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

# Contains mostly duplicates.
# mmodel_df <- readr::read_csv("data/mmodel/sbml/metrics.csv")
mmodel3_df <- readr::read_csv("data/mmodel/sbml3/metrics.csv")

total_df <- bind_rows(bigg_df, uminho_df, mmodel3_df) %>%
  mutate(
    model = factor(model),
    collection = factor(collection),
    metric = 1 - metric
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

total_df %>%
  filter(is.finite(metric)) %>%
ggplot(
  .,
  aes(x = metric, fill = collection, color = collection)
) +
  geom_freqpoly(binwidth = 0.02) +
  coord_cartesian(xlim = c(0, 1)) +
  scale_fill_brewer(palette = "Set1") +
  scale_color_brewer(palette = "Set1") +
  xlab("Metric") +
  ylab("Frequency") +
  facet_wrap(~ test, scales = "free_y")

ggsave(file.path("figures", "overview.pdf"), width = 84, height = 118, units = "cm")

total_df %>%
  filter(is.finite(metric)) %>%
  ggplot(
    .,
    aes(x = collection, y = metric, fill = collection)
  ) +
  geom_violin(draw_quantiles = c(0.25, 0.5, 0.75)) +
  geom_jitter(height = 0, width = 0.3, fill = "black", color = "black") +
  coord_cartesian(ylim = c(0, 1)) +
  scale_fill_brewer(palette = "Set1") +
  # scale_color_brewer(palette = "Set1") +
  xlab("Collection") +
  ylab("Metric") +
  facet_wrap(~ test)

ggsave(file.path("figures", "violins.pdf"), width = 84, height = 118, units = "cm")
