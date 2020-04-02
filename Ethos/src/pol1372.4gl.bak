#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1372                                                 #
# OBJETIVO: CADASTRO DE ITENS CLIENTE P/ EDI                        #
# AUTOR...: IVO                                                     #
# DATA....: 07/06/19                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_cod_empresa_plano   LIKE empresa.cod_empresa

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_panel           VARCHAR(10),
       m_pan_arq         VARCHAR(10),
       m_cliente         VARCHAR(10),
       m_zoom_cliente    VARCHAR(10),
       m_lupa_cliente    VARCHAR(10),
       m_item            VARCHAR(10),
       m_den_item        VARCHAR(10),
       m_zoom_item       VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_cli_item        VARCHAR(10),
       m_den_it_cli      VARCHAR(10),
       m_zoom_it_cli     VARCHAR(10),
       m_construct       VARCHAR(10),
       m_pedido          VARCHAR(10),
       m_lupa_pedido     VARCHAR(10),
       m_brz_itens       VARCHAR(10),
       m_dlg_arquivo     VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_den_cliente     CHAR(36),
       m_id_registro     INTEGER,
       m_id_registroa    INTEGER,
       m_cod_item        CHAR(15)
       
DEFINE mr_cabec          RECORD
       cod_cliente       LIKE clientes.cod_cliente,
       nom_cliente       LIKE clientes.nom_cliente,
       cod_it_cli        LIKE cliente_item.cod_item_cliente,
       den_it_cli        LIKE item.den_item,
       num_pedido        LIKE pedidos.num_pedido,
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item,
       num_ped_compra    LIKE pedidos.num_pedido_cli
END RECORD

DEFINE ma_itens          ARRAY[2000] OF RECORD
       cod_cliente       CHAR(15),
       nom_cliente       CHAR(36),
       num_pedido        INTEGER,
       cod_item          CHAR(15),
       den_item          CHAR(40),
       item_cliente      CHAR(30),
       mensagem          CHAR(100)
END RECORD

DEFINE ma_files ARRAY[50] OF CHAR(100)

DEFINE mr_arquivo             RECORD
       nom_arquivo            CHAR(100)
END RECORD

DEFINE m_sel_arquivo          VARCHAR(10)

DEFINE m_caminho         CHAR(80),
       m_ies_ambiente    CHAR(01),
       m_comando         CHAR(100),
       m_qtd_arq         INTEGER,
       m_posi_arq        INTEGER,
       m_arq_arigem      CHAR(100),
       m_registro        CHAR(80),
       m_ies_sel         SMALLINT,
       m_ies_import      SMALLINT,
       m_ind             INTEGER,
       m_pos_ini         INTEGER,
       m_reg_bom         INTEGER,
       m_reg_mal         INTEGER
       
#-----------------#
FUNCTION pol1372()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1372-12.00.00  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1372_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1372_menu()#
#----------------------#

    DEFINE l_menubar,
           l_panel,
           l_create,
           l_update,
           l_find,
           l_first,
           l_previous,
           l_next,
           l_last,
           l_delete,
           l_proces,
           l_importar  VARCHAR(10),
           l_titulo    CHAR(80)

    LET l_titulo = 'CADASTRO DE ITENS/CLIENTES P/ EDI - ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1372_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1372_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1372_create_cancel")
    
    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1372_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1372_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1372_update_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1372_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1372_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1372_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1372_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1372_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1372_delete")

    LET l_importar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_importar,"IMAGE","IMPORTAR_ARQUIVO")     
    CALL _ADVPL_set_property(l_importar,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_importar,"TOOLTIP","Importar itens de arquivo CSV")
    CALL _ADVPL_set_property(l_importar,"EVENT","pol1372_importar")
    CALL _ADVPL_set_property(l_importar,"CONFIRM_EVENT","pol1372_imp_conf")
    CALL _ADVPL_set_property(l_importar,"CANCEL_EVENT","pol1372_imp_cancel")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1372_cabec(l_panel)
    CALL pol1372_itens(l_panel)

    CALL pol1372_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------#
