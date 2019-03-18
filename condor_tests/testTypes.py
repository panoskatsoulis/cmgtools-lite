import itertools
from CMGTools.RootTools.samples.triggers_13TeV_DATA2016 import *
from CMGTools.RootTools.samples.samples_13TeV_RunIISummer16MiniAODv2 import *
from CMGTools.RootTools.samples.samples_13TeV_signals import *
from CMGTools.RootTools.samples.samples_13TeV_80X_susySignalsPriv import *
from CMGTools.RootTools.samples.samples_13TeV_DATA2016 import *

typelist = []
processlist = [
  SMS_TChiWZ,
  TTJets_DiLepton,
  TTJets_DiLepton_ext,
  TBar_tWch_ext,
  T_tWch_ext,
  DYJetsM5to50HT,
  DYJetsM50HT,
  TTJets_SingleLeptonFromTbar,
  TTJets_SingleLeptonFromT,
  WJetsToLNuHT,
  VVTo2L2Nu,
  VVTo2L2Nu_ext
]

processlist_str = [
  'SMS_TChiWZ',
  'TTJets_DiLepton',
  'TTJets_DiLepton_ext',
  'TBar_tWch_ext',
  'T_tWch_ext',
  'DYJetsM5to50HT',
  'DYJetsM50HT',
  'TTJets_SingleLeptonFromTbar',
  'TTJets_SingleLeptonFromT',
  'WJetsToLNuHT',
  'VVTo2L2Nu',
  'VVTo2L2Nu_ext'
]

for process in processlist:
    typelist.append(type(process))

for process, type_ in zip(processlist_str, typelist):
    print('-----> {} is type {}'.format(process, type_))
