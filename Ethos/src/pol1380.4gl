#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1380                                                 #
# OBJETIVO: EMBALAGEM PADRÃO DO ITEM                                #
# AUTOR...: IVO                                                     #
# DATA....: 16/01/2020                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           p_cod_item    CHAR(05),
           p_cod_itema   CHAR(05)
END GLOBALS

DEFINE m_cod_empresa_plano   LIKE empresa.cod_empresa

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_cod_item        VARCHAR(10),
       m_den_item        VARCHAR(10),
       m_zoom_item       VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_cod_embal       VARCHAR(10),
       m_den_item_embal  VARCHAR(10),
       m_zoom_embal      VARCHAR(10),
       m_lupa_embal      VARCHAR(10),
       m_construct       VARCHAR(10),
       m_qtd_item        VARCHAR(10),
       m_cod_cliente     VARCHAR(10),
       m_nom_cliente     VARCHAR(10),
       m_zoom_cliente    VARCHAR(10),
       m_lupa_cliente    VARCHAR(10),
       m_form_email      VARCHAR(10),
       m_bar_email       VARCHAR(10),
       m_emitente        VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_id_registro     INTEGER,
       m_id_registroa    INTEGER
       
DEFINE mr_campos         RECORD
       cod_cliente       LIKE clientes.cod_cliente,
       nom_cliente       LIKE clientes.nom_cliente,
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item,
       cod_item_embal    LIKE item.cod_item,
       den_item_embal    LIKE item.den_item,
       qtd_item_embal    DECIMAL(10,3)
END RECORD

#-----------------#
FUNCTION pol1380()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1380-12.00.01  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1380_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1380_menu()#
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
           l_delete  VARCHAR(10),
           l_titulo  VARCHAR(80)
    
    LET l_titulo = 'EMBALAGEM PADRÃO DO ITEM - ', p_versao
    
    CALL pol1380_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1380_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1380_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1380_create_cancel")
    
    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1380_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1380_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1380_update_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1380_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1380_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1380_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1380_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1380_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1380_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1380_cria_campos(l_panel)

    CALL pol1380_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1380_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1380_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_campo           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",40)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
    CALL _ADVPL_set_property(l_panel,"WIDTH",200)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",4)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Código do cliente:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_cliente,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_cliente,"VARIABLE",mr_campos,"cod_cliente")
    CALL _ADVPL_set_property(m_cod_cliente,"PICTURE","@E!")
    CALL _ADVPL_set_property(m_cod_cliente,"VALID","pol1380_valida_cliente")

    LET m_lupa_cliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_cliente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cliente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cliente,"CLICK_EVENT","pol1380_zoom_cliente")

    LET l_campo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_campo,"LENGTH",30) 
    CALL _ADVPL_set_property(l_campo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_campo,"VARIABLE",mr_campos,"nom_cliente")
    CALL _ADVPL_set_property(l_campo,"CAN_GOT_FOCUS",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Código do item:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_item,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_item,"VARIABLE",mr_campos,"cod_item")
    CALL _ADVPL_set_property(m_cod_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_item,"VALID","pol1380_valida_item")

    LET m_lupa_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_item,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_item,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_item,"CLICK_EVENT","pol1380_zoom_item")

    LET l_campo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_campo,"LENGTH",50) 
    CALL _ADVPL_set_property(l_campo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_campo,"VARIABLE",mr_campos,"den_item")
    CALL _ADVPL_set_property(l_campo,"CAN_GOT_FOCUS",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Código da embalag:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_embal = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_embal,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_embal,"VARIABLE",mr_campos,"cod_item_embal")
    CALL _ADVPL_set_property(m_cod_embal,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_embal,"VALID","pol1380_valida_embal")

    LET m_lupa_embal = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_embal,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_embal,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_embal,"CLICK_EVENT","pol1380_zoom_embal")

    LET l_campo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_campo,"LENGTH",50) 
    CALL _ADVPL_set_property(l_campo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_campo,"VARIABLE",mr_campos,"den_item_embal")
    CALL _ADVPL_set_property(l_campo,"CAN_GOT_FOCUS",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd item na embal:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_qtd_item = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_qtd_item,"LENGTH",12)
    CALL _ADVPL_set_property(m_qtd_item,"VARIABLE",mr_campos,"qtd_item_embal")
    CALL _ADVPL_set_property(m_qtd_item,"PICTURE","@E #######.###")

