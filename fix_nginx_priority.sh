#!/bin/bash
DOMAIN="lovblack.online"
NGINX_CONF="/etc/nginx/sites-available/lovablack"

echo "🎯 [LOVABLACK] Corrigindo prioridade e removendo conflitos..."

# 1. Procurar em todos os arquivos habilitados quem está "roubando" o domínio
FILES=$(grep -rl "$DOMAIN" /etc/nginx/sites-enabled/ | grep -v "lovablack" || true)

if [ -z "$FILES" ]; then
    echo "❓ Nenhum arquivo habilitado encontrado com esse domínio além do lovablack."
    echo "🔍 Verificando se o domínio está no arquivo default ou em outros blocos..."
else
    echo "🚫 Removendo links de sites que conflitam: $FILES"
    echo "$FILES" | xargs sudo rm
fi

# 2. Configuração forçada e limpa
sudo tee $NGINX_CONF > /dev/null <<INNEREOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
INNEREOF

# 3. Habilitar lovablack e garantir que o link existe
sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/lovablack

# 4. Reiniciar Nginx
echo "🚀 Reiniciando Nginx..."
sudo nginx -t && sudo systemctl restart nginx

echo "✅ Conflito removido! O domínio $DOMAIN deve agora mostrar o Lovablack."
