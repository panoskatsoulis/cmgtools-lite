#!/bin/bash
set -x

TEST=false
[ "$1" == "--test" ] && { RUN="--dont-run"; TEST=true; } || RUN="--run"
[ -z $CMSSW_BASE ] && echo "do cmsenv"


#OUTPUT=/eos/user/k/kpanos/www/SOS/tests/test_plots2018/plotting/SatNov02/Studies_CRissue
#OUTPUT=/eos/user/k/kpanos/www/SOS/tests/test_plots2018/plotting/SatNov02/many_sigs
OUTPUT=/eos/user/k/kpanos/www/SOS/tests/test_plots2018/plotting/WedNov06/few_sigs_Ptcut4.5
www_OUTPUT=$(echo $OUTPUT | sed s@/eos/user/k/kpanos/www/@@)
#$TEST || rm -rf $OUTPUT

echo $OUTPUT
echo $www_OUTPUT

cd ../python/plotter


## SOS ref
# python susy-sos/sos_plots.py --lep 2los --reg cr_dy --bin low $OUTPUT/Reference/Original 2018 --data $RUN

# python susy-sos/sos_plots.py --lep 2los --reg cr_tt --bin low $OUTPUT/Reference/Original 2018 --data $RUN

# python susy-sos/sos_plots.py --lep 2los --reg sr --bin low $OUTPUT/Reference/Original 2018 --signal $RUN



## SOS mod
# python susy-sos/sos_plots.py --lep 2los --reg cr_dy --bin low $OUTPUT/Modification/Original 2018 --data $RUN --study-mod SingleMuonTrigger sos True

# python susy-sos/sos_plots.py --lep 2los --reg cr_tt --bin low $OUTPUT/Modification/Original 2018 --data $RUN --study-mod SingleMuonTrigger sos True

python susy-sos/sos_plots.py --lep 2los --reg sr --bin low $OUTPUT/Modification/Original 2018 --signal $RUN --study-mod SingleMuonTrigger sos True



## ALT mod
# python susy-sos/sos_plots.py --lep 2los --reg cr_dy --bin low $OUTPUT/Modification/Altrernative 2018 --data $RUN --study-mod SingleMuonTrigger alt True

# python susy-sos/sos_plots.py --lep 2los --reg cr_dy --bin low $OUTPUT/Modification/Altrernative_muPt2gt3p5 2018 --data $RUN --study-mod SingleMuonTrigger alt_muPt2gt3 True

# python susy-sos/sos_plots.py --lep 2los --reg cr_tt --bin low $OUTPUT/Modification/Altrernative 2018 --data $RUN --study-mod SingleMuonTrigger alt True

# python susy-sos/sos_plots.py --lep 2los --reg cr_tt --bin low $OUTPUT/Modification/Altrernative_muPt2gt3p5 2018 --data $RUN --study-mod SingleMuonTrigger alt_muPt2gt3 True

# python susy-sos/sos_plots.py --lep 2los --reg sr --bin low $OUTPUT/Modification/Altrernative 2018 --signal $RUN --study-mod SingleMuonTrigger alt True

# python susy-sos/sos_plots.py --lep 2los --reg sr --bin low $OUTPUT/Modification/Altrernative_muPt2gt3p5 2018 --signal $RUN --study-mod SingleMuonTrigger alt_muPt2gt3p5 True

python susy-sos/sos_plots.py --lep 2los --reg sr --bin low $OUTPUT/Modification/Altrernative_muPt2gt3 2018 --signal $RUN --study-mod SingleMuonTrigger alt_muPt2gt3 True


cd -
## Extra Plots
mkdir $OUTPUT/SigVsMassPoints
./makeExtraPlots.py --files $OUTPUT/Modification/Original/2018/2los_sr_low/2los_plots.root,$OUTPUT/Modification/Altrernative_muPt2gt3/2018/2los_sr_low/2los_plots.root --names 2los_sos,2los_alt --filestype root --out-dir $www_OUTPUT/SigVsMassPoints --plots SigVsMassPoints --save-root --deltaMs 20,15,10,8,5 2>extraplots.err | tee extraplots.log

exit 0
