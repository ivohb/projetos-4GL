#-------------------------------------------------------------------#
# SISTEMA.: LOGIX      ETHOS INDUSTRIAL                             #
# PROGRAMA: pol1349                                                 #
# OBJETIVO: ALTERAÇÃO DO PREÇO DO ITEM DO PEDIDO DE VENDA           #
# AUTOR...: IVO                                                     #
# DATA....: 27/08/2018                                              #
#-------------------------------------------------------------------#
# Alterações                                                        #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003),
           g_msg           CHAR(150),
           p_nom_arquivo   CHAR(100),
           p_caminho       CHAR(080)
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_panel           VARCHAR(10),
       m_browse          VARCHAR(10)

DEFINE mr_cabec          RECORD
       num_list_preco    DECIMAL(4,0),
       den_list_preco    CHAR(15),
       cod_cliente       CHAR(15),
       nom_cliente       CHAR(36),
       dat_arquivo       DATE,
       arquivo           CHAR(80),
       data_de           DATE,
       data_ate          DATE
END RECORD       

DEFINE m_lista           VARCHAR(10),
       m_zoom_lst        VARCHAR(10),
       m_lupa_lst        VARCHAR(10),
       m_data            VARCHAR(10),
       m_cliente         VARCHAR(10),
       m_zoom_cli        VARCHAR(10),
       m_lupa_cli        VARCHAR(10)
       

DEFINE ma_lista        ARRAY[3000] OF RECORD
       num_list_preco  LIKE desc_preco_item.num_list_preco,
       cod_cliente     LIKE clientes.cod_cliente,  
       nom_cliente     LIKE clientes.nom_cliente,
       cod_item        LIKE item.cod_item,    
       den_item        LIKE item.den_item,    
       pre_unit        LIKE desc_preco_item.pre_unit, 
       mensagem        CHAR(80),
       ies_erro        CHAR(01)
END RECORD

DEFINE m_msg           CHAR(150),
       m_carregando    SMALLINT,
       m_ies_info      SMALLINT,
       m_count         INTEGER,
       m_registro      CHAR(100),
       m_pos_ini       INTEGER,
       m_pos_fim       INTEGER,
       m_num_lista     INTEGER,
       m_cod_cliente   CHAR(15),
       m_cod_item      CHAR(15),
       m_val_item      DECIMAL(12,5),
       m_nom_arquivo   CHAR(30),
       m_index         INTEGER,
       m_dat_atu       DATE,
       m_qtd_erro      INTEGER,
       m_num_transac   INTEGER,
       m_dat_de        CHAR(10),
       m_dat_ate       CHAR(10)
       
DEFINE m_preco_minimo  LIKE vdp_pre_it_audit.preco_minimo