END FUNCTION

#----------------------------------------#
FUNCTION pol1380_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   IF m_opcao = 'M' THEN
      CALL _ADVPL_set_property(m_cod_cliente,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_lupa_cliente,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_cod_item,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_lupa_item,"EDITABLE",FALSE)
   ELSE
      CALL _ADVPL_set_property(m_cod_cliente,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_lupa_cliente,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_cod_item,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_lupa_item,"EDITABLE",l_status)
   END IF
   
   CALL _ADVPL_set_property(m_cod_embal,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_embal,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_qtd_item,"EDITABLE",l_status)

END FUNCTION

#------------------------------#
FUNCTION pol1380_zoom_cliente()#
#------------------------------#

    DEFINE l_codigo       LIKE clientes.cod_cliente
    
    IF  m_zoom_cliente IS NULL THEN
        LET m_zoom_cliente = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_cliente,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_cliente,"ACTIVATE")
    
    LET l_codigo    = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    
    IF l_codigo IS NOT NULL THEN
       IF pol1380_le_cliente(l_codigo) THEN
          LET mr_campos.cod_cliente = l_codigo
          LET mr_campos.nom_cliente = m_nom_cliente     
       END IF   
    END IF

    CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")

END FUNCTION

#--------------------------------#
FUNCTION pol1380_valida_cliente()#
#--------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF mr_campos.cod_cliente IS NOT NULL THEN
      IF NOT pol1380_le_cliente(mr_campos.cod_cliente) THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   ELSE
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", 'Informe o cliente')
      RETURN FALSE
   END IF
   
   SELECT COUNT(*) INTO m_count
     FROM emabalagem_padrao_405
    WHERE cod_cliente = mr_campos.cod_cliente
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','emabalagem_padrao_405')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Cliente não cadastrados no POL1379'
      RETURN TRUE
   END IF
     
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1380_le_cliente(l_cod)#
#----------------------------------#
   
   DEFINE l_cod LIKE clientes.cod_cliente
   
   LET m_msg = ''
      
   SELECT nom_cliente
     INTO m_nom_cliente
     FROM clientes
    WHERE cod_cliente = l_cod
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cliente')    
      LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA cliente'    
      LET m_nom_cliente = NULL   
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1380_zoom_item()#
#---------------------------#

    DEFINE l_where_clause CHAR(300),
           l_codigo       CHAR(15)
    
    IF  m_zoom_item IS NULL THEN
        LET m_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_item,"ZOOM","zoom_item")
    END IF

    LET l_where_clause = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_item,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")
    
    IF l_codigo IS NOT NULL THEN
       IF pol1380_le_item(l_codigo) THEN
          LET mr_campos.cod_item = l_codigo
          LET mr_campos.den_item = m_den_item
       END IF
    END IF

    CALL _ADVPL_set_property(m_cod_item,"GET_FOCUS")

END FUNCTION

#---------------------------------#
FUNCTION pol1380_valida_item()#
#---------------------------------#
    
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
 
    LET m_den_item = NULL
       
   IF mr_campos.cod_item IS NOT NULL THEN
      IF NOT pol1380_le_item(mr_campos.cod_item) THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   END IF
   
   LET mr_campos.den_item = m_den_item
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1380_le_item(l_cod)#
#------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''
      
   SELECT den_item
     INTO m_den_item
     FROM item
    WHERE cod_empresa =  p_cod_empresa
      AND cod_item = l_cod
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')   
      LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA item'    
      LET m_den_item = NULL
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1380_valida_embal()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF mr_campos.cod_item_embal IS NOT NULL THEN
      IF NOT pol1380_le_embal(mr_campos.cod_item_embal) THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1380_le_embal(l_cod)#
