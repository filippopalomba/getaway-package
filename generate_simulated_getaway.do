**************************************************************
** Author: Filippo Palomba
** Date: 12 Jan 2022
** Generate simulated_getaway.dta
**************************************************************

clear

local Nobs = 2000                  // Observations in the sample
local Nranks = 5                   // Number of different rankings
local Ncandidates = 10			   // Number of candidate covariates
local Nciacovs    = 2              // Number of candidate covariates satisfying the CIA

set seed 8894

local Nobsrank = `Nobs'/`Nranks'

set obs `Nobs'
g site = mod(_n,5) + 1
g fixedeffect = site*20
	
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



* What we observe is a noisy function of the outcome of the DGP
g noise_Y = rnormal(0,10)
g Yobs = Y + noise_Y

* Generate Treatment Effect
g effect = Y1 - Y0

** Label and eliminate variables

foreach j of numlist 1/`Ncandidates'{
	la var w`j' "Candidate Variable `j'"
}

la var site "Site identifier"
la var T "Treatment Dummy"
la var X "Standardized Running Variable"
la var Xraw "Runnning Variable"
la var cutoff "Site Cutoff"
la var effect "True Treatment Effect"
la var Y1 "Potential Outcome if treated (T=1)"
la var Y0 "Potential Outcome if not treated (T=0)"

keep Yobs T X Xraw site cutoff w* Y1 Y0 effect
order Yobs T X Xraw site cutoff w* Y1 Y0 effect
sort site
rename Yobs Y
la var Y "Outcome Variable"

save "simulated_getaway.dta", replace
