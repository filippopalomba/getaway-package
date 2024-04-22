{smcl}
{* *!version 0.8 2024-04-22}{...}
{viewerjumpto "Syntax" "getawayplot##syntax"}{...}
{viewerjumpto "Description" "getawayplot##description"}{...}
{viewerjumpto "Options" "getawayplot##options"}{...}
{viewerjumpto "Examples" "getawayplot##examples"}{...}
{viewerjumpto "Stored results" "getawayplot##stored_results"}{...}
{viewerjumpto "References" "getawayplot##references"}{...}
{viewerjumpto "Authors" "getawayplot##authors"}{...}

{title:Title}

{p 4 8}{cmd:getawayplot} {hline 2} Plot non-parametric extrapolation of treatment effect.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:getawayplot } 
{cmd:{it:varlist}} (ts fv) [{help if}] [{help in}], 
{cmd:outcome(}{it:outcomevar}{cmd:)} 
{cmd:score(}{it:scorevar}{cmd:)}
{cmd:bandwidth(}{it:string}{cmd:)}
[{cmd:cutoff(}{it:#}{cmd:)}  
{cmd:kernel(}{it:string}{cmd:)}
{cmd:site(}{it:varname}{cmd:)}
{cmd:nbins(}{it:numlist}{cmd:)}
{cmd:clevel(}{it:#}{cmd:)}
{cmd:nostderr}
{cmd:gphoptions(}{it:string}{)}
{cmd:scatterplotopt(}{it:string}{cmd:)}
{cmd:areaplotopt(}{it:string}{cmd:)}
{cmd:lineplotopt(}{it:string}{cmd:)}
{cmd:lineCFplotopt(}{it:string}{cmd:)}
{cmd:legendopt(}{it:string}{cmd:)}
]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:getawayplot} plots non-parametric estimates of the actual and counterfactual regression functions using the methodology discussed in
 {browse "https://economics.mit.edu/files/10851":Angrist and Rokkanen (2015)} in a Regression Discontinuity framework.{p_end}

{p 4 8 }The command relies on {help lpoly} to get smooth estimates of the two
potential outcomes. Then, it jointly plots the actual smoothed regression function and the counterfactual smoothed regression function together
with within-bin averages of the counterfactual outcome to show the fit of the non-parametric estimates. {p_end}

{p 4 8} This command belongs to the {cmd:getawayplot} package. Companion commands are {help ciares:ciares}, {help ciasearch:ciasearch}, {help ciacs:ciacs}, {help ciatest:ciatest}, and
{help getaway:getaway}. More information can be found in the {browse "https://github.com/filippopalomba/getaway-package":official Github repository}.


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
{synopt:{opt k:ernel(string)}}  specifies the kernel function. The default is {cmd:kernel(}{it:epanechnikov}{cmd:)}. See kernel functions allowed in {help lpoly}.

{pstd}
{p_end}
{synopt:{opt site(varname)}}  specifies the variable identifying the site to add site fixed effects.

{pstd}
{p_end}
{synopt:{opt d:egree(#)}}  specifies the degree of the local polynomial smooth. The default is {cmd: degree(0)}.

{pstd}
{p_end}
{synopt:{opt nb:ins(numlist)}}  specifies the number of bins for which the counterfactual average is shown in the final graph. Default is {cmd:nbins(10 10)}.

{pstd}
{p_end}
{synopt:{opt clevel(#)}}  specifies the confidence level for the confidence bands reported in the plot. Default is {cmd:clevel(95)}.

{pstd}
{p_end}
{synopt:{opt nostderr}}  if specified standard errors are not computed and plotted.

{pstd}
{p_end}
{synopt:{opt gphoptions(string)}}  specifies graphical options to be passed on to the underlying graph command.

{pstd}
{p_end}
{synopt:{opt scatterplotopt(string)}} specifies graphical options to be passed on to the underlying scatter plot.

{pstd}
{p_end}
{synopt:{opt lineplotopt(string)}} specifies graphical options to be passed on to the underlying line plot for observed potential outcomes.

{pstd}
{p_end}
{synopt:{opt lineCFplotopt(string)}} specifies graphical options to be passed on to the underlying line plot for counterfactual potential outcomes.

{pstd}
{p_end}
{synopt:{opt areaplotopt(string)}} specifies graphical options to be passed on to the underlying confidence bands plot.

{pstd}
{p_end}
{synopt:{opt legendopt(string)}} specifies graphical options to be passed on to the underlying plot legend.

    {hline}


{marker examples}{...}
{title:Example: Simulated Data}

{p 4 8}Setup{p_end}
{p 8 8}{cmd:use simulated_getawayplot.dta}{p_end}

{p 4 8}Prepare data{p_end}
{p 8 8}{cmd:generate X2 = X^2}{p_end}
{p 8 8}{cmd:generate interaction = X*T}{p_end}
{p 8 8}{cmd:generate interaction2 = X2*T}{p_end}
{p 8 8}{cmd:generate w1sq = w1^2}{p_end}
{p 8 8}{cmd:generate w2sq = w2^2}{p_end}
{p 8 8}{cmd:generate w2Xw1 = w2*w1}{p_end}

{p 4 8}Estimate Potential Outcomes{p_end}
{p 8 8}{cmd:getawayplot w1 w2 w1sq w2sq w2Xw1, o(Y) s(X) c(0) b(7) k(triangle) d(2) nb(30) site(site) gphoptions(xlabel(-6(3)6))
}{p_end}

{marker references}{...}
{title:References}

{p 4 8}Angrist, Joshua D., and Miikka Rokkanen. {browse "https://economics.mit.edu/files/10851":Wanna get away? Regression discontinuity estimation of exam school effects away from the cutoff.} 
{it:Journal of the American Statistical Association} 110.512 (2015): 1331-1344.{p_end}

{marker authors}{...}
{title:Authors}

{p 4 8}Filippo Palomba, Princeton University, Princeton, NJ.
{browse "mailto:fpalomba@princeton.edu":fpalomba@princeton.edu}.
