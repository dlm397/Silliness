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