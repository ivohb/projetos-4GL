#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1337                                                 #
# OBJETIVO: CLIENTES PARA NÃO AGRUPAMENTO DE PEDIDOS NA NF          #
# AUTOR...: IVO                                                     #
# DATA....: 15/03/18                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           p_cod_cliente   CHAR(15),
           p_cod_clientea  CHAR(15)
END GLOBALS

DEFINE m_cod_empresa_plano   LIKE empresa.cod_empresa

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_cod_cliente     VARCHAR(10),
       m_nom_cliente     VARCHAR(10),
       m_zoom_cliente    VARCHAR(10),
       m_lupa_cliente    VARCHAR(10),
       m_construct       VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT
       
DEFINE mr_campos         RECORD
       cod_cliente          LIKE clientes.cod_cliente,
       nom_cliente          LIKE clientes.nom_cliente
END RECORD

#-----------------#
FUNCTION pol1337()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1337-12.00.00  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1337_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1337_menu()#
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
           l_delete  VARCHAR(10)

    DEFINE l_titulo  CHAR(40)
    
    LET l_titulo  = "CLIENTES PARA NÃO AGRUPAR PEDIDOS NA NF"
    CALL pol1337_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1337_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1337_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1337_create_cancel")
    
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1337_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1337_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1337_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1337_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1337_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1337_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1337_cria_campos(l_panel)

    CALL pol1337_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1337_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1337_cria_campos(l_container)#
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
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_cliente,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_cliente,"VARIABLE",mr_campos,"cod_cliente")
    CALL _ADVPL_set_property(m_cod_cliente,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_cliente,"VALID","pol1337_valida_cliente")

    LET m_lupa_cliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_cliente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cliente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cliente,"CLICK_EVENT","pol1337_zoom_cliente")

    LET m_nom_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_nom_cliente,"LENGTH",50) 
    CALL _ADVPL_set_property(m_nom_cliente,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_nom_cliente,"VARIABLE",mr_campos,"nom_cliente")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

END FUNCTION

#----------------------------------------#
FUNCTION pol1337_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   CALL _ADVPL_set_property(m_cod_cliente,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_cliente,"EDITABLE",l_status)

END FUNCTION

#-----------------------#
FUNCTION pol1337_create()
#-----------------------#
    
    LET m_opcao = 'I'    
    CALL pol1337_limpa_campos()
    CALL pol1337_ativa_desativa(TRUE)
    
    LET m_ies_cons = FALSE
    
    CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1337_create_confirm()
#-------------------------------#
    
   INSERT INTO cliente_agrupa_970(cod_cliente)
   VALUES(mr_campos.cod_cliente)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','cliente_agrupa_970')
      RETURN FALSE
   END IF
            
    CALL pol1337_ativa_desativa(FALSE)

    RETURN TRUE
        
END FUNCTION

#-------------------------------#
FUNCTION pol1337_create_cancel()#
#-------------------------------#

    CALL pol1337_ativa_desativa(FALSE)
    CALL pol1337_limpa_campos()
    
    RETURN TRUE
        
END FUNCTION

#-------------------------------------#
FUNCTION pol1337_cli_ja_existe(l_cod)#
#-------------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''
   
   SELECT 1
     FROM cliente_agrupa_970
    WHERE cod_cliente = l_cod
   
   IF STATUS = 100 THEN
      RETURN FALSE
   ELSE
      IF STATUS = 0 THEN
         LET m_msg = 'Cliente já cadastrada nessa rotina.'
      ELSE
         CALL log003_err_sql('SELECT','cliente_agrupa_970')
         LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA CLIENTE_AGRUPA_970'   
      END IF
   END IF   
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1337_zoom_cliente()#
#------------------------------#

    DEFINE l_codigo    LIKE clientes.cod_cliente,
           l_descri    LIKE clientes.nom_cliente
    
    IF  m_zoom_cliente IS NULL THEN
        LET m_zoom_cliente = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_cliente,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_cliente,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_descri = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")

    IF  l_codigo IS NOT NULL THEN
        LET mr_campos.cod_cliente = l_codigo
        CALL pol1337_le_cliente(l_codigo)
    END IF

END FUNCTION

#----------------------------------#
FUNCTION pol1337_le_cliente(l_cod)#
#----------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''
      
   SELECT nom_cliente
     INTO mr_campos.nom_cliente
     FROM clientes
    WHERE cod_cliente = l_cod
   
   IF STATUS = 100 THEN
      LET m_msg = 'Cliente inexistente no Logix'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cliente')    
         LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA CLIENTE'       
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1337_valida_cliente()#
#--------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF  mr_campos.cod_cliente IS NULL THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o cliente sucata.")
       RETURN FALSE
   END IF

   IF NOT pol1337_le_cliente(mr_campos.cod_cliente) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF pol1337_cli_ja_existe(mr_campos.cod_cliente) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
   
   RETURN TRUE

END FUNCTION


#----------------------#
FUNCTION pol1337_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1337_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","cliente_agrupa_970","cliente")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","cliente_agrupa_970","cod_cliente","Cliente",1 {CHAR},15,0,"zoom_cliente")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1337_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1337_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " cod_cliente "
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT cod_cliente ",
                      " FROM cliente_agrupa_970",
                     " WHERE ",l_where CLIPPED,
                     " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","cliente_agrupa_970")
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

    FETCH cq_cons INTO p_cod_cliente

    IF STATUS <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","cq_cons")
       ELSE
          LET m_msg = "Argumentos de pesquisa não encontrados."
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       END IF
       CALL pol1337_limpa_campos()
       RETURN FALSE
    END IF
    
    CALL pol1337_exibe_dados() 
    
    LET m_ies_cons = TRUE
    LET p_cod_clientea = p_cod_cliente
    
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1337_exibe_dados()#
#-----------------------------#
   
   LET m_excluiu = FALSE
   LET mr_campos.cod_cliente = p_cod_cliente
         
   IF NOT pol1337_le_cliente(mr_campos.cod_cliente) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
        
END FUNCTION

#--------------------------#
FUNCTION pol1337_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1337_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1337_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET p_cod_clientea = p_cod_cliente

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO p_cod_cliente
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO p_cod_cliente
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO p_cod_cliente
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO p_cod_cliente
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET p_cod_cliente = p_cod_clientea
         EXIT WHILE
      ELSE
         SELECT 1
           FROM cliente_agrupa_970
          WHERE cod_cliente = p_cod_cliente
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1337_exibe_dados()
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
FUNCTION pol1337_first()#
#-----------------------#

   IF NOT pol1337_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1337_next()#
#----------------------#

   IF NOT pol1337_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1337_previous()#
#--------------------------#

   IF NOT pol1337_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1337_last()#
#----------------------#

   IF NOT pol1337_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1337_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM cliente_agrupa_970
     WHERE cod_cliente = mr_campos.cod_cliente
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
FUNCTION pol1337_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1337_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1337_prende_registro() THEN
      RETURN FALSE
   END IF

   DELETE FROM cliente_agrupa_970
    WHERE cod_cliente = mr_campos.cod_cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','cliente_agrupa_970')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1337_limpa_campos()
      LET m_excluiu = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION
