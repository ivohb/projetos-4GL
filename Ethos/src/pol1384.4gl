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
       m_num_pedido      DECIMAL(6,0),
       m_num_pedidoa     DECIMAL(6,0),
       m_qtd_item        INTEGER


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
       prz_ent_ant       LIKE ped_itens.prz_entrega,
       ship_date         LIKE ped_itens.prz_entrega,
       num_ordem         LIKE ordens.num_ordem,
       mensagem          CHAR(50)
END RECORD

#-----------------#
FUNCTION pol1384()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1384-12.00.00  "
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

    CALL pol1384_ativa_desativa('L')

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1384_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)

    LET m_panel_campos = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel_campos,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_panel_campos,"HEIGHT",60)
    CALL _ADVPL_set_property(m_panel_campos,"BACKGROUND_COLOR",231,237,237)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_campos)
    CALL _ADVPL_set_property(l_label,"TEXT","Pedido:")    
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_ref_pedido = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_campos)
    CALL _ADVPL_set_property(m_ref_pedido,"VARIABLE",mr_campos,"num_pedido")
    CALL _ADVPL_set_property(m_ref_pedido,"POSITION",60,10)
    CALL _ADVPL_set_property(m_ref_pedido,"LENGTH",15)
    CALL _ADVPL_set_property(m_ref_pedido,"PICTURE","@!")
    #CALL _ADVPL_set_property(m_ref_pedido,"VALID","pol1384_valida_pedido")

    LET m_lupa_pedido = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_campos)
    CALL _ADVPL_set_property(m_lupa_pedido,"POSITION",200,10)
    CALL _ADVPL_set_property(m_lupa_pedido,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_pedido,"SIZE",24,20)
    #CALL _ADVPL_set_property(m_lupa_pedido,"CLICK_EVENT","pol1384_zoom_pedido")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_campos)
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    
    CALL _ADVPL_set_property(l_label,"POSITION",250,10)
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_ref_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_campos)
    CALL _ADVPL_set_property(m_ref_cliente,"VARIABLE",mr_campos,"cod_cliente")
    CALL _ADVPL_set_property(m_ref_cliente,"LENGTH",15)
    CALL _ADVPL_set_property(m_ref_cliente,"POSITION",300,10)
    CALL _ADVPL_set_property(m_ref_cliente,"PICTURE","@!")
    #CALL _ADVPL_set_property(m_ref_cliente,"VALID","pol1384_valida_cliente")

    LET m_lupa_cliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_campos)
    CALL _ADVPL_set_property(m_lupa_cliente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cliente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cliente,"POSITION",435,10)
    #CALL _ADVPL_set_property(m_lupa_cliente,"CLICK_EVENT","pol1384_zoom_cliente")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_campos)
    CALL _ADVPL_set_property(l_caixa,"POSITION",475,10)
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
    CALL _ADVPL_set_property(m_browse,"AFTER_ROW_EVENT","pol1384_after_row")

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

    {LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sdo pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","sdo_pedido")}

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Prz entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LDATEFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    #CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",15)
    #CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","prz_entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1384_valida_prazo")
            
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ship date")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    #CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",15)
    #CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ship_date")    

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Num OP")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ordem")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)

END FUNCTION

#---------------------------#
FUNCTION pol1384_after_row()#
#---------------------------#
   
   DEFINE l_linha     INTEGER,
          l_dat_txt   CHAR(10)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
         
   LET l_linha = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   LET l_dat_txt = ma_itens[l_linha].prz_entrega   
   
   IF l_dat_txt IS NULL OR l_dat_txt = ' ' THEN
      LET m_msg = 'A data não pode ser nula ou em branco'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
   
   IF ma_itens[l_linha].prz_entrega < TODAY THEN
      IF ma_itens[l_linha].prz_entrega <> ma_itens[l_linha].prz_ent_ant THEN
         LET m_msg = 'O prazo de entega NÃO é válido'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
         RETURN FALSE
     END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1384_valida_prazo()#
