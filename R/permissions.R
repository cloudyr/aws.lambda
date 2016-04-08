add_permission <- function(func, qualifier, ...) {
    act <- paste0("/functions/", func, "/policy")
    query <- list(Qualifier = qualifier)
    r <- lambdaHTTP(verb = "GET", action = act, query = query, ...)
    return(r)
}

remove_permission <- function(func, qualifier, id, ...) {
    act <- paste0("/functions/", func, "/policy/", id)
    query <- list(Qualifier = qualifier)
    r <- lambdaHTTP(verb = "DELETE", action = act, query = query, ...)
    return(r)
}
