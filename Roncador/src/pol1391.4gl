#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1391                                                 #
# OBJETIVO: CADASTROS PARA INREGRAÇÃO SICAL X LOGIX                 #
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
       m_fold_item       VARCHAR(10),
       m_fold_pgto       VARCHAR(10),
       m_fold_oper       VARCHAR(10),
       m_fold_erro       VARCHAR(10),
       m_construct       VARCHAR(10)

DEFINE m_pan_item        VARCHAR(10),
       m_pan_pgto        VARCHAR(10),
       m_pan_oper        VARCHAR(10),
       m_pan_erro        VARCHAR(10)

DEFINE m_brz_item        VARCHAR(10),
       m_brz_pgto        VARCHAR(10),
       m_brz_oper        VARCHAR(10),
       m_brz_erro        VARCHAR(10)
       
DEFINE m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_opcao           CHAR(01),
       m_op_oper         CHAR(01),
       m_car_item        SMALLINT,
       m_car_pgto        SMALLINT,
       m_car_oper        SMALLINT,
       m_qtd_item        INTEGER,
       m_ind             INTEGER,
       m_lin_atu         INTEGER
                     
DEFINE m_zoom_item       VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_sical           VARCHAR(10),
       m_logix           VARCHAR(10),
       m_zoom_operv      VARCHAR(10),
       m_zoom_operr      VARCHAR(10),
       m_lupa_operv      VARCHAR(10),
       m_lupa_operr      VARCHAR(10),
       m_zoom_pgto       VARCHAR(10),
       m_lupa_pgto       VARCHAR(10),
       m_pgto_sical      VARCHAR(10),
       m_pgto_logix      VARCHAR(10),
       m_tip_pedido      VARCHAR(10),
       m_entrega         VARCHAR(10),
       m_nat_venda       VARCHAR(10),
       m_nat_remessa     VARCHAR(10)

DEFINE mr_item          RECORD
       cod_sical        LIKE item.cod_item,
       cod_logix        LIKE item.cod_item,
       den_item         LIKE item.den_item
END RECORD

DEFINE ma_item          ARRAY[200] OF RECORD
       cod_sical        LIKE item.cod_item,
       cod_logix        LIKE item.cod_item,
       den_item         LIKE item.den_item,
       filler           CHAR(01)
END RECORD
       
DEFINE m_den_item       CHAR(76),
       m_den_pgto       CHAR(30)

DEFINE mr_pgto          RECORD
       cod_sical        LIKE cond_pgto.cod_cnd_pgto,
       cod_logix        LIKE cond_pgto.cod_cnd_pgto,
       den_pgto         LIKE cond_pgto.den_cnd_pgto
END RECORD

DEFINE ma_pgto          ARRAY[200] OF RECORD
       cod_sical        LIKE cond_pgto.cod_cnd_pgto,
       cod_logix        LIKE cond_pgto.cod_cnd_pgto,
       den_pgto         LIKE cond_pgto.den_cnd_pgto,
       filler           CHAR(01)
END RECORD

DEFINE mr_oper          RECORD
       tip_pedido            char(01),
       entrega_furura        char(01),
       cod_nat_venda         integer, 
       den_nat_venda         char(30),
       cod_nat_remessa       integer,
       den_nat_remessa       char(30)
END RECORD

DEFINE ma_oper          ARRAY[10] OF RECORD
       tip_pedido            char(01),
       entrega_furura        char(01),
       cod_nat_venda         integer, 
       den_nat_venda         char(30),
       cod_nat_remessa       integer,
       den_nat_remessa       char(30),
       filler                CHAR(01)
END RECORD
             
#-----------------#
FUNCTION pol1391()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1391-12.00.03  "
   CALL func002_versao_prg(p_versao)
   
   LET m_car_item = TRUE
   LET m_car_oper = TRUE
   
   CALL pol1391_menu()

END FUNCTION
 
#----------------------#
FUNCTION pol1391_menu()#
#----------------------#

    DEFINE l_menubar       VARCHAR(10),
           l_fechar        VARCHAR(10),
           l_panel         VARCHAR(10),
           l_fpanel        VARCHAR(10),
           l_label         VARCHAR(10),
           l_titulo        CHAR(80)

    LET l_titulo = 'CADASTROS PARA INREGRAÇÃO SICAL X LOGIX - ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET m_folder = _ADVPL_create_component(NULL,"LFOLDER",m_dialog)
    CALL _ADVPL_set_property(m_folder,"ALIGN","CENTER")

    # FOLDER item 

    LET m_fold_item = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_item,"TITLE","Produto")
		CALL pol1391_item(m_fold_item)
    
    # FOLDER nat oper 

    LET m_fold_oper = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_oper,"TITLE","Operação")
    CALL pol1391_oper(m_fold_oper)

    # FOLDER erros
{
    LET m_fold_erro = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_erro,"TITLE","Erro")
    #CALL pol1391_erro(m_fold_erro)

    # FOLDER cnd pgto 

    LET m_fold_pgto = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_pgto,"TITLE","Cond pgto")
    #CALL pol1391_pgto(m_fold_pgto)
}
    CALL _ADVPL_set_property(m_folder,"FOLDER_SELECTED",1)
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION
   
