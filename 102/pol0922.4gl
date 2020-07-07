#------------------------------------------------------------------------------#
# SISTEMA.: MANUFATURA      - BI                                               #
# PROGRAMA: pol0922                                                            #
# OBJETIVO: PROGRAMA DE IMPORTACAO DE DADOS DO DRUMMER PARA O LOGIX - PADRAO   #
# DATA....: 05/12/2008                                                         #   
# ALTERAÇÕES                                                                   #
# Dia 28-04-2009(Manuel) versão 10.02.05 O programa foi alterado para que grave#
#                        as operações da ordem independentemente se o indicador#
#                        na tabela ITEM_MAN.ies_apontamento indicar S/N, até   #
#                        então o programa somente gravava as operações caso    #
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

   DEFINE p_msg                    CHAR(150),
          p_texto                  CHAR(30),
          m_ies_familia            SMALLINT

   DEFINE ma_familia ARRAY[500] OF RECORD
          cod_familia LIKE familia.cod_familia,
          den_familia LIKE familia.den_familia,
          filler      CHAR(01)
   END RECORD

   DEFINE mr_par_logix             RECORD LIKE par_logix.*,
          mr_par_pcp               RECORD LIKE par_pcp.*,
          mr_par_mrp               RECORD LIKE par_mrp.*,
          mr_necessidades          RECORD LIKE necessidades.*,
          mr_ord_compon            RECORD LIKE ord_compon.*

#END MODULARES

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_browse          VARCHAR(10),
       m_lupa_familia    VARCHAR(10),
       m_zoom_familia    VARCHAR(10)              

DEFINE m_ind             INTEGER,
       m_den_familia     CHAR(30),
       m_msg             VARCHAR(200),
       m_count           INTEGER

#-----------------#
FUNCTION pol0922()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol0922-12.00.06  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol0922_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol0922_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_proces      VARCHAR(10)
    
    LET m_ies_familia = FALSE

       #Criação da janela do programa
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE","IMPORTAÇÃO DE ORDENS DO DRUMMER")

       #Criação da barra de status
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

       #Criação da barra de menu
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

       #Criação do botão informar
    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol0922_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol0922_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol0922_cancelar")
    
       #Criação do botão processar
    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"EVENT","pol0922_processar")

       #Criação do botão sair
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    #Criação de um painel, para organizar os campos de pesquisa.    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol0922_cria_grade(l_panel)

    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

       #Exibe a janela do programa
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#---------------------------------------#
FUNCTION pol0922_cria_grade(l_container)#
#---------------------------------------#

    DEFINE l_container           VARCHAR(10),
           l_panel               VARCHAR(10),
           l_layout              VARCHAR(10),
           l_tabcolumn           VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    
    CALL _ADVPL_set_property(m_browse,"AFTER_ROW_EVENT","pol0922_row_familia")
    
    # código da familia

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Familia")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",5)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol0922_checa_familia")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_familia")

    # zoom da familia
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol0922_zoom_familia")

    #descrição da familia
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",185)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_familia")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
        
    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_familia,1)
        
END FUNCTION

#-----------------------------#
FUNCTION pol0922_row_familia()#
#-----------------------------#

   DEFINE l_lin_atu, l_ind   SMALLINT
      
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN
      IF ma_familia[l_lin_atu].cod_familia IS NULL OR 
         ma_familia[l_lin_atu].cod_familia = ' ' THEN
         RETURN FALSE
      END IF

      FOR l_ind = 1 TO 500
         IF ma_familia[l_ind].cod_familia IS NULL OR 
            ma_familia[l_ind].cod_familia = ' ' THEN
            EXIT FOR
         END IF
         IF l_ind <> l_lin_atu AND
            ma_familia[l_ind].cod_familia = ma_familia[l_lin_atu].cod_familia THEN
            CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Família já informada.")
            RETURN FALSE
         END IF
      END FOR

   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0922_zoom_familia()#
#------------------------------#
    
   DEFINE l_codigo      LIKE Familia.cod_familia,
          l_lin_atu     INTEGER
          
   IF  m_zoom_familia IS NULL THEN
       LET m_zoom_familia = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_familia,"ZOOM","zoom_familia")
   END IF

   CALL _ADVPL_get_property(m_zoom_familia,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_zoom_familia,"RETURN_BY_TABLE_COLUMN","familia","cod_familia")

   IF l_codigo IS NOT NULL THEN
      LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
      LET ma_familia[l_lin_atu].cod_familia = l_codigo
      CALL pol0922_le_familia(l_codigo) RETURNING p_status
      LET ma_familia[l_lin_atu].den_familia = m_den_familia   
   END IF
    
