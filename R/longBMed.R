#' Exploratory Bayesian Mediation Analysis for Longitudinal Data
#'
#' Fits the Longitudinal Bayesian Mediation (longBMed) model for identifying
#' candidate mediators in repeated-measures data using Bayesian variable
#' selection implemented in JAGS.
#'
#' The input data should be provided as a three-dimensional numeric array of
#' dimension `(N, T, K + 2)`, where:
#' \describe{
#'   \item{`N`}{Number of subjects.}
#'   \item{`T`}{Number of repeated measurements (time points).}
#'   \item{`[, , 1]`}{Predictor variable (`X`).}
#'   \item{`[, , 2:(K + 1)]`}{Candidate mediators.}
#'   \item{`[, , K + 2]`}{Outcome variable (`Y`).}
#' }
#'
#' The function constructs the corresponding JAGS model, performs burn-in,
#' samples from the posterior distribution, and returns summary statistics
#' for the monitored parameters.
#'
#' @param subxym A three-dimensional numeric array with dimensions
#'   `(N, T, K + 2)` containing the predictor, candidate mediators, and
#'   outcome variable.
#' @param n.burnin Integer specifying the number of burn-in iterations for
#'   the JAGS sampler. Defaults to `1000`.
#' @param n.iter Integer specifying the number of posterior samples to draw
#'   after burn-in. Defaults to `5000`.
#' @param thin Integer specifying the thinning interval for posterior
#'   sampling. Defaults to `1`.
#'
#' @return A matrix of posterior summary statistics produced by
#'   `summary(output)$statistics`, including posterior means, standard
#'   deviations, and Monte Carlo standard errors for the monitored
#'   parameters.
#'
#' @details
#' The function monitors the posterior inclusion probabilities
#' (`ind.p`) and joint mediator selection indicators (`ind.joint`)
#' from the Bayesian mediation model.
#'
#' @importFrom rjags jags.model coda.samples
#'
#' @export


longBMed <-function(subxym,
                    n.burnin = 1000,
                    n.iter = 5000,
                    thin = 1
  ){

  # Validate input ----
  if (!is.array(subxym) || length(dim(subxym)) != 3) {
    stop("`subxym` must be a three-dimensional numeric array.")
  }

  if (!is.numeric(subxym)) {
    stop("`subxym` must contain numeric values.")
  }

  if (dim(subxym)[3] < 3) {
    stop("`subxym` must include X, at least one mediator, and Y in the third dimension.")
  }

  # Prepare data ----
Nvpm = dim(subxym)[[1]]
Tvpm = dim(subxym)[[2]]
Kvpm = dim(subxym)[[3]]-2

bdata <- list(
  N = as.numeric(Nvpm),
  T = as.numeric(Tvpm),
  K = as.numeric(Kvpm),
  X = as.matrix(subxym[,,1]),
  MY = subxym[,,-1]
)

# Specify model ----
modelstring="
model {
  for (i in 1:N) {
     u_M[i] ~ dnorm(0, tau_uM)
     u_Y[i] ~ dnorm(0, tau_uY)

    MY[i,1,1:(K+1)] ~ dmnorm(rep(0,K+1),Inv_cov[1:(K+1),1:(K+1)])

    for (t in 2:T) {
      MY[i,t,1:(K+1)] ~ dmnorm(muMY[i,t,1:(K+1)],Inv_cov[1:(K+1),1:(K+1)])

       for (k in 1:K){
          muMY[i,t,k] <- alpha0 + inprod(alpha1_t[k,t-1], X[i, t-1])
                        + alpha2 * MY[i, t-1,k] + u_M[i]
       }

       muMY[i,t,K+1] <- beta0 + beta1 * X[i, t] + inprod(beta2_t[1:K,t-1], MY[i, t-1,1:K]) +
                      beta3 * MY[i, t-1,K+1] + u_Y[i]
    }
  }

  for (t in 1:T){
    for (k in 1:K){
    alpha1_t[k,t] <- ind.a[k,t] * aI[k,t]
    ind.a[k,t] ~ dbern(ind.p[k,t])
    aI[k,t] ~ dnorm(0,taua)

    beta2_t[k,t] <- ind.b[k, t] * bI[k, t]
    ind.b[k,t] ~ dbern(ind.p[k,t])
    bI[k,t] ~ dnorm(0,taub)

    ind.p[k,t] ~ dbeta(3,3)
    }
  }

  Inv_cov[1:(K+1),1:(K+1)]~dwish(R[1:(K+1),1:(K+1)], (K+1))

  for (j in 1:(K+1)){
    R[j,j] <- 1
  }

  for (j1 in 1:K) {
    for (j2 in (j1+1):(K+1)) {
      R[j1,j2] <- 0.6
      R[j2,j1] <- 0.6
    }
  }

  taua ~ dgamma(1,0.001)
  taub ~ dgamma(1,0.001)

  alpha0 ~ dnorm(0, 1.0E-6)
  alpha2 ~ dnorm(0, 1.0E-6)
  beta0 ~ dnorm(0, 1.0E-6)
  beta1 ~ dnorm(0, 1.0E-6)
  beta3 ~ dnorm(0, 1.0E-6)

  tau_uM ~ dgamma(1, 0.001)
  tau_uY ~ dgamma(1, 0.001)

  for (t in 1:T){
    for (k in 1:K){
      ind.joint[k,t] = ind.a[k,t]*ind.b[k,t]
    }
  }
}
"

# Initial values ----
init <- function() {
  list(taua=1,taub=1,
       ind.p = structure(.Data=dput(rep(0,Kvpm*Tvpm)),.Dim=c(Kvpm,Tvpm)),
       aI = structure(.Data=dput(rep(0,Kvpm*Tvpm)),.Dim=c(Kvpm,Tvpm)),
       bI = structure(.Data=dput(rep(0,Kvpm*Tvpm)),.Dim=c(Kvpm,Tvpm)),
       ind.a = structure(.Data=dput(rep(0,Kvpm*Tvpm)),.Dim=c(Kvpm,Tvpm)),
       ind.b = structure(.Data=dput(rep(0,Kvpm*Tvpm)),.Dim=c(Kvpm,Tvpm)),
       alpha0 = 0,
       alpha2 = 0,
       beta0 = 0,
       beta1 = 0,
       beta3 = 0,
       tau_uM = 1,
       tau_uY = 1,
       Inv_cov=structure(diag(rep(1,(Kvpm+1))),.Dim=c((Kvpm+1),(Kvpm+1))),
       u_M = rnorm(Nvpm),
       u_Y = rnorm(Nvpm)
  )
}

params <- c( "ind.joint","ind.p")

# Run the JAGS model----
jags_model <- jags.model(textConnection(modelstring), data = bdata,
                         inits=init)
update(jags_model, n.burnin)  # Burn-in

# Sample from posterior ----
output <- coda.samples(jags_model, variable.names = params, n.iter = n.iter,thin = thin)

# Summarize results ----
allres <- summary(output)$statistics
return(allres)
}
