#!/bin/bash

function do_help() {
    printf "
Usage: $(basename $0) --output-trees <path> --process <proc>
Options:
   --output-trees <path> : output path with the chuncks of the process <proc>.
   --process <proc>      : the physical process for which this script will run.
   --dry-run             : print the commands instead of running them

"
    exit 0
}

while [ ! -z $1 ]; do
    { [ "$1" == "--help" ] || [ "$1" == "-h" ]; } && do_help
    [ "$1" == "--output-trees" ] && { OUTPUT_TREES_PATH=$2; shift 2; continue; }
    [ "$1" == "--process" ] && { PROCESS=$2; shift 2; continue; }
    [ "$1" == "--dry-run" ] && { DRY_RUN=true; shift 1; continue; }
    echo "Unsupported command line argument $1"
    exit 1
done
[ -z $OUTPUT_TREES_PATH ] && { echo "Trees' location has not been given."; exit 1; }
[ -z $PROCESS ] && { echo "Process has not been given."; exit 1; }
[ -z $DRY_RUN ] && DRY_RUN=false

## Check env and build commands and run
[ -z $CMSSW_VERSION ] && { echo "Run cmsenv and rerun the script."; exit 2; }

ADD_CHUNKS="haddChunks.py $OUTPUT_TREES_PATH --clean"
{ ! $DRY_RUN && {
	$ADD_CHUNKS || { echo "haddChunks returned $?."; exit 3; };
    };
} || printf "\e[0;33mADD CHUNKS COMMAND|\e[0m $ADD_CHUNKS\n"

INITIAL_PATH=$PWD && cd $CMSSW_BASE/src/CMGTools/TTHAnalysis/macros
MAKE_FRIENDS="python prepareEventVariablesFriendTree.py --tra2 --tree treeProducerSusyMultilepton -I CMGTools.TTHAnalysis.tools.susySosReCleaner -m both3dloose -m ipjets -N 100000 ${OUTPUT_TREES_PATH}/ ${OUTPUT_TREES_PATH}/0_both3dlooseClean_v2/"
{ ! $DRY_RUN && {
	$MAKE_FRIENDS || { echo "prepareEventVariablesFriendTree.py returned $?."; exit 3; };
    };
} || printf "\e[0;33mMAKE FRIENDS COMMAND|\e[0m $MAKE_FRIENDS\n"

if ! $DRY_RUN; then
    FRIEND_CHUNKS_LIST=$(ls ${OUTPUT_TREES_PATH}/0_both3dlooseClean_v2/evVarFriend_${PROCESS}_Chunk*.root)
    ADD_FRIEND_CHUNKS="hadd evVarFriend_${PROCESS}.root ${FRIEND_CHUNKS_LIST}"
    $ADD_FRIEND_CHUNKS || { echo "hadd returned $?."; exit 3; };
else
    printf "\e[0;33mADD FRIEND CHUNKS COMMAND|\e[0m hadd evVarFriend_${PROCESS}.root FRIEND_CHUNKS_LIST\n"
    echo ">> FRIEND_CHUNKS_LIST=\$(ls ${OUTPUT_TREES_PATH}/0_both3dlooseClean_v2/evVarFriend_${PROCESS}_Chunk*.root)"
fi

[ $PWD != $INITIAL_PATH ] && cd $INITIAL_PATH
exit 0
