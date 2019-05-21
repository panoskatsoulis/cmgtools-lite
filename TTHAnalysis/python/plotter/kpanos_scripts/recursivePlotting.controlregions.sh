#!/bin/bash
[ -z $2 ] && { echo "Usage $(basename $0) <output-path> <logfile-name> [<--CRs/--ARs>]"; exit 1; }
OUTPUT_PATH=$1
LOG_FILE=$2
[ -e $LOG_FILE ] && rm -f $LOG_FILE
touch $LOG_FILE

PLOT_CRs=false; PLOT_ARs=false
[ ! -z $3 ] && {
    [ "$3" == "--CRs" ] && { PLOT_CRs=true; PLOT_ARs=false; }
    [ "$3" == "--ARs" ] && { PLOT_CRs=false; PLOT_ARs=true; }
}
echo "PLOT_CRs=$PLOT_CRs"
echo "PLOT_ARs=$PLOT_ARs"
! $PLOT_CRs && ! $PLOT_ARs && { echo "No region requested."; exit 1; }

## Plotting CRs
$PLOT_CRs && {
    echo "Will run 6 plotmaker commands to plot CRs..."

    python susy-interface/plotmaker.py sos2l16 dyLow16 /afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/ $OUTPUT_PATH/plots_controlregions -l 33.2 --make bkgs --plots all -o SRsemi --flags "--perBin --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root" -p "data;prompt_.*;rares;fakes_applmcBoth;sig_T2tt_.*" -W 'wBG' -j 8
    echo $? >> $LOG_FILE

    python susy-interface/plotmaker.py sos2l16 dyMed16 /afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/ $OUTPUT_PATH/plots_controlregions -l 35.9 --make bkgs --plots all -o SRsemi --flags "--perBin --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root" -p "data;prompt_.*;rares;fakes_applmcBoth;sig_T2tt_.*" -W 'wBG' -j 8
    echo $? >> $LOG_FILE

    python susy-interface/plotmaker.py sos2l16 ttLow16 /afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/ $OUTPUT_PATH/plots_controlregions -l 33.2 --make bkgs --plots all -o SRsemi --flags "--perBin --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root" -p "data;prompt_.*;rares;fakes_applmcBoth;sig_T2tt_.*" -W 'wBG' -j 8
    echo $? >> $LOG_FILE

    python susy-interface/plotmaker.py sos2l16 ttMed16 /afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/ $OUTPUT_PATH/plots_controlregions -l 35.9 --make bkgs --plots all -o SRsemi --flags "--perBin --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root" -p "data;prompt_.*;rares;fakes_applmcBoth;sig_T2tt_.*" -W 'wBG' -j 8
    echo $? >> $LOG_FILE

    python susy-interface/plotmaker.py sos2l16 vvLow16 /afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/ $OUTPUT_PATH/plots_controlregions -l 33.2 --make bkgs --plots all -o SRsemi --flags "--perBin --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root" -p "data;prompt_.*;rares;fakes_applmcBoth;sig_TChiWZ_.*" -W 'wBG' -j 8
    echo $? >> $LOG_FILE

    python susy-interface/plotmaker.py sos2l16 vvMed16 /afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/ $OUTPUT_PATH/plots_controlregions -l 35.9 --make bkgs --plots all -o SRsemi --flags "--perBin --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root" -p "data;prompt_.*;rares;fakes_applmcBoth;sig_TChiWZ_.*" -W 'wBG' -j 8
    echo $? >> $LOG_FILE
}


