{smcl}
{* *!version 0.1 2022-01-25}{...}
{viewerjumpto "Syntax" "ciatest##syntax"}{...}
{viewerjumpto "Description" "ciatest##description"}{...}
{viewerjumpto "Options" "ciatest##options"}{...}
{viewerjumpto "Examples" "ciatest##examples"}{...}
{viewerjumpto "Stored results" "ciatest##stored_results"}{...}
{viewerjumpto "References" "ciatest##references"}{...}
{viewerjumpto "Authors" "ciatest##authors"}{...}

{title:Title}

{p 4 8}{cmd:ciatest} {hline 2} Test for ignorability of the running variable in a Regression Discontinuity framework.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:ciatest } 
{cmd:{it:varlist}} (ts fv) [{help if}] [{help in}], 
{cmd:outcome(}{it:outcomevar}{cmd:)} 
{cmd:score(}{it:scorevar}{cmd:)}
{cmd:bandwidth(}{it:string}{cmd:)}
[{cmd:cutoff(}{it:#}{cmd:)}  
{cmd:poly(}{it:numlist}{cmd:)}
{cmd:robust}
{cmd:vce(}{it:varname}{)}
{cmd:site(}{it:varname}{)}
{cmd:alpha(}{it:#}{)}
{cmd:details}
{cmd:noise}]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:ciatest} tests whether the set of candidate variables ({it:varlist}) makes the running variable ignorable on the two sides of the cutoff. This 
test validates the use of the extrapolating procedure developed by Angrist and Rokkanen (2015) in a Regression Discontinuity framework.{p_end}

{p 4 8 }The main testing procedure runs two separate regressions of {it:outcomevar} on a constant, {it:varlist} and {it:scorevar} on the left and on the right of the cutoff.
The table named "CIA Test Results" displays the results of the test for the null of the coefficient of {it:scorevar} being equal to 0. The CIA condition
holds if there is not enough evidence to reject the null of the coefficient of {it:scorevar} being equal to 0 both on the left and on the right of the 
cutoff. Notice that if the user specifies a higher order polynomial in {opt poly}, then a F-test on the null hypothesis that {it:scorevar} and its corresponding 
higher order terms are jointly equal to 0.{p_end}

{p 4 8}If {cmd: details} is specified, then {cmd:ciatest} runs two additional sets of regressions:{p_end}

{p 8 8}i) Original Regression: it is the simple linear regression of {it:outcomevar} on {it:scorevar}. {cmd:ciatest} runs the regression separately on the left and on the right of the cutoff.
It allows to see the original coefficient (i.e. in the full sample) of the running variable;{p_end}

{p 8 8 }ii) Original Regression - Restricted Sample: it is the simple linear regression of {it:outcomevar} on {it:scorevar} using the same observations as in the main 
testing regression. {cmd:ciatest} runs the regression separately on the left and on the right of the cutoff. Notice that ii) will produce a different outcome than i) only if some
of the variables in {it:varlist} contain missing values. For this reason, it is a useful robustness check when there are missing values in the sample. 
Indeed, comparing the results in the main table with the ones in ii) allows to distinguish between the case in which a non-significant coefficient of {it:scorevar} 
is driven by the variables in {it:varlist} or  by missing values. In the latter case, it would not be possible to claim that the variables contained in {it:varlist} 
validate the CIA assumption.{p_end}


{marker options}{...}
{title:Options}

{synoptset 28 tabbed}{...}
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

