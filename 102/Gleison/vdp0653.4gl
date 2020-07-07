###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: VDP0653                                               #
# MODULOS.: VDP0653 - LOG0010 - LOG0030 - LOG0050 - LOG0060       #
#           LOG1300 - LOG1400                                     #
# OBJETIVO: IMPORTACAO DA TABELA QFPTRAN                          #
# AUTOR...: EMANUELE BERGUI                                       #
# DATA....: 21/06/2006                                            #
#-----------------------------------------------------------------#
# OBJETIVO: MIGRAÇÃO VERSÃO 05.10 PARA VERSAO 10.02               #
# AUTOR...: IVANELE DO ROCIO LOPES                                #
# DATA....: 05/01/2011                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_status               SMALLINT,
         p_houve_erro           SMALLINT,
         p_erro_informar        CHAR(01),
         p_ind_decimais         DECIMAL(01,0),
         p_divisor              DECIMAL(10,0),
         g_ies_ambiente         CHAR(001),
         g_ies_grafico          SMALLINT

  DEFINE p_qfptran              RECORD LIKE qfptran.*
  DEFINE p_par_vdp              RECORD LIKE par_vdp.*

  DEFINE p_qfptran_3            RECORD
                                chave              CHAR(76),
                                data1              CHAR(06),
                                hora1              DECIMAL(02,0),
                                qtd_chamada1       DECIMAL(09,0),
                                data2              CHAR(06),
                                hora2              DECIMAL(02,0),
                                qtd_chamada2       DECIMAL(09,0),
                                data3              CHAR(06),
                                hora3              DECIMAL(02,0),
                                qtd_chamada3       DECIMAL(09,0),
                                data4              CHAR(06),
                                hora4              DECIMAL(02,0),
                                qtd_chamada4       DECIMAL(09,0),
                                data5              CHAR(06),
                                hora5              DECIMAL(02,0),
                                qtd_chamada5       DECIMAL(09,0),
                                data6              CHAR(06),
                                hora6              DECIMAL(02,0),
                                qtd_chamada6       DECIMAL(09,0),
                                data7              CHAR(06),
                                hora7              DECIMAL(02,0),
                                qtd_chamada7       DECIMAL(09,0),
                                fim                CHAR(05)
                                END RECORD

   DEFINE p_nom_arquivo          CHAR(100),
          p_msg                  CHAR(100),
          p_comando              CHAR(080),
          p_caminho              CHAR(080),
          p_nom_tela             CHAR(080),
          p_help                 CHAR(080),
          m_nom_arquivo_aux      CHAR(100),
          p_cancel               INTEGER

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

END GLOBALS

DEFINE m_status               INTEGER,
       m_diretorio            CHAR(100),
       m_executa_auto         SMALLINT,
       m_usa_var_qfp_agco     CHAR(01),
       m_comand_cap           CHAR(150),
       m_comando              CHAR(150),
       m_arr_curr             SMALLINT ,
       m_scr_line             SMALLINT



DEFINE ma_tela  ARRAY[9000] OF RECORD
                   seleciona  CHAR(01),
                   arquivo    CHAR(57)
                END RECORD

MAIN

   CALL log0180_conecta_usuario()

  CALL fgl_setenv("VERSION_INFO","L10-VDP0653-10.02.$Revision: 6 $e") #Informacao da versao do programa controlado pelo SourceSafe - Nao remover esta linha.
   LET p_versao = "VDP0653-10.02.00p" #Favor nao alterar esta linha (SUPORTE)

   WHENEVER ERROR CONTINUE
   CALL log1400_isolation()
   WHENEVER ERROR STOP
   DEFER INTERRUPT

   INITIALIZE m_comando,m_arr_curr , m_scr_line  TO NULL
   CALL log140_procura_caminho("vdp0653.iem") RETURNING m_comando
   OPTIONS
       HELP FILE m_comando

   IF NUM_ARGS() > 0  THEN
      LET p_cod_empresa      = ARG_VAL(0)
      LET m_executa_auto     = TRUE
   ELSE
      LET m_executa_auto     = FALSE
   END IF

   CALL log001_acessa_usuario("VDP","LOGERP")
        RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      CALL vdp0653_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION vdp0653_controle()
