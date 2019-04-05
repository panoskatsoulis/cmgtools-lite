#!/bin/bash
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Script to run remotely the tree producer."
    echo "Supports 2 execution environments '--local' and '--condor', otherwise it returns code 101."
    echo "When running in condor environment, the parameters MUST be passed without the switches (--xyz) and using the following 'remote' format exactly as it is."
    echo "~~~"
    echo "remote usage: sosTrees_production.sh --condor <process> <condor-job-id> <condor-proc> <output-path> <tree-producer-nosuffix> <events-per-job> <jobs-per-process> <begin-file> <end-file>"
    echo " local usage: sosTrees_production.sh --local --process <process> --out-path <output-path> --tree-producer <tree-producer-nosuffix>"
    echo "  --local and --condor      : mandatory switches, this argument MUST be inserted as argument '\$1'"
    echo "  --events <events-per-job> : overwrites the number of events to be processed by each process-job (default '1000')"
    echo "  --jobs <jobs-per-process> : overwrites the number of jobs to split the range that is defined by '--begin-file' and '--end-file' (default '1')"
    echo "  --begin-file <begin-file> : overwrites the first root file to process (default '')"
    echo "  --end-file <end-file>     : overwrites the last root file to process (default '1')"
    echo "  --help, -h                : prints this help message."
    echo "~~~"
    echo "Exit codes:"
    echo "'0' all good"
    echo "'1' kerberos ticket doesn't exist somewhere in /afs (required by the heppy tool)"
    echo "'2' problem with env-variables SOS_80X or/and EOS_USER_PATH"
    echo "'3' sed command for selecting the process failed (script failure)"
    echo "'4' the final heppy command failed"
    echo "'101' unknown execution environment"
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
	[ "$1" == "--process" ] && { PROCESS=$2; shift 2; }
	[ "$1" == "--out-path" ] && { OUTPUT_TREE_PATH=${2}; shift 2; }
	[ "$1" == "--tree-producer" ] && { TREE_PRODUCER=$2; shift 2; }
	[ "$1" == "--events" ] && { EVENTS=$2; shift 2; }
	[ "$1" == "--begin-file" ] && { FILE1=$2; shift 2; }
	[ "$1" == "--end-file" ] && { FILE2=$2; shift 2; }
	[ "$1" == "--jobs-per-mcProcess" ] && { JOBS=$2; shift 2; }
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
else
    echo "-----> [ERROR] unknown execution environment $1"
    exit 101
fi

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
if [ ! -z $SOS_80X ] || [ ! -z $EOS_USER_PATH ]; then
    cd $SOS_80X
    eval `scramv1 runtime -sh`
    echo "-----> CMSSW_VERSION = $CMSSW_VERSION"
else 
    echo "-----> [ERROR] SOS_80X or/and EOS_USER_PATH are empty variables" ; exit 2
fi
echo "-----> PWD = $(pwd)"

echo "~~~~~"
echo "-----> configuring according to process..."
echo "-----> PROCESS = $PROCESS"
echo "-----> JOB_ID = $JOB_ID"
echo "-----> FILES = [${FILE1}:${FILE2}]"
echo "-----> JOBS = $JOBS"
echo "-----> configuring env and files"
cd CMGTools/condor_prod && { [ ! -d prod_treeProducersPerProcess ] && mkdir prod_treeProducersPerProcess; }
NEW_TREE_PRODUCER=${TREE_PRODUCER}_${PROCESS}.${JOB_ID}.py
cp -a ${TREE_PRODUCER}.py prod_treeProducersPerProcess/${NEW_TREE_PRODUCER}
sed -r -i "
s@(^selectedComponents.*)\[.*\]@\1\[${PROCESS}\]@;
s@(= comp\.files).*(#sosTrees_production)@\1\[${FILE1}:${FILE2}\] \2@;
s@(comp\.splitFactor).*(#sosTrees_production)@\1 = ${JOBS} \2@;
" prod_treeProducersPerProcess/${NEW_TREE_PRODUCER} || { echo "-----> [ERROR] sed command failed"; exit 3; }
JOB_RUN_PATH=jobBase_${PROCESS}_${JOB_ID}
[ -d "$JOB_RUN_PATH" ] && rm -rf $JOB_RUN_PATH
mkdir $JOB_RUN_PATH && cd $JOB_RUN_PATH
echo "-----> delete previous trees if exist"
[ -d "$OUTPUT_TREE_PATH" ] && rm -rf $OUTPUT_TREE_PATH

echo "~~~~~"
[ -z $EVENTS ] && { echo "-----> specific number of events has not been given as input, will run for 1000"; EVENTS='1000'; }
echo "-----> will run the heppy tool with the tree producer $TREE_PRODUCER"
HEPPY_COMMAND=$(heppy $OUTPUT_TREE_PATH ../prod_treeProducersPerProcess/${NEW_TREE_PRODUCER} -f -N $EVENTS -o analysis=SOS -o test='sosTrees_production' -j 4 > ../prod_treeProducersPerProcess/heppy.${PROCESS}_${JOB_ID}.out 2>&1)
$HEPPY_COMMAND || { echo "-----> [ERROR] heppy failure, would execute command:"; echo "$HEPPY_COMMAND"; exit 4; }
echo "-----> heppy exited with code $?"

cd - && rm -rf $JOB_RUN_PATH
exit 0
