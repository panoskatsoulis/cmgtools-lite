import ROOT, sys

if len(sys.argv)<2:
    print "Usage: "+sys.argv[0]+" <root-file> [<tree-name>]"
    quit(1)
else:
    try:
        _file = ROOT.TFile(sys.argv[1], "READ")
        if len(sys.argv) > 2:
            tree = _file.Get(sys.argv[2])
        else:
            tree = _file.Get("tree")
    except:
        print "TFile or TTree has not been initialized."
        quit(1)

tree.Print("all")
quit(0)
