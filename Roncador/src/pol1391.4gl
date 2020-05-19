#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1391                                                 #
# OBJETIVO: CADASTRO DE ENDERE�OS DO ITEM                           #
# AUTOR...: IVO                                                     #
# DATA....: 18/05/2020                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
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
       
DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_carregando      SMALLINT,
       m_ind             INTEGER,
       m_lin_atu         INTEGER
                     
DEFINE m_zoom_item       VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_sical           VARCHAR(10),
       m_logix           VARCHAR(10)

DEFINE mr_item          RECORD
       cod_sical        LIKE item.cod_item,
       cod_logix        LIKE item.cod_item,
       den_item         LIKE item.den_item
END RECORD

DEFINE ma_item          ARRAY[20] OF RECORD
       cod_sical        LIKE item.cod_item,
       cod_logix        LIKE item.cod_item,
       den_item         LIKE item.den_item,
       filler           CHAR(01)
END RECORD
       
DEFINE m_cod_item       VARCHAR(10),
       m_new_item       VARCHAR(10)

DEFINE m_info_item      SMALLINT
             
#-----------------#
FUNCTION pol1391()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1391-12.00.00  "
   CALL func002_versao_prg(p_versao)
   
   LET m_carregando = TRUE
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

    LET l_titulo = 'CADASTRO DE ENDERE�OS DO ITEM - ',p_versao
    
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
    CALL _ADVPL_set_property(m_fold_item,"TITLE","Item")
		CALL pol1391_item(m_fold_item)
    
    # FOLDER cnd pgto 

    LET m_fold_pgto = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_pgto,"TITLE","Cond pgto")
    #CALL pol1391_pgto(m_fold_pgto)

    # FOLDER nat oper 

    LET m_fold_oper = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_oper,"TITLE","Nat opera��o")
    #CALL pol1391_oper(m_fold_oper)

    # FOLDER erros

    LET m_fold_erro = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_erro,"TITLE","Nat opera��o")
    #CALL pol1391_erro(m_fold_erro)

    #CALL _ADVPL_set_property(m_folder,"FOLDER_SELECTED",1)
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION
   
#------------------------#
FUNCTION pol1391_fechar()#
#------------------------#

   RETURN TRUE
   
END FUNCTION


#---item ----#

#------------------------------#
FUNCTION pol1391_item(l_fpanel)#
#------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_inform    VARCHAR(10),
           l_update    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10),
           l_create    VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1391_item_find")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1391_item_find_conf")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1391_item_find_canc")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1391_item_insert")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1391_item_insert_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1391_item_insert_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1372_item_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1372_item_update_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1372_item_update_canc")

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
    CALL _ADVPL_set_property(m_sical,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(m_sical,"VARIABLE",mr_item,"cod_sical")
    CALL _ADVPL_set_property(m_sical,"VALID","pol1391_valid_sical")        
              
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_item)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",230,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Item logix:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_logix = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_item)     
    CALL _ADVPL_set_property(m_logix,"POSITION",300,10) 
    CALL _ADVPL_set_property(m_logix,"LENGTH",15,0)    
    CALL _ADVPL_set_property(m_logix,"VARIABLE",mr_item,"cod_logix")
    CALL _ADVPL_set_property(m_logix,"VALID","pol1391_valid_item")    

    LET m_lupa_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_item)
    CALL _ADVPL_set_property(m_lupa_item,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_item,"POSITION",420,10)     
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
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Lote")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",250)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_item,"SET_ROWS",ma_item,1)
    CALL _ADVPL_set_property(m_brz_item,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_item,"CAN_REMOVE_ROW",FALSE)
   
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
      
END FUNCTION

#-----------------------------#
FUNCTION pol1391_valid_sical()#
#-----------------------------#
   
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
      LET m_msg = 'Item sical j� cadastrado.'
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

    LET l_where_clause = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
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
   
   IF NOT pol1391_le_item() THEN
      RETURN FALSE
   END IF

   IF NOT pol1391_le_item() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#-------------------------#   
FUNCTION pol1391_le_item()#
#-------------------------#

   SELECT den_item
     INTO mr_item.den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_item.cod_logix

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION    

