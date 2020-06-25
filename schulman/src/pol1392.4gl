#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1392                                                 #
# OBJETIVO: CADASTROS PARA INREGRAÇÃO CONCUR X LOGIX                #
# AUTOR...: IVO                                                     #
# DATA....: 18/05/2020                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           m_panel           VARCHAR(10),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_cod_empresa_plano   LIKE empresa.cod_empresa

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_folder          VARCHAR(10),
       m_fold_func       VARCHAR(10),
       m_fold_cust       VARCHAR(10),
       m_fold_desp       VARCHAR(10),
       m_construct       VARCHAR(10)

DEFINE m_pan_func        VARCHAR(10),
       m_pan_cust        VARCHAR(10),
       m_pan_desp        VARCHAR(10)

DEFINE m_brz_func        VARCHAR(10),
       m_brz_cust        VARCHAR(10),
       m_brz_desp        VARCHAR(10)
       
DEFINE m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_opcao           CHAR(01),
       m_op_desp         CHAR(01),
       m_op_cust         CHAR(01),
       m_car_func        SMALLINT,
       m_car_cust        SMALLINT,
       m_car_desp        SMALLINT,
       m_qtd_item        INTEGER,
       m_ind             INTEGER,
       m_lin_atu         INTEGER
                     
DEFINE m_zoom_fornec     VARCHAR(10),
       m_lupa_func       VARCHAR(10),
       m_funcio          VARCHAR(10),
       m_fornec          VARCHAR(10),
       m_zoom_desp       VARCHAR(10),
       m_lupa_desp       VARCHAR(10),
       m_zoom_cust       VARCHAR(10),
       m_lupa_cust       VARCHAR(10),
       m_cc_concur       VARCHAR(10),
       m_cc_logix        VARCHAR(10),
       m_lin_prod        VARCHAR(10),
       m_lin_recei       VARCHAR(10),
       m_seg_merc        VARCHAR(10),
       m_cla_uso         VARCHAR(10),
       m_desp_concur     VARCHAR(10),
       m_desp_logix      VARCHAR(10),
       m_entrega         VARCHAR(10),
       m_nat_venda       VARCHAR(10),
       m_nat_remessa     VARCHAR(10)

DEFINE mr_func          RECORD
       funcio_id        LIKE item.cod_item,
       cod_fornecedor   LIKE item.cod_item,
       raz_social       LIKE item.den_item
END RECORD

DEFINE ma_func          ARRAY[200] OF RECORD
       funcio_id        LIKE item.cod_item,
       cod_fornecedor   LIKE item.cod_item,
       raz_social       LIKE item.den_item,
       filler           CHAR(01)
END RECORD
       
DEFINE m_raz_social       CHAR(76),
       m_den_cust       CHAR(30)

DEFINE mr_cust          RECORD
       cod_empresa       CHAR(02),     
       cod_cc_concor     INTEGER,      
       cod_cc_logix      INTEGER,      
       nom_cent_cust     CHAR(30),     
       cod_lin_prod      decimal(2,0), 
       cod_lin_recei     decimal(2,0), 
       cod_seg_merc      decimal(2,0), 
       cod_cla_uso       decimal(2,0), 
       nom_linha_prod    char(30)      
END RECORD

DEFINE ma_cust          ARRAY[200] OF RECORD
       cod_empresa       CHAR(02),     
       cod_cc_concor     INTEGER,      
       cod_cc_logix      INTEGER,      
       nom_cent_cust     CHAR(30),     
       cod_lin_prod      decimal(2,0), 
       cod_lin_recei     decimal(2,0), 
       cod_seg_merc      decimal(2,0), 
       cod_cla_uso       decimal(2,0), 
       nom_linha_prod    char(30),     
       filler           CHAR(01)
END RECORD

DEFINE mr_desp          RECORD
       cod_empresa      CHAR(02),
       tip_desp_concur  INTEGER,
       tip_desp_logix   INTEGER,
       den_despesa      CHAR(30)
END RECORD

DEFINE ma_desp          ARRAY[10] OF RECORD
       cod_empresa      CHAR(02),
       tip_desp_concur  INTEGER,
       tip_desp_logix   INTEGER,
       den_despesa      CHAR(30),
       filler           CHAR(01)
END RECORD
             
#-----------------#
FUNCTION pol1392()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1392-12.00.00  "
   CALL func002_versao_prg(p_versao)
   
   LET m_car_func = TRUE
   LET m_car_desp = TRUE
   LET m_car_cust = TRUE
   
   CALL pol1392_menu()

END FUNCTION
 
#----------------------#
FUNCTION pol1392_menu()#
#----------------------#

    DEFINE l_menubar       VARCHAR(10),
           l_fechar        VARCHAR(10),
           l_panel         VARCHAR(10),
           l_fpanel        VARCHAR(10),
           l_label         VARCHAR(10),
           l_titulo        CHAR(80)

    LET l_titulo = 'CADASTROS PARA INREGRAÇÃO SICAL X CONCUR - ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET m_folder = _ADVPL_create_component(NULL,"LFOLDER",m_dialog)
    CALL _ADVPL_set_property(m_folder,"ALIGN","CENTER")

    # FOLDER item 

    LET m_fold_func = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_func,"TITLE","Funcionário")
		CALL pol1392_item(m_fold_func)
    
    # FOLDER despesa 

    LET m_fold_desp = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_desp,"TITLE","Tip despesa")
    CALL pol1392_desp(m_fold_desp)


    # FOLDER cnd pgto 

    LET m_fold_cust = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_cust,"TITLE","Centro de custo")
    CALL pol1392_cust(m_fold_cust)

    CALL _ADVPL_set_property(m_folder,"FOLDER_SELECTED",1)
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION
   
#------------------------#
FUNCTION pol1392_fechar()#
#------------------------#

   RETURN TRUE
   
END FUNCTION

#-----------------------------------------#
FUNCTION pol1392_desativa_folder(l_folder)#
#-----------------------------------------#

   DEFINE l_folder             CHAR(01)
             
   CASE l_folder
        WHEN '1' 
           CALL _ADVPL_set_property(m_fold_desp,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_cust,"ENABLE",FALSE)        
        WHEN '2' 
           CALL _ADVPL_set_property(m_fold_func,"ENABLE",FALSE)   
           CALL _ADVPL_set_property(m_fold_cust,"ENABLE",FALSE)
        WHEN '3' 
           CALL _ADVPL_set_property(m_fold_func,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_desp,"ENABLE",FALSE)
   END CASE
   
END FUNCTION