#-------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''
      
   SELECT 1
     FROM emabalagem_padrao_405
    WHERE cod_cliente = mr_campos.cod_cliente
      AND cod_item_embal = l_cod

   IF STATUS = 100 THEN
      LET m_msg = 'Cliente/embalagem não cadastrados no POL1379'
      RETURN FALSE
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','emabalagem_padrao_405:cliente/embalagem')
      RETURN FALSE
   END IF
   
   IF NOT pol1380_le_item(l_cod) THEN
      RETURN FALSE
   END IF
   
   LET mr_campos.den_item_embal = m_den_item
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1380_validitem()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF mr_campos.cod_item IS NULL THEN
      LET m_msg = 'Informe o item'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_cod_item,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF pol1380_item_existe() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF NOT pol1380_validembal() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1380_validembal()#
#----------------------------#  
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_campos.cod_item_embal IS NULL THEN
      LET m_msg = 'Informe o item embalagem'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_cod_embal,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_campos.cod_item_embal = mr_campos.cod_item THEN
      LET m_msg = 'Item e item embalagem não podem ser iguais'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_cod_embal,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_campos.qtd_item_embal IS NULL OR mr_campos.qtd_item_embal <= 0 THEN
      LET m_msg = 'Informe quantidade do item por embalagem'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_qtd_item,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF pol1380_embal_existe() THEN
      LET m_msg = 'Cliente/item/embal já cadastrados no pol1380'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol1380_item_existe()#
#-----------------------------#
      
   SELECT 1
     FROM item_embal_405
    WHERE cod_cliente = mr_campos.cod_cliente
      AND cod_item = mr_campos.cod_item
   
   IF STATUS = 0 THEN
      LET m_msg = 'Cliente/item já cadastrados no pol1380'
      RETURN TRUE
   END IF
   
   IF STATUS <> 100 THEN
      LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA item_embal_405' 
      RETURN TRUE  
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
FUNCTION pol1380_embal_existe()#
#------------------------------#
         
   SELECT 1
     FROM item_embal_405
    WHERE cod_cliente = mr_campos.cod_cliente
      AND cod_item = mr_campos.cod_item
      AND cod_item_embal = mr_campos.cod_item_embal
   
   IF STATUS = 0 THEN
      LET m_msg = 'Cliente/item/embal já cadastrados no pol1380'
      RETURN TRUE
   END IF
   
   IF STATUS <> 100 THEN
      LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA item_embal_405' 
      RETURN TRUE  
   END IF
   
   RETURN FALSE

END FUNCTION

#-----------------------#
FUNCTION pol1380_create()
#-----------------------#
    
    LET m_opcao = 'I'    
    CALL pol1380_limpa_campos()
    CALL pol1380_ativa_desativa(TRUE)
    
    LET m_ies_cons = FALSE
    
    CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1380_create_confirm()
#-------------------------------#
   
   IF NOT pol1380_validitem() THEN
      RETURN FALSE
   END IF

   SELECT MAX(id_registro) INTO m_id_registro
     FROM item_embal_405
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item_embal_405;max')
      RETURN FALSE
   END IF
   
   IF m_id_registro IS NULL THEN
      LET m_id_registro = 0
   END IF
   
   LET m_id_registro = m_id_registro + 1

   INSERT INTO item_embal_405(
      id_registro,
      cod_cliente,   
      cod_item,      
      cod_item_embal,
      qtd_item_embal) VALUES(
      m_id_registro,
      mr_campos.cod_cliente,
      mr_campos.cod_item,
      mr_campos.cod_item_embal,
      mr_campos.qtd_item_embal)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','item_embal_405')
      RETURN FALSE
   END IF
            
    CALL pol1380_ativa_desativa(FALSE)

    RETURN TRUE
        
