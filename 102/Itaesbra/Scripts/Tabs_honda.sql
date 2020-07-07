CREATE TABLE ped_seq_ped_cliente
    (
    empresa      CHAR (2),
    pedido       INTEGER,
    seq_item_ped INTEGER,
    xped         CHAR (15),
    nitemped     INTEGER,
    PRIMARY KEY (empresa, pedido, seq_item_ped)
    );

CREATE UNIQUE INDEX 15713_77551941
    ON ped_seq_ped_cliente (empresa, pedido, seq_item_ped);


CREATE TABLE ped_itens_mgr
    (
    cod_empresa   CHAR (2),
    num_pedido    INTEGER,
    num_sequencia INTEGER,
    handling      VARCHAR (25),
    estoquista    VARCHAR (36)
    );

CREATE UNIQUE INDEX ix_ped_itens_mgr
    ON ped_itens_mgr (cod_empresa, num_pedido, num_sequencia);



CREATE TABLE ped_item_edi
    (
    cod_empresa        CHAR (2),
    num_pedido         DECIMAL(6,0),
    prz_entrega        DATE,
    num_contrato       VARCHAR (100),
    num_sequencia      INTEGER,
    cod_item           VARCHAR (15),
    qtd_solic          DECIMAL(10,3),
    cod_fabrica        CHAR (7),
    cod_doca           CHAR (5),
    hora               CHAR (5),
    tipo_prg_honda     CHAR (2),
    slip_number_honda  CHAR (14),
    seppen_honda       CHAR (10),
    lote_prod_honda    CHAR (12),
    cpi_honda          CHAR (3),
    observacao_honda   CHAR (20),
    hora_entrega_honda CHAR (4),
    handling           CHAR (25),
    estoquista         CHAR (36),
    planta             CHAR (5),
    unidade_medida     CHAR (2),
    embalagem          CHAR (10),
    tipo_prg           CHAR (1),
    tipo_opr           CHAR (1),
    qtd_pcp            DECIMAL(10,3),
    qtd_expedicao      DECIMAL(10,3)
    );

CREATE UNIQUE INDEX ix_ped_item_edi
    ON ped_item_edi 
 (cod_empresa, num_pedido, prz_entrega, num_contrato, num_sequencia, cod_item, hora);

CREATE INDEX ped_item_edi_02
    ON ped_item_edi (cod_empresa, num_pedido, num_sequencia);



CREATE TABLE ped_item_sel_912 (
   cod_empresa       CHAR(02),
   num_pedido        INTEGER,
   num_sequencia     INTEGER,
   usuario           CHAR(08)
);

CREATE UNIQUE INDEX ix_ped_item_sel_912 ON
 ped_item_sel_912(cod_empresa, num_pedido, num_sequencia); 

create table etiqueta_912(
   id_registro   INTEGER,
   cod_empresa   CHAR(02), 
   den_empresa   CHAR(36),               
   num_om        INTEGER,      
   num_pedido    INTEGER,     
   num_seq       INTEGER,     
   cod_item      CHAR(15),    
   den_item      CHAR(76),    
   peso_unit     DECIMAL(12,5),      
   item_cliente  CHAR(30),
   cod_cliente   CHAR(15),    
   nom_cliente   CHAR(36),      
   num_lote      CHAR(15),      
   qtd_lote      DECIMAL(10,3),  
   qtd_etiqueta  INTEGER,    
   peso_item     DECIMAL(12,5),
   cod_embal     CHAR(03),
   peso_embal    DECIMAL(12,5),    
   dat_user      CHAR(30),
   ies_impressao CHAR(01),
   qtd_embal     DECIMAL(10,3),    
   primary key(cod_empresa, id_registro)
);                  

create INDEX ix_etiqueta_912 ON
 etiqueta_912(cod_empresa, num_om, num_pedido, cod_item);

create table oper_transf_lot_912 (
 cod_empresa          CHAR(02),
 cod_oper_sai         CHAR(04),
 cod_oper_ent         CHAR(04)
 primary key(cod_empresa)
);

