# Arrange Images by Color

Takes a vector of image paths, extracts the main color from each image
using k-means clustering, converts the colors to the LAB color space,
and sorts the images based on the lightness (L) component of their
dominant color.

## Usage

``` r
col_arrange(image_paths)
```

## Arguments

- image_paths:

  Character vector. A vector of file paths to the images.

## Value

A character vector of image paths, sorted by the lightness of their main
color.

## Examples

``` r
img1 <- system.file("extdata/rectLight.png", package = "hexsession")
img2 <- system.file("extdata/rectMed.png", package = "hexsession")
img3 <- system.file("extdata/rectDark.png", package = "hexsession")
sorted_paths <- col_arrange(c(img1,img3,img2))
```
