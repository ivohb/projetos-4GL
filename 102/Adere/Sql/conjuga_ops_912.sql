
create table conjuga_ops_912 
  (
    cod_empresa     char(2) not null ,
    id_registro     integer,
    num_seq         integer not null,
    num_ordem       integer,
    num_seq_operac  DEC(3,0),
    qtd_ciclos_peca integer not null,
    qtd_pecas_ciclo integer not null,
    dat_inclusao    date not null,
    hor_inclusao    char(08) not null,
    nom_usuario     char(08) not null   );

create unique index ix1_conjuga_ops on conjuga_ops_912
    (cod_empresa,num_ordem, num_seq_operac)  ;

create unique index ix2_conjuga_ops on conjuga_ops_912
    (cod_empresa,id_registro, num_seq)  ;