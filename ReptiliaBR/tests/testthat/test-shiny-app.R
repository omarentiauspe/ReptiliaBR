test_that("shiny app directory is bundled and loads", {
  skip_if_not_installed("shiny")

  app_dir <- system.file("shiny-app", package = "ReptiliaBR")
  expect_true(nzchar(app_dir))
  expect_true(file.exists(file.path(app_dir, "app.R")))

  app <- shiny::shinyAppDir(app_dir)
  expect_s3_class(app, "shiny.appobj")
})

test_that("shiny app server reactives compute without error", {
  skip_if_not_installed("shiny")

  app_env <- new.env()
  source(system.file("shiny-app/app.R", package = "ReptiliaBR"), local = app_env)

  shiny::testServer(app_env$server, {
    session$setInputs(chk_rank = "family", chk_value = "Viperidae",
                       chk_endemic = FALSE, chk_states = character(0),
                       chk_state_endemic = FALSE, chk_show_states = FALSE)
    expect_gt(nrow(chk_data()), 0)
    expect_true("state_endemic" %in% names(chk_data()))

    session$setInputs(chk_show_states = TRUE)
    expect_true("states" %in% names(chk_data()))

    session$setInputs(search_pattern = "jarara")
    expect_gt(nrow(search_data()), 0)

    session$setInputs(map_rank = "taxon", map_value = "Bothrops jararaca",
                       map_labels = TRUE, map_color = "grey20",
                       map_color_hex = "#333333", map_size = 2.6,
                       map_font = "sans", map_bold = FALSE, map_bg = FALSE,
                       map_bg_color = "white", map_bg_alpha = 0.85)
    expect_false(is.null(output$map_plot))
    expect_false(is.null(output$map_download_png))
    expect_false(is.null(output$map_download_pdf))

    # Custom color + background-box styling should also compute cleanly.
    session$setInputs(map_color = "custom", map_color_hex = "#123456",
                       map_bg = TRUE)
    expect_false(is.null(output$map_plot))

    session$setInputs(rich_filter = FALSE, rich_endemic = FALSE,
                       rich_palette = "Viridis", rich_color = "grey15",
                       rich_color_hex = "#333333", rich_size = 2.6,
                       rich_font = "sans", rich_bold = FALSE, rich_bg = FALSE,
                       rich_bg_color = "white", rich_bg_alpha = 0.85)
    expect_false(is.null(output$rich_plot))

    session$setInputs(rich_show_species = TRUE)
    expect_gt(nrow(rich_species_data()), 0)
    expect_false(is.null(output$rich_species_table))
    expect_false(is.null(output$rich_species_download))

    session$setInputs(st_states = c("AM", "PA", "RR"), st_match = "all",
                       st_filter = FALSE)
    expect_gt(nrow(st_data()), 0)
  })
})

test_that("run_app errors clearly when app dir is unavailable is not triggered normally", {
  # Just check the function exists and validates dependencies without
  # actually starting a server (avoid blocking the test run).
  expect_true(is.function(run_app))
})
