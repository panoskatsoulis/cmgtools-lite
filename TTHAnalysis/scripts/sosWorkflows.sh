#!/bin/bash

## clean outputs
[ -z $CMSSW_BASE ] && echo "do cmsenv"
fs quota && echo "Removing old working directories (local chunks) under $CMSSW_BASE/src ..."
rm -rf $CMSSW_BASE/src/mcWorkflow2016
rm -rf $CMSSW_BASE/src/dataWorkflow2016
rm -rf $CMSSW_BASE/src/mcWorkflow2017
rm -rf $CMSSW_BASE/src/dataWorkflow2017
rm -rf $CMSSW_BASE/src/mcWorkflow2018
rm -rf $CMSSW_BASE/src/dataWorkflow2018
fs quota

## For quick testing the below switches can be used
## DATA --> --dataset '.*Run[0-9]*B.*'
## MC   --> --dataset '.*Jets.*'
## They can also be followed by --debug for more verbosity.
REMOTE_OUT_DIR=/eos/user/k/kpanos/sostrees/test-workflows ## it MUST be mounted, otherwise needs modifications (for other T2s & T3s, needs xrd)

## 2016
echo "Submitting workflow 2016-mc..."
./sosTreesProduction.sh --friends-only --task mcWorkflow2016 --type mc --year 2016 -in /eos/cms/store/cmst3/group/tthlep/peruzzi/NanoTrees_SOS_230819_v5/2016 -out $REMOTE_OUT_DIR --freq 20m --force-rm > workflow-2016-mc.log 2>&1 &
sleep 5s

echo "Submitting workflow 2016-data..."
./sosTreesProduction.sh --friends-only --task dataWorkflow2016 --type data --year 2016 -in /eos/cms/store/cmst3/group/tthlep/peruzzi/NanoTrees_SOS_230819_v5/2016 -out $REMOTE_OUT_DIR --freq 20m --force-rm > workflow-2016-data.log 2>&1 &
sleep 5s


## 2017
echo "Submitting workflow 2017-mc..."
./sosTreesProduction.sh --friends-only --task mcWorkflow2017 --type mc --year 2017 -in /eos/cms/store/cmst3/group/tthlep/peruzzi/NanoTrees_SOS_230819_v5/2017 -out $REMOTE_OUT_DIR --freq 20m --force-rm > workflow-2017-mc.log 2>&1 &
sleep 5s

echo "Submitting workflow 2017-data..."
./sosTreesProduction.sh --friends-only --task dataWorkflow2017 --type data --year 2017 -in /eos/cms/store/cmst3/group/tthlep/peruzzi/NanoTrees_SOS_230819_v5/2017 -out $REMOTE_OUT_DIR --freq 20m --force-rm > workflow-2017-data.log 2>&1 &
sleep 5s


## 2018
echo "Submitting workflow 2018-mc..."
./sosTreesProduction.sh --friends-only --task mcWorkflow2018 --type mc --year 2018 -in /eos/cms/store/cmst3/group/tthlep/peruzzi/NanoTrees_SOS_230819_v5/2018 -out $REMOTE_OUT_DIR --freq 20m --force-rm > workflow-2018-mc.log 2>&1 &
sleep 5s

echo "Submitting workflow 2018-data..."
./sosTreesProduction.sh --friends-only --task dataWorkflow2018 --type data --year 2018 -in /eos/cms/store/cmst3/group/tthlep/peruzzi/NanoTrees_SOS_230819_v5/2018 -out $REMOTE_OUT_DIR --freq 20m --force-rm > workflow-2018-data.log 2>&1 &

echo "Done"
