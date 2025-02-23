join_validation_taxonomy <- function(validation_data, lab_sheet_path, taxonomy_path) {
  # Load BOLD sheets with explicit column types
  lab_data <- read_delim(
    lab_sheet_path,
    delim="\t",
    col_types = cols(
      .default = col_character(),  # Set all columns to character by default
      `COI-5P Seq. Length` = col_character(),
      `COI-5P Trace Count` = col_double(),
      `Image Count` = col_double()
    )
  )
  
  # Check for parsing issues in lab data
  lab_problems <- problems(lab_data)
  if(nrow(lab_problems) > 0) {
    warning("Lab sheet parsing issues:")
    print(lab_problems)
  }
  
  lab_data <- lab_data %>%
    # Parse collection dates and calculate specimen age
    mutate(
      collection_date = dmy(`Collection Date`),
      specimen_age_years = interval(collection_date, today()) / years(1)
    ) %>%
    # Keep only needed columns
    select(
      `Process ID`,
      `Sample ID`,
      collection_date,
      specimen_age_years
    )
  
  taxonomy_data <- read_delim(
    taxonomy_path,
    delim="\t",
    col_types = cols(.default = col_character())  # All columns as character
  )
  
  # Check for parsing issues in taxonomy data
  tax_problems <- problems(taxonomy_data)
  if(nrow(tax_problems) > 0) {
    warning("Taxonomy parsing issues:")
    print(tax_problems)
  }
  
  taxonomy_data <- taxonomy_data %>%
    # Keep taxonomic hierarchy columns
    select(
      `Sample ID`,
      Phylum:Species
    )
  
  # Join validation data with lab sheet and taxonomy
  joined_nhm <- validation_data$nhm %>%
    left_join(lab_data, by = c("process_id" = "Process ID")) %>%
    left_join(taxonomy_data, by = c("Sample ID" = "Sample ID"))
  
  joined_naturalis <- validation_data$naturalis %>%
    left_join(lab_data, by = c("process_id" = "Process ID")) %>%
    left_join(taxonomy_data, by = c("Sample ID" = "Sample ID"))
  
  return(list(
    nhm = joined_nhm,
    naturalis = joined_naturalis
  ))
}