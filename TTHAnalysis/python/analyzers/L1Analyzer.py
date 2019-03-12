#module to add L1 quantities in CMG
#orig author: g karathanasis (georgios.karathanasis@cern)
#modified by p katsoulis (panos.katsoulis@cern.ch)
from PhysicsTools.Heppy.analyzers.core.Analyzer import Analyzer
from PhysicsTools.Heppy.analyzers.core.AutoHandle import AutoHandle
#from PhysicsTools.HeppyCore.utils.deltar import deltaR, deltaPhi
#from PhysicsTools.Heppy.physicsutils.genutils import *


'''
class L1Particle(object):
     pt=0
     eta=0
     phi=0
     mass=0
     def __init__(self,pt,eta,phi,mass):
        self.pt=pt
        self.eta=eta
        self.phi=phi
        self.mass=mass
'''


class L1Analyzer( Analyzer ):

    def __init__(self, cfg_ana, cfg_comp, looperName):
        super(L1Analyzer,self).__init__(cfg_ana,cfg_comp,looperName)


    def fixBXVector(self, bxVec):
        if bxVec.getFirstBX()==0 and bxVec.getLastBX()==0:
            return
        else:
            for bx in [-2,-1,1,2]:
                if not bxVec.isEmpty(bx):
                    bxVec.deleteBX(bx)


    #---------------------------------------------
    # DECLARATION OF HANDLES OF LEVEL1 OBJECTS 
    #---------------------------------------------
    def declareHandles(self):
        super(L1Analyzer, self).declareHandles()
        self.handles['l1muons'] = AutoHandle( ('gmtStage2Digis','Muon'), 'BXVector<l1t::Muon>' )
        self.handles['l1jets'] = AutoHandle( ('caloStage2Digis','Jet'), 'BXVector<l1t::Jet>')
        self.handles['l1met'] = AutoHandle( ('caloStage2Digis','EtSum'), 'BXVector<l1t::EtSum>' )
        self.handles['l1eg'] = AutoHandle( ('caloStage2Digis','EGamma'), 'BXVector<l1t::EGamma>' )


    def beginLoop(self, setup):
        super(L1Analyzer,self).beginLoop(setup)


    def doLeptons(self,event):
        l1muons=self.handles['l1muons'].product()
        self.fixBXVector(l1muons)
        event.L1muons = l1muons.size(0)
        event.L1muon=[]

        for mu in l1muons:
            event.L1muon.append(mu)       

        event.L1muon.sort(key=lambda mu: mu.pt(), reverse=True)


    def doJets(self,event):
         l1jets=self.handles['l1jets'].product()
         self.fixBXVector(l1jets)
         event.L1jets = l1jets.size(0)
         event.L1jet=[]       

         for jet in l1jets:
                 event.L1jet.append(jet)

         event.L1jet.sort(key=lambda jet: jet.pt(), reverse=True)
 

    def doEG(self,event):
         l1egs=self.handles['l1eg'].product() 
         self.fixBXVector(l1egs)
         event.L1egs = l1egs.size(0)
         event.L1eg=[]

         for eg in l1egs:
              event.L1eg.append(eg)

         event.L1eg.sort(key=lambda eg: eg.pt(), reverse=True)


    def doMET(self,event):
        if not self.cfg_comp.isMC:
            return
        l1met_objs = self.handles['l1met'].product()
        self.fixBXVector(l1met_objs)
        event.L1met = -1
        event.L1met_phi = -999

        for met in l1met_objs:
            if met.getType()=='kMissingEtHF':
                event.L1met = met.pt()
                event.L1met_phi = met.phi()
                break


    def process(self, event):
        self.readCollections( event.input )        
        self.doLeptons(event) # registers in event L1muon list and L1muons variable
        self.doEG(event) # registers in event L1eg list and L1egs variable
        self.doJets(event) # registers in event L1jet list and L1jets variable
        self.doMET(event) # registers in event L1met and L1met_phi variables
        # print("-----> Muons = "+str(event.L1muons))
        # print("-----> Jets = "+str(event.L1jets))
        # print("-----> l1_hiPtMuon_Pt = "+str(event.L1muon[0].pt()))
        # print("-----> l1_hiPtJet_Pt = "+str(event.L1jet[0].pt()))
        # print("-----> l1MET = "+str(event.L1met))
        return True
