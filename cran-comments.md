## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Rhub v2 checks: ALL OK

Test environments:

linux x86_64-pc-linux-gnu Ubuntu 24.04.3 LTS
macOS macOS Sequoia 15.7.4
Windows Server 2022 x64 (build 26100)


## Interactive and system-dependent functions

Several exported functions (`make_tile()`, `snap_tile()`, `generate_hexsession_js()`)
require external software at runtime: a 'Quarto' installation for HTML rendering and
a Chromium-based web browser (e.g., Chrome, Chromium, Opera, or Vivaldi) accessed via
'chromote' for screenshots. All examples for these functions are wrapped in `\dontrun{}`
as they cannot be run in a standard check environment.


