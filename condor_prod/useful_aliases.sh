#!/bin/bash

function printUsefulAliases(){
    [ -z $CMSSW_BASE ] && { echo "Run cmsenv and re-source this file."; return 1; }
    grep ^alias $CMSSW_BASE/src/CMGTools/condor_prod/useful_aliases.sh | sed -r 's/alias (.*)=.*/new alias "\1"/'
    return 0
}

alias checkHeppyFiles='for file in $(ls prod_treeProducersPerProcess/heppy.*); do echo "-----> $file" && tail -3 $file; done'
alias cleanProducts='rm -f output/* && rm -f error/* && rm -f log/* && rm -rf prod_treeProducersPerProcess && rm -f *~ && rm -f kpanos.cc && rm -rf jobBase_* && ll . log output error'

printUsefulAliases
