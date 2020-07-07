--- tabela de parametros dos relatórios gerados de 
--- de contagem pela curva ABC

drop table ethos_par_rel_inv;

create table "informix".ethos_par_rel_inv 
  (
    cod_empresa      char(02),
    data_class       date,
    hora_class       char(08),
    tot_ite_cta_dia  decimal(6,0),
    tot_ger_cta_item decimal(6,0),
    per_ini          date,
    per_fim          date,
    dias_uteis_efet  decimal(6,0),
    capacid_cta_per  decimal(6,0),
    ite_ficaram_fora decimal(6,0)
  );

revoke all on "informix".ethos_par_rel_inv from "public" as "informix";

create unique index "informix".ix_eth_par_rel_inv_1 
       on "informix".ethos_par_rel_inv 
      (cod_empresa, data_class, hora_class) using btree ;

