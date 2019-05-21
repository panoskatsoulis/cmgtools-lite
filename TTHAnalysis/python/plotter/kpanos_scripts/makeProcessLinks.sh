#!/bin/bash

function dohelp() {
    echo "Usage $(basename $0) --process <process> --dir <trees-dir>"
    echo "   --help, -h : Print this and exit."
    echo "   --process  : Specify the process for which link will be created."
    echo "   --trees    : Define differently than the default the original SOS trees' path."
    echo "   --remotes  : Define differently that the default the original SOS remote path."
    echo "   --ftrees   : Change the directory for f-trees (default 0_both3dlooseClean_v2)"
    echo "   --fmctrees : Change the directory for fmc-trees (default 0_eventBTagWeight_v2)"
    echo "   --ftrees   : Change the directory for r-trees (default fake_remote_path)"
    echo "   --dir      : Directory to put the soft links."
    echo "   --debug    : Enable debugging print out."
    exit 0
}

## Initialization of parameters
while [ ! -z "$1" ]; do
    { [ "$1" == "--help" ] || [ "$1" == "-h" ]; } && dohelp
    [ "$1" == "--process" ] && { PROCESS=$2; shift 2; continue; }
    [ "$1" == "--trees" ] && { TREE_PATH=$2; shift 2; continue; }
    [ "$1" == "--remotes" ] && { REMOTE_PATH=$2; shift 2; continue; }
    [ "$1" == "--ftrees" ] && { FTREES_1=$2; shift 2; continue; }
    [ "$1" == "--fmctrees" ] && { FTREES_2=$2; shift 2; continue; }
    [ "$1" == "--rtrees" ] && { RTREES=$2; shift 2; continue; }
    [ "$1" == "--dir" ] && { OUTPUT_DIR=$2; shift 2; continue; }
    [ "$1" == "--debug" ] && { DEBUG=true; shift; continue; }
    echo "Unsupported argument, $1" && exit 101
done
{ [ -z $PROCESS ] || [ -z $OUTPUT_DIR ]; } && {
    echo "Specify process to link (--process) and output directory (--dir).";
    exit 1;
}
[ -z $DEBUG ] && DEBUG=false
[ -z $TREE_PATH ] && \
    TREES_PATH=/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217
[ -z $REMOTE_PATH ] && \
    REMOTE_PATH=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217
[ -z $FTREES_1 ] && \
    FTREES_1=$TREES_PATH/0_both3dlooseClean_v2
[ -z $FTREES_2 ] && \
    FTREES_2=$TREES_PATH/0_eventBTagWeight_v2
[ -z $RTREES ] && \
    RTREES=fake_remote_path
INITIAL_PATH=$(pwd)

$DEBUG && {
    echo "--process = $PROCESS"
    echo "--dir = $OUTPUT_DIR"
    echo "--trees = $TREE_PATH"
    echo "--remotes = $REMOTE_PATH"
    echo "--ftrees = $FTREES_1"
    echo "--fmctrees = $FTREES_2"
    echo "--rtrees = $RTREES"
}

## Linking trees
cd ${OUTPUT_DIR}
for tree in $(ls ${TREES_PATH} | grep ${PROCESS});
do
    echo "Linking the tree: ${tree}";
    $DEBUG && { pwd; echo "ln -s ${TREES_PATH}/${tree} ${tree};"; }
    ln -s ${TREES_PATH}/${tree} ${tree};
done

## Linking friend trees
[ ! -d $(basename $FTREES_1) ] && \
    mkdir -p ${FTREES_1}
cd $(basename $FTREES_1)
for ftree in $(ls ${FTREES_1} | grep ${PROCESS});
do
    echo "Linking the friend tree: $ftree";
    $DEBUG && { pwd; echo "ln -s ${FTREES_1}/${ftree} ${ftree}"; }
    ln -s ${FTREES_1}/${ftree} ${ftree}
done
cd - > /dev/null

## Linking friend trees
[ ! -d $(basename $FTREES_2) ] && \
    mkdir -p ${FTREES_2}
cd $(basename $FTREES_2)
for ftree in $(ls ${FTREES_2} | grep ${PROCESS});
do
    echo "Linking the friend tree: $ftree";
    $DEBUG && { pwd; echo "ln -s ${FTREES_2}/${ftree} ${ftree}"; }
    ln -s ${FTREES_2}/${ftree} ${ftree}
done
cd - > /dev/null

## Linking remote trees
[ ! -d ${OUTPUT_DIR}/${RTREES} ] && \
    mkdir -p ${RTREES}
cd $(basename $RTREES)
for rtree in $(ls ${REMOTE_PATH} | grep ${PROCESS});
do
    echo "Linking the remote tree: $rtree";
    $DEBUG && { pwd; echo "ln -s ${REMOTE_PATH}/${rtree} ${rtree}"; }
    ln -s ${REMOTE_PATH}/${rtree} ${rtree}
done
cd - > /dev/null

cd $INITIAL_PATH
exit 0
