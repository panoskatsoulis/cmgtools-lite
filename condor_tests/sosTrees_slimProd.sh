#!/bin/bash
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Script to run remotely the tree producer."
    echo "remote usage: sosTrees_slimProd.sh <process> <condor-job-id> <condor-proc> <output-path>"
    echo " local usage: sosTrees_slimProd.sh --local <process> <output-path>"
    echo "  -h, --help: prints this help message."
    exit 0
fi

if [ "$1" == "--local" ]; then
    shift 1 #shift the "--local" arg
    CUSTOM_PS1=$PS1
    PROCESS=$1
    JOB_ID="local.test"
    OUTPUT_TREE_PATH=$EOS_USER_PATH/sostrees/${2}/$PROCESS
else
    CUSTOM_PS1="[${USER}@$(hostname)]$"
    PROCESS=$1
    JOB_ID="$2.$3"
    OUTPUT_TREE_PATH=$EOS_USER_PATH/sostrees/${4}/$PROCESS
fi

echo "-----> SOS Tree Production"

echo "-----> checking hostname..."
hostname
echo "-----> checking path..."
pwd
echo "-----> checking networking setup..."
ifconfig

echo "-----> setting up proxy and running voms-proxy-info..."
if [ -e "$AFS_HOME/x509up_u90599" ]; then
    cp -a $AFS_HOME/x509up_u90599 /tmp/x509up_u90599
else
    echo "-----> [ERROR] file $AFS_HOME/x509up_u90599 doesn't exist"; exit 1
fi
export X509_USER_PROXY=$AFS_HOME/x509up_u90599
voms-proxy-info

echo "-----> setting up cmssw env..."
if [ ! -z $SOS_80X ] || [ ! -z $EOS_USER_PATH ]; then
    cd $SOS_80X
    eval `scramv1 runtime -sh`
    echo "-----> CMSSW_VERSION = $CMSSW_VERSION"
else 
    echo "-----> [ERROR] SOS_80X or/and EOS_USER_PATH are empty variables" ; exit 2
fi
echo "-----> PWD = $(pwd)"

echo "-----> configuring according to process and running heppy tree producer..."
echo "-----> PROCESS = $PROCESS"
echo "-----> JOB_ID = $JOB_ID"

echo "-----> configuring env and files"
cd CMGTools/condor_tests && mkdir slimProd_treeProducersPerProcess
#rm -rf test && mkdir test
cp -a run_susyMultilepton_cfg_jpsi_noMetCut.py slimProd_treeProducersPerProcess/run_susyMultilepton_cfg_jpsi_noMetCut_${PROCESS}_${JOB_ID}.py
sed -r -i "s@(^selectedComponents.*)\[.*\]@\1\[${PROCESS}\]@" slimProd_treeProducersPerProcess/run_susyMultilepton_cfg_jpsi_noMetCut_${PROCESS}_${JOB_ID}.py || { echo "-----> [ERROR] sed command failed"; exit 3; }

echo "-----> delete previous trees if exist and run heppy"
[ -d "$OUTPUT_TREE_PATH" ] && rm -rf $OUTPUT_TREE_PATH
mkdir jobBase_${PROCESS}_${JOB_ID} && cd jobBase_${PROCESS}_${JOB_ID}
heppy $OUTPUT_TREE_PATH ../slimProd_treeProducersPerProcess/run_susyMultilepton_cfg_jpsi_noMetCut_${PROCESS}_${JOB_ID}.py -f -N 100000 -o test=2 -o analysis=SOS -j 8 > ../slimProd_treeProducersPerProcess/heppy.${PROCESS}_${JOB_ID}.out 2>&1 || { echo "-----> [ERROR] heppy failure"; exit 4; }

exit 0