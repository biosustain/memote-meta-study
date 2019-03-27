# Libraries ---------------------------------------------------------------

library(readr)
library(dplyr)
library(ggplot2)
library(ggforce)
library(stringr)
library(cowplot)
source("scripts/helpers.R")

# Plot Layers -------------------------------------------------------------

ggplot2::theme_set(cowplot::theme_cowplot(font_size = 14))

sina_layers <- list(
  ggforce::geom_sina(size = 1, scale = FALSE),
  ggplot2::geom_boxplot(color = "black", outlier.shape = NA, fill = NA),
  ggplot2::scale_x_discrete(labels = collection_labels),
  ggplot2::scale_color_manual(values = colors, guide = FALSE),
  ggplot2::scale_shape_manual(values = shapes, guide = FALSE),
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(),
    axis.text.x = ggplot2::element_text(
      angle = 45,
      hjust = 1,
      vjust = 1
    )
  )
)

# Plot per Test -----------------------------------------------------------

all_plots <- total_df %>%
  dplyr::filter(is.finite(metric)) %>%
  dplyr::mutate(score = ifelse(test %in% only_scored_tests, 1 - metric, metric)) %>%
  dplyr::group_by(test) %>%
  dplyr::do(
    plot_sina = ggplot2::ggplot(
      .,
      ggplot2::aes(
        x = collection,
        y = score,
        color = collection,
        shape = collection,
        label = model
      )
    ) + sina_layers + ggplot2::ylab(stringr::str_wrap(y_axis_labels[unique(.$test)], width = 40))
  )

for (i in 1:nrow(all_plots)) {
  test_name <- all_plots$test[[i]]
  message(sprintf("Plotting %s", test_name))
  tryCatch({
    ggplot2::ggsave(
      filename = sprintf("%s.%s", test_name, file_format),
      path = file.path("figures", "tests"),
      plot = all_plots$plot_sina[[i]]
    )
  },
  error = function(err) {
    print(sprintf("Could not plot %s!", test_name))
    print(err)
  })
}
