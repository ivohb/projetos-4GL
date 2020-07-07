#-----------------------------------------------------------#
# SISTEMA.: MANUFATURA                            			#
#	PROGRAMA:	pol1276										#
#	CLIENTE.:	METAAL										#
#	OBJETIVO:	PREPARAÇÃO PARA APONTAMENTO DE PRODUÇÃO     #
#															#
#	AUTOR...:	THIAGO										#
#	DATA....:	05/06/2009									#
#                                                           #
#-----------------------------------------------------------#

DATABASE logix
GLOBALS
   DEFINE 
   		p_cod_empresa         	LIKE empresa.cod_empresa,
		p_user                	LIKE usuario.nom_usuario,
		p_status              	SMALLINT,
		comando               	CHAR(80),
		p_versao              	CHAR(18),
		p_nom_tela 				CHAR(200),
		p_index					SMALLINT,
		p_qtd_saldo         	DECIMAL(15,7), 
		p_chave					char(20),
		p_hor_dif             	CHAR(10),
		p_qtd_segundo         	INTEGER,
		p_hor_proces          	CHAR(08),
		p_hor_ini_periodo     	CHAR(20),
		p_hor_fim_periodo     	CHAR(20),
	  	p_num_serie            	DECIMAL(18,0),
		p_dat_hor_producao      LIKE estoque_lote_ender.dat_hor_producao,
		p_dat_hor_validade		LIKE estoque_lote_ender.dat_hor_validade,
		p_today					DATE,
		p_validade         		DATE,
		p_msg   				CHAR(150),
		p_item_ctr_grade       	RECORD LIKE item_ctr_grade.*
 
		  
          
END GLOBALS

DEFINE p_w_apont_prod RECORD 
				COD_EMPRESA CHAR(2), 
				COD_ITEM CHAR(15), 
				NUM_ORDEM INTEGER, 
				NUM_DOCUM CHAR(10), 
				COD_ROTEIRO CHAR(15), 
				NUM_ALTERN DECIMAL(2,0), 
				COD_OPERACAO CHAR(5), 
				NUM_SEQ_OPERAC DECIMAL(3,0), 
				COD_CENT_TRAB CHAR(5), 
				COD_ARRANJO CHAR(5), 
				COD_EQUIP CHAR(15), 
				COD_FERRAM CHAR(15), 
				NUM_OPERADOR CHAR(15), 
				NUM_LOTE CHAR(15), 
				HOR_INI_PERIODO DATETIME HOUR TO MINUTE, 
				HOR_FIM_PERIODO DATETIME HOUR TO MINUTE, 
				COD_TURNO DECIMAL(3,0), 
				QTD_BOAS DECIMAL(15,7), 
				QTD_REFUG DECIMAL(15,7), 
				QTD_TOTAL_HORAS DECIMAL(10,2), 
				COD_LOCAL CHAR(10), 
				COD_LOCAL_EST CHAR(10), 
				DAT_PRODUCAO DATE, 
				DAT_INI_PROD DATE, 
				DAT_FIM_PROD DATE, 
				COD_TIP_MOVTO CHAR(1), 
				EFETUA_ESTORNO_TOTAL CHAR(1), 
				IES_PARADA SMALLINT, 
				IES_DEFEITO SMALLINT, 
				IES_SUCATA SMALLINT, 
				IES_EQUIP_MIN CHAR(1), 
				IES_FERRAM_MIN CHAR(1), 
				IES_SIT_QTD CHAR(1), 
				IES_APONTAMENTO CHAR(1), 
				TEX_APONT CHAR(255), 
				NUM_SECAO_REQUIS CHAR(10), 
				NUM_CONTA_ENT CHAR(23), 
				NUM_CONTA_SAIDA CHAR(23), 
				NUM_PROGRAMA CHAR(8), 
				NOM_USUARIO CHAR(8), 
				NUM_SEQ_REGISTRO INTEGER, 
				OBSERVACAO CHAR(200), 
				COD_ITEM_GRADE1 CHAR(15), 
				COD_ITEM_GRADE2 CHAR(15), 
				COD_ITEM_GRADE3 CHAR(15), 
				COD_ITEM_GRADE4 CHAR(15), 
				COD_ITEM_GRADE5 CHAR(15), 
				QTD_REFUG_ANT DECIMAL(15,7), 
				QTD_BOAS_ANT DECIMAL(15,7), 
				TIP_SERVICO CHAR(1), 
				ABRE_TRANSACAO SMALLINT,
				MODO_EXIBICAO_MSG SMALLINT, 
				SEQ_REG_INTEGRA INTEGER, 
				ENDERECO INTEGER, 
				IDENTIF_ESTOQUE CHAR(30), 
				SKU CHAR(25),
				FINALIZA_OPERACAO CHAR(1),
				SEQ_PROCESSO      DECIMAL(10,0)
END RECORD 

DEFINE  p_w_parada RECORD 
				cod_parada char(03),
				dat_ini_parada   			DATE,
				dat_fim_parada 				DATE,
				hor_ini_periodo 			DATETIME HOUR TO MINUTE,
				hor_fim_periodo 			DATETIME HOUR TO MINUTE,
				hor_tot_periodo 			DECIMAL(7,2)
