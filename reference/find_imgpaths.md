# Find image paths

Find image paths

## Usage

``` r
find_imgpaths(pkgnames)
```

## Arguments

- pkgnames:

  Character vector of package names

## Value

A list of image file paths for each package

## Details

Images in svg format will be converted to png. When no image matches
'logo' in the file name the used is will be prompted to select likely
logos.
