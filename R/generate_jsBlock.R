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
  # Encode images and get base64 strings
  encoded_paths <- sapply(logopaths, function(path) {
    tryCatch({
      encoded <- base64enc::base64encode(path)
      ext <- tolower(tools::file_ext(path))
      paste0("data:image/", ext, ";base64,", encoded)
    }, error = function(e) {
      warning(paste("Error encoding file:", path, "-", e$message))
      NULL
    })
  })

  # Remove any NULL entries (failed encodings)
  encoded_paths <- encoded_paths[!sapply(encoded_paths, is.null)]

  # Ensure urls matches the length of encoded_paths
  urls <- urls[1:length(encoded_paths)]

  js_content <- sprintf('
const imagePaths = %s;
const linkUrls = %s;
const darkMode = %s;

document.addEventListener("DOMContentLoaded", function() {
  const container = document.getElementById("imageContainer");

  // Set color scheme based on dark mode
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

  // Ensure imagePaths is always iterable
  (Array.isArray(imagePaths) ? imagePaths : [imagePaths]).forEach((path, index) => {
    const div = document.createElement("div");
    const img = document.createElement("img");

    img.src = path;
    img.alt = "Hexagon Image " + (index + 1);

    if (linkUrls[index] && linkUrls[index] !== "NA") {
      const a = document.createElement("a");
      a.href = linkUrls[index];
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
                        jsonlite::toJSON(encoded_paths, auto_unbox = TRUE),
                        jsonlite::toJSON(urls, auto_unbox = TRUE),
                        tolower(as.character(dark_mode))
  )

  writeLines(js_content, output_js)
}
