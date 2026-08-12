-- Step 1: Update admin settings table or logic
CREATE TABLE public.app_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT UNIQUE NOT NULL,
    value JSONB NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now()
);

GRANT SELECT ON public.app_settings TO authenticated;
GRANT ALL ON public.app_settings TO service_role;

ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage app_settings" 
ON public.app_settings 
FOR ALL 
TO authenticated 
USING (auth_internal.has_role(auth.uid(), 'admin'));

CREATE POLICY "Everyone can read app_settings"
ON public.app_settings
FOR SELECT
TO authenticated
USING (true);

-- Initialize default settings
INSERT INTO public.app_settings (key, value) VALUES 
('download_link', '"https://example.com/extension.zip"'),
('tutorials', '[{"title": "Como Instalar", "url": "https://www.youtube.com/embed/dQw4w9WgXcQ"}]');

-- Step 2: InfinitePay Transactions table
CREATE TABLE public.infinitepay_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    order_nsu TEXT UNIQUE NOT NULL,
    transaction_nsu TEXT,
    invoice_slug TEXT,
    amount INTEGER NOT NULL, -- in cents
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'expired')),
    plan_name TEXT NOT NULL,
    plan_duration_days INTEGER NOT NULL,
    payment_link TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

GRANT SELECT, INSERT ON public.infinitepay_transactions TO authenticated;
GRANT ALL ON public.infinitepay_transactions TO service_role;

ALTER TABLE public.infinitepay_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can see their own transactions"
ON public.infinitepay_transactions
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Admins can see all transactions"
ON public.infinitepay_transactions
FOR SELECT
TO authenticated
USING (auth_internal.has_role(auth.uid(), 'admin'));

-- Step 3: Grant access to user_roles for the admin check function
GRANT SELECT ON public.user_roles TO authenticated;
