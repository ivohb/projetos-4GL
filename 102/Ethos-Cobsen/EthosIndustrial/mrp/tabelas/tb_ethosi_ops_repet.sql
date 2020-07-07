--- TABELA DAS OP´S QUE FORAM GERADAS REPETIDAS POR CONTA DA ESTRURA QUE SERÁ
--- UTILIZADO PARA AGRUPAR AS OP´S NA APLICAÇÃO ETHOSI0030

drop table ethosi_ops_repet;

create table "informix".ethosi_ops_repet
  (
    cod_empresa             char(02),
    cod_item                char(15),
    qtde_repetida           decimal(10,0),
    dat_inclus             date,
    hor_inclus             char(08)
 );

revoke all on "informix".ethosi_ops_repet from "public";

create unique index "informix".ix_ethi_ops_repet_1 
       on "informix".ethosi_ops_repet
      (cod_empresa, cod_item,
       dat_inclus, hor_inclus) using btree;

create index "informix".ix_ethi_ops_repet_2
       on "informix".ethosi_ops_repet
      (cod_empresa, dat_inclus, 
       hor_inclus) using btree;


alter table ethosi_ops_repet lock mode (row);
