# https://www.hoteis.com/ho1197467840/?pa=5&q-check-out=2020-01-26&tab=description&q-room-0-adults=2&YGF=3&q-check-in=2020-01-25&MGT=1&WOE=7&WOD=6&ZSX=0&SYE=3&q-room-0-children=0

#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1381                                                 #
# OBJETIVO: ESTRUTURA - APURA��O DAS NECESSIDADES                   #
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
           p_cod_cliente    CHAR(05),
           p_cod_clientea   CHAR(05)
END GLOBALS

DEFINE m_cod_empresa_plano   LIKE empresa.cod_empresa

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_cod_cliente     VARCHAR(10),
       m_nom_cliente     VARCHAR(10),
       m_zoom_cliente    VARCHAR(10),
       m_lupa_cliente    VARCHAR(10),
       m_cod_item        VARCHAR(10),
       m_den_item        VARCHAR(10),
       m_zoom_item       VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_dat_ini         VARCHAR(10),
       m_dat_fim         VARCHAR(10),
       m_brz_analitico   VARCHAR(10),
       m_brz_sintetico   VARCHAR(10),
       m_pnl_info        VARCHAR(10),
       m_menu_anali      VARCHAR(10),
       m_menu_sinte      VARCHAR(10),
       m_pnl_sinte       VARCHAR(10),
       m_pnl_anali       VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_carregando      SMALLINT,   
       m_dat_prev_ini    DATE,
       m_dat_prev_fim    DATE,
       m_dat_aval_ini    DATE,
       m_dat_aval_fim    DATE,
       m_dat_atu         DATE,
       m_qtd_erro        INTEGER   
       
DEFINE mr_campos         RECORD
       cod_cliente       LIKE clientes.cod_cliente,
       nom_cliente       LIKE clientes.nom_cliente,
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item,
       dat_inicial       DATE,
       dat_final         DATE
END RECORD

DEFINE ma_analitico      ARRAY[1000] OF RECORD
       num_ped_cli       VARCHAR(30),
       num_pedido        DECIMAL(6,0),
       num_sequencia     DECIMAL(3,0)
END RECORD

DEFINE ma_sintetico      ARRAY[1000] OF RECORD
       cod_embal         CHAR(15),
       descricao         VARCHAR(50),
       qtd_neces         DECIMAL(10,3),
       peso_total        DECIMAL(10,3)
END RECORD

DEFINE mr_faturar        RECORD
       num_pedido        DECIMAL(6,0),
       num_pedido_cli    CHAR(30),
       num_sequencia     DECIMAL(3,0),
       cod_item          CHAR(15),
       prz_entrega       DATE,
       qtd_faturar       DECIMAL(10,3),
       cod_item_embal    CHAR(15),
       qtd_item_embal    DECIMAL(10,3)
END RECORD

DEFINE ma_divergencia    ARRAY[2000] OF RECORD
       cod_item          CHAR(15),
       mensagem          CHAR(80)
END RECORD       
       
