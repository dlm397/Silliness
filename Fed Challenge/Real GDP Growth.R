library(fredr)
library(ggplot2)
library(dplyr)

# Set your FRED API key
fredr_set_key("9a1589f16ea211e13d4bdde8ac424667")

# Function to fetch and inspect FRED data
fetch_fred_data <- function(series_id, start_date, end_date, series_name) {
  data <- tryCatch({
    fredr(
      series_id = series_id,
      observation_start = as.Date(start_date),
      observation_end = as.Date(end_date)
    )
  }, error = function(e) {
    stop("Error fetching series ", series_id, ": ", e$message)
  })
  
  # Print column names for debugging
  cat("Columns for", series_id, ":", colnames(data), "\n")
  
  # Check if 'value' column exists, rename to GDP_Growth
  if ("value" %in% colnames(data)) {
    data <- data %>%
      select(date, value) %>%
      rename(GDP_Growth = value)
  } else {
    stop("Column 'value' not found in series ", series_id)
  }
  
  return(data)
}

# Fetch data
tryCatch({
  gdp_growth <- fetch_fred_data(
    series_id = "A191RL1Q225SBEA",
    start_date = "2021-01-01",
    end_date = Sys.Date(),
    series_name = "Historical GDP Growth"
  ) %>%
    mutate(type = "Historical")

  pgdp_mean <- fetch_fred_data(
    series_id = "GDPC1CTM",
    start_date = "2025-01-01",
    end_date = "2027-01-01",
    series_name = "Projected GDP Mean"
  ) %>%
    mutate(type = "Projected")

  pgdp_low <- fetch_fred_data(
    series_id = "GDPC1RL",
    start_date = "2025-01-01",
    end_date = "2027-01-01",
    series_name = "Projected GDP Low"
  )

  pgdp_high <- fetch_fred_data(
    series_id = "GDPC1RH",
    start_date = "2025-01-01",
    end_date = "2027-01-01",
    series_name = "Projected GDP High"
  )

  # Combine projected data for ribbon
  pgdp_range <- pgdp_mean %>%
    left_join(pgdp_low, by = "date", suffix = c("_mean", "_low")) %>%
    left_join(pgdp_high, by = "date") %>%
    rename(GDP_Growth_mean = GDP_Growth_mean,
           GDP_Growth_low = GDP_Growth_low,
           GDP_Growth_high = GDP_Growth)

  # Combine historical and mean projected data for line plotting
  combined_data <- bind_rows(gdp_growth, pgdp_mean)

  # Plot
  p <- ggplot() +
    # Shaded area for projected range
    geom_ribbon(data = pgdp_range, aes(x = date, ymin = GDP_Growth_low, ymax = GDP_Growth_high), 
                fill = "#E87722", alpha = 0.2) +
    # Historical and projected mean line
    geom_line(data = combined_data, aes(x = date, y = GDP_Growth, color = type, linetype = type), 
              size = 1.2) +
    geom_point(data = gdp_growth, aes(x = date, y = GDP_Growth), color = "#0C233C", size = 2) +
    scale_color_manual(values = c("Historical" = "#0C233C", "Projected" = "#E87722")) +
    scale_linetype_manual(values = c("Historical" = "solid", "Projected" = "dashed")) +
    scale_y_continuous(
      breaks = seq(0, 6, by = 2),
      labels = function(x) paste0(x, "%")  # Add % to labels
    ) +
    labs(
      title = "US Real GDP Growth with Projections",
      subtitle = "(Quarterly, SAAR, 2021-2027)",
      x = "Quarterly",
      y = "Real GDP Growth",
      caption = "Source: FRED (Series: A191RL1Q225SBEA, GDPC1CTM, GDPC1RL, GDPC1RH)"
    ) +
    theme(
      legend.position = "bottom",
      legend.title = element_blank(),
      legend.text = element_text(size = 14),
      panel.background = element_rect(fill = "white", color = NA),
      panel.grid.major = element_line(color = "gray95"),
      plot.background = element_rect(fill = "white", color = NA),
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold"),
      axis.text = element_text(size = 16),
    )
  # Save the plot
  ggsave("Plots/US_Proj_Real_GDP_Growth.png", p, width = 8, height = 5, dpi = 600)

}, error = function(e) {
  cat("Error in processing: ", e$message, "\n")
})