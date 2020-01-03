#-----------------------------------------------------------------#
# SISTEMA.: CONTROLE DE VIAGENS                                   #
# PROGRAMA: CDV2008                                               #
# OBJETIVO: MANUTENCAO DA TABELA CDV_CONTROLE_781                 #
# AUTOR...: FABIANO PEDRO ESPINDOLA                               #
# DATA....: 18.07.2005                                            #
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

  DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

  DEFINE sql_stmt         CHAR(500),
         sql_stmt2        CHAR(500),
         where_clause     CHAR(500),
         m_den_empresa    LIKE empresa.den_empresa

  DEFINE m_houve_erro         SMALLINT,
         m_ies_cons           SMALLINT,
         mr_cdv_controle_781  RECORD LIKE cdv_controle_781.*,
         mr_cdv_controle_781r RECORD LIKE cdv_controle_781.*

MAIN

  CALL log0180_conecta_usuario()

  LET p_versao = "CDV2008-05.10.02p" #Favor nao alterar esta linha (SUPORTE)
  INITIALIZE p_status TO NULL

  WHENEVER ERROR CONTINUE
     CALL log1400_isolation()
  SET LOCK MODE TO WAIT 120
  WHENEVER ERROR STOP
  DEFER INTERRUPT

  CALL log140_procura_caminho("cdv2008.iem") RETURNING g_comand_cdv

  OPTIONS
    FIELD  ORDER UNCONSTRAINED,
    HELP    FILE g_comand_cdv,
    HELP     KEY control-w,
#4gl INSERT   KEY control-i,
    DELETE   KEY control-e,
    NEXT     KEY control-f,
    PREVIOUS KEY control-b
  CALL log001_acessa_usuario("CDV","LOGERP")
    RETURNING p_status, p_cod_empresa, p_user

  IF p_status = 0 THEN
     CALL cdv2008_controle()
  END IF
END MAIN

#---------------------------#
 FUNCTION cdv2008_controle()
#---------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  CALL log130_procura_caminho("cdv2008") RETURNING g_comand_cdv

  OPEN WINDOW w_cdv2008 AT 2,2 WITH FORM g_comand_cdv
       ATTRIBUTE(BORDER,MESSAGE LINE LAST,PROMPT LINE LAST)

   CALL log0010_close_window_screen()
  MENU "OPÇÃO"
    COMMAND "Incluir" "Inclusão de um novo controle (sinistro)."
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"CDV","CDV2008","IN") THEN
         CALL cdv2008_inclusao()
      END IF

    COMMAND "Modificar" "Modifica o controle corrente."
      HELP 002
      MESSAGE ""
      LET int_flag = 0
      IF mr_cdv_controle_781.controle IS NOT NULL THEN
         IF log005_seguranca(p_user,"CDV","CDV2008","MO") THEN
            CALL cdv2008_modificacao()
         END IF
      ELSE
         CALL log0030_mensagem("Consulte previamente para fazer a modificação.","exclamation")
      END IF

    COMMAND "Excluir" "Exclui o controle cadastrado."
      HELP 003
      MESSAGE ""
      LET int_flag = 0
      IF mr_cdv_controle_781.controle IS NOT NULL THEN
         IF log005_seguranca(p_user,"CDV","CDV2008","EX") THEN
            CALL cdv2008_exclusao()
         END IF
      ELSE
         CALL log0030_mensagem("Consulte previamente para executar a exclusão.","exclamation")
      END IF

    COMMAND "Consultar" "Consulta os controles cadastrados."
      HELP 004
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV","CDV2008","CO") THEN
         CALL cdv2008_consulta()
      END IF

    COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
      HELP 006
      MESSAGE ""
      LET int_flag = 0
      IF m_ies_cons  THEN
         CALL cdv2008_paginacao("SEGUINTE")
      ELSE
         CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")
      END IF

    COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
      HELP 007
      MESSAGE  ""
      IF m_ies_cons  THEN
         CALL cdv2008_paginacao("ANTERIOR")
      ELSE
         CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")
      END IF

    COMMAND "Listar" "Lista os controles cadastrados."
      HELP 005
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"CDV","CDV2008","CO") THEN
         CALL cdv2008_lista()
      END IF

    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR g_comando
      RUN g_comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR g_comando
      LET int_flag = 0

    COMMAND "Fim" "Retorna ao menu anterior."
      HELP 008
      MESSAGE  ""
      EXIT MENU
  END MENU

 CLOSE WINDOW w_cdv2008
END FUNCTION

#---------------------------#
 FUNCTION cdv2008_inclusao()
#---------------------------#
  DEFINE l_where_audit  CHAR(1000)

  LET mr_cdv_controle_781.* = mr_cdv_controle_781.*

  INITIALIZE mr_cdv_controle_781.* TO NULL
  CLEAR FORM

  IF cdv2008_entrada_dados("INCLUSAO") THEN
     WHENEVER ERROR CONTINUE
     CALL log085_transacao("BEGIN")
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     INSERT INTO cdv_controle_781 (controle,
                                   dat_inclusao,
                                   cliente_atendido,
                                   cliente_fatur,
                                   tip_cliente,
                                   tip_contrato,
                                   apolice,
                                   ramo_ativ,
                                   sistema,
                                   cliente_ligacao,
                                   controle_pai,
                                   encerrado,
                                   tip_processo)
                           VALUES (mr_cdv_controle_781.controle,
                                   mr_cdv_controle_781.dat_inclusao,
                                   mr_cdv_controle_781.cliente_atendido,
                                   mr_cdv_controle_781.cliente_fatur,
                                   mr_cdv_controle_781.tip_cliente,
                                   mr_cdv_controle_781.tip_contrato,
                                   mr_cdv_controle_781.apolice,
                                   mr_cdv_controle_781.ramo_ativ,
                                   mr_cdv_controle_781.sistema,
                                   mr_cdv_controle_781.cliente_ligacao,
                                   mr_cdv_controle_781.controle_pai,
                                   mr_cdv_controle_781.encerrado,
                                   mr_cdv_controle_781.tip_processo)
     WHENEVER ERROR STOP

     IF sqlca.sqlcode = 0 THEN

        INITIALIZE l_where_audit TO NULL
        LET l_where_audit =  " cdv_controle_781.controle = '", mr_cdv_controle_781.controle CLIPPED, "' "
        CALL cdv2008_grava_auditoria(l_where_audit, "I", 0)

        WHENEVER ERROR CONTINUE
        CALL log085_transacao("COMMIT")
        WHENEVER ERROR STOP

        MESSAGE "Inclusão efetuada com sucesso. "
        LET m_ies_cons = FALSE
     ELSE
        WHENEVER ERROR CONTINUE
        CALL log085_transacao("ROLLBACK")
        WHENEVER ERROR STOP

        CALL log003_err_sql("INCLUSAO","cdv_controle_781")
     END IF
  ELSE
     LET mr_cdv_controle_781r.* = mr_cdv_controle_781.*
     CALL cdv2008_exibe_dados()
     ERROR " Inclusão cancelada. "
  END IF
