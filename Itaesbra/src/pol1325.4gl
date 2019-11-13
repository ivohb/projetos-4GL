#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1325                                                 #
# OBJETIVO: PARÂMETROS P/ DEVOLUÇÃO DE MATERIAL                     #
# AUTOR...: IVO                                                     #
# DATA....: 19/06/17                                                #
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
       m_menubar          VARCHAR(10),
       m_menu_cli        VARCHAR(10),
       m_menu_oper       VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_panel_opcoes    VARCHAR(10),
       m_panel_dados     VARCHAR(10),
       m_panel_client    VARCHAR(10),
       m_panel_oper      VARCHAR(10),
       m_cliente         VARCHAR(10),
       m_natoper         VARCHAR(10),
       m_parametro       VARCHAR(10),
       m_cod_cliente     VARCHAR(10),
       m_lupa_cliente    VARCHAR(10),
       m_cod_nat_oper    VARCHAR(10),
       m_lupa_oper       VARCHAR(10),
       m_brs_cliente     VARCHAR(10),
       m_brs_natoper     VARCHAR(10),
       m_cli_construct   VARCHAR(10),
       m_zoom_cliente    VARCHAR(10),
       m_zoom_natoper    VARCHAR(10),
       m_create          VARCHAR(10)
              

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_ind             INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_excluiu         SMALLINT,
       m_opcao           CHAR(01),
       m_den_empresa     CHAR(36),
       m_den_operacao    CHAR(30),
       m_ies_tipo        CHAR(01),
       m_cod_empresa     CHAR(02),
       m_cod_empresaa    CHAR(02),
       m_descricao       CHAR(50),
       m_linha_atual     INTEGER,
       m_cod_oper        INTEGER,
       m_incluiu         SMALLINT

DEFINE mr_param          RECORD
       sel_opcao         INTEGER
END RECORD

DEFINE mr_cliente        RECORD
       cod_cliente       CHAR(15),
       nom_cliente       CHAR(36)
END RECORD

DEFINE mr_natoper        RECORD
       cod_nat_oper      INTEGER,
       den_nat_oper      CHAR(36)
END RECORD

DEFINE ma_cliente        ARRAY[100] OF RECORD
       ies_editar        CHAR(30),
       cod_cliente       CHAR(15),
       nom_cliente       CHAR(36),
       filler            CHAR(01)
END RECORD
              
DEFINE mr_campos         RECORD
       cod_empresa       CHAR(02),
       den_empresa       CHAR(36),
       cod_oper_sai      CHAR(04),
       den_oper_sai      CHAR(30),
       cod_oper_ent      CHAR(04),
       den_oper_ent      CHAR(30)
END RECORD

#-----------------#
FUNCTION pol1325()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 11

   LET p_versao = "pol1325-12.00.02  "
   CALL func002_versao_prg(p_versao)
   
   CALL pol1325_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1325_menu()#
#----------------------#

    DEFINE l_menubar,
           l_panel,
           l_cliente,
           l_operacao  VARCHAR(10)
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"TITLE","PARÂMETROS PARA MONTAGEM DE CARGA")
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET m_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menubar,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menubar)

    LET m_menu_cli = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_cli,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_cli,"VISIBLE",FALSE)

    LET m_menu_oper = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_oper,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_oper,"VISIBLE",FALSE)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1325_cria_panel(l_panel)
    CALL pol1325_exib_opcoes()
    CALL pol1325_menu_client()
    CALL pol1325_menu_natoper()
    CALL pol1325_campos_client()
    CALL pol1325_campos_oper()

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------------#
FUNCTION pol1325_cria_panel(l_panel)#
#-----------------------------------#

    DEFINE l_panel        VARCHAR(10)

    LET m_panel_opcoes = _ADVPL_create_component(NULL,"LPANEL",l_panel)
    CALL _ADVPL_set_property(m_panel_opcoes,"ALIGN","LEFT")
    CALL _ADVPL_set_property(m_panel_opcoes,"WIDTH",300)
    CALL _ADVPL_set_property(m_panel_opcoes,"BACKGROUND_COLOR",231,237,237)

    LET m_panel_dados = _ADVPL_create_component(NULL,"LPANEL",l_panel)
    CALL _ADVPL_set_property(m_panel_dados,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(m_panel_dados,"BACKGROUND_COLOR",231,237,237)

    LET m_panel_client = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_panel_client,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_panel_client,"VISIBLE",FALSE)

    LET m_panel_oper = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_panel_oper,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_panel_oper,"VISIBLE",FALSE)

