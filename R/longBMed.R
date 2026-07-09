#' Select time-varying mediators using the longitudinal Bayesian mediation selection model
#'
#' This function selects time-varying mediators using the longitudinal
#' Bayesian mediation selection model.
#'
#' The model supports one or more predictor variables (X), one or more
#' candidate mediators (M), and exactly one outcome variable (Y). Data may be
#' supplied in any of three formats (see Details).
#'
#' @param model Specifies how variables are assigned to the outcome(Y),
#'   predictor(s)(X), and candidate mediator(s) (M).
#'   The format depends on the type of \code{data}:
#'
#'   \strong{Named list or data frame:} A character string of the form
#'   \code{"Y ~ X1 + X2 | M1 + M2"}, where \code{Y}, \code{X1},
#'   \code{X2}, \code{M1}, and \code{M2} should be replaced by the names of the
#'   corresponding variables in the named list or data frame.
#'
#'   \strong{3-D array:} A character string of the form \code{"Y ~ X | M"},
#'   where Y, X, and M are specified using slice numbers. For example,
#'   \code{"10 ~ 1+2 | 3:9"} uses slice 10 as the outcome,
#'   slices 1 and 2 as predictors, and slices 3 through 9 as candidate mediators.
#'   If \code{model = NULL}, the first slice is used as the predictor, the
#'   last slice as the outcome, and all remaining slices as candidate mediators.
#'
#' @param data One of:
#'   \describe{
#'     \item{3-D numeric array \code{[N, T, K]}}{ N represents number of
#'     observations, T represents number of measurement occasions,
#'     and K represents a concatenated dimension of X, M, Y. Slice assignments are
#'       controlled by \code{model} (index expression string) or defaulted
#'       automatically when \code{model = NULL} as mentioned above in the
#'       \code{model} section.}
#'     \item{Named list of \code{N x T} matrices}{Each element is a
#'       subject-by-time matrix. Names must match the variable names in
#'       \code{model}.}
#'     \item{Long-format data frame}{The original longitudinal data in long
#'     format, where each row represents one measurement for one observational
#'     unit at one measurement occasion. The data frame must contain columns
#'     named \code{id} and \code{time}, together with one column for each
#'     variable specified in \code{model}. Here, \code{id} identifies each
#'     observational unit and \code{time} identifies the measurement occasion.}
#'   }
#' @param n.burnin Integer. Number of burn-in iterations. Default \code{3000}.
#' @param n.iter Integer. Number of posterior samples after burn-in.
#'   Default \code{6000}.
#' @param thin Integer. Thinning interval. Default \code{1}.
#'
#' @return A matrix of posterior summary statistics from
#'   \code{summary(output)$statistics}, including posterior means, standard
#'   deviations, and standard errors for \code{ind.joint} and \code{ind.p}.
#'
#' @details
#' #' For a named list or long-format data frame, the model can be specified using
#' variable names, such as \code{"Y ~ X1 + X2 | M1 + M2"}.
#'
#' For a 3-D array, the model can be specified using integer slice indices,
#' such as \code{"21 ~ 1 | 2:20"}, where the left side specifies the outcome,
#' the expression before \code{|} specifies the predictor(s), and the
#' expression after \code{|} specifies the mediator(s).
#'
#' @importFrom rjags jags.model coda.samples
#' @importFrom stats rnorm
#'
#' @export

