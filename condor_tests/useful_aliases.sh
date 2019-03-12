#!/bin/bash

function printUsefulAliases(){
    grep ^alias $CMSSW_BASE/src/CMGTools/condor_tests/useful_aliases.sh | sed -r 's/alias (.*)=.*/new alias "\1"/'
}

alias checkHeppyFiles='for file in $(ls slimProd_treeProducersPerProcess/heppy.*); do echo "-----> $file" && tail -3 $file; done'
alias cleanProducts='rm -f output/* && rm -f error/* && rm -f log/* && rm -rf slimProd_treeProducersPerProcess && rm -f *~ && rm -f kpanos.cc && rm -rf jobBase_* && ll . log output error'

printUsefulAliases