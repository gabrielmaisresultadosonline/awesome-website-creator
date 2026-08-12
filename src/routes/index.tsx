import { createFileRoute } from "@tanstack/react-router";
import { Check, Shield, Zap, MessageSquare, FileText, Mic, Sparkles, PlusCircle, Eraser, Globe, Star, Clock, Heart, Users, ShieldCheck } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import logoHeart from "@/assets/logo-heart.png.asset.json";
import logoFull from "@/assets/logo-full.png.asset.json";

export const Route = createFileRoute("/")({
  component: Index,
  head: () => ({
    title: "LOVABLACK | Extensão Lovable Ilimitada",
    meta: [
      { name: "description", content: "Use Lovable ilimitado e grátis com a extensão LOVABLACK. Sem créditos, velocidade máxima e hospedagem inclusa." },
      { property: "og:title", content: "LOVABLACK | Extensão Lovable Ilimitada" },
      { property: "og:description", content: "O fim dos limites de créditos no Lovable. Crie sem restrições." }
    ]
  })
});

function Index() {
  const benefits = [
    { title: "Lovable Unlimited", desc: "Use o Lovable ilimitado e de graça. Crie quantos projetos quiser, sem limite de créditos.", icon: Heart },
    { title: "Velocidade Máxima", desc: "Sem filas, sem espera. Suas requisições são processadas com prioridade total.", icon: Zap },
    { title: "Hospedagem Inclusa", desc: "Publique e hospede seus projetos gratuitamente. Lovable com hospedagem sem custo extra.", icon: Globe },
    { title: "Grátis Pra Sempre", desc: "Lovable grátis pra sempre com plano acessível. Sem surpresas, sem limites.", icon: Star },
  ];

  const features = [
    { title: "Bloqueio do Chat", desc: "Bloqueie o chat da Lovable e evite que seus créditos sejam consumidos.", icon: MessageSquare },
    { title: "Envio de Arquivos", desc: "Envie qualquer tipo de arquivo diretamente no chat para usar nos seus projetos.", icon: FileText },
    { title: "Envio de Áudio", desc: "Grave e envie áudios para descrever o que precisa — sem digitar.", icon: Mic },
    { title: "IA para Prompts", desc: "IA integrada que melhora seus prompts automaticamente.", icon: Sparkles },
    { title: "Novo Projeto Grátis", desc: "Crie novos projetos sem gastar nenhum crédito.", icon: PlusCircle },
    { title: "Tirar Marca d'Água", desc: "Remova a marca d'água da Lovable para um visual profissional.", icon: Eraser },
    { title: "Hospedagem Grátis", desc: "Publique e hospede seu projeto gratuitamente.", icon: Globe },
  ];

  const plans = [
    { 
      name: "Teste Grátis", 
      price: "R$ 0", 
      period: "20 minutos", 
      features: ["Acesso total", "Ativação instantânea", "Sem compromisso"],
      button: "COMEÇAR AGORA",
      popular: false
    },
    { 
      name: "Mensal", 
      price: "R$ 47", 
      period: "por mês", 
      features: ["Prompts ilimitados", "Todos os navegadores", "Hospedagem inclusa", "Suporte WhatsApp"],
      button: "ASSINAR AGORA",
      popular: false
    },
    { 
      name: "Semestral", 
      price: "R$ 147", 
      period: "6 meses", 
      features: ["Melhor custo-benefício", "Prompts ilimitados", "Hospedagem inclusa", "Suporte Prioritário"],
      button: "GARANTIR AGORA",
      popular: true
    },
    { 
      name: "Vitalício", 
      price: "R$ 397", 
      period: "pagamento único", 
      features: ["Acesso para sempre", "Todas atualizações", "Hospedagem inclusa", "Suporte VIP"],
      button: "ACESSO VITALÍCIO",
      popular: false
    }
  ];

  return (
    <div className="min-h-screen font-sans selection:bg-primary/20" style={{ backgroundColor: "#FFFDF5" }}>
      {/* Hero Section */}
      <header className="container mx-auto px-4 pt-20 pb-16 text-center">
        <div className="flex justify-center mb-8">
          <img src={logoFull.url} alt="LOVABLACK Logo" className="h-20 md:h-28 object-contain" />
        </div>
        <Badge variant="outline" className="mb-6 border-primary/20 text-primary px-4 py-1">
          🚀 O NOVO LOVABLACK CHEGOU
        </Badge>
        <p className="text-xl md:text-2xl text-neutral-600 max-w-3xl mx-auto mb-10 leading-relaxed">
          Prepare-se para aproveitar uma experiência aprimorada e <span className="text-neutral-900 font-bold italic underline decoration-primary/30">ilimitada</span>. 
          A melhor ferramenta do mercado está de volta!
        </p>
        
        <div className="flex flex-col md:flex-row items-center justify-center gap-4 mb-12">
          <Button size="lg" className="h-14 px-8 text-lg font-bold rounded-full bg-neutral-900 text-white hover:bg-neutral-800 transition-all hover:scale-105">
            🚀 TESTE GRÁTIS 20 MIN
          </Button>
          <div className="flex items-center gap-6 text-sm text-neutral-500 font-medium">
            <span className="flex items-center gap-2"><Zap className="w-4 h-4 text-primary" /> Ativação instantânea</span>
            <span className="flex items-center gap-2"><Shield className="w-4 h-4 text-primary" /> Pagamento seguro</span>
          </div>
        </div>

        <div className="relative max-w-5xl mx-auto rounded-2xl overflow-hidden border-8 border-white shadow-2xl bg-neutral-900 aspect-video flex items-center justify-center group">
          <div className="absolute inset-0 bg-neutral-900/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center z-10 pointer-events-none">
             <Button variant="secondary" className="rounded-full h-16 w-16 p-0 shadow-lg border-white/20">
                <Zap className="fill-current w-6 h-6" />
             </Button>
          </div>
          <img src={logoHeart.url} alt="LOVABLACK Icon" className="w-32 h-32 md:w-48 md:h-48 object-contain animate-pulse" />
          <div className="absolute bottom-6 left-6 right-6 bg-white/90 backdrop-blur p-4 rounded-xl flex items-center justify-between border border-white/20 shadow-lg">
             <p className="text-sm font-bold text-neutral-900">🚀 Esse Site foi feito inteiramente por essa extensão</p>
             <Badge variant="secondary" className="bg-neutral-900 text-white border-0">GRÁTIS</Badge>
          </div>
        </div>
      </header>

      {/* Benefits */}
      <section className="py-24 bg-white/50 border-y border-neutral-100">
        <div className="container mx-auto px-4">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-neutral-900 mb-4">Por que escolher o LOVABLACK?</h2>
            <p className="text-neutral-600">Tudo o que você precisa para usar o Lovable de graça e ilimitado.</p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {benefits.map((b, i) => (
              <div key={i} className="p-8 rounded-3xl bg-white border border-neutral-100 hover:shadow-xl hover:-translate-y-1 transition-all duration-300">
                <div className="w-12 h-12 rounded-2xl bg-neutral-50 flex items-center justify-center mb-6 text-neutral-900 group-hover:bg-primary group-hover:text-white transition-colors">
                  <b.icon className="w-6 h-6" />
                </div>
                <h3 className="text-xl font-bold mb-3">{b.title}</h3>
                <p className="text-neutral-500 text-sm leading-relaxed">{b.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section className="py-24">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl mx-auto text-center mb-20">
            <h2 className="text-4xl font-bold mb-6">Tudo que a extensão faz por você</h2>
            <p className="text-neutral-600">Funcionalidades premium que tornam o Lovable ilimitado e profissional.</p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {features.map((f, i) => (
              <Card key={i} className="border-0 shadow-sm hover:shadow-md transition-all bg-white overflow-hidden group">
                <CardHeader className="pb-2">
                  <f.icon className="w-8 h-8 text-neutral-400 group-hover:text-neutral-900 transition-colors mb-2" />
                  <CardTitle className="text-lg">{f.title}</CardTitle>
                </CardHeader>
                <CardContent>
                  <CardDescription className="text-neutral-500">{f.desc}</CardDescription>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Steps */}
      <section className="py-24 bg-neutral-900 text-white rounded-[4rem] mx-4">
        <div className="container mx-auto px-4">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4">Como Usar LOVABLACK?</h2>
            <p className="text-neutral-400">Tenha Lovable unlimited em 4 passos simples.</p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            {[
              { s: "01", t: "Escolha seu plano", d: "Selecione o plano ideal para suas necessidades." },
              { s: "02", t: "Instale a extensão", d: "Chrome, Firefox, Edge ou Opera em segundos." },
              { s: "03", t: "Ative sua licença", d: "Ativação instantânea com sua chave de acesso." },
              { s: "04", t: "Lovable Unlimited", d: "Pronto! Crie e hospede sem limites de créditos." },
            ].map((step, i) => (
              <div key={i} className="relative p-6 border border-white/10 rounded-3xl hover:bg-white/5 transition-colors">
                <span className="text-5xl font-black text-white/10 absolute -top-4 -left-2">{step.s}</span>
                <h3 className="text-xl font-bold mb-3 mt-4">{step.t}</h3>
                <p className="text-sm text-neutral-400 leading-relaxed">{step.d}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Pricing */}
      <section className="py-24">
        <div className="container mx-auto px-4">
          <div className="text-center mb-16">
            <div className="inline-flex items-center gap-2 bg-neutral-100 px-4 py-2 rounded-full mb-6">
              <Users className="w-4 h-4 text-neutral-500" />
              <span className="text-sm font-bold text-neutral-600">47 pessoas estão vendo esta página agora</span>
            </div>
            <h2 className="text-4xl font-bold mb-4">Desbloqueie o LOVABLACK</h2>
            <p className="text-neutral-600">Escolha o plano ideal e comece a criar sem limites hoje.</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {plans.map((plan, i) => (
              <Card key={i} className={`relative flex flex-col border-neutral-200 transition-all hover:shadow-2xl ${plan.popular ? 'scale-105 border-neutral-900 shadow-xl z-10' : ''}`}>
                {plan.popular && (
                  <Badge className="absolute -top-3 left-1/2 -translate-x-1/2 bg-neutral-900 text-white px-4 py-1">MAIS POPULAR</Badge>
                )}
                <CardHeader>
                  <CardTitle className="text-xl">{plan.name}</CardTitle>
                  <div className="flex items-baseline gap-1 mt-2">
                    <span className="text-4xl font-black text-neutral-900">{plan.price}</span>
                    <span className="text-sm text-neutral-500">{plan.period}</span>
                  </div>
                </CardHeader>
                <CardContent className="flex-grow">
                  <ul className="space-y-4">
                    {plan.features.map((feature, j) => (
                      <li key={j} className="flex items-center gap-3 text-sm text-neutral-600">
                        <Check className="w-4 h-4 text-neutral-900 shrink-0" />
                        {feature}
                      </li>
                    ))}
                  </ul>
                </CardContent>
                <CardFooter>
                  <Button className={`w-full h-12 font-bold rounded-xl transition-all ${plan.popular ? 'bg-neutral-900 hover:bg-neutral-800' : 'bg-neutral-100 text-neutral-900 hover:bg-neutral-200 shadow-none'}`}>
                    {plan.button}
                  </Button>
                </CardFooter>
              </Card>
            ))}
          </div>
          <div className="mt-12 text-center flex items-center justify-center gap-6 text-neutral-400 text-sm">
             <span className="flex items-center gap-2"><ShieldCheck className="w-4 h-4" /> Pagamento Seguro via PIX</span>
             <span className="flex items-center gap-2 font-bold text-neutral-500 italic">⚡ Últimas vagas com este preço</span>
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section className="py-24 bg-white border-y border-neutral-100">
        <div className="container mx-auto px-4">
          <h2 className="text-4xl font-bold text-center mb-16">Quem usa recomenda</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[
              { name: "Lucas M.", role: "Dev Full-Stack", text: "Finalizei 3 projetos usando o Lovable de graça com o LOVABLACK. Antes eu ficava preso calculando créditos o tempo todo.", initials: "LM" },
              { name: "Ana Paula S.", role: "Designer UI/UX", text: "Agora tenho Lovable grátis pra sempre e posso testar todas as ideias sem me preocupar com limites. Mudou meu fluxo.", initials: "AP" },
              { name: "Rafael C.", role: "Freelancer", text: "A hospedagem grátis inclusa é um diferencial absurdo. Consigo entregar projetos maiores e mais rápido.", initials: "RC" },
            ].map((t, i) => (
              <div key={i} className="p-8 rounded-[2.5rem] bg-neutral-50 border border-neutral-100 relative">
                <Star className="w-8 h-8 text-neutral-200 absolute top-8 right-8" />
                <p className="text-lg text-neutral-700 mb-8 italic">"{t.text}"</p>
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-full bg-neutral-900 text-white flex items-center justify-center font-bold">{t.initials}</div>
                  <div>
                    <h4 className="font-bold text-neutral-900">{t.name}</h4>
                    <p className="text-sm text-neutral-500">{t.role}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Footer CTA */}
      <footer className="py-24 text-center container mx-auto px-4">
        <div className="max-w-4xl mx-auto bg-neutral-900 text-white p-12 md:p-20 rounded-[4rem] relative overflow-hidden">
           <div className="absolute top-0 right-0 w-64 h-64 bg-primary/20 blur-[100px] -translate-y-1/2 translate-x-1/2"></div>
           <h2 className="text-4xl md:text-6xl font-bold mb-8 relative z-10">Quantos projetos você deixou de criar por falta de créditos?</h2>
           <p className="text-xl text-neutral-400 mb-12 relative z-10">Isso acaba agora. Lovable ilimitado é realidade com LOVABLACK.</p>
           <Button size="lg" className="h-16 px-12 text-xl font-bold rounded-full bg-white text-neutral-900 hover:bg-neutral-100 transition-all hover:scale-105 relative z-10">
              🔥 QUERO MEU LOVABLACK AGORA
           </Button>
        </div>
        <div className="mt-20 pt-8 border-t border-neutral-100 flex flex-col md:flex-row justify-between items-center gap-6 text-neutral-400 text-sm">
           <p>© 2026 LOVABLACK. Todos os direitos reservados.</p>
           <div className="flex gap-8">
              <a href="#" className="hover:text-neutral-900 transition-colors">Termos de Uso</a>
              <a href="#" className="hover:text-neutral-900 transition-colors">Privacidade</a>
           </div>
        </div>
      </footer>
    </div>
  );
}