#------------------------------#
FUNCTION pol1392_ativa_folder()#
#------------------------------#

   CALL _ADVPL_set_property(m_fold_func,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_desp,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_cust,"ENABLE",TRUE)

END FUNCTION

#---Rotinas de-para item ----#

#------------------------------#
FUNCTION pol1392_item(l_fpanel)#
#------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_inform    VARCHAR(10),
           l_update    VARCHAR(10),
           l_delete    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10),
           l_create    VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1392_func_find")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1392_func_insert")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1392_func_insert_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1392_func_insert_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1392_func_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1392_func_update_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1392_func_update_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1392_func_delete")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1392_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1392_func_campo(l_panel)
    CALL pol1392_func_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1392_func_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_func = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_func,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_func,"HEIGHT",40)
    #CALL _ADVPL_set_property(m_pan_func,"BACKGROUND_COLOR",225,232,232) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_func)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Funcionário ID:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_funcio = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_func)     
    CALL _ADVPL_set_property(m_funcio,"POSITION",100,10) 
    CALL _ADVPL_set_property(m_funcio,"LENGTH",15,0)    
    CALL _ADVPL_set_property(m_funcio,"PICTURE","@!") 
    CALL _ADVPL_set_property(m_funcio,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(m_funcio,"VARIABLE",mr_func,"funcio_id")
    CALL _ADVPL_set_property(m_funcio,"VALID","pol1392_func_valid_funcio")        
              
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_func)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",250,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Fornecedor:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_fornec = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_func)     
    CALL _ADVPL_set_property(m_fornec,"POSITION",320,10) 
    CALL _ADVPL_set_property(m_fornec,"LENGTH",15,0)    
    CALL _ADVPL_set_property(m_fornec,"PICTURE","@!") 
    CALL _ADVPL_set_property(m_fornec,"VARIABLE",mr_func,"cod_fornecedor")
    CALL _ADVPL_set_property(m_fornec,"VALID","pol1392_func_valid_fornec")    

    LET m_lupa_func = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_func)
    CALL _ADVPL_set_property(m_lupa_func,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_func,"POSITION",450,10)     
    CALL _ADVPL_set_property(m_lupa_func,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_func,"CLICK_EVENT","pol1392_zoom_fornec")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_func)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",480,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",35,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_func,"raz_social")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    CALL _ADVPL_set_property(m_pan_func,"ENABLE",FALSE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1392_func_grade(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_func = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_func,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_func,"BEFORE_ROW_EVENT","pol1392_func_before_row")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_func)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Funcionário")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","funcio_id")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_func)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Fornecedor")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_fornecedor")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_func)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",300)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","raz_social")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_func)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_func,"SET_ROWS",ma_func,1)
    CALL _ADVPL_set_property(m_brz_func,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_func,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_func,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#---------------------------------#
FUNCTION pol1392_func_before_row()#
#---------------------------------#
   
   DEFINE l_linha          INTEGER
   
   IF m_car_func THEN
      RETURN TRUE
   END IF
      
   LET l_linha = _ADVPL_get_property(m_brz_func,"ROW_SELECTED")
   
   IF l_linha = 0 OR l_linha IS NULL THEN
      RETURN TRUE
   END IF
   
   LET mr_func.funcio_id = ma_func[l_linha].funcio_id
   LET mr_func.cod_fornecedor = ma_func[l_linha].cod_fornecedor
   
   CALL pol1392_le_fornec(mr_func.cod_fornecedor) RETURNING p_status
   
   LET mr_func.raz_social = m_raz_social
   LET m_lin_atu = l_linha
   
   CALL pol1392_func_ativa(TRUE)
   CALL _ADVPL_set_property(m_fornec,"GET_FOCUS")
   CALL pol1392_func_ativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1392_func_ativa(l_status)#
#------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pan_func,"ENABLE",l_status)

   IF m_opcao = 'I' THEN
      CALL _ADVPL_set_property(m_funcio,"ENABLE",l_status)
   ELSE
      CALL _ADVPL_set_property(m_funcio,"ENABLE",FALSE)
   END IF
   
   CALL _ADVPL_set_property(m_fornec,"ENABLE",l_status)
      
END FUNCTION

#---------------------------#
FUNCTION pol1392_func_find()#
#---------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200),
           m_construct    VARCHAR(10)            
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1392_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","func_fornec_concur","funcionario")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","func_fornec_concur","funcio_id","Funcionário",1 {INT},15,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","func_fornec_concur","cod_fornecedor","Fornecedor",1 {CHAR},15,0,"zoom_fornecedor")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1392_func_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#----------------------------------------------------#
FUNCTION pol1392_func_create_cursor(l_where, l_order)#
#----------------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)
    DEFINE l_ind        INTEGER

    IF l_order IS NULL THEN
       LET l_order = " funcio_id "
    END IF
    
    LET l_sql_stmt = 
        "SELECT funcio_id, cod_fornecedor ",
        " FROM func_fornec_concur ",
        " WHERE ",l_where CLIPPED,
        " AND cod_empresa = '",p_cod_empresa,"' ",
        " ORDER BY ",l_order
   
   CALL pol1392_func_exibe(l_sql_stmt)
   
END FUNCTION

#--------------------------------------#
FUNCTION pol1392_func_exibe(l_sql_stmt)#
#--------------------------------------#
   
   DEFINE l_sql_stmt   CHAR(2000),
          l_ind        INTEGER

   CALL _ADVPL_set_property(m_brz_func,"CLEAR")
   CALL _ADVPL_set_property(m_brz_func,"EDITABLE",FALSE)
   LET m_car_func = TRUE
   INITIALIZE ma_func TO NULL
   LET l_ind = 1
   
    PREPARE var_func FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","func_fornec_concur")
       RETURN FALSE
    END IF

   DECLARE cq_func CURSOR FOR var_func
   
   FOREACH cq_func INTO 
      ma_func[l_ind].funcio_id,
      ma_func[l_ind].cod_fornecedor
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','cq_func:01')
         EXIT FOREACH
      END IF

      IF NOT pol1392_le_fornec(ma_func[l_ind].cod_fornecedor) THEN
         RETURN FALSE
      END IF
   
      LET ma_func[l_ind].raz_social = m_raz_social
            
      LET l_ind = l_ind + 1
      
      IF l_ind > 200 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   IF l_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_func,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'Não há registros para os parâmetros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   LET m_car_func = FALSE
        
END FUNCTION

#-----------------------------------#
FUNCTION pol1392_func_valid_funcio()#
#-----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_func.funcio_id IS NULL THEN
      LET m_msg = 'Informe o ID do funcionário.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_funcio,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   IF NOT pol1392_ve_dupl_funcio() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_funcio,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_func.cod_fornecedor IS NULL THEN
      CALL _ADVPL_set_property(m_fornec,"GET_FOCUS")
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
FUNCTION pol1392_ve_dupl_funcio()#
#--------------------------------#

   SELECT 1 FROM func_fornec_concur
    WHERE cod_empresa = p_cod_empresa
      AND funcio_id = mr_func.funcio_id
   
   IF STATUS = 0 THEN
      LET m_msg = 'Funcionário já cadastrado no POL1392'
   ELSE
      IF STATUS = 100 THEN
         RETURN TRUE
      ELSE
         CALL log003_err_sql('SELECT','func_fornec_concur')
         LET m_msg = 'Erro ',STATUS, ' Lendo tabela func_fornec_concur '
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION         
   
#-----------------------------#
FUNCTION pol1392_zoom_fornec()#
#-----------------------------#

    DEFINE l_codigo         LIKE fornecedor.cod_fornecedor,
           l_descri         LIKE fornecedor.raz_social,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_fornec IS NULL THEN
       LET m_zoom_fornec = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_fornec,"ZOOM","zoom_fornecedor")
    END IF

    #LET l_where_clause = " item.cod_empresa = '",p_cod_empresa,"' "
    #CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_fornec,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_fornec,"RETURN_BY_TABLE_COLUMN","fornecedor","cod_fornecedor")
    LET l_descri = _ADVPL_get_property(m_zoom_fornec,"RETURN_BY_TABLE_COLUMN","fornecedor","raz_social")

    IF l_codigo IS NOT NULL THEN
       LET mr_func.cod_fornecedor = l_codigo
       LET mr_func.raz_social = l_descri
    END IF        
    
    CALL _ADVPL_set_property(m_fornec,"GET_FOCUS")
    
