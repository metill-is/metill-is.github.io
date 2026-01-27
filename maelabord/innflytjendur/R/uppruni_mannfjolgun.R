d |> 
  filter(
    ar %in% c(2017, 2024)
  ) |> 
  select(-country) |> 
  pivot_wider(names_from = ar, values_from = n) |> 
  rename(
    pre = 2, post = 3
  ) |> 
  mutate(
    diff = post - pre
  ) |> 
  arrange(desc(diff)) |> 
  mutate(
    rikisfang = if_else(
      row_number() > 40,
      "Annað",
      rikisfang
    )
  ) |> 
  summarise(
    diff = sum(diff),
    .by = rikisfang
  ) |> 
  mutate(
    cumul_diff = cumsum(diff),
    p = diff / sum(diff),
    cumul_p = cumsum(p),
    start = lag(cumul_p, default = 0),
    end = cumul_p,
    y = glue::glue("{rikisfang} ({percent(p, accuracy = 0.1)})") |> fct_reorder(diff * (rikisfang != "Annað")),
    rikisfang = fct_reorder(rikisfang, diff),
  ) |> 
  # top_n(diff, n = 40) |> 
  ggplot(aes(cumul_p, y)) +
  geom_vline(
    xintercept = 1,
    lty = 2,
    linewidth = 0.2
  ) +
  geom_segment(
    aes(x = start, xend = end, yend = y),
    linewidth = 0.3
  ) +
  geom_point(
    shape = "|",
    size = 3
  ) +
  geom_point(
    data = ~filter(.x, start > 0),
    aes(x = start),
    shape = "|",
    size = 3
  ) +
  scale_x_continuous(
    guide = guide_axis(cap = "both"),
    labels = label_percent(),
    limits = c(0, 1),
    expand = expansion(mult = c(0, 0.02))
  ) +
  scale_y_discrete(
    guide = guide_axis(cap = "both")
  ) +
  labs(
    x = "Hlutfall af mannfjölgun (2017 - 2024)",
    y = NULL,
    title = "Hvaða ríkisföng bera þungan af fjölgun íbúa á Íslandi frá 2017 til 2024?"
  )
