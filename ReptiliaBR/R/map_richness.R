#' Map species richness per Brazilian state
#'
#' Draws a static choropleth map of Brazil colored by the number of
#' matching species recorded in each state.
#'
#' @param rank,value Optional taxonomic filter, as in [list_taxa()]. If
#'   omitted, richness is computed over the entire checklist.
#' @param endemic_only Logical. If `TRUE`, count only taxa endemic to
#'   Brazil.
#' @param title Optional plot title.
#' @param palette A `ggplot2` continuous fill palette function, or `NULL`
#'   to use the default (`viridis`-like) scale.
#' @param label_color Color of the per-state richness-count text. Default
#'   `"grey15"`.
#' @param label_size Size (in the usual `ggplot2` text-size units) of the
#'   richness-count text. Default `2.6`.
#' @param label_family Font family for the richness-count text. One of
#'   `"sans"` (default), `"serif"`, or `"mono"` -- these are the only
#'   families guaranteed to render without extra font packages.
#' @param label_fontface Font face for the richness-count text: `"plain"`
#'   (default), `"bold"`, `"italic"`, or `"bold.italic"`.
#' @param label_background Logical. If `TRUE`, draw the richness-count
#'   text on a small opaque/semi-opaque background box, which can make
#'   labels easier to read against the fill palette. Default `FALSE`.
#' @param label_bg_color Fill color of the label background box, used only
#'   when `label_background = TRUE`. Default `"white"`.
#' @param label_bg_alpha Opacity (0-1) of the label background box, used
#'   only when `label_background = TRUE`. Default `0.85`.
#'
#' @return A `ggplot` object (printed automatically if not assigned).
#'
#' @examples
#' \donttest{
#' map_richness()
#' map_richness(rank = "family", value = "Viperidae",
#'              title = "Viperidae richness by state")
#' map_richness(label_color = "white", label_background = TRUE)
#' }
#'
#' @export
map_richness <- function(rank = NULL, value = NULL, endemic_only = FALSE,
                          title = NULL, palette = NULL,
                          label_color = "grey15",
                          label_size = 2.6,
                          label_family = "sans",
                          label_fontface = "plain",
                          label_background = FALSE,
                          label_bg_color = "white",
                          label_bg_alpha = 0.85) {
  data <- richness_subset(rank, value, endemic_only)

  states <- br_state_codes()
  occ <- as.matrix(data[states])
  richness <- colSums(occ, na.rm = TRUE)
  richness_df <- data.frame(uf = names(richness), n_species = as.integer(richness))

  map_data <- merge(ReptiliaBR::br_states, richness_df, by = "uf", all.x = TRUE)
  map_data$n_species[is.na(map_data$n_species)] <- 0L
  map_data <- sf::st_as_sf(map_data)

  if (is.null(title)) {
    title <- if (!is.null(value)) {
      paste("Species richness:", paste(value, collapse = " / "))
    } else {
      "Species richness by state"
    }
  }

  p <- ggplot2::ggplot(map_data) +
    ggplot2::geom_sf(ggplot2::aes(fill = n_species), color = "white",
                      linewidth = 0.2) +
    ggplot2::labs(title = title, fill = "N species") +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", hjust = 0.5),
      legend.position = "right"
    )

  p <- p + if (!is.null(palette)) {
    palette
  } else {
    ggplot2::scale_fill_gradient(low = "#F7FCB9", high = "#31A354")
  }

  centroids <- suppressWarnings(sf::st_centroid(map_data))
  coords <- sf::st_coordinates(centroids)
  label_df <- data.frame(uf = map_data$uf, n = map_data$n_species,
                          X = coords[, 1], Y = coords[, 2])
  p <- p + label_layer(
    label_df, label_col = "n",
    color = label_color, size = label_size, family = label_family,
    fontface = label_fontface, background = label_background,
    bg_color = label_bg_color, bg_alpha = label_bg_alpha
  )

  p
}

#' Filter the checklist for a richness map (shared by [map_richness()] and
#' [list_richness_species()])
#' @keywords internal
#' @noRd
richness_subset <- function(rank = NULL, value = NULL, endemic_only = FALSE) {
  data <- ReptiliaBR::lista_repteis

  if (!is.null(rank)) {
    rank <- check_rank(rank)
    if (!is.null(value)) {
      keep <- tolower(data[[rank]]) %in% tolower(value)
      data <- data[which(keep), , drop = FALSE]
    }
  }
  if (isTRUE(endemic_only)) {
    data <- data[data$endemic_br %in% TRUE, , drop = FALSE]
  }

  data
}

#' List the species underlying a richness map
#'
#' Returns the same checklist subset that [map_richness()] uses to compute
#' its per-state counts, for the same `rank`/`value`/`endemic_only`
#' filters. Useful for inspecting or exporting exactly which species are
#' being counted in a given richness map.
#'
#' @inheritParams map_richness
#'
#' @return A data frame subset of [lista_repteis] (taxonomic columns plus
#'   `endemic_br`), one row per matching species/subspecies -- the same
#'   set of taxa whose state occurrence columns are summed to produce the
#'   richness counts.
#'
#' @examples
#' list_richness_species(rank = "family", value = "Viperidae")
#' nrow(list_richness_species(endemic_only = TRUE))
#'
#' @export
list_richness_species <- function(rank = NULL, value = NULL,
                                   endemic_only = FALSE) {
  data <- richness_subset(rank, value, endemic_only)
  out_cols <- c(taxon_ranks_full(), "endemic_br")
  data[, intersect(out_cols, names(data)), drop = FALSE]
}