END RECORD 

DEFINE p_man_log_apo_prod912 RECORD	
				empresa char(2),
				transacao decimal(12,0),
				seq_mensagem integer,
				seq_reg_mestre decimal(10,0),
				item char(15),
				ordem_producao decimal(10,0),
				num_seq_operac decimal(3,0),
				num_operador char(15),
				tip_apontamento char(1),
				tip_movimentacao char(1),
				apo_operacao char(1),
				sit_apontamento char(1),
				operacao char(5),
				tip_mensagem char(1),
				erro decimal(10,0),
				texto_resumo char(70),
				texto_detalhado char(500),
				programa char(10),
				dat_processamento date,
				hor_processamento datetime hour to second,
				usuario char(8),
				num_serie  integer
END RECORD 

DEFINE p_item_produz RECORD	
				empresa					CHAR(02),
				seq_reg_mestre			INTEGER,
				SEQ_REGISTRO_ITEM       INTEGER, 
				tip_movto				CHAR(01),
				item_produzido			CHAR(15),
				lote_produzido			CHAR(15),
				grade_1					CHAR(15),
				grade_2					CHAR(15),
				grade_3					CHAR(15),
				grade_4					CHAR(15),
				grade_5					CHAR(15),
				num_peca				CHAR(15),
				serie					CHAR(15),
				volume					INTEGER,
				comprimento				DECIMAL(15,3),
				largura					DECIMAL(15,3),
				altura					DECIMAL(15,3),
				diametro				DECIMAL(15,3),
				local					CHAR(10),
				endereco				CHAR(15),
				tip_producao			CHAR(01),
				qtd_produzida			DECIMAL(10,3),
				qtd_convertida			DECIMAL(10,3),
				sit_est_producao		CHAR(01),
				data_producao			DATE,
				data_valid				DATE,
				conta_ctbl				CHAR(23),
				moviment_estoque		INTEGER,
				observacao				CHAR(300),
				seq_reg_normal			INTEGER,
				ies_sofre_estorno		CHAR(01)
END RECORD 
DEFINE p_compon        RECORD
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
  qtd_transf 		  DECIMAL(15,3), 
  cod_grade_1     CHAR(15), 
  cod_grade_2     CHAR(15), 
  cod_grade_3     CHAR(15), 
  cod_grade_4     CHAR(15), 
  cod_grade_5     CHAR(15)
  
END RECORD
 
MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "pol1276-12.00.05"
   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180

   DEFER INTERRUPT
   CALL log140_procura_caminho("vdp.iem") RETURNING comando
   OPTIONS
      HELP FILE comando

    LET p_status			= 0
    LET p_cod_empresa = '01'
    LET p_user 				= 'admlog'
    
    LET p_chave = arg_val(1)
    
    IF p_chave IS NULL OR p_chave = ' ' THEN
       CALL log0030_mensagem('Parâmetro obrigatório\n não enviado', 'info')
    ELSE
      IF p_status = 0 THEN
      	CALL pol1276_controle()
      END IF
   END IF
END MAIN

#------------------------------#
FUNCTION pol1276_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_status          SMALLINT

   {CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,1) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param2_user
   
   IF l_param1_empresa IS NULL THEN
      RETURN 1
   END IF

   SELECT den_empresa
     INTO l_den_empresa
     FROM empresa
    WHERE cod_empresa = l_param1_empresa
      
   IF STATUS <> 0 THEN
      RETURN 1
   END IF
   }
   
   LET p_cod_empresa = '01' #l_param1_empresa
   LET p_user = 'admlog'  #l_param2_user
      
   CALL pol1276_controle() RETURNING p_status
   
   RETURN p_status
   
END FUNCTION   

#--------------------------#
FUNCTION pol1276_controle()#
#--------------------------#
			
   CALL pol1276_processa()
   
   CALL log085_transacao("BEGIN")

     
END FUNCTION
#--------------------------#
FUNCTION pol1276_processa()
#--------------------------#
DEFINE 
			 l_hor_proces		CHAR(10),
			 l_qtd_segundo		INTEGER,
			 c,d				INTEGER,
			 p_par 				char(1),
			 l_seq_MAN8237_2    INTEGER,
			 l_vid_util         decimal(5,0),
			 l_linha		decimal(4,0),
				l_coluna	decimal(4,0),
				l_cod_operacao	CHAR(04),
				l_funcao	CHAR(20),
				l_cod_item	CHAR(15),
				l_num_docum	CHAR(10),
				l_num_ordem	INTEGER,
				l_consiste_qtd	CHAR(01),
				l_qtd_consiste	DECIMAL(10,3),
				l_tipo	CHAR(01),
				l_trat_qea	decimal(4,0)

  #----------------------------------------#
  

	CALL log006_exibe_teclas("01",p_versao)
	INITIALIZE p_nom_tela TO NULL 
	CALL log130_procura_caminho("pol1276") RETURNING p_nom_tela
	LET p_nom_tela = p_nom_tela CLIPPED 
	OPEN WINDOW w_pol1276 AT 1,1 WITH FORM p_nom_tela
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
								
	LET p_num_serie = p_chave
	
		CALL log085_transacao("BEGIN")
	
