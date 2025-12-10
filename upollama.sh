current=$(ollama --version | awk '{print $NF}')
latest=$(curl -s https://api.github.com/repos/ollama/ollama/releases/latest | grep tag_name | cut -d '"' -f4 | sed 's/v//')
echo "Installed ollama version: $current"
echo "Lastest ollama version: $latest"

if [ "$current" = "$latest" ]; then
  echo "✓ Already lastest version installed."
else
  echo "⚠Update availiable! Found: $latest"
  echo "===> Updating ollama..."
  curl -fsSL https://ollama.com/install.sh | sh
  sudo cp ollama.service /etc/systemd/system/ollama.service
  sudo systemctl daemon-reload && sudo systemctl restart ollama
  echo "===> Done!"

fi
