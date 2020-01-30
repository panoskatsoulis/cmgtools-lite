#!/usr/bin/env python
import ROOT, argparse

parser = argparse.ArgumentParser(description='Check a list of files if they are corrupted.')
parser.add_argument('--owns', metavar='TREESA', nargs='+', help="Trees cluster A")
parser.add_argument('--theirs', metavar='TREESB', nargs='+', help="Trees cluster B")
args = parser.parse_args()

if len(args.owns) != len(args.theirs):
    print "Non-equal number of tree clusters."
    quit(1)

for A,B in zip(args.owns,args.theirs):
    fileA = ROOT.TFile.Open(A)
    fileB = ROOT.TFile.Open(B)
    if not (fileA and fileB):
        continue
    Nowns = fileA.Get("Events").GetEntries()
    Ntheirs = fileB.Get("Events").GetEntries()
    res = "OK" if Nowns > Ntheirs else "NOT OK"
    print A, B, "\nEntries:", Nowns, "|", Ntheirs, res

quit(0)
