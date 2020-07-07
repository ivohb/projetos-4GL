###PARSER-Não remover esta linha(Framework Logix)###
#-------------------------------------------------------------------#
# SISTEMA.: CONTROLE DE DESPESAS DE VIAGENS.                        #
# PROGRAMA: CDV0041Y                                                #
# OBJETIVO: POPUP PARA INFORMAR PARÂMETRO DE EXIBIÇÃO OU NÃO DA     #
#           MENSAGEM DE VIAGEM PENDENTE DE ACERTO PARA O VIAJANTE   #
# AUTOR...: MAJARA PAULA SCHNEIDER DE SOUZA                         #
# DATA....: 15/09/2011.                                             #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
DEFINE p_cod_empresa         LIKE empresa.cod_empresa,
       g_ies_grafico         SMALLINT,
       p_user                LIKE usuario.nom_usuario
END GLOBALS

#---#MODULARES#--#
DEFINE m_avisa_pend_viagem  CHAR(01),
       m_avisa_pend_viagemr CHAR(01)

#--#END MODULARES#--#

#---------------------------------------------#
FUNCTION cdv0041y_acessa_parametro(l_matricula)
#---------------------------------------------#
DEFINE l_command          CHAR(150),
       l_matricula            LIKE cdv_info_viajante.matricula

  CALL log130_procura_caminho("cdv0041y") RETURNING l_command
  OPEN WINDOW w_cap3380s AT 2,2  WITH FORM l_command
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  IF NOT cdv0041y_carrega_parametro(l_matricula) THEN
     CLOSE WINDOW w_cdv0041y
     CURRENT WINDOW IS w_cdv0041
     RETURN
  END IF

  INPUT m_avisa_pend_viagem WITHOUT DEFAULTS FROM avisa_pend_viagem
     BEFORE INPUT
        IF m_avisa_pend_viagem IS NULL THEN
           LET m_avisa_pend_viagem = 'N'
           DISPLAY m_avisa_pend_viagem TO avisa_pend_viagem
        END IF
        LET m_avisa_pend_viagemr = m_avisa_pend_viagem
  END INPUT

  MENU "OPCAO"
    COMMAND "OK"        "Confirmar operação. "
       IF cdv0041y_deleta_parametro(l_matricula) THEN
           IF cdv0041y_grava_parametro(l_matricula) THEN
              CALL log0030_mensagem(" Modificação efetuada com sucesso ","info")
           END IF
        END IF

    COMMAND "Cancela"        "Cancela a operação"
       CALL log0030_mensagem(" Operação cancelada. ","info")
       EXIT MENU

    COMMAND "Fim"        "Retorna ao Menu Anterior"
       HELP 008
       EXIT MENU

  END MENU

  CLOSE WINDOW w_cdv0041y
  CURRENT WINDOW IS w_cdv0041

END FUNCTION

#----------------------------------------------#
FUNCTION cdv0041y_carrega_parametro(l_matricula)
#----------------------------------------------#
DEFINE l_matricula            LIKE cdv_info_viajante.matricula

 WHENEVER ERROR CONTINUE
    SELECT parametro_booleano
      INTO m_avisa_pend_viagem
      FROM cdv_par_viajante
      WHERE empresa = p_cod_empresa
      AND parametro = 'msg_viaj_pend_acerto'
      AND matricula = l_matricula
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("SELECT","cdv_par_viajante")
    RETURN FALSE
 END IF

 DISPLAY m_avisa_pend_viagem TO avisa_pend_viagem
 RETURN TRUE

END FUNCTION

#----------------------------------------------#
FUNCTION cdv0041y_deleta_parametro(l_matricula)
#----------------------------------------------#
DEFINE l_matricula            LIKE cdv_info_viajante.matricula

 WHENEVER ERROR CONTINUE
    DELETE
      FROM cdv_par_viajante
      WHERE empresa = p_cod_empresa
      AND parametro = 'msg_viaj_pend_acerto'
      AND matricula = l_matricula
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DELETE","cdv_par_viajante")
    RETURN FALSE
 END IF

 RETURN TRUE
END FUNCTION

#--------------------------------------------#
FUNCTION cdv0041y_grava_parametro(l_matricula)
#--------------------------------------------#
DEFINE l_matricula            LIKE cdv_info_viajante.matricula

 WHENEVER ERROR CONTINUE
    INSERT INTO cdv_par_viajante
      VALUES(p_cod_empresa, l_matricula, p_cod_empresa, 'msg_viaj_pend_acerto', 'MOSTRA MENSAGEM PARA O VIAJANTE PENDENTE DE ACERTO.', m_avisa_pend_viagem, NULL, NULL, NULL, NULL )
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DELETE","cdv_par_viajante")
    RETURN FALSE
 END IF

 RETURN TRUE
END FUNCTION

#-------------------------------#
 FUNCTION cdv0041y_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/funcoes/cdv0041y.4gl $|$Revision: 11 $|$Date: 23/12/11 12:22 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION