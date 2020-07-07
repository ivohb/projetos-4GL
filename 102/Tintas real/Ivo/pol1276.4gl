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
   		p_cod_empresa         LIKE empresa.cod_empresa,
      p_user                LIKE usuario.nom_usuario,
      p_status              SMALLINT,
      comando               CHAR(80),
      p_versao              CHAR(18),
      p_nom_tela 			      CHAR(200),
      p_index				        SMALLINT,
      p_qtd_saldo         	DECIMAL(15,7), 
      p_chave					      char(20),
		  p_processando         LIKE proc_apont_man912.processando,
		  p_hora_ini           	LIKE proc_apont_man912.hor_ini,
		  p_hor_atu             LIKE proc_apont_man912.hor_ini,
		  p_hor_dif             CHAR(10),
		  p_qtd_segundo         INTEGER,
		  p_hor_proces          CHAR(08),
      p_hor_ini_periodo     CHAR(20),
      p_hor_fim_periodo     CHAR(20)
 
		  
          
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
				FINALIZA_OPERACAO CHAR(1)
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
				num_seq_registro integer
END RECORD 


MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "pol1276-10.02.00"
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
			
   SELECT processando,
          hor_ini
     INTO p_processando,
          p_hora_ini
     FROM proc_apont_man912
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 100 THEN
      INSERT INTO proc_apont_man912 VALUES('S', CURRENT HOUR TO SECOND, p_cod_empresa)
      IF STATUS <> 0 THEN
         CALL log003_err_sql("INSERT","proc_apont_man912")
         RETURN 
      END IF
   ELSE
      IF STATUS = 0 THEN
         IF p_processando = 'S' THEN
            LET p_hor_atu = CURRENT HOUR TO SECOND
            IF p_hora_ini > p_hor_atu THEN
               LET p_hor_dif = '24:00:00' - (p_hora_ini - p_hor_atu)
            ELSE
               LET p_hor_dif = (p_hor_atu - p_hora_ini)
            END IF
            LET p_hor_proces = p_hor_dif[2,9]
            LET p_qtd_segundo = (p_hor_proces[1,2] * 3600) + 
                                (p_hor_proces[4,5] * 60)   + (p_hor_proces[7,8])
            IF p_qtd_segundo <= 240 THEN
               RETURN
            END IF
         END IF
         
         UPDATE proc_apont_man912 
            SET processando = 'S',
                hor_ini = CURRENT YEAR TO SECOND
          WHERE cod_empresa = p_cod_empresa
          
         IF STATUS <> 0 THEN
            CALL log003_err_sql("UPDATE","proc_apont_man912")
            RETURN 
         END IF
      ELSE
         CALL log003_err_sql("LEITURA","proc_apont_man912")
         RETURN 
      END IF
   END IF

   CALL pol1276_processa()
   
   CALL log085_transacao("BEGIN")

   UPDATE proc_apont_man912 
      SET processando = 'N'
    WHERE cod_empresa = p_cod_empresa
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE","proc_apont_man912")
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
   END IF
      
