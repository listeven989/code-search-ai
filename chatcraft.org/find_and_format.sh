#!/bin/bash

# Check if a file name is provided
if [ -z "$1" ]; then
  echo "Please provide a file name as an argument."
  exit 1
fi

# Find the closest matching file
file_path=$(find . -type f -iname "*$1*" | head -n 1)

# Check if the file name or file path includes the argument $1
if [ -z "$file_path" ] || [[ ! "$file_path" =~ .*"$1".* ]]; then
  echo "No matching file found."
  exit 1
fi

# Print and format the file contents
echo "```"
echo "// $file_path"
echo ""
cat "$file_path"
echo "```"

# Copy the contents to the clipboard
formatted_contents=$(echo "```"; echo "// $file_path"; echo ""; cat "$file_path"; echo "```")

if [ "$(uname)" == "Darwin" ]; then
  echo "$formatted_contents" | pbcopy
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  echo "$formatted_contents" | xclip -selection clipboard
else
  echo "Clipboard copy not supported on this platform."
fi