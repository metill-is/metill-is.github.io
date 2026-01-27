url <- "https://px.hagstofa.is:443/pxis/api/v1/is/Samfelag/vinnumarkadur/vinnuaflskraargogn/VIN10032.px"

hg_dat <- hg_data(url) |> 
  filter(
    Aldur == "Alls",
    Kyn == "Alls",
    Lögheimili == "Alls"
  )

d <- hg_dat |>  
  collect() |> 
  janitor::clean_names()

d <- d |> 
  separate(manudur, into = c("ar", "manudur"), sep = "M", convert = TRUE) |> 
  mutate(dags = clock::date_build(ar, manudur)) |>  
  select(dags, kyn, atvinnugrein_balkar, starfandi, bakgrunnur) |>  
  drop_na() |>  
  janitor::remove_constant()

d |> 
  rename(
    atv = atvinnugrein_balkar
  ) |> 
  filter(
    atv != "Alls - Starfandi",
    bakgrunnur != "Alls",
    !year(dags) %in% c(2020, 2021)
  ) |> 
  janitor::remove_constant() |> 
  mutate(
    hlutf = starfandi / sum(starfandi),
    .by = c(dags, atv)
  ) |>
  filter(bakgrunnur == "Innflytjendur") |> 
  janitor::clean_names() |> 
  mutate(
    man = month(dags),
    ar = year(dags),
    atv = str_wrap(atv, 40)
  ) |> 
  mutate(
    mean = mean(hlutf),
    diff = hlutf / mean,
    .by = c(ar, atv)
  ) |> 
  ggplot(aes(man, diff)) +
  geom_hline(yintercept = 1, lty = 2, alpha = 0.4) +
  geom_line(aes(group = ar, col = ar)) +
  scale_x_continuous(
    breaks = 1:12
  ) +
  scale_y_continuous(
    breaks = breaks_pretty(),
    labels = function(x) hlutf(x - 1),
    trans = "log10"
  ) +
  scale_colour_distiller(palette = "RdBu") +
  facet_wrap("atv", scales = "free") +
  labs(
    title = "Árstíðarleitni í hlutfalli innflytjenda af öllum starfandi",
    subtitle = "Sýnt sem % munur frá meðaltali"
  )

d |> 
  filter(
    atvinnugrein_balkar != "Alls - Starfandi"
  ) |> 
  count(dags, bakgrunnur, wt = starfandi) |> 
  mutate(
    man = month(dags),
    ar = year(dags)
  ) |> 
  filter(
    ar == 2023
  ) |> 
  mutate(
    diff = n / mean(n),
    .by = c(bakgrunnur, ar)
  ) |> 
  ggplot(aes(man, diff)) +
  geom_line(aes(col = ar, group = ar)) +
  facet_wrap("bakgrunnur")


d |> 
  rename(
    atv = atvinnugrein_balkar
  ) |> 
  filter(
    atv != "Alls - Starfandi",
    bakgrunnur != "Alls"
  ) |> 
  janitor::remove_constant() |> 
  mutate(
    hlutf = starfandi / sum(starfandi),
    .by = c(dags, atv)
  ) |>
  filter(bakgrunnur == "Innflytjendur") |> 
  janitor::clean_names() |> 
  mutate(
    man = month(dags),
    ar = year(dags),
    atv = str_wrap(atv, 40),
    atv = fct_reorder(atv, -hlutf)
  ) |> 
  mutate(
    mean = mean(starfandi),
    diff = starfandi / mean,
    .by = c(ar, atv)
  ) |> 
  ggplot(aes(dags, hlutf)) +
  geom_line() +
  scale_y_continuous(
    breaks = breaks_pretty(),
    labels = label_hlutf(),
    limits = c(0, 1)
  ) +
  scale_colour_distiller(palette = "RdBu") +
  facet_wrap("atv", scales = "free")



