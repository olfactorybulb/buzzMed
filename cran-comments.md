## Resubmission
This is a resubmission of buzzMed 0.1.2. This version addresses the feedback provided by Benjamin Altmann regarding documentation formatting and console output.

## New Fixes
* **Title:** Shortened the package title in the DESCRIPTION file to "Bayesian Understanding for Mediator Selection Framework" to meet the 65-character limit.
* **Document Formatting:** Removed the `\dontrun{}` wrapper where the example takes less than 5 seconds to run.
  * Interactive examples (e.g., `run_parms_wizard()`) is still wrapped in `\dontrun{}` as they require user input and cannot be executed by automated checks.
* **References:** Updated methodological references in all core exported functions to the requested `Authors (Year) "Title" <doi:...>` format.
* **Console Output:** Modified certain lines in `run_parms_wizard` to use `message()` instead of `cat()` for status updates to allow suppression.
  * Added a `verbose` argument to `run_parms_wizard()` to give users control over non-essential console output.
  * Documented the new `verbose` argument in the corresponding `.Rd` documentation.
  * We have retained `cat()` and `readline() `in select interactive components where they are necessary for user input, while ensuring all non-interactive status updates now use `message()` for better suppressibility.

## Test environments
* Local: macOS Sequoia 15.6.1 (aarch64), R 4.4.2
* Windows Server (win-builder): R-devel (2026-05-12 r90049 ucrt)
* Linux (R-hub): Ubuntu Linux 24.04.4 LTS, R-release (4.6.0)

## R CMD check results
0 errors | 0 warnings | 1 note
* NOTE: `unable to verify current time.`
This was observed on both local and win-builder environments. This is a transient system clock synchronization issue on the build servers and does not affect package functionality.

## Previous Fixes
* **Testing:** Implemented a formal unit testing suite using the `testthat` framework.
* **Function Renaming:** Updated naming convention (e.g., from `buzzMYcat` to `buzzEBMcatMcatY`) to improve consistency across the package and better reflect the model structures.
* **Code Coverage:** Added `@examples` to all exported functions to demonstrate usage and ensure code paths are exercised during checks.
* **Extended Prior Customization:** Added support for user-defined prior distributions via new internal parameter-handling logic and flexible input methods.
* **Interactive Tooling:** Introduced `run_parms_wizard()`, a command-line interface to assist users in interactively configuring prior data frames.
* **Documentation:** Updated function descriptions with comprehensive literature references.
* **Addressed Reviewer Feedback:** Removed redundant introductory phrasing ("The buzzMed package offers...") from the Description field.
  * Added methodological references in the requested `Authors (Year) <doi:...>` format to the documentation of all core exported functions to provide context where the specific methods are implemented.
