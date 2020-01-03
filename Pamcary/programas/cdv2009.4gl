#-----------------------------------------------------------------#
# SISTEMA.: CONTROLE DE VIAGENS                                   #
# PROGRAMA: CDV2009                                               #
# OBJETIVO: MANUTENCAO DA TABELA CDV_MOTIVO_HOR_781               #
# AUTOR...: FABIANO PEDRO ESPINDOLA                               #
# DATA....: 15.07.2005                                            #
#-----------------------------------------------------------------#

DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         g_last_row          SMALLINT,
         p_ies_impressao     CHAR(01),
         g_ies_ambiente      CHAR(001),
         p_nom_arquivo       CHAR(100),
         g_ies_cons          SMALLINT,
         g_comando           CHAR(80),
         g_comand_cdv_rel    CHAR(150),
         g_comand_cdv        CHAR(100),
         g_ies_ordem         CHAR(01)

DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

  DEFINE sql_stmt         CHAR(500),
         sql_stmt2        CHAR(500),
         where_clause     CHAR(500),
         m_den_empresa    LIKE empresa.den_empresa

  DEFINE m_houve_erro            SMALLINT,
         m_ies_cons              SMALLINT,
         mr_cdv_motivo_hor_781   RECORD LIKE cdv_motivo_hor_781.*,
         mr_cdv_motivo_hor_781r  RECORD LIKE cdv_motivo_hor_781.*

MAIN

     CALL log0180_conecta_usuario()

LET p_versao = "CDV2009-05.10.00p" #Favor nao alterar esta linha (SUPORTE)
INITIALIZE p_status TO NULL

  WHENEVER ERROR CONTINUE
     CALL log1400_isolation()
     SET LOCK MODE TO WAIT  120
  WHENEVER ERROR STOP
  DEFER INTERRUPT

  CALL log140_procura_caminho("cdv2009.iem") RETURNING g_comand_cdv

  OPTIONS
    FIELD ORDER UNCONSTRAINED,
    HELP    FILE g_comand_cdv,
    HELP     KEY control-w,
#4gl     INSERT   KEY control-i,
    DELETE   KEY control-e,
    NEXT     KEY control-f,
    PREVIOUS KEY control-b
  CALL log001_acessa_usuario("CDV","LOGERP")
    RETURNING p_status, p_cod_empresa, p_user

  IF p_status = 0
    THEN CALL cdv2009_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION cdv2009_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  CALL log130_procura_caminho("cdv2009") RETURNING g_comand_cdv

  OPEN WINDOW w_cdv2009 AT 2,9 WITH FORM g_comand_cdv
       ATTRIBUTE(BORDER,MESSAGE LINE LAST,PROMPT LINE LAST)

   CALL log0010_close_window_screen()
  MENU "OPÇÃO"
    COMMAND "Incluir" "Inclusão de um novo motivo."
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"CDV","CDV2009","IN") THEN
         CALL cdv2009_inclusao()
      END IF

    COMMAND "Modificar" "Modifica o motivo corrente."
      HELP 002
      MESSAGE ""
      LET int_flag = 0

      IF mr_cdv_motivo_hor_781.motivo IS NOT NULL THEN
         IF log005_seguranca(p_user,"CDV","CDV2009","MO")  THEN
            CALL cdv2009_modificacao()
         END IF
      ELSE
         CALL log0030_mensagem("Consulte previamente para fazer a modificação.","exclamation")
      END IF

    COMMAND "Excluir"  "Exclui o motivo cadastrado."
      HELP 003
      MESSAGE ""
      LET int_flag = 0
      IF mr_cdv_motivo_hor_781.motivo IS NOT NULL THEN
         IF log005_seguranca(p_user,"CDV","CDV2009","EX") THEN
            CALL cdv2009_exclusao()
         END IF
      ELSE
         CALL log0030_mensagem("Consulte previamente para executar a exclusão.","exclamation")
      END IF

    COMMAND "Consultar"    "Consulta os motivos cadastradas."
      HELP 004
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV","CDV2009","CO") THEN
         CALL cdv2009_consulta()
      END IF

    COMMAND "Seguinte"   "Exibe o próximo item encontrado na consulta."
      HELP 006
      MESSAGE ""
      LET int_flag = 0
      IF m_ies_cons  THEN
         CALL cdv2009_paginacao("SEGUINTE")
      ELSE
         CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")
      END IF

    COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta."
      HELP 007
      MESSAGE  ""
      IF m_ies_cons  THEN
         CALL cdv2009_paginacao("ANTERIOR")
      ELSE
         CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")
      END IF

    COMMAND "Listar"     "Lista os motivos cadastradas."
      HELP 005
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"CDV","CDV2009","CO") THEN
         CALL cdv2009_lista()
      END IF

    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR g_comando
      RUN g_comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR g_comando
      LET int_flag = 0

    COMMAND "Fim"        "Retorna ao menu anterior."
      HELP 008
      MESSAGE  ""
      EXIT MENU
  END MENU

 CLOSE WINDOW w_cdv2009
