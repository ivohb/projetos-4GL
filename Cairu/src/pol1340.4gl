#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1340                                                 #
# OBJETIVO: CLIENTES PARA ENVIO DE E-MAILS SOBRE TITULOS EM ATRASO  #
# AUTOR...: IVO                                                     #
# DATA....: 23/04/18                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18)
END GLOBALS

DEFINE  m_id_registro   INTEGER,
        a_id_registro   INTEGER

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_cod_cliente     VARCHAR(10),
       m_nom_cliente     VARCHAR(10),
       m_zoom_cliente    VARCHAR(10),
       m_lupa_cliente    VARCHAR(10),
       m_construct       VARCHAR(10),
       m_panel           VARCHAR(10),
       m_dias_envio      VARCHAR(10),
       m_dias_renvio     VARCHAR(10),
       m_ies_enviar      VARCHAR(10),
       m_emitente        VARCHAR(10),
       m_zoom_emitente   VARCHAR(10),
       m_lupa_emitente   VARCHAR(10),
       m_email_cliente   VARCHAR(10),
       m_limite          VARCHAR(10),
       m_obs             VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT
       
DEFINE mr_campos      RECORD
 cod_cliente          CHAR(15),
 nom_cliente          CHAR(36),
 qtd_dias_envio       INTEGER,
 qtd_dias_renvio      INTEGER,
 ies_enviar           CHAR(01),
 emitente_email       CHAR(08),
 nom_emitente         CHAR(36),
 email_cliente        CHAR(120),
 limite_saldo         DECIMAL(12,2),
 observacao           CHAR(120)
END RECORD

#-----------------#
FUNCTION pol1340()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1340-12.00.04  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1340_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1340_menu()#
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
    
    LET l_titulo  = "CLIENTES PARA ENVIO DE E-MAILS SOBRE TITULOS EM ATRASO"
    CALL pol1340_limpa_campos()
    LET m_ies_cons = FALSE

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1340_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1340_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1340_create_cancel")

    LET l_update = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"IMAGE","UPDATE_EX") 
    CALL _ADVPL_set_property(l_update,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_update,"TOOLTIP","Modificar dados")
    CALL _ADVPL_set_property(l_update,"EVENT","pol1340_alterar")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1340_ies_alterar")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1340_no_alterar")
    
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1340_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1340_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1340_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1340_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1340_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1340_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1340_cria_campos(l_panel)

    CALL pol1340_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1340_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1340_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)

    LET m_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_panel,"HEIGHT",40)

    LET m_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel,"ALIGN","LEFT")
    CALL _ADVPL_set_property(m_panel,"WIDTH",200)

    LET m_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",4)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    

    LET m_cod_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_cliente,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_cliente,"VARIABLE",mr_campos,"cod_cliente")
    CALL _ADVPL_set_property(m_cod_cliente,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_cliente,"VALID","pol1340_valida_cliente")

    LET m_lupa_cliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_cliente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cliente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cliente,"CLICK_EVENT","pol1340_zoom_cliente")

    LET m_nom_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_nom_cliente,"LENGTH",50) 
    CALL _ADVPL_set_property(m_nom_cliente,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_nom_cliente,"VARIABLE",mr_campos,"nom_cliente")
    CALL _ADVPL_set_property(m_nom_cliente,"CAN_GOT_FOCUS",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Dias para envio:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dias_envio = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_dias_envio,"LENGTH",15)
    CALL _ADVPL_set_property(m_dias_envio,"VARIABLE",mr_campos,"qtd_dias_envio")
    CALL _ADVPL_set_property(m_dias_envio,"PICTURE","@E ###")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Dias p/ re-envio:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dias_renvio = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_dias_renvio,"LENGTH",15)
    CALL _ADVPL_set_property(m_dias_renvio,"VARIABLE",mr_campos,"qtd_dias_renvio")
    CALL _ADVPL_set_property(m_dias_renvio,"PICTURE","@E ###")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Enviar e-amil:")    

    LET m_ies_enviar= _ADVPL_create_component(NULL,"LCHECKBOX",l_layout)
    CALL _ADVPL_set_property(m_ies_enviar,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_ies_enviar,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_ies_enviar,"VARIABLE",mr_campos,"ies_enviar")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Emitente e-amil:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_emitente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_emitente,"LENGTH",8)
    CALL _ADVPL_set_property(m_emitente,"VARIABLE",mr_campos,"emitente_email")
    CALL _ADVPL_set_property(m_emitente,"VALID","pol1340_valida_emitente")

    LET m_lupa_emitente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_emitente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_emitente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_emitente,"CLICK_EVENT","pol1340_zoom_emitemte")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",40) 
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_campos,"nom_emitente")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",8,240)     
    CALL _ADVPL_set_property(l_label,"TEXT","Email cliente:")    

    LET m_email_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(m_email_cliente,"POSITION",117,240)     
    CALL _ADVPL_set_property(m_email_cliente,"LENGTH",120)
    CALL _ADVPL_set_property(m_email_cliente,"ENABLE",FALSE) 
    CALL _ADVPL_set_property(m_email_cliente,"VARIABLE",mr_campos,"email_cliente")
    CALL _ADVPL_set_property(m_email_cliente,"GOT_FOCUS_EVENT","pol1340_ve_cliente") 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",8,280)     
    CALL _ADVPL_set_property(l_label,"TEXT","Cobrar saldo a partir de:")    

    LET m_limite = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_limite,"POSITION",135,280)     
    CALL _ADVPL_set_property(m_limite,"LENGTH",15)
    CALL _ADVPL_set_property(m_limite,"ENABLE",FALSE) 
    CALL _ADVPL_set_property(m_limite,"PICTURE","@E ######9.99")
    CALL _ADVPL_set_property(m_limite,"VARIABLE",mr_campos,"limite_saldo")
    CALL _ADVPL_set_property(m_limite,"GOT_FOCUS_EVENT","pol1340_ve_cliente") 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",8,320)     
    CALL _ADVPL_set_property(l_label,"TEXT","Observa��o:")    

    LET m_obs = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(m_obs,"POSITION",135,320)     
    CALL _ADVPL_set_property(m_obs,"LENGTH",120)
    CALL _ADVPL_set_property(m_obs,"VARIABLE",mr_campos,"observacao")

