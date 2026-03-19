# hexsession 0.1.0

* Initial CRAN submission.
* `make_tile()` and `snap_tile()` gain an `output_dir` parameter (default:
  `tempdir()`). Previously the intermediate HTML and supporting files were
  written to a `temp_hexsession/` folder in the working directory. To restore
  the old behaviour, pass `output_dir = getwd()`. The path to the HTML output
  is always returned by `make_tile()` and printed as a message when the viewer
  is not available.
