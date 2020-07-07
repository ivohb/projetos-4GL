#------------------------------------------------------------------------------#
# SISTEMA.: MANUFATURA      - BI                                               #
# PROGRAMA: pol0922 Linter                                                     #
# OBJETIVO: PROGRAMA DE IMPORTACAO DE DADOS DO DRUMMER PARA O LOGIX - PADRAO   #
# DATA....: 05/12/2008                                                         #   
# ALTERAÇÕES                                                                   #
# Dia 28-04-2009(Manuel) versão 10.02.05 O programa foi alterado para que grave#
#                        as operações da ordem independentemente se o indicador#
#                        na tabela ITEM_MAN.ies_apontamento indicar S/N, até   #
#                        então o programa somente gravava as operações caso    #
#                        esse campo estivesse igual a 'S'                      # 
#                                                                              #
#11/04/16 - Ivo                                                                #
#   - Abrir transação por ordem                                                #
#   - Gravar mesagens para ordens criticadas                                   #
#   - Possibilitar consulta das mensagens de ordens criticadas                 #
#   - Ciração de botão, para reprocessar as ordens criticadas                  #
#25/10/17 - Ivo                                                                #
#   - gravar tabelas de necessidades a partir da tabela man_necd_drummer       #
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

   DEFINE p_ind                     INTEGER,
          m_ies_situa               CHAR(01),
          m_cod_processo            INTEGER

   DEFINE m_caminho                CHAR(100),
          m_help_file              CHAR(100),
          m_comando                CHAR(100),
          #sql_stmt                CHAR(500),
          #where_clause             CHAR(500),
          m_ies_tipo               CHAR(01),
          m_ies_informou           SMALLINT,
          m_num_ordem_aux          LIKE ordens.num_ordem,
          m_rastreia               SMALLINT,
          m_grava_oplote           SMALLINT,
          m_arr_curr               SMALLINT,
          sc_curr                  SMALLINT,
          m_arr_count              SMALLINT,
          m_cod_cent_trab          LIKE consumo.cod_cent_trab,
          p_seq_comp               DECIMAL(10,0),
          m_operacao               CHAR(01),
          p_status_import          CHAR(01),
          l_progres                INTEGER

   DEFINE p_msg                    CHAR(150),
          p_texto                  CHAR(30),
          m_ies_familia            SMALLINT,
          m_qtd_erros              INTEGER

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


DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_browse          VARCHAR(10),
       m_lupa_familia    VARCHAR(10),
       m_zoom_familia    VARCHAR(10),
       m_form_rros       VARCHAR(10),
       m_brow_erros      VARCHAR(10),              
       m_stat_erros      VARCHAR(10)              

DEFINE m_ind             INTEGER,
       m_den_familia     CHAR(30),
       m_msg             VARCHAR(200),
       m_count           INTEGER,
       p_erro            CHAR(80)
       

DEFINE ma_erros ARRAY[1000] OF RECORD
       ordem_mps      char(30),
       item           char(15),
       den_item       char(18),
       erro           char(80),
       filler         CHAR(01)
END RECORD

DEFINE p_prx_num_op    LIKE par_mrp.prx_num_ordem,
       p_prx_num_neces LIKE par_mrp.prx_num_neces

DEFINE mr_param             RECORD
       cod_empresa          CHAR(02),
       ies_docum            CHAR(01)
END RECORD

DEFINE m_dlg_param         VARCHAR(10),
       m_stst_param        VARCHAR(10),
       m_docum             VARCHAR(10),
       m_ies_param         SMALLINT,
       m_num_docum         CHAR(10),
       m_num_ordem         INTEGER,
       m_new_docum         CHAR(10)

#-----------------#
FUNCTION pol0922()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol0922-12.00.03  "

   IF NOT log0150_verifica_se_tabela_existe("agrupa_pol0922") THEN
      IF NOT pol0922_cria_agrupa_pol0922() THEN
         RETURN 
      END IF
   END IF
       
   CALL pol0922_menu()
    
END FUNCTION

#-------------------------------------#
FUNCTION pol0922_cria_agrupa_pol0922()#
#-------------------------------------#

   CREATE TABLE agrupa_pol0922 (
      cod_empresa       CHAR(02),
      cod_processo      INTEGER,
      num_ordem         INTEGER,
      cod_item          CHAR(15),
      cod_item_pai      CHAR(15),
      num_docum         CHAR(10)
   );
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','agrupa_pol0922')
      RETURN FALSE
   END IF
   
   CREATE INDEX ix_agrupa_pol0922 ON 
    agrupa_pol0922(cod_empresa, cod_processo);
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','ix_agrupa_pol0922')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION  

