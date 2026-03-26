# Helpers --------------------------------------------------------------------

imgs <- function() {
  c(
    system.file("extdata/rectLight.png", package = "hexsession"),
    system.file("extdata/rectMed.png",   package = "hexsession"),
    system.file("extdata/rectDark.png",  package = "hexsession")
  )
}

# Output file ----------------------------------------------------------------

test_that("make_tile writes _hexout.html to the specified output_dir", {
  out_dir <- withr::local_tempdir()
  make_tile(local_images = imgs(), output_dir = out_dir)

  expect_true(file.exists(file.path(out_dir, "temp_hexsession", "_hexout.html")))
})

test_that("make_tile returns the path to _hexout.html (invisibly)", {
  out_dir <- withr::local_tempdir()
  result  <- make_tile(local_images = imgs(), output_dir = out_dir)

  expect_equal(result, file.path(out_dir, "temp_hexsession", "_hexout.html"))
})

test_that("make_tile emits a message containing the output path", {
  out_dir  <- withr::local_tempdir()
  expected <- file.path(out_dir, "temp_hexsession", "_hexout.html")

  expect_message(
    make_tile(local_images = imgs(), output_dir = out_dir),
    regexp = "Tile saved to:"
  )
})

# HTML content ---------------------------------------------------------------

test_that("make_tile output HTML contains inlined JS (data URI for images)", {
  out_dir  <- withr::local_tempdir()
  make_tile(local_images = imgs(), output_dir = out_dir)

  html <- paste(
    readLines(file.path(out_dir, "temp_hexsession", "_hexout.html"), warn = FALSE),
    collapse = "\n"
  )

  expect_match(html, "data:image/png;base64,")
})

test_that("make_tile output HTML contains the .main container div", {
  out_dir <- withr::local_tempdir()
  make_tile(local_images = imgs(), output_dir = out_dir)

  html <- paste(
    readLines(file.path(out_dir, "temp_hexsession", "_hexout.html"), warn = FALSE),
    collapse = "\n"
  )

  expect_match(html, 'class="main"')
})

test_that("make_tile sets darkMode = true in the JS when dark_mode = TRUE", {
  out_dir <- withr::local_tempdir()
  make_tile(local_images = imgs(), output_dir = out_dir, dark_mode = TRUE)

  html <- paste(
    readLines(file.path(out_dir, "temp_hexsession", "_hexout.html"), warn = FALSE),
    collapse = "\n"
  )

  expect_match(html, "const darkMode = true")
})

test_that("make_tile sets darkMode = false in the JS when dark_mode = FALSE", {
  out_dir <- withr::local_tempdir()
  make_tile(local_images = imgs(), output_dir = out_dir, dark_mode = FALSE)

  html <- paste(
    readLines(file.path(out_dir, "temp_hexsession", "_hexout.html"), warn = FALSE),
    collapse = "\n"
  )

  expect_match(html, "const darkMode = false")
})

# Invalid inputs -------------------------------------------------------------

test_that("make_tile returns an HTML object when no valid images are supplied", {
  out_dir <- withr::local_tempdir()
  result  <- make_tile(local_images = "/nonexistent.png", output_dir = out_dir)

  expect_s3_class(result, "html")
})