#-----------------#
FUNCTION pol1381()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1381-12.00.01  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1381_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1381_menu()#
#----------------------#

    DEFINE l_menubar,
           l_panel,
           l_inform,
           l_titulo           VARCHAR(80)
    
    LET l_titulo = "ESTRUTURA - APURA��O DAS NECESSIDADES - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1381_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1381_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1381_cancelar")

    LET m_menu_sinte = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(m_menu_sinte,"IMAGE","ANALISAR") 
    CALL _ADVPL_set_property(m_menu_sinte,"TOOLTIP","Processa apura��o sint�tica")
    CALL _ADVPL_set_property(m_menu_sinte,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(m_menu_sinte,"EVENT","pol1381_sintetica")

    LET m_menu_anali = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(m_menu_anali,"IMAGE","ANALISE_ITEM") 
    CALL _ADVPL_set_property(m_menu_anali,"TOOLTIP","Processa apura��o anal�tica")
    CALL _ADVPL_set_property(m_menu_anali,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(m_menu_anali,"EVENT","pol1381_analitica")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1381_cria_campos(l_panel)
    CALL pol1381_panel_analitico(l_panel)
    CALL pol1381_panel_sintetico(l_panel)

    CALL pol1381_ativa_desativa(FALSE)
    CALL pol1381_limpa_campos()

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1381_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10)

    LET m_pnl_info = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_container)
    CALL _ADVPL_set_property(m_pnl_info,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pnl_info,"HEIGHT",60)
    CALL _ADVPL_set_property(m_pnl_info,"ENABLE",FALSE)
    #CALL _ADVPL_set_property(m_pnl_info,"BACKGROUND_COLOR",231,237,237)
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pnl_info)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",8)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cod cliente:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_cliente,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_cliente,"VARIABLE",mr_campos,"cod_cliente")
    CALL _ADVPL_set_property(m_cod_cliente,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_cliente,"VALID","pol1381_valida_cliente")

    LET m_lupa_cliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_cliente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cliente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cliente,"CLICK_EVENT","pol1381_zoom_cliente")

    LET m_nom_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_nom_cliente,"LENGTH",50) 
    CALL _ADVPL_set_property(m_nom_cliente,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_nom_cliente,"VARIABLE",mr_campos,"nom_cliente")
    CALL _ADVPL_set_property(m_nom_cliente,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","C�digo item:")    

    LET m_cod_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_item,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_item,"VARIABLE",mr_campos,"cod_item")
    CALL _ADVPL_set_property(m_cod_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_item,"CLICK_EVENT","pol1381_valida_item")

    LET m_lupa_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_item,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_item,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_item,"CLICK_EVENT","pol1381_zoom_item")

    LET m_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_item,"LENGTH",50) 
    CALL _ADVPL_set_property(m_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_den_item,"VARIABLE",mr_campos,"den_item")
    CALL _ADVPL_set_property(m_den_item,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Per�odo de:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dat_ini = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_ini,"VARIABLE",mr_campos,"dat_inicial")
    CALL _ADVPL_set_property(m_dat_ini,"EDITABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","At�:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dat_fim = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_fim,"VARIABLE",mr_campos,"dat_final")
    CALL _ADVPL_set_property(m_dat_fim,"EDITABLE",FALSE) 

END FUNCTION

#--------------------------------------------#
FUNCTION pol1381_panel_analitico(l_container)#
#--------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_pnl_anali = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pnl_anali,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pnl_anali)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brz_analitico = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_analitico,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_analitico)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Num ped cli")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ped_cli")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_analitico)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_pedido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_analitico)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Seq")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_sequencia")

    CALL _ADVPL_set_property(m_brz_analitico,"SET_ROWS",ma_analitico,1)
    CALL _ADVPL_set_property(m_brz_analitico,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_pnl_anali,"VISIBLE",FALSE)

END FUNCTION

#--------------------------------------------#
FUNCTION pol1381_panel_sintetico(l_container)#
#--------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_pnl_sinte= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pnl_sinte,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pnl_sinte)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brz_sintetico = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_sintetico,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sintetico)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item embal")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_embal")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sintetico)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",400)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","descricao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sintetico)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd necess�ria")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_neces")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sintetico)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Peso total")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","peso_total")

    CALL _ADVPL_set_property(m_brz_sintetico,"SET_ROWS",ma_sintetico,1)
    CALL _ADVPL_set_property(m_brz_sintetico,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_pnl_sinte,"VISIBLE",TRUE)

END FUNCTION

#--------------------------------#
FUNCTION pol1381_valida_cliente()#
#--------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF mr_campos.cod_cliente IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", 'Informe o cliente')
      CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   IF NOT pol1381_le_cliente(mr_campos.cod_cliente) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT COUNT(*) INTO m_count
     FROM emabalagem_padrao_405
    WHERE cod_cliente = mr_campos.cod_cliente
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','emabalagem_padrao_405')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Cliente n�o cadastrados no POL1379'
      RETURN FALSE
   END IF

   SELECT COUNT(*) INTO m_count
     FROM item_embal_405
    WHERE cod_cliente = mr_campos.cod_cliente
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item_embal_405')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Cliente n�o cadastrados no pol1381'
      RETURN FALSE
   END IF
     
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1381_le_cliente(l_cod)#
#----------------------------------#
   
   DEFINE l_cod LIKE clientes.cod_cliente
   
   LET m_msg = ''
      
   SELECT nom_cliente
     INTO mr_campos.nom_cliente
     FROM clientes
    WHERE cod_cliente = l_cod
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cliente')    
      LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA cliente'    
      LET mr_campos.nom_cliente = NULL   
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1381_zoom_cliente()#
#------------------------------#

    DEFINE l_codigo       LIKE clientes.cod_cliente,
           l_descricao    LIKE clientes.nom_cliente
    
    IF  m_zoom_cliente IS NULL THEN
        LET m_zoom_cliente = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_cliente,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_cliente,"ACTIVATE")
    
    LET l_codigo    = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_descricao = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")
    
    IF l_codigo IS NOT NULL THEN
       LET mr_campos.cod_cliente = l_codigo
       LET mr_campos.nom_cliente = l_descricao     
    END IF

    CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")