#----------------------#
FUNCTION pol0922_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_proces      VARCHAR(10),
           l_find        VARCHAR(10),
           l_reproces    VARCHAR(10),
           l_titulo      VARCHAR(50),
           l_param        VARCHAR(50)
    
    LET m_ies_familia = FALSE
    LET l_titulo = p_versao CLIPPED, ' - IMPORTAÇÃO DE ORDENS DO DRUMMER'

       #Criação da janela do programa
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)

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
    
    LET l_proces = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_proces,"IMAGE","GERAR_EX")     
    CALL _ADVPL_set_property(l_proces,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Gerar ordens de produção")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol0922_proc_ops")

    LET l_find = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_find,"IMAGE","FIND_EX")     
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_find,"TOOLTIP","Exibe OPs criticadas")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1922_find")

    #FIND_EX / QUIT_EX / CONFIRM_EX / UPDATE_EX / RUN_EX / NEW_EX
    #CANCEL_EX / DELETE_EX / LANCAMENTOS_EX / ESTORNO_EX / SAVEPROFILE
    
    LET l_reproces = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_reproces,"IMAGE","RUN_EX")     
    CALL _ADVPL_set_property(l_reproces,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_reproces,"TOOLTIP","Processa OPs criticadas")
    CALL _ADVPL_set_property(l_reproces,"EVENT","pol0922_proc_critic")

    LET l_param = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_param,"IMAGE","PARAM")     
    CALL _ADVPL_set_property(l_param,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_param,"TOOLTIP","Parâmetros do pol0922")
    CALL _ADVPL_set_property(l_param,"EVENT","pol0922_parametros")


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
FUNCTION pol0922_proc_ops() #
#---------------------------#

   LET m_operacao = "P"
   LET p_status = pol0922_processar()

   RETURN p_status

END FUNCTION

#------------------------------#
FUNCTION pol0922_proc_critic() #
#------------------------------#

   LET m_operacao = "C"
   LET p_status = pol0922_processar()

   RETURN p_status

END FUNCTION
   
#---------------------------#
FUNCTION pol0922_processar()#
#---------------------------#

   DELETE FROM tempo_proces912
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','tempo_proces912')
      RETURN FALSE
   END IF
   
   LET p_status = TRUE
   
   LET m_qtd_erros = 0
   
   IF m_operacao = 'P' THEN
      LET m_msg = p_versao CLIPPED, " - Importando OPs DO drummer"
   ELSE
      LET m_msg = p_versao CLIPPED, " - Importando OPs criticadas"
   END IF
   
   CALL LOG_progresspopup_start(m_msg,"pol0922_importar","PROCESS")

   IF NOT p_status THEN 
      LET m_msg = 'Operação cancelada.'
   ELSE
      IF m_qtd_erros > 0 THEN
         LET m_msg = 'Ordens MPS criticadas: ', m_qtd_erros USING '<<<<<<<<'
      ELSE
         LET m_msg = 'Operação efetuada com sucesso.'
      END IF
   END IF
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   CALL log0030_mensagem(m_msg,'info') 
   
   LET m_ies_familia = FALSE
   
   RETURN p_status

END FUNCTION

#--------------------------#
FUNCTION pol0922_importar()
#--------------------------#
   
   LET p_status = FALSE
   
   SELECT MAX(cod_processo)
     INTO m_cod_processo
     FROM agrupa_pol0922
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','agrupa_pol0922')
      RETURN
   END IF
   
   IF m_cod_processo IS NULL THEN
      LET m_cod_processo = 0
   END IF
   
   LET m_cod_processo = m_cod_processo + 1
       
   IF NOT pol0922_proc_importacao() THEN
   ELSE
      LET p_status = TRUE
   END IF

END FUNCTION

#------------------------------------------#
FUNCTION pol0922_ins_erro(l_num_op, l_item)#
#------------------------------------------#
   
   DEFINE l_num_op CHAR(30),
          l_item   CHAR(15)
   
   LET m_qtd_erros = m_qtd_erros + 1
   
   INSERT INTO ordem_erro_912
    VALUES (p_cod_empresa, l_num_op, l_item, p_erro)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ordem_erro_912')
   END IF

END FUNCTION    

#----------------------------------#
 FUNCTION pol1311_prende_registro()#
