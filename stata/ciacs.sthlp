{smcl}
{* *!version 0.7 2023-12-01}{...}
{viewerjumpto "Syntax" "ciacs##syntax"}{...}
{viewerjumpto "Description" "ciacs##description"}{...}
{viewerjumpto "Options" "ciacs##options"}{...}
{viewerjumpto "Examples" "ciacs##examples"}{...}
{viewerjumpto "Stored results" "ciacs##stored_results"}{...}
{viewerjumpto "References" "ciacs##references"}{...}
{viewerjumpto "Authors" "ciacs##authors"}{...}

{title:Title}

{p 4 8}{cmd:ciacs} {hline 2} Verify common support for CIA in Regression Discontinuity designs.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:ciacs } 
{cmd:{it:varlist}} (ts fv) [{help if}] [{help in}], 
{cmd:outcome(}{it:outcomevar}{cmd:)} 
{cmd:assign(}{it:assignvar}{cmd:)}
{cmd:score(}{it:scorevar}{cmd:)}
{cmd:bandwidth(}{it:string}{cmd:)}
[{cmd:cutoff(}{it:#}{cmd:)}  
{cmd:nbins(}{it:numlist}{cmd:)}
{cmd:site(}{it:varname}{cmd:)}
{cmd:asis}
{cmd:gphoptions(}{it:string}{cmd:)}
{cmd:pscore(}{it:string}{cmd:)}
{cmd:probit}
{cmd:kdensity}
{cmd:nograph}]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:ciacs} allows to visualize the common support condition to validate estimation of treatment effects away from the cutoff in a Regression Discontinuity framework as proposed in  
{browse "https://economics.mit.edu/files/10851":Angrist and Rokkanen (2015)} in a Regression Discontinuity framework.{p_end}

{p 4 8} This command belongs to the {cmd:getaway} package. Companion commands are {help ciares:ciares}, {help ciasearch:ciasearch}, {help ciatest:ciatest}, {help getaway:getaway}, and
{help getawayplot:getawayplot}. More information can be found in the {browse "https://github.com/filippopalomba/getaway-package":official Github repository}.


{marker options}{...}
{title:Options}

{synoptset 28 tabbed}{...}
{syntab:Main}
{synopt:{opt o:utcome(varname)}}  specifies the dependent variable of interest. This option is used just to mark the sample on which the pscore is estimated.

{pstd}
{p_end}
{synopt:{opt a:ssign(varname)}}  sets the assignment to treatment variable.

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
{synopt:{opt nb:ins(#)}}  number of bins of the common support histogram. Default is {cmd:nbins(10 10)}.

{pstd}
{p_end}
{synopt:{opt site(varname)}}  specifies the variable identifying the site to add site fixed effects.

{pstd}
{p_end}
{synopt:{opt asis}}  forces retention of perfect predictor variables and their associated perfectly predicted observations.

{pstd}
{p_end}
{synopt:{opt gphoptions(string)}}  specifies graphical options to be passed on to the underlying graph command.

{pstd}
{p_end}
{synopt:{opt pscore(string)}}  specifies the name of the variable containing the pscore rather than the defaul logit model.
This variable is added to the current dataset.

{pstd}
{p_end}
{synopt:{opt probit}}  if specified uses a probit model to estimate the pscore.

{pstd}
{p_end}
{synopt:{opt kd:ensity}}  displays kernel densities rather than histograms, which is the default.

{pstd}
{p_end}
{synopt:{opt nog:raph}}  suppresses any graphical output.

    {hline}


{marker examples}{...}
{title:Example: Simulated Data}

{p 4 8}Setup{p_end}
{p 8 8}{cmd:use simulated_getaway.dta}{p_end}

{p 4 8}Prepare data{p_end}
{p 8 8}{cmd:generate X2 = X^2}{p_end}
{p 8 8}{cmd:generate interaction = X*T}{p_end}
{p 8 8}{cmd:generate interaction2 = X2*T}{p_end}
{p 8 8}{cmd:generate w1sq = w1^2}{p_end}
{p 8 8}{cmd:generate w2sq = w2^2}{p_end}
{p 8 8}{cmd:generate w2Xw1 = w2*w1}{p_end}

{p 4 8}Visualize common support{p_end}
{p 8 8}{cmd:ciacs w1 w2 w1sq w2sq w2Xw1, o(Y) assign(T) s(X) c(0) b(7) site(site) pscore(pscore)}{p_end}

{marker stored_results}{...}
{title:Stored results}

{p 4 8}{cmd:ciacs} stores the following in {cmd:e()}:

{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(CSmin)}} common support lower bound.{p_end}
{synopt:{cmd:e(CSmax)}} common support upper bound.{p_end}

{marker references}{...}
{title:References}

{p 4 8}Angrist, Joshua D., and Miikka Rokkanen. {browse "https://economics.mit.edu/files/10851":Wanna get away? Regression discontinuity estimation of exam school effects away from the cutoff.} 
{it:Journal of the American Statistical Association} 110.512 (2015): 1331-1344.{p_end}

{marker authors}{...}
{title:Authors}

{p 4 8}Filippo Palomba, Princeton University, Princeton, NJ.
{browse "mailto:fpalomba@princeton.edu":fpalomba@princeton.edu}.