#------------------------#
FUNCTION pol1391_fechar()#
#------------------------#

   RETURN TRUE
   
END FUNCTION

#-----------------------------------------#
FUNCTION pol1391_desativa_folder(l_folder)#
#-----------------------------------------#

   DEFINE l_folder             CHAR(01)
             
   CASE l_folder
        WHEN '1' 
           CALL _ADVPL_set_property(m_fold_oper,"ENABLE",FALSE)
           #CALL _ADVPL_set_property(m_fold_erro,"ENABLE",FALSE)        
           #CALL _ADVPL_set_property(m_fold_pgto,"ENABLE",FALSE)        
        WHEN '2' 
           CALL _ADVPL_set_property(m_fold_item,"ENABLE",FALSE)   
           #CALL _ADVPL_set_property(m_fold_erro,"ENABLE",FALSE)      
           #CALL _ADVPL_set_property(m_fold_pgto,"ENABLE",FALSE)
        WHEN '3' 
           CALL _ADVPL_set_property(m_fold_item,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_oper,"ENABLE",FALSE)
           #CALL _ADVPL_set_property(m_fold_pgto,"ENABLE",FALSE)
        WHEN '4' 
           CALL _ADVPL_set_property(m_fold_item,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_oper,"ENABLE",FALSE) 
           #CALL _ADVPL_set_property(m_fold_erro,"ENABLE",FALSE)      
   END CASE
   
END FUNCTION

#------------------------------#
FUNCTION pol1391_ativa_folder()#
#------------------------------#

   CALL _ADVPL_set_property(m_fold_item,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_oper,"ENABLE",TRUE)
   #CALL _ADVPL_set_property(m_fold_erro,"ENABLE",TRUE) 
   #CALL _ADVPL_set_property(m_fold_pgto,"ENABLE",TRUE)

END FUNCTION




#---Rotinas de-para item ----#

