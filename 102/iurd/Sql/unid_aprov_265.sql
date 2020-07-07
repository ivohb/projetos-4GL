
create table unid_aprov_265 
  (
    cod_empresa char(2) not null ,
    nom_usuario char(8) not null ,
    cod_uni_funcio char(10) not null ,
    primary key (cod_empresa,nom_usuario,cod_uni_funcio) 
  );

create index unid_aprov_265 on unid_aprov_265 
    (cod_empresa,nom_usuario) ;