END FUNCTION

#-----------------------------------#
FUNCTION pol1392_func_valid_fornec()#
#-----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   IF mr_func.funcio_id IS NULL THEN
      CALL _ADVPL_set_property(m_funcio,"GET_FOCUS")
      RETURN TRUE
   END IF
   
   IF mr_func.cod_fornecedor IS NULL THEN
      LET m_msg = 'Informe o fornecedor.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT pol1392_le_fornec(mr_func.cod_fornecedor) THEN
      RETURN FALSE
   END IF
   
   LET mr_func.raz_social = m_raz_social
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#   
FUNCTION pol1392_le_fornec(l_cod)#
#--------------------------------#

   DEFINE l_cod       CHAR(15)
   
   SELECT raz_social
     INTO m_raz_social
     FROM fornecedor
    WHERE cod_fornecedor = l_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','fornecedor')
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION    

#-----------------------------#
FUNCTION pol1392_func_insert()#
#-----------------------------#

   LET m_opcao = 'I'
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_func.* TO NULL
   CALL pol1392_desativa_folder("1")
   LET m_car_func = TRUE
   CALL pol1392_func_ativa(TRUE)
   CALL _ADVPL_set_property(m_funcio,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1392_func_insert_canc()#
#----------------------------------#

   CALL pol1392_func_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1392_ativa_folder()
   INITIALIZE mr_func.* TO NULL
   LET m_car_func = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1392_func_insert_conf()#
#----------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   INSERT INTO func_fornec_concur
    VALUES(p_cod_empresa, mr_func.funcio_id, mr_func.cod_fornecedor)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','func_fornec_concur')
      RETURN FALSE
   END IF   
   
   CALL pol1392_func_prepare()
   CALL pol1392_func_ativa(FALSE)
   CALL pol1392_ativa_folder()
   LET m_car_func = FALSE
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1392_func_prepare()#
#------------------------------#

   DEFINE l_sql_stmt CHAR(2000)
   
   LET l_sql_stmt =
    " SELECT funcio_id, cod_fornecedor ",
    "  FROM func_fornec_concur ",
    " WHERE cod_empresa = '",p_cod_empresa,"' "

   CALL pol1392_func_exibe(l_sql_stmt)

END FUNCTION

#------------------------------#
 FUNCTION pol1392_func_prende()#
#------------------------------#
   
   CALL  LOG_transaction_begin()
   
   DECLARE cq_fu_prende CURSOR FOR
    SELECT 1
      FROM func_fornec_concur
     WHERE cod_empresa =  p_cod_empresa
       AND funcio_id = mr_func.funcio_id
     FOR UPDATE 
    
    OPEN cq_fu_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_fu_prende")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
    
   FETCH cq_fu_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_fu_prende")
      CALL log085_transacao("ROLLBACK")
      CLOSE cq_fu_prende
      RETURN FALSE
   END IF

END FUNCTION
   
#-----------------------------#
FUNCTION pol1392_func_update()#
#-----------------------------#   
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_func.funcio_id IS NULL THEN
      LET m_msg = 'Selecione previamente um funcionário.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1392_func_prende() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'M'
   CALL pol1392_func_ativa(TRUE)
   LET m_car_func = TRUE
   CALL _ADVPL_set_property(m_fornec,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1392_func_update_canc()#
#----------------------------------#   
   
   CLOSE cq_fu_prende
   CALL  LOG_transaction_rollback()
   
   SELECT funcio_id
     INTO mr_func.funcio_id
     FROM func_fornec_concur
    WHERE cod_empresa = p_cod_empresa
      AND funcio_id = mr_func.funcio_id

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'func_fornec_concur:iuc')
   ELSE
      CALL pol1392_le_fornec(mr_func.cod_fornecedor)
      LET mr_func.raz_social = m_raz_social
   END IF
         
   CALL pol1392_func_ativa(FALSE)
   LET m_car_func = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1392_func_update_conf()#
#----------------------------------#   

   UPDATE func_fornec_concur 
      SET cod_fornecedor = mr_func.cod_fornecedor
    WHERE cod_empresa = p_cod_empresa
      AND funcio_id = mr_func.funcio_id
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','func_fornec_concur:iuc')
      RETURN FALSE
   END IF

   CALL LOG_transaction_commit()
   
   CLOSE cq_fu_prende
   CALL pol1392_func_ativa(FALSE)
   LET m_car_func = FALSE
   CALL pol1392_func_prepare()   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1392_func_delete()#
#-----------------------------#
   
   DEFINE l_ret   SMALLINT

   IF mr_func.funcio_id IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Selecione om funcionário para excluir.")
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1392_func_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM func_fornec_concur
    WHERE cod_empresa = p_cod_empresa
      AND funcio_id = mr_func.funcio_id

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','func_fornec_concur')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_func.* TO NULL
   ELSE
      CALL LOG_transaction_commit()     
   END IF
   
   CLOSE cq_fu_prende
   CALL pol1392_func_prepare()
   
   RETURN l_ret
        
END FUNCTION




#---Rotinas para tipo de despesa ----#

#------------------------------#
FUNCTION pol1392_desp(l_fpanel)#
#------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_inform    VARCHAR(10),
           l_update    VARCHAR(10),
           l_delete    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10),
           l_create    VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1392_desp_find")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1392_desp_insert")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1392_desp_insert_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1392_desp_insert_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1392_desp_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1392_desp_update_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1392_desp_update_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1392_desp_delete")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1392_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1392_desp_campo(l_panel)
    CALL pol1392_desp_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1392_desp_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_desp = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_desp,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_desp,"HEIGHT",40)
    #CALL _ADVPL_set_property(m_pan_desp,"BACKGROUND_COLOR",225,232,232) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_desp)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Desp concur:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_desp_concur = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_desp)
    CALL _ADVPL_set_property(m_desp_concur,"POSITION",80,10) 
    CALL _ADVPL_set_property(m_desp_concur,"LENGTH",5)    
    CALL _ADVPL_set_property(m_desp_concur,"VARIABLE",mr_desp,"tip_desp_concur")
    CALL _ADVPL_set_property(m_desp_concur,"VALID","pol1392_valid_desp_concur")    
              
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_desp)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",190,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Desp logix:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_desp_logix = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_desp)
    CALL _ADVPL_set_property(m_desp_logix,"POSITION",260,10)
    CALL _ADVPL_set_property(m_desp_logix,"LENGTH",5)    
    CALL _ADVPL_set_property(m_desp_logix,"VARIABLE",mr_desp,"tip_desp_logix")
    CALL _ADVPL_set_property(m_desp_logix,"VALID","pol1392_valid_desp_logix")    

    LET m_lupa_desp = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_desp)
    CALL _ADVPL_set_property(m_lupa_desp,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_desp,"POSITION",320,10)     
    CALL _ADVPL_set_property(m_lupa_desp,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_desp,"CLICK_EVENT","pol1392_zoom_despesa")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_desp)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",350,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_desp,"den_despesa")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    CALL _ADVPL_set_property(m_pan_desp,"ENABLE",FALSE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1392_desp_grade(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_desp = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_desp,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_desp,"BEFORE_ROW_EVENT","pol1392_desp_before_row")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_desp)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Desp concur")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","tip_desp_concur")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_desp)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Desp logix")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","tip_desp_logix")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_desp)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",140)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_despesa")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_desp)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_desp,"SET_ROWS",ma_desp,1)
    CALL _ADVPL_set_property(m_brz_desp,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_desp,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_desp,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#---------------------------------#
FUNCTION pol1392_desp_before_row()#
#---------------------------------#
   
   DEFINE l_linha          INTEGER
   
   IF m_car_desp THEN
      RETURN TRUE
   END IF
      
   LET l_linha = _ADVPL_get_property(m_brz_desp,"ROW_SELECTED")
   
   IF l_linha = 0 OR l_linha IS NULL THEN
      RETURN TRUE
   END IF
   
   LET mr_desp.tip_desp_concur = ma_desp[l_linha].tip_desp_concur
   LET mr_desp.tip_desp_logix = ma_desp[l_linha].tip_desp_logix
   LET mr_desp.den_despesa = ma_desp[l_linha].den_despesa
   
   CALL pol1392_desp_ativa(TRUE)
   CALL _ADVPL_set_property(m_desp_logix,"GET_FOCUS")
   CALL pol1392_desp_ativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1392_desp_ativa(l_status)#
#------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pan_desp,"ENABLE",l_status)
   
   IF m_op_desp = 'I' THEN
      CALL _ADVPL_set_property(m_desp_concur,"ENABLE",l_status)
   ELSE
      CALL _ADVPL_set_property(m_desp_concur,"ENABLE",FALSE)
   END IF
   
   CALL _ADVPL_set_property(m_desp_logix,"ENABLE",l_status)
      
END FUNCTION

#---------------------------#
FUNCTION pol1392_desp_find()#
#---------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200),
           m_construct    VARCHAR(10) 

    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1392_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","tip_desp_concur","Despesa")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","tip_desp_concur","tip_desp_concur","Desp concur",1 {INT},5,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","tip_desp_concur","tip_desp_logix","Desp logix",1 {INT},5,0,"zoom_tipo_despesa")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1392_desp_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#----------------------------------------------------#
FUNCTION pol1392_desp_create_cursor(l_where, l_order)#
#----------------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)
    DEFINE l_ind        INTEGER

    IF l_order IS NULL THEN
       LET l_order = " tip_desp_concur "
    END IF
    
    LET l_sql_stmt = 
        "SELECT tip_desp_concur, tip_desp_logix ",
        " FROM tip_desp_concur ",
        " WHERE ",l_where CLIPPED,
        " ORDER BY ",l_order
   
   CALL pol1392_desp_exibe(l_sql_stmt)
   
END FUNCTION

#--------------------------------------#
FUNCTION pol1392_desp_exibe(l_sql_stmt)#
#--------------------------------------#
   
   DEFINE l_sql_stmt   CHAR(2000),
          l_ind        INTEGER

   CALL _ADVPL_set_property(m_brz_desp,"CLEAR")
   CALL _ADVPL_set_property(m_brz_desp,"EDITABLE",FALSE)
   LET m_car_desp = TRUE
   INITIALIZE ma_desp TO NULL
   LET l_ind = 1
   
    PREPARE var_desp FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","tip_desp_concur")
       RETURN FALSE
    END IF

   DECLARE cq_desp CURSOR FOR var_desp
   
   FOREACH cq_desp INTO 
      ma_desp[l_ind].tip_desp_concur,
      ma_desp[l_ind].tip_desp_logix
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','cq_desp:01')
         EXIT FOREACH
      END IF
      
      LET ma_desp[l_ind].den_despesa = pol1392_le_desp(ma_desp[l_ind].tip_desp_logix)
                  
      LET l_ind = l_ind + 1
      
      IF l_ind > 200 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   LET l_ind = l_ind - 1

   IF l_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_desp,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'Não há registros para os parâmetros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   LET m_car_desp = FALSE
        
END FUNCTION

#------------------------------#
FUNCTION pol1392_le_desp(l_cod)#
#------------------------------#
   
   DEFINE l_cod          integer,
          l_desc         CHAR(30)
   
   SELECT nom_tip_despesa
     INTO l_desc
     FROM tipo_despesa
    WHERE cod_empresa = p_cod_empresa
      AND cod_tip_despesa = l_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','tipo_despesa')
      LET l_desc = NULL
   END IF
   
   RETURN l_desc

END FUNCTION         
     
#-------------------------------#
FUNCTION pol1392_desp_duplicou()#
#-------------------------------#

   SELECT 1 FROM tip_desp_concur
    WHERE cod_empresa = p_cod_empresa
      AND tip_desp_concur = mr_desp.tip_desp_concur
   
   IF STATUS = 0 THEN
      LET m_msg = 'Tipo de despesa já cadastrado no POL1392.'
   ELSE
      IF STATUS = 100 THEN
         RETURN FALSE
      ELSE
         CALL log003_err_sql('SELECT','tip_desp_concur')
         LET m_msg = 'Erro ',STATUS, ' Lendo tabela tip_desp_concur '
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION         
   
#------------------------------#
FUNCTION pol1392_zoom_despesa()#
#------------------------------#

    DEFINE l_codigo         LIKE tipo_despesa.cod_tip_despesa,
           l_descri         LIKE tipo_despesa.nom_tip_despesa,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_desp IS NULL THEN
       LET m_zoom_desp = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_desp,"ZOOM","zoom_tipo_despesa")
    END IF

    LET l_where_clause = " tipo_despesa.cod_empresa = '",p_cod_empresa,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)

    CALL _ADVPL_get_property(m_zoom_desp,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_desp,"RETURN_BY_TABLE_COLUMN","tipo_despesa","cod_tip_despesa")
    LET l_descri = _ADVPL_get_property(m_zoom_desp,"RETURN_BY_TABLE_COLUMN","tipo_despesa","nom_tip_despesa")

    IF l_codigo IS NOT NULL THEN
       LET mr_desp.tip_desp_logix = l_codigo
       LET mr_desp.den_despesa = l_descri
    END IF        
    
    CALL _ADVPL_set_property(m_desp_logix,"GET_FOCUS")
    