create table cliente_lote_912 (
 cod_cliente          CHAR(15),
 num_lote             CHAR(15),
 primary key(cod_cliente,num_lote)
);

create table client_dev_mat_912 (
 cod_cliente          CHAR(15),
 primary key(cod_cliente)
);

create table natoper_dev_mat_912 (
 cod_nat_oper     INTEGER,
 primary key(cod_nat_oper)
);


CREATE TABLE num_solicit_970 (
    cod_empresa      CHAR(02),
    num_solicit      INTEGER,
    primary key(cod_empresa)
   );
   
create table cliente_agrupa_970 (
 cod_cliente  char(15),
 primary key(cod_cliente)
);



CREATE TABLE carga_mestre_912 (
   cod_empresa       CHAR(02),
   num_carga         INTEGER,
   dat_carga         DATE,
   cod_user          CHAR(08),
   ies_impressao     CHAR(01),
   ies_romaneio      CHAR(01)
);

create UNIQUE INDEX ix_carga_mestre_912 ON
 carga_mestre_912(cod_empresa, num_carga); 

CREATE TABLE carga_item_912 (
   cod_empresa       CHAR(02),
   num_carga         INTEGER,
   num_om            INTEGER,
   cod_cliente       CHAR(15),
   num_pedido        INTEGER,
   num_sequencia     INTEGER,
   cod_item          CHAR(15),
   num_lote          CHAR(15),
   cod_local         CHAR(10),
   qtd_lote          DECIMAL(10,3),
   qtd_etiqueta      DECIMAL(4,0),
   qtd_embal         DECIMAL(8,0),
   num_reserva       INTEGER
);

CREATE INDEX ix_carga_item_912 ON
 carga_item_912(cod_empresa, num_carga); 


CREATE TABLE carga_fiat_970 (
    id_carga         INTEGER,
    dat_geracao      DATE,
    cod_empresa      CHAR(02),
    nom_carga        CHAR(30),
    cod_cliente      CHAR(15),
    num_solicit      INTEGER,  
    cod_usuario      CHAR(08),  
    ies_situa        CHAR(10)
    primary key(id_carga)
   );

create UNIQUE INDEX ix_carga_fiat_970 ON
 carga_fiat_970(cod_empresa, nom_carga);     

CREATE TABLE carga_item_fiat_970 (
   id_carga          INTEGER,
   cod_empresa       CHAR(02),
   num_om            INTEGER,
   cod_cliente       CHAR(15),
   num_pedido        INTEGER,
   num_sequencia     INTEGER,
   cod_item          CHAR(15),
   num_lote          CHAR(15),
   cod_local         CHAR(10),
   qtd_lote          DECIMAL(10,3),
   qtd_etiqueta      DECIMAL(4,0),
   qtd_embal         DECIMAL(8,0),
   num_reserva       INTEGER
);

CREATE INDEX ix_carga_item_fiat_970 ON
 carga_item_fiat_970(cod_empresa, id_carga); 

drop table embal_itaesbra
create table embal_itaesbra 
  (
    cod_empresa char(2) not null ,
    cod_cliente char(15) not null ,
    cod_item char(15) not null ,
    cod_tip_venda decimal(2,0) not null ,
    cod_embal char(3),
    ies_tip_embal char(1) not null ,
    qtd_padr_embal decimal(12,3) not null ,
    vol_padr_embal decimal(9,3) not null ,
    contner char(15),
    dloc char(12),
    doc char(3),
    stck char(5)
  );


create unique index ix_embal_ita1 on 
    embal_itaesbra (cod_empresa,cod_cliente,cod_item,cod_tip_venda,
    cod_embal,ies_tip_embal) ;
    
create index ix_embal_ita2 on embal_itaesbra 
    (cod_empresa,cod_cliente,cod_item,cod_tip_venda,ies_tip_embal)  ;


