## ReptiliaBR Shiny app (base shiny only -- no DT, no bslib) ------------------
## Launch with ReptiliaBR::run_app()

library(shiny)
library(ggplot2)
library(ReptiliaBR)

rank_choices <- c(
  "Order"       = "order",
  "Suborder"    = "suborder",
  "Clade"       = "clade",
  "Superfamily" = "superfamily",
  "Family"      = "family",
  "Subfamily"   = "subfamily",
  "Tribe"       = "tribe",
  "Genus"       = "genus",
  "Species (epithet)" = "species",
  "Taxon (full name)" = "taxon"
)

## Richness map tab: same ranks, minus "species" and "taxon" (a richness
## count only makes sense above the single-taxon level).
richness_rank_choices <- rank_choices[!rank_choices %in% c("species", "taxon")]

## Taxon Map tab: same ranks, minus "species" (epithet) -- searching the
## taxon map by species epithet alone is excluded here.
taxon_map_rank_choices <- rank_choices[!rank_choices %in% c("species")]

state_choices <- ReptiliaBR:::br_state_codes()

## Named list of selectable continuous fill palettes for the richness map.
## Kept as simple two/three-color gradients so no extra packages (e.g.
## viridisLite/scales) are required beyond what ggplot2 already provides.
palette_choices <- list(
  "Green"       = ggplot2::scale_fill_gradient(low = "#F7FCB9", high = "#31A354"),
  "Blue"        = ggplot2::scale_fill_gradient(low = "#EFF3FF", high = "#08519C"),
  "Orange-Red"  = ggplot2::scale_fill_gradient(low = "#FEE8C8", high = "#B30000"),
  "Purple"      = ggplot2::scale_fill_gradient(low = "#F2F0F7", high = "#54278F"),
  "Viridis"     = ggplot2::scale_fill_viridis_c()
)

value_choices_for <- function(rank) {
  vals <- unique(lista_repteis[[rank]])
  vals <- sort(vals[!is.na(vals)])
  vals
}

## Wraps a tableOutput in a fixed-height scrollable box, since base shiny
## tables (unlike DT) have no built-in pagination.
scroll_table <- function(id, height = "550px") {
  div(style = sprintf("max-height:%s; overflow-y:auto;", height),
      tableOutput(id))
}

## -- Map text styling (Taxon Map / Richness map) ---------------------
## Kept to base shiny inputs (no colourpicker/shinyWidgets dependency):
## a preset color list with a "Custom" hex fallback, and font families
## restricted to "sans"/"serif"/"mono" since those are the only ones
## guaranteed to render without extra font packages.
text_color_choices <- c(
  "Dark grey" = "grey20",
  "Black"     = "black",
  "White"     = "white",
  "Dark green"= "#1B4D3E",
  "Dark blue" = "#0B3D91",
  "Dark red"  = "#7A1F1F",
  "Custom (hex below)" = "custom"
)

text_font_choices <- c(
  "Sans-serif" = "sans",
  "Serif"      = "serif",
  "Monospace"  = "mono"
)

## Builds the "text color / size / font / background" controls shared by
## the Taxon Map and Richness map sidebars. `id` is the input-id prefix,
## e.g. id = "map" creates input$map_color, input$map_size, etc.
label_style_ui <- function(id, default_size = 2.6) {
  tagList(
    tags$hr(),
    tags$strong("Map text style"),
    helpText("Controls the labels drawn on top of the map",
             "(state codes / richness counts)."),
    selectInput(paste0(id, "_color"), "Text color",
                choices = text_color_choices, selected = "grey20"),
    conditionalPanel(
      sprintf("input.%s_color == 'custom'", id),
      textInput(paste0(id, "_color_hex"), "Custom color (hex)",
                value = "#333333", placeholder = "#RRGGBB")
    ),
    sliderInput(paste0(id, "_size"), "Text size", min = 1.5, max = 6,
                value = default_size, step = 0.1),
    selectInput(paste0(id, "_font"), "Font", choices = text_font_choices,
                selected = "sans"),
    checkboxInput(paste0(id, "_bold"), "Bold text", FALSE),
    checkboxInput(paste0(id, "_bg"),
                  "Add background behind text (improves readability)",
                  FALSE),
    conditionalPanel(
      sprintf("input.%s_bg == true", id),
      selectInput(paste0(id, "_bg_color"), "Background color",
                  choices = c("White" = "white", "Black" = "black",
                              "Light grey" = "grey90"),
                  selected = "white"),
      sliderInput(paste0(id, "_bg_alpha"), "Background opacity",
                  min = 0.2, max = 1, value = 0.85, step = 0.05)
    )
  )
}

## Resolves an id's label_style_ui() inputs into the label_* argument list
## expected by map_taxon()/map_richness().
resolve_label_style <- function(input, id) {
  color <- input[[paste0(id, "_color")]]
  if (identical(color, "custom")) {
    hex <- input[[paste0(id, "_color_hex")]]
    color <- if (grepl("^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$", hex)) hex else "#333333"
  }
  list(
    label_color = color,
    label_size = input[[paste0(id, "_size")]],
    label_family = input[[paste0(id, "_font")]],
    label_fontface = if (isTRUE(input[[paste0(id, "_bold")]])) "bold" else "plain",
    label_background = isTRUE(input[[paste0(id, "_bg")]]),
    label_bg_color = input[[paste0(id, "_bg_color")]] %||% "white",
    label_bg_alpha = input[[paste0(id, "_bg_alpha")]] %||% 0.85
  )
}

`%||%` <- function(a, b) if (is.null(a)) b else a

# ---------------------------------------------------------------------- UI
ui <- navbarPage(
  title = "ReptiliaBR \u2014 Brazilian Reptile Checklist",

  ## -- Tab 1: Checklist explorer ------------------------------------
  tabPanel(
    "Checklist",
    sidebarLayout(
      sidebarPanel(
        width = 3,
        selectInput("chk_rank", "Filter by rank", choices = rank_choices,
                    selected = "family"),
        selectInput("chk_value", "Value(s)", choices = NULL, multiple = TRUE),
        checkboxInput("chk_endemic", "Endemic to Brazil only", FALSE),
        checkboxInput("chk_state_endemic", "State endemic only", FALSE),
        helpText("\"State endemic\" = endemic to Brazil AND recorded in",
                 "only one Brazilian state."),
        selectInput("chk_states", "Occurs in state(s)", choices = state_choices,
                    multiple = TRUE),
        checkboxInput("chk_show_states", "Show geographic distribution", FALSE),
        downloadButton("chk_download", "Download CSV")
      ),
      mainPanel(
        width = 9,
        textOutput("chk_count"),
        br(),
        scroll_table("chk_table")
      )
    )
  ),

  ## -- Tab 2: Search -------------------------------------------------
  tabPanel(
    "Search",
    sidebarLayout(
      sidebarPanel(
        width = 3,
        textInput("search_pattern", "Search taxon names",
                  placeholder = "e.g. jarara, ^Bothrops, micrurus"),
        helpText("Case-insensitive. Matches any taxonomic name column",
                 "(suborder through full species/subspecies name).",
                 "Supports regular expressions."),
        downloadButton("search_download", "Download CSV")
      ),
      mainPanel(
        width = 9,
        textOutput("search_count"),
        br(),
        scroll_table("search_table")
      )
    )
  ),

  ## -- Tab 3: Distribution map for a taxon ----------------------------
  tabPanel(
    "Taxon Map",
    sidebarLayout(
      sidebarPanel(
        width = 3,
        selectInput("map_rank", "Rank", choices = taxon_map_rank_choices,
                    selected = "taxon"),
        selectInput("map_value", "Value", choices = NULL),
        checkboxInput("map_labels", "Show state labels", TRUE),
        helpText("States with a \"?\" (doubtful) or \"!\" (contested)",
                 "occurrence record are shown in their own colors on",
                 "the map instead of being folded into \"No record\"."),
        downloadButton("map_download", "Download CSV"),
        br(), br(),
        downloadButton("map_download_png", "Download PNG"),
        downloadButton("map_download_pdf", "Download PDF"),
        label_style_ui("map")
      ),
      mainPanel(
        width = 9,
        plotOutput("map_plot", height = "600px"),
        h5("Occurrence status by state:"),
        scroll_table("map_status_table", height = "260px")
      )
    )
  ),

  ## -- Tab 4: Richness map --------------------------------------------
  tabPanel(
    "Richness map",
    sidebarLayout(
      sidebarPanel(
        width = 3,
        checkboxInput("rich_filter", "Restrict to a taxon", FALSE),
        conditionalPanel(
          "input.rich_filter == true",
          selectInput("rich_rank", "Rank", choices = richness_rank_choices,
                      selected = "family"),
          selectInput("rich_value", "Value", choices = NULL)
        ),
        checkboxInput("rich_endemic", "Endemic to Brazil only", FALSE),
        selectInput("rich_palette", "Color palette",
                    choices = names(palette_choices), selected = "Green"),
        downloadButton("rich_download_png", "Download PNG"),
        downloadButton("rich_download_pdf", "Download PDF"),
        label_style_ui("rich"),
        tags$hr(),
        tags$strong("Species included"),
        checkboxInput("rich_show_species",
                      "Show / export the species behind this map", FALSE),
        conditionalPanel(
          "input.rich_show_species == true",
          downloadButton("rich_species_download", "Download species (CSV)")
        )
      ),
      mainPanel(
        width = 9,
        plotOutput("rich_plot", height = "600px"),
        conditionalPanel(
          "input.rich_show_species == true",
          br(),
          textOutput("rich_species_count"),
          br(),
          scroll_table("rich_species_table", height = "300px")
        )
      )
    )
  ),

  ## -- Tab 5: By state -------------------------------------------------
  tabPanel(
    "By state",
    sidebarLayout(
      sidebarPanel(
        width = 3,
        selectInput("st_states", "State(s)", choices = state_choices,
                    multiple = TRUE, selected = "SP"),
        radioButtons("st_match", "Match", choices = c("Any of these" = "any",
                                                        "All of these" = "all")),
        checkboxInput("st_filter", "Restrict to a taxon", FALSE),
        conditionalPanel(
          "input.st_filter == true",
          selectInput("st_rank", "Rank", choices = rank_choices,
                      selected = "family"),
          selectInput("st_value", "Value", choices = NULL)
        ),
        downloadButton("st_download", "Download CSV")
      ),
      mainPanel(
        width = 9,
        textOutput("st_count"),
        br(),
        scroll_table("st_table")
      )
    )
  )
)

# ------------------------------------------------------------------ Server
server <- function(input, output, session) {

  ## Tab 1: Checklist ---------------------------------------------------
  observeEvent(input$chk_rank, {
    updateSelectInput(session, "chk_value",
                       choices = value_choices_for(input$chk_rank))
  }, ignoreInit = FALSE)

  chk_data <- reactive({
    list_taxa(
      rank = input$chk_rank,
      value = if (length(input$chk_value)) input$chk_value else NULL,
      endemic_only = input$chk_endemic,
      states = if (length(input$chk_states)) input$chk_states else NULL,
      state_endemic_only = input$chk_state_endemic,
      include_states = input$chk_show_states
    )
  })

  output$chk_count <- renderText({
    sprintf("%d taxa match the current filters.", nrow(chk_data()))
  })

  output$chk_table <- renderTable(chk_data(), striped = TRUE, spacing = "xs")

  output$chk_download <- downloadHandler(
    filename = function() "ReptiliaBR_checklist.csv",
    content = function(file) write.csv(chk_data(), file, row.names = FALSE)
  )

  ## Tab 2: Search --------------------------------------------------------
  search_data <- reactive({
    req(nchar(input$search_pattern) > 0)
    tryCatch(search_species(input$search_pattern),
             error = function(e) lista_repteis[0, ])
  })

  output$search_count <- renderText({
    if (nchar(input$search_pattern) == 0) {
      "Type a pattern to search."
    } else {
      sprintf("%d taxa match \"%s\".", nrow(search_data()), input$search_pattern)
    }
  })

  output$search_table <- renderTable({
    req(nchar(input$search_pattern) > 0)
    search_data()
  }, striped = TRUE, spacing = "xs")

  output$search_download <- downloadHandler(
    filename = function() "ReptiliaBR_search.csv",
    content = function(file) {
      req(nchar(input$search_pattern) > 0)
      write.csv(search_data(), file, row.names = FALSE)
    }
  )

  ## Tab 3: Taxon map -----------------------------------------------
  observeEvent(input$map_rank, {
    updateSelectInput(session, "map_value",
                       choices = value_choices_for(input$map_rank))
  }, ignoreInit = FALSE)

  map_plot_obj <- reactive({
    req(input$map_value)
    style <- resolve_label_style(input, "map")
    do.call(map_taxon, c(
      list(rank = input$map_rank, value = input$map_value,
           show_labels = input$map_labels),
      style
    ))
  })

  output$map_plot <- renderPlot({
    map_plot_obj()
  })

  output$map_download_png <- downloadHandler(
    filename = function() "ReptiliaBR_taxon_map.png",
    content = function(file) {
      ggsave(file, plot = map_plot_obj(), width = 10, height = 8,
             dpi = 300, bg = "white")
    }
  )

  output$map_download_pdf <- downloadHandler(
    filename = function() "ReptiliaBR_taxon_map.pdf",
    content = function(file) {
      ggsave(file, plot = map_plot_obj(), width = 10, height = 8,
             device = "pdf")
    }
  )

  ## Per-state occurrence status (present / contested "!" / doubtful "?" /
  ## no record) for the taxon currently mapped -- backs both the on-screen
  ## table and the CSV download.
  map_status_data <- reactive({
    req(input$map_value)
    occ_states <- states_by_taxon(input$map_rank, input$map_value)
    flags <- ReptiliaBR:::flagged_states_by_taxon(input$map_rank, input$map_value)
    contested_states <- unique(flags$state[flags$status == "contested"])
    doubtful_states <- unique(flags$state[flags$status == "doubtful"])

    df <- as.data.frame(ReptiliaBR::br_states)[, c("uf", "name", "region")]
    df$status <- "No record"
    df$status[df$uf %in% doubtful_states] <- "Doubtful (?)"
    df$status[df$uf %in% contested_states] <- "Contested (!)"
    df$status[df$uf %in% occ_states] <- "Present"
    df[order(df$region, df$uf), ]
  })

  output$map_status_table <- renderTable(map_status_data(), striped = TRUE,
                                          spacing = "xs")

  output$map_download <- downloadHandler(
    filename = function() "ReptiliaBR_taxon_map.csv",
    content = function(file) write.csv(map_status_data(), file, row.names = FALSE)
  )

  ## Tab 4: Richness map ------------------------------------------------
  observeEvent(input$rich_rank, {
    updateSelectInput(session, "rich_value",
                       choices = value_choices_for(input$rich_rank))
  }, ignoreInit = FALSE)

  rich_plot_obj <- reactive({
    pal <- palette_choices[[input$rich_palette]]
    style <- resolve_label_style(input, "rich")
    base_args <- if (isTRUE(input$rich_filter)) {
      req(input$rich_value)
      list(rank = input$rich_rank, value = input$rich_value,
           endemic_only = input$rich_endemic, palette = pal)
    } else {
      list(endemic_only = input$rich_endemic, palette = pal)
    }
    do.call(map_richness, c(base_args, style))
  })

  output$rich_plot <- renderPlot({
    rich_plot_obj()
  })

  output$rich_download_png <- downloadHandler(
    filename = function() "ReptiliaBR_richness_map.png",
    content = function(file) {
      ggsave(file, plot = rich_plot_obj(), width = 10, height = 8,
             dpi = 300, bg = "white")
    }
  )

  output$rich_download_pdf <- downloadHandler(
    filename = function() "ReptiliaBR_richness_map.pdf",
    content = function(file) {
      ggsave(file, plot = rich_plot_obj(), width = 10, height = 8,
             device = "pdf")
    }
  )

  ## Species underlying the currently displayed richness map -- same
  ## rank/value/endemic_only filters as rich_plot_obj(), exposed as a
  ## viewable/downloadable table.
  rich_species_data <- reactive({
    if (isTRUE(input$rich_filter)) {
      req(input$rich_value)
      list_richness_species(rank = input$rich_rank, value = input$rich_value,
                            endemic_only = input$rich_endemic)
    } else {
      list_richness_species(endemic_only = input$rich_endemic)
    }
  })

  output$rich_species_count <- renderText({
    req(input$rich_show_species)
    sprintf("%d species are counted in this richness map.",
            nrow(rich_species_data()))
  })

  output$rich_species_table <- renderTable({
    req(input$rich_show_species)
    rich_species_data()
  }, striped = TRUE, spacing = "xs")

  output$rich_species_download <- downloadHandler(
    filename = function() "ReptiliaBR_richness_species.csv",
    content = function(file) {
      write.csv(rich_species_data(), file, row.names = FALSE)
    }
  )

  ## Tab 5: By state -----------------------------------------------------
  observeEvent(input$st_rank, {
    updateSelectInput(session, "st_value",
                       choices = value_choices_for(input$st_rank))
  }, ignoreInit = FALSE)

  st_data <- reactive({
    req(length(input$st_states) > 0)
    if (isTRUE(input$st_filter)) {
      req(input$st_value)
      list_by_state(input$st_states, match = input$st_match,
                    rank = input$st_rank, value = input$st_value)
    } else {
      list_by_state(input$st_states, match = input$st_match)
    }
  })

  output$st_count <- renderText({
    sprintf("%d taxa match.", nrow(st_data()))
  })

  output$st_table <- renderTable(st_data(), striped = TRUE, spacing = "xs")

  output$st_download <- downloadHandler(
    filename = function() "ReptiliaBR_by_state.csv",
    content = function(file) write.csv(st_data(), file, row.names = FALSE)
  )
}

shinyApp(ui, server)
