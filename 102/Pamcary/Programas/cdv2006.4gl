###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: CONTROLE DE VIAGENS                                   #
# PROGRAMA: CDV2006                                               #
# OBJETIVO: MANUTENCAO DA TABELA cdv_find_ativ_781                #
# AUTOR...: FABIANO PEDRO ESPINDOLA                               #
# DATA....: 14.07.2005                                            #
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
         g_comando           CHAR(80),
         g_comand_cdv_rel    CHAR(150),
         g_comand_cdv          CHAR(100),
         g_ies_grafico       SMALLINT

DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

  DEFINE sql_stmt         CHAR(500),
         sql_stmt2        CHAR(500),
         where_clause     CHAR(500),
         m_den_empresa    LIKE empresa.den_empresa

  DEFINE m_houve_erro           SMALLINT,
         m_consunta_ativa       SMALLINT,
         mr_cdv_find_ativ_781   RECORD LIKE cdv_find_ativ_781.*,
         mr_cdv_find_ativ_781r  RECORD LIKE cdv_find_ativ_781.*,
         mr_cdv_finalidade_781  RECORD LIKE cdv_finalidade_781.*,
         mr_cdv_finalidade_781r RECORD LIKE cdv_finalidade_781.*

  DEFINE ma_atividades          ARRAY[999] OF RECORD
                                atividade     LIKE cdv_ativ_781.ativ,
                                des_atividade LIKE cdv_ativ_781.des_ativ
                                END RECORD

  DEFINE m_curr                 SMALLINT,
         m_scr_line             SMALLINT,
         m_ind                  SMALLINT

MAIN

     CALL log0180_conecta_usuario()

LET p_versao = "CDV2006-05.10.02p" #Favor nao alterar esta linha (SUPORTE)
INITIALIZE p_status TO NULL

  WHENEVER ERROR CONTINUE
  CALL log1400_isolation()
  SET LOCK MODE TO WAIT  120
  WHENEVER ERROR STOP
  DEFER INTERRUPT

  CALL log140_procura_caminho("cdv2006.iem") RETURNING g_comand_cdv

  OPTIONS
    FIELD ORDER UNCONSTRAINED,
    HELP    FILE g_comand_cdv,
     INSERT   KEY control-i,
    DELETE   KEY control-e,
    NEXT     KEY control-f,
    PREVIOUS KEY control-b
  CALL log001_acessa_usuario("CDV","LOGERP")
    RETURNING p_status, p_cod_empresa, p_user

  IF p_status = 0
    THEN CALL cdv2006_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION cdv2006_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  CALL log130_procura_caminho("cdv2006") RETURNING g_comand_cdv

  OPEN WINDOW w_cdv2006 AT 2,2 WITH FORM g_comand_cdv
       ATTRIBUTE(BORDER,MESSAGE LINE LAST,PROMPT LINE LAST)

  MENU "OPÇÃO"
    COMMAND "Incluir" "Inclusão uma nova relação entre finalidade e atividade."
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"CDV","CDV2006","IN") THEN
         INITIALIZE ma_atividades TO NULL
         CALL cdv2006_inclusao()
      END IF

    COMMAND "Modificar" "Modifica as atividades de uma finalidade."
      HELP 002
      MESSAGE ""
      LET int_flag = 0
      IF m_consunta_ativa IS NOT NULL THEN
         IF log005_seguranca(p_user,"CDV","CDV2006","MO")  THEN
            CALL cdv2006_modificacao()
         END IF
      ELSE
         CALL log0030_mensagem("Consulte previamente para fazer a modificação.","exclamation")
      END IF

    COMMAND "Excluir"  "Exclui a relação de finalidade cadastrada."
      HELP 003
      MESSAGE ""
      LET int_flag = 0
      IF m_consunta_ativa IS NOT NULL THEN
         IF log005_seguranca(p_user,"CDV","CDV2006","EX") THEN
            CALL cdv2006_exclusao()
         END IF
      ELSE
         CALL log0030_mensagem("Consulte previamente para executar a exclusão. ","exclamation")
      END IF

    COMMAND "Consultar"    "Consulta as finalidades x atividades cadastradas."
      HELP 004
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV","CDV2006","CO") THEN
         CALL cdv2006_consulta()
      END IF

    COMMAND "Seguinte"   "Exibe o próximo item encontrado na consulta."
      HELP 006
      MESSAGE ""
      LET int_flag = 0
      IF m_consunta_ativa  THEN
         CALL cdv2006_paginacao("SEGUINTE")
      ELSE
         CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")
      END IF

    COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta."
      HELP 007
      MESSAGE  ""
      IF m_consunta_ativa  THEN
         CALL cdv2006_paginacao("ANTERIOR")
      ELSE
         CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")
      END IF

    COMMAND "Listar"     "Lista as finalidades x atividades cadastradas."
      HELP 005
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"CDV","CDV2006","CO") THEN
         IF log0280_saida_relat(11,42) IS NOT NULL THEN
            CALL cdv2006_lista()
         END IF
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


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU

 CLOSE WINDOW w_cdv2006
END FUNCTION

#--------------------------#
 FUNCTION cdv2006_inclusao()
