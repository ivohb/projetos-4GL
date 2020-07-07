#-------------------------------------------------------------------#
# SISTEMA.: QUALIDADE                                               #
# PROGRAMA: pol0903                                                 #
# MODULOS.: pol0903 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: CADASTRAR PLANO DE CONTROLE DE INSPEÇÃO - ROVEMAR       #
# AUTOR...: LOGOCENTER GSP - THIAGO				                    			#
# DATA....: 20/01/5009                                              #
# Modificaçao:  adicionado um botão para alterar a sequencia para q #
#				caso seja excluida uam sequencia no logix possamos a				#
#				alterar no programa tambem																	#
#-------------------------------------------------------------------#
DATABASE logix
GLOBALS
   DEFINE p_cod_empresa 		  LIKE empresa.cod_empresa,
          p_den_empresa 		  LIKE empresa.den_empresa,  
          p_den_roteiro       CHAR(30),
          p_msg               CHAR(600),
          p_del               CHAR(100),
          p_upd               CHAR(100),
          p_ins               CHAR(100),
          p_user        		  LIKE usuario.nom_usuario,
          p_status      		  SMALLINT,
          p_houve_erro  		  SMALLINT,
          comando     	 		  CHAR(80),
          p_versao    		    CHAR(18),
          p_ies_impressao 		CHAR(001),
          g_ies_ambiente 		  CHAR(001),
          p_nom_arquivo   		CHAR(100),
          p_arquivo       		CHAR(025),
          p_caminho       		CHAR(080),
          p_nom_tela      		CHAR(200),
          p_nom_help      		CHAR(200),
          sql_stmt        		CHAR(300),
          sql_stmt1       		CHAR(1000),
          p_count         		SMALLINT,
          p_ies_cons      		SMALLINT,
          p_ies_cons1      		SMALLINT,
          p_cod_item       		LIKE plan_inspecao_1120.cod_item,
         	p_num_seq_operac  	LIKE plan_inspecao_1120.num_seq_operac,
          p_index							SMALLINT,
          s_index							SMALLINT,
          p_index3						SMALLINT,
          s_index3						SMALLINT,
          p_retorno						SMALLINT,
          where_clause				CHAR(300),
          p_den_item					LIKE	item.den_item,
          p_den_opercac				LIKE	operacao.den_operac,
          l_sequencia_cota   	SMALLINT,
          l_val_cota					SMALLINT,
          parametro						CHAR(1),
          p_ies_tip_item			LIKE item.ies_tip_item,
          p_valida						SMALLINT,
          l_den_operac        LIKE operacao.den_operac,
          p_den_item_reduz    LIKE item.den_item_reduz,
          p_ies_copia         SMALLINT,
          p_ind               SMALLINT,
          p_meio_inspecao     CHAR(15),
          p_cota_ant          DECIMAL(6,0),
          p_mod_inst          SMALLINT
         
   DEFINE p_cod_operac     LIKE plan_inspecao_1120.cod_operac,
          p_cod_roteiro    LIKE plan_inspecao_1120.cod_roteiro,
          l_num_seq_operac LIKE consumo.num_seq_operac
         
END GLOBALS

	DEFINE  es_tela						RECORD
					cod_item       		LIKE plan_inspecao_1120.cod_item,      
					cod_roteiro       LIKE plan_inspecao_1120.cod_roteiro,
					cod_operac        LIKE plan_inspecao_1120.cod_operac,   
					num_seq_operac   	LIKE plan_inspecao_1120.num_seq_operac    
	END RECORD  
	DEFINE  p_es_tela					RECORD
					cod_item       		LIKE plan_inspecao_1120.cod_item,      
					cod_roteiro       LIKE plan_inspecao_1120.cod_roteiro,   
					cod_operac        LIKE plan_inspecao_1120.cod_operac,  
					num_seq_operac   	LIKE plan_inspecao_1120.num_seq_operac    
	END RECORD        
	DEFINE  di_tela 					ARRAY[500] OF	 RECORD
					sequencia_cota   	LIKE plan_inspecao_1120.sequencia_cota,
					num_cota         	LIKE plan_inspecao_1120.num_cota, 
					cota   						LIKE plan_inspecao_1120.sequencia_cota,
					den_cota					LIKE cotas_1120.den_cota,
					cod_unid_med      LIKE plan_inspecao_1120.cod_unid_med,   
					val_nominal       LIKE plan_inspecao_1120.val_nominal,  
					variacao_menor    LIKE plan_inspecao_1120.variacao_menor,   
					variacao_maior    LIKE plan_inspecao_1120.variacao_maior, 
					imprime_ind				LIKE plan_inspecao_1120.imprime_ind,
					instrumento				CHAR(1),
					pecas							LIKE plan_inspecao_1120.qtd_pecas,
					frequencia 				LIKE plan_inspecao_1120.frequencia,
					texto    					LIKE plan_inspecao_1120.texto
	END RECORD

	DEFINE  di_seq 					  ARRAY[500] OF	 RECORD
					sequencia_cota   	LIKE plan_inspecao_1120.sequencia_cota
	END RECORD

		DEFINE vai_tela 				 RECORD
					sequencia_cota   	LIKE plan_inspecao_1120.sequencia_cota,    
					num_cota         	LIKE plan_inspecao_1120.num_cota,
					cota    					LIKE plan_inspecao_1120.sequencia_cota,
					den_cota					LIKE cotas_1120.den_cota,
					cod_unid_med      LIKE plan_inspecao_1120.cod_unid_med,   
					val_nominal       LIKE plan_inspecao_1120.val_nominal,  
					variacao_menor    LIKE plan_inspecao_1120.variacao_menor,   
					variacao_maior    LIKE plan_inspecao_1120.variacao_maior, 
					imprime_ind				LIKE plan_inspecao_1120.imprime_ind,
					instrumento				CHAR(1),
					pecas							LIKE plan_inspecao_1120.qtd_pecas,
					frequencia 				LIKE plan_inspecao_1120.frequencia,
					texto    					LIKE plan_inspecao_1120.texto
	END RECORD
	DEFINE 	p_operac				ARRAY[1000] OF RECORD
					cod_operac      LIKE plan_inspecao_1120.cod_operac,
					num_seq_operac  LIKE plan_inspecao_1120.num_seq_operac,
					den_operac			LIKE operacao.den_operac
	END RECORD
	DEFINE 	p_meio_insp				RECORD 
					cod_item       		LIKE plan_inspecao_1120.cod_item,      
					cod_operac        LIKE plan_inspecao_1120.cod_operac,  
					num_seq_operac   	LIKE plan_inspecao_1120.num_seq_operac,    
					cod_roteiro       LIKE plan_inspecao_1120.cod_roteiro , 
					num_cota         	LIKE plan_inspecao_1120.num_cota,    
					sequencia_cota    LIKE plan_inspecao_1120.sequencia_cota,
					cota              LIKE plan_inspecao_1120.cota
	END RECORD 
	DEFINE 	p_meio_insp1					RECORD 
					cod_item       		LIKE plan_inspecao_1120.cod_item,      
					cod_operac        LIKE plan_inspecao_1120.cod_operac,  
					num_seq_operac   	LIKE plan_inspecao_1120.num_seq_operac,    
					cod_roteiro       LIKE plan_inspecao_1120.cod_roteiro , 
					num_cota         	LIKE plan_inspecao_1120.num_cota,    
					sequencia_cota    LIKE plan_inspecao_1120.sequencia_cota,
					cota              LIKE plan_inspecao_1120.cota
	END RECORD 
	DEFINE  p_inst							ARRAY[500] OF RECORD
					meio_inspecao  			LIKE avf_meio_inspecao.meio_inspecao,
					des_meio_inspecao  	LIKE avf_meio_inspecao.des_meio_inspecao
	END RECORD
	DEFINE  p_inst_b						RECORD
					meio_inspecao  			LIKE avf_meio_inspecao.meio_inspecao,
					des_meio_inspecao  	LIKE avf_meio_inspecao.des_meio_inspecao
	END RECORD
	
	DEFINE p_tela_copia         RECORD
	       cod_item             LIKE item.cod_item
	END RECORD
	       
	DEFINE pr_copia_operac       ARRAY[2000] OF RECORD
	       cod_roteiro_copia    LIKE plan_inspecao_1120.cod_roteiro,
	       cod_operac_copia     LIKE plan_inspecao_1120.cod_operac,
	       num_seq_operac_copia	LIKE plan_inspecao_1120.num_seq_operac,
	       ies_copia            CHAR(01)
	END RECORD
	
	DEFINE p_copia_operacao     RECORD
	       cod_item       		  LIKE plan_inspecao_1120.cod_item,      
				 cod_operac           LIKE plan_inspecao_1120.cod_operac,   
				 num_seq_operac     	LIKE plan_inspecao_1120.num_seq_operac,    
				 cod_roteiro          LIKE plan_inspecao_1120.cod_roteiro,
				 num_cota         	  LIKE plan_inspecao_1120.num_cota, 
				 sequencia_cota   	  LIKE plan_inspecao_1120.sequencia_cota,   
				 cota   					   	LIKE plan_inspecao_1120.cota,
				 cod_unid_med         LIKE plan_inspecao_1120.cod_unid_med,   
				 val_nominal          LIKE plan_inspecao_1120.val_nominal,  
				 variacao_menor       LIKE plan_inspecao_1120.variacao_menor,   
				 variacao_maior       LIKE plan_inspecao_1120.variacao_maior, 
				 imprime_ind			   	LIKE plan_inspecao_1120.imprime_ind,
				 pecas							  LIKE plan_inspecao_1120.qtd_pecas,
				 frequencia 				  LIKE plan_inspecao_1120.frequencia,
				 texto    					  LIKE plan_inspecao_1120.texto
	END RECORD 
	
	DEFINE p_inseri             RECORD LIKE plan_inspecao_1120.*
	DEFINE p_inseri_meio        RECORD LIKE meio_inspecao_1120.*
	
	#METODO MAIN QUE INCIA O SISTEMA
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "pol0903-12.00.01"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0903.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0903_controle()
   END IF
END MAIN

#-----------------------#
FUNCTION pol0903_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#--------------------------#
 FUNCTION pol0903_controle() 
