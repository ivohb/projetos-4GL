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

END GLOBALS

   DEFINE l_estrut RECORD
          num_neces              INTEGER, 
          dat_neces              date,
          cod_item_pai           char(15),
          cod_item_compon        char(15),
          cod_grade_comp_1       char(15),
          cod_grade_comp_2       char(15),
          cod_grade_comp_3       char(15),
          cod_grade_comp_4       char(15),
          cod_grade_comp_5       char(15),
          num_seq                dec(5,0),
          qtd_necessaria         dec(14,7),
          pct_refug              dec(6,3),
          tmp_ressup             dec(4,0),
          tmp_ressup_sobr        dec(3,0),
          sequencia_it_operacao  dec(10,0), 
          seq_processo           dec(10,0)
   END RECORD

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
          p_seq_comp               DECIMAL(10,0),
          m_num_seq                INTEGER,
          m_val_flag               CHAR(01)

   DEFINE ma_familia ARRAY[500] OF RECORD
          cod_familia LIKE familia.cod_familia
   END RECORD

   DEFINE mr_par_logix             RECORD LIKE par_logix.*,
          mr_par_pcp               RECORD LIKE par_pcp.*,
          mr_par_mrp               RECORD LIKE par_mrp.*,
          mr_ord_compon            RECORD LIKE ord_compon.*

   DEFINE m_ies_familia            SMALLINT,
          m_ind                    INTEGER,
          m_operacao               CHAR(01),
          m_msg                    CHAR(500),
          p_erro                   CHAR(100),
          m_count                  INTEGER
          
#END MODULARES


MAIN

   CALL log0180_conecta_usuario()

   LET p_versao = "pol0922-12.00.11"  

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
   
   LET m_ies_familia = FALSE
   
   MENU "OPCAO"

      {COMMAND "Informar"   "Informar par�metros para o processamento."
         CALL pol0922_inicializa_campos()
         IF log005_seguranca( p_user, "MANUFAT","pol0922","CO") THEN
            IF pol0922_entrada_parametros() THEN
               ERROR 'Par�metors informados com sucesso'
            ELSE
               ERROR 'Par�metros cancelados'
            END IF
         ELSE
            LET m_ies_familia = FALSE
         END IF}
      COMMAND "Processar"   "Processa a importa��o das ordens do drummer."
         IF log005_seguranca( p_user, "MANUFAT","pol0922","CO") THEN
            IF pol0922_processa_importacao() THEN
               ERROR 'Processamento efetuado com sucesso.'
               NEXT OPTION "Fim"
            ELSE
               ERROR 'Processamento cancelado.'
            END IF
         END IF
         MESSAGE ' '
         #lds CALL LOG_refresh_display()	

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

   DROP TABLE familia_tmp
   
   CREATE  TABLE familia_tmp (
      familia  CHAR(05)
   )
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('criando','familia_tmp')
      RETURN FALSE
   END IF

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
      RETURN FALSE
   END IF

   FOR m_ind = 1 TO 500
       IF ma_familia[m_ind].cod_familia IS NOT NULL THEN
          INSERT INTO familia_tmp VALUES(ma_familia[m_ind].cod_familia)
          LET m_ies_familia = TRUE
       END IF       
   END FOR
   
   IF NOT m_ies_familia THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

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

   IF NOT pol0922_cria_temp_estrut() THEN
      RETURN FALSE
   END IF
   
   LET m_operacao = 'P'
   
   BEGIN WORK
   
   IF NOT pol0922_processar() THEN
      ROLLBACK WORK
      RETURN FALSE 
   END IF
   
   COMMIT WORK
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol0922_cria_temp_estrut()
#----------------------------------#

   DROP TABLE t_estrut
 
   create temp table t_estrut (
          num_neces              INTEGER, 
          dat_neces              date,
          cod_item_pai           char(15),
          cod_item_compon        char(15),
          cod_grade_comp_1       char(15),
          cod_grade_comp_2       char(15),
          cod_grade_comp_3       char(15),
          cod_grade_comp_4       char(15),
          cod_grade_comp_5       char(15),
          num_seq                dec(5,0),
          qtd_necessaria         dec(14,7),
          pct_refug              dec(6,3),
          tmp_ressup             dec(4,0),
          tmp_ressup_sobr        dec(3,0),
          sequencia_it_operacao  dec(10,0), 
          seq_processo           dec(10,0)
   ) with no log

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Criando','t_estrut')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION


#---------------------------#
FUNCTION pol0922_processar()#
#---------------------------#
         
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
          l_ind1                INTEGER,
          p_status_import       CHAR(01)

   
   IF m_operacao = 'P' THEN

      IF NOT m_ies_familia THEN   
         SELECT COUNT(a.empresa)
           INTO m_count
           FROM man_ordem_drummer a, item b
          WHERE a.empresa       = p_cod_empresa
            AND (a.status_import IS NULL OR a.status_import = ' ')
            AND b.cod_empresa = a.empresa 
            AND b.cod_item = a.item
      ELSE
         SELECT COUNT(a.empresa)
           INTO m_count
           FROM man_ordem_drummer a, item b
          WHERE a.empresa       = p_cod_empresa
            AND (a.status_import IS NULL OR a.status_import = ' ')
            AND b.cod_empresa = a.empresa 
            AND b.cod_item = a.item
            AND b.cod_familia IN (SELECT familia FROM familia_tmp)
      END IF
      
      IF m_count = 0 THEN
         CALL log0030_mensagem("N�o h� dados a serem importados","info")
         RETURN FALSE
      END IF
   
      LET m_msg = 'Toda a Programa��o Atual\n',
                  'Ser� Sobreposta.\n\n',
	                'Confirma o porcessamento ?' 
	 
	    IF log0040_confirm(20,25,m_msg) THEN
	    ELSE
	       RETURN FALSE
	    END IF

      IF NOT pol0922_del_ordens() THEN
         RETURN FALSE
      END IF
      
   END IF

   MESSAGE 'Aguarde!... importando ordens:'
   #lds CALL LOG_refresh_display()	
   
   #-- Inicializa as vari�veis usadas
   INITIALIZE lr_man_ordem_drummer TO NULL
   INITIALIZE m_num_ordem_aux TO NULL           

   LET sql_stmt = "SELECT man_ordem_drummer.* "
                 ,"  FROM man_ordem_drummer, item "
   
   IF m_operacao = 'P' THEN
      LET where_clause = 
          " WHERE man_ordem_drummer.empresa       = '",p_cod_empresa, "'",
          "  AND (man_ordem_drummer.status_import IS NULL OR man_ordem_drummer.status_import = ' ') ",
          "  AND item.cod_empresa        = '",p_cod_empresa, "'",
          "  AND item.cod_item           = man_ordem_drummer.item "
   
   
   
      # Verifica se foi informada alguma fam�lia

      IF m_ies_familia THEN
         LET where_clause = where_clause CLIPPED, 
             " AND item.cod_familia IN (SELECT familia FROM familia_tmp) "
      END IF
   ELSE
      LET where_clause = 
          " WHERE man_ordem_drummer.empresa = '",p_cod_empresa, "'",
          "  AND man_ordem_drummer.status_import = 'C' ",
          "  AND item.cod_empresa        = '",p_cod_empresa, "'",
          "  AND item.cod_item           = man_ordem_drummer.item "
   END IF

   LET sql_stmt = sql_stmt CLIPPED, " ", where_clause CLIPPED

   LET sql_stmt = sql_stmt CLIPPED, " ",
       " ORDER BY man_ordem_drummer.dat_recebto "

   LET l_ind = FALSE
   LET l_ind1 = 0
   
   PREPARE var_query1 FROM sql_stmt

   DECLARE cq_man_ordem_drummer_im CURSOR WITH HOLD FOR var_query1

   FOREACH cq_man_ordem_drummer_im INTO lr_man_ordem_drummer.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_man_ordem_drummer_im')
         RETURN FALSE
      END IF

     LET p_num_ordem = lr_man_ordem_drummer.ordem_mps
                
     LET l_ind = TRUE
     LET l_ind1 = l_ind1 + 1
	   LET p_erro = NULL
	   
     IF lr_man_ordem_drummer.status_ordem = 'P' THEN

        CALL pol0922_gera_novas_ordens(lr_man_ordem_drummer.*) 
        
        IF p_erro IS NOT NULL THEN
           CALL log0030_mensagem(p_erro,'info')
           RETURN FALSE
        END IF
        
        LET p_status_import = 'X'

        UPDATE man_ordem_drummer
           SET man_ordem_drummer.ordem_producao = m_num_ordem_aux,
               man_ordem_drummer.status_import  = p_status_import
         WHERE man_ordem_drummer.empresa        = p_cod_empresa
           AND man_ordem_drummer.ordem_mps      = lr_man_ordem_drummer.ordem_mps
                                   
     END IF

     IF lr_man_ordem_drummer.status_ordem = 'L' THEN

        CALL pol0922_atualiza_ordem(lr_man_ordem_drummer.*) 

        IF p_erro IS NOT NULL THEN
           CALL log0030_mensagem(p_erro,'info')
           RETURN FALSE
        END IF
        
        LET p_status_import = 'X'

        UPDATE man_ordem_drummer
           SET man_ordem_drummer.status_import  = p_status_import
         WHERE man_ordem_drummer.empresa        = p_cod_empresa
           AND man_ordem_drummer.ordem_mps      = lr_man_ordem_drummer.ordem_mps
        
     END IF
     
   END FOREACH
   
   FREE cq_man_ordem_drummer_im
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0922_del_ordens()#
#----------------------------#

   DEFINE l_num_ordem     INTEGER,
          sql_stmt        CHAR(2000),
          where_clause    CHAR(2000)
      
   #Exclui ordens de situacao 3 

   MESSAGE 'Aguarde!... deletando ordens:'
   #lds CALL LOG_refresh_display()	

    LET sql_stmt = " SELECT num_ordem",
                   "   FROM ordens, item "

    LET where_clause =   
        "  WHERE ordens.cod_empresa = '",p_cod_empresa,"'",
        "    AND ordens.ies_situa = '3'",
        "    AND item.cod_empresa = ordens.cod_empresa ",
        "    AND item.cod_item = ordens.cod_item "

   # Verifica se foi informada alguma fam�lia
   
   IF m_ies_familia THEN
      LET where_clause = where_clause CLIPPED, 
          " AND item.cod_familia IN (SELECT familia FROM familia_tmp) "
   END IF

   LET sql_stmt = sql_stmt CLIPPED, " ", where_clause CLIPPED

   PREPARE var_ordens_elim FROM sql_stmt
   DECLARE cq_ordens_eliminadas CURSOR WITH HOLD FOR var_ordens_elim

   FOREACH cq_ordens_eliminadas INTO l_num_ordem

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_ordens_eliminadas')
         RETURN FALSE
      END IF
      
           #Elimina ordens_complement
           
            DELETE FROM ordens_complement
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           

           IF  sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("DELETE","ORDENS_COMPLEMENT")
               RETURN FALSE
           END IF

           #Elimina necessidades
           
            DELETE FROM necessidades
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","NECESSIDADES")
             RETURN FALSE
           END IF

           #Elimina ord_oper
           
            DELETE FROM ord_oper
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","ORD_OPER")
             RETURN FALSE
           END IF

           #Elimina man_oper_compl
           
            DELETE FROM man_oper_compl
             WHERE empresa            = p_cod_empresa
               AND ordem_producao     = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("DELETE","MAN_OPER_COMPL")
              RETURN FALSE
           END IF

           #Elimina ord_compon
           
            DELETE FROM ord_compon
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","ORD_COMPON")
             RETURN FALSE
           END IF

           #Elimina Ordens
           
             DELETE FROM ordens
              WHERE cod_empresa      = p_cod_empresa
                AND num_ordem        = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("DELETE","ORDENS")
              RETURN FALSE
           END IF

   END FOREACH
  
   FREE cq_ordens_eliminadas
   
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
          l_ordem_producao       CHAR(30),
		      p_dat_atu 			       DATE

   DEFINE l_ord_docum            LIKE ordens.num_docum,
          l_ord_ordem            LIKE ordens.num_ordem

   DEFINE where_clause          CHAR(2000),
          l_ind                 SMALLINT,
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
   

   IF STATUS <> 0 THEN
      LET p_erro = "Item ",lr_man_ordem_drummer_new.item, " n�o cadastrado na tabela item "
      RETURN 
   END IF
   
    SELECT *
      INTO lr_item_man.*
      FROM item_man
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = lr_man_ordem_drummer_new.item
   

   IF STATUS <> 0 THEN
      LET p_erro = "Item ",lr_man_ordem_drummer_new.item, " n�o cadastrado na tabela item_man "
      RETURN 
   END IF

   LET lr_ordens.cod_empresa        = p_cod_empresa
   LET lr_ordens.num_ordem          = pol0922_atualiza_param()
   
   IF lr_ordens.num_ordem = 0 THEN
      RETURN 
   END IF

   LET m_num_ordem_aux              = lr_ordens.num_ordem

   LET lr_ordens.num_neces          = 0
   LET lr_ordens.num_versao         = 0
   LET lr_ordens.cod_item           = lr_man_ordem_drummer_new.item
   LET lr_ordens.cod_item_pai       = '0'
   
   IF lr_ordens.cod_item_pai IS NULL THEN
      LET lr_ordens.cod_item_pai = '0'
   END IF
   
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

   IF STATUS <> 0 THEN
      LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela ordens '
      RETURN 
   END IF
   
    LET p_dat_atu = TODAY
   
   INITIALIZE lr_ordens_complement TO NULL

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
   LET lr_ordens_complement.ordem_producao_pai = NULL
      
   INSERT INTO ordens_complement VALUES( lr_ordens_complement.* )         

   IF STATUS <> 0 THEN
      LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela ordens_complement '
      RETURN 
   END IF

   IF  pol0922_inclui_necessidade(lr_ordens.*) = FALSE THEN
       RETURN 
   END IF
      
   IF  pol0922_inclui_oper_ordem(lr_ordens.*) = FALSE THEN
       RETURN 
   END IF

