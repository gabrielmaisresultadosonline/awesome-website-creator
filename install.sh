#!/bin/bash
set -e
DOMAIN="lovblack.online"
EMAIL="mro@gmail.com"
APP_DIR=$(pwd)

echo "🚀 Iniciando configuração do LOVABLACK..."

# 1. System dependencies (including unzip for Bun)
sudo apt-get update && sudo apt-get install -y nodejs git nginx certbot python3-certbot-nginx curl unzip

# 2. Bun installation
if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
fi
export PATH="$HOME/.bun/bin:$PATH"

# 3. Project setup
# Dependencies and Build
bun install
bun run build

# 4. PM2 Management
sudo npm install -g pm2
pm2 delete lovablack 2>/dev/null || true
pm2 start "bun run start" --name "lovablack" --env PORT=3000
pm2 save
pm2 startup | tail -n 1 | bash || true

# 5. Nginx Configuration
NGINX_CONF="/etc/nginx/sites-available/lovablack"
sudo tee $NGINX_CONF > /dev/null <<INNEREOF
server {
    listen 80;
    server_name $DOMAIN;
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
INNEREOF

sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

# 6. SSL Configuration
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect

echo "✅ LOVABLACK INSTALADO COM SUCESSO!"
echo "🌐 Acesse: https://$DOMAIN"
