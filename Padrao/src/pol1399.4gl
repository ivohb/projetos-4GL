#-------------------------------------------------------------------#
# SISTEMA.: LOGIX - CRE                                             #
# PROGRAMA: pol1399                                                 #
# OBJETIVO: PARÂMETROS PARA ENVIO DE COBRANÇA                       #
#           ENVIO DE COBRANÇA PARA TITULOS VENCIDOS                 #
#           ENVIO DE LEMBRETES PARA TITULOS A VENCER                #
# AUTOR...: IVO                                                     #
# DATA....: 03/08/20                                                #
#-------------------------------------------------------------------#
#-------------------------------------------------------------------#
# OBS: Os emails dos clientes devem estar cadastrados no POL1399 ou #
#      no VDP1325                                                   #
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
       m_vencidos_de     VARCHAR(10),
       m_vencidos_ate    VARCHAR(10),
       m_cobranca_de     VARCHAR(10),
       m_cobranca_ate    VARCHAR(10),
       m_lembrete_ate    VARCHAR(10),
       m_tip_envio       VARCHAR(10),
       m_a_vencer        VARCHAR(10),
       m_enviar_cob      VARCHAR(10),
       m_repetir_cob     VARCHAR(10),
       m_rep_cob_apos    VARCHAR(10),
       m_enviar_lemb     VARCHAR(10),
       m_repetir_lemb    VARCHAR(10),
       m_rep_lemb_apos   VARCHAR(10),
       m_emitente        VARCHAR(10),
       m_zoom_emitente   VARCHAR(10),
       m_lupa_emitente   VARCHAR(10),
       m_email1_cliente  VARCHAR(10),
       m_email2_cliente  VARCHAR(10),
       m_email3_cliente  VARCHAR(10),
       m_limite          VARCHAR(10),
       m_obs             VARCHAR(10),
       m_browse          VARCHAR(10),
       m_erro_construct  VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_ies_cobranca    SMALLINT,
       m_ies_lembrete    SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_nome_cliente    CHAR(36),
       m_dat_cobranca    DATE
       
DEFINE mr_param             RECORD
       cod_cliente          VARCHAR(15),  
       nom_cliente          VARCHAR(36),  
       vencidos_de          DECIMAL(3,0), 
       vencidos_ate         DECIMAL(3,0), 
       enviar_cobranca      VARCHAR(01),  
       repetir_cobranca     VARCHAR(01),  
       repetir_cob_apos     DECIMAL(3,0), 
       limite_saldo         DECIMAL(12,2),
       enviar_lembrete      VARCHAR(01),  
       repetir_lembrete     VARCHAR(01),  
       repetir_lemb_apos    DECIMAL(3,0), 
       vencer_ate           DECIMAL(3,0), 
       emitente_email       VARCHAR(08),  
       nom_emitente         VARCHAR(30),  
       grupo_email          DECIMAL(3,0),
       email1_cliente       VARCHAR(50),  
       email2_cliente       VARCHAR(50),  
       email3_cliente       VARCHAR(50),  
       observacao           VARCHAR(120)
END RECORD

DEFINE mr_cobranca       RECORD
       cod_empresa       CHAR(02),
       cod_cliente       CHAR(15),     
       nom_cliente       CHAR(36),        
       vencidos_de       DECIMAL(3,0),  
       vencidos_ate      DECIMAL(3,0),
       enviar_cobranca   VARCHAR(01),
       repetir_cobranca  VARCHAR(01),
       repetir_cob_apos  DECIMAL(3,0),
       limite_saldo      DECIMAL(12,2),
       emitente_email    VARCHAR(08)
END RECORD

DEFINE mr_lembrete       RECORD
       cod_empresa       CHAR(02),
       cod_cliente       CHAR(15),     
       nom_cliente       CHAR(36),   
       enviar_lembrete   CHAR(01),  
       repetir_lembrete  CHAR(01),  
       repetir_lemb_apos DECIMAL(3,0),   
       vencer_ate        DECIMAL(3,0),
       emitente_email    VARCHAR(08)
END RECORD

DEFINE m_panel_aba           VARCHAR(10),
       m_panel_dados         VARCHAR(10),
       m_pnl_parametro       VARCHAR(10),
       m_pnl_cobranca        VARCHAR(10),
       m_pnl_lembrete        VARCHAR(10),
       m_pnl_erro            VARCHAR(10),
       m_aba_parametro       VARCHAR(10),
       m_aba_cobranca        VARCHAR(10),
       m_aba_lembrete        VARCHAR(10),      
       m_aba_erro            VARCHAR(10),      
       m_menu_parametro      VARCHAR(10),
       m_menu_cobranca       VARCHAR(10),
       m_menu_lembrete       VARCHAR(10),
       m_menu_erro           VARCHAR(10),
       m_pnl_cab_param       VARCHAR(10),
       m_pnl_cab_cobr        VARCHAR(10),
       m_pnl_cab_lembre      VARCHAR(10),
       m_pnl_cab_erro        VARCHAR(10),
       m_cli_cobranca        VARCHAR(10),
       m_cli_lembrete        VARCHAR(10),
       m_vencer_ate          VARCHAR(10)

DEFINE ma_erro               ARRAY[1000] OF RECORD    
       cod_empresa           VARCHAR(02), 
       cod_usuario           VARCHAR(08), 
       dat_proces            DATE,        
       hor_proces            VARCHAR(08), 
       mensagem              VARCHAR(150) 
END RECORD
        
#-----------------#
FUNCTION pol1399()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1399-12.00.00  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1399_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1399_menu()#
#----------------------#

    DEFINE l_titulo  VARCHAR(40),
           l_panel   VARCHAR(10)
    
    LET l_titulo  = "ENVIO DE COBRANÇA/LEMBRETES A CLIENTES"

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"FONT",NULL,11,FALSE,TRUE)
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"INIT_EVENT","pol1399_ativa_cor")

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET m_menu_parametro = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_parametro,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_parametro,"VISIBLE",FALSE)

    LET m_menu_cobranca = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_cobranca,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_cobranca,"VISIBLE",FALSE)

    LET m_menu_lembrete = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_lembrete,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_lembrete,"VISIBLE",FALSE)

    LET m_menu_erro = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_erro,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_erro,"VISIBLE",FALSE)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1399_paineis(l_panel)
    CALL pol1399_cria_abas()

    CALL pol1399_menu_parametro()
    CALL pol1399_dados_parametro()

    CALL pol1399_menu_cobranca()
    CALL pol1399_dados_cobranca()

    CALL pol1399_menu_lembrete()
    CALL pol1399_dados_lembrete()

    CALL pol1399_menu_erro()
    CALL pol1399_dados_erro()

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#---------------------------#
FUNCTION pol1399_ativa_cor()#
#---------------------------#

   CALL _ADVPL_set_property(m_aba_parametro,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_cobranca,"FOREGROUND_COLOR",255,0,0)  
   CALL _ADVPL_set_property(m_aba_lembrete,"FOREGROUND_COLOR",255,0,0) 
   CALL _ADVPL_set_property(m_aba_erro,"FOREGROUND_COLOR",255,0,0) 
   
   CALL pol1399_parametro_click()
   
  RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1399_paineis(l_panel)#
