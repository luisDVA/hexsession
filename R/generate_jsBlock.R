#' Generate JavaScript file for hexsession
#'
#' @param logopaths Vector of image paths
#' @param urls Vector of URLs
#' @param dark_mode Use dark mode, inherited from make_tile
#' @param output_js Path to save the JavaScript file
#'
#' @importFrom jsonlite toJSON
#' @importFrom base64enc base64encode
#'
#' @export
generate_hexsession_js <- function(logopaths, urls, dark_mode, output_js) {
  encoded_paths <- vector("character", length(logopaths))
  for (i in seq_along(logopaths)) {
    tryCatch({
      encoded <- base64enc::base64encode(logopaths[i])
      ext <- tolower(tools::file_ext(logopaths[i]))
      encoded_paths[i] <- paste0("data:image/", ext, ";base64,", encoded)
    }, error = function(e) {
      warning(paste("Error encoding file:", logopaths[i], "-", e$message))
      encoded_paths[i] <- NA_character_
    })
  }

  image_url_pairs <- lapply(seq_along(encoded_paths), function(i) {
    list(
      image = encoded_paths[i],
      url = if (is.na(urls[i]) || urls[i] == "NA") NULL else as.character(urls[i])
    )
  })

  image_url_pairs <- image_url_pairs[!is.na(sapply(image_url_pairs, function(x) x$image))]

  js_content <- sprintf('
const imageUrlPairs = %s;
const darkMode = %s;

document.addEventListener("DOMContentLoaded", function() {
  const container = document.getElementById("imageContainer");

  if (darkMode) {
    document.documentElement.style.setProperty("--bg-color", "#1a1a1a");
    document.documentElement.style.setProperty("--text-color", "#ffffff");
    document.documentElement.style.setProperty("--tile-bg", "#2a2a2a");
    document.documentElement.style.setProperty("--attribution-bg", "rgba(255, 255, 255, 0.1)");
    document.documentElement.style.setProperty("--link-color", "#66b3ff");
  } else {
    document.documentElement.style.setProperty("--bg-color", "#ffffff");
    document.documentElement.style.setProperty("--text-color", "#000000");
    document.documentElement.style.setProperty("--tile-bg", "#f0f0f0");
    document.documentElement.style.setProperty("--attribution-bg", "rgba(0, 0, 0, 0.1)");
    document.documentElement.style.setProperty("--link-color", "#0066cc");
  }

  imageUrlPairs.forEach((pair, index) => {
    const div = document.createElement("div");
    const img = document.createElement("img");

    img.src = pair.image;
    img.alt = "Hexagon Image " + (index + 1);

    if (pair.url && typeof pair.url === "string") {
      const a = document.createElement("a");
      a.href = pair.url;
      a.target = "_blank";
      a.appendChild(img);
      div.appendChild(a);
    } else {
      div.appendChild(img);
    }

    container.appendChild(div);
  });
});
',
    jsonlite::toJSON(image_url_pairs, auto_unbox = TRUE),
    tolower(as.character(dark_mode))
  )

  writeLines(js_content, output_js)
}
