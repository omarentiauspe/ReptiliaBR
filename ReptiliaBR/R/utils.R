#' Brazilian state (UF) abbreviations used as column names in [lista_repteis]
#' @keywords internal
#' @noRd
br_state_codes <- function() {
  c("RR", "AP", "AC", "RO", "AM", "PA", "TO", "MT", "MS", "GO", "DF",
    "MA", "PI", "CE", "RN", "PB", "PE", "AL", "SE", "BA", "ES", "MG",
    "RJ", "SP", "PR", "SC", "RS")
}

#' Taxonomic rank columns available for filtering, in hierarchical order
#' @keywords internal
#' @noRd
taxon_ranks <- function() {
  c("order", "suborder", "clade", "superfamily", "family", "subfamily",
    "tribe", "genus", "species", "taxon")
}

#' Validate and normalize a vector of state codes
#' @keywords internal
#' @noRd
check_states <- function(states) {
  states <- toupper(states)
  valid <- br_state_codes()
  bad <- setdiff(states, valid)
  if (length(bad) > 0) {
    stop(
      "Unrecognized state code(s): ", paste(bad, collapse = ", "), ".\n",
      "Valid codes are: ", paste(valid, collapse = ", "),
      call. = FALSE
    )
  }
  states
}

#' Validate a taxonomic rank argument
#' @keywords internal
#' @noRd
check_rank <- function(rank) {
  valid <- taxon_ranks()
  if (!rank %in% valid) {
    stop(
      "`rank` must be one of: ", paste(valid, collapse = ", "),
      call. = FALSE
    )
  }
  rank
}

#' Build a styled text layer for map overlay labels (state codes / counts)
#'
#' Shared by [map_taxon()] and [map_richness()] so their `label_*`
#' arguments behave identically. Returns a `geom_text()` layer, or a
#' `geom_label()` layer (opaque/semi-opaque background box) when
#' `background = TRUE`, which improves legibility of text sitting on top
#' of colored/dark polygon fills.
#'
#' @param label_df Data frame with `X`, `Y` columns and the label text
#'   column named by `label_col`.
#' @param label_col Name of the column in `label_df` holding the label
#'   text.
#' @keywords internal
#' @noRd
label_layer <- function(label_df, label_col,
                         color = "grey20", size = 2.6,
                         family = "sans", fontface = "plain",
                         background = FALSE,
                         bg_color = "white", bg_alpha = 0.85) {
  mapping <- ggplot2::aes(x = .data$X, y = .data$Y,
                           label = .data[[label_col]])
  if (isTRUE(background)) {
    ggplot2::geom_label(
      data = label_df, mapping = mapping,
      colour = color, size = size, family = family, fontface = fontface,
      fill = bg_color, alpha = bg_alpha, label.size = 0,
      label.padding = ggplot2::unit(0.12, "lines"),
      label.r = ggplot2::unit(0.08, "lines")
    )
  } else {
    ggplot2::geom_text(
      data = label_df, mapping = mapping,
      colour = color, size = size, family = family, fontface = fontface
    )
  }
}
