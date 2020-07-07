CREATE TABLE pol1309_erro_885 (
  cod_empresa     CHAR(02),
  num_romaneio    INTEGER,
  den_erro        CHAR(80),
  dat_proces      DATETIME
);

CREATE INDEX pol1309_erro_885 ON
 pol1309_erro_885(cod_empresa, num_romaneio);


CREATE TABLE solic_fatura_885 (
 cod_empresa    CHAR(02),
 num_solicit    INTEGER,
 num_om         INTEGER,
 num_pedido     INTEGER,
 seq_item       INTEGER,
 peso_liq       DECIMAL(10,2),
 peso_bruto     DECIMAL(10,2),
 num_nf         INTEGER
);

CREATE INDEX solic_fatura_885 ON
 solic_fatura_885(cod_empresa, num_solicit);


CREATE TABLE nf_ajust_885 (
 cod_empresa    CHAR(02),
 num_solicit    INTEGER,
 num_nf         INTEGER,
 dat_ajuste     DATETIME,
 peso_liq_ant   DECIMAL(10,2),
 peso_liq_atu   DECIMAL(10,2),
 peso_bru_ant   DECIMAL(10,2),
 peso_bru_atu   DECIMAL(10,2),
 ies_justific   CHAR(01)
);


CREATE UNIQUE INDEX nf_ajust_885 ON
 nf_ajust_885(cod_empresa, num_solicit, num_nf);

CREATE INDEX nf_ajust_885_2 ON
 nf_ajust_885(cod_empresa, num_solicit);
