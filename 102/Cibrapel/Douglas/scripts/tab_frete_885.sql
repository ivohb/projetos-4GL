
create table tab_frete_885 (
  tabela       int not null, --visualizar
  versao       decimal(2,0) not null,      --visualizar
  versao_atual char(01) not null,          --visualizar
  origem       char(70) not null,          --editar
  destino      char(70) not null,          --editar
  val_tonelada decimal(12,2) not null,     --editar
  primary key(tabela, versao)
);

create unique index tab_frete_885 on tab_frete_885
    (tabela, versao, versao_atual);