# Manda para histórico registros processados e excluidos das tabelas abaixo:

# Tabela: apont_prog912

		INSERT INTO apont_prog912_hist	
		SELECT * FROM APONT_PROG912
		WHERE (IES_PROCESSADO = 'S'
		OR IES_PROCESSADO = 'E')
		
		IF STATUS = 0 THEN 
			DELETE FROM apont_prog912
			WHERE (IES_PROCESSADO = 'S'
			OR IES_PROCESSADO = 'E')
			
			IF STATUS <> 0 THEN 
				CALL log085_transacao("ROLLBACK")	
			END IF 
		END IF 

# Tabela: apont_compon912
		
		INSERT INTO hist_apont_compon912	
		SELECT * FROM apont_compon912
		WHERE (IES_PROCESSADO = 'S'
		OR IES_PROCESSADO = 'E')
		
		IF STATUS = 0 THEN 
			DELETE FROM apont_compon912
			WHERE (IES_PROCESSADO = 'S'
			OR IES_PROCESSADO = 'E')
			
			IF STATUS <> 0 THEN 
				CALL log085_transacao("ROLLBACK")	
			END IF 
		END IF 
	
# Tabela: apont_parada912
	
		INSERT INTO hist_apont_parada912	
		SELECT * FROM apont_parada912
		WHERE (IES_PROCESSADO = 'S'
		OR IES_PROCESSADO = 'E')
		
		IF STATUS = 0 THEN 
			DELETE FROM apont_parada912
			WHERE (IES_PROCESSADO = 'S'
			OR IES_PROCESSADO = 'E')
			
			IF STATUS <> 0 THEN 
				CALL log085_transacao("ROLLBACK")	
			END IF 
		END IF 	
		
		CALL log085_transacao("COMMIT")			
		
	DECLARE cq_apont_prog912 SCROLL CURSOR WITH HOLD FOR 
	 SELECT	cod_empresa,
	        cod_item,
	        num_ordem,
	        num_docum,
	        cod_roteiro,
					num_altern,
					cod_operacao,
					num_seq_operac,
					cod_cent_trab,
					cod_arranjo,
					cod_equip,
					cod_ferram,
					num_operador,
					num_lote,
					hor_ini_periodo,
					hor_fim_periodo,
					cod_turno,
					qtd_boas,
					qtd_refug,
					qtd_total_horas,
					cod_local,
					cod_local_est,
					dat_producao,
					dat_ini_prod,
					dat_fim_prod,
					cod_tip_movto,
					efetua_estorno_total,
					ies_parada ,
					ies_defeito,
					ies_sucata,
					ies_equip_min,
					ies_ferram_min,
					ies_sit_qtd,
					ies_apontamento,
					tex_apont,
					num_secao_requis,
					num_conta_ent,
					num_conta_saida,
					num_programa,
					nom_usuario,
					observacao,
					cod_item_grade1,
					cod_item_grade2,
					cod_item_grade3,
					cod_item_grade4,
					cod_item_grade5,
					qtd_refug_ant,
					qtd_boas_ant,
					tip_servico,
					modo_exibicao_msg,
					seq_reg_integra,
					endereco,
					identif_estoque,
					sku,
					ies_finaliza
		 FROM apont_prog912
		 WHERE cod_empresa = p_cod_empresa
		   AND num_serie = p_num_serie 
		ORDER BY num_ordem,num_seq_operac
	
	 
	FOREACH cq_apont_prog912 
		 INTO p_w_apont_prod.cod_empresa,                                                                            												
					p_w_apont_prod.cod_item,                                                                                 											
					p_w_apont_prod.num_ordem,                                                                                											
					p_w_apont_prod.num_docum,                                                                                											
					p_w_apont_prod.cod_roteiro,                                                                              											
					p_w_apont_prod.num_altern,                                                                               											
					p_w_apont_prod.cod_operacao,                                                                             											
					p_w_apont_prod.num_seq_operac,                                                                           											
					p_w_apont_prod.cod_cent_trab,                                                                            											
					p_w_apont_prod.cod_arranjo,                                                                              											
					p_w_apont_prod.cod_equip,                                                                                											
					p_w_apont_prod.cod_ferram,                                                                               											
					p_w_apont_prod.num_operador,                                                                             											
					p_w_apont_prod.num_lote,                                                                                 											
					p_hor_ini_periodo,             #Ivo 26/11/10                                                             											
					p_hor_fim_periodo,             #Ivo 26/11/10                                                             											
					p_w_apont_prod.cod_turno,                                                                                											
					p_w_apont_prod.qtd_boas,                                                                                 											
					p_w_apont_prod.qtd_refug,                                                                                											
					p_w_apont_prod.qtd_total_horas,                                                                          											
					p_w_apont_prod.cod_local,                                                                                											
					p_w_apont_prod.cod_local_est,                                                                            											
					p_w_apont_prod.dat_producao,                                                                             											
					p_w_apont_prod.dat_ini_prod,                                                                             											
					p_w_apont_prod.dat_fim_prod,                                                                             											
					p_w_apont_prod.cod_tip_movto,                                                                            											
					p_w_apont_prod.efetua_estorno_total,                                                                     											
					p_w_apont_prod.ies_parada ,                                                                              											
					p_w_apont_prod.ies_defeito,                                                                              											
					p_w_apont_prod.ies_sucata,                                                                               											
					p_w_apont_prod.ies_equip_min,                                                                            											
					p_w_apont_prod.ies_ferram_min,                                                                           											
					p_w_apont_prod.ies_sit_qtd,                                                                              											
					p_w_apont_prod.ies_apontamento,                                                                          											
					p_w_apont_prod.tex_apont,                                                                                											
					p_w_apont_prod.num_secao_requis,                                                                         											
					p_w_apont_prod.num_conta_ent,                                                                            											
					p_w_apont_prod.num_conta_saida,                                                                          											
					p_w_apont_prod.num_programa,                                                                             											
					p_w_apont_prod.nom_usuario,                                                                              											                                                                        											
					p_w_apont_prod.observacao,                                                                               											
					p_w_apont_prod.cod_item_grade1,                                                                          											
					p_w_apont_prod.cod_item_grade2,                                                                          											
					p_w_apont_prod.cod_item_grade3,                                                                          											
					p_w_apont_prod.cod_item_grade4,                                                                          											
					p_w_apont_prod.cod_item_grade5,                                                                          											
					p_w_apont_prod.qtd_refug_ant,                                                                            											
					p_w_apont_prod.qtd_boas_ant,                                                                             											
					p_w_apont_prod.tip_servico,                                                                              											
					p_w_apont_prod.modo_exibicao_msg,		#vai fazer um select na tabela apont_prog912 todos                   											
					p_w_apont_prod.seq_reg_integra,			#os apontamentos que não foram processado e fazer                    											
					p_w_apont_prod.endereco,						#um loop ate o final dos regitros para apontar                       											
					p_w_apont_prod.identif_estoque,			#um a um para não haver erro                                         											
					p_w_apont_prod.sku,                                                                                      											
     		  p_w_apont_prod.finaliza_operacao			                                                                   
   
				IF STATUS <> 0 THEN
				   CALL log003_err_sql('FOREACH','cq_apont_prog912')
				   RETURN
				END IF
				
				#----------Ivo 26/11/10------#
				LET p_w_apont_prod.hor_ini_periodo = p_hor_ini_periodo
				LET p_w_apont_prod.hor_fim_periodo = p_hor_fim_periodo
        LET p_w_apont_prod.num_programa = "POL1276"

   #--------------------------------------------#

				#----------Ivo 25/04/2017------#
        
        SELECT seq_processo
          INTO p_w_apont_prod.seq_processo
          FROM ord_oper
         WHERE cod_empresa = p_cod_empresa
           AND num_ordem = p_w_apont_prod.num_ordem
           AND num_seq_operac = p_w_apont_prod.num_seq_operac
                                                                                         											
				IF STATUS <> 0 THEN
				   CALL log003_err_sql('SELECT','ord_oper') 
				   RETURN
				END IF

