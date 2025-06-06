make_plot2a <- function() {
  start_date <- min(virkni$dags)
  end_date <- max(virkni$dags)
  point_size <- 2.2

  p1 <- virkni |>
    drop_na() |>
    filter(dags == start_date) |>
    mutate(
      colour = case_when(
        land == "Ísland" ~ litur_island,
        land == "Danmörk" ~ litur_danmork,
        land == "Finnland" ~ litur_finnland,
        land == "Noregur" ~ litur_noregur,
        land == "Svíþjóð" ~ litur_svithjod,
        land == "Meðaltal" ~ litur_total,
        TRUE ~ litur_annad
      ),
      linewidth = 1 * (land == "Ísland"),
      size = as_factor(linewidth),
      land_ordered = glue("<i style='color:{colour}'>{land}</i>"),
      land_ordered = fct_reorder(land_ordered, erlent)
    ) |>
    ggplot(aes(erlent, land_ordered, col = colour, size = size)) +
    geom_text_interactive(
      aes(x = 0.5, label = str_c(land, " "), data_id = land),
      hjust = 1,
      size = 3.5
    ) +
    geom_point_interactive(
      aes(data_id = land, shape = "Erlent"),
      size = point_size
    ) +
    geom_point_interactive(
      aes(x = innlent, data_id = land, shape = "Innlent"),
      size = point_size
    ) +
    geom_segment_interactive(
      aes(yend = land_ordered, xend = innlent, linewidth = linewidth, data_id = land),
      lty = 2,
      alpha = 0.5
    ) +
    scale_x_continuous(
      expand = expansion(c(0, 0.05)),
      breaks = breaks_extended(6),
      limits = c(0.5, 1),
      labels = label_hlutf(),
      guide = guide_axis_truncated(
        trunc_lower = 0.5
      )
    ) +
    scale_colour_identity() +
    scale_size_manual(values = c(1.5, 3)) +
    scale_linewidth(
      range = c(0.2, 0.4)
    ) +
    scale_shape_manual(
      values = c(16, 15)
    ) +
    coord_cartesian(clip = "off", xlim = c(0.45, NA)) +
    guides(
      color = "none",
      linewidth = "none",
      size = "none",
      shape = guide_legend(
        keywidth = unit(1, "cm"),
        override.aes = list(size = 4)
      )
    ) +
    theme(
      plot.margin = margin(t = 5, r = 25, b = 5, l = 5),
      axis.line.y = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      legend.position = c(0.23, 0.95)
    ) +
    labs(
      x = NULL,
      y = NULL,
      shape = NULL,
      subtitle = glue("Hlutfall í {month(start_date, label = T, abbr = F)} {year(start_date)}"),
      caption = caption
    )


  p2 <- virkni |>
    drop_na() |>
    filter(dags == end_date) |>
    mutate(
      colour = case_when(
        land == "Ísland" ~ litur_island,
        land == "Danmörk" ~ litur_danmork,
        land == "Finnland" ~ litur_finnland,
        land == "Noregur" ~ litur_noregur,
        land == "Svíþjóð" ~ litur_svithjod,
        land == "Meðaltal" ~ litur_total,
        TRUE ~ litur_annad
      ),
      linewidth = 1 * (land == "Ísland"),
      size = as_factor(linewidth),
      land_ordered = glue("<i style='color:{colour}'>{land}</i>"),
      land_ordered = fct_reorder(land_ordered, erlent)
    ) |>
    ggplot(aes(erlent, land_ordered, col = colour, size = size)) +
    geom_text_interactive(
      aes(x = 0.5, label = str_c(land, " "), data_id = land),
      hjust = 1,
      size = 3.5
    ) +
    geom_point_interactive(
      aes(data_id = land, shape = "Erlent"),
      size = point_size
    ) +
    geom_point_interactive(
      aes(x = innlent, data_id = land, shape = "Innlent"),
      size = point_size
    ) +
    geom_segment_interactive(
      aes(yend = land_ordered, xend = innlent, linewidth = linewidth, data_id = land),
      lty = 2,
      alpha = 0.5
    ) +
    scale_x_continuous(
      expand = expansion(c(0, 0.05)),
      breaks = breaks_extended(6),
      limits = c(0.5, 1),
      labels = label_hlutf(),
      guide = guide_axis_truncated(
        trunc_lower = 0.5
      )
    ) +
    scale_colour_identity() +
    scale_size_manual(values = c(1.5, 3)) +
    scale_linewidth(
      range = c(0.2, 0.4)
    ) +
    scale_shape_manual(
      values = c(16, 15)
    ) +
    coord_cartesian(clip = "off", xlim = c(0.45, NA)) +
    theme(
      plot.margin = margin(t = 5, r = 25, b = 5, l = 5),
      axis.line.y = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      legend.position = "none"
    ) +
    labs(
      x = NULL,
      y = NULL,
      subtitle = glue("Hlutfall í {month(end_date, label = T, abbr = F)} {year(end_date)}"),
      caption = caption
    )

  plot_dat <- virkni |>
    arrange(dags) |>
    filter(dags >= start_date) |>
    select(dags, land, value = erlent) |>
    mutate(
      colour = case_when(
        land == "Ísland" ~ litur_island,
        land == "Danmörk" ~ litur_danmork,
        land == "Finnland" ~ litur_finnland,
        land == "Noregur" ~ litur_noregur,
        land == "Svíþjóð" ~ litur_svithjod,
        land == "Meðaltal" ~ litur_total,
        TRUE ~ litur_annad
      ),
      linewidth = 1 * (land == "Ísland"),
      size = as_factor(linewidth)
    ) |>
    mutate(
      value = slider::slide_dbl(value, mean, .before = 3)
    )

  p3 <- plot_dat |>
    ggplot(aes(dags, value)) +
    geom_line_interactive(
      data = plot_dat |>
        filter(colour == litur_annad),
      aes(group = land, colour = litur_annad, data_id = land),
      alpha = 0.3,
      col = litur_annad
    ) +
    geom_line_interactive(
      data = plot_dat |>
        filter(colour != litur_annad),
      aes(group = land, colour = colour, data_id = land),
      linewidth = 1
    ) +
    scale_x_date(
      breaks = breaks_width("year"),
      limits = c(min(plot_dat$dags), max(plot_dat$dags) + days(25)),
      labels = label_date_short(),
      expand = expansion(add = 15),
      guide = guide_axis_truncated(
        trunc_lower = min(plot_dat$dags),
        trunc_upper = max(plot_dat$dags)
      )
    ) +
    scale_y_continuous(
      breaks = breaks_extended(6),
      labels = label_hlutf(),
      limits = c(0.6, 0.9),
      guide = guide_axis_truncated(
        trunc_lower = 0.6,
        trunc_upper = 0.9
      )
    ) +
    scale_colour_identity() +
    coord_cartesian(clip = "on") +
    theme(
      plot.margin = margin(t = 5, r = 35, b = 5, l = 5)
    ) +
    labs(
      x = NULL,
      y = NULL,
      subtitle = "Þróun í atvinnuþátttöku erlendra einstaklinga | Leiðrétt fyrir árstíðarsveiflum"
    )

  p <- (
    (p1 + labs(title = NULL, caption = NULL)) +
      (p2 + labs(title = NULL, caption = NULL))
  ) /
    p3 +
    plot_annotation(
      title = "Atvinnuþátttaka í Evrópulöndum eftir fæðingarlandi (innlendis/erlendis)",
      subtitle = str_c(
        "Hlutfall eintaklinga 20 - 64 ára með vinnu eða í leit að vinnu | ",
        "Láttu músina yfir land til að einblína á það"
      ),
      caption = caption
    )

  girafe(
    ggobj = p,
    width_svg = 11,
    height_svg = 0.9 * 11,
    bg = "transparent",
    options = list(
      opts_tooltip(
        opacity = 0.8,
        use_fill = TRUE,
        use_stroke = FALSE,
        css = "padding:5pt;font-family: Open Sans;font-size:1rem;color:white"
      ),
      opts_hover(css = ""),
      opts_hover_inv(css = "opacity:0.05"),
      opts_toolbar(saveaspng = TRUE),
      opts_zoom(max = 1)
    )
  )
}
