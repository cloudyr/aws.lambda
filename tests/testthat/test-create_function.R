test_that("Can create a function", {
  # Note: We're assuming the API doesn't change. That assumption will be tested
  # outside the normal test suite.
  mockery::stub(
    where = create_function,
    what = "lambdaHTTP",
    how = list
  )
  role <- "my_fake_role"

  test_result <- create_function(
    name = "matrix",
    func = "s3://fake_bucket/for_testing",
    handler = "matrix.get_col",
    role = role,
    runtime = "provided",
    layers = c(
      "arn:aws:lambda:us-east-1:131329294410:layer:r-runtime-3_6_0:13",
      "arn:aws:lambda:us-east-1:131329294410:layer:r-recommended-3_6_0:13"
    ),
    timeout = 12L,
    description = "A function description"
  )
  expected_result <- list(
    verb = "POST",
    action = "/2015-03-31/functions",
    body = list(
      Code = list(
        S3Bucket = "fake_bucket",
        S3Key = "for_testing"
      ),
      FunctionName = "matrix",
      Handler = "matrix.get_col",
      Role = role,
      Runtime = "provided",
      Description = "A function description",
      Timeout = 12L,
      Layers = list(
        "arn:aws:lambda:us-east-1:131329294410:layer:r-runtime-3_6_0:13",
        "arn:aws:lambda:us-east-1:131329294410:layer:r-recommended-3_6_0:13"
      )
    )
  )
  expect_identical(test_result, expected_result)

  expect_error(
    create_function(
      name = "matrix",
      func = "does_not_exist",
      handler = "matrix.get_col",
      role = "my_fake_role",
      runtime = "provided",
      layers = c(
        "arn:aws:lambda:us-east-1:131329294410:layer:r-runtime-3_6_0:13",
        "arn:aws:lambda:us-east-1:131329294410:layer:r-recommended-3_6_0:13"
      )
    ),
    regexp = "not found"
  )
})

test_that("update_function_code works", {
  mockery::stub(
    where = update_function_code,
    what = "lambdaHTTP",
    how = list
  )
  test_result <- update_function_code(
    name = "my_function",
    func = "s3://fake_bucket/updated"
  )
  expected_result <- list(
    verb = "PUT",
    action = "/2015-03-31/functions/my_function/code",
    body = list(
      S3Bucket = "fake_bucket",
      S3Key = "updated"
    )
  )
  expect_identical(test_result, expected_result)
})

test_that("update_function_config works", {
  mockery::stub(
    where = update_function_config,
    what = "lambdaHTTP",
    how = list
  )
  test_result <- update_function_config(
    name = "my_function",
    description = "A new description",
    handler = "new.handler",
    role = "a new role",
    runtime = "nodejs12.x",
    timeout = 12L
  )
  expected_result <- list(
    verb = "PUT",
    action = "/2015-03-31/functions/my_function/configuration",
    body = list(
      Description = "A new description",
      Handler = "new.handler",
      Role = "a new role",
      Runtime = "nodejs12.x",
      Timeout = 12L
    )
  )
  expect_identical(test_result, expected_result)
})

test_that("publish_function_version works", {
  mockery::stub(
    where = publish_function_version,
    what = "lambdaHTTP",
    how = list
  )
  test_result <- publish_function_version(
    name = "my_function",
    description = "A new version"
  )
  expected_result <- list(
    verb = "POST",
    action = "/2015-03-31/functions/my_function/versions",
    body = list(Description = "A new version")
  )
  expect_identical(test_result, expected_result)
})