#--------------------------------------------#

   
		LET p_w_apont_prod.abre_transacao = 1

		IF manr24_cria_w_comp_baixa (0) THEN
		   
		    CALL  pol1276_componentes() # Verifica se houve alteração nos componentes, se houve grava tabela w_comp_baixa
		     
			IF manr24_cria_w_apont_prod(0)  THEN 	#Essa função totvs tem por objetivo criar a tabela apont_prod para que possa 
																						#ser realizado o apontamento
			
				CALL man8237_cria_tables_man8237()	#cria as tabelas temporarias necessarias para o apontamento.Função Totvs
				
				
				LET l_seq_MAN8237_2 = 0 
				
				select MAX(NUM_SEQ)  
				INTO l_seq_MAN8237_2
				FROM W_MAN8237_2
										
				IF STATUS <> 0 THEN
					   CALL log003_err_sql('SELECT','W_MAN8237_2')
				END IF
								
				IF l_seq_MAN8237_2 > 0 THEN
				   LET l_seq_MAN8237_2 = l_seq_MAN8237_2 + 1
				ELSE  
				   LET l_seq_MAN8237_2 = 1
				END IF 

				LET p_today = TODAY
				
				INSERT INTO W_MAN8237_1 
				VALUES(l_seq_MAN8237_2, 1 , p_today)

				IF STATUS <> 0 THEN
					   CALL log003_err_sql('INSERT1','W_MAN8237_1')
				END IF	
				
				LET l_vid_util  =  0 
				
				SELECT VID_UTIL
			    INTO l_vid_util
				FROM ITEM_SUP  
				WHERE ITEM_SUP.COD_EMPRESA=p_cod_empresa
				AND ITEM_SUP.COD_ITEM=p_w_apont_prod.cod_item 
				
				IF STATUS <> 0 THEN
					   CALL log003_err_sql('SELECT','ITEM_SUP')
					   LET l_vid_util  =  0 
				END IF
				
				LET l_vid_util = l_vid_util * 30 
				LET p_validade = TODAY + l_vid_util
				
				INSERT INTO W_MAN8237_1 
				VALUES(l_seq_MAN8237_2, 2 , p_validade)

				IF STATUS <> 0 THEN
					   CALL log003_err_sql('INSERT2','W_MAN8237_1')
				END IF	
				
		        INSERT INTO W_MAN8237_2 
				VALUES(l_seq_MAN8237_2, p_w_apont_prod.qtd_boas, 	p_w_apont_prod.qtd_refug, 'N', 0)
	
				IF STATUS <> 0 THEN
					   CALL log003_err_sql('INSERT','W_MAN8237_2')
				END IF
						
				IF 	pol1276_item_tem_dim()  THEN 	
					CALL pol1276_inclui_dim_item_produz()                                 #Grava tabela t_item_produz para item com dimenssional 
				END IF 									
	
		
				CALL man8246_cria_temp_fifo()		#essa função tem por finalidade corrigir um erro da função anterior
													#ela cria a tabela temp_fifo para que seja aponta as ops.
					
				SELECT COD_ESTOQUE_RP 
				INTO   l_cod_operacao
				FROM  PAR_PCP   
				WHERE COD_EMPRESA='01'

				IF STATUS <> 0 THEN
					CALL log003_err_sql('lEITURA','PARPCP')
				END IF	
					
				LET l_linha	= 5
				LET l_coluna	= 5 
				LET l_funcao		= 'INCLUSAO' 
				LET l_cod_item		= p_w_apont_prod.cod_item
				LET l_num_docum		= p_w_apont_prod.num_docum
				LET l_num_ordem		= p_w_apont_prod.num_ordem
				LET l_consiste_qtd	= 'S'
				LET l_qtd_consiste	= p_w_apont_prod.qtd_boas
				LET l_tipo			= 'B'
				LET l_trat_qea		= 'N'
													
													
													
