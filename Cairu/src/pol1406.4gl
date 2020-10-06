#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1406                                                 #
# OBJETIVO: PAR�METROS PARA ITEGRA��O LOGIX X ECOMMERCE             #
# AUTOR...: IVO                                                     #
# DATA....: 30/09/2020                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           m_panel           VARCHAR(10),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_cod_empresa_plano   LIKE empresa.cod_empresa

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_folder          VARCHAR(10),
       m_fold_sys        VARCHAR(10),
       m_pan_sys         VARCHAR(10),
       m_brz_sys         VARCHAR(10),
       m_sys_construct   VARCHAR(10)
       
DEFINE m_count           INTEGER,
       m_msg             VARCHAR(200),
       m_op_sys          CHAR(01),
       m_car_sys         SMALLINT,
       m_ind             INTEGER,
       m_nom_sys         VARCHAR(15),
       m_sen_env_crip    VARCHAR(80),
       m_sen_req_crip    VARCHAR(80)
                            
DEFINE mr_sys            RECORD
       cod_sys           VARCHAR(01),
       user_envio        VARCHAR(15),
       senha_envio       VARCHAR(15),
       uri_env_prod      VARCHAR(80),
       uri_env_estoq     VARCHAR(80),
       user_req_serv     VARCHAR(15),
       senha_req_serv    VARCHAR(15),
       qtd_lin_page      INTEGER,
       max_lin_page      INTEGER
END RECORD

DEFINE ma_sys            ARRAY[20] OF RECORD
       nom_sys           VARCHAR(15),
       user_envio        VARCHAR(15),
       uri_env_prod      VARCHAR(80),
       uri_env_estoq     VARCHAR(80),
       user_req_serv     VARCHAR(15),
       qtd_lin_page      INTEGER,
       max_lin_page      INTEGER
END RECORD

DEFINE m_cod_sys         VARCHAR(10),
       m_user_envio      VARCHAR(10),
       m_senha_envio     VARCHAR(10),
       m_user_req        VARCHAR(10),
       m_senha_req       VARCHAR(10),
       m_uri_prod        VARCHAR(10),
       m_uri_estoq       VARCHAR(10),
       m_qtd_lin         VARCHAR(10),
       m_max_lin         VARCHAR(10)
       


DEFINE m_brz_aen         VARCHAR(10),
       m_zoom_aen        VARCHAR(10),
       m_lupa_aen        VARCHAR(10),
       m_fold_aen        VARCHAR(10),
       m_pan_aen         VARCHAR(10),
       m_aen_construct   VARCHAR(10),
       m_op_aen          CHAR(01),
       m_car_aen         SMALLINT

DEFINE mr_aen            RECORD
       cod_sys           VARCHAR(15), 
       cod_lin_prod      DECIMAL(2,0),
       desc_linha        VARCHAR(30) 
END RECORD

DEFINE ma_aen            ARRAY[100] OF RECORD
       nom_sys           VARCHAR(15), 
       cod_lin_prod      DECIMAL(2,0),
       desc_linha        VARCHAR(30), 
       filler            CHAR(01)
END RECORD

DEFINE m_aen_sys         VARCHAR(10),
       m_lin_prod        VARCHAR(10),
       m_aen_nom_sys     VARCHAR(15)

DEFINE m_brz_erro        VARCHAR(10),
       m_fold_erro       VARCHAR(10),
       m_pan_erro        VARCHAR(10)


DEFINE mr_erro          RECORD

END RECORD

            
#-----------------#
FUNCTION pol1406()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1406-12.00.00  "
   CALL func002_versao_prg(p_versao)
   
   LET m_car_sys = TRUE
   LET m_car_aen = TRUE
   INITIALIZE mr_sys.* TO NULL
   INITIALIZE mr_aen.* TO NULL
   INITIALIZE mr_erro.* TO NULL
   
   CALL pol1406_menu()

END FUNCTION
 
#----------------------#
FUNCTION pol1406_menu()#
#----------------------#

    DEFINE l_menubar       VARCHAR(10),
           l_fechar        VARCHAR(10),
           l_panel         VARCHAR(10),
           l_fpanel        VARCHAR(10),
           l_label         VARCHAR(10),
           l_titulo        CHAR(80)

    LET l_titulo = 'PAR�METROS PARA ITEGRA��O LOGIX X ECOMMERCE - ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET m_folder = _ADVPL_create_component(NULL,"LFOLDER",m_dialog)
    CALL _ADVPL_set_property(m_folder,"ALIGN","CENTER")

    # FOLDER systema 

    LET m_fold_sys = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_sys,"TITLE","Ecommerce")
		CALL pol1406_systema(m_fold_sys)
    
    # FOLDER aen 

    LET m_fold_aen = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_aen,"TITLE","�rea e linha")
    CALL pol1406_aen(m_fold_aen)

    # FOLDER erros

    LET m_fold_erro = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_erro,"TITLE","Erros na integra��o")
    #CALL pol1406_erro(m_fold_erro)

    CALL _ADVPL_set_property(m_folder,"FOLDER_SELECTED",1)
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION
   
