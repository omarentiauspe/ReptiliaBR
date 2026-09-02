# ReptiliaBR

The Brazilian list of Reptiles, now available in R format.
Checklists and static distribution maps for Brazilian reptiles (Testudines,
Crocodylia, and Squamata), based on a curated taxonomic checklist with
state-level (Unidade da Federacao / UF) occurrence records. 

# Citation: 

Entiauspe-Neto, O.M., Costa, H.C., Guedes, T.B. 2026. ReptiliaBR: an R/Shiny 
package for the checklist of Brazilian reptiles. Under Review. 

## Installation
#### Option 1: Using `remotes` (Recommended)

```r
# Install remotes if you haven't already
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

# Install ReptiliaBR from GitHub
remotes::install_github("omarentiauspe/ReptiliaBR", subdir = "ReptiliaBR")
```

#### Option 2: Using `devtools` 
```r
# Install devtools if you haven't already
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Install ReptiliaBR from GitHub
devtools::install_github("omarentiauspe/ReptiliaBR", subdir = "ReptiliaBR")
```

#### Option 3: Manual installation 

You can install `ReptiliaBR` in your own working directory, by downloading the source file and installing it as below:

```r
install.packages("ReptiliaBR_0.4.0.tar.gz", repos = NULL, type = "source")
```

Requires: `ggplot2`, `sf`, `rlang` (installed automatically as dependencies).

## What's included

- `lista_repteis` — data frame, 911 species x taxonomy + 27 state occurrence columns
- `lista_repteis_flags` — long-format table of occurrence records flagged
  as doubtful ("?") or contested ("!") in the source checklist
- `br_states` — `sf` polygon layer of the 27 Brazilian states

### Listing functions
- `list_taxa(rank, value, endemic_only, states, state_endemic_only, include_states)`
  — filter the checklist by any taxonomic rank (order, family, genus, ...),
  optionally restricted to endemics or to species occurring in given
  states. Every result includes a derived `state_endemic` column (`TRUE`
  when a taxon is endemic to Brazil *and* recorded in only one state);
  set `state_endemic_only = TRUE` to filter down to just those, or
  `include_states = TRUE` to add a compact column listing each taxon's
  occupied states
- `list_by_state(states, match = c("any","all"), rank, value)` — species
  recorded in one or more states
- `states_by_taxon(rank, value)` — which states a given taxon occurs in
- `search_species(pattern)` — free-text search across all name columns
- `list_flagged(status, states, taxon)` — doubtful or contested occurrence
  records, filterable by status, state, or taxon

### Mapping functions
- `map_taxon(rank, value)` — static choropleth showing which states a
  taxon (species/genus/family/...) occurs in. States with a `"?"`
  (doubtful) or `"!"` (contested) occurrence flag for the matching taxa
  are drawn in their own colors instead of being folded into "no record"
  (see `doubtful_color`/`contested_color`).
- `map_richness(rank, value, endemic_only)` — static choropleth of species
  counts per state, optionally filtered to a taxon
- `list_richness_species(rank, value, endemic_only)` — the checklist
  subset (species list) underlying a given `map_richness()` call, for
  the same filters — useful for inspecting or exporting exactly which
  species are being counted

Both `map_taxon()` and `map_richness()` accept `label_color`,
`label_size`, `label_family` (`"sans"`/`"serif"`/`"mono"`),
`label_fontface`, and `label_background`/`label_bg_color`/
`label_bg_alpha` arguments to style the state-code/richness-count text
drawn on the map and, optionally, draw it on a background box for
readability.

### Interactive app
- `run_app()` — launches a bundled Shiny app with five tabs: a filterable/
  downloadable checklist, free-text search, a single-taxon distribution
  map (Taxon Map), a richness map, and a by-state browser. Built with
  **base shiny only** (no DT, no bslib) — install with
  `install.packages("shiny")`.
  - The Checklist, Search, Taxon Map, and By state tabs each have a
    "Download CSV" button for the table currently on screen.
  - The Checklist tab has a "State endemic only" filter (taxa endemic to
    Brazil that are recorded in a single state) and a "Show geographic
    distribution" toggle that adds a column listing each taxon's
    occurring states.
  - The Taxon Map tab colors states with contested ("!") or doubtful
    ("?") occurrence records separately from confirmed/no-record states,
    its CSV download includes the per-state status, and it has "Download
    PNG"/"Download PDF" buttons for the map figure currently on screen.
  - The Richness map tab has a "Color palette" selector (Green, Blue,
    Orange-Red, Purple, Viridis) plus "Download PNG" and "Download PDF"
    buttons for the map currently on screen, and a "Show / export the
    species behind this map" toggle that displays (and lets you download
    as CSV) the exact list of species whose occurrences were summed into
    the counts shown.
  - The Taxon Map and Richness map tabs both have a "Map text style"
    panel to set the color (preset or custom hex), size, and font
    (sans-serif/serif/monospace, optionally bold) of the text overlaid
    on the map, plus a toggle to draw that text on a semi-opaque
    background box for readability against busy or dark fill colors.

## Examples

```r
library(ReptiliaBR)

# Launch the interactive Shiny app
run_app()

# All vipers
list_taxa("family", "Viperidae")

# Endemic species in genus Bothrops
list_taxa("genus", "Bothrops", endemic_only = TRUE)

# Species endemic to Brazil AND recorded in a single state
list_taxa(state_endemic_only = TRUE)

# Species recorded in every one of AM, PA, RR
list_by_state(c("AM", "PA", "RR"), match = "all")

# Where does the jararaca occur?
states_by_taxon("taxon", "Bothrops jararaca")

# Map a single species
map_taxon("taxon", "Bothrops jararaca")

# Richness map for a family
map_richness(rank = "family", value = "Elapidae")

# Same map, but with larger white text on a dark background box
map_richness(rank = "family", value = "Elapidae",
             label_color = "white", label_size = 3.2,
             label_background = TRUE, label_bg_color = "black")

# The species counted in that richness map
list_richness_species(rank = "family", value = "Elapidae")

# Contested occurrence records for a genus
list_flagged("contested", taxon = "Bothrops")

# All doubtful or contested records in Rio de Janeiro
list_flagged(states = "RJ")

```

## Data sources

- Taxonomy and state occurrence: curated checklist supplied by the package
  maintainer.
- State boundaries: simplified from `giuliano-macedo/geodata-br-states`
  (CC0 / public domain), reprojected to EPSG:4326.

## Notes

- Endemism (`endemic_br`) marks taxa endemic to Brazil, as coded in the
  source checklist ("End" column).
- State occurrence columns are `TRUE` (confirmed, "X" in the source
  checklist), `FALSE` (no record, blank), or `NA` (flagged "?" doubtful
  or "!" contested in the source checklist). The flag itself isn't
  discarded — it's kept in `lista_repteis_flags` and queryable with
  `list_flagged()`.
- The `data-raw/` scripts can be re-run on an updated spreadsheet (same
  column layout) to refresh the bundled `lista_repteis` and
  `lista_repteis_flags` data.
- `data-raw/edit_checklist.R` provides maintainer-only helpers (not part
  of the package API, not used by the app) for renaming a species, adding
  a species, or changing a state occurrence record directly in
  `lista_repteis_raw.csv`, each change automatically logged to
  `data-raw/changelog/CHANGELOG_<version>.md`. See
  `data-raw/example_edit_checklist.R` for a runnable example.