FUNCTION pol1372_cabec(l_container)#
#----------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_ok              VARCHAR(10),
           l_descricao       VARCHAR(10),
           l_confirm         VARCHAR(10),
           l_menubar         VARCHAR(10)

    LET m_pan_arq = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_arq,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_arq,"HEIGHT",70)
    CALL _ADVPL_set_property(m_pan_arq,"BACKGROUND_COLOR",231,231,237)
    CALL _ADVPL_set_property(m_pan_arq,"VISIBLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_arq)
    CALL _ADVPL_set_property(l_label,"POSITION",20,20)     
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    

    LET m_sel_arquivo = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_arq)     
    CALL _ADVPL_set_property(m_sel_arquivo,"POSITION",100,20)     
    CALL _ADVPL_set_property(m_sel_arquivo,"CHANGE_EVENT","pol1372_imp_arquivo") 
    CALL _ADVPL_set_property(m_sel_arquivo,"VARIABLE",mr_arquivo,"nom_arquivo")   
         
    LET m_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_panel,"HEIGHT",70)
    CALL _ADVPL_set_property(m_panel,"BACKGROUND_COLOR",231,237,237)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Cod cliente:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(m_cliente,"POSITION",120,10)     
    CALL _ADVPL_set_property(m_cliente,"LENGTH",15)
    CALL _ADVPL_set_property(m_cliente,"VARIABLE",mr_cabec,"cod_cliente")
    CALL _ADVPL_set_property(m_cliente,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cliente,"VALID","pol1372_chec_cliente")
    
    LET m_lupa_cliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_cliente,"POSITION",260,10)     
    CALL _ADVPL_set_property(m_lupa_cliente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cliente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cliente,"CLICK_EVENT","pol1372_cliente_zoom")

    LET l_descricao = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_descricao,"POSITION",300,10)     
    CALL _ADVPL_set_property(l_descricao,"LENGTH",40) 
    CALL _ADVPL_set_property(l_descricao,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_descricao,"VARIABLE",mr_cabec,"nom_cliente")
    CALL _ADVPL_set_property(l_descricao,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",670,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Item cliente:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cli_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(m_cli_item,"POSITION",750,10)     
    CALL _ADVPL_set_property(m_cli_item,"LENGTH",30)
    CALL _ADVPL_set_property(m_cli_item,"VARIABLE",mr_cabec,"cod_it_cli")
    CALL _ADVPL_set_property(m_cli_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cli_item,"VALID","pol1372_chec_it_cliente")

    LET l_descricao = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_descricao,"POSITION",1020,10)     
    CALL _ADVPL_set_property(l_descricao,"LENGTH",30) 
    CALL _ADVPL_set_property(l_descricao,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_descricao,"VARIABLE",mr_cabec,"den_it_cli")
    CALL _ADVPL_set_property(l_descricao,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Item logix:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(m_item,"POSITION",120,40)     
    CALL _ADVPL_set_property(m_item,"LENGTH",15)
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_cabec,"cod_item")
    CALL _ADVPL_set_property(m_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_item,"VALID","pol1372_chec_item")

    LET m_lupa_cliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_cliente,"POSITION",260,40)     
    CALL _ADVPL_set_property(m_lupa_cliente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cliente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cliente,"CLICK_EVENT","pol1372_item_zoom")

    LET l_descricao = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_descricao,"POSITION",300,40)     
    CALL _ADVPL_set_property(l_descricao,"LENGTH",40) 
    CALL _ADVPL_set_property(l_descricao,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_descricao,"VARIABLE",mr_cabec,"den_item")
    CALL _ADVPL_set_property(l_descricao,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",670,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Núm pedido:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_pedido = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_pedido,"POSITION",750,40)     
    CALL _ADVPL_set_property(m_pedido,"LENGTH",10)
    CALL _ADVPL_set_property(m_pedido,"VARIABLE",mr_cabec,"num_pedido")
    CALL _ADVPL_set_property(m_pedido,"VALID","pol1372_chec_pedido")

    LET m_lupa_pedido = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_pedido,"POSITION",850,40)     
    CALL _ADVPL_set_property(m_lupa_pedido,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_pedido,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_pedido,"CLICK_EVENT","pol1372_pedido_zoom")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",890,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Pedido de compra:")    

    LET l_descricao = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_descricao,"POSITION",990,40)     
    CALL _ADVPL_set_property(l_descricao,"LENGTH",25) 
    CALL _ADVPL_set_property(l_descricao,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_descricao,"VARIABLE",mr_cabec,"num_ped_compra")
    CALL _ADVPL_set_property(l_descricao,"CAN_GOT_FOCUS",FALSE)

END FUNCTION