END FUNCTION
#--------------------------#
FUNCTION pol1276_processa()
#--------------------------#
DEFINE 
			 l_hor_proces						CHAR(10),
			 l_qtd_segundo					INTEGER,
			 c,d										INTEGER,
			 p_par 									char(1),
			 p_num_serie            DECIMAL(18,0)

  #Ivo 22/12/2010
  DEFINE p_qtd_plan LIKE ord_oper.qtd_planejada,
         p_qtd_apon LIKE ord_oper.qtd_boas
  #----------------------------------------#

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
  qtd_transf 		  DECIMAL(15,3) 
  
 END RECORD
  
	CALL log006_exibe_teclas("01",p_versao)
	INITIALIZE p_nom_tela TO NULL 
	CALL log130_procura_caminho("pol1276") RETURNING p_nom_tela
	LET p_nom_tela = p_nom_tela CLIPPED 
	OPEN WINDOW w_pol1276 AT 1,1 WITH FORM p_nom_tela
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	DISPLAY p_cod_empresa TO cod_empresa
								
	LET p_num_serie = p_chave
	
		CALL log085_transacao("BEGIN")
	
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
					num_seq_registro,
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
					p_w_apont_prod.num_seq_registro,                                                                         											
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

    IF pol1276_ja_apontou() THEN 
       CONTINUE FOREACH
    END IF
    #----------------------------#   

   #----------Ivo 22/12/10------#
   SELECT qtd_planejada,
          (qtd_boas + qtd_refugo + qtd_sucata)
     INTO p_qtd_plan,
          p_qtd_apon
     FROM ord_oper
    WHERE cod_empresa    = p_w_apont_prod.cod_empresa
      AND num_ordem      = p_w_apont_prod.num_ordem
      AND num_seq_operac = p_w_apont_prod.num_seq_operac
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ord_oper')
      RETURN
   END IF
   
   IF p_qtd_apon >= p_qtd_plan THEN
      UPDATE apont_prog912
         SET ies_apontamento = 'E'
		   WHERE cod_empresa = p_w_apont_prod.cod_empresa
				 AND num_seq_registro = p_w_apont_prod.num_seq_registro
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Update','ord_oper')
         RETURN
      END IF

      CONTINUE FOREACH
   END IF
   
   #--------------------------------------------#
   
		LET p_w_apont_prod.abre_transacao = 1
		
		
		#IF  pol1276_tem_material() THEN 				# verifica se tem estoque para apontar se nao tem faz a tranferencia de local
																						# se o item for comprado não pode haver transferencia.
		
		IF manr24_cria_w_comp_baixa (0) THEN
		   
		   INITIALIZE p_compon TO NULL
		   
		   DECLARE cq_baixa CURSOR FOR
		    SELECT cod_item_compon, 	  
		           qtd_item_pai,   		
		           qtd_neces_total_i  
		      FROM apont_compon912
		     WHERE cod_empresa = p_cod_empresa
		       AND num_serie = p_num_serie
		       
		   FOREACH cq_baixa INTO 
		           p_compon.cod_item,
		           p_compon.cod_item_pai,
		           p_compon.qtd_transf
		      
		      IF STATUS <> 0 THEN
		         CALL log003_err_sql('FOREACH','cq_baixa')
		      ELSE
		         INSERT INTO w_comp_baixa VALUES(p_compon.*)
		         IF STATUS <> 0 THEN
		            CALL log003_err_sql('INSERT','w_comp_baixa')
		         END IF
		      END IF
		      
		   END FOREACH
			
			IF manr24_cria_w_apont_prod(0)  THEN 	#Essa função totvs tem por objetivo criar a tabela apont_prod para que possa 
																						#ser realizado o apontamento
			
				CALL man8237_cria_tables_man8237()	#cria as tabelas temporarias necessarias para o apontamento.Função Totvs
				
				CALL man8246_cria_temp_fifo()		#essa função tem por finalidade corrigir um erro da função anterior
																				#ela cria a tabela temp_fifo para que seja aponta as ops.
				
				IF manr24_inclui_w_apont_prod(p_w_apont_prod.*,1) = TRUE THEN # Essa função inclui apontamentos para processar.Função totvs
					
					IF p_w_apont_prod.ies_parada = 1 THEN 
						DECLARE cq_apont_parada912 SCROLL CURSOR WITH HOLD FOR 
						SELECT 	cod_parada,dat_ini_parada,dat_fim_parada ,
										hor_ini_periodo,hor_fim_periodo,hor_tot_periodo
							FROM apont_parada912
						 WHERE cod_empresa = p_w_apont_prod.cod_empresa
							 AND num_serie = p_num_serie
							 AND ies_processado = 'N'
																									
						IF STATUS = 0 THEN 
							CALL pol1276_w_parada()
							FOREACH cq_apont_parada912 INTO p_w_parada.*					#aqui verificamos se houve alguma parada pelo campo ies_parada
								INSERT INTO w_parada VALUES (p_w_parada.*)					#se houver algum erro iremos colocalo na tabela w_parada para
							END FOREACH																						#que possa ser processado
						END IF 
					
					END IF
					
					IF  p_w_apont_prod.ies_defeito = 1 THEN 
						CALL pol1276_w_defeito()
						INSERT INTO w_defeito VALUES ('01',p_w_apont_prod.qtd_refug)
					END IF 
					
					IF manr27_processa_apontamento(p_w_apont_prod.*)  THEN 			#se tudo ocorrer certo o programa vai dar um
						UPDATE apont_prog912																			#update nas tabelas mundando o campo ies_processamento
						   SET ies_processado = 'S'																	#para dizer que o registro ja foi apontado
						WHERE cod_empresa = p_w_apont_prod.cod_empresa
						  AND num_seq_registro = p_w_apont_prod.num_seq_registro
						
						UPDATE apont_parada912 
						   SET ies_processado = 'S'
					 	 WHERE cod_empresa = p_w_apont_prod.cod_empresa
						   AND num_serie = p_num_serie
						
						CALL pol1276_mov_hist()  #----------Ivo 26/11/10------#
						
						CONTINUE FOREACH
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
					let p_man_log_apo_prod912.num_seq_registro = p_w_apont_prod.num_seq_registro
					
					INSERT INTO man_log_apo_prod912 VALUES 
						( p_man_log_apo_prod912.* ) 
						
			END FOREACH
		END IF  
	
	END FOREACH
	CLOSE WINDOW w_pol1276  

END FUNCTION
        																							

#----------------------------#
FUNCTION pol1276_ja_apontou()         #----------Ivo 26/11/10------#
#----------------------------#

   DEFINE p_count INTEGER,
          p_msg   CHAR(150)
   
   SELECT COUNT(cod_empresa)
     INTO p_count
     FROM apont_prog912_hist
    WHERE cod_empresa    = p_w_apont_prod.cod_empresa
      AND num_ordem      = p_w_apont_prod.num_ordem
      AND cod_item       = p_w_apont_prod.cod_item
      AND cod_operacao   = p_w_apont_prod.cod_operacao
      AND num_seq_operac = p_w_apont_prod.num_seq_operac
      AND hor_ini_periodo= p_hor_ini_periodo
      AND hor_fim_periodo= p_hor_fim_periodo
      AND dat_ini_prod   = p_w_apont_prod.dat_ini_prod
      AND dat_fim_prod   = p_w_apont_prod.dat_fim_prod
      AND qtd_boas       = p_w_apont_prod.qtd_boas

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','apont_prog912_hist')
      RETURN FALSE
   END IF

   IF p_count = 0 THEN
      LET p_msg = 'Um apontamento com essas caracteristicas\n',
                  'já foi efetuado em outro processo.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF

	 UPDATE apont_prog912				
	    SET ies_processado = 'E'
		WHERE cod_empresa = p_w_apont_prod.cod_empresa
			AND num_seq_registro = p_w_apont_prod.num_seq_registro
						
   UPDATE apont_parada912 
			SET ies_processado = 'E'
		WHERE cod_empresa = p_w_apont_prod.cod_empresa
			AND num_seq_registro = p_w_apont_prod.num_seq_registro
						
   CALL pol1276_mov_hist()  
     
   RETURN TRUE

END FUNCTION

#--------------------------#      
FUNCTION pol1276_mov_hist()       #----------Ivo 26/11/10------#
#--------------------------#

		INSERT INTO apont_prog912_hist
		SELECT * FROM APONT_PROG912
     WHERE cod_empresa      = p_w_apont_prod.cod_empresa
			 AND num_seq_registro = p_w_apont_prod.num_seq_registro
			 AND (ies_processado  = 'S' OR ies_processado  = 'E')
		
		IF STATUS = 0 THEN 
			DELETE FROM apont_prog912
       WHERE cod_empresa      = p_w_apont_prod.cod_empresa
	  		 AND num_seq_registro = p_w_apont_prod.num_seq_registro
		  	 AND (ies_processado  = 'S' OR ies_processado  = 'E')
		END IF 