END FUNCTION

#----------------------------------------#
 FUNCTION cdv2008_entrada_dados(l_funcao)
#----------------------------------------#
 DEFINE l_funcao            CHAR(30),
        l_data_aux          DATE

 CALL log006_exibe_teclas("01 02 03 07",p_versao)
 CURRENT WINDOW IS w_cdv2008

 IF l_funcao = "INCLUSAO" THEN
    LET mr_cdv_controle_781.dat_inclusao = TODAY
    LET mr_cdv_controle_781.encerrado = "N"
    DISPLAY BY NAME mr_cdv_controle_781.dat_inclusao
 END IF

 LET INT_FLAG = 0
 INPUT BY NAME mr_cdv_controle_781.controle,
               mr_cdv_controle_781.sistema, #
               mr_cdv_controle_781.dat_inclusao,
               mr_cdv_controle_781.cliente_atendido,
               mr_cdv_controle_781.cliente_fatur,
               mr_cdv_controle_781.cliente_ligacao, #
               mr_cdv_controle_781.tip_cliente,
               mr_cdv_controle_781.tip_contrato,
               mr_cdv_controle_781.apolice,
               mr_cdv_controle_781.ramo_ativ,
               mr_cdv_controle_781.tip_processo, #
               mr_cdv_controle_781.controle_pai, #
               mr_cdv_controle_781.encerrado WITHOUT DEFAULTS #

    BEFORE FIELD controle
       IF l_funcao = "MODIFICACAO" THEN
          NEXT FIELD dat_inclusao
       END IF

    BEFORE FIELD sistema
       IF l_funcao = "MODIFICACAO" THEN
          NEXT FIELD dat_inclusao
       END IF

    AFTER FIELD sistema #OS462484
      IF  mr_cdv_controle_781.sistema  IS NOT NULL AND mr_cdv_controle_781.sistema  <> " "
      AND mr_cdv_controle_781.controle IS NOT NULL AND mr_cdv_controle_781.controle <> " " THEN
         IF l_funcao = "INCLUSAO" THEN
            IF cdv2008_verifica_controle_sistema() = TRUE THEN
               CALL log0030_mensagem("Controle já cadastrado nesse sistema.","exclamation")
               NEXT FIELD controle
            END IF
            IF cdv2008_verifica_sistema() = FALSE THEN
               CALL log0030_mensagem("Sistema não cadastrado.","exclamation")
               NEXT FIELD sistema
            END IF
         END IF
      END IF

    AFTER FIELD cliente_atendido
       IF  mr_cdv_controle_781.cliente_atendido IS NOT NULL
       AND mr_cdv_controle_781.cliente_atendido <> " " THEN
          IF cdv2008_verifica_cliente_aten(mr_cdv_controle_781.cliente_atendido) THEN
          END IF
       END IF


    AFTER FIELD cliente_fatur
       IF  mr_cdv_controle_781.cliente_fatur IS NOT NULL
       AND mr_cdv_controle_781.cliente_fatur <> " " THEN
         IF NOT cdv2008_verifica_cliente_fatur(mr_cdv_controle_781.cliente_fatur) THEN
           CALL log0030_mensagem("Cliente não cadastrado.","exclamation")
           NEXT FIELD cliente_fatur
         END IF
       ELSE
          DISPLAY '' TO nom_cliente_fatur
       END IF

     AFTER FIELD cliente_ligacao #OS462484
       IF  mr_cdv_controle_781.cliente_ligacao IS NOT NULL
       AND mr_cdv_controle_781.cliente_ligacao <> " " THEN
          IF cdv2008_verifica_cliente_ligacao(mr_cdv_controle_781.cliente_ligacao) THEN
          END IF
       END IF

     AFTER FIELD tip_cliente
       IF  mr_cdv_controle_781.tip_cliente IS NOT NULL
       AND mr_cdv_controle_781.tip_cliente <> " " THEN
         IF NOT cdv2008_verifica_tip_cliente(mr_cdv_controle_781.tip_cliente) THEN
           CALL log0030_mensagem("Tipo de cliente não cadastrado.","exclamation")
           NEXT FIELD tip_cliente
         END IF
       END IF

     AFTER FIELD tip_contrato
       IF  mr_cdv_controle_781.tip_contrato IS NOT NULL
       AND mr_cdv_controle_781.tip_contrato <> " " THEN
         IF NOT cdv2008_verifica_tip_contrato(mr_cdv_controle_781.tip_contrato) THEN
           CALL log0030_mensagem("Tipo de contrato não cadastrado.","exclamation")
           NEXT FIELD tip_contrato
         END IF
       END IF

     AFTER FIELD tip_processo #OS462484
       IF  mr_cdv_controle_781.tip_processo IS NOT NULL
       AND mr_cdv_controle_781.tip_processo <> " " THEN
          IF cdv2008_verifica_tip_processo(mr_cdv_controle_781.tip_processo) THEN
          END IF
       END IF

     AFTER FIELD controle_pai #OS462484
       IF  mr_cdv_controle_781.controle_pai IS NOT NULL
       AND mr_cdv_controle_781.controle_pai <> " " THEN
          IF cdv2008_verifica_controle_pai() = FALSE THEN
             CALL log0030_mensagem("Controle não cadastrado.","exclamation")
             NEXT FIELD controle_pai
          END IF
       END IF
       IF fgl_lastkey() <> FGL_KEYVAL("UP")
       AND FGL_LASTKEY() <> FGL_KEYVAL("LEFT") THEN

          IF  mr_cdv_controle_781.tip_processo = '2'
          AND (mr_cdv_controle_781.controle_pai IS NULL
            OR mr_cdv_controle_781.controle_pai = " ") THEN
                CALL log0030_mensagem("Controle pai obrigatório para este tipo de processo.","exclamation")
                NEXT FIELD controle_pai
          END IF

       END IF


    ON KEY (f1, control-w)
      CALL cdv2008_help()

    ON KEY (control-z, f4)
       CALL cdv2008_popup()

    AFTER INPUT
       IF int_flag = 0 THEN
          IF mr_cdv_controle_781.controle IS NULL
          OR mr_cdv_controle_781.controle = " " THEN
             CALL log0030_mensagem("Controle não informado.","exclamation")
             NEXT FIELD controle
          END IF

          IF mr_cdv_controle_781.sistema IS NULL #OS462484
          OR mr_cdv_controle_781.sistema = " " THEN
             CALL log0030_mensagem("Sistema não informado.","exclamation")
             NEXT FIELD sistema
          END IF

          IF l_funcao = "INCLUSAO" THEN
             IF cdv2008_verifica_controle_sistema() = TRUE THEN
                CALL log0030_mensagem("Controle já cadastrado nesse sistema.","exclamation")
                NEXT FIELD controle
             END IF
          END IF

          IF mr_cdv_controle_781.dat_inclusao IS NULL
          OR mr_cdv_controle_781.dat_inclusao = " " THEN
             CALL log0030_mensagem("Data da inclusão não informada. ","exclamation")
             NEXT FIELD dat_inclusao
          END IF

          IF mr_cdv_controle_781.cliente_atendido IS NULL
          OR mr_cdv_controle_781.cliente_atendido = " " THEN
             CALL log0030_mensagem("Cliente atendido não informado. ","exclamation")
             NEXT FIELD cliente_atendido
          END IF

          IF mr_cdv_controle_781.cliente_fatur IS NULL
          OR mr_cdv_controle_781.cliente_fatur = " " THEN
             CALL log0030_mensagem("Cliente faturamento não informado. ","exclamation")
             NEXT FIELD cliente_fatur
          END IF

          IF mr_cdv_controle_781.cliente_ligacao IS NULL #OS462484
          OR mr_cdv_controle_781.cliente_ligacao = " " THEN
             CALL log0030_mensagem("Cliente ligação não informado. ","exclamation")
             NEXT FIELD cliente_ligacao
          END IF

          IF mr_cdv_controle_781.tip_cliente IS NULL
          OR mr_cdv_controle_781.tip_cliente = " " THEN
             CALL log0030_mensagem("Tipo de cliente não informado. ","exclamation")
             NEXT FIELD tip_cliente
          END IF

          IF mr_cdv_controle_781.tip_contrato IS NULL
          OR mr_cdv_controle_781.tip_contrato = " " THEN
             CALL log0030_mensagem("Tipo de contrato não informado. ","exclamation")
             NEXT FIELD tip_contrato
          END IF

          IF mr_cdv_controle_781.tip_processo IS NULL #OS462484
          OR mr_cdv_controle_781.tip_processo = " " THEN
             CALL log0030_mensagem("Tipo de processo não informado. ","exclamation")
             NEXT FIELD tip_processo
          END IF

          IF  mr_cdv_controle_781.tip_processo = '2'
          AND (mr_cdv_controle_781.controle_pai IS NULL
            OR mr_cdv_controle_781.controle_pai = " ") THEN
                CALL log0030_mensagem("Controle pai obrigatório para este tipo de processo.","exclamation")
                NEXT FIELD controle_pai
          END IF

          IF mr_cdv_controle_781.encerrado IS NULL #OS462484
          OR mr_cdv_controle_781.encerrado = " " THEN
             CALL log0030_mensagem("Não foi informado se o controle esta encerrado. ","exclamation")
             NEXT FIELD encerrado
          END IF

       END IF

  END INPUT

  CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_cdv2008

  IF int_flag = 0 THEN
     RETURN TRUE
  ELSE
     LET int_flag = 0
     RETURN FALSE
  END IF