longBMed <- function(model    = NULL,
                     data,
                     n.burnin = 3000,
                     n.iter   = 6000,
                     thin     = 1) {


# 1. Detect data type and route to the correct parser ----

  if (is.array(data) && length(dim(data)) == 3) {


    # FORMAT A: 3-D numeric array [N, T, K]

    if (!is.numeric(data))
      stop("`data` must contain numeric values.")

    K  <- dim(data)[3]   # total number of slices

    if (K < 3)
      stop("`data` must have at least 3 slices (1 X, 1 M, 1 Y).")

    # Reject real R formula objects — index syntax must be a plain string
    if (inherits(model, "formula"))
      stop(
        "When `data` is a 3-D array, `model` must be a character string ",
        "using slice indices (e.g. \"10 ~ 1+2 | 3:9\"), not an R formula ",
        "object created with `~`."
      )

    if (is.null(model)) {
      # Default layout: slice 1 = X, slice K = Y, slices 2:(K-1) = M
      y_idx <- K
      x_idx <- 1L
      m_idx <- 2L:(K - 1L)

      message(
        "No formula provided. Defaulting to:\n",
        "  slice ", x_idx, " -> X\n",
        "  slices ", m_idx[1], " to ", m_idx[length(m_idx)], " -> M\n",
        "  slice ", y_idx, " -> Y\n",
        "To override, pass a model string e.g. \"", K, " ~ 1 | 2:", K - 1L, "\"."
      )

    } else {
      # Parse index expression string
      parsed <- .parse_index_formula(model, K)
      y_idx  <- parsed$y_idx
      x_idx  <- parsed$x_idx
      m_idx  <- parsed$m_idx
    }

    N  <- dim(data)[1]
    Tv <- dim(data)[2]
    K  <- length(m_idx)
    P  <- length(x_idx)

    X_list <- lapply(seq_len(P), function(p) data[, , x_idx[p]])
    M_arr  <- if (K == 1) {
      array(data[, , m_idx], dim = c(N, Tv, 1L))
    } else {
      data[, , m_idx, drop = FALSE]
    }
    Y_mat  <- data[, , y_idx]

  } else if (is.list(data) && !is.data.frame(data)) {

    # FORMAT B: Named list of N x T matrices

    # Reject numeric index-style model strings for this format
    if (!is.null(model) && .looks_like_index_formula(model))
      stop(
        "The model string looks like an index expression (e.g. \"10 ~ 1+2 | 3:9\") ",
        "but `data` is a named list. Use variable names in the formula ",
        "(e.g. \"Y ~ X1 + X2 | M1 + M2\") or supply a 3-D array."
      )

    if (is.null(model))
      stop("A `model` formula is required when `data` is a named list of matrices.")

    parsed  <- .parse_name_formula(model)
    x_names <- parsed$x_vars
    m_names <- parsed$m_vars
    y_name  <- parsed$y_var

    .check_var_names(data, c(x_names, m_names, y_name))

    X_list <- lapply(x_names, function(v) as.matrix(data[[v]]))
    names(X_list) <- x_names

    dims <- dim(X_list[[1]])
    N    <- dims[1]
    Tv   <- dims[2]
    K    <- length(m_names)
    P    <- length(x_names)

    M_arr <- array(
      unlist(lapply(m_names, function(v) as.matrix(data[[v]]))),
      dim = c(N, Tv, K)
    )
    Y_mat <- as.matrix(data[[y_name]])

  } else if (is.data.frame(data)) {

    # FORMAT C: Long-format data frame

    # Reject numeric index-style model strings for this format
    if (!is.null(model) && .looks_like_index_formula(model))
      stop(
        "The model string looks like an index expression (e.g. \"10 ~ 1+2 | 3:9\") ",
        "but `data` is a data frame. Use variable names in the formula ",
        "(e.g. \"Y ~ X1 + X2 | M1 + M2\") or supply a 3-D array."
      )

    if (is.null(model))
      stop("A `model` formula is required when `data` is a data frame.")
    if (!all(c("id", "time") %in% names(data)))
      stop("`data` must contain columns named 'id' and 'time'.")

    parsed  <- .parse_name_formula(model)
    x_names <- parsed$x_vars
    m_names <- parsed$m_vars
    y_name  <- parsed$y_var

    .check_var_names(data, c(x_names, m_names, y_name))

    data  <- data[order(data$id, data$time), ]
    N     <- length(unique(data$id))
    Tv    <- length(unique(data$time))
    K     <- length(m_names)
    P     <- length(x_names)

    .wide <- function(var) {
      matrix(data[[var]], nrow = N, ncol = Tv, byrow = FALSE)
    }

    X_list <- lapply(x_names, .wide)
    names(X_list) <- x_names

    M_arr <- array(unlist(lapply(m_names, .wide)), dim = c(N, Tv, K))
    Y_mat <- .wide(y_name)

  } else {
    stop(
      "`data` must be a 3-D numeric array, a named list of N x T matrices, ",
      "or a long-format data frame."
    )
  }

# 2. Build JAGS data list ----

  # Stack X: N x T matrix (P=1) or N x T x P array (P>1)
  X_jags <- if (P == 1L) {
    X_list[[1L]]
  } else {
    array(unlist(X_list), dim = c(N, Tv, P))
  }

  # MY array: N x T x (K+1)  — mediators first, Y last
  MY_arr <- array(NA_real_, dim = c(N, Tv, K + 1L))
  MY_arr[, , seq_len(K)] <- M_arr
  MY_arr[, , K + 1L]     <- Y_mat

  # Only pass P when the multi-X model string references it
  bdata <- if (P == 1L) {
    list(N = as.numeric(N), T = as.numeric(Tv), K = as.numeric(K),
         X = X_jags, MY = MY_arr)
  } else {
    list(N = as.numeric(N), T = as.numeric(Tv), K = as.numeric(K),
         P = as.numeric(P), X = X_jags, MY = MY_arr)
  }


# 3. JAGS model string ----


  if (P == 1L) {

    modelstring <- "
model {
  for (i in 1:N) {
    u_M[i] ~ dnorm(0, tau_uM)
    u_Y[i] ~ dnorm(0, tau_uY)

    MY[i,1,1:(K+1)] ~ dmnorm(rep(0,K+1), Inv_cov[1:(K+1),1:(K+1)])

    for (t in 2:T) {
      MY[i,t,1:(K+1)] ~ dmnorm(muMY[i,t,1:(K+1)], Inv_cov[1:(K+1),1:(K+1)])

      for (k in 1:K) {
        muMY[i,t,k] <- alpha0 + inprod(alpha1_t[k,t-1], X[i,t-1])
                       + alpha2 * MY[i,t-1,k] + u_M[i]
      }

      muMY[i,t,K+1] <- beta0 + beta1 * X[i,t]
                       + inprod(beta2_t[1:K,t-1], MY[i,t-1,1:K])
                       + beta3 * MY[i,t-1,K+1] + u_Y[i]
    }
  }

  for (t in 1:T) {
    for (k in 1:K) {
      alpha1_t[k,t] <- ind.a[k,t] * aI[k,t]
      ind.a[k,t]    ~ dbern(ind.p[k,t])
      aI[k,t]       ~ dnorm(0, taua)

      beta2_t[k,t] <- ind.b[k,t] * bI[k,t]
      ind.b[k,t]   ~ dbern(ind.p[k,t])
      bI[k,t]      ~ dnorm(0, taub)

      ind.p[k,t] ~ dbeta(3, 3)
    }
  }

  Inv_cov[1:(K+1),1:(K+1)] ~ dwish(R[1:(K+1),1:(K+1)], (K+1))

  for (j in 1:(K+1)) { R[j,j] <- 1 }
  for (j1 in 1:K) {
    for (j2 in (j1+1):(K+1)) {
      R[j1,j2] <- 0.6
      R[j2,j1] <- 0.6
    }
  }

  taua ~ dgamma(1, 0.001)
  taub ~ dgamma(1, 0.001)

  alpha0 ~ dnorm(0, 1.0E-6)
  alpha2 ~ dnorm(0, 1.0E-6)
  beta0  ~ dnorm(0, 1.0E-6)
  beta1  ~ dnorm(0, 1.0E-6)
  beta3  ~ dnorm(0, 1.0E-6)

  tau_uM ~ dgamma(1, 0.001)
  tau_uY ~ dgamma(1, 0.001)

  for (t in 1:T) {
    for (k in 1:K) {
      ind.joint[k,t] <- ind.a[k,t] * ind.b[k,t]
    }
  }
}
"

  } else {

    modelstring <- "
model {
  for (i in 1:N) {
    u_M[i] ~ dnorm(0, tau_uM)
    u_Y[i] ~ dnorm(0, tau_uY)

    MY[i,1,1:(K+1)] ~ dmnorm(rep(0,K+1), Inv_cov[1:(K+1),1:(K+1)])

    for (t in 2:T) {
      MY[i,t,1:(K+1)] ~ dmnorm(muMY[i,t,1:(K+1)], Inv_cov[1:(K+1),1:(K+1)])

      for (k in 1:K) {
        muMY[i,t,k] <- alpha0 + inprod(alpha1_t[k,1:P,t-1], X[i,t-1,1:P])
                       + alpha2 * MY[i,t-1,k] + u_M[i]
      }

      muMY[i,t,K+1] <- beta0 + inprod(beta1[1:P], X[i,t,1:P])
                       + inprod(beta2_t[1:K,t-1], MY[i,t-1,1:K])
                       + beta3 * MY[i,t-1,K+1] + u_Y[i]
    }
  }

  for (t in 1:T) {
    for (k in 1:K) {
      for (p in 1:P) {
        alpha1_t[k,p,t] <- ind.a[k,p,t] * aI[k,p,t]
        ind.a[k,p,t]    ~ dbern(ind.p[k,p,t])
        aI[k,p,t]       ~ dnorm(0, taua)
        ind.p[k,p,t]    ~ dbeta(3, 3)
      }

      beta2_t[k,t]  <- ind.b[k,t] * bI[k,t]
      ind.b[k,t]    ~ dbern(ind.p.b[k,t])
      bI[k,t]       ~ dnorm(0, taub)
      ind.p.b[k,t]  ~ dbeta(3, 3)
    }
  }

  Inv_cov[1:(K+1),1:(K+1)] ~ dwish(R[1:(K+1),1:(K+1)], (K+1))

  for (j in 1:(K+1)) { R[j,j] <- 1 }
  for (j1 in 1:K) {
    for (j2 in (j1+1):(K+1)) {
      R[j1,j2] <- 0.6
      R[j2,j1] <- 0.6
    }
  }

  taua ~ dgamma(1, 0.001)
  taub ~ dgamma(1, 0.001)

  alpha0 ~ dnorm(0, 1.0E-6)
  alpha2 ~ dnorm(0, 1.0E-6)
  beta0  ~ dnorm(0, 1.0E-6)
  for (p in 1:P) { beta1[p] ~ dnorm(0, 1.0E-6) }
  beta3  ~ dnorm(0, 1.0E-6)

  tau_uM ~ dgamma(1, 0.001)
  tau_uY ~ dgamma(1, 0.001)

  for (t in 1:T) {
    for (k in 1:K) {
      for (p in 1:P) {
        ind.joint[k,p,t] <- ind.a[k,p,t] * ind.b[k,t]
      }
    }
  }
}
"
  }

# 4. Initial values ----
init <- if (P == 1L) {
  function() {
    list(
      taua    = 1,      taub    = 1,
      ind.p   = array(0, dim = c(K, Tv)),
      aI      = array(0, dim = c(K, Tv)),
      bI      = array(0, dim = c(K, Tv)),
      ind.a   = array(0, dim = c(K, Tv)),
      ind.b   = array(0, dim = c(K, Tv)),
      alpha0  = 0,      alpha2  = 0,
      beta0   = 0,      beta1   = 0,      beta3   = 0,
      tau_uM  = 1,      tau_uY  = 1,
      Inv_cov = diag(K + 1L),
      u_M     = rnorm(N),
      u_Y     = rnorm(N)
    )
  }
} else {
  function() {
    list(
      taua    = 1,      taub    = 1,
      ind.p   = array(0, dim = c(K, P, Tv)),
      aI      = array(0, dim = c(K, P, Tv)),
      ind.a   = array(0, dim = c(K, P, Tv)),
      ind.p.b = array(0, dim = c(K, Tv)),
      bI      = array(0, dim = c(K, Tv)),
      ind.b   = array(0, dim = c(K, Tv)),
      alpha0  = 0,      alpha2  = 0,
      beta0   = 0,      beta1   = rep(0, P),      beta3 = 0,
      tau_uM  = 1,      tau_uY  = 1,
      Inv_cov = diag(K + 1L),
      u_M     = rnorm(N),
      u_Y     = rnorm(N)
    )
  }
}

# 5. Run JAGS ----

jags_model <- jags.model(textConnection(modelstring),
                         data  = bdata,
                         inits = init)
update(jags_model, n.burnin)

output <- coda.samples(jags_model,
                       variable.names = c("ind.joint", "ind.p"),
                       n.iter         = n.iter,
                       thin           = thin)

return(summary(output)$statistics)
}

