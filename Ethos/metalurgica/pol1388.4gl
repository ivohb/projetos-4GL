#---CAPACIDADE DA F�BRICA----#

DATABASE logix

GLOBALS
   
   DEFINE p_cod_empresa          CHAR(02),
          g_tipo_sgbd            CHAR(03)

   DEFINE p_user                 LIKE usuarios.cod_usuario

END GLOBALS

DEFINE m_construct       VARCHAR(10),
       m_pan_cap_fab     VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_zoom_item       VARCHAR(10),
       m_item            VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_capacdade       VARCHAR(10)
       
DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cap_fab     SMALLINT,
       m_ies_prz_min     SMALLINT,
       m_op_cap_fab      CHAR(01),
       m_op_prz_min      CHAR(01),
       m_exc_cap_fab     SMALLINT,
       m_carregando      SMALLINT,
       m_ind             INTEGER,
       m_index           INTEGER,
       m_den_item        CHAR(76),
       m_cod_itema       CHAR(15),
       m_cod_item        CHAR(15),
       p_status          SMALLINT

DEFINE mr_cap_fab        RECORD
       cod_item          CHAR(15),
       den_item          CHAR(76),
       cap_fab_dia       INTEGER
END RECORD

#---------------------------------------------#
FUNCTION pol1388_cap_fab(l_fpanel,l_statusbar)#
#---------------------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_statusbar VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_inform    VARCHAR(10),
           l_update    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10),
           l_create,
           l_first,
           l_previous,
           l_next,
           l_last,
           l_delete    VARCHAR(10)

    LET m_statusbar = l_statusbar
    
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1388_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1388_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1388_create_cancel")
    
    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1388_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1388_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1388_update_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1388_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1388_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1388_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1388_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1388_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1388_delete")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1388_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1388_cap_campos(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1388_cap_campos(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_cap_fab = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_cap_fab,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_pan_cap_fab,"ENABLE",FALSE)
    #CALL _ADVPL_set_property(m_pan_cap_fab,"BACKGROUND_COLOR",225,232,232) 
              
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cap_fab)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","C�d item:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_cap_fab)     
    CALL _ADVPL_set_property(m_item,"POSITION",130,10) 
    CALL _ADVPL_set_property(m_item,"LENGTH",15,0)    
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_cap_fab,"cod_item")
    CALL _ADVPL_set_property(m_item,"VALID","pol1388_valid_item")    

    LET m_lupa_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_cap_fab)
    CALL _ADVPL_set_property(m_lupa_item,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_item,"POSITION",260,10)     
    CALL _ADVPL_set_property(m_lupa_item,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_item,"CLICK_EVENT","pol1388_zoom_item")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cap_fab)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Descri��o:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_cap_fab)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",130,40) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",76,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cap_fab,"den_item")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cap_fab)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","Capacidade di�ria:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_capacdade = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_cap_fab)     
    CALL _ADVPL_set_property(m_capacdade,"POSITION",130,70) 
    CALL _ADVPL_set_property(m_capacdade,"LENGTH",10,0)    
    CALL _ADVPL_set_property(m_capacdade,"VARIABLE",mr_cap_fab,"cap_fab_dia")

END FUNCTION

#----------------------------#
FUNCTION pol1388_valid_item()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_cap_fab.cod_item IS NULL THEN
      RETURN TRUE
   END IF
   
   IF NOT pol1388_le_item(mr_cap_fab.cod_item) THEN
      RETURN FALSE
   END IF
   
   LET mr_cap_fab.den_item = m_den_item   
   
   RETURN TRUE
   
END FUNCTION   

#------------------------------#   
FUNCTION pol1388_le_item(l_cod)#
#------------------------------#
   
   DEFINE l_cod           CHAR(15)
   
   SELECT den_item
     INTO m_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_cod

   IF STATUS <> 0 THEN
      LET m_den_item = NULL
      LET m_msg = log0030_mensagem_get_texto()
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION    

#---------------------------#
FUNCTION pol1388_zoom_item()#
#---------------------------#

    DEFINE l_codigo         LIKE item.cod_item,
           l_descri         LIKE item.den_item,
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
       LET mr_cap_fab.cod_item = l_codigo
       CALL pol1388_le_item(mr_cap_fab.cod_item) RETURNING p_status
       LET mr_cap_fab.den_item = m_den_item
   END IF
    
END FUNCTION

#-----------------------#
FUNCTION pol1388_create()
#-----------------------#
    
    LET m_op_cap_fab = 'I'    
    INITIALIZE mr_cap_fab.* TO NULL
    CALL pol1388_setCapacidade(TRUE)
    CALL _ADVPL_set_property(m_item,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1388_setCapacidade(l_status)#
#---------------------------------------#
   
   DEFINE l_status         SMALLINT
   
   IF m_op_cap_fab = 'I' THEN
      CALL _ADVPL_set_property(m_item,"ENABLE",l_status)
   ELSE
      CALL _ADVPL_set_property(m_item,"ENABLE",FALSE)
   END IF
   
   CALL _ADVPL_set_property(m_pan_cap_fab,"ENABLE",l_status)

END FUNCTION

#-------------------------------#
FUNCTION pol1388_create_cancel()#
#-------------------------------#
    
    INITIALIZE mr_cap_fab.* TO NULL
    CALL pol1388_setCapacidade(FALSE)
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1388_create_confirm()
#-------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')

   IF mr_cap_fab.cod_item IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", 'Informe o item')
      CALL _ADVPL_set_property(m_item,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF NOT pol1388_valid_capac() THEN
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_begin()
   
   IF NOT pol1388_ins_capacidade() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   CALL LOG_transaction_commit()
   CALL pol1388_setCapacidade(FALSE)
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1388_valid_capac()#
#-----------------------------#
   
   DEFINE l_compon     SMALLINT,
          l_ind        SMALLINT

   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')

   IF  mr_cap_fab.cap_fab_dia IS NULL OR mr_cap_fab.cap_fab_dia <= 0 THEN
       LET m_msg = "Informe a capacidade di�ria da f�brica"
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       CALL _ADVPL_set_property(m_capacdade,"GET_FOCUS")
       RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1388_ins_capacidade()#
#--------------------------------#

   LET m_msg = NULL
   
   SELECT 1 FROM cap_fabrica_405
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_cap_fab.cod_item
   
   IF STATUS = 0 THEN
      LET m_msg = 'Item j� cadasrado no pol1388.'       
   ELSE
      IF STATUS <> 100 THEN
         LET m_msg = log0030_mensagem_get_texto()
      END IF
   END IF
   
   IF m_msg IS NULL THEN
      INSERT INTO cap_fabrica_405(cod_empresa, cod_item, cap_fab_dia)
       VALUES(p_cod_empresa, mr_cap_fab.cod_item, mr_cap_fab.cap_fab_dia)
      IF STATUS <> 0 THEN
         LET m_msg = log0030_mensagem_get_texto()
      END IF
   END IF
   
   IF m_msg IS NOT NULL THEN 
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_item,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#----------------------#
FUNCTION pol1388_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1388_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","cap_fabrica_405","capac_fab")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","cap_fabrica_405","cod_iteml","Item",1 {CHAR},15,0,"zoom_item")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","cap_fabrica_405","cap_fab_dia","Capacidade",1 {DEC},5,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1388_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1388_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " cod_item "
    END IF
    
    LET m_ies_cap_fab = FALSE

    LET l_sql_stmt = "SELECT cod_item ",
                      " FROM cap_fabrica_405",
                     " WHERE ",l_where CLIPPED,
                     " AND cod_empresa = '",p_cod_empresa,"' ",
                     " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","cap_fabrica_405:PREPARE")
       RETURN FALSE
    END IF

    DECLARE cq_cons SCROLL CURSOR WITH HOLD FOR var_cons

    IF  STATUS <> 0 THEN
        CALL log003_err_sql("DECLARE CURSOR","cap_fabrica_405:DECLARE")
        RETURN FALSE
    END IF

    FREE var_cons

    OPEN cq_cons

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cap_fabrica_405:OPEN")
       RETURN FALSE
    END IF

    FETCH cq_cons INTO m_cod_item

    IF STATUS <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","cap_fabrica_405:FETCH")
       ELSE
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Argumentos de pesquisa n�o encontrados.")
       END IF
       RETURN FALSE
    END IF
    
    IF NOT pol1388_exibe_dados() THEN
       RETURN
    END IF
    
    LET m_ies_cap_fab = TRUE
    LET m_cod_itema = m_cod_item
    
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1388_exibe_dados()#
#-----------------------------#
   
   LET m_exc_cap_fab = FALSE
   
   SELECT cap_fab_dia
     INTO mr_cap_fab.cap_fab_dia
     FROM cap_fabrica_405
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cap_fabrica_405:ed')
      RETURN FALSE
   END IF
   
   LET mr_cap_fab.cod_item = m_cod_item
   CALL pol1388_le_item(m_cod_item) RETURNING p_status
   LET mr_cap_fab.den_item = m_den_item
   
   RETURN TRUE
           
