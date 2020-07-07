drop  table conta_contabil_ronc;
create table conta_contabil_ronc (
  cod_empresa           char(02) not null,
  num_conta             char(23) not null,
  num_conta_reduz       char(10) not null,
  primary key (cod_empresa, num_conta)
);
