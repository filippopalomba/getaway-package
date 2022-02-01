{smcl}
{* *! version 1.0 17 Jan 2022}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "ciasearch##syntax"}{...}
{viewerjumpto "Description" "ciasearch##description"}{...}
{viewerjumpto "Options" "ciasearch##options"}{...}
{viewerjumpto "Remarks" "ciasearch##remarks"}{...}
{viewerjumpto "Examples" "ciasearch##examples"}{...}
{title:Title}
{phang}
{bf:ciasearch} {hline 2} Data-driven algorithm that selects covariates satisfying the CIA in a Regression Discontinuity framework.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:ciasearch}
varlist(min
=
1)
[{help if}]
[{help in}]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt o:utcome(varname)}}  specifies the dependent variable of interest.

{pstd}
{p_end}
{synopt:{opt s:core(varname)}}  specifies the running variable.

{pstd}
{p_end}
{synopt:{opt b:andwidth(string)}}  specifies the bandwidth to be used for estimation. The user can specify a different bandwidth for each side.

{pstd}
{p_end}
{synopt:{opt c:utoff(#)}}  specifies the RD cutoff for the running variable.  Default is {cmd:c(0)}. The cutoff value is subtracted from the {it:score} variable and the bandwidth. In case multiple cutoffs are present, provide the pooled cutoff.

{pstd}
{p_end}
{synopt:{opt included(varlist fv)}}  specifies the covariates that are always included in the testing regression.

{pstd}
{p_end}
{synopt:{opt p:oly(numlist max=2  integer)}}  specifies the degree of the polynomial in the running variable. The user can specify a different degree for each side. Default is {cmd:p(1 1)}.

{pstd}
{p_end}
{synopt:{opt rob:ust}}  estimates heteroskedasticity-robust standard errors.

{pstd}
{p_end}
{synopt:{opt vce(varname)}}  clusters standard errors at the specified level.

{pstd}
{p_end}
{synopt:{opt site(varname)}}  specifies the variable identifying the site to add site fixed effects.

{pstd}
{p_end}
{synopt:{opt alpha(#)}}  specifies the level of I-type error in the CIA test. Default is {cmd:alpha(0.1)}.

{pstd}
{p_end}
{synopt:{opt quad}}  adds to {it:varlist} squared terms of each (non-dichotomic) covariate in {it:varlist} and interactions of all the covariates in {it:varlist}.

{pstd}
{p_end}
{synopt:{opt unique}}  runs a unique algorithm on both sides. This version selects a set of covariates that satisfies the CIA condition on both sides of the
	cutoff at the same time.
{p_end}
{synopt:{opt force}}  with this option switched on, the algorithm forgets the value of the loss function at the iteration j-1 and selects
	the covariate providing the lower value of the loss function at iteration j. In
	other words, with this option switched on, the algorithm searches for the covariate that
	minimizes the loss function within a certain iteration. This can make the loss function
	non-strictly decreasing in the number of iterations, but allows the algorithm to select
	covariates that provide a sensible gain only after some steps.
{p_end}
{synopt:{opt nop:rint}}  suppresses within-iteration results.

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:ciasearch} is an algorithm that searches for a set of covariates that validates the CIA among the candidate ones (i.e. those indicated in {it:varlist}).
The algorithm relies on the testing procedure developed by Angrist and Rokkanen (2015) in a Regression Discontinuity framework and implemented by the 
command {help ciatest}.

{pstd}
The algorithm adds one covariate in {it:varlist} at a time and runs {help ciatest}. Then, the covariate that minimizes a loss function based on the 
test of the null hypothesis that the CIA holds is selected. By default the command runs the algorithm separately to the left and to the right of the 
cutoff. If the option {cmd:unique} is specified then a single set of covariates satisfying the CIA on both sides is selected.

{pstd}
The covariates indicated in {it:included} are always included in the testing regression.

{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt o:utcome(varname)}     specifies the dependent variable of interest.

{pstd}
{p_end}
{phang}
{opt s:core(varname)}     specifies the running variable.

{pstd}
{p_end}
{phang}
{opt b:andwidth(string)}     specifies the bandwidth to be used for estimation. The user can specify a different bandwidth for each side.

{pstd}
{p_end}
{phang}
{opt c:utoff(#)}     specifies the RD cutoff for the running variable.  Default is {cmd:c(0)}. The cutoff value is subtracted from the {it:score} variable and the bandwidth. In case multiple cutoffs are present, provide the pooled cutoff.

{pstd}
{p_end}
{phang}
{opt included(varlist fv)}     specifies the covariates that are always included in the testing regression.

{pstd}
{p_end}
{phang}
{opt p:oly(numlist max=2  integer)}     specifies the degree of the polynomial in the running variable. The user can specify a different degree for each side. Default is {cmd:p(1 1)}.

{pstd}
{p_end}
{phang}
{opt rob:ust}     estimates heteroskedasticity-robust standard errors.

{pstd}
{p_end}
{phang}
{opt vce(varname)}     clusters standard errors at the specified level.

{pstd}
{p_end}
{phang}
{opt site(varname)}     specifies the variable identifying the site to add site fixed effects.

{pstd}
{p_end}
{phang}
{opt alpha(#)}     specifies the level of I-type error in the CIA test. Default is {cmd:alpha(0.1)}.

{pstd}
{p_end}
{phang}
{opt quad}     adds to {it:varlist} squared terms of each (non-dichotomic) covariate in {it:varlist} and interactions of all the covariates in {it:varlist}.

{pstd}
{p_end}
{phang}
{opt unique}     runs a unique algorithm on both sides. This version selects a set of covariates that satisfies the CIA condition on both sides of the
	cutoff at the same time.
{p_end}
{phang}
{opt force}     with this option switched on, the algorithm forgets the value of the loss function at the iteration j-1 and selects
	the covariate providing the lower value of the loss function at iteration j. In
	other words, with this option switched on, the algorithm searches for the covariate that
	minimizes the loss function within a certain iteration. This can make the loss function
	non-strictly decreasing in the number of iterations, but allows the algorithm to select
	covariates that provide a sensible gain only after some steps.
{p_end}
{phang}
{opt nop:rint}     suppresses within-iteration results.

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}

{pstd}
The examples below show how to correctly use the command {cmd:ciatest} to check whether the CIA holds or not. Suppose that we have at hand an
{it:outcome} variable, a {it:score} variable, and a set of K covariates ({it:varlist}). We would like to know whether a subset of {it:varlist} 
makes {it:score} ignorable, i.e. makes CIA hold. To do so, it is enough to run (for the sake of the example assume the bandwidth to be 10 and 
the cutoff to be 0)

{pstd}
{cmd:ciasearch cov1 cov2 ... covK, o(outcome) s(score) b(10)}

{pstd}
If we suspect that there is either heteroskedasticity or intra-cluster correlation in the residuals, then

{pstd}
{cmd:ciasearch cov1 cov2 ... covK, o(outcome) s(score) b(10) robust}

{pstd}
{cmd:ciasearch cov1 cov2 ... covK, o(outcome) s(score) b(10) vce(clustervar)}

{pstd}
If, in addition, we are pooling together different rankings, then we should add fixed effects at the ranking level (see Ichino and Rettore (forthcoming))

{pstd}
{cmd:ciasearch cov1 cov2 ... covK, o(outcome) s(score) b(10) vce(clustervar) site(ranking)}

{pstd}
If we want to add to the list also second-order covariates

{pstd}
{cmd:ciasearch cov1 cov2 ... covK, o(outcome) s(score) b(10) vce(clustervar) site(ranking) quad}

{pstd}
If we want some covariates to be always included

{pstd}
{cmd:ciasearch cov1 cov2 ... covK, o(outcome) s(score) b(10) vce(clustervar) site(ranking) quad included(covI1 ... covIK)}

{pstd}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Locals}{p_end}
{synopt:{cmd:r(selected_covs)}}  is the list of selected covariates (without those in {it:included}). {p_end}
{synopt:{cmd:r(selected_covs_r)}}  is the list of selected covariates to the right of the cutoff. {p_end}
{synopt:{cmd:r(selected_covs_l)}}  is the list of selected covariates to the left of the cutoff. {p_end}
{synopt:{cmd:r(CIAright)}}  {p_end}
{synopt:{cmd:r(CIAleft)}}  {p_end}


{title:References}
{pstd}

{pstd}
Angrist, J. D., & Rokkanen, M. (2015). Wanna get away? Regression discontinuity estimation of exam school effects away from the cutoff. 
{it:Journal of the American Statistical Association}, 110(512), 1331-1344.


{title:Author}
{p}

Filippo Palomba, Department of Economics, Princeton University.

Email {browse "mailto:fpalomba@princeton.edu":fpalomba@princeton.edu}



{title:See Also}
Related commands:


{pstd}
Other Related Commands (ssc repository not working yet): {p_end}

{synoptset 27 }{...}

{synopt:{help ciatest} (if installed)} {stata ssc install ciatest}   (to install) {p_end}
{synopt:{help ciares} (if installed)}   {stata ssc install ciares} (to install) {p_end}
{synopt:{help ciacs} (if installed)}   {stata ssc install ciacs}     (to install) {p_end}
{synopt:{help getaway} (if installed)} {stata ssc install getaway}   (to install) {p_end}
{synopt:{help getawayplot}  (if installed)}   {stata ssc install getawayplot}      (to install) {p_end}

{p2colreset}{...}