END FUNCTION

#--------------------------#
 FUNCTION cdv2009_inclusao()
#--------------------------#
  DEFINE l_where_audit  CHAR(1000)

  LET mr_cdv_motivo_hor_781.* = mr_cdv_motivo_hor_781.*

  INITIALIZE mr_cdv_motivo_hor_781.* TO NULL
  CLEAR FORM

  IF cdv2009_entrada_dados("INCLUSAO") THEN
     WHENEVER ERROR CONTINUE
     CALL log085_transacao("BEGIN")
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     INSERT INTO cdv_motivo_hor_781 (motivo,
                                     des_motivo,
                                     eh_obs_apont_hor)
                             VALUES (mr_cdv_motivo_hor_781.motivo,
                                     mr_cdv_motivo_hor_781.des_motivo,
                                     mr_cdv_motivo_hor_781.eh_obs_apont_hor)
     WHENEVER ERROR STOP

     IF sqlca.sqlcode = 0 THEN

        INITIALIZE l_where_audit TO NULL
        LET l_where_audit =  " cdv_motivo_hor_781.motivo = ", mr_cdv_motivo_hor_781.motivo USING "<<<<&"
        CALL cdv2009_grava_auditoria(l_where_audit, "I", 0)

        WHENEVER ERROR CONTINUE
        CALL log085_transacao("COMMIT")
        WHENEVER ERROR STOP

        MESSAGE "Inclusão efetuada com sucesso. "
        LET m_ies_cons = FALSE
     ELSE
        WHENEVER ERROR CONTINUE
        CALL log085_transacao("ROLLBACK")
        WHENEVER ERROR STOP

        CALL log003_err_sql("INCLUSAO","cdv_motivo_hor_781")
     END IF
  ELSE
     LET mr_cdv_motivo_hor_781r.* = mr_cdv_motivo_hor_781.*
     CALL cdv2009_exibe_dados()
     ERROR " Inclusão cancelada. "
  END IF
END FUNCTION

#---------------------------------------#
 FUNCTION cdv2009_entrada_dados(l_funcao)
