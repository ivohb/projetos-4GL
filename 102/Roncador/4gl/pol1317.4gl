#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1317                                                 #
# OBJETIVO: PREVISÃO DE RATEIO DE DESPESAS                          #
# AUTOR...: IVO                                                     #
# DATA....: 30/11/16                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_datini          VARCHAR(10),
       m_datfim          VARCHAR(10),
       m_time_sheet      VARCHAR(10),
       m_zoom_sheet      VARCHAR(10),
       m_lupa_sheet      VARCHAR(10),
       m_emp_orig        VARCHAR(10),
       m_nom_emp         VARCHAR(10),
       m_periodo         VARCHAR(10),
       m_browse          VARCHAR(10),
       m_form_popup      VARCHAR(10),
       m_brow_popup      VARCHAR(10),
       m_construct       VARCHAR(10),
       m_filtro          VARCHAR(10),
       m_form_imp        VARCHAR(10),
       m_brow_imp        VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_caminho         CHAR(100),
       m_comando         CHAR(200),
       m_ies_ambiente    CHAR(001),
       m_houve_erro      SMALLINT,
       m_cod_empresa     CHAR(02),
       m_num_rateio      INTEGER,
       m_timesheet       CHAR(01),
       m_index           INTEGER,
       m_num_previsao    INTEGER,
       m_dat_atu         DATE,
       m_cent_custo      INTEGER,
       m_origem          CHAR(03),
       m_num_seq         INTEGER,
       m_qtd_ad          INTEGER,
       m_page_length     SMALLINT,
       m_den_empresa     VARCHAR(36),
       m_dat_ini         CHAR(10),
       m_dat_fim         CHAR(10),
       m_exibiu_ts       SMALLINT,
       m_num_ad          INTEGER

DEFINE mr_parametro      RECORD
       dat_ini           DATE,
       dat_fim           DATE,
       num_rateio        INTEGER,
       cod_emp_orig      VARCHAR(02),
       nom_emp_orig      VARCHAR(40),
       periodo           CHAR(07)
END RECORD

DEFINE ma_itens          ARRAY[300] OF RECORD
       cod_emp_dest      CHAR(02),
       den_emp_dest      VARCHAR(40),
       cod_cent_cust     DECIMAL(4,0),
       nom_cent_cust     CHAR(30),
       cod_aen           CHAR(08),
       den_aen           CHAR(30),
       pct_rateio        DECIMAL(5,2)
END RECORD

DEFINE ma_rateio         ARRAY[300] OF RECORD 
       num_rateio        INTEGER, 
       empresa_orig      CHAR(02),
       periodo           CHAR(07)
END RECORD       

DEFINE mr_ad             RECORD LIKE ad_mestre.*

DEFINE mr_rateio         RECORD
       num_previsao      INTEGER,
       num_ad            INTEGER,
       num_seq           INTEGER,
       empresa_dest      CHAR(02), 
       cod_cent_cust     DECIMAL(4,0),
       cod_aen           CHAR(08),      
       pct_rateio        DECIMAL(5,2),
       val_rateio        DECIMAL(12,2),
       num_docum         INTEGER,
       num_titulo        CHAR(10)
END RECORD       

DEFINE ma_previsao      ARRAY[2000] OF RECORD 
      num_previsao      INTEGER,
      dat_ini           DATE,
      dat_fim           DATE
END RECORD      

DEFINE mr_relat         RECORD
       cod_cent_cust    DECIMAL(5,0),       
       empresa_dest     CHAR(02),    
       cod_fornecedor   CHAR(15),  
       num_docum        INTEGER,       
       origem           CHAR(03),          
       cod_tip_despesa  DECIMAL(4,0), 
       dat_rec_nf       DATE,     
       pct_rateio       DECIMAL(5,2),      
       val_rateio       DECIMAL(12,2),
       nom_fornec       CHAR(36),
       nom_despesa      CHAR(30),
       nom_cent_cust    CHAR(30)
END RECORD                    
#-----------------#
FUNCTION pol1317()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 11

   LET p_versao = "pol1317-12.00.10  "
   CALL func002_versao_prg(p_versao)
   LET m_cod_empresa = p_cod_empresa

   CALL pol1317_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1317_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_proces      VARCHAR(10),
           l_print       VARCHAR(10)
     
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE","PREVISÃO DE RATEIO DE DESPESAS")
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1317_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1317_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1317_cancelar")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1317_processar")

    LET l_print = _ADVPL_create_component(NULL,"LPRINTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_print,"EVENT","pol1317_sel_previsao")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1317_cria_campos(l_panel)
    CALL pol1317_cria_grade(l_panel)
    CALL pol1317_limpa_campos()
    CALL pol1317_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1317_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_campos          VARCHAR(10)


    LET l_campos = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_campos,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_campos,"HEIGHT",130)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_campos)
    CALL _ADVPL_set_property(l_panel,"ALIGN","NONE")
    CALL _ADVPL_set_property(l_panel,"BOUNDS",20,10,480,30) #PH,PV,L,A
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",4)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Período de:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_datini = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_datini,"VARIABLE",mr_parametro,"dat_ini")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","   Até:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_datfim = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_datfim,"VARIABLE",mr_parametro,"dat_fim")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_campos)
    CALL _ADVPL_set_property(l_panel,"ALIGN","NONE")
    CALL _ADVPL_set_property(l_panel,"BOUNDS",20,50,480,60)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",3)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Grade timesheet:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_time_sheet = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_time_sheet,"LENGTH",8,0)
    CALL _ADVPL_set_property(m_time_sheet,"VARIABLE",mr_parametro,"num_rateio")
    CALL _ADVPL_set_property(m_time_sheet,"PICTURE","@E ########")
    CALL _ADVPL_set_property(m_time_sheet,"VALID","pol1317_valida_timesheet")

    LET m_lupa_sheet = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_sheet,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_sheet,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_sheet,"CLICK_EVENT","pol1317_zoom_sheet")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    

    LET m_emp_orig = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_emp_orig,"LENGTH",4) 
    CALL _ADVPL_set_property(m_emp_orig,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_emp_orig,"VARIABLE",mr_parametro,"cod_emp_orig")

    LET m_nom_emp = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_nom_emp,"LENGTH",40) 
    CALL _ADVPL_set_property(m_nom_emp,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_nom_emp,"VARIABLE",mr_parametro,"nom_emp_orig")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Período:")    
    
    LET m_periodo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_periodo,"LENGTH",7) 
    CALL _ADVPL_set_property(m_periodo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_periodo,"VARIABLE",mr_parametro,"periodo")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")    

