#!/bin/bash

[ -e plotting_today.log ] && rm -f plotting_today.log
DATE=$(date | sed -r 's@^(.* .* .*) .* .* (.*)$@\1_\2@' | tr ' ' '-' | sed -r 's@\-{2,}@\-@')

## Input root files
TREES_PATH="/eos/user/k/kpanos/sostrees/2016_80X"
REMOTE_PATH=""
INPUT_FTREES="-F sf/t /eos/user/k/kpanos/sostrees/2016_80X/0_both3dlooseClean_v2/evVarFriend_{cname}.root"
OUTPUT_DIR="/eos/user/k/kpanos/www/SOS/tests/${DATE}"

#WEIGHTS="--alias wBG puw_nInt_Moriond(nTrueInt)*getLepSF(LepGood_pt[iLepSel[0]],LepGood_eta[iLepSel[0]],LepGood_pdgId[iLepSel[0]])*getLepSF(LepGood_pt[iLepSel[1]],LepGood_eta[iLepSel[1]],LepGood_pdgId[iLepSel[1]])*bTagWeight*triggerSFfullsim(LepGood_pt[iLepSel[0]],LepGood_eta[iLepSel[0]],LepGood_pt[iLepSel[1]],LepGood_eta[iLepSel[1]],met_pt,metmm_pt(LepGood_pdgId[iLepSel[0]],LepGood_pt[iLepSel[0]],LepGood_phi[iLepSel[0]],LepGood_pdgId[iLepSel[1]],LepGood_pt[iLepSel[1]],LepGood_phi[iLepSel[1]],met_pt,met_phi)) --alias wFS getLepSFFS(LepGood_pt[iLepSel[0]],LepGood_eta[iLepSel[0]],LepGood_pdgId[iLepSel[0]])*getLepSFFS(LepGood_pt[iLepSel[1]],LepGood_eta[iLepSel[1]],LepGood_pdgId[iLepSel[1]])*ISREwkCor*bTagWeightFS*triggerEff(LepGood_pt[iLepSel[0]],LepGood_eta[iLepSel[0]],LepGood_pt[iLepSel[1]],LepGood_eta[iLepSel[1]],met_pt,metmm_pt(LepGood_pdgId[iLepSel[0]],LepGood_pt[iLepSel[0]],LepGood_phi[iLepSel[0]],LepGood_pdgId[iLepSel[1]],LepGood_pt[iLepSel[1]],LepGood_phi[iLepSel[1]],met_pt,met_phi)) -W wBG"

WEIGHTS="-l 35.9 --alias weight xsec -W weight" ## this Weighting adds the scale factor xsec*lumi

## No Cuts
echo "Will plot JPsi sample with no cuts"
python mcPlots.py susy-sos-v1/2l/mca_sos_2016.txt emptyCuts susy-sos-v1/2l/plots_sos_kpanos.txt -P ${TREES_PATH} --s2v --tree treeProducerSusyMultilepton --cmsprel Preliminary --legendWidth 0.20 --legendFontSize 0.02 --mcc susy-sos-v1/2l/mcc2016/mcc_2l.txt --mcc susy-sos-v1/mcc_sos.txt --load-macro susy-sos-v1/functionsSOS.cc ${INPUT_FTREES} --print png,txt --neg --legendHeader Datasets -j 8 -p jpsi --pdir ${OUTPUT_DIR}/analysis_JPsiDATA_FullStat-NoCuts $WEIGHTS > plotting_today.log || exit ?

## Only MET
echo "Will plot JPsi sample with MET cut"
python mcPlots.py susy-sos-v1/2l/mca_sos_2016.txt emptyCuts susy-sos-v1/2l/plots_sos_kpanos.txt -P ${TREES_PATH} --s2v --tree treeProducerSusyMultilepton --cmsprel Preliminary --legendWidth 0.20 --legendFontSize 0.02 --mcc susy-sos-v1/2l/mcc2016/mcc_2l.txt --mcc susy-sos-v1/mcc_sos.txt --load-macro susy-sos-v1/functionsSOS.cc ${INPUT_FTREES} --print png,txt --neg --legendHeader Datasets -j 8 -p jpsi -A 'alwaysTrue' 'MET' 'met_pt>125' --pdir ${OUTPUT_DIR}/analysis_JPsiDATA_FullStat-MET_125 $WEIGHTS > plotting_today.log || exit ?

## Only HT
echo "Will plot JPsi sample with HT cut"
python mcPlots.py susy-sos-v1/2l/mca_sos_2016.txt emptyCuts susy-sos-v1/2l/plots_sos_kpanos.txt -P ${TREES_PATH} --s2v --tree treeProducerSusyMultilepton --cmsprel Preliminary --legendWidth 0.20 --legendFontSize 0.02 --mcc susy-sos-v1/2l/mcc2016/mcc_2l.txt --mcc susy-sos-v1/mcc_sos.txt --load-macro susy-sos-v1/functionsSOS.cc ${INPUT_FTREES} --print png,txt --neg --legendHeader Datasets -j 8 -p jpsi -A 'alwaysTrue' 'HT' '(htJet25-LepGood1_pt-LepGood2_pt)>100' --pdir ${OUTPUT_DIR}/analysis_JPsiDATA_FullStat-HTCut $WEIGHTS > plotting_today.log || exit ?

