###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: CONTROLE DE VIAGENS                                   #
# PROGRAMA: CDV2010                                               #
# MODULOS.: CDV2010 - LOG0010 - LOG0050 - LOG0060 - LOG1300       #
#           LOG0100                                               #
# OBJETIVO: CONSULTA VIAGENS                                      #
# AUTOR...: FABIANO PEDRO ESPINDOLA                               #
# DATA....: 28.07.2005                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_ies_impressao        CHAR(01),
         p_nom_arquivo          CHAR(100),
         p_user                 LIKE usuario.nom_usuario,
         p_status               SMALLINT

  DEFINE g_ies_ambiente         CHAR(1),
         g_ies_grafico          SMALLINT

  DEFINE sql_stmt             CHAR(3000),
         where_clause         CHAR(1000)

  DEFINE p_versao            CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

END GLOBALS

# MODULARES
   DEFINE m_dat_pard_ini   LIKE cdv_solic_viagem.dat_hor_partida
   DEFINE m_dat_pard_final LIKE cdv_solic_viagem.dat_hor_partida
   DEFINE m_dat_retn_ini   LIKE cdv_solic_viagem.dat_hor_retorno
   DEFINE m_dat_retn_final LIKE cdv_solic_viagem.dat_hor_retorno
   DEFINE m_dat_aux        CHAR(19)
   DEFINE m_caminho        CHAR(150),
          m_comando        CHAR(100)

  DEFINE ma_tipo    ARRAY[300] OF CHAR(02),
         m_curr     SMALLINT,
         m_curr1    SMALLINT,
         m_sc_curr  SMALLINT,
         m_cont     SMALLINT,
         m_ind      SMALLINT

  DEFINE ma_num_ad  ARRAY[300] OF DECIMAL(6,0)

  DEFINE ma_viagens ARRAY[300] OF RECORD
                                   empresa          CHAR(02),
                                   viagem           LIKE cdv_solic_adto_781.viagem,
                                   status           CHAR(03),
                                   valor            LIKE cdv_solic_adto_781.val_adto_viagem,
                                   dat_prev         DATE,
                                   dat_pgto         DATE,
                                   despesas         LIKE cdv_solic_adto_781.val_adto_viagem,
                                   creditos         LIKE cdv_solic_adto_781.val_adto_viagem,
                                   controle         LIKE cdv_solic_viag_781.controle,
                                   td               LIKE tipo_despesa.nom_tip_despesa,
                                   saldo_viag       LIKE cdv_solic_adto_781.val_adto_viagem,
                                   cliente_aten     LIKE clientes.nom_cliente,
                                   viagem_receb     LIKE cdv_dev_transf_781.viagem_receb,
                                   controle_receb   LIKE cdv_dev_transf_781.controle_receb,
                                   cliente_fatur    LIKE clientes.nom_cliente,
                                   dat_partida      DATE,
                                   dat_retorno      DATE
                                   END RECORD

   DEFINE m_saldo_geral            LIKE cdv_solic_adto_781.val_adto_viagem

   DEFINE ma_cod_tip_despesa   ARRAY[300] OF DECIMAL(4,0)

   DEFINE mr_tela        RECORD
                         viagem               LIKE cdv_solic_viag_781.viagem,
                         controle             LIKE cdv_solic_viag_781.controle,
                         viajante             LIKE cdv_solic_viag_781.viajante,
                         nom_funcionario      LIKE funcionario.nom_funcionario,
                         cliente_atendido     LIKE cdv_solic_viag_781.cliente_atendido,
                         nom_cliente_aten     LIKE clientes.nom_cliente,
                         cliente_fatur        LIKE cdv_solic_viag_781.cliente_fatur,
                         nom_cliente_fat      LIKE clientes.nom_cliente,
                         dat_hr_pard_ini      DATE,
                         dat_hr_pard_final    DATE,
                         dat_hr_retn_ini      DATE,
                         dat_hr_retn_final    DATE,
                         status_acer_viagem   CHAR(01),
                         den_status           CHAR(50)
                         END RECORD

   DEFINE m_empresa      LIKE empresa.cod_empresa,
          m_viagem       LIKE cdv_solic_viag_781.viagem,
          m_controle     LIKE cdv_solic_viag_781.controle,
          m_cliente_aten LIKE clientes.nom_cliente,
          m_cliente_fat  LIKE clientes.nom_cliente,
          m_data_part    DATE,
          m_data_ret     DATE


   DEFINE m_matricula_viajante LIKE cdv_solic_viagem.matricula_viajante

# END MODULARES

MAIN

     CALL log0180_conecta_usuario()

LET p_versao = "CDV2010-05.10.01p" #Favor nao alterar esta linha (SUPORTE)

  WHENEVER ERROR CONTINUE
  CALL log1400_isolation()
  SET LOCK MODE TO WAIT 120
  WHENEVER ERROR STOP

  INITIALIZE p_cod_empresa,
             p_user,
             ma_viagens,
             ma_tipo,
             ma_num_ad,
             ma_cod_tip_despesa,
             p_status,
             m_comando TO NULL

  INITIALIZE m_empresa,
             m_viagem,       m_controle,
             m_cliente_aten, m_cliente_fat,
             m_data_part,    m_data_ret TO NULL

  DEFER INTERRUPT
  CALL log140_procura_caminho("cdv2010.iem") RETURNING m_comando

  OPTIONS
    FIELD ORDER UNCONSTRAINED,
    HELP    FILE m_comando,
    NEXT    KEY control-f,
    PREVIOUS KEY control-b

  CALL log001_acessa_usuario("CDV","LOGERP")
       RETURNING p_status, p_cod_empresa, p_user

  CALL cdv2010_controle()

END MAIN

#--------------------------#
 FUNCTION cdv2010_controle()
#--------------------------#
   DEFINE l_den_reduz         CHAR(10),
          l_ies_ha_registros  SMALLINT


   CALL log130_procura_caminho("cdv2010") RETURNING m_comando
   OPEN WINDOW w_cdv2010 AT 2,2  WITH FORM m_comando
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   CALL log006_exibe_teclas("01 02 07", p_versao)

   CURRENT WINDOW IS w_cdv2010

   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPÇÃO"
    COMMAND "Consultar"  "Consulta as viagens conforme parâmetros informados."
      HELP 004
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV","CDV2010","CO") THEN
         IF cdv2010_informa_dados() THEN
            IF NOT cdv2010_consulta_viagens() THEN
               CALL log0030_mensagem('Argumentos de pesquisa não encontrados.','exclamation')
            END IF
         END IF
      END IF

    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR m_comando
      RUN m_comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando

    COMMAND "Fim"        "Retorna ao menu anterior."
      HELP 008
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU

  WHENEVER ERROR CONTINUE
  CLOSE WINDOW w_cdv2010
#  CLOSE WINDOW w_cdv20101
  WHENEVER ERROR CONTINUE

END FUNCTION

#--------------------------------#
 FUNCTION cdv2010_informa_dados()
