#------------------------------------------------------------------------------#
# SISTEMA.: MANUFATURA                                                         #
# PROGRAMA: pol0922                                                            #
# OBJETIVO: PROGRAMA DE IMPORTACAO DE DADOS DO DRUMMER PARA O LOGIX - PADRAO   #
# DATA....: 05/12/2008                                                         #   
# ALTERA��ES                                                                   #
# Dia 28-04-2009(Manuel) vers�o 10.02.05 O programa foi alterado para que grave#
#                        as opera��es da ordem independentemente se o indicador#
#                        na tabela ITEM_MAN.ies_apontamento indicar S/N, at�   #
#                        ent�o o programa somente gravava as opera��es caso    #
#                        esse campo estivesse igual a 'S'                      # 
#                                                                              #
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

   DEFINE t1_feriado ARRAY[500] OF RECORD
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

   LET p_versao = "pol0922-10.02.12"  

   WHENEVER ERROR CONTINUE
   
     CALL log1400_isolation()
     SET LOCK MODE TO WAIT 10
   

   DEFER INTERRUPT

   CALL log140_procura_caminho("pol0922.iem") RETURNING m_help_file

   OPTIONS
     HELP FILE m_help_file,
     HELP KEY control-w

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
  
   IF p_status = 0 THEN
      CALL pol0922_controle()
   END IF

END MAIN


#--------------------------#
 FUNCTION pol0922_controle()
#--------------------------#

   CALL log006_exibe_teclas("01", p_versao)

   CALL log130_procura_caminho("pol0922") RETURNING m_caminho

   OPEN WINDOW w_pol0922 AT 2,2  WITH FORM m_caminho
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol0922_par_pcp() THEN
       RETURN
   END IF

   MENU "OPCAO"

      COMMAND "Informar"   "Informar par�metros para importa��o do Drummer para o Logix."
         HELP 009
         MESSAGE ""
         CALL pol0922_inicializa_campos()
         IF log005_seguranca( p_user, "MANUFAT","pol0922","CO") THEN
            LET m_ies_informou = FALSE
            LET m_ies_tipo = ''

            IF pol0922_entrada_parametros() THEN
               IF pol0922_processa_importacao() THEN
                  NEXT OPTION "Fim"
               ELSE
                  ERROR 'Processamento cancelado!!!'
               END IF
            ELSE
               ERROR 'Opera��o cancelada!!!'
            END IF
         END IF

      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol0922_sobre() 

      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR m_comando
         RUN m_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando

      COMMAND "Fim" " Retorna ao Menu Anterior "
         HELP 008
         MESSAGE ""
         EXIT MENU

   END MENU

   CLOSE WINDOW w_pol0922

 END FUNCTION


#-----------------------#
FUNCTION pol0922_sobre()
#-----------------------#

   DEFINE p_msg CHAR(100)

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------------#
FUNCTION pol0922_entrada_parametros()
#------------------------------------#

   LET INT_FLAG = FALSE
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0922

   INPUT ARRAY ma_familia WITHOUT DEFAULTS FROM s_familia.*

      BEFORE ROW
         LET m_arr_curr  = ARR_CURR()
         LET sc_curr     = SCR_LINE()
         LET m_arr_count = ARR_COUNT()

      AFTER FIELD cod_familia
         IF ma_familia[m_arr_curr].cod_familia IS NOT NULL THEN
            IF NOT pol0922_familia_existe() THEN
               NEXT FIELD cod_familia
            END IF

            IF pol0922_familia_duplicada(m_arr_curr) THEN
               NEXT FIELD cod_familia
            END IF
         END IF

         IF g_ies_grafico THEN
            --# CALL fgl_dialog_setkeylabel('Control-Z','Zoom')
         ELSE
            DISPLAY " (Zoom) " AT 3,55
         END IF

      ON KEY (control-z, f4)
         CALL pol0922_popup_familia()

      ON KEY (f1, control-w)
         CALL pol0922_help()

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
FUNCTION pol0922_familia_duplicada(l_arr_curr)
#---------------------------------------------#

   DEFINE l_arr_curr SMALLINT,
          l_ind      SMALLINT

   FOR l_ind = 1 TO m_arr_curr
      IF l_ind <> l_arr_curr AND
         ma_familia[l_ind].cod_familia = ma_familia[m_arr_curr].cod_familia THEN
         ERROR " Familia j� informada. "
         RETURN TRUE
      END IF
   END FOR

   RETURN FALSE

END FUNCTION

#---------------------------------#
 FUNCTION pol0922_familia_existe()
#---------------------------------#

   
     SELECT cod_familia
       FROM familia
      WHERE cod_empresa = p_cod_empresa
        AND cod_familia = ma_familia[m_arr_curr].cod_familia
   

   IF sqlca.sqlcode <> 0 THEN
      IF sqlca.sqlcode <> 100 THEN
         CALL log003_err_sql("SELECT","FAMILIA")
      ELSE
         ERROR " Fam�lia n�o cadastrada. "
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------#
FUNCTION pol0922_help()
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
FUNCTION pol0922_inicializa_campos()
#-----------------------------------#

   INITIALIZE ma_familia
             ,m_ies_informou
             ,m_ies_processou
             ,m_ocorreu_erro TO NULL