END FUNCTION

#-----------------------------#
FUNCTION pol1325_exib_opcoes()#
#-----------------------------#

    DEFINE l_label      VARCHAR(10),
           l_cliente    VARCHAR(10),
           l_natoper    VARCHAR(10)
        
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_opcoes)
    CALL _ADVPL_set_property(l_label,"POSITION",20,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Cadastro de parâmetros")  
    CALL _ADVPL_set_property(l_label,"FONT",NULL,10,TRUE,FALSE)  

    LET m_cliente = _ADVPL_create_component(NULL,"LLABEL",m_panel_opcoes)
    CALL _ADVPL_set_property(m_cliente,"POSITION",20,40)
    CALL _ADVPL_set_property(m_cliente,"TEXT",">> Cientes p/ retorno de material")  
    CALL _ADVPL_set_property(m_cliente,"FONT",NULL,11,FALSE,TRUE)  
    CALL _ADVPL_set_property(m_cliente,"FOREGROUND_COLOR",0,0,0) 
    CALL _ADVPL_set_property(m_cliente,"CLICK_EVENT","pol1325_clinte_click")

    LET m_natoper = _ADVPL_create_component(NULL,"LLABEL",m_panel_opcoes)
    CALL _ADVPL_set_property(m_natoper,"POSITION",20,70)
    CALL _ADVPL_set_property(m_natoper,"TEXT",">> Nat operação usada no retorno")  
    CALL _ADVPL_set_property(m_natoper,"FONT",NULL,11,FALSE,TRUE)  
    CALL _ADVPL_set_property(m_natoper,"FOREGROUND_COLOR",0,0,0) 
    CALL _ADVPL_set_property(m_natoper,"CLICK_EVENT","pol1325_natoper_click")
     

END FUNCTION

#------------------------------#
FUNCTION pol1325_clinte_click()#
#------------------------------#

   CALL _ADVPL_set_property(m_cliente,"FOREGROUND_COLOR",0,0,160)
   CALL _ADVPL_set_property(m_natoper,"FOREGROUND_COLOR",0,0,0) 

   CALL _ADVPL_set_property(m_menu_oper,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_menu_cli,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_menubar,"VISIBLE",FALSE)
   
   CALL _ADVPL_set_property(m_panel_oper,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_panel_client,"VISIBLE",TRUE)
   
   CALL _ADVPL_set_property(m_cod_cliente,"EDITABLE",FALSE)      
   CALL _ADVPL_set_property(m_lupa_cliente,"EDITABLE",FALSE)
   
   CALL pol1325_le_clientes()
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   RETURN TRUE
       
END FUNCTION

#-------------------------------#
FUNCTION pol1325_natoper_click()#
#-------------------------------#

   CALL _ADVPL_set_property(m_natoper,"FOREGROUND_COLOR",0,0,160)
   CALL _ADVPL_set_property(m_cliente,"FOREGROUND_COLOR",0,0,0) 

   CALL _ADVPL_set_property(m_menu_cli,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_menu_oper,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_menubar,"VISIBLE",FALSE)

   CALL _ADVPL_set_property(m_panel_client,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_panel_oper,"VISIBLE",TRUE)
   
   CALL pol1325_le_natoper()
   CALL pol1325_setCompon_natoper(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   RETURN TRUE
       
END FUNCTION
 
#-----------------------------#
FUNCTION pol1325_menu_client()#
#-----------------------------#

    DEFINE l_create,
           l_find,
           l_delete VARCHAR(10)
    
    INITIALIZE mr_cliente.* TO NULL

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",m_menu_cli)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1325_cli_inclui")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1325_cli_inc_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1325_cli_inc_cancel")
    
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",m_menu_cli)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1325_cli_find")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",m_menu_cli)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1325_cli_del")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_cli)



END FUNCTION