#---------------------------------------#
 DEFINE l_funcao            CHAR(30),
        l_data_aux          DATE

 CALL log006_exibe_teclas("01 02 03 07",p_versao)
 CURRENT WINDOW IS w_cdv2009

 IF l_funcao = "INCLUSAO" THEN
    LET mr_cdv_motivo_hor_781.eh_obs_apont_hor = 'N'
    DISPLAY BY NAME mr_cdv_motivo_hor_781.eh_obs_apont_hor
 END IF

 LET INT_FLAG = 0
 INPUT BY NAME mr_cdv_motivo_hor_781.motivo,
               mr_cdv_motivo_hor_781.des_motivo,
               mr_cdv_motivo_hor_781.eh_obs_apont_hor WITHOUT DEFAULTS

    BEFORE FIELD motivo
       IF l_funcao = "MODIFICACAO" THEN
          NEXT FIELD des_motivo
       END IF

    AFTER FIELD motivo
       IF  mr_cdv_motivo_hor_781.motivo IS NOT NULL
       AND mr_cdv_motivo_hor_781.motivo <> " " THEN
         IF cdv2009_verifica_motivo() = TRUE THEN
           CALL log0030_mensagem("Motivo já cadastrado.","exclamation")
           NEXT FIELD motivo
         END IF
       END IF

    ON KEY (f1, control-w)
      CALL cdv2009_help()

    AFTER INPUT
       IF INT_FLAG = 0 THEN
          IF mr_cdv_motivo_hor_781.motivo IS NULL
          OR mr_cdv_motivo_hor_781.motivo = " " THEN
             CALL log0030_mensagem("Código do motivo não informado.","exclamation")
             NEXT FIELD motivo
          END IF

          IF mr_cdv_motivo_hor_781.des_motivo IS NULL
          OR mr_cdv_motivo_hor_781.des_motivo = " " THEN
             CALL log0030_mensagem("Descrição do motivo não informado. ","exclamation")
             NEXT FIELD des_motivo
          END IF

          IF mr_cdv_motivo_hor_781.eh_obs_apont_hor IS NULL
          OR mr_cdv_motivo_hor_781.eh_obs_apont_hor = " " THEN
             LET mr_cdv_motivo_hor_781.eh_obs_apont_hor = 'N'
             DISPLAY BY NAME mr_cdv_motivo_hor_781.eh_obs_apont_hor
          END IF

       END IF

  END INPUT

  CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_cdv2009

  IF int_flag = 0 THEN
     RETURN TRUE
  ELSE
     LET int_flag = 0
     RETURN FALSE
  END IF
END FUNCTION

#-----------------------------#
 FUNCTION cdv2009_exibe_dados()
#-----------------------------#
  CLEAR FORM
  DISPLAY BY NAME mr_cdv_motivo_hor_781.*

END FUNCTION

#----------------------#
 FUNCTION cdv2009_help()
#----------------------#

  CASE
    WHEN infield(motivo)           CALL showhelp(100)
    WHEN infield(des_motivo)       CALL showhelp(101)
    WHEN infield(eh_obs_apont_hor) CALL showhelp(102)
 END CASE
END FUNCTION


#-----------------------------------#
 FUNCTION cdv2009_cursor_for_update()
#-----------------------------------#

  WHENEVER ERROR CONTINUE
   DECLARE cm_cdv_motivo CURSOR FOR
   SELECT motivo,
          des_motivo,
          eh_obs_apont_hor
     INTO mr_cdv_motivo_hor_781.motivo,
          mr_cdv_motivo_hor_781.des_motivo,
          mr_cdv_motivo_hor_781.eh_obs_apont_hor
     FROM cdv_motivo_hor_781
    WHERE cdv_motivo_hor_781.motivo     = mr_cdv_motivo_hor_781.motivo
      AND cdv_motivo_hor_781.des_motivo = mr_cdv_motivo_hor_781.des_motivo
   FOR UPDATE
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","cdv_motivo_hor_781")
  END IF

  WHENEVER ERROR CONTINUE
  CALL log085_transacao("BEGIN")
  WHENEVER ERROR STOP

  LET m_houve_erro  = FALSE

  WHENEVER ERROR CONTINUE
  OPEN cm_cdv_motivo
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("cm_cdv_motivo","OPEN")
  END IF

  WHENEVER ERROR CONTINUE
  FETCH cm_cdv_motivo
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
  END IF

  CASE sqlca.sqlcode
    WHEN    0 RETURN TRUE
    WHEN -250 ERROR " Registro sendo atualizado por outro usuário. Aguarde e tente novamente. "
    WHEN  100 ERROR " Registro não mais existe na tabela. Execute a consulta novamente. "
    OTHERWISE CALL log003_err_sql("LEITURA","cdv_motivo_hor_781")
  END CASE

  RETURN FALSE
