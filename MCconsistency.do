**************************************************************
** Author: Filippo Palomba
** Date: 4 Mar 2023
** Monte Carlo Simulation to show consistency of getaway
**************************************************************

cd "/Users/fpalomba/Dropbox (Princeton)/projects/getaway-project-backend"

clear all

local MC = 200                     // Number of simulations
local Nobs = 2000                  // Observations in the sample
local Nranks = 5                   // Number of different rankings
local Ncandidates = 10			   // Number of candidate covariates
local Nciacovs    = 2              // Number of candidate covariates satisfying the CIA

set seed 8894

local Nobsrank = `Nobs'/`Nranks'

set obs `Nobs'
g site = mod(_n,5)*20 + 1
g fixedeffect = site
	
* Generate candidate covariates
global covs_candidate ""
foreach iter of numlist 1/`Ncandidates' { 
	local media = runiform(-1,1)
	g w`iter' = rnormal(`media',1)
	global covs_candidate "$covs_candidate w`iter'"
}

* Generate the observed score as a noisy function of some of the candidate covariates, i.e. X = g(W,e)
g W = 0   
matrix define beta_score = J(`Nciacovs',1,.)
foreach iter of numlist 1/`Nciacovs'{
	local beta_`iter' = runiform(1,2)
	replace W = W + `beta_`iter''*w`iter' 
	matrix beta_score[`iter',1] = `beta_`iter''
}

g noise_score = rnormal(0,1)

g X = W + noise_score


* Generate cutoff and assignment to treatment dummy. Notice that the treatment status depends on X not on W!!
sort site X, stable
by site: egen cutoff = median(X)
g Xraw = X
replace X = X - cutoff
g T = X > 0


* Data Generating Process: the DGP depends on W not on X
g W2 = W^2

cap drop Y*
local a = 50
local b = 5
local c = 0.5
local d = 1
local e = 2

g Y = `a'*T + `b'*W + `c'*W2 + `d'*W*T + `e'*W2*T + fixedeffect

g Y1 = Y if T
g Y0 = Y if !T
replace Y1 = `a' + `b'*W + `c'*W2 + `d'*W + `e'*W2 + fixedeffect if !T
replace Y0 = `b'*W + `c'*W2 + fixedeffect if T

* Generate Treatment Effect
g effect = Y1 - Y0

generate w1sq = w1^2
generate w2sq = w2^2
generate w2Xw1 = w2*w1


mat define QTLEest = J(`MC', 10, .)


forvalues i = 1/`MC' {
	g noise_Y`i' = rnormal(0,1)
}

quietly {
	forvalues iter = 1/`MC' {
		
		cap drop Yobs effect_est* incs pscore
		
		g Yobs = Y + noise_Y`iter'

		cap drop pscore incs
		ciacs w1 w2 w1sq w2sq w2Xw1, o(Yobs) assign(T) s(X) c(0) b(7) pscore(pscore) nograph site(site)
		generate incs = pscore >= e(CSmin) & pscore <= e(CSmax)

		cap drop effect_est
		getaway w1 w2 w1sq w2sq w2Xw1 if incs, o(Yobs) s(X) c(0) b(7) nquant(5 5) boot(2) genvar(effect_est) site(site) reghd
		
		cap drop Xqtlel Xqtler
		xtile Xqtler = X if T == 1 & incs, nq(5) 
		xtile Xqtlel = X if T == 0 & incs, nq(5) 
		matrix define QTLEStrue = J(10, 1, .)

		forval qt = 1/5{         
			qui su effect if Xqtlel == `qt' & incs == 1
			local trueL = r(mean)
			
			local qtt = `qt' + 5
			qui su effect if Xqtler == `qt' & incs == 1
			local trueR = r(mean)

			qui su effect_est if Xqtlel == `qt' & incs == 1
			matrix QTLEest[`iter', `qt'] = 100*(r(mean)/`trueL'-1)
			qui su effect_est if Xqtler == `qt' & incs == 1
			matrix QTLEest[`iter', `qtt'] = 100*(r(mean)/`trueR'-1)
			
		}	

	}
}

preserve 
clear
svmat QTLEest
xpose, clear

egen QTLES1 = rowmedian(v*)
egen QTLES2 = rowsd(v*)
drop v*

svmat QTLEStrue


g qtle = _n
g QTLES5 = QTLES1 - invnormal(0.995) * QTLES2
g QTLES6 = QTLES1 + invnormal(0.995) * QTLES2

twoway (rcap QTLES5 QTLES6 qtle, yline(0))                       ///
	   (scatter QTLES1 qtle), legend(order(1 2)     			 ///
	   lab(1 "99% bands") lab(2 "median bias") rows(2)           ///
	   region(style(none)) nobox) scheme(white_tableau)          ///
	   xtitle("Quantile of Running Variable") ytitle("bias (%)") ///
	   yscale(range(-10 10)) ylabel(-10(5)10)

graph export "article/fig_git/unbiasednessMC.png", replace

restore 


