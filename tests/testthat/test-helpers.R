# encode_image() ------------------------------------------------------------

test_that("encode_image returns a data URI with the correct prefix", {
  img <- system.file("extdata", "rectLight.png", package = "hexsession")
  result <- encode_image(img)

  expect_type(result, "character")
  expect_match(result, "^data:image/png;base64,")
})

test_that("encode_image result is longer than just the prefix", {
  img <- system.file("extdata", "rectLight.png", package = "hexsession")
  result <- encode_image(img)

  expect_gt(nchar(result), nchar("data:image/png;base64,"))
})

test_that("encode_image warns and returns NULL for a non-existent file", {
  expect_warning(
    result <- encode_image("/nonexistent/path/image.png"),
    regexp = "Error encoding"
  )
  expect_null(result)
})

# pkgurls() -----------------------------------------------------------------

test_that("pkgurls returns a character vector the same length as input", {
  result <- hexsession:::pkgurls(c("base64enc", "jsonlite"))

  expect_type(result, "character")
  expect_length(result, 2)
})

test_that("pkgurls returns NA for packages with no URL field", {
  # 'datasets' ships with R and has no URL in its DESCRIPTION
  result <- hexsession:::pkgurls("datasets")

  expect_true(is.na(result))
})

test_that("pkgurls returns a single URL string (not a multi-URL blob) per package", {
  # jsonlite lists multiple URLs; only the first should be returned
  result <- hexsession:::pkgurls("jsonlite")

  expect_false(grepl(",|\n", result))
})

# getLoaded() ---------------------------------------------------------------

test_that("getLoaded returns a character vector", {
  result <- hexsession:::getLoaded()

  expect_type(result, "character")
})

test_that("getLoaded excludes base R packages and hexsession itself", {
  base_pkgs <- c(
    "stats", "graphics", "grDevices", "utils",
    "datasets", "methods", "base", "hexsession"
  )
  result <- hexsession:::getLoaded()

  expect_false(any(base_pkgs %in% result))
})