END FUNCTION

#-----------------------------------#
FUNCTION pol1392_valid_desp_concur()#
#-----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_desp.tip_desp_concur IS NULL THEN
      LET m_msg = 'Informe o tipo de despesa do concur.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF mr_desp.tip_desp_logix IS NULL THEN
      CALL _ADVPL_set_property(m_desp_logix,"GET_FOCUS")
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#----------------------------------#
FUNCTION pol1392_valid_desp_logix()#
#----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   IF mr_desp.tip_desp_concur IS NULL THEN
      CALL _ADVPL_set_property(m_desp_concur,"GET_FOCUS")
      RETURN TRUE
   END IF
   
   IF mr_desp.tip_desp_logix IS NULL THEN
      LET m_msg = 'Informe o tipo de despesa do logix.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   LET mr_desp.den_despesa = pol1392_le_desp(mr_desp.tip_desp_logix)

   IF mr_desp.den_despesa IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION   

#-----------------------------#
FUNCTION pol1392_desp_insert()#
#-----------------------------#

   LET m_op_desp = 'I'
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_desp.* TO NULL
   CALL pol1392_desativa_folder("2")
   LET m_car_desp = TRUE
   CALL pol1392_desp_ativa(TRUE)
   CALL _ADVPL_set_property(m_desp_concur,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1392_desp_insert_canc()#
#----------------------------------#

   CALL pol1392_desp_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1392_ativa_folder()
   INITIALIZE mr_desp.* TO NULL
   LET m_car_desp = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1392_desp_insert_conf()#
#----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF pol1392_desp_duplicou() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   INSERT INTO tip_desp_concur
    VALUES(p_cod_empresa,
           mr_desp.tip_desp_concur,
           mr_desp.tip_desp_logix)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','tip_desp_concur')
      RETURN FALSE
   END IF   
   
   CALL pol1392_desp_prepare()
   CALL pol1392_desp_ativa(FALSE)
   CALL pol1392_ativa_folder()
   LET m_car_desp = FALSE
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1392_desp_prepare()#
#------------------------------#

   DEFINE l_sql_stmt CHAR(2000)

   LET l_sql_stmt = 
        "SELECT tip_desp_concur, tip_desp_logix ",
        " FROM tip_desp_concur ",
        " ORDER BY tip_desp_concur "
   
   CALL pol1392_desp_exibe(l_sql_stmt)

END FUNCTION

#------------------------------#
 FUNCTION pol1392_desp_prende()#
#------------------------------#
   
   CALL  LOG_transaction_begin()
   
   DECLARE cq_desp_prende CURSOR FOR
    SELECT 1
      FROM tip_desp_concur
     WHERE cod_empresa = p_cod_empresa
       AND tip_desp_concur = mr_desp.tip_desp_concur
     FOR UPDATE 
    
    OPEN cq_desp_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_desp_prende")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
    
   FETCH cq_desp_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_desp_prende")
      CALL log085_transacao("ROLLBACK")
      CLOSE cq_fu_prende
      RETURN FALSE
   END IF

END FUNCTION
   
#-----------------------------#
FUNCTION pol1392_desp_update()#
#-----------------------------#   
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_desp.tip_desp_concur IS NULL THEN
      LET m_msg = 'Selecione previamente um registro.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1392_desp_prende() THEN
      RETURN FALSE
   END IF
   
   LET m_op_desp = 'U'
   CALL pol1392_desp_ativa(TRUE)
   LET m_car_desp = TRUE
   CALL _ADVPL_set_property(m_desp_logix,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1392_desp_update_canc()#
#----------------------------------#   
   
   CLOSE cq_desp_prende
   CALL  LOG_transaction_rollback()
   
   SELECT tip_desp_concur, 
          tip_desp_logix
     INTO mr_desp.tip_desp_concur, 
          mr_desp.tip_desp_logix
     FROM tip_desp_concur
    WHERE cod_empresa = p_cod_empresa
      AND tip_desp_concur = mr_desp.tip_desp_concur

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'tip_desp_concur:duc')
   ELSE
      LET mr_desp.den_despesa = pol1392_le_desp(mr_desp.tip_desp_logix)
   END IF
         
   CALL pol1392_desp_ativa(FALSE)
   LET m_car_desp = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1392_desp_update_conf()#
#----------------------------------#   

   UPDATE tip_desp_concur 
      SET tip_desp_logix = mr_desp.tip_desp_logix
    WHERE cod_empresa = p_cod_empresa
      AND tip_desp_concur = mr_desp.tip_desp_concur
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','tip_desp_concur:conf')
      RETURN FALSE
   END IF

   CALL LOG_transaction_commit()
   
   CLOSE cq_desp_prende
   CALL pol1392_desp_ativa(FALSE)
   LET m_car_desp = FALSE
   CALL pol1392_desp_prepare()   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1392_desp_delete()#
#-----------------------------#
   
   DEFINE l_ret   SMALLINT

   IF mr_desp.tip_desp_concur IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Selecione um registro para excluir.")
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1392_desp_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM tip_desp_concur
    WHERE cod_empresa = p_cod_empresa
      AND tip_desp_concur = mr_desp.tip_desp_concur

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','tip_desp_concur:od')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_desp.* TO NULL
   ELSE
      CALL LOG_transaction_commit()     
   END IF
   
   CLOSE cq_desp_prende
   CALL pol1392_desp_prepare()
   
   RETURN l_ret
        
END FUNCTION


#---Rotinas para centro de custo ----#

#------------------------------#
FUNCTION pol1392_cust(l_fpanel)#
#------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_inform    VARCHAR(10),
           l_update    VARCHAR(10),
           l_delete    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10),
           l_create    VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1392_cust_find")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1392_cust_insert")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1392_cust_insert_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1392_cust_insert_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1392_cust_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1392_cust_update_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1392_cust_update_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1392_cust_delete")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1392_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1392_cust_campo(l_panel)
    CALL pol1392_cust_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1392_cust_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_cust = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_cust,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_cust,"HEIGHT",60)
    #CALL _ADVPL_set_property(m_pan_cust,"BACKGROUND_COLOR",225,232,232) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cust)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Cent cust concur:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_cc_concur = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_cust)
    CALL _ADVPL_set_property(m_cc_concur,"POSITION",110,10) 
    CALL _ADVPL_set_property(m_cc_concur,"LENGTH",5)    
    CALL _ADVPL_set_property(m_cc_concur,"VARIABLE",mr_cust,"cod_cc_concor")
    CALL _ADVPL_set_property(m_cc_concur,"VALID","pol1392_valid_cust_concur")    
              
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cust)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",180,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Cent cust logix:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cc_logix = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_cust)
    CALL _ADVPL_set_property(m_cc_logix,"POSITION",270,10)
    CALL _ADVPL_set_property(m_cc_logix,"LENGTH",5)    
    CALL _ADVPL_set_property(m_cc_logix,"VARIABLE",mr_cust,"cod_cc_logix")
    CALL _ADVPL_set_property(m_cc_logix,"VALID","pol1392_valid_cust_logix")    

    LET m_lupa_cust = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_cust)
    CALL _ADVPL_set_property(m_lupa_cust,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cust,"POSITION",320,10)     
    CALL _ADVPL_set_property(m_lupa_cust,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cust,"CLICK_EVENT","pol1392_zoom_cust")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_cust)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",350,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cust,"nom_cent_cust")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cust)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Cód lin prod:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_lin_prod = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_cust)
    CALL _ADVPL_set_property(m_lin_prod,"POSITION",90,40) 
    CALL _ADVPL_set_property(m_lin_prod,"LENGTH",3)    
    CALL _ADVPL_set_property(m_lin_prod,"VARIABLE",mr_cust,"cod_lin_prod")
    CALL _ADVPL_set_property(m_lin_prod,"VALID","pol1392_checa_linha")    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cust)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",160,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Cód lin recei:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_lin_recei = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_cust)
    CALL _ADVPL_set_property(m_lin_recei,"POSITION",235,40) 
    CALL _ADVPL_set_property(m_lin_recei,"LENGTH",3)    
    CALL _ADVPL_set_property(m_lin_recei,"VARIABLE",mr_cust,"cod_lin_recei")
    CALL _ADVPL_set_property(m_lin_recei,"VALID","pol1392_checa_linha")    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cust)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",300,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Cód seg merc:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_seg_merc = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_cust)
    CALL _ADVPL_set_property(m_seg_merc,"POSITION",380,40) 
    CALL _ADVPL_set_property(m_seg_merc,"LENGTH",3)    
    CALL _ADVPL_set_property(m_seg_merc,"VARIABLE",mr_cust,"cod_seg_merc")
    CALL _ADVPL_set_property(m_seg_merc,"VALID","pol1392_checa_linha")    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cust)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",440,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Cód cla uso:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_cla_uso = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_cust)
    CALL _ADVPL_set_property(m_cla_uso,"POSITION",510,40) 
    CALL _ADVPL_set_property(m_cla_uso,"LENGTH",3)    
    CALL _ADVPL_set_property(m_cla_uso,"VARIABLE",mr_cust,"cod_cla_uso")
    CALL _ADVPL_set_property(m_cla_uso,"VALID","pol1392_checa_linha")    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cust)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",600,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Nome linha:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_cust)
    CALL _ADVPL_set_property(l_caixa,"POSITION",670,40) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cust,"nom_linha_prod")
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    CALL _ADVPL_set_property(m_pan_cust,"ENABLE",FALSE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1392_cust_grade(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_cust = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_cust,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_cust,"BEFORE_ROW_EVENT","pol1392_cust_before_row")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cust)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cent cust concur")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cc_concor")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cust)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cent cust logix")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cc_logix")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cust)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",140)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_cent_cust")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cust)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Lin prod")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_lin_prod")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cust)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Lin recei")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_lin_recei")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cust)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Seg merc")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_seg_merc")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cust)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cla uso")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cla_uso")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cust)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome linha")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_linha_prod")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cust)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_cust,"SET_ROWS",ma_cust,1)
    CALL _ADVPL_set_property(m_brz_cust,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_cust,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_cust,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#---------------------------------#
FUNCTION pol1392_cust_before_row()#
#---------------------------------#
   
   DEFINE l_linha          INTEGER
   
   IF m_car_cust THEN
      RETURN TRUE
   END IF
      
   LET l_linha = _ADVPL_get_property(m_brz_cust,"ROW_SELECTED")
   
   IF l_linha = 0 OR l_linha IS NULL THEN
      RETURN TRUE
   END IF
   
   LET mr_cust.cod_cc_concor = ma_cust[l_linha].cod_cc_concor
   LET mr_cust.cod_cc_logix = ma_cust[l_linha].cod_cc_logix
   LET mr_cust.nom_cent_cust = ma_cust[l_linha].nom_cent_cust
   LET mr_cust.cod_lin_prod = ma_cust[l_linha].cod_lin_prod
   LET mr_cust.cod_lin_recei = ma_cust[l_linha].cod_lin_recei
   LET mr_cust.cod_seg_merc = ma_cust[l_linha].cod_seg_merc
   LET mr_cust.cod_cla_uso = ma_cust[l_linha].cod_cla_uso
   LET mr_cust.nom_linha_prod = ma_cust[l_linha].nom_linha_prod
   
   CALL pol1392_cust_ativa(TRUE)
   CALL _ADVPL_set_property(m_cc_logix,"GET_FOCUS")
   CALL pol1392_cust_ativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1392_cust_ativa(l_status)#
#------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pan_cust,"ENABLE",l_status)
   
   IF m_op_cust = 'I' THEN
      CALL _ADVPL_set_property(m_cc_concur,"ENABLE",l_status)
   ELSE
      CALL _ADVPL_set_property(m_cc_concur,"ENABLE",FALSE)
   END IF
   
   CALL _ADVPL_set_property(m_cc_logix,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_lin_prod,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_lin_recei,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_cla_uso,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_seg_merc,"ENABLE",l_status)
      
END FUNCTION

#---------------------------#
FUNCTION pol1392_cust_find()#
#---------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200),
           m_construct    VARCHAR(10) 
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1392_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","cent_cust_concur","Cent_custo")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","cent_cust_concur","cod_cc_concor","Cent cust concur",1 {INT},5,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","cent_cust_concur","cod_cc_logix","Cent cust logix",1 {INT},5,0,"zoom_tipo_custesa")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1392_cust_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#----------------------------------------------------#
FUNCTION pol1392_cust_create_cursor(l_where, l_order)#
#----------------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)
    DEFINE l_ind        INTEGER

    IF l_order IS NULL THEN
       LET l_order = " cod_cc_concor "
    END IF
    
    LET l_sql_stmt = 
        "SELECT * FROM cent_cust_concur ",
        " WHERE ",l_where CLIPPED,
        " ORDER BY ",l_order
   
   CALL pol1392_cust_exibe(l_sql_stmt)
   
END FUNCTION

#--------------------------------------#
FUNCTION pol1392_cust_exibe(l_sql_stmt)#
#--------------------------------------#
   
   DEFINE l_sql_stmt   CHAR(2000),
          l_ind        INTEGER

   CALL _ADVPL_set_property(m_brz_cust,"CLEAR")
   CALL _ADVPL_set_property(m_brz_cust,"EDITABLE",FALSE)
   LET m_car_cust = TRUE
   INITIALIZE ma_cust TO NULL
   LET l_ind = 1
   
    PREPARE var_cust FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","tip_cust_concur")
       RETURN FALSE
    END IF

   DECLARE cq_cust CURSOR FOR var_cust
   
   FOREACH cq_cust INTO 
      ma_cust[l_ind].cod_empresa,
      ma_cust[l_ind].cod_cc_concor,
      ma_cust[l_ind].cod_cc_logix,
      ma_cust[l_ind].cod_lin_prod,  
      ma_cust[l_ind].cod_lin_recei, 
      ma_cust[l_ind].cod_seg_merc,  
      ma_cust[l_ind].cod_cla_uso

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','cq_cust:01')
         EXIT FOREACH
      END IF
      
      LET ma_cust[l_ind].nom_cent_cust = pol1392_le_cust(ma_cust[l_ind].cod_cc_logix)

      SELECT den_estr_linprod                                
        INTO ma_cust[l_ind].nom_linha_prod                          
        FROM linha_prod                                      
       WHERE cod_lin_prod = ma_cust[l_ind].cod_lin_prod             
         AND cod_lin_recei = ma_cust[l_ind].cod_lin_recei           
         AND cod_seg_merc = ma_cust[l_ind].cod_seg_merc             
         AND cod_cla_uso  = ma_cust[l_ind].cod_cla_uso              
                                                             
      IF STATUS <> 0 THEN                                    
         LET ma_cust[l_ind].nom_linha_prod = NULL                               
      END IF                                                 
                        
      LET l_ind = l_ind + 1
      
      IF l_ind > 200 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   LET l_ind = l_ind - 1

   IF l_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_cust,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'Não há registros para os parâmetros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   LET m_car_cust = FALSE
        
END FUNCTION

#------------------------------#
FUNCTION pol1392_le_cust(l_cod)#
#------------------------------#
   
   DEFINE l_cod          integer,
          l_desc         CHAR(30)
   
   SELECT nom_cent_cust
     INTO l_desc
     FROM cad_cc
    WHERE cod_empresa = p_cod_empresa
      AND cod_cent_cust = l_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cad_cc')
      LET l_desc = NULL
   END IF
   
   RETURN l_desc

END FUNCTION         
     
#-------------------------------#
FUNCTION pol1392_cust_duplicou()#
#-------------------------------#

   SELECT 1 FROM cent_cust_concur
    WHERE cod_empresa = p_cod_empresa
      AND cod_cc_concor = mr_cust.cod_cc_concor
   
   IF STATUS = 0 THEN
      LET m_msg = 'Centro de custo já cadastrado no POL1392.'
   ELSE
      IF STATUS = 100 THEN
         RETURN FALSE
      ELSE
         CALL log003_err_sql('SELECT','cod_cc_concor')
         LET m_msg = 'Erro ',STATUS, ' Lendo tabela cod_cc_concor '
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION         
   
#---------------------------#
FUNCTION pol1392_zoom_cust()#
#---------------------------#

    DEFINE l_codigo         LIKE cad_cc.cod_cent_cust,
           l_descri         LIKE cad_cc.nom_cent_cust,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_cust IS NULL THEN
       LET m_zoom_cust = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_cust,"ZOOM","zoom_centro_custo")
    END IF

    LET l_where_clause = " cad_cc.cod_empresa = '",p_cod_empresa,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)

    CALL _ADVPL_get_property(m_zoom_cust,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_cust,"RETURN_BY_TABLE_COLUMN","cad_cc","cod_cent_cust")
    LET l_descri = _ADVPL_get_property(m_zoom_cust,"RETURN_BY_TABLE_COLUMN","cad_cc","nom_cent_cust")

    IF l_codigo IS NOT NULL THEN
       LET mr_cust.cod_cc_logix = l_codigo
       LET mr_cust.nom_cent_cust = l_descri
    END IF        
    
    CALL _ADVPL_set_property(m_cc_logix,"GET_FOCUS")
    
