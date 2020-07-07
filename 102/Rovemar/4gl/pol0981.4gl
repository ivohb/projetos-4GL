#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0981                                                 #
# OBJETIVO: CADASTRO DE PEÇAS POR CICLO E CIICLO POR PEÇAS          #
# AUTOR...: thiago							                                    #
# DATA....: 23/09/2008                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_erro_critico       SMALLINT,
          p_last_row           SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_6lpp               CHAR(02),
          p_8lpp               CHAR(02),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_msg                CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(256)
          
   DEFINE p_rovciclo_peca     RECORD LIKE rovciclo_peca.*,
          p_rovciclo_pecaa    RECORD LIKE rovciclo_peca.* 

   DEFINE p_den_item           LIKE item.den_item,
          p_cod_item           LIKE item.cod_item,
          p_cod_itema          LIKE item.cod_item
{
   DEFINE pr_item              ARRAY[10000] OF RECORD          
          cod_item             LIKE item.cod_item,
          den_item             LIKE item.den_item_reduz,
          qtd_ciclo_peca       LIKE rovciclo_peca.qtd_ciclo_peca,
          qtd_peca_ciclo       LIKE rovciclo_peca.qtd_peca_ciclo,
          num_seq							 LIKE rovciclo_peca.num_seq,
          num_sub_seq					 LIKE rovciclo_peca.num_sub_seq,
          qtd_peca_emb				 LIKE rovciclo_peca.qtd_peca_emb
   END RECORD
   }
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0981-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0981.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
    # CALL pol0981_carrega_da_consumo()
      CALL pol0981_controle()
   END IF
END MAIN


#--------------------------#
 FUNCTION pol0981_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0981") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0981 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         CALL pol0981_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         IF p_ies_cons THEN
            CALL pol0981_modificacao() RETURNING p_status
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         IF p_ies_cons THEN
            CALL pol0981_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         CALL pol0981_consulta()
         IF p_ies_cons THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         IF p_ies_cons THEN
            CALL pol0981_paginacao("S")
         ELSE
            ERROR "Nao Existe Nenhuma Consulta Ativa"
         END IF
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         IF p_ies_cons THEN
            CALL pol0981_paginacao("A")
         ELSE
            ERROR "Nao Existe Nenhuma Consulta Ativa"
         END IF
      COMMAND "Listar" "Listagem dos parâmetros"
         CALL pol0981_listagem()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0981

END FUNCTION


#--------------------------#
 FUNCTION pol0981_inclusao()
#--------------------------#
		
   INITIALIZE p_rovciclo_peca.* TO NULL
   CLEAR FORM
   LET p_rovciclo_peca.cod_empresa = p_cod_empresa

   IF pol0981_entrada_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO rovciclo_peca VALUES (p_rovciclo_peca.*)
      IF SQLCA.SQLCODE <> 0 THEN 
      	 CALL log003_err_sql("INCLUSAO","p_rovciclo_peca")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF

   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0981_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE

   INPUT BY NAME p_rovciclo_peca.* WITHOUT DEFAULTS
   
      BEFORE FIELD cod_item
      IF p_funcao = 'M' THEN
         NEXT FIELD qtd_ciclo_peca
      END IF
      
      AFTER FIELD cod_item
         IF p_rovciclo_peca.cod_item IS NULL THEN
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_item   
         ELSE
					         
	         CALL pol0981_le_item() RETURNING p_msg
	         
	         IF p_msg IS NOT NULL THEN
	            CALL log0030_mensagem(p_msg,'exclamation')
	            NEXT FIELD cod_item
	         ELSE
	         		DISPLAY p_den_item TO den_item
	         		NEXT FIELD cod_operac
	         END IF
	      
	     END IF
      AFTER FIELD cod_operac
      	IF p_rovciclo_peca.cod_operac IS NULL THEN
      		 ERROR "Campo com preenchimento obrigatório !!!"
      		 NEXT FIELD cod_operac
      	ELSE
      		IF p_rovciclo_peca.num_seq_operac IS NULL THEN
      			NEXT FIELD cod_operac
      			CALL pol0981_popup() 
      		ELSE 
      			IF pol0981_valida_oper() THEN
      				IF NOT pol0981_ver_duplicidade() THEN 
      					DISPLAY	p_rovciclo_peca.num_seq_operac TO num_seq_operac
      					NEXT FIELD qtd_ciclo_peca
      				ELSE
      					ERROR "Registro já cadastrada!!!"
      					NEXT FIELD cod_operac
      				END IF 
      			ELSE
      				ERROR "Operação não cadastrada na tabela consumo!!!"
      				NEXT FIELD cod_operac
      			END IF 
      		END IF 
      	END IF 
      	
      AFTER FIELD qtd_ciclo_peca
         IF p_rovciclo_peca.qtd_ciclo_peca IS NULL THEN
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD qtd_ciclo_peca   
         ELSE
         		NEXT FIELD qtd_peca_ciclo
         END IF
      
      AFTER FIELD qtd_peca_ciclo
         IF p_rovciclo_peca.qtd_peca_ciclo IS NULL THEN
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD qtd_peca_ciclo 
         END IF
      
      ON KEY (control-z)
         CALL pol0981_popup()

   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0981_valida_oper()#
