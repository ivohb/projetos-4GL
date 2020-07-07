create table apont_transac_405 (
  cod_empresa    char(2) not null ,
  id_man_apont   integer  not null,
  num_transac    integer  not null,
  tip_proces     char(01) not null
);

create index apont_transac_405 on apont_transac_405 
    (cod_empresa,id_man_apont);


