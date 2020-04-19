
<!-- README.md is generated from README.Rmd. Please edit that file -->

# aws.lambda

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/aws.lambda)](https://CRAN.R-project.org/package=aws.lambda)
<!-- badges: end -->

**aws.lambda** is a client package for the [Amazon Web Services (AWS)
Lambda API](https://aws.amazon.com/lambda/).

## Installation

You can install the released version of aws.lambda from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("aws.lambda")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("cloudyr/aws.lambda")
```

## API Keys

To use the package, you will need an AWS account and to enter your
credentials into R. Your keypair can be generated on the [IAM Management
Console](https://aws.amazon.com/) under the heading *Access Keys*. Note
that you only have access to your secret key once. After it is
generated, you need to save it in a secure location. New keypairs can be
generated at any time if yours has been lost, stolen, or forgotten. The
[**aws.iam** package](https://github.com/cloudyr/aws.iam) profiles tools
for working with IAM, including creating roles, users, groups, and
credentials programmatically; it is not needed to *use* IAM credentials.

A detailed description of how credentials can be specified is provided
at: <https://github.com/cloudyr/aws.signature/>. The easiest way is to
simply set environment variables on the command line prior to starting R
or via an `Renviron.site` or `.Renviron` file, which are used to set
environment variables in R during startup (see `? Startup`). They can
also be set within R:

``` r
Sys.setenv("AWS_ACCESS_KEY_ID" = "mykey",
           "AWS_SECRET_ACCESS_KEY" = "mysecretkey",
           "AWS_DEFAULT_REGION" = "us-east-1",
           "AWS_SESSION_TOKEN" = "mytoken")
```

## Code Examples

The package is still under rapid development, but a simple and literal
“Hello, world\!” example can be found by doing the following:

``` r
library("aws.lambda")

# get list of all current functions
funclist <- sapply(list_functions(), get_function_name)

# 'hello world!' example code
hello <- system.file("templates", "helloworld.js", package = "aws.lambda")

# get IAM role for Lambda execution. Note: This is not currently sufficient, and
# will be updated in an upcoming update to the package.
requireNamespace("aws.iam")
id <- aws.iam::get_caller_identity()[["Account"]]
role <- paste0("arn:aws:iam::", id, ":role/lambda_basic_execution")

if (!"helloworld" %in% funclist) {
  func <- create_function(name = "helloworld", func = hello, 
                          handler = "helloworld.handler", role = role)
} else {
  func <- get_function("helloworld")
}

# invoke function
invoke_function(func)
```

``` r
delete_function(func)
```

Obviously this is a trivial lambda function, but the point is that
basically anything (in node.js, python, or java) could be written into
the “deployment package” and called in this way.

A slightly more complex example shows how to pass arguments to the
lambda function via the function’s `payload` and examine the response.

``` r
# example function that performs simple addition
plus <- system.file("templates", "plus.js", package = "aws.lambda")

# get IAM role for Lambda execution
requireNamespace("aws.iam")
id <- aws.iam::get_caller_identity()[["Account"]]
role <- paste0("arn:aws:iam::", id, ":role/lambda_basic_execution")

if (!"plus" %in% funclist) {
  func <- create_function(name = "plus", func = plus, 
                          handler = "plus.handler", role = role)
} else {
  func <- get_function("plus")
}

# invoke function
invoke_function(func, payload = list(a = 2, b = 3))
invoke_function(func, payload = list(a = -5, b = 7))
```

``` r
delete_function(func)
```

## Contributing

If you want to get involved, start by opening an issue. Once you're ready to start working on the code, fork the repository and submit a pull request. 

If you are changing functionality or adding any new functionality, you _must_ add tests. 

Make sure `R CMD check` passes before you submit the pull request for review.

-----

[![cloudyr project
logo](http://i.imgur.com/JHS98Y7.png)](https://github.com/cloudyr)
