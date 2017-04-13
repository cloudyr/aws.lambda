# AWS Lambda Client Package #

**aws.lambda** is a simple client package for the [Amazon Web Services (AWS) Lambda API](https://aws.amazon.com/lambda/).

To use the package, you will need an AWS account and enter your credentials into R. Your keypair can be generated on the [IAM Management Console](https://aws.amazon.com/) under the heading *Access Keys*. Note that you only have access to your secret key once. After it is generated, you need to save it in a secure location. New keypairs can be generated at any time if yours has been lost, stolen, or forgotten. 

By default, all **cloudyr** packages look for the access key ID and secret access key in environment variables. You can also use this to specify a default region or a temporary "session token". For example:

```R
Sys.setenv("AWS_ACCESS_KEY_ID" = "mykey",
           "AWS_SECRET_ACCESS_KEY" = "mysecretkey",
           "AWS_DEFAULT_REGION" = "us-east-1",
           "AWS_SESSION_TOKEN" = "mytoken")
```

These can alternatively be set on the command line prior to starting R or via an `Renviron.site` or `.Renviron` file, which are used to set environment variables in R during startup (see `? Startup`).

If you work with multiple AWS accounts, another option that is consistent with other Amazon SDKs is to create [a centralized `~/.aws/credentials` file](https://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs), containing credentials for multiple accounts. You can then use credentials from this file on-the-fly by simply doing:

```R
# use your 'default' account credentials
aws.signature::use_credentials()

# use an alternative credentials profile
aws.signature::use_credentials(profile = "bob")
```

Temporary session tokens are stored in environment variable `AWS_SESSION_TOKEN` (and will be stored there by the `use_credentials()` function). The [aws.iam package](https://github.com/cloudyr/aws.iam/) provides an R interface to IAM roles and the generation of temporary session tokens via the security token service (STS).



## Code Examples ##

The package is still under rapid development, but a simple and literal "Hello, world!" example can be found by doing the following:


```r
library("aws.lambda")

# 'hello world!' example code
hello <- system.file("templates", "helloworld.js", package = "aws.lambda")

# get IAM role for Lambda execution
requireNamespace("aws.iam")
id <- aws.iam::get_caller_identity()[["Account"]]
role <- paste0("arn:aws:iam::", id, ":role/lambda_basic_execution")

func <- create_function(name = "helloworld", func = hello, 
                        handler = "helloworld.handler", role = role)

# invoke function
invoke_function(func)
```

```
## [1] "Hello, world!"
```

Obviously this is a trivial lambda function, but the point is that basically anything (in node.js, python, or java) could be written into the "deployment package" and called in this way.

## Installation ##

[![CRAN](http://www.r-pkg.org/badges/version/aws.lambda)](http://cran.r-project.org/package=aws.lambda)
![Downloads](https://cranlogs.r-pkg.org/badges/aws.lambda)
[![Build Status](https://travis-ci.org/cloudyr/aws.lambda.png?branch=master)](https://travis-ci.org/cloudyr/aws.lambda) 
[![codecov.io](http://codecov.io/github/cloudyr/aws.lambda/coverage.svg?branch=master)](http://codecov.io/github/cloudyr/aws.lambda?branch=master)

This package is not yet on CRAN. To install the latest development version you can install from the cloudyr drat repository:

```R
# latest stable version
install.packages("aws.s3", repos = c("cloudyr" = "http://cloudyr.github.io/drat"))
```

To install the latest development version from GitHub, run the following:

```R
if (!require("ghit")){
    install.packages("ghit")
}
ghit::install_github("cloudyr/aws.lambda")
```


---
[![cloudyr project logo](http://i.imgur.com/JHS98Y7.png)](https://github.com/cloudyr)
