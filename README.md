# buzzMed v0.1.4

**Bayesian Mediation Analysis with Variable Selection**

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Overview

**buzzMed** is an R package for Bayesian mediation analysis. It provides tools for exploratory Bayesian mediation models with Bayesian variable selection, supporting continuous and binary mediators and outcomes. The package also includes a longitudinal Bayesian mediation model for repeated-measures data.

### Features

- Exploratory Bayesian mediation analysis with variable selection
- Continuous or binary (0/1) mediators
- Continuous or binary (0/1) outcomes
- Multiple predictors and candidate mediators
- Formula-based model specification
- Longitudinal Bayesian mediation for repeated-measures data

---

## Requirements

This package requires **JAGS (Just Another Gibbs Sampler)** to be installed on your system.

Download JAGS from:

https://mcmc-jags.sourceforge.io/

---

## Installation

Install the development version from GitHub:

```r
# install.packages("remotes")
remotes::install_github("olfactorybulb/buzzMed")

library(buzzMed)
```

---

## Main Functions

### Generalized Two-stage(GT) exploratory Bayesian mediation model

The package provides four functions for exploratory Bayesian mediation analysis based on the mediator and outcome variable types.

| Function | Mediator | Outcome |
|----------|----------|---------|
| `buzzEBMcontMcontY()` | Continuous | Continuous |
| `buzzEBMcontMcatY()` | Continuous | Binary |
| `buzzEBMcatMcontY()` | Binary | Continuous |
| `buzzEBMcatMcatY()` | Binary | Binary |

### Longitudinal Bayesian Mediation

- `longBMed()` fits a Bayesian mediation model for repeated-measures data with one or more predictors, multiple candidate mediators, and a continuous outcome.

---

## Example Usage

### GT-Exploratory Bayesian Mediation

```r
library(buzzMed)

# Create toy data
my_data <- data.frame(
  MyPredictor = rnorm(30),
  MyMediator1 = rnorm(30),
  MyMediator2 = rnorm(30),
  MyOutcome = rnorm(30)
)

# Fit the model
fit <- buzzEBMcontMcontY(
  model = "MyOutcome ~ MyPredictor | MyMediator1 + MyMediator2",
  dataset = my_data
)
```

### Longitudinal Bayesian Mediation

```r
library(buzzMed)

# Load the example longitudinal dataset
data(sublongspikes)

# Fit the longitudinal Bayesian mediation model
# For model specification, slice 1 is the predictor, slices 2--20 are candidate mediators, and slice 21 is the outcome.
# n.burnin and n.iter are optional arguments
results <- longBMed(
  model = "21 ~ 1 | 2:20",
  data = sublongspikes,
  n.burnin = 100,
  n.iter = 500
)

summary(results)
```

---

## Included Example Datasets

- `singlespikes`: Cross-sectional mediation dataset containing one predictor, nineteen candidate mediators, and one outcome.
- `sublongspikes`: Longitudinal mediation dataset stored as a three-dimensional array for repeated-measures analysis with `longBMed()`.
- `framing2`: A modified version of the `framing` dataset from the `mediation` package containing dichotomized candidate mediators for demonstrating the GT-exploratory Bayesian mediation functions.

---

## Citation

If you use **buzzMed** in your research, please cite:

> Shi, D., Shi, D., & Fairchild, A. J. (2023). *Variable Selection for Mediators under a Bayesian Mediation Model*. *Structural Equation Modeling: A Multidisciplinary Journal*, 30(6), 887–900. https://doi.org/10.1080/10705511.2022.2164285

---

## License

This project is licensed under the **GNU General Public License v3.0**.

See the `LICENSE` file for details.
