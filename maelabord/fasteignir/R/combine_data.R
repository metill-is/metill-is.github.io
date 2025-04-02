d <- read_csv("maelabord/fasteignir/data/fasteignir_pop.csv")
d_gleeson <- read_csv("maelabord/fasteignir/data/gleeson.csv")



d |>
  filter(year >= 2007) |>
  ggplot(aes(year, population / dwellings)) +
  geom_line()


bind_rows(d, d_gleeson) |>
  inner_join(
    read_csv("dashboards/properties/data/pop.csv")
  ) |>
  mutate(
    new_by_adult = new_dwellings / population_adult * 1000,
    rolling_adult = slider::slide_index_dbl(new_by_adult, year, sum, .before = 9),
    .by = country
  ) |>
  filter(
    between(year, 2007, 2023)
  ) |>
  inner_join(
    metill::country_names()
  ) |>
  select(-country) |>
  rename(country = land) |>
  write_csv("maelabord/fasteignir/data/data_combined.csv")
