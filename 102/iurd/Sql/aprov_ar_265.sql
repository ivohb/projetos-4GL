--grade de aprovação do AR

create table aprov_ar_265 
  (
    cod_empresa       char(2) not null,
    num_aviso_rec     integer not null,
    hierarquia        integer not null,
    cod_nivel_autorid char(2) not null,
    nom_usuario_aprov char(8),
    dat_aprovacao     date,
    hor_aprovacao     char(8),
    usuario_inclusao  char(8),
    dat_inclusao      date,
    hor_inclusao      char(8)
  );

create unique index aprov_ar_265_1 on aprov_ar_265 
    (cod_empresa, num_aviso_rec, hierarquia);

create unique index aprov_ar_265_2 on aprov_ar_265 
    (cod_empresa, num_aviso_rec, cod_nivel_autorid);

create index aprov_ar_265_3 on aprov_ar_265 
    (cod_empresa, cod_nivel_autorid);