#----------------------------------#
   
   DECLARE cq_prende CURSOR FOR
   SELECT prx_num_ordem, prx_num_neces
    FROM par_mrp
   WHERE cod_empresa = p_cod_empresa
     FOR UPDATE 
    
    OPEN cq_prende

    IF STATUS <> 0 THEN
       LET p_erro = "Erro ", STATUS, 'lendo tabela par_mrp for update:open '
       RETURN FALSE
    END IF
    
   FETCH cq_prende INTO p_prx_num_op, p_prx_num_neces

      
   IF STATUS <> 0 THEN
      LET p_erro = "Erro ", STATUS, 'lendo tabela par_mrp for update:FETCH '
      CLOSE cq_prende
      RETURN FALSE
   END IF

   IF p_prx_num_neces IS NULL THEN
      LET p_prx_num_neces = 0
   END IF

   IF p_prx_num_op IS NULL THEN
      LET p_prx_num_op = 0
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0922_proc_importacao()
#---------------------------------#

   DEFINE l_mensagem            CHAR(100),
          l_dat_atu             CHAR(10)
   
   DEFINE lr_ordens             RECORD LIKE ordens.*,
          lr_ord_oper           RECORD LIKE ord_oper.*,
          lr_necessidades       RECORD LIKE necessidades.*,
          lr_man_ordem_drummer  RECORD LIKE man_ordem_drummer.*,
          lr_man_oper_drummer   RECORD LIKE man_oper_drummer.*,
          lr_man_necd_drummer   RECORD LIKE man_necd_drummer.*
          

   DEFINE l_ies_tip_item        LIKE item.ies_tip_item
   DEFINE l_ordem_mps           CHAR(30),
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
          l_ind1                INTEGER

   IF NOT pol0922_cria_temp_estrut() THEN
      RETURN FALSE
   END IF
   
   LET l_dat_atu = TODAY
   
   IF m_operacao = 'P' THEN

      SELECT COUNT(empresa)
        INTO m_count
        FROM man_ordem_drummer
       WHERE empresa       = p_cod_empresa
         AND man_ordem_drummer.ordem_mps IS NOT NULL 
         AND (status_import IS NULL OR status_import = ' ')
   
      IF m_count = 0 THEN
         CALL log0030_mensagem("Não há dados a serem importados","info")
         RETURN FALSE
      END IF
   
      LET p_msg = 'Toda a Programação Atual\n',
                  'Será Sobreposta.\n\n',
	                'Confirma o porcessamento ?' 
	 
	    IF log0040_confirm(20,25,p_msg) THEN
	    ELSE
	       RETURN FALSE
	    END IF

      BEGIN WORK
      IF NOT pol0922_del_ordens() THEN
         ROLLBACK WORK
         RETURN FALSE
      END IF
      COMMIT WORK
      
      DELETE FROM ordem_erro_912

   END IF
   
   #-- Inicializa as variáveis usadas
   INITIALIZE lr_man_ordem_drummer TO NULL
   INITIALIZE m_num_ordem_aux TO NULL
        
   LET sql_stmt = "SELECT man_ordem_drummer.* "
                 ,"  FROM man_ordem_drummer, item "
   
   IF m_operacao = 'P' THEN
      LET where_clause = 
          " WHERE man_ordem_drummer.empresa       = '",p_cod_empresa, "'",
          "  AND man_ordem_drummer.ordem_mps IS NOT NULL ",
          "  AND (man_ordem_drummer.status_import IS NULL OR man_ordem_drummer.status_import = ' ') ",
          "  AND item.cod_empresa        = '",p_cod_empresa, "'",
          "  AND item.cod_item           = man_ordem_drummer.item "
   
   
   
      # Verifica se foi informada alguma família

      IF m_ies_familia THEN
         LET where_clause = where_clause CLIPPED, 
             " AND item.cod_familia IN (SELECT familia FROM familia_tmp) "
      END IF
   ELSE
      LET where_clause = 
          " WHERE man_ordem_drummer.empresa = '",p_cod_empresa, "'",
          "  AND man_ordem_drummer.ordem_mps IS NOT NULL ",
          "  AND man_ordem_drummer.status_import = 'C' ",
          "  AND item.cod_empresa        = '",p_cod_empresa, "'",
          "  AND item.cod_item           = man_ordem_drummer.item "
   END IF

   LET sql_stmt = sql_stmt CLIPPED, " ", where_clause CLIPPED

   LET sql_stmt = sql_stmt CLIPPED, " ",
       " ORDER BY man_ordem_drummer.docum, man_ordem_drummer.item_pai "

   LET l_ind = FALSE
   LET l_ind1 = 0
         
   CALL LOG_progresspopup_set_total("PROCESS", m_count)

   PREPARE var_query1 FROM sql_stmt

   DECLARE cq_man_ordem_drummer_im CURSOR WITH HOLD FOR var_query1

   FOREACH cq_man_ordem_drummer_im INTO lr_man_ordem_drummer.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_man_ordem_drummer_im')
         RETURN FALSE
      END IF
      
      LET m_ies_situa = lr_man_ordem_drummer.status_op
      
      IF m_ies_situa MATCHES "[23]" THEN
      ELSE
         LET m_ies_situa = '3'
      END IF
      
      IF m_operacao = 'C' THEN
         DELETE FROM ordem_erro_912
          WHERE empresa = p_cod_empresa
            AND ordem_mps = lr_man_ordem_drummer.ordem_mps
      END IF
          
     LET l_ind = TRUE
     LET l_ind1 = l_ind1 + 1
	 
     LET l_progres = LOG_progresspopup_increment("PROCESS")

     LET p_num_ordem = lr_man_ordem_drummer.ordem_mps
     
     BEGIN WORK
     
     LET p_erro = NULL
     
     IF lr_man_ordem_drummer.status_ordem = 'P' THEN

        CALL pol0922_gera_novas_ordens(lr_man_ordem_drummer.*) 
        
        IF p_erro IS NOT NULL THEN
           ROLLBACK WORK
           LET p_status_import = 'C'   
           CALL pol0922_ins_erro(
                  lr_man_ordem_drummer.ordem_mps, lr_man_ordem_drummer.item)     
           LET m_num_ordem_aux = NULL
        ELSE
           LET p_status_import = 'X'
           COMMIT WORK
           
           INSERT INTO ordens_x_ordens
            VALUES(p_cod_empresa, 
                   lr_man_ordem_drummer.ordem_mps,
                   m_num_ordem_aux, l_dat_atu)           
        END IF

        UPDATE man_ordem_drummer
           SET man_ordem_drummer.ordem_producao = m_num_ordem_aux,
               man_ordem_drummer.status_import  = p_status_import
         WHERE man_ordem_drummer.empresa        = p_cod_empresa
           AND man_ordem_drummer.ordem_mps      = lr_man_ordem_drummer.ordem_mps

         CLOSE cq_prende
                                   
     END IF

     IF lr_man_ordem_drummer.status_ordem = 'L' THEN

        CALL pol0922_atualiza_ordem(lr_man_ordem_drummer.*) 
        
        IF p_erro IS NOT NULL THEN
           ROLLBACK WORK
           LET p_status_import = 'C'   
           CALL pol0922_ins_erro(
                  lr_man_ordem_drummer.ordem_mps, lr_man_ordem_drummer.item)     
        ELSE
          COMMIT WORK
          LET p_status_import = 'X'
        END IF

        UPDATE man_ordem_drummer
           SET man_ordem_drummer.status_import  = p_status_import
         WHERE man_ordem_drummer.empresa        = p_cod_empresa
           AND man_ordem_drummer.ordem_mps      = lr_man_ordem_drummer.ordem_mps
        
     END IF
     
   END FOREACH
   
   FREE cq_man_ordem_drummer_im
   
	 DELETE FROM ordem_orig_912
	  WHERE cod_empresa=p_cod_empresa
	    AND   num_ordem NOT IN (SELECT  num_ordem FROM ORDENS  WHERE cod_empresa= p_cod_empresa)

   
   SELECT ies_docum INTO mr_param.ies_docum
    FROM param_pol0922
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 100 THEN
      LET mr_param.ies_docum = 'N'
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','param_pol0922')
         LET mr_param.ies_docum = 'N'
      END IF
   END IF
   
   IF mr_param.ies_docum = 'S' THEN
      CALL pol0922_ajusta_docum() RETURNING p_status
   END IF
      
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0922_del_ordens()#
#----------------------------#

   DEFINE l_num_ordem     INTEGER,
          sql_stmt        CHAR(2000),
          where_clause    CHAR(2000)

    
   #Exclui ordens de situacao 3 

    LET sql_stmt = " SELECT num_ordem",
                   "   FROM ordens, item "

    LET where_clause =   
        "  WHERE ordens.cod_empresa = '",p_cod_empresa,"'",
        "    AND ordens.ies_situa = '3'",
        "    AND item.cod_empresa = ordens.cod_empresa ",
        "    AND item.cod_item = ordens.cod_item ",
        "    AND ordens.num_ordem IN ",
        " (SELECT ordem_orig_912.num_ordem FROM ordem_orig_912 ",
        "   WHERE ordem_orig_912.cod_empresa = '",p_cod_empresa,"' ) "

   # Verifica se foi informada alguma família
   
   IF m_ies_familia THEN
      LET where_clause = where_clause CLIPPED, 
          " AND item.cod_familia IN (SELECT familia FROM familia_tmp) "
   END IF

   LET sql_stmt = sql_stmt CLIPPED, " ", where_clause CLIPPED

   CALL LOG_progresspopup_set_total("PROCESS", m_count)

   PREPARE var_ordens_elim FROM sql_stmt
   DECLARE cq_ordens_eliminadas CURSOR WITH HOLD FOR var_ordens_elim

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
               RETURN FALSE
           END IF

           #Elimina necessidades

            DELETE FROM neces_complement
             WHERE cod_empresa = p_cod_empresa AND num_neces IN
               (SELECT num_neces FROM necessidades
                 WHERE cod_empresa = p_cod_empresa 
                   AND num_ordem   = l_num_ordem)
           
           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","neces_complement")
             RETURN FALSE
           END IF           
           
           
            DELETE FROM necessidades
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","NECESSIDADES")
             RETURN FALSE
           END IF

           #Elimina ord_oper
           
           DELETE FROM  man_recurso_operacao_ordem
            WHERE empresa = p_cod_empresa
              AND seq_processo IN
              (SELECT seq_processo FROM ord_oper
                WHERE cod_empresa = p_cod_empresa
                  AND num_ordem   = l_num_ordem)

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","man_recurso_operacao_ordem")
             RETURN FALSE
           END IF
           
            DELETE FROM ord_oper
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","ORD_OPER")
             RETURN FALSE
           END IF

            DELETE FROM ord_oper_txt
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","ord_oper_txt")
             RETURN FALSE
           END IF

            DELETE FROM man_op_componente_operacao
             WHERE empresa = p_cod_empresa
               AND ordem_producao = l_num_ordem
           

           IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("DELETE","man_op_componente_operacao")
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

   COMMIT WORK
   
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

   SELECT COUNT(item) INTO l_cont
      FROM man_necd_drummer
     WHERE empresa = p_cod_empresa
       AND ordem_mps = p_num_ordem

   IF l_cont = 0 THEN
      LET p_erro = "O Drummer nao enviou os componentes da ordem ",p_num_ordem CLIPPED
      RETURN 
   END IF
     
   #Verifica Item
   
     SELECT *
       INTO lr_item.*
       FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = lr_man_ordem_drummer_new.item
   

   IF STATUS <> 0 THEN
      LET p_erro = "Item ",lr_man_ordem_drummer_new.item, " não cadastrado na tabela item "
      RETURN 
   END IF
   
    SELECT *
      INTO lr_item_man.*
      FROM item_man
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = lr_man_ordem_drummer_new.item
   

   IF STATUS <> 0 THEN
      LET p_erro = "Item ",lr_man_ordem_drummer_new.item, " não cadastrado na tabela item_man "
      RETURN 
   END IF

   LET lr_ordens.cod_empresa        = p_cod_empresa
   
   IF NOT pol1311_prende_registro() THEN
      RETURN
   END IF      
   
   LET p_prx_num_op = p_prx_num_op + 1
   
   LET lr_ordens.num_ordem = p_prx_num_op
   
   IF lr_ordens.num_ordem = 0 THEN
      RETURN 
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
   LET lr_ordens.ies_situa          = m_ies_situa
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

   IF STATUS <> 0 THEN
      LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela ordens '
      RETURN 
   END IF
   
   INSERT INTO agrupa_pol0922
    VALUES(lr_ordens.cod_empresa,
           m_cod_processo,
           lr_ordens.num_ordem,
           lr_ordens.cod_item,
           lr_ordens.cod_item_pai,
           lr_ordens.num_docum)

   IF STATUS <> 0 THEN
      LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela agrupa_pol0922 '
      RETURN 
   END IF
   
    LET p_dat_atu = TODAY
   
    INSERT INTO ordem_orig_912
    VALUES(lr_ordens.cod_empresa,
		   lr_ordens.num_ordem, 
		   lr_ordens.dat_entrega,
		   lr_ordens.dat_liberac,
		   p_dat_atu)
             
   IF STATUS <> 0 THEN
      LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela ordem_orig_912 '
      RETURN 
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

   IF STATUS <> 0 THEN
      LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela ordens_complement '
      RETURN 
   END IF
   
   IF m_ies_situa = '3' THEN
      IF  pol0922_inclui_oper_ordem(lr_ordens.*) = FALSE THEN
          RETURN 
      END IF
   END IF
   
   IF  pol0922_inclui_necessidade(lr_ordens.*) = FALSE THEN
       RETURN 
   END IF
   
   IF m_ies_situa = '3' THEN
      IF  pol0922_inclui_comp_ordem(lr_ordens.*) = FALSE THEN
          RETURN 
      END IF
   END IF
   
   UPDATE par_mrp
      SET prx_num_neces = p_prx_num_neces,
          prx_num_ordem = p_prx_num_op
    WHERE cod_empresa   = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_erro = "Erro ", STATUS, 'Atualizando num ordem e num neces na tab par_mrp '
      RETURN 
   END IF
            
