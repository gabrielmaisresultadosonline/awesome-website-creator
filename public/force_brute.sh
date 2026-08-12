#!/bin/bash
DOMAIN="lovblack.online"
NGINX_ROOT="/etc/nginx"

echo "💣 [LOVABLACK] EXECUTANDO OPERAÇÃO DE FORÇA BRUTA..."

# 1. Parar o Nginx completamente
sudo systemctl stop nginx

# 2. Varredura TOTAL e DELEÇÃO em toda a pasta /etc/nginx/
# Vamos apagar qualquer arquivo que cite o domínio e não seja a nossa config
echo "🔍 Caçando e deletando sequestradores em todo o /etc/nginx/..."
grep -rl "$DOMAIN" "$NGINX_ROOT" 2>/dev/null | grep -v "lovablack" | xargs -I {} sudo rm -f {} || true

# 3. Remover o link default e limpar links quebrados
sudo rm -f "$NGINX_ROOT/sites-enabled/default"
sudo find "$NGINX_ROOT/sites-enabled/" -xtype l -delete

# 4. Criar a configuração como PRIORIDADE MÁXIMA (default_server)
# Adicionamos o "default_server" para que o Nginx entregue este site se nenhum outro der match exato
sudo tee "$NGINX_ROOT/sites-available/lovablack" > /dev/null <<INNEREOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
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

# 5. Habilitar e Reiniciar Forçado
sudo ln -sf "$NGINX_ROOT/sites-available/lovablack" "$NGINX_ROOT/sites-enabled/lovablack"
sudo killall -9 nginx 2>/dev/null || true
sudo nginx -t && sudo systemctl start nginx

echo "✅ OPERAÇÃO DE FORÇA BRUTA CONCLUÍDA!"
echo "👉 AGORA É OBRIGATÓRIO: Use uma ABA ANÔNIMA para testar."
echo "👉 Acesse: http://$DOMAIN"
