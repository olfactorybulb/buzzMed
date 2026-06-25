# --- Arrange: Create the dummy parms dataframe ---
dummy_parms <- data.frame(
  priors       = c("m.prec","y.prec",
                   "direct.coef","a.pip.hyperprior","b.pip.hyperprior"),
  distribution = c("dgamma","dgamma","dnorm","dbeta","dbeta"),
  arguments    = c("1,0.001","1,0.001",
                   "0,1.0E-6","3,3","3,3"),
  template     = c("%s[j] ~ %s(%s)","%s ~ %s(%s)","%s[p] ~ %s(%s)",
                   "%s ~ %s(%s)","%s ~ %s(%s)"),
  stringsAsFactors = FALSE
)

# --- 1. Basic Structure and Type ----------------------------------------------
test_that("build_ebmed_model_mcat_ycat returns a character string", {
  # Act
  model_str <- build_ebmed_model_mcat_ycat(P = 2, K = 3, parms = dummy_parms)

  # Assert
  expect_type(model_str, "character")
  expect_true(nchar(model_str) > 100) # Ensure it's not an empty string
})

# --- 2. Dynamic Loops (K Mediators and P Predictors) --------------------------
test_that("build_ebmed_model_mcat_ycat dynamically builds for K mediators", {
  # Act: Use 2 predictors and 3 mediators
  model_str <- build_ebmed_model_mcat_ycat(P = 2, K = 3, parms = dummy_parms)

  # Assert: It should explicitly contain equations for m1, m2, and m3
  expect_match(model_str, "logit\\(p\\.m1\\[i\\]\\) <- inprod\\(X\\[i, \\], a\\[1, \\]\\)")
  expect_match(model_str, "logit\\(p\\.m3\\[i\\]\\) <- inprod\\(X\\[i, \\], a\\[3, \\]\\)")

  # Assert: It should NOT contain an equation for m4
  expect_false(grepl("logit\\(p\\.m4\\[i\\]\\)", model_str))

  # Assert: The loops should limit to P=2 and K=3
  expect_match(model_str, "for \\(j in 1:3\\)") # K loop
  expect_match(model_str, "for \\(p in 1:2\\)") # P loop
})

# --- 3. Outcome Equation (Binary Logic) ---------------------------------------
test_that("build_ebmed_model_mcat_ycat uses logistic/bernoulli logic for y", {
  model_str <- build_ebmed_model_mcat_ycat(P = 1, K = 2, parms = dummy_parms)

  # Assert: Y is binary, so we need dbern and logit
  expect_match(model_str, "y\\[i\\] ~ dbern\\(prob\\.y\\[i\\]\\)")
  expect_match(model_str, "logit\\(prob\\.y\\[i\\]\\) <- inprod\\(X\\[i, \\], direct\\.coef\\[\\]\\) \\+ \\(m1\\[i\\] \\* b\\[1\\]\\) \\+ \\(m2\\[i\\] \\* b\\[2\\]\\)")
})

# --- 4. Prior Injection -------------------------------------------------------
test_that("build_ebmed_model_mcat_ycat properly injects prior strings", {
  model_str <- build_ebmed_model_mcat_ycat(P = 1, K = 1, parms = dummy_parms)

  # Assert: The formatted strings from the dataframe should be pasted in exactly
  expect_match(model_str, "a\\.pip\\.hyperprior ~ dbeta\\(3,3\\)")
  expect_match(model_str, "direct\\.coef\\[p\\] ~ dnorm\\(0,1\\.0E-6\\)")
})
