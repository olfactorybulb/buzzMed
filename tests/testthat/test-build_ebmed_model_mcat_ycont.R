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
test_that("build_ebmed_model_mcat_ycont returns a character string", {
  model_str <- build_ebmed_model_mcat_ycont(P = 2, K = 3, parms = dummy_parms)
  expect_type(model_str, "character")
  expect_true(nchar(model_str) > 100)
})

# --- 2. Dynamic Loops (Binary Mediators) --------------------------------------
test_that("build_ebmed_model_mcat_ycont correctly models binary mediators", {
  model_str <- build_ebmed_model_mcat_ycont(P = 1, K = 2, parms = dummy_parms)

  # Assert: M is categorical, so we expect dbern and logit
  expect_match(model_str, "logit\\(p\\.m1\\[i\\]\\) <- inprod\\(X\\[i, \\], a\\[1, \\]\\)")
  expect_match(model_str, "m2\\[i\\] ~ dbern\\(p\\.m2\\[i\\]\\)")
})

# --- 3. Outcome Equation (Continuous Logic) -----------------------------------
test_that("build_ebmed_model_mcat_ycont uses continuous logic for y", {
  model_str <- build_ebmed_model_mcat_ycont(P = 1, K = 2, parms = dummy_parms)

  # Assert: Y is continuous, so we need dnorm and y.prec
  expect_match(model_str, "y\\[i\\] ~ dnorm\\(mu\\.y\\[i\\], y\\.prec\\)")

  # Assert: b_effects use the inprod string you specified
  expect_match(model_str, "mu\\.y\\[i\\] <- inprod\\(X\\[i, \\], direct\\.coef\\[\\]\\)\\+ inprod\\(m1\\[i\\],b\\[1\\]\\)\\+ inprod\\(m2\\[i\\],b\\[2\\]\\)")
})

# --- 4. Prior Injection (Including Precision) ---------------------------------
test_that("build_ebmed_model_mcat_ycont injects outcome precision prior", {
  model_str <- build_ebmed_model_mcat_ycont(P = 1, K = 1, parms = dummy_parms)

  # Assert: Crucially, y.prec MUST be injected because Y is continuous
  expect_match(model_str, "y\\.prec ~ dgamma\\(1,0\\.001\\)")
})
