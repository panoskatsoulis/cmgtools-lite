#author: G.Karathanasis
from CMGTools.TTHAnalysis.treeReAnalyzer import *
from CMGTools.TTHAnalysis.tools.collectionSkimmer import CollectionSkimmer
import ROOT, os
from ROOT import*
import time


ROOT.gROOT.ProcessLine(".L ../python/tools/WPolarizationVariation.C+")
ROOT.gROOT.ProcessLine(".L ../python/tools/TTbarPolarization.C+")
ROOT.gROOT.ProcessLine(".L ../python/tools/TTbarSpinCorrelation.C+")

ROOT.gSystem.Load("libFWCoreFWLite.so")
ROOT.AutoLibraryLoader.enable()


class EventVars1LWeightsForSystematics:
    def __init__(self):
          # Top related
        self.branches = [("GenTopPt","F")]
        self.branches+= [("GenAntiTopPt","F")]
        self.branches+= [("TopPtWeight","F")]
  
  
            # ISR
        self.branches+= [("ISRTTBarWeight","F")]
        self.branches+= [("ISRTTBarWeightUp","F")]
        self.branches+= [("ISRTTBarWeightDown","F")]
        self.branches+= [("ISR","F")]
        self.branches+= [( "GenGGPt","F")]
        self.branches+= [( "ISREwkCor" ,"F")]
        self.branches+= [("EWKinoSystPt","F")]
        self.branches+= [( "ISRStopCor" ,"F")] 
        self.branches+= [( "ISRStopCorUp" ,"F")]        
        self.branches+= [( "ISRStopCorDown" ,"F")] 
        self.branches+= [( "ISRStop" ,"F")]
             # W polarisation
     #   self.branches+= [( "WpolWup","F",20)]
     #   self.branches+= [("WpolWdown","F",20)]
        self.branches+= [( "WpolWup","F")]
        self.branches+= [("WpolWdown","F")]
        self.branches+= [("AntiTopCos","F")]
        self.branches+= [("TopCos","F")]
        self.branches+= [("SpinCorWeightUp","F")]
        self.branches+= [("SpinCorWeightDown","F")]
        self.branches+= [("ResZWeight","F")]              
        if "/functions_cc.so" not in ROOT.gSystem.GetLibraries(): 
            ROOT.gROOT.ProcessLine(".L %s/src/CMGTools/TTHAnalysis/python/plotter/functions.cc+" % os.environ['CMSSW_BASE']);
    def listBranches(self):
        return self.branches
    def init(self,tree):
        self._ttreereaderversion = tree._ttreereaderversion
        for P in "nGenPart",: setattr(self, P, tree.valueReader(P))
        for P in "pt", "eta", "phi", "mass","pdgId","motherId","grandmotherId","motherIndex","charge","status" : setattr(self,"GenPart_"+P, tree.arrayReader("GenPart_"+P))
        for M in "met_pt","met_phi": setattr(self, M, tree.valueReader(M))
        for L in "nLepGood",: setattr(self, L, tree.valueReader(L))
        for L in "pt","charge" : setattr(self,"LepGood_"+L, tree.arrayReader("LepGood_"+L))  
        for N in "nISR",: setattr(self, N, tree.valueReader(N))
        for CHI1 in "GenSusyMNeutralino",: setattr(self, CHI1, tree.valueReader(CHI1))
        for CHI2 in "GenSusyMNeutralino2",: setattr(self, CHI2, tree.valueReader(CHI2))
        for STOP in "GenSusyMStop",: setattr(self, STOP, tree.valueReader(STOP))
        
        

    
    def getLV(self,pt,eta,phi,mass):
      if pt!=None: return ROOT.LorentzVector(pt,eta,phi,mass)
      else: return -1
    
    def getTLV(self,p4):
       if p4 != None: return ROOT.TLorentzVector(p4.Px(),p4.Py(),p4.Pz(),p4.E())
       else: return p4

    def getZResWeight(self):
       genZ=[]
       for i in xrange(self.nGenPart.Get()[0]):
            if self.GenPart_motherId.At(i)==22 or self.GenPart_motherId.At(i)==23 : 
              genZ.append(i)
       met_pt = self.met_pt.Get()[0]
       met_phi = self.met_phi.Get()[0]
     
       if len(genZ)>0:    
          p4_z=ROOT.TLorentzVector()
          p4_z.SetPtEtaPhiM(self.GenPart_pt.At(genZ[0]),self.GenPart_eta.At(genZ[0]),self.GenPart_phi.At(genZ[0]),self.GenPart_mass.At(genZ[0]))
          return ROOT.ResolutionWeight(met_pt, met_phi,p4_z)
       else:
          return -1.
       #return -1
    def getGenWandLepton(self):
      wP4 = None
      lepP4 = None
      wP4=ROOT.TLorentzVector()
      lepP4=ROOT.TLorentzVector()
      lFromW=[]
      for i in xrange(self.nGenPart.Get()[0]):
            if abs(self.GenPart_pdgId.At(i))==13 or abs(self.GenPart_pdgId.At(i))==11 or  abs(self.GenPart_pdgId.At(i))==15: 
               if abs(self.GenPart_motherId.At(i))==24:
                   lFromW.append(i)
      if len(lFromW) == 0:
         print "no gen W found!"
         return wP4, lepP4

      elif len(lFromW)>1:
         print 'this should not have happened'
         return wP4, lepP4

      elif len(lFromW) == 1:
         genLep = lFromW[0]
         genW = self.GenPart_motherIndex.At(genLep)
         #wP4 = self.getLV(self.GenPart_pt.At(genW),self.GenPart_eta.At(genW),self.GenPart_phi.At(genW),self.GenPart_mass.At(genW))
         #lepP4 = self.getLV(self.GenPart_pt.At(genLep),self.GenPart_eta.At(genLep),self.GenPart_phi.At(genLep),self.GenPart_mass.At(genLep))

         wP4.SetPtEtaPhiM(self.GenPart_pt.At(genW),self.GenPart_eta.At(genW),self.GenPart_phi.At(genW),self.GenPart_mass.At(genW))
         lepP4.SetPtEtaPhiM(self.GenPart_pt.At(genLep),self.GenPart_eta.At(genLep),self.GenPart_phi.At(genLep),self.GenPart_mass.At(genLep))

      return wP4, lepP4

    def getGenTopWLepton(self):
      topP4 = None
      wP4 = None
      lepP4 = None
      topP4=ROOT.TLorentzVector()
      wP4=ROOT.TLorentzVector()
      lepP4=ROOT.TLorentzVector()
      lFromW=[]
      for i in xrange(self.nGenPart.Get()[0]):
            if abs(self.GenPart_pdgId.At(i))==13 or abs(self.GenPart_pdgId.At(i))==11 or  abs(self.GenPart_pdgId.At(i))==15: 
              if abs(self.GenPart_motherId.At(i))==24 and abs(self.GenPart_grandmotherId.At(i))==6 :
                      lFromW.append(i)     
      
      #print "new event",  len(lFromW)     
      if len(lFromW) == 0:
          print "no gen W found!"
          return topP4, wP4, lepP4

      elif len(lFromW) > 2:
          print "More than 2 W's found!"
          return topP4, wP4, lepP4

      elif len(lFromW) == 1:
         genLep = lFromW[0]
         genW = self.GenPart_motherIndex.At(genLep)
         genTop = self.GenPart_motherIndex.At(genW) 
         topP4.SetPtEtaPhiM(self.GenPart_pt.At(genTop),self.GenPart_eta.At(genTop),self.GenPart_phi.At(genTop),self.GenPart_mass.At(genTop))
         wP4.SetPtEtaPhiM(self.GenPart_pt.At(genW),self.GenPart_eta.At(genW),self.GenPart_phi.At(genW),self.GenPart_mass.At(genW))
         lepP4.SetPtEtaPhiM(self.GenPart_pt.At(genLep),self.GenPart_eta.At(genLep),self.GenPart_phi.At(genLep),self.GenPart_mass.At(genLep))
         return topP4, wP4, lepP4
         
      elif len(lFromW) == 2:        
          match = False
          if self.nLepGood.Get()[0] > 0:
              leadLep = self.LepGood_pt.At(0)
              for genLep in lFromW:
                 #print "new part", self.GenPart_pdgId.At(genLep)  
                 if self.LepGood_charge.At(0) == self.GenPart_charge.At(genLep):
                    match = True
                    genW = self.GenPart_motherIndex.At(genLep)
                    genTop = self.GenPart_motherIndex.At(genW) 
                    topP4.SetPtEtaPhiM(self.GenPart_pt.At(genTop),self.GenPart_eta.At(genTop),self.GenPart_phi.At(genTop),self.GenPart_mass.At(genTop))
                    wP4.SetPtEtaPhiM(self.GenPart_pt.At(genW),self.GenPart_eta.At(genW),self.GenPart_phi.At(genW),self.GenPart_mass.At(genW))
                    lepP4.SetPtEtaPhiM(self.GenPart_pt.At(genLep),self.GenPart_eta.At(genLep),self.GenPart_phi.At(genLep),self.GenPart_mass.At(genLep))
          #print "result ", topP4.Pt(),wP4.Pt(),lepP4.Pt()
          return topP4, wP4, lepP4
          if not match:
              print 'No match at all!'
              return topP4, wP4, lepP4

      return topP4, wP4, lepP4

    def getWPolWeights(self, sample):

       wUp = 1
       wDown = 1
       if "TTJets" in sample: #W polarization in TTbar
           topP4, wP4, lepP4 = self.getGenTopWLepton()          
           if topP4 != None:
              #print "top=",topP4.Px()," w=",wP4.Px()," l=",lepP4.Px()
              cosTheta = ROOT.ttbarPolarizationAngle(topP4, wP4, lepP4)
              #print "cos=",cosTheta
              wUp = (1. + 0.05*(1.-cosTheta)**2) * 1./(1.+0.05*2./3.) * (1./1.0323239521945559)
              wDown = (1. - 0.05*(1.-cosTheta)**2) * 1./(1.-0.05*2./3.) * (1.034553190276963956)
            
       elif "WJets" in sample: #W polarization in WJets
           wP4, lepP4 = self.getGenWandLepton()
           if wP4 != None:
              cosTheta = ROOT.WjetPolarizationAngle(wP4, lepP4)
              wUp = (1. + 0.1*(1.-cosTheta)**2) * 1./(1.+0.1*2./3.) * (1./1.04923678332724659)
              wDown = (1. - 0.1*(1.-cosTheta)**2) * 1./(1.-0.1*2./3.) * (1.05627060952003952)   
       return wUp, wDown

    def GenSpinCorW(self, tcos, antitcos,up_or_down): 
        f1=ROOT.TFile("../python/tools/topSpinCor.root","READ") 
        histo=TH2D()
        if up_or_down=="up": histo=f1.Get("over")
        if up_or_down=="down": histo=f1.Get("under")
        histo2=TH2D()
        histo2=f1.Get("cor")
        histo.Divide(histo2)
        xbin=histo.GetXaxis().FindBin(tcos)
        ybin=histo.GetYaxis().FindBin(antitcos)
        #xbin2=histo2.GetYaxis().FindBin(antitcos)
        #ybin=histo2.GetYaxis().FindBin(antitcos)
        return histo.GetBinContent(xbin,ybin)
   #######from here#######################################
    def __call__(self,event):
        #print os.path.basename(D)
        ## Init
        if event._tree._ttreereaderversion > self._ttreereaderversion: 
            self.init(event._tree)

        ####read C for signal ewkino ISR
        f_CandD=ROOT.TFile("../python/tools/C_factors_test.root","READ")
        hC_fc=TH2D()
        hC_fc=f_CandD.Get("hC")
        #########read D for stop signal ISR 
        hD_fc=TH2D()
        hD_fc=f_CandD.Get("hD")
        hD_up=TH2D()
        hD_up=f_CandD.Get("hD+var")
        hD_down=TH2D()
        hD_down=f_CandD.Get("hD-var")
        

        #hD_fc.Draw()
        #time.sleep(5)
        #### W polarisation
       
        run_sample= "DY"       
        wPolWup, wPolWdown = self.getWPolWeights(run_sample)
       # print wPolWup, wPolWdown
        ret={'WpolWup': wPolWup,
             'WpolWdown': wPolWdown}

        ### PDF VARS
        pdfWup= 1
        pdfWdown = 1
        pdfWcentr = 1

        ### TOP RELATED VARS
        GenTopPt = -99
        GenTopIdx = -99
        GenAntiTopPt = -99
        GenAntiTopIdx = -99
        TopPtWeight = -99.
        GenTTBarPt = -99
        GenTTBarWeight = -99.
        ISRTTBarWeight = -99.
        EWKino_syst_Pt=-99.
        ISREwkCor = -99.
        ISRStopCor=-99.
        ISRStopCorUp=-99.
        ISRStopCorDown=-99.
        TopCos = -2
        AntiTopCos = -2
        SpinCorWeightUp = -999
        SpinCorWeightDown = -999
        nGenTops = 0
        nGenWlep = 0
        ResZWeight = 1
        Stop_Idx=[]
        EWKino_Idx = []
        N1_Idx=[]
        EWKinoHiggsino_Idx=[]
        N1Higgsino_Idx=[]
        nIsr_stop=0
        lsp_mass=0
        nlsp_mass=0
        stop_mass=0
        #print "new event"
        for i_part in xrange(self.nGenPart.Get()[0]):
            if self.GenPart_pdgId.At(i_part) ==  6:
                GenTopPt = self.GenPart_pt.At(i_part)
                GenTopIdx = i_part
            if self.GenPart_pdgId.At(i_part) == -6:
                GenAntiTopPt = self.GenPart_pt.At(i_part)
                GenAntiTopIdx = i_part
            if abs(self.GenPart_pdgId.At(i_part)) ==  6: nGenTops+=1
            

            if (self.GenPart_pdgId.At(i_part) == 11 or self.GenPart_pdgId.At(i_part) == 13 or self.GenPart_pdgId.At(i_part) == 15) and  self.GenPart_motherId.At(i_part)==-24 and self.GenPart_grandmotherId.At(i_part)==-6 :
                GenLepFromAntiWIdx =  i_part
                nGenWlep+=1
           
            if (self.GenPart_pdgId.At(i_part) == -11 or self.GenPart_pdgId.At(i_part) == -13 or self.GenPart_pdgId.At(i_part) == -15) and  self.GenPart_motherId.At(i_part)==24 and  self.GenPart_grandmotherId.At(i_part)==6 :
                GenLepFromWIdx =  i_part
                nGenWlep+=1    

            if 1000022<abs(self.GenPart_pdgId.At(i_part))<1000026 or abs(self.GenPart_pdgId.At(i_part))==1000035 or abs(self.GenPart_pdgId.At(i_part))==1000037  and  self.GenPart_status.At(i_part)>1 :
                if self.GenPart_motherId.At(i_part)==-9999:
         #          print "this ",self.GenPart_motherId.At(i_part) 
                   EWKino_Idx.append(i_part)
                   nlsp_mass=self.GenSusyMNeutralino2.Get()[0]
          #  if  abs(self.GenPart_pdgId.At(i_part))>1000000: print self.GenPart_pdgId.At(i_part),"mother",self.GenPart_motherId.At(i_part),self.GenPart_pt.At(i_part),self.GenPart_status.At(i_part)
            if abs(self.GenPart_pdgId.At(i_part)) == 1000006 or abs(self.GenPart_pdgId.At(i_part)) ==2000006:
                Stop_Idx.append(i_part)
                stop_mass=self.GenSusyMStop.Get()[0]
                #print self.GenSusyMStop.Get()[0]
            if self.GenPart_pdgId.At(i_part) == 1000022:
                if self.GenPart_status.At(i_part)>1: N1_Idx.append(i_part)
                lsp_mass=self.GenSusyMNeutralino.Get()[0]
          
        #here good
        if  nGenTops==2 and nGenWlep==2:
            p4_t=ROOT.TLorentzVector()
            p4_t.SetPtEtaPhiM(self.GenPart_pt.At(GenTopIdx),self.GenPart_eta.At(GenTopIdx),self.GenPart_phi.At(GenTopIdx),self.GenPart_mass.At(GenTopIdx))
            p4_lepw=ROOT.TLorentzVector()
            p4_lepw.SetPtEtaPhiM(self.GenPart_pt.At(GenLepFromWIdx),self.GenPart_eta.At(GenLepFromWIdx),self.GenPart_phi.At(GenLepFromWIdx),self.GenPart_mass.At(GenLepFromWIdx))
            p4_tb=ROOT.TLorentzVector()
            p4_tb.SetPtEtaPhiM(self.GenPart_pt.At(GenAntiTopIdx),self.GenPart_eta.At(GenAntiTopIdx),self.GenPart_phi.At(GenAntiTopIdx),self.GenPart_mass.At(GenAntiTopIdx))
            p4_lepwb=ROOT.TLorentzVector()
            p4_lepwb.SetPtEtaPhiM(self.GenPart_pt.At(GenLepFromAntiWIdx),self.GenPart_eta.At(GenLepFromAntiWIdx),self.GenPart_phi.At(GenLepFromAntiWIdx),self.GenPart_mass.At(GenLepFromAntiWIdx))
            TopCos =   ROOT.ttbarCorellationAngle(p4_t,p4_lepw)
            AntiTopCos =   ROOT.ttbarCorellationAngle(p4_tb,p4_lepwb)
            #print TopCos, AntiTopCos
            SpinCorWeightUp = self.GenSpinCorW(TopCos,AntiTopCos,"up")
            SpinCorWeightDown = self.GenSpinCorW(TopCos,AntiTopCos,"down")


