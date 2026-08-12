import { createFileRoute, redirect } from '@tanstack/react-router';
import { supabase } from '@/integrations/supabase/client';
import { isAdmin } from '@/lib/auth';

export const Route = createFileRoute('/admin')({
  beforeLoad: async () => {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) {
      throw redirect({ to: '/' });
    }
    
    // Explicitly check for admin email or role
    if (session.user.email !== 'mro@Gmail.com') {
      const isUserAdmin = await isAdmin(session.user.id);
      if (!isUserAdmin) {
        throw redirect({ to: '/dashboard' });
      }
    }
  },
});
