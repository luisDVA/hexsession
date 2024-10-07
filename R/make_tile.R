#' Generate tile of package logos
#'
#' @return Path to the output file.
#' @importFrom jsonlite toJSON
#' @importFrom base64enc base64encode
#' @export
make_tile <- function() {

# Create a temporary directory in the current working directory
    temp_dir <- file.path(getwd(), "temp_hexsession")
    dir.create(temp_dir, showWarnings = FALSE)

    # Generate package data and save to temporary file in the temp directory
    package_data <- get_pkg_data()
    temp_file <- file.path(temp_dir, "package_data.rds")
    saveRDS(package_data, temp_file)

    # Get the path to the Quarto template
    template_path <- system.file("templates", "hexout.qmd", package = "hexsession")

    # Copy the template to the temp directory
    file.copy(template_path, file.path(temp_dir, "hexout.qmd"), overwrite = TRUE)

    # Build and run the Quarto cli render call
    quarto_call <- sprintf(
      'quarto render "%s"',
      file.path(temp_dir, "hexout.qmd")
    )
    system(quarto_call)

    viewer <- getOption("viewer")
    viewer("temp_hexsession/hexout.html")
}