#--------------------------#
  DEFINE l_where_audit        CHAR(1000),
         lr_cdv_find_ativ_781 RECORD LIKE cdv_find_ativ_781.*,
         l_ind                INTEGER,
         l_sequencia          INTEGER

  LET mr_cdv_find_ativ_781.* = mr_cdv_find_ativ_781.*

  INITIALIZE mr_cdv_find_ativ_781.*, mr_cdv_finalidade_781.*  TO NULL
  CLEAR FORM

  IF cdv2006_entrada_dados("INCLUSAO") THEN
     LET m_houve_erro = FALSE

     WHENEVER ERROR CONTINUE
     CALL log085_transacao("BEGIN")
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     INSERT INTO cdv_finalidade_781 (finalidade,
                                     des_finalidade,
                                     eh_controle_obrig,
                                     eh_periodo_viagem,
                                     eh_ctr_encerram,
                                     gerar_tab_fat,
                                     eh_servico_interno)
                             VALUES (mr_cdv_finalidade_781.finalidade,
                                     mr_cdv_finalidade_781.des_finalidade,
                                     mr_cdv_finalidade_781.eh_controle_obrig,
                                     mr_cdv_finalidade_781.eh_periodo_viagem,
                                     mr_cdv_finalidade_781.eh_ctr_encerram,
                                     mr_cdv_finalidade_781.gerar_tab_fat,
                                     mr_cdv_finalidade_781.eh_servico_interno)

     WHENEVER ERROR STOP

     IF SQLCA.sqlcode <> 0 THEN
        CALL log003_err_sql("INSERT","cdv_finalidade_781")
        LET m_houve_erro = TRUE

        WHENEVER ERROR CONTINUE
        CALL log085_transacao("ROLLBACK")
        WHENEVER ERROR STOP
        RETURN
     END IF

     INITIALIZE l_where_audit TO NULL
     LET l_where_audit =  " cdv_finalidade_781.finalidade = ", mr_cdv_finalidade_781.finalidade USING "<<<<&"
     CALL cdv2006_grava_auditoria(l_where_audit, "I", 0, "cdv_finalidade_781")

     LET lr_cdv_find_ativ_781.finalidade = mr_cdv_finalidade_781.finalidade

     FOR l_ind = 1 TO 999

        IF ma_atividades[l_ind].atividade IS NULL
        OR ma_atividades[l_ind].atividade = " "
        OR ma_atividades[l_ind].atividade = 0 THEN
           CONTINUE FOR
        ELSE
           LET l_sequencia                         = l_sequencia + 1
           LET lr_cdv_find_ativ_781.ativ           = ma_atividades[l_ind].atividade
           LET lr_cdv_find_ativ_781.sequencia_ativ = l_sequencia

           WHENEVER ERROR CONTINUE
           INSERT INTO cdv_find_ativ_781 (finalidade,
                                          ativ,
                                          sequencia_ativ )
             VALUES (lr_cdv_find_ativ_781.finalidade,
                     lr_cdv_find_ativ_781.ativ,
                     lr_cdv_find_ativ_781.sequencia_ativ)
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode <> 0 THEN
              LET m_houve_erro = TRUE
              EXIT FOR
           END IF

           INITIALIZE l_where_audit TO NULL
           LET l_where_audit =  " cdv_find_ativ_781.finalidade =     ", lr_cdv_find_ativ_781.finalidade     USING "<<<<&",
                                " AND cdv_find_ativ_781.ativ =           ", lr_cdv_find_ativ_781.ativ           USING "<<<<&",
                                " AND cdv_find_ativ_781.sequencia_ativ = ", lr_cdv_find_ativ_781.sequencia_ativ USING "<<<<&"
           CALL cdv2006_grava_auditoria(l_where_audit, "I", 0, "cdv_find_ativ_781")

        END IF

     END FOR

     IF m_houve_erro = FALSE THEN
        WHENEVER ERROR CONTINUE
        CALL log085_transacao("COMMIT")
        WHENEVER ERROR STOP

        MESSAGE "Inclusão efetuada com sucesso."
        LET m_consunta_ativa = FALSE
     ELSE
        WHENEVER ERROR CONTINUE
        CALL log085_transacao("ROLLBACK")
        WHENEVER ERROR STOP

        CALL log003_err_sql("INCLUSAO","cdv_find_ativ_781")
     END IF

  ELSE
     LET mr_cdv_find_ativ_781r.* = mr_cdv_find_ativ_781.*
     CALL cdv2006_exibe_dados()
     ERROR "Inclusão cancelada."
  END IF

END FUNCTION

#---------------------------------------#
 FUNCTION cdv2006_entrada_dados(l_funcao)
