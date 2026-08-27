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

test_that("br_states has 27 states with valid geometry", {
  expect_s3_class(br_states, "sf")
  expect_equal(nrow(br_states), 27)
  expect_true(all(sf::st_is_valid(br_states)))
  expect_setequal(br_states$uf, br_state_codes())
})
