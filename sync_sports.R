# sync_sports.R
# Syncs latest sports prediction figures from Sports/ to Website/
# Run this after updating sports models with Sports/update.R

library(fs)
library(here)
library(glue)

# Configuration
sports_dir <- here::here("..", "Sports")
website_dir <- here::here()

# Domestic leagues
domestic <- list(
  list(
    from = "basketball/iceland",
    to = "korfubolti",
    sexes = c("male" = "karlar", "female" = "konur")
  ),
  list(
    from = "handball/iceland",
    to = "handbolti",
    sexes = c("male" = "karlar", "female" = "konur")
  ),
  list(
    from = "football/iceland",
    to = "fotbolti",
    sexes = c("male" = "karlar", "female" = "konur")
  )
)

# International tournaments
international <- list(
  list(
    from = "handball/international",
    to = "handbolti/mot/em-karla-2026",
    sex = "male"
  ),
  list(
    from = "basketball/international",
    to = "korfubolti/mot/em-karla-2025",
    sex = "male"
  )
)

# Find latest dated folder with actual figures
get_latest_figures <- function(results_path) {
  if (!fs::dir_exists(results_path)) {
    return(NULL)
  }

  # Get all dated folders (YYYY-MM-DD format)
  dated_folders <- fs::dir_ls(results_path, type = "directory") |>
    fs::path_file() |>
    grep("^\\d{4}-\\d{2}-\\d{2}$", x = _, value = TRUE)

  if (length(dated_folders) == 0) {
    return(NULL)
  }

  # Find most recent folder that has actual PNG files
  for (folder in sort(dated_folders, decreasing = TRUE)) {
    figures_path <- fs::path(results_path, folder, "figures")
    if (fs::dir_exists(figures_path) && length(fs::dir_ls(figures_path, glob = "*.png")) > 0) {
      return(list(path = figures_path, date = folder))
    }
  }

  return(NULL)
}

# Sync domestic leagues
sync_domestic <- function(sport) {
  message(glue("\n📊 Syncing {sport$from} → {sport$to}"))

  sport_path <- fs::path(sports_dir, sport$from)

  if (!fs::dir_exists(sport_path)) {
    message(glue("  ⚠ Sport folder not found: {sport_path}"))
    return(invisible(NULL))
  }

  for (sex_en in names(sport$sexes)) {
    sex_is <- sport$sexes[sex_en]
    results_path <- fs::path(sport_path, "results", sex_en)

    result <- get_latest_figures(results_path)

    if (is.null(result)) {
      message(glue("  ⚠ {sex_is}: No figures to sync"))
      next
    }

    figures_to <- fs::path(website_dir, "ithrottir", sport$to, sex_is, "figures")
    pngs <- fs::dir_ls(result$path, glob = "*.png")

    if (length(pngs) == 0) {
      message(glue("  ⚠ {sex_is}: No PNG files found"))
      next
    }

    fs::dir_create(figures_to)
    fs::file_copy(pngs, figures_to, overwrite = TRUE)
    message(glue("  ✓ {sex_is}: Synced {length(pngs)} figures from {result$date}"))
  }
}

# Sync international tournaments
sync_international <- function(tournament) {
  message(glue("\n🌍 Syncing {tournament$from} → {tournament$to}"))

  sport_path <- fs::path(sports_dir, tournament$from)

  if (!fs::dir_exists(sport_path)) {
    message(glue("  ⚠ Tournament folder not found: {sport_path}"))
    return(invisible(NULL))
  }

  results_path <- fs::path(sport_path, "results", tournament$sex)
  result <- get_latest_figures(results_path)

  if (is.null(result)) {
    message(glue("  ⚠ No figures to sync"))
    return(invisible(NULL))
  }

  figures_to <- fs::path(website_dir, "ithrottir", tournament$to, "figures")
  pngs <- fs::dir_ls(result$path, glob = "*.png")

  if (length(pngs) == 0) {
    message(glue("  ⚠ No PNG files found"))
    return(invisible(NULL))
  }

  fs::dir_create(figures_to)
  fs::file_copy(pngs, figures_to, overwrite = TRUE)
  message(glue("  ✓ Synced {length(pngs)} figures from {result$date}"))
}

# Main execution
message("🔄 Starting sports figure sync...")
message(glue("   From: {sports_dir}"))
message(glue("   To:   {website_dir}/ithrottir/"))

message("\n=== Domestic Leagues ===")
for (sport in domestic) {
  sync_domestic(sport)
}

message("\n=== International Tournaments ===")
for (tournament in international) {
  sync_international(tournament)
}

message("\n✅ Sync complete!")
