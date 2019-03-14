# Libraries ---------------------------------------------------------------

library(readr)
library(dplyr)
library(ggplot2)
library(cowplot)
source("scripts/helpers.R")

# Plot Layers -------------------------------------------------------------

ggplot2::theme_set(cowplot::theme_cowplot(font_size = 14))

layers <- list(
  ggplot2::geom_point(size = 1),
  ggplot2::scale_color_manual("Collection", values = colors, labels = collection_labels),
  ggplot2::scale_shape_manual("Collection", values = shapes, labels = collection_labels),
  ggplot2::theme(
    axis.title = ggplot2::element_blank(),
    axis.text = ggplot2::element_blank(),
    axis.ticks = ggplot2::element_blank()
  )
)

# Plot Score Clustering ---------------------------------------------------

ggplot2::ggplot(score_pca_tbl,
                ggplot2::aes(
                  x = x,
                  y = y,
                  color = collection,
                  shape = collection
                )) +
  layers
ggplot2::ggsave(
  filename = sprintf("score_pca.%s", file_format),
  path = file.path("figures", "clustering")
)

ggplot2::ggplot(score_tsne_tbl,
                ggplot2::aes(
                  x = x,
                  y = y,
                  color = collection,
                  shape = collection
                )) +
  layers
ggplot2::ggsave(
  filename = sprintf("score_tsne.%s", file_format),
  path = file.path("figures", "clustering")
)

ggplot2::ggplot(score_umap_tbl,
                ggplot2::aes(
                  x = x,
                  y = y,
                  color = collection,
                  shape = collection
                )) +
  layers
ggplot2::ggsave(
  filename = sprintf("score_umap.%s", file_format),
  path = file.path("figures", "clustering")
)

# Plot Metric Clustering --------------------------------------------------

ggplot2::ggplot(metric_pca_tbl,
                ggplot2::aes(
                  x = x,
                  y = y,
                  color = collection,
                  shape = collection
                )) +
  layers
ggplot2::ggsave(
  filename = sprintf("metric_pca.%s", file_format),
  path = file.path("figures", "clustering")
)

ggplot2::ggplot(metric_tsne_tbl,
                ggplot2::aes(
                  x = x,
                  y = y,
                  color = collection,
                  shape = collection
                )) +
  layers
ggplot2::ggsave(
  filename = sprintf("metric_tsne.%s", file_format),
  path = file.path("figures", "clustering")
)

ggplot2::ggplot(metric_umap_tbl,
                ggplot2::aes(
                  x = x,
                  y = y,
                  color = collection,
                  shape = collection
                )) +
  layers
ggplot2::ggsave(
  filename = sprintf("metric_umap.%s", file_format),
  path = file.path("figures", "clustering")
)
