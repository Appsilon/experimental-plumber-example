box::use(
  dplyr[filter, all_of, select],
  checkmate[test_posixct, test_string],
  purrr[pluck],
  stringr[str_split, str_trim],
)

box::use(
  api/logic/setup[date_from_null, date_to_null, data, date_column]
)

#' Handler to read data from data storage provider
#'
#' @param from string with starting date that can be converted to a Date class
#' @param to string with ending date that can be converted to a Date class
#' @param index string with starting date that can be converted to a Date class
#' @export
#' @examples
#' ranges()
indexes <- function() {
  result <- names(data)

  list(
    status = 200,
    result = result[!result %in% date_column]
  )
}


#' Handler to read data from data storage provider
#'
#' @param from string with starting date that can be converted to a Date class
#' @param to string with ending date that can be converted to a Date class
#' @param index string with starting date that can be converted to a Date class
#' @export
#' @examples
#' ranges()
ranges <- function() {
  list(
    status = 200,
    result = c(min(data$date), max(data$date))
  )
}

#' Handler to read data from data storage provider
#'
#' @param from string with starting date that can be converted to a Date class
#' @param to string with ending date that can be converted to a Date class
#' @param index string with starting date that can be converted to a Date class
#' @export
#' @examples
#' query("1993-01-01", "", "FTSE")
query <- function(from, to, index) {
  from <- as.Date(from)
  to <- as.Date(to)

  if (identical(from, date_from_null)) {
    from <- NULL
  }
  if (identical(to, date_to_null)) {
    to <- NULL
  }

  result <- data
  result_warnings <- c()

  if (test_posixct(from)) result <- filter(result, date >= from)
  if (test_posixct(to)) result <- filter(result, date <= to)

  if (test_string(index, min.chars = 1)) {
    index <- str_split(index, ",") |>
      pluck(1) |>
      str_trim()

    index <- index[index %in% colnames(data)]

    if (length(index) > 0) {
      result <- select(result, all_of(c(date_column, index)))
    } else {
      result_warnings <- c(result_warnings, "Symbol is ")
    }
  }

  list(
    status = 200,
    warnings = result_warnings,
    result = result
  )
}
