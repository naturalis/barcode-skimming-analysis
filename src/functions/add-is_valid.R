# Add validation status to both NHM and Naturalis datasets
add_validation_status <- function(df) {
  df %>%
    mutate(
      is_valid = !is.na(nuc_basecount) &  # Check if sequence exists
        ambig_basecount <= 6 &     # Ambiguous bases threshold
        nuc_basecount >= 500 &     # Minimum length threshold
        error == "None" &          # No processing errors
        stop_codons == 0 &         # No stop codons
        # Check if identification is in observed taxa
        # Need to handle NA values in either field
        (!is.na(identification) & !is.na(obs_taxon) & 
           str_detect(obs_taxon, fixed(identification)))
    )
}

joined_data$nhm <- add_validation_status(joined_data$nhm)
joined_data$naturalis <- add_validation_status(joined_data$naturalis)