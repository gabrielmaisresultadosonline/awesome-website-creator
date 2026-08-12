import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";

const INFINITEPAY_API_URL = "https://api.checkout.infinitepay.io/links";

export const createPaymentLink = createServerFn({ method: "POST" })
  .inputValidator((data) => z.object({
    planName: z.string(),
    priceCents: z.number(),
    planDurationDays: z.number(),
    customerName: z.string(),
    customerEmail: z.string(),
    customerPhone: z.string().optional(),
    redirectUrl: z.string(),
    webhookUrl: z.string(),
  }).parse(data))
  .handler(async ({ data, context }) => {
    // We need to import supabaseAdmin to record the transaction
    const { supabaseAdmin } = await import("@/integrations/supabase/client.server");
    const { data: { user } } = await supabaseAdmin.auth.getUser();
    
    if (!user) {
      throw new Error("Unauthorized");
    }

    const handle = "paguemro"; // Fixed handle from documentation
    const orderNsu = \`order-\${Date.now()}-\${Math.floor(Math.random() * 1000)}\`;

    const payload = {
      handle,
      order_nsu: orderNsu,
      redirect_url: data.redirectUrl,
      webhook_url: data.webhookUrl,
      customer: {
        name: data.customerName,
        email: data.customerEmail,
        phone_number: data.customerPhone,
      },
      items: [
        {
          quantity: 1,
          price: data.priceCents,
          description: \`LOVABLACK - \${data.planName}\`,
        },
      ],
    };

    const response = await fetch(INFINITEPAY_API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const result = await response.json();

    if (!response.ok) {
      console.error("InfinitePay Error:", result);
      throw new Error("Falha ao gerar link de pagamento");
    }

    // Record transaction in pending state
    await supabaseAdmin.from("infinitepay_transactions").insert({
      user_id: user.id,
      order_nsu: orderNsu,
      amount: data.priceCents,
      plan_name: data.planName,
      plan_duration_days: data.planDurationDays,
      payment_link: result.url,
      status: "pending",
    });

    return { url: result.url };
  });
