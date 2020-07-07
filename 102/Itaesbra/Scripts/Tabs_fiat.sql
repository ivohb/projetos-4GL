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
   num_reserva       INTEGER,
   num_controle      INTEGER
);

CREATE INDEX ix_carga_item_fiat_970 ON
 carga_item_fiat_970(cod_empresa, id_carga); 
