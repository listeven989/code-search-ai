#!/bin/bash

# Check if a file name is provided
if [ -z "$1" ]; then
  echo "Please provide a file name as an argument."
  exit 1
fi

# Find the closest matching file
file_path=$(find . -type f -iname "*$1*" | awk 'NR==1')

# Check if the file name or file path includes the argument $1
if [ -z "$file_path" ] || [[ ! "$file_path" =~ .*"$1".* ]]; then
  echo "No matching file found."
  exit 1
else
  echo "File path found: $file_path"
  
  # Copy the file contents to the clipboard
  cat "$file_path" | pbcopy
  
  # Print the file contents in the terminal
  cat "$file_path"
fi