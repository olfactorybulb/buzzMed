#' Extract and Rename Mediation Results from JAGS Output
#'
#' Parses the summary statistics from a \code{coda} MCMC output object and
#' extracts rows corresponding to \code{ind.joint}, \code{a.pip.hyperprior},
#' and \code{b.pip.hyperprior}.
#'
#' @param output An \code{mcmc.list} object.
#' @param M Character vector of mediator variable names.
#'
#' @return A named numeric matrix.
#' @keywords internal
extract_results <- function(output, M) {
  # Extract the mean statistics (first column of the summary)
  stats <- summary(output)$statistics
  row_names <- rownames(stats)

  # 1. Regex logic:
  # (^name) starts with the name
  # (\\{|$) handles names with brackets (multiple) or without (single)
  joint_idx  <- grep("^ind\\.joint(\\[|$)", row_names)
  a_hyper_idx <- grep("^a\\.pip\\.hyperprior", row_names)
  b_hyper_idx <- grep("^b\\.pip\\.hyperprior", row_names)

  # 2. Validation
  if (length(M) != length(joint_idx)) {
    stop("Number of mediator names (", length(M),
         ") must match number of ind.joint entries: ", length(joint_idx))
  }

  # 3. Extraction & Column Naming
  # Extract joint inclusion probabilities and name them after the mediators
  res_joint <- t(stats[joint_idx, 1:4, drop = FALSE])
  colnames(res_joint) <- M

  # Initialize the final result with joint probabilities
  res <- res_joint

  # 4. Append Hyperpriors if found
  if (length(a_hyper_idx) > 0) {
    a_hyper <- t(stats[a_hyper_idx, 1:4, drop = FALSE])
    colnames(a_hyper) <- "a.pip.hyperprior"
    res <- cbind(res, a_hyper)
  }

  if (length(b_hyper_idx) > 0) {
    b_hyper <- t(stats[b_hyper_idx, 1:4, drop = FALSE])
    colnames(b_hyper) <- "b.pip.hyperprior"
    res <- cbind(res, b_hyper)
  }

  return(t(res))
}