#-------------------------------#
FUNCTION pol1325_campos_client()#
#-------------------------------#

    DEFINE l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_descricao       VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_panel_client)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",40)
    #CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",4)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_cliente,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_cliente,"VARIABLE",mr_cliente,"cod_cliente")
    CALL _ADVPL_set_property(m_cod_cliente,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_cliente,"VALID","pol1325_cli_valida")

    LET m_lupa_cliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_cliente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cliente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cliente,"CLICK_EVENT","pol1325_zoom_cliente")

    LET l_descricao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_descricao,"LENGTH",36) 
    CALL _ADVPL_set_property(l_descricao,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_descricao,"VARIABLE",mr_cliente,"nom_cliente")
    CALL _ADVPL_set_property(l_descricao,"CAN_GOT_FOCUS",FALSE)

    # CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW") 

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_panel_client)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)

    LET m_brs_cliente = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brs_cliente,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brs_cliente)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Editar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_editar")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_COLUMN",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1324_cli_edita")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brs_cliente)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Código")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    #CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",130)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brs_cliente)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    #CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",300)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    {LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brs_cliente)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")}

    CALL _ADVPL_set_property(m_brs_cliente,"SET_ROWS",ma_cliente,1)
    CALL _ADVPL_set_property(m_brs_cliente,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brs_cliente,"CAN_REMOVE_ROW",FALSE)
    #CALL _ADVPL_set_property(m_brs_cliente,"CLEAR")

END FUNCTION