END FUNCTION

#------------------------------#
 FUNCTION cdv2008_exibe_dados()
#------------------------------#
  CLEAR FORM
  DISPLAY BY NAME mr_cdv_controle_781.*

  IF cdv2008_verifica_cliente_aten(mr_cdv_controle_781.cliente_atendido) THEN
  END IF

  IF cdv2008_verifica_cliente_fatur(mr_cdv_controle_781.cliente_fatur) THEN
  END IF

  IF cdv2008_verifica_tip_cliente(mr_cdv_controle_781.tip_cliente) THEN
  END IF

  IF cdv2008_verifica_tip_contrato(mr_cdv_controle_781.tip_contrato) THEN
  END IF

  IF cdv2008_verifica_cliente_ligacao(mr_cdv_controle_781.cliente_ligacao) THEN #OS462484
  END IF

  IF cdv2008_verifica_tip_processo(mr_cdv_controle_781.tip_processo) THEN #OS462484
  END IF

END FUNCTION

#-----------------------#
 FUNCTION cdv2008_help()
#-----------------------#

  CASE
    WHEN infield(controle)         CALL showhelp(100)
    WHEN infield(dat_inclusao)     CALL showhelp(101)
    WHEN infield(cliente_atendido) CALL showhelp(102)
    WHEN infield(cliente_fatur)    CALL showhelp(103)
    WHEN infield(tip_cliente)      CALL showhelp(104)
    WHEN infield(tip_contrato)     CALL showhelp(107)
    WHEN infield(apolice)          CALL showhelp(105)
    WHEN infield(ramo_ativ)        CALL showhelp(106)
    WHEN infield(sistema)          CALL showhelp(108) #OS462484
    WHEN infield(cliente_ligacao)  CALL showhelp(109) #OS462484
    WHEN infield(tip_processo)     CALL showhelp(110) #OS462484
    WHEN infield(controle_pai)     CALL showhelp(111) #OS462484
    WHEN infield(encerrado)        CALL showhelp(112) #OS462484
 END CASE

