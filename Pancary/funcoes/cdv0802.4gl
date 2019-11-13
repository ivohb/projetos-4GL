#-----------------------------------------------------------------#
# SISTEMA.: CONTROLE DE DESPESAS DE VIAGENS                       #
# PROGRAMA: CDV0802                                               #
# OBJETIVO: POPUP TIPOS DE DESPESA POR ATIVIDADE   (PAMCARY)      #
# AUTOR...: JULIANO TEÓFILO CABRAL DA MAIA                        #
# DATA....: 13/07/2005                                            #
#-----------------------------------------------------------------#
DATABASE logix

 GLOBALS
 DEFINE  p_user          CHAR(08),
         g_ies_ambiente  CHAR(01)
 END GLOBALS

 DEFINE m_versao_funcao       CHAR(18)

#---------------------------------------------------------------------------#
 FUNCTION cdv0802_popup_tip_desp_versus_ativ(l_empresa, l_where_clause)
#---------------------------------------------------------------------------#
  DEFINE sql_stmt               CHAR(700),
         l_empresa              CHAR(02),
         l_where_clause         CHAR(500),
         l_comando              CHAR(150),
         l_tip_despesa_viagem   DECIMAL(5,0),
         l_ind                  SMALLINT

	 DEFINE ma_tip_despesa ARRAY[1000] OF RECORD
	        tip_despesa_viagem  LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
	        des_tdesp_viagem    LIKE cdv_tdesp_viag_781.des_tdesp_viagem,
	        atividade           LIKE cdv_ativ_781.ativ
		END RECORD

  LET m_versao_funcao = "CDV0802-05.00.00p"

  INITIALIZE l_tip_despesa_viagem TO NULL

  CALL log130_procura_caminho("cdv0802") RETURNING l_comando

  OPEN WINDOW w_cdv0802 AT 6,20 WITH FORM l_comando
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)

   CALL log0010_close_window_screen()
  CALL log006_exibe_teclas("02 08 09", m_versao_funcao)
  CURRENT WINDOW IS w_cdv0802

  LET sql_stmt =
   'SELECT tip_despesa_viagem, des_tdesp_viagem, ativ',
    ' FROM cdv_tdesp_viag_781',
   ' WHERE empresa = "',l_empresa,'"',
     ' AND ',l_where_clause CLIPPED

  WHENEVER ERROR CONTINUE
   PREPARE var_query FROM sql_stmt
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql_detalhe("PREPARE","var_query",sql_stmt)
     CLOSE WINDOW w_cdv0802
     RETURN l_tip_despesa_viagem
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_tip_desp_viag CURSOR FOR var_query
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DECLARE','cq_tip_desp_viag')
     CLOSE WINDOW w_cdv0802
     RETURN l_tip_despesa_viagem
  END IF

  LET l_ind = 1

  WHENEVER ERROR CONTINUE
   FOREACH cq_tip_desp_viag INTO ma_tip_despesa[l_ind].*
  WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('FOREACH','cq_tip_desp_viag')
        CLOSE WINDOW w_cdv0802
        RETURN l_tip_despesa_viagem
     END IF
     LET l_ind = l_ind + 1
     IF l_ind > 1000 THEN
	       CALL log0030_mensagem("Estão sendo mostrados os primeiro 1000 tipos de depesa.","exclamation")
	       EXIT FOREACH
     END IF
  END FOREACH


  CALL SET_COUNT(l_ind - 1)
  IF l_ind = 1  THEN
     CLEAR FORM
     CALL log0030_mensagem("Argumentos de pesquisa não encontrados.","info")
  ELSE
     DISPLAY ARRAY ma_tip_despesa TO s_tip_despesa.*
        ON KEY (control-z, f4)
           CALL log120_procura_caminho("CDV2004") RETURNING l_comando
           RUN l_comando
     END DISPLAY
     IF INT_FLAG THEN
	       LET INT_FLAG = 0
     ELSE
	       LET l_ind = ARR_CURR()
	       LET l_tip_despesa_viagem = ma_tip_despesa[l_ind].tip_despesa_viagem
     END IF
  END IF

  CLOSE WINDOW w_cdv0802
  RETURN l_tip_despesa_viagem

END FUNCTION

#-------------------------------#
 FUNCTION cdv0802_version_info()
#-------------------------------#

  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/funcoes/cdv0802.4gl $|$Revision: 8 $|$Date: 23/12/11 12:22 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

 END FUNCTION