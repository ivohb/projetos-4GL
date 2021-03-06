
#---PRAZO M�NIMO----#

DATABASE logix

GLOBALS
   
   DEFINE p_cod_empresa          CHAR(02),
          g_tipo_sgbd            CHAR(03)

   DEFINE p_user                 LIKE usuarios.cod_usuario

END GLOBALS

DEFINE m_pan_prz_min     VARCHAR(10),
       m_tipo            VARCHAR(10),
       m_prazo           VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_construct       VARCHAR(10)
       
DEFINE mr_prz_min        RECORD
       tip_pedido        CHAR(02),
       prz_minimo        DECIMAL(5,0)
END RECORD

DEFINE m_op_prz_min      CHAR(01),
       m_msg             VARCHAR(150),
       m_tip_pedido      CHAR(02),
       m_tip_pedidoa     CHAR(02),
       m_ies_prz_min     SMALLINT,
       m_exc_prz_min     SMALLINT

#---------------------------------------------#
FUNCTION pol1387_prz_min(l_fpanel,l_statusbar)#
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
    CALL _ADVPL_set_property(l_create,"EVENT","pol1387_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1387_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1387_create_cancel")
    
    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1387_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1387_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1387_update_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1387_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1387_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1387_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1387_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1387_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1387_delete")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1387_cap_campos(l_panel)
    
END FUNCTION


#---------------------------------------#
FUNCTION pol1387_cap_campos(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_prz_min = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_prz_min,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_pan_prz_min,"ENABLE",FALSE)
    #CALL _ADVPL_set_property(m_pan_prz_min,"BACKGROUND_COLOR",225,232,232) 
              
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_prz_min)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Tip pedido:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_tipo = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_prz_min)     
    CALL _ADVPL_set_property(m_tipo,"POSITION",130,10) 
    CALL _ADVPL_set_property(m_tipo,"LENGTH",15,0)    
    CALL _ADVPL_set_property(m_tipo,"PICTURE","@!")    
    CALL _ADVPL_set_property(m_tipo,"VARIABLE",mr_prz_min,"tip_pedido")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_prz_min)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Prazo m�nimo:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_prazo = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_prz_min)     
    CALL _ADVPL_set_property(m_prazo,"POSITION",130,40) 
    CALL _ADVPL_set_property(m_prazo,"LENGTH",5,0)    
    CALL _ADVPL_set_property(m_prazo,"VARIABLE",mr_prz_min,"prz_minimo")

END FUNCTION

#-----------------------#
FUNCTION pol1387_create()
#-----------------------#
    
    LET m_op_prz_min = 'I'    
    INITIALIZE mr_prz_min.* TO NULL
    CALL pol1387_setCapacidade(TRUE)
    CALL _ADVPL_set_property(m_tipo,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1387_setCapacidade(l_status)#
#---------------------------------------#
   
   DEFINE l_status         SMALLINT
   
   IF m_op_prz_min = 'I' THEN
      CALL _ADVPL_set_property(m_tipo,"ENABLE",l_status)
   ELSE
      CALL _ADVPL_set_property(m_tipo,"ENABLE",FALSE)
   END IF
   
   CALL _ADVPL_set_property(m_pan_prz_min,"ENABLE",l_status)

END FUNCTION

#-------------------------------#
FUNCTION pol1387_create_cancel()#
#-------------------------------#
    
    INITIALIZE mr_prz_min.* TO NULL
    CALL pol1387_setCapacidade(FALSE)
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1387_create_confirm()
#-------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')

   IF NOT pol1387_valid_chave() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_tipo,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   IF NOT pol1387_valid_prazo() THEN
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_begin()
   
   IF NOT pol1387_ins_prazo() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   CALL LOG_transaction_commit()
   CALL pol1387_setCapacidade(FALSE)
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1387_valid_chave()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')

   IF  mr_prz_min.tip_pedido IS NULL THEN
       LET m_msg = "Informe o tipo de pedido."
       RETURN FALSE
   END IF
   
   SELECT 1 FROM tip_pedido_405
    WHERE cod_empresa = p_cod_empresa
      AND tip_pedido = mr_prz_min.tip_pedido
   
   IF STATUS = 0 THEN
      LET m_msg = "Tipo de pedido j� cadastrado no pol1387."
      RETURN FALSE
   ELSE
      IF STATUS <> 100 THEN
         LET m_msg = log0030_mensagem_get_texto()
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION    

#-----------------------------#
FUNCTION pol1387_valid_prazo()#
#-----------------------------#
   
   DEFINE l_compon     SMALLINT,
          l_ind        SMALLINT

   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')

   IF  mr_prz_min.prz_minimo IS NULL OR mr_prz_min.prz_minimo <= 0 THEN
       LET m_msg = "Informe o prazo m�nimo de entrega."
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       CALL _ADVPL_set_property(m_prazo,"GET_FOCUS")
       RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1387_ins_prazo()#
#---------------------------#

   
   INSERT INTO tip_pedido_405(cod_empresa, tip_pedido, prz_minimo)
    VALUES(p_cod_empresa, mr_prz_min.tip_pedido, mr_prz_min.prz_minimo)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','tip_pedido_405')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION
 
#----------------------#
FUNCTION pol1387_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
     IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1387_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","tip_pedido_405","prz_min")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","tip_pedido_405","tip_pedido","Tipo",1 {CHAR},2,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","tip_pedido_405","prz_minimo","Prazo",1 {DEC},5,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1387_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1387_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " tip_pedido "
    END IF
    
    LET m_ies_prz_min = FALSE

    LET l_sql_stmt = "SELECT tip_pedido ",
                      " FROM tip_pedido_405",
                     " WHERE ",l_where CLIPPED,
                     " AND cod_empresa = '",p_cod_empresa,"' ",
                     " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","tip_pedido_405:PREPARE")
       RETURN FALSE
    END IF

    DECLARE cq_cons SCROLL CURSOR WITH HOLD FOR var_cons

    IF  STATUS <> 0 THEN
        CALL log003_err_sql("DECLARE CURSOR","tip_pedido_405:DECLARE")
        RETURN FALSE
    END IF

    FREE var_cons

    OPEN cq_cons

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","tip_pedido_405:OPEN")
       RETURN FALSE
    END IF

    FETCH cq_cons INTO m_tip_pedido

    IF STATUS <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","tip_pedido_405:FETCH")
       ELSE
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Argumentos de pesquisa n�o encontrados.")
       END IF
       RETURN FALSE
    END IF
    
    IF NOT pol1387_exibe_dados() THEN
       RETURN
    END IF
    
    LET m_ies_prz_min = TRUE
    LET m_tip_pedidoa = m_tip_pedido
    
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1387_exibe_dados()#
#-----------------------------#
   
   LET m_exc_prz_min = FALSE
   
   SELECT tip_pedido, prz_minimo
     INTO mr_prz_min.tip_pedido,
          mr_prz_min.prz_minimo
     FROM tip_pedido_405
    WHERE cod_empresa = p_cod_empresa
      AND tip_pedido = m_tip_pedido

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','tip_pedido_405:ed')
      RETURN FALSE
   END IF
      
   RETURN TRUE
           
END FUNCTION

#--------------------------#
FUNCTION pol1387_ies_cons()#
#--------------------------#

   IF NOT m_ies_prz_min THEN
      LET m_msg = 'N�o h� consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1387_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1387_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_tip_pedidoa = m_tip_pedido

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_tip_pedido
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_tip_pedido
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_tip_pedido
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_tip_pedido
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons:2")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","N�o existem mais registros nesta dire��o.")
         END IF
         LET m_tip_pedido = m_tip_pedidoa
         EXIT WHILE
      ELSE
         SELECT 1
           FROM tip_pedido_405
          WHERE cod_empresa = p_cod_empresa
            AND tip_pedido = m_tip_pedido
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1387_exibe_dados()
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
FUNCTION pol1387_first()#
#-----------------------#

   IF NOT pol1387_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1387_next()#
#----------------------#

   IF NOT pol1387_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1387_previous()#
#--------------------------#

   IF NOT pol1387_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1387_last()#
#----------------------#

   IF NOT pol1387_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1387_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prz_min CURSOR FOR
    SELECT 1
      FROM tip_pedido_405
     WHERE cod_empresa = p_cod_empresa
       AND tip_pedido = m_tip_pedido
     FOR UPDATE 
    
    OPEN cq_prz_min

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_prz_min")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
    
   FETCH cq_prz_min
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_prz_min")
      CALL log085_transacao("ROLLBACK")
      CLOSE cq_prz_min
      RETURN FALSE
   END IF

END FUNCTION

#------------------------#
FUNCTION pol1387_update()#
#------------------------#

   IF m_exc_prz_min THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "N�o h� dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT pol1387_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1387_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_op_prz_min = 'M'    
   
   CALL pol1387_setCapacidade(TRUE)
   CALL _ADVPL_set_property(m_prazo,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1387_update_confirm()#
#--------------------------------#
   
   DEFINE l_ret   SMALLINT

   IF NOT pol1387_valid_prazo() THEN
      RETURN FALSE
   END IF

   UPDATE tip_pedido_405
      SET prz_minimo = mr_prz_min.prz_minimo
    WHERE cod_empresa = p_cod_empresa
      AND tip_pedido = m_tip_pedido
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','tip_pedido_405:update')
      LET l_ret = FALSE
   ELSE 
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1387_setCapacidade(FALSE)
   ELSE
      CALL log085_transacao("ROLLBACK")  
   END IF
   
   CLOSE cq_prz_min
      
   RETURN l_ret
   
END FUNCTION

#------------------------------#
FUNCTION pol1387_update_cancel()
#------------------------------#
    
    LET m_tip_pedido = m_tip_pedidoa
    CALL pol1387_exibe_dados()
    CALL pol1387_setCapacidade(FALSE)

    RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1387_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_exc_prz_min THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "N�o h� dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1387_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclus�o do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1387_prende_registro() THEN
      RETURN FALSE
   END IF

   LET l_ret = TRUE

   DELETE FROM tip_pedido_405
    WHERE cod_empresa = p_cod_empresa
      AND tip_pedido = m_tip_pedido

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','tip_pedido_405:delete')
      LET l_ret = FALSE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      INITIALIZE mr_prz_min.* TO NULL
      LET m_exc_prz_min = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prz_min
   
   RETURN l_ret
        
END FUNCTION
