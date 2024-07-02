#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Error: Please provide a directory name as an argument."
  exit 1
fi

# Get the directory name from the argument
dir_name="$1"

# Create the main directory with the argument name
mkdir -p "$dir_name"

# Create the .idea directory inside the main directory
mkdir -p "$dir_name/.idea"

# Create the templates directory inside the main directory
mkdir -p "$dir_name/templates"

# Create the files within their respective directories
touch "$dir_name/main.py"
touch "$dir_name/README.md"
touch "$dir_name/templates/index.html"

echo "Successfully created directory structure for: $dir_name"
