# https://www.hoteis.com/ho1197467840/?pa=5&q-check-out=2020-01-26&tab=description&q-room-0-adults=2&YGF=3&q-check-in=2020-01-25&MGT=1&WOE=7&WOD=6&ZSX=0&SYE=3&q-room-0-children=0

#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1381                                                 #
# OBJETIVO: EMBALAGEM - APURAÇÃO DAS NECESSIDADES                   #
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
       m_descricao       VARCHAR(10),
       m_zoom_item       VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_dat_ini         VARCHAR(10),
       m_dat_fim         VARCHAR(10),
       m_brz_pedido      VARCHAR(10),
       m_brz_embal       VARCHAR(10),
       m_brz_sintetico   VARCHAR(10),
       m_pnl_info        VARCHAR(10),
       m_menu_anali      VARCHAR(10),
       m_menu_sinte      VARCHAR(10),
       m_pnl_sinte       VARCHAR(10),
       m_pnl_anali       VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_proc_analitic   SMALLINT,
       m_proc_sintetic   SMALLINT,
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
       m_qtd_erro        INTEGER,   
       m_ind_ped         INTEGER,
       m_den_item        VARCHAR(76),
       m_den_item_reduz  VARCHAR(18),
       m_lin_atu         INTEGER,
       m_qtd_neces       INTEGER,
       m_index           INTEGER,
       m_cod_embal       CHAR(15),
       m_cod_compon      CHAR(15),
       m_qtd_embal       INTEGER,
       m_qtd_ant         INTEGER
       
DEFINE mr_campos         RECORD
       cod_cliente       LIKE clientes.cod_cliente,
       nom_cliente       LIKE clientes.nom_cliente,
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item,
       dat_inicial       DATE,
       dat_final         DATE
END RECORD

DEFINE ma_pedido      ARRAY[1000] OF RECORD
       id_embal          INTEGER,
       num_pedido        DECIMAL(6,0),
       num_ped_cli       VARCHAR(30),
       num_sequencia     DECIMAL(3,0),
       cod_item          CHAR(15),
       den_item_reduz    CHAR(18),
       item_Cliente      CHAR(15),
       prz_entrega       DATE,
       qtd_faturar       INTEGER,
       cod_item_embal    CHAR(15),
       den_item_embal    CHAR(30),
       qtd_item_embal    INTEGER,
       qtd_embalagem     INTEGER
END RECORD

DEFINE ma_embal          ARRAY[20] OF RECORD
       cod_item_compon   CHAR(15),
       den_compon        CHAR(18),
       qtd_neces         INTEGER
END RECORD
       

DEFINE ma_sintetico      ARRAY[1000] OF RECORD
       cod_item_compon   CHAR(15),
       descricao         VARCHAR(50),
       saldo_atual       INTEGER,
       neces_per_pre     INTEGER,
       saldo_per_aval    INTEGER,
       neces_per_aval    INTEGER,
       qtd_solicitar     INTEGER,
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
       qtd_item_embal    DECIMAL(10,3),
       qtd_embalagem     INTEGER
END RECORD

DEFINE ma_divergencia    ARRAY[2000] OF RECORD
       cod_item          CHAR(15),
       mensagem          CHAR(80)
END RECORD       

DEFINE m_pes_unit        LIKE item.pes_unit,
       m_cod_local_estoq LIKE item.cod_local_estoq,
       m_desc_pre        CHAR(40),
       m_desc_atu        CHAR(40)
       
#-----------------#
FUNCTION pol1381()#
#-----------------#

   DEFINE l_per_pre, l_per_atu CHAR(30)
   
   LET m_dat_atu = TODAY
   LET m_dat_prev_ini = m_dat_atu
   LET m_dat_prev_fim = m_dat_atu + 6
   
   LET m_dat_aval_ini = m_dat_prev_fim + 1
   LET m_dat_aval_fim = m_dat_aval_ini + 6
   LET m_carregando = TRUE

   LET l_per_pre = m_dat_prev_ini, ' - ',m_dat_prev_fim
   LET l_per_atu = m_dat_aval_ini, ' - ',m_dat_aval_fim
   
   LET m_desc_pre = 'Neces periodo ',l_per_pre
   LET m_desc_atu = 'Neces periodo ',l_per_atu
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1381-12.00.02  "
   CALL func002_versao_prg(p_versao)

   IF NOT pol1381_cria_tabs() THEN
      RETURN FALSE
   END IF
      
   CALL pol1381_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1381_menu()#
