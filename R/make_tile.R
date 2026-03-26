#' Generate tile of package logos
#'
#' @description
#' Creates and returns an interactive html tile of the packages either listed in the `packages` argument, or all the packages attached to the search path. When rendered interactively, the result is output in the viewer. When rendered in Quarto or RMarkdown, the tile becomes part of the rendered html. revealjs presentations are now supported. If local images are provided, only these images will be used, excluding loaded packages.
#'
#' @param packages A character vector of package names to include (defaults to NULL, which uses loaded packages)
#' @param dark_mode Draw the tile on a dark background?
#' @param local_images Optional character vector of local image paths to add to the tile
#' @param local_urls Optional character vector of URLs for each of the local images passed
#' @param color_arrange Logical, whether to arrange the images by color along the 'Lab' color space (defaults to FALSE)
#' @param highlight_mode Logical, dim all images except on hover (defaults to FALSE)
#' @param focus A character vector of package names to highlight, dimming all others (defaults to NULL)
#' @param output_dir Directory where the intermediate js, rds, and HTML outputs are written. Defaults to `tempdir()`. To keep the output HTML in your
#'   project folder, pass `output_dir = getwd()` or any other path. The
#'   returned value and a console message both show the exact file location.
#' @details If an installed package does not have a bundled logo, or if the logo has been added to .Rbuildignore, a generic logo with the name of the package will be created instead. When the function cannot locate a package logo unambiguously, users will be prompted to select one from a list of potential options.
#' @return The path to the output HTML file (invisibly) when called
#'   interactively. A `message()` also prints the location. Returns an
#'   `htmltools` HTML object when rendered inside Quarto or R Markdown.
#'
#' @examples
#' img1 <- system.file("extdata/rectLight.png", package = "hexsession")
#' img2 <- system.file("extdata/rectMed.png", package = "hexsession")
#' img3 <- system.file("extdata/rectDark.png", package = "hexsession")
#' path <- make_tile(local_images = c(img1, img2, img3))
#'
#' @importFrom jsonlite toJSON
#' @importFrom base64enc base64encode
#' @export
#' @details
#' Set the execution options to `output: asis` in Quarto revealjs presentations to enable raw markdown output and adequate rendering of the tiles.
#'
make_tile <- function(
  packages = NULL,
  local_images = NULL,
  local_urls = NULL,
  dark_mode = FALSE,
  color_arrange = FALSE,
  highlight_mode = FALSE,
  focus = NULL,
  output_dir = tempdir()
) {
  temp_dir <- file.path(output_dir, "temp_hexsession")
  dir.create(temp_dir, showWarnings = FALSE)

  if (is.null(local_images)) {
    package_data <- get_pkg_data(packages)
    all_logopaths <- package_data$logopaths
    all_urls <- package_data$urls
    pkg_names <- package_data$packages
  } else {
    all_logopaths <- local_images
    all_urls <- local_urls
    pkg_names <- NULL
  }

  # Validate focus packages if provided
  if (!is.null(focus) && !is.null(pkg_names)) {
    invalid_focus <- focus[!focus %in% pkg_names]
    if (length(invalid_focus) > 0) {
      warning(
        "The following packages in 'focus' are not in the tile: ",
        paste(invalid_focus, collapse = ", ")
      )
      focus <- focus[focus %in% pkg_names]
    }
  }

  # all_urls the same length as all_logopaths
  if (length(all_urls) < length(all_logopaths)) {
    all_urls <- c(all_urls, rep(NA, length(all_logopaths) - length(all_urls)))
  } else if (length(all_urls) > length(all_logopaths)) {
    all_urls <- all_urls[1:length(all_logopaths)]
  }

  # Coerce `all_logopaths` to a character vector

  if (is.list(all_logopaths)) {
    # Use unlist to flatten the list into a character vector.
    all_logopaths <- unlist(all_logopaths, use.names = FALSE)
  }

  # as character for subsequent operations
  all_logopaths <- as.character(all_logopaths)

  # remove NA, empty, and non-existent files.
  valid_indices <- !is.na(all_logopaths) &
    nzchar(all_logopaths) &
    file.exists(all_logopaths)

  all_logopaths <- all_logopaths[valid_indices]
  all_urls <- all_urls[valid_indices] # Align URLs with filtered logopaths
  if (!is.null(pkg_names)) {
    pkg_names <- pkg_names[valid_indices]
  }

  # Arrange images by color if requested and if there are logopaths to arrange
  if (color_arrange && length(all_logopaths) > 0) {
    laborder <- col_arrange(all_logopaths)

    if (!is.null(laborder) && length(laborder) > 0) {
      order_match <- match(all_logopaths, laborder)
      valid_order_indices <- !is.na(order_match)
      all_logopaths <- all_logopaths[valid_order_indices]
      all_urls <- all_urls[valid_order_indices]
      if (!is.null(pkg_names)) {
        pkg_names <- pkg_names[valid_order_indices]
      }

      sorted_indices <- order(match(all_logopaths, laborder))
      all_logopaths <- all_logopaths[sorted_indices]
      all_urls <- all_urls[sorted_indices]
      if (!is.null(pkg_names)) {
        pkg_names <- pkg_names[sorted_indices]
      }
    } else {
      warning("Color arrangement failed. Proceeding without sorting.")
    }
  }

  # Only proceed if there are actual logopaths to work with
  if (length(all_logopaths) > 0) {
    temp_file <- file.path(temp_dir, "package_data.rds")
    saveRDS(list(logopaths = all_logopaths, urls = all_urls, packages = pkg_names), temp_file)

    js_file <- file.path(temp_dir, "hexsession.js")
    generate_hexsession_js(
      all_logopaths,
      all_urls,
      dark_mode,
      js_file,
      highlight_mode,
      pkg_names,
      focus
    )

    # Build HTML directly from template (no Quarto needed)
    html_template_path <- system.file(
      "templates",
      "_hexout_template.html",
      package = "hexsession"
    )
    html_template <- paste(readLines(html_template_path, warn = FALSE), collapse = "
")
    js_content <- paste(readLines(js_file, warn = FALSE), collapse = "
")
    html_out_content <- sub("{{JS_CONTENT}}", js_content, html_template, fixed = TRUE)
    writeLines(html_out_content, file.path(temp_dir, "_hexout.html"))

    in_html_knitr <- isTRUE(getOption("knitr.in.progress")) &&
      requireNamespace("knitr", quietly = TRUE) &&
      tryCatch(knitr::is_html_output(), error = function(e) FALSE)
    if (in_html_knitr) {
      html_content <- readLines(
        file.path(temp_dir, "_hexout.html"),
        warn = FALSE
      )
      body_content <- paste(
        html_content[
          grep("<body.*?>", html_content):grep("</body>", html_content)
        ],
        collapse = "\n"
      )
      body_content <- gsub("</?body.*?>", "", body_content)

      div_content <- sprintf(
        '<div class="hexsession-container">%s</div>',
        body_content
      )

      # Return raw HTML to be embedded
      return(htmltools::HTML(div_content))
    } else if (!isTRUE(getOption("knitr.in.progress"))) {
      html_out <- file.path(temp_dir, "_hexout.html")
      message("Tile saved to: ", html_out)
      viewer <- getOption("viewer")
      if (!is.null(viewer)) {
        viewer(html_out)
      }
      return(invisible(html_out))
    }
  } else {
    return(htmltools::HTML("<p>No valid package logos found to display.</p>"))
  }
}
