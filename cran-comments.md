## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Interactive and system-dependent functions

Several exported functions (`make_tile()`, `snap_tile()`, `generate_hexsession_js()`)
require external software at runtime: a 'Quarto' installation for HTML rendering and
a Chromium-based web browser (e.g., Chrome, Chromium, Opera, or Vivaldi) accessed via
'chromote' for screenshots. All examples for these functions are wrapped in `\dontrun{}`
as they cannot be run in a standard check environment.


