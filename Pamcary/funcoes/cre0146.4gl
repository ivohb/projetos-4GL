###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: CONTAS A RECEBER                                      #
# PROGRAMA: CRE0146                                               #
# OBJETIVO: FUNCAO POPUP PARA SISTEMAS GERADORES.                 #
# AUTOR...: ARINE MORCIANI                                        #
# DATA....: 01/11/2006                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS

 DEFINE p_cod_empresa      LIKE empresa.cod_empresa,
        p_user             LIKE usuario.nom_usuario

END GLOBALS

  DEFINE m_caminho             CHAR(80)
  DEFINE m_versao_funcao       CHAR(18) # -- Favor nao apagar esta linha (SUPORTE)

#-------------------------------#
 FUNCTION cre0146_version_info()
#-------------------------------#

 RETURN "$Archive: /especificos/logix10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/contas_receber/funcoes/cre0146.4gl $|$Revision: 2 $|$Date: 2/06/11 10:49 $|$Modtime: 23/05/11 14:06 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

 END FUNCTION

#-------------------------------------------#
 FUNCTION cre0146_popup_sist_ger(l_programa)
#-------------------------------------------#
   DEFINE la_cre_popup_sist ARRAY[999] OF
                               RECORD
                                  sistema     LIKE cre_par_sist_781.sistema,
                                  des_sistema LIKE cre_par_sist_781.des_sistema,
                                  sit_sistema LIKE cre_popup_sist_781.sit_sistema
                               END RECORD

   DEFINE l_ind                SMALLINT,
          l_arr_curr           SMALLINT,
          l_arr_count          SMALLINT,
          l_sistema_marcado    SMALLINT

   DEFINE l_msg               CHAR(100),
          l_sistemas          CHAR(999),
          l_programa          CHAR(010)

   INITIALIZE la_cre_popup_sist TO NULL

   LET l_ind     = 1
   LET int_flag  = FALSE

   LET m_versao_funcao = 'CRE0146-10.02.00'

   CALL log130_procura_caminho("cre0146")
    RETURNING m_caminho

   OPEN WINDOW w_cre0146 AT 5,20 WITH FORM m_caminho
    ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)

   WHENEVER ERROR CONTINUE
    DECLARE cq_cre_popup_sist CURSOR FOR
     SELECT sistema,
            des_sistema
       FROM cre_par_sist_781
      WHERE empresa = p_cod_empresa
      ORDER BY sistema
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE CURSOR","cq_cre_popup_sist")
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
    FOREACH cq_cre_popup_sist INTO la_cre_popup_sist[l_ind].sistema,
                                   la_cre_popup_sist[l_ind].des_sistema
       IF sqlca.sqlcode <> 0 THEN
          IF sqlca.sqlcode <> 100 THEN
             CALL log003_err_sql("FOREACH","CQ_CRE_POPUP_SIST")
             RETURN FALSE
          END IF

          EXIT FOREACH
       END IF

       WHENEVER ERROR CONTINUE
         SELECT sit_sistema
           INTO la_cre_popup_sist[l_ind].sit_sistema
           FROM cre_popup_sist_781
          WHERE sistema  = la_cre_popup_sist[l_ind].sistema
            AND programa = l_programa
            AND usuario  = p_user
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          IF sqlca.sqlcode <> 100 THEN
             CALL log003_err_sql("SELECT","CRE_POPUP_SIST_781")
             RETURN FALSE
          END IF
       END IF

       IF la_cre_popup_sist[l_ind].sit_sistema IS NULL THEN
          LET la_cre_popup_sist[l_ind].sit_sistema = "N"
       END IF

       LET l_ind = l_ind + 1

       IF l_ind > l_sistemas THEN
          LET l_msg = "Serão apresentados apenas os ", l_sistemas USING "<<<", " primeiros registros."
          CALL log0030_mensagem(l_msg,"excl")
          EXIT FOREACH
       END IF

       WHENEVER ERROR CONTINUE
    END FOREACH
   WHENEVER ERROR STOP

   FREE cq_cre_popup_sist

   CALL set_count(l_ind - 1)

   CALL log006_exibe_teclas("01 02 07",m_versao_funcao)
   CURRENT WINDOW IS w_cre0146

   INPUT ARRAY la_cre_popup_sist WITHOUT DEFAULTS FROM sr_sistema.*
      BEFORE ROW
       LET l_arr_curr  = arr_curr()
       LET l_arr_count = arr_count()

      AFTER INPUT
       IF NOT int_flag THEN
          WHENEVER ERROR CONTINUE
            DELETE FROM cre_popup_sist_781
             WHERE programa = l_programa
               AND usuario  = p_user
          WHENEVER ERROR CONTINUE
          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","cre_popup_sist_781")
             RETURN FALSE
          END IF

          FOR l_ind = 1 TO l_arr_count
             IF la_cre_popup_sist[l_ind].sistema IS NOT NULL THEN
                #----------Somente para p cre1273----------------#
                IF l_programa = "CRE1273" THEN
                   IF la_cre_popup_sist[l_ind].sit_sistema = "S" THEN
                      WHENEVER ERROR CONTINUE
                        INSERT INTO cre_sist_detm_781(empresa, sistema_gerador, usuario)
                             VALUES (p_cod_empresa, la_cre_popup_sist[l_ind].sistema, p_user)
                       WHENEVER ERROR STOP
                       IF sqlca.sqlcode <> 0 THEN
                          CALL log003_err_sql("INCLUSAO","cre_sist_detm_781")
                          EXIT FOR
                      END IF
                   END IF
                END IF
                #----------Somente para p cre1273----------------#
                WHENEVER ERROR CONTINUE
                  INSERT INTO cre_popup_sist_781 (sistema,sit_sistema,usuario,programa)
                  VALUES (la_cre_popup_sist[l_ind].sistema,
                          la_cre_popup_sist[l_ind].sit_sistema,
                          p_user,
                          l_programa)
                WHENEVER ERROR STOP
                IF sqlca.sqlcode = 0 THEN
                   MESSAGE "Inclusão efetuada com sucesso." ATTRIBUTE(REVERSE)
                ELSE
                   CALL log003_err_sql("INCLUSAO","cre_popup_sist_781")
                   EXIT FOR
                END IF
             END IF
          END FOR
       END IF

   END INPUT

   CLOSE WINDOW w_cre0146

   LET l_sistema_marcado = FALSE

   FOR l_ind = 1 TO 999
      IF la_cre_popup_sist[l_ind].sistema     IS NULL AND
         la_cre_popup_sist[l_ind].sit_sistema IS NULL THEN
         EXIT FOR
      END IF
      IF la_cre_popup_sist[l_ind].sistema IS NOT NULL AND
         la_cre_popup_sist[l_ind].sit_sistema = 'S'   THEN
         LET l_sistema_marcado = TRUE
         EXIT FOR
      END IF
   END FOR

   IF int_flag = 0 THEN
      IF l_sistema_marcado THEN
         RETURN TRUE
      ELSE
         RETURN FALSE
      END IF
   ELSE
      LET int_flag = 0
      RETURN FALSE
   END IF

 END FUNCTION
