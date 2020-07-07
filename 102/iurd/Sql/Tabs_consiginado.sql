--U00

CREATE TABLE banco_265 (
	(
	cod_banco       DECIMAL(3,0),
	den_reduz       CHAR (15),
	nom_contato     CHAR (30),
	num_agencia     CHAR (6),
	nom_agencia     CHAR (30),
	num_conta       CHAR (15),
	cod_tip_reg     CHAR (2),
	dat_termino     DATE,
	posi_header     INTEGER,
	posi_bco_header INTEGER
	);

CREATE UNIQUE INDEX banco_265_ix1
	ON banco_265 (cod_banco);


--U01

CREATE TABLE evento_265
	(
	cod_banco  DECIMAL(3,0),
	cod_evento INTEGER,
	tip_evento DECIMAL(1,0),
	estado     CHAR (2)
	);

CREATE UNIQUE INDEX evento_265_ix1
	ON evento_265 (cod_banco, cod_evento, estado);


--U02

CREATE TABLE layout_265
	(
	cod_banco DECIMAL(3,0),
	campo     CHAR (20),
	posicao   INTEGER,
	tamanho   INTEGER
	);

CREATE UNIQUE INDEX layout_265_ix1
	ON layout_265 (cod_banco, campo);

--U03

CREATE TABLE contr_consig_265
	(
	cod_empresa     CHAR (2),
	num_cpf         CHAR (19),
	num_matricula   DECIMAL(8,0),
	nom_funcionario CHAR (30),
	cod_banco       DECIMAL(3,0),
	num_contrato    CHAR (15),
	cod_tip_contr   CHAR (1),
	qtd_parcela     DECIMAL(3,0),
	val_parcela     DECIMAL(12,2),
	num_parcela     DECIMAL(2,0),
	dat_contrato    DATE,
	val_emprestimo  DECIMAL(12,2),
	dat_liquidacao  DATE,
	dat_rescisao    DATE,
	dat_afastamento DATE,
	valor_30        DECIMAL(12,2),
	cod_status      CHAR (1),
	dat_vencto      DATE,
	uf              CHAR (2),
	id_arq_banco    INTEGER
	);

CREATE UNIQUE INDEX contr_cons_265_ix1
	ON contr_consig_265 (cod_banco, num_contrato);


--U04

CREATE TABLE tip_acerto_265	(
	cod_tipo DECIMAL(2,0),
	den_tipo CHAR (30)
	);

CREATE UNIQUE INDEX tip_acerto_265_ix1
	ON tip_acerto_265 (cod_tipo);


--U05

CREATE TABLE arq_banco_265
	(
	id_registro     INTEGER,
	cod_empresa     CHAR (2),
	cod_banco       DECIMAL(3,0),
	nom_funcionario CHAR (60),
	num_cpf         CHAR (19),
	num_matricula   DECIMAL(8,0),
	dat_vencto      DATE,
	num_parcela     DECIMAL(3,0),
	qtd_parcela     DECIMAL(3,0),
	val_emprestimo  DECIMAL(12,2),
	val_parcela     DECIMAL(12,2),
	num_contrato    CHAR (12),
	dat_solicitacao DATE,
	cod_tip_contr   CHAR (1),
	dat_referencia  DATETIME YEAR TO MONTH,
	nom_arq_txt     CHAR (30),
	num_seq_txt     INTEGER,
	cod_status      CHAR (1),
	uf              CHAR (2)
	);

CREATE UNIQUE INDEX arq_banco_265_ix1
	ON arq_banco_265 (id_registro);

--U06

CREATE table ult_proces_265 (
	id_registro     INTEGER,
	dat_ult_proces  DATE
);

CREATE UNIQUE INDEX ult_proces_265_ix1
	ON ult_proces_265 (id_registro);

CREATE TABLE diverg_consig_265
	(
	id_registro     INTEGER,
	cod_empresa     CHAR (2),
	cod_banco       DECIMAL(3,0),
	num_cpf         CHAR (19),
	num_matricula   DECIMAL(8,0),
	nom_funcionario CHAR (30),
	dat_referencia  DATETIME YEAR TO MONTH,
	val_acerto      DECIMAL(12,2),
	tip_acerto      DECIMAL(1,0),
	dat_acerto_prev DATETIME YEAR TO MONTH,
	dat_acerto_real DATETIME YEAR TO MONTH,
	dat_conciliacao DATE,
	nom_usuario     CHAR (8),
	observacao      CHAR (225),
	cod_status      CHAR (1),
	tip_diverg      CHAR (1),
	dat_rescisao    DATE,
	dat_afastamento DATE,
	valor_30        DECIMAL(12,2),
	uf              CHAR (2),
	val_folha       DECIMAL(12,2),
	val_banco       DECIMAL(12,2),
	mensagem        CHAR (60),
	tip_evento      INTEGER
	);

CREATE UNIQUE INDEX div_consig_265_ix1
	ON diverg_consig_265 (id_registro);


--U07

CREATE TABLE obs_consig_265
	(
	id_registro   INTEGER,
	num_sequencia INTEGER,
	observacao    CHAR (30)
	);

CREATE UNIQUE INDEX obs_con_265_ix1
	ON obs_consig_265 (id_registro, num_sequencia);


--U08

CREATE TABLE carga_erro_265
	(
	cod_banco    DECIMAL(3,0),
	mes_ano_ref  CHAR (7),
	nom_arquivo  CHAR (25),
	num_registro CHAR (6),
	dat_proces   DATE,
	hor_proces   CHAR (8),
	den_erro     CHAR (75)
	);

CREATE INDEX carga_erro_265_ix1
	ON carga_erro_265 (cod_banco, mes_ano_ref, num_registro);


--U09

CREATE TABLE hist_movto_265
	(
	cod_empresa    CHAR (2),
	num_matricula  DECIMAL(8,0),
	dat_referencia DATETIME YEAR TO MONTH,
	cod_tip_proc   DECIMAL(2,0),
	cod_categoria  CHAR (1),
	cod_evento     SMALLINT,
	dat_pagto      DATE,
	ies_calculado  CHAR (1),
	qtd_horas      DECIMAL(5,2),
	val_evento     DECIMAL(13,2),
	num_cpf        CHAR (14),
	uf             CHAR (2),
	cod_banco      DECIMAL(3,0),
	id_registro    INTEGER,
	cod_status     CHAR (1),
	tip_evento     DECIMAL(1,0)
	);

CREATE UNIQUE INDEX hist_movto_265_ix1
	ON hist_movto_265 (cod_empresa, id_registro);


--U10

CREATE TABLE alerta_consig_265
	(
	id_registro   INTEGER,
	num_sequencia INTEGER,
	dat_gravacao  DATE,
	observacao    CHAR (75)
	);

CREATE UNIQUE INDEX alerta_con_265_ix1
	ON alerta_consig_265 (id_registro, num_sequencia);

--U11

CREATE TABLE contr_audit_265
	(
	cod_empresa  CHAR (2),
	nom_usuario  CHAR (8),
	num_contrato CHAR (12),
	den_operacao CHAR (10),
	dat_operacao DATETIME YEAR TO SECOND,
	cod_banco    DECIMAL(3,0)
	);

CREATE INDEX contr_audit_265
	ON contr_audit_265 (num_contrato);

--U12

CREATE TABLE cracha_imp_265
	(
	cod_empresa     CHAR (2) not null,
	num_matricula   CHAR (8) not null,
  nom_funcionario CHAR(30) not null,
  dat_validade    DATE not null
  );  

CREATE UNIQUE INDEX cracha_imp_265_ix1
	ON cracha_imp_265 (cod_empresa, num_matricula);

--U13

CREATE TABLE banco_hist_265 (
	cod_banco       DECIMAL(3,0),
	descricao       CHAR (30)
);

--U14

CREATE TABLE func_hist_265 (
	num_cpf         CHAR(19),
	num_contrato    CHAR(20)
);