######        IF  man8237_tela_informa_dimensionais(	l_linha,	
######														l_coluna,
######														l_cod_operacao,
######														l_funcao,
######														l_cod_item,
######														l_num_docum,
######														l_num_ordem,
######														l_consiste_qtd,
######														l_qtd_consiste,
######														l_tipo,
######														l_trat_qea)    THEN
	        IF man8237_carrega_modulares(p_w_apont_prod.cod_empresa, p_w_apont_prod.cod_item)  THEN
	
				IF pol1276_inclui_w_apont_prod() = TRUE THEN # Essa função inclui apontamentos para processar.Função totvs
					
						DECLARE cq_apont_parada912 SCROLL CURSOR WITH HOLD FOR 
						SELECT 	cod_parada,dat_ini_parada,dat_fim_parada ,
										hor_ini_periodo,hor_fim_periodo,hor_tot_periodo
							FROM apont_parada912
						 WHERE cod_empresa = p_w_apont_prod.cod_empresa
							 AND num_serie = p_num_serie
							 AND ies_processado = 'N'
																									
						IF STATUS = 0 THEN 
							LET p_w_apont_prod.ies_parada = 1 
							CALL pol1276_w_parada()
							FOREACH cq_apont_parada912 INTO p_w_parada.*					#aqui verificamos se houve alguma parada pelo campo ies_parada
								INSERT INTO w_parada VALUES (p_w_parada.*)					#se houver algum erro iremos colocalo na tabela w_parada para
							END FOREACH																						#que possa ser processado
						ELSE
							LET p_w_apont_prod.ies_parada = 0
						END IF 
					
						IF p_w_apont_prod.qtd_refug > 0 THEN 
							LET p_w_apont_prod.ies_defeito = '1' 
							CALL pol1276_w_defeito()
							INSERT INTO w_defeito VALUES ('01',p_w_apont_prod.qtd_refug)
						ELSE
							LET p_w_apont_prod.ies_defeito = 0
						END IF 
					
						IF manr27_processa_apontamento()  THEN 			#se tudo ocorrer certo o programa vai dar um
							UPDATE apont_prog912																			#update nas tabelas mundando o campo ies_processamento
							   SET ies_processado = 'S'																	#para dizer que o registro ja foi apontado
							WHERE cod_empresa = p_w_apont_prod.cod_empresa
							  AND num_serie = p_num_serie							  
							  
							UPDATE apont_compon912 
							   SET ies_processado = 'S'
							 WHERE cod_empresa = p_w_apont_prod.cod_empresa
							   AND num_serie = p_num_serie 							 
							
							UPDATE apont_parada912 
							   SET ies_processado = 'S'
							 WHERE cod_empresa = p_w_apont_prod.cod_empresa
							   AND num_serie = p_num_serie
							
							CALL pol1276_mov_hist()  #----------Ivo 26/11/10------#
							
							CONTINUE FOREACH
						ELSE
							CALL pol1276_Executa_update()
						END if	
					ELSE
						CALL pol1276_Executa_update()
					END if
				else
					CALL pol1276_Executa_update()
				END if
			else
				CALL pol1276_Executa_update()
			END IF
			
		#	CALL log0030_mensagem('ERRO','')
			DECLARE cq_erro SCROLL CURSOR WITH HOLD FOR 
			SELECT EMPRESA ,TRANSACAO ,SEQ_MENSAGEM,SEQ_REG_MESTRE,ITEM ,
						 ORDEM_PRODUCAO,TIP_APONTAMENTO ,TIP_MOVIMENTACAO,APO_OPERACAO ,
						 SIT_APONTAMENTO,OPERACAO ,TIP_MENSAGEM ,ERRO,TEXTO_RESUMO,TEXTO_DETALHADO,
						 PROGRAMA,DAT_PROCESSAMENTO ,HOR_PROCESSAMENTO,USUARIO
				FROM MAN_LOG_APO_PROD WHERE EMPRESA = p_cod_empresa 
			
			FOREACH cq_erro INTO p_man_log_apo_prod912.empresa ,
													 p_man_log_apo_prod912.transacao ,
													 p_man_log_apo_prod912.seq_mensagem,
													 p_man_log_apo_prod912.seq_reg_mestre,
													 p_man_log_apo_prod912.item ,
													 p_man_log_apo_prod912.ordem_producao,
													 p_man_log_apo_prod912.tip_apontamento ,
													 p_man_log_apo_prod912.tip_movimentacao,
													 p_man_log_apo_prod912.apo_operacao ,
													 p_man_log_apo_prod912.sit_apontamento,
													 p_man_log_apo_prod912.operacao ,
													 p_man_log_apo_prod912.tip_mensagem ,
													 p_man_log_apo_prod912.erro,
													 p_man_log_apo_prod912.texto_resumo,
													 p_man_log_apo_prod912.texto_detalhado,
													 p_man_log_apo_prod912.programa,
													 p_man_log_apo_prod912.dat_processamento ,
													 p_man_log_apo_prod912.hor_processamento,
													 p_man_log_apo_prod912.usuario																		#insere novos dados na tabela de erro
					
					LET p_man_log_apo_prod912.seq_mensagem		= 0
					LET p_man_log_apo_prod912.num_seq_operac 	= p_w_apont_prod.num_seq_operac
					LET p_man_log_apo_prod912.num_operador 		= p_w_apont_prod.num_operador
					let p_man_log_apo_prod912.num_serie = p_num_serie
					
					INSERT INTO man_log_apo_prod912 VALUES 
						( p_man_log_apo_prod912.* ) 
						
			END FOREACH
		END IF  
	
	END FOREACH
	CLOSE WINDOW w_pol1276  

