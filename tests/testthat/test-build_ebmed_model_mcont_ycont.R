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
test_that("build_ebmed_model_mcont_ycont returns a valid character string", {
  model_str <- build_ebmed_model_mcont_ycont(P = 2, K = 3, parms = dummy_parms)

  expect_type(model_str, "character")
  expect_true(nchar(model_str) > 200) # Should be quite long
})

# --- 2. Mediator Equation (Continuous Logic & Precision Indexing) -------------
test_that("build_ebmed_model_mcont_ycont uses dnorm and indexed precision for M", {
  model_str <- build_ebmed_model_mcont_ycont(P = 1, K = 2, parms = dummy_parms)

  # Assert: dnorm used for mediators, and precision is indexed (m.prec[1], m.prec[2])
  expect_match(model_str, "m1\\[i\\] ~ dnorm\\(mu\\.m1\\[i\\], m\\.prec\\[1\\]\\)")
  expect_match(model_str, "m2\\[i\\] ~ dnorm\\(mu\\.m2\\[i\\], m\\.prec\\[2\\]\\)")

  # Assert: mu.m uses inprod
  expect_match(model_str, "mu\\.m1\\[i\\] <- inprod\\(X\\[i, \\], a\\[1,\\]\\)")
})

# --- 3. Outcome Equation (Continuous Logic) -----------------------------------
test_that("build_ebmed_model_mcont_ycont uses dnorm for Y", {
  model_str <- build_ebmed_model_mcont_ycont(P = 2, K = 2, parms = dummy_parms)

  # Assert: dnorm for outcome y with a global y.prec
  expect_match(model_str, "y\\[i\\] ~ dnorm\\(mu\\.y\\[i\\], y\\.prec\\)")

  # Assert: b effects are added continuously via inprod
  expect_match(model_str, "\\+ inprod\\(m1\\[i\\],b\\[1\\]\\)\\+ inprod\\(m2\\[i\\],b\\[2\\]\\)")
})

# --- 4. Dual Precision Prior Injection ----------------------------------------
test_that("build_ebmed_model_mcont_ycont injects both precision priors correctly", {
  model_str <- build_ebmed_model_mcont_ycont(P = 1, K = 1, parms = dummy_parms)

  # Assert: m.prec is injected (inside the K loop in the code)
  expect_match(model_str, "m\\.prec\\[j\\] ~ dgamma\\(1,0\\.001\\)")

  # Assert: y.prec is injected (in the hyperparameters block)
  expect_match(model_str, "y\\.prec ~ dgamma\\(1,0\\.001\\)")

  # Assert: Hyperpriors are present
  expect_match(model_str, "a\\.pip\\.hyperprior ~ dbeta\\(3,3\\)")
  expect_match(model_str, "b\\.pip\\.hyperprior ~ dbeta\\(3,3\\)")
})
