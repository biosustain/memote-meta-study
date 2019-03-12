# Libraries ---------------------------------------------------------------

library(readr)
library(dplyr)
library(ggplot2)
source("scripts/helpers.R")

# Load data ---------------------------------------------------------------

bigg_df <- readr::read_csv("data/bigg.csv.gz") %>%
  dplyr::mutate(collection = "bigg")

uminho_df <- readr::read_csv("data/uminho.csv.gz") %>%
  mutate(collection = "uminho")

mmodel_df <- readr::read_csv("data/mmodel.csv.gz") %>%
  dplyr::mutate(collection = "ebrahim")

agora_df <- readr::read_csv("data/agora.csv.gz") %>%
  dplyr::mutate(collection = "agora")

embl_df <- readr::read_csv("data/embl_gems.csv.gz") %>%
  dplyr::mutate(collection = "embl")

path_df <- readr::read_csv("data/path2models.csv.gz") %>%
  dplyr::mutate(collection = "path")

seed_df <- readr::read_csv("data/seed.csv.gz") %>%
  dplyr::mutate(collection = "seed")

total_df <- dplyr::bind_rows(
    bigg_df,
    uminho_df,
    mmodel_df,
    agora_df,
    embl_df,
    path_df,
    seed_df
  ) %>%
  dplyr::filter(
    test != "test_biomass_open_production"
  ) %>%
  dplyr::mutate(
    model = factor(model),
    collection = factor(collection, levels = c("agora", "embl", "path", "seed", "bigg", "ebrahim", "uminho")),
    test = factor(test),
    section = factor(section),
    numeric = as.numeric(numeric),
    time = as.numeric(time),
    score = ifelse(test %in% only_scored_tests, 1 - metric, metric)
  )

# Plot Layers -------------------------------------------------------------

sina_layers <- list(
  geom_sina(size = 1, scale = FALSE),
  scale_x_discrete(labels = collection_labels),
  scale_shape_manual(values = shapes, guide = FALSE),
  scale_color_manual(
    values = colors,
    labels = collection_labels,
    guide = FALSE
  ),
  theme(axis.text.x = element_text(
    angle = 45,
    hjust = 1,
    vjust = 1
  ))
)

# Plot per Test -----------------------------------------------------------

time_per_model <- total_df %>%
  group_by(collection, model) %>%
  summarize(
    duration = sum(time),
    rxn_size = numeric[which(test == "test_reactions_presence")[1]],
    met_size = numeric[which(test == "test_metabolites_presence")[1]]
  )

ggplot(time_per_model,
       aes(x = rxn_size,
           y = duration,
           color = collection
           )
       ) +
  geom_point(size = 1) +
  scale_color_manual(values = colors)
  # scale_y_log10() +
  # scale_x_log10()

ggplot(time_per_model,
       aes(
         x = collection,
         y = duration,
         color = collection
       )) +
  scale_color_manual(values = colors,
                     labels = collection_labels,
                     guide = FALSE) +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_text(
    angle = 45,
    hjust = 1,
    vjust = 1
  )) +
  scale_x_discrete(labels = collection_labels) +
  ylab("Duration [s]") +
  geom_boxplot()

ggplotly()

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

# Sections ----------------------------------------------------------------

time_per_model_section <- total_df %>%
  group_by(collection, model, section) %>%
  summarize(duration = sum(time))

ggplot(time_per_model_section,
       aes(
         x = duration,
         y = stat(ncount)
       )) +
  # scale_color_manual(values = colors,
                     # labels = collection_labels,
                     # guide = FALSE) +
  # theme(axis.text.x = element_text(
  #   angle = 45,
  #   hjust = 1,
  #   vjust = 1
  # )) +
  # scale_x_discrete(labels = collection_labels) +
  # ylab("Duration [s]") +
  geom_freqpoly() +
  facet_grid(collection ~ section)