END FUNCTION

#---------------------------------------#
FUNCTION pol1317_cria_grade(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Empresa dest")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_emp_dest")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",2)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome empresa")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",270)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_emp_dest")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cent custo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cent_cust")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",4,0)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ####")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome cent custo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",300)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_cent_cust")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cod AEN")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_aen")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",8,0)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome AEN")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",300)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_aen")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","% Rateio")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pct_rateio")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",5,2)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ###.##")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1317_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
    
   CALL _ADVPL_set_property(m_datini,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_datfim,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_time_sheet,"EDITABLE",l_status)

END FUNCTION

#----------------------------#
FUNCTION pol1317_zoom_sheet()#
#----------------------------#

    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","PESQUISA RATEIO MENSAL")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","rateio_mensal_orig912","Rateio")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","rateio_mensal_orig912","ano","Ano",1 {CHAR},4,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","rateio_mensal_orig912","mes","Mês",1 {CHAR},2,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF  l_status THEN
        LET l_where_clause = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_construct,"ORDER_BY")
        CALL pol1317_cria_cursor(l_where_clause,l_order_by)
    ELSE
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
        
END FUNCTION

#------------------------------------------------------#
FUNCTION pol1317_cria_cursor(l_where_clause,l_order_by)#
#------------------------------------------------------#
 
   DEFINE l_where_clause CHAR(800)
   DEFINE l_order_by     CHAR(200)

   DEFINE l_sql_stmt     CHAR(2000),
          l_ind          INTEGER,
          l_ano          CHAR(04),
          l_mes          CHAR(02)

   IF  l_order_by IS NULL THEN
       LET l_order_by = "empresa_orig, ano, mes"
   END IF

   INITIALIZE ma_rateio TO NULL
   LET l_ind = 1
   
   LET l_sql_stmt = "SELECT num_rateio, empresa_orig, ano, mes ",
                     " FROM rateio_mensal_orig912 ",
                    " WHERE ", l_where_clause CLIPPED,
                    "   AND empresa_orig = '",m_cod_empresa,"' ",
                    " ORDER BY ", l_order_by

   PREPARE var_pesquisa FROM l_sql_stmt
    
   IF  Status <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","var_pesquisa")
       RETURN 
   END IF

   DECLARE cq_cons SCROLL CURSOR FOR var_pesquisa

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE CURSOR","cq_cons")
       RETURN 
   END IF

   FOREACH cq_cons INTO 
      ma_rateio[l_ind].num_rateio, 
      ma_rateio[l_ind].empresa_orig, 
      l_ano, l_mes
      
      IF  STATUS <> 0 THEN
          CALL log003_err_sql("FOREACH","cq_cons")
          RETURN 
      END IF

      LET ma_rateio[l_ind].periodo = l_mes,'/',l_ano
      
      LET l_ind = l_ind + 1

      IF l_ind > 300 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF l_ind = 1 THEN
      LET m_msg = 'Não há dados, para os argumentos informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN
   END IF
   
   LET m_index = l_ind - 1
   
   CALL pol1317_tela_zoom()
   
END FUNCTION

#---------------------------#
FUNCTION pol1317_tela_zoom()#
#---------------------------#

   DEFINE l_menubar     VARCHAR(10),
          l_panel       VARCHAR(10),
          l_select      VARCHAR(10),
          l_cancel      VARCHAR(10)

    LET m_form_popup = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_popup,"SIZE",800,450)
    CALL _ADVPL_set_property(m_form_popup,"TITLE","SELECÇÃO DE RATEIO")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_popup)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1317_exibe_rateio(l_panel)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_popup)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) #vermelho,verde,azul
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   #FIND_EX / QUIT_EX / CONFIRM_EX / UPDATE_EX / RUN_EX / NEW_EX
   #CANCEL_EX / DELETE_EX / LANCAMENTOS_EX / ESTORNO_EX / SAVEPROFILE
   LET l_select = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_select,"IMAGE","CONFIRM_EX")
   CALL _ADVPL_set_property(l_select,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_select,"EVENT","pol1317_select")     

   LET l_cancel = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancel,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancel,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancel,"EVENT","pol1317_cancel")     

   CALL _ADVPL_set_property(m_form_popup,"ACTIVATE",TRUE)


END FUNCTION

#-----------------------------------------#
FUNCTION pol1317_exibe_rateio(l_container)#
#-----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",200,190,230)
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 

    LET m_brow_popup = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brow_popup,"ALIGN","CENTER")    
    CALL _ADVPL_set_property(m_brow_popup,"BEFORE_ROW_EVENT","pol1317_row_popup")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_popup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Rateio")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_rateio")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_popup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Empresa orig")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","empresa_orig")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_popup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Período")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","periodo")
   
    CALL _ADVPL_set_property(m_brow_popup,"SET_ROWS",ma_rateio,m_index)
    CALL _ADVPL_set_property(m_brow_popup,"CAN_ADD_ROW",FALSE)
    

