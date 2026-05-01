# --- Arrange: Create a standard dummy dataset ---
# We include multiple Xs and Ms to ensure matrices and lists format correctly
dummy_dataset <- data.frame(
  predictor1 = c(1.1, 2.2, 3.3, 4.4),
  predictor2 = c(5, 6, 7, 8),
  medA = c(0.1, 0.2, 0.3, 0.4),
  medB = c(10, 20, 30, 40),
  outcome = c(1, 0, 1, 0)
)

# --- 1. Standard Happy Path (1 X, 2 M, 1 Y) -----------------------------------
test_that("prepare_ebmed_data formats standard inputs correctly", {
  # Act
  res <- prepare_ebmed_data(
    dataset = dummy_dataset,
    X = "predictor1",
    M = c("medA", "medB"),
    Y = "outcome",
    M_cont = TRUE,
    Y_cont = TRUE
  )

  # Assert: Core structure
  expect_type(res, "list")
  expect_equal(res$N, 4)

  # Assert: X is a matrix (even with 1 column)
  expect_true(is.matrix(res$X))
  expect_equal(ncol(res$X), 1)

  # Assert: Y is a flat vector
  expect_true(is.numeric(res$y))
  expect_equal(res$y, dummy_dataset$outcome)

  # Assert: Mediators are renamed to m1, m2, etc.
  expect_true(all(c("m1", "m2") %in% names(res)))
  expect_equal(res$m1, dummy_dataset$medA)
  expect_equal(res$m2, dummy_dataset$medB)
})

# --- 2. Multiple Predictors (Covariates) --------------------------------------
test_that("prepare_ebmed_data handles multiple X variables (covariates)", {
  res <- prepare_ebmed_data(
    dataset = dummy_dataset,
    X = c("predictor1", "predictor2"),
    M = "medA",
    Y = "outcome",
    M_cont = TRUE, Y_cont = TRUE
  )

  # Assert: X must be a 2-column matrix
  expect_true(is.matrix(res$X))
  expect_equal(ncol(res$X), 2)
  expect_equal(res$X[, "predictor2"], dummy_dataset$predictor2)
})

# --- 3. Missing Data Passthrough (NAs) ----------------------------------------
test_that("prepare_ebmed_data passes NAs through cleanly for JAGS", {
  # Arrange: Data with NAs
  na_data <- dummy_dataset
  na_data$outcome[1] <- NA
  na_data$medA[2] <- NA

  # Act
  res <- prepare_ebmed_data(
    dataset = na_data, X = "predictor1", M = "medA", Y = "outcome",
    M_cont = TRUE, Y_cont = TRUE
  )

  # Assert: JAGS handles NAs, so R shouldn't drop them, just pass them along
  expect_true(is.na(res$y[1]))
  expect_true(is.na(res$m1[2]))
  expect_equal(res$N, 4) # N should remain 4, not drop to complete cases
})
