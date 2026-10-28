#' Checklist of Brazilian reptiles
#'
#' A curated taxonomic checklist of Brazilian reptile species (Testudines,
#' Crocodylia, and Squamata) with their recorded occurrence in each of the
#' 27 Brazilian states (Unidades da Federacao, UFs).
#'
#' @format A data frame with 911 rows and 41 columns:
#' \describe{
#'   \item{order}{Order, e.g. "TESTUDINES", "CROCODYLIA", "SQUAMATA".}
#'   \item{suborder}{Suborder, when applicable (may be `NA`).}
#'   \item{clade}{Clade, when applicable (may be `NA`).}
#'   \item{superfamily}{Superfamily, when applicable (may be `NA`).}
#'   \item{family}{Taxonomic family.}
#'   \item{subfamily}{Taxonomic subfamily (may be `NA`).}
#'   \item{tribe}{Taxonomic tribe (may be `NA`).}
#'   \item{genus}{Genus.}
#'   \item{species}{Specific epithet.}
#'   \item{subspecies}{Subspecific epithet, when applicable (may be `NA`).}
#'   \item{endemic_br}{Logical. `TRUE` if the taxon is endemic to Brazil.}
#'   \item{binomial}{Genus + species, e.g. "Anilius scytale".}
#'   \item{taxon}{Full name used throughout the package: binomial, or
#'     trinomial when a subspecies is recorded.}
#'   \item{RR, AP, AC, RO, AM, PA, TO, MT, MS, GO, DF, MA, PI, CE, RN, PB,
#'     PE, AL, SE, BA, ES, MG, RJ, SP, PR, SC, RS}{Logical columns, one per
#'     Brazilian state (2-letter UF code). `TRUE` when the taxon has a
#'     confirmed occurrence record in that state, `NA` when the record
#'     still needs review, `FALSE` when there is no record.}
#'   \item{review}{Character. Notes flagging rows that still need manual
#'     review (e.g. an abbreviated species name to be expanded), `NA`
#'     otherwise.}
#' }
#'
#' @source Compiled checklist supplied by the package maintainer.
"lista_repteis"

#' Doubtful and contested occurrence records
#'
#' A long-format companion to [lista_repteis]. Some state-level occurrence
#' records in the source checklist were flagged as `"?"` (doubtful) or
#' `"!"` (contested) rather than a plain presence/absence call. Those
#' records are `NA` in [lista_repteis]'s state columns; this table keeps
#' the original flag so it can be inspected on its own (see
#' [list_flagged()]).
#'
#' @format A data frame with 174 rows and 4 columns:
#' \describe{
#'   \item{taxon}{Binomial or trinomial name of the flagged taxon.}
#'   \item{family}{Taxonomic family, for convenient filtering.}
#'   \item{state}{Brazilian state (2-letter UF code) the flag applies to.}
#'   \item{status}{Either `"doubtful"` or `"contested"`.}
#' }
#'
#' @source Compiled checklist supplied by the package maintainer.
"lista_repteis_flags"

#' National threat status of Brazilian reptiles
#'
#' A companion to [lista_repteis] with the taxa listed as threatened in the
#' official list of threatened Brazilian fauna, "Lista Nacional Oficial das
#' Especies da Fauna Ameacadas de Extincao" (Annex I of Portaria MMA n.
#' 1.704, of 16 June 2026, which replaced the list in Portaria MMA n.
#' 148/2022). Taxa not in this table are not listed as threatened. Names
#' follow [lista_repteis]: when the Portaria uses a different spelling or a
#' synonym, the original name is kept in `name_in_source`. The full
#' correspondence, with notes on every name that did not match directly,
#' is in `data-raw/status_ameaca_portaria1704.csv`. Query it with
#' [list_threatened()].
#'
#' @format A data frame with 123 rows and 6 columns:
#' \describe{
#'   \item{taxon}{Binomial or trinomial name, as in [lista_repteis].}
#'   \item{family}{Taxonomic family, as in [lista_repteis].}
#'   \item{category}{National risk category: `"VU"` (Vulnerable), `"EN"`
#'     (Endangered), `"CR"` (Critically Endangered), or `"CR (PE)"`
#'     (Critically Endangered, Possibly Extinct).}
#'   \item{new_in_list}{Logical. `TRUE` when the taxon was not on the
#'     previous list (Portaria MMA n. 148/2022), as marked with `"*"` in
#'     the Portaria.}
#'   \item{name_in_source}{Name as printed in the Portaria.}
#'   \item{source}{The legal act, `"Portaria MMA 1.704/2026"`.}
#' }
#'
#' @source Portaria MMA n. 1.704, de 16 de junho de 2026. Diario Oficial da
#'   Uniao, 17 June 2026, edition 111-B, section 1 (extra B), p. 15.
#'   <https://www.in.gov.br/web/dou/-/portaria-mma-n-1.704-de-16-de-junho-de-2026-712968917>
"lista_repteis_threat"

#' Simplified polygons of the 27 Brazilian states
#'
#' A simple feature (`sf`) polygon layer with one row per Brazilian state
#' (Unidade da Federacao, UF), simplified for lightweight plotting.
#'
#' @format An `sf` object with 27 rows and 4 columns:
#' \describe{
#'   \item{uf}{2-letter state abbreviation, e.g. "SP", "AM".}
#'   \item{name}{Full state name, e.g. "Sao Paulo".}
#'   \item{region}{Macro-region: North, Northeast, Central-West, Southeast,
#'     or South.}
#'   \item{geometry}{Polygon/multipolygon geometry, CRS EPSG:4326.}
#' }
#'
#' @source Simplified from public-domain state boundaries published in the
#'   `giuliano-macedo/geodata-br-states` GitHub repository
#'   (CC0, <https://github.com/giuliano-macedo/geodata-br-states>).
"br_states"
