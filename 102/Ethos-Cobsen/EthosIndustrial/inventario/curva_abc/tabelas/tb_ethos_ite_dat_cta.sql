--- tabela de itens e suas datas de contagem pela curva abc

drop table ethos_ite_dat_cta;

create table "informix".ethos_ite_dat_cta 
  (
    cod_empresa      char(02),
    data_class       date,
    hora_class       char(08),
    cod_classe       char(01),
    cod_item         char(15),
    unidade          char(03),
    data_cta         date,
    cod_familia      char(03)
  );

revoke all on "informix".ethos_ite_dat_cta from "public" as "informix";


create unique index "informix".ix_eth_dat_cta_1 
       on "informix".ethos_ite_dat_cta 
      (cod_empresa, data_class, hora_class, cod_classe, 
       cod_item, data_cta) using btree ;

create index "informix".ix_eth_ite_dat_cta_2 
       on "informix".ethos_ite_dat_cta 
      (cod_empresa, data_class, hora_class) using btree ;