#--------------------------#
	CALL log006_exibe_teclas("01",p_versao)
	INITIALIZE p_nom_tela TO NULL
	CALL log130_procura_caminho("pol0903") RETURNING p_nom_tela
	LET  p_nom_tela = p_nom_tela CLIPPED 
	OPEN WINDOW w_pol0903 AT 2,2 WITH FORM p_nom_tela 
	  ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  IF NOT pol0903_cria_temp() THEN
     RETURN
  END IF
  
  LET p_mod_inst = FALSE
  
	MENU "OPCAO"
		COMMAND "Incluir" "Inclui dados na Tabela"
			HELP 001
			MESSAGE ""
			LET INT_FLAG = 0
			CALL log085_transacao("BEGIN")
			CALL pol0903_incluir() RETURNING p_status
			IF p_status THEN
				CALL log085_transacao("COMMIT")
				MESSAGE "Inclusão de Dados Efetuada c/ Sucesso !!!"
				ATTRIBUTE(REVERSE)
			ELSE
				CALL log085_transacao("ROLLBACK")
				MESSAGE "Operação Cancelada !!!"
				ATTRIBUTE(REVERSE)
			END IF      
			LET p_ies_cons = FALSE   
		COMMAND "Modificar" "Modifica/Inclui dados na Tabela"
			HELP 002
			MESSAGE ""
			LET INT_FLAG = 0
			IF es_tela.cod_item IS NOT NULL THEN
				IF p_ies_cons THEN
					CALL log085_transacao("BEGIN")
					CALL pol0903_modificar() RETURNING p_status
					IF p_status THEN
					CALL log085_transacao("COMMIT")
					 MESSAGE "Modificação de Dados Efetuada c/ Sucesso !!!"
					    ATTRIBUTE(REVERSE)
					ELSE
					CALL log085_transacao("ROLLBACK")
					 MESSAGE "Operação Cancelada !!!"
					    ATTRIBUTE(REVERSE)
					END IF      
				ELSE
					ERROR "Execute Previamente a Consulta !!!"
				END IF
			ELSE
				ERROR "Execute Previamente a Consulta !!!"
			END IF 
	  COMMAND "Excluir" "Exclui Todos os dados da Tela"
	     HELP 003
	     MESSAGE ""
	     LET INT_FLAG = 0
	     IF p_ies_cons THEN
	        IF es_tela.cod_item IS NULL THEN
	           ERROR "Não há dados na tela a serem excluídos !!!"
	        ELSE
	        	 CALL log085_transacao("BEGIN")
	           CALL pol0903_excluir() RETURNING p_status
	           IF p_status THEN
	           		CALL log085_transacao("COMMIT")
	              MESSAGE "Exclusão de Dados Efetuada c/ Sucesso !!!"
	                 ATTRIBUTE(REVERSE)
	           ELSE
	           		CALL log085_transacao("ROLLBACK")
	              MESSAGE "Operação Cancelada !!!"
	                 ATTRIBUTE(REVERSE)
	           END IF      
	        END IF
	     ELSE
	        ERROR "Execute Previamente a Consulta !!!"
	     END IF
	  COMMAND "Consultar" "Consulta Dados da Tabela"
	     HELP 004
	     MESSAGE "" 
	     LET INT_FLAG = 0
	     CALL pol0903_consulta()
	     IF p_ies_cons THEN
	        NEXT OPTION "Seguinte" 
	     END IF
	  COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
	     HELP 005
	     MESSAGE ""
	     LET INT_FLAG = 0
	     CALL pol0903_paginacao("SEGUINTE")
	  COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
	     HELP 006
	     MESSAGE ""
	     LET INT_FLAG = 0
	     CALL pol0903_paginacao("ANTERIOR")
	  COMMAND KEY ("T")"insTrumentos" "Cadastro de instrumentos"
	     HELP 006
	     MESSAGE ""
	     LET INT_FLAG = 0
	     CALL pol0903_controle_inst()
	     LET p_mod_inst = FALSE
	  COMMAND "modificar_Seq" "Modifica o numero de sequencia da operação"
			HELP 002
			MESSAGE ""
			LET INT_FLAG = 0
			IF es_tela.cod_item IS NOT NULL THEN
				IF p_ies_cons THEN
				  LET p_ies_cons = FALSE
					CALL log085_transacao("BEGIN")
					CALL pol0903_compatibiliza() RETURNING p_status
					IF p_status THEN
						CALL log085_transacao("COMMIT")
					  MESSAGE "Modificação de Dados Efetuada c/ Sucesso !!!"   ATTRIBUTE(REVERSE)
					ELSE
						CALL log085_transacao("ROLLBACK")
						MESSAGE "Operação Cancelada !!!"	ATTRIBUTE(REVERSE)
					END IF      
				ELSE
					ERROR "Execute Previamente a Consulta !!!"
				END IF
			ELSE
				ERROR "Execute Previamente a Consulta !!!"
			END IF
    COMMAND "Listar" "Lista os Dados do Cadastro"
	     HELP 003
	     MESSAGE ""
	     IF NOT pol0903_informar() THEN 
	        ERROR "Operação Cancelada !!!"
	        CONTINUE MENU
	     END IF
	     IF log005_seguranca(p_user,"VDP","pol0903","MO") THEN
	        IF log028_saida_relat(18,35) IS NOT NULL THEN
	           MESSAGE " Processando a Extracao do Relatorio..." 
	              ATTRIBUTE(REVERSE)
	           IF p_ies_impressao = "S" THEN
	              IF g_ies_ambiente = "U" THEN
	                 START REPORT pol0903_relat TO PIPE p_nom_arquivo
	              ELSE
	                 CALL log150_procura_caminho ('LST') RETURNING p_caminho
	                 LET p_caminho = p_caminho CLIPPED, 'pol0903.tmp'
	                 START REPORT pol0903_relat  TO p_caminho
	              END IF
	           ELSE
	              START REPORT pol0903_relat TO p_nom_arquivo
	           END IF
	           IF NOT  pol0903_emite_relatorio()  THEN
	           		ERROR "Erro ao processar dados "
	           END IF   
	           IF p_count = 0 THEN
	              ERROR "Nao Existem Dados para serem Listados" 
	           ELSE
	              ERROR "Relatorio Processado com Sucesso" 
	           END IF
	           FINISH REPORT pol0903_relat   
	        ELSE
	           CONTINUE MENU
	        END IF                                                     
	        IF p_ies_impressao = "S" THEN
	           MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
	              ATTRIBUTE(REVERSE)
	           IF g_ies_ambiente = "W" THEN
	              LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
	                            p_nom_arquivo
	              RUN comando
	           END IF
	        ELSE
	           MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
	              " " ATTRIBUTE(REVERSE)
	        END IF                              
	        NEXT OPTION "Fim"
	     END IF 
    COMMAND KEY ("O") "copia Operação" "Copia a operação corrente do item atual !!!"
       IF p_ies_cons THEN 
          IF pol0903_copia_operacao() THEN 
             LET p_ies_cons = FALSE
             ERROR "Operação efetuada com sucesso !!!"
          ELSE
             ERROR "Operação cancelada !!!"
          END IF 
       ELSE
          ERROR "Consulte previamente para fazer a cópia !!!"
          NEXT OPTION "Consultar"
       END IF 
    COMMAND KEY ("B") "soBre" "Exibe a versão do programa"
       CALL pol0903_sobre() 

    COMMAND KEY ("Z") "equaliZa" "Equaliza as tabelas de cota e ferramentas"
       IF pol0903_equaliza() THEN
          CALL log0030_mensagem('Processamento efetuado c/ sucesso.','excla')
       ELSE
          CALL log0030_mensagem('Operação cancelada.','excla')
       END IF

	  COMMAND KEY ("!")
	     PROMPT "Digite o comando : " FOR comando
	     RUN comando
	     PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
	     DATABASE logix
	     LET INT_FLAG = 0
	  COMMAND "Fim"       "Retorna ao Menu Anterior"
	     HELP 008
	     MESSAGE ""
	     EXIT MENU
	END MENU
CLOSE WINDOW w_pol0903
END FUNCTION

#---------------------------#
FUNCTION pol0903_equaliza()
#---------------------------#
   
   SELECT COUNT(cod_empresa)
     INTO p_count
     FROM meio_copia_1120

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("SELECT","meio_copia_1120")
			RETURN FALSE
	 END IF
   
   IF p_count > 0 THEN
      CALL log0030_mensagem('Esse processo já foi efetuado\n e não pode ser repetido!', 'excla')
      RETURN FALSE
   END IF                             
      
	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("ALTER","meio_copia_1120:add.cota")
			RETURN  FALSE
	 END IF
	 
	 INSERT INTO meio_copia_1120 SELECT * FROM meio_inspecao_1120 
	  
	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("INSERT","meio_copia_1120")
			RETURN FALSE
	 END IF

   CALL log085_transacao("BEGIN")
      
   IF NOT pol0903_atualiza_meio() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0903_atualiza_meio()#
#-------------------------------#

   DECLARE cq_atu CURSOR FOR
    SELECT DISTINCT 
           cod_empresa,
           cod_item,
           cod_roteiro,
           cod_operac,
           num_seq_operac
      FROM plan_inspecao_1120
     ORDER BY
           cod_empresa,
           cod_item,
           cod_roteiro,
           cod_operac,
           num_seq_operac


   FOREACH cq_atu INTO 
      p_inseri.cod_empresa,   
      p_inseri.cod_item,      
      p_inseri.cod_roteiro,   
      p_inseri.cod_operac,    
      p_inseri.num_seq_operac 

	    IF STATUS <> 0 THEN 
			   CALL log003_err_sql("FOREACH","cq_atu")
			   RETURN FALSE
	    END IF
	 
	    DECLARE cq_le_plan CURSOR FOR
	     SELECT num_cota, sequencia_cota, cota
	       FROM plan_inspecao_1120
        WHERE cod_empresa    = p_inseri.cod_empresa  
          AND cod_item       = p_inseri.cod_item      
          AND cod_roteiro    = p_inseri.cod_roteiro   
          AND cod_operac     = p_inseri.cod_operac    
	      ORDER BY num_cota, sequencia_cota
      
      FOREACH cq_le_plan INTO 
         p_inseri.num_cota,   
         p_inseri.sequencia_cota,      
         p_inseri.cota   
         
	       IF STATUS <> 0 THEN 
			      CALL log003_err_sql("FOREACH","cq_le_plan")
			      RETURN FALSE
	       END IF
	       
	       UPDATE meio_inspecao_1120
	          SET cota = p_inseri.cota
	        WHERE cod_empresa    = p_inseri.cod_empresa   
	          AND cod_item       = p_inseri.cod_item      
	          AND cod_roteiro    = p_inseri.cod_roteiro   
	          AND cod_operac     = p_inseri.cod_operac    
	          AND num_seq_operac = p_inseri.num_seq_operac 
	          AND num_cota       = p_inseri.num_cota
	          AND sequencia_cota = p_inseri.sequencia_cota
	          
	       IF STATUS <> 0 THEN 
			      CALL log003_err_sql("UPDATE","meio_inspecao_1120")
			      RETURN FALSE
	       END IF
      
      END FOREACH
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION   
   

#---------------------------#
FUNCTION pol0903_cria_temp()#
#---------------------------#

   DROP TABLE meio_temp_1120
   
   CREATE TEMP  TABLE meio_temp_1120(
      sequencia_cota  integer,
	    cota            decimal(6,0),
	    meio_inspecao   CHAR(15))

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","meio_temp_1120")
			RETURN FALSE
	 END IF

   DROP TABLE plan_temp_1120
   
   CREATE TEMP TABLE plan_temp_1120 (
    num_cota       decimal(6,0),
    cota           decimal(6,0),
    cod_unid_med   char(3),
    val_nominal    decimal(10,4),
    variacao_menor decimal(10,4),
    variacao_maior decimal(10,4),
    imprime_ind    char(1),
    qtd_pecas      decimal(6,0),
    frequencia     char(5),
    texto          varchar(250)
   );

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","plan_temp_1120")
			RETURN FALSE
	 END IF

	 RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol0903_incluir()
#-----------------------#
	
	LET p_retorno = FALSE
	
	IF pol0903_aceita_chave() THEN 
	   DELETE FROM meio_temp_1120
		 IF pol0903_aceita_itens("INCLUIR") THEN
		    CALL log085_transacao("BEGIN")
		    IF NOT pol0903_grava_itens() THEN
		       CALL log085_transacao("ROLLBACK")
		    ELSE
		       CALL log085_transacao("COMMIT")
		       LET p_retorno = TRUE
		    END IF
		 END IF
	END IF

	RETURN(p_retorno)
	
END FUNCTION

#-----------------------------#
FUNCTION pol0903_aceita_chave()
#-----------------------------#
  
  DEFINE par 		SMALLINT 
	CALL log006_exibe_teclas("01 02 07",p_versao)
	CURRENT WINDOW IS w_pol0903
	CLEAR FORM
	DISPLAY p_cod_empresa TO cod_empresa
	INITIALIZE es_tela TO NULL
	INITIALIZE p_cod_item,p_num_seq_operac,
	          es_tela.cod_item,es_tela.num_seq_operac TO NULL

	INPUT BY NAME es_tela.* WITHOUT DEFAULTS  
		
		AFTER FIELD cod_item
			IF es_tela.cod_item IS NULL THEN
				ERROR "Campo com Preenchimento Obrigatório !!!"
				NEXT FIELD cod_item
			END IF
			
			IF pol0903_verifica_item() = FALSE THEN
					ERROR "Item não cadastrado"
					NEXT FIELD cod_item
			END IF
			
			IF p_ies_tip_item MATCHES '[BC]' THEN
			ELSE
  			 IF NOT pol0903_validar()  THEN
			      LET p_msg = 'Item sem roteiro na tabela consumo!'
			      CALL log0030_mensagem(p_msg,'excla')
			      NEXT FIELD cod_item
			   END IF
			END IF
         
		AFTER FIELD cod_roteiro
		
		IF p_ies_tip_item MATCHES '[BC]' THEN
		   let es_tela.cod_roteiro = 0
		   let p_den_roteiro = ' '
		else
			IF es_tela.cod_roteiro IS NULL THEN
				ERROR "Campo com Preenchimento Obrigatório !!!"
				NEXT FIELD cod_roteiro
			END IF
			
			SELECT COUNT(roteiro)
			  INTO p_count
			  FROM man_processo_item
			 WHERE empresa = p_cod_empresa
			   AND item    = es_tela.cod_item
			   AND roteiro = es_tela.cod_roteiro
			
			IF p_count = 0 THEN
			   ERROR 'Roteiro não cadstrado para o item informado!'
			   NEXT FIELD cod_roteiro
			END IF
			
			CALL pol0903_le_roteiro(es_tela.cod_roteiro)
	  END IF
	  
		DISPLAY es_tela.cod_roteiro TO cod_roteiro
		DISPLAY p_den_roteiro TO den_roteiro

		AFTER FIELD cod_operac
			IF es_tela.cod_operac IS NULL THEN
				ERROR "Campo com Preenchimento Obrigatório !!!"
				NEXT FIELD cod_operac
			END IF
      
      IF es_tela.cod_roteiro IS NULL OR es_tela.cod_roteiro = 0 THEN
      ELSE
			   SELECT COUNT(operacao)
			     INTO p_count
			     FROM man_processo_item
			    WHERE empresa = p_cod_empresa
			      AND item    = es_tela.cod_item
			      AND roteiro = es_tela.cod_roteiro
			
			   IF p_count = 0 THEN
			      ERROR 'Operação não cadstrado para o item/roteiro informados!'
			      NEXT FIELD cod_operac
			   END IF
      END IF
      
			SELECT den_operac 
			  INTO l_den_operac
			  FROM operacao 
			 WHERE cod_empresa = p_cod_empresa
			   AND cod_operac  = es_tela.cod_operac 
			   
			IF STATUS = 100 THEN
			   ERROR 'Operação não cadastrada na tabela operação'
         NEXT FIELD cod_operac
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','operacao')   
            NEXT FIELD cod_operac
         END IF
      END IF 

 		  DISPLAY l_den_operac TO den_operac

		  IF p_ies_tip_item = 'B' OR p_ies_tip_item='C' THEN 
		     SELECT MAX(num_seq_operac)
		       INTO es_tela.num_seq_operac
		       FROM plan_inspecao_1120
		      WHERE cod_empresa = p_cod_empresa
		        AND cod_item    = es_tela.cod_item
		     
		     IF STATUS <> 0 THEN
		        CALL log003_err_sql('Lendo','plan_inspecao_1120')
		        NEXT FIELD cod_operac
		     END IF
		     
		     IF es_tela.num_seq_operac IS NULL THEN
		        LET es_tela.num_seq_operac = 0
		     END IF
		      
 			   LET es_tela.num_seq_operac = es_tela.num_seq_operac + 1
			   LET es_tela.cod_roteiro=0
		  END IF

		AFTER FIELD num_seq_operac
				 
		  IF p_ies_tip_item = 'B' OR p_ies_tip_item='C' THEN  
			ELSE  
			   SELECT roteiro
			     FROM man_processo_item
			    WHERE empresa    = p_cod_empresa
			      AND operacao     = es_tela.cod_operac 
			      AND seq_operacao = es_tela.num_seq_operac
			      AND item       = es_tela.cod_item 
			      AND roteiro    = es_tela.cod_roteiro

         IF STATUS <> 0 AND STATUS <> 100 THEN
            CALL log003_err_sql('Lendo','consumo')   
            NEXT FIELD cod_operac
         END IF
			   
			   IF STATUS =  100 THEN
			      LET p_msg = 'Operação não prevista no roteiro do item informado!'
			      CALL log0030_mensagem(p_msg,'excla')
			      NEXT FIELD cod_operac
			   END IF
			END IF   
      
      DISPLAY es_tela.cod_roteiro TO cod_roteiro
      	
 		  IF pol0903_verifica_duplicidade() THEN
			 	 ERROR "Item/operação/sequência já cadastrado !!!"
			 	 NEXT FIELD cod_item
		  END IF
			
			EXIT INPUT
			
		ON KEY (control-z)
		   CALL pol0903popup()
		   
	END INPUT 
	
	IF INT_FLAG = 0 THEN
	  LET p_retorno = TRUE 
	ELSE
		INITIALIZE es_tela TO NULL
	  CLEAR FORM
	  LET p_retorno = FALSE
	  LET INT_FLAG = 0
	END IF
	
	RETURN(p_retorno)
	