END FUNCTION

#------------------------------#
FUNCTION   pol1276_componentes()
#------------------------------#
DEFINE  			
		l_qtd_neces 		decimal(15,3),
		l_qtd_saldo			decimal(15,3),
		l_cod_local_baixa  	char(10),
		l_contador          decimal(5,0),
		l_lote              CHAR(15) 
 
		LET l_contador  = 0 
		
		
		
		
		SELECT count(*) 
          INTO l_contador 		
		      FROM apont_compon912 
		     WHERE cod_empresa 	= p_cod_empresa
		       AND num_serie 	= p_num_serie
			   AND ((qtd_neces_total_i <> qtd_neces_total_c) 
			    OR (lote IS NOT NULL))
			   AND ies_processado='N'	
 
	IF  l_contador > 0 THEN 
		
			INITIALIZE p_compon TO NULL
	

           LET p_compon.cod_item_pai =  p_w_apont_prod.cod_item
		   LET l_qtd_neces 	= 0
		   
		   DECLARE cq_baixa CURSOR FOR
		    SELECT cod_item_compon, 	   		
		           qtd_neces_total_i,
                   lote 				   
		      FROM apont_compon912
		     WHERE cod_empresa = p_cod_empresa
		       AND num_serie = p_num_serie
			   AND ies_processado='N'	
		       
		FOREACH cq_baixa INTO 
		           p_compon.cod_item,
		           l_qtd_neces,
				   l_lote

		      IF STATUS <> 0 THEN
				IF STATUS = 100 THEN
				   EXIT FOREACH
				ELSE   
		           CALL log003_err_sql('FOREACH','cq_baixa')
				END IF
		      END IF				   
			 
			 
			 LET l_qtd_saldo	= 0
			 INITIALIZE p_dat_hor_producao, p_dat_hor_validade, l_cod_local_baixa TO NULL
			 
			 SELECT DISTINCT COD_LOCAL_BAIXA 
			 INTO   l_cod_local_baixa 
			 FROM ORD_COMPON
			 WHERE COD_EMPRESA=p_cod_empresa
			 AND   NUM_ORDEM=p_w_apont_prod.num_ordem
			 AND COD_ITEM_COMPON=p_compon.cod_item

			 
			  IF STATUS <> 0 THEN
		           CALL log003_err_sql('SELECT','LOCAL_BAIXA')
		      END IF
			 
			 
			 DECLARE cq_estoque_lote  CURSOR FOR
					SELECT 
					num_lote,
					cod_local,
					endereco,
					num_serie,
					num_volume,
					comprimento,
					largura,
					altura,
					diametro,
					num_peca,
					dat_hor_producao,
					dat_hor_validade,
					identif_estoque,
					deposit,
					qtd_saldo,
					cod_grade_1,
					cod_grade_2,
					cod_grade_3,
					cod_grade_4,
					cod_grade_5
					FROM ESTOQUE_LOTE_ENDER
					WHERE cod_empresa 	= p_cod_empresa
					AND   cod_item  	= p_compon.cod_item
					AND   ies_situa_qtd	= 'L'
					AND   cod_local 	= l_cod_local_baixa
					AND   qtd_saldo>0
					ORDER BY dat_hor_producao 
					
			FOREACH cq_estoque_lote INTO 
						  p_compon.num_lote, 
						  p_compon.cod_local, 		     
						  p_compon.endereco, 		     
						  p_compon.num_serie, 		     
						  p_compon.num_volume,
						  p_compon.comprimento,
						  p_compon.largura, 						  	   	    
						  p_compon.altura, 			    
						  p_compon.diametro, 		  
						  p_compon.num_peca, 		   
						  p_dat_hor_producao,
						  p_dat_hor_validade, 		     
						  p_compon.identif_estoque, 	
						  p_compon.deposit,
						  l_qtd_saldo,
						  p_compon.cod_grade_1,
						  p_compon.cod_grade_2,
						  p_compon.cod_grade_3,
						  p_compon.cod_grade_4,
						  p_compon.cod_grade_5 
			 
						  IF STATUS <> 0 THEN
							 CALL log003_err_sql('FOREACH','cq_estoque_lote')
						  ELSE					 
                             IF  (l_lote   IS NOT NULL)  
							 AND (l_lote <>  p_compon.num_lote) THEN 
							      CONTINUE FOREACH 
							 END IF 	  
								
							 LET p_compon.dat_producao = EXTEND(p_dat_hor_producao, YEAR TO DAY)
							 LET p_compon.hor_producao = EXTEND(p_dat_hor_producao, HOUR TO SECOND)
 							 LET p_compon.dat_valid = EXTEND(p_dat_hor_validade, YEAR TO DAY)
							 LET p_compon.hor_valid = EXTEND(p_dat_hor_validade, HOUR TO SECOND)
							IF l_qtd_saldo >=  l_qtd_neces  THEN
								LET p_compon.qtd_transf	 = l_qtd_neces 
								IF pol1276_inclui_w_comp_baixa(p_compon.*) THEN 
								END IF	
								EXIT FOREACH 								
							ELSE
								LET p_compon.qtd_transf	 = l_qtd_saldo
								LET l_qtd_neces =  l_qtd_neces - l_qtd_saldO
							    IF pol1276_inclui_w_comp_baixa(p_compon.*) THEN 
								END IF	
                                CONTINUE FOREACH 
							END IF 
						  END IF 
			END FOREACH			  
        END FOREACH					
	END IF 		
