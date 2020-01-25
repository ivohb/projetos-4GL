#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1379                                                 #
# OBJETIVO: ESTRUTURA DA EMBALAGEM PADRÃO                           #
# AUTOR...: IVO                                                     #
# DATA....: 19/03/19                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           p_cod_cliente    CHAR(05),
           p_cod_clientea   CHAR(05)
END GLOBALS

DEFINE m_cod_empresa_plano   LIKE empresa.cod_empresa

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_cod_cliente     VARCHAR(10),
       m_nom_cliente     VARCHAR(10),
       m_zoom_cliente    VARCHAR(10),
       m_lupa_cliente    VARCHAR(10),
       m_cod_item        VARCHAR(10),
       m_den_embal       VARCHAR(10),
       m_zoom_item       VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_cod_compon      VARCHAR(10),
       m_den_compon      VARCHAR(10),
       m_zoom_compon     VARCHAR(10),
       m_lupa_compon     VARCHAR(10),
       m_browse          VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_carregando      SMALLINT,
       m_den_item        VARCHAR(76)
       
DEFINE mr_campos         RECORD
       cod_cliente       LIKE clientes.cod_cliente,
       nom_cliente       LIKE clientes.nom_cliente,
       cod_item          LIKE item.cod_item,
       den_item_embal    VARCHAR(50)
END RECORD

DEFINE ma_compon         ARRAY[100] OF RECORD
       cod_compon        LIKE item.cod_item,
       den_compon        LIKE item.den_item,
       excluir           CHAR(01)      
END RECORD

DEFINE m_codigo          LIKE item.cod_item,
       m_lin_atu         INTEGER,
       m_id_embal        INTEGER,
       m_id_embala       INTEGER
       
#-----------------#
FUNCTION pol1379()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1379-12.00.01  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1379_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1379_menu()#
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
           l_titulo           VARCHAR(80)
    
    LET l_titulo = "ESTRUTURA DA EMBALAGEM PADRÃO - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1379_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1379_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1379_create_cancel")
    
    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1379_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1379_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1379_update_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1379_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1379_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1379_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1379_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1379_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1379_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1379_cria_campos(l_panel)
    CALL pol1379_cria_grade(l_panel)

    CALL pol1379_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1379_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
   INITIALIZE ma_compon TO NULL
   CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_compon,1)
   CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
      
END FUNCTION

#----------------------------------------#
FUNCTION pol1379_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)
    #CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",4)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cod cliente:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_cliente,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_cliente,"VARIABLE",mr_campos,"cod_cliente")
    CALL _ADVPL_set_property(m_cod_cliente,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_cliente,"VALID","pol1379_valida_cliente")

    LET m_lupa_cliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_cliente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cliente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cliente,"CLICK_EVENT","pol1379_zoom_cliente")

    LET m_nom_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_nom_cliente,"LENGTH",50) 
    CALL _ADVPL_set_property(m_nom_cliente,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_nom_cliente,"VARIABLE",mr_campos,"nom_cliente")
    CALL _ADVPL_set_property(m_nom_cliente,"CAN_GOT_FOCUS",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Embalagem padrão:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_item,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_item,"VARIABLE",mr_campos,"cod_item")
    CALL _ADVPL_set_property(m_cod_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_item,"VALID","pol1379_valida_item")
    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET m_den_embal = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_embal,"LENGTH",50) 
    CALL _ADVPL_set_property(m_den_embal,"VARIABLE",mr_campos,"den_item_embal")
    CALL _ADVPL_set_property(m_den_embal,"PICTURE","@!")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

END FUNCTION

#---------------------------------------#
FUNCTION pol1379_cria_grade(l_container)#
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
    #CALL _ADVPL_set_property(m_browse,"BEFORE_ADD_ROW_EVENT","pol1379_before_add_row")
    CALL _ADVPL_set_property(m_browse,"AFTER_ROW_EVENT","pol1379_after_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CANCEL_EX")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Excluir")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","excluir")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1379_exc_compon")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Componenete")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_compon")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",15)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    #CALL _ADVPL_set_property(l_tabcolumn,"VALID","pol1379_valida_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1379_zoom_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    #CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",270)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_compon")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_compon,1)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1379_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   IF m_opcao = 'M' THEN
      CALL _ADVPL_set_property(m_cod_cliente,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_lupa_cliente,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_cod_item,"EDITABLE",FALSE)
   ELSE
      CALL _ADVPL_set_property(m_cod_cliente,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_lupa_cliente,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_cod_item,"EDITABLE",l_status)
   END IF
   
   CALL _ADVPL_set_property(m_den_embal,"EDITABLE",l_status)

