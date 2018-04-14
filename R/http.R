#' @title Execute AWS Lambda API Request
#' @description This is the workhorse function to execute calls to the Lambda API.
#' @param verb A character string specifying the HTTP verb to use.
#' @param action A character string specifying the API version and endpoint.
#' @param query An optional named list containing query string parameters and their character values.
#' @param headers A list of headers to pass to the HTTP request.
#' @param body The HTTP request body.
#' @param verbose A logical indicating whether to be verbose. Default is given by \code{options("verbose")}.
#' @param region A character string specifying an AWS region. See \code{\link[aws.signature]{locate_credentials}}.
#' @param key A character string specifying an AWS Access Key. See \code{\link[aws.signature]{locate_credentials}}.
#' @param secret A character string specifying an AWS Secret Key. See \code{\link[aws.signature]{locate_credentials}}.
#' @param session_token Optionally, a character string specifying an AWS temporary Session Token to use in signing a request. See \code{\link[aws.signature]{locate_credentials}}.
#' @param \dots Additional arguments passed to \code{\link[httr]{GET}} or another httr request function.
#' @return If successful, a named list. Otherwise, a data structure of class \dQuote{aws-error} containing any error message(s) from AWS and information about the request attempt.
#' @details This function constructs and signs an AWS Lambda API request and returns the results thereof, or relevant debugging information in the case of error.
#' @author Thomas J. Leeper
#' @seealso \code{\link{get_lambda_account}}, which works well as a hello world for the package
#' @import httr
#' @importFrom utils str
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom aws.signature signature_v4_auth
#' @export
lambdaHTTP <- 
function(
  verb = "GET",
  action,
  query = list(),
  headers = list(),
  body = NULL,
  verbose = getOption("verbose", FALSE),
  region = Sys.getenv("AWS_DEFAULT_REGION", "us-east-1"), 
  key = NULL, 
  secret = NULL, 
  session_token = NULL,
  ...
) {
    # locate and validate credentials
    credentials <- locate_credentials(key = key, secret = secret, session_token = session_token, region = region, verbose = verbose)
    key <- credentials[["key"]]
    secret <- credentials[["secret"]]
    session_token <- credentials[["session_token"]]
    region <- credentials[["region"]]
    
    # generate request signature
    d_timestamp <- format(Sys.time(), "%Y%m%dT%H%M%SZ", tz = "UTC")
    url <- paste0("https://lambda.", region, ".amazonaws.com", action)
    
    if (length(body)) { 
        if (is.list(body)) {
            body <- jsonlite::toJSON(body, auto_unbox = TRUE)
        }
    } else {
        body <- NULL
    }
    
    headers[["host"]] <- paste0("lambda.",region,".amazonaws.com")
    headers[["x-amz-date"]] <- d_timestamp
    Sig <- signature_v4_auth(
           datetime = d_timestamp,
           region = region,
           service = "lambda",
           verb = verb,
           action = action,
           query_args = if (length(query)) query else NULL,
           canonical_headers = if (length(headers)) headers else NULL,
           request_body = if (is.null(body)) "" else body,
           key = key,
           secret = secret,
           session_token = session_token,
           verbose = verbose)
    headers[["x-amz-content-sha256"]] <- Sig$BodyHash
    headers[["Authorization"]] <- Sig[["SignatureHeader"]]
    if (!is.null(session_token) && session_token != "") {
        headers[["x-amz-security-token"]] <- session_token
    }
    H <- do.call("add_headers", headers)
    
    # execute request
    if (verb == "GET") {
        if (length(query)) {
            r <- GET(url, H, query = query, ...)
        } else {
            r <- GET(url, H, ...)
        }
    } else if (verb == "DELETE") {
        if (length(query)) {
            r <- DELETE(url, H, query = query, ...)
        } else {
            r <- DELETE(url, H, ...)
        }
    } else if (verb == "PUT") {
        if (length(query)) {
            if (is.null(body)) {
                r <- PUT(url, H, query = query, ...)
            } else {
                r <- PUT(url, H, query = query, body = body, encode = "json", ...)
            }
        } else {
            if (is.null(body)) {
                r <- PUT(url, H, ...)
            } else {
                r <- PUT(url, H, body = body, encode = "json", ...)
            }
        }
    } else if (verb == "POST") {
        if (length(query)) {
            if (is.null(body)) {
                r <- POST(url, H, query = query, ...)
            } else {
                r <- POST(url, H, query = query, body = body, encode = "json", ...)
            }
        } else {
            if (is.null(body)) {
                r <- POST(url, H, ...)
            } else {
                r <- POST(url, H, body = body, encode = "json", ...)
            }
        }
    } 
    
    if (http_error(r)) {
        h <- headers(r)
        content <- try(content(r, "parsed", encoding = "UTF-8"), silent = TRUE)
        if (!inherits(content, "try-error")) {
            r[["content"]] <- content
        }
        out <- structure(r, headers = h, class = "aws_error")
        attr(out, "request_canonical") <- Sig$CanonicalRequest
        attr(out, "request_string_to_sign") <- Sig$StringToSign
        attr(out, "request_signature") <- Sig$SignatureHeader
        print(out)
        stop_for_status(r)
    }
    content(r, "parsed", encoding = "UTF-8")
}
