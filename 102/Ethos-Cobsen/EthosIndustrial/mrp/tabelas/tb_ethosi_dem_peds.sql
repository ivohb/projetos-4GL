--- TABELA DAS DEMANDAS E OS PEDIDOS/ITENS VINCULADOS/AGRUPADOS PARA GERAÇÃO DAS OP´S
--- UTILIZADA NA APLICAÇÃO ETHOSI0030

drop table ethosi_dem_peds;

create table "informix".ethosi_dem_peds
  (
    cod_empresa             char(02),
    dat_inclus_demanda      date,
    hor_inclus_demanda      char(08),
    num_pedido              decimal(12,0),
    num_seq_ped             decimal(5,0),
    qtd_produ_item          decimal(10,3)
 );

revoke all on "informix".ethosi_dem_peds from "public";

create unique index "informix".ix_ethi_dem_peds_1 
       on "informix".ethosi_dem_peds
      (cod_empresa, dat_inclus_demanda, 
       hor_inclus_demanda, num_pedido, 
       num_seq_ped) using btree;

create index "informix".ix_ethi_dem_peds_2
       on "informix".ethosi_dem_peds
      (cod_empresa, num_pedido, 
       num_seq_ped) using btree;


alter table ethosi_dem_peds lock mode (row);
