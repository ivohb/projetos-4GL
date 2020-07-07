
create table man_apo_nest_405 
  (
    cod_empresa     char(2) not null ,
    num_programa    char(50) not null ,
    num_ordem       integer not null ,
    cod_operac      char(5),
    cod_item_compon char(15),
    qtd_produzida   decimal(10,3),
    pes_unit        decimal(14,7),
    tempo_unit      char(8),
    tip_registro    char(1) not null ,
    cod_item        char(15),
    qtd_boas        decimal(10,3),
    qtd_apontada    decimal(10,3),
    qtd_refugo      decimal(10,3),
    cod_defeito     decimal(3,0),
    pes_sucata      decimal(14,7) default 0.0000000,
    dat_proces      date,
    id_registro     integer
  );

create index i2_man_apo_nest_405 on man_apo_nest_405 
    (cod_empresa,num_programa) using btree ;

create index ix_man_apo_nest_405 on man_apo_nest_405 
    (cod_empresa,tip_registro) using btree ;


