from __future__ import print_function
import sys, time

started_at = time.time()
cuts = []; libs = []; treefile = None; debug = False
good_only = False; other_only = False; do_ev_eff = False
debugEntries = 1000; ev_leps_req = None
if "--debug" in sys.argv:
    debug = True;
if "--help" in sys.argv:
    print("Supported options: --tree, --cut, --lib, --debug, --help, --good-only, --other-only, --do-event-eff")
    quit(0)
if len(sys.argv) > 0:
    for i,arg in enumerate(sys.argv):
        if debug: print("arg("+str(i)+"): "+arg)
        if arg == "--tree": treefile = sys.argv[i+1]
        if arg == "--cut": cuts.append(sys.argv[i+1])
        if arg == "--lib": libs.append(sys.argv[i+1])
        if arg == "--debug": debugEntries = int(sys.argv[i+1])
        if arg == "--good-only": good_only = True
        if arg == "--other-only": other_only = True
        if arg == "--do-event-eff": do_ev_eff = True; ev_leps_req = int(sys.argv[i+1])
if debug:
    print("tree = "+str(treefile))
    print("cuts = ", cuts)
    print("libs = ", libs)
    print("debug = ", debug)
    print("good_only = ", good_only)
    print("other_only = ", other_only)
    print("do_ev_eff = ", do_ev_eff)
    print("ev_leps_req = ", ev_leps_req)
    print("debugEntries = ", debugEntries)

if good_only and other_only:
    print("arguments --good-only and --other-only must not be used together.")
    quit(1)

import ROOT, subprocess, re
RawConditions = []; GoodConditions = []; OtherConditions = []
for cut in cuts:
    ## Parse conditions
    LHSides = []; CondsAndRHSides = []; connectors = []
    expr = re.compile("([^ ]+) *([^ ]*)")
    lepConds = expr.findall(cut)
    # print("conditions for cut: ", cut)
    expr = re.compile("(.+)([<>=!]+.*)")
    # print("lepConds : ",lepConds)
    for cond in lepConds:
        # print("cond : ",cond[0])
        parsedCond = expr.findall(cond[0])
        if len(cond) > 1: ## if there is a connector append it in their list
            connectors.append(cond[1])
        # print(parsedCond, "\tlength=", len(parsedCond))
        LHSides.append(parsedCond[0][0])
        CondsAndRHSides.append(parsedCond[0][1])
        
    GoodLHSides = []; OtherLHSides = []
    GoodCondsRHSides = []; OtherCondsRHSides = []
    # print("LHSides : ",LHSides)
    for lhs in LHSides:
        GoodLHSides.append( re.sub("([^*/+-]+)","getattr(tree,\"LepGood_\\1\")[lep]",lhs) )
        OtherLHSides.append( re.sub("([^*/+-]+)","getattr(tree,\"LepOther_\\1\")[lep]",lhs) )
    # print("CondsAndRHSides : ",CondsAndRHSides)
    for condrhs in CondsAndRHSides:
        GoodCondsRHSides.append( re.sub("([_a-zA-Z][_a-zA-Z0-9]*)","getattr(tree,\"LepGood_\\1\")[lep]",condrhs) )
        OtherCondsRHSides.append( re.sub("([_a-zA-Z][_a-zA-Z0-9]*)","getattr(tree,\"LepOther_\\1\")[lep]",condrhs) )

    # print(RHSides)
    RawCondition = LHSides[0] + CondsAndRHSides[0]
    GoodCondition = GoodLHSides[0] + GoodCondsRHSides[0]
    OtherCondition = OtherLHSides[0] + OtherCondsRHSides[0]
    for i,connector in enumerate(connectors):
        if connector == '':
            continue
        RawCondition += ' ' + connector + ' ' + LHSides[i+1] + CondsAndRHSides[i+1]
        GoodCondition += ' ' + connector + ' ' + GoodLHSides[i+1] + GoodCondsRHSides[i+1]
        OtherCondition += ' ' + connector + ' ' + OtherLHSides[i+1] + OtherCondsRHSides[i+1]

    print("LepGood condition: ", GoodCondition)
    print("LepOther condition: ", OtherCondition)
    RawConditions.append(RawCondition)
    GoodConditions.append(GoodCondition)
    OtherConditions.append(OtherCondition)

