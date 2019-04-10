#!/bin/bash

function do_help() {
    printf "
Usage: $(basename $0) --prod1 <file-no-sufix> --prod2 <file-no-sufix> --process <process> --run-type <type> --work-dir <work-path>
       $(basename $0) --only-compare --work-dir <work-path>
Options:
      --prod1, --prod2 : Producers to compare.
      --run-type       : Which producers to run (nominal/test/both).
      --events         : Maximum events for the producers to run over.
      --process        : Process for the producers to run over.
      --output         : Output directory for the produced test trees.
      --work-dir       : Directory in which the analysis_scripts path exist.
      --rm-old         : Remove the previous trees generated for testing.
      --only-compare   : Skip the tree production and do comparison of existing trees in the OUTPUT_PATH.
\n"
exit 0
}

while [ -n "$1" ]; do
    { [ "$1" == "--help" ] || [ "$1" == "-h" ]; } && do_help
    [ "$1" == "--prod1" ] && { PROD1=$2; shift 2; continue; }
    [ "$1" == "--prod2" ] && { PROD2=$2; shift 2; continue; }
    [ "$1" == "--run-type" ] && { TYPE=$2; shift 2; continue; }
    [ "$1" == "--events" ] && { EVENTS=$2; shift 2; continue; }
    [ "$1" == "--process" ] && { PROCESS=$2; shift 2; continue; }
    [ "$1" == "--output" ] && { OUTPUT_PATH=$2; shift 2; continue; }    
    [ "$1" == "--work-dir" ] && { WORK_PATH=$2; shift 2; continue; }
    [ "$1" == "--rm-old" ] && { RM_OLD=true; shift 1; continue; }
    [ "$1" == "--only-compare" ] && { ONLY_CMP=true; shift 1; continue; }
    [ "$1" == "--verbose" ] && { VERBOSE=true; shift 1; continue; }
    echo "Unsupported argument $1"
    exit 1
done

## Fixing the undeclared variables
[ -z "$RM_OLD" ] && RM_OLD=false
[ -z "$ONLY_CMP" ] && ONLY_CMP=false
[ -z "$WORK_PATH" ] && { echo "Assuming as WORK_PATH the current directory."; WORK_PATH=$(pwd); }
[ "$PWD" != "$WORK_PATH" ] && cd $WORK_DIR # let's go to the working directory
[ -z $VERBOSE ] && VERBOSE=false
! $ONLY_CMP && {
    { [ -z "$PROD1" ] || [ -z "$PROD2" ]; } \
	&& { echo "Specify which 2 tree producers the script will compare."; exit 1; }
    { [ "$TYPE" != "nominal" ] && [ "$TYPE" != "test" ] && [ "$TYPE" != "both" ]; } \
	&& { echo "The run type $TYPE is unknown."; exit 1; }
    [ -z "$PROCESS" ] && { echo "A process is mandatory to be specified."; exit 1; }
    [ -z "$EVENTS" ] && EVENTS=100
}

## sosTrees_production configuration
[ -z "$OUTPUT_PATH" ] && {
    NEW_OUT_PATH=$EOS_USER_PATH/sostrees/test_80X_compTrees;
    [ ! -d "$NEW_OUT_PATH" ] && mkdir $NEW_OUT_PATH;
    OUTPUT_PATH=$NEW_OUT_PATH;
}
JOBS=1
#FILES='--begin-file 1 --end-file 10'

## Verbose print
$VERBOSE && {
    printf "Variables:
    PROD1 = $PROD1
    PROD2 = $PROD2
    TYPE = $TYPE
    EVENTS = $EVENTS
    PROCESS = $PROCESS
    OUTPUT_PATH = $OUTPUT_PATH
    WORK_PATH = $WORK_PATH
    RM_OLD = $RM_OLD
    ONLY_CMP = $ONLY_CMP
    VERBOSE = $VERBOSE
"
}

## Execute the commands
$RM_OLD && rm -rf $OUTPUT_PATH
! $ONLY_CMP && {
    [ -d $OUTPUT_PATH/$PROCESS ] && rm -rf $OUTPUT_PATH/$PROCESS
    if [ "$TYPE" == "nominal" ] || [ "$TYPE" == "both" ]; then
	./sosTrees_production.sh --local --process $PROCESS --out-path $OUTPUT_PATH --tree-producer $PROD1 --jobs $JOBS --events $EVENTS $FILES
	[ -d $OUTPUT_PATH/Nominal_Tree ] && rm -rf $OUTPUT_PATH/Nominal_Tree
	mv $OUTPUT_PATH/$PROCESS $OUTPUT_PATH/Nominal_Tree
    fi
    if [ "$TYPE" == "test" ] || [ "$TYPE" == "both" ]; then
	./sosTrees_production.sh --local --process $PROCESS --out-path $OUTPUT_PATH --tree-producer $PROD2 --jobs $JOBS --events $EVENTS $FILES
	[ -d $OUTPUT_PATH/Test_Tree ] && rm -rf $OUTPUT_PATH/Test_Tree
	mv $OUTPUT_PATH/$PROCESS $OUTPUT_PATH/Test_Tree
    fi
}

## Compare Trees
if [ -d $OUTPUT_PATH/Nominal_Tree ] && [ -d $OUTPUT_PATH/Test_Tree ]; then
    echo "Comparing Nominal_Tree (Tree1) and Test_Tree (Tree2):"
    python analysis_scripts/compareTrees.py $OUTPUT_PATH/Nominal_Tree $OUTPUT_PATH/Test_Tree --events $EVENTS
else
    echo "Cant find the tree paths Nominal_Tree or/and Test_Tree."
    echo "OUTPUT_PATH = $OUTPUT_PATH"
    exit 5
fi

exit 0
