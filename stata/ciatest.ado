*! Date        : 01 Dec 2023
*! Version     : 0.7
*! Authors     : Filippo Palomba
*! Email       : fpalomba@princeton.edu
*! Description : Test CIA to the left and to the right of the cutoff

program ciatest, eclass
version 14.0

	syntax varlist(ts fv) [if] [in], Outcome(varname) Score(varname) Bandwidth(string) [Cutoff(real 0) Poly(numlist max=2 integer) ROBust vce(varname) ///
						   site(varname) alpha(real 0.1) Details Noise]  	
	
	tempvar su1 su2 __X_1

	qui {
				cap drop __*

				marksample touse, novarlist       // marksample just for "if" and "in" conditions
				
				***************************
				****    PREPARATION    ****
				***************************
				
				** Parse polynomial degree
				if mi("`poly'") {         // Default polynomial degree
					local poly "1 1"
					}
				tokenize `poly'	
				local w : word count `poly'

				if `w' == 1 {
					local poly_r = `"`1'"'
					local poly_l = `"`1'"'
				}
				if `w' == 2 {
					local poly_l `"`1'"'
					local poly_r `"`2'"'
				}
				
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
				
				** Parse standard errors 		
				if !mi("`vce'") & !mi("`robust'"){      
					di as error "Choose one option between robust and vce!"
					exit
					}
				else if !mi("`robust'")	{
					local SEs "robust"
					}
				else if !mi("`vce'") {
					local SEs "vce(cluster `vce')"
					}
				else {
					local SEs
					}

					
				** Parse noisily
				if !mi("`noise'") {
					local loud = "noisily:"
					}
				
				
				** Standardize the X variable and translate bandwidth
				g __X_1 = `score' - `cutoff'
				local band_l = `band_l' - `cutoff'
				local band_r = `band_r' - `cutoff'

				
				** Generating higher order degrees of the X variable.
				local x_covs_l "__X_1"  				
				local x_covs_r "__X_1"  		

				forval degree = 2(1)`poly_l'{                  // Build polynomial to the left of the cutoff
					g __X_`degree' = __X_1^`degree'
					local x_covs_l "`x_covs_l' __X_`degree'"
					}
				forval degree = 2(1)`poly_r'{                  // Build polynomial to the right of the cutoff
					cap drop __X_`degree'                           
					g __X_`degree' = __X_1^`degree'
					local x_covs_r "`x_covs_r' __X_`degree'"
					}	

					
				**************************					
				****    ESTIMATION    ****
				**************************
				
				** Without Fixed Effects
				if mi("`site'") {
					`loud' reg `outcome' `x_covs_r' `varlist' if __X_1 >= 0 & __X_1 < `band_r' & `touse', `SEs'  // right

					foreach iter of numlist 1/`poly_r'{ 
						local b_r_`iter' = _b[__X_`iter']
						}
					`loud' test `x_covs_r'
					if `poly_r' == 1 {
						local test_r = sqrt(r(F))
						}
					else {
						local test_r = r(F)
					}
					local pv_r   = r(p)
					local N_r    = e(N)
					g `su1' = e(sample)  // Auxiliary variable to be eventually used in the optional part

					`loud' reg `outcome' `x_covs_l' `varlist' if __X_1 < 0 & __X_1 > `band_l' & `touse', `SEs'  // left
					foreach iter of numlist 1/`poly_l'{ 
						local b_l_`iter' = _b[__X_`iter']
						}					
					`loud' test `x_covs_l'
					if `poly_l' == 1 {
						local test_l = sqrt(r(F))
						}
					else {
						local test_l = r(F)
					}
					local pv_l   = r(p)
					local N_l    = e(N)	
					g `su2' = e(sample)
					}
					
				** With Fixed Effects
				if !mi("`site'") {
					`loud' areg `outcome' `x_covs_r' `varlist' if __X_1 >= 0 & __X_1 < `band_r' & `touse', a(`site') `SEs'  // right
					foreach iter of numlist 1/`poly_r'{ 
						local b_r_`iter' = _b[__X_`iter']
						}
					`loud' test `x_covs_r'
					if `poly_r' == 1 {
						local test_r = sqrt(r(F))
						}
					else {
						local test_r = r(F)
					}
					local pv_r   = r(p)
					local N_r    = e(N)
					g `su1' = e(sample)  // Auxiliary variable to be eventually used in the optional part
					
					`loud' areg `outcome' `x_covs_l' `varlist' if __X_1 < 0 & __X_1 > `band_l' & `touse', a(`site') `SEs'  // left
					foreach iter of numlist 1/`poly_l'{ 
						local b_l_`iter' = _b[__X_`iter']
						}
					`loud' test `x_covs_l'
					if `poly_l' == 1 {
						local test_l = sqrt(r(F))
						}
					else {
						local test_l = r(F)
					}
					local pv_l   = r(p)
					local N_l    = e(N)	
					g `su2' = e(sample)
					}

				** Storing test results
				
				if `pv_l' >= `alpha' {
					local cia_l = 1
					}
				else if `pv_l' < `alpha' {
					local cia_l = 0
					}
				
				if `pv_r' >= `alpha' {
					local cia_r = 1
					}
				else if `pv_r' < `alpha' {
					local cia_r = 0 
					}
				local maxpoly = max(`poly_l',`poly_r')
				local matrows = `maxpoly' + 3
				matrix define RESULTS = J(`matrows',2,.)
				foreach iter of numlist 1/`poly_l'{
					matrix RESULTS[`iter',1] = `b_l_`iter''
					}
				foreach iter of numlist 1/`poly_r'{
					matrix RESULTS[`iter',2] = `b_r_`iter''
					}
				matrix RESULTS[`maxpoly'+1,1]  = `test_l'
				matrix RESULTS[`maxpoly'+1,2]  = `test_r'
				matrix RESULTS[`maxpoly'+2,1]  = `pv_l'
				matrix RESULTS[`maxpoly'+2,2]  = `pv_r'
				matrix RESULTS[`maxpoly'+3,1]  = `N_l'
				matrix RESULTS[`maxpoly'+3,2]  = `N_r'

				if `poly_l' == 1 & `poly_r' == 1{
					local testname "t-stat"
				}
				else if `poly_l' == 1 & `poly_r' > 1 {
					local testname "t\F"
				}
				else if `poly_l' > 1 & `poly_r' == 1 {
					local testname "F\t"
				}	
				else {
					local testname "F-stat"
				}
				
				if `maxpoly' > 1 {
					global Coef ""
					foreach iter of numlist 1/`maxpoly'{
						global Coef "$Coef Coef_`iter'"
						}
					}
				else {
					global Coef "Coef"
					}
				matrix rownames RESULTS = $Coef `testname' p-value N
				matrix colnames RESULTS = LEFT RIGHT

				
				*** Check CIA holds in simple regression of Y on X (never displayed)
					
				if mi("`site'") {
					reg `outcome' `x_covs_r' if __X_1 >= 0 & __X_1 < `band_r' & `touse', `SEs'  // right
					foreach iter of numlist 1/`poly_r'{ 
						local b_origr_`iter' = _b[__X_`iter']
						}
					test `x_covs_r'
					if `poly_r' == 1 {
						local test_origr = sqrt(r(F))
						}
					else {
						local test_origr = r(F)
					}						
					local pv_origr   = r(p)
					local N_origr    = e(N)
					
					reg `outcome' `x_covs_l' if __X_1 < 0 & __X_1 > `band_l' & `touse', `SEs'  // left
					foreach iter of numlist 1/`poly_l'{ 
						local b_origl_`iter' = _b[__X_`iter']
						}
					test `x_covs_l'
					if `poly_l' == 1 {
						local test_origl = sqrt(r(F))
						}
					else {
						local test_origl = r(F)
					}	
					local pv_origl   = r(p)
					local N_origl    = e(N)					
					}
					
				if !mi("`site'") {
					areg `outcome' `x_covs_r' if __X_1 >= 0 & __X_1 < `band_r' & `touse', a(`site') `SEs'  // right
					foreach iter of numlist 1/`poly_r'{ 
						local b_origr_`iter' = _b[__X_`iter']
						}
					test `x_covs_r'
					if `poly_r' == 1 {
						local test_origr = sqrt(r(F))
						}
					else {
						local test_origr = r(F)
					}	
					local pv_origr   = r(p)
					local N_origr    = e(N)
				
					areg `outcome' `x_covs_l' if __X_1 < 0 & __X_1 > `band_l' & `touse', a(`site') `SEs'  // left
					foreach iter of numlist 1/`poly_l'{ 
						local b_origl_`iter' = _b[__X_`iter']
						}
					test `x_covs_l'
					if `poly_l' == 1 {
						local test_origl = sqrt(r(F))
						}
					else {
						local test_origl = r(F)
					}	
					local pv_origl   = r(p)
					local N_origl    = e(N)					
					}
					
					local cia_already = 0
					if `pv_origl' >= `alpha' & `pv_origr' >= `alpha' {
						local cia_already = 1
						local alphaperc = `alpha'*100
						}
								
					
				*****************************				
				****    OPTIONAL PART    ****
				*****************************
				
				if !mi("`details'") {  
					
					** Simple regression of Y on X (full sample)
					
					if mi("`site'") {
						`loud' reg `outcome' `x_covs_r' if __X_1 >= 0 & __X_1 < `band_r' & `touse', `SEs'  // right
						foreach iter of numlist 1/`poly_r'{ 
							local b_origr_`iter' = _b[__X_`iter']
							}
						`loud' test `x_covs_r'
						if `poly_r' == 1 {
							local test_origr = sqrt(r(F))
							}
						else {
							local test_origr = r(F)
						}						
						local pv_origr   = r(p)
						local N_origr    = e(N)
						
						`loud' reg `outcome' `x_covs_l' if __X_1 < 0 & __X_1 > `band_l' & `touse', `SEs'  // left
						foreach iter of numlist 1/`poly_l'{ 
							local b_origl_`iter' = _b[__X_`iter']
							}
						`loud' test `x_covs_l'
						if `poly_l' == 1 {
							local test_origl = sqrt(r(F))
							}
						else {
							local test_origl = r(F)
						}	
						local pv_origl   = r(p)
						local N_origl    = e(N)					
						}
						
					if !mi("`site'") {
						`loud' areg `outcome' `x_covs_r' if __X_1 >= 0 & __X_1 < `band_r' & `touse', a(`site') `SEs'  // right
						foreach iter of numlist 1/`poly_r'{ 
							local b_origr_`iter' = _b[__X_`iter']
							}
						`loud' test `x_covs_r'
						if `poly_r' == 1 {
							local test_origr = sqrt(r(F))
							}
						else {
							local test_origr = r(F)
						}	
						local pv_origr   = r(p)
						local N_origr    = e(N)
					
						`loud' areg `outcome' `x_covs_l' if __X_1 < 0 & __X_1 > `band_l' & `touse', a(`site') `SEs'  // left
						foreach iter of numlist 1/`poly_l'{ 
							local b_origl_`iter' = _b[__X_`iter']
							}
						`loud' test `x_covs_l'
						if `poly_l' == 1 {
							local test_origl = sqrt(r(F))
							}
						else {
							local test_origl = r(F)
						}	
						local pv_origl   = r(p)
						local N_origl    = e(N)					
						}
												
						matrix define DETAILS1 = J(`matrows',2,.)
						foreach iter of numlist 1/`poly_l'{
							matrix DETAILS1[`iter',1] = `b_origl_`iter''
							}
						foreach iter of numlist 1/`poly_r'{
							matrix DETAILS1[`iter',2] = `b_origr_`iter''
							}
						matrix DETAILS1[`maxpoly'+1,1]  = `test_origl'
						matrix DETAILS1[`maxpoly'+1,2]  = `test_origr'
						matrix DETAILS1[`maxpoly'+2,1]  = `pv_origl'
						matrix DETAILS1[`maxpoly'+2,2]  = `pv_origr'
						matrix DETAILS1[`maxpoly'+3,1]  = `N_origl'
						matrix DETAILS1[`maxpoly'+3,2]  = `N_origr'
						
						matrix rownames DETAILS1 = $Coef `testname' p-value N
						matrix colnames DETAILS1 = LEFT RIGHT
					
					
					** Simple regression of Y on X (restricted sample)
					
					if mi("`site'") {
						`loud' reg `outcome' `x_covs_r' if __X_1 >= 0 & __X_1 < `band_r' & `su1', `SEs'  // right
						foreach iter of numlist 1/`poly_r'{ 
							local b_origr_`iter' = _b[__X_`iter']
							}
						`loud' test `x_covs_r'
						if `poly_r' == 1 {
							local test_origr = sqrt(r(F))
							}
						else {
							local test_origr = r(F)
						}	
						local pv_origr   = r(p)
						local N_origr    = e(N)
						
						`loud' reg `outcome' `x_covs_l' if __X_1 < 0 & __X_1 > `band_l' & `su2', `SEs'  // left
						foreach iter of numlist 1/`poly_l'{ 
							local b_origl_`iter' = _b[__X_`iter']
							}
						`loud' test `x_covs_l'
						if `poly_l' == 1 {
							local test_origl = sqrt(r(F))
							}
						else {
							local test_origl = r(F)
						}	
						local pv_origl   = r(p)
						local N_origl    = e(N)					
						}	
						
					if !mi("`site'") {
						`loud' areg `outcome' `x_covs_r' if __X_1 >= 0 & __X_1 < `band_r' & `su1', a(`site') `SEs'  // right
						foreach iter of numlist 1/`poly_r'{ 
							local b_origr_`iter' = _b[__X_`iter']
							}
						`loud' test `x_covs_r'
						if `poly_r' == 1 {
							local test_origr = sqrt(r(F))
							}
						else {
							local test_origr = r(F)
						}	
						local pv_origr   = r(p)
						local N_origr    = e(N)
					
						`loud' areg `outcome' `x_covs_l' if __X_1 < 0 & __X_1 > `band_l' & `su2', a(`site') `SEs'  // left
						foreach iter of numlist 1/`poly_l'{ 
							local b_origl_`iter' = _b[__X_`iter']
							}
						`loud' test `x_covs_l'
						if `poly_l' == 1 {
							local test_origl = sqrt(r(F))
							}
						else {
							local test_origl = r(F)
						}	
						local pv_origl   = r(p)
						local N_origl    = e(N)					
						}
					
						matrix define DETAILS2 = J(`matrows',2,.)
						foreach iter of numlist 1/`poly_l'{
							matrix DETAILS2[`iter',1] = `b_origl_`iter''
							}
						foreach iter of numlist 1/`poly_r'{
							matrix DETAILS2[`iter',2] = `b_origr_`iter''
							}
						matrix DETAILS2[`maxpoly'+1,1]  = `test_origl'
						matrix DETAILS2[`maxpoly'+1,2]  = `test_origr'
						matrix DETAILS2[`maxpoly'+2,1]  = `pv_origl'
						matrix DETAILS2[`maxpoly'+2,2]  = `pv_origr'
						matrix DETAILS2[`maxpoly'+3,1]  = `N_origl'
						matrix DETAILS2[`maxpoly'+3,2]  = `N_origr'
						
						matrix rownames DETAILS2 = $Coef `testname' p-value N
						matrix colnames DETAILS2 = LEFT RIGHT
					
					local missingv = 0
					
					if `pv_origl' > `alpha' {
						local missingv = 1
						}				
					if `pv_origr' > `alpha' {
						local missingv = `missingv' + 1
						}					
				}
				
				}
				
				**************************				
				**** PRINTING RESULTS ****
				**************************
				
				di as text "{hline 80}"
				if `cia_already' == 1 {
					display as text "{bf:Notice that the CIA condition is already satisfied without covariates!}"
					display as text "{bf:You can treat the RDD as a random experiment within the actual bandwidth}"
					display as text "{bf:at a `alphaperc'% confidence level.}"
					di as text ""
					}
				
					
				di as text "{bf:             CIA Test Results }"

				matrix list RESULTS, noblank noheader 
				
				local alrdisp = 0     // auxiliary local to avoid printing redundant test results
				if  `cia_r' == 0 & `cia_l' == 0 {
					display as text "{bf:CIA condition not satisfied on both sides!}"
					local ++alrdisp
					}
				if  `cia_r' == 0 & `alrdisp' == 0{
					display as text "{bf:CIA condition not satisfied to the right of the cutoff!}"
					}
				if  `cia_l' == 0 & `alrdisp' == 0{
					display as text "{bf:CIA condition not satisfied to the left of the cutoff!}"
					}
				if  `cia_l' == 1 & `cia_r' == 1 {
					display as text "{bf:CIA condition satisfied! (alpha = `alpha')}"
					}			
					
				if !mi("`details'") {
				
					di as text "{hline 80}"
					di as text "{bf:   Original Regression - Full Sample}"
					matrix list DETAILS1, noblank noheader
					di as text ""
					di as text "Simple Regression of the Outcome Variable on the Running Variable."
					di as text ""
					di as text "{bf: Original Regression - Restricted Sample}"
					matrix list DETAILS2, noblank noheader
					di as text ""
					di as text "Simple Regression of the Outcome Variable on the Running Variable"
					di as text "on the same observations as the CIA regression."
					di as text ""
					if `missingv' == 2 & `cia_r' == 1 & `cia_l' == 1{
						di as text "{bf:It seems that the CIA holds just because of missing values}"
						di as text "{bf:in the additional covariates.}"
					}
					di as text ""
					di as text "{bf: This additional check is useful to understand whether the running}"
					di as text "{bf: variable has become ignorable thanks to the added covariates or}"
					di as text "{bf: just because of sample selection. It may be helpful when the sample}"
					di as text "{bf: contains missing values for the additional covariates.}"
					}
				
				
				** Clean leftovers
				drop __X_*
				
				di as text "{hline 80}"
					
			** Storage of results
						
			if !mi("`details'") {
				ereturn matrix cia_test3 = DETAILS2	
				ereturn matrix cia_test2 = DETAILS1		
				}
				
			ereturn matrix cia_test = RESULTS
			ereturn scalar CIAalready = `cia_already'
end