#--------------------------------#
   DEFINE l_cont    SMALLINT

   INITIALIZE mr_tela.* TO NULL

   INITIALIZE m_empresa,
              m_viagem,       m_controle,
              m_cliente_aten, m_cliente_fat,
              m_data_part,    m_data_ret TO NULL

   CALL cdv2010_busca_viajante()
        RETURNING mr_tela.viajante,
                  mr_tela.nom_funcionario
   LET INT_FLAG = 0
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   DISPLAY BY NAME mr_tela.viajante
   DISPLAY BY NAME mr_tela.nom_funcionario
   LET mr_tela.status_acer_viagem = '6'
   DISPLAY BY NAME mr_tela.status_acer_viagem

   CALL log006_exibe_teclas("01 02 07" , p_versao)
   CURRENT WINDOW IS w_cdv2010

   INPUT mr_tela.viagem, mr_tela.controle, mr_tela.viajante,
         mr_tela.nom_funcionario, mr_tela.cliente_atendido, mr_tela.nom_cliente_aten,
         mr_tela.cliente_fatur, mr_tela.nom_cliente_fat, mr_tela.dat_hr_pard_ini,
         mr_tela.dat_hr_pard_final, mr_tela.dat_hr_retn_ini, mr_tela.dat_hr_retn_final,
         mr_tela.status_acer_viagem, mr_tela.den_status       WITHOUT DEFAULTS
         FROM
         viagem, controle, viajante, nom_funcionario, cliente_atendido,
         nom_cliente_aten, cliente_fatur, nom_cliente_fat, dat_hr_pard_ini,
         dat_hr_pard_final, dat_hr_retn_ini, dat_hr_retn_final, status_acer_viagem,
         den_status

       BEFORE FIELD viajante
         IF g_ies_grafico THEN
            --# CALL fgl_dialog_setkeylabel('Control-Z','Zoom')
         ELSE
            DISPLAY '( Zoom )' AT 03,68
         END IF

       AFTER FIELD viajante
         IF  mr_tela.viajante IS  NOT NULL
         AND mr_tela.viajante <> " " THEN
            IF NOT cdv2010_verifica_viajante(mr_tela.viajante) THEN
               CALL log0030_mensagem('Vijante não cadastrado.','exclamation')
               NEXT FIELD viajante
            END IF
         END IF

         IF g_ies_grafico THEN
            --# CALL fgl_dialog_setkeylabel('Control-Z','')
         ELSE
            DISPLAY '--------' AT 03,68
         END IF

       BEFORE FIELD cliente_atendido
         IF g_ies_grafico THEN
            --# CALL fgl_dialog_setkeylabel('Control-Z','Zoom')
         ELSE
            DISPLAY '( Zoom )' AT 03,68
         END IF

       AFTER FIELD cliente_atendido
          IF  mr_tela.cliente_atendido IS NOT NULL
          AND mr_tela.cliente_atendido <> " " THEN
             IF NOT cdv2010_verifica_cliente(mr_tela.cliente_atendido, "ATEN") THEN
                CALL log0030_mensagem('Cliente não cadastrado.','exclamation')
                NEXT FIELD cliente_atendido
             END IF
          ELSE
             LET mr_tela.nom_cliente_aten = NULL
             DISPLAY BY NAME mr_tela.nom_cliente_aten
          END IF

          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel('Control-Z','')
          ELSE
             DISPLAY '--------' AT 03,68
          END IF

       BEFORE FIELD cliente_fatur
         IF g_ies_grafico THEN
            --# CALL fgl_dialog_setkeylabel('Control-Z','Zoom')
         ELSE
            DISPLAY '( Zoom )' AT 03,68
         END IF

       AFTER FIELD cliente_fatur
         IF  mr_tela.cliente_fatur IS NOT NULL
         AND mr_tela.cliente_fatur <> " " THEN
            IF NOT cdv2010_verifica_cliente(mr_tela.cliente_fatur, "FAT") THEN
               CALL log0030_mensagem('Cliente não cadastrado.','exclamation')
               NEXT FIELD cliente_fatur
            END IF
          ELSE
             LET mr_tela.nom_cliente_fat = NULL
             DISPLAY BY NAME mr_tela.nom_cliente_fat
         END IF
         IF g_ies_grafico THEN
            --# CALL fgl_dialog_setkeylabel('Control-Z','')
         ELSE
            DISPLAY '--------' AT 03,68
         END IF

       AFTER FIELD dat_hr_pard_final
           IF  mr_tela.dat_hr_pard_ini IS NOT NULL
           AND mr_tela.dat_hr_pard_final IS NULL THEN
               CALL log0030_mensagem('Data final não informada.','exclamation')
               NEXT FIELD dat_hr_pard_final
           END IF

           IF  mr_tela.dat_hr_pard_ini IS NULL
           AND mr_tela.dat_hr_pard_final IS NOT NULL THEN
               CALL log0030_mensagem('Data inicial não informada informada.','exclamation')
               NEXT FIELD dat_hr_pard_ini
           END IF

           IF mr_tela.dat_hr_pard_ini > mr_tela.dat_hr_pard_final THEN
               CALL log0030_mensagem('Data inicial posterior a data final.','exclamation')
               NEXT FIELD dat_hr_pard_ini
           END IF

       AFTER FIELD dat_hr_retn_final
           IF  mr_tela.dat_hr_retn_ini IS NOT NULL
           AND mr_tela.dat_hr_retn_final IS NULL THEN
               CALL log0030_mensagem('Data final não informada.','exclamation')
               NEXT FIELD dat_hr_retn_final
           END IF

           IF  mr_tela.dat_hr_retn_ini IS NULL
           AND mr_tela.dat_hr_retn_final IS NOT NULL THEN
               CALL log0030_mensagem('Data inicial não informada. ','exclamation')
               NEXT FIELD dat_hr_retn_ini
           END IF

           IF mr_tela.dat_hr_retn_ini > mr_tela.dat_hr_retn_final THEN
               CALL log0030_mensagem('Data inicial posterior a data final. ','exclamation')
               NEXT FIELD dat_hr_retn_ini
           END IF

       AFTER FIELD status_acer_viagem
          IF  mr_tela.status_acer_viagem IS NOT NULL
          AND mr_tela.status_acer_viagem <> " " THEN
             IF NOT cdv2010_verifica_status(mr_tela.status_acer_viagem) THEN

             END IF
          END IF

       AFTER INPUT
          IF INT_FLAG THEN
             LET INT_FLAG = TRUE
             EXIT INPUT
          ELSE
             IF mr_tela.viajante IS NULL
             OR mr_tela.viajante = " " THEN
                CALL log0030_mensagem("Viajante não informado.","exclamation")
                NEXT FIELD viajante
             END IF

             IF mr_tela.dat_hr_pard_ini IS NOT NULL AND
                mr_tela.dat_hr_pard_final IS NULL THEN
                 CALL log0030_mensagem('Data final de partida não informada.','exclamation')
                 NEXT FIELD dat_hr_pard_final
             END IF
             IF mr_tela.dat_hr_pard_ini IS NULL AND
                mr_tela.dat_hr_pard_final IS NOT NULL THEN
                 CALL log0030_mensagem('Data inicial de partida não informada.','exclamation')
                 NEXT FIELD dat_hr_pard_ini
             END IF
             IF mr_tela.dat_hr_pard_ini > mr_tela.dat_hr_pard_final THEN
                 CALL log0030_mensagem('Data inicial posterior a data final. ','exclamation')
                 NEXT FIELD dat_hr_pard_ini
             END IF

             IF mr_tela.dat_hr_retn_ini IS NOT NULL AND
                mr_tela.dat_hr_retn_final IS NULL THEN
                 CALL log0030_mensagem('Data final de retorno não informada. ','exclamation')
                 NEXT FIELD dat_hr_retn_final
             END IF
             IF mr_tela.dat_hr_retn_ini IS NULL AND
                mr_tela.dat_hr_retn_final IS NOT NULL THEN
                 CALL log0030_mensagem('Data inicial de retorno não informada.','exclamation')
                 NEXT FIELD dat_hr_retn_ini
             END IF
             IF mr_tela.dat_hr_retn_ini > mr_tela.dat_hr_retn_final THEN
                 CALL log0030_mensagem('Data inicial posterior a data final. ','exclamation')
                 NEXT FIELD dat_hr_retn_ini
             END IF

             IF  mr_tela.status_acer_viagem <> '1'
             AND mr_tela.status_acer_viagem <> '2'
             AND mr_tela.status_acer_viagem <> '3'
             AND mr_tela.status_acer_viagem <> '4'
             AND mr_tela.status_acer_viagem <> '5'
             AND mr_tela.status_acer_viagem <> '6' THEN
                 CALL log0030_mensagem("Status de viagem não cadastrado.","exclamation")
                 NEXT FIELD status_acer_viagem
             END IF

          END IF

       ON KEY (control-z, f4)
         CALL cdv2010_popup()

       ON KEY(f1, control-w)
          #lds IF NOT LOG_logix_versao5() THEN
          #lds CONTINUE INPUT
          #lds END IF
         CALL cdv2010_help()

   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_cdv2010

   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      ERROR "Consulta cancelada."
      RETURN FALSE
   END IF

   RETURN TRUE

 END FUNCTION

#------------------------------------------------------#
 FUNCTION cdv2010_verifica_cliente(l_cliente, l_tip_cli)