#--------------------------#
   DEFINE
      l_diretorio  LIKE  exp_interface.dir_entrada,
      l_arquivo    LIKE  exp_interface.nom_arquivo,
      l_parametro  CHAR(01),
      l_caminho    CHAR(200),
      l_comando    CHAR(130),
      l_nom_remove CHAR(200),
      l_ind        SMALLINT,
      l_selecao    SMALLINT

   CALL log2250_busca_parametro(p_cod_empresa,'usa_var_qfp_agco')
      RETURNING m_usa_var_qfp_agco, p_status

   IF m_usa_var_qfp_agco = 'S' THEN
      {Sistema QFP não suporta arquivo EDI AGCO}
      IF NOT m_executa_auto THEN
         CALL LOG0030_mensagem('Sistema QFP não suporta arquivo EDI AGCO.','exclamation')
      END IF
      RETURN
   END IF

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_par_vdp.*
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
   END IF

   LET p_erro_informar = "N"

   WHENEVER ERROR CONTINUE
   SELECT nom_caminho
   	 INTO m_diretorio
    FROM path_logix_v2
   WHERE cod_empresa= p_cod_empresa
     AND cod_sistema = 'QFP'
     AND ies_ambiente = g_ies_ambiente
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      LET m_diretorio = "/u/publico/qfp/"         
   END IF
   
   IF g_ies_ambiente = "W" THEN
      LET p_nom_arquivo = "dir ", m_diretorio CLIPPED,
                          "* ", m_diretorio CLIPPED ,"lista.txt "

      LET l_nom_remove = 'del ',m_diretorio CLIPPED,'lista.txt'
   ELSE
      LET p_nom_arquivo = "ls ",m_diretorio CLIPPED,
                          "* > ", m_diretorio CLIPPED, "lista.txt "

      LET  l_nom_remove = 'rm ' ,m_diretorio CLIPPED,'lista.txt'
   END IF

   RUN l_nom_remove
   RUN p_nom_arquivo

   LET l_caminho      = m_diretorio CLIPPED, "lista.txt"

   WHENEVER ERROR CONTINUE
   DROP TABLE t_lista
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
   END IF

   WHENEVER ERROR CONTINUE
   CREATE TEMP TABLE t_lista
   (nom_arquivo      CHAR(250) );
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
   END IF

   WHENEVER ERROR CONTINUE
   LOAD FROM l_caminho INSERT INTO t_lista
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
   END IF

   #--inicio--CH 724108 #
   IF m_executa_auto THEN
      CALL vdp0653_processar_auto()
   ELSE
     FOR l_ind =  1 TO 99
        INITIALIZE ma_tela[l_ind].* TO NULL
     END FOR

     CALL log006_exibe_teclas("01", p_versao)
     CALL log130_procura_caminho("vdp0653") RETURNING m_comand_cap
     OPEN WINDOW w_vdp0653 AT 2,2  WITH FORM m_comand_cap
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

     MENU "OPCAO"

      COMMAND "Informar" "Informe parametros para o processamento."
        HELP 009
        MESSAGE ""
        IF log005_seguranca(p_user,"VDP","VDP0653","CO") THEN
           LET INT_FLAG = 0
           LET l_selecao = FALSE
           IF VDP0653_entrada_dados() THEN
              NEXT OPTION "Processar"
           ELSE
              CALL LOG0030_mensagem('Processamento cancelado.','exclamation')
              CLEAR FORM
              INITIALIZE ma_tela TO NULL
           END IF
        END IF

      COMMAND "Processar" "Importa dados de outra unidade."
        HELP 010
        MESSAGE ""

        FOR l_ind = 1 TO 99
           IF ma_tela[l_ind].seleciona = "S" AND ma_tela[l_ind].arquivo IS NOT NULL  THEN
              LET l_selecao = TRUE
              EXIT FOR
           END IF
        END FOR
        IF l_selecao = TRUE THEN
           IF VDP0653_processar_manual() THEN
              CALL LOG0030_mensagem('Processamento efetuado com sucesso.','exclamation')
           ELSE
              CALL LOG0030_mensagem('Processamento cancelado.','exclamation')
           END IF
           NEXT OPTION "Fim"
        ELSE
           CALL LOG0030_mensagem('Informe parametros para o Processamento.','exclamation')
           NEXT OPTION "Informar"
        END IF


      COMMAND "Fim" "Retorna ao Menu Anterior"
        HELP 008
        MESSAGE ""
        EXIT MENU
         #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
         #lds CALL LOG_info_sobre(sourceName(),p_versao)

     END MENU
     CLOSE WINDOW w_vdp0653
  END IF
   #---fim----CH 724108 #

END FUNCTION

#------------------------------------#
 FUNCTION  VDP0653_processar_manual()
#------------------------------------#
  DEFINE  l_ind        SMALLINT,
          l_comando    CHAR(130)

  FOR l_ind = 1 TO 99
     IF ma_tela[l_ind].seleciona = "S" AND ma_tela[l_ind].arquivo IS NOT NULL THEN

        WHENEVER ERROR CONTINUE
        CALL log085_transacao("BEGIN")
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
        END IF
        LET m_nom_arquivo_aux = ma_tela[l_ind].arquivo
        IF vdp0653_carrega_qfptran() THEN
           IF vdp0653_verifica_decimais()THEN

               WHENEVER ERROR CONTINUE
                CALL log085_transacao("COMMIT")
               WHENEVER ERROR STOP

               LET l_comando = "rm ", m_nom_arquivo_aux  CLIPPED
               RUN l_comando RETURNING m_status

               IF m_status <> 0 THEN
                  CONTINUE FOR
               END IF
           ELSE
              WHENEVER ERROR CONTINUE
              CALL log085_transacao("ROLLBACK")
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 THEN
                 RETURN FALSE
              END IF
           END IF
        ELSE
           WHENEVER ERROR CONTINUE
           CALL log085_transacao("ROLLBACK")
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              RETURN FALSE
           END IF
        END IF
     ELSE
        CONTINUE FOR
     END IF
  END FOR

  RETURN  TRUE

END FUNCTION

#----------------------------------#
 FUNCTION  vdp0653_processar_auto()
#----------------------------------#
  DEFINE l_comando   CHAR(130)


   WHENEVER ERROR CONTINUE
   DECLARE cm_lista CURSOR WITH HOLD FOR
   SELECT nom_arquivo
     FROM t_lista
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
   END IF

   WHENEVER ERROR CONTINUE
   FOREACH cm_lista INTO m_nom_arquivo_aux
      IF sqlca.sqlcode <> 0 THEN
      END IF

      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
      END IF

      IF vdp0653_carrega_qfptran() THEN
         IF vdp0653_verifica_decimais()THEN
            CALL vdp0654_carrega_ies_job(m_executa_auto)
            IF vdp0654_controle() THEN

               WHENEVER ERROR CONTINUE
               CALL log085_transacao("COMMIT")
               WHENEVER ERROR STOP

               LET l_comando = "rm ", m_nom_arquivo_aux  CLIPPED
               RUN l_comando RETURNING m_status

               IF m_status <> 0 THEN
                  CONTINUE FOREACH
               END IF
            ELSE
               WHENEVER ERROR CONTINUE
               CALL log085_transacao("ROLLBACK")
               WHENEVER ERROR STOP
               IF sqlca.sqlcode <> 0 THEN
               END IF
            END IF
         ELSE
            WHENEVER ERROR CONTINUE
            CALL log085_transacao("ROLLBACK")
            WHENEVER ERROR STOP
            IF sqlca.sqlcode <> 0 THEN
            END IF
         END IF
      ELSE
         WHENEVER ERROR CONTINUE
         CALL log085_transacao("ROLLBACK")
         WHENEVER ERROR STOP
         IF sqlca.sqlcode <> 0 THEN
         END IF
      END IF
   END FOREACH
   WHENEVER ERROR STOP


