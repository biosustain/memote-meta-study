# Libraries ---------------------------------------------------------------

library(readr)
library(dplyr)
library(ggplot2)
library(ggforce)
library(cowplot)
library(stringr)
source("scripts/helpers.R")

# Load data ---------------------------------------------------------------

scored_df <- read_csv("data/scored_tests.csv.gz")

ecoli_models <- readr::read_csv("data/bigg/organism.csv.gz") %>%
  filter(grepl("^Escherichia coli", .$strain, ignore.case = TRUE)) %>%
  pull(model)

bigg_df <- readr::read_csv("data/bigg.csv.gz") %>%
  filter(
    # Filter excessive amount of E. coli strain models.
    !(model %in% ecoli_models) |
      # Maintain latest E. coli model.
      (model %in% c("iML1515", "iJO1366", "iAF1260", "iJR904"))
  ) %>%
  mutate(collection = "bigg")

uminho_df <- readr::read_csv("data/uminho.csv.gz") %>%
  mutate(collection = "uminho")

mmodel_df <- readr::read_csv("data/mmodel.csv.gz") %>%
  mutate(collection = "ebrahim")

agora_df <- readr::read_csv("data/agora.csv.gz") %>%
  mutate(collection = "agora")

embl_df <- readr::read_csv("data/embl_gems.csv.gz") %>%
  mutate(collection = "embl")

path_df <- readr::read_csv("data/path2models.csv.gz") %>%
  mutate(collection = "path")

seed_df <- readr::read_csv("data/seed.csv.gz") %>%
  mutate(collection = "seed")

total_df <- bind_rows(
  bigg_df,
  uminho_df,
  mmodel_df,
  agora_df,
  embl_df,
  path_df,
  seed_df
) %>%
  filter(
    # The following tests have non-normalized metrics or non-numeric results.
    (!(test %in% c(
      "test_biomass_open_production",
      "test_metabolic_coverage",
      "test_essential_precursors_not_in_biomass",
      "test_find_duplicate_reactions"
    ))
    )
  ) %>%
  mutate(
    model = factor(model),
    collection = factor(collection, levels = c("agora", "embl", "path", "seed", "bigg", "ebrahim", "uminho")),
    test = factor(test),
    section = factor(section),
    numeric = as.numeric(numeric),
    score = case_when( test %in% only_scored_tests ~ (1 - metric), !(test %in% only_scored_tests) ~ metric),
    ylabels = str_wrap(y_axis_labels[as.character(test)], width = 40),
    xlabels = collection_labels[collection]
  )

metric_tsne_tbl <- readr::read_csv("data/metric_tsne.csv.gz") %>%
  mutate(
    collection = factor(collection)
  )

# Plot Layers -------------------------------------------------------------
sina_layers <- list(
  theme_bw(base_size = 21),
  geom_sina(size = 1, scale = FALSE),
  coord_cartesian(ylim = c(0, 1)),
  scale_x_discrete(labels = collection_labels),
  scale_color_manual(values = colors, labels = collection_labels, guide = FALSE),
  theme(
    axis.title.y=element_text(size = 12),
    axis.title.x=element_blank(),
    axis.text.x=element_text(angle = 45, hjust = 1, vjust = 1))
)

layers <- list(
  theme_bw(base_size = 21),
  geom_point(size = 1),
  scale_color_manual(values = colors, guide = FALSE),
  # scale_color_manual(values = colors, labels = collection_labels),
  theme(
    axis.title.x=element_blank(),
    axis.title.y=element_blank(),
    axis.ticks = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    plot.margin = unit(c(21, 21, 21, 21), "pt")
  )
)

# Generate individual plot objects -----------------------------------------------------------

test_selection = c("test_stoichiometric_consistency", "test_find_reversible_oxygen_reactions", "test_blocked_reactions")

panel_df <- total_df %>%
  filter(test %in% test_selection) %>%
  group_by(test) %>%
  do(plot_sina = ggplot(
    .,
    aes(x = collection, y = score, col = collection, label = model)
  ) + sina_layers + ylab(.$ylabels)
  )

clustering <- ggplot(metric_tsne_tbl, aes(x = x, y = y, color = collection)) +
  layers

# ggplot(test_of_interest_df, aes(x = collection, y = score, col = collection, label = model)
#        ) + sina_layers + facet_wrap(~test, ncol = 1)

grid = plot_grid(
  clustering,
  panel_df$plot_sina[[3]] + theme(axis.text.x=element_blank()),
  panel_df$plot_sina[[2]] + theme(axis.text.x=element_blank()),
  panel_df$plot_sina[[1]], labels = c("a", "b", "c", "d"), nrow = 4, align = "v", label_size = 30)

save_plot("manuscript_panel_figure.pdf", grid, nrow = 4, base_aspect_ratio = 1.6180)

