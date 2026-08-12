REVOKE EXECUTE ON FUNCTION auth_internal.handle_new_user() FROM anon;
REVOKE EXECUTE ON FUNCTION auth_internal.has_role(uuid, public.app_role) FROM anon;
REVOKE EXECUTE ON FUNCTION public.auto_confirm_email() FROM anon;
