test_that("lista_repteis has expected structure", {
  expect_s3_class(lista_repteis, "data.frame")
  expect_true(all(c("family", "genus", "species", "taxon", "endemic_br") %in%
                    names(lista_repteis)))
  expect_true(all(br_state_codes() %in% names(lista_repteis)))
  expect_false(anyNA(lista_repteis$genus))
  expect_false(anyNA(lista_repteis$species))
})

test_that("lista_repteis_flags has expected structure", {
  expect_s3_class(lista_repteis_flags, "data.frame")
  expect_true(all(c("taxon", "family", "state", "status") %in%
                    names(lista_repteis_flags)))
  expect_true(all(lista_repteis_flags$status %in% c("doubtful", "contested")))
  expect_true(all(lista_repteis_flags$state %in% br_state_codes()))
})

test_that("lista_repteis_threat has expected structure", {
  expect_s3_class(lista_repteis_threat, "data.frame")
  expect_named(lista_repteis_threat,
               c("taxon", "family", "category", "new_in_list",
                 "name_in_source", "source"))
  expect_true(all(lista_repteis_threat$category %in%
                    c("CR (PE)", "CR", "EN", "VU")))
  expect_type(lista_repteis_threat$new_in_list, "logical")
  expect_false(anyDuplicated(lista_repteis_threat$taxon) > 0)
})

test_that("every threatened taxon is in lista_repteis, with the same family", {
  idx <- match(lista_repteis_threat$taxon, lista_repteis$taxon)
  expect_false(anyNA(idx))
  expect_equal(lista_repteis_threat$family, lista_repteis$family[idx])
})

test_that("br_states has 27 states with valid geometry", {
  expect_s3_class(br_states, "sf")
  expect_equal(nrow(br_states), 27)
  expect_true(all(sf::st_is_valid(br_states)))
  expect_setequal(br_states$uf, br_state_codes())
})
