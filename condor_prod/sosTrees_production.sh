#!/bin/bash
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Script to run remotely the tree producer."
    echo "Supports 2 execution environments '--local' and '--condor', otherwise it returns code 101."
    echo "When running in condor environment, the parameters MUST be passed without the switches (--xyz) and using the following 'remote' format exactly as it is."
    echo "~~~"
    echo "remote usage: sosTrees_production.sh --condor <process> <condor-job-id> <condor-proc> <output-path> <tree-producer-nosuffix> <events-per-job> <jobs-per-process> <begin-file> <end-file> [<task-name>]"
    echo " local usage: sosTrees_production.sh --local --process <process> --out-path <output-path> --tree-producer <tree-producer-nosuffix>"
    echo "  --local and --condor      : mandatory switches, this argument MUST be inserted as argument '\$1'"
    echo "  --events <events-per-job> : overwrites the number of events to be processed by each process-job (default '1000')"
    echo "  --jobs <jobs-per-process> : overwrites the number of jobs to split the range that is defined by '--begin-file' and '--end-file' (default '1')"
    echo "  --begin-file <begin-file> : overwrites the first root file to process (default '')"
    echo "  --end-file <end-file>     : overwrites the last root file to process (default '1')"
    echo "  --task <task-name>        : overwrites the task name for jobs of a given process using a specific tree producer (default '<process>.<tree-producer-nosuffix>')"
    echo "  --dont-rm-link            : configures the script to keep the link that points to the workspace (for debugging)"
    echo "  --help, -h                : prints this help message."
    echo "~~~"
    echo "Exit codes:"
    echo "'0' all good"
    echo "'1' kerberos ticket doesn't exist somewhere in /afs (required by the heppy tool)"
    echo "'2' problem with env-variables SOS_WORK_PATH or/and EOS_USER_PATH"
    echo "'3' sed command for selecting the process failed (script failure)"
    echo "'4' the final heppy command failed"
    echo "'101' unknown execution environment"
    echo "'102' unknown command line argument (local only)"
    exit 0
fi

if [ "$1" == "--local" ]; then
    EXE_ENV="local" && shift 1 #save and shift the "--local" arg
    CUSTOM_PS1=$PS1
    JOB_ID="local.test"
    JOBS='1'
    FILE1=''
    FILE2='1'
    while [ ! -z $1 ]; do
	[ "$1" == "--process" ] && { PROCESS=$2; shift 2; continue; }
	[ "$1" == "--out-path" ] && { OUTPUT_TREE_PATH=$2; shift 2; continue; }
	[ "$1" == "--tree-producer" ] && { TREE_PRODUCER=$2; shift 2; continue; }
	[ "$1" == "--events" ] && { EVENTS=$2; shift 2; continue; }
	[ "$1" == "--begin-file" ] && { FILE1=$2; shift 2; continue; }
	[ "$1" == "--end-file" ] && { FILE2=$2; shift 2; continue; }
	[ "$1" == "--jobs" ] && { JOBS=$2; shift 2; continue; }
	[ "$1" == "--task" ] && { TASK_NAME=$2; shift 2; continue; }
	[ "$1" == "--dont-rm-link" ] && { KEEP_JOB_LINK=true; shift; continue; }
	echo "Unknown command line argument $1" && exit 102;
    done
elif [ "$1" == "--condor" ]; then
    EXE_ENV="condor" && shift 1 #save and shift the "--condor" arg
    CUSTOM_PS1="[${USER}@$(hostname)]$"
    PROCESS=$1
    JOB_ID="$2.$3"
    OUTPUT_TREE_PATH=$4
    TREE_PRODUCER=$5
    EVENTS=$6
    JOBS=$7
    FILE1=$8
    FILE2=$9
    TASK_NAME=${10}
else
    echo "-----> [ERROR] unknown execution environment $1"
    exit 101
fi
[ -z $KEEP_JOB_LINK ] && KEEP_JOB_LINK=false
[ -z $TASK_NAME ] && TASK_NAME=${PROCESS}.$TREE_PRODUCER # fill the task name if it's not given.
TASK_NAME=task_$TASK_NAME