END FUNCTION

#------------------------------------#
 FUNCTION cdv2008_cursor_for_update()
#------------------------------------#

  WHENEVER ERROR CONTINUE
   DECLARE cm_cdv_controle CURSOR FOR
    SELECT controle,
           dat_inclusao,
           cliente_atendido,
           cliente_fatur,
           tip_cliente,
           tip_contrato,
           apolice,
           ramo_ativ,
           sistema,
           cliente_ligacao,
           controle_pai,
           encerrado,
           tip_processo
      INTO mr_cdv_controle_781.controle,
           mr_cdv_controle_781.dat_inclusao,
           mr_cdv_controle_781.cliente_atendido,
           mr_cdv_controle_781.cliente_fatur,
           mr_cdv_controle_781.tip_cliente,
           mr_cdv_controle_781.tip_contrato,
           mr_cdv_controle_781.apolice,
           mr_cdv_controle_781.ramo_ativ,
           mr_cdv_controle_781.sistema,
           mr_cdv_controle_781.cliente_ligacao,
           mr_cdv_controle_781.controle_pai,
           mr_cdv_controle_781.encerrado,
           mr_cdv_controle_781.tip_processo
      FROM cdv_controle_781
     WHERE cdv_controle_781.controle = mr_cdv_controle_781.controle
       AND cdv_controle_781.sistema = mr_cdv_controle_781.sistema
       FOR UPDATE
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","cdv_controle_781")
  END IF

  WHENEVER ERROR CONTINUE
  CALL log085_transacao("BEGIN")
  WHENEVER ERROR STOP

  LET m_houve_erro  = FALSE

  WHENEVER ERROR CONTINUE
      OPEN cm_cdv_controle
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("cm_cdv_controle","OPEN")
  END IF

  WHENEVER ERROR CONTINUE
     FETCH cm_cdv_controle
  WHENEVER ERROR STOP

  CASE sqlca.sqlcode
    WHEN    0 RETURN TRUE
    WHEN -250 ERROR " Registro sendo atualizado por outro usuário. Aguarde e tente novamente. "
    WHEN  100 ERROR " Registro não mais existe na tabela. Execute a consulta novamente. "
    OTHERWISE CALL log003_err_sql("LEITURA","cdv_controle_781")
  END CASE

  RETURN FALSE
END FUNCTION

#------------------------------#
 FUNCTION cdv2008_modificacao()
#------------------------------#

 DEFINE l_where_audit    CHAR(1000)

  IF cdv2008_cursor_for_update() THEN
     LET mr_cdv_controle_781r.* = mr_cdv_controle_781.*

     IF cdv2008_entrada_dados("MODIFICACAO")  THEN
           INITIALIZE l_where_audit TO NULL
           LET l_where_audit =  " cdv_controle_781.controle = '", mr_cdv_controle_781.controle CLIPPED, "' "
           CALL cdv2008_grava_auditoria(l_where_audit, "M", 1)

           WHENEVER ERROR CONTINUE
             UPDATE cdv_controle_781
                SET cdv_controle_781.controle         = mr_cdv_controle_781.controle,
                    cdv_controle_781.dat_inclusao     = mr_cdv_controle_781.dat_inclusao,
                    cdv_controle_781.cliente_atendido = mr_cdv_controle_781.cliente_atendido,
                    cdv_controle_781.cliente_fatur    = mr_cdv_controle_781.cliente_fatur,
                    cdv_controle_781.tip_cliente      = mr_cdv_controle_781.tip_cliente,
                    cdv_controle_781.tip_contrato     = mr_cdv_controle_781.tip_contrato,
                    cdv_controle_781.apolice          = mr_cdv_controle_781.apolice,
                    cdv_controle_781.ramo_ativ        = mr_cdv_controle_781.ramo_ativ,
                    cdv_controle_781.sistema          = mr_cdv_controle_781.sistema,
                    cdv_controle_781.cliente_ligacao  = mr_cdv_controle_781.cliente_ligacao,
                    cdv_controle_781.controle_pai     = mr_cdv_controle_781.controle_pai,
                    cdv_controle_781.encerrado        = mr_cdv_controle_781.encerrado,
                    cdv_controle_781.tip_processo     = mr_cdv_controle_781.tip_processo
              WHERE CURRENT OF cm_cdv_controle
           WHENEVER ERROR STOP

           IF sqlca.sqlcode = 0  THEN

              INITIALIZE l_where_audit TO NULL
              LET l_where_audit =  " cdv_controle_781.controle = '", mr_cdv_controle_781.controle CLIPPED, "' "
              CALL cdv2008_grava_auditoria(l_where_audit, "M", 2)

              WHENEVER ERROR CONTINUE
              CALL log085_transacao("COMMIT")
              WHENEVER ERROR STOP

              MESSAGE "Modificação efetuada com sucesso. "
           ELSE

              WHENEVER ERROR CONTINUE
              CALL log085_transacao("ROLLBACK")
              WHENEVER ERROR STOP

              CALL log003_err_sql("UPDATE","cdv_controle_781")
           END IF
           WHENEVER ERROR STOP
     ELSE
        WHENEVER ERROR CONTINUE
        CALL log085_transacao("ROLLBACK")
        WHENEVER ERROR STOP

        LET mr_cdv_controle_781.* = mr_cdv_controle_781r.*

        CALL cdv2008_exibe_dados()
        ERROR " Modificação cancelada. "
     END IF
     WHENEVER ERROR CONTINUE
        CLOSE cm_cdv_controle
     WHENEVER ERROR STOP

  END IF
END FUNCTION

#---------------------------#
 FUNCTION cdv2008_exclusao()
