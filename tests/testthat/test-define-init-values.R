# --- 1. Test Default Values & Dimensions (Fully Continuous) -------------------
test_that("define_init_values sets correct defaults and dimensions", {
  # Act: Pass NULL to all initialization parameters
  res <- define_init_values(
    P = 2, K = 3,
    M_cont = TRUE, Y_cont = TRUE,
    m.prec.init = NULL, y.prec.init = NULL,
    direct.coef.init = NULL,
    a.pip.hyperprior.init = NULL, b.pip.hyperprior.init = NULL
  )

  # Assert: Core structure
  expect_type(res, "list")

  # Assert: Defaults applied correctly via %||%
  expect_equal(res$m.prec, rep(1, 3))       # Default 1, length K
  expect_equal(res$y.prec, 1)               # Default 1, scalar
  expect_equal(res$direct.coef, rep(0, 2))  # Default 0, length P
  expect_equal(res$a.pip.hyperprior, 0.5)   # Default 0.5
  expect_equal(res$b.pip.hyperprior, 0.5)   # Default 0.5

  # Assert: Matrix and Vector Dimensions
  expect_true(is.matrix(res$a.coef))
  expect_equal(dim(res$a.coef), c(3, 2))    # K rows, P columns

  expect_equal(length(res$a.pip), 3)        # length K
  expect_equal(length(res$b.coef), 3)       # length K
  expect_equal(length(res$b.pip), 3)        # length K
})

# --- 2. Test Conditional Exclusion (Categorical/Binary) -----------------------
test_that("define_init_values excludes precisions when variables are categorical", {
  # Act: Set M_cont and Y_cont to FALSE
  res <- define_init_values(
    P = 1, K = 1,
    M_cont = FALSE, Y_cont = FALSE,
    m.prec.init = NULL, y.prec.init = NULL,
    direct.coef.init = NULL,
    a.pip.hyperprior.init = NULL, b.pip.hyperprior.init = NULL
  )

  # Assert: Precision parameters should NOT exist in the list
  expect_false("m.prec" %in% names(res))
  expect_false("y.prec" %in% names(res))

  # Assert: The other base parameters should still be there
  expect_true("a.coef" %in% names(res))
  expect_true("direct.coef" %in% names(res))
})

# --- 3. Test Custom Initialization Overrides ----------------------------------
test_that("define_init_values respects user-supplied custom values", {
  # Act: Supply explicit numbers instead of NULL
  res <- define_init_values(
    P = 1, K = 2,
    M_cont = TRUE, Y_cont = TRUE,
    m.prec.init = 10,
    y.prec.init = 20,
    direct.coef.init = 5,
    a.pip.hyperprior.init = 0.8,
    b.pip.hyperprior.init = 0.2
  )

  # Assert: Ensure custom values override the defaults
  expect_equal(res$m.prec, c(10, 10))      # Custom 10, replicated K times
  expect_equal(res$y.prec, 20)             # Custom 20
  expect_equal(res$direct.coef, c(5))      # Custom 5, replicated P times
  expect_equal(res$a.pip.hyperprior, 0.8)  # Custom 0.8
  expect_equal(res$b.pip.hyperprior, 0.2)  # Custom 0.2
})