## Ploting ARs to test
$PLOT_ARs && {
    echo "Will run 3 plotmaker commands to plot testing ARs..."

    ## EWK-Low
    echo "Plotting EWK-Low"

    python susy-interface/plotmaker.py sos2l16 2losEwkLow16 "/eos/user/k/kpanos/sostrees/2016_80X/" $OUTPUT_PATH/ewklow_plots_applicationregions -l 33.2 --make datasig --plots all -o AR --flags "--perBin -X twoTight -E oneNotTight --RP=/eos/user/k/kpanos/sostrees/2016_80X/fake_remote_path -F sf/t /eos/user/k/kpanos/sostrees/2016_80X/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/user/k/kpanos/sostrees/2016_80X/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;jpsi;prompt_.*;rares;fakes_matched_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    echo $? >> $LOG_FILE

    # python susy-interface/plotmaker.py sos2l16 2losEwkLow16 "/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/" $OUTPUT_PATH/ewklow_plots_applicationregions -l 33.2 --make datasig --plots all -o AR1F --flags "--perBin -X twoTight -E oneLNT --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;prompt_.*;rares;fakes_matched_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    # echo $? >> $LOG_FILE

    # python susy-interface/plotmaker.py sos2l16 2losEwkLow16 "/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/" $OUTPUT_PATH/ewklow_plots_applicationregions -l 33.2 --make datasig --plots all -o AR2F --flags "--perBin -X twoTight -E twoLNT --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;prompt_.*;rares;fakes_matched_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    # echo $? >> $LOG_FILE

    # python susy-interface/plotmaker.py sos2l16 2losEwkLow16 "/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/" $OUTPUT_PATH/ewklow_plots_applicationregions -l 33.2 --make datasig --plots all -o AR_sc --flags "--perBin -X twoTight -E oneNotTight --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;prompt_.*;rares;fakes_matchedBoth_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    # echo $? >> $LOG_FILE

    # python susy-interface/plotmaker.py sos2l16 2losEwkLow16 "/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/" $OUTPUT_PATH/ewklow_plots_applicationregions -l 33.2 --make datasig --plots all -o AR1F_sc --flags "--perBin -X twoTight -E oneLNT --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;prompt_.*;rares;fakes_matched1_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    # echo $? >> $LOG_FILE

    # python susy-interface/plotmaker.py sos2l16 2losEwkLow16 "/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/" $OUTPUT_PATH/ewklow_plots_applicationregions -l 33.2 --make datasig --plots all -o AR2F_sc --flags "--perBin -X twoTight -E twoLNT --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;prompt_.*;rares;fakes_matched2_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    # echo $? >> $LOG_FILE

    ## EWK-Med
    echo "Plotting EWK-Med"

    python susy-interface/plotmaker.py sos2l16 2losEwkMed16 "/eos/user/k/kpanos/sostrees/2016_80X/" $OUTPUT_PATH/ewkmed_plots_applicationregions -l 35.9 --make datasig --plots all -o AR --flags "--perBin -X twoTight -E oneNotTight --RP=/eos/user/k/kpanos/sostrees/2016_80X/fake_remote_path -F sf/t /eos/user/k/kpanos/sostrees/2016_80X/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/user/k/kpanos/sostrees/2016_80X/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;jpsi;prompt_.*;rares;fakes_matched_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    echo $? >> $LOG_FILE

    # python susy-interface/plotmaker.py sos2l16 2losEwkMed16 "/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/" $OUTPUT_PATH/ewkmed_plots_applicationregions -l 35.9 --make datasig --plots all -o AR1F --flags "--perBin -X twoTight -E oneLNT --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;prompt_.*;rares;fakes_matched_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    # echo $? >> $LOG_FILE

    # python susy-interface/plotmaker.py sos2l16 2losEwkMed16 "/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/" $OUTPUT_PATH/ewkmed_plots_applicationregions -l 35.9 --make datasig --plots all -o AR2F --flags "--perBin -X twoTight -E twoLNT --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;prompt_.*;rares;fakes_matched_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    # echo $? >> $LOG_FILE

    # python susy-interface/plotmaker.py sos2l16 2losEwkMed16 "/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/" $OUTPUT_PATH/ewkmed_plots_applicationregions -l 35.9 --make datasig --plots all -o AR_sc --flags "--perBin -X twoTight -E oneNotTight --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;prompt_.*;rares;fakes_matchedBoth_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    # echo $? >> $LOG_FILE

    # python susy-interface/plotmaker.py sos2l16 2losEwkMed16 "/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/" $OUTPUT_PATH/ewkmed_plots_applicationregions -l 35.9 --make datasig --plots all -o AR1F_sc --flags "--perBin -X twoTight -E oneLNT --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;prompt_.*;rares;fakes_matched1_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    # echo $? >> $LOG_FILE

    # python susy-interface/plotmaker.py sos2l16 2losEwkMed16 "/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/" $OUTPUT_PATH/ewkmed_plots_applicationregions -l 35.9 --make datasig --plots all -o AR2F_sc --flags "--perBin -X twoTight -E twoLNT --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;prompt_.*;rares;fakes_matched2_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    # echo $? >> $LOG_FILE

    ## EWK-Hig
    echo "Plotting EWK-Hig"

    python susy-interface/plotmaker.py sos2l16 2losEwkHig16 "/eos/user/k/kpanos/sostrees/2016_80X/" $OUTPUT_PATH/ewkhig_plots_applicationregions -l 35.9 --make datasig --plots all -o AR --flags "--perBin -X twoTight -E oneNotTight --RP=/eos/user/k/kpanos/sostrees/2016_80X/fake_remote_path -F sf/t /eos/user/k/kpanos/sostrees/2016_80X/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/user/k/kpanos/sostrees/2016_80X/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;jpsi;prompt_.*;rares;fakes_matched_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    echo $? >> $LOG_FILE

    # python susy-interface/plotmaker.py sos2l16 2losEwkHig16 "/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/" $OUTPUT_PATH/ewkhig_plots_applicationregions -l 35.9 --make datasig --plots all -o AR1F --flags "--perBin -X twoTight -E oneLNT --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;prompt_.*;rares;fakes_matched_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    # echo $? >> $LOG_FILE

    # python susy-interface/plotmaker.py sos2l16 2losEwkHig16 "/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/" $OUTPUT_PATH/ewkhig_plots_applicationregions -l 35.9 --make datasig --plots all -o AR2F --flags "--perBin -X twoTight -E twoLNT --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;prompt_.*;rares;fakes_matched_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    # echo $? >> $LOG_FILE

    # python susy-interface/plotmaker.py sos2l16 2losEwkHig16 "/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/" $OUTPUT_PATH/ewkhig_plots_applicationregions -l 35.9 --make datasig --plots all -o AR_sc --flags "--perBin -X twoTight -E oneNotTight --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;prompt_.*;rares;fakes_matchedBoth_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    # echo $? >> $LOG_FILE

    # python susy-interface/plotmaker.py sos2l16 2losEwkHig16 "/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/" $OUTPUT_PATH/ewkhig_plots_applicationregions -l 35.9 --make datasig --plots all -o AR1F_sc --flags "--perBin -X twoTight -E oneLNT --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;prompt_.*;rares;fakes_matched1_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    # echo $? >> $LOG_FILE

    # python susy-interface/plotmaker.py sos2l16 2losEwkHig16 "/afs/cern.ch/user/p/peruzzi/work/sostrees/trees_SOS_010217/" $OUTPUT_PATH/ewkhig_plots_applicationregions -l 35.9 --make datasig --plots all -o AR2F_sc --flags "--perBin -X twoTight -E twoLNT --RP=/eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217 -F sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_both3dlooseClean_v2/evVarFriend_{cname}.root --FMC sf/t /eos/cms/store/cmst3/group/susy/SOS/trees_SOS_010217/0_eventBTagWeight_v2/evVarFriend_{cname}.root -R 'mll' 'mll' 'm2l<50'" -p "data;prompt_.*;rares;fakes_matched2_.*;sig_TChiWZ_.*"  -W 'wBG' -j 8
    # echo $? >> $LOG_FILE
}

exit 0
