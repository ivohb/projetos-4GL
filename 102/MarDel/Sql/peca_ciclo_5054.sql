create table peca_ciclo_5054 
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    cod_operac char(5) not null ,
    num_seq_operac decimal(3,0) not null ,
    qtd_ciclo_peca integer not null ,
    qtd_peca_ciclo integer not null 
  );


create unique index peca_ciclo_5054 on peca_ciclo_5054 
    (cod_empresa, cod_item, num_seq_operac) ;


