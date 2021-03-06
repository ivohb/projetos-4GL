#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1402                                                 #
# OBJETIVO: ITENS PARA BLOQUEIO DE PEDIDOS                          #
# DATA....: 22/01/2021                                              #
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
       m_construct       VARCHAR(10),
       m_brz_item        VARCHAR(10),
       m_pnl_cabec       VARCHAR(10),
       m_pnl_item        VARCHAR(10),
       m_item            VARCHAR(10),
       m_zoom_item       VARCHAR(10)

DEFINE mr_cabec          RECORD
       cod_empresa       LIKE item.cod_empresa,
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item
END RECORD
       
DEFINE ma_item           ARRAY[5000] OF RECORD
       cod_empresa       LIKE item.cod_empresa,
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item,
       filler            CHAR(01)
END RECORD

DEFINE m_ies_cons        SMALLINT,
       m_qtd_item        INTEGER,
       m_msg             CHAR(120),
       m_ind             INTEGER,
       m_carregando      SMALLINT,
       m_opcao           VARCHAR(01)

DEFINE m_den_item        LIKE item.den_item
       
#-----------------#
FUNCTION pol1402()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   IF NOT log0150_verifica_se_tabela_existe("item_bloqueio_547") THEN 
      IF NOT pol1402_cria_tabela() THEN
         RETURN FALSE
      END IF
   END IF

   LET p_versao = "pol1402-12.00.00  "   
   CALL pol1402_menu()

END FUNCTION

#-----------------------------#
FUNCTION pol1402_cria_tabela()#
#-----------------------------#

   CREATE TABLE item_bloqueio_547 (
      cod_empresa       VARCHAR(02),
      cod_item          VARCHAR(15),
      den_item          VARCHAR(76)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','item_bloqueio_547')
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX ix_item_bloqueio_547
    ON item_bloqueio_547(cod_empresa, cod_item);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','ix_item_bloqueio_547')
      RETURN FALSE
   END IF
   
   RETURN TRUE      
   
END FUNCTION

#----------------------#
FUNCTION pol1402_menu()#
#----------------------#

    DEFINE l_menubar,
           l_create,
           l_delete,
           l_find,
           l_panel,
           l_titulo  VARCHAR(80)

    LET l_titulo = 'ITENS PARA BLOQUEIO DE PEDIDOS - ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1402_find")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1402_insert")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1402_insert_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1402_insert_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1402_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1402_monta_cabec(l_panel)
    CALL pol1402_monta_item(l_panel)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1402_monta_cabec(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_lupa            VARCHAR(10)

    LET m_pnl_cabec = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pnl_cabec,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pnl_cabec,"HEIGHT",40)
    CALL _ADVPL_set_property(m_pnl_cabec,"ENABLE",FALSE) 
    #CALL _ADVPL_set_property(m_pnl_cabec,"BACKGROUND_COLOR",231,237,237)
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pnl_cabec)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",6)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"cod_empresa")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",2)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","  Item:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_item,"LENGTH",15)
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_cabec,"cod_item")
    CALL _ADVPL_set_property(m_item,"VALID","pol1402_valid_item")

    LET l_lupa = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(l_lupa,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa,"CLICK_EVENT","pol1402_zoom_item")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"den_item")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",76)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)


END FUNCTION

#---------------------------------------#
FUNCTION pol1402_monta_item(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_pnl_item = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pnl_item,"ALIGN","CENTER")
          
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pnl_item)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brz_item = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_item,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_item,"BEFORE_ROW_EVENT","pol1402_before_row")
    

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Empresa")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_empresa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",400)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_item,"SET_ROWS",ma_item,1)

END FUNCTION

#----------------------------#
FUNCTION pol1402_before_row()#
#----------------------------#
      
   DEFINE l_linha          INTEGER
   
   LET m_opcao = 'R'
   
   IF m_carregando THEN
      RETURN TRUE
   END IF
      
   LET l_linha = _ADVPL_get_property(m_brz_item,"ROW_SELECTED")

   IF l_linha IS NULL OR l_linha = 0 THEN
      RETURN TRUE
   END IF
   
   CALL pol1402_set_item(l_linha)         
   CALL pol1402_set_compon (TRUE)
   CALL _ADVPL_set_property(m_item,"GET_FOCUS")
   CALL pol1402_set_compon(FALSE)
   CALL _ADVPL_set_property(m_brz_item,"SELECT_ITEM",l_linha,1)

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1402_valid_item()#
#----------------------------#      
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF m_opcao <> 'I' THEN
      RETURN TRUE
   END IF

   IF mr_cabec.cod_item IS NULL THEN
      LET m_msg = 'Informe o item'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET mr_cabec.den_item = pol1402_le_item(mr_cabec.cod_item) 
   
   IF mr_cabec.den_item IS NULL THEN
      RETURN FALSE
   END IF
   
   SELECT cod_item FROM item_bloqueio_547
    WHERE cod_empresa = mr_cabec.cod_empresa
      AND cod_item = mr_cabec.cod_item

   IF STATUS = 0 THEN
      LET m_msg = 'Item j� cadastrado no POL1402'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','item_bloqueio_547')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION
   
#---------------------------#
FUNCTION pol1402_zoom_item()#
#---------------------------#
    
   DEFINE l_item           LIKE item.cod_item,
          l_desc           LIKE item.den_item,
          l_where_clause   VARCHAR(300)
          
   IF  m_zoom_item IS NULL THEN
       LET m_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_item,"ZOOM","zoom_item")
   END IF

    LET l_where_clause = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)

   CALL _ADVPL_get_property(m_zoom_item,"ACTIVATE")

   LET l_item = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")
   LET l_desc = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","den_item")

   IF l_item IS NOT NULL THEN
      LET mr_cabec.cod_item = l_item
      LET mr_cabec.den_item = pol1402_le_item(mr_cabec.cod_item) 
   END IF
   
   CALL _ADVPL_set_property(m_item,"GET_FOCUS")
   
