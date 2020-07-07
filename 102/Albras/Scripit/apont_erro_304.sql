

create table apont_erro_304
  (
    cod_empresa  char(2) not null ,
    id_man_apont integer not null ,
    den_erro     char(150)
  );

create index apont_erro_304 on apont_erro_304
(cod_empresa, id_man_apont);

