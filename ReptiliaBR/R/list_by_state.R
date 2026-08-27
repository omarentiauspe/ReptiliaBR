#' List species occurring in one or more Brazilian states
#'
#' @param states Character vector of state (UF) codes, e.g. `"SP"` or
#'   `c("AM", "PA", "RR")`.
#' @param match Either `"any"` (default; species occurring in at least one
#'   of `states`) or `"all"` (species occurring in every state listed).
#' @param rank,value Optional taxonomic filter, as in [list_taxa()]. Use to
#'   restrict results to a family, genus, etc. before intersecting with
#'   `states`.
#'
#' @return A data frame with the taxonomic columns of [lista_repteis], one row
#'   per matching species.
#'
#' @examples
#' # Species recorded in Amazonas
#' list_by_state("AM")
#'
#' # Species recorded in all of AM, PA and RR
#' list_by_state(c("AM", "PA", "RR"), match = "all")
#'
#' # Vipers occurring in Sao Paulo
#' list_by_state("SP", rank = "family", value = "Viperidae")
#'
#' @export
list_by_state <- function(states, match = c("any", "all"),
                           rank = NULL, value = NULL) {
  match <- match.arg(match)
  states <- check_states(states)
  data <- ReptiliaBR::lista_repteis

  if (!is.null(rank)) {
    rank <- check_rank(rank)
    if (!is.null(value)) {
      keep <- tolower(data[[rank]]) %in% tolower(value)
      data <- data[which(keep), , drop = FALSE]
    }
  }

  occ <- as.matrix(data[states])
  keep <- if (match == "any") {
    rowSums(occ, na.rm = TRUE) > 0
  } else {
    rowSums(occ, na.rm = TRUE) == length(states)
  }

  out_cols <- c(taxon_ranks_full(), "endemic_br")
  data[which(keep), intersect(out_cols, names(data)), drop = FALSE]
}

#' List the states where a taxon occurs
#'
#' @param rank Taxonomic rank to filter on, e.g. `"taxon"` for a single
#'   species, `"genus"`, `"family"`, etc. See [list_taxa()].
#' @param value Value at `rank` to match, e.g. `"Bothrops jararaca"`.
#'
#' @return A character vector of state (UF) codes where at least one
#'   matching taxon occurs, in the same North-to-South order used
#'   throughout the package.
#'
#' @examples
#' states_by_taxon("taxon", "Bothrops jararaca")
#' states_by_taxon("family", "Elapidae")
#'
#' @export
states_by_taxon <- function(rank = "taxon", value) {
  rank <- check_rank(rank)
  data <- ReptiliaBR::lista_repteis
  keep <- tolower(data[[rank]]) %in% tolower(value)
  data <- data[which(keep), , drop = FALSE]

  if (nrow(data) == 0) {
    return(character(0))
  }

  states <- br_state_codes()
  occ <- as.matrix(data[states])
  states[colSums(occ, na.rm = TRUE) > 0]
}

#' Doubtful/contested flag records for the taxa matching a rank/value
#'
#' Internal helper used by [map_taxon()] to look up which states carry a
#' `"?"` (doubtful) or `"!"` (contested) flag for a taxon (or every taxon
#' under a higher rank, e.g. a whole family/genus).
#'
#' @param rank,value As in [list_taxa()].
#'
#' @return A subset of [lista_repteis_flags] with rows for the matching
#'   taxa only (may have 0 rows).
#'
#' @keywords internal
#' @noRd
flagged_states_by_taxon <- function(rank, value) {
  rank <- check_rank(rank)
  matching <- list_taxa(rank, value)
  taxa <- matching$taxon
  flags <- ReptiliaBR::lista_repteis_flags
  flags[flags$taxon %in% taxa, , drop = FALSE]
}
