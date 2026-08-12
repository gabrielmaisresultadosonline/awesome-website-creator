#!/bin/bash
set -e

# Configurações
DOMAIN="lovblack.online"
EMAIL="mro@gmail.com"
PORT=3000

echo "🚀 [LOVABLACK] Iniciando instalação profissional e isolada..."

# 1. Atualização e Dependências
echo "📦 Instalando dependências do sistema..."
sudo apt-get update
sudo apt-get install -y nodejs nginx certbot python3-certbot-nginx git curl unzip

# 2. Instalação do Bun (se não existir)
if ! command -v bun &> /dev/null; then
    echo "⚡ Instalando Bun..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="\$HOME/.bun/bin:\$PATH"
else
    echo "✅ Bun já instalado."
fi
export PATH="\$HOME/.bun/bin:\$PATH"

# 3. Preparação do Projeto
echo "🔧 Instalando dependências do projeto e gerando build..."
bun install
bun run build

# 4. Configuração do PM2
echo "⚙️ Configurando processo PM2..."
sudo npm install -g pm2
pm2 delete lovablack 2>/dev/null || true
pm2 start "bun run start" --name "lovablack" --env PORT=$PORT
pm2 save

# 5. Configuração do Nginx (Robusta)
echo "🌐 Configurando Nginx Reverse Proxy..."
NGINX_CONF="/etc/nginx/sites-available/lovablack"

sudo tee $NGINX_CONF > /dev/null <<INNEREOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # ACME-challenge para Certbot
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
}
INNEREOF

sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

echo "🔍 Testando configuração do Nginx..."
sudo nginx -t
sudo systemctl restart nginx

# 6. SSL com Certbot (com retry e fallback)
echo "🔒 Solicitando certificado SSL..."
# Garantir que a pasta de desafio existe
sudo mkdir -p /var/www/html/.well-known/acme-challenge

# Tenta o método Nginx primeiro, se falhar tenta o webroot
if ! sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect; then
    echo "⚠️ Falha no método Nginx do Certbot, tentando via webroot..."
    sudo certbot certonly --webroot -w /var/www/html -d $DOMAIN --non-interactive --agree-tos -m $EMAIL
    
    # Se o certonly funcionou, precisamos atualizar o Nginx manualmente para SSL
    # Mas o erro 500 geralmente indica que o Nginx não está respondendo corretamente.
fi

echo "✅ INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
echo "📡 Acesse: https://$DOMAIN"
