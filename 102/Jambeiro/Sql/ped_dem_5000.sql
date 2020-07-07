CREATE TABLE ped_dem_5000
  (
    cod_empresa  CHAR(2) NOT NULL,
    num_projeto  CHAR(08) NOT NULL,
    num_pedido   DECIMAL(6,0) NOT NULL,
    num_seq      DECIMAL(3,0) NOT NULL,
    cod_item_pai CHAR(15) NOT NULL,
    num_op_pai   INTEGER  NOT NULL,
    prz_entrega  DATE NOT NULL,
    qtd_saldo    DECIMAL(10,3) NOT NULL
  );

CREATE UNIQUE INDEX ix_ped_dem_5000 ON 
ped_dem_5000(cod_empresa,num_pedido,num_seq);
