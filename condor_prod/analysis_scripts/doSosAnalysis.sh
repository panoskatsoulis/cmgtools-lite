#!/bin/bash

function do_help() {
    printf "
Usage: $(basename $0) --producer <file-no-sufix> --process <process> --work-dir <work-path>
Options:
      --producer       : Tree producer to use.
      --events         : Maximum events for the producer to run over (default 100).
      --process        : Process for the producers to run over.
      --output-trees   : Output directory where the test trees will be produced in.
      --output-plots   : Output directory where the new plots will be produced in.
      --work-dir       : Directory in which the analysis_scripts path exist.
      --rm-old-plots   : Remove the previous plots generated for testing.
                         IMPORTANT: this will be executed only if the plotting step is enabled.
      --rm-old-trees   : Remove the previous trees included in the 'output directory' given
                         (or the default \$EOS_USER_PATH/sostrees/{year}_$(echo $CMSSW_VERSION | awk -F _ '{print $2$3"X" }'))
                         IMPORTANT: this will be executed only if the production step is enabled.
      --trees          : Enable running the trees production step.
      --ftrees         : Enable running the friend trees production step.
      --plots          : Enable running the plotting step.
      --trees-complete : Same as --trees --ftrees.
      --complete       : Same as --trees --ftrees --plots.
      --verbose        : Enable more printing out.
      --dry-run        : Do not run the commands, enable verbosity and just print them.
      -h, --help       : Prints this message.
Exit codes:
      0  ) Everything worked as expected (at least about the script).
      1  ) Problem occured while fixing the undeclared variables.
      11 ) Unsupported command line argument.
      2  ) Problem occured in the Tree producer's section.
      3  ) Problem occured in the Friend-Tree producer's section.
      2  ) Problem occured in the Plotting section.
\n"
exit 0
}

while [ -n "$1" ]; do
    { [ "$1" == "--help" ] || [ "$1" == "-h" ]; } && do_help
    [ "$1" == "--producer" ] && { PRODUCER=$2; shift 2; continue; }
    [ "$1" == "--events" ] && { EVENTS=$2; shift 2; continue; }
    [ "$1" == "--process" ] && { PROCESS=$2; shift 2; continue; }
    [ "$1" == "--output-trees" ] && { OUTPUT_PATH_TREES=$2; shift 2; continue; }    
    [ "$1" == "--output-plots" ] && { OUTPUT_PATH_PLOTS=$2; shift 2; continue; }
    [ "$1" == "--work-dir" ] && { WORK_PATH=$2; shift 2; continue; }
    [ "$1" == "--rm-old-plots" ] && { RM_OLD_PLOTS=true; shift 1; continue; }
    [ "$1" == "--rm-old-trees" ] && { RM_OLD_TREES=true; shift 1; continue; }
    [ "$1" == "--trees" ] && { DO_TREES=true; shift 1; continue; }
    [ "$1" == "--ftrees" ] && { DO_FTREES=true; shift 1; continue; }
    [ "$1" == "--plots" ] && { DO_PLOTS=true; shift 1; continue; }
    [ "$1" == "--trees-complete" ] && { DO_TREES=true; DO_FTREES=true; shift 1; continue; }
    [ "$1" == "--complete" ] && { DO_TREES=true; DO_FTREES=true; DO_PLOTS=true; shift 1; continue; }
    [ "$1" == "--verbose" ] && { VERBOSE=true; shift 1; continue; }
    [ "$1" == "--dry-run" ] && { DRY_RUN=true; VERBOSE=true; shift 1; continue; }
    echo "Unsupported argument $1"
    exit 11
done