#----------------------#

    DEFINE l_menubar,
           l_panel,
           l_inform,
           l_titulo           VARCHAR(80)
    
    LET l_titulo = "EMBALAGEM - APURAÇÃO DAS NECESSIDADES - ",p_versao
    
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

    LET m_menu_anali = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(m_menu_anali,"IMAGE","ANALISE_CONSUMO") 
    CALL _ADVPL_set_property(m_menu_anali,"TOOLTIP","Consumo de embalgem por produto")
    CALL _ADVPL_set_property(m_menu_anali,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(m_menu_anali,"EVENT","pol1381_analitica")

    LET m_menu_sinte = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(m_menu_sinte,"IMAGE","RESUMO_PEDIDO") 
    CALL _ADVPL_set_property(m_menu_sinte,"TOOLTIP","Resumo para pedido de embalagem")
    CALL _ADVPL_set_property(m_menu_sinte,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(m_menu_sinte,"EVENT","pol1381_sintetica")

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

    LET m_cod_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_item,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_item,"VARIABLE",mr_campos,"cod_item")
    CALL _ADVPL_set_property(m_cod_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_item,"CLICK_EVENT","pol1381_valida_item")

    LET m_lupa_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_item,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_item,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_item,"CLICK_EVENT","pol1381_zoom_item")

    LET m_descricao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_descricao,"LENGTH",50) 
    CALL _ADVPL_set_property(m_descricao,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_descricao,"VARIABLE",mr_campos,"den_item")
    CALL _ADVPL_set_property(m_descricao,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Período de:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dat_ini = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_ini,"VARIABLE",mr_campos,"dat_inicial")
    CALL _ADVPL_set_property(m_dat_ini,"EDITABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Até:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dat_fim = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_fim,"VARIABLE",mr_campos,"dat_final")
    CALL _ADVPL_set_property(m_dat_fim,"EDITABLE",FALSE) 

END FUNCTION

#--------------------------------------------#
FUNCTION pol1381_panel_analitico(l_container)#
#--------------------------------------------#

    DEFINE l_container       VARCHAR(10)

    LET m_pnl_anali = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pnl_anali,"ALIGN","CENTER")
    LET m_carregando = TRUE
    CALL pol1381_cria_panel_pedido(m_pnl_anali)
    CALL pol1381_cria_panel_embal(m_pnl_anali)

END FUNCTION

#----------------------------------------------#
FUNCTION pol1381_cria_panel_pedido(l_container)#
#----------------------------------------------#
   
   DEFINE l_container   VARCHAR(10),
          l_panel       VARCHAR(10),
          l_layout      VARCHAR(10),
          l_tabcolumn   VARCHAR(10)
          
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brz_pedido = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_pedido,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_pedido,"BEFORE_ROW_EVENT","pol1381_ped_before_row")
    
    {LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Num ped cli")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ped_cli")}

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_pedido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Seq")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_sequencia")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Produto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item_reduz")

    {LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","item_Cliente")}

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","prz_entrega")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Faturar")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_faturar")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Embalagem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item_embal")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item_embal")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qdt embal")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_embalagem")

    CALL _ADVPL_set_property(m_brz_pedido,"SET_ROWS",ma_pedido,1)
    CALL _ADVPL_set_property(m_brz_pedido,"EDITABLE",FALSE)

END FUNCTION

