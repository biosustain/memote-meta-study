# Libraries ---------------------------------------------------------------

library(readr)
library(dplyr)
library(ggplot2)

# Load data ---------------------------------------------------------------

meta_df <- read_csv("data/meta.csv")
bigg_df <- read_csv("data/bigg/metrics.csv")
uminho_df <- read_csv("data/uminho/metrics.csv")
total_df <- bind_rows(bigg_df, uminho_df)
total_df$source <- factor(total_df$source)
total_df$model_id <- factor(total_df$model_id)

# Transform data ----------------------------------------------------------

for (i in 1:nrow(meta_df)) {
  test_case <- meta_df$test_case[i]
  title_text <- meta_df$title[i]
  tmp <- total_df %>%
    select(model_id, source, metric = test_case)
  print(
    ggplot(tmp, aes(x = metric, fill = source)) +
      geom_histogram(position = "dodge", binwidth = 0.05, alpha = 0.6) +
      coord_cartesian(xlim = c(0, 1)) +
      scale_fill_brewer(palette = "Set1") +
      ggtitle(title_text) +
      xlab("Metric") +
      ylab("Frequency")
  )
  ggsave(file.path("figures", sprintf("%s.pdf", test_case)))
}
