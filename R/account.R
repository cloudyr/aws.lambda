#' @title AWS Lambda Account Settings
#' @description Get account settings
#' @template dots
#' @return A list.
#' @examples
#' \dontrun{
#'   get_account()
#' }
#' @export
get_account <- function(...) {
    act <- paste0("/2016-08-19/account-settings")
    lambdaHTTP(verb = "GET", action = act, ...)
}
