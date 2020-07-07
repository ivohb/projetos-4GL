**************************************************************
*                 GESTÃO DE IMOVEIS - GI                     *
*                                                            *
*   SCRIPTS DE CRIAÇÃO DAS TABELAS - INTEGRAÇÃO FINANCEIRA   *
*                                                            *
**************************************************************

create table obrigacao_proces_912 (
  cod_empresa          char(02),
  id_ad                INTEGER,
  cod_fatura           INTEGER,
  num_ad               INTEGER,
  num_ar               INTEGER,
  ser_nf               CHAR(03),
  ssr_nf               INTEGER,
  num_nf               INTEGER,
  dat_proces           CHAR(19)
  primary key(id_ad)
);

create unique index ix_proces_912 on
 obrigacao_proces_912(cod_empresa, cod_fatura);
 

DROP table gi_ad_912;
create table gi_ad_912  (
   id_ad                       	INTEGER                 NOT NULL,
   cod_empresa                 	CHAR(2)                 NOT NULL,
   cod_fatura                  	INTEGER                 NOT NULL,
   cod_contrato                	INTEGER                 NOT NULL,
   cod_obrigacao               	INTEGER                 NOT NULL,
   num_ad                     	DECIMAL(6,0)               NULL,
   num_ar                      	INTEGER                 NULL,
   ser_nf                      	CHAR(03)                NULL,
   ssr_nf                      	DECIMAL(2,0)               NULL,
   num_nf                      	DECIMAL(7,0)               NOT NULL,                 
   cod_fornecedor              	CHAR(15)                NOT NULL,
   den_item 			              char(50)  		          null ,
   val_tot_nf                  	DECIMAL(15,2)            NOT NULL,
   cod_moeda                   	DECIMAL(3,0)               NOT NULL,
   cod_tip_despesa              DECIMAL(4,0)            NOT NULL,
   den_observacao              	VARCHAR(255)           NULL,
   ies_gera_nota               	CHAR(1)                 NOT NULL,
   num_lote                    	INTEGER                 NOT NULL,
   cod_situacao                	CHAR(1)                 NOT NULL,
   ies_da_bc_ipi               	char(1)                 null,
   cod_incid_ipi               	decimal(2,0)            null ,
   ies_tip_incid_ipi           	char(1)                 null ,
   pct_ipi_declarad            	decimal(6,3)            null ,
   val_base_c_ipi_it           	decimal(17,2)           null,
   val_ipi_decl_item           	decimal(17,2)           null ,
   val_ipi_desp_aces           	decimal(17,2)           null ,
   val_base_c_item_d           	decimal(17,2)           null ,
   pct_icms_item_d 		          decimal(5,3) 		        null ,
   val_icms_item_d 		          decimal(17,2) 		      null ,
   pct_red_bc_item_d 		        decimal(5,3) 		        null ,
   val_base_c_icms_da 		      decimal(17,2) 		      null ,
   val_icms_desp_aces 		      decimal(17,2) 		      null ,
   ies_incid_icms_ite 		      char(1) 		            null ,
   val_base_pis_d 		          decimal(17,6)  		      null ,
   val_base_cofins_d 		        decimal(17,6)  		      null ,
   pct_pis_item_d 		          decimal(8,6)  		      null ,
   pct_cofins_item_d 		        decimal(8,6)  		      null ,
   val_pis_d 			              decimal(17,2)  		      null ,
   val_cofins_d 		            decimal(17,2)  		      null ,
   dt_processamento             DATE                    NOT NULL,
   cod_usuario                  char(08)                NOT NULL,
   constraint pk_gi_ad primary key (ID_AD)
);
create sequence seq_id_ad;
create  index ix_gi_ad_912 on gi_ad_912 (cod_empresa,num_ad)

DROP table gi_ad_aen_912;
create table gi_ad_aen_912  (
   id_ad_aen                   INTEGER                 NOT NULL,
   id_ad                       INTEGER                 NOT NULL,
   cod_empresa                 CHAR(2)                 NOT NULL,
   cod_fatura                  INTEGER                 NOT NULL,
   cod_lin_prod                DECIMAL(2,0)            NOT NULL,
   cod_lin_recei               DECIMAL(2,0)            NOT NULL,
   cod_seg_merc                DECIMAL(2,0)            NOT NULL,
   cod_cla_uso                 DECIMAL(2,0)            NOT NULL,
   val_aen                     DECIMAL(15,2)          NOT NULL,
   constraint pk_id_ad_aen primary key (id_ad_aen)
);
create sequence seq_id_ad_aen;
create unique index ix_gi_ad_aen_912 on gi_ad_aen_912
(cod_empresa,  id_ad  , COD_LIN_PROD,cod_seg_merc , cod_cla_uso, cod_lin_recei)

