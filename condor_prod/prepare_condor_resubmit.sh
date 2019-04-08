#!/bin/bash

function dohelp() {
    echo "Usage $0 <opt1> <arg1> ... <optN> <argN>"
    echo "Supported arguments"
    echo "   --help, -h    : Print this and exit"
    echo "   --cluster     : Specify the condor cluster in which the production has been done."
    echo "   --process     : Specify the process for which the jobs were running."
    echo "   --submit-file : Input for the condor submit file which will be copied, modified and used."
    exit 0
}

[ "$#" == '0' ] && dohelp
while [ ! -z $1 ]; do
    { [ "$1" == "--help" ] || [ "$1" == "-h" ]; } && dohelp
    [ "$1" == "--cluster" ] && { CONDOR_CLUSTER=$2; shift 2; continue; }
    [ "$1" == "--process" ] && { PROCESS=$2; shift 2; continue; }
    [ "$1" == "--submit-file" ] && { CONDOR_SUBMIT_FILE=$2; shift 2; continue; }
    echo "Unsupported argument, $1" && exit 101
done

{ [ -z "$CONDOR_CLUSTER" ] || [ -z "$PROCESS" ] || [ -z "$CONDOR_SUBMIT_FILE" ]; } \
    && { echo "All arguments must be filled."; exit 1; }

[ -e ${CONDOR_SUBMIT_FILE}.resubmit ] && {
    printf ".resubmit file for the given condor submit file alrady exist.\nDo you want to proceed and overwrite the old file? [y/n]";
    read ans;
    case $ans in
	y)
	    echo "will overwrite the old .duplicate file.";;
	n)
	    echo "exiting."; exit 0;;
	*)
	    echo "unknown answer, exiting."; exit 2;;
    esac
}
cp -a $CONDOR_SUBMIT_FILE ${CONDOR_SUBMIT_FILE}.resubmit && CONDOR_SUBMIT_FILE=${CONDOR_SUBMIT_FILE}.resubmit

for heppyFile in $(ls prod_treeProducersPerProcess/heppy.${PROCESS}_${CONDOR_CLUSTER}.* | sort -n);
do
    echo $heppyFile
    JOB=$(echo $heppyFile | sed -r 's@.*_([^_]*)\.out$@\1@') && echo $JOB
    PRODUCTION_DONE=$(grep -wE 'production|submitting' $heppyFile \
	| sed -r 's@^([^ ]*) .*@\1@' \
	| uniq -c \
	| sed 'N; s@\n@ @' \
	| awk '{if ($1==$3) {printf "true"} }' )
    [ -z "$PRODUCTION_DONE" ] && PRODUCTION_DONE=false
    echo "PRODUCTION_DONE=${PRODUCTION_DONE}"

    $PRODUCTION_DONE && {
	TREE_PRODUCER=prod_treeProducersPerProcess/run_susyMultilepton_cfg_jpsi_noMetCut_${PROCESS}.${JOB}.py;
	[ ! -e $TREE_PRODUCER ] && { echo "Tree producer for the job $JOB couldn't be found"; continue; };
	FILES=$(grep files.*#sosTrees_production $TREE_PRODUCER | sed -r 's@.*\[(.*):(.*)\].*@\1,\2@');
	sed -i -r "s@(^.*${FILES}$)@#\1@" $CONDOR_SUBMIT_FILE;
    }
done

exit 0
