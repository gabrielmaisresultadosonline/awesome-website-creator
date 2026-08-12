import { createFileRoute } from '@tanstack/react-router';
import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';
import { Users, CreditCard, Clock, CheckCircle, XCircle } from 'lucide-react';

export const Route = createFileRoute('/admin/dashboard')({
  component: AdminDashboard,
});

function AdminDashboard() {
  const { data: stats } = useQuery({
    queryKey: ['admin-stats'],
    queryFn: async () => {
      const { data: subs, error } = await supabase.from('subscriptions').select('*, profiles(*)');
      if (error) throw error;
      
      const total = subs.length;
      const active = subs.filter(s => s.status === 'active' && new Date(s.expires_at) > new Date()).length;
      const expired = total - active;
      const trials = subs.filter(s => s.type === 'trial').length;
      
      return { total, active, expired, trials, subs };
    }
  });

  return (
    <div className="min-h-screen bg-[#F7F1EB] p-4 md:p-8">
      <div className="max-w-7xl mx-auto space-y-8">
        <header className="flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold text-[#1A1B1A]">Painel Administrativo</h1>
            <p className="text-neutral-500">Gestão de Usuários e Assinaturas</p>
          </div>
        </header>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <StatCard icon={Users} label="Total Registros" value={stats?.total || 0} />
          <StatCard icon={CheckCircle} label="Assinaturas Ativas" value={stats?.active || 0} color="text-green-600" />
          <StatCard icon={XCircle} label="Expirados" value={stats?.expired || 0} color="text-red-600" />
          <StatCard icon={Clock} label="Testes (Trials)" value={stats?.trials || 0} color="text-blue-600" />
        </div>

        <Card className="bg-white border-neutral-200">
          <CardHeader>
            <CardTitle>Histórico de Assinaturas</CardTitle>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Usuário</TableHead>
                  <TableHead>WhatsApp</TableHead>
                  <TableHead>Tipo</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Expiração</TableHead>
                  <TableHead>Data Cadastro</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {stats?.subs?.map((sub: any) => (
                  <TableRow key={sub.id}>
                    <TableCell className="font-medium">
                      {sub.profiles?.full_name || 'N/A'}
                    </TableCell>
                    <TableCell>{sub.profiles?.whatsapp || 'N/A'}</TableCell>
                    <TableCell>
                      <Badge variant="outline">{sub.type.toUpperCase()}</Badge>
                    </TableCell>
                    <TableCell>
                      <Badge className={sub.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}>
                        {sub.status.toUpperCase()}
                      </Badge>
                    </TableCell>
                    <TableCell>{new Date(sub.expires_at).toLocaleDateString()}</TableCell>
                    <TableCell>{new Date(sub.created_at).toLocaleDateString()}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

function StatCard({ icon: Icon, label, value, color = "text-[#1A1B1A]" }: any) {
  return (
    <Card className="bg-white border-neutral-200">
      <CardContent className="pt-6">
        <div className="flex items-center gap-4">
          <div className="p-3 bg-neutral-100 rounded-2xl">
            <Icon className="w-6 h-6 text-[#1A1B1A]" />
          </div>
          <div>
            <p className="text-xs text-neutral-500 font-bold uppercase">{label}</p>
            <p className={`text-2xl font-black ${color}`}>{value}</p>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