#-----------------------------#
DEFINE l_cont  SMALLINT

	SELECT COUNT(cod_empresa)
	INTO l_cont
	FROM consumo 
	WHERE  cod_empresa =p_cod_empresa
	AND cod_item = p_rovciclo_peca.cod_item
	AND cod_operac = p_rovciclo_peca.cod_operac
	AND num_seq_operac = p_rovciclo_peca.num_seq_operac
	
	IF l_cont > 0 THEN 
		RETURN TRUE 
	ELSE
		RETURN FALSE
	END IF 
      			
END FUNCTION

#---------------------------------#
FUNCTION pol0981_ver_duplicidade()#
#---------------------------------#
DEFINE l_cont  SMALLINT

	SELECT COUNT(cod_empresa)
	INTO l_cont
	FROM rovciclo_peca 
	WHERE  cod_empresa =p_cod_empresa
	AND cod_item = p_rovciclo_peca.cod_item
	AND cod_operac = p_rovciclo_peca.cod_operac
	AND num_seq_operac = p_rovciclo_peca.num_seq_operac
	
	IF l_cont > 0 THEN 
		RETURN TRUE 
	ELSE
		RETURN FALSE
	END IF 
      			
END FUNCTION

#-------------------------#
FUNCTION pol0981_le_item()
#-------------------------#

   DEFINE p_erro CHAR(70)

   INITIALIZE p_den_item, p_erro TO NULL
   
   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_rovciclo_peca.cod_item

   IF STATUS = 100 THEN
      LET p_erro = 'Item não cadastrado'
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = 'Erro (',STATUS,') Lendo tabela item'
      END IF
   END IF

   RETURN(p_erro)
   
END FUNCTION

#------------------------------#
FUNCTION pol0981_le_ciclo_peca()
#------------------------------#

   SELECT *
     INTO p_rovciclo_peca.*
     FROM rovciclo_peca
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_rovciclo_peca.cod_item
			AND cod_operac	=	p_rovciclo_peca.cod_operac
			AND num_seq_operac = p_rovciclo_peca.num_seq_operac
END FUNCTION


#-----------------------#
FUNCTION pol0981_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0981
         IF p_codigo IS NOT NULL THEN
           LET p_rovciclo_peca.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF
         
        WHEN INFIELD(cod_operac)
   				CALL pol0981_ListOpercao() RETURNING p_rovciclo_peca.cod_operac,p_rovciclo_peca.num_seq_operac
   				DISPLAY p_rovciclo_peca.cod_operac TO cod_operac
   				DISPLAY p_rovciclo_peca.num_seq_operac TO num_seq_operac
   				CALL log006_exibe_teclas("01 02 03 07", p_versao)
       		CURRENT WINDOW IS w_pol0981
   END CASE

END FUNCTION 


#--------------------------#
 FUNCTION pol0981_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_itema = p_rovciclo_peca.cod_item
   
   CONSTRUCT BY NAME where_clause ON 
      rovciclo_peca.cod_item,
      rovciclo_peca.cod_operac,
      rovciclo_peca.qtd_ciclo_peca,
      rovciclo_peca.qtd_peca_ciclo
      

   IF INT_FLAG THEN
      IF p_ies_cons THEN
         LET p_rovciclo_peca.cod_item = p_cod_itema
         CALL pol0981_exibe_dados()
      END IF
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * ",
                  "  FROM rovciclo_peca ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_item, num_seq_operac"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_rovciclo_peca.*

   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0981_exibe_dados()
   END IF
   
   RETURN

