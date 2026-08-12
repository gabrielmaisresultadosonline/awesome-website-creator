#!/bin/bash

# ==========================================================================
# LOVABLACK - SCRIPT DE INSTALAÇÃO AUTOMATIZADA (VPS UBUNTU 24.04)
# Domínio: lovblack.online
# Repositório: https://github.com/gabrielmaisresultadosonline/awesome-website-creator.git
# ==========================================================================

set -e

DOMAIN="lovblack.online"
APP_DIR="/var/www/lovablack"
REPO_URL="https://github.com/gabrielmaisresultadosonline/awesome-website-creator.git"
GIT_BRANCH="main"

echo "---------------------------------------------------"
echo "🚀 Iniciando instalação do LOVABLACK em $DOMAIN"
echo "---------------------------------------------------"

# 1. Atualização do Sistema
echo "📦 Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

# 2. Instalação de Dependências Essenciais
echo "🛠️ Instalando Node.js, Git, Nginx e Certbot..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs git nginx certbot python3-certbot-nginx

# 3. Instalação do Bun (Runtime ultra-rápido para TanStack Start)
echo "⚡ Instalando Bun..."
curl -fsSL https://bun.sh/install | bash
export PATH="$HOME/.bun/bin:$PATH"
source ~/.bashrc || true

# 4. Configuração do Diretório Isolado
echo "📂 Preparando pasta isolada em $APP_DIR..."
sudo mkdir -p $APP_DIR
sudo chown -R $USER:$USER $APP_DIR
cd $APP_DIR

# 5. Clonagem do Repositório
echo "📥 Clonando repositório..."
if [ -d ".git" ]; then
    git pull origin $GIT_BRANCH
else
    git clone $REPO_URL .
fi

# 6. Instalação de Dependências do Projeto
echo "📦 Instalando dependências com Bun..."
~/.bun/bin/bun install

# 7. Build do Projeto
echo "🏗️ Gerando build de produção..."
~/.bun/bin/bun run build

# 8. Configuração do PM2 (Gerenciador de Processos)
echo "⚙️ Configurando PM2 para manter o site online..."
sudo npm install -g pm2
pm2 delete lovablack 2>/dev/null || true
pm2 start "bun run start" --name "lovablack" --env PORT=3000
pm2 save
pm2 startup | tail -n 1 | bash

# 9. Configuração do Nginx (Proxy Reverso)
echo "🌐 Configurando Nginx para $DOMAIN..."
NGINX_CONF="/etc/nginx/sites-available/lovablack"

sudo bash -c "cat > $NGINX_CONF << 'INNEREOF'
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
INNEREOF"

sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

# 10. Instalação do SSL (Certbot)
echo "🔒 Gerando certificado SSL gratuito com Let's Encrypt..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m mro@gmail.com --redirect

echo "---------------------------------------------------"
echo "✅ INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
echo "🌐 Acesse: https://$DOMAIN"
echo "📂 Localização: $APP_DIR"
echo "🚀 O processo está sendo gerenciado pelo PM2"
echo "---------------------------------------------------"
