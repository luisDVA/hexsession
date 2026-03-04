test_that("col_arrange returns a character vector the same length as input", {
  img1 <- system.file("extdata", "rectLight.png", package = "hexsession")
  img2 <- system.file("extdata", "rectMed.png",   package = "hexsession")
  img3 <- system.file("extdata", "rectDark.png",  package = "hexsession")

  result <- col_arrange(c(img1, img2, img3))

  expect_type(result, "character")
  expect_length(result, 3)
})

test_that("col_arrange output contains the same paths as the input", {
  img1 <- system.file("extdata", "rectLight.png", package = "hexsession")
  img2 <- system.file("extdata", "rectMed.png",   package = "hexsession")
  img3 <- system.file("extdata", "rectDark.png",  package = "hexsession")
  imgs <- c(img1, img2, img3)

  result <- col_arrange(imgs)

  expect_setequal(result, imgs)
})

test_that("col_arrange sorts dark-to-light when given known test images", {
  img_light <- system.file("extdata", "rectLight.png", package = "hexsession")
  img_med   <- system.file("extdata", "rectMed.png",   package = "hexsession")
  img_dark  <- system.file("extdata", "rectDark.png",  package = "hexsession")

  # Pass in reverse order; expect dark first, light last after sorting
  result <- col_arrange(c(img_light, img_med, img_dark))

  expect_equal(result[1], img_dark)
  expect_equal(result[3], img_light)
})

test_that("col_arrange works with a single image", {
  img <- system.file("extdata", "rectLight.png", package = "hexsession")
  result <- col_arrange(img)

  expect_equal(result, img)
})