END FUNCTION 
	 
#-------------------------------#
 FUNCTION pol0903_verifica_item() 
#-------------------------------#
	
	DEFINE l_den_item         LIKE item.den_item

	SELECT den_item, ies_tip_item
	INTO l_den_item, p_ies_tip_item
	FROM item
	WHERE cod_empresa     = p_cod_empresa
	AND cod_item = es_tela.cod_item
	
	IF sqlca.SQLCODE = 0 THEN
	  DISPLAY l_den_item to den_item
	  RETURN TRUE
	ELSE
	  RETURN FALSE
	END IF
END FUNCTION   

#-------------------------#
FUNCTION pol0903_validar()
#-------------------------#

   DEFINE p_cont	SMALLINT

   SELECT COUNT(*) 
	   INTO p_cont 
	   FROM operacao a, man_processo_item b 
	  WHERE a.cod_empresa = empresa 
	    AND a.cod_operac  = operacao 
	    AND b.item    = es_tela.cod_item 
	    AND b.empresa = p_cod_empresa

   IF p_cont > 0 THEN
		  RETURN TRUE
	 ELSE 
		  RETURN FALSE 
	 END IF 

END FUNCTION

#-----------------------------------------#
FUNCTION pol0903_le_roteiro(p_cod_roteiro)
#-----------------------------------------#
   
   DEFINE p_cod_roteiro LIKE roteiro.cod_roteiro
   
   SELECT den_roteiro
     INTO p_den_roteiro
     FROM roteiro
    WHERE cod_empresa = p_cod_empresa
      AND cod_roteiro = p_cod_roteiro
   
   IF STATUS <> 0 THEN
      LET p_den_roteiro = ''
   END IF

END FUNCTION

#--------------------------------------#
 FUNCTION pol0903_verifica_duplicidade() 
#---------------------------------------#
   
   DEFINE l_cont         SMALLINT

	 IF p_ies_tip_item ='B'OR p_ies_tip_item='C' THEN 
		 SELECT COUNT(cod_item)
		   INTO l_cont
		   FROM plan_inspecao_1120
		  WHERE cod_empresa     = p_cod_empresa
		    AND cod_item = es_tela.cod_item
	 ELSE 
		 SELECT COUNT(cod_item)
		   INTO l_cont
		   FROM plan_inspecao_1120
		  WHERE cod_empresa    = p_cod_empresa
		    AND cod_item       = es_tela.cod_item
		    AND cod_operac     = es_tela.cod_operac
		    AND num_seq_operac = es_tela.num_seq_operac
		    AND cod_roteiro    = es_tela.cod_roteiro
	 END IF 
	
	 IF l_cont>0 THEN 
		  RETURN TRUE 
	 ELSE
			DISPLAY es_tela.num_seq_operac TO num_seq_operac
			DISPLAY es_tela.cod_roteiro TO cod_roteiro
			RETURN FALSE  
	 END IF

END FUNCTION

#-----------------------------------#
FUNCTION pol0903_aceita_itens(p_func)
#-----------------------------------#

DEFINE  p_func						CHAR(10),
				l_index						SMALLINT,
				l_ind							SMALLINT,
				l_sequencia				SMALLINT,
				l_primeira_vez		SMALLINT,
				l_sequencia1			SMALLINT,
				p_repetiu         SMALLINT
				 				
	INITIALIZE di_tela TO NULL
	LET p_index = 1
	
	DECLARE cq_cota CURSOR FOR 	
	 SELECT 	num_cota, sequencia_cota,cota, cod_unid_med, val_nominal,
						variacao_maior, variacao_menor, imprime_ind,qtd_pecas,frequencia ,texto
		 FROM plan_inspecao_1120
 	  WHERE	cod_empresa    = p_cod_empresa 
		  AND cod_item       = es_tela.cod_item
	 	  AND cod_operac     = es_tela.cod_operac
			AND num_seq_operac = es_tela.num_seq_operac
			AND cod_roteiro	   = es_tela.cod_roteiro
		ORDER BY cota
	
   FOREACH cq_cota INTO 
	        di_tela[p_index].num_cota,
					di_tela[p_index].sequencia_cota,     
					di_tela[p_index].cota,               					
					di_tela[p_index].cod_unid_med,       					
					di_tela[p_index].val_nominal,        					
					di_tela[p_index].variacao_maior,     					
					di_tela[p_index].variacao_menor,     					
					di_tela[p_index].imprime_ind,        					
					di_tela[p_index].pecas,              					
					di_tela[p_index].frequencia,         					
					di_tela[p_index].texto               					
	
		INITIALIZE di_tela[p_index].den_cota TO NULL

		SELECT den_cota
		  INTO di_tela[p_index].den_cota
		  FROM cotas_1120
		 WHERE cod_empresa = p_cod_empresa
		   AND num_cota = di_tela[p_index].num_cota

		SELECT COUNT(meio_inspecao)
		  INTO p_count
		  FROM meio_temp_1120
		 WHERE cota = di_tela[p_index].cota
		
		IF p_count > 0 THEN 
			LET di_tela[p_index].instrumento = '*'
		ELSE 
			LET di_tela[p_index].instrumento = ''
		END IF 
		
		LET p_index = p_index + 1
		
		IF p_index > 500 THEN
		   EXIT FOREACH
		END IF
		
   END FOREACH
	
	CALL SET_COUNT(p_index - 1) 
	
   INPUT ARRAY di_tela WITHOUT DEFAULTS FROM  s_itens.*
      
      BEFORE ROW
		 	  LET p_index = ARR_CURR() 
        LET s_index = SCR_LINE()
      
      AFTER DELETE

        FOR p_ind = 1 TO ARR_COUNT()                                                                        
            LET di_tela[p_ind].sequencia_cota = p_ind
            DISPLAY p_ind TO s_itens[p_ind].sequencia_cota                                                                                       
        END FOR                                                                                                

      AFTER INSERT

        FOR p_ind = 1 TO ARR_COUNT()                                                                        
            LET di_tela[p_ind].sequencia_cota = p_ind
            DISPLAY p_ind TO s_itens[p_ind].sequencia_cota                                                                                       
        END FOR       
        
        LET p_cota_ant = NULL                                                                                         
       
      BEFORE FIELD num_cota
         LET vai_tela.num_cota = di_tela[p_index].num_cota
         
      AFTER FIELD num_cota
      			
      			IF ((FGL_LASTKEY() = FGL_KEYVAL("ACCEPT"))OR(FGL_LASTKEY() = FGL_KEYVAL("INSERT"))) 
      					AND (di_tela[p_index].cota IS NULL) THEN 
      					
      			ELSE 
	            IF (di_tela[p_index].num_cota IS NULL) AND  (di_tela[p_index].cota IS NOT NULL) THEN
	               ERROR "Campo c/ Prenchimento Obrigatório !!!"
	               LET di_tela[p_index].num_cota = vai_tela.num_cota
	               NEXT FIELD num_cota
	            ELSE
				        	IF di_tela[p_index].num_cota IS NOT NULL THEN
				                SELECT den_cota
							        	  INTO di_tela[p_index].den_cota
							       	   	FROM cotas_1120
							     		  WHERE num_cota = di_tela[p_index].num_cota
				                IF STATUS = 0 THEN 
				                   DISPLAY di_tela[p_index].den_cota TO 
				                           s_itens[s_index].den_cota
				                  
				                  IF FGL_LASTKEY() = FGL_KEYVAL("ACCEPT") OR  
				                  	(FGL_LASTKEY() = FGL_KEYVAL("INSERT") AND di_tela[p_index].cota  IS NULL)
				                  	AND di_tela[p_index].num_cota IS NOT NULL THEN
				                  		NEXT FIELD cota
				                  END IF 
				               ELSE
				                  ERROR "Cota nao cadastra no Logix !!!"
				                  NEXT FIELD num_cota
				               END IF
	         					END IF
	        			END IF
	        		END IF 

			BEFORE FIELD cota	
				
				IF di_tela[p_index].num_cota IS NULL THEN 
					NEXT FIELD num_cota
				END IF 
			
				IF di_tela[p_index].cota IS NULL  THEN 
					LET di_tela[p_index].cota = ARR_COUNT()
					DISPLAY di_tela[p_index].cota TO s_itens[s_index].cota
					DISPLAY ARR_COUNT()  TO s_itens[s_index].cota
				END IF 
			  
			  LET p_cota_ant = di_tela[p_index].cota
				
			AFTER FIELD cota
			
				IF di_tela[p_index].num_cota IS NULL THEN 
					NEXT FIELD num_cota
				END IF 
				
				IF di_tela[p_index].cota IS NULL THEN
					ERROR "Campo c/ Prenchimento Obrigatório !!!"
					NEXT FIELD cota
				END IF
				
				LET p_repetiu = FALSE
				
        FOR p_ind = 1 TO ARR_COUNT()                                                                        
            IF p_ind <> p_index THEN                                                                            
               IF di_tela[p_ind].cota = di_tela[p_index].cota THEN  
                  LET p_repetiu = TRUE  
               END IF                                                                                           
            END IF     
            LET di_tela[p_ind].sequencia_cota = p_ind
            DISPLAY p_ind TO s_itens[p_ind].sequencia_cota                                                                                       
        END FOR                                                                                                
        
        IF p_repetiu THEN
           ERROR "Cota já informada! !!!"                                               
           NEXT FIELD cota   
        END IF
        
        IF p_cota_ant IS NULL OR p_cota_ant = ' ' THEN
        ELSE
           IF p_func = 'MUDAR' THEN
              IF p_cota_ant <> di_tela[p_index].cota THEN
                 IF di_tela[p_index].sequencia_cota IS NOT NULL THEN
                    UPDATE meio_temp_1120
                       SET cota = di_tela[p_index].cota 
                     WHERE sequencia_cota = di_tela[p_index].sequencia_cota
                 END IF
              END IF
           END IF
        END IF
                                    
           
				IF FGL_LASTKEY() = FGL_KEYVAL("ACCEPT") OR FGL_LASTKEY() = FGL_KEYVAL("INSERT") OR 
							FGL_LASTKEY() = FGL_KEYVAL("DOWN") THEN 
						NEXT FIELD cod_unid_med
				END IF
				
			
			BEFORE FIELD cod_unid_med
			
				IF di_tela[p_index].num_cota IS NULL THEN 
					NEXT FIELD num_cota
				END IF 
        LET vai_tela.cod_unid_med = di_tela[p_index].cod_unid_med
         
      AFTER FIELD cod_unid_med
      
         IF di_tela[p_index].cod_unid_med IS NULL THEN
            ERROR "Campo c/ Prenchimento Obrigatório !!!"
            LET di_tela[p_index].cod_unid_med = vai_tela.cod_unid_med
            NEXT FIELD cod_unid_med
         ELSE
         		SELECT cod_unid_med
           		FROM unid_med
           	 WHERE cod_unid_med = di_tela[p_index].cod_unid_med
	       
	          IF STATUS <> 0 THEN
	          	 ERROR "Unidade não cadastrada !!!"
	          	  NEXT FIELD cod_unid_med
	         	ELSE 
			       		IF FGL_LASTKEY() = FGL_KEYVAL("ACCEPT") OR FGL_LASTKEY() = FGL_KEYVAL("INSERT") OR FGL_LASTKEY() = FGL_KEYVAL("DOWN")THEN
			           	 NEXT FIELD val_nominal
			          END IF
	         	END IF
         END IF
         
      BEFORE FIELD val_nominal
      	
      	IF di_tela[p_index].num_cota IS NULL THEN 
					NEXT FIELD num_cota
				END IF 
      	
      	IF di_tela[p_index].val_nominal IS NULL THEN
           LET  di_tela[p_index].val_nominal = 0
        END IF
        
        LET vai_tela.val_nominal= di_tela[p_index].val_nominal
         
      AFTER FIELD val_nominal
        
            IF di_tela[p_index].val_nominal IS NULL THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               LET di_tela[p_index].val_nominal = vai_tela.val_nominal
               NEXT FIELD val_nominal
            ELSE
            		IF FGL_LASTKEY() = FGL_KEYVAL("ACCEPT")  OR FGL_LASTKEY() = FGL_KEYVAL("INSERT") OR FGL_LASTKEY() = FGL_KEYVAL("DOWN") THEN
                	NEXT FIELD variacao_menor
                END IF   
            END IF
     
     BEFORE FIELD variacao_menor
     		
     		IF di_tela[p_index].num_cota IS NULL THEN 
					NEXT FIELD num_cota
				END IF 
        
        IF di_tela[p_index].variacao_menor IS NULL THEN
          LET  di_tela[p_index].variacao_menor = 0
        END IF
        
        LET vai_tela.variacao_menor = di_tela[p_index].variacao_menor
         
      AFTER FIELD variacao_menor
        
            IF di_tela[p_index].variacao_menor IS NULL THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               LET di_tela[p_index].variacao_menor = vai_tela.variacao_menor
               NEXT FIELD variacao_menor
            ELSE
          		IF FGL_LASTKEY() = FGL_KEYVAL("ACCEPT")  OR FGL_LASTKEY() = FGL_KEYVAL("INSERT") OR FGL_LASTKEY() = FGL_KEYVAL("DOWN") THEN
              	NEXT FIELD variacao_maior
              END IF   
          	END IF
              
      BEFORE FIELD variacao_maior 
      	
      	IF di_tela[p_index].num_cota IS NULL THEN 
					NEXT FIELD num_cota
				END IF 
				IF  di_tela[p_index].variacao_maior IS NULL THEN 
					LET di_tela[p_index].variacao_maior =0 
				END IF
      
       LET vai_tela.variacao_maior = di_tela[p_index].variacao_maior
         
      AFTER FIELD variacao_maior
       	
       			IF  di_tela[p_index].variacao_maior IS NULL THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               LET di_tela[p_index].variacao_maior = vai_tela.variacao_maior
               NEXT FIELD variacao_maior
        	  ELSE
          		IF FGL_LASTKEY() = FGL_KEYVAL("ACCEPT")  OR FGL_LASTKEY() = FGL_KEYVAL("INSERT") OR FGL_LASTKEY() = FGL_KEYVAL("DOWN") THEN
              	NEXT FIELD imprime_ind
              END IF       
        		END IF  
       
     BEFORE FIELD imprime_ind
     		
     		IF di_tela[p_index].num_cota IS NULL THEN 
					NEXT FIELD num_cota
				END IF 
				
				IF p_ies_tip_item="C" OR p_ies_tip_item="B" THEN 
					LET di_tela[p_index].imprime_ind ='N'
					DISPLAY di_tela[p_index].imprime_ind TO s_itens[s_index].imprime_ind
					NEXT FIELD instrumento
				ELSE 
					LET vai_tela.imprime_ind = di_tela[p_index].imprime_ind
				END IF 
         
      AFTER FIELD imprime_ind
        
            IF di_tela[p_index].imprime_ind IS NULL THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               LET di_tela[p_index].imprime_ind = vai_tela.imprime_ind
               NEXT FIELD imprime_ind
            ELSE
          		IF di_tela[p_index].imprime_ind = 'S' OR di_tela[p_index].imprime_ind = 'N' THEN
          			
          		ELSE
          			ERROR "Somenteo so valores S para sim ou N para não!"
          			NEXT FIELD imprime_ind
          		END IF 
            END IF
   
      BEFORE FIELD instrumento
      	
      	IF di_tela[p_index].num_cota IS NULL THEN 
					NEXT FIELD num_cota
				END IF 
      
      AFTER FIELD instrumento

         SELECT COUNT(meio_inspecao)
		       INTO p_count
		       FROM meio_temp_1120
		      WHERE cota = di_tela[p_index].cota
								
					IF p_count > 0 THEN 
							LET di_tela[p_index].instrumento = '*'
							DISPLAY di_tela[p_index].instrumento  TO s_itens[s_index].instrumento
				 	ELSE 
				  		LET di_tela[p_index].instrumento = ''
				  		DISPLAY di_tela[p_index].instrumento  TO s_itens[s_index].instrumento
				  END IF  
           
      BEFORE FIELD pecas
      	
      		IF di_tela[p_index].num_cota IS NULL THEN 
						NEXT FIELD num_cota
					END IF 
					
      		IF  ((p_ies_tip_item = 'C' OR p_ies_tip_item = 'B')	AND di_tela[s_index].sequencia_cota > 1 )THEN 
      			NEXT FIELD frequencia
      		END IF
      		
      BEFORE FIELD frequencia
      		
      		IF di_tela[p_index].num_cota IS NULL THEN 
						NEXT FIELD num_cota
					END IF 
					
      		IF ((p_ies_tip_item = 'C' OR p_ies_tip_item = 'B')		AND di_tela[p_index].sequencia_cota > 1 )THEN 
      			NEXT FIELD texto
      		END IF 
    
    ON KEY (control-z)
       CALL pol0903popup()
       
   END INPUT 

   IF INT_FLAG = 0 THEN
      LET p_retorno = TRUE
   ELSE
 			INITIALIZE es_tela TO NULL
 			CLEAR FORM
      LET p_retorno = FALSE
      LET INT_FLAG = 0
   END IF   

   RETURN(p_retorno)

