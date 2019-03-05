# Installation ------------------------------------------------------------
install.packages("ggforce")
install.packages("readr")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("ggforce")
install.packages("plotly")
install.packages("cowplot")

# Libraries ---------------------------------------------------------------
library(readr)
library(dplyr)
library(ggplot2)
library(ggforce)
library(stringr)
library(plotly)
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
    ylabels = str_wrap(y_axis_labels[as.character(test)], width = 30)
  )

# Plot Layers -------------------------------------------------------------

violin_layers <- list(
  theme_bw(base_size = 21),
  geom_jitter(height = 0, width = 0.4, size = 1, alpha = 0.1),
  # geom_violin(draw_quantiles = c(0.25, 0.5, 0.75)),
  coord_cartesian(ylim = c(0, 1)),
  scale_fill_manual(values = colors, guide = FALSE),
  scale_color_manual(values = colors, labels = collection_labels, guide = FALSE),
  # scale_x_discrete(labels = collection_labels),
  ylab("Score"),
  theme(
    axis.title.x = element_blank()
    # plot.margin = unit(c(21, 21, 21, 21), "pt")
  )
)

sina_layers <- list(
  theme_bw(base_size = 21),
  geom_sina(size = 1, scale = FALSE),
  coord_cartesian(ylim = c(0, 1)),
  scale_x_discrete(labels = collection_labels),
  scale_color_manual(values = colors, labels = collection_labels, guide = FALSE),
  theme(
    axis.title.y=element_text(size = 16),
    axis.title.x=element_text(size = 16),
    axis.text.x=element_text(angle = 45, hjust = 1, vjust = 1))
)

# Plot per Test -----------------------------------------------------------

meta_df_sina <- total_df %>%
  filter(is.finite(score)) %>%
  group_by(test, ylabels) %>%
  do(plot_sina = ggplot(
        .,
        aes(x = collection, y = score, col = collection, label = model)
      ) + sina_layers + ylab(.$ylabels)
  )

meta_df_violin <- total_df %>%
  filter(is.finite(score)) %>%
  group_by(test) %>%
  do(plot_violin = ggplot(
    .,
    aes(x = collection, y = score, col = collection, fill = collection, label = model)
  ) + violin_layers + ylab(.$ylabels)
  )

for (i in 1:nrow(meta_df_sina)) {
  message(sprintf("Plotting %s", meta_df_sina$test[[i]]))
  tryCatch(
    {
      ggsave(
        filename = sprintf("%s.%s", meta_df_sina$test[[i]], file_format),
        path = file.path("figures", "tests"),
        plot = meta_df_sina$plot_sina[[i]]
      )
    },
    error = function(err) {
      print(sprintf("Could not plot %s!", meta_df_sina$test[[i]]))
      print(err)
    }
  )
}

# Exploration in plotly ---------------------------------------------------
ggplotly(meta_df_violin$plot_violin[[1]])

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
    geom_jitter(height = 0, width = 0.4, alpha = 0.1, size=1) +
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
      print(err)
    }
  )
}

# Plot per Section --------------------------------------------------------

# Plot violins.
section_df <- total_df %>%
  filter(is.finite(score)) %>%
  group_by(section, collection, model) %>%
  summarise(avg_score = mean(score)) %>%
  ungroup() %>%
  group_by(section) %>%
  do(
    plot = ggplot(
      .,
      aes(x = collection, y = avg_score, fill = collection)
    ) + violin_layers
  )

# Generate files
for (i in 1:nrow(section_df)) {
  message(sprintf("Plotting %s", section_df$section[[i]]))
  tryCatch(
    {
      ggsave(
        filename = sprintf("%s.%s", section_df$section[[i]], file_format),
        path = file.path("figures", "sections"),
        plot = section_df$plot[[i]]
      )
    },
    error = function(err) {
      print(sprintf("Could not plot %s!", section_df$section[[i]]))
      print(err)
    }
  )
}

# Plot Overview -----------------------------------------------------------

total_df %>%
  filter(is.finite(score)) %>%
  ggplot(
    .,
    aes(x = collection, y = score, fill = collection)
  ) +
  geom_violin(draw_quantiles = c(0.25, 0.5, 0.75)) +
  coord_cartesian(ylim = c(0, 1)) +
  scale_fill_brewer(palette = "Set1", guide = FALSE) +
  ylab("Score") +
  theme(
    axis.title.x = element_blank()
  ) +
  facet_wrap( ~ test)

ggsave(
  filename = sprintf("overview.%s", file_format),
  path = file.path("figures"),
  width = 84,
  height = 118,
  units = "cm"
)