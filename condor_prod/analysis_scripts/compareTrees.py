import argparse
from ROOT import TFile, TTree

parser = argparse.ArgumentParser(description='Compares the entries of tree1 and tree2.')
parser.add_argument('tree1', type=str, help='Directory for tree1.')
parser.add_argument('tree2', type=str, help='Directory for tree2.')
#parser.print_help()
args = parser.parse_args()

file1 = TFile.Open(args.tree1+"/treeProducerSusyMultilepton/tree.root")
tree1 = file1.Get('tree')
file2 = TFile.Open(args.tree2+"/treeProducerSusyMultilepton/tree.root")
tree2 = file2.Get('tree')

## Printing Results
print 'Printing Results:'
print 'Tree1 = '+str(tree1.GetEntries())+' entries'
print 'Tree2 = '+str(tree2.GetEntries())+' entries'

quit(0)