END FUNCTION


#--------------------------------------------#
FUNCTION pol0922_inclui_necessidade(lr_ordens)
#--------------------------------------------#

   DEFINE lr_ordens        RECORD LIKE ordens.*

   DEFINE l_texto          CHAR(5000),
          lr_necessidades  RECORD LIKE necessidades.*

   IF NOT pol0922_carrega_feriado() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0922_carrega_semana() THEN
      RETURN FALSE
   END IF
    
   LET lr_necessidades.cod_empresa  = p_cod_empresa
   LET lr_necessidades.num_versao   = lr_ordens.num_versao
   LET lr_necessidades.cod_item_pai = lr_ordens.cod_item
   LET lr_necessidades.num_ordem    = lr_ordens.num_ordem
   LET lr_necessidades.qtd_saida    = 0
   LET lr_necessidades.num_docum    = lr_ordens.num_docum
   LET lr_necessidades.ies_origem   = lr_ordens.ies_origem
   LET lr_necessidades.ies_situa    = m_ies_situa

   IF NOT pol0922_carrega_temp_estrut(lr_ordens.cod_item, lr_ordens.dat_liberac) THEN
      RETURN FALSE
   END IF
   
    DECLARE cq_estrutur CURSOR WITH HOLD FOR
     SELECT * FROM t_estrut_912
      
    FOREACH cq_estrutur INTO p_t_estrut.*
   
       IF STATUS <> 0 THEN
          LET p_erro = "Erro ", STATUS, 'lendo dados da tabela t_estrut_912 '
          RETURN FALSE
       END IF

      LET p_prx_num_neces = p_prx_num_neces + 1
      
      LET lr_necessidades.num_neces = p_prx_num_neces
      
      LET lr_necessidades.dat_neces = pol0922_calcula_data(
          lr_ordens.dat_liberac, (p_t_estrut.tmp_ressup_sobr - p_t_estrut.tmp_ressup))
                                     
      LET lr_necessidades.cod_item = p_t_estrut.cod_item_compon
      LET lr_necessidades.qtd_necessaria = p_t_estrut.qtd_necessaria
      
      INSERT INTO necessidades VALUES (lr_necessidades.*)
      
      IF STATUS <> 0 THEN
         LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela necessidades '
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
         LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela neces_complement '
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
          l_arranjo              CHAR(5),
          l_num_seq              INTEGER

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
   
   DEFINE lr_recurso RECORD LIKE man_recurso_processo.*
   
   LET l_entrou = FALSE

   LET l_num_ordem = p_num_ordem

   
   DECLARE cq_operacao CURSOR WITH HOLD FOR
    SELECT *
      FROM man_oper_drummer
     WHERE empresa   = p_cod_empresa
       AND ordem_mps = p_num_ordem
   
   
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
                  lr_man_processo.qtd_tempo,                                  
                  l_parametro)                                                    

         IF sqlca.sqlcode = 0 THEN
         ELSE
            LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela ord_oper '
            RETURN FALSE
         END IF
         
         LET l_num_seq = SQLCA.SQLERRD[2]

         DECLARE cq_recurso CURSOR FOR 
          SELECT *
            FROM man_recurso_processo
           WHERE empresa = p_cod_empresa
             AND seq_processo = lr_man_processo.seq_processo
         FOREACH cq_recurso INTO lr_recurso.*
           
           IF STATUS <> 0 THEN
              LET p_erro = "Erro ", STATUS, 'lendo dados da tabela man_recurso_processo '
              RETURN FALSE
           END IF
           
           LET lr_recurso.seq_processo = l_num_seq
           
           INSERT INTO man_recurso_operacao_ordem 
           VALUES(lr_recurso.*)

           IF STATUS <> 0 THEN
              LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela man_recurso_processo '
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
               
               IF sqlca.sqlcode = 0  THEN
               ELSE
                  LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela ord_oper_txt '
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
               LET p_erro = "Erro ", STATUS, 'lendo dados da tabela man_estrutura_operacao '
               RETURN FALSE
            END IF
            
            SELECT ies_tip_item
              INTO l_ies_tip_item
              FROM item
             WHERE cod_empresa = p_cod_empresa
               AND cod_item = l_compon
            
            IF STATUS <> 0 THEN
               LET p_erro = "Erro ", STATUS, 'lendo dados da tabela item '
               RETURN FALSE
            END IF
            
            INSERT INTO man_op_componente_operacao 
             VALUES (p_cod_empresa,
                     lr_ordens.num_ordem,                                                              
                     lr_ordens.cod_roteiro ,                                                           
                     lr_ordens.num_altern_roteiro,                                                     
                     lr_man_oper_drummer.sequencia_operacao,                                           
                     lr_man_oper_drummer.item,                                                         
                     l_compon,                                               
                     l_ies_tip_item,                                                  
                     lr_ordens.dat_entrega,                                                            
                     l_qtd_neces,                                                    
                     lr_ordens.cod_local_prod,                                                         
                     m_cod_cent_trab,                                                                              
                     l_pct_refugo,                                                    
                     l_seq,
                     l_num_seq)     
                                                                                       
            IF sqlca.sqlcode = 0  THEN
            ELSE
               LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela man_op_componente_operacao '
               RETURN FALSE
            END IF
               
         END FOREACH
            
      END FOREACH

   END FOREACH

   RETURN TRUE

