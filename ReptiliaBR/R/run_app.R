#' Launch the ReptiliaBR Shiny app
#'
#' Opens an interactive browser app for exploring the [lista_repteis] checklist:
#' filter/download the checklist, free-text search, draw distribution maps
#' for a single taxon, richness maps, and browse species by state.
#'
#' Requires only the \pkg{shiny} package, which is not required to use the
#' rest of ReptiliaBR and is therefore not installed automatically. Install it
#' with: `install.packages("shiny")`
#'
#' @param ... Additional arguments passed to [shiny::runApp()], e.g.
#'   `launch.browser = TRUE`, `port = 1234`.
#'
#' @return Invisibly, the value returned by [shiny::runApp()]. Called for
#'   its side effect of launching the app.
#'
#' @examples
#' \dontrun{
#' run_app()
#' }
#'
#' @export
run_app <- function(...) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop(
      "The 'shiny' package is required to run the app.\n",
      'Install it with: install.packages("shiny")',
      call. = FALSE
    )
  }

  app_dir <- system.file("shiny-app", package = "ReptiliaBR")
  if (app_dir == "") {
    stop("Could not find the Shiny app directory. Try re-installing ReptiliaBR.",
         call. = FALSE)
  }

  shiny::runApp(app_dir, ...)
}
