--- Tabela de quantidade de itens por classe da classificação
--- processada e quantidade de itens a contar.

drop table ethos_itens_cla_cta;

create table "informix".ethos_itens_cla_cta
  (
    cod_empresa      char(02),
    data_class       date,
    hora_class       char(08),
    cod_classe       char(01),
    qtde_itens       decimal(6,0),
    qtde_contar_dia  decimal(6,0)
  );

revoke all on "informix".ethos_itens_cla_cta from "public" as "informix";


create unique index "informix".ix_eth_ite_cla_cta_1 
    on "informix".ethos_itens_cla_cta
    (cod_empresa, cod_classe, data_class, hora_class) using btree ;

create index "informix".ix_eth_ite_cla_cta_2 
    on "informix".ethos_itens_cla_cta
    (cod_empresa, data_class, hora_class) using btree ;
