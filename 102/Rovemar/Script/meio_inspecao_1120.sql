create table meio_inspecao_1120 
  (
    cod_empresa    char(2) not null ,
    cod_item       char(15) not null ,
    cod_operac     char(5) not null ,
    num_seq_operac decimal(3,0) not null ,
    cod_roteiro    char(15) not null ,
    num_cota       decimal(6,0) not null ,
    sequencia_cota decimal(6,0) not null ,
    meio_inspecao  char(15) not null, 
    cota           decimal(6,0)
  );


create index ix_meio_inspecao_1 on meio_inspecao_1120 
    (cod_empresa,cod_item,cod_operac,num_seq_operac,num_cota,
     sequencia_cota) using btree ;