END FUNCTION

#------------------------#
FUNCTION pol1317_select()#
#------------------------#

   CALL _ADVPL_set_property(m_form_popup,"ACTIVATE",FALSE)
   LET mr_parametro.num_rateio = m_num_rateio

   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1317_cancel()#
#------------------------#

   CALL _ADVPL_set_property(m_form_popup,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1317_row_popup()#
#---------------------------#

   DEFINE l_lin_atu       SMALLINT
      
   LET l_lin_atu = _ADVPL_get_property(m_brow_popup,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN
      LET m_num_rateio = ma_rateio[l_lin_atu].num_rateio
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1317_valida_timesheet()#
#----------------------------------#

   IF mr_parametro.num_rateio IS NOT NULL THEN
      LET m_num_rateio = mr_parametro.num_rateio
      IF NOT pol1317_le_rateio() THEN
         RETURN FALSE
      END IF
   END IF
   
   LET m_exibiu_ts = TRUE
   
   RETURN TRUE

END FUNCTION      

#---------------------------#
FUNCTION pol1317_le_rateio()#
#---------------------------#
   DEFINE l_mes        CHAR(02),
          l_ano        CHAR(04)
          
   SELECT empresa_orig,
          ano,         
          mes         
     INTO mr_parametro.cod_emp_orig,
          l_ano,
          l_mes          
    FROM rateio_mensal_orig912
   WHERE num_rateio = m_num_rateio
     AND empresa_orig = m_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','rateio_mensal_orig912')
      RETURN FALSE
   END IF
   
   LET mr_parametro.periodo = l_mes,'/',l_ano
   LET mr_parametro.nom_emp_orig = pol1317_le_empresa(mr_parametro.cod_emp_orig)
   
   IF NOT pol1317_le_itens() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1317_le_empresa(l_codigo)#
#------------------------------------#

   DEFINE l_codigo       LIKE empresa.cod_empresa,
          l_den_empresa  LIKE empresa.den_empresa
   
   LET l_den_empresa = ''
   
   SELECT den_empresa
     INTO l_den_empresa
     FROM empresa
    WHERE cod_empresa = l_codigo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa')
   END IF
   
   RETURN l_den_empresa

END FUNCTION

#-----------------------------#
FUNCTION pol1317_le_aen(l_cod)#
#-----------------------------#
   
   DEFINE l_cod       CHAR(08),
          l_descricao CHAR(30),
          l_lin_prod  DECIMAL(2,0),
          l_lin_recei DECIMAL(2,0),
          l_seg_merc  DECIMAL(2,0),
          l_cla_uso   DECIMAL(2,0)

   LET l_lin_prod = l_cod[1,2]
   LET l_lin_recei = l_cod[3,4]
   LET l_seg_merc = l_cod[5,6]
   LET l_cla_uso = l_cod[7,8]
   
   SELECT den_estr_linprod
     INTO l_descricao
     FROM linha_prod
    WHERE cod_lin_prod =  l_lin_prod
      AND cod_lin_recei = l_lin_recei
      AND cod_seg_merc = l_seg_merc
      AND cod_cla_uso = l_cla_uso
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','linha_prod')   
   END IF
   
   RETURN l_descricao

END FUNCTION

#--------------------------#  
FUNCTION pol1317_le_itens()#
#--------------------------#
   
   DEFINE l_ind       SMALLINT
   
   INITIALIZE ma_itens TO NULL
   LET l_ind = 1
      
   DECLARE cq_itens CURSOR FOR
    SELECT empresa_dest, 
           cod_cent_cust,
           cod_aen,      
           pct_rateio   
      FROM rateio_mensal_dest912
     WHERE num_rateio = m_num_rateio
      ORDER BY empresa_dest, cod_cent_cust

   FOREACH cq_itens INTO 
      ma_itens[l_ind].cod_emp_dest,
      ma_itens[l_ind].cod_cent_cust,
      ma_itens[l_ind].cod_aen,
      ma_itens[l_ind].pct_rateio
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_itens')
         RETURN FALSE
      END IF
      
      LET ma_itens[l_ind].den_emp_dest = pol1317_le_empresa(ma_itens[l_ind].cod_emp_dest)
      
      LET ma_itens[l_ind].nom_cent_cust = 
             pol1317_le_cent_cust(ma_itens[l_ind].cod_emp_dest,
           ma_itens[l_ind].cod_cent_cust)
                 
      IF ma_itens[l_ind].cod_aen IS NOT NULL THEN
         LET ma_itens[l_ind].den_aen = pol1317_le_aen(ma_itens[l_ind].cod_aen)
      END IF
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 300 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   FREE cq_itens
   
   LET l_ind = l_ind - 1

   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", l_ind)
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1317_limpa_campos()
#-----------------------------#

   INITIALIZE mr_parametro.* TO NULL
   INITIALIZE ma_itens TO NULL
    
END FUNCTION

#--------------------------#
FUNCTION pol1317_informar()#
#--------------------------#

   CALL pol1317_ativa_desativa(TRUE)
   CALL pol1317_limpa_campos()
   
   LET m_ies_info = FALSE
   LET m_exibiu_ts = FALSE
   CALL _ADVPL_set_property(m_datini,"GET_FOCUS")
   
   RETURN TRUE 

END FUNCTION

#---------------------------#
FUNCTION pol1317_confirmar()#
#---------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_parametro.dat_ini IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a data inicial!")
      CALL _ADVPL_set_property(m_datini,"GET_FOCUS")
      RETURN FALSE      
   END IF

   IF mr_parametro.dat_fim IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a data final!")
      CALL _ADVPL_set_property(m_datfim,"GET_FOCUS")
      RETURN FALSE      
   END IF
   
   IF mr_parametro.dat_fim < mr_parametro.dat_ini THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Período inválido!")
      CALL _ADVPL_set_property(m_datini,"GET_FOCUS")
      RETURN FALSE      
   END IF

   IF mr_parametro.num_rateio IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a grade timesheet!")
      CALL _ADVPL_set_property(m_time_sheet,"GET_FOCUS")
      RETURN FALSE      
   END IF
   
   IF NOT m_exibiu_ts THEN
      CALL pol1317_le_rateio() RETURNING p_status
   END IF
   
   LET m_ies_info = TRUE
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1317_cancelar()#
#--------------------------#

    CALL pol1317_limpa_campos()
    CALL pol1317_ativa_desativa(FALSE)
    RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1317_processar()#
#---------------------------#
   
   DEFINE l_previsao   CHAR(10)
   
   IF NOT m_ies_info THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe os parâmetros previamente")
      RETURN FALSE
   END IF

   LET m_dat_ini = EXTEND(mr_parametro.dat_ini, YEAR TO DAY)
   LET m_dat_fim = EXTEND(mr_parametro.dat_fim, YEAR TO DAY)

   SELECT COUNT(a.cod_empresa)
     INTO m_qtd_ad
     FROM ad_mestre a, rateio_tip_desp_orig912 b
    WHERE a.cod_empresa = m_cod_empresa
      AND TO_CHAR(a.dat_rec_nf,'YYYY-MM-DD')  >= m_dat_ini
      AND TO_CHAR(a.dat_rec_nf,'YYYY-MM-DD')  <= m_dat_fim
      AND a.cod_empresa = b.empresa_orig
      AND b.situacao = 'A'
      AND ((a.cod_tip_despesa = b.cod_tip_desp AND a.cod_fornecedor = b.cod_fornecedor) OR
           (a.cod_tip_despesa = b.cod_tip_desp AND (b.cod_fornecedor IS NULL OR b.cod_fornecedor = '')))
      AND a.num_ad NOT IN
           (SELECT p.num_ad FROM previsao_912 p 
             WHERE p.cod_emp_orig = a.cod_empresa)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ad_mestre')
      LET p_status = FALSE
      RETURN
   END IF      
   
   IF m_qtd_ad = 0 THEN
      LET m_msg = 'Não há dados para \n o período informado.'
      CALL log0030_mensagem(m_msg,'info')
      LET p_status = FALSE
      RETURN
   END IF           

   IF NOT LOG_question("Confirma a geração da previsão de despesas?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF
   
   LET p_status = TRUE
   
   BEGIN WORK
   
   CALL LOG_progresspopup_start("Procesando...","pol1317_executa","PROCESS")
   
   LET m_ies_info = FALSE

   IF NOT p_status THEN 
      ROLLBACK WORK
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
                "Operação cancelada")
   ELSE
      COMMIT WORK
      LET l_previsao = m_num_previsao
      LET m_msg = ' Previsão ',l_previsao CLIPPED, ' gerada com ',m_count USING '<<<<<<'
      LET m_msg = m_msg CLIPPED, ' titulos'
      LET m_msg = m_msg CLIPPED,'\n Deseja imprimir agora?'
      IF LOG_question(m_msg) THEN
         CALL pol1317_imprimir()
      END IF
   END IF
      
   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol1317_executa()#
#-------------------------#
      
   CALL LOG_progresspopup_set_total("PROCESS",m_qtd_ad)
   
   SELECT MAX(num_previsao)
     INTO m_num_previsao
     FROM previsao_periodo_912
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','previsao_periodo_912')
      LET p_status = FALSE
      RETURN
   END IF      
   
   IF m_num_previsao IS NULL THEN
      LET m_num_previsao = 0
   END IF
   
   LET m_num_previsao = m_num_previsao + 1
   LET m_dat_atu = TODAY     

   INSERT INTO previsao_periodo_912
    VALUES(m_num_previsao,
           m_dat_atu,
           m_cod_empresa,
           mr_parametro.dat_ini,
           mr_parametro.dat_fim)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','previsao_periodo_912')
      LET p_status = FALSE
      RETURN
   END IF      
   
   LET p_status = pol1317_le_ads()
   
   IF NOT p_status THEN
      DELETE FROM previsao_912 WHERE num_previsao = m_num_previsao
      DELETE FROM previsao_rateio_912 WHERE num_previsao = m_num_previsao
      DELETE FROM previsao_periodo_912 WHERE num_previsao = m_num_previsao
   END IF
   
END FUNCTION

#------------------------#
FUNCTION pol1317_le_ads()#
#------------------------#
   
   LET m_count = 0

   DECLARE cq_ads CURSOR FOR
    SELECT DISTINCT a.num_ad
     FROM ad_mestre a, rateio_tip_desp_orig912 b
    WHERE a.cod_empresa = m_cod_empresa
      AND TO_CHAR(a.dat_rec_nf,'YYYY-MM-DD')  >= m_dat_ini
      AND TO_CHAR(a.dat_rec_nf,'YYYY-MM-DD')  <= m_dat_fim
      AND a.cod_empresa = b.empresa_orig
      AND b.situacao = 'A'
      AND ((a.cod_tip_despesa = b.cod_tip_desp AND a.cod_fornecedor = b.cod_fornecedor) OR
           (a.cod_tip_despesa = b.cod_tip_desp AND (b.cod_fornecedor IS NULL OR b.cod_fornecedor = '')))
      AND a.num_ad NOT IN
           (SELECT p.num_ad FROM previsao_912 p 
             WHERE p.cod_emp_orig = a.cod_empresa)
     ORDER BY a.num_ad
              
   FOREACH cq_ads INTO m_num_ad         

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_ads')
         RETURN FALSE
      END IF
      
      LET p_status = LOG_progresspopup_increment("PROCESS")
      
      LET m_count = m_count + 1
      
      IF NOT pol1317_gera_previsao() THEN
         RETURN FALSE
      END IF
      
   END FOREACH
   
   IF m_count = 0 THEN
      LET m_msg = 'Não há titulos para \n o período informado.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#-------------------------------#   
FUNCTION pol1317_gera_previsao()#
#-------------------------------#

   DEFINE l_count    INTEGER   
                      
   DECLARE cq_ger_prev CURSOR FOR
    SELECT num_ad, 
           cod_tip_despesa, 
           num_nf, 
           dat_rec_nf, 
           cnd_pgto, 
           dat_venc, 
           cod_fornecedor, 
           val_tot_nf, 
           cod_moeda, 
           cod_tip_ad,
           ies_sup_cap
     FROM ad_mestre 
    WHERE cod_empresa = m_cod_empresa
      AND num_ad = m_num_ad

   FOREACH cq_ger_prev INTO
      mr_ad.num_ad,          
      mr_ad.cod_tip_despesa, 
      mr_ad.num_nf,          
      mr_ad.dat_rec_nf,     
      mr_ad.cnd_pgto,        
      mr_ad.dat_venc,        
      mr_ad.cod_fornecedor,  
      mr_ad.val_tot_nf,      
      mr_ad.cod_moeda,       
      mr_ad.cod_tip_ad,
      mr_ad.ies_sup_cap

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_ger_prev')
         RETURN FALSE
      END IF
      
      IF mr_ad.ies_sup_cap = 'C' THEN 
         LET m_origem = 'CAP'
      ELSE
         IF mr_ad.ies_sup_cap = 'S' THEN 
            LET m_origem = 'SUP'
         ELSE
            IF mr_ad.ies_sup_cap = 'F' THEN 
               LET m_origem = 'RH'
            ELSE
               LET m_origem = 'OUT'
            END IF
         END IF
      END IF
      
      SELECT COUNT(centro_custo)
        INTO l_count
        FROM cap_ad_centro_custo
       WHERE empresa = m_cod_empresa
         AND num_ad = mr_ad.num_ad

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cap_ad_centro_custo')
         RETURN FALSE
      END IF
      
      IF l_count = 1 THEN
         SELECT centro_custo
           INTO m_cent_custo
           FROM cap_ad_centro_custo
          WHERE empresa = m_cod_empresa
            AND num_ad = mr_ad.num_ad
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','cap_ad_centro_custo')
            RETURN FALSE
         END IF
      ELSE
         LET m_cent_custo = 99999
      END IF
            
      IF NOT pol1317_ins_previsao() THEN
         RETURN FALSE
      END IF      
      
      IF NOT pol1317_rateia_valor() THEN
         RETURN FALSE
      END IF

      #IF NOT pol1317_arredonda() THEN
      #   RETURN FALSE
      #END IF
            
   END FOREACH      
   
   RETURN TRUE
      
END FUNCTION

#------------------------------#
FUNCTION pol1317_ins_previsao()#
#------------------------------#

   INSERT INTO previsao_912 (
      num_previsao,   
      cod_emp_orig,   
      num_ad,         
      cod_cent_cust,  
      cod_fornecedor, 
      cod_tip_despesa,
      num_nf,    
      dat_rec_nf,     
      cnd_pgto,       
      val_tot_nf,  
      dat_venc,   
      cod_moeda,      
      cod_tip_ad,     
      ies_sup_cap,    
      origem,         
      rateado)        
   VALUES(
      m_num_previsao,                
      m_cod_empresa,
      mr_ad.num_ad, 
      m_cent_custo,         
      mr_ad.cod_fornecedor,  
      mr_ad.cod_tip_despesa, 
      mr_ad.num_nf,     
      mr_ad.dat_rec_nf,     
      mr_ad.cnd_pgto,        
      mr_ad.val_tot_nf,   
      mr_ad.dat_venc,   
      mr_ad.cod_moeda,       
      mr_ad.cod_tip_ad,
      mr_ad.ies_sup_cap,
      m_origem,
      '')
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','previsao_912')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION
      
#------------------------------#
FUNCTION pol1317_rateia_valor()#
#------------------------------#
   
   LET m_num_seq = 0
   
   SELECT num_rateio,
          timesheet
     INTO m_num_rateio,
          m_timesheet
     FROM rateio_tip_desp_orig912
    WHERE empresa_orig = m_cod_empresa
      AND cod_tip_desp = mr_ad.cod_tip_despesa
      AND cod_fornecedor = mr_ad.cod_fornecedor
      AND situacao = 'A'

   IF STATUS = 100 THEN
      SELECT num_rateio,
             timesheet
        INTO m_num_rateio,
             m_timesheet
        FROM rateio_tip_desp_orig912
       WHERE empresa_orig = m_cod_empresa
         AND cod_tip_desp = mr_ad.cod_tip_despesa
         AND cod_fornecedor IS NULL
         AND situacao = 'A'
      IF STATUS = 100 THEN
         RETURN TRUE   
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','rateio_tip_desp_orig912')
            RETURN FALSE
         END IF
      END IF
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','rateio_tip_desp_orig912')
         RETURN FALSE
      END IF
   END IF

   IF m_timesheet = 'S' THEN

      DECLARE cq_rateio CURSOR FOR
       SELECT empresa_dest,
              cod_cent_cust,
              cod_aen,
              pct_rateio
         FROM rateio_mensal_dest912           
        WHERE num_rateio = mr_parametro.num_rateio

   ELSE
   
      DECLARE cq_rateio CURSOR FOR
       SELECT empresa_dest,
              cod_cent_cust,
              cod_aen,
              pct_rateio
         FROM rateio_tip_desp_dest912           
        WHERE num_rateio = m_num_rateio
   
   END IF
   
   FOREACH cq_rateio INTO
      mr_rateio.empresa_dest, 
      mr_rateio.cod_cent_cust,
      mr_rateio.cod_aen,      
      mr_rateio.pct_rateio    
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_rateio')
         RETURN FALSE
      END IF
      
      LET mr_rateio.num_previsao = m_num_previsao
      LET mr_rateio.num_ad = mr_ad.num_ad
      
      IF mr_ad.ies_sup_cap = 'C' THEN 
         LET mr_rateio.num_docum = mr_ad.num_ad
      ELSE
         LET mr_rateio.num_docum = mr_ad.num_nf
      END IF 
      
      LET mr_rateio.val_rateio = mr_ad.val_tot_nf * mr_rateio.pct_rateio / 100
      
      IF NOT pol1317_ins_rateio() THEN 
         RETURN FALSE
      END IF      
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1317_ins_rateio()#
#----------------------------#
   
   LET m_num_seq = m_num_seq + 1
   LET mr_rateio.num_seq = m_num_seq
   LET mr_rateio.num_titulo = ''
   
   INSERT INTO previsao_rateio_912 
     VALUES(mr_rateio.*)
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','previsao_rateio_912')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#      
FUNCTION pol1317_arredonda()#
#---------------------------#

   DEFINE l_val_rateio DECIMAL(12,2),
          l_val_dif    DECIMAL(12,2),
          l_pct_rateio DECIMAL(5,2)

   SELECT SUM(pct_rateio), SUM(val_rateio)
     INTO l_pct_rateio, l_val_rateio
     FROM previsao_rateio_912
    WHERE num_previsao = m_num_previsao
      AND num_ad = mr_ad.num_ad
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','previsao_rateio_912')
      RETURN FALSE
   END IF
      
   LET l_val_dif = l_val_rateio - mr_ad.val_tot_nf
     
   IF l_val_dif <> 0 THEN
      UPDATE previsao_rateio_912
         SET val_rateio = val_rateio + l_val_dif
       WHERE num_previsao = m_num_previsao
         AND num_ad = mr_ad.num_ad
         AND num_seq = m_num_seq

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','previsao_rateio_912')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#            
FUNCTION pol1317_sel_previsao()#
#------------------------------#


    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)
    
    IF m_filtro IS NULL THEN
       LET m_filtro = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_filtro,"CONSTRUCT_NAME","SELEÇÃO DE PREVISÃO")
       CALL _ADVPL_set_property(m_filtro,"ADD_VIRTUAL_TABLE","previsao_periodo_912","Previsao")
       CALL _ADVPL_set_property(m_filtro,"ADD_VIRTUAL_COLUMN","previsao_periodo_912","num_previsao","Previsão",1 {INT},10,0)        	       
       CALL _ADVPL_set_property(m_filtro,"ADD_VIRTUAL_COLUMN","previsao_periodo_912","dat_ini","Dat inicial",1 {DATE},10,0)        	       
       CALL _ADVPL_set_property(m_filtro,"ADD_VIRTUAL_COLUMN","previsao_periodo_912","dat_fim","Dat Final",1 {DATE},10,0)        	       
    END IF

    LET l_status = _ADVPL_get_property(m_filtro,"INIT_CONSTRUCT")

    IF  l_status THEN
        LET l_where_clause = _ADVPL_get_property(m_filtro,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_filtro,"ORDER_BY")
        CALL pol1317_le_previsao(l_where_clause,l_order_by)
    END IF
        