END FUNCTION

#---------------------------------#
 FUNCTION vdp0653_entrada_dados()
#---------------------------------#
  DEFINE l_ind         SMALLINT,
         l_parametro   CHAR(01),
         l_status      SMALLINT

  CALL log006_exibe_teclas("01 02 03 07",p_versao)
  CURRENT WINDOW IS w_vdp0653
  CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa
  DISPLAY m_diretorio TO caminho
  WHENEVER ERROR CONTINUE
   DECLARE cq_lista1 CURSOR  FOR
   SELECT nom_arquivo
     FROM t_lista
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
   END IF

   LET l_ind = 1

   WHENEVER ERROR CONTINUE
    FOREACH cq_lista1 INTO ma_tela[l_ind].arquivo
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
   END IF

      LET l_ind = l_ind + 1
   END FOREACH

   CALL set_count(l_ind - 1)

   IF l_ind = 1 THEN
      CALL LOG0030_mensagem('Não foram encontrados dados para o processamento.','exclamation')
      RETURN FALSE
   END IF
   LET int_flag = 0
   INPUT ARRAY ma_tela  WITHOUT DEFAULTS FROM sr_selecionar.*
      BEFORE ROW

           LET m_arr_curr =  arr_curr()
           LET m_scr_line =  scr_line()

      BEFORE FIELD seleciona
         IF ma_tela[m_arr_curr].seleciona  IS NULL THEN
            LET ma_tela[m_arr_curr].seleciona = "N"
         END IF

      AFTER FIELD seleciona

      ON KEY (f1, control-w)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
           CALL vdp0653_help()
   AFTER INPUT
      IF NOT int_flag THEN
         FOR l_ind = 1 TO 99
            IF ma_tela[l_ind].seleciona IS NOT NULL THEN
               EXIT FOR
            END IF
            IF l_ind = 99 THEN
               CALL log0030_mensagem('Informe um arquivo para o processamento.','exclamation')
               NEXT FIELD seleciona
            END IF
         END FOR
      END IF
   END INPUT

   RETURN NOT int_flag

END FUNCTION

#---------------------------------#
FUNCTION vdp0653_help()
#---------------------------------#

  CASE
    WHEN INFIELD(seleciona)  CALL SHOWHELP(101)
  END CASE

END FUNCTION

#---------------------------------#
 FUNCTION vdp0653_carrega_qfptran()