END FUNCTION

#-----------------------#
FUNCTION pol1379_create()
#-----------------------#
    
    LET m_opcao = 'I'    
    CALL pol1379_limpa_campos()
    
    CALL pol1379_ativa_desativa(TRUE)
    
    LET m_ies_cons = FALSE
    LET ma_compon[1].excluir = 'N'
    
    CALL _ADVPL_set_property(m_browse,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1379_create_confirm()
#-------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF NOT pol1379_valid_itens() THEN
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_begin()
   
   IF NOT pol1379_ins_embalagem() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   IF NOT pol1379_ins_compon() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   CALL pol1379_ativa_desativa(FALSE)
   CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1379_valid_itens()#
#-----------------------------#
   
   DEFINE l_compon     SMALLINT,
          l_ind        SMALLINT

   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')

   IF  mr_campos.den_item_embal IS NULL THEN
       LET m_msg = "Informe a descrição da embalagem padrão"
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       CALL _ADVPL_set_property(m_den_embal,"GET_FOCUS")
       RETURN FALSE
   END IF

   LET m_count =_ADVPL_get_property(m_browse,"ITEM_COUNT")
   LET l_compon = FALSE

   FOR l_ind = 1 TO  m_count
      IF ma_compon[l_ind].cod_compon IS NULL OR ma_compon[l_ind].cod_compon = ' '  THEN
      ELSE
         LET l_compon = TRUE
         EXIT FOR
      END IF
   END FOR

   IF NOT l_compon THEN
      LET m_msg = 'Informe os componentes da embalagem.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1379_ins_embalagem()#
#-------------------------------#
   
   SELECT MAX(id_embal) INTO m_id_embal
     FROM emabalagem_padrao_405
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','emabalagem_padrao_405;max')
      RETURN FALSE
   END IF
   
   IF m_id_embal IS NULL THEN
      LET m_id_embal = 0
   END IF
   
   LET m_id_embal = m_id_embal + 1
   
   INSERT INTO emabalagem_padrao_405(
      id_embal, cod_cliente, cod_item_embal, den_item_embal)
   VALUES(m_id_embal, mr_campos.cod_cliente, mr_campos.cod_item,  mr_campos.den_item_embal)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','emabalagem_padrao_405')
      RETURN FALSE
   END IF
            
   RETURN TRUE
        
END FUNCTION

#----------------------------#
FUNCTION pol1379_ins_compon()#
#----------------------------#
   
   DEFINE l_ind    SMALLINT
   
   DELETE FROM emabalagem_compon_405
    WHERE id_embal = m_id_embal
   
   LET m_count =_ADVPL_get_property(m_browse,"ITEM_COUNT")
   
   FOR l_ind = 1 TO m_count
       IF ma_compon[l_ind].cod_compon IS NULL OR ma_compon[l_ind].cod_compon = ' '  THEN
       ELSE
          DELETE FROM emabalagem_compon_405
           WHERE id_embal = m_id_embal 
             AND cod_item_compon = ma_compon[l_ind].cod_compon
           
          INSERT INTO emabalagem_compon_405(id_embal, cod_item_compon)
          VALUES (m_id_embal, ma_compon[l_ind].cod_compon)
       
          IF STATUS <> 0 THEN
             CALL log003_err_sql('INSERT','emabalagem_compon_405')
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1379_create_cancel()#
#-------------------------------#

    CALL pol1379_ativa_desativa(FALSE)
    CALL pol1379_limpa_campos()
    
    RETURN TRUE
        
END FUNCTION

#------------------------------#
FUNCTION pol1379_zoom_cliente()#
#------------------------------#

    DEFINE l_codigo       LIKE clientes.cod_cliente,
           l_descricao    LIKE clientes.nom_cliente
    
    IF  m_zoom_cliente IS NULL THEN
        LET m_zoom_cliente = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_cliente,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_cliente,"ACTIVATE")
    
    LET l_codigo    = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_descricao = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")

    IF  l_codigo IS NOT NULL THEN
        LET mr_campos.cod_cliente = l_codigo
        LET mr_campos.nom_cliente = l_descricao
    END IF

