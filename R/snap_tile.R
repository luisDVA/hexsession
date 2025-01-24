#' Take screenshot of html image tile
#'
#' @param output_path Path to image file
#' @param screen_width Width of the browser window
#' @param screen_height Height of the browser window
#' @param dark_mode Is the tile being saved dark or light mode?
#' @return Path to the saved image
#' @export
snap_tile <- function(output_path,
                      screen_width = 800,
                      screen_height = 700,
                      dark_mode = FALSE) {

  b_color <- if(dark_mode == TRUE) {
    "black"
  } else "white"

  html_path <- "temp_hexsession/hexout.html"

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

  # Browser session
  b <- chromote::ChromoteSession$new(height = screen_height, width = screen_width)

  # Open the hex tile
  b$Page$navigate(paste0("file://", normalizePath(html_path)))
  Sys.sleep(1)  # breathe

  # screenshot
  tryCatch({
    screenshot(b, selector = "#quarto-content")
  }, error = function(e) {
    cat("Error taking screenshot:", conditionMessage(e), "\n")
  })

  # post process
  tryCatch({
    magick::image_read(temppath) |>
      magick::image_trim() |>
      magick::image_border(b_color, "10x10") |>
      magick::image_shadow() |>
      magick::image_write(output_path, format = "png",
                          density = 300)

    cat("Image processed and saved to:", output_path, "\n")
  }, error = function(e) {
    cat("Could not process screenshot:", conditionMessage(e), "\n")
  })

  b$close()

}
