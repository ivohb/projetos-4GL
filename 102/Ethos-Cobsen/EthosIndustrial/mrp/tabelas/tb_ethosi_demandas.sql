--- TABELA DAS DEMANDAS PARA GERAÇÃO DAS OP´S
--- UTILIZADA NA APLICAÇÃO ETHOSI0030

drop table ethosi_demandas;

create table "informix".ethosi_demandas
  (
    cod_empresa             char(02),
    nro_documento           char(10),
    pai_principal           char(15),
    prazo_entrega           date,
    qtd_a_produzir          decimal(17,3),
    dat_inclus              date,
    hor_inclus              char(08),
    ja_processado           char(01),
    usuario_inclusao        char(18),
    dat_process             date,
    hor_process             char(08)
 );

revoke all on "informix".ethosi_demandas from "public";

create unique index "informix".ix_ethi_demandas_1 
       on "informix".ethosi_demandas
      (cod_empresa, nro_documento, pai_principal, 
       dat_inclus, hor_inclus) using btree;

create index "informix".ix_ethi_demandas_2
       on "informix".ethosi_demandas
      (cod_empresa, nro_documento, 
       pai_principal, prazo_entrega) using btree;

create index "informix".ix_ethi_demandas_3
       on "informix".ethosi_demandas
      (cod_empresa, ja_processado, 
       usuario_inclusao) using btree;


alter table ethosi_demandas lock mode (row);
