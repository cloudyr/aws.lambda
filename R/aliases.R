#' @rdname alias
#' @title Alias Management
#' @description List, create, update, and delete function aliases
#' @template name
#' @param alias A character string specifying a function alias
#' @param description Optionally, a max 256-character description of the function for your own use.
#' @param version A character string specifying a function version
#' @param marker A pagination marker from a previous request.
#' @param n An integer specifying the number of results to return.
#' @template dots
#' @return An object of class \dQuote{aws_lambda_function}.
#' @details \code{list_functions} lists all functions. \code{get_function} retrieves a specific function and \code{get_function_versions} retrieves all versions of that function. \code{get_function_configuration} returns the configuration details used when creating or updating the function. \code{delete_function} deletes a function, if you have permission to do so.
#' @references
#'  \href{http://docs.aws.amazon.com/lambda/latest/dg/API_GetAlias.html}{API Reference: GetAlias}
#'  \href{http://docs.aws.amazon.com/lambda/latest/dg/API_CreateAlias.html}{API Reference: CreateAlias}
#'  \href{http://docs.aws.amazon.com/lambda/latest/dg/API_UpdateAlias.html}{API Reference: UpdateAlias}
#'  \href{http://docs.aws.amazon.com/lambda/latest/dg/API_DeleteAlias.html}{API Reference: DeleteAlias}
#'  \href{http://docs.aws.amazon.com/lambda/latest/dg/API_ListAliases.html}{API Reference: ListAliases}
#' @seealso \code{\link{create_function}}, \code{\link{list_functions}}
#' @export
create_alias <- function(name, alias, description, version, ...) {
    name <- get_function_name(name)
    act <- paste0("/2015-03-31/functions/", name, "/aliases")
    b <- list(Description = description, FunctionVersion = version, Name = alias)
    r <- lambdaHTTP(verb = "POST", action = act, body = b, ...)
    return(r)
}

#' @rdname alias
#' @export
update_alias <- function(name, alias, description, version, ...) {
    name <- get_function_name(name)
    act <- paste0("/2015-03-31/functions/", name, "/aliases/", alias)
    b <- list(Description = description, FunctionVersion = version)
    r <- lambdaHTTP(verb = "PUT", action = act, body = b, ...)
    return(r)
}

#' @rdname alias
#' @export
delete_alias <- function(name, alias, ...) {
    name <- get_function_name(name)
    act <- paste0("/2015-03-31/functions/", name, "/aliases/", alias)
    r <- lambdaHTTP(verb = "DELETE", action = act, ...)
    return(r)
}

#' @rdname alias
#' @export
get_alias <- function(name, alias, ...) {
    name <- get_function_name(name)
    act <- paste0("/2015-03-31/functions/", name, "/aliases/", alias)
    r <- lambdaHTTP(verb = "GET", action = act, ...)
    return(r)
}

#' @rdname alias
#' @export
list_aliases <- function(name, version, marker, n, ...) {
    name <- get_function_name(name)
    act <- paste0("/2015-03-31/functions/", name, "/aliases")
    query <- list(FunctionVersion = version, Marker = marker, MaxItems = n)
    r <- lambdaHTTP(verb = "GET", action = act, query = query, ...)
    return(r)
}
