create table cliente_msg_885 (
  dat_hor_proces   datetime,
  mensagem         char(76)
);

create table ordem_erro_885 (
  num_docum        char(15),
  mensagem         char(76),
  dat_hor_proces   datetime
);

create table apont_msg_885 (
  cod_empresa      char(02),
  dat_hor_proces   datetime,
  mensagem         char(150)
);


alter table parametros_885  add dat_corte datetime default '01/01/2012'
alter table parametros_885  add oper_entr_sucata char(04) default 'APOS'
alter table parametros_885  add oper_sai_apto_refug char(04) 


create table pol0653_msg_885 (
  dat_hor_proces   datetime,
  mensagem         char(76)
);

create table pol0654_msg_885 (
  dat_hor_proces   datetime,
  mensagem         char(76)
);


alter table umd_aparas_885 alter column fat_conversao char(20) not null


alter table insumo_885  add  dat_geracao  char(19)
alter table insumo_885 add tipestoque char(01)

alter table cont_aparas_885 add num_transac int

alter table ar_aparas_885 add ies_financeiro char(01)

alter table apont_trim_885 add tipoitem char(02) -- CX=Caixa TB=TAbuleiro CH=Chapa
alter table apont_erro_885 alter column mensagem char(150)

CREATE TABLE proces_apont_box(
	ies_proces char(1) NOT null
);

CREATE TABLE proces_apont_papel(
	ies_proces char(1) NOT null
);


dropar e recriar tabela man_apont_885
dropar tabela man_apont_hist_885

alter table apont_trans_885 drop column
alter table apont_trans_885 add ies_implant   char(01)