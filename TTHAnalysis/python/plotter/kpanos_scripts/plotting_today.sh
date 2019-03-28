#!/bin/bash

DATE=$(date | sed -r 's@^(.* .* .*) .* .* (.*)$@\1_\2@' | tr ' ' '-')

MCPLOTS_COMAND="python mcPlots.py susy-sos-v1/2l/mca_sos_2016.txt susy-sos-v1/2l/cuts_sos_2016.txt susy-sos-v1/2l/plots_sos_kpanos.txt -P /eos/user/k/kpanos/sostrees/test_80X --s2v --tree treeProducerSusyMultilepton -uf --cmsprel Preliminary --legendWidth 0.20 --legendFontSize 0.02 --mcc susy-sos-v1/mcc_triggerdefs.txt --mcc susy-sos-v1/2l/mcc2016/mcc_2l.txt --mcc susy-sos-v1/mcc_sos.txt --mcc susy-sos-v1/2l/mcc2016/mcc_sf_met125.txt --mcc susy-sos-v1/2l/mcc2016/mcc_sf_fakes_2losEwkLow.txt --load-macro susy-sos-v1/functionsSOS.cc --load-macro susy-sos-v1/functionsSF.cc --load-macro susy-sos-v1/functionsPUW.cc -F sf/t /eos/user/k/kpanos/sostrees/test_80X/0_both3dlooseClean/evVarFriend_{cname}.root --print png,txt --neg --legendHeader Datasets -j 8"

PLOT_bothInverted=false
PLOT_BVetoInverted=false
PLOT_IsrIdInverted=false
PLOT_BVetoAdded=false
PLOT_IsrIdAdded=false
PLOT_BothAdded=false
PLOT_HighMET16_Incl=true

## JPsi Mass Investigation
OUTNAME="analysis_JPsiDATA_RestCutsInvestigation_applied="

$PLOT_bothInverted && {
    echo "Now plotting bothInverted.";
    $MCPLOTS_COMAND --pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}invertedBVeto+invertedIsrId \
	-p prompt_tt -p prompt_dy -p jpsi -p Zjpsi -p data \
	-E 'ewk_.*' \
	-E 'met125_.*' \
	-R 'lepRel_mll' 'lepRel_mll' 'm2l<50' \
	-X 'lepRel_upsilonVeto' \
	-X '^evRel_.*' \
	-X 'met125_met' \
	-A 'met125_trig' 'METoverHT' '(met_pt/(htJet25-LepGood1_pt-LepGood2_pt))>(2/3) && (met_pt/(htJet25-LepGood1_pt-LepGood2_pt)) < 1.4' \
	-A 'met125_trig' 'MET' 'met_pt>125 && metmm_pt(LepGood1_pdgId, LepGood1_pt, LepGood1_phi, LepGood2_pdgId, LepGood2_pt, LepGood2_phi, met_pt, met_phi) > 125' \
	-A 'met125_trig' 'HT' '(htJet25-LepGood1_pt-LepGood2_pt) > 100' \
	-A 'met125_trig' 'bveto' 'nBJetLoose25 != 0' \
	-A 'met125_trig' 'ISRjet' 'Jet1_id != 5' || { echo "Error"; exit 1; };
    echo "Finished";
}

$PLOT_BVetoInverted && {
    echo "Now plotting BVetoInverted";
    $MCPLOTS_COMAND --pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}invertedBVeto \
	-p prompt_tt -p prompt_dy -p jpsi -p Zjpsi -p data \
	-E 'ewk_.*' \
	-E 'met125_.*' \
	-R 'lepRel_mll' 'lepRel_mll' 'm2l<50' \
	-X 'lepRel_upsilonVeto' \
	-X '^evRel_.*' \
	-X 'met125_met' \
	-A 'met125_trig' 'METoverHT' '(met_pt/(htJet25-LepGood1_pt-LepGood2_pt))>(2/3) && (met_pt/(htJet25-LepGood1_pt-LepGood2_pt)) < 1.4' \
	-A 'met125_trig' 'MET' 'met_pt>125 && metmm_pt(LepGood1_pdgId, LepGood1_pt, LepGood1_phi, LepGood2_pdgId, LepGood2_pt, LepGood2_phi, met_pt, met_phi) > 125' \
	-A 'met125_trig' 'HT' '(htJet25-LepGood1_pt-LepGood2_pt) > 100' \
	-A 'met125_trig' 'bveto' 'nBJetLoose25 != 0' || { echo "Error"; exit 2; };
    echo "Finished";
}

$PLOT_IsrIdInverted && {
    echo "Now plotting IsrIdInverted";
    $MCPLOTS_COMAND --pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}invertedIsrId \
	-p prompt_tt -p prompt_dy -p jpsi -p Zjpsi -p data \
	-E 'ewk_.*' \
	-E 'met125_.*' \
	-R 'lepRel_mll' 'lepRel_mll' 'm2l<50' \
	-X 'lepRel_upsilonVeto' \
	-X '^evRel_.*' \
	-X 'met125_met' \
	-A 'met125_trig' 'METoverHT' '(met_pt/(htJet25-LepGood1_pt-LepGood2_pt))>(2/3) && (met_pt/(htJet25-LepGood1_pt-LepGood2_pt)) < 1.4' \
	-A 'met125_trig' 'MET' 'met_pt>125 && metmm_pt(LepGood1_pdgId, LepGood1_pt, LepGood1_phi, LepGood2_pdgId, LepGood2_pt, LepGood2_phi, met_pt, met_phi) > 125' \
	-A 'met125_trig' 'HT' '(htJet25-LepGood1_pt-LepGood2_pt) > 100' \
	-A 'met125_trig' 'ISRjet' 'Jet1_id != 5' || { echo "Error";  exit 3; };
    echo "Finished";
}