#-----------------#
FUNCTION pol1349()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1349-12.00.05  "
   CALL func002_versao_prg(p_versao)
   CALL pol1349_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1349_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_proces      VARCHAR(10), 
           l_auditoria   VARCHAR(10), 
           l_titulo      CHAR(50)
    
    LET l_titulo = "ALTERAÇÃO DO PREÇO DO ITEM DO PEDIDO DE VEND"
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1349_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1349_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1349_cancelar")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Processa a alteração de preço")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1349_processar")

    LET l_auditoria = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_auditoria,"IMAGE","AUDITORIA") 
    CALL _ADVPL_set_property(l_auditoria,"TOOLTIP","Consulta auditoria de trocas")
    CALL _ADVPL_set_property(l_auditoria,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(l_auditoria,"EVENT","pol1349_auditoria")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1349_cria_campos(l_panel)
   CALL pol1349_cria_grade(l_panel)
   CALL pol1349_limpa_campos()   

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1349_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_desc            VARCHAR(10),
           l_label           VARCHAR(10),
           l_arq             VARCHAR(10)

    LET m_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_panel,"HEIGHT",70)
    CALL _ADVPL_set_property(m_panel,"EDITABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,15)     
    CALL _ADVPL_set_property(l_label,"TEXT","Lista:")    
    #CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_lista = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_lista,"POSITION",45,15)     
    CALL _ADVPL_set_property(m_lista,"LENGTH",4,0)
    CALL _ADVPL_set_property(m_lista,"PICTURE","@E ####")
    CALL _ADVPL_set_property(m_lista,"VARIABLE",mr_cabec,"num_list_preco")
    CALL _ADVPL_set_property(m_lista,"VALID","pol1349_valid_lista")

    LET m_lupa_lst = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_lst,"POSITION",87,15)     
    CALL _ADVPL_set_property(m_lupa_lst,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_lst,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_lst,"CLICK_EVENT","pol1349_zoom_lista")

    LET l_desc = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_desc,"POSITION",115,15)     
    CALL _ADVPL_set_property(l_desc,"PICTURE","@!")
    CALL _ADVPL_set_property(l_desc,"LENGTH",15) 
    CALL _ADVPL_set_property(l_desc,"VARIABLE",mr_cabec,"den_list_preco")
    CALL _ADVPL_set_property(l_desc,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_desc,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",255,15)     
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    
    #CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(m_cliente,"POSITION",305,15)     
    CALL _ADVPL_set_property(m_cliente,"LENGTH",15,0)
    CALL _ADVPL_set_property(m_cliente,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cliente,"VARIABLE",mr_cabec,"cod_cliente")
    CALL _ADVPL_set_property(m_cliente,"VALID","pol1349_valid_cliente")

    LET m_lupa_cli = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_cli,"POSITION",435,15)     
    CALL _ADVPL_set_property(m_lupa_cli,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cli,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cli,"CLICK_EVENT","pol1349_zoom_cliente")

    LET l_desc = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_desc,"POSITION",460,15)     
    CALL _ADVPL_set_property(l_desc,"PICTURE","@!")
    CALL _ADVPL_set_property(l_desc,"LENGTH",36) 
    CALL _ADVPL_set_property(l_desc,"VARIABLE",mr_cabec,"nom_cliente")
    CALL _ADVPL_set_property(l_desc,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_desc,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",800,15)     
    CALL _ADVPL_set_property(l_label,"TEXT","Pedidos com entrega de:")    

    LET m_dat_de = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel)
    CALL _ADVPL_set_property(m_dat_de,"POSITION",950,15)     
    CALL _ADVPL_set_property(m_dat_de,"VARIABLE",mr_cabec,"data_de")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1060,15)     
    CALL _ADVPL_set_property(l_label,"TEXT","Até:")    

    LET m_dat_ate = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel)
    CALL _ADVPL_set_property(m_dat_ate,"POSITION",1090,15)     
    CALL _ADVPL_set_property(m_dat_ate,"VARIABLE",mr_cabec,"data_ate")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,45)     
    CALL _ADVPL_set_property(l_label,"TEXT","Data do arquivo:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_data = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel)
    CALL _ADVPL_set_property(m_data,"POSITION",110,45)     
    CALL _ADVPL_set_property(m_data,"VARIABLE",mr_cabec,"dat_arquivo")
    CALL _ADVPL_set_property(m_data,"VALID","pol1349_valid_data")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",225,45)     
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    

    LET l_arq = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_arq,"POSITION",270,45)     
    CALL _ADVPL_set_property(l_arq,"PICTURE","@!")
    CALL _ADVPL_set_property(l_arq,"LENGTH",80) 
    CALL _ADVPL_set_property(l_arq,"VARIABLE",mr_cabec,"arquivo")
    CALL _ADVPL_set_property(l_arq,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_arq,"CAN_GOT_FOCUS",FALSE)


END FUNCTION

#---------------------------------------#
FUNCTION pol1349_cria_grade(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(m_browse,"AFTER_ROW_EVENT","alb001_limpa_status")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Lista")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_list_preco")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ####")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cliente")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_cliente")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Produto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Preço unit")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pre_unit")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    #CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_lista,1)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)


END FUNCTION

#----------------------------#
FUNCTION pol1349_zoom_lista()#
#----------------------------#
    
   DEFINE l_codigo      CHAR(15),
          l_filtro      CHAR(300)

   IF m_zoom_lst IS NULL THEN
      LET m_zoom_lst = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_zoom_lst,"ZOOM","zoom_desc_preco_mest")
   END IF

   LET l_filtro = " desc_preco_mest.cod_empresa = '",p_cod_empresa CLIPPED,"' "
   CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_zoom_lst,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_zoom_lst,"RETURN_BY_TABLE_COLUMN","desc_preco_mest","num_list_preco")
   
   IF l_codigo IS NOT NULL THEN
      LET mr_cabec.num_list_preco = l_codigo
      LET p_status = pol1349_le_lista()
   END IF
   
   CALL _ADVPL_set_property(m_lista,"GET_FOCUS")
   
END FUNCTION

