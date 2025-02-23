# Calculate success rates and validation failure reasons
param_validation <- bind_rows(
  NHM = joined_data$nhm %>% filter(!is_control),
  Naturalis = joined_data$naturalis %>% filter(!is_control),
  .id = "institution"
) %>%
  group_by(institution, r_param, s_param) %>%
  summarise(
    total_attempts = n(),
    valid_rate = mean(is_valid, na.rm = TRUE) * 100,
    # Failure reasons (calculated independently)
    ambig_fail_rate = mean(ambig_basecount > 6, na.rm = TRUE) * 100,
    length_fail_rate = mean(nuc_basecount < 500, na.rm = TRUE) * 100,
    tax_fail_rate = mean(!str_detect(obs_taxon, fixed(identification)), na.rm = TRUE) * 100,
    stop_codon_rate = mean(stop_codons > 0, na.rm = TRUE) * 100,
    .groups = "drop"
  )

# Rest of the visualization code remains the same but uses param_validation directly
validation_heatmap <- ggplot(param_validation, 
                             aes(x = factor(r_param), y = factor(s_param))) +
  geom_tile(aes(fill = valid_rate)) +
  scale_fill_viridis_c(labels = percent_format()) +
  facet_wrap(~institution) +
  labs(
    x = "Read Length Multiplier (r)",
    y = "Sequence Similarity Threshold (s)",
    fill = "Valid Sequences (%)",
    title = "Validation Success Rate by Parameter Combination"
  ) +
  theme(plot.title = element_text(hjust = 0.5))

save_plot("validation_param_heatmap.png", validation_heatmap,
          width = fig_width * 1.5, height = fig_height)

# Create failure reason breakdown
failure_breakdown <- param_validation %>%
  pivot_longer(
    cols = ends_with("_rate"),
    names_to = "metric",
    values_to = "rate"
  ) %>%
  mutate(
    metric = factor(metric,
                    levels = c("valid_rate", "ambig_fail_rate", "length_fail_rate", 
                               "tax_fail_rate", "stop_codon_rate"),
                    labels = c("Valid Sequences", "Ambiguity Failures", 
                               "Length Failures", "Taxonomic Failures", 
                               "Stop Codon Failures"))
  ) %>%
  ggplot(aes(x = factor(r_param), y = rate, fill = factor(s_param))) +
  geom_col(position = "dodge") +
  facet_grid(metric ~ institution, scales = "free_y") +
  scale_fill_viridis_d(name = "Similarity\nThreshold (s)") +
  scale_y_continuous(labels = percent_format(scale = 1)) +
  labs(
    x = "Read Length Multiplier (r)",
    y = "Rate (%)",
    title = "Parameter Effects on Validation Success and Failure Modes"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text.x = element_text(angle = 0),
    strip.text.y = element_text(angle = 0)
  )

save_plot("validation_failure_breakdown.png", failure_breakdown,
          width = fig_width * 1.5, height = fig_height * 2)

# Create summary table of optimal parameters
optimal_params <- param_validation %>%
  group_by(institution) %>%
  slice_max(valid_rate, n = 1) %>%
  select(institution, r_param, s_param, valid_rate, 
         ambig_fail_rate, length_fail_rate, tax_fail_rate, stop_codon_rate) %>%
  arrange(institution)

print("Optimal parameter combinations by institution:")
print(optimal_params)