#---------------------------------------#
 DEFINE l_funcao            CHAR(30),
        l_data_aux          DATE

 CALL log006_exibe_teclas("01 02 03 07",p_versao)
 CURRENT WINDOW IS w_cdv2006

 LET INT_FLAG = 0
 INPUT BY NAME mr_cdv_finalidade_781.finalidade,
               mr_cdv_finalidade_781.des_finalidade,
               mr_cdv_finalidade_781.eh_controle_obrig,
               mr_cdv_finalidade_781.eh_periodo_viagem,
               mr_cdv_finalidade_781.eh_ctr_encerram,
               mr_cdv_finalidade_781.gerar_tab_fat,
               mr_cdv_finalidade_781.eh_servico_interno WITHOUT DEFAULTS

    BEFORE INPUT
       IF mr_cdv_finalidade_781.gerar_tab_fat IS NULL THEN
          LET mr_cdv_finalidade_781.gerar_tab_fat = 'N'
       END IF
       IF mr_cdv_finalidade_781.eh_servico_interno IS NULL THEN
          LET mr_cdv_finalidade_781.eh_servico_interno = 'N'
       END IF

    BEFORE FIELD finalidade
       IF l_funcao = "MODIFICACAO" THEN
          NEXT FIELD des_finalidade
       END IF

    AFTER FIELD finalidade
       IF  mr_cdv_finalidade_781.finalidade IS NOT NULL
       AND mr_cdv_finalidade_781.finalidade <> " " THEN
         IF cdv2006_verifica_finalidade_cadastrada() = TRUE THEN
           CALL log0030_mensagem("Finalidade já cadastrada.","exclamation")
           NEXT FIELD finalidade
         END IF
       END IF

     AFTER FIELD eh_controle_obrig
        IF mr_cdv_finalidade_781.eh_controle_obrig IS NULL
        OR mr_cdv_finalidade_781.eh_controle_obrig = " " THEN
           LET mr_cdv_finalidade_781.eh_controle_obrig = "N"
           DISPLAY BY NAME mr_cdv_finalidade_781.eh_periodo_viagem
        END IF

     AFTER FIELD eh_periodo_viagem
        IF mr_cdv_finalidade_781.eh_periodo_viagem IS NULL
        OR mr_cdv_finalidade_781.eh_periodo_viagem = " " THEN
           LET mr_cdv_finalidade_781.eh_periodo_viagem = "N"
           DISPLAY BY NAME mr_cdv_finalidade_781.eh_periodo_viagem
        END IF

     AFTER FIELD eh_ctr_encerram
        IF mr_cdv_finalidade_781.eh_ctr_encerram IS NULL
        OR mr_cdv_finalidade_781.eh_ctr_encerram = " " THEN
           LET mr_cdv_finalidade_781.eh_ctr_encerram = "N"
           DISPLAY BY NAME mr_cdv_finalidade_781.eh_ctr_encerram
        END IF


    ON KEY (f1, control-w)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
      CALL cdv2006_help()

    AFTER INPUT
       IF INT_FLAG = 0 THEN
          IF mr_cdv_finalidade_781.finalidade IS NULL
          OR mr_cdv_finalidade_781.finalidade = " " THEN
             CALL log0030_mensagem("Finalidade não informada.","exclamation")
             NEXT FIELD finalidade
          ELSE
	            IF l_funcao = "INCLUSAO" THEN
	               IF cdv2006_verifica_finalidade_cadastrada() = TRUE THEN
 	                 CALL log0030_mensagem("Finalidade já cadastrada.","exclamation")
                   NEXT FIELD finalidade
   	            END IF
   	         END IF
          END IF

          IF mr_cdv_finalidade_781.des_finalidade IS NULL
          OR mr_cdv_finalidade_781.des_finalidade = " " THEN
             CALL log0030_mensagem("Descrição da finalidade não informada.","exclamation")
             NEXT FIELD des_finalidade
          END IF

          IF mr_cdv_finalidade_781.eh_controle_obrig IS NULL
          OR mr_cdv_finalidade_781.eh_controle_obrig = " " THEN
             LET mr_cdv_finalidade_781.eh_controle_obrig = "N"
          END IF

          IF mr_cdv_finalidade_781.eh_periodo_viagem IS NULL
          OR mr_cdv_finalidade_781.eh_periodo_viagem = " " THEN
             LET mr_cdv_finalidade_781.eh_periodo_viagem = "N"
          END IF
       END IF
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel("Control-Z","")
       ELSE
           DISPLAY "------" AT 3,69
       END IF

  END INPUT

  IF INT_FLAG = 0 THEN
     IF NOT cdv2006_informa_atividades(l_funcao) THEN
        LET INT_FLAG = FALSE
        RETURN FALSE
     END IF
  END IF

  IF int_flag = 0 THEN
     RETURN TRUE
  ELSE
     LET int_flag = 0
     RETURN FALSE
  END IF

END FUNCTION

#-----------------------------#
 FUNCTION cdv2006_exibe_dados()
#-----------------------------#
  DISPLAY BY NAME mr_cdv_finalidade_781.*

  WHENEVER ERROR CONTINUE
  SELECT UNIQUE finalidade
    FROM cdv_find_ativ_781
   WHERE finalidade = mr_cdv_finalidade_781.finalidade
  WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 OR SQLCA.sqlcode = -284 THEN
    IF INT_FLAG = 0 THEN
       CALL cdv2006_mostra_array()
    END IF
 END IF

END FUNCTION

#----------------------#
 FUNCTION cdv2006_help()
#----------------------#

  CASE
    WHEN infield(finalidade)          CALL showhelp(100)
    WHEN infield(des_finalidade)      CALL showhelp(101)
    WHEN infield(eh_controle_obrig)   CALL showhelp(102)
    WHEN infield(eh_periodo_viagem)   CALL showhelp(103)
    WHEN infield(atividade)           CALL showhelp(104)
    WHEN infield(eh_ctr_encerram)     CALL showhelp(105)
    WHEN infield(gerar_tab_fat)       CALL showhelp(106)
    WHEN infield(eh_servico_interno)  CALL showhelp(107)

 END CASE
END FUNCTION


#-----------------------------------#
 FUNCTION cdv2006_cursor_for_update()
#-----------------------------------#

  WHENEVER ERROR CONTINUE
   DECLARE cm_cdv_ativi CURSOR FOR
   SELECT finalidade
     INTO mr_cdv_finalidade_781.finalidade
     FROM cdv_finalidade_781
    WHERE cdv_finalidade_781.finalidade = mr_cdv_finalidade_781.finalidade
   FOR UPDATE
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","cm_cdv_ativi")
  END IF

  WHENEVER ERROR CONTINUE
  CALL log085_transacao("BEGIN")
  WHENEVER ERROR STOP

  LET m_houve_erro  = FALSE

  WHENEVER ERROR CONTINUE
  OPEN cm_cdv_ativi
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("cm_cdv_ativi","OPEN")
  END IF

  WHENEVER ERROR CONTINUE
  FETCH cm_cdv_ativi
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
  END IF

  CASE sqlca.sqlcode
    WHEN    0 RETURN TRUE
    WHEN -250 CALL log0030_mensagem("Registro sendo atualizado por outro usuário. Aguarde e tente novamente.","exclamation")
    WHEN  100 CALL log0030_mensagem("Registro não mais existe na tabela. Execute a consulta novamente.","exclamation")
    OTHERWISE CALL log003_err_sql("LEITURA","cdv_finalidade_781")
  END CASE

  WHENEVER ERROR CONTINUE
  CALL log085_transacao("ROLLBACK")
  WHENEVER ERROR STOP

  RETURN FALSE
END FUNCTION

#-----------------------------#
 FUNCTION cdv2006_modificacao()