FUNCTION pol1372_on_change()

   CALL log0030_mensagem('pol1372_on_change','info')
   RETURN TRUE

END FUNCTION
   
#----------------------------------#
FUNCTION pol1372_itens(l_container)#
#----------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_itens = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_itens,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_itens)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_itens)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_itens)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_itens)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item logix")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_itens)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_itens)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item ciente")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","item_cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_itens)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    #CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",350)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_brz_itens,"SET_ROWS",ma_itens,1)
    #CALL _ADVPL_set_property(m_brz_itens,"CAN_ADD_ROW",FALSE)
    #CALL _ADVPL_set_property(m_brz_itens,"CAN_REMOVE_ROW",FALSE)

END FUNCTION

#-----------------------------#
FUNCTION pol1372_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1372_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   IF m_opcao = 'M' THEN
      CALL _ADVPL_set_property(m_cliente,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_lupa_cliente,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_cli_item,"EDITABLE",FALSE)
   ELSE
      CALL _ADVPL_set_property(m_cliente,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_lupa_cliente,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_cli_item,"EDITABLE",l_status)
   END IF
   
   CALL _ADVPL_set_property(m_panel,"EDITABLE",l_status)
   
END FUNCTION
   
#------------------------------#
FUNCTION pol1372_cliente_zoom()#
#------------------------------#

    DEFINE l_codigo         LIKE clientes.cod_cliente,
           l_descri         LIKE clientes.nom_cliente,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_cliente IS NULL THEN
       LET m_zoom_cliente = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_cliente,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_cliente,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_descri = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")

    IF l_codigo IS NOT NULL THEN
       LET mr_cabec.cod_cliente = l_codigo
       LET mr_cabec.nom_cliente = l_descri
    END IF        
    
END FUNCTION

#---------------------------#
FUNCTION pol1372_item_zoom()#
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
       LET mr_cabec.cod_item = l_codigo
       LET mr_cabec.den_item = l_descri
    END IF        
    
END FUNCTION

#-----------------------#
FUNCTION pol1372_create()
#-----------------------#
    
    LET m_opcao = 'I'    
    CALL pol1372_limpa_campos()
    CALL pol1372_ativa_desativa(TRUE)
    
    LET m_ies_cons = FALSE
    
    CALL _ADVPL_set_property(m_cliente,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1372_create_confirm()
#-------------------------------#
   
   IF NOT pol1372_chec_cliente() THEN
      RETURN FALSE
   END IF

   IF NOT pol1372_chec_it_cliente() THEN
      RETURN FALSE
   END IF

   IF NOT pol1372_chec_item() THEN
      RETURN FALSE
   END IF

   IF NOT pol1372_chec_pedido() THEN
      RETURN FALSE
   END IF

   LET m_msg = NULL

   IF NOT pol1372_chec_chave_dipl() OR m_msg IS NOT NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
   
   CALL LOG_transaction_begin()
   
   IF NOT pol1372_inserir() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
                  
   CALL pol1372_ativa_desativa(FALSE)

   RETURN TRUE
        
END FUNCTION

#-------------------------------#
FUNCTION pol1372_create_cancel()#
#-------------------------------#

    CALL pol1372_ativa_desativa(FALSE)
    CALL pol1372_limpa_campos()
    
    RETURN TRUE
        
END FUNCTION

#------------------------------#
FUNCTION pol1372_chec_cliente()#
#------------------------------#

   LET m_msg = NULL
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)

   IF mr_cabec.cod_cliente IS NULL THEN
      LET m_msg = 'Informe o cliente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_cliente,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF NOT pol1372_le_cliente() OR m_msg IS NOT NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF 
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1372_chec_it_cliente()#
#---------------------------------#

   LET m_msg = NULL
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)

   IF mr_cabec.cod_it_cli IS NULL THEN
      LET m_msg = 'Informe o item cliente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_cli_item,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF NOT pol1372_le_cli_item() OR m_msg IS NOT NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_cli_item,"GET_FOCUS")
      RETURN FALSE
   END IF 
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1372_chec_item()#
#---------------------------#

   LET m_msg = NULL
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)

   IF mr_cabec.cod_item IS NULL THEN
      LET m_msg = 'Informe o item logix.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_item,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF NOT pol1372_le_item() OR m_msg IS NOT NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_item,"GET_FOCUS")
      RETURN FALSE
   END IF 

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1372_chec_pedido()#
#-----------------------------#

   LET m_msg = NULL
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)

   IF mr_cabec.num_pedido IS NULL OR mr_cabec.num_pedido = 0 THEN
      LET m_msg = 'Informe o pedido logix.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_pedido,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF NOT pol1372_le_pedido() OR m_msg IS NOT NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF 
      
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1372_le_cliente()#
#----------------------------#
   
   SELECT nom_cliente
     INTO mr_cabec.nom_cliente
     FROM clientes
    WHERE cod_cliente = mr_cabec.cod_cliente

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 100 THEN
         LET m_msg = 'Cliente não cadastrado no logix'
      ELSE
         CALL log003_err_sql('SELECT','clientes')
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION    

