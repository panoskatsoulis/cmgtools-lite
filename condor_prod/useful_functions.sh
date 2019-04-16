#!/bin/bash

function printUsefulFunctions(){
    [ -z $CMSSW_BASE ] && { echo "Run cmsenv and re-source this file."; return 1; }
    grep '^function' $CMSSW_BASE/src/CMGTools/condor_prod/useful_functions.sh | sed -r 's@function (.*)\{$@\1@'
    return 0
}

function checkHeppyFiles(){
    ll prod_treeProducersPerProcess/heppy.* | awk '{printf "----> "$6"-"$7"-"$8":\t"$9"\n"; system("tail -3 "$9)}'
    return 0
}

function cleanProducts(){
    { rm -f output/* && rm -f error/* && rm -f log/*; } || return 1
    { rm -rf prod_treeProducersPerProcess; } || return 2
    { rm -f *~ && rm -f kpanos.cc; } || return 3
    { rm -rf jobBase_* && ll . log output error; } || return 4
    return 0
}

printUsefulFunctions