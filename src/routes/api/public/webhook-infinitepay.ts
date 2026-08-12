import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/api/public/webhook-infinitepay')({
  server: {
    handlers: {
      POST: async ({ request }) => {
        try {
          const payload = await request.json();
          console.log("InfinitePay Webhook Received:", payload);

          // Payload structure from docs:
          // { invoice_slug, amount, paid_amount, installments, capture_method, transaction_nsu, order_nsu, receipt_url, items: [...] }

          const { order_nsu, transaction_nsu, invoice_slug, amount } = payload;

          if (!order_nsu) {
            return new Response("Missing order_nsu", { status: 400 });
          }

          const { supabaseAdmin } = await import("@/integrations/supabase/client.server");

          // 1. Find the transaction
          const { data: transaction, error: txError } = await supabaseAdmin
            .from("infinitepay_transactions")
            .select("*")
            .eq("order_nsu", order_nsu)
            .single();

          if (txError || !transaction) {
            console.error("Transaction not found for NSU:", order_nsu);
            return new Response("Transaction not found", { status: 400 });
          }

          if (transaction.status === 'paid') {
            return new Response("Already processed", { status: 200 });
          }

          // 2. Update transaction status
          await supabaseAdmin
            .from("infinitepay_transactions")
            .update({
              status: "paid",
              transaction_nsu,
              invoice_slug,
            })
            .eq("id", transaction.id);

          // 3. Activate or Extend Subscription
          const expiresAt = new Date();
          expiresAt.setDate(expiresAt.getDate() + transaction.plan_duration_days);

          // Upsert subscription
          const { error: subError } = await supabaseAdmin
            .from("subscriptions")
            .upsert({
              user_id: transaction.user_id,
              type: transaction.plan_duration_days >= 365 ? 'annual' : 'paid',
              status: 'active',
              expires_at: expiresAt.toISOString(),
            }, { onConflict: 'user_id' });

          if (subError) {
            console.error("Error updating subscription:", subError);
            return new Response("Subscription update failed", { status: 500 });
          }

          return new Response("OK", { status: 200 });
        } catch (error) {
          console.error("Webhook Error:", error);
          return new Response("Internal Error", { status: 500 });
        }
      }
    }
  }
});