END FUNCTION

#------------------------------#
 FUNCTION pol0981_exibe_dados()
#------------------------------#

   CALL pol0981_le_ciclo_peca()
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','tab:rovciclo_peca')
   END IF
   
   CALL pol0981_le_item() RETURNING p_msg
   
   IF p_msg IS NOT NULL THEN
      LET p_den_item = p_msg
   END IF
   
   DISPLAY BY NAME p_rovciclo_peca.*
   
   DISPLAY p_den_item TO den_item

END FUNCTION

#-----------------------------------#
 FUNCTION pol0981_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_itema = p_rovciclo_peca.cod_item

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_rovciclo_peca.*
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_rovciclo_peca.*
      END CASE

      IF SQLCA.SQLCODE = NOTFOUND THEN
         ERROR "Nao Existem Mais Itens Nesta Direção"
         LET p_rovciclo_peca.cod_item = p_cod_itema
         EXIT WHILE
      END IF

      CALL pol0981_le_ciclo_peca()
      
      IF STATUS = 0 THEN
         CALL pol0981_exibe_dados()
         EXIT WHILE
      END IF

   END WHILE

END FUNCTION

#-----------------------------------#
 FUNCTION pol0981_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
    SELECT  *
     INTO p_rovciclo_peca.*
     FROM rovciclo_peca
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_rovciclo_peca.cod_item
			AND cod_operac	=	p_rovciclo_peca.cod_operac
			AND num_seq_operac = p_rovciclo_peca.num_seq_operac
             FOR UPDATE 
   CALL log085_transacao("BEGIN")   
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","cotas_1120")
   END CASE
   CALL log085_transacao("ROLLBACK")
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#----------------------------------#
 FUNCTION pol0981_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")
   DECLARE cq_prende CURSOR WITH HOLD FOR
   SELECT cod_empresa 
     FROM rovciclo_peca  
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_rovciclo_peca.cod_item
      AND cod_operac	=	p_rovciclo_peca.cod_operac
			AND num_seq_operac = p_rovciclo_peca.num_seq_operac
      
      FOR UPDATE 
   
   OPEN cq_prende
   FETCH cq_prende
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","rovciclo_peca")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0981_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0981_cursor_for_update() THEN
      IF pol0981_entrada_dados("M") THEN
         UPDATE rovciclo_peca 
            SET qtd_ciclo_peca = p_rovciclo_peca.qtd_ciclo_peca,
                qtd_peca_ciclo = p_rovciclo_peca.qtd_peca_ciclo,
                cod_operac		 = rovciclo_peca.cod_operac,
                num_seq_operac = rovciclo_peca.num_seq_operac
          WHERE CURRENT OF cm_padrao

         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificando","rovciclo_peca")
         END IF
      ELSE
         CALL pol0981_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
 FUNCTION pol0981_exclusao()
#--------------------------#

   LET p_retorno = FALSE

   IF pol0981_prende_registro() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM rovciclo_peca
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_rovciclo_peca.cod_item
            AND cod_operac	=	p_rovciclo_peca.cod_operac
						AND num_seq_operac = p_rovciclo_peca.num_seq_operac

         IF STATUS = 0 THEN
            INITIALIZE p_rovciclo_peca TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Excluindo","rovciclo_peca")
         END IF
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION 

#-----------------------------#
FUNCTION pol0981_ListOpercao()#
#-----------------------------#
DEFINE l_index					SMALLINT
DEFINE p_oper ARRAY[100] OF  RECORD 	
				cod_operac			LIKE	consumo.cod_operac,
				num_seq_operac	LIKE  consumo.num_seq_operac,
				den_operac			LIKE	operacao.den_operac