END FUNCTION

#------------------------------#
FUNCTION pol1276_Executa_update()
#------------------------------#
	UPDATE apont_prog912																			#update nas tabelas mundando o campo ies_processamento para P
	SET ies_processado = 'P'																	#para dizer que o registro ja foi processado e esta pendente
	WHERE cod_empresa = p_w_apont_prod.cod_empresa
	AND num_seq_registro = p_w_apont_prod.num_seq_registro
END FUNCTION


#------------------------------#
FUNCTION pol1276_tem_material()
#------------------------------#
	
	DEFINE 	p_local_prod 			LIKE ord_compon.cod_local_baixa,
					p_local_esto			LIKE ord_compon.cod_local_baixa,
					p_cod_item				LIKE item.cod_item,
					p_qtd_necessaria	DECIMAL(15,7), #LIKE ord_compon.qtd_necessaria,
					p_qtd_mvto				DECIMAL(15,7), #LIKE estoque_lote.qtd_saldo,
					p_qtd_reservada		DECIMAL(15,7), #LIKE estoque_loc_reser.qtd_reservada,
					p_qtd_estoq				DECIMAL(15,7), #LIKE 	estoque_lote.qtd_saldo,	
					p_num_lote				CHAR(15),
					l_hou_erro				SMALLINT, 
					l_tem_pend				SMALLINT,
					p_num_transac 		INTEGER,
					p_num_transac1 		INTEGER,
					p_transac					INTEGER,
					P_DATA						DATE,
					p_hora						DATETIME HOUR TO SECOND ,
					p_data_hor				LIKE ESTOQUE_AUDITORIA.DAT_HOR_PROCES,
					p_hora_char				CHAR(08),
					p_qtd_pende				DECIMAL(15,7), #LIKE 	estoque_lote.qtd_saldo,
					p_msg							CHAR(250),
					p_erro						SMALLINT,
					p_index						SMALLINT,
					p_ies_tip					CHAR ,
					p_tem_lote				SMALLINT,
					l_count						SMALLINT
					
					
					
	DEFINE  l_man_log_apo_prod912 ARRAY[200] OF RECORD LIKE man_log_apo_prod912.*
					
	LET p_erro  = FALSE 
	LET p_index = 1
					
	CALL log085_transacao("BEGIN")
	
	SELECT COUNT(ORDEM_PRODUCAO) 
	INTO l_tem_pend
	FROM MAN_OP_COMPONENTE_OPERACAO
	WHERE EMPRESA  =	p_cod_empresa
	AND ORDEM_PRODUCAO =	p_w_apont_prod.num_ordem
	AND SEQUENCIA_OPERACAO = p_w_apont_prod.num_seq_operac
	
	IF l_tem_pend = 0 THEN
		CALL log085_transacao("COMMIT")
		RETURN TRUE    
	ELSE  
	
		DECLARE cq_comp SCROLL CURSOR WITH HOLD FOR 	
		 SELECT COD_ITEM_COMPON, 
		        QTD_NECESSARIA * (p_w_apont_prod.qtd_boas +	p_w_apont_prod.qtd_refug), 
						COD_LOCAL_BAIXA 
			 FROM	ORD_COMPON, ORDENS,MAN_OP_COMPONENTE_OPERACAO
		  WHERE ORD_COMPON.COD_EMPRESA = ORDENS.COD_EMPRESA
				AND ORD_COMPON.NUM_ORDEM   = ORDENS.NUM_ORDEM
				AND ORDENS.NUM_ORDEM = MAN_OP_COMPONENTE_OPERACAO.ORDEM_PRODUCAO
				AND ORDENS.COD_EMPRESA = MAN_OP_COMPONENTE_OPERACAO.EMPRESA
				AND COD_ITEM_COMPON = MAN_OP_COMPONENTE_OPERACAO.ITEM_COMPONENTE
				AND ORD_COMPON.COD_EMPRESA = p_cod_empresa
				AND ORD_COMPON.NUM_ORDEM   = p_w_apont_prod.num_ordem
				AND MAN_OP_COMPONENTE_OPERACAO.SEQUENCIA_OPERACAO = p_w_apont_prod.num_seq_operac
		
		FOREACH cq_comp INTO 	p_cod_item,
													p_qtd_necessaria,
													p_local_prod
			LET p_qtd_saldo = 0
			LET p_qtd_mvto =0
					
			SELECT round(SUM(qtd_transf - qtd_cons),7)
			INTO p_qtd_saldo
			FROM OP_LOTE
			WHERE COD_EMPRESA = p_cod_empresa
			AND NUM_ORDEM = p_w_apont_prod.num_ordem
			AND COD_ITEM_COMPON = p_cod_item
			AND COD_LOCAL_BAIXA = p_local_prod
			
			IF SQLCA.SQLCODE <> 0 THEN 
				LET p_qtd_saldo  = 0
			END IF 
			
			IF p_qtd_saldo IS NULL THEN 
				LET p_qtd_saldo  = 0
			END IF 
			
			IF p_qtd_saldo >= p_qtd_necessaria THEN 
				
				SELECT SUM(qtd_saldo) 
				INTO p_qtd_estoq
				FROM estoque_lote
				WHERE COD_EMPRESA =p_cod_empresa
				AND COD_LOCAL =p_local_prod
				AND COD_ITEM =p_cod_item
				AND IES_SITUA_QTD = "L"
				
				IF p_qtd_estoq IS NULL THEN 
					LET p_qtd_estoq = 0
				END IF
				
				SELECT SUM(qtd_reservada - qtd_atendida)
		    INTO p_qtd_reservada
				FROM estoque_loc_reser
				WHERE cod_empresa =p_cod_empresa
				AND cod_item    = p_cod_item
				AND cod_local   = p_local_prod
				
				IF p_qtd_reservada IS NULL OR p_qtd_reservada <= 0 THEN
	  			LET p_qtd_reservada = 0
	  		END IF
	  		
	  		LET p_qtd_estoq = p_qtd_estoq - p_qtd_reservada
			
				IF p_qtd_estoq < p_qtd_saldo THEN 
						LET p_erro  = TRUE
				    LET l_man_log_apo_prod912[p_index].texto_resumo = "ITEM -",p_cod_item," DIVERGENCIA ENTRE ESTOQUE E RESERVA"
				    LET l_man_log_apo_prod912[p_index].texto_detalhado = "ITEM - ", p_cod_item," DIVERGENCIA ENTRE LOTE DO ESTOQUE RESERVADO PARA A ORDEM  " ,p_w_apont_prod.num_ordem
				    LET p_index = p_index + 1
				    CONTINUE FOREACH
				ELSE 
					SELECT SUM(qtd_transf - qtd_cons)
					INTO p_qtd_saldo
					FROM OP_LOTE A, ESTOQUE_LOTE B
					WHERE B.COD_EMPRESA = A.COD_EMPRESA
						AND B.COD_ITEM = A.COD_ITEM_COMPON
						AND B.NUM_LOTE = A.NUM_LOTE
						AND A.COD_LOCAL_BAIXA = B.COD_LOCAL
						AND A.COD_EMPRESA  =p_cod_empresa
						AND NUM_ORDEM = p_w_apont_prod.num_ordem
						AND B.COD_ITEM = p_cod_item
						AND IES_SITUA_QTD = 'L'
						
						IF p_qtd_saldo IS NULL THEN 
							LET p_qtd_saldo = 0
						END IF 
						
						IF p_qtd_saldo >= p_qtd_necessaria THEN 
							CONTINUE FOREACH
						ELSE
							LET p_erro  = TRUE
					    LET l_man_log_apo_prod912[p_index].texto_resumo = "ITEM -",p_cod_item," DIVERGENCIA ENTRE ESTOQUE E RESERVA"
				    	LET l_man_log_apo_prod912[p_index].texto_detalhado = "ITEM - ", p_cod_item," DIVERGENCIA ENTRE LOTE DO ESTOQUE RESERVADO PARA A ORDEM  " ,p_w_apont_prod.num_ordem
					    LET p_index = p_index + 1
					    CONTINUE FOREACH
						END IF 
				END IF 
			END IF 
			
			SELECT qtd_movto
			INTO p_qtd_pende
			FROM TRANS_PENDENTES  
			WHERE cod_empresa = p_cod_empresa
			AND num_ordem = p_w_apont_prod.num_ordem
			AND cod_item  = p_cod_item
			AND qtd_movto>0
			
			IF SQLCA.SQLCODE <> 0 THEN 
				LET p_qtd_pende = 0
			END IF 
			
			IF p_qtd_saldo  < p_qtd_necessaria AND p_qtd_pende > = (p_qtd_necessaria - p_qtd_saldo) THEN 
				
				SELECT IES_TIP_ITEM, COD_LOCAL_ESTOQ 
				INTO p_ies_tip ,  p_local_esto
				FROM ITEM
				WHERE COD_EMPRESA =p_cod_empresa
				AND COD_ITEM =p_cod_item
			
				IF p_ies_tip = "F" OR p_ies_tip = "P" OR p_ies_tip='B' THEN 
					LET p_qtd_necessaria = p_qtd_necessaria - p_qtd_saldo
					LET p_qtd_mvto = p_qtd_necessaria
					
					IF p_qtd_pende > 0 THEN 
		         
		        SELECT SUM(qtd_reservada - qtd_atendida)
				    INTO p_qtd_reservada
						FROM estoque_loc_reser
						WHERE cod_empresa =p_cod_empresa
						AND cod_item    = p_cod_item
						AND cod_local   = p_local_esto
						
						IF p_qtd_reservada IS NULL OR p_qtd_reservada <= 0 THEN
			  			LET p_qtd_reservada = 0
			  		END IF
			  		
			  		SELECT SUM(qtd_saldo)
		        INTO p_qtd_saldo
		        FROM estoque_lote
		       WHERE cod_empresa   = p_cod_empresa
		         AND cod_item      = p_cod_item
		         AND cod_local     = p_local_esto
		         AND ies_situa_qtd = "L"
		         
		       IF qtd_saldo IS NULL THEN 
		       		LET p_qtd_saldo = 0
		       END IF 
		       
				   LET p_qtd_saldo  = p_qtd_saldo - p_qtd_reservada 
					 LET p_qtd_mvto = p_qtd_necessaria
				
						IF p_qtd_saldo > 0  THEN 
							IF p_qtd_saldo > = p_qtd_necessaria THEN
								DECLARE cq_saldo  CURSOR FOR 	SELECT ESTOQUE_LOTE.QTD_SALDO, ESTOQUE_LOTE.NUM_LOTE,ESTOQUE_LOTE.NUM_TRANSAC,ESTOQUE_LOTE_ENDER.NUM_TRANSAC  
																								FROM ESTOQUE_LOTE , ESTOQUE_LOTE_ENDER
																								WHERE ESTOQUE_LOTE.COD_ITEM = ESTOQUE_LOTE_ENDER.COD_ITEM
																								AND  ESTOQUE_LOTE.COD_EMPRESA = ESTOQUE_LOTE_ENDER.COD_EMPRESA
																								AND ESTOQUE_LOTE.NUM_LOTE = ESTOQUE_LOTE_ENDER.NUM_LOTE
																								AND ESTOQUE_LOTE.COD_LOCAL =  ESTOQUE_LOTE_ENDER.COD_LOCAL
																								AND ESTOQUE_LOTE.COD_ITEM = p_cod_item
																								AND ESTOQUE_LOTE.COD_LOCAL = p_local_esto
																								AND  ESTOQUE_LOTE.COD_EMPRESA = p_cod_empresa
																								AND ESTOQUE_LOTE.IES_SITUA_QTD="L"
								
								
								FOREACH cq_saldo INTO p_qtd_saldo, p_num_lote ,p_num_transac, p_num_transac1
										LET P_DATA = TODAY
										LET p_hora = CURRENT 
										LET p_data_hor =CURRENT
										LET p_hora_char = p_hora
										
										SELECT SUM(qtd_reservada - qtd_atendida)
								    INTO p_qtd_reservada
										FROM estoque_loc_reser
										WHERE cod_empresa =p_cod_empresa
										AND cod_item    = p_cod_item
										AND cod_local   = p_local_esto
										AND num_lote		= p_num_lote
										
										IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
							  			LET p_qtd_reservada = 0
							  		END IF
							  		
							  		LET p_qtd_saldo  = p_qtd_saldo - p_qtd_reservada 
										
										IF p_qtd_necessaria >  p_qtd_saldo THEN 
										
											UPDATE estoque_lote_ender
											SET QTD_SALDO = 0
											WHERE COD_EMPRESA =p_cod_empresa
											AND num_transac = p_num_transac1
											
											SELECT COUNT(num_lote) 
											INTO l_tem_pend
											FROM ESTOQUE_LOTE_ender
											WHERE COD_EMPRESA =p_cod_empresa
											AND COD_ITEM 			=p_cod_item
											AND COD_LOCAL     =p_local_prod
											AND NUM_LOTE			= p_num_lote
											AND IES_SITUA_QTD ="L"
											
											IF l_tem_pend > 0 THEN 
												
												UPDATE estoque_lote_ender
												SET qtd_saldo = qtd_saldo + p_qtd_saldo
												WHERE COD_EMPRESA =p_cod_empresa
												AND COD_LOCAL =p_local_prod
												AND NUM_LOTE = p_num_lote
												AND COD_ITEM =p_cod_item
												
											ELSE
													INSERT INTO estoque_lote_ender
						              VALUES (p_cod_empresa, p_cod_item,
						                      p_local_prod, p_num_lote,
						                      " ", 0, " ", " ", " ", " ", " ", "1900-01-01 00:00:00",
						                      0, 0, "L", p_qtd_saldo, 0, " ",
						                      "1900-01-01 00:00:00", " ", " ", 0, 0, 0, 0,
						                      "1900-01-01 00:00:00", "1900-01-01 00:00:00",
						                      "1900-01-01 00:00:00", 0, 0, 0, 0, 0, 0, " ",NULL,NULL)
											END IF
											
											SELECT COUNT(cod_empresa)
					          	INTO l_count
					          	FROM op_lote
											WHERE cod_empresa = p_cod_empresa
											AND cod_item_compon = p_cod_item
											AND num_lote = p_num_lote
											AND cod_local_baixa = p_local_prod
											AND NUM_ORDEM = p_w_apont_prod.num_ordem
											
											IF l_count = 0 THEN 
													INSERT INTO OP_LOTE VALUES
													(p_cod_empresa,"P",p_w_apont_prod.num_ordem,p_cod_item,'1900-01-01 00:00:00',p_local_prod,p_num_lote," ",0,'1900-01-01 00:00:00','1900-01-01 00:00:00'," "," ",
													0,0,0,0,p_qtd_saldo,0,"")
											ELSE
												UPDATE OP_LOTE
												SET qtd_transf = qtd_transf + p_qtd_saldo
												WHERE cod_empresa = p_cod_empresa
												AND cod_item_compon = p_cod_item
												AND num_lote = p_num_lote
												AND cod_local_baixa = p_local_prod
												AND NUM_ORDEM = p_w_apont_prod.num_ordem
											END IF
											
											UPDATE estoque_lote
											SET qtd_saldo 	=	 0
											WHERE COD_EMPRESA =p_cod_empresa	
											AND num_transac = p_num_transac
											
											SELECT COUNT(num_lote) 
											INTO l_tem_pend
											FROM ESTOQUE_LOTE
											WHERE COD_EMPRESA =p_cod_empresa
											AND COD_ITEM 			=p_cod_item
											AND COD_LOCAL     =p_local_prod
											AND NUM_LOTE			= p_num_lote
											AND IES_SITUA_QTD ="L"
											
											IF l_tem_pend > 0 THEN 
												UPDATE estoque_lote
												SET qtd_saldo = qtd_saldo + p_qtd_saldo
													WHERE COD_EMPRESA =p_cod_empresa	
													AND COD_ITEM 			=p_cod_item
													AND COD_LOCAL     =p_local_prod
													AND IES_SITUA_QTD ="L"
													AND NUM_LOTE = p_num_lote
											ELSE
													INSERT INTO estoque_lote 
														VALUES(p_cod_empresa,p_cod_item,p_local_prod,p_num_lote,'L',p_qtd_saldo,0)
											END IF
											
											LET p_qtd_necessaria = p_qtd_necessaria - p_qtd_saldo
																				
											INSERT INTO ESTOQUE_TRANS (COD_EMPRESA, COD_ITEM, DAT_MOVTO, DAT_REF_MOEDA_FORT, COD_OPERACAO, NUM_DOCUM, NUM_SEQ, IES_TIP_MOVTO, QTD_MOVTO, CUS_UNIT_MOVTO_P, CUS_TOT_MOVTO_P, CUS_UNIT_MOVTO_F, CUS_TOT_MOVTO_F, NUM_CONTA, NUM_SECAO_REQUIS, COD_LOCAL_EST_ORIG, COD_LOCAL_EST_DEST, NUM_LOTE_ORIG, NUM_LOTE_DEST, IES_SIT_EST_ORIG, IES_SIT_EST_DEST, COD_TURNO, NOM_USUARIO, DAT_PROCES, HOR_OPERAC, NUM_PROG)
											VALUES(p_cod_empresa,p_cod_item,P_DATA,P_DATA,'TRAN',p_w_apont_prod.num_ordem ,NULL,'N',p_qtd_saldo,0,0,0,0,NULL,NULL,p_local_esto
											,p_local_prod,p_num_lote,p_num_lote,'L','L',NULL,'admlog  ',P_DATA,
											p_hora_char,'pol1276 ')
											
											LET p_transac = SQLCA.SQLERRD[2]
											
											INSERT INTO ESTOQUE_TRANS_END (COD_EMPRESA, NUM_TRANSAC, ENDERECO, NUM_VOLUME, QTD_MOVTO, COD_GRADE_1, COD_GRADE_2,
											COD_GRADE_3, COD_GRADE_4, COD_GRADE_5, DAT_HOR_PROD_INI, DAT_HOR_PROD_FIM, VLR_TEMPERATURA, ENDERECO_ORIGEM, NUM_PED_VEN,
											NUM_SEQ_PED_VEN, DAT_HOR_PRODUCAO, DAT_HOR_VALIDADE, NUM_PECA, NUM_SERIE, COMPRIMENTO, LARGURA, ALTURA, DIAMETRO,
											DAT_HOR_RESERV_1, DAT_HOR_RESERV_2, DAT_HOR_RESERV_3, QTD_RESERV_1, QTD_RESERV_2, QTD_RESERV_3, NUM_RESERV_1, NUM_RESERV_2,
											NUM_RESERV_3, TEX_RESERVADO, CUS_UNIT_MOVTO_P, CUS_UNIT_MOVTO_F, CUS_TOT_MOVTO_P, CUS_TOT_MOVTO_F, COD_ITEM, DAT_MOVTO,
											cOD_OPERACAO, IES_TIP_MOVTO, NUM_PROG, IDENTIF_ESTOQUE, DEPOSIT)
											VALUES
											(p_cod_empresa,p_transac,'               ',0,p_qtd_saldo,'   ','     ','   ','    ','   '
											,' 1900-01-01 00:00:00',' 1900-01-01 00:00:00',0,'               ',0,0,'1900-01-01 00:00:00','1900-01-01 00:00:00'
											,' ','  ',0,0,0,0,'1900-01-01 00:00:00','1900-01-01 00:00:00','1900-01-01 00:00:00'
											,0,0,0,0,0,0,'         ',0,0,0,0,p_cod_item,P_DATA,'TRAN','N','pol1276 ',' ',' ')	
											
											INSERT INTO ESTOQUE_AUDITORIA (COD_EMPRESA, NUM_TRANSAC, NOM_USUARIO, DAT_HOR_PROCES, NUM_PROGRAMA) 
											VALUES(p_cod_empresa, p_transac, p_user, p_data_hor , "pol1276")
											
										ELSE 
											UPDATE estoque_lote
											SET qtd_saldo = qtd_saldo -p_qtd_necessaria
											WHERE COD_EMPRESA =p_cod_empresa	
											AND num_transac = p_num_transac
											
											SELECT COUNT(num_lote) 
											INTO l_tem_pend
											FROM ESTOQUE_LOTE
											WHERE COD_EMPRESA =p_cod_empresa
											AND COD_ITEM 			=p_cod_item
											AND COD_LOCAL     =p_local_prod
											AND NUM_LOTE			= p_num_lote
											AND IES_SITUA_QTD ="L"
											
											IF l_tem_pend > 0 THEN 
												UPDATE estoque_lote
												SET qtd_saldo = qtd_saldo + p_qtd_necessaria
												WHERE COD_EMPRESA =p_cod_empresa	
												AND COD_ITEM 			=p_cod_item
												AND COD_LOCAL     =p_local_prod
												AND IES_SITUA_QTD ="L"
												AND NUM_LOTE = p_num_lote
											ELSE
													INSERT INTO estoque_lote 
														VALUES(p_cod_empresa,p_cod_item,
														p_local_prod,p_num_lote,'L',p_qtd_necessaria,0)
											END IF
											
											UPDATE estoque_lote_ender
											SET qtd_saldo = qtd_saldo -p_qtd_necessaria
											WHERE COD_EMPRESA =p_cod_empresa
											AND num_transac = p_num_transac1	
											
											SELECT COUNT(num_lote) 
											INTO l_tem_pend
											FROM ESTOQUE_LOTE_ender
											WHERE COD_EMPRESA =p_cod_empresa
											AND COD_ITEM 			=p_cod_item
											AND COD_LOCAL     =p_local_prod
											AND NUM_LOTE			= p_num_lote
											AND IES_SITUA_QTD ="L"
											
											IF l_tem_pend > 0 THEN 
												
												UPDATE estoque_lote_ender
												SET qtd_saldo = qtd_saldo + p_qtd_necessaria
												WHERE COD_EMPRESA =p_cod_empresa
												AND COD_LOCAL =p_local_prod
												AND NUM_LOTE = p_num_lote
												AND COD_ITEM =p_cod_item
												
											ELSE
													INSERT INTO estoque_lote_ender
						              VALUES (p_cod_empresa, p_cod_item,p_local_prod, p_num_lote,
						                      " ", 0, " ", " ", " ", " ", " ", "1900-01-01 00:00:00",
						                      0, 0, "L", p_qtd_necessaria, 0, " ",
						                      "1900-01-01 00:00:00", " ", " ", 0, 0, 0, 0,
						                      "1900-01-01 00:00:00", "1900-01-01 00:00:00",
						                      "1900-01-01 00:00:00", 0, 0, 0, 0, 0, 0, " ",NULL,NULL)
						          END IF 
					          	SELECT COUNT(cod_empresa)
					          	INTO l_count
					          	FROM op_lote
											WHERE cod_empresa = p_cod_empresa
											AND cod_item_compon = p_cod_item
											AND num_lote = p_num_lote
											AND cod_local_baixa = p_local_prod
											AND NUM_ORDEM = p_w_apont_prod.num_ordem
											
											IF l_count = 0 THEN 
													INSERT INTO OP_LOTE VALUES
													(p_cod_empresa,"P",p_w_apont_prod.num_ordem,p_cod_item,'1900-01-01 00:00:00',p_local_prod,p_num_lote," ",0,'1900-01-01 00:00:00','1900-01-01 00:00:00'," "," ",
													0,0,0,0,p_qtd_necessaria,0,"")
											ELSE
												UPDATE OP_LOTE
												SET qtd_transf = qtd_transf + p_qtd_necessaria
												WHERE cod_empresa = p_cod_empresa
												AND cod_item_compon = p_cod_item
												AND num_lote = p_num_lote
												AND cod_local_baixa = p_local_prod
												AND NUM_ORDEM = p_w_apont_prod.num_ordem
											END IF 
																		
											INSERT INTO ESTOQUE_TRANS (COD_EMPRESA, COD_ITEM, DAT_MOVTO, DAT_REF_MOEDA_FORT, COD_OPERACAO, NUM_DOCUM, NUM_SEQ, IES_TIP_MOVTO, QTD_MOVTO, CUS_UNIT_MOVTO_P, CUS_TOT_MOVTO_P, CUS_UNIT_MOVTO_F, CUS_TOT_MOVTO_F, NUM_CONTA, NUM_SECAO_REQUIS, COD_LOCAL_EST_ORIG, COD_LOCAL_EST_DEST, NUM_LOTE_ORIG, NUM_LOTE_DEST, IES_SIT_EST_ORIG, IES_SIT_EST_DEST, COD_TURNO, NOM_USUARIO, DAT_PROCES, HOR_OPERAC, NUM_PROG)
											VALUES(p_cod_empresa,p_cod_item,P_DATA,P_DATA,'TRAN',p_w_apont_prod.num_ordem ,NULL,'N',p_qtd_necessaria,0,0,0,0,NULL,NULL,p_local_esto
											,p_local_prod,p_num_lote,p_num_lote,'L','L',NULL,'admlog  ',P_DATA,	p_hora_char,'pol1276 ')
											
											LET p_transac = SQLCA.SQLERRD[2]
											
											INSERT INTO ESTOQUE_TRANS_END (COD_EMPRESA, NUM_TRANSAC, ENDERECO, NUM_VOLUME, QTD_MOVTO, COD_GRADE_1, COD_GRADE_2,
											COD_GRADE_3, COD_GRADE_4, COD_GRADE_5, DAT_HOR_PROD_INI, DAT_HOR_PROD_FIM, VLR_TEMPERATURA, ENDERECO_ORIGEM, NUM_PED_VEN,
											NUM_SEQ_PED_VEN, DAT_HOR_PRODUCAO, DAT_HOR_VALIDADE, NUM_PECA, NUM_SERIE, COMPRIMENTO, LARGURA, ALTURA, DIAMETRO,
											DAT_HOR_RESERV_1, DAT_HOR_RESERV_2, DAT_HOR_RESERV_3, QTD_RESERV_1, QTD_RESERV_2, QTD_RESERV_3, NUM_RESERV_1, NUM_RESERV_2,
											NUM_RESERV_3, TEX_RESERVADO, CUS_UNIT_MOVTO_P, CUS_UNIT_MOVTO_F, CUS_TOT_MOVTO_P, CUS_TOT_MOVTO_F, COD_ITEM, DAT_MOVTO,
											cOD_OPERACAO, IES_TIP_MOVTO, NUM_PROG, IDENTIF_ESTOQUE, DEPOSIT)
											VALUES
											(p_cod_empresa,p_transac,'               ',0,p_qtd_necessaria,'   ','     ','   ','    ','   '
											,' 1900-01-01 00:00:00',' 1900-01-01 00:00:00',0,'               ',0,0,'1900-01-01 00:00:00','1900-01-01 00:00:00'
											,' ','  ',0,0,0,0,'1900-01-01 00:00:00','1900-01-01 00:00:00','1900-01-01 00:00:00'
											,0,0,0,0,0,0,'         ',0,0,0,0,p_cod_item,P_DATA,'TRAN','N','pol1276 ',' ',' ')		
											
											INSERT INTO ESTOQUE_AUDITORIA (COD_EMPRESA, NUM_TRANSAC, NOM_USUARIO, DAT_HOR_PROCES, NUM_PROGRAMA) 
												VALUES(p_cod_empresa, p_transac, p_user, p_data_hor , "pol1276")	
											EXIT FOREACH
										END IF #end qtdNecessaria
									#END IF 	#end numlote
								END FOREACH
								
								UPDATE TRANS_PENDENTES  
								SET QTD_MOVTO= QTD_MOVTO - p_qtd_mvto
								WHERE cod_empresa = p_cod_empresa
								AND num_ordem = p_w_apont_prod.num_ordem
								AND cod_item  = p_cod_item
								AND qtd_movto>0
								
							ELSE
								LET p_erro  = TRUE
						    LET l_man_log_apo_prod912[p_index].texto_resumo = "QUANTIDADE DO COMPONETE ",p_cod_item," INSUFICIENTE PARA TRANSFERENCIA"
						    LET l_man_log_apo_prod912[p_index].texto_detalhado = "QUANTIDADE DO COMPONENTE ", p_cod_item," INSUFICIENTE TRANSFERENCIA DA ORDEM " ,p_w_apont_prod.num_ordem
						    LET p_index = p_index + 1
							END IF #qtd_necessaria
						ELSE
							LET p_erro  = TRUE
							
					    LET l_man_log_apo_prod912[p_index].texto_resumo = "QUANTIDADE DO COMPONETE ",p_cod_item," INSUFICIENTE PARA TRANSFERENCIA"
					    LET l_man_log_apo_prod912[p_index].texto_detalhado = "QUANTIDADE DO COMPONENTE ", p_cod_item," INSUFICIENTE TRANSFERENCIA DA ORDEM " ,p_w_apont_prod.num_ordem
					   
					    LET p_index = p_index + 1
						END IF	#slqca
					ELSE
						LET p_erro  = TRUE
				    LET l_man_log_apo_prod912[p_index].texto_resumo = "QUANTIDADE DO COMPONETE ",p_cod_item," INSUFICIENTE PARA TRANSFERENCIA"
					  LET l_man_log_apo_prod912[p_index].texto_detalhado = "QUANTIDADE DO COMPONENTE ", p_cod_item," INSUFICIENTE TRANSFERENCIA DA ORDEM " ,p_w_apont_prod.num_ordem
						LET p_index = p_index + 1
					END IF #tem pend
				ELSE
					LET p_erro  = TRUE
			    LET l_man_log_apo_prod912[p_index].texto_resumo = "QUANTIDADE DO COMPONETE ",p_cod_item," INSUFICIENTE PARA TRANSFERENCIA"
				  LET l_man_log_apo_prod912[p_index].texto_detalhado = "QUANTIDADE DO COMPONENTE ", p_cod_item," INSUFICIENTE TRANSFERENCIA DA ORDEM " ,p_w_apont_prod.num_ordem, " ITEM NÃO PODE SER TRASNFERIDO INSUMO"
			    LET p_index = p_index + 1
				END IF 
			ELSE
					LET p_erro  = TRUE
			    LET l_man_log_apo_prod912[p_index].texto_resumo = "QUANTIDADE DO COMPONETE ",p_cod_item," INSUFICIENTE PARA TRANSFERENCIA"
				  LET l_man_log_apo_prod912[p_index].texto_detalhado = "QUANTIDADE DO COMPONENTE ", p_cod_item," INSUFICIENTE TRANSFERENCIA DA ORDEM " ,p_w_apont_prod.num_ordem, " ITEM NÃO PODE SER TRASNFERIDO INSUMO"
			    LET p_index = p_index + 1
			END IF #saldo notfound
			
		DELETE FROM TRANS_PENDENTES	
		WHERE cod_empresa = p_cod_empresa
		AND   COD_ITEM    = p_cod_item  
		AND QTD_MOVTO     <= 0
		
		DELETE FROM estoque_lote_ender
		WHERE COD_EMPRESA = p_cod_empresa
		AND   COD_ITEM    = p_cod_item  
		AND QTD_SALDO     = 0
		AND IES_SITUA_QTD ="L"
		
		DELETE FROM estoque_lote
		WHERE COD_EMPRESA = p_cod_empresa
		AND   COD_ITEM    = p_cod_item  
		AND QTD_SALDO     = 0
		AND IES_SITUA_QTD ="L"
		END FOREACH
		
		
		
	END IF 
	
	IF p_erro THEN 																			#INSERE O ERRO
		CALL log085_transacao("ROLLBACK")
		CALL pol1276_Executa_update()
		CALL SET_COUNT(p_index-1)
		FOR p_index = 1 TO ARR_COUNT()
			LET l_man_log_apo_prod912[p_index].empresa = p_cod_empresa
	    LET l_man_log_apo_prod912[p_index].item = p_w_apont_prod.cod_item
	    LET l_man_log_apo_prod912[p_index].ordem_producao = p_w_apont_prod.num_ordem
	    LET l_man_log_apo_prod912[p_index].num_seq_operac = p_w_apont_prod.num_seq_operac
	    LET l_man_log_apo_prod912[p_index].num_operador = 	p_w_apont_prod.num_operador
	    LET l_man_log_apo_prod912[p_index].tip_apontamento  = 2
	    LET l_man_log_apo_prod912[p_index].tip_movimentacao = "A"
	    LET l_man_log_apo_prod912[p_index].apo_operacao = 1
	    LET l_man_log_apo_prod912[p_index].sit_apontamento = "A"
	    LET l_man_log_apo_prod912[p_index].operacao = p_w_apont_prod.cod_operacao
	    LET l_man_log_apo_prod912[p_index].tip_mensagem ="E"
	    LET l_man_log_apo_prod912[p_index].erro = 0
			LET l_man_log_apo_prod912[p_index].programa = "PGI351"
			LET l_man_log_apo_prod912[p_index].dat_processamento = CURRENT 
			LET l_man_log_apo_prod912[p_index].hor_processamento = CURRENT 
			LET l_man_log_apo_prod912[p_index].usuario = p_user
			let l_man_log_apo_prod912[p_index].num_seq_registro = p_w_apont_prod.num_seq_registro
			
			SELECT MAX(seq_reg_mestre + 1)
			INTO l_man_log_apo_prod912[p_index].seq_reg_mestre
			FROM man_log_apo_prod912
			
			IF l_man_log_apo_prod912[p_index].seq_reg_mestre IS NULL THEN 
				LET l_man_log_apo_prod912[p_index].seq_reg_mestre = p_index
			END IF 
			LET l_man_log_apo_prod912[p_index].transacao = p_w_apont_prod.num_ordem
			 LET l_man_log_apo_prod912[p_index].seq_mensagem  = 0
			 INSERT INTO man_log_apo_prod912 VALUES (l_man_log_apo_prod912[p_index].*)
		END FOR 
		RETURN FALSE 
	ELSE
		CALL log085_transacao("COMMIT")
	END IF 

		
	RETURN TRUE
	
	
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
	