#------------------------------#
FUNCTION pol1391_item(l_fpanel)#
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
    CALL _ADVPL_set_property(l_find,"EVENT","pol1391_item_find")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1391_item_insert")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1391_item_insert_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1391_item_insert_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1391_item_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1391_item_update_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1391_item_update_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1391_item_delete")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1391_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1391_item_campo(l_panel)
    CALL pol1391_item_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1391_item_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_item = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_item,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_item,"HEIGHT",40)
    #CALL _ADVPL_set_property(m_pan_item,"BACKGROUND_COLOR",225,232,232) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_item)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Item sical:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_sical = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_item)     
    CALL _ADVPL_set_property(m_sical,"POSITION",80,10) 
    CALL _ADVPL_set_property(m_sical,"LENGTH",15,0)    
    CALL _ADVPL_set_property(m_sical,"PICTURE","@!") 
    CALL _ADVPL_set_property(m_sical,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(m_sical,"VARIABLE",mr_item,"cod_sical")
    CALL _ADVPL_set_property(m_sical,"VALID","pol1391_item_valid_sical")        
              
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_item)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",230,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Item logix:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_logix = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_item)     
    CALL _ADVPL_set_property(m_logix,"POSITION",300,10) 
    CALL _ADVPL_set_property(m_logix,"LENGTH",15,0)    
    CALL _ADVPL_set_property(m_logix,"PICTURE","@!") 
    CALL _ADVPL_set_property(m_logix,"VARIABLE",mr_item,"cod_logix")
    CALL _ADVPL_set_property(m_logix,"VALID","pol1391_valid_item")    

    LET m_lupa_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_item)
    CALL _ADVPL_set_property(m_lupa_item,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_item,"POSITION",430,10)     
    CALL _ADVPL_set_property(m_lupa_item,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_item,"CLICK_EVENT","pol1391_zoom_item")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_item)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",480,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",35,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_item,"den_item")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    CALL _ADVPL_set_property(m_pan_item,"ENABLE",FALSE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1391_item_grade(l_container)#
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
   
    LET m_brz_item = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_item,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_item,"BEFORE_ROW_EVENT","pol1391_item_before_row")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item sical")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_sical")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item logix")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_logix")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",300)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_item,"SET_ROWS",ma_item,1)
    CALL _ADVPL_set_property(m_brz_item,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_item,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_item,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#---------------------------------#
FUNCTION pol1391_item_before_row()#
#---------------------------------#
   
   DEFINE l_linha          INTEGER
   
   IF m_car_item THEN
      RETURN TRUE
   END IF
      
   LET l_linha = _ADVPL_get_property(m_brz_item,"ROW_SELECTED")
   
   IF l_linha = 0 OR l_linha IS NULL THEN
      RETURN TRUE
   END IF
   
   LET mr_item.cod_sical = ma_item[l_linha].cod_sical
   LET mr_item.cod_logix = ma_item[l_linha].cod_logix
   
   CALL pol1391_le_item(mr_item.cod_logix) RETURNING p_status
   
   LET mr_item.den_item = m_den_item
   LET m_lin_atu = l_linha
   
   CALL pol1391_item_ativa(TRUE)
   CALL _ADVPL_set_property(m_logix,"GET_FOCUS")
   CALL pol1391_item_ativa(false)
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1391_item_ativa(l_status)#
#------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pan_item,"ENABLE",l_status)
   IF m_opcao = 'I' THEN
      CALL _ADVPL_set_property(m_sical,"ENABLE",l_status)
   ELSE
      CALL _ADVPL_set_property(m_sical,"ENABLE",FALSE)
   END IF
   
   CALL _ADVPL_set_property(m_logix,"ENABLE",l_status)
      
END FUNCTION

#---------------------------#
FUNCTION pol1391_item_find()#
#---------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1391_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","de_para_produto","produto")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","de_para_produto","cod_sical","Item sical",1 {CHAR},15,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","de_para_produto","cod_logix","Item logix",1 {CHAR},15,0,"zoom_item")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1391_item_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#----------------------------------------------------#
FUNCTION pol1391_item_create_cursor(l_where, l_order)#
#----------------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)
    DEFINE l_ind        INTEGER

    IF l_order IS NULL THEN
       LET l_order = " cod_sical "
    END IF
    
    LET l_sql_stmt = 
        "SELECT cod_sical, cod_logix ",
        " FROM de_para_produto ",
        " WHERE ",l_where CLIPPED,
        " AND cod_empresa = '",p_cod_empresa,"' ",
        " ORDER BY ",l_order
   
   CALL pol1391_item_exibe(l_sql_stmt)
   
END FUNCTION

#--------------------------------------#
FUNCTION pol1391_item_exibe(l_sql_stmt)#
#--------------------------------------#
   
   DEFINE l_sql_stmt   CHAR(2000),
          l_ind        INTEGER

   CALL _ADVPL_set_property(m_brz_item,"CLEAR")
   CALL _ADVPL_set_property(m_brz_item,"EDITABLE",FALSE)
   LET m_car_item = TRUE
   INITIALIZE ma_item TO NULL
   LET l_ind = 1
   
    PREPARE var_item FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","de_para_produto")
       RETURN FALSE
    END IF

   DECLARE cq_item CURSOR FOR var_item
   
   FOREACH cq_item INTO 
      ma_item[l_ind].cod_sical,
      ma_item[l_ind].cod_logix
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','cq_item:01')
         EXIT FOREACH
      END IF

      IF NOT pol1391_le_item(ma_item[l_ind].cod_logix) THEN
         RETURN FALSE
      END IF
   
      LET ma_item[l_ind].den_item = m_den_item
            
      LET l_ind = l_ind + 1
      
      IF l_ind > 200 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   IF l_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_item,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'Não há registros para os parâmetros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   LET m_car_item = FALSE
        
END FUNCTION

#----------------------------------#
FUNCTION pol1391_item_valid_sical()#
#----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_item.cod_sical IS NULL THEN
      LET m_msg = 'Informe o item sical.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_sical,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   IF NOT pol1391_ve_duplicidade() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_sical,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
FUNCTION pol1391_ve_duplicidade()#
#--------------------------------#

   SELECT 1 FROM de_para_produto
    WHERE cod_empresa = p_cod_empresa
      AND cod_sical = mr_item.cod_sical
   
   IF STATUS = 0 THEN
      LET m_msg = 'Item sical já cadastrado.'
   ELSE
      IF STATUS = 100 THEN
         RETURN TRUE
      ELSE
         CALL log003_err_sql('SELECT','de_para_produto')
         LET m_msg = 'Erro ',STATUS, ' Lendo tabela de_para_produto '
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION         
   
#---------------------------#
FUNCTION pol1391_zoom_item()#
#---------------------------#

    DEFINE l_codigo         LIKE item.cod_item,
           l_descri         LIKE item.den_item,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_item IS NULL THEN
       LET m_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_item,"ZOOM","zoom_item")
    END IF

    #LET l_where_clause = " item.cod_empresa = '",p_cod_empresa,"' "
    #CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_item,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")
    LET l_descri = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","den_item")

    IF l_codigo IS NOT NULL THEN
       LET mr_item.cod_logix = l_codigo
       LET mr_item.den_item = l_descri
    END IF        
    
