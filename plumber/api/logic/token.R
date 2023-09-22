box::use(
  purrr[pluck],
  rlang[hash],
  checkmate[test_string],
  rlang[abort, dots_list],
  config,
  logger[log_info, log_debug]
)

box::use(
  api/logic/setup[session_secrets],
)

#' Get secret from list of session secrets
#'
#' @param id string that identifies a given secret
#'
#' @export
get_secret <- function() {
  pluck(session_secrets, 1)
}

#' @export
#' @examples
#' validate_token(1, 2, 3, token = "12")
validate_token <- function(..., token = "") {
  if (is.null(session_secrets) && !test_string(token, min.chars = 1)) {
    return(TRUE)
  }

  if (is.null(token) || !test_string(token)) {
    return(FALSE)
  }

  args <- dots_list(...)
  if (length(args) == 0) args <- list()
  args$secret <- get_secret()
  log_debug("token sent: {token} vs. expected {hash(args)}")
  return(token == hash(args))
}
