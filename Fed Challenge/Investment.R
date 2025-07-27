# Required libraries
library(fredr)
library(ggplot2)
library(dplyr)

# FRED API key
fredr_set_key("9a1589f16ea211e13d4bdde8ac424667")

# API, Residential Investment (PRFI)
residential_investment_change <- fredr(
  series_id = "A011RL1Q225SBEA",
  observation_start = as.Date("2021-01-01")
) %>%
  select(date, value) %>%
  rename(Residential_Investment_Change = value)

# Plot as a line chart
p1 <- ggplot(residential_investment_change, aes(x = date, y = Residential_Investment_Change)) +
  geom_line(color = "#E87722", size = 1.2) +
  geom_point(data = tail(residential_investment_change, 1), aes(x = date, y = Residential_Investment_Change), color = "red", size = 3) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  scale_y_continuous(
      breaks = seq(-20, 10, by = 10),  # Y-ticks every 25 billion from 300 to 450
      labels = function(x) paste0(x, "%")  # Add B for billions
    ) +
  labs(
    title = "Real Residential Fixed Investment",
    subtitle = "(% Change, Quarterly, SAAR, Chained 2017 Dollars)",
    x = NULL,
    y = "Percent Change",
    caption = "Source: FRED (Series: A011RL1Q225SBEA)"
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

# Saves plot
ggsave("Plots/Change in Residential Investment.png", p1, width = 8, height = 5, dpi = 600)





# Fetch data from FRED for the three series
gdp_components <- bind_rows(
  fredr(series_id = "Y033RX1Q020SBEA", observation_start = as.Date("2021-01-01")) %>%
    select(date, value) %>% mutate(series = "Equipment"),
  fredr(series_id = "Y001RX1Q020SBEA", observation_start = as.Date("2021-01-01")) %>%
    select(date, value) %>% mutate(series = "IP Products"),
  fredr(series_id = "B009RX1Q020SBEA", observation_start = as.Date("2021-01-01")) %>%
    select(date, value) %>% mutate(series = "Structures")
) %>%
  mutate(series = factor(series, levels = c("Equipment", "IP Products", "Structures"))) %>%
  group_by(series) %>%
  arrange(date) %>%
  mutate(pct_change = (value / lag(value) - 1) * 100) %>%
  ungroup() %>%
  filter(!is.na(pct_change))

# Create stacked bar chart with percent change
p <- ggplot(gdp_components, aes(x = date, y = pct_change, fill = series)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("#0C233C", "#E87722", "#9e29ad")) +
  scale_y_continuous(
    breaks = seq(-20, 20, by = 5),
    labels = function(x) paste0(x, "%")
  ) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  labs(
    title = "Real Private Nonresidential Fixed Investment",
    subtitle = "(Component-wise, Quarterly % Change, SAAR)",
    x = NULL,
    y = "Percent Change",
    fill = "",
    caption = "Source: FRED (Series: Y033RX1Q020SBEA, Y001RX1Q020SBEA, B009RX1Q020SBEA)"
  ) +
  theme_minimal(base_size = 15) +
  theme(
    legend.position = "top",
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "gray95"),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold"),
    axis.text = element_text(size = 16),
  )

# Save plot
ggsave("Plots/Real_nonresidential_fixed.png", p, width = 8, height = 5, dpi = 600)
