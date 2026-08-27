## example_edit_checklist.R -----------------------------------------------
## Worked example for data-raw/edit_checklist.R.
##
## This script runs against a throwaway COPY of the raw checklist (in
## tempdir()), so it's safe to source as-is to see how the helpers and the
## changelog work. For a real release, point `csv_path` at the real
## data-raw/lista_repteis_raw.csv instead (or just omit `path`/`log_dir`
## arguments below to use the defaults).

source("data-raw/edit_checklist.R")

## --- safe sandbox copy, delete this block for a real release -----------
csv_path <- file.path(tempdir(), "lista_repteis_raw.csv")
log_dir  <- file.path(tempdir(), "changelog")
file.copy("data-raw/lista_repteis_raw.csv", csv_path, overwrite = TRUE)
## -------------------------------------------------------------------------

chk <- checklist_load(csv_path)

## 1. Fix a species name (e.g. a taxonomic revision moved it to a new
##    specific epithet).
chk <- checklist_rename_species(chk, genus = "Bothrops", species = "jararaca",
                                 new_species = "jararacatinga")

## 2. Add a newly described species, with its state occurrences.
chk <- checklist_add_species(
  chk,
  genus = "Bothrops", species = "exemplaris",
  order = "SQUAMATA", suborder = "SERPENTES",
  family = "Viperidae", subfamily = "Crotalinae",
  endemic = TRUE,
  occurrences = c(SP = "confirmed", RJ = "confirmed", MG = "doubtful"),
  review = "Described 2026, added for example purposes"
)

## 3. Update an existing occurrence record (e.g. a new state record
##    confirmed, or a doubtful record resolved).
chk <- checklist_set_occurrence(chk, genus = "Bothrops", species = "jararacussu",
                                 state = "PR", status = "confirmed")

## Review what's about to be written before saving.
print(checklist_log())

## Write the updated CSV and the per-release changelog.
checklist_save(chk, version = "0.4.0-example", path = csv_path, log_dir = log_dir)

## Inspect the generated log.
cat(readLines(file.path(log_dir, "CHANGELOG_0.4.0-example.md")), sep = "\n")

## For a real release, after checklist_save() with the real path:
##   1. Re-run data-raw/prepare_lista_repteis.R to rebuild lista_repteis /
##      lista_repteis_flags.
##   2. Commit the updated data-raw/lista_repteis_raw.csv, the new
##      data-raw/changelog/CHANGELOG_<version>.md, and the rebuilt data/*.rda
##      files together.
