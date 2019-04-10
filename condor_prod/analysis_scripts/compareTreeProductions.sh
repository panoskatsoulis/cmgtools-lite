#!/bin/bash

function do_help() {
    printf "
Usage: $(basename $0) --prod1 <file-no-sufix> --prod2 <file-no-sufix> --process <process> --run-type <type> [options]
Options:
      --prod1, --prod2 : Producers to compare.
      --run-type       : Which producers to run (nominal/test/both).
      --events         : Maximum events for the producers to run over.
      --process        : Process for the producers to run over.
      --rm-old         : Remove the previous trees generated for testing.
"
exit 0
}

while [ -n $1 ]; do
    { [ "$1" == "--help" ] || [ "$1" == "-h" ]; } && do_help
    [ "$1" == "--prod1" ] && { PROD1=$2; shift 2; continue; }
    [ "$1" == "--prod2" ] && { PROD2=$2; shift 2; continue; }
    [ "$1" == "--run-type" ] && { TYPE=$2; shift 2; continue; }
    [ "$1" == "--events" ] && { EVENTS=$2; shift 2; continue; }
    [ "$1" == "--process" ] && { PROCESS=$2; shift 2; continue; }
    [ "$1" == "--rm-old" ] && { RM_OLD=true; shift 1; continue; }
    echo "Unsupported argument $1"
    exit 1
done

{ [ -z $PROD1 ] || [ -z $PROD2 ]; } \
    && { echo "Specify which 2 tree producers the script will compare."; exit 1 }
{ [ "$TYPE" != "nominal" ] || [ "$TYPE" != "test" ] || [ "$TYPE" != "both" ]; } \
    && { echo "The run type $TYPE is unknown."; exit 1; }
[ -z $PROCESS ] && { echo "A process is mandatory to be specified."; exit 1; }
[ -z $RM_OLD ] && RM_OLD=false
[ -z $EVENTS ] && EVENTS=100


## sosTrees_production configuration
OUTPUT_PATH=$EOS_USER_PATH/sostrees/test_80X_compTrees
JOBS=1
FILES='--begin-file 1 --end-file 10'

## Execute the commands
[ -d $OUTPUT_PATH/$PROCESS ] && rm -rf $OUTPUT_PATH/$PROCESS
if [ "$TYPE" == "nominal" ] || [ "$TYPE" == "both" ]; then
    ./sosTrees_production.sh --local --process $PROCESS --out-path $OUTPUT_PATH --tree-producer $PROD1 --jobs $JOBS --events $EVENTS $FILES
    [ -d $OUTPUT_PATH/Nominal_Tree ] && rm -rf $OUTPUT_PATH/Nominal_Tree
    mv $OUTPUT_PATH/$PROCESS $OUTPUT_PATH/Nominal_Tree
elif [ "$TYPE" == "test" ] || [ "$TYPE" == "both" ]; then
    ./sosTrees_production.sh --local --process $PROCESS --out-path $OUTPUT_PATH --tree-producer $PROD2 --jobs $JOBS --events $EVENTS $FILES
    [ -d $OUTPUT_PATH/Test_Tree ] && rm -rf $OUTPUT_PATH/Test_Tree
    mv $OUTPUT_PATH/$PROCESS $OUTPUT_PATH/Test_Tree
else
    echo "Something is wrong with the TYPE variable."
    exit 2
fi

## Compare Trees
if [ -d $OUTPUT_PATH/Nominal_Tree ] && [ -d $OUTPUT_PATH/Test_Tree ]; then
    echo "Comparing Nominal_Tree (Tree1) and Test_Tree (Tree2):"
    python compareTrees.py $OUTPUT_PATH/Nominal_Tree $OUTPUT_PATH/Test_Tree
fi

exit 0
