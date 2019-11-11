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
    [ "$1" == "--skip-friends" ] && { SKIP_FRIENDS=true; shift; continue; }
    [ "$1" == "--skip-btagFriends" ] && { SKIP_BTAG_FRIENDS=true; shift; continue; }
    [ "$1" == "--skip-friends-all" ] && { SKIP_ALL_FRIENDS=true; shift; continue; }
    [ "$1" == "--debug" ] && { set -x; shift; continue; }
    [ "$1" == "--force-rm" ] && { FORCE_RM_DIRS=true; shift; continue; }
    [ "$1" == "--print-cmds" ] && { JUST_PRINT_CMDS=true; shift; continue; }
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
[ -z "$SKIP_FRIENDS" ] && SKIP_FRIENDS=false
[ -z "$SKIP_BTAG_FRIENDS" ] && SKIP_BTAG_FRIENDS=false
[ -z "$SKIP_ALL_FRIENDS" ] && SKIP_ALL_FRIENDS=false
[ -z "$JUST_PRINT_CMDS" ] && JUST_PRINT_CMDS=false
[ -z "$FORCE_RM_DIRS" ] && FORCE_RM_DIRS=false
[ -z "$N_EVENTS" ] && N_EVENTS=500000
[ -z "$FREQ" ] && FREQ=10m
{ [ -z $DATASET ] && [ "$TASK_TYPE" == "data" ]; } && DATASET="'.*Run.*'"
{ [ -z $DATASET ] && [ "$TASK_TYPE" == "mc" ]; } && DATASET="'^(?!.*Run).*'"
{ [ -z $IN_FILE_DIR ] && ! $FRIENDS_ONLY; } && {
    echo "Either a Python cfg file is required or the Friends Only mode must be specified."
    exit 1
}
# { ! [ -z $IN_FILE_DIR ] && $FRIENDS_ONLY; } && {
#     echo "The Friends Only mode has been selected but a Python cfg has been given as input. The PyCfg is not required for this mode. Aborting.."
#     exit 1
# }

## setup environment
OUT_PATH=$OUT_TREES_DIR/$TASK_YEAR/$TASK_NAME-$(date | awk '{print $3$2$6}')
SPACE_CLEANER=$CMSSW_DIR/CMGTools/TTHAnalysis/scripts/spaceCleaner.dog
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
OUT_PATH_TREES=$OUT_PATH/trees_hadd
OUT_PATH_FRIENDS=$OUT_PATH/friends_hadd
OUT_PATH_JETMET=$OUT_PATH/jetmetUncertainties_hadd
OUT_PATH_BTAGWEIGHT=$OUT_PATH/btagWeight_hadd
if ! $JUST_PRINT_CMDS; then
    { $FORCE_RM_DIRS && [ -d $OUT_PATH_POSTPROC ]; } && rm -rf $OUT_PATH_POSTPROC
    mkdir $OUT_PATH_TREES -p
    mkdir $OUT_PATH_FRIENDS
    mkdir $OUT_PATH_JETMET
    mkdir $OUT_PATH_BTAGWEIGHT
    mkdir $CMSSW_DIR/$TASK_NAME ## local directories
