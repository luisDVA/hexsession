## R CMD check results

0 errors | 0 warnings | 0 notes

## Rhub v2 checks: All OK

Test environments:  

- linux x86_64-pc-linux-gnu Ubuntu 24.04.3 LTS - Ubuntu 13.3.0-6ubuntu2~24.04.01  
- Windows Server 2022 x64 (build 26100) - x86_64-w64-mingw32  

## Summary

This resubmission addresses all issues raised in previous rounds of review,
including example runtime, writing to the user's home filespace, and
system-dependent functions.

`make_tile()` generates HTML directly in R with no external software required.
Its example is fully unconditional and completes in well under one second.

`snap_tile()` requires a Chromium-based browser accessed via 'chromote'. Its
example is guarded with `@examplesIf` and will be skipped on systems where no
browser is found.