END FUNCTION

#-----------------------------#
FUNCTION pol0903_grava_itens()
#-----------------------------#
  
   DEFINE p_ind1 SMALLINT,
   				l_max  SMALLINT
   				
   DELETE FROM plan_inspecao_1120
    WHERE cod_empresa    = p_cod_empresa 
      AND cod_item       = es_tela.cod_item
    	AND cod_operac     = es_tela.cod_operac
    	AND num_seq_operac = es_tela.num_seq_operac
    	AND cod_roteiro    = es_tela.cod_roteiro
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','plan_inspecao_1120')
      RETURN FALSE
   END IF
   
   DELETE FROM meio_inspecao_1120
    WHERE cod_empresa    = p_cod_empresa 
      AND cod_item       = es_tela.cod_item
    	AND cod_operac     = es_tela.cod_operac
    	AND num_seq_operac = es_tela.num_seq_operac
    	AND cod_roteiro    = es_tela.cod_roteiro
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','meio_inspecao_1120')
      RETURN FALSE
   END IF
   
   DELETE FROM plan_temp_1120
   
   LET p_inseri.cod_empresa    = p_cod_empresa         
   LET p_inseri.cod_item       = es_tela.cod_item      
   LET p_inseri.cod_operac     = es_tela.cod_operac    
   LET p_inseri.num_seq_operac = es_tela.num_seq_operac
   LET p_inseri.cod_roteiro    = es_tela.cod_roteiro   
   
   FOR p_ind1 = 1 TO ARR_COUNT()
     		
       IF di_tela[p_ind1].num_cota IS NULL THEN
          CONTINUE FOR
       END IF

       INSERT INTO plan_temp_1120
          VALUES(di_tela[p_ind1].num_cota,            
								 di_tela[p_ind1].cota,       
								 di_tela[p_ind1].cod_unid_med,        
								 di_tela[p_ind1].val_nominal,          
								 di_tela[p_ind1].variacao_menor,       
								 di_tela[p_ind1].variacao_maior,      
								 di_tela[p_ind1].imprime_ind,
								 di_tela[p_ind1].pecas,
								 di_tela[p_ind1].frequencia,      
								 di_tela[p_ind1].texto )
       
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('DELETE','plan_temp_1120')
         RETURN FALSE
      END IF
   
   END FOR
   
   LET p_ind1 = 0      
	 
	 DECLARE cq_plan_tmp CURSOR FOR
	  SELECT *
	    FROM plan_temp_1120
	   ORDER BY cota 
   
   FOREACH cq_plan_tmp INTO
           p_inseri.num_cota,        
           p_inseri.cota,            
           p_inseri.cod_unid_med,    
           p_inseri.val_nominal,     
           p_inseri.variacao_menor,  
           p_inseri.variacao_maior,  
           p_inseri.imprime_ind,     
           p_inseri.qtd_pecas,           
           p_inseri.frequencia,      
           p_inseri.texto
           
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('FOREACH','cq_plan_tmp')
         RETURN FALSE
      END IF
   	  
   	  LET p_ind1 = p_ind1 + 1
      LET p_inseri.sequencia_cota = p_ind1
	 
      INSERT INTO plan_inspecao_1120
          VALUES(p_inseri.*)
       
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('INSERT','plan_inspecao_1120')
         RETURN FALSE
      END IF
      
      IF NOT pol0903_ins_meio() THEN
         RETURN FALSE
      END IF
         
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0903_ins_meio()#
#--------------------------#

   DECLARE cq_tmp CURSOR FOR
    SELECT meio_inspecao
      FROM meio_temp_1120
     WHERE cota = p_inseri.cota
   
   FOREACH cq_tmp INTO p_meio_inspecao

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('FOREACH','cq_tmp')
         RETURN FALSE
      END IF
      
      INSERT INTO meio_inspecao_1120
       VALUES(p_inseri.cod_empresa,
							p_inseri.cod_item,
							p_inseri.cod_operac,           
							p_inseri.num_seq_operac,       
							p_inseri.cod_roteiro,         
							p_inseri.num_cota,   
							p_inseri.sequencia_cota,
							p_meio_inspecao,
							p_inseri.cota)
							
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('INSERT','meio_inspecao_1120')
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
 FUNCTION pol0903_verifica_operacao()#		
#------------------------------------#

	INITIALIZE l_den_operac TO NULL 				
	
		IF p_ies_tip_item = 'B' OR p_ies_tip_item = 'C' THEN 
		 	 SELECT den_operac 
			   INTO l_den_operac
			   FROM operacao a 
			  WHERE a.cod_empresa = p_cod_empresa
			    AND a.cod_operac = es_tela.cod_operac 
			
			 LET es_tela.num_seq_operac = 1
			 LET es_tela.cod_roteiro = 0
		ELSE 
			SELECT den_operac 
			  INTO l_den_operac
			  FROM operacao a, man_processo_item b 
			 WHERE a.cod_empresa = b.empresa 
			   AND a.cod_operac  = b.operacao 
			   AND b.item    = es_tela.cod_item 
			   AND b.empresa = p_cod_empresa
			   AND a.cod_operac  = es_tela.cod_operac 
			   AND b.seq_operacao = es_tela.num_seq_operac
		END IF

	IF l_den_operac IS NOT NULL  THEN
		DISPLAY l_den_operac TO den_operac
		RETURN TRUE
	ELSE
		RETURN FALSE
	END IF
	
END FUNCTION   

#---------------------------#
FUNCTION pol0903_modificar()#
#---------------------------#
	
	LET p_retorno = FALSE
	
	IF pol0903_aceita_itens("MUDAR") THEN
     CALL log085_transacao("BEGIN")
		 IF NOT pol0903_grava_itens() THEN
		    CALL log085_transacao("ROLLBACK")
		    CALL pol0903_exibe_codigos()
		 ELSE
		    CALL log085_transacao("COMMIT")
		    LET p_retorno = TRUE
		 END IF
	ELSE
	  CALL pol0903_exibe_codigos()
	END IF
	
	RETURN(p_retorno)
	
END FUNCTION


#-------------------------------#
FUNCTION pol0903_compatibiliza()
#-------------------------------#
   
   LET p_msg = 'Resumo do processamento:\n'
   INITIALIZE p_del, p_upd TO NULL
   
   DECLARE cq_co CURSOR FOR
    SELECT DISTINCT
           cod_operac,
           num_seq_operac,
           cod_roteiro
      FROM plan_inspecao_1120
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = es_tela.cod_item
       AND cod_roteiro = es_tela.cod_roteiro

   FOREACH cq_co INTO 
      p_cod_operac, p_num_seq_operac, p_cod_roteiro
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','plan_inspecao_1120:cq_co')
         RETURN FALSE
      END IF
      
      SELECT DISTINCT seq_operacao
        INTO l_num_seq_operac
        FROM man_processo_item
       WHERE empresa = p_cod_empresa
         AND item    = es_tela.cod_item
         AND operacao  = p_cod_operac
         AND roteiro = p_cod_roteiro
      
      IF STATUS = 100 THEN
         IF NOT pol0903_del_oper() THEN
            RETURN FALSE
         END IF
      ELSE
         IF STATUS = 0 THEN
            IF l_num_seq_operac <> p_num_seq_operac THEN
               IF NOT pol0903_atu_seq() THEN
                  RETURN FALSE
               END IF
            END IF
         ELSE
            CALL log003_err_sql('Lendo','consumo:cq_co')
            RETURN FALSE 
         END IF
      END IF
      
   END FOREACH

   DECLARE cq_cm CURSOR FOR
    SELECT DISTINCT
           operacao
      FROM man_processo_item
     WHERE empresa = p_cod_empresa
       AND item    = es_tela.cod_item
       AND roteiro = es_tela.cod_roteiro

   FOREACH cq_cm INTO p_cod_operac
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','plan_inspecao_1120:cq_co')
         RETURN FALSE
      END IF

      SELECT DISTINCT
             cod_operac
        FROM plan_inspecao_1120
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = es_tela.cod_item
         AND cod_roteiro = es_tela.cod_roteiro
         AND cod_operac  = p_cod_operac
      
      IF STATUS = 100 THEN 
         IF p_ins IS NULL THEN
            LET p_ins = 'Oper Logix s/ cota no pol:'
         END IF
         LET p_ins = p_ins CLIPPED, ' ',p_cod_operac
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','plan_inspecao_1120:cq_cm')
            RETURN FALSE
         END IF
      END IF

   END FOREACH
   
   IF p_ins IS NULL AND p_del IS NULL AND p_upd IS NULL THEN
      LET p_msg = p_msg CLIPPED, 'Não há necessidade de acertos\n' 
   ELSE
      LET p_msg = p_msg CLIPPED, p_ins, '\n', p_upd, '\n', p_del, '\n'
   END IF
   
   CALL log0030_mensagem(p_msg,'excla')
   
   RETURN TRUE
      
END FUNCTION

