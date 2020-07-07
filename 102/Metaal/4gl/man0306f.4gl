#------------------------------------------------------------------------------#
# SISTEMA.: MANUFATURA                                                         #
# PROGRAMA: man0306f                                                           #
# OBJETIVO: PROGRAMA DE IMPORTACAO DE DADOS DO DRUMMER PARA O LOGIX - PADRAO   #
# DATA....: 05/12/2008                                                         #   
# ALTERAÇÕES                                                                   #
# Dia 12-01-2009(Manuel)  a pedido do Ruben alterei o seguinte                 #
#  De                                                                          #
#       LET lr_ordens.num_docum          = lr_man_ordem_new.ordem_producao     #
#  Para:                                                                       #
#       LET lr_ordens.num_docum          = lr_man_ordem_new.docum              #
# Dia 13-02-2009(Manuel) para alimentar a tabela MAN_OP_COMPONENTE_OPERACAO    #
#  PARA A VERSÃO 10.02                                                         #  
#                                                                              #
# Dia 24-03-2009(Manuel) versão 10.02.09 e 10 definido em reuniao com a Linter #
#                                                                              #
# Dia 02-04-2009(Manuel) versão 10.02.11 Foram alteradas as seguintes dados    #
#                        1- Na tabela ORDENS o campo origem deve ser gravado   #
#                           com 1-PED e não 3-Manual                           #
#                        2- Na tabela ORDENS o campo BX COMP virá do cadastro  #
#                           do item pai no MAN0020 e não mais fixo como 1      #
# Dia 08-04-2009(Manuel) versão 10.02.12 Foram alteradas as seguintes dados    #
#                        1- O local de baixa dos componentes                   #
# Dia 28-04-2009(Manuel) versão 10.02.13 O programa foi alterado para que grave#
#                        as operações da ordem independentemente se o indicador#
#                        na tabela ITEM_MAN.ies_apontamento indicar S/N, até   #
#                        então o programa somente gravava as operações caso    #
#                        esse campo estivesse igual a 'S'                      #           
#------------------------------------------------------------------------------#
 

DATABASE logix

GLOBALS

   DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
          p_user                   LIKE usuario.nom_usuario,
          p_status                 SMALLINT,
          g_ies_grafico            SMALLINT,     -- Windows 4Js --
          p_dep1                   SMALLINT,
          p_dep2                   SMALLINT,
          p_ind1                   SMALLINT,
          p_ind2                   SMALLINT,
          p_num_ordem              CHAR(30)

   DEFINE p_versao                 CHAR(18)  #FAVOR NAO ALTERAR ESTA LINHA (SUPORTE)

   DEFINE p_num_pedido         LIKE pedidos.num_pedido,
          p_num_docum          LIKE ordens.num_docum,
          p_num_lote           LIKE ordens.num_lote

   DEFINE t1_feriado ARRAY[100] OF RECORD
          dat_ref    LIKE feriado.dat_ref,
          ies_situa  LIKE feriado.ies_situa
   END RECORD

   DEFINE t2_semana ARRAY[7] OF RECORD
          ies_dia_semana LIKE semana.ies_dia_semana
         ,ies_situa      LIKE semana.ies_situa
   END RECORD

   DEFINE p_t_estrut RECORD
          cod_item_pai    LIKE estrutura.cod_item_pai
         ,cod_item_compon LIKE estrutura.cod_item_compon
         ,qtd_necessaria  LIKE estrutura.qtd_necessaria
         ,pct_refug       LIKE estrutura.pct_refug
         ,tmp_ressup      LIKE item_man.tmp_ressup
         ,tmp_ressup_sobr LIKE estrutura.tmp_ressup_sobr
   END RECORD

END GLOBALS

#MODULARES
   DEFINE m_caminho                CHAR(100),
          m_help_file              CHAR(100),
          m_comando                CHAR(100),
          #sql_stmt                CHAR(500),
          #where_clause             CHAR(500),
          m_ies_tipo               CHAR(01),
          m_den_empresa            LIKE empresa.den_empresa,
          m_ies_informou           SMALLINT,
          m_num_ordem_aux          LIKE ordens.num_ordem,
          m_ies_processou          SMALLINT,
          m_ocorreu_erro           SMALLINT,
          m_rastreia               SMALLINT,
          m_grava_oplote           SMALLINT,
          m_arr_curr               SMALLINT,
          sc_curr                  SMALLINT,
          m_arr_count              SMALLINT,
          m_cod_cent_trab          LIKE consumo.cod_cent_trab,
          p_seq_comp               DECIMAL(10,0)

   DEFINE ma_familia ARRAY[500] OF RECORD
          cod_familia LIKE familia.cod_familia
   END RECORD

   DEFINE mr_par_logix             RECORD LIKE par_logix.*,
          mr_par_pcp               RECORD LIKE par_pcp.*,
          mr_par_mrp               RECORD LIKE par_mrp.*,
          mr_necessidades          RECORD LIKE necessidades.*,
          mr_ord_compon            RECORD LIKE ord_compon.*

#END MODULARES

MAIN

   CALL log0180_conecta_usuario()

   LET p_versao = "man0306f-10.02.13" 

   WHENEVER ERROR CONTINUE
     CALL log1400_isolation()
     SET LOCK MODE TO WAIT 120
   WHENEVER ERROR STOP

   DEFER INTERRUPT

   CALL log140_procura_caminho("man0306.iem") RETURNING m_help_file

   OPTIONS
     HELP FILE m_help_file,
     HELP KEY control-w

   CALL log001_acessa_usuario("MANUFAT","LOGERP")
       RETURNING p_status, p_cod_empresa, p_user


           WHENEVER ERROR CONTINUE
             SELECT den_empresa
               INTO m_den_empresa
               FROM empresa
              WHERE empresa.cod_empresa = p_cod_empresa
           

           IF  sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("SELECT","EMPRESA")
           END IF

           IF  man0306_par_pcp() THEN
               CALL man0306_controle()
           END IF


END MAIN


#--------------------------#
 FUNCTION man0306_controle()
#--------------------------#

   CALL log006_exibe_teclas("01", p_versao)

   CALL log130_procura_caminho("man0306f") RETURNING m_caminho

   OPEN WINDOW w_man0306 AT 2,2  WITH FORM m_caminho
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"

      COMMAND "Informar"   "Informar parâmetros para importação do Drummer para o Logix."
         HELP 009
         MESSAGE ""
         CALL man0306_inicializa_campos()
         IF log005_seguranca( p_user, "MANUFAT","man0306f","CO") THEN
            LET m_ies_informou = FALSE
            LET m_ies_tipo = ''

            IF man0306_entrada_parametros() THEN
               IF man0306_processa_importacao() THEN
                  NEXT OPTION "Fim"
               ELSE
                  ERROR 'Processamento cancelado!!!'
               END IF
            ELSE
               ERROR 'Operação cancelada!!!'
            END IF
         END IF

      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR m_comando
         RUN m_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando

      COMMAND "Fim" " Retorna ao Menu Anterior "
         HELP 008
         MESSAGE ""
         EXIT MENU

   END MENU

   CLOSE WINDOW w_man0306

 END FUNCTION

#------------------------------------#
FUNCTION man0306_entrada_parametros()
#------------------------------------#

   LET INT_FLAG = FALSE
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_man0306

   INPUT ARRAY ma_familia WITHOUT DEFAULTS FROM s_familia.*

      BEFORE ROW
         LET m_arr_curr  = ARR_CURR()
         LET sc_curr     = SCR_LINE()
         LET m_arr_count = ARR_COUNT()

      AFTER FIELD cod_familia
         IF ma_familia[m_arr_curr].cod_familia IS NOT NULL THEN
            IF NOT man0306_familia_existe() THEN
               NEXT FIELD cod_familia
            END IF

            IF man0306_familia_duplicada(m_arr_curr) THEN
               NEXT FIELD cod_familia
            END IF
         END IF

         IF g_ies_grafico THEN
            --# CALL fgl_dialog_setkeylabel('Control-Z','Zoom')
         ELSE
            DISPLAY " (Zoom) " AT 3,55
         END IF

      ON KEY (control-z, f4)
         CALL man0306_popup_familia()

      ON KEY (f1, control-w)
         CALL man0306_help()

   END INPUT

   IF INT_FLAG THEN
      LET INT_FLAG = 0
      CLEAR FORM
      ERROR " Entrada de dados cancelada. "
      RETURN FALSE
   ELSE
      LET m_ies_informou = TRUE
      RETURN TRUE
   END IF