END FUNCTION

#--------------------------------------------#
FUNCTION pol0922_inclui_necessidade(lr_ordens)
#--------------------------------------------#

   DEFINE lr_ordens        RECORD LIKE ordens.*
   DEFINE l_seq_processo   INTEGER,
          l_seq_operacao   INTEGER,
          l_op_pai         INTEGER,
          l_ies_tip_item   CHAR(01),
          l_cod_local      CHAR(15)

   DEFINE l_texto          CHAR(5000),
          lr_necessidades  RECORD LIKE necessidades.*
   
   LET l_op_pai = 0
   
   IF NOT pol0922_carrega_feriado() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0922_carrega_semana() THEN
      RETURN FALSE
   END IF
    
   SELECT val_flag
     INTO m_val_flag
     FROM man_inf_com_item 
    WHERE empresa = p_cod_empresa 
      AND item = lr_ordens.cod_item
      AND informacao_compl = 'estrutura_operacao  '
   
   IF STATUS <> 0 THEN
      LET p_erro = "Erro ", STATUS, 'lendo dados da tabela man_inf_com_item '
      RETURN FALSE
   END IF
   
   DELETE FROM t_estrut

   IF STATUS <> 0 THEN
      LET p_erro = "Erro ", STATUS, 'deletando dados da tabela t_estrut '
      RETURN FALSE
   END IF
         
   IF NOT pol0922_carrega_estrut(
                lr_ordens.cod_item, 
                lr_ordens.dat_liberac,     
                lr_ordens.cod_roteiro,
                lr_ordens.num_altern_roteiro) THEN
      RETURN FALSE
   END IF      

   LET lr_necessidades.cod_empresa  = p_cod_empresa
   LET lr_necessidades.num_versao   = lr_ordens.num_versao
   LET lr_necessidades.cod_item_pai = lr_ordens.cod_item
   LET lr_necessidades.num_ordem    = lr_ordens.num_ordem
   LET lr_necessidades.qtd_saida    = 0
   LET lr_necessidades.num_docum    = lr_ordens.num_docum
   LET lr_necessidades.ies_origem   = lr_ordens.ies_origem
   LET lr_necessidades.ies_situa    = "3"
   
   
   DECLARE cq_estrutur CURSOR WITH HOLD FOR
     SELECT * FROM t_estrut
      
    FOREACH cq_estrutur INTO l_estrut.*
   
       IF STATUS <> 0 THEN
          LET p_erro = "Erro ", STATUS, 'lendo dados da tabela t_estrut '
          RETURN FALSE
       END IF

      LET lr_necessidades.num_neces = l_estrut.num_neces
      LET lr_necessidades.dat_neces = l_estrut.dat_neces
                                           
      LET lr_necessidades.cod_item = l_estrut.cod_item_compon
      LET lr_necessidades.qtd_necessaria = lr_ordens.qtd_planej *
          l_estrut.qtd_necessaria * (100/(100-l_estrut.pct_refug))
      
      INSERT INTO necessidades VALUES (lr_necessidades.*)
      
      IF sqlca.sqlcode <> 0 THEN
         LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela necessidades '
         RETURN FALSE
      END IF

        INSERT INTO neces_complement (
          cod_empresa, 
          num_neces, 
          cod_grade_1, 
          cod_grade_2, 
          cod_grade_3, 
          cod_grade_4, 
          cod_grade_5, 
          ordem_producao_pai,
          sequencia_it_operacao, 
          seq_processo) 
        VALUES(p_cod_empresa, 
               l_estrut.num_neces,
               l_estrut.cod_grade_comp_1,
               l_estrut.cod_grade_comp_2,
               l_estrut.cod_grade_comp_3,
               l_estrut.cod_grade_comp_4,
               l_estrut.cod_grade_comp_5,
               l_op_pai,
               l_estrut.sequencia_it_operacao,
               l_estrut.seq_processo)

        IF sqlca.sqlcode <> 0 THEN
           LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela neces_complement '
           RETURN FALSE
        END IF
      
      INITIALIZE mr_ord_compon.* TO NULL
      
      LET mr_ord_compon.cod_empresa     = p_cod_empresa
      LET mr_ord_compon.cod_item_pai    = lr_necessidades.num_neces  
      LET mr_ord_compon.num_ordem       = lr_ordens.num_ordem
      LET mr_ord_compon.cod_item_compon = lr_necessidades.cod_item
      LET mr_ord_compon.dat_entrega     = lr_necessidades.dat_neces
            
      SELECT ies_tip_item, cod_local_estoq
        INTO l_ies_tip_item, l_cod_local
        FROM item
       WHERE item.cod_empresa   = p_cod_empresa
         AND item.cod_item      = lr_necessidades.cod_item      

      IF sqlca.sqlcode <> 0 THEN
         LET p_erro = "Erro ", STATUS, 'lendo dados na tabela item '
         RETURN FALSE
      END IF
     
      LET mr_ord_compon.ies_tip_item = l_ies_tip_item
     
      IF lr_ordens.ies_baixa_comp  = "1" THEN
         LET mr_ord_compon.cod_local_baixa  = lr_ordens.cod_local_prod
      ELSE
         LET mr_ord_compon.cod_local_baixa  = l_cod_local
      END IF

      IF mr_ord_compon.cod_local_baixa IS NULL THEN
         LET mr_ord_compon.cod_local_baixa = "NULO"
      END IF

      LET mr_ord_compon.qtd_necessaria = l_estrut.qtd_necessaria
      LET mr_ord_compon.pct_refug = l_estrut.pct_refug

      LET mr_ord_compon.cod_cent_trab = m_cod_cent_trab
      LET mr_ord_compon.num_seq       = 0
      
      INSERT INTO ord_compon VALUES (mr_ord_compon.*)
      
      IF sqlca.sqlcode <> 0 THEN
         LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela ord_compon '
         RETURN FALSE
      END IF
            
   END FOREACH

   RETURN TRUE

