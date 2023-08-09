#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <relative_path>"
  exit 1
fi

RELATIVE_PATH="$1"
OUTPUT_FILE="mermaid_chart.md"

echo "graph TD" > $OUTPUT_FILE

tree -fi --noreport -I 'node_modules|.*|*.json|*build*|*dist*|public|assets|*config*' "$RELATIVE_PATH" | while read -r line; do
  if [ -f "$line" ]; then
    parent=$(dirname "$line")
    child=$(basename "$line")
    parent_id="${parent//\//-}"
    child_id="${parent//\//-}-${child//\//-}"
    parent_id="${parent_id//./_}"
    child_id="${child_id//./_}"
    parent_id="${parent_id//-/_}"
    child_id="${child_id//-/_}"
    echo "${parent_id}[${parent}] --> ${child_id}[${child}]" >> $OUTPUT_FILE
  fi
done

echo "Mermaid chart generated in $OUTPUT_FILE"