END FUNCTION

#---------------------------------------------#
FUNCTION man0306_familia_duplicada(l_arr_curr)
#---------------------------------------------#

   DEFINE l_arr_curr SMALLINT,
          l_ind      SMALLINT

   FOR l_ind = 1 TO m_arr_curr
      IF l_ind <> l_arr_curr AND
         ma_familia[l_ind].cod_familia = ma_familia[m_arr_curr].cod_familia THEN
         ERROR " Familia já informada. "
         RETURN TRUE
      END IF
   END FOR

   RETURN FALSE

END FUNCTION

#---------------------------------#
 FUNCTION man0306_familia_existe()
#---------------------------------#

   WHENEVER ERROR CONTINUE
     SELECT cod_familia
       FROM familia
      WHERE cod_empresa = p_cod_empresa
        AND cod_familia = ma_familia[m_arr_curr].cod_familia
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      IF sqlca.sqlcode <> 100 THEN
         CALL log003_err_sql("SELECT","FAMILIA")
      ELSE
         ERROR " Família não cadastrada. "
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------#
FUNCTION man0306_help()
#----------------------#

   OPTIONS
      HELP FILE m_help_file,
      HELP KEY control-w

   CASE
      WHEN INFIELD(cod_familia) CALL SHOWHELP(101)
      WHEN INFIELD(ies_tipo)    CALL SHOWHELP(102)
   END CASE

END FUNCTION

#-----------------------------------#
FUNCTION man0306_inicializa_campos()
#-----------------------------------#

   INITIALIZE ma_familia
             ,m_ies_informou
             ,m_ies_processou
             ,m_ocorreu_erro TO NULL

END FUNCTION


#------------------------------------#
FUNCTION man0306_processa_importacao()
#------------------------------------#
   DEFINE l_mensagem            CHAR(100)

   DEFINE lr_man_ordem          RECORD
       		empresa        char(2),
			    ordem_producao char(30),
			    item 					 char(30),
			    dat_recebto    date,
			    qtd_ordem      decimal(12,2),
			    ordem_mps      char(30),
			    origem         char(1),
			    pedido         char(30),
			    status_ordem   char(1),
			    status_import  char(1),
			    dat_liberacao  date,
			    qtd_pecas_boas decimal(12,2),
			    docum          char(10),
			    lote           char(15),
			    num_projeto    CHAR(10)
   END RECORD
   
   DEFINE lr_man_operacao_ordem RECORD
			    empresa             char(2),
			    ordem_producao      char(30),
			    item                char(30),
			    operacao            char(5),
			    des_operacao        char(40),
			    sequencia_operacao  decimal(3,0),
			    centro_trabalho     char(10),
			    arranjo             char(5),
			    tmp_maquina_prepar  decimal(8,2),
			    tmp_maq_execucao    decimal(14,6),
			    tmp_mdo_prepar      decimal(8,2),
			    tmp_mdo_execucao    decimal(14,6),
			    relacao_ferramenta  char(150),
			    dat_ini_planejada   datetime year to second,
			    dat_trmn_planejada  datetime year to second,
			    qtd_planejada       decimal(12,2),
			    qtd_real            decimal(12,2),
			    qtd_sucata          decimal(12,2),
			    status_import       char(1)
   END RECORD
   
   DEFINE lr_man_necd_ordem     RECORD
			    empresa            char(2),
			    necessidad_ordem   INTEGER,
			    ordem_producao     char(30),
			    item               char(30),
			    qtd_necess         decimal(12,2),
			    status_import      char(1),
			    qtd_requis         decimal(12,2)
   END RECORD   
   
   DEFINE lr_ordens             RECORD LIKE ordens.*,
          lr_ord_oper           RECORD LIKE ord_oper.*,
          lr_necessidades       RECORD LIKE necessidades.*

   DEFINE l_ies_tip_item        LIKE item.ies_tip_item
   DEFINE l_ordem_mps           CHAR(30),
          l_num_docum           CHAR(10),
          l_num_oclinha         LIKE ordens.num_lote

   DEFINE where_clause          CHAR(2000),
          l_ind                 SMALLINT,
          l_informou_familia    SMALLINT,
          l_coloca_virgula      SMALLINT,
          sql_stmt              CHAR(300),
          l_resp                CHAR(01),
          l_status              SMALLINT,
          l_status_import       CHAR(01),
          l_num_ordem           INTEGER,
          l_cod_arranjo         LIKE ord_oper.cod_arranjo,
          l_centro_trabalho     LIKE ord_oper.cod_cent_trab,
          l_num_processo        LIKE ord_oper.num_processo,
          l_ies_situa           SMALLINT,
          l_count               SMALLINT,
          l_ordem_producao      CHAR(30),
          l_ind1                INTEGER


   IF NOT man0306_cria_temp_estrut() THEN
      RETURN FALSE
   END IF

   #-- Inicializa as variáveis usadas
   INITIALIZE lr_man_ordem TO NULL
   INITIALIZE m_num_ordem_aux TO NULL

   LET m_ies_processou = FALSE
   LET m_ocorreu_erro  = FALSE

   LET l_count = 0

   WHENEVER ERROR CONTINUE
     SELECT COUNT(empresa)
       INTO l_count
       FROM man_ordem
      WHERE empresa                 = p_cod_empresa
        AND man_ordem.status_import = "I"
   WHENEVER ERROR STOP

   IF l_count = 0 THEN
      CALL log0030_mensagem("Tabelas para processamento estão vazias.","info")
      RETURN FALSE
   END IF

   MESSAGE " Excluindo dados . . . " ATTRIBUTE (REVERSE)

   CALL log085_transacao("BEGIN")

   #Exclui registros de situacao 3 da familia