#------------------------#
FUNCTION pol1406_fechar()#
#------------------------#

   RETURN TRUE
   
END FUNCTION

#-----------------------------------------#
FUNCTION pol1406_desativa_folder(l_folder)#
#-----------------------------------------#

   DEFINE l_folder             CHAR(01)
             
   CASE l_folder
        WHEN '1' 
           CALL _ADVPL_set_property(m_fold_aen,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_erro,"ENABLE",FALSE)        
        WHEN '2' 
           CALL _ADVPL_set_property(m_fold_sys,"ENABLE",FALSE)   
           CALL _ADVPL_set_property(m_fold_erro,"ENABLE",FALSE)      
        WHEN '3' 
           CALL _ADVPL_set_property(m_fold_sys,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_aen,"ENABLE",FALSE)
   END CASE
   
END FUNCTION

#------------------------------#
FUNCTION pol1406_ativa_folder()#
#------------------------------#

   CALL _ADVPL_set_property(m_fold_sys,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_aen,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_erro,"ENABLE",TRUE) 

END FUNCTION




#---Rotinas par�metros do ecommerce ----#

#---------------------------------#
FUNCTION pol1406_systema(l_fpanel)#
#---------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_inform    VARCHAR(10),
           l_update    VARCHAR(10),
           l_delete    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10),
           l_create    VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1406_sys_find")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1406_sys_insert")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1406_sys_insert_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1406_sys_insert_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1406_sys_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1406_sys_update_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1406_sys_update_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1406_sys_delete")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1406_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1406_sys_campo(l_panel)
    CALL pol1406_sys_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1406_sys_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_sys = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_sys,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_sys,"HEIGHT",60)
    #CALL _ADVPL_set_property(m_pan_sys,"BACKGROUND_COLOR",225,232,232) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Ecommerce:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_cod_sys = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_sys)     
    CALL _ADVPL_set_property(m_cod_sys,"POSITION",80,10)     
    CALL _ADVPL_set_property(m_cod_sys,"ADD_ITEM","0"," ")
    CALL _ADVPL_set_property(m_cod_sys,"ADD_ITEM","1","Tray")
    CALL _ADVPL_set_property(m_cod_sys,"ADD_ITEM","2","Mercos")
    CALL _ADVPL_set_property(m_cod_sys,"VARIABLE",mr_sys,"cod_sys")
    CALL _ADVPL_set_property(m_cod_sys,"VALID","pol1406_sys_valid_cod")
              
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",230,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","User envio:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_user_envio = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_user_envio,"POSITION",300,10) 
    CALL _ADVPL_set_property(m_user_envio,"LENGTH",15)    
    CALL _ADVPL_set_property(m_user_envio,"VARIABLE",mr_sys,"user_envio")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",450,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Senha envio:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_senha_envio = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_senha_envio,"POSITION",540,10) 
    CALL _ADVPL_set_property(m_senha_envio,"LENGTH",15)    
    CALL _ADVPL_set_property(m_senha_envio,"PASSWORD",TRUE)
    CALL _ADVPL_set_property(m_senha_envio,"VARIABLE",mr_sys,"senha_envio")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",690,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","User req:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_user_req = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_user_req,"POSITION",750,10) 
    CALL _ADVPL_set_property(m_user_req,"LENGTH",15)    
    CALL _ADVPL_set_property(m_user_req,"VARIABLE",mr_sys,"user_req_serv")
    CALL _ADVPL_set_property(m_user_req,"VALID","pol1406_sys_valid_user")    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",900,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Senha req:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_senha_req = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_senha_req,"POSITION",965,10) 
    CALL _ADVPL_set_property(m_senha_req,"LENGTH",15)    
    CALL _ADVPL_set_property(m_senha_req,"PASSWORD",TRUE)
    CALL _ADVPL_set_property(m_senha_req,"VARIABLE",mr_sys,"senha_req_serv")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",1190,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Linha default:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_qtd_lin = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_qtd_lin,"POSITION",1265,10) 
    CALL _ADVPL_set_property(m_qtd_lin,"LENGTH",5)    
    CALL _ADVPL_set_property(m_qtd_lin,"VARIABLE",mr_sys,"qtd_lin_page")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","URI env produto:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_uri_prod = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_uri_prod,"POSITION",100,40) 
    CALL _ADVPL_set_property(m_uri_prod,"LENGTH",60)    
    CALL _ADVPL_set_property(m_uri_prod,"VARIABLE",mr_sys,"uri_env_prod")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",600,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","URI env estoq:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_uri_estoq = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_uri_estoq,"POSITION",685,40) 
    CALL _ADVPL_set_property(m_uri_estoq,"LENGTH",60)    
    CALL _ADVPL_set_property(m_uri_estoq,"VARIABLE",mr_sys,"uri_env_estoq")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",1180,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Max num linha:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_max_lin = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_max_lin,"POSITION",1265,40) 
    CALL _ADVPL_set_property(m_max_lin,"LENGTH",5)    
    CALL _ADVPL_set_property(m_max_lin,"VARIABLE",mr_sys,"max_lin_page")

    CALL _ADVPL_set_property(m_pan_sys,"ENABLE",FALSE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1406_sys_grade(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_sys = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_sys,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_sys,"BEFORE_ROW_EVENT","pol1406_sys_before_row")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sys)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ecommerce")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_sys")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sys)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","User envio")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","user_envio")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sys)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","User requisi��o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","user_req_serv")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sys)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","URI envio de produto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",300)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","uri_env_prod")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sys)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","URI envio de estoque")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",300)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","uri_env_estoq")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sys)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd linha")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_lin_page")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sys)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","M�x linha")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","max_lin_page")    

    CALL _ADVPL_set_property(m_brz_sys,"SET_ROWS",ma_sys,1)
    CALL _ADVPL_set_property(m_brz_sys,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_sys,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_sys,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#---------------------------------#
FUNCTION pol1406_sys_before_row()#
#---------------------------------#
   
   DEFINE l_linha          INTEGER
   
   LET m_op_sys = 'R'
   
   IF m_car_sys THEN
      RETURN TRUE
   END IF
      
   LET l_linha = _ADVPL_get_property(m_brz_sys,"ROW_SELECTED")
   
   IF l_linha IS NULL OR l_linha = 0 THEN
      RETURN TRUE
   END IF
   CALL pol1406_sys_set_item(l_linha)         
   CALL pol1406_sys_ativa(TRUE)
   CALL _ADVPL_set_property(m_user_envio,"GET_FOCUS")
   CALL pol1406_sys_ativa(false)
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1406_sys_set_item(l_linha)#
#-------------------------------------#
   
   DEFINE l_linha     INTEGER
   
   LET m_nom_sys = ma_sys[l_linha].nom_sys
   CALL pol1406_cod_sys()
   LET mr_sys.user_envio = ma_sys[l_linha].user_envio
   LET mr_sys.uri_env_prod = ma_sys[l_linha].uri_env_prod
   LET mr_sys.uri_env_estoq = ma_sys[l_linha].uri_env_estoq
   LET mr_sys.user_req_serv = ma_sys[l_linha].user_req_serv
   LET mr_sys.qtd_lin_page = ma_sys[l_linha].qtd_lin_page
   LET mr_sys.max_lin_page = ma_sys[l_linha].max_lin_page

END FUNCTION

#--------------------------#
FUNCTION pol1406_nome_sys()#
#--------------------------#

   CASE mr_sys.cod_sys
        WHEN '1' LET m_nom_sys = 'Tray'
        WHEN '2' LET m_nom_sys = 'Mercos'
   END CASE

END FUNCTION
  
#-------------------------#
FUNCTION pol1406_cod_sys()#
#-------------------------#

   CASE m_nom_sys
        WHEN 'Tray' LET mr_sys.cod_sys = '1'
        WHEN 'Mercos' LET  mr_sys.cod_sys = '2'
   END CASE

END FUNCTION

#------------------------------------#
FUNCTION pol1406_sys_ativa(l_status)#
#------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pan_sys,"ENABLE",l_status)
   
   IF m_op_sys = 'I' THEN
      CALL _ADVPL_set_property(m_cod_sys,"ENABLE",l_status)
      CALL _ADVPL_set_property(m_senha_envio,"ENABLE",l_status)
      CALL _ADVPL_set_property(m_senha_req,"ENABLE",l_status)
   ELSE
      CALL _ADVPL_set_property(m_cod_sys,"ENABLE",FALSE)
      CALL _ADVPL_set_property(m_senha_envio,"ENABLE",FALSE)
      CALL _ADVPL_set_property(m_senha_req,"ENABLE",FALSE)
   END IF
         
END FUNCTION

#-----------------------------#
FUNCTION pol1406_sys_insert()#
#-----------------------------#

   LET m_op_sys = 'I'
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_sys.* TO NULL
   
   CALL pol1406_desativa_folder("1")
   LET m_car_sys = TRUE
   CALL pol1406_sys_ativa(TRUE)
   CALL _ADVPL_set_property(m_cod_sys,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1406_sys_insert_canc()#
#----------------------------------#

   CALL pol1406_sys_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1406_ativa_folder()
   CALL _ADVPL_set_property(m_brz_sys,"CLEAR")
   INITIALIZE mr_sys.*, ma_sys TO NULL
   LET m_car_sys = FALSE
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1406_sys_valid_cod()#
#-------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_sys.cod_sys = '0' THEN
      LET m_msg = 'Informe o c�digo de sistema ecommerce'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_cod_sys,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   CALL pol1406_nome_sys()
   
   IF NOT pol1406_sys_ve_dupl() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_cod_sys,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
FUNCTION pol1406_sys_valid_user()#
#--------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_sys.user_req_serv IS NULL THEN
      LET m_msg = 'Informe o usu�rio para as requisi��es na API'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT 1 FROM par_api_cairu
    WHERE user_req_serv = mr_sys.user_req_serv
    
   IF STATUS = 0 THEN
      LET m_msg = 'J� existe no POL1406 um usu�rio com esse nome'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','par_api_cairu:svu')
         RETURN FALSE
      END IF
   END IF
          
   RETURN TRUE
   
END FUNCTION   

#-----------------------------#
FUNCTION pol1406_sys_ve_dupl()#
#-----------------------------#

   SELECT 1 FROM par_api_cairu
    WHERE nom_sys = m_nom_sys
   
   IF STATUS = 0 THEN
      LET m_msg = 'Sistema ecommerce j� cadastrado.'
   ELSE
      IF STATUS = 100 THEN
         RETURN TRUE
      ELSE
         CALL log003_err_sql('SELECT','par_api_cairu')
         LET m_msg = 'Erro ',STATUS, ' Lendo tabela par_api_cairu '
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION         

#----------------------------------#
FUNCTION pol1406_sys_insert_conf()#
#----------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_msg = NULL

   CALL pol1406_sys_valid_form()
   
   IF m_msg IS NOT NULL THEN
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Preencha o formul�rio.')
      RETURN FALSE
   END IF
   
   LET m_sen_env_crip = func002_criptografa(mr_sys.senha_envio)
   LET m_sen_req_crip = func002_criptografa(mr_sys.senha_req_serv)
   
   IF NOT pol1406_sys_ins_sys() THEN
      RETURN FALSE
   END IF
   
   CALL pol1406_sys_prepare()
   CALL pol1406_sys_ativa(FALSE)
   CALL pol1406_ativa_folder()
   LET m_car_sys = FALSE
   
   RETURN TRUE

END FUNCTION        
   
#--------------------------------#
FUNCTION pol1406_sys_valid_form()#
#--------------------------------#
      
   IF mr_sys.user_envio IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe usu�rio de envio\n'
   END IF

   IF mr_sys.senha_envio IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe senha de envio\n'
   END IF

   IF mr_sys.user_req_serv IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe usu�rio p/ requisi��o\n'
   END IF

   IF mr_sys.senha_req_serv IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe senha p/ requisi��o\n'
   END IF

   IF mr_sys.qtd_lin_page IS NULL OR mr_sys.qtd_lin_page = 0 THEN
      LET m_msg = m_msg CLIPPED, '- Informe qtd linha default\n'
   END IF

   IF mr_sys.uri_env_prod IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe a URI de envio\n'
   END IF

   IF mr_sys.uri_env_estoq IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe a URI de estoque\n'
   END IF

   IF mr_sys.max_lin_page IS NULL OR mr_sys.max_lin_page = 0 THEN
      LET m_msg = m_msg CLIPPED, '- Informe qtd m�xima de linha\n'
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol1406_sys_ins_sys()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   INSERT INTO par_api_cairu(
       nom_sys,       
       user_envio,    
       senha_envio,   
       uri_env_prod,  
       uri_env_estoq, 
       user_req_serv, 
       senha_req_serv,
       qtd_lin_page,  
       max_lin_page)  
    VALUES(m_nom_sys,       
           mr_sys.user_envio,    
           m_sen_env_crip,   
           mr_sys.uri_env_prod,  
           mr_sys.uri_env_estoq, 
           mr_sys.user_req_serv, 
           m_sen_req_crip,
           mr_sys.qtd_lin_page,  
           mr_sys.max_lin_page)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','par_api_cairu')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1406_sys_prepare()#
#------------------------------#

   DEFINE l_sql_stmt CHAR(2000)
                        
   LET l_sql_stmt =
       " SELECT nom_sys, user_envio, uri_env_prod, ",
       " uri_env_estoq, user_req_serv, ",
       " qtd_lin_page, max_lin_page ",
    "  FROM par_api_cairu ",
    " WHERE 1 = 1 "

   CALL pol1406_sys_exibe(l_sql_stmt)

END FUNCTION

#--------------------------------------#
FUNCTION pol1406_sys_exibe(l_sql_stmt)#
#--------------------------------------#
   
   DEFINE l_sql_stmt   CHAR(2000),
          l_ind        INTEGER

   CALL _ADVPL_set_property(m_brz_sys,"CLEAR")
   LET m_car_sys = TRUE
   INITIALIZE ma_sys TO NULL
   LET l_ind = 1
   
    PREPARE var_sys FROM l_sql_stmt

    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","par_api_cairu")
       RETURN FALSE
    END IF

   DECLARE cq_sys CURSOR FOR var_sys
   
   FOREACH cq_sys INTO ma_sys[l_ind].*
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','cq_sys:01')
         EXIT FOREACH
      END IF

      LET l_ind = l_ind + 1
      
      IF l_ind > 20 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   IF l_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_sys,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'N�o h� registros para os par�metros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   LET m_car_sys = FALSE
        
END FUNCTION

#---------------------------#
FUNCTION pol1406_sys_find()#
#---------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    LET m_op_sys = 'P'
    
    IF m_sys_construct IS NULL THEN
       LET m_sys_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_sys_construct,"CONSTRUCT_NAME","pol1406_FILTER")
       CALL _ADVPL_set_property(m_sys_construct,"ADD_VIRTUAL_TABLE","par_api_cairu","parametro")
       CALL _ADVPL_set_property(m_sys_construct,"ADD_VIRTUAL_COLUMN","par_api_cairu","nom_sys","Ecommerce",1 {CHAR},15,0)
       CALL _ADVPL_set_property(m_sys_construct,"ADD_VIRTUAL_COLUMN","par_api_cairu","user_envio","User envio",1 {CHAR},15,0)
       CALL _ADVPL_set_property(m_sys_construct,"ADD_VIRTUAL_COLUMN","par_api_cairu","user_req_serv","User requisi��o",1 {CHAR},15)
    END IF

    LET l_status = _ADVPL_get_property(m_sys_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_sys_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_sys_construct,"ORDER_BY")
       CALL pol1406_sys_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#----------------------------------------------------#
FUNCTION pol1406_sys_create_cursor(l_where, l_order)#
#----------------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)
    DEFINE l_ind        INTEGER

    IF l_order IS NULL THEN
       LET l_order = " nom_sys "
    END IF
    
    LET l_sql_stmt = 
       " SELECT nom_sys, user_envio, uri_env_prod, ",
           " uri_env_estoq, user_req_serv, ",
           " qtd_lin_page, max_lin_page ",
       " FROM par_api_cairu ",
        " WHERE ",l_where CLIPPED,
        " ORDER BY ",l_order
   
   CALL pol1406_sys_exibe(l_sql_stmt)
   CALL pol1406_sys_set_item(1)
   
END FUNCTION

#------------------------------#
 FUNCTION pol1406_sys_prende()#
#------------------------------#
   
   CALL  LOG_transaction_begin()
   
   DECLARE cq_sys_prende CURSOR FOR
    SELECT 1
      FROM par_api_cairu
     WHERE nom_sys = m_nom_sys
     FOR UPDATE 
    
    OPEN cq_sys_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_sys_prende")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
    
   FETCH cq_sys_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_sys_prende")
      CALL log085_transacao("ROLLBACK")
      CLOSE cq_sys_prende
      RETURN FALSE
   END IF

END FUNCTION
   
#-----------------------------#
FUNCTION pol1406_sys_update()#
#-----------------------------#   
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_sys.cod_sys IS NULL OR mr_sys.cod_sys = '0' THEN
      LET m_msg = 'Selecione previamente um item na grade'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1406_sys_prende() THEN
      RETURN FALSE
   END IF
   
   LET m_op_sys = 'M'
   CALL pol1406_sys_ativa(TRUE)
   LET m_car_sys = TRUE
   CALL _ADVPL_set_property(m_user_envio,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1406_sys_update_canc()#
#----------------------------------#   
   
   CLOSE cq_sys_prende
   CALL  LOG_transaction_rollback()
   
   INITIALIZE mr_sys.* TO NULL
   
   SELECT nom_sys, user_envio, uri_env_prod, 
          uri_env_estoq, user_req_serv, 
          qtd_lin_page, max_lin_page 
    INTO mr_sys.*
    FROM par_api_cairu
   WHERE nom_sys = m_nom_sys

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'par_api_cairu:suc')
   END IF
         
   CALL pol1406_sys_ativa(FALSE)
   LET m_car_sys = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1406_sys_update_conf()#
#----------------------------------#   

   UPDATE par_api_cairu 
      SET user_envio = mr_sys.user_envio,
          uri_env_prod = mr_sys.uri_env_prod,
          uri_env_estoq = mr_sys.uri_env_estoq,
          user_req_serv = mr_sys.user_req_serv,
          qtd_lin_page = mr_sys.qtd_lin_page,
          max_lin_page = mr_sys.max_lin_page
    WHERE nom_sys = m_nom_sys
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','de_para_produto:iuc')
      RETURN FALSE
   END IF

   CALL LOG_transaction_commit()
   
   CLOSE cq_sys_prende
   CALL pol1406_sys_ativa(FALSE)
   LET m_car_sys = FALSE
   CALL pol1406_sys_prepare()   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1406_sys_delete()#
#-----------------------------#
   
   DEFINE l_ret   SMALLINT

   IF mr_sys.cod_sys IS NULL OR mr_sys.cod_sys = '0' THEN
      LET m_msg = 'Selecione previamente um item na grade'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclus�o do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1406_sys_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM par_api_cairu
    WHERE nom_sys = m_nom_sys

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','par_api_cairu:sd')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_sys.* TO NULL
   ELSE
      CALL LOG_transaction_commit()     
   END IF
   
   CLOSE cq_sys_prende
   CALL pol1406_sys_prepare()
   
   RETURN l_ret
        
END FUNCTION








#---Rotinas cadastro de aen ----#

#-----------------------------#
FUNCTION pol1406_aen(l_fpanel)#
#-----------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_inform    VARCHAR(10),
           l_update    VARCHAR(10),
           l_delete    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10),
           l_create    VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1406_aen_find")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1406_aen_insert")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1406_aen_insert_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1406_aen_insert_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1406_aen_delete")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1406_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1406_aen_campo(l_panel)
    CALL pol1406_aen_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1406_aen_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_aen = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_aen,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_aen,"HEIGHT",40)
    #CALL _ADVPL_set_property(m_pan_aen,"BACKGROUND_COLOR",225,232,232) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_aen)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Ecommerce:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_aen_sys = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_aen)     
    CALL _ADVPL_set_property(m_aen_sys,"POSITION",80,10)     
    CALL _ADVPL_set_property(m_aen_sys,"ADD_ITEM","0"," ")
    CALL _ADVPL_set_property(m_aen_sys,"ADD_ITEM","1","Tray")
    CALL _ADVPL_set_property(m_aen_sys,"ADD_ITEM","2","Mercos")
    CALL _ADVPL_set_property(m_aen_sys,"VARIABLE",mr_aen,"cod_sys")
             
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_aen)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",200,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Linha prod:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_lin_prod = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_aen)     
    CALL _ADVPL_set_property(m_lin_prod,"POSITION",270,10) 
    CALL _ADVPL_set_property(m_lin_prod,"LENGTH",3)    
    CALL _ADVPL_set_property(m_lin_prod,"VARIABLE",mr_aen,"cod_lin_prod")
    CALL _ADVPL_set_property(m_lin_prod,"VALID","pol1406_aen_le_aen")

    LET m_lupa_aen = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_aen)
    CALL _ADVPL_set_property(m_lupa_aen,"POSITION",300,10)     
    CALL _ADVPL_set_property(m_lupa_aen,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_aen,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_aen,"CLICK_EVENT","pol1406_zoom_lin_prod")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_aen)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",370,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Descri�ao:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_aen)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",440,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_aen,"desc_linha")

    CALL _ADVPL_set_property(m_pan_aen,"ENABLE",FALSE)

