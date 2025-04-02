atvinna |> 
  filter(land == "Ísland") |> 
  mutate(
    innlent = slider::slide_dbl(innlent, mean, .before = 3),
    erlent = slider::slide_dbl(erlent, mean, .before = 3)
  ) |> 
  ggplot(aes(dags, innlent)) +
  geom_line(aes(lty = "Innlent")) +
  geom_line(aes(y = erlent, lty = "Erlent")) +
  scale_x_date(
    guide = ggh4x::guide_axis_truncated(),
    breaks = breaks_width("1 year"),
    labels = label_date_short()
  ) +
  scale_y_continuous(
    guide = ggh4x::guide_axis_truncated(),
    labels = label_percent(),
    limits = c(NA, 1)
  ) +
  theme(
    legend.position = c(0.15, 0.85)
  ) +
  labs(
    x = NULL,
    y = NULL,
    lty = "Vinnuafl",
    title = "Hlutfall með vinnu á Íslandi eftir fæðingarlandi",
    subtitle = "Hlutfall einstaklinga 20 - 64 ára með vinnu | Hlaupandi eins árs meðaltöl",
    caption = caption
  )
