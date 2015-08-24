# make
# 
# Copyright 2015 Consolidated Logic 
# 
# This is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
# 
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this software; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street,
# Boston, MA 02110-1301, USA.
# 
# Todd Fleming 2007
#
# ===========================================================================
# = Commands
# ===========================================================================
# make              same as "make bit"
# make TOP='ModuleName' as a generic Makefile
# make CLK='clk' for clock naming
# make clean        Remove intermediate and final output files
# make xst          Synthesize design
# make translate    Translate design
# make map          Map design
# make par          Place and route design and
#                   generate timing report
# make bit          Make bitfile
#
# ===========================================================================
# = Makefile configuration
# ===========================================================================
SHELL = /bin/bash
# Top-level module
TOP = passthrough
# Bitstream name
BITSTREAM_NAME = $(TOP)
# Build directory
BUILD_DIR = ./build/$(TOP)
# Source directory
SRC_DIR = ./src
# Library directory
LIB_DIR = ./lib
# Precompiled cores (ngd, ncd, edif, etc):
PRECOMPILED_DIR = $(SRC_DIR)/precompiled
PRECOMPILED_CORES = $(wildcard $(PRECOMPILED_DIR)/*) 
# TORC
TORC = /usr/share/rda/ 
# Bus Macro Manipulation
BMNUM = 0
# Clock Name
CLK = "bus_clk ce_clk"

# ===========================================================================
# Shaping things
# Constraint file
UCF = $(SRC_DIR)/$(TOP).ucf
# Xilinx part #
PART = xc7k410tffg900-2
#xc7z020clg484-1
#xc5vlx110tff1136-1
# Amount of extra resources to allocate
CLB_TOLERANCE=50
BRAM_TOLERANCE=0
DSP_TOLERANCE=0
EXTRA_RESOURCE=20
# Device location to generate shapes
	# Can probably be omitted with the new shape_generator
CONSTRAINTS = 0 0 999 349 
# Number of shapes (UCFs) to generate
NUM_SHAPES=10
# Submodule directory prefix
SUB_PREFIX=build_

# Logs
SHAPE_LOG=shape_log


# ===========================================================================
# = Shortcuts
# ===========================================================================

default:   shape
translate: $(BUILD_DIR)/$(TOP).ngd
map:       $(BUILD_DIR)/$(TOP)_map.ncd $(BUILD_DIR)/$(TOP).pcf
par:       $(BUILD_DIR)/$(TOP)_routed.ncd
bit:       $(BUILD_DIR)/$(BITSTREAM_NAME).bit

$(UCF): $(SRC_DIR)/$(TOP).ndf
	# ===========================================================================
	# = Automatically figure out resource requirements and generate ucf
	# ===========================================================================
	mkdir -p $(BUILD_DIR)
	cp -p $(SRC_DIR)/$(TOP).ndf $(BUILD_DIR)/$(TOP).ndf
	cp -p $(SRC_DIR)/$(TOP)/* $(BUILD_DIR)/ 
	#Generate Plan Ahead tcl script and then run PA
	cd $(BUILD_DIR) && pa_script $(TORC) $(TOP).ndf rda $(PART) $(CONSTRAINTS)
	cd $(BUILD_DIR) && make -f shape_module TOP=$(TOP) NUM_SHAPES=$(NUM_SHAPES) \
		CLB_TOLERANCE=$(CLB_TOLERANCE) BRAM_TOLERANCE=$(BRAM_TOLERANCE) \
		DSP_TOLERANCE=$(DSP_TOLERANCE) EXTRA_RESOURCE=$(EXTRA_RESOURCE) | tee $(SHAPE_LOG)

$(BUILD_DIR)/$(TOP).ngd : $(SRC_DIR)/$(TOP).ndf $(SRC_DIR)/xpartition.pxml $(PRECOMPILED_CORES) #$(BMM) 
	# ===========================================================================
	# = ngdbuild (Translate)
	# ===========================================================================
	mkdir -p $(BUILD_DIR)	
	cd $(BUILD_DIR) && EdifWrapper $(TOP).ndf
	cd $(BUILD_DIR) && cp -p $(TOP)_Wrapped.ndf $(TOP).ndf
	#NEED this xpartition file apparently.
	cp -p $(SRC_DIR)/xpartition.pxml $(BUILD_DIR)/xpartition.pxml
	cd $(BUILD_DIR) && edif2ngd -aul -p $(PART) -intstyle xflow $(TOP).ndf
	#cp -p $(UCF) $(BUILD_DIR)/$(TOP).ucf & 
	cd $(BUILD_DIR) && ngdbuild -aul -p $(PART) -intstyle xflow $(TOP) $(TOP).ngd
	# Andrew: Create XML for edif
	cd $(BUILD_DIR) && EdifToXML $(TOP).ndf
	
$(BUILD_DIR)/$(TOP)_map.ncd $(BUILD_DIR)/$(TOP).pcf : $(BUILD_DIR)/$(TOP).ngd $(BUILD_DIR)/$(TOP).xml
	# ===========================================================================
	# = map
	# ===========================================================================
	mkdir -p $(BUILD_DIR)
	#original
	#cd $(BUILD_DIR) && map -u -detail -o $(TOP)_map.ncd -w -intstyle pa $(TOP).ngd $(TOP).pcf
	cd $(BUILD_DIR) && map -detail -o $(TOP)_map.ncd -w -intstyle pa $(TOP).ngd $(TOP).pcf
	cd $(BUILD_DIR) && xdl -ncd2xdl $(TOP)_map.ncd
	cd $(BUILD_DIR) && cp $(TOP)_map.ncd $(TOP).ncd
	cd $(BUILD_DIR) && XMLRDAPhysicalUpdater $(TOP)_map.xdl $(TORC) $(TOP).xml $(CLK)


$(BUILD_DIR)/$(TOP)_routed.ncd : $(BUILD_DIR)/$(TOP)_map.ncd $(BUILD_DIR)/$(TOP).pcf
	# ===========================================================================
	# = par
	# ===========================================================================
	mkdir -p $(BUILD_DIR)
	#needed this apparently at some point, but its commented out for now
	#export XIL_PLACE_ALLOW_LOCAL_BUFG_ROUTING=1 && 
	#cd $(BUILD_DIR) && par -w -ol std -intstyle pa $(TOP)_map.ncd $(TOP)_routed.ncd $(TOP).pcf
	cd $(BUILD_DIR) && par -w -k $(TOP).ncd $(TOP).ncd $(TOP).pcf
	# Create the script to unroute the CLK(s) for later routing in RDA
	cd $(BUILD_DIR) && RDAClockUnroute $(CLK)
	cd $(BUILD_DIR) && fpga_edline -p Unroute $(TOP).ncd
	cd $(BUILD_DIR) && xdl -ncd2xdl $(TOP).ncd
	# XML updater
	cd $(BUILD_DIR) && XMLPipsUpdater $(TOP).xdl $(TORC) $(TOP)_rda.xml
	mv $(BUILD_DIR)/$(TOP).xml $(BUILD_DIR)/$(TOP)_orig.xml
	mv $(BUILD_DIR)/$(TOP)_rda_rda.xml $(BUILD_DIR)/$(TOP).xml
	# Transform xdl into hard macro (xdl module)
	cd $(BUILD_DIR) && cp $(TOP).xdl $(TOP)_par.xdl
	cd $(BUILD_DIR) && create_hardmacro $(TORC) $(TOP).xdl $(TOP).xml $(TOP)_design $(PART)
	cd $(BUILD_DIR) && mv $(TOP)_design.xdl $(TOP).xdl

$(BUILD_DIR)/$(BITSTREAM_NAME).bit : $(BUILD_DIR)/$(TOP)_routed.ncd
	# ===========================================================================
	# = bitgen (DRC disabled)
	# ===========================================================================
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && bitgen -w -d $(TOP).ncd $(BITSTREAM_NAME)

.PHONY: shape 

shape: $(UCF)
	# UCFs have been built at this point
	mkdir -p $(BUILD_DIR)/UCFs
	cp $(BUILD_DIR)/*.ucf $(BUILD_DIR)/UCFs/
	# Create subdirectories for each shape and move corresponding UCFs over
	for i in {1..$(NUM_SHAPES)} ; do \
		if [ -e $(BUILD_DIR)/$(TOP)_$$i-1.ucf ] ; then \
			mkdir -p $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i ; \
			mv $(BUILD_DIR)/$(TOP)_$$i-1.ucf $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i/$(TOP).ucf ; \
		fi ; \
	done ;
	rm $(BUILD_DIR)/*.ucf
	# read -p "Pausing to allow for manual UCF file override. Press 'Enter' to continue"
	# Copy remaining files over and recursively run make on each subdirectory
	# No clobber is enabled to prevent overwriting of UCF file
	for i in {1..$(NUM_SHAPES)} ; do \
		if [ -d $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i ] ; then \
			cp -u $(BUILD_DIR)/* $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i/ ; \
			$(MAKE) -f Makefile TOP=$(TOP) CLK="$(CLK)" BUILD_DIR=$(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i bit ; \
		fi ; \
	done ;

library: 
	# ===========================================================================
	# = Add a built module to the library
	# ===========================================================================
	# Update the XML file with the shape's ID
	xml_pre_combine $(TOP) $(BUILD_DIR) 
	mkdir -p $(LIB_DIR)
	# Copy files over to the lib folder
	let "n=0" ; \
	for i in {1..$(NUM_SHAPES)} ; do \
		if [ -e $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i/$(TOP).ncd ] && [ -e $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i/$(TOP).bit ] && \
		   [ -e $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i/$(TOP).xdl ] && [ -e $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i/$(TOP).xml ] && \
		   [ -e $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i/$(TOP).ucf ] && [ -e $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i/$(TOP)_par.xdl ] ; then \
		   	let "n+=1" ; \
			mkdir -p $(LIB_DIR)/$(TOP)_$$i ; \
			cp $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i/$(TOP).ncd $(LIB_DIR)/$(TOP)_$$i/$(TOP).ncd ; \
			cp $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i/$(TOP).bit $(LIB_DIR)/$(TOP)_$$i/$(TOP).bit ; \
			cp $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i/$(TOP).xdl $(LIB_DIR)/$(TOP)_$$i/$(TOP).xdl ; \
			cp $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i/$(TOP).xml $(LIB_DIR)/$(TOP)_$$i/$(TOP).xml ; \
			cp $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i/$(TOP).ucf $(LIB_DIR)/$(TOP)_$$i/$(TOP).ucf ; \
			cp $(BUILD_DIR)/$(SUB_PREFIX)$(TOP)_$$i/$(TOP)_par.xdl $(LIB_DIR)/$(TOP)_$$i/$(TOP)_par.xdl ; \
			( cd $(LIB_DIR)/$(TOP)_$$i/ && metadataConverter $(TOP).xml ) ; \
		fi ; \
	done ; \
	
	echo "$$n shapes successfully synthesized out of $(NUM_SHAPES)" ;


clean:
	# ===========================================================================
	# = Remove intermediate and output files
	# ===========================================================================
	rm -rf $(BUILD_DIR)

