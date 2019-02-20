# Libraries ---------------------------------------------------------------

library(readr)
library(dplyr)
library(ggplot2)

# Load data ---------------------------------------------------------------

scored_df <- read_csv("scored_tests.csv")

ecoli_models <- readr::read_csv("data/bigg/organism.csv") %>%
  filter(grepl("^Escherichia coli", .$strain, ignore.case = TRUE)) %>%
  pull(model)

bigg_df <- readr::read_csv("data/bigg/metrics.csv") %>%
  filter(
    # Filter excessive amount of E. coli models.
    !(model %in% ecoli_models) |
      # Maintain latest E. coli model.
      (model %in% c("iML1515", "iJO1366", "iAF1260", "iJR904"))
  )

uminho_df <- readr::read_csv("data/uminho/metrics.csv")

# Contains mostly duplicates.
# mmodel_df <- readr::read_csv("data/mmodel/sbml/metrics.csv")
mmodel3_df <- readr::read_csv("data/mmodel/sbml3/metrics.csv")

agora_df <- readr::read_csv("data/AGORA/metrics.csv")

carveme_df <- readr::read_csv("data/embl_gems/metrics.csv")

path_df <- readr::read_csv("data/BioModels_Database-r27_p2m-whole_genome_metabolism/metrics.csv")

total_df <- bind_rows(
    bigg_df,
    uminho_df,
    mmodel3_df,
    agora_df,
    carveme_df,
    path_df
  ) %>%
  mutate(
    model = factor(model),
    collection = factor(collection),
    test = factor(test),
    section = factor(section),
    score = 1 - metric
  )

# Transform data ----------------------------------------------------------

# Plot per Test -----------------------------------------------------------

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

meta_df <- total_df %>%
  filter(is.finite(metric)) %>%
  group_by(test) %>%
  do(plot = ggplot(
    .,
    aes(x = collection, y = metric, fill = collection)
  ) +
    ggtitle(.$title) +
    geom_violin(draw_quantiles = c(0.25, 0.5, 0.75)) +
    geom_jitter(height = 0, width = 0.3, fill = "black", color = "black") +
    coord_cartesian(ylim = c(0, 1)) +
    scale_fill_brewer(palette = "Set1") +
    xlab("") +
    ylab("Metric")
  )

for (i in 1:nrow(meta_df)) {
  message(sprintf("Plotting %s", meta_df$test[[i]]))
  tryCatch(
    {
      print(meta_df$plot[[i]])
      ggsave(file.path("figures", "tests",
                       sprintf("%s.png", meta_df$test[[i]])))
    },
    error = function(err) {
      print(sprintf("Could not plot %s!", meta_df$test[[i]]))
    }
  )
}

# Plot raw ----------------------------------------------------------------

meta_df <- total_df %>%
  filter(
    is.finite(numeric),
    numeric < 2000,
    test == "test_biomass_consistency"
    ) %>%
  group_by(test) %>%
  do(plot = ggplot(
    .,
    aes(x = numeric, color = collection, fill = collection)
  ) +
    ggtitle(.$title) +
    geom_freqpoly(mapping = aes(y = ncount), binwidth = 0.05) +
    # geom_violin(draw_quantiles = c(0.25, 0.5, 0.75)) +
    # geom_jitter(height = 0, width = 0.3, fill = "black", color = "black", alpha=0.3) +
    scale_fill_brewer(palette = "Set1") +
    scale_color_brewer(palette = "Set1") +
    # scale_y_log10() +
    xlab("") +
    ylab("Raw")
  )

meta_df <- total_df %>%
  filter(is.finite(numeric)) %>%
  group_by(test) %>%
  do(plot = ggplot(
    .,
    aes(x = collection, y = numeric, fill = collection)
  ) +
    ggtitle(.$title) +
    geom_violin(draw_quantiles = c(0.25, 0.5, 0.75)) +
    geom_jitter(height = 0, width = 0.3, fill = "black", color = "black", alpha=0.3) +
    scale_fill_brewer(palette = "Set1") +
    xlab("") +
    ylab("Raw")
  )

for (i in 1:nrow(meta_df)) {
  message(sprintf("Plotting %s", meta_df$test[[i]]))
  tryCatch(
    {
      print(meta_df$plot[[i]])
      ggsave(file.path("figures", "raw_tests",
                       sprintf("%s.png", meta_df$test[[i]])))
    },
    error = function(err) {
      print(sprintf("Could not plot %s!", meta_df$test[[i]]))
    }
  )
}

# Plot per Section --------------------------------------------------------

section_df <- total_df %>%
  filter(is.finite(numeric)) %>%
  group_by(section) %>%
  do(plot = ggplot(
    .,
    aes(x = collection, y = score, fill = collection)
  ) +
    geom_violin(draw_quantiles = c(0.25, 0.5, 0.75)) +
    geom_jitter(height = 0, width = 0.3, fill = "black", color = "black") +
    coord_cartesian(ylim = c(0, 1)) +
    scale_fill_brewer(palette = "Set1") +
    xlab("") +
    ylab("Score")
  )

for (i in 1:nrow(section_df)) {
  message(sprintf("Plotting %s", section_df$section[[i]]))
  tryCatch(
    {
      print(section_df$plot[[i]])
      ggsave(file.path("figures", "sections",
                       sprintf("%s.svg", section_df$section[[i]])))
    },
    error = function(err) {
      print(sprintf("Could not plot %s!", section_df$section[[i]]))
      print(err)
    }
  )
}

# Plot Overview -----------------------------------------------------------

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