#--------------------------------#

    DEFINE l_panel        VARCHAR(10)

    LET m_panel_aba = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel)
    CALL _ADVPL_set_property(m_panel_aba,"ALIGN","LEFT")
    CALL _ADVPL_set_property(m_panel_aba,"WIDTH",210)
    CALL _ADVPL_set_property(m_panel_aba,"FONT",NULL,11,FALSE,TRUE)
    CALL _ADVPL_set_property(m_panel_aba,"BACKGROUND_COLOR",210,210,210)

    LET m_panel_dados = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel)
    CALL _ADVPL_set_property(m_panel_dados,"ALIGN","CENTER")

    LET m_pnl_parametro = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_pnl_parametro,"ALIGN","CENTER")

    LET m_pnl_cobranca = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_pnl_cobranca,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_pnl_cobranca,"VISIBLE",FALSE)

    LET m_pnl_lembrete = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_pnl_lembrete,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_pnl_lembrete,"VISIBLE",FALSE)

    LET m_pnl_erro = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_pnl_erro,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_pnl_erro,"VISIBLE",FALSE)

END FUNCTION

#---------------------------#
FUNCTION pol1399_cria_abas()#
#---------------------------#

    DEFINE l_label      VARCHAR(10),
           l_invent     VARCHAR(10),
           l_diverg     VARCHAR(10),
           l_carga      VARCHAR(10)
        

    LET m_aba_parametro = _ADVPL_create_component(NULL,"LLABEL",m_panel_aba)
    CALL _ADVPL_set_property(m_aba_parametro,"POSITION",10,10)
    CALL _ADVPL_set_property(m_aba_parametro,"TEXT","> Parâmetros")  
    CALL _ADVPL_set_property(m_aba_parametro,"CLICK_EVENT","pol1399_parametro_click")

    LET m_aba_cobranca = _ADVPL_create_component(NULL,"LLABEL",m_panel_aba)
    CALL _ADVPL_set_property(m_aba_cobranca,"POSITION",10,40)
    CALL _ADVPL_set_property(m_aba_cobranca,"TEXT","> Cobranças")  
    CALL _ADVPL_set_property(m_aba_cobranca,"CLICK_EVENT","pol1399_cobranca_click")
     
    LET m_aba_lembrete = _ADVPL_create_component(NULL,"LLABEL",m_panel_aba)
    CALL _ADVPL_set_property(m_aba_lembrete,"POSITION",10,70)
    CALL _ADVPL_set_property(m_aba_lembrete,"TEXT","> Lembretes")  
    CALL _ADVPL_set_property(m_aba_lembrete,"CLICK_EVENT","pol1399_lembrete_click")

    LET m_aba_erro = _ADVPL_create_component(NULL,"LLABEL",m_panel_aba)
    CALL _ADVPL_set_property(m_aba_erro,"POSITION",10,100)
    CALL _ADVPL_set_property(m_aba_erro,"TEXT","> Consulta erro")  
    CALL _ADVPL_set_property(m_aba_erro,"CLICK_EVENT","pol1399_erro_click")

END FUNCTION

#---------------------------------#
FUNCTION pol1399_parametro_click()#
#---------------------------------#
   
   CALL pol1399_desativa_cor()
   CALL _ADVPL_set_property(m_aba_parametro,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_parametro,"FONT",NULL,NULL,TRUE,TRUE)

   CALL pol1399_enib_menu_panel()
   CALL _ADVPL_set_property(m_menu_parametro,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_pnl_parametro,"VISIBLE",TRUE)
   
   RETURN TRUE
       
END FUNCTION

#--------------------------------#
FUNCTION pol1399_cobranca_click()#
#--------------------------------#
   
   CALL pol1399_desativa_cor()
   CALL _ADVPL_set_property(m_aba_cobranca,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_cobranca,"FONT",NULL,NULL,TRUE,TRUE)

   CALL pol1399_enib_menu_panel()
   CALL _ADVPL_set_property(m_menu_cobranca,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_pnl_cobranca,"VISIBLE",TRUE)
   
   RETURN TRUE
       
END FUNCTION

#--------------------------------#
FUNCTION pol1399_lembrete_click()#
#--------------------------------#
   
   CALL pol1399_desativa_cor()
   CALL _ADVPL_set_property(m_aba_lembrete,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_lembrete,"FONT",NULL,NULL,TRUE,TRUE)

   CALL pol1399_enib_menu_panel()
   CALL _ADVPL_set_property(m_menu_lembrete,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_pnl_lembrete,"VISIBLE",TRUE)
   
   RETURN TRUE
       
END FUNCTION

#----------------------------#
FUNCTION pol1399_erro_click()#
#----------------------------#
   
   CALL pol1399_desativa_cor()
   CALL _ADVPL_set_property(m_aba_erro,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_erro,"FONT",NULL,NULL,TRUE,TRUE)

   CALL pol1399_enib_menu_panel()
   CALL _ADVPL_set_property(m_menu_erro,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_pnl_erro,"VISIBLE",TRUE)
   
   RETURN TRUE
       
END FUNCTION

#------------------------------#
FUNCTION pol1399_desativa_cor()#
#------------------------------#

   CALL _ADVPL_set_property(m_aba_parametro,"FOREGROUND_COLOR",0,0,0)
   CALL _ADVPL_set_property(m_aba_parametro,"FONT",NULL,NULL,FALSE,TRUE)
   CALL _ADVPL_set_property(m_aba_cobranca,"FOREGROUND_COLOR",0,0,0)  
   CALL _ADVPL_set_property(m_aba_cobranca,"FONT",NULL,NULL,FALSE,TRUE)
   CALL _ADVPL_set_property(m_aba_lembrete,"FOREGROUND_COLOR",0,0,0)  
   CALL _ADVPL_set_property(m_aba_lembrete,"FONT",NULL,NULL,FALSE,TRUE)
   CALL _ADVPL_set_property(m_aba_erro,"FOREGROUND_COLOR",0,0,0)  
   CALL _ADVPL_set_property(m_aba_erro,"FONT",NULL,NULL,FALSE,TRUE)

END FUNCTION

#---------------------------------#
FUNCTION pol1399_enib_menu_panel()#
#---------------------------------#

   CALL _ADVPL_set_property(m_menu_parametro,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_menu_cobranca,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_menu_lembrete,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_menu_erro,"VISIBLE",FALSE)

   CALL _ADVPL_set_property(m_pnl_parametro,"VISIBLE",FALSE)   
   CALL _ADVPL_set_property(m_pnl_cobranca,"VISIBLE",FALSE)   
   CALL _ADVPL_set_property(m_pnl_lembrete,"VISIBLE",FALSE)   
   CALL _ADVPL_set_property(m_pnl_erro,"VISIBLE",FALSE)   
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