#---------------------------------------------#
FUNCTION pol1381_cria_panel_embal(l_container)#
#---------------------------------------------#
   
   DEFINE l_container   VARCHAR(10),
          l_panel       VARCHAR(10),
          l_layout      VARCHAR(10),
          l_tabcolumn   VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brz_embal = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_embal,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_embal)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Componente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_embal)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_embal)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Quant")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_neces")

    CALL _ADVPL_set_property(m_brz_embal,"SET_ROWS",ma_embal,1)
    CALL _ADVPL_set_property(m_brz_embal,"EDITABLE",FALSE)

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
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sintetico)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","descricao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sintetico)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Saldo atual")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","saldo_atual")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sintetico)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER",m_desc_pre)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","neces_per_pre")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sintetico)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Saldo periodo aval")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","saldo_per_aval")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sintetico)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER",m_desc_atu)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","neces_per_aval")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sintetico)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd solicitar")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_solicitar")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sintetico)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Peso total")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","peso_total")

    CALL _ADVPL_set_property(m_brz_sintetico,"SET_ROWS",ma_sintetico,1)
    CALL _ADVPL_set_property(m_brz_sintetico,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_pnl_sinte,"VISIBLE",FALSE)

END FUNCTION

#--------------------------------#
FUNCTION pol1381_ped_before_row()#
#--------------------------------#

   IF m_carregando THEN
      RETURN TRUE
   END IF
     
   LET m_lin_atu = _ADVPL_get_property(m_brz_pedido,"ROW_SELECTED")
      
   CALL pol1381_le_compon()
   
   RETURN TRUE

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
     FROM embalagem_padrao_405
    WHERE cod_cliente = mr_campos.cod_cliente
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','embalagem_padrao_405')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Cliente não cadastrados no POL1379'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
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
      LET m_msg = 'Cliente não cadastrados no pol1380'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
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
      
   SELECT den_item, den_item_reduz, 
          pes_unit, cod_local_estoq
     INTO m_den_item,
          m_den_item_reduz,
          m_pes_unit,
          m_cod_local_estoq
     FROM item
    WHERE cod_empresa =  p_cod_empresa
      AND cod_item = l_cod
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')   
      LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA item'    
      LET m_den_item = NULL
      LET m_den_item_reduz = NULL
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
   INITIALIZE ma_pedido TO NULL
   INITIALIZE ma_embal TO NULL
   INITIALIZE ma_sintetico TO NULL
   
   CALL _ADVPL_set_property(m_brz_pedido,"SET_ROWS",ma_pedido,1)
   CALL _ADVPL_set_property(m_brz_embal,"SET_ROWS",ma_embal,1)
   CALL _ADVPL_set_property(m_brz_sintetico,"SET_ROWS",ma_sintetico,1)
   CALL _ADVPL_set_property(m_pnl_sinte,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_pnl_anali,"VISIBLE",TRUE)
   
END FUNCTION

#--------------------------#
FUNCTION pol1381_informar()#
#--------------------------#
      
   CALL pol1381_limpa_campos()
   CALL pol1381_ativa_desativa(TRUE)
   LET m_ies_info = FALSE
   LET m_proc_analitic = FALSE
   LET m_proc_sintetic = FALSE
      
   CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1381_cancelar()#
