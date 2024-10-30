#' Generate tile of package logos
#'
#' @param dark_mode Draw the tile on a dark background?
#' @param packages Character vector of package names to include (default: NULL, which uses loaded packages)
#' @return Path to the output file
#' @importFrom jsonlite toJSON
#' @importFrom base64enc base64encode
#' @export
make_tile <- function(dark_mode=FALSE, packages=NULL) {
# Create a temporary directory in the current working directory
temp_dir <- file.path(getwd(), "temp_hexsession")
dir.create(temp_dir, showWarnings = FALSE)

# Generate package data and save to temporary file in the temp directory
package_data <- get_pkg_data(packages)
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
