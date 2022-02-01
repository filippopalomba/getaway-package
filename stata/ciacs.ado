*! Date        : 17 Jan 2022
*! Version     : 0.5
*! Authors     : Filippo Palomba
*! Email       : fpalomba@princeton.edu
*! Description : Graphical visualization of the common support condition in RDD

/*
FUTURE release should include:
	- Appropriate label tickers on the Y-axis.
*/

/* 
START HELP FILE

title[Verify graphically the common support condition for heterogeneous treatment effect estimation in RDD.]

desc[
{cmd:getawaycs} allows to visualize the common support condition to validate estimation of treatment effects away from the cutoff in a Regression Discontinuity framework as proposed in 
Angrist and Rokkanen (2015).
]

opt[outcome specifies the dependent variable of interest. This option is used just to mark the sample on which the pscore is estimated.]
opt[assign sets the assignment to treatment variable.]
opt[score specifies the running variable.]
opt[bandwidth specifies the bandwidth to be used for estimation. The user can specify a different bandwidth for each side.]
opt[cutoff specifies the RD cutoff for the running variable.  Default is {cmd:c(0)}. The cutoff value is subtracted from the {it:score} variable and the bandwidth. In case multiple cutoffs are present, provide the pooled cutoff.]
opt[nbins number of bins of the common support histogram. Default is {cmd:nbins(10 10)}.]
opt[site specifies the variable identifying the site to add site fixed effects.]
opt[asis forces retention of perfect predictor variables and their associated perfectly predicted observations.]
opt[gphoptions specifies graphical options to be passed on to the underlying graph command.]
opt[pscore specifies the name of the variable containing the pscore. This variable is added to the current dataset.]
opt[probit implements a probit model to estimate the pscore.]
opt[kdensity displays kernel densities rather than histograms, which is the default.]
opt[nograph suppresses any graphical output.]

example[

The example below show how to correctly use the command {cmd:ciacs} to visualize the common support condition. 
Suppose that we have at hand an {it:outcome} variable, a {it:score} variable that induces assignment to treatment ({it:assign}) 
and a set of K covariates ({it:varlist}) that makes the running variable ignorable. For the sake of the example assume the bandwidth 
to be 10 and the cutoff to be 0. To verify the common support condition graphically, then

{cmd:ciacs cov1 cov2 ... covK, o(outcome) a(assign) s(score) b(10)}
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
{synopt:{help ciatest} (if installed)}   {stata ssc install ciatest}     (to install) {p_end}
{synopt:{help getaway} (if installed)} {stata ssc install getaway}   (to install) {p_end}
{synopt:{help getawayplot}  (if installed)}   {stata ssc install getawayplot}      (to install) {p_end}

{p2colreset}{...}

]

references[
Angrist, J. D., & Rokkanen, M. (2015). Wanna get away? Regression discontinuity estimation of exam school effects away from the cutoff. 
{it:Journal of the American Statistical Association}, 110(512), 1331-1344.
]

END HELP FILE 
*/

program ciacs, rclass         
version 14.0           
		
		syntax varlist(ts fv) [if] [in], Outcome(varname) Assign(varname) Score(varname) Bandwidth(string) [Cutoff(real 0) NBins(integer 10)  ///
				site(varname) asis gphoptions(string) pscore(string) probit KDensity NOGraph]
			  
			  tempvar pred temp temp_x temp_y1 temp_y0 temp_i score_std
			  
			  qui {
					
					marksample touse, novarlist       // marksample just for "if" and "in" conditions
					
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
					
				    ** Standardize the X variable (if no cutoff specified it just subtracts 0) and translate bandwidth
					g `score_std' = `score' - `cutoff'
					local band_l = `band_l' - `cutoff'
					local band_r = `band_r' - `cutoff'
					
					
					if !mi("`asis'") {
						local asis `asis'
						}
					if mi("`asis'") {
						local asis
						}
						
					if !mi("`pscore'") {                     // Check that the name for the new variable has not been taken!
						capture confirm variable `pscore'
						if _rc == 0 {
							di as error "`pscore' already exists! Please choose a different name!"
							error 110
							}
						}
					
					** Select probability model
					if mi("`probit'") {
						local model "logit"
						}
					else if !mi("`probit'") {
						local model "probit"
						}
					
										
					** Pscore estimation
					if mi("`site'") {
						`model' `assign' `varlist' if !mi(`outcome') & `score_std' > `band_l' & `score_std' < `band_r'  & `touse', `asis' 
						}
					if !mi("`site'") {
						`model' `assign' `varlist' i.`site' if !mi(`outcome') & `score_std' > `band_l' & `score_std' < `band_r' & `touse', `asis'
						}
						
					count if e(sample) & `assign'
					local N_T = r(N)
					count if e(sample) & !`assign'
					local N_C = r(N)
					predict `pred' if e(sample), pr     // Retrieve estimated pscore
					

					if mi("`kdensity'") & mi("`nograph'") {
					
					local step = 1/`nbins'
					egen `temp' = cut(`pred'), at(0(`step')1)      // Creating grid on which histogram columns should be displayed
					egen `temp_x' = group(`temp')
					replace `temp_x' = `temp_x' - 0.5
					drop `temp'

					bysort `temp_x': egen `temp' = count(`temp_x') if !`assign'    // Creating columns
					bysort `temp_x': egen `temp_y0' = mean(`temp')
					drop `temp'				
					replace `temp_y0' = -`temp_y0'
					
					bysort `temp_x': egen `temp' = count(`temp_x') if `assign'
					bysort `temp_x': egen `temp_y1' = mean(`temp')
					drop `temp'
					
					bysort `temp_x': gen `temp_i' = _n

					* Creating X-axis labels
					local tk1 = `nbins'/5
					local tk2 = `tk1'*2
					local tk3 = `tk1'*3
					local tk4 = `tk1'*4
										
						** Plot common support histograms
						graph twoway (bar `temp_y1' `temp_x' if `temp_i' == 1, color(navy)) (bar `temp_y0' `temp_x' if `temp_i' == 1, color(maroon)),  ///
							xtitle("Propensity Score") ytitle("Frequency") legend(label(1 "Treated") label(2 "Control") size(small)) 				   ///
							xlabel(0 "0" `tk1' "0.2" `tk2' "0.4" `tk3' "0.6" `tk4' "0.8" `nbins' "1") ylabel("", nogrid)   	         				   ///
							title("Common Support") note("T:`N_T', C:`N_C'") `gphoptions'
						}				
					
					if !mi("`kdensity'") & mi("`nograph'") {
					
						** Plot kdensities
						graph twoway (kdensity `pred' if `assign', color(navy) lp(solid)) (kdensity `pred' if !`assign', color(maroon) lp(solid)),    ///
							xtitle("Propensity Score") ytitle("Density") legend(label(1 "Treated") label(2 "Control") size(small))   				  ///
							xlabel(0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1 "1") ylabel(, nogrid)   	 						 				  ///
							title("Common Support") note("T:`N_T', C:`N_C'") `gphoptions'
						}
						
											
					if !mi("`pscore'") {
						g `pscore' = `pred'
					}
					
					
					*************************************
					***** COMMON SUPPORT TABLE      *****
					*************************************
					
					qui su `pred' if `assign', d     // P-score support for treated
					local Tmin = r(min)
					local Tmax = r(max)
					
					qui su `pred' if !`assign', d    // P-score support for control
					local Cmin = r(min)
					local Cmax = r(max)					
					
					local csmin = max(`Cmin',`Tmin') // Common support interval
					local csmax = min(`Cmax',`Tmax')
					
					* Count control units in and out common support
					count if `pred' >= `csmin' & `pred' <= `csmax' & !`assign'
					local Cincs  = r(N)
					local Coutcs = `N_C' - `Cincs'
					
					* Count treated units in and out common support
					count if `pred' >= `csmin' & `pred' <= `csmax' & `assign'
					local Tincs = r(N)
					local Toutcs = `N_T' - `Tincs'
					
					noisily {
					matrix define CSup = J(2,4,.)
					matrix rownames CSup = Control Treatment
					matrix colnames CSup = "N" "Out of CS" "Lower Bound" "Upper Bound"
					matrix CSup[1,1] = `N_C'
					matrix CSup[1,2] = `Coutcs'
					matrix CSup[1,3] = `Cmin'
					matrix CSup[1,4] = `Cmax'
					matrix CSup[2,1] = `N_T'
					matrix CSup[2,2] = `Toutcs'
					matrix CSup[2,3] = `Tmin'
					matrix CSup[2,4] = `Tmax'
					
					
					local csmin_disp: di %6.4f `csmin'
					local csmax_disp: di %6.4f `csmax'
					
					di as text "{hline 80}"
					di as text "{bf:    			 Common Support       }"
					matrix list CSup, noblank noheader 
					di as text ""
					di as text "The common support is verified in the interval [`csmin_disp',`csmax_disp'],"
					di as text "which contains `Cincs' control units and `Tincs' treated units."
					di as text "{hline 80}"
					}
				}
				
				return scalar CSmin = `csmin'
				return scalar CSmax = `csmax'
					   
end
