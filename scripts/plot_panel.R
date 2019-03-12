# Libraries ---------------------------------------------------------------

library(readr)
library(dplyr)
library(stringr)
library(ggplot2)
library(ggforce)
library(cowplot)
library(egg)
source("scripts/helpers.R")

# Panel plots -------------------------------------------------------------

size <- 18

ggplot2::theme_set(cowplot::theme_cowplot(font_size = size))

base_layers <- list(
  ggplot2::scale_color_manual(values = colors, guide = FALSE),
  ggplot2::scale_shape_manual(values = shapes, guide = FALSE)
)

reduced_margin <- ggplot2::theme(plot.margin =
                                   ggplot2::margin(
                                     t = -size,
                                     r = 8,
                                     b = -size,
                                     l = size
                                   ))

# Metric t-SNE plot -------------------------------------------------------

clustering <-
  ggplot2::ggplot(metric_tsne_tbl,
                  ggplot2::aes(
                    x = x,
                    y = y,
                    color = collection,
                    shape = collection
                  )) +
  ggplot2::geom_point(size = 1) +
  base_layers +
  ggplot2::theme(axis.title = ggplot2::element_blank(),
                 axis.text = ggplot2::element_blank())
  # ggplot2::theme(plot.margin =
  #                  ggplot2::margin(
  #                    t = 8,
  #                    r = 8,
  #                    b = -size,
  #                    l = size
  #                  ))

# Stoichiometric consistency plot -----------------------------------------

stoich_consistency <- total_df %>%
  dplyr::filter(test == "test_stoichiometric_consistency") %>%
  droplevels() %>%
  ggplot2::ggplot(.,
                  ggplot2::aes(
                    x = collection,
                    y = metric * 100,
                    color = collection,
                    shape = collection
                  )) +
  ggforce::geom_sina(size = 1, scale = FALSE) +
  base_layers +
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(),
    axis.text.x = ggplot2::element_blank()
  ) +
  ggplot2::ylab(stringr::str_wrap("Unbalanced Metabolites [%]", width = 35))
  # reduced_margin

# Reversible oxygen-consuming reactions plot ------------------------------

oxygen <- total_df %>%
  dplyr::filter(test == "test_find_reversible_oxygen_reactions") %>%
  droplevels() %>%
  ggplot2::ggplot(.,
                  ggplot2::aes(
                    x = collection,
                    y = metric * 100,
                    color = collection,
                    shape = collection
                  )) +
  ggforce::geom_sina(size = 1, scale = FALSE) +
  base_layers +
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(),
    axis.text.x = ggplot2::element_blank()
  ) +
  ggplot2::ylab(stringr::str_wrap("Reversible Oxygen-Reactions [%]", width = 35))
  # reduced_margin

# Blocked reactions plot --------------------------------------------------

blocked <- total_df %>%
  dplyr::filter(test == "test_blocked_reactions") %>%
  droplevels() %>%
  ggplot2::ggplot(.,
                  ggplot2::aes(
                    x = collection,
                    y = metric * 100,
                    color = collection,
                    shape = collection
                  )) +
  ggforce::geom_sina(size = 1, scale = FALSE) +
  base_layers +
  ggplot2::scale_x_discrete(labels = collection_labels) +
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(),
    # axis.text.x = ggplot2::element_blank()
    axis.text.x = ggplot2::element_text(
      angle = 45,
      hjust = 1,
      vjust = 1
    )
  ) +
  ggplot2::ylab(stringr::str_wrap("Blocked Reactions [%]", width = 35)) +
  ggplot2::theme(plot.margin =
                   ggplot2::margin(
                     l = size
                   ))

# Save figure -------------------------------------------------------------

grid <-
    egg::ggarrange(
    clustering,
    stoich_consistency,
    oxygen,
    blocked,
    nrow = 4,
    labels = letters[1:4],
    label.args = list(gp = grid::gpar(fontsize = 18))
  )

cowplot::save_plot(
  "manuscript_panel_figure.pdf",
  grid,
  nrow = 4,
  base_aspect_ratio = 1.6180,
  path = file.path("figures")
)
