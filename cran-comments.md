## Test environments
* Local: macOS Sequoia 15.6.1 (aarch64), R 4.4.2

## R CMD check results
0 errors | 0 warnings | 1 note
* NOTE: `unable to verify current time`
This appears to be a local environment/time verification note and does not affect package functionality.

## Release summary
This is an update release for buzzMed 0.1.3.

## Changes
* Added `longBMed()` for exploratory Bayesian mediation analysis with longitudinal data.
* Added two example datasets: `singlespikes` and `sublongspikes`.
* Added documentation for the new datasets.
* Updated examples to use the corrected model syntax `Y ~ X | M`.
* Updated tests to reflect the current model syntax and prior structure.
* Fixed previous package check issues related to examples, documentation, and namespace imports.
