#!/bin/bash
! [ -z $CMSSW_BASE ] && CMSSW_DIR=$CMSSW_BASE/src || { echo "do cmsenv"; exit 1; }

## load functions
source $CMSSW_DIR/CMGTools/TTHAnalysis/scripts/sosTreesProduction.dep

## parse arguments
while ! [ -z "$1" ]; do
    { [ "$1" == "-h" ] || [[ $1 =~ \-*help ]]; } && do_treeProd_help $2
    [ "$1" == "--task" ] && { TASK_NAME=$2; shift 2; continue; }
    [ "$1" == "--type" ] && { TASK_TYPE=$2; shift 2; continue; }
    [ "$1" == "--year" ] && { TASK_YEAR=$2; shift 2; continue; }
    [ "$1" == "--events" ] && { N_EVENTS=$2; shift 2; continue; }
    [ "$1" == "--freq" ] && { FREQ=$2; shift 2; continue; }
    [ "$1" == "--dataset" ] && { DATASET=$2; shift 2; continue; }
    { [ "$1" == "-in" ] || [ "$1" == "--input" ]; } && { IN_FILE_DIR=$2; shift 2; continue; }
    { [ "$1" == "-out" ] || [ "$1" == "--output" ]; } && { OUT_TREES_DIR=$2; shift 2; continue; }
    [ "$1" == "--friends-only" ] && { FRIENDS_ONLY=true; shift; continue; }
    [ "$1" == "--skip-jetCorrs" ] && { SKIP_JETCORRS=true; shift; continue; }
    [ "$1" == "--debug" ] && { set -x; shift; continue; }
    [ "$1" == "--force-rm" ] && { FORCE_RM_DIRS=true; shift; continue; }
    echo "Unsupported argument $1."
    exit 1
done

## define undefined arguments
{ [ -z "$TASK_NAME" ] || [ -z "$TASK_TYPE" ] || [ -z "$TASK_YEAR" ] \
    || [ -z "$IN_FILE_DIR" ] || [ -z "$OUT_TREES_DIR" ]; } && {
    echo "Arguments 'task', 'type', 'year', 'input' & 'output' are necessary."
    exit 1
}
[ -z "$FRIENDS_ONLY" ] && FRIENDS_ONLY=false
[ -z "$SKIP_JETCORRS" ] && SKIP_JETCORRS=false
[ -z "$FORCE_RM_DIRS" ] && FORCE_RM_DIRS=false
[ -z "$N_EVENTS" ] && N_EVENTS=500000
[ -z "$FREQ" ] && FREQ=10m
{ [ -z $DATASET ] && [ "$TASK_TYPE" == "data" ]; } && DATASET="'.*Run.*'"
{ [ -z $DATASET ] && [ "$TASK_TYPE" == "mc" ]; } && DATASET="'^(?!.*Run).*'"
{ [ -z $PY_CFG ] && ! $FRIENDS_ONLY; } && {
    echo "Either a Python cfg file is required or the Friends Only mode must be specified."
    exit 1
}
{ ! [ -z $PY_CFG ] && $FRIENDS_ONLY; } && {
    echo "The Friends Only mode has been selected but a Python cfg has been given as input. The PyCfg is not required for this mode. Aborting.."
    exit 1
}

## setup environment
OUT_PATH=$OUT_TREES_DIR/$TASK_YEAR/$TASK_NAME-$(date | awk '{print $3$2$6}')
SPACE_CLEANER=$CMSSW_DIR/CMGTools/TTHAnalysis/scripts/spaceCleaner-v2.dog
PY_FTREES_CMD=$CMSSW_DIR/CMGTools/TTHAnalysis/macros/prepareEventVariablesFriendTree.py
FRIENDS_DIR=friends

## clean existing working paths if the user allows
if $FORCE_RM_DIRS; then
    echo "The flag --force-rm has been issued."
    printf "Removing $OUT_PATH ..."
    checkRmPath $OUT_PATH true && echo "Done"
    printf "Removing $CMSSW_DIR/$TASK_NAME ..."
    checkRmPath $CMSSW_DIR/$TASK_NAME true && echo "Done"
