# https://www.hoteis.com/ho1197467840/?pa=5&q-check-out=2020-01-26&tab=description&q-room-0-adults=2&YGF=3&q-check-in=2020-01-25&MGT=1&WOE=7&WOD=6&ZSX=0&SYE=3&q-room-0-children=0

#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1381                                                 #
# OBJETIVO: ESTRUTURA - APURAÇÃO DAS NECESSIDADES                   #
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
       m_carregando      SMALLINT
       
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
    
    LET l_titulo = "ESTRUTURA - APURAÇÃO DAS NECESSIDADES - ",p_versao
    
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
    CALL _ADVPL_set_property(m_menu_sinte,"TOOLTIP","Processa apuração sintética")
    CALL _ADVPL_set_property(m_menu_sinte,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(m_menu_sinte,"EVENT","pol1349_sintetica")

    LET m_menu_anali = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(m_menu_anali,"IMAGE","ANALISE_ITEM") 
    CALL _ADVPL_set_property(m_menu_anali,"TOOLTIP","Processa apuração analítica")
    CALL _ADVPL_set_property(m_menu_anali,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(m_menu_anali,"EVENT","pol1349_analitica")

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
    CALL _ADVPL_set_property(l_label,"TEXT","Código item:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_item,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_item,"VARIABLE",mr_campos,"cod_item")
    CALL _ADVPL_set_property(m_cod_item,"PICTURE","@!")

    LET m_lupa_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_item,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_item,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_item,"CLICK_EVENT","pol1381_zoom_embal")

    LET m_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_item,"LENGTH",50) 
    CALL _ADVPL_set_property(m_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_den_item,"VARIABLE",mr_campos,"den_item")
    CALL _ADVPL_set_property(m_den_item,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Período de:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dat_ini = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_ini,"VARIABLE",mr_campos,"dat_inicial")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Até:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dat_fim = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_fim,"VARIABLE",mr_campos,"dat_final")

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
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",400)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","descricao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sintetico)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd necessária")
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

#--------------------------#
FUNCTION pol1381_informar()#
#--------------------------#
   
   CALL pol1381_limpa_campos()
   CALL pol1381_ativa_desativa(TRUE)
   CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")

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

#---------------------------#
FUNCTION pol1349_sintetica()#
#---------------------------#

   CALL _ADVPL_set_property(m_pnl_anali,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_pnl_sinte,"VISIBLE",TRUE)

   RETURN TRUE

END FUNCTION
   
#---------------------------#
FUNCTION pol1349_analitica()#
#---------------------------#

   CALL _ADVPL_set_property(m_pnl_sinte,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_pnl_anali,"VISIBLE",TRUE)

   RETURN TRUE

END FUNCTION