## Fixing the undeclared variables
[ -z "$CMSSW_VERSION" ] && { echo "Run cmsenv and rerun the script."; exit 1; }
[ -z "$VERBOSE" ] && VERBOSE=false
[ -z "$DRY_RUN" ] && DRY_RUN=false
[ -z "$DO_TREES" ] && DO_TREES=false
[ -z "$DO_FTREES" ] && DO_FTREES=false
[ -z "$DO_PLOTS" ] && DO_PLOTS=false
{ ! "$DO_TREES" && ! "$DO_FTREES" && ! "$DO_PLOTS"; } && {
    echo "None of the analysis tasks has been requested. (trees/ftrees/plots)"
    exit 1
}
[ -z "$WORK_PATH" ] && {
    echo "Assuming as WORK_PATH the directory $CMSSW_BASE/src/CMGTools.";
    WORK_PATH=$CMSSW_BASE/src/CMGTools;
}
INITIAL_PATH=$PWD
[ "$PWD" != "$WORK_PATH" ] && cd $WORK_DIR # let's go to the working directory
[ -z "$PRODUCER" ] && { echo "Specify which tree producer the script will use."; exit 1; }
[ -z "$PROCESS" ] && { echo "A process is mandatory to be specified."; exit 1; }
[ -z "$EVENTS" ] && EVENTS=100
[ -z "$OUTPUT_PATH_TREES" ] && {
    printf "Output path for the trees has not been specified.
Will use the default path related to the corresponding year of the trees.
[2016/2017/2018] (different answer terminates the script) ";
    read ans;
    ! [[ $ans =~ 201[678] ]] && { echo "Unknown year."; exit 1; }
    OUTPUT_PATH_TREES="${EOS_USER_PATH}/sostrees/${ans}_$(echo $CMSSW_VERSION | awk -F _ '{print $2$3"X" }')";
    echo "Declaring the default path for saving the treess ${OUTPUT_PATH_TREES}";
    [ ! -d $OUTPUT_PATH_TREES ] && mkdir -p $OUTPUT_PATH_TREES
}
[ -z "$OUTPUT_PATH_PLOTS" ] && {
    OUTPUT_PATH_PLOTS="${EOS_USER_PATH}/www/SOS/tests/$(date | tr ' ' '_' | sed -r 's@\:[0-9]{2}_@_@' )/test${EVENTS}events";
    echo "Declaring the default path for saving the plots ${OUTPUT_PATH_PLOTS}";
    [ ! -d $OUTPUT_PATH_PLOTS ] && mkdir -p $OUTPUT_PATH_PLOTS;
}
{ [ -z "$RM_OLD_TREES" ] || $DRY_RUN; } && RM_OLD_TREES=false
{ [ -z "$RM_OLD_PLOTS" ] || $DRY_RUN; } && RM_OLD_PLOTS=false
EXTRA_MACRO_TO_LOAD='-L functions-kpanos.cc' # In the future changes, specify with options an extra macro to load
#COMMANDS_FILE=$WORK_PATH/condor_prod/analysis_scripts/doSosAnalysis.commands # In the future changes, include the commands in a separate file