else
    checkRmPath $OUT_PATH false && echo "Removed"
    [ -d $CMSSW_DIR/$TASK_NAME ] && {
	echo "[ WARNING ]"
	echo "The directory $CMSSW_DIR/$TASK_NAME exists and MUST be deleted otherwise the counted log-files will be more that the jobs running."
	echo "Alternatively, select a different 'task-name'."
	ans=''; while ! [[ $ans =~ [yn] ]]; do printf "Proceed? [y/n]"; read ans; done
	[ "$ans" == "y" ] && \
	    { checkRmPath $CMSSW_DIR/$TASK_NAME true && echo "Removed"; } || \
	    { echo "Exiting.."; exit 0; }
    }
fi

## setup the required directories
OUT_PATH_POSTPROC=$OUT_PATH/postprocessor_chunks ## remote directories
OUT_PATH_FRIENDS=$OUT_PATH/friends_hadd
OUT_PATH_JETMET=$OUT_PATH/jetmetUncertainties_hadd
mkdir $OUT_PATH_POSTPROC -p
mkdir $OUT_PATH_FRIENDS
mkdir $OUT_PATH_JETMET
mkdir $CMSSW_DIR/$TASK_NAME ## local directories
cd $CMSSW_DIR/$TASK_NAME && echo "$PWD"
ln -s ../CMGTools/TTHAnalysis/macros/lxbatch_runner.sh lxbatch_runner.sh
AFS_DIR_POSTPROC_CHUNKS=postprocessor_chunks
AFS_DIR_JETMET_CHUNKS=jetmetUncertainties_chunks
AFS_DIR_FRIENDS_CHUNKS=friends_chunks

