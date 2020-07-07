#-------------------------------------------------------------------#
# SISTEMA.: ESTOQUE                                                 #
# PROGRAMA: pol0919                                                 #
# CLIENTE: ALBRAS                                                                  #
#           																								        #
#                                                                   #
# OBJETIVO: RETORNAR AO ESTOQUE ITENS DEVOLVIDOS POR CLIENTES       #
# AUTOR...: POLO INFORMATICA - THIAGO                               #
# DATA....: 10/03/2009                                              #
#-------------------------------------------------------------------#
DATABASE logix
GLOBALS
   DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
          p_den_empresa   LIKE empresa.den_empresa,  
          p_user          LIKE usuario.nom_usuario,
          p_msg           CHAR(100),
          p_status        SMALLINT,
          p_houve_erro    SMALLINT,
          comando         CHAR(80),
      #   p_versao        CHAR(17),
          p_versao        CHAR(18),
          p_ies_impressao CHAR(001),
          g_ies_ambiente  CHAR(001),
          p_nom_arquivo   CHAR(100),
          p_arquivo       CHAR(025),
          p_caminho       CHAR(080),
          p_nom_tela      CHAR(200),
          p_nom_help      CHAR(200),
          sql_stmt        CHAR(300),
          p_r             CHAR(001),
          p_count         SMALLINT,
          p_ies_cons      SMALLINT,
          p_last_row      SMALLINT,
          p_grava         SMALLINT, 
          pa_curr         SMALLINT,
          pa_curr1        SMALLINT,
          sc_curr         SMALLINT,
          sc_curr1        SMALLINT,
          w_a             SMALLINT,
          p_index					SMALLINT,
          s_index					SMALLINT,
          p_retorno				SMALLINT,
          where_clause		CHAR(300),
          p_agora         DATETIME YEAR TO SECOND,
          p_hoje          DATE, 
          p_num_transac   								LIKE estoque_lote_ender.num_transac,{recebe o numero da transaçao}
          p_num_transac_orig							LIKE estoque_trans_end.num_transac,{numero da transação a ser gerado pelo banco ao inserir dados na tabela estoque_trans}
					p_nota_dev											LIKE dev_mestre.num_nff			{numero da nota fiscal de devoluçao}
						
DEFINE 	p_estoque_trans						RECORD	LIKE 	estoque_trans.*,
				p_estoque_lote_ender			RECORD	LIKE 	estoque_lote_ender.*
END GLOBALS

DEFINE 		p_ent_item							RECORD 
					qtd_necessaria					LIKE ord_compon.qtd_necessaria, {qtdade de item utilizada}
					cod_local_estoq 				LIKE item.cod_local_estoq {local onde o item sera estocado}
					END RECORD 

{--onde estiver o (*) siguinifica que esta passando parametros para query por uma variavel--}

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0919-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0919.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0919_controle()
   END IF
END MAIN

#-------------------------#
FUNCTION pol0919_controle()
#-------------------------#

CALL log006_exibe_teclas("01", p_versao)
   CALL log130_procura_caminho("pol0919") RETURNING comando    
   OPEN WINDOW w_pol0919 AT 2,2 WITH FORM comando
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parametros"
         HELP 0001
         IF log005_seguranca(p_user,"VDP","pol0919","CO") THEN
            IF pol0919_entrada_dados() THEN
               LET p_ies_cons = TRUE
               NEXT OPTION "Processar"
            END IF
         END IF
      COMMAND "Processar" "Processa e retorna itens das notas devoluçao ao estoque"
         HELP 0002
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0919","CO") THEN
               LET p_ies_cons = FALSE
               IF pol0919_processa_saida() THEN 
               	IF pol0919_processa_entrada() THEN 
               		ERROR 'Dados processados com sucesso !!!'
                  NEXT OPTION 'Fim'
                ELSE 
                	ERROR 'Erro ao processar os dados !!!'
                END IF 
               ELSE 
               		ERROR 'Erro ao processar os dados !!!'
               END IF
            END IF
         ELSE
            ERROR 'Informe os parâmetros previamente !!!'
            NEXT OPTION 'Informar'
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0919_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0919

