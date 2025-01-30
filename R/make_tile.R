#' Generate tile of package logos
#'
#' @param packages Character vector of package names to include (default: NULL, which uses loaded packages)
#' @param dark_mode Draw the tile on a dark background?
#' @param local_images Optional character vector of local image paths to add to the tile
#' @param local_urls Optional character vector of URLs for each of the local images passed
#' @return Path to the output file
#' @importFrom jsonlite toJSON
#' @importFrom base64enc base64encode
#' @export
make_tile <- function(packages=NULL, local_images=NULL, local_urls=NULL, dark_mode=FALSE) {
  temp_dir <- file.path(getwd(), "temp_hexsession")
  dir.create(temp_dir, showWarnings = FALSE)

  package_data <- get_pkg_data(packages)

  all_logopaths <- c(package_data$logopaths, local_images)
  all_urls <- c(package_data$urls, local_urls)

  if (length(all_urls) < length(all_logopaths)) {
    all_urls <- c(all_urls, rep(NA, length(all_logopaths) - length(all_urls)))
  } else if (length(all_urls) > length(all_logopaths)) {
    all_urls <- all_urls[1:length(all_logopaths)]
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

  if (isTRUE(getOption("knitr.in.progress"))) {
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