## MET (+) HT
echo "Will plot JPsi sample with MET(+)HT cut"
python mcPlots.py susy-sos-v1/2l/mca_sos_2016.txt emptyCuts susy-sos-v1/2l/plots_sos_kpanos.txt -P ${TREES_PATH} --s2v --tree treeProducerSusyMultilepton --cmsprel Preliminary --legendWidth 0.20 --legendFontSize 0.02 --mcc susy-sos-v1/2l/mcc2016/mcc_2l.txt --mcc susy-sos-v1/mcc_sos.txt --load-macro susy-sos-v1/functionsSOS.cc ${INPUT_FTREES} --print png,txt --neg --legendHeader Datasets -j 8 -p jpsi -A 'alwaysTrue' 'MET+HT' 'met_pt>125 && (htJet25-LepGood1_pt-LepGood2_pt)>100' --pdir ${OUTPUT_DIR}/analysis_JPsiDATA_FullStat-MET_125+HTCut $WEIGHTS > plotting_today.log || exit ?

## Only MET/HT
echo "Will plot JPsi sample with MET/HT cut"
python mcPlots.py susy-sos-v1/2l/mca_sos_2016.txt emptyCuts susy-sos-v1/2l/plots_sos_kpanos.txt -P ${TREES_PATH} --s2v --tree treeProducerSusyMultilepton --cmsprel Preliminary --legendWidth 0.20 --legendFontSize 0.02 --mcc susy-sos-v1/2l/mcc2016/mcc_2l.txt --mcc susy-sos-v1/mcc_sos.txt --load-macro susy-sos-v1/functionsSOS.cc ${INPUT_FTREES} --print png,txt --neg --legendHeader Datasets -j 8 -p jpsi -A 'alwaysTrue' 'METoverHT' 'met_pt/(htJet25-LepGood_pt[iLepSel[0]]-LepGood_pt[iLepSel[1]])>(2/3) && met_pt/(htJet25-LepGood_pt[iLepSel[0]]-LepGood_pt[iLepSel[1]])<1.4' --pdir ${OUTPUT_DIR}/analysis_JPsiDATA_FullStat-METoverHTCut $WEIGHTS > plotting_today.log || exit ?

## MET/HT (+) MET
echo "Will plot JPsi sample with MET/HT(+)MET cut"
python mcPlots.py susy-sos-v1/2l/mca_sos_2016.txt emptyCuts susy-sos-v1/2l/plots_sos_kpanos.txt -P ${TREES_PATH} --s2v --tree treeProducerSusyMultilepton --cmsprel Preliminary --legendWidth 0.20 --legendFontSize 0.02 --mcc susy-sos-v1/2l/mcc2016/mcc_2l.txt --mcc susy-sos-v1/mcc_sos.txt --load-macro susy-sos-v1/functionsSOS.cc ${INPUT_FTREES} --print png,txt --neg --legendHeader Datasets -j 8 -p jpsi -A 'alwaysTrue' 'METoverHT' 'met_pt/(htJet25-LepGood_pt[iLepSel[0]]-LepGood_pt[iLepSel[1]])>(2/3) && met_pt/(htJet25-LepGood_pt[iLepSel[0]]-LepGood_pt[iLepSel[1]])<1.4' -A 'alwaysTrue' 'MET-125' 'met_pt>125' --pdir ${OUTPUT_DIR}/analysis_JPsiDATA_FullStat-METoverHTCut+MET_125 $WEIGHTS > plotting_today.log || exit ?

## MET/HT (+) MET (+) BothTight
echo "Will plot JPsi sample with MET/HT(+)MET(+)BothTight cut"
python mcPlots.py susy-sos-v1/2l/mca_sos_2016.txt emptyCuts susy-sos-v1/2l/plots_sos_kpanos.txt -P ${TREES_PATH} --s2v --tree treeProducerSusyMultilepton --cmsprel Preliminary --legendWidth 0.20 --legendFontSize 0.02 --mcc susy-sos-v1/2l/mcc2016/mcc_2l.txt --mcc susy-sos-v1/mcc_sos.txt --load-macro susy-sos-v1/functionsSOS.cc ${INPUT_FTREES} --print png,txt --neg --legendHeader Datasets -j 8 -p jpsi -A 'alwaysTrue' 'METoverHT' 'met_pt/(htJet25-LepGood_pt[iLepSel[0]]-LepGood_pt[iLepSel[1]])>(2/3) && met_pt/(htJet25-LepGood_pt[iLepSel[0]]-LepGood_pt[iLepSel[1]])<1.4' -A 'alwaysTrue' 'MET-125' 'met_pt>125' -A 'alwaysTrue' 'BothTight' 'LepGood1_isTightString && LepGood2_isTightString' --pdir ${OUTPUT_DIR}/analysis_JPsiDATA_FullStat-METoverHTCut+MET_125+BothTight $WEIGHTS > plotting_today.log || exit ?

echo "Finished JPsi plotting."
echo "Plots can be accessed online at https://kpanos.web.cern.ch/kpanos/SOS/tests/${DATE}."
exit 0