END FUNCTION

#--------------------------------------------#
 FUNCTION pol0922_inclui_comp_ordem(lr_ordens)
#--------------------------------------------#

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
          LET p_erro = "Erro ", STATUS, 'lendo dados da tabela necessidades '
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
         LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela ord_compon '
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

#----------------------------------#
FUNCTION pol0922_cria_temp_estrut()
#----------------------------------#

      DROP TABLE t_estrut_912
      CREATE TEMP TABLE t_estrut_912(
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
   
   {DECLARE cq_temp CURSOR FOR
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
     ORDER BY num_sequencia}

   DECLARE cq_temp CURSOR FOR
    SELECT item, qtd_necess, 0, 0
      FROM man_necd_drummer
     WHERE empresa = p_cod_empresa
       AND ordem_mps = p_num_ordem
     ORDER BY necessidad_ordem
     
   FOREACH cq_temp INTO 
           p_cod_item_compon,
           p_qtd_necessaria,
           p_pct_refug,
           P_tmp_ressup_sobr

      IF STATUS <> 0 THEN
         LET p_erro = "Erro ", STATUS, 'lendo dados da tabela estrut_grade '
         RETURN FALSE
      END IF
      
      {SELECT tmp_ressup
        INTO P_tmp_ressup
        FROM item_man
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item_pai

      IF STATUS <> 0 THEN
         LET p_erro = "Erro ", STATUS, 'lendo dados da tabela item_man '
         RETURN FALSE
      END IF}
      
      LET P_tmp_ressup = 0
      
      INSERT INTO t_estrut_912
       VALUES(p_cod_item_pai,
              p_cod_item_compon,
              p_qtd_necessaria,
              p_pct_refug,
              P_tmp_ressup,
              P_tmp_ressup_sobr)

      IF STATUS <> 0 THEN
         LET p_erro = "Erro ", STATUS, 'inserindo dados na tabela t_estrut_912 '
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

#----------------------#
FUNCTION pol1922_find()#
#----------------------#
   
   DEFINE l_panel      VARCHAR(10),
          l_menubar    VARCHAR(10)
   
   LET m_form_rros = _ADVPL_create_component(NULL,"LDIALOG")
   CALL _ADVPL_set_property(m_form_rros,"SIZE",870,530)
   CALL _ADVPL_set_property(m_form_rros,"TITLE","APONTAMENTOS CRITICADOS")

   LET m_stat_erros = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_rros)

   LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_rros)
   CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
   
   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_rros)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol0922_cria_gr_erros(l_panel)
   CALL pol0922_le_erros()
   
   CALL _ADVPL_set_property(m_brow_erros,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_brow_erros,"CAN_ADD_ROW",FALSE)
   CALL _ADVPL_set_property(m_brow_erros,"CAN_REMOVE_ROW",FALSE)

   CALL _ADVPL_set_property(m_form_rros,"ACTIVATE",TRUE)


