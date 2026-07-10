# ==============================================================================
# Setup Dummy Data for Testing
# ==============================================================================

# Dimensions: N = 5 subjects, T = 3 timepoints, K = 4 slices/variables
set.seed(42)
N <- 5
Tv <- 3
K <- 4

# Format A: 3-D Numeric Array
dummy_array <- array(rnorm(N * Tv * K), dim = c(N, Tv, K))

# Format B: Named List of Matrices
dummy_list <- list(
  X1 = dummy_array[, , 1],
  X2 = dummy_array[, , 2],
  M1 = dummy_array[, , 3],
  Y  = dummy_array[, , 4]
)

# Format C: Long Data Frame
dummy_df <- data.frame(
  id   = rep(1:N, each = Tv),
  time = rep(1:Tv, times = N),
  X1   = as.vector(dummy_array[, , 1]),
  X2   = as.vector(dummy_array[, , 2]),
  M1   = as.vector(dummy_array[, , 3]),
  Y    = as.vector(dummy_array[, , 4])
)


# ==============================================================================
# Tests for Format A: 3-D Array Input
# ==============================================================================

test_that("longBMed works with 3-D array format and single X", {
  # Skip if rjags is not installed / JAGS is missing
  skip_if_not_installed("rjags")

  # Default model layout: X=1, M=2:3, Y=4
  expect_message(
    res <- longBMed(model = NULL, data = dummy_array, n.burnin = 2, n.iter = 5),
    "No formula provided\\. Defaulting to:"
  )

  expect_true(is.matrix(res))
  expect_true("ind.joint[1,1]" %in% rownames(res))
})

test_that("longBMed works with 3-D array format, custom formula, and multiple X", {
  skip_if_not_installed("rjags")

  # Custom index expression: Y=4 ~ X=1+2 | M=3
  res <- longBMed(model = "4 ~ 1+2 | 3", data = dummy_array, n.burnin = 2, n.iter = 5)

  expect_true(is.matrix(res))
  # With multiple X, ind.joint should have 3 dimensions in JAGS: [k, p, t]
  expect_true("ind.joint[1,1,1]" %in% rownames(res))
})

test_that("longBMed catches invalid input types or dimensions for 3-D array", {
  # Non-numeric array
  char_array <- dummy_array
  char_array[1,1,1] <- "a"
  expect_error(longBMed(data = char_array), "`data` must contain numeric values\\.")

  # Too few slices
  small_array <- array(rnorm(5*3*2), dim = c(5, 3, 2))
  expect_error(longBMed(data = small_array), "at least 3 slices")

  # Passing real R formula object to array format
  expect_error(
    longBMed(model = Y ~ X | M, data = dummy_array),
    "model` must be a character string"
  )
})


# ==============================================================================
# Tests for Format B: Named List Input
# ==============================================================================

test_that("longBMed works with Named List format (Single & Multiple X)", {
  skip_if_not_installed("rjags")

  # Single X
  res_single <- longBMed(model = "Y ~ X1 | M1", data = dummy_list, n.burnin = 2, n.iter = 5)
  expect_true(is.matrix(res_single))
  expect_true("ind.joint[1,1]" %in% rownames(res_single))

  # Multiple X
  res_multi <- longBMed(model = "Y ~ X1 + X2 | M1", data = dummy_list, n.burnin = 2, n.iter = 5)
  expect_true(is.matrix(res_multi))
  expect_true("ind.joint[1,1,1]" %in% rownames(res_multi))
})

test_that("longBMed enforces errors for Named List formatting missteps", {
  # Missing model formula
  expect_error(longBMed(model = NULL, data = dummy_list), "formula is required")

  # Index expression used on named list
  expect_error(longBMed(model = "4 ~ 1 | 2:3", data = dummy_list), "looks like an index expression")

  # Missing variable in data list
  expect_error(longBMed(model = "MissingVar ~ X1 | M1", data = dummy_list), "Variable\\(s\\) not found")
})


# ==============================================================================
# Tests for Format C: Long Data Frame Input
# ==============================================================================

test_that("longBMed works with Long-format Data Frames", {
  skip_if_not_installed("rjags")

  res <- longBMed(model = "Y ~ X1 + X2 | M1", data = dummy_df, n.burnin = 2, n.iter = 5)
  expect_true(is.matrix(res))
  expect_true("ind.joint[1,1,1]" %in% rownames(res))
})

test_that("longBMed catches Data Frame structural requirements", {
  # Change the expected string to match the id/time check
  expect_error(
    longBMed(model = "Y ~ X1 | M1", data = data.frame(a = 1, b = 2)),
    "must contain columns named 'id' and 'time'"
  )

  # Missing id/time columns with NULL model
  bad_df <- dummy_df
  bad_df$id <- NULL
  expect_error(
    longBMed(model = "Y ~ X1 | M1", data = bad_df),
    "must contain columns named 'id' and 'time'"
  )
})


# ==============================================================================
# Tests for Internal Parsing Logic (.parse_index_formula / .expand_index_expr)
# ==============================================================================

test_that("Internal formula parsers correctly identify constraints and syntax errors", {

  # Test index string validation issues
  expect_error(.parse_index_formula("10 ~ 1+2", K=10), "must contain '\\|'")
  expect_error(.parse_index_formula("10 1+2 | 3", K=10), "must contain '~'")
  expect_error(.parse_index_formula("10+11 ~ 1 | 2", K=12), "must resolve to exactly one slice index")

  # Cross-role assignment error checking
  expect_error(.parse_index_formula("3 ~ 1+3 | 4:5", K=10), "appear in both Y and X")
  expect_error(.parse_index_formula("3 ~ 1+2 | 3:5", K=10), "appear in both Y and M")
  expect_error(.parse_index_formula("3 ~ 1+4 | 4:5", K=10), "appear in both X and M")

  # Syntax expanding bugs
  expect_error(.expand_index_expr("1:5:9", K=10), "Invalid range")
  expect_error(.expand_index_expr("5:1", K=10), "start > end")
  expect_error(.expand_index_expr("abc", K=10), "Non-integer token")
  expect_error(.expand_index_expr("11", K=10), "Slice index/indices out of bounds")

  # Test that duplicate within-role indices are successfully
  # handled and deduplicated by the parsing logic
  parsed <- .parse_index_formula("4 ~ 1+1 | 2:3", K = 5)
  expect_equal(parsed$x_idx, 1L)

  # Check informational messages for unassigned slices
  expect_message(
    .parse_index_formula("4 ~ 1 | 2", K=5),
    "Note: slice\\(s\\) 3, 5 were not assigned"
  )
})
