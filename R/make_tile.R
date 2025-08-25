#' Generate tile of package logos
#'
#' @description
#' Creates and returns an interactive html tile of the packages either listed in the `packages` argument, or all the packages attached to the search path. When rendered interactively, the result is output in the viewer. When  rendered in Quarto or RMarkdown, the tile becomes part of the rendered html. revealjs presentations are currently not supported. If local images are provided,
#' only these images will be used, excluding loaded packages.
#'
#' @param packages Character vector of package names to include (default: NULL, which uses loaded packages)
#' @param dark_mode Draw the tile on a dark background?
#' @param local_images Optional character vector of local image paths to add to the tile
#' @param local_urls Optional character vector of URLs for each of the local images passed
#' @param color_arrange Logical, whether to arrange the images by color along the 'Lab' color space (defaults to FALSE)
#' @details If an installed package does not have a bundled logo, or if the logo has been added to .Rbuildignore, a generic logo with the name of the package will be created instead. When the function cannot locate a package logo unambiously, users will be prompted to select one.
#' @return Path to the output file
#' @importFrom jsonlite toJSON
#' @importFrom base64enc base64encode
#' @importFrom knitr is_html_output
#' @export
#' @details
#' Set the execution options to `output: asis` in Quarto revealjs presentations to enable raw markdown output and adequate rendering of the tiles.
#'
make_tile <- function(
  packages = NULL,
  local_images = NULL,
  local_urls = NULL,
  dark_mode = FALSE,
  color_arrange = FALSE
) {
  temp_dir <- file.path(getwd(), "temp_hexsession")
  dir.create(temp_dir, showWarnings = FALSE)

  if (is.null(local_images)) {
    package_data <- get_pkg_data(packages)
    all_logopaths <- package_data$logopaths
    all_urls <- package_data$urls
  } else {
    all_logopaths <- local_images
    all_urls <- local_urls
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

  # Arrange images by color if requested and if there are logopaths to arrange
  if (color_arrange && length(all_logopaths) > 0) {
    laborder <- col_arrange(all_logopaths)

    if (!is.null(laborder) && length(laborder) > 0) {
      order_match <- match(all_logopaths, laborder)
      valid_order_indices <- !is.na(order_match)
      all_logopaths <- all_logopaths[valid_order_indices]
      all_urls <- all_urls[valid_order_indices]

      sorted_indices <- order(match(all_logopaths, laborder))
      all_logopaths <- all_logopaths[sorted_indices]
      all_urls <- all_urls[sorted_indices]
    } else {
      warning("Color arrangement failed. Proceeding without sorting.")
    }
  }

  # Only proceed if there are actual logopaths to work with
  if (length(all_logopaths) > 0) {
    temp_file <- file.path(temp_dir, "package_data.rds")
    saveRDS(list(logopaths = all_logopaths, urls = all_urls), temp_file)

    js_file <- file.path(temp_dir, "hexsession.js")
    generate_hexsession_js(all_logopaths, all_urls, dark_mode, js_file)

    template_path <- system.file(
      "templates",
      "_hexout.qmd",
      package = "hexsession"
    )
    file.copy(
      template_path,
      file.path(temp_dir, "_hexout.qmd"),
      overwrite = TRUE
    )

    quarto_call <- sprintf(
      'quarto render "%s" -P dark_mode:%s',
      file.path(temp_dir, "_hexout.qmd"),
      tolower(as.character(dark_mode))
    )
    system(quarto_call)

    if (isTRUE(getOption("knitr.in.progress")) && knitr::is_html_output()) {
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
    } else if (isFALSE(getOption("knitr.in.progress"))) {
      viewer <- getOption("viewer")
      viewer(file.path(temp_dir, "_hexout.html"))
    }
  } else {
    return(htmltools::HTML("<p>No valid package logos found to display.</p>"))
  }
}
