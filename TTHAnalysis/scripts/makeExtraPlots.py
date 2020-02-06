#!/usr/bin/env python
from __future__ import print_function
import argparse, sys, math, os, re
from collections import OrderedDict
from array import array

##------> Plots
knownFuncs = ['SigVsMassPoints','OptimizeMu2PtCut','diffSig_vs_PtMu2','MLLplots_perSample']
newPlots = ['diffSig_vs_PtMu2','MLLplots_perSample']

##------> Parser
parser = argparse.ArgumentParser(description='Make Analysis Plots. Known Functions: '+', '.join(knownFuncs))
parser.add_argument('--files', metavar='files', help='Comma separated files that include the CMG plots.')
parser.add_argument('--names', metavar='names', help='Comma separated names for each root file given.')
parser.add_argument('--deltaMs', help='Comma separated values of deltaM.')
parser.add_argument('--out-dir', dest='outDir', help='Directory to store the plots.')
parser.add_argument('--plots', nargs='+', help='Plots to make.')
parser.add_argument('--save-root', action='store_true', default=False, help='Create a ROOT file with the outputs and the products.')
parser.add_argument('--filestype', help='Specifies what type are the input files given. ("root","dir")')
parser.add_argument('--show-args', action='store_true', default=False, help='Show the requires arguments for each plotting function.')
parser.add_argument('--signals', default="", help='Comma separated signal names to process.')

##------> Parse args and check their validity
args = parser.parse_args()
if not args.show_args:
    _files = args.files.split(',')
    names = args.names.split(',')
    if len(_files) != len(names):
        raise RuntimeError("Names and files given are not equal.")

##------> Necessary libs from ROOT
from ROOT import TGraph, TMultiGraph, TFile, TTree, TGraphErrors, TCanvas, TPad, gPad, gStyle, Double
gStyle.SetTitleFontSize(0.08)
if args.save_root:
    if not args.outDir:
        raise RuntimeError("The option --save-root requires --out-dir to be given too.")
    save_file = TFile.Open("/eos/home-k/kpanos/www/{}/plots.root".format(args.outDir),"RECREATE")
    save_file.Print()

##------> Try to open the files
def openTFile(_file):
    f = TFile.Open(_file)
    if not f:
        raise RuntimeError("File "+_file+" not found.")
    if f.IsZombie():
        raise RuntimeError("File "+_file+" is zombie.")
    return f


