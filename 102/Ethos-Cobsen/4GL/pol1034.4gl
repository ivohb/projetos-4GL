#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1034                                                 #
# OBJETIVO: INDICA QUAIS ITENS JÁ FORAM REVISTOS                    #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 29/04/10                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_den_familia        LIKE familia.den_familia,
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
          p_msg                CHAR(300),
          p_last_row           SMALLINT
         
   DEFINE p_revisao_item_547     RECORD LIKE revisao_item_547.*
   
   DEFINE p_revisao_item_547_ant RECORD LIKE revisao_item_547.*
             
   DEFINE p_den_item_reduz     LIKE item.den_item_reduz,
          p_cod_familia        LIKE item.cod_familia,
          p_texto              CHAR(250)
                    
END GLOBALS

MAIN
   #CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1034-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1034_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1034_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1034") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1034 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   CALL pol1034_limpa_tela()
   
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela"
         CALL pol1034_consultar() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = TRUE
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte"
         ELSE
            LET p_ies_cons = FALSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1034_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1034_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN 
            IF pol1034_modificar() THEN
               ERROR 'Modificação efetuada com sucesso !!!' 
            ELSE
               ERROR 'Operação cancela !!!'
            END IF
         ELSE
            ERROR 'Consulte previamente !!!'
         END IF  
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1034_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1034

END FUNCTION

#----------------------------#
 FUNCTION pol1034_limpa_tela()
#----------------------------#
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 
   
#---------------------------#
 FUNCTION pol1034_consultar()
#---------------------------#
   
   DEFINE where_clause,
          sql_stmt      CHAR(700)
   
   LET INT_FLAG = FALSE  
   CALL pol1034_limpa_tela()
         
   LET p_revisao_item_547_ant.* = p_revisao_item_547.*
   LET INT_FLAG                 = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      revisao_item_547.cod_item,
      revisao_item_547.num_revisao,
      revisao_item_547.ies_revisto
      
      ON KEY (control-z)
         CALL pol1034_popup()
         
   END CONSTRUCT      
            
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_revisao_item_547.* = p_revisao_item_547_ant.*
         CALL pol1034_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT *",
                  "  FROM revisao_item_547 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_item, num_revisao, ies_revisto"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_revisao_item_547.*

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1034_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION   

#-----------------------------#
 FUNCTION pol1034_exibe_dados()
#-----------------------------#
   
   SELECT den_item_reduz,
          cod_familia
     INTO p_den_item_reduz,
          p_cod_familia
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_revisao_item_547.cod_item
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo", "item")
      RETURN FALSE
   END IF 
   
   SELECT texto 
     INTO p_texto
     FROM txt_revisao_item_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = p_cod_familia
      AND num_revisao = p_revisao_item_547.num_revisao
          
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo", "txt_revisao_item_547")
      RETURN FALSE
   END IF 
   
   DISPLAY p_revisao_item_547.cod_item    TO cod_item
   DISPLAY p_den_item_reduz               TO den_item_reduz
   DISPLAY p_revisao_item_547.num_revisao TO num_revisao
   DISPLAY p_texto                        TO texto
   DISPLAY p_revisao_item_547.ies_revisto TO ies_revisto
   
   RETURN TRUE
   
END FUNCTION      

#-----------------------#
 FUNCTION pol1034_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
     WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1034
         IF p_codigo IS NOT NULL THEN
           LET p_revisao_item_547.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF
   END CASE 
   
END FUNCTION 

#-----------------------------------#
 FUNCTION pol1034_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_revisao_item_547_ant.* = p_revisao_item_547.*

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_revisao_item_547.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_revisao_item_547.*
         
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_item,
                num_revisao,
                ies_revisto
           INTO p_revisao_item_547.cod_item,
                p_revisao_item_547.num_revisao,
                p_revisao_item_547.ies_revisto
           FROM revisao_item_547
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_revisao_item_547.cod_item
            AND num_revisao = p_revisao_item_547.num_revisao
             
         IF STATUS = 0 THEN
            CALL pol1034_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_revisao_item_547.* = p_revisao_item_547_ant.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1034_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_item 
      FROM revisao_item_547
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_revisao_item_547.cod_item
       AND num_revisao = p_revisao_item_547.num_revisao
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","revisao_item_547")
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------#
 FUNCTION pol1034_modificar()
#---------------------------#
   
   IF p_revisao_item_547.ies_revisto = "S" THEN 
      CALL log0030_mensagem("Não se pode modificar itens que foram revistos !!!", "exclamation")
      RETURN FALSE 
   END IF 
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   IF pol1034_prende_registro() THEN
   
      UPDATE revisao_item_547
         SET ies_revisto = "S",
             cod_usuario = p_user,
             dat_atualiz = CURRENT 
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_revisao_item_547.cod_item
         AND num_revisao = p_revisao_item_547.num_revisao  
   
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("Modificando","revisao_item_547")       
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
      CLOSE cq_prende
      CALL log085_transacao("COMMIT")
      DISPLAY "S" TO ies_revisto
      RETURN TRUE 
   
   END IF 
   
   RETURN FALSE
      
END FUNCTION

#----------------------#
FUNCTION pol1034_sobre()
#----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#