END FUNCTION

#------------------------------------------------------#
FUNCTION pol1317_le_previsao(l_where_clause,l_order_by)#
#------------------------------------------------------#
 
   DEFINE l_where_clause CHAR(800),
          l_order_by     CHAR(200),
          l_sql_stmt     CHAR(2000),
          l_ind          INTEGER

    IF  l_order_by IS NULL THEN
        LET l_order_by = " num_previsao "
    END IF

   LET l_sql_stmt = "SELECT num_previsao, dat_ini, dat_fim ",
                     " FROM previsao_periodo_912 ",
                    " WHERE ", l_where_clause CLIPPED,
                    " AND cod_emp_orig = '",m_cod_empresa,"' ",
                    " ORDER BY ", l_order_by

   PREPARE var_prepare FROM l_sql_stmt
    
   IF  STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE","var_prepare")
       RETURN 
   END IF

   DECLARE cq_pesq CURSOR FOR var_prepare

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE","cq_pesq")
       RETURN 
   END IF
   
   LET l_ind = 1
   INITIALIZE ma_previsao TO NULL
   
   FOREACH cq_pesq INTO 
      ma_previsao[l_ind].num_previsao,
      ma_previsao[l_ind].dat_ini,
      ma_previsao[l_ind].dat_fim

      IF  STATUS <> 0 THEN
          CALL log003_err_sql("FOREACH","cq_pesq")
          RETURN 
      END IF
      
      LET l_ind = l_ind + 1

      IF l_ind > 2000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF l_ind = 1 THEN
      LET m_msg = 'Não a dados, para os argumentos informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN
   END IF
   
   LET m_index = l_ind - 1
   
   CALL pol1317_tela_prov()
   
