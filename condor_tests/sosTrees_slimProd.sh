#!/bin/bash
CUSTOM_PS1="[${USER}@$(hostname)]$"
PROCESS=$1
JOB_ID="$2.$3"
OUTPUT_PATH=$EOS_USER_PATH/sostrees/2016_94X

echo "-----> SOS tree Slim Production"

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
if [ ! -z $SOS_94X ] || [ ! -z $EOS_USER_PATH ]; then
    cd $SOS_94X
    eval `scramv1 runtime -sh`
    echo "-----> CMSSW_VERSION = $CMSSW_VERSION"
else 
    echo "-----> [ERROR] SOS_94X or/and EOS_USER_PATH are empty variables" ; exit 2
fi
echo "-----> PWD = $(pwd)"

echo "-----> configuring according to process and running heppy tree producer..."
echo "-----> PROCESS = $PROCESS"
echo "-----> JOB_ID = $JOB_ID"
echo "-----> OUTPUT_PATH = $OUTPUT_PATH"

echo "-----> configuring env and files"
cd CMGTools/condor_tests && mkdir slimProd_treeProducersPerProcess
#rm -rf test && mkdir test
cp -a run_susySOS_cfg_slimProd.py slimProd_treeProducersPerProcess/run_susySOS_cfg_slimProd_${PROCESS}_${JOB_ID}.py
sed -r -i "s@(^process = )\[.*\]@\1\[${PROCESS}\]@" slimProd_treeProducersPerProcess/run_susySOS_cfg_slimProd_${PROCESS}_${JOB_ID}.py || { echo "-----> [ERROR] sed command failed"; exit 3; }

echo "-----> delete previous trees if exist and run heppy"
[ -d "$OUTPUT_PATH/$PROCESS" ] && rm -rf $OUTPUT_PATH/$PROCESS
heppy $OUTPUT_PATH slimProd_treeProducersPerProcess/run_susySOS_cfg_slimProd_${PROCESS}_${JOB_ID}.py -f -N 10000 -o test=2 -j 4 > slimProd_treeProducersPerProcess/heppy.${PROCESS}_${JOB_ID}.out 2>&1 || { echo "-----> [ERROR] heppy failure"; exit 4; }

exit 0