#------------------------------#
   
   DEFINE l_linha     INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
         
   LET l_linha = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   IF ma_itens[l_linha].num_ordem IS NOT NULL THEN
      LET ma_itens[l_linha].prz_entrega = ma_itens[l_linha].prz_ent_ant
      CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","prz_entrega",l_linha,ma_itens[l_linha].prz_ent_ant)
      RETURN TRUE
   END IF

   IF ma_itens[l_linha].prz_entrega IS NULL OR ma_itens[l_linha].prz_entrega < TODAY THEN
      IF ma_itens[l_linha].prz_entrega <> ma_itens[l_linha].prz_ent_ant then
         LET m_msg = 'Prazo de entega inválido'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
         RETURN FALSE
     END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1384_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
   INITIALIZE ma_itens TO NULL
   CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
      
END FUNCTION


#---------------------------------------#
FUNCTION pol1384_ativa_desativa(l_opcao)#
#---------------------------------------#

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

#----------------------#
FUNCTION pol1384_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1384_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","pedidos","pedido")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","pedidos","num_pedido","Pedido",1 {INT},6,0,"zoom_pedidos")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","pedidos","cod_cliente","Cliente",1 {CHAR},15,0,"zoom_clientes")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1384_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1384_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " cod_cliente, num_pedido "
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT num_pedido ",
                      " FROM pedidos",
                     " WHERE ",l_where CLIPPED,
                     " AND cod_empresa = '",p_cod_empresa,"' ",
                     " AND ies_sit_pedido <> '9' ",
                     " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","pedidos:var_cons")
       RETURN FALSE
    END IF

    DECLARE cq_cons SCROLL CURSOR WITH HOLD FOR var_cons

    IF  STATUS <> 0 THEN
        CALL log003_err_sql("DECLARE CURSOR","pedidos:cq_cons")
        RETURN FALSE
    END IF

    FREE var_cons

    OPEN cq_cons

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","open:cq_cons")
       RETURN FALSE
    END IF

    FETCH cq_cons INTO m_num_pedido

    IF STATUS <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","FETCH:cq_cons:1")
       ELSE
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Argumentos de pesquisa não encontrados.")
       END IF
       CALL pol1384_limpa_campos()
       RETURN FALSE
    END IF
    
    IF NOT pol1384_exibe_dados() THEN
       RETURN
    END IF
    
    LET m_ies_cons = TRUE
    LET m_num_pedidoa = m_num_pedido
    
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1384_exibe_dados()#
#-----------------------------#
      
   SELECT pedidos.num_pedido,
          pedidos.cod_cliente,
          clientes.nom_cliente
     INTO mr_campos.num_pedido,
          mr_campos.cod_cliente,
          mr_campos.nom_cliente
     FROM pedidos, clientes
    WHERE pedidos.cod_empresa = p_cod_empresa
      AND pedidos.num_pedido = m_num_pedido
      AND pedidos.cod_cliente = clientes.cod_cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','pedidos:ed')
      RETURN FALSE
   END IF
         
   IF NOT pol1384_load_itens() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
           
END FUNCTION

#----------------------------#
FUNCTION pol1384_load_itens()#
#----------------------------#
   
   DEFINE l_ind    INTEGER
   
   INITIALIZE ma_itens TO NULL
   CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
   LET l_ind = 1
   
   DECLARE cq_le_it CURSOR FOR
    SELECT num_sequencia,
           cod_item,
           qtd_pecas_solic,
           prz_entrega,
           prz_entrega
      FROM ped_itens
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido
   
   FOREACH cq_le_it INTO 
      ma_itens[l_ind].num_seq,    
      ma_itens[l_ind].cod_item,   
      ma_itens[l_ind].qtd_solic,  
      ma_itens[l_ind].prz_entrega,
      ma_itens[l_ind].prz_ent_ant

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ped_itens:cq_le_it')
         RETURN FALSE
      END IF
      
      SELECT den_item 
        INTO ma_itens[l_ind].den_item   
        FROM Item 
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_itens[l_ind].cod_item
      
      IF STATUS = 100 THEN
         LET ma_itens[l_ind].den_item = NULL
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','Item:cq_le_it')
            RETURN FALSE
         END IF
      END IF
      
      SELECT ship_date
        INTO ma_itens[l_ind].ship_date
        FROM ped_itens_ethos
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = m_num_pedido
         AND num_sequencia = ma_itens[l_ind].num_seq

      IF STATUS = 100 THEN
         LET ma_itens[l_ind].ship_date = NULL
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','ped_itens_ethos:cq_le_it')
            RETURN FALSE
         END IF
      END IF

      SELECT num_ordem
        INTO ma_itens[l_ind].num_ordem
        FROM ord_ped_item_547
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = m_num_pedido
         AND num_sequencia = ma_itens[l_ind].num_seq

      IF STATUS = 100 THEN
         LET ma_itens[l_ind].num_ordem = NULL
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','ord_ped_item_547:cq_le_it')
            RETURN FALSE
         END IF
      END IF
      
      IF ma_itens[l_ind].num_ordem IS NULL THEN
         LET ma_itens[l_ind].mensagem = NULL
         CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",l_ind,0,0,0)
      ELSE
         LET ma_itens[l_ind].mensagem = 'Alteração não permitida'
         CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",l_ind,180,14,22)
      END IF
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 1000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapasou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   LET m_qtd_item = l_ind - 1
   
   IF m_qtd_item > 0 THEN
      CALL _ADVPL_set_property(m_browse,"ITEM_COUNT",m_qtd_item)
   ELSE
      LET m_msg = 'Pedido sem itens'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
   END IF
   
   RETURN TRUE

