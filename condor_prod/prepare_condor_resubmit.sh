#!/bin/bash

function dohelp() {
    printf "
Usage $0 <opt1> <arg1> ... <optN> <argN>
Supported arguments
   --help, -h         : Print this and exit
   --cluster          : Specify the condor cluster in which the production has been done.
   --process          : Specify the process for which the jobs were running.
   --submit-file      : Input for the condor submit file which will be copied, modified and used.
   --resubmit-file    : Input for the condor resubmit file which will be copied, modified and used.
   --failure-specific : Specify a pattern to search as the failure reason in the heppy files,
                        and produce a resubmit file for only the jobs failed this way.
   --prod-done-false  : Will resubmit only jobs that have the PRODUCTION_DONE flag false.
"
    exit 0
}

[ "$#" == '0' ] && dohelp
while [ ! -z $1 ]; do
    { [ "$1" == "--help" ] || [ "$1" == "-h" ]; } && dohelp
    [ "$1" == "--cluster" ] && { CONDOR_CLUSTER=$2; shift 2; continue; }
    [ "$1" == "--process" ] && { PROCESS=$2; shift 2; continue; }
    [ "$1" == "--submit-file" ] && { CONDOR_SUBMIT_FILE=$2; shift 2; continue; }
    [ "$1" == "--resubmit-file" ] && { CONDOR_RESUBMIT_FILE=$2; shift 2; continue; }
    [ "$1" == "--failure-specific" ] && { FAILURE_SPECIFIC=true; FAILURE=$2; shift 2; continue; }
    [ "$1" == "--prod-done-false" ] && { PROD_FAILED_MODE=true; shift 1; continue; }
    echo "Unsupported argument, $1" && exit 101
done

[ -z $FAILURE_SPECIFIC ] && FAILURE_SPECIFIC=false
[ -z $PROD_FAILED_MODE ] && PROD_FAILED_MODE=false
if ! $PROD_FAILED_MODE && ! $FAILURE_SPECIFIC; then
    { [ -z "$CONDOR_CLUSTER" ] || [ -z "$PROCESS" ] || [ -z "$CONDOR_SUBMIT_FILE" ]; } \
	&& { echo "The cluster-id, the process and the initial condor submit file must be specified. Otherwise run in --failure-specific or in --prod-done-false mode."; exit 1; }

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
fi

if $FAILURE_SPECIFIC; then
    SUFFIX=$(echo $FAILURE | sed -r 's@[^A-Za-z0-9]+@\-@g')
    cp -a $CONDOR_SUBMIT_FILE ${CONDOR_SUBMIT_FILE}.resubmit.${SUFFIX}
    CONDOR_SUBMIT_FILE=${CONDOR_SUBMIT_FILE}.resubmit.${SUFFIX}
elif ! [ -z $CONDOR_RESUBMIT_FILE ]; then
    ## instead of a submit file a resubmit file has been given
    ## the given condor submit file will be overridden
    ! [ -z $CONDOR_SUBMIT_FILE ] && {
	echo "A condor resubmit file has been provided to the prepare resubmit script."
	echo "The CONDOR_SUBMIT_FILE var will be overridden with the contents of the CONDOR_RESUBMIT_FILE var."
    }
    CONDOR_SUBMIT_FILE=$CONDOR_RESUBMIT_FILE
else
    cp -a $CONDOR_SUBMIT_FILE ${CONDOR_SUBMIT_FILE}.resubmit
    CONDOR_SUBMIT_FILE=${CONDOR_SUBMIT_FILE}.resubmit
fi
touch $CONDOR_SUBMIT_FILE # update the date of the file

if $PROD_FAILED_MODE; then
    ## This mode checks for the flag PRODUCTION_DONE in the out files of the sosTrees_production
    ## if the flag is true comment out the job from the condor submit file
    ## it works with the simple .resubmit file
    ## Also, here the procedure is inverted (because of the continue keywords used)
    ## in a given commented out file, uncomment the failed jobs
    #[OLD-PROCESS-SPECIFIC] sed -i -r "/${PROCESS}/ s/(.*)/#\1/" $CONDOR_SUBMIT_FILE
    sed -i -r 's/(^[^ ,#]*,[0-9]*,[0-9]*)/#\1/' $CONDOR_SUBMIT_FILE

    ! ls output/*.out &>/dev/null && { echo "No jobs exist in the output/ path yet."; exit 11; }
    for outfile in $(grep PROCESS output/*.out | grep $PROCESS | sed -r 's/^([^:]*\.out).*/\1/'); do
	! [[ $(grep PROCESS $outfile) =~ .*$PROCESS ]] && continue
	JOB=$(echo $outfile | sed -r 's@.*/condor\.(.*\..*)\.out$@\1@') && {
	    [ ! -z $JOB ] && echo "job found."; }
	[ ! -s $outfile ] && { # if the outfile is still empty, refresh the heppy links if possible and skip the job
	    echo "The job $JOB has not output written yet. Skipping, either it's running or is idle.";
	    JOB_HEPPY_FILE=$(find jobBase*${JOB}/ 2>/dev/null | grep heppy.*\.out$)
	    [ -z $JOB_HEPPY_FILE ] && continue || echo "JOB_HEPPY_FILE=$JOB_HEPPY_FILE"
	    PROD_PATH_LINK=prod_treeProducersPerProcess/$(basename $JOB_HEPPY_FILE) && echo "PROD_PATH_LINK=$PROD_PATH_LINK"
	    ln -sf ../$JOB_HEPPY_FILE $PROD_PATH_LINK
	    continue;
	}

	TREE_PRODUCER=$(find prod_treeProducersPerProcess/ | grep ${JOB}\.py$)
	[ -e $TREE_PRODUCER ] && rm -f $TREE_PRODUCER || echo "Tree producer couldn't be found."
	FILES=$(grep FILES.* $outfile | sed -r 's@.*\[(.*):(.*)\].*@\1,\2@') && {
	    [ ! -z $FILES ] && echo "files found."; }
	PRODUCTION_DONE=$(grep PRODUCTION_DONE $outfile | sed -r 's/ //g; s/\x1B\[0[;0-9]*m//g;' | awk -F = '{print $2}') && {
	    [ ! -z $PRODUCTION_DONE ] && echo "flag found."; }
	[ -z $PRODUCTION_DONE ] && PRODUCTION_DONE=false
	echo ">> $JOB, $TREE_PRODUCER, $(echo $FILES | tr ',' ':'), $PRODUCTION_DONE)"

	echo $PRODUCTION_DONE
	! $PRODUCTION_DONE && {
	    printf "running sed.. "
	    sed -i -r "s@^#(${PROCESS},${FILES}$)@\1@" $CONDOR_SUBMIT_FILE;
	    printf "sed exited $?.\n$ grep ${PROCESS}.*${FILES} $CONDOR_SUBMIT_FILE\n"
	    grep ${PROCESS},${FILES} $CONDOR_SUBMIT_FILE
	    rm -f $outfile prod_treeProducersPerProcess/*${JOB}*;
	    condor_rm $JOB;
	}
    done
    exit 0
fi

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