END FUNCTION

#--------------------------------#
FUNCTION pol1399_menu_parametro()#
#--------------------------------#

    DEFINE l_panel,
           l_create,
           l_update,
           l_find,
           l_first,
           l_previous,
           l_next,
           l_last,
           l_delete  VARCHAR(10)
    
    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",m_menu_parametro)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1399_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1399_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1399_create_cancel")

    LET l_update = _ADVPL_create_component(NULL,"LMENUBUTTON",m_menu_parametro)
    CALL _ADVPL_set_property(l_update,"IMAGE","UPDATE_EX") 
    CALL _ADVPL_set_property(l_update,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_update,"TOOLTIP","Modificar dados")
    CALL _ADVPL_set_property(l_update,"EVENT","pol1399_alterar")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1399_ies_alterar")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1399_no_alterar")
    
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",m_menu_parametro)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1399_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",m_menu_parametro)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1399_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",m_menu_parametro)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1399_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",m_menu_parametro)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1399_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",m_menu_parametro)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1399_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",m_menu_parametro)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1399_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_parametro)

END FUNCTION

#---------------------------------#
FUNCTION pol1399_dados_parametro()#
#---------------------------------#

    DEFINE l_panel           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_label           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_pnl_parametro)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",35)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)
    CALL _ADVPL_set_property(l_panel,"EDITABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",350,10)  
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"TEXT","PARÂMETROS DO CLIENTE")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET m_pnl_cab_param = _ADVPL_create_component(NULL,"LPANEL",m_pnl_parametro)
    CALL _ADVPL_set_property(m_pnl_cab_param,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_pnl_cab_param,"ENABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    

    LET m_cod_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_cod_cliente,"POSITION",70,10)  
    CALL _ADVPL_set_property(m_cod_cliente,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_cliente,"VARIABLE",mr_param,"cod_cliente")
    CALL _ADVPL_set_property(m_cod_cliente,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_cliente,"VALID","pol1399_valida_cliente")

    LET m_lupa_cliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_lupa_cliente,"POSITION",200,10)  
    CALL _ADVPL_set_property(m_lupa_cliente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cliente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cliente,"CLICK_EVENT","pol1399_zoom_cliente")

    LET m_nom_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_nom_cliente,"POSITION",235,10)  
    CALL _ADVPL_set_property(m_nom_cliente,"LENGTH",50) 
    CALL _ADVPL_set_property(m_nom_cliente,"ENABLE",FALSE) 
    CALL _ADVPL_set_property(m_nom_cliente,"VARIABLE",mr_param,"nom_cliente")
    CALL _ADVPL_set_property(m_nom_cliente,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",10,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Vencidos de:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_vencidos_de = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_vencidos_de,"POSITION",90,40)  
    CALL _ADVPL_set_property(m_vencidos_de,"LENGTH",5)
    CALL _ADVPL_set_property(m_vencidos_de,"VARIABLE",mr_param,"vencidos_de")
    CALL _ADVPL_set_property(m_vencidos_de,"PICTURE","@E ###")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",160,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Até:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_vencidos_ate = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_vencidos_ate,"POSITION",200,40)  
    CALL _ADVPL_set_property(m_vencidos_ate,"LENGTH",5)
    CALL _ADVPL_set_property(m_vencidos_ate,"VARIABLE",mr_param,"vencidos_ate")
    CALL _ADVPL_set_property(m_vencidos_ate,"PICTURE","@E ###")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",260,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","dias")    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",10,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","Enviar cobrança:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_enviar_cob = _ADVPL_create_component(NULL,"LCHECKBOX",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_enviar_cob,"POSITION",100,70)  
    CALL _ADVPL_set_property(m_enviar_cob,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_enviar_cob,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_enviar_cob,"VARIABLE",mr_param,"enviar_cobranca")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",140,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","Repetir cobrança:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_repetir_cob = _ADVPL_create_component(NULL,"LCHECKBOX",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_repetir_cob,"POSITION",240,70)  
    CALL _ADVPL_set_property(m_repetir_cob,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_repetir_cob,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_repetir_cob,"VARIABLE",mr_param,"repetir_cobranca")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",280,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","Repetir após:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_rep_cob_apos = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_rep_cob_apos,"POSITION",360,70)  
    CALL _ADVPL_set_property(m_rep_cob_apos,"LENGTH",5)
    CALL _ADVPL_set_property(m_rep_cob_apos,"VARIABLE",mr_param,"repetir_cob_apos")
    CALL _ADVPL_set_property(m_rep_cob_apos,"PICTURE","@E ###")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",410,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","dias")    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",460,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","Saldo a partir de:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_limite = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_limite,"POSITION",560,70)  
    CALL _ADVPL_set_property(m_limite,"LENGTH",5)
    CALL _ADVPL_set_property(m_limite,"VARIABLE",mr_param,"limite_saldo")
    CALL _ADVPL_set_property(m_limite,"PICTURE","@E ###")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",10,100)  
    CALL _ADVPL_set_property(l_label,"TEXT","Enviar lembrete:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_enviar_lemb = _ADVPL_create_component(NULL,"LCHECKBOX",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_enviar_lemb,"POSITION",100,100)  
    CALL _ADVPL_set_property(m_enviar_lemb,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_enviar_lemb,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_enviar_lemb,"VARIABLE",mr_param,"enviar_lembrete")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",140,100)  
    CALL _ADVPL_set_property(l_label,"TEXT","Repetir lembrete:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_repetir_lemb = _ADVPL_create_component(NULL,"LCHECKBOX",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_repetir_lemb,"POSITION",240,100)  
    CALL _ADVPL_set_property(m_repetir_lemb,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_repetir_lemb,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_repetir_lemb,"VARIABLE",mr_param,"repetir_lembrete")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",280,100)  
    CALL _ADVPL_set_property(l_label,"TEXT","Repetir após:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_rep_lemb_apos = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_rep_lemb_apos,"POSITION",360,100)  
    CALL _ADVPL_set_property(m_rep_lemb_apos,"LENGTH",5)
    CALL _ADVPL_set_property(m_rep_lemb_apos,"VARIABLE",mr_param,"repetir_lemb_apos")
    CALL _ADVPL_set_property(m_rep_lemb_apos,"PICTURE","@E ###")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",410,100)  
    CALL _ADVPL_set_property(l_label,"TEXT","dias")    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",460,100)  
    CALL _ADVPL_set_property(l_label,"TEXT","A vencer até:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_a_vencer = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_a_vencer,"POSITION",540,100)  
    CALL _ADVPL_set_property(m_a_vencer,"LENGTH",5)
    CALL _ADVPL_set_property(m_a_vencer,"VARIABLE",mr_param,"vencer_ate")
    CALL _ADVPL_set_property(m_a_vencer,"PICTURE","@E ###")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",595,100)  
    CALL _ADVPL_set_property(l_label,"TEXT","dias")    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",10,130)  
    CALL _ADVPL_set_property(l_label,"TEXT","Emitente do e-amil:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_emitente = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_emitente,"POSITION",120,130)  
    CALL _ADVPL_set_property(m_emitente,"LENGTH",8)
    CALL _ADVPL_set_property(m_emitente,"VARIABLE",mr_param,"emitente_email")
    CALL _ADVPL_set_property(m_emitente,"VALID","pol1399_valida_emitente")

    LET m_lupa_emitente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_lupa_emitente,"POSITION",195,130)  
    CALL _ADVPL_set_property(m_lupa_emitente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_emitente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_emitente,"CLICK_EVENT","pol1399_zoom_emitemte")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_caixa,"POSITION",220,130)  
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30)
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_param,"nom_emitente")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",10,160)  
    CALL _ADVPL_set_property(l_label,"TEXT","Emails do cliente:")    

    LET m_email1_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_email1_cliente,"POSITION",120,160)  
    CALL _ADVPL_set_property(m_email1_cliente,"LENGTH",50)
    CALL _ADVPL_set_property(m_email1_cliente,"VARIABLE",mr_param,"email1_cliente")
    CALL _ADVPL_set_property(m_email1_cliente,"GOT_FOCUS_EVENT","pol1399_ve_cliente") 
    CALL _ADVPL_set_property(m_email1_cliente,"ENABLE",FALSE)

    LET m_email2_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_email2_cliente,"POSITION",120,190)  
    CALL _ADVPL_set_property(m_email2_cliente,"LENGTH",50)
    CALL _ADVPL_set_property(m_email2_cliente,"VARIABLE",mr_param,"email2_cliente")
    CALL _ADVPL_set_property(m_email2_cliente,"GOT_FOCUS_EVENT","pol1399_ve_cliente") 
    CALL _ADVPL_set_property(m_email2_cliente,"ENABLE",FALSE)

    LET m_email3_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_cab_param)
    CALL _ADVPL_set_property(m_email3_cliente,"POSITION",120,220)  
    CALL _ADVPL_set_property(m_email3_cliente,"LENGTH",50)
    CALL _ADVPL_set_property(m_email3_cliente,"VARIABLE",mr_param,"email3_cliente")
    CALL _ADVPL_set_property(m_email3_cliente,"GOT_FOCUS_EVENT","pol1399_ve_cliente") 
    CALL _ADVPL_set_property(m_email3_cliente,"ENABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_label,"POSITION",10,250)  
    CALL _ADVPL_set_property(l_label,"TEXT","Observação:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_cab_param)
    CALL _ADVPL_set_property(l_caixa,"POSITION",90,250)  
    CALL _ADVPL_set_property(l_caixa,"LENGTH",80)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_param,"observacao")

END FUNCTION

#----------------------------#
FUNCTION pol1399_ve_cliente()#
#----------------------------#

   IF mr_param.cod_cliente IS NULL THEN
      INITIALIZE mr_param.email1_cliente, 
         mr_param.email2_cliente, mr_param.email3_cliente TO NULL
      CALL pol1399_ativa_email(FALSE)
   ELSE
      CALL pol1399_ativa_email(TRUE)
   END IF

   IF mr_param.email1_cliente IS NULL THEN
      INITIALIZE mr_param.email2_cliente, mr_param.email3_cliente TO NULL
   END IF

   IF mr_param.email2_cliente IS NULL THEN
      INITIALIZE mr_param.email3_cliente TO NULL
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1399_ativa_email(l_status)#
#-------------------------------------#
   
   DEFINE l_status      SMALLINT
   
   CALL _ADVPL_set_property(m_email1_cliente,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_email2_cliente,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_email3_cliente,"ENABLE",l_status)

END FUNCTION

#------------------------------#
FUNCTION pol1399_zoom_cliente()#
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
        LET mr_param.cod_cliente = l_codigo
        LET mr_param.nom_cliente = l_descri
    END IF
   
    CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")  

END FUNCTION

#----------------------------------#
FUNCTION pol1399_le_cliente(l_cod)#
#----------------------------------#
   
   DEFINE l_cod CHAR(15)

   IF l_cod IS NULL THEN
      LET m_nome_cliente = ''
      RETURN TRUE
   END IF
   
   LET m_msg = ''
      
   SELECT nom_cliente
     INTO m_nome_cliente
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
FUNCTION pol1399_valida_cliente()#
#--------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF NOT pol1399_le_cliente(mr_param.cod_cliente) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET mr_param.nom_cliente = m_nome_cliente
   
   IF m_opcao = 'I' THEN
      IF pol1399_cli_ja_existe(mr_param.cod_cliente) THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF      
   END IF
   
   CALL pol1399_ve_cliente()
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1399_cli_ja_existe(l_cod)#
#------------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''

   IF l_cod IS NULL THEN
      SELECT COUNT(*)
        INTO m_count
        FROM param_cobranca_912
       WHERE cod_cliente IS NULL
   ELSE   
      SELECT COUNT(*)
        INTO m_count
        FROM param_cobranca_912
       WHERE cod_cliente = l_cod
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','param_cobranca_912')
      LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA param_cobranca_912'   
      RETURN TRUE
   END IF
         
   IF m_count > 0 THEN
      IF l_cod IS NULL THEN
         LET m_msg = 'Já existe um registro padrão cadastrado no pol1399.'
      ELSE
         LET m_msg = 'Cliente já cadastrado no pol1399.'
      END IF
      RETURN TRUE
   END IF   
   
   RETURN FALSE

END FUNCTION

#-------------------------------#
FUNCTION pol1399_zoom_emitemte()#
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
        LET mr_param.emitente_email = l_codigo
        LET mr_param.nom_emitente = l_descri
    END IF
    
    CALL _ADVPL_set_property(m_emitente,"GET_FOCUS")
    
END FUNCTION

#---------------------------------#
FUNCTION pol1399_le_usuario(l_cod)#
#---------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''
      
   SELECT nom_funcionario
     INTO mr_param.nom_emitente
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
FUNCTION pol1399_valida_emitente()#
#---------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF  mr_param.emitente_email IS NULL THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o emitente de e-amil")
       RETURN FALSE
   END IF

   IF NOT pol1399_le_usuario(mr_param.emitente_email) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------------#
FUNCTION pol1399_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   CALL _ADVPL_set_property(m_pnl_cab_param,"ENABLE",l_status)

END FUNCTION

#-----------------------------#
FUNCTION pol1399_limpa_campos()
#-----------------------------#

   INITIALIZE mr_param.* TO NULL
    
END FUNCTION

#-----------------------#
FUNCTION pol1399_create()
#-----------------------#
    
    LET m_opcao = 'I'    
    CALL pol1399_limpa_campos()
    CALL pol1399_ativa_desativa(TRUE)
    
    LET m_ies_cons = FALSE

    SELECT emitente_email
      INTO mr_param.emitente_email
      FROM param_cobranca_912
     WHERE cod_cliente IS NULL
    
    CALL pol1399_le_usuario(mr_param.emitente_email) RETURNING p_status
    
    CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")    
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1399_create_confirm()
#-------------------------------#

   IF NOT pol1399_valid_form() THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN FALSE
   END IF

   SELECT MAX(id_registro)
     INTO m_id_registro
     FROM param_cobranca_912

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','param_cobranca_912:max')
      RETURN FALSE
   END IF

   IF m_id_registro IS NULL THEN
      LET m_id_registro = 0
   END IF
   
   LET m_id_registro = m_id_registro + 1
       
   INSERT INTO param_cobranca_912(
      id_registro,
      cod_cliente,     
      vencidos_de,      
      vencidos_ate,        
      enviar_cobranca,         
      repetir_cobranca,       
      repetir_cob_apos,       
      limite_saldo,           
      enviar_lembrete,        
      repetir_lembrete,                  
      repetir_lemb_apos,                 
      vencer_ate,                        
      emitente_email,                    
      email1_cliente,         
      email2_cliente,         
      email3_cliente,   
      observacao)      
                    
   VALUES(m_id_registro,
          mr_param.cod_cliente,      
          mr_param.vencidos_de,       
          mr_param.vencidos_ate,      
          mr_param.enviar_cobranca,   
          mr_param.repetir_cobranca,  
          mr_param.repetir_cob_apos,  
          mr_param.limite_saldo,      
          mr_param.enviar_lembrete,   
          mr_param.repetir_lembrete,  
          mr_param.repetir_lemb_apos, 
          mr_param.vencer_ate,        
          mr_param.emitente_email,    
          mr_param.email1_cliente,    
          mr_param.email2_cliente,    
          mr_param.email3_cliente,    
          mr_param.observacao)        
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','param_cobranca_912')
      RETURN FALSE
   END IF
            
   CALL pol1399_ativa_desativa(FALSE)

   RETURN TRUE
        
END FUNCTION

#----------------------------#
FUNCTION pol1399_valid_form()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')

   LET m_msg = 'Campos em negrito são obrigatórios.'

   IF mr_param.vencidos_de IS NULL OR mr_param.vencidos_de < 0 THEN 
      CALL _ADVPL_set_property(m_vencidos_de,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_param.vencidos_ate IS NULL OR mr_param.vencidos_ate < 0 THEN 
      CALL _ADVPL_set_property(m_vencidos_ate,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_param.vencidos_ate < mr_param.vencidos_de THEN 
      LET m_msg = 'Campo Atraso até deve ser maior ou igual ao campo Atrade de'
      CALL _ADVPL_set_property(m_vencidos_ate,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_param.repetir_cob_apos IS NULL OR mr_param.repetir_cob_apos < 0 THEN 
      CALL _ADVPL_set_property(m_rep_cob_apos,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_param.vencer_ate IS NULL OR mr_param.vencer_ate < 0 THEN 
      CALL _ADVPL_set_property(m_a_vencer,"GET_FOCUS")
      RETURN FALSE
   END IF
      
   IF  mr_param.emitente_email IS NULL THEN
       CALL _ADVPL_set_property(m_emitente,"GET_FOCUS")
       RETURN FALSE
   END IF

   IF mr_param.limite_saldo IS NULL OR mr_param.limite_saldo < 0 THEN 
      LET mr_param.limite_saldo = 0
   END IF
   
   IF mr_param.email3_cliente = mr_param.email2_cliente THEN
      INITIALIZE mr_param.email3_cliente TO NULL
   END IF

   IF mr_param.email3_cliente = mr_param.email1_cliente THEN
      INITIALIZE mr_param.email3_cliente TO NULL
   END IF
   
   IF mr_param.email2_cliente = mr_param.email1_cliente THEN
      INITIALIZE mr_param.email2_cliente TO NULL
   END IF
   
   LET m_msg = ''
      
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1399_create_cancel()#
#-------------------------------#

    CALL pol1399_ativa_desativa(FALSE)
    CALL pol1399_limpa_campos()
    
    RETURN TRUE
        
END FUNCTION

#----------------------#
FUNCTION pol1399_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1399_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","param_cobranca_912","cliente")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","param_cobranca_912","cod_cliente","Cliente",1 {CHAR},15,0,"zoom_clientes")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","param_cobranca_912","emitente_email","Emitente",1 {CHAR},8,0,"zoom_usuarios")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1399_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1399_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " cod_cliente "
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT id_registro ",
                      " FROM param_cobranca_912",
                     " WHERE ",l_where CLIPPED,
                     " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","param_cobranca_912")
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
          LET m_msg = "Argumentos de pesquisa não encontrados."
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       END IF
       CALL pol1399_limpa_campos()
       RETURN FALSE
    END IF
    
    CALL pol1399_exibe_dados() RETURNING p_status 
    
    LET m_ies_cons = TRUE
    LET a_id_registro = m_id_registro
    
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1399_exibe_dados()#
#-----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_excluiu = FALSE
   INITIALIZE mr_param.* TO NULL
   
   SELECT cod_cliente,       
          vencidos_de,      
          vencidos_ate,     
          enviar_cobranca,  
          repetir_cobranca, 
          repetir_cob_apos, 
          limite_saldo,     
          enviar_lembrete,         
          repetir_lembrete,        
          repetir_lemb_apos,       
          vencer_ate,              
          emitente_email,   
          email1_cliente,   
          email2_cliente,   
          email3_cliente,   
          observacao                        
     INTO mr_param.cod_cliente,       
          mr_param.vencidos_de,       
          mr_param.vencidos_ate,      
          mr_param.enviar_cobranca,   
          mr_param.repetir_cobranca,  
          mr_param.repetir_cob_apos,  
          mr_param.limite_saldo,      
          mr_param.enviar_lembrete,       
          mr_param.repetir_lembrete,  
          mr_param.repetir_lemb_apos,     
          mr_param.vencer_ate,        
          mr_param.emitente_email,    
          mr_param.email1_cliente,    
          mr_param.email2_cliente,        
          mr_param.email3_cliente,    
          mr_param.observacao         
     FROM param_cobranca_912
    WHERE id_registro = m_id_registro

    IF STATUS <> 0 THEN
       CALL log003_err_sql("SELECT","param_cobranca_912:ed")
       RETURN FALSE
    END IF
         
   IF NOT pol1399_le_cliente(mr_param.cod_cliente) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
   
   LET mr_param.nom_cliente = m_nome_cliente
   
   IF NOT pol1399_le_usuario(mr_param.emitente_email) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1399_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1399_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1399_ies_cons() THEN
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
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_id_registro = a_id_registro
         EXIT WHILE
      ELSE
         SELECT 1
           FROM param_cobranca_912
          WHERE id_registro = m_id_registro
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1399_exibe_dados()
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
FUNCTION pol1399_first()#
#-----------------------#

   IF NOT pol1399_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1399_next()#
#----------------------#

   IF NOT pol1399_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1399_previous()#
#--------------------------#

   IF NOT pol1399_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1399_last()#
#----------------------#

   IF NOT pol1399_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1399_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM param_cobranca_912
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
FUNCTION pol1399_alterar()#
#-------------------------#
   
   LET m_opcao = 'A'
    
   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN FALSE
   END IF
   
   IF NOT pol1399_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1399_prende_registro() THEN
      RETURN FALSE
   END IF
   
   CALL pol1399_ativa_desativa(TRUE)
   CALL _ADVPL_set_property(m_cod_cliente,"ENABLE",FALSE)
   CALL pol1399_ve_cliente()
   CALL _ADVPL_set_property(m_vencidos_de,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1399_ies_alterar()#
#-----------------------------#
   
   DEFINE l_ret   SMALLINT
   
   LET l_ret = TRUE

   IF NOT pol1399_valid_form() THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN FALSE
   END IF

   UPDATE param_cobranca_912
      SET vencidos_de        = mr_param.vencidos_de,           
          vencidos_ate       = mr_param.vencidos_ate,     
          enviar_cobranca    = mr_param.enviar_cobranca,  
          repetir_cobranca   = mr_param.repetir_cobranca, 
          repetir_cob_apos   = mr_param.repetir_cob_apos, 
          limite_saldo       = mr_param.limite_saldo,     
          enviar_lembrete    = mr_param.enviar_lembrete,  
          repetir_lembrete   = mr_param.repetir_lembrete, 
          repetir_lemb_apos  = mr_param.repetir_lemb_apos,
          vencer_ate         = mr_param.vencer_ate,       
          emitente_email     = mr_param.emitente_email,   
          email1_cliente     = mr_param.email1_cliente,   
          email2_cliente     = mr_param.email2_cliente,   
          email3_cliente     = mr_param.email3_cliente,   
          observacao         = mr_param.observacao       
    WHERE id_registro = m_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','param_cobranca_912')
      LET l_ret = FALSE
   END IF
         
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1399_ativa_desativa(FALSE)
      CALL _ADVPL_set_property(m_cod_cliente,"ENABLE",TRUE)
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
   
END FUNCTION

#----------------------------#
FUNCTION pol1399_no_alterar()#
#----------------------------#
    
   CALL pol1399_exibe_dados()
   CALL pol1399_ativa_desativa(FALSE)
   CALL _ADVPL_set_property(m_cod_cliente,"ENABLE",TRUE)

   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1399_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1399_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1399_prende_registro() THEN
      RETURN FALSE
   END IF

   DELETE FROM param_cobranca_912
    WHERE id_registro = m_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','param_cobranca_912')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1399_limpa_campos()
      LET m_excluiu = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION

#-------------------------------#
FUNCTION pol1399_menu_cobranca()#
#-------------------------------#

    DEFINE l_inform     VARCHAR(10),
           l_proces     VARCHAR(10)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",m_menu_cobranca)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1399_info_cobranca")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1399_info_cobranca_ies")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1399_info_cobranca_no")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",m_menu_cobranca)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Envia e-mail de cobrança")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1399_proces_cobranca")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_cobranca)
    
END FUNCTION

#--------------------------------#
FUNCTION pol1399_dados_cobranca()#
#--------------------------------#

    DEFINE l_panel           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_zoom            VARCHAR(10),
           l_label           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_pnl_cobranca)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",35)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)
    CALL _ADVPL_set_property(l_panel,"EDITABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",350,10)  
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"TEXT","PROCESSAMENTO DE COBRANÇA MANUAL")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET m_pnl_cab_cobr = _ADVPL_create_component(NULL,"LPANEL",m_pnl_cobranca)
    CALL _ADVPL_set_property(m_pnl_cab_cobr,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_pnl_cab_cobr,"ENABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_cobr)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cli_cobranca = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_cab_cobr)
    CALL _ADVPL_set_property(m_cli_cobranca,"POSITION",70,10)  
    CALL _ADVPL_set_property(m_cli_cobranca,"LENGTH",15)
    CALL _ADVPL_set_property(m_cli_cobranca,"VARIABLE",mr_cobranca,"cod_cliente")
    CALL _ADVPL_set_property(m_cli_cobranca,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cli_cobranca,"VALID","pol1399_valida_cli_cobr")

    LET l_zoom = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pnl_cab_cobr)
    CALL _ADVPL_set_property(l_zoom,"POSITION",200,10)  
    CALL _ADVPL_set_property(l_zoom,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_zoom,"SIZE",24,20)
    CALL _ADVPL_set_property(l_zoom,"CLICK_EVENT","pol1399_zoom_cli_cobr")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_cab_cobr)
    CALL _ADVPL_set_property(l_caixa,"POSITION",235,10)  
    CALL _ADVPL_set_property(l_caixa,"LENGTH",50) 
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cobranca,"nom_cliente")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_cobr)
    CALL _ADVPL_set_property(l_label,"POSITION",10,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Vencidos de:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cobranca_de = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pnl_cab_cobr)
    CALL _ADVPL_set_property(m_cobranca_de,"POSITION",90,40)  
    CALL _ADVPL_set_property(m_cobranca_de,"LENGTH",5)
    CALL _ADVPL_set_property(m_cobranca_de,"VARIABLE",mr_cobranca,"vencidos_de")
    CALL _ADVPL_set_property(m_cobranca_de,"PICTURE","@E ###")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_cobr)
    CALL _ADVPL_set_property(l_label,"POSITION",160,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Até:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cobranca_ate = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pnl_cab_cobr)
    CALL _ADVPL_set_property(m_cobranca_ate,"POSITION",200,40)  
    CALL _ADVPL_set_property(m_cobranca_ate,"LENGTH",5)
    CALL _ADVPL_set_property(m_cobranca_ate,"VARIABLE",mr_cobranca,"vencidos_ate")
    CALL _ADVPL_set_property(m_cobranca_ate,"PICTURE","@E ###")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_cobr)
    CALL _ADVPL_set_property(l_label,"POSITION",10,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","Reenviar após:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pnl_cab_cobr)
    CALL _ADVPL_set_property(l_caixa,"POSITION",90,70)  
    CALL _ADVPL_set_property(l_caixa,"LENGTH",5)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cobranca,"repetir_cob_apos")
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E ###")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

