# Getaway - RD Treatment Effects away from the cutoff

This repository hosts the Stata `getaway package` that implements point estimation and inference away from the cutoff in Regression Discontinuity (RD) designs as proposed in [Angrist and Rokkanen (2015)](https://doi.org/10.1080/01621459.2015.1012259). Moreover, it contains the file to generate the data and replicates the figures in [Palomba (2024)](https://filippopalomba.github.io/docs/Palomba_2024_getaway_SJ.pdf).

Angrist and Rokkanen (2015) exploit additional information contained in explanatory variables other than the score to estimate treatment effects away from the cutoff. The only assumption needed is a \`_conditional independence assumption_'' (CIA), which requires mean independence between potential outcomes and the score variable conditional on a vector of other covariates, together with a common support condition. Moreover, the CIA has implications that can be tested with standard hypothesis tests.

The `getaway` allows user to estimates treatment effects away from the cutoff in the general framework of RD with multiple cutoffs following [Fort, Ichino, Rettore, and Zanella (2025)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4114595). The package contains six different commands:

1. `ciasearch` applies a data-driven algorithm that selects a set of covariates to ``get away'' from the cutoff, thus allowing for extrapolation of treatment effects
2. `ciatest` tests the CIA assumption for a given set of covariates
3. `ciares` visualizes the CIA mean independence assumption
4. `ciacs` produces graphical visualizations of the CIA common support assumption
5. `getaway` estimates parametrically treatment effects away from the cutoff
6. `getawayplot` shows estimated potential outcomes as functions of the score variable

More information on how to use each command can be found in the article and in the replication file contained in this repo.

If you spot any bug/inconsistencies or simply would like to give feedback or chat about the package just reach out!

## Installation

To install/update in Stata type

```
net install getaway, from("https://raw.githubusercontent.com/filippopalomba/getaway-package/main/stata") replace force 
```

## Structure of this repository

- stata: folder containing .ado files, help files, and a simulated dataset
- [getaway-software_article.pdf](https://filippopalomba.github.io/docs/Palomba_2024_getaway_SJ.pdf): software article
- [generate-dataPalomba2024.do](https://github.com/filippopalomba/getaway-package/blob/main/generate-dataPalomba2024.do) : .do file to create the simulated dataset provided with the package
- [replicationPalomba2024.do](https://github.com/filippopalomba/getaway-package/blob/main/replication-Palomba2024.do): walkthrough the main functionalities of the package
- [MCconsistency.do](https://github.com/filippopalomba/getaway-package/blob/main/MCconsistency.do): proof by Monte-Carlo of A&R unbiasedness with simulated data

## Examples of papers using this package:

- [Cingano, Palomba, Pinotti, and Rettore (2025)](https://doi.org/10.3982/ECTA21319) - "Making Subsidies Work: Rules versus Discretion", _Econometrica_, 93, 3, pp. 747-778.
- [Carlana, Chiuri, Miglino, and Tincani (2026)](https://michelacarlana.com/wp-content/uploads/2026/07/PACE_NBER_updated.pdf) - "How Far Can Inclusion Go? The Long-term Impacts of Preferential College Admissions", working paper.

## References

- Angrist, Joshua D., and Miikka Rokkanen. "[Wanna get away? Regression discontinuity estimation of exam school effects away from the cutoff](https://doi.org/10.1080/01621459.2015.1012259)". _Journal of the American Statistical Association_ 110, no. 512 (2015): 1331-1344.
- Fort, Margherita, Andrea Ichino, Enrico Rettore, and Giulio Zanella. "[Multi-cutoff RD designs with observations located at each cutoff: problems and solutions](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4114595)". Working paper, 2025.
- Palomba, Filippo. "[Getting away from the cutoff in regression discontinuity designs](https://doi.org/10.1177/1536867X241276108)". _Stata Journal_, 24, 3, pp. 371-401, 2024.
