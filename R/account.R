#' @title AWS Lambda Account Settings
#' @description Get account settings
#' @template dots
#' @return A list.
#' @examples
#' \dontrun{
#' get_lambda_account()
#' }
#' @export
get_lambda_account <- function(...) {
  act <- "/2016-08-19/account-settings"
  return(
    structure(
      lambdaHTTP(verb = "GET", action = act, ...),
      class = "aws_lambda_account"
    )
  )
}
