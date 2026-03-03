#!/usr/bin/env Rscript

extract_md_paths <- function(lines) {
  hits <- regmatches(
    lines,
    gregexpr("!\\[[^\\]]*\\]\\((figures/[^)]+\\.png)\\)", lines, perl = TRUE)
  )

  unlist(lapply(hits, function(x) {
    if (length(x) == 1 && identical(x, "")) {
      return(character(0))
    }
    sub(".*\\((figures/[^)]+\\.png)\\).*", "\\1", x, perl = TRUE)
  }), use.names = FALSE)
}

extract_html_paths <- function(lines) {
  hits <- regmatches(
    lines,
    gregexpr('src=["\'](figures/[^"\']+\\.png)["\']', lines, perl = TRUE)
  )

  unlist(lapply(hits, function(x) {
    if (length(x) == 1 && identical(x, "")) {
      return(character(0))
    }
    sub('src=["\'](figures/[^"\']+\\.png)["\']', "\\1", x, perl = TRUE)
  }), use.names = FALSE)
}

qmd_files <- list.files("ithrottir", pattern = "\\.qmd$", recursive = TRUE, full.names = TRUE)
qmd_files <- qmd_files[file.exists(qmd_files)]

if (length(qmd_files) == 0) {
  message("No sports qmd files found; skipping checks")
  quit(status = 0)
}

missing <- character(0)

for (qmd in qmd_files) {
  lines <- readLines(qmd, warn = FALSE, encoding = "UTF-8")
  refs <- unique(c(extract_md_paths(lines), extract_html_paths(lines)))

  if (length(refs) == 0) {
    next
  }

  qmd_dir <- dirname(qmd)
  abs_refs <- file.path(qmd_dir, refs)

  for (i in seq_along(abs_refs)) {
    if (!file.exists(abs_refs[[i]])) {
      missing <- c(missing, sprintf("%s -> %s", qmd, refs[[i]]))
    }
  }
}

if (length(missing) > 0) {
  message("Missing sports figure assets:")
  message(paste0("- ", missing, collapse = "\n"))
  quit(status = 1)
}

message(sprintf("Sports figure contract OK (%d qmd files checked)", length(qmd_files)))
