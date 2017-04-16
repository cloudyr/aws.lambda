#' @rdname create_function
#' @title Manage AWS Lambda Functions
#' @description Create, update, and version AWS Lambda functions
#' @param func Either (1) a character string containing AWS S3 bucket and object key (e.g., \code{"s3://bucketname/objectkey"}) where the object is the .zip file containing the AWS Lambda deployment package; or (2) a file string pointing to a .zip containing the deployment package.
#' @template name
#' @param description Optionally, a max 256-character description of the function for your own use.
#' @param handler A character string specifying the function within your code that Lambda calls to begin execution.
#' @param role A character string containing an IAM role or an object of class \dQuote{iam_role}.
#' @param runtime A character string specifying the runtime environment for the function.
#' @param timeout An integer specifying the timeout for the function, in seconds.
#' @template dots
#' @return A list of class \dQuote{aws_lambda_function}.
#' @details \code{create_function} creates a new function from a deployment package. \code{update_function} can, separately, update the code within a function or the configuration settings thereof. \code{make_function_version} records a function version (see \code{\link{list_function_versions}}; changes made between versioning are not recorded.
#' @references
#'  \href{http://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html}{API Reference: CreateFunction}
#'  \href{http://docs.aws.amazon.com/lambda/latest/dg/API_UpdateFunction.html}{API Reference: UpdateFunction}
#'  \href{http://docs.aws.amazon.com/lambda/latest/dg/API_PublishFunction.html}{API Reference: PublishFunction}
#' 
#' @examples
#' \dontrun{
#'   # 'hello world!' example code
#'   hello <- system.file("templates", "helloworld.js", package = "aws.lambda")
#'
#'   # get IAM role for Lambda execution
#'   library("aws.iam")
#'   id <- get_caller_identity()[["Account"]]
#'   role <- paste0("arn:aws:iam::", id, ":role/lambda_basic_execution")
#' 
#'   func <- create_function("helloworld", func = hello, 
#'                           handler = "helloworld.handler", 
#'                           role = role)
#'   
#'   # invoke function
#'   invoke_function(func)
#' 
#'   # delete function
#'   delete_function(func)
#' }
#' @seealso \code{\link{invoke_function}}, \code{\link{create_function_alias}}, \code{\link{list_functions}}, \code{\link{delete_function}}
#' @importFrom base64enc base64encode
#' @importFrom utils zip
#' @export
create_function <- 
function(name, 
         description = name,
         func, 
         handler, 
         role,
         runtime = c("nodejs6.10", "nodejs4.3", "java8", "python2.7", "dotnetcore1.0", "nodejs4.3-edge"),
         timeout = 3L,
         ...) {
    act <- paste0("/2015-03-31/functions")
    b <- list(Code = list())
    if (grepl("^s3://", func)) {
        x <- substring(func, 6, nchar(func))
        b[["Code"]][["S3Bucket"]] <- substring(x, 1, regexpr("/", x)-1L)
        b[["Code"]][["S3Key"]] <- substring(x, regexpr("/", x)+1L, nchar(x))
    } else {
        if (!file.exists(func)) {
            stop(sprintf("File '%s' not found!", func))
        }
        if (endsWith(func, "zip")) {
            b[["Code"]] <- list(ZipFile = base64enc::base64encode(func))
        } else {
            wd <- getwd()
            on.exit(setwd(wd))
            file.copy(from = func, to = tempdir(), overwrite = TRUE)
            tmp <- tempfile(fileext = ".zip")
            on.exit(unlink(tmp), add = TRUE)
            setwd(tempdir())
            utils::zip(zipfile = tmp, files = basename(func))
            setwd(wd)
            b[["Code"]] <- list(ZipFile = base64enc::base64encode(tmp))
        }
    }
    b[["FunctionName"]] <- name
    b[["Description"]] <- description
    b[["Handler"]] <- handler
    b[["Role"]] <- role
    b[["Runtime"]] <- match.arg(runtime)
    if (timeout != 3) {
        b[["Timeout"]] <- timeout
    }
    r <- lambdaHTTP(verb = "POST", action = act, body = b, ...)
    structure(r, class = "aws_lambda_function")
}

#' @rdname create_function
#' @export
update_function <- 
function(name, 
         func, 
         description,
         handler, 
         role,
         runtime = c("nodejs6.10", "nodejs4.3", "java8", "python2.7", "dotnetcore1.0", "nodejs4.3-edge"),
         timeout = 3L,
         ...) {
    name <- get_function_name(name)
    if (!missing(func)) {
        # update code
        act <- paste0("/2015-03-31/functions/", name, "/code")
        b <- list()
        if (grepl("^s3://", func)) {
            x <- substring(func, 6, nchar(func))
            b[["S3Bucket"]] <- substring(x, 1, regexpr("/", x)-1L)
            b[["S3Key"]] <- substring(x, regexpr("/", x)+1L, nchar(x))
        } else {
            if (!file.exists(func)) {
                stop(sprintf("File '%s' not found!", func))
            }
            if (endsWith(func, "zip")) {
                b[["ZipFile"]] <- base64enc::base64encode(func)
            } else {
                wd <- getwd()
                on.exit(setwd(wd))
                file.copy(from = func, to = tempdir(), overwrite = TRUE)
                tmp <- tempfile(fileext = ".zip")
                on.exit(unlink(tmp), add = TRUE)
                setwd(tempdir())
                utils::zip(zipfile = tmp, files = basename(func))
                setwd(wd)
                b[["ZipFile"]] <- base64enc::base64encode(tmp)
            }
        }
    } else {
        act <- paste0("/2015-03-31/functions/", name, "/configuration")
        b <- list()
        if (!missing(description)) {
            b[["Description"]] <- description
        }
        if (!missing(handler)) {
            b[["Handler"]] <- handler
        }
        if (!missing(role)) {
            b[["Role"]] <- role
        }
        if (!missing(runtime)) {
            b[["Runtime"]] <- match.arg(runtime)
        }
        if (!missing(runtime) && timeout != 3) {
            b[["Timeout"]] <- timeout
        }
    }
    r <- lambdaHTTP(verb = "PUT", action = act, body = b, ...)
    structure(r, class = "aws_lambda_function")
}

#' @rdname create_function
#' @export
make_function_version <- function(name, description, ...) {
    name <- get_function_name(name)
    act <- paste0("/2015-03-31/functions/", name, "/versions")
    b <- list()
    if (!missing(description)) {
        b[["Description"]] <- description
    }
    r <- lambdaHTTP(verb = "POST", action = act, body = b, ...)
    return(r)
}