END FUNCTION

#-------------------------------#
FUNCTION pol1399_zoom_cli_cobr()#
#-------------------------------#

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
        LET mr_cobranca.cod_cliente = l_codigo
        LET mr_cobranca.nom_cliente = l_descri
    END IF
   
    CALL _ADVPL_set_property(m_cli_cobranca,"GET_FOCUS")  

END FUNCTION

#--------------------------------#
FUNCTION pol1399_valida_cli_cobr()#
#--------------------------------#
   
   DEFINE l_dias_reenvio     DECIMAL(3,0),
          l_dat_cobranca     CHAR(10)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF mr_cobranca.cod_cliente IS NULL THEN
      LET m_msg = 'Informe o cliente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT pol1399_le_cliente(mr_cobranca.cod_cliente) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET mr_cobranca.nom_cliente = m_nome_cliente
   
   SELECT vencidos_de,      
          vencidos_ate,    
          enviar_cobranca, 
          repetir_cobranca,                 
          repetir_cob_apos,                 
          limite_saldo,                     
          emitente_email   
     INTO mr_cobranca.vencidos_de,     
          mr_cobranca.vencidos_ate,    
          mr_cobranca.enviar_cobranca, 
          mr_cobranca.repetir_cobranca,
          mr_cobranca.repetir_cob_apos,
          mr_cobranca.limite_saldo,    
          mr_cobranca.emitente_email   
     FROM param_cobranca_912
    WHERE cod_cliente = mr_cobranca.cod_cliente

   IF STATUS = 100 THEN
      SELECT vencidos_de,                   
             vencidos_ate,                  
             enviar_cobranca,               
             repetir_cobranca,              
             repetir_cob_apos,                                                 
             limite_saldo,                                                     
             emitente_email                                                    
        INTO mr_cobranca.vencidos_de,                                          
             mr_cobranca.vencidos_ate,                                         
             mr_cobranca.enviar_cobranca,   
             mr_cobranca.repetir_cobranca,  
             mr_cobranca.repetir_cob_apos,  
             mr_cobranca.limite_saldo,      
             mr_cobranca.emitente_email     
        FROM param_cobranca_912                   
       WHERE cod_cliente IS NULL

      IF STATUS = 100 THEN
         LET m_msg = 'Cliente não cadstrado no POL1399'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','param_cobranca_912')
            RETURN FALSE
         END IF
      END IF  
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','param_cobranca_912')
         RETURN FALSE
      END IF
   END IF

   IF mr_cobranca.enviar_cobranca = 'N' THEN
      LET m_msg = 'Cliente não está parametrizado para receber lembretes.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
        
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1399_info_cobranca()#
#-------------------------------#

   INITIALIZE mr_cobranca TO NULL
   LET m_ies_cobranca = FALSE
   CALL _ADVPL_set_property(m_pnl_cab_cobr,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_cli_cobranca,"GET_FOCUS")
   
    RETURN TRUE
    
