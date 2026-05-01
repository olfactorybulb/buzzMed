# --- 1. Integration "Smoke Test" ----------------------------------------------
test_that("buzzEBMcontMcatY runs end-to-end without crashing", {
  set.seed(123)
  n <- 30
  toy_data <- data.frame(
    X = rnorm(n),
    M1 = rnorm(n),              # M is Continuous
    M2 = rnorm(n),              # M is Continuous
    Y = rbinom(n, 1, 0.5)       # Y is Binary
  )

  res <- buzzEBMcontMcatY(
    model    = "Y ~ M1 + M2 | X",
    dataset  = toy_data,
    n_chains = 1,
    n_burnin = 10,
    n_iter   = 10
  )

  expect_true(is.matrix(res))

  # Assert: Does the matrix have the correct row names from extract_results?
  expect_true(all(c("M1", "M2", "a.pip.hyperprior", "b.pip.hyperprior") %in% rownames(res)))
})

# --- 2. Error Handling (The Sad Path) -----------------------------------------
test_that("buzzEBMcontMcatY catches bad formulas before running JAGS", {

  toy_data <- data.frame(X = 1:10, M1 = 1:10, Y = 1:10)

  # Assert: It should immediately fail using the parser we tested earlier
  expect_error(
    buzzEBMcontMcatY(model = "Y = M1 | X", dataset = toy_data),
    regexp = "Invalid model syntax"
  )
})
