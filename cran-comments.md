## R CMD check results

0 errors | 0 warnings | 0 notes

## Summary

This resubmission addresses all issues raised in previous rounds of review,
including example runtime, writing to the user's home filespace, and
system-dependent functions.

`make_tile()` generates HTML directly in R with no external software required.
Its example is fully unconditional and completes in well under one second.

`snap_tile()` requires a Chromium-based browser accessed via 'chromote'. Its
example is guarded with `@examplesIf` and will be skipped on systems where no
browser is found.