END FUNCTION

#----------------------------#
FUNCTION pol1340_ve_cliente()#
#----------------------------#

   IF mr_campos.cod_cliente IS NULL THEN
      CALL _ADVPL_set_property(m_email_cliente,"ENABLE",FALSE)
      CALL _ADVPL_set_property(m_limite,"ENABLE",TRUE)
   ELSE
      CALL _ADVPL_set_property(m_email_cliente,"ENABLE",TRUE)
      CALL _ADVPL_set_property(m_limite,"ENABLE",FALSE)
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1340_zoom_cliente()#
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
        CALL pol1340_le_cliente(l_codigo)
    END IF

END FUNCTION

#----------------------------------#
FUNCTION pol1340_le_cliente(l_cod)#
#----------------------------------#
   
   DEFINE l_cod CHAR(15)

   IF l_cod IS NULL THEN
      LET mr_campos.nom_cliente = ''
      RETURN TRUE
   END IF
   
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
FUNCTION pol1340_valida_cliente()#
#--------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF NOT pol1340_le_cliente(mr_campos.cod_cliente) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF m_opcao = 'I' THEN
      IF pol1340_cli_ja_existe(mr_campos.cod_cliente) THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF      
   END IF
   
   CALL pol1340_ve_cliente()
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1340_cli_ja_existe(l_cod)#
#------------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''

   IF l_cod IS NULL THEN
      SELECT COUNT(*)
        INTO m_count
        FROM cliente_email_912
       WHERE cod_cliente IS NULL
   ELSE   
      SELECT COUNT(*)
        INTO m_count
        FROM cliente_email_912
       WHERE cod_cliente = l_cod
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cliente_email_912')
      LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA cliente_email_912'   
      RETURN TRUE
   END IF
         
   IF m_count > 0 THEN
      IF l_cod IS NULL THEN
         LET m_msg = 'J� existe um registro padr�o cadastrado no POL1340.'
      ELSE
         LET m_msg = 'Cliente j� cadastrado no POL1340.'
      END IF
      RETURN TRUE
   END IF   
   
   RETURN FALSE

END FUNCTION