END FUNCTION

#----------------------------------#
FUNCTION pol1399_info_cobranca_no()#
#----------------------------------#

   INITIALIZE mr_cobranca TO NULL
   CALL _ADVPL_set_property(m_pnl_cab_cobr,"ENABLE",FALSE)
   LET m_ies_cobranca = FALSE
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1399_info_cobranca_ies()#
#-----------------------------------#

   IF mr_cobranca.vencidos_de IS NULL OR mr_cobranca.vencidos_de <= 0 THEN
      LET m_msg = 'Informe o campo Vencido de '
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF mr_cobranca.vencidos_ate IS NULL OR mr_cobranca.vencidos_ate <= 0 THEN
      LET m_msg = 'Informe o campo Vencido até '
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF mr_cobranca.vencidos_ate < mr_cobranca.vencidos_de THEN
      LET m_msg = 'O campo Vencido até deve ser maior ou igual ao campo Vencido de '
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF mr_cobranca.repetir_cob_apos IS NULL OR mr_cobranca.repetir_cob_apos <= 0 THEN
      LET m_msg = 'Informe o campo Repetir cobrança '
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET mr_cobranca.cod_empresa = p_cod_empresa
   LET m_ies_cobranca = TRUE
   
   CALL _ADVPL_set_property(m_pnl_cab_cobr,"ENABLE",FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1399_proces_cobranca()#
#---------------------------------#
   
   IF NOT m_ies_cobranca THEN
      LET m_msg = 'Informe o cliente, previamente '
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET m_msg = pol1400_proces_cobranca(mr_cobranca) 
   
   IF m_msg IS NULL THEN
      LET m_msg = 'Operação aefetuada com sucesso'
   END IF

   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1399_menu_lembrete()#
#-------------------------------#

    DEFINE l_inform     VARCHAR(10),
           l_proces     VARCHAR(10)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",m_menu_lembrete)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1399_info_lembrete")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1399_info_lembrete_ies")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1399_info_lembrete_no")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",m_menu_lembrete)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Envia e-mail de lembrete")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1399_proces_lembrete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_lembrete)
    
