#' List taxa in the national list of threatened species
#'
#' Returns the taxa of [lista_repteis] that are listed as threatened in the
#' official Brazilian list of threatened fauna (Portaria MMA n. 1.704, of
#' 16 June 2026), with their national risk category. See
#' [lista_repteis_threat] for details on the source and on how names in the
#' Portaria were matched to the checklist.
#'
#' @param category Character vector: one or more of `"CR (PE)"`, `"CR"`,
#'   `"EN"`, and `"VU"` (default: all). `"CR (PE)"` is kept apart from
#'   `"CR"`, as in the Portaria.
#' @param states Optional character vector of state (UF) codes. If
#'   supplied, only taxa with a confirmed occurrence in at least one of
#'   these states are returned, as in [list_taxa()].
#' @param taxon Optional character string. Case-insensitive partial match
#'   against the `taxon` column, e.g. `"Bothrops"` matches every threatened
#'   species of that genus.
#'
#' @return A data frame with the columns of [lista_repteis_threat], one row
#'   per threatened taxon.
#'
#' @examples
#' # Every threatened reptile
#' list_threatened()
#'
#' # Critically endangered species only
#' list_threatened("CR")
#'
#' # Threatened species recorded in Bahia
#' list_threatened(states = "BA")
#'
#' # Threatened species of a given genus
#' list_threatened(taxon = "Bothrops")
#'
#' @export
list_threatened <- function(category = c("CR (PE)", "CR", "EN", "VU"),
                             states = NULL, taxon = NULL) {
  category <- match.arg(category, choices = c("CR (PE)", "CR", "EN", "VU"),
                         several.ok = TRUE)
  data <- ReptiliaBR::lista_repteis_threat
  data <- data[data$category %in% category, , drop = FALSE]

  if (!is.null(states)) {
    states <- check_states(states)
    checklist <- ReptiliaBR::lista_repteis
    occ <- as.matrix(checklist[states])
    occurring <- checklist$taxon[rowSums(occ, na.rm = TRUE) > 0]
    data <- data[data$taxon %in% occurring, , drop = FALSE]
  }

  if (!is.null(taxon)) {
    keep <- grepl(taxon, data$taxon, ignore.case = TRUE)
    data <- data[keep, , drop = FALSE]
  }

  rownames(data) <- NULL
  data
}