#-----------------------------#
FUNCTION pol1349_valid_lista()#
#-----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_cabec.num_list_preco IS NOT NULL THEN
      IF NOT pol1349_le_lista() THEN
         RETURN FALSE
      END IF
      #CALL pol1349_enibe_cliente(FALSE)
   ELSE
      LET mr_cabec.den_list_preco = NULL
      #CALL pol1349_enibe_cliente(TRUE)
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1349_le_lista()#
#--------------------------#

   SELECT den_list_preco
     INTO mr_cabec.den_list_preco
     FROM desc_preco_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_list_preco = mr_cabec.num_list_preco
      AND m_dat_atu BETWEEN dat_ini_vig AND dat_fim_vig
   
   IF STATUS = 100 THEN
      LET m_msg = 'Lista inexistente ou fora de vigência.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','desc_preco_mest')
         RETURN FALSE            
      END IF 
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1349_enibe_lista(l_status)#
#-------------------------------------#

   DEFINE l_status   SMALLINT
   
   CALL _ADVPL_set_property(m_lista,"EDITABLE",l_status) 
   CALL _ADVPL_set_property(m_lupa_lst,"EDITABLE",l_status) 
   LET mr_cabec.num_list_preco = NULL
   LET mr_cabec.den_list_preco = NULL

END FUNCTION

#---------------------------------------#
FUNCTION pol1349_enibe_cliente(l_status)#
#---------------------------------------#

   DEFINE l_status   SMALLINT
   
   CALL _ADVPL_set_property(m_cliente,"EDITABLE",l_status) 
   CALL _ADVPL_set_property(m_lupa_cli,"EDITABLE",l_status) 
   LET mr_cabec.cod_cliente = NULL
   LET mr_cabec.nom_cliente = NULL

END FUNCTION

