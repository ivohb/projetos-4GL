CREATE TABLE mapa_compras_454 ( 
   cod_empresa         CHAR(2) NOT NULL,                        
   cod_item            CHAR(15) NOT NULL,                    
   dat_realizar        DATE,                                 
   dat_falta           DATE,                                 
   ponto_corte         DATETIME YEAR to SECOND,              
   docum_corte         CHAR(10),                             
   qtd_estoque         DECIMAL(15,3),                        
   qtd_refugo          DECIMAL(15,3),                        
   qtd_prod_receb      DECIMAL(15,3),                        
   qtd_atraso          DECIMAL(15,3),                        
   qtd_atraso_entr     DECIMAL(15,3),                        
   alt_prog_firme      CHAR(6),                              
   qtd_excesso         DECIMAL(15,3),                        
   tmp_cobertura       DECIMAL(7,3),                         
   pct_compras_demanda DECIMAL(15,3),                        
   PRIMARY KEY(cod_empresa,cod_item)                         
);

CREATE TABLE mapa_compras_data_454
 (
 cod_empresa CHAR (2) NOT NULL,
 cod_item CHAR (15) NOT NULL,
 seq_campo smallint NOT NULL,
 campo CHAR(25) NOT NULL,
 seq_periodo smallint NOT NULL,
 periodo CHAR(15) NOT NULL,
 qtd_dia DECIMAL (15,3) NOT NULL,
    ies_ajustado char(1) default 'N',
    dat_entrega date, 
    chave_processo dec(12,0), 
 PRIMARY KEY(cod_empresa,cod_item,seq_campo,campo,seq_periodo,periodo)
 );
        
create index map_comp_data_1 on mapa_compras_data_454(
   cod_empresa, chave_processo);                                                                           

CREATE TABLE mapa_periodos_454(
  cod_empresa    CHAR(2) NOT NULL,
  cod_frequencia CHAR(1) NOT NULL,
  seq_periodo    smallint NOT NULL,
  periodo        CHAR(15) NOT NULL,
  dat_inicio     date NOT NULL,
  dat_fim        date NOT NULL,
  PRIMARY KEY(cod_empresa,cod_frequencia,seq_periodo)
);


-- CADASTRO ADICIONAL PARA ITENS COMPRADOS.
CREATE TABLE man_par_prog_454 (
   empresa CHAR(2)   NOT NULL,                             
   item CHAR(15)     NOT NULL,                            
   cod_frequencia    CHAR(1) NOT NULL,                   
   qtd_periodo_firme smallint,                        
   qtd_lote_minimo   DECIMAL(10,3),                     
   qtd_lote_multiplo DECIMAL(10,3),                   
   qtd_periodo_antec smallint,                        
   PRIMARY KEY (empresa,item)                         
);


CREATE TABLE mapa_compras_hist_454(
   id_registro     SERIAL,
   cod_empresa     CHAR(02),
   cod_item        CHAR(15),
   seq_campo       smallint,
   campo           CHAR(25),
   seq_periodo     smallint,
   periodo         CHAR(15),
   sdo_oc          DECIMAL(15,3),
   qtd_dia         DECIMAL(15,3),
   qtd_ajustada    DECIMAL(15,3),
   tip_ajuste      CHAR(01),
   dat_entrega     DATE,                                          
   dat_ini_periodo DATE,
   dat_fim_periodo DATE,
   usuario         CHAR(08),
   dat_proces      DATETIME YEAR TO SECOND,
   num_ocs         CHAR(30),
   chave_processo dec(12,0)
   );                                                                                 

create unique index map_aomp_hist_01 on
   mapa_compras_hist_454(cod_empresa, id_registro);
   
create index map_aomp_hist_02 on mapa_compras_hist_454(
   cod_empresa, cod_item, seq_periodo);
   
create index map_aomp_hist_03 on mapa_compras_hist_454(
   cod_empresa, chave_processo);

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
      ies_alt        CHAR(01),
      seq_periodo    INTEGER,
      sdo_oc         INTEGER, 
      qtd_suger      INTEGER, 
	    qtd_realiz     INTEGER, 
      qtd_ajust      INTEGER, 
      cod_oper       CHAR(01),
      mensagem       CHAR(800)
);