END FUNCTION

#--------------------------------#
FUNCTION pol1399_dados_lembrete()#
#--------------------------------#

    DEFINE l_panel           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_zoom            VARCHAR(10),
           l_label           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_pnl_lembrete)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",35)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)
    CALL _ADVPL_set_property(l_panel,"EDITABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",350,10)  
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"TEXT","PROCESSAMENTO DE LEMBRETE MANUAL")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET m_pnl_cab_lembre = _ADVPL_create_component(NULL,"LPANEL",m_pnl_lembrete)
    CALL _ADVPL_set_property(m_pnl_cab_lembre,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_pnl_cab_lembre,"ENABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_lembre)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cli_lembrete = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_cab_lembre)
    CALL _ADVPL_set_property(m_cli_lembrete,"POSITION",70,10)  
    CALL _ADVPL_set_property(m_cli_lembrete,"LENGTH",15)
    CALL _ADVPL_set_property(m_cli_lembrete,"VARIABLE",mr_lembrete,"cod_cliente")
    CALL _ADVPL_set_property(m_cli_lembrete,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cli_lembrete,"VALID","pol1399_valida_cli_lembre")

    LET l_zoom = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pnl_cab_lembre)
    CALL _ADVPL_set_property(l_zoom,"POSITION",200,10)  
    CALL _ADVPL_set_property(l_zoom,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_zoom,"SIZE",24,20)
    CALL _ADVPL_set_property(l_zoom,"CLICK_EVENT","pol1399_zoom_cli_lembre")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_cab_lembre)
    CALL _ADVPL_set_property(l_caixa,"POSITION",235,10)  
    CALL _ADVPL_set_property(l_caixa,"LENGTH",50) 
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_lembrete,"nom_cliente")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cab_lembre)
    CALL _ADVPL_set_property(l_label,"POSITION",10,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Vencer até:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_vencer_ate = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pnl_cab_lembre)
    CALL _ADVPL_set_property(m_vencer_ate,"POSITION",90,40)  
    CALL _ADVPL_set_property(m_vencer_ate,"LENGTH",5)
    CALL _ADVPL_set_property(m_vencer_ate,"VARIABLE",mr_lembrete,"vencer_ate")
    CALL _ADVPL_set_property(m_vencer_ate,"PICTURE","@E ###")

