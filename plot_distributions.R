# Libraries ---------------------------------------------------------------

library(readr)
library(dplyr)
library(ggplot2)

# Load data ---------------------------------------------------------------

ecoli_models <- readr::read_csv("data/bigg/organism.csv") %>%
  filter(grepl("^Escherichia coli", .$strain, ignore.case = TRUE)) %>%
  pull(model)

bigg_df <- readr::read_csv("data/bigg/metrics.csv") %>%
  filter(
    # Filter excessive amount of E. coli models.
    !(model %in% ecoli_models) |
      # Maintain latest E. coli model.
      (model == "iML1515")
  )

uminho_df <- readr::read_csv("data/uminho/metrics.csv")

mmodel_df <- readr::read_csv("data/mmodel/metrics.csv")

total_df <- bind_rows(bigg_df, uminho_df, mmodel_df) %>%
  mutate(
    model = factor(model),
    collection = factor(collection)
  )

# Transform data ----------------------------------------------------------

meta_df <- total_df %>%
  filter(is.finite(metric)) %>%
  group_by(test) %>%
  do(plot = ggplot(
        .,
        aes(x = metric, fill = collection, fill = collection, color = collection)
      ) +
      ggtitle(.$title) +
      geom_freqpoly(binwidth = 0.02) +
      coord_cartesian(xlim = c(0, 1)) +
      scale_fill_brewer(palette = "Set1") +
      scale_color_brewer(palette = "Set1") +
      xlab("Metric") +
      ylab("Frequency")
  )


for (i in 1:nrow(meta_df)) {
  print(meta_df$plot[[i]])
  ggsave(file.path("figures", sprintf("%s.pdf", meta_df$test[[i]])))
}