#---------------------------#
FUNCTION pol1324_cli_edita()#
#---------------------------#

   DEFINE l_lin_atu       INTEGER
      
   LET l_lin_atu = _ADVPL_get_property(m_brs_cliente,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN

      IF pol1325_cli_nao_existe(ma_cliente[l_lin_atu].cod_cliente) THEN
         RETURN FALSE
      END IF
      
      LET m_linha_atual = l_lin_atu
      LET mr_cliente.cod_cliente = ma_cliente[m_linha_atual].cod_cliente   
      LET mr_cliente.nom_cliente = ma_cliente[m_linha_atual].nom_cliente  
      CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1325_le_clientes()#
#-----------------------------#

   INITIALIZE ma_cliente TO NULL
   CALL _ADVPL_set_property(m_brs_cliente,"CLEAR")

   LET m_ind = 1

   DECLARE cq_cli_par CURSOR FOR 
    SELECT a.cod_cliente,
           b.nom_cliente
      FROM client_dev_mat_912 a,
           clientes b
     WHERE a.cod_cliente = b.cod_cliente
   
   FOREACH cq_cli_par INTO
           ma_cliente [m_ind].cod_cliente,
           ma_cliente [m_ind].nom_cliente

      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("FOREACH","cq_cli_par",0)
         EXIT FOREACH
      END IF
      
      LET ma_cliente[m_ind].ies_editar = 'editar-docum'
      
      LET m_ind = m_ind + 1
   
      IF m_ind > 200 THEN
         LET m_msg = 'Limite de linhas da grade\n de clientes ultrapasou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH

   LET m_ind = m_ind - 1
   CALL _ADVPL_set_property(m_brs_cliente,"ITEM_COUNT", m_ind)
   LET mr_cliente.cod_cliente = ma_cliente[1].cod_cliente
   CALL pol1325_cli_exib_dados()
   LET m_linha_atual = 1
   
END FUNCTION

#-------------------------------------------#
FUNCTION pol1325_setCompon_cliente(l_status)#
#-------------------------------------------#

   DEFINE l_status SMALLINT

    CALL _ADVPL_set_property(m_cod_cliente,"EDITABLE",l_status)
    CALL _ADVPL_set_property(m_lupa_cliente,"EDITABLE",l_status)

END FUNCTION

#--------------------------#
FUNCTION pol1325_cli_find()#
#--------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_cli_construct IS NULL THEN
       LET m_cli_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_cli_construct,"CONSTRUCT_NAME","pol1325_FILTER")
       CALL _ADVPL_set_property(m_cli_construct,"ADD_VIRTUAL_TABLE","client_dev_mat_912","Clientes")
       CALL _ADVPL_set_property(m_cli_construct,"ADD_VIRTUAL_COLUMN","client_dev_mat_912","cod_cliente","Cliente",1 {CHAR},15,0,"zoom_clientes")
    END IF

    LET l_status = _ADVPL_get_property(m_cli_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_cli_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_cli_construct,"ORDER_BY")
       CALL pol1325_cli_pesquisa(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#----------------------------------------------#
FUNCTION pol1325_cli_pesquisa(l_where, l_order)#
#----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = "1"
    END IF
    
    LET l_sql_stmt = "SELECT cod_cliente ",
                      " FROM client_dev_mat_912",
                     " WHERE ",l_where CLIPPED,
                     " ORDER BY ",l_order

    PREPARE var_cli_pesq FROM l_sql_stmt
    
    IF STATUS <> 0 THEN
       CALL log0030_processa_err_sql("PREPARE","var_cli_pesq",0)
       RETURN FALSE
    END IF

    DECLARE cq_cli_pesq CURSOR FOR var_cli_pesq

    IF  STATUS <> 0 THEN
        CALL log0030_processa_err_sql("DECLARE","cq_cli_pesq",0)
        RETURN FALSE
    END IF

    FREE var_cli_pesq
    
    LET m_ind = 1

    FOREACH cq_cli_pesq INTO ma_cliente[m_ind].cod_cliente

       IF STATUS <> 0 THEN
          CALL log0030_processa_err_sql("FOREACH","var_cli_pesq",0)
          RETURN FALSE
       END IF
    
       CALL pol1325_le_nom_cli(ma_cliente[m_ind].cod_cliente)
       LET ma_cliente[m_ind].nom_cliente = m_descricao
       LET ma_cliente[m_ind].ies_editar = 'editar-docum'
       
       LET m_ind = m_ind + 1
       
      IF m_ind > 200 THEN
         LET m_msg = 'Limite de linhas da grade\n de clientes ultrapasou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
    
    END FOREACH
    
   LET m_ind = m_ind - 1

   IF m_ind = 0 THEN
      LET m_msg = "Argumentos de pesquisa não encontrados."
      CALL _ADVPL_set_property(m_statusbar,"WARNING_TEXT",m_msg)
   ELSE
      CALL _ADVPL_set_property(m_brs_cliente,"ITEM_COUNT", m_ind)
      LET mr_cliente.cod_cliente = ma_cliente[1].cod_cliente
      CALL pol1325_cli_exib_dados()
      LET m_linha_atual = 1
   END IF    
    
    RETURN TRUE
    
END FUNCTION

#---------------------------------#
FUNCTION pol1325_le_nom_cli(l_cod)#
#---------------------------------#

   DEFINE l_cod    LIKE Clientes.cod_cliente
   
   INITIALIZE m_descricao TO NULL
   
   SELECT nom_cliente
     INTO m_descricao
     FROM clientes
    WHERE cod_cliente = l_cod
    
   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql("SELECT","clientes",0)
   END IF

END FUNCTION

#--------------------------------#
FUNCTION pol1325_cli_exib_dados()#
#--------------------------------#

   CALL pol1325_le_nom_cli(mr_cliente.cod_cliente)
   LET mr_cliente.nom_cliente = m_descricao
   
END FUNCTION   

#----------------------------#
FUNCTION pol1325_cli_inclui()#
#----------------------------#

    LET m_opcao = 'I'    
        
    INITIALIZE mr_cliente.* TO NULL
    
    CALL pol1325_setCompon_cliente(TRUE)
    CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#------------------------------#
FUNCTION pol1325_cli_inc_conf()#
#------------------------------#
      
   IF pol1325_cli_existe() THEN
      CALL _ADVPL_set_property(m_statusbar,"WARNING_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_begin()
   
   INSERT INTO client_dev_mat_912(cod_cliente)
   VALUES(mr_cliente.cod_cliente)
    
   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql("INSERT","client_dev_mat_912",0)
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   CALL LOG_transaction_commit()

   CALL pol1325_setCompon_cliente(FALSE)
   LET m_opcao = NULL          
   
   LET m_count = _ADVPL_get_property(m_brs_cliente,"ITEM_COUNT") + 1
   CALL _ADVPL_set_property(m_brs_cliente,"ADD_ROW")
   LET ma_cliente[m_count].cod_cliente = mr_cliente.cod_cliente
   LET ma_cliente[m_count].nom_cliente = mr_cliente.nom_cliente
   LET ma_cliente[m_count].ies_editar = 'editar-docum'
   CALL _ADVPL_set_property(m_brs_cliente,"ITEM_COUNT", m_count)
   LET m_linha_atual = m_count
   
   RETURN TRUE
        
END FUNCTION

#--------------------------------#
FUNCTION pol1325_cli_inc_cancel()#
#--------------------------------#

    CALL pol1325_setCompon_cliente(FALSE)
    INITIALIZE mr_cliente.* TO NULL
    LET m_opcao = NULL
    
    IF m_linha_atual > 0 THEN
      LET mr_cliente.cod_cliente = ma_cliente[m_linha_atual].cod_cliente
      LET mr_cliente.nom_cliente = ma_cliente[m_linha_atual].nom_cliente 
    END IF
    
    RETURN TRUE
        
END FUNCTION

#------------------------------#
FUNCTION pol1325_zoom_cliente()#
#------------------------------#

    DEFINE l_codigo       LIKE clientes.cod_cliente,
           l_descri       LIKE clientes.nom_cliente
    
    IF  m_zoom_cliente IS NULL THEN
        LET m_zoom_cliente = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_cliente,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_cliente,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_descri = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")

    IF l_codigo IS NOT NULL THEN
       LET mr_cliente.cod_cliente = l_codigo
       LET mr_cliente.nom_cliente = l_descri
    END IF
    
    CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")

END FUNCTION

#----------------------------#
FUNCTION pol1325_cli_valida()#
#----------------------------#

   CALL pol1325_le_nom_cli(mr_cliente.cod_cliente)
   
   IF m_descricao IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"WARNING_TEXT","Código inválido")
      RETURN FALSE
   END IF
   
   LET mr_cliente.nom_cliente = m_descricao
   
   RETURN TRUE

END FUNCTION   

#-------------------------------------#
FUNCTION pol1325_cli_nao_existe(l_cod)#
#-------------------------------------#
      
   DEFINE l_cod LIKE clientes.cod_cliente
   
   SELECT 1
     FROM client_dev_mat_912
    WHERE cod_cliente =  l_cod
   
   IF STATUS = 0 THEN
      RETURN FALSE
   ELSE
      CALL log0030_processa_err_sql("SELECT","client_dev_mat_912",0)
   END IF   
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1325_cli_existe()#
#----------------------------#
      
   LET m_msg = ''
   
   SELECT 1
     FROM client_dev_mat_912
    WHERE cod_cliente =  mr_cliente.cod_cliente
   
   IF STATUS = 100 THEN
   ELSE
      IF STATUS = 0 THEN
         LET m_msg = 'Cliente ja cadastrada no POL1325.'
      ELSE
         LET m_msg = 'Erro ',STATUS, ' lendo tabela client_dev_mat_912.' 
      END IF
      RETURN TRUE
   END IF   
   
   RETURN FALSE

END FUNCTION


#--------------------------------#
 FUNCTION pol1325_cli_trava_reg()#
#--------------------------------#
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM client_dev_mat_912
     WHERE cod_cliente =  mr_cliente.cod_cliente
     FOR UPDATE 

    IF STATUS <> 0 THEN
       CALL log0030_processa_err_sql("DECLARE","client_dev_mat_912:cq_prende",0)
       RETURN FALSE
    END IF
    
    OPEN cq_prende

    IF STATUS <> 0 THEN
       CALL log0030_processa_err_sql("OPEN","client_dev_mat_912:cq_prende",0)
       RETURN FALSE
    END IF
    
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log0030_processa_err_sql("FETCH","client_dev_mat_912:cq_prende",0)
   END IF

   CLOSE cq_prende
   RETURN FALSE
   
END FUNCTION

#-------------------------#
FUNCTION pol1325_cli_del()#
#-------------------------#

   IF mr_cliente.cod_cliente IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"WARNING_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   CALL LOG_transaction_begin()

   IF NOT pol1325_cli_trava_reg() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   DELETE FROM client_dev_mat_912
    WHERE cod_cliente = mr_cliente.cod_cliente

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql("DELETE","client_dev_mat_912",0)
      CALL LOG_transaction_rollback()
      CLOSE cq_prende
      RETURN FALSE
   END IF

   CALL LOG_transaction_commit()
   CLOSE cq_prende

   INITIALIZE mr_cliente.* TO NULL
   CALL pol1325_setCompon_cliente(FALSE)
   
   CALL _ADVPL_set_property(m_brs_cliente,"REMOVE_ROW",m_linha_atual)
   
   RETURN TRUE
    
END FUNCTION


#-----------NATUREZA DE OPERAÇÃO----------------------------------------#

#------------------------------#
FUNCTION pol1325_menu_natoper()#
#------------------------------#

    DEFINE l_menubar,
           l_panel,
           l_update,
           l_label,
           l_create   VARCHAR(10)

    LET m_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",m_menu_oper)
    CALL _ADVPL_set_property(m_create,"EVENT","pol1325_oper_inclui")
    CALL _ADVPL_set_property(m_create,"CONFIRM_EVENT","pol1325_oper_inc_conf")
    CALL _ADVPL_set_property(m_create,"CANCEL_EVENT","pol1325_oper_inc_cancel")
      
    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",m_menu_oper)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1325_oper_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1325_oper_upd_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1325_oper_upd_cancel")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_oper)

