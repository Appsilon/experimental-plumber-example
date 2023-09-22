box::use(
  echarts4r[e_charts, e_line, e_tooltip],
  dplyr[group_by],
  tidyr[gather],
)

box::use(
  api/handler/query[query],
)

#' Handler to read data from data storage provider
#'
#' @param from string with starting date that can be converted to a Date class
#' @param to string with ending date that can be converted to a Date class
#' @param index string with starting date that can be converted to a Date class
#' @export
#' @examples
#' render("1993-01-01", "", "FTSE")
render <- function(from, to, index) {
  data <- query(from, to, index)$result |>
    gather("index", "value", -date)

  data |>
    group_by(index) |>
    e_charts(date) |>
    e_line(value) |>
    e_tooltip()
}
