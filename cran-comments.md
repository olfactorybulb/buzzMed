## Resubmission
This is a resubmission of `buzzMed 0.1.2`. Compared to the previous submission, I have:
* Removed + file LICENSE from the DESCRIPTION file.
* Removed the redundant LICENSE file from the package root as requested.

## Test environments
* Local: macOS Sequoia 15.6.1 (aarch64), R 4.4.2
* Windows Server (win-builder): R-devel (2026-05-03 r89994 ucrt)
* Linux (R-hub): Ubuntu Linux 24.04.4 LTS, R-release (4.6.0)

## R CMD check results
0 errors | 0 warnings | 1 note
* NOTE: `unable to verify current time.`
This was observed on both local and win-builder environments. This is a transient system clock synchronization issue on the build servers and does not affect package functionality.

## Fixes
* **Testing:** Implemented a formal unit testing suite using the `testthat` framework.
* **Function Renaming:** Updated naming convention (e.g., from `buzzMYcat` to `buzzEBMcatMcatY`) to improve consistency across the package and better reflect the model structures.
* **Code Coverage:** Added `@examples` to all exported functions to demonstrate usage and ensure code paths are exercised during checks.
* **Extended Prior Customization:** Added support for user-defined prior distributions via new internal parameter-handling logic and flexible input methods.
* **Interactive Tooling:** Introduced `run_parms_wizard()`, a command-line interface to assist users in interactively configuring prior data frames.
* **Documentation:** Updated function descriptions with comprehensive literature references.
* **Addressed Reviewer Feedback:** Removed redundant introductory phrasing ("The buzzMed package offers...") from the Description field.
  * Added methodological references in the requested `Authors (Year) <doi:...>` format to the documentation of all core exported functions to provide context where the specific methods are implemented.