#         DECLARE cq_ordens_eliminadas CURSOR WITH HOLD FOR

    LET sql_stmt = " SELECT num_ordem",
                   "   FROM ordens"

    LET where_clause =   "  WHERE ordens.cod_empresa = '",p_cod_empresa,"'",
                            " AND ordens.ies_situa = '3'"

   # Verifica se foi informada alguma família
   FOR l_ind = 1 TO 500
      IF ma_familia[l_ind].cod_familia IS NOT NULL THEN
         LET l_informou_familia = TRUE
         LET where_clause = where_clause CLIPPED, " AND item.cod_familia IN ("
         EXIT FOR
      END IF
   END FOR

   # Inclui as famílias selecionadas no SELECT
   LET l_coloca_virgula = FALSE
   FOR l_ind =1 TO 500
      IF ma_familia[l_ind].cod_familia IS NULL THEN
         CONTINUE FOR
      END IF
      IF l_coloca_virgula THEN
         LET where_clause = where_clause CLIPPED,","
      END IF
      LET where_clause = where_clause CLIPPED, "'" CLIPPED,
         ma_familia[l_ind].cod_familia CLIPPED , "'" CLIPPED
      LET l_coloca_virgula = TRUE
   END FOR

   IF l_informou_familia THEN
      LET where_clause = where_clause CLIPPED,  ")"
   END IF

   LET sql_stmt = sql_stmt CLIPPED, " ", where_clause CLIPPED

   MESSAGE 'Aguarde!... processando:'

   PREPARE var_ordens_elim FROM sql_stmt
   DECLARE cq_ordens_eliminadas CURSOR FOR var_ordens_elim

   FOREACH cq_ordens_eliminadas INTO l_num_ordem

           DISPLAY l_num_ordem AT 21,28
           
           #Elimina ordens_complement
           WHENEVER ERROR CONTINUE
            DELETE FROM ordens_complement
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           WHENEVER ERROR STOP

           IF  sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("DELETE","ORDENS_COMPLEMENT")
               CALL log085_transacao("ROLLBACK")
               RETURN FALSE
           END IF

           #Elimina necessidades
           WHENEVER ERROR CONTINUE
            DELETE FROM necessidades
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","NECESSIDADES")
             CALL log085_transacao("ROLLBACK")
             RETURN FALSE
           END IF

           #Elimina ord_oper
           WHENEVER ERROR CONTINUE
            DELETE FROM ord_oper
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","ORD_OPER")
             CALL log085_transacao("ROLLBACK")
             RETURN FALSE
           END IF

           #Elimina man_oper_compl
           WHENEVER ERROR CONTINUE
            DELETE FROM man_oper_compl
             WHERE empresa            = p_cod_empresa
               AND ordem_producao     = l_num_ordem
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("DELETE","MAN_OPER_COMPL")
              CALL log085_transacao("ROLLBACK")
              RETURN FALSE
           END IF

           #Elimina ord_compon
           WHENEVER ERROR CONTINUE
            DELETE FROM ord_compon
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","ORD_COMPON")
             CALL log085_transacao("ROLLBACK")
             RETURN FALSE
           END IF

           #Elimina Ordens
           WHENEVER ERROR CONTINUE
             DELETE FROM ordens
              WHERE cod_empresa      = p_cod_empresa
                AND num_ordem        = l_num_ordem
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("DELETE","ORDENS")
              CALL log085_transacao("ROLLBACK")
              RETURN FALSE
           END IF

   END FOREACH

   LET sql_stmt = "SELECT man_ordem.* "
                 ,"  FROM man_ordem, item "

   LET where_clause = "WHERE man_ordem.empresa       = '",p_cod_empresa, "'"
                     ,"  AND man_ordem.status_import = 'I' "
                     ,"  AND item.cod_empresa        = '",p_cod_empresa, "'"
                     ,"  AND item.cod_item           = man_ordem.item "

   # Verifica se foi informada alguma família
   FOR l_ind = 1 TO 500
      IF ma_familia[l_ind].cod_familia IS NOT NULL THEN
         LET l_informou_familia = TRUE
         LET where_clause = where_clause CLIPPED, " AND item.cod_familia IN ("
         EXIT FOR
      END IF
   END FOR

   # Inclui as famílias selecionadas no SELECT
   LET l_coloca_virgula = FALSE
   FOR l_ind =1 TO 500
      IF ma_familia[l_ind].cod_familia IS NULL THEN
         CONTINUE FOR
      END IF
      IF l_coloca_virgula THEN
         LET where_clause = where_clause CLIPPED,","
      END IF
      LET where_clause = where_clause CLIPPED, "'" CLIPPED,
         ma_familia[l_ind].cod_familia CLIPPED , "'" CLIPPED
      LET l_coloca_virgula = TRUE
   END FOR

   IF l_informou_familia THEN
      LET where_clause = where_clause CLIPPED,  ")"
   END IF

   LET sql_stmt = sql_stmt CLIPPED, " ", where_clause CLIPPED

   LET sql_stmt = sql_stmt CLIPPED, " ",
       " ORDER BY man_ordem.empresa, man_ordem.dat_recebto "

   LET l_ind = FALSE
   LET l_ind1 = 0

   WHENEVER ERROR CONTINUE
   PREPARE var_query1 FROM sql_stmt

   DECLARE cq_man_ordem_im CURSOR FOR var_query1

   FOREACH cq_man_ordem_im INTO lr_man_ordem.*
   WHENEVER ERROR STOP

     LET l_ind = TRUE
     LET l_ind1 = l_ind1 + 1

     DISPLAY lr_man_ordem.ordem_producao AT 21,28

     IF lr_man_ordem.status_ordem = '3' THEN

        #Reinclui os dados de ies_situa = 3 nas tabelas do Logix conforme dados selecionados
        IF NOT man0306_gera_novas_ordens(lr_man_ordem.*) THEN
           CALL log0030_mensagem( 'Não foi possível criar as novas ordens.Refazer processo.','info')
           MESSAGE "Não foi possível criar as novas ordens.Refazer processo. "

           CALL log085_transacao("ROLLBACK")

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql( 'ROLLBACK', "TRANSACAO" )
           END IF

           RETURN FALSE
        ELSE

           WHENEVER ERROR CONTINUE
             UPDATE man_ordem
                SET man_ordem.ordem_producao = m_num_ordem_aux,
                    man_ordem.status_import  = "O"
              WHERE man_ordem.empresa        = p_cod_empresa
                AND man_ordem.ordem_producao = lr_man_ordem.ordem_producao
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql( 'UPDATE', "MAN_ORDEM" )
              CALL log085_transacao("ROLLBACK")
              RETURN FALSE
           END IF

           WHENEVER ERROR CONTINUE
             UPDATE man_operacao_ordem
                SET man_operacao_ordem.status_import      = 'O',
                    man_operacao_ordem.ordem_producao     = m_num_ordem_aux
              WHERE man_operacao_ordem.empresa            = p_cod_empresa
                AND man_operacao_ordem.ordem_producao     = lr_man_ordem.ordem_producao
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql( 'UPDATE', "MAN_OPERACAO_ORDEM" )
              CALL log085_transacao("ROLLBACK")
              RETURN FALSE
           END IF

           WHENEVER ERROR CONTINUE
             UPDATE man_necd_ordem
                SET man_necd_ordem.ordem_producao = m_num_ordem_aux,
                    man_necd_ordem.status_import  = "O"
              WHERE man_necd_ordem.empresa        = p_cod_empresa
                AND man_necd_ordem.ordem_producao = lr_man_ordem.ordem_producao
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql( 'UPDATE', "MAN_NECD_ORDEM" )
              CALL log085_transacao("ROLLBACK")
              RETURN FALSE
           END IF
        END IF
     END IF

     IF lr_man_ordem.status_ordem = '4' THEN
        WHENEVER ERROR CONTINUE
          UPDATE ordens
             SET ordens.dat_entrega = lr_man_ordem.dat_recebto,
                 ordens.dat_liberac = lr_man_ordem.dat_liberacao
           WHERE ordens.cod_empresa = p_cod_empresa
             AND ordens.num_ordem   = lr_man_ordem.ordem_producao
         WHENEVER ERROR STOP

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql( 'UPDATE', "ORDENS" )
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF

        #Atualiza os registros nas tabelas intermediárias
        WHENEVER ERROR CONTINUE
          UPDATE man_ordem
             SET man_ordem.status_import  = "O"
           WHERE man_ordem.empresa        = p_cod_empresa
             AND man_ordem.ordem_producao = lr_man_ordem.ordem_producao
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql( 'UPDATE', "MAN_ORDEM" )
           CALL log085_transacao("ROLLBACK")
           RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
          UPDATE man_operacao_ordem
             SET man_operacao_ordem.status_import      = 'O'
           WHERE man_operacao_ordem.empresa            = p_cod_empresa
             AND man_operacao_ordem.ordem_producao     = lr_man_ordem.ordem_producao
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql( 'UPDATE', "MAN_OPERACAO_ORDEM" )
           CALL log085_transacao("ROLLBACK")
           RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
          UPDATE man_necd_ordem
             SET man_necd_ordem.status_import  = "O"
           WHERE man_necd_ordem.empresa        = p_cod_empresa
             AND man_necd_ordem.ordem_producao = lr_man_ordem.ordem_producao
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql( 'UPDATE', "MAN_NECD_ORDEM" )
           CALL log085_transacao("ROLLBACK")
           RETURN FALSE
        END IF

        #-- MAN_OPERACAO_ORDEM --> ORDEM_OPER
        WHENEVER ERROR CONTINUE
         DECLARE cq_man_operacao_ordem_im CURSOR FOR
          SELECT man_operacao_ordem.*
            FROM man_operacao_ordem
           WHERE man_operacao_ordem.empresa        = p_cod_empresa
             AND man_operacao_ordem.ordem_producao = lr_man_ordem.ordem_producao
        WHENEVER ERROR STOP

        WHENEVER ERROR CONTINUE
        FOREACH cq_man_operacao_ordem_im INTO lr_man_operacao_ordem.*
        WHENEVER ERROR STOP

           WHENEVER ERROR CONTINUE
            SELECT empresa
              FROM man_oper_compl
             WHERE empresa            = p_cod_empresa
               AND ordem_producao     = lr_man_operacao_ordem.ordem_producao
               AND operacao           = lr_man_operacao_ordem.operacao
               AND sequencia_operacao = lr_man_operacao_ordem.sequencia_operacao
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN

              IF sqlca.sqlcode <> 100 THEN
                 CALL log003_err_sql("SELECT","MAN_OPER_COMPL")
                 CALL log085_transacao("ROLLBACK")
                 RETURN FALSE
              ELSE
                 WHENEVER ERROR CONTINUE
                  INSERT INTO man_oper_compl(empresa
                                            ,ordem_producao
                                            ,operacao
                                            ,sequencia_operacao
                                            ,dat_ini_planejada
                                            ,dat_trmn_planejada)
                                      VALUES(p_cod_empresa
                                            ,lr_man_operacao_ordem.ordem_producao
                                            ,lr_man_operacao_ordem.operacao
                                            ,lr_man_operacao_ordem.sequencia_operacao
                                            ,lr_man_operacao_ordem.dat_ini_planejada
                                            ,lr_man_operacao_ordem.dat_trmn_planejada)
                 WHENEVER ERROR STOP

                 IF sqlca.sqlcode <> 0 THEN
                    CALL log003_err_sql("INSERT","MAN_OPER_COMPL")
                    CALL log085_transacao("ROLLBACK")
                    RETURN FALSE
                 END IF
              END IF
           ELSE
              WHENEVER ERROR CONTINUE
               UPDATE man_oper_compl
                  SET dat_ini_planejada  = lr_man_operacao_ordem.dat_ini_planejada
                     ,dat_trmn_planejada = lr_man_operacao_ordem.dat_trmn_planejada
                WHERE empresa            = p_cod_empresa
                  AND ordem_producao     = lr_man_operacao_ordem.ordem_producao
                  AND operacao           = lr_man_operacao_ordem.operacao
                  AND sequencia_operacao = lr_man_operacao_ordem.sequencia_operacao
              WHENEVER ERROR STOP

              IF sqlca.sqlcode <> 0 THEN
                 CALL log003_err_sql("UPDATE","MAN_OPER_COMPL")
                 CALL log085_transacao("ROLLBACK")
                 RETURN FALSE
              END IF
           END IF

        END FOREACH

     END IF

   END FOREACH

   IF l_ind = FALSE THEN
      CALL log0030_mensagem("Tabelas para processamento estão vazias para os dados informados.","info")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
    CALL log085_transacao("COMMIT")
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql( 'COMMIT', "TRANSACAO" )
      RETURN FALSE
   END IF

   CALL log0030_mensagem('Importação e processo de atualização - executados com sucesso','info')
   MESSAGE "Importação e processo de atualização - executados com sucesso"

   RETURN TRUE

END FUNCTION

#-----------------------------------------------------#
FUNCTION man0306_gera_novas_ordens(lr_man_ordem_new)
#-----------------------------------------------------#

   DEFINE lr_man_ordem_new       RECORD
       		empresa        char(2),
			    ordem_producao char(30),
			    item 					 char(30),
			    dat_recebto    date,
			    qtd_ordem      decimal(12,2),
			    ordem_mps      char(30),
			    origem         char(1),
			    pedido         char(30),
			    status_ordem   char(1),
			    status_import  char(1),
			    dat_liberacao  date,
			    qtd_pecas_boas decimal(12,2),
			    docum          char(10),
			    lote           char(15),
			    num_projeto    CHAR(10)
   END RECORD
             
   DEFINE lr_item                RECORD LIKE item.*,
          lr_item_man            RECORD LIKE item_man.*,
          lr_ordens              RECORD LIKE ordens.*,
          l_data                 DATE,
          lr_ordens_complement   RECORD LIKE ordens_complement.*,
          l_qtd_dias_horiz       LIKE horizonte.qtd_dias_horizon,
          l_ordem_producao       CHAR(30)

   DEFINE l_ord_docum            LIKE ordens.num_docum,
          l_ord_ordem            LIKE ordens.num_ordem

   DEFINE where_clause          CHAR(2000),
          l_ind                 SMALLINT,
          l_informou_familia    SMALLINT,
          l_coloca_virgula      SMALLINT,
          sql_stmt              CHAR(2000),
          l_cont_ord            SMALLINT,
          l_cont                SMALLINT

   LET l_ordem_producao = lr_man_ordem_new.ordem_producao
   LET p_num_ordem = lr_man_ordem_new.ordem_producao

   #Verifica Item
   WHENEVER ERROR CONTINUE
     SELECT *
       INTO lr_item.*
       FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = lr_man_ordem_new.item
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      ERROR "Item ",lr_man_ordem_new.item, " não cadastrado "
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
    SELECT *
      INTO lr_item_man.*
      FROM item_man
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = lr_man_ordem_new.item
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      ERROR "Item ",lr_man_ordem_new.item, " não encontrado na ITEM_MAN "
      RETURN FALSE
   END IF

   LET lr_ordens.cod_empresa        = p_cod_empresa
   LET lr_ordens.num_ordem          = man0306_atualiza_param()
   
   IF lr_ordens.num_ordem = 0 THEN
      RETURN FALSE
   END IF

   LET m_num_ordem_aux              = lr_ordens.num_ordem

   LET lr_ordens.num_neces          = 0
   LET lr_ordens.num_versao         = 0
   LET lr_ordens.cod_item           = lr_man_ordem_new.item
   LET lr_ordens.cod_item_pai       = 0
   LET lr_ordens.dat_ini            = NULL
   LET lr_ordens.dat_entrega        = lr_man_ordem_new.dat_recebto
   LET l_qtd_dias_horiz             = man0306_dias_horizon(lr_item_man.cod_horizon)
   LET lr_ordens.dat_liberac        = lr_man_ordem_new.dat_liberacao  {Alterado por Manuel 24-03-2009}
#  LET lr_ordens.dat_liberac        = man0306_calcula_data(lr_ordens.dat_entrega,  lr_item_man.tmp_ressup * -1)
   LET lr_ordens.dat_abert          = TODAY                           {Alterado por Manuel 24-03-2009}
#  LET lr_ordens.dat_abert          = man0306_calcula_data(lr_ordens.dat_liberac, l_qtd_dias_horiz * -1)
   LET lr_ordens.qtd_planej         = lr_man_ordem_new.qtd_ordem
   LET lr_ordens.pct_refug          = lr_item_man.pct_refug
   LET lr_ordens.qtd_boas           = 0
   LET lr_ordens.qtd_refug          = 0
   LET lr_ordens.cod_local_prod     = lr_item_man.cod_local_prod
   LET lr_ordens.cod_local_estoq    = lr_item.cod_local_estoq
   LET lr_ordens.num_docum          = lr_man_ordem_new.docum   
   LET lr_ordens.ies_lista_roteiro  = 2
   LET lr_ordens.ies_origem         = 1  {Alteração efetuada por Manuel em 02-04-2009 antes a opção era 3}
   LET lr_ordens.ies_situa          = 3
   LET lr_ordens.ies_abert_liber    = 2
   LET lr_ordens.ies_baixa_comp     = lr_item_man.ies_baixa_comp {Alteração efetuada por Manuel em 02-04-2009 antes a opção era fixo 1}
   LET lr_ordens.dat_atualiz        = TODAY
   LET lr_ordens.num_lote           = " "

   IF  lr_man_ordem_new.num_projeto  IS NOT NULL THEN
       LET lr_ordens.cod_local_prod  = lr_man_ordem_new.num_projeto
       LET lr_ordens.cod_local_estoq = lr_man_ordem_new.num_projeto
       LET lr_ordens.num_docum       = lr_man_ordem_new.docum
   END IF

   IF (mr_par_pcp.parametros[92,92] = "S") AND 
      (lr_item.ies_ctr_lote         = "S") THEN                                   {Alterado por Manuel 24-03-2009}
      IF lr_man_ordem_new.docum <>      lr_man_ordem_new.ordem_mps[1,10] THEN     {Alterado por Manuel 24-03-2009}
         LET lr_ordens.num_lote = lr_man_ordem_new.docum                          {Alterado por Manuel 24-03-2009} 
      ELSE                                                                        {Alterado por Manuel 24-03-2009}
         LET lr_ordens.num_lote = lr_ordens.num_ordem
      END IF                                                                      {Alterado por Manuel 24-03-2009}
   END IF

   LET lr_ordens.cod_roteiro        = lr_item_man.cod_roteiro
   LET lr_ordens.num_altern_roteiro = lr_item_man.num_altern_roteiro
   LET lr_ordens.ies_lista_ordem    = lr_item_man.ies_lista_ordem
   LET lr_ordens.ies_lista_roteiro  = lr_item_man.ies_lista_roteiro
   LET lr_ordens.ies_abert_liber    = lr_item_man.ies_abert_liber
   LET lr_ordens.ies_baixa_comp     = lr_item_man.ies_baixa_comp
   LET lr_ordens.ies_apontamento    = lr_item_man.ies_apontamento
   LET lr_ordens.pct_refug          = lr_item_man.pct_refug
   LET lr_ordens.qtd_sucata         = 0

   
WHENEVER ERROR CONTINUE
    INSERT INTO 
    ordens
    (cod_empresa,
    num_ordem,
    num_neces,
    num_versao,
    cod_item,
    cod_item_pai,
    dat_ini,
    dat_entrega,
    dat_abert,
    dat_liberac,
    qtd_planej,
    pct_refug,
    qtd_boas,
    qtd_refug,
    qtd_sucata,
    cod_local_prod,
    cod_local_estoq,
    num_docum,
    ies_lista_ordem,
    ies_lista_roteiro,
    ies_origem,
    ies_situa,
    ies_abert_liber,
    ies_baixa_comp,
    ies_apontamento,
    dat_atualiz,
    num_lote,
    cod_roteiro,
    num_altern_roteiro)
 VALUES 
   (lr_ordens.cod_empresa,
    lr_ordens.num_ordem,
    lr_ordens.num_neces,
    lr_ordens.num_versao,
    lr_ordens.cod_item,
    lr_ordens.cod_item_pai,
    lr_ordens.dat_ini,
    lr_ordens.dat_entrega,
    lr_ordens.dat_abert,
    lr_ordens.dat_liberac,
    lr_ordens.qtd_planej,
    lr_ordens.pct_refug,
    lr_ordens.qtd_boas,
    lr_ordens.qtd_refug,
    lr_ordens.qtd_sucata,
    lr_ordens.cod_local_prod,
    lr_ordens.cod_local_estoq,
    lr_ordens.num_docum,
    lr_ordens.ies_lista_ordem,
    lr_ordens.ies_lista_roteiro,
    lr_ordens.ies_origem,
    lr_ordens.ies_situa,
    lr_ordens.ies_abert_liber,
    lr_ordens.ies_baixa_comp,
    lr_ordens.ies_apontamento,
    lr_ordens.dat_atualiz,
    lr_ordens.num_lote,
    lr_ordens.cod_roteiro,
    lr_ordens.num_altern_roteiro)   

WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","ORDENS")
      RETURN FALSE
   END IF

   INITIALIZE lr_ordens_complement TO NULL

      IF (mr_par_pcp.parametros[92,92] = "S" OR
          m_rastreia = TRUE ) THEN
         LET lr_ordens_complement.cod_empresa    = p_cod_empresa
         LET lr_ordens_complement.num_ordem      = lr_ordens.num_ordem
         LET lr_ordens_complement.cod_grade_1    = " "
         LET lr_ordens_complement.cod_grade_2    = " "
         LET lr_ordens_complement.cod_grade_3    = " "
         LET lr_ordens_complement.cod_grade_4    = " "
         LET lr_ordens_complement.cod_grade_5    = " "
         LET lr_ordens_complement.num_lote       = lr_ordens.num_lote
         LET lr_ordens_complement.ies_tipo       = "N"
         LET lr_ordens_complement.num_prioridade = 9999
         LET lr_ordens_complement.reservado_1    = NULL
         LET lr_ordens_complement.reservado_2    = NULL
         LET lr_ordens_complement.reservado_3    = NULL
         LET lr_ordens_complement.reservado_4    = NULL
         LET lr_ordens_complement.reservado_5    = NULL
         LET lr_ordens_complement.reservado_6    = NULL
         LET lr_ordens_complement.reservado_7    = NULL
         LET lr_ordens_complement.reservado_8    = NULL

         WHENEVER ERROR CONTINUE
          INSERT INTO ordens_complement VALUES( lr_ordens_complement.* )
         WHENEVER ERROR STOP

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql( "INSERT", "ORDENS_COMPLEMENT" )
            RETURN FALSE
         END IF
      END IF

      IF  man0306_inclui_necessidade(lr_ordens.*) = FALSE THEN
          RETURN FALSE
      END IF

      IF  man0306_inclui_comp_ordem(lr_ordens.*) = FALSE THEN
          RETURN FALSE
      END IF

      IF  man0306_inclui_oper_ordem(lr_ordens.*) = FALSE THEN
          RETURN FALSE
      END IF

   RETURN TRUE

END FUNCTION

#--------------------------------------------#
FUNCTION man0306_inclui_necessidade(lr_ordens)
#--------------------------------------------#

   DEFINE lr_ordens        RECORD LIKE ordens.*

   DEFINE l_texto          CHAR(5000),
          lr_necessidades  RECORD LIKE necessidades.*

   CALL man0306_carrega_feriado()
   CALL man0306_carrega_semana()

   LET lr_necessidades.cod_empresa  = p_cod_empresa
   LET lr_necessidades.num_versao   = lr_ordens.num_versao
   LET lr_necessidades.cod_item_pai = lr_ordens.cod_item
   LET lr_necessidades.num_ordem    = lr_ordens.num_ordem
   LET lr_necessidades.qtd_saida    = 0
   LET lr_necessidades.num_docum    = lr_ordens.num_docum
   LET lr_necessidades.ies_origem   = lr_ordens.ies_origem
   LET lr_necessidades.ies_situa    = "3"

   IF man0306_carrega_temp_estrut(lr_ordens.cod_item, lr_ordens.dat_liberac) THEN
   ELSE
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("CARGA-2","MAN7840")
         RETURN FALSE
      END IF
   END IF

   WHENEVER ERROR CONTINUE
    DECLARE cq_estrutur CURSOR WITH HOLD FOR
     SELECT * FROM t_estrut_912
   WHENEVER ERROR STOP

   WHENEVER ERROR CONTINUE
    FOREACH cq_estrutur INTO p_t_estrut.*
   WHENEVER ERROR STOP

      LET lr_necessidades.num_neces = man0306_atualiza_neces()
      LET lr_necessidades.dat_neces = man0306_calcula_data(lr_ordens.dat_liberac,
                                    (p_t_estrut.tmp_ressup_sobr -
                                     p_t_estrut.tmp_ressup))
      LET lr_necessidades.cod_item = p_t_estrut.cod_item_compon
      LET lr_necessidades.qtd_necessaria = lr_ordens.qtd_planej *
          p_t_estrut.qtd_necessaria * (100/(100-p_t_estrut.pct_refug))

      WHENEVER ERROR CONTINUE
        INSERT INTO necessidades VALUES (lr_necessidades.*)
      WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","NECESSIDADES")
         RETURN FALSE
      END IF
   END FOREACH

   RETURN TRUE

END FUNCTION

#-------------------------------------------------#
 FUNCTION man0306_inclui_oper_ordem(lr_ordens)
#-------------------------------------------------#

   DEFINE lr_ordens              RECORD LIKE ordens.*,
          lr_consumo             RECORD LIKE consumo.*,
          lr_consumo_compl       RECORD LIKE consumo_compl.*,
          lr_consumo_txt         RECORD LIKE consumo_txt.*,
          l_parametro            CHAR(07),
          l_entrou               SMALLINT,
          l_num_ordem            CHAR(30),
          l_status               SMALLINT,
          l_arranjo              CHAR(5)

   DEFINE lr_man_operacao_ordem  RECORD
			    empresa             char(2),
			    ordem_producao      char(30),
			    item                char(30),
			    operacao            char(5),
			    des_operacao        char(40),
			    sequencia_operacao  decimal(3,0),
			    centro_trabalho     char(10),
			    arranjo             char(5),
			    tmp_maquina_prepar  decimal(8,2),
			    tmp_maq_execucao    decimal(14,6),
			    tmp_mdo_prepar      decimal(8,2),
			    tmp_mdo_execucao    decimal(14,6),
			    relacao_ferramenta  char(150),
			    dat_ini_planejada   datetime year to second,
			    dat_trmn_planejada  datetime year to second,
			    qtd_planejada       decimal(12,2),
			    qtd_real            decimal(12,2),
			    qtd_sucata          decimal(12,2),
			    status_import       char(1)
   END RECORD
   
   DEFINE lr_man_estrut_oper  RECORD
   			  empresa             char(2),
			    item_componente     char(15),
			    ies_tip_item        char(01),
			    qtd_necess          decimal(14,7),
			    pct_refugo          decimal(6,3),
			    parametro_geral     char(20)
   END RECORD
   
   LET l_entrou = FALSE

   LET l_num_ordem = p_num_ordem

   WHENEVER ERROR CONTINUE
   DECLARE cq_operacao CURSOR WITH HOLD FOR
    SELECT *
      FROM man_operacao_ordem
     WHERE man_operacao_ordem.empresa        = p_cod_empresa
       AND man_operacao_ordem.ordem_producao = l_num_ordem
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","CQ_OPERACAO")
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
    FOREACH cq_operacao INTO lr_man_operacao_ordem.*
   WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("FOREACH","CQ_OPERACAO")
         RETURN FALSE
      END IF

      WHENEVER ERROR CONTINUE
        SELECT *
          FROM item_man
         WHERE item_man.cod_empresa = p_cod_empresa
           AND item_man.cod_item    = lr_ordens.cod_item