def SigVsMassPoints(files):
    if args.show_args:
        print("Plotting function: SigVsMassPoints")
        print("required: --not implemented yet--")
        return

    ## get files
    print("Will make plots SigVsMassPoints")
    sosFile, altFile = files["2los_sos"], files["2los_alt"]

    ## get bkgs
    sos_bkg_err, alt_bkg_err = Double(0.), Double(0.)
    sos_bkg = sosFile.Get("yields_background").IntegralAndError(1, sosFile.Get("yields_background").GetNbinsX(), sos_bkg_err)
    alt_bkg = altFile.Get("yields_background").IntegralAndError(1, altFile.Get("yields_background").GetNbinsX(), alt_bkg_err)
    print("BKG yields:\tSOS={} ({}), ALT={} ({})".format(sos_bkg, sos_bkg_err, alt_bkg, alt_bkg_err) )

    ## get sigs, calc s/sqrt(b), ratios, errors and create graphs
    graphs = {}
    deltaMs = list( map( int, args.deltaMs.split(',') ) )
    print("DeltaM values chosen,", deltaMs)
    for dM in deltaMs: ## deltaM loop (aka loop over diff plots)
        print("----------"*16)
        ## create arrays for the TGraphs
        Mpoints = [150, 200, 225, 250, 275]
        x = array('d', Mpoints)
        ysos, ysos_err = array('d'), array('d')
        yalt, yalt_err = array('d'), array('d')
        yrat, yrat_err = array('d'), array('d')
        for Mp in Mpoints: ## mass point loop (aka loop over diff x-axis points)
            ## get signal histo and check if are null
            sig_name = "yields_signal_TChiWZ_"+str(Mp)+'_'+str(Mp-dM)
            h_sig_sos = sosFile.Get(sig_name)
            h_sig_alt = altFile.Get(sig_name)
            if not h_sig_sos:
                print("Missing", sig_name, "from SOS TFile.")
            if not h_sig_alt:
                print("Missing", sig_name, "from ALT TFile.")
            if not (h_sig_sos or h_sig_alt):
                print("Skipping Mp={} for dM {} because of missing plots in the TFiles.".format(Mp, dM))
                continue
            ## calculate signal yields and errors
            sos_sig_err, alt_sig_err = Double(-99.), Double(-99.)
            sos_sig = h_sig_sos.IntegralAndError(1, h_sig_sos.GetNbinsX(), sos_sig_err)
            alt_sig = h_sig_alt.IntegralAndError(1, h_sig_alt.GetNbinsX(), alt_sig_err)
            ## calculate s/sqrtb and errors
            sos_SsqrtB = sos_sig/math.sqrt(sos_bkg)
            alt_SsqrtB = alt_sig/math.sqrt(alt_bkg)
            sos_SsqrtB_err, alt_SsqrtB_err = -99, -99
            if sos_sig != 0. and sos_bkg != 0.:
                sos_SsqrtB_err = sos_SsqrtB*math.sqrt( sos_sig_err*sos_sig_err/(sos_sig*sos_sig) + sos_bkg_err*sos_bkg_err/(2*sos_bkg*sos_bkg) )
            if alt_sig != 0. and alt_bkg != 0.:
                alt_SsqrtB_err = alt_SsqrtB*math.sqrt( alt_sig_err*alt_sig_err/(alt_sig*alt_sig) + alt_bkg_err*alt_bkg_err/(2*alt_bkg*alt_bkg) )
            ## calculate ratio and error
            ratio, ratio_err = -99., -99.
            if sos_SsqrtB != 0 and alt_SsqrtB != 0:
                ratio = alt_SsqrtB/sos_SsqrtB if sos_SsqrtB != 0 else 0.0
                ratio_err = ratio*math.sqrt( alt_SsqrtB_err*alt_SsqrtB_err/(alt_SsqrtB*alt_SsqrtB) + sos_SsqrtB_err*sos_SsqrtB_err/(sos_SsqrtB*sos_SsqrtB) )
            ## make a nice print
            print( "TChi{}/{}\t|*|SIG(SOS)={:06.3f} ({:.3f}), S/sqrtB={:.3f} ({:.3f})\t|*|SIG(ALT)={:06.3f} ({:.3f}), S/sqrtB={:.3f} ({:.3f})\t|*|Ratio={:.4f} ({:.3f})".format(
                Mp, dM,
                sos_sig, sos_sig_err, sos_SsqrtB, sos_SsqrtB_err,
                alt_sig,alt_sig_err, alt_SsqrtB, alt_SsqrtB_err,
                ratio, ratio_err )
            )
            ## fill the graphs
            ysos.append(sos_SsqrtB if sos_SsqrtB >= 0 else 0 )
            yalt.append(alt_SsqrtB if alt_SsqrtB >= 0 else 0 )
            yrat.append(ratio if ratio >= 0 else 0 )
            ysos_err.append(sos_SsqrtB_err if sos_SsqrtB_err >= 0 else 10)
            yalt_err.append(alt_SsqrtB_err if alt_SsqrtB_err >= 0 else 10)
            yrat_err.append(ratio_err if ratio_err >= 0 else 10)
        graphs["sosGrph_dM"+str(dM)] = TGraphErrors(len(x), x, ysos, array('d',[0]*len(x)), ysos_err)
        graphs["altGrph_dM"+str(dM)] = TGraphErrors(len(x), x, yalt, array('d',[0]*len(x)), yalt_err)
        graphs["ratGrph_dM"+str(dM)] = TGraphErrors(len(x), x, yrat, array('d',[0]*len(x)), yrat_err)

    ## make canvases
    for dM in deltaMs:
        c = TCanvas("canv"+str(dM), "SigVsMassPoints dM="+str(dM), 500, 600)
        p1 = TPad("pad_plot","S/sqrtB vs Mp", 0.0, 0.3, 1.0, 1.0)
        p2 = TPad("pad_ratio","ratio", 0.0, 0.0, 1.0, 0.3)
        c.cd(); p1.Draw(); p2.Draw("same")
        p1.cd()
        gPad.SetLogy(); gPad.SetGridx(); gPad.SetGridy()
        altGrph = graphs["altGrph_dM"+str(dM)]
        altGrph.Draw()
        altGrph.SetTitle("S/sqrtB Vs Mpoint (dm={});Mass Point (GeV);S/sqrtB".format(dM))
        altGrph.SetLineColor(2)
        altGrph.SetLineWidth(2)
        altGrph.GetXaxis().SetLabelSize(0.035)
        altGrph.GetYaxis().SetTitleOffset(0.5)
        altGrph.GetYaxis().SetRangeUser(0.001, 5.)
        sosGrph = graphs["sosGrph_dM"+str(dM)]
        sosGrph.Draw("same")
        sosGrph.SetLineColor(4)
        sosGrph.SetLineWidth(2)
        p2.cd()
        gPad.SetGridx(); gPad.SetGridy()
        ratGrph = graphs["ratGrph_dM"+str(dM)]
        ratGrph.Draw()
        ratGrph.SetTitle("Ratio")
        ratGrph.SetMarkerStyle(11)
        ratGrph.GetXaxis().SetLabelSize(0.09)
        ratGrph.GetYaxis().SetTitle("alt/sos")
        ratGrph.GetYaxis().SetLabelSize(0.09)
        ratGrph.GetYaxis().SetTitleSize(0.09)
        ratGrph.GetYaxis().SetTitleOffset(0.5)
        c.SaveAs("/eos/home-k/kpanos/www/{}/SigVsMassPoints_{}.png".format(args.outDir, dM))
        if args.save_root:
            save_file.cd()
            c.Write()
    ## save graphs if has been requested
    if args.save_root:
        save_file.cd()
        for g in graphs.values():
            g.Write()
    return