#-----------------------------#

 DEFINE l_where_audit         CHAR(1000),
        l_sequencia_ativ      INTEGER,
        l_ind                 INTEGER,
        lr_cdv_find_ativ_781  RECORD LIKE cdv_find_ativ_781.*

 LET mr_cdv_find_ativ_781r.* = mr_cdv_find_ativ_781.*

 IF cdv2006_entrada_dados("MODIFICACAO")  THEN

       WHENEVER ERROR CONTINUE
        CALL log085_transacao("BEGIN")
       WHENEVER ERROR STOP

       INITIALIZE l_where_audit TO NULL
       LET l_where_audit =  " cdv_finalidade_781.finalidade = ", mr_cdv_finalidade_781.finalidade USING "<<<<&", " "
       CALL cdv2006_grava_auditoria(l_where_audit, "M", 1, "cdv_finalidade_781")

       WHENEVER ERROR CONTINUE
       UPDATE cdv_finalidade_781
          SET des_finalidade      = mr_cdv_finalidade_781.des_finalidade,
              eh_controle_obrig   = mr_cdv_finalidade_781.eh_controle_obrig,
              eh_periodo_viagem   = mr_cdv_finalidade_781.eh_periodo_viagem,
              eh_ctr_encerram     = mr_cdv_finalidade_781.eh_ctr_encerram,
              gerar_tab_fat       = mr_cdv_finalidade_781.gerar_tab_fat,
              eh_servico_interno  = mr_cdv_finalidade_781.eh_servico_interno
        WHERE finalidade        = mr_cdv_finalidade_781.finalidade
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          LET m_houve_erro = TRUE
          CALL log003_err_sql("UPDATE","cdv_finalidade_781")

          WHENEVER ERROR CONTINUE
          CALL log085_transacao("ROLLBACK")
          WHENEVER ERROR STOP

          RETURN
       END IF

       INITIALIZE l_where_audit TO NULL
       LET l_where_audit =  " cdv_finalidade_781.finalidade = ", mr_cdv_finalidade_781.finalidade USING "<<<<&", " "
       CALL cdv2006_grava_auditoria(l_where_audit, "M", 2, "cdv_finalidade_781")

       LET m_houve_erro = FALSE

       # DELETE
       WHENEVER ERROR CONTINUE
       DELETE FROM cdv_find_ativ_781
        WHERE finalidade = mr_cdv_finalidade_781.finalidade
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","cdv_find_ativ_781")
          RETURN
       END IF
       # DELETE

       FOR l_ind = 1 TO 999

          IF ma_atividades[l_ind].atividade IS NULL
          OR ma_atividades[l_ind].atividade = " "
          OR ma_atividades[l_ind].atividade = 0 THEN
             CONTINUE FOR
          ELSE
             LET lr_cdv_find_ativ_781.finalidade     = mr_cdv_finalidade_781.finalidade
             LET lr_cdv_find_ativ_781.ativ           = ma_atividades[l_ind].atividade
             LET lr_cdv_find_ativ_781.sequencia_ativ = l_ind

             INITIALIZE l_where_audit TO NULL
             LET l_where_audit =  " cdv_find_ativ_781.finalidade = ", lr_cdv_find_ativ_781.finalidade     USING "<<<<&",
                                  " AND cdv_find_ativ_781.ativ = ", lr_cdv_find_ativ_781.ativ           USING "<<<<&",
                                  " AND cdv_find_ativ_781.sequencia_ativ = ", lr_cdv_find_ativ_781.sequencia_ativ USING "<<<<&"
             CALL cdv2006_grava_auditoria(l_where_audit, "M", 1, "cdv_find_ativ_781")

             WHENEVER ERROR CONTINUE
             INSERT INTO cdv_find_ativ_781 (finalidade,
                                            ativ,
                                            sequencia_ativ )
               VALUES (lr_cdv_find_ativ_781.finalidade,
                       lr_cdv_find_ativ_781.ativ,
                       lr_cdv_find_ativ_781.sequencia_ativ)
             WHENEVER ERROR STOP

             IF SQLCA.sqlcode <> 0 THEN
                LET m_houve_erro = TRUE
                EXIT FOR
             END IF

             INITIALIZE l_where_audit TO NULL
             LET l_where_audit =  " cdv_find_ativ_781.finalidade = ", lr_cdv_find_ativ_781.finalidade     USING "<<<<&",
                                  " AND cdv_find_ativ_781.ativ   = ", lr_cdv_find_ativ_781.ativ           USING "<<<<&",
                                  " AND cdv_find_ativ_781.sequencia_ativ = ", lr_cdv_find_ativ_781.sequencia_ativ USING "<<<<&"
             CALL cdv2006_grava_auditoria(l_where_audit, "M", 2, "cdv_find_ativ_781")

          END IF

       END FOR

       IF m_houve_erro = FALSE  THEN

          WHENEVER ERROR CONTINUE
          CALL log085_transacao("COMMIT")
          WHENEVER ERROR STOP

          MESSAGE "Modificação efetuada com sucesso."
       ELSE

          WHENEVER ERROR CONTINUE
          CALL log085_transacao("ROLLBACK")
          WHENEVER ERROR STOP

          CALL log003_err_sql("UPDATE","cdv_find_ativ_781")
       END IF
       WHENEVER ERROR STOP
 ELSE
    WHENEVER ERROR CONTINUE
    CALL log085_transacao("ROLLBACK")
    WHENEVER ERROR STOP

    LET mr_cdv_find_ativ_781.* = mr_cdv_find_ativ_781r.*

    CALL cdv2006_exibe_dados()
    ERROR "Modificação cancelada."
 END IF
 WHENEVER ERROR CONTINUE
 CLOSE cm_cdv_ativi
 WHENEVER ERROR STOP

END FUNCTION

#--------------------------#
 FUNCTION cdv2006_exclusao()