END FUNCTION

#-------------------------------#
FUNCTION pol0922_checa_familia()#
#-------------------------------#

   DEFINE l_lin_atu       SMALLINT
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
      
   LET ma_familia[l_lin_atu].den_familia = ''
   
   IF ma_familia[l_lin_atu].cod_familia IS NULL THEN
      RETURN TRUE
   END IF
       
   IF NOT pol0922_le_familia(ma_familia[l_lin_atu].cod_familia) THEN
      LET m_msg = 'Familia não existe.'
      CALL log0030_mensagem(m_msg,'excl')
      RETURN FALSE
   END IF
   
   LET ma_familia[l_lin_atu].den_familia = m_den_familia
      
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol0922_le_familia(l_familia)#
#-------------------------------------#

   DEFINE l_familia     LIKE familia.cod_familia
   
   SELECT den_familia
     INTO m_den_familia
     FROM familia
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = l_familia
      
   IF STATUS <> 0 THEN
      LET m_den_familia = ''
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION
    
#--------------------------#
FUNCTION pol0922_informar()#
#--------------------------#

   DROP TABLE familia_tmp
   
   CREATE  TABLE familia_tmp (
      familia  CHAR(05)
   )
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('criando','familia_tmp')
      RETURN FALSE
   END IF
     
   LET m_ies_familia = FALSE
   
   INITIALIZE ma_familia TO NULL
   
   CALL _ADVPL_set_property(m_browse,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", 1)
      
   RETURN TRUE 
    
END FUNCTION

#---------------------------#
FUNCTION pol0922_confirmar()#
#---------------------------#
      
   FOR m_ind = 1 TO 500
       IF ma_familia[m_ind].cod_familia IS NOT NULL THEN
          INSERT INTO familia_tmp VALUES(ma_familia[m_ind].cod_familia)
          LET m_ies_familia = TRUE
       END IF       
   END FOR
   
   IF NOT m_ies_familia THEN
      LET m_msg = 'Informar familia não é obrigatório.\n',
                  'Más como você escolheu  essa opção,\n',
                  'agora você deve cancelar a operação\n',
                  'ou informar pelo menos uma familia \n',
                  'antes de confirmar.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0922_cancelar()#
#--------------------------#
  
   CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_browse,"CLEAR")

    RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0922_processar()#
#---------------------------#

   LET p_status = TRUE
   
   CALL LOG_progresspopup_start("importando ordens...","pol0922_importar","PROCESS")

   IF NOT p_status THEN 
      LET m_msg = 'Operação cancelada.'
   ELSE
      LET m_msg = 'Operação efetuada com sucesso.'
   END IF
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   CALL log0030_mensagem(m_msg,'info') 
   
   LET m_ies_familia = FALSE
   
   RETURN p_status

END FUNCTION

#-----------------------------#
FUNCTION pol0922_bloquia_tab()
#-----------------------------#
   
   DEFINE p_erro      CHAR(10)
   
   LOCK TABLE par_mrp IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, 'bloqueando tabela PAR_MRP.\n',
                  'Não foi possivel abrir essa tabela\n em modo exclusivo.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0922_importar()
#--------------------------#

   IF NOT pol0922_proc_importacao() THEN
      LET p_status = FALSE
   ELSE
      LET p_status = TRUE
   END IF

END FUNCTION

#---------------------------------#
FUNCTION pol0922_proc_importacao()
#---------------------------------#

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
          l_ind1                INTEGER,
          l_progres             INTEGER


   LET p_msg = 'Toda a Programação Atual\n',
               'Será Sobreposta.\n\n',
	             'Confirma o porcessamento ?' 
	 
	 IF log0040_confirm(20,25,p_msg) THEN
	 ELSE
	    RETURN FALSE
	 END IF
      
   IF NOT pol0922_cria_temp_estrut() THEN
      RETURN FALSE
   END IF

   #-- Inicializa as variáveis usadas
   INITIALIZE lr_man_ordem_drummer TO NULL
   INITIALIZE m_num_ordem_aux TO NULL

   LET m_ies_processou = FALSE
   LET m_ocorreu_erro  = FALSE

   LET l_count = 0
   
   SELECT COUNT(empresa)
     INTO l_count
     FROM man_ordem_drummer
    WHERE empresa       = p_cod_empresa
      AND (status_import <> "X" OR status_import IS NULL)
   
   IF l_count = 0 THEN
      CALL log0030_mensagem("Não há dados a serem importados","info")
      RETURN FALSE
   END IF
   
   LET m_count = l_count
   
   BEGIN WORK
   
   IF NOT pol0922_bloquia_tab() THEN
      ROLLBACK WORK
      RETURN FALSE
   END IF
   
   #Exclui ordens de situacao 3 

    LET sql_stmt = " SELECT num_ordem",
                   "   FROM ordens, item "

    LET where_clause =   
        "  WHERE ordens.cod_empresa = '",p_cod_empresa,"'",
        "    AND ordens.ies_situa = '3'",
        "    AND item.cod_empresa = ordens.cod_empresa ",
        "    AND item.cod_item = ordens.cod_item "

   # Verifica se foi informada alguma família
   
   IF m_ies_familia THEN
      LET l_informou_familia = TRUE
      LET where_clause = where_clause CLIPPED, 
          " AND item.cod_familia IN (SELECT familia FROM familia_tmp) "
   END IF

   LET sql_stmt = sql_stmt CLIPPED, " ", where_clause CLIPPED

   CALL LOG_progresspopup_set_total("PROCESS", m_count)

   PREPARE var_ordens_elim FROM sql_stmt
   DECLARE cq_ordens_eliminadas CURSOR FOR var_ordens_elim

   FOREACH cq_ordens_eliminadas INTO l_num_ordem

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_ordens_eliminadas')
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")                       
           
           #Elimina ordens_complement
           
            DELETE FROM ordens_complement
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           

           IF  sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("DELETE","ORDENS_COMPLEMENT")
               ROLLBACK WORK
               RETURN FALSE
           END IF

           #Elimina necessidades
           
            DELETE FROM necessidades
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","NECESSIDADES")
             ROLLBACK WORK
             RETURN FALSE
           END IF

           #Elimina ord_oper
           
            DELETE FROM ord_oper
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","ORD_OPER")
             ROLLBACK WORK
             RETURN FALSE
           END IF

           #Elimina man_oper_compl
           
            DELETE FROM man_oper_compl
             WHERE empresa            = p_cod_empresa
               AND ordem_producao     = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("DELETE","MAN_OPER_COMPL")
              ROLLBACK WORK
              RETURN FALSE
           END IF

           #Elimina ord_compon
           
            DELETE FROM ord_compon
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","ORD_COMPON")
             ROLLBACK WORK
             RETURN FALSE
           END IF

           #Elimina Ordens
           
             DELETE FROM ordens
              WHERE cod_empresa      = p_cod_empresa
                AND num_ordem        = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("DELETE","ORDENS")
              ROLLBACK WORK
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

   # Verifica se foi informada alguma família

   IF m_ies_familia THEN
      LET l_informou_familia = TRUE
      LET where_clause = where_clause CLIPPED, 
          " AND item.cod_familia IN (SELECT familia FROM familia_tmp) "
   END IF

   LET sql_stmt = sql_stmt CLIPPED, " ", where_clause CLIPPED

   LET sql_stmt = sql_stmt CLIPPED, " ",
       " ORDER BY man_ordem_drummer.dat_recebto "

   LET l_ind = FALSE
   LET l_ind1 = 0

   CALL LOG_progresspopup_set_total("PROCESS", m_count)

   PREPARE var_query1 FROM sql_stmt

   DECLARE cq_man_ordem_drummer_im CURSOR FOR var_query1

   FOREACH cq_man_ordem_drummer_im INTO lr_man_ordem_drummer.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_man_ordem_drummer_im')
         RETURN FALSE
      END IF

     LET l_ind = TRUE
     LET l_ind1 = l_ind1 + 1
	 
     LET l_progres = LOG_progresspopup_increment("PROCESS")

     LET p_num_ordem = lr_man_ordem_drummer.ordem_mps

     LET p_texto = 'Lendo Ordem Drummer ', p_num_ordem
     DISPLAY p_texto AT 18,28
     
     IF lr_man_ordem_drummer.status_ordem = 'P' THEN

        #inclui ordens planejadas (ies_situa = 3)
        # nas tabelas do Logix conforme dados selecionados

        IF NOT pol0922_gera_novas_ordens(lr_man_ordem_drummer.*) THEN
           CALL log0030_mensagem( 'Não foi possível criar as novas ordens.Refazer processo.','info')
           ROLLBACK WORK
           RETURN FALSE
        ELSE
 		       LET p_texto = 'Gravando Ordem Logix ', m_num_ordem_aux
			     DISPLAY p_texto AT 20,28
           UPDATE man_ordem_drummer
              SET man_ordem_drummer.ordem_producao = m_num_ordem_aux,
                  man_ordem_drummer.status_import  = "X"
            WHERE man_ordem_drummer.empresa        = p_cod_empresa
              AND man_ordem_drummer.ordem_mps      = lr_man_ordem_drummer.ordem_mps
           
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql( 'UPDATE', "man_ordem_drummer" )
              ROLLBACK WORK
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
           ROLLBACK WORK
           RETURN FALSE
        END IF         
		 
		    LET p_texto = 'Atualizando Ordem Logix ', lr_man_ordem_drummer.ordem_producao
		    DISPLAY p_texto AT 20,28 

        #Atualiza os registros nas tabelas intermediárias
        
        UPDATE man_ordem_drummer
           SET man_ordem_drummer.status_import  = "X"
         WHERE man_ordem_drummer.empresa        = p_cod_empresa
           AND man_ordem_drummer.ordem_producao = lr_man_ordem_drummer.ordem_producao
        
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql( 'UPDATE', "man_ordem_drummer" )
           ROLLBACK WORK
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
                 ROLLBACK WORK
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
                    ROLLBACK WORK
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
                 ROLLBACK WORK
                 RETURN FALSE
              END IF
           END IF

        END FOREACH

     END IF

   END FOREACH

   IF l_ind = FALSE THEN
      CALL log0030_mensagem("Tabelas para processamento estão vazias para os dados informados.","info")
      ROLLBACK WORK
      RETURN FALSE
   END IF

   
   COMMIT WORK
   

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql( 'COMMIT', "TRANSACAO" )
      RETURN FALSE
   END IF

