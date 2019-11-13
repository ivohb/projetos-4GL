#-------------------------------------------------------------------#
# SISTEMA.: LOGIX      ITAESBRA                                     #
# PROGRAMA: pol1369                                                 #
# OBJETIVO: INSPEÇÃO DE ITEM PRODUZIDO                              #
# AUTOR...: IVO                                                     #
# DATA....: 07/05/2019                                              #
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
           p_caminho       CHAR(080),
           p_comando       CHAR(200)
END GLOBALS

DEFINE p_nom_tela          CHAR(200)

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_panel           VARCHAR(10),
       m_ordem           VARCHAR(10),
       m_lote            VARCHAR(10),
       m_produzida       VARCHAR(10),
       m_liberada        VARCHAR(10),
       m_rejeitada       VARCHAR(10),
       m_motivo          VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT

DEFINE mr_cabec            RECORD 
   num_ordem               DECIMAL(9,0),
   num_lote                CHAR(15),
   qtd_lote                DECIMAL(10,3),
   qtd_liberada            DECIMAL(10,3),
   qtd_rejeitada           DECIMAL(10,3),
   cod_motivo              DECIMAL(10,3)
END RECORD        

#-----------------#
FUNCTION pol1369()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1369-12.00.00  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1369_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1369_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_proces      VARCHAR(10),
           l_titulo      CHAR(50)
    
    LET l_titulo = "INSPEÇÃO DE ITEM PRODUZIDO"
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    #CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    #CALL _ADVPL_set_property(m_dialog,"SIZE",150,120)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1369_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1369_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1369_cancelar")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Processa a inspeção")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1369_processar")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1369_cria_campos(l_panel)

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1369_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_label           VARCHAR(10)

    LET m_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel,"ALIGN","CENTER")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Num ordem:")    

    LET m_ordem = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_ordem,"POSITION",90,10)     
    CALL _ADVPL_set_property(m_ordem,"LENGTH",9,0)
    CALL _ADVPL_set_property(m_ordem,"PICTURE","@E #########")
    CALL _ADVPL_set_property(m_ordem,"VARIABLE",mr_cabec,"num_ordem")
    #CALL _ADVPL_set_property(m_ordem,"VALID","pol1369_valid_ordem")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Num Lote:")    

    LET m_lote = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(m_lote,"POSITION",90,40)     
    CALL _ADVPL_set_property(m_lote,"LENGTH",15) 
    CALL _ADVPL_set_property(m_lote,"PICTURE","@!")
    CALL _ADVPL_set_property(m_lote,"VARIABLE",mr_cabec,"num_lote")
    CALL _ADVPL_set_property(m_lote,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_lote,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,70)     
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd Lote:")    

    LET m_produzida = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_produzida,"POSITION",90,70)     
    CALL _ADVPL_set_property(m_produzida,"LENGTH",10) 
    CALL _ADVPL_set_property(m_produzida,"PICTURE","@E ######.###")
    CALL _ADVPL_set_property(m_produzida,"VARIABLE",mr_cabec,"qtd_lote")
    CALL _ADVPL_set_property(m_produzida,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_produzida,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,100)     
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd liberada:")    

    LET m_liberada = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_liberada,"POSITION",90,100)     
    CALL _ADVPL_set_property(m_liberada,"LENGTH",10) 
    CALL _ADVPL_set_property(m_liberada,"PICTURE","@E ######.###")
    CALL _ADVPL_set_property(m_liberada,"VARIABLE",mr_cabec,"qtd_liberada")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,130)     
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd rejeitada:")    

    LET m_rejeitada = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_rejeitada,"POSITION",90,130)     
    CALL _ADVPL_set_property(m_rejeitada,"LENGTH",10) 
    CALL _ADVPL_set_property(m_rejeitada,"PICTURE","@E ######.###")
    CALL _ADVPL_set_property(m_rejeitada,"VARIABLE",mr_cabec,"qtd_rejeitada")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,160)     
    CALL _ADVPL_set_property(l_label,"TEXT","Motivo:")    

    LET m_motivo = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_motivo,"POSITION",90,160)     
    CALL _ADVPL_set_property(m_motivo,"LENGTH",10) 
    CALL _ADVPL_set_property(m_motivo,"PICTURE","@E ######.###")
    CALL _ADVPL_set_property(m_motivo,"VARIABLE",mr_cabec,"cod_motivo")

END FUNCTION
   