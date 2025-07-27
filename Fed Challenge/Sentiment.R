library(fredr)
library(ggplot2)
library(dplyr)
library(scales)

# FRED API key
fredr_set_key("9a1589f16ea211e13d4bdde8ac424667")

# API, Consumer Sentiment (UMCSENT)
consumer_sentiment <- fredr(
  series_id = "UMCSENT",
  observation_start = as.Date("2021-01-01")
) %>%
  select(date, value) %>%
  rename(Consumer_Sentiment = value)

# API, Business Sentiment (BSCICP02USM460S)
business_confidence <- fredr(
  series_id = "BSCICP02USM460S",
  observation_start = as.Date("2021-01-01")
) %>%
  select(date, value) %>%
  rename(Business_Confidence = value)

# Plot Business Sentiment
p2 <- ggplot(business_confidence, aes(x = date, y = Business_Confidence)) +
  geom_line(color = "#0C233C", size = 1.2) +
  geom_point(data = tail(business_confidence, 1), aes(x = date, y = Business_Confidence), color = "red", size = 3) +
  scale_y_continuous(
      breaks = seq(0, 20, by = 10),
      labels = function(x) paste0(x, "%")  # Add % to labels
    ) +
  labs(
    title = "Business Confidence Composite Indicator ",
    subtitle = "(Percent, SA, Monthly, Manufacturing Sector, US)",
    x = NULL,
    y = "Percent",
    caption = "Source: FRED (Series: BSCICP02USM460S)"
  ) +
  theme_minimal(base_size = 15) +
  theme(
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "gray95"),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold"),
    axis.text = element_text(size = 16)
  )

# Plot Consumer Sentiment
p1 <- ggplot(consumer_sentiment, aes(x = date, y = Consumer_Sentiment)) +
  geom_line(color = "#E87722", size = 1.2) +
  geom_point(data = tail(consumer_sentiment, 1), aes(x = date, y = Consumer_Sentiment), color = "red", size = 3) +
  labs(
    title = "Consumer Sentiment Index",
    subtitle = "(U-Michigan, 1Q1966 = 100)",
    x = NULL,
    y = "Index Value",
    caption = "Source: FRED (Series: UMCSENT)"
  ) +
  theme_minimal(base_size = 15) +
  theme(
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "gray95"),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold"),
    axis.text = element_text(size = 16),
  )


# Save the plots
ggsave("Plots/Consumer_Sentiment.png", p1, width = 8, height = 5, dpi = 600)
ggsave("Plots/Business_Confidence_PMI.png", p2, width = 8, height = 5, dpi = 600)
