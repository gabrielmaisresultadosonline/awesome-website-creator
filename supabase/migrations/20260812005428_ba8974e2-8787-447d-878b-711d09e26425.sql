REVOKE EXECUTE ON FUNCTION auth_internal.has_role(uuid, public.app_role) FROM public;
REVOKE EXECUTE ON FUNCTION auth_internal.has_role(uuid, public.app_role) FROM authenticated;