#--------------------------#
 DEFINE l_where_audit    CHAR(1000)

 IF log0040_confirm(5,10,"Confirma exclusão?") THEN
    IF cdv2006_cursor_for_update() THEN

       WHENEVER ERROR CONTINUE
        CALL log085_transacao("BEGIN")
       WHENEVER ERROR STOP

       LET m_houve_erro = FALSE
       INITIALIZE l_where_audit TO NULL
       LET l_where_audit =  " cdv_find_ativ_781.finalidade = ", mr_cdv_finalidade_781.finalidade USING "<<<<&"
       CALL cdv2006_grava_auditoria(l_where_audit, "E", 1, "cdv_find_ativ_781")

       WHENEVER ERROR CONTINUE
       DELETE FROM cdv_find_ativ_781
        WHERE finalidade = mr_cdv_finalidade_781.finalidade
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","CDV_FIND_ATIV_781")
          LET m_houve_erro = TRUE
          CALL log085_transacao("ROLLBACK")
          RETURN
       END IF

       INITIALIZE l_where_audit TO NULL
       LET l_where_audit =  " cdv_finalidade_781.finalidade = ", mr_cdv_finalidade_781.finalidade USING "<<<<&"
       CALL cdv2006_grava_auditoria(l_where_audit, "E", 1, "cdv_finalidade_781")

       WHENEVER ERROR CONTINUE
       DELETE FROM cdv_finalidade_781
        WHERE finalidade = mr_cdv_finalidade_781.finalidade
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","CDV_FINALIDADE_781")
          LET m_houve_erro = TRUE
          CALL log085_transacao("ROLLBACK")
          RETURN
       END IF

       MESSAGE "Exclusão efetuada com sucesso."

       INITIALIZE mr_cdv_finalidade_781.* TO NULL
       CLEAR FORM

       WHENEVER ERROR CONTINUE
       CALL log085_transacao("COMMIT")
       WHENEVER ERROR STOP
    END IF
 END IF

 WHENEVER ERROR CONTINUE
 CLOSE cm_cdv_ativi
 WHENEVER ERROR STOP

END FUNCTION

#--------------------------#
 FUNCTION cdv2006_consulta()
#--------------------------#
  DEFINE where_clause, sql_stmt   CHAR(1000)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_cdv2006

  CLEAR FORM

  LET mr_cdv_find_ativ_781r.* = mr_cdv_find_ativ_781.*

  INITIALIZE mr_cdv_find_ativ_781.* TO NULL
  CLEAR FORM

  LET INT_FLAG = 0
  CONSTRUCT where_clause ON cdv_finalidade_781.finalidade,
                            cdv_finalidade_781.des_finalidade,
                            cdv_finalidade_781.eh_controle_obrig,
                            cdv_finalidade_781.eh_periodo_viagem,
                            cdv_finalidade_781.eh_ctr_encerram
                            FROM finalidade,
                                 des_finalidade,
                                 eh_controle_obrig,
                                 eh_periodo_viagem,
                                 eh_ctr_encerram

  ON KEY (f1, control-w)
     #lds IF NOT LOG_logix_versao5() THEN
     #lds CONTINUE CONSTRUCT
     #lds END IF
      CALL cdv2006_help()

  END CONSTRUCT

  CALL log006_exibe_teclas("02 09",p_versao)
  CURRENT WINDOW IS w_cdv2006

  IF int_flag THEN
     LET int_flag = 0
     LET mr_cdv_find_ativ_781.* = mr_cdv_find_ativ_781r.*
     CALL cdv2006_exibe_dados()
     ERROR "Consulta cancelada. "
     RETURN
  END IF

  LET sql_stmt2 = " SELECT finalidade, des_finalidade, eh_controle_obrig, eh_periodo_viagem, eh_ctr_encerram, gerar_tab_fat, eh_servico_interno ",
                  " FROM cdv_finalidade_781 WHERE ", where_clause CLIPPED,
                  " ORDER BY finalidade "

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
  FETCH cq_cdv_forn_fun2     INTO mr_cdv_finalidade_781.finalidade,
                                  mr_cdv_finalidade_781.des_finalidade,
                                  mr_cdv_finalidade_781.eh_controle_obrig,
                                  mr_cdv_finalidade_781.eh_periodo_viagem,
                                  mr_cdv_finalidade_781.eh_ctr_encerram,
                                  mr_cdv_finalidade_781.gerar_tab_fat,
                                  mr_cdv_finalidade_781.eh_servico_interno

  WHENEVER ERROR STOP

  IF sqlca.sqlcode = NOTFOUND  THEN
     CALL log0030_mensagem("Argumentos de pesquisa não encontrados. ","info")
     LET m_consunta_ativa = FALSE
  ELSE
     LET m_consunta_ativa = TRUE
     MESSAGE "Consulta efetuada com sucesso." ATTRIBUTE(REVERSE)
  END IF

  CALL cdv2006_exibe_dados()

END FUNCTION

#-----------------------------------#
 FUNCTION cdv2006_paginacao(l_funcao)