END FUNCTION


#------------------------------------#
FUNCTION pol0922_processa_importacao()
#------------------------------------#

   DEFINE l_mensagem            CHAR(100)
   
   DEFINE lr_ordens             RECORD LIKE ordens.*,
          lr_ord_oper           RECORD LIKE ord_oper.*,
          lr_necessidades       RECORD LIKE necessidades.*,
          lr_man_ordem_drummer  RECORD LIKE man_ordem_drummer.*,
          lr_man_oper_drummer   RECORD LIKE man_oper_drummer.*,
          lr_man_necd_drummer   RECORD LIKE man_necd_drummer.*
          

   DEFINE l_ies_tip_item        LIKE item.ies_tip_item
   DEFINE l_ordem_mps           CHAR(30),
          l_num_docum           CHAR(10),
          l_num_oclinha         LIKE ordens.num_lote

   DEFINE where_clause          CHAR(2000),
          l_ind                 SMALLINT,
          l_informou_familia    SMALLINT,
          l_coloca_virgula      SMALLINT,
          sql_stmt              CHAR(1000),
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


   IF NOT pol0922_cria_temp_estrut() THEN
      RETURN FALSE
   END IF

   #-- Inicializa as vari�veis usadas
   INITIALIZE lr_man_ordem_drummer TO NULL
   INITIALIZE m_num_ordem_aux TO NULL

   LET m_ies_processou = FALSE
   LET m_ocorreu_erro  = FALSE

   LET l_count = 0

   
   SELECT COUNT(empresa)
     INTO l_count
     FROM man_ordem_drummer
    WHERE empresa       = p_cod_empresa
      AND status_import <> "X"
       OR status_import IS NULL
   
   IF l_count = 0 THEN
      CALL log0030_mensagem("N�o h� dados a serem importados","info")
      RETURN FALSE
   END IF

   MESSAGE " Excluindo dados . . . " ATTRIBUTE (REVERSE)
   #lds CALL LOG_refresh_display()	
   
   CALL log085_transacao("BEGIN")

   #Exclui ordens de situacao 3 

    LET sql_stmt = " SELECT num_ordem",
                   "   FROM ordens"

    LET where_clause =   "  WHERE ordens.cod_empresa = '",p_cod_empresa,"'",
                            " AND ordens.ies_situa = '3'"

   # Verifica se foi informada alguma fam�lia
   FOR l_ind = 1 TO ARR_COUNT()
      IF ma_familia[l_ind].cod_familia IS NOT NULL THEN
         LET l_informou_familia = TRUE
         LET where_clause = where_clause CLIPPED, " AND item.cod_familia IN ("
         EXIT FOR
      END IF
   END FOR

   # Inclui as fam�lias selecionadas no SELECT
   LET l_coloca_virgula = FALSE
   FOR l_ind =1 TO ARR_COUNT()
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
   #lds CALL LOG_refresh_display()	

   PREPARE var_ordens_elim FROM sql_stmt
   DECLARE cq_ordens_eliminadas CURSOR FOR var_ordens_elim

   FOREACH cq_ordens_eliminadas INTO l_num_ordem

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_ordens_eliminadas')
         RETURN FALSE
      END IF
      
           DISPLAY l_num_ordem AT 21,28
           
           #Elimina ordens_complement
           
            DELETE FROM ordens_complement
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           

           IF  sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("DELETE","ORDENS_COMPLEMENT")
               CALL log085_transacao("ROLLBACK")
               RETURN FALSE
           END IF

           #Elimina necessidades
           
            DELETE FROM necessidades
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","NECESSIDADES")
             CALL log085_transacao("ROLLBACK")
             RETURN FALSE
           END IF

           #Elimina ord_oper
           
            DELETE FROM ord_oper
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","ORD_OPER")
             CALL log085_transacao("ROLLBACK")
             RETURN FALSE
           END IF

           #Elimina man_oper_compl
           
            DELETE FROM man_oper_compl
             WHERE empresa            = p_cod_empresa
               AND ordem_producao     = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("DELETE","MAN_OPER_COMPL")
              CALL log085_transacao("ROLLBACK")
              RETURN FALSE
           END IF

           #Elimina ord_compon
           
            DELETE FROM ord_compon
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","ORD_COMPON")
             CALL log085_transacao("ROLLBACK")
             RETURN FALSE
           END IF

           #Elimina Ordens
           
             DELETE FROM ordens
              WHERE cod_empresa      = p_cod_empresa
                AND num_ordem        = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("DELETE","ORDENS")
              CALL log085_transacao("ROLLBACK")
              RETURN FALSE
           END IF

   END FOREACH

   LET sql_stmt = "SELECT man_ordem_drummer.* "
                 ,"  FROM man_ordem_drummer, item "

   LET where_clause = "WHERE man_ordem_drummer.empresa       = '",p_cod_empresa, "'"
                     ,"  AND (man_ordem_drummer.status_import <> 'X' "
                     ,"   OR man_ordem_drummer.status_import IS NULL) "
                     ,"  AND item.cod_empresa        = '",p_cod_empresa, "'"
                     ,"  AND item.cod_item           = man_ordem_drummer.item "

   # Verifica se foi informada alguma fam�lia
   FOR l_ind = 1 TO ARR_COUNT()
      IF ma_familia[l_ind].cod_familia IS NOT NULL THEN
         LET l_informou_familia = TRUE
         LET where_clause = where_clause CLIPPED, " AND item.cod_familia IN ("
         EXIT FOR
      END IF
   END FOR

   # Inclui as fam�lias selecionadas no SELECT
   LET l_coloca_virgula = FALSE
   FOR l_ind =1 TO ARR_COUNT()
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
       " ORDER BY man_ordem_drummer.dat_recebto "

   LET l_ind = FALSE
   LET l_ind1 = 0

   
   PREPARE var_query1 FROM sql_stmt

   DECLARE cq_man_ordem_drummer_im CURSOR FOR var_query1

   FOREACH cq_man_ordem_drummer_im INTO lr_man_ordem_drummer.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_man_ordem_drummer_im')
         RETURN FALSE
      END IF

     LET l_ind = TRUE
     LET l_ind1 = l_ind1 + 1
	 
	 IF ((lr_man_ordem_drummer.qtd_pecas_boas IS NULL) 
	 OR  (lr_man_ordem_drummer.qtd_pecas_boas <= 0 ))  THEN 
         CONTINUE FOREACH
     END IF 		 

