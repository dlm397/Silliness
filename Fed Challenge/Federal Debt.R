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
  
  # Check if 'value' column exists, rename to appropriate name
  if ("value" %in% colnames(data)) {
    data <- data %>%
      select(date, value) %>%
      rename(!!series_name := value)
  } else {
    stop("Column 'value' not found in series ", series_id)
  }
  
  return(data)
}

# Fetch data
tryCatch({
  # Fetch FYGFGDQ188S (Federal Debt held by Public as Percent of GDP)
  gfde_gdp <- fetch_fred_data(
    series_id = "FYGFGDQ188S",
    start_date = "2021-01-01",
    end_date = Sys.Date(),
    series_name = "Debt_to_GDP"
  )

  # Fetch GFDEBTN (Total Public Debt)
  gfdebtn <- fetch_fred_data(
    series_id = "GFDEBTN",
    start_date = "2021-01-01",
    end_date = Sys.Date(),
    series_name = "Total_Debt"
  )

  # Check date ranges for debugging
  cat("GFDEGDQ188S date range:", format(min(gfde_gdp$date), "%Y-%m-%d"), "to", format(max(gfde_gdp$date), "%Y-%m-%d"), "\n")
  cat("GFDEBTN date range:", format(min(gfdebtn$date), "%Y-%m-%d"), "to", format(max(gfdebtn$date), "%Y-%m-%d"), "\n")

  # Plot 1: Federal Debt held by Public as Percent of GDP (GFDEGDQ188S)
  p1 <- ggplot(gfde_gdp, aes(x = date, y = Debt_to_GDP)) +
    geom_line(color = "#0C233C", size = 1.2) +
    geom_point(color = "#0C233C", size = 2) +
    scale_y_continuous(
      breaks = seq(91, 97, by = 2),  # Y-ticks every 10% from 80% to 140%
      labels = function(x) paste0(x, "%")  # Add % to labels
    ) +
    labs(
      title = "Federal Debt held by Public as Percent of GDP",
      subtitle = "(Quarterly, Seasonally Adjusted, 2021-Current)",
      x = "Quarterly",
      y = "Percent of GDP (%)",
      caption = "Source: FRED (Series: FYGFGDQ188S)"
    ) +
    theme(
      panel.background = element_rect(fill = "white", color = NA),
      panel.grid.major = element_line(color = "gray95"),
      plot.background = element_rect(fill = "white", color = NA),
      legend.position = "none",
      axis.text = element_text(size = 16)
    )

  # Plot 2: Total Public Debt (GFDEBTN)
  p2 <- ggplot(gfdebtn, aes(x = date, y = Total_Debt / 1000000)) +  # Convert millions to trillions
    geom_line(color = "#E87722", size = 1.2) +
    geom_point(color = "#E87722", size = 2) +
    scale_y_continuous(
      breaks = seq(28, 40, by = 2),  # Y-ticks every 2 trillion from 28 to 40
      labels = function(x) paste0(x, "T")  # Add T for trillions
    ) +
    labs(
      title = "Federal Debt: Total Public Debt",
      subtitle = "(Quarterly, Not Seasonally Adjusted, 2021-Current)",
      x = "Quarterly",
      y = "Total Debt (USD)",
      caption = "Source: FRED (Series: GFDEBTN)"
    ) +
    theme(
      legend.position = "none",
      panel.background = element_rect(fill = "white", color = NA),
      panel.grid.major = element_line(color = "gray95"),
      plot.background = element_rect(fill = "white", color = NA),
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold"),
      axis.text = element_text(size = 16),
    )

  # Save the plots
  ggsave("Plots/federal_debt_public_held.png", p1, width = 8, height = 5, dpi = 600)
  ggsave("Plots/total_federal_debt.png", p2, width = 8, height = 5, dpi = 600)

}, error = function(e) {
  cat("Error in processing: ", e$message, "\n")
})