END FUNCTION

#------------------------------------------#
FUNCTION pol0922_cria_gr_erros(l_container)#
#------------------------------------------#

    DEFINE l_container           VARCHAR(10),
           l_panel               VARCHAR(10),
           l_layout              VARCHAR(10),
           l_tabcolumn           VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    
    LET m_brow_erros = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brow_erros,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_erros)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","OP Drummer")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ordem_mps")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_erros)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_erros)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","den_item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",110)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_erros)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",400)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","erro")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_erros)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",10)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
        
    CALL _ADVPL_set_property(m_brow_erros,"SET_ROWS",ma_erros,1)
        
END FUNCTION

#--------------------------#
FUNCTION pol0922_le_erros()#
#--------------------------#

   INITIALIZE ma_erros TO NULL
   LET m_ind = 1
   
   DECLARE cq_erros CURSOR FOR
    SELECT o.ordem_mps, o.item, i.den_item_reduz, o.erro  
      FROM ordem_erro_912 o, item i
     WHERE o.empresa = p_cod_empresa
       AND o.empresa = i.cod_empresa
       AND o.item = i.cod_item
     ORDER BY o.ordem_mps
      
   FOREACH cq_erros INTO 
      ma_erros[m_ind].ordem_mps,
      ma_erros[m_ind].item,     
      ma_erros[m_ind].den_item, 
      ma_erros[m_ind].erro     

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_erros')
         EXIT FOREACH
      END IF
      
      LET m_ind = m_ind + 1

      IF m_ind > 1000 THEN
         CALL _ADVPL_set_property(m_stat_erros,"ERROR_TEXT",
             "Númro de erros ultrapasou a capacidade de linhas da grade.")
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET m_ind = m_ind - 1
   
   CALL _ADVPL_set_property(m_brow_erros,"ITEM_COUNT", m_ind)
   
   FREE cq_erros
   