#------------------------------------------------------#
   DEFINE l_cliente     LIKE clientes.cod_cliente,
          l_tip_cli     CHAR(10),
          l_nom_cliente LIKE clientes.nom_cliente

    INITIALIZE l_nom_cliente TO NULL

    WHENEVER ERROR CONTINUE
      SELECT nom_cliente
        INTO l_nom_cliente
        FROM clientes
       WHERE cod_cliente = l_cliente
    WHENEVER ERROR STOP

    IF l_tip_cli = "ATEN" THEN
       DISPLAY l_nom_cliente TO nom_cliente_aten
    ELSE
       DISPLAY l_nom_cliente TO nom_cliente_fat
    END IF

    IF SQLCA.SQLCODE = 0 THEN
       RETURN TRUE
    ELSE
       RETURN FALSE
    END IF

 END FUNCTION

#----------------------------------------------#
 FUNCTION cdv2010_verifica_viajante(l_viajante)
#----------------------------------------------#
 DEFINE l_matricula       LIKE cdv_info_viajante.matricula,
        l_nom_funcionario LIKE usuarios.nom_funcionario,
        l_viajante        INTEGER,
        l_cod_funcio      LIKE cdv_fornecedor_fun.cod_funcio,
        l_cod_fornecedor  LIKE fornecedor.cod_fornecedor

   INITIALIZE l_nom_funcionario TO NULL

   WHENEVER ERROR CONTINUE
     SELECT matricula
       FROM cdv_info_viajante
      WHERE cdv_info_viajante.empresa   = p_cod_empresa
        AND cdv_info_viajante.matricula = l_viajante
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      RETURN FALSE
   END IF

   LET l_cod_funcio = l_viajante

   WHENEVER ERROR CONTINUE
   SELECT cod_fornecedor
     INTO l_cod_fornecedor
     FROM cdv_fornecedor_fun
    WHERE cod_funcio = l_cod_funcio
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      WHENEVER ERROR CONTINUE
      SELECT raz_social
        INTO l_nom_funcionario
        FROM fornecedor
       WHERE cod_fornecedor = l_cod_fornecedor
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE
      END IF
   END IF

   DISPLAY l_nom_funcionario TO nom_funcionario
   LET mr_tela.nom_funcionario = l_nom_funcionario

   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION cdv2010_help()
#-----------------------#
  CASE
    WHEN INFIELD(viagem)             CALL showhelp(101)
    WHEN INFIELD(viajante)           CALL showhelp(102)
    WHEN INFIELD(cliente_atendido)   CALL showhelp(103)
    WHEN INFIELD(dat_hr_pard_ini)    CALL showhelp(104)
    WHEN INFIELD(dat_hr_pard_final)  CALL showhelp(104)
    WHEN INFIELD(dat_hr_retn_ini)    CALL showhelp(105)
    WHEN INFIELD(dat_hr_retn_final)  CALL showhelp(105)
    WHEN INFIELD(controle)           CALL showhelp(107)
    WHEN INFIELD(cliente_fatur)      CALL showhelp(108)
    WHEN INFIELD(status_acer_viagem) CALL showhelp(109)
  END CASE

 END FUNCTION

#-----------------------------------------#
 FUNCTION cdv2010_seleciona_viagens_solic()
#-----------------------------------------#
 DEFINE lr_w_cdv2010    RECORD
                        empresa          CHAR(02),
                        viagem           LIKE cdv_solic_adto_781.viagem,
                        status           CHAR(03),
                        valor            LIKE cdv_solic_adto_781.val_adto_viagem,
                        dat_prev         DATE,
                        dat_pgto         DATE,
                        despesas         LIKE cdv_solic_adto_781.val_adto_viagem,
                        creditos         LIKE cdv_solic_adto_781.val_adto_viagem,
                        controle         LIKE cdv_solic_viag_781.controle,
                        td               LIKE tipo_despesa.nom_tip_despesa,
                        saldo_viag       LIKE cdv_solic_adto_781.val_adto_viagem,
                        cliente_aten     LIKE clientes.nom_cliente,
                        viagem_receb     like cdv_dev_transf_781.viagem_receb,
                        controle_receb   like cdv_dev_transf_781.controle_receb,
                        cliente_fatur    LIKE clientes.nom_cliente,
                        dat_partida      DATE,
                        dat_retorno      DATE,
                        tipo             CHAR(02),
                        num_ad           DECIMAL(6,0)
                        END RECORD

 DEFINE lr_solic        RECORD LIKE cdv_solic_viag_781.*

 DEFINE l_data_hr       CHAR(20),
        l_achou_solic   SMALLINT,
        l_status        CHAR(01)

 INITIALIZE lr_w_cdv2010.*, lr_solic.*,
            sql_stmt,       l_data_hr TO NULL

 LET sql_stmt = " SELECT empresa, viagem, controle, dat_hr_emis_solic, viajante, ",
                " finalidade_viagem, cc_viajante, cc_debitar, cliente_atendido, ",
                " cliente_fatur, empresa_atendida, filial_atendida, trajeto_principal, ",
                " dat_hor_partida, dat_hor_retorno, motivo_viagem ",
                " FROM cdv_solic_viag_781 ",
                " WHERE empresa = '", p_cod_empresa, "' ",
                " AND viajante = ", mr_tela.viajante, " "

 IF  mr_tela.controle IS NOT NULL
 AND mr_tela.controle <> " " THEN
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND controle = '", mr_tela.controle CLIPPED, "' "
 END IF

 IF  mr_tela.viagem IS NOT NULL
 AND mr_tela.viagem <> " " THEN
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND viagem = ", mr_tela.viagem CLIPPED, " "
 END IF

 IF  mr_tela.cliente_atendido IS NOT NULL
 AND mr_tela.cliente_atendido <> " " THEN
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND cliente_atendido = '", mr_tela.cliente_atendido CLIPPED, "' "
 END IF

 IF  mr_tela.cliente_fatur IS NOT NULL
 AND mr_tela.cliente_fatur <> " " THEN
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND cliente_fatur = '", mr_tela.cliente_fatur CLIPPED, "' "
 END IF

 IF  mr_tela.dat_hr_pard_ini IS NOT NULL
 AND mr_tela.dat_hr_pard_ini <> " " THEN
    INITIALIZE l_data_hr TO NULL
    LET l_data_hr = cdv2010_prepara_data(mr_tela.dat_hr_pard_ini, "INI")
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND dat_hor_partida >= '", l_data_hr CLIPPED, "' "
 END IF

 IF  mr_tela.dat_hr_pard_final IS NOT NULL
 AND mr_tela.dat_hr_pard_final <> " " THEN
    INITIALIZE l_data_hr TO NULL
    LET l_data_hr = cdv2010_prepara_data(mr_tela.dat_hr_pard_final, "FIM")
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND dat_hor_partida  <= '", l_data_hr CLIPPED, "' "
 END IF

 IF  mr_tela.dat_hr_retn_ini IS NOT NULL
 AND mr_tela.dat_hr_retn_ini <> " " THEN
    INITIALIZE l_data_hr TO NULL
    LET l_data_hr = cdv2010_prepara_data(mr_tela.dat_hr_retn_ini, "INI")
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND dat_hor_retorno >= '", l_data_hr CLIPPED, "' "
 END IF

 IF  mr_tela.dat_hr_retn_final IS NOT NULL
 AND mr_tela.dat_hr_retn_final <> " " THEN
    INITIALIZE l_data_hr TO NULL
    LET l_data_hr = cdv2010_prepara_data(mr_tela.dat_hr_retn_final, "FIM")
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND dat_hor_retorno  <= '", l_data_hr CLIPPED, "' "
 END IF

 LET sql_stmt = sql_stmt CLIPPED,
    " ORDER BY viagem "

 WHENEVER ERROR CONTINUE
  PREPARE var_query FROM sql_stmt
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("PREPARE","VAR_QUERY")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 DECLARE cq_solic CURSOR FOR var_query
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_SOLIC")
    RETURN FALSE
 END IF

 LET l_achou_solic = FALSE

 WHENEVER ERROR CONTINUE
 FOREACH cq_solic INTO lr_solic.*
 WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","CQ_SOLIC")
       RETURN FALSE
    END IF

    LET l_achou_solic = TRUE

    LET m_empresa  = lr_solic.empresa
    LET m_viagem   = lr_solic.viagem
    LET m_controle = lr_solic.controle

    LET l_status = cdv2010_busca_status_acerto(lr_solic.empresa, lr_solic.viagem)

    CASE l_status
       WHEN '1' LET lr_w_cdv2010.status = 'PEN'
       WHEN '2' LET lr_w_cdv2010.status = 'INI'
       WHEN '3' LET lr_w_cdv2010.status = 'FIN'
       WHEN '4' LET lr_w_cdv2010.status = 'LIB'
    END CASE

    LET lr_w_cdv2010.empresa         = lr_solic.empresa
    LET lr_w_cdv2010.viagem          = lr_solic.viagem
    LET lr_w_cdv2010.valor           = 0
    LET lr_w_cdv2010.dat_prev        = ''
    LET lr_w_cdv2010.dat_pgto        = ''
    LET lr_w_cdv2010.despesas        = 0
    LET lr_w_cdv2010.creditos        = 0
    LET lr_w_cdv2010.controle        = lr_solic.controle
    LET lr_w_cdv2010.td              = cdv2010_busca_den_tip_desp(lr_solic.empresa)
    LET lr_w_cdv2010.saldo_viag      = 0
    LET lr_w_cdv2010.cliente_aten    = cdv2010_busca_den_cliente(lr_solic.cliente_atendido)
    LET lr_w_cdv2010.viagem_receb    = ''
    LET lr_w_cdv2010.controle_receb  = ''
    LET lr_w_cdv2010.cliente_fatur   = cdv2010_busca_den_cliente(lr_solic.cliente_fatur)
    LET lr_w_cdv2010.dat_partida     = lr_solic.dat_hor_partida
    LET lr_w_cdv2010.dat_retorno     = lr_solic.dat_hor_retorno
    LET lr_w_cdv2010.tipo            = 'SO'
    LET lr_w_cdv2010.num_ad          = 0

    LET m_cliente_aten               = lr_w_cdv2010.cliente_aten
    LET m_cliente_fat                = lr_w_cdv2010.cliente_fatur
    LET m_data_part                  = lr_w_cdv2010.dat_partida
    LET m_data_ret                   = lr_w_cdv2010.dat_retorno

    WHENEVER ERROR CONTINUE
    INSERT INTO w_cdv2010 VALUES (lr_w_cdv2010.*)
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("INSERT","W_CDV2010")
       RETURN FALSE
    END IF

    IF NOT cdv2010_seleciona_viagens_adto() THEN
       RETURN FALSE
    END IF

 END FOREACH
 WHENEVER ERROR CONTINUE
 FREE cq_solic
 WHENEVER ERROR STOP

 IF l_achou_solic = FALSE THEN
    RETURN FALSE
 END IF

 RETURN TRUE
 END FUNCTION

