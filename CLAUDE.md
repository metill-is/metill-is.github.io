# Website — CLAUDE.md

Quarto-based static website deployed to metill.is via GitHub Pages. Contains articles, interactive dashboards, sports prediction pages, and election forecasts. All content is in Icelandic.

## Directory structure

```
Website/
├── _quarto.yml              # Site configuration
├── index.qmd                # Homepage (auto-discovery listings)
├── greinar.qmd              # Articles index page
├── maelabord.qmd            # Dashboards index page
├── um_metil.qmd             # About page
├── theme.scss               # SCSS theme (flatly base + customizations)
├── style.css                # Additional CSS
├── content.yml              # Manual content listings (legacy fallback)
├── featured.yml             # Featured content for homepage hero
├── ejs/                     # EJS listing templates
│   ├── content-auto.ejs     # Auto-groups items by home-category
│   ├── featured.ejs         # Featured hero cards
│   └── featured-sports.ejs  # Sports listing cards
├── greinar/                 # Articles (data-driven analysis)
│   ├── flottafolk/          # Refugee/demographic analysis
│   ├── handbolti/           # Handball article
│   ├── landspitali/         # National Hospital analysis
│   ├── launagognfjarsyslu/  # Salary data analysis
│   ├── stjornmalaflokkar/   # Political parties analysis
│   └── vinnuafl/            # Labor force analysis
├── maelabord/               # Dashboards (interactive data viz)
│   ├── _setup.R             # Shared dashboard setup (libraries + theme)
│   ├── fasteignir/          # Real estate dashboard
│   ├── innflytjendur/       # Immigration dashboard
│   ├── leikskolar/          # Kindergarten dashboard
│   ├── skattagogn/          # Tax data (iframe to Shiny app)
│   ├── sveitarfelog/        # Municipalities (iframe to Shiny app)
│   ├── tekjuroggjold/       # Income/expenditure (draft)
│   └── verdbolga/           # Inflation dashboard
├── ithrottir/               # Sports section
│   ├── index.qmd            # Sports hub page with listings
│   ├── fotbolti/            # Football predictions
│   │   └── besta/           # Besta deild (besta-karla, besta-kvenna)
│   ├── handbolti/           # Handball predictions
│   │   └── olis/            # Olís deild (olis-karla, olis-kvenna)
│   └── korfubolti/          # Basketball predictions
│       ├── bonus/           # Bónusdeild (bonus-karla, bonus-kvenna)
│       └── greinar/         # Basketball articles
├── kosningaspa/             # Election forecast
│   ├── index.qmd            # Main forecast page
│   ├── Adferdir.qmd         # Methodology page
│   ├── UmLikanid.qmd        # Model description
│   └── R/                   # Election model scripts
├── docs/                    # Built site output (git-tracked for GitHub Pages)
├── _freeze/                 # Quarto freeze cache (auto-managed)
├── header/                  # Custom header HTML (legacy, replaced by navbar)
├── footer/                  # Footer components
├── favicon/                 # Favicon assets
└── .github/workflows/       # CI/CD
    └── render-site.yml      # GitHub Actions: render + deploy
```

## Commands

```bash
quarto render              # Build full site to docs/
quarto preview             # Local preview server (port 4212)
quarto render greinar/flottafolk/index.qmd   # Render single page
```

## Architecture

### Site configuration (`_quarto.yml`)

- **Output**: `docs/` directory (GitHub Pages)
- **URL**: https://metill.is
- **Theme**: Bootstrap "flatly" + custom `theme.scss`
- **Freeze**: `auto` — only re-renders changed pages
- **Navbar**: Built-in Quarto navbar with search, 5 nav items
- **Google Analytics**: G-J28QQV8PN9

### Homepage auto-discovery

The homepage uses a listing that auto-discovers content:

```yaml
- id: content
  template: ejs/content-auto.ejs
  contents:
    - greinar/*/index.qmd
    - maelabord/*/index.qmd
  include:
    home-category: "*"
  sort: "home-category"
```

