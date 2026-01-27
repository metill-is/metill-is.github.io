library(gganimate)

d <- read_csv(
  here::here("maelabord", "innflytjendur", "data", "origin_combined.csv")
)

rikisfong <- d |>
  summarise(
    n = sum(n),
    .by = rikisfang
  ) |>
  top_n(n = 35, wt = n) |>
  filter(
    rikisfang != "Ísland"
  )

plot_data <- d |>
  filter(
    # ar == max(ar),
    rikisfang != "Ísland"
  ) |>
  arrange(desc(n)) |>
  mutate(
    rikisfang = if_else(
      rikisfang %in% rikisfong$rikisfang,
      rikisfang,
      "Annað"
    )
  ) |>
  count(rikisfang, ar, wt = n, name = "n") |>
  mutate(
    rikisfang2 = glue("{rikisfang} ({number(n, big.mark = '.',decimal.mark = ',')})") |>
      fct_reorder(n * (rikisfang != "Annað")),
    rikisfang2 = fct_reorder(rikisfang, n * (rikisfang != "Annað"), .fun = max)
  ) |>
  arrange(desc(rikisfang2)) |>
  mutate(
    total = sum(n),
    total = if_else(
      row_number() == 1,
      total,
      NA
    ),
    n = cumsum(n),
    xend = lag(n, default = 0),
    .by = ar
  )


p1 <- ggplot(plot_data, aes(n, rikisfang2)) +
  geom_vline(
    aes(
      xintercept = total
    ),
    lty = 1
  ) +
  geom_segment(
    aes(xend = xend, yend = rikisfang2)
  ) +
  geom_point(
    shape = "|",
    size = 3
  ) +
  geom_point(
    aes(x = xend),
    shape = "|",
    size = 3
  ) +
  geom_text(
    aes(x = 0, label = str_c(rikisfang2, " ")),
    hjust = 1,
    size = 3.5
  ) +
  scale_x_continuous(
    breaks = breaks_extended(5),
    labels = label_number(),
    limits = c(0, NA),
    expand = expansion(c(0, 0.1)),
    guide = guide_axis(cap = "both")
  ) +
  scale_y_discrete(
    guide = guide_axis(cap = "both")
  ) +
  labs(
    x = "Samanlagður fjöldi innflytjenda",
    y = NULL,
    title = "Innflytjendur á Íslandi ({closest_state})",
    subtitle = "Frá hvaða löndum komu innflytjendur til Íslands?",
    caption = "Mynd teiknuð úr gögnum Hagstofu:\nhttps://px.hagstofa.is/pxis/pxweb/is/Ibuar/Ibuar__mannfjoldi__3_bakgrunnur__Rikisfang/MAN04103.px"
  ) +
  coord_cartesian(clip = "off", xlim = c(-1.3e4, NA)) +
  theme(
    plot.margin = margin(t = 5, r = 25, b = 5, l = 5),
    axis.line.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
  ) +
  transition_states(ar, transition_length = 0.5, state_length = 0.5) +
  ease_aes("cubic-in-out")

p_anim <- animate(p1, fps = 8, duration = 20, renderer = gifski_renderer(loop = FALSE))

p_anim

anim_save(filename = "anim.gif",  animation = p_anim)