END FUNCTION


#-----------------------------------#
FUNCTION pol0919_verifica_nff()
#-----------------------------------#
DEFINE l_cod_cliente			LIKE dev_mestre.cod_cliente, {codigo do cliente}
			 
			 l_num_nff_origem		LIKE dev_mestre.num_nff_origem	{numero da nota fiscal de origem}
													
			SELECT UNIQUE a.num_nff_origem, a.cod_cliente
			INTO l_num_nff_origem, l_cod_cliente
			FROM dev_mestre a
			WHERE a.num_nff = p_nota_dev				    
      
      IF SQLCA.SQLCODE <> 0 THEN 
      	RETURN FALSE 
      ELSE
				DISPLAY	l_num_nff_origem	TO num_nff_origem
				DISPLAY  l_cod_cliente	TO cod_cliente
				RETURN TRUE 
      END	IF 
END FUNCTION
#--------------------------------------#
FUNCTION pol0919_entrada_dados()
#--------------------------------------#
 CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0919
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_nota_dev TO NULL
   INPUT  p_nota_dev WITHOUT DEFAULTS  
   FROM num_nff
			AFTER FIELD num_nff
				IF p_nota_dev IS NULL THEN
							ERROR "Campo com Preenchimento Obrigatório !!!"
            	NEXT FIELD num_nff
           ELSE
              	IF pol0919_verifica_nff() = FALSE THEN
	           			ERROR "Nota de devolução não cadastrada!"
	         				NEXT FIELD num_nff
         			 END IF
    	 	END IF	
   END INPUT 
   IF INT_FLAG = 0 THEN
      LET p_retorno = TRUE 
   ELSE
   		INITIALIZE p_nota_dev TO NULL
      CLEAR FORM
      LET p_retorno = FALSE
      LET INT_FLAG = 0
   END IF
   RETURN(p_retorno)
END FUNCTION 

