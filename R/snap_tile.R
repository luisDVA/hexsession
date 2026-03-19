#' Take screenshot of html image tile
#'
#' @param output_path Path to image file
#' @param screen_width Width of the browser window
#' @param screen_height Height of the browser window
#' @param dark_mode Is the tile being saved dark or light mode?
#' @param output_dir Directory where `make_tile()` wrote its files.
#'   Must match the `output_dir` used in the preceding `make_tile()` call.
#'   Defaults to `tempdir()` to match `make_tile()`'s default.
#' @return Path to the saved PNG image (the value of `output_path`).
#'
#' @examplesIf file.exists(file.path(tempdir(), "temp_hexsession", "_hexout.html")) && isTRUE(nzchar(tryCatch(chromote::find_chrome(), error = function(e) "")))
#' snap_tile(tempfile(fileext = ".png"))
#'
#' @export
snap_tile <- function(
  output_path,
  screen_width = 800,
  screen_height = 700,
  dark_mode = FALSE,
  output_dir = tempdir()
) {
  b_color <- if (dark_mode == TRUE) {
    "black"
  } else {
    "white"
  }

  html_path <- file.path(output_dir, "temp_hexsession", "_hexout.html")

  # Check for hex tile HTML file
  if (!file.exists(html_path)) {
    stop("No file to capture. Did you create your tile of logos?")
  }

  temppath <- tempfile(fileext = ".png")

  screenshot <- function(b, selector) {
    b$screenshot(
      temppath,
      selector = selector,
      scale = 2,
      delay = 2
    )
  }

  # Browser session - create explicit Chromote instance for clean shutdown
  chr <- chromote::Chromote$new()
  b <- chr$new_session(height = screen_height, width = screen_width)

  # Open the hex tile
  b$Page$navigate(paste0("file://", normalizePath(html_path)))
  Sys.sleep(1) # breathe

  # screenshot
  tryCatch(
    {
      screenshot(b, selector = "#quarto-content")
    },
    error = function(e) {
      warning("Error taking screenshot: ", conditionMessage(e))
    }
  )

  # post process
  tryCatch(
    {
      magick::image_read(temppath) |>
        magick::image_trim() |>
        magick::image_border(b_color, "10x10") |>
        magick::image_shadow() |>
        magick::image_write(output_path, format = "png", density = 300)

      message("Image saved to: ", output_path)
    },
    error = function(e) {
      warning("Could not process screenshot: ", conditionMessage(e))
    }
  )

  b$close()
  chr$close()

  # Close any remaining supervisor FIFOs from chromote/processx
  cons <- showConnections(all = TRUE)
  if (nrow(cons) > 0) {
    fifo_ids <- rownames(cons)[
      cons[, "class"] == "fifo" &
      grepl("supervisor", cons[, "description"])
    ]
    for (id in fifo_ids) {
      try(close(getConnection(as.integer(id))), silent = TRUE)
    }
  }
}
