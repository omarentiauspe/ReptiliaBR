## Prepare `lista_repteis_threat` -------------------------------------------
# National threat status of the reptiles in `lista_repteis`, according to
# the official list of threatened Brazilian fauna:
#
#   Portaria MMA n. 1.704, de 16 de junho de 2026 (DOU de 17/06/2026,
#   edicao 111-B, secao 1 - extra B, p. 15). It replaces Annexes I and II
#   of Portaria MMA n. 444/2014; the previous version of those annexes was
#   Portaria MMA n. 148, de 7 de junho de 2022.
#   https://www.in.gov.br/web/dou/-/portaria-mma-n-1.704-de-16-de-junho-de-2026-712968917
#
# Source file: data-raw/status_ameaca_portaria1704.csv, one row per reptile
# taxon in Annex I of the Portaria (Annex II, extinct fauna, lists no
# reptiles). Columns:
#   numero              row number in Annex I
#   ordem               order, as printed in the Portaria
#   familia_portaria    family, as printed in the Portaria
#   nome_portaria       name, as printed in the Portaria
#   categoria           VU, EN, CR, or CR (PE)
#   nova_na_lista       TRUE when marked "*" in the Portaria (not on the
#                       previous list, Portaria MMA n. 148/2022)
#   nome_reptiliabr     matching `taxon` in lista_repteis
#   familia_reptiliabr  family of that taxon in lista_repteis
#   correspondencia     "exata" (same name), "grafia" (spelling variant),
#                       or "sinonimo" (name treated as a synonym by the
#                       checklist)
#   observacao          notes on every case that did not match directly
#
# The taxonomy follows lista_repteis: names in the Portaria are only mapped
# onto it, never the other way around.

threat_raw <- read.csv("data-raw/status_ameaca_portaria1704.csv",
                        stringsAsFactors = FALSE, encoding = "UTF-8",
                        na.strings = c("", "NA"))

load("data/lista_repteis.rda")

# sanity checks: every row maps onto exactly one taxon of the checklist
stopifnot(!anyNA(threat_raw$nome_reptiliabr))
stopifnot(!anyDuplicated(threat_raw$nome_reptiliabr))
stopifnot(all(threat_raw$nome_reptiliabr %in% lista_repteis$taxon))
stopifnot(all(threat_raw$categoria %in% c("VU", "EN", "CR", "CR (PE)")))

lista_repteis_threat <- data.frame(
  taxon = threat_raw$nome_reptiliabr,
  family = lista_repteis$family[match(threat_raw$nome_reptiliabr,
                                      lista_repteis$taxon)],
  category = threat_raw$categoria,
  new_in_list = threat_raw$nova_na_lista,
  name_in_source = threat_raw$nome_portaria,
  source = "Portaria MMA 1.704/2026",
  stringsAsFactors = FALSE
)

lista_repteis_threat <- lista_repteis_threat[
  order(lista_repteis_threat$family, lista_repteis_threat$taxon), ]
rownames(lista_repteis_threat) <- NULL

usethis::use_data(lista_repteis_threat, overwrite = TRUE)
