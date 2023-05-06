*! Date        : 06 May 2023
*! Version     : 0.6
*! Authors     : Filippo Palomba
*! Email       : fpalomba@princeton.edu
*! Description : Estimate Heterogeneous TEs in Sharp RDD

/*
FUTURE release should include:
	- Extension of PSW estimation to quantiles.
	- Merge with the fuzzy version
*/

program getaway, eclass
version 14.0           
		
		syntax varlist(ts fv) [if] [in], Outcome(varname) Score(varname) Bandwidth(string) [Cutoff(real 0) Method(string) site(varname) ///
			   NQuant(numlist max=2 integer) probit trimming(string) BOOTrep(integer 0) clevel(real 95) reghd qtleplot             ///
			   gphoptions(string) GENvar(string) asis]

		tempvar assign qtle_x qtle_xl qtle_xr running pred0 pred1 pred0b pred1b effect effectb FE d xb
			   
	    qui {
			 
			 if !mi("`reghd'") {
				 capture which reghdfe, all
				 if _rc != 0 {
					noisily{ 
						di "Installing reghdfe!"
						ssc install reghdfe
					}
				 }			 	
			 }
		
			 marksample touse, novarlist       // marksample just for "if" and "in" conditions

			 
			 ****  PREPARATION  ****
			 *** Parse bandwidth on left and right side
			 tokenize `bandwidth'	
			 local w : word count `bandwidth'

			 if `w' == 1 {
				local band_r = `"`1'"'
				local band_l = -`band_r'
			 }
			 if `w' == 2 {
				local band_l `"`1'"'
				local band_r `"`2'"'
			 }  
 			 if `w' > 2 {
				 di as error  "{err}{cmd:b()} accepts at most two inputs" 
				 exit 125
			 }
			 
			 
			 g `running' = `score' - `cutoff'         // Standardize running variable
			 local band_l = `band_l' - `cutoff'
			 local band_r = `band_r' - `cutoff'
   			 g `assign' = `running' >= 0              // Generate assignment dummy
	        
			 
			 if mi("`nquant'") {
				local nquant "0 0"
				}

			 tokenize `nquant'
			 local w : word count `nquant'
			 
			 if `w' == 1 {
				local nquant_l = `"`1'"'
				local nquant_r = `"`1'"'
			    }
			 if `w' == 2 {
				local nquant_l `"`1'"'
				local nquant_r `"`2'"'
			    }
			 
			 
			 if "`method'" == "pscore" {             
			 	** atm pscore does not support quantile estimation
				local effnq = 0
				
				
				** Select probability model
				if mi("`probit'") {
					local model "logit"
					}
				else if !mi("`probit'") {
					local model "probit"
					}

				** specify trimming parameters
				if mi("`trimming'") {
					local psLow = 0.1
					local psHigh = 0.9
				}
				else {
					tokenize `trimming'
					local w : word count `trimming'
					
					if `w' < 2 {
						di as error "{err}{cmd:trimming() need two inputs!}"
						exit 125
					}
					else {
						local psLow = `"`1'"'
						local psHigh = `"`2'"'
					}
				}
			 }
			
			 local strap = 0
			 if `bootrep' != 0 {
				local strap = 1
				}
				
			 if (!mi("`qtleplot'") & `bootrep' == 0) {  // In order to plot within-quantile estimates with SE bootrep must be specified
				di as error "Please specify a number of bootstrap iterations!"
				exit
				}
				
			 if !mi("`genvar'") {                     // Check that the name for the new variable has not been already taken!
				capture confirm variable `genvar'
				if _rc == 0 {
					di as error "`genvar' already exists! Please choose a different name!"
					error 110
					}
				}
			 
			 
			 
			 **** ESTIMATION ****
			 
			 ** a) Linear Reweighting Estimator (Kline, 2011)
			 
			 if "`method'" == "linear" | mi("`method'") {     // Linear Reweighting estimator is the default
			 if mi("`site'") {                                  // Without FEs
	   			 reg `outcome' `varlist' if `running' >= 0 & `running' < `band_r' & `touse'			  // right
				 matrix b1 = e(b)
				 predict `pred1' if !missing(`outcome'), xb   
				 reg `outcome' `varlist' if `running' < 0 & `running' > `band_l' & `touse'              // left
				 matrix b0 = e(b)
				 predict `pred0' if !missing(`outcome'), xb
				 
				 }			 
			 if !mi("`site'") {                                 // With FEs
				 if mi("`reghd'") {
					 areg `outcome' `varlist' if `running' >= 0 & `running' < `band_r' & `touse', a(`site') 		    // right
					 matrix b1 = e(b)
					 predict `pred1' if !missing(`outcome'), xb
					 areg `outcome' `varlist' if `running' < 0 & `running' > `band_l' & `touse', a(`site') 
					 matrix b0 = e(b)
					 predict `pred0' if !missing(`outcome'), xb
				 }
				 else {
					 reghdfe `outcome' `varlist' if `running' >= 0 & `running' <= `band_r' & `touse', a(`FE'=`site') 	// right
					 matrix b1 = e(b)
					 predict `xb' if !missing(`outcome'), xb
					 bys `site': egen `d' = max(`FE')
					 gen `pred1' = `xb' + `d'
					 drop `d' `xb' `FE'
				 	
					 reghdfe `outcome' `varlist' if `running' < 0 & `running' > `band_l' & `touse', a(`FE'=`site')		// right
					 matrix b0 = e(b)
					 predict `xb' if !missing(`outcome'), xb
					 bys `site': egen `d' = max(`FE')
					 gen `pred0' = `xb' + `d'
					 drop `d' `xb' `FE'
				 }
				 
				 
				 }				 
		 
			 /* NOTE: Here we are implictly assuming that the FE are different on each side of the cutoff. This is because
			          we estimate them on each side. But then, we do not take them into account while retrieving the fitted
					  values. Indeed, to do things properly, two different strategies could have been applied:
					  
					  1. Constrained OLS, imposing FE(left) = FE(right) and then predict, xb;
					  2. Standard OLS, but then predict, xbd, which also uses estimated FEs to retrieve fitted values.
					  
					  The drawback with the first approach is that it can, in principle, have a large number of constraints, while
					  the second approach relies on the postestimation command predict, xbd which does not give out of sample estimates.
					  
					  So here, we let FEs to vary on each side of the cutoff, but then we treat them as fixed when retrieving fitted
					  values. Indeed, using just xb to retrieve them boils down in assuming that FEs are the same on each side of c.*/
			 
			 
				 
			 g `effect' = `pred1' - `pred0' if `touse' & `running' > `band_l' & `running' < `band_r'  // Estimate TE distribution
			 su `effect' if `assign'
			 local effect_1 = r(mean)                   // Average Effect on the Right
			 local N_T = r(N)
			 su `effect' if !`assign'
			 local effect_0 = r(mean)			        // Average Effect on the Left
			 local N_C = r(N)
			 }

			 
			 ** b) Propensity Score Weighting Estimator (Hirano, Imbens, and Ridder, 2003)			 

			 else if "`method'" == "pscore" {		    

				if mi("`site'") {                   // Compute pscore
					`model' `assign' `varlist' if !mi(`outcome') & `running' < `band_r' & `running' > `band_l' & `touse',  `asis'
				}
				if !mi("`site'") {
					`model' `assign' `varlist' i.`site' if !mi(`outcome') & `running' < `band_r' & `running' > `band_l' & `touse',  `asis'
				}
				
				tempvar ATNT ATT
				
				predict pred_p if e(sample) 
				replace pred_p = . if pred_p < `psLow' | pred_p > `psHigh'  // trim pscore

				su `assign' if !mi(pred_p)
				local p = r(mean)
				
				g `ATNT' = `outcome' * (`assign' - pred_p)/(pred_p*(1-`p'))
				su `ATNT'
				local effect_0 = r(mean)
				
				g `ATT' = `outcome' * (`assign' - pred_p)/((1-pred_p)*`p')	
				su `ATT'
				local effect_1 = r(mean)
				
				su `ATT' if `assign'
				local N_T = r(N)
				su `ATT' if !`assign'
				local N_C = r(N)
			}	

			 
			 
			 **** WITHIN-QUANTILE ESTIMATION ****
			 if (`nquant_l' > 0 & `nquant_r' > 0) & "`method'" == "linear" { 
			 	
				local effnq = `nquant_l' + `nquant_r'

			    matrix define QTLES = J(`effnq',4,.)
				xtile `qtle_xr' = `running' if `assign'  & `running' > 0 & `running' < `band_r' & `touse',  nq(`nquant_r')  // Quantiles on the right of the cutoff
				xtile `qtle_xl' = `running' if !`assign' & `running' > `band_l' & `running' < 0 & `touse', nq(`nquant_l')  // Quantiles on the left of the cutoff
				
				forval qt = 1/`nquant_l'{         
					su `effect' if `qtle_xl' == `qt' & !`assign' & `running' > `band_l' & `running' < 0 & `touse'  // left
				    matrix QTLES[`qt',1] = r(mean)			
				}	
				forval qt = 1/`nquant_r'{         
					su `effect' if `qtle_xr' == `qt' & `assign' & `running' > 0 & `running' < `band_r' & `touse'  // right
					local qtt = `qt' + `nquant_l'
				    matrix QTLES[`qtt',1] = r(mean)			
				}				
			 }
			 
			 else if (`nquant_l' > 0 & `nquant_r' > 0) & "`method'" == "pscore" {
			 	
			 	local effnq = `nquant_l' + `nquant_r'
				
			    matrix define QTLES = J(`effnq',4,.)
				xtile `qtle_xr' = `running' if `assign' & `running' > 0 & `running' < `band_r' & `touse' & !mi(pred_p),  nq(`nquant_r')  // Quantiles on the right of the cutoff
				xtile `qtle_xl' = `running' if !`assign' & `running' > `band_l' & `running' < 0 & `touse' & !mi(pred_p), nq(`nquant_l')  // Quantiles on the left of the cutoff
 	
				forval qt = 1/`nquant_l' {
					cap drop __inQt __teQt
					su `running' if `qtle_xl' == `qt' & `touse' & !mi(`outcome') & !mi(pred_p)
					g __inQt = `running' >= r(min) & `running' <= r(max) if `touse' & !mi(`outcome') & !mi(pred_p)
					
					if mi("`site'") {                   // Compute probability of being in quantile
						`model' __inQt `varlist' if !mi(`outcome') & `running' < `band_r' & `running' > `band_l' & `touse',  `asis'
					}
					if !mi("`site'") {
						`model' __inQt `varlist' i.`site' if !mi(`outcome') & `running' < `band_r' & `running' > `band_l' & `touse',  `asis'
					}
					predict __pscoreQt_L`qt' if e(sample)
					su __inQt 
					local pQt = r(mean)
					
					g __teQt = `outcome' * ( (`assign' - pred_p) / (pred_p * ( 1-pred_p)) ) * (__pscoreQt_L`qt' / `pQt')
					su __teQt
					matrix QTLES[`qt', 1] = r(mean)
					
				}

				forval qt = 1/`nquant_r' {
					cap drop __inQt __teQt
					su `running' if `qtle_xr' == `qt' & `touse' & !mi(`outcome') & !mi(pred_p)
					g __inQt = `running' >= r(min) & `running' <= r(max) if `touse' & !mi(`outcome') & !mi(pred_p)
					
					if mi("`site'") {                   // Compute probability of being in quantile
						`model' __inQt `varlist' if !mi(`outcome') & `running' < `band_r' & `running' > `band_l' & `touse',  `asis'
					}
					if !mi("`site'") {
						`model' __inQt `varlist' i.`site' if !mi(`outcome') & `running' < `band_r' & `running' > `band_l' & `touse',  `asis'
					}
					predict __pscoreQt_R`qt' if e(sample)
					su __inQt 
					local pQt = r(mean)
					
					g __teQt = `outcome' * ( (`assign' - pred_p) / (pred_p * ( 1-pred_p)) ) * (__pscoreQt_R`qt' / `pQt')
					su __teQt
					
					local qtt = `qt' + `nquant_l'
					matrix QTLES[`qtt', 1] = r(mean)
					
				}				
				
				
			 } 
			 
			 
			 
			 
			 ****  SE ESTIMATION WITH NON-PARAMETRIC BOOTSTRAP ****			 
			 if `bootrep' > 0 {
			 	 cap drop boot_*
				 set seed 8894
				 capture: nois _dots 0, reps(`bootrep') title("Bootstrapping standard errors ...")
				 capture: matrix define boot_M = J(`bootrep',2,.)
				 if (`nquant_l' > 0 & `nquant_r' > 0) {
						matrix define boot_Q = J(`bootrep',`effnq',.)
					}
			 
			 forval iter = 1/`bootrep'{
						nois _dots `iter' 0
			 
						preserve
						if mi("`site'") {
							bsample
						}
						else {
							bsample, cluster(`site')
						}
						
						** a) Linear Reweighting Estimator
						
						if "`method'" == "linear" | mi("`method'") {
							if mi("`site'") {
								reg `outcome' `varlist' if `running' >= 0 & `running' < `band_r' & `touse'			  // right
								predict `pred1b' if !missing(`outcome'), xb   
								reg `outcome' `varlist' if `running' < 0 & `running' > `band_l' & `touse'                 // left
								predict `pred0b' if !missing(`outcome'), xb
								}
								
							if !mi("`site'") {                                 // With FEs
								if mi("`reghd'") {
									areg `outcome' `varlist' if `running' >= 0 & `running' < `band_r' & `touse', a(`site')		// right
									predict `pred1b' if !missing(`outcome'), xb
									areg `outcome' `varlist' if `running' < 0 & `running' > `band_l' & `touse', a(`site') 
									predict `pred0b' if !missing(`outcome'), xb
								}
								else {
									reghdfe `outcome' `varlist' if `running' >= 0 & `running' <= `band_r' & `touse', a(`FE'=`site') 	// right
									predict `xb' if !missing(`outcome'), xb
									bys `site': egen `d' = max(`FE')
									gen `pred1b' = `xb' + `d'
									drop `d' `xb' `FE'
									
									reghdfe `outcome' `varlist' if `running' < 0 & `running' > `band_l' & `touse', a(`FE'=`site') 	
									predict `xb' if !missing(`outcome'), xb
									bys `site': egen `d' = max(`FE')
									gen `pred0b' = `xb' + `d'
									drop `d' `xb' `FE'								
								}
								 
							}				 

							gen `effectb' = `pred1b'-`pred0b' 

							su `effectb' if `assign' & `running' < `band_r' & `touse'
							matrix boot_M[`iter',1] = r(mean)
							su `effectb' if !`assign' & `running' > `band_l' & `touse'
							matrix boot_M[`iter',2] = r(mean)					
							
							cap drop qtle_xrb qtle_xlb
							
							if (`nquant_l' > 0 & `nquant_r' > 0) & "`method'" == "linear"{       
								xtile qtle_xrb = `running' if `assign'  & `running' > 0 & `running' < `band_r' & `touse',  nq(`nquant_r')  // Quantiles on the right of the cutoff
								xtile qtle_xlb = `running' if !`assign' & `running' > `band_l' & `running' < 0 & `touse', nq(`nquant_l')  // Quantiles on the left of the cutoff
								
								forval qt = 1/`nquant_l'{         
									su `effectb' if qtle_xlb == `qt' & !`assign' & `running' > `band_l' & `running' < 0  // left
									matrix boot_Q[`iter',`qt'] = r(mean)	
								}	
								forval qt = 1/`nquant_r'{         
									local qtt = `qt' + `nquant_l'
									su `effectb' if qtle_xrb == `qt' & `assign' & `running' > 0 & `running' < `band_r'    // right
									matrix boot_Q[`iter',`qtt'] = r(mean)			
								}							
							}
														
							restore
						}
						
						
						** b) Propensity Score Weighting Estimator
						
						else if "`method'" == "pscore" {
						
							if mi("`site'") {
								logit `assign' `varlist' if !mi(`outcome')  & `running' > `band_l' & `running' <`band_r' & `touse'
								}
							if !mi("`site'") {
								logit `assign' `varlist' i.`site' if !mi(`outcome')  & `running' > `band_l' & `running' < `band_r' & `touse'
								}
							
							predict pred_pb if e(sample)
							replace pred_pb = . if pred_pb < `psLow' | pred_pb > `psHigh'  // trim pscore
								
							su `assign' if !mi(pred_pb)
							local p = r(mean)
							
							g ATNTb = `outcome' * (`assign' - pred_pb)/(pred_pb*(1-`p'))
							su ATNTb
							matrix boot_M[`iter',1] = r(mean)
							
							g ATTb = `outcome' * (`assign' - pred_pb)/((1-pred_pb)*`p')	
							su ATTb
							matrix boot_M[`iter',2] = r(mean)
							
							forval qt = 1/`nquant_l' {
								cap drop __teQt
								su __inQt 
								local pQt = r(mean)
								
								g __teQt = `outcome' * ( (`assign' - pred_pb) / (pred_pb * ( 1-pred_pb)) ) * (__pscoreQt_L`qt' / `pQt')
								su __teQt
								matrix boot_Q[`iter', `qt'] = r(mean)
								
							}

							forval qt = 1/`nquant_r' {
								cap drop __teQt
								su __inQt 
								local pQt = r(mean)
								
								g __teQt = `outcome' * ( (`assign' - pred_pb) / (pred_pb * ( 1-pred_pb)) ) * (__pscoreQt_R`qt' / `pQt')
								local qtt = `qt' + `nquant_l'
								su __teQt								
								matrix boot_Q[`iter', `qtt'] = r(mean)
								
							}					
							
							restore
						}
					}
			  
			  svmat boot_M 
			  su boot_M1 
			  local se_eff1 = r(sd)
			  su boot_M2 
			  local se_eff0 = r(sd)	

     	      if (`nquant_l' > 0 & `nquant_r' > 0) {
			      svmat boot_Q
				  forval qt = 1/`effnq'{   
						su boot_Q`qt'
						matrix QTLES[`qt',2] = r(sd)
				  }
				  matrix colnames QTLES = Estimate SE Xlb Xub
			  }
			  drop boot_*
			  }
			  
 
			  **** PLOT WITHIN-QUANTILES ESTIMATES, ATT, ATNT AND SEs ****
			  if !mi("`qtleplot'"){
				preserve
					clear
					local alp   = (100 - `clevel')/200
					local proba = 1 - `alp'
					svmat QTLES
					
					g QTLES5 = QTLES1 - invnormal(`proba') * QTLES2
					g QTLES6 = QTLES1 + invnormal(`proba') * QTLES2
					g num = _n
					g ATT = `effect_1' 
					g ATNT = `effect_0'
					g ATTl = ATT - invnormal(`proba') * `se_eff1' 
					g ATTu = ATT + invnormal(`proba') * `se_eff1'					
					g ATNTl = ATNT - invnormal(`proba') * `se_eff0'
					g ATNTu = ATNT + invnormal(`proba') * `se_eff0'	
					local vertbar = `nquant_l' + 0.5
					g num2 = num
					replace num2 = `vertbar' if num2 == `nquant_l'
					replace num2 = `vertbar' if num2 == `nquant_l' + 1
					replace num2 = 0.5 if num2 == 1
					replace num2 = _n + 0.5 if num2 == _n
					twoway (line ATTl num2 if num > `vertbar', lc(green) lp(dash) lw(vvthin) fintensity(inten20))    /// /* ATT lower bound      */
					       (line ATTu num2 if num > `vertbar', lc(green) lp(dash) lw(vvthin) fintensity(inten20))    /// /* ATT upper bound      */
   						   (line ATNTl num2 if num < `vertbar', lc(orange) lp(dash) lw(vvthin) fintensity(inten20))  /// /* ATNT lower bound     */
   						   (line ATNTu num2 if num < `vertbar', lc(orange) lp(dash) lw(vvthin) fintensity(inten20))  /// /* ATNT upper bound     */
						   (line ATT num2 if num > `vertbar', lcolor(green) lp(solid) lw(thin)) 				     /// /* ATT point estimate   */
						   (line ATNT num2 if num < `vertbar', lcolor(orange) lp(solid) lw(thin)) 					 /// /* ATNT point estimate  */
						   (rspike QTLES5 QTLES6 num, lcolor(black) xline(`vertbar',lc(black) lw(vthin) lp(dash)))	 /// /* Qtles 95% CI         */
						   (scatter QTLES1 num, mcolor(cranberry) m(T)), 											 /// /* Qtles point estimate */
						    xlabel(1(1)`effnq')  ytitle("Treatment Effect ") ylabel(,nogrid) legend(order(5 6 8 7) lab(5 "ATT") ///
							lab(6 "ATNT") lab(8 "Within-Quantile Estimate") lab(7 "95% CI") rows(2) region(style(none)) nobox) xtitle("Quantiles")     ///
							title("Treatment Effect") `gphoptions'						
					
				restore
			  }
		 	 
			 
		 * Storage of results
		 scalar drop _all
		 if !mi("`genvar'"){
			 g `genvar' = `effect'
			 }
			
			
		 }	
		 
		 cap drop __pscoreQt*
				
		  ** Prepare elements to print
			
		  * Create rownames	for QTLES
		  if (`nquant_l' > 0 & `nquant_r' > 0) {
			  local lqt 			
			  forval qt = 1/`nquant_l'{
				local aux = strtoname("Left `qt'")
				local lqt `lqt' `aux'
			  }     
			  forval qt = 1/`nquant_r'{
				local aux = strtoname("Right `qt'")
				local lqt `lqt' `aux'
			  }     								  
			  
			  * Store intervals of running variables
			  local qttot = 1
			  forval qt = 1/`nquant_l'{
				qui su `running' if `qtle_xl' == `qt'
				matrix QTLES[`qttot', 3] = r(min)
				matrix QTLES[`qttot', 4] = r(max)
				local qttot = `qttot' + 1
			  }
			  forval qt = 1/`nquant_r'{
				qui su `running' if `qtle_xr' == `qt'
				matrix QTLES[`qttot', 3] = r(min)
				matrix QTLES[`qttot', 4] = r(max)
				local qttot = `qttot' + 1
			  }
			  
			  * Round QTLES matrix
			  mata : Mrounded=round(st_matrix("QTLES"),.001) 
			  mata : st_matrix("QTLESr",Mrounded)
			  matrix rownames QTLES = `lqt'
			  matrix rownames QTLESr = `lqt'
			  matrix colnames QTLESr = Estimate SE Xlb Xub
		  }


		  * Prepare matrix with main causal estimates
		  matrix define params = J(2,2,.)
		  matrix params[2,1] = `effect_1'
		  matrix params[1,1] = `effect_0'
		  if `bootrep' > 0 {
			  matrix params[2,2] = `se_eff1'
			  matrix params[1,2] = `se_eff0'
		  }
	  
		  mata : Prounded=round(st_matrix("params"),.001) 		 
		  mata : st_matrix("paramsr",Prounded)
		  matrix colnames paramsr = Estimate SE
		  matrix rownames paramsr = ATNT ATT
		  
		  if !mi("`site'") {
		  	local FElogical "`site'"
		  } 
		  else {
		  	local FElogical "No"
		  }
		  
		  
		  if mi("`method'") {
		  	local method = "linear"
		  } 

		  * Print results
		  di as text ""
		  di as text "{hline 80}"
		  di as text "{bf:             Extrapolation Results }"
		  di as text "{hline 80}"
		  
		  di as text "Outcome Variable            `outcome'"
		  di as text "Running Variable            `score'"

		  di as text ""
		  
		  di as text "Number of observations "
		  di as text "              Treated       `N_T'"
		  di as text "              Control       `N_C'"
		  di as text "Cutoff                      `cutoff'"
		  di as text "Bandwidth                   `bandwidth'"
		  di as text "Bootstrap Iterations        `bootrep'"
		  di as text "Site Fixed Effects          `FElogical'"
		  di as text "Method                      `method'"
		  

		  di as text ""
		  di as text "{it: Main Estimates}"
		  matrix list paramsr, noblank noheader format(%4.3f)
	  
		  if (`nquant_l' > 0 & `nquant_r' > 0) {
			  di as text ""
			  di as text "{it: Within-Quantile Estimates}"
			  matrix list QTLESr, noblank noheader format(%4.3f)
		  }

		  di as text ""
		  di as text "CIA Covariates: `varlist'"

		 if (`bootrep' == 0) {
		 	di as text ""
			di as text "To compute standard errors use the option bootrep(#)!"
		 }
		 
		 
		 
		  di as text "{hline 80}"				 
		 
						
		 return clear
		 ereturn clear
					
					
		 if `strap' == 1 {
			 if (`nquant_l' > 0 & `nquant_r' > 0) {
					ereturn matrix quantiles = QTLES
				}
			 ereturn scalar se_eff1 = `se_eff1'
			 ereturn scalar se_eff0 = `se_eff0'
		 }

		 if "`method'" == "linear" | mi("`method'") {
			 ereturn matrix b1_kline = b1
			 ereturn matrix b0_kline = b0
		 }			 

		 ereturn scalar effect1  = `effect_1'			 
		 ereturn scalar effect0  = `effect_0'
		 ereturn scalar N_T      = `N_T'			 
		 ereturn scalar N_C      = `N_C'
		 
			 
end