#-------------------------------#
FUNCTION pol1340_zoom_emitemte()#
#-------------------------------#

    DEFINE l_codigo    LIKE usuarios.cod_usuario,
           l_descri    LIKE usuarios.nom_funcionario
    
    IF  m_zoom_emitente IS NULL THEN
        LET m_zoom_emitente = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_emitente,"ZOOM","zoom_usuarios")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_emitente,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_emitente,"RETURN_BY_TABLE_COLUMN","usuarios","cod_usuario")
    LET l_descri = _ADVPL_get_property(m_zoom_emitente,"RETURN_BY_TABLE_COLUMN","usuarios","nom_funcionario")

    IF  l_codigo IS NOT NULL THEN
        LET mr_campos.emitente_email = l_codigo
        CALL pol1340_le_usuario(l_codigo)
    END IF

END FUNCTION

#---------------------------------#
FUNCTION pol1340_le_usuario(l_cod)#
#---------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''
      
   SELECT nom_funcionario
     INTO mr_campos.nom_emitente
     FROM usuarios
    WHERE cod_usuario = l_cod
   
   IF STATUS = 100 THEN
      LET m_msg = 'Usuario inexistente no Logix'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cliente')    
         LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA USUARIOS'       
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1340_valida_emitente()#
#---------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF  mr_campos.emitente_email IS NULL THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o emitente de e-amil")
       RETURN FALSE
   END IF

   IF NOT pol1340_le_usuario(mr_campos.emitente_email) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------------#
FUNCTION pol1340_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   CALL _ADVPL_set_property(m_panel,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_email_cliente,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_limite,"ENABLE",l_status)

END FUNCTION

#-----------------------#
FUNCTION pol1340_create()
#-----------------------#
    
    LET m_opcao = 'I'    
    CALL pol1340_limpa_campos()
    CALL pol1340_ativa_desativa(TRUE)
    
    LET m_ies_cons = FALSE
    
    CALL _ADVPL_set_property(m_cod_cliente,"ENABLE",TRUE)
    CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")    
    
    SELECT emitente_email
      INTO mr_campos.emitente_email
      FROM cliente_email_912
     WHERE cod_cliente IS NULL
    
    CALL pol1340_le_usuario(mr_campos.emitente_email) RETURNING p_status
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1340_create_confirm()
#-------------------------------#

   IF NOT pol1340_valid_form() THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN FALSE
   END IF

   SELECT MAX(id_registro)
     INTO m_id_registro
     FROM cliente_email_912

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cliente_email_912:max')
      RETURN FALSE
   END IF

   IF m_id_registro IS NULL THEN
      LET m_id_registro = 0
   END IF
   
   LET m_id_registro = m_id_registro + 1
       
   INSERT INTO cliente_email_912(
      id_registro,
      cod_cliente,    
      qtd_dias_envio, 
      qtd_dias_renvio,
      ies_enviar,     
      emitente_email,
      email_cliente,
      limite_saldo,
      observacao)
   VALUES(m_id_registro,
          mr_campos.cod_cliente,
          mr_campos.qtd_dias_envio,
          mr_campos.qtd_dias_renvio,
          mr_campos.ies_enviar,
          mr_campos.emitente_email,
          mr_campos.email_cliente,
          mr_campos.limite_saldo,
          mr_campos.observacao)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','cliente_email_912')
      RETURN FALSE
   END IF
            
   CALL pol1340_ativa_desativa(FALSE)

   RETURN TRUE
        
END FUNCTION

