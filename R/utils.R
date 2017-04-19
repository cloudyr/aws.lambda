print.aws_lambda_function <- function(x, ...) {
    print(str(x))
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