#--------------------------#
FUNCTION pol0903_del_oper()
#--------------------------#
   
   IF p_del IS NULL THEN
      LET p_del = 'Operações excluidas:'
   END IF
   
   LET p_del = p_del CLIPPED, ' ',p_cod_operac
   
   DELETE FROM plan_inspecao_1120
     WHERE cod_empresa    = p_cod_empresa
       AND cod_item       = es_tela.cod_item
       AND cod_operac     = p_cod_operac
       AND num_seq_operac = p_num_seq_operac
       AND cod_roteiro    = p_cod_roteiro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('deletando','plan_inspecao_1120')
      RETURN FALSE
   END IF
   
   DELETE FROM meio_inspecao_1120
     WHERE cod_empresa    = p_cod_empresa
       AND cod_item       = es_tela.cod_item
       AND cod_operac     = p_cod_operac
       AND num_seq_operac = p_num_seq_operac
       AND cod_roteiro    = p_cod_roteiro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('deletando','meio_inspecao_1120')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol0903_atu_seq()
#-------------------------#

   IF p_upd IS NULL THEN
      LET p_upd = 'Oper c/ num_seq alterado:'
   END IF
   
   LET p_upd = p_upd CLIPPED, ' ',p_cod_operac
        
   UPDATE plan_inspecao_1120
      SET num_seq_operac = l_num_seq_operac
     WHERE cod_empresa    = p_cod_empresa
       AND cod_item       = es_tela.cod_item
       AND cod_operac     = p_cod_operac
       AND num_seq_operac = p_num_seq_operac
       AND cod_roteiro    = p_cod_roteiro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('atualizando','plan_inspecao_1120')
      RETURN FALSE
   END IF
   
   UPDATE meio_inspecao_1120
      SET num_seq_operac = l_num_seq_operac
     WHERE cod_empresa    = p_cod_empresa
       AND cod_item       = es_tela.cod_item
       AND cod_operac     = p_cod_operac
       AND num_seq_operac = p_num_seq_operac
       AND cod_roteiro    = p_cod_roteiro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('atualizando','meio_inspecao_1120')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION
        
#------------------------------#
FUNCTION pol0903_valdia_seq_op()
#------------------------------#

DEFINE l_cont	SMALLINT
		SELECT COUNT(*) 
		INTO l_cont 
		FROM operacao a, man_processo_item b 
		WHERE a.cod_empresa = b.empresa 
		AND   a.cod_operac = b.operacao 
		#AND 	b.roteiro = a.cod_roteiro
		AND   b.item=es_tela.cod_item 
		AND   b.empresa = p_cod_empresa
		AND   b.seq_operacao =es_tela.num_seq_operac
		AND 	b.operacao = es_tela.cod_operac
		AND 	b.roteiro = es_tela.cod_roteiro
 
	IF l_cont > 0 THEN
		RETURN TRUE
	ELSE 
		RETURN FALSE 
	END IF 
END FUNCTION

#----------------------------------#				#Essa função tem como objetivo controlar
FUNCTION pol0903_control_di_telaa()#				#a sequencia de cota tanto na plan_inspecao_1120
#----------------------------------#				#como na meio_inespecao_1120
DEFINE l_index SMALLINT
		
	UPDATE meio_inspecao_1120
	SET sequencia_cota = sequencia_cota - 1
	WHERE cod_empresa = p_cod_empresa												#Assim que deletar a cota o programa
		AND cod_item =es_tela.cod_item												#vai pegar o numero de sequencia
		AND cod_operac =es_tela.cod_operac										#subitrair um de toda as cotas que vierem
		AND num_seq_operac =es_tela.num_seq_operac						#apos ela no banco
		AND cod_roteiro =es_tela.cod_roteiro
		AND sequencia_cota > di_tela[p_index].sequencia_cota
	
	LET s_index = SCR_LINE()	
	 
	FOR l_index = 1 TO ARR_COUNT()
		IF di_tela[l_index].sequencia_cota IS NOT NULL THEN 
			IF (di_tela[p_index].sequencia_cota )< di_tela[l_index].sequencia_cota THEN				#Esse bloco e responsavel pela atualização da tabela
				LET di_tela[l_index].sequencia_cota = di_tela[l_index].sequencia_cota -1			#da tela e do array, se o usuario confirmar ele grava 
			END IF
		ELSE 
			EXIT  FOR  
		END IF 																																					
	END FOR 
END FUNCTION 

#-------------------------------#
FUNCTION pol0903_repetiu_cod()
#-------------------------------#
   DEFINE p_ind SMALLINT
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF di_tela[p_ind].num_cota = di_tela[p_index].num_cota THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
END FUNCTION

      
#-------------------------#
FUNCTION pol0903_informar() 
#-------------------------#
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CONSTRUCT BY NAME where_clause ON  plan_inspecao_1120.cod_item,
	                                    plan_inspecao_1120.cod_operac,
	                                    plan_inspecao_1120.num_seq_operac, 
	                                    plan_inspecao_1120.cod_roteiro
   ON KEY(control-z)
			CALL pol0903PEGA()
	END CONSTRUCT
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0903
   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
END FUNCTION
#------------------------#
FUNCTION pol0903_excluir()
#------------------------#
DEFINE l_delete		RECORD
				num_cota 				LIKE meio_inspecao_1120.num_cota,
				sequencia_cota	LIKE meio_inspecao_1120.sequencia_cota
	END RECORD 			
   LET p_retorno = FALSE
		INITIALIZE l_delete TO NULL 
   IF log004_confirm(18,35) THEN
      DECLARE cq_delete CURSOR FOR
      			SELECT num_cota, sequencia_cota
      			FROM meio_inspecao_1120
      			WHERE cod_empresa = p_cod_empresa 
			     	    AND cod_item = es_tela.cod_item
			     			AND cod_operac =  es_tela.cod_operac
			     			AND num_seq_operac = es_tela.num_seq_operac
			     			AND cod_roteiro = es_tela.cod_roteiro
			     			
			IF SQLCA.SQLCODE = 0 THEN 
					FOREACH cq_delete INTO l_delete.*
							DELETE FROM meio_inspecao_1120
								WHERE cod_empresa = p_cod_empresa
									AND cod_item = es_tela.cod_item
									AND cod_operac = es_tela.cod_operac
									AND num_seq_operac =es_tela.num_seq_operac
									AND cod_roteiro = es_tela.cod_roteiro
									AND num_cota = l_delete.num_cota
									AND sequencia_cota = l_delete.sequencia_cota
					END FOREACH
			END IF 
      DELETE FROM plan_inspecao_1120
     	WHERE cod_empresa = p_cod_empresa 
     	    AND cod_item = es_tela.cod_item
     			AND cod_operac =  es_tela.cod_operac
     			AND num_seq_operac = es_tela.num_seq_operac
     			AND cod_roteiro = es_tela.cod_roteiro
     			
      IF STATUS = 0 THEN 
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         INITIALIZE es_tela TO NULL
      ELSE
         CALL log003_err_sql("DELEÇÃO","plan_inspecao_1120")
      END IF
   END IF
   RETURN(p_retorno)
END FUNCTION
#--------------------------#
 FUNCTION pol0903_consulta()
#--------------------------#

   LET p_es_tela.* = es_tela.*
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
   CONSTRUCT BY NAME where_clause ON 
      plan_inspecao_1120.cod_item,
	    plan_inspecao_1120.cod_roteiro,
	    plan_inspecao_1120.cod_operac,
	    plan_inspecao_1120.num_seq_operac 
	    
	   ON KEY(control-z)
			  CALL pol0903PEGA()

   END CONSTRUCT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0903

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET es_tela.* = p_es_tela.*
      CALL pol0903_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF
   
   LET sql_stmt = "SELECT cod_item, cod_roteiro, cod_operac, num_seq_operac",
   								"  FROM plan_inspecao_1120 ",
                  " WHERE ", where_clause CLIPPED, 
                  "   AND cod_empresa = ", p_cod_empresa,                
                  " ORDER BY cod_item, cod_roteiro, num_seq_operac"

   PREPARE var_queri FROM sql_stmt   
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_queri
   OPEN cq_consulta
   
   FETCH cq_consulta INTO es_tela.*
   
   IF SQLCA.SQLCODE <> 0 THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0903_exibe_dados()
   END IF
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol0903_exibe_dados()
#-----------------------------------#
   
   DISPLAY p_cod_empresa TO cod_empresa
   DISPLAY es_tela.cod_item TO cod_item
   DISPLAY es_tela.cod_roteiro TO cod_roteiro
   DISPLAY es_tela.cod_operac TO cod_operac
   DISPLAY es_tela.num_seq_operac TO num_seq_operac

   CALL pol0903_verifica_item() RETURNING p_status
   CALL pol0903_le_roteiro(es_tela.cod_roteiro)
   DISPLAY p_den_roteiro TO den_roteiro
   CALL pol0903_verifica_operacao() RETURNING p_status

   CALL pol0903_exibe_codigos()

END FUNCTION

 #-------------------------------#
 FUNCTION pol0903_exibe_codigos()
#-------------------------------#
   
   DELETE FROM plan_temp_1120
   DELETE FROM meio_temp_1120

   LET p_inseri.cod_empresa    = p_cod_empresa            
	 LET p_inseri.cod_item       = es_tela.cod_item         
	 LET p_inseri.cod_operac     = es_tela.cod_operac           
	 LET p_inseri.num_seq_operac = es_tela.num_seq_operac
	 LET p_inseri.cod_roteiro    = es_tela.cod_roteiro         
							
   DECLARE cq_codigo CURSOR FOR 
    SELECT num_cota, sequencia_cota, cota, cod_unid_med, val_nominal,
    			 variacao_maior, variacao_menor, imprime_ind, qtd_pecas,frequencia,texto
      FROM plan_inspecao_1120
     WHERE cod_empresa = p_cod_empresa
			 AND cod_item    = es_tela.cod_item
			 AND cod_operac  = es_tela.cod_operac
			 AND num_seq_operac = es_tela.num_seq_operac
			 AND cod_roteiro = es_tela.cod_roteiro
     ORDER BY cota
   
   LET p_index = 1
   
   FOREACH cq_codigo INTO 
	    di_tela[p_index].num_cota,       							
	   	di_tela[p_index].sequencia_cota, 										
	   	di_tela[p_index].cota,           										
	   	di_tela[p_index].cod_unid_med,   										
	   	di_tela[p_index].val_nominal,    										
	   	di_tela[p_index].variacao_maior, 										
	   	di_tela[p_index].variacao_menor, 										
	   	di_tela[p_index].imprime_ind,    										
	   	di_tela[p_index].pecas,          										
	   	di_tela[p_index].frequencia,     										
      di_tela[p_index].texto   
              
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_codigo')
         RETURN FALSE
      END IF

      INSERT INTO plan_temp_1120
       VALUES(di_tela[p_index].num_cota,
              di_tela[p_index].cota,
              di_tela[p_index].cod_unid_med,
 							di_tela[p_index].val_nominal,
	   					di_tela[p_index].variacao_menor,
	   					di_tela[p_index].variacao_maior,
	   					di_tela[p_index].imprime_ind,
	   					di_tela[p_index].pecas,
	   					di_tela[p_index].frequencia,
	   					di_tela[p_index].texto)
              
   	SELECT den_cota
	   	INTO di_tela[p_index].den_cota
	    FROM cotas_1120
     WHERE num_cota = di_tela[p_index].num_cota

	  LET di_tela[p_index].instrumento = ''

    DECLARE cq_mi CURSOR FOR
	   SELECT meio_inspecao
			 FROM meio_inspecao_1120
  	  WHERE cod_empresa = p_cod_empresa
			  AND cod_item = es_tela.cod_item
			  AND cod_operac = es_tela.cod_operac
			  AND num_seq_operac = es_tela.num_seq_operac
			  AND cod_roteiro = es_tela.cod_roteiro
			  AND num_cota = di_tela[p_index].num_cota
			  AND cota = di_tela[p_index].cota
    
    FOREACH cq_mi INTO p_meio_inspecao

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_mi')
         RETURN FALSE
      END IF

      INSERT INTO meio_temp_1120
       VALUES(di_tela[p_index].sequencia_cota,
              di_tela[p_index].cota,
              p_meio_inspecao)
							
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('INSERT','meio_temp_1120')
         RETURN FALSE
      END IF
    								
			 LET di_tela[p_index].instrumento = '*'
   
    END FOREACH

    LET p_index = p_index + 1
   
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
		
   IF p_index > 50 THEN 
		  LET p_ies_cons = TRUE 
		  DISPLAY ARRAY di_tela TO s_itens.*
		  LET p_index = ARR_CURR()
		  LET s_index = SCR_LINE()
   ELSE
   	  INPUT ARRAY di_tela WITHOUT DEFAULTS FROM s_itens.*
      BEFORE INPUT
         EXIT INPUT
   	  END INPUT
   END IF
   
   RETURN TRUE
   
END FUNCTION 


#-----------------------------------#
 FUNCTION pol0903_paginacao(p_funcao)
#-----------------------------------#
   DEFINE p_funcao CHAR(20)
   
   IF p_ies_cons THEN
      LET p_es_tela.* = es_tela.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_consulta INTO 
                            es_tela.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_consulta INTO 
                            es_tela.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET es_tela.* = p_es_tela.* 
            EXIT WHILE
         END IF

         IF es_tela.cod_item = p_es_tela.cod_item 
         AND es_tela.cod_operac = p_es_tela.cod_operac 
         AND es_tela.num_seq_operac = p_es_tela.num_seq_operac
         AND es_tela.cod_roteiro = p_es_tela.cod_roteiro THEN
            CONTINUE WHILE
         END IF 
         
         SELECT COUNT(*)
           INTO p_count
           FROM plan_inspecao_1120
          WHERE cod_empresa = p_cod_empresa
          	AND cod_item = es_tela.cod_item
          	AND cod_operac =  es_tela.cod_operac
          	AND num_seq_operac = es_tela.num_seq_operac
     
         IF p_count > 0 THEN  
            CALL pol0903_exibe_dados()
            EXIT WHILE
         END IF

      END WHILE

   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-------------------------------------------------#
 FUNCTION pol0903_pega_operac(par_cod_item,p_tipo)#
