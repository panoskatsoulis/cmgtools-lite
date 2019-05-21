#!/bin/bash

[ -e plotting_today.log ] && rm -f plotting_today.log
DATE=$(date | sed -r 's@^(.* .* .*) .* .* (.*)$@\1_\2@' | tr ' ' '-' | sed -r 's@\-{2,}@\-@')

MCPLOTS_COMAND="python mcPlots.py susy-sos-v1/2l/mca_sos_2016.txt susy-sos-v1/2l/cuts_sos_2016.txt susy-sos-v1/2l/plots_sos_kpanos.txt -P /eos/user/k/kpanos/sostrees/2016_80X --s2v --tree treeProducerSusyMultilepton -uf --cmsprel Preliminary --legendWidth 0.20 --legendFontSize 0.02 --mcc susy-sos-v1/mcc_triggerdefs.txt --mcc susy-sos-v1/2l/mcc2016/mcc_2l.txt --mcc susy-sos-v1/mcc_sos.txt --mcc susy-sos-v1/2l/mcc2016/mcc_sf_met125.txt --mcc susy-sos-v1/2l/mcc2016/mcc_sf_fakes_2losEwkLow.txt --load-macro susy-sos-v1/functionsSOS.cc --load-macro susy-sos-v1/functionsSF.cc --load-macro susy-sos-v1/functionsPUW.cc --load-macro functions-kpanos.cc -F sf/t /eos/user/k/kpanos/sostrees/2016_80X/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/user/k/kpanos/sostrees/2016_80X/0_eventBTagWeight_v2/evVarFriend_{cname}.root --print png,txt --neg --legendHeader Datasets -j 8"

PROCS_CUTS_MOD_BASE="-p jpsi -E ewk_.* -R lepRel_mll lepRel_mll m2l<50 -X lepRel_upsilonVeto -X ^evRel_.*"

WEIGHTS="--alias wBG puw_nInt_Moriond(nTrueInt)*getLepSF(LepGood_pt[iLepSel[0]],LepGood_eta[iLepSel[0]],LepGood_pdgId[iLepSel[0]])*getLepSF(LepGood_pt[iLepSel[1]],LepGood_eta[iLepSel[1]],LepGood_pdgId[iLepSel[1]])*bTagWeight*triggerSFfullsim(LepGood_pt[iLepSel[0]],LepGood_eta[iLepSel[0]],LepGood_pt[iLepSel[1]],LepGood_eta[iLepSel[1]],met_pt,metmm_pt(LepGood_pdgId[iLepSel[0]],LepGood_pt[iLepSel[0]],LepGood_phi[iLepSel[0]],LepGood_pdgId[iLepSel[1]],LepGood_pt[iLepSel[1]],LepGood_phi[iLepSel[1]],met_pt,met_phi)) --alias wFS getLepSFFS(LepGood_pt[iLepSel[0]],LepGood_eta[iLepSel[0]],LepGood_pdgId[iLepSel[0]])*getLepSFFS(LepGood_pt[iLepSel[1]],LepGood_eta[iLepSel[1]],LepGood_pdgId[iLepSel[1]])*ISREwkCor*bTagWeightFS*triggerEff(LepGood_pt[iLepSel[0]],LepGood_eta[iLepSel[0]],LepGood_pt[iLepSel[1]],LepGood_eta[iLepSel[1]],met_pt,metmm_pt(LepGood_pdgId[iLepSel[0]],LepGood_pt[iLepSel[0]],LepGood_phi[iLepSel[0]],LepGood_pdgId[iLepSel[1]],LepGood_pt[iLepSel[1]],LepGood_phi[iLepSel[1]],met_pt,met_phi)) -W wBG"

## Enable & Disable Workflows
PLOTS1_JPsiFullStat=false

PLOTS2to5_1_METbins=false

PLOTS6_2to5_HTcut=true
PLOTS7_2to5_METoverHTlowcut=false
PLOTS8_2to5_METoverHThighcut=false
PLOTS9_2to5_METoverHTentirecut=true
PLOTS10_2to5_METoverHTentirecut_HTcut=true

PLOTS11_HighMET16_SR=false
PLOTS12_HighMET16_DYCR=false
PLOTS13_HighMET16_TTCR=false
PLOTS14_HighMET16_fakes=false

## JPsi Mass Investigation
OUTNAME="analysis_JPsiDATA_FullStat"

$PLOTS1_JPsiFullStat && {
    echo "Now plotting plots1.";
    [ -d /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-noMETcut ] && \
	rm -rf /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-noMETcut;
    $MCPLOTS_COMAND $PROCS_CUTS_MOD_BASE $WEIGHTS \
	--pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-noMETcut 1>>plotting_today.log 2>&1 || { echo "Error"; exit 1; };
    echo "-----------------------------------">>plotting_today.log;
    echo "Finished";
}

