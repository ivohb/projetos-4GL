create table oc_bloqueada_1099 (
 cod_empresa  char(02),
 num_oc       integer,
 pre_unit_oc  decimal(17,6),
 pre_unit_ant decimal(17,6),
 causa        char(30),
 tip_liberac  char(01),
 motivo       char(210),
 nom_usuario  char(08),
 dat_liberac  date,
 hor_liberac  char(08),
 oc_pre_ant   integer,
 primary key (cod_empresa, num_oc)
);

-- alter table oc_bloqueada_1099 add oc_pre_ant   integer

create table usuario_desblok_oc_1099 (
  nom_usuario char(08) not null,
  cod_funcao  char(08) not null, --C=Consultar L=Liberar 
  primary key (nom_usuario)
)

create table familia_oc_1099 (
 cod_empresa char(02) not null,
 cod_familia char(03) not null,
 primary key (cod_empresa, cod_familia)
);