fi
AFS_DIR_POSTPROC_CHUNKS=postprocessor_chunks
AFS_DIR_JETMET_CHUNKS=jetmetUncertainties_chunks
AFS_DIR_FRIENDS_CHUNKS=friends_chunks
AFS_DIR_BTAGWEIGHT_CHUNKS=btagWeight_chunks


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## the postprocessor block won't run in case of the Friends Only mode
if ! $FRIENDS_ONLY; then
    ## go to the initial directory
    cd $CMSSW_DIR/$TASK_NAME && echo $PWD

    ## check the input and prepare the command
    ! [ -f $IN_FILE_DIR ] && { echo "Input must be a file in the Full Production mode."; exit 2; }
    PY_CFG=$IN_FILE_DIR
    ## prepare the post-proc command
    [[ $OUT_PATH_POSTPROC =~ ^/eos ]] && { ## transform mounted path to eos url
	EOS_PATH_MOUNTED=$OUT_PATH_POSTPROC
	OUT_PATH_POSTPROC=$(echo $OUT_PATH_POSTPROC | sed "s@/eos@$EOS_MGM_URL//eos@")
	echo "OUT_PATH_POSTPROC directory has changed value to $OUT_PATH_POSTPROC"
    }
    POSTPROC_CMD="nanopy_batch.py -r $OUT_PATH_POSTPROC -o $AFS_DIR_POSTPROC_CHUNKS $PY_CFG --option year=$TASK_YEAR -B -b 'run_condor_simple.sh -t 1200 ./batchScript.sh' --option=selectComponents=$DATASET > nanopy_batch.log"
    echo "Main Tree Procuction, will run the command:"
    echo $POSTPROC_CMD

    if ! $JUST_PRINT_CMDS; then
	## step1 condor submit the nanoAOD postprocessor
	eval $POSTPROC_CMD || { echo "nanopy_batch failed, returned $?";  exit 1; }
	printf "Submimtted tasks for $TASK_YEAR from $PY_CFG\nnanopy_batch returned $?\n"

	## put the running processes in an array
	cd $AFS_DIR_POSTPROC_CHUNKS && echo $PWD
	RUNNING_TASKS=($(ls *_Chunk* -d | sed -r "s/_Chunk[0-9]+//" | sort -u))

	## wait for the condor tasks to finish
	FINISHED=false
	while ! $FINISHED; do
	    echo "$(date) | running tasks (${RUNNING_TASKS[@]})"
	    sleep $FREQ
	    for i in ${!RUNNING_TASKS[@]}; do
		## remove the task from the running tasks if grep can't find it in the condor_q's output
		condor_q | grep ${RUNNING_TASKS[$i]} || unset RUNNING_TASKS[$i]
	    done
	    [ "${#RUNNING_TASKS[@]}" == "0" ] && { ## if all running tasks finished
		## check chunks' integrity
		cmgListChunksToResub -t NanoAODurl -q "HTCondor -t 72000" ./ > corruptedChunks
		if [ ! -s corruptedChunks ]; then ## if corruptedChunks file is empty
		    FINISHED=true ## fix the FINISHED BOOL; else
		else
		    echo "Will resubmit failed chunks.."
		    eval `cat corruptedChunks | grep -v ^#` ## run the resub cmds
		    RUNNING_TASKS=($(cat corruptedChunks | grep -v ^# | sed -r "s@.*/([^/]*)\$@\1@")) ## update the running processes
		    rm corruptedChunks ## delete the file
		fi
	    }
	done

	## copy the output to eos
	cp -a * $OUT_PATH_TREES/.

	## hadd chunks
	cd $OUT_PATH_TREES
	$CMSSW_BASE/src/CMGTools/TTHAnalysis/scripts/urlToBashLink.sh make ./ ## generate links from the urls
	haddChunks.py -n -c .

	## move 1-chunk trees into the chunks and link their root files
	echo "Moving 1-chunk trees into Chunks/ and linking their files"
	for dir in $(ls -d */ | grep -v Chunks); do
	    echo "----> $dir"; 
	    file=`cat $dir*url | sed -r "s@root://eosuser.cern.ch[/]+(.*)@/\1@"`
	    mv $dir Chunks/.
	    ln -rs $file ./
	done

    fi ## if not just-print

    ## redirecting the input to be the directory which is expected below
    [[ $OUT_PATH_POSTPROC =~ ^.*://.*//eos.* ]] && {
	OUT_PATH_POSTPROC=$EOS_PATH_MOUNTED
	echo "OUT_PATH_POSTPROC directory has changed value to $EOS_PATH_MOUNTED"
    }
    IN_FILE_DIR=$OUT_PATH_TREES
fi ## if not friends-only


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## run the friend tree modules
if ! $SKIP_ALL_FRIENDS; then
    ## go to the initial directory
    cd $CMSSW_DIR/$TASK_NAME && echo $PWD
    ln -s ../CMGTools/TTHAnalysis/macros/lxbatch_runner.sh lxbatch_runner.sh

    ## prepare the friend tree commands
    DATA_CMD="python $PY_FTREES_CMD -t NanoAOD $IN_FILE_DIR $AFS_DIR_FRIENDS_CHUNKS -D $DATASET -I CMGTools.TTHAnalysis.tools.nanoAOD.susySOS_modules recleaner_step1,recleaner_step2_data,isTightLepDY,isTightLepTT,isTightLepVV,isTightLepWZ -N $N_EVENTS -q condor --maxruntime 240 --batch-name $TASK_NAME | tee last-submit-info"
    JETMET_CMD="python $PY_FTREES_CMD -t NanoAOD $IN_FILE_DIR $AFS_DIR_JETMET_CHUNKS -D $DATASET -I CMGTools.TTHAnalysis.tools.nanoAOD.susySOS_modules jetmetUncertainties$TASK_YEAR -N $N_EVENTS -q condor --maxruntime 240 --batch-name $TASK_NAME-jetcorrs | tee last-submit-info"
    MC_CMD="python $PY_FTREES_CMD -t NanoAOD $IN_FILE_DIR $AFS_DIR_FRIENDS_CHUNKS -D $DATASET -F $OUT_PATH_JETMET/{cname}_Friend.root Friends -I CMGTools.TTHAnalysis.tools.nanoAOD.susySOS_modules recleaner_step1,recleaner_step2_mc,isTightLepDY,isTightLepTT,isTightLepVV,isTightLepWZ,mcMatchId,mcPromptGamma -N $N_EVENTS -q condor --maxruntime 240 --batch-name $TASK_NAME-recl | tee last-submit-info"
    BTAGWEIGHT_CMD="python $PY_FTREES_CMD -t NanoAOD $IN_FILE_DIR $AFS_DIR_BTAGWEIGHT_CHUNKS -D $DATASET -F $OUT_PATH_JETMET/{cname}_Friend.root Friends -F $OUT_PATH_FRIENDS/{cname}_Friend.root Friends -I CMGTools.TTHAnalysis.tools.nanoAOD.susySOS_modules eventBTagWeight_$(echo $TASK_YEAR | sed s/20//) -N $N_EVENTS -q condor --maxruntime 240 --batch-name $TASK_NAME-btag | tee last-submit-info"

    echo "Friend Tree Production, will run the command:"
    [ $TASK_TYPE == "data" ] && echo $DATA_CMD
    [ $TASK_TYPE == "mc" ] && { echo $JETMET_CMD; echo $MC_CMD; echo $BTAGWEIGHT_CMD; }

    if ! $JUST_PRINT_CMDS; then
	## be sure that the input file is a directory
	! [ -d $IN_FILE_DIR ] && {
	    echo "Input must be a directory in the Friends Only mode."
	    exit 2
	}

	## run the friend modules
	if [ $TASK_TYPE == "data" ]; then
	    eval $DATA_CMD
	    CLUSTER=$(grep -o "cluster [0-9]\+" last-submit-info | sed 's/[^0-9]*//')
	    wait_friendsModule $AFS_DIR_FRIENDS_CHUNKS $FREQ "$DATA_CMD" $CLUSTER && \
		haddProcesses $AFS_DIR_FRIENDS_CHUNKS $OUT_PATH_FRIENDS || \
		exit 1
	elif [ $TASK_TYPE == "mc" ]; then
	    ## run the friends' producer for calculating the jet met corrections
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
	    ! $SKIP_FRIENDS && {
		eval $MC_CMD
		CLUSTER=$(grep -o "cluster [0-9]\+" last-submit-info | sed 's/[^0-9]*//')
		wait_friendsModule $AFS_DIR_FRIENDS_CHUNKS $FREQ "$MC_CMD" $CLUSTER && \
		    haddProcesses $AFS_DIR_FRIENDS_CHUNKS $OUT_PATH_FRIENDS || \
		    exit 1
	    }
	    echo "Files ($(ls $OUT_PATH_FRIENDS | wc | awk '{print $1}')) in the directory $OUT_PATH_FRIENDS:"
	    ls $OUT_PATH_FRIENDS
	    ## now run the producer for the btag weights
	    ! $SKIP_BTAG_FRIENDS && {
		eval $BTAGWEIGHT_CMD
		CLUSTER=$(grep -o "cluster [0-9]\+" last-submit-info | sed 's/[^0-9]*//')
		wait_friendsModule $AFS_DIR_BTAGWEIGHT_CHUNKS $FREQ "$MC_CMD" $CLUSTER && \
		    haddProcesses $AFS_DIR_BTAGWEIGHT_CHUNKS $OUT_PATH_BTAGWEIGHT || \
		    exit 1
	    }
	    echo "Files ($(ls $OUT_PATH_BTAGWEIGHT | wc | awk '{print $1}')) in the directory $OUT_PATH_BTAGWEIGHT:"
	    ls $OUT_PATH_BTAGWEIGHT
	else
	    echo "TASK_TYPE is neither 'data' nor 'mc'"
	    exit 1
	fi

    else
	exit 0
    fi ## if not just-print
fi ## if not skip-friends

cd -
echo "Done"
exit 0
