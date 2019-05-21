from __future__ import print_function
import ROOT, sys, subprocess

cuts = []; libs = []; treefile = None; debug = False
if "--debug" in sys.argv:
    debug = True;
if len(sys.argv) > 0:
    for i,arg in enumerate(sys.argv):
        if debug: print("arg("+str(i)+"): "+arg)
        if arg == "--tree": treefile = sys.argv[i+1]
        if arg == "--cut": cuts.append(sys.argv[i+1])
        if arg == "--lib": libs.append(sys.argv[i+1])
if debug:
    print("tree = "+str(treefile))
    print("cuts = ", cuts)
    print("libs = ", libs)

## Load TTree
if treefile is not None:
    try:
        file_jpsi = ROOT.TFile.Open(treefile,"READ")
        file_jpsi.Print()
        tree_jpsi = file_jpsi.Get("tree")
        print("TTree for JPsi Initialized.\tEntries: ", tree_jpsi.GetEntries())
    except:
        print(sys.argv)
        print("TTree for JPsi didn't initialize correctly. Exiting..")
        quit(1)
else:
    print("Usage: sys.argv[0] --tree <jpsi-root-file> [--cut <cut> --lib <lib> --debug]")
    quit(1)

## Try to add friend
try:
    treePath = subprocess.check_output("dirname "+treefile, shell=True).strip("\n")
    print("Will now try to add friend from the path "+treePath+"/../../0_both3dlooseClean_v2")
    tree_jpsi.AddFriend("sf/t",treePath+"/../../0_both3dlooseClean_v2/evVarFriend_JPsiToMuMu_JPsiPt8.root")
except:
    print("...friend was not able to be added, proceeding without friend tree.")

for lib in libs:
    root_cmd = ".L "+lib+"+"
    print("root_cmd: "+root_cmd)
    ROOT.gROOT.ProcessLine(root_cmd);

## Print the table
dash='+'+('~'*240)+'+'
print(dash)
print("|{:^200s}|{:>20s}|{:>18s}|".format("Cut", "Events Survived", "Percentage"))
print(dash)
for cut in cuts:
    entriesSurvived = float(tree_jpsi.GetEntries(cut))
    print("|{:^200s}|{:>20d}|{:>18.5f}|".format(cut, int(entriesSurvived), 100*entriesSurvived/tree_jpsi.GetEntries()) )
print(dash)

quit(0)