# Internal helpers ----
#
# .parse_index_formula
# Parses an index-expression string such as "10 ~ 1+2 | 3:9" into integer
# vectors of slice indices for Y, X, and M, with full validation.
.parse_index_formula <- function(model_str, K) {

  model_str <- trimws(as.character(model_str))

  if (!grepl("~", model_str, fixed = TRUE))
    stop("Index formula must contain '~', e.g. \"10 ~ 1+2 | 3:9\".")
  if (!grepl("|", model_str, fixed = TRUE))
    stop("Index formula must contain '|' to separate X from M, e.g. \"10 ~ 1+2 | 3:9\".")

  # Split on "~" first
  lr <- strsplit(model_str, "~", fixed = TRUE)[[1]]
  if (length(lr) != 2)
    stop("Index formula must have exactly one '~'.")

  lhs <- trimws(lr[1])
  rhs <- trimws(lr[2])

  # Split RHS on "|"
  xm <- strsplit(rhs, "|", fixed = TRUE)[[1]]
  if (length(xm) != 2)
    stop("Right-hand side of index formula must have exactly one '|'.")

  x_str <- trimws(xm[1])
  m_str <- trimws(xm[2])

  # Parse each component into integer indices
  y_idx <- .expand_index_expr(lhs, K, role = "Y")
  x_idx <- .expand_index_expr(x_str, K, role = "X")
  m_idx <- .expand_index_expr(m_str, K, role = "M")

  # Y must be exactly one slice
  if (length(y_idx) != 1L)
    stop(
      "Y (left-hand side) must resolve to exactly one slice index, ",
      "but got: ", paste(y_idx, collapse = ", "), "."
    )

  # Check for within-role duplicates (warn and de-duplicate)
  for (role_name in c("X", "M")) {
    idx <- if (role_name == "X") x_idx else m_idx
    if (anyDuplicated(idx)) {
      warning(
        "Duplicate slice indices in ", role_name, " expression; ",
        "de-duplicating. Original indices: ", paste(idx, collapse = ", "), "."
      )
      if (role_name == "X") x_idx <- unique(x_idx)
      else                  m_idx <- unique(m_idx)
    }
  }

  # Check for cross-role overlaps — these are hard errors
  yx_overlap <- intersect(y_idx, x_idx)
  ym_overlap <- intersect(y_idx, m_idx)
  xm_overlap <- intersect(x_idx, m_idx)

  if (length(yx_overlap) > 0)
    stop("Slice(s) ", paste(yx_overlap, collapse = ", "),
         " appear in both Y and X. Each slice may only be assigned one role.")
  if (length(ym_overlap) > 0)
    stop("Slice(s) ", paste(ym_overlap, collapse = ", "),
         " appear in both Y and M. Each slice may only be assigned one role.")
  if (length(xm_overlap) > 0)
    stop("Slice(s) ", paste(xm_overlap, collapse = ", "),
         " appear in both X and M. Each slice may only be assigned one role.")

  # Warn about unassigned slices
  assigned <- sort(unique(c(y_idx, x_idx, m_idx)))
  omitted  <- setdiff(seq_len(K), assigned)
  if (length(omitted) > 0)
    message(
      "Note: slice(k) ", paste(omitted, collapse = ", "),
      " were not assigned to any role (Y, X, or M) and will be ignored."
    )

  list(y_idx = y_idx, x_idx = x_idx, m_idx = m_idx)
}


