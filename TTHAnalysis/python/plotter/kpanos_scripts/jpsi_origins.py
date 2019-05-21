import ROOT, sys, subprocess

if len(sys.argv) > 1:
    try:
        file_jpsi = ROOT.TFile.Open(sys.argv[1]+"/treeProducerSusyMultilepton/tree.root","READ")
        file_jpsi.Print()
        tree_jpsi = file_jpsi.Get("tree")
        print "TTree for JPsi Initialized.\tEntries: ", tree_jpsi.GetEntries()
    except:
        print(sys.argv)
        print("TTree for JPsi didn't initialize correctly. Exiting..")
        quit(1)
else:
    print("Usage: sys.argv[0] <jpsi-process-dir>")
    quit(1)

cuts = []
debug = False
if len(sys.argv) > 2:
    for i,arg in enumerate(sys.argv):
        if i < 2:
            continue
        else:
            if arg == "--cut":
                cuts.append(sys.argv[i+1])
            if arg == "--debug":
                debug = True
    print "cuts: ", cuts

## Try to add friends
treePath = subprocess.check_output("dirname "+sys.argv[1], shell=True).strip("\n")
process = subprocess.check_output("basename "+sys.argv[1], shell=True).strip("\n")
print("Will now try to add friend from the path "+treePath+"/0_both3dlooseClean_v2, for process "+process)
tree_jpsi.AddFriend("sf/t",treePath+"/0_both3dlooseClean_v2/evVarFriend_"+process+".root")
print("Will now try to add friend from the path "+treePath+"/0_eventBTagWeight_v2, for process "+process)
tree_jpsi.AddFriend("sf/t",treePath+"/0_eventBTagWeight_v2/evVarFriend_"+process+".root")

## If Cuts have been requested, apply them on the tree and generate a new cut tree.
if len(cuts) > 0:
    file_cut_trees = ROOT.TFile.Open("file_cut_trees.root","RECREATE")
    cut_trees = [tree_jpsi]
    for i,cut in enumerate(cuts):
        cut_trees.append(cut_trees[-1].CopyTree(cut))
        print 'TTree entries after cut ', cut, "\t", cut_trees[-1].GetEntries() 
        cut_trees[-1].Write('tree_'+str('_'.join(cuts[:i+1])))
    tree_jpsi = cut_trees[-1]
    if debug:
        print 'tree_jpsi entries: ', tree_jpsi.GetEntries(), '\tcut_trees[-1] entries: ', cut_trees[-1].GetEntries()

for event in range(0,tree_jpsi.GetEntries()):
    if debug and event == 10: break

    tree_jpsi.GetEntry(event)
    print "--------< NEW EVENT >--------"

    genParticleIds = getattr(tree_jpsi, "genId")
    genMothers = getattr(tree_jpsi, "genMother")

    particles = [part for part in genParticleIds]; print 'particles: ', particles
    mothers = [part for part in genMothers]; print '  mothers: ', mothers
    plist = []
    if debug: print plist
    target = None

    ## 1) Find JPsi and its mom
    if 443 in particles:
        jpsi_idx = particles.index(443)
        mom = mothers.pop(jpsi_idx)
        plist.append(particles.pop(jpsi_idx))
        plist.append(mom)
        target = mom
        if debug:
            print 'particles: ', particles
            print '  mothers: ', mothers
    else:
        print "Result:\tJPsi has not been found."
        continue

    ## 2) Propagate back to the rest of the particles
    target_found = True # get in the while loop
    while target_found:
        target_found = False
        for i,particle in enumerate(particles):
            if particle == target:
                target_found = True
                mom = mothers.pop(i) # get mom[i] and remove it from mothers
                particles.pop(i) # remove target from the list particles
                plist.append(mom)
                target = mom
                break
        if debug:
            print 'particles: ', particles
            print '  mothers: ', mothers

    plist.reverse()
    print "Result:\t", plist

quit(0)