#------------------------------#
FUNCTION pol1349_zoom_cliente()#
#------------------------------#
    
   DEFINE l_codigo      CHAR(15),
          l_filtro      CHAR(300)

   IF m_zoom_cli IS NULL THEN
      LET m_zoom_cli = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_zoom_cli,"ZOOM","zoom_clientes")
   END IF

   CALL _ADVPL_get_property(m_zoom_cli,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_zoom_cli,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
   
   IF l_codigo IS NOT NULL THEN
      LET mr_cabec.cod_cliente = l_codigo
      LET p_status = pol1349_le_cliente()
   END IF
   
   CALL _ADVPL_set_property(m_cliente,"GET_FOCUS")
   
END FUNCTION

#-------------------------------#
FUNCTION pol1349_valid_cliente()#
#-------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_cabec.cod_cliente IS NOT NULL THEN
      IF NOT pol1349_le_cliente() THEN
         RETURN FALSE
      END IF
      #CALL pol1349_enibe_lista(FALSE)
   ELSE
      LET mr_cabec.nom_cliente = NULL   
      #CALL pol1349_enibe_lista(TRUE)
   END IF
   
   RETURN TRUE
   
END FUNCTION


#----------------------------#
FUNCTION pol1349_le_cliente()#
#----------------------------#

   LET mr_cabec.nom_cliente = ''
   
   SELECT nom_cliente
     INTO mr_cabec.nom_cliente
     FROM clientes
    WHERE cod_cliente = mr_cabec.cod_cliente
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','clientes')
      RETURN FALSE            
   END IF 
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1349_valid_data()#
#----------------------------#
   
   DEFINE l_data        CHAR(10),
          l_lista       CHAR(15)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET l_data = EXTEND(mr_cabec.dat_arquivo, YEAR TO DAY)
   
   IF l_data IS NULL or l_data[1,4] < '2000' THEN
      LET m_msg = 'Informe a data do arquivo.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_data,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   IF  mr_cabec.num_list_preco IS NULL OR
          LENGTH( mr_cabec.num_list_preco) <= 0  THEN
      LET l_lista = mr_cabec.cod_cliente CLIPPED 
   ELSE
      LET l_lista = mr_cabec.num_list_preco USING '<<<<'   
   END IF
      
   LET mr_cabec.arquivo = 'LISTA-',l_lista CLIPPED,'-',l_data,'.CSV'
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1349_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_lista TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")

END FUNCTION

#----------------------------------------#
FUNCTION pol1349_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT

   CALL _ADVPL_set_property(m_panel,"EDITABLE",l_status) 

   #CALL _ADVPL_set_property(m_lista,"EDITABLE",l_status) 
   #CALL _ADVPL_set_property(m_lupa_lst,"EDITABLE",l_status) 
   #CALL _ADVPL_set_property(m_cliente,"EDITABLE",l_status) 
   #CALL _ADVPL_set_property(m_lupa_cli,"EDITABLE",l_status) 
   
END FUNCTION


#--------------------------#
FUNCTION pol1349_informar()#
#--------------------------#
   
   LET m_dat_atu = TODAY

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT pol1349_cria_temp() THEN
      RETURN FALSE
   END IF

   IF NOT pol1349_le_caminho() THEN
      RETURN FALSE
   END IF

   CALL pol1349_limpa_campos()   
   CALL pol1349_ativa_desativa(TRUE)
   #LET mr_cabec.dat_arquivo = TODAY
   CALL _ADVPL_set_property(m_lista,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION
#--------------------------#
FUNCTION pol1349_cancelar()#
#--------------------------#

   CALL pol1349_limpa_campos()   
   CALL pol1349_ativa_desativa(FALSE)
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1349_cria_temp()
#---------------------------#

   DROP TABLE arq_temp_304
   
   CREATE  TABLE arq_temp_304(
		registro CHAR(100)
   );

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIACAO","arq_temp_304:criando")
			RETURN FALSE
	 END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1349_le_caminho()
#---------------------------#

   SELECT nom_caminho
     INTO p_caminho
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "CSV"
     AND ies_ambiente = 'W'

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema CSV não cadastrado na LOG1100.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo","path_logix_v2")
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1349_confirmar()#
#---------------------------#
   
   IF NOT pol1349_valid_data() THEN
      RETURN FALSE
   END IF

   IF NOT pol1349_valid_periodo() THEN
      RETURN FALSE
   END IF      
   
   IF mr_cabec.num_list_preco IS NULL AND
      mr_cabec.cod_cliente IS NULL THEN
      LET m_msg = 'Informe a lista ou o cliente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   LET m_nom_arquivo = mr_cabec.arquivo 
   LET mr_cabec.arquivo = p_caminho CLIPPED, mr_cabec.arquivo CLIPPED
   LET m_carregando = TRUE
   
   SELECT COUNT(cod_empresa) INTO m_count
    FROM troca_preco_304
   WHERE cod_empresa = p_cod_empresa
     AND nom_arquivo = m_nom_arquivo
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','troca_preco_304')
      RETURN FALSE
   END IF
   
   IF m_count > 0 THEN
      LET m_msg = "Esse arquivo já foi processado.\n",
                  "Deseja reprocessá-lo ?"
      IF NOT LOG_question(m_msg) THEN
         RETURN FALSE
      END IF
   END IF   
   
   LET p_status = pol1349_carrega_arq()
   
   IF p_status THEN
      CALL pol1349_ativa_desativa(FALSE)    
      LET m_ies_info = TRUE
      LET m_carregando = FALSE
   END IF
   
   RETURN p_status
    
END FUNCTION

#-------------------------------#
FUNCTION pol1349_valid_periodo()#
#-------------------------------#
   
   IF mr_cabec.data_de IS NOT NULL AND
         mr_cabec.data_ate IS NOT NULL THEN
      IF mr_cabec.data_ate <  mr_cabec.data_de THEN
         LET m_msg = 'Período de entrega inválido'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         CALL _ADVPL_set_property(m_dat_de,"GET_FOCUS")
         RETURN FALSE
      END IF
   END IF
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
         
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1349_carrega_arq()#
#-----------------------------#

   LOAD FROM mr_cabec.arquivo INSERT INTO arq_temp_304

   IF STATUS <> 0 AND STATUS <> -805 THEN 
      CALL log003_err_sql("LOAD","arq_banco.txt")
      RETURN FALSE
   END IF
   
   IF STATUS = -805 THEN
      LET m_msg = "Arquivo ",m_nom_arquivo CLIPPED,
       " nao encontrado no caminho ", p_caminho
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   SELECT COUNT(*) INTO m_count FROM arq_temp_304
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','arq_temp_304')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'O arquivo ',mr_cabec.arquivo CLIPPED, ' não contém registros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
           
   CALL log085_transacao("BEGIN")

   LET p_status = LOG_progresspopup_start("Carregango lista...","pol1349_le_temp","PROCESS") 

   IF NOT p_status THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1349_le_temp()#
#-------------------------#

   DEFINE l_progres         SMALLINT

   CALL LOG_progresspopup_set_total("PROCESS",m_count)          
   LET m_index = 1
   LET m_qtd_erro = 0
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   
   DECLARE cq_temp CURSOR FOR
    SELECT registro FROM arq_temp_304
    
   FOREACH cq_temp INTO m_registro

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','arq_temp_304:cq_temp')
         RETURN FALSE
      END IF

      LET m_pos_ini = 1
      LET ma_lista[m_index].num_list_preco = pol1349_divide_texto()
      LET ma_lista[m_index].cod_cliente = pol1349_divide_texto()

      IF mr_cabec.num_list_preco IS NOT NULL THEN
         IF ma_lista[m_index].num_list_preco <> mr_cabec.num_list_preco THEN
            LET ma_lista[m_index].num_list_preco = NULL
            LET ma_lista[m_index].cod_cliente = NULL
            CONTINUE FOREACH
         END IF
      END IF
      
      IF mr_cabec.cod_cliente IS NOT NULL THEN
         IF ma_lista[m_index].cod_cliente <> mr_cabec.cod_cliente THEN
            LET ma_lista[m_index].num_list_preco = NULL
            LET ma_lista[m_index].cod_cliente = NULL
            CONTINUE FOREACH
         END IF
         IF mr_cabec.num_list_preco IS NULL THEN
            CALL pol1349_pega_lista_cli(ma_lista[m_index].cod_cliente)
            LET ma_lista[m_index].num_list_preco = m_num_lista
         END IF
      END IF
      
      LET ma_lista[m_index].cod_item = pol1349_divide_texto()
      LET ma_lista[m_index].pre_unit = m_registro[m_pos_ini,LENGTH(m_registro)]
      
      LET ma_lista[m_index].den_item = func002_le_den_item(ma_lista[m_index].cod_item) 
      LET ma_lista[m_index].nom_cliente = func002_le_nom_cliente(ma_lista[m_index].cod_cliente) 
      
      LET m_msg = ''
      LET m_num_lista = ma_lista[m_index].num_list_preco
      
      IF NOT pol1349_checa_lista() THEN
         RETURN FALSE
      END IF
      
      LET ma_lista[m_index].mensagem = m_msg
      
      IF m_msg IS NOT NULL THEN
         CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_index,180,14,22)
         LET m_qtd_erro = m_qtd_erro + 1
         LET ma_lista[m_index].ies_erro = 'S'
      ELSE
         CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_index,0,0,0)
         LET ma_lista[m_index].ies_erro = 'N'
      END IF
      
      LET m_index = m_index + 1
      LET l_progres = LOG_progresspopup_increment("PROCESS")   
      
      
   END FOREACH
   
   LET m_count = m_index - 1
   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_count)

   IF m_count = 0 THEN
      LET m_msg = 'O arquivo ',mr_cabec.arquivo CLIPPED, 
        ' não contém registros, para os parâmetros informados.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1349_divide_texto()#
