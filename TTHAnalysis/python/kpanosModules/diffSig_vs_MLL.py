from __future__ import print_function
import math
from array import array
from ROOT import TCanvas, gPad, gStyle, TH1F
from ROOT import kBlue, kMagenta, kPink, kRed, kOrange, kYellow
gStyle.SetTitleFontSize(0.08)
gStyle.SetOptStat(False)

def diffSig_vs_MLL(inputdir, args):
    if args.show_args:
        print("Plotting function: diffSig_vs_MLL")
        print("required: --files <root-dir> --names root_dir --filestype dir --signals <signals> --out-dir <dir-under-www>")
        return

    ## seperate dirs into Alternative and Original
    print("Input directory given {}".format(inputdir.values()[0]))

    ## colors to be used for the histograms
    colors = { "SOS530" : kBlue,
               "ALT34"  : kMagenta, "ALT45" : kPink+5,
               "ALT330" : kRed, "ALT430"    : kOrange, "ALT530" : kYellow }

    for i,sig in enumerate(args.signals.split(',')):
        signame = sig

        ## define TH1s
        xbins = array('d', [1,4,20,50])
        histos = { "SOS530" : TH1F( "SOS530", "Significance({}) vs MLL;MLL (GeV);s/#sqrt{{b}}".format(signame), 3, xbins ),

                   "ALT330" : TH1F( "ALT330", "Significance({}) vs MLL;MLL (GeV);s/#sqrt{{b}}".format(signame), 3, xbins ),
                   "ALT430" : TH1F( "ALT430", "Significance({}) vs MLL;MLL (GeV);s/#sqrt{{b}}".format(signame), 3, xbins ),
                   "ALT530" : TH1F( "ALT530", "Significance({}) vs MLL;MLL (GeV);s/#sqrt{{b}}".format(signame), 3, xbins ),

                   "ALT34"  : TH1F( "ALT34" , "Significance({}) vs MLL;MLL (GeV);s/#sqrt{{b}}".format(signame), 3, xbins ),
                   "ALT45"  : TH1F( "ALT45" , "Significance({}) vs MLL;MLL (GeV);s/#sqrt{{b}}".format(signame), 3, xbins ) }

        ## loop on the histograms
        print("-----> Will plot Sig-vs-MLL for {}".format(signame))
        for name,hist in histos.items():
            signif, yErr = 0.0, 0.0

            ## loop on the bins
            for _bin,(x1,x2) in enumerate( zip(xbins[:-1],xbins[1:]) ):
                print("Getting value for {} and MLL bin {}-{}".format(name,x1,x2),end=', ')

                ## getting the directory
                _dir = inputdir.values()[0]
                if (x1,x2) == (1,4):
                    _dir += "/MLL_1.0_4.0/"
                elif (x1,x2) == (4,20):
                    _dir += "/MLL_4.0_20.0/"
                elif (x1,x2) == (20,50):
                    _dir += "/MLL_20.0_50.0/"
                else:
                    print("Unknown MLL bin")
                    quit(1)

                if "SOS" in name:
                    _dir += "Original_muPt2"
                    if x1 == 1:
                        ## fill the SOS histogram
                        hist.SetBinContent(_bin+1, 0.)
                        hist.SetBinError(_bin+1, 0.)
                        continue
                elif "ALT" in name:
                    _dir += "Alternative_muPt2"
                else:
                    print("Unknown senario")
                    quit(1)

                if "330" in name:
                    _dir += "_3.0_30.0"
                elif "430" in name:
                    _dir += "_4.0_30.0"
                elif "530" in name:
                    _dir += "_5.0_30.0"
                elif "34" in name:
                    _dir += "_3.0_4.0"
                elif "45" in name:
                    _dir += "_4.0_5.0"
                else:
                    print("Unknown Pt2 binning")
                    quit(1)

                print(_dir)
                yields_file = open(_dir+'/2018/2los_sr_low/yields.txt','r')

                ## defining the variables needed
                s, s_err = 0.0, 0.0
                ## parse info from the ALT directory
                for line in yields_file.readlines():
                    if "------" in line:
                        continue
                    _sig, _yield, _1, error, _2 = line.split()
                    if _sig == signame: ## signal yield ## put here a reference signal to compare significances
                        signif += float(_yield)
                        s += float(_yield)
                        s_err += float(error)
                    elif name == "BACKGROUND": ## bkg yield
                        bkg = float(_yield); bkg_err = float(error)
                        if bkg == 0: break
                        signif /= math.sqrt( bkg )
                        if s != 0:
                            yErr = signif*math.sqrt( s_err*s_err/(s*s) + bkg_err*bkg_err/(4*bkg*bkg) )
                        print(" -- signif:", signif, end='')
                print() ## print newline

                ## fill the histogram
                hist.SetBinContent(_bin+1, signif)
                hist.SetBinError(_bin+1, yErr)

                hist.Print()
            ##<- itr over bins
        ##<- itr over plots

        ## make the plots and save them
        canv_diffPt2 = TCanvas("canv_diffPt2","canv_diff",400,400); canv_diffPt2.cd()
        canv_intgPt2 = TCanvas("canv_intgPt2","canv_intg",400,400); canv_intgPt2.cd()
        canv_intgPt2.Print()
        canv_diffPt2.Print()
        ## customize histograms
        for i,(name,hist) in enumerate( histos.items() ):
            hist.SetLineColor( colors[name] )
            hist.SetLineWidth(2)
            # if hist.GetBinContent(3) < 1:
            #     hist.GetYaxis().SetRangeUser(0.01, 4.0)
            #     canv.SetLogy()
        ## make Pt2 integral plot
        canv_intgPt2.cd()
        histos["ALT330"].Draw()
        histos["ALT430"].Draw("same")
        histos["ALT530"].Draw("same")
        histos["SOS530"].Draw("same")
        canv_intgPt2.SetGridx()
        canv_intgPt2.SetGridy()
        canv_intgPt2.SaveAs( "/eos/home-k/kpanos/www/{}/{}-SignifVsMLL_intgPt2.png".format(args.outDir, signame.replace('/','_')) )
        canv_diffPt2.cd()
        ## make Pt2 differential plot
        histos["ALT34"].Draw()
        histos["ALT45"].Draw("same")
        histos["ALT530"].Draw("same")
        histos["SOS530"].Draw("same")
        canv_diffPt2.SetGridx()
        canv_diffPt2.SetGridy()
        canv_diffPt2.SaveAs( "/eos/home-k/kpanos/www/{}/{}-SignifVsMLL_diffPt2.png".format(args.outDir, signame.replace('/','_')) )

    ## signals loop

    return
