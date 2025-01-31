#' Generate tile of package logos
#'
#' @description
#' This function returns an interactive html tile view of the packages either
#' listed in the `packages` option, or all of the loaded packages. When rendered
#' interactively, the result is output in the viewer. When rendered in Quarto or
#' RMarkdown, the tile becomes part of the rendered html. If local images are provided,
#' only these images will be used, excluding loaded packages.
#'
#' @param packages Character vector of package names to include (default: NULL, which uses loaded packages)
#' @param dark_mode Draw the tile on a dark background?
#' @param local_images Optional character vector of local image paths to add to the tile
#' @param local_urls Optional character vector of URLs for each of the local images passed
#' @param color_arrange Logical, whether to arrange the images by color along the 'Lab' color space (defaults to FALSE)
#' @return Path to the output file
#' @importFrom jsonlite toJSON
#' @importFrom base64enc base64encode
#' @importFrom knitr is_html_output
#' @importFrom htmltools HTML
#' @export
make_tile <- function(packages = NULL, local_images = NULL,
                      local_urls = NULL, dark_mode = FALSE,
                      color_arrange = FALSE) {
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

  # Ensure all_urls is the same length as all_logopaths
  if (length(all_urls) < length(all_logopaths)) {
    all_urls <- c(all_urls, rep(NA, length(all_logopaths) - length(all_urls)))
  } else if (length(all_urls) > length(all_logopaths)) {
    all_urls <- all_urls[1:length(all_logopaths)]
  }

  # Arrange images by color if requested
  if (color_arrange) {
    laborder <- col_arrange(all_logopaths)
    all_logopaths <- all_logopaths[order(match(all_logopaths,laborder))]
    all_urls <- all_urls[order(match(all_logopaths,laborder))]
  }

  temp_file <- file.path(temp_dir, "package_data.rds")
  saveRDS(list(logopaths = all_logopaths, urls = all_urls), temp_file)

  js_file <- file.path(temp_dir, "hexsession.js")
  generate_hexsession_js(all_logopaths, all_urls, dark_mode, js_file)

  template_path <- system.file("templates", "_hexout.qmd", package = "hexsession")
  file.copy(template_path, file.path(temp_dir, "_hexout.qmd"), overwrite = TRUE)

  quarto_call <- sprintf(
    'quarto render "%s" -P dark_mode:%s',
    file.path(temp_dir, "_hexout.qmd"), tolower(as.character(dark_mode))
  )
  system(quarto_call)

  if (isTRUE(getOption("knitr.in.progress")) && knitr::is_html_output()) {
    # Read the HTML content directly
    html_content <- readLines(file.path(temp_dir, "_hexout.html"), warn = FALSE)

    # Extract just the body content
    body_content <- paste(html_content[grep("<body.*?>", html_content):grep("</body>", html_content)], collapse = "\n")
    body_content <- gsub("</?body.*?>", "", body_content)

    # Create a div container with the content
    div_content <- sprintf(
      '<div class="hexsession-container" style="width:100%%; height:100%%; overflow:hidden;">%s</div>',
      body_content
    )

    # Return the HTML content directly
    return(htmltools::HTML(div_content))

  } else if (isFALSE(getOption("knitr.in.progress"))) {
    viewer <- getOption("viewer")
    viewer(file.path(temp_dir, "_hexout.html"))
  }
}