function plots1_allMetBins() {
    ## call example: plots1_allMetBins <dirname-extention> <mcPlots-args>

    [ ! -z "$*" ] && { DIRNAME_MOD="_$1"; shift; CUTS_MOD="$*"; }
    #CUTS_MOD=$(echo $CUTS_MOD | sed -r "s@([^ ][^\-][^ ]*)@'\1'@g" | sed -r "s@'(\-.)'@\1@");
    echo "CUTS_MOD=$CUTS_MOD";

    echo "Now plotting plots2."
    [ -d /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-MET_0-50${DIRNAME_MOD} ] && \
	rm -rf /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-MET_0-50${DIRNAME_MOD};
    $MCPLOTS_COMAND $PROCS_CUTS_MOD_BASE $WEIGHTS -E 'MET_0_50' $CUTS_MOD \
	--pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-MET_0-50${DIRNAME_MOD} 1>>plotting_today.log 2>&1 || { echo "Error"; return 2; }
    echo "-----------------------------------">>plotting_today.log;
    echo "Finished"

    echo "Now plotting plots3."
    [ -d /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-MET_50-125${DIRNAME_MOD} ] && \
	rm -rf /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-MET_50-125${DIRNAME_MOD};
    $MCPLOTS_COMAND $PROCS_CUTS_MOD_BASE $WEIGHTS -E 'MET_50_125' $CUTS_MOD \
	--pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-MET_50-125${DIRNAME_MOD} 1>>plotting_today.log 2>&1 || { echo "Error"; return 3; }
    echo "-----------------------------------">>plotting_today.log;
    echo "Finished"

    echo "Now plotting plots4."
    [ -d /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-MET_125-200${DIRNAME_MOD} ] && \
	rm -rf /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-MET_125-200${DIRNAME_MOD};
    $MCPLOTS_COMAND $PROCS_CUTS_MOD_BASE $WEIGHTS -E 'MET_125_200' $CUTS_MOD \
	--pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-MET_125-200${DIRNAME_MOD} 1>>plotting_today.log 2>&1 || { echo "Error"; return 4; }
    echo "-----------------------------------">>plotting_today.log;
    echo "Finished"

    echo "Now plotting plots5."
    [ -d /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-MET_200-inf${DIRNAME_MOD} ] && \
	rm -rf /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-MET_200-inf${DIRNAME_MOD};
    $MCPLOTS_COMAND $PROCS_CUTS_MOD_BASE $WEIGHTS -E 'MET_200_inf' $CUTS_MOD \
	--pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-MET_200-inf${DIRNAME_MOD} 1>>plotting_today.log 2>&1 || { echo "Error"; return 5; }
    echo "-----------------------------------">>plotting_today.log;
    echo "Finished"

    return 0
}

$PLOTS2to5_1_METbins && {  ## lets call the function to run once
    plots1_allMetBins || exit $?;
}

## Now Call The Function Recursively For Different Cutflows
$PLOTS6_2to5_HTcut && {
    echo "Now plotting plots6-HTcut. Recursively plots2-5...";
    plots1_allMetBins "HTcut" \
	-A 'ewk_pt5sublep' 'HT' '(htJet25-LepGood1_pt-LepGood2_pt)>100' || { echo "Error in recursive $?"; exit 6; };
    echo "Finished recursively plotting.";
}

$PLOTS7_2to5_METoverHTlowcut && {
    echo "Now plotting plots7-METoverHTlowcut. Recursively plots2-5...";
    plots1_allMetBins "METoverHTlowcut" \
	-A 'ewk_pt5sublep' 'METoverHT_low' '(met_pt/(htJet25-LepGood1_pt-LepGood2_pt))>(2/3)' || { echo "Error in recursive $?"; exit 7; };
    echo "Finished recursively plotting.";
}

$PLOTS8_2to5_METoverHThighcut && {
    echo "Now plotting plots8-METoverHThighcut. Recursively plots2-5...";
    plots1_allMetBins "METoverHThighcut" \
	-A 'ewk_pt5sublep' 'METoverHT_high' '(met_pt/(htJet25-LepGood1_pt-LepGood2_pt))<1.4' || { echo "Error in recursive $?"; exit 8; };
    echo "Finished recursively plotting.";
}

$PLOTS9_2to5_METoverHTentirecut && {
    echo "Now plotting plots9-METoverHTentirecut. Recursively plots2-5...";
    plots1_allMetBins "METoverHTentirecut" \
	-A 'ewk_pt5sublep' 'METoverHT' '(met_pt/(htJet25-LepGood1_pt-LepGood2_pt))>(2/3)&&(met_pt/(htJet25-LepGood1_pt-LepGood2_pt))<1.4' || { echo "Error in recursive $?"; exit 9; };
    echo "Finished recursively plotting.";
}