#-----------------------------#
FUNCTION pol1372_le_cli_item()#
#-----------------------------#
   
   
   LET p_status = FALSE
   
   DECLARE cq_cli_it CURSOR FOR
   SELECT cliente_item.tex_complementar,
          cliente_item.cod_item
     FROM cliente_item, item
    WHERE cliente_item.cod_empresa = p_cod_empresa
      AND cliente_item.cod_cliente_matriz = mr_cabec.cod_cliente
      AND cliente_item.cod_item_cliente = mr_cabec.cod_it_cli 
      AND item.cod_empresa = cliente_item.cod_empresa
      AND item.cod_item = cliente_item.cod_item
      AND item.ies_situacao = 'A'

   FOREACH cq_cli_it INTO mr_cabec.den_it_cli, mr_cabec.cod_item
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cliente_item')
      END IF
      
      LET p_status = TRUE
      EXIT FOREACH
         
   END FOREACH
   
   IF NOT p_status THEN
      LET m_msg = 'Item cliente inválido.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION    

#------------------------------#
FUNCTION pol1372_den_cli_item()#
#------------------------------#

   SELECT tex_complementar
     INTO mr_cabec.den_it_cli
     FROM cliente_item
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente_matriz = mr_cabec.cod_cliente
      AND cod_item_cliente = mr_cabec.cod_it_cli 
      AND cod_item = mr_cabec.cod_item 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cliente_item')
      LET mr_cabec.den_it_cli = NULL
   END IF

END FUNCTION

#-------------------------#
FUNCTION pol1372_le_item()#
#-------------------------#
   
   SELECT den_item
     INTO mr_cabec.den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_cabec.cod_item
      AND ies_situacao = 'A'

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 100 THEN
         LET m_msg = 'Item não cadastrado no logix ou não está ativo.'
      ELSE
         CALL log003_err_sql('SELECT','item')
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION    

#---------------------------#
FUNCTION pol1372_le_pedido()#
#---------------------------#

   SELECT num_pedido_cli
     INTO mr_cabec.num_ped_compra
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = mr_cabec.num_pedido
      AND cod_cliente = mr_cabec.cod_cliente
      AND ies_sit_pedido <> '9'

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 100 THEN
      LET m_msg = 'Pedidonão existe, não é do cliente ou esta inativo.'
      ELSE
         CALL log003_err_sql('SELECT','pedidos')
      END IF
   END IF
      
   RETURN FALSE

END FUNCTION    

#---------------------------------#
FUNCTION pol1372_chec_chave_dipl()#
#---------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   SELECT id_registro
     INTO m_id_registro
     FROM cliente_item_edi_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_cabec.cod_cliente
      AND cod_it_cli = mr_cabec.cod_it_cli

   IF STATUS = 0 THEN
      LET m_msg = 'Cliente/item já cadastrado no POL1372'
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('INSERT','cliente_item_edi_547')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION   
             
#-------------------------#
FUNCTION pol1372_inserir()#
#-------------------------#

   INSERT INTO cliente_item_edi_547(
      cod_empresa, 
      cod_cliente, 
      cod_it_cli,  
      cod_it_logix,
      num_pedido)
   VALUES(p_cod_empresa, 
          mr_cabec.cod_cliente, 
          mr_cabec.cod_it_cli,
          mr_cabec.cod_item, 
          mr_cabec.num_pedido)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','cliente_item_edi_547')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------#
