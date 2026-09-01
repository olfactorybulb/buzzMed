## Test environments
* Local: macOS Sequoia 15.6.1 (aarch64), R 4.4.2
* Ubuntu 24.04.4 LTS, R 4.6.1 (R-hub)

## R CMD check results
0 errors | 0 warnings | 1 note
* NOTE: `unable to verify current time`
This appears to be a local environment/time verification note and does not affect package functionality.

## Release summary
This is an update release of buzzMed, version 0.1.4.

## Changes
* Recreated the `framing2` dataset from the original `framing` dataset in the `mediation` package.
* Updated the variables included in `framing2` while retaining the original variable names where applicable.
* Added numeric recodings `english2`, `anx2`, and `educ2` based on the corresponding variables in the original `framing` dataset.
* Updated the `framing2` documentation to reflect the revised dataset and recoding schemes.
