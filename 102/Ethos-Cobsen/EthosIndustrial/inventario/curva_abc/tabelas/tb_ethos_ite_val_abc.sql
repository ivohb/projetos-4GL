--- tabela de itens e seu custo total para classificacao da curva abc

drop table ethos_ite_val_abc;

create table "informix".ethos_ite_val_abc 
  (
    cod_empresa      char(02),
    cod_item         char(15),
    unidade          char(03),
    cod_familia      char(03),
    qtd_estoque      decimal(15,3),
    cus_unitario     decimal(17,6),
    cus_total        decimal(17,2),
    classe_valor     char(01),
    data_class       date,
    hora_class       char(08)
  );

revoke all on "informix".ethos_ite_val_abc from "public" as "informix";


create unique index "informix".ix_eth_ite_val_abc_1 
       on "informix".ethos_ite_val_abc 
      (cod_empresa, cod_item, data_class, hora_class) using btree ;

       create index "informix".ix_eth_ite_val_abc_2 
       on "informix".ethos_ite_val_abc 
      (cod_empresa, data_class, hora_class) using btree ;

       create index "informix".ix_eth_ite_val_abc_3 
       on "informix".ethos_ite_val_abc 
      (cod_empresa, data_class, hora_class, 
       classe_valor) using btree ;
