#' Take screenshot of html image tile
#'
#' @param output_path Path to image file
#' @param screen_width Width of the browser window
#' @param screen_height Height of the browser window
#' @param dark_mode Is the tile being saved dark or light mode?
#' @param output_dir Directory where `make_tile()` wrote its files.
#'   Must match the `output_dir` used in the preceding `make_tile()` call.
#'   Defaults to `getwd()`. To snap a tile written to `tempdir()`, pass
#'   `output_dir = tempdir()` explicitly.
#' @return Path to the saved PNG image (the value of `output_path`).
#'
#' @examplesIf file.exists(file.path(getwd(), "temp_hexsession", "_hexout.html")) && isTRUE(nzchar(tryCatch(chromote::find_chrome(), error = function(e) "")))
#' snap_tile(tempfile(fileext = ".png"))
#'
#' @export
snap_tile <- function(
  output_path,
  screen_width = 800,
  screen_height = 700,
  dark_mode = FALSE,
  output_dir = getwd()
) {
  b_color <- if (dark_mode == TRUE) "black" else "white"

  html_path <- file.path(output_dir, "temp_hexsession", "_hexout.html")

  if (!file.exists(html_path)) {
    stop(
      "No tile found at: ", html_path,
      "\nDid you run make_tile() with the same output_dir?"
    )
  }
  message("Snapping tile from: ", html_path)

  temppath <- tempfile(fileext = ".png")

  # Record open connections before starting browser (for check cleanup)
  pre_con_ids <- rownames(showConnections(all = TRUE))

  b <- chromote::ChromoteSession$new(height = screen_height, width = screen_width)

  b$Page$navigate(paste0("file://", normalizePath(html_path)))
  Sys.sleep(1)

  tryCatch({
    # Get the real content dimensions; add buffer for absolutely-positioned
    # elements (e.g. the attribution div that sits 44px below .main)
    metrics <- b$Page$getLayoutMetrics()
    content_w <- as.integer(ceiling(metrics$contentSize$width))
    content_h <- as.integer(ceiling(metrics$contentSize$height)) + 100L

    # Resize viewport to match full content before capturing
    b$Emulation$setDeviceMetricsOverride(
      width  = content_w,
      height = content_h,
      deviceScaleFactor = 2L,  # 2x resolution, equivalent to scale = 2
      mobile = FALSE
    )
    Sys.sleep(0.3)

    # Capture directly via CDP; avoids selector clipping issues
    raw <- b$Page$captureScreenshot(format = "png")
    writeBin(base64enc::base64decode(raw$data), temppath)
  },
  error = function(e) warning("Error taking screenshot: ", conditionMessage(e))
  )

  tryCatch(
    {
      magick::image_read(temppath) |>
        magick::image_trim() |>
        magick::image_border(b_color, "10x10") |>
        magick::image_shadow() |>
        magick::image_write(output_path, format = "png", density = 300)
      message("Image saved to: ", output_path)
    },
    error = function(e) warning("Could not process screenshot: ", conditionMessage(e))
  )

  b$close()

  # In non-interactive environments (e.g. R CMD check), clean up any new
  # FIFO connections opened by the browser session to avoid "connections left
  # open" errors. In interactive use, Chrome stays running between calls.
  if (!interactive()) {
    post_cons <- showConnections(all = TRUE)
    new_ids <- setdiff(rownames(post_cons), pre_con_ids)
    if (length(new_ids) > 0) {
      fifo_new <- new_ids[post_cons[new_ids, "class"] == "fifo"]
      for (id in fifo_new) {
        try(close(getConnection(as.integer(id))), silent = TRUE)
      }
    }
  }

  invisible(output_path)
}
