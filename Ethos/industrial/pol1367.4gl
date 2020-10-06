#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1367                                                 #
# OBJETIVO: CADASTRO DE ITEM SUCATA POR OPERAÇÃO                    #
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
           p_cod_operac    CHAR(05),
           p_cod_operaca   CHAR(05)
END GLOBALS

DEFINE m_cod_empresa_plano   LIKE empresa.cod_empresa

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_cod_operac      VARCHAR(10),
       m_den_operac      VARCHAR(10),
       m_zoom_operac     VARCHAR(10),
       m_lupa_operac     VARCHAR(10),
       m_cod_item        VARCHAR(10),
       m_den_item        VARCHAR(10),
       m_zoom_item       VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_cod_defeito     VARCHAR(10),
       m_den_defeito     VARCHAR(10),
       m_zoom_defeito    VARCHAR(10),
       m_lupa_defeito    VARCHAR(10),
       m_form_email      VARCHAR(10),
       m_bar_email       VARCHAR(10),
       m_emitente        VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT
       
DEFINE mr_campos         RECORD
       cod_operac        LIKE operacao.cod_operac,
       den_operac        LIKE operacao.den_operac,
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item,
       cod_defeito       LIKE defeito.cod_defeito,
       den_defeito       LIKE defeito.den_defeito
END RECORD

DEFINE mr_email          RECORD
 emitente                CHAR(50),
 receptor                CHAR(150)
END RECORD

#-----------------#
FUNCTION pol1367()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1367-12.00.01  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1367_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1367_menu()#
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
           l_delete, l_email  VARCHAR(10)

    
    CALL pol1367_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE","ITEM SUCATA POR OPERAÇÃO")
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1367_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1367_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1367_create_cancel")
    
    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1367_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1367_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1367_update_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1367_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1367_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1367_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1367_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1367_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1367_delete")

    LET l_email = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_email,"IMAGE","EMAIL_EX") 
    CALL _ADVPL_set_property(l_email,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(l_email,"EVENT","pol1367_email")
    CALL _ADVPL_set_property(l_email,"TOOLTIP","Cadastro de email")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1367_cria_campos(l_panel)

    CALL pol1367_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1367_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1367_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10)

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
    CALL _ADVPL_set_property(l_label,"TEXT","Cod operação:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_operac = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_operac,"LENGTH",6)
    CALL _ADVPL_set_property(m_cod_operac,"VARIABLE",mr_campos,"cod_operac")
    CALL _ADVPL_set_property(m_cod_operac,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_operac,"VALID","pol1367_valida_operacao")

    LET m_lupa_operac = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_operac,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_operac,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_operac,"CLICK_EVENT","pol1367_zoom_operacao")

    LET m_den_operac = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_operac,"LENGTH",50) 
    CALL _ADVPL_set_property(m_den_operac,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_den_operac,"VARIABLE",mr_campos,"den_operac")
    CALL _ADVPL_set_property(m_den_operac,"CAN_GOT_FOCUS",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","item sucata:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_item,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_item,"VARIABLE",mr_campos,"cod_item")
    CALL _ADVPL_set_property(m_cod_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_item,"VALID","pol1367_valida_item")

    LET m_lupa_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_item,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_item,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_item,"CLICK_EVENT","pol1367_zoom_item")

    LET m_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_item,"LENGTH",50) 
    CALL _ADVPL_set_property(m_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_den_item,"VARIABLE",mr_campos,"den_item")
    CALL _ADVPL_set_property(m_den_item,"CAN_GOT_FOCUS",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cód defeito:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_defeito = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_defeito,"LENGTH",4)
    CALL _ADVPL_set_property(m_cod_defeito,"VARIABLE",mr_campos,"cod_defeito")
    CALL _ADVPL_set_property(m_cod_defeito,"PICTURE","@E ####")
    CALL _ADVPL_set_property(m_cod_defeito,"VALID","pol1367_valida_defeito")

    LET m_lupa_defeito = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_defeito,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_defeito,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_defeito,"CLICK_EVENT","pol1367_zoom_defeito")

    LET m_den_defeito = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_defeito,"LENGTH",30) 
    CALL _ADVPL_set_property(m_den_defeito,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_den_defeito,"VARIABLE",mr_campos,"den_defeito")
    CALL _ADVPL_set_property(m_den_defeito,"CAN_GOT_FOCUS",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

END FUNCTION

#----------------------------------------#
FUNCTION pol1367_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   IF m_opcao = 'M' THEN
      CALL _ADVPL_set_property(m_cod_operac,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_lupa_operac,"EDITABLE",FALSE)
   ELSE
      CALL _ADVPL_set_property(m_cod_operac,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_lupa_operac,"EDITABLE",l_status)
   END IF
   
   CALL _ADVPL_set_property(m_cod_item,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_item,"EDITABLE",l_status)

   CALL _ADVPL_set_property(m_cod_defeito,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_defeito,"EDITABLE",l_status)

END FUNCTION

#-----------------------#
FUNCTION pol1367_create()
#-----------------------#
    
    LET m_opcao = 'I'    
    CALL pol1367_limpa_campos()
    CALL pol1367_ativa_desativa(TRUE)
    
    LET m_ies_cons = FALSE
    
    CALL _ADVPL_set_property(m_cod_operac,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1367_create_confirm()
#-------------------------------#
    
   INSERT INTO item_sucata_405(
      cod_empresa, cod_operac, cod_item, cod_defeito)
   VALUES(p_cod_empresa, mr_campos.cod_operac, 
          mr_campos.cod_item, mr_campos.cod_defeito)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','item_sucata_405')
      RETURN FALSE
   END IF
            
    CALL pol1367_ativa_desativa(FALSE)

    RETURN TRUE
        
END FUNCTION

#-------------------------------#
FUNCTION pol1367_create_cancel()#
#-------------------------------#

    CALL pol1367_ativa_desativa(FALSE)
    CALL pol1367_limpa_campos()
    
    RETURN TRUE
        
END FUNCTION

#------------------------------#
FUNCTION pol1367_zoom_operacao()#
#------------------------------#

    DEFINE l_codigo       LIKE operacao.cod_operac,
           l_descricao    LIKE operacao.den_operac
    
    IF  m_zoom_operac IS NULL THEN
        LET m_zoom_operac = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_operac,"ZOOM","zoom_operacao")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_operac,"ACTIVATE")
    
    LET l_codigo    = _ADVPL_get_property(m_zoom_operac,"RETURN_BY_TABLE_COLUMN","operacao","cod_operac")
    LET l_descricao = _ADVPL_get_property(m_zoom_operac,"RETURN_BY_TABLE_COLUMN","operacao","den_operac")

    IF  l_codigo IS NOT NULL THEN
        LET mr_campos.cod_operac = l_codigo
        LET mr_campos.den_operac = l_descricao
    END IF

END FUNCTION

#---------------------------------#
FUNCTION pol1367_valida_operacao()#
#---------------------------------#
    
    CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
    IF  mr_campos.cod_operac IS NULL THEN
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a operação.")
        RETURN FALSE
    END IF

   IF NOT pol1367_le_operacao(mr_campos.cod_operac) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF pol1367_oper_ja_existe(mr_campos.cod_operac) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1367_le_operacao(l_cod)#
#----------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''
      
   SELECT den_operac
     INTO mr_campos.den_operac
     FROM operacao
    WHERE cod_empresa =  p_cod_empresa
      AND cod_operac = l_cod
   
   IF STATUS = 100 THEN
      LET m_msg = 'Operação inexistente no logix.'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','operacao')   
         LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA OPERACAO'    
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1367_oper_ja_existe(l_cod)#
#-------------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''
   
   SELECT 1
     FROM item_sucata_405
    WHERE cod_empresa =  p_cod_empresa
      AND cod_operac = l_cod
   
   IF STATUS = 100 THEN
      RETURN FALSE
   ELSE
      IF STATUS = 0 THEN
         LET m_msg = 'Operação já cadastrada nessa rotina.'
      ELSE
         CALL log003_err_sql('SELECT','item_sucata_405')
         LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA item_sucata_405'   
      END IF
   END IF   
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1367_zoom_item()#
#---------------------------#

    DEFINE l_codigo       LIKE item.cod_item,
           l_descricao    LIKE item.den_item,
           l_where_clause CHAR(300)
    
    IF  m_zoom_item IS NULL THEN
        LET m_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_item,"ZOOM","zoom_item")
    END IF

    LET l_where_clause = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_item,"ACTIVATE")
    
    LET l_codigo    = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")
    LET l_descricao = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","den_item")

    IF  l_codigo IS NOT NULL THEN
        LET mr_campos.cod_item = l_codigo
        CALL pol1367_le_item(l_codigo)
    END IF

