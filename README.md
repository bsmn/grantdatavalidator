# grantdatavalidator

The goal of grantdatavalidator is to validate grant data that has passed NDA validation for use in the BSMN.

## Installation

You can install `grantdatavalidator` with `devtools`:

``` r
devtools::install_github("bsmn/grantdatavalidator")
```

## Example

This is a basic example which shows you how to validate manifests uploaded to Synapse:

``` r
library(grantdatavalidator)
library(synapser)
synLogin()

# A table that aggregates all submitted manifests - don't change this
manifestsviewid <- 'syn12031228'

# the folder ID of where your manifests are
parentid <- 'syn12345678'

res <- validate(manifestsviewid, parentid)
```
