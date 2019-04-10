import argparse, os
from ROOT import TFile, TTree

parser = argparse.ArgumentParser(description='Compares the entries of tree1 and tree2.')
parser.add_argument('tree1', type=str, help='Directory for tree1.')
parser.add_argument('tree2', type=str, help='Directory for tree2.')
parser.add_argument('--events', type=int, help='Entire initial sample which the tree producers have processed.')
#parser.print_help()
args = parser.parse_args()

file1 = args.tree1+"/treeProducerSusyMultilepton/tree.root"
file2 = args.tree2+"/treeProducerSusyMultilepton/tree.root"
if os.path.isfile(file1):
    tfile1 = TFile.Open(args.tree1+"/treeProducerSusyMultilepton/tree.root")
    tree1 = tfile1.Get('tree')
else:
    print "File", file1, "doesn't exist."
    quit(1)
if os.path.isfile(file2):
    tfile2 = TFile.Open(args.tree2+"/treeProducerSusyMultilepton/tree.root")
    tree2 = tfile2.Get('tree')
else:
    print "File", file2, "doesn't exist."
    quit(1)

## Printing Results
print 'Printing Results:'
print 'Tree1 = '+str(tree1.GetEntries())+' entries ('+str(100*tree1.GetEntries()/args.events)+'%)'
print 'Tree2 = '+str(tree2.GetEntries())+' entries ('+str(100*tree2.GetEntries()/args.events)+'%)'

quit(0)
