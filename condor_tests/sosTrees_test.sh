#!/bin/bash
CUSTOM_PS1="[${USER}@$(hostname)]$"

echo "-----> Test SOS tree production"

echo "-----> checking hostname..."
hostname
echo "-----> checking path..."
pwd
echo "-----> checking networking setup..."
ifconfig

echo "-----> setting up proxy and running voms-proxy-info..."
cp -a $AFS_HOME/x509up_u90599 /tmp/x509up_u90599
export X509_USER_PROXY=$AFS_HOME/x509up_u90599
voms-proxy-info

echo "-----> setting up cmssw env..."
if [ ! -z $SOS_80X ] || [ ! -z $EOS_USER_PATH ]; then
    cd $SOS_80X
    eval `scramv1 runtime -sh`
    echo "-----> CMSSW_VERSION = $CMSSW_VERSION"
else 
    echo "-----> [ERROR] SOS_80X or/and EOS_USER_PATH are empty variables"
    exit 1
fi
echo "-----> PWD = $(pwd)"

echo "-----> running heppy tree producer..."
echo "$CUSTOM_PS1 which heppy" && which heppy
heppy $EOS_USER_PATH/sostrees CMGTools/condor_tests/run_susyMultilepton_cfg_EOSCondortest.py -f -N 1000 -o test=2 -o analysis=SOS > CMGTools/condor_tests/output/heppy.out 2>&1

exit 0