#---------------------------#
 DEFINE l_where_audit    CHAR(1000)

     IF log0040_confirm(5,10,"Confirma exclusão de controle?") THEN
        IF cdv2008_cursor_for_update() THEN

           INITIALIZE l_where_audit TO NULL
           LET l_where_audit =  " cdv_controle_781.controle = '", mr_cdv_controle_781.controle CLIPPED, "' "
           CALL cdv2008_grava_auditoria(l_where_audit, "E", 1)

           WHENEVER ERROR CONTINUE
             DELETE FROM cdv_controle_781
              WHERE CURRENT OF cm_cdv_controle
           WHENEVER ERROR STOP

           IF sqlca.sqlcode = 0  THEN

              CLEAR FORM
              MESSAGE "Exclusão efetuada com sucesso. "
              INITIALIZE mr_cdv_controle_781.* TO NULL

              WHENEVER ERROR CONTINUE
              CALL log085_transacao("COMMIT")
              WHENEVER ERROR STOP

           ELSE
              CALL log003_err_sql("EXCLUSAO","cdv_controle_781")
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
        CLOSE cm_cdv_controle
     WHENEVER ERROR STOP

END FUNCTION

#---------------------------#
 FUNCTION cdv2008_consulta()
#---------------------------#
  DEFINE where_clause, sql_stmt   CHAR(1000)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_cdv2008

  LET mr_cdv_controle_781r.* = mr_cdv_controle_781.*

  INITIALIZE mr_cdv_controle_781.* TO NULL
  CLEAR FORM

  LET INT_FLAG = 0
  CONSTRUCT BY NAME where_clause ON cdv_controle_781.controle,
                                    cdv_controle_781.sistema, #
                                    cdv_controle_781.dat_inclusao,
                                    cdv_controle_781.cliente_atendido,
                                    cdv_controle_781.cliente_fatur,
                                    cdv_controle_781.cliente_ligacao, #
                                    cdv_controle_781.tip_cliente,
                                    cdv_controle_781.tip_contrato,
                                    cdv_controle_781.apolice,
                                    cdv_controle_781.ramo_ativ,
                                    cdv_controle_781.tip_processo, #
                                    cdv_controle_781.controle_pai, #
                                    cdv_controle_781.encerrado #

    ON KEY (f1, control-w)
      CALL cdv2008_help()

    ON KEY (control-z, f4)
       CALL cdv2008_popup()

   END CONSTRUCT

  CALL log006_exibe_teclas("02 09",p_versao)
  CURRENT WINDOW IS w_cdv2008

  IF int_flag THEN
     LET int_flag = 0
     INITIALIZE mr_cdv_controle_781.* TO NULL
     CALL cdv2008_exibe_dados()
     ERROR "Consulta cancelada."
     RETURN
  END IF

  LET sql_stmt2 = "SELECT controle, sistema, dat_inclusao, cliente_atendido,",
                        " cliente_fatur, cliente_ligacao, tip_cliente, tip_contrato,",
                        " apolice, ramo_ativ, tip_processo, controle_pai, encerrado",
                   " FROM cdv_controle_781 WHERE ", where_clause CLIPPED,
                  " ORDER BY controle "

  LET sql_stmt2 = sql_stmt2 CLIPPED

  WHENEVER ERROR CONTINUE
   PREPARE var_query1 FROM sql_stmt2
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("var_query1","PREPARE")
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_cdv_forn_fun2 SCROLL CURSOR WITH HOLD FOR var_query1
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","cq_cdv_forn_fun2")
  END IF

  WHENEVER ERROR CONTINUE
      OPEN cq_cdv_forn_fun2
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("cq_cdv_forn_fun2","OPEN")
  END IF

  WHENEVER ERROR CONTINUE
     FETCH cq_cdv_forn_fun2 INTO mr_cdv_controle_781.controle,
                                 mr_cdv_controle_781.sistema,
                                 mr_cdv_controle_781.dat_inclusao,
                                 mr_cdv_controle_781.cliente_atendido,
                                 mr_cdv_controle_781.cliente_fatur,
                                 mr_cdv_controle_781.cliente_ligacao,
                                 mr_cdv_controle_781.tip_cliente,
                                 mr_cdv_controle_781.tip_contrato,
                                 mr_cdv_controle_781.apolice,
                                 mr_cdv_controle_781.ramo_ativ,
                                 mr_cdv_controle_781.tip_processo,
                                 mr_cdv_controle_781.controle_pai,
                                 mr_cdv_controle_781.encerrado
  WHENEVER ERROR STOP

  IF sqlca.sqlcode = NOTFOUND THEN
     #ERROR " "
     CALL log0030_mensagem("Argumentos de pesquisa não encontrados. ","exclamation")

     LET m_ies_cons = FALSE
     RETURN
  ELSE
     CALL cdv2008_exibe_dados()
     MESSAGE "Consulta efetuada com sucesso." ATTRIBUTE(REVERSE)
     LET m_ies_cons = TRUE
     RETURN
  END IF

  CALL cdv2008_exibe_dados()

END FUNCTION

#------------------------------------#
 FUNCTION cdv2008_paginacao(l_funcao)