#     DISPLAY lr_man_ordem_drummer.ordem_mps AT 21,28
     LET p_num_ordem = lr_man_ordem_drummer.ordem_mps
     
     IF lr_man_ordem_drummer.status_ordem = 'P' THEN

        #inclui ordens planejadas (ies_situa = 3)
        # nas tabelas do Logix conforme dados selecionados
        IF NOT pol0922_gera_novas_ordens(lr_man_ordem_drummer.*) THEN
           CALL log0030_mensagem( 'N�o foi poss�vel criar as novas ordens.Refazer processo.','info')
           MESSAGE "N�o foi poss�vel criar as novas ordens.Refazer processo. "

           CALL log085_transacao("ROLLBACK")

           RETURN FALSE
        ELSE
             DISPLAY m_num_ordem_aux AT 21,28 
             UPDATE man_ordem_drummer
                SET man_ordem_drummer.ordem_producao = m_num_ordem_aux,
                    man_ordem_drummer.status_import  = "X"
              WHERE man_ordem_drummer.empresa        = p_cod_empresa
                AND man_ordem_drummer.ordem_mps      = lr_man_ordem_drummer.ordem_mps
           
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql( 'UPDATE', "man_ordem_drummer" )
              CALL log085_transacao("ROLLBACK")
              RETURN FALSE
           END IF
        END IF
     END IF

     IF lr_man_ordem_drummer.status_ordem = 'L' THEN
        
          UPDATE ordens
             SET ordens.dat_entrega = lr_man_ordem_drummer.dat_recebto,
                 ordens.dat_liberac = lr_man_ordem_drummer.dat_liberacao
           WHERE ordens.cod_empresa = p_cod_empresa
             AND ordens.num_ordem   = lr_man_ordem_drummer.ordem_producao
         

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql( 'UPDATE', "ORDENS" )
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
         
        DISPLAY lr_man_ordem_drummer.ordem_producao AT 21,28

        #Atualiza os registros nas tabelas intermedi�rias
        
          UPDATE man_ordem_drummer
             SET man_ordem_drummer.status_import  = "X"
           WHERE man_ordem_drummer.empresa        = p_cod_empresa
             AND man_ordem_drummer.ordem_producao = lr_man_ordem_drummer.ordem_producao
        

        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql( 'UPDATE', "man_ordem_drummer" )
           CALL log085_transacao("ROLLBACK")
           RETURN FALSE
        END IF

              
        #-- man_oper_drummer --> ORDEM_OPER
        
         DECLARE cq_man_oper_drummer_im CURSOR FOR
          SELECT man_oper_drummer.*
            FROM man_oper_drummer
           WHERE man_oper_drummer.empresa   = p_cod_empresa
             AND man_oper_drummer.ordem_mps = lr_man_ordem_drummer.ordem_mps
        
        
        FOREACH cq_man_oper_drummer_im INTO lr_man_oper_drummer.*
        
           IF STATUS <> 0 THEN
              CALL log003_err_sql('Lendo','cq_man_oper_drummer_im')
              RETURN FALSE
           END IF
           
            SELECT empresa
              FROM man_oper_compl
             WHERE empresa            = p_cod_empresa
               AND ordem_producao     = lr_man_ordem_drummer.ordem_producao
               AND operacao           = lr_man_oper_drummer.operacao
               AND sequencia_operacao = lr_man_oper_drummer.sequencia_operacao
           

           IF sqlca.sqlcode <> 0 THEN

              IF sqlca.sqlcode <> 100 THEN
                 CALL log003_err_sql("SELECT","MAN_OPER_COMPL")
                 CALL log085_transacao("ROLLBACK")
                 RETURN FALSE
              ELSE
                 
                  INSERT INTO man_oper_compl(empresa
                                            ,ordem_producao
                                            ,operacao
                                            ,sequencia_operacao
                                            ,dat_ini_planejada
                                            ,dat_trmn_planejada)
                                      VALUES(p_cod_empresa
                                            ,lr_man_ordem_drummer.ordem_producao
                                            ,lr_man_oper_drummer.operacao
                                            ,lr_man_oper_drummer.sequencia_operacao
                                            ,lr_man_oper_drummer.dat_ini_planejada
                                            ,lr_man_oper_drummer.dat_trmn_planejada)
                 

                 IF sqlca.sqlcode <> 0 THEN
                    CALL log003_err_sql("INSERT","MAN_OPER_COMPL")
                    CALL log085_transacao("ROLLBACK")
                    RETURN FALSE
                 END IF
              END IF
           ELSE
              
               UPDATE man_oper_compl
                  SET dat_ini_planejada  = lr_man_oper_drummer.dat_ini_planejada
                     ,dat_trmn_planejada = lr_man_oper_drummer.dat_trmn_planejada
                WHERE empresa            = p_cod_empresa
                  AND ordem_producao     = lr_man_ordem_drummer.ordem_producao
                  AND operacao           = lr_man_oper_drummer.operacao
                  AND sequencia_operacao = lr_man_oper_drummer.sequencia_operacao
              

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
      CALL log0030_mensagem("Tabelas para processamento est�o vazias para os dados informados.","info")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   
    CALL log085_transacao("COMMIT")
   

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql( 'COMMIT', "TRANSACAO" )
      RETURN FALSE
   END IF

   CALL log0030_mensagem('Importa��o e processo de atualiza��o - executados com sucesso','info')
   MESSAGE "Importa��o e processo de atualiza��o - executados com sucesso"

   RETURN TRUE