#----------------------------------------#
 FUNCTION cdv2010_seleciona_viagens_adto()
#----------------------------------------#
 DEFINE lr_w_cdv2010    RECORD
                        empresa          CHAR(02),
                        viagem           LIKE cdv_solic_adto_781.viagem,
                        status           CHAR(03),
                        valor            LIKE cdv_solic_adto_781.val_adto_viagem,
                        dat_prev         DATE,
                        dat_pgto         DATE,
                        despesas         LIKE cdv_solic_adto_781.val_adto_viagem,
                        creditos         LIKE cdv_solic_adto_781.val_adto_viagem,
                        controle         LIKE cdv_solic_viag_781.controle,
                        td               LIKE tipo_despesa.nom_tip_despesa,
                        saldo_viag       LIKE cdv_solic_adto_781.val_adto_viagem,
                        cliente_aten     LIKE clientes.nom_cliente,
                        viagem_receb     like cdv_dev_transf_781.viagem_receb,
                        controle_receb   like cdv_dev_transf_781.controle_receb,
                        cliente_fatur    LIKE clientes.nom_cliente,
                        dat_partida      DATE,
                        dat_retorno      DATE,
                        tipo             CHAR(02),
                        num_ad           DECIMAL(6,0)
                        END RECORD

 DEFINE lr_adto        RECORD LIKE cdv_solic_adto_781.*

 DEFINE l_data_hr      CHAR(20),
        l_achou_adto   SMALLINT,
        l_status       CHAR(01)

 INITIALIZE lr_w_cdv2010.*, lr_adto.*,
            sql_stmt,       l_data_hr TO NULL

 LET sql_stmt = " SELECT empresa,    ",
                " viagem,            ",
                " sequencia_adto,    ",
                " dat_adto_viagem,   ",
                " val_adto_viagem,   ",
                " forma_adto_viagem, ",
                " banco,             ",
                " agencia,           ",
                " cta_corrente,      ",
                " num_ad_adto_viagem ",
                " FROM cdv_solic_adto_781 ",
                " WHERE empresa = '", m_empresa, "' ",
                " AND viagem    = ",  m_viagem, " ",
                " ORDER BY sequencia_adto "

 WHENEVER ERROR CONTINUE
 PREPARE var_query1 FROM sql_stmt
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("PREPARE","VAR_QUERY1")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 DECLARE cq_adto CURSOR FOR var_query1
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_ADTO")
 END IF

 LET l_achou_adto = FALSE

 WHENEVER ERROR CONTINUE
 FOREACH cq_adto INTO lr_adto.*
 WHENEVER ERROR STOP
    LET l_achou_adto = TRUE

    LET l_status = cdv2010_busca_status_acerto(lr_adto.empresa, lr_adto.viagem)

    IF l_status = '1' THEN
       LET lr_w_cdv2010.status          = 'PEN'
    END IF
    IF l_status = '2' THEN
       LET lr_w_cdv2010.status          = 'INI'
    END IF
    IF l_status = '3' THEN
       LET lr_w_cdv2010.status          = 'FIN'
    END IF
    IF l_status = '4' THEN
       LET lr_w_cdv2010.status          = 'LIB'
    END IF

    LET lr_w_cdv2010.empresa         = lr_adto.empresa
    LET lr_w_cdv2010.viagem          = lr_adto.viagem
#    LET lr_w_cdv2010.status          = 'PEN'
    LET lr_w_cdv2010.valor           = lr_adto.val_adto_viagem
    LET lr_w_cdv2010.dat_prev        = cdv2010_busca_dat_prev(lr_adto.num_ad_adto_viagem)
    LET lr_w_cdv2010.dat_pgto        = cdv2010_busca_dat_pgto(lr_adto.num_ad_adto_viagem)
    LET lr_w_cdv2010.despesas        = lr_adto.val_adto_viagem
    LET lr_w_cdv2010.creditos        = 0
    LET lr_w_cdv2010.controle        = m_controle
    LET lr_w_cdv2010.td              = cdv2010_busca_den_tip_desp_adto(lr_adto.empresa)
    LET lr_w_cdv2010.saldo_viag      = lr_w_cdv2010.despesas - lr_w_cdv2010.creditos
    LET lr_w_cdv2010.cliente_aten    = m_cliente_aten
    LET lr_w_cdv2010.viagem_receb    = ''
    LET lr_w_cdv2010.controle_receb  = ''
    LET lr_w_cdv2010.cliente_fatur   = m_cliente_fat
    LET lr_w_cdv2010.dat_partida     = m_data_part
    LET lr_w_cdv2010.dat_retorno     = m_data_ret
    LET lr_w_cdv2010.tipo            = 'AD'
    LET lr_w_cdv2010.num_ad          = lr_adto.num_ad_adto_viagem

    WHENEVER ERROR CONTINUE
    INSERT INTO w_cdv2010 VALUES (lr_w_cdv2010.*)
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("INSERT","W_CDV2010")
       RETURN FALSE
    END IF

 END FOREACH
 WHENEVER ERROR CONTINUE
 FREE cq_adto
 WHENEVER ERROR STOP

 RETURN TRUE
END FUNCTION


#----------------------------------------#
 FUNCTION cdv2010_seleciona_viagens_acer()
#----------------------------------------#
 DEFINE lr_w_cdv2010    RECORD
                        empresa          CHAR(02),
                        viagem           LIKE cdv_solic_adto_781.viagem,
                        status           CHAR(03),
                        valor            LIKE cdv_solic_adto_781.val_adto_viagem,
                        dat_prev         DATE,
                        dat_pgto         DATE,
                        despesas         LIKE cdv_solic_adto_781.val_adto_viagem,
                        creditos         LIKE cdv_solic_adto_781.val_adto_viagem,
                        controle         LIKE cdv_solic_viag_781.controle,
                        td               LIKE tipo_despesa.nom_tip_despesa,
                        saldo_viag       LIKE cdv_solic_adto_781.val_adto_viagem,
                        cliente_aten     LIKE clientes.nom_cliente,
                        viagem_receb     LIKE cdv_dev_transf_781.viagem_receb,
                        controle_receb   LIKE cdv_dev_transf_781.controle_receb,
                        cliente_fatur    LIKE clientes.nom_cliente,
                        dat_partida      DATE,
                        dat_retorno      DATE,
                        tipo             CHAR(02),
                        num_ad           DECIMAL(6,0)
                        END RECORD

 DEFINE lr_acer        RECORD LIKE cdv_acer_viag_781.*

 DEFINE l_data_hr       CHAR(20),
        l_achou_acer   SMALLINT

 INITIALIZE lr_w_cdv2010.*, lr_acer.*,
            sql_stmt,       l_data_hr TO NULL

 LET sql_stmt = " SELECT empresa, viagem, controle, dat_hr_emis_relat,  ",
                " status_acer_viagem, viajante, finalidade_viagem, cc_viajante, ",
                " cc_debitar, ad_acerto_conta, cliente_destino, cliente_debitar, ",
                " empresa_atendida, filial_atendida, trajeto_principal, ",
                " dat_hor_partida, dat_hor_retorno, motivo_viagem ",
                " FROM cdv_acer_viag_781 ",
                " WHERE empresa = '",p_cod_empresa, "' ",
                " AND viajante  = ", mr_tela.viajante , " "

 IF  mr_tela.controle IS NOT NULL
 AND mr_tela.controle <> " " THEN
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND cdv_acer_viag_781.controle = '", mr_tela.controle CLIPPED, "' "
 END IF

 IF  mr_tela.viagem IS NOT NULL
 AND mr_tela.viagem <> " " THEN
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND cdv_acer_viag_781.viagem = ", mr_tela.viagem CLIPPED, " "
 END IF

 IF  mr_tela.cliente_atendido IS NOT NULL
 AND mr_tela.cliente_atendido <> " " THEN
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND cdv_acer_viag_781.cliente_destino = '", mr_tela.cliente_atendido CLIPPED, "' "
 END IF

 IF  mr_tela.cliente_fatur IS NOT NULL
 AND mr_tela.cliente_fatur <> " " THEN
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND cdv_acer_viag_781.cliente_debitar = '", mr_tela.cliente_fatur CLIPPED, "' "
 END IF

 IF  mr_tela.dat_hr_pard_ini IS NOT NULL
 AND mr_tela.dat_hr_pard_ini <> " " THEN
    INITIALIZE l_data_hr TO NULL
    LET l_data_hr = cdv2010_prepara_data(mr_tela.dat_hr_pard_ini, "INI")
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND cdv_acer_viag_781.dat_hor_partida >= '", l_data_hr CLIPPED, "' "
 END IF

 IF  mr_tela.dat_hr_pard_final IS NOT NULL
 AND mr_tela.dat_hr_pard_final <> " " THEN
    INITIALIZE l_data_hr TO NULL
    LET l_data_hr = cdv2010_prepara_data(mr_tela.dat_hr_pard_final, "FIM")
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND cdv_acer_viag_781.dat_hor_partida  <= '", l_data_hr CLIPPED, "' "
 END IF

 IF  mr_tela.dat_hr_retn_ini IS NOT NULL
 AND mr_tela.dat_hr_retn_ini <> " " THEN
    INITIALIZE l_data_hr TO NULL
    LET l_data_hr = cdv2010_prepara_data(mr_tela.dat_hr_retn_ini, "INI")
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND cdv_acer_viag_781.dat_hor_retorno >= '", l_data_hr CLIPPED, "' "
 END IF

 IF  mr_tela.dat_hr_retn_final IS NOT NULL
 AND mr_tela.dat_hr_retn_final <> " " THEN
    INITIALIZE l_data_hr TO NULL
    LET l_data_hr = cdv2010_prepara_data(mr_tela.dat_hr_retn_final, "FIM")
    LET sql_stmt = sql_stmt CLIPPED,
                   " AND cdv_acer_viag_781.dat_hor_retorno  <= '", l_data_hr CLIPPED, "' "
 END IF

 IF  mr_tela.status_acer_viagem IS NOT NULL
 AND mr_tela.status_acer_viagem <> " " THEN
    CASE mr_tela.status_acer_viagem
       WHEN '3'
          LET sql_stmt = sql_stmt CLIPPED,
                         " AND cdv_acer_viag_781.status_acer_viagem IN ('1','2') "
       WHEN '6'
          LET sql_stmt = sql_stmt CLIPPED,
                         " AND cdv_acer_viag_781.status_acer_viagem IN ('1','2','3','4') "
        OTHERWISE
          LET sql_stmt = sql_stmt CLIPPED,
                         " AND cdv_acer_viag_781.status_acer_viagem = '", mr_tela.status_acer_viagem CLIPPED, "' "
    END CASE
 END IF

 WHENEVER ERROR CONTINUE
 PREPARE var_query3 FROM sql_stmt
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("PREPARE","VAR_QUERY3")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 DECLARE cq_acer CURSOR FOR var_query3
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_ACER")
    RETURN FALSE
 END IF

 LET l_achou_acer = FALSE

 WHENEVER ERROR CONTINUE
 FOREACH cq_acer INTO lr_acer.*
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("FOREACH","CQ_ACER")
    RETURN FALSE
 END IF

    LET l_achou_acer = TRUE

    LET lr_w_cdv2010.empresa         = lr_acer.empresa
    LET lr_w_cdv2010.viagem          = lr_acer.viagem
    IF lr_acer.status_acer_viagem = '1' THEN
       LET lr_w_cdv2010.status       = 'PEN'
    END IF
    IF lr_acer.status_acer_viagem = '2' THEN
       LET lr_w_cdv2010.status       = 'INI'
    END IF
    IF lr_acer.status_acer_viagem = '3' THEN
       LET lr_w_cdv2010.status       = 'FIN'
    END IF
    IF lr_acer.status_acer_viagem = '4' THEN
       LET lr_w_cdv2010.status       = 'LIB'
    END IF
    LET lr_w_cdv2010.valor           = cdv2010_busca_somatorio()
    LET lr_w_cdv2010.dat_prev        = cdv2010_busca_dat_prev(lr_acer.ad_acerto_conta)
    LET lr_w_cdv2010.dat_pgto        = cdv2010_busca_dat_pgto(lr_acer.ad_acerto_conta)
    LET lr_w_cdv2010.despesas        = cdv2010_busca_somatorio()
    LET lr_w_cdv2010.creditos        = 0
    LET lr_w_cdv2010.saldo_viag      = lr_w_cdv2010.despesas - lr_w_cdv2010.creditos
    LET lr_w_cdv2010.controle        = m_controle
    IF lr_w_cdv2010.saldo_viag < 0 THEN
       LET lr_w_cdv2010.td              = cdv2010_busca_den_tip_desp_acer_neg(lr_acer.empresa)
    ELSE
       LET lr_w_cdv2010.td              = cdv2010_busca_den_tip_desp_acer_pos(lr_acer.empresa)
    END IF
    LET lr_w_cdv2010.cliente_aten    = m_cliente_aten
    LET lr_w_cdv2010.viagem_receb    = cdv2010_busca_viagem_receb()
    LET lr_w_cdv2010.controle_receb  = cdv2010_busca_controle_receb()
    LET lr_w_cdv2010.cliente_fatur   = m_cliente_fat
    LET lr_w_cdv2010.dat_partida     = m_data_part
    LET lr_w_cdv2010.dat_retorno     = m_data_ret
    LET lr_w_cdv2010.tipo            = 'AC'
    LET lr_w_cdv2010.num_ad          = lr_acer.ad_acerto_conta

    WHENEVER ERROR CONTINUE
    INSERT INTO w_cdv2010 VALUES (lr_w_cdv2010.*)
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("INSERT","W_CDV2010")
       RETURN FALSE
    END IF

#    EXIT FOREACH
 END FOREACH
 WHENEVER ERROR CONTINUE
 FREE cq_acer
 WHENEVER ERROR STOP

 RETURN TRUE
END FUNCTION

#-------------------------------#
 FUNCTION cdv2010_mostra_dados()
