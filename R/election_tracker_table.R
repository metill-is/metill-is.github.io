library(tidyverse)
library(gt)
library(gtExtras)
library(arrow)
library(here)
library(glue)

colors <- tribble(
  ~flokkur, ~litur,
  "Sjálfstæðisflokkurinn", "#377eb8",
  "Framsóknarflokkurinn", "#41ab5d",
  "Samfylkingin", "#e41a1c",
  "Vinstri Græn", "#006d2c",
  "Viðreisn", "#f16913",
  "Píratar", "#6a51a3",
  "Miðflokkurinn", "#08306b",
  "Flokkur Fólksins", "#FBB829",
  "Sósíalistaflokkurinn", "#a50f15",
  "Annað", "grey50"
)

gallup_data <- read_csv(here("data", "gallup_data.csv"))
maskina_data <- read_csv(here("data", "maskina_data.csv"))
prosent_data <- read_csv(here("data", "prosent_data.csv"))
felagsvisindastofnun_data <- read_csv(here("data", "felagsvisindastofnun_data.csv"))

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

d <- read_parquet(here("data", "y_rep_draws.parquet")) |>
  summarise(
    mean = mean(value),
    q5 = quantile(value, 0.05),
    q95 = quantile(value, 0.95),
    .by = c(dags, flokkur)
  ) |>
  inner_join(
    colors
  )

table <- d |>
  filter(dags == max(dags)) |>
  select(flokkur, mean, q5, q95) |>
  arrange(desc(mean)) |>
  gt() |>
  cols_label(
    flokkur = "Flokkur",
    mean = "Vegið fylgi",
    q5 = "Neðri",
    q95 = "Efri"
  ) |>
  tab_spanner(
    label = "95% Öryggisbil",
    columns = c(q5, q95)
  ) |>
  cols_align(
    align = "left",
    columns = 1
  ) |>
  cols_align(
    align = "center",
    columns = -1
  ) |>
  fmt_percent() |>
  tab_header(
    title = "Fylgi stjórnmálaflokka",
    subtitle = glue("Síðasta könnun: {max(poll_data$dags)}")
  ) |>
  tab_footnote(
    md(
      str_c(
        "Matið styðst við kannanir Félagsvísindastofnunar, Gallup, Maskínu og Prósents\n",
        "auk niðurstaðna kosninga frá 2021"
      )
    )
  )


for (row in seq_len(nrow(colors))) {
  table <- table |>
    tab_style(
      style = cell_text(
        color = colors$litur[row],
        weight = 800
      ),
      locations = cells_body(
        rows = flokkur == colors$flokkur[row]
      )
    )
}


table