END FUNCTION

#----------------------------------------------------------#
FUNCTION pol0922_gera_novas_ordens(lr_man_ordem_drummer_new)
#----------------------------------------------------------#

   DEFINE lr_man_ordem_drummer_new  RECORD LIKE man_ordem_drummer.*

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

   LET l_ordem_producao = lr_man_ordem_drummer_new.ordem_producao

   #Verifica Item
   
     SELECT *
       INTO lr_item.*
       FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = lr_man_ordem_drummer_new.item
   

   IF sqlca.sqlcode <> 0 THEN
      ERROR "Item ",lr_man_ordem_drummer_new.item, " n�o cadastrado "
      RETURN FALSE
   END IF

   
    SELECT *
      INTO lr_item_man.*
      FROM item_man
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = lr_man_ordem_drummer_new.item
   

   IF sqlca.sqlcode <> 0 THEN
      ERROR "Item ",lr_man_ordem_drummer_new.item, " n�o encontrado na ITEM_MAN "
      RETURN FALSE
   END IF

   LET lr_ordens.cod_empresa        = p_cod_empresa
   LET lr_ordens.num_ordem          = pol0922_atualiza_param()
   
   IF lr_ordens.num_ordem = 0 THEN
      RETURN FALSE
   END IF

   LET m_num_ordem_aux              = lr_ordens.num_ordem

   LET lr_ordens.num_neces          = 0
   LET lr_ordens.num_versao         = 0
   LET lr_ordens.cod_item           = lr_man_ordem_drummer_new.item
   LET lr_ordens.cod_item_pai       = lr_man_ordem_drummer_new.item_pai
   LET lr_ordens.dat_ini            = NULL
   LET lr_ordens.dat_entrega        = lr_man_ordem_drummer_new.dat_recebto
   LET l_qtd_dias_horiz             = pol0922_dias_horizon(lr_item_man.cod_horizon)
   LET lr_ordens.dat_liberac        = lr_man_ordem_drummer_new.dat_liberacao
   LET lr_ordens.dat_abert          = TODAY
   LET lr_ordens.qtd_planej         = lr_man_ordem_drummer_new.qtd_ordem
   LET lr_ordens.pct_refug          = lr_item_man.pct_refug
   LET lr_ordens.qtd_boas           = 0
   LET lr_ordens.qtd_refug          = 0
   LET lr_ordens.cod_local_prod     = lr_item_man.cod_local_prod
   LET lr_ordens.cod_local_estoq    = lr_item.cod_local_estoq
   LET lr_ordens.num_docum          = lr_man_ordem_drummer_new.docum   
   LET lr_ordens.ies_lista_roteiro  = 2
   LET lr_ordens.ies_origem         = 1  {Altera��o efetuada por Manuel em 16-04-2009 antes a op��o era 3}
   LET lr_ordens.ies_situa          = 3
   LET lr_ordens.ies_abert_liber    = 2
   LET lr_ordens.ies_baixa_comp     = lr_item_man.ies_baixa_comp {Altera��o efetuada por Manuel em 16-04-2009 antes a op��o era fixo 1}
   LET lr_ordens.dat_atualiz        = TODAY
   LET lr_ordens.num_lote           = " "

   IF  (lr_man_ordem_drummer_new.num_projeto  IS NOT NULL )
   AND (lr_man_ordem_drummer_new.num_projeto  <> ' ')    THEN
       LET lr_ordens.cod_local_prod  = lr_man_ordem_drummer_new.num_projeto
       LET lr_ordens.cod_local_estoq = lr_man_ordem_drummer_new.num_projeto
   END IF

   IF (mr_par_pcp.parametros[92,92] = "S") AND 
      (lr_item.ies_ctr_lote         = "S") THEN                                            {Alterado por Manuel 24-03-2009}
      IF lr_man_ordem_drummer_new.docum <> lr_man_ordem_drummer_new.ordem_mps[1,10] THEN   {Alterado por Manuel 24-03-2009}
         LET lr_ordens.num_lote = lr_man_ordem_drummer_new.docum                           {Alterado por Manuel 24-03-2009} 
      ELSE                                                                                 {Alterado por Manuel 24-03-2009}
         LET lr_ordens.num_lote = lr_ordens.num_ordem
      END IF                                                                               {Alterado por Manuel 24-03-2009}
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

         
          INSERT INTO ordens_complement VALUES( lr_ordens_complement.* )
         

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql( "INSERT", "ORDENS_COMPLEMENT" )
            RETURN FALSE
         END IF
      END IF

      IF  pol0922_inclui_necessidade(lr_ordens.*) = FALSE THEN
          RETURN FALSE
      END IF

      IF  pol0922_inclui_comp_ordem(lr_ordens.*) = FALSE THEN
          RETURN FALSE
      END IF

      IF  pol0922_inclui_oper_ordem(lr_ordens.*) = FALSE THEN
          RETURN FALSE
      END IF

   RETURN TRUE