END FUNCTION

#-----------------------------#
 FUNCTION cdv2009_modificacao()
#-----------------------------#

 DEFINE l_where_audit    CHAR(1000)

  IF cdv2009_cursor_for_update() THEN
     LET mr_cdv_motivo_hor_781r.* = mr_cdv_motivo_hor_781.*

     IF cdv2009_entrada_dados("MODIFICACAO")  THEN

        INITIALIZE l_where_audit TO NULL
        LET l_where_audit =  " cdv_motivo_hor_781.motivo = ", mr_cdv_motivo_hor_781.motivo USING "<<<<&"
        CALL cdv2009_grava_auditoria(l_where_audit, "M", 1)

        WHENEVER ERROR CONTINUE
        UPDATE cdv_motivo_hor_781 SET cdv_motivo_hor_781.motivo           = mr_cdv_motivo_hor_781.motivo,
                                      cdv_motivo_hor_781.des_motivo       = mr_cdv_motivo_hor_781.des_motivo,
                                      cdv_motivo_hor_781.eh_obs_apont_hor = mr_cdv_motivo_hor_781.eh_obs_apont_hor

        WHERE CURRENT OF cm_cdv_motivo
        WHENEVER ERROR STOP

        IF sqlca.sqlcode = 0  THEN

           INITIALIZE l_where_audit TO NULL
           LET l_where_audit =  " cdv_motivo_hor_781.motivo = ", mr_cdv_motivo_hor_781.motivo USING "<<<<&"
           CALL cdv2009_grava_auditoria(l_where_audit, "M", 2)

           WHENEVER ERROR CONTINUE
           CALL log085_transacao("COMMIT")
           WHENEVER ERROR STOP

           MESSAGE "Modificação efetuada com sucesso. "
        ELSE

           WHENEVER ERROR CONTINUE
           CALL log085_transacao("ROLLBACK")
           WHENEVER ERROR STOP

           CALL log003_err_sql("UPDATE","cdv_motivo_hor_781")
        END IF
        WHENEVER ERROR STOP
     ELSE
        WHENEVER ERROR CONTINUE
        CALL log085_transacao("ROLLBACK")
        WHENEVER ERROR STOP

        LET mr_cdv_motivo_hor_781.* = mr_cdv_motivo_hor_781r.*

        CALL cdv2009_exibe_dados()
        ERROR " Modificação cancelada. "
     END IF
     WHENEVER ERROR CONTINUE
     CLOSE cm_cdv_motivo
     WHENEVER ERROR STOP

  END IF
END FUNCTION

#--------------------------#
 FUNCTION cdv2009_exclusao()
#--------------------------#
 DEFINE l_where_audit    CHAR(1000)

     IF log0040_confirm(5,10,"Confirma exclusão de motivo?") THEN
        IF cdv2009_cursor_for_update() THEN

           INITIALIZE l_where_audit TO NULL
           LET l_where_audit =  " cdv_motivo_hor_781.motivo = ", mr_cdv_motivo_hor_781.motivo USING "<<<<&"
           CALL cdv2009_grava_auditoria(l_where_audit, "E", 1)

           WHENEVER ERROR CONTINUE
           DELETE FROM cdv_motivo_hor_781
           WHERE CURRENT OF cm_cdv_motivo
           WHENEVER ERROR STOP

           IF SQLCA.SQLCODE = 0  THEN
              MESSAGE "Exclusão efetuada com sucesso. "

              INITIALIZE mr_cdv_motivo_hor_781.* TO NULL
              CLEAR FORM

              WHENEVER ERROR CONTINUE
              CALL log085_transacao("COMMIT")
              WHENEVER ERROR STOP

           ELSE
              CALL log003_err_sql("EXCLUSAO","cdv_motivo_hor_781")
              LET m_houve_erro  = TRUE

              WHENEVER ERROR CONTINUE
              CALL log085_transacao("ROLLBACK")
              WHENEVER ERROR STOP

           END IF
        ELSE

           WHENEVER ERROR CONTINUE
           CALL log085_transacao("ROLLBACK")
           WHENEVER ERROR STOP

        END IF
     END IF

     WHENEVER ERROR CONTINUE
     CLOSE cm_cdv_motivo
     WHENEVER ERROR STOP

