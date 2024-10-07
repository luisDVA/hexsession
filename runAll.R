# Generate package data and get the path to the temporary file
temp_file_path <- source("pkg_data.R")$value

quarto_command <- sprintf(
  'quarto render hexout.qmd -P temp_file_path="%s"',
  temp_file_path
)

# Execute the Quarto command
system(quarto_command)
