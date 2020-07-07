#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1096                                                 #
# OBJETIVO: Cadastro de Associação Fornecedor x Norma               #
# AUTOR...: PAULO CESAR MARTINEZ                                    #
# DATA....: 04/05/2011                                              #
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
          p_where              CHAR(50),
          p_excluiu            SMALLINT
         
  
   DEFINE p_cert_norm_for_1040   RECORD LIKE cert_norm_for_1040.*

   DEFINE p_cod_norma          LIKE cert_norm_for_1040.cod_norma,
          p_cod_norma_ant      LIKE cert_norm_for_1040.cod_norma,
          p_revisao            LIKE cert_norm_for_1040.revisao,
          p_revisao_ant        LIKE cert_norm_for_1040.revisao,
          p_cod_item           LIKE cert_norm_for_1040.cod_item,
          p_cod_item_ant       LIKE cert_norm_for_1040.cod_item,
          p_cod_fornecedor     LIKE cert_norm_for_1040.cod_fornecedor,
          p_cod_fornecedor_ant LIKE cert_norm_for_1040.cod_fornecedor
          
   DEFINE p_relat       RECORD
   	      cod_norma      LIKE cert_norm_for_1040.cod_norma,      
   	      revisao        LIKE cert_norm_for_1040.revisao,      
   	      cod_fornecedor LIKE cert_norm_for_1040.cod_fornecedor,
   	      cod_item       LIKE cert_norm_for_1040.cod_item      
   END RECORD   	            
          


END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1096-05.10.02"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1096_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1096_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1096") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1096 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1096_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1096_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1096_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1096_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1096_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_cod_norma TO cod_norma
               DISPLAY p_cod_fornecedor TO cod_fornecedor
               
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1096_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1096_listagem()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1096

END FUNCTION