## Useful functions which are used in all the 3 commands
function run_command() {
    ## run the command passed as arg 1 and keep output in arg 2
    ## while testing also VERBOSE and DRY_RUN vars
    COMMAND=$(echo "$*" | sed -r 's@(.*) [^ ]*$@\1@')
    shift $(( $#-1 ))
    LOG_FILE=$1
    $VERBOSE && {
	echo "In Path: $PWD";
	echo "Command: $COMMAND";
	echo "Logfile: $LOG_FILE";
    }
    ! $DRY_RUN && $COMMAND > $LOG_FILE 2>&1
    return $?
}

function echo_date() {
    { date | awk '{ printf $1"-"$2" "$4 }'; } \
	&& return 0
    return 1
}


## Commands
PRODUCTION_COMMAND="bash sosTrees_production.sh --local --process $PROCESS --out-path $OUTPUT_PATH_TREES --tree-producer $PRODUCER --events $EVENTS"
FTREES_COMMAND="python prepareEventVariablesFriendTree.py --tra2 --tree treeProducerSusyMultilepton -I CMGTools.TTHAnalysis.tools.susySosReCleaner -m both3dloose -m ipjets -N 1000000 $OUTPUT_PATH_TREES $OUTPUT_PATH_TREES/0_both3dlooseClean_v2/ -j 4"
PLOTTING_COMMAND="python mcPlots.py $WORK_PATH/condor_prod/analysis_scripts/sosmca.txt $WORK_PATH/condor_prod/analysis_scripts/soscuts.txt $WORK_PATH/condor_prod/analysis_scripts/sosplots.txt -P $OUTPUT_PATH_TREES --s2v --tree treeProducerSusyMultilepton -uf --mcc susy-sos-v1/mcc_triggerdefs.txt --mcc susy-sos-v1/2l/mcc2016/mcc_2l.txt --mcc susy-sos-v1/mcc_sos.txt --mcc susy-sos-v1/2l/mcc2016/mcc_sf_met125.txt --mcc susy-sos-v1/2l/mcc2016/mcc_sf_fakes_2losEwkLow.txt -L susy-sos-v1/functionsSOS.cc -L susy-sos-v1/functionsSF.cc -L susy-sos-v1/functionsPUW.cc -F sf/t $OUTPUT_PATH_TREES/0_both3dlooseClean_v2/evVarFriend_{cname}.root --print png,txt --neg --legendHeader Datasets -p jpsi -E 'ewk_.*' -R 'lepRel_mll' 'lepRel_mll' 'm2l<50' -X 'lepRel_upsilonVeto' -X '^evRel_.*' --pdir $OUTPUT_PATH_PLOTS $EXTRA_MACRO_TO_LOAD"

## Running the tree producer
if $DO_TREES; then
    cd $WORK_PATH/condor_prod
    [ -z $SOS_WORK_PATH ] && export SOS_WORK_PATH=$CMSSW_BASE/src
    $RM_OLD_TREES && {
	ls $OUTPUT_PATH_TREES;
	printf "Removing the above trees in $OUTPUT_PATH_TREES [y/n]"; read ans;
	! [[ $ans =~ [yn] ]] && { echo "Unknown answer given."; exit 2; };
	{ [ "$ans" == 'y' ] && rm -rf $OUTPUT_PATH_TREES/*; } || echo "Didn't remove the old trees.";
    }

    { ! $DRY_RUN \
	&& printf "\e[0;33m$(echo_date)|\e[0m Running sosTrees_production (locally) with $PRODUCER for $PROCESS to nTuplize $EVENTS events.\n"; } \
	|| printf "\e[0;33mTrees' Production  |\e[0m Running sosTrees_production (locally) with $PRODUCER for $PROCESS to nTuplize $EVENTS events.\n"
    run_command $PRODUCTION_COMMAND $INITIAL_PATH/production.log

    ! $DRY_RUN && { # if --dry-run skip it, else print info about the outcome of the tree production (if --verbose print more)
	{ $VERBOSE && { echo "exit code of trees production: $?"; tail $INITIAL_PATH/production.log; }; } \
	    || grep 'heppy exited' $INITIAL_PATH/production.log;
	tail -3 prod_treeProducersPerProcess/heppy.${PROCESS}_local.test.out;
    }
fi

## Running the friend tree producer
if $DO_FTREES; then
    cd $WORK_PATH/TTHAnalysis/macros

    { ! $DRY_RUN \
	&& printf "\e[0;33m$(echo_date)|\e[0m Running prepareEventVariablesFriendTree to calculate the rest analysis variables.\n"; } \
	|| printf "\e[0;33mFTrees' Production |\e[0m Running prepareEventVariablesFriendTree to calculate the rest analysis variables.\n"
    run_command $FTREES_COMMAND $INITIAL_PATH/friendtrees.log

    ! $DRY_RUN && { # if --dry-run skip it, else print info about the outcome of the ftree production (if --verbose print more)
	{ $VERBOSE && { echo "exit code of friend trees production: $?"; tail $INITIAL_PATH/friendtrees.log; }; } \
	    || grep -w task[s]* $INITIAL_PATH/friendtrees.log;
    }
fi

## Running the plotter
if $DO_PLOTS; then
    cd $WORK_PATH/TTHAnalysis/python/plotter
    $RM_OLD_PLOTS && {
	ls $OUTPUT_PATH_PLOTS;
	printf "Removing the above plots in $OUTPUT_PATH_PLOTS [y/n]"; read ans;
	[ "$ans" == 'y' ] && rm -rf $OUTPUT_PATH_PLOTS
    }

    { ! $DRY_RUN \
	&& printf "\e[0;33m$(echo_date)|\e[0m Running mcPlot to produce the plots specidied in condor_prod/analysis_scripts/testplots.txt.\n"; } \
	|| printf "\e[0;33mPlots' Production  |\e[0m Running mcPlot to produce the plots specidied in condor_prod/analysis_scripts/testplots.txt.\n"
    run_command $PLOTTING_COMMAND $INITIAL_PATH/plotting.log

    ! $DRY_RUN && { # if --dry-run skip it, else print info about the outcome of plotting (if --verbose print more)
	{ $VERBOSE && { echo "exit code of plootting: $?"; tail $INITIAL_PATH/plotting.log; }; } \
	    || { echo "The plotter processed the following"; grep -w plot: $INITIAL_PATH/plotting.log; };
	grep --color ^Error.*Bad.*expression.* $INITIAL_PATH/plotting.log \
	    || printf "\e[0;32mNo bad expression found in the log file.\e[m\n";
    }
fi

[ "$INITIAL_PATH" != "$PWD" ] && cd $INITIAL_PATH
exit 0