END FUNCTION


#-----------------------------#
FUNCTION pol1381_valida_item()#
#-----------------------------#
    
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
 
    LET m_den_item = NULL
       
   IF mr_campos.cod_item IS NOT NULL THEN
      IF NOT pol1381_le_item(mr_campos.cod_item) THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   END IF
   
   LET mr_campos.den_item = m_den_item
   
   RETURN TRUE

END FUNCTION
#---------------------------#
FUNCTION pol1381_zoom_item()#
#---------------------------#

    DEFINE l_where_clause CHAR(300),
           l_codigo       CHAR(15)
    
    IF  m_zoom_item IS NULL THEN
        LET m_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_item,"ZOOM","zoom_item")
    END IF

    LET l_where_clause = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_item,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")
    
    IF l_codigo IS NOT NULL THEN
       IF pol1381_le_item(l_codigo) THEN
          LET mr_campos.cod_item = l_codigo
          LET mr_campos.den_item = m_den_item
       END IF
    END IF

    CALL _ADVPL_set_property(m_cod_item,"GET_FOCUS")

END FUNCTION

#------------------------------#
FUNCTION pol1381_le_item(l_cod)#
#------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''
      
   SELECT den_item
     INTO m_den_item
     FROM item
    WHERE cod_empresa =  p_cod_empresa
      AND cod_item = l_cod
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')   
      LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA item'    
      LET m_den_item = NULL
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#----------------------------------------#
FUNCTION pol1381_ativa_desativa(l_status)#
#----------------------------------------#
   
   DEFINE l_status        SMALLINT
   
   CALL _ADVPL_set_property(m_pnl_info,"ENABLE",l_status)
   
END FUNCTION

#------------------------------#
FUNCTION pol1381_limpa_campos()#
#------------------------------#

   INITIALIZE mr_campos.* TO NULL
   INITIALIZE ma_analitico TO NULL
   INITIALIZE ma_sintetico TO NULL
   
   CALL _ADVPL_set_property(m_brz_analitico,"SET_ROWS",ma_analitico,1)
   CALL _ADVPL_set_property(m_brz_sintetico,"SET_ROWS",ma_sintetico,1)
   CALL _ADVPL_set_property(m_brz_analitico,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_brz_sintetico,"VISIBLE",TRUE)
   
END FUNCTION