#-------------------------------------------------#
DEFINE 	par_cod_item LIKE item.cod_item,
				p_tipo		SMALLINT,
				p_index SMALLINT,
				s_index SMALLINT
	 ## s_operac_popup		----------------------- tela#
	INITIALIZE p_nom_tela TO NULL
	CALL log130_procura_caminho("pol09032") RETURNING p_nom_tela
	LET p_nom_tela = p_nom_tela CLIPPED
	OPEN WINDOW w_pol09032 AT 7,6 WITH FORM p_nom_tela
	  ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
  IF p_tipo  THEN  
		LET sql_stmt = 	"SELECT a.cod_operac, b.seq_operacao,a.den_operac",
										" FROM operacao a, man_processo_item b",
										" WHERE a.cod_empresa=b.empresa",
										" AND   a.cod_operac=b.operacao",
										" AND   b.item='",par_cod_item,"'",
										" AND   b.roteiro='",es_tela.cod_roteiro,"'",
										" AND   b.empresa='",p_cod_empresa,"'",
										" ORDER BY b.seq_operacao"
	ELSE 
		LET sql_stmt=	"SELECT UNIQUE pi.cod_operac,pi.num_seq_operac,o.den_operac",
									" FROM plan_inspecao_1120 pi",
									" LEFT OUTER join operacao o",
									" ON pi.cod_empresa = o.cod_empresa",
									" AND pi.cod_operac=o.cod_operac",
									" WHERE pi.cod_empresa ='",p_cod_empresa,"'",
									" AND pi.cod_item='",par_cod_item,"'"
	END IF 
	PREPARE var_query_oper FROM sql_stmt							
	DECLARE cq_operac_popup CURSOR FOR var_query_oper
	LET p_index = 1
	FOREACH cq_operac_popup INTO p_operac[p_index].*
	  LET p_index = p_index + 1
	END FOREACH
	CALL SET_COUNT(p_index - 1)
	DISPLAY ARRAY p_operac TO s_operac_popup.*
	  LET p_index = ARR_CURR()
	  LET s_index = SCR_LINE() 
	CLOSE WINDOW w_pol09032
	IF p_tipo THEN 
		IF INT_FLAG = 0 THEN
		  RETURN p_operac[p_index].cod_operac, p_operac[p_index].num_seq_operac, p_operac[p_index].den_operac
		ELSE
		  LET INT_FLAG = 0
		  RETURN '','',''
		END IF
	ELSE
		IF INT_FLAG = 0 THEN
		  RETURN p_operac[p_index].cod_operac
		ELSE
		  LET INT_FLAG = 0
		  RETURN ''
		END IF 
	END IF 
END FUNCTION
#-----------------------#
FUNCTION pol0903PEGA()
#-----------------------#
DEFINE 	p_codigo  CHAR(15),
 				p_index 	SMALLINT,
 				s_index 	SMALLINT
	CASE
		WHEN INFIELD(cod_item)
			LET p_codigo = min071_popup_item(p_cod_empresa)
			CALL log006_exibe_teclas("01 02 03 07", p_versao)
			CURRENT WINDOW IS w_pol0903
			IF p_codigo IS NOT NULL THEN
				LET es_tela.cod_item = p_codigo
			DISPLAY p_codigo TO cod_item
			END IF
		WHEN INFIELD(cod_roteiro)
			CALL log009_popup(8,10,"ROTEIROS","roteiro",
			     "cod_roteiro","den_roteiro","","S","") 
			RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0903
			IF p_codigo IS NOT NULL THEN
				LET es_tela.cod_roteiro = p_codigo CLIPPED
				DISPLAY p_codigo TO cod_roteiro
			END IF 
		WHEN INFIELD(cod_operac)
			IF pol0903_verifica_item() THEN #parabuscar o ies_tip_item
			END IF 
			IF p_ies_tip_item = 'C' OR p_ies_tip_item = 'B'  THEN 
				CALL pol0903_pega_operac(es_tela.cod_item,FALSE) RETURNING p_codigo
				CALL log006_exibe_teclas("01 02 03 07", p_versao)
				CURRENT WINDOW IS w_pol0903
				IF p_codigo IS NOT NULL THEN
						LET es_tela.cod_operac = p_codigo CLIPPED
						DISPLAY p_codigo TO cod_operac
					END IF 
			ELSE  
				CALL log009_popup(8,10,"CODIGO OPERAÇÕES","operacao",
				"cod_operac","den_operac","","S","") 
				RETURNING p_codigo
				CALL log006_exibe_teclas("01 02 07", p_versao)
				CURRENT WINDOW IS w_pol0903
				IF p_codigo IS NOT NULL THEN
					LET p_es_tela.cod_operac = p_codigo CLIPPED
					DISPLAY p_codigo TO cod_operac
				END IF
			END IF 
			  
		WHEN INFIELD(num_cota)
			CALL log009_popup(8,10,"CODIGO COTA INSPEÇÃO","cotas_1120",
			"num_cota","den_cota","pol0902","S","") 
			RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0903
			IF p_codigo IS NOT NULL THEN
				LET di_tela[p_index].num_cota = p_codigo CLIPPED
				DISPLAY p_codigo TO s_itens[s_index].num_cota
			END IF 
		WHEN INFIELD(cod_unid_med)
			CALL log009_popup(8,10,"CODIGO UNIDADE DE MEDIDA","unid_med",
			"cod_unid_med","den_unid_med_30","man1170","N","") 
			RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0903
			IF p_codigo IS NOT NULL THEN
				LET di_tela[p_index].cod_unid_med = p_codigo CLIPPED
				DISPLAY p_codigo TO s_itens[s_index].cod_unid_med
			END IF 
	END CASE
END FUNCTION

#-----------------------#
FUNCTION pol0903popup() #
#-----------------------#

   DEFINE p_codigo  CHAR(15),
          p_codigo2 CHAR(15),
          p_den     LIKE operacao.den_operac,
          p_roteiro	LIKE consumo.cod_roteiro,
          par				SMALLINT
   CASE
			WHEN INFIELD(cod_item)
				LET p_codigo = min071_popup_item(p_cod_empresa)
				CALL log006_exibe_teclas("01 02 03 07", p_versao)
				CURRENT WINDOW IS w_pol0903
				IF p_codigo IS NOT NULL THEN
					LET es_tela.cod_item = p_codigo
					DISPLAY p_codigo TO cod_item
				END IF
			WHEN INFIELD(cod_roteiro)
         LET p_codigo = pol0903_roteiro()
         CLOSE WINDOW w_pol09034

         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0903
         
         IF p_codigo IS NOT NULL THEN
           LET es_tela.cod_roteiro = p_codigo
           DISPLAY p_codigo TO cod_roteiro
         END IF

			WHEN INFIELD(cod_operac)
				LET par = 0
				SELECT COUNT(*)
				INTO par
				FROM operacao a, b.seq_operacao b
				WHERE a.cod_empresa=b.empresa
				AND   a.cod_operac =b.operacao
				AND   b.item= es_tela.cod_item
				AND   b.empresa=p_cod_empresa
				IF par = 0 OR  (p_ies_tip_item = "B" OR p_ies_tip_item = "C")THEN 
					CALL log009_popup(8,10,"CODIGO OPERAÇÕES","operacao",
					  "cod_operac","den_operac","","S","") 
					RETURNING p_codigo
					CALL log006_exibe_teclas("01 02 07", p_versao)
					CURRENT WINDOW IS w_pol0903
					IF p_codigo IS NOT NULL THEN
						LET es_tela.cod_operac = p_codigo CLIPPED
						DISPLAY p_codigo TO cod_operac
					END IF 
				ELSE
					CALL pol0903_pega_operac(es_tela.cod_item,TRUE) RETURNING p_codigo, p_codigo2, p_den
					CALL log006_exibe_teclas("01 02 03 07", p_versao)
					CURRENT WINDOW IS w_pol0903
					IF p_codigo IS NOT NULL THEN
						LET es_tela.cod_operac = p_codigo CLIPPED
						LET es_tela.num_seq_operac = p_codigo2 CLIPPED
						DISPLAY p_codigo TO cod_operac
						DISPLAY p_den TO	den_operac
						DISPLAY p_codigo2 TO num_seq_operac
					  #---------buscar codigo Roteiro----------#
					  SELECT 	roteiro
					  INTO		p_roteiro
					  FROM		man_processo_item
					  WHERE		empresa = p_cod_empresa
					  	AND 	item = es_tela.cod_item
					  	AND		operacao = p_codigo
					  	AND		seq_operacao = p_codigo2
					  	
						LET es_tela.cod_roteiro = p_roteiro
						DISPLAY p_roteiro to cod_roteiro	
						#-----------------------------------------#	
				 	END IF 
				END IF 
			WHEN INFIELD(num_cota)
				 CALL log009_popup(8,10,"CODIGO COTA INSPEÇÃO","cotas_1120",
				      "num_cota","den_cota","pol0902","S","") 
				      RETURNING p_codigo
				  
				  IF p_codigo IS NOT NULL THEN
				  		LET di_tela[p_index].num_cota = p_codigo CLIPPED
				 END IF 
				 CALL log006_exibe_teclas("01 02 07", p_versao)
				 CURRENT WINDOW IS w_pol0903
				 DISPLAY p_codigo TO s_itens[s_index].num_cota
				 
			 WHEN INFIELD(cod_unid_med)
				 CALL log009_popup(8,10,"CODIGO UNIDADE DE MEDIDA","unid_med",
				      "cod_unid_med","den_unid_med_30","man1170","N","") 
				      RETURNING p_codigo
				 CALL log006_exibe_teclas("01 02 07", p_versao)
				 CURRENT WINDOW IS w_pol0903
				 IF p_codigo IS NOT NULL THEN
				   LET di_tela[p_index].cod_unid_med = p_codigo CLIPPED
				   DISPLAY p_codigo TO s_itens[s_index].cod_unid_med
				 END IF 
			 
			 WHEN INFIELD(instrumento)
				 CALL pol0903_instrumento()
				 
				 CLOSE WINDOW w_pol09033
				 CALL log006_exibe_teclas("01 02 07", p_versao)
				 CURRENT WINDOW IS w_pol0903
				
			 WHEN INFIELD(meio_inspecao)
				 CALL log009_popup(8,10,"CODIGO  DE INSTRUMENTOS","avf_meio_inspecao",
				      "meio_inspecao","des_meio_inspecao","avf0035","S","") 
				      RETURNING p_codigo
				 CALL log006_exibe_teclas("01 02 07", p_versao)
				 CURRENT WINDOW IS w_pol09033
				 IF p_codigo IS NOT NULL THEN
				   LET p_inst[p_index3].meio_inspecao = p_codigo CLIPPED
				   DISPLAY p_codigo TO s_inst[s_index3].meio_inspecao 
				 END IF 
   END CASE
END FUNCTION 

#------------------------#
FUNCTION pol0903_roteiro()
#------------------------#

   DEFINE pr_roteiro  ARRAY[10] OF RECORD
          cod_roteiro  LIKE roteiro.cod_roteiro
   END RECORD
   
   DEFINE p_ind, s_ind SMALLINT
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol09034") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol09034 AT 8,18 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1

   DECLARE cq_rot CURSOR FOR
    SELECT DISTINCT roteiro
      FROM man_processo_item
     WHERE empresa = p_cod_empresa
       AND item    = es_tela.cod_item
   
   FOREACH cq_rot INTO pr_roteiro[p_ind].cod_roteiro
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','consumo:cq_rot')
         RETURN ''
      END IF
      LET p_ind = p_ind + 1
      IF p_ind > 10 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassou','excla')
         EXIT FOREACH
      END IF
   END FOREACH
   
   IF p_ind = 1 THEN
      CALL log0030_mensagem('Não há roteiros cadastrados para o item informado','excla')
      RETURN ''
   END IF  
  
   CALL SET_COUNT(p_ind)
   
   DISPLAY ARRAY pr_roteiro TO sr_roteiro.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   
   IF NOT INT_FLAG THEN
      RETURN pr_roteiro[p_ind].cod_roteiro
   ELSE
      RETURN ""
   END IF
   
END FUNCTION


#-----------------------------#
FUNCTION pol0903_instrumento()#
#-----------------------------#

	INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol09033") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol09033 AT 2,2  WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
      
      INITIALIZE p_meio_insp	TO  NULL 
      DISPLAY p_cod_empresa TO cod_empresa1
      DISPLAY es_tela.cod_item TO cod_item 
      DISPLAY es_tela.cod_operac TO cod_operac
      DISPLAY es_tela.num_seq_operac TO num_seq_operac
      DISPLAY es_tela.cod_roteiro TO cod_roteiro
      DISPLAY di_tela[p_index].num_cota TO num_cota
      DISPLAY di_tela[p_index].cota TO cota
      
      IF pol0903_aceita_inst() THEN
      	CALL pol0903_grava_inst() RETURNING p_houve_erro
      ELSE 
     		CALL pol0903_exibe_inst()
      END IF 
      
      INITIALIZE p_meio_insp	TO  NULL 
       
END FUNCTION

#-------------------------------------#
# Programação do tela de Instrumentos #
#-------------------------------------#

#-------------------------------#
 FUNCTION pol0903_exibe_inst()	#