#----------------------------#
FUNCTION pol1340_valid_form()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')

   LET m_msg = 'Campos em negrito s�o obrigat�rios.'

   IF mr_campos.qtd_dias_envio IS NULL OR mr_campos.qtd_dias_envio < 0 THEN 
      CALL _ADVPL_set_property(m_dias_envio,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_campos.qtd_dias_renvio IS NULL OR mr_campos.qtd_dias_renvio < 0 THEN 
      CALL _ADVPL_set_property(m_dias_renvio,"GET_FOCUS")
      RETURN FALSE
   END IF
      
   IF  mr_campos.emitente_email IS NULL THEN
       CALL _ADVPL_set_property(m_emitente,"GET_FOCUS")
       RETURN FALSE
   END IF
   
   LET m_msg = ''
      
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1340_create_cancel()#
#-------------------------------#

    CALL pol1340_ativa_desativa(FALSE)
    CALL pol1340_limpa_campos()
    
    RETURN TRUE
        
END FUNCTION

#----------------------#
FUNCTION pol1340_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1340_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","cliente_email_912","cliente")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","cliente_email_912","cod_cliente","Cliente",1 {CHAR},15,0,"zoom_clientes")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","cliente_email_912","emitente_email","Emitente",1 {CHAR},8,0,"zoom_usuarios")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1340_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1340_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " cod_cliente "
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT id_registro ",
                      " FROM cliente_email_912",
                     " WHERE ",l_where CLIPPED,
                     " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","cliente_email_912")
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
          LET m_msg = "Argumentos de pesquisa n�o encontrados."
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       END IF
       CALL pol1340_limpa_campos()
       RETURN FALSE
    END IF
    
    CALL pol1340_exibe_dados() RETURNING p_status 
    
    LET m_ies_cons = TRUE
    LET a_id_registro = m_id_registro
    
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1340_exibe_dados()#
#-----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_excluiu = FALSE
   INITIALIZE mr_campos.* TO NULL
   
   SELECT cod_cliente,
          qtd_dias_envio,
          qtd_dias_renvio,
          ies_enviar,
          emitente_email,
          email_cliente,
          limite_saldo,
          observacao
     INTO mr_campos.cod_cliente,
          mr_campos.qtd_dias_envio, 
          mr_campos.qtd_dias_renvio,
          mr_campos.ies_enviar,     
          mr_campos.emitente_email,
          mr_campos.email_cliente,
          mr_campos.limite_saldo,
          mr_campos.observacao
     FROM cliente_email_912
    WHERE id_registro = m_id_registro

    IF STATUS <> 0 THEN
       CALL log003_err_sql("SELECT","cliente_email_912:ed")
       RETURN FALSE
    END IF
         
   IF NOT pol1340_le_cliente(mr_campos.cod_cliente) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   IF NOT pol1340_le_usuario(mr_campos.emitente_email) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1340_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'N�o h� consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1340_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1340_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET a_id_registro = m_id_registro

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
               "ERROR_TEXT","N�o existem mais registros nesta dire��o.")
         END IF
         LET m_id_registro = a_id_registro
         EXIT WHILE
      ELSE
         SELECT 1
           FROM cliente_email_912
          WHERE id_registro = m_id_registro
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1340_exibe_dados()
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
FUNCTION pol1340_first()#
#-----------------------#

   IF NOT pol1340_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1340_next()#
#----------------------#

   IF NOT pol1340_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1340_previous()#
#--------------------------#

   IF NOT pol1340_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1340_last()#
#----------------------#

   IF NOT pol1340_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1340_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM cliente_email_912
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

#-------------------------#
FUNCTION pol1340_alterar()#
#-------------------------#
   
   LET m_opcao = 'A'
    
   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "N�o h� dados na tela a serem modificados.")
      RETURN FALSE
   END IF
   
   IF NOT pol1340_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1340_prende_registro() THEN
      RETURN FALSE
   END IF
   
   CALL pol1340_ativa_desativa(TRUE)
   CALL _ADVPL_set_property(m_cod_cliente,"ENABLE",FALSE)
   CALL pol1340_ve_cliente()
   CALL _ADVPL_set_property(m_dias_envio,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1340_ies_alterar()#
#-----------------------------#
   
   DEFINE l_ret   SMALLINT
   
   LET l_ret = TRUE

   IF NOT pol1340_valid_form() THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN FALSE
   END IF

   UPDATE cliente_email_912
      SET qtd_dias_envio = mr_campos.qtd_dias_envio,
          qtd_dias_renvio = mr_campos.qtd_dias_renvio,
          ies_enviar = mr_campos.ies_enviar,
          emitente_email = mr_campos.emitente_email,
          email_cliente = mr_campos.email_cliente,
          limite_saldo = mr_campos.limite_saldo,
          observacao = mr_campos.observacao
    WHERE id_registro = m_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','cliente_email_912')
      LET l_ret = FALSE
   END IF
         
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1340_ativa_desativa(FALSE)
      CALL _ADVPL_set_property(m_cod_cliente,"EDITABLE",TRUE)
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
   
END FUNCTION

#----------------------------#
FUNCTION pol1340_no_alterar()#
#----------------------------#
    
   CALL pol1340_exibe_dados()
   CALL pol1340_ativa_desativa(FALSE)
   CALL _ADVPL_set_property(m_cod_cliente,"EDITABLE",TRUE)

   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1340_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "N�o h� dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1340_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclus�o do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1340_prende_registro() THEN
      RETURN FALSE
   END IF

   DELETE FROM cliente_email_912
    WHERE id_registro = m_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','cliente_email_912')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1340_limpa_campos()
      LET m_excluiu = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION
