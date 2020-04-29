test_that("lambdaHTTP works", {
  skip(
    paste(
      "This test does not work yet except when run manually,",
      "and I don't know why."
    )
  )

  # For these tests, we're still using mocks, but something closer to the real
  # response.
  library(vcr)
  vcr::vcr_configure(
    dir = here::here("tests", "testthat"),
    allow_unused_http_interactions = FALSE,
    record = "none"
  )

  expect_warning(
    vcr::use_cassette(
      "account_httr",
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
      },
      record = "none"
    ),
    "partial match"
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
