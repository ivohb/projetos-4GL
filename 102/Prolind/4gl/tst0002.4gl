DATABASE logix

GLOBALS
    DEFINE p_cod_empresa LIKE empresa.cod_empresa
    DEFINE p_user        LIKE usuarios.cod_usuario
END GLOBALS

DEFINE m_dialog_reference,
       m_statusbar_reference VARCHAR(10)

DEFINE m_grid_reference,
       m_zoom_log_grupos_reference VARCHAR(10)

DEFINE ma_log_usu_grupos  ARRAY[999] OF RECORD
                              grupo     LIKE log_grupos.grupo,
                              des_grupo LIKE log_grupos.des_grupo
                          END RECORD

DEFINE ma_zoom_log_grupos ARRAY[999] OF RECORD
                              grupo     LIKE log_grupos.grupo,
                              des_grupo LIKE log_grupos.des_grupo
                          END RECORD

DEFINE m_page_length SMALLINT

#----------------#
FUNCTION tst0002()
#----------------#
    DEFINE l_menubar_reference VARCHAR(10)
    DEFINE l_panel_reference   VARCHAR(10)

    DEFINE l_inform_reference,
           l_print_reference,
           l_process_reference VARCHAR(10)

    {
    IF  LOG_initApp("PADRAO") <> 0 THEN
        RETURN
    END IF
    }

    LET p_cod_empresa = '21'
    LET p_user        = 'demo'

    INITIALIZE ma_log_usu_grupos,ma_zoom_log_grupos TO NULL

    CALL LOG_connectDatabase("DEFAULT")

    LET m_dialog_reference = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog_reference,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog_reference,"TITLE","Cadastro de grupo por usuários")

    LET m_statusbar_reference = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog_reference)

    #CRIACAO DO MENU
    LET l_menubar_reference = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog_reference)
    CALL _ADVPL_set_property(l_menubar_reference,"HELP_VISIBLE",FALSE)

    LET l_inform_reference = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar_reference)
    CALL _ADVPL_set_property(l_inform_reference,"EVENT","tst0002_inform")
    CALL _ADVPL_set_property(l_inform_reference,"CONFIRM_EVENT","tst0002_inform_confirm")
    CALL _ADVPL_set_property(l_inform_reference,"CANCEL_EVENT","tst0002_inform_cancel")

    LET l_print_reference = _ADVPL_create_component(NULL,"LPRINTBUTTON",l_menubar_reference)
    CALL _ADVPL_set_property(l_print_reference,"EVENT","tst0002_print")

    {
    LET l_process_reference = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar_reference)
    CALL _ADVPL_set_property(l_process_reference,"EVENT","tst0002_process")
    }

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar_reference)

    #CRIACAO DOS COMPONENTES
    LET l_panel_reference = _ADVPL_create_component(NULL,"LPANEL",m_dialog_reference)
    CALL _ADVPL_set_property(l_panel_reference,"ALIGN","CENTER")

    CALL tst0002_create_fields(l_panel_reference)

    CALL tst0002_enable_fields(FALSE)

    CALL _ADVPL_set_property(m_dialog_reference,"ACTIVATE",TRUE)
END FUNCTION

#---------------------------------------------------#
FUNCTION tst0002_create_fields(l_container_reference)
#---------------------------------------------------#
    DEFINE l_container_reference VARCHAR(10)
    DEFINE l_panel_reference     VARCHAR(10)
    DEFINE l_layout_reference    VARCHAR(10)
    DEFINE l_tabcolumn_reference VARCHAR(10)

    LET l_panel_reference = _ADVPL_create_component(NULL,"LPANEL",l_container_reference)
    CALL _ADVPL_set_property(l_panel_reference,"ALIGN","CENTER")

    LET l_layout_reference = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference)
    CALL _ADVPL_set_property(l_layout_reference,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout_reference,"EXPANSIBLE",TRUE)

    LET m_grid_reference = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout_reference)
    CALL _ADVPL_set_property(m_grid_reference,"ALIGN","CENTER")

    LET l_tabcolumn_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_grid_reference)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"HEADER","* Grupo")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDIT_PROPERTY","LENGTH",8)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDIT_PROPERTY","PICTURE","@&")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDIT_PROPERTY","VALID","tst0001_grupo_valid")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"VARIABLE","grupo")

    LET l_tabcolumn_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_grid_reference)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"BEFORE_EDIT_EVENT","tst0002_zoom_log_grupos")

    LET l_tabcolumn_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_grid_reference)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"HEADER","Descrição grupo")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"VARIABLE","des_grupo")

    CALL _ADVPL_set_property(m_grid_reference,"SET_ROWS",ma_log_usu_grupos,1)
END FUNCTION

#--------------------------------------#
FUNCTION tst0002_enable_fields(l_enable)
#--------------------------------------#
    DEFINE l_enable SMALLINT

    CALL _ADVPL_set_property(m_grid_reference,"EDITABLE",l_enable)
END FUNCTION

