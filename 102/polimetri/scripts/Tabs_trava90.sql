create table usuario_oc_bloq_454 (
  nom_usuario char(08) not null,
  tip_acesso  char(01) not null,
  primary key (nom_usuario)
);

create table audit_oc_bloq_454 (
  cod_empresa  char(02) not null,
  num_oc       integer not null,
  num_versao   integer not null,
  nom_usuario  char(08) not null,
  tip_operacao char(01) not null,
  dat_operacao date not null,
  hor_operacao char(08) not null
);

create index audit_oc_bloq_454_1 on 
 audit_oc_bloq_454(cod_empresa, nom_usuario);
 
create table tabela_trava90_454 (
  cod_empresa        char(02) not null,
  cod_lin_prod       decimal(2,0) not null,
  val_med_mensal     decimal(12,2) not null,
  estoq_quando_menor decimal(12,3) not null,
  estoq_quando_maior decimal(12,3) not null,
  lote_quando_menor  decimal(12,3) not null,
  lote_quando_maior  decimal(12,3) not null,
  limit_quando_menor decimal(12,3) not null,
  limit_quando_maior decimal(12,3) not null,
  num_versao         decimal(12,3) not null,
  ies_versao_atual   char(01) not null,
  nom_usuario_cad    char(08) not null,
  dat_cadast         date not null,
  hor_cadast         char(08) not null,
  primary key (cod_empresa, cod_lin_prod, num_versao)
);

create unique index tab_trava90_454_1 on
 tabela_trava90_454(cod_empresa, cod_lin_prod, ies_versao_atual)

create table conta_contabil_454 (
  cod_empresa  char(02) not null,
  num_conta    char(23) not null,
  primary key (cod_empresa, num_conta)
);

CREATE TABLE mapa_compras_obs_454(
   cod_empresa     CHAR(02),
   chave_processo dec(12,0),
   cod_item        CHAR(15),
   num_seq         DEC(2,0),
   Texto           CHAR(60)
   );                                                                                 

create unique index map_comp_obs_01 on
   mapa_compras_obs_454(cod_empresa, chave_processo, cod_item,num_seq );


CREATE TABLE item_criticado_bi_454(
      chave_processo DECIMAL(12,0),
      cod_empresa    CHAR(02),
      num_oc         INTEGER,
      cod_item       CHAR(15),
      seq_periodo    INTEGER,
      mensagem       CHAR(240),
      cod_lin_prod   DECIMAL(2,0),
      id_prog_ord    INTEGER
);


create table oc_bloqueada_454 
  (
      chave_processo DECIMAL(12,0) not null,
      cod_empresa    CHAR(02) not null,
      num_oc         INTEGER not null,
      mensagem       CHAR(240),
      primary key (chave_processo,cod_empresa,num_oc)
  );


CREATE TABLE prog_ord_sup_454(
      cod_empresa      CHAR(02),
      cod_item         CHAR(15),
      num_oc           INTEGER,
      num_versao       decimal(3,0),   
      num_prog_entrega decimal(3,0),   
      qtd_ajuste       DECIMAL(10,3),
      dat_entrega_prev date,
      dat_origem       date,
      tip_ajuste       CHAR(01),
      id_registro      INTEGER
);