END FUNCTION

#---------------------------#
FUNCTION pol1317_tela_prov()#
#---------------------------#

   DEFINE l_menubar     VARCHAR(10),
          l_panel       VARCHAR(10),
          l_select      VARCHAR(10),
          l_cancel      VARCHAR(10)

    LET m_form_imp = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_imp,"SIZE",800,450)
    CALL _ADVPL_set_property(m_form_imp,"TITLE","SELECÇÃO DE PREVISÕES")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_imp)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1317_exibe_previsoes(l_panel)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_imp)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) #vermelho,verde,azul
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   #FIND_EX / QUIT_EX / CONFIRM_EX / UPDATE_EX / RUN_EX / NEW_EX
   #CANCEL_EX / DELETE_EX / LANCAMENTOS_EX / ESTORNO_EX / SAVEPROFILE
   LET l_select = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_select,"IMAGE","CONFIRM_EX")
   CALL _ADVPL_set_property(l_select,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_select,"EVENT","pol1317_conf_prev")     

   LET l_cancel = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancel,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancel,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancel,"EVENT","pol1317_canc_prev")     

   CALL _ADVPL_set_property(m_form_imp,"ACTIVATE",TRUE)


END FUNCTION

#--------------------------------------------#
FUNCTION pol1317_exibe_previsoes(l_container)#
#--------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",200,190,230)
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 

    LET m_brow_imp = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brow_imp,"ALIGN","CENTER")    
    CALL _ADVPL_set_property(m_brow_imp,"BEFORE_ROW_EVENT","pol1317_row_prev")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_imp)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Previsão")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_previsao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_imp)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dat inicial")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_ini")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_imp)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dat final")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_fim")
    
    CALL _ADVPL_set_property(m_brow_imp,"SET_ROWS",ma_previsao,m_index)