END FUNCTION

#------------------------------#
FUNCTION pol0922_parametros()#
#------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   INITIALIZE mr_param.* TO NULL
   LET m_ies_param = FALSE
   
   IF NOT log0150_verifica_se_tabela_existe("param_pol0922") THEN
      IF NOT pol0922_cria_param_pol0922() THEN
         RETURN FALSE
      END IF
      LET mr_param.cod_empresa = p_cod_empresa
      LET mr_param.ies_docum = 'N'
   ELSE
      IF NOT pol0922_le_param_pol0922() THEN
         RETURN FALSE
      END IF
   END IF      
      
   CALL pol0922_tela_param()
   CALL log0030_mensagem(m_msg,'info')

END FUNCTION

#------------------------------------#
FUNCTION pol0922_cria_param_pol0922()#
#------------------------------------#
   
   CREATE TABLE param_pol0922(
      cod_empresa CHAR(02) NOT NULL,
      ies_docum   CHAR(01) NOT NULL
   );
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','tabela:param_pol0922')
      RETURN FALSE
   END IF   

   CREATE UNIQUE INDEX ix_param_pol0922 ON
    param_pol0922(cod_empresa);   
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','indice:ix_param_pol0922')
      RETURN FALSE
   END IF   
    
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol0922_le_param_pol0922()#
#----------------------------------#

   SELECT * INTO mr_param.*
     FROM param_pol0922
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 100 THEN
      LET mr_param.cod_empresa = p_cod_empresa
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','indice:param_pol0922')
         RETURN FALSE
      END IF   
      LET m_ies_param = TRUE
   END IF
   
   RETURN TRUE
 