#--------------------------#
 FUNCTION pol1096_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_cod_cliente TO NULL
   INITIALIZE p_cert_norm_for_1040.* TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE
   
   IF pol1096_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      LET p_cert_norm_for_1040.cod_empresa = p_cod_empresa
      INSERT INTO cert_norm_for_1040 VALUES (p_cert_norm_for_1040.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","cert_norm_for_1040")       
         CALL log085_transacao("ROLLBACK")
      ELSE
          CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1096_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT p_cert_norm_for_1040.cod_norma,   
         p_cert_norm_for_1040.cod_fornecedor,
         p_cert_norm_for_1040.cod_item
      WITHOUT DEFAULTS
         FROM cod_norma,
              cod_fornecedor,
              cod_item
                       
      BEFORE FIELD cod_norma
      IF p_funcao = "M" THEN
         NEXT FIELD cod_fornecedor
      END IF
      
      AFTER FIELD cod_norma
      IF p_cert_norm_for_1040.cod_norma IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_norma   
      END IF

      SELECT revisao
        INTO p_cert_norm_for_1040.revisao
        FROM certif_normas_1040
        WHERE codigo  = p_cert_norm_for_1040.cod_norma
        AND   cod_empresa = p_cod_empresa 
				DISPLAY p_cert_norm_for_1040.revisao TO revisao

      IF STATUS = 100 THEN 
         ERROR 'Norma não cadastrada na tabela certif_normas_1040!!!'
         NEXT FIELD cod_norma
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','certif_normas_1040')
            RETURN FALSE
         END IF 
      END IF  


   		SELECT descricao
     	INTO p_den_origem
     	FROM certif_normas_1040
      WHERE codigo  = p_cert_norm_for_1040.cod_norma
      AND   revisao = p_cert_norm_for_1040.revisao 
      AND   cod_empresa = p_cod_empresa 
   		DISPLAY p_den_origem TO descricao
          
     
   		   

      AFTER FIELD cod_fornecedor
      IF p_cert_norm_for_1040.cod_fornecedor IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_fornecedor   
      END IF
          

   		SELECT raz_social 
   		INTO p_den_ref
   		FROM fornecedor
   		WHERE cod_fornecedor = p_cert_norm_for_1040.cod_fornecedor
   		DISPLAY p_den_ref  TO raz_social   

      SELECT cod_fornecedor
        INTO p_cert_norm_for_1040.cod_fornecedor
        FROM fornecedor
       WHERE cod_fornecedor = p_cert_norm_for_1040.cod_fornecedor
         
      IF STATUS = 100 THEN 
         ERROR 'Código de Fornecedor não cadastrado na tabela fornecedor!!!'
         NEXT FIELD cod_fornecedor
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','fornecedor')
            RETURN FALSE
         END IF 
      END IF  

      AFTER FIELD cod_item
      IF p_cert_norm_for_1040.cod_item IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_item   
      END IF
          
   		SELECT den_item_reduz 
   		INTO p_den_ref
   		FROM item
   		WHERE cod_item = p_cert_norm_for_1040.cod_item
      AND  cod_empresa = p_cod_empresa 
   		DISPLAY p_den_ref  TO den_item_reduz   

         
      IF STATUS = 100 THEN 
         ERROR 'Código de item não cadastrado na tabela item!!!'
         NEXT FIELD cod_item
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','item')
            RETURN FALSE
         END IF 
      END IF  


      SELECT cod_norma
        FROM cert_norm_for_1040
       WHERE cod_norma  = p_cert_norm_for_1040.cod_norma
       AND revisao = p_cert_norm_for_1040.revisao
       AND cod_fornecedor = p_cert_norm_for_1040.cod_fornecedor
       AND cod_item = p_cert_norm_for_1040.cod_item
       AND  cod_empresa = p_cod_empresa 
      
      IF STATUS = 0 THEN
         ERROR "Norma já cadastrada para este fornecedor e item!!!"
         NEXT FIELD cod_norma
      ELSE 
         IF STATUS <> 100 THEN   
            CALL log003_err_sql('lendo','cert_norm_for_1040')
            RETURN FALSE
         END IF 
      END IF    
     
      
      ON KEY (control-z)
         CALL pol1096_popup()
           

   END INPUT 
   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
  FUNCTION pol1096_popup()
#-----------------------#

   DEFINE p_codigo VARCHAR(15)
   
   LET p_where = "cod_empresa = ",p_cod_empresa CLIPPED

   CASE
      WHEN INFIELD(cod_norma)
         
   		LET p_cod_norma = pol1096_carrega_item() 
   		IF p_cod_norma IS NOT NULL THEN
      	LET p_cert_norm_for_1040.cod_norma = p_cod_norma CLIPPED
        DISPLAY p_cert_norm_for_1040.cod_norma TO cod_norma
				DISPLAY p_cert_norm_for_1040.revisao TO revisao
				DISPLAY p_den_origem TO descricao

      END IF

   END CASE 

   CASE
      WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1096
         
         IF p_codigo IS NOT NULL THEN
            LET p_cert_norm_for_1040.cod_fornecedor = p_codigo CLIPPED
   					SELECT raz_social 
   					INTO p_den_ref
   					FROM fornecedor
   					WHERE cod_fornecedor = p_codigo
   					DISPLAY p_den_ref  TO raz_social
   					DISPLAY p_codigo   TO cod_fornecedor  
         END IF
   END CASE 
   
   CASE
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1096
                   
         IF p_codigo IS NOT NULL THEN
            LET p_cert_norm_for_1040.cod_item = p_codigo CLIPPED
   					SELECT den_item_reduz 
   					INTO p_den_ref
   					FROM item
   					WHERE cod_item = p_codigo
      			AND  cod_empresa = p_cod_empresa 
   					DISPLAY p_den_ref  TO den_item_reduz 
   					DISPLAY p_codigo   TO cod_item  
         END IF
   END CASE 
   

END FUNCTION 

#--------------------------#
 FUNCTION pol1096_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_norma_ant = p_cod_norma
   LET p_cod_fornecedor_ant = p_cod_fornecedor
   LET p_revisao_ant = p_revisao
   LET p_cod_item_ant = p_cod_item
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      cert_norm_for_1040.cod_norma,
      cert_norm_for_1040.cod_fornecedor,
      cert_norm_for_1040.cod_item
      ON KEY (control-z)
         CALL pol1096_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            LET p_cod_norma = p_cod_norma_ant
            LET p_cod_fornecedor = p_cod_fornecedor_ant
            LET p_revisao = p_revisao_ant
            LET p_cod_item = p_cod_item_ant
            CALL pol1096_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   		LET sql_stmt = "SELECT cod_norma, revisao, cod_fornecedor, cod_item ",
                  	 "  FROM cert_norm_for_1040 ",
                     " WHERE ", where_clause CLIPPED,
                     " ORDER BY cod_norma,cod_fornecedor"
   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_norma,p_revisao,p_cod_fornecedor,p_cod_item 

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1096_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1096_exibe_dados()
#------------------------------#
   LET p_cod_exibe = ""
   
   SELECT cod_norma,
          revisao,
          cod_fornecedor,
          cod_item
     INTO p_cert_norm_for_1040.cod_norma,
          p_cert_norm_for_1040.revisao,
          p_cert_norm_for_1040.cod_fornecedor,
          p_cert_norm_for_1040.cod_item
          
     FROM cert_norm_for_1040
    WHERE cod_norma = p_cod_norma
    AND revisao = p_revisao
    AND cod_fornecedor = p_cod_fornecedor
    AND cod_item = p_cod_item
    AND cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "cert_norm_for_1040")
      RETURN FALSE
   END IF
   
   DISPLAY p_cert_norm_for_1040.cod_norma    TO cod_norma
   DISPLAY p_cert_norm_for_1040.revisao      TO revisao
   DISPLAY p_cert_norm_for_1040.cod_fornecedor TO cod_fornecedor
   DISPLAY p_cert_norm_for_1040.cod_item      TO cod_item
   
   SELECT descricao
   INTO p_den_origem
   FROM certif_normas_1040
   WHERE codigo  = p_cert_norm_for_1040.cod_norma
   AND   revisao = p_cert_norm_for_1040.revisao 
   AND   cod_empresa = p_cod_empresa 
   DISPLAY p_den_origem TO descricao

   SELECT raz_social 
   INTO p_den_ref
   FROM fornecedor
   WHERE cod_fornecedor = p_cert_norm_for_1040.cod_fornecedor
   DISPLAY p_den_ref                      TO raz_social   
      
   SELECT den_item_reduz 
   INTO p_den_ref
   FROM item
   WHERE cod_item = p_cert_norm_for_1040.cod_item
   AND cod_empresa = p_cod_empresa
   DISPLAY p_den_ref                      TO den_item_reduz   
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1096_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_norma_ant = p_cod_norma
   LET p_cod_fornecedor_ant  = p_cod_fornecedor
   LET p_revisao_ant = p_revisao
   LET p_cod_item_ant = p_cod_item
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_norma, p_revisao, p_cod_fornecedor, p_cod_item
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_norma, p_revisao, p_cod_fornecedor, p_cod_item 
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_norma, revisao,cod_fornecedor,cod_item
           FROM cert_norm_for_1040
          WHERE cod_norma = p_cod_norma
          AND revisao = p_revisao
          AND cod_fornecedor = p_cod_fornecedor
          AND cod_item = p_cod_item
          AND cod_empresa = p_cod_empresa
            
         IF STATUS = 0 THEN
            CALL pol1096_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_norma = p_cod_norma_ant
            LET p_cod_fornecedor  = p_cod_fornecedor_ant
            LET p_revisao = p_revisao_ant
            LET p_cod_item = p_cod_item_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1096_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_norma,revisao,cod_fornecedor,cod_item 
     FROM cert_norm_for_1040  
     WHERE cod_norma = p_cod_norma
     AND   cod_fornecedor  = p_cod_fornecedor  
     AND cod_empresa = p_cod_empresa
     FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","cert_norm_for_1040")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1096_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   LET p_cod_norma = p_cert_norm_for_1040.cod_norma
   LET p_cod_fornecedor  = p_cert_norm_for_1040.cod_fornecedor 
   
   IF pol1096_prende_registro() THEN
      IF pol1096_edita_dados("M") THEN
         
         UPDATE cert_norm_for_1040
            SET cod_norma = p_cert_norm_for_1040.cod_norma,
                revisao  = p_cert_norm_for_1040.revisao,
                cod_fornecedor  = p_cert_norm_for_1040.cod_fornecedor,
                cod_item  = p_cert_norm_for_1040.cod_item
          WHERE cod_norma = p_cod_norma
          AND cod_fornecedor = p_cod_fornecedor
          AND cod_empresa = p_cod_empresa
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Modificando", "cert_norm_for_1040")
         ELSE
            LET p_retorno = TRUE
         END IF
      
      ELSE
         CALL pol1096_exibe_dados() RETURNING p_status
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
 FUNCTION pol1096_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   LET p_cod_norma = p_cert_norm_for_1040.cod_norma
   LET p_cod_fornecedor  = p_cert_norm_for_1040.cod_fornecedor 

   IF pol1096_prende_registro() THEN
      DELETE FROM cert_norm_for_1040
			WHERE cod_norma = p_cod_norma
			AND cod_fornecedor = p_cod_fornecedor
			AND cod_empresa = p_cod_empresa

      IF STATUS = 0 THEN               
         INITIALIZE p_cert_norm_for_1040 TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","cert_norm_for_1040")
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
 FUNCTION pol1096_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1096_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1096_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT cod_norma,
          revisao,
          cod_fornecedor,
          cod_item
     FROM cert_norm_for_1040
 ORDER BY cod_norma,cod_fornecedor                          
  
   FOREACH cq_impressao 
      INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   

      SELECT raz_social_reduz
        INTO p_den_item_reduz
        FROM fornecedor
       WHERE cod_fornecedor = p_relat.cod_fornecedor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'fornecedor')
         RETURN
      END IF 
      
      LET p_den_item_reduz = p_relat.cod_fornecedor CLIPPED,' - ',p_den_item_reduz 
    
   OUTPUT TO REPORT pol1096_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1096_relat   
   
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
 FUNCTION pol1096_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1096.tmp"
         START REPORT pol1096_relat TO p_caminho
      ELSE
         START REPORT pol1096_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1096_le_den_empresa()
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
 REPORT pol1096_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 135, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1096",
               COLUMN 022, "CADASTRO NORMA / FORNECEDOR",
               COLUMN 53, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "---------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, '    Norma        Rev.            Fornecedor                Item '
         PRINT COLUMN 002, '--------------- ------ ------------------------------ ---------------'
                          #         1         2         3         4         5         6         7         8 
                          # 234567890123456789012345678901234567890123456789012345678901234567890123456789012
                            
      ON EVERY ROW

         PRINT COLUMN 003, p_relat.cod_norma [1,15],
               COLUMN 018, p_relat.revisao [1,5],
               COLUMN 025, p_den_item_reduz [1,30],
               COLUMN 056, p_relat.cod_item [1,15]
                              
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
 FUNCTION pol1096_carrega_item() 