FUNCTION pol1372_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1372_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","cliente_item_edi_547","cliente")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","cliente_item_edi_547","cod_cliente","Cliente",1 {CHAR},15,0,"zoom_cliente")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","cliente_item_edi_547","cod_it_cli","Item cliente",1 {INT},4,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","cliente_item_edi_547","cod_item","Item",1 {CHAR},15,0,"zoom_item")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","cliente_item_edi_547","num_pedido","Pedido",1 {INT},9,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1372_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1372_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " cod_cliente "
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT id_registro ",
                      " FROM cliente_item_edi_547",
                     " WHERE ",l_where CLIPPED,
                       " AND cod_empresa = '",p_cod_empresa,"' ",
                     " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","cliente_item_edi_547")
       RETURN FALSE
    END IF

    DECLARE cq_cons SCROLL CURSOR WITH HOLD FOR var_cons

    IF  STATUS <> 0 THEN
        CALL log003_err_sql("DECLARE CURSOR","cq_cons")
        RETURN FALSE
    END IF

    FREE var_cons

    OPEN cq_cons

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_cons")
       RETURN FALSE
    END IF

    FETCH cq_cons INTO m_id_registro

    IF STATUS <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","cq_cons")
       ELSE
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Argumentos de pesquisa não encontrados.")
       END IF
       CALL pol1372_limpa_campos()
       RETURN FALSE
    END IF
    
    CALL pol1372_exibe_dados() 
    
    LET m_ies_cons = TRUE
    LET m_id_registroa = m_id_registro
    
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1372_exibe_dados()#
#-----------------------------#
   
   LET m_excluiu = FALSE
   
   SELECT cod_cliente,
          cod_it_cli,
          cod_it_logix,
          num_pedido          
     INTO mr_cabec.cod_cliente,
          mr_cabec.cod_it_cli,
          mr_cabec.cod_item,
          mr_cabec.num_pedido
     FROM cliente_item_edi_547
    WHERE cod_empresa = p_cod_empresa
      AND id_registro = m_id_registro
                
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cliente_item_edi_547:ed')
      RETURN
   END IF
   
   IF NOT pol1372_le_cliente() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   CALL pol1372_den_cli_item() 
   
   IF NOT pol1372_le_item() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   IF NOT pol1372_le_pedido() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
        
END FUNCTION

#--------------------------#
FUNCTION pol1372_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1372_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1372_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_id_registroa = m_id_registro

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_id_registro
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_id_registro
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_id_registro
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_id_registro
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_id_registro = m_id_registroa
         EXIT WHILE
      ELSE
         SELECT 1
           FROM cliente_item_edi_547
          WHERE cod_empresa =  p_cod_empresa
            AND id_registro = m_id_registro
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1372_exibe_dados()
               LET l_achou = TRUE
               EXIT WHILE
            ELSE 
               CALL log003_err_sql("FETCH CURSOR","cq_cons")
               EXIT WHILE
            END IF
         END IF
      END IF               
   
   END WHILE
   
   RETURN l_achou
   
END FUNCTION

#-----------------------#
FUNCTION pol1372_first()#
#-----------------------#

   IF NOT pol1372_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1372_next()#
#----------------------#

   IF NOT pol1372_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1372_previous()#
#--------------------------#

   IF NOT pol1372_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1372_last()#
#----------------------#

   IF NOT pol1372_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1372_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM cliente_item_edi_547
     WHERE cod_empresa =  p_cod_empresa
       AND id_registro = m_id_registro
     FOR UPDATE 
    
    OPEN cq_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_prende")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
    
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_prende")
      CALL log085_transacao("ROLLBACK")
      CLOSE cq_prende
      RETURN FALSE
   END IF

END FUNCTION