END FUNCTION

#-------------------------------#
FUNCTION pol1380_create_cancel()#
#-------------------------------#

    CALL pol1380_ativa_desativa(FALSE)
    CALL pol1380_limpa_campos()
    
    RETURN TRUE
        
END FUNCTION

#----------------------#
FUNCTION pol1380_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1380_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","item_embal_405","embal")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","item_embal_405","cod_cliente","item",1 {CHAR},15,0,"zoom_clientes")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","item_embal_405","cod_item","item",1 {CHAR},15,0,"zoom_item")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","item_embal_405","cod_item_embal","embal",1 {CHAR},15,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1380_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1380_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " cod_cliente, cod_item "
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT id_registro ",
                      " FROM item_embal_405",
                     " WHERE ",l_where CLIPPED,
                     " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","item_embal_405")
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
       RETURN FALSE
    END IF
    
    CALL pol1380_exibe_dados() 
    
    LET m_ies_cons = TRUE
    LET m_id_registroa = m_id_registro
    
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1380_exibe_dados()#
#-----------------------------#
   
   LET m_excluiu = FALSE
   
   SELECT cod_cliente,
          cod_item,
          cod_item_embal,
          qtd_item_embal         
     INTO mr_campos.cod_cliente,
          mr_campos.cod_item,
          mr_campos.cod_item_embal,
          mr_campos.qtd_item_embal
     FROM item_embal_405
    WHERE id_registro = m_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item_embal_405:ed')
      RETURN
   END IF

   IF NOT pol1380_le_cliente(mr_campos.cod_cliente) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
   
   LET mr_campos.nom_cliente = m_nom_cliente  
   
   IF NOT pol1380_le_item(mr_campos.cod_item) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF   
   
   LET mr_campos.den_item = m_den_item
   
   IF NOT pol1380_le_item(mr_campos.cod_item_embal) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
   
   LET mr_campos.den_item_embal = m_den_item
        
END FUNCTION

#--------------------------#
FUNCTION pol1380_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1380_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1380_ies_cons() THEN
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
           FROM item_embal_405
          WHERE id_registro = m_id_registro
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1380_exibe_dados()
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
FUNCTION pol1380_first()#
#-----------------------#

   IF NOT pol1380_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1380_next()#
#----------------------#

   IF NOT pol1380_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1380_previous()#
#--------------------------#

   IF NOT pol1380_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1380_last()#
#----------------------#

   IF NOT pol1380_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1380_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM item_embal_405
     WHERE id_registro = m_id_registro
     
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
FUNCTION pol1380_update()#
#------------------------#

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT pol1380_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1380_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'M'    

   CALL pol1380_ativa_desativa(TRUE)
      
   CALL _ADVPL_set_property(m_cod_embal,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1380_update_confirm()#
#--------------------------------#
   
   DEFINE l_ret   SMALLINT
   
   IF NOT pol1380_validembal() THEN
      RETURN FALSE
   END IF
   
   UPDATE item_embal_405
      SET cod_item_embal = mr_campos.cod_item_embal,
          qtd_item_embal = mr_campos.qtd_item_embal
    WHERE id_registro = m_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','item_embal_405')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1380_ativa_desativa(FALSE)
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
   
END FUNCTION

#------------------------------#
FUNCTION pol1380_update_cancel()
#------------------------------#
    
    LET m_id_registro = m_id_registroa
    CALL pol1380_exibe_dados()
    CALL pol1380_ativa_desativa(FALSE)

    RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1380_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1380_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "item cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1380_prende_registro() THEN
      RETURN FALSE
   END IF

   DELETE FROM item_embal_405
    WHERE id_registro = m_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','item_embal_405')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1380_limpa_campos()
      LET m_excluiu = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION

{
#----------------------------#
FUNCTION pol1380_zoom_embal()#
#----------------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_confirma    VARCHAR(10),
           l_cancela     VARCHAR(10),
           l_label       VARCHAR(10),
           l_titulo      VARCHAR(80)

    INITIALIZE mr_email TO NULL
    
    SELECT emitente, receptor
      INTO mr_email.emitente, mr_email.receptor
      FROM email_apont_405
     WHERE cod_empresa = p_cod_empresa
    
    LET l_titulo = 'CADASTRO DE EMAIL PARA ENVIO E RECEBIMENTO'
    
    LET m_form_email = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_email,"SIZE",900,500) #400
    CALL _ADVPL_set_property(m_form_email,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_form_email,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_form_email,"INIT_EVENT","pol1380_posiciona")

    LET m_bar_email = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_email)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_email)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",40)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) #vermelho,verde,azul

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_email)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1380_info_dados(l_panel)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_email)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)
    
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
   CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirma,"EVENT","pol1380_conf_email")  

   LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancela,"EVENT","pol1380_canc_email")     

    CALL _ADVPL_set_property(m_form_email,"ACTIVATE",TRUE)
            
    RETURN TRUE
    