#-------------------------------#
	
	IF p_meio_insp.cod_item IS NULL THEN 
		LET p_meio_insp.cod_item 				= es_tela.cod_item 
		LET p_meio_insp.cod_operac			=	es_tela.cod_operac
		LET p_meio_insp.num_seq_operac	=	es_tela.num_seq_operac
		LET p_meio_insp.cod_roteiro			= es_tela.cod_roteiro
		LET p_meio_insp.num_cota 				=	di_tela[p_index].num_cota
		LET p_meio_insp.sequencia_cota	=	di_tela[p_index].sequencia_cota
		LET p_meio_insp.cota	          =	di_tela[p_index].cota
	END IF 
  
  DISPLAY BY NAME p_meio_insp.*
  
	DECLARE cq_exi_ins  CURSOR  FOR 		
									SELECT meio_inspecao 
									 FROM meio_inspecao_1120 
									 WHERE cod_empresa = p_cod_empresa
									 AND cod_item = p_meio_insp.cod_item 
									 AND cod_operac = p_meio_insp.cod_operac
									 AND num_seq_operac = p_meio_insp.num_seq_operac
									 AND cod_roteiro = p_meio_insp.cod_roteiro
									 AND num_cota = p_meio_insp.num_cota
									 AND sequencia_cota = p_meio_insp.sequencia_cota
									 ORDER BY meio_inspecao
   LET p_index3 = 1
   
   FOREACH cq_exi_ins INTO p_inst[p_index3].meio_inspecao
      SELECT des_meio_inspecao
      INTO p_inst[p_index3].des_meio_inspecao
			FROM avf_meio_inspecao
			WHERE  meio_inspecao=p_inst[p_index3].meio_inspecao
      LET p_index3 = p_index3 + 1
   END FOREACH
   
   CALL SET_COUNT(p_index3 - 1)
		IF p_index3 > 100 THEN 
		      LET p_ies_cons1 = TRUE 
		      DISPLAY ARRAY p_inst TO s_itens.*
		         LET p_index3 = ARR_CURR()
		         LET s_index3 = SCR_LINE()
   ELSE
   
   INPUT ARRAY p_inst WITHOUT DEFAULTS FROM s_inst.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
     END IF
     
END FUNCTION 

#-----------------------------#
FUNCTION pol0903_grava_inst()
#-----------------------------#

   DEFINE p_ind 					SMALLINT, 
 		      p_houve_erro1 	SMALLINT
   
   DELETE FROM meio_temp_1120
    WHERE cota = di_tela[p_index].cota
    
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_inst[p_ind].meio_inspecao IS NULL THEN
          CONTINUE FOR
       END IF
   
       INSERT INTO meio_temp_1120
          VALUES(di_tela[p_index].sequencia_cota,
                 di_tela[p_index].cota,
                 p_inst[p_ind].meio_inspecao)
											
       IF sqlca.SQLCODE <> 0 THEN 
          LET p_houve_erro1 = TRUE
          CALL log003_err_sql("INSERT","meio_temp_1120")
          EXIT FOR
       END IF
      
   END FOR
   
   IF NOT p_houve_erro1 THEN
      RETURN TRUE 
   ELSE
      RETURN FALSE
   END IF      

END FUNCTION

#---------------------------#
FUNCTION pol0903_modi_inst()
#---------------------------#

   DEFINE p_ind 					SMALLINT, 
 		      p_houve_erro1 	SMALLINT

   DELETE FROM meio_inspecao_1120
    WHERE cod_empresa    = p_cod_empresa 
      AND cod_item       = p_meio_insp.cod_item
    	AND cod_operac     = p_meio_insp.cod_operac
    	AND num_seq_operac = p_meio_insp.num_seq_operac
    	AND cod_roteiro    = p_meio_insp.cod_roteiro
    	AND sequencia_cota = p_meio_insp.sequencia_cota
    	AND cota           = p_meio_insp.cota 
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_inst[p_ind].meio_inspecao IS NULL THEN
          CONTINUE FOR
       END IF
   
       INSERT INTO meio_inspecao_1120
          VALUES(p_cod_empresa,                  
                 p_meio_insp.cod_item,       
                 p_meio_insp.cod_operac,     
                 p_meio_insp.num_seq_operac, 
                 p_meio_insp.cod_roteiro,    
                 p_meio_insp.num_cota,
                 p_meio_insp.sequencia_cota,
                 p_inst[p_ind].meio_inspecao,
                 p_meio_insp.cota)
											
       IF sqlca.SQLCODE <> 0 THEN 
          LET p_houve_erro1 = TRUE
          CALL log003_err_sql("INSERT","meio_temp_1120")
          EXIT FOR
       END IF
      
   END FOR
   
   IF NOT p_houve_erro1 THEN
      RETURN TRUE 
   ELSE
      RETURN FALSE
   END IF      

END FUNCTION

#-----------------------------#
FUNCTION pol0903_aceita_inst()
#-----------------------------#

   DEFINE p_func		CHAR(10)

	IF p_meio_insp.cod_item IS NULL THEN 
		LET p_meio_insp.cod_item 				= es_tela.cod_item 
		LET p_meio_insp.cod_operac			=	es_tela.cod_operac
		LET p_meio_insp.num_seq_operac	=	es_tela.num_seq_operac
		LET p_meio_insp.cod_roteiro			= es_tela.cod_roteiro
		LET p_meio_insp.num_cota 				=	di_tela[p_index].num_cota
		LET p_meio_insp.sequencia_cota	=	di_tela[p_index].sequencia_cota
		LET p_meio_insp.cota	          =	di_tela[p_index].cota
	END IF 	
	
	IF NOT p_mod_inst THEN
 	   INITIALIZE p_inst TO NULL
     LET p_index3 = 1

     DECLARE cq_inst CURSOR FOR 
 	    SELECT meio_inspecao  
		    FROM meio_temp_1120
   		 WHERE cota = di_tela[p_index].cota
		   ORDER BY meio_inspecao
   
     FOREACH cq_inst INTO p_inst[p_index3].meio_inspecao

		   INITIALIZE p_inst[p_index3].des_meio_inspecao TO NULL

   		 SELECT des_meio_inspecao
 		     INTO p_inst[p_index3].des_meio_inspecao
		     FROM avf_meio_inspecao
		    WHERE  meio_inspecao=p_inst[p_index3].meio_inspecao
	      
		   LET p_index3 = p_index3 + 1
	
		   IF p_index3 > 500 THEN
		      EXIT FOREACH
		   END IF
  
     END FOREACH
     
	END IF
	
	CALL SET_COUNT(p_index3 - 1) 
	
	INPUT ARRAY p_inst WITHOUT DEFAULTS FROM s_inst.*

      BEFORE ROW
         LET p_index3 = ARR_CURR() 
         LET s_index3 = SCR_LINE()
  
      BEFORE FIELD meio_inspecao
         LET p_inst_b.meio_inspecao = p_inst[p_index3].meio_inspecao
  
      AFTER FIELD meio_inspecao
	
				IF p_inst[p_index3].meio_inspecao IS NOT NULL  THEN
	
					SELECT des_meio_inspecao
	 				  INTO p_inst[p_index3].des_meio_inspecao
					  FROM avf_meio_inspecao
					 WHERE meio_inspecao=p_inst[p_index3].meio_inspecao
					   AND empresa = p_cod_empresa
						
					IF STATUS = 0 THEN 
							DISPLAY p_inst[p_index3].des_meio_inspecao TO 
						 	        s_inst[s_index3].des_meio_inspecao
					ELSE
						  ERROR "Instrumento não cadastrado no Logix !!!"
						  NEXT FIELD meio_inspecao
					END IF

          FOR p_ind = 1 TO ARR_COUNT()                                                                        
            IF p_ind <> p_index3 THEN                                                                            
               IF p_inst[p_ind].meio_inspecao = p_inst[p_index3].meio_inspecao THEN    
                  ERROR "Instrumento já informado! !!!"                                               
                  NEXT FIELD meio_inspecao   
               END IF                                                                                           
            END IF                                                                                              
          END FOR                                                                                                
				
				END IF
				
      ON KEY (control-z)
         CALL pol0903popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
 			CLEAR FORM
      LET INT_FLAG = 0
      RETURN FALSE 
   END IF   

END FUNCTION


#--------------------------------#
 FUNCTION pol0903_controle_inst() 