#------------------------#
FUNCTION pol1372_update()#
#------------------------#

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT pol1372_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1372_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'M'    

   CALL pol1372_ativa_desativa(TRUE)
      
   CALL _ADVPL_set_property(m_item,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1372_update_confirm()#
#--------------------------------#
   
   DEFINE l_ret   SMALLINT
   
   UPDATE cliente_item_edi_547
      SET cod_it_logix = mr_cabec.cod_item,
          num_pedido = mr_cabec.num_pedido
    WHERE cod_empresa = p_cod_empresa
      AND id_registro = m_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','cliente_item_edi_547')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1372_ativa_desativa(FALSE)
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
   
END FUNCTION

#------------------------------#
FUNCTION pol1372_update_cancel()
#------------------------------#
    
    LET m_id_registro = m_id_registroa
    CALL pol1372_exibe_dados()
    CALL pol1372_ativa_desativa(FALSE)

    RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1372_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1372_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1372_prende_registro() THEN
      RETURN FALSE
   END IF

   DELETE FROM cliente_item_edi_547
    WHERE cod_empresa = p_cod_empresa
      AND id_registro = m_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','cliente_item_edi_547')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1372_limpa_campos()
      LET m_excluiu = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION
   
#--------------------------#
FUNCTION pol1372_importar()#
#--------------------------#

   INITIALIZE mr_arquivo TO NULL
   LET m_ies_sel = FALSE
   LET m_ies_import = FALSE
   LET m_ies_info = FALSE
   
   CALL _ADVPL_set_property(m_panel,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_pan_arq,"VISIBLE",TRUE)
   
   IF NOT pol1372_carrega_arqs() THEN
      RETURN FALSE
   END IF
   
   LET m_ies_info = TRUE
   
   CALL _ADVPL_set_property(m_sel_arquivo,"GET_FOCUS")

   RETURN TRUE   

END FUNCTION

#------------------------------#
FUNCTION pol1372_carrega_arqs()#
#------------------------------#

   DEFINE l_ind     INTEGER,
          t_ind     CHAR(03)

   IF NOT pol1372_le_caminho() THEN
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_sel_arquivo,"CLEAR") 
   CALL _ADVPL_set_property(m_sel_arquivo,"ADD_ITEM","0","    ") 
   
   LET m_caminho = m_caminho CLIPPED,'\\'
   LET m_posi_arq = LENGTH(m_caminho) + 1
   LET m_qtd_arq = LOG_file_getListCount(m_caminho,"*.csv",FALSE,FALSE,TRUE)
   
   IF m_qtd_arq = 0 THEN
      LET m_msg = 'Nenhum arquivo foi encontrado no caminho ', m_caminho
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF m_qtd_arq > 50 THEN
         LET m_msg = 'Arquivos previstos na pasta: 50 - ',
                     'Arquivos encontrados: ', m_qtd_arq USING '<<<<<<'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   END IF
   
   INITIALIZE ma_files TO NULL
   
   FOR l_ind = 1 TO m_qtd_arq
       LET t_ind = l_ind
       LET ma_files[l_ind] = LOG_file_getFromList(l_ind)
       CALL _ADVPL_set_property(m_sel_arquivo,"ADD_ITEM",t_ind,ma_files[l_ind])                    
   END FOR

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1372_le_caminho()#
#----------------------------#

   SELECT nom_caminho, ies_ambiente
     INTO m_caminho, m_ies_ambiente
     FROM path_logix_v2
    WHERE cod_empresa = p_cod_empresa 
      AND cod_sistema = "EDI"

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema EDI não cadastrado na LOG1100.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo","path_logix_v2")
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1372_imp_arquivo()#
#-----------------------------#
   
   IF NOT m_ies_info THEN
      RETURN TRUE
   END IF
   
   LET m_ies_info = TRUE
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_arquivo.nom_arquivo = "0" THEN
      LET m_msg = 'Selecione um arquivo para importação.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_sel_arquivo,"GET_FOCUS") 
      RETURN FALSE
   END IF

   LET m_count = mr_arquivo.nom_arquivo
   LET m_arq_arigem = ma_files[m_count] CLIPPED
   
   IF NOT pol1372_cria_temp() THEN
      RETURN FALSE
   END IF
   
   DELETE FROM import_temp_547
   
   LOAD FROM m_arq_arigem INSERT INTO import_temp_547
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("LOAD",m_arq_arigem)
      RETURN FALSE
   END IF
   
   SELECT COUNT(*) INTO m_count
     FROM import_temp_547

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("SELECT",'import_temp_547')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Arquivo selecionado não contém dados.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_sel_arquivo,"GET_FOCUS") 
      RETURN FALSE
   END IF
   
   LET p_status = LOG_progresspopup_start(
       "Processando...","pol1372_sepa_info","PROCESS")  
   
   IF p_status THEN
      LET m_ies_import = TRUE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1372_cria_temp()#