END FUNCTION

#--------------------------#
FUNCTION pol1317_row_prev()#
#--------------------------#

   DEFINE l_lin_atu       SMALLINT
      
   LET l_lin_atu = _ADVPL_get_property(m_brow_imp,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN
      LET m_num_previsao = ma_previsao[l_lin_atu].num_previsao
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1317_conf_prev()#
#---------------------------#

   CALL _ADVPL_set_property(m_form_imp,"ACTIVATE",FALSE)
   CALL pol1317_imprimir()

   RETURN p_status

END FUNCTION

#---------------------------#
FUNCTION pol1317_canc_prev()#
#---------------------------#

   CALL _ADVPL_set_property(m_form_imp,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION
            
#--------------------------#            
FUNCTION pol1317_imprimir()#
#--------------------------#

  CALL LOG_progresspopup_start("Imprimindo...","pol1317_print","PROCESS")

  RETURN p_status

END FUNCTION

#-----------------------#
FUNCTION pol1317_print()#
#-----------------------#

 LET p_status = StartReport(
   "pol1317_gera_relat","pol1317","PREVISAO DE RATEIO DE DESPESA",120,TRUE,TRUE)

END FUNCTION

#------------------------------------#
FUNCTION pol1317_gera_relat(l_report)#
#------------------------------------#

   DEFINE l_report CHAR(300),
          l_status SMALLINT

    #*** ANTES DO START REPORT DO 4GL. ***#
    
   LET m_page_length = ReportPageLength("pol1317")
       
   START REPORT pol1317_relat TO l_report

   CALL pol1317_le_den_empresa(m_cod_empresa) RETURNING p_status

   CALL pol1317_le_periodo() RETURNING p_status

   DECLARE cq_relat CURSOR FOR 
    SELECT b.cod_cent_cust,  
           b.empresa_dest,         
           a.cod_fornecedor,
           b.num_docum,
           a.origem,
           a.cod_tip_despesa,
           a.dat_rec_nf,
           b.pct_rateio,
           b.val_rateio
      FROM previsao_912 a,
           previsao_rateio_912 b
     WHERE a.num_previsao = m_num_previsao
       AND a.cod_emp_orig = m_cod_empresa
       AND a.num_previsao = b.num_previsao
       AND a.num_ad = b.num_ad       
     ORDER BY b.cod_cent_cust, b.empresa_dest,  b.num_docum
   
   FOREACH cq_relat INTO 
           mr_relat.cod_cent_cust,  
           mr_relat.empresa_dest,   
           mr_relat.cod_fornecedor, 
           mr_relat.num_docum,      
           mr_relat.origem,         
           mr_relat.cod_tip_despesa,
           mr_relat.dat_rec_nf,    
           mr_relat.pct_rateio,     
           mr_relat.val_rateio      

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_relat')
         EXIT FOREACH
      END IF
      
      LET l_status = LOG_progresspopup_increment("PROCESS") 
      LET mr_relat.nom_despesa = pol1317_le_despesa()
      LET mr_relat.nom_fornec = pol1317_le_fornec()

      OUTPUT TO REPORT pol1317_relat(mr_relat.cod_cent_cust)

   END FOREACH      
      
   FINISH REPORT pol1317_relat

   CALL FinishReport("pol1317")
    
END FUNCTION

#--------------------------------------#
 FUNCTION pol1317_le_den_empresa(l_cod)#
#--------------------------------------#
  
   DEFINE l_cod     LIKE empresa.cod_empresa
   
   SELECT den_empresa
     INTO m_den_empresa
     FROM empresa
    WHERE cod_empresa = l_cod
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1317_le_periodo()#
#-----------------------------#

   SELECT dat_ini,
          dat_fim
     INTO mr_parametro.dat_ini,
          mr_parametro.dat_fim
     FROM previsao_periodo_912
    WHERE cod_emp_orig = m_cod_empresa
      AND num_previsao = m_num_previsao
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','previsao_periodo_912')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1317_le_despesa()#
#----------------------------#
   
   DEFINE l_nom_despesa LIKE tipo_despesa.nom_tip_despesa
   
   LET l_nom_despesa = ''
   
   SELECT nom_tip_despesa
     INTO l_nom_despesa
     FROM tipo_despesa
    WHERE cod_empresa = m_cod_empresa
      AND cod_tip_despesa = mr_relat.cod_tip_despesa

   RETURN l_nom_despesa

END FUNCTION

#---------------------------#
FUNCTION pol1317_le_fornec()#
#---------------------------#
   
   DEFINE l_nom_fornec LIKE fornecedor.raz_social
   
   LET l_nom_fornec = ''
   
   SELECT raz_social
     INTO l_nom_fornec
     FROM fornecedor
    WHERE cod_fornecedor = mr_relat.cod_fornecedor

   RETURN l_nom_fornec

END FUNCTION

#---------------------------#
FUNCTION pol1317_le_cad_cc()#
#---------------------------#
   
   DEFINE l_nom_cent  LIKE cad_cc.nom_cent_cust
   
   IF mr_relat.cod_cent_cust = 99999 THEN
      LET l_nom_cent = 'OUTROS'
   ELSE   
      LET l_nom_cent = pol1317_le_cent_cust(
         mr_relat.empresa_dest, mr_relat.cod_cent_cust)          
      LET l_nom_cent = mr_relat.cod_cent_cust CLIPPED, ' - ', l_nom_cent
   END IF
   
   RETURN l_nom_cent

END FUNCTION

#-------------------------------------------#
FUNCTION pol1317_le_cent_cust(l_emp, l_cust)#
#-------------------------------------------#

   DEFINE l_emp       LIKE empresa.cod_empresa, 
          l_emp_plano LIKE empresa.cod_empresa, 
          l_cust      LIKE cad_cc.cod_cent_cust,
          l_nom_cent  LIKE cad_cc.nom_cent_cust
   
   SELECT cod_empresa_plano
     INTO l_emp_plano
     FROM par_con
    WHERE cod_empresa = l_emp

   IF STATUS <> 0 THEN
      LET l_emp_plano = l_emp
   END IF
   
   IF l_emp_plano IS NULL THEN
      LET l_emp_plano = l_emp
   END IF
   
   SELECT nom_cent_cust
     INTO l_nom_cent
     FROM cad_cc
    WHERE cod_empresa = l_emp_plano
      AND cod_cent_cust = l_cust

   IF STATUS <> 0 THEN
      LET l_nom_cent = NULL
   END IF
   
   RETURN l_nom_cent

END FUNCTION

#--------------------------------#
REPORT pol1317_relat(l_cent_cust)#
#--------------------------------#

   DEFINE l_cod_empresa LIKE empresa.cod_empresa,
          l_cent_cust   LIKE cad_cc.cod_cent_cust
   
    OUTPUT
        TOP    MARGIN 0
        LEFT   MARGIN 0
        RIGHT  MARGIN 0
        BOTTOM MARGIN 0
        PAGE   LENGTH m_page_length
   
    ORDER EXTERNAL BY l_cent_cust

    FORMAT

    PAGE HEADER
        CALL ReportPageHeader("pol1317")
       
        LET l_cod_empresa = mr_relat.empresa_dest
        #CALL pol1317_le_den_empresa(l_cod_empresa) RETURNING p_status

        PRINT COLUMN 001,'Numero da previsao: ', func002_strzero(m_num_previsao,2), 
              COLUMN 050,'Periodo: ',mr_parametro.dat_ini USING 'dd/mm/yyyy',' - ',mr_parametro.dat_fim  USING 'dd/mm/yyyy'            
        PRINT COLUMN 001,'Empresa Origem: ', m_cod_empresa, ' - ', m_den_empresa

      LET mr_relat.nom_cent_cust = pol1317_le_cad_cc()

      PRINT
      PRINT COLUMN 001,'------------------------------------------------------------------------------------------------------------------------'
      PRINT COLUMN 001,'Centro de custo: ',mr_relat.nom_cent_cust
      PRINT COLUMN 001,'------------------------------------------------------------------------------------------------------------------------'
      
      PRINT COLUMN 001,'EMP FORNECEDOR                           TIPO DE DESPESA                DOCUMENTO ORIG DT EMISSAO % RAT   VALOR RATEIO'
      PRINT COLUMN 001,'--- ------------------------------------ ------------------------------ --------- ---- ---------- ----- ----------------'

   BEFORE GROUP OF l_cent_cust

      SKIP TO TOP OF PAGE
      
    ON EVERY ROW
        PRINT COLUMN 002,mr_relat.empresa_dest,
              COLUMN 005,mr_relat.nom_fornec,
              COLUMN 042,mr_relat.nom_despesa,
              COLUMN 073,mr_relat.num_docum USING '########&',
              COLUMN 084,mr_relat.origem,
              COLUMN 088,mr_relat.dat_rec_nf USING 'dd/mm/yyyy',
              COLUMN 099,mr_relat.pct_rateio USING '#&.&&',
              COLUMN 105,mr_relat.val_rateio USING '#,###,###,##&.&&'
              
   AFTER GROUP OF l_cent_cust
      
      SKIP 2 LINES
      PRINT COLUMN 078, 'Total do centro de custo:',
            COLUMN 105, GROUP SUM(mr_relat.val_rateio) USING '#,###,##&.&&'

END REPORT
