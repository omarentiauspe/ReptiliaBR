#' Search taxa by free-text pattern
#'
#' Case-insensitive search across all taxonomic name columns (suborder
#' through taxon). Useful when you're not sure which rank a name belongs
#' to, or want partial matches.
#'
#' @param pattern Character. A regular expression or plain substring to
#'   search for, e.g. `"jarara"` or `"^Bothrops"`.
#' @param ... Additional arguments passed to [grepl()] (e.g.
#'   `fixed = TRUE`).
#'
#' @return A data frame subset of [lista_repteis] with rows where `pattern`
#'   matches any taxonomic name column.
#'
#' @examples
#' search_species("jarara")
#' search_species("^Micrurus")
#'
#' @export
search_species <- function(pattern, ...) {
  data <- ReptiliaBR::lista_repteis
  name_cols <- taxon_ranks_full()
  name_cols <- intersect(name_cols, names(data))

  hit <- Reduce(`|`, lapply(data[name_cols], function(col) {
    grepl(pattern, col, ignore.case = TRUE, ...) & !is.na(col)
  }))

  out_cols <- c(name_cols, "endemic_br")
  data[which(hit), intersect(out_cols, names(data)), drop = FALSE]
}
