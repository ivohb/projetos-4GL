create table linha_547 (
  cod_empresa    char(02),
  cod_linha      char(02),
  primary key(cod_empresa, cod_linha)
);

create table predio_547 (
  cod_empresa     char(02),
  cod_predio      char(02),
  primary key(cod_empresa, cod_predio)
);

create table andar_547 (
  cod_empresa     char(02),
  cod_andar       char(02),          
  primary key(cod_empresa, cod_andar)
);

create table apto_547 (
  cod_empresa     char(02),
  cod_apto        char(02),          
  primary key(cod_empresa, cod_apto)
);

create table relacto_547 (
  cod_empresa     char(02),
  cod_relac       char(10),
  cod_linha       char(02),
  cod_predio      char(02),
  cod_andar       char(02),
  cod_apto        char(02),    
  den_relac       char(30),
  primary key(cod_empresa, cod_relac)
);