END FUNCTION

#--------------------------------------#
FUNCTION pol1406_aen_grade(l_container)#
#--------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_aen = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_aen,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_aen,"BEFORE_ROW_EVENT","pol1406_aen_before_row")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_aen)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ecommerce")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_sys")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_aen)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Linha prod")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_lin_prod")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_aen)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","desc_linha")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_aen)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_aen,"SET_ROWS",ma_aen,1)
    CALL _ADVPL_set_property(m_brz_aen,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_aen,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_aen,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#---------------------------------#
FUNCTION pol1406_aen_before_row()#
#---------------------------------#
   
   DEFINE l_linha          INTEGER
   
   LET m_op_aen = 'R'
   
   IF m_car_aen THEN
      RETURN TRUE
   END IF
      
   LET l_linha = _ADVPL_get_property(m_brz_aen,"ROW_SELECTED")
   
   IF l_linha IS NULL OR l_linha = 0 THEN
      RETURN TRUE
   END IF
   
   CALL pol1406_aen_set_item(l_linha)         
   CALL pol1406_aen_ativa(TRUE)
   CALL _ADVPL_set_property(m_lin_prod,"GET_FOCUS")
   CALL pol1406_aen_ativa(false)
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1406_aen_set_item(l_linha)#
#-------------------------------------#
   
   DEFINE l_linha     INTEGER
   
   LET m_aen_nom_sys = ma_aen[l_linha].nom_sys
   CALL pol1406_aen_cod_sys()
   LET mr_aen.cod_lin_prod = ma_aen[l_linha].cod_lin_prod
   LET mr_aen.desc_linha = ma_aen[l_linha].desc_linha

END FUNCTION

#-----------------------------#
FUNCTION pol1406_aen_cod_sys()#
#-----------------------------#

   CASE m_aen_nom_sys
        WHEN 'Tray'   LET mr_aen.cod_sys = '1'
        WHEN 'Mercos' LET  mr_aen.cod_sys = '2'
   END CASE

END FUNCTION

#------------------------------#
FUNCTION pol1406_aen_nome_sys()#
#------------------------------#

   CASE mr_aen.cod_sys
        WHEN '1' LET m_aen_nom_sys = 'Tray'
        WHEN '2' LET m_aen_nom_sys = 'Mercos'
   END CASE

END FUNCTION
  
#------------------------------------#
FUNCTION pol1406_aen_ativa(l_status)#
#------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pan_aen,"ENABLE",l_status)
   
   IF m_op_aen = 'I' THEN
      CALL _ADVPL_set_property(m_aen_sys,"ENABLE",l_status)
   ELSE
      CALL _ADVPL_set_property(m_aen_sys,"ENABLE",FALSE)
   END IF
         
END FUNCTION

#----------------------------#
FUNCTION pol1406_aen_le_aen()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_aen.cod_lin_prod IS NULL THEN
      LET m_msg = 'Informe a linha de produto.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT den_estr_linprod
     INTO mr_aen.desc_linha
     FROM linha_prod
    WHERE cod_lin_prod = mr_aen.cod_lin_prod
      AND cod_lin_recei = 0
      AND cod_seg_merc = 0
      AND cod_cla_uso = 0

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','linha_prod')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
   
#-------------------------------#
FUNCTION pol1406_zoom_lin_prod()#
#-------------------------------#

    DEFINE l_codigo         LIKE linha_prod.cod_lin_prod,
           l_descri         LIKE linha_prod.den_estr_linprod,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_aen IS NULL THEN
       LET m_zoom_aen = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_aen,"ZOOM","zoom_linha_prod")
    END IF

    LET l_where_clause = 
    " linha_prod.cod_lin_recei = 0 and linha_prod.cod_seg_merc = 0 and linha_prod.cod_cla_uso = 0 "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_aen,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_aen,"RETURN_BY_TABLE_COLUMN","linha_prod","cod_lin_prod")
    LET l_descri = _ADVPL_get_property(m_zoom_aen,"RETURN_BY_TABLE_COLUMN","linha_prod","den_estr_linprod")

    IF l_codigo IS NOT NULL THEN
       LET mr_aen.cod_lin_prod = l_codigo
       LET mr_aen.desc_linha = l_descri
    END IF        
    