END FUNCTION
   
#----------------------------------#
FUNCTION pol1384_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1384_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_num_pedidoa = m_num_pedido

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_num_pedido
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_num_pedido
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_num_pedido
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_num_pedido
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons:2")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_num_pedido = m_num_pedidoa
         EXIT WHILE
      ELSE
         SELECT 1
           FROM pedidos
          WHERE cod_empresa = p_cod_empresa 
            AND num_pedido = m_num_pedido
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1384_exibe_dados()
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

#--------------------------#
FUNCTION pol1384_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1384_first()#
#-----------------------#

   IF NOT pol1384_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1384_next()#
#----------------------#

   IF NOT pol1384_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1384_previous()#
#--------------------------#

   IF NOT pol1384_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1384_last()#
#----------------------#

   IF NOT pol1384_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1384_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM pedidos
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido = m_num_pedido
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
FUNCTION pol1384_update()#
#------------------------#

   IF NOT pol1384_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1384_prende_registro() THEN
      RETURN FALSE
   END IF
      
   CALL pol1384_ativa_desativa('M')
   CALL _ADVPL_set_property(m_browse,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_browse,"SELECT_ITEM",1,5)

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1384_update_cancel()#
#-------------------------------#

    CALL pol1384_exibe_dados()
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

    RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1384_update_confirm()#
#--------------------------------#
   
   DEFINE l_ret   SMALLINT
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1384_atu_prazo() THEN
      CALL log085_transacao("ROLLBACK")  
      LET m_msg = 'Operação cancelada.'
   ELSE
      CALL log085_transacao("COMMIT")  
      LET m_msg = 'Operação efetuada com sucesso.'
   END IF
      
   CLOSE cq_prende

   CALL pol1384_exibe_dados()
   CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
   
   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1384_atu_prazo()#
#----------------------------#
   
   DEFINE l_linha    SMALLINT
      
   LET m_count =_ADVPL_get_property(m_browse,"ITEM_COUNT")
   
   FOR l_linha = 1 TO m_count
       
       IF ma_itens[l_linha].prz_entrega <> ma_itens[l_linha].prz_ent_ant THEN
         
          UPDATE ped_itens SET prz_entrega = ma_itens[l_linha].prz_entrega
           WHERE cod_empresa = p_cod_empresa
             AND num_pedido = m_num_pedido
             AND num_sequencia = ma_itens[l_linha].num_seq
             
          IF STATUS <> 0 THEN
             CALL log003_err_sql('UPDATE','ped_itens')
             RETURN FALSE
          END IF
          
          SELECT 1
            FROM ped_itens_ethos
           WHERE cod_empresa = p_cod_empresa
             AND num_pedido = m_num_pedido
             AND num_sequencia = ma_itens[l_linha].num_seq
        
          IF STATUS = 0 THEN
             UPDATE ped_itens_ethos SET ship_date = ma_itens[l_linha].prz_entrega
              WHERE cod_empresa = p_cod_empresa
                AND num_pedido = m_num_pedido
                AND num_sequencia = ma_itens[l_linha].num_seq

             IF STATUS <> 0 THEN
                CALL log003_err_sql('UPDATE','ped_itens_ethos')
                RETURN FALSE
             END IF         
          END IF
         
      END IF

   END FOR
   
   RETURN TRUE

END FUNCTION
