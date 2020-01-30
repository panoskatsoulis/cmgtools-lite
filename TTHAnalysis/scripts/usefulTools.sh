#!/bin/bash

function usefulTools_run() {
    [ -z "$CMSSW_BASE" ] && { echo "do cmsenv"; return 1; }
    echo "Registered the following tools:"
    grep '^function' $CMSSW_BASE/src/CMGTools/TTHAnalysis/scripts/usefulTools.sh | \
	sed -r 's/function (.*)\(.*/\1/' | grep -v usefulTools
    echo
    return 0
}

function usefulTools_dohelp() {
    { [[ $2 =~ \-*help ]] || [ "$2" == "-h" ]; } && {
	printf "$1\n\n"
	return 0
    }
    return 1
}

function tailall() {
    usefulTools_dohelp "Usage: tailall -<lines> <files>" $@ && return 0
    lines=$1; shift
    for file in $(ls $@);
    do
	echo "=================================> $file"
	tail $lines $file
    done
    return 0
}

usefulTools_run
