#' @title Execute AWS Lambda API Request
#' @description This is the workhorse function to execute calls to the Lambda
#'   API.
#' @param verb A character string specifying the HTTP verb to use.
#' @param action A character string specifying the API version and endpoint.
#' @param query An optional named list containing query string parameters and
#'   their character values.
#' @param headers A list of headers to pass to the HTTP request.
#' @param body The HTTP request body.
#' @param verbose A logical indicating whether to be verbose. Default is given
#'   by \code{options("verbose")}.
#' @param region A character string specifying an AWS region. See
#'   \code{\link[aws.signature]{locate_credentials}}.
#' @param key A character string specifying an AWS Access Key. See
#'   \code{\link[aws.signature]{locate_credentials}}.
#' @param secret A character string specifying an AWS Secret Key. See
#'   \code{\link[aws.signature]{locate_credentials}}.
#' @param session_token Optionally, a character string specifying an AWS
#'   temporary Session Token to use in signing a request. See
#'   \code{\link[aws.signature]{locate_credentials}}.
#' @param \dots Additional arguments passed to \code{\link[httr]{GET}} or
#'   another httr request function.
#' @return If successful, a named list. Otherwise, a data structure of class
#'   \dQuote{aws-error} containing any error message(s) from AWS and information
#'   about the request attempt.
#' @details This function constructs and signs an AWS Lambda API request and
#'   returns the results thereof, or relevant debugging information in the case
#'   of error.
#' @author Thomas J. Leeper
#' @seealso \code{\link{get_lambda_account}}, which works well as a hello world
#'   for the package
#' @importFrom httr GET DELETE PUT POST add_headers http_error headers
#'   stop_for_status content
#' @importFrom aws.signature locate_credentials signature_v4_auth
#' @importFrom jsonlite toJSON
#' @export
lambdaHTTP <- function(verb = "GET",
                       action,
                       query = NULL,
                       headers = list(),
                       body = NULL,
                       verbose = getOption("verbose", FALSE),
                       region = Sys.getenv("AWS_DEFAULT_REGION", "us-east-1"),
                       key = NULL,
                       secret = NULL,
                       session_token = NULL,
                       ...) {
  if (length(body)) {
    if (is.list(body)) {
      body <- jsonlite::toJSON(body, auto_unbox = TRUE)
    }
  } else {
    body <- NULL
  }
  query <- if (length(query)) query else NULL

  # Set things up for aws.signature.
  headers[["host"]] <- paste0("lambda.", region, ".amazonaws.com")
  headers[["x-amz-date"]] <- format(Sys.time(), "%Y%m%dT%H%M%SZ", tz = "UTC")

  # generate request signature
  Sig <- aws.signature::signature_v4_auth(
    datetime = headers[["x-amz-date"]],
    region = region,
    service = "lambda",
    verb = verb,
    action = action,
    query_args = query,
    canonical_headers = headers,
    request_body = body %||% "",
    key = key,
    secret = secret,
    session_token = session_token,
    verbose = verbose
  )
  headers[["x-amz-content-sha256"]] <- Sig$BodyHash
  headers[["Authorization"]] <- Sig[["SignatureHeader"]]
  if (!is.null(session_token) && session_token != "") {
    headers[["x-amz-security-token"]] <- session_token
  }

  r <- httr::VERB(
    verb = verb,
    url = paste0("https://", headers[["host"]], action),
    config = do.call(httr::add_headers, headers),
    body = body,
    encode = if (is.null(body)) NULL else "json",
    query = query,
    ...
  )

  if (httr::http_error(r)) {
    h <- httr::headers(r)
    content <- try(
      httr::content(r, "parsed", encoding = "UTF-8"),
      silent = TRUE
    )
    if (!inherits(content, "try-error")) {
      r[["content"]] <- content
    }
    out <- structure(r, headers = h, class = "aws_error")
    attr(out, "request_canonical") <- Sig$CanonicalRequest
    attr(out, "request_string_to_sign") <- Sig$StringToSign
    attr(out, "request_signature") <- Sig$SignatureHeader
    print(out)
    httr::stop_for_status(r)
  }

  return(
    httr::content(r, "parsed", encoding = "UTF-8")
  )
}
