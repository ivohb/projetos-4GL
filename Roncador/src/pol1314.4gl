#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1314                                                 #
# OBJETIVO: PERCENTUAL DE RATEIO POR TIPO DE DESPESA                #
# AUTOR...: IVO                                                     #
# DATA....: 28/11/16                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_den_empresa   LIKE empresa.den_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003)
           
END GLOBALS

DEFINE m_den_empresa     LIKE empresa.den_empresa,
       m_nom_despesa     LIKE tipo_despesa.nom_tip_despesa,
       m_nom_fornec      LIKE fornecedor.raz_social,
       m_nom_cent_cust   LIKE cad_cc.nom_cent_cust

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_ceo             VARCHAR(10),
       m_lupa_ceo        VARCHAR(10),
       m_zoom_ceo        VARCHAR(10),
       m_deo             VARCHAR(10),
       m_versao          VARCHAR(10),
       m_tip_desp        VARCHAR(10),
       m_lupa_desp       VARCHAR(10),
       m_zoom_desp       VARCHAR(10),
       m_nom_desp        VARCHAR(10),
       m_cod_fornec      VARCHAR(10),
       m_lupa_fornec     VARCHAR(10),
       m_zoom_fornec     VARCHAR(10),
       m_raz_social      VARCHAR(10),
       m_lupa_portador   VARCHAR(10),
       m_zoom_portador   VARCHAR(10),
       m_nom_portador    VARCHAR(10),
       m_timesheet       VARCHAR(10),
       m_situacao        VARCHAR(10),
       m_dat_liberac     VARCHAR(10),
       m_aprovantes      VARCHAR(10),
       m_construct       VARCHAR(10),
       m_browse          VARCHAR(10)       

DEFINE mr_cabec          RECORD
       cod_emp_orig      VARCHAR(02),
       den_emp_orig      VARCHAR(40),
       versao            INTEGER,
       cod_tip_desp      DECIMAL(4,0),
       nom_tip_despesa   CHAR(30),
       cod_fornecedor    CHAR(15),
       raz_social        CHAR(40),
       nom_portador      CHAR(36),
       timesheet         CHAR(01),
       situacao          CHAR(01),
       dat_liberac       CHAR(10),
       aprovantes        CHAR(80)     
END RECORD

DEFINE ma_itens          ARRAY[300] OF RECORD
       cod_emp_dest      CHAR(02),
       den_emp_dest      VARCHAR(40),
       cod_cent_cust     DECIMAL(4,0),
       nom_cent_cust     CHAR(30),
       cod_aen           CHAR(08),
       den_aen           CHAR(30),
       pct_rateio        DECIMAL(5,2)
END RECORD

DEFINE m_zoom_ced        VARCHAR(10),
       m_zoom_ccc        VARCHAR(10),
       m_zoom_aen        VARCHAR(10)

DEFINE m_ies_cons        SMALLINT,
       m_ies_inc         SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ind             INTEGER,
       m_dat_atu         CHAR(10),
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_par_aen         CHAR(01),
       m_lin_pord        DECIMAL(2,0),
       m_lin_recei       DECIMAL(2,0),
       m_seg_merc        DECIMAL(2,0),
       m_cla_uso         DECIMAL(2,0),
       m_den_aen         CHAR(30),
       m_num_rateio      INTEGER,
       m_num_rateioa     INTEGER,
       m_carregando      SMALLINT,
       m_qtd_linha       INTEGER,
       m_qtd_aprov       INTEGER,
       m_des_portador    CHAR(36)

#-----------------#
FUNCTION pol1314()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 11

   LET g_tipo_sgbd = LOG_getCurrentDBType()
   
   LET p_versao = "pol1314-12.00.09  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1314_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1314_menu()#
#----------------------#

    DEFINE l_menubar,
           l_panel,
           l_create,
           l_update,
           l_find,
           l_first,
           l_previous,
           l_next,
           l_last,
           l_delete,
           l_aprovar,
           l_versao  VARCHAR(10),
           l_titulo  VARCHAR(80)
    
    CALL pol1314_limpa_campos()
    LET l_titulo = "RATEIO POR TIPO DE DESPESA - ", p_versao
 
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1314_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1314_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1314_create_cancel")
    
    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1314_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1314_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1314_update_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1314_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1314_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1314_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1314_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1314_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1314_delete")

    LET l_aprovar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_aprovar,"IMAGE","APROVAREX") 
    CALL _ADVPL_set_property(l_aprovar,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_aprovar,"EVENT","pol1314_aprovar")

    LET l_versao = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_versao,"IMAGE","NOVA_VERSAO")
    CALL _ADVPL_set_property(l_versao,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_versao,"EVENT","pol1314_nova_versao")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1314_cria_campos(l_panel)
    CALL pol1314_cria_grade(l_panel)

    CALL pol1314_ativa_desativa(FALSE)
    CALL pol1314_set_emp_orig()

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#------------------------------#
FUNCTION pol1314_set_emp_orig()#
#------------------------------#

    LET mr_cabec.cod_emp_orig = p_cod_empresa
    CALL pol1314_le_empresa(mr_cabec.cod_emp_orig) RETURNING p_status
    LET mr_cabec.den_emp_orig = m_den_empresa

END FUNCTION

