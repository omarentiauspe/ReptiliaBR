test_that("list_flagged filters by status", {
  out <- list_flagged("contested")
  expect_true(all(out$status == "contested"))

  out2 <- list_flagged("doubtful")
  expect_true(all(out2$status == "doubtful"))

  out_both <- list_flagged()
  expect_equal(nrow(out_both), nrow(out) + nrow(out2))
})

test_that("list_flagged filters by state and taxon", {
  out <- list_flagged(states = "RJ")
  expect_true(all(out$state == "RJ"))

  out2 <- list_flagged(taxon = "Bothrops")
  expect_true(all(grepl("Bothrops", out2$taxon, ignore.case = TRUE)))
})

test_that("list_flagged rejects unknown state codes", {
  expect_error(list_flagged(states = "XX"))
})