#--------------------------------#
	
	CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol09033") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol09033 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   IF es_tela.cod_item IS NOT NULL THEN 
   		LET parametro = 'P' 
   		CALL pol0903_consulta_ins()
   END IF 
   MENU "OPCAO"
      COMMAND "Modificar" "Modifica/Inclui dados na Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_meio_insp.cod_item IS NOT NULL THEN
	         IF p_ies_cons1 THEN
	         			CALL log085_transacao("BEGIN")
		            CALL pol0903_modificar_ins() RETURNING p_status
		            IF p_status THEN
		               MESSAGE "Modificação de Dados Efetuada c/ Sucesso !!!"
		                  ATTRIBUTE(REVERSE)
		               CALL log085_transacao("COMMIT")
		            ELSE
		            		CALL log085_transacao("ROLLBACK")
		               	MESSAGE "Operação Cancelada !!!"
		                  ATTRIBUTE(REVERSE)
		            END IF      
		       ELSE
		       	ERROR "Execute Previamente a Consulta !!!"
	         END IF
         ELSE
         	ERROR "Execute Previamente a Consulta !!!"
        END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0903_consulta_ins()
         IF p_ies_cons1 THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0903_pag("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0903_pag("ANTERIOR")
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol09033
END FUNCTION
#-------------------------------#
 FUNCTION pol0903_consulta_ins()
#-------------------------------#
   
   LET p_meio_insp1.* =  p_meio_insp.*
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa1
 
		IF parametro <>'P'   OR parametro IS NULL THEN 
		   CONSTRUCT BY NAME where_clause ON 	meio_inspecao_1120.cod_item,
			                                    meio_inspecao_1120.cod_operac,
			                                    meio_inspecao_1120.num_seq_operac, 
			                                    meio_inspecao_1120.cod_roteiro,
			                                    meio_inspecao_1120.num_cota,
			                                    meio_inspecao_1120.sequencia_cota,
			                                    meio_inspecao_1120.cota
		
		   CALL log006_exibe_teclas("01",p_versao)
		END IF 
   CURRENT WINDOW IS w_pol09033
   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_meio_insp.* =  p_meio_insp1.*
      CALL pol0903_exibe_inst()
      ERROR "Consulta Cancelada"
      RETURN
   END IF
	 IF parametro = 'P' THEN 
	 		LET sql_stmt = "SELECT unique cod_item,cod_operac,num_seq_operac,cod_roteiro, ", 
	 		               " num_cota, sequencia_cota, cota ",
		   								" FROM meio_inspecao_1120 ",
		                  " WHERE cod_item=","'",es_tela.cod_item,"'",
		                  " AND cod_operac =","'",es_tela.cod_operac,"'",
		                  " AND num_seq_operac =","'",es_tela.num_seq_operac,"'",
		                  " AND cod_roteiro =","'",es_tela.cod_roteiro,"'",
		                  " AND 	cod_empresa=",p_cod_empresa,                
		                  "ORDER BY 1,3,2"
	 ELSE 
	     LET sql_stmt = "SELECT unique cod_item,cod_operac,num_seq_operac,cod_roteiro, ", 
	                    "num_cota, sequencia_cota, cota ",
		   								" FROM meio_inspecao_1120 ",
		                  " WHERE ", where_clause CLIPPED, 
		                  "AND 	cod_empresa=",p_cod_empresa,                
		                  "ORDER BY 1,3,2"
   END IF 
   PREPARE var_queri2 FROM sql_stmt   
   DECLARE cq_cons_insp SCROLL CURSOR WITH HOLD FOR var_queri2
   OPEN cq_cons_insp
   
   FETCH cq_cons_insp INTO p_meio_insp.*
   
   IF SQLCA.SQLCODE <>0 THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons1 = FALSE
   ELSE 
      LET p_ies_cons1 = TRUE
      CALL pol0903_exibe_inst()
   END IF
   LET parametro = NULL 
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol0903_pag(p_funcao)
#-----------------------------------#
   DEFINE p_funcao CHAR(20)
   IF p_ies_cons1 THEN
     LET p_meio_insp1.* =  p_meio_insp.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_cons_insp INTO 
                            p_meio_insp.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_cons_insp INTO 
                            p_meio_insp.*
         END CASE
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_meio_insp.* = p_meio_insp1.* 
            EXIT WHILE
         END IF
         IF p_meio_insp.cod_item = p_meio_insp1.cod_item 
         AND p_meio_insp.cod_operac = p_meio_insp1.cod_operac 
         AND p_meio_insp.num_seq_operac = p_meio_insp1.num_seq_operac
         AND p_meio_insp.cod_roteiro = p_meio_insp1.cod_roteiro
         AND p_meio_insp.num_cota = p_meio_insp1.num_cota
         AND p_meio_insp.sequencia_cota = p_meio_insp1.sequencia_cota
          THEN
            CONTINUE WHILE
         END IF 
          SELECT COUNT(*)
           INTO p_count
           FROM plan_inspecao_1120
          WHERE cod_item = p_meio_insp.cod_item
          	AND cod_operac =  p_meio_insp.cod_operac
          	AND num_seq_operac = p_meio_insp.num_seq_operac
          	AND cod_roteiro = p_meio_insp.cod_roteiro
          	AND num_cota = p_meio_insp.num_cota
          	AND sequencia_cota=p_meio_insp.sequencia_cota
         IF p_count > 0 THEN  
            CALL pol0903_exibe_inst()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF
END FUNCTION

#------------------------------#
FUNCTION pol0903_modificar_ins()
#------------------------------#
  
  LET p_mod_inst = TRUE
  
	IF pol0903_aceita_inst() THEN
	  CALL pol0903_modi_inst() RETURNING p_retorno
	ELSE
	  CALL pol0903_exibe_inst()
	END IF
	RETURN(p_retorno)

END FUNCTION

#--------------------#
# Emitir o relatorio #
#--------------------#
#-----------------------------------#
 FUNCTION pol0903_emite_relatorio()
#-----------------------------------#
	INITIALIZE p_count TO NULL 
	SELECT den_empresa INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	LET sql_stmt1 = "SELECT UNIQUE cod_item,cod_operac,num_seq_operac,cod_roteiro,",
									"plan_inspecao_1120.num_cota, sequencia_cota, cotas_1120.den_cota,", 
	          			"cod_unid_med, val_nominal, variacao_menor," ,
	          			"variacao_maior, imprime_ind, texto",
	 								" FROM plan_inspecao_1120 , cotas_1120 ",
	                " WHERE ", where_clause CLIPPED, 
	                " AND plan_inspecao_1120.cod_empresa = cotas_1120.cod_empresa",
	                " AND plan_inspecao_1120.num_cota=cotas_1120.num_cota ",
	                "AND plan_inspecao_1120.cod_empresa = ",p_cod_empresa,                
	                "ORDER BY 1,2,3,4,5"
	PREPARE var_quer1 FROM sql_stmt1   
	DECLARE cq_padrao CURSOR FOR var_quer1
	IF SQLCA.SQLCODE = 0 THEN 
		FOREACH cq_padrao INTO p_es_tela.cod_item,		#---DETERMINANDO OS GRUPOS---
												p_es_tela.cod_operac,
												p_es_tela.num_seq_operac,
												p_es_tela.cod_roteiro,
												vai_tela.num_cota,
												vai_tela.sequencia_cota,
												vai_tela.den_cota,
												vai_tela.cod_unid_med,
												vai_tela.val_nominal,
												vai_tela.variacao_menor,
												vai_tela.variacao_maior,
												vai_tela.imprime_ind,
												vai_tela.texto
			SELECT den_item INTO p_den_item
			FROM item
			WHERE cod_item = p_es_tela.cod_item
			AND cod_empresa = p_cod_empresa
		 
		 	SELECT den_operac INTO p_den_opercac
		  FROM operacao
		 	WHERE cod_operac = p_es_tela.cod_operac
		 	AND cod_empresa = p_cod_empresa
		
			OUTPUT TO REPORT pol0903_relat(p_es_tela.cod_item, p_es_tela.cod_operac, p_es_tela.num_seq_operac, p_es_tela.cod_roteiro) 
			LET p_count = p_count + 1
		END FOREACH 
		RETURN TRUE 
	ELSE 
   RETURN FALSE 
	END IF 
END FUNCTION 
#----------------------------------#
 REPORT pol0903_relat(g_cod_item, g_cod_operac, g_num_seq_operac, g_cod_roteiro)
#----------------------------------#

   DEFINE 															#Registro responsavel pela separação dos 
   				g_cod_item       		LIKE plan_inspecao_1120.cod_item,   #grupos de itens nos quais serão separados
					g_cod_operac        LIKE plan_inspecao_1120.cod_operac,  
					g_num_seq_operac   	LIKE plan_inspecao_1120.num_seq_operac,    
					g_cod_roteiro       LIKE plan_inspecao_1120.cod_roteiro   
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  								#----------CABEÇALHO DO RELATORIO-------------

         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 044, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME,
               COLUMN 074, "PAG: ", PAGENO USING "#&"
         PRINT 
         PRINT COLUMN 001, "POL00903              RELATORIO DE PLANO DE INSPEÇÃO"
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT

      BEFORE GROUP OF g_cod_item 	#------------GRUPO----------
			
			
         PRINT
         PRINT COLUMN 010, "Item: ", p_es_tela.cod_item," - ", p_den_item
         PRINT COLUMN 010, "Operação: ", p_es_tela.cod_operac," - ", p_den_opercac
         PRINT COLUMN 010, "Numero de seuqncia operacional: ", p_es_tela.num_seq_operac
         PRINT COLUMN 010, "Roteiro: ", p_es_tela.cod_roteiro
         PRINT
         PRINT COLUMN 010, "N.COTA",
          			COLUMN 021, "         DESCRICAO",
          			COLUMN 054,"UN" ,
          			COLUMN 060,"NOMINAL",
          			COLUMN 070,"TOTAL+" ,
          			COLUMN 079,"TOTAL-"
         PRINT
         PRINT COLUMN 017, "--------" ,
          			COLUMN 021,"-----------------------------",
          			COLUMN 054,"---" ,
          			COLUMN 060,"-------" ,
          			COLUMN 070,"------" ,
          			COLUMN 079,"------"
         PRINT
      ON EVERY ROW			#---ITENS DO  GRUPO---
            PRINT COLUMN 011, vai_tela.num_cota USING "######",
            			COLUMN 022,vai_tela.den_cota CLIPPED,
            			COLUMN 054,vai_tela.cod_unid_med CLIPPED ,
            			COLUMN 057,vai_tela.val_nominal USING "##&.&&&&&" ,
            			COLUMN 066,vai_tela.variacao_maior USING "##&.&&&&&" ,
            			COLUMN 074,vai_tela.variacao_menor USING "##&.&&&&&" 
   					
   					PRINT COLUMN 022,'TEXTO: ',vai_tela.texto CLIPPED
   					
		        PRINT
         
END REPORT

#--------------------------------#
 FUNCTION pol0903_copia_operacao()
#--------------------------------#
    
   IF NOT pol0903_seleciona_item() THEN
      RETURN FALSE
   END IF  
     
   IF NOT log004_confirm(18,35) THEN
      RETURN FALSE
   END IF 
   
   LET p_ies_copia = FALSE
   
   CALL log085_transacao("BEGIN")
   
   FOR p_ind = 1 TO ARR_COUNT()
      
      IF pr_copia_operac[p_ind].cod_operac_copia IS NOT NULL THEN 
         IF pr_copia_operac[p_ind].ies_copia = "S" THEN 
            
            DECLARE cq_inseri CURSOR WITH HOLD FOR  
            
            SELECT *
              FROM plan_inspecao_1120
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = es_tela.cod_item
               AND cod_operac  = es_tela.cod_operac
               AND num_seq_operac = es_tela.num_seq_operac
             ORDER BY cod_operac, cota
                  
            FOREACH cq_inseri INTO p_inseri.*
               
               IF STATUS <> 0 THEN 
                  CALL log003_err_sql("Lendo", "Cursor: cq_inseri")
                  CALL log085_transacao("ROLLBACK")
                  RETURN FALSE
               END IF 
               
               LET p_inseri.cod_item       = p_tela_copia.cod_item
               LET p_inseri.cod_roteiro    = pr_copia_operac[p_ind].cod_roteiro_copia
               LET p_inseri.num_seq_operac = pr_copia_operac[p_ind].num_seq_operac_copia
               
               INSERT INTO plan_inspecao_1120
                   VALUES (p_inseri.*)
                           
               IF STATUS <> 0 THEN 
                  CALL log003_err_sql("Incluindo", "plan_inspecao_1120")
                  CALL log085_transacao("ROLLBACK")
		              RETURN FALSE   
		           END IF
               
               DECLARE cq_inseri_meio CURSOR FOR 
               
               SELECT *
                 FROM meio_inspecao_1120
                WHERE cod_empresa    = p_cod_empresa
                  AND cod_item       = es_tela.cod_item
                  AND cod_operac     = es_tela.cod_operac
                  AND num_seq_operac = es_tela.num_seq_operac
                  AND num_cota       = p_inseri.num_cota
                  AND sequencia_cota = p_inseri.sequencia_cota
                  
                  
               FOREACH cq_inseri_meio INTO p_inseri_meio.*
               
                  IF STATUS <> 0 THEN 
                     CALL log003_err_sql("Lendo", "Cursor: cq_inseri_meio")
                     CALL log085_transacao("ROLLBACK")
                     RETURN FALSE
                  END IF 
                  
                  LET p_inseri_meio.cod_item       = p_tela_copia.cod_item
                  LET p_inseri_meio.cod_roteiro    = pr_copia_operac[p_ind].cod_roteiro_copia
                  LET p_inseri_meio.num_seq_operac = pr_copia_operac[p_ind].num_seq_operac_copia
                  
                  INSERT INTO meio_inspecao_1120
		                  VALUES (p_inseri_meio.*)
		              
		              IF STATUS <> 0 THEN 
                     CALL log003_err_sql("Incluindo", "meio_inspecao_1120")
                     CALL log085_transacao("ROLLBACK")
		                 RETURN FALSE   
		              END IF

               END FOREACH
               
            END FOREACH
            
            LET p_ies_copia = TRUE 
            
         END IF 
      END IF 
          
   END FOR
   
   CALL log085_transacao("COMMIT")
   
   IF p_ies_copia = FALSE THEN 
      CALL log0030_mensagem("Não foi selecionado um destino válido para efetuar a cópia !!!", "exclamation")
      RETURN FALSE 
   END IF 
   
   RETURN TRUE  
 
END FUNCTION
      
#--------------------------------#
 FUNCTION pol0903_seleciona_item()
#--------------------------------#

   CALL log006_exibe_teclas("01",p_versao)
	 INITIALIZE p_nom_tela TO NULL
	 CALL log130_procura_caminho("pol09031") RETURNING p_nom_tela
	 LET  p_nom_tela = p_nom_tela CLIPPED 
	 OPEN WINDOW w_pol09031 AT 8,35 WITH FORM p_nom_tela 
	   ATTRIBUTE(BORDER, MESSAGE LINE LAST, FORM LINE FIRST)
	   
	 INPUT BY NAME p_tela_copia.* WITHOUT DEFAULTS
	 
	 AFTER FIELD cod_item 
	    IF p_tela_copia.cod_item IS NULL THEN 
	       CALL log0030_mensagem("Campo com prenchimento obrigatório !!!", "exclamation") 
	       NEXT FIELD cod_item
	    END IF 
	    
	    SELECT den_item_reduz 
	      INTO p_den_item_reduz
	      FROM item 
	     WHERE cod_empresa = p_cod_empresa
	       AND cod_item    = p_tela_copia.cod_item
	       
	    IF STATUS = 100 THEN 
	       CALL log0030_mensagem("Item inexistente !!!", "exclamation")
	       NEXT FIELD cod_item
	    ELSE
	       IF STATUS <> 0 THEN 
	          CALL log003_err_sql("Lendo", "Item")
	          RETURN FALSE
	       END IF 
	    END IF 
      
      DISPLAY p_den_item_reduz TO den_item_reduz
            
	    LET p_index = 1
	    	    
	    DECLARE cq_consumo CURSOR FOR
	    
	    SELECT roteiro,
	           operacao,
	           seq_operacao
	      FROM man_processo_item
	     WHERE empresa = p_cod_empresa
	       AND item    = p_tela_copia.cod_item
	       AND operacao  = es_tela.cod_operac
	     ORDER BY roteiro, operacao, seq_operacao
	       
	    FOREACH cq_consumo 
	       INTO pr_copia_operac[p_index].cod_roteiro_copia,
	            pr_copia_operac[p_index].cod_operac_copia,
	            pr_copia_operac[p_index].num_seq_operac_copia
	            
	       IF STATUS <> 0 THEN 
	          CALL log003_err_sql("Lendo", "Cursor: cq_consumo")
	          RETURN FALSE
	       END IF 

         SELECT DISTINCT cod_item 
           FROM plan_inspecao_1120
          WHERE cod_empresa = p_cod_empresa
	          AND cod_item    = p_tela_copia.cod_item
	          AND cod_roteiro = pr_copia_operac[p_index].cod_roteiro_copia
	          AND cod_operac  = pr_copia_operac[p_index].cod_operac_copia
	          AND num_seq_operac = pr_copia_operac[p_index].num_seq_operac_copia
	    
	       IF STATUS = 0 THEN 
	          CONTINUE FOREACH
	       ELSE
	          IF STATUS <> 100 THEN 
	             CALL log003_err_sql("Lendo", "plan_inspecao_1120:cq_consumo")
	             RETURN FALSE
	          END IF
	       END IF 
	    
	       LET pr_copia_operac[p_index].ies_copia = 'N'
	       
	       LET p_index = p_index + 1
	       
	    END FOREACH 
	    
	    IF p_index = 1 THEN 
	       LET p_msg = "Item destino não possui a operação ", es_tela.cod_operac, "\n",
	                   "ou a mesma já consta do plano de inspeção !!!"
	       CALL log0030_mensagem(p_msg, "exclamation")
	       NEXT FIELD cod_item
	    END IF 
      
      ON KEY (control-z)
         CALL pol0903_popup()
      
   END INPUT
   
   IF INT_FLAG THEN 
      LET INT_FLAG = FALSE 
      RETURN FALSE
   END IF 
   
   LET p_ind = p_index - 1
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_copia_operac
      WITHOUT DEFAULTS FROM sr_copia_operac.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()
           
      AFTER FIELD ies_copia

        { IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            ERROR "Não há mais sequências para essa operação !!!"
            NEXT FIELD ies_copia
         END IF   }      
         
   END INPUT 

   IF INT_FLAG = FALSE THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = FALSE
      RETURN FALSE
   END IF 
   
END FUNCTION 

#-----------------------#
 FUNCTION pol0903_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
     WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol09031
         IF p_codigo IS NOT NULL THEN
           LET p_tela_copia.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF
   END CASE 
   
END FUNCTION 

#-------------------------------- FIM DE PROGRAMA BI-----------------------------#