$PLOT_BVetoAdded && {
    echo "Now plotting BVetoAdded";
    $MCPLOTS_COMAND --pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}afterMETandHTCuts+addedBVeto \
	-p prompt_tt -p prompt_dy -p jpsi -p Zjpsi -p data \
	-E 'ewk_.*' \
	-E 'met125_.*' \
	-R 'lepRel_mll' 'lepRel_mll' 'm2l<50' \
	-X 'lepRel_upsilonVeto' \
	-X '^evRel_.*' \
	-X 'met125_met' \
	-A 'met125_trig' 'METoverHT' '(met_pt/(htJet25-LepGood1_pt-LepGood2_pt))>(2/3) && (met_pt/(htJet25-LepGood1_pt-LepGood2_pt)) < 1.4' \
	-A 'met125_trig' 'MET' 'met_pt>125 && metmm_pt(LepGood1_pdgId, LepGood1_pt, LepGood1_phi, LepGood2_pdgId, LepGood2_pt, LepGood2_phi, met_pt, met_phi) > 125' \
	-A 'met125_trig' 'HT' '(htJet25-LepGood1_pt-LepGood2_pt) > 100' \
	-A 'met125_trig' 'bveto' 'nBJetLoose25 == 0' || { echo "Error"; exit 11; };
    echo "Finished";
}

$PLOT_IsrIdAdded && {
    echo "Now plotting IsrIdAdded";
    $MCPLOTS_COMAND --pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}afterMETandHTCuts+addedIsrId \
	-p prompt_tt -p prompt_dy -p jpsi -p Zjpsi -p data \
	-E 'ewk_.*' \
	-E 'met125_.*' \
	-R 'lepRel_mll' 'lepRel_mll' 'm2l<50' \
	-X 'lepRel_upsilonVeto' \
	-X '^evRel_.*' \
	-X 'met125_met' \
	-A 'met125_trig' 'METoverHT' '(met_pt/(htJet25-LepGood1_pt-LepGood2_pt))>(2/3) && (met_pt/(htJet25-LepGood1_pt-LepGood2_pt)) < 1.4' \
	-A 'met125_trig' 'MET' 'met_pt>125 && metmm_pt(LepGood1_pdgId, LepGood1_pt, LepGood1_phi, LepGood2_pdgId, LepGood2_pt, LepGood2_phi, met_pt, met_phi) > 125' \
	-A 'met125_trig' 'HT' '(htJet25-LepGood1_pt-LepGood2_pt) > 100' \
	-A 'met125_trig' 'bveto' 'nBJetLoose25 == 0' \
	-A 'met125_trig' 'ISRjet' 'Jet1_id == 5' || { echo "Error";  exit 12; };
    echo "Finished";
}

$PLOT_BothAdded && {
    echo "Now plotting IsrIdAdded";
    $MCPLOTS_COMAND --pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}afterMETandHTCuts+addedBVeto+addedIsrId \
	-p prompt_tt -p prompt_dy -p jpsi -p Zjpsi -p data \
	-E 'ewk_.*' \
	-E 'met125_.*' \
	-R 'lepRel_mll' 'lepRel_mll' 'm2l<50' \
	-X 'lepRel_upsilonVeto' \
	-X '^evRel_.*' \
	-X 'met125_met' \
	-A 'met125_trig' 'METoverHT' '(met_pt/(htJet25-LepGood1_pt-LepGood2_pt))>(2/3) && (met_pt/(htJet25-LepGood1_pt-LepGood2_pt)) < 1.4' \
	-A 'met125_trig' 'MET' 'met_pt>125 && metmm_pt(LepGood1_pdgId, LepGood1_pt, LepGood1_phi, LepGood2_pdgId, LepGood2_pt, LepGood2_phi, met_pt, met_phi) > 125' \
	-A 'met125_trig' 'HT' '(htJet25-LepGood1_pt-LepGood2_pt) > 100' \
	-A 'met125_trig' 'bveto' 'nBJetLoose25 == 0' \
	-A 'met125_trig' 'ISRjet' 'Jet1_id == 5' || { echo "Error";  exit 13; };
    echo "Finished";
}

## HighMET16 Inclusive (MET bin 200-inf)
OUTNAME="analysis_HighMET16_Inclusive"

$PLOT_HighMET16_Incl && {
    echo "Now plotting HighMET16_Incl";
    $MCPLOTS_COMAND --pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME} \
	-p prompt_tt -p prompt_dy -p jpsi -p Zjpsi -p data \
	-E 'ewk_.*' \
	-E 'ewk200_.*' \
	-R 'lepRel_mll' 'lepRel_mll' 'm2l<50' \
	-X 'lepRel_upsilonVeto' \
	-X 'ewk200_met2' || { echo "Error";  exit 4; };
    echo "Finished";
}


## figure-of-merit test

exit 0