DROP table gi_ad_valores_912;
create table gi_ad_valores_912  (
   num_seq                     INTEGER                 NOT NULL,
   id_ad                       INTEGER                 NOT NULL,
   cod_empresa                 CHAR(2)                 NOT NULL,
   cod_fatura                  INTEGER                 NOT NULL,
   cod_tip_valor               INTEGER                 NOT NULL,
   valor                       DECIMAL(15,2)            NOT NULL,
   constraint pk_num_seq_ad primary key (cod_empresa,id_ad, num_seq)
);

DROP table gi_ap_912 ;
create table gi_ap_912  (
   id_ap                       INTEGER                 NOT NULL,
   id_ad                       INTEGER                 NOT NULL,
   cod_empresa                 CHAR(2)                 NOT NULL,
   num_ap                      DECIMAL(6,0)               NULL,
   cod_fatura                  INTEGER                 NOT NULL,
   cod_fornecedor              CHAR(15)                NOT NULL,
   cod_favorecido              CHAR(15)                NULL,
   val_nom_ap                  DECIMAL(15,2)            NOT NULL,
   dt_vencimento               DATE                    NOT NULL,
   dt_pagamento                DATE                    NULL,
   ies_banco                   CHAR(01)
   constraint pk_id_ap primary key (id_ap)
);
create sequence seq_id_ap;
create  index ix_gi_ap_912 on gi_ap_912 (cod_empresa,num_ap)


DROP table gi_ap_valores_912;
create table gi_ap_valores_912  (
   num_seq                     INTEGER                 NOT NULL,
   id_ad                       INTEGER                 NOT NULL,   
   id_ap                       INTEGER                 NOT NULL, 
   cod_empresa                 CHAR(2)                 NOT NULL,
   cod_fatura                  INTEGER                 NOT NULL,
   cod_tip_valor               INTEGER                 NOT NULL,
   valor                       DECIMAL(15,2)            NOT NULL,
   constraint pk_num_seq_ap primary key (cod_empresa,id_ap, num_seq)
);


DROP table gi_ad_erro_912;
create table gi_ad_erro_912  (
   id_ad                       INTEGER                 NOT NULL,
   cod_empresa                 CHAR(2)                 NOT NULL,
   cod_fatura                  INTEGER                 NOT NULL,
   num_seq                     INTEGER                 NOT NULL,
   den_erro                    VARCHAR(255)           NOT NULL,
   constraint pk_ad_erro primary key (cod_empresa,id_ad, num_seq)
);
create sequence seq_id_erro;


DROP table gi_param_integracao_912;
Create table gi_param_integracao_912  (
   cod_parametro               CHAR(60)                NOT NULL,
   den_parametro               VARCHAR(100)            NOT NULL,
   tip_dado                    CHAR(1)                 NOT NULL,
   val_texto                   VARCHAR(30)             NULL,
   val_data                    DATE                    NULL,
   val_valor                   DECIMAL(15,2)           NULL,
   val_inteiro                 INTEGER                 NULL,
   ies_ativo                   CHAR(1)                 NOT NULL,
   constraint pk_cod_parametro primary key (cod_parametro)
);
create sequence seq_cod_param_integra;


DROP table gi_param_ar_912;
Create table gi_param_ar_912  (
   cod_tipo_obrigacao          	DECIMAL(4,0)        NOT NULL,
   den_parametro                VARCHAR(100  )      NOT NULL,
   cod_operacao                 char(07)            NOT null,
   cod_item                     char(15)            NOT null,
   especie_nf                   char(03)            NOT null,
   cnd_pgto                     DECIMAL(4,0)        NOT null,
   constraint pk_gi_param_ar_912 primary key (cod_tipo_obrigacao)
);

Create table gi_param_cfop_912  (
   cod_tipo_obrigacao          DECIMAL(4,0)        NOT NULL,
   cod_operacao                 char(07)           
);

create unique index ix_gi_param_cfop_912 on gi_param_cfop_912
   (cod_tipo_obrigacao, cod_operacao);
   


   create table gi_desp_uni_funcio_912  (
   cod_tip_despesa              DECIMAL(4,0)            NOT NULL,
   cod_uni_funcio               CHAR(10)   NOT NULL ,
     constraint pk_gi_desp_uni_funcio primary key (cod_tip_despesa ));
     
create  unique index ix_gi_desp_uni_funcio_912 on gi_desp_uni_funcio_912 (cod_tip_despesa,cod_uni_funcio )
