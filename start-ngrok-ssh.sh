#!/bin/bash

echo "=== Starting SSH service ==="
service ssh start

# Check Ngrok token
if [ -z "$NGROK_AUTH_TOKEN" ]; then
    echo "Error: NGROK_AUTH_TOKEN environment variable is not set."
    echo "Please set your token before running."
    exit 1
fi

# Login to Ngrok
ngrok config add-authtoken "$NGROK_AUTH_TOKEN"

# Detect aaPanel port dynamically
AAPANEL_PORT=$(cat /www/server/panel/data/port.pl 2>/dev/null || echo 8888)
echo "Detected aaPanel port: $AAPANEL_PORT"

# Create Ngrok Configuration File for multiple tunnels
NGROK_CONFIG="/root/.config/ngrok/ngrok.yml"
mkdir -p $(dirname $NGROK_CONFIG)

cat <<EOF > $NGROK_CONFIG
version: "2"
authtoken: $NGROK_AUTH_TOKEN
region: ap
tunnels:
  ssh:
    proto: tcp
    addr: 22
  aapanel:
    proto: http
    addr: $AAPANEL_PORT
EOF

# Start all tunnels defined in config
echo "=== Starting Ngrok Tunnels ==="
ngrok start --all --config=$NGROK_CONFIG > /tmp/ngrok.log 2>&1 &
sleep 5

# Display tunnel info
echo "=== SSH Tunnel Info ==="
curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"tcp://[^"]*"' | cut -d'"' -f4

echo "=== aaPanel / Web Tunnel Info ==="
curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"https://[^"]*"' | cut -d'"' -f4

# Keep container alive (Run in FOREGROUND - remove '&' at the end)
echo "=== Container keep-alive running on port 8080 ==="
python3 -m http.server 8080