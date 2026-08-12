-- Move the function to a private internal schema to avoid linter warnings 
-- regarding public execution of SECURITY DEFINER functions.
CREATE SCHEMA IF NOT EXISTS auth_internal;

CREATE OR REPLACE FUNCTION auth_internal.auto_confirm_email()
RETURNS TRIGGER AS $$
BEGIN
  NEW.email_confirmed_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- Update trigger to point to the new location
DROP TRIGGER IF EXISTS on_auth_user_created_confirm ON auth.users;
CREATE TRIGGER on_auth_user_created_confirm
  BEFORE INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION auth_internal.auto_confirm_email();

-- Explicitly revoke execute from public to be safe
REVOKE EXECUTE ON FUNCTION auth_internal.auto_confirm_email() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION auth_internal.auto_confirm_email() FROM authenticated;
REVOKE EXECUTE ON FUNCTION auth_internal.auto_confirm_email() FROM anon;