#-------------------------------#
   DEFINE l_empresa           CHAR(02)

 CALL log006_exibe_teclas("01 02 07", p_versao)
 CALL log130_procura_caminho("cdv20101") RETURNING m_comando
 OPEN WINDOW w_cdv20101 AT 2,2  WITH FORM m_comando
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   CALL cdv2010_carrega_array()

   IF m_ind = 1 THEN
       RETURN
   END IF

   CALL log006_exibe_teclas("01 02 03 07", p_versao)
   CURRENT WINDOW IS w_cdv20101

   MESSAGE 'Para Consultar, Aprovantes e Adiantamentos utilize o botão ZOOM.' ATTRIBUTE(REVERSE)
   DISPLAY mr_tela.nom_funcionario TO viajante
   DISPLAY m_saldo_geral     TO saldo_geral

   CALL SET_COUNT(m_ind-1)
   DISPLAY ARRAY ma_viagens TO sr_cdv2010.*

     ON KEY (control-z, f4)
       CALL cdv2010_zoom_registro()
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z','Zoom')
       ELSE
          DISPLAY '( Zoom )' AT 03,68
       END IF

   END DISPLAY

   MESSAGE ''

   IF INT_FLAG THEN
       LET INT_FLAG = FALSE
   END IF

   CLOSE WINDOW w_cdv20101

END FUNCTION

#-------------------------------#
 FUNCTION cdv2010_zoom_registro()
#-------------------------------#
   DEFINE l_ad                 DECIMAL(6,0),
          l_num_viagem         LIKE cdv_solic_viagem.num_viagem,
	         l_fornecedor         LIKE cdv_fornecedor_fun.cod_fornecedor,
	         l_aux1               CHAR(10),
          l_tip_desp           LIKE cdv_par_ctr_viagem.tip_desp_acer_cta,
          l_tip_desp_acer_reem LIKE cdv_par_ctr_viagem.tip_desp_acer_cta,
          l_num_ad_acer_conta  LIKE cdv_relat_viagem.num_ad_acer_conta,
          l_viajante           LIKE cdv_solic_viag_781.viajante,
          l_cod_funcio         LIKE cdv_fornecedor_fun.cod_funcio

   LET m_curr   = ARR_CURR()

   MENU 'OPÇÃO'
     COMMAND 'Consultar' 'Consulta solicitação/acerto da viagem.'
        HELP 012
        MESSAGE ''

        CASE ma_tipo[m_curr]
           WHEN 'SO'
              CALL log120_procura_caminho("cdv2001") RETURNING m_comando
              LET m_comando = m_comando CLIPPED, " ", ma_viagens[m_curr].viagem, " ",
                               ma_viagens[m_curr].empresa
           WHEN 'AD'
              CALL log120_procura_caminho("cdv2002") RETURNING m_comando
              LET m_comando = m_comando CLIPPED, " ", ma_viagens[m_curr].empresa,
                                                   " ", ma_viagens[m_curr].viagem
           WHEN 'AC'
              CALL log120_procura_caminho("cdv2000") RETURNING m_comando
              LET m_comando = m_comando CLIPPED, " ", "1", " ",
                               "CO", " ", ma_viagens[m_curr].empresa, " ", ma_viagens[m_curr].viagem
        END CASE
        RUN m_comando

     COMMAND 'Aprovantes'      'Consulta aprovantes da viagem.'
        HELP 010
        MESSAGE ''
        LET m_curr    = ARR_CURR()
        LET m_sc_curr  = SCR_LINE()
        LET m_cont     = ARR_COUNT()
        LET m_curr1   = m_curr

        IF ma_num_ad[m_curr] <> 0 THEN
           CALL log120_procura_caminho("cdv0063") RETURNING m_comando
           LET m_comando = m_comando  CLIPPED, " ", ma_num_ad[m_curr],
                            " ", ma_viagens[m_curr].empresa, " ", "2"
        ELSE
           CALL log120_procura_caminho("cdv0063") RETURNING m_comando
           LET m_comando = m_comando  CLIPPED, " ", ma_num_ad[m_curr],
                            " ", ma_viagens[m_curr].empresa, " ", "1"
        END IF
        RUN m_comando
#        EXIT MENU

     COMMAND 'aDiantamentos'   'Consulta adiantamentos pendentes do viajante.'
        HELP 011
        MESSAGE ''
        LET m_curr = ARR_CURR()

        WHENEVER ERROR CONTINUE
        SELECT viajante
          INTO l_viajante
          FROM cdv_solic_viag_781
         WHERE cdv_solic_viag_781.empresa = ma_viagens[m_curr].empresa
           AND cdv_solic_viag_781.viagem  = ma_viagens[m_curr].viagem
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('LEITURA','cdv_solic_viag_781')
           RETURN
        END IF

        LET l_cod_funcio = l_viajante

        WHENEVER ERROR CONTINUE
        DECLARE cq_fornec CURSOR FOR
        SELECT cdv_fornecedor_fun.cod_fornecedor
          FROM cdv_fornecedor_fun
         WHERE cdv_fornecedor_fun.cod_funcio = l_cod_funcio
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("DECLARE","CQ_FORNEC")
            EXIT MENU
        END IF

        WHENEVER ERROR CONTINUE
        FOREACH cq_fornec INTO l_fornecedor
        WHENEVER ERROR STOP
           EXIT FOREACH
        END FOREACH
        FREE cq_fornec

        IF cdv0064_popup_adiant(l_fornecedor) THEN
        ELSE
           CALL log0030_mensagem("Não existe AD pendente.","exclamation")
        END IF

        CURRENT WINDOW IS w_cdv20101
        LET INT_FLAG = FALSE

     COMMAND 'Fim'    'Retorna ao menu anterior.'
        MESSAGE ''
        EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

   END MENU

END FUNCTION

#-------------------------------#
 FUNCTION cdv2010_carrega_array()
#-------------------------------#

  INITIALIZE ma_viagens, ma_tipo, ma_num_ad TO NULL

  WHENEVER ERROR CONTINUE
  DECLARE cq_array CURSOR FOR
  SELECT *
    FROM w_cdv2010
    ORDER BY viagem, tipo DESC
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","CQ_ARRAY")
     RETURN
  END IF

  LET m_ind         = 1
  LET m_saldo_geral = 0
  WHENEVER ERROR CONTINUE
  FOREACH cq_array INTO ma_viagens[m_ind].*, ma_tipo[m_ind], ma_num_ad[m_ind]
  WHENEVER ERROR STOP

     LET m_saldo_geral = m_saldo_geral + ma_viagens[m_ind].saldo_viag
     LET m_ind         = m_ind         + 1
     IF m_ind = 300 THEN
        CALL log0030_mensagem('Nem todas as viagens serão mostradas.','exclamation')
        EXIT FOREACH
     END IF

  END FOREACH

  WHENEVER ERROR CONTINUE
  FREE cq_array
  WHENEVER ERROR STOP

END FUNCTION

#------------------------#
 FUNCTION cdv2010_popup()
#------------------------#
  DEFINE l_funcio   LIKE cdv_solic_viag_781.viajante,
         l_cliente  LIKE cdv_solic_viag_781.cliente_atendido,
         l_list_box CHAR(150),
         l_status   CHAR(01)

  CASE
    WHEN INFIELD(viajante)
      LET l_funcio = cdv0033_popup_matricula_viaj(p_cod_empresa)
      CALL log006_exibe_teclas("01 02 07" , p_versao)
      CURRENT WINDOW IS w_cdv2010
      IF l_funcio IS NOT NULL THEN
         LET mr_tela.viajante = l_funcio
         DISPLAY BY NAME mr_tela.viajante
         IF cdv2010_verifica_viajante(mr_tela.viajante) THEN
         END IF
      END IF

    WHEN INFIELD(cliente_atendido)
      LET l_cliente = vdp372_popup_cliente()
      CALL log006_exibe_teclas("01 02 07" , p_versao)
      CURRENT WINDOW IS w_cdv2010

      IF l_cliente IS NOT NULL THEN
         LET mr_tela.cliente_atendido = l_cliente
         DISPLAY BY NAME mr_tela.cliente_atendido
      END IF

    WHEN INFIELD(cliente_fatur)
      LET l_cliente = vdp372_popup_cliente()
      CALL log006_exibe_teclas("01 02 07" , p_versao)
      CURRENT WINDOW IS w_cdv2010

      IF l_cliente IS NOT NULL THEN
         LET mr_tela.cliente_fatur = l_cliente
         DISPLAY BY NAME mr_tela.cliente_fatur
      END IF

    WHEN INFIELD(status_acer_viagem)
      LET l_list_box = '1 {Viagem pendente}, 2 {Viagem com acerto}, 3 {Viag pend/acert despesa}, 4 {Viagem acerto finalizado}, 5 {Viagem acerto liberado}, 6 {Todas}'
      LET l_status = log0830_list_box(05,10,l_list_box)
      CALL log006_exibe_teclas("01 02 07" , p_versao)
      CURRENT WINDOW IS w_cdv2010

      IF l_status IS NOT NULL THEN
         LET mr_tela.status_acer_viagem = l_status
         DISPLAY BY NAME mr_tela.status_acer_viagem
      END IF

  END CASE

 END FUNCTION

