from __future__ import print_function
import argparse

##------> Parser
parser = argparse.ArgumentParser(description="Make Correlation Maps for the given variables")
parser.add_argument('--varPairs', metavar='FILE', help='Pairs of variables to plot. Different pair different line')
parser.add_argument('--tree', metavar='TREE', help='NanoAOR file (sample) to test')
parser.add_argument('--ftree', metavar='FTREE', help='Friend tree file (sample) to attachto the TREE')
parser.add_argument('--out', metavar='PATH', help='Directory to store the TGraphs')
args = parser.parse_args()

##------> Open files and create the output dir if it doesn't exist
import os,sys
from analysisTools import getTFileTree
## open varPairs
varPairsFile = open(args.varPairs,'r')
varPairs = []
for pair in varPairsFile.readlines():
    if not pair.startswith("#"):
        varPairs.append( tuple(pair.strip('\n').split(',')) )
print("Will make correlation maps for the following pairs:")
print(varPairs)
print()
## open tree and attach friend tree
ft_tree = getTFileTree(args.tree,"Events")
ft_friend = getTFileTree(args.ftree,"Friends")
ft_tree["tree"].AddFriend( ft_friend["tree"] )

##------> Make Corr Maps, loop over var pairs
from analysisTools import getBranchArray
from ROOT import TGraph, TCanvas, TH1F, TVectorF
from array import array
tree = ft_tree["tree"]
for var1,var2 in varPairs:
    ## make TGraph
    ev = tree.GetEntries()
    var1_array = getBranchArray(var1,tree)
    var2_array = getBranchArray(var2,tree)
    graph = TGraph(ev,var1_array,var2_array); graph.SetTitle("Var {}, {} Correlation;{};{}".format(var1,var2,var1,var2))
    graph.SetMarkerStyle(6)
    hist1 = TH1F(); hist2 = TH1F()
    hist1.SetTitle( "Variable {}; {}".format(var1,var1) ); hist1.SetBins(100,0,20)
    hist1.FillN( ev, var1_array, array('d', [1 for i in range(ev)]) )
    hist2.SetTitle( "Variable {}; {}".format(var2,var2) ); hist2.SetBins(100,0,20)
    hist2.FillN( ev, var2_array, array('d', [1 for i in range(ev)]) )
    ## make TCanvas
    canv = TCanvas("canv1","canv1",400,400); canv.cd()
    graph.Draw("AP") ##--- draw corr plot
    canv.SaveAs( "{}/Correlation_{}_{}.png".format(args.out, var1, var2) )
    hist1.Draw() ##--- draw var1 hist
    canv.SaveAs( "{}/Variable_{}.png".format(args.out, var1) ); canv.SetLogy()
    hist2.Draw() ##--- draw var2 hist
    canv.SaveAs( "{}/Variable_{}.png".format(args.out, var2) ); canv.SetLogy()

quit(0)
    
