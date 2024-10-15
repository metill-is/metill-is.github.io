library(tidyverse)
library(metill)
library(ggh4x)
library(scales)
theme_set(theme_metill())


d <- read_csv(here::here("dashboards/properties/data/fasteignir_pop.csv"))

d |>
  mutate(
    fasteignir = if_else(
      ar == 2024,
      fasteignir / (10 / 12),
      fasteignir
    )
  ) |>
  mutate(
    new_per_pop = fasteignir / pop * 10000
  ) |>
  ggplot(aes(x = ar, y = new_per_pop)) +
  geom_line(
    alpha = 0.2
  ) +
  geom_smooth(
    method = "loess",
    span = 0.15,
    se = 0,
    linewidth = 1,
    n = 2000,
    col = "black"
  ) +
  scale_x_continuous(
    breaks = c(seq(1900, 2010, by = 10), 2024),
    guide = guide_axis_truncated(
      trunc_lower = 1900,
      trunc_upper = 2024
    )
  ) +
  scale_y_continuous(
    breaks = c(25, seq(100, 400, by = 100), 425),
    guide = guide_axis_truncated(
      trunc_lower = 25,
      trunc_upper = 425
    )
  ) +
  labs(
    x = NULL,
    y = NULL,
    title = "Fjöldi nýbyggðra fasteigna á 1.000 fullorðna íbúa Íslands frá 1900 til 2024",
    subtitle = "Grunngögn sýnd með fölum lit | Leitni sýnd með svörtum lit"
  )

ggsave(
  here::here("dashboards/properties/img/img.png"),
  width = 8,
  height = 0.621 * 8,
  scale = 1.3
)


d_iceland |>
  filter(year >= 2007) |>
  ggplot(aes(year, population / dwellings)) +
  geom_line()
