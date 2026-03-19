# Changelog

## hexsession 0.1.0

- Initial CRAN submission.
- [`make_tile()`](https://luisdva.github.io/hexsession/reference/make_tile.md)
  and
  [`snap_tile()`](https://luisdva.github.io/hexsession/reference/snap_tile.md)
  gain an `output_dir` parameter (default:
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html)). Previously the
  intermediate HTML and supporting files were written to a
  `temp_hexsession/` folder in the working directory. To restore the old
  behaviour, pass `output_dir = getwd()`. The path to the HTML output is
  always returned by
  [`make_tile()`](https://luisdva.github.io/hexsession/reference/make_tile.md)
  and printed as a message when the viewer is not available.