## the postprocessor block won't run in case of the Friends Only mode
if ! $FRIENDS_ONLY; then

    ## check the input and prepate the command
    ! [ -f $IN_FILE_DIR ] && { echo "Input must be a file in the Full Production mode."; exit 2; }
    PY_CFG=$IN_FILE_DIR
    POSTPROC_CMD="nanopy_batch.py -o $TASK_NAME $PY_CFG --option year=$TASK_YEAR -B -b 'run_condor_simple.sh -t 1200 ./batchScript.sh'"

    ## step1 condor submit the nanoAOD postprocessor
    eval $POSTPROC_CMD || { echo "nanopy_batch failed, returned $?";  exit 1; }
    printf "Submimtted tasks for $TASK_YEAR from $PY_CFG\nnanopy_batch returned $?\n"

    ## wait until the batch jobs finish (CMD: 'watchdog <in-dir> <out-dir> <freq>')
    $SPACE_CLEANER $AFS_DIR_POSTPROC_CHUNKS $OUT_PATH_POSTPROC $FREQ > spaceCleaner.log

    ## hadd the nanoAOD chuncks
    # haddProcesses $AFS_DIR_POSTPROC_CHUNKS $OUT_PATH_POSTPROC/_hadd || {
    # 	echo "haddProcess on the chunks in $OUT_PATH_POSTPROC/_hadd failed"
    # 	exit 1
    # }
    ## probably this block will be overwritten by the block above
    JOBS=$(ls $AFS_DIR_POSTPROC_CHUNKS/*.log | wc | awk '{print $1}')
    FINISHED_JOBS=$(grep "return value 0" $AFS_DIR_POSTPROC_CHUNKS/*.log | wc | awk '{print $1}')
    if (( $FINISHED_JOBS == $JOBS )); then ## if the jobs finished for each process hadd the chunks
    	for process in $(ls $OUT_PATH_POSTPROC | sed 's/_Chunk.*$//' | sort -u); do
	    CHUNKS_COUNTED=$(ls $OUT_PATH_POSTPROC | grep $process | wc | awk '{print $1}')
	    ## if the process was split into 1 chunk, skip it
	    (( $CHUNKS_COUNTED < 2 )) && continue
	    ## else hadd the chunks
    	    hadd -ff $OUT_PATH_POSTPROC/$process.root $(ls $OUT_PATH_POSTPROC | grep $process)
    	done
    else
	printf "Finished jobs are not equal to the jobs ran.\nJOBS = $JOBS\nFINISHED_JOBS = $FINISHED_JOBS\n"
	exit 1
    fi

    ## redirecting the input to be the directory which is expected below
    IN_FILE_DIR=$OUT_PATH_POSTPROC
fi

## prepare the friend tree commands
DATA_CMD="python $PY_FTREES_CMD -t NanoAOD $IN_FILE_DIR $AFS_DIR_FRIENDS_CHUNKS -D $DATASET -I CMGTools.TTHAnalysis.tools.nanoAOD.susySOS_modules recleaner_step1,recleaner_step2_data,tightLepCR_seq -N $N_EVENTS -q condor --maxruntime 240 --batch-name $TASK_NAME | tee last-submit-info"
JETMET_CMD="python $PY_FTREES_CMD -t NanoAOD $IN_FILE_DIR $AFS_DIR_JETMET_CHUNKS -D $DATASET -I CMGTools.TTHAnalysis.tools.nanoAOD.susySOS_modules jetmetUncertainties$TASK_YEAR -N $N_EVENTS -q condor --maxruntime 240 --batch-name $TASK_NAME-jetcorrs | tee last-submit-info"
MC_CMD="python $PY_FTREES_CMD -t NanoAOD $IN_FILE_DIR $AFS_DIR_FRIENDS_CHUNKS -D $DATASET -F $OUT_PATH_JETMET/{cname}_Friend.root Friends -I CMGTools.TTHAnalysis.tools.nanoAOD.susySOS_modules recleaner_step1,recleaner_step2_mc,mcMatch_seq,tightLepCR_seq -N $N_EVENTS -q condor --maxruntime 240 --batch-name $TASK_NAME | tee last-submit-info"

## be sure that the input file is a directory
! [ -d $IN_FILE_DIR ] && {
    echo "Input must be a directory in the Friends Only mode."
    exit 2
}

## run the friend tree modules
if [ $TASK_TYPE == "data" ]; then
    eval $DATA_CMD
    CLUSTER=$(grep -o "cluster [0-9]\+" last-submit-info | sed 's/[^0-9]*//')
    wait_friendsModule $AFS_DIR_FRIENDS_CHUNKS $FREQ "$DATA_CMD" $CLUSTER && \
	haddProcesses $AFS_DIR_FRIENDS_CHUNKS $OUT_PATH_FRIENDS || \
	exit 1
elif [ $TASK_TYPE == "mc" ]; then
    ! $SKIP_JETCORRS && {
	eval $JETMET_CMD
	CLUSTER=$(grep -o "cluster [0-9]\+" last-submit-info | sed 's/[^0-9]*//')
	wait_friendsModule $AFS_DIR_JETMET_CHUNKS $FREQ "$JETMET_CMD" $CLUSTER && \
	    haddProcesses $AFS_DIR_JETMET_CHUNKS $OUT_PATH_JETMET || \
	    exit 1
    }
    echo "Files ($(ls $OUT_PATH_JETMET | wc | awk '{print $1}')) in the directory $OUT_PATH_JETMET:"
    ls $OUT_PATH_JETMET
    ## now run the step1 and mc step 2
    eval $MC_CMD
    CLUSTER=$(grep -o "cluster [0-9]\+" last-submit-info | sed 's/[^0-9]*//')
    wait_friendsModule $AFS_DIR_FRIENDS_CHUNKS $FREQ "$MC_CMD" $CLUSTER && \
	haddProcesses $AFS_DIR_FRIENDS_CHUNKS $OUT_PATH_FRIENDS || \
	exit 1
else
    echo "TASK_TYPE is neither 'data' nor 'mc'"
    exit 1
fi

cd -
echo "Done"
exit 0
