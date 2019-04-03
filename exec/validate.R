#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(grantdatavalidator))
suppressPackageStartupMessages(library(synapser))
suppressPackageStartupMessages(library(optparse))

synLogin()

read_args <- function() {
  option_list <- list(
    make_option(c("--parent_id"), type = "character",
                help = "Synapse ID of folder with manifests to validate.",
                dest = "parent_id"),
    make_option(c("--manifests_file_view_id"), type = "character",
                help = "Synapse ID of file view with all manifests.",
                dest = "manifests_file_view_id",
                default = "syn12031228"))
                
  opt <- parse_args(OptionParser(option_list = option_list))
  return(opt)
}

# A table that aggregates all submitted manifests - don't change this
manifestsviewid <- opt$manifests_file_view_id

# the Synapse folder ID of where the three manifests are
parentid <- opt$parent_id

res <- validate(manifestsviewid, parentid)
