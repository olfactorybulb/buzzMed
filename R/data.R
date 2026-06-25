#' Single Spike Data
#'
#' A simulated dataset for demonstrating Bayesian mediation analysis.
#'
#' @format A data frame with 300 rows and 22 variables:
#' \describe{
#'   \item{x}{Predictor variable.}
#'   \item{m1}{Candidate mediator 1.}
#'   \item{m2}{Candidate mediator 2.}
#'   \item{m3}{Candidate mediator 3.}
#'   \item{m4}{Candidate mediator 4.}
#'   \item{m5}{Candidate mediator 5.}
#'   \item{m6}{Candidate mediator 6.}
#'   \item{m7}{Candidate mediator 7.}
#'   \item{m8}{Candidate mediator 8.}
#'   \item{m9}{Candidate mediator 9.}
#'   \item{m10}{Candidate mediator 10.}
#'   \item{m11}{Candidate mediator 11.}
#'   \item{m12}{Candidate mediator 12.}
#'   \item{m13}{Candidate mediator 13.}
#'   \item{m14}{Candidate mediator 14.}
#'   \item{m15}{Candidate mediator 15.}
#'   \item{m16}{Candidate mediator 16.}
#'   \item{m17}{Candidate mediator 17.}
#'   \item{m18}{Candidate mediator 18.}
#'   \item{m19}{Candidate mediator 19.}
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