#---------------------------#

   DROP TABLE import_temp_547
   
   CREATE  TABLE import_temp_547(
    linha      CHAR(80));

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','import_temp_547')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1372_sepa_info()#
#---------------------------#

   DEFINE l_progres         SMALLINT
      
   INITIALIZE ma_itens TO NULL
   CALL _ADVPL_set_property(m_brz_itens,"CLEAR")
   LET m_ind = 1
   LET m_reg_bom = 0
   LET m_reg_mal = 0

   CALL LOG_progresspopup_set_total("PROCESS",m_count)
      
   DECLARE cq_linha CURSOR FOR
    SELECT linha
      FROM import_temp_547 
   FOREACH cq_linha INTO m_registro
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','import_temp_547:cq_linha')
         RETURN FALSE
      END IF
            
      LET l_progres = LOG_progresspopup_increment("PROCESS")

      LET m_pos_ini = 1
      LET ma_itens[m_ind].cod_cliente = pol1372_divide_texto()
      LET ma_itens[m_ind].num_pedido = pol1372_divide_texto()
      LET ma_itens[m_ind].cod_item = pol1372_divide_texto()
      LET ma_itens[m_ind].item_cliente = pol1372_divide_texto()
            
      LET m_msg = ''
      
      IF ma_itens[m_ind].cod_cliente IS NULL THEN
         LET m_msg = m_msg CLIPPED, ' - Cleinte inválido;'
      END IF
      
      IF ma_itens[m_ind].num_pedido IS NULL OR 
          ma_itens[m_ind].num_pedido = 0 THEN
         LET m_msg = m_msg CLIPPED, ' - Pedido inválido;'
      END IF

      IF ma_itens[m_ind].cod_item IS NULL THEN
         LET m_msg = m_msg CLIPPED, ' - Item inválido;'
      END IF

      IF ma_itens[m_ind].item_cliente IS NULL THEN
         LET m_msg = m_msg CLIPPED, ' - Item cliente inválido;'
      END IF
      
      IF m_msg IS NULL THEN
         IF NOT pol1372_consiste() THEN
            RETURN FALSE
         END IF
      END IF
      
      LET ma_itens[m_ind].mensagem = m_msg
      
      IF m_msg IS NULL THEN
         LET m_reg_bom = m_reg_bom + 1
      ELSE
         LET m_reg_mal = m_reg_mal + 1
      END IF            
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 2000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH

   LET m_ind = m_ind - 1
   
   CALL _ADVPL_set_property(m_brz_itens,"ITEM_COUNT", m_ind)
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1372_divide_texto()#
#------------------------------#
   
   DEFINE l_ind        INTEGER,
          l_conteudo   CHAR(30),
          l_pos_fim    INTEGER
          
   FOR l_ind = m_pos_ini TO LENGTH(m_registro)
       IF m_registro[l_ind] = ';' THEN
          LET l_pos_fim = l_ind - 1
          EXIT FOR
       END IF
   END FOR
   
   IF l_pos_fim = 0 THEN
      LET l_pos_fim = LENGTH(m_registro)
   END IF
   
   LET l_conteudo = m_registro[m_pos_ini, l_pos_fim]
   LET m_pos_ini = l_pos_fim + 2
   
   RETURN l_conteudo

END FUNCTION

#--------------------------#
FUNCTION pol1372_consiste()#
#--------------------------#
   
   DEFINE l_situa      CHAR(01),
          l_cliente    CHAR(15),
          l_count      INTEGER
   
   SELECT nom_cliente
     INTO ma_itens[m_ind].nom_cliente
     FROM clientes
    WHERE cod_cliente = ma_itens[m_ind].cod_cliente

   IF STATUS = 0 THEN
   ELSE
      IF STATUS = 100 THEN
         LET m_msg = m_msg CLIPPED, ' - Cliente inexistente;'
      ELSE
         CALL log003_err_sql('SELECT','clientes')
         RETURN FALSE
      END IF
   END IF
   
   SELECT den_item, ies_situacao
     INTO ma_itens[m_ind].den_item, l_situa
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = ma_itens[m_ind].cod_item

   IF STATUS = 0 THEN
      IF l_situa <> 'A' THEN
         LET m_msg = m_msg CLIPPED, ' - Item inativo;'
      END IF
   ELSE
      IF STATUS = 100 THEN
         LET m_msg = m_msg CLIPPED, ' - Item inexistente;'
      ELSE
         CALL log003_err_sql('SELECT','item')
         RETURN FALSE
      END IF
   END IF
   
   SELECT cod_cliente, ies_sit_pedido
     INTO l_cliente, l_situa
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = ma_itens[m_ind].num_pedido

   IF STATUS = 0 THEN
      IF l_situa = '9' THEN
         LET m_msg = m_msg CLIPPED, ' - Pedido cancelado;'
      END IF
   ELSE
      IF STATUS = 100 THEN
      LET m_msg = m_msg CLIPPED, ' - Pedido inexistente;'
      ELSE
         CALL log003_err_sql('SELECT','pedidos')
         RETURN FALSE
      END IF
   END IF
   
   IF m_msg IS NULL THEN
      SELECT COUNT(*) INTO l_count
        FROM cliente_item
       WHERE cod_empresa = p_cod_empresa
         AND cod_cliente_matriz = ma_itens[m_ind].cod_cliente
         AND cod_item = ma_itens[m_ind].cod_item 
         AND cod_item_cliente = ma_itens[m_ind].item_cliente 
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cliente_item:count')
         RETURN FALSE
      END IF
      
      IF l_count = 0 THEN
         LET m_msg = m_msg CLIPPED, ' - Item cliente inexistente;'
      ELSE
         SELECT id_registro
           FROM cliente_item_edi_547
          WHERE cod_empresa = p_cod_empresa
            AND cod_cliente = ma_itens[m_ind].cod_cliente
            AND cod_it_cli = ma_itens[m_ind].item_cliente

         IF STATUS = 0 THEN
            LET m_msg = 'Cliente/item já cadastrado no POL1372'
         ELSE
            IF STATUS <> 100 THEN
               CALL log003_err_sql('INSERT','cliente_item_edi_547')
               RETURN FALSE
            END IF
         END IF
      
      END IF
   
   END IF
   
   RETURN TRUE

