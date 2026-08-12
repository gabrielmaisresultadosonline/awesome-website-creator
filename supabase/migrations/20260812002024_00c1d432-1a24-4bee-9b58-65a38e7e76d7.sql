-- Revoke execute from public and authenticated for security definer functions
-- to ensure they can only be called by the system (triggers) or explicitly authorized contexts.

REVOKE EXECUTE ON FUNCTION public.has_role(uuid, app_role) FROM PUBLIC, authenticated;
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC, authenticated;

-- Ensure service_role can still execute if needed (though usually it can by default)
GRANT EXECUTE ON FUNCTION public.has_role(uuid, app_role) TO service_role;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;
