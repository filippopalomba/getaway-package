*! Date        : 17 Jan 2022
*! Version     : 0.5
*! Authors     : Filippo Palomba
*! Email       : fpalomba@princeton.edu
*! Description : Graphical visualization of the conditional independence assumption


program ciares
version 14.0
		
		syntax varlist(ts fv) [if] [in], Outcome(varname) Score(varname) Bandwidth(string) [Cutoff(real 0) NBins(numlist) site(varname) ///
		gphoptions(string) cmpr(numlist max=2 integer)]      
 						
				tempvar resl resr resl_cmp resr_cmp res res_cmp cut_x cut_xR cond_y toplot assign running intrc

				qui{

				marksample touse, novarlist       // marksample just for "if" and "in" conditions

				
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
				
				
				preserve
				
				g `running' = `score' - `cutoff'    // Standardizing running variable
				local band_l = `band_l' - `cutoff'
				local band_r = `band_r' - `cutoff'
				g `assign' = `running' >= 0         // Creating RDD dummy
											
				
				keep if `running' < `band_r' & `running' > `band_l' & `touse'
				
				** Estimate testing regression and retrieve residuals 
				if mi("`site'") {	   			
					reg `outcome' `varlist' if `running' >= 0 & `running' < `band_r' 			      // right
					predict `resl' if `running' >= 0 & e(sample), r
					reg `outcome' `varlist' if `running' < 0 & `running' > `band_l'                   // left
					predict `resr' if `running' < 0 & e(sample), r				
					}
					 
				if !mi("`site'") {
					areg `outcome' `varlist' if `running' >= 0 & `running' < `band_r' , a(`site')      // right
					predict `resl' if `running' >= 0 & e(sample), r
					areg `outcome' `varlist' if `running' < 0 & `running' > `band_l', a(`site')       // left
					predict `resr' if `running' < 0 & e(sample), r				
					}				 

				g `res' = `resl'
				replace `res' = `resr' if mi(`resl')
				
				** Preparing the graph
				local stepL = `band_l'/`nbins_l'
				local step2L = `stepL'/2
				egen `cut_x' = cut(`running'), at(`band_l'(`stepL')0)
				replace `cut_x' = `cut_x' + `step2L'

				local stepR = `band_r'/`nbins_r'
				local step2R = `stepR'/2
				egen `cut_xR' = cut(`running'), at(0(`stepR')`band_r')
				replace `cut_xR' = `cut_xR' + `step2R'
				replace `cut_x' = `cut_xR' if `running' > 0
				
				bys `cut_x': egen `cond_y' = mean(`res')
				bys `cut_x': g `toplot' = _n

				** Store some useful results 
				g `intrc' = `assign'*`running'
				reg `res' `assign' `running' `intrc', robust 
				local tst = round(_b[`assign']/_se[`assign'],.01)
				local pvl: di %3.2f el(r(table),4,1)		
				
				if !mi("`cmpr'"){
				
					tokenize `cmpr'	
					local w : word count `cmpr'

					if `w' == 1 {
						local poly_r = `"`1'"'
						local poly_l = `"`1'"'
					}
					if `w' == 2 {
						local poly_l `"`1'"'
						local poly_r `"`2'"'
					}				
				
					local x_covs_l "`running'"  				
					local x_covs_r "`running'"  		
					 
					forval degree = 2(1)`poly_l'{                  // Build polynomial to the left of the cutoff
						g `running'_`degree' = `running'^`degree'
						local x_covs_l "`x_covs_l' `running'_`degree'"
						}
						
					forval degree = 2(1)`poly_r'{                  // Build polynomial to the right of the cutoff
						cap drop `running'_`degree'                           
						g `running'_`degree' = `running'^`degree'
						local x_covs_r "`x_covs_r' `running'_`degree'"
						}	

				
					if mi("`site'") {	   			
						reg `outcome' `x_covs_r' if `running' >= 0 & `running' < `band_r' 			      // right
						predict `resl_cmp' if `running' >= 0 & e(sample), xb
						replace `resl_cmp' = `resl_cmp' - _b[_cons]
						reg `outcome' `x_covs_l' if `running' < 0 & `running' > `band_l'                  // left
						predict `resr_cmp' if `running' < 0 & e(sample), xb	
						replace `resr_cmp' = `resr_cmp' - _b[_cons]
						}
						 
					if !mi("`site'") {
						areg `outcome' `x_covs_r' if `running' >= 0 & `running' < `band_r' , a(`site')      // right
						predict `resl_cmp' if `running' >= 0 & e(sample), xb
						replace `resl_cmp' = `resl_cmp' - _b[_cons]
						areg `outcome' `x_covs_l' if `running' < 0 & `running' > `band_l', a(`site')       // left
						predict `resr_cmp' if `running' < 0 & e(sample), xb			
						replace `resr_cmp' = `resr_cmp' - _b[_cons]
						}	
						
					g `res_cmp' = `resl_cmp'
					replace `res_cmp' = `resr_cmp' if mi(`resl_cmp')

					}
				
				** Plot residuals against the running variable
				local x_lb   = -floor(-`band_l')
				local x_ub   =  floor( `band_r')
				local x_step = (`band_r' -`band_l')/5
				
				if mi("`cmpr'"){
					twoway (scatter `cond_y' `cut_x' if `toplot' == 1, xline(0, lpattern(shortdash))) 									      ///
						   (lfit `res' `running' if `running' < 0, lpattern(solid) lcolor(red))       										  ///
						   (lfit `res' `running' if `running' > 0, lpattern(solid) lcolor(green)),      									  ///
						   ylabel(,nogrid) xlabel(`x_lb'(`x_step')`x_ub') ytitle("Residuals") 												  ///
						   xtitle("Running Variable") title("Visualization of the CIA")              										  ///
						   legend(order(1 2 3) lab(1 "Within-bin Mean") lab(2 "Conditional") lab(3 "Conditional") rows(1)) `gphoptions' 
					}
				else {
					twoway (scatter `cond_y' `cut_x' if `toplot' == 1, xline(0, lpattern(shortdash))) 									      ///
						   (lfit `res' `running' if `running' < 0, lpattern(solid) lcolor(red))       										  ///
						   (lfit `res' `running' if `running' > 0, lpattern(solid) lcolor(green))      									      ///
						   (lfit `res_cmp' `running' if `running' > 0, lpattern(dash) lcolor(orange))    									  ///
						   (lfit `res_cmp' `running' if `running' < 0, lpattern(dash) lcolor(orange)),   									  ///
						   ylabel(,nogrid) xlabel(`x_lb'(`x_step')`x_ub') ytitle("Residuals") xtitle("Running Variable")     ///
						   title("Visualization of the CIA")              ///
						   legend(order(1 2 3 4) lab(1 "Within-bin Mean") lab(2 "Cond") lab(3 "Cond") lab(4 "Uncond")  rows(1)) `gphoptions' 
					}
				restore	   
				}
end
