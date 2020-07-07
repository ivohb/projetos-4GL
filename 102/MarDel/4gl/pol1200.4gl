#-------------------------------------------------------------------#
# PROGRAMA: pol1200                                                 #
# CLIENTE.: KF                                                      #
# OBJETIVO: UNIDADES VW PARA RECEBIMENTO DE EDI                     #
# AUTOR...: WILLIANS                                                #
# DATA....: 08/09/2010                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_fornecedor     LIKE fornec_edi_vw_5054.cod_fornecedor,
          p_user               LIKE usuario.nom_usuario,
          p_cod_empresa        LIKE empresa.cod_empresa,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          p_raz_social        LIKE fornecedor.raz_social,
          p_msg                CHAR(300)
          
   DEFINE p_fornec_edi_vw_5054       RECORD LIKE fornec_edi_vw_5054.*,
          p_fornec_edi_vw_5054a      RECORD LIKE fornec_edi_vw_5054.* 
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol1200-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1200.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol1200_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1200_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1200") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1200 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa to cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol1200_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol1200_exclusao() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol1200_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol1200_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol1200_paginacao("ANTERIOR")
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1200_sobre()
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1200

END FUNCTION

#--------------------------#
 FUNCTION pol1200_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa to cod_empresa
   
   INITIALIZE p_fornec_edi_vw_5054.* TO NULL

   IF pol1200_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO fornec_edi_vw_5054 VALUES (p_fornec_edi_vw_5054.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
      ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa to cod_empresa
      END IF 
   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol1200_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol1200

   INPUT BY NAME p_fornec_edi_vw_5054.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_fornecedor
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD raz_social
      END IF 
      
      AFTER FIELD cod_fornecedor
      IF p_fornec_edi_vw_5054.cod_fornecedor IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_fornecedor
      ELSE
         SELECT raz_social
         INTO p_raz_social
         FROM fornecedor
         WHERE cod_fornecedor = p_fornec_edi_vw_5054.cod_fornecedor
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Fornecedor nao Cadastrado no Logix !!!" 
            NEXT FIELD cod_fornecedor
         END IF
                  
           SELECT cod_fornecedor
           INTO p_cod_fornecedor
           FROM fornec_edi_vw_5054
          WHERE cod_fornecedor = p_fornec_edi_vw_5054.cod_fornecedor
            
          
         IF STATUS = 0 THEN
            ERROR "Fornecedor já Cadastrado no EDI !!!"
            NEXT FIELD cod_fornecedor
         END IF
         
         DISPLAY p_raz_social TO raz_social 
      END IF
         
         ON KEY (control-z)
            LET p_cod_fornecedor = sup162_popup_fornecedor()
            IF p_cod_fornecedor IS NOT NULL THEN
               LET p_fornec_edi_vw_5054.cod_fornecedor = p_cod_fornecedor
               CURRENT WINDOW IS w_pol1200
               DISPLAY p_fornec_edi_vw_5054.cod_fornecedor TO cod_fornecedor
            END IF
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol1200

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol1200_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa to cod_empresa
   
   LET p_fornec_edi_vw_5054a.* = p_fornec_edi_vw_5054.*

   CONSTRUCT BY NAME where_clause ON fornec_edi_vw_5054.cod_fornecedor
  
   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_fornec_edi_vw_5054.* = p_fornec_edi_vw_5054a.*
      CALL pol1200_exibe_dados()
      CLEAR FORM         
      DISPLAY p_cod_empresa to cod_empresa
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM fornec_edi_vw_5054 ",
                  " where ", where_clause CLIPPED,                 
                  "ORDER BY cod_fornecedor "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_fornec_edi_vw_5054.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol1200_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol1200_exibe_dados()
#------------------------------#
   SELECT raz_social
     INTO p_raz_social
     FROM fornecedor
    WHERE cod_fornecedor = p_fornec_edi_vw_5054.cod_fornecedor

   DISPLAY BY NAME p_fornec_edi_vw_5054.*
   DISPLAY p_raz_social TO raz_social
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol1200_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_fornec_edi_vw_5054.*                                              
     FROM fornec_edi_vw_5054
    WHERE cod_fornecedor = p_fornec_edi_vw_5054.cod_fornecedor
    FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","fornec_edi_vw_5054")   
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1200_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol1200_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM fornec_edi_vw_5054
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_fornec_edi_vw_5054.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa to cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","fornec_edi_vw_5054")
         END IF
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

#-----------------------------------#
 FUNCTION pol1200_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_fornec_edi_vw_5054a.* = p_fornec_edi_vw_5054.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_fornec_edi_vw_5054.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_fornec_edi_vw_5054.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_fornec_edi_vw_5054.* = p_fornec_edi_vw_5054a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_fornec_edi_vw_5054.*
           FROM fornec_edi_vw_5054
          WHERE cod_fornecedor = p_fornec_edi_vw_5054.cod_fornecedor 
           
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol1200_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol1200_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               "ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     GrupoAceex\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#