*! Date        : 17 Jan 2022
*! Version     : 0.5
*! Authors     : Filippo Palomba
*! Email       : fpalomba@princeton.edu
*! Description : Algorithm for data-driven covariate selection to validate CIA condition

/*
FUTURE release should include:
- Algorithm on all possible combinations
- Alternative algorithm less myopic

*/


/* 
START HELP FILE

title[Data-driven algorithm that selects covariates satisfying the CIA in a Regression Discontinuity framework.]

desc[
{cmd:ciasearch} is an algorithm that searches for a set of covariates that validates the CIA among the candidate ones (i.e. those indicated in {it:varlist}).
The algorithm relies on the testing procedure developed by Angrist and Rokkanen (2015) in a Regression Discontinuity framework and implemented by the 
command {help ciatest}.

The algorithm adds one covariate in {it:varlist} at a time and runs {help ciatest}. Then, the covariate that minimizes a loss function based on the 
test of the null hypothesis that the CIA holds is selected. By default the command runs the algorithm separately to the left and to the right of the 
cutoff. If the option {cmd:unique} is specified then a single set of covariates satisfying the CIA on both sides is selected.

The covariates indicated in {it:included} are always included in the testing regression.

]

opt[outcome specifies the dependent variable of interest.]
opt[score specifies the running variable.]
opt[bandwidth specifies the bandwidth to be used for estimation. The user can specify a different bandwidth for each side.]
opt[included specifies the covariates that are always included in the testing regression.]
opt[cutoff specifies the RD cutoff for the running variable.  Default is {cmd:c(0)}. The cutoff value is subtracted from the {it:score} variable and the bandwidth. In case multiple cutoffs are present, provide the pooled cutoff.]
opt[poly specifies the degree of the polynomial in the running variable. The user can specify a different degree for each side. Default is {cmd:p(1 1)}.]
opt[robust estimates heteroskedasticity-robust standard errors.]
opt[vce clusters standard errors at the specified level.]
opt[site specifies the variable identifying the site to add site fixed effects.]
opt[alpha specifies the level of I-type error in the CIA test. Default is {cmd:alpha(0.1)}.]
opt[quad adds to {it:varlist} squared terms of each (non-dichotomic) covariate in {it:varlist} and interactions of all the covariates in {it:varlist}.]
opt[unique runs a unique algorithm on both sides. This version selects a set of covariates that satisfies the CIA condition on both sides of the
	cutoff at the same time.]
opt[force with this option switched on, the algorithm forgets the value of the loss function at the iteration j-1 and selects
	the covariate providing the lower value of the loss function at iteration j. In
	other words, with this option switched on, the algorithm searches for the covariate that
	minimizes the loss function within a certain iteration. This can make the loss function
	non-strictly decreasing in the number of iterations, but allows the algorithm to select
	covariates that provide a sensible gain only after some steps.]
opt[noprint suppresses within-iteration results.]

return[selected_covs is the list of selected covariates (without those in {it:included}).]
return[selected_covs_l is the list of selected covariates to the left of the cutoff.]
return[selected_covs_r is the list of selected covariates to the right of the cutoff.]

example[

The examples below show how to correctly use the command {cmd:ciatest} to check whether the CIA holds or not. Suppose that we have at hand an
{it:outcome} variable, a {it:score} variable, and a set of K covariates ({it:varlist}). We would like to know whether a subset of {it:varlist} 
makes {it:score} ignorable, i.e. makes CIA hold. To do so, it is enough to run (for the sake of the example assume the bandwidth to be 10 and 
the cutoff to be 0)

{cmd:ciasearch cov1 cov2 ... covK, o(outcome) s(score) b(10)}

If we suspect that there is either heteroskedasticity or intra-cluster correlation in the residuals, then

{cmd:ciasearch cov1 cov2 ... covK, o(outcome) s(score) b(10) robust}

{cmd:ciasearch cov1 cov2 ... covK, o(outcome) s(score) b(10) vce(clustervar)}

If, in addition, we are pooling together different rankings, then we should add fixed effects at the ranking level (see Ichino and Rettore (forthcoming))

{cmd:ciasearch cov1 cov2 ... covK, o(outcome) s(score) b(10) vce(clustervar) site(ranking)}

If we want to add to the list also second-order covariates

{cmd:ciasearch cov1 cov2 ... covK, o(outcome) s(score) b(10) vce(clustervar) site(ranking) quad}

If we want some covariates to be always included

{cmd:ciasearch cov1 cov2 ... covK, o(outcome) s(score) b(10) vce(clustervar) site(ranking) quad included(covI1 ... covIK)}

]

author[Filippo Palomba]
institute[Department of Economics, Princeton University]
email[fpalomba@princeton.edu]

seealso[

{pstd}
Other Related Commands (ssc repository not working yet): {p_end}

{synoptset 27 }{...}

{synopt:{help ciatest} (if installed)} {stata ssc install ciatest}   (to install) {p_end}
{synopt:{help ciares} (if installed)}   {stata ssc install ciares} (to install) {p_end}
{synopt:{help ciacs} (if installed)}   {stata ssc install ciacs}     (to install) {p_end}
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

program define ciasearch, rclass

version 14.0
	
syntax varlist(min = 1) [if] [in], Outcome(varname) Score(varname) Bandwidth(string) [Cutoff(real 0) included(varlist fv) Poly(numlist max=2 integer) ///
									 ROBust vce(varname) site(varname) alpha(real 0.1) quad unique force NOPrint]	

******************************************									 
*** --- Check ciatest is installed
capture:  which ciatest
if _rc != 0 {
	disp as error "command {bf:ciatest} not found as either built-in or ado-file!"
	error 111
}								
	
	
	
******************************************									 
*** --- Prepare locals to call "ciatest" program

*** Set of candidates
local candidates `varlist'


*** Type of standard errors
if !mi("`vce'") & !mi("`robust'"){      
	di as error "Choose one option between robust and vce!"
	exit
	}
else if !mi("`robust'")	{
	local SEs "robust"
	}
else if !mi("`vce'") {
	local SEs "vce(`vce')"
	}
else {
	local SEs
	}

	
*** Fixed effects
if !mi("`site'"){
	local fixedeff "site(`site')"
	}
else {
    local fixedeff
	}
	
	
*** Significance level 
if !mi("`alpha'"){
	local significance "alpha(`alpha')"
	}
else {
    local significance
	}	

	
*** Critical value
local critval = `alpha'	


*** Eventually suppress algorithm iterations
local suppress ""
if !mi("`noprint'"){
	local suppress "quietly"
	}
	
	
	

******************************************									 
******************************************


*** Check if the CIA holds without covariates
disp as text "{hline 90}"
disp as text "Algorithm Path:"

di as text""
qui ciatest `varlist' `if' `in', outcome(`outcome') score(`score') bandwidth(`bandwidth') cutoff(`cutoff') poly(`poly') `SEs' `fixedeff' `significance' 

if r(CIAalready) == 1{
	local alphaperc = `alpha'*100
	display as text "{bf:Notice that the CIA condition is already satisfied without covariates!}"
	display as text "{bf:You can treat the RDD as a random experiment within the actual bandwidth}"
	display as text "{bf:of `bandwidth' at a `alphaperc'% confidence level.}"	
	exit
}



								   
** -------------------------------------------------------------------------- **
** -------------------------------------------------------------------------- **

***** First Algorithm - Same set of covariates on both sides

** -------------------------------------------------------------------------- **
** -------------------------------------------------------------------------- **
	
if !mi("`unique'"){	

	**** --- Parse list of always included covariates and check CIA already holds with these covariates


	if !mi("`included'"){
		disp as text "Checking that CIA is not already verified with always included covariates..."
		
		ciatest `included' `if' `in', outcome(`outcome') score(`score') bandwidth(`bandwidth') cutoff(`cutoff') poly(`poly') `SEs' `fixedeff' `significance' 
		matrix _T = r(cia_test)
		local pvalpos = rownumb(_T,"p-value")
		local pv_l = _T[`pvalpos',1]      // Store p-value on the left
		local pv_r = _T[`pvalpos',2]      // Store p-value on the right
		matrix drop _T
			
		local loss_fun_max = min(`pv_l',`pv_r')   

		if (`pv_r' >= `alpha') & (`pv_l' >= `alpha'){
			disp as text "{bf: CIA condition already satisfied on both sides of the cutoff with the included covariates!}"
			return local selected_covs `included'
			exit
			}
		else {
			disp as text "{bf: CIA condition is not satisfied on both sides of the cutoff with the included covariates!}"		
		}
	}
	else {
		local loss_fun_max = -2   // Initial value for the loss function if no included covariates
	}




	** -------------------------------------------------------------------------- **

	**** --- Algorithm


	disp as text "{bf: Searching for a unique set of covariates validating the CIA on both sides...}"

	*** Create quadratic terms and interactions
	if !mi("`quad'"){
		
		* Interaction Terms
		local interactions
		local num_cov : word count `varlist'
		forval i = 1/`num_cov' {
				forval j = 1/`=`i'-1' {
						local x : word `i' of `candidates'
						local y : word `j' of `candidates'
						cap drop `x'X`y'					
						g `x'X`y' = `x'*`y'
						local interactions `interactions' `x'X`y'
				}
		}
		

		* Quadratic Terms
		
		* Identify dummy variables
		foreach v of local candidates {
			capture assert missing(`v') | inlist(`v', 0, 1)
			if _rc != 0 local nondummy `nondummy' `v'
		}

			
		local quadterms
		foreach covar of local nondummy {
			if (substr("`covar'",1,2) != "i."){   // Exclude categorical covariates 
				cap drop `covar'_sq
				qui g `covar'_sq = `covar'^2
				local quadterms "`quadterms' `covar'_sq"
			}
		}
		local candidates `candidates' `quadterms'
		local candidates `candidates' `interactions'
	}   
		

	local selected_covs ""

	local iter = 1
	while `loss_fun_max' < `critval' {          

			if !mi("`force'") {  				// With the option "force" on the algorithm forgets the last maximum value of the loss function
				local loss_fun_max = -2   
			}
			
			local temp_maximiser ""           
			local firstcov = 1                  // Auxiliary local to print output
			
			* Test the CIA over the set of candidate variables
			foreach covar of local candidates{   
				qui ciatest `included' `covar' `selected_covs' `if' `in', outcome(`outcome') score(`score') bandwidth(`bandwidth') cutoff(`cutoff') poly(`poly') `SEs' `fixedeff' noise
				matrix _T = r(cia_test)
				local pvalpos = rownumb(_T,"p-value")
				local pv_l = _T[`pvalpos',1]      // Store p-value on the left
				local pv_r = _T[`pvalpos',2]      // Store p-value on the right
				matrix drop _T

				local actual_loss_fun = min(`pv_l',`pv_r')
				
				if `actual_loss_fun' > `loss_fun_max' {       // Update distance with new local maximum and store name of candidate maximiser
					local loss_fun_max = `actual_loss_fun'
					local temp_maximiser "`covar'"
				}
				if `firstcov' == 1 {
					`suppress' di "Loss Function Value    Covariate"
					local firstcov = 0
				}
				
				local loss_disp : di %8.7f `actual_loss_fun'
				`suppress' di "`loss_disp'              `covar' "
					
			}
					
			if "`temp_maximiser'" == "" {     // In this case no minimiser has been found, so the algorithm stops (with the force option switched on this never happens
				di as text "{bf: Algorithm not converged}"
				continue, break
				}
			else {                           // In this case a minimiser has been found and has to be taken out to the list of candidates ...
				disp as text "Iteration #`iter' finished || Loss Function (>`critval') `loss_fun_max' || Selected `temp_maximiser' "
				local candidates: list candidates - temp_maximiser
				local selected_covs `selected_covs' `temp_maximiser'   // ... and added to the list of selected covariates in the next iteration
			}
			
	local iter = `iter' + 1		
	}
}


** -------------------------------------------------------------------------- **
** -------------------------------------------------------------------------- **

***** Second Algorithm - Different sets of covariates on each side

** -------------------------------------------------------------------------- **
** -------------------------------------------------------------------------- **


if mi("`unique'"){

	local selected_covs_l ""
	local selected_covs_r ""


	** -------------------------------------------------------------------------- **

	**** --- Eventually check CIA already holds with included covariates

	** -------------------------------------------------------------------------- **
	local already_l = 0
	local already_r = 0
	if !mi("`included'"){
		disp as text "Checking that CIA is not already verified with included covariates..."
		
		qui ciatest `included' `if' `in', outcome(`outcome') score(`score') bandwidth(`bandwidth') cutoff(`cutoff') poly(`poly') ///
										   `SEs' `fixedeff' `significance' 									   
		matrix _T = r(cia_test)
		local pvalpos = rownumb(_T,"p-value")
		local loss_fun_max_l = _T[`pvalpos',1]      // Store p-value on the left
		local loss_fun_max_r = _T[`pvalpos',2]      // Store p-value on the right
		matrix drop _T
			
		if (`loss_fun_max_l' >= `alpha'){
			disp as text "{bf: CIA condition already satisfied on the left side of the cutoff with the included covariates!}"		
			local already_l = 1
			local selected_covs_l `included'
			}
		else {
			disp as text "{bf: CIA condition is not satisfied on the left side of the cutoff with the included covariates!}"		
		}
		
		if (`loss_fun_max_r' >= `alpha'){
			disp as text "{bf: CIA condition already satisfied on the right side of the cutoff with the included covariates!}"
			local already_r = 1
			local selected_covs_r `included'
			}
		else {
			disp as text "{bf: CIA condition is not satisfied on the right side of the cutoff with the included covariates!}"		
		}	
	}
	else {
		local loss_fun_max_l = -2   // Initial fictitious distance if no included covariates
		local loss_fun_max_r = -2   // Initial fictitious distance if no included covariates 
	}
			


	** -------------------------------------------------------------------------- **

	**** --- Algorithm on the left of the cutoff

	** -------------------------------------------------------------------------- **


	/* The default algorithm tries to maximise the p-value of the coefficient relative
	   to the running variable. At each iteration the actual local maximum is stored
	   and the algorithm stops whenever: (i) a whole iteration ends without having found
	   a new local maximum; (ii) a new local maximum is found and it satisfies the 
	   stopping criterion (i.e. I-type error level); (iii) there are no more candidate
	   covariates in varlist.
	   
	   The alternative algorithm, called through the option "force", just looks at the 
	   maximum within each iteration, so it does not care about the value of the loss 
	   function coming from previous iterations. Notice that this algorithm stops 
	   only when: (i) a new local maximum is found and it satisfies the stopping criterion 
	   (i.e. I-type error level); (ii) there are no more candidate covariates in varlist.

	*/

	*** Create quadratic terms and interactions (only if CIA is not already satisfied on both sides)
	if !mi("`quad'") & (`already_l' != 1 | `already_r' != 1) {
		
		* Interaction Terms
		local interactions
		local num_cov : word count `varlist'
		forval i = 1/`num_cov' {
				forval j = 1/`=`i'-1' {
						local x : word `i' of `candidates'
						local y : word `j' of `candidates'
						cap drop `x'X`y'					
						g `x'X`y' = `x'*`y'
						local interactions `interactions' `x'X`y'
				}
		}
		

		* Quadratic Terms
		
		* Identify dummy variables
		foreach v of local candidates {
			capture assert missing(`v') | inlist(`v', 0, 1)
			if _rc != 0 local nondummy `nondummy' `v'
		}

		
		
		local quadterms
		foreach covar of local nondummy {
			if (substr("`covar'",1,2) != "i."){   // Exclude categorical covariates 
				cap drop `covar'_sq
				qui g `covar'_sq = `covar'^2
				local quadterms "`quadterms' `covar'_sq"
			}
		}
		local candidates `candidates' `quadterms'
		local candidates `candidates' `interactions'
	}   
		
	local candidates_l `candidates'
	local candidates_r `candidates'



	if `already_l' == 0{

	disp as text "{bf: Searching for a set of covariates validating the CIA on the left of the cutoff ...}"

	local iter = 1

	while `loss_fun_max_l' < `critval' {          // The threshold is the sum of the critical t-stats on the left and on the right

			 
			if !mi("`force'") {  // With the option "force" on the algorithm forgets the last maximum
				local loss_fun_max_l = -2   
			}
			
			local temp_maximiser ""
			local firstcov = 1
			* Test the CIA over the set of candidate variables
			foreach covar of local candidates_l{   

				qui ciatest `included' `covar' `selected_covs_l' `if' `in', outcome(`outcome') score(`score') bandwidth(`bandwidth') ///
																	cutoff(`cutoff') poly(`poly') `SEs' `fixedeff' 	
				matrix _T = r(cia_test)
				local pvalpos = rownumb(_T,"p-value")
				local actual_loss_fun_l = _T[`pvalpos',1]      // Store p-value on the left
				matrix drop _T

				if `actual_loss_fun_l' > `loss_fun_max_l' {   // Update distance with new local minimum and store name of candidate minimiser
					local loss_fun_max_l = `actual_loss_fun_l'
					local temp_maximiser "`covar'"
				}	
				

				if `firstcov' == 1 {
					`suppress' di "Loss Function Value    Covariate"
					local firstcov = 0
				}
				local loss_disp : di %8.7f `actual_loss_fun_l'
				`suppress' di "`loss_disp'              `covar' "
			}
			
			
			if "`temp_maximiser'" == "" {     // In this case no maximiser has been found, so the algorithm stops
				disp as text as text "{bf: Algorithm not converged}"
				continue, break
				}
			else {                           // In this case a maximiser has been found and has to be taken out of the list of candidates ...
				disp as text "Iteration #`iter' finished || Loss Function (>`critval') `loss_fun_max_l' || Selected `temp_maximiser' "
				local candidates_l: list candidates_l - temp_maximiser
				local selected_covs_l `selected_covs_l' `temp_maximiser'   // ... and added to the list of selected covariates in the next iteration
			}
		local iter = `iter' + 1	
	}
	}

	** -------------------------------------------------------------------------- **

	**** --- Algorithm on the right of the cutoff

	** -------------------------------------------------------------------------- **
	if `already_r' == 0{
	disp as text ""
	disp as text "{bf: Searching for a set of covariates validating the CIA on the right of the cutoff ...}"

	local iter = 1
	while `loss_fun_max_r' < `critval' {          

			if !mi("`force'") {  // With the option "force" on the algorithm forgets the last maximum
				local loss_fun_max_r = -2   
			}
			
			local temp_maximiser ""   
			local firstcov = 1
			* Test the CIA over the set of candidate variables
			foreach covar of local candidates_r{   
				qui ciatest `included' `covar' `selected_covs_r' `if' `in', outcome(`outcome') score(`score') bandwidth(`bandwidth') cutoff(`cutoff') poly(`poly') `SEs' `fixedeff' 																	   
				matrix _T = r(cia_test)
				local pvalpos = rownumb(_T,"p-value")
				local actual_loss_fun_r = _T[`pvalpos',2]         // Store p-value on the right
				matrix drop _T
				
				if `actual_loss_fun_r' > `loss_fun_max_r' {       // Update distance with new local maximum and store name of candidate maximiser
					local loss_fun_max_r = `actual_loss_fun_r'
					local temp_maximiser "`covar'"
				}
				if `firstcov' == 1 {
					`suppress' di "Loss Function Value    Covariate"
					local firstcov = 0
				}
				
				local loss_disp : di %8.7f `actual_loss_fun_r'
				`suppress' di "`loss_disp'              `covar' "
				
			}
					
			if "`temp_maximiser'" == "" {     // In this case no maximiser has been found, so the algorithm stops
				di as text "{bf: Algorithm not converged}"
				continue, break
				}
			else {                            // In this case a minimiser has been found and has to be taken out of the list of candidates ...
				disp as text "Iteration #`iter' finished || Loss Function (>`critval') `loss_fun_max_r' || Selected `temp_maximiser' "
				local candidates_r: list candidates_r - temp_maximiser
				local selected_covs_r `selected_covs_r' `temp_maximiser'   // ... and added to the list of selected covariates in the next iteration
			}
			local iter = `iter' + 1
			
	}
}

}

*** Create flags and print final results


disp as text "{hline 90}"
disp as text " "
disp as text "{bf:Results}"


if !mi("`unique'"){
	
	if `loss_fun_max' > `critval' {
		local CIAleft = 1
		local CIAright = 1
		local selected_covs_r `selected_covs'
		local selected_covs_l `selected_covs'
		}
	else {
		local CIAleft = 0
		local CIAright = 0
		local selected_covs_r ""
		local selected_covs_l ""
		}
	
	}
else {

	** Left
	if `loss_fun_max_l' > `critval' {
		local CIAleft = 1
		}
	else {
		local CIAleft = 0
		local selected_covs_l ""
		}

	** Right
	if `loss_fun_max_r' > `critval' {
		local CIAright = 1
		}
	else {
		local CIAright = 0
		local selected_covs_r ""
		}

	}



if `CIAleft' == 1 {	
	disp as text "Algorithm Converged - Selected Covariates on the Left: `selected_covs_l'"
}
else {
	disp as text "Algorithm not converged on the Left - No Selected Covariates"
	}	
if `CIAright' == 1 {	
	disp as text "Algorithm Converged - Selected Covariates on the Right: `selected_covs_r'"
	 }
else {
	disp as text "Algorithm not converged on the Right - No Selected Covariates"
	}


return local selected_covs_r `selected_covs_r'    // Local containing covariates satisfying the CIA on the right
return local selected_covs_l `selected_covs_l'    // Local containing covariates satisfying the CIA on the left
return local CIAright `CIAright'				  // Flag equal to 1 if CIA holds on the right 
return local CIAleft `CIAleft'                    // Flag equal to 1 if CIA holds on the left 


**** Clean Leftovers

foreach cov of local interactions {
	drop `cov'
	}
foreach cov of local quadterms {
	drop `cov'
	}

	
end	
