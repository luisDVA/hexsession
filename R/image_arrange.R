#' Extract the Most Frequent Color from an Image
#'
#' Internal helper. For a given image path, this functions uses k-means
#' clustering to identify the most dominant color in the image.
#'
#' @param imgpath Character string. File path to the image.
#'
#' @return A data frame with one row containing the RGB values of the dominant color.
#'         The column name is set to the input image path.
#'
#' @importFrom magick image_read image_scale image_data
#' @importFrom stats kmeans
#'
maincolorRGB <- function(imgpath) {
  img <- magick::image_scale(magick::image_read(imgpath), "130")
  imgint <- as.integer(magick::image_data(img, channels = "rgb"))
  img_df <- data.frame(red = c(imgint[,,1]), green = c(imgint[,,2]), blue = c(imgint[,,3]))
  km     <- kmeans(img_df, 5)
  rgbout <- data.frame(km$centers[which.max(km$size),])
  names(rgbout) <- paste(imgpath)
  rgbout
}

#' Arrange Images by Color
#'
#' Takes a vector of image paths, extracts the main color from each image using
#' k-means clustering, converts the colors to the LAB color space, and sorts the
#' images based on the lightness (L) component of their dominant color.
#'
#' @param image_paths Character vector. A vector of file paths to the images.
#'
#' @return A character vector of image paths, sorted by the lightness of their
#'   main color.
#'
#' @importFrom grDevices convertColor
#' @importFrom purrr map
#'
#' @examples
#' img1 <- system.file("extdata/rectLight.png", package = "hexsession")
#' img2 <- system.file("extdata/rectMed.png", package = "hexsession")
#' img3 <- system.file("extdata/rectDark.png", package = "hexsession")
#' sorted_paths <- col_arrange(c(img1,img3,img2))
#'
#' @export
col_arrange <- function(image_paths) {
  # find most common color and convert to rgb
  allrgbspace <- do.call(cbind, purrr::map(image_paths, maincolorRGB))
  # 'Lab' color space
  lab <- convertColor(t(allrgbspace), 'sRGB', 'Lab')
  # sort images by lightness
  image_paths[order(lab[, 'L'])]
}
