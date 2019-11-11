#!/bin/bash

## clean outputs
[ -z $CMSSW_BASE ] && echo "do cmsenv"
fs quota && echo "Removing old working directories (local chunks) under $CMSSW_BASE/src ..."
# rm -rf $CMSSW_BASE/src/mcFTrees*
# rm -rf $CMSSW_BASE/src/dataFTrees*
rm -rf $CMSSW_BASE/src/fullProd_WJets
fs quota

## For quick testing the below switches can be used
## DATA --> --dataset '.*Run[0-9]*B.*'
## MC   --> --dataset '.*Jets.*'
## They can also be followed by --debug for more verbosity.
# INPUT_TREES_DIR=/eos/user/k/kpanos/sostrees/2018/cr-DYandTT-issue/fullProdTest_TTJets-25Oct2019/TTJets_test/postprocessor_chunks
REMOTE_OUT_DIR=/eos/user/k/kpanos/sostrees/2018/cr-DYandTT-issue/fullProdTest_VVCR-27Oct2019 ## it MUST be mounted, otherwise needs modifications (for other T2s & T3s, needs xrd)

## 2018
# echo "Submitting workflow 2018-mc..."
# ./sosTreesProduction.sh --friends-only --task mcFTreesReprod2018 --type mc --year 2018 -in $INPUT_TREES_DIR -out $REMOTE_OUT_DIR --freq 20m --force-rm > workflow-2018-mc.log 2>&1 &
# PID_2018MC=$!

# sleep 5s
# echo "Submitting workflow 2018-data..."
# ./sosTreesProduction.sh --friends-only --task dataFTreesReprod2018 --type data --year 2018 -in $INPUT_TREES_DIR -out $REMOTE_OUT_DIR --freq 20m --force-rm > workflow-2018-data.log 2>&1 &
# PID_2018DATA=$!

## full prod test
INPUT_CFG=$CMSSW_BASE/src/CMGTools/TTHAnalysis/cfg/run_susySOS_fromNanoAOD_cfg.py
echo "Submitting test workflow "fullProd" 2018..."
sosTreesProduction.sh --task fullProd_WJets --type mc --year 2018 -in $INPUT_CFG -out $REMOTE_OUT_DIR --freq 20m --force-rm --dataset 'WJets.*,WZ.*,WW.*,ZZ.*,WpWpJJ' > fullProd_WJets.log 2>&1 &
PID_WJets=$!


echo "Waiting for job $PID_WJets.."; wait $PID_WJets
#echo "Waiting for job $PID_2018DATA.."; wait $PID_2018DATA
#echo "Waiting for job $PID_2018MC.."; wait $PID_2018MC
echo "Done"
exit 0
