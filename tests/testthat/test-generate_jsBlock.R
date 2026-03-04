test_that("generate_hexsession_js writes a file to the specified path", {
  img <- system.file("extdata", "rectLight.png", package = "hexsession")
  out <- withr::local_tempfile(fileext = ".js")

  generate_hexsession_js(
    logopaths = img,
    urls      = "https://example.com",
    dark_mode = FALSE,
    output_js = out
  )

  expect_true(file.exists(out))
})

test_that("generated JS file contains the image data URI", {
  img <- system.file("extdata", "rectLight.png", package = "hexsession")
  out <- withr::local_tempfile(fileext = ".js")

  generate_hexsession_js(
    logopaths = img,
    urls      = "https://example.com",
    dark_mode = FALSE,
    output_js = out
  )

  js_text <- paste(readLines(out), collapse = "\n")
  expect_match(js_text, "data:image/png;base64,")
})

test_that("generated JS file sets darkMode to false in light mode", {
  img <- system.file("extdata", "rectLight.png", package = "hexsession")
  out <- withr::local_tempfile(fileext = ".js")

  generate_hexsession_js(
    logopaths = img,
    urls      = NA_character_,
    dark_mode = FALSE,
    output_js = out
  )

  js_text <- paste(readLines(out), collapse = "\n")
  expect_match(js_text, "const darkMode = false")
})

test_that("generated JS file sets darkMode to true in dark mode", {
  img <- system.file("extdata", "rectLight.png", package = "hexsession")
  out <- withr::local_tempfile(fileext = ".js")

  generate_hexsession_js(
    logopaths = img,
    urls      = NA_character_,
    dark_mode = TRUE,
    output_js = out
  )

  js_text <- paste(readLines(out), collapse = "\n")
  expect_match(js_text, "const darkMode = true")
})

test_that("generate_hexsession_js handles NA URLs without error", {
  img <- system.file("extdata", "rectLight.png", package = "hexsession")
  out <- withr::local_tempfile(fileext = ".js")

  expect_no_error(
    generate_hexsession_js(
      logopaths = img,
      urls      = NA_character_,
      dark_mode = FALSE,
      output_js = out
    )
  )
})