#--------------------------------#
 FUNCTION cdv2010_busca_viajante()
#--------------------------------#
 DEFINE l_matricula       LIKE cdv_info_viajante.matricula,
        l_usuario         LIKE usuarios.cod_usuario,
        l_nom_funcionario LIKE usuarios.nom_funcionario,
        l_viajante        INTEGER,
        l_cod_funcio      LIKE cdv_fornecedor_fun.cod_funcio,
        l_cod_fornecedor  LIKE fornecedor.cod_fornecedor

   WHENEVER ERROR CONTINUE
   DECLARE cq_info CURSOR FOR
   SELECT matricula
     FROM cdv_info_viajante
    WHERE empresa       = p_cod_empresa
      AND usuario_logix = p_user
   WHENEVER ERROR STOP
   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","CQ_INFO")
   END IF

   WHENEVER ERROR CONTINUE
   FOREACH cq_info INTO l_viajante
   WHENEVER ERROR STOP
   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("SELECT","CDV_INFO_VIAJANTE")
   END IF
      EXIT FOREACH
   END FOREACH
   FREE cq_info

   LET l_cod_funcio = l_viajante

   WHENEVER ERROR CONTINUE
   SELECT cod_fornecedor
     INTO l_cod_fornecedor
     FROM cdv_fornecedor_fun
    WHERE cod_funcio = l_cod_funcio
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      WHENEVER ERROR CONTINUE
      SELECT raz_social
        INTO l_nom_funcionario
        FROM fornecedor
       WHERE cod_fornecedor = l_cod_fornecedor
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         LET l_nom_funcionario = NULL
      END IF
   END IF

 RETURN l_viajante, l_nom_funcionario

END FUNCTION

#----------------------------------#
 FUNCTION cdv2010_consulta_viagens()
#----------------------------------#

 IF NOT cdv2010_cria_temporaria() THEN
    ERROR 'Problemas na criação da tabela temporária.'
    RETURN FALSE
 END IF

 IF cdv2010_seleciona_viagens_solic() THEN
    {IF cdv2010_seleciona_viagens_adto() THEN}
       IF mr_tela.status_acer_viagem <> '1' THEN
          IF cdv2010_seleciona_viagens_acer() THEN
             CALL cdv2010_mostra_dados()
          ELSE
             RETURN FALSE
          END IF
       ELSE
          CALL cdv2010_mostra_dados()
       END IF
    {ELSE
       RETURN FALSE
    END IF}
 ELSE
    RETURN FALSE
 END IF

 MESSAGE 'Consulta efetuada com sucesso.' ATTRIBUTE(REVERSE)

 RETURN TRUE
 END FUNCTION

#---------------------------------#
 FUNCTION cdv2010_cria_temporaria()
#---------------------------------#

 WHENEVER ERROR CONTINUE
 DROP TABLE w_cdv2010
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
 CREATE TEMP TABLE w_cdv2010
   (empresa            CHAR(02),
    viagem             INTEGER,
    status             CHAR(03),
    valor              DECIMAL(17,2),
    dat_prev           DATE,
    dat_pgto           DATE,
    despesas           DECIMAL(12,2),
    creditos           DECIMAL(17,2),
    controle           DECIMAL(20,0),
    td                 CHAR(30),
    saldo_viag         DECIMAL(17,2),
    cliente_aten       CHAR(36),
    viagem_receb       INTEGER,
    controle_receb     DECIMAL(20,0),
    cliente_fatur      CHAR(36),
    dat_partida        DATE,
    dat_retorno        DATE,
    tipo               CHAR(02),
    num_ad             DECIMAL(6,0)
    )
 WITH NO LOG;
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("CREATE","W_CDV2010")
    RETURN FALSE
 END IF

 RETURN TRUE
 END FUNCTION

#------------------------------------------#
 FUNCTION cdv2010_prepara_data(l_data, l_op)
#------------------------------------------#
 DEFINE l_data       CHAR(10),
        l_op         CHAR(03),
        l_data_aux   CHAR(20)

 IF l_op = "INI" THEN
    LET l_data_aux        = l_data[7,10], '-',
                            l_data[4,5],  '-',
                            l_data[1,2],  ' ',
                            '00:00:00'
 ELSE
    LET l_data_aux        = l_data[7,10], '-',
                            l_data[4,5],  '-',
                            l_data[1,2],  ' ',
                            '23:59:59'
 END IF

 RETURN l_data_aux
 END FUNCTION

#---------------------------------------------#
 FUNCTION cdv2010_busca_den_tip_desp(l_empresa)
#---------------------------------------------#
 DEFINE l_empresa  LIKE empresa.cod_empresa,
        l_tip_desp LIKE cdv_par_ctr_viagem.desp_solic_viagem,
        l_den_desp LIKE tipo_despesa.nom_tip_despesa

 WHENEVER ERROR CONTINUE
 SELECT desp_solic_viagem
   INTO l_tip_desp
   FROM cdv_par_ctr_viagem
  WHERE empresa = l_empresa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_tip_desp TO NULL
 END IF

 LET l_den_desp = cdv2010_busca_denominacao_tip_desp(l_tip_desp)

 RETURN l_den_desp
 END FUNCTION

#--------------------------------------------------#
 FUNCTION cdv2010_busca_den_tip_desp_adto(l_empresa)
#--------------------------------------------------#
 DEFINE l_empresa  LIKE empresa.cod_empresa,
        l_tip_desp LIKE cdv_par_ctr_viagem.desp_solic_viagem,
        l_den_desp LIKE tipo_despesa.nom_tip_despesa

 WHENEVER ERROR CONTINUE
 SELECT tip_desp_adto_viag
   INTO l_tip_desp
   FROM cdv_par_ctr_viagem
  WHERE empresa = l_empresa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_tip_desp TO NULL
 END IF

 LET l_den_desp = cdv2010_busca_denominacao_tip_desp(l_tip_desp)

 RETURN l_den_desp
 END FUNCTION

#------------------------------------------------------#
 FUNCTION cdv2010_busca_denominacao_tip_desp(l_tip_desp)
#------------------------------------------------------#
 DEFINE l_tip_desp     LIKE tipo_despesa.cod_tip_despesa,
        l_den_tip_desp LIKE tipo_despesa.nom_tip_despesa

 WHENEVER ERROR CONTINUE
 SELECT nom_tip_despesa
   INTO l_den_tip_desp
   FROM tipo_despesa
  WHERE cod_empresa     = p_cod_empresa
    AND cod_tip_despesa = l_tip_desp
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_den_tip_desp TO NULL
 END IF

 RETURN l_den_tip_desp
 END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2010_busca_den_cliente(l_cliente)
#--------------------------------------------#
 DEFINE l_cliente     LIKE clientes.cod_cliente,
        l_nom_cliente LIKE clientes.nom_cliente

 WHENEVER ERROR CONTINUE
 SELECT nom_cliente
   INTO l_nom_cliente
   FROM clientes
  WHERE cod_cliente = l_cliente
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_nom_cliente TO NULL
 END IF

 RETURN l_nom_cliente
 END FUNCTION

#----------------------------------------#
 FUNCTION cdv2010_busca_dat_prev(l_num_ad)
