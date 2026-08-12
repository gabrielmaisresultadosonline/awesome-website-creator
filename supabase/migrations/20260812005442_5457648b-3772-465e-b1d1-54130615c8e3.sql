ALTER FUNCTION public.auto_confirm_email() SET search_path = public;
REVOKE EXECUTE ON FUNCTION public.auto_confirm_email() FROM public;
REVOKE EXECUTE ON FUNCTION public.auto_confirm_email() FROM authenticated;
