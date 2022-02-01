{smcl}
{* *! version 1.0 17 Jan 2022}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "ciares##syntax"}{...}
{viewerjumpto "Description" "ciares##description"}{...}
{viewerjumpto "Options" "ciares##options"}{...}
{viewerjumpto "Remarks" "ciares##remarks"}{...}
{viewerjumpto "Examples" "ciares##examples"}{...}
{title:Title}
{phang}
{bf:ciares} {hline 2} Verify graphically the conditional independence assumption.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:ciares}
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
{synopt:{opt nb:ins(numlist)}}  specifies the number of bins in which the average of residuals should be computed. The number of bins can be specified for each side of 
	the cutoff. Default is {cmd:nbins(10 10)}.
{p_end}
{synopt:{opt site(varname)}}  specifies the variable identifying the site to add site fixed effects.

{pstd}
{p_end}
{synopt:{opt gphoptions(string)}}  specifies graphical options to be passed on to the underlying graph command.

{pstd}
{p_end}
{synopt:{opt cmpr(numlist max=2  integer)}}  adds the conditional regression function of {\cmd: outcome} on the {\cdm: score}. The form of polynomials on the left and on the right can be modelled independently - eg. {\cmd: cmpr(2 3)} for a second order polynomial on the left and a third order on the right.

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:ciares} allows to visualize the conditional independence assumption of the running variable given a certain set of covariates 
in a Regression Discontinuity framework as proposed in Angrist and Rokkanen (2015).

{pstd}
The command {cmd:ciares} plots the residuals of the regression of {it:outcome} on a constant and {it:varlist} against the running variable. 
If the CIA condition holds, then the plot should approximate a flat line. 

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
{opt nb:ins(numlist)}     specifies the number of bins in which the average of residuals should be computed. The number of bins can be specified for each side of 
	the cutoff. Default is {cmd:nbins(10 10)}.
{p_end}
{phang}
{opt site(varname)}     specifies the variable identifying the site to add site fixed effects.

{pstd}
{p_end}
{phang}
{opt gphoptions(string)}     specifies graphical options to be passed on to the underlying graph command.

{pstd}
{p_end}
{phang}
{opt cmpr(numlist max=2  integer)}     adds the conditional regression function of {\cmd: outcome} on the {\cdm: score}. The form of polynomials on the left and on the right can be modelled independently - eg. {\cmd: cmpr(2 3)} for a second order polynomial on the left and a third order on the right.

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}

{pstd}
The example below show how to correctly use the command {cmd:ciares}. Suppose that we have at hand an {it:outcome} variable, a {it:score} variable and a set of K covariates ({it:varlist}) that makes the running variable
ignorable. For the sake of the example assume the bandwidth to be 10 and the cutoff to be 0. To visualize the conditional independence assumption, then

{pstd}
{cmd:ciares cov1 cov2 ... covK, o(outcome) s(score) b(10)}

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
{synopt:{help ciatest} (if installed)}   {stata ssc install ciatest} (to install) {p_end}
{synopt:{help ciacs} (if installed)}   {stata ssc install ciacs}     (to install) {p_end}
{synopt:{help getaway} (if installed)} {stata ssc install getaway}   (to install) {p_end}
{synopt:{help getawayplot}  (if installed)}   {stata ssc install getawayplot}      (to install) {p_end}

{p2colreset}{...}

