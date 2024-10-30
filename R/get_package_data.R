#' Get package data
#' @param packages Character vector of package names (default is NULL, uses loaded packages)
#' @return A list containing logopaths and urls for the packages
get_pkg_data <- function(packages = NULL) {
  if (is.null(packages)) {
    packages <- getLoaded()
  } else {
    # Check if specified packages are installed
    not_installed <- packages[!packages %in% installed.packages()[,"Package"]]
    if (length(not_installed) > 0) {
      stop("The following packages are not installed: ", paste(not_installed, collapse = ", "))
    }
  }

  imagepaths <- find_imgpaths(packages)
  logopaths <- find_logopaths(imagepaths, packages)
  
  # Generate missing logos
  missing <- is.na(logopaths)
  if (any(missing)) {
    generated <- make_missingLogos(packages[missing], logopaths[missing])
    logopaths[missing] <- generated
  }
  
  # Get package URLs
  urls <- sapply(packages, function(pkg) {
    desc <- packageDescription(pkg)
    url <- desc$URL
    if (is.null(url)) {
      paste0("https://cran.r-project.org/package=", pkg)
    } else {
      strsplit(url, ",")[[1]][1]  # Use the first URL if multiple are provided
    }
  })
  
  list(logopaths = logopaths, urls = urls)
}