END FUNCTION

#---------------------------------#
FUNCTION pol1399_zoom_cli_lembre()#
#---------------------------------#

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
        LET mr_lembrete.cod_cliente = l_codigo
        LET mr_lembrete.nom_cliente = l_descri
    END IF
   
    CALL _ADVPL_set_property(m_cli_lembrete,"GET_FOCUS")  

END FUNCTION

#-----------------------------------#
FUNCTION pol1399_valida_cli_lembre()#
#-----------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF mr_lembrete.cod_cliente IS NULL THEN
      LET m_msg = 'Informe o cliente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT pol1399_le_cliente(mr_lembrete.cod_cliente) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET mr_lembrete.nom_cliente = m_nome_cliente

   SELECT enviar_lembrete, 
          repetir_lembrete, 
          repetir_lemb_apos,
          vencer_ate,                    
          emitente_email                                       
     INTO mr_lembrete.enviar_lembrete,  
          mr_lembrete.repetir_lembrete, 
          mr_lembrete.repetir_lemb_apos,
          mr_lembrete.vencer_ate,       
          mr_lembrete.emitente_email    
     FROM param_cobranca_912
    WHERE cod_cliente = mr_cobranca.cod_cliente

   IF STATUS = 100 THEN
      SELECT enviar_lembrete,              
             repetir_lembrete,             
             repetir_lemb_apos,            
             vencer_ate,                   
             emitente_email                
        INTO mr_lembrete.enviar_lembrete,  
             mr_lembrete.repetir_lembrete, 
             mr_lembrete.repetir_lemb_apos,
             mr_lembrete.vencer_ate,       
             mr_lembrete.emitente_email    
        FROM param_cobranca_912                   
       WHERE cod_cliente IS NULL

      IF STATUS = 100 THEN
         LET m_msg = 'Cliente não cadstrado no POL1399'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','param_cobranca_912')
            RETURN FALSE
         END IF
      END IF  
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','param_cobranca_912')
         RETURN FALSE
      END IF
   END IF
   
   IF mr_lembrete.enviar_lembrete = 'N' THEN
      LET m_msg = 'Cliente não está parametrizado para receber lembretes.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1399_info_lembrete()#
