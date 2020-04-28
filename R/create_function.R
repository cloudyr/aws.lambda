#' @rdname create_function
#' @title Manage AWS Lambda Functions
#' @description Create, update, and version AWS Lambda functions
#' @param func Either (1) a character string containing a url-style AWS S3
#'   bucket and object key (e.g., \code{"s3://bucketname/objectkey"}) where the
#'   object is the .zip file containing the AWS Lambda deployment package; (2) a
#'   file string pointing to a .zip containing the deployment package; or (3) a
#'   single file (e.g., a javascript file) that will be zipped and used as the
#'   deployment. The third option is merely a convenience for very simple
#'   deployment packages.
#' @template name
#' @param description Optionally, a max 256-character description of the
#'   function for your own use.
#' @param handler A character string specifying the function within your code
#'   that Lambda calls to begin execution.
#' @param role A character string containing an IAM role or an object of class
#'   \dQuote{iam_role}. This is the role that is used when the function is
#'   invoked, so it must have permissions over any AWS resources needed by the
#'   function.
#' @param runtime A character string specifying the runtime environment for the
#'   function.
#' @param timeout An integer specifying the timeout for the function, in
#'   seconds.
#' @param layers A character vector of pre-built layers to be used by your function
#'   when runtime is \code{provided}.
#' @param memory_size An integer specifying the amount of RAM that's allocated to the
#'   function. Unenforced minimum value of 128, maximum value of 3008 (will be
#'   enforced on the API side).
#' @template dots
#' @return A list of class \dQuote{aws_lambda_function}.
#' @details \code{create_function} creates a new function from a deployment
#'   package. \code{update_function_code} updates the code within a function.
#'   \code{update_function_config} updates the configuration settings of a
#'   function. \code{publish_function_version} records a function version (see
#'   \code{\link{list_function_versions}}; changes made between versioning are
#'   not recorded.
#' @references
#' \href{https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html}{API
#' Reference: CreateFunction}
#' \href{https://docs.aws.amazon.com/lambda/latest/dg/API_UpdateFunctionCode.html}{API
#' Reference: UpdateFunctionCode}
#' \href{https://docs.aws.amazon.com/lambda/latest/dg/API_PublishVersion.html}{API
#' Reference: PublishVersion}
#'
#' @examples
#' \dontrun{
#' # 'hello world!' example code
#' hello <- system.file("templates", "helloworld.js", package = "aws.lambda")
#'
#' # get IAM role for Lambda execution
#' library("aws.iam")
#' id <- get_caller_identity()[["Account"]]
#' # Note: This role may not work. We recommend copying the ARN of a
#' # Lambda-capable role from the console once until we're able to more
#' # smoothly integrate with aws.iam.
#' role <- paste0("arn:aws:iam::", id, ":role/lambda_basic_execution")
#'
#' lambda_func <- create_function("helloworld",
#'   func = hello,
#'   handler = "helloworld.handler",
#'   role = role
#' )
#'
#' # invoke function
#' invoke_function(lambda_func)
#'
#' # delete function
#' delete_function(lambda_func)
#' }
#' @seealso \code{\link{invoke_function}}, \code{\link{create_function_alias}},
#'   \code{\link{list_functions}}, \code{\link{delete_function}}
#' @export
create_function <- function(name,
                            func,
                            handler,
                            role,
                            runtime = c(
                              "nodejs12.x",
                              "nodejs10.x",
                              "java11",
                              "java8",
                              "python3.8",
                              "python3.7",
                              "python3.6",
                              "python2.7",
                              "dotnetcore3.1",
                              "dotnetcore2.1",
                              "go1.x",
                              "ruby2.7",
                              "ruby2.5",
                              "provided"
                            ),
                            timeout = 3L,
                            description,
                            layers,
                            memory_size = 128L,
                            ...) {
  act <- "/2015-03-31/functions"
  b <- list()
  b[["Code"]] <- .function_code_body(func)
  b[["FunctionName"]] <- name
  b[["Handler"]] <- handler
  b[["Role"]] <- role
  b[["Runtime"]] <- match.arg(runtime)
  if (!missing(description)) {
    b[["Description"]] <- description
  }
  if (timeout != 3) {
    b[["Timeout"]] <- timeout
  }
  if (!missing(layers)) {
    b[["Layers"]] <- as.list(layers)
  }
  if (!missing(memory_size)) {
    b[["MemorySize"]] = memory_size
  }
  return(lambdaHTTP(verb = "POST", action = act, body = b, ...))
}

