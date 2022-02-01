{smcl}
{* *! version 1.0 17 Jan 2022}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "getaway##syntax"}{...}
{viewerjumpto "Description" "getaway##description"}{...}
{viewerjumpto "Options" "getaway##options"}{...}
{viewerjumpto "Remarks" "getaway##remarks"}{...}
{viewerjumpto "Examples" "getaway##examples"}{...}
{title:Title}
{phang}
{bf:getaway} {hline 2} Estimate treatment effect away from the cutoff in a Sharp RDD framework.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:getaway}
varlist(ts
fv)
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
{synopt:{opt m:ethod(string)}}  allows to choose the estimation method between Linear Rewighting Estimator ({it:linear}) and Propensity Score Weighting Estimator ({it:pscore}). Default is {cmd:method(}{it:linear}{cmd:)}.

{pstd}
{p_end}
{synopt:{opt site(varname)}}  specifies the variable identifying the site to add site fixed effects.

{pstd}
{p_end}
{synopt:{opt nq:uant(numlist max=2  integer)}}  specifies the number of quantiles in which the treatment effect must be estimated. It can be specified separately for each side. Default is {cmd:nquant(0 0)}. 
	To be specified if {cmd: qtleplot} is used.
{p_end}
{synopt:{opt boot:rep(#)}}  sets the number of replications of the non-parametric bootstrap. Default is {cmd:bootrep(0)}. If {cmd: site} is specified a non-parametric block bootstrap is used.

{pstd}
{p_end}
{synopt:{opt qtleplot}}  plots estimated treatment effect over running variable quantiles together with bootstrapped standard errors. 
	Also estimates and bootstrapped standard errors of the Average Treatment Effect on the Treated (ATT) and on the Non Treated (ATNT) are reported.
{p_end}
{synopt:{opt gphoptions(string)}}  specifies graphical options to be passed on to the underlying graph command.

{pstd}
{p_end}
{synopt:{opt gen:var(string)}}  specifies the name of the variable containing the distribution of treatment effects. Only with {it:linear} option.

{pstd}
{p_end}
{synopt:{opt asis}}  forces retention of perfect predictor variables and their associated perfectly predicted observations in p-score estimation. To be used only with {it:pscore}.

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:getaway} uses variables contained in {it:varlist} to estimate the treatment effect away from the cutoff in a Sharp Regression Discontinuity
framework as proposed by Angrist and Rokkanen (2015). 

{pstd}
The command {cmd:getaway} can use either the Linear Reweighting Estimator or the Propensity Score Weighting Estimator. The average treatment effect 
on the left and on the right of the cutoff are estimated by default. In addition, {cmd:getaway} gives the possibility to estimate the treatment effect 
on finer intervals of the support of the running variable. The command allows to plot the estimates together with their bootstrapped standard errors.

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
{opt m:ethod(string)}     allows to choose the estimation method between Linear Rewighting Estimator ({it:linear}) and Propensity Score Weighting Estimator ({it:pscore}). Default is {cmd:method(}{it:linear}{cmd:)}.

{pstd}
{p_end}
{phang}
{opt site(varname)}     specifies the variable identifying the site to add site fixed effects.

{pstd}
{p_end}
{phang}
{opt nq:uant(numlist max=2  integer)}     specifies the number of quantiles in which the treatment effect must be estimated. It can be specified separately for each side. Default is {cmd:nquant(0 0)}. 
	To be specified if {cmd: qtleplot} is used.
{p_end}
{phang}
{opt boot:rep(#)}     sets the number of replications of the non-parametric bootstrap. Default is {cmd:bootrep(0)}. If {cmd: site} is specified a non-parametric block bootstrap is used.

{pstd}
{p_end}
{phang}
{opt qtleplot}     plots estimated treatment effect over running variable quantiles together with bootstrapped standard errors. 
	Also estimates and bootstrapped standard errors of the Average Treatment Effect on the Treated (ATT) and on the Non Treated (ATNT) are reported.
{p_end}
{phang}
{opt gphoptions(string)}     specifies graphical options to be passed on to the underlying graph command.

{pstd}
{p_end}
{phang}
{opt gen:var(string)}     specifies the name of the variable containing the distribution of treatment effects. Only with {it:linear} option.

{pstd}
{p_end}
{phang}
{opt asis}     forces retention of perfect predictor variables and their associated perfectly predicted observations in p-score estimation. To be used only with {it:pscore}.

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}

{pstd}
The examples below show how to correctly use the command {cmd:getaway} to estimate heterogeneous treatment effects in a sharp RDD framework. 
Suppose that we have at hand an {it:outcome} variable, a {it:score} variable and a set of K covariates ({it:varlist}) that makes the running variable
ignorable. For the sake of the example assume the bandwidth to be 10 and the cutoff to be 0. If we are interested in just the ATT and the ATNT , then

{pstd}
{cmd:getaway cov1 cov2 ... covK, o(outcome) s(score) b(10)}           - using Linear Rewighting Estimator 

{pstd}
{cmd:getaway cov1 cov2 ... covK, o(outcome) s(score) b(10) m(pscore)} - using Propensity Score Weighting Estimator

{pstd}
If, in addition, we are pooling together different rankings, then we should add fixed effects at the site level (see Fort et al. (2022))

{pstd}
{cmd:getaway cov1 cov2 ... covK, o(outcome) s(score) b(10) site(ranking)}

{pstd}
If we are interested in estimating the treatment effect on 5 quantiles of the running variable on each side (10 quantiles in total) and we also want to
estimate their standard errors with 200 repetitions of a non-parametric bootstrap, then

{pstd}
{cmd:getaway cov1 cov2 ... covK, o(outcome) s(score) b(10) nquant(5) bootrep(200)}

{pstd}
and if we want also a graphical representation of the estimates

{pstd}
{cmd:getaway cov1 cov2 ... covK, o(outcome) s(score) b(10) nquant(5) bootrep(200) qtleplot}

{pstd}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(se_eff1)}}  Bootstrapped standard error of the average effect on the right of the cutoff. {p_end}
{synopt:{cmd:r(se_eff0)}}  Bootstrapped standard error of the average effect on the left of the cutoff. {p_end}
{synopt:{cmd:r(effect1)}}  Average effect on the right of the cutoff. {p_end}
{synopt:{cmd:r(effect0)}}  Average effect on the left of the cutoff. {p_end}
{synopt:{cmd:r(N_T)}}  Number of treatment observation. {p_end}
{synopt:{cmd:r(N_C)}}  Number of control observation. {p_end}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(quantiles)}}  Matrix containing point estimates and standard errors of the quantiles. {p_end}
{synopt:{cmd:r(b1_kline)}}  Estimated weight of each covariate used in CIA test (right of cutoff) {p_end}
{synopt:{cmd:r(b0_kline)}}  Estimated weight of each covariate used in CIA test (left of cutoff) {p_end}


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

{synopt:{help ciasearch} (if installed)} {stata ssc install ciasearch}   (to install) {p_end}
{synopt:{help ciares} (if installed)}   {stata ssc install ciares} (to install) {p_end}
{synopt:{help ciacs} (if installed)}   {stata ssc install ciacs}     (to install) {p_end}
{synopt:{help ciatest} (if installed)} {stata ssc install ciatest}   (to install) {p_end}
{synopt:{help getawayplot}  (if installed)}   {stata ssc install getawayplot}      (to install) {p_end}

{p2colreset}{...}

