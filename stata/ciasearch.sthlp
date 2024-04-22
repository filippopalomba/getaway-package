{smcl}
{* *!version 0.8 2024-04-22}{...}
{viewerjumpto "Syntax" "ciasearch##syntax"}{...}
{viewerjumpto "Description" "ciasearch##description"}{...}
{viewerjumpto "Options" "ciasearch##options"}{...}
{viewerjumpto "Examples" "ciasearch##examples"}{...}
{viewerjumpto "Stored results" "ciasearch##stored_results"}{...}
{viewerjumpto "References" "ciasearch##references"}{...}
{viewerjumpto "Authors" "ciasearch##authors"}{...}

{title:Title}

{p 4 8}{cmd:ciasearch} {hline 2} Data-driven algorithm that selects covariates satisfying the CIA in Regression Discontinuity designs.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:ciasearch } 
{cmd:{it:varlist}} (ts fv) [{help if}] [{help in}], 
{cmd:outcome(}{it:outcomevar}{cmd:)} 
{cmd:score(}{it:scorevar}{cmd:)}
{cmd:bandwidth(}{it:string}{cmd:)}
[{cmd:cutoff(}{it:#}{cmd:)}  
{cmd:included(}{it:varlist}{cmd:)}
{cmd:poly(}{it:numlist}{cmd:)}
{cmd:robust}
{cmd:vce(}{it:varname}{cmd:)}
{cmd:site(}{it:varname}{cmd:)}
{cmd:alpha(}{it:#}{cmd:)}
{cmd:quad}
{cmd:unique}
{cmd:force}
{cmd:noprint}]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:ciasearch} is an algorithm that searches for a set of covariates that validates the CIA among the candidate ones (i.e. those indicated in {it:varlist}).
The algorithm relies on the testing procedure developed by Angrist and Rokkanen (2015) in a Regression Discontinuity framework and implemented by the 
command {help ciatest}.{p_end}

{p 4 8}The algorithm adds one covariate in {it:varlist} at a time and runs {help ciatest}. Then, the covariate that minimizes a loss function based on the 
test of the null hypothesis that the CIA holds is selected. By default the command runs the algorithm separately to the left and to the right of the 
cutoff. If the option {cmd:unique} is specified then a single set of covariates satisfying the CIA on both sides is selected.{p_end}

{p 4 8}The covariates indicated in {it:included} are always included in the testing regression.{p_end}

{p 4 8} This command belongs to the {cmd:getaway} package. Companion commands are {help ciares:ciares}, {help ciatest:ciatest}, {help ciacs:ciacs}, {help getaway:getaway}, and
{help getawayplot:getawayplot}. More information can be found in the {browse "https://github.com/filippopalomba/getaway-package":official Github repository}.


{marker options}{...}
{title:Options}

{synoptset 28 tabbed}{...}
{dlgtab:Main Options}

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
{synopt:{opt included(varlist)}} specifies the covariates that are always included.

{pstd}
{p_end}
{synopt:{opt p:oly(numlist)}}  specifies the degree of the polynomial in the running variable. The user can specify a different degree for each side. Default is {cmd:p(1 1)}.

{pstd}
{p_end}
{synopt:{opt robust}}  estimates heteroskedasticity-robust standard errors.

{pstd}
{p_end}
{synopt:{opt vce(varname)}}  clusters standard errors at the specified level.

{pstd}
{p_end}
{synopt:{opt site(varname)}}  specifies the variable identifying the site to add site fixed effects.

{pstd}
{p_end}
{synopt:{opt alpha(#)}} specifies the level of I-type error in the CIA test. Default is {cmd:alpha(0.1)}.

{dlgtab:Algorithm Options}

{pstd}
{p_end}
{synopt:{opt quad}}  adds to {it:varlist} squared terms of each (non-dichotomic) covariate in {it:varlist} and interactions of all the covariates in {it:varlist}.

{pstd}
{p_end}
{synopt:{opt unique}}  runs a unique algorithm on both sides. This version selects a set of covariates that satisfies the CIA condition on both sides of the
	cutoff at the same time.

{pstd}
{p_end}
{synopt:{opt force}}  with this option switched on, the algorithm forgets the value of the loss function at the iteration j-1 and selects
	the covariate providing the lower value of the loss function at iteration j. In
	other words, with this option switched on, the algorithm searches for the covariate that
	minimizes the loss function within a certain iteration. This can make the loss function
	non-strictly decreasing in the number of iterations, but allows the algorithm to select
	covariates that provide a sensible gain only after some steps.

{pstd}
{p_end}
{synopt:{opt nop:rint}}  suppresses within-iteration results.

    {hline}


{marker examples}{...}
{title:Example: Simulated Data}

{p 4 8}Setup{p_end}
{p 8 8}{cmd:use simulated_getaway.dta}{p_end}

{p 4 8}Search for covariates satisfying the CIA{p_end}
{p 8 8}{cmd:ciasearch w*, o(Y) s(X) c(0) b(7) site(site) quad noprint p(2) alpha(0.2)}{p_end}


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

{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Locals}{p_end}
{synopt:{cmd:e(selected_covs)}}  is the list of selected covariates (without those in {it:included}). {p_end}
{synopt:{cmd:e(selected_covs_r)}}  is the list of selected covariates to the right of the cutoff. {p_end}
{synopt:{cmd:e(selected_covs_l)}}  is the list of selected covariates to the left of the cutoff. {p_end}
{synopt:{cmd:e(CIAright)}}  {p_end}
{synopt:{cmd:e(CIAleft)}}  {p_end}


{marker references}{...}
{title:References}

{p 4 8}Angrist, Joshua D., and Miikka Rokkanen. {browse "https://economics.mit.edu/files/10851":Wanna get away? Regression discontinuity estimation of exam school effects away from the cutoff.} 
{it:Journal of the American Statistical Association} 110.512 (2015): 1331-1344.{p_end}

{marker authors}{...}
{title:Authors}

{p 4 8}Filippo Palomba, Princeton University, Princeton, NJ.
{browse "mailto:fpalomba@princeton.edu":fpalomba@princeton.edu}.