#------------------------------#
   
   DEFINE l_ind        INTEGER,
          l_conteudo   CHAR(20)
          
   FOR l_ind = m_pos_ini TO LENGTH(m_registro)
       IF m_registro[l_ind] = ';' THEN
          LET m_pos_fim = l_ind - 1
          EXIT FOR
       END IF
   END FOR
   
   LET l_conteudo = m_registro[m_pos_ini, m_pos_fim]
   LET m_pos_ini = m_pos_fim + 2
   
   RETURN l_conteudo

END FUNCTION

#---------------------------------------------#
FUNCTION pol1349_pega_lista_cli(l_cod_cliente)#
#---------------------------------------------#
   
   DEFINE l_cod_cliente      CHAR(15)
   
   LET m_num_lista = 0
   
   DECLARE cq_num_list CURSOR FOR
    SELECT DISTINCT i.num_list_preco
     FROM desc_preco_item i, desc_preco_mest d
    WHERE i.cod_empresa = p_cod_empresa
      AND i.cod_cliente = l_cod_cliente
      AND d.cod_empresa = i.cod_empresa
      AND d.num_list_preco = i.num_list_preco
      AND m_dat_atu BETWEEN d.dat_ini_vig AND d.dat_fim_vig
   
   FOREACH cq_num_list INTO m_num_lista
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cq_num_list')
         LET m_num_lista = 0            
      END IF 
      
      EXIT FOREACH

   END FOREACH

END FUNCTION      
      
#-----------------------------#
FUNCTION pol1349_checa_lista()#
#-----------------------------#

   IF m_num_lista = 0 THEN
      LET m_msg = m_msg CLIPPED, 'Lista inválida;'
   ELSE
      SELECT den_list_preco
        FROM desc_preco_mest
       WHERE cod_empresa = p_cod_empresa
         AND num_list_preco = m_num_lista
         AND m_dat_atu BETWEEN dat_ini_vig AND dat_fim_vig
      IF STATUS = 100 THEN
         LET m_msg = m_msg CLIPPED,'Lista inexistente ou fora de vigência;'
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','desc_preco_mest')
            RETURN FALSE            
         END IF 
         IF NOT pol1349_checa_item() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
   
   IF ma_lista[m_index].pre_unit = 0 THEN
      LET m_msg = m_msg CLIPPED, 'Preço inválido;'
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1349_checa_item()#
#----------------------------#
   
   DEFINE l_ies_situacao    CHAR(01)
   
   SELECT 1
     FROM desc_preco_item
    WHERE cod_empresa = p_cod_empresa
      AND num_list_preco = m_num_lista
      AND cod_cliente = ma_lista[m_index].cod_cliente
      AND cod_item = ma_lista[m_index].cod_item

   IF STATUS = 100 THEN
      LET m_msg = m_msg CLIPPED,'Cliente ou item inexistente na lista;'
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','desc_preco_item')
         RETURN FALSE            
      END IF 
   END IF
   
   SELECT ies_situacao INTO l_ies_situacao
    FROM item WHERE cod_empresa = p_cod_empresa
    AND cod_item =  ma_lista[m_index].cod_item

   IF STATUS = 100 THEN
      LET m_msg = m_msg CLIPPED,'Item inexistente no MAN10021;'
   ELSE   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item')
         RETURN FALSE            
      END IF
   END IF 

   {IF l_ies_situacao = 'A' THEN #06/03/19 - Adriano pediu para não fazer essa verificação
   ELSE
      LET m_msg = m_msg CLIPPED,'Item inativo;'
   END IF}
   
   RETURN TRUE

