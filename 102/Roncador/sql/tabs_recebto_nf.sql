--conterá o status final da NF para cada
--tipo de operação (CFOP)

create table status_nf_ronc (
  cod_empresa           char(02) not null,
  cod_operacao          char(07) not null,
  cod_status            char(01) not null,
  primary key(cod_operacao)
);

--conterá as notas fiscais recebidas
--via POL0260

create table nf_recebida_ronc (
  cod_empresa           char(02) not null,
  num_ar                integer not null,
  recebto_fiscal        date not null,
  recebto_fisico        date not null,
  cod_usuario           char(08) not null,
  dat_proces            date not null,
  hor_proces            char(08) not null,
  primary key (cod_empresa, num_ar)
);

