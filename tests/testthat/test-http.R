test_that("lambdaHTTP works", {
  # For these tests, we're still using mocks, but something closer to the real
  # response.

  httptest::with_mock_api(
    {
      mockery::stub(
        where = lambdaHTTP,
        what = "aws.signature::signature_v4_auth",
        how = list(
          BodyHash = "fake_body_hash",
          SignatureHeader = "fake_signature_header"
        )
      )
      test_result <- names(lambdaHTTP(
        verb = "GET",
        action = "/2016-08-19/account-settings"
      ))
    }
  )

  expected_result <- c(
    "AccountLimit",
    "AccountUsage",
    "BlacklistedFeatures",
    "DeprecatedFeaturesAccess",
    "HasFunctionWithDeprecatedRuntime",
    "PreviewFeatures"
  )
  expect_identical(test_result, expected_result)
})
