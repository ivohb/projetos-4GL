create table empresa_manut_ind_1099 (
  cod_empresa        char(02) not null,
  dat_corte          date not null,
  usuario_email      char(08) not null
  primary key (cod_empresa)
);

create table usuario_manut_ind_1099 (
  cod_empresa        char(02) not null,
  nom_usuario        char(08) not null,
  ies_tip_os         char(01) not null,
  primary key (cod_empresa, nom_usuario, ies_tip_os)
);

create table nf_proces_1099  (
  id_nf_proces           integer,
  cod_empresa            char(02),
  num_transac            integer,
  seq_item_nf            integer,
  cod_nat_oper           integer,
  primary key (id_nf_proces)
);

create unique index ix1_nf_proces_1099 on
 nf_proces_1099(cod_empresa, num_transac, seq_item_nf)

create table nf_item_proces_1099  (
  id_nf_proces           integer,
  cod_item               char(15),
  qtd_item               decimal(10,3),
  cod_operac             char(05),
  num_seq_operac         integer,
  cod_equip              char(15)
);

  
create table erro_contagem_1099 (
  cod_empresa        char(02),
  num_transac        integer,
  den_erro           char(500),
  dat_ini_proces     date,
  hor_ini_proces     char(08)
);

create table erro_email_1099 (
  cod_empresa        char(02),
  num_os             char(10),
  den_erro           char(500),
  dat_ini_proces     date,
  hor_ini_proces     char(08)
);

create table os_email_1099 (
  cod_empresa          char(02),  
  num_os               char(10),
  cod_equip            char(15),
  ies_tip_os           char(01),
  dat_base             date
);
 

create unique index ix1_os_email_1099 on
 os_email_1099(cod_empresa, num_os, cod_equip, ies_tip_os)