END FUNCTION    

#----------------------------#
FUNCTION pol1372_imp_cancel()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_pan_arq,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_panel,"VISIBLE",TRUE)
   INITIALIZE ma_itens TO NULL
   LET m_ies_info = FALSE
   CALL _ADVPL_set_property(m_brz_itens,"SET_ROWS",ma_itens,1)
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1372_imp_conf()#
#--------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT m_ies_import THEN
      LET m_msg = 'Selectcione previmante um arquivo e click em OK.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF m_reg_bom = 0 THEN
      LET m_msg = 'Não a registros em condições de importar.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF m_reg_mal > 0 THEN
      LET m_msg = 'Existem registors com divergência.\n Importar os que estão OK ?'
      IF NOT LOG_question(m_msg) THEN
         RETURN FALSE
      END IF
   END IF
   
   CALL LOG_transaction_begin()
   
   IF NOT pol1372_proc_import() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   LET p_status = pol1372_imp_cancel()
   LET m_ies_cons = FALSE
   LET m_msg = 'Registros importados com sucesso.'
   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE

END FUNCTION 

#-----------------------------#
FUNCTION pol1372_proc_import()#
#-----------------------------#
   
   DEFINE l_qtd_reg    INTEGER
   
   LET l_qtd_reg = _ADVPL_get_property(m_brz_itens,"ITEM_COUNT")
   
   FOR m_ind = 1 TO l_qtd_reg
       
       IF ma_itens[m_ind].mensagem IS NULL THEN
          IF NOT pol1372_ins_import() THEN
             RETURN FALSE
          END IF          
       END IF
       
   END FOR
   
   IF NOT pol1372_move_arquivo() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1372_ins_import()#
#----------------------------#

   INSERT INTO cliente_item_edi_547(
      cod_empresa, 
      cod_cliente, 
      cod_it_cli,  
      cod_it_logix,
      num_pedido)
   VALUES(p_cod_empresa, 
          ma_itens[m_ind].cod_cliente, 
          ma_itens[m_ind].item_cliente,
          ma_itens[m_ind].cod_item, 
          ma_itens[m_ind].num_pedido)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','cliente_item_edi_547:import')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#------------------------------#
FUNCTION pol1372_move_arquivo()#
#------------------------------#
   
   DEFINE l_arq_dest       CHAR(100),
          l_comando        CHAR(120)
          
   LET l_arq_dest = m_arq_arigem CLIPPED,'-import'

   IF m_ies_ambiente = 'W' THEN
      LET l_comando = 'move ', m_arq_arigem CLIPPED, ' ', l_arq_dest
   ELSE
      LET l_comando = 'mv ', m_arq_arigem CLIPPED, ' ', l_arq_dest
   END IF
 
   RUN l_comando RETURNING p_status
   
   IF p_status = 1 THEN
      LET m_msg = 'Não foi possivel renomear o arquivo de .txt para .txt-proces'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

      