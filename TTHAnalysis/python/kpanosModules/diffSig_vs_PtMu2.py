from __future__ import print_function
import math
from array import array
from ROOT import TCanvas, gPad, gStyle, TH1F
gStyle.SetTitleFontSize(0.08)
gStyle.SetOptStat(False)

def diffSig_vs_PtMu2(dirs, args):
    if args.show_args:
        print("Plotting function: diffSig_vs_PtMu2")
        print("required: --files <dirs> --names <names> --filestype dir --signals <signals> --out-dir <dir-under-www>")
        return

    ## seperate dirs into Alternative and Original
    dirs_ALT = {}; dirs_SOS = {}
    for key,value in dirs.items():
        if "Original" in key:
            dirs_SOS[key] = value
        elif "Alternative" in key:
            dirs_ALT[key] = value
        else:
            raise RuntimeError("Unknown key to process. "+key)

    ## pt binnings (per plot)
    xaxes = { #"plot1" : array('d', [3,5,30]),
              #"plot2" : array('d', [3,4,5,30])
              "plot3" : array('d', [3,4,5,6])
              #"plot4" : array('d', [3,3.7,4.4,5,6]) 
    }

    for i,sig in enumerate(args.signals.split(',')):
        signame = sig

        ## define TH1s
        histosALT = { #"plot1" : TH1F("ALTsigVpt1", "Significance({}) vs Pt;Pt (GeV);s/#sqrt{{b}}".format(signame), 2, xaxes["plot1"]),
                      #"plot2" : TH1F("ALTsigVpt2", "Significance({}) vs Pt;Pt (GeV);s/#sqrt{{b}}".format(signame), 3, xaxes["plot2"])
                      "plot3" : TH1F("ALTsigVpt3", "Significance({}) vs Pt;Pt (GeV);s/#sqrt{{b}}".format(signame), 3, xaxes["plot3"]),
                      #"plot4" : TH1F("ALTsigVpt4", "Significance({}) vs Pt;Pt (GeV);s/#sqrt{{b}}".format(signame), 4, xaxes["plot4"])
        }

        histosSOS = { #"plot1" : TH1F("SOSsigVpt1", "Significance({}) vs Pt;Pt (GeV);s/#sqrt{{b}}".format(signame), 2, xaxes["plot1"]),
                      #"plot2" : TH1F("SOSsigVpt2", "Significance({}) vs Pt;Pt (GeV);s/#sqrt{{b}}".format(signame), 3, xaxes["plot2"])
                      "plot3" : TH1F("SOSsigVpt3", "Significance({}) vs Pt;Pt (GeV);s/#sqrt{{b}}".format(signame), 3, xaxes["plot3"]),
                      #"plot4" : TH1F("SOSsigVpt4", "Significance({}) vs Pt;Pt (GeV);s/#sqrt{{b}}".format(signame), 4, xaxes["plot4"])
        }

        ## loop on the plots(x-axes)
        print("-----> Will plot Sig-vs-Pt for {}".format(signame))
        for plot,bins in xaxes.items():
            signifALT, signifSOS = 0.0, 0.0
            ALT_yErr, SOS_yErr = 0.0, 0.0
            for _bin,(x1,x2) in enumerate( zip(bins[:-1],bins[1:]) ):
                ## getting the directory
                name = "Alternative_muPt2_{}_{}".format(x1,x2)
                if x1 >= 5.:
                    name = "Alternative_muPt2_5.0_30.0"
                alt_dir = None #for error checking
                alt_dir = dirs_ALT[name]
                ## print("alt_dir: {}".format(alt_dir))
                if not alt_dir:
                    raise RuntimeError("Directory with name {} does not exist in the list.".format(name))
                altYields_file = open(alt_dir+'/yields.txt','r')
                ## defining the variables needed
                s_alt, s_alt_err = 0.0, 0.0
                ## parse info from the ALT directory
                for altLine in altYields_file.readlines():
                    ## print( "alt-line: {}".format(altLine) )
                    if "------" in altLine:
                        continue
                    name, _yield, _1, error, _2 = altLine.split()
                    if name == signame: ## signal yield ## put here a reference signal to compare significances
                        signifALT += float(_yield)
                        s_alt += float(_yield)
                        s_alt_err += float(error)
                        # elif name == "Wj(fakes)": ## Wj(fakes) yield and error
                        #     WjYield.append( float(_yield) )
                        #     WjErr.append( float(error) )
                        #     print("Yield:",_yield," Err:",error,end=', ')
                    elif name == "BACKGROUND": ## bkg yield
                        bkg = float(_yield); bkg_err = float(error)
                        if bkg == 0: break
                        signifALT /= math.sqrt( bkg )
                        if s_alt != 0:
                            ALT_yErr = signifALT*math.sqrt( s_alt_err*s_alt_err/(s_alt*s_alt) + bkg_err*bkg_err/(4*bkg*bkg) )
                print("bin: {}-{}, signif-ALT = {} +/- {}".format(x1,x2,signifALT,ALT_yErr))
                ## parse info from the SOS directory (if needed)
                if x1 >= 5.:
                    name = "Original_muPt2_5.0_30.0".format(x1,x2)
                    # name = "Original_muPt2_{}_{}".format(x1,x2)
                    sos_dir = None
                    sos_dir = dirs_SOS[name]
                    ## print("sos_dir: {}".format(sos_dir))
                    if not sos_dir:
                        raise RuntimeError("Directory with name {} does not exist in the list.".format(name))
                    sosYields_file = open(sos_dir+'/yields.txt','r')
                    ## defining the variables needed
                    s_sos, s_sos_err = 0.0, 0.0
                    for sosLine in sosYields_file.readlines():
                        ## print( "sos-line: {}".format(sosLine) )
                        if "------" in sosLine:
                            continue
                        name, _yield, _1, error, _2 = sosLine.split()
                        if name == signame: ## signal yield
                            signifSOS += float(_yield)
                            s_sos += float(_yield)
                            s_sos_err += float(error)
                        elif name == "BACKGROUND": ## bkg yield
                            bkg = float(_yield); bkg_err = float(error)
                            if bkg == 0: break
                            signifSOS /= math.sqrt( bkg )
                            if s_sos != 0:
                                SOS_yErr = signifSOS*math.sqrt( s_sos_err*s_sos_err/(s_sos*s_sos) + bkg_err*bkg_err/(4*bkg*bkg) )
                    print("bin: {}-{}, signif-SOS = {} +/- {}".format(x1,x2,signifSOS,SOS_yErr))
                    print() ## print newline

                ## fill the histograms
                histosALT[plot].SetBinContent(_bin+1, signifALT)
                histosALT[plot].SetBinError(_bin+1, ALT_yErr)
                histosSOS[plot].SetBinContent(_bin+1, signifSOS)
                histosSOS[plot].SetBinError(_bin+1, SOS_yErr)

            ## itr over bins
            ## itr over plots

        ## make the plots and save them
        for plot,(ALT,SOS) in zip( xaxes.keys(), zip(histosALT.values(),histosSOS.values()) ):
            canv = TCanvas("canv","canv",400,400); canv.cd()
            ALT.SetLineColor(2); ALT.SetLineWidth(2)
            SOS.SetLineColor(4); SOS.SetLineWidth(2)
            ALT.Draw(); ALT.GetYaxis().SetRangeUser(0.0, 10.0)
            if histosALT["plot3"].GetBinContent(3) < 1:
                ALT.GetYaxis().SetRangeUser(0.01, 10.0)
                canv.SetLogy()
            SOS.Draw("same")
            canv.SetGridx()
            canv.SetGridy()
            canv.SaveAs("/eos/home-k/kpanos/www/{}/{}-SignifVsPt_{}.png".format(args.outDir, signame.replace('/','_'), plot))

        ## delete the histos for proventing memory leaks
        # for ALT,SOS in zip(histosALT.values(),histosSOS.values()):
        #     ALT.~TH1F()
        #     SOS.~TH1F()
    ## signals loop

    return
