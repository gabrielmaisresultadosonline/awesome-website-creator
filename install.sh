#!/bin/bash

# LOVABLACK - VPS Installation Script (Ubuntu 24.04 LTS)
# Installs Node.js, Bun, PM2, and Nginx

set -e

echo "🚀 Starting LOVABLACK installation on Ubuntu 24.04..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y curl wget git build-essential unzip nginx

# Install Node.js via NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 20
nvm use 20

# Install Bun
curl -fsSL https://bun.sh/install | bash
export PATH="$HOME/.bun/bin:$PATH"

# Install PM2
npm install -g pm2

echo "✅ Environment ready!"
echo "Next steps:"
echo "1. Clone your project"
echo "2. Run 'bun install'"
echo "3. Run 'bun run build'"
echo "4. Start with PM2: 'pm2 start bun --name lovablack -- run start'"
echo "5. Configure Nginx proxy to port 8080"
