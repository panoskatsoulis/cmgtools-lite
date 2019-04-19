#!/bin/bash

function do_help() {
    printf "
Usage: $(basename $0) --output-trees <path> --process <proc>
Options:
   --output-trees <path> : output path with the chuncks of the process <proc>.
   --output <path>       : path to store the merged treefor the process <proc>.
   --process <proc>      : the physical process for which this script will run.
   --dry-run             : print the commands instead of running them.
   --skip-links          : do not create links in the ChunksCMGKnownFormat path, already exist in there.
   --skip-addChunks      : do not run ADD_CHUNK command, chunks already merged in the --output dir
   --skip-makeFriends    : do not run MAKE_FRIENDS commands, friends already exist in --output/0_both3dlooseClean_v2 dir
"
    exit 0
}

while [ ! -z $1 ]; do
    { [ "$1" == "--help" ] || [ "$1" == "-h" ]; } && do_help
    [ "$1" == "--output-trees" ] && { OUTPUT_TREES_PATH=$2; shift 2; continue; }
    [ "$1" == "--output" ] && { OUTPUT_PATH=$2; shift 2; continue; }
    [ "$1" == "--process" ] && { PROCESS=$2; shift 2; continue; }
    [ "$1" == "--dry-run" ] && { DRY_RUN=true; shift 1; continue; }
    [ "$1" == "--skip-links" ] && { SKIP_LINKS=true; shift 1; continue; }
    [ "$1" == "--skip-addChunks" ] && { SKIP_ADD_CHUNKS=true; shift 1; continue; }
    [ "$1" == "--skip-makeFriends" ] && { SKIP_MAKE_FRIENDS=true; shift 1; continue; }
    echo "Unsupported command line argument $1"
    exit 1
done
[ -z $OUTPUT_TREES_PATH ] && { echo "Trees' location has not been given."; exit 1; }
[ -z $OUTPUT_PATH ] && { echo "Output location for the merged tree has not been given."; exit 1; }
[ -z $PROCESS ] && { echo "Process has not been given."; exit 1; }
[ -z $DRY_RUN ] && DRY_RUN=false
[ -z $SKIP_LINKS ] && SKIP_LINKS=false
[ -z $SKIP_ ] && SKIP_=false
[ -z $SKIP_MAKE_FRIENDS ] && SKIP_MAKE_FRIENDS=false
INITIAL_PATH=$PWD


## Make the Chunks to be in the CMG known format first
cd $OUTPUT_TREES_PATH && {
    [ ! -d ChunksCMGKnownFormat ] && mkdir ChunksCMGKnownFormat;
}
LINKED_TREES_PATH=ChunksCMGKnownFormat
if ! $SKIP_LINKS; then
    for dir in $(ls ${PROCESS}_Chunk* -d); do

	echo $dir | grep -vE 'Chunk.*_[0-9]*-[0-9]*$' && { continue; }

	new_name=$(echo $dir | sed -r 's@^(.*Chunk.*)_[0-9]*-[0-9]*$@\1@')
	#echo $new_name

	{ [ ! -e $LINKED_TREES_PATH/$new_name ] && ln -sr $dir $LINKED_TREES_PATH/$new_name; } || {
	    while [ -e $LINKED_TREES_PATH/$new_name ]; do
		num=$(echo $new_name | sed -r 's/.*Chunk([0-9]+)/\1/')
		new_name="$(echo $new_name | sed -r 's/(.*Chunk)[0-9]+/\1/')$(($num+1))"
	    done
            echo "---> $new_name"
	    ln -rs $dir $LINKED_TREES_PATH/$new_name
	}
    done
else
    [ ! -d ChunksCMGKnownFormat ] && {
	cd -
	echo "The path ChunksCMGKnownFormat doesn't exist. In there is expected to find the chunks with a known naming scheme."
	exit 13
    }
fi

ls -Altr $LINKED_TREES_PATH && printf "Continue to hadd the chunks? [y/n]" && read ans
if [ "$ans" == 'y' ]; then
    echo "Checking env and will try to run commands to hadd chunks, make friend trees and merge the friend tree chunks."
elif [ "$ans" == 'n' ]; then
    echo "Exiting.."
    exit 11
else
    echo "Unknown answer $ans, Exiting.."
    exit 12
fi


## Check env, build commands and run
[ -z $CMSSW_VERSION ] && { echo "Run cmsenv and rerun the script."; exit 2; }

[ ! -d $OUTPUT_PATH ] && mkdir -p $OUTPUT_PATH
printf "Going to "; cd $OUTPUT_PATH && echo $PWD
ADD_CHUNKS="haddChunks.py $OUTPUT_TREES_PATH/$LINKED_TREES_PATH"
! $SKIP_ADD_CHUNKS && {
    { ! $DRY_RUN && {
	    printf "\e[0;33mADD CHUNKS COMMAND|\e[0m Executing on $(date)\n";
	    $ADD_CHUNKS > $INITIAL_PATH/addChunks.log 2>&1 || { echo "haddChunks returned $?."; exit 3; };
	    echo "haddChunks returned $?.";
	    [ -e $OUTPUT_TREES_PATH/$LINKED_TREES_PATH/$PROCESS ] \
		&& mv $OUTPUT_TREES_PATH/$LINKED_TREES_PATH/$PROCESS .
	};
    } || printf "\e[0;33mADD CHUNKS COMMAND|\e[0m $ADD_CHUNKS\n"
}

printf "Going to "; cd $CMSSW_BASE/src/CMGTools/TTHAnalysis/macros && echo $PWD
MAKE_FRIENDS="python prepareEventVariablesFriendTree.py --tra2 --tree treeProducerSusyMultilepton -I CMGTools.TTHAnalysis.tools.susySosReCleaner -m both3dloose -m ipjets -N 100000 ${OUTPUT_PATH}/ ${OUTPUT_PATH}/0_both3dlooseClean_v2/"
! $SKIP_MAKE_FRIENDS && {
    { ! $DRY_RUN && {
	    printf "\e[0;33mMAKE FRIENDS COMMAND|\e[0m Executing on $(date)\n";
	    $MAKE_FRIENDS > $INITIAL_PATH/makeFriends.log 2>&1 || { echo "prepareEventVariablesFriendTree.py returned $?."; exit 3; };
	    echo "prepareEventVariablesFriendTree.py returned $?.";
	};
    } || printf "\e[0;33mMAKE FRIENDS COMMAND|\e[0m $MAKE_FRIENDS\n"
}

printf "Going to "; cd $OUTPUT_PATH && echo $PWD
if ! $DRY_RUN; then
    FRIEND_CHUNKS_LIST=$(ls 0_both3dlooseClean_v2/evVarFriend_${PROCESS}.chunk*.root)
    ADD_FRIEND_CHUNKS="hadd evVarFriend_${PROCESS}.root ${FRIEND_CHUNKS_LIST}"
    printf "\e[0;33mMAKE FRIENDS COMMAND|\e[0m Executing on $(date)\n"
    $ADD_FRIEND_CHUNKS > $INITIAL_PATH/addFriendChunks.log 2>&1 || { echo "hadd returned $?."; exit 3; };
    echo "hadd returned $?."
else
    printf "\e[0;33mADD FRIEND CHUNKS COMMAND|\e[0m hadd evVarFriend_${PROCESS}.root FRIEND_CHUNKS_LIST\n"
    echo ">> FRIEND_CHUNKS_LIST=\$(ls 0_both3dlooseClean_v2/evVarFriend_${PROCESS}.chunk*.root)"
fi

[ $PWD != $INITIAL_PATH ] && cd $INITIAL_PATH
exit 0
