# Plano de Integração InfinitePay e Área de Membros Dinâmica

Este plano detalha a implementação do sistema de pagamento automatizado via InfinitePay, a gestão dinâmica de downloads e tutoriais pelo administrador, e a atualização do dashboard de usuários.

## 1. Infraestrutura de Banco de Dados (Finalizado)
- [x] Criar tabela `public.app_settings` para armazenar o link de download e tutoriais.
- [x] Criar tabela `public.infinitepay_transactions` para rastrear pagamentos e NSUs.
- [x] Configurar RLS e privilégios para acesso administrativo e de usuário.
- [x] Seeder inicial com valores padrão.

## 2. Integração de Pagamento InfinitePay
- [x] **Server Function (`src/lib/payments.functions.ts`)**: Criar função `createPaymentLink` que chama a API da InfinitePay (`/links`) e registra a transação pendente.
- [x] **Webhook (`src/routes/api/public/webhook-infinitepay.ts`)**: Endpoint público para receber confirmações de pagamento, atualizar a transação e estender a assinatura do usuário automaticamente.

## 3. Área de Membros Dinâmica (Dashboard)
- [x] **Consumo de Configurações**: Dashboard agora lê `download_link` e `tutorials` da tabela `app_settings`.
- [x] **Sistema de Planos**: Exibir opções de compra diretamente no dashboard para usuários expirados ou trials.
- [x] **Redirecionamento Pós-Login**: Se um usuário clicar em "Assinar" na home sem estar logado, ele será redirecionado para o dashboard e o link de pagamento será gerado automaticamente após o login.

## 4. Painel Administrativo (`/admin`)
- [x] **Edição em Tempo Real**: Interface para o admin atualizar o link de download e o vídeo de tutorial sem mexer no código.
- [x] **Monitoramento de Vendas**: Lista de transações da InfinitePay com status, NSU e dados do comprador.
- [x] **Gestão de Usuários**: Visão consolidada de todos os usuários e suas assinaturas.

## 5. Fluxo de Usuário Atualizado
1. **Home**: Usuário escolhe um plano. Se não logado, abre `AuthModal`.
2. **Cadastro/Login**: Após o sucesso, o sistema verifica se havia um plano pendente e gera o link InfinitePay.
3. **Pagamento**: Usuário paga via PIX/Cartão no checkout da InfinitePay.
4. **Liberação**: Webhook recebe o aviso, atualiza o banco e o dashboard do usuário libera o botão de download e vídeos instantaneamente.

---

### Detalhes Técnicos
- **API InfinitePay**: Utilizando o handle `paguemro`.
- **NSU Customizado**: Gerado dinamicamente para rastreio robusto.
- **TanStack Query**: Invalidação automática de cache após atualizações administrativas.
- **Segurança**: RLS garante que usuários só vejam suas transações, enquanto o admin tem visão global.
