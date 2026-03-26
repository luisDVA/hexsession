# Generate tile of package logos

Creates and returns an interactive html tile of the packages either
listed in the `packages` argument, or all the packages attached to the
search path. When rendered interactively, the result is output in the
viewer. When rendered in Quarto or RMarkdown, the tile becomes part of
the rendered html. revealjs presentations are now supported. If local
images are provided, only these images will be used, excluding loaded
packages.

## Usage

``` r
make_tile(
  packages = NULL,
  local_images = NULL,
  local_urls = NULL,
  dark_mode = FALSE,
  color_arrange = FALSE,
  highlight_mode = FALSE,
  focus = NULL,
  output_dir = tempdir()
)
```

## Arguments

- packages:

  A character vector of package names to include (defaults to NULL,
  which uses loaded packages)

- local_images:

  Optional character vector of local image paths to add to the tile

- local_urls:

  Optional character vector of URLs for each of the local images passed

- dark_mode:

  Draw the tile on a dark background?

- color_arrange:

  Logical, whether to arrange the images by color along the 'Lab' color
  space (defaults to FALSE)

- highlight_mode:

  Logical, dim all images except on hover (defaults to FALSE)

- focus:

  A character vector of package names to highlight, dimming all others
  (defaults to NULL)

- output_dir:

  Directory where the intermediate js, rds, and HTML outputs are
  written. Defaults to
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html). To keep the
  output HTML in your project folder, pass `output_dir = getwd()` or any
  other path. The returned value and a console message both show the
  exact file location.

## Value

The path to the output HTML file (invisibly) when called interactively.
A [`message()`](https://rdrr.io/r/base/message.html) also prints the
location. Returns an `htmltools` HTML object when rendered inside Quarto
or R Markdown.

## Details

If an installed package does not have a bundled logo, or if the logo has
been added to .Rbuildignore, a generic logo with the name of the package
will be created instead. When the function cannot locate a package logo
unambiguously, users will be prompted to select one from a list of
potential options.

Set the execution options to `output: asis` in Quarto revealjs
presentations to enable raw markdown output and adequate rendering of
the tiles.

## Examples

``` r
img1 <- system.file("extdata/rectLight.png", package = "hexsession")
img2 <- system.file("extdata/rectMed.png", package = "hexsession")
img3 <- system.file("extdata/rectDark.png", package = "hexsession")
path <- make_tile(local_images = c(img1, img2, img3))
#> Tile saved to: /tmp/Rtmp0vUPGK/temp_hexsession/_hexout.html
```
