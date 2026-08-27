## edit_checklist.R -----------------------------------------------------
## Maintenance helpers for editing data-raw/lista_repteis_raw.csv between
## releases.
##
## This file is NOT part of the package's exported API and is NOT used by
## the Shiny app -- it's a maintainer-only tool. Source it interactively:
##
##   source("data-raw/edit_checklist.R")
##
## Every change made with these functions is recorded in memory and written
## out as a dated Markdown log (data-raw/changelog/CHANGELOG_<version>.md)
## by checklist_save(), so each release has a record of exactly what
## changed in the underlying data. See data-raw/example_edit_checklist.R
## for a full worked example.
##
## Typical workflow:
##
##   source("data-raw/edit_checklist.R")
##   chk <- checklist_load()
##   chk <- checklist_rename_species(chk, "Bothrops", "jararaca",
##                                    new_species = "jararacussu")
##   chk <- checklist_add_species(chk, genus = "Bothrops", species = "cotiara",
##                                 family = "Viperidae", subfamily = "Crotalinae",
##                                 occurrences = c(PR = "X", SC = "X", RS = "X"))
##   chk <- checklist_set_occurrence(chk, "Bothrops", "jararaca",
##                                    state = "SP", status = "contested")
##   checklist_save(chk, version = "0.4.0")
##
## After checklist_save(), re-run data-raw/prepare_lista_repteis.R to
## rebuild the lista_repteis / lista_repteis_flags objects bundled with
## the package.

state_cols <- c("RR","AP","AC","RO","AM","PA","TO","MT","MS","GO","DF",
                 "MA","PI","CE","RN","PB","PE","AL","SE","BA","ES","MG",
                 "RJ","SP","PR","SC","RS")

checklist_cols <- c("Order","Suborder","Clade","Superfamily","Family",
                     "Subfamily","Tribe","Genus","Species","Subspecies",
                     "End", state_cols, "REVIEW")

status_symbol <- c(confirmed = "X", doubtful = "?", contested = "!", none = "")

## Internal, in-memory log of pending changes. Cleared each time
## checklist_save() writes a log file, so a fresh session/release starts
## empty.
.checklist_log <- new.env(parent = emptyenv())
.checklist_log$entries <- list()

.log_change <- function(action, taxon, ...) {
  entry <- c(list(timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
                   action = action, taxon = taxon), list(...))
  .checklist_log$entries[[length(.checklist_log$entries) + 1]] <- entry
  invisible(NULL)
}

## Build a full taxon string (genus + species [+ subspecies]) for messages
## and log entries.
.taxon_label <- function(genus, species, subspecies = NA) {
  if (!is.na(subspecies) && nzchar(subspecies)) {
    paste(genus, species, subspecies)
  } else {
    paste(genus, species)
  }
}

## Locate the single row matching a genus/species/subspecies combination.
## subspecies = NA matches the nominate row (blank Subspecies field).
.find_row <- function(df, genus, species, subspecies = NA) {
  match_sub <- if (is.na(subspecies)) {
    is.na(df$Subspecies) | df$Subspecies == ""
  } else {
    !is.na(df$Subspecies) & df$Subspecies == subspecies
  }
  idx <- which(df$Genus == genus & df$Species == species & match_sub)
  if (length(idx) == 0) {
    stop("No matching row for ", .taxon_label(genus, species, subspecies),
         call. = FALSE)
  }
  if (length(idx) > 1) {
    stop("Multiple matching rows for ", .taxon_label(genus, species, subspecies),
         " -- fix the source data first.", call. = FALSE)
  }
  idx
}

## --- Public functions ---------------------------------------------------

#' Load the raw checklist CSV as a plain character data frame.
checklist_load <- function(path = "data-raw/lista_repteis_raw.csv") {
  df <- read.csv(path, stringsAsFactors = FALSE, encoding = "UTF-8",
                  na.strings = character(0), colClasses = "character")
  missing_cols <- setdiff(checklist_cols, names(df))
  if (length(missing_cols) > 0) {
    stop("Raw CSV is missing expected column(s): ",
         paste(missing_cols, collapse = ", "), call. = FALSE)
  }
  df
}

#' Rename a species/subspecies (fix a typo, apply a taxonomic revision,
#' move a taxon to a new genus, etc). Only the fields you pass are changed.
checklist_rename_species <- function(df, genus, species, subspecies = NA,
                                      new_genus = NA, new_species = NA,
                                      new_subspecies = NA) {
  i <- .find_row(df, genus, species, subspecies)
  old_taxon <- .taxon_label(genus, species, subspecies)

  if (!is.na(new_genus))      df$Genus[i]      <- new_genus
  if (!is.na(new_species))    df$Species[i]    <- new_species
  if (!is.na(new_subspecies)) df$Subspecies[i] <- new_subspecies

  new_taxon <- .taxon_label(df$Genus[i], df$Species[i], df$Subspecies[i])
  .log_change("rename", old_taxon, new_taxon = new_taxon)
  message("Renamed ", old_taxon, " -> ", new_taxon)
  df
}

#' Add a new species (or subspecies) row to the checklist.
#' `occurrences` is a named character vector of state = status, e.g.
#' c(SP = "confirmed", RJ = "doubtful"); any state not listed defaults to
#' "none" (no record). Accepts either the long status names
#' (confirmed/doubtful/contested/none) or the raw symbols (X/?/!/"").
checklist_add_species <- function(df, genus, species, subspecies = NA,
                                   order = NA, suborder = NA, clade = NA,
                                   superfamily = NA, family = NA,
                                   subfamily = NA, tribe = NA,
                                   endemic = FALSE, occurrences = character(0),
                                   review = NA) {
  match_sub <- if (is.na(subspecies)) {
    is.na(df$Subspecies) | df$Subspecies == ""
  } else {
    !is.na(df$Subspecies) & df$Subspecies == subspecies
  }
  if (any(df$Genus == genus & df$Species == species & match_sub)) {
    stop(.taxon_label(genus, species, subspecies),
         " already exists in the checklist -- use checklist_rename_species() ",
         "or checklist_set_occurrence() instead.", call. = FALSE)
  }

  new_row <- as.data.frame(as.list(setNames(rep(NA_character_, length(checklist_cols)),
                                             checklist_cols)),
                            stringsAsFactors = FALSE)
  new_row$Order <- order; new_row$Suborder <- suborder; new_row$Clade <- clade
  new_row$Superfamily <- superfamily; new_row$Family <- family
  new_row$Subfamily <- subfamily; new_row$Tribe <- tribe
  new_row$Genus <- genus; new_row$Species <- species
  new_row$Subspecies <- subspecies
  new_row$End <- if (isTRUE(endemic)) "X" else NA
  new_row$REVIEW <- review
  new_row[state_cols] <- ""

  if (length(occurrences) > 0) {
    bad_states <- setdiff(names(occurrences), state_cols)
    if (length(bad_states) > 0) {
      stop("Unknown state code(s): ", paste(bad_states, collapse = ", "),
           call. = FALSE)
    }
    symbols <- ifelse(occurrences %in% names(status_symbol),
                       status_symbol[occurrences], occurrences)
    new_row[names(occurrences)] <- symbols
  }

  df <- rbind(df, new_row)
  taxon <- .taxon_label(genus, species, subspecies)
  .log_change("add", taxon, family = family,
              occurrences = paste(names(occurrences), occurrences,
                                   sep = "=", collapse = ", "))
  message("Added ", taxon)
  df
}

#' Set (or clear) a single species/state occurrence record.
#' status is one of "confirmed", "doubtful", "contested", "none".
checklist_set_occurrence <- function(df, genus, species, subspecies = NA,
                                      state, status = c("confirmed", "doubtful",
                                                         "contested", "none")) {
  status <- match.arg(status)
  if (!state %in% state_cols) {
    stop("Unknown state code: ", state, call. = FALSE)
  }
  i <- .find_row(df, genus, species, subspecies)
  old_value <- df[[state]][i]
  old_value <- if (is.na(old_value) || old_value == "") "none" else old_value
  new_value <- status_symbol[[status]]

  df[[state]][i] <- new_value
  taxon <- .taxon_label(genus, species, subspecies)
  .log_change("occurrence", taxon, state = state,
              old_value = old_value, new_value = status)
  message("Set ", taxon, " / ", state, ": ", old_value, " -> ", status)
  df
}

#' Show the changes recorded so far in this session (before saving).
checklist_log <- function() {
  if (length(.checklist_log$entries) == 0) {
    message("No pending changes.")
    return(invisible(NULL))
  }
  do.call(rbind, lapply(.checklist_log$entries, function(e) {
    as.data.frame(lapply(e, function(x) if (is.null(x)) NA else x),
                  stringsAsFactors = FALSE)
  }))
}

#' Write the updated checklist back to CSV and record a dated changelog
#' entry for this release. Clears the in-memory log afterwards.
checklist_save <- function(df, version,
                            path = "data-raw/lista_repteis_raw.csv",
                            log_dir = "data-raw/changelog") {
  write.csv(df[checklist_cols], path, row.names = FALSE, na = "")

  if (!dir.exists(log_dir)) dir.create(log_dir, recursive = TRUE)
  log_path <- file.path(log_dir, sprintf("CHANGELOG_%s.md", version))

  lines <- c(sprintf("# Data changes for v%s", version),
             sprintf("_Generated %s_", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
             "")
  entries <- .checklist_log$entries
  if (length(entries) == 0) {
    lines <- c(lines, "No changes recorded.")
  } else {
    for (e in entries) {
      line <- switch(e$action,
        rename = sprintf("- **Renamed**: %s -> %s", e$taxon, e$new_taxon),
        add = sprintf("- **Added**: %s (family: %s)%s", e$taxon,
                       if (is.na(e$family) || !nzchar(e$family)) "unspecified" else e$family,
                       if (nzchar(e$occurrences)) sprintf(" -- occurrences: %s", e$occurrences) else ""),
        occurrence = sprintf("- **Occurrence changed**: %s / %s: %s -> %s",
                              e$taxon, e$state, e$old_value, e$new_value),
        sprintf("- %s: %s", e$action, e$taxon)
      )
      lines <- c(lines, line)
    }
  }

  writeLines(lines, log_path)
  message(length(entries), " change(s) written to ", log_path)

  ## Reset the log so the next editing session starts clean.
  .checklist_log$entries <- list()
  invisible(path)
}
