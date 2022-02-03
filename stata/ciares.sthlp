{smcl}
{* *!version 0.1 2022-01-25}{...}
{viewerjumpto "Syntax" "##syntax"}{...}
{viewerjumpto "Description" "ciares##description"}{...}
{viewerjumpto "Options" "ciares##options"}{...}
{viewerjumpto "Examples" "ciares##examples"}{...}
{viewerjumpto "Stored results" "ciares##stored_results"}{...}
{viewerjumpto "References" "ciares##references"}{...}
{viewerjumpto "Authors" "ciares##authors"}{...}

{title:Title}

{p 4 8}{cmd:ciares} {hline 2} Verify graphically the conditional independence assumption in Regression Discontinuity designs.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:ciares } 
{cmd:{it:varlist}} (ts fv) [{help if}] [{help in}], 
{cmd:outcome(}{it:outcomevar}{cmd:)} 
{cmd:score(}{it:scorevar}{cmd:)}
{cmd:bandwidth(}{it:string}{cmd:)}
[{cmd:cutoff(}{it:#}{cmd:)}  
{cmd:nbins(}{it:numlist}{cmd:)}
{cmd:site(}{it:varname}{cmd:)}
{cmd:gphoptions(}{it:string}{cmd:)}
{cmd:cmpr(}{it:numlist}{cmd:)}]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:ciares} allows to visualize the conditional independence assumption of the running variable given a certain set of covariates 
in a Regression Discontinuity framework as proposed in {browse "https://economics.mit.edu/files/10851":Angrist and Rokkanen (2015)}.{p_end}

{p 4 8}The command {cmd:ciares} plots the residuals of the regression of {it:outcome} on a constant and {it:varlist} against the running variable. 
If the CIA condition holds, then the plot should approximate a flat line. {p_end}

{p 4 8} This command belongs to the {cmd:getaway} package. Companion commands are {help ciatest:ciatest}, {help ciasearch:ciasearch}, {help ciacs:ciacs}, {help getaway:getaway}, and
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
{synopt:{opt nb:ins(numlist)}}  specifies the number of bins in which the average of residuals should be computed. The number of bins can be specified for each side of 
	the cutoff. Default is {cmd:nbins(10 10)}.

{pstd}
{p_end}
{synopt:{opt site(varname)}}  specifies the variable identifying the site to add site fixed effects.

{pstd}
{p_end}
{synopt:{opt gphoptions(string)}} specifies graphical options to be passed on to the underlying graph command.

{pstd}
{p_end}
{synopt:{opt cmpr(numlist)}} adds the conditional regression function of {cmd: outcome} on the {cmd: score}. The form of polynomials on the left and on the right can be modelled independently - 
eg. {cmd: cmpr(2 3)} for a second order polynomial on the left and a third order on the right.

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

{p 4 8}Test the CIA{p_end}
{p 8 8}{cmd:ciares w1 w2 w1sq w2sq w2Xw1, o(Y) s(X) b(7) site(site) nb(10 10)}{p_end}

{marker references}{...}
{title:References}

{p 4 8}Angrist, Joshua D., and Miikka Rokkanen. {browse "https://economics.mit.edu/files/10851":Wanna get away? Regression discontinuity estimation of exam school effects away from the cutoff.} 
{it:Journal of the American Statistical Association} 110.512 (2015): 1331-1344.{p_end}

{marker authors}{...}
{title:Authors}

{p 4 8}Filippo Palomba, Princeton University, Princeton, NJ.
{browse "mailto:fpalomba@princeton.edu":fpalomba@princeton.edu}.

