#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1375                                                 #
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
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_cod_empresa_plano   LIKE empresa.cod_empresa

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_panel           VARCHAR(10)

#----------------------#
FUNCTION pol1375_menu()#
#----------------------#

    DEFINE l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_titulo    CHAR(80)

    LET p_versao = "pol1375-12.00.00  "
    CALL func002_versao_prg(p_versao)
    
    LET l_titulo = 'CADASTRO DE LINHAS - ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LFRAME")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"BACKGROUND_COLOR",210,210,210)
    
    #CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    #CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1375_fechar")

    #LET m_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    #CALL _ADVPL_set_property(m_panel,"ALIGN","CENTER")

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#------------------------#
FUNCTION pol1375_fechar()#
#------------------------#

   RETURN TRUE

END FUNCTION
          