#-------------------------------------#
FUNCTION pol0919_processa_saida()
#-------------------------------------#
DEFINE l_num_seq			LIKE aviso_rec.num_seq
	INITIALIZE p_estoque_trans TO NULL
	CALL log085_transacao("BEGIN")
	DECLARE cq_item_sai CURSOR FOR	
					SELECT UNIQUE b.num_aviso_rec, b.cod_item, b.num_seq
					FROM nf_sup a, aviso_rec b
					WHERE a.ies_especie_nf = 'NFD'
						AND a.cod_empresa = b.cod_empresa
						AND a.num_aviso_rec = b.num_aviso_rec
						AND a.cod_empresa =p_cod_empresa{*}
						AND a.num_nf=p_nota_dev	{*}	
		
		FOREACH cq_item_sai INTO p_estoque_trans.num_docum,
														 p_estoque_trans.cod_item,
														 p_estoque_trans.num_seq 
		
											SELECT 	qtd_movto, num_conta, cod_local_est_orig, 
															cod_local_est_dest,num_lote_orig,num_lote_dest,
															ies_sit_est_orig, ies_sit_est_dest, ies_tip_movto
											INTO p_estoque_trans.qtd_movto,
													 p_estoque_trans.num_conta,
													 p_estoque_trans.cod_local_est_orig,
													 p_estoque_trans.cod_local_est_dest,
													 p_estoque_trans.num_lote_orig,
													 p_estoque_trans.num_lote_dest,
													 p_estoque_trans.ies_sit_est_orig,
													 p_estoque_trans.ies_sit_est_dest,
													 p_estoque_trans.ies_tip_movto
											FROM estoque_trans
											WHERE cod_item = p_estoque_trans.cod_item {*}
												AND num_docum = p_estoque_trans.num_docum {*}
												AND num_seq = p_estoque_trans.num_seq{*}
												AND cod_empresa = p_cod_empresa{*}
			IF SQLCA.SQLCODE = 0 THEN 											
				 LET p_hoje = TODAY
				 IF p_estoque_trans.ies_sit_est_dest = 'L' THEN
				      UPDATE estoque
				      SET qtd_liberada = qtd_liberada - p_estoque_trans.qtd_movto{*},
				         dat_ult_saida = p_hoje
				       WHERE cod_empresa = p_cod_empresa{*}
				         	AND cod_item    = p_estoque_trans.cod_item {*}
				        IF STATUS <> 0 THEN
									CALL log003_err_sql("GRAVAÇÃO","estoque")
							    CALL log085_transacao("ROLLBACK")
							     RETURN FALSE
							  END IF
				  ELSE
				      UPDATE estoque
				      SET qtd_lib_excep = qtd_lib_excep - p_estoque_trans.qtd_movto{*},
				          dat_ult_saida = p_hoje 
				      WHERE cod_empresa = p_cod_empresa{*}
				         	AND cod_item    = p_estoque_trans.cod_item{*}
				      IF STATUS <> 0 THEN
									CALL log003_err_sql("GRAVAÇÃO","estoque")
							    CALL log085_transacao("ROLLBACK")
							     RETURN FALSE
							  END IF
				  END IF
	   			{---Dando Baixa na tabela de estoque_lote_ender---}
		      IF pol0919_valida_num_lote_ender() THEN 
	 				 	UPDATE estoque_lote_ender
			      SET qtd_saldo = qtd_saldo - p_estoque_trans.qtd_movto{*}
			    	WHERE cod_empresa   = p_cod_empresa{*}
					      AND num_transac = p_estoque_lote_ender.num_transac{*}
					 	IF STATUS <> 0 THEN
							CALL log003_err_sql("GRAVAÇÃO","estoque_lote_ender")
					    CALL log085_transacao("ROLLBACK")
					     RETURN FALSE
					  END IF
					ELSE 
						ERROR "ITEM ",p_estoque_trans.cod_item," SEM QUANTIDADE NO ESTOUE" 
						CALL log085_transacao("ROLLBACK")
						RETURN FALSE			      	
					END IF  
		      {---Dando Baixa na tabela de estoque_lote---}
		      IF pol0919_valida_num_lote() THEN 
			      UPDATE estoque_lote
			      SET qtd_saldo = qtd_saldo - p_estoque_trans.qtd_movto{*}
			    	WHERE cod_empresa   = p_cod_empresa{*}
					      AND num_transac = p_num_transac{*}
						  IF STATUS <> 0 THEN
								CALL log003_err_sql("GRAVAÇÃO","estoque_lote")
						    CALL log085_transacao("ROLLBACK")
						     RETURN FALSE
						  END IF
					ELSE 
						ERROR "ITEM ",p_estoque_trans.cod_item," SEM QUANTIDADE NO ESTOUE" 
						CALL log085_transacao("ROLLBACK")
						RETURN FALSE
					END IF
					SELECT cod_oper_ent 
					INTO p_estoque_trans.cod_operacao
					FROM oper_dev_304
						WHERE cod_empresa = p_cod_empresa	
							
					IF NOT  pol0919_ins_est_trans() THEN {insere na tabela estoque trans}
						CALL log085_transacao("ROLLBACK")
						RETURN FALSE 
					END IF 
			ELSE 
				CALL log085_transacao("ROLLBACK")
				RETURN FALSE
			END IF 
		END FOREACH
		CALL pol0919_deleta_lote()
		CALL log085_transacao("COMMIT")
		RETURN TRUE 
