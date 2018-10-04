#' @export
validate <- function(manifestsviewid, parentid) {
  submissiondata <- get_submission(manifestsviewid, parentid)

  subjectdatarow <- submissiondata %>%
    dplyr::filter(nda_short_name == "genomics_subject02")
  sampledatarow <- submissiondata %>%
    dplyr::filter(nda_short_name == "genomics_sample03")
  nichddatarow <- submissiondata %>%
    dplyr::filter(nda_short_name == "nichd_btb02")

  subjectdata <- read_and_validate(id = subjectdatarow$id,
                                   version = subjectdatarow$currentVersion,
                                   validation_func = validate_subject_data)

  nichddata <- read_and_validate(id = nichddatarow$id,
                                 version = nichddatarow$currentVersion,
                                 validation_func = validate_nichd_data,
                                 subjectdata = subjectdata)

  sampledata <- read_and_validate(id = sampledatarow$id,
                                  version = sampledatarow$currentVersion,
                                  validation_func = validate_sample_data,
                                  submissiondata = submissiondata,
                                  subjectdata = subjectdata,
                                  nichddata = nichddata)

  # submissiondata <- submissiondata %>% tibble::as_tibble()
  # submissiondata$data <- list(sampledata, subjectdata, nichddata)
  # return(submissiondata)
  return(list(submission = submissiondata,
              sampledata = sampledata,
              subjectdata = subjectdata,
              nichddata = nichddata))
}

#' @export
get_submission <- function(manifestsviewid, parentid) {
  query <- glue::glue("select * from {manifestsviewid} where parentId=\'{parentid}\'")
  dres <- synapser::synTableQuery(query)
  submissiondata <- dres$asDataFrame() %>%
    validate_manifests_submission() %>%
    dplyr::arrange(nda_short_name)
  return(submissiondata)
}

#' @export
read_and_validate <- function(id, version, validation_func, ...) {
  dataobj <- synapser::synGet(id, version = version)
  readr::read_csv(dataobj$path, skip = 1) %>%
    validation_func(., ...)
}

#' @export
validate_manifests_submission <- function(data) {
  # There should only be three files
  # with distinct values for 'nda_short_name'
  # in the set of allowed short name values
  expected_nda_short_names <- c("genomics_sample03",
                                "genomics_subject02",
                                "nichd_btb02")
  data %>%
    assertr::chain_start() %>%
    assertr::verify(nrow(data) == 3) %>%
    assertr::verify(assertr::is_uniq(nda_short_name)) %>%
    assertr::verify(assertr::not_na(grant)) %>%
    assertr::verify(dplyr::n_distinct(grant) == 1) %>%
    assertr::verify(nda_short_name %in% expected_nda_short_names) %>%
    assertr::chain_end() %>%
    tibble::as_tibble()
}

#' @export
validate_subject_data <- function(data) {
  data %>%
    assertr::chain_start() %>%
    assertr::verify(assertr::is_uniq(subjectkey)) %>%
    assertr::verify(assertr::is_uniq(src_subject_id)) %>%
    assertr::verify(assertr::is_uniq(sample_id_original)) %>%
    assertr::verify(assertr::is_uniq(sample_id_biorepository)) %>%
    assertr::chain_end() %>%
    tibble::as_tibble()
}

#' @export
validate_nichd_data <- function(data, subjectdata) {
  data %>%
    assertr::chain_start() %>%
    assertr::verify(assertr::is_uniq(sample_id_original)) %>%
    assertr::verify(subjectkey %in% subjectdata$subjectkey) %>%
    assertr::verify(src_subject_id %in% subjectdata$src_subject_id) %>%
    assertr::chain_end() %>%
    tibble::as_tibble()
}

#' @export
validate_sample_data <- function(data, submissiondata, subjectdata, nichddata) {
  data %>%
    assertr::chain_start() %>%
    assertr::verify(assertr::not_na(site)) %>%
    assertr::verify(dplyr::n_distinct(site) == 1) %>%
    assertr::assert(assertr::in_set(submissiondata$grant), site) %>%
    assertr::verify(subjectkey %in% subjectdata$subjectkey) %>%
    assertr::verify(src_subject_id %in% subjectdata$src_subject_id) %>%
    assertr::verify(sample_id_biorepository %in% nichddata$sample_id_original) %>%
    assertr::chain_end() %>%
    tibble::as_tibble()
}
