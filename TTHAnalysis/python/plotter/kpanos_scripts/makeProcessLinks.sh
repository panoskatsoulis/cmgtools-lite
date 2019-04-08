#!/bin/bash

function dohelp() {
    echo "Usage $(basename $0) --process <process> --dir <trees-dir>"
    echo "   --help, -h : Print this and exit."
    echo "   --process  : Specify the process for which link will be created."
    echo "   --trees    : Define differently than the default the original SOS trees' path."
    echo "   --dir      : Directory to put the soft links."
    exit 0
}

## Initialization of parameters
while [ ! -z "$1" ]; do
    { [ "$1" == "--help" ] || [ "$1" == "-h" ]; } && dohelp
    [ "$1" == "--process" ] && { PROCESS=$2; shift 2; continue; }
    [ "$1" == "--trees" ] && { TREE_PATH=$2; shift 2; continue; }
    [ "$1" == "--ftrees" ] && { FTREES=$2; shift 2; continue; }
    [ "$1" == "--dir" ] && { OUTPUT_DIR=$2; shift 2; continue; }
    echo "Unsupported argument, $1" && exit 101
done
{ [ -z $PROCESS ] || [ -z $OUTPUT_DIR ]; } && {
    echo "Specify process to link (--process) and output directory (--dir).";
    exit 1;
}
[ -z $TREE_PATH ] && \
    TREES_PATH=/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217
[ -z $FTREES ] && \
    FTREES=0_both3dlooseClean_v2
INITIAL_PATH=$(pwd)

## Linking trees
cd ${OUTPUT_DIR}
for tree in $(ls ${TREES_PATH} | grep ${PROCESS});
do
    echo "Linking the tree: ${tree}";
    ln -s ${TREES_PATH}/${tree} ${tree};
done

## Linking friend trees
[ ! -d ${OUTPUT_DIR}/${FTREES} ] && \
    mkdir -p ${FTREES}
cd ${FTREES}
for ftree in $(ls ${TREES_PATH}/${FTREES} | grep ${PROCESS});
do
    echo "Linking the friend tree: $ftree";
    ln -s ${TREES_PATH}/${FTREES}/${ftree} ${ftree}
done

cd $INITIAL_PATH
exit 0
