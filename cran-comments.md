## R CMD check results

0 errors | 0 warnings | 0 notes

winbuilder OK 

## Rhub v2 checks: All OK

Test environments:  

linux x86_64-pc-linux-gnu Ubuntu 24.04.3 LTS - Ubuntu 13.3.0-6ubuntu2~24.04.01  
  
Windows Server 2022 x64 (build 26100) - x86_64-w64-mingw32  

macOS Sequoia 15.7.4 aarch64-apple-darwin23   


## Interactive and system-dependent functions

Three exported functions (`make_tile()`, `snap_tile()`, `generate_hexsession_js()`)
require external software at runtime: a 'Quarto' installation for HTML rendering and
a Chromium-based web browser (e.g., Chrome, Chromium, Opera, or Vivaldi) accessed via
'chromote' for screenshots.

Examples for `make_tile()` are guarded with `@examplesIf nzchar(Sys.which("quarto"))`,
so they are skipped in environments where Quarto is not installed. Examples for
`snap_tile()` additionally require a pre-existing HTML tile file and a Chromium
browser, and are guarded accordingly. On CRAN check servers where Quarto is not
available, both sets of examples will be skipped.

## Changes for first resubmission

* Replaced `\dontrun{}` with `\donttest{}`/`@examplesIf` throughout, as requested.
* `cat()` calls in `snap_tile()` replaced with `message()` and `warning()`.
* `installed.packages()` in `get_pkg_data()` replaced with `find.package()` as
  recommended in the `installed.packages()` help page.

## Changes for third resubmission

* `make_tile()` and `snap_tile()` now accept an `output_dir` parameter
  (default: `tempdir()`) so that intermediate HTML and supporting files are
  no longer written to the user's working directory by default. Users who wish
  to keep the output HTML in their project can pass `output_dir = getwd()`.
  The returned path and a `message()` always show the exact file location.
* Fixed the `@examplesIf` guard in `snap_tile()`: `chromote::find_chrome()`
  returns `NA` (not an error) when no browser is found, causing `nzchar(NA)`
  to propagate `NA` into the `if()` condition and crash the example with
  "missing value where TRUE/FALSE needed". Wrapped in `isTRUE()` so the
  condition safely evaluates to `FALSE` when no browser is available.


