
create table laudo_usu_petrom 
  (
    cod_empresa char(2) not null,
    cod_usuario char(8) not null
  );

create unique index ix_lau_usu_1 
   on laudo_usu_petrom(cod_empresa,cod_usuario);