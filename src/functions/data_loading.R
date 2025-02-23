load_validation_data <- function(nhm_path, naturalis_path) {
  # Load NHM validation data
  nhm_validation <- read_delim(
    nhm_path,
    delim="\t",
    show_col_types = FALSE
  ) %>%
    mutate(
      process_id = str_extract(sequence_id, "^[^_]+"),
      is_control = str_detect(process_id, "-NC$")
    )
  
  # Load Naturalis validation data  
  naturalis_validation <- read_delim(
    naturalis_path, 
    delim="\t",
    show_col_types = FALSE
  ) %>%
    mutate(
      process_id = str_extract(sequence_id, "^[^_]+"),
      is_control = str_detect(process_id, "-NC$")
    )
  
  # Return both datasets in a named list
  return(list(
    nhm = nhm_validation,
    naturalis = naturalis_validation
  ))
}