#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1386                                                 #
# OBJETIVO: CONFER�NCIA DE PEDIDOS                                  #
# AUTOR...: IVO                                                     #
# DATA....: 17/02/20                                                #
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

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_browse          VARCHAR(10)

DEFINE m_folder          VARCHAR(10),
       m_fold_conf_ped   VARCHAR(10),
       m_fold_cap_fab    VARCHAR(10),
       m_fold_prz_min    VARCHAR(10)
              
DEFINE ma_pedido         ARRAY[2000] OF RECORD
       filler            CHAR(01)
END RECORD
             
#-----------------#
FUNCTION pol1386()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1386-12.00.00  "
   CALL func002_versao_prg(p_versao)
   
   CALL pol1386_menu()

END FUNCTION
 
#----------------------#
FUNCTION pol1386_menu()#
#----------------------#

    DEFINE l_menubar       VARCHAR(10),
           l_fechar        VARCHAR(10),
           l_panel         VARCHAR(10),
           l_fpanel        VARCHAR(10),
           l_label         VARCHAR(10),
           l_titulo        CHAR(80)

    LET l_titulo = 'CONFER�NCIA DE PEDIDOS - ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET m_folder = _ADVPL_create_component(NULL,"LFOLDER",m_dialog)
    CALL _ADVPL_set_property(m_folder,"ALIGN","CENTER")

    # FOLDER de confer�ncia do pedido 

    LET m_fold_conf_ped = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_conf_ped,"TITLE","Confer�ncia do pedido")
		CALL pol1386_conf_ped(m_fold_conf_ped)
    
    # FOLDER capacidade da f�brica 

    LET m_fold_cap_fab = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_cap_fab,"TITLE","Capacidade da f�brica")
    CALL pol1388_cap_fab(m_fold_cap_fab, m_statusbar)

    # FOLDER prazo m�nimo 

    LET m_fold_prz_min = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_prz_min,"TITLE","Prazo m�nimo")
    CALL pol1387_prz_min(m_fold_prz_min, m_statusbar)

    CALL _ADVPL_set_property(m_folder,"FOLDER_SELECTED",1)
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION
   
#------------------------#
FUNCTION pol1386_fechar()#
#------------------------#
   
   DEFINE l_folder    SMALLINT

   LET l_folder = _ADVPL_get_property(m_folder,"FOLDER_SELECTED")
   CALL log0030_mensagem(l_folder,'info') 
   RETURN TRUE
   
END FUNCTION

#---CONFER�NCIA DO PEDIDO----#

#----------------------------------#
FUNCTION pol1386_conf_ped(l_fpanel)#
#----------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_inform    VARCHAR(10),
           l_update    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1386_info_item")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1386_info_item_conf")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1386_info_item_canc")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1386_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    #CALL pol1386_local_item(l_panel)
    #CALL pol1386_local_grade(l_panel)
    
END FUNCTION