END FUNCTION

#----------------------------#
FUNCTION pol1406_aen_insert()#
#----------------------------#

   LET m_op_aen = 'I'
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_aen.* TO NULL
   
   CALL pol1406_desativa_folder("2")
   LET m_car_aen = TRUE
   CALL pol1406_aen_ativa(TRUE)
   CALL _ADVPL_set_property(m_aen_sys,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1406_aen_insert_canc()#
#----------------------------------#

   CALL pol1406_aen_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1406_ativa_folder()
   CALL _ADVPL_set_property(m_brz_aen,"CLEAR")
   INITIALIZE mr_aen.*, ma_aen TO NULL
   LET m_car_aen = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1406_aen_insert_conf()#
#----------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_msg = NULL

   CALL pol1406_aen_valid_form()
   
   IF m_msg IS NOT NULL THEN
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Preencha o formul�rio.')
      RETURN FALSE
   END IF
   
   CALL pol1406_aen_nome_sys()
   
   IF NOT pol1406_aen_ve_dupl() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
   
   IF NOT pol1406_aen_ins_aen() THEN
      RETURN FALSE
   END IF
   
   CALL pol1406_aen_prepare()
   CALL pol1406_aen_ativa(FALSE)
   CALL pol1406_ativa_folder()
   LET m_car_aen = FALSE
   
   RETURN TRUE

END FUNCTION        
   
#--------------------------------#
FUNCTION pol1406_aen_valid_form()#
#--------------------------------#
      
   IF mr_aen.cod_sys IS NULL OR mr_aen.cod_sys = '0' THEN
      LET m_msg = m_msg CLIPPED, '- Selecione o Ecommerce\n'
   END IF

   IF mr_aen.cod_lin_prod IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe a linha de produto\n'
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol1406_aen_ve_dupl()#
#-----------------------------#

   SELECT 1 FROM aen_api_cairu
    WHERE nom_sys = m_aen_nom_sys
      AND cod_lin_prod = mr_aen.cod_lin_prod
   
   IF STATUS = 0 THEN
      LET m_msg = 'Linha de produto j� cadastrado no POL1406'
   ELSE
      IF STATUS = 100 THEN
         RETURN TRUE
      ELSE
         CALL log003_err_sql('SELECT','aen_api_cairu')
         LET m_msg = 'Erro ',STATUS, ' Lendo tabela aen_api_cairu '
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#-----------------------------#
FUNCTION pol1406_aen_ins_aen()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   INSERT INTO aen_api_cairu(
       nom_sys,       
       cod_lin_prod,    
       desc_linha)   
    VALUES(m_aen_nom_sys,       
           mr_aen.cod_lin_prod,    
           mr_aen.desc_linha)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','aen_api_cairu')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1406_aen_prepare()#
#-----------------------------#

   DEFINE l_sql_stmt CHAR(2000)
                        
   LET l_sql_stmt =
       " SELECT nom_sys, cod_lin_prod, desc_linha ",
    "  FROM aen_api_cairu ",
    " WHERE 1 = 1 "

   CALL pol1406_aen_exibe(l_sql_stmt)

END FUNCTION

#--------------------------------------#
FUNCTION pol1406_aen_exibe(l_sql_stmt)#
#--------------------------------------#
   
   DEFINE l_sql_stmt   CHAR(2000),
          l_ind        INTEGER

   CALL _ADVPL_set_property(m_brz_aen,"CLEAR")
   LET m_car_aen = TRUE
   INITIALIZE ma_aen TO NULL
   LET l_ind = 1
   
    PREPARE var_aen FROM l_sql_stmt

    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","aen_api_cairu:PREPARE")
       RETURN FALSE
    END IF

   DECLARE cq_aen CURSOR FOR var_aen
   
   FOREACH cq_aen INTO ma_aen[l_ind].*
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','cq_aen:01')
         EXIT FOREACH
      END IF

      LET l_ind = l_ind + 1
      
      IF l_ind > 200 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   IF l_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_aen,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'N�o h� registros para os par�metros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   LET m_car_aen = FALSE
        
END FUNCTION

#--------------------------#
FUNCTION pol1406_aen_find()#
#--------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    LET m_op_sys = 'P'
    
    IF m_aen_construct IS NULL THEN
       LET m_aen_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_aen_construct,"CONSTRUCT_NAME","pol1406_FILTER")
       CALL _ADVPL_set_property(m_aen_construct,"ADD_VIRTUAL_TABLE","aen_api_cairu","parametro")
       CALL _ADVPL_set_property(m_aen_construct,"ADD_VIRTUAL_COLUMN","aen_api_cairu","nom_sys","Ecommerce",1 {CHAR},15,0)
       CALL _ADVPL_set_property(m_aen_construct,"ADD_VIRTUAL_COLUMN","aen_api_cairu","cod_lin_prod","Linha de produto",1 {INT},2,0)
    END IF

    LET l_status = _ADVPL_get_property(m_aen_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_aen_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_aen_construct,"ORDER_BY")
       CALL pol1406_aen_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#---------------------------------------------------#
