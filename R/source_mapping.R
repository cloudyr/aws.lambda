# The endpoints ("act") need to be updated on these before they're exported.

create_eventsource <- function(body, ...) {
  act <- paste0("/event-source-mapping")
  r <- lambdaHTTP(verb = "POST", action = act, body = body, ...)
  return(r)
}

update_eventsource <- function(source, body, ...) {
  act <- paste0("/event-source-mapping/", source)
  r <- lambdaHTTP(verb = "PUT", action = act, body = body, ...)
  return(r)
}

delete_eventsource <- function(source, ...) {
  act <- paste0("/event-source-mapping/", source)
  r <- lambdaHTTP(verb = "DELETE", action = act, ...)
  return(r)
}

get_eventsource <- function(source, ...) {
  act <- paste0("/event-source-mapping/", source)
  r <- lambdaHTTP(verb = "GET", action = act, ...)
  return(r)
}

list_eventsources <- function(stream, func, marker, n, ...) {
  act <- paste0("/event-source-mappings/")
  query <- list(
    EventSourceArn = stream,
    FunctionName = func,
    Marker = marker,
    MaxItems = n
  )
  r <- lambdaHTTP(verb = "GET", action = act, query = query, ...)
  return(r)
}
