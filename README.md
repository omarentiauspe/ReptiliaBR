# ReptiliaBR
**<h2>ReptiliaBR: an R/Shiny package for the checklist of Brazilian reptiles**

# RUNNING ReptiliaBR
ReptiliaBR is implemented in R language. It imports "ggplot2", "rlang", and "sf". For tutorial use, see  the ["Guide" folder here](https://github.com/omarentiauspe/ReptiliaBR/tree/main/Guide).

# DESCRIPTION
Package: ReptiliaBR
Title: Checklists and Distribution Maps for Brazilian Reptiles
Version: 0.4.0
Authors@R: 
    person("Omar M.", "Entiauspe-Neto", email = "entiauspe@usp.br",
           role = c("aut", "cre"))
Description: Provides a curated taxonomic checklist of Brazilian reptile
    species (Testudines, Crocodylia, and Squamata) together with their
    state-level (Unidade da Federacao) occurrence records. Includes
    helper functions to filter and list species by taxonomic rank or by
    state, and to draw static choropleth maps of species richness or of
    a single taxon's distribution across the 27 Brazilian states.
License: MIT + file LICENSE
Encoding: UTF-8
Roxygen: list(markdown = TRUE)
RoxygenNote: 7.3.1
Depends: R (>= 4.1)
Imports: ggplot2, rlang, sf
Suggests: shiny, testthat (>= 3.0.0)
Config/testthat/edition: 3
LazyData: true
NeedsCompilation: no
Maintainer: Omar M. Entiauspe-Neto <entiauspe@usp.br>

Authored by Omar M. Entiauspe-Neto◑, Henrique C. Costa◑◑, and Thaís B. Guedes◑◑◑
◑ Instituto Butantan, Laboratório de Coleções Zoológicas, 05503-90, São Paulo, SP, Brazil. 
◑◑ Universidade Federal de Juiz de Fora, Instituto de Ciências Biológicas, Departamento de Zoologia, Campus Universitário, 36036-900, Juiz de Fora, MG, Brazil.
◑◑◑ Instituto de Biociências, Departamento de Biodiversidade, Universidade Estadual Paulista “Júlio de Mesquita Filho”, Rio Claro, São Paulo, 13506-900, Brazil.
