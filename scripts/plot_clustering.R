# Libraries ---------------------------------------------------------------

library(readr)
library(dplyr)
library(ggplot2)

# Load data ---------------------------------------------------------------

score_pca_tbl <- readr::read_csv("data/score_pca.csv.gz") %>%
  mutate(
    collection = factor(collection)
  )

score_tsne_tbl <- readr::read_csv("data/score_tsne.csv.gz") %>%
  mutate(
    collection = factor(collection)
  )

score_umap_tbl <- readr::read_csv("data/score_umap.csv.gz") %>%
  mutate(
    collection = factor(collection)
  )

metric_pca_tbl <- readr::read_csv("data/metric_pca.csv.gz") %>%
  mutate(
    collection = factor(collection)
  )

metric_tsne_tbl <- readr::read_csv("data/metric_tsne.csv.gz") %>%
  mutate(
    collection = factor(collection)
  )

metric_umap_tbl <- readr::read_csv("data/metric_umap.csv.gz") %>%
  mutate(
    collection = factor(collection)
  )

colors <- c(
  "agora" = "#A6A9AA",
  "bigg" = "#000000",
  "ebrahim" = "#3E7CBC",
  "embl" = "#A3D2E2",
  "path" = "#737878",
  "seed" = "#EDA85F",
  "uminho" = "#CD2028"
)

# Plot Layers -------------------------------------------------------------

layers <- list(
  theme_bw(base_size = 21),
  geom_point(size = 1),
  scale_color_manual(values = colors, guide = FALSE),
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    plot.margin = unit(c(21, 21, 21, 21), "pt")
  )
)

# Plot Score Clustering ---------------------------------------------------

file_format <- "pdf"

ggplot(score_pca_tbl, aes(x = x, y = y, color = collection)) +
  layers
ggsave(
  filename = sprintf("score_pca.%s", file_format),
  path = file.path("figures", "clustering")
)

ggplot(score_tsne_tbl, aes(x = x, y = y, color = collection)) +
  layers
ggsave(
  filename = sprintf("score_tsne.%s", file_format),
  path = file.path("figures", "clustering")
)

ggplot(score_umap_tbl, aes(x = x, y = y, color = collection)) +
  layers
ggsave(
  filename = sprintf("score_umap.%s", file_format),
  path = file.path("figures", "clustering")
)

# Plot Metric Clustering --------------------------------------------------

ggplot(metric_pca_tbl, aes(x = x, y = y, color = collection)) +
  layers
ggsave(
  filename = sprintf("metric_pca.%s", file_format),
  path = file.path("figures", "clustering")
)

ggplot(metric_tsne_tbl, aes(x = x, y = y, color = collection)) +
  layers
ggsave(
  filename = sprintf("metric_tsne.%s", file_format),
  path = file.path("figures", "clustering")
)

ggplot(metric_umap_tbl, aes(x = x, y = y, color = collection)) +
  layers
ggsave(
  filename = sprintf("metric_umap.%s", file_format),
  path = file.path("figures", "clustering")
)
