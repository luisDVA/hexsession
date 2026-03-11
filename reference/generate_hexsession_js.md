# Generate JavaScript file for hexsession

Generate JavaScript file for hexsession

## Usage

``` r
generate_hexsession_js(
  logopaths,
  urls,
  dark_mode,
  output_js,
  highlight_mode = FALSE,
  pkg_names = NULL,
  focus = NULL
)
```

## Arguments

- logopaths:

  Vector of image paths

- urls:

  Vector of URLs

- dark_mode:

  Use dark mode, inherited from make_tile

- output_js:

  Path to save the JavaScript file

- highlight_mode:

  Use highlight mode, inherited from make_tile

- pkg_names:

  Vector of package names (optional)

- focus:

  Vector of package names to focus on (optional)

## Value

Called for its side effect; invisibly returns `NULL`. Writes a
JavaScript file to `output_js` containing base64-encoded image data and
dark/light mode CSS variable assignments.

## Examples

``` r
img <- system.file("extdata/rectLight.png", package = "hexsession")
out <- tempfile(fileext = ".js")
generate_hexsession_js(
  logopaths = img,
  urls = "https://example.com",
  dark_mode = FALSE,
  output_js = out
)
```
