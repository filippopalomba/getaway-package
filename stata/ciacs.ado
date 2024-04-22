*! Date        : 22 Apr 2024
*! Version     : 0.8
*! Authors     : Filippo Palomba
*! Email       : fpalomba@princeton.edu
*! Description : Graphical visualization of the common support condition in RDD

program ciacs, eclass         
version 14.0           
		
		syntax varlist(ts fv) [if] [in], Outcome(varname) Assign(varname) Score(varname) Bandwidth(string) [Cutoff(real 0) NBins(integer 10)  ///
				site(varname) asis gphoptions(string) pscore(string) probit KDensity NOGraph ///
				barTopt(string) barCopt(string) lineTopt(string) lineCopt(string) legendopt(string)]
			  
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

					if mi("`legendopt'") {
						local legendopt `" label(1 "Treated") label(2 "Control") size(small) "'
					}

					if (mi("`lineTopt'")) {
						local lineTopt `"lp(solid)"'
					}
					if (mi("`lineCopt'")) {
						local lineCopt `"lp(solid)"'
					}

					** Plot common support histograms
					graph twoway (bar `temp_y1' `temp_x' if `temp_i' == 1, `barTopt') (bar `temp_y0' `temp_x' if `temp_i' == 1, `barCopt'),  ///
						xtitle("Propensity Score") ytitle("Frequency") legend(`legendopt') 				   ///
						xlabel(0 "0" `tk1' "0.2" `tk2' "0.4" `tk3' "0.6" `tk4' "0.8" `nbins' "1") ylabel("", nogrid)   	         				   ///
						title("Common Support") note("T:`N_T', C:`N_C'") `gphoptions'
					}				
					
					if !mi("`kdensity'") & mi("`nograph'") {
					
						** Plot kdensities
						graph twoway (kdensity `pred' if `assign', `lineTopt') (kdensity `pred' if !`assign', `lineCopt'),    ///
							xtitle("Propensity Score") ytitle("Density") legend(`legendopt')   				  ///
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
				
				ereturn scalar CSmin = `csmin'
				ereturn scalar CSmax = `csmax'
					   
end
