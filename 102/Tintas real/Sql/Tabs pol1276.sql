------------atializada

DROP TABLE  apont_parada912;
DROP TABLE  apont_prog912; 
DROP TABLE  apont_compon912;



CREATE TABLE  apont_prog912
	(
	cod_empresa          CHAR (2),
	cod_item             CHAR (15),
	num_ordem            INTEGER,
	num_docum            CHAR (10),
	cod_roteiro          CHAR (15),
	num_altern           DECIMAL(2,0),
	cod_operacao         CHAR (5),
	num_seq_operac       DECIMAL(3,0),
	cod_cent_trab        CHAR (5),
	cod_arranjo          CHAR (5),
	cod_equip            CHAR (15),
	cod_ferram           CHAR (15),
	num_operador         CHAR (15),
	num_lote             CHAR (15),
	hor_ini_periodo      CHAR (20),
	hor_fim_periodo      CHAR (20),
	cod_turno            DECIMAL(3,0),
	qtd_boas             DECIMAL(10,3),
	qtd_refug            DECIMAL(10,3),
	qtd_total_horas      DECIMAL(10,2),
	cod_local            CHAR (10),
	cod_local_est        CHAR (10),
	dat_producao         DATE,
	dat_ini_prod         DATE,
	dat_fim_prod         DATE,
	cod_tip_movto        CHAR (1),
	efetua_estorno_total CHAR (1),
	ies_parada           SMALLINT,
	ies_defeito          SMALLINT,
	ies_sucata           SMALLINT,
	ies_equip_min        CHAR (1),
	ies_ferram_min       CHAR (1),
	ies_sit_qtd          CHAR (1),
	ies_apontamento      CHAR (1),
	tex_apont            CHAR (255),
	num_secao_requis     CHAR (10),
	num_conta_ent        CHAR (23),
	num_conta_saida      CHAR (23),
	num_programa         CHAR (8),
	nom_usuario          CHAR (8),
	num_seq_registro     INTEGER,
	observacao           CHAR (200),
	cod_item_grade1      CHAR (15),
	cod_item_grade2      CHAR (15),
	cod_item_grade3      CHAR (15),
	cod_item_grade4      CHAR (15),
	cod_item_grade5      CHAR (15),
	qtd_refug_ant        DECIMAL(10,3),
	qtd_boas_ant         DECIMAL(10,3),
	tip_servico          CHAR (1),
	modo_exibicao_msg    SMALLINT,
	seq_reg_integra      INTEGER,
	endereco             INTEGER,
	identif_estoque      CHAR (30),
	sku                  CHAR (25),
	ies_processado       CHAR (1),
	ies_finaliza         CHAR (1),
	num_serie            DECIMAL(18,0)
	);

CREATE INDEX ix1_apont_prog912
	ON apont_prog912 (cod_empresa, num_ordem,NUM_SERIE);

CREATE TABLE  apont_parada912
	(
	cod_empresa      CHAR (2),
	num_serie        DECIMAL(18,0),
	cod_parada       CHAR (3),
	dat_ini_parada   DATE,
	dat_fim_parada   DATE,
	hor_ini_periodo  CHAR (20),
	hor_fim_periodo  CHAR (20),
	hor_tot_periodo  DECIMAL(7,2),
	ies_processado   CHAR (1)
	);

CREATE INDEX ix1_apont_parada912
	ON apont_parada912 (cod_empresa,  NUM_SERIE);


CREATE TABLE  temp_parada912
	(
	cod_empresa    CHAR (2),
	num_ordem      INTEGER,
	num_seq_operac INTEGER,
	num_matricula  INTEGER,
	inicio         DATETIME YEAR TO SECOND,
	fim            DATETIME YEAR TO SECOND,
	cod_parada     CHAR (3),
	qtd_boas       DECIMAL(10,3),
	qtd_refugo     DECIMAL(10,3),
	processado     CHAR (1),
	NUM_SERIE       DECIMAL(18,0)
	);

CREATE INDEX ix1_temp_parada912
	ON temp_parada912 (cod_empresa, num_serie);

CREATE TABLE  apont_compon912
	(
	cod_empresa       CHAR (2),
	num_serie         DECIMAL(18,0),
	cod_item_compon 	char(15),
	qtd_item_pai   		decimal(10,3),
	qtd_neces_unit_c 	decimal(10,3),
	qtd_neces_total_c decimal(10,3),
	qtd_neces_unit_i 	decimal(10,3),
	qtd_neces_total_i decimal(10,3),
	ies_processado    CHAR (1)
	);

CREATE INDEX ix1_apont_compon912
	ON apont_compon912 (cod_empresa, num_seq_registro);
	

CREATE TEMP TABLE w_comp_baixa ( 
 cod_item_pai 		CHAR(15), 
 cod_item 		    CHAR(15), 
 num_lote 		    CHAR(15), 
 cod_local 		    CHAR(10), 
 endereco 		    CHAR(15), 
 num_serie 		    CHAR(25), 
 num_volume 		  INTEGER, 
 comprimento		  DECIMAL(15,3), 
 largura 		      DECIMAL(15,3), 
 altura 			    DECIMAL(15,3), 
 diametro 		    DECIMAL(15,3), 
 num_peca 		    CHAR(15), 
 dat_producao 		DATE, 
 hor_producao 		CHAR(08), 
 dat_valid 		    DATE, 
 hor_valid 		    CHAR(08), 
 identif_estoque 	CHAR(30), 
 deposit 		      CHAR(15), 
 qtd_transf 		  DECIMAL(15,3) 
);
  
create table apont_compon912 (  
COD_EMPRESA	CHAR(2),
NUM_SERIE	dec(18,0),
COD_ITEM_COMPON	CHAR(15 ),
QTD_ITEM_PAI	dec(10,3),
QTD_NECES_UNIT_C	dec(10,3),
QTD_NECES_TOTAL_C	dec(10,3),
QTD_NECES_UNIT_I	dec(10,3),
QTD_NECES_TOTAL_I	dec(10,3),
IES_PROCESSADO	CHAR(1),
NUM_SEQ_REGISTRO	dec(38,0),
POSICAO_LOTE	char(100),
LOTE	char(100)
);
