--- Tabela provisória para transferir os estoque dos locais
--- padrão para o local da OP por não usar o programa 
--- transcol.

drop table ethosm_provis_trest;

create table "informix".ethosm_provis_trest
  (
    cod_empresa      char(02),
    cod_item         char(15),
    qtde_trans       decimal(17,6),
    local_destino    char(10)
  );

revoke all on "informix".ethosm_provis_trest from "public";

create unique index "informix".ix_eth_prov_trest_1 
    on "informix".ethosm_provis_trest
    (cod_empresa, cod_item,
     local_destino) using btree;

alter table ethosm_provis_trest lock mode (row);