END FUNCTION

#--------------------------#
 FUNCTION cdv2009_consulta()
#--------------------------#
  DEFINE where_clause, sql_stmt   CHAR(1000)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_cdv2009

  LET mr_cdv_motivo_hor_781r.* = mr_cdv_motivo_hor_781.*

  INITIALIZE mr_cdv_motivo_hor_781.* TO NULL
  CLEAR FORM

  LET INT_FLAG = 0
  CONSTRUCT BY NAME where_clause ON cdv_motivo_hor_781.motivo,
                                    cdv_motivo_hor_781.des_motivo,
                                    cdv_motivo_hor_781.eh_obs_apont_hor

  CALL log006_exibe_teclas("02 09",p_versao)
  CURRENT WINDOW IS w_cdv2009

  IF int_flag THEN
     LET int_flag = 0
     LET mr_cdv_motivo_hor_781.* = mr_cdv_motivo_hor_781r.*
     CALL cdv2009_exibe_dados()
     ERROR "Consulta cancelada."
     RETURN
  END IF

  LET sql_stmt2 = " SELECT motivo, ",
                  "        des_motivo, ",
                  "        eh_obs_apont_hor ",
                  " FROM cdv_motivo_hor_781 WHERE ", where_clause CLIPPED,
                  " ORDER BY motivo "

  LET sql_stmt2 = sql_stmt2 CLIPPED

  WHENEVER ERROR CONTINUE
  PREPARE var_query1 FROM sql_stmt2
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("var_query1","PREPARE")
  END IF

  WHENEVER ERROR CONTINUE
  DECLARE cq_cdv_forn_fun2 SCROLL CURSOR WITH HOLD FOR var_query1
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","cq_cdv_forn_fun2")
  END IF

  WHENEVER ERROR CONTINUE
  OPEN cq_cdv_forn_fun2
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("cq_cdv_forn_fun2","OPEN")
  END IF

  WHENEVER ERROR CONTINUE
  FETCH cq_cdv_forn_fun2     INTO mr_cdv_motivo_hor_781.*
  WHENEVER ERROR STOP

  IF sqlca.sqlcode = NOTFOUND  THEN
     #ERROR " "
     CALL log0030_mensagem("Argumentos de pesquisa não encontrados. ","exclamation")

     LET m_ies_cons = FALSE
     RETURN
  ELSE
     CALL cdv2009_exibe_dados()
     MESSAGE "Consulta efetuada com sucesso." ATTRIBUTE(REVERSE)
     LET m_ies_cons = TRUE
     RETURN
  END IF

  CALL cdv2009_exibe_dados()

END FUNCTION

#-----------------------------------#
 FUNCTION cdv2009_paginacao(l_funcao)
