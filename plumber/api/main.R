box::use(
  plumber,
  glue[glue],
  logger[log_info, log_debug, log_error],
  promises[future_promise],
  memoise[memoise],
)

box::use(
  api/handler/query[query, ranges, indexes],
  api/handler/render[render],
  api/logic/token[validate_token],
)

query_m <- memoise(query)
render_m <- memoise(render)
ranges_m <- memoise(ranges)
indexes_m <- memoise(indexes)

response_403 <- function(res) {
  res$status <- 403
  res$body <- "<html><body>Forbidden</body></html>"
  res
}

# API Functions ----

#' Example
#' @get /health_check
function(req, res){

  log_info('@get /health_check triggered')

  msg <- glue("Everything is nice and peachy at {Sys.time()}")
  res$status <- 200
  return(list(success = jsonlite::unbox(msg)))

}

## Ranges ---------------------------------------------------------------------

#* Plot the first platform plot
#* @get /ranges
#* @param token String characters with hash of parameters
function(req, res, token = "") {
  log_info('@get /ranges triggered')

  if (isFALSE(validate_token(token = token))) {
    return(response_403(res))
  }

  future_promise(
    ranges_m(),
    globals = FALSE
  )
}

#* Plot the first platform plot
#* @get /indexes
#* @param token String characters with hash of parameters
function(req, res, token = "") {
  log_info('@get /indexes triggered')

  if (isFALSE(validate_token(token = token))) {
    return(response_403(res))
  }

  future_promise(
    indexes_m(),
    globals = FALSE
  )
}

## Query ----------------------------------------------------------------------

#* Plot the first platform plot
#* @get /query
#* @param from (optional) date format (YYYY-MM-DD)
#* @param to (optional) date format (YYYY-MM-DD)
#* @param index (optional) List of indexes delimited by comma `,` (one of `FTSE`, `DAX`, `SMI`,`CAC`). If empty or invalid index it will return all.
#* @param token String characters with hash of parameters
function(req, res, from = "", to = "", index = "", token = "") {
  log_info('@get /query triggered')

  if (isFALSE(validate_token(from, to, index, token = token))) {
    return(response_403(res))
  }

  future_promise(
    query_m(from, to, index),
    globals = FALSE
  )
}

## Render ---------------------------------------------------------------------

#* Plot the first platform plot
#* @get /plot
#* @param from (optional) date format (YYYY-MM-DD)
#* @param to (optional) date format (YYYY-MM-DD)
#* @param index (optional) List of indexes delimited by comma `,` (one of `FTSE`, `DAX`, `SMI`,`CAC`). If empty or invalid index it will return all.
#* @param token String characters with hash of parameters
#* @serializer htmlwidget
function(req, res, from = "", to = "", index = "", token = "") {
  log_info('@get /render triggered')

  if (isFALSE(validate_token(from, to, index, token = token))) {
    return(response_403(res))
  }

  future_promise(
    render_m(from, to, index),
    globals = FALSE
  )
}
