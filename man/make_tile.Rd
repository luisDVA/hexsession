% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/make_tile.R
\name{make_tile}
\alias{make_tile}
\title{Generate tile of package logos}
\usage{
make_tile(
  packages = NULL,
  local_images = NULL,
  local_urls = NULL,
  dark_mode = FALSE,
  color_arrange = FALSE
)
}
\arguments{
\item{packages}{Character vector of package names to include (default: NULL, which uses loaded packages)}

\item{local_images}{Optional character vector of local image paths to add to the tile}

\item{local_urls}{Optional character vector of URLs for each of the local images passed}

\item{dark_mode}{Draw the tile on a dark background?}

\item{color_arrange}{Logical, whether to arrange the images by color along the 'Lab' color space (defaults to FALSE)}
}
\value{
Path to the output file
}
\description{
This function returns an interactive html tile view of the packages either
listed in the \code{packages} option, or all of the loaded packages. When rendered
interactively, the result is output in the viewer. When rendered in Quarto or
RMarkdown, the tile becomes part of the rendered html. If local images are provided,
only these images will be used, excluding loaded packages.
}
