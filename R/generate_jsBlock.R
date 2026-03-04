#' Generate JavaScript file for hexsession
#'
#' @param logopaths Vector of image paths
#' @param urls Vector of URLs
#' @param dark_mode Use dark mode, inherited from make_tile
#' @param output_js Path to save the JavaScript file
#' @param highlight_mode Use highlight mode, inherited from make_tile
#' @param pkg_names Vector of package names (optional)
#' @param focus Vector of package names to focus on (optional)
#'
#' @return Called for its side effect; invisibly returns `NULL`. Writes a
#'   JavaScript file to `output_js` containing base64-encoded image data and
#'   dark/light mode CSS variable assignments.
#'
#' @examples
#' \dontrun{
#' img <- system.file("extdata/rectLight.png", package = "hexsession")
#' out <- tempfile(fileext = ".js")
#' generate_hexsession_js(
#'   logopaths = img,
#'   urls = "https://example.com",
#'   dark_mode = FALSE,
#'   output_js = out
#' )
#' }
#'
#' @importFrom jsonlite toJSON
#' @importFrom base64enc base64encode
#'
#' @export
generate_hexsession_js <- function(logopaths, urls, dark_mode, output_js, highlight_mode = FALSE, pkg_names = NULL, focus = NULL) {
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
    pair <- list(
      image = encoded_paths[i],
      url = if (is.na(urls[i]) || urls[i] == "NA") NULL else as.character(urls[i])
    )
    
    # Add package name if available
    if (!is.null(pkg_names) && i <= length(pkg_names)) {
      pair$package <- pkg_names[i]
    }
    
    pair
  })

  image_url_pairs <- image_url_pairs[!is.na(sapply(image_url_pairs, function(x) x$image))]

  # Convert focus to JSON or null
  focus_json <- if (!is.null(focus) && length(focus) > 0) {
    jsonlite::toJSON(focus, auto_unbox = FALSE)
  } else {
    "null"
  }

  js_content <- sprintf('
const imageUrlPairs = %s;
const darkMode = %s;
const highlightMode = %s;
const focusPackages = %s;

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

  if (highlightMode) {
    container.classList.add("highlight-mode");
  }

  if (focusPackages && focusPackages.length > 0) {
    container.classList.add("focus-mode");
  }

  imageUrlPairs.forEach((pair, index) => {
    const div = document.createElement("div");
    const img = document.createElement("img");

    img.src = pair.image;
    img.alt = "Hexagon Image " + (index + 1);

    // Add focus class if this package is in the focus list
    if (focusPackages && pair.package && focusPackages.includes(pair.package)) {
      div.classList.add("focused");
    }

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
    tolower(as.character(dark_mode)),
    tolower(as.character(highlight_mode)),
    focus_json
  )

  writeLines(js_content, output_js)
}
