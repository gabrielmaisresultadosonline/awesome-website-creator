#!/bin/bash
set -e
DOMAIN="lovblack.online"
EMAIL="mro@gmail.com"
PORT=3000

echo "🚀 [LOVABLACK] Iniciando instalação ULTRA-ROBUSTA (Fix SSL 500)..."

# 1. Dependências
sudo apt-get update && sudo apt-get install -y nodejs nginx certbot python3-certbot-nginx git curl unzip

# 2. Bun
if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
fi
export PATH="$HOME/.bun/bin:$PATH"

# 3. Build e PM2
bun install && bun run build
sudo npm install -g pm2
pm2 delete lovablack 2>/dev/null || true
pm2 start "bun run start" --name "lovablack" --env PORT=$PORT
pm2 save

# 4. Nginx Config - USANDO PORTA 8080 TEMPORÁRIA PARA CERTBOT SE NECESSÁRIO
# Mas vamos focar em limpar os conflitos do Nginx.
NGINX_CONF="/etc/nginx/sites-available/lovablack"

# Criar pasta de desafio com permissão total
sudo mkdir -p /var/www/lovablack/public/.well-known/acme-challenge
sudo chown -R $USER:$USER /var/www/lovablack/public
sudo chmod -R 755 /var/www/lovablack/public

sudo tee $NGINX_CONF > /dev/null <<INNEREOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    location /.well-known/acme-challenge/ {
        alias /var/www/lovablack/public/.well-known/acme-challenge/;
        try_files \$uri =404;
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
# Não vamos remover o default se ele for necessário para outros sites, 
# mas os logs mostram conflitos em outros arquivos.

# Tentar limpar duplicatas de configuração de SSL que estão causando o 'redefined' warn
echo "🔍 Validando Nginx..."
sudo nginx -t && sudo systemctl restart nginx

# 5. SSL via Standalone (Para evitar o erro 500 do plugin Nginx)
echo "🔒 Gerando SSL para $DOMAIN (Modo Standalone)..."
# Paramos o nginx por 10 segundos para o certbot assumir a porta 80 e validar sem erro 500
sudo systemctl stop nginx
if sudo certbot certonly --standalone -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos -m $EMAIL; then
    echo "✅ Certificado obtido!"
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
else
    echo "⚠️ Falha no Standalone, tentando Webroot final..."
    sudo systemctl start nginx
    sudo certbot certonly --webroot -w /var/www/lovablack/public -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos -m $EMAIL
fi

sudo systemctl start nginx
sudo nginx -t && sudo systemctl restart nginx

echo "✅ PROCESSO CONCLUÍDO!"
