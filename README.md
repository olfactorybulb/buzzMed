# buzzMed v0.1.3

**Exploratory Bayesian Mediation Analysis with Variable Selection**

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Overview

A collection of quantitative tools for selecting mediating effects within exploratory Bayesian mediation models. The package accommodates both continuous and dichotomous outcomes, including the dependent variables and the mediators for identifying and analyzing mediation pathways.

- **Multiple predictors and mediators**
- **Continuous or binary (0/1) mediators**
- **Continuous or binary (0/1) outcomes**
- **Automated model dispatch via formula syntax**

---

## Requirements

This package requires **JAGS (Just Another Gibbs Sampler)** to be installed on your system.
Download from: [https://mcmc-jags.sourceforge.io/](https://mcmc-jags.sourceforge.io/)

---

## Installation

You can install the development version from GitHub:

```r
# install.packages("remotes")
remotes::install_github("olfactorybulb/buzzMed")
library(buzzMed)
```

---

## Main Functions
The package provides a primary automated interface and four specialized model-fitting functions based on variable types:
- `buzzEBMcontMcontY()`: Continuous mediators, continuous outcome.
- `buzzEBMcontMcatY()`: Continuous mediators, binary outcome.
- `buzzEBMcatMcontY()`: Binary mediators, continuous outcome.
- `buzzEBMcatMcatY()`: Binary mediators, binary outcome.

---

## Example Usage
```r
library(buzzMed)

# Create some toy data to play with
my_data <- data.frame(
    MyPredictor = rnorm(30),
    MyMediator1 = rnorm(30),
    MyMediator2 = rnorm(30),
    MyOutcome = rnorm(30)
)

# Specify your mediation model using syntax 'Y ~ M1 + M2 | X'
model_string <- "MyOutcome ~ MyMediator1 + MyMediator2 | MyPredictor"

# Run the model with continuous mediator and continuous outcome
fit <- buzzEBMcontMcontY(model = model_string, dataset = my_data)
```

---

## Citation
If you use buzzMed in your research, please cite:

> Shi, D., Dexin Shi, & Amanda J. Fairchild (2023). Variable Selection for Mediators under a Bayesian Mediation Model. Structural Equation Modeling: A Multidisciplinary Journal, 30(6), 887-900. DOI: 10.1080/10705511.2022.2164285

---

## License
This project is licensed under the **GNU General Public License v3.0.**
See the `LICENSE` file for details.