#           AND item_man.ies_apontamento = "1"   {Alterado por Manuel em 28-04-2009 na versão 05.10.13}
      WHENEVER ERROR STOP

      IF sqlca.sqlcode = 0 THEN
         WHENEVER ERROR CONTINUE
          DECLARE cq_consumo CURSOR WITH HOLD FOR
           SELECT consumo.*, consumo_compl.*
             FROM consumo, consumo_compl
            WHERE consumo.cod_empresa         = p_cod_empresa
              AND consumo.cod_item            = lr_man_operacao_ordem.item
              AND consumo.cod_roteiro         = lr_ordens.cod_roteiro
              AND consumo.num_altern_roteiro  = lr_ordens.num_altern_roteiro
              AND consumo.num_seq_operac      = lr_man_operacao_ordem.sequencia_operacao #teste
              AND consumo_compl.cod_empresa   = p_cod_empresa

              AND consumo_compl.num_processo  = consumo.parametro[1,7]
              AND ((consumo_compl.dat_validade_ini IS NULL AND consumo_compl.dat_validade_fim IS NULL)
               OR  (consumo_compl.dat_validade_ini IS NULL AND consumo_compl.dat_validade_fim >= lr_ordens.dat_liberac)
               OR  (consumo_compl.dat_validade_fim IS NULL AND consumo_compl.dat_validade_ini <= lr_ordens.dat_liberac)
               OR  (lr_ordens.dat_liberac BETWEEN consumo_compl.dat_validade_ini AND consumo_compl.dat_validade_fim))
         WHENEVER ERROR STOP

         WHENEVER ERROR CONTINUE
          FOREACH cq_consumo INTO lr_consumo.*, lr_consumo_compl.*
         WHENEVER ERROR STOP

            LET m_cod_cent_trab = lr_consumo.cod_cent_trab
            LET l_entrou = TRUE

            LET l_parametro = lr_consumo.parametro[1,7]

            WHENEVER ERROR CONTINUE
              SELECT cod_empresa
                FROM arranjo
               WHERE cod_empresa = p_cod_empresa
                 AND cod_arranjo = lr_man_operacao_ordem.arranjo
            WHENEVER ERROR STOP

            IF sqlca.sqlcode <> 0 THEN
               IF sqlca.sqlcode <> 100 THEN
                  CALL log003_err_sql("SELECT","CONSUMO")
                  RETURN FALSE
               ELSE
                  LET l_arranjo = lr_consumo.cod_arranjo
               END IF
            ELSE
               LET l_arranjo = lr_man_operacao_ordem.arranjo
            END IF

            WHENEVER ERROR CONTINUE
              INSERT INTO ord_oper VALUES (p_cod_empresa,
                                           lr_ordens.num_ordem,
                                           lr_ordens.cod_item,
                                           lr_man_operacao_ordem.operacao,
                                           lr_man_operacao_ordem.sequencia_operacao,
                                           lr_consumo.cod_cent_trab,
                                           l_arranjo,
                                           lr_consumo.cod_cent_cust,
                                           lr_ordens.dat_entrega,
                                           NULL,
                                           lr_man_operacao_ordem.qtd_planejada,
                                           0,
                                           0,
                                           0,
                                           lr_consumo.qtd_horas,
                                           lr_consumo.qtd_horas_setup,
                                           lr_consumo_compl.ies_apontamento,
                                           lr_consumo_compl.ies_impressao,
                                           lr_consumo_compl.ies_oper_final,
                                           lr_consumo_compl.pct_refug,
                                           lr_consumo_compl.tmp_producao,
                                           l_parametro)
            WHENEVER ERROR STOP

            IF sqlca.sqlcode = 0 OR
               log0030_err_sql_registro_duplicado() THEN
            ELSE
               CALL log003_err_sql("INCLUSAO","ORD_OPER")
               RETURN FALSE
               EXIT FOREACH
            END IF

            WHENEVER ERROR CONTINUE
              INSERT INTO man_oper_compl(empresa
                                        ,ordem_producao
                                        ,operacao
                                        ,sequencia_operacao
                                        ,dat_ini_planejada
                                        ,dat_trmn_planejada)
              VALUES (p_cod_empresa
                     ,lr_ordens.num_ordem
                     ,lr_man_operacao_ordem.operacao
                     ,lr_man_operacao_ordem.sequencia_operacao
                     ,lr_man_operacao_ordem.dat_ini_planejada
                     ,lr_man_operacao_ordem.dat_trmn_planejada)
            WHENEVER ERROR STOP

            IF sqlca.sqlcode <> 0 AND
               sqlca.sqlcode <> -239 AND
               sqlca.sqlcode <> -268 THEN
               CALL log003_err_sql("INSERT3","MAN_OPER_COMPL")
               RETURN FALSE
            END IF

            WHENEVER ERROR CONTINUE
             DECLARE cq_cons_txt CURSOR WITH HOLD FOR
              SELECT consumo_txt.*
                FROM consumo_txt
               WHERE consumo_txt.cod_empresa  = lr_consumo_compl.cod_empresa
                 AND consumo_txt.num_processo = lr_consumo_compl.num_processo
            WHENEVER ERROR STOP

            WHENEVER ERROR CONTINUE
             FOREACH cq_cons_txt INTO lr_consumo_txt.*
            WHENEVER ERROR STOP

               WHENEVER ERROR CONTINUE
                 INSERT INTO ord_oper_txt VALUES (p_cod_empresa,
                                                  lr_ordens.num_ordem,
                                                  lr_consumo_txt.num_processo,
                                                  lr_consumo_txt.ies_tipo,
                                                  lr_consumo_txt.num_seq_linha,
                                                  lr_consumo_txt.tex_processo)
               WHENEVER ERROR STOP
               IF sqlca.sqlcode = 0 OR
                  log0030_err_sql_registro_duplicado() THEN
               ELSE
                  CALL log003_err_sql("INCLUSAO", "ORD_OPER_TXT")
                  RETURN FALSE
               END IF
            END FOREACH
            
#      Alimenta a tabela MAN_OP_COMPONENTE_OPERACAO a partir da tabela MAN_ESTRUT_OPER para a versão 10.02
            
            WHENEVER ERROR CONTINUE
             DECLARE cq_estr_oper CURSOR WITH HOLD FOR
              SELECT MAN_ESTRUT_OPER.EMPRESA, 
                     MAN_ESTRUT_OPER.ITEM_COMPONENTE, 
                     ITEM.IES_TIP_ITEM, 
                     MAN_ESTRUT_OPER.QTD_NECESS, 
                     MAN_ESTRUT_OPER.PCT_REFUGO, 
                     MAN_ESTRUT_OPER.PARAMETRO_GERAL 
                     FROM MAN_ESTRUT_OPER,ITEM 
                     WHERE MAN_ESTRUT_OPER.EMPRESA             = p_cod_empresa 
                     AND MAN_ESTRUT_OPER.ITEM                  = lr_man_operacao_ordem.item
                     AND MAN_ESTRUT_OPER.ROTEIRO               = lr_ordens.cod_roteiro 
                     AND MAN_ESTRUT_OPER.NUM_ALTERN_ROTEIRO    = lr_ordens.num_altern_roteiro 
                     AND MAN_ESTRUT_OPER.SEQUENCIA_OPERACAO    = lr_man_operacao_ordem.sequencia_operacao  
                     AND MAN_ESTRUT_OPER.EMPRESA=ITEM.COD_EMPRESA 
                     AND MAN_ESTRUT_OPER.ITEM_COMPONENTE=ITEM.COD_ITEM 
                     AND (MAN_ESTRUT_OPER.DAT_VALID_INICIAL IS NULL OR 
                          MAN_ESTRUT_OPER.DAT_VALID_INICIAL<=lr_ordens.dat_liberac) 
                     AND (MAN_ESTRUT_OPER.DAT_VALID_FINAL IS NULL OR 
                          MAN_ESTRUT_OPER.DAT_VALID_FINAL>= lr_ordens.dat_liberac) 
                     ORDER BY MAN_ESTRUT_OPER.PARAMETRO_GERAL[6, 10]

             FOREACH cq_estr_oper INTO lr_man_estrut_oper.*
            WHENEVER ERROR STOP
               LET  p_seq_comp   =  0 
               
               SELECT MIN(num_seq) 
               INTO   p_seq_comp
               FROM ord_compon  
               WHERE cod_empresa     = p_cod_empresa   
               AND num_ordem         = lr_ordens.num_ordem 
               AND cod_item_compon   = lr_man_estrut_oper.item_componente  
               AND ies_tip_item      = lr_man_estrut_oper.ies_tip_item
               AND qtd_necessaria    = lr_man_estrut_oper.qtd_necess 
