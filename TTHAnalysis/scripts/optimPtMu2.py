from __future__ import print_function
from numpy import arange
import os, subprocess
import argparse

# parse arguments
parser = argparse.ArgumentParser(description='Tool to make the Mu2 Pt cut optimization.')
parser.add_argument('--exit-on-err', action='store_true', default=False, help='Exit on error.')
parser.add_argument('--run-it', action='store_true', default=False, help='Run the mcPlot commands instead of printing them only.')
args = parser.parse_args()

# get files, env variables and check env
print("User:", os.getenv("USER"))
OUTPUT = "/eos/user/k/kpanos/www/SOS/tests/test_plots2018/plotting/Feb2020/Differential_Regions_FebSW/minMllSFOS_allbutBtag"
cuts_file = None
CMSSW_BASE = os.getenv("CMSSW_BASE")
if CMSSW_BASE:
    print("CMSSW_BASE",CMSSW_BASE)
    print("Getting the cuts file")
    os.chdir(CMSSW_BASE+"/src/CMGTools/TTHAnalysis/python/plotter")
    cuts_file = "susy-sos/2los_cuts.txt"
    print("Cut file:", cuts_file)
    if os.path.isfile(cuts_file):
        print("Cuts file found")
    else:
        print("Cannot find the cuts file")
        quit(1)
else:
    print("do cmsenv")
    quit(1)


MLLcuts = [ (1,4), (4,20), (20,50) ]
#MLLcuts = [ (4,20) ]
Pt2cuts = [ (3,4), (4,5), (5,30) ]
#Pt2cuts = [ (3,30), (4,30) ] + Pt2cuts
#Pt2cuts = [ (4,5) ]
print("Pt2cuts = {}".format(Pt2cuts))
# variate the MLL cut, sed the change and run the plotter
for m2lcut in MLLcuts:
    # get the m2l cut
    m2l_cut1 = str(round(m2lcut[0],2))
    m2l_cut2 = str(round(m2lcut[1],2))    
    # apply the m2l cut
    sed_cmd = '-r "s@(^mll.*: )minMllSFOS.*&& minMllSFOS.*@\\1minMllSFOS > {} \\&\\& minMllSFOS < {}@" {}'.format(m2l_cut1, m2l_cut2, cuts_file)
    print(sed_cmd)
    # os.system("sed {} | grep ^mll".format(sed_cmd, cuts_file))
    os.system("sed -i {} && cat {} | grep ^mll".format(sed_cmd, cuts_file))
    # continue

    outdir_base = "{}/Modification/MLL_{}_{}".format(OUTPUT, m2l_cut1, m2l_cut2)
    # variate the Pt2 cut, sed the change and run the plotter
    for i,cut in enumerate(Pt2cuts):
        #
        # get the pt cut
        pt_cut1 = str(round(cut[0],2))
        pt_cut2 = str(round(cut[1],2))
        print( "Will run for: pt-cut1={}, pt-cut2={}".format(pt_cut1, pt_cut2) )

        # sed it into the cuts file
        sed_cmd = '-r "s@(^pt3subMu[^&]*&&)[^\)]+\)+(.*)@\\1 (LepGood2_pt > {} \\&\\& LepGood2_pt < {} ))\\2@" {}'.format(pt_cut1, pt_cut2, cuts_file)
        print(sed_cmd)
        # os.system("sed -i "+sed_cmd)
        os.system("sed -i {} && cat {} | grep pt3subMu".format(sed_cmd, cuts_file))
        # continue

        outdirs = []
        # run the plotting command for ALT
        outdir = "{}/Alternative_muPt2_{}_{}".format(outdir_base, pt_cut1, pt_cut2); outdirs.append(outdir)
        plot_cmd = "python susy-sos/sos_plots.py --lep 2los --reg sr --bin low {} 2018 --signal --run --study-mod SingleMuonTrigger alt_muPt2gt3 True".format(outdir)
        # if i == 0:
        #     plot_cmd = plot_cmd.replace('--run ','')
        print("Will run:", plot_cmd, sep='\n')
        if args.run_it:
            os.system(plot_cmd)

        ## DEBUG with only one plotting done
        # quit(0)

        # plotting command for SOS cuts
        if cut[0] >= 5:
            outdir = "{}/Original_muPt2_{}_{}".format(outdir_base, pt_cut1, pt_cut2); outdirs.append(outdir)
            plot_cmd = "python susy-sos/sos_plots.py --lep 2los --reg sr --bin low {} 2018 --signal --run --study-mod SingleMuonTrigger sos_muPt2gt3 True".format(outdir)
            print("Will run:", plot_cmd, sep='\n')
            if args.run_it:
                os.system(plot_cmd)

        # if the plots dir has been created, save in there the pt cut in a txt file
        for _dir in outdirs:
            if os.path.isdir(_dir):
                ptcut_file1 = open(_dir+"/2018/2los_sr_low/mu2ptcut.txt",'w+')
                ptcut_file1.write("MLL {} {}".format(m2l_cut1, m2l_cut2))
                ptcut_file1.write("Pt2 {} {}".format(pt_cut1, pt_cut2))
                ptcut_file1.close()
            elif args.exit_on_err:
                print("Alternative plots' directory for MLL ({},{}) and Pt2 ({},{}) does not exist.".format(m2l_cut1, m2l_cut2, pt_cut1, pt_cut2))
                quit(1)

# return the cut file in its initial state
sed_cmd = 'sed -i -r "s@(^mll.*: )minMllSFOS.*&& minMllSFOS.*@\\1minMllSFOS > 4 \\&\\& minMllSFOS < 50@" {}'.format(cuts_file)
os.system(sed_cmd)
sed_cmd = 'sed -i -r "s@(^pt3subMu[^&]*&&)[^\)]+\)+(.*)@\\1 LepGood2_pt > 3)\\2@" {}'.format(cuts_file)
os.system(sed_cmd)
quit(0)
