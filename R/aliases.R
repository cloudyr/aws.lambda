#' @rdname alias
#' @title Alias Management
#' @description List, create, update, and delete function aliases
#' @template name
#' @param alias A character string specifying a function alias
#' @param version A character string specifying a function version to associate
#'   with this alias.
#' @param description Optionally, a max 256-character description of the
#'   function for your own use.
#' @param marker A pagination marker from a previous request.
#' @param n An integer specifying the number of results to return.
#' @template dots
#' @return An object of class \dQuote{aws_lambda_function}.
#' @details \code{create_function_alias} creates a new function alias for a
#'   given version of a function. \code{update_function_alias} updates the
#'   association between a function alias and the function version.
#'   \code{list_function_aliases} lists all function aliases.
#'   \code{get_function_alias} retrieves a specific function alias.
#'   \code{delete_function_alias} deletes a function alias, but not the
#'   associated function version.
#' @references
#' \href{https://docs.aws.amazon.com/lambda/latest/dg/API_GetAlias.html}{API
#' Reference: GetAlias}
#' \href{https://docs.aws.amazon.com/lambda/latest/dg/API_CreateAlias.html}{API
#' Reference: CreateAlias}
#' \href{https://docs.aws.amazon.com/lambda/latest/dg/API_UpdateAlias.html}{API
#' Reference: UpdateAlias}
#' \href{https://docs.aws.amazon.com/lambda/latest/dg/API_DeleteAlias.html}{API
#' Reference: DeleteAlias}
#' \href{https://docs.aws.amazon.com/lambda/latest/dg/API_ListAliases.html}{API
#' Reference: ListAliases}
#' @seealso \code{\link{create_function}}, \code{\link{list_functions}}
#' @export
create_function_alias <- function(name, alias, version, description, ...) {
  name <- get_function_name(name)
  act <- paste0("/2015-03-31/functions/", name, "/aliases")
  b <- list(FunctionVersion = version, Name = alias)
  # Description is optional.
  if (!missing(description)) {
    b[["Description"]] <- description
  }
  r <- lambdaHTTP(verb = "POST", action = act, body = b, ...)
  return(r)
}

#' @rdname alias
#' @export
update_function_alias <- function(name, alias, version, description, ...) {
  name <- get_function_name(name)
  act <- paste0("/2015-03-31/functions/", name, "/aliases/", alias)
  b <- list()
  if (!missing(version)) {
    b[["FunctionVersion"]] <- version
  }
  if (!missing(description)) {
    b[["Description"]] <- description
  }
  r <- lambdaHTTP(verb = "PUT", action = act, body = b, ...)
  return(r)
}

#' @rdname alias
#' @export
delete_function_alias <- function(name, alias, ...) {
  name <- get_function_name(name)
  act <- paste0("/2015-03-31/functions/", name, "/aliases/", alias)
  r <- lambdaHTTP(verb = "DELETE", action = act, ...)
  return(r)
}

#' @rdname alias
#' @export
get_function_alias <- function(name, alias, ...) {
  name <- get_function_name(name)
  act <- paste0("/2015-03-31/functions/", name, "/aliases/", alias)
  r <- lambdaHTTP(verb = "GET", action = act, ...)
  return(r)
}

#' @rdname alias
#' @export
list_function_aliases <- function(name, version, marker, n, ...) {
  name <- get_function_name(name)
  act <- paste0("/2015-03-31/functions/", name, "/aliases")
  query <- list()
  if (!missing(version)) {
    warning(
      "The AWS API erroneously returns an empty list when version is specified",
      " if you only have one alias.",
      "\n  You may want to try again without specifying a version."
    )
    query[["FunctionVersion"]] <- version
  }
  if (!missing(marker)) {
    query[["Marker"]] <- marker
  }
  if (!missing(n)) {
    query[["MaxItems"]] <- n
  }
  r <- lambdaHTTP(verb = "GET", action = act, query = query, ...)
  return(r)
}
