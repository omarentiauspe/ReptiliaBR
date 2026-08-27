#' Map the distribution of a taxon across Brazilian states
#'
#' Draws a static choropleth map of Brazil highlighting the states where a
#' given taxon (species, genus, family, ...) is recorded to occur. States
#' that carry a doubtful (`"?"`) or contested (`"!"`) occurrence flag for
#' the matching taxa (see [list_flagged()]) are drawn in their own colors
#' rather than being folded into "no record".
#'
#' @param rank Taxonomic rank to filter on, e.g. `"taxon"`, `"genus"`,
#'   `"family"`. See [list_taxa()].
#' @param value Value at `rank` to match, e.g. `"Bothrops jararaca"`.
#' @param title Optional plot title. Defaults to `value`.
#' @param present_color Fill color for states with a confirmed occurrence.
#' @param absent_color Fill color for states without any record.
#' @param doubtful_color Fill color for states with a `"?"` (doubtful)
#'   occurrence flag and no confirmed record.
#' @param contested_color Fill color for states with a `"!"` (contested)
#'   occurrence flag and no confirmed record.
#' @param show_labels Logical. If `TRUE` (default), overlay state (UF)
#'   abbreviations.
#' @param label_color Color of the state-label text. Default `"grey20"`.
#' @param label_size Size (in the usual `ggplot2` text-size units) of the
#'   state-label text. Default `2.6`.
#' @param label_family Font family for the state-label text. One of
#'   `"sans"` (default), `"serif"`, or `"mono"` -- these are the only
#'   families guaranteed to render without extra font packages.
#' @param label_fontface Font face for the state-label text: `"plain"`
#'   (default), `"bold"`, `"italic"`, or `"bold.italic"`.
#' @param label_background Logical. If `TRUE`, draw the state-label text on
#'   a small opaque/semi-opaque background box, which can make labels
#'   easier to read against busy or dark fill colors. Default `FALSE`.
#' @param label_bg_color Fill color of the label background box, used only
#'   when `label_background = TRUE`. Default `"white"`.
#' @param label_bg_alpha Opacity (0-1) of the label background box, used
#'   only when `label_background = TRUE`. Default `0.85`.
#'
#' @return A `ggplot` object (printed automatically if not assigned).
#'
#' @examples
#' \donttest{
#' map_taxon("taxon", "Bothrops jararaca")
#' map_taxon("family", "Elapidae", title = "Coral snakes (Elapidae)")
#' map_taxon("family", "Elapidae", label_color = "white", label_size = 3.2,
#'           label_background = TRUE)
#' }
#'
#' @export
map_taxon <- function(rank = "taxon", value,
                       title = NULL,
                       present_color = "#2E6F40",
                       absent_color = "#E8E8E8",
                       doubtful_color = "#F2B705",
                       contested_color = "#C1272D",
                       show_labels = TRUE,
                       label_color = "grey20",
                       label_size = 2.6,
                       label_family = "sans",
                       label_fontface = "plain",
                       label_background = FALSE,
                       label_bg_color = "white",
                       label_bg_alpha = 0.85) {
  rank <- check_rank(rank)
  occ_states <- states_by_taxon(rank, value)
  flags <- flagged_states_by_taxon(rank, value)
  contested_states <- unique(flags$state[flags$status == "contested"])
  doubtful_states <- unique(flags$state[flags$status == "doubtful"])

  map_data <- ReptiliaBR::br_states

  occ_status <- rep("No record", nrow(map_data))
  occ_status[map_data$uf %in% doubtful_states] <- "Doubtful"
  occ_status[map_data$uf %in% contested_states] <- "Contested"
  occ_status[map_data$uf %in% occ_states] <- "Present"
  map_data$occ_status <- factor(
    occ_status,
    levels = c("Present", "Contested", "Doubtful", "No record")
  )

  if (is.null(title)) {
    title <- paste(value, collapse = " / ")
  }

  fill_values <- c(
    Present = present_color,
    Contested = contested_color,
    Doubtful = doubtful_color,
    `No record` = absent_color
  )
  fill_labels <- c(
    Present = "Occurs",
    Contested = sprintf("Contested (\"!\") \u2013 %d state(s)", length(contested_states)),
    Doubtful = sprintf("Doubtful (\"?\") \u2013 %d state(s)", length(doubtful_states)),
    `No record` = "No record"
  )
  # Drop unused levels so the legend doesn't show flag categories with 0
  # states when a taxon has no doubtful/contested records at all.
  used <- levels(map_data$occ_status)[levels(map_data$occ_status) %in%
                                         unique(as.character(map_data$occ_status))]
  fill_values <- fill_values[used]
  fill_labels <- fill_labels[used]

  p <- ggplot2::ggplot(map_data) +
    ggplot2::geom_sf(ggplot2::aes(fill = .data$occ_status), color = "white",
                      linewidth = 0.2) +
    ggplot2::scale_fill_manual(
      values = fill_values,
      labels = fill_labels,
      name = NULL,
      drop = TRUE
    ) +
    ggplot2::labs(title = title,
                  subtitle = sprintf(
                    "Recorded in %d of 27 states \u2014 %d contested, %d doubtful",
                    length(occ_states), length(contested_states),
                    length(doubtful_states)
                  )) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", hjust = 0.5),
      plot.subtitle = ggplot2::element_text(hjust = 0.5),
      legend.position = "bottom"
    )

  if (isTRUE(show_labels)) {
    centroids <- suppressWarnings(sf::st_centroid(map_data))
    coords <- sf::st_coordinates(centroids)
    label_df <- data.frame(uf = map_data$uf, X = coords[, 1], Y = coords[, 2])
    p <- p + label_layer(
      label_df, label_col = "uf",
      color = label_color, size = label_size, family = label_family,
      fontface = label_fontface, background = label_background,
      bg_color = label_bg_color, bg_alpha = label_bg_alpha
    )
  }

  p
}
