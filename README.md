# grantdatavalidator

The goal of grantdatavalidator is to validate grant data that has passed NDA validation for use in the BSMN.

## Installation

You can install `grantdatavalidator` with `devtools`:

``` r
devtools::install_github("bsmn/grantdatavalidator")
```

## Example

This is a basic example which shows you how to validate manifests uploaded to Synapse.

It assumes that you have uploaded the three required manifest files and annotated them with the appropriate `nda_short_name` (one of `genomics_subject02`, `genomics_sample03`, or `nichd_btb02`) and `grant`.

``` r
library(grantdatavalidator)
library(synapser)
synLogin()

# A table that aggregates all submitted manifests - don't change this
manifestsviewid <- 'syn12031228'

# the Synapse folder ID of where the three manifests are
parentid <- 'syn12345678'

res <- validate(manifestsviewid, parentid)
```

## RStudio

If you install this package and use RStudio, there is an [RMarkdown template](https://rstudio.github.io/rstudio-extensions/rmarkdown_templates.html) available titled 'BSMN Grant Data Validation Report'. 