END FUNCTION
 
#---------------------------#     
FUNCTION pol1349_processar()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
      
   IF NOT m_ies_info THEN
      LET m_msg = 'Informe os parâmetros previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF m_qtd_erro > 0 THEN
      LET m_msg = 'Esse arquivo comtém ',m_qtd_erro USING '<<<<<', '\n',
                  'item(ns) com erro(s).\n','Processá-lo mesmo assim?.'
                  
      IF NOT LOG_question(m_msg) THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Operação cancelada.")
         RETURN FALSE
      END IF
   END IF

   CALL log085_transacao("BEGIN")

   LET p_status = LOG_progresspopup_start("Processando lista...","pol1349_proc_lista","PROCESS") 

   LET m_ies_info = FALSE
   
   IF NOT p_status THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   LET m_msg = 'Processamento efetuado com sucesso.'
   CALL log0030_mensagem(m_msg, 'info')
   
   CALL log085_transacao("COMMIT")

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1349_proc_lista()#
#----------------------------#

   DEFINE l_progres         SMALLINT,
          l_qtd_reg         INTEGER
   
   LET l_qtd_reg = m_count - m_qtd_erro
      
   CALL LOG_progresspopup_set_total("PROCESS",l_qtd_reg)    
         
   FOR m_index = 1 TO m_count 
      IF ma_lista[m_index].ies_erro = 'N' THEN
         IF NOT pol1339_troca_preco() THEN
            RETURN FALSE
         END IF
      END IF
      LET l_progres = LOG_progresspopup_increment("PROCESS") 
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1339_troca_preco()#
#-----------------------------#

   IF NOT pol1349_alt_ped_item() THEN
      RETURN FALSE
   END IF

   IF NOT pol1349_ins_audit() THEN
      RETURN FALSE
   END IF

   UPDATE desc_preco_item 
      SET pre_unit = ma_lista[m_index].pre_unit
    WHERE cod_empresa = p_cod_empresa
      AND num_list_preco = ma_lista[m_index].num_list_preco
      AND cod_cliente = ma_lista[m_index].cod_cliente
      AND cod_item = ma_lista[m_index].cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','desc_preco_item')
      RETURN FALSE            
   END IF 

   IF NOT pol1349_ins_proces() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1349_alt_ped_item()#
