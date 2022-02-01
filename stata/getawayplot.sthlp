{smcl}
{* *! version 1.0 17 Jan 2022}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "getawayplot##syntax"}{...}
{viewerjumpto "Description" "getawayplot##description"}{...}
{viewerjumpto "Options" "getawayplot##options"}{...}
{viewerjumpto "Remarks" "getawayplot##remarks"}{...}
{viewerjumpto "Examples" "getawayplot##examples"}{...}
{title:Title}
{phang}
{bf:getawayplot} {hline 2} Plot non-parametric extrapolation of treatment effect.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:getawayplot}
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
{synopt:{opt k:ernel(string)}}  specifies the kernel function. The default is {cmd:kernel(}{it:epanechnikov}{cmd:)}. See kernel functions allowed in {help lpoly}.

{pstd}
{p_end}
{synopt:{opt site(varname)}}  specifies the variable identifying the site to add site fixed effects.

{pstd}
{p_end}
{synopt:{opt d:egree(#)}}  specifies the degree of the local polynomial smooth. The default is {cmd: degree(0)}.

{pstd}
{p_end}
{synopt:{opt nb:ins(numlist max=2  integer)}}  specifies the number of bins for which the counterfactual average is shown in the final graph. Default is {cmd:nbins(10 10)}.

{pstd}
{p_end}
{synopt:{opt gphoptions(string)}}  specifies graphical options to be passed on to the underlying graph command.

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:getawayplot} plots non-parametric estimates of the actual and counterfactual regression functions using the methodology discussed in 
Angrist and Rokkanen (2015) in a Regression Discontinuity framework. The command relies on {help lpoly} to get smooth estimates of the two
potential outcomes. Then, it jointly plots the actual smoothed regression function and the counterfactual smoothed regression function together
with within-bin averages of the counterfactual outcome to show the fit of the non-parametric estimates. 

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
{opt k:ernel(string)}     specifies the kernel function. The default is {cmd:kernel(}{it:epanechnikov}{cmd:)}. See kernel functions allowed in {help lpoly}.

{pstd}
{p_end}
{phang}
{opt site(varname)}     specifies the variable identifying the site to add site fixed effects.

{pstd}
{p_end}
{phang}
{opt d:egree(#)}     specifies the degree of the local polynomial smooth. The default is {cmd: degree(0)}.

{pstd}
{p_end}
{phang}
{opt nb:ins(numlist max=2  integer)}     specifies the number of bins for which the counterfactual average is shown in the final graph. Default is {cmd:nbins(10 10)}.

{pstd}
{p_end}
{phang}
{opt gphoptions(string)}     specifies graphical options to be passed on to the underlying graph command.

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}

{pstd}
The example below show how to correctly use the command {cmd:getawayplot} to plot actual and counterfactual regression functions. 
Suppose that we have at hand an {it:outcome} variable, a {it:score} variable and a set of K covariates ({it:varlist}) that makes the running variable
ignorable. For the sake of the example assume the bandwidth to be 10 and the cutoff to be 0. To plot the regression functions, then

{pstd}
{cmd:getawayplot cov1 cov2 ... covK, o(outcome) s(score) b(10) path({it:saving_location.format})}

{pstd}


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
{synopt:{help ciatest}  (if installed)}   {stata ssc install ciatest}      (to install) {p_end}
{synopt:{help getaway} (if installed)} {stata ssc install getaway}   (to install) {p_end}

{p2colreset}{...}

