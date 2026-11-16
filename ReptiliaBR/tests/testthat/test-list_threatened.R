test_that("list_threatened with no filters returns the whole table", {
  out <- list_threatened()
  expect_equal(nrow(out), nrow(lista_repteis_threat))
  expect_named(out, names(lista_repteis_threat))
})

test_that("list_threatened filters by category", {
  out <- list_threatened("CR")
  expect_gt(nrow(out), 0)
  expect_true(all(out$category == "CR"))

  out2 <- list_threatened(c("EN", "VU"))
  expect_true(all(out2$category %in% c("EN", "VU")))
  expect_equal(nrow(out) + nrow(out2), nrow(list_threatened()))

  expect_error(list_threatened("LC"))
})

test_that("list_threatened filters by state like list_taxa", {
  out <- list_threatened(states = "BA")
  expect_gt(nrow(out), 0)
  occurring <- list_taxa(states = "BA")$taxon
  expect_true(all(out$taxon %in% occurring))
  expected <- intersect(lista_repteis_threat$taxon, occurring)
  expect_setequal(out$taxon, expected)
})

test_that("list_threatened filters by taxon", {
  out <- list_threatened(taxon = "Bothrops")
  expect_gt(nrow(out), 0)
  expect_true(all(grepl("Bothrops", out$taxon, ignore.case = TRUE)))
  expect_true("Bothrops insularis" %in% out$taxon)
})

test_that("list_threatened rejects unknown state codes", {
  expect_error(list_threatened(states = "XX"))
})

test_that("list_threatened keeps the name used in the Portaria", {
  out <- list_threatened(taxon = "Urostrophus undulatus")
  expect_equal(nrow(out), 1)
  expect_equal(out$name_in_source, "Anisolepis undulatus")
})