def OptimizeMu2PtCut(dirs):
    if args.show_args:
        print("Plotting function: OptimizeMu2PtCut")
        print("required: --files <dirs> --names <names> --filestype dir --signals <signals> --out-dir <dir-under-www>")
        return

    ## seperate dirs into Alternative and Original
    dirs_ALT = {}; dirs_SOS = {}
    for key,value in dirs.items():
        if "Original" in key:
            dirs_SOS[key] = value
        elif "Altrernative" in key:
            dirs_ALT[key] = value
        else:
            raise RuntimeError("Unknown key to process. "+key)

    for i,sig in enumerate(args.signals.split(',')):
        ## define arrays for TGraphs
        ptcut, WjYield, WjErr, SignifsALT, SignifsSOS = array('d'), array('d'), array('d'), array('d'), array('d')
        ALT_yErr, SOS_yErr = array('d'), array('d')

        ## loop on the dirs
        signame = sig
        ord_ALT_dirs = OrderedDict( sorted(dirs_ALT.items()) ).values()
        ord_SOS_dirs = OrderedDict( sorted(dirs_SOS.items()) ).values()
        for alt_dir,sos_dir in zip(ord_ALT_dirs,ord_SOS_dirs):
            ptcut_file = open(alt_dir+'/mu2ptcut.txt','r')
            altYields_file = open(alt_dir+'/yields.txt','r')
            sosYields_file = open(sos_dir+'/yields.txt','r')
            _ptcut = float(ptcut_file.read())
            ptcut.append( _ptcut )
            print("Getting values for",_ptcut,end=', ')
            signifALT_tmp = 0
            signifSOS_tmp = 0
            s_alt, s_alt_err, s_sos, s_sos_err = 0, 0, 0, 0
            for altLine,sosLine in zip(altYields_file.readlines(),sosYields_file.readlines()):
                if "------" in altLine or "------" in sosLine:
                    continue
                ## parse info from the ALT directory
                name, _yield, _1, error, _2 = altLine.split()
                if name == signame: ## signal yield ## put here a reference signal to compare significances
                    signifALT_tmp += float(_yield)
                    s_alt += float(_yield)
                    s_alt_err += float(error)
                elif name == "Wj(fakes)": ## Wj(fakes) yield and error
                    WjYield.append( float(_yield) )
                    WjErr.append( float(error) )
                    print("Yield:",_yield," Err:",error,end=', ')
                elif name == "BACKGROUND": ## bkg yield
                    signifALT_tmp /= math.sqrt( float(_yield) )
                    SignifsALT.append( signifALT_tmp )
                    ALT_yErr.append( signifALT_tmp*math.sqrt( s_alt_err*s_alt_err/(s_alt*s_alt) + float(error)*float(error)/(4*float(_yield)*float(_yield)) ) )
                    print("signif:",signifALT_tmp,end=', ')
                ## now from the SOS directory
                name, _yield, _1, error, _2 = sosLine.split()
                if name == signame: ## signal yield ## put here a reference signal to compare significances
                    signifSOS_tmp += float(_yield)
                    s_sos += float(_yield)
                    s_sos_err += float(error)
                elif name == "BACKGROUND": ## bkg yield
                    signifSOS_tmp /= math.sqrt( float(_yield) )
                    SignifsSOS.append( signifSOS_tmp )
                    SOS_yErr.append( signifSOS_tmp*math.sqrt( s_sos_err*s_sos_err/(s_sos*s_sos) + float(error)*float(error)/(4*float(_yield)*float(_yield)) ) )
                    print("signif:",signifSOS_tmp)
            if len(WjYield) != len(WjErr) or len(WjYield) != len(SignifsALT) or len(WjYield) != len(SignifsSOS) or len(WjYield) != len(ptcut) or len(ALT_yErr) != len(ptcut) or len(SOS_yErr) != len(ptcut):
                raise RuntimeError( "The arrays ptcut, WjYield, WjErr and SignifsALT are not of the same size. Problem occured at ptcut="+ptcut_file.read() )

        ## make TGraphs and change style
        #SignifALT_vsPt = TGraphErrors(len(ptcut), ptcut, SignifsALT, array('d', [0 for l in range(len(ptcut))]), ALT_yErr)
        SignifALT_vsPt = TGraph(len(ptcut), ptcut, SignifsALT)
        SignifALT_vsPt.SetLineColor(2); SignifALT_vsPt.SetLineWidth(2)
        #SignifSOS_vsPt = TGraphErrors(len(ptcut), ptcut, SignifsSOS, array('d', [0 for l in range(len(ptcut))]), SOS_yErr)
        SignifSOS_vsPt = TGraph(len(ptcut), ptcut, SignifsSOS)
        SignifSOS_vsPt.SetLineColor(4); SignifSOS_vsPt.SetLineWidth(2)
        ## put them on the TCanvas and save them
        canv = TCanvas("canv", "canv", 400, 400); canv.cd()
        SignifALT_vsPt.Draw("ACP")
        SignifALT_vsPt.SetTitle("Significance ("+signame+") vs PtCut;Pt(cut) [GeV]; sig")
        SignifSOS_vsPt.Draw("ACP")
        SignifSOS_vsPt.SetTitle("Significance ("+signame+") vs PtCut;Pt(cut) [GeV]; sig")
        tmg = TMultiGraph("tmg","Significance ("+signame+") vs PtCut;Pt(cut) [GeV]; s/sqrtb")
        SignifALT_vsPt.SetTitle("ALT Significance"); tmg.Add(SignifALT_vsPt)
        SignifSOS_vsPt.SetTitle("SOS Significance"); tmg.Add(SignifSOS_vsPt)
        tmg.Draw("ACP")
        canv.BuildLegend(0.55,0.4,0.9,0.6)
        canv.SetGridx()
        canv.SetGridy()
        canv.SaveAs("/eos/home-k/kpanos/www/{}/{}-SignifAndWjErr_vsPt.png".format(args.outDir, signame))
        if os.path.isfile("/eos/home-k/kpanos/www/{}/WjErr_vsPt.png".format(args.outDir)): ## the next plots are the same for each signal
            if os.path.isfile("/eos/home-k/kpanos/www/{}/WjYields_vsPt.png".format(args.outDir)):
                continue
        ## make TGraphs and change style
        WjYields_vsPt = TGraph(len(ptcut), ptcut, WjYield)
        WjErr_vsPt = TGraph(len(ptcut), ptcut, WjErr)
        WjYields_vsPt.SetLineColor(1); WjYields_vsPt.SetLineWidth(2)
        WjErr_vsPt.SetLineColor(3); WjErr_vsPt.SetLineWidth(2)
        ## plot Wj Yields
        WjYields_vsPt.Draw("ACP")
        WjYields_vsPt.SetTitle("WjYields ("+signame+") vs PtCut;Pt(cut) [GeV]; WjYields")
        canv.SaveAs("/eos/home-k/kpanos/www/{}/WjYields_vsPt.png".format(args.outDir))
        canv.Clear()
        ## plot Wj Errors
        WjErr_vsPt.Draw("ACP")
        WjErr_vsPt.SetTitle("WjErr ("+signame+") vs PtCut;Pt(cut) [GeV]; WjErr")
        canv.SaveAs("/eos/home-k/kpanos/www/{}/WjErr_vsPt.png".format(args.outDir))
        canv.Clear()
    ## signals loop

    return

