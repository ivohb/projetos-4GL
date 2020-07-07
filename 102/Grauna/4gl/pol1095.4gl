#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1095                                                 #
# OBJETIVO: Cadastro de Normas                                      #
# AUTOR...: PAULO CESAR MARTINEZ                                    #
# DATA....: 03/05/2011                                              #
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
         
  
   DEFINE p_certif_normas_1040   RECORD LIKE certif_normas_1040.*

   DEFINE p_codigo           LIKE certif_normas_1040.codigo,
          p_codigo_ant       LIKE certif_normas_1040.codigo,
          p_revisao          LIKE certif_normas_1040.revisao,
          p_revisao_ant      LIKE certif_normas_1040.revisao
          
   DEFINE p_relat       RECORD
   	      codigo        LIKE certif_normas_1040.codigo,      
   	      revisao       LIKE certif_normas_1040.revisao,      
   	      descricao     LIKE certif_normas_1040.descricao,
   	      data_vig_ini  LIKE certif_normas_1040.data_vig_ini,      
   	      data_vig_fim  LIKE certif_normas_1040.data_vig_fim      
   END RECORD   	            
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1095-05.10.02"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1095_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1095_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1095") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1095 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1095_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1095_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1095_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1095_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1095_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_codigo TO codigo
               DISPLAY p_revisao TO revisao
               
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1095_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1095_listagem()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1095

END FUNCTION

#--------------------------#
 FUNCTION pol1095_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_cod_cliente TO NULL
   INITIALIZE p_certif_normas_1040.* TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1095_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      LET p_certif_normas_1040.cod_empresa = p_cod_empresa
      LET p_certif_normas_1040.cod_usuario = p_user
      LET p_certif_normas_1040.data_cadastro = CURRENT
      INSERT INTO certif_normas_1040 VALUES (p_certif_normas_1040.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","certif_normas_1040")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1095_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT p_certif_normas_1040.codigo,   
         p_certif_normas_1040.revisao,
         p_certif_normas_1040.descricao,
         p_certif_normas_1040.data_vig_ini,
         p_certif_normas_1040.data_vig_fim
      WITHOUT DEFAULTS
         FROM codigo,
              revisao,
              descricao,
              data_vig_ini,
              data_vig_fim
              
                       
      BEFORE FIELD codigo
      IF p_funcao = "M" THEN
         NEXT FIELD descricao
      END IF
      
      AFTER FIELD codigo
      IF p_certif_normas_1040.codigo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD codigo   
      END IF
          
      BEFORE FIELD revisao
      IF p_funcao = "M" THEN
         NEXT FIELD descricao
      END IF
     

      AFTER FIELD revisao
      IF p_certif_normas_1040.revisao IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD revisao   
      END IF
          
      SELECT codigo
        FROM certif_normas_1040
       WHERE codigo  = p_certif_normas_1040.codigo
       AND   revisao = p_certif_normas_1040.revisao
      
      IF STATUS = 0 THEN
         ERROR "Norma já cadastrada!!!"
         NEXT FIELD codigo
      ELSE 
         IF STATUS <> 100 THEN   
            CALL log003_err_sql('lendo','certif_normas_1040')
            RETURN FALSE
         END IF 
      END IF    

      AFTER FIELD descricao
      IF p_certif_normas_1040.descricao IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD descricao   
      END IF
          
      AFTER FIELD data_vig_ini
      IF p_certif_normas_1040.data_vig_ini IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD data_vig_ini   
      END IF

      SELECT codigo
        FROM certif_normas_1040
       WHERE codigo  = p_certif_normas_1040.codigo
       AND  p_certif_normas_1040.data_vig_ini between data_vig_ini AND data_vig_fim
      
      IF STATUS = 0 THEN
         ERROR "Já existe norma cadastrada nessa data informada!!!"
      ELSE 
         IF STATUS <> 100 THEN   
            CALL log003_err_sql('lendo','certif_normas_1040')
            RETURN FALSE
         END IF 
      END IF    

      AFTER FIELD data_vig_fim
      IF p_certif_normas_1040.data_vig_fim IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD data_vig_fim   
      END IF

      IF p_certif_normas_1040.data_vig_ini > p_certif_normas_1040.data_vig_fim  THEN 
         ERROR "Data vigência inicial não pode ser maior que a final!!!"
         NEXT FIELD data_vig_ini   
      END IF


      ON KEY (control-z)
         CALL pol1095_popup()
           

   END INPUT 
   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
  FUNCTION pol1095_popup()
#-----------------------#

   DEFINE p_codigo SMALLINT


   

END FUNCTION 

#--------------------------#
 FUNCTION pol1095_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_codigo_ant = p_codigo
   LET p_revisao_ant = p_revisao
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      certif_normas_1040.codigo,
      certif_normas_1040.revisao,
      certif_normas_1040.descricao,
      certif_normas_1040.data_vig_ini,
      certif_normas_1040.data_vig_fim
      ON KEY (control-z)
         CALL pol1095_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            LET p_codigo = p_codigo_ant
            LET p_revisao = p_revisao_ant
            CALL pol1095_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   		LET sql_stmt = "SELECT codigo, revisao, descricao, data_vig_ini,data_vig_fim ",
                  	 "  FROM certif_normas_1040 ",
                     " WHERE ", where_clause CLIPPED,
                     " ORDER BY codigo,revisao"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_codigo, p_revisao

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1095_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1095_exibe_dados()
#------------------------------#
   LET p_cod_exibe = ""
   
   SELECT codigo,
          revisao,
          descricao,
          data_vig_ini,
          data_vig_fim
     INTO p_certif_normas_1040.codigo,
          p_certif_normas_1040.revisao,
          p_certif_normas_1040.descricao,
          p_certif_normas_1040.data_vig_ini,
          p_certif_normas_1040.data_vig_fim
     FROM certif_normas_1040
    WHERE codigo = p_codigo
    AND   revisao = p_revisao
    AND cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "certif_normas_1040")
      RETURN FALSE
   END IF
   
   		DISPLAY p_certif_normas_1040.codigo       TO codigo
   		DISPLAY p_certif_normas_1040.revisao      TO revisao
   		DISPLAY p_certif_normas_1040.descricao    TO descricao
   		DISPLAY p_certif_normas_1040.data_vig_ini TO data_vig_ini
   		DISPLAY p_certif_normas_1040.data_vig_fim TO data_vig_fim
   
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1095_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_codigo_ant  = p_codigo
   LET p_revisao_ant = p_revisao
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_codigo, p_revisao
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_codigo, p_revisao
      
      END CASE

      IF STATUS = 0 THEN
         SELECT codigo, revisao, descricao, data_vig_ini,data_vig_fim 
           FROM certif_normas_1040
          WHERE codigo = p_codigo
          AND  revisao = p_revisao
          AND cod_empresa = p_cod_empresa
            
         IF STATUS = 0 THEN
            CALL pol1095_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_codigo  = p_codigo_ant
            LET p_revisao = p_revisao_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1095_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT codigo, revisao, descricao, data_vig_ini,data_vig_fim  
      FROM certif_normas_1040  
     WHERE codigo = p_codigo
     AND   revisao  = p_revisao  
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","certif_normas_1040")
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------------#
 FUNCTION pol1095_prende_nor_for()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_deleta CURSOR FOR
    SELECT * 
      FROM cert_norm_for_1040  
     WHERE cod_norma = p_codigo
     AND   revisao  = p_revisao  
       FOR UPDATE 
    
    OPEN cq_deleta
   FETCH cq_deleta
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","cert_norm_for_1040")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1095_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   LET p_codigo = p_certif_normas_1040.codigo
   LET p_revisao  = p_certif_normas_1040.revisao 
   
   IF pol1095_prende_registro() THEN
      IF pol1095_edita_dados("M") THEN
         
         UPDATE certif_normas_1040
            SET codigo = p_certif_normas_1040.codigo,
                revisao  = p_certif_normas_1040.revisao,
                descricao = p_certif_normas_1040.descricao,
                data_vig_ini = p_certif_normas_1040.data_vig_ini,
                data_vig_fim = p_certif_normas_1040.data_vig_fim
          WHERE codigo = p_codigo
          AND revisao  = p_revisao
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Modificando", "certif_normas_1040")
         ELSE
            LET p_retorno = TRUE
         END IF
      
      ELSE
         CALL pol1095_exibe_dados() RETURNING p_status
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
 FUNCTION pol1095_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   LET p_codigo = p_certif_normas_1040.codigo
   LET p_revisao  = p_certif_normas_1040.revisao 

   IF pol1095_prende_registro() THEN
      DELETE FROM certif_normas_1040
			WHERE codigo = p_codigo
			AND revisao    = p_revisao

      IF STATUS = 0 THEN               
         INITIALIZE p_certif_normas_1040 TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","certif_normas_1040")
      END IF
      CLOSE cq_prende
   END IF

   IF pol1095_prende_nor_for() THEN
      DELETE FROM cert_norm_for_1040
			WHERE cod_norma = p_codigo
			AND revisao    = p_revisao

      IF STATUS = 0 THEN               
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","cert_norm_for_1040")
      END IF
      CLOSE cq_deleta
   END IF


   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#--------------------------#
 FUNCTION pol1095_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1095_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1095_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT codigo,
          revisao,
          descricao,
          data_vig_ini,
          data_vig_fim
     FROM certif_normas_1040
 ORDER BY codigo,revisao                          
  
   FOREACH cq_impressao 
      INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'certif_normas_1040')
         RETURN
      END IF 
   
   OUTPUT TO REPORT pol1095_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1095_relat   
   
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
 FUNCTION pol1095_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1095.tmp"
         START REPORT pol1095_relat TO p_caminho
      ELSE
         START REPORT pol1095_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1095_le_den_empresa()
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
 REPORT pol1095_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 135, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1095",
               COLUMN 022, "NORMAS CADASTRADAS",
               COLUMN 053, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, '    Código      Rev.              Descrição               Inicio Vig.  Fim Vig.'
                          #         1         2         3         4         5         6         7         8 
                          # 234567890123456789012345678901234567890123456789012345678901234567890123456789012
         PRINT COLUMN 002, '--------------- ----- ----------------------------------- ---------- ----------'
                            
      ON EVERY ROW

         PRINT COLUMN 003, p_relat.codigo [1,15],
               COLUMN 018, p_relat.revisao [1,5],
               COLUMN 024, p_relat.descricao [1,35],
               COLUMN 060, p_relat.data_vig_ini,
               COLUMN 071, p_relat.data_vig_fim
                              
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
 FUNCTION pol1095_carrega_item() 
#-------------------------------#
 
    DEFINE pr_item       ARRAY[3000]
     OF RECORD
         cod_item          LIKE item.cod_item,
         den_item          LIKE item.den_item
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol10951") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol10951 AT 5,4 WITH FORM p_nom_tela
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
      
  CLOSE WINDOW w_pol10951

   RETURN pr_item[pr_index].cod_item
      
END FUNCTION 



#-------------------------------- FIM DE PROGRAMA -----------------------------#