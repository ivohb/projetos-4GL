#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1409                                                 #
# OBJETIVO: CARTEIRAS P/ UNIFICA��O DE OMs                          #
# AUTOR...: IVO                                                     #
# DATA....: 30/09/2020                                              #
#-------------------------------------------------------------------#
#Lista de pre�o
{VPD30100 � GERA��O DE ROMANEIO
POL1407 - UNIFICA��O DE ROMANEIO
VPD20028 � AUDITORIA }


DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           m_panel           VARCHAR(10),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_ies_cons        SMALLINT,
       m_excluiu         SMALLINT

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_folder          VARCHAR(10)
       
DEFINE m_count           INTEGER,
       m_msg             VARCHAR(200),
       m_ind             INTEGER,
       m_sql_stmt        CHAR(2000),
       m_qtd_estoque     DECIMAL(10,3)

DEFINE m_brz_cart         VARCHAR(10),
       m_fold_cart        VARCHAR(10),
       m_zoom_cart        VARCHAR(10),
       m_lupa_cart        VARCHAR(10),
       m_pan_cart         VARCHAR(10),
       m_cart_construct   VARCHAR(10),
       m_cod_cart         VARCHAR(10),
       m_op_cart          CHAR(01),
       m_car_cart         SMALLINT

DEFINE mr_cart           RECORD
       empresa           CHAR(02),
       carteira          CHAR(02)
END RECORD

DEFINE ma_cart           ARRAY[100] OF RECORD
       empresa           CHAR(02),
       carteira          CHAR(02),
       filler            CHAR(01)
END RECORD
              
DEFINE m_unif_construct   VARCHAR(10),
       m_car_unif         SMALLINT

DEFINE m_brz_unif         VARCHAR(10),
       m_fold_unif        VARCHAR(10),
       m_pan_unif         VARCHAR(10),
       m_op_unif          CHAR(01),
       m_pedido           VARCHAR(10)

DEFINE mr_unif          RECORD
       pedido           INTEGER,
       cliente          VARCHAR(15),
       nome             VARCHAR(36),
       ies_unificado    CHAR(01)
END RECORD

DEFINE ma_unif            ARRAY[1000] OF RECORD
       pedido             INTEGER,
       sequencia          INTEGER,
       item               VARCHAR(15),
       entrega            DATE,
       solicitado         DECIMAL(10,3),
       atendido           DECIMAL(10,3),
       cancelado          DECIMAL(10,3),
       romaneado          DECIMAL(10,3),
       romaneio           INTEGER,
       saldo              DECIMAL(10,3),
       estoque            DECIMAL(10,3),
       filler             CHAR(01)
END RECORD
                   
#-----------------#
FUNCTION pol1409()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1409-12.00.00  "
   CALL pol1409_tab_temp()
      
   LET m_car_cart = TRUE
   LET m_car_unif = TRUE
   INITIALIZE mr_cart.* TO NULL
   INITIALIZE mr_unif.* TO NULL
   
   CALL pol1409_menu()

END FUNCTION

#--------------------------#
FUNCTION pol1409_tab_temp()#
#--------------------------#
   
   DROP TABLE w_estoque
   
   CREATE TEMP TABLE w_estoque (
    empresa   VARCHAR(02),
    item      VARCHAR(15),
    saldo     DECIMAL(10,3)
   )
   
   CREATE UNIQUE INDEX ix_w_estoque
    ON w_estoque(empresa, item)

END FUNCTION
    