END FUNCTION

#-------------------------------------------------#
 FUNCTION pol0922_inclui_oper_ordem(lr_ordens)
#-------------------------------------------------#

   DEFINE l_man_recurso_processo RECORD
          recurso                CHAR(05),            
          qtd_recurso            DECIMAL(7,4),         
          texto_recurso          VARCHAR(255),       
          qtd_tempo              DECIMAL(11,7),           
          qtd_pecas_ciclo        DECIMAL(12,7)
           
   END RECORD   

   DEFINE lr_ordens              RECORD LIKE ordens.*,
          lr_man_processo        RECORD LIKE man_processo_item.*,
          l_local                LIKE ord_compon.cod_local_baixa,
          l_parametro            CHAR(07),
          l_entrou               SMALLINT,
          l_num_ordem            CHAR(30),
          l_status               SMALLINT,
          l_arranjo              CHAR(5),
          l_num_seq              INTEGER

   DEFINE lr_man_oper_drummer  RECORD LIKE man_oper_drummer.*
      
   DEFINE l_processo          char(07),
          l_tipo              char(01),
          l_linha             integer,
          l_texto             char(70),
          l_seq               integer,
          l_compon            char(15),
          l_qtd_neces         dec(14,7),
          l_pct_refugo        decimal(5,2),
          l_ies_tip_item      char(01),
          l_proc_recurso      integer,
          l_dat_neces         date,
          l_seq_it_operacao   integer,
          l_num_neces         integer

   LET l_entrou = FALSE

   LET l_num_ordem = p_num_ordem

   
   DECLARE cq_operacao CURSOR WITH HOLD FOR
    SELECT *
      FROM man_oper_drummer
     WHERE empresa   = p_cod_empresa
       AND ordem_mps = p_num_ordem
     ORDER BY sequencia_operacao
      
   FOREACH cq_operacao INTO lr_man_oper_drummer.*
   
      IF STATUS <> 0 THEN
         LET p_erro = "Erro ", STATUS, 'lendo dados da tabela man_oper_drummer '
         RETURN FALSE
      END IF
      
      SELECT *
        FROM item_man
       WHERE item_man.cod_empresa = p_cod_empresa
         AND item_man.cod_item    = lr_ordens.cod_item
      
      IF STATUS <> 0 THEN
         CONTINUE FOREACH
      END IF
      
      DECLARE cq_processo CURSOR WITH HOLD FOR
       SELECT * FROM man_processo_item
        WHERE empresa         = p_cod_empresa
          AND item            = lr_man_oper_drummer.item
          AND roteiro         = lr_ordens.cod_roteiro
          AND roteiro_alternativo  = lr_ordens.num_altern_roteiro
          AND seq_operacao      = lr_man_oper_drummer.sequencia_operacao 
          AND ((validade_inicial IS NULL AND validade_final IS NULL)
           OR  (validade_inicial IS NULL AND validade_final >= lr_ordens.dat_liberac)
           OR  (validade_final IS NULL AND validade_inicial <= lr_ordens.dat_liberac)
           OR  (lr_ordens.dat_liberac BETWEEN validade_inicial AND validade_final))
                  
      FOREACH cq_processo INTO lr_man_processo.*
         
         IF STATUS <> 0 THEN
            LET p_erro = "Erro ", STATUS, 'lendo dados da tabela man_processo_item '
            RETURN FALSE
         END IF

         LET m_cod_cent_trab = lr_man_processo.centro_trabalho
         LET l_entrou = TRUE
         LET l_parametro = lr_man_processo.seq_processo USING '<<<<<<<'
            
         SELECT cod_empresa
           FROM arranjo
          WHERE cod_empresa = p_cod_empresa
            AND cod_arranjo = lr_man_oper_drummer.arranjo

         IF STATUS <> 0 THEN
            IF STATUS <> 100 THEN
               LET p_erro = "Erro ", STATUS, 'lendo dados da tabela arranjo '
               RETURN FALSE
            ELSE
               LET l_arranjo = lr_man_processo.arranjo
            END IF
         ELSE
            LET l_arranjo = lr_man_oper_drummer.arranjo
         END IF
            
         INSERT INTO ord_oper(
            cod_empresa,
            num_ordem,
            cod_item,
            cod_operac,
            num_seq_operac,
            cod_cent_trab,
            cod_arranjo,
            cod_cent_cust,
            dat_entrega,
            dat_inicio,
            qtd_planejada,
            qtd_boas,
            qtd_refugo,
            qtd_sucata,
            qtd_horas,
            qtd_horas_setup,
            ies_apontamento,
            ies_impressao,
            ies_oper_final,
            pct_refug,
            tmp_producao,
            num_processo)
          VALUES (p_cod_empresa,
                  lr_ordens.num_ordem,                                            
                  lr_ordens.cod_item,                                             
                  lr_man_oper_drummer.operacao,                                   
                  lr_man_oper_drummer.sequencia_operacao,                         
                  m_cod_cent_trab,                                       
                  l_arranjo,                                                      
                  lr_man_processo.centro_custo,                                       
                  lr_ordens.dat_entrega,                                          
                  NULL,                                                           
                  lr_man_oper_drummer.qtd_planejada,                              
                  0,                                                              
                  0,                                                              
                  0,                                                              
                  lr_man_oper_drummer.tmp_maq_execucao,                           
                  lr_man_oper_drummer.tmp_maquina_prepar, 
                  lr_man_processo.apontar_operacao,                               
                  lr_man_processo.imprimir_operacao,                                 
                  lr_man_processo.operacao_final,                                
                  lr_man_processo.pct_retrabalho,                                     
                  0,                                  
                  l_parametro)                                                    

         IF sqlca.sqlcode = 0 OR
            log0030_err_sql_registro_duplicado() THEN
         ELSE
            LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela ord_oper '
            RETURN FALSE
         END IF
         
         LET l_num_seq = SQLCA.SQLERRD[2]

         DECLARE cq_man_recurso_processo CURSOR FOR
          SELECT recurso, 
                 qtd_recurso, 
                 texto_recurso, 
                 qtd_tempo, 
                 qtd_pecas_ciclo 
            FROM man_recurso_processo 
           WHERE empresa = p_cod_empresa
             AND seq_processo = lr_man_processo.seq_processo       
           
         FOREACH cq_man_recurso_processo INTO l_man_recurso_processo.*

            IF STATUS <> 0 THEN
               LET p_erro = "Erro ", STATUS, 'lendo  man_recurso_processo'
               RETURN FALSE
            END IF
         
            INSERT INTO man_recurso_operacao_ordem (
              empresa, 
              seq_processo, 
              recurso, 
              qtd_recurso, 
              texto, 
              qtd_tempo, 
              qtd_pecas_ciclo) 
            VALUES(p_cod_empresa,
                   l_num_seq,
                   l_man_recurso_processo.recurso ,       
                   l_man_recurso_processo.qtd_recurso,    
                   l_man_recurso_processo.texto_recurso,  
                   l_man_recurso_processo.qtd_tempo,      
                   l_man_recurso_processo.qtd_pecas_ciclo)

            IF STATUS <> 0 THEN
               LET p_erro = "Erro ", STATUS, 'inserindo man_recurso_operacao_ordem'
               RETURN FALSE
            END IF
            
         END FOREACH
         
         INSERT INTO man_oper_compl(
                empresa
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
            LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela man_oper_compl '
            RETURN FALSE
         END IF
                     
                  
         DECLARE cq_cons_txt CURSOR WITH HOLD FOR
          SELECT tip_texto, 
                 seq_texto_processo,
                 texto_processo[1,70]
            FROM man_texto_processo
           WHERE empresa  = p_cod_empresa
             AND seq_processo = lr_man_processo.seq_processo            
            
         FOREACH cq_cons_txt INTO l_tipo, l_linha, l_texto

            IF STATUS <> 0 THEN
               LET p_erro = "Erro ", STATUS, 'lendo dados da tabela man_texto_processo '
               RETURN FALSE
            END IF            
               
            INSERT INTO ord_oper_txt 
             VALUES (p_cod_empresa,
                     lr_ordens.num_ordem,                                      
                     l_parametro,                              
                     l_tipo,                                  
                     l_linha,                             
                     l_texto,NULL)                              
               
            IF sqlca.sqlcode = 0 OR
               log0030_err_sql_registro_duplicado() THEN
            ELSE
               LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela ord_oper_txt '
               RETURN FALSE
            END IF
          
         END FOREACH
            
         IF m_val_flag = 'S' THEN
        
            DECLARE cq_estr_oper CURSOR WITH HOLD FOR
             SELECT num_neces,
                    dat_neces,
                    cod_item_compon,
                    qtd_necessaria, 
                    pct_refug,
                    sequencia_it_operacao,
                    ies_tip_item
               FROM t_estrut t, item i
              WHERE cod_item_pai = lr_man_oper_drummer.item
                AND seq_processo = lr_man_processo.seq_processo  
                AND i.cod_empresa = p_cod_empresa
                AND i.cod_item = t.cod_item_pai        

            FOREACH cq_estr_oper INTO 
                    l_num_neces, l_dat_neces, l_compon, l_qtd_neces, l_pct_refugo, 
                    l_seq_it_operacao, l_ies_tip_item

               IF STATUS <> 0 THEN
                  LET p_erro = "Erro ", STATUS, 'lendo dados da tabela t_estrut/item '
                  RETURN FALSE
               END IF

               SELECT cod_local_baixa 
                 INTO l_local
                 FROM ord_compon 
                WHERE cod_empresa = p_cod_empresa 
                  AND num_ordem = lr_ordens.num_ordem
                  AND cod_item_compon = l_compon
                  AND cod_item_pai = l_num_neces

               IF STATUS <> 0 THEN
                  LET p_erro = "Erro ", STATUS, 'lendo dados da tabela ord_compon '
                  RETURN FALSE
               END IF

              INSERT INTO man_op_componente_operacao (
                empresa, ordem_producao, roteiro, num_altern_roteiro, 
                sequencia_operacao, item_pai, item_componente, tip_item, 
                dat_entrega, qtd_necess, local_baixa, centro_trabalho, 
                pct_refugo, sequencia_componente, seq_processo) 
            
                VALUES (p_cod_empresa,
                     lr_ordens.num_ordem,                                                              
                     lr_ordens.cod_roteiro ,                                                           
                     lr_ordens.num_altern_roteiro,                                                     
                     lr_man_oper_drummer.sequencia_operacao,                                           
                     lr_man_oper_drummer.item,                                                         
                     l_compon,                                               
                     l_ies_tip_item,                                                  
                     l_dat_neces,                                                            
                     l_qtd_neces,                                                    
                     l_local,                                                         
                     m_cod_cent_trab,                                                                              
                     l_pct_refugo,                                                    
                     l_num_neces,
                     l_num_seq)     
                                                                                       
               IF sqlca.sqlcode = 0 OR
                  log0030_err_sql_registro_duplicado() THEN
               ELSE
                  LET p_erro = "Erro ", STATUS, 'inserindo tabela man_op_componente_operacao '
                  RETURN FALSE
               END IF
               
            END FOREACH
         
         END IF
         
      END FOREACH

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
         LET p_erro = "Erro ", STATUS, 'lendo dados Da tabela feriado '
         RETURN FALSE
      END IF
      
      LET p_dep1 = p_dep1 + 1
      IF p_dep1 > 500 THEN
         LET p_erro = 'Tabela de Feriados com mais de 100 ocorrencias '
         RETURN FALSE
      END IF

      LET t1_feriado[p_dep1].dat_ref = p_feriado.dat_ref
      LET t1_feriado[p_dep1].ies_situa = p_feriado.ies_situa

   END FOREACH
   
   RETURN TRUE
   
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
         LET p_erro = "Tabela de Semanas com mais de 7 ocorrencias"
         RETURN FALSE
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

      IF STATUS <> 0 THEN
         LET p_erro = "Erro ", STATUS, 'lendo o proximo numero de ordem '
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

      IF STATUS <> 0 THEN
         LET p_erro = "Erro ", STATUS, 'atualizando o logix com o proximo numero de ordem '
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

#---------------------------------------------------------------------#
FUNCTION pol0922_carrega_estrut(
   p_cod_item_pai, p_dat_liberac, l_cod_roteiro, l_num_altern_roteiro)
#---------------------------------------------------------------------#
   
   DEFINE p_cod_item_pai    LIKE item.cod_item,
          p_dat_liberac     LIKE ordens.dat_liberac,
          l_cod_roteiro        LIKE ordens.cod_roteiro,
          l_num_altern_roteiro LIKE ordens.num_altern_roteiro,  
          p_cod_item_compon LIKE estrutura.cod_item_compon,
          p_qtd_necessaria  LIKE estrutura.qtd_necessaria,
          p_pct_refug       LIKE estrutura.pct_refug,
          P_tmp_ressup_sobr LIKE estrutura.tmp_ressup_sobr,
          P_tmp_ressup      LIKE item_man.tmp_ressup,
          l_cod_grade_1     LIKE estrut_grade.cod_grade_1,
          l_cod_grade_2     LIKE estrut_grade.cod_grade_2,
          l_cod_grade_3     LIKE estrut_grade.cod_grade_3,
          l_cod_grade_4     LIKE estrut_grade.cod_grade_4,
          l_cod_grade_5     LIKE estrut_grade.cod_grade_5,
          l_num_neces       INTEGER,
          l_dat_neces       DATE
   
   DEFINE l_sequencia_it_operacao  dec(10,0), 
          l_seq_processo           dec(10,0)  

   IF m_val_flag = 'S' THEN
   
   LET m_num_seq = 1
      
   DECLARE cq_estrutura CURSOR FOR
    SELECT item_componente,
           qtd_necessaria, 
           pct_refugo,      
           tmp_rsp_sobreposto,
           0,
           grade_comp_1,
           grade_comp_2,
           grade_comp_3,
           grade_comp_4,
           grade_comp_5,
           seq_processo,
           seq_componente
       FROM man_estrutura_operacao 
      WHERE empresa  =  p_cod_empresa
        AND item_pai =  p_cod_item_pai 
        AND (conteudo_grade_1 = '' OR conteudo_grade_1    = ' ')  
        AND (conteudo_grade_2 = '' OR conteudo_grade_2    = ' ')  
        AND (conteudo_grade_3 = '' OR conteudo_grade_3    = ' ')  
        AND (conteudo_grade_4 = '' OR conteudo_grade_4    = ' ')  
        AND (conteudo_grade_5 = '' OR conteudo_grade_5    = ' ')  
        AND (validade_inicial IS NULL OR validade_inicial <= p_dat_liberac)   
        AND (validade_final   IS NULL OR validade_final   >= p_dat_liberac) 
        AND seq_processo in (
            SELECT seq_processo FROM man_processo_item 
             WHERE empresa = p_cod_empresa
               AND item = p_cod_item_pai 
               AND roteiro = l_cod_roteiro 
               AND roteiro_alternativo = l_num_altern_roteiro)
   
   ELSE

   DECLARE cq_estrutura CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria, 
           pct_refug,      
           tmp_ressup_sobr,
           num_sequencia,
           cod_grade_1,
           cod_grade_2,
           cod_grade_3,
           cod_grade_4,
           cod_grade_5, 
           0,0
      FROM estrut_grade
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_cod_item_pai
       AND (dat_validade_ini IS NULL OR dat_validade_ini <= p_dat_liberac)   
       AND (dat_validade_fim IS NULL OR dat_validade_fim >= p_dat_liberac)
     ORDER BY num_sequencia
   
   END IF
       
   FOREACH cq_estrutura INTO 
           p_cod_item_compon,
           p_qtd_necessaria,
           p_pct_refug,
           P_tmp_ressup_sobr,
           m_num_seq,
           l_cod_grade_1, 
           l_cod_grade_2, 
           l_cod_grade_3, 
           l_cod_grade_4, 
           l_cod_grade_5,
           l_seq_processo, 
           l_sequencia_it_operacao

      IF STATUS <> 0 THEN
         LET p_erro = "Erro ", STATUS, 'lendo dados da estrutura do produto '
         RETURN FALSE
      END IF
      
      IF m_val_flag = 'S' THEN
         LET m_num_seq = m_num_seq + 1
         
         SELECT DISTINCT seq_operacao 
           INTO l_sequencia_it_operacao
           FROM man_processo_item 
          WHERE empresa = p_cod_empresa
            AND seq_processo = l_seq_processo

         IF STATUS <> 0 THEN
            LET p_erro = "Erro ", STATUS, 'lendo dados da tabela man_processo_item '
            RETURN FALSE
         END IF
      END IF
      
      SELECT tmp_ressup
        INTO p_tmp_ressup
        FROM item_man
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item_pai

      IF STATUS <> 0 THEN
         LET p_erro = "Erro ", STATUS, 'lendo dados da tabela item_man '
         RETURN FALSE
      END IF
      
      LET l_num_neces = pol0922_atualiza_neces()

      LET l_dat_neces = pol0922_calcula_data(
             p_dat_liberac, (l_estrut.tmp_ressup_sobr - l_estrut.tmp_ressup))
      
      INSERT INTO t_estrut (                    
        num_neces,
        dat_neces,
        cod_item_pai,    
        cod_item_compon, 
        cod_grade_comp_1,
        cod_grade_comp_2,
        cod_grade_comp_3,
        cod_grade_comp_4,
        cod_grade_comp_5,
        num_seq,         
        qtd_necessaria,  
        pct_refug,       
        tmp_ressup,      
        tmp_ressup_sobr, 
        sequencia_it_operacao, 
        seq_processo) VALUES(
           l_num_neces,   
           l_dat_neces,                 
           p_cod_item_pai,
           p_cod_item_compon,
           l_cod_grade_1, 
           l_cod_grade_2, 
           l_cod_grade_3, 
           l_cod_grade_4, 
           l_cod_grade_5,
           m_num_seq,
           p_qtd_necessaria,
           p_pct_refug,
           P_tmp_ressup,
           P_tmp_ressup_sobr,
           l_sequencia_it_operacao,
           l_seq_processo)

      IF STATUS <> 0 THEN
         LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela t_estrut '
         RETURN FALSE
      END IF
                 
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------------------------#
FUNCTION pol0922_atualiza_ordem(lr_man_ordem_drummer)
#----------------------------------------------------#

   DEFINE lr_man_ordem_drummer  RECORD LIKE man_ordem_drummer.*
   DEFINE lr_man_oper_drummer  RECORD LIKE man_oper_drummer.*

   UPDATE ordens
      SET ordens.dat_entrega = lr_man_ordem_drummer.dat_recebto,
          ordens.dat_liberac = lr_man_ordem_drummer.dat_liberacao
    WHERE ordens.cod_empresa = p_cod_empresa
      AND ordens.num_ordem   = lr_man_ordem_drummer.ordem_producao
         
   IF STATUS <> 0 THEN
      LET p_erro = "Erro ", STATUS, 'atualizando dados na tabela ordens '
      RETURN 
   END IF         
		         
   DECLARE cq_man_oper_drummer_im CURSOR FOR
    SELECT man_oper_drummer.*
      FROM man_oper_drummer
     WHERE man_oper_drummer.empresa   = p_cod_empresa
       AND man_oper_drummer.ordem_mps = lr_man_ordem_drummer.ordem_mps
                
   FOREACH cq_man_oper_drummer_im INTO lr_man_oper_drummer.*
        
      IF STATUS <> 0 THEN
         LET p_erro = "Erro ", STATUS, 'lendo dados na tabela man_oper_drummer '
         RETURN 
      END IF
               
      SELECT empresa
        FROM man_oper_compl
       WHERE empresa            = p_cod_empresa
         AND ordem_producao     = lr_man_ordem_drummer.ordem_producao
         AND operacao           = lr_man_oper_drummer.operacao
         AND sequencia_operacao = lr_man_oper_drummer.sequencia_operacao

      IF STATUS <> 0 AND STATUS <> 100 THEN
         LET p_erro = "Erro ", STATUS, 'lendo dados na tabela man_oper_compl '
         RETURN 
      END IF           

      IF STATUS <> 0 THEN

         IF STATUS <> 100 THEN
            LET p_erro = "Erro ", STATUS, 'lendo dados na tabela man_oper_compl '
            RETURN
         END IF              

         INSERT INTO man_oper_compl(
            empresa
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
                 
         IF STATUS <> 0 THEN
            LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela man_oper_compl '
            RETURN
         END IF                      
           
      ELSE
              
         UPDATE man_oper_compl
            SET dat_ini_planejada  = lr_man_oper_drummer.dat_ini_planejada
                ,dat_trmn_planejada = lr_man_oper_drummer.dat_trmn_planejada
          WHERE empresa            = p_cod_empresa
            AND ordem_producao     = lr_man_ordem_drummer.ordem_producao
            AND operacao           = lr_man_oper_drummer.operacao
            AND sequencia_operacao = lr_man_oper_drummer.sequencia_operacao

         IF STATUS <> 0 THEN
            LET p_erro = "Erro ", STATUS, 'atualizando dados na tabela man_oper_compl '
            RETURN
         END IF
           
      END IF

   END FOREACH

END FUNCTION


#----------------------------FIM DO PROGRAMA------------------------#