# Elimina registros da tabela ordem_orig_912 que não existam mais na tabela ORDENS pois foram enviadas para historico. 
   
	DELETE FROM ordem_orig_912
	 WHERE cod_empresa=p_cod_empresa
	   AND   num_ordem NOT IN (SELECT  num_ordem FROM ORDENS  WHERE cod_empresa= p_cod_empresa)

   CALL log0030_mensagem('Importação e processo de atualização - executados com sucesso','info')

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
      ERROR "Item ",lr_man_ordem_drummer_new.item, " não cadastrado "
      RETURN FALSE
   END IF

   
    SELECT *
      INTO lr_item_man.*
      FROM item_man
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = lr_man_ordem_drummer_new.item
   

   IF sqlca.sqlcode <> 0 THEN
      ERROR "Item ",lr_man_ordem_drummer_new.item, " não encontrado na ITEM_MAN "
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
   LET lr_ordens.ies_origem         = 1  {Alteração efetuada por Manuel em 16-04-2009 antes a opção era 3}
   LET lr_ordens.ies_situa          = 3
   LET lr_ordens.ies_abert_liber    = 2
   LET lr_ordens.ies_baixa_comp     = lr_item_man.ies_baixa_comp {Alteração efetuada por Manuel em 16-04-2009 antes a opção era fixo 1}
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
   
    LET p_dat_atu = TODAY
   
    INSERT INTO ordem_orig_912
    VALUES(lr_ordens.cod_empresa,
		   lr_ordens.num_ordem, 
		   lr_ordens.dat_entrega,
		   lr_ordens.dat_liberac,
		   p_dat_atu)
             
    IF STATUS <> 0 THEN
       CALL log003_err_sql('INSERT','ordem_orig_912')
       ROLLBACK WORK
       RETURN FALSE
    END IF

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
         

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql( "INSERT", "ORDENS_COMPLEMENT" )
         RETURN FALSE
      END IF
      

   IF  pol0922_inclui_oper_ordem(lr_ordens.*) = FALSE THEN
       RETURN FALSE
   END IF

   IF  pol0922_inclui_necessidade(lr_ordens.*) = FALSE THEN
       RETURN FALSE
   END IF

   IF  pol0922_inclui_comp_ordem(lr_ordens.*) = FALSE THEN
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
      
      INSERT INTO NECES_COMPLEMENT (
        COD_EMPRESA, 
        NUM_NECES, 
        COD_GRADE_1, 
        COD_GRADE_2, 
        COD_GRADE_3, 
        COD_GRADE_4, 
        COD_GRADE_5, 
        ORDEM_PRODUCAO_PAI,
        SEQUENCIA_IT_OPERACAO, 
        SEQ_PROCESSO) 
      VALUES(p_cod_empresa, lr_necessidades.num_neces ,' ',' ',' ',' ',' ',NULL, 0, 0)

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","NECES_COMPLEMENT")
         RETURN FALSE
      END IF
      
   END FOREACH

   RETURN TRUE

END FUNCTION

#-------------------------------------------------#
 FUNCTION pol0922_inclui_oper_ordem(lr_ordens)
#-------------------------------------------------#

   DEFINE lr_ordens              RECORD LIKE ordens.*,
          lr_man_processo        RECORD LIKE man_processo_item.*,
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
   
   DEFINE l_processo          char(07),
          l_tipo              char(01),
          l_linha             integer,
          l_texto             char(70),
          l_seq               integer,
          l_compon            char(15),
          l_qtd_neces         decimal(10,3),
          l_pct_refugo        decimal(5,2),
          l_ies_tip_item      char(01)
   
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
            CALL log003_err_sql('Lendo','man_processo_item:cq_processo')
            RETURN FALSE
         END IF

         LET m_cod_cent_trab = lr_man_processo.centro_trabalho
         LET l_entrou = TRUE
         LET l_parametro = lr_man_processo.seq_processo USING '<<<<<<<'
            
         SELECT cod_empresa
           FROM arranjo
          WHERE cod_empresa = p_cod_empresa
            AND cod_arranjo = lr_man_oper_drummer.arranjo

         IF sqlca.sqlcode <> 0 THEN
            IF sqlca.sqlcode <> 100 THEN
               CALL log003_err_sql("SELECT","CONSUMO")
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
                  lr_man_processo.qtd_tempo,                                  
                  l_parametro)                                                    

         IF sqlca.sqlcode = 0 OR
            log0030_err_sql_registro_duplicado() THEN
         ELSE
            CALL log003_err_sql("INCLUSAO","ORD_OPER")
            RETURN FALSE
         END IF
            
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
            CALL log003_err_sql("INSERT3","MAN_OPER_COMPL")
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
               CALL log003_err_sql('Lendo','man_texto_processo:cq_cons_txt')
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
                  CALL log003_err_sql("INCLUSAO", "ORD_OPER_TXT")
                  RETURN FALSE
               END IF
          
         END FOREACH
            
         DECLARE cq_estr_oper CURSOR WITH HOLD FOR
          SELECT seq_componente,
                 item_componente, 
                 qtd_necessaria, 
                 pct_refugo 
            FROM man_estrutura_operacao
           WHERE empresa      = p_cod_empresa 
             AND item_pai     = lr_man_oper_drummer.item
             AND seq_processo = lr_man_processo.seq_processo            

         FOREACH cq_estr_oper INTO l_seq, l_compon, l_qtd_neces, l_pct_refugo

            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','man_estrutura_operacao:cq_estr_oper')
               RETURN FALSE
            END IF
            
            SELECT ies_tip_item
              INTO l_ies_tip_item
              FROM item
             WHERE cod_empresa = p_cod_empresa
               AND cod_item = lr_man_oper_drummer.item
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','item:cq_estr_oper')
               RETURN FALSE
            END IF
            
            INSERT INTO man_op_componente_operacao 
             VALUES (p_cod_empresa,
                     lr_ordens.num_ordem,                                                              
                     lr_ordens.cod_roteiro ,                                                           
                     lr_ordens.num_altern_roteiro,                                                     
                     lr_man_oper_drummer.sequencia_operacao,                                           
                     lr_man_oper_drummer.item,                                                         
                     lr_man_estrut_oper.item_componente,                                               
                     l_ies_tip_item,                                                  
                     lr_ordens.dat_entrega,                                                            
                     l_qtd_neces,                                                    
                     lr_ordens.cod_local_prod,                                                         
                     m_cod_cent_trab,                                                                              
                     l_pct_refugo,                                                    
                     l_seq,
                     lr_man_processo.seq_processo)     
                                                                                       
            IF sqlca.sqlcode = 0 OR
               log0030_err_sql_registro_duplicado() THEN
            ELSE
               CALL log003_err_sql("INCLUSAO", "MAN_OP_COMPONENTE_OPERACAO")
               RETURN FALSE
            END IF
               
         END FOREACH
            
      END FOREACH

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

   LET l_familia_zoom = log009_popup(8,10,"FAMÍLIAS","familia","cod_familia","den_familia","man0040","S","")

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

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','par_mrp:num_op')
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
          P_tmp_ressup      LIKE item_man.tmp_ressup,
          l_num_seq         INTEGER

   DELETE FROM t_estrut_912
   
   DECLARE cq_temp CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria, 
           pct_refug,      
           tmp_ressup_sobr,
           num_sequencia
      FROM estrut_grade
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_cod_item_pai
       AND (dat_validade_ini IS NULL OR dat_validade_ini <= p_dat_liberac)   
       AND (dat_validade_fim IS NULL OR dat_validade_fim >= p_dat_liberac)
     ORDER BY num_sequencia
       
   FOREACH cq_temp INTO 
           p_cod_item_compon,
           p_qtd_necessaria,
           p_pct_refug,
           P_tmp_ressup_sobr,
           l_num_seq

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