#------------------------------------#
 DEFINE l_funcao            CHAR(20)

 IF m_ies_cons THEN
    LET mr_cdv_controle_781r.* = mr_cdv_controle_781.*

    WHILE TRUE
       CASE
          WHEN l_funcao = "SEGUINTE" FETCH NEXT     cq_cdv_forn_fun2 INTO mr_cdv_controle_781.controle,
                                                                          mr_cdv_controle_781.sistema,
                                                                          mr_cdv_controle_781.dat_inclusao,
                                                                          mr_cdv_controle_781.cliente_atendido,
                                                                          mr_cdv_controle_781.cliente_fatur,
                                                                          mr_cdv_controle_781.cliente_ligacao,
                                                                          mr_cdv_controle_781.tip_cliente,
                                                                          mr_cdv_controle_781.tip_contrato,
                                                                          mr_cdv_controle_781.apolice,
                                                                          mr_cdv_controle_781.ramo_ativ,
                                                                          mr_cdv_controle_781.tip_processo,
                                                                          mr_cdv_controle_781.controle_pai,
                                                                          mr_cdv_controle_781.encerrado
          WHEN l_funcao = "ANTERIOR" FETCH PREVIOUS cq_cdv_forn_fun2 INTO mr_cdv_controle_781.controle,
                                                                          mr_cdv_controle_781.sistema,
                                                                          mr_cdv_controle_781.dat_inclusao,
                                                                          mr_cdv_controle_781.cliente_atendido,
                                                                          mr_cdv_controle_781.cliente_fatur,
                                                                          mr_cdv_controle_781.cliente_ligacao,
                                                                          mr_cdv_controle_781.tip_cliente,
                                                                          mr_cdv_controle_781.tip_contrato,
                                                                          mr_cdv_controle_781.apolice,
                                                                          mr_cdv_controle_781.ramo_ativ,
                                                                          mr_cdv_controle_781.tip_processo,
                                                                          mr_cdv_controle_781.controle_pai,
                                                                          mr_cdv_controle_781.encerrado
       END CASE

       IF sqlca.sqlcode = NOTFOUND  THEN
          ERROR " Não existem mais itens nesta direção. "
          LET mr_cdv_controle_781.* = mr_cdv_controle_781r.*
          EXIT WHILE
       END IF

       WHENEVER ERROR CONTINUE
         SELECT controle,
                dat_inclusao,
                cliente_atendido,
                cliente_fatur,
                tip_cliente,
                tip_contrato,
                apolice,
                ramo_ativ,
                sistema,
                cliente_ligacao,
                controle_pai,
                encerrado,
                tip_processo
           INTO mr_cdv_controle_781.controle,
                mr_cdv_controle_781.dat_inclusao,
                mr_cdv_controle_781.cliente_atendido,
                mr_cdv_controle_781.cliente_fatur,
                mr_cdv_controle_781.tip_cliente,
                mr_cdv_controle_781.tip_contrato,
                mr_cdv_controle_781.apolice,
                mr_cdv_controle_781.ramo_ativ,
                mr_cdv_controle_781.sistema,
                mr_cdv_controle_781.cliente_ligacao,
                mr_cdv_controle_781.controle_pai,
                mr_cdv_controle_781.encerrado,
                mr_cdv_controle_781.tip_processo
           FROM cdv_controle_781
          WHERE cdv_controle_781.controle = mr_cdv_controle_781.controle
            AND cdv_controle_781.sistema  = mr_cdv_controle_781.sistema
       WHENEVER ERROR STOP

       IF sqlca.sqlcode = 0 THEN
          IF  mr_cdv_controle_781.controle = mr_cdv_controle_781r.controle
          AND mr_cdv_controle_781.sistema  = mr_cdv_controle_781r.sistema THEN
          ELSE
            CALL cdv2008_exibe_dados()
            EXIT WHILE
          END IF
       END IF

    END WHILE
 ELSE
    CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")
 END IF
END FUNCTION

#------------------------#
 FUNCTION cdv2008_lista()
#------------------------#
 DEFINE l_msg      CHAR(200),
        l_tot_reg  INTEGER

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
          LET g_comand_cdv_rel = g_comand_cdv_rel CLIPPED, "cdv2008.tmp"
          START REPORT cdv2008_relat TO g_comand_cdv_rel
       ELSE
          START REPORT cdv2008_relat TO p_nom_arquivo
       END IF
    ELSE
       IF p_ies_impressao = "S" THEN
          START REPORT cdv2008_relat TO PIPE p_nom_arquivo
       ELSE
          START REPORT cdv2008_relat TO p_nom_arquivo
       END IF
    END IF

    WHENEVER ERROR CONTINUE
     DECLARE cq_rel CURSOR FOR
      SELECT controle,
             dat_inclusao,
             cliente_atendido,
             cliente_fatur,
             tip_cliente,
             tip_contrato,
             apolice,
             ramo_ativ,
             sistema,
             cliente_ligacao,
             controle_pai,
             encerrado,
             tip_processo
        FROM cdv_controle_781
       ORDER BY controle
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("DECLARE","cq_rel")
    END IF

    WHENEVER ERROR CONTINUE
        OPEN cq_rel
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("CQ_REL","OPEN")
    END IF

    WHENEVER ERROR CONTINUE
       FETCH cq_rel INTO mr_cdv_controle_781.*
    WHENEVER ERROR STOP

    IF sqlca.sqlcode = NOTFOUND THEN
    ELSE
       WHILE sqlca.sqlcode <> NOTFOUND
         OUTPUT TO REPORT cdv2008_relat(mr_cdv_controle_781.*)
         LET l_tot_reg = l_tot_reg + 1
         WHENEVER ERROR CONTINUE
            FETCH cq_rel  INTO mr_cdv_controle_781.*
         WHENEVER ERROR STOP
         IF sqlca.sqlcode <> 0 THEN
         END IF
       END WHILE

       LET g_ies_cons = TRUE
    END IF

    WHENEVER ERROR CONTINUE
       CLOSE cq_rel
        FREE cq_rel
    WHENEVER ERROR STOP

    FINISH REPORT cdv2008_relat

    IF l_tot_reg > 0 THEN
       IF  g_ies_ambiente = "W"
       AND p_ies_impressao = "S" THEN
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
    ELSE
       CLEAR FORM
       CALL log0030_mensagem("Não existem dados para serem listados.","exclamation")
    END IF
 END IF

END FUNCTION

#-----------------------------------------#
 REPORT cdv2008_relat(mr_cdv_controle_781)