END FUNCTION

#-----------------------------------#
FUNCTION pol1392_valid_cust_concur()#
#-----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_cust.cod_cc_concor IS NULL THEN
      LET m_msg = 'Informe o centro de custo do concur.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF mr_cust.cod_cc_logix IS NULL THEN
      CALL _ADVPL_set_property(m_cc_logix,"GET_FOCUS")
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#----------------------------------#
FUNCTION pol1392_valid_cust_logix()#
#----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   IF mr_cust.cod_cc_concor IS NULL THEN
      CALL _ADVPL_set_property(m_cc_concur,"GET_FOCUS")
      RETURN TRUE
   END IF
   
   IF mr_cust.cod_cc_logix IS NULL THEN
      LET m_msg = 'Informe o centro de custo do logix.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   LET mr_cust.nom_cent_cust = pol1392_le_cust(mr_cust.cod_cc_logix)

   IF mr_cust.nom_cent_cust IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION   

#-----------------------------#
FUNCTION pol1392_cust_insert()#
#-----------------------------#

   LET m_op_cust = 'I'
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_cust.* TO NULL
   CALL pol1392_desativa_folder("3")
   LET m_car_cust = TRUE
   CALL pol1392_cust_ativa(TRUE)
   CALL _ADVPL_set_property(m_cc_concur,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1392_cust_insert_canc()#
#----------------------------------#

   CALL pol1392_cust_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1392_ativa_folder()
   INITIALIZE mr_cust.* TO NULL
   LET m_car_cust = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1392_cust_insert_conf()#
#----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF pol1392_cust_duplicou() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1392_valid_linha() THEN
      RETURN FALSE
   END IF
   
   INSERT INTO cent_cust_concur
    VALUES(p_cod_empresa,
           mr_cust.cod_cc_concor,
           mr_cust.cod_cc_logix,
           mr_cust.cod_lin_prod,
           mr_cust.cod_lin_recei,
           mr_cust.cod_cla_uso,
           mr_cust.cod_seg_merc)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','cent_cust_concur')
      RETURN FALSE
   END IF   
   
   CALL pol1392_cust_prepare()
   CALL pol1392_cust_ativa(FALSE)
   CALL pol1392_ativa_folder()
   LET m_car_cust = FALSE
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1392_checa_linha()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_cust.cod_lin_prod IS NULL OR
      mr_cust.cod_lin_recei IS NULL OR
      mr_cust.cod_seg_merc IS NULL OR
      mr_cust.cod_cla_uso IS NULL THEN
      RETURN TRUE
   END IF
   
   IF NOT pol1392_valid_linha() THEN
      LET m_msg = 'Informe uma AEN com 4 níveis cadastrados no Logix'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
   
   RETURN TRUE

END FUNCTION
       
#-----------------------------#
FUNCTION pol1392_valid_linha()#
#-----------------------------#
       
   SELECT den_estr_linprod
     INTO mr_cust.nom_linha_prod
     FROM linha_prod
    WHERE cod_lin_prod = mr_cust.cod_lin_prod
      AND cod_lin_recei = mr_cust.cod_lin_recei
      AND cod_seg_merc = mr_cust.cod_seg_merc
      AND cod_cla_uso  = mr_cust.cod_cla_uso

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','linha_prod')
      LET mr_cust.nom_linha_prod = NULL
      RETURN FALSE
   END IF  
      
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1392_cust_prepare()#
#------------------------------#

   DEFINE l_sql_stmt CHAR(2000)

   LET l_sql_stmt = 
        "SELECT * FROM cent_cust_concur ",
        " ORDER BY cod_cc_concor "
   
   CALL pol1392_cust_exibe(l_sql_stmt)

END FUNCTION

#------------------------------#
 FUNCTION pol1392_cust_prende()#
#------------------------------#
   
   CALL  LOG_transaction_begin()
   
   DECLARE cq_cust_prende CURSOR FOR
    SELECT 1
      FROM cent_cust_concur
     WHERE cod_empresa = p_cod_empresa
       AND cod_cc_concor = mr_cust.cod_cc_concor
     FOR UPDATE 
    
    OPEN cq_cust_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_cust_prende")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
    
   FETCH cq_cust_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_cust_prende")
      CALL log085_transacao("ROLLBACK")
      CLOSE cq_fu_prende
      RETURN FALSE
   END IF

END FUNCTION
   
#-----------------------------#
FUNCTION pol1392_cust_update()#
#-----------------------------#   
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_cust.cod_cc_concor IS NULL THEN
      LET m_msg = 'Selecione previamente um registro.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1392_cust_prende() THEN
      RETURN FALSE
   END IF
   
   LET m_op_cust = 'U'
   CALL pol1392_cust_ativa(TRUE)
   LET m_car_cust = TRUE
   CALL _ADVPL_set_property(m_cc_logix,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1392_cust_update_canc()#
#----------------------------------#   
   
   CLOSE cq_cust_prende
   CALL  LOG_transaction_rollback()
   
   SELECT cod_cc_concor, 
          cod_cc_logix
     INTO mr_cust.cod_cc_concor, 
          mr_cust.cod_cc_logix
     FROM cent_cust_concur
    WHERE cod_empresa = p_cod_empresa
      AND cod_cc_concor = mr_cust.cod_cc_concor

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'cent_cust_concur:cuc')
   ELSE
      LET mr_cust.nom_cent_cust = pol1392_le_cust(mr_cust.cod_cc_logix)
   END IF
         
   CALL pol1392_cust_ativa(FALSE)
   LET m_car_cust = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1392_cust_update_conf()#
#----------------------------------#   

   IF NOT pol1392_valid_linha() THEN
      RETURN FALSE
   END IF

   UPDATE cent_cust_concur 
      SET cod_cc_logix = mr_cust.cod_cc_logix,
          cod_lin_prod =  mr_cust.cod_lin_prod,
          cod_lin_recei = mr_cust.cod_lin_recei,
          cod_cla_uso =   mr_cust.cod_cla_uso,
          cod_seg_merc =  mr_cust.cod_seg_merc
    WHERE cod_empresa = p_cod_empresa
      AND cod_cc_concor = mr_cust.cod_cc_concor
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','cent_cust_concur:conf')
      RETURN FALSE
   END IF

   CALL LOG_transaction_commit()
   
   CLOSE cq_cust_prende
   CALL pol1392_cust_ativa(FALSE)
   LET m_car_cust = FALSE
   CALL pol1392_cust_prepare()   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1392_cust_delete()#
#-----------------------------#
   
   DEFINE l_ret   SMALLINT

   IF mr_cust.cod_cc_concor IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Selecione um registro para excluir.")
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1392_cust_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM cent_cust_concur
    WHERE cod_empresa = p_cod_empresa
      AND cod_cc_concor = mr_cust.cod_cc_concor

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','cent_cust_concur:od')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_cust.* TO NULL
   ELSE
      CALL LOG_transaction_commit()     
   END IF
   
   CLOSE cq_cust_prende
   CALL pol1392_cust_prepare()
   
   RETURN l_ret
        
END FUNCTION
