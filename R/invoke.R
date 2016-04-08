# http://docs.aws.amazon.com/mobileanalytics/latest/ug/PutEvents.html

invoke_function <- 
function(func, qualifier, payload, 
         type = c("Event", "RequestResponse", "DryRun"),
         log = c("None", "Tail"),
         context
         ...) {
    act <- paste0("/functions/", func, "/invocations")
    h <- list("X-Amz-Invocation-Type" = type,
              "X-Amz-Log-Type" = log,
              "X-Amz-Client-Context" = context)
    r <- lambdaHTTP(verb = "POST", action = act, 
                    headers = h,
                    query = list(Qualifier = qualifier), 
                    body = payload, ...)
    return(r)
}