{pstd}
{p_end}
{synopt:{opt d:etails}}  reports results of additional tests in the output. The {cmd:details} option reports the main statistics of the simple regression of {cmd:outcome} on {cmd:score} 
in both the full-sample and the restricted-sample. The restricted-sample is the sample composed by all units with no missing values in {cmd:outcome}, {cmd:score}, and {it:varlist}, whilst the full-sample
is defined as those units with no missing entries just in {cmd:outcome} and {cmd:score}. This additional check is particularly useful when there are missing values in {it:varlist}.]
opt[noise prints all testing regression outputs.

{pstd}
{p_end}
{synopt:{opt n:oise}}  prints all testing regression outputs.

    {hline}


{marker examples}{...}
{title:Example: Simulated Data}

{p 4 8}Setup{p_end}
{p 8 8}{cmd:. use simulated_getaway.dta}{p_end}

{p 4 8}Prepare data{p_end}
{p 8 8}{cmd:. generate X2 = X^2}{p_end}
{p 8 8}{cmd:. generate interaction = X*T}{p_end}
{p 8 8}{cmd:. generate interaction2 = X2*T}{p_end}
{p 8 8}{cmd:. generate w1sq = w1^2}{p_end}
{p 8 8}{cmd:. generate w2sq = w2^2}{p_end}
{p 8 8}{cmd:. generate w2Xw1 = w2*w1}{p_end}

{p 4 8}Test the CIA{p_end}
{p 8 8}{cmd:. ciatest w1 w2 w1sq w2sq w2Xw1, o(Y) s(X) c(0) b(7) p(2) site(site)}{p_end}


{p 4 8}The examples below show how to correctly use the command {cmd:ciatest} to check whether the CIA holds or not. Suppose that we have at hand an
{it:outcome} variable, a {it:score} variable, and a set of K covariates ({it:varlist}). We would like to know whether {it:varlist} makes {it:score}
ignorable, i.e. makes CIA hold. To do so, it is enough to run (for the sake of the example assume the bandwidth to be 10 and the cutoff to be 0){p_end}

{p 8 8}{cmd:ciatest cov1 cov2 ... covK, o(outcome) s(score) b(10)}{p_end}

{p 4 8}If we suspect that there is either heteroskedasticity or intra-cluster correlation in the residuals, then{p_end}

{p 8 8}{cmd:ciatest cov1 cov2 ... covK, o(outcome) s(score) b(10) robust}{p_end}

{p 8 8}{cmd:ciatest cov1 cov2 ... covK, o(outcome) s(score) b(10) vce(clustervar)}{p_end}

{p 4 8}If, in addition, we are pooling together different rankings, then we should add fixed effects at the ranking level{p_end}

{p 8 8}{cmd:ciatest cov1 cov2 ... covK, o(outcome) s(score) b(10) vce(clustervar) site(ranking)}{p_end}

{p 4 8}If we suspect that the coefficient of {it:score} is not significant just because of missing values in {it:varlist}, then{p_end}

{p 8 8}{cmd:ciatest cov1 cov2 ... covK, o(outcome) s(score) b(10) vce(clustervar) site(ranking) details}{p_end}

{p 4 8}If we now want to fit a quadratic model on both sides, then{p_end}

{p 8 8}{cmd:ciatest cov1 cov2 ... covK, o(outcome) s(score) b(10) p(2) vce(clustervar) site(ranking) details}{p_end}

{p 4 8}If we want to fit a quadratic model on the left and a cubic model on the right, then{p_end}

{p 8 8}{cmd:ciatest cov1 cov2 ... covK, o(outcome) s(score) b(10) p(2 3) vce(clustervar) site(ranking) details}{p_end}




{marker stored_results}{...}
{title:Stored results}

{p 4 8}{cmd:scest} stores the following in {cmd:e()}:

{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(cia_test)}} matrix containing the results of the testing procedure as reported in the results window.{p_end}
{synopt:{cmd:e(cia_test2)}} matrix containing the results of the Original Regression - Full Sample if the option {it:details} is specified.{p_end}
{synopt:{cmd:e(cia_test3)}} a matrix containing the results of the Original Regression - Restricted Sample if the option {it:details} is specified.{p_end}

{marker references}{...}
{title:References}

{p 4 8}Angrist, Joshua D., and Miikka Rokkanen. {browse "https://economics.mit.edu/files/10851":Wanna get away? Regression discontinuity estimation of exam school effects away from the cutoff.} 
{it:Journal of the American Statistical Association} 110.512 (2015): 1331-1344.{p_end}

{marker authors}{...}
{title:Authors}

{p 4 8}Filippo Palomba, Princeton University, Princeton, NJ.
{browse "mailto:fpalomba@princeton.edu":fpalomba@princeton.edu}.