#-------------------------------#

   INITIALIZE mr_lembrete TO NULL
   LET m_ies_lembrete = FALSE
   CALL _ADVPL_set_property(m_pnl_cab_lembre,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_cli_lembrete,"GET_FOCUS")

END FUNCTION

#----------------------------------#
FUNCTION pol1399_info_lembrete_no()#
#----------------------------------#

   INITIALIZE mr_lembrete TO NULL
   CALL _ADVPL_set_property(m_pnl_cab_lembre,"ENABLE",FALSE)
   LET m_ies_lembrete = FALSE

END FUNCTION

#-----------------------------------#
FUNCTION pol1399_info_lembrete_ies()#
#-----------------------------------#

   IF mr_lembrete.vencer_ate IS NULL OR mr_lembrete.vencer_ate <= 0 THEN
      LET m_msg = 'Informe o campo Vencer até '
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_pnl_cab_lembre,"ENABLE",FALSE)

   LET mr_lembrete.cod_empresa = p_cod_empresa   
   LET m_ies_lembrete = TRUE
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1399_proces_lembrete()#
#---------------------------------#

   IF NOT m_ies_lembrete THEN
      LET m_msg = 'Informe o cliente, previamente '
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET m_msg = pol1400_proces_lembrete(mr_lembrete) 
   
   IF m_msg IS NULL THEN
      LET m_msg = 'Operação aefetuada com sucesso'
   END IF

   CALL log0030_mensagem(m_msg,'info')

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1399_menu_erro()#
#---------------------------#

    DEFINE l_find       VARCHAR(10),
           l_proces     VARCHAR(10)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",m_menu_erro)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1399_consulta")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_erro)
    
END FUNCTION

#----------------------------#
FUNCTION pol1399_dados_erro()#
#----------------------------#
   
    DEFINE l_panel           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_zoom            VARCHAR(10),
           l_label           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)
           
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_pnl_erro)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",35)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)
    CALL _ADVPL_set_property(l_panel,"EDITABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",300,10)  
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"TEXT","CONSULTA ERROS DE ENVIO DE COBRANÇA/LEMBRETES")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET m_pnl_cab_erro = _ADVPL_create_component(NULL,"LPANEL",m_pnl_erro)
    CALL _ADVPL_set_property(m_pnl_cab_erro,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_pnl_cab_erro,"ENABLE",FALSE) 

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pnl_cab_erro)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","EMPRESA")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_empresa")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DATA")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_proces")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","HORA")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","hor_proces")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","MENSAGEM")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_erro,1)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#--------------------------#
FUNCTION pol1399_consulta()#
#--------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_erro_construct IS NULL THEN
       LET m_erro_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_erro_construct,"CONSTRUCT_NAME","pol1399_FILTER_ERRO")
       CALL _ADVPL_set_property(m_erro_construct,"ADD_VIRTUAL_TABLE","mensagem_envio_912","mensagem")
       CALL _ADVPL_set_property(m_erro_construct,"ADD_VIRTUAL_COLUMN","mensagem_envio_912","cod_empresa","Empresa",1 {CHAR},2,0)
       CALL _ADVPL_set_property(m_erro_construct,"ADD_VIRTUAL_COLUMN","mensagem_envio_912","dat_proces","Data",1 {DATE},10,0)
       CALL _ADVPL_set_property(m_erro_construct,"ADD_VIRTUAL_COLUMN","mensagem_envio_912","hor_proces","Hora",1 {CHAR},8,0)
    END IF

    LET l_status = _ADVPL_get_property(m_erro_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_erro_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_erro_construct,"ORDER_BY")
       CALL pol1399_erro_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#---------------------------------------------#
FUNCTION pol1399_erro_cursor(l_where, l_order)#
#---------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt  CHAR(2000)
    DEFINE l_ind       INTEGER

    LET l_ind = 1
    INITIALIZE ma_erro TO NULL
    CALL _ADVPL_set_property(m_browse,"CLEAR")

    IF l_order IS NULL THEN
       LET l_order = " dat_proces "
    END IF
    
    LET l_sql_stmt = "SELECT * FROM mensagem_envio_912",
                     " WHERE ",l_where CLIPPED,
                     " ORDER BY ",l_order

    PREPARE var_erro FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","mensagem_envio_912")
       RETURN FALSE
    END IF

    DECLARE cq_erro SCROLL CURSOR WITH HOLD FOR var_erro

    IF  STATUS <> 0 THEN
        CALL log003_err_sql("DECLARE CURSOR","cq_erro")
        RETURN FALSE
    END IF

    FOREACH cq_erro INTO ma_erro[l_ind].*

       IF STATUS <> 0 THEN
          CALL log003_err_sql('FOREACH','cq_erro')
       END IF
       
       LET l_ind = l_ind + 1
       
       IF l_ind > 1000 THEN
          LET m_msg = 'Limite de linhas da grade ultrpassou'
          CALL log0030_mensagem(m_msg, 'info')
          EXIT FOREACH
       END IF
       
    END FOREACH
    
    IF l_ind = 1 THEN
       LET m_msg = 'Não há dados para os parêmetros informados'
       CALL log0030_mensagem(m_msg, 'info')
    ELSE
      LET l_ind = l_ind - 1
      CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", l_ind)
    END IF
    
    RETURN TRUE
    
END FUNCTION

   