#--------------------------#
FUNCTION pol1381_informar()#
#--------------------------#
   
   LET m_dat_atu = TODAY
   LET m_dat_prev_ini = m_dat_atu
   LET m_dat_prev_fim = m_dat_atu + 6
   
   LET m_dat_aval_ini = m_dat_prev_fim + 1
   LET m_dat_aval_fim = m_dat_aval_ini + 6
   
   CALL log0030_mensagem(m_dat_prev_ini,'info')
   CALL log0030_mensagem(m_dat_prev_fim,'info')
   CALL log0030_mensagem(m_dat_aval_ini,'info')
   CALL log0030_mensagem(m_dat_aval_fim,'info')
      
   CALL pol1381_limpa_campos()
   CALL pol1381_ativa_desativa(TRUE)
   LET m_ies_info = FALSE
   
   LET mr_campos.dat_inicial = m_dat_prev_ini #m_dat_aval_ini
   LET mr_campos.dat_final = m_dat_prev_fim #m_dat_aval_fim
   
   CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1381_cancelar()#
#--------------------------#

   CALL pol1381_limpa_campos()
   CALL pol1381_ativa_desativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1381_confirmar()#
#---------------------------#
   
   LET p_status = LOG_progresspopup_start(
     "Pesquisando...","pol1381_le_pedidos","PROCESS") 

   IF p_status THEN
      LET m_ies_info = TRUE
   END IF
     
   RETURN p_status

END FUNCTION