END FUNCTION

#-----------------------------#
FUNCTION pol1325_campos_oper()#
#-----------------------------#

    DEFINE l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_descricao       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_panel_oper)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
    CALL _ADVPL_set_property(l_panel,"WIDTH",10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_panel_oper)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",30)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_panel_oper)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",4)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Nat operação:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_nat_oper = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_nat_oper,"LENGTH",5)
    CALL _ADVPL_set_property(m_cod_nat_oper,"VARIABLE",mr_natoper,"cod_nat_oper")
    CALL _ADVPL_set_property(m_cod_nat_oper,"PICTURE","@E #####")
    CALL _ADVPL_set_property(m_cod_nat_oper,"VALID","pol1325_oper_valida")

    LET m_lupa_oper = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_oper,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_oper,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_oper,"CLICK_EVENT","pol1325_zoom_oper")

    LET l_descricao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_descricao,"LENGTH",36) 
    CALL _ADVPL_set_property(l_descricao,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_descricao,"VARIABLE",mr_natoper,"den_nat_oper")
    CALL _ADVPL_set_property(l_descricao,"CAN_GOT_FOCUS",FALSE)

END FUNCTION

#-------------------------------------------#
FUNCTION pol1325_setCompon_natoper(l_status)#
#-------------------------------------------#

   DEFINE l_status SMALLINT

    CALL _ADVPL_set_property(m_cod_nat_oper,"EDITABLE",l_status)
    CALL _ADVPL_set_property(m_lupa_oper,"EDITABLE",l_status)

