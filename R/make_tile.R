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
make_tile <- function(packages=NULL, local_images=NULL,local_urls=NULL, dark_mode=FALSE) {
# Create a temporary directory in the current working directory
temp_dir <- file.path(getwd(), "temp_hexsession")
dir.create(temp_dir, showWarnings = FALSE)

  
# Generate package data and save to temporary file in the temp directory
package_data <- get_pkg_data(packages)

  # Check if local_images is provided and is a character vector
  if (!is.null(local_images) && is.character(local_images)) {
    # Check if local_urls is provided
    if (!is.null(local_urls)) {
      # If local_urls is shorter than local_images, fill with NA
      if (length(local_urls) < length(local_images)) {
        local_urls <- c(local_urls, rep(NA, length(local_images) - length(local_urls)))
      }
    } else {
      # If local_urls is not provided, fill with NA
      local_urls <- rep(NA, length(local_images))
    }
    
    # Add local images and urls to the package data
    package_data$logopaths <- c(package_data$logopaths, local_images)
    package_data$urls <- c(package_data$urls, local_urls)
  }
  
temp_file <- file.path(temp_dir, "package_data.rds")
saveRDS(package_data, temp_file)

# Generate JavaScript file
js_file <- file.path(temp_dir, "hexsession.js")
generate_hexsession_js(package_data$logopaths, package_data$urls, dark_mode, js_file)

# Path to the Quarto template
template_path <- system.file("templates", "hexout.qmd", package = "hexsession")

# Copy the template to the temp directory
file.copy(template_path, file.path(temp_dir, "hexout.qmd"), overwrite = TRUE)

# Build and run the Quarto cli render call
quarto_call <-
      sprintf(
        'quarto render "%s" -P dark_mode:%s',
        file.path(temp_dir, "hexout.qmd"),tolower(as.character(dark_mode))
      )
system(quarto_call)

    viewer <- getOption("viewer")
    viewer("temp_hexsession/hexout.html")
}
