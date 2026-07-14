#' Select binary mediators using the GT-exploratory Bayesian mediation model with continuous dependent variables.
#'
#' Fits a Bayesian mediation model specifically designed for cases where
#' the mediators (\eqn{M}) are binary (0/1) and the outcome variable (\eqn{Y})
#' is continuous.
#'
#' @description
#' This function selects time-invariant binary mediators using the generalized
#' two-stage exploratory Bayesian mediation model with continuous dependent variables.
#'
#' @param model A character string specifying the mediation model to be
#' fitted. The model should be specified using the syntax
#' \code{"Y ~ X1 + X2 | M1 + M2"}, where \code{Y}, \code{X1},
#' \code{X2}, \code{M1}, and \code{M2} should be replaced by the names of the
#' corresponding variables in the dataset.
#' @param dataset A \code{data.frame} containing the variables specified in the model.
#' @param my_prior Optional \code{data.frame} containing custom prior specifications.
#' Run \code{parms <- run_parms_wizard()} to see the required structure.
#' @param advanced Character. Use \code{"interactive"} for an interactive wizard
#' to choose parameter distributions, or leave \code{NULL} for defaults.
#'
#' @param y.prec.shape Numeric scalar. Shape hyperparameter of the Gamma prior
#' distribution for the outcome residual precision. The default value is 1.
#' @param y.prec.rate Numeric scalar. Rate hyperparameter of the Gamma prior
#' distribution for the outcome residual precision. The default value is
#' 0.001.
#' @param a.pip.hyperalpha Numeric scalar or vector. Alpha hyperparameter of
#' the Beta prior distribution for the \eqn{a}-path inclusion probabilities.
#' The default value is 3.
#' @param a.pip.hyperbeta Numeric scalar or vector. Beta hyperparameter of
#' the Beta prior distribution for the \eqn{a}-path inclusion probabilities.
#' The default value is 3.
#' @param b.pip.hyperalpha Numeric scalar or vector. Alpha hyperparameter of
#' the Beta prior distribution for the \eqn{b}-path inclusion probabilities.
#' The default value is 3.
#' @param b.pip.hyperbeta Numeric scalar or vector. Beta hyperparameter of
#' the Beta prior distribution for the \eqn{b}-path inclusion probabilities.
#' The default value is 3.
#' @param direct.coef.mean Numeric scalar or vector. Mean parameter of the
#' Normal prior distribution for the direct effects (\eqn{c'}). The default
#' value is 0.
#' @param direct.coef.precision Numeric scalar or vector. Precision parameter
#' of the Normal prior distribution for the direct effects (\eqn{c'}). The
#' default value is 1.0E-6.
#'
#' @param y.prec.init Numeric or \code{NULL}. Initial value for the outcome
#' residual precision. The default value is 1.
#' @param direct.coef.init Numeric or \code{NULL}. Initial value for the direct
#' effect (\eqn{c'}). Default is 0.
#' @param a.pip.hyperprior.init Numeric or \code{NULL}. Initial value of the
#' \eqn{a}-path inclusion probability (PIP). The default value is 0.5.
#' @param b.pip.hyperprior.init Numeric or \code{NULL}. Initial value of the
#' \eqn{b}-path inclusion probability (PIP). The default value is 0.5.
#'
#' @param n_chains Integer. Number of MCMC chains.
#' @param n_adapt Integer. Number of adaptation iterations.
#' @param n_burnin Integer. Number of burn-in iterations.
#' @param n_iter Integer. Number of post-burn-in iterations.
#' @param thin Integer. Thinning interval.
#'
#' @return A matrix of posterior summary statistics for the monitored
#' parameters.
#'
#' @references
#' Shi, D., Shi, D., and Fairchild, A. J. (2023) "Variable Selection for Mediators
#' under a Bayesian Mediation Model" <doi:10.1080/10705511.2022.2164285>
#'
#' @examples
#' # Mixed case: Binary M, Continuous Y
#' set.seed(789)
#' n <- 100
#' toy_data <- data.frame(
#'    X = rnorm(n),
#'    M1 = rbinom(n, 1, 0.4),
#'    M2 = rbinom(n, 1, 0.6),
#'    Y = rnorm(n)
#' )
#'
#' # Fit the model
#' results <- buzzEBMcatMcontY(
#'    model    = "Y ~ X | M1 + M2",
#'    dataset  = toy_data,
#'    n_burnin = 200,
#'    n_iter   = 1000
#' )
#'
#' summary(results)
#'
#' @export


buzzEBMcatMcontY <- function(
    model,
    dataset,
    my_prior = NULL, advanced = NULL,
    y.prec.shape = NULL, y.prec.rate = NULL,
    a.pip.hyperalpha = NULL, a.pip.hyperbeta = NULL,
    b.pip.hyperalpha = NULL, b.pip.hyperbeta = NULL,
    direct.coef.mean = NULL, direct.coef.precision = NULL,
    y.prec.init = NULL,
    direct.coef.init = NULL,
    a.pip.hyperprior.init = NULL,
    b.pip.hyperprior.init = NULL,
    n_chains = NULL,
    n_adapt = NULL,
    n_burnin = NULL,
    n_iter = NULL,
    thin = NULL
){
  # Parse Model
  vars <- .parse_buzz_syntax(model, dataset)
  X <- vars$X
  Y <- vars$Y
  M <- vars$M

  ## number of mediators
  P <- length(X)
  K <- length(M)

  Y_cont <- TRUE
  M_cont <- FALSE

  ## 1. prepare data and set up the prior data frame
  bdata <- prepare_ebmed_data(dataset, X, M, Y, M_cont, Y_cont)

  parms <- make_parms_main(
    y.prec.shape = y.prec.shape,
    y.prec.rate  = y.prec.rate,
    a.pip.hyperalpha = a.pip.hyperalpha,
    a.pip.hyperbeta  = a.pip.hyperbeta,
    b.pip.hyperalpha = b.pip.hyperalpha,
    b.pip.hyperbeta  = b.pip.hyperbeta,
    direct.coef.mean = direct.coef.mean,
    direct.coef.precision = direct.coef.precision,
    my_prior  = my_prior,
    advanced = advanced
  )

  ## 2. build model
  modelstring <- build_ebmed_model_mcat_ycont(P, K, parms)

  ## 3. initial values
  init <- define_init_values(P,
                             K,
                             M_cont,
                             Y_cont,
                             m.prec.init = NULL,
                             y.prec.init = y.prec.init,
                             direct.coef.init = direct.coef.init,
                             a.pip.hyperprior.init = a.pip.hyperprior.init,
                             b.pip.hyperprior.init = b.pip.hyperprior.init)

  ## 4. run JAGS
  output <- run_ebmed_jags(modelstring = modelstring,
                           bdata = bdata,
                           init = init,
                           M_cont = M_cont,
                           Y_cont = Y_cont,
                           n_chains = n_chains,
                           n_adapt = n_adapt,
                           n_burnin = n_burnin,
                           n_iter = n_iter,
                           thin = thin)
  ## 5. extract results
  res <- extract_results(output, M)

  return(res)
}