$PLOTS10_2to5_METoverHTentirecut_HTcut && {
    echo "Now plotting plots10-METoverHTentirecut+HTcut. Recursively plots2-5...";
    plots1_allMetBins "METoverHTentirecut+HTcut" \
	-A 'ewk_pt5sublep' 'METoverHT' '(met_pt/(htJet25-LepGood1_pt-LepGood2_pt))>(2/3)&&(met_pt/(htJet25-LepGood1_pt-LepGood2_pt))<1.4' \
	-A 'ewk_pt5sublep' 'HT' '(htJet25-LepGood1_pt-LepGood2_pt)>100' || { echo "Error in recursive $?"; exit 10; };
    echo "Finished recursively plotting.";
}

## HighMET16 Inclusive (MET bin 200-inf)
OUTNAME="analysis_HighMET16_Regions"
MCPLOTS_COMAND_MOD=$(echo $MCPLOTS_COMAND | sed -r 's@\-\-mcc [^ ]*/mcc_sf_met125\.txt *@@; s@\-\-mcc [^ ]*/mcc_sf_fakes_2losEwkLow\.txt *@@;') ## remove mccs that are not needed
PROCS_CUTS_MOD=$(echo "-p data -p prompt_tt -p prompt_dy ${PROCS_CUTS_MOD_BASE}" | sed 's@ -X ^evRel_.*$@@') ## dont exclude the evRel_* cuts for the next plots

$PLOTS11_HighMET16_SR && {
    echo "Now plotting HighMET16_SR";
    [ -d /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-SR ] && \
	rm -rf /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-SR;
    $MCPLOTS_COMAND_MOD $PROCS_CUTS_MOD --pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-SR \
	--mcc susy-sos-v1/2l/mcc2016/mcc_sf_met200.txt \
	-E 'ewk200_.*' -X 'ewk200_met2' 1>>plotting_today.log 2>&1 || { echo "Error";  exit 11; }; ## remove the met<250 cut for the middle bin
    echo "-----------------------------------">>plotting_today.log;
    echo "Finished";
}

$PLOTS12_HighMET16_DYCR && {
    echo "Now plotting HighMET16_DYCR";
    [ -d /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-DYCR ] && \
	rm -rf /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-DYCR;
    ## change the cutfile and remove the mccs
    MCPLOTS_COMAND_MOD=$(echo $MCPLOTS_COMAND_MOD | sed -r 's@[^ ]*cuts_sos[^ ]*\.txt@susy-sos-v1/crdy/cuts_dy_2016.txt@');
    $MCPLOTS_COMAND_MOD $PROCS_CUTS_MOD --pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-DYCR \
	--mcc susy-sos-v1/2l/mcc2016/mcc_sf_met200.txt \
	--mcc susy-sos-v1/2l/mcc2016/mcc_sf_fakes_dyMed.txt \
	--mcc susy-sos-v1/crdy/mcc_dy_2016.txt \
	-E 'ewk200_.*' -X 'ewk200_met2' 1>>plotting_today.log 2>&1 || { echo "Error";  exit 12; }; ## remove the met<250 cut for the middle bin
    echo "-----------------------------------">>plotting_today.log;
    echo "Finished";
}

$PLOTS13_HighMET16_TTCR && {
    echo "Now plotting HighMET16_TTCR";
    [ -d /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-DYCR ] && \
	rm -rf /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-TTCR;
    ## change the cutfile and remove the mccs
    MCPLOTS_COMAND_MOD=$(echo $MCPLOTS_COMAND_MOD | sed -r 's@[^ ]*cuts_sos[^ ]*\.txt@susy-sos-v1/crtt/cuts_tt_2016.txt@');
    $MCPLOTS_COMAND_MOD $PROCS_CUTS_MOD --pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-TTCR \
	--mcc susy-sos-v1/2l/mcc2016/mcc_sf_met200.txt \
	--mcc susy-sos-v1/2l/mcc2016/mcc_sf_fakes_ttMed.txt \
	--mcc susy-sos-v1/crtt/mcc_tt_2016.txt\
	-E 'ewk200_.*' -X 'ewk200_met2' 1>>plotting_today.log 2>&1 || { echo "Error";  exit 13; }; ## remove the met<250 cut for the middle bin
    echo "-----------------------------------">>plotting_today.log;
    echo "Finished";
}

$PLOTS14_HighMET16_fakes && {
    echo "Now plotting HighMET16_fakes";
    [ -d /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-fakes ] && \
	rm -rf /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-fakes;
    $MCPLOTS_COMAND $PROCS_CUTS_MOD --pdir /eos/user/k/kpanos/www/SOS/tests/${DATE}/${OUTNAME}-fakes \
	-E 'ewk200_.*' -X 'ewk200_met2' 1>>plotting_today.log 2>&1 || { echo "Error";  exit 14; }; ## remove the met<250 cut for the middle bin
    echo "-----------------------------------">>plotting_today.log;
    echo "Finished";
}


## figure-of-merit test

exit 0