from CMGTools.TTHAnalysis.kpanosModules.diffSig_vs_PtMu2 import diffSig_vs_PtMu2
from CMGTools.TTHAnalysis.kpanosModules.MLLplots_perSample import MLLplots_perSample

##------> Main functionality
if __name__ == "__main__":
    ## test and append files/directories into the files dictionary
    files = {}
    if args.filestype == "root":
        for f,n in zip(_files,names):
            try: ## try to open the file and create the files' dictionary
                files[n] = openTFile(f)
            except Exception as e:
                print("Exception: ",e)
                quit(1)
        print("Opened",len(files),"root files.")
    elif args.filestype == "dir":
        for f,n in zip(_files,names):
            try:
                if os.path.isdir(f):
                    files[n] = f
                else:
                    raise EnvironmentError("Directory "+f+" doesn't exist.")
            except Exception as e:
                print("Exception: ",e)
                quit(1)
    else:
        if not args.show_args:
            print("Unknown input files' type given.")
            quit(1)

    ## loop over the requested functions and execute them
    for plot in args.plots:
        try:
            if not plot in knownFuncs:
                raise RuntimeError("Unknown code has been asked to run.")
            if plot in newPlots:
                print("Running... {}(files,args)".format(plot))
                exec(plot+'(files,args)')
            else:
                print("Running... {}(files)".format(plot))
                exec(plot+'(files)')
        except Exception as err:
            print("Plotting failure has been caught. Plot:", plot)
            print("Exception caught:", err)

    ## print the command ran into a file
    if args.outDir:
        user = os.environ['USER']
        command = ""
        for arg in sys.argv:
            command += ' '+arg
        if "www" in args.outDir:
            args.outDir = re.sub(r"/eos/.*/{}/www/".format(user),"",args.outDir)
        cmd_file = open("/eos/home-{}/{}/www/{}/command.txt".format(user[0],user,args.outDir),"w+")
        cmd_file.write("Command:\n")
        cmd_file.write(command)
        cmd_file.close()

    quit(0)