#----------------------------------------#
FUNCTION pol1314_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_campos          VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",140)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa origem:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_ceo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_ceo,"POSITION",140,10)     
    CALL _ADVPL_set_property(m_ceo,"LENGTH",2)
    CALL _ADVPL_set_property(m_ceo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_ceo,"VARIABLE",mr_cabec,"cod_emp_orig")
    CALL _ADVPL_set_property(m_ceo,"PICTURE","@!")
    CALL _ADVPL_set_property(m_ceo,"VALID","pol1314_valida_emp_orig")

    LET m_lupa_ceo = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_ceo,"POSITION",180,10)     
    CALL _ADVPL_set_property(m_lupa_ceo,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_ceo,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_ceo,"CLICK_EVENT","pol1314_zoom_emp_orig")
    
    LET m_deo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_deo,"POSITION",220,10)     
    CALL _ADVPL_set_property(m_deo,"LENGTH",40) 
    CALL _ADVPL_set_property(m_deo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_deo,"VARIABLE",mr_cabec,"den_emp_orig")
    CALL _ADVPL_set_property(m_deo,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,35)     
    CALL _ADVPL_set_property(l_label,"TEXT","Tip de despesa:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_tip_desp = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_tip_desp,"POSITION",140,35)     
    CALL _ADVPL_set_property(m_tip_desp,"LENGTH",4,0)
    CALL _ADVPL_set_property(m_tip_desp,"VARIABLE",mr_cabec,"cod_tip_desp")
    CALL _ADVPL_set_property(m_tip_desp,"PICTURE","@E ####")
    CALL _ADVPL_set_property(m_tip_desp,"VALID","pol1314_valida_tip_desp")

    LET m_lupa_desp = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_desp,"POSITION",180,35)     
    CALL _ADVPL_set_property(m_lupa_desp,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_desp,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_desp,"CLICK_EVENT","pol1314_zoom_tip_desp")
    
    LET m_nom_desp = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_nom_desp,"POSITION",220,35)     
    CALL _ADVPL_set_property(m_nom_desp,"LENGTH",30) 
    CALL _ADVPL_set_property(m_nom_desp,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_nom_desp,"VARIABLE",mr_cabec,"nom_tip_despesa")
    CALL _ADVPL_set_property(m_nom_desp,"CAN_GOT_FOCUS",FALSE)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,60)     
    CALL _ADVPL_set_property(l_label,"TEXT","C�d fornecedor:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,FALSE,FALSE)

    LET m_cod_fornec = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_cod_fornec,"POSITION",140,60)     
    CALL _ADVPL_set_property(m_cod_fornec,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_fornec,"VARIABLE",mr_cabec,"cod_fornecedor")
    CALL _ADVPL_set_property(m_cod_fornec,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_fornec,"VALID","pol1314_valida_fornec")

    LET m_lupa_fornec = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_fornec,"POSITION",280,60)     
    CALL _ADVPL_set_property(m_lupa_fornec,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_fornec,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_fornec,"CLICK_EVENT","pol1314_zoom_fornec")
    
    LET m_raz_social = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_raz_social,"POSITION",320,60)     
    CALL _ADVPL_set_property(m_raz_social,"LENGTH",40) 
    CALL _ADVPL_set_property(m_raz_social,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_raz_social,"VARIABLE",mr_cabec,"raz_social")
    CALL _ADVPL_set_property(m_raz_social,"CAN_GOT_FOCUS",FALSE)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,85)     
    CALL _ADVPL_set_property(l_label,"TEXT","     TimeSheet:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_timesheet = _ADVPL_create_component(NULL,"LCHECKBOX",l_panel)
    CALL _ADVPL_set_property(m_timesheet,"POSITION",140,85)     
    CALL _ADVPL_set_property(m_timesheet,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_timesheet,"VARIABLE",mr_cabec,"timesheet")
    CALL _ADVPL_set_property(m_timesheet,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_timesheet,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_timesheet,"VALID","pol1314_valida_timesheet")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",170,85)     
    CALL _ADVPL_set_property(l_label,"TEXT","Libera��o:")    
    
    LET m_dat_liberac = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_dat_liberac,"POSITION",230,85)     
    CALL _ADVPL_set_property(m_dat_liberac,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_dat_liberac,"VARIABLE",mr_cabec,"dat_liberac")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",340,85)     
    CALL _ADVPL_set_property(l_label,"TEXT","Vers�o:")    

    LET m_versao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_versao,"POSITION",390,85)     
    CALL _ADVPL_set_property(m_versao,"LENGTH",2)
    CALL _ADVPL_set_property(m_versao,"VARIABLE",mr_cabec,"versao")
    CALL _ADVPL_set_property(m_versao,"EDITABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",430,85)     
    CALL _ADVPL_set_property(l_label,"TEXT","Status:")    

    LET m_situacao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_situacao,"POSITION",476,85)     
    CALL _ADVPL_set_property(m_situacao,"LENGTH",1)
    CALL _ADVPL_set_property(m_situacao,"VARIABLE",mr_cabec,"situacao")
    CALL _ADVPL_set_property(m_situacao,"EDITABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",510,85)     
    CALL _ADVPL_set_property(l_label,"TEXT","Aprovantes:")    

    LET m_aprovantes = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_aprovantes,"POSITION",580,85)     
    CALL _ADVPL_set_property(m_aprovantes,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_aprovantes,"VARIABLE",mr_cabec,"aprovantes")

END FUNCTION

#---------------------------------------#
FUNCTION pol1314_cria_grade(l_container)#
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
    CALL _ADVPL_set_property(m_browse,"BEFORE_ADD_ROW_EVENT","pol1314_add_linha")
    CALL _ADVPL_set_property(m_browse,"AFTER_ROW_EVENT","pol1314_after_linha")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Empresa dest")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_emp_dest")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",2)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1314_ck_emp_dest")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1314_zoom_emp_dest")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome empresa")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",270)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_emp_dest")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cent custo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cent_cust")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",4,0)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ####")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1314_ck_cent_cust")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1314_zoom_cent_cust")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome cent custo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",280)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_cent_cust")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cod AEN")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_aen")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",8,0)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1314_ck_aen")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1314_zoom_aen")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome AEN")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",250)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_aen")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","% Rateio")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pct_rateio")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",5,2)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ###.##")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1314_ck_pct")
  
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CANCEL_EX")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Excluir")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER_CLICK_EVENT","pol1314_del_linha")
    
    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",TRUE)
    CALL _ADVPL_set_property(m_browse,"CLEAR")


END FUNCTION