#-----------------------------------#
 DEFINE l_funcao            CHAR(20)

 IF m_ies_cons THEN
    LET mr_cdv_motivo_hor_781r.* = mr_cdv_motivo_hor_781.*

    WHILE TRUE
       CASE
          WHEN l_funcao = "SEGUINTE" FETCH NEXT     cq_cdv_forn_fun2 INTO mr_cdv_motivo_hor_781.*
          WHEN l_funcao = "ANTERIOR" FETCH PREVIOUS cq_cdv_forn_fun2 INTO mr_cdv_motivo_hor_781.*
       END CASE

       IF sqlca.sqlcode = NOTFOUND  THEN
          ERROR " Não existem mais itens nesta direção. "
          LET mr_cdv_motivo_hor_781.* = mr_cdv_motivo_hor_781r.*
          EXIT WHILE
       END IF

       WHENEVER ERROR CONTINUE
       SELECT motivo,
              des_motivo,
              eh_obs_apont_hor
         INTO mr_cdv_motivo_hor_781.motivo,
              mr_cdv_motivo_hor_781.des_motivo,
              mr_cdv_motivo_hor_781.eh_obs_apont_hor
         FROM cdv_motivo_hor_781
        WHERE cdv_motivo_hor_781.motivo           = mr_cdv_motivo_hor_781.motivo
          AND cdv_motivo_hor_781.des_motivo       = mr_cdv_motivo_hor_781.des_motivo
          AND cdv_motivo_hor_781.eh_obs_apont_hor = mr_cdv_motivo_hor_781.eh_obs_apont_hor
       WHENEVER ERROR STOP

       IF sqlca.sqlcode = 0 THEN
          IF mr_cdv_motivo_hor_781.motivo           = mr_cdv_motivo_hor_781r.motivo AND
             mr_cdv_motivo_hor_781.des_motivo       = mr_cdv_motivo_hor_781r.des_motivo AND
             mr_cdv_motivo_hor_781.eh_obs_apont_hor = mr_cdv_motivo_hor_781r.eh_obs_apont_hor THEN
          ELSE
            CALL cdv2009_exibe_dados()
            EXIT WHILE
          END IF
       END IF

    END WHILE
 ELSE
    CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")
 END IF
END FUNCTION

#-----------------------#
 FUNCTION cdv2009_lista()
#-----------------------#
 DEFINE l_msg     CHAR(200),
        l_tot_reg INTEGER

 INITIALIZE l_msg TO NULL
 LET l_tot_reg = 0

 IF log0280_saida_relat(11,42) IS NOT NULL THEN
    ERROR " Processando a extração do relatório ... "

    WHENEVER ERROR CONTINUE
    SELECT den_empresa
      INTO m_den_empresa
      FROM empresa
     WHERE cod_empresa = p_cod_empresa
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       INITIALIZE m_den_empresa TO NULL
    END IF

    IF g_ies_ambiente = "W" THEN

       IF p_ies_impressao = "S" THEN
          CALL log150_procura_caminho("LST") RETURNING g_comand_cdv_rel
          LET g_comand_cdv_rel = g_comand_cdv_rel CLIPPED, "cdv2009.tmp"
          START REPORT cdv2009_relat TO g_comand_cdv_rel
       ELSE
          START REPORT cdv2009_relat TO p_nom_arquivo
       END IF
    ELSE
       IF p_ies_impressao = "S" THEN
          START REPORT cdv2009_relat TO PIPE p_nom_arquivo
       ELSE
          START REPORT cdv2009_relat TO p_nom_arquivo
       END IF
    END IF

  WHENEVER ERROR CONTINUE
  DECLARE cq_rel CURSOR FOR
   SELECT motivo,
          des_motivo,
          eh_obs_apont_hor
     FROM cdv_motivo_hor_781
   ORDER BY motivo
   WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","cq_rel")
  END IF

  WHENEVER ERROR CONTINUE
  OPEN cq_rel
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("CQ_REL","OPEN")
  END IF

  WHENEVER ERROR CONTINUE
  FETCH cq_rel INTO mr_cdv_motivo_hor_781.*
  WHENEVER ERROR STOP

    IF sqlca.sqlcode = NOTFOUND THEN
       CLEAR FORM
       ERROR " "
       CALL log0030_mensagem("Não existem dados para serem listados.","info")
    ELSE
       WHILE sqlca.sqlcode <> NOTFOUND
         OUTPUT TO REPORT cdv2009_relat(mr_cdv_motivo_hor_781.*)
         LET l_tot_reg = l_tot_reg + 1
         WHENEVER ERROR CONTINUE
         FETCH cq_rel  INTO mr_cdv_motivo_hor_781.*
         WHENEVER ERROR STOP
         IF SQLCA.sqlcode <> 0 THEN
         END IF
       END WHILE

       LET g_ies_cons = TRUE
    END IF

  WHENEVER ERROR CONTINUE
  CLOSE cq_rel
  FREE cq_rel
  WHENEVER ERROR STOP

  FINISH REPORT cdv2009_relat

  IF l_tot_reg > 0 THEN
     IF  g_ies_ambiente = "W" AND
         p_ies_impressao = "S"  THEN
         LET g_comand_cdv_rel = "lpdos.bat ",
             g_comand_cdv_rel CLIPPED, " ", p_nom_arquivo CLIPPED
         RUN g_comand_cdv_rel
     END IF
     IF p_ies_impressao = "S" THEN
        CALL log0030_mensagem("Relatório impresso com sucesso. ","info")
     ELSE
        IF g_ies_cons <> FALSE THEN
           LET l_msg = " Relatório gravado no arquivo ",p_nom_arquivo CLIPPED
           CALL log0030_mensagem(l_msg,"info")
        END IF
     END IF
  END IF
