import { createFileRoute } from '@tanstack/react-router';
import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { getSubscriptionStatus, getProfile } from '@/lib/auth';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Download, PlayCircle, Clock, AlertTriangle, CreditCard } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { useEffect, useState } from 'react';

export const Route = createFileRoute('/_authenticated/dashboard')({
  component: Dashboard,
});

function Dashboard() {
  const [timeLeft, setTimeLeft] = useState<string>('');

  const { data: user } = useQuery({
    queryKey: ['user'],
    queryFn: async () => {
      const { data: { user } } = await supabase.auth.getUser();
      return user;
    }
  });

  const { data: profile } = useQuery({
    queryKey: ['profile', user?.id],
    queryFn: () => getProfile(user!.id),
    enabled: !!user
  });

  const { data: sub } = useQuery({
    queryKey: ['subscription', user?.id],
    queryFn: () => getSubscriptionStatus(user!.id),
    enabled: !!user,
    refetchInterval: 10000 // Refetch every 10s to check for expiry
  });

  useEffect(() => {
    let timer: NodeJS.Timeout | undefined;
    if (sub?.type === 'trial' && sub.status === 'active') {
      timer = setInterval(() => {
        const now = new Date().getTime();
        const expiry = new Date(sub.expires_at).getTime();
        const diff = expiry - now;

        if (diff <= 0) {
          setTimeLeft('Expirado');
          if (timer) clearInterval(timer);
        } else {
          const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
          const seconds = Math.floor((diff % (1000 * 60)) / 1000);
          setTimeLeft(`${minutes}m ${seconds}s`);
        }
      }, 1000);
    }
    return () => {
      if (timer) clearInterval(timer);
    };
  }, [sub]);

  if (!user) return null;

  const isActive = sub && sub.status === 'active' && !sub.isExpired;

  return (
    <div className="min-h-screen bg-[#F7F1EB] p-4 md:p-8">
      <div className="max-w-6xl mx-auto space-y-8">
        <header className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
          <div>
            <h1 className="text-3xl font-bold text-[#1A1B1A]">Bem-vindo, {profile?.full_name || user.email}</h1>
            <p className="text-neutral-500">Painel do Membro LOVABLACK</p>
          </div>
          <Button variant="outline" onClick={() => supabase.auth.signOut()}>Sair</Button>
        </header>

        {!sub && (
          <Card className="border-red-200 bg-red-50">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-red-700">
                <AlertTriangle /> Nenhuma Assinatura Ativa
              </CardTitle>
              <CardDescription className="text-red-600">
                Você ainda não possui um plano ativo ou teste grátis.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Button onClick={() => window.location.href = '/#pricing'} className="bg-[#DC0D0D]">Escolher Plano</Button>
            </CardContent>
          </Card>
        )}

        {sub && sub.isExpired && (
          <Card className="border-orange-200 bg-orange-50">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-orange-700">
                <Clock /> Acesso Expirado
              </CardTitle>
              <CardDescription className="text-orange-600">
                Seu tempo de {sub.type === 'trial' ? 'teste' : 'assinatura'} acabou.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Button onClick={() => window.location.href = '/#pricing'} className="bg-[#1A1B1A]">Renovar Acesso</Button>
            </CardContent>
          </Card>
        )}

        {isActive && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <Card className="bg-white border-neutral-200 shadow-sm">
              <CardHeader>
                <div className="flex justify-between items-start">
                  <div>
                    <CardTitle className="text-2xl font-bold">Extensão LOVABLACK</CardTitle>
                    <CardDescription>Versão mais recente disponível</CardDescription>
                  </div>
                  <Badge className={sub.type === 'trial' ? 'bg-[#DC0D0D]' : 'bg-[#1A1B1A]'}>
                    {sub.type === 'trial' ? 'TESTE GRÁTIS' : 'PLANO ATIVO'}
                  </Badge>
                </div>
              </CardHeader>
              <CardContent className="space-y-6">
                {sub.type === 'trial' && (
                  <div className="p-4 bg-[#F7F1EB] rounded-2xl flex items-center justify-between">
                    <span className="text-sm font-bold text-[#4F4E4D]">Tempo Restante:</span>
                    <span className="text-2xl font-black text-[#DC0D0D]">{timeLeft}</span>
                  </div>
                )}
                <Button className="w-full h-16 text-lg font-bold bg-[#1A1B1A] gap-3">
                  <Download className="w-6 h-6" /> BAIXAR EXTENSÃO (.ZIP)
                </Button>
                <p className="text-xs text-center text-neutral-400">Compatível com Chrome, Brave, Edge e Opera.</p>
              </CardContent>
            </Card>

            <Card className="bg-white border-neutral-200 shadow-sm">
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Tutorial de Uso</CardTitle>
                <CardDescription>Aprenda a instalar e usar em 2 minutos</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="aspect-video bg-neutral-900 rounded-2xl flex items-center justify-center relative group cursor-pointer overflow-hidden">
                  <PlayCircle className="w-16 h-16 text-white opacity-50 group-hover:opacity-100 transition-opacity" />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
                  <span className="absolute bottom-4 left-4 text-white font-bold text-sm">COMO INSTALAR O LOVABLACK</span>
                </div>
              </CardContent>
            </Card>
          </div>
        )}

        {isActive && sub.type === 'trial' && (
          <Card className="bg-gradient-to-r from-[#DC0D0D] to-[#650000] text-white border-0">
            <CardHeader>
              <CardTitle>Gostou do LOVABLACK?</CardTitle>
              <CardDescription className="text-white/80">Garanta acesso ilimitado sem limite de tempo.</CardDescription>
            </CardHeader>
            <CardContent>
              <Button className="bg-white text-[#DC0D0D] hover:bg-neutral-100 font-bold" onClick={() => window.location.href = '/#pricing'}>
                <CreditCard className="w-4 h-4 mr-2" /> VER PLANOS ILIMITADOS
              </Button>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
}