#-----------------------------------#
 DEFINE l_funcao            CHAR(20)

 INITIALIZE ma_atividades TO NULL
 CLEAR FORM

 IF m_consunta_ativa THEN
    LET mr_cdv_find_ativ_781r.* = mr_cdv_find_ativ_781.*

    WHILE TRUE
       CASE
          WHEN l_funcao = "SEGUINTE"
             WHENEVER ERROR CONTINUE
             FETCH NEXT     cq_cdv_forn_fun2 INTO mr_cdv_finalidade_781.finalidade,
                                                  mr_cdv_finalidade_781.des_finalidade,
                                                  mr_cdv_finalidade_781.eh_controle_obrig,
                                                  mr_cdv_finalidade_781.eh_periodo_viagem,
                                                  mr_cdv_finalidade_781.eh_ctr_encerram,
                                                  mr_cdv_finalidade_781.gerar_tab_fat,
                                                  mr_cdv_finalidade_781.eh_servico_interno
             WHENEVER ERROR STOP

          WHEN l_funcao = "ANTERIOR"
             WHENEVER ERROR CONTINUE
             FETCH PREVIOUS cq_cdv_forn_fun2 INTO mr_cdv_finalidade_781.finalidade,
                                                  mr_cdv_finalidade_781.des_finalidade,
                                                  mr_cdv_finalidade_781.eh_controle_obrig,
                                                  mr_cdv_finalidade_781.eh_periodo_viagem,
                                                  mr_cdv_finalidade_781.eh_ctr_encerram,
                                                  mr_cdv_finalidade_781.gerar_tab_fat,
                                                  mr_cdv_finalidade_781.eh_servico_interno
             WHENEVER ERROR STOP
       END CASE

       IF sqlca.sqlcode = NOTFOUND  THEN
          ERROR "Não existem mais itens nesta direção."
          LET mr_cdv_find_ativ_781.* = mr_cdv_find_ativ_781r.*
          EXIT WHILE
       END IF

       WHENEVER ERROR CONTINUE
       SELECT finalidade,
              des_finalidade,
              eh_controle_obrig,
              eh_periodo_viagem,
              eh_ctr_encerram,
              gerar_tab_fat,
              eh_servico_interno
         INTO mr_cdv_finalidade_781.finalidade,
              mr_cdv_finalidade_781.des_finalidade,
              mr_cdv_finalidade_781.eh_controle_obrig,
              mr_cdv_finalidade_781.eh_periodo_viagem,
              mr_cdv_finalidade_781.eh_ctr_encerram,
              mr_cdv_finalidade_781.gerar_tab_fat,
              mr_cdv_finalidade_781.eh_servico_interno
         FROM cdv_finalidade_781
        WHERE finalidade = mr_cdv_finalidade_781.finalidade
       WHENEVER ERROR STOP

       IF sqlca.sqlcode = 0 THEN
          IF mr_cdv_find_ativ_781.finalidade = mr_cdv_find_ativ_781r.finalidade THEN
          ELSE
            EXIT WHILE
          END IF
       END IF
    END WHILE
 ELSE
    CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")
 END IF

 CALL cdv2006_exibe_dados()

END FUNCTION

#-----------------------#
 FUNCTION cdv2006_lista()
#-----------------------#
 DEFINE l_tot_reg        SMALLINT,
        l_msg            CHAR(100),
        lr_relat         RECORD
                            finalidade         LIKE cdv_finalidade_781.finalidade,
                            des_finalidade     LIKE cdv_finalidade_781.des_finalidade,
                            eh_controle_obrig  LIKE cdv_finalidade_781.eh_controle_obrig,
                            eh_periodo_viagem  LIKE cdv_finalidade_781.eh_periodo_viagem,
                            eh_ctr_encerram    LIKE cdv_finalidade_781.eh_ctr_encerram,
                            gerar_tab_fat      CHAR(01),
                            eh_servico_interno CHAR(01),
                            ativ               LIKE cdv_find_ativ_781.ativ,
                            des_ativ           LIKE cdv_ativ_781.des_ativ,
                            sequencia_ativ     LIKE cdv_find_ativ_781.sequencia_ativ
                         END RECORD

 INITIALIZE lr_relat.* TO NULL

 MESSAGE " Processando a extração do relatório ... " ATTRIBUTE(REVERSE)

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
       LET g_comand_cdv_rel = g_comand_cdv_rel CLIPPED, "cdv2006.tmp"
       START REPORT cdv2006_relat TO g_comand_cdv_rel
    ELSE
       START REPORT cdv2006_relat TO p_nom_arquivo
    END IF
 ELSE
    IF p_ies_impressao = "S" THEN
       START REPORT cdv2006_relat TO PIPE p_nom_arquivo
    ELSE
       START REPORT cdv2006_relat TO p_nom_arquivo
    END IF
 END IF

 LET l_tot_reg = 0

 WHENEVER ERROR CONTINUE
 DECLARE cq_rel CURSOR FOR
  SELECT a.finalidade,
         a.des_finalidade,
         a.eh_controle_obrig,
         a.eh_periodo_viagem,
         a.eh_ctr_encerram,
         a.gerar_tab_fat,
         a.eh_servico_interno,
         b.ativ,
         c.des_ativ,
         b.sequencia_ativ
    FROM cdv_finalidade_781 a, cdv_find_ativ_781 b, cdv_ativ_781 c
   WHERE a.finalidade = b.finalidade
     AND b.ativ       = c.ativ
  ORDER BY finalidade, b.sequencia_ativ
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","CQ_REL")
  END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_rel INTO lr_relat.finalidade,
                     lr_relat.des_finalidade,
                     lr_relat.eh_controle_obrig,
                     lr_relat.eh_periodo_viagem,
                     lr_relat.eh_ctr_encerram,
                     lr_relat.gerar_tab_fat,
                     lr_relat.eh_servico_interno,
                     lr_relat.ativ,
                     lr_relat.des_ativ,
                     lr_relat.sequencia_ativ
 WHENEVER ERROR STOP

      IF SQLCA.sqlcode <> 0 THEN
         CALL log003_err_sql("cq_rel","FOREACH")
         RETURN
      END IF

      OUTPUT TO REPORT cdv2006_relat(lr_relat.*)
      LET l_tot_reg = l_tot_reg + 1

 END FOREACH
 FREE cq_rel

 FINISH REPORT cdv2006_relat

 IF l_tot_reg > 0 THEN
    IF g_ies_ambiente = "W" AND p_ies_impressao = "S"  THEN
       LET g_comand_cdv_rel = "lpdos.bat ", g_comand_cdv_rel CLIPPED, " ", p_nom_arquivo CLIPPED
       RUN g_comand_cdv_rel
    END IF
    IF p_ies_impressao = "S" THEN
       CALL log0030_mensagem("Relatório impresso com sucesso.","info")
    ELSE
       LET l_msg = " Relatório gravado no arquivo ",p_nom_arquivo CLIPPED
       CALL log0030_mensagem(l_msg,"info")
    END IF
 ELSE
    CALL log0030_mensagem("Não existem dados para serem listados.","info")
 END IF

 END FUNCTION

