**************************************************************
** Author: Filippo Palomba
** Date: 4 Mar 2023
** Produce figures for getaway paper
**************************************************************

***************************************
* Generate log files and other figures
***************************************
cd "/Users/fpalomba/Dropbox (Princeton)/projects/getaway-project-backend"

cap mkdir article
cap mkdir article/fig_git
global fig "article/fig_git"

use "data/simulated_getaway.dta", clear

summarize Y T X cutoff
tabulate cutoff


* visualize data
twoway (scatter Y X if site == 1, mc(cyan) m(o))                    ///
(scatter Y X if site == 2, mc(midblue) m(o))                        ///
(scatter Y X if site == 3, mc(ebblue) m(o))                         ///
(scatter Y X if site == 4, mc(navy) m(o))                           ///
(scatter Y X if site == 5, mc(dknavy) m(o)),                        ///
xline(0, lc(red)) ylabel(,nogrid)                                   ///
xtitle("Score") ytitle("Outcome") xlabel(-6(3)6) legend(off)        ///
graphregion(color(white)) plotregion(color(white)) scheme(white_tableau) 

graph export "$fig/rdplot.png", replace
graph close

* search for vector W that satisfies the CIA (true vector is w1 w2 w1^2 w2^2 and w1Xw2)
ciasearch w1 w2 w3 w4 w5 w6 w7 w8 w9 w10, o(Y) s(X) c(0) b(7) ///
site(site) quad noprint p(2) alpha(0.2) 

generate w1sq = w1^2
generate w2sq = w2^2
generate w2Xw1 = w2*w1

* manually test the CIA
ciatest w1 w2 w1sq w2sq w2Xw1, o(Y) s(X) c(0) b(7) p(2) site(site) 

* visually check that CIA holds
ciares w1 w2 w1sq w2sq w2Xw1, o(Y) s(X) b(7) site(site) nb(10 10) ///
gphoptions(xlabel(-6(3)6) title("") graphregion(color(white))     ///
plotregion(color(white)) scheme(white_tableau) legend(off))

graph export "$fig/ciares.png", replace
graph close

* verify common support 
ciacs w1 w2 w1sq w2sq w2Xw1, o(Y) assign(T) s(X) c(0) b(7) site(site) ///
pscore(pscore) gphoptions(title("") graphregion(color(white))         ///
plotregion(color(white)) scheme(white_tableau)) 

graph export "$fig/ciacs.png", replace
graph close

generate incs = pscore >= e(CSmin) & pscore <= e(CSmax)
tabulate incs T

* estimate treatment effects away from the cutoff
getaway w1 w2 w1sq w2sq w2Xw1 if incs, o(Y) s(X) c(0) b(7) site(site) ///
qtleplot nquant(5 5) boot(200) gphoptions(graphregion(color(white))   ///
plotregion(color(white)) scheme(white_tableau) legend(rows(4)) 		  ///
title("")) genvar(effect_est) reghd


graph export "$fig/getaway.png", replace
graph close

* compare estimated treatment effects with true treatment effects
mat define QTLES = e(quantiles)
xtile Xqtler = X if T == 1 & incs, nq(5) 
xtile Xqtlel = X if T == 0 & incs, nq(5) 
matrix define QTLEStrue = J(10,1,.)

forval qt = 1/5{         
	qui su effect if Xqtlel == `qt' & incs
	matrix QTLEStrue[`qt',1] = r(mean)
	
	local qtt = `qt' + 5
	qui su effect if Xqtler == `qt' & incs 
	matrix QTLEStrue[`qtt',1] = r(mean)
}	

preserve 
clear
svmat QTLES
svmat QTLEStrue
g qtle = _n
g QTLES5 = QTLES1 - invnormal(0.975) * QTLES2
g QTLES6 = QTLES1 + invnormal(0.975) * QTLES2

twoway (scatter QTLES1 qtle) (scatter QTLEStrue qtle)   ///
	   (rcap QTLES5 QTLES6 qtle), legend(order(1 2)     ///
	   lab(1 "Estimated TE") lab(2 "True TE") rows(2)   ///
	   region(style(none)) nobox) scheme(white_tableau) ///
	   xtitle("Quantile") ytitle("Treatment Effect")

graph export "$fig/compare_effects.png", replace
graph close
restore 

* if you are not satisfied with the precision of the estimator due to sampling
* variability run the following montecarlo simulation to check unbiasedness!

* do MCunbiasedness.do

* visualize potential outcomes functions through kernel-smoothing
getawayplot w1 w2 w1sq w2sq w2Xw1, o(Y) s(X) c(0) b(7) k(triangle)       ///
d(2) nb(30) site(site) gphoptions(xlabel(-6(3)6)                         ///
graphregion(color(white)) plotregion(color(white)) scheme(white_tableau) ///
legend(rows(3)))

graph export "$fig/getawayplot.png", replace
graph close