END FUNCTION

#-----------------------------------#
FUNCTION pol1380_info_dados(l_panel)#
#-----------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_destinat        VARCHAR(10),
           l_label           VARCHAR(10),
           l_cliente         VARCHAR(10),
           l_den_cent_trab   VARCHAR(10),
           l_den_item      VARCHAR(10)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Email do remetente:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_emitente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_emitente,"POSITION",30,60)     
    CALL _ADVPL_set_property(m_emitente,"LENGTH",50) 
    CALL _ADVPL_set_property(m_emitente,"VARIABLE",mr_email,"emitente")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,90)     
    CALL _ADVPL_set_property(l_label,"TEXT","Emails dos destinatários:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_destinat = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_destinat,"POSITION",30,120)     
    CALL _ADVPL_set_property(l_destinat,"LENGTH",100) 
    CALL _ADVPL_set_property(l_destinat,"VARIABLE",mr_email,"receptor")

END FUNCTION

#---------------------------#
FUNCTION pol1380_posiciona()#
#---------------------------#

    CALL _ADVPL_set_property(m_emitente,"GET_FOCUS")

    RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1380_conf_email()#
#----------------------------#

   CALL _ADVPL_set_property(m_bar_email,"ERROR_TEXT", '')
    
   IF mr_email.emitente IS NULL THEN
      LET m_msg = 'Informe o email do emitente.'
       CALL _ADVPL_set_property(m_bar_email,"ERROR_TEXT",m_msg)
       RETURN FALSE
   END IF

   IF mr_email.receptor IS NULL THEN
      LET m_msg = 'Informe o(s) email(s) do(s) destinatários'
       CALL _ADVPL_set_property(m_bar_email,"ERROR_TEXT",m_msg)
       RETURN FALSE
   END IF
   
   SELECT 1 FROM email_apont_405
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 100 THEN
      INSERT INTO email_apont_405
       VALUES(p_cod_empresa, mr_email.emitente, mr_email.receptor)
   ELSE
      IF STATUS = 0 THEN
         UPDATE email_apont_405
          SET emitente = mr_email.emitente,
              receptor = mr_email.receptor
         WHERE cod_empresa = p_cod_empresa
      ELSE
         CALL log003_err_sql('SELECT','email_apont_405')
         RETURN FALSE
      END IF
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('gravando','email_apont_405')
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_form_email,"ACTIVATE",FALSE) 
   
   RETURN TRUE

END FUNCTION             
   
#----------------------------#
FUNCTION pol1380_canc_email()#
#----------------------------#
    
   CALL _ADVPL_set_property(m_form_email,"ACTIVATE",FALSE)    

   RETURN TRUE

END FUNCTION
   