##########ISR EWKINO
        #print "number of N1 (not final)",len(N1_Idx),"number of EWKino ",len(EWKino_Idx)
       # print "at=",GenAntiTopIdx, " aw=",GenLepFromAntiWIdx," cos=", TopCos, "
        if (len(EWKino_Idx)==2 or (len(EWKino_Idx)==1 and len(N1_Idx)==1)):
       # if len(EWKino_Idx)==1 and len(LSP_Idx)==3:
            C_const=1.0
            biny=nlsp_mass/25-3
            binx=(nlsp_mass-lsp_mass)/10
           # print lsp_mass,nlsp_mass,binx,biny
       #     C_const=hC_fc.GetBinContent(binx,biny)
            fh=open("../python/tools/TChiWZ_normalization.txt","r")
            data=fh.readlines()
            words=[]
            for line in data:
              words=line.split()
              values=words[0].split("_")
              nlsp_bench=int(values[1])
              lsp_bench=int(values[2])
              if nlsp_bench==nlsp_mass and lsp_bench==lsp_mass:C_const=float(words[2])
            
            #print C_const
            if len(EWKino_Idx)==2: EWKino_syst_Pt =self.GenPart_pt.At(EWKino_Idx[0]) +self.GenPart_pt.At(EWKino_Idx[1])
            else :  EWKino_syst_Pt =self.GenPart_pt.At(EWKino_Idx[0])++self.GenPart_pt.At(N1_Idx[0])
            if  EWKino_syst_Pt<50: ISREwkCor=1.0
            elif  EWKino_syst_Pt>50 and EWKino_syst_Pt<100: ISREwkCor=1.052
            elif  EWKino_syst_Pt>100 and EWKino_syst_Pt<150: ISREwkCor=1.179
            elif  EWKino_syst_Pt>150 and EWKino_syst_Pt<200: ISREwkCor=1.150
            elif  EWKino_syst_Pt>200 and EWKino_syst_Pt<300: ISREwkCor=1.057
            elif  EWKino_syst_Pt>300 and EWKino_syst_Pt<400: ISREwkCor=1.0
            elif  EWKino_syst_Pt>400 and EWKino_syst_Pt<600: ISREwkCor=0.912
            else: ISREwkCor=0.783
            ISREwkCor=ISREwkCor*C_const
        #if ISREwkCor<-50: print "here ",EWKino_Idx,N1_Idx
        if len(Stop_Idx)==2:
           nIsr_stop2=0    
           nIsr_stop=self.nISR.Get()[0]
           nIsr_stop2=nIsr_stop
           if nIsr_stop2>6: nIsr_stop2=6
           D_const=1
           biny=stop_mass/25-9
           binx=(stop_mass-lsp_mass)/10
           D_const=hD_fc.GetBinContent(binx,biny)
           D_constUp=hD_up.GetBinContent(binx,biny)
           D_constDown=hD_down.GetBinContent(binx,biny)
           #D_const=1.13973#1.18061#1.13973 #skim unskim
           #D_constUp=1.06516#1.0826#1.06516
           #D_constDown=1.22553#1.29813#1.22553
           #print "stop=",stop_mass," lsp_mass=",lsp_mass,binx,biny
           ISRweights = { 0: 1, 1 : 0.920, 2 : 0.821, 3 : 0.715, 4 : 0.662, 5 : 0.561, 6 : 0.511}
           ISRweightssyst = { 0: 0.0, 1 : 0.040, 2 : 0.090, 3 : 0.143, 4 : 0.169, 5 : 0.219, 6 : 0.244}
           ISRStopCor=D_const*ISRweights[nIsr_stop2]
           ISRStopCorUp=D_constUp*(ISRweights[nIsr_stop2]+ISRweightssyst[nIsr_stop2])
           ISRStopCorDown=D_constDown*(ISRweights[nIsr_stop2]-ISRweightssyst[nIsr_stop2])
       

        #here good   
        nIsr=0
        ISRTTBarWeight=0
        ISRTTBarWeightUp=0
        ISRTTBarWeightDown=0
        if GenTopPt!=-999 and GenAntiTopPt!=-999 and nGenTops==2:
            SFTop     = exp(0.0615    -0.0005*GenTopPt    )
            SFAntiTop = exp(0.0615    -0.0005*GenAntiTopPt)
            TopPtWeight = sqrt(SFTop*SFAntiTop)
            if TopPtWeight<0.5: TopPtWeight=0.5
            nIsr=self.nISR.Get()[0]
            nIsr2=nIsr
            if nIsr2>6: nIsr2=6
            ISRweights = { 0: 1, 1 : 0.920, 2 : 0.821, 3 : 0.715, 4 : 0.662, 5 : 0.561, 6 : 0.511}
            ISRweightssyst = { 0: 0.0, 1 : 0.040, 2 : 0.090, 3 : 0.143, 4 : 0.169, 5 : 0.219, 6 : 0.244}
            C_ISR= 1.116#14% larger than real value
            C_Up= 1.055
            C_Down= 1.185
            ISRTTBarWeight=C_ISR * ISRweights[nIsr2]
            ISRTTBarWeightUp=C_Up * (ISRweights[nIsr2]+ISRweightssyst[nIsr2])
            ISRTTBarWeightDown=C_Down * (ISRweights[nIsr2]-ISRweightssyst[nIsr2])
           
            
            
     
     #    if  nGenTops==2 and 

        ResZWeight = self.getZResWeight()

        ####################################
        ### For DiLepton systematics
        # values in sync with AN2015_207_v3
        #        Const weight
        # const: 0.85 +-0.06
        #        16%
        wmean = 5.82 - 0.5
        # slope: 0.03 +/-0.05
        slopevariation = sqrt(0.03*0.03 +0.05*0.05)

        '''if "nJets30Clean" in base: nJets30Clean = base["nJets30Clean"]
        else: nJets30Clean = event.nJet

        if (event.ngenLep+event.ngenTau)==2:
            ret['DilepNJetWeightConstUp'] = 0.84
            ret['DilepNJetWeightSlopeUp'] = 1+ (nJets30Clean-wmean)*slopevariation
            ret['DilepNJetWeightConstDn'] = 1.16
            ret['DilepNJetWeightSlopeDn'] = 1- (nJets30Clean-wmean)*slopevariation
        else:
            ret['DilepNJetWeightConstUp'] = 1.
            ret['DilepNJetWeightSlopeUp'] = 1.
            ret['DilepNJetWeightConstDn'] = 1.
            ret['DilepNJetWeightSlopeDn'] = 1.'''


        ret['GenTopPt'] = GenTopPt
        ret['GenAntiTopPt'] = GenAntiTopPt
        ret['TopPtWeight']  = TopPtWeight 
        ret['ISR']=nIsr     
        ret['ISRTTBarWeight' ]  = ISRTTBarWeight
        ret['ISRTTBarWeightUp' ]  = ISRTTBarWeightUp
        ret['ISRTTBarWeightDown' ]  = ISRTTBarWeightDown
        ret['EWKinoSystPt'] =   EWKino_syst_Pt
        ret['ISREwkCor' ]  = ISREwkCor
        ret['ISRStop']=nIsr_stop
        ret['ISRStopCor']=ISRStopCor
        ret['ISRStopCorUp']=ISRStopCorUp
        ret['ISRStopCorDown']=ISRStopCorDown
        ret['AntiTopCos'] = AntiTopCos
        ret['TopCos'] = TopCos
        ret['SpinCorWeightUp'] = SpinCorWeightUp
        ret['SpinCorWeightDown'] = SpinCorWeightDown
        ret['ResZWeight'] = ResZWeight

        return ret

MODULES = [
('systematics', lambda :  EventVars1LWeightsForSystematics()),
]