END FUNCTION

#----------------------------#
FUNCTION pol1391_valid_item()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_item.cod_logix IS NULL THEN
      LET m_msg = 'Informe o item logix.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT pol1391_le_item(mr_item.cod_logix) THEN
      RETURN FALSE
   END IF
   
   LET mr_item.den_item = m_den_item
   
   IF mr_item.cod_sical IS NULL THEN
      CALL _ADVPL_set_property(m_sical,"GET_FOCUS")
   END IF

   RETURN TRUE
   
END FUNCTION   

#------------------------------#   
FUNCTION pol1391_le_item(l_cod)#
#------------------------------#
   DEFINE l_cod       CHAR(15)
   
   SELECT den_item
     INTO m_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION    

#-----------------------------#
FUNCTION pol1391_item_insert()#
#-----------------------------#

   LET m_opcao = 'I'
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_item.* TO NULL
   CALL pol1391_desativa_folder("1")
   LET m_car_item = TRUE
   CALL pol1391_item_ativa(TRUE)
   CALL _ADVPL_set_property(m_sical,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1391_item_insert_canc()#
#----------------------------------#

   CALL pol1391_item_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1391_ativa_folder()
   INITIALIZE mr_item.* TO NULL
   LET m_car_item = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1391_item_insert_conf()#
#----------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   INSERT INTO de_para_produto
    VALUES(p_cod_empresa, mr_item.cod_sical, mr_item.cod_logix)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','de_para_produto')
      RETURN FALSE
   END IF   
   
   CALL pol1391_item_prepare()
   CALL pol1391_item_ativa(FALSE)
   CALL pol1391_ativa_folder()
   LET m_car_item = FALSE
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1391_item_prepare()#
#------------------------------#

   DEFINE l_sql_stmt CHAR(2000)
   
   LET l_sql_stmt =
    " SELECT cod_sical, cod_logix ",
    "  FROM de_para_produto ",
    " WHERE cod_empresa = '",p_cod_empresa,"' "

   CALL pol1391_item_exibe(l_sql_stmt)

END FUNCTION

#------------------------------#
 FUNCTION pol1391_item_prende()#
#------------------------------#
   
   CALL  LOG_transaction_begin()
   
   DECLARE cq_it_prende CURSOR FOR
    SELECT 1
      FROM de_para_produto
     WHERE cod_empresa =  p_cod_empresa
       AND cod_sical = mr_item.cod_sical
     FOR UPDATE 
    
    OPEN cq_it_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_it_prende")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
    
   FETCH cq_it_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_it_prende")
      CALL log085_transacao("ROLLBACK")
      CLOSE cq_it_prende
      RETURN FALSE
   END IF

END FUNCTION
   
#-----------------------------#
FUNCTION pol1391_item_update()#
#-----------------------------#   
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_item.cod_sical IS NULL THEN
      LET m_msg = 'Selecione previamente um item.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1391_item_prende() THEN
      RETURN FALSE
   END IF
      
   CALL pol1391_item_ativa(TRUE)
   LET m_car_item = TRUE
   CALL _ADVPL_set_property(m_logix,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1391_item_update_canc()#
#----------------------------------#   
   
   CLOSE cq_it_prende
   CALL  LOG_transaction_rollback()
   
   SELECT cod_logix
     INTO mr_item.cod_logix
     FROM de_para_produto
    WHERE cod_empresa = p_cod_empresa
      AND cod_sical = mr_item.cod_sical

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'de_para_produto:iuc')
   ELSE
      CALL pol1391_le_item(mr_item.cod_logix)
      LET mr_item.den_item = m_den_item
   END IF
         
   CALL pol1391_item_ativa(FALSE)
   LET m_car_item = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1391_item_update_conf()#
#----------------------------------#   

   UPDATE de_para_produto 
      SET cod_logix = mr_item.cod_logix
    WHERE cod_empresa = p_cod_empresa
      AND cod_sical = mr_item.cod_sical
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','de_para_produto:iuc')
      RETURN FALSE
   END IF

   CALL LOG_transaction_commit()
   
   CLOSE cq_it_prende
   CALL pol1391_item_ativa(FALSE)
   LET m_car_item = FALSE
   CALL pol1391_item_prepare()   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1391_item_delete()#
#-----------------------------#
   
   DEFINE l_ret   SMALLINT

   IF mr_item.cod_sical IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Selecione om item para excluir.")
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1391_item_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM de_para_produto
    WHERE cod_empresa = p_cod_empresa
      AND cod_sical = mr_item.cod_sical

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','de_para_produto:id')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_item.* TO NULL
   ELSE
      CALL LOG_transaction_commit()     
   END IF
   
   CLOSE cq_it_prende
   CALL pol1391_item_prepare()
   
   RETURN l_ret
        
END FUNCTION




#---Rotinas de-para oper ----#

#------------------------------#
FUNCTION pol1391_oper(l_fpanel)#
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
    CALL _ADVPL_set_property(l_find,"EVENT","pol1391_oper_find")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1391_oper_insert")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1391_oper_insert_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1391_oper_insert_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1391_oper_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1391_oper_update_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1391_oper_update_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1391_oper_delete")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1391_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1391_oper_campo(l_panel)
    CALL pol1391_oper_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1391_oper_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_oper = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_oper,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_oper,"HEIGHT",40)
    #CALL _ADVPL_set_property(m_pan_oper,"BACKGROUND_COLOR",225,232,232) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_oper)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","tip pedido:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_tip_pedido = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_oper)
    CALL _ADVPL_set_property(m_tip_pedido,"POSITION",70,10)
    CALL _ADVPL_set_property(m_tip_pedido,"ADD_ITEM","1","Venda")     
    CALL _ADVPL_set_property(m_tip_pedido,"ADD_ITEM","2","Bonificação")     
    CALL _ADVPL_set_property(m_tip_pedido,"ADD_ITEM","3","Doação")     
    CALL _ADVPL_set_property(m_tip_pedido,"VARIABLE",mr_oper,"tip_pedido")    
              
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_oper)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",190,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Entrega futura:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_entrega = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_oper)
    CALL _ADVPL_set_property(m_entrega,"POSITION",280,10)
    CALL _ADVPL_set_property(m_entrega,"ADD_ITEM","0","Não")     
    CALL _ADVPL_set_property(m_entrega,"ADD_ITEM","1","Sim")     
    CALL _ADVPL_set_property(m_entrega,"VARIABLE",mr_oper,"entrega_furura")    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_oper)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",350,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Operação venda:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_nat_venda = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_oper)     
    CALL _ADVPL_set_property(m_nat_venda,"POSITION",440,10) 
    CALL _ADVPL_set_property(m_nat_venda,"LENGTH",5)    
    CALL _ADVPL_set_property(m_nat_venda,"VARIABLE",mr_oper,"cod_nat_venda")
    CALL _ADVPL_set_property(m_nat_venda,"VALID","pol1391_valid_oper_venda")    

    LET m_lupa_operv = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_oper)
    CALL _ADVPL_set_property(m_lupa_operv,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_operv,"POSITION",490,10)     
    CALL _ADVPL_set_property(m_lupa_operv,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_operv,"CLICK_EVENT","pol1391_zoom_oper_venda")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_oper)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",530,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_oper,"den_nat_venda")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_oper)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",810,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Operação remessa:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_nat_remessa = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_oper)     
    CALL _ADVPL_set_property(m_nat_remessa,"POSITION",910,10) 
    CALL _ADVPL_set_property(m_nat_remessa,"LENGTH",5)    
    CALL _ADVPL_set_property(m_nat_remessa,"VARIABLE",mr_oper,"cod_nat_remessa")
    CALL _ADVPL_set_property(m_nat_remessa,"VALID","pol1391_valid_oper_remessa")    

    LET m_lupa_operr = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_oper)
    CALL _ADVPL_set_property(m_lupa_operr,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_operr,"POSITION",960,10)     
    CALL _ADVPL_set_property(m_lupa_operr,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_operr,"CLICK_EVENT","pol1391_zoom_oper_remessa")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_oper)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",990,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_oper,"den_nat_remessa")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    CALL _ADVPL_set_property(m_pan_oper,"ENABLE",FALSE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1391_oper_grade(l_container)#
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
   
    LET m_brz_oper = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_oper,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_oper,"BEFORE_ROW_EVENT","pol1391_oper_before_row")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_oper)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","tip_pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_oper)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Entrega futura")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","entrega_furura")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_oper)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Oper venda")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_nat_venda")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_oper)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_nat_venda")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_oper)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Oper remessa")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_nat_remessa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_oper)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_nat_remessa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_oper)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_oper,"SET_ROWS",ma_oper,1)
    CALL _ADVPL_set_property(m_brz_oper,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_oper,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_oper,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#---------------------------------#
FUNCTION pol1391_oper_before_row()#
#---------------------------------#
   
   DEFINE l_linha          INTEGER
   
   IF m_car_oper THEN
      RETURN TRUE
   END IF
      
   LET l_linha = _ADVPL_get_property(m_brz_oper,"ROW_SELECTED")
   
   IF l_linha = 0 OR l_linha IS NULL THEN
      RETURN TRUE
   END IF
   
   LET mr_oper.tip_pedido = ma_oper[l_linha].tip_pedido
   LET mr_oper.entrega_furura = ma_oper[l_linha].entrega_furura
   LET mr_oper.cod_nat_venda = ma_oper[l_linha].cod_nat_venda
   LET mr_oper.cod_nat_remessa = ma_oper[l_linha].cod_nat_remessa
   LET mr_oper.den_nat_venda = pol1391_le_oper(mr_oper.cod_nat_venda)

   IF mr_oper.cod_nat_remessa IS NOT NULL THEN
      LET mr_oper.den_nat_remessa = pol1391_le_oper(mr_oper.cod_nat_remessa)
   ELSE
      LET mr_oper.den_nat_remessa = NULL
   END IF
   
   CALL pol1391_oper_ativa(TRUE)
   CALL _ADVPL_set_property(m_nat_venda,"GET_FOCUS")
   CALL pol1391_oper_ativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1391_oper_ativa(l_status)#
#------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pan_oper,"ENABLE",l_status)
   
   IF m_op_oper = 'I' THEN
      CALL _ADVPL_set_property(m_tip_pedido,"ENABLE",l_status)
      CALL _ADVPL_set_property(m_entrega,"ENABLE",l_status)
   ELSE
      CALL _ADVPL_set_property(m_tip_pedido,"ENABLE",FALSE)
      CALL _ADVPL_set_property(m_entrega,"ENABLE",FALSE)
   END IF
   
   CALL _ADVPL_set_property(m_nat_venda,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_nat_remessa,"ENABLE",l_status)
      
END FUNCTION

#---------------------------#
FUNCTION pol1391_oper_find()#
#---------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1391_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","nat_oper_sical","Operacao")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","nat_oper_sical","tip_pedido","Tipo pedido",1 {CHAR},1,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","nat_oper_sical","entrega_furura","Entrega furura",1 {CHAR},1,0,"zoom_item")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1391_oper_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#----------------------------------------------------#
FUNCTION pol1391_oper_create_cursor(l_where, l_order)#
#----------------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)
    DEFINE l_ind        INTEGER

    IF l_order IS NULL THEN
       LET l_order = " tip_pedido "
    END IF
    
    LET l_sql_stmt = 
        "SELECT tip_pedido, entrega_furura, cod_nat_venda, ",
        " cod_nat_remessa FROM nat_oper_sical ",
        " WHERE ",l_where CLIPPED,
        " ORDER BY ",l_order
   
   CALL pol1391_oper_exibe(l_sql_stmt)
   
END FUNCTION

#--------------------------------------#
FUNCTION pol1391_oper_exibe(l_sql_stmt)#
#--------------------------------------#
   
   DEFINE l_sql_stmt   CHAR(2000),
          l_ind        INTEGER

   CALL _ADVPL_set_property(m_brz_oper,"CLEAR")
   CALL _ADVPL_set_property(m_brz_oper,"EDITABLE",FALSE)
   LET m_car_oper = TRUE
   INITIALIZE ma_oper TO NULL
   LET l_ind = 1
   
    PREPARE var_oper FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","nat_oper_sical")
       RETURN FALSE
    END IF

   DECLARE cq_oper CURSOR FOR var_oper
   
   FOREACH cq_oper INTO 
      ma_oper[l_ind].tip_pedido,
      ma_oper[l_ind].entrega_furura,
      ma_oper[l_ind].cod_nat_venda,
      ma_oper[l_ind].cod_nat_remessa
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','cq_oper:01')
         EXIT FOREACH
      END IF
      
      LET ma_oper[l_ind].den_nat_venda = pol1391_le_oper(ma_oper[l_ind].cod_nat_venda)
      
      IF ma_oper[l_ind].cod_nat_remessa IS NOT NULL THEN
         LET mr_oper.den_nat_remessa = pol1391_le_oper(ma_oper[l_ind].cod_nat_remessa)
      ELSE
         LET mr_oper.den_nat_remessa = NULL
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
      CALL _ADVPL_set_property(m_brz_oper,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'Não há registros para os parâmetros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   LET m_car_oper = FALSE
        
END FUNCTION

#------------------------------#
FUNCTION pol1391_le_oper(l_cod)#
#------------------------------#
   
   DEFINE l_cod          integer,
          l_desc         CHAR(30)
   
   SELECT den_nat_oper
     INTO l_desc
     FROM nat_operacao
    WHERE cod_nat_oper = l_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','nat_operacao')
      LET l_desc = NULL
   END IF
   
   RETURN l_desc

END FUNCTION         
     
#-------------------------------#
FUNCTION pol1391_oper_duplicou()#
#-------------------------------#

   SELECT 1 FROM nat_oper_sical
    WHERE 1 = 1
      AND tip_pedido = mr_oper.tip_pedido
      AND entrega_furura = mr_oper.entrega_furura
   
   IF STATUS = 0 THEN
      LET m_msg = 'Tipo/entrega já cadastrados.'
   ELSE
      IF STATUS = 100 THEN
         RETURN FALSE
      ELSE
         CALL log003_err_sql('SELECT','nat_oper_sical')
         LET m_msg = 'Erro ',STATUS, ' Lendo tabela nat_oper_sical '
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION         
   
#---------------------------------#
FUNCTION pol1391_zoom_oper_venda()#
#---------------------------------#

    DEFINE l_codigo         LIKE nat_operacao.cod_nat_oper,
           l_descri         LIKE nat_operacao.den_nat_oper,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_operv IS NULL THEN
       LET m_zoom_operv = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_operv,"ZOOM","zoom_nat_operacao")
    END IF

    CALL _ADVPL_get_property(m_zoom_operv,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_operv,"RETURN_BY_TABLE_COLUMN","nat_operacao","cod_nat_oper")
    LET l_descri = _ADVPL_get_property(m_zoom_operv,"RETURN_BY_TABLE_COLUMN","nat_operacao","den_nat_oper")

    IF l_codigo IS NOT NULL THEN
       LET mr_oper.cod_nat_venda = l_codigo
       LET mr_oper.den_nat_venda = l_descri
    END IF        
    
    CALL _ADVPL_set_property(m_nat_venda,"GET_FOCUS")
    
END FUNCTION

#-----------------------------------#
FUNCTION pol1391_zoom_oper_remessa()#
#-----------------------------------#

    DEFINE l_codigo         LIKE nat_operacao.cod_nat_oper,
           l_descri         LIKE nat_operacao.den_nat_oper,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_operr IS NULL THEN
       LET m_zoom_operr = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_operr,"ZOOM","zoom_nat_operacao")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_operr,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_operr,"RETURN_BY_TABLE_COLUMN","nat_operacao","cod_nat_oper")
    LET l_descri = _ADVPL_get_property(m_zoom_operr,"RETURN_BY_TABLE_COLUMN","nat_operacao","den_nat_oper")

    IF l_codigo IS NOT NULL THEN
       LET mr_oper.cod_nat_remessa = l_codigo
       LET mr_oper.den_nat_remessa = l_descri
    END IF        
    
    CALL _ADVPL_set_property(m_nat_remessa,"GET_FOCUS")
    
