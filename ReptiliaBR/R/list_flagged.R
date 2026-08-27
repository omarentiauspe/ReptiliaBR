#' List occurrence records flagged as doubtful or contested
#'
#' Some state-level occurrence records in [lista_repteis] are not a plain
#' presence/absence call: they were flagged in the source checklist as
#' `"?"` (doubtful) or `"!"` (contested). Those records are set to `NA`
#' in [lista_repteis]'s state columns so they don't count as confirmed
#' presences, but the underlying flag is kept in [lista_repteis_flags] so
#' it can still be inspected and evaluated on its own.
#'
#' @param status Character vector: one or both of `"doubtful"` and
#'   `"contested"` (default: both).
#' @param states Optional character vector of state (UF) codes to
#'   restrict to, e.g. `"SP"` or `c("AM", "PA")`.
#' @param taxon Optional character string. Case-insensitive partial match
#'   against the `taxon` column, e.g. `"Bothrops"` matches every flagged
#'   record for that genus.
#'
#' @return A data frame with columns `taxon`, `family`, `state`, and
#'   `status`, one row per flagged taxon/state record.
#'
#' @examples
#' # Every contested record
#' list_flagged("contested")
#'
#' # Doubtful or contested records in Rio de Janeiro
#' list_flagged(states = "RJ")
#'
#' # Flagged records for a given genus
#' list_flagged(taxon = "Bothrops")
#'
#' @export
list_flagged <- function(status = c("doubtful", "contested"), states = NULL,
                          taxon = NULL) {
  status <- match.arg(status, choices = c("doubtful", "contested"),
                       several.ok = TRUE)
  data <- ReptiliaBR::lista_repteis_flags
  data <- data[data$status %in% status, , drop = FALSE]

  if (!is.null(states)) {
    states <- check_states(states)
    data <- data[data$state %in% states, , drop = FALSE]
  }

  if (!is.null(taxon)) {
    keep <- grepl(taxon, data$taxon, ignore.case = TRUE)
    data <- data[keep, , drop = FALSE]
  }

  rownames(data) <- NULL
  data
}