#---------------------------------#
  DEFINE p_qfptran         RECORD LIKE qfptran.*

  DEFINE l_mensagem        CHAR(078),
         l_buffer          CHAR(5000),
         l_nom_arquivo_aux CHAR(100),
         l_des_qfptran     CHAR(300),
         l_caminho         CHAR(50),
         l_comando         CHAR(130)

  WHENEVER ERROR CONTINUE
  DELETE FROM qfptran
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
  END IF

  WHENEVER ERROR CONTINUE
  DROP TABLE t_vdp0653
  CREATE TEMP TABLE t_vdp0653(qfp_tran_txt CHAR(300),
                              num_trans    DECIMAL(10,0));
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("CREATE TABLE","t_vdp0653")
    RETURN FALSE
  END IF

   IF g_ies_ambiente = "U" THEN

      LET l_nom_arquivo_aux  = m_nom_arquivo_aux CLIPPED, 'tmp'

      #Comando que converte arquivos que são copiados do servidor para windows
      LET l_comando          = "dos2unix ", m_nom_arquivo_aux CLIPPED
      RUN l_comando RETURNING m_status

      LET l_comando          = "cat ", m_nom_arquivo_aux CLIPPED," |",
                               " awk {'print $0""^0^""'} > ", l_nom_arquivo_aux
      RUN l_comando RETURNING m_status
      IF m_status <> 0 THEN
         CALL log0030_mensagem( "Erro concatenar","exclamation")
         RETURN FALSE
      END IF

      WHENEVER ERROR CONTINUE
      LOAD FROM l_nom_arquivo_aux DELIMITER "^" INSERT INTO t_vdp0653
      WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
         IF sqlca.sqlcode = -805 THEN
            ERROR "Nao foi possivel a leitura do arquivo ",
                   m_nom_arquivo_aux CLIPPED
            RETURN FALSE
         ELSE
            CALL log003_err_sql("IMPORTACAO","t_vdp0653")
            RETURN FALSE
         END IF
      END IF

      WHENEVER ERROR CONTINUE
      DECLARE cq_qfptran CURSOR FOR
       SELECT qfp_tran_txt FROM t_vdp0653
      WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("DECLARE CURSOR","t_vdp0653")
         RETURN FALSE
      END IF

      WHENEVER ERROR CONTINUE
      FOREACH cq_qfptran INTO l_des_qfptran

        IF sqlca.sqlcode <> 0 THEN
          RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
        INSERT INTO qfptran(qfp_tran_txt,num_trans) VALUES (l_des_qfptran,0)
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
          RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE

      END FOREACH
      WHENEVER ERROR STOP

      LET l_comando = "rm ", l_nom_arquivo_aux  CLIPPED
      RUN l_comando RETURNING m_status
      IF m_status <> 0 THEN
         RETURN FALSE
      END IF
   ELSE
      --#  WHENEVER ERROR CONTINUE
      --#  CALL log4070_channel_open_file("f1",m_nom_arquivo_aux,"r")
           IF  status <> 0 THEN
               RETURN FALSE
           END IF

      --#  CALL log4070_channel_set_delimiter("f1","")
      --#  WHILE log4070_channel_read_eof("f1")
      --#   LET l_buffer = log4070_channel_read( "f1" )
      --#      LET l_des_qfptran = l_buffer[1,300]
      --#      INSERT INTO qfptran(qfp_tran_txt,num_trans) VALUES (l_des_qfptran,0)
      --#      WHENEVER ERROR STOP
      --#         IF  SQLCA.SQLCODE <> 0 THEN
      --#             ERROR "Erro ao inserir tabela qfptran.\n SQLCODE=",
      --#                    SQLCA.SQLCODE USING "-<<<<<"," ISAM CODE=",
      --#                    SQLCA.SQLERRD[2] USING "-<<<<<"
      --#             RETURN FALSE
      --#         END IF
      --# END WHILE

      --# CALL log4070_channel_close("f1")
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------------#
 REPORT repo0653(r_arquivo,p_num_col)
#------------------------------------#
   DEFINE r_arquivo  CHAR(100),
          p_num_col  DECIMAL(2,0)

   OUTPUT
       REPORT TO     "VDP0653.dbl"
       LEFT MARGIN   0
       RIGHT MARGIN  80
       TOP MARGIN    0
       BOTTOM MARGIN 0
       PAGE LENGTH   3

   FORMAT
     ON EVERY ROW
       PRINT COLUMN   1, "FILE """,r_arquivo clipped, "\"  delimiter \"|\" ",p_num_col," ;"
       PRINT COLUMN   1, "INSERT INTO qfptran ;"
END REPORT

#------------------------------------#
 FUNCTION vdp0653_verifica_decimais()
