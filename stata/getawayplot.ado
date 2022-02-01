*! Date        : 17 Jan 2022
*! Version     : 0.5
*! Authors     : Filippo Palomba
*! Email       : fpalomba@princeton.edu
*! Description : Plot non-parametric extrapolation of treatment effect

/*
FUTURE release should include:
	- Extension to PSW estimation.
	- Add fuzzy version 
*/

/* 
START HELP FILE

title[Plot non-parametric extrapolation of treatment effect.]

desc[
{cmd:getawayplot} plots non-parametric estimates of the actual and counterfactual regression functions using the methodology discussed in 
Angrist and Rokkanen (2015) in a Regression Discontinuity framework. The command relies on {help lpoly} to get smooth estimates of the two
potential outcomes. Then, it jointly plots the actual smoothed regression function and the counterfactual smoothed regression function together
with within-bin averages of the counterfactual outcome to show the fit of the non-parametric estimates. 
]

opt[outcome specifies the dependent variable of interest.]
opt[score specifies the running variable.]
opt[bandwidth specifies the bandwidth to be used for estimation. The user can specify a different bandwidth for each side.]
opt[cutoff specifies the RD cutoff for the running variable.  Default is {cmd:c(0)}. The cutoff value is subtracted from the {it:score} variable and the bandwidth. In case multiple cutoffs are present, provide the pooled cutoff.]
opt[kernel specifies the kernel function. The default is {cmd:kernel(}{it:epanechnikov}{cmd:)}. See kernel functions allowed in {help lpoly}.]
opt[site specifies the variable identifying the site to add site fixed effects.]
opt[degree specifies the degree of the local polynomial smooth. The default is {cmd: degree(0)}.]
opt[nbins specifies the number of bins for which the counterfactual average is shown in the final graph. Default is {cmd:nbins(10 10)}.]
opt[gphoptions specifies graphical options to be passed on to the underlying graph command.]

example[

The example below show how to correctly use the command {cmd:getawayplot} to plot actual and counterfactual regression functions. 
Suppose that we have at hand an {it:outcome} variable, a {it:score} variable and a set of K covariates ({it:varlist}) that makes the running variable
ignorable. For the sake of the example assume the bandwidth to be 10 and the cutoff to be 0. To plot the regression functions, then

{cmd:getawayplot cov1 cov2 ... covK, o(outcome) s(score) b(10) path({it:saving_location.format})}

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
{synopt:{help ciatest}  (if installed)}   {stata ssc install ciatest}      (to install) {p_end}
{synopt:{help getaway} (if installed)} {stata ssc install getaway}   (to install) {p_end}

{p2colreset}{...}

]

references[
Angrist, J. D., & Rokkanen, M. (2015). Wanna get away? Regression discontinuity estimation of exam school effects away from the cutoff. 
{it:Journal of the American Statistical Association}, 110(512), 1331-1344.
]

END HELP FILE 
*/