END FUNCTION

#--------------------------------#
FUNCTION pol1379_valida_cliente()#
#--------------------------------#
    
    CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
    IF  mr_campos.cod_cliente IS NULL THEN
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o cliente.")
        CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")
        RETURN FALSE
    END IF

   IF NOT pol1379_le_clientes(mr_campos.cod_cliente) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_cod_item,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1379_le_clientes(l_cod)#
#----------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''
      
   SELECT nom_cliente
     INTO mr_campos.nom_cliente
     FROM clientes
    WHERE cod_cliente = l_cod
   
   IF STATUS = 100 THEN
      LET m_msg = 'Cliente inexistente no logix.'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','clientes')   
         LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA clientes'    
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1379_zoom_item()#
#---------------------------#

    DEFINE l_where_clause CHAR(300)
    
    IF  m_zoom_item IS NULL THEN
        LET m_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_item,"ZOOM","zoom_item")
    END IF

    LET l_where_clause = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_item,"ACTIVATE")
    
    LET m_codigo    = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")

    LET m_den_item = NULL
    
    IF  m_codigo IS NOT NULL THEN
        CALL pol1379_le_item(m_codigo)
        RETURN TRUE
    END IF
    
    RETURN FALSE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1379_valida_item()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF  mr_campos.cod_item IS NULL THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe código da embalagem padrão")
       CALL _ADVPL_set_property(m_cod_item,"GET_FOCUS")
       RETURN FALSE
   END IF
   
   IF pol1379_cli_item_existe() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1379_cli_item_existe()#
#---------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''
   
   SELECT 1
     FROM emabalagem_padrao_405
    WHERE cod_cliente = mr_campos.cod_cliente
      AND cod_item_embal = mr_campos.cod_item
   
   IF STATUS = 100 THEN
      RETURN FALSE
   ELSE
      IF STATUS = 0 THEN
         LET m_msg = 'Cliente/embalagem já cadastrados. Use o botão modificar.'
      ELSE
         CALL log003_err_sql('SELECT','emabalagem_padrao_405')
      END IF
   END IF   
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1379_zoom_compon()#
#------------------------------#

   IF pol1379_zoom_item() THEN
      LET m_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
      LET ma_compon[m_lin_atu].cod_compon = m_codigo
      LET ma_compon[m_lin_atu].den_compon = m_den_item
   END IF

END FUNCTION

#-------------------------------#
FUNCTION pol1379_valida_compon()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
         
   LET m_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   
   IF  ma_compon[m_lin_atu].cod_compon IS NULL OR ma_compon[m_lin_atu].cod_compon = '' THEN
   ELSE
      IF NOT pol1379_le_item(ma_compon[m_lin_atu].cod_compon) THEN     
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
      LET ma_compon[m_lin_atu].den_compon = m_den_item
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1379_before_add_row()#
#--------------------------------#

   IF m_carregando THEN
      RETURN TRUE
   END IF
   
   CALL _ADVPL_set_property(m_browse,"REMOVE_EMPTY_ROWS")
            
   RETURN TRUE

END FUNCTION
   