END FUNCTION

#---------------------------------#
FUNCTION pol1402_le_item(l_codigo)#
#---------------------------------#
   
   DEFINE l_codigo       LIKE item.cod_item,
          l_descricao    LIKE item.den_item
   
   SELECT den_item INTO l_descricao
     FROM item WHERE cod_empresa = mr_cabec.cod_empresa
      AND cod_item = l_codigo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      LET l_descricao = NULL
   END IF
   
   RETURN l_descricao
   
END FUNCTION

#----------------------#
FUNCTION pol1402_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    LET m_opcao = 'P'
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1402_find")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","item_bloqueio_547","item")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","item_bloqueio_547","cod_item","C�digo",1 {CHAR},15,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","item_bloqueio_547","den_item","Descri��o",1 {CHAR},76,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1402_pesquisa(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#------------------------------------------#
FUNCTION pol1402_pesquisa(l_where, l_order)#
#------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)
    DEFINE l_ind        INTEGER

    IF l_order IS NULL THEN
       LET l_order = " cod_item "
    END IF
    
    LET l_sql_stmt = 
       " SELECT * ",
       " FROM item_bloqueio_547 ",
        " WHERE ",l_where CLIPPED,
        " AND cod_empresa =  '",p_cod_empresa,"' ",
        " ORDER BY ",l_order
   
   CALL pol1402_exibe_item(l_sql_stmt)
   CALL pol1402_set_item(1)
   
END FUNCTION

#-------------------------#
FUNCTION pol1402_prepare()#
#-------------------------#

   DEFINE l_sql_stmt CHAR(2000)
                        
   LET l_sql_stmt =
       " SELECT * ",
    "  FROM item_bloqueio_547 ",
    " WHERE cod_empresa =  '",p_cod_empresa,"' "

   CALL pol1402_exibe_item(l_sql_stmt)

END FUNCTION

#--------------------------------------#
FUNCTION pol1402_exibe_item(l_sql_stmt)#
#--------------------------------------#
   
   DEFINE l_sql_stmt   CHAR(2000),
          l_ind        INTEGER

   CALL _ADVPL_set_property(m_brz_item,"CLEAR")
   LET m_carregando = TRUE
   INITIALIZE ma_item TO NULL
   LET l_ind = 1
   
    PREPARE prep_query FROM l_sql_stmt

    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","preparando query")
       RETURN FALSE
    END IF

   DECLARE cq_query CURSOR FOR prep_query
   
   FOREACH cq_query INTO ma_item[l_ind].*
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','carregando dados para a grade')
         EXIT FOREACH
      END IF

      LET l_ind = l_ind + 1
      
      IF l_ind > 5000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou\n',
                     'Ser�o exibidos apenas 5000 registros.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   IF l_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_item,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'N�o h� registros para os par�metros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   LET m_carregando = FALSE
        
END FUNCTION

#---------------------------------#
FUNCTION pol1402_set_item(l_linha)#
#---------------------------------#
   
   DEFINE l_linha     INTEGER
   
   LET mr_cabec.cod_empresa = ma_item[l_linha].cod_empresa
   LET mr_cabec.cod_item = ma_item[l_linha].cod_item
   LET mr_cabec.den_item = ma_item[l_linha].den_item

END FUNCTION

#------------------------------------#
FUNCTION pol1402_set_compon(l_status)#
#------------------------------------#

   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pnl_cabec,"ENABLE",l_status)
   LET m_carregando = l_status
               
END FUNCTION

#------------------------#
FUNCTION pol1402_insert()#
#------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   LET m_opcao = 'I'
   INITIALIZE mr_cabec.* TO NULL
   LET mr_cabec.cod_empresa = p_cod_empresa      
   CALL pol1402_set_compon(TRUE)
   CALL _ADVPL_set_property(m_item,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1402_insert_canc()#
#-----------------------------#

   CALL pol1402_set_compon(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_cabec.* TO NULL
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1402_insert_conf()#
#-----------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_msg = NULL
   
   CALL  LOG_transaction_begin()
   
   IF NOT pol1402_insert_dados() THEN
      CALL  LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL  LOG_transaction_commit()
   CALL pol1402_prepare()
   CALL pol1402_set_compon(FALSE)
   
   RETURN TRUE

END FUNCTION        

#------------------------------#
FUNCTION pol1402_insert_dados()#
#------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   INSERT INTO item_bloqueio_547
    VALUES(mr_cabec.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','item_bloqueio_547')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#-------------------------#
 FUNCTION pol1402_prende()#
#-------------------------#
   
   CALL  LOG_transaction_begin()
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM item_bloqueio_547
     WHERE cod_empresa = mr_cabec.cod_empresa
       AND cod_item = mr_cabec.cod_item
     FOR UPDATE 
    
    OPEN cq_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_prende")
       CALL LOG_transaction_rollback()
       RETURN FALSE
    END IF
    
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_prende")
      CALL LOG_transaction_rollback()
      CLOSE cq_prende
      RETURN FALSE
   END IF

END FUNCTION

#------------------------#
FUNCTION pol1402_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF mr_cabec.cod_item IS NULL THEN
      LET m_msg = 'Selecione um registro para excluir'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclus�o do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1402_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM item_bloqueio_547
     WHERE cod_empresa = mr_cabec.cod_empresa
       AND cod_item = mr_cabec.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','item_bloqueio_547')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_cabec.* TO NULL
      CALL pol1402_prepare()
   ELSE
      CALL LOG_transaction_rollback()     
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION
