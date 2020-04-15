#' @title Invoke Lambda Function
#' @description Invoke a lambda function
#' @template name
#' @template qualifier
#' @param payload Optionally, a list of parameters to send in the JSON body to
#'   the function.
#' @param type A character string specifying one of: (1) \dQuote{Event}
#'   (asynchronous execution), (2) \dQuote{RequestResponse} (the default), or
#'   (3) \dQuote{DryRun} to test the function without executing it.
#' @param log A character string to control log response.
#' @template dots
#' @seealso \code{\link{create_function}}, \code{\link{list_functions}},
#' @export
invoke_function <- function(name,
                            qualifier,
                            payload = NULL,
                            type = c("RequestResponse", "Event", "DryRun"),
                            log = c("None", "Tail"),
                            # context,
                            ...) {
  name <- get_function_name(name)
  act <- paste0("/2015-03-31/functions/", name, "/invocations")
  query <- list()
  if (!missing(qualifier)) {
    query[["Qualifier"]] <- qualifier
  }
  h <- list(
    "X-Amz-Invocation-Type" = match.arg(type),
    "X-Amz-Log-Type" = match.arg(log) # ,
    # "X-Amz-Client-Context" = context
  )
  r <- lambdaHTTP(
    verb = "POST",
    action = act,
    headers = h,
    query = query,
    body = payload,
    ...
  )
  return(r)
}
