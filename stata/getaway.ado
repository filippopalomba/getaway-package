*! Date        : 17 Jan 2022
*! Version     : 0.5
*! Authors     : Filippo Palomba
*! Email       : fpalomba@princeton.edu
*! Description : Estimate Heterogeneous TEs in Sharp RDD

/*
FUTURE release should include:
	- Extension of PSW estimation to quantiles.
	- Merge with the fuzzy version
	- Add a table for printing results
	- Add cluster bootstrap
*/

/* 
START HELP FILE

title[Estimate treatment effect away from the cutoff in a Sharp RDD framework.]

desc[
{cmd:getaway} uses variables contained in {it:varlist} to estimate the treatment effect away from the cutoff in a Sharp Regression Discontinuity
framework as proposed by Angrist and Rokkanen (2015). 

The command {cmd:getaway} can use either the Linear Reweighting Estimator or the Propensity Score Weighting Estimator. The average treatment effect 
on the left and on the right of the cutoff are estimated by default. In addition, {cmd:getaway} gives the possibility to estimate the treatment effect 
on finer intervals of the support of the running variable. The command allows to plot the estimates together with their bootstrapped standard errors.]

opt[outcome specifies the dependent variable of interest.]
opt[score specifies the running variable.]
opt[bandwidth specifies the bandwidth to be used for estimation. The user can specify a different bandwidth for each side.]
opt[cutoff specifies the RD cutoff for the running variable.  Default is {cmd:c(0)}. The cutoff value is subtracted from the {it:score} variable and the bandwidth. In case multiple cutoffs are present, provide the pooled cutoff.]
opt[method allows to choose the estimation method between Linear Rewighting Estimator ({it:linear}) and Propensity Score Weighting Estimator ({it:pscore}). Default is {cmd:method(}{it:linear}{cmd:)}.]	
opt[site specifies the variable identifying the site to add site fixed effects.]
opt[bootrep sets the number of replications of the non-parametric bootstrap. Default is {cmd:bootrep(0)}. If {cmd: site} is specified a non-parametric block bootstrap is used.]
opt[nquant specifies the number of quantiles in which the treatment effect must be estimated. It can be specified separately for each side. Default is {cmd:nquant(0 0)}. 
	To be specified if {cmd: qtleplot} is used.] 
opt[qtleplot plots estimated treatment effect over running variable quantiles together with bootstrapped standard errors. 
	Also estimates and bootstrapped standard errors of the Average Treatment Effect on the Treated (ATT) and on the Non Treated (ATNT) are reported.]
opt[gphoptions specifies graphical options to be passed on to the underlying graph command.]
opt[genvar specifies the name of the variable containing the distribution of treatment effects. Only with {it:linear} option.]
opt[asis forces retention of perfect predictor variables and their associated perfectly predicted observations in p-score estimation. To be used only with {it:pscore}.]

return[N_C Number of control observation.]
return[N_T Number of treatment observation.]
return[effect0 Average effect on the left of the cutoff.]
return[effect1 Average effect on the right of the cutoff.]
return[b0_kline Estimated weight of each covariate used in CIA test (left of cutoff)]
return[b1_kline Estimated weight of each covariate used in CIA test (right of cutoff)]
return[se_eff0 Bootstrapped standard error of the average effect on the left of the cutoff.]
return[se_eff1 Bootstrapped standard error of the average effect on the right of the cutoff.]
return[quantiles Matrix containing point estimates and standard errors of the quantiles.]
return[effect Variable containing estimated treatment effect for each observation in the sample (only linear reweighting estimator).]

example[

The examples below show how to correctly use the command {cmd:getaway} to estimate heterogeneous treatment effects in a sharp RDD framework. 
Suppose that we have at hand an {it:outcome} variable, a {it:score} variable and a set of K covariates ({it:varlist}) that makes the running variable
ignorable. For the sake of the example assume the bandwidth to be 10 and the cutoff to be 0. If we are interested in just the ATT and the ATNT , then

{cmd:getaway cov1 cov2 ... covK, o(outcome) s(score) b(10)}           - using Linear Rewighting Estimator 

{cmd:getaway cov1 cov2 ... covK, o(outcome) s(score) b(10) m(pscore)} - using Propensity Score Weighting Estimator

If, in addition, we are pooling together different rankings, then we should add fixed effects at the site level (see Fort et al. (2022))

{cmd:getaway cov1 cov2 ... covK, o(outcome) s(score) b(10) site(ranking)}

If we are interested in estimating the treatment effect on 5 quantiles of the running variable on each side (10 quantiles in total) and we also want to
estimate their standard errors with 200 repetitions of a non-parametric bootstrap, then

{cmd:getaway cov1 cov2 ... covK, o(outcome) s(score) b(10) nquant(5) bootrep(200)}

and if we want also a graphical representation of the estimates

{cmd:getaway cov1 cov2 ... covK, o(outcome) s(score) b(10) nquant(5) bootrep(200) qtleplot}

]

author[Filippo Palomba]
institute[Department of Economics, Princeton University]
email[fpalomba@princeton.edu]


seealso[

{pstd}
Other Related Commands (ssc repository not working yet): {p_end}

{synoptset 27 }{...}

{synopt:{help ciasearch} (if installed)} {stata ssc install ciasearch}   (to install) {p_end}
{synopt:{help ciares} (if installed)}   {stata ssc install ciares} (to install) {p_end}
{synopt:{help ciacs} (if installed)}   {stata ssc install ciacs}     (to install) {p_end}
{synopt:{help ciatest} (if installed)} {stata ssc install ciatest}   (to install) {p_end}
{synopt:{help getawayplot}  (if installed)}   {stata ssc install getawayplot}      (to install) {p_end}

{p2colreset}{...}

]

references[
Angrist, J. D., & Rokkanen, M. (2015). Wanna get away? Regression discontinuity estimation of exam school effects away from the cutoff. 
{it:Journal of the American Statistical Association}, 110(512), 1331-1344.
]

END HELP FILE 
*/


program getaway, eclass
version 14.0           
		
		syntax varlist(ts fv) [if] [in], Outcome(varname) Score(varname) Bandwidth(string) [Cutoff(real 0) Method(string) site(varname) ///
			   NQuant(numlist max=2 integer) BOOTrep(integer 0) qtleplot gphoptions(string) GENvar(string) asis]

		tempvar assign qtle_x qtle_xl qtle_xr running pred0 pred1 pred0b pred1b effect effectb
			   
	    qui {
		
		
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
			 
			 
			 if "`method'" == "pscore" {             // atm pscore does not support quantile estimation
				local effnq = 0
				}
			
			
			 local strap = 0
			 if `bootrep' != 0 {
				local strap = 1
				}
			
			 if !mi("`qtleplot'") & `bootrep' == 0 {  // In order to plot within-quantile estimates with SE bootrep must be specified
				di as error "Please specify a number of bootstrap iterations!"
				exit
				}
								
			 if (`nquant_l' > 0 & `nquant_r' > 0) & `bootrep' == 0 {       // In order to report within-quantile estimates with SE bootrep must be specified
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
*				 reg `outcome' `varlist' i.`site' if `running' >= 0 & `running' <= `bandwidth' & `touse'		// right
				 areg `outcome' `varlist' if `running' >= 0 & `running' < `band_r' & `touse', a(`site') 		// right
*				 reghdfe `outcome' `varlist' if `running' >= 0 & `running' <= `bandwidth' & `touse', a(`site')  resid		// right
				 matrix b1 = e(b)
				 predict `pred1' if !missing(`outcome'), xb   				 
*				 reg `outcome' `varlist' i.`site' if `running' < 0 & `running' > - `bandwidth' & `touse'		// left
				 areg `outcome' `varlist' if `running' < 0 & `running' > `band_l' & `touse', a(`site') 
*				 reghdfe `outcome' `varlist' if `running' < 0 & `running' > -`bandwidth' & `touse', a(`site') resid		// right
				 matrix b0 = e(b)
				 predict `pred0' if !missing(`outcome'), xb
				 
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
			 
			 
				 
			 g `effect' = `pred1' - `pred0' if `running' < `band_r' & `running' > `band_l'  // Estimate TE distribution
			 su `effect' if `assign' & `running' < `band_r'  & `touse'
			 local effect_1 = r(mean)                   // Average Effect on the Right
			 local N_T = r(N)
			 su `effect' if !`assign' & `running' > `band_l' & `touse'
			 local effect_0 = r(mean)			        // Average Effect on the Left
			 local N_C = r(N)
			 }

			 
			 ** b) Propensity Score Weighting Estimator (Hirano, Imbens, and Ridder, 2003)			 

			 else if "`method'" == "pscore" {		    

				if mi("`site'") {                   // Compute pscore
					logit `assign' `varlist' if !mi(`outcome') & `running' < `band_r' & `running' > `band_l' & `touse',  `asis'
					}
				if !mi("`site'") {
					logit `assign' `varlist' i.`site' if !mi(`outcome') & `running' < `band_r' & `running' > `band_l' & `touse',  `asis'
					}
				 
				predict pred_p if e(sample)
				
				su `assign' if !mi(pred_p)
				local p = r(mean)
				
				gen w0 = (1 - `assign')/(1 - pred_p)
				gen w1 = `assign'/pred_p
				
				gen w00 = w0*((1 - pred_p)/(1 - `p'))
				gen w10 = w1*((1 - pred_p)/(1 - `p'))
				
				gen w01 = w0*(pred_p/`p')
				gen w11 = w1*(pred_p/`p')
								
				foreach w in w00 w10 w01 w11 {
					su `w' if !mi(`outcome')
					replace `w' = `w'/r(mean)
				}
				noisily{
				gen temp = (w10 - w00)*`outcome'
				su temp 
				local effect_0 = r(mean)
				drop temp
				
				gen temp = (w11 - w01)*`outcome'
				su temp 
				local effect_1 = r(mean)
				drop temp
				}
				drop pred_p w0 w1 w00 w10 w01 w11
			}	

			 
			 
			 **** WITHIN-QUANTILE ESTIMATION ****
			 
			 if (`nquant_l' > 0 & `nquant_r' > 0) & "`method'" != "pscore"{       // atm pscore is not supported!!
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
			 
			 ****  SE ESTIMATION WITH NON-PARAMETRIC BOOTSTRAP ****

			 if `bootrep' > 0 {
				 set seed 8894
				 capture: nois _dots 0, reps(`bootrep') title("Bootstrapping standard errors ...")
				 capture: matrix define boot_M = J(`bootrep',2,.)
				 if (`nquant_l' > 0 & `nquant_r' > 0) & "`method'" != "pscore"{
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
			*				reg `outcome' `varlist' i.`site' if `running' >= 0 & `running' <= `bandwidth' & `touse'		// right
							areg `outcome' `varlist' if `running' >= 0 & `running' < `band_r' & `touse', a(`site')		// right
							predict `pred1b' if !missing(`outcome'), xb   
			*				reg `outcome' `varlist' i.`site' if `running' < 0 & `running' > - `bandwidth' & `touse'		// left
							areg `outcome' `varlist' if `running' < 0 & `running' > `band_l' & `touse', a(`site') 
							predict `pred0b' if !missing(`outcome'), xb
							}				 

						gen `effectb' = `pred1b'-`pred0b' 

						su `effectb' if `assign' & `running' < `band_r' & `touse'
						matrix boot_M[`iter',1] = r(mean)
						su `effectb' if !`assign' & `running' > `band_l' & `touse'
						matrix boot_M[`iter',2] = r(mean)					
						
						cap drop qtle_xrb qtle_xlb

						if (`nquant_l' > 0 & `nquant_r' > 0) & "`method'" != "pscore"{       // atm pscore is not supported!!
							xtile qtle_xrb = `running' if `assign'  & `running' > 0 & `running' < `band_r' & `touse',  nq(`nquant_r')  // Quantiles on the right of the cutoff
							xtile qtle_xlb = `running' if !`assign' & `running' > `band_l' & `running' < 0 & `touse', nq(`nquant_l')  // Quantiles on the left of the cutoff
							
							forval qt = 1/`nquant_l'{         
								su `effectb' if qtle_xlb == `qt' & !`assign' & `running' > `band_l' & `running' < 0  // left
								matrix boot_Q[`iter',`qt'] = r(mean)	
							}	
							forval qt = 1/`nquant_r'{         
								su `effectb' if qtle_xrb == `qt' & `assign' & `running' > 0 & `running' < `band_r'    // right
								local qtt = `qt' + `nquant_l'
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
							 
						predict pred_p if !mi(`outcome')
							
						su pred_p if !`assign'
						su pred_p if `assign'
						su `assign' if !mi(pred_p)
						local p = r(mean)
						
						gen w0 = (1 - `assign')/(1 - pred_p)
						gen w1 = `assign'/pred_p
					
						gen w00 = w0*((1 - pred_p)/(1 - `p'))
						gen w10 = w1*((1 - pred_p)/(1 - `p'))
							
						gen w01 = w0*(pred_p/`p')
						gen w11 = w1*(pred_p/`p')
											
						foreach w in w00 w10 w01 w11 {
							su `w' if !mi(`outcome')
							replace `w' = `w'/r(mean)
						}
					
						gen temp = (w10 - w00)*`outcome'
						su temp if `running' > `band_l' & `running' < `band_r' & `touse'
						matrix boot_M[`iter',1] = r(mean)
						drop temp
							
						gen temp = (w11 - w01)*`outcome'
						su temp if `running' > `band_l' & `running' < `band_r' & `touse'
						matrix boot_M[`iter',2] = r(mean)
						drop temp
						drop pred_p w0 w1 w00 w10 w01 w11
						restore
						}
					}
			  
			  svmat boot_M 
			  su boot_M1 
			  local se_eff1 = r(sd)
			  su boot_M2 
			  local se_eff0 = r(sd)	
     	      if `effnq' > 0 {
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
					svmat QTLES
					g QTLES5 = QTLES1 - invnormal(0.975) * QTLES2
					g QTLES6 = QTLES1 + invnormal(0.975) * QTLES2
					g num = _n
					g ATT = `effect_1' 
					g ATNT = `effect_0'
					g ATTl = ATT - invnormal(0.975) * `se_eff1' 
					g ATTu = ATT + invnormal(0.975) * `se_eff1'					
					g ATNTl = ATNT - invnormal(0.975) * `se_eff0'
					g ATNTu = ATNT + invnormal(0.975) * `se_eff0'	
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
			 			
				
		  ** Prepare elements to print
			
			
		  * Create rownames	for QTLES
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
		  
		  * Prepare matrix with main causal estimates
		  matrix define params = J(2,2,.)
		  matrix params[2,1] = `effect_1'
		  matrix params[1,1] = `effect_0'
		  matrix params[2,2] = `se_eff1'
		  matrix params[1,2] = `se_eff0'
		  
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
		  
		  di as text ""
		  di as text "{it: Within-Quantile Estimates}"
		  matrix list QTLESr, noblank noheader format(%4.3f)

		  di as text ""
		  di as text "CIA Covariates: `varlist'"

		 
		 
		 
		 
		  di as text "{hline 80}"				 
		 
						
					
					
		 if `strap' == 1 {
			 if `effnq' > 0 {
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