#------------------------------#
FUNCTION pol1379_after_compon()#
#------------------------------#
      
   DEFINE l_ind    SMALLINT
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
      
   IF m_carregando  THEN
      RETURN TRUE
   END IF
   
   LET m_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   LET m_count = _ADVPL_get_property(m_browse,"ITEM_COUNT")
   
   FOR l_ind = 1 TO m_count
      IF ma_compon[l_ind].cod_compon IS NULL OR ma_compon[l_ind].cod_compon = ' ' THEN
         CALL _ADVPL_set_property(m_browse,"REMOVE_ROW",l_ind)
      END IF
   END FOR
   
   #CALL _ADVPL_get_property(m_browse,"REMOVE_EMPTY_ROWS")
   
   IF  ma_compon[m_lin_atu].cod_compon IS NULL OR ma_compon[m_lin_atu].cod_compon = '' THEN
       RETURN TRUE
   END IF
   
   IF ma_compon[m_lin_atu].cod_compon = mr_campos.cod_item THEN
      LET m_msg = 'Item não pode estar na estrutura dele mesmo'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   IF NOT pol1379_le_item(ma_compon[m_lin_atu].cod_compon) THEN     
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET ma_compon[m_lin_atu].den_compon = m_den_item
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1379_le_item(l_cod)#
#------------------------------#
   
   DEFINE l_cod              LIKE item.cod_item,
          l_ies_ctr_estoque  LIKE item.ies_ctr_estoque,
          l_tipo             LIKE item.ies_tip_item,
          l_pes_unit         LIKE item.pes_unit
   
   IF l_cod IS NULL THEN
      RETURN TRUE
   END IF
   
   LET m_msg = ''
      
   SELECT den_item,
          ies_ctr_estoque,
          ies_tip_item,
          pes_unit
     INTO m_den_item,
          l_ies_ctr_estoque,
          l_tipo,
          l_pes_unit
     FROM item
    WHERE cod_empresa =  p_cod_empresa
      AND cod_item = l_cod
   
   IF STATUS = 100 THEN
      LET m_msg = 'item não cadastrado no Logix'
      LET m_den_item = NULL
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item')    
         LET m_den_item = NULL
         RETURN FALSE
      END IF
   END IF

   IF l_ies_ctr_estoque = 'N' THEN
      LET m_msg = 'Item não controla estoque.'
      RETURN FALSE
   END IF

   IF l_tipo <> 'C' THEN
      LET m_msg = 'O item componente deve ser do tipo comprado (C)'
      RETURN FALSE
   END IF

   IF l_pes_unit <= 0 THEN
      LET m_msg = 'O peso unitário do item no MAN10021 não é válido.'
      RETURN FALSE
   END IF
   
   SELECT COUNT(*) INTO m_count FROM cliente_item
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente_matriz = mr_campos.cod_cliente
      AND cod_item = l_cod
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cliente_item')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'O item não está cadastrado como um item do cliente.'
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#----------------------------#   
FUNCTION pol1379_exc_compon()#
#----------------------------#

   DEFINE l_lin_atu       INTEGER,
          l_ind           INTEGER
      
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   
   CALL _ADVPL_set_property(m_browse,"REMOVE_ROW",l_lin_atu)
            
   RETURN TRUE

END FUNCTION

#----------------------#
FUNCTION pol1379_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1379_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","emabalagem_padrao_405","embalagem")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","emabalagem_padrao_405","cod_cliente","Cliente",1 {CHAR},5,0,"zoom_clientes")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","emabalagem_padrao_405","cod_item_embal","Emabalagem",1 {CHAR},15,0,"zoom_item")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","emabalagem_padrao_405","cod_item_compon","Componente",1 {CHAR},15,0,"zoom_item")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1379_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1379_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " cod_cliente "
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT id_embal ",
                      " FROM emabalagem_padrao_405",
                     " WHERE ",l_where CLIPPED,
                     " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","emabalagem_padrao_405")
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

    FETCH cq_cons INTO m_id_embal

    IF STATUS <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","cq_cons:1")
       ELSE
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Argumentos de pesquisa não encontrados.")
       END IF
       CALL pol1379_limpa_campos()
       RETURN FALSE
    END IF
    
    IF NOT pol1379_exibe_dados() THEN
       RETURN
    END IF
    
    LET m_ies_cons = TRUE
    LET m_id_embala = m_id_embal
    
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1379_exibe_dados()#
#-----------------------------#
   
   LET m_excluiu = FALSE
   
   SELECT cod_cliente,
          cod_item_embal,
          den_item_embal
     INTO mr_campos.cod_cliente,
          mr_campos.cod_item,
          mr_campos.den_item_embal
     FROM emabalagem_padrao_405
    WHERE id_embal = m_id_embal

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','emabalagem_padrao_405:ed')
      RETURN FALSE
   END IF
   
   IF NOT pol1379_le_clientes(mr_campos.cod_cliente) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
      
   IF NOT pol1379_load_itens() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
           
