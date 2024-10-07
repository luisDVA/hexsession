#' Get loaded packages
#' @return A character vector of the attached packages (excludes base packages)
getLoaded <- function() {
  # also exclude hexsession
  basepkgs <- c(
    "stats", "graphics", "grDevices", "utils", "datasets",
    "methods", "base", "hexsession"
  )
  (.packages())[!(.packages()) %in% basepkgs]
}

#' Find image paths
#' @param pkgnames Character vector of package names
#' @return A list of image file paths for each package
find_imgpaths <- function(pkgnames) {
  lapply(pkgnames, function(x) {
    list.files(system.file(package = x),
      pattern = "\\.png$|\\.jpg$|\\.svg$",
      recursive = TRUE,
      full.names = TRUE
    )
  })
}

#' Find logo paths
#' @param imagepaths List of image paths
#' @return A vector of logo paths
find_logopaths <- function(imagepaths) {
  logopaths <- lapply(imagepaths, function(x) x[grepl("logo", x, ignore.case = TRUE)])
  logopaths[lengths(logopaths) == 0] <- NA_character_
  logopaths <- sapply(logopaths, "[[", 1)
  unlist(logopaths)
}

#' Get package URLs
#' @param pkgnames Character vector of package names
#' @importFrom utils packageDescription
#' @return A vector of package URLs
pkgurls <- function(pkgnames) {
  allurls <- purrr::map(pkgnames, \(x) {
    url <- packageDescription(x, fields = "URL")
    if (is.null(url) || all(is.na(url)) || all(url == "")) NA_character_ else url
  })
  splturls <- purrr::map(allurls, \(x) {
    if (all(is.na(x))) NA_character_ else unlist(strsplit(x, ",|\n"))
  })
  purrr::map_chr(splturls, \(x) {
    if (all(is.na(x))) NA_character_ else x[1]
  })
}



#' Encode image to Base64
#' @param file_path Path to an image file
#' @return Base64 encoded string of the image
#' @export
encode_image <- function(file_path) {
  tryCatch(
    {
      encoded <- base64enc::base64encode(file_path)
      ext <- tolower(tools::file_ext(file_path))
      paste0("data:image/", ext, ";base64,", encoded)
    },
    error = function(e) {
      warning(paste("Error encoding file:", file_path, "-", e$message))
      NULL
    }
  )
}

#' Create missing logos
#' @param attached_pkgs Character vector of attached package names
#' @param logopaths Vector of existing logo paths
#' @return Vector of paths to new logos
make_missingLogos <- function(attached_pkgs, logopaths) {
  pending <- attached_pkgs[is.na(logopaths)]
  basehex <- magick::image_read(system.file("extdata", "blankhexsm.png", package = "hexsession"))


  create_logo <- function(pkgname) {
    widthhex <- magick::image_info(basehex)$width

    fig <- magick::image_blank(700, 700) |>
      magick::image_annotate(pkgname, size = 100, color = "white") |>
      magick::image_trim() |>
      magick::image_border("none") |>
      magick::image_resize(paste0(widthhex - 30, "x"))

    magick::image_composite(basehex, fig, operator = "SrcOver", gravity = "center")
  }

  logoimgs <- purrr::map(pending, create_logo)
  imgpaths <- paste0(tempfile(), "_", pending, ".png")
  purrr::walk2(logoimgs, imgpaths, \(x, y) magick::image_write(x, y))
  imgpaths
}