.function_code_body <- function(func) {
  if (grepl("^s3://", func)) {
    x <- substring(func, 6, nchar(func))
    to_return <- list(
      S3Bucket = substring(x, 1, regexpr("/", x) - 1L),
      S3Key = substring(x, regexpr("/", x) + 1L, nchar(x))
    )
  } else {
    if (!file.exists(func)) {
      stop(sprintf("File '%s' not found!", func))
    }
    # For now, I do not test any of these due to inconsistency in the result.
    # Will add mocks soon.
    if (endsWith(func, "zip")) { # nocov start
      to_return <- list(ZipFile = base64enc::base64encode(func))
    } else {
      wd <- getwd()
      on.exit(setwd(wd))
      file.copy(from = func, to = tempdir(), overwrite = TRUE)
      tmp <- tempfile(fileext = ".zip")
      on.exit(unlink(tmp), add = TRUE)
      setwd(tempdir())
      utils::zip(zipfile = tmp, files = basename(func))
      setwd(wd)
      to_return <- list(ZipFile = base64enc::base64encode(tmp))
    } # nocov end
  }
  return(to_return)
}

# update_function_code and update_function_config were smushed into one
# update_function, but I think that was a bad idea, so I've split them.

#' @rdname create_function
#' @export
update_function_code <- function(name, func, ...) {
  name <- get_function_name(name)
  act <- paste0("/2015-03-31/functions/", name, "/code")
  b <- .function_code_body(func)
  return(lambdaHTTP(verb = "PUT", action = act, body = b, ...))
}

#' @rdname create_function
#' @export
update_function_config <- function(name,
                                   description,
                                   handler,
                                   role,
                                   runtime = c(
                                     "nodejs12.x",
                                     "nodejs10.x",
                                     "java11",
                                     "java8",
                                     "python3.8",
                                     "python3.7",
                                     "python3.6",
                                     "python2.7",
                                     "dotnetcore3.1",
                                     "dotnetcore2.1",
                                     "go1.x",
                                     "ruby2.7",
                                     "ruby2.5",
                                     "provided"
                                   ),
                                   timeout = 3L,
                                   ...) {
  name <- get_function_name(name)
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
  return(lambdaHTTP(verb = "PUT", action = act, body = b, ...))
}

#' @rdname create_function
#' @export
update_function <- function(name, # nocov start
                            func,
                            description,
                            handler,
                            role,
                            runtime = c(
                              "nodejs12.x",
                              "nodejs10.x",
                              "java11",
                              "java8",
                              "python3.8",
                              "python3.7",
                              "python3.6",
                              "python2.7",
                              "dotnetcore3.1",
                              "dotnetcore2.1",
                              "go1.x",
                              "ruby2.7",
                              "ruby2.5",
                              "provided"
                            ),
                            timeout = 3L,
                            ...) {
  if (!missing(func)) {
    .Deprecated(
      new = "update_function_code",
      package = "aws.lambda",
      msg = paste(
        "update_function has been replaced by update_function_code and",
        "update_function_config.",
        "\nSince you included the func parameter, your code will be executed",
        "by update_function_code.",
        "\nupdate_function will be removed in a future version of this",
        "package."
      )
    )
    update_function_code(name, func, ...)
  } else {
    .Deprecated(
      new = "update_function_config",
      package = "aws.lambda",
      msg = paste(
        "update_function has been replaced by update_function_code and",
        "update_function_config.",
        "\nSince you did not include the func parameter,",
        "your code will be executed by update_function_config.",
        "\nupdate_function will be removed in a future version of this",
        "package."
      )
    )
    update_function_config(
      name, description, handler, role, runtime, timeout, ...
    )
  }
} # nocov end

#' @rdname create_function
#' @export
publish_function_version <- function(name, description, ...) {
  name <- get_function_name(name)
  act <- paste0("/2015-03-31/functions/", name, "/versions")
  b <- list()
  if (!missing(description)) {
    b[["Description"]] <- description
  }
  return(lambdaHTTP(verb = "POST", action = act, body = b, ...))
}

#' @rdname create_function
#' @export
make_function_version <- function(name, description, ...) { # nocov start
  .Deprecated(
    new = "publish_function_version",
    package = "aws.lambda",
    msg = paste(
      "make_function_version has been renamed to publish_function_version",
      "to better match the api.",
      "\nmake_function_version will be removed in a future version",
      "of this package."
    )
  )
  publish_function_version(name = name, description = description, ...)
} # nocov end
