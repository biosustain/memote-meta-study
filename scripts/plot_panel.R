sina_layers <- list(
  geom_sina(size = 1, scale = FALSE),
  coord_cartesian(ylim = c(0, 1)),
  scale_x_discrete(labels = collection_labels),
  scale_color_manual(
    values = colors,
    labels = collection_labels,
    guide = FALSE
  ),
  scale_shape_manual(values = shapes, guide = FALSE),
  theme(
    axis.title.y = element_text(size = 12),
    axis.title.x = element_blank(),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1,
      vjust = 1
    )
  )
)

layers <- list(
  geom_point(size = 1),
  scale_color_manual(values = colors, guide = FALSE),
  scale_shape_manual(values = shapes, guide = FALSE),
  theme(
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank()
  )
)


test_selection = c(
  "test_stoichiometric_consistency",
  "test_find_reversible_oxygen_reactions",
  "test_blocked_reactions"
)

clustering <-
  ggplot(metric_tsne_tbl,
         aes(
           x = x,
           y = y,
           color = collection,
           shape = collection
         )) +
  c(layers, list(theme(plot.margin = unit(c(t = 7, r = 21, b = 7, l = 21), "pt"))))

panel_df <- total_df %>%
  filter(test %in% test_selection) %>%
  group_by(test) %>%
  do(plot_sina = ggplot(
    .,
    aes(
      x = collection,
      y = score,
      col = collection,
      label = model,
      shape = collection
    )
  ) + c(sina_layers, list(theme(plot.margin = unit(c(7, 21, 7, 21), "pt")))) + ylab(first(.$ylabels)))

# ggplot(test_of_interest_df, aes(x = collection, y = score, col = collection, label = model)
#        ) + sina_layers + facet_wrap(~test, ncol = 1)

grid = plot_grid(
  clustering,
  panel_df$plot_sina[[3]] + theme(axis.text.x = element_blank()),
  panel_df$plot_sina[[2]] + theme(axis.text.x = element_blank()),
  panel_df$plot_sina[[1]],
  labels = c("a", "b", "c", "d"),
  nrow = 4,
  align = "hv",
  # axis = "trbl",
  label_size = 21
)

save_plot(
  "manuscript_panel_figure.pdf",
  grid,
  nrow = 4,
  base_aspect_ratio = 1.6180,
  path = file.path("figures")
)
