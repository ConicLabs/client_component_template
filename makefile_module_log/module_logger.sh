#!/bin/bash
#this is executed one directory up, but the logs should be placed in this directory anyway
LOGS="./makefile_module_log"

cp $1/module_log $LOGS/module_log
sed -n "/INFO: Parsed/,/This module is anchored/p" $LOGS/module_log | grep "net.*is an" > $LOGS/port_log
sed -n "/Device Utilization Summary:/,/Overall effort level/p" $LOGS/module_log > $LOGS/resource_log
sed -n "/Logical Boundary/,/Output xml/p" $LOGS/module_log > $LOGS/boundary_log
sed -n "/anchored at/,/The/p" $LOGS/module_log > $LOGS/anchored_log
sed -n "/column placement/,/Placement information/p" $LOGS/module_log > $LOGS/placement_log