END FUNCTION
#-------------------------------------------------#
FUNCTION   pol1276_inclui_w_comp_baixa(l_compon)																							
#-------------------------------------------------#

 DEFINE l_compon        RECORD
  cod_item_pai 			CHAR(15), 
  cod_item 		    	CHAR(15), 
  num_lote 		    	CHAR(15), 
  cod_local 		    CHAR(10), 
  endereco 		    	CHAR(15), 
  num_serie 		  	CHAR(25), 
  num_volume 		 	INTEGER, 
  comprimento		 	DECIMAL(15,3), 
  largura 		     	DECIMAL(15,3), 
  altura 			    DECIMAL(15,3), 
  diametro 		    	DECIMAL(15,3), 
  num_peca 		    	CHAR(15), 
  dat_producao 			DATE, 
  hor_producao 			CHAR(08), 
  dat_valid 		    DATE, 
  hor_valid 		    CHAR(08), 
  identif_estoque 		CHAR(30), 
  deposit 		     	 CHAR(15), 
  qtd_transf 		  	DECIMAL(15,3), 
  cod_grade_1     CHAR(15), 
  cod_grade_2     CHAR(15), 
  cod_grade_3     CHAR(15), 
  cod_grade_4     CHAR(15), 
  cod_grade_5     CHAR(15)

  END RECORD
 
  
			  INSERT INTO w_comp_baixa 
			  VALUES (l_compon.*)
				IF STATUS <> 0 THEN
					CALL log003_err_sql('INSERT','W_COMP_BAIXA')
					RETURN FALSE
				END IF	
				
   RETURN TRUE
				
END FUNCTION
#---------------------------------#
FUNCTION 	pol1276_item_tem_dim() 
#---------------------------------#
  DEFINE l_item CHAR(15)
         

	SELECT *
	INTO  p_item_ctr_grade
    FROM item_ctr_grade
    WHERE cod_empresa    = p_w_apont_prod.cod_empresa
    AND cod_item      = p_w_apont_prod.cod_item
	
	IF STATUS <> 0 THEN
		RETURN FALSE
	END IF
	
	
	IF 	(p_item_ctr_grade.ies_endereco 		= 'S') OR 
		(p_item_ctr_grade.ies_volume 		= 'S') OR 
		(p_item_ctr_grade.ies_dat_producao 	= 'S') OR 
		(p_item_ctr_grade.ies_dat_validade 	= 'S') OR 
		(p_item_ctr_grade.ies_comprimento	= 'S') OR 
		(p_item_ctr_grade.ies_largura 		= 'S') OR 
		(p_item_ctr_grade.ies_altura 		= 'S') OR 
		(p_item_ctr_grade.ies_diametro		= 'S') THEN
		 RETURN TRUE
	ELSE
		RETURN FALSE
	END IF	
	
