

--- tabela de feriados especifica para geracao das data limites
--- das operacoes de fabricacao das ordens de producao

drop table ethosm_fer_prz;

create table "informix".ethosm_fer_prz
  (
   cod_empresa          char(2),
   dat_ref              date,
   ies_situa            char(1)  
);

revoke all on "informix".ethosm_fer_prz from "public";

create unique index "informix".ix_eth_fer_prz_1 
       on "informix".ethosm_fer_prz
      (cod_empresa, dat_ref) using btree;