#-----------------------------------------#
   DEFINE mr_cdv_controle_781      RECORD LIKE cdv_controle_781.*

   DEFINE p_primeira_vez    SMALLINT,
          p_ies_situacao    CHAR(09)

   OUTPUT LEFT     MARGIN 0
          TOP      MARGIN 0
          BOTTOM   MARGIN 0
          PAGE     LENGTH 66

 FORMAT

   PAGE HEADER
   PRINT log5211_retorna_configuracao(PAGENO,66,123) CLIPPED;
      PRINT COLUMN 001, m_den_empresa CLIPPED
      PRINT COLUMN 001, "CDV2008",
            COLUMN 057, "CONTROLE (SINISTRO)",
            COLUMN 164, "FL.",
            COLUMN 167, pageno USING "##&"
      PRINT COLUMN 131, "EXTRAIDO EM ", today, " AS ", time, " HRS."

      SKIP 1 LINE

      PRINT COLUMN 001, "CONTROLE             SISTEMA INCLUSAO   CLIENTE ATENDIDO CLIENTE FATURAR CLIENTE LIGACAO TIPO CLIENTE TIPO CONTRATO APOLICE         RAMO ATIVIDADE TIP PROCESSO ENCERRADO"
      PRINT COLUMN 001, "-------------------- ------- ---------- ---------------- --------------- --------------- ------------ ------------- --------------- -------------- ------------ ---------"

   LET p_primeira_vez = TRUE

   ON EVERY ROW
      PRINT COLUMN 001, mr_cdv_controle_781.controle         USING "###################&",
            COLUMN 022, mr_cdv_controle_781.sistema,
            COLUMN 030, mr_cdv_controle_781.dat_inclusao,
            COLUMN 041, mr_cdv_controle_781.cliente_atendido CLIPPED,
            COLUMN 058, mr_cdv_controle_781.cliente_fatur    CLIPPED,
            COLUMN 074, mr_cdv_controle_781.cliente_ligacao  CLIPPED,
            COLUMN 090, mr_cdv_controle_781.tip_cliente      CLIPPED,
            COLUMN 103, mr_cdv_controle_781.tip_contrato     CLIPPED,
            COLUMN 117, mr_cdv_controle_781.apolice          USING "#############&&",
            COLUMN 133, mr_cdv_controle_781.ramo_ativ        USING "#############&",
            COLUMN 148, mr_cdv_controle_781.tip_processo     USING "&",
            COLUMN 161, mr_cdv_controle_781.encerrado

  ON LAST ROW
    LET g_last_row = TRUE

  PAGE TRAILER
      IF g_last_row = TRUE THEN
        PRINT "* * * ULTIMA FOLHA * * *"
      ELSE
        PRINT " "
      END IF

END REPORT

#--------------------------------------------#
 FUNCTION cdv2008_verifica_controle_sistema()
#--------------------------------------------#

  WHENEVER ERROR CONTINUE
    SELECT controle
      FROM cdv_controle_781
     WHERE controle = mr_cdv_controle_781.controle
       AND sistema  = mr_cdv_controle_781.sistema
  WHENEVER ERROR STOP

  IF sqlca.sqlcode = 0 THEN
    RETURN TRUE
  ELSE
    RETURN FALSE
  END IF

END FUNCTION

#----------------------------------#
 FUNCTION cdv2008_verifica_sistema()
#----------------------------------#
  DEFINE l_sistema   CHAR(02)

  LET l_sistema = mr_cdv_controle_781.sistema[1,2]

  WHENEVER ERROR CONTINUE
    SELECT finalidade
      FROM cdv_finalidade_781
     WHERE finalidade[1,2] = l_sistema
  WHENEVER ERROR STOP

  IF sqlca.sqlcode = 0
  OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
  ELSE
    RETURN FALSE
  END IF

END FUNCTION

#----------------------------------------#
 FUNCTION cdv2008_verifica_controle_pai()
#----------------------------------------#

  WHENEVER ERROR CONTINUE
    SELECT controle
      FROM cdv_controle_781
     WHERE controle  = mr_cdv_controle_781.controle_pai
       AND encerrado = "N"
  WHENEVER ERROR STOP

  IF sqlca.sqlcode = 0 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
  ELSE
    RETURN FALSE
  END IF

END FUNCTION

#---------------------------------------------------------------#
 FUNCTION cdv2008_grava_auditoria(l_where_audit, l_opcao, l_num)
#---------------------------------------------------------------#
 DEFINE l_where_audit CHAR(1000),
        l_opcao       CHAR(01),
        l_num         SMALLINT

 IF NOT cdv0801_geracao_auditoria(p_cod_empresa, "cdv_controle_781", l_where_audit, l_opcao, "CDV2008", l_num) THEN
    CALL log003_err_sql('INSERT','cdv_controle_781')
 END IF

 END FUNCTION

#----------------------------------------------------------#
 FUNCTION cdv2008_verifica_cliente_aten(l_cliente_atendido)
#----------------------------------------------------------#

  DEFINE l_cliente_atendido LIKE clientes.cod_cliente,
         l_nom_cliente      LIKE clientes.nom_cliente

  WHENEVER ERROR CONTINUE
    SELECT nom_cliente
      INTO l_nom_cliente
      FROM clientes
     WHERE cod_cliente = l_cliente_atendido
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET l_nom_cliente = " "
  END IF

  DISPLAY l_nom_cliente TO nom_cliente_atendido

  RETURN TRUE

END FUNCTION

#--------------------------------------------------------#
 FUNCTION cdv2008_verifica_cliente_fatur(l_cliente_fatur)
#--------------------------------------------------------#
 DEFINE l_cliente_fatur        LIKE clientes.cod_cliente,
        l_nom_cliente          LIKE clientes.nom_cliente

 WHENEVER ERROR CONTINUE
   SELECT nom_cliente
     INTO l_nom_cliente
     FROM clientes
    WHERE cod_cliente   = l_cliente_fatur
 WHENEVER ERROR STOP

 DISPLAY l_nom_cliente TO nom_cliente_fatur

 IF sqlca.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#------------------------------------------------------------#
 FUNCTION cdv2008_verifica_cliente_ligacao(l_cliente_ligacao)
#------------------------------------------------------------#

  DEFINE l_cliente_ligacao LIKE clientes.cod_cliente,
         l_nom_cliente     LIKE clientes.nom_cliente

  WHENEVER ERROR CONTINUE
    SELECT nom_cliente
      INTO l_nom_cliente
      FROM clientes
     WHERE cod_cliente = l_cliente_ligacao
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET l_nom_cliente = " "
  END IF

  DISPLAY l_nom_cliente TO nom_cliente_ligacao

  RETURN TRUE

END FUNCTION

#------------------------------------------------------#
 FUNCTION cdv2008_verifica_tip_processo(l_tip_processo)