#-----------------------------#
FUNCTION pol1391_item_insert()#
#-----------------------------#

   CALL pol1391_item_ativa(TRUE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_item.* TO NULL
   CALL pol1391_desativa_folder("1")
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
   
   CALL pol1391_itens_carrega()
   CALL pol1391_item_ativa(FALSE)
   CALL pol1391_ativa_folder()
   
   RETURN TRUE

END FUNCTION

#-----------------------------------------#
FUNCTION pol1391_desativa_folder(l_folder)#
#-----------------------------------------#

   DEFINE l_folder             CHAR(01)
             
   CASE l_folder
        WHEN '1' 
           CALL _ADVPL_set_property(m_fold_oper,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_pgto,"ENABLE",FALSE)        
           CALL _ADVPL_set_property(m_fold_erro,"ENABLE",FALSE)        
        WHEN '2' 
           CALL _ADVPL_set_property(m_fold_oper,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_item,"ENABLE",FALSE)   
           CALL _ADVPL_set_property(m_fold_erro,"ENABLE",FALSE)      
        WHEN '3' 
           CALL _ADVPL_set_property(m_fold_apto,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_item,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_erro,"ENABLE",FALSE) 
        WHEN '4' 
           CALL _ADVPL_set_property(m_fold_apto,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_item,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_item,"ENABLE",FALSE) 
   END CASE
   
END FUNCTION

#------------------------------#
FUNCTION pol1391_ativa_folder()#
#------------------------------#

   CALL _ADVPL_set_property(m_fold_item,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_pgto,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_oper,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_erro,"ENABLE",TRUE) 

END FUNCTION

#-------------------------------#
FUNCTION pol1391_itens_carrega()#
#-------------------------------#

   CALL _ADVPL_set_property(m_brz_linha,"CLEAR")

   LET m_carregando = TRUE
   LET mr_linha.cod_linha = NULL
   INITIALIZE ma_linha TO NULL
   LET m_ind = 1
   
   DECLARE cq_le_lin CURSOR FOR
    SELECT cod_linha
      FROM linha_547
     WHERE cod_empresa = p_cod_empresa
   
   FOREACH cq_le_lin INTO ma_linha[m_ind].cod_linha
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','linha_547:cq_le_lin')
         EXIT FOREACH
      END IF
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 500 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   IF m_ind > 1 THEN
      LET m_ind = m_ind - 1
      CALL _ADVPL_set_property(m_brz_linha,"ITEM_COUNT", m_ind)
   END IF

   LET m_carregando = FALSE
   
END FUNCTION

{   
#---------------------------#
FUNCTION pol1391_item_find()#
#---------------------------#

   CALL _ADVPL_set_property(m_pan_item,"ENABLE",TRUE)
   INITIALIZE mr_item.* TO NULL
   CALL pol1391_item_ativa(TRUE)
   LET m_info_item = FALSE   
   CALL pol1391_desativa_folder("1")
   CALL _ADVPL_set_property(m_cod_item,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1391_item_find_canc()#
#--------------------------------#

   CALL _ADVPL_set_property(m_pan_item,"ENABLE",FALSE)
   INITIALIZE mr_item.* TO NULL
   CALL pol1391_item_ativa(FALSE)
   CALL pol1391_ativa_folder()
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1391_item_find_conf()#
#--------------------------------#

   CALL pol1391_item_ativa(FALSE)
   LET m_info_item = TRUE

   IF NOT pol1391_le_estoq() THEN
      RETURN FALSE
   END IF
      
   CALL pol1391_ativa_folder()      
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1391_le_estoq()#
#--------------------------#
   
   DEFINE l_ind    INTEGER
   
   INITIALIZE ma_item TO NULL
   LET l_ind = 1
   
   DECLARE cq_estoq CURSOR FOR
    SELECT cod_item,
           cod_item,
           num_lote,
           qtd_saldo,
           ies_situa_qtd
      FROM estoque_lote
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = mr_item.cod_item
       AND qtd_saldo > 0

   FOREACH cq_estoq INTO 
      ma_item[l_ind].cod_item,
      ma_item[l_ind].cod_item,
      ma_item[l_ind].num_lote,
      ma_item[l_ind].qtd_saldo,
      ma_item[l_ind].ies_situa_qtd

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','estoque_lote:cq_estoq')
         RETURN FALSE
      END IF
      
      LET l_ind = l_ind + 1
   
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   CALL _ADVPL_set_property(m_brz_item,"SET_ROWS",ma_item,l_ind)
    
   RETURN TRUE

END FUNCTION   
 
    
      


#-----------------------------#
FUNCTION pol1372_item_update()#
#-----------------------------#   
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT m_info_item THEN
      LET m_msg = 'Informe o item previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   INITIALIZE mr_item.new_item, mr_item.new_desc TO NULL
   CALL pol1391_item_ativa(TRUE)
   CALL _ADVPL_set_property(m_new_item,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1372_item_update_canc()#
#----------------------------------#   

   INITIALIZE mr_item.new_item, mr_item.new_desc TO NULL
   CALL pol1391_item_ativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1372_item_update_conf()#
#----------------------------------#   

   CALL pol1391_item_ativa(FALSE)
   
   CALL LOG_transaction_begin()
   
   IF NOT pol1391_grava_item() THEN
      CALL  LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1391_grava_item()#
#-----------------------------#
   
   UPDATE item 
      SET cod_item_estoq = mr_item.new_item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_item.cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
      
   SELECT 1 FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_item.new_item
   
   IF STATUS = 0 THEN
   ELSE
      IF STATUS = 100 THEN
         IF NOT pol1391_ins_item() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('SELECT','item')
         RETURN FALSE
      END IF
   END IF   
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1391_ins_item()#
#---------------------------#

   INSERT INTO item
    VALUES(p_cod_empresa,
           mr_item.new_item,
           mr_item.new_desc,0)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','item')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
           


          