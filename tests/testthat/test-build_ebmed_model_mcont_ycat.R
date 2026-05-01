# --- Arrange: Create the dummy parms dataframe ---
dummy_parms <- data.frame(
  priors       = c("a.coef","b.coef","m.prec","y.prec",
                   "direct.coef","a.pip.hyperprior","b.pip.hyperprior"),
  distribution = c("dnorm","dnorm","dgamma","dgamma","dnorm","dbeta","dbeta"),
  arguments    = c("0,1.0E-6","0,1.0E-6",
                   "1,0.001","1,0.001",
                   "0,1.0E-6","3,3","3,3"),
  template     = c("%s[j,p] ~ %s(%s)","%s[j] ~ %s(%s)",
                   "%s[j] ~ %s(%s)","%s ~ %s(%s)","%s[p] ~ %s(%s)",
                   "%s ~ %s(%s)","%s ~ %s(%s)"),
  stringsAsFactors = FALSE
)

# --- 1. Basic Structure -------------------------------------------------------
test_that("build_ebmed_model_mcont_ycat returns a valid character string", {
  model_str <- build_ebmed_model_mcont_ycat(P = 2, K = 3, parms = dummy_parms)

  expect_type(model_str, "character")
  expect_true(nchar(model_str) > 200)
})

# --- 2. Mediator Equation (Continuous Logic & Precision) ----------------------
test_that("build_ebmed_model_mcont_ycat uses continuous logic for M", {
  model_str <- build_ebmed_model_mcont_ycat(P = 1, K = 2, parms = dummy_parms)

  # Assert: dnorm used for mediators, and precision is indexed (m.prec[1])
  expect_match(model_str, "m1\\[i\\] ~ dnorm\\(mu\\.m1\\[i\\], m\\.prec\\[1\\]\\)")
  expect_match(model_str, "m2\\[i\\] ~ dnorm\\(mu\\.m2\\[i\\], m\\.prec\\[2\\]\\)")

  # Assert: mu.m uses inprod
  expect_match(model_str, "mu\\.m1\\[i\\] <- inprod\\(X\\[i, \\], a\\[1,\\]\\)")
})

# --- 3. Outcome Equation (Binary Logic) ---------------------------------------
test_that("build_ebmed_model_mcont_ycat uses binary logic for Y", {
  model_str <- build_ebmed_model_mcont_ycat(P = 2, K = 2, parms = dummy_parms)

  # Assert: dbern and logit for outcome y
  expect_match(model_str, "y\\[i\\] ~ dbern\\(prob\\.y\\[i\\]\\)")

  # Assert: b effects use the specific multiplier logic from the code
  expect_match(model_str, "logit\\(prob\\.y\\[i\\]\\) <- inprod\\(X\\[i, \\], direct\\.coef\\[\\]\\) \\+ \\(m1\\[i\\] \\* b\\[1\\]\\) \\+ \\(m2\\[i\\] \\* b\\[2\\]\\)")
})

# --- 4. Prior Injection (m.prec only, NO y.prec) ------------------------------
test_that("build_ebmed_model_mcont_ycat injects precision correctly", {
  model_str <- build_ebmed_model_mcont_ycat(P = 1, K = 1, parms = dummy_parms)

  # Assert: m.prec is injected inside the K loop
  expect_match(model_str, "m\\.prec\\[j\\] ~ dgamma\\(1,0\\.001\\)")

  # Assert: y.prec should NOT be injected into the hyperparameters block
  # We test this by ensuring the y.prec template string is NOT in the final model
  expect_false(grepl("y\\.prec ~ dgamma", model_str))

  # Assert: Hyperpriors are present
  expect_match(model_str, "a\\.pip\\.hyperprior ~ dbeta\\(3,3\\)")
})
