context("If this test fails we're all doomed.")

test_that("multiplication works", {
  ugly_assignment <- 3
  expect_equal(2 * 2, 4)
})
