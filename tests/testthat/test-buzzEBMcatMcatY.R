# --- 1. Integration "Smoke Test" ----------------------------------------------
test_that("buzzEBMcatMcatY runs end-to-end without crashing", {

  # Arrange: Create a very small, simple binary dataset
  set.seed(123)
  n <- 30
  toy_data <- data.frame(
    X = rbinom(n, 1, 0.5),
    M1 = rbinom(n, 1, 0.3),
    M2 = rbinom(n, 1, 0.7),
    Y = rbinom(n, 1, 0.5)
  )

  # Act: Run the model with extremely low MCMC settings to save time
  # We use capture.output() or suppressWarnings() if JAGS prints too much to the console
  res <- buzzEBMcatMcatY(
    model    = "Y ~ M1 + M2 | X",
    dataset  = toy_data,
    n_chains = 1,      # Just 1 chain
    n_burnin = 10,     # Bare minimum burn-in
    n_iter   = 10      # Bare minimum iterations
  )

  # Assert: Did it successfully return the extracted matrix?
  expect_true(is.matrix(res))

  # Assert: Does the matrix have the correct row names from extract_results?
  expect_true(all(c("M1", "M2", "a.pip.hyperprior", "b.pip.hyperprior") %in% rownames(res)))
})

# --- 2. Error Handling (The Sad Path) -----------------------------------------
test_that("buzzEBMcatMcatY catches bad formulas before running JAGS", {

  toy_data <- data.frame(X = 1:10, M1 = 1:10, Y = 1:10)

  # Assert: It should immediately fail using the parser we tested earlier
  expect_error(
    buzzEBMcatMcatY(model = "Y = M1 | X", dataset = toy_data),
    regexp = "Invalid model syntax"
  )
})
