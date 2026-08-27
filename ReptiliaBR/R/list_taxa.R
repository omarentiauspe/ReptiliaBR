#' List taxa filtered by taxonomic rank
#'
#' Returns the subset of [lista_repteis] matching a value (or values) at a given
#' taxonomic rank, e.g. all species in a family, all species in a genus, or
#' a single species by its full name.
#'
#' @param rank Character. One of `"order"`, `"suborder"`, `"clade"`,
#'   `"superfamily"`, `"family"`, `"subfamily"`, `"tribe"`, `"genus"`,
#'   `"species"`, or `"taxon"` (binomial/trinomial name).
#' @param value Character vector of one or more values to match at `rank`
#'   (case-insensitive). If `NULL` (default), no filtering is applied and
#'   the full checklist is returned.
#' @param endemic_only Logical. If `TRUE`, restrict to taxa endemic to
#'   Brazil (`endemic_br == TRUE`). Default `FALSE`.
#' @param states Optional character vector of state (UF) codes. If
#'   supplied, only taxa occurring in at least one of these states are
#'   returned.
#' @param state_endemic_only Logical. If `TRUE`, restrict to taxa that are
#'   both endemic to Brazil (`endemic_br == TRUE`) *and* recorded in
#'   exactly one Brazilian state (see `state_endemic` below). Default
#'   `FALSE`.
#' @param include_states Logical. If `TRUE`, add a `states` column listing
#'   the comma-separated state (UF) codes where each taxon is recorded to
#'   occur. Default `FALSE`.
#'
#' @return A tibble/data frame subset of [lista_repteis], including the
#'   taxonomic columns, `endemic_br`, and a derived `state_endemic` logical
#'   column (`TRUE` when the taxon is endemic to Brazil *and* occurs in
#'   only one state). State occurrence columns themselves are dropped for
#'   readability (use [states_by_taxon()] to see occurrence per state, or
#'   pass `include_states = TRUE` for a compact summary column).
#'
#' @examples
#' # All species in family Viperidae
#' list_taxa("family", "Viperidae")
#'
#' # All endemic species in genus Bothrops
#' list_taxa("genus", "Bothrops", endemic_only = TRUE)
#'
#' # Species in Dipsadidae occurring in Sao Paulo or Rio de Janeiro
#' list_taxa("family", "Dipsadidae", states = c("SP", "RJ"))
#'
#' # Species endemic to a single Brazilian state
#' list_taxa(state_endemic_only = TRUE)
#'
#' @export
list_taxa <- function(rank = "family", value = NULL, endemic_only = FALSE,
                       states = NULL, state_endemic_only = FALSE,
                       include_states = FALSE) {
  rank <- check_rank(rank)
  data <- ReptiliaBR::lista_repteis

  if (!is.null(value)) {
    col <- data[[rank]]
    keep <- tolower(col) %in% tolower(value)
    data <- data[which(keep), , drop = FALSE]
  }

  if (isTRUE(endemic_only)) {
    data <- data[data$endemic_br %in% TRUE, , drop = FALSE]
  }

  if (!is.null(states)) {
    states <- check_states(states)
    occ <- as.matrix(data[states])
    keep <- rowSums(occ, na.rm = TRUE) > 0
    data <- data[which(keep), , drop = FALSE]
  }

  # -- State endemism & (optional) per-taxon state summary --------------
  # A taxon is "state endemic" when it is endemic to Brazil AND has a
  # confirmed occurrence record (TRUE) in exactly one of the 27 states.
  # NA (flagged "?"/"!") and FALSE records don't count as a confirmed
  # occurrence for this purpose.
  all_states <- br_state_codes()
  occ_all <- as.matrix(data[all_states])
  occ_all[is.na(occ_all)] <- FALSE
  n_states <- rowSums(occ_all)
  data$state_endemic <- (data$endemic_br %in% TRUE) & (n_states == 1)

  if (isTRUE(include_states)) {
    data$states <- apply(occ_all, 1, function(row) {
      paste(all_states[row], collapse = ", ")
    })
  }

  if (isTRUE(state_endemic_only)) {
    data <- data[data$state_endemic, , drop = FALSE]
  }

  out_cols <- c(taxon_ranks_full(), "endemic_br", "state_endemic")
  if (isTRUE(include_states)) {
    out_cols <- c(out_cols, "states")
  }
  data[, intersect(out_cols, names(data)), drop = FALSE]
}

#' @keywords internal
#' @noRd
taxon_ranks_full <- function() {
  c("order", "suborder", "clade", "superfamily", "family", "subfamily",
    "tribe", "genus", "species", "subspecies", "binomial", "taxon")
}
