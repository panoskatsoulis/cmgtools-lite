#!/bin/bash

function printUsefulFunctions(){
    [ -z $CMSSW_BASE ] && { echo "Run cmsenv and re-source this file."; return 1; }
    grep '^function' $CMSSW_BASE/src/CMGTools/condor_prod/useful_functions.sh | sed -r 's@function (.*)\{$@\1@'
    return 0
}

function checkHeppyFiles(){
    CLUSTER=$1
    ll prod_treeProducersPerProcess/heppy.*$CLUSTER* | awk '{printf "\033[0;33mFile created at "$6"-"$7"-"$8"|\t"$9"\033[0m\n"; system("tail -3 "$9); printf "\n"}'
    return 0
}

function cleanProducts(){
    { rm -f output/* && rm -f error/* && rm -f log/*; } || return 1
    { rm -rf prod_treeProducersPerProcess; } || return 2
    { rm -f *~ && rm -f kpanos.cc; } || return 3
    { rm -rf jobBase_* && ll . log output error; } || return 4
    return 0
}

function enableSosLinks(){
    [ -e analysis_scripts/sosmca.link.disabled ] && {
	mv analysis_scripts/sosmca.link.disabled analysis_scripts/sosmca.link
	mv analysis_scripts/sosmca.txt analysis_scripts/sosmca.txt.disabled
	mv analysis_scripts/sosmca.link analysis_scripts/sosmca.txt
    }
    [ -e analysis_scripts/soscuts.link.disabled ] && {
	mv analysis_scripts/soscuts.link.disabled analysis_scripts/soscuts.link
	mv analysis_scripts/soscuts.txt analysis_scripts/soscuts.txt.disabled
	mv analysis_scripts/soscuts.link analysis_scripts/soscuts.txt
    }
    [ -e analysis_scripts/sosplots.link.disabled ] && {
	mv analysis_scripts/sosplots.link.disabled analysis_scripts/sosplots.link
	mv analysis_scripts/sosplots.txt analysis_scripts/sosplots.txt.disabled
	mv analysis_scripts/sosplots.link analysis_scripts/sosplots.txt
    }
    return 0
}

function disableSosLinks(){
    [ -h analysis_scripts/sosmca.txt ] && {
	mv analysis_scripts/sosmca.txt analysis_scripts/sosmca.link.disabled
	mv analysis_scripts/sosmca.txt.disabled analysis_scripts/sosmca.txt
    }
    [ -h analysis_scripts/soscuts.txt ] && {
	mv analysis_scripts/soscuts.txt analysis_scripts/soscuts.link.disabled
	mv analysis_scripts/soscuts.txt.disabled analysis_scripts/soscuts.txt
    }
    [ -h analysis_scripts/sosplots.txt ] && {
	mv analysis_scripts/sosplots.txt analysis_scripts/sosplots.link.disabled
	mv analysis_scripts/sosplots.txt.disabled analysis_scripts/sosplots.txt
    }
    return 0
}

printUsefulFunctions
