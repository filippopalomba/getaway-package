# Getaway Package

This repository hosts the Stata `getaway package` that implements point estimation and inference away from the cutoff in Regression Discontinuity (RD) designs as proposed in [Angrist and Rokkanen (2015)](https://economics.mit.edu/files/10851).

Angrist and Rokkanen (2015) exploit additional information contained in explanatory variables other than the score to estimate treatment effects away from the cutoff. The only assumption needed is a \`_conditional independence assumption_'' (CIA), which requires mean independence between potential outcomes and the score variable conditional on a vector of other covariates, together with a common support condition. Moreover, the CIA has implications that can be tested with standard hypothesis tests.

The <tt> getaway </tt> allows user to estimates treatment effects away from the cutoff in the general framework of RD with multiple cutoffs following [Fort, Ichino, Rettore, and Zanella (2022)](http://www.andreaichino.it/wp-content/uploads/FIRZ_Stacking.pdf). The package contains six different commands: 
1. <tt> ciasearch </tt> applies a data-driven algorithm that selects an adequate set of covariates to ``get away'' from the cutoff 
2. <tt> ciatest </tt> tests the CIA assumption for a given set of covariates 
3. <tt> ciares </tt> visualizes the CIA mean independence assumption
4. <tt> ciacs </tt> produces graphical visualizations of the CIA common support assumption
5. <tt> getaway </tt> estimates parametrically treatment effects away from the cutoff
6. <tt> getawayplot </tt> shows estimated potential outcomes as functions of the score variable

More information on how to use each command can be found in the article contained in this repo.