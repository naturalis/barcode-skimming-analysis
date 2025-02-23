# Add parameters directly to joined_data frames
joined_data$nhm <- joined_data$nhm %>%
  mutate(
    r_param = as.numeric(str_remove_all(r, "\\[|\\]")),
    s_param = as.numeric(str_remove_all(s, "\\[|\\]"))
  )

joined_data$naturalis <- joined_data$naturalis %>%
  mutate(
    r_param = as.numeric(str_extract(sequence_id, "(?<=_r_)\\d+(\\.\\d+)?")),
    s_param = as.numeric(str_extract(sequence_id, "(?<=_s_)\\d+"))
  )