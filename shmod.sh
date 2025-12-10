#!/bin/bash

# Print table header
printf "%-40s %-15s %-18s %s\n" "Model" "Context Length" "Embedding Length" "Quantization"
printf "%-40s %-15s %-18s %s\n" "-----" "-------------" "---------------" "-----------"

# Botian models list and processing it
ollama list | awk 'NR>1 {print $1}' | while read -r model; do
    [ -z "$model" ] && continue

    ollama show "$model" 2>/dev/null | awk -v model="$model" '
    /^[[:space:]]*context length/ {context = $NF}
    /^[[:space:]]*embedding length/ {embedding = $NF}
    /^[[:space:]]*quantization/ {quantization = $NF}
    END {
        if (context != "" && embedding != "" && quantization != "") {
            printf "%-40s %-15s %-18s %s\n", model, context, embedding, quantization
        }
    }'
done