#------------------------------#
 REPORT cdv2006_relat(lr_relat)
#------------------------------#
 DEFINE lr_relat         RECORD
                            finalidade         LIKE cdv_finalidade_781.finalidade,
                            des_finalidade     LIKE cdv_finalidade_781.des_finalidade,
                            eh_controle_obrig  LIKE cdv_finalidade_781.eh_controle_obrig,
                            eh_periodo_viagem  LIKE cdv_finalidade_781.eh_periodo_viagem,
                            eh_ctr_encerram    LIKE cdv_finalidade_781.eh_ctr_encerram,
                            gerar_tab_fat      CHAR(01),
                            eh_servico_interno CHAR(01),
                            ativ               LIKE cdv_find_ativ_781.ativ,
                            des_ativ           LIKE cdv_ativ_781.des_ativ,
                            sequencia_ativ     LIKE cdv_find_ativ_781.sequencia_ativ
                         END RECORD

 OUTPUT LEFT     MARGIN 0
        TOP      MARGIN 0
        BOTTOM   MARGIN 0
        PAGE     LENGTH 66

FORMAT

   PAGE HEADER
   PRINT log5211_retorna_configuracao(PAGENO,66,114) CLIPPED;
      PRINT COLUMN 001, m_den_empresa CLIPPED
      PRINT COLUMN 001, "CDV2006",
            COLUMN 040, "FINALIDADES X ATIVIDADES",
            COLUMN 102, "FL.",
            COLUMN 105, pageno USING "##&"
      PRINT COLUMN 069, "EXTRAIDO EM ", today, " AS ", time, " HRS."

      SKIP 1 LINE

      PRINT COLUMN 001, "                                         CONTR VERIFICA VERIFICA GERAR GERAR                                                       "
      PRINT COLUMN 001, "FINALIDADE                               OBRIG PER.VIAG CTR ENCE FAT.  SERV. ATIV  DESCRICAO                                         "
      PRINT COLUMN 001, "---------------------------------------- ----- -------- -------- ----- ----- --------------------------------------------------------"

   BEFORE GROUP OF lr_relat.finalidade
      PRINT COLUMN 001, lr_relat.finalidade, " - ",
            COLUMN 008, lr_relat.des_finalidade CLIPPED;
      IF lr_relat.eh_controle_obrig = 'S' THEN
         PRINT COLUMN 042, "SIM";
      ELSE
         PRINT COLUMN 042, "NAO";
      END IF

      IF lr_relat.eh_periodo_viagem = 'S' THEN
         PRINT COLUMN 048, "SIM";
      ELSE
         PRINT COLUMN 048, "NAO";
      END IF

      IF lr_relat.eh_ctr_encerram = 'S' THEN
         PRINT COLUMN 057, "SIM";
      ELSE
         PRINT COLUMN 057, "NAO";
      END IF

      IF lr_relat.gerar_tab_fat = 'S' THEN
         PRINT COLUMN 066, "SIM";
      ELSE
         PRINT COLUMN 066, "NAO";
      END IF

      IF lr_relat.eh_servico_interno = 'S' THEN
         PRINT COLUMN 072, "SIM";
      ELSE
         PRINT COLUMN 072, "NAO";
      END IF

   ON EVERY ROW
         PRINT COLUMN 078, lr_relat.ativ,
               COLUMN 084, lr_relat.des_ativ CLIPPED

  ON LAST ROW
    LET g_last_row = TRUE

  PAGE TRAILER
      IF g_last_row = TRUE THEN
        PRINT "* * * ULTIMA FOLHA * * *"
      ELSE
        PRINT " "
      END IF

END REPORT

#-------------------------------------------------------------#
 FUNCTION cdv2006_verifica_cod_ativ(l_cod_ativ, l_curr, l_line)
#-------------------------------------------------------------#
  DEFINE l_cod_ativ  LIKE cdv_find_ativ_781.ativ,
         l_curr      SMALLINT,
         l_line      SMALLINT,
         l_des_ativ  LIKE cdv_ativ_781.des_ativ

 INITIALIZE l_des_ativ TO NULL

 WHENEVER ERROR CONTINUE
 SELECT des_ativ
   INTO l_des_ativ
   FROM cdv_ativ_781
  WHERE ativ = l_cod_ativ
 WHENEVER ERROR STOP

 LET ma_atividades[l_curr].des_atividade = l_des_ativ
 DISPLAY ma_atividades[l_curr].des_atividade TO sr_ativ[l_line].des_atividade

 IF sqlca.sqlcode = 0 THEN
   RETURN TRUE
 ELSE
   RETURN FALSE
 END IF

END FUNCTION

#------------------------------------------------------------------------#
 FUNCTION cdv2006_grava_auditoria(l_where_audit, l_opcao, l_num, l_tabela)
#------------------------------------------------------------------------#
 DEFINE l_where_audit CHAR(1000),
        l_opcao       CHAR(01),
        l_num         SMALLINT,
        l_tabela      CHAR(30)

 IF NOT cdv0801_geracao_auditoria(p_cod_empresa, l_tabela, l_where_audit, l_opcao, "CDV2006", l_num) THEN
    CALL log003_err_sql('INSERT','cdv_find_ativ_781')
 END IF

 END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2006_informa_atividades(l_funcao)
