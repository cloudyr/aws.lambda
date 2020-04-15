# These functions are not yet exported, and I don't think they're pointing to a
# valid endpoint (they need a date before /functions/). I'm not deleting yet,
# but I also have not verified these.

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
