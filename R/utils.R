print.aws_lambda_function <- function(x, ...) {
  print(utils::str(x))
  return(invisible(x))
}

#' @rdname get_function_name
#' @title Get name of Lambda function
#' @description Extracts an AWS Lambda function's name
#' @param x An object of class \dQuote{aws_lambda_function}.
#' @param \dots Additional arguments passed to methods
#' @export
get_function_name <- function(x, ...) {
  UseMethod("get_function_name")
}

#' @rdname get_function_name
#' @export
get_function_name.character <- function(x, ...) {
  x
}

#' @rdname get_function_name
#' @export
get_function_name.aws_lambda_function <- function(x, ...) {
  x[["FunctionName"]]
}

#' Default value for `NULL`
#'
#' This infix function makes it easy to replace `NULL`s with a default
#' value. It's inspired by the way that Ruby's or operation (`||`)
#' works. Copied from the rlang package.
#'
#' @param x,y If `x` is NULL, will return `y`; otherwise returns `x`.
#' @keywords internal
#' @name op-null-default
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
