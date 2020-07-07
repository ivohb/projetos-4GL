#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1336                                                 #
# OBJETIVO: VALIDADE DOS LOTES POR CLIENTE                          #
# AUTOR...: IVO                                                     #
# DATA....: 12/01/18                                                #
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
       m_cod_cliente      VARCHAR(10),
       m_nom_cliente      VARCHAR(10),
       m_zoom_client     VARCHAR(10),
       m_lupa_client     VARCHAR(10),
       m_cod_item        VARCHAR(10),
       m_den_item        VARCHAR(10),
       m_qtd_dias        VARCHAR(10),
       m_zoom_item       VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_construct       VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_id_reg          INTEGER
       
DEFINE mr_campos         RECORD
       cod_cliente       LIKE clientes.cod_cliente,
       nom_cliente       LIKE clientes.nom_cliente,
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item,
       qtd_dias          DECIMAL(4,0)
END RECORD

#-----------------#
FUNCTION pol1336()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1336-12.00.00  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1336_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1336_menu()#
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
           l_titulo  CHAR(43)
    
    LET l_titulo = "VALIDADE DOS LOTES POR CLIENTE - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1336_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1336_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1336_create_cancel")
    
    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1336_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1336_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1336_update_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1336_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1336_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1336_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1336_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1336_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1336_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1336_cria_campos(l_panel)

    CALL pol1336_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1336_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1336_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10)

    CALL pol1336_limpa_campos()

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
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_cliente,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_cliente,"VARIABLE",mr_campos,"cod_cliente")
    CALL _ADVPL_set_property(m_cod_cliente,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_cliente,"VALID","pol1336_valida_cliente")

    LET m_lupa_client = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_client,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_client,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_client,"CLICK_EVENT","pol1336_zoom_cliente")

    LET m_nom_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_nom_cliente,"LENGTH",50) 
    CALL _ADVPL_set_property(m_nom_cliente,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_nom_cliente,"VARIABLE",mr_campos,"nom_cliente")
    CALL _ADVPL_set_property(m_nom_cliente,"CAN_GOT_FOCUS",FALSE)
    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Produto:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_item,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_item,"VARIABLE",mr_campos,"cod_item")
    CALL _ADVPL_set_property(m_cod_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_item,"VALID","pol1336_valida_item")

    LET m_lupa_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_item,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_item,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_item,"CLICK_EVENT","pol1336_zoom_item")

    LET m_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_item,"LENGTH",60) 
    CALL _ADVPL_set_property(m_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_den_item,"VARIABLE",mr_campos,"den_item")
    CALL _ADVPL_set_property(m_den_item,"CAN_GOT_FOCUS",FALSE)
    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Validad:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_qtd_dias = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_qtd_dias,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_qtd_dias,"LENGTH",12,0)
    CALL _ADVPL_set_property(m_qtd_dias,"PICTURE","@E ####")
    CALL _ADVPL_set_property(m_qtd_dias,"VARIABLE",mr_campos,"qtd_dias")
    CALL _ADVPL_set_property(m_qtd_dias,"VALID","pol1336_valida_dias")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","dias")    

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

END FUNCTION

#----------------------------------------#
FUNCTION pol1336_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   IF m_opcao = 'M' THEN
      CALL _ADVPL_set_property(m_cod_cliente,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_lupa_client,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_cod_item,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_lupa_item,"EDITABLE",FALSE)
   ELSE
      CALL _ADVPL_set_property(m_cod_cliente,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_lupa_client,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_cod_item,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_lupa_item,"EDITABLE",l_status)
   END IF
   
   CALL _ADVPL_set_property(m_qtd_dias,"EDITABLE",l_status)

END FUNCTION


#-----------------------#
FUNCTION pol1336_create()
#-----------------------#
    
    LET m_opcao = 'I'    
    CALL pol1336_limpa_campos()
    CALL pol1336_ativa_desativa(TRUE)
    
    LET m_ies_cons = FALSE
    
    CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1336_create_confirm()