#               AND cod_local_baixa   = lr_ordens.cod_local_prod 
#               AND pct_refug         = lr_consumo_compl.pct_refug
                    
               IF   sqlca.sqlcode = 0  THEN              
                    IF (p_seq_comp   IS NULL)  
                    OR (p_seq_comp   = 0    ) THEN 
                        LET p_seq_comp   = 1
                    END IF                           
                    WHENEVER ERROR CONTINUE
                    INSERT INTO man_op_componente_operacao VALUES (p_cod_empresa,
                                                                lr_ordens.num_ordem,
                                                                lr_ordens.cod_roteiro ,
                                                                lr_ordens.num_altern_roteiro,
                                                                lr_man_operacao_ordem.sequencia_operacao,
                                                                lr_man_operacao_ordem.item,
                                                                lr_man_estrut_oper.item_componente,
                                                                lr_man_estrut_oper.ies_tip_item,
                                                                lr_ordens.dat_entrega,
                                                                lr_man_estrut_oper.qtd_necess,
                                                                lr_ordens.cod_local_prod,
                                                                lr_consumo.cod_cent_trab,
                                                                lr_man_estrut_oper.pct_refugo, 
                                                                p_seq_comp)
                   IF sqlca.sqlcode = 0 OR
                      log0030_err_sql_registro_duplicado() THEN
                   ELSE
                      CALL log003_err_sql("INCLUSAO", "MAN_OP_COMPONENTE_OPERACAO")
                      RETURN FALSE
                   END IF
               ELSE
                  CALL log003_err_sql("LEITURA", "ORD_COMPON 2")
                  RETURN FALSE
               END IF                                                 
               
            END FOREACH
            
         END FOREACH

      END IF
   END FOREACH

   RETURN TRUE

END FUNCTION

#------------------------------------#
 FUNCTION man0306_inclui_comp_ordem(lr_ordens)
#------------------------------------#
   DEFINE lr_item     RECORD LIKE item.*,
          lr_ordens   RECORD LIKE ordens.*

   WHENEVER ERROR CONTINUE
    DECLARE c_neces CURSOR WITH HOLD FOR
     SELECT necessidades.*
       FROM necessidades
      WHERE necessidades.cod_empresa   = p_cod_empresa
        AND necessidades.num_ordem     = lr_ordens.num_ordem
      ORDER BY num_neces
   WHENEVER ERROR STOP

   WHENEVER ERROR CONTINUE
    FOREACH c_neces INTO mr_necessidades.*
   WHENEVER ERROR STOP
      LET mr_ord_compon.cod_empresa     = p_cod_empresa
      LET mr_ord_compon.cod_item_pai    = mr_necessidades.num_neces  {novo conceito desta versao}
      LET mr_ord_compon.num_ordem       = lr_ordens.num_ordem
      LET mr_ord_compon.cod_item_compon = mr_necessidades.cod_item
      LET mr_ord_compon.dat_entrega     = mr_necessidades.dat_neces
      INITIALIZE lr_item.* TO NULL

      WHENEVER ERROR CONTINUE
        SELECT item.*
          INTO lr_item.*
          FROM item
         WHERE item.cod_empresa   = p_cod_empresa
           AND item.cod_item      = mr_necessidades.cod_item
      WHENEVER ERROR STOP

      IF lr_ordens.ies_baixa_comp  = "1" THEN
         LET mr_ord_compon.cod_local_baixa  = lr_ordens.cod_local_prod
      ELSE
         LET mr_ord_compon.cod_local_baixa  = lr_item.cod_local_estoq
      END IF

##### LET mr_ord_compon.cod_local_baixa = lr_ordens.cod_local_prod  { alterado por Manuel em 08-04-2009} 

      IF mr_ord_compon.cod_local_baixa IS NULL THEN
         LET mr_ord_compon.cod_local_baixa = "NULO"
      END IF

      LET mr_ord_compon.qtd_necessaria = (mr_necessidades.qtd_necessaria /
                                          lr_ordens.qtd_planej)

      LET mr_ord_compon.cod_cent_trab = m_cod_cent_trab
      LET mr_ord_compon.pct_refug     = 0  { nesta nova versao nao eh mais necessario}
      LET mr_ord_compon.ies_tip_item  = lr_item.ies_tip_item { nesta nova versao nao eh mais necessario}
      LET mr_ord_compon.num_seq       = 0

      WHENEVER ERROR CONTINUE
        INSERT INTO ord_compon VALUES (mr_ord_compon.*)
      WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql ("INCLUSAO","ORD_COMPON")
         RETURN FALSE
      END IF
   END FOREACH

   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION man0306_carrega_feriado()
#---------------------------------#
   DEFINE p_feriado           RECORD LIKE feriado.*

   LET p_dep1 = 0
   WHENEVER ERROR CONTINUE
    DECLARE cq_feriado CURSOR FOR
     SELECT *
       INTO p_feriado.*
       FROM feriado
      WHERE cod_empresa = p_cod_empresa
   WHENEVER ERROR STOP

   WHENEVER ERROR CONTINUE
    FOREACH cq_feriado
   WHENEVER ERROR STOP

      LET p_dep1 = p_dep1 + 1
      IF p_dep1 > 100 THEN
         PROMPT " Tabela de Feriados com mais de 100 ocorrencias " FOR CHAR m_comando
         EXIT PROGRAM
      END IF
      LET t1_feriado[p_dep1].dat_ref = p_feriado.dat_ref
      LET t1_feriado[p_dep1].ies_situa = p_feriado.ies_situa
   END FOREACH

END FUNCTION

#--------------------------------#
 FUNCTION man0306_carrega_semana()
#--------------------------------#

   DEFINE p_semana           RECORD LIKE semana.*

   LET p_dep2 = 0
   WHENEVER ERROR CONTINUE
    DECLARE cq_semana CURSOR FOR
     SELECT *
       INTO p_semana.*
       FROM semana
      WHERE cod_empresa = p_cod_empresa
   WHENEVER ERROR STOP

   WHENEVER ERROR CONTINUE
   FOREACH cq_semana
   WHENEVER ERROR STOP
      LET p_dep2 = p_dep2 + 1
      IF p_dep2 > 7 THEN
         PROMPT " Tabela de Semanas com mais de 7 ocorrencias " FOR CHAR m_comando
         EXIT PROGRAM
      END IF
      LET t2_semana[p_dep2].ies_dia_semana = p_semana.ies_dia_semana
      LET t2_semana[p_dep2].ies_situa = p_semana.ies_situa
   END FOREACH

END FUNCTION

#------------------------------------------------#
 FUNCTION man0306_calcula_data(p_data, p_qtd_dias)