#--------------------------------------------#
 DEFINE l_funcao       CHAR(30)

 LET m_houve_erro = FALSE

 CALL log006_exibe_teclas("01 02 07",p_versao)
 CURRENT WINDOW IS w_cdv2006

 LET INT_FLAG = 0

 CALL SET_COUNT(m_ind)
 INPUT ARRAY ma_atividades WITHOUT DEFAULTS FROM sr_ativ.*

    BEFORE ROW
      LET m_curr      = arr_curr()
      LET m_scr_line  = scr_line()
      LET m_ind       = arr_count()

    BEFORE FIELD atividade
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel("Control-Z","Zoom")
       ELSE
          DISPLAY "(Zoom)" AT 3,69
       END IF

   AFTER DELETE
     IF m_ind > 0 AND
        m_ind >= m_curr THEN
        INITIALIZE ma_atividades[m_ind].* TO NULL
     END IF

    AFTER FIELD atividade
       IF  ma_atividades[m_curr].atividade IS NOT NULL
       AND ma_atividades[m_curr].atividade <> " " THEN
          IF NOT cdv2006_verifica_cod_ativ(ma_atividades[m_curr].atividade, m_curr, m_scr_line) THEN
             CALL log0030_mensagem("Atividade não cadastrada.","exclamation")
             NEXT FIELD atividade
          END IF
          IF cdv2006_verifica_duplicidade(ma_atividades[m_curr].atividade, m_curr) THEN
             CALL log0030_mensagem("Atividade já informada.","exclamation")
             NEXT FIELD atividade
          END IF

       END IF

    ON KEY (f1, control-w)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
      CALL cdv2006_help()

    ON KEY (control-z, f4)
      CALL cdv2006_popup(m_curr, m_scr_line)

    AFTER INPUT
       IF INT_FLAG = 0 THEN
       END IF
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel("Control-Z","")
       ELSE
           DISPLAY "------" AT 3,69
       END IF

 END INPUT

 IF INT_FLAG = TRUE THEN
    LET INT_FLAG = FALSE
    RETURN FALSE
 ELSE
    RETURN TRUE
 END IF

 END FUNCTION

#------------------------------#
 FUNCTION cdv2006_mostra_array()
#------------------------------#
 DEFINE l_ind, l_cont  INTEGER

 INITIALIZE ma_atividades TO NULL
 FOR l_cont = 1 TO 3
    DISPLAY ma_atividades[l_cont].atividade     TO sr_ativ[l_cont].atividade
    DISPLAY ma_atividades[l_cont].des_atividade TO sr_ativ[l_cont].des_atividade
 END FOR

 WHENEVER ERROR CONTINUE
 DECLARE cq_find_ativ_781 CURSOR FOR
  SELECT a.ativ, b.des_ativ, sequencia_ativ
    FROM cdv_find_ativ_781 a, cdv_ativ_781 b
   WHERE a.finalidade = mr_cdv_finalidade_781.finalidade
     AND a.ativ       = b.ativ
   ORDER BY sequencia_ativ
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_FIND_ATIV_781")
 END IF

 LET l_ind = 1
 WHENEVER ERROR CONTINUE
 FOREACH cq_find_ativ_781 INTO ma_atividades[l_ind].atividade,
                               ma_atividades[l_ind].des_atividade
 WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("cq_find_ativ_781","FOREACH")
       EXIT FOREACH
    END IF

    LET l_ind = l_ind + 1

 END FOREACH

 LET l_ind = l_ind - 1

 WHENEVER ERROR CONTINUE
 FREE cq_find_ativ_781
 WHENEVER ERROR STOP

 IF l_ind <= 3 THEN
    FOR l_cont = 1 TO l_ind
       DISPLAY ma_atividades[l_cont].atividade     TO sr_ativ[l_cont].atividade
       DISPLAY ma_atividades[l_cont].des_atividade TO sr_ativ[l_cont].des_atividade
    END FOR
 ELSE
    CALL SET_COUNT(l_ind)
    DISPLAY ARRAY ma_atividades TO sr_ativ.*
 END IF
 LET m_ind = l_ind

 END FUNCTION

#-------------------------------------#
 FUNCTION cdv2006_popup(l_curr, l_line)
#-------------------------------------#

 DEFINE l_cod_ativ           LIKE cdv_tdesp_viag_781.ativ,
        l_curr               INTEGER,
        l_line               INTEGER

 CASE
    WHEN INFIELD(atividade)
       LET l_cod_ativ = log009_popup(5,25,"ATIVIDADES",
                                           "cdv_ativ_781",
                                           "ativ",
                                           "des_ativ",
                                           "cdv2005",
                                           "N","")

      CALL log006_exibe_teclas("01 02 07",p_versao)
      CURRENT WINDOW IS w_cdv2006
      IF l_cod_ativ IS NOT NULL THEN
         LET ma_atividades[l_curr].atividade = l_cod_ativ
         DISPLAY ma_atividades[l_curr].atividade TO sr_ativ[l_line].atividade
      END IF

 END CASE

 END FUNCTION

#----------------------------------------------------#
 FUNCTION cdv2006_verifica_duplicidade(l_ativ, l_curr)
#----------------------------------------------------#

 DEFINE l_ativ  LIKE cdv_ativ_781.ativ,
        l_curr  INTEGER,
        l_ind   INTEGER

 IF l_curr <> 1 THEN
    FOR l_ind = 1 TO l_curr - 1
       IF l_ativ = ma_atividades[l_ind].atividade THEN
          RETURN TRUE
       END IF
    END FOR
 END IF

 RETURN FALSE
 END FUNCTION

#------------------------------------------------#
 FUNCTION cdv2006_verifica_finalidade_cadastrada()
#------------------------------------------------#

 WHENEVER ERROR CONTINUE
 SELECT finalidade
   FROM cdv_finalidade_781
  WHERE finalidade = mr_cdv_finalidade_781.finalidade
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE
 END FUNCTION

#-------------------------------#
 FUNCTION cdv2006_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/programas/cdv2006.4gl $|$Revision: 3 $|$Date: 23/12/11 12:23 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION