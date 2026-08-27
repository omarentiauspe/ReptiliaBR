test_that("list_taxa filters by rank/value", {
  out <- list_taxa("family", "Viperidae")
  expect_true(all(out$family == "Viperidae"))
  expect_gt(nrow(out), 0)
})

test_that("list_taxa with no filters returns everything", {
  out <- list_taxa()
  expect_equal(nrow(out), nrow(lista_repteis))
})

test_that("list_taxa endemic_only restricts correctly", {
  out <- list_taxa("genus", "Bothrops", endemic_only = TRUE)
  expect_true(all(out$endemic_br))
})

test_that("list_taxa states filter restricts to occurring taxa", {
  out <- list_taxa("family", "Dipsadidae", states = c("SP", "RJ"))
  manual <- list_by_state(c("SP", "RJ"), rank = "family", value = "Dipsadidae")
  expect_equal(sort(out$taxon), sort(manual$taxon))
})

test_that("list_taxa rejects invalid rank", {
  expect_error(list_taxa("nonsense", "x"))
})

test_that("list_taxa always reports a state_endemic column", {
  out <- list_taxa()
  expect_true("state_endemic" %in% names(out))
  expect_type(out$state_endemic, "logical")
})

test_that("list_taxa state_endemic_only restricts to single-state endemics", {
  out <- list_taxa(state_endemic_only = TRUE)
  expect_true(all(out$state_endemic))
  expect_true(all(out$endemic_br))

  # Cross-check against the underlying occurrence matrix directly.
  states <- br_state_codes()
  occ <- as.matrix(lista_repteis[states])
  occ[is.na(occ)] <- FALSE
  n_states <- rowSums(occ)
  expected <- lista_repteis$taxon[lista_repteis$endemic_br %in% TRUE & n_states == 1]
  expect_setequal(out$taxon, expected)
})

test_that("list_taxa include_states adds a states summary column", {
  out <- list_taxa("family", "Viperidae", include_states = TRUE)
  expect_true("states" %in% names(out))
  expect_true(is.character(out$states))
})

test_that("list_by_state match any/all behave as expected", {
  any_res <- list_by_state(c("AM", "PA"), match = "any")
  all_res <- list_by_state(c("AM", "PA"), match = "all")
  expect_true(nrow(all_res) <= nrow(any_res))
})

test_that("list_by_state rejects invalid state codes", {
  expect_error(list_by_state("XX"))
})

test_that("states_by_taxon returns valid UF codes", {
  st <- states_by_taxon("taxon", "Bothrops jararaca")
  expect_true(all(st %in% br_state_codes()))
  expect_true(length(st) > 0)
})

test_that("search_species finds partial matches case-insensitively", {
  out <- search_species("jarara")
  expect_true(all(grepl("jarara", out$taxon, ignore.case = TRUE)))
  expect_gt(nrow(out), 0)
})
