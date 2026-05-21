# buzzMed 0.1.2

* **CRAN Compliance**:
  * Shortened package title to meet 65-character limit.
  * Reformatted all methodological references to use the `<doi:...>` bracket notation.
  * Replaced `\dontrun{}` with `if(interactive()){}` for interactive functions.
  * Unwrapped `\dontrun{}` examples when the code can execute in under 5 seconds.
  * Added and documented a `verbose` argument for `run_parms_wizard()`.

* **Function Renaming**: Updated core fitting functions for better clarity on data types:
  * `buzzEBMcat`   -> `buzzEBMcatMcontY`
  * `buzzMYcat`    -> `buzzEBMcatMcatY`
  * `buzzMYcont`   -> `buzzEBMcontMcontY`
  * `buzzYcat`     -> `buzzEBMcontMcatY`

* **Custom Prior Support**: Users can now manually define prior distributions via new internal parameter-handling logic.
  * Added `run_parms_wizard()`, a CLI tool to guide users through creating prior dataframes interactively.
  * Added `make_parms_main()` as a internal central router for parameter handling.
  * Added `make_parms_from_argument()` and `make_parms_from_df()` for flexible input methods.

* **Internal Improvements**:
  * Transitioned console output to use `message()` for better control.
  * Organized internal logic into `helpers.R` and `extract_results.R` to improve maintainability and result readability.

---

# buzzMed 0.1.1
* Added unit tests using `testthat` to ensure model stability.
* Added executable examples to all main functions.
* Fixed `.Rbuildignore` to exclude internal development files.

---
# buzzMed 0.1.0
* Initial CRAN submission.
