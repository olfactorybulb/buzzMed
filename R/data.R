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

#' Binarized Framing Dataset
#'
#' A modified version of the \code{framing} dataset from the
#' \pkg{mediation} package, originally based on the study by
#' Brader, Valentino, and Suhay (2008). The candidate mediators have
#' been dichotomized for use with the binary mediator models implemented
#' in \pkg{buzzMed}. The dataset contains 265 observations and 10 variables.
#'
#' @format A data frame with 265 rows and 10 variables:
#' \describe{
#'   \item{tone}{Binary treatment indicator denoting whether the news story
#'   was framed positively or negatively. Can be used as a predictor.}
#'
#'   \item{eth}{Binary treatment indicator denoting whether the news story
#'   featured a Latino or European immigrant. Can be used as a predictor.}
#'
#'   \item{treat}{Interaction of \code{tone} and \code{eth}. In the original
#'   study, this interaction represented the significant treatment effect.
#'   Can be used as a predictor.}
#'
#'   \item{emo}{Binary indicator of negative emotional response. A value of
#'   1 indicates an original score of 7 or lower, corresponding to stronger
#'   negative emotion. Can be used as a candidate mediator.}
#'
#'   \item{p_harm}{Binary indicator of perceived harm caused by increased
#'   immigration. A value of 1 indicates an original score of 6 or higher,
#'   corresponding to greater perceived harm. Can be used as a candidate
#'   mediator.}
#'
#'   \item{immigr}{Binary indicator derived from the original four-point
#'   immigration attitude scale. A value of 1 indicates an original score
#'   of 3 or 4, corresponding to more negative attitudes toward increased
#'   immigration. Can be used as a candidate mediator.}
#'
#'   \item{anx}{Binary indicator derived from the original four-point anxiety
#'   scale. A value of 1 indicates respondents who reported being
#'   ``very anxious'' or ``somewhat anxious'' about increased immigration.
#'   Can be used as a candidate mediator.}
#'
#'   \item{english}{Binary indicator derived from the original four-point
#'   scale measuring support for making English the official language of the
#'   United States. A value of 1 indicates respondents who selected
#'   ``Favor'' or ``Strongly Favor.'' Can be used as a candidate mediator.}
#'
#'   \item{cong_mesg}{Binary outcome indicating whether the respondent
#'   requested that an anti-immigration message be sent to Congress on
#'   their behalf.}
#'
#'   \item{anti_info}{Binary outcome indicating whether the respondent
#'   requested additional information from anti-immigration organizations.}
#' }
#'
#' @references
#' Brader, T., Valentino, N. A., & Suhay, E. (2008).
#' What Triggers Public Opposition to Immigration? Anxiety, Group Cues,
#' and Immigration Threat.
#' \emph{American Journal of Political Science}, 52(4), 959--978.
#'
#' @source
#' Adapted from the \code{framing} dataset in the \pkg{mediation} package.
#'
#' @docType data
#' @name framing2
#' @keywords datasets
"framing2"
