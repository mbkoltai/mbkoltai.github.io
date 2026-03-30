library(rvest)
library(xml2)
library(dplyr)
library(stringr)

# ---- SETTINGS ----
# Folder containing all HTML files (including subfolders)
root_folder <- "../../_includes/images/hu-cee-convergence/output/HU"

# Mapping for column headers
header_map <- c(
  "country" = "ország",
  "% of EU8" = "EU8 %-a",
  "relative to initial value" = "változás kezdeti értékhez képest", 
  # regex for "relative to initial value (%)"
  "absolute value \\(thousand USD PPP\\)" = "abszolút érték (ezer konstans USD PPP)",
  "absolute value \\(PPS\\)" = "abszolút érték (PPS)",
  "absolute value \\(thousand PPS\\)" = "abszolút érték (ezer PPS)",
  "absolute value \\(years\\)" = "abszolút érték (év)",
    "absolute value \\(% of 15\\+ popul\\.\\)" = "abszolút érték (% 15+ lakosság)"
)

# Mapping for country names
country_map <- c(
  "Romania" = "Románia",
  "Bulgaria" = "Bulgária",
  "Lithuania" = "Litvánia",
  "Latvia" = "Lettország",
  "Croatia" = "Horvátország",
  "Poland" = "Lengyelország",
  "Estonia" = "Észtország",
  "Hungary" = "Magyarország",
  "Czechia" = "Csehország",
  "Slovenia" = "Szlovénia",
  "Slovakia" = "Szlovákia"
)

# ---- FUNCTION TO PROCESS ONE FILE ----
process_html <- function(file_path) {
  cat("Processing:", file_path, "\n")
  
  # Read HTML
  #html <- read_html(file_path)
  html <- read_html(file, encoding = "UTF-8")
  
  # Replace headers
  headers <- html %>% html_nodes("th") %>% html_text(trim = TRUE)
  
  new_headers <- headers
  for (h in names(header_map)) {
    new_headers <- str_replace_all(new_headers, h, header_map[h])
  }
  
  # Apply new headers
  th_nodes <- html %>% html_nodes("th")
  for (i in seq_along(th_nodes)) {
    xml_text(th_nodes[i]) <- new_headers[i]
  }
  
  # Replace country names in all td elements
  td_nodes <- html %>% html_nodes("td")
  for (i in seq_along(td_nodes)) {
    text <- xml_text(td_nodes[i])
    for (c in names(country_map)) {
      if (str_detect(text, fixed(c))) {
        xml_text(td_nodes[i]) <- str_replace_all(text, fixed(c), country_map[c])
      }
    }
  }
  
  # Save modified HTML (overwrite original)
  # write_html(html, str_replace(file_path, "\\.html?$", "_hu.html"))
  # ,encoding = "UTF-8", options = "format"
  # writeLines(as.character(html), file, useBytes = TRUE)
  writeLines(
  paste0(as.character(xml2::xml_children(xml2::xml_find_first(html, "//body"))), collapse = "\n"),
  file,
  useBytes = TRUE
)
}

# ---- RECURSIVE FILE COLLECTION ----
# Only HTMLs in subfolders (1 level deep)
all_html_files <- list.files(root_folder, recursive=T, pattern = "\\.html?$", full.names=T)
all_html_files <- all_html_files[!grepl(paste0("^",
  root_folder, "/[^/]+\\.html$"), all_html_files)]

# ---- PROCESS ALL FILES ----
for (file in all_html_files) {
  process_html(file)
}

cat("All HTML files processed.\n")
rm(all_html_files,file,root_folder,country_map,header_map)