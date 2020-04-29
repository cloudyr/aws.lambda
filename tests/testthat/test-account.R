test_that("get_lambda_account works", {
  mockery::stub(
    where = get_lambda_account,
    what = "lambdaHTTP",
    how = list
  )
  test_result <- get_lambda_account()
  expected_result <- structure(
    list(
      verb = "GET",
      action = "/2016-08-19/account-settings"
    ),
    class = "aws_lambda_account"
  )
  expect_identical(test_result, expected_result)
})
