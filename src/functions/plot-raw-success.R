# Aggregate validation results by Process ID for each institution
process_level_summary <- bind_rows(
  NHM = joined_data$nhm %>%
    filter(!is_control) %>%
    group_by(process_id) %>%
    summarise(
      attempts = n(),
      any_valid = any(is_valid, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    summarise(
      total_specimens = n(),
      specimens_with_valid = sum(any_valid, na.rm = TRUE),
      success_rate = mean(any_valid, na.rm = TRUE) * 100,
      avg_attempts = mean(attempts)
    ),
  Naturalis = joined_data$naturalis %>%
    filter(!is_control) %>%
    group_by(process_id) %>%
    summarise(
      attempts = n(),
      any_valid = any(is_valid, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    summarise(
      total_specimens = n(),
      specimens_with_valid = sum(any_valid, na.rm = TRUE),
      success_rate = mean(any_valid, na.rm = TRUE) * 100,
      avg_attempts = mean(attempts)
    ),
  .id = "Institution"
)