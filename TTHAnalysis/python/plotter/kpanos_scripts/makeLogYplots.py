import ROOT, sys

if len(sys.argv) > 1:
    try:
        plotfile = ROOT.TFile.Open(sys.argv[1],"READ")
        plotfile.Print()
    except:
        print(sys.argv)
        print("Couldn't open the file.")
        quit(1)
else:
    print("Usage: sys.argv[0] <plots-root-file>")
    quit(1)

## Find output dir name
import subprocess
treePath = subprocess.check_output("dirname "+sys.argv[1], shell=True).strip("\n")

hasRatio = False
try:
    if sys.argv[2] == "--hasRatio":
        hasRatio = True
except:
    print "--hasRatio arg has not been found."

## Modify plots
## HT plot
plot_ht = plotfile.Get("htJet25_canvas")
if hasRatio:
    primList = plot_ht.GetPad(0).GetListOfPrimitives()[0].GetListOfPrimitives()
else:
    primList = plot_ht.GetPad(0).GetListOfPrimitives()
hist = primList[1]; yaxis = hist.GetYaxis()
yaxis.SetRangeUser(hist.GetMinimum()+0.0001, hist.GetMaximum())
print hist.GetMinimum(), hist.GetMaximum()
plot_ht.SetLogy()
plot_ht.Print(treePath+"/htJet25_logY.png","png")

## MET plot
plot_met = plotfile.Get("met_canvas")
if hasRatio:
    primList = plot_ht.GetPad(0).GetListOfPrimitives()[0].GetListOfPrimitives()
else:
    primList = plot_ht.GetPad(0).GetListOfPrimitives()
hist = primList[1]; yaxis = hist.GetYaxis()
yaxis.SetRangeUser(hist.GetMinimum()+0.0001, hist.GetMaximum())
print hist.GetMinimum(), hist.GetMaximum()
plot_met.SetLogy()
plot_met.Print(treePath+"/met_logY.png","png")

## Mll plot
plot_mll = plotfile.Get("mll_canvas")
if hasRatio:
    primList = plot_ht.GetPad(0).GetListOfPrimitives()[0].GetListOfPrimitives()
else:
    primList = plot_ht.GetPad(0).GetListOfPrimitives()
hist = primList[1]; yaxis = hist.GetYaxis()
yaxis.SetRangeUser(hist.GetMinimum()+0.0001, hist.GetMaximum())
print hist.GetMinimum(), hist.GetMaximum()
plot_mll.SetLogy()
plot_mll.Print(treePath+"/mll_logY.png","png")
#except:
#print "Some problem occured, exception caught."
#quit(2)

quit(0)