END RECORD

		CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol09811") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol09811 AT 2,16 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   LET l_index = 1
   
   DECLARE cq_oper CURSOR FOR SELECT A.COD_OPERAC, A.NUM_SEQ_OPERAC, B.DEN_OPERAC
															FROM CONSUMO A, OPERACAO B
															WHERE A.COD_ITEM = p_rovciclo_peca.cod_item
															AND A.COD_EMPRESA = p_cod_empresa
															AND A.COD_OPERAC = B.COD_OPERAC
															AND A.COD_EMPRESA = B.COD_EMPRESA
															ORDER BY 2,1
	FOREACH cq_oper INTO p_oper[l_index].* 
		LET l_index = l_index + 1
	END FOREACH
   
   CALL SET_COUNT(l_index -1)
   
   	DISPLAY ARRAY p_oper TO s_oper.*
	  LET p_index = ARR_CURR()
	  LET s_index = SCR_LINE() 
   
   CLOSE WINDOW w_pol09811
   
   IF INT_FLAG = 0 THEN
		  RETURN p_oper[p_index].cod_operac, p_oper[p_index].num_seq_operac
		ELSE
		  LET INT_FLAG = 0
		  RETURN NULL,NULL
		END IF
   
END FUNCTION 


#--------------------------#
FUNCTION pol0981_listagem()
#--------------------------#

   CALL pol0981_escolhe_saida()

   IF NOT pol0981_le_empresa() THEN
      RETURN FALSE
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_imp CURSOR FOR
    SELECT cod_item,
    			 cod_operac,
    			 num_seq_operac,
           qtd_ciclo_peca,
           qtd_peca_ciclo
      FROM rovciclo_peca
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_item,num_seq_operac
   
   FOREACH cq_imp INTO 
           p_rovciclo_peca.cod_item,
           p_rovciclo_peca.cod_operac,
           p_rovciclo_peca.num_seq_operac,
           p_rovciclo_peca.qtd_ciclo_peca,
           p_rovciclo_peca.qtd_peca_ciclo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','rovciclo_peca:cq_imp')
         EXIT FOREACH
      END IF

      CALL pol0981_le_item() RETURNING p_msg
      
      IF p_msg IS NOT NULL THEN
         LET p_den_item = p_msg
      END IF
      
      OUTPUT TO REPORT pol0981_relat() 

      LET p_count = p_count + 1
      
   END FOREACH

   FINISH REPORT pol0981_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados para serem listados. "
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso!!!'
   END IF
  
END FUNCTION 

#-------------------------------#
FUNCTION pol0981_escolhe_saida()
#-------------------------------#
   
 INITIALIZE p_caminho TO NULL
  IF log028_saida_relat(18,35) IS NOT NULL THEN
		MESSAGE " Processando a Extracao do Relatorio..." ATTRIBUTE(REVERSE)
		IF p_ies_impressao = "S" THEN
			IF g_ies_ambiente = "U" THEN
				START REPORT pol0981_relat TO PIPE p_nom_arquivo
			ELSE
				CALL log150_procura_caminho ('LST') RETURNING p_caminho
				LET p_caminho = p_caminho CLIPPED, 'pol0981.tmp'
				START REPORT pol0981_relat  TO p_caminho
			END IF
		ELSE
			START REPORT pol0981_relat TO p_nom_arquivo
		END IF
	ELSE
		RETURN
	END IF         
   
END FUNCTION

#----------------------------#
FUNCTION pol0981_le_empresa()
#----------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------#
 REPORT pol0981_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 070, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol0981",
               COLUMN 017, "CICLOS POR PECA / PECA POR CICLO",
               COLUMN 052, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "---------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '   COD ITEM              DESCRICAO              CICLO/PC PC/CICLO   OP     SEQ'   
         PRINT COLUMN 001, '--------------- ------------------------------- -------- -------- ------- -----'
      
      ON EVERY ROW

         PRINT COLUMN 001, p_rovciclo_peca.cod_item,
               COLUMN 017, p_den_item[1,31],
               COLUMN 050, p_rovciclo_peca.qtd_ciclo_peca USING '######&',
               COLUMN 059, p_rovciclo_peca.qtd_peca_ciclo USING '######&',
               COLUMN 066, p_rovciclo_peca.cod_operac USING '######&',
               COLUMN 072, p_rovciclo_peca.num_seq_operac USING '######&'


      ON LAST ROW

        LET p_last_row = TRUE

     PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#