END FUNCTION

#--------------------------------------------#
FUNCTION pol0922_inclui_necessidade(lr_ordens)
#--------------------------------------------#

   DEFINE lr_ordens        RECORD LIKE ordens.*

   DEFINE l_texto          CHAR(5000),
          lr_necessidades  RECORD LIKE necessidades.*

   CALL pol0922_carrega_feriado()
   CALL pol0922_carrega_semana()

   LET lr_necessidades.cod_empresa  = p_cod_empresa
   LET lr_necessidades.num_versao   = lr_ordens.num_versao
   LET lr_necessidades.cod_item_pai = lr_ordens.cod_item
   LET lr_necessidades.num_ordem    = lr_ordens.num_ordem
   LET lr_necessidades.qtd_saida    = 0
   LET lr_necessidades.num_docum    = lr_ordens.num_docum
   LET lr_necessidades.ies_origem   = lr_ordens.ies_origem
   LET lr_necessidades.ies_situa    = "3"

   IF pol0922_carrega_temp_estrut(lr_ordens.cod_item, lr_ordens.dat_liberac) THEN
   ELSE
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("CARGA-2","MAN7840")
         RETURN FALSE
      END IF
   END IF

   
    DECLARE cq_estrutur CURSOR WITH HOLD FOR
     SELECT * FROM t_estrut_912
   

   
    FOREACH cq_estrutur INTO p_t_estrut.*
   
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','cq_estrutur')
          RETURN FALSE
       END IF

      LET lr_necessidades.num_neces = pol0922_atualiza_neces()
      LET lr_necessidades.dat_neces = pol0922_calcula_data(lr_ordens.dat_liberac,
                                    (p_t_estrut.tmp_ressup_sobr -
                                     p_t_estrut.tmp_ressup))
      LET lr_necessidades.cod_item = p_t_estrut.cod_item_compon
      LET lr_necessidades.qtd_necessaria = lr_ordens.qtd_planej *
          p_t_estrut.qtd_necessaria * (100/(100-p_t_estrut.pct_refug))

      
        INSERT INTO necessidades VALUES (lr_necessidades.*)
      

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","NECESSIDADES")
         RETURN FALSE
      END IF
   END FOREACH

   RETURN TRUE

END FUNCTION