echo "-----> SOS Tree Production"
echo "-----> checking hostname..."
hostname
echo "-----> checking path..."
pwd

echo "~~~~~"
echo "-----> checking networking setup..."
ifconfig

echo "~~~~~"
echo "-----> setting up proxy and running voms-proxy-info..."
if [ -e "/tmp/x509up_u${UID}" ]; then
    cp -a /tmp/x509up_u${UID} ${AFS_HOME}/.
    voms-proxy-info
elif [ "$EXE_ENV" == "condor" ]; then
    CMS_PROXY_FILE=${AFS_HOME}/x509up_u${UID}
    { [ -e $CMS_PROXY_FILE ] && voms-proxy-info --file $CMS_PROXY_FILE; } || {
	echo "-----> [ERROR] Valid CMS proxy file not found. Execution environment is 'condor' and $CMS_PROXY_FILE doesn't exist"; }
else
    echo "-----> [ERROR] Valid CMS proxy file not found. Execution environment is 'local' and /tmp/x509up_u${UID} doesn't exist"
    exit 1
fi
export X509_USER_PROXY=$AFS_HOME/x509up_u${UID}

echo "~~~~~"
echo "-----> setting up cmssw env..."
if [ ! -z $SOS_WORK_PATH ] && [ ! -z $EOS_USER_PATH ]; then
    echo "-----> [NOTE] SOS_WORK_PATH and EOS_USER_PATH variables are set as expected."
elif [ -z $SOS_WORK_PATH ] && [ ! -z $EOS_USER_PATH ]; then
    echo "-----> [WARNING] SOS_WORK_PATH is empty, will set it to \$CMSSW_BASE/src if CMSSW environment has already been set."
    [ ! -z $CMSSW_VERSION ] && export SOS_WORK_PATH=$CMSSW_BASE/src
else
    echo "-----> [ERROR] SOS_WORK_PATH or/and EOS_USER_PATH are empty variables"
    echo "-----> [NOTE] sosTrees_production.sh uses these variables to setup the running environment and also save output trees in EOS."
    echo "-----> [NOTE] Please export your \$CMSSW_BASE/src as SOS_WORK_PATH, your EOS path as EOS_USER_PATH, and rerun the script."
    exit 2
fi
INITIAL_PATH=$(pwd) && cd $SOS_WORK_PATH
eval `scramv1 runtime -sh`
echo "-----> SOS_WORK_PATH = $SOS_WORK_PATH"
echo "-----> CMSSW_VERSION = $CMSSW_VERSION"
echo "-----> PWD = $(pwd)"

echo "-----> finding the relative task..."
cd CMGTools/condor_prod # get into the condor_prod package
# create the TASK path if it doesn't exist and get into there
[ ! -d $TASK_NAME ] && mkdir $TASK_NAME
cd $TASK_NAME
# prepare the task path in a way that the rest script will be able to run unchanged from inside the task folder
[ ! -d prod_treeProducersPerProcess ] && mkdir prod_treeProducersPerProcess
[ ! -e $TREE_PRODUCER.py ] && cp -a ../$TREE_PRODUCER.py .
echo "-----> TASK = $TASK_NAME"
echo "-----> PWD = $(pwd)"