#-----------------------------#
FUNCTION pol1314_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_itens TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1314_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   IF m_opcao = 'M' THEN
      #CALL _ADVPL_set_property(m_ceo,"EDITABLE",FALSE)
      #CALL _ADVPL_set_property(m_lupa_ceo,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_tip_desp,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_lupa_desp,"EDITABLE",FALSE)
   ELSE      
      #CALL _ADVPL_set_property(m_ceo,"EDITABLE",l_status)
      #CALL _ADVPL_set_property(m_lupa_ceo,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_tip_desp,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_lupa_desp,"EDITABLE",l_status)
   END IF
   
   CALL _ADVPL_set_property(m_cod_fornec,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_fornec,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_timesheet,"EDITABLE",l_status)

   CALL _ADVPL_set_property(m_browse,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",l_status)
   

END FUNCTION

#------------------------------------#
FUNCTION pol1314_le_par_cap(l_codigo)#
#------------------------------------#

   DEFINE l_codigo        CHAR(02)
   
   SELECT par_ies
     INTO m_par_aen
     FROM par_cap_pad
    WHERE cod_empresa = l_codigo
      AND cod_parametro = 'ies_area_linha_neg'

   IF STATUS <> 0 THEN
      LET m_par_aen = 'N'
   END IF
   
   IF m_par_aen IS NULL OR m_par_aen = ' ' THEN
      LET m_par_aen = 'N'
   END IF
   
END FUNCTION      

#--------------------------------#
FUNCTION pol1314_ck_cap(l_codigo)#
#--------------------------------#

   DEFINE l_codigo     CHAR(02)
   

RETURN TRUE
   
   LET m_msg = ''
   
   SELECT COUNT(cod_empresa_destin)
     INTO m_count
     FROM emp_orig_destino
    WHERE cod_empresa_orig = l_codigo

   IF m_count = 0 THEN
      LET m_msg = 'Empresa ', l_codigo, ' n�o tem contas a pagar.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1314_create()
#-----------------------#
    
    CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
    
    LET m_opcao = 'I'    
    CALL pol1314_limpa_campos()
    CALL pol1314_set_emp_orig()

    CALL _ADVPL_set_property(m_browse,"CLEAR")
    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)   
    CALL pol1314_ativa_desativa(TRUE)
    LET m_ies_inc = FALSE
    LET mr_cabec.versao = 1
    LET mr_cabec.situacao = 'B'
    CALL _ADVPL_set_property(m_tip_desp,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1314_create_confirm()
#-------------------------------#
   
   DEFINE l_linha       INTEGER
                     
   IF  mr_cabec.cod_tip_desp IS NULL THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o tipo de despesa")
       CALL _ADVPL_set_property(m_tip_desp,"GET_FOCUS")
       RETURN FALSE
   END IF
   
   IF pol1314_grade_existe() THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       CALL _ADVPL_set_property(m_ceo,"GET_FOCUS")
       RETURN FALSE
   END IF
      
   CALL log085_transacao("BEGIN")

   IF NOT pol1314_insere_orig() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   IF NOT pol1314_grava_dest() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF     
   
   CALL log085_transacao("COMMIT")
                  
   CALL pol1314_ativa_desativa(FALSE)
   
   LET m_ies_inc = TRUE
   LET m_qtd_aprov = 0
   LET m_num_rateioa = m_num_rateio
   LET m_opcao = NULL
   LET m_ies_cons = FALSE

   RETURN TRUE
        
END FUNCTION

#------------------------------#
FUNCTION pol1314_grade_existe()#
#------------------------------#
   
   IF mr_cabec.cod_fornecedor IS NULL THEN
      LET m_msg = 'J� existe grade para a empresa e tipo de despesa informados.'
      SELECT 1
        FROM rateio_tip_desp_orig912
       WHERE empresa_orig = mr_cabec.cod_emp_orig
         AND cod_tip_desp = mr_cabec.cod_tip_desp
         AND cod_fornecedor IS NULL
   ELSE
      LET m_msg = 'J� existe grade para a empresa/tip despesa/fornecedor informados.'
      SELECT 1
        FROM rateio_tip_desp_orig912
       WHERE empresa_orig = mr_cabec.cod_emp_orig
         AND cod_tip_desp = mr_cabec.cod_tip_desp
         AND cod_fornecedor = mr_cabec.cod_fornecedor
   END IF
   
   IF STATUS = 100 THEN
   ELSE
      IF STATUS = 0 THEN
      ELSE
         CALL log003_err_sql('SELECT','rateio_tip_desp_orig912')
         LET m_msg = 'Erro ',STATUS, ' lendo tabela rateio_tip_desp_orig912.'
      END IF
      RETURN TRUE
   END IF

   {SELECT COUNT(cod_tip_desp)
     INTO m_count
     FROM rateio_tip_desp_orig912
    WHERE empresa_orig <> mr_cabec.cod_emp_orig
      AND cod_tip_desp = mr_cabec.cod_tip_desp

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','rateio_tip_desp_orig912')
      LET m_msg = 'Erro ',STATUS, ' lendo tabela rateio_tip_desp_orig912.'
      RETURN TRUE
   END IF

   IF m_count > 0 THEN
      LET m_msg = 'O tipo de despesa informado j� est� cadstrado para outra empresa.'
      RETURN TRUE
   END IF}
   
   RETURN FALSE

END FUNCTION

#-----------------------------#
FUNCTION pol1314_insere_orig()#
#-----------------------------#

   DEFINE l_ind    SMALLINT
      
   SELECT MAX(num_rateio)
     INTO m_num_rateio
     FROM rateio_tip_desp_orig912

   IF STATUS <> 0 THEN     
      CALL log003_err_sql('SELECT','rateio_tip_desp_orig912')
      RETURN FALSE
   END IF
   
   IF m_num_rateio IS NULL THEN
      LET m_num_rateio = 0
   END IF
   
   LET m_num_rateio = m_num_rateio + 1
   
   INSERT INTO rateio_tip_desp_orig912(    
        num_rateio,
        empresa_orig, 
        versao,              
        cod_tip_desp,        
        cod_fornecedor,     
        timesheet,           
        situacao)
      VALUES(
          m_num_rateio,
          mr_cabec.cod_emp_orig,
          mr_cabec.versao,
          mr_cabec.cod_tip_desp,
          mr_cabec.cod_fornecedor,
          mr_cabec.timesheet,
          mr_cabec.situacao)
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','rateio_tip_desp_orig912')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION               

#----------------------------#
FUNCTION pol1314_grava_dest()#
#----------------------------#
   
   DEFINE l_info        SMALLINT,
          l_linha       SMALLINT,
          l_pct         DECIMAL(6,2)
   
   LET l_info = FALSE
   LET l_pct = 0

   IF  mr_cabec.timesheet = 'S' THEN
       CALL _ADVPL_set_property(m_browse,"CLEAR")
       INITIALIZE ma_itens TO NULL
       RETURN TRUE
   END IF

   LET m_qtd_linha = _ADVPL_get_property(m_browse,"ITEM_COUNT")
   
   FOR l_linha = 1 TO m_qtd_linha
   
       IF ma_itens[l_linha].pct_rateio IS NULL OR 
             ma_itens[l_linha].pct_rateio <= 0 THEN
          EXIT FOR
       END IF

       IF NOT pol1314_checa_linha(l_linha) THEN
          RETURN FALSE
       END IF
      
      LET l_pct = l_pct + ma_itens[l_linha].pct_rateio

      IF l_pct > 100 THEN
         LET m_msg = 'A somat�ria da coluna Rateio ultrapassou 100%'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
       
      LET l_info = TRUE
       
      IF NOT pol1314_insere_dest(l_linha) THEN
         RETURN FALSE
      END IF
       
   END FOR
      
   IF NOT l_info AND mr_cabec.timesheet = 'N' THEN
      LET m_msg = 'Informe pelo menos \n uma empresa destino.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_browse,"REMOVE_EMPTY_ROWS")
   
   RETURN TRUE

END FUNCTION
   
#----------------------------------#
FUNCTION pol1314_insere_dest(l_ind)#
#----------------------------------#

   DEFINE l_ind    SMALLINT
      
   INSERT INTO rateio_tip_desp_dest912(   
     num_rateio, 
     empresa_dest, 
     cod_cent_cust,
     cod_aen,      
     pct_rateio)
   VALUES(
       m_num_rateio,
       ma_itens[l_ind].cod_emp_dest,
       ma_itens[l_ind].cod_cent_cust,
       ma_itens[l_ind].cod_aen,
       ma_itens[l_ind].pct_rateio)
      
   IF STATUS <> 0 THEN
      CALL log0030_mensagem(STATUS,'info')
      CALL log003_err_sql('INSERT','rateio_tip_desp_dest912')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION               

#-------------------------------#
FUNCTION pol1314_create_cancel()#
#-------------------------------#

    CALL pol1314_ativa_desativa(FALSE)
    CALL pol1314_limpa_campos()
    CALL _ADVPL_set_property(m_browse,"CLEAR")
    LET m_opcao = NULL
    
    RETURN TRUE
        
END FUNCTION

#---------------------------------#
FUNCTION pol1314_valida_emp_orig()#
#---------------------------------#
    
    CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
    IF  mr_cabec.cod_emp_orig IS NULL THEN
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a empresa origem.")
        RETURN FALSE
    END IF
      
   IF NOT pol1314_le_empresa(mr_cabec.cod_emp_orig) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1314_ck_cap(mr_cabec.cod_emp_orig) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
        
   LET mr_cabec.den_emp_orig = m_den_empresa
   CALL _ADVPL_set_property(m_tip_desp,"GET_FOCUS")   
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1314_le_empresa(l_codigo)#
#------------------------------------#

   DEFINE l_codigo LIKE empresa.cod_empresa  
   
   LET m_msg = ''
   
   SELECT den_empresa
     INTO m_den_empresa
     FROM empresa
    WHERE cod_empresa = l_codigo

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      LET m_den_empresa = ''
      IF STATUS = 100 THEN
         LET m_msg = 'Empresa inexistente.'    
      ELSE
         CALL log003_err_sql('SELECT','empresa')
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#-------------------------------#
FUNCTION pol1314_zoom_emp_orig()#
#-------------------------------#
    
   DEFINE l_codigo      LIKE empresa.cod_empresa,
          l_descricao   LIKE empresa.den_empresa
          
   IF  m_zoom_ceo IS NULL THEN
       LET m_zoom_ceo = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_ceo,"ZOOM","zoom_empresa")
   END IF

   CALL _ADVPL_get_property(m_zoom_ceo,"ACTIVATE")

   LET l_codigo    = _ADVPL_get_property(m_zoom_ceo,"RETURN_BY_TABLE_COLUMN","empresa","cod_empresa")
   LET l_descricao = _ADVPL_get_property(m_zoom_ceo,"RETURN_BY_TABLE_COLUMN","empresa","den_empresa")

   IF l_codigo IS NOT NULL THEN
      LET mr_cabec.cod_emp_orig = l_codigo
      LET mr_cabec.den_emp_orig = l_descricao
   END IF
    
END FUNCTION

#---------------------------------#
FUNCTION pol1314_valida_tip_desp()#
#---------------------------------#
    
    CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
    IF  mr_cabec.cod_tip_desp IS NULL THEN
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o tipo de despesa.")
        RETURN FALSE
    END IF
      
   IF NOT pol1314_le_despesa(mr_cabec.cod_tip_desp) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
        
   LET mr_cabec.nom_tip_despesa = m_nom_despesa
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1314_le_despesa(l_codigo)#
#------------------------------------#

   DEFINE l_codigo LIKE tipo_despesa.cod_tip_despesa
   
   LET m_msg = ''
   
   SELECT nom_tip_despesa
     INTO m_nom_despesa
     FROM tipo_despesa
    WHERE cod_empresa = mr_cabec.cod_emp_orig
      AND cod_tip_despesa = l_codigo

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      LET m_nom_desp = ''
      IF STATUS = 100 THEN
         LET m_msg = 'Tipo de despesa inexistente.'    
      ELSE
         CALL log003_err_sql('SELECT','tipo_despesa')
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#-------------------------------#
FUNCTION pol1314_zoom_tip_desp()#
#-------------------------------#
    
   DEFINE l_codigo       LIKE tipo_despesa.cod_tip_despesa,
          l_descricao    LIKE tipo_despesa.nom_tip_despesa,
          l_where_clause CHAR(300)
          
   IF  m_zoom_desp IS NULL THEN
       LET m_zoom_desp = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_desp,"ZOOM","zoom_tipo_despesa")
   END IF

   LET l_where_clause = " tipo_despesa.cod_empresa = '", mr_cabec.cod_emp_orig CLIPPED,"' "
   CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)

   CALL _ADVPL_get_property(m_zoom_desp,"ACTIVATE")
 
   LET l_codigo    = _ADVPL_get_property(m_zoom_desp,"RETURN_BY_TABLE_COLUMN","tipo_despesa","cod_tip_despesa")
   LET l_descricao = _ADVPL_get_property(m_zoom_desp,"RETURN_BY_TABLE_COLUMN","tipo_despesa","nom_tip_despesa")

   IF l_codigo IS NOT NULL THEN
      LET mr_cabec.cod_tip_desp = l_codigo
      LET mr_cabec.nom_tip_despesa = l_descricao
   END IF
    
END FUNCTION

#-------------------------------#
FUNCTION pol1314_valida_fornec()#
#-------------------------------#
    
    CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
    IF  mr_cabec.cod_fornecedor IS NULL THEN
        RETURN TRUE
    END IF
      
   IF NOT pol1314_le_fornecedor(mr_cabec.cod_fornecedor) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
        
   LET mr_cabec.raz_social = m_nom_fornec
   
   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION pol1314_le_fornecedor(l_codigo)#
#---------------------------------------#

   DEFINE l_codigo LIKE fornecedor.cod_fornecedor
   
   LET m_msg = ''
   
   SELECT raz_social
     INTO m_nom_fornec
     FROM fornecedor
    WHERE cod_fornecedor = l_codigo

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      LET m_nom_fornec = ''
      IF STATUS = 100 THEN
         LET m_msg = 'Fornecedor inexistente.'    
      ELSE
         CALL log003_err_sql('SELECT','fornecedor')
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#-----------------------------#
FUNCTION pol1314_zoom_fornec()#
#-----------------------------#
    
   DEFINE l_codigo      LIKE fornecedor.cod_fornecedor,
          l_descricao   LIKE fornecedor.raz_social
          
   IF  m_zoom_fornec IS NULL THEN
       LET m_zoom_fornec = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_fornec,"ZOOM","zoom_fornecedor")
   END IF

   CALL _ADVPL_get_property(m_zoom_fornec,"ACTIVATE")

   LET l_codigo    = _ADVPL_get_property(m_zoom_fornec,"RETURN_BY_TABLE_COLUMN","fornecedor","cod_fornecedor")
   LET l_descricao = _ADVPL_get_property(m_zoom_fornec,"RETURN_BY_TABLE_COLUMN","fornecedor","raz_social")

   IF l_codigo IS NOT NULL THEN
      LET mr_cabec.cod_fornecedor = l_codigo
      LET mr_cabec.raz_social = l_descricao
   END IF
    
END FUNCTION

#----------------------------------#
FUNCTION pol1314_valida_timesheet()#
#----------------------------------#

   IF  mr_cabec.timesheet = 'S' THEN
       CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
   ELSE
       LET m_qtd_linha = _ADVPL_get_property(m_browse,"ITEM_COUNT")
       IF m_qtd_linha = 0 THEN
          CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
       END IF
       CALL _ADVPL_set_property(m_browse,"EDITABLE",TRUE) 
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1314_ck_emp_dest()#
#-----------------------------#

   DEFINE l_lin_atu       SMALLINT,
          l_codigo        CHAR(02)
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
      
   LET ma_itens[l_lin_atu].den_emp_dest = ''
   
   LET l_codigo = ma_itens[l_lin_atu].cod_emp_dest
   
   IF l_codigo IS NULL THEN
      RETURN TRUE
   END IF

   IF ma_itens[l_lin_atu].cod_emp_dest = mr_cabec.cod_emp_orig THEN
      LET m_msg = 'Empresa destino n�o pode ser igual a empresa origem.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT pol1314_le_empresa(l_codigo) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET ma_itens[l_lin_atu].den_emp_dest = m_den_empresa
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1314_zoom_emp_dest()#
#-------------------------------#
    
   DEFINE l_codigo       LIKE empresa.cod_empresa,
          l_descricao    LIKE empresa.den_empresa,
          l_lin_atu      SMALLINT,
          l_where_clause CHAR(300)


   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
       
   IF  m_zoom_ced IS NULL THEN
       LET m_zoom_ced = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_ced,"ZOOM","zoom_empresa")
   END IF

   LET l_where_clause = " empresa.cod_empresa <> '",mr_cabec.cod_emp_orig CLIPPED,"' "
   CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)

   CALL _ADVPL_get_property(m_zoom_ced,"ACTIVATE")

   LET l_codigo    = _ADVPL_get_property(m_zoom_ced,"RETURN_BY_TABLE_COLUMN","empresa","cod_empresa")
   LET l_descricao = _ADVPL_get_property(m_zoom_ced,"RETURN_BY_TABLE_COLUMN","empresa","den_empresa")

   IF l_codigo IS NOT NULL THEN
      LET ma_itens[l_lin_atu].cod_emp_dest = l_codigo
      LET ma_itens[l_lin_atu].den_emp_dest = l_descricao
   END IF
    
END FUNCTION

#--------------------------------#
FUNCTION pol1314_zoom_cent_cust()#
#--------------------------------#
    
   DEFINE l_codigo      LIKE cad_cc.cod_cent_cust,
          l_descricao   LIKE cad_cc.nom_cent_cust,
          l_lin_atu     SMALLINT,
          l_where_clause CHAR(300),
          l_empresa      CHAR(02)

   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
       
   IF  m_zoom_ccc IS NULL THEN
       LET m_zoom_ccc = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_ccc,"ZOOM","zoom_centro_custo")
   END IF

   SELECT cod_empresa_plano
     INTO l_empresa
     FROM par_con
    WHERE cod_empresa = ma_itens[l_lin_atu].cod_emp_dest

   IF STATUS <> 0 THEN
      LET l_empresa = ma_itens[l_lin_atu].cod_emp_dest
   END IF
   
   IF l_empresa IS NULL THEN
      LET l_empresa = ma_itens[l_lin_atu].cod_emp_dest
   END IF
   
   LET l_where_clause = " cad_cc.cod_empresa = '",l_empresa CLIPPED,"' "
   CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)

   CALL _ADVPL_get_property(m_zoom_ccc,"ACTIVATE")

   LET l_codigo    = _ADVPL_get_property(m_zoom_ccc,"RETURN_BY_TABLE_COLUMN","cad_cc","cod_cent_cust")
   LET l_descricao = _ADVPL_get_property(m_zoom_ccc,"RETURN_BY_TABLE_COLUMN","cad_cc","nom_cent_cust")

   IF l_codigo IS NOT NULL THEN
      LET ma_itens[l_lin_atu].cod_cent_cust = l_codigo
      LET ma_itens[l_lin_atu].nom_cent_cust = l_descricao
   END IF
    
END FUNCTION

#------------------------------#
FUNCTION pol1314_ck_cent_cust()#
#------------------------------#

   DEFINE l_lin_atu       SMALLINT,
          l_codigo        LIKE cad_cc.cod_cent_cust
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
      
   LET ma_itens[l_lin_atu].nom_cent_cust = ''
   
   LET l_codigo = ma_itens[l_lin_atu].cod_cent_cust
   
   IF l_codigo IS NULL THEN
      RETURN TRUE
   END IF
   
   IF NOT pol1314_le_cad_cc(ma_itens[l_lin_atu].cod_emp_dest, l_codigo) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET ma_itens[l_lin_atu].nom_cent_cust = m_nom_cent_cust
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------------#
FUNCTION pol1314_le_cad_cc(l_emp, l_cust)#
#----------------------------------------#

   DEFINE l_emp       LIKE empresa.cod_empresa, 
          l_emp_plano LIKE empresa.cod_empresa, 
          l_cust      LIKE cad_cc.cod_cent_cust
   
   LET m_msg = ''
   
   SELECT cod_empresa_plano
     INTO l_emp_plano
     FROM par_con
    WHERE cod_empresa = l_emp

   IF STATUS <> 0 THEN
      LET l_emp_plano = l_emp
   END IF
   
   IF l_emp_plano IS NULL THEN
      LET l_emp_plano = l_emp
   END IF
   
   SELECT nom_cent_cust
     INTO m_nom_cent_cust
     FROM cad_cc
    WHERE cod_empresa = l_emp_plano
      AND cod_cent_cust = l_cust

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      LET m_nom_cent_cust = ''
      IF STATUS = 100 THEN
         LET m_msg = 'Centro de cudto inexistente.'    
      ELSE
         CALL log003_err_sql('SELECT','cad_cc')
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#--------------------------#
FUNCTION pol1314_zoom_aen()#
#--------------------------#

   DEFINE l_descricao    LIKE linha_prod.den_estr_linprod,
          l_codigo       CHAR(08),
          l_lin_atu      SMALLINT

   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   CALL pol1314_le_par_cap(ma_itens[l_lin_atu].cod_emp_dest)
   
   IF m_par_aen = 'N' THEN
      LET ma_itens[l_lin_atu].cod_aen = ''
      LET ma_itens[l_lin_atu].den_aen = ''
      LET m_msg = 'Empresa n�o utiliza AEN'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN 
   END IF

   CALL func008_zoom_area_linha() RETURNING l_codigo, l_descricao
   
    IF l_codigo IS NOT NULL THEN
       LET ma_itens[l_lin_atu].cod_aen = l_codigo
       LET ma_itens[l_lin_atu].den_aen = l_descricao
    END IF

END FUNCTION

#----------------------------#
FUNCTION pol1314_zoom_linha()#
#----------------------------#

    DEFINE l_codigo    CHAR(08),
           l_descricao CHAR(30),
           l_lin_atu   SMALLINT

   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
    
    IF  m_zoom_aen IS NULL THEN
        LET m_zoom_aen = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_aen,"ZOOM","zoom_aen")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_aen,"ACTIVATE")

    LET l_codigo    = _ADVPL_get_property(m_zoom_aen,"RETURN_BY_TABLE_COLUMN","linha_prod","cod_aen")
    LET l_descricao = _ADVPL_get_property(m_zoom_aen,"RETURN_BY_TABLE_COLUMN","linha_prod","den_estr_linprod")

    IF  l_codigo IS NOT NULL THEN
        LET ma_itens[l_lin_atu].cod_aen = l_codigo
        LET ma_itens[l_lin_atu].den_aen = l_descricao
    END IF

END FUNCTION

#------------------------#
FUNCTION pol1314_ck_aen()#
#------------------------#

   DEFINE l_lin_atu   SMALLINT

   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
    
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
   LET ma_itens[l_lin_atu].den_aen = ''
   
   CALL pol1314_le_par_cap(ma_itens[l_lin_atu].cod_emp_dest)
   
   IF m_par_aen = 'N' THEN
      LET ma_itens[l_lin_atu].cod_aen = ''
      RETURN TRUE
   END IF

   IF ma_itens[l_lin_atu].cod_aen IS NULL THEN
      RETURN TRUE
   END IF
       
   CALL pol1314_separa_aen(ma_itens[l_lin_atu].cod_aen)
   
   IF NOT pol1314_le_aen() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET ma_itens[l_lin_atu].den_aen = m_den_aen
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1314_ck_pct()#
#------------------------#

   DEFINE l_lin_atu   SMALLINT

   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
    
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
   IF ma_itens[l_lin_atu].pct_rateio IS NULL OR ma_itens[l_lin_atu].pct_rateio = 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Informe a % de rateio.')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#---------------------------------#
FUNCTION pol1314_separa_aen(l_cod)#
#---------------------------------#
   
   DEFINE l_cod      CHAR(08)
   
   LET m_lin_pord = l_cod[1,2]
   LET m_lin_recei = l_cod[3,4]
   LET m_seg_merc = l_cod[5,6]
   LET m_cla_uso = l_cod[7,8]

END FUNCTION

#------------------------#
FUNCTION pol1314_le_aen()#
#------------------------#
   
   LET m_msg = ''
   
   SELECT den_estr_linprod
     INTO m_den_aen
     FROM linha_prod
    WHERE cod_lin_prod =  m_lin_pord
      AND cod_lin_recei = m_lin_recei
      AND cod_seg_merc = m_seg_merc
      AND cod_cla_uso = m_cla_uso
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      LET m_den_aen = ''
      IF STATUS = 100 THEN
         LET m_msg = 'AEN inexistente no logix.'
      ELSE
         CALL log003_err_sql('SELECT','linha_prod')   
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#---------------------------#
FUNCTION pol1314_del_linha()#
#---------------------------#

   DEFINE l_lin_atu       INTEGER
   
   IF m_opcao IS NULL THEN
      RETURN TRUE
   END IF
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   CALL _ADVPL_set_property(m_browse,"REMOVE_ROW",l_lin_atu)
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ITEM_COUNT")
   
   IF l_lin_atu = 0 THEN
      CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
   END IF
         
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1314_add_linha()#
#---------------------------#

   DEFINE l_lin_atu       INTEGER

   IF m_carregando OR m_opcao IS NULL THEN
      RETURN TRUE
   END IF
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
      
   IF l_lin_atu <= 0 OR l_lin_atu IS NULL THEN
      RETURN TRUE
   END IF

   IF NOT pol1314_checa_linha(l_lin_atu) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1314_after_linha()#
#-----------------------------#

   DEFINE l_lin_atu       INTEGER

   IF m_carregando OR m_opcao IS NULL THEN
      RETURN TRUE
   END IF
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   
   IF l_lin_atu <= 0 OR l_lin_atu IS NULL THEN
      RETURN TRUE
   END IF

   IF ma_itens[l_lin_atu].cod_emp_dest IS NULL AND
      ma_itens[l_lin_atu].cod_cent_cust IS NULL AND
      ma_itens[l_lin_atu].cod_aen IS NULL AND
      (ma_itens[l_lin_atu].pct_rateio IS NULL OR
       ma_itens[l_lin_atu].pct_rateio = 0) THEN
      RETURN TRUE
   END IF
   
   IF NOT pol1314_checa_linha(l_lin_atu) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
   
#--------------------------------------#
FUNCTION pol1314_checa_linha(l_lin_atu)#
#--------------------------------------#

   DEFINE l_lin_atu       INTEGER
   
   IF ma_itens[l_lin_atu].cod_emp_dest IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a empresa destino.")
      RETURN FALSE
   END IF

   IF NOT pol1314_ck_cap(ma_itens[l_lin_atu].cod_emp_dest) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF ma_itens[l_lin_atu].cod_emp_dest = mr_cabec.cod_emp_orig THEN
      LET m_msg = 'Empresa destino n�o pode ser igual a empresa origem.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
       
   IF ma_itens[l_lin_atu].cod_cent_cust IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe centro de custo.")
      RETURN FALSE
   END IF
   
   CALL pol1314_le_par_cap(ma_itens[l_lin_atu].cod_emp_dest)

   IF m_par_aen = 'N' THEN
      LET ma_itens[l_lin_atu].cod_aen = ''
      LET ma_itens[l_lin_atu].den_aen = ''
   ELSE
      IF ma_itens[l_lin_atu].cod_aen IS NULL THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a AEN.")
         RETURN FALSE
      END IF
   END IF

   IF ma_itens[l_lin_atu].pct_rateio IS NULL OR
         ma_itens[l_lin_atu].pct_rateio <= 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o percentual do rateio.")
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#----------------------#
FUNCTION pol1314_find()#
#----------------------#

    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)
    
    CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
    LET m_num_rateioa = m_num_rateio
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","PESQUISA RATEIO")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","rateio_tip_desp_orig912","Rateio")
       #CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","rateio_tip_desp_orig912","empresa_orig","Empresa origem",1 {CHAR},2,0,"zoom_empresa")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","rateio_tip_desp_orig912","cod_tip_desp","Tip despesa",1 {INT},4,0,"zoom_tipo_despesa")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","rateio_tip_desp_orig912","cod_fornecedor","Fornecedor",1 {CHAR},15,0,"zoom_fornecedor")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","rateio_tip_desp_orig912","timesheet","TimeSheet",1 {CHAR},1,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF  l_status THEN
        LET l_where_clause = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_construct,"ORDER_BY")
        CALL pol1314_cria_cursor(l_where_clause,l_order_by)
    ELSE
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
    LET m_num_rateio = m_num_rateioa
    
END FUNCTION

#------------------------------------------------------#
FUNCTION pol1314_cria_cursor(l_where_clause,l_order_by)#
#------------------------------------------------------#
 
   DEFINE l_where_clause CHAR(800)
   DEFINE l_order_by     CHAR(200)

   DEFINE l_sql_stmt     CHAR(2000)

    IF  l_order_by IS NULL THEN
        LET l_order_by = "empresa_orig, cod_tip_desp"
    END IF

   LET l_sql_stmt = "SELECT num_rateio, empresa_orig, cod_tip_desp, cod_fornecedor ",
                     " FROM rateio_tip_desp_orig912 ",
                    " WHERE ", l_where_clause CLIPPED,
                    "   AND empresa_orig = '",p_cod_empresa,"' ",
                    " ORDER BY ", l_order_by

   PREPARE var_pesquisa FROM l_sql_stmt
    
   IF  Status <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","var_pesquisa")
       RETURN 
   END IF

   DECLARE cq_cons SCROLL CURSOR WITH HOLD FOR var_pesquisa

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE CURSOR","cq_cons")
       RETURN 
   END IF

   FREE var_pesquisa

   OPEN cq_cons

   IF  STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_cons")
       RETURN 
   END IF
   
   #LET m_ies_cons = FALSE
   
   FETCH cq_cons INTO m_num_rateio


   IF STATUS <> 0 THEN
      IF STATUS <> 100 THEN
         CALL log003_err_sql("FETCH CURSOR","cq_cons")
      ELSE
         LET m_msg = 'N�o a dados, para os argumentos informados.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN 
   END IF

    IF NOT pol1314_exibe_dados() THEN
       LET m_msg = 'Opera��o cancelada'
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN 
    END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
    
   LET m_ies_cons = TRUE
   LET m_ies_inc = FALSE
   
   LET m_num_rateioa = m_num_rateio
   
END FUNCTION

#-----------------------------#
FUNCTION pol1314_exibe_dados()#
#-----------------------------#

   DEFINE l_prod, l_recei, l_merc, l_uso CHAR(02),
          l_id   INTEGER
   
   LET m_excluiu = FALSE
   CALL pol1314_limpa_campos()

   SELECT empresa_orig,
          versao,
          cod_tip_desp,         
          cod_fornecedor,
          timesheet,
          situacao,
          dat_liberac
     INTO mr_cabec.cod_emp_orig,
          mr_cabec.versao,
          mr_cabec.cod_tip_desp,
          mr_cabec.cod_fornecedor,
          mr_cabec.timesheet,
          mr_cabec.situacao,
          mr_cabec.dat_liberac
    FROM rateio_tip_desp_orig912
   WHERE num_rateio = m_num_rateio

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','rateio_tip_desp_orig912:ED')
      RETURN FALSE 
   END IF
         
   CALL pol1314_le_empresa(mr_cabec.cod_emp_orig) RETURNING p_status
   LET mr_cabec.den_emp_orig = m_den_empresa

   CALL pol1314_le_despesa(mr_cabec.cod_tip_desp) RETURNING p_status
   LET mr_cabec.nom_tip_despesa = m_nom_despesa

   IF mr_cabec.cod_fornecedor IS NOT NULL THEN
      CALL pol1314_le_fornecedor(mr_cabec.cod_fornecedor) RETURNING p_status
      LET mr_cabec.raz_social = m_nom_fornec
   ELSE
      LET mr_cabec.raz_social = NULL
   END IF
   
   CALL pol1314_le_arpvantes()
   
   CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",TRUE)
   LET m_carregando = TRUE
   LET p_status = pol1314_le_itens()
   CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
   LET m_carregando = FALSE
   
   IF p_status THEN
      LET p_status = pol1315_ve_aprovacao()
   END IF
   
   RETURN p_status

END FUNCTION

#------------------------------#
FUNCTION pol1314_le_arpvantes()#
#------------------------------#
  
  DEFINE l_user        CHAR(08)
  
  DECLARE cq_aprovantes CURSOR FOR
   SELECT cod_user
     FROM rateio_aprovado_912
    WHERE num_rateio = m_num_rateio
  
  FOREACH cq_aprovantes INTO  l_user
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cq_aprovantes')
      EXIT FOREACH
   END IF 
   
   LET l_user = l_user CLIPPED, ';'
   LET mr_cabec.aprovantes = mr_cabec.aprovantes CLIPPED, ' ', l_user
  
  END FOREACH       

END FUNCTION   

#--------------------------#  
FUNCTION pol1314_le_itens()#
#--------------------------#
   
   DEFINE l_ind       SMALLINT
   
   INITIALIZE ma_itens TO NULL
   LET l_ind = 1
      
   DECLARE cq_itens CURSOR FOR
    SELECT empresa_dest, 
           cod_cent_cust,
           cod_aen,      
           pct_rateio   
      FROM rateio_tip_desp_dest912
     WHERE num_rateio = m_num_rateio
      ORDER BY empresa_dest, cod_cent_cust

   FOREACH cq_itens INTO 
      ma_itens[l_ind].cod_emp_dest,
      ma_itens[l_ind].cod_cent_cust,
      ma_itens[l_ind].cod_aen,
      ma_itens[l_ind].pct_rateio
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_itens')
         RETURN FALSE
      END IF
      
      CALL pol1314_le_empresa(ma_itens[l_ind].cod_emp_dest) RETURNING p_status
      LET ma_itens[l_ind].den_emp_dest = m_den_empresa

      CALL pol1314_le_cad_cc(
         ma_itens[l_ind].cod_emp_dest, ma_itens[l_ind].cod_cent_cust) RETURNING p_status                       
      LET ma_itens[l_ind].nom_cent_cust = m_den_empresa

      CALL pol1314_separa_aen(ma_itens[l_ind].cod_aen)
   
      CALL pol1314_le_aen() RETURNING p_status
      LET ma_itens[l_ind].den_aen = m_den_aen
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 300 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   FREE cq_itens
   
   LET l_ind = l_ind - 1

   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", l_ind)
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1315_ve_aprovacao()#
#------------------------------#

   SELECT COUNT(cod_user)
     INTO m_qtd_aprov
     FROM rateio_aprovado_912
    WHERE num_rateio = m_num_rateio
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','rateio_aprovado_912')
      RETURN FALSE
   END IF 
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1314_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'N�o h� consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1314_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1314_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_num_rateioa = m_num_rateio

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_num_rateio
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_num_rateio
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_num_rateio
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_num_rateio
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","N�o existem mais registros nesta dire��o.")
         END IF
         LET m_num_rateio = m_num_rateioa
         EXIT WHILE
      ELSE
         SELECT 1
           FROM rateio_tip_desp_orig912
          WHERE num_rateio = m_num_rateio
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1314_exibe_dados()
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
FUNCTION pol1314_first()#
#-----------------------#

   IF NOT pol1314_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1314_next()#
#----------------------#

   IF NOT pol1314_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1314_previous()#
#--------------------------#

   IF NOT pol1314_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1314_last()#
#----------------------#

   IF NOT pol1314_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1314_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM rateio_tip_desp_orig912
     WHERE num_rateio = m_num_rateio
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

#------------------------#
FUNCTION pol1314_update()#
#------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "N�o h� dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT m_ies_inc THEN
      IF NOT pol1314_ies_cons() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF m_qtd_aprov > 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Grade com aprova��es n�o podem ser modificada.")
      RETURN FALSE
   END IF
   
   IF NOT pol1314_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'M'    

   CALL pol1314_ativa_desativa(TRUE)
   CALL _ADVPL_set_property(m_cod_fornec,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1314_update_confirm()#
#--------------------------------#
   
   DEFINE l_ret   SMALLINT
   
   LET l_ret = FALSE
   
   IF pol1314_grava_orig() THEN
      IF pol1314_del_dest() THEN
         IF pol1314_grava_dest() THEN
            LET l_ret = TRUE
         END IF
      END IF
   END IF
         
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1314_ativa_desativa(FALSE)
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   LET m_opcao = NULL
   
   RETURN l_ret
   
END FUNCTION

#------------------------------#
FUNCTION pol1314_update_cancel()
#------------------------------#

   CALL log085_transacao("ROLLBACK")      
   CLOSE cq_prende
    
   LET m_num_rateio = m_num_rateioa
   CALL pol1314_exibe_dados()
   CALL pol1314_ativa_desativa(FALSE)
   LET m_opcao = NULL
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1314_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "N�o h� dados na tela a serem excluidos.")
      RETURN FALSE
   END IF

   IF NOT m_ies_inc THEN
      IF NOT pol1314_ies_cons() THEN
         RETURN FALSE
      END IF
   END IF
      
   IF m_qtd_aprov > 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Grade com aprova��es n�o podem ser exclu�da.")
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclus�o do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1314_prende_registro() THEN
      RETURN FALSE
   END IF

   LET l_ret = TRUE

   IF NOT pol1314_del_orig() THEN
      LET l_ret = FALSE
   END IF

   IF NOT pol1314_del_dest() THEN
      LET l_ret = FALSE
   END IF

   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1314_limpa_campos()
      LET m_excluiu = TRUE
      CALL _ADVPL_set_property(m_browse,"CLEAR")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF
         
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION

#--------------------------#
FUNCTION pol1314_del_orig()#
#--------------------------#

   DELETE FROM rateio_tip_desp_orig912
     WHERE num_rateio = m_num_rateio

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','rateio_tip_desp_orig912')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1314_del_dest()#
#--------------------------#
   
   DELETE FROM rateio_tip_desp_dest912
     WHERE num_rateio = m_num_rateio

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','rateio_tip_desp_dest912')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#          
FUNCTION pol1314_grava_orig()#
#----------------------------#
   
   UPDATE rateio_tip_desp_orig912
      SET cod_fornecedor = mr_cabec.cod_fornecedor,
          timesheet = mr_cabec.timesheet
    WHERE num_rateio = m_num_rateio

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','rateio_tip_desp_orig912')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1314_aprovar()#
#-------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "N�o h� dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT m_ies_inc THEN
      IF NOT pol1314_ies_cons() THEN
         RETURN FALSE
      END IF
   END IF

   IF mr_cabec.situacao = 'B' THEN
   ELSE
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Somente grade com status B podem ser aprovada.")
      RETURN FALSE
   END IF

   CALL pol1314_ve_possibilidade() RETURNING m_msg   

   IF m_msg IS NOT NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a aprova��o do rateio?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1314_prende_registro() THEN
      RETURN FALSE
   END IF

   IF NOT pol1314_grava_tabs() THEN
      CALL log085_transacao("ROLLBACK")
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   CALL log0030_mensagem('Aprova��o efetuada \n com sucesso.','info')
   
   LET m_qtd_aprov = 1
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1314_ve_possibilidade()#
#----------------------------------#
   
   DEFINE l_erro        CHAR(150),
          l_dat         CHAR(10)
   
   LET l_erro = NULL
   
   SELECT 1
     FROM aprovador_912
    WHERE cod_empresa = mr_cabec.cod_emp_orig 
      AND cod_user = p_user

   IF STATUS = 100 THEN
      LET l_erro = 'Voc� n�o est� autorizado a apovar grade da empresa ',mr_cabec.cod_emp_orig
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','aprovador_912')
         LET l_erro = 'Erro ',STATUS,' lendo tabela aprovador_912'
      END IF
   END IF 

   SELECT dat_aprovac
     INTO l_dat
     FROM rateio_aprovado_912
    WHERE num_rateio = m_num_rateio
      AND empresa_orig = mr_cabec.cod_emp_orig
      AND cod_user = p_user

   IF STATUS = 0 THEN
      LET l_erro = 'Voc� j� aprovou essa grade na data ', l_dat
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','aprovador_912')
         LET l_erro = 'Erro ',STATUS,' lendo tabela rateio_aprovado_912'
      END IF
   END IF 

   RETURN l_erro

END FUNCTION
   
#----------------------------#
FUNCTION pol1314_grava_tabs()#
#----------------------------#

   DEFINE l_empresa     CHAR(02),
          l_user        CHAR(08),
          l_liberar     SMALLINT

   LET m_dat_atu = TODAY   
   LET l_empresa = mr_cabec.cod_emp_orig       
   
   INSERT INTO rateio_aprovado_912(
      num_rateio,  
      empresa_orig,
      cod_user,    
      dat_aprovac)
   VALUES(
      m_num_rateio,
      l_empresa,
      p_user,
      m_dat_atu)
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','rateio_aprovado_912')
      LET m_msg = 'Erro ',STATUS,' inserindo dados na tabela rateio_aprovado_912'
      RETURN FALSE
   END IF 
   
   CALL pol1314_le_arpvantes()
   
   {LET l_liberar = TRUE
   
   DECLARE cq_aprov CURSOR FOR
    SELECT cod_user 
      FROM aprovador_912
     WHERE cod_empresa = l_empresa
   
   FOREACH cq_aprov INTO l_user
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_aprov')
         LET m_msg = 'Erro ',STATUS,' lendo dados da tabela aprovador_912'
         RETURN FALSE
      END IF 
      
     SELECT 1
       FROM rateio_aprovado_912
      WHERE num_rateio = m_num_rateio
        AND empresa_orig = l_empresa
        AND cod_user = l_user
      
      IF STATUS = 100 THEN
         LET l_liberar = FALSE
         EXIT FOREACH
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','rateio_aprovado_912')
            LET m_msg = 'Erro ',STATUS,' lendo aprova��es da tabela rateio_aprovado_912'
            RETURN FALSE
         END IF
      END IF 
   
   END FOREACH
         
   IF NOT l_liberar THEN
      RETURN TRUE
   END IF}

   IF NOT pol1314_atu_rateio('A') THEN
      RETURN FALSE
   END IF
   
   IF mr_cabec.versao > 1 THEN
      IF NOT pol1314_atu_versao_ant() THEN
         RETURN FALSE
      END IF
   END IF

   LET mr_cabec.situacao = 'A'
   LET mr_cabec.dat_liberac = m_dat_atu
   
   RETURN TRUE
   
END FUNCTION

#------------------------------------#          
FUNCTION pol1314_atu_rateio(l_status)#
#------------------------------------#

   DEFINE l_status   CHAR(01)
      
   UPDATE rateio_tip_desp_orig912
      SET situacao = l_status,
          dat_liberac = m_dat_atu
    WHERE num_rateio = m_num_rateio

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','rateio_tip_desp_orig912')
      LET m_msg = 'Erro ',STATUS,' atualizando tabela rateio_tip_desp_orig912'
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#--------------------------------#          
FUNCTION pol1314_atu_versao_ant()#
#--------------------------------#

   DEFINE l_empresa   CHAR(02),
          l_versao    INTEGER
          
   LET l_versao = mr_cabec.versao - 1
   
   UPDATE rateio_tip_desp_orig912
      SET situacao = 'I'
    WHERE empresa_orig = mr_cabec.cod_emp_orig
      AND cod_tip_desp = mr_cabec.cod_tip_desp
      AND versao < mr_cabec.versao
      AND ((cod_fornecedor = mr_cabec.cod_fornecedor AND mr_cabec.cod_fornecedor IS NOT NULL)
        OR (cod_fornecedor IS NULL AND mr_cabec.cod_fornecedor IS NULL))

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','rateio_tip_desp_orig912')
      LET m_msg = 'Erro ',STATUS,' atualizando tabela rateio_tip_desp_orig912'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1314_nova_versao()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT pol1314_ies_cons() THEN
      RETURN FALSE
   END IF
   
   IF mr_cabec.situacao = 'A' THEN
   ELSE
      LET m_msg = 'Para criar nova vers�o, \n selecione uma grade ativa.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   SELECT COUNT(*)
     INTO m_count
     FROM rateio_tip_desp_orig912
    WHERE empresa_orig = mr_cabec.cod_emp_orig
      AND cod_tip_desp = mr_cabec.cod_tip_desp
      AND situacao = 'B'
      AND ((cod_fornecedor = mr_cabec.cod_fornecedor AND mr_cabec.cod_fornecedor IS NOT NULL) OR 
           (cod_fornecedor IS NULL AND mr_cabec.cod_fornecedor IS NULL) )
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','rateio_tip_desp_orig912')
      RETURN FALSE
   END IF
   
   IF m_count > 0 THEN
      LET m_msg = 'J� esxiste uma nova vers�o em manuten��o.\n',
                  'Sua replica��o n�o � permitida.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
        
   IF NOT LOG_question("Confirma a gera��o da nova vers�o?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1314_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_dat_atu = mr_cabec.dat_liberac
   
   {IF NOT pol1314_atu_rateio('I') THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF}
   
   LET mr_cabec.versao = mr_cabec.versao + 1
   LET mr_cabec.situacao = 'B'
   LET mr_cabec.dat_liberac = NULL
   
   IF NOT pol1314_insere_orig() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   IF NOT pol1314_grava_dest() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF     
   
   CALL log085_transacao("COMMIT")
                     
   LET m_ies_inc = TRUE
   LET m_qtd_aprov = 0
   LET m_num_rateioa = m_num_rateio
   LET m_opcao = NULL
   LET m_ies_cons = FALSE

   CALL log0030_mensagem('Nova vers�o criada \n com sucesso.','info')

   RETURN TRUE
        
END FUNCTION
   