#-----------------------#
FUNCTION tst0002_inform()
#-----------------------#
    INITIALIZE ma_log_usu_grupos TO NULL

    CALL tst0002_enable_fields(TRUE)
    CALL _ADVPL_set_property(m_grid_reference,"ITEM_COUNT",1)
END FUNCTION

#-------------------------------#
FUNCTION tst0002_inform_confirm()
#-------------------------------#
    CALL tst0002_enable_fields(FALSE)
    RETURN TRUE
END FUNCTION

#------------------------------#
FUNCTION tst0002_inform_cancel()
#------------------------------#
    CALL tst0002_enable_fields(FALSE)
    RETURN TRUE
END FUNCTION

#----------------------#
FUNCTION tst0002_print()
#----------------------#
    IF  NOT LOG_question("Deseja executar o processamento?") THEN
        RETURN FALSE
    END IF

    #http://tdn.totvs.com.br/display/lg/LOG_progresspopup_start
    CALL LOG_progresspopup_start("Gerando relatório","tst0002_print_confirm","PROCESS")
END FUNCTION

#------------------------------#
FUNCTION tst0002_print_confirm()
#------------------------------#
    DEFINE l_status SMALLINT

    LET l_status = StartReport("tst0002_process_report","tst0002","Grupos por Usuário",80,TRUE,TRUE)

    RETURN l_status
END FUNCTION

#--------------------------------------------#
FUNCTION tst0002_process_report(l_report_file)
#--------------------------------------------#
    DEFINE l_report_file CHAR(300)

    DEFINE l_ind   SMALLINT
    DEFINE l_count SMALLINT

    #*** ANTES DO START REPORT REPORT DO 4GL. ***
    LET m_page_length = ReportPageLength("tst0002")

    START REPORT tst0002_relat TO l_report_file

    LET l_count = _ADVPL_get_property(m_grid_reference,"ITEM_COUNT")

    CALL LOG_progresspopup_set_total("PROCESS",l_count)

    FOR l_ind = 1 TO l_count
        IF  NOT LOG_progresspopup_increment("PROCESS") THEN
            EXIT FOR
        END IF

        SLEEP 1

        OUTPUT TO REPORT tst0002_relat(ma_log_usu_grupos[l_ind].*)
    END FOR

    FINISH REPORT tst0002_relat

    CALL FinishReport("tst0002")
    
END FUNCTION

#--------------------------------#
FUNCTION tst0002_zoom_log_grupos()
#--------------------------------#
    DEFINE l_count SMALLINT
    DEFINE l_ind   SMALLINT

    INITIALIZE ma_zoom_log_grupos TO NULL

    IF  m_zoom_log_grupos_reference IS NULL THEN
        LET m_zoom_log_grupos_reference = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_log_grupos_reference,"ZOOM","zoom_log_grupos")
        CALL _ADVPL_set_property(m_zoom_log_grupos_reference,"ZOOM_TYPE",1)
        CALL _ADVPL_set_property(m_zoom_log_grupos_reference,"ARRAY_RECORD_RETURN",ma_zoom_log_grupos)

        #O ARRAY OF RECORD TEM QUE TER OS MESMOS CAMPOS DO ZOOM.
    END IF

    CALL _ADVPL_get_property(m_zoom_log_grupos_reference,"ACTIVATE")
    LET l_count = _ADVPL_get_property(m_zoom_log_grupos_reference,"ITEM_SELECTED")

    IF  l_count > 0 THEN
        FOR l_ind = 1 TO l_count
            LET ma_log_usu_grupos[l_ind].grupo     = ma_zoom_log_grupos[l_ind].grupo
            LET ma_log_usu_grupos[l_ind].des_grupo = ma_zoom_log_grupos[l_ind].des_grupo
        END FOR

        CALL _ADVPL_set_property(m_grid_reference,"ITEM_COUNT",l_count)
    END IF
END FUNCTION

#---------------------------------#
REPORT tst0002_relat(lr_log_grupos)
#---------------------------------#
    DEFINE lr_log_grupos RECORD
                             grupo     LIKE log_grupos.grupo,
                             des_grupo LIKE log_grupos.des_grupo
                         END RECORD

{
Empresa: XX

Grupo    Descrição grupo
-------- ----------------------------------
XXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
}
    OUTPUT
        TOP    MARGIN 0
        LEFT   MARGIN 0
        RIGHT  MARGIN 0
        BOTTOM MARGIN 0
        PAGE   LENGTH m_page_length
    ORDER EXTERNAL BY lr_log_grupos.grupo

    FORMAT

    PAGE HEADER
        CALL ReportPageHeader("tst0002")

        SKIP 1 LINE

        PRINT COLUMN 001,"Empresa: ",p_cod_empresa

        PRINT COLUMN 001,"Grupo    Descrição grupo"
        PRINT COLUMN 001,"-------- ----------------------------"

    ON EVERY ROW
        PRINT COLUMN 001,lr_log_grupos.grupo,
              COLUMN 010,lr_log_grupos.des_grupo

END REPORT
