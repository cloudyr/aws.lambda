#' @rdname functions
#' @title Function Management
#' @description List functions, function versions, and function policies
#' @template name
#' @template qualifier
#' @param marker A pagination marker from a previous request.
#' @param n An integer specifying the number of results to return.
#' @template dots
#' @return An object of class \dQuote{aws_lambda_function}.
#' @details \code{list_functions} lists all functions. \code{get_function}
#'   retrieves a specific function and \code{list_function_versions} retrieves
#'   all versions of that function. \code{get_function_policy} returns the
#'   resource-based IAM policy for a function. \code{delete_function} deletes a
#'   function, if you have permission to do so.
#' @references
#' \href{https://docs.aws.amazon.com/lambda/latest/dg/API_GetFunction.html}{API
#' Reference: GetFunction}
#' \href{https://docs.aws.amazon.com/lambda/latest/dg/API_ListVersionsByFunction.html}{API
#' Reference: ListVersionsByFunction}
#' \href{https://docs.aws.amazon.com/lambda/latest/dg/API_ListFunctions.html}{API
#' Reference: ListFunctions}
#' \href{https://docs.aws.amazon.com/lambda/latest/dg/API_GetPolicy.html}{API
#' Reference: GetPolicy}
#' @seealso \code{\link{create_function}}, \code{\link{update_function_code}},
#'   \code{\link{update_function_config}}
#' @export
get_function <- function(name, qualifier, ...) {
  name <- get_function_name(name)
  act <- paste0("/2015-03-31/functions/", name)
  query <- list()
  if (!missing(qualifier)) {
    query[["Qualifier"]] <- qualifier
  }
  r <- lambdaHTTP(verb = "GET", action = act, query = query, ...)
  structure(
    c(r[["Configuration"]], list(Code = r[["Code"]], Tags = r[["Tags"]])),
    class = "aws_lambda_function"
  )
}

#' @rdname functions
#' @export
list_functions <- function(marker, n, ...) {
  act <- paste0("/2015-03-31/functions")
  query <- list()
  if (!missing(marker)) {
    query[["Marker"]] <- marker
  }
  if (!missing(n)) {
    query[["MaxItems"]] <- n
  }
  r <- lambdaHTTP(verb = "GET", action = act, query = query, ...)
  structure(
    lapply(r[["Functions"]], `class<-`, "aws_lambda_function"),
    marker = r[["NextMarker"]]
  )
}

#' @rdname functions
#' @export
list_function_versions <- function(name, marker, n, ...) {
  name <- get_function_name(name)
  act <- paste0("/2015-03-31/functions/", name, "/versions")
  query <- list()
  if (!missing(marker)) {
    query[["Marker"]] <- marker
  }
  if (!missing(n)) {
    query[["MaxItems"]] <- n
  }
  r <- lambdaHTTP(verb = "GET", action = act, query = query, ...)
  structure(
    lapply(r[["Versions"]], `class<-`, "aws_lambda_function"),
    marker = r[["NextMarker"]]
  )
}

#' @rdname functions
#' @export
delete_function <- function(name, qualifier, ...) {
  name <- get_function_name(name)
  act <- paste0("/2015-03-31/functions/", name)
  query <- list()
  if (!missing(qualifier)) {
    query[["Qualifier"]] <- qualifier
  }
  r <- lambdaHTTP(verb = "DELETE", action = act, query = query, ...)
  return(TRUE)
}

#' @rdname functions
#' @export
get_function_policy <- function(name, qualifier, ...) {
  name <- get_function_name(name)
  act <- paste0("/2015-03-31/functions/", name, "/policy")
  query <- list()
  if (!missing(qualifier)) {
    query[["Qualifier"]] <- qualifier
  }
  r <- lambdaHTTP(verb = "GET", action = act, query = query, ...)
  return(r)
}