END IF

 END FUNCTION

#--------------------------------------------#
 REPORT cdv2009_relat(mr_cdv_motivo_hor_781)
#--------------------------------------------#
   DEFINE mr_cdv_motivo_hor_781      RECORD LIKE cdv_motivo_hor_781.*

   DEFINE p_primeira_vez    SMALLINT,
          p_ies_situacao    CHAR(09)

   OUTPUT LEFT     MARGIN 0
          TOP      MARGIN 0
          BOTTOM   MARGIN 0
          PAGE     LENGTH 66

 FORMAT

   PAGE HEADER
   PRINT log5211_retorna_configuracao(PAGENO,66,80) CLIPPED;
      PRINT COLUMN 001, m_den_empresa CLIPPED
      PRINT COLUMN 001, "CDV2009",
            COLUMN 027, "MOTIVO DE HORAS",
            COLUMN 074, "FL.",
            COLUMN 077, pageno USING "##&"
      PRINT COLUMN 041, "EXTRAIDO EM ", today, " AS ", time, " HRS."

      SKIP 1 LINE

      PRINT COLUMN 001, "COD   MOTIVO                         OBS "
      PRINT COLUMN 001, "----- ------------------------------ ----"

   LET p_primeira_vez = TRUE

   ON EVERY ROW

   PRINT COLUMN 001, mr_cdv_motivo_hor_781.motivo,
         COLUMN 007, mr_cdv_motivo_hor_781.des_motivo CLIPPED,
         COLUMN 038, mr_cdv_motivo_hor_781.eh_obs_apont_hor

  ON LAST ROW
    LET g_last_row = TRUE

  PAGE TRAILER
      IF g_last_row = TRUE THEN
        PRINT "* * * ULTIMA FOLHA * * *"
      ELSE
        PRINT " "
      END IF

END REPORT

#---------------------------------#
 FUNCTION cdv2009_verifica_motivo()
#---------------------------------#

 WHENEVER ERROR CONTINUE
 SELECT motivo
   FROM cdv_motivo_hor_781
  WHERE motivo  = mr_cdv_motivo_hor_781.motivo
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN
   RETURN TRUE
 ELSE
   RETURN FALSE
 END IF

END FUNCTION

#--------------------------------------------------------------#
 FUNCTION cdv2009_grava_auditoria(l_where_audit, l_opcao, l_num)
#--------------------------------------------------------------#
 DEFINE l_where_audit CHAR(1000),
        l_opcao       CHAR(01),
        l_num         SMALLINT

 IF NOT cdv0801_geracao_auditoria(p_cod_empresa, "cdv_motivo_hor_781", l_where_audit, l_opcao, "CDV2009", l_num) THEN
    CALL log003_err_sql('INSERT','cdv_motivo_hor_781')
 END IF

 END FUNCTION

#-------------------------------#
 FUNCTION cdv2009_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/programas/cdv2009.4gl $|$Revision: 3 $|$Date: 23/12/11 12:22 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION