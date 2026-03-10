## R CMD check results

0 errors | 0 warnings | 0 notes

## Rhub v2 checks: All OK

Test environments:  

linux x86_64-pc-linux-gnu Ubuntu 24.04.3 LTS - Ubuntu 11.4.0-1ubuntu1~22.04.3  
  
Windows Server 2022 x64 (build 26100) - x86_64-w64-mingw32


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

## Changes for resubmission

* Replaced `\dontrun{}` with `\donttest{}`/`@examplesIf` throughout, as requested.
* `cat()` calls in `snap_tile()` replaced with `message()` and `warning()`.
* `installed.packages()` in `get_pkg_data()` replaced with `find.package()` as
  recommended in the `installed.packages()` help page.


