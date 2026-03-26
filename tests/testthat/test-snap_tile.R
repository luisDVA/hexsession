# snap_tile() -----------------------------------------------------------------
# Chrome-dependent tests are skipped when Chromium is unavailable.

# Error handling -------------------------------------------------------------

test_that("snap_tile stops with informative message when HTML file is missing", {
  out_dir <- withr::local_tempdir()  # empty — no _hexout.html

  expect_error(
    snap_tile(tempfile(fileext = ".png"), output_dir = out_dir),
    regexp = "No tile found at"
  )
})

test_that("snap_tile error mentions the path it looked in", {
  out_dir  <- withr::local_tempdir()
  expected <- file.path(out_dir, "temp_hexsession", "_hexout.html")

  expect_error(
    snap_tile(tempfile(fileext = ".png"), output_dir = out_dir),
    regexp = "temp_hexsession/_hexout\\.html"
  )
})

test_that("snap_tile error asks the user to check output_dir", {
  out_dir <- withr::local_tempdir()

  expect_error(
    snap_tile(tempfile(fileext = ".png"), output_dir = out_dir),
    regexp = "make_tile"
  )
})

# Default output_dir ---------------------------------------------------------

test_that("snap_tile default output_dir is getwd()", {
  # Inspect the formals; no side effects needed
  expect_equal(formals(snap_tile)$output_dir, quote(getwd()))
})


