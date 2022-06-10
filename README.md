# Getaway - RD Treatment Effects away from the cutoff

This repository hosts the Stata `getaway package` that implements point estimation and inference away from the cutoff in Regression Discontinuity (RD) designs as proposed in [Angrist and Rokkanen (2015)](https://economics.mit.edu/files/10851).

Angrist and Rokkanen (2015) exploit additional information contained in explanatory variables other than the score to estimate treatment effects away from the cutoff. The only assumption needed is a \`_conditional independence assumption_'' (CIA), which requires mean independence between potential outcomes and the score variable conditional on a vector of other covariates, together with a common support condition. Moreover, the CIA has implications that can be tested with standard hypothesis tests.

The <tt>getaway</tt> allows user to estimates treatment effects away from the cutoff in the general framework of RD with multiple cutoffs following [Fort, Ichino, Rettore, and Zanella (2022)](http://www.andreaichino.it/wp-content/uploads/FIRZ_Stacking.pdf). The package contains six different commands: 
1. <tt>ciasearch</tt> applies a data-driven algorithm that selects a set of covariates to ``get away'' from the cutoff, thus allowing for extrapolation of treatment effects
2. <tt>ciatest</tt> tests the CIA assumption for a given set of covariates 
3. <tt>ciares</tt> visualizes the CIA mean independence assumption
4. <tt>ciacs</tt> produces graphical visualizations of the CIA common support assumption
5. <tt>getaway</tt> estimates parametrically treatment effects away from the cutoff
6. <tt>getawayplot</tt> shows estimated potential outcomes as functions of the score variable

More information on how to use each command can be found in the article contained in this repo.

## Installation
To install/update in Stata type

```
net install getaway, from("https://raw.githubusercontent.com/filippopalomba/getaway-package/main/stata") replace force 
```


## Structure of this repository
- stata: folder containing .ado files, help files, and a simulated dataset
- article.pdf: software article
- generate_simulated_getaway.do: .do file to create the simulated dataset provided with the package


## Examples of papers using this package:
- [Cingano, Palomba, Pinotti, and Rettore (2022)](https://www.dropbox.com/s/naoxo4aal4woajd/L488_feb2022.pdf?dl=0) - "Making Subsidies Work: Rules vs. Discretion", working paper.



## References

- Angrist, Joshua D., and Miikka Rokkanen. "Wanna get away? Regression discontinuity estimation of exam school effects away from the cutoff." _Journal of the American Statistical Association_ 110, no. 512 (2015): 1331-1344.

- Fort, Margherita, Andrea Ichino, Enrico Rettore, and Giulio Zanella. "Multi-cutoff RD designs with observations located at each cutoff: problems and solutions". No. 0278. _Dipartimento di Scienze Economiche ``Marco Fanno''_, 2022.

- Le Cam, Lucien. Asymptotic methods in statistical decision theory. Springer Science & Business Media, 2012.