#----------------------#
FUNCTION pol1409_menu()#
#----------------------#

    DEFINE l_menubar       VARCHAR(10),
           l_fechar        VARCHAR(10),
           l_panel         VARCHAR(10),
           l_fpanel        VARCHAR(10),
           l_label         VARCHAR(10),
           l_titulo        CHAR(80)

    LET l_titulo = 'CARTEIRAS P/ UNIFICA��O DE OMs  - OMs UNIFICADAS ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET m_folder = _ADVPL_create_component(NULL,"LFOLDER",m_dialog)
    CALL _ADVPL_set_property(m_folder,"ALIGN","CENTER")
    
    # FOLDER carteira 

    LET m_fold_cart = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_cart,"TITLE","Carteiras p/ unifica��o de OMs")
    CALL pol1409_cart(m_fold_cart)

    # FOLDER ordens

    LET m_fold_unif = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_unif,"TITLE","OMs unificadas")
    CALL pol1409_unif(m_fold_unif)

    CALL _ADVPL_set_property(m_folder,"FOLDER_SELECTED",1)
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION
   
#------------------------#
FUNCTION pol1409_fechar()#
#------------------------#

   RETURN TRUE
   
END FUNCTION

#-----------------------------------------#
FUNCTION pol1409_desativa_folder(l_folder)#
#-----------------------------------------#

   DEFINE l_folder             CHAR(01)
             
   CASE l_folder
        WHEN '1' 
           CALL _ADVPL_set_property(m_fold_unif,"ENABLE",FALSE)
        WHEN '2' 
           CALL _ADVPL_set_property(m_fold_cart,"ENABLE",FALSE)      
   END CASE
   
END FUNCTION

#------------------------------#
FUNCTION pol1409_ativa_folder()#
#------------------------------#

   CALL _ADVPL_set_property(m_fold_cart,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_unif,"ENABLE",TRUE) 

END FUNCTION


#---Rotinas cadastro de carteiras ----#

#-----------------------------#
FUNCTION pol1409_cart(l_fpanel)#
#-----------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_delete    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10),
           l_create    VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1409_cart_find")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1409_cart_insert")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1409_cart_insert_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1409_cart_insert_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1409_cart_delete")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1409_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1409_cart_campo(l_panel)
    CALL pol1409_cart_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1409_cart_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_cart = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_cart,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_cart,"HEIGHT",40)
    #CALL _ADVPL_set_property(m_pan_cart,"BACKGROUND_COLOR",225,232,232) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cart)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_cart)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",60,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",2)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cart,"empresa")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cart)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",150,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Carteira:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_cart = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_cart)     
    CALL _ADVPL_set_property(m_cod_cart,"POSITION",200,10) 
    CALL _ADVPL_set_property(m_cod_cart,"LENGTH",19)    
    CALL _ADVPL_set_property(m_cod_cart,"VARIABLE",mr_cart,"carteira")
    CALL _ADVPL_set_property(m_cod_cart,"VALID","pol1409_cart_valid_cart")
             
    CALL _ADVPL_set_property(m_pan_cart,"ENABLE",FALSE)

END FUNCTION

#--------------------------------------#
FUNCTION pol1409_cart_grade(l_container)#
#--------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_cart = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_cart,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_cart,"BEFORE_ROW_EVENT","pol1409_cart_before_row")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cart)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","empresa")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","empresa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cart)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Carteira")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","carteira")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cart)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_cart,"SET_ROWS",ma_cart,1)
    CALL _ADVPL_set_property(m_brz_cart,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_cart,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_cart,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#---------------------------------#
FUNCTION pol1409_cart_before_row()#
#---------------------------------#
   
   DEFINE l_linha          INTEGER
   
   LET m_op_cart = 'R'
   
   IF m_car_cart THEN
      RETURN TRUE
   END IF
      
   LET l_linha = _ADVPL_get_property(m_brz_cart,"ROW_SELECTED")
   
   IF l_linha IS NULL OR l_linha = 0 THEN
      RETURN TRUE
   END IF
   
   CALL pol1409_cart_set_item(l_linha)         
   CALL pol1409_cart_ativa(TRUE)
   CALL _ADVPL_set_property(m_cod_cart,"GET_FOCUS")
   CALL pol1409_cart_ativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1409_cart_set_item(l_linha)#
#-------------------------------------#
   
   DEFINE l_linha     INTEGER
   
   LET mr_cart.empresa = ma_cart[l_linha].empresa
   LET mr_cart.carteira = ma_cart[l_linha].carteira

END FUNCTION

#------------------------------------#
FUNCTION pol1409_cart_ativa(l_status)#
#------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pan_cart,"ENABLE",l_status)
            
END FUNCTION


#---------------------------------#
FUNCTION pol1409_cart_valid_cart()#
#---------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF m_op_cart = 'I' THEN
   ELSE
      RETURN TRUE
   END IF
      
   IF mr_cart.carteira IS NULL THEN
      LET m_msg = 'Informe o c�digo da carteira'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT 1
     FROM empresa_carteira_adere
    WHERE empresa = p_cod_empresa
      AND carteira = mr_cart.carteira

   IF STATUS = 0 THEN
      LET m_msg = 'Carteira j� cadastrada no POL1409'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
   
#----------------------------#
FUNCTION pol1409_cart_insert()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   LET m_op_cart = 'I'
   LET m_car_cart = TRUE
   INITIALIZE mr_cart.* TO NULL
   LET mr_cart.empresa = p_cod_empresa
      
   CALL pol1409_desativa_folder("1")
   CALL pol1409_cart_ativa(TRUE)
   CALL _ADVPL_set_property(m_cod_cart,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1409_cart_insert_canc()#
#----------------------------------#

   CALL pol1409_cart_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1409_ativa_folder()
   CALL _ADVPL_set_property(m_brz_cart,"CLEAR")
   INITIALIZE mr_cart.*, ma_cart TO NULL
   LET m_car_cart = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1409_cart_insert_conf()#
#----------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_msg = NULL
   
   IF NOT pol1409_cart_ins_cart() THEN
      RETURN FALSE
   END IF
   
   CALL pol1409_cart_prepare()
   CALL pol1409_cart_ativa(FALSE)
   CALL pol1409_ativa_folder()
   LET m_car_cart = FALSE
   
   RETURN TRUE

END FUNCTION        
   

#-------------------------------#
FUNCTION pol1409_cart_ins_cart()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   INSERT INTO empresa_carteira_adere
    VALUES(mr_cart.empresa,   
           mr_cart.carteira)    

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','empresa_carteira_adere')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1409_cart_prepare()#
#-----------------------------#

   DEFINE l_sql_stmt CHAR(2000)
                        
   LET l_sql_stmt =
       " SELECT * ",
    "  FROM empresa_carteira_adere ",
    " WHERE empresa =  '",p_cod_empresa,"' "

   CALL pol1409_cart_exibe(l_sql_stmt)

END FUNCTION

#--------------------------------------#
FUNCTION pol1409_cart_exibe(l_sql_stmt)#
#--------------------------------------#
   
   DEFINE l_sql_stmt   CHAR(2000),
          l_ind        INTEGER

   CALL _ADVPL_set_property(m_brz_cart,"CLEAR")
   LET m_car_cart = TRUE
   INITIALIZE ma_cart TO NULL
   LET l_ind = 1
   
    PREPARE var_cart FROM l_sql_stmt

    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","empresa_carteira_adere:PREPARE")
       RETURN FALSE
    END IF

   DECLARE cq_cart CURSOR FOR var_cart
   
   FOREACH cq_cart INTO ma_cart[l_ind].*
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','cq_cart:01')
         EXIT FOREACH
      END IF

      LET l_ind = l_ind + 1
      
      IF l_ind > 100 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   IF l_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_cart,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'N�o h� registros para os par�metros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   LET m_car_cart = FALSE
        
END FUNCTION

#--------------------------#
FUNCTION pol1409_cart_find()#
#--------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    LET m_op_cart = 'P'
    
    IF m_cart_construct IS NULL THEN
       LET m_cart_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_cart_construct,"CONSTRUCT_NAME","pol1409_FILTER")
       CALL _ADVPL_set_property(m_cart_construct,"ADD_VIRTUAL_TABLE","empresa_carteira_adere","parametro")
       CALL _ADVPL_set_property(m_cart_construct,"ADD_VIRTUAL_COLUMN","empresa_carteira_adere","carteira","Carteira",1 {CHAR},2,0)
    END IF

    LET l_status = _ADVPL_get_property(m_cart_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_cart_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_cart_construct,"ORDER_BY")
       CALL pol1409_cart_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#---------------------------------------------------#
FUNCTION pol1409_cart_create_cursor(l_where, l_order)#
#---------------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)
    DEFINE l_ind        INTEGER

    IF l_order IS NULL THEN
       LET l_order = " carteira "
    END IF

    
    LET l_sql_stmt = 
       " SELECT * ",
       " FROM empresa_carteira_adere ",
        " WHERE ",l_where CLIPPED,
        " AND empresa =  '",p_cod_empresa,"' ",
        " ORDER BY ",l_order
   
   CALL pol1409_cart_exibe(l_sql_stmt)
   CALL pol1409_cart_set_item(1)
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1409_cart_prende()#
#-----------------------------#
   
   CALL  LOG_transaction_begin()
   
   DECLARE cq_cart_prende CURSOR FOR
    SELECT 1
      FROM empresa_carteira_adere
     WHERE empresa = mr_cart.empresa
       AND carteira = mr_cart.carteira
     FOR UPDATE 
    
    OPEN cq_cart_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_cart_prende")
       CALL LOG_transaction_rollback()
       RETURN FALSE
    END IF
    
   FETCH cq_cart_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_cart_prende")
      CALL LOG_transaction_rollback()
      CLOSE cq_cart_prende
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol1409_cart_delete()#
#----------------------------#
   
   DEFINE l_ret   SMALLINT

   IF mr_cart.carteira IS NULL THEN
      LET m_msg = 'Selecione previamente um item na grade'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclus�o do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1409_cart_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM empresa_carteira_adere
     WHERE empresa = mr_cart.empresa
       AND carteira = mr_cart.carteira

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','empresa_carteira_adere:cd')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_cart.* TO NULL
   ELSE
      CALL LOG_transaction_commit()     
   END IF
   
   CLOSE cq_cart_prende
   CALL pol1409_cart_prepare()
   
   RETURN l_ret
        
END FUNCTION


#---Rotinas para unifica��o de romaneio ----#

#-----------------------------#
FUNCTION pol1409_unif(l_fpanel)#
#-----------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1409_unif_find")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1409_unif_find_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1409_unif_find_canc")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1409_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1409_unif_campo(l_panel)
    CALL pol1409_unif_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1409_unif_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10),
           l_lupa_cnpj       VARCHAR(10),
           l_lupa_unif        VARCHAR(10)

    LET m_pan_unif = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_unif,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_unif,"HEIGHT",40)
    #CALL _ADVPL_set_property(m_pan_unif,"BACKGROUND_COLOR",225,232,232) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_unif)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Pedido:")    

    LET m_pedido = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_unif)     
    CALL _ADVPL_set_property(m_pedido,"POSITION",60,10) 
    CALL _ADVPL_set_property(m_pedido,"LENGTH",10)    
    CALL _ADVPL_set_property(m_pedido,"VARIABLE",mr_unif,"pedido")
    CALL _ADVPL_set_property(m_pedido,"VALID","pol1409_unif_valid_ped")
             
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_unif)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",170,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_unif)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",230,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",15)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_unif,"cliente")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_unif)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",380,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",36)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_unif,"nome")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_unif)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",720,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Unificado?:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_unif)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",805,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",2)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_unif,"ies_unificado")

    CALL _ADVPL_set_property(m_pan_unif,"ENABLE",FALSE)

