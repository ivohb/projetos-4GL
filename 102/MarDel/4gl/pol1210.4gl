#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1210                                                 #
# OBJETIVO: FORNECEDORES P/ ENVIO DE NOTAS                          #
# AUTOR...: ACEEX - BL                                              #
# DATA....: 15/07/2013                                              #
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
          p_ind                SMALLINT,
          s_ind                SMALLINT,
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
          p_erro               CHAR(10)

END GLOBALS

DEFINE p_cod_fornecedor        CHAR(15),
       p_cod_ant               CHAR(15),
       p_descricao             CHAR(80),
       p_excluiu               SMALLINT

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1210-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0 THEN
      CALL pol1210_menu()
   END IF
   
END MAIN

#-----------------------#
 FUNCTION pol1210_menu()#
#-----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1210") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1210 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1210_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclus�o efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Opera��o cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1210_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o pr�ximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1210_paginacao("S")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1210_paginacao("A")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1210_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclus�o efetuada com sucesso !!!'
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclus�o !!!"
         END IF   
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
				CALL pol1210_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1210   

END FUNCTION

#------------------------#
 FUNCTION pol1210_sobre()#
#------------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1210_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION


#--------------------------#
 FUNCTION pol1210_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_cod_fornecedor TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1210_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO fornec_nf_5054 VALUES (p_cod_fornecedor)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","fornec_nf_5054")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1210_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
      
   INPUT p_cod_fornecedor   
      WITHOUT DEFAULTS
         FROM cod_fornecedor   
                            
      AFTER FIELD cod_fornecedor
      IF p_cod_fornecedor IS NULL THEN 
         ERROR "Campo com preenchimento obrigat�rio !!!"
         NEXT FIELD cod_fornecedor   
      END IF
          
      SELECT raz_social
        INTO p_descricao
        FROM fornecedor
       WHERE cod_fornecedor = p_cod_fornecedor
         
      IF STATUS = 100 THEN 
         ERROR 'Fornecedor inexistente!'
         NEXT FIELD cod_fornecedor
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','fornecedor')
            RETURN FALSE
         END IF 
      END IF  
     
      SELECT cod_fornecedor
        FROM fornec_nf_5054
       WHERE cod_fornecedor = p_cod_fornecedor
      
      IF STATUS = 0 THEN
         ERROR "C�digo j� cadastrado p/ envio de notas"
         NEXT FIELD cod_fornecedor
      ELSE 
         IF STATUS <> 100 THEN   
            CALL log003_err_sql('lendo','fornec_nf_5054')
            RETURN FALSE
         END IF 
      END IF    
      
      DISPLAY p_descricao TO descricao

      ON KEY (control-z)
         CALL pol1210_popup()
           
   END INPUT 

   IF INT_FLAG THEN
      CALL pol1210_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1210_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1210
         IF p_codigo IS NOT NULL THEN
            LET p_cod_fornecedor = p_codigo
            DISPLAY p_cod_fornecedor TO cod_fornecedor
         END IF

   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1210_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_ant = p_cod_fornecedor
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      fornec_nf_5054.cod_fornecedor
      
      ON KEY (control-z)
         CALL pol1210_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            LET p_cod_fornecedor = p_cod_ant
            CALL pol1210_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT cod_fornecedor ",
                  "  FROM fornec_nf_5054 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_fornecedor"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_fornecedor

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa n�o encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1210_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1210_exibe_dados()
#------------------------------#
   
   SELECT raz_social
     INTO p_descricao
     FROM Fornecedor
    WHERE cod_fornecedor = p_cod_fornecedor
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "Fornecedor")
      RETURN FALSE
   END IF
   
   DISPLAY p_cod_fornecedor        TO cod_fornecedor
   DISPLAY p_descricao             TO descricao
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1210_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_ant = p_cod_fornecedor
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_fornecedor
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_fornecedor
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_fornecedor
           FROM fornec_nf_5054
          WHERE cod_fornecedor = p_cod_fornecedor
            
         IF STATUS = 0 THEN
            CALL pol1210_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "N�o existem mais itens nesta dire��o !!!"
            LET p_cod_fornecedor = p_cod_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1210_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_fornecedor 
      FROM fornec_nf_5054  
     WHERE cod_fornecedor = p_cod_fornecedor
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","fornec_nf_5054")
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1210_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("N�o h� dados � serem exclu�dos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1210_prende_registro() THEN
      DELETE FROM fornec_nf_5054
			WHERE cod_fornecedor = p_cod_fornecedor

      IF STATUS = 0 THEN               
         INITIALIZE p_cod_fornecedor TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","fornec_nf_5054")
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
