create table apont_proces_405 (
  cod_empresa    char(2)  not null ,
  id_man_apont   integer  not null,
  num_processo   integer  not null,
  num_seq_mestre integer  not null
);

create index apont_proces_405 on apont_proces_405 
    (cod_empresa,id_man_apont);