#--------------------------#

   CALL pol1381_limpa_campos()
   CALL pol1381_ativa_desativa(FALSE)
   LET m_carregando = FALSE
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1381_confirmar()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   DELETE FROM fat_pre_periodo_405
   DELETE FROM fat_real_periodo_405
      
   LET mr_campos.dat_inicial = m_dat_prev_ini #m_dat_aval_ini
   LET mr_campos.dat_final = m_dat_prev_fim #m_dat_aval_fim
   
   LET p_status = LOG_progresspopup_start(
     "Pesquisando...","pol1381_le_pedidos","PROCESS") 

   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   INSERT INTO fat_pre_periodo_405 SELECT * FROM fat_pol1381_405

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','fat_pre_periodo_405')
      RETURN FALSE
   END IF
   
   LET mr_campos.dat_inicial = m_dat_aval_ini
   LET mr_campos.dat_final = m_dat_aval_fim

   LET p_status = LOG_progresspopup_start(
     "Pesquisando...","pol1381_le_pedidos","PROCESS") 

   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   SELECT COUNT(*) INTO m_count
     FROM fat_pol1381_405

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','fat_pol1381_405')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Não há dados para os parâmetros informados!'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
   
   INSERT INTO fat_real_periodo_405 SELECT * FROM fat_pol1381_405

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','fat_real_periodo_405')
      RETURN FALSE
   END IF
   
   LET m_ies_info = TRUE
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1381_cria_tabs()#
#---------------------------#

   DROP TABLE fat_pol1381_405
   
   CREATE TABLE fat_pol1381_405 (
       num_pedido        DECIMAL(6,0),
       num_pedido_cli    CHAR(30),
       num_sequencia     DECIMAL(3,0),
       cod_item          CHAR(15),
       prz_entrega       DATE,
       qtd_faturar       DECIMAL(10,3),
       cod_item_embal    CHAR(15),
       qtd_item_embal    DECIMAL(10,3),
       qtd_embalagem     INTEGER
   );
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','fat_pol1381_405')
      RETURN FALSE
   END IF
      
   CREATE INDEX ix_fat_pol1381_405 ON fat_pol1381_405
    (num_pedido, cod_item);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','INDEX-ix_fat_pol1381_405')
      RETURN FALSE
   END IF
   
   DROP TABLE fat_pre_periodo_405
   
   CREATE TABLE fat_pre_periodo_405 (
       num_pedido        DECIMAL(6,0),
       num_pedido_cli    CHAR(30),
       num_sequencia     DECIMAL(3,0),
       cod_item          CHAR(15),
       prz_entrega       DATE,
       qtd_faturar       DECIMAL(10,3),
       cod_item_embal    CHAR(15),
       qtd_item_embal    DECIMAL(10,3),
       qtd_embalagem     INTEGER
   );
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','fat_pre_periodo_405')
      RETURN FALSE
   END IF
      
   CREATE INDEX ix_fat_pre_periodo_405 ON fat_pre_periodo_405
    (num_pedido, cod_item);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','INDEX-ix_fat_pre_periodo_405')
      RETURN FALSE
   END IF

   DROP TABLE fat_real_periodo_405
   
   CREATE TABLE fat_real_periodo_405 (
       num_pedido        DECIMAL(6,0),
       num_pedido_cli    CHAR(30),
       num_sequencia     DECIMAL(3,0),
       cod_item          CHAR(15),
       prz_entrega       DATE,
       qtd_faturar       DECIMAL(10,3),
       cod_item_embal    CHAR(15),
       qtd_item_embal    DECIMAL(10,3),
       qtd_embalagem     INTEGER
   );
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','fat_real_periodo_405')
      RETURN FALSE
   END IF
      
   CREATE INDEX ix_fat_real_periodo_405 ON fat_real_periodo_405
    (num_pedido, cod_item);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','INDEX-ix_fat_real_periodo_405')
      RETURN FALSE
   END IF
   
   DROP TABLE embal_compon_405
   
   CREATE TABLE embal_compon_405(
      cod_compon     CHAR(15),
      qtd_pre        INTEGER,
      qtd_aval       INTEGER
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','embal_compon_405')
      RETURN FALSE
   END IF

   CREATE INDEX ix_embal_compon_405 ON embal_compon_405
    (cod_compon);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','INDEX-ix_embal_compon_405')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1381_le_pedidos()#
#----------------------------#
   
   DEFINE l_query        CHAR(2000),
          l_progres      SMALLINT
   
   DELETE FROM fat_pol1381_405
      
   INITIALIZE ma_divergencia TO NULL
   LET m_qtd_erro = 0

   LET l_query = 
    " SELECT COUNT(ped_itens.num_sequencia) ",
    " FROM ped_itens, pedidos, item_embal_405 ",
    " WHERE pedidos.cod_empresa = ped_itens.cod_empresa ",
    " AND pedidos.num_pedido = ped_itens.num_pedido ",
    " AND pedidos.ies_sit_pedido <> '9' ",
    " AND pedidos.cod_cliente = '",mr_campos.cod_cliente,"' ",
    " AND pedidos.cod_empresa = '",p_cod_empresa,"' ",
    " AND ped_itens.prz_entrega >= '",mr_campos.dat_inicial,"' ",
    " AND ped_itens.prz_entrega <= '",mr_campos.dat_final,"' ",
    " AND ((ped_itens.qtd_pecas_solic - ped_itens.qtd_pecas_atend - ped_itens.qtd_pecas_cancel) > 0) ",
    " AND item_embal_405.cod_cliente =  pedidos.cod_cliente ",
    " AND item_embal_405.cod_item = ped_itens.cod_item "

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

    OPEN cq_cont

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_cont")
       RETURN FALSE
    END IF
   
   FETCH cq_cont INTO m_count

   IF STATUS <> 0 THEN
      CALL log003_err_sql("FETCH","FETCH-cq_cont")
      RETURN FALSE
   END IF

   IF m_count = 0 THEN
      LET m_msg = 'Não a registros para os \n parãmetros informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   LET l_query = 
    " SELECT pedidos.num_pedido, pedidos.num_pedido_cli,  ",
    "  ped_itens.num_sequencia, ped_itens.cod_item, ped_itens.prz_entrega, ",
    "  (ped_itens.qtd_pecas_solic - ped_itens.qtd_pecas_atend - ped_itens.qtd_pecas_cancel), ",
    " item_embal_405.cod_item_embal, item_embal_405.qtd_item_embal ",
    " FROM ped_itens, pedidos, item_embal_405 ",
    " WHERE pedidos.cod_empresa = ped_itens.cod_empresa ",
    " AND pedidos.num_pedido = ped_itens.num_pedido ",
    " AND pedidos.ies_sit_pedido <> '9' ",
    " AND pedidos.cod_cliente = '",mr_campos.cod_cliente,"' ",
    " AND pedidos.cod_empresa = '",p_cod_empresa,"' ",
    " AND ped_itens.prz_entrega >= '",mr_campos.dat_inicial,"' ",
    " AND ped_itens.prz_entrega <= '",mr_campos.dat_final,"' ",
    " AND ((ped_itens.qtd_pecas_solic - ped_itens.qtd_pecas_atend - ped_itens.qtd_pecas_cancel) > 0) ",
    " AND item_embal_405.cod_cliente =  pedidos.cod_cliente ",
    " AND item_embal_405.cod_item = ped_itens.cod_item "

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
      mr_faturar.qtd_faturar,
      mr_faturar.cod_item_embal,
      mr_faturar.qtd_item_embal
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("SELECT","foreach-cq_reg")
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET mr_faturar.qtd_embalagem = mr_faturar.qtd_faturar / mr_faturar.qtd_item_embal

      IF (mr_faturar.qtd_faturar MOD mr_faturar.qtd_item_embal ) > 0 THEN 
         LET mr_faturar.qtd_embalagem = mr_faturar.qtd_embalagem + 1
      END IF
       
      INSERT INTO fat_pol1381_405 VALUES(mr_faturar.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql("INSERT","fat_pol1381_405")
         RETURN FALSE
      END IF
      
   END FOREACH
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
      
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
FUNCTION pol1381_analitica()#
#---------------------------#

   CALL _ADVPL_set_property(m_pnl_sinte,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_pnl_anali,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF NOT m_ies_info OR m_proc_analitic THEN
      LET m_msg = 'Informe previamente os parâmetros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
   
   LET p_status = LOG_progresspopup_start(
     "Pesquisando...","pol1381_proc_analitic","PROCESS") 


   LET m_proc_analitic = TRUE
   LET m_carregando = FALSE
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1381_proc_analitic()#
#-------------------------------#
   
   DEFINE l_progres     SMALLINT    
   
   SELECT COUNT(*) INTO m_count
     FROM fat_real_periodo_405
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','fat_real_periodo_405:count')
      RETURN FALSE
   END IF
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   LET m_carregando = TRUE
   LET m_ind_ped = 1
   
   DECLARE cq_fat CURSOR FOR
    SELECT * FROM fat_real_periodo_405
   
   FOREACH cq_fat INTO 
      ma_pedido[m_ind_ped].num_pedido,    
      ma_pedido[m_ind_ped].num_ped_cli,
      ma_pedido[m_ind_ped].num_sequencia, 
      ma_pedido[m_ind_ped].cod_item,      
      ma_pedido[m_ind_ped].prz_entrega,   
      ma_pedido[m_ind_ped].qtd_faturar,   
      ma_pedido[m_ind_ped].cod_item_embal,
      ma_pedido[m_ind_ped].qtd_item_embal,
      ma_pedido[m_ind_ped].qtd_embalagem 
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','fat_real_periodo_405:cq_fat')
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")      
      
      CALL pol1381_le_item(ma_pedido[m_ind_ped].cod_item) RETURNING p_status
      LET ma_pedido[m_ind_ped].den_item_reduz = m_den_item_reduz

      SELECT id_embal, den_item_embal 
        INTO ma_pedido[m_ind_ped].id_embal,
             ma_pedido[m_ind_ped].den_item_embal
        FROM embalagem_padrao_405
       WHERE cod_cliente = mr_campos.cod_cliente       
         AND cod_item_embal = ma_pedido[m_ind_ped].cod_item_embal
   
      IF STATUS <> 0 THEN
         LET ma_pedido[m_ind_ped].den_item_embal = NULL
      END IF
      
      LET m_ind_ped = m_ind_ped + 1
      
      IF m_ind_ped > 1000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.'
         CALL log0030_mensagem(m_msg,'1info')
         exit FOREACH
      END IF
   
   END FOREACH
   
   LET m_ind_ped = m_ind_ped - 1
   
   CALL _ADVPL_set_property(m_brz_pedido,"ITEM_COUNT", m_ind_ped)
   LET m_lin_atu = 1
   CALL pol1381_le_compon()
   
   RETURN TRUE
   
END FUNCTION
   
#---------------------------#
FUNCTION pol1381_le_compon()#
#---------------------------#

   DEFINE l_id        INTEGER,
          l_ind       INTEGER
   
   LET l_id = ma_pedido[m_lin_atu].id_embal
   
   INITIALIZE ma_embal TO NULL
   CALL _ADVPL_set_property(m_brz_embal,"CLEAR")
   LET l_ind = 1
   
   DECLARE cq_compon CURSOR FOR
    SELECT cod_item_compon, den_item_reduz, qtd_necess
      FROM embalagem_compon_405, item
     WHERE item.cod_empresa = p_cod_empresa
       AND item.cod_item = embalagem_compon_405.cod_item_compon
       AND embalagem_compon_405.id_embal = l_id

   FOREACH cq_compon INTO 
      ma_embal[l_ind].cod_item_compon,
      ma_embal[l_ind].den_compon,
      m_qtd_neces

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','embalagem_compon_405:cq_compon')
         EXIT FOREACH
      END IF
      
      LET ma_embal[l_ind].qtd_neces = ma_pedido[m_lin_atu].qtd_embalagem * m_qtd_neces
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 20 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.'
         CALL log0030_mensagem(m_msg,'1info')
         EXIT FOREACH
      END IF
      
   END FOREACH

   LET l_ind = l_ind - 1
   
   CALL _ADVPL_set_property(m_brz_embal,"ITEM_COUNT", l_ind)
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1381_sintetica()#
#---------------------------#
   
   DEFINE l_count     INTEGER
   
   CALL _ADVPL_set_property(m_pnl_anali,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_pnl_sinte,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF NOT m_ies_info OR m_proc_sintetic THEN
      LET m_msg = 'Informe previamente os parâmetros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   SELECT COUNT(*) INTO l_count
     FROM fat_pre_periodo_405
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','fat_pre_periodo_405:count')
      RETURN FALSE
   END IF
   
   LET m_count = l_count

   SELECT COUNT(*) INTO l_count
     FROM fat_real_periodo_405
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','fat_real_periodo_405:count')
      RETURN FALSE
   END IF
   
   LET m_count = m_count + l_count
   
   LET p_status = LOG_progresspopup_start(
     "Pesquisando...","pol1381_proc_sintetic","PROCESS") 

   LET m_proc_sintetic = TRUE

   RETURN TRUE

END FUNCTION
      
#-------------------------------#
FUNCTION pol1381_proc_sintetic()#
#-------------------------------#
   
   DEFINE l_progres     SMALLINT,
          l_status      SMALLINT,
          l_qtd_saldo   DECIMAL(10,3),
          l_qtd_pre     INTEGER,
          l_qtd_aval    INTEGER
   
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DELETE FROM embal_compon_405
   
   DECLARE cq_proc_sint CURSOR FOR
    SELECT cod_item_embal, 
           SUM(qtd_embalagem) 
      FROM fat_real_periodo_405 
     GROUP BY cod_item_embal

   FOREACH cq_proc_sint INTO m_cod_embal, m_qtd_embal
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','fat_real_periodo_405:cq_proc_sint')
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")      
      
      SELECT SUM(qtd_embalagem)  
        INTO m_qtd_ant
        FROM fat_pre_periodo_405 
       WHERE cod_item_embal = m_cod_embal

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','fat_pre_periodo_405:cq_proc_sint')
         RETURN FALSE
      END IF
      
      IF m_qtd_ant IS NULL THEN
         LET m_qtd_ant = 0
      END IF
      
      DECLARE cq_estrut CURSOR FOR
       SELECT cod_item_compon, qtd_necess 
         FROM embalagem_compon_405, embalagem_padrao_405
        WHERE embalagem_padrao_405.cod_item_embal = m_cod_embal
          AND embalagem_padrao_405.cod_cliente = mr_campos.cod_cliente
          AND embalagem_padrao_405.id_embal = embalagem_compon_405.id_embal

      FOREACH cq_estrut INTO m_cod_compon, m_qtd_neces

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','embalagem_padrao_405:cq_estrut')
            RETURN FALSE
         END IF
         
         LET l_qtd_pre = m_qtd_ant * m_qtd_neces
         LET l_qtd_aval = m_qtd_embal * m_qtd_neces
         
         INSERT INTO embal_compon_405
          VALUES(m_cod_compon, l_qtd_pre, l_qtd_aval)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('INSERT','embal_compon_405:cq_estrut')
            RETURN FALSE
         END IF
      
      END FOREACH
   
   END FOREACH
   
   LET m_index = 1

   DECLARE cq_it_compon CURSOR FOR
    SELECT cod_compon, SUM(qtd_pre), SUM(qtd_aval)  
      FROM embal_compon_405
     GROUP BY cod_compon
   
   FOREACH cq_it_compon INTO 
      ma_sintetico[m_index].cod_item_compon,
      ma_sintetico[m_index].neces_per_pre,
      ma_sintetico[m_index].neces_per_aval

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','embal_compon_405:cq_estrut')
         RETURN FALSE
      END IF
         
      CALL pol1381_le_item(ma_sintetico[m_index].cod_item_compon) RETURNING l_status
      LET ma_sintetico[m_index].descricao = m_den_item_reduz

      SELECT SUM(qtd_saldo) INTO l_qtd_saldo
        FROM estoque_lote
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_sintetico[m_index].cod_item_compon
         AND cod_local = m_cod_local_estoq

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque_lote:cq_it_compon')
         RETURN FALSE
      END IF
      
      IF l_qtd_saldo IS NULL THEN
         LET l_qtd_saldo = 0
      END IF
      
      LET ma_sintetico[m_index].saldo_atual = l_qtd_saldo
      
      IF ma_sintetico[m_index].saldo_atual > ma_sintetico[m_index].neces_per_pre THEN
         LET ma_sintetico[m_index].saldo_per_aval = ma_sintetico[m_index].saldo_atual 
             - ma_sintetico[m_index].neces_per_pre
      ELSE
         LET ma_sintetico[m_index].saldo_per_aval = 0
      END IF 
      
      IF ma_sintetico[m_index].neces_per_aval > ma_sintetico[m_index].saldo_per_aval THEN
         LET ma_sintetico[m_index].qtd_solicitar = ma_sintetico[m_index].neces_per_aval 
             - ma_sintetico[m_index].saldo_per_aval          
      ELSE
         LET ma_sintetico[m_index].qtd_solicitar = 0
      END IF
      
      LET ma_sintetico[m_index].peso_total = m_pes_unit * ma_sintetico[m_index].qtd_solicitar
      
      LET m_index = m_index + 1

      IF m_index > 1000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH   

   LET m_index = m_index - 1
   
   CALL _ADVPL_set_property(m_brz_sintetico,"ITEM_COUNT", m_index)
   
   RETURN TRUE
   
END FUNCTION