program getawayplot              
version 14.0           
		
		syntax varlist(ts fv) [if] [in], Outcome(varname) Score(varname) Bandwidth(string) [Cutoff(real 0) Kernel(string) site(varname) Degree(integer 1) ///
		NBins(numlist max=2 integer) gphoptions(string)]

		tempvar running	pred1 pred0 fit0 fit1 temp_x temp_xR temp_y temp_pred0 temp_pred1 temp_i
			   
	qui{	         
			 
			 marksample touse, novarlist       // marksample just for "if" and "in" conditions
			 
			 ** Setting smoothing kernel and step for computing within-bin averages
			 
			 if mi("`kernel'"){   // Default kernel
				local kernel "epanechnikov"
			 }
			 
			 local dg = `degree'
			 
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
					 
			 
			 ** Number of bins on the left and on the right of the cutoff
			 if mi("`nbins'") {         // Default polynomial degree
				local nbins "10 10"
				}
			 tokenize `nbins'	
			 local w : word count `nbins'

			 if `w' == 1 {
				local nbins_r = `"`1'"'
				local nbins_l = `"`1'"'
			 }
			 if `w' == 2 {
				local nbins_l `"`1'"'
				local nbins_r `"`2'"'
			 }				
			 
			 ** NOTE: atm only linear reweighting estimator is supported!!!
			 
			 * Estimate actual regression function and retrieve out of sample prediction for counterfactual regression function
			 
			 if mi("`site'") {   // Without FEs
	   			 reg `outcome' `varlist' if `running' >= 0 & `running' < `band_r' & `touse'			  // right
				 predict `pred1' if !missing(`outcome') & `touse', xb   
				 reg `outcome' `varlist' if `running' < 0 & `running' > `band_l' & `touse'              // left
				 predict `pred0' if !missing(`outcome') & `touse', xb
				 }
				 
			 if !mi("`site'") {   // With FEs
				 reg `outcome' `varlist' i.`site' if `running' >= 0 & `running' < `band_r' & `touse' 		// right
				 predict `pred1' if !missing(`outcome') & `touse', xb   
				 reg `outcome' `varlist' i.`site' if `running' < 0 & `running' > `band_l' & `touse'		// left
				 predict `pred0' if !missing(`outcome') & `touse', xb
				 }				 
			 
			 * Get a smoother estimate of the two potential outcomes 
 			 lpoly `pred0' `running', degree(`dg') kernel(`kernel') generate(`fit0') at(`running') nograph // Y_0
			 lpoly `pred1' `running', degree(`dg') kernel(`kernel') generate(`fit1') at(`running') nograph // Y_1
			 
			 * Divide in bins the support of the running variable and compute averages to be shown as a scatter in final graph			

			 local stepL = `band_l'/`nbins_l'
			 local step2L = `stepL'/2
			 egen `temp_x' = cut(`running'), at(`band_l'(`stepL')0)
			 replace `temp_x' = `temp_x' + `step2L'

			 local stepR = `band_r'/`nbins_r'
			 local step2R = `stepR'/2
			 egen `temp_xR' = cut(`running'), at(0(`stepR')`band_r')
			 replace `temp_xR' = `temp_xR' + `step2R'
			 replace `temp_x' = `temp_xR' if `running' > 0
			
			 bysort `temp_x': egen `temp_y' = mean(`outcome')
			 bysort `temp_x': egen `temp_pred0' = mean(`pred0')
			 bysort `temp_x': egen `temp_pred1' = mean(`pred1')
			 bysort `temp_x': gen `temp_i' = _n
			 
			local x_lb   = -floor(-`band_l')
			local x_ub   =  floor( `band_r')
			local x_step = (`band_r' -`band_l')/5

			 
			 ** Plot of Actual and Counterfactual Regression Function
			
			 graph twoway  ///
			 (scatter `temp_pred1' `temp_x' if `temp_x' > `band_l' & `temp_x' < `band_r' & `running' < 0 & `temp_i' == 1, msymbol(x) mcolor(red)) 		       ///
			 (scatter `temp_pred0' `temp_x' if `temp_x' > `band_l' & `temp_x' < `band_r' & `running' >= 0 & `temp_i' == 1, msymbol(x) mcolor(red))              ///
			 (lpoly `fit0' `running' if `running' > `band_l' & `running' < `band_r' & `running' < 0,  deg(`dg') k(`kernel') lc(black) lp(solid) lw(medthick))     ///
			 (lpoly `fit1' `running' if `running' > `band_l' & `running' < `band_r' & `running' >= 0, deg(`dg') k(`kernel') lc(black) lp(solid) lw(medthick))    ///
			 (lpoly `fit1' `running' if `running' > `band_l' & `running' < `band_r' & `running' < 0,  deg(`dg') k(`kernel') lp(shortdash) lw(medthick) lc(red))   ///
			 (lpoly `fit0' `running' if `running' > `band_l' & `running' < `band_r' & `running' >= 0, deg(`dg') k(`kernel') lp(shortdash) lw(medthick) lc(red)), ///
			 legend(order(4 6) size(small) label(4 "Fitted") label(6 "Extrapolated")) xtitle("Standardized Running Variable") 				       ///
			 ytitle("Outcome") xline(0) xlabel(`x_lb'(`x_step')`x_ub') ylabel(,nogrid) `gphoptions'
			
		     }
end
