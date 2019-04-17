#!/bin/bash

function dohelp() {
    printf "
Usage $0 <opt1> <arg1> ... <optN> <argN>
Supported arguments
   --help, -h         : Print this and exit
   --cluster          : Specify the condor cluster in which the production has been done.
   --process          : Specify the process for which the jobs were running.
   --submit-file      : Input for the condor submit file which will be copied, modified and used.
   --failure-specific : Specify a pattern to search as the failure reason in the heppy files,
                        and produce a resubmit file for only the jobs failed this way.
"
    exit 0
}

[ "$#" == '0' ] && dohelp
while [ ! -z $1 ]; do
    { [ "$1" == "--help" ] || [ "$1" == "-h" ]; } && dohelp
    [ "$1" == "--cluster" ] && { CONDOR_CLUSTER=$2; shift 2; continue; }
    [ "$1" == "--process" ] && { PROCESS=$2; shift 2; continue; }
    [ "$1" == "--submit-file" ] && { CONDOR_SUBMIT_FILE=$2; shift 2; continue; }
    [ "$1" == "--failure-specific" ] && { FAILURE_SPECIFIC=true; FAILURE=$2; shift 2; continue; }
    echo "Unsupported argument, $1" && exit 101
done

{ [ -z "$CONDOR_CLUSTER" ] || [ -z "$PROCESS" ] || [ -z "$CONDOR_SUBMIT_FILE" ]; } \
    && { echo "The cluster-id, the process and the initial condor submit file must be specified."; exit 1; }
[ -z $FAILURE_SPECIFIC ] && FAILURE_SPECIFIC=false

{ [ -e ${CONDOR_SUBMIT_FILE}.resubmit ] && [ ! $FAILURE_SPECIFIC ]; } && {
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

if $FAILURE_SPECIFIC; then
    SUFFIX=$(echo $FAILURE | sed -r 's@[^A-Za-z0-9]+@\-@g')
    cp -a $CONDOR_SUBMIT_FILE ${CONDOR_SUBMIT_FILE}.resubmit.${SUFFIX}
    CONDOR_SUBMIT_FILE=${CONDOR_SUBMIT_FILE}.resubmit.${SUFFIX}
else
    cp -a $CONDOR_SUBMIT_FILE ${CONDOR_SUBMIT_FILE}.resubmit
    CONDOR_SUBMIT_FILE=${CONDOR_SUBMIT_FILE}.resubmit
fi
touch $CONDOR_SUBMIT_FILE # update the date of the file

for heppyFile in $(ls prod_treeProducersPerProcess/heppy.${PROCESS}_${CONDOR_CLUSTER}.* | sort -n);
do
    echo $heppyFile
    JOB=$(echo $heppyFile | sed -r 's@.*_([^_]*)\.out$@\1@')
    TREE_PRODUCER=$(find prod_treeProducersPerProcess/ | grep ${JOB}\.py$)
    [ ! -e $TREE_PRODUCER ] && { echo "Tree producer for the job $JOB couldn't be found"; continue; }
    FILES=$(grep files.*#sosTrees_production $TREE_PRODUCER | sed -r 's@.*\[(.*):(.*)\].*@\1,\2@')
    echo ">> $JOB, $TREE_PRODUCER, $FILES, GREP=$(grep $FAILURE $heppyFile)"

    PRODUCTION_DONE=$(grep -wE 'production|submitting' $heppyFile \
	| sed -r 's@^([^ ]*) .*@\1@' \
	| uniq -c \
	| sed 'N; s@\n@ @' \
	| awk '{if ($1==$3) {printf "true"} }' )
    [ -z "$PRODUCTION_DONE" ] && PRODUCTION_DONE=false
    echo "PRODUCTION_DONE=${PRODUCTION_DONE}"

    # if the failure will not be found,
    # the related job will be commented out in the produced submit file
    { $FAILURE_SPECIFIC && ! $PRODUCTION_DONE; } && {
	! grep -i $FAILURE $heppyFile && sed -i -r "s@(^.*${FILES}$)@#\1@" $CONDOR_SUBMIT_FILE
	continue
    }

    # simply, if the job finished comment it out
    $PRODUCTION_DONE && sed -i -r "s@(^.*${FILES}$)@#\1@" $CONDOR_SUBMIT_FILE
done

exit 0
