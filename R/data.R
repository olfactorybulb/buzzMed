#' Rate of action potential (i.e. firing rate) across neurons and repetitions.
#'
#' The average rate of action potentials over the observation period
#' (i.e. 2500 ms) is provided per neuron (N:20) across repetitions (n: 300),
#' yielding a single average firing rate value for each neuron.
#'
#' @format A data frame with 300 observations and 21 variables:
#' \describe{
#'   \item{x}{Predictor variable. External Current.}
#'   \item{m1}{Candidate mediator 1. Average action potential of neuron 1.}
#'   \item{m2}{Candidate mediator 2. Average action potential of neuron 2.}
#'   \item{m3}{Candidate mediator 3. Average action potential of neuron 3.}
#'   \item{m4}{Candidate mediator 4. Average action potential of neuron 4.}
#'   \item{m5}{Candidate mediator 5. Average action potential of neuron 5.}
#'   \item{m6}{Candidate mediator 6. Average action potential of neuron 6.}
#'   \item{m7}{Candidate mediator 7. Average action potential of neuron 7.}
#'   \item{m8}{Candidate mediator 8. Average action potential of neuron 8.}
#'   \item{m9}{Candidate mediator 9. Average action potential of neuron 9.}
#'   \item{m10}{Candidate mediator 10. Average action potential of neuron 10.}
#'   \item{m11}{Candidate mediator 11. Average action potential of neuron 11.}
#'   \item{m12}{Candidate mediator 12. Average action potential of neuron 12.}
#'   \item{m13}{Candidate mediator 13. Average action potential of neuron 13.}
#'   \item{m14}{Candidate mediator 14. Average action potential of neuron 14.}
#'   \item{m15}{Candidate mediator 15. Average action potential of neuron 15.}
#'   \item{m16}{Candidate mediator 16. Average action potential of neuron 16.}
#'   \item{m17}{Candidate mediator 17. Average action potential of neuron 17.}
#'   \item{m18}{Candidate mediator 18. Average action potential of neuron 18.}
#'   \item{m19}{Candidate mediator 19. Average action potential of neuron 19.}
#'   \item{y}{Outcome variable. Average action potential of neuron 20.}
#' }
#'
#' @details
#' The dataset contains one predictor, nineteen candidate mediators,
#' and one outcome variable.
#'
#' @usage data(singlespikes)
#'
#' @source Time-averaged neural spiking data included with the \pkg{buzzMed} package.
"singlespikes"

#' A subset in time of longitudinal spike train data.
#'
#' For each neuron across all repetitions, the time series that describe
#' whether or not a neuron generated action potential is provided. This
#' is a subset of the full data matrix where the temporal index starts
#' at 1002 ms and continues until 1026 ms.
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
#' @source Longitudinal spiking train data included with the \pkg{buzzMed} package.
"sublongspikes"

#' Modified framing dataset
#'
#' A modified version of the \code{framing} dataset from the
#' \pkg{mediation} package, originally based on the study by
#' Brader, Valentino, and Suhay (2008). The dataset contains selected variables
#' from the original \code{framing} dataset and numeric recodings of
#' \code{english}, \code{anx}, and \code{educ}.
#' The dataset contains 265 observations and 11 variables.
#'
#' @format A data frame with 265 observations and 11 variables:
#' \describe{
#'   \item{treat}{Product of the two treatment variables. In the original study
#'   the authors only find this cell to be significant.}
#'
#'   \item{age}{Subjects' age.}
#'
#'   \item{gender}{Subjects' gender.}
#'
#'   \item{income}{Subjects' income, measured as a 19-point scale.}
#'
#'   \item{emo}{Measure of subjects' negative feeling during the experiment.
#'   A numeric scale ranging between 3 and 12 where 3 indicates the most
#'   negative feeling.}
#'
#'   \item{p_harm}{Subjects' perceived harm caused by increased immigration.
#'   A numeric scale between 2 and 8.}
#'
#'   \item{immigr}{A four-point scale measuring subjects' attitudes toward
#'   increased immigration. Larger values indicate more negative attitudes.}
#'
#'   \item{cong_mesg}{Whether subjects requested sending an anti-immigration
#'   message to Congress on their behalf.}
#'
#'   \item{english2}{Numeric recoding of \code{english}, where
#'   1 = ``Strongly Oppose'', 2 = ``Oppose'', 3 = ``Favor'', and
#'   4 = ``Strongly Favor''.}
#'
#'   \item{anx2}{Numeric recoding of \code{anx}, where
#'   1 = ``not anxious at all'', 2 = ``a little anxious'',
#'   3 = ``somewhat anxious'', and 4 = ``very anxious''.}
#'
#'   \item{educ2}{Numeric recoding of \code{educ}, where
#'   1 = ``less than high school'', 2 = ``high school'',
#'   3 = ``some college'', and 4 = ``bachelor's degree or higher''.}
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
