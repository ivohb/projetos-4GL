#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1374                                                 #
# OBJETIVO: CADASTRO DE ENDEREÇOS DO ITEM                           #
# AUTOR...: IVO                                                     #
# DATA....: 24/06/19                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           m_panel           VARCHAR(10),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_cod_empresa_plano   LIKE empresa.cod_empresa

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_folder          VARCHAR(10),
       m_opcoes          VARCHAR(10),
       m_edicao          VARCHAR(10),
       m_aba_linha       VARCHAR(10),
       m_aba_predio      VARCHAR(10),
       m_aba_andar       VARCHAR(10),
       m_aba_apto        VARCHAR(10),
       m_aba_relacto     VARCHAR(10),
       m_aba_local       VARCHAR(10)
       
DEFINE m_pan_arq         VARCHAR(10),
       m_item            VARCHAR(10),
       m_zoom_item       VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_local           VARCHAR(10),
       m_construct       VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_id_registro     INTEGER,
       m_id_registroa    INTEGER,
       m_cod_item        CHAR(15)
       
DEFINE mr_cabec          RECORD
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item,
       cod_local         LIKE local.cod_local,
       den_local         LIKE local.den_local
       
END RECORD



#-----------------#
FUNCTION pol1374()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1374-12.00.00  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1374_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1374_menu()#
#----------------------#

    DEFINE l_menubar       VARCHAR(10),
           l_fechar        VARCHAR(10),
           l_panel         VARCHAR(10),
           l_titulo        CHAR(80)

    LET l_titulo = 'CADASTRO DE ENDEREÇOS DO ITEM - ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1374_fechar")

    LET m_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(m_panel,"ALIGN","CENTER")

    #CALL pol1374_opcoes()
    CALL pol1374_folder()
    #CALL pol1374_edicao()

    CALL _ADVPL_set_property(m_folder,"FOLDER_SELECTED",1)
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#------------------------#
FUNCTION pol1374_opcoes()#
#------------------------#

    DEFINE l_panel        VARCHAR(10)
   
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_panel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
    CALL _ADVPL_set_property(l_panel,"WIDTH",210)
    CALL _ADVPL_set_property(l_panel,"FONT",NULL,11,FALSE,TRUE)    
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,231,237)

		LET m_aba_linha = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(m_aba_linha,"POSITION",10,20)     
    CALL _ADVPL_set_property(m_aba_linha,"TEXT","> Linha:")    
    CALL _ADVPL_set_property(m_aba_linha,"FONT",NULL,12,FALSE,FALSE)    
    CALL _ADVPL_set_property(m_aba_linha,"CLICK_EVENT","pol1374_linha")

		LET m_aba_predio = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(m_aba_predio,"POSITION",10,50)     
    CALL _ADVPL_set_property(m_aba_predio,"TEXT","> Prédio:")    
    CALL _ADVPL_set_property(m_aba_predio,"FONT",NULL,12,FALSE,FALSE)    
    CALL _ADVPL_set_property(m_aba_predio,"CLICK_EVENT","pol1374_predio")

		LET m_aba_andar = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(m_aba_andar,"POSITION",10,80)     
    CALL _ADVPL_set_property(m_aba_andar,"TEXT","> Andar:")    
    CALL _ADVPL_set_property(m_aba_andar,"FONT",NULL,12,FALSE,FALSE)    
    CALL _ADVPL_set_property(m_aba_andar,"CLICK_EVENT","pol1374_andar")

		LET m_aba_apto = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(m_aba_apto,"POSITION",10,110)     
    CALL _ADVPL_set_property(m_aba_apto,"TEXT","> Apto:")    
    CALL _ADVPL_set_property(m_aba_apto,"FONT",NULL,12,FALSE,FALSE)    
    CALL _ADVPL_set_property(m_aba_apto,"CLICK_EVENT","pol1374_apto")

		LET m_aba_relacto = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(m_aba_relacto,"POSITION",10,140)     
    CALL _ADVPL_set_property(m_aba_relacto,"TEXT","> Relacionamento:")    
    CALL _ADVPL_set_property(m_aba_relacto,"FONT",NULL,12,FALSE,FALSE)    
    CALL _ADVPL_set_property(m_aba_relacto,"CLICK_EVENT","pol1374_relacto")

		LET m_aba_local = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(m_aba_local,"POSITION",10,170)     
    CALL _ADVPL_set_property(m_aba_local,"TEXT","> Alterar local:")    
    CALL _ADVPL_set_property(m_aba_local,"FONT",NULL,12,FALSE,FALSE)    
    CALL _ADVPL_set_property(m_aba_local,"CLICK_EVENT","pol1374_alt_local")

END FUNCTION

FUNCTION pol1374_linha()

   CALL pol1375_menu()
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1374_fechar()#
#------------------------#

   #CALL log0030_mensagem('fechar','info')
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1374_folder()#
#------------------------#
   
    DEFINE l_panel        VARCHAR(10),
           l_fpanel       VARCHAR(10),
           l_label        VARCHAR(10)
   
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_panel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
    CALL _ADVPL_set_property(l_panel,"WIDTH",210)
    CALL _ADVPL_set_property(l_panel,"FONT",NULL,11,FALSE,TRUE)    
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,231,237)
   


   LET m_folder = _ADVPL_create_component(NULL,"LFOLDER",l_panel)
   CALL _ADVPL_set_property(m_folder,"ALIGN","CENTER")

    # FOLDER linha 

   LET l_fpanel = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
   CALL _ADVPL_set_property(l_fpanel,"TITLE","Linha")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_fpanel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)


    # FOLDER predio 

   LET l_fpanel = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
   CALL _ADVPL_set_property(l_fpanel,"TITLE","Prédio")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_fpanel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","predio:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)

END FUNCTION
   