END FUNCTION 
#-------------------------------------#
FUNCTION pol0919_processa_entrada()
#-------------------------------------#
DEFINE l_num_pedido LIKE ordens.num_docum
INITIALIZE l_num_pedido TO NULL
INITIALIZE p_ent_item TO NULL
INITIALIZE p_estoque_trans TO NULL 
	DECLARE cq_ped CURSOR FOR 	
													SELECT UNIQUE a.num_pedido 
													FROM wfat_item a, dev_mestre b
													WHERE a.cod_empresa = b.cod_empresa
														AND a.num_nff = b.num_nff_origem
														AND b.num_nff=p_nota_dev{*}
														AND b.cod_empresa = p_cod_empresa{*}
						
	IF SQLCA.SQLCODE <> 0 THEN
		RETURN FALSE
	ELSE 
		FOREACH cq_ped INTO l_num_pedido
				
				DECLARE cq_ent_item CURSOR FOR 
														SELECT b.cod_item_compon, b.qtd_necessaria,c.cod_local_estoq
															from ordens a, ord_compon b, item c
															WHERE a.cod_empresa = b.cod_empresa
															AND a.num_ordem = b.num_ordem
															AND b.cod_empresa = c.cod_empresa
															AND b.cod_item_compon = c.cod_item
															AND a.cod_empresa = p_cod_empresa{*}
															AND a.num_docum = l_num_pedido{*}
		IF SQLCA.SQLCODE = 0 THEN
				FOREACH cq_ent_item INTO p_estoque_trans.cod_item,
																 p_estoque_trans.qtd_movto,
																 p_estoque_trans.cod_local_est_dest
					{---Dando Entrada na tabela de estoque---}		
		LET 	 p_estoque_trans.ies_sit_est_dest = 'L'
		LET 	 p_estoque_trans.ies_sit_est_orig = 'L'
		      
		      SELECT qtd_liberada 
		      FROM estoque 
		      WHERE cod_empresa = p_cod_empresa{*}
		         	AND cod_item    = p_estoque_trans.cod_item{*}
		      LET p_hoje = TODAY
		      IF STATUS = 0 THEN  		
			      UPDATE estoque
			      SET qtd_liberada = qtd_liberada + p_estoque_trans.qtd_movto{*},
			         dat_ult_entrada = p_hoje
			       WHERE cod_empresa = p_cod_empresa{*}
			         	AND cod_item    = p_estoque_trans.cod_item{*}
			         		
			        IF STATUS <> 0 THEN
			        	
								CALL log003_err_sql("GRAVAÇÃO","estoque")
						    CALL log085_transacao("ROLLBACK")
						     
						    RETURN FALSE
									   
						  END IF
						ELSE
							INSERT INTO estoque VALUES(
										p_cod_empresa,p_estoque_trans.cod_item,p_estoque_trans.qtd_movto,
										0,0,0,0,0,'01/01/1900',p_hoje,'01/01/1900')
										IF STATUS <> 0 THEN
											CALL log003_err_sql("GRAVAÇÃO","estoque")
									    CALL log085_transacao("ROLLBACK")
									     
									     RETURN FALSE
									   END IF 
						END IF 
					  
						{---Dando Entrada na tabela de estoque_lote_ender---}
			      IF pol0919_valida_num_lote_ender() THEN
	   				 	UPDATE estoque_lote_ender
				      SET qtd_saldo = qtd_saldo + p_estoque_trans.qtd_movto{*}
				    	WHERE cod_item = p_estoque_trans.cod_item
									AND cod_local = p_estoque_trans.cod_local_est_dest
									AND cod_empresa = p_cod_empresa
						 			AND num_lote      IS NULL
						 			AND ies_situa_qtd ='L'
						 	IF STATUS <> 0 THEN
						 		CALL log003_err_sql("GRAVAÇÃO","estoque_lote_ender")
						    CALL log085_transacao("ROLLBACK")
						     
						    RETURN FALSE
						
							END IF
						ELSE
							INSERT INTO estoque_lote_ender
		              VALUES (p_cod_empresa, p_estoque_trans.cod_item,
		                      p_estoque_trans.cod_local_est_dest, NULL,
		                      " ", 0, " ", " ", " ", " ", " ", "1900-01-01 00:00:00",
		                      0, 0, "L", p_estoque_trans.qtd_movto, 0, " ",
		                      "1900-01-01 00:00:00", " ", " ", 0, 0, 0, 0,
		                      "1900-01-01 00:00:00", "1900-01-01 00:00:00",
		                      "1900-01-01 00:00:00", 0, 0, 0, 0, 0, 0, " ")
		            IF STATUS <> 0 THEN          
		              CALL log003_err_sql("GRAVAÇÃO","estoque_lote_ender")
							    CALL log085_transacao("ROLLBACK")
							    RETURN FALSE
							  END IF 
						END IF 			      	
			      
			      {---Dando Entrada na tabela de estoque_lote---}
			       IF pol0919_valida_num_lote_ender() THEN
					      UPDATE estoque_lote
					      SET qtd_saldo = qtd_saldo + p_estoque_trans.qtd_movto{*}
					    	WHERE cod_item = p_estoque_trans.cod_item
											AND cod_local = p_estoque_trans.cod_local_est_dest
											AND cod_empresa = p_cod_empresa
											AND num_lote      IS NULL
											AND ies_situa_qtd ='L'
							      	
							  IF STATUS <> 0 THEN
								  CALL log003_err_sql("GRAVAÇÃO","estoque_lote")
							    CALL log085_transacao("ROLLBACK")
							     
							    RETURN FALSE
							  END IF
						 ELSE
						 	INSERT INTO estoque_lote VALUES(p_cod_empresa,p_estoque_trans.cod_item,
										p_estoque_trans.cod_local_est_dest,null,'L',p_estoque_trans.qtd_movto,0)
								
								IF STATUS <> 0 THEN		
									CALL log003_err_sql("GRAVAÇÃO","estoque_lote")
							    CALL log085_transacao("ROLLBACK")
							     
							    RETURN FALSE
							  END IF 
						 END IF 
				 LET p_estoque_lote_ender.endereco					= " "
			   LET p_estoque_lote_ender.cod_grade_1				=	" "
			   LET p_estoque_lote_ender.cod_grade_2				=	" "
			   LET p_estoque_lote_ender.cod_grade_3				=	" "
			   LET p_estoque_lote_ender.cod_grade_4				=	" "
			   LET p_estoque_lote_ender.cod_grade_5				=	" "
			   LET p_estoque_lote_ender.num_ped_ven				= 0
			   LET p_estoque_lote_ender.num_seq_ped_ven		= 0
			   LET p_estoque_lote_ender.dat_hor_producao	="1900-01-01 00:00:00"
			   LET p_estoque_lote_ender.dat_hor_validade	="1900-01-01 00:00:00"
			   LET p_estoque_lote_ender.num_peca					= 0
			   LET p_estoque_lote_ender.num_serie					= 0
			   LET p_estoque_lote_ender.comprimento				= 0
			   LET p_estoque_lote_ender.largura						= 0
			   LET p_estoque_lote_ender.altura						= 0
			   LET p_estoque_lote_ender.diametro					= 0
			   LET p_estoque_lote_ender.dat_hor_reserv_1	= "1900-01-01 00:00:00"
			   LET p_estoque_lote_ender.dat_hor_reserv_2	= "1900-01-01 00:00:00"
			   LET p_estoque_lote_ender.dat_hor_reserv_3	= "1900-01-01 00:00:00"
			   LET p_estoque_lote_ender.qtd_reserv_1			=	0
			   LET p_estoque_lote_ender.qtd_reserv_2			=	0
			   LET p_estoque_lote_ender.qtd_reserv_3			=	0
			   LET p_estoque_lote_ender.num_reserv_1			=	0
			   LET p_estoque_lote_ender.num_reserv_2			=	0
			   LET p_estoque_lote_ender.num_reserv_3			=	0
				 LET p_estoque_trans.num_conta=0
				# LET p_estoque_trans.cod_local_est_orig = 
				 LET p_estoque_trans.num_lote_orig = NULL 
				 LET p_estoque_trans.num_lote_dest = NULL 
				 LET p_estoque_trans.ies_sit_est_orig = 'L'
				 LET p_estoque_trans.ies_sit_est_dest = 'L'
				 LET p_estoque_trans.ies_tip_movto = 'N'
				 LET p_estoque_trans.num_docum =''
						
						SELECT cod_oper_sai 
						INTO p_estoque_trans.cod_operacao
						FROM oper_dev_304
							WHERE cod_empresa = 01
						
						IF NOT  pol0919_ins_est_trans() THEN {insere na tabela estoque trans}
							CALL log085_transacao("ROLLBACK")
							RETURN FALSE 
						END IF 	
				END FOREACH
			RETURN TRUE 
		ELSE
			RETURN FALSE 
		END IF 
	END FOREACH		
	CALL log085_transacao("COMMIT")
	END IF 
