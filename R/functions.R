# http://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html
create_function <- function(func, body, ...) {
    act <- paste0("/functions")
    r <- lambdaHTTP(verb = "POST", action = act, body = body, ...)
    return(r)
}

update_function <- function(func, code, configuration, ...) {
    if (!missing(code)) {
        act <- paste0("/functions/", func, "/code")
        r <- lambdaHTTP(verb = "PUT", action = act, body = code, ...)
        return(r)
    } else if (!missing(configuration)) {
        act <- paste0("/functions/", func, "/configuration")
        r <- lambdaHTTP(verb = "PUT", action = act, body = configuration, ...)
        return(r)
    } else {
        stop("Must specify 'code' or 'configuration'")
    }
}

publish_function <- function(func, sha, desc, ...) {
    act <- paste0("/functions/", func, "/versions")
    b <- list(CodeSha256 = sha, Description = desc)
    r <- lambdaHTTP(verb = "POST", action = act, body = b, ...)
    return(r)
}

delete_function <- function(func, qualifier, ...) {
    act <- paste0("/functions/", func, "/aliases/", name)
    b <- list(Qualifier = qualifier)
    r <- lambdaHTTP(verb = "DELETE", action = act, body = b, ...)
    return(r)
}

get_function <- function(func, qualifier, ...) {
    # Another endpoint just gets configuration: 
    # http://docs.aws.amazon.com/lambda/latest/dg/API_GetFunctionConfiguration.html
    act <- paste0("/functions/", func)
    b <- list(Qualifier = qualifier)
    r <- lambdaHTTP(verb = "GET", action = act, body = b, ...)
    return(r)
}

get_function_policy <- function(func, qualifier, ...) {
    act <- paste0("/functions/", func, "/policy")
    b <- list(Qualifier = qualifier)
    r <- lambdaHTTP(verb = "GET", action = act, body = b, ...)
    return(r)
}


list_functions <- function(func, name, vers, marker, n...) {
    act <- paste0("/functions")
    query <- list(Marker = marker, MaxItems = n)
    r <- lambdaHTTP(verb = "GET", action = act, query = query, ...)
    return(r)
}

list_function_versions <- function(func, marker, n...) {
    act <- paste0("/functions/", func, "/versions")
    query <- list(Marker = marker, MaxItems = n)
    r <- lambdaHTTP(verb = "GET", action = act, query = query, ...)
    return(r)
}