# -----------------------------------------------------------------------------
# .expand_index_expr
#
# Converts an index expression string (e.g. "1:2+4" or "3+5:8+10") into a
# sorted integer vector of slice indices, checking bounds against K.
# -----------------------------------------------------------------------------
.expand_index_expr <- function(expr, K, role = "unknown") {

  expr <- trimws(expr)

  if (!nzchar(expr))
    stop("Empty index expression for role '", role, "'.")

  # Tokenise on "+" — each token is either a single integer or a "a:b" range
  tokens <- trimws(strsplit(expr, "+", fixed = TRUE)[[1]])

  indices <- integer(0)

  for (tok in tokens) {
    if (grepl(":", tok, fixed = TRUE)) {
      # Range token: "a:b"
      parts <- strsplit(tok, ":", fixed = TRUE)[[1]]
      if (length(parts) != 2)
        stop("Invalid range '", tok, "' in ", role, " expression. ",
             "Ranges must be of the form 'a:b'.")
      a <- suppressWarnings(as.integer(trimws(parts[1])))
      b <- suppressWarnings(as.integer(trimws(parts[2])))
      if (is.na(a) || is.na(b))
        stop("Non-integer value in range '", tok, "' for role '", role, "'.")
      if (a > b)
        stop("Range '", tok, "' is empty (start > end) for role '", role, "'.")
      indices <- c(indices, a:b)
    } else {
      # Single index token
      idx <- suppressWarnings(as.integer(tok))
      if (is.na(idx))
        stop("Non-integer token '", tok, "' in ", role, " index expression. ",
             "Did you mean to use a named-variable formula instead?")
      indices <- c(indices, idx)
    }
  }

  # Bounds check
  out_of_bounds <- indices[indices < 1L | indices > K]
  if (length(out_of_bounds) > 0)
    stop(
      "Slice index/indices out of bounds in role '", role, "': ",
      paste(out_of_bounds, collapse = ", "),
      ". Array has ", K, " slices (valid range: 1 to ", K, ")."
    )

  sort(unique(indices))
}


