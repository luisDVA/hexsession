# Extract the Most Frequent Color from an Image

Internal helper. For a given image path, this functions uses k-means
clustering to identify the most dominant color in the image.

## Usage

``` r
maincolorRGB(imgpath)
```

## Arguments

- imgpath:

  Character string. File path to the image.

## Value

A data frame with one row containing the RGB values of the dominant
color. The column name is set to the input image path.