#-------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF pol1336_reg_ja_existe() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
      
   SELECT MAX(id_registro)
     INTO m_id_reg
     FROM cliente_item_455
   
   IF m_id_reg IS NULL THEN
      LET m_id_reg = 0
   END IF
   
   LET m_id_reg = m_id_reg + 1   
   
   INSERT INTO cliente_item_455(id_registro,
      cod_cliente, cod_item, qtd_dias)
   VALUES(m_id_reg, mr_campos.cod_cliente, mr_campos.cod_item, mr_campos.qtd_dias)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','cliente_item_455')
      RETURN FALSE
   END IF
            
    CALL pol1336_ativa_desativa(FALSE)

    RETURN TRUE
        
END FUNCTION

#-------------------------------#
FUNCTION pol1336_create_cancel()#
#-------------------------------#

    CALL pol1336_ativa_desativa(FALSE)
    CALL pol1336_limpa_campos()
    
    RETURN TRUE
        
END FUNCTION

#------------------------------#
FUNCTION pol1336_zoom_cliente()#
#------------------------------#

    DEFINE l_codigo       LIKE clientes.cod_cliente
    
    IF  m_zoom_client IS NULL THEN
        LET m_zoom_client = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_client,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_client,"ACTIVATE")
    
    LET l_codigo    = _ADVPL_get_property(m_zoom_client,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")

    IF  l_codigo IS NOT NULL THEN
        LET mr_campos.cod_cliente = l_codigo
        CALL pol1336_le_clientes(l_codigo) RETURNING p_status
    END IF

END FUNCTION

#--------------------------------#
FUNCTION pol1336_valida_cliente()#
#--------------------------------#
    
    CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
    IF  mr_campos.cod_cliente IS NULL THEN
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a operação.")
        RETURN FALSE
    END IF

   IF NOT pol1336_le_clientes(mr_campos.cod_cliente) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1336_le_clientes(l_cod)#
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
         LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA clientes'    
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1336_zoom_item()#
#---------------------------#

    DEFINE l_codigo         LIKE item.cod_item,
           l_filtro         CHAR(300)

    IF  m_zoom_item IS NULL THEN
        LET m_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_item,"ZOOM","zoom_item")
    END IF

    LET l_filtro = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' AND item.ies_situacao = 'A' "
    CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_item,"ACTIVATE")
    
    LET l_codigo    = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")

    IF  l_codigo IS NOT NULL THEN
        LET mr_campos.cod_item = l_codigo
        CALL pol1336_le_item(l_codigo)
    END IF

END FUNCTION

#-----------------------------#
FUNCTION pol1336_valida_item()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF  mr_campos.cod_item IS NULL THEN
       RETURN TRUE
   END IF

   IF NOT pol1336_le_item(mr_campos.cod_item) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1336_le_item(l_cod)#
#----------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''
      
   SELECT den_item
     INTO mr_campos.den_item
     FROM item
    WHERE cod_empresa =  p_cod_empresa
      AND cod_item = l_cod
      AND ies_situacao = 'A'
   
   IF STATUS = 100 THEN
      LET m_msg = 'Produto inexistente ou não está ativo no Logix'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA ITEM'       
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1336_valida_dias()#
#-----------------------------#
    
    CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
    IF  mr_campos.qtd_dias IS NULL THEN
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a validade.")
        RETURN FALSE
    END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1336_reg_ja_existe()#
#-------------------------------#
   
   DEFINE l_ret     SMALLINT
   
   LET l_ret = TRUE
   LET m_msg = ''
   
   SELECT 1
     FROM cliente_item_455
    WHERE cod_cliente =  mr_campos.cod_cliente
      AND ( (cod_item = mr_campos.cod_item AND mr_campos.cod_item IS NOT NULL)
          OR (cod_item IS NULL AND mr_campos.cod_item IS NULL))
   
   IF STATUS = 0 THEN
      LET m_msg = 'Cliente / item já cadastrado no POL1336.'
   ELSE
      IF STATUS = 100 THEN
         LET l_ret = FALSE
      ELSE
         LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA CLIENTE_ITEM_455'   
      END IF
   END IF   
   
   RETURN l_ret

END FUNCTION

