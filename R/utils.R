print.aws_lambda_function <- function(x, ...) {
    print(str(x))
    return(invisible(x))
}

get_function_name <- function(x, ...) {
    UseMethod("get_function_name")
}

get_function_name.character <- function(x, ...) {
    x
}

get_function_name.aws_lambda_function <- function(x, ...) {
    x[["FunctionName"]]
}
