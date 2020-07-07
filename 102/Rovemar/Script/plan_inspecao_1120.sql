
create table plan_inspecao_1120 
  (
    cod_empresa    char(2) not null ,
    cod_item       char(15) not null ,
    cod_operac     char(5) not null ,
    num_seq_operac decimal(3,0) not null ,
    cod_roteiro    char(15) not null ,
    num_cota       decimal(6,0) not null ,
    sequencia_cota decimal(6,0) not null ,
    cota           decimal(6,0),
    cod_unid_med   char(3) not null ,
    val_nominal    decimal(10,4) not null ,
    variacao_menor decimal(10,4) not null ,
    variacao_maior decimal(10,4) not null ,
    imprime_ind    char(1) not null ,
    qtd_pecas      decimal(6,0),
    frequencia     char(5),
    texto          varchar(250)
  );




