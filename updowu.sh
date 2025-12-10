#!/bin/bash
# Script for updating the OpenWebUI container

# Container and image names
CONTAINER_NAME="open-webui"
IMAGE_NAME="ghcr.io/open-webui/open-webui:main"
PORT="8080"

# --------------------------------------------------------------------
# 1️⃣  Gather digests
# --------------------------------------------------------------------
# Local digest (from the image that is already on disk)
LOCAL_DIGEST=$(docker images --digests "$IMAGE_NAME" --format "{{.Digest}}")

# Remote digest – fetched from the registry *without* pulling the image
REMOTE_DIGEST=$(docker manifest inspect "$IMAGE_NAME" |
                grep digest |
                head -n 1 |
                awk -F '"' '{print $4}')

if [ -z "$REMOTE_DIGEST" ]; then
  echo "❌  ERROR: Could not obtain the remote digest."
  exit 1
fi

echo "Local digest:  $LOCAL_DIGEST"
echo "Remote digest: $REMOTE_DIGEST"

# --------------------------------------------------------------------
# 2️⃣  No update needed?
# --------------------------------------------------------------------
if [ "$LOCAL_DIGEST" == "$REMOTE_DIGEST" ]; then
  echo "✓  No update required – the image is already up‑to‑date."
  exit 0
fi

# --------------------------------------------------------------------
# 3️⃣  Stop & remove the existing container
# --------------------------------------------------------------------
echo "🚚  Stopping container $CONTAINER_NAME…"
docker stop "$CONTAINER_NAME" 2>/dev/null

echo "🚚  Removing container $CONTAINER_NAME…"
docker rm "$CONTAINER_NAME" 2>/dev/null

# --------------------------------------------------------------------
# 4️⃣  Remove the old image (if it exists)
# --------------------------------------------------------------------
echo "🚚  Removing old image $IMAGE_NAME…"
OLD_IMAGE_ID=$(docker images -q "$IMAGE_NAME")
if [ -n "$OLD_IMAGE_ID" ]; then
  docker rmi "$OLD_IMAGE_ID"
fi

# --------------------------------------------------------------------
# 5️⃣  Pull the latest image
# --------------------------------------------------------------------
echo "🚚  Pulling latest image $IMAGE_NAME…"
docker pull "$IMAGE_NAME"

# --------------------------------------------------------------------
# 6️⃣  Launch the new container
# --------------------------------------------------------------------
echo "🚚  Starting new container…"
docker run -d \
  -p "${PORT}:8080" \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --name "$CONTAINER_NAME" \
  --restart always \
  "$IMAGE_NAME"

echo "✅  Update completed!"

# Show the running container
docker ps | grep "$CONTAINER_NAME"

# --------------------------------------------------------------------
# 7️⃣  Check Ollama version & auto‑upgrade if needed
# --------------------------------------------------------------------
current=$(ollama --version | awk '{print $NF}')
latest=$(curl -s https://api.github.com/repos/ollama/ollama/releases/latest |
         grep tag_name |
         cut -d '"' -f4 |
         sed 's/v//')

echo "Current Ollama version: $current"
echo "Latest Ollama version : $latest"

if [ "$current" = "$latest" ]; then
  echo "✓  You are running the latest Ollama version."
else
  echo "⚠  A newer Ollama version ($latest) is available."
  echo "🚚  Updating Ollama…"
  curl -fsSL https://ollama.com/install.sh | sh
  sudo cp ollama.service /etc/systemd/system/ollama.service
  sudo systemctl daemon-reload && sudo systemctl restart ollama
  echo "✅  Ollama updated!"
fi