END FUNCTION

#----------------------------#
FUNCTION pol1325_le_natoper()#
#----------------------------#
   
   INITIALIZE mr_natoper.* TO NULL
   
   SELECT a.cod_nat_oper,
          b.den_nat_oper
     INTO mr_natoper.cod_nat_oper,
          mr_natoper.den_nat_oper
     FROM natoper_dev_mat_912 a,
          nat_operacao b
    WHERE a.cod_nat_oper = b.cod_nat_oper

   IF STATUS = 100 THEN      
   ELSE
      IF STATUS = 0 THEN
         CALL _ADVPL_set_property(m_create,"ENABLE",FALSE)
      ELSE
         CALL log0030_processa_err_sql('SELECT','natoper_dev_mat_912',0)
      END IF
   END IF 

END FUNCTION

#---------------------------------#
FUNCTION pol1325_le_den_nat(l_cod)#
#---------------------------------#
   
   DEFINE l_cod     INTEGER,
          l_ies_tip CHAR(01)
   
   INITIALIZE m_descricao TO NULL
   
   SELECT den_nat_oper, 
          ies_tip_controle
     INTO m_descricao,
          l_ies_tip
     FROM nat_operacao
    WHERE cod_nat_oper = l_cod

   IF STATUS <> 0 THEN      
      CALL log0030_processa_err_sql('SELECT','nat_operacao',0)
      LET m_msg = 'Falha na valida~]ao do código informado.'
      RETURN FALSE
   END IF 
   
   IF l_ies_tip <> '3' THEN
      LET m_msg = 'Operão informada não é de retorno de material.'
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1325_oper_valida()#
#-----------------------------#

   IF NOT pol1325_le_den_nat(mr_natoper.cod_nat_oper) THEN
      CALL _ADVPL_set_property(m_statusbar,"WARNING_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET mr_natoper.den_nat_oper = m_descricao
   
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1325_zoom_oper()#
#---------------------------#

    DEFINE l_codigo       LIKE nat_operacao.cod_nat_oper,
           l_descri       LIKE nat_operacao.den_nat_oper,
           l_where_clause CHAR(300)
    
    IF  m_zoom_natoper IS NULL THEN
        LET m_zoom_natoper = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_natoper,"ZOOM","zoom_nat_operacao")
    END IF

    LET l_where_clause = " nat_operacao.ies_tip_controle = '3' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_natoper,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_natoper,"RETURN_BY_TABLE_COLUMN","nat_operacao","cod_nat_oper")
    LET l_descri = _ADVPL_get_property(m_zoom_natoper,"RETURN_BY_TABLE_COLUMN","nat_operacao","den_nat_oper")

    IF l_codigo IS NOT NULL THEN
       LET mr_natoper.cod_nat_oper = l_codigo
       LET mr_natoper.den_nat_oper = l_descri
    END IF
    
    CALL _ADVPL_set_property(m_cod_nat_oper,"GET_FOCUS")