END FUNCTION
    
#----------------------------#
FUNCTION pol0922_tela_param()#
#----------------------------#
   
    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_confirma    VARCHAR(10),
           l_cancela     VARCHAR(10),
           l_label       VARCHAR(10)

   LET m_dlg_param = _ADVPL_create_component(NULL,"LDIALOG")
   CALL _ADVPL_set_property(m_dlg_param,"SIZE",900,500) 
   CALL _ADVPL_set_property(m_dlg_param,"TITLE","PARÂMETROS DO POL0922")
   CALL _ADVPL_set_property(m_dlg_param,"ENABLE_ESC_CLOSE",FALSE)
   CALL _ADVPL_set_property(m_dlg_param,"INIT_EVENT","pol0922_posiciona")

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dlg_param)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
   CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirma,"EVENT","pol0922_conf_param")  

   LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancela,"EVENT","pol0922_canc_param")     

    LET m_stst_param = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dlg_param)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dlg_param)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol0922_param_item(l_panel)

    CALL _ADVPL_set_property(m_dlg_param,"ACTIVATE",TRUE)
    
   
END FUNCTION

#---------------------------#
FUNCTION pol0922_posiciona()#
#---------------------------#

   CALL _ADVPL_set_property(m_docum,"GET_FOCUS")

END FUNCTION

#-----------------------------------#
FUNCTION pol0922_param_item(l_panel)#
#-----------------------------------#

    DEFINE l_panel           VARCHAR(10),
           l_desc            VARCHAR(10),
           l_label           VARCHAR(10),
           l_arq             VARCHAR(10),
           l_lupa            VARCHAR(10),
           l_empresa         VARCHAR(10)
    
    LET m_msg = "Gravar número da ordem do item pai no campo num_docum das ordens filhas:"
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,20)     
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_empresa = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel)
    CALL _ADVPL_set_property(l_empresa,"POSITION",100,20)     
    CALL _ADVPL_set_property(l_empresa,"EDITABLE",FALSE)     
    CALL _ADVPL_set_property(l_empresa,"VARIABLE",mr_param,"cod_empresa")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",250,20)     
    CALL _ADVPL_set_property(l_label,"TEXT",m_msg)   
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_docum = _ADVPL_create_component(NULL,"LCHECKBOX",l_panel)
    CALL _ADVPL_set_property(m_docum,"POSITION",660,20)     
    CALL _ADVPL_set_property(m_docum,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_docum,"VARIABLE",mr_param,"ies_docum")
    CALL _ADVPL_set_property(m_docum,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_docum,"VALUE_NCHECKED","N")     

END FUNCTION

#----------------------------#
FUNCTION pol0922_conf_param()#
#----------------------------#
   
   LET m_msg = 'Operação efetuada com sucesso.'
   
   IF NOT m_ies_param THEN
      INSERT INTO param_pol0922
       VALUES(mr_param.*)
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','param_pol0922')
         LET m_msg = 'Operação cancelada.'
      END IF
   ELSE
      UPDATE param_pol0922 SET ies_docum = mr_param.ies_docum
       WHERE cod_empresa = p_cod_empresa
          
      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','param_pol0922')
         LET m_msg = 'Operação cancelada.'
      END IF
   END IF
   
   CALL _ADVPL_set_property(m_dlg_param,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0922_canc_param()#
#----------------------------#

   LET m_msg = 'Operação cancelada.'
   
   CALL _ADVPL_set_property(m_dlg_param,"ACTIVATE",FALSE)
   
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol0922_ajusta_docum()#
#------------------------------#
                
   DECLARE cq_ajusta CURSOR FOR
    SELECT num_ordem, num_docum
      FROM agrupa_pol0922
     WHERE cod_empresa = p_cod_empresa
       AND cod_processo = m_cod_processo
       AND cod_item_pai = '0'
   
   FOREACH cq_ajusta INTO m_num_ordem, m_num_docum
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_ajusta')
         RETURN FALSE
      END IF
      
      LET m_new_docum = m_num_ordem

      IF NOT pol0922_grava_docum() THEN
         RETURN FALSE
      END IF
      
      DECLARE cq_ops_filha CURSOR FOR
       SELECT num_ordem 
         FROM agrupa_pol0922
        WHERE cod_empresa = p_cod_empresa
          AND cod_processo = m_cod_processo
          AND num_docum = m_num_docum
          AND cod_item_pai <> '0'
   
      FOREACH cq_ops_filha INTO m_num_ordem
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_ops_filha')
            RETURN FALSE
         END IF

         IF NOT pol0922_grava_docum() THEN
            RETURN FALSE
         END IF
     
      END FOREACH

   END FOREACH
   
   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol0922_grava_docum()#
#-----------------------------#

   UPDATE ordens SET num_docum = m_new_docum
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ordens')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
              

#----------------------------FIM DO PROGRAMA------------------------#
