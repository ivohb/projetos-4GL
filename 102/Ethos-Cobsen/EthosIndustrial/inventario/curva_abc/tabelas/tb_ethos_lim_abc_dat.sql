--- tabela de limites percentuais para classificacao da curva abc
--- da classificação processada

drop table ethos_lim_abc_dat;

create table "informix".ethos_lim_abc_dat 
  (
    cod_empresa      char(02),
    cod_classe       char(01),
    perc_ini         decimal(5,2),
    perc_fim         decimal(5,2),
    ciclo_cta        decimal(3,0),
    data_class       date,
    hora_class       char(08)
  );

revoke all on "informix".ethos_lim_abc_dat from "public" as "informix";


create unique index "informix".ix_eth_lim_abc_dat_1 
    on "informix".ethos_lim_abc_dat
    (cod_empresa, cod_classe, data_class, hora_class) using btree ;

create index "informix".ix_eth_lim_abc_dat_2 
    on "informix".ethos_lim_abc_dat
    (cod_empresa, data_class, hora_class) using btree ;
