-- Cole tudo no SQL Editor do Supabase e clique em Run.
create table public.forms (
  slug text primary key, title text not null, subtitle text default '',
  success text default 'Recebemos suas informações. Obrigado!',
  fields jsonb not null default '[]', updated_at timestamptz default now());
create table public.responses (
  id bigint generated always as identity primary key,
  form_slug text not null references public.forms(slug) on update cascade,
  data jsonb not null, labels jsonb not null default '{}',
  status text not null default 'novo', created_at timestamptz not null default now());
create index on public.responses (form_slug, created_at desc);
alter table public.forms enable row level security;
alter table public.responses enable row level security;
create policy "forms: todos leem" on public.forms for select to anon, authenticated using (true);
create policy "forms: adm edita" on public.forms for update to authenticated using (true) with check (true);
create policy "respostas: todos enviam" on public.responses for insert to anon, authenticated
  with check (status = 'novo' and jsonb_typeof(data) = 'object' and pg_column_size(data) < 20000);
create policy "respostas: adm le" on public.responses for select to authenticated using (true);
create policy "respostas: adm atualiza" on public.responses for update to authenticated using (true) with check (true);
create policy "respostas: adm exclui" on public.responses for delete to authenticated using (true);

insert into public.forms (slug, title, subtitle, success, fields) values
('relatorio-culto','Relatório semanal de cultos','Verbo da Vida – Marcolândia – PI','Relatório enviado. Obrigado!',
$j$[{"id":"dia","label":"Dia","type":"select","required":true,"options":["Terça-feira - Culto do Espírito Santo","Quinta-feira - Culto de Ensino","Domingo - Culto da Família","Sábado - Culto de Jovens e Adolescentes","Outro"]},
{"id":"data","label":"Data do culto ou evento","type":"date","required":true},
{"id":"tipo","label":"Tipo","type":"select","required":true,"options":["Culto","Evento"]},
{"id":"inicio","label":"Início do culto","type":"time","required":true},
{"id":"termino","label":"Término do culto","type":"time","required":true},
{"id":"ministro","label":"Ministro","type":"text","required":true},
{"id":"tema","label":"Tema","type":"text","required":true},
{"id":"nascimento","label":"Novo nascimento","type":"number","required":true},
{"id":"espirito","label":"Batismo no Espírito Santo","type":"number","required":true},
{"id":"cura","label":"Oração por cura","type":"number","required":true},
{"id":"adultos","label":"Total de adultos","type":"number","required":true},
{"id":"criancas","label":"Total de crianças","type":"number","required":true},
{"id":"visitantes","label":"Total de visitantes","type":"number","required":true},
{"id":"obs","label":"Observação","type":"textarea","required":false}]$j$::jsonb),
('acolhe','Acolhe – Ficha de visitante','Que bom ter você aqui! Conte um pouco sobre você para a gente cuidar de você.','Recebemos sua ficha. Deus abençoe você!',
$j$[{"id":"data","label":"Data do culto","type":"date","required":true},
{"id":"nome","label":"Nome do visitante","type":"text","required":true},
{"id":"telefone","label":"Telefone com DDD","type":"tel","required":true},
{"id":"entregou","label":"Me entreguei para Jesus hoje","type":"yesno","required":true},
{"id":"visitando","label":"Estou apenas visitando","type":"yesno","required":true},
{"id":"desejo","label":"Desejo","type":"multi","required":true,"options":["Visita","Aconselhamento Pastoral","Mensagem SMS/WhatsApp","Ligação"]}]$j$::jsonb);
