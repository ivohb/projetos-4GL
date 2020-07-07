#-------------------------------------------------------------------#
# PROGRAMA: POL0609                                                 #
# OBJETIVO: CADASTRO DE HISTÓRICOS PARA NOTA FISCAL                 #
# AUTOR...: IVO HONÓRIO BARBOSA                                     #
# DATA....: 13/06/2007                                              #
# TABELA..: FIT_HIST                                                #
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
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080)

   DEFINE p_num_solicit        LIKE fit_hist.num_solicit,
          p_num_solicita       LIKE fit_hist.num_solicit,
          p_nom_usuario        LIKE fit_hist.nom_usuario
   
   DEFINE p_texto              RECORD 
          num_solicit          LIKE fit_hist.num_solicit,
          texto_1              LIKE fit_hist.tex_hist_1_1,
          texto_2              LIKE fit_hist.tex_hist_1_1,
          texto_3              LIKE fit_hist.tex_hist_1_1,
          texto_4              LIKE fit_hist.tex_hist_1_1,
          texto_5              LIKE fit_hist.tex_hist_1_1,
          texto_6              LIKE fit_hist.tex_hist_1_1,
          texto_7              LIKE fit_hist.tex_hist_1_1,
          texto_8              LIKE fit_hist.tex_hist_1_1
   END RECORD          

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0609-05.00.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0609.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0609_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0609_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0609") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0609 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0609_consulta()
#         IF p_ies_cons THEN
#            NEXT OPTION "Seguinte" 
#         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0609_modificacao() THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
{      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0609_inclusao() THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF

      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0609_exclusao() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0609_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0609_paginacao("ANTERIOR")
}      COMMAND KEY ("!")
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
   CLOSE WINDOW w_pol0609

END FUNCTION

#---------------------------------------#
 FUNCTION pol0609_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01)

   INPUT BY NAME p_texto.* WITHOUT DEFAULTS
   
      BEFORE FIELD num_solicit
         IF p_funcao = 'M' THEN
            NEXT FIELD texto_1
         END IF
     
   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0609_consulta()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_texto TO NULL

   INPUT BY NAME p_texto.num_solicit WITHOUT DEFAULTS
   
      AFTER FIELD num_solicit
         
         LET p_num_solicit = p_texto.num_solicit
         
         IF p_num_solicit IS NULL THEN
            ERROR 'Informe o Número da Solicitação !!!'
            NEXT FIELD num_solicit
         END IF

         SELECT nom_usuario
           INTO p_nom_usuario
           FROM fit_hist
          WHERE cod_empresa = p_cod_empresa
            AND num_solicit = p_num_solicit

         IF STATUS = 100 THEN
            ERROR 'Solicitação Inexistente !!!'
            NEXT FIELD num_solicit
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql("leitura","fit_hist - Linha: 216")            
               LET INT_FLAG = TRUE
               EXIT INPUT
            END IF
         END IF
         
         DISPLAY p_nom_usuario TO nom_usuario
   
         IF p_nom_usuario <> p_user THEN
            ERROR 'Solicitação de Outro Usuário - Acesso Negado !!!'
            NEXT FIELD num_solicit
         END IF
     
   END INPUT 

   IF NOT INT_FLAG THEN
      CALL pol0609_exibe_dados()
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET INT_FLAG = 0
      LET p_ies_cons = FALSE
   END IF

END FUNCTION

#------------------------------#
FUNCTION  pol0609_le_fit_hist()
#------------------------------#

   SELECT num_solicit,
          tex_hist_1_1,
          tex_hist_2_1,
          tex_hist_3_1,
          tex_hist_4_1,
          tex_hist_1_2,
          tex_hist_2_2,
          tex_hist_3_2,
          tex_hist_4_2
     INTO p_texto.*
    FROM fit_hist
   WHERE cod_empresa = p_cod_empresa
     AND num_solicit = p_num_solicit
     AND nom_usuario = p_user
     
END FUNCTION

#------------------------------#
 FUNCTION pol0609_exibe_dados()
#------------------------------#

   CALL pol0609_le_fit_hist()         
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Leitura","fit_hist - Linha: 270")            
      LET p_ies_cons = FALSE
   ELSE   
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      DISPLAY BY NAME p_texto.*
      LET p_ies_cons = TRUE
   END IF
      
END FUNCTION

#-----------------------------------#
 FUNCTION pol0609_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE

   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT num_solicit
     FROM fit_hist  
    WHERE cod_empresa = p_cod_empresa
      AND num_solicit = p_num_solicit
      AND nom_usuario = p_user
      FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Leitura","fit_hist - Linha: 302")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0609_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0609_cursor_for_update() THEN
      IF pol0609_entrada_dados("M") THEN
         UPDATE fit_hist 
            SET tex_hist_1_1 = p_texto.texto_1,
                tex_hist_2_1 = p_texto.texto_2,
                tex_hist_3_1 = p_texto.texto_3,
                tex_hist_4_1 = p_texto.texto_4,
                tex_hist_1_2 = p_texto.texto_5,
                tex_hist_2_2 = p_texto.texto_6,
                tex_hist_3_2 = p_texto.texto_7,
                tex_hist_4_2 = p_texto.texto_8
          WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificacao","fit_hist - Linha: 329")
         END IF 
      ELSE
         CALL pol0609_exibe_dados()
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

{
#--------------------------#
 FUNCTION pol0609_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_texto.* TO NULL
   LET p_texto.cod_empresa = p_cod_empresa

   IF pol0609_entrada_dados("I") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO fit_hist VALUES (p_texto.*)
      IF SQLCA.SQLCODE <> 0 THEN 
	 CALL log003_err_sql("INCLUSAO","fit_hist")       
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

#-----------------------------------#
 FUNCTION pol0609_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_num_solicita = p_num_solicit
      WHILE TRUE
         
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao     INTO p_num_solicit
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_num_solicit
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_num_solicit = p_num_solicita
            EXIT WHILE
         END IF

         CALL pol0609_le_fit_hist()         

         IF STATUS <> 100 THEN
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION



#--------------------------#
 FUNCTION pol0609_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0609_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM fit_hist
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_texto.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","fit_hist")
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


#-------------------------------- FIM DE PROGRAMA -----------------------------#