#----------------------------#
FUNCTION pol1381_le_pedidos()#
#----------------------------#
   
   DEFINE l_query        CHAR(2000),
          l_progres      SMALLINT,
          l_msg          CHAR(400),
          l_qtd_ok       INTEGER
   
   IF NOT pol1381_cria_temp() THEN
      RETURN FALSE
   END IF
   
   INITIALIZE ma_divergencia TO NULL
   LET m_qtd_erro = 0

   LET l_query = 
    " SELECT COUNT(ped_itens.num_sequencia) ",
    " FROM ped_itens, pedidos ",
    " WHERE pedidos.cod_empresa = ped_itens.cod_empresa ",
    " AND pedidos.num_pedido = ped_itens.num_pedido ",
    " AND pedidos.ies_sit_pedido <> '9' ",
    " AND pedidos.cod_cliente = '",mr_campos.cod_cliente,"' ",
    " AND pedidos.cod_empresa = '",p_cod_empresa,"' ",
    " AND ped_itens.prz_entrega >= '",mr_campos.dat_inicial,"' ",
    " AND ped_itens.prz_entrega <= '",mr_campos.dat_final,"' ",
    " AND ((ped_itens.qtd_pecas_solic - ped_itens.qtd_pecas_atend - ped_itens.qtd_pecas_cancel) > 0) "

   IF mr_campos.cod_item IS NOT NULL THEN
      LET l_query = l_query CLIPPED, " AND ped_itens.cod_item = '",mr_campos.cod_item,"' "
   END IF
         
   PREPARE var_cont FROM l_query
   
   IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","prepare-var_cont")
       RETURN FALSE
   END IF

   DECLARE cq_cont CURSOR FOR var_cont

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DECLARE CURSOR","declare-cq_cont")
      RETURN FALSE
   END IF
   
   FETCH cq_cont INTO m_count

   IF STATUS <> 0 THEN
      CALL log003_err_sql("FETCH","FETCH-cq_cont")
      RETURN FALSE
   END IF

   IF m_count = 0 THEN
      LET m_msg = 'N�o a registros para os \n par�metros informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   LET l_query = 
    " SELECT pedidos.num_pedido, pedidos.num_pedido_cli,  ",
    "  ped_itens.num_sequencia, ped_itens.cod_item, ped_itens.prz_entrega, ",
    "  (ped_itens.qtd_pecas_solic - ped_itens.qtd_pecas_atend - ped_itens.qtd_pecas_cancel) ",
    " FROM ped_itens, pedidos ",
    " WHERE pedidos.cod_empresa = ped_itens.cod_empresa ",
    " AND pedidos.num_pedido = ped_itens.num_pedido ",
    " AND pedidos.ies_sit_pedido <> '9' ",
    " AND pedidos.cod_cliente = '",mr_campos.cod_cliente,"' ",
    " AND pedidos.cod_empresa = '",p_cod_empresa,"' ",
    " AND ped_itens.prz_entrega >= '",mr_campos.dat_inicial,"' ",
    " AND ped_itens.prz_entrega <= '",mr_campos.dat_final,"' ",
    " AND ((ped_itens.qtd_pecas_solic - ped_itens.qtd_pecas_atend - ped_itens.qtd_pecas_cancel) > 0) "

   IF mr_campos.cod_item IS NOT NULL THEN
      LET l_query = l_query CLIPPED, " AND ped_itens.cod_item = '",mr_campos.cod_item,"' "
   END IF
         
   PREPARE query FROM l_query
   
   IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","prepare-l_query")
       RETURN FALSE
   END IF
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   DECLARE cq_reg CURSOR FOR query

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DECLARE CURSOR","declare-cq_reg")
      RETURN FALSE
   END IF
   
   FOREACH cq_reg INTO 
      mr_faturar.num_pedido,
      mr_faturar.num_pedido_cli,
      mr_faturar.num_sequencia,
      mr_faturar.cod_item, 
      mr_faturar.prz_entrega,
      mr_faturar.qtd_faturar
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("SELECT","foreach-cq_reg")
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      SELECT cod_item_embal,
             qtd_item_embal 
        INTO mr_faturar.cod_item_embal,
             mr_faturar.qtd_item_embal
        FROM item_embal_405
       WHERE cod_cliente = mr_campos.cod_cliente
         AND cod_item = mr_faturar.cod_item

      IF STATUS = 100 THEN
         CALL pol1381_add_divergencia()
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql("SELECT","item_embal_405-cq_reg")
            RETURN FALSE
         END IF
      END IF
      
      INSERT INTO fat_pol1381_temp VALUES(mr_faturar.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql("INSERT","fat_pol1381_temp")
         RETURN FALSE
      END IF
      
   END FOREACH
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   SELECT COUNT(*) INTO l_qtd_ok
    FROM fat_pol1381_temp

   IF STATUS <> 0 THEN
      CALL log003_err_sql("SELECT","fat_pol1381_temp:count")
      RETURN FALSE
   END IF
    
   LET l_msg = "Registros lidos a partir dos parametros: ",m_count,"\n",
               "Registros prontos para  o processamento: ",l_qtd_ok,"\n",
               "Registros sem cadastro no POL1380: ",m_qtd_erro,"\n"
   
   CALL log0030_mensagem(l_msg,'info')
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1381_cria_temp()#
#---------------------------#
   
   DROP TABLE fat_pol1381_temp
   
   CREATE TABLE fat_pol1381_temp (
       num_pedido        DECIMAL(6,0),
       num_pedido_cli    CHAR(30),
       num_sequencia     DECIMAL(3,0),
       cod_item          CHAR(15),
       prz_entrega       DATE,
       qtd_faturar       DECIMAL(10,3),
       cod_item_embal    CHAR(15),
       qtd_item_embal    DECIMAL(10,3)
   );
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','fat_pol1381_temp')
      RETURN FALSE
   END IF
      
   CREATE INDEX ix_pol1381 ON fat_pol1381_temp
    (num_pedido, cod_item);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','INDEX-ix_pol1381')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
       
#---------------------------------#
FUNCTION pol1381_add_divergencia()#
#---------------------------------#

   LET m_qtd_erro = m_qtd_erro + 1
   LET ma_divergencia[m_qtd_erro].cod_item = mr_faturar.cod_item
   LET ma_divergencia[m_qtd_erro].mensagem = 'Sem cadastro no pol180'

END FUNCTION   
   
#---------------------------#
FUNCTION pol1381_sintetica()#
#---------------------------#

   CALL _ADVPL_set_property(m_pnl_anali,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_pnl_sinte,"VISIBLE",TRUE)

   RETURN TRUE

END FUNCTION
   
#---------------------------#
FUNCTION pol1381_analitica()#
#---------------------------#

   CALL _ADVPL_set_property(m_pnl_sinte,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_pnl_anali,"VISIBLE",TRUE)

   RETURN TRUE

END FUNCTION
