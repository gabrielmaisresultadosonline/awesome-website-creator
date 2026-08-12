#!/bin/bash
set -e
DOMAIN="lovblack.online"
EMAIL="mro@gmail.com"
PORT=3000

echo "🚀 [LOVABLACK] Iniciando instalação ULTRA-ROBUSTA (Fix 500/DNS)..."

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

# 4. Diagnóstico de DNS e IP
SERVER_IP=$(curl -s https://api.ipify.org)
echo "🔍 IP da VPS: $SERVER_IP"
echo "🔍 Domínio configurado: $DOMAIN"

# 5. Nginx Config - MODO SEGURO (HTTPS Opcional no início)
NGINX_CONF="/etc/nginx/sites-available/lovablack"
sudo tee $NGINX_CONF > /dev/null <<INNEREOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

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
sudo nginx -t && sudo systemctl restart nginx

echo "✅ Site instalado em modo HTTP (sem cadeado ainda)."

# 6. SSL com Retry e Diagnóstico
echo "🔒 Tentando obter SSL para $DOMAIN..."
# Se o standalone falhou com 500, é porque algo está interceptando a porta 80 antes da rede.
# Vamos tentar o plugin Nginx direto, mas sem forçar, para não travar o script.

if sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect; then
    echo "✅ SSL ATIVADO COM SUCESSO!"
else
    echo "❌ O Certbot ainda não consegue validar o domínio."
    echo "👉 Verifique se no seu painel de DNS (Hostinger/Cloudflare) o domínio $DOMAIN aponta para $SERVER_IP."
    echo "⚠️ Se estiver usando Cloudflare, desative o 'Proxy' (nuvem laranja) e deixe apenas 'DNS Only' até o SSL ser gerado."
fi

echo "🚀 INSTALAÇÃO FINALIZADA!"
