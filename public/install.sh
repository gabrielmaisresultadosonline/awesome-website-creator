#!/bin/bash
set -e
DOMAIN="lovblack.online"
EMAIL="mro@gmail.com"
PORT=3000

echo "🚀 [LOVABLACK] Iniciando instalação ULTRA-ROBUSTA..."

# 1. Dependências
sudo apt-get update && sudo apt-get install -y nodejs nginx certbot python3-certbot-nginx git curl unzip

# 2. Bun
if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
fi
export PATH="$HOME/.bun/bin:$PATH"

# 3. Build
bun install && bun run build

# 4. PM2
sudo npm install -g pm2
pm2 delete lovablack 2>/dev/null || true
pm2 start "bun run start" --name "lovablack" --env PORT=$PORT
pm2 save

# 5. Nginx Config - MODO WEBROOT PARA SSL INFALÍVEL
NGINX_CONF="/etc/nginx/sites-available/lovablack"
sudo mkdir -p /var/www/html/.well-known/acme-challenge
sudo chown -R www-data:www-data /var/www/html

sudo tee $NGINX_CONF > /dev/null <<INNEREOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
        allow all;
    }

    location / {
        proxy_pass http://localhost:$PORT;
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

# 6. SSL com Certbot via Webroot (Mais confiável que o plugin nginx puro)
echo "🔒 Gerando SSL para $DOMAIN via Webroot..."
if sudo certbot certonly --webroot -w /var/www/html -d $DOMAIN --non-interactive --agree-tos -m $EMAIL; then
    # Se gerou com sucesso, atualiza o Nginx para usar SSL
    sudo tee $NGINX_CONF > /dev/null <<INNEREOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN www.$DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
INNEREOF
    sudo nginx -t && sudo systemctl restart nginx
    echo "✅ SSL ATIVADO COM SUCESSO!"
else
    echo "❌ FALHA NO SSL. Verifique se o DNS aponta para este IP."
fi

echo "✅ PROCESSO CONCLUÍDO!"
