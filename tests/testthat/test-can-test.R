context("can test")

test_that("can add 1+1", {

  expect_equal(1+1,2) })

test_that("can not add 1+1", {
  expect_false(1+1==3) })
