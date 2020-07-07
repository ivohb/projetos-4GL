

CREATE TABLE cliente_email_912 (
 id_registro          INTEGER,
 cod_cliente          CHAR(15),
 qtd_dias_envio       DEC(3,0),
 qtd_dias_renvio      DEC(3,0),
 ies_enviar           CHAR(01),
 emitente_email       CHAR(08),
 email_cliente        CHAR(120),
 limite_saldo         decimal(12,2),
 observacao           CHAR(120),
 primary key(id_registro)
);

CREATE UNIQUE INDEX cliente_email_912 ON 
  cliente_email_912(cod_cliente);

create table mensagem_pol1341(
 cod_empresa    CHAR(02),
 cod_usuario    CHAR(08),
 dat_proces     CHAR(20),
 mensagem       CHAR(150)
);

CREATE INDEX mensagem_pol1341 ON 
  mensagem_pol1341(cod_empresa);


create table proces_pol1341 (
 empresa         CHAR(02),
 processando     CHAR(01),
 dat_proces     CHAR(20),
 primary key(empresa)
);

create table titulo_cobrado_912 (
  id_registro        INTEGER,
  cod_empresa        CHAR(02),
  cod_cliente        CHAR(15),
  cod_emitente       CHAR(08),
  num_docum          CHAR(15),
  dat_vencto         date,
  dat_cobranca       date,
  dat_processo       date,
  dias_atraso        decimal(18,0),
  ies_enviado        CHAR(01),
  primary key(id_registro)
);


create table cliente_cobrado_912 (
  cod_empresa        CHAR(02),
  cod_cliente        CHAR(15),
  dat_cobranca       date,
  primary key(cod_empresa, cod_cliente)
);
  