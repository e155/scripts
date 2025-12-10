#!/bin/bash

# Check ollama
if ! command -v ollama &> /dev/null; then
    echo "Ollama not found."
    exit 1
fi

echo "Obtaining installed models..."
models=$(ollama list | tail -n +2 | awk '{print $1}')

if [ -z "$models" ]; then
    echo "No installed models found."
    exit 0
fi

echo "Updating models..."
for model in $models; do
    echo "Updating model: $model"
    ollama pull "$model"
done

echo "Updating finished."
