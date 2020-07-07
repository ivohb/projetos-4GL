#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1094                                                 #
# OBJETIVO: Cadastro de Código Fiscal de Referência                 #
# AUTOR...: PAULO CESAR MARTINEZ                                    #
# DATA....: 11/04/2011                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
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
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_den_item_reduz     CHAR(34),
          p_den_origem         CHAR(30),
          p_den_ref            CHAR(30),
          p_cod_item           CHAR(15),
          p_nom_cliente        CHAR(36),
          p_cod_cliente        CHAR(15),
          p_cod_exibe          CHAR(7),
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          p_excluiu            SMALLINT
         
  
   DEFINE p_cfop_referencia_792g   RECORD LIKE cfop_referencia_792g.*

   DEFINE p_cfop_orig         LIKE cfop_referencia_792g.cfop_orig,
          p_cfop_orig_ant     LIKE cfop_referencia_792g.cfop_orig,
          p_cfop_ref          LIKE cfop_referencia_792g.cfop_ref,
          p_cfop_ref_ant      LIKE cfop_referencia_792g.cfop_ref
          
   DEFINE p_relat              RECORD LIKE cfop_referencia_792g.*      
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1094-10.02.02"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1094_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1094_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1094") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1094 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1094_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1094_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1094_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1094_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1094_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_cfop_orig TO cfop_orig
               DISPLAY p_cfop_ref TO cfop_ref
               
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1094_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1094_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	    	CALL pol1094_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1094

END FUNCTION