# quit(3)

## Load the specified extra ROOT libraries
for lib in libs:
    root_cmd = ".L "+lib+"+"
    print("root_cmd: "+root_cmd)
    ROOT.gROOT.ProcessLine(root_cmd);

## Load TTree
if treefile is not None:
    try:
        _file = ROOT.TFile.Open(treefile,"READ")
        _file.Print()
        tree = _file.Get("tree")
        print("TTree for JPsi Initialized.\tEntries: ", tree.GetEntries())
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
    tree.AddFriend("sf/t",treePath+"/../../0_both3dlooseClean_v2/evVarFriend_JPsiToMuMu_JPsiPt8.root")
except:
    print("...friend was not able to be added, proceeding without friend tree.")

## Efficiency Calculation
events_succeed = tree.Draw(">>elist","nLepGood>0 || nLepOther>0","entrylist")
print("Events with muons:", events_succeed, " (%.2f %%)"%(100*events_succeed/float(tree.GetEntries()) ) )
elist = ROOT.gDirectory.Get('elist')
# tree.SetEntryList(ROOT.gDirectory.Get('elist'))
print(elist.GetN())

lepPassed = [ 0 for i in range(0,len(RawConditions)) ]; evPassed = [ 0 for i in range(0,len(RawConditions)) ]
inclusiveEvents = 0; inclusiveLeps = 0
for i in range(0,elist.GetN()):
    if debug:
        if i > debugEntries:
            break
        elif i%10000 == 0:
            print(i)

    if i == 0: #get the entry and the event from TTree
        ev = elist.GetEntry(0)
    else:
        ev = elist.Next()
    tree.GetEntry(ev)

    nLepGood = getattr(tree,"nLepGood")
    nLepOther = getattr(tree,"nLepOther")
    if not other_only:
        inclusiveLeps += nLepGood
    if not good_only:
        inclusiveLeps += nLepOther
    if good_only or other_only:
        if good_only and nLepGood > 0:
            inclusiveEvents += 1
        elif other_only and nLepOther > 0:
            inclusiveEvents += 1
    else:
        inclusiveEvents += 1

    ## Iterate over all leps
    ev_lepPassed = []
    if do_ev_eff:
        ev_lepPassed = [ 0 for c in range(0,len(RawConditions)) ] 
    for cond in range(0,len(RawConditions)):
        if not other_only:
            for lep in range(0,nLepGood):
                if eval(GoodConditions[cond]):
                    lepPassed[cond] += 1
                    if do_ev_eff: ev_lepPassed[cond] += 1                
        if not good_only:
            for lep in range(0,nLepOther):
                if eval(OtherConditions[cond]):
                    lepPassed[cond] += 1
                    if do_ev_eff: ev_lepPassed[cond] += 1
        if do_ev_eff and ev_lepPassed[cond] >= ev_leps_req:
            evPassed[cond] += 1

for i,cond in enumerate(RawConditions):
    if do_ev_eff:
        print("Cut: ", cond,
              "\tLepton Efficiency = ", "%.2f %%" %(100*lepPassed[i]/float(inclusiveLeps)),
              "\tEvent Efficiency (nlep>=%d) = " %ev_leps_req, "%.2f %%" %(100*evPassed[i]/float(inclusiveEvents)))
    else:
        print("Cut: ", cond,
              "\tLepton Efficiency = ", "%.2f %%" %(100*lepPassed[i]/float(inclusiveLeps)))

print("Denominators: %d leptons, %d events" %(inclusiveLeps,inclusiveEvents))
print("Timing: %s sec" %(time.time()-started_at))
quit(0)