# -----------------------------------------------------------------------------
# .looks_like_index_formula
#
# Heuristic: returns TRUE when a model string looks like it uses numeric
# slice indices rather than variable names. Used to catch mix-and-match errors.
# -----------------------------------------------------------------------------
.looks_like_index_formula <- function(model) {
  model_str <- trimws(
    if (inherits(model, "formula")) paste(deparse(model), collapse = " ")
    else as.character(model)
  )
  # If the LHS (before ~) is purely digits/spaces, treat as index formula
  lhs <- trimws(strsplit(model_str, "~")[[1]][1])
  grepl("^[0-9]+$", lhs)
}


# -----------------------------------------------------------------------------
# .parse_name_formula
#
# Parses a named-variable formula string or R formula object of the form
# "Y ~ X1 + X2 | M1 + M2" into character vectors.
# -----------------------------------------------------------------------------
.parse_name_formula <- function(model) {

  model_str <- if (inherits(model, "formula")) {
    paste(deparse(model), collapse = " ")
  } else {
    as.character(model)
  }

  # Strip leading tilde produced by deparse() on bare formula objects
  model_str <- trimws(gsub("^~", "", model_str))

  if (!grepl("|", model_str, fixed = TRUE))
    stop("Formula must contain '|' to separate predictors from mediators, ",
         "e.g. \"Y ~ X1 + X2 | M1 + M2\".")

  sides <- strsplit(model_str, "~", fixed = TRUE)[[1]]
  if (length(sides) != 2)
    stop("Formula must be of the form \"Y ~ X1 + X2 | M1 + M2\".")

  y_var <- trimws(sides[1])

  rhs <- strsplit(sides[2], "|", fixed = TRUE)[[1]]
  if (length(rhs) != 2)
    stop("Right-hand side of formula must contain exactly one '|'.")

  x_vars <- trimws(strsplit(rhs[1], "+", fixed = TRUE)[[1]])
  m_vars <- trimws(strsplit(rhs[2], "+", fixed = TRUE)[[1]])

  if (!nzchar(y_var))
    stop("Outcome variable (left-hand side) is missing from formula.")
  if (length(x_vars) == 0L || any(!nzchar(x_vars)))
    stop("At least one predictor must be specified before '|'.")
  if (length(m_vars) == 0L || any(!nzchar(m_vars)))
    stop("At least one mediator must be specified after '|'.")

  list(y_var = y_var, x_vars = x_vars, m_vars = m_vars)
}


# -----------------------------------------------------------------------------
# .check_var_names — confirm all required names exist in data
# -----------------------------------------------------------------------------
.check_var_names <- function(data, required) {
  missing <- setdiff(required, names(data))
  if (length(missing) > 0)
    stop("Variable(s) not found in `data`: ",
         paste(missing, collapse = ", "), ".")
}
