library(ggplot2)
library(dplyr)

#Dynamic directory path mapping
repository <- file.path(dirname(rstudioapi::getSourceEditorContext()$path))
setwd(repository)

df <- read.csv("../../raw_data/dflows_last_update.csv")

# Reorder factor by year to control y-axis order
df <- df %>%
  mutate(dflow = factor(dflow, levels = dflow[order(lastupdated)]))

# Heatmap style chart
ggplot(df, aes(x = "", y = dflow, fill = lastupdated)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "green", high = "red", trans = "reverse") +
  labs(
    title = "Heatmap of Data Flows by Last Updated Year",
    fill = "Last Updated",
    y = "Data Flow",
    x = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank()
  )
