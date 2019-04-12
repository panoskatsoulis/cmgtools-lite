#####COMPONENT CREATOR
from CMGTools.RootTools.samples.ComponentCreator import ComponentCreator
kreator = ComponentCreator()

samples = []
ZToJPsiMuMu = kreator.makeMCComponent("ZToJPsiMuMu", "/ZToJPsiMuMu_TuneCUEP8M1_13TeV-pythia8/RunIISummer16MiniAODv2-PUMoriond17_80X_mcRun2_asymptotic_2016_TrancheIV_v6-v1/MINIAODSIM", "CMS", ".*root")
samples.append(ZToJPsiMuMu)
JPsiToMuMu = kreator.makeMCComponent("JPsiToMuMu", "/JPsiToMuMu_Pt20to100-pythia8-gun/RunIISummer16MiniAODv2-PUMoriond17RAW_80X_mcRun2_asymptotic_2016_TrancheIV_v6-v1/MINIAODSIM", "CMS", ".*root")
samples.append(JPsiToMuMu)
JPsiToMuMu_OniaMuonFilter = kreator.makeMCComponent("JPsiToMuMu_OniaMuonFilter", "/JpsiToMuMu_OniaMuonFilter_TuneCUEP8M1_13TeV-pythia8/RunIISummer16MiniAODv2-PUMoriond17_80X_mcRun2_asymptotic_2016_TrancheIV_v6-v1/MINIAODSIM", "CMS", ".*root")
samples.append(JPsiToMuMu_OniaMuonFilter)
JPsiToMuMu_JPsiPt8 = kreator.makeMCComponent("JPsiToMuMu_JPsiPt8", "/JpsiToMuMu_JpsiPt8_TuneCUEP8M1_13TeV-pythia8/RunIISummer16MiniAODv2-PUMoriond17_80X_mcRun2_asymptotic_2016_TrancheIV_v6-v1/MINIAODSIM", "CMS", ".*root")
samples.append(JPsiToMuMu_JPsiPt8)

# ---------------------------------------------------------------------                                                                                                                                          

#from CMGTools.TTHAnalysis.setup.Efficiencies import *
#dataDir = "$CMSSW_BASE/src/CMGTools/TTHAnalysis/data"

#Define splitting
for comp in samples:
    comp.isMC = True
    comp.isData = False
    comp.splitFactor = 250
#    comp.efficiency = eff2012

if __name__ == "__main__":
    from CMGTools.RootTools.samples.tools import runMain
    runMain(samples)

