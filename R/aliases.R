create_alias <- function(func, name, desc, vers, ...) {
    act <- paste0("/functions/", func, "/aliases")
    b <- list(Description = desc, FunctionVersion = vers, Name = name)
    r <- lambdaHTTP(verb = "POST", action = act, body = b, ...)
    return(r)
}

update_alias <- function(func, name, desc, vers, ...) {
    act <- paste0("/functions/", func, "/aliases/", name)
    b <- list(Description = desc, FunctionVersion = vers)
    r <- lambdaHTTP(verb = "PUT", action = act, body = b, ...)
    return(r)
}

delete_alias <- function(func, name, ...) {
    act <- paste0("/functions/", func, "/aliases/", name)
    r <- lambdaHTTP(verb = "DELETE", action = act, ...)
    return(r)
}

get_alias <- function(func, name, ...) {
    act <- paste0("/functions/", func, "/aliases/", name)
    r <- lambdaHTTP(verb = "GET", action = act, ...)
    return(r)
}

list_aliases <- function(func, name, vers, marker, n...) {
    act <- paste0("/functions/", func, "/aliases")
    query <- list(FunctionVersion = vers, Marker = marker, MaxItems = n)
    r <- lambdaHTTP(verb = "GET", action = act, query = query, ...)
    return(r)
}