#------------------------------#
   
   DEFINE l_query      CHAR(1000),
          l_num_pedido LIKE ped_itens.num_pedido, 
          l_num_seq    LIKE ped_itens.num_sequencia
   
   LET l_query = 
    " SELECT i.num_pedido, i.num_sequencia ",
    " FROM  ped_itens i, pedidos p  ",
    "WHERE p.cod_empresa = '",p_cod_empresa,"' ",
    "  AND p.num_list_preco = '",ma_lista[m_index].num_list_preco,"' ",
    "  AND p.cod_cliente = '",ma_lista[m_index].cod_cliente,"' ",
    "  AND i.cod_empresa =  p.cod_empresa ",
    "  AND i.num_pedido = p.num_pedido ",
    "  AND i.cod_item = '",ma_lista[m_index].cod_item,"' ",
    "  AND i.qtd_pecas_cancel < i.qtd_pecas_solic ",
    "  AND (i.qtd_pecas_solic - i.qtd_pecas_atend - i.qtd_pecas_cancel) >= 0 "
    
    IF mr_cabec.data_de IS NOT NULL THEN
       LET l_query = l_query CLIPPED, " AND i.prz_entrega >= '",mr_cabec.data_de,"' "
    END IF

    IF mr_cabec.data_ate IS NOT NULL THEN
       LET l_query = l_query CLIPPED, " AND i.prz_entrega <= '",mr_cabec.data_ate,"' "
    END IF
                        

   PREPARE var_query FROM l_query
    
   IF Status <> 0 THEN
      CALL log003_err_sql("PREPARE SQL","var_query")
      RETURN FALSE
   END IF

   DECLARE cq_query CURSOR FOR var_query

   IF Status <> 0 THEN
      CALL log003_err_sql("DECLARE CURSOR","cq_query")
      RETURN FALSE
   END IF

   FREE var_query

   FOREACH cq_query INTO l_num_pedido, l_num_seq

      IF Status <> 0 THEN
         CALL log003_err_sql("DECLARE CURSOR","FOREACH:cq_query")
         RETURN FALSE
      END IF
      
      UPDATE ped_itens SET pre_unit = ma_lista[m_index].pre_unit
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = l_num_pedido
         AND num_sequencia = l_num_seq

      IF Status <> 0 THEN
         CALL log003_err_sql("UPDATE","ped_itens")
         RETURN FALSE
      END IF
         
   END FOREACH

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1349_ins_audit()#
#---------------------------#

   DEFINE lr_vdp_pre     RECORD LIKE vdp_pre_it_audit.*,
          lr_desc_item   RECORD LIKE desc_preco_item.*,
          l_texto        LIKE audit_vdp.texto,
          l_hora         CHAR(08)
   
   SELECT * INTO lr_desc_item.*
     FROM desc_preco_item
    WHERE cod_empresa = p_cod_empresa
      AND num_list_preco = m_num_lista
      AND cod_cliente = ma_lista[m_index].cod_cliente
      AND cod_item = ma_lista[m_index].cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','desc_preco_item')
      RETURN FALSE            
   END IF
   
   IF lr_desc_item.cod_uni_feder IS NULL THEN
      SELECT parametro_qtd 
        INTO m_preco_minimo
        FROM vdp_pre_item_compl  
       WHERE empresa = p_cod_empresa
         AND lista_preco = m_num_lista
         AND (vdp_pre_item_compl.estado IS NULL OR vdp_pre_item_compl.estado = ' ') 
         AND vdp_pre_item_compl.cliente = lr_desc_item.cod_cliente
         AND vdp_pre_item_compl.linha_produto  = lr_desc_item.cod_lin_prod
         AND vdp_pre_item_compl.linha_receita  = lr_desc_item.cod_lin_recei
         AND vdp_pre_item_compl.segmto_mercado = lr_desc_item.cod_seg_merc
         AND vdp_pre_item_compl.classe_uso     = lr_desc_item.cod_cla_uso
         AND vdp_pre_item_compl.item = lr_desc_item.cod_item
         AND vdp_pre_item_compl.campo = 'PRECO MINIMO'
   ELSE
      SELECT parametro_qtd 
        INTO m_preco_minimo
        FROM vdp_pre_item_compl  
       WHERE empresa = p_cod_empresa
         AND lista_preco = m_num_lista
         AND vdp_pre_item_compl.estado = lr_desc_item.cod_uni_feder
         AND vdp_pre_item_compl.cliente = lr_desc_item.cod_cliente
         AND vdp_pre_item_compl.linha_produto  = lr_desc_item.cod_lin_prod
         AND vdp_pre_item_compl.linha_receita  = lr_desc_item.cod_lin_recei
         AND vdp_pre_item_compl.segmto_mercado = lr_desc_item.cod_seg_merc
         AND vdp_pre_item_compl.classe_uso     = lr_desc_item.cod_cla_uso
         AND vdp_pre_item_compl.item = lr_desc_item.cod_item
         AND vdp_pre_item_compl.campo = 'PRECO MINIMO'
   END IF
   
   IF STATUS = 100 THEN
      LET m_preco_minimo = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','vdp_pre_item_compl')
         RETURN FALSE
      END IF
   END IF
   
   IF m_preco_minimo IS NULL THEN
      LET m_preco_minimo = 0
   END IF
   
   LET lr_vdp_pre.empresa           = lr_desc_item.cod_empresa
   LET lr_vdp_pre.lista_preco       = lr_desc_item.num_list_preco
   LET lr_vdp_pre.estado            = lr_desc_item.cod_uni_feder
   LET lr_vdp_pre.cliente           = lr_desc_item.cod_cliente
   LET lr_vdp_pre.linha_produto     = lr_desc_item.cod_lin_prod 
   LET lr_vdp_pre.linha_receita     = lr_desc_item.cod_lin_recei
   LET lr_vdp_pre.segmento_mercado  = lr_desc_item.cod_seg_merc 
   LET lr_vdp_pre.classe_uso        = lr_desc_item.cod_cla_uso  
   LET lr_vdp_pre.item              = lr_desc_item.cod_item
   LET lr_vdp_pre.preco_unitario    = lr_desc_item.pre_unit
   LET lr_vdp_pre.desc_lista_preco  = pol1349_le_desc_list()
   LET lr_vdp_pre.desc_adic_lpre    = lr_desc_item.pct_desc_adic
   LET lr_vdp_pre.grupo             = lr_desc_item.cod_grupo
   LET lr_vdp_pre.acabamento        = lr_desc_item.cod_acabam
   LET lr_vdp_pre.condicao_pagto    = lr_desc_item.cod_cnd_pgto
   LET lr_vdp_pre.pre_unit_adicional = lr_desc_item.pre_unit_adic
   LET lr_vdp_pre.pre_unit_anterior = lr_desc_item.pre_unit_ant
   LET lr_vdp_pre.pre_unit_adic_ant = lr_desc_item.pre_unit_adic_ant
   LET lr_vdp_pre.preco_minimo      = m_preco_minimo
   LET lr_vdp_pre.transacao         = 0
   LET lr_vdp_pre.dat_auditoria     = m_dat_atu
   LET lr_vdp_pre.usuario           = p_user

   INSERT INTO vdp_pre_it_audit VALUES(lr_vdp_pre.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','vdp_pre_it_audit')
      RETURN FALSE
   END IF

   LET m_num_transac = SQLCA.SQLERRD[2]

   INSERT INTO vdp_audit_lpre (
     empresa,  lista_preco,  unid_federal,  
     cliente,  linha_produto, linha_receita, 
     segmto_mercado, classe_uso, item, preco_unit, 
     pct_desc, pct_desc_adicional, grupo, acabamto, 
     cond_pagto, pre_unit_adicional, preco_unit_ant, 
     pre_uni_adic_ant, usuario, dat_alteracao, programa) 
   VALUES(lr_desc_item.cod_empresa, lr_desc_item.num_list_preco, lr_desc_item.cod_uni_feder,
          lr_desc_item.cod_cliente, lr_desc_item.cod_lin_prod, lr_desc_item.cod_lin_recei,
          lr_desc_item.cod_seg_merc, lr_desc_item.cod_cla_uso, lr_desc_item.cod_item,
          lr_desc_item.pre_unit, lr_desc_item.pct_desc, lr_desc_item.pct_desc_adic,
          lr_desc_item.cod_grupo, lr_desc_item.cod_acabam, lr_desc_item.cod_cnd_pgto,
          lr_desc_item.pre_unit_adic, lr_desc_item.pre_unit_ant, lr_desc_item.pre_unit_adic_ant,
          p_user, m_dat_atu, 'POL1349')    

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','vdp_audit_lpre')
      RETURN FALSE
   END IF
   
   LET l_texto = 'Alterado Preco Unitario da lista de preco ', m_num_lista USING '<<<<',
                 ' de ', lr_desc_item.pre_unit USING '<<<<<.<<<<<<', ' para ',
                 ma_lista[m_index].pre_unit USING '<<<<<.<<<<<<',
                 ' Cliente: ', lr_desc_item.cod_cliente CLIPPED,
                 ' Item: ', lr_desc_item.cod_item CLIPPED

   LET l_hora = TIME
   
   INSERT INTO audit_vdp (
      cod_empresa, num_pedido, tipo_informacao, tipo_movto, 
      texto, num_programa, data, hora, usuario) 
   VALUES(lr_desc_item.cod_empresa, 0, 'I', 'A', 
          l_texto, 'POL1349', m_dat_atu, l_hora, p_user)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','audit_vdp')
      RETURN FALSE
   END IF          
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1349_le_desc_list()#
#------------------------------#
   
   DEFINE l_desc     LIKE desc_preco_mest.den_list_preco
   
   SELECT den_list_preco
     INTO l_desc
     FROM desc_preco_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_list_preco = m_num_lista
      AND m_dat_atu BETWEEN dat_ini_vig AND dat_fim_vig
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','desc_preco_mest')
   END IF
   
   RETURN l_desc

END FUNCTION   

#----------------------------#
FUNCTION pol1349_ins_proces()#
#----------------------------#

   INSERT INTO troca_preco_304
    VALUES(p_cod_empresa,
           m_num_lista,
           ma_lista[m_index].cod_cliente,
           ma_lista[m_index].cod_item,
           ma_lista[m_index].pre_unit,
           m_dat_atu,
           m_nom_arquivo)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','troca_preco_304')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------FIM DO PROGRAMA---------------#
{
 
CREATE TABLE troca_preco_304 (
 cod_empresa      CHAR(02),
 num_list_preco   DECIMAL(4,0),
 cod_cliente      CHAR(15),
 cod_item         CHAR(15),
 preco_planilha   DECIMAL(14,7),
 dat_proces       DATE,
 nom_arquivo      CHAR(30)
);
 
CREATE INDEX ix1_troca_preco_304 ON
 troca_preco_304(cod_empresa, num_list_preco);