#----------------------------------------#
 DEFINE l_num_ad LIKE ad_ap.num_ad,
        l_num_ap LIKE ad_ap.num_ap,
        l_data   DATE

 WHENEVER ERROR CONTINUE
 DECLARE cq_ap CURSOR FOR
 SELECT num_ap
   FROM ad_ap
  WHERE cod_empresa = p_cod_empresa
    AND num_ad      = l_num_ad
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_AP")
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_ap INTO l_num_ap
 WHENEVER ERROR STOP
    EXIT FOREACH
 END FOREACH

 WHENEVER ERROR CONTINUE
 FREE cq_ap
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
 SELECT dat_vencto_s_desc
   INTO l_data
   FROM ap
  WHERE cod_empresa      = p_cod_empresa
    AND num_ap           = l_num_ap
    AND ies_versao_atual = 'S'
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_data TO NULL
 END IF

 RETURN l_data
 END FUNCTION

#----------------------------------------#
 FUNCTION cdv2010_busca_dat_pgto(l_num_ad)
#----------------------------------------#
 DEFINE l_num_ad LIKE ad_ap.num_ad,
        l_num_ap LIKE ad_ap.num_ap,
        l_data   DATE

 WHENEVER ERROR CONTINUE
 DECLARE cq_ap2 CURSOR FOR
 SELECT num_ap
   FROM ad_ap
  WHERE cod_empresa = p_cod_empresa
    AND num_ad      = l_num_ad
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_AP")
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_ap2 INTO l_num_ap
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("FOREACH","CQ_AP2")
    RETURN
 END IF

    EXIT FOREACH
 END FOREACH

 WHENEVER ERROR CONTINUE
 FREE cq_ap2
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
 SELECT dat_pgto
   INTO l_data
   FROM ap
  WHERE cod_empresa      = p_cod_empresa
    AND num_ap           = l_num_ap
    AND ies_versao_atual = 'S'
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_data TO NULL
 END IF

 RETURN l_data
 END FUNCTION

#---------------------------------#
 FUNCTION cdv2010_busca_somatorio()
#---------------------------------#
 DEFINE l_tot_desp_urb  LIKE cdv_desp_urb_781.val_despesa_urbana,
        l_tot_desp_km   LIKE cdv_despesa_km_781.val_km,
        l_tot_desp      LIKE cdv_solic_adto_781.val_adto_viagem

 LET l_tot_desp_urb = 0
 WHENEVER ERROR CONTINUE
 SELECT SUM(val_despesa_urbana)
   INTO l_tot_desp_urb
   FROM cdv_desp_urb_781
  WHERE empresa  = m_empresa
    AND viagem   = m_viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECT","CDV_DESP_URB_781")
    RETURN
 END IF

 IF l_tot_desp_urb IS NULL THEN
    LET l_tot_desp_urb = 0
 END IF

 WHENEVER ERROR CONTINUE
 SELECT SUM(cdv_despesa_km_781.val_km)
   INTO l_tot_desp_km
   FROM cdv_despesa_km_781, cdv_tdesp_viag_781
  WHERE cdv_despesa_km_781.empresa            = m_empresa
    AND cdv_despesa_km_781.viagem             = m_viagem
    AND cdv_tdesp_viag_781.empresa            = m_empresa
    AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
    AND cdv_tdesp_viag_781.grp_despesa_viagem = 2
    AND cdv_tdesp_viag_781.ativ               = cdv_despesa_km_781.ativ_km #OS462484
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECT","DESPESAS")
    RETURN
 END IF

 IF l_tot_desp_km IS NULL THEN
    LET l_tot_desp_km = 0
 END IF

 LET l_tot_desp = l_tot_desp_urb + l_tot_desp_km

 RETURN l_tot_desp
 END FUNCTION

#------------------------------------------------------#
 FUNCTION cdv2010_busca_den_tip_desp_acer_neg(l_empresa)
#------------------------------------------------------#
 DEFINE l_empresa  LIKE empresa.cod_empresa,
        l_tip_desp LIKE cdv_par_ctr_viagem.desp_solic_viagem,
        l_den_desp LIKE tipo_despesa.nom_tip_despesa

 WHENEVER ERROR CONTINUE
 SELECT tip_desp_acer_cta
   INTO l_tip_desp
   FROM cdv_par_ctr_viagem
  WHERE empresa = l_empresa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_tip_desp TO NULL
 END IF

 LET l_den_desp = cdv2010_busca_denominacao_tip_desp(l_tip_desp)

 RETURN l_den_desp
 END FUNCTION

#------------------------------------------------------#
 FUNCTION cdv2010_busca_den_tip_desp_acer_pos(l_empresa)
#------------------------------------------------------#
 DEFINE l_empresa  LIKE empresa.cod_empresa,
        l_tip_desp LIKE cdv_par_ctr_viagem.desp_solic_viagem,
        l_den_desp LIKE tipo_despesa.nom_tip_despesa

 WHENEVER ERROR CONTINUE
 SELECT parametro_val
   INTO l_tip_desp
   FROM cdv_par_padrao
  WHERE empresa   = l_empresa
    AND parametro = 'tip_desp_acer_reem'
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_tip_desp TO NULL
 END IF

 LET l_den_desp = cdv2010_busca_denominacao_tip_desp(l_tip_desp)

 RETURN l_den_desp
 END FUNCTION

#------------------------------------#
 FUNCTION cdv2010_busca_viagem_receb()
#------------------------------------#
 DEFINE l_viagem_receb LIKE cdv_dev_transf_781.viagem_receb

 WHENEVER ERROR CONTINUE
 SELECT viagem_receb
   INTO l_viagem_receb
   FROM cdv_dev_transf_781
  WHERE cod_empresa = m_empresa
    AND viagem      = m_viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_viagem_receb TO NULL
 END IF

 RETURN l_viagem_receb
 END FUNCTION

#--------------------------------------#
 FUNCTION cdv2010_busca_controle_receb()
#--------------------------------------#
 DEFINE l_controle_receb LIKE cdv_dev_transf_781.controle_receb

 WHENEVER ERROR CONTINUE
 SELECT controle_receb
   INTO l_controle_receb
   FROM cdv_dev_transf_781
  WHERE cod_empresa = m_empresa
    AND viagem      = m_viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_controle_receb TO NULL
 END IF

 RETURN l_controle_receb
 END FUNCTION

#-----------------------------------------#
 FUNCTION cdv2010_verifica_status(l_status)
#-----------------------------------------#
 DEFINE l_status CHAR(01)

 CASE l_status
  WHEN '1'
     LET mr_tela.den_status = 'Viagem pendente'
     DISPLAY BY NAME mr_tela.den_status
     RETURN TRUE
  WHEN '2'
     LET mr_tela.den_status = 'Viagem c/ acerto inicializado'
     DISPLAY BY NAME mr_tela.den_status
     RETURN TRUE
  WHEN '3'
     LET mr_tela.den_status = 'Viagem pendente ou c/ acerto inicializado'
     DISPLAY BY NAME mr_tela.den_status
     RETURN TRUE
  WHEN '4'
     LET mr_tela.den_status = 'Viagem c/ acerto finalizado'
     DISPLAY BY NAME mr_tela.den_status
     RETURN TRUE
  WHEN '5'
     LET mr_tela.den_status = 'Viagem c/ acerto liberado'
     DISPLAY BY NAME mr_tela.den_status
     RETURN TRUE
  WHEN '6'
     LET mr_tela.den_status = 'Todas'
     DISPLAY BY NAME mr_tela.den_status
     RETURN TRUE
  OTHERWISE
     LET mr_tela.den_status = ''
     DISPLAY BY NAME mr_tela.den_status
     CALL log0030_mensagem('Status não cadastrado.','exclamation')
     RETURN FALSE

 END CASE

 END FUNCTION


#-------------------------------------------------------#
FUNCTION cdv2010_busca_status_acerto(l_empresa, l_viagem)
#-------------------------------------------------------#

 DEFINE l_empresa    LIKE cdv_solic_adto_781.empresa,
        l_viagem     LIKE cdv_solic_adto_781.viagem,
        l_status     CHAR(02)

  WHENEVER ERROR CONTINUE
  SELECT status_acer_viagem
    INTO l_status
    FROM cdv_acer_viag_781
   WHERE empresa = l_empresa
     AND viagem  = l_viagem
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     LET l_status = '1'
  END IF

 RETURN l_status
 END FUNCTION

#-------------------------------#
 FUNCTION cdv2010_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/programas/cdv2010.4gl $|$Revision: 3 $|$Date: 23/12/11 12:22 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION