box::use(
  datasets[EuStockMarkets],
  dplyr[mutate, as_tibble, relocate],
  purrr[pluck],
  stats[time],
  checkmate[test_string],
  rlang[abort],
  stringr[str_trim],
  config,
)

#' Common date_from to recognize as NULL
#' @export
date_from_null <- "0000-01-01"

#' Common date_to to recognize as NULL
#' @export
date_to_null <- "9999-12-31"

#' @export
data <- as_tibble(EuStockMarkets) |>
  mutate(
    date = time(EuStockMarkets),
    date = lubridate::make_datetime(
      year = floor(date), sec = (date - floor(date)) * 365 * 24 * 60 * 60
    )
  ) |>
  relocate(date, .before = 1)

#' @export
date_column <- "date"

#
setup_secrets <- function(tokens_raw) {
  if (!test_string(tokens_raw, null.ok = TRUE)) {
    abort("SECRET_TOKENS environmental variable must be a string")
  }

  if (is.null(tokens_raw) || str_trim(tokens_raw) == "") {
    return(NULL)
  }

  str_trim(tokens_raw) |>
    strsplit(" ") |>
    pluck(1)
}

#' @export
session_secrets <- setup_secrets(config$get("tokens"))
