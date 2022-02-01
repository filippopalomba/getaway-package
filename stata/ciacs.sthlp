{smcl}
{* *! version 1.0 17 Jan 2022}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "ciacs##syntax"}{...}
{viewerjumpto "Description" "ciacs##description"}{...}
{viewerjumpto "Options" "ciacs##options"}{...}
{viewerjumpto "Remarks" "ciacs##remarks"}{...}
{viewerjumpto "Examples" "ciacs##examples"}{...}
{title:Title}
{phang}
{bf:ciacs} {hline 2} Verify graphically the common support condition for heterogeneous treatment effect estimation in RDD.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:ciacs}
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
{synopt:{opt pscore(string)}}  specifies the name of the variable containing the pscore. This variable is added to the current dataset.

{pstd}
{p_end}
{synopt:{opt probit}}  implements a probit model to estimate the pscore.

{pstd}
{p_end}
{synopt:{opt kd:ensity}}  displays kernel densities rather than histograms, which is the default.

{pstd}
{p_end}
{synopt:{opt nog:raph}}  suppresses any graphical output.

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:getawaycs} allows to visualize the common support condition to validate estimation of treatment effects away from the cutoff in a Regression Discontinuity framework as proposed in 
Angrist and Rokkanen (2015).

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt o:utcome(varname)}     specifies the dependent variable of interest. This option is used just to mark the sample on which the pscore is estimated.

{pstd}
{p_end}
{phang}
{opt a:ssign(varname)}     sets the assignment to treatment variable.

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
{opt nb:ins(#)}     number of bins of the common support histogram. Default is {cmd:nbins(10 10)}.

{pstd}
{p_end}
{phang}
{opt site(varname)}     specifies the variable identifying the site to add site fixed effects.

{pstd}
{p_end}
{phang}
{opt asis}     forces retention of perfect predictor variables and their associated perfectly predicted observations.

{pstd}
{p_end}
{phang}
{opt gphoptions(string)}     specifies graphical options to be passed on to the underlying graph command.

{pstd}
{p_end}
{phang}
{opt pscore(string)}     specifies the name of the variable containing the pscore. This variable is added to the current dataset.

{pstd}
{p_end}
{phang}
{opt probit}     implements a probit model to estimate the pscore.

{pstd}
{p_end}
{phang}
{opt kd:ensity}     displays kernel densities rather than histograms, which is the default.

{pstd}
{p_end}
{phang}
{opt nog:raph}     suppresses any graphical output.

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}

{pstd}
The example below show how to correctly use the command {cmd:ciacs} to visualize the common support condition. 
Suppose that we have at hand an {it:outcome} variable, a {it:score} variable that induces assignment to treatment ({it:assign}) 
and a set of K covariates ({it:varlist}) that makes the running variable ignorable. For the sake of the example assume the bandwidth 
to be 10 and the cutoff to be 0. To verify the common support condition graphically, then

{pstd}
{cmd:ciacs cov1 cov2 ... covK, o(outcome) a(assign) s(score) b(10)}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(CSmin)}}  {p_end}
{synopt:{cmd:r(CSmax)}}  {p_end}


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
{synopt:{help ciatest} (if installed)}   {stata ssc install ciatest}     (to install) {p_end}
{synopt:{help getaway} (if installed)} {stata ssc install getaway}   (to install) {p_end}
{synopt:{help getawayplot}  (if installed)}   {stata ssc install getawayplot}      (to install) {p_end}

{p2colreset}{...}

