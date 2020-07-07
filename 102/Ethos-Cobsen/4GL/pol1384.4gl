#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1384                                                 #
# OBJETIVO: MANUTENÇÃO DO SHIPDATE                                  #
# AUTOR...: IVO                                                     #
# DATA....: 10/02/2020                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_ref_pedido      VARCHAR(10),
       m_zoom_pedido     VARCHAR(10),
       m_lupa_pedido     VARCHAR(10),
       m_ref_cliente     VARCHAR(10),
       m_zoom_cliente    VARCHAR(10),
       m_lupa_cliente    VARCHAR(10),
       m_construct       VARCHAR(10),
       m_browse          VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_carregando      SMALLINT,
       m_lin_atu         INTEGER


DEFINE mr_campos         RECORD
       num_pedido        LIKE pedidos.num_pedido,
       cod_cliente       LIKE clientes.cod_cliente,
       nom_cliente       LIKE clientes.nom_cliente
END RECORD

DEFINE m_panel_campos    VARCHAR(10)

DEFINE ma_itens          ARRAY[1000] OF RECORD
       num_seq           LIKE ped_itens.num_sequencia,
       cod_item          LIKE ped_itens.cod_item,
       den_item          LIKE item.den_item,
       qtd_solic         LIKE ped_itens.qtd_pecas_atend,
       sdo_pedido        LIKE ped_itens.qtd_pecas_atend,
       prz_entrega       LIKE ped_itens.prz_entrega,
       ship_date         LIKE ped_itens.prz_entrega
END RECORD

#-----------------#
FUNCTION pol1384()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1384-12.00.01  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1384_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1384_menu()#
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
    
    LET l_titulo = "MANUTENÇÃO DO SHIPDATE (PRAZO DE ENTREGA) - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)
    
    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1384_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1384_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1384_update_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1384_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1384_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1384_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1384_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1384_last")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1384_cria_campos(l_panel)
    CALL pol1384_cria_grade(l_panel)

    CALL pol1384_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1384_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)

    LET m_panel_campos = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel_campos,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_panel_campos,"HEIGHT",60)
    CALL _ADVPL_set_property(m_panel_campos,"BACKGROUND_COLOR",231,237,237)
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",5)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Pedido:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_ref_pedido = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_ref_pedido,"LENGTH",15)
    CALL _ADVPL_set_property(m_ref_pedido,"VARIABLE",mr_campos,"num_pedido")
    CALL _ADVPL_set_property(m_ref_pedido,"PICTURE","@!")
    CALL _ADVPL_set_property(m_ref_pedido,"VALID","pol1384_valida_pedido")

    LET m_lupa_pedido = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_pedido,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_pedido,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_pedido,"CLICK_EVENT","pol1384_zoom_pedido")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_ref_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_ref_cliente,"LENGTH",15)
    CALL _ADVPL_set_property(m_ref_cliente,"VARIABLE",mr_campos,"cod_cliente")
    CALL _ADVPL_set_property(m_ref_cliente,"PICTURE","@!")
    CALL _ADVPL_set_property(m_ref_cliente,"VALID","pol1384_valida_cliente")

    LET m_lupa_cliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_cliente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cliente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cliente,"CLICK_EVENT","pol1384_zoom_cliente")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",50) 
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_campos,"nom_cliente")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

END FUNCTION

#---------------------------------------#
FUNCTION pol1384_cria_grade(l_container)#
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
    #CALL _ADVPL_set_property(m_browse,"BEFORE_ADD_ROW_EVENT","pol1384_before_add_row")
    #CALL _ADVPL_set_property(m_browse,"AFTER_ROW_EVENT","pol1384_after_row")

    {LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CANCEL_EX")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Excluir")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","excluir")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1384_exc_compon")}

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Seq")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_seq")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",270)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Solicitado")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_solic")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sdo pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","sdo_pedido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Prz entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LDATEFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    #CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",15)
    #CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","prz_entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"VALID","pol1384_valida_prazo")
            
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ship date")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LDATEFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    #CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",15)
    #CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ship_date")    

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#---------------------------#
FUNCTION pol1384_after_row()#
#---------------------------#
      
   DEFINE l_ind    SMALLINT
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
      
   IF m_carregando  THEN
      RETURN TRUE
   END IF
   
   LET m_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   IF ma_itens[m_lin_atu].prz_entrega IS NULL OR ma_itens[m_lin_atu].prz_entrega < TODAY THEN
      LET m_msg = 'Prazo de entega inválido'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1384_valida_prazo()#
#------------------------------#
         
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
         
   LET m_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   IF ma_itens[m_lin_atu].prz_entrega IS NULL OR ma_itens[m_lin_atu].prz_entrega < TODAY THEN
      LET m_msg = 'Prazo de entega inválido'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1384_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
   INITIALIZE ma_itens TO NULL
   CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_compon,1)
      
END FUNCTION


#----------------------------------------#
FUNCTION pol1384_ativa_desativa(l_opcao)#
#----------------------------------------#

   DEFINE l_opcao SMALLINT
   
   IF l_opcao = 'I' THEN      
      CALL _ADVPL_set_property(m_panel_campos,"ENABLE",TRUE)
      CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
   ELSE
      IF l_opcao = 'M' THEN      
         CALL _ADVPL_set_property(m_panel_campos,"ENABLE",FALSE)
         CALL _ADVPL_set_property(m_browse,"EDITABLE",TRUE)
      ELSE
         CALL _ADVPL_set_property(m_panel_campos,"ENABLE",FALSE)
         CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
      END IF
   END IF
   
END FUNCTION

