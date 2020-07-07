

create table apont_erro_912
  (
    cod_empresa  char(2) not null ,
    id_man_apont integer not null ,
    den_erro     char(150),
    num_ordem    integer
  );

create index apont_erro_912 on apont_erro_912
(cod_empresa, id_man_apont);

create index ix_apont_erro_912 on apont_erro_912
(cod_empresa, num_ordem);
