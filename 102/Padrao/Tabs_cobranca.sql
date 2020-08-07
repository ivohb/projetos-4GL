

CREATE TABLE param_cobranca_912 (
 id_registro          INTEGER,
 cod_cliente          VARCHAR(15),
 vencidos_de          DECIMAL(3,0),
 vencidos_ate         DECIMAL(3,0),
 enviar_cobranca      VARCHAR(01),
 repetir_cobranca     VARCHAR(01),
 repetir_cob_apos     DECIMAL(3,0),
 limite_saldo         DECIMAL(12,2),
 enviar_lembrete      VARCHAR(01), 
 repetir_lembrete     VARCHAR(01),
 repetir_lemb_apos    DECIMAL(3,0),
 vencer_ate           DECIMAL(3,0),
 emitente_email       VARCHAR(08),
 email1_cliente       VARCHAR(50),
 email2_cliente       VARCHAR(50),
 email3_cliente       VARCHAR(50),
 observacao           VARCHAR(120),
 primary key(id_registro)
);

CREATE UNIQUE INDEX param_cobranca_912 ON 
  param_cobranca_912(cod_cliente);


create table mensagem_envio_912(
 cod_empresa    VARCHAR(02),
 cod_usuario    VARCHAR(08),
 dat_proces     DATE,
 hor_proces     VARCHAR(08),
 mensagem       VARCHAR(150)
);

CREATE INDEX mensagem_envio_912 ON 
  mensagem_envio_912(cod_empresa);


create table proces_cobranca_912 (
 empresa         VARCHAR(02),
 processando     VARCHAR(01),
 dat_proces      VARCHAR(20),
 primary key(empresa)
);

create table docum_enviado_912 (
  id_registro        INTEGER,
  cod_empresa        VARCHAR(02),
  cod_cliente        VARCHAR(15),
  cod_emitente       VARCHAR(08),
  num_docum          VARCHAR(15),
  dat_vencto         DATE,
  dat_envio          DATE,
  dias_atraso        DECIMAL(18,0),
  ies_enviado        VARCHAR(01),
  tip_envio          VARCHAR(01),
  primary key(id_registro)
);

create table client_enviado_912 (
  cod_empresa        VARCHAR(02),
  cod_cliente        VARCHAR(15),
  dat_envio          DATE,
  tip_envio          VARCHAR(01),
  primary key(cod_empresa, cod_cliente, tip_envio)
);
  