END FUNCTION

#-----------------------------#
FUNCTION pol0919_deleta_lote()
#-----------------------------#
CALL log085_transacao("BEGIN")
		   DELETE FROM estoque_lote
		   WHERE cod_empresa = p_cod_empresa{*}
		      AND qtd_saldo   <= 0
		    IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 AND SQLCA.SQLCODE <> NOTFOUND THEN
		     	CALL log003_err_sql("DELETAR","estoque_lote")
					CALL log085_transacao("ROLLBACK")
		    END IF 
		   DELETE FROM estoque_lote_ender
		   WHERE cod_empresa = p_cod_empresa{*}
		         AND qtd_saldo   <= 0
		   IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 AND SQLCA.SQLCODE <> NOTFOUND THEN
		     	CALL log003_err_sql("DELETAR","estoque_lote_ender")
					CALL log085_transacao("ROLLBACK")
		    END IF
	CALL log085_transacao("COMMIT")
END FUNCTION

#------------------------------------#
FUNCTION pol0919_valida_num_lote_ender()
#------------------------------------#
   IF p_estoque_trans.num_lote_dest IS NOT NULL  THEN
		   SELECT *
		     INTO p_estoque_lote_ender.*
		     FROM estoque_lote_ender
		    WHERE cod_empresa = p_cod_empresa{*}
		      AND cod_item      = p_estoque_trans.cod_item{*}
		      AND cod_local     = p_estoque_trans.cod_local_est_dest{*}
		      AND num_lote      = p_estoque_trans.num_lote_dest{*}
		      AND ies_situa_qtd = p_estoque_trans.ies_sit_est_dest{*}
   ELSE
		   SELECT *
		     INTO p_estoque_lote_ender.*
		     FROM estoque_lote_ender
		    WHERE cod_empresa = p_cod_empresa{*}
		      AND cod_item      = p_estoque_trans.cod_item{*}
		      AND cod_local     = p_estoque_trans.cod_local_est_dest{*}
		      AND num_lote      IS NULL 
		      AND ies_situa_qtd = p_estoque_trans.ies_sit_est_dest{*}
   END IF  
   IF STATUS <> 0 THEN
      RETURN FALSE
      
   ELSE 
   		RETURN TRUE 
   END IF  
