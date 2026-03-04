# Take screenshot of html image tile

Take screenshot of html image tile

## Usage

``` r
snap_tile(
  output_path,
  screen_width = 800,
  screen_height = 700,
  dark_mode = FALSE
)
```

## Arguments

- output_path:

  Path to image file

- screen_width:

  Width of the browser window

- screen_height:

  Height of the browser window

- dark_mode:

  Is the tile being saved dark or light mode?

## Value

Path to the saved PNG image (the value of `output_path`).

## Examples

``` r
if (FALSE) { # \dontrun{
# First create a tile with make_tile(), then capture it
make_tile(packages = c("ggplot2", "dplyr"))
snap_tile("my_tile.png", screen_width = 1000, screen_height = 800)
} # }
```
