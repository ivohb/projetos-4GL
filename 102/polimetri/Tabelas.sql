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