#------------------------------------------------------#

  DEFINE l_tip_processo     LIKE cdv_controle_781.tip_processo,
         l_den_tip_processo CHAR(17)

  CASE l_tip_processo
    WHEN "0"  LET l_den_tip_processo = "Normal"
    WHEN "1"  LET l_den_tip_processo = "Reincidencia"
    WHEN "2"  LET l_den_tip_processo = "Desmembramento"
    WHEN "3"  LET l_den_tip_processo = "Extensao"
    WHEN "4"  LET l_den_tip_processo = "Servicos Internos"
    WHEN "5"  LET l_den_tip_processo = "Atendimento Extra"
    WHEN "6"  LET l_den_tip_processo = "Servicos Externos"
    OTHERWISE LET l_den_tip_processo = " "
  END CASE

  DISPLAY l_den_tip_processo TO den_tip_processo

  RETURN TRUE

END FUNCTION

#------------------------#
 FUNCTION cdv2008_popup()
#------------------------#
 DEFINE l_cliente      LIKE clientes.cod_cliente,
        l_tip_cli      CHAR(10),
        l_tip_con      CHAR(10),
        l_tip_processo CHAR(01),
        l_sistema      CHAR(05)

 CASE
  WHEN infield(sistema)
    LET l_sistema = log009_popup(5,25,"SISTEMA",
                                      "cdv_finalidade_781",
                                      "finalidade",
                                      "des_finalidade",
                                      "cdv2006",
                                      "N","")
    CALL log006_exibe_teclas("01 02 03 07",p_versao)
    CURRENT WINDOW IS w_cdv2008

    IF l_sistema IS NOT NULL  THEN
       LET mr_cdv_controle_781.sistema = l_sistema
       DISPLAY BY NAME mr_cdv_controle_781.sistema
    END IF

  WHEN infield(cliente_atendido)
    LET l_cliente  = vdp372_popup_cliente()
    CALL log006_exibe_teclas("01 02 03 07",p_versao)
    CURRENT WINDOW IS w_cdv2008

    IF l_cliente IS NOT NULL  THEN
       LET mr_cdv_controle_781.cliente_atendido = l_cliente
       DISPLAY BY NAME mr_cdv_controle_781.cliente_atendido
    END IF

  WHEN infield(cliente_fatur)
    LET l_cliente  = vdp372_popup_cliente()
    CALL log006_exibe_teclas("01 02 03 07",p_versao)
    CURRENT WINDOW IS w_cdv2008

    IF l_cliente IS NOT NULL  THEN
       LET mr_cdv_controle_781.cliente_fatur = l_cliente
       DISPLAY BY NAME mr_cdv_controle_781.cliente_fatur
    END IF

  WHEN infield(cliente_ligacao) #OS462484
    LET l_cliente  = vdp372_popup_cliente()
    CALL log006_exibe_teclas("01 02 03 07",p_versao)
    CURRENT WINDOW IS w_cdv2008

    IF l_cliente IS NOT NULL THEN
       LET mr_cdv_controle_781.cliente_ligacao = l_cliente
       DISPLAY BY NAME mr_cdv_controle_781.cliente_ligacao
    END IF

  WHEN infield(tip_cliente)
    LET l_tip_cli  = log009_popup(5,25,"TIPO CLIENTE",
                                       "vntpcliente",
                                       "cod",
                                       "descr",
                                       "",
                                       "N","")
    CALL log006_exibe_teclas("01 02 03 07",p_versao)
    CURRENT WINDOW IS w_cdv2008

    IF l_tip_cli IS NOT NULL THEN
       LET mr_cdv_controle_781.tip_cliente = l_tip_cli
       DISPLAY BY NAME mr_cdv_controle_781.tip_cliente
    END IF

  WHEN infield(tip_contrato)
    LET l_tip_con  = log009_popup(5,25,"TIPO CONTRATO",
                                       "vntpcontr",
                                       "cod",
                                       "descr",
                                       "",
                                       "N","")
    CALL log006_exibe_teclas("01 02 03 07",p_versao)
    CURRENT WINDOW IS w_cdv2008

    IF l_tip_con IS NOT NULL  THEN
       LET mr_cdv_controle_781.tip_contrato = l_tip_con
       DISPLAY BY NAME mr_cdv_controle_781.tip_contrato
    END IF

  WHEN infield(tip_processo) #OS462484
    INITIALIZE l_tip_processo TO NULL
    LET l_tip_processo = log0830_list_box(12,42, "0 {Normal}, 1 {Reincidencia}, 2 {Desmembramento}, 3 {Extensão}, 4 {Serviços INternos}, 5 {Atendimento Extra}, 6 {Serviços Externos}")

    IF  l_tip_processo IS NOT NULL
    AND l_tip_processo <> ' ' THEN
       LET mr_cdv_controle_781.tip_processo = l_tip_processo
       DISPLAY mr_cdv_controle_781.tip_processo TO tip_processo
    END IF

    CALL log006_exibe_teclas("01 02 03 07",p_versao)
    CURRENT WINDOW IS w_cdv2008

 END CASE

 END FUNCTION

#----------------------------------------------------#
 FUNCTION cdv2008_verifica_tip_cliente(l_tip_cliente)
#----------------------------------------------------#
 DEFINE l_tip_cliente   CHAR(10),
        l_des_cliente   CHAR(40)

 INITIALIZE l_des_cliente TO NULL

 WHENEVER ERROR CONTINUE
   SELECT descr
     INTO l_des_cliente
     FROM vntpcliente
    WHERE cod = l_tip_cliente
 WHENEVER ERROR STOP

 DISPLAY l_des_cliente TO descr_cli

 IF sqlca.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE
END FUNCTION

#------------------------------------------------------#
 FUNCTION cdv2008_verifica_tip_contrato(l_tip_contrato)
#------------------------------------------------------#
 DEFINE l_tip_contrato   CHAR(10),
        l_des_contrato   CHAR(40)

 INITIALIZE l_des_contrato TO NULL

 WHENEVER ERROR CONTINUE
   SELECT descr
     INTO l_des_contrato
     FROM vntpcontr
    WHERE cod   = l_tip_contrato
 WHENEVER ERROR STOP

 DISPLAY l_des_contrato TO descr_con

 IF sqlca.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE
END FUNCTION

#-------------------------------#
 FUNCTION cdv2008_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/programas/cdv2008.4gl $|$Revision: 3 $|$Date: 23/12/11 12:22 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION