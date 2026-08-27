test_that("map_taxon returns a ggplot object", {
  p <- map_taxon("taxon", "Bothrops jararaca")
  expect_s3_class(p, "ggplot")
})

test_that("map_taxon flags contested/doubtful states with their own status", {
  flagged_taxon <- lista_repteis_flags$taxon[
    lista_repteis_flags$status == "contested"
  ][1]
  skip_if(is.na(flagged_taxon), "no contested record to test against")

  p <- map_taxon("taxon", flagged_taxon)
  expect_s3_class(p, "ggplot")
  expect_true("occ_status" %in% names(p$data))
  expect_true("Contested" %in% levels(p$data$occ_status))

  flagged_state <- lista_repteis_flags$state[
    lista_repteis_flags$taxon == flagged_taxon &
      lista_repteis_flags$status == "contested"
  ][1]
  expect_equal(
    as.character(p$data$occ_status[p$data$uf == flagged_state]),
    "Contested"
  )
})

test_that("map_taxon accepts custom doubtful/contested colors", {
  p <- map_taxon("taxon", "Bothrops jararaca",
                  doubtful_color = "#000000", contested_color = "#FFFFFF")
  expect_s3_class(p, "ggplot")
})

test_that("map_richness returns a ggplot object", {
  p <- map_richness(rank = "family", value = "Viperidae")
  expect_s3_class(p, "ggplot")
})

test_that("map_richness works with no filters", {
  p <- map_richness()
  expect_s3_class(p, "ggplot")
})

test_that("map_taxon accepts label style / background options", {
  p1 <- map_taxon("taxon", "Bothrops jararaca",
                   label_color = "white", label_size = 3.2,
                   label_family = "serif", label_fontface = "bold")
  expect_s3_class(p1, "ggplot")

  p2 <- map_taxon("taxon", "Bothrops jararaca",
                   label_background = TRUE, label_bg_color = "black",
                   label_bg_alpha = 0.5)
  expect_s3_class(p2, "ggplot")
  expect_true(inherits(p2$layers[[length(p2$layers)]]$geom, "GeomLabel"))
})

test_that("map_richness accepts label style / background options", {
  p1 <- map_richness(rank = "family", value = "Viperidae",
                      label_color = "grey40", label_size = 3)
  expect_s3_class(p1, "ggplot")

  p2 <- map_richness(label_background = TRUE)
  expect_s3_class(p2, "ggplot")
  expect_true(inherits(p2$layers[[length(p2$layers)]]$geom, "GeomLabel"))
})

test_that("list_richness_species matches the species behind map_richness", {
  sp <- list_richness_species(rank = "family", value = "Viperidae")
  expect_true(all(tolower(sp$family) == "viperidae"))
  expect_true(nrow(sp) > 0)

  all_sp <- list_richness_species()
  expect_equal(nrow(all_sp), nrow(lista_repteis))

  endemic_sp <- list_richness_species(endemic_only = TRUE)
  expect_true(all(endemic_sp$endemic_br))
})