END FUNCTION

#--------------------------------------#
FUNCTION pol1409_unif_grade(l_container)#
#--------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_unif = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_unif,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_unif)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_unif)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Seq")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","sequencia")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_unif)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_unif)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","entrega")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_unif)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd solic")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","solicitado")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_unif)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd atend")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","atendido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_unif)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd canc")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cancelado")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_unif)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd romaneio")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","romaneado")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_unif)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Num romaneio")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","romaneio")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_unif)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sdo pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","saldo")

    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_unif)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sdo estoque")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","estoque")
    

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_unif)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_unif,"SET_ROWS",ma_unif,1)
    CALL _ADVPL_set_property(m_brz_unif,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_unif,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_unif,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1409_unif_ativa(l_status)#
#-----------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pan_unif,"ENABLE",l_status)
            
END FUNCTION

#---------------------------#
FUNCTION pol1409_unif_find()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   LET m_op_unif = 'P'
   LET m_car_unif = TRUE
   INITIALIZE mr_unif.*, ma_unif TO NULL
   CALL _ADVPL_set_property(m_brz_unif,"CLEAR")   
   CALL pol1409_desativa_folder("2")
   CALL pol1409_unif_ativa(TRUE)
   CALL _ADVPL_set_property(m_pedido,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1409_unif_find_canc()#
#--------------------------------#

   CALL pol1409_unif_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1409_ativa_folder()
   INITIALIZE mr_cart.* TO NULL
   LET m_car_unif = FALSE
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1409_unif_valid_ped()#
#--------------------------------#

   IF mr_unif.pedido = 0 THEN
      LET mr_unif.pedido = NULL
   END IF

   IF mr_unif.pedido IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Informe o pedido.')
      RETURN FALSE
   END IF
   
   IF NOT pol1409_le_pedido() THEN
      RETURN FALSE
   END IF

   IF NOT pol1409_le_cliente() THEN 
      RETURN FALSE
   END IF

   IF NOT pol1409_ve_unific() THEN 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
      
#---------------------------#
FUNCTION pol1409_le_pedido()#
#---------------------------#
   
   SELECT cod_cliente
     INTO mr_unif.cliente
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = mr_unif.pedido
      AND ies_sit_pedido <> '9'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','pedidos')
      LET mr_unif.cliente = ''
      LET mr_unif.nome = ''
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION       
   
#----------------------------#
FUNCTION pol1409_le_cliente()#
#----------------------------#
   
   SELECT nom_cliente
     INTO mr_unif.nome
     FROM clientes
    WHERE cod_cliente = mr_unif.cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','clientes')
      LET mr_unif.nome = ''
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION       

#---------------------------#
FUNCTION pol1409_ve_unific()#
#---------------------------#
   
   DEFINE l_count INTEGER
   
   SELECT COUNT(*)
     INTO l_count
    FROM ord_montag_item_hist  
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido = mr_unif.pedido
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ord_montag_item_hist')
      RETURN FALSE
   END IF
   
   IF l_count > 0 THEN
      LET mr_unif.ies_unificado = 'S'
   ELSE
      LET mr_unif.ies_unificado = 'N'
   END IF
   
   RETURN TRUE
   
END FUNCTION       
   
#--------------------------------#
FUNCTION pol1409_unif_find_conf()#
#--------------------------------#    
    
    LET m_sql_stmt = 
       " SELECT p.num_pedido, i.num_sequencia, i.cod_item, ",
       " i.prz_entrega, i.qtd_pecas_solic, i.qtd_pecas_atend, ",
       " i.qtd_pecas_cancel, i.qtd_pecas_romaneio, o.num_om ",
       " FROM pedidos p, ped_itens i ",
      " LEFT JOIN ordem_montag_item o on o.cod_empresa = i.cod_empresa ",
      " AND o.num_pedido = i.num_pedido  AND o.num_sequencia = i.num_sequencia ",    
       " WHERE p.cod_empresa = '",p_cod_empresa,"' ",
       " AND p.cod_empresa = i.cod_empresa ",
       " AND p.num_pedido = i.num_pedido "

   
   IF mr_unif.pedido IS NOT NULL THEN
      LET m_sql_stmt = m_sql_stmt CLIPPED, " AND p.num_pedido = '",mr_unif.pedido,"' "
   END IF
   
   LET m_sql_stmt = m_sql_stmt CLIPPED, " ORDER BY i.num_pedido, i.num_sequencia"

   LET p_status = LOG_progresspopup_start(
         "Juntando Ordens...","pol1409_le_itens","PROCESS")  

   RETURN p_status

END FUNCTION

#--------------------------#
FUNCTION pol1409_le_itens()#
#--------------------------#

    DEFINE l_ind       INTEGER,
           l_progres   SMALLINT,
           l_estoque   DECIMAL(10,3)
   
    DELETE FROM w_estoque
    
    LET l_ind = 1
    CALL LOG_progresspopup_set_total("PROCESS",30)
    
    PREPARE var_unif FROM m_sql_stmt

    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","m_sql_stmt:PREPARE")
       RETURN FALSE
    END IF
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")  
   
   DECLARE cq_unif CURSOR FOR var_unif
   
   FOREACH cq_unif INTO 
      ma_unif[l_ind].pedido,     
      ma_unif[l_ind].sequencia,  
      ma_unif[l_ind].item,       
      ma_unif[l_ind].entrega,    
      ma_unif[l_ind].solicitado, 
      ma_unif[l_ind].atendido,   
      ma_unif[l_ind].cancelado,  
      ma_unif[l_ind].romaneado,  
      ma_unif[l_ind].romaneio
            
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('FOREACH','cq_unif:FOREACH')
         EXIT FOREACH
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS") 
      
      LET ma_unif[l_ind].saldo = ma_unif[l_ind].solicitado -
          ma_unif[l_ind].atendido - ma_unif[l_ind].cancelado - ma_unif[l_ind].romaneado

      SELECT saldo INTO ma_unif[l_ind].estoque
        FROM w_estoque 
       WHERE empresa = p_cod_empresa 
         AND item = ma_unif[l_ind].item
      
      IF STATUS = 100 THEN
         IF NOT pol1409_pega_estoq(ma_unif[l_ind].item) THEN
            EXIT FOREACH
         END IF

         LET ma_unif[l_ind].estoque = m_qtd_estoque
         LET m_qtd_estoque = m_qtd_estoque - ma_unif[l_ind].saldo         
         
         INSERT INTO w_estoque 
          VALUES(p_cod_empresa, ma_unif[l_ind].item, m_qtd_estoque)
          
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('INSERT','w_estoque')
            EXIT FOREACH
         END IF         
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','w_estoque:cq_unif')
            EXIT FOREACH
         ELSE
            UPDATE w_estoque SET saldo = saldo - ma_unif[l_ind].saldo
             WHERE empresa = p_cod_empresa 
               AND item = ma_unif[l_ind].item
            IF STATUS <> 0 THEN
               CALL log003_err_sql('UPDATE','w_estoque:cq_unif')
               EXIT FOREACH
            END IF               
         END IF
      END IF
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 1000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH

   LET m_car_unif = FALSE
   
   LET l_ind = l_ind - 1
   
   IF l_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_unif,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'N�o h� registros para os par�metros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE
        
END FUNCTION

#----------------------------------#
FUNCTION pol1409_pega_estoq(l_item)#
#----------------------------------#
   
   DEFINE l_item         VARCHAR(15)

   DEFINE l_parametro      RECORD
          cod_empresa      CHAR(02),
          cod_item         CHAR(15),
          cod_local        CHAR(10)
   END RECORD
   
   LET l_parametro.cod_empresa = p_cod_empresa
   LET l_parametro.cod_item = l_item
   
   SELECT cod_local_estoq
     INTO l_parametro.cod_local
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_parametro.cod_item

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('SELECT','item:cq_unif')
      RETURN FALSE
   END IF
      
   CALL func002_le_estoque(l_parametro) RETURNING m_msg, m_qtd_estoque

   IF m_msg IS NOT NULL THEN
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   IF m_qtd_estoque IS NULL THEN
      LET m_qtd_estoque = 0
   END IF
   
   RETURN TRUE

END FUNCTION
