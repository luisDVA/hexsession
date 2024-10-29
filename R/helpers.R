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
#' @details
#' Images in svg format will be converted to png. When no image matches 'logo'
#' in the file name the used is will be prompted to select likely logos.
find_imgpaths <- function(pkgnames) {
  lapply(pkgnames, function(x) {
    img_files <- list.files(system.file(package = x),
      pattern = "\\.png$|\\.jpg$|\\.svg$",
      recursive = TRUE,
      full.names = TRUE
    )

    # Convert SVG to PNG if necessary
    img_files <- lapply(img_files, function(file) {
      if (tools::file_ext(file) == "svg") {
        # Create a new filename with "converted" prefix
        file_dir <- tempdir()
        file_name <- basename(file)
        new_file_name <- paste0("converted_", tools::file_path_sans_ext(file_name), ".png")
        png_file <- file.path(file_dir, new_file_name)

        # Convert SVG to PNG

          magick::image_write(
            magick::image_read_svg(file),
            png_file, format = "png")

        return(png_file)
      }
      return(file)
    })

    unlist(img_files)
  })
}
#' Find logo paths
#' @param imagepaths List of image paths
#' @return A vector of logo paths
find_logopaths <- function(imagepaths){
  logopaths <- purrr::map(imagepaths, function(x) {
    logo_matches <- x[grepl("logo", x, ignore.case = TRUE)]

    if (length(logo_matches) == 0 && length(x) > 0) {
      choices <- c(basename(x), "None of the above")

      choice <- utils::menu(
        choices = choices,
        title = "No images match 'logo'. Please select the image with the package logo:"
      )

      if (choice > 0 && choice <= length(x)) {
        return(x[choice])
      } else {
        return(NA_character_)
      }
    } else if (length(logo_matches) > 0) {
      return(logo_matches[1])
    } else {
      return(NA_character_)
    }
  })
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
