#!/bin/bash
LOGS="./makefile_module_log"

cp $1/synth_log $LOGS/synth_log
sed -n "/HDL Synthesis Report/,/===/p" $LOGS/synth_log > $LOGS/HDL_log
sed -n "/Timing Summary/,/===/p" $LOGS/synth_log > $LOGS/timing_log