END FUNCTION

#----------------------------------#
FUNCTION pol1391_valid_oper_venda()#
#----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_oper.cod_nat_venda IS NULL THEN
      LET m_msg = 'Informe natureza de operação de venda.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET mr_oper.den_nat_venda = pol1391_le_oper(mr_oper.cod_nat_venda)

   IF mr_oper.den_nat_venda IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION   

#------------------------------------#
FUNCTION pol1391_valid_oper_remessa()#
#------------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_oper.entrega_furura = '0' THEN
      LET mr_oper.cod_nat_remessa = NULL
      LET mr_oper.den_nat_remessa = NULL
      RETURN TRUE
   END IF
   
   IF mr_oper.cod_nat_remessa IS NULL THEN
      LET m_msg = 'Informe natureza de operação de remessa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET mr_oper.den_nat_remessa = pol1391_le_oper(mr_oper.cod_nat_remessa)

   IF mr_oper.den_nat_remessa IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   IF mr_oper.cod_nat_venda IS NULL THEN
      CALL _ADVPL_set_property(m_nat_venda,"GET_FOCUS")
   END IF

   RETURN TRUE
   
END FUNCTION   

#-----------------------------#
FUNCTION pol1391_oper_insert()#
#-----------------------------#

   LET m_op_oper = 'I'
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_oper.* TO NULL
   CALL pol1391_desativa_folder("2")
   LET m_car_oper = TRUE
   CALL pol1391_oper_ativa(TRUE)
   CALL _ADVPL_set_property(m_tip_pedido,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1391_oper_insert_canc()#
#----------------------------------#

   CALL pol1391_oper_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1391_ativa_folder()
   INITIALIZE mr_oper.* TO NULL
   LET m_car_oper = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1391_oper_insert_conf()#
#----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF pol1391_oper_duplicou() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   INSERT INTO nat_oper_sical
    VALUES(mr_oper.tip_pedido,
           mr_oper.entrega_furura,
           mr_oper.cod_nat_venda,
           mr_oper.cod_nat_remessa)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','nat_oper_sical')
      RETURN FALSE
   END IF   
   
   CALL pol1391_oper_prepare()
   CALL pol1391_oper_ativa(FALSE)
   CALL pol1391_ativa_folder()
   LET m_car_oper = FALSE
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1391_oper_prepare()#
#------------------------------#

   DEFINE l_sql_stmt CHAR(2000)

   LET l_sql_stmt = 
        "SELECT tip_pedido, entrega_furura, cod_nat_venda, ",
        " cod_nat_remessa FROM nat_oper_sical ",
        " ORDER BY tip_pedido, entrega_furura"
   
   CALL pol1391_oper_exibe(l_sql_stmt)

END FUNCTION

#------------------------------#
 FUNCTION pol1391_oper_prende()#
#------------------------------#
   
   CALL  LOG_transaction_begin()
   
   DECLARE cq_oper_prende CURSOR FOR
    SELECT 1
      FROM nat_oper_sical
     WHERE 1 = 1
       AND tip_pedido = mr_oper.tip_pedido
       AND entrega_furura = mr_oper.entrega_furura
     FOR UPDATE 
    
    OPEN cq_oper_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_oper_prende")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
    
   FETCH cq_oper_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_oper_prende")
      CALL log085_transacao("ROLLBACK")
      CLOSE cq_it_prende
      RETURN FALSE
   END IF

END FUNCTION
   
#-----------------------------#
FUNCTION pol1391_oper_update()#
#-----------------------------#   
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_oper.tip_pedido IS NULL THEN
      LET m_msg = 'Selecione previamente um registro.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1391_oper_prende() THEN
      RETURN FALSE
   END IF
   
   LET m_op_oper = 'U'
   CALL pol1391_oper_ativa(TRUE)
   LET m_car_oper = TRUE
   CALL _ADVPL_set_property(m_nat_venda,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1391_oper_update_canc()#
#----------------------------------#   
   
   CLOSE cq_oper_prende
   CALL  LOG_transaction_rollback()
   
   SELECT cod_nat_venda, 
          cod_nat_remessa
     INTO mr_oper.cod_nat_venda, 
          mr_oper.cod_nat_remessa
     FROM nat_oper_sical
    WHERE 1 = 1
      AND tip_pedido = mr_oper.tip_pedido
      AND entrega_furura = mr_oper.entrega_furura

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'nat_oper_sical:ouc')
   ELSE
      LET mr_oper.den_nat_venda = pol1391_le_oper(mr_oper.cod_nat_venda)
      IF mr_oper.cod_nat_remessa IS NOT NULL THEN
         LET mr_oper.den_nat_remessa = pol1391_le_oper(mr_oper.cod_nat_remessa)
      ELSE
         LET mr_oper.den_nat_remessa = NULL
      END IF
   END IF
         
   CALL pol1391_oper_ativa(FALSE)
   LET m_car_oper = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1391_oper_update_conf()#
#----------------------------------#   

   UPDATE nat_oper_sical 
      SET cod_nat_venda = mr_oper.cod_nat_venda,
          cod_nat_remessa = mr_oper.cod_nat_remessa
    WHERE 1 = 1
      AND tip_pedido = mr_oper.tip_pedido
      AND entrega_furura = mr_oper.entrega_furura
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','nat_oper_sical:ouc')
      RETURN FALSE
   END IF

   CALL LOG_transaction_commit()
   
   CLOSE cq_oper_prende
   CALL pol1391_oper_ativa(FALSE)
   LET m_car_oper = FALSE
   CALL pol1391_oper_prepare()   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1391_oper_delete()#
#-----------------------------#
   
   DEFINE l_ret   SMALLINT

   IF mr_oper.tip_pedido IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Selecione um registro para excluir.")
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1391_oper_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM nat_oper_sical
    WHERE 1 = 1
      AND tip_pedido = mr_oper.tip_pedido
      AND entrega_furura = mr_oper.entrega_furura

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','nat_oper_sical:od')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_oper.* TO NULL
   ELSE
      CALL LOG_transaction_commit()     
   END IF
   
   CLOSE cq_oper_prende
   CALL pol1391_oper_prepare()
   
   RETURN l_ret
        
END FUNCTION