#-------------------------------------------------#
 FUNCTION pol0922_inclui_oper_ordem(lr_ordens)
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

   DEFINE lr_man_oper_drummer  RECORD LIKE man_oper_drummer.*
   
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

   
   DECLARE cq_operacao CURSOR WITH HOLD FOR
    SELECT *
      FROM man_oper_drummer
     WHERE empresa   = p_cod_empresa
       AND ordem_mps = p_num_ordem
   
   
    FOREACH cq_operacao INTO lr_man_oper_drummer.*
   

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("FOREACH","CQ_OPERACAO")
         RETURN FALSE
      END IF

      
        SELECT *
          FROM item_man
         WHERE item_man.cod_empresa = p_cod_empresa
           AND item_man.cod_item    = lr_ordens.cod_item
      

      IF sqlca.sqlcode = 0 THEN
         
          DECLARE cq_consumo CURSOR WITH HOLD FOR
           SELECT consumo.*, consumo_compl.*
             FROM consumo, consumo_compl
            WHERE consumo.cod_empresa         = p_cod_empresa
              AND consumo.cod_item            = lr_man_oper_drummer.item
              AND consumo.cod_roteiro         = lr_ordens.cod_roteiro
              AND consumo.num_altern_roteiro  = lr_ordens.num_altern_roteiro
              AND consumo.num_seq_operac      = lr_man_oper_drummer.sequencia_operacao #teste
              AND consumo_compl.cod_empresa   = p_cod_empresa

              AND consumo_compl.num_processo  = consumo.parametro[1,7]
              AND ((consumo_compl.dat_validade_ini IS NULL AND consumo_compl.dat_validade_fim IS NULL)
               OR  (consumo_compl.dat_validade_ini IS NULL AND consumo_compl.dat_validade_fim >= lr_ordens.dat_liberac)
               OR  (consumo_compl.dat_validade_fim IS NULL AND consumo_compl.dat_validade_ini <= lr_ordens.dat_liberac)
               OR  (lr_ordens.dat_liberac BETWEEN consumo_compl.dat_validade_ini AND consumo_compl.dat_validade_fim))
         

         
          FOREACH cq_consumo INTO lr_consumo.*, lr_consumo_compl.*
         
             IF STATUS <> 0 THEN
                CALL log003_err_sql('Lendo','cq_consumo')
                RETURN FALSE
             END IF

            LET m_cod_cent_trab = lr_consumo.cod_cent_trab
            LET l_entrou = TRUE

            LET l_parametro = lr_consumo.parametro[1,7]

            
              SELECT cod_empresa
                FROM arranjo
               WHERE cod_empresa = p_cod_empresa
                 AND cod_arranjo = lr_man_oper_drummer.arranjo
            

            IF sqlca.sqlcode <> 0 THEN
               IF sqlca.sqlcode <> 100 THEN
                  CALL log003_err_sql("SELECT","CONSUMO")
                  RETURN FALSE
               ELSE
                  LET l_arranjo = lr_consumo.cod_arranjo
               END IF
            ELSE
               LET l_arranjo = lr_man_oper_drummer.arranjo
            END IF

            
              INSERT INTO ord_oper VALUES (p_cod_empresa,
                                           lr_ordens.num_ordem,
                                           lr_ordens.cod_item,
                                           lr_man_oper_drummer.operacao,
                                           lr_man_oper_drummer.sequencia_operacao,
                                           lr_consumo.cod_cent_trab,
                                           l_arranjo,
                                           lr_consumo.cod_cent_cust,
                                           lr_ordens.dat_entrega,
                                           NULL,
                                           lr_man_oper_drummer.qtd_planejada,
                                           0,
                                           0,
                                           0,
                                           lr_man_oper_drummer.tmp_maq_execucao,
                                           lr_man_oper_drummer.tmp_maquina_prepar,
                                           lr_consumo_compl.ies_apontamento,
                                           lr_consumo_compl.ies_impressao,
                                           lr_consumo_compl.ies_oper_final,
                                           lr_consumo_compl.pct_refug,
                                           lr_consumo_compl.tmp_producao,
                                           l_parametro)            

            IF sqlca.sqlcode = 0 OR
               log0030_err_sql_registro_duplicado() THEN
            ELSE
               CALL log003_err_sql("INCLUSAO","ORD_OPER")
               RETURN FALSE
               EXIT FOREACH
            END IF

            
              INSERT INTO man_oper_compl(empresa
                                        ,ordem_producao
                                        ,operacao
                                        ,sequencia_operacao
                                        ,dat_ini_planejada
                                        ,dat_trmn_planejada)
              VALUES (p_cod_empresa
                     ,lr_ordens.num_ordem
                     ,lr_man_oper_drummer.operacao
                     ,lr_man_oper_drummer.sequencia_operacao
                     ,lr_man_oper_drummer.dat_ini_planejada
                     ,lr_man_oper_drummer.dat_trmn_planejada)
            

            IF sqlca.sqlcode <> 0 AND
               sqlca.sqlcode <> -239 AND
               sqlca.sqlcode <> -268 THEN
               CALL log003_err_sql("INSERT3","MAN_OPER_COMPL")
               RETURN FALSE
            END IF

            
             DECLARE cq_cons_txt CURSOR WITH HOLD FOR
              SELECT consumo_txt.*
                FROM consumo_txt
               WHERE consumo_txt.cod_empresa  = lr_consumo_compl.cod_empresa
                 AND consumo_txt.num_processo = lr_consumo_compl.num_processo
            

            
             FOREACH cq_cons_txt INTO lr_consumo_txt.*

                IF STATUS <> 0 THEN
                   CALL log003_err_sql('Lendo','cq_cons_txt')
                   RETURN FALSE
                END IF
            

               
                 INSERT INTO ord_oper_txt VALUES (p_cod_empresa,
                                                  lr_ordens.num_ordem,
                                                  lr_consumo_txt.num_processo,
                                                  lr_consumo_txt.ies_tipo,
                                                  lr_consumo_txt.num_seq_linha,
                                                  lr_consumo_txt.tex_processo)
               
               IF sqlca.sqlcode = 0 OR
                  log0030_err_sql_registro_duplicado() THEN
               ELSE
                  CALL log003_err_sql("INCLUSAO", "ORD_OPER_TXT")
                  RETURN FALSE
               END IF
            END FOREACH
            