FUNCTION pol1406_aen_create_cursor(l_where, l_order)#
#---------------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)
    DEFINE l_ind        INTEGER

    IF l_order IS NULL THEN
       LET l_order = " nom_sys "
    END IF
    
    LET l_sql_stmt = 
       " SELECT nom_sys, cod_lin_prod, desc_linha ",
       " FROM aen_api_cairu ",
        " WHERE ",l_where CLIPPED,
        " ORDER BY ",l_order
   
   CALL pol1406_aen_exibe(l_sql_stmt)
   CALL pol1406_aen_set_item(1)
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1406_aen_prende()#
#-----------------------------#
   
   CALL  LOG_transaction_begin()
   
   DECLARE cq_aen_prende CURSOR FOR
    SELECT 1
      FROM aen_api_cairu
     WHERE nom_sys = m_aen_nom_sys
       AND cod_lin_prod = mr_aen.cod_lin_prod
     FOR UPDATE 
    
    OPEN cq_aen_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_aen_prende")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
    
   FETCH cq_aen_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_aen_prende")
      CALL log085_transacao("ROLLBACK")
      CLOSE cq_aen_prende
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol1406_aen_delete()#
#----------------------------#
   
   DEFINE l_ret   SMALLINT

   IF mr_aen.cod_sys IS NULL OR mr_aen.cod_sys = '0' THEN
      LET m_msg = 'Selecione previamente um item na grade'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclus�o do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1406_aen_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM aen_api_cairu
     WHERE nom_sys = m_aen_nom_sys
       AND cod_lin_prod = mr_aen.cod_lin_prod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','aen_api_cairu:sd')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_aen.* TO NULL
   ELSE
      CALL LOG_transaction_commit()     
   END IF
   
   CLOSE cq_aen_prende
   CALL pol1406_aen_prepare()
   
   RETURN l_ret
        
END FUNCTION