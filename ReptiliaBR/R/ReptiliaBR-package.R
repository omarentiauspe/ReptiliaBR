#' ReptiliaBR: Checklists and Distribution Maps for Brazilian Reptiles
#'
#' Tools to explore a taxonomic checklist of Brazilian reptiles and their
#' occurrence across the 27 Brazilian states (Unidades da Federacao, UFs).
#' The package bundles three datasets, [lista_repteis], [lista_repteis_flags],
#' and [br_states], and a set of functions to filter, list, and map species
#' occurrence.
#'
#' @section Main functions:
#' * [list_taxa()] - filter the checklist by any taxonomic rank
#' * [list_by_state()] - species recorded in one or more states
#' * [states_by_taxon()] - states where a given taxon occurs
#' * [search_species()] - free-text search across taxon names
#' * [list_flagged()] - doubtful or contested occurrence records
#' * [map_taxon()] - map where a taxon (species, genus, family, ...) occurs
#' * [map_richness()] - choropleth of species richness per state
#'
#' @keywords internal
#' @importFrom rlang .data
"_PACKAGE"

## quiets concerns of R CMD check re: variables used in NSE (dplyr/ggplot2)
utils::globalVariables(c(
  "uf", "name", "region", "n_species", "present", "state",
  "order", "suborder", "clade", "superfamily", "family", "subfamily",
  "tribe", "genus", "species", "subspecies", "binomial", "taxon",
  "endemic_br", "review", "status", "geometry"
))
