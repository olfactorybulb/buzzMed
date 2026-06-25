# Create a valid dummy list based on your required structure
# We define this outside the test_that blocks so we can reuse it easily
dummy_list <- list(
  priors       = c("m.prec","y.prec",
                   "direct.coef","a.pip.hyperprior","b.pip.hyperprior"),
  distribution = c("dgamma","dgamma","dnorm","dbeta","dbeta"),
  arguments    = c("1,0.001","1,0.001",
                   "0,1.0E-6","3,3","3,3"),
  template     = c("%s[j] ~ %s(%s)","%s ~ %s(%s)","%s[p] ~ %s(%s)",
                   "%s ~ %s(%s)","%s ~ %s(%s)")
)
dummy_df <- as.data.frame(dummy_list)

# --- 1. Test Input Pre-processing (List to DF) --------------------------------

test_that("make_parms_main correctly coerces a list to a dataframe", {
  # Act: Pass the list with advanced = 'myprior' to bypass other logic
  # If it fails to convert, the downstream make_parms_from_df will likely crash
  result <- make_parms_main(my_prior = dummy_list, advanced = "myprior")

  # Assert: The output must be a dataframe (assuming make_parms_from_df returns one)
  expect_s3_class(result, "data.frame")
})


# --- 2. Test Validation and Errors --------------------------------------------

test_that("make_parms_main throws an error for invalid 'advanced' arguments", {
  # Assert: Catch the specific error string
  expect_error(
    make_parms_main(advanced = "invalid_string"),
    regexp = "'advanced' received an unrecognized value"
  )
})

test_that("make_parms_main throws an error if advanced = 'myprior' but my_prior is NULL", {
  expect_error(
    make_parms_main(advanced = "myprior", my_prior = NULL),
    regexp = "requires a dataframe.*but 'my_prior' is NULL"
  )
})


# --- 3. Test Routing Priority & Messages --------------------------------------

test_that("make_parms_main correctly prioritizes my_prior over named arguments", {
  # Act & Assert: We expect a specific message when both are provided
  expect_message(
    result <- make_parms_main(
      my_prior = dummy_df,
      m.prec.shape = 1, # Trigger named argument
      advanced = NULL
    ),
    regexp = "Both 'my_prior' and named arguments supplied. 'my_prior' takes priority."
  )

  expect_s3_class(result, "data.frame")
})

test_that("advanced = FALSE ignores my_prior with a message", {
  expect_message(
    make_parms_main(my_prior = dummy_df, advanced = FALSE),
    regexp = "'my_prior' is ignored when advanced = FALSE."
  )
})

test_that("advanced = 'myprior' ignores named arguments with a message", {
  expect_message(
    make_parms_main(my_prior = dummy_df, m.prec.shape = 1, advanced = "myprior"),
    regexp = "Named arguments are ignored when advanced = 'myprior'."
  )
})