END FUNCTION

#-----------------------------#
FUNCTION pol1367_valida_item()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF  mr_campos.cod_item IS NULL THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o item sucata.")
       RETURN FALSE
   END IF

   IF NOT pol1367_le_item(mr_campos.cod_item) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1367_le_item(l_cod)#
#----------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''
      
   SELECT den_item
     INTO mr_campos.den_item
     FROM item
    WHERE cod_empresa =  p_cod_empresa
      AND cod_item = l_cod
      AND ies_situacao = 'A'
      #AND gru_ctr_estoq = 19
   
   IF STATUS = 100 THEN
      LET m_msg = 'Item inexistente ou não está ativo ou não é uma sucata'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item')    
         LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA ITEM'       
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1367_zoom_defeito()#
#------------------------------#

    DEFINE l_codigo       LIKE defeito.cod_defeito,
           l_descricao    LIKE defeito.den_defeito,
           l_where_clause CHAR(300)
    
    IF  m_zoom_defeito IS NULL THEN
        LET m_zoom_defeito = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_defeito,"ZOOM","zoom_defeito")
    END IF
    
    LET l_where_clause = " defeito.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)

    CALL _ADVPL_get_property(m_zoom_defeito,"ACTIVATE")
    
    LET l_codigo    = _ADVPL_get_property(m_zoom_defeito,"RETURN_BY_TABLE_COLUMN","defeito","cod_defeito")
    LET l_descricao = _ADVPL_get_property(m_zoom_defeito,"RETURN_BY_TABLE_COLUMN","defeito","den_defeito")

    IF  l_codigo IS NOT NULL THEN
        LET mr_campos.cod_defeito = l_codigo
        CALL pol1367_le_defeito(l_codigo)
    END IF

END FUNCTION

#--------------------------------#
FUNCTION pol1367_valida_defeito()#
#--------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF  mr_campos.cod_defeito IS NULL THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o código do defeito.")
       RETURN FALSE
   END IF

   IF NOT pol1367_le_defeito(mr_campos.cod_defeito) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1367_le_defeito(l_cod)#
#----------------------------------#
   
   DEFINE l_cod LIKE defeito.cod_defeito
   
   LET m_msg = ''
      
   SELECT den_defeito
     INTO mr_campos.den_defeito
     FROM defeito
    WHERE cod_empresa =  p_cod_empresa
      AND cod_defeito = l_cod
   
   IF STATUS = 100 THEN
      LET m_msg = 'Defeito não cadastrado no Logix'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','defeito')    
         LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA defeito'       
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------#
FUNCTION pol1367_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1367_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","item_sucata_405","sucata")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","item_sucata_405","cod_operac","Operação",1 {CHAR},5,0,"zoom_operacao")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","item_sucata_405","cod_item","Item",1 {CHAR},15,0,"zoom_item")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","item_sucata_405","cod_defeito","Defeito",1 {INT},4,0,"zoom_defeito")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1367_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1367_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " cod_operac "
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT cod_operac, cod_item, cod_defeito ",
                      " FROM item_sucata_405",
                     " WHERE ",l_where CLIPPED,
                       " AND cod_empresa = '",p_cod_empresa,"' ",
                     " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","item_sucata_405")
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

    FETCH cq_cons INTO p_cod_operac

    IF STATUS <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","cq_cons")
       ELSE
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Argumentos de pesquisa não encontrados.")
       END IF
       CALL pol1367_limpa_campos()
       RETURN FALSE
    END IF
    
    CALL pol1367_exibe_dados() 
    
    LET m_ies_cons = TRUE
    LET p_cod_operaca = p_cod_operac
    
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1367_exibe_dados()#
#-----------------------------#
   
   LET m_excluiu = FALSE
   
   SELECT cod_operac,
          cod_item,
          cod_defeito
     INTO mr_campos.cod_operac,
          mr_campos.cod_item,
          mr_campos.cod_defeito
     FROM item_sucata_405
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac = p_cod_operac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item_sucata_405:ed')
      RETURN
   END IF
   
   IF NOT pol1367_le_operacao(mr_campos.cod_operac) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
   
   IF NOT pol1367_le_item(mr_campos.cod_item) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   IF NOT pol1367_le_defeito(mr_campos.cod_defeito) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
        
