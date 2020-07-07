create table ciclo_peca_454
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    cod_operac  char(05) not null,
    num_seq_operac decimal(3,0) not null,  
    qtd_ciclo_peca integer not null ,
    qtd_peca_ciclo integer not null 
  );

create unique index ciclo_peca_454  on ciclo_peca_454
    (cod_empresa,cod_item, num_seq_operac);




