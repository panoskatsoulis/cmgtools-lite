#!/bin/bash
#set -x

## prepate env
cd $SOS_data18/CMSSW_10_4_0/src/CMGTools/TTHAnalysis/python/plotter
eval `scramv1 runtime -sh`

## get the input vars
REGION=$1
BIN=$2
DATA=$3
OUTPUT=$4
SCENARIO=$5

## build the command
COMMAND="python susy-sos-v2-clean/sos_plots.py --recursive-cuts --lep 2los --reg $REGION --bin $BIN $OUTPUT 2018 --study-mod SingleMuonTrigger $SCENARIO True --run"
[ "$DATA" == "--data" ] && COMMAND="$COMMAND --data"
COMMAND="$COMMAND > $CMSSW_BASE/src/plotting_logs/plots-${REGION}_${BIN}_$SCENARIO"
echo "Command to run:"
echo $COMMAND

## run the command and exit whatever code has been returned
#eval $COMMAND
exit $?
