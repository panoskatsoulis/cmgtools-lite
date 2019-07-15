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

class GenPart:
    def __init__(self, part, copy):
        self.pdgId = part.pdgId()
        self.pt = part.pt()
        self.eta = part.eta()
        self.phi = part.phi()
        self.mass = part.mass()
        if copy is "last":
            self.daughters = [part.daughter(i).pdgId() for i in range(0,part.numberOfDaughters()-1)] ## here saves a list of part's daughters
            mother = part.mother()
            if not mother: self.mother = 0; return # if mother is a null ref, mom is 0 and return
            while mother == part.pdgId():
                mother = mother.mother()
                if not mother: self.mother = 0; return
            self.mother = mother.pdgId()
        elif copy is "first":
            if not part.mother() or part.mother().pdgId() == part.pdgId(): # if not the same particle and the reference exists
                self.mother = 0
            else:
                self.mother = part.mother().pdgId()

class Analyzer_GEN_L1( Analyzer ):
    """
      
    """
    def __init__(self, cfg_ana, cfg_comp, looperName ):
        super(Analyzer_GEN_L1, self).__init__(cfg_ana,cfg_comp,looperName)


    #---------------------------------------------
    # DECLARATION OF HANDLES OF LEVEL1 OBJECTS 
    #---------------------------------------------
    def declareHandles(self):
        super(Analyzer_GEN_L1, self).declareHandles()
        # GEN
        self.handles['genParts'] = AutoHandle( 'prunedGenParticles', 'std::vector<reco::GenParticle>' )
        # L1
        self.handles['l1muons'] = AutoHandle( ('gmtStage2Digis','Muon'), 'BXVector<l1t::Muon>' )
        self.handles['l1jets'] = AutoHandle( ('caloStage2Digis','Jet'), 'BXVector<l1t::Jet>')
        self.handles['l1met'] = AutoHandle( ('caloStage2Digis','EtSum'), 'BXVector<l1t::EtSum>' )
        self.handles['l1eg'] = AutoHandle( ('caloStage2Digis','EGamma'), 'BXVector<l1t::EGamma>' )

    def beginLoop(self, setup):
        super(Analyzer_GEN_L1, self).beginLoop(setup)

    def doGenParts(self, event):
        genParts = self.handles['genParts'].product()
        GENParticles = []
        for part in genParts:
            # if part.isLastCopy():
            #     GENParticles.append(GenPart(part,"last")) ## here creates a GenPart and running __init__ before be appended to the list
            if part.statusFlags().isFirstCopy():
                GENParticles.append(GenPart(part,"first"))

        GENParticles.sort(key=lambda part: part.pt, reverse=True)
        event.genPdgIds = [part.pdgId for part in GENParticles]
        # event.genDaughters = [part.daughters for part in GENParticles]
        event.genMothers = [part.mother for part in GENParticles]
        event.genPts = [part.pt for part in GENParticles]
        event.genEtas = [part.eta for part in GENParticles]
        event.genPhis = [part.phi for part in GENParticles]
        event.genMasses = [part.mass for part in GENParticles]


    def doLeptons(self,event):
        event.L1muons = 0
        event.L1muon=[]
        l1=self.handles['l1muons'].product()

        for l in range(0,l1.size(0)):
              mu=l1.at(0,l)               
              event.L1muons +=1 
              event.L1muon.append(mu)       

        event.L1muon.sort(key=lambda mu: mu.pt(), reverse=True)


    def doJets(self,event):
         event.L1jets = 0
         event.L1jet=[]       
         l1=self.handles['l1jets'].product()
         for j in range(0,l1.size(0)):
              jet=l1.at(0,j) 
              event.L1jet.append(jet)
              event.L1jets+=1

         event.L1jet.sort(key=lambda jet: jet.pt(), reverse=True)
 

    def doEG(self,event):
         event.L1egs = 0
         event.L1eg=[]
         l1=self.handles['l1eg'].product() 
         for e in range(0,l1.size(0)):
              eg=l1.at(0,e)
              event.L1eg.append(eg)
              event.L1egs+=1

         event.L1eg.sort(key=lambda eg: eg.pt(), reverse=True)


    def doMET(self,event):
          event.L1met = -1
          event.L1met_phi = -999
          if self.cfg_comp.isMC:
            for m in self.handles['l1met'].product():
               if m.getType()=='kMissingEtHF': 
                    event.L1met =l1met.pt()
                    event.L1met_phi =l1met.phi()
          else:
           l1met=[]
           l1metphi=[]
           for m in self.handles['l1met'].product():
               if m.getType()=='kMissingEtHF':
                    l1met =l1met.pt()
                    l1met_phi =l1met.phi()       
           event.L1met =l1met[2]
           event.L1met_phi =l1met_phi[2]
          

    def process(self, event):
        self.readCollections( event.input )        
        # self.doLeptons(event) # registers in event L1muon list and L1muons variable
        # self.doEG(event) # registers in event L1eg list and L1egs variable
        # self.doJets(event) # registers in event L1jet list and L1jets variable
        # self.doMET(event) # registers in event L1met and L1met_phi variables
        self.doGenParts(event) # registers in event the list GENParticles
        return True
