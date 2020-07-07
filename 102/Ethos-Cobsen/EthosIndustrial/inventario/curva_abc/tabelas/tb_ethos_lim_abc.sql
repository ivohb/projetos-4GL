--- tabela de limites percentuais para classificacao da curva abc

drop table lim_abc;

create table "informix".ethos_lim_abc 
  (
    cod_empresa      char(02),
    cod_classe       char(01),
    perc_ini         decimal(5,2),
    perc_fim         decimal(5,2),
    ciclo_cta        decimal(3,0)
  );

revoke all on "informix".ethos_lim_abc from "public" as "informix";


create unique index "informix".ix_eth_lim_abc_1 
    on "informix".ethos_lim_abc 
    (cod_empresa, cod_classe) using btree ;

