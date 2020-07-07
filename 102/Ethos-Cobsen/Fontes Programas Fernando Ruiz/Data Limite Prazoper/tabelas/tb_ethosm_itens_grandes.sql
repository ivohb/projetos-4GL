


create table "informix".ethosm_itens_grandes
  (
   cod_empresa          char(2),
   cod_item             char(15)
);

revoke all on "informix".ethosm_itens_grandes from "public";

create unique index "informix".ix_eth_ite_grd_1 
       on "informix".ethosm_itens_grandes
      (cod_empresa, cod_item) using btree;

