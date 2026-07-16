## Test environments
* Local: macOS Sequoia 15.6.1 (aarch64), R 4.4.2
* Ubuntu 24.04.4 LTS, R 4.6.1 (R-hub)
* Windows Server 2022 x64 (win-builder), R 4.6.1

## R CMD check results
0 errors | 0 warnings | 1 note
* NOTE: `unable to verify current time`
This appears to be a local environment/time verification note and does not affect package functionality.

## Release summary
This is an update release of buzzMed, version 0.1.3.

## Changes
* Added `longBMed()` for exploratory Bayesian mediation analysis with longitudinal data.
* Added three example datasets: `singlespikes`, `sublongspikes` and `framing2`.
* Added documentation for the new datasets.
* Updated examples to use the corrected model syntax `Y ~ X | M`.
* Updated tests to reflect the current model syntax and prior structure.
* Fixed previous package check issues related to examples and documentations.
