
attached_pkgs <- getLoaded()


imgpaths <- find_imgpaths(attached_pkgs)
imgpaths

logopaths <- find_logopaths(imgpaths)
logopaths


pendingLogos <- make_missingLogos()

logopaths[is.na(logopaths)] <- pendingLogos

urlsForlinks <- pkgurls(attached_pkgs)