d |> 
  rename(
    atv = atvinnugrein_balkar
  ) |> 
  mutate(
    starfandi = slider::slide_dbl(starfandi, mean, .before = 7),
    .by = c(atv, bakgrunnur)
  ) |> 
  filter(
    bakgrunnur != "Alls",
    dags %in% clock::date_build(c(2025, 2023, 2018, 2013), 8, 1),
    str_detect(atv, "^[A-Z]+ |Alls|^O-Q")
  ) |> 
  janitor::remove_constant() |> 
  mutate(
    hlutf = starfandi / sum(starfandi),
    .by = c(atv, dags)
  ) |>
  filter(bakgrunnur == "Innflytjendur") |> 
  janitor::clean_names() |> 
  select(atv, dags, starfandi, hlutf) |> 
  pivot_wider(
    names_from = dags, 
    values_from = c(starfandi, hlutf), 
    names_vary = "slowest"
  ) |> 
  slice(c(1, 3:18, 2)) |> 
  gt() |> 
  tab_header(
    title = "Fjöldi og hlutfall innflytjenda meðal starfandi eftir atvinnugrein",
    subtitle = "Tölur eru meðaltöl fyrstu átta mánaða (janúar - ágúst) á hverju ári"
  ) |> 
  tab_spanner(
    "2013",
    columns = 2:3
  ) |> 
  tab_spanner(
    "2018",
    columns = 4:5
  ) |> 
  tab_spanner(
    "2023",
    columns = 6:7
  ) |> 
  tab_spanner(
    "2025",
    columns = 8:9
  ) |> 
  cols_label(
    atv = "Atvinnugrein",
    contains("starfandi") ~ "Fjöldi (n)",
    contains("hlutf") ~ "Hlutfall (%)"
  ) |> 
  fmt_percent(
    columns = contains("hlutf")
  ) |> 
  fmt_integer(
    columns = contains("starfandi")
  ) |> 
  gt_color_rows(
    columns = c(3, 5, 7, 9),
    palette = "Greys"
  ) |> 
  sub_missing() |> 
  gtExtras::gt_theme_538()




d |> 
  rename(
    atv = atvinnugrein_balkar
  ) |> 
  mutate(
    starfandi = slider::slide_dbl(starfandi, mean, .before = 11),
    .by = c(atv, bakgrunnur)
  ) |> 
  filter(
    bakgrunnur != "Alls",
    dags <= clock::date_build(2026, 1, 1),
    str_detect(atv, "^[A-Z]+ |^O-Q")
  ) |> 
  janitor::remove_constant() |> 
  mutate(
    hlutf = starfandi / sum(starfandi),
    .by = c(atv, dags)
  ) |>
  filter(bakgrunnur == "Innflytjendur") |> 
  janitor::clean_names() |> 
  select(atv, dags, starfandi, hlutf) |> 
  mutate(
    atv = fct_reorder(atv, starfandi)
  ) |> 
  ggplot(aes(dags, starfandi)) +
  geom_area(
    aes(group = atv, fill = atv,col = atv, position = "stack")
    )


d |> 
  rename(
    atv = atvinnugrein_balkar
  ) |> 
  mutate(
    starfandi = slider::slide_dbl(starfandi, mean, .before = 11),
    .by = c(atv, bakgrunnur)
  ) |> 
  filter(
    bakgrunnur != "Alls",
    dags >= clock::date_build(2010, 1, 1),
    str_detect(atv, "^[A-Z]+ |^O-Q")
  ) |> 
  janitor::remove_constant() |> 
  mutate(
    change = starfandi - starfandi[dags == min(dags)],
    .by = c(atv, bakgrunnur)
  ) |> 
  filter(bakgrunnur == "Innflytjendur") |> 
  filter(
    max(change) >= 2000,
    .by = atv
  ) |> 
  janitor::clean_names() |> 
  select(atv, dags, starfandi, change) |> 
  mutate(
    atv = fct_reorder(atv, change)
  ) |> 
  ggplot(aes(dags, change)) +
  geom_hline(
    yintercept = 0,
    lty = 2
  ) +
  geom_line(
    aes(col = atv),
    linewidth = 1
  ) +
  geom_text(
    data = ~ filter(.x, dags == max(dags)),
    aes(col = atv, label = str_wrap(atv, width = 100)),
    hjust = 0,
    nudge_x = 30
  ) +
  scale_x_date(
    guide = guide_axis(cap = "both"),
    limits = date_build(c(2010, 2026)),
    breaks = date_build(c(2010, 2015, 2020, 2025)),
    labels = label_date_short()
  ) +
  scale_y_continuous(
    guide = guide_axis(cap = "both")
  ) +
  scale_colour_brewer(
    palette = "Set2"
  ) +
  coord_cartesian(
    clip = "off",
    xlim = date_build(c(2010, 2038))
  ) +
  theme(
    legend.position = "none"
  )


d |> 
  rename(
    atv = atvinnugrein_balkar
  ) |> 
  mutate(
    starfandi = slider::slide_dbl(starfandi, mean, .before = 11),
    .by = c(atv, bakgrunnur)
  ) |> 
  filter(
    bakgrunnur != "Alls",
    dags >= clock::date_build(2010, 1, 1),
    str_detect(atv, "^[A-Z]+ |^O-Q")
  ) |> 
  janitor::remove_constant() |> 
  mutate(
    change = starfandi - starfandi[dags == min(dags)],
    .by = c(atv, bakgrunnur)
  ) |> 
  filter(bakgrunnur == "Innflytjendur") |> 
  janitor::clean_names() |> 
  select(atv, dags, starfandi, change) |> 
  mutate(
    atv = fct_reorder(atv, change)
  ) |> 
  filter(dags == max(dags)) |> 
  pull(change) |> sum()


36 / (63 - 21)
