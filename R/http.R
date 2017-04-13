#' @title Execute AWS Lambda API Request
#' @description This is the workhorse function to execute calls to the Lambda API.
#' @param verb A character string specifying the HTTP verb to use.
#' @param action A character string specifying the API version and endpoint.
#' @param body The HTTP request body.
#' @param query An optional named list containing query string parameters and their character values.
#' @param headers An optional list of HTTP request headers.
#' @param region A character string containing an AWS region. If missing, the default \dQuote{us-east-1} is used.
#' @param key A character string containing an AWS Access Key ID. The default is pulled from environment variable \dQuote{AWS_ACCESS_KEY_ID}.
#' @param secret A character string containing an AWS Secret Access Key. The default is pulled from environment variable \dQuote{AWS_SECRET_ACCESS_KEY}.
#' @param session_token Optionally, a character string containing an AWS temporary Session Token. If missing, defaults to value stored in environment variable \dQuote{AWS_SESSION_TOKEN}.
#' @param \dots Additional arguments passed to \code{\link[httr]{GET}} or another httr request function.
#' @return If successful, a named list. Otherwise, a data structure of class \dQuote{aws-error} containing any error message(s) from AWS and information about the request attempt.
#' @details This function constructs and signs an AWS Lambda API request and returns the results thereof, or relevant debugging information in the case of error.
#' @author Thomas J. Leeper
#' @seealso \code{\link{get_account}}, which works well as a hello world for the package
#' @import httr
#' @importFrom utils str
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom aws.signature signature_v4_auth
#' @export
lambdaHTTP <- function(verb = "GET", action, body = NULL, query = list(), headers = list(), 
                       region = Sys.getenv("AWS_DEFAULT_REGION"), 
                       key = Sys.getenv("AWS_ACCESS_KEY_ID"), 
                       secret = Sys.getenv("AWS_SECRET_ACCESS_KEY"), 
                       session_token = Sys.getenv("AWS_SESSION_TOKEN"), 
                       ...) {
    current <- Sys.time()
    d_timestamp <- format(current, "%Y%m%dT%H%M%SZ", tz = "UTC")
    if (region == "") {
        region <- "us-east-1"
    }
    url <- paste0("https://lambda.", region, ".amazonaws.com", action)
    
    if (length(body)) { 
        if (is.list(body)) {
            body <- jsonlite::toJSON(body, auto_unbox = TRUE)
        }
    } else {
        body <- NULL
    }
    if (key == "") {
        stop("Must supply AWS AccessKeyId and SecretAccessKey")
    } else {
        headers$host <- paste0("lambda.",region,".amazonaws.com")
        headers$`x-amz-date` <- d_timestamp
        #if (!is.null(body)) {
        #    headers$`x-amz-sha256-tree-hash` <- .treehash(body)
        #}
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
               session_token = session_token)
        headers$`x-amz-content-sha256` <- Sig$BodyHash
        headers$Authorization <- Sig$SignatureHeader
        if (!is.null(session_token) && session_token != "") {
            headers[["x-amz-security-token"]] <- session_token
        }
        H <- do.call("add_headers", headers)
    }
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
    
    #browser()
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
