#!/bin/bash
[ -z $CMSSW_BASE ] && { echo "Run cmsenv."; exit 100; }

function do_help() {
    printf "
Usage: $(basename $0) --producer <file-no-sufix> --process <process> --work-dir <work-path>
Options:
      --producer       : Tree producer to use.
      --events         : Maximum events for the producer to run over.
      --process        : Process for the producers to run over.
      --output         : Output directory for the produced test trees.
      --work-dir       : Directory in which the analysis_scripts path exist.
      --rm-old-plots   : Remove the previous plots generated for testing.
      --plot-only      : Do not run the tree producer, only replot the already produced Test_Tree
      --dry-run        : Do not run the commands, enable verbosity and just print them. 
\n"
exit 0
}

while [ -n "$1" ]; do
    { [ "$1" == "--help" ] || [ "$1" == "-h" ]; } && do_help
    [ "$1" == "--producer" ] && { PRODUCER=$2; shift 2; continue; }
    [ "$1" == "--events" ] && { EVENTS=$2; shift 2; continue; }
    [ "$1" == "--process" ] && { PROCESS=$2; shift 2; continue; }
    [ "$1" == "--output" ] && { OUTPUT_PATH=$2; shift 2; continue; }    
    [ "$1" == "--work-dir" ] && { WORK_PATH=$2; shift 2; continue; }
    [ "$1" == "--rm-old-plots" ] && { RM_OLD_PLOTS=true; shift 1; continue; }
    [ "$1" == "--plot-only" ] && { PLOT_ONLY=true; shift 1; continue; }
    [ "$1" == "--verbose" ] && { VERBOSE=true; shift 1; continue; }
    [ "$1" == "--dry-run" ] && { DRY_RUN=true; VERBOSE=true; shift 1; continue; }
    echo "Unsupported argument $1"
    exit 1
done

## Fixing the undeclared variables
[ -z "$RM_OLD_PLOTS" ] && RM_OLD_PLOTS=false
[ -z "$PLOT_ONLY" ] && PLOT_ONLY=false
[ -z "$WORK_PATH" ] && { echo "Assuming as WORK_PATH the directory $CMSSW_BASE/src/CMGTools."; WORK_PATH=$CMSSW_BASE/src/CMGTools; }
INITIAL_PATH=$PWD
[ "$PWD" != "$WORK_PATH" ] && cd $WORK_DIR # let's go to the working directory
[ -z "$VERBOSE" ] && VERBOSE=false
[ -z "$DRY_RUN" ] && DRY_RUN=false
[ -z "$PRODUCER" ] && { echo "Specify which tree producer the script will use."; exit 1; }
[ -z "$PROCESS" ] && { echo "A process is mandatory to be specified."; exit 1; }
[ -z "$EVENTS" ] && EVENTS=100

function run_command() {
    ## run the command passed as arg 1 and keep output in arg 2
    ## while testing also VERBOSE and DRY_RUN vars
    COMMAND=$(echo $* | sed -r 's@(.*) [^ ]*$@\1@')
    shift $(( $#-1 ))
    LOG_FILE=$1
    $VERBOSE && { echo "PATH: $PWD"; echo $COMMAND; }
    ! $DRY_RUN && $COMMAND > $LOG_FILE 2>&1
    return $?
}

function echo_date() {
    { date | awk '{ printf $1"-"$2" "$4 }'; } \
	&& return 0
    return 1
}

## Running the tree producer
PRODUCTION_COMMAND="bash sosTrees_production.sh --local --process $PROCESS --out-path $OUTPUT_PATH --tree-producer $PRODUCER --events $EVENTS"
cd $WORK_PATH/condor_prod
[ -z $SOS_WORK_PATH ] && export SOS_WORK_PATH=$CMSSW_BASE/src
echo "$(echo_date)| Running sosTrees_production (locally) with $PRODUCER for $PROCESS to nTuplize $EVENTS events."
run_command $PRODUCTION_COMMAND $INITIAL_PATH/production.log

## Running the friend tree producer
FTREES_COMMAND="python prepareEventVariablesFriendTree.py --tra2 --tree treeProducerSusyMultilepton -I CMGTools.TTHAnalysis.tools.susySosReCleaner -m both3dloose -m ipjets -N 1000000 $OUTPUT_PATH $OUTPUT_PATH/0_both3dlooseClean_v2/ -j 4"
cd $WORK_PATH/TTHAnalysis/macros
echo "$(echo_date)| Running prepareEventVariablesFriendTree to calculate the rest analysis variables."
run_command $FTREES_COMMAND $INITIAL_PATH/friendtrees.log

## Running the plotter
PLOTTING_COMMAND="python mcPlots.py susy-sos-v1/2l/mca_sos_2016.txt susy-sos-v1/2l/cuts_sos_2016.txt myTestPlots.txt -P /eos/user/k/kpanos/sostrees/test_80X_compTrees/ --s2v --tree treeProducerSusyMultilepton -uf --mcc susy-sos-v1/mcc_triggerdefs.txt --mcc susy-sos-v1/2l/mcc2016/mcc_2l.txt --mcc susy-sos-v1/mcc_sos.txt --mcc susy-sos-v1/2l/mcc2016/mcc_sf_met125.txt --mcc susy-sos-v1/2l/mcc2016/mcc_sf_fakes_2losEwkLow.txt --load-macro susy-sos-v1/functionsSOS.cc --load-macro susy-sos-v1/functionsSF.cc --load-macro susy-sos-v1/functionsPUW.cc --load-macro functions-kpanos.cc -F sf/t /eos/user/k/kpanos/sostrees/test_80X_compTrees/0_both3dlooseClean_v2/evVarFriend_{cname}.root --print png,txt --neg --legendHeader Datasets -p jpsi-test -E 'ewk_.*' -R 'lepRel_mll' 'lepRel_mll' 'm2l<50' -X 'lepRel_upsilonVeto' -X '^evRel_.*' --pdir /eos/user/k/kpanos/www/SOS/tests/$(date | tr ' ' '_')/variables-test10000"
cd $WORK_PATH/TTHAnalysis/python/plotter
echo "$(echo_date)| Running mcPlot to produce the plots specidied in condor_prod/analysis_scripts/testplots.txt."
run_command $PLOTS_COMMAND $INITIAL_PATH/plotting.log
#$PLOTS_COMMAND
echo "exit code of plootting: $?"

[ "$INITIAL_PATH" != "$PWD" ] && cd $INITIAL_PATH
exit 0