#-------------------------------#
 
    DEFINE pr_item       ARRAY[3000]
     OF RECORD
         codigo            LIKE certif_normas_1040.codigo,
         num_rev           LIKE certif_normas_1040.revisao,
         den_norma         LIKE certif_normas_1040.descricao,
         data_vig_ini       LIKE certif_normas_1040.data_vig_ini,
         data_vig_fim       LIKE certif_normas_1040.data_vig_fim
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol10961") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol10961 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_item CURSOR FOR 
   SELECT codigo,revisao,descricao,data_vig_ini,data_vig_fim
   FROM   certif_normas_1040
   WHERE cod_empresa   = p_cod_empresa
   ORDER BY codigo

   LET pr_index = 1

   FOREACH cq_item INTO pr_item[pr_index].codigo,
                        pr_item[pr_index].num_rev,
                        pr_item[pr_index].den_norma,
                        pr_item[pr_index].data_vig_ini,
                        pr_item[pr_index].data_vig_fim
                         
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
      
  CLOSE WINDOW w_pol10961
   LET p_cert_norm_for_1040.revisao = pr_item[pr_index].num_rev
   LET p_den_origem = pr_item[pr_index].den_norma
   RETURN pr_item[pr_index].codigo
      
END FUNCTION 


#-------------------------------- FIM DE PROGRAMA -----------------------------#