END FUNCTION

#--------------------------#
FUNCTION pol1367_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1367_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1367_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET p_cod_operaca = p_cod_operac

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO p_cod_operac
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO p_cod_operac
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO p_cod_operac
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO p_cod_operac
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET p_cod_operac = p_cod_operaca
         EXIT WHILE
      ELSE
         SELECT 1
           FROM item_sucata_405
          WHERE cod_empresa =  p_cod_empresa
            AND cod_operac = p_cod_operac
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1367_exibe_dados()
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
FUNCTION pol1367_first()#
#-----------------------#

   IF NOT pol1367_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1367_next()#
#----------------------#

   IF NOT pol1367_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1367_previous()#
#--------------------------#

   IF NOT pol1367_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1367_last()#
#----------------------#

   IF NOT pol1367_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1367_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM item_sucata_405
     WHERE cod_empresa =  p_cod_empresa
       AND cod_operac = mr_campos.cod_operac
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
FUNCTION pol1367_update()#
#------------------------#

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT pol1367_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1367_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'M'    

   CALL pol1367_ativa_desativa(TRUE)
      
   CALL _ADVPL_set_property(m_cod_item,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1367_update_confirm()#
#--------------------------------#
   
   DEFINE l_ret   SMALLINT
   
   UPDATE item_sucata_405
      SET cod_item = mr_campos.cod_item,
          cod_defeito = mr_campos.cod_defeito
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac = mr_campos.cod_operac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','item_sucata_405')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1367_ativa_desativa(FALSE)
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
   
END FUNCTION

#------------------------------#
FUNCTION pol1367_update_cancel()
#------------------------------#
    
    LET p_cod_operac = p_cod_operaca
    CALL pol1367_exibe_dados()
    CALL pol1367_ativa_desativa(FALSE)

    RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1367_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1367_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1367_prende_registro() THEN
      RETURN FALSE
   END IF

   DELETE FROM item_sucata_405
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac = mr_campos.cod_operac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','item_sucata_405')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1367_limpa_campos()
      LET m_excluiu = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION

#-----------------------#
FUNCTION pol1367_email()#
#-----------------------#

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
    CALL _ADVPL_set_property(m_form_email,"INIT_EVENT","pol1367_posiciona")

    LET m_bar_email = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_email)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_email)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",40)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) #vermelho,verde,azul

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_email)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1367_info_dados(l_panel)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_email)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)
    
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
   CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirma,"EVENT","pol1367_conf_email")  

   LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancela,"EVENT","pol1367_canc_email")     

    CALL _ADVPL_set_property(m_form_email,"ACTIVATE",TRUE)
            
    RETURN TRUE
    
END FUNCTION

#-----------------------------------#
FUNCTION pol1367_info_dados(l_panel)#
#-----------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_destinat        VARCHAR(10),
           l_label           VARCHAR(10),
           l_defeito         VARCHAR(10),
           l_den_cent_trab   VARCHAR(10),
           l_den_operac      VARCHAR(10)

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
FUNCTION pol1367_posiciona()#
#---------------------------#

    CALL _ADVPL_set_property(m_emitente,"GET_FOCUS")

    RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1367_conf_email()#
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
FUNCTION pol1367_canc_email()#
#----------------------------#
    
   CALL _ADVPL_set_property(m_form_email,"ACTIVATE",FALSE)    

   RETURN TRUE

END FUNCTION
   