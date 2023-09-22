
library(httr2)
library(shiny)
library(rlang)

uri_base <- config::get("uri")$base

ui <- function(id) {
  ns <- NS(id)

  bootstrapPage(
    div(
      style = "max-width: 900px; margin: auto",
      h2("The plot and ranges are obtained from Plumber!"),
      sliderInput(
        ns("range"),
        "Date",
        min = 1990,
        max = 2000,
        value = c(1990, 2000)
      ),
      uiOutput(ns("refresh")),
      shinyWidgets::checkboxGroupButtons(
        ns("index"),
        label = "Select one (or more) indexes:",
        choices = c("")
      ),
      tags$div(
        style = "width: 100%",
        uiOutput(ns("iframe"))
      )
    )
  )
}

retrieve_metadata <- function() {
  ranges <- tryCatch({
    request(uri_base) %>%
      req_url_path(paste0(config::get("uri")$prefix, config::get("uri")$ranges)) |>
      httr2::req_headers(
        "Authorization" = glue::glue("Key {config::get('authorization')}")
      ) |>
      req_perform() |>
      httr2::resp_body_json() |>
      purrr::pluck("result") |>
      unlist() |>
      lubridate::as_date() |>
      rlang::set_names(c("min", "max"))
  },
  error = function(err) NULL
  )


  indexes <- tryCatch({
    request(uri_base) %>%
      req_url_path(paste0(config::get("uri")$prefix, config::get("uri")$indexes)) |>
      httr2::req_headers(
        "Authorization" = glue::glue("Key {config::get('authorization')}")
      ) |>
      req_perform() |>
      httr2::resp_body_json() |>
      purrr::pluck("result") |>
      unlist() |>
      sort()
  },
  error = function(err) NULL
  )

  list(ranges = ranges, indexes = indexes)
}

server <- function(id) {
  moduleServer(id, function(input, output, session) {

    metadata <- retrieve_metadata()
    ranges <- reactiveVal(metadata$ranges)
    indexes <- reactiveVal(metadata$indexes)

    observe({
      updateSliderInput(
        session = session,
        "range",
        min = purrr::pluck(ranges(), "min") - 1,
        max = purrr::pluck(ranges(), "max") + 1,
        value = c(
          purrr::pluck(ranges(), "min"),
          purrr::pluck(ranges(), "max")
        )
      )

      shinyWidgets::updateCheckboxGroupButtons(
        session = session,
        "index",
        choices = indexes(),
        label = "Select one (or more) indexes:"
      )
    })

    query <- reactive({
      validate(
        need(!is.null(ranges()) || !is.null(ranges()), "Plumber API is down. Shiny needs to restart.")
      )

      list(
        from = as.character(as.Date(purrr::pluck(input$range, 1))),
        to = as.character(as.Date(purrr::pluck(input$range, 2))),
        index = paste(input$index, collapse = ",")
      )
    })

    observe({
      metadata <- retrieve_metadata()
      ranges(metadata$ranges)
      indexes(metadata$indexes)
    }) |>
      bindEvent(input$refresh_button)


    output$refresh <- renderUI({
      if (is.null(ranges()) || is.null(ranges())) {
        actionButton(session$ns("refresh_button"), "Try API again")
      } else {
        NULL
      }
    })

    output$iframe <- renderUI({
      uri_base_iframe <- paste0(uri_base, config::get("uri")$prefix)
      uri_query <- paste(names(query()), query(), sep = "=", collapse = "&")

      uri <- glue::glue(uri_base_iframe, config::get("uri")$plot, "?", uri_query)
      tagList(
        tags$iframe(
          style = "width: 100%; height: 400px; border: none",
          src = uri
        ),
        tags$div(
          tags$h4("Links to data & plot:"),
          tags$ul(
            tags$li(
              "Plot outside this dashboard:",
              tags$a(href = uri, target = "_blank", uri)
            ),
            tags$li(
              "Ranges outside this dashboard:",
              tags$a(href = file.path(uri_base_iframe, "ranges"), target = "_blank", uri)
            ),
            tags$li(
              "Indexes outside this dashboard:",
              tags$a(href = file.path(uri_base_iframe, "indexes"), target = "_blank", uri)
            ),
            tags$li(
              tags$a(href = file.path(uri_base_iframe, "__docs__/"), target = "_blank", "Plumber documentation")
            )
          ),
          tags$pre(
            tags$span("# Explanation of link structure:"),
            tags$span(
              glue::glue("`{uri_base_iframe}`: link to plumber instance")
            ),
            tags$span(
              "`/plot`: plumber endpoint"
            ),
            tags$span(
              glue::glue("`{uri_query}`: query parameters")
            )
          )
        )
      )
    })
  })
}

shiny::shinyApp(
  ui = ui("example"),
  server = function(input, output, session) server("example")
)
