library(fredr)
library(ggplot2)
library(dplyr)
library(lubridate)

# Set your FRED API key
fredr_set_key("9a1589f16ea211e13d4bdde8ac424667")

# Function to fetch and inspect FRED data
fetch_fred_data <- function(series_id, start_date, end_date, series_name, period_label) {
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
  cat("Columns for", series_id, "(", period_label, "):", colnames(data), "\n")
  
  # Check if 'value' column exists, rename to Imports_Value
  if ("value" %in% colnames(data)) {
    data <- data %>%
      select(date, value) %>%
      rename(Imports_Value = value) %>%
      mutate(period = period_label)
  } else {
    stop("Column 'value' not found in series ", series_id)
  }
  
  return(data)
}

# Fetch data
tryCatch({
  # Fetch XTIMVA01USM667S for April 2023 - April 2024
  imports_2023_2024 <- fetch_fred_data(
    series_id = "XTIMVA01USM667S",
    start_date = "2023-05-01",
    end_date = "2024-04-01",
    series_name = "Imports_Value",
    period_label = "May 2023 - Apr 2024"
  )

  # Fetch XTIMVA01USM667S for May 2024 - April 2025
  imports_2024_2025 <- fetch_fred_data(
    series_id = "XTIMVA01USM667S",
    start_date = "2024-05-01",
    end_date = "2025-04-01",
    series_name = "Imports_Value",
    period_label = "May 2024 - Apr 2025"
  )

  # Combine data and align months
  combined_data <- bind_rows(imports_2023_2024, imports_2024_2025) %>%
    mutate(
      month = month(date, label = TRUE, abbr = FALSE),  # Extract month name (e.g., April, May)
      month = factor(month, levels = month.name[c(4:12, 1:3)])  # Order: April to March
    ) %>%
    arrange(date, period)

  # Check date and value ranges for debugging
  cat("May 2023 - Apr 2024 date range:", format(min(imports_2023_2024$date), "%Y-%m-%d"), "to", format(max(imports_2023_2024$date), "%Y-%m-%d"))
  cat("May 2024 - Apr 2025 date range:", format(min(imports_2024_2025$date), "%Y-%m-%d"), "to", format(max(imports_2024_2025$date), "%Y-%m-%d"))
  cat("Imports value range (billions):", min(combined_data$Imports_Value / 1000), "to", max(combined_data$Imports_Value / 1000))
  cat("Preview of combined data:")
  print(head(combined_data %>% select(date, month, Imports_Value, period), 20))

  # Plot
  p <- ggplot(combined_data, aes(x = month, y = Imports_Value / 1000000000, color = period)) +
    geom_line(aes(linetype = period, group = period), size = 1.2) +
    geom_point(size = 2) +
    scale_color_manual(values = c("May 2023 - Apr 2024" = "#0C233C", "May 2024 - Apr 2025" = "#E87722")) +
    scale_linetype_manual(values = c("May 2023 - Apr 2024" = "solid", "May 2024 - Apr 2025" = "dashed")) +
    scale_y_continuous(
      breaks = seq(250, 400, by = 15),  # Y-ticks every 25 billion from 300 to 450
      labels = function(x) paste0(x, "B")  # Add B for billions
    ) +
    labs(
      title = "Value of US Goods Imports, Compared by Month",
      subtitle = "(Monthly, Seasonally Adjusted, May 2023 - Apr 2025)",
      x = "Month",
      y = "Imports Value (Billions of USD)",
      caption = "Source: FRED (Series: XTIMVA01USM667S)",
      color = "Period",
      linetype = "Period"
    ) +
    theme(
      legend.position = "bottom",
      legend.text = element_text(size = 14),
      axis.text.x = element_text(size = 12, angle=23),
      panel.background = element_rect(fill = "white", color = NA),
      panel.grid.major = element_line(color = "gray95"),
      plot.background = element_rect(fill = "white", color = NA),
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold"),
      axis.text.y = element_text(size = 16),
    )

  # Save the plot
  ggsave("Plots/year_imports.png", p, width = 8, height = 5, dpi = 600)

}, error = function(e) {
  cat("Error in processing: ", e$message, "\n")
})