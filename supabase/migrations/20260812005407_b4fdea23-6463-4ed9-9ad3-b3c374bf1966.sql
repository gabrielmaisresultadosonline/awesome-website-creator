-- Fix security warnings for auth_internal functions
ALTER FUNCTION auth_internal.handle_new_user() SET search_path = public;
REVOKE EXECUTE ON FUNCTION auth_internal.handle_new_user() FROM public;
REVOKE EXECUTE ON FUNCTION auth_internal.handle_new_user() FROM authenticated;

ALTER FUNCTION auth_internal.auto_confirm_email() SET search_path = public;
REVOKE EXECUTE ON FUNCTION auth_internal.auto_confirm_email() FROM public;
REVOKE EXECUTE ON FUNCTION auth_internal.auto_confirm_email() FROM authenticated;

-- Ensure RLS policies are in place with correct schema for has_role
DO $$ 
BEGIN
    -- app_settings policies
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Admins can update settings') THEN
        CREATE POLICY "Admins can update settings" ON public.app_settings
        FOR ALL TO authenticated
        USING (auth_internal.has_role(auth.uid(), 'admin'::public.app_role));
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can read settings') THEN
        CREATE POLICY "Users can read settings" ON public.app_settings
        FOR SELECT TO authenticated
        USING (true);
    END IF;

    -- infinitepay_transactions policies
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can see own transactions') THEN
        CREATE POLICY "Users can see own transactions" ON public.infinitepay_transactions
        FOR SELECT TO authenticated
        USING (auth.uid() = user_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can insert own transactions') THEN
        CREATE POLICY "Users can insert own transactions" ON public.infinitepay_transactions
        FOR INSERT TO authenticated
        WITH CHECK (auth.uid() = user_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Admins can see all transactions') THEN
        CREATE POLICY "Admins can see all transactions" ON public.infinitepay_transactions
        FOR SELECT TO authenticated
        USING (auth_internal.has_role(auth.uid(), 'admin'::public.app_role));
    END IF;
END $$;