#------------------------------------------------#
   DEFINE p_data              DATE,
          p_x                 INTEGER,
          p_qtd_dias          INTEGER

   IF p_qtd_dias < 0 THEN
      LET p_qtd_dias = p_qtd_dias * -1    { tornar positivo para o FOR}
      FOR p_x = 1 TO p_qtd_dias
         LET p_data = p_data - 1
         WHILE TRUE
            FOR p_ind1 = 1 TO p_dep1
               IF p_data = t1_feriado[p_ind1].dat_ref THEN
                  IF t1_feriado[p_ind1].ies_situa = "3" THEN
                     LET p_data = p_data - 1
                     CONTINUE WHILE
                  END IF
               END IF
            END FOR

            FOR p_ind2 = 1 TO p_dep2
               IF WEEKDAY(p_data) = t2_semana[p_ind2].ies_dia_semana THEN
                  IF t2_semana[p_ind2].ies_situa = "3" THEN
                     LET p_data = p_data - 1
                     CONTINUE WHILE
                  END IF
               END IF
            END FOR
            EXIT WHILE
         END WHILE
      END FOR
      RETURN p_data
   ELSE
      IF p_qtd_dias > 0 THEN
         FOR p_x = 1 TO p_qtd_dias
            LET p_data = p_data + 1
            WHILE TRUE
               FOR p_ind1 = 1 TO p_dep1
                  IF p_data = t1_feriado[p_ind1].dat_ref THEN
                     IF t1_feriado[p_ind1].ies_situa = "3" THEN
                        LET p_data = p_data + 1
                        CONTINUE WHILE
                     END IF
                  END IF
               END FOR

               FOR p_ind2 = 1 TO p_dep2
                  IF WEEKDAY(p_data) = t2_semana[p_ind2].ies_dia_semana THEN
                     IF t2_semana[p_ind2].ies_situa = "3" THEN
                        LET p_data = p_data + 1
                        CONTINUE WHILE
                     END IF
                  END IF
               END FOR
               EXIT WHILE
            END WHILE
         END FOR
         RETURN p_data
      END IF
   END IF

   RETURN p_data

 END FUNCTION

#--------------------------#
 FUNCTION man0306_par_pcp()
#--------------------------#

#   CALL sup0063_cria_temp_controle()

   WHENEVER ERROR CONTINUE
     SELECT *
       INTO mr_par_logix.*
       FROM par_logix
      WHERE cod_empresa = p_cod_empresa
   WHENEVER ERROR STOP

   IF sqlca.sqlcode = 0 THEN
      IF mr_par_logix.parametros[50,50] = "S" THEN
         LET m_rastreia = TRUE
      ELSE
         LET m_rastreia = FALSE
      END IF
   ELSE
      CALL log0030_mensagem( "Tabela de Parâmetros do Logix não encontrada.", "info" )
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
     SELECT *
       INTO mr_par_pcp.*
       FROM par_pcp
      WHERE par_pcp.cod_empresa = p_cod_empresa
   WHENEVER ERROR STOP

   IF sqlca.sqlcode = 0 THEN
      IF mr_par_pcp.parametros[116,116] = "N" THEN
         LET m_grava_oplote = FALSE
      ELSE
         LET m_grava_oplote = TRUE
      END IF
      RETURN TRUE
   ELSE
      CALL log0030_mensagem( "Tabela de Parâmetros do Manufatura não encontrada.", "info" )
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION man0306_popup_familia()
#-------------------------------#

   DEFINE l_familia_zoom   LIKE familia.cod_familia

   LET l_familia_zoom = log009_popup(6,25,"FAMÍLIAS","familia","cod_familia","den_familia","man0040","S","")

   IF l_familia_zoom IS NOT NULL THEN
      CURRENT WINDOW IS w_man0306
      LET ma_familia[m_arr_curr].cod_familia = l_familia_zoom
      DISPLAY BY NAME ma_familia[m_arr_curr].cod_familia
   END IF

   CALL log006_exibe_teclas("01 02 03 07",p_versao)
   CURRENT WINDOW IS w_man0306

   LET INT_FLAG = 0

END FUNCTION

#--------------------------------------------#
FUNCTION man0306_dias_horizon(p_cod_horizon)
#--------------------------------------------#

   DEFINE p_cod_horizon LIKE horizonte.cod_horizon,
          p_qtd_dias_horizon LIKE horizonte.qtd_dias_horizon
   
   SELECT qtd_dias_horizon
     INTO p_qtd_dias_horizon
     FROM horizonte
    WHERE cod_empresa = p_cod_empresa
      AND cod_horizon = p_cod_horizon
   
   IF STATUS <> 0 THEN
      LET p_qtd_dias_horizon = 0
   END IF
   
   RETURN(p_qtd_dias_horizon)
   
END FUNCTION

#-------------------------------#
FUNCTION man0306_atualiza_param()
#-------------------------------#

   DEFINE p_prx_num_op LIKE par_mrp.prx_num_ordem

   SELECT prx_num_ordem
     INTO p_prx_num_op
     FROM par_mrp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','par_mrp:num_op')
      RETURN(0)
   END IF

   IF p_prx_num_op IS NULL THEN
      LET p_prx_num_op = 1
   ELSE
      LET p_prx_num_op = p_prx_num_op + 1
   END IF

   UPDATE par_mrp
      SET prx_num_ordem = p_prx_num_op
    WHERE cod_empresa   = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Update','par_mrp:num_op')
      RETURN(0)
   END IF

   RETURN(p_prx_num_op)
   
END FUNCTION

#--------------------------------#
FUNCTION man0306_atualiza_neces()
#--------------------------------#

   DEFINE p_prx_num_neces LIKE par_mrp.prx_num_neces
   
   SELECT prx_num_neces
     INTO p_prx_num_neces
     FROM par_mrp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','par_mrp:num_neces')
      RETURN(0)
   END IF

   IF p_prx_num_neces IS NULL THEN
      LET p_prx_num_neces = 0
   ELSE
      LET p_prx_num_neces = p_prx_num_neces + 1
   END IF
   
   UPDATE par_mrp
      SET prx_num_neces = p_prx_num_neces
    WHERE cod_empresa   = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Update','par_mrp:num_neces')
      RETURN(0)
   END IF

   RETURN(p_prx_num_neces)
   
END FUNCTION

#----------------------------------#
FUNCTION man0306_cria_temp_estrut()
#----------------------------------#

   WHENEVER ERROR CONTINUE
   
   DROP TABLE t_estrut_912

   IF STATUS = 0 OR STATUS -206 THEN 
 
      CREATE TABLE t_estrut_912(
         cod_item_pai    CHAR(15),
         cod_item_compon CHAR(15),
         qtd_necessaria  DECIMAL(14,7),
         pct_refug       DECIMAL(6,3),
         tmp_ressup      DECIMAL(3,0),
         tmp_ressup_sobr DECIMAL(3,0)

       );

      IF SQLCA.SQLCODE <> 0 THEN 
         RETURN FALSE
      END IF
   ELSE
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------------------------------------#
FUNCTION man0306_carrega_temp_estrut(p_cod_item_pai, p_dat_liberac)
#-----------------------------------------------------------------#

   DEFINE p_cod_item_pai    LIKE item.cod_item,
          p_dat_liberac     LIKE ordens.dat_liberac,
          p_cod_item_compon LIKE estrutura.cod_item_compon,
          p_qtd_necessaria  LIKE estrutura.qtd_necessaria,
          p_pct_refug       LIKE estrutura.pct_refug,
          P_tmp_ressup_sobr LIKE estrutura.tmp_ressup_sobr,
          P_tmp_ressup      LIKE item_man.tmp_ressup

   DELETE FROM t_estrut_912
   
   DECLARE cq_temp CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria, 
           pct_refug,      
           tmp_ressup_sobr,
           parametros
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_cod_item_pai
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
            (dat_validade_ini IS NULL AND dat_validade_fim >= p_dat_liberac) OR
            (dat_validade_fim IS NULL AND dat_validade_ini <= p_dat_liberac )OR
            (p_dat_liberac BETWEEN dat_validade_ini AND dat_validade_fim))
     ORDER BY parametros
       
   FOREACH cq_temp INTO 
           p_cod_item_compon,
           p_qtd_necessaria,
           p_pct_refug,
           P_tmp_ressup_sobr

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_temp')
         RETURN FALSE
      END IF
      
      SELECT tmp_ressup
        INTO P_tmp_ressup
        FROM item_man
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item_pai

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','item_man:cq_temp')
         RETURN FALSE
      END IF
      
      INSERT INTO t_estrut_912
       VALUES(p_cod_item_pai,
              p_cod_item_compon,
              p_qtd_necessaria,
              p_pct_refug,
              P_tmp_ressup,
              P_tmp_ressup_sobr)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','t_estrut_912')
         RETURN FALSE
      END IF
              
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#----------------------------FIM DO PROGRAMA------------------------#
