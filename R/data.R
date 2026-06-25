#' Single Spike Data
#'
#' A simulated dataset for demonstrating Bayesian mediation analysis.
#'
#' @format A data frame with 300 rows and 22 variables:
#' \describe{
#'   \item{x}{Predictor variable.}
#'   \item{m1--m19}{Candidate mediators.}
#'   \item{y}{Outcome variable.}
#' }
#'
#' @details
#' The dataset contains one predictor, nineteen candidate mediators,
#' and one outcome variable.
#'
#' @usage data(singlespikes)
#'
#' @source Simulated data included with the \pkg{buzzMed} package.
"singlespikes"

#' Long Spike Data
#'
#' A simulated longitudinal dataset for demonstrating Bayesian mediation
#' analysis with repeated measurements.
#'
#' @format A numeric array with dimensions 300 × 25 × 21:
#' \describe{
#'   \item{Dimension 1 (N)}{300 observations.}
#'   \item{Dimension 2 (T)}{25 repeated measurements (time points).}
#'   \item{Dimension 3 (Variables)}{21 variables consisting of one predictor
#'   (X), 19 candidate mediators (M), and one outcome (Y).}
#' }
#'
#' @details
#' The third dimension stores the variables in the following order:
#' \enumerate{
#'   \item Slice 1: Predictor (X)
#'   \item Slices 2--20: Candidate mediators (M)
#'   \item Slice 21: Outcome (Y)
#' }
#'
#' @usage data(sublongspikes)
#'
#' @source Simulated data included with the \pkg{buzzMed} package.
"sublongspikes"
