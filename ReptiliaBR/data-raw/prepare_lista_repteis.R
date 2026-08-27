## Prepare `lista_repteis` and `lista_repteis_flags` -----------------------
# Cleans the final checklist spreadsheet of Brazilian reptile taxonomy and
# state-level occurrence records into the data bundled with the package.
#
# Source spreadsheet: "reptiles_final.xlsx", exported to
# data-raw/lista_repteis_raw.csv (one row per taxon). Occurrence columns
# hold "X" when presence is confirmed, "?" when the record is doubtful,
# "!" when the record is contested, and are otherwise blank (no record).

state_cols <- c("RR","AP","AC","RO","AM","PA","TO","MT","MS","GO","DF",
                 "MA","PI","CE","RN","PB","PE","AL","SE","BA","ES","MG",
                 "RJ","SP","PR","SC","RS")

raw <- read.csv("data-raw/lista_repteis_raw.csv", stringsAsFactors = FALSE,
                 encoding = "UTF-8", na.strings = c("", "NA"))

trim <- function(x) {
  x <- trimws(x)
  x[x == ""] <- NA
  x
}

txt_cols <- c("Order", "Suborder", "Clade", "Superfamily", "Family",
              "Subfamily", "Tribe", "Genus", "Species", "Subspecies",
              "REVIEW")
raw[txt_cols] <- lapply(raw[txt_cols], trim)

# Occurrence columns: TRUE when confirmed ("X"), FALSE when blank (no
# record), NA when the record is flagged "?" (doubtful) or "!"
# (contested) -- the flag itself is preserved separately, in
# `lista_repteis_flags`, so it isn't lost.
occ <- lapply(state_cols, function(uf) {
  x <- trim(raw[[uf]])
  out <- rep(FALSE, length(x))
  out[toupper(x) == "X"] <- TRUE
  out[x %in% c("?", "!")] <- NA
  out
})
names(occ) <- state_cols

lista_repteis <- data.frame(
  order = raw$Order,
  suborder = raw$Suborder,
  clade = raw$Clade,
  superfamily = raw$Superfamily,
  family = raw$Family,
  subfamily = raw$Subfamily,
  tribe = raw$Tribe,
  genus = raw$Genus,
  species = raw$Species,
  subspecies = raw$Subspecies,
  stringsAsFactors = FALSE
)

lista_repteis$endemic_br <- !is.na(raw$End) & raw$End == "X"
lista_repteis$binomial <- paste(lista_repteis$genus, lista_repteis$species)
lista_repteis$taxon <- ifelse(
  !is.na(lista_repteis$subspecies),
  paste(lista_repteis$genus, lista_repteis$species, lista_repteis$subspecies),
  lista_repteis$binomial
)

lista_repteis <- cbind(lista_repteis, as.data.frame(occ, stringsAsFactors = FALSE))
lista_repteis$review <- raw$REVIEW

ord <- order(lista_repteis$family, lista_repteis$genus, lista_repteis$species)
lista_repteis <- lista_repteis[ord, ]
rownames(lista_repteis) <- NULL

# sanity checks
stopifnot(!anyNA(lista_repteis$genus), !anyNA(lista_repteis$species))
stopifnot(all(vapply(lista_repteis[state_cols], function(x) all(x %in% c(TRUE, FALSE, NA)), logical(1))))

## `lista_repteis_flags` ----------------------------------------------------
# Long-format companion table: one row per taxon x state record that is
# doubtful ("?") or contested ("!"), so those judgment calls stay
# queryable (see list_flagged()) instead of collapsing into plain NA.
taxon_all <- paste(raw$Genus, raw$Species)
taxon_all <- ifelse(!is.na(trim(raw$Subspecies)),
                     paste(taxon_all, trim(raw$Subspecies)), taxon_all)

flag_rows <- do.call(rbind, lapply(state_cols, function(uf) {
  x <- trim(raw[[uf]])
  is_flag <- x %in% c("?", "!")
  if (!any(is_flag)) return(NULL)
  data.frame(
    taxon = taxon_all[is_flag],
    family = lista_repteis$family[match(taxon_all[is_flag], lista_repteis$taxon)],
    state = uf,
    status = ifelse(x[is_flag] == "?", "doubtful", "contested"),
    stringsAsFactors = FALSE
  )
}))

lista_repteis_flags <- flag_rows[order(flag_rows$taxon, flag_rows$state), ]
rownames(lista_repteis_flags) <- NULL

usethis::use_data(lista_repteis, overwrite = TRUE)
usethis::use_data(lista_repteis_flags, overwrite = TRUE)