END FUNCTION

#----------------------------#
FUNCTION pol1379_load_itens()#
#----------------------------#
   
   DEFINE l_ind    INTEGER
   
   INITIALIZE ma_compon TO NULL
   CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_compon,1)
   LET l_ind = 1
   
   DECLARE cq_le_it CURSOR FOR
    SELECT cod_item_compon 
      FROM emabalagem_compon_405
     WHERE id_embal = m_id_embal
   
   FOREACH cq_le_it INTO ma_compon[l_ind].cod_compon
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','emabalagem_compon_405:cq_le_it')
         RETURN FALSE
      END IF
      
      IF NOT pol1379_le_item(ma_compon[l_ind].cod_compon) THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      ELSE
         LET ma_compon[l_ind].den_compon = m_den_item
      END IF
      
      LET ma_compon[l_ind].excluir = 'N'
      LET l_ind = l_ind + 1
      
      IF l_ind > 100 THEN
         LET m_msg = 'Limite de linhas da grade ultrapasou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   IF l_ind > 1 THEN
      CALL _ADVPL_set_property(m_browse,"ITEM_COUNT",(l_ind - 1))
   ELSE
      LET m_msg = 'Item embalagem sem estrutura'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1379_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1379_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1379_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_id_embala = m_id_embal

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_id_embal
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_id_embal
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_id_embal
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_id_embal
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons:2")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_id_embal = m_id_embala
         EXIT WHILE
      ELSE
         SELECT 1
           FROM emabalagem_padrao_405
          WHERE id_embal = m_id_embal
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1379_exibe_dados()
               LET l_achou = TRUE
               EXIT WHILE
            ELSE 
               CALL log003_err_sql("FETCH CURSOR","cq_cons:3")
               EXIT WHILE
            END IF
         END IF
      END IF               
   
   END WHILE
   
   RETURN l_achou
   
END FUNCTION

#-----------------------#
FUNCTION pol1379_first()#
#-----------------------#

   IF NOT pol1379_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1379_next()#
#----------------------#

   IF NOT pol1379_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1379_previous()#
#--------------------------#

   IF NOT pol1379_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1379_last()#
#----------------------#

   IF NOT pol1379_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1379_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM emabalagem_padrao_405
     WHERE id_embal = m_id_embal
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
FUNCTION pol1379_update()#
#------------------------#

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT pol1379_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1379_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'M'    
   
   CALL pol1379_ativa_desativa(TRUE)
   CALL _ADVPL_set_property(m_browse,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_den_embal,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1379_update_confirm()#
#--------------------------------#
   
   DEFINE l_ret   SMALLINT

   IF NOT pol1379_valid_itens() THEN
      RETURN FALSE
   END IF

   UPDATE emabalagem_padrao_405
      SET den_item_embal = mr_campos.den_item_embal
    WHERE id_embal = m_id_embal
   
   IF STATUS = 0 THEN
      LET l_ret = pol1379_ins_compon() 
   ELSE
      CALL log003_err_sql('UPDATE','emabalagem_padrao_405')
      LET l_ret = FALSE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1379_ativa_desativa(FALSE)
   ELSE
      CALL log085_transacao("ROLLBACK")  
   END IF
   
   CLOSE cq_prende
   
   CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
   
   RETURN l_ret
   
END FUNCTION

#------------------------------#
FUNCTION pol1379_update_cancel()
#------------------------------#
    
    LET p_cod_cliente = p_cod_clientea
    CALL pol1379_exibe_dados()
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
    CALL pol1379_ativa_desativa(FALSE)

    RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1379_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1379_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1379_prende_registro() THEN
      RETURN FALSE
   END IF

   LET l_ret = FALSE

   DELETE FROM emabalagem_padrao_405
    WHERE id_embal = m_id_embal

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','emabalagem_padrao_405')
   ELSE
      DELETE FROM emabalagem_compon_405
       WHERE id_embal = m_id_embal
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','emabalagem_compon_405')
      ELSE
         LET l_ret = TRUE
      END IF
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1379_limpa_campos()
      LET m_excluiu = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION

