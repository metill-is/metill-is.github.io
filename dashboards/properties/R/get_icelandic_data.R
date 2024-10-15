library(tidyverse)
library(arrow)
library(metill)
library(rjson)

d_json <- fromJSON(file = "https://talnaefni.fasteignaskra.is/talnaefni/v1/staerdibudasveitarfelog")

d_fasteignir <- tibble(
  data = list(d_json)
) |>
  unnest_wider(data) |>
  unnest_longer(sveitarfélög) |>
  unnest_wider(sveitarfélög) |>
  unnest_longer(c(-name)) |>
  mutate_at(vars(-name), parse_number) |>
  mutate(
    fjoldi_nyjar = fjolbyli_fjoldi + serbyli_fjoldi
  ) |>
  mutate(
    fjoldi = cumsum(fjoldi_nyjar),
    .by = name
  ) |>
  select(
    ar = date,
    sveitarfelag = name,
    fjoldi_nyjar,
    fjoldi
  )

mannfjoldi <- mtl_mannfjoldi_svf() |>
  collect() |>
  mutate(
    vinnualdur = ifelse((aldur >= 20) & (aldur <= 64), 1, 0),
    heild = 1,
    fullordin = ifelse(aldur >= 20, 1, 0)
  ) |>
  group_by(sveitarfelag, ar) |>
  summarise(
    mannfjoldi_vinnualdur = sum(mannfjoldi * vinnualdur),
    mannfjoldi_fullordin = sum(mannfjoldi * fullordin),
    mannfjoldi = sum(mannfjoldi * heild)
  )


d <- d |>
  left_join(
    mannfjoldi,
    by = c("ar", "sveitarfelag")
  ) |>
  group_by(sveitarfelag) |>
  fill(mannfjoldi_vinnualdur, mannfjoldi_fullordin, mannfjoldi, .direction = "down") |>
  ungroup() |>
  drop_na()

d |>
  summarise(
    new_dwellings = sum(fjoldi),
    dwellings = sum(cum_fjoldi),
    population = sum(mannfjoldi),
    .by = ar
  ) |>
  rename(year = ar) |>
  mutate(
    country = "Iceland",
    new_by_pop = new_dwellings / population * 1000,
    rolling = slider::slide_index_dbl(new_by_pop, year, sum, .before = 9),
    country = "Iceland"
  ) |>
  write_parquet("greinar/fasteignafjoldi/data/data_iceland.parquet")
