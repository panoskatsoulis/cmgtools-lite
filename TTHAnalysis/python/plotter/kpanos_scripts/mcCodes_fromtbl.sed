s@([^0-9])1([^0-9])@\1d\2@g
s@([^0-9])-1([^0-9])@\1dbar\2@g
s@([^0-9])2([^0-9])@\1u\2@g
s@([^0-9])-2([^0-9])@\1ubar\2@g
s@([^0-9])3([^0-9])@\1s\2@g
s@([^0-9])-3([^0-9])@\1sbar\2@g
s@([^0-9])4([^0-9])@\1c\2@g
s@([^0-9])-4([^0-9])@\1cbar\2@g
s@([^0-9])5([^0-9])@\1b\2@g
s@([^0-9])-5([^0-9])@\1bbar\2@g
s@([^0-9])6([^0-9])@\1t\2@g
s@([^0-9])-6([^0-9])@\1tbar\2@g
s@([^0-9])7([^0-9])@\1b'\2@g
s@([^0-9])-7([^0-9])@\1b'bar\2@g
s@([^0-9])8([^0-9])@\1t'\2@g
s@([^0-9])-8([^0-9])@\1t'bar\2@g
s@([^0-9])11([^0-9])@\1e-\2@g
s@([^0-9])-11([^0-9])@\1e+\2@g
s@([^0-9])12([^0-9])@\1nu_e\2@g
s@([^0-9])-12([^0-9])@\1nu_ebar\2@g
s@([^0-9])13([^0-9])@\1mu-\2@g
s@([^0-9])-13([^0-9])@\1mu+\2@g
s@([^0-9])14([^0-9])@\1nu_mu\2@g
s@([^0-9])-14([^0-9])@\1nu_mubar\2@g
s@([^0-9])15([^0-9])@\1tau-\2@g
s@([^0-9])-15([^0-9])@\1tau+\2@g
s@([^0-9])16([^0-9])@\1nu_tau\2@g
s@([^0-9])-16([^0-9])@\1nu_taubar\2@g
s@([^0-9])17([^0-9])@\1tau'-\2@g
s@([^0-9])-17([^0-9])@\1tau'+\2@g
s@([^0-9])18([^0-9])@\1nu'_tau\2@g
s@([^0-9])-18([^0-9])@\1nu'_taubar\2@g
s@([^0-9])21([^0-9])@\1g\2@g
s@([^0-9])22([^0-9])@\1gamma\2@g
s@([^0-9])23([^0-9])@\1Z0\2@g
s@([^0-9])24([^0-9])@\1W+\2@g
s@([^0-9])-24([^0-9])@\1W-\2@g
s@([^0-9])25([^0-9])@\1h0\2@g
s@([^0-9])32([^0-9])@\1Z'0\2@g
s@([^0-9])33([^0-9])@\1Z"0\2@g
s@([^0-9])34([^0-9])@\1W'+\2@g
s@([^0-9])-34([^0-9])@\1W'-\2@g
s@([^0-9])35([^0-9])@\1H0\2@g
s@([^0-9])36([^0-9])@\1A0\2@g
s@([^0-9])37([^0-9])@\1H+\2@g
s@([^0-9])-37([^0-9])@\1H-\2@g
s@([^0-9])39([^0-9])@\1Graviton\2@g
s@([^0-9])41([^0-9])@\1R0\2@g
s@([^0-9])-41([^0-9])@\1Rbar0\2@g
s@([^0-9])42([^0-9])@\1LQ_ue\2@g
s@([^0-9])-42([^0-9])@\1LQ_uebar\2@g
s@([^0-9])81([^0-9])@\1specflav\2@g
s@([^0-9])82([^0-9])@\1rndmflav\2@g
s@([^0-9])-82([^0-9])@\1rndmflavbar\2@g
s@([^0-9])83([^0-9])@\1phasespa\2@g
s@([^0-9])84([^0-9])@\1c-hadron\2@g
s@([^0-9])-84([^0-9])@\1c-hadronbar\2@g
s@([^0-9])85([^0-9])@\1b-hadron\2@g
s@([^0-9])-85([^0-9])@\1b-hadronbar\2@g
s@([^0-9])88([^0-9])@\1junction\2@g
s@([^0-9])90([^0-9])@\1system\2@g
s@([^0-9])91([^0-9])@\1cluster\2@g
s@([^0-9])92([^0-9])@\1string\2@g
s@([^0-9])93([^0-9])@\1indep.\2@g
s@([^0-9])94([^0-9])@\1CMshower\2@g
s@([^0-9])95([^0-9])@\1SPHEaxis\2@g
s@([^0-9])96([^0-9])@\1THRUaxis\2@g
s@([^0-9])97([^0-9])@\1CLUSjet\2@g
s@([^0-9])98([^0-9])@\1CELLjet\2@g
s@([^0-9])99([^0-9])@\1table\2@g
s@([^0-9])110([^0-9])@\1reggeon\2@g
s@([^0-9])111([^0-9])@\1pi0\2@g
s@([^0-9])113([^0-9])@\1rho0\2@g
s@([^0-9])115([^0-9])@\1a_20\2@g
s@([^0-9])130([^0-9])@\1K_L0\2@g
s@([^0-9])211([^0-9])@\1pi+\2@g
s@([^0-9])-211([^0-9])@\1pi-\2@g
s@([^0-9])213([^0-9])@\1rho+\2@g
s@([^0-9])-213([^0-9])@\1rho-\2@g
s@([^0-9])215([^0-9])@\1a_2+\2@g
s@([^0-9])-215([^0-9])@\1a_2-\2@g
s@([^0-9])221([^0-9])@\1eta\2@g
s@([^0-9])223([^0-9])@\1omega\2@g
s@([^0-9])225([^0-9])@\1f_2\2@g
s@([^0-9])310([^0-9])@\1K_S0\2@g
s@([^0-9])311([^0-9])@\1K0\2@g
s@([^0-9])-311([^0-9])@\1Kbar0\2@g
s@([^0-9])313([^0-9])@\1K*0\2@g
s@([^0-9])-313([^0-9])@\1K*bar0\2@g
s@([^0-9])315([^0-9])@\1K*_20\2@g
s@([^0-9])-315([^0-9])@\1K*_2bar0\2@g
s@([^0-9])321([^0-9])@\1K+\2@g
s@([^0-9])-321([^0-9])@\1K-\2@g
s@([^0-9])323([^0-9])@\1K*+\2@g
s@([^0-9])-323([^0-9])@\1K*-\2@g
s@([^0-9])325([^0-9])@\1K*_2+\2@g
s@([^0-9])-325([^0-9])@\1K*_2-\2@g
s@([^0-9])331([^0-9])@\1eta'\2@g
s@([^0-9])333([^0-9])@\1phi\2@g
s@([^0-9])335([^0-9])@\1f'_2\2@g
s@([^0-9])411([^0-9])@\1D+\2@g
s@([^0-9])-411([^0-9])@\1D-\2@g
s@([^0-9])413([^0-9])@\1D*+\2@g
s@([^0-9])-413([^0-9])@\1D*-\2@g
s@([^0-9])415([^0-9])@\1D*_2+\2@g
s@([^0-9])-415([^0-9])@\1D*_2-\2@g
s@([^0-9])421([^0-9])@\1D0\2@g
s@([^0-9])-421([^0-9])@\1Dbar0\2@g
s@([^0-9])423([^0-9])@\1D*0\2@g
s@([^0-9])-423([^0-9])@\1D*bar0\2@g
s@([^0-9])425([^0-9])@\1D*_20\2@g
s@([^0-9])-425([^0-9])@\1D*_2bar0\2@g
s@([^0-9])431([^0-9])@\1D_s+\2@g
s@([^0-9])-431([^0-9])@\1D_s-\2@g
s@([^0-9])433([^0-9])@\1D*_s+\2@g
s@([^0-9])-433([^0-9])@\1D*_s-\2@g
s@([^0-9])435([^0-9])@\1D*_2s+\2@g
s@([^0-9])-435([^0-9])@\1D*_2s-\2@g
s@([^0-9])441([^0-9])@\1eta_c\2@g
s@([^0-9])443([^0-9])@\1J/psi\2@g
s@([^0-9])445([^0-9])@\1chi_2c\2@g
s@([^0-9])511([^0-9])@\1B0\2@g
s@([^0-9])-511([^0-9])@\1Bbar0\2@g
s@([^0-9])513([^0-9])@\1B*0\2@g
s@([^0-9])-513([^0-9])@\1B*bar0\2@g
s@([^0-9])515([^0-9])@\1B*_20\2@g
s@([^0-9])-515([^0-9])@\1B*_2bar0\2@g
s@([^0-9])521([^0-9])@\1B+\2@g
s@([^0-9])-521([^0-9])@\1B-\2@g
s@([^0-9])523([^0-9])@\1B*+\2@g
s@([^0-9])-523([^0-9])@\1B*-\2@g
s@([^0-9])525([^0-9])@\1B*_2+\2@g
s@([^0-9])-525([^0-9])@\1B*_2-\2@g
s@([^0-9])531([^0-9])@\1B_s0\2@g
s@([^0-9])-531([^0-9])@\1B_sbar0\2@g
s@([^0-9])533([^0-9])@\1B*_s0\2@g
s@([^0-9])-533([^0-9])@\1B*_sbar0\2@g
s@([^0-9])535([^0-9])@\1B*_2s0\2@g
s@([^0-9])-535([^0-9])@\1B*_2sbar0\2@g
s@([^0-9])541([^0-9])@\1B_c+\2@g
s@([^0-9])-541([^0-9])@\1B_c-\2@g
s@([^0-9])543([^0-9])@\1B*_c+\2@g
s@([^0-9])-543([^0-9])@\1B*_c-\2@g
s@([^0-9])545([^0-9])@\1B*_2c+\2@g
s@([^0-9])-545([^0-9])@\1B*_2c-\2@g
s@([^0-9])551([^0-9])@\1eta_b\2@g
s@([^0-9])553([^0-9])@\1Upsilon\2@g
s@([^0-9])555([^0-9])@\1chi_2b\2@g
s@([^0-9])990([^0-9])@\1pomeron\2@g
s@([^0-9])1103([^0-9])@\1dd_1\2@g
s@([^0-9])-1103([^0-9])@\1dd_1bar\2@g
s@([^0-9])1114([^0-9])@\1Delta-\2@g
s@([^0-9])-1114([^0-9])@\1Deltabar+\2@g
s@([^0-9])2101([^0-9])@\1ud_0\2@g
s@([^0-9])-2101([^0-9])@\1ud_0bar\2@g
s@([^0-9])2103([^0-9])@\1ud_1\2@g
s@([^0-9])-2103([^0-9])@\1ud_1bar\2@g
s@([^0-9])2112([^0-9])@\1n0\2@g
s@([^0-9])-2112([^0-9])@\1nbar0\2@g
s@([^0-9])2114([^0-9])@\1Delta0\2@g
s@([^0-9])-2114([^0-9])@\1Deltabar0\2@g
s@([^0-9])2203([^0-9])@\1uu_1\2@g
s@([^0-9])-2203([^0-9])@\1uu_1bar\2@g
s@([^0-9])2212([^0-9])@\1p+\2@g
s@([^0-9])-2212([^0-9])@\1pbar-\2@g
s@([^0-9])2214([^0-9])@\1Delta+\2@g
s@([^0-9])-2214([^0-9])@\1Deltabar-\2@g
s@([^0-9])2224([^0-9])@\1Delta++\2@g
s@([^0-9])-2224([^0-9])@\1Deltabar--\2@g
s@([^0-9])3101([^0-9])@\1sd_0\2@g
s@([^0-9])-3101([^0-9])@\1sd_0bar\2@g
s@([^0-9])3103([^0-9])@\1sd_1\2@g
s@([^0-9])-3103([^0-9])@\1sd_1bar\2@g
s@([^0-9])3112([^0-9])@\1Sigma-\2@g
s@([^0-9])-3112([^0-9])@\1Sigmabar+\2@g
s@([^0-9])3114([^0-9])@\1Sigma*-\2@g
s@([^0-9])-3114([^0-9])@\1Sigma*bar+\2@g
s@([^0-9])3122([^0-9])@\1Lambda0\2@g
s@([^0-9])-3122([^0-9])@\1Lambdabar0\2@g
s@([^0-9])3201([^0-9])@\1su_0\2@g
s@([^0-9])-3201([^0-9])@\1su_0bar\2@g
s@([^0-9])3203([^0-9])@\1su_1\2@g
s@([^0-9])-3203([^0-9])@\1su_1bar\2@g
s@([^0-9])3212([^0-9])@\1Sigma0\2@g
s@([^0-9])-3212([^0-9])@\1Sigmabar0\2@g
s@([^0-9])3214([^0-9])@\1Sigma*0\2@g
s@([^0-9])-3214([^0-9])@\1Sigma*bar0\2@g
s@([^0-9])3222([^0-9])@\1Sigma+\2@g
s@([^0-9])-3222([^0-9])@\1Sigmabar-\2@g
s@([^0-9])3224([^0-9])@\1Sigma*+\2@g
s@([^0-9])-3224([^0-9])@\1Sigma*bar-\2@g
s@([^0-9])3303([^0-9])@\1ss_1\2@g
s@([^0-9])-3303([^0-9])@\1ss_1bar\2@g
s@([^0-9])3312([^0-9])@\1Xi-\2@g
s@([^0-9])-3312([^0-9])@\1Xibar+\2@g
s@([^0-9])3314([^0-9])@\1Xi*-\2@g
s@([^0-9])-3314([^0-9])@\1Xi*bar+\2@g
s@([^0-9])3322([^0-9])@\1Xi0\2@g
s@([^0-9])-3322([^0-9])@\1Xibar0\2@g
s@([^0-9])3324([^0-9])@\1Xi*0\2@g
s@([^0-9])-3324([^0-9])@\1Xi*bar0\2@g
s@([^0-9])3334([^0-9])@\1Omega-\2@g
s@([^0-9])-3334([^0-9])@\1Omegabar+\2@g
s@([^0-9])4101([^0-9])@\1cd_0\2@g
s@([^0-9])-4101([^0-9])@\1cd_0bar\2@g
s@([^0-9])4103([^0-9])@\1cd_1\2@g
s@([^0-9])-4103([^0-9])@\1cd_1bar\2@g
s@([^0-9])4112([^0-9])@\1Sigma_c0\2@g
s@([^0-9])-4112([^0-9])@\1Sigma_cbar0\2@g
s@([^0-9])4114([^0-9])@\1Sigma*_c0\2@g
s@([^0-9])-4114([^0-9])@\1Sigma*_cbar0\2@g
s@([^0-9])4122([^0-9])@\1Lambda_c+\2@g
s@([^0-9])-4122([^0-9])@\1Lambda_cbar-\2@g
s@([^0-9])4132([^0-9])@\1Xi_c0\2@g
s@([^0-9])-4132([^0-9])@\1Xi_cbar0\2@g
s@([^0-9])4201([^0-9])@\1cu_0\2@g
s@([^0-9])-4201([^0-9])@\1cu_0bar\2@g
s@([^0-9])4203([^0-9])@\1cu_1\2@g
s@([^0-9])-4203([^0-9])@\1cu_1bar\2@g
s@([^0-9])4212([^0-9])@\1Sigma_c+\2@g
s@([^0-9])-4212([^0-9])@\1Sigma_cbar-\2@g
s@([^0-9])4214([^0-9])@\1Sigma*_c+\2@g
s@([^0-9])-4214([^0-9])@\1Sigma*_cbar-\2@g
s@([^0-9])4222([^0-9])@\1Sigma_c++\2@g
s@([^0-9])-4222([^0-9])@\1Sigma_cbar--\2@g
s@([^0-9])4224([^0-9])@\1Sigma*_c++\2@g
s@([^0-9])-4224([^0-9])@\1Sigma*_cbar--\2@g
s@([^0-9])4232([^0-9])@\1Xi_c+\2@g
s@([^0-9])-4232([^0-9])@\1Xi_cbar-\2@g
s@([^0-9])4301([^0-9])@\1cs_0\2@g
s@([^0-9])-4301([^0-9])@\1cs_0bar\2@g
s@([^0-9])4303([^0-9])@\1cs_1\2@g
s@([^0-9])-4303([^0-9])@\1cs_1bar\2@g
s@([^0-9])4312([^0-9])@\1Xi'_c0\2@g
s@([^0-9])-4312([^0-9])@\1Xi'_cbar0\2@g
s@([^0-9])4314([^0-9])@\1Xi*_c0\2@g
s@([^0-9])-4314([^0-9])@\1Xi*_cbar0\2@g
s@([^0-9])4322([^0-9])@\1Xi'_c+\2@g
s@([^0-9])-4322([^0-9])@\1Xi'_cbar-\2@g
s@([^0-9])4324([^0-9])@\1Xi*_c+\2@g
s@([^0-9])-4324([^0-9])@\1Xi*_cbar-\2@g
s@([^0-9])4332([^0-9])@\1Omega_c0\2@g
s@([^0-9])-4332([^0-9])@\1Omega_cbar0\2@g
s@([^0-9])4334([^0-9])@\1Omega*_c0\2@g
s@([^0-9])-4334([^0-9])@\1Omega*_cbar0\2@g
s@([^0-9])4403([^0-9])@\1cc_1\2@g
s@([^0-9])-4403([^0-9])@\1cc_1bar\2@g
s@([^0-9])4412([^0-9])@\1Xi_cc+\2@g
s@([^0-9])-4412([^0-9])@\1Xi_ccbar-\2@g
s@([^0-9])4414([^0-9])@\1Xi*_cc+\2@g
s@([^0-9])-4414([^0-9])@\1Xi*_ccbar-\2@g
s@([^0-9])4422([^0-9])@\1Xi_cc++\2@g
s@([^0-9])-4422([^0-9])@\1Xi_ccbar--\2@g
s@([^0-9])4424([^0-9])@\1Xi*_cc++\2@g
s@([^0-9])-4424([^0-9])@\1Xi*_ccbar--\2@g
s@([^0-9])4432([^0-9])@\1Omega_cc+\2@g
s@([^0-9])-4432([^0-9])@\1Omega_ccbar-\2@g
s@([^0-9])4434([^0-9])@\1Omega*_cc+\2@g
s@([^0-9])-4434([^0-9])@\1Omega*_ccbar-\2@g
s@([^0-9])4444([^0-9])@\1Omega*_ccc++\2@g
s@([^0-9])-4444([^0-9])@\1Omega*_cccbar-\2@g
s@([^0-9])5101([^0-9])@\1bd_0\2@g
s@([^0-9])-5101([^0-9])@\1bd_0bar\2@g
s@([^0-9])5103([^0-9])@\1bd_1\2@g
s@([^0-9])-5103([^0-9])@\1bd_1bar\2@g
s@([^0-9])5112([^0-9])@\1Sigma_b-\2@g
s@([^0-9])-5112([^0-9])@\1Sigma_bbar+\2@g
s@([^0-9])5114([^0-9])@\1Sigma*_b-\2@g
s@([^0-9])-5114([^0-9])@\1Sigma*_bbar+\2@g
s@([^0-9])5122([^0-9])@\1Lambda_b0\2@g
s@([^0-9])-5122([^0-9])@\1Lambda_bbar0\2@g
s@([^0-9])5132([^0-9])@\1Xi_b-\2@g
s@([^0-9])-5132([^0-9])@\1Xi_bbar+\2@g
s@([^0-9])5142([^0-9])@\1Xi_bc0\2@g
s@([^0-9])-5142([^0-9])@\1Xi_bcbar0\2@g
s@([^0-9])5201([^0-9])@\1bu_0\2@g
s@([^0-9])-5201([^0-9])@\1bu_0bar\2@g
s@([^0-9])5203([^0-9])@\1bu_1\2@g
s@([^0-9])-5203([^0-9])@\1bu_1bar\2@g
s@([^0-9])5212([^0-9])@\1Sigma_b0\2@g
s@([^0-9])-5212([^0-9])@\1Sigma_bbar0\2@g
s@([^0-9])5214([^0-9])@\1Sigma*_b0\2@g
s@([^0-9])-5214([^0-9])@\1Sigma*_bbar0\2@g
s@([^0-9])5222([^0-9])@\1Sigma_b+\2@g
s@([^0-9])-5222([^0-9])@\1Sigma_bbar-\2@g
s@([^0-9])5224([^0-9])@\1Sigma*_b+\2@g
s@([^0-9])-5224([^0-9])@\1Sigma*_bbar-\2@g
s@([^0-9])5232([^0-9])@\1Xi_b0\2@g
s@([^0-9])-5232([^0-9])@\1Xi_bbar0\2@g
s@([^0-9])5242([^0-9])@\1Xi_bc+\2@g
s@([^0-9])-5242([^0-9])@\1Xi_bcbar-\2@g
s@([^0-9])5301([^0-9])@\1bs_0\2@g
s@([^0-9])-5301([^0-9])@\1bs_0bar\2@g
s@([^0-9])5303([^0-9])@\1bs_1\2@g
s@([^0-9])-5303([^0-9])@\1bs_1bar\2@g
s@([^0-9])5312([^0-9])@\1Xi'_b-\2@g
s@([^0-9])-5312([^0-9])@\1Xi'_bbar+\2@g
s@([^0-9])5314([^0-9])@\1Xi*_b-\2@g
s@([^0-9])-5314([^0-9])@\1Xi*_bbar+\2@g
s@([^0-9])5322([^0-9])@\1Xi'_b0\2@g
s@([^0-9])-5322([^0-9])@\1Xi'_bbar0\2@g
s@([^0-9])5324([^0-9])@\1Xi*_b0\2@g
s@([^0-9])-5324([^0-9])@\1Xi*_bbar0\2@g
s@([^0-9])5332([^0-9])@\1Omega_b-\2@g
s@([^0-9])-5332([^0-9])@\1Omega_bbar+\2@g
s@([^0-9])5334([^0-9])@\1Omega*_b-\2@g
s@([^0-9])-5334([^0-9])@\1Omega*_bbar+\2@g
s@([^0-9])5342([^0-9])@\1Omega_bc0\2@g
s@([^0-9])-5342([^0-9])@\1Omega_bcbar0\2@g
s@([^0-9])5401([^0-9])@\1bc_0\2@g
s@([^0-9])-5401([^0-9])@\1bc_0bar\2@g
s@([^0-9])5403([^0-9])@\1bc_1\2@g
s@([^0-9])-5403([^0-9])@\1bc_1bar\2@g
s@([^0-9])5412([^0-9])@\1Xi'_bc0\2@g
s@([^0-9])-5412([^0-9])@\1Xi'_bcbar0\2@g
s@([^0-9])5414([^0-9])@\1Xi*_bc0\2@g
s@([^0-9])-5414([^0-9])@\1Xi*_bcbar0\2@g
s@([^0-9])5422([^0-9])@\1Xi'_bc+\2@g
s@([^0-9])-5422([^0-9])@\1Xi'_bcbar-\2@g
s@([^0-9])5424([^0-9])@\1Xi*_bc+\2@g
s@([^0-9])-5424([^0-9])@\1Xi*_bcbar-\2@g
s@([^0-9])5432([^0-9])@\1Omega'_bc0\2@g
s@([^0-9])-5432([^0-9])@\1Omega'_bcba\2@g
s@([^0-9])5434([^0-9])@\1Omega*_bc0\2@g
s@([^0-9])-5434([^0-9])@\1Omega*_bcbar0\2@g
s@([^0-9])5442([^0-9])@\1Omega_bcc+\2@g
s@([^0-9])-5442([^0-9])@\1Omega_bccbar-\2@g
s@([^0-9])5444([^0-9])@\1Omega*_bcc+\2@g
s@([^0-9])-5444([^0-9])@\1Omega*_bccbar-\2@g
s@([^0-9])5503([^0-9])@\1bb_1\2@g
s@([^0-9])-5503([^0-9])@\1bb_1bar\2@g
s@([^0-9])5512([^0-9])@\1Xi_bb-\2@g
s@([^0-9])-5512([^0-9])@\1Xi_bbbar+\2@g
s@([^0-9])5514([^0-9])@\1Xi*_bb-\2@g
s@([^0-9])-5514([^0-9])@\1Xi*_bbbar+\2@g
s@([^0-9])5522([^0-9])@\1Xi_bb0\2@g
s@([^0-9])-5522([^0-9])@\1Xi_bbbar0\2@g
s@([^0-9])5524([^0-9])@\1Xi*_bb0\2@g
s@([^0-9])-5524([^0-9])@\1Xi*_bbbar0\2@g
s@([^0-9])5532([^0-9])@\1Omega_bb-\2@g
s@([^0-9])-5532([^0-9])@\1Omega_bbbar+\2@g
s@([^0-9])5534([^0-9])@\1Omega*_bb-\2@g
s@([^0-9])-5534([^0-9])@\1Omega*_bbbar+\2@g
s@([^0-9])5542([^0-9])@\1Omega_bbc0\2@g
s@([^0-9])-5542([^0-9])@\1Omega_bbcbar0\2@g
s@([^0-9])5544([^0-9])@\1Omega*_bbc0\2@g
s@([^0-9])-5544([^0-9])@\1Omega*_bbcbar0\2@g
s@([^0-9])5554([^0-9])@\1Omega*_bbb-\2@g
s@([^0-9])-5554([^0-9])@\1Omega*_bbbbar+\2@g
s@([^0-9])10111([^0-9])@\1a_00\2@g
s@([^0-9])10113([^0-9])@\1b_10\2@g
s@([^0-9])10211([^0-9])@\1a_0+\2@g
s@([^0-9])-10211([^0-9])@\1a_0-\2@g
s@([^0-9])10213([^0-9])@\1b_1+\2@g
s@([^0-9])-10213([^0-9])@\1b_1-\2@g
s@([^0-9])10221([^0-9])@\1f_0\2@g
s@([^0-9])10223([^0-9])@\1h_1\2@g
s@([^0-9])10311([^0-9])@\1K*_00\2@g
s@([^0-9])-10311([^0-9])@\1K*_0bar0\2@g
s@([^0-9])10313([^0-9])@\1K_10\2@g
s@([^0-9])-10313([^0-9])@\1K_1bar0\2@g
s@([^0-9])10321([^0-9])@\1K*_0+\2@g
s@([^0-9])-10321([^0-9])@\1K*_0-\2@g
s@([^0-9])10323([^0-9])@\1K_1+\2@g
s@([^0-9])-10323([^0-9])@\1K_1-\2@g
s@([^0-9])10331([^0-9])@\1f'_0\2@g
s@([^0-9])10333([^0-9])@\1h'_1\2@g
s@([^0-9])10411([^0-9])@\1D*_0+\2@g
s@([^0-9])-10411([^0-9])@\1D*_0-\2@g
s@([^0-9])10413([^0-9])@\1D_1+\2@g
s@([^0-9])-10413([^0-9])@\1D_1-\2@g
s@([^0-9])10421([^0-9])@\1D*_00\2@g
s@([^0-9])-10421([^0-9])@\1D*_0bar0\2@g
s@([^0-9])10423([^0-9])@\1D_10\2@g
s@([^0-9])-10423([^0-9])@\1D_1bar0\2@g
s@([^0-9])10431([^0-9])@\1D*_0s+\2@g
s@([^0-9])-10431([^0-9])@\1D*_0s-\2@g
s@([^0-9])10433([^0-9])@\1D_1s+\2@g
s@([^0-9])-10433([^0-9])@\1D_1s-\2@g
s@([^0-9])10441([^0-9])@\1chi_0c\2@g
s@([^0-9])10443([^0-9])@\1h_1c\2@g
s@([^0-9])10511([^0-9])@\1B*_00\2@g
s@([^0-9])-10511([^0-9])@\1B*_0bar0\2@g
s@([^0-9])10513([^0-9])@\1B_10\2@g
s@([^0-9])-10513([^0-9])@\1B_1bar0\2@g
s@([^0-9])10521([^0-9])@\1B*_0+\2@g
s@([^0-9])-10521([^0-9])@\1B*_0-\2@g
s@([^0-9])10523([^0-9])@\1B_1+\2@g
s@([^0-9])-10523([^0-9])@\1B_1-\2@g
s@([^0-9])10531([^0-9])@\1B*_0s0\2@g
s@([^0-9])-10531([^0-9])@\1B*_0sbar0\2@g
s@([^0-9])10533([^0-9])@\1B_1s0\2@g
s@([^0-9])-10533([^0-9])@\1B_1sbar0\2@g
s@([^0-9])10541([^0-9])@\1B*_0c+\2@g
s@([^0-9])-10541([^0-9])@\1B*_0c-\2@g
s@([^0-9])10543([^0-9])@\1B_1c+\2@g
s@([^0-9])-10543([^0-9])@\1B_1c-\2@g
s@([^0-9])10551([^0-9])@\1chi_0b\2@g
s@([^0-9])10553([^0-9])@\1h_1b\2@g
s@([^0-9])20113([^0-9])@\1a_10\2@g
s@([^0-9])20213([^0-9])@\1a_1+\2@g
s@([^0-9])-20213([^0-9])@\1a_1-\2@g
s@([^0-9])20223([^0-9])@\1f_1\2@g
s@([^0-9])20313([^0-9])@\1K*_10\2@g
s@([^0-9])-20313([^0-9])@\1K*_1bar0\2@g
s@([^0-9])20323([^0-9])@\1K*_1+\2@g
s@([^0-9])-20323([^0-9])@\1K*_1-\2@g
s@([^0-9])20333([^0-9])@\1f'_1\2@g
s@([^0-9])20413([^0-9])@\1D*_1+\2@g
s@([^0-9])-20413([^0-9])@\1D*_1-\2@g
s@([^0-9])20423([^0-9])@\1D*_10\2@g
s@([^0-9])-20423([^0-9])@\1D*_1bar0\2@g
s@([^0-9])20433([^0-9])@\1D*_1s+\2@g
s@([^0-9])-20433([^0-9])@\1D*_1s-\2@g
s@([^0-9])20443([^0-9])@\1chi_1c\2@g
s@([^0-9])20513([^0-9])@\1B*_10\2@g
s@([^0-9])-20513([^0-9])@\1B*_1bar0\2@g
s@([^0-9])20523([^0-9])@\1B*_1+\2@g
s@([^0-9])-20523([^0-9])@\1B*_1-\2@g
s@([^0-9])20533([^0-9])@\1B*_1s0\2@g
s@([^0-9])-20533([^0-9])@\1B*_1sbar0\2@g
s@([^0-9])20543([^0-9])@\1B*_1c+\2@g
s@([^0-9])-20543([^0-9])@\1B*_1c-\2@g
s@([^0-9])20553([^0-9])@\1chi_1b\2@g
s@([^0-9])100443([^0-9])@\1psi'\2@g
s@([^0-9])100553([^0-9])@\1Upsilon'\2@g
s@([^0-9])1000001([^0-9])@\1~d_L\2@g
s@([^0-9])-1000001([^0-9])@\1~d_Lbar\2@g
s@([^0-9])1000002([^0-9])@\1~u_L\2@g
s@([^0-9])-1000002([^0-9])@\1~u_Lbar\2@g
s@([^0-9])1000003([^0-9])@\1~s_L\2@g
s@([^0-9])-1000003([^0-9])@\1~s_Lbar\2@g
s@([^0-9])1000004([^0-9])@\1~c_L\2@g
s@([^0-9])-1000004([^0-9])@\1~c_Lbar\2@g
s@([^0-9])1000005([^0-9])@\1~b_1\2@g
s@([^0-9])-1000005([^0-9])@\1~b_1bar\2@g
s@([^0-9])1000006([^0-9])@\1~t_1\2@g
s@([^0-9])-1000006([^0-9])@\1~t_1bar\2@g
s@([^0-9])1000011([^0-9])@\1~e_L-\2@g
s@([^0-9])-1000011([^0-9])@\1~e_L+\2@g
s@([^0-9])1000012([^0-9])@\1~nu_eL\2@g
s@([^0-9])-1000012([^0-9])@\1~nu_eLbar\2@g
s@([^0-9])1000013([^0-9])@\1~mu_L-\2@g
s@([^0-9])-1000013([^0-9])@\1~mu_L+\2@g
s@([^0-9])1000014([^0-9])@\1~nu_muL\2@g
s@([^0-9])-1000014([^0-9])@\1~nu_muLbar\2@g
s@([^0-9])1000015([^0-9])@\1~tau_1-\2@g
s@([^0-9])-1000015([^0-9])@\1~tau_1+\2@g
s@([^0-9])1000016([^0-9])@\1~nu_tauL\2@g
s@([^0-9])-1000016([^0-9])@\1~nu_tauLbar\2@g
s@([^0-9])1000021([^0-9])@\1~g\2@g
s@([^0-9])1000022([^0-9])@\1~chi_10\2@g
s@([^0-9])1000023([^0-9])@\1~chi_20\2@g
s@([^0-9])1000024([^0-9])@\1~chi_1+\2@g
s@([^0-9])-1000024([^0-9])@\1~chi_1-\2@g
s@([^0-9])1000025([^0-9])@\1~chi_30\2@g
s@([^0-9])1000035([^0-9])@\1~chi_40\2@g
s@([^0-9])1000037([^0-9])@\1~chi_2+\2@g
s@([^0-9])-1000037([^0-9])@\1~chi_2-\2@g
s@([^0-9])1000039([^0-9])@\1~Gravitino\2@g
s@([^0-9])2000001([^0-9])@\1~d_R\2@g
s@([^0-9])-2000001([^0-9])@\1~d_Rbar\2@g
s@([^0-9])2000002([^0-9])@\1~u_R\2@g
s@([^0-9])-2000002([^0-9])@\1~u_Rbar\2@g
s@([^0-9])2000003([^0-9])@\1~s_R\2@g
s@([^0-9])-2000003([^0-9])@\1~s_Rbar\2@g
s@([^0-9])2000004([^0-9])@\1~c_R\2@g
s@([^0-9])-2000004([^0-9])@\1~c_Rbar\2@g
s@([^0-9])2000005([^0-9])@\1~b_2\2@g
s@([^0-9])-2000005([^0-9])@\1~b_2bar\2@g
s@([^0-9])2000006([^0-9])@\1~t_2\2@g
s@([^0-9])-2000006([^0-9])@\1~t_2bar\2@g
s@([^0-9])2000011([^0-9])@\1~e_R-\2@g
s@([^0-9])-2000011([^0-9])@\1~e_R+\2@g
s@([^0-9])2000012([^0-9])@\1~nu_eR\2@g
s@([^0-9])-2000012([^0-9])@\1~nu_eRbar\2@g
s@([^0-9])2000013([^0-9])@\1~mu_R-\2@g
s@([^0-9])-2000013([^0-9])@\1~mu_R+\2@g
s@([^0-9])2000014([^0-9])@\1~nu_muR\2@g
s@([^0-9])-2000014([^0-9])@\1~nu_muRbar\2@g
s@([^0-9])2000015([^0-9])@\1~tau_2-\2@g
s@([^0-9])-2000015([^0-9])@\1~tau_2+\2@g
s@([^0-9])2000016([^0-9])@\1~nu_tauR\2@g
s@([^0-9])-2000016([^0-9])@\1~nu_tauRbar\2@g
s@([^0-9])3000111([^0-9])@\1pi_tc0\2@g
s@([^0-9])3000211([^0-9])@\1pi_tc+\2@g
s@([^0-9])-3000211([^0-9])@\1pi_tc-\2@g
s@([^0-9])3000221([^0-9])@\1pi'_tc0\2@g
s@([^0-9])3100331([^0-9])@\1eta_tc0\2@g
s@([^0-9])3000113([^0-9])@\1rho_tc0\2@g
s@([^0-9])3000213([^0-9])@\1rho_tc+\2@g
s@([^0-9])-3000213([^0-9])@\1rho_tc-\2@g
s@([^0-9])3000223([^0-9])@\1omega_tc\2@g
s@([^0-9])3100021([^0-9])@\1V8_tc\2@g
s@([^0-9])3100111([^0-9])@\1pi_22_1_tc\2@g
s@([^0-9])3200111([^0-9])@\1pi_22_8_tc\2@g
s@([^0-9])3100113([^0-9])@\1rho_11_tc\2@g
s@([^0-9])3200113([^0-9])@\1rho_12_tc\2@g
s@([^0-9])3300113([^0-9])@\1rho_21_tc\2@g
s@([^0-9])3400113([^0-9])@\1rho_22_tc\2@g
s@([^0-9])4000001([^0-9])@\1d*\2@g
s@([^0-9])-4000001([^0-9])@\1d*bar\2@g
s@([^0-9])4000002([^0-9])@\1u*\2@g
s@([^0-9])-4000002([^0-9])@\1u*bar\2@g
s@([^0-9])4000011([^0-9])@\1e*-\2@g
s@([^0-9])-4000011([^0-9])@\1e*bar+\2@g
s@([^0-9])4000012([^0-9])@\1nu*_e0\2@g
s@([^0-9])-4000012([^0-9])@\1nu*_ebar0\2@g
s@([^0-9])4000013([^0-9])@\1mu*-\2@g
s@([^0-9])-4000013([^0-9])@\1mu*bar+\2@g
s@([^0-9])4000015([^0-9])@\1tau*-\2@g
s@([^0-9])-4000015([^0-9])@\1tau*bar+\2@g
s@([^0-9])5000039([^0-9])@\1Graviton*\2@g
s@([^0-9])9900012([^0-9])@\1nu_Re\2@g
s@([^0-9])9900014([^0-9])@\1nu_Rmu\2@g
s@([^0-9])9900016([^0-9])@\1nu_Rtau\2@g
s@([^0-9])9900023([^0-9])@\1Z_R0\2@g
s@([^0-9])9900024([^0-9])@\1W_R+\2@g
s@([^0-9])-9900024([^0-9])@\1W_R-\2@g
s@([^0-9])9900041([^0-9])@\1H_L++\2@g
s@([^0-9])-9900041([^0-9])@\1H_L--\2@g
s@([^0-9])9900042([^0-9])@\1H_R++\2@g
s@([^0-9])-9900042([^0-9])@\1H_R--\2@g
s@([^0-9])9900110([^0-9])@\1rho_diff0\2@g
s@([^0-9])9900210([^0-9])@\1pi_diffr+\2@g
s@([^0-9])-9900210([^0-9])@\1pi_diffr-\2@g
s@([^0-9])9900220([^0-9])@\1omega_di\2@g
s@([^0-9])9900330([^0-9])@\1phi_diff\2@g
s@([^0-9])9900440([^0-9])@\1J/psi_di\2@g
s@([^0-9])9902110([^0-9])@\1n_diffr0\2@g
s@([^0-9])-9902110([^0-9])@\1n_diffrbar0\2@g
s@([^0-9])9902210([^0-9])@\1p_diffr+\2@g
s@([^0-9])-9902210([^0-9])@\1p_diffrbar-\2@g
s@([^0-9])9900443([^0-9])@\1cc~[3S18]\2@g
s@([^0-9])9900441([^0-9])@\1cc~[1S08]\2@g
s@([^0-9])9910441([^0-9])@\1cc~[3P08]\2@g
s@([^0-9])9900553([^0-9])@\1bb~[3S18]\2@g
s@([^0-9])9900551([^0-9])@\1bb~[1S08]\2@g
s@([^0-9])9910551([^0-9])@\1bb~[3P08]\2@g
s@([^0-9])-100([^0-9])@\1deuteron\2@g
s@([^0-9])-101([^0-9])@\1triton\2@g
s@([^0-9])-104([^0-9])@\1He3\2@g
s@([^0-9])-102([^0-9])@\1alpha\2@g
s@([^0-9])1000010020([^0-9])@\1Deuterium\2@g
s@([^0-9])1000010030([^0-9])@\1Tritium\2@g
s@([^0-9])1000020030([^0-9])@\1Helium3\2@g
s@([^0-9])1000020040([^0-9])@\1Alpha-(He4)\2@g
s@([^0-9])4110000([^0-9])@\1Monopole\2@g
s@([^0-9])-4110000([^0-9])@\1AntiMono\2@g