END FUNCTION
#----------------------------------------#
FUNCTION pol1276_inclui_dim_item_produz()
#----------------------------------------#

		INITIALIZE p_item_produz.*  TO NULL
					
	
		LET		p_item_produz.empresa				=	p_w_apont_prod.cod_empresa	
		LET		p_item_produz.seq_reg_mestre		=	1
		LET		p_item_produz.SEQ_REGISTRO_ITEM     =   1
		LET		p_item_produz.tip_movto				=	'L'
		LET		p_item_produz.item_produzido		=	p_w_apont_prod.cod_item
		LET		p_item_produz.lote_produzido		=	p_w_apont_prod.num_lote
		LET		p_item_produz.grade_1				=	' '
		LET		p_item_produz.grade_2				=	' '
		LET		p_item_produz.grade_3				=	' '
		LET		p_item_produz.grade_4				=	' '
		LET		p_item_produz.grade_5				=	' '
		LET		p_item_produz.num_peca				=	' '
		LET		p_item_produz.serie					=	' '
		LET		p_item_produz.volume				=	0
		LET		p_item_produz.comprimento			=	0
		LET		p_item_produz.largura				=	0
		LET		p_item_produz.altura				=	0
		LET		p_item_produz.diametro				=	0
		LET		p_item_produz.local					=	p_w_apont_prod.cod_local
		LET		p_item_produz.endereco				=	'               '
		LET		p_item_produz.tip_producao			=   'B'
		LET		p_item_produz.qtd_produzida			=	p_w_apont_prod.qtd_boas
		LET		p_item_produz.qtd_convertida		=	0
		LET		p_item_produz.sit_est_producao		=	'L'
		LET		p_item_produz.data_producao			= 	p_today
		LET		p_item_produz.data_valid			=	p_validade
#		LET		p_item_produz.conta_ctbl			=
		LET		p_item_produz.moviment_estoque		=    0 
#		LET		p_item_produz.observacao			=
#		LET		p_item_produz.seq_reg_normal		=
#		LET		p_item_produz.ies_sofre_estorno		=


		INSERT INTO t_item_produz
			  VALUES (p_item_produz.*)
			  
		IF STATUS <> 0 THEN
			CALL log003_err_sql('INSERT','T_ITEM_PRODUZ')
			RETURN FALSE
		END IF	
		
   RETURN TRUE

END FUNCTION



#--------------------------#      
FUNCTION pol1276_mov_hist()       #----------Ivo 26/11/10------#
#--------------------------#

		INSERT INTO apont_prog912_hist
		SELECT * FROM APONT_PROG912
     WHERE cod_empresa      = p_w_apont_prod.cod_empresa
			 AND num_serie = p_num_serie
			 AND (ies_processado  = 'S' OR ies_processado  = 'E')
		
		IF STATUS = 0 THEN 
			DELETE FROM apont_prog912
       WHERE cod_empresa      = p_w_apont_prod.cod_empresa
	  		 AND num_serie = p_num_serie
		  	 AND (ies_processado  = 'S' OR ies_processado  = 'E')
		END IF 

END FUNCTION

#------------------------------#
FUNCTION pol1276_Executa_update()
#------------------------------#
	UPDATE apont_prog912								#update nas tabelas mundando o campo ies_processamento para P
	SET ies_processado = 'P'							#para dizer que o registro ja foi processado e esta pendente
	WHERE cod_empresa = p_w_apont_prod.cod_empresa
	AND num_serie = p_num_serie
	
	LET p_msg = 'Ocorreu erro no apontamento, verifique mensagem de erro.'
    CALL log0030_mensagem(p_msg,'info')
	
END FUNCTION

#---------------------------#
 FUNCTION pol1276_w_parada()#
#---------------------------#
	DROP TABLE w_parada
	CREATE TEMP TABLE w_parada (
				cod_parada char(03),
				dat_ini_parada   			DATE,
				dat_fim_parada 				DATE,
				hor_ini_periodo 			DATETIME HOUR TO MINUTE,
				hor_fim_periodo 			DATETIME HOUR TO MINUTE,
				hor_tot_periodo 			DECIMAL(7,2)
		)
END FUNCTION 
#---------------------------#
 FUNCTION pol1276_w_defeito()#
#---------------------------#
	DROP TABLE w_defeito
	CREATE TEMP TABLE w_defeito(
				cod_defeito		DECIMAL(3,0),
				qtd_refugo		DECIMAL(15,7)
		)
END FUNCTION 
	
FUNCTION pol1276_inclui_w_apont_prod()

   INSERT INTO w_apont_prod VALUES(p_w_apont_prod.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('insert','w_apont_prod')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