#--------------------------#
 FUNCTION pol1094_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_cod_cliente TO NULL
   INITIALIZE p_cfop_referencia_792g.* TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE
   
   IF pol1094_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO cfop_referencia_792g VALUES (p_cfop_referencia_792g.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","cfop_referencia_792g")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1094_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT p_cfop_referencia_792g.cfop_orig,   
         p_cfop_referencia_792g.cfop_ref
      WITHOUT DEFAULTS
         FROM cfop_orig,
              cfop_ref
                       
      BEFORE FIELD cfop_orig
      IF p_funcao = "M" THEN
         NEXT FIELD cfop_ref
      END IF
      
      AFTER FIELD cfop_orig
      IF p_cfop_referencia_792g.cfop_orig IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cfop_orig   
      END IF
          
      SELECT cod_fiscal
        INTO p_cfop_referencia_792g.cfop_orig
        FROM codigo_fiscal
       WHERE cod_fiscal = p_cfop_referencia_792g.cfop_orig
         
      IF STATUS = 100 THEN 
         ERROR 'Código Fiscal não cadastrado na tabela Codigo_fiscal!!!'
         NEXT FIELD cfop_orig
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','codigo_fiscal')
            RETURN FALSE
         END IF 
      END IF  
     
      SELECT cfop_orig
        FROM cfop_referencia_792g
       WHERE cfop_orig = p_cfop_referencia_792g.cfop_orig

      
      IF STATUS = 0 THEN
         ERROR "código fiscal já cadastrado!!!"
         NEXT FIELD cfop_orig
      ELSE 
         IF STATUS <> 100 THEN   
            CALL log003_err_sql('lendo','cfop_referencia_792g')
            RETURN FALSE
         END IF 
      END IF    

   		SELECT den_cod_fiscal
     	INTO p_den_origem
     	FROM Codigo_fiscal
    	WHERE cod_fiscal = p_cfop_referencia_792g.cfop_orig
   		DISPLAY p_den_origem TO den_cod_fisc_o
   		   


      IF p_cfop_referencia_792g.cfop_orig < '5000' THEN
         ERROR "código fiscal não válido para origem!!!"
         NEXT FIELD cfop_orig
      END IF    

      AFTER FIELD cfop_ref
      IF p_cfop_referencia_792g.cfop_ref IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cfop_ref   
      END IF
          
   		SELECT den_cod_fiscal 
   		INTO p_den_ref
   		FROM codigo_fiscal
   		WHERE cod_fiscal = p_cfop_referencia_792g.cfop_ref
   		DISPLAY p_den_ref  TO den_cod_fisc_r   

      SELECT cod_fiscal
        INTO p_cfop_referencia_792g.cfop_ref
        FROM codigo_fiscal
       WHERE cod_fiscal = p_cfop_referencia_792g.cfop_ref
         
      IF STATUS = 100 THEN 
         ERROR 'Código Fiscal não cadastrado na tabela Codigo_fiscal!!!'
         NEXT FIELD cfop_ref
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','codigo_fiscal')
            RETURN FALSE
         END IF 
      END IF  

      IF p_cfop_referencia_792g.cfop_ref > '4000' THEN
         ERROR "código fiscal não válido para destino!!!"
         NEXT FIELD cfop_ref
      END IF    

     
      
      ON KEY (control-z)
         CALL pol1094_popup()
           

   END INPUT 
   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
  FUNCTION pol1094_popup()
#-----------------------#

   DEFINE p_codigo SMALLINT


   CASE
      WHEN INFIELD(cfop_orig)
         
         CALL log009_popup(8,10,"CÓDIGO FISCAL","codigo_fiscal",
              "cod_fiscal","den_cod_fiscal","","S","cod_fiscal >= '5000'") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_cfop_referencia_792g.cfop_orig = p_codigo CLIPPED
            DISPLAY p_codigo TO cfop_orig
   					SELECT den_cod_fiscal
     				INTO p_den_origem
     				FROM Codigo_fiscal
    				WHERE cod_fiscal = p_codigo
   					DISPLAY p_den_origem TO den_cod_fisc_o   
         END IF
   END CASE 

   CASE
      WHEN INFIELD(cfop_ref)
         
         CALL log009_popup(8,10,"CÓDIGO FISCAL","codigo_fiscal",
              "cod_fiscal","den_cod_fiscal","","S","cod_fiscal < '4000'") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_cfop_referencia_792g.cfop_ref = p_codigo CLIPPED
            DISPLAY p_codigo TO cfop_ref
   					SELECT den_cod_fiscal 
   					INTO p_den_ref
   					FROM codigo_fiscal
   					WHERE cod_fiscal = p_codigo
   					DISPLAY p_den_ref  TO den_cod_fisc_r   
         END IF
   END CASE 
   

END FUNCTION 

#--------------------------#
 FUNCTION pol1094_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cfop_orig_ant = p_cfop_orig
   LET p_cfop_ref_ant = p_cfop_ref
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      cfop_referencia_792g.cfop_orig,
      cfop_referencia_792g.cfop_ref
      ON KEY (control-z)
         CALL pol1094_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            LET p_cfop_orig = p_cfop_orig_ant
            LET p_cfop_ref = p_cfop_ref_ant
            CALL pol1094_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   IF (p_cfop_orig IS NOT NULL) OR (p_cfop_ref IS NOT NULL) THEN
   		LET sql_stmt = "SELECT cfop_orig, cfop_ref ",
                  	 "  FROM cfop_referencia_792g ",
                     " WHERE ", where_clause CLIPPED,
                     " ORDER BY cfop_orig"
  ELSE                   
   		LET sql_stmt = "SELECT cfop_orig, cfop_ref ",
                  	 "  FROM cfop_referencia_792g ",
                     " ORDER BY cfop_orig"
 	END IF
   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cfop_orig

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1094_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1094_exibe_dados()
#------------------------------#
   LET p_cod_exibe = ""
   
   SELECT cfop_orig,
          cfop_ref
     INTO p_cfop_referencia_792g.cfop_orig,
          p_cfop_referencia_792g.cfop_ref
     FROM cfop_referencia_792g
    WHERE cfop_orig = p_cfop_orig
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "cfop_referencia_792g")
      RETURN FALSE
   END IF
   
   IF LENGTH(p_cfop_referencia_792g.cfop_orig) < 7 THEN
      LET p_cod_exibe = "   ",p_cfop_referencia_792g.cfop_orig CLIPPED
   		DISPLAY p_cod_exibe    TO cfop_orig
   ELSE	
   		DISPLAY p_cfop_referencia_792g.cfop_orig    TO cfop_orig
   END IF
   
   IF LENGTH(p_cfop_referencia_792g.cfop_ref) < 7 THEN
      LET p_cod_exibe = "   ",p_cfop_referencia_792g.cfop_ref CLIPPED
   		DISPLAY p_cod_exibe    TO cfop_ref
   ELSE	
   		DISPLAY p_cfop_referencia_792g.cfop_ref    TO cfop_ref
   END IF
   
   SELECT den_cod_fiscal
     INTO p_den_origem
     FROM Codigo_fiscal
    WHERE cod_fiscal = p_cfop_referencia_792g.cfop_orig
   DISPLAY p_den_origem                   TO den_cod_fisc_o   

   SELECT den_cod_fiscal 
   INTO p_den_ref
   FROM codigo_fiscal
   WHERE cod_fiscal = p_cfop_referencia_792g.cfop_ref
   DISPLAY p_den_ref                      TO den_cod_fisc_r   
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1094_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cfop_orig_ant = p_cfop_orig
   LET p_cfop_ref_ant  = p_cfop_ref
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cfop_orig
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cfop_orig
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cfop_orig,cfop_ref
           FROM cfop_referencia_792g
          WHERE cfop_orig = p_cfop_orig
