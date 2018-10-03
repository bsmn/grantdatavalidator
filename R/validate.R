#' @export
validate <- function(manifestsView, parentId) {
  synapser::synLogin()

  # manifestsView <- 'syn12031228'
  # parentId <- 'syn12138863' # Weinberger
  # parentId <- 'syn12182254' # McConnell

  d <- synapser::synTableQuery(glue::glue('select * from {manifestsView} where parentId=\'{parentId}\''))$asDataFrame()

  d <- d %>%
    assertr::verify(nrow(d) == 3) %>%
    assertr::verify(assertr::is_uniq(nda_short_name)) %>%
    assertr::verify(nda_short_name %in% c('genomics_sample03', 'genomics_subject02', 'nichd_btb02'))

  subjectDataRow <- d %>% dplyr::filter(nda_short_name == "genomics_subject02")
  sampleDataRow <- d %>% dplyr::filter(nda_short_name == "genomics_sample03")
  nichdDataRow <- d %>% dplyr::filter(nda_short_name == "nichd_btb02")

  subjectData <- readr::read_csv(synapser::synGet(subjectDataRow$id,
                                                  version=subjectDataRow$currentVersion)$path,
                                 skip=1) %>%
    assertr::chain_start() %>%
    assertr::verify(assertr::is_uniq(subjectkey)) %>%
    assertr::verify(assertr::is_uniq(src_subject_id)) %>%
    assertr::verify(assertr::is_uniq(sample_id_original)) %>%
    assertr::verify(assertr::is_uniq(sample_id_biorepository)) %>%
    assertr::chain_end()

  nichdData <- readr::read_csv(synapser::synGet(nichdDataRow$id,
                                                version=nichdDataRow$currentVersion)$path,
                               skip=1) %>%
    assertr::chain_start() %>%
    assertr::verify(subjectkey %in% subjectData$subjectkey) %>%
    assertr::verify(src_subject_id %in% subjectData$src_subject_id) %>%
    assertr::verify(assertr::is_uniq(sample_id_original)) %>%
    assertr::chain_end()

  sampleData <- readr::read_csv(synapser::synGet(sampleDataRow$id,
                                                 version=sampleDataRow$currentVersion)$path,
                                skip=1)

  sampleData <- sampleData %>%
    assertr::chain_start() %>%
    assertr::verify(subjectkey %in% subjectData$subjectkey) %>%
    assertr::verify(src_subject_id %in% subjectData$src_subject_id) %>%
    assertr::verify(sample_id_biorepository %in% nichdData$sample_id_original) %>%
    assertr::verify(assertr::is_uniq(sample_id_original)) %>%
    assertr::chain_end()

  return(list(sampleData=sampleData, subjectData=subjectData, nichdData=nichdData))
}