END FUNCTION

#-----------------------------#
FUNCTION pol1325_oper_inclui()#
#-----------------------------#
    
    CALL _ADVPL_set_property(m_statusbar,"WARNING_TEXT",'')
    
    IF m_incluiu THEN
       LET m_msg = 'Somente uma operação pode ser cadastrada.'
       CALL _ADVPL_set_property(m_statusbar,"WARNING_TEXT",m_msg)
       RETURN FALSE
    END IF
    
    LET m_opcao = 'I'    
        
    INITIALIZE mr_natoper.* TO NULL
    
    CALL pol1325_setCompon_natoper(TRUE)
    CALL _ADVPL_set_property(m_cod_nat_oper,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1325_oper_inc_conf()#
#-------------------------------#
         
   CALL LOG_transaction_begin()
   
   INSERT INTO natoper_dev_mat_912(cod_nat_oper)
   VALUES(mr_natoper.cod_nat_oper)
    
   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql("INSERT","natoper_dev_mat_912",0)
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   CALL LOG_transaction_commit()

   CALL pol1325_setCompon_natoper(FALSE)
   LET m_opcao = NULL      
   LET m_incluiu = TRUE   
   
   RETURN TRUE
        
END FUNCTION

#---------------------------------#
FUNCTION pol1325_oper_inc_cancel()#
#---------------------------------#

    CALL pol1325_setCompon_natoper(FALSE)
    INITIALIZE mr_natoper.* TO NULL
    LET m_opcao = NULL
        
    RETURN TRUE
        
END FUNCTION

#---------------------------------#
 FUNCTION pol1325_oper_trava_reg()#
#---------------------------------#
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM natoper_dev_mat_912
     WHERE cod_nat_oper =  m_cod_oper
     FOR UPDATE 

    IF STATUS <> 0 THEN
       CALL log0030_processa_err_sql("DECLARE","natoper_dev_mat_912:cq_prende",0)
       RETURN FALSE
    END IF
    
    OPEN cq_prende

    IF STATUS <> 0 THEN
       CALL log0030_processa_err_sql("OPEN","natoper_dev_mat_912:cq_prende",0)
       RETURN FALSE
    END IF
    
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log0030_processa_err_sql("FETCH","natoper_dev_mat_912:cq_prende",0)
   END IF

   CLOSE cq_prende
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1325_oper_update()#
#-----------------------------#

   IF mr_natoper.cod_nat_oper IS NULL OR
      mr_natoper.cod_nat_oper <= 0 THEN
      LET m_msg = 'Não há dados na tela a serem alterados.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET m_cod_oper = mr_natoper.cod_nat_oper
   CALL pol1325_setCompon_natoper(TRUE)
   CALL _ADVPL_set_property(m_cod_nat_oper,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1325_oper_upd_conf()#
#-------------------------------#
   
   CALL LOG_transaction_begin()

   IF NOT pol1325_oper_trava_reg() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   UPDATE natoper_dev_mat_912
    SET cod_nat_oper = mr_natoper.cod_nat_oper

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql("UPDATE","natoper_dev_mat_912",0)
      CALL LOG_transaction_rollback()
      CLOSE cq_prende
      RETURN FALSE
   END IF

   CALL LOG_transaction_commit()
   CLOSE cq_prende

   CALL pol1325_setCompon_natoper(FALSE)
      
   RETURN TRUE
    
END FUNCTION

#---------------------------------#
FUNCTION pol1325_oper_upd_cancel()#
#---------------------------------#

   CALL pol1325_setCompon_natoper(FALSE)

   CALL pol1325_le_natoper() 
   
   RETURN TRUE

END FUNCTION
   

#-----------------FIM DO PROGRAMA-------------------#

