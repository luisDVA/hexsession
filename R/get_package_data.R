#' Get package logos and urls
#'
#' @return A list with paths to logos and URLs for loaded packages
#' @export
get_pkg_data <- function() {
  attached_pkgs <- getLoaded()
  imgpaths <- find_imgpaths(attached_pkgs)
  logopaths <- find_logopaths(imgpaths, pkgnames=attached_pkgs)
  pendingLogos <- make_missingLogos(attached_pkgs, logopaths)
  logopaths[is.na(logopaths)] <- pendingLogos
  urlsForlinks <- pkgurls(attached_pkgs)

  list(logopaths = logopaths, urls = urlsForlinks)
}
