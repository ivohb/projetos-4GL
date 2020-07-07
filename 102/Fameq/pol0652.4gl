#-----------------------------------------------------------------------#
# PROGRAMA: pol0652                                                     #
# OBJETIVO: ACERTA A TABELA QFPTRAN                                     #
# AUTOR...: POLO INFORMATICA - IVO                                      #
# DATA....: 15/10/2007                                                  #
#-----------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_num_doca           CHAR(05),
          p_concatena          SMALLINT,
          p_ies_ex             CHAR(01),
          p_cod_cliente        CHAR(14),
          p_men                CHAR(60),
          p_rowid              INTEGER,
          p_count              INTEGER,
          p_status             SMALLINT,
          p_sobe               DECIMAL(1,0),
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_msg                CHAR(300),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          p_caminho            CHAR(080)

   DEFINE p_qfptran            RECORD LIKE qfptran.*
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
      DEFER INTERRUPT
      
   LET p_versao = "pol0652-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0652.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0652_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0652_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0652") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0652 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Processa" "Processa o pol0652"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log004_confirm(18,35) THEN
            CALL log085_transacao("BEGIN")
            IF pol0652_processa() THEN
               MESSAGE 'Processamento efetuado com sucesso!' ATTRIBUTE(REVERSE)
               ERROR p_men
               CALL log085_transacao("COMMIT")
            ELSE
               MESSAGE 'Operação cancelada!' ATTRIBUTE(REVERSE)
               CALL log085_transacao("ROLLBACK")
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0652_sobre() 
      COMMAND KEY ("!")
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
   CLOSE WINDOW w_pol0652

END FUNCTION

#------------------------#
 FUNCTION pol0652_sobre()#
#------------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Conversão 10.02 - 01/10/12\n\n ",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#------------------------#
FUNCTION pol0652_processa()
#------------------------#

   DEFINE p_dat CHAR(06)

   DECLARE pri_reg CURSOR FOR 
    SELECT qfp_tran_txt[26,39]
      FROM qfptran
     ORDER BY num_trans

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","QFPTRAN:pri_reg")
      RETURN FALSE
   END IF
     
   FOREACH pri_reg INTO p_cod_cliente
      EXIT FOREACH
   END FOREACH

   SELECT UNIQUE cod_cliente
     FROM trata_edi_1080
    WHERE cod_cliente = p_cod_cliente

   IF STATUS = 0 THEN
      LET p_concatena = TRUE
   ELSE
      IF STATUS = 100 THEN
         LET p_concatena = FALSE
      ELSE
         CALL log003_err_sql("LEITURA","trata_edi_1080")
         RETURN FALSE
      END IF
   END IF
  
   MESSAGE 'Aguarde!... Processando.'

   LET p_count = 0
   
   DECLARE cq_tran CURSOR WITH HOLD FOR 
    SELECT * 
      FROM qfptran
     WHERE qfp_tran_txt[1,3] IN ('PE1','PE2','PE3')
     ORDER BY num_trans

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","QFPTRAN")
      RETURN FALSE
   END IF
     
   FOREACH cq_tran INTO p_qfptran.*
      IF STATUS <> 0 THEN
         CALL log003_err_sql("CURSOR","CQ_TRAN")
         RETURN FALSE
      END IF

      DISPLAY p_qfptran.num_trans AT 21,30


      IF p_qfptran.qfp_tran_txt[1,3] = 'PE1' THEN
         LET p_dat = p_qfptran.qfp_tran_txt[16,21]
         IF p_concatena THEN
           IF NOT pol0652_concatena_doca() THEN
              RETURN FALSE
           END IF
        END IF
      ELSE
         IF p_qfptran.qfp_tran_txt[1,3] = 'PE2' THEN
            LET p_qfptran.qfp_tran_txt[78,80] = '10 '
            IF NOT pol0652_atualiza_qfptran() THEN
               RETURN FALSE
            END IF
         ELSE   
            IF p_qfptran.qfp_tran_txt[4,9] = '222222' OR
               p_qfptran.qfp_tran_txt[4,9] = '333333' OR
               p_qfptran.qfp_tran_txt[4,9] = '444444' THEN
               LET p_qfptran.qfp_tran_txt[4,9] = p_dat
               IF NOT pol0652_atualiza_qfptran() THEN
                  RETURN FALSE
               END IF
            END IF
         END IF
      END IF    

   END FOREACH   

   IF p_count = 0 THEN
      LET p_men = 'Nenhuma substituicao foi efetuada'
   ELSE
      LET p_men = 'Processamento efetuado com sucesso'
   END IF

   RETURN TRUE
   
END FUNCTION


#--------------------------------#
FUNCTION pol0652_concatena_doca()
#--------------------------------#

   DEFINE p_num_ped_cli CHAR(12),
          p_num_ped_aux CHAR(12),
          p_doca        CHAR(05),
          p_ind         SMALLINT
   
   LET p_num_ped_aux = p_qfptran.qfp_tran_txt[97,108]
   LET p_doca        = p_qfptran.qfp_tran_txt[109,113]
   LET p_num_ped_cli = NULL
   
   FOR p_ind = 1 TO 12
       IF p_num_ped_aux[p_ind] = '-' THEN
          RETURN TRUE
       ELSE
          IF p_num_ped_aux[p_ind] = ' ' THEN
          ELSE
             LET p_num_ped_cli = p_num_ped_cli CLIPPED, p_num_ped_aux[p_ind]
          END IF
       END IF
   END FOR
   
   SELECT ies_ex
     INTO p_ies_ex
     FROM trata_edi_1080
    WHERE cod_cliente = p_cod_cliente
      AND doca        = p_doca

   IF p_ies_ex = 'S' THEN
      LET p_num_ped_cli = p_num_ped_cli CLIPPED,'EX-', p_doca
   ELSE
      LET p_num_ped_cli = p_num_ped_cli CLIPPED,'-', p_doca
   END IF
         
   LET p_qfptran.qfp_tran_txt[97,108] = p_num_ped_cli

   IF NOT pol0652_atualiza_qfptran() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol0652_atualiza_qfptran()
#----------------------------------#

   UPDATE qfptran
     SET qfp_tran_txt = p_qfptran.qfp_tran_txt
   WHERE num_trans = p_qfptran.num_trans
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE","QFPTRAN")
      RETURN FALSE
   END IF

   LET p_count = p_count + 1

   RETURN TRUE

END FUNCTION