#------------------------------------#

  LET p_houve_erro = FALSE

  WHENEVER ERROR CONTINUE
  DECLARE cl_qfptran CURSOR FOR
    SELECT qfptran.*
      INTO p_qfptran.*
      FROM qfptran
     ORDER BY num_trans
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
  END IF

  WHENEVER ERROR CONTINUE
  FOREACH cl_qfptran
    IF sqlca.sqlcode <> 0 THEN
    END IF
    INITIALIZE p_qfptran_3 TO NULL
    IF p_par_vdp.par_vdp_txt[491,491] = "N" OR
       p_par_vdp.par_vdp_txt[491,491] = " " THEN
       LET p_qfptran.qfp_tran_txt = 14 spaces,p_qfptran.qfp_tran_txt
    END IF

    IF p_qfptran.qfp_tran_txt[71,73]   = "PE1" THEN
       LET p_ind_decimais = p_qfptran.qfp_tran_txt[170,170]
    END IF
    IF p_ind_decimais <> 0 THEN
       IF p_qfptran.qfp_tran_txt[71,73] = "PE3" THEN
          CALL vdp0653_busca_divisor()
          IF vdp0653_recalcular_qtde() = FALSE THEN
             LET p_houve_erro = TRUE
             EXIT FOREACH
          END IF
       END IF
    END IF
  END FOREACH
  WHENEVER ERROR STOP

  IF p_houve_erro = FALSE THEN
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF
END FUNCTION

#-------------------------------#
 FUNCTION vdp0653_busca_divisor()
#-------------------------------#
  CASE p_ind_decimais
    WHEN 1
         LET p_divisor = 10
    WHEN 2
         LET p_divisor = 100
    WHEN 3
         LET p_divisor = 1000
    WHEN 4
         LET p_divisor = 10000
    WHEN 5
         LET p_divisor = 100000
    WHEN 6
         LET p_divisor = 1000000
    WHEN 7
         LET p_divisor = 10000000
    WHEN 8
         LET p_divisor = 100000000
    WHEN 9
         LET p_divisor = 1000000000
  END CASE
END FUNCTION

#---------------------------------#
 FUNCTION vdp0653_recalcular_qtde()
#---------------------------------#
  DEFINE p_chave                CHAR(076)

  LET p_chave                  = p_qfptran.qfp_tran_txt[1,76]
  LET p_qfptran_3.qtd_chamada1 = p_qfptran.qfp_tran_txt[85,93]   / p_divisor
  LET p_qfptran_3.qtd_chamada2 = p_qfptran.qfp_tran_txt[102,110] / p_divisor
  LET p_qfptran_3.qtd_chamada3 = p_qfptran.qfp_tran_txt[119,127] / p_divisor
  LET p_qfptran_3.qtd_chamada4 = p_qfptran.qfp_tran_txt[136,144] / p_divisor
  LET p_qfptran_3.qtd_chamada5 = p_qfptran.qfp_tran_txt[153,161] / p_divisor
  LET p_qfptran_3.qtd_chamada6 = p_qfptran.qfp_tran_txt[170,178] / p_divisor
  LET p_qfptran_3.qtd_chamada7 = p_qfptran.qfp_tran_txt[187,195] / p_divisor

  WHENEVER ERROR CONTINUE
  UPDATE qfptran
     SET qfp_tran_txt[85,93]   = p_qfptran_3.qtd_chamada1,
         qfp_tran_txt[102,110] = p_qfptran_3.qtd_chamada2,
         qfp_tran_txt[119,127] = p_qfptran_3.qtd_chamada3,
         qfp_tran_txt[136,144] = p_qfptran_3.qtd_chamada4,
         qfp_tran_txt[153,161] = p_qfptran_3.qtd_chamada5,
         qfp_tran_txt[170,178] = p_qfptran_3.qtd_chamada6,
         qfp_tran_txt[187,195] = p_qfptran_3.qtd_chamada7
   WHERE qfp_tran_txt[1,76] = p_chave
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE
  END IF

  RETURN TRUE
END FUNCTION

#-------------------------------#
 FUNCTION vdp0653_version_info()
#-------------------------------#

  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/painco_industria_e_comercio_sa/vendas/vendas/programas/vdp0653.4gl $|$Revision: 6 $|$Date: 30/08/11 14:46 $|$Modtime: 26/05/11 17:03 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

END FUNCTION