#          AND cfop_ref = p_cfop_ref
            
         IF STATUS = 0 THEN
            CALL pol1094_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cfop_orig = p_cfop_orig_ant
            LET p_cfop_ref  = p_cfop_ref_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1094_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cfop_orig,cfop_ref 
      FROM cfop_referencia_792g  
     WHERE cfop_orig = p_cfop_orig
     AND   cfop_ref  = p_cfop_ref  
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","cfop_referencia_792g")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1094_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   LET p_cfop_orig = p_cfop_referencia_792g.cfop_orig
   LET p_cfop_ref  = p_cfop_referencia_792g.cfop_ref 
   
   IF pol1094_prende_registro() THEN
      IF pol1094_edita_dados("M") THEN
         
         UPDATE cfop_referencia_792g
            SET cfop_orig = p_cfop_referencia_792g.cfop_orig,
                cfop_ref  = p_cfop_referencia_792g.cfop_ref
          WHERE cfop_orig = p_cfop_orig
          AND cfop_ref    = p_cfop_ref
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Modificando", "cfop_referencia_792g")
         ELSE
            LET p_retorno = TRUE
         END IF
      
      ELSE
         CALL pol1094_exibe_dados() RETURNING p_status
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

#--------------------------#
 FUNCTION pol1094_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   LET p_cfop_orig = p_cfop_referencia_792g.cfop_orig
   LET p_cfop_ref  = p_cfop_referencia_792g.cfop_ref 

   IF pol1094_prende_registro() THEN
      DELETE FROM cfop_referencia_792g
			WHERE cfop_orig = p_cfop_orig
			AND cfop_ref    = p_cfop_ref

      IF STATUS = 0 THEN               
         INITIALIZE p_cfop_referencia_792g TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","cfop_referencia_792g")
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

#--------------------------#
 FUNCTION pol1094_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1094_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1094_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT cfop_orig,
          cfop_ref
     FROM cfop_referencia_792g
 ORDER BY cfop_orig                          
  
   FOREACH cq_impressao 
      INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      SELECT den_cod_fiscal
      INTO p_den_origem
      FROM Codigo_fiscal
      WHERE cod_fiscal = p_relat.cfop_orig
      
      SELECT den_cod_fiscal 
      INTO p_den_ref
      FROM codigo_fiscal
      WHERE cod_fiscal = p_relat.cfop_ref

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'cfop_referencia_792g')
         RETURN
      END IF 
   
   OUTPUT TO REPORT pol1094_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1094_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados !!!"
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
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1094_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1094.tmp"
         START REPORT pol1094_relat TO p_caminho
      ELSE
         START REPORT pol1094_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1094_le_den_empresa()
#--------------------------------#

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

#---------------------#
 REPORT pol1094_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 135, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1094",
               COLUMN 022, "CODIGO FISCAL DE REFERENCIA",
               COLUMN 114, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "---------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, 'CFOP            Descrição          CFOP             Descrição          '
         PRINT COLUMN 002, 'Origem                             Ref. '
         PRINT COLUMN 002, '------- -------------------------- ------- --------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 003, p_relat.cfop_orig [1,4],
               COLUMN 010, p_den_origem [1,26],
               COLUMN 038, p_relat.cfop_ref [1,4],
               COLUMN 045, p_den_ref [1,26]
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 055, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-------------------------------#   
 FUNCTION pol1094_carrega_item() 
#-------------------------------#
 
    DEFINE pr_item       ARRAY[3000]
     OF RECORD
         cod_item          LIKE item.cod_item,
         den_item          LIKE item.den_item
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol10941") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol10941 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_item CURSOR FOR 
   SELECT i.cod_item,i.den_item
   FROM   ped_itens p, item i
   WHERE  p.num_pedido = p_pedido_volvo_512.num_pedido
   AND i.cod_empresa   = p_cod_empresa
   AND p.cod_empresa   = i.cod_empresa
   AND p.cod_item      = i.cod_item
   ORDER BY i.den_item

   LET pr_index = 1

   FOREACH cq_item INTO pr_item[pr_index].cod_item,
                        pr_item[pr_index].den_item
                         
      LET pr_index = pr_index + 1
       IF pr_index > 3000 THEN
         ERROR "Limit e de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_item TO sr_item.*

   LET pr_index = ARR_CURR()
   LET sr_index = SCR_LINE() 
      
  CLOSE WINDOW w_pol10941

   RETURN pr_item[pr_index].cod_item
      
END FUNCTION 


#-----------------------#
 FUNCTION pol1094_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#-------------------------------- FIM DE PROGRAMA -----------------------------#