Pages appear on the homepage when they have a `home-category` field in their YAML front matter. The EJS template groups items by category.

Current categories:
| Category | Pages |
|---|---|
| Útlendingar | innflytjendur, flottafolk |
| Heimili | fasteignir |
| Efnahagur | vinnuafl, verdbolga |
| Hið Opinbera | landspitali, stjornmalaflokkar |

To add a new page to the homepage, add `home-category: "CategoryName"` to its YAML front matter.

### Article/dashboard pattern

Each article (`greinar/*/`) and dashboard (`maelabord/*/`) follows:

```
topic/
├── index.qmd          # Main page (Quarto document or dashboard)
├── R/                 # R scripts sourced by index.qmd
│   ├── plot1.R        # Each script defines a function (e.g., make_plot1())
│   └── plot2.R
├── data/              # Data files (CSV, Parquet)
├── img/               # Images used in the page
└── Figures/           # Generated figures
```

### Dashboard setup

Dashboards source a shared setup file:

```r
source(here::here("maelabord", "_setup.R"))
```

This loads: tidyverse, scales, metill, glue, plotly, sets Icelandic locale, and applies `theme_metill()`.

Dashboard-specific libraries are loaded after the shared setup.

### Sports pages

Sport prediction pages display images from the Sports repos via raw GitHub URLs. Basketball and handball pages use parameterised `.qmd` files that construct image URLs from `params$repo` and `params$sex`. Updating predictions in the sport repos automatically updates the website.

**Exception: Football** — the football pages (`ithrottir/fotbolti/`) are hand-authored `.qmd` files with local figure paths (`figures/*.png`). Figures are manually copied from the `football/iceland` repo's results directory.

### Iframe dashboards

`skattagogn/` and `sveitarfelog/` embed external Shiny apps via iframes (hosted on shinyapps.io). These pages contain minimal Quarto content — just the iframe and custom CSS.

### CI/CD

`.github/workflows/render-site.yml` runs on push to `main`:
1. Sets up Quarto + R with dependencies
2. Runs `quarto render`
3. Commits and pushes `docs/` changes

R packages installed include: tidyverse, metill (from GitHub), here, gt, gtExtras, plotly, ggiraph, scales, glue, pxweb, eurostat, gganimate, patchwork, ggh4x, cowplot, kableExtra, rnaturalearth, sf, visitalaneysluverds, janitor.

## Styling

### Theme (`theme.scss`)

Based on Bootstrap "flatly" with overrides:
- **Primary**: `#484D6D` (dark blue)
- **Secondary**: `#faf9f9` (off-white)
- **Fonts**: Lato (body), Playfair Display (headings/brand)
- **Navbar**: Custom styled with Playfair Display brand, hover scale effects

### CSS (`style.css`)

Custom card styles (`.fp-card`), hero section, responsive adjustments. Cards use hover transform and box-shadow effects.

## Adding new content

### New article

1. Create `greinar/topic-name/index.qmd` with front matter:
   ```yaml
   ---
   title: "Title"
   description: "Description"
   home-category: "CategoryName"  # Optional: adds to homepage
   ---
   ```
2. Add R scripts to `greinar/topic-name/R/`
3. Add data to `greinar/topic-name/data/`
4. The article auto-appears on `greinar.qmd` via its listing

### New dashboard

1. Create `maelabord/topic-name/index.qmd` with format: dashboard
2. Source `maelabord/_setup.R` in setup chunk
3. Add `home-category` for homepage visibility
4. The dashboard auto-appears on `maelabord.qmd` via its listing

## Key dependencies

- **quarto** — Site generation
- **tidyverse** — Data manipulation and visualization
- **metill** — Custom R package (theme, formatting)
- **plotly** / **ggiraph** — Interactive visualizations
- **gt** / **gtExtras** — Table generation
- **pxweb** — Statistics Iceland API access
- **eurostat** — Eurostat data access
- **rnaturalearth** / **sf** — Map visualizations
