*! Date        : 06 May 2023
*! Version     : 0.6
*! Authors     : Filippo Palomba
*! Email       : fpalomba@princeton.edu
*! Description : Algorithm for data-driven covariate selection to validate CIA condition


program define ciasearch, eclass

version 14.0
	
syntax varlist(min = 1  ts fv) [if] [in], Outcome(varname) Score(varname) Bandwidth(string) [Cutoff(real 0) included(varlist fv) Poly(numlist max=2 integer) ///
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

if e(CIAalready) == 1{
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
		matrix _T = e(cia_test)
		local pvalpos = rownumb(_T,"p-value")
		local pv_l = _T[`pvalpos',1]      // Store p-value on the left
		local pv_r = _T[`pvalpos',2]      // Store p-value on the right
		matrix drop _T
			
		local loss_fun_max = min(`pv_l',`pv_r')   
		
		if (`pv_r' >= `alpha') & (`pv_l' >= `alpha'){
			disp as text "{bf: CIA condition already satisfied on both sides of the cutoff with the included covariates!}"
			ereturn local selected_covs `included'
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
				qui ciatest `included' `covar' `selected_covs' `if' `in', outcome(`outcome') score(`score') bandwidth(`bandwidth') ///
							cutoff(`cutoff') poly(`poly') `SEs' `fixedeff' 
				matrix _T = e(cia_test)
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
		matrix _T = e(cia_test)
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
				matrix _T = e(cia_test)
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
				matrix _T = e(cia_test)
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


ereturn local selected_covs_r `selected_covs_r'    // Local containing covariates satisfying the CIA on the right
ereturn local selected_covs_l `selected_covs_l'    // Local containing covariates satisfying the CIA on the left
ereturn local CIAright `CIAright'				  // Flag equal to 1 if CIA holds on the right 
ereturn local CIAleft `CIAleft'                    // Flag equal to 1 if CIA holds on the left 


**** Clean Leftovers

foreach cov of local interactions {
	drop `cov'
	}
foreach cov of local quadterms {
	drop `cov'
	}

	
end	
