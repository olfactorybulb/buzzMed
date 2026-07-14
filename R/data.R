#' Time-averaged neural spiking data.
#'
#' Time-averaged neural spiking data, where neural activities are summarized
#' as the average rate of action potentials over the observation period,
#' yielding a single value for each neuron or recording.
#'
#' @format A data frame with 300 observations and 22 variables:
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
#' @source Time-averaged neural spiking data included with the \pkg{buzzMed} package.
"singlespikes"

#' A subset of longitudinal spike train data.
#'
#' A subset of spike train data with a time-indexed sequence of neural action
#' potentials, where each spike is represented as a single event occurring at
#' its recorded time.
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

#' Modified framing dataset with some dichotomization
#'
#' A modified version of the \code{framing} dataset from the
#' \pkg{mediation} package, originally based on the study by
#' Brader, Valentino, and Suhay (2008). The candidate mediators have been
#' dichotomized relative to the original \code{framing} dataset. The dataset
#' contains 265 observations and 10 variables.
#'
#' @format A data frame with 265 observations and 10 variables:
#' \describe{
#'   \item{tone}{Binary variable denoting whether the news story
#'   was framed positively(\code{tone}=0) or negatively(\code{tone}=1).}
#'
#'   \item{eth}{Binary variable denoting whether the news story
#'   featured a Latino(\code{eth}=1) or European immigrant(\code{eth}=0).}
#'
#'   \item{treat}{Binary variable indicating the interaction between
#'   \code{tone} and \code{eth}. A value of 1 indicates a negatively framed
#'   news story featuring a Latino immigrant, whereas a value of 0 indicates
#'   any other treatment combination.}
#'
#'   \item{negaff}{Binary variable of subjects' negative feelings during the experiment.
#'   This variable is derived from the \code{emo} variable in the original
#'   \code{framing} dataset. A value of 1 indicates an original score of 3--7,
#'   corresponding to stronger negative emotions, whereas a value of 0 indicates
#'   an original score of 8--12.}
#'
#'   \item{pharm}{Binary variable of subjects' perceived harm caused by increased
#'   immigration. This variable is derived from the \code{p_harm} variable in
#'   the original \code{framing} dataset. A value of 1 indicates an original
#'   score of 6--8, whereas a value of 0 indicates a score of 2--5.}
#'
#'   \item{immigr}{Binary variable derived from the original four-point scale
#'   measuring subjects' attitudes toward increased immigration. A value of 1
#'   indicates an original score of 3 or 4, corresponding to more negative
#'   attitudes toward increased immigration. A value of 0 indicates an original
#'   score of 1 or 2.}
#'
#'   \item{anx}{Binary variable derived from the original four-point scale
#'   measuring subjects' anxiety about increased immigration. A value of 1
#'   indicates respondents who reported being ``very anxious'' or
#'   ``somewhat anxious'' about increased immigration. A value of 0 indicates
#'   respondents who reported being ``a little anxious`` or ``not anxious at all``.}
#'
#'   \item{english}{Binary variable derived from the original four-point
#'   scale measuring support for making English the official language of the
#'   United States. A value of 1 indicates respondents who selected
#'   ``Favor`` or ``Strongly Favor``. A value of 0 indicates respondents who
#'   selected ``Oppose`` or ``Strongly Oppose``.}
#'
#'   \item{cong_mesg}{Binary variable indicating whether the respondent
#'   requested that an anti-immigration message be sent to Congress on
#'   their behalf. A value of 1 indicates that the subject chose to send the
#'   message, whereas a value of 0 indicates that the subject did not.}
#'
#'   \item{anti_info}{Binary variable indicating whether the respondent
#'   requested additional information from anti-immigration organizations.
#'   A value of 1 indicates that the subject chose to send the message,
#'   whereas a value of 0 indicates that the subject did not.}
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
