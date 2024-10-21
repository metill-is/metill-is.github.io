library(tidyverse)
library(ggiraph)
library(metill)
library(patchwork)
library(here)
library(arrow)
Sys.setlocale("LC_ALL", "is_IS.UTF-8")

theme_set(theme_metill(type = "blog"))

colors <- tribble(
  ~flokkur, ~litur,
  "Sjálfstæðisflokkurinn", "#377eb8",
  "Framsóknarflokkurinn", "#41ab5d",
  "Samfylkingin", "#e41a1c",
  "Vinstri Græn", "#00441b",
  "Viðreisn", "#ff7d14",
  "Píratar", "#984ea3",
  "Miðflokkurinn", "#08306b",
  "Flokkur Fólksins", "#FBB829",
  "Sósíalistaflokkurinn", "#67000d",
  "Annað", "grey50"
)

# read data
gallup_data <- read_csv("https://raw.githubusercontent.com/RafaelVias/althingi-forecast-2025/refs/heads/data_setup/data/gallup_data.csv?token=GHSAT0AAAAAACVJNYHDQUPGQXBNXV6L2AI6ZYWWQZQ")
maskina_data <- read_csv("https://raw.githubusercontent.com/RafaelVias/althingi-forecast-2025/refs/heads/data_setup/data/maskina_data.csv?token=GHSAT0AAAAAACVJNYHD2WDJ77OUODIQHYIGZYWWRQQ")
prosent_data <- read_csv("https://raw.githubusercontent.com/RafaelVias/althingi-forecast-2025/refs/heads/data_setup/data/prosent_data.csv?token=GHSAT0AAAAAACVJNYHD7ETSQWSWBWZFJB34ZYWWRXA")
felagsvisindastofnun_data <- read_csv("https://raw.githubusercontent.com/RafaelVias/althingi-forecast-2025/refs/heads/data_setup/data/felagsvisindastofnun_data.csv?token=GHSAT0AAAAAACVJNYHCHS6HN46EUAGGZS2AZYWWRIA")

# combine data
poll_data <- bind_rows(
  maskina_data,
  prosent_data,
  gallup_data,
  felagsvisindastofnun_data
) |>
  mutate(
    flokkur = if_else(flokkur == "Lýðræðisflokkurinn", "Annað", flokkur)
  ) |>
  mutate(
    p = n / sum(n),
    .by = c(date, fyrirtaeki)
  ) |>
  select(
    dags = date,
    fyrirtaeki,
    flokkur,
    p_poll = p
  )

temp <- tempfile()
download.file(
  "https://raw.githubusercontent.com/RafaelVias/althingi-forecast-2025/refs/heads/data_setup/data/y_rep_draws.parquet?token=GHSAT0AAAAAACZJYQ2LII5IWYZK4NZGFPWAZYWWVAQ",
  temp
)

d <- read_parquet(temp) |>
  mutate(
    value = value / sum(value),
    .by = c(.iteration, .chain, .draw, dags)
  ) |>
  summarise(
    mean = mean(value),
    q5 = quantile(value, 0.05),
    q95 = quantile(value, 0.95),
    .by = c(dags, flokkur)
  ) |>
  inner_join(
    colors
  ) |>
  inner_join(
    poll_data
  )

write_parquet(d, "data/election_tracker_data.parquet")
