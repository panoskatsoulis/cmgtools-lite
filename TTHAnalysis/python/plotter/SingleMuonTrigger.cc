
void SingleMuonTrigger() {}

bool SignleSoftMuon(int l1Muons, float l1Muon1Pt, float l1Muon1Eta,
		    int l1Jets,  float l1Jet1Pt, float l1Jet1Eta, float l1Met) {

  return (l1Muons >= 1 && l1Muon1Pt > 3 && abs(l1Muon1Eta) < 1.5
	  && l1Jets >= 1 && l1Jet1Pt > 100 && abs(l1Jet1Eta) < 2.5
	  && l1Met > 40) ? true : false ;
}