END FUNCTION 

#-----------------------------#
FUNCTION pol0919_valida_num_lote()
#-----------------------------#
   IF p_estoque_trans.num_lote_dest IS NOT NULL THEN
		   SELECT num_transac 
		     INTO p_num_transac
		     FROM estoque_lote
		    WHERE cod_empresa = p_cod_empresa{*}
		      AND cod_item      = p_estoque_trans.cod_item{*}
		      AND cod_local     = p_estoque_trans.cod_local_est_dest{*}
		      AND num_lote      =p_estoque_trans.num_lote_dest
		      AND ies_situa_qtd = p_estoque_trans.ies_sit_est_dest{*}
   ELSE
		   SELECT num_transac, 
		     INTO p_num_transac
		     FROM estoque_lote
		    WHERE cod_empresa = p_cod_empresa{*}
		      AND cod_item      = p_estoque_trans.cod_item{*}
		      AND cod_local     = p_estoque_trans.cod_local_est_dest{*}
		      AND num_lote      IS NULL 
		      AND ies_situa_qtd = p_estoque_trans.ies_sit_est_dest{*}
   END IF
   
   IF STATUS <> 0  THEN
      RETURN FALSE
   ELSE 
   		RETURN TRUE 
   END IF  
END FUNCTION 

#------------------------------------#
 FUNCTION pol0919_ins_est_trans_end()
#------------------------------------#
DEFINE p_estoque_trans_end		RECORD LIKE estoque_trans_end.*

