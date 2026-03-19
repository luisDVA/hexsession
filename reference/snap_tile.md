# Take screenshot of html image tile

Take screenshot of html image tile

## Usage

``` r
snap_tile(
  output_path,
  screen_width = 800,
  screen_height = 700,
  dark_mode = FALSE,
  output_dir = tempdir()
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

- output_dir:

  Directory where
  [`make_tile()`](https://luisdva.github.io/hexsession/reference/make_tile.md)
  wrote its files. Must match the `output_dir` used in the preceding
  [`make_tile()`](https://luisdva.github.io/hexsession/reference/make_tile.md)
  call. Defaults to [`tempdir()`](https://rdrr.io/r/base/tempfile.html)
  to match
  [`make_tile()`](https://luisdva.github.io/hexsession/reference/make_tile.md)'s
  default.

## Value

Path to the saved PNG image (the value of `output_path`).

## Examples

``` r
snap_tile(tempfile(fileext = ".png"))
#> Image saved to: /tmp/RtmpWRaRMP/file26be4cde8992.png
```
