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

size <- 18  # Base font size applied to the theme.

label_width <- 28  # Number of characters to wrap lines by.

ggplot2::theme_set(cowplot::theme_cowplot(font_size = size))

base_layers <- list(
  ggplot2::scale_color_manual(values = colors, guide = FALSE),
  ggplot2::scale_shape_manual(values = shapes, guide = FALSE)
)

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
                 axis.text = ggplot2::element_blank(),
                 axis.ticks = ggplot2::element_blank())

# Stoichiometric consistency plot -----------------------------------------

stoich_consistency <- total_df %>%
  dplyr::filter(test == "test_stoichiometric_consistency") %>%
  droplevels() %>%
  ggplot2::ggplot(.,
                  ggplot2::aes(
                    x = collection,
                    y = metric,
                    color = collection,
                    shape = collection
                  )) +
  ggforce::geom_sina(size = 1, scale = FALSE) +
  ggplot2::geom_boxplot(color = "black", outlier.shape = NA, fill = NA) +
  base_layers +
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(),
    axis.text.x = ggplot2::element_blank()
  ) +
  ggplot2::ylab(stringr::str_wrap("Fraction of Unbalanced Metabolites", width = label_width))

# Reactions without GPR ---------------------------------------------------

gpr <- total_df %>%
  dplyr::filter(test == "test_gene_protein_reaction_rule_presence") %>%
  droplevels() %>%
  ggplot2::ggplot(.,
                  ggplot2::aes(
                    x = collection,
                    y = metric,
                    color = collection,
                    shape = collection
                  )) +
  ggforce::geom_sina(size = 1, scale = FALSE) +
  ggplot2::geom_boxplot(color = "black", outlier.shape = NA, fill = NA) +
  base_layers +
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(),
    axis.text.x = ggplot2::element_blank()
  ) +
  ggplot2::ylab(stringr::str_wrap("Fraction of Reactions Without GPR Rules", width = label_width))

# Blocked reactions plot --------------------------------------------------

blocked <- total_df %>%
  dplyr::filter(test == "test_blocked_reactions") %>%
  droplevels() %>%
  ggplot2::ggplot(.,
                  ggplot2::aes(
                    x = collection,
                    y = metric,
                    color = collection,
                    shape = collection
                  )) +
  ggforce::geom_sina(size = 1, scale = FALSE) +
  ggplot2::geom_boxplot(color = "black", outlier.shape = NA, fill = NA) +
  base_layers +
  ggplot2::scale_x_discrete(labels = collection_labels) +
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(),
    axis.text.x = ggplot2::element_text(
      angle = 45,
      hjust = 1,
      vjust = 1
    )
  ) +
  ggplot2::ylab(stringr::str_wrap("Fraction of Blocked Reactions", width = label_width)) +
  ggplot2::theme(plot.margin =
                   ggplot2::margin(
                     l = size
                   ))

# Save figure -------------------------------------------------------------

grid <-
    egg::ggarrange(
    clustering,
    stoich_consistency,
    gpr,
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

cowplot::save_plot(
  "manuscript_panel_figure.png",
  grid,
  nrow = 4,
  base_aspect_ratio = 1.6180,
  path = file.path("figures")
)