echo "~~~~~"
echo "-----> configuring according to process..."
echo "-----> PROCESS = $PROCESS"
echo "-----> JOB_ID = $JOB_ID"
echo "-----> FILES = [${FILE1}:${FILE2}]"
echo "-----> JOBS = $JOBS"
echo "-----> configuring env and files"
NEW_TREE_PRODUCER=${TREE_PRODUCER}_${PROCESS}.${JOB_ID}.py
cp -a ${TREE_PRODUCER}.py prod_treeProducersPerProcess/${NEW_TREE_PRODUCER}
sed -r -i "
s@(^selectedComponents.*)\[.*\]@\1\[${PROCESS}\]@;
s@(= comp\.files).*(#sosTrees_production)@\1\[${FILE1}:${FILE2}\] \2@;
s@(comp\.splitFactor).*(#sosTrees_production)@\1 = ${JOBS} \2@;
" prod_treeProducersPerProcess/${NEW_TREE_PRODUCER} || { echo "-----> [ERROR] sed command failed"; exit 3; }

## Preparing the running path and the remote path
JOB_RUN_PATH=jobBase_${PROCESS}_${JOB_ID} # link to the remote path that is defined next
JOB_REMOTE_PATH=$EOS_USER_PATH/workspace/$JOB_RUN_PATH # real location of the job run path
[ -d $JOB_REMOTE_PATH ] && rm -rf $JOB_REMOTE_PATH
mkdir $JOB_REMOTE_PATH
[ -e $JOB_RUN_PATH ] && rm -f $JOB_RUN_PATH
ln -s $JOB_REMOTE_PATH $JOB_RUN_PATH && cd $JOB_RUN_PATH

## This commented out section is responsible for checking if similar pathe exist in the output dir and to create a new dir for output
#
# echo "-----> check if previous trees exist"
# [ ! -z "$(ls -d ${OUTPUT_TREE_PATH}/*/ | grep ${PROCESS})" ] && {
#     echo "-----> The following directories exist with similar name to that of the process ${PROCESS}:";
#     ls -d ${OUTPUT_TREE_PATH}/*/ | grep ${PROCESS};
#     echo "-----> Will create new directory inside the output directory using date information.";
#     OUTPUT_TREE_PATH=${OUTPUT_TREE_PATH}/$(date | awk -F '[ :]*' '{print $1"-"$2"-"$3"-"$8"_time"$4$5}');
#     mkdir $OUTPUT_TREE_PATH;
# }

## Create output directory if it doesn't exist already
[ ! -e $OUTPUT_TREE_PATH ] && mkdir $OUTPUT_TREE_PATH

echo "~~~~~"
[ -z $EVENTS ] && { echo "-----> specific number of events has not been given as input, will run for 1000"; EVENTS='1000'; }
echo "-----> will run the heppy tool with the tree producer $TREE_PRODUCER for $EVENTS events"
echo "-----> OUTPUT_TREE_PATH = $OUTPUT_TREE_PATH"
OUT_FILE=heppy.${PROCESS}_${JOB_ID}.out && touch $OUT_FILE
HEPPY_COMMAND="heppy ./ $SOS_WORK_PATH/CMGTools/condor_prod/$TASK_NAME/prod_treeProducersPerProcess/$NEW_TREE_PRODUCER -f -N $EVENTS -o analysis=SOS -o test=sosTrees_production -j 4 > $OUT_FILE 2>&1"
echo "-----> HEPPY CMD: $HEPPY_COMMAND"
eval $HEPPY_COMMAND || { echo "-----> [ERROR] heppy failure, exited with code: $?"; exit 4; }
echo "-----> heppy exited with code $?"

echo "~~~~~"
echo "-----> Comparing chunks and checking if the production has been finished."
PRODUCTION_DONE=false
if [ "$EXE_ENV" == "local" ]; then
    EVENTS_PRODUCED=$(grep 'events processed' $OUT_FILE | sed 's/ //g' | awk -F : '{print $2}')
    [ -z $EVENTS_PRODUCED ] && EVENTS_PRODUCED=0
    (( $EVENTS_PRODUCED == $EVENTS )) && PRODUCTION_DONE=true
elif [ "$EXE_ENV" == "condor" ]; then
    CHUNKS_SUBMITED=0
    CHUNKS_DONE=-1
    CHUNKS_SUBMITED=$(grep -w submitting $OUT_FILE | sed -r 's@^(submitting).*@\1@' | uniq -c | awk '{print $1}')
    CHUNKS_DONE=$(grep -w done $OUT_FILE | sed -r 's@^(.*done):.*@\1@' | uniq -c | awk '{print $1}')
    (( $CHUNKS_DONE == $CHUNKS_SUBMITED )) && PRODUCTION_DONE=true
else
    echo "Unknown execution environment $EXE_ENV."
    exit 101
fi

echo "In path: $PWD"
for LOCAL_CHUNK in $(ls * -d | grep ^${PROCESS}); do
    ## Copy the output heppy file to the task's prod_treeProducersPerProcess folder
    TARGET_HEPPY_FILE=$SOS_WORK_PATH/CMGTools/condor_prod/$TASK_NAME/prod_treeProducersPerProcess/$OUT_FILE
    [ -e $TARGET_HEPPY_FILE ] && rm -f $TARGET_HEPPY_FILE
    cp -a $OUT_FILE $TARGET_HEPPY_FILE

    ## Compare the chunks and copy them to EOS if needed
    LOCAL_CHUNK_LARGER=false
    REMOTE_CHUNK_EXIST=false
    REMOTE_CHUNK=$OUTPUT_TREE_PATH/${LOCAL_CHUNK}_${FILE1}-${FILE2}
    [ -d $REMOTE_CHUNK ] && {
	REMOTE_CHUNK_EXIST=true
	REMOTE_SIZE=$(du --total $REMOTE_CHUNK | grep total | awk '{print $1}')
	echo "REMOTE_SIZE=$REMOTE_SIZE"
	LOCAL_SIZE=$(du --total $LOCAL_CHUNK | grep total | awk '{print $1}')
	echo "LOCAL_SIZE=$LOCAL_SIZE"
	(( $LOCAL_SIZE > $REMOTE_SIZE )) && LOCAL_CHUNK_LARGER=true
    }
    echo ">> LOCAL_CHUNK_LARGER=$LOCAL_CHUNK_LARGER, REMOTE_CHUNK_EXIST=$REMOTE_CHUNK_EXIST, $LOCAL_CHUNK, $REMOTE_CHUNK"

    if ! $REMOTE_CHUNK_EXIST; then # if there is no remote chunk just copy the new one
	printf "A remote chunk doesn't exist, copying the local chunk to ${OUTPUT_TREE_PATH}.\n"
	cp -r $LOCAL_CHUNK $REMOTE_CHUNK && rm -rf $LOCAL_CHUNK
    elif $PRODUCTION_DONE; then # there are 4 cases here, this elif holps 2 PD+LCL or PD+!LCL
	printf "The production has been finished as expected. The file will be copied to $OUTPUT_TREE_PATH.\n"
	rm -rf $REMOTE_CHUNK
	cp -r $LOCAL_CHUNK $REMOTE_CHUNK && rm -rf $LOCAL_CHUNK
	! $LOCAL_CHUNK_LARGER && \
	    printf "\e[0;33mWARNING!\e[0m The local chunk $LOCAL_CHUNK is NOT larger than the remote, BUT the production has been finished.\nThe chunk won't be removed from $JOB_REMOTE_PATH.\n"
    else # !PD+LCL or !PD+!LCL
	$LOCAL_CHUNK_LARGER && { # if the new chunk is larger copy it regardless of if the production has been finished
	    printf "The new chunk is larger, copying it to ${OUTPUT_TREE_PATH}.\n";
	    rm -rf $REMOTE_CHUNK
	    cp -r $LOCAL_CHUNK $REMOTE_CHUNK && rm -rf $LOCAL_CHUNK;
	    continue;
	}

	printf "Removing the local chunk.\nThe remote is larger and the production has not been finished.\n";
	rm -rf $LOCAL_CHUNK
    fi
done
{ $PRODUCTION_DONE && printf "PRODUCTION_DONE = \e[0;32m$PRODUCTION_DONE\e[0m\n"; } || \
    printf "PRODUCTION_DONE = \e[0;31m$PRODUCTION_DONE\e[0m\n"

cd - > /dev/null && ! $KEEP_JOB_LINK && rm -f $JOB_RUN_PATH # remove the link but NOT the remote path if it's not been removed yet
cd $INITIAL_PATH
exit 0