#      Alimenta a tabela MAN_OP_COMPONENTE_OPERACAO a partir da tabela MAN_ESTRUT_OPER para a vers�o 10.02
            
            
             DECLARE cq_estr_oper CURSOR WITH HOLD FOR
              SELECT MAN_ESTRUT_OPER.EMPRESA, 
                     MAN_ESTRUT_OPER.ITEM_COMPONENTE, 
                     ITEM.IES_TIP_ITEM, 
                     MAN_ESTRUT_OPER.QTD_NECESS, 
                     MAN_ESTRUT_OPER.PCT_REFUGO, 
                     MAN_ESTRUT_OPER.PARAMETRO_GERAL 
                     FROM MAN_ESTRUT_OPER,ITEM 
                     WHERE MAN_ESTRUT_OPER.EMPRESA             = p_cod_empresa 
                     AND MAN_ESTRUT_OPER.ITEM                  = lr_man_oper_drummer.item
                     AND MAN_ESTRUT_OPER.ROTEIRO               = lr_ordens.cod_roteiro 
                     AND MAN_ESTRUT_OPER.NUM_ALTERN_ROTEIRO    = lr_ordens.num_altern_roteiro 
                     AND MAN_ESTRUT_OPER.SEQUENCIA_OPERACAO    = lr_man_oper_drummer.sequencia_operacao  
                     AND MAN_ESTRUT_OPER.EMPRESA=ITEM.COD_EMPRESA 
                     AND MAN_ESTRUT_OPER.ITEM_COMPONENTE=ITEM.COD_ITEM 
                     AND (MAN_ESTRUT_OPER.DAT_VALID_INICIAL IS NULL OR 
                          MAN_ESTRUT_OPER.DAT_VALID_INICIAL<=lr_ordens.dat_liberac) 
                     AND (MAN_ESTRUT_OPER.DAT_VALID_FINAL IS NULL OR 
                          MAN_ESTRUT_OPER.DAT_VALID_FINAL>= lr_ordens.dat_liberac) 
                     ORDER BY MAN_ESTRUT_OPER.PARAMETRO_GERAL[6, 10]

             FOREACH cq_estr_oper INTO lr_man_estrut_oper.*

                IF STATUS <> 0 THEN
                   CALL log003_err_sql('Lendo','cq_estr_oper')
                   RETURN FALSE
                END IF
             
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
                    
                    INSERT INTO man_op_componente_operacao VALUES (p_cod_empresa,
                                                                lr_ordens.num_ordem,
                                                                lr_ordens.cod_roteiro ,
                                                                lr_ordens.num_altern_roteiro,
                                                                lr_man_oper_drummer.sequencia_operacao,
                                                                lr_man_oper_drummer.item,
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
 FUNCTION pol0922_inclui_comp_ordem(lr_ordens)
#------------------------------------#
   DEFINE lr_item     RECORD LIKE item.*,
          lr_ordens   RECORD LIKE ordens.*

   
    DECLARE c_neces CURSOR WITH HOLD FOR
     SELECT necessidades.*
       FROM necessidades
      WHERE necessidades.cod_empresa   = p_cod_empresa
        AND necessidades.num_ordem     = lr_ordens.num_ordem
      ORDER BY num_neces
   

   
    FOREACH c_neces INTO mr_necessidades.*

       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','c_neces')
          RETURN FALSE
       END IF
   
      LET mr_ord_compon.cod_empresa     = p_cod_empresa
      LET mr_ord_compon.cod_item_pai    = mr_necessidades.num_neces  {novo conceito desta versao}
      LET mr_ord_compon.num_ordem       = lr_ordens.num_ordem
      LET mr_ord_compon.cod_item_compon = mr_necessidades.cod_item
      LET mr_ord_compon.dat_entrega     = mr_necessidades.dat_neces
      INITIALIZE lr_item.* TO NULL

      
        SELECT item.*
          INTO lr_item.*
          FROM item
         WHERE item.cod_empresa   = p_cod_empresa
           AND item.cod_item      = mr_necessidades.cod_item
      

      IF lr_ordens.ies_baixa_comp  = "1" THEN
         LET mr_ord_compon.cod_local_baixa  = lr_ordens.cod_local_prod
      ELSE
         LET mr_ord_compon.cod_local_baixa  = lr_item.cod_local_estoq
      END IF

 ########LET mr_ord_compon.cod_local_baixa = lr_ordens.cod_local_prod  { alterado por Manuel em 16-04-2009} 

      IF mr_ord_compon.cod_local_baixa IS NULL THEN
         LET mr_ord_compon.cod_local_baixa = "NULO"
      END IF

      LET mr_ord_compon.qtd_necessaria = (mr_necessidades.qtd_necessaria /
                                          lr_ordens.qtd_planej)

      LET mr_ord_compon.cod_cent_trab = m_cod_cent_trab
      LET mr_ord_compon.pct_refug     = 0  { nesta nova versao nao eh mais necessario}
      LET mr_ord_compon.ies_tip_item  = lr_item.ies_tip_item { nesta nova versao nao eh mais necessario}
      LET mr_ord_compon.num_seq       = 0

      
        INSERT INTO ord_compon VALUES (mr_ord_compon.*)
      

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql ("INCLUSAO","ORD_COMPON")
         RETURN FALSE
      END IF
   END FOREACH

   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION pol0922_carrega_feriado()
#---------------------------------#
   DEFINE p_feriado           RECORD LIKE feriado.*

   LET p_dep1 = 0
   
    DECLARE cq_feriado CURSOR FOR
     SELECT *
       FROM feriado
      WHERE cod_empresa = p_cod_empresa
   

   
    FOREACH cq_feriado INTO p_feriado.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_feriado')
         EXIT FOREACH 
      END IF
      
      LET p_dep1 = p_dep1 + 1
      IF p_dep1 > 500 THEN
         PROMPT " Tabela de Feriados com mais de 100 ocorrencias " FOR CHAR m_comando
         EXIT FOREACH
      END IF
      LET t1_feriado[p_dep1].dat_ref = p_feriado.dat_ref
      LET t1_feriado[p_dep1].ies_situa = p_feriado.ies_situa
   END FOREACH

END FUNCTION

#--------------------------------#
 FUNCTION pol0922_carrega_semana()
#--------------------------------#

   DEFINE p_semana           RECORD LIKE semana.*

   LET p_dep2 = 0
   
    DECLARE cq_semana CURSOR FOR
     SELECT *
       INTO p_semana.*
       FROM semana
      WHERE cod_empresa = p_cod_empresa
   

   
   FOREACH cq_semana
   
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
 FUNCTION pol0922_calcula_data(p_data, p_qtd_dias)
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
 FUNCTION pol0922_par_pcp()
#--------------------------#

#   CALL sup0063_cria_temp_controle()

     SELECT *
       INTO mr_par_logix.*
       FROM par_logix
      WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode = 0 THEN
      IF mr_par_logix.parametros[50,50] = "S" THEN
         LET m_rastreia = TRUE
      ELSE
         LET m_rastreia = FALSE
      END IF
   ELSE
      CALL log003_err_sql('Lendo','par_logix')
      RETURN FALSE
   END IF

   
     SELECT *
       INTO mr_par_pcp.*
       FROM par_pcp
      WHERE par_pcp.cod_empresa = p_cod_empresa
   

   IF sqlca.sqlcode = 0 THEN
      IF mr_par_pcp.parametros[116,116] = "N" THEN
         LET m_grava_oplote = FALSE
      ELSE
         LET m_grava_oplote = TRUE
      END IF
      RETURN TRUE
   ELSE
      CALL log003_err_sql('Lendo','par_pcp')
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION pol0922_popup_familia()
#-------------------------------#

   DEFINE l_familia_zoom   LIKE familia.cod_familia

   LET l_familia_zoom = log009_popup(8,10,"FAM�LIAS","familia","cod_familia","den_familia","man0040","S","")

   IF l_familia_zoom IS NOT NULL THEN
      CURRENT WINDOW IS w_pol0922
      LET ma_familia[m_arr_curr].cod_familia = l_familia_zoom
      DISPLAY BY NAME ma_familia[m_arr_curr].cod_familia
   END IF

   CALL log006_exibe_teclas("01 02 03 07",p_versao)
   CURRENT WINDOW IS w_pol0922

   LET INT_FLAG = 0

END FUNCTION

#--------------------------------------------#
FUNCTION pol0922_dias_horizon(p_cod_horizon)
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
FUNCTION pol0922_atualiza_param()
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
FUNCTION pol0922_atualiza_neces()
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
FUNCTION pol0922_cria_temp_estrut()
#----------------------------------#

      DROP TABLE t_estrut_912
      CREATE  TABLE t_estrut_912(
         cod_item_pai    CHAR(15),
         cod_item_compon CHAR(15),
         qtd_necessaria  DECIMAL(14,7),
         pct_refug       DECIMAL(6,3),
         tmp_ressup      DECIMAL(3,0),
         tmp_ressup_sobr DECIMAL(3,0)

       );

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql('Criando','t_estrut_912')
         RETURN FALSE
      END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------------------------------------#
FUNCTION pol0922_carrega_temp_estrut(p_cod_item_pai, p_dat_liberac)
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