#----------------------#
FUNCTION pol1336_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1336_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","cliente_item_455","PARAMETROS")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","cliente_item_455","cod_cliente","Cliente",1 {CHAR},15,0,"zoom_clientes")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","cliente_item_455","cod_item","Item",1 {CHAR},15,0,"zoom_item")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1336_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1336_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500),
           l_order     CHAR(200),
           l_sql_stmt  CHAR(2000),
           l_id_reg    INTEGER

    IF l_order IS NULL THEN
       LET l_order = " cod_cliente "
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT id_registro, cod_cliente, cod_item ",
                      " FROM cliente_item_455",
                     " WHERE ",l_where CLIPPED,
                     " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","cliente_item_455")
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
        
    FETCH cq_cons INTO l_id_reg

    IF STATUS <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","cq_cons")
       ELSE
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Argumentos de pesquisa não encontrados.")
       END IF
       CALL pol1336_limpa_campos()
       RETURN FALSE
    END IF
    
    IF NOT pol1336_exibe_dados(l_id_reg) THEN
       RETURN FALSE
    END IF
    
    LET m_ies_cons = TRUE
    
    RETURN TRUE
    
END FUNCTION

#-------------------------------------#
FUNCTION pol1336_exibe_dados(l_id_reg)#
#-------------------------------------#
   
   DEFINE l_id_reg      INTEGER
   
   LET m_excluiu = FALSE
   
   SELECT cod_cliente,
          cod_item,
          qtd_dias
     INTO mr_campos.cod_cliente,
          mr_campos.cod_item,
          mr_campos.qtd_dias
     FROM cliente_item_455
    WHERE id_registro = l_id_reg

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cliente_item_455:ed')
      RETURN FALSE
   END IF
   
   IF NOT pol1336_le_clientes(mr_campos.cod_cliente) THEN
      LET mr_campos.nom_cliente = ''
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
   
   IF mr_campos.cod_item IS NOT NULL THEN
      IF NOT pol1336_le_item(mr_campos.cod_item) THEN
         LET mr_campos.den_item = ''
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
   ELSE
      LET mr_campos.den_item = ''
   END IF
       
   LET m_id_reg = l_id_reg

   RETURN TRUE 
   
END FUNCTION

#--------------------------#
FUNCTION pol1336_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1336_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao     CHAR(01),
          l_achou     SMALLINT,
          l_id_reg    INTEGER

   IF NOT pol1336_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO l_id_reg
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO l_id_reg
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO l_id_reg
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO l_id_reg
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         EXIT WHILE
      ELSE
         SELECT 1
           FROM cliente_item_455
          WHERE id_registro = l_id_reg
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1336_exibe_dados(l_id_reg)
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
FUNCTION pol1336_first()#
#-----------------------#

   IF NOT pol1336_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1336_next()#
#----------------------#

   IF NOT pol1336_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1336_previous()#
#--------------------------#

   IF NOT pol1336_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1336_last()#
#----------------------#

   IF NOT pol1336_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1336_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM cliente_item_455
     WHERE id_registro = m_id_reg
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
FUNCTION pol1336_update()#
#------------------------#

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT pol1336_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1336_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'M'    

   CALL pol1336_ativa_desativa(TRUE)
      
   CALL _ADVPL_set_property(m_qtd_dias,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1336_update_confirm()#
#--------------------------------#
   
   DEFINE l_ret   SMALLINT
   
   UPDATE cliente_item_455
      SET qtd_dias = mr_campos.qtd_dias
     WHERE id_registro = m_id_reg

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','cliente_item_455')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1336_ativa_desativa(FALSE)
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
   
END FUNCTION

#------------------------------#
FUNCTION pol1336_update_cancel()
#------------------------------#
    
    CALL pol1336_exibe_dados(m_id_reg)
    CALL pol1336_ativa_desativa(FALSE)

    RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1336_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1336_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1336_prende_registro() THEN
      RETURN FALSE
   END IF

   DELETE FROM cliente_item_455
     WHERE id_registro = m_id_reg

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','cliente_item_455')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1336_limpa_campos()
      LET m_excluiu = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION
