--- Tabela provisória para transferir os estoque dos locais
--- padrão para o local da OP por não usar o programa 
--- transcol.

drop table ethosm_provis_trest1;

create table "informix".ethosm_provis_trest1
  (
    cod_empresa      char(02),
    cod_item         char(15),
    local_origem     char(10),
    local_destino    char(10),
    qtde_trans       decimal(17,6)
  );

revoke all on "informix".ethosm_provis_trest1 from "public";

create unique index "informix".ix_eth_prov_trest1_1 
    on "informix".ethosm_provis_trest1
    (cod_empresa, cod_item,
     local_origem, local_destino) using btree;

alter table ethosm_provis_trest1 lock mode (row);