{passando os valores de estoque_lote_ender para estoque_trans_
end para facilitar na hora de inserir os dados  }
	LET p_estoque_trans_end.num_transac      = p_num_transac_orig
	LET p_estoque_trans_end.endereco         = p_estoque_lote_ender.endereco
   LET p_estoque_trans_end.cod_grade_1      = p_estoque_lote_ender.cod_grade_1
   LET p_estoque_trans_end.cod_grade_2      = p_estoque_lote_ender.cod_grade_2
   LET p_estoque_trans_end.cod_grade_3      = p_estoque_lote_ender.cod_grade_3
   LET p_estoque_trans_end.cod_grade_4      = p_estoque_lote_ender.cod_grade_4
   LET p_estoque_trans_end.cod_grade_5      = p_estoque_lote_ender.cod_grade_5
   LET p_estoque_trans_end.num_ped_ven      = p_estoque_lote_ender.num_ped_ven
   LET p_estoque_trans_end.num_seq_ped_ven  = p_estoque_lote_ender.num_seq_ped_ven
   LET p_estoque_trans_end.dat_hor_producao = p_estoque_lote_ender.dat_hor_producao
   LET p_estoque_trans_end.dat_hor_validade = p_estoque_lote_ender.dat_hor_validade
   LET p_estoque_trans_end.num_peca         = p_estoque_lote_ender.num_peca
   LET p_estoque_trans_end.num_serie        = p_estoque_lote_ender.num_serie
   LET p_estoque_trans_end.comprimento      = p_estoque_lote_ender.comprimento
   LET p_estoque_trans_end.largura          = p_estoque_lote_ender.largura
   LET p_estoque_trans_end.altura           = p_estoque_lote_ender.altura
   LET p_estoque_trans_end.diametro         = p_estoque_lote_ender.diametro
   LET p_estoque_trans_end.dat_hor_reserv_1 = p_estoque_lote_ender.dat_hor_reserv_1
   LET p_estoque_trans_end.dat_hor_reserv_2 = p_estoque_lote_ender.dat_hor_reserv_2
   LET p_estoque_trans_end.dat_hor_reserv_3 = p_estoque_lote_ender.dat_hor_reserv_3
   LET p_estoque_trans_end.qtd_reserv_1     = p_estoque_lote_ender.qtd_reserv_1
   LET p_estoque_trans_end.qtd_reserv_2     = p_estoque_lote_ender.qtd_reserv_2
   LET p_estoque_trans_end.qtd_reserv_3     = p_estoque_lote_ender.qtd_reserv_3
   LET p_estoque_trans_end.num_reserv_1     = p_estoque_lote_ender.num_reserv_1
   LET p_estoque_trans_end.num_reserv_2     = p_estoque_lote_ender.num_reserv_2
   LET p_estoque_trans_end.num_reserv_3     = p_estoque_lote_ender.num_reserv_3
	LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa
	LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item
	LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
	LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
	LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
	LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto
	LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog
	LET p_estoque_trans_end.cus_unit_movto_p = 0
	LET p_estoque_trans_end.cus_unit_movto_f = 0
	LET p_estoque_trans_end.cus_tot_movto_p  = 0
	LET p_estoque_trans_end.cus_tot_movto_f  = 0
	LET p_estoque_trans_end.num_volume       = 0
	LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
	LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
	LET p_estoque_trans_end.vlr_temperatura  = 0
	LET p_estoque_trans_end.endereco_origem  = ' '
	LET p_estoque_trans_end.tex_reservado    = " "
		
		IF p_num_transac_orig IS NOT NULL THEN 
		
			INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)
			
			IF STATUS <> 0 THEN
				CALL log003_err_sql("GRAVAÇÃO","estoque_trans_end")
		    DELETE FROM estoque_trans_end WHERE num_transac = p_num_transac_orig
		     
		     RETURN FALSE
		  ELSE 
		  	IF NOT pol0919_ins_est_audi() THEN {insere na tabela estoque_auditoria}
		  		DELETE FROM estoque_trans_end WHERE num_transac = p_num_transac_orig
		  		RETURN FALSE 
		  	END IF 
		  	
		  	RETURN TRUE 
		  END IF
		END IF 	
END FUNCTION

#------------------------------------#
 FUNCTION pol0919_ins_est_trans()
#------------------------------------#
	

	 LET p_estoque_trans.cod_empresa        = p_cod_empresa
   LET p_estoque_trans.num_transac        = 0
   LET p_estoque_trans.dat_movto          = TODAY
   LET p_estoque_trans.dat_ref_moeda_fort = TODAY
   LET p_estoque_trans.dat_proces         = TODAY
   LET p_estoque_trans.hor_operac         = TIME
   LET p_estoque_trans.num_prog           = "POL0919"
   LET p_estoque_trans.num_seq            = NULL
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_secao_requis   = NULL
   LET p_estoque_trans.nom_usuario        = p_user
   
    INSERT INTO estoque_trans(
          cod_empresa,cod_item,dat_movto, dat_ref_moeda_fort,
          cod_operacao,num_docum,num_seq,ies_tip_movto,
          qtd_movto,cus_unit_movto_p,cus_tot_movto_p,
          cus_unit_movto_f,cus_tot_movto_f, num_conta,
          num_secao_requis, cod_local_est_orig,
          cod_local_est_dest, num_lote_orig, num_lote_dest,
          ies_sit_est_orig,ies_sit_est_dest,cod_turno,
          nom_usuario, dat_proces,hor_operac, num_prog)   
          VALUES (p_estoque_trans.cod_empresa, p_estoque_trans.cod_item,
                  p_estoque_trans.dat_movto,p_estoque_trans.dat_ref_moeda_fort,
                  p_estoque_trans.cod_operacao,p_estoque_trans.num_docum,
                  p_estoque_trans.num_seq,p_estoque_trans.ies_tip_movto,
                  p_estoque_trans.qtd_movto,p_estoque_trans.cus_unit_movto_p,
                  p_estoque_trans.cus_tot_movto_p,p_estoque_trans.cus_unit_movto_f,
                  p_estoque_trans.cus_tot_movto_f,p_estoque_trans.num_conta,
                  p_estoque_trans.num_secao_requis,p_estoque_trans.cod_local_est_orig,
                  p_estoque_trans.cod_local_est_dest,p_estoque_trans.num_lote_orig,
                  p_estoque_trans.num_lote_dest,p_estoque_trans.ies_sit_est_orig,
                  p_estoque_trans.ies_sit_est_dest,p_estoque_trans.cod_turno,
                  p_estoque_trans.nom_usuario,p_estoque_trans.dat_proces,
                  p_estoque_trans.hor_operac,p_estoque_trans.num_prog)  
                  
	IF STATUS <> 0 THEN
		CALL log003_err_sql("GRAVAÇÃO","estoque_trans")
     RETURN FALSE
  ELSE 
  	LET p_num_transac_orig = SQLCA.SQLERRD[2]
  	IF NOT pol0919_ins_est_trans_end() THEN {insere na tabela estoque_trans_end}
			DELETE FROM estoque_trans WHERE num_transac = p_num_transac_orig
			RETURN FALSE 
		END IF 
  	
  	RETURN TRUE 
  END IF
 

END FUNCTION

#------------------------------------#
 FUNCTION pol0919_ins_est_audi()
#------------------------------------#
	IF p_num_transac_orig IS NOT NULL THEN 
		
		LET p_agora = CURRENT 
		
		INSERT INTO estoque_auditoria 
    VALUES(p_cod_empresa, p_num_transac_orig, p_user,p_agora,'POL0919')
    
	    IF STATUS <> 0 THEN
				CALL log003_err_sql("GRAVAÇÃO","plan_inspecao_1120")
		    DELETE FROM estoque_trans WHERE num_transac = p_num_transac_orig
		     
		     RETURN FALSE
		  ELSE 
		  	
		  	RETURN TRUE 
		  END IF
   
	ELSE
		RETURN FALSE  
	END IF 
END FUNCTION

#-----------------------#
 FUNCTION pol0919_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION