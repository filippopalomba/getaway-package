{smcl}
{* *!version 0.8 2024-04-22}{...}
{viewerjumpto "Syntax" "getaway##syntax"}{...}
{viewerjumpto "Description" "getaway##description"}{...}
{viewerjumpto "Options" "getaway##options"}{...}
{viewerjumpto "Examples" "getaway##examples"}{...}
{viewerjumpto "Stored results" "getaway##stored_results"}{...}
{viewerjumpto "References" "getaway##references"}{...}
{viewerjumpto "Authors" "getaway##authors"}{...}

{title:Title}

{p 4 8}{cmd:getaway} {hline 2} Estimate treatment effect away from the cutoff in a Sharp RDD designs.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:getaway } 
{cmd:{it:varlist}} (ts fv) [{help if}] [{help in}], 
{cmd:outcome(}{it:outcomevar}{cmd:)} 
{cmd:score(}{it:scorevar}{cmd:)}
{cmd:bandwidth(}{it:string}{cmd:)}
[{cmd:cutoff(}{it:#}{cmd:)}  
{cmd:method(}{it:string}{cmd:)}
{cmd:site(}{it:varname}{cmd:)}
{cmd:nquant(}{it:numlist}{cmd:)}
{cmd:probit}
{cmd:trimming(}{it:numlist}{cmd:)}
{cmd:bootrep(}{it:#}{cmd:)}
{cmd:clevel(}{it:#}{cmd:)}
{cmd:reghd}
{cmd:qtleplot}
{cmd:genvar(}{it:string}{cmd:)}
{cmd:asis}
{cmd:gphoptions(}{it:string}{cmd:)}
{cmd:qtleplotopt(}{it:string}{cmd:)}
{cmd:qtleciplotopt(}{it:string}{cmd:)}
{cmd:attplotopt(}{it:string}{cmd:)}
{cmd:attciplotopt(}{it:string}{cmd:)}
{cmd:atntplotopt(}{it:string}{cmd:)}
{cmd:atntciplotopt(}{it:string}{cmd:)}
{cmd:legendopt(}{it:string}{cmd:)}
]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:getaway} uses variables contained in {it:varlist} to estimate the treatment effect away from the cutoff in a Sharp Regression Discontinuity
framework as proposed by {browse "https://economics.mit.edu/files/10851":Angrist and Rokkanen (2015)} in a Regression Discontinuity framework.{p_end}

{p 4 8 }The command {cmd:getaway} can use either the Linear Reweighting Estimator or the Propensity Score Weighting Estimator. The average treatment effect 
on the left and on the right of the cutoff are estimated by default. In addition, {cmd:getaway} gives the possibility to estimate the treatment effect 
on finer intervals of the support of the running variable. The command allows to plot the estimates together with their bootstrapped standard errors.{p_end}

{p 4 8} This command belongs to the {cmd:getaway} package. Companion commands are {help ciares:ciares}, {help ciasearch:ciasearch}, {help ciacs:ciacs}, {help ciatest:ciatest}, and
{help getawayplot:getawayplot}. More information can be found in the {browse "https://github.com/filippopalomba/getaway-package":official Github repository}.


{marker options}{...}
{title:Options}

{synoptset 28 tabbed}{...}
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
{synopt:{opt nq:uant(numlist)}}  specifies the number of quantiles in which the treatment effect must be estimated. It can be specified separately for each side. Default is {cmd:nquant(0 0)}. 
	To be specified if {cmd: qtleplot} is used.

{pstd}
{p_end}
{synopt:{opt probit}}  if specified uses a probit model to estimate the pscore rather than the default logit model. 
It is effective only if {cmd: method("pscore")} is used.

{pstd}
{p_end}
{synopt:{opt trimming(numlist)}}  specifies a lower and an upper bound for the pscore. Units with pscore outside such interval are trimmed
and not used in estimation and inference. It is effective only if {cmd: method("pscore")} is used and in such case the 
default is {cmd:trimming(0.1 0.9)} according to Crump, Hotz, Imbens, and Mitnik (2009). 

{pstd}
{p_end}
{synopt:{opt boot:rep(#)}} sets the number of replications of the non-parametric bootstrap. Default is {cmd:bootrep(0)}. If {cmd: site} is specified a non-parametric block bootstrap is used.

{pstd}
{p_end}
{synopt:{opt clevel(#)}} specifies the confidence level for the confidence intervals reported in the plot. Default is {cmd:clevel(95)}.

{pstd}
{p_end}
{synopt:{opt reghd}} allows site fixed effects to differ on each side of the cutoff. If the number of
observations per ranking is not sufficiently high might yield inconsistent estimates for the treatment effects away from the cutoff. It relies on the command {help reghdfe:reghdfe}.

{pstd}
{p_end}
{synopt:{opt qtleplot}} plots estimated treatment effect over running variable quantiles together with bootstrapped standard errors. 
	Also estimates and bootstrapped standard errors of the Average Treatment Effect on the Treated (ATT) and on the Non Treated (ATNT) are reported.
	
{pstd}
{p_end}
{synopt:{opt gen:var(string)}}  specifies the name of the variable containing the distribution of treatment effects. Only with {it:linear} option.

{pstd}
{p_end}
{synopt:{opt asis}}  forces retention of perfect predictor variables and their associated perfectly predicted observations in p-score estimation. To be used only with {it:pscore}.

{pstd}
{p_end}
{synopt:{opt gphoptions(string)}}  specifies graphical options to be passed on to the underlying graph command.

{pstd}
{p_end}
{synopt:{opt qtleplotopt(string)}}  specifies graphical options to be passed on to the underlying scatter plot.

{pstd}
{p_end}
{synopt:{opt qtleciplotopt(string)}}  specifies graphical options to be passed on to the underlying spike plot for the confidence intervals
for the treatment effect at each quantile of the running variable.

{pstd}
{p_end}
{synopt:{opt attplotopt(string)}}  specifies graphical options to be passed on to the underlying line plot for the average treatment effect on the treated.

{pstd}
{p_end}
{synopt:{opt attciplotopt(string)}}  specifies graphical options to be passed on to the underlying line plot for the confidence interval of the average treatment effect on the treated.

{pstd}
{p_end}
{synopt:{opt atntplotopt(string)}}  specifies graphical options to be passed on to the underlying line plot for the average treatment effect on the non-treated.

{pstd}
{p_end}
{synopt:{opt atntciplotopt(string)}}  specifies graphical options to be passed on to the underlying line plot for the confidence interval of the average treatment effect on the non-treated.

{pstd}
{p_end}
{synopt:{opt legendopt(string)}} specifies graphical options to be passed on to the underlying plot legend.

    {hline}


{marker examples}{...}
{title:Example: Simulated Data}

{p 4 8}Setup{p_end}
{p 8 8}{cmd:use simulated_getawayplot.dta}{p_end}

{p 4 8}Prepare data{p_end}
{p 8 8}{cmd:generate w1sq = w1^2}{p_end}
{p 8 8}{cmd:generate w2sq = w2^2}{p_end}
{p 8 8}{cmd:generate w2Xw1 = w2*w1}{p_end}

{p 4 8}Visualize common support{p_end}
{p 8 8}{cmd:ciacs w1 w2 w1sq w2sq w2Xw1, o(Y) assign(T) s(X) c(0) b(7) site(site) pscore(pscore)}{p_end}

{p 4 8}Estimate Treatment Effects{p_end}
{p 8 8}{cmd:getaway w1 w2 w1sq w2sq w2Xw1 if incs, o(Y) s(X) c(0) b(7) site(site) qtleplot nquant(5 5) boot(200)}{p_end}

{marker stored_results}{...}
{title:Stored results}

{p 4 8}{cmd:getaway} stores the following in {cmd:e()}:

{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N_C)}} number of control observations.{p_end}
{synopt:{cmd:e(N_T)}} number of treatment observations.{p_end}
{synopt:{cmd:e(effect0)}} average effect on the left of the cutoff.{p_end}
{synopt:{cmd:e(effect1)}} average effect on the right of the cutoff.{p_end}
{synopt:{cmd:e(se_eff0)}} bootstrapped standard error of the average effect on the left of the cutoff.{p_end}
{synopt:{cmd:e(se_eff1)}} bootstrapped standard error of the average effect on the right of the cutoff.{p_end}


{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b0_kline)}} estimated weight of each covariate used in CIA test (left of cutoff){p_end}
{synopt:{cmd:e(b1_kline)}} estimated weight of each covariate used in CIA test (right of cutoff).{p_end}
{synopt:{cmd:e(quantiles)}} matrix containing point estimates and standard errors of the quantiles and the bounds of the running variable in each quantile.{p_end}

{marker references}{...}
{title:References}

{p 4 8}Angrist, Joshua D., and Miikka Rokkanen. {browse "https://economics.mit.edu/files/10851":Wanna get away? Regression discontinuity estimation of exam school effects away from the cutoff.} 
{it:Journal of the American Statistical Association} 110.512 (2015): 1331-1344.{p_end}

{p 4 8}Sergio Correia. {browse "http://scorreia.com/research/hdfe.pdf" reghdfe: Stata module for linear and instrumental-variable/GMM regression absorbing multiple levels of fixed effects.}{it:Statistical Software Components s457874}, Boston College Department of Economics (2017).{p_end}

{p 4 8}Crump, Richard K., V. Joseph Hotz, Guido W. Imbens, and Oscar A. Mitnik. {browse "https://academic.oup.com/biomet/article/96/1/187/235329":Dealing with limited overlap in estimation of average treatment effects.}
{it:Biometrika} 96.1 (2009): 187-199.{p_end}

{marker authors}{...}
{title:Authors}

{p 4 8}Filippo Palomba, Princeton University, Princeton, NJ.
{browse "mailto:fpalomba@princeton.edu":fpalomba@princeton.edu}.