END FUNCTION

#--------------------------#
FUNCTION pol1388_ies_cons()#
#--------------------------#

   IF NOT m_ies_cap_fab THEN
      LET m_msg = 'N�o h� consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1388_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1388_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_cod_itema = m_cod_item

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_cod_item
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_cod_item
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_cod_item
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_cod_item
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons:2")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","N�o existem mais registros nesta dire��o.")
         END IF
         LET m_cod_item = m_cod_itema
         EXIT WHILE
      ELSE
         SELECT 1
           FROM cap_fabrica_405
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = m_cod_item
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1388_exibe_dados()
               LET l_achou = TRUE
               EXIT WHILE
            ELSE 
               CALL log003_err_sql("FETCH CURSOR","cq_cons:FETCH")
               EXIT WHILE
            END IF
         END IF
      END IF               
   
   END WHILE
   
   RETURN l_achou
   
END FUNCTION

#-----------------------#
FUNCTION pol1388_first()#
#-----------------------#

   IF NOT pol1388_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1388_next()#
#----------------------#

   IF NOT pol1388_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1388_previous()#
#--------------------------#

   IF NOT pol1388_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1388_last()#
#----------------------#

   IF NOT pol1388_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1388_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM cap_fabrica_405
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = m_cod_item
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
FUNCTION pol1388_update()#
#------------------------#

   IF m_exc_cap_fab THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "N�o h� dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT pol1388_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1388_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_op_cap_fab = 'M'    
   
   CALL pol1388_setCapacidade(TRUE)
   CALL _ADVPL_set_property(m_capacdade,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1388_update_confirm()#
#--------------------------------#
   
   DEFINE l_ret   SMALLINT

   IF NOT pol1388_valid_capac() THEN
      RETURN FALSE
   END IF

   UPDATE cap_fabrica_405
      SET cap_fab_dia = mr_cap_fab.cap_fab_dia
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','cap_fabrica_405:update')
      LET l_ret = FALSE
   ELSE 
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1388_setCapacidade(FALSE)
   ELSE
      CALL log085_transacao("ROLLBACK")  
   END IF
   
   CLOSE cq_prende
      
   RETURN l_ret
   
END FUNCTION

#------------------------------#
FUNCTION pol1388_update_cancel()
#------------------------------#
    
    LET m_cod_item = m_cod_itema
    CALL pol1388_exibe_dados()
    CALL pol1388_setCapacidade(FALSE)

    RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1388_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_exc_cap_fab THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "N�o h� dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1388_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclus�o do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1388_prende_registro() THEN
      RETURN FALSE
   END IF

   LET l_ret = TRUE

   DELETE FROM cap_fabrica_405
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','cap_fabrica_405:delete')
      LET l_ret = FALSE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      INITIALIZE mr_cap_fab.* TO NULL
      LET m_exc_cap_fab = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION


