join_validation_taxonomy <- function(validation_data, lab_sheet_path, taxonomy_path) {
  
  # Load BOLD sheets
  lab_data <- read_delim(
    lab_sheet_path,
    delim="\t",
    show_col_types = FALSE
  ) %>%
    # Parse collection dates and calculate specimen age
    mutate(
      collection_date = dmy(Collection.Date),
      specimen_age_years = interval(collection_date, today()) / years(1)
    ) %>%
    # Keep only needed columns
    select(
      Process.ID,
      Sample.ID,
      collection_date,
      specimen_age_years
    )
  
  taxonomy_data <- read_delim(
    taxonomy_path,
    delim="\t",
    show_col_types = FALSE
  ) %>%
    # Keep taxonomic hierarchy columns
    select(
      Sample.ID,
      Phylum:Species
    )
  
  # Join validation data with lab sheet and taxonomy
  joined_nhm <- validation_data$nhm %>%
    left_join(lab_data, by = c("process_id" = "Process.ID")) %>%
    left_join(taxonomy_data, by = c("Sample.ID" = "Sample.ID"))
  
  joined_naturalis <- validation_data$naturalis %>%
    left_join(lab_data, by = c("process_id" = "Process.ID")) %>%
    left_join(taxonomy_data, by = c("Sample.ID" = "Sample.ID"))
  
  return(list(
    nhm = joined_nhm,
    naturalis = joined_naturalis
  ))
}