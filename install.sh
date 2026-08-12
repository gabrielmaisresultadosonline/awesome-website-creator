#!/bin/bash

# ==========================================================================
# LOVABLACK - SCRIPT DE INSTALAÇÃO (FIXED)
# Domínio: lovblack.online
# ==========================================================================

set -e

DOMAIN="lovblack.online"
APP_DIR=$(pwd)

echo "---------------------------------------------------"
echo "🚀 Iniciando configuração do LOVABLACK em $APP_DIR"
echo "---------------------------------------------------"

# 1. Instalação de Dependências de Sistema
echo "🛠️ Instalando dependências globais..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt update
sudo apt install -y nodejs nginx certbot python3-certbot-nginx git

# 2. Instalação do Bun
echo "⚡ Instalando Bun..."
if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
fi

# 3. Instalação de dependências do projeto
echo "📦 Instalando dependências locais..."
/root/.bun/bin/bun install || bun install

# 4. Build
echo "🏗️ Gerando build..."
/root/.bun/bin/bun run build || bun run build

# 5. Configuração do PM2
echo "⚙️ Iniciando processo com PM2..."
sudo npm install -g pm2
pm2 delete lovablack 2>/dev/null || true
pm2 start "bun run start" --name "lovablack" --env PORT=3000
pm2 save
pm2 startup | tail -n 1 | bash || true

# 6. Nginx & SSL
echo "🌐 Configurando Nginx e SSL para $DOMAIN..."
NGINX_CONF="/etc/nginx/sites-available/lovablack"

# Criar arquivo temporário para evitar problemas de redirecionamento no bash da VPS
cat << 'INNEREOF' > /tmp/lovablack_nginx.conf
server {
    listen 80;
    server_name lovblack.online;
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
INNEREOF

sudo mv /tmp/lovablack_nginx.conf $NGINX_CONF
sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

echo "🔒 Solicitando SSL..."
sudo certbot --nginx -d lovblack.online --non-interactive --agree-tos -m mro@gmail.com --redirect

echo "---------------------------------------------------"
echo "✅ INSTALAÇÃO CONCLUÍDA DENTRO DA PASTA!"
echo "🌐 Acesse: https://$DOMAIN"
echo "---------------------------------------------------"
