# --- Arrange: Create a dummy dataset for the parser to validate against ---
dummy_data <- data.frame(
  X = rnorm(10),
  M1 = rnorm(10),
  M2 = rnorm(10),
  Y = rnorm(10),
  UnusedVar = rnorm(10)
)

# --- 1. The Happy Path (Perfect Syntax) ---------------------------------------
test_that(".parse_buzz_syntax correctly extracts Y, M, and X", {
  # Act
  # Note: When running devtools::test(), internal functions are available.
  # If running line-by-line in the console, you may need buzzMed:::.parse_buzz_syntax
  result <- .parse_buzz_syntax("Y ~ M1 + M2 | X", dummy_data)

  # Assert: It should return a list with exactly the right variables
  expect_type(result, "list")
  expect_equal(result$Y, "Y")
  expect_equal(result$M, c("M1", "M2"))
  expect_equal(result$X, "X")
})

# --- 2. Robustness to Messy Strings (Whitespace/Formatting) -------------------
test_that(".parse_buzz_syntax handles extra spaces and weird formatting", {
  # Act: Give it a really ugly, space-filled string
  result_messy <- .parse_buzz_syntax("  Y   ~M1+   M2| X  ", dummy_data)

  # Assert: It should strip the whitespace and still work perfectly
  expect_equal(result_messy$Y, "Y")
  expect_equal(result_messy$M, c("M1", "M2"))
  expect_equal(result_messy$X, "X")
})

# --- 3. Invalid Syntax Errors (The Sad Path) ----------------------------------
test_that(".parse_buzz_syntax throws specific errors for bad syntax", {
  # Missing the pipe for X
  expect_error(
    .parse_buzz_syntax("Y ~ M1 + M2 + X", dummy_data),
    regexp = "Invalid model syntax" # Matches the error you saw in your logs!
  )

  # Missing the tilde for Y
  expect_error(
    .parse_buzz_syntax("Y = M1 + M2 | X", dummy_data),
    regexp = "Invalid model syntax"
  )

  # Completely empty
  expect_error(
    .parse_buzz_syntax("", dummy_data)
  )
})

# --- 4. Dataset Validation (Missing Variables) --------------------------------
test_that(".parse_buzz_syntax throws an error if variables aren't in dataset", {
  # M3 and Z do not exist in dummy_data
  expect_error(
    .parse_buzz_syntax("Y ~ M1 + M3 | Z", dummy_data),
    regexp = "not found in dataset|missing" # Adjust this regex to match your actual error message
  )
})
