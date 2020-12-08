#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1406                                                 #
# OBJETIVO: CADASTROS PARA ITEGRAÇÃO LOGIX X ECOMMERCE              #
# AUTOR...: IVO                                                     #
# DATA....: 30/09/2020                                              #
#-------------------------------------------------------------------#
#Lista de preço
{VPD10102 – Tabela Mestre
VPD0270 – Item} 

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           m_panel         VARCHAR(10),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_nom_func        LIKE usuarios.nom_funcionario

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
       cod_sys           VARCHAR(1), 
       user_req_serv     VARCHAR(15), 
       senha_req_serv    VARCHAR(80), 
       user_erp          VARCHAR(08), 
       qtd_lin_page      INTEGER,     
       max_lin_page      INTEGER,     
       user_envio        VARCHAR(15), 
       senha_envio       VARCHAR(80), 
       uri_inc_prod      VARCHAR(80), 
       uri_alt_prod      VARCHAR(80), 
       uri_alt_estoq     VARCHAR(80), 
       uri_canc_pedido   VARCHAR(80)
END RECORD

DEFINE ma_sys            ARRAY[20] OF RECORD
       nom_sys           VARCHAR(15), 
       user_req_serv     VARCHAR(15), 
       user_erp          VARCHAR(08), 
       qtd_lin_page      INTEGER,     
       max_lin_page      INTEGER,     
       user_envio        VARCHAR(15), 
       uri_inc_prod      VARCHAR(80), 
       uri_alt_prod      VARCHAR(80), 
       uri_alt_estoq     VARCHAR(80), 
       uri_canc_pedido   VARCHAR(80)
END RECORD

DEFINE m_cod_sys         VARCHAR(10),
       m_user_envio      VARCHAR(10),
       m_senha_envio     VARCHAR(10),
       m_user_req        VARCHAR(10),
       m_senha_req       VARCHAR(10),
       m_user_erp        VARCHAR(10),
       m_inc_prod        VARCHAR(10),
       m_alt_prod        VARCHAR(10),
       m_alt_estoq       VARCHAR(10),
       m_uri_canc_ped    VARCHAR(10),
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
       cnpj              VARCHAR(19), 
       cod_lin_prod      DECIMAL(2,0),
       desc_linha        VARCHAR(30) 
END RECORD

DEFINE ma_aen            ARRAY[100] OF RECORD
       nom_sys           VARCHAR(15), 
       cnpj              VARCHAR(19), 
       cod_lin_prod      DECIMAL(2,0),
       desc_linha        VARCHAR(30), 
       filler            CHAR(01)
END RECORD

DEFINE m_aen_sys         VARCHAR(10),
       m_lin_prod        VARCHAR(10),
       m_cgc_emp         VARCHAR(10),
       m_aen_nom_sys     VARCHAR(15)

DEFINE m_brz_emp         VARCHAR(10),
       m_fold_emp        VARCHAR(10),
       m_pan_emp         VARCHAR(10),
       m_cnpj_emp        VARCHAR(10),
       m_emp_emp         VARCHAR(10),
       m_env_aut         VARCHAR(10),
       m_emp_construct   VARCHAR(10),
       m_zoom_cnpj       VARCHAR(10),
       m_zoom_emp        VARCHAR(10),
       m_car_emp         smallint,
       m_op_emp          char(01)

DEFINE mr_emp          RECORD
       cnpj            VARCHAR(19),
       empresa         VARCHAR(02),
       descricao       VARCHAR(36),
       uf              VARCHAR(02),
       gerar_om        VARCHAR(01)
END RECORD

DEFINE ma_emp            ARRAY[100] OF RECORD
       cnpj              VARCHAR(19),
       empresa           VARCHAR(02),
       uf                CHAR(02),
       descricao         VARCHAR(36),
       gerar_om          CHAR(01),
       filler            CHAR(01)
END RECORD

DEFINE m_par_construct   VARCHAR(10),
       m_op_par          CHAR(01),
       m_ies_cons        SMALLINT,
       m_excluiu         SMALLINT

DEFINE m_fold_par        VARCHAR(10),
       m_pan_par         VARCHAR(10),
       m_cnpj_empresa    VARCHAR(19),
       m_cnpj_empresaa   VARCHAR(19)

DEFINE mr_par            RECORD        
   cnpj_empresa          VARCHAR(19),  
   cod_empresa           CHAR(02),
   cod_nat_oper          DECIMAL(4,0), 
   den_nat_oper          VARCHAR(30),
   pct_comissao          DECIMAL(5,2), 
   ies_finalidade        DECIMAL(1,0), 
   ies_frete             DECIMAL(1,0), 
   ies_preco             CHAR(01),     
   cod_cnd_pgto          DECIMAL(4,0), 
   den_cnd_pgto          VARCHAR(30),
   ies_embal_padrao      CHAR(01),     
   ies_tip_entrega       DECIMAL(1,0), 
   ies_sit_pedido        CHAR(01),     
   num_list_preco        DECIMAL(4,0), 
   den_list_preco        VARCHAR(30),
   cod_repres            DECIMAL(4,0), 
   cod_tip_venda         DECIMAL(1,0), 
   cod_moeda             DECIMAL(1,0), 
   ies_comissao          CHAR(01),     
   cod_tip_carteira      CHAR(02),     
   cod_local_estoq       CHAR(10),
   den_local             VARCHAR(30),
   bloqueio_estoque      CHAR(01)      
END RECORD

DEFINE m_cnpj_par        VARCHAR(10),
       m_nat_par         VARCHAR(10),
       m_zoom_nat        VARCHAR(10),
       m_zoom_cond       VARCHAR(10),
       m_zoom_lista      VARCHAR(10),
       m_zoom_local      VARCHAR(10),
       m_pct_comis       VARCHAR(10),
       m_finalidade      VARCHAR(10),
       m_frete           VARCHAR(10),
       m_preco           VARCHAR(10),
       m_condicao        VARCHAR(10),
       m_embal           VARCHAR(10),
       m_carteira        VARCHAR(10),
       m_entrega         VARCHAR(10),
       m_situacao        VARCHAR(10),
       m_lista           VARCHAR(10),
       m_repres          VARCHAR(10),
       m_venda           VARCHAR(10),
       m_moeda           VARCHAR(10),
       m_ies_comis       VARCHAR(10),
       m_local           VARCHAR(10),
       m_bloq_estoq      VARCHAR(10)

                   
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
   LET m_car_emp = TRUE
   INITIALIZE mr_sys.* TO NULL
   INITIALIZE mr_aen.* TO NULL
   INITIALIZE mr_emp.* TO NULL
   INITIALIZE mr_par.* TO NULL
   
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

    LET l_titulo = 'CADASTROS PARA ITEGRAÇÃO LOGIX X ECOMMERCE - ',p_versao
    
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
    CALL _ADVPL_set_property(m_fold_aen,"TITLE","Área e linha")
    CALL pol1406_aen(m_fold_aen)

    # FOLDER empresas

    LET m_fold_emp = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_emp,"TITLE","Empresas")
    CALL pol1406_emp(m_fold_emp)

    # FOLDER parâmetros

    LET m_fold_par = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_par,"TITLE","Parâmetros")
    CALL pol1406_par(m_fold_par)

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
           CALL _ADVPL_set_property(m_fold_emp,"ENABLE",FALSE)        
           CALL _ADVPL_set_property(m_fold_par,"ENABLE",FALSE)        
        WHEN '2' 
           CALL _ADVPL_set_property(m_fold_sys,"ENABLE",FALSE)   
           CALL _ADVPL_set_property(m_fold_emp,"ENABLE",FALSE)      
           CALL _ADVPL_set_property(m_fold_par,"ENABLE",FALSE)        
        WHEN '3' 
           CALL _ADVPL_set_property(m_fold_sys,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_aen,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_par,"ENABLE",FALSE)        
        WHEN '4' 
           CALL _ADVPL_set_property(m_fold_sys,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_aen,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_emp,"ENABLE",FALSE)      
   END CASE
   
END FUNCTION

#------------------------------#
FUNCTION pol1406_ativa_folder()#
#------------------------------#

   CALL _ADVPL_set_property(m_fold_sys,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_aen,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_emp,"ENABLE",TRUE) 
   CALL _ADVPL_set_property(m_fold_par,"ENABLE",TRUE) 

END FUNCTION




#---Rotinas parâmetros do ecommerce ----#

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
    CALL _ADVPL_set_property(m_pan_sys,"HEIGHT",130)
    #CALL _ADVPL_set_property(m_pan_sys,"BACKGROUND_COLOR",225,232,232) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",35,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Ecommerce:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_cod_sys = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_sys)     
    CALL _ADVPL_set_property(m_cod_sys,"POSITION",115,10)     
    CALL _ADVPL_set_property(m_cod_sys,"ADD_ITEM","0"," ")
    CALL _ADVPL_set_property(m_cod_sys,"ADD_ITEM","1","Tray")
    CALL _ADVPL_set_property(m_cod_sys,"ADD_ITEM","2","Mercos")
    CALL _ADVPL_set_property(m_cod_sys,"VARIABLE",mr_sys,"cod_sys")
    CALL _ADVPL_set_property(m_cod_sys,"VALID","pol1406_sys_valid_cod")
              
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",35,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Usuário req:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_user_req = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_user_req,"POSITION",115,40) 
    CALL _ADVPL_set_property(m_user_req,"LENGTH",15)    
    CALL _ADVPL_set_property(m_user_req,"VARIABLE",mr_sys,"user_req_serv")
    CALL _ADVPL_set_property(m_user_req,"VALID","pol1406_sys_valid_user")    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",35,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","Senha req:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_senha_req = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_senha_req,"POSITION",115,70) 
    CALL _ADVPL_set_property(m_senha_req,"LENGTH",15)    
    CALL _ADVPL_set_property(m_senha_req,"PASSWORD",TRUE)
    CALL _ADVPL_set_property(m_senha_req,"VARIABLE",mr_sys,"senha_req_serv")
    CALL _ADVPL_set_property(m_senha_req,"VALID","pol1406_valid_sen_req")    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",35,100)  
    CALL _ADVPL_set_property(l_label,"TEXT","Usuário ERP:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_user_erp = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_user_erp,"POSITION",115,100) 
    CALL _ADVPL_set_property(m_user_erp,"LENGTH",8)    
    CALL _ADVPL_set_property(m_user_erp,"VARIABLE",mr_sys,"user_erp")
    CALL _ADVPL_set_property(m_user_erp,"VALID","pol1406_sys_val_user_erp") 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",330,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Linha default:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_qtd_lin = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_qtd_lin,"POSITION",415,10) 
    CALL _ADVPL_set_property(m_qtd_lin,"LENGTH",5)    
    CALL _ADVPL_set_property(m_qtd_lin,"VARIABLE",mr_sys,"qtd_lin_page")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",325,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Max num linha:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_max_lin = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_max_lin,"POSITION",415,40) 
    CALL _ADVPL_set_property(m_max_lin,"LENGTH",5)    
    CALL _ADVPL_set_property(m_max_lin,"VARIABLE",mr_sys,"max_lin_page")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",255,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","Usuário envio:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_user_envio = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_user_envio,"POSITION",330,70) 
    CALL _ADVPL_set_property(m_user_envio,"LENGTH",15)    
    CALL _ADVPL_set_property(m_user_envio,"VARIABLE",mr_sys,"user_envio")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",260,100)  
    CALL _ADVPL_set_property(l_label,"TEXT","Senha envio:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_senha_envio = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_senha_envio,"POSITION",330,100) 
    CALL _ADVPL_set_property(m_senha_envio,"LENGTH",15)    
    CALL _ADVPL_set_property(m_senha_envio,"PASSWORD",TRUE)
    CALL _ADVPL_set_property(m_senha_envio,"VARIABLE",mr_sys,"senha_envio")
    CALL _ADVPL_set_property(m_senha_envio,"VALID","pol1406_valid_sen_env")    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",505,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","URI inclusão produto:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_inc_prod = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_inc_prod,"POSITION",630,10) 
    CALL _ADVPL_set_property(m_inc_prod,"LENGTH",80)    
    CALL _ADVPL_set_property(m_inc_prod,"VARIABLE",mr_sys,"uri_inc_prod")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",500,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","URI alteração produto:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_alt_prod = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_alt_prod,"POSITION",630,40) 
    CALL _ADVPL_set_property(m_alt_prod,"LENGTH",80)    
    CALL _ADVPL_set_property(m_alt_prod,"VARIABLE",mr_sys,"uri_alt_prod")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",500,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","URI alteração estoque:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_alt_estoq = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_alt_estoq,"POSITION",630,70) 
    CALL _ADVPL_set_property(m_alt_estoq,"LENGTH",80)    
    CALL _ADVPL_set_property(m_alt_estoq,"VARIABLE",mr_sys,"uri_alt_estoq")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_sys)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",535,100)  
    CALL _ADVPL_set_property(l_label,"TEXT","URI canc pedido:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_uri_canc_ped = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_sys)     
    CALL _ADVPL_set_property(m_uri_canc_ped,"POSITION",630,100) 
    CALL _ADVPL_set_property(m_uri_canc_ped,"LENGTH",80)    
    CALL _ADVPL_set_property(m_uri_canc_ped,"VARIABLE",mr_sys,"uri_canc_pedido")

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
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","User requisição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","user_req_serv")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sys)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","User ERP")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","user_erp")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sys)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd linha")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_lin_page")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sys)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)    
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Máx linha")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","max_lin_page")    

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sys)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","User envio")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","user_envio")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sys)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","URI inclusão de produto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","uri_inc_prod")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sys)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","URI alteração de produto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","uri_alt_prod")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sys)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","URI alteração de estoque")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","uri_alt_estoq")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sys)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","URI cancelamento de estoque")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","uri_canc_pedido")

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
   LET mr_sys.uri_inc_prod = ma_sys[l_linha].uri_inc_prod
   LET mr_sys.uri_alt_prod = ma_sys[l_linha].uri_alt_prod
   LET mr_sys.uri_alt_estoq = ma_sys[l_linha].uri_alt_estoq
   LET mr_sys.user_req_serv = ma_sys[l_linha].user_req_serv
   LET mr_sys.qtd_lin_page = ma_sys[l_linha].qtd_lin_page
   LET mr_sys.max_lin_page = ma_sys[l_linha].max_lin_page
   LET mr_sys.user_erp = ma_sys[l_linha].user_erp
   LET mr_sys.uri_canc_pedido = ma_sys[l_linha].uri_canc_pedido

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
      LET m_msg = 'Informe o código de sistema ecommerce'
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
   
   DEFINE l_nom_sys       VARCHAR(15)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_sys.user_req_serv IS NULL THEN
      LET m_msg = 'Informe o usuário para as requisições na API'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT nom_sys INTO l_nom_sys
     FROM sys_api_cairu
    WHERE user_req_serv = mr_sys.user_req_serv
    
   IF STATUS = 0 THEN
      IF l_nom_sys <> m_nom_sys THEN
         LET m_msg = 'Já existe no POL1406 um usuário com esse nome'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','sys_api_cairu:svu')
         RETURN FALSE
      END IF
   END IF
          
   RETURN TRUE
   
END FUNCTION   

#-------------------------------#
FUNCTION pol1406_valid_sen_env()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_sys.senha_envio IS NULL THEN
      LET m_msg = 'Informe a senha para envio automático de dados pela API'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT func002_validaSenha(mr_sys.senha_envio) THEN
      LET m_msg = 'Senha deve conter pelo menos uma letra, um número e um especial'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1406_valid_sen_req()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_sys.senha_req_serv IS NULL THEN
      LET m_msg = 'Informe a senha para requisição dos recursos da API'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT func002_validaSenha(mr_sys.senha_req_serv) THEN
      LET m_msg = 'Senha deve conter pelo menos uma letra, um número e um especial'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol1406_sys_ve_dupl()#
#-----------------------------#

   SELECT 1 FROM sys_api_cairu
    WHERE nom_sys = m_nom_sys
   
   IF STATUS = 0 THEN
      LET m_msg = 'Sistema ecommerce já cadastrado.'
   ELSE
      IF STATUS = 100 THEN
         RETURN TRUE
      ELSE
         CALL log003_err_sql('SELECT','sys_api_cairu')
         LET m_msg = 'Erro ',STATUS, ' Lendo tabela sys_api_cairu '
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION         

#----------------------------------#
FUNCTION pol1406_sys_val_user_erp()#
#----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_sys.user_erp IS NULL THEN
      LET m_msg = 'Informe o usuário correspoendente no ERP'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT nom_funcionario INTO m_nom_func
     FROM usuarios
    WHERE cod_usuario = mr_sys.user_erp
    
   IF STATUS = 100 THEN
      LET m_msg = 'Usuário não existe no ERP'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','usuarios:svue')
         RETURN FALSE
      END IF
   END IF
          
   RETURN TRUE
   
END FUNCTION   

#----------------------------------#
FUNCTION pol1406_sys_insert_conf()#
#----------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_msg = NULL

   CALL pol1406_sys_valid_form()
   
   IF m_msg IS NOT NULL THEN
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Preencha o formulário.')
      RETURN FALSE
   END IF
   
   #LET m_sen_env_crip = func002_criptografa(mr_sys.senha_envio)
   LET m_sen_env_crip = mr_sys.senha_envio
   LET m_sen_req_crip = func002_criptografa(mr_sys.senha_req_serv)
   
   CALL  LOG_transaction_begin()
   
   IF NOT pol1406_sys_ins_sys() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
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
      LET m_msg = m_msg CLIPPED, '- Informe usuário de envio\n'
   END IF

   IF mr_sys.senha_envio IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe senha de envio\n'
   END IF

   IF mr_sys.user_req_serv IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe usuário p/ requisição\n'
   END IF

   IF mr_sys.senha_req_serv IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe senha p/ requisição\n'
   END IF

   IF mr_sys.qtd_lin_page IS NULL OR mr_sys.qtd_lin_page = 0 THEN
      LET m_msg = m_msg CLIPPED, '- Informe qtd linha default\n'
   END IF

   IF mr_sys.user_erp IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe usuário no ERP\n'
   END IF

   IF mr_sys.uri_inc_prod IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe a URI de inclusão de produtos\n'
   END IF

   IF mr_sys.uri_alt_prod IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe a URI de alteração de produtos\n'
   END IF

   IF mr_sys.uri_alt_estoq IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe a URI de alteração de estoque estoque\n'
   END IF

   IF mr_sys.uri_canc_pedido IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe a URI de canc pedido\n'
   END IF

   IF mr_sys.max_lin_page IS NULL OR mr_sys.max_lin_page = 0 THEN
      LET m_msg = m_msg CLIPPED, '- Informe qtd máxima de linha\n'
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol1406_sys_ins_sys()#
#-----------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_sen_req_crip = UPSHIFT(m_sen_req_crip)
   #LET m_sen_env_crip = UPSHIFT(m_sen_env_crip)
   
   INSERT INTO sys_api_cairu(
       nom_sys,       
       user_envio,    
       senha_envio,   
       uri_inc_prod,  
       uri_alt_prod,  
       uri_alt_estoq, 
       user_req_serv, 
       senha_req_serv,
       qtd_lin_page,  
       max_lin_page,
       user_erp,
       uri_canc_pedido)  
    VALUES(m_nom_sys,       
           mr_sys.user_envio,    
           m_sen_env_crip,   
           mr_sys.uri_inc_prod,  
           mr_sys.uri_alt_prod,  
           mr_sys.uri_alt_estoq, 
           mr_sys.user_req_serv, 
           m_sen_req_crip,
           mr_sys.qtd_lin_page,  
           mr_sys.max_lin_page,
           mr_sys.user_erp,
           mr_sys.uri_canc_pedido)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','sys_api_cairu')
      RETURN FALSE
   END IF   
   
   INSERT INTO usuario_api_cairu(
      codigo,
      codigo_erp,
      cpf_cnpj,
      email,
      nome,
      perfil,
      pessoa,
      senha,
      situacao)
   VALUES(mr_sys.user_req_serv, 
          mr_sys.user_erp,
          ' ',
          ' ',
          m_nom_sys,
          0,
          'J',
          m_sen_req_crip,
          'A')

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','usuario_api_cairu')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1406_sys_prepare()#
#------------------------------#

   DEFINE l_sql_stmt CHAR(2000)
                        
   LET l_sql_stmt =
       " SELECT nom_sys, user_req_serv, ",
       " user_erp, qtd_lin_page, max_lin_page, ",
       " user_envio, uri_inc_prod, uri_alt_prod, ",
       " uri_alt_estoq, uri_canc_pedido ",
    "  FROM sys_api_cairu ",
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
       CALL log003_err_sql("PREPARE SQL","sys_api_cairu")
       RETURN FALSE
    END IF

   DECLARE cq_sys CURSOR FOR var_sys
   
   FOREACH cq_sys INTO 
      ma_sys[l_ind].nom_sys,
      ma_sys[l_ind].user_req_serv,
      ma_sys[l_ind].user_erp,
      ma_sys[l_ind].qtd_lin_page,
      ma_sys[l_ind].max_lin_page,
      ma_sys[l_ind].user_envio,
      ma_sys[l_ind].uri_inc_prod,
      ma_sys[l_ind].uri_alt_prod,
      ma_sys[l_ind].uri_alt_estoq,
      ma_sys[l_ind].uri_canc_pedido

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
      LET m_msg = 'Não há registros para os parâmetros informados'
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
       CALL _ADVPL_set_property(m_sys_construct,"ADD_VIRTUAL_TABLE","sys_api_cairu","parametro")
       CALL _ADVPL_set_property(m_sys_construct,"ADD_VIRTUAL_COLUMN","sys_api_cairu","nom_sys","Ecommerce",1 {CHAR},15,0)
       CALL _ADVPL_set_property(m_sys_construct,"ADD_VIRTUAL_COLUMN","sys_api_cairu","user_envio","User envio",1 {CHAR},15,0)
       CALL _ADVPL_set_property(m_sys_construct,"ADD_VIRTUAL_COLUMN","sys_api_cairu","user_req_serv","User requisição",1 {CHAR},15)
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
       " SELECT nom_sys, user_req_serv, ",
       " user_erp, qtd_lin_page, max_lin_page, ",
       " user_envio, uri_inc_prod, uri_alt_prod, ",
       " uri_alt_estoq, uri_canc_pedido ",
       " FROM sys_api_cairu ",
        " WHERE ",l_where CLIPPED,
        " ORDER BY ",l_order
   
   CALL pol1406_sys_exibe(l_sql_stmt)
   CALL pol1406_sys_set_item(1)
   
END FUNCTION

#------------------------------#
 FUNCTION pol1406_sys_prende()#
#------------------------------#
   
   CALL LOG_transaction_begin()
   
   DECLARE cq_sys_prende CURSOR FOR
    SELECT 1
      FROM sys_api_cairu
     WHERE nom_sys = m_nom_sys
     FOR UPDATE 
    
    OPEN cq_sys_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_sys_prende")
       CALL LOG_transaction_rollback()
       RETURN FALSE
    END IF
    
   FETCH cq_sys_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_sys_prende")
      CALL LOG_transaction_rollback()
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
   CALL _ADVPL_set_property(m_user_req,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1406_sys_update_canc()#
#----------------------------------#   
   
   CLOSE cq_sys_prende
   CALL LOG_transaction_rollback()
   
   INITIALIZE mr_sys.* TO NULL
          
   SELECT nom_sys, user_envio, uri_inc_prod, uri_alt_prod,
          uri_alt_estoq, user_req_serv, 
          qtd_lin_page, max_lin_page, user_erp, uri_canc_pedido
    INTO mr_sys.cod_sys,
         mr_sys.user_envio,
         mr_sys.uri_inc_prod,
         mr_sys.uri_alt_prod,
         mr_sys.uri_alt_estoq,
         mr_sys.user_req_serv,
         mr_sys.qtd_lin_page,
         mr_sys.max_lin_page,
         mr_sys.user_erp,
         mr_sys.uri_canc_pedido
    FROM sys_api_cairu
   WHERE nom_sys = m_nom_sys

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'sys_api_cairu:suc')
   END IF
         
   CALL pol1406_sys_ativa(FALSE)
   LET m_car_sys = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1406_sys_update_conf()#
#----------------------------------#   

   UPDATE sys_api_cairu 
      SET user_envio = mr_sys.user_envio,
          uri_inc_prod = mr_sys.uri_inc_prod,
          uri_alt_prod = mr_sys.uri_alt_prod,
          uri_alt_estoq = mr_sys.uri_alt_estoq,
          user_req_serv = mr_sys.user_req_serv,
          qtd_lin_page = mr_sys.qtd_lin_page,
          max_lin_page = mr_sys.max_lin_page,
          user_erp = mr_sys.user_erp,
          uri_canc_pedido = mr_sys.uri_canc_pedido
    WHERE nom_sys = m_nom_sys
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','de_para_produto:iuc')
      CALL pol1406_sys_update_canc()
      RETURN FALSE
   END IF
   
   UPDATE usuario_api_cairu
      SET codigo_erp = mr_sys.user_erp
    WHERE codigo = mr_sys.user_req_serv

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','usuario_api_cairu:iuc')
      CALL pol1406_sys_update_canc()
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
   
   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1406_sys_prende() THEN
      RETURN FALSE
   END IF

   LET l_ret = FALSE

   DELETE FROM sys_api_cairu
    WHERE nom_sys = m_nom_sys

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','sys_api_cairu:sd')
   ELSE
      DELETE FROM usuario_api_cairu
       WHERE codigo = mr_sys.user_req_serv
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','sys_api_cairu:sd')
      ELSE
         LET l_ret = TRUE
      END IF
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
    CALL _ADVPL_set_property(l_label,"POSITION",180,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","CNPJ Empresa:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cgc_emp = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_aen)     
    CALL _ADVPL_set_property(m_cgc_emp,"POSITION",270,10) 
    CALL _ADVPL_set_property(m_cgc_emp,"LENGTH",19)    
    CALL _ADVPL_set_property(m_cgc_emp,"VARIABLE",mr_aen,"cnpj")
    CALL _ADVPL_set_property(m_cgc_emp,"VALID","pol1406_aen_valid_ccg")
             
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_aen)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",470,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Linha prod:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_lin_prod = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_aen)     
    CALL _ADVPL_set_property(m_lin_prod,"POSITION",540,10) 
    CALL _ADVPL_set_property(m_lin_prod,"LENGTH",3)    
    CALL _ADVPL_set_property(m_lin_prod,"VARIABLE",mr_aen,"cod_lin_prod")
    CALL _ADVPL_set_property(m_lin_prod,"VALID","pol1406_aen_le_aen")

    LET m_lupa_aen = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_aen)
    CALL _ADVPL_set_property(m_lupa_aen,"POSITION",580,10)     
    CALL _ADVPL_set_property(m_lupa_aen,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_aen,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_aen,"CLICK_EVENT","pol1406_zoom_lin_prod")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_aen)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",620,10) 
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
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CNPJ Empresa")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cnpj")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_aen)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Linha prod")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_lin_prod")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_aen)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
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
   CALL _ADVPL_set_property(m_cgc_emp,"GET_FOCUS")
   CALL pol1406_aen_ativa(false)
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1406_aen_set_item(l_linha)#
#-------------------------------------#
   
   DEFINE l_linha     INTEGER
   
   LET m_aen_nom_sys = ma_aen[l_linha].nom_sys
   CALL pol1406_aen_cod_sys()
   LET mr_aen.cnpj = ma_aen[l_linha].cnpj
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

#-------------------------------#
FUNCTION pol1406_aen_valid_ccg()#
#-------------------------------#

   IF mr_aen.cnpj IS NOT NULL THEN
      SELECT 1
        FROM empresa_api_cairu
       WHERE cnpj = mr_aen.cnpj
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','empresa_api_cairu')
         RETURN FALSE
      END IF
   END IF
      
   RETURN TRUE

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
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Preencha o formulário.')
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

   IF mr_aen.cnpj IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe o CNPJ da empresa\n'
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
      AND cnpj = mr_aen.cnpj
      AND cod_lin_prod = mr_aen.cod_lin_prod
   
   IF STATUS = 0 THEN
      LET m_msg = 'Linha de produto já cadastrado no POL1406'
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
       cnpj,   
       cod_lin_prod,    
       desc_linha)   
    VALUES(m_aen_nom_sys,    
           mr_aen.cnpj,   
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
       " SELECT nom_sys, cnpj, cod_lin_prod, desc_linha ",
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
      
      IF l_ind > 100 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   IF l_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_aen,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'Não há registros para os parâmetros informados'
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
       CALL _ADVPL_set_property(m_aen_construct,"ADD_VIRTUAL_COLUMN","aen_api_cairu","cnpj","CNPJ",1 {CHAR},19,0)
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
       " SELECT nom_sys, cnpj, cod_lin_prod, desc_linha ",
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
       AND cnpj = mr_aen.cnpj
       AND cod_lin_prod = mr_aen.cod_lin_prod
     FOR UPDATE 
    
    OPEN cq_aen_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_aen_prende")
       CALL LOG_transaction_rollback()
       RETURN FALSE
    END IF
    
   FETCH cq_aen_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_aen_prende")
      CALL LOG_transaction_rollback()
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
   
   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1406_aen_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM aen_api_cairu
     WHERE nom_sys = m_aen_nom_sys
       AND cnpj = mr_aen.cnpj
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

#---Rotinas cadastro de empresas ----#

#-----------------------------#
FUNCTION pol1406_emp(l_fpanel)#
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
    CALL _ADVPL_set_property(l_find,"EVENT","pol1406_emp_find")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1406_emp_insert")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1406_emp_insert_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1406_emp_insert_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1406_emp_delete")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1406_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1406_emp_campo(l_panel)
    CALL pol1406_emp_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1406_emp_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10),
           l_lupa_cnpj       VARCHAR(10),
           l_lupa_emp        VARCHAR(10)

    LET m_pan_emp = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_emp,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_emp,"HEIGHT",40)
    #CALL _ADVPL_set_property(m_pan_emp,"BACKGROUND_COLOR",225,232,232) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_emp)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","CNPJ:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_cnpj_emp = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_emp)     
    CALL _ADVPL_set_property(m_cnpj_emp,"POSITION",45,10) 
    CALL _ADVPL_set_property(m_cnpj_emp,"LENGTH",19)    
    CALL _ADVPL_set_property(m_cnpj_emp,"VARIABLE",mr_emp,"cnpj")
    CALL _ADVPL_set_property(m_cnpj_emp,"VALID","pol1406_emp_valid_cnpj")
             
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_emp)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",240,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_emp_emp = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_emp)     
    CALL _ADVPL_set_property(m_emp_emp,"POSITION",300,10) 
    CALL _ADVPL_set_property(m_emp_emp,"LENGTH",2)    
    CALL _ADVPL_set_property(m_emp_emp,"VARIABLE",mr_emp,"empresa")
    CALL _ADVPL_set_property(m_emp_emp,"VALID","pol1406_emp_valid_emp")

    LET l_lupa_emp = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_emp)
    CALL _ADVPL_set_property(l_lupa_emp,"POSITION",330,10)     
    CALL _ADVPL_set_property(l_lupa_emp,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa_emp,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa_emp,"CLICK_EVENT","pol1406_zoom_empresa")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_emp)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",370,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Descriçao:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_emp)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",440,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_emp,"descricao")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_emp)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",710,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","UF:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_emp)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",740,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",2)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_emp,"uf")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_emp)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",800,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Gerar romaneio:")    

    LET m_env_aut = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_emp)     
    CALL _ADVPL_set_property(m_env_aut,"POSITION",890,10)     
    CALL _ADVPL_set_property(m_env_aut,"ADD_ITEM","S","Sim")
    CALL _ADVPL_set_property(m_env_aut,"ADD_ITEM","N","Não")
    CALL _ADVPL_set_property(m_env_aut,"VARIABLE",mr_emp,"gerar_om")


    CALL _ADVPL_set_property(m_pan_emp,"ENABLE",FALSE)

END FUNCTION

#--------------------------------------#
FUNCTION pol1406_emp_grade(l_container)#
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
   
    LET m_brz_emp = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_emp,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_emp,"BEFORE_ROW_EVENT","pol1406_emp_before_row")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_emp)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CNPJ")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cnpj")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_emp)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Empresa")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","empresa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_emp)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","descricao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_emp)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","UF")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","uf")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_emp)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Gerar OM")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","gerar_om")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_emp)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_emp,"SET_ROWS",ma_emp,1)
    CALL _ADVPL_set_property(m_brz_emp,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_emp,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_emp,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#--------------------------------#
FUNCTION pol1406_emp_before_row()#
#--------------------------------#
   
   DEFINE l_linha          INTEGER
   
   LET m_op_emp = 'R'
   
   IF m_car_emp THEN
      RETURN TRUE
   END IF
      
   LET l_linha = _ADVPL_get_property(m_brz_emp,"ROW_SELECTED")
   
   IF l_linha IS NULL OR l_linha = 0 THEN
      RETURN TRUE
   END IF
   
   CALL pol1406_emp_set_item(l_linha)         
   CALL pol1406_emp_ativa(TRUE)
   CALL _ADVPL_set_property(m_emp_emp,"GET_FOCUS")
   CALL pol1406_emp_ativa(false)
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1406_emp_set_item(l_linha)#
#-------------------------------------#
   
   DEFINE l_linha     INTEGER
      
   LET mr_emp.cnpj = ma_emp[l_linha].cnpj
   LET mr_emp.empresa = ma_emp[l_linha].empresa
   LET mr_emp.descricao = ma_emp[l_linha].descricao
   LET mr_emp.uf = ma_emp[l_linha].uf
   LET mr_emp.gerar_om = ma_emp[l_linha].gerar_om

END FUNCTION

#-----------------------------------#
FUNCTION pol1406_emp_ativa(l_status)#
#-----------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pan_emp,"ENABLE",l_status)
   
   IF m_op_emp = 'I' THEN
      CALL _ADVPL_set_property(m_cnpj_emp,"ENABLE",l_status)
   ELSE
      CALL _ADVPL_set_property(m_cnpj_emp,"ENABLE",FALSE)
   END IF
         
END FUNCTION

#----------------------------#
FUNCTION pol1406_emp_insert()#
#----------------------------#

   LET m_op_emp = 'I'
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_emp.* TO NULL
   
   CALL pol1406_desativa_folder("3")
   LET m_car_emp = TRUE
   CALL pol1406_emp_ativa(TRUE)
   CALL _ADVPL_set_property(m_cnpj_emp,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1406_emp_insert_canc()#
#---------------------------------#

   CALL pol1406_emp_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1406_ativa_folder()
   CALL _ADVPL_set_property(m_brz_emp,"CLEAR")
   INITIALIZE mr_emp.*, ma_emp TO NULL
   LET m_car_emp = FALSE
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1406_emp_insert_conf()#
#---------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_msg = NULL

   CALL pol1406_emp_valid_form()
   
   IF m_msg IS NOT NULL THEN
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Preencha o formulário.')
      RETURN FALSE
   END IF
      
   IF NOT pol1406_emp_ve_dupl() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
   
   IF NOT pol1406_emp_ins_emp() THEN
      RETURN FALSE
   END IF
   
   CALL pol1406_emp_prepare()
   CALL pol1406_emp_ativa(FALSE)
   CALL pol1406_ativa_folder()
   LET m_car_emp = FALSE
   
   RETURN TRUE

END FUNCTION        
   
#--------------------------------#
FUNCTION pol1406_emp_valid_form()#
#--------------------------------#
      
   IF mr_emp.cnpj IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe o CNPJ\n'
   END IF

   IF mr_emp.empresa IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe o código da empresa\n'
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol1406_emp_ve_dupl()#
#-----------------------------#

   SELECT 1 FROM empresa_api_cairu
    WHERE cnpj = mr_emp.cnpj
   
   IF STATUS = 0 THEN
      LET m_msg = 'CNPJ/Empresa já cadastrados no POL1406'
   ELSE
      IF STATUS = 100 THEN
         RETURN TRUE
      ELSE
         CALL log003_err_sql('SELECT','empresa_api_cairu')
         LET m_msg = 'Erro ',STATUS, ' Lendo tabela empresa_api_cairu '
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#-----------------------------#
FUNCTION pol1406_emp_ins_emp()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   INSERT INTO empresa_api_cairu(
       cnpj,       
       empresa,
       uf, gerar_om)    
    VALUES(mr_emp.cnpj,    
           mr_emp.empresa,
           mr_emp.uf,
           mr_emp.gerar_om)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','empresa_api_cairu')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1406_emp_prepare()#
#-----------------------------#

   DEFINE l_sql_stmt CHAR(2000)
                        
   LET l_sql_stmt =
       " SELECT cnpj, empresa, uf, gerar_om ",
    "  FROM empresa_api_cairu ",
    " WHERE 1 = 1 "

   CALL pol1406_emp_exibe(l_sql_stmt)

END FUNCTION

#--------------------------------------#
FUNCTION pol1406_emp_exibe(l_sql_stmt)#
#--------------------------------------#
   
   DEFINE l_sql_stmt   CHAR(2000),
          l_ind        INTEGER

   CALL _ADVPL_set_property(m_brz_emp,"CLEAR")
   LET m_car_emp = TRUE
   INITIALIZE ma_emp TO NULL
   LET l_ind = 1
   
    PREPARE var_emp FROM l_sql_stmt

    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","empresa_api_cairu:PREPARE")
       RETURN FALSE
    END IF

   DECLARE cq_emp CURSOR FOR var_emp
   
   FOREACH cq_emp INTO 
      ma_emp[l_ind].cnpj,
      ma_emp[l_ind].empresa,
      ma_emp[l_ind].uf,
      ma_emp[l_ind].gerar_om
            
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','cq_emp:01')
         EXIT FOREACH
      END IF
      
      LET ma_emp[l_ind].descricao = pol1406_emp_le_empresa(ma_emp[l_ind].empresa)
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 100 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   IF l_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_emp,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'Não há registros para os parâmetros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   LET m_car_emp = FALSE
        
END FUNCTION

#-------------------------------------#
FUNCTION pol1406_emp_le_empresa(l_cod)#
#-------------------------------------#
   
   DEFINE l_empresa    VARCHAR(36),
          l_cod        CHAR(02)
   
   SELECT den_empresa
     INTO l_empresa
     FROM empresa
    WHERE cod_empresa = l_cod
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa')
      LET l_empresa = ''
   END IF
   
   RETURN l_empresa

END FUNCTION

#--------------------------------#
FUNCTION pol1406_emp_valid_cnpj()#
#--------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   SELECT COUNT(*)
     INTO m_count
     FROM empresa
    WHERE num_cgc = mr_emp.cnpj
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'CNPJ não exixte no cadastro de empresas do Logix'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1406_emp_valid_emp()#
#-------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   SELECT den_empresa, uni_feder
     INTO mr_emp.descricao, mr_emp.uf
     FROM empresa
    WHERE cod_empresa = mr_emp.empresa
      AND num_cgc = mr_emp.cnpj
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1406_zoom_empresa()#
#------------------------------#

    DEFINE l_codigo         LIKE empresa.cod_empresa,
           l_descri         LIKE empresa.den_empresa,
           l_lin_atu        INTEGER
    
    IF m_zoom_emp IS NULL THEN
       LET m_zoom_emp = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_emp,"ZOOM","zoom_empresa")
    END IF
   
    CALL _ADVPL_get_property(m_zoom_emp,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_emp,"RETURN_BY_TABLE_COLUMN","empresa","cod_empresa")
    LET l_descri = _ADVPL_get_property(m_zoom_emp,"RETURN_BY_TABLE_COLUMN","empresa","den_empresa")

    IF l_codigo IS NOT NULL THEN
       LET mr_emp.empresa = l_codigo
       LET mr_emp.descricao = l_descri
    END IF        
    
END FUNCTION

#--------------------------#
FUNCTION pol1406_emp_find()#
#--------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    LET m_op_emp = 'P'
    
    IF m_emp_construct IS NULL THEN
       LET m_emp_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_emp_construct,"CONSTRUCT_NAME","pol1406_FILTER")
       CALL _ADVPL_set_property(m_emp_construct,"ADD_VIRTUAL_TABLE","empresa_api_cairu","parametro")
       CALL _ADVPL_set_property(m_emp_construct,"ADD_VIRTUAL_COLUMN","empresa_api_cairu","cnpj","CNPJ",1 {CHAR},19,0)
       CALL _ADVPL_set_property(m_emp_construct,"ADD_VIRTUAL_COLUMN","empresa_api_cairu","empresa","Empresa",1 {CHAR},2,0)
    END IF

    LET l_status = _ADVPL_get_property(m_emp_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_emp_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_emp_construct,"ORDER_BY")
       CALL pol1406_emp_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#---------------------------------------------------#
FUNCTION pol1406_emp_create_cursor(l_where, l_order)#
#---------------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)
    DEFINE l_ind        INTEGER

    IF l_order IS NULL THEN
       LET l_order = " cnpj "
    END IF
    
    LET l_sql_stmt = 
       " SELECT cnpj, empresa, uf, gerar_om ",
       " FROM empresa_api_cairu ",
        " WHERE ",l_where CLIPPED,
        " ORDER BY ",l_order
   
   CALL pol1406_emp_exibe(l_sql_stmt)
   CALL pol1406_emp_set_item(1)
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1406_emp_prende()#
#-----------------------------#
   
   CALL  LOG_transaction_begin()
   
   DECLARE cq_emp_prende CURSOR FOR
    SELECT 1
      FROM empresa_api_cairu
     WHERE cnpj = mr_emp.cnpj
       AND empresa = mr_emp.empresa
     FOR UPDATE 
    
    OPEN cq_emp_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_emp_prende")
       CALL LOG_transaction_rollback()
       RETURN FALSE
    END IF
    
   FETCH cq_emp_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_emp_prende")
      CALL LOG_transaction_rollback()
      CLOSE cq_emp_prende
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol1406_emp_delete()#
#----------------------------#
   
   DEFINE l_ret   SMALLINT

   IF mr_emp.cnpj IS NULL THEN
      LET m_msg = 'Selecione previamente um item na grade'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1406_emp_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM empresa_api_cairu
     WHERE cnpj = mr_emp.cnpj
       AND empresa = mr_emp.empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','empresa_api_cairu:ed')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_emp.* TO NULL
   ELSE
      CALL LOG_transaction_commit()     
   END IF
   
   CLOSE cq_emp_prende
   CALL pol1406_emp_prepare()
   
   RETURN l_ret
        
END FUNCTION

#---Rotinas cadastro de parâmetros ----#

#-----------------------------#
FUNCTION pol1406_par(l_fpanel)#
#-----------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_inform    VARCHAR(10),
           l_update    VARCHAR(10),
           l_delete    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10),
           l_create    VARCHAR(10),
           l_first     VARCHAR(10),
           l_previous  VARCHAR(10),
           l_next      VARCHAR(10),
           l_last      VARCHAR(10)
           
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1406_par_insert")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1406_par_insert_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1406_par_insert_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1406_par_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1406_par_upd_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1406_par_upd_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1406_par_delete")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1406_par_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1406_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1406_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1406_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1406_last")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1406_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1406_par_campo(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1406_par_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10),
           l_lupa_cnpj       VARCHAR(10),
           l_lupa_cond       VARCHAR(10),
           l_lupa_nat        VARCHAR(10),
           l_lupa_lista      VARCHAR(10),
           l_lupa_local      VARCHAR(10)

    LET m_pan_par = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_container)
    CALL _ADVPL_set_property(m_pan_par,"ALIGN","CENTER")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","CNPJ empresa:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_cnpj_par = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_cnpj_par,"POSITION",100,10) 
    CALL _ADVPL_set_property(m_cnpj_par,"LENGTH",19)    
    CALL _ADVPL_set_property(m_cnpj_par,"VARIABLE",mr_par,"cnpj_empresa")
    CALL _ADVPL_set_property(m_cnpj_par,"VALID","pol1406_par_valid_cnpj")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",280,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_par)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",340,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",2)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_par,"cod_empresa")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",380,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Nat operação:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_nat_par = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_nat_par,"POSITION",470,10) 
    CALL _ADVPL_set_property(m_nat_par,"LENGTH",4)    
    CALL _ADVPL_set_property(m_nat_par,"VARIABLE",mr_par,"cod_nat_oper")
    CALL _ADVPL_set_property(m_nat_par,"VALID","pol1406_par_valid_nat")

    LET l_lupa_nat = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_par)
    CALL _ADVPL_set_property(l_lupa_nat,"POSITION",515,10)     
    CALL _ADVPL_set_property(l_lupa_nat,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa_nat,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa_nat,"CLICK_EVENT","pol1406_zoom_nat")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_par)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",540,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_par,"den_nat_oper")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",830,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Pct comissão:")    
    
    LET m_pct_comis = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_pct_comis,"POSITION",910,10) 
    CALL _ADVPL_set_property(m_pct_comis,"LENGTH",5,2)
    CALL _ADVPL_set_property(m_pct_comis,"PICTURE","@E ##.##")
    CALL _ADVPL_set_property(m_pct_comis,"VARIABLE",mr_par,"pct_comissao")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",1010,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Finalidade:")    
    
    LET m_finalidade = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_finalidade,"POSITION",1070,10) 
    CALL _ADVPL_set_property(m_finalidade,"LENGTH",1)
    CALL _ADVPL_set_property(m_finalidade,"VARIABLE",mr_par,"ies_finalidade")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",1111,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Tem comissão?:")    
    
    LET m_ies_comis = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_ies_comis,"POSITION",1195,10) 
    CALL _ADVPL_set_property(m_ies_comis,"LENGTH",1)
    CALL _ADVPL_set_property(m_ies_comis,"PICTURE","!")
    CALL _ADVPL_set_property(m_ies_comis,"VARIABLE",mr_par,"ies_comissao")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Tip frete:")    
    
    LET m_frete = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_frete,"POSITION",60,40) 
    CALL _ADVPL_set_property(m_frete,"LENGTH",1)
    CALL _ADVPL_set_property(m_frete,"VARIABLE",mr_par,"ies_frete")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",115,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Tip preço:")    
    
    LET m_preco = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_preco,"POSITION",170,40) 
    CALL _ADVPL_set_property(m_preco,"LENGTH",1)
    CALL _ADVPL_set_property(m_preco,"PICTURE","!")
    CALL _ADVPL_set_property(m_preco,"VARIABLE",mr_par,"ies_preco")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",205,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Cond pgto:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_condicao = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_condicao,"POSITION",270,40) 
    CALL _ADVPL_set_property(m_condicao,"LENGTH",4)
    CALL _ADVPL_set_property(m_condicao,"VARIABLE",mr_par,"cod_cnd_pgto")
    CALL _ADVPL_set_property(m_condicao,"VALID","pol1406_par_valid_cond")

    LET l_lupa_cond = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_par)
    CALL _ADVPL_set_property(l_lupa_cond,"POSITION",320,40)     
    CALL _ADVPL_set_property(l_lupa_cond,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa_cond,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa_cond,"CLICK_EVENT","pol1406_zoom_cond")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_par)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",360,40) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_par,"den_cnd_pgto")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",645,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Emb padrão:")    
    
    LET m_preco = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_preco,"POSITION",720,40) 
    CALL _ADVPL_set_property(m_preco,"LENGTH",1)
    CALL _ADVPL_set_property(m_preco,"PICTURE","!")
    CALL _ADVPL_set_property(m_preco,"VARIABLE",mr_par,"ies_embal_padrao")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",765,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Tip emtrega:")    
    
    LET m_entrega = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_entrega,"POSITION",840,40) 
    CALL _ADVPL_set_property(m_entrega,"LENGTH",1)
    CALL _ADVPL_set_property(m_entrega,"VARIABLE",mr_par,"ies_tip_entrega")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",900,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Situação pedido:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_situacao = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_situacao,"POSITION",990,40) 
    CALL _ADVPL_set_property(m_situacao,"LENGTH",1)
    CALL _ADVPL_set_property(m_situacao,"PICTURE","!")
    CALL _ADVPL_set_property(m_situacao,"VARIABLE",mr_par,"ies_sit_pedido")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",1020,40)  
    CALL _ADVPL_set_property(l_label,"TEXT","Tip carteira:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_carteira = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_carteira,"POSITION",1105,40) 
    CALL _ADVPL_set_property(m_carteira,"LENGTH",2)
    CALL _ADVPL_set_property(m_carteira,"PICTURE","@!")
    CALL _ADVPL_set_property(m_carteira,"VARIABLE",mr_par,"cod_tip_carteira")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","Lista preço:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_lista = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_lista,"POSITION",90,70) 
    CALL _ADVPL_set_property(m_lista,"LENGTH",4)
    CALL _ADVPL_set_property(m_lista,"VARIABLE",mr_par,"num_list_preco")
    CALL _ADVPL_set_property(m_lista,"VALID","pol1406_par_valid_lista")

    LET l_lupa_lista = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_par)
    CALL _ADVPL_set_property(l_lupa_lista,"POSITION",130,70)     
    CALL _ADVPL_set_property(l_lupa_lista,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa_lista,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa_lista,"CLICK_EVENT","pol1406_zoom_lista")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_par)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",155,70) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_par,"den_list_preco")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",430,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","Cod repres:")    
    
    LET m_repres = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_repres,"POSITION",505,70) 
    CALL _ADVPL_set_property(m_repres,"LENGTH",4)
    CALL _ADVPL_set_property(m_repres,"VARIABLE",mr_par,"cod_repres")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",590,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","Tip venda:")    
    
    LET m_venda = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_venda,"POSITION",660,70) 
    CALL _ADVPL_set_property(m_venda,"LENGTH",4)
    CALL _ADVPL_set_property(m_venda,"VARIABLE",mr_par,"cod_tip_venda")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",710,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","Moeda:")    
    
    LET m_moeda = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_moeda,"POSITION",760,70) 
    CALL _ADVPL_set_property(m_moeda,"LENGTH",1)
    CALL _ADVPL_set_property(m_moeda,"VARIABLE",mr_par,"cod_moeda")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",800,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","Local estoq:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_local = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_par)     
    CALL _ADVPL_set_property(m_local,"POSITION",875,70) 
    CALL _ADVPL_set_property(m_local,"LENGTH",10)    
    CALL _ADVPL_set_property(m_local,"PICTURE","@!")    
    CALL _ADVPL_set_property(m_local,"VARIABLE",mr_par,"cod_local_estoq")
    CALL _ADVPL_set_property(m_local,"VALID","pol1406_par_valid_local")

    LET l_lupa_nat = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_par)
    CALL _ADVPL_set_property(l_lupa_nat,"POSITION",970,70)     
    CALL _ADVPL_set_property(l_lupa_nat,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa_nat,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa_nat,"CLICK_EVENT","pol1406_zoom_local")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_par)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",1020,70)  
    CALL _ADVPL_set_property(l_label,"TEXT","Checa estoq para:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_bloq_estoq = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_par)
    CALL _ADVPL_set_property(m_bloq_estoq,"POSITION",1130,70)
    CALL _ADVPL_set_property(m_bloq_estoq,"ADD_ITEM","P","Pedido")     
    CALL _ADVPL_set_property(m_bloq_estoq,"ADD_ITEM","R","Romaneio")     
    CALL _ADVPL_set_property(m_bloq_estoq,"VARIABLE",mr_par,"bloqueio_estoque")    

    {LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_par)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",1000,70) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",25)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_par,"den_local")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)}

    CALL _ADVPL_set_property(m_pan_par,"ENABLE",FALSE)

END FUNCTION

#--------------------------------#
FUNCTION pol1406_par_valid_cnpj()#
#--------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF m_op_par = 'I' THEN
      SELECT 1 FROM par_api_cairu
       WHERE cnpj_empresa = mr_par.cnpj_empresa
      IF STATUS = 0 THEN
         LET m_msg = 'Esse CNPJ já tem parâmetros cadastrados'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   END IF
   
   SELECT empresa
     INTO mr_par.cod_empresa
     FROM empresa_api_cairu
    WHERE cnpj = mr_par.cnpj_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa_api_cairu')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1406_par_valid_nat()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   SELECT den_nat_oper
     INTO mr_par.den_nat_oper
     FROM nat_operacao
    WHERE cod_nat_oper = mr_par.cod_nat_oper
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','nat_operacao')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1406_zoom_nat()#
#--------------------------#

    DEFINE l_codigo         LIKE nat_operacao.cod_nat_oper,
           l_descri         LIKE nat_operacao.den_nat_oper
    
    IF m_zoom_nat IS NULL THEN
       LET m_zoom_nat = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_nat,"ZOOM","zoom_nat_operacao")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_nat,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_nat,"RETURN_BY_TABLE_COLUMN","nat_operacao","cod_nat_oper")
    LET l_descri = _ADVPL_get_property(m_zoom_nat,"RETURN_BY_TABLE_COLUMN","nat_operacao","den_nat_oper")

    IF l_codigo IS NOT NULL THEN
       LET mr_par.cod_nat_oper = l_codigo
       LET mr_par.den_nat_oper = l_descri
    END IF        
    
    CALL _ADVPL_set_property(m_nat_par,"GET_FOCUS")
    
END FUNCTION

#--------------------------------#
FUNCTION pol1406_par_valid_cond()#
#--------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   SELECT den_cnd_pgto
     INTO mr_par.den_cnd_pgto
     FROM cond_pgto
    WHERE cod_cnd_pgto = mr_par.cod_cnd_pgto
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cond_pgto')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1406_zoom_cond()#
#---------------------------#

    DEFINE l_codigo         LIKE cond_pgto.cod_cnd_pgto,
           l_descri         LIKE cond_pgto.den_cnd_pgto
    
    IF m_zoom_cond IS NULL THEN
       LET m_zoom_cond = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_cond,"ZOOM","zoom_cond_pgto")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_cond,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_cond,"RETURN_BY_TABLE_COLUMN","cond_pgto","cod_cnd_pgto")
    LET l_descri = _ADVPL_get_property(m_zoom_cond,"RETURN_BY_TABLE_COLUMN","cond_pgto","den_cnd_pgto")

    IF l_codigo IS NOT NULL THEN
       LET mr_par.cod_cnd_pgto = l_codigo
       LET mr_par.den_cnd_pgto = l_descri
    END IF        
    
    CALL _ADVPL_set_property(m_condicao,"GET_FOCUS")
    
END FUNCTION

#---------------------------------#
FUNCTION pol1406_par_valid_lista()#
#---------------------------------#

   DEFINE l_empresa     CHAR(02)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   SELECT empresa
     INTO l_empresa
     FROM empresa_api_cairu
    WHERE cnpj = mr_par.cnpj_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa_api_cairu')
      RETURN FALSE
   END IF
   
   SELECT den_list_preco
     INTO mr_par.den_list_preco
     FROM desc_preco_mest
    WHERE cod_empresa = l_empresa
      AND num_list_preco = mr_par.num_list_preco
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','desc_preco_mest')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1406_zoom_lista()#
#----------------------------#

    DEFINE l_codigo         LIKE desc_preco_mest.num_list_preco,
           l_descri         LIKE desc_preco_mest.den_list_preco,
           l_where_clause   VARCHAR(500),
           l_empresa        CHAR(02)
   
   SELECT empresa
     INTO l_empresa
     FROM empresa_api_cairu
    WHERE cnpj = mr_par.cnpj_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa_api_cairu')
      RETURN FALSE
   END IF
    
    IF m_zoom_lista IS NULL THEN
       LET m_zoom_lista = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_lista,"ZOOM","zoom_desc_preco_mest")
    END IF

    LET l_where_clause = " desc_preco_mest.cod_empresa = '",l_empresa,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_lista,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_lista,"RETURN_BY_TABLE_COLUMN","desc_preco_mest","num_list_preco")
    LET l_descri = _ADVPL_get_property(m_zoom_lista,"RETURN_BY_TABLE_COLUMN","desc_preco_mest","den_list_preco")

    IF l_codigo IS NOT NULL THEN
       LET mr_par.num_list_preco = l_codigo
       LET mr_par.den_list_preco = l_descri
    END IF        
    
    CALL _ADVPL_set_property(m_lista,"GET_FOCUS")
    
END FUNCTION

#---------------------------------#
FUNCTION pol1406_par_valid_local()#
#---------------------------------#

   DEFINE l_empresa     CHAR(02)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_par.cod_local_estoq IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT empresa
     INTO l_empresa
     FROM empresa_api_cairu
    WHERE cnpj = mr_par.cnpj_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa_api_cairu')
      RETURN FALSE
   END IF
   
   SELECT den_local
     INTO mr_par.den_local
     FROM local
    WHERE cod_empresa = l_empresa
      AND cod_local = mr_par.cod_local_estoq
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','local')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1406_zoom_local()#
#----------------------------#

    DEFINE l_codigo         LIKE local.cod_local,
           l_descri         LIKE local.den_local,
           l_where_clause   VARCHAR(500),
           l_empresa        CHAR(02)
   
   SELECT empresa
     INTO l_empresa
     FROM empresa_api_cairu
    WHERE cnpj = mr_par.cnpj_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa_api_cairu')
      RETURN FALSE
   END IF
    
    IF m_zoom_local IS NULL THEN
       LET m_zoom_local = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_local,"ZOOM","zoom_local")
    END IF

    LET l_where_clause = " local.cod_empresa = '",l_empresa,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_local,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_local,"RETURN_BY_TABLE_COLUMN","local","cod_local")
    LET l_descri = _ADVPL_get_property(m_zoom_local,"RETURN_BY_TABLE_COLUMN","local","den_local")

    IF l_codigo IS NOT NULL THEN
       LET mr_par.cod_local_estoq = l_codigo
       LET mr_par.den_local = l_descri
    END IF        
    
    CALL _ADVPL_set_property(m_local,"GET_FOCUS")
    
END FUNCTION

#----------------------------#
FUNCTION pol1406_par_insert()#
#----------------------------#

   LET m_op_par = 'I'
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_par.* TO NULL
   LET m_ies_cons = FALSE
   
   CALL pol1406_desativa_folder("4")
   CALL pol1406_par_ativa(TRUE)
   CALL pol1406_par_default()
   CALL _ADVPL_set_property(m_cnpj_par,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1406_par_insert_canc()#
#---------------------------------#

   CALL pol1406_par_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1406_ativa_folder()
   INITIALIZE mr_par.* TO NULL
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1406_par_insert_conf()#
#---------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_msg = NULL

   CALL pol1406_par_valid_form()
   
   IF m_msg IS NOT NULL THEN
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Preencha corretamente o formulário.')
      RETURN FALSE
   END IF
   
   CALL pol1406_par_default()
   
   CALL LOG_transaction_begin()
   
   IF NOT pol1406_par_ins_par() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   CALL pol1406_par_ativa(FALSE)
   CALL pol1406_ativa_folder()
   
   RETURN TRUE

END FUNCTION        

#-----------------------------------#
FUNCTION pol1406_par_ativa(l_status)#
#-----------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pan_par,"ENABLE",l_status)
   
   IF m_op_par = 'I' THEN
      CALL _ADVPL_set_property(m_cnpj_par,"ENABLE",l_status)
   ELSE
      CALL _ADVPL_set_property(m_cnpj_par,"ENABLE",FALSE)
   END IF
         
END FUNCTION

#-----------------------------#
FUNCTION pol1406_par_default()#
#-----------------------------#

   IF mr_par.pct_comissao IS NULL THEN
      LET mr_par.pct_comissao = 0
   END IF
   
   IF mr_par.ies_finalidade IS NULL THEN
      LET mr_par.ies_finalidade = 1
   END IF

   IF mr_par.ies_frete IS NULL THEN
      LET mr_par.ies_frete = 3
   END IF
   
   IF mr_par.ies_preco IS NULL THEN
      LET mr_par.ies_preco = 'R'
   END IF

   IF mr_par.ies_embal_padrao IS NULL THEN
      LET mr_par.ies_embal_padrao = '3'
   END IF

   IF mr_par.ies_tip_entrega IS NULL THEN
      LET mr_par.ies_tip_entrega = 1
   END IF

   IF mr_par.ies_sit_pedido IS NULL THEN
      LET mr_par.ies_sit_pedido = 'E'
   END IF

   IF mr_par.cod_tip_venda IS NULL THEN
      LET mr_par.cod_tip_venda = 1
   END IF

   IF mr_par.cod_moeda IS NULL THEN
      LET mr_par.cod_moeda = 1
   END IF

   IF mr_par.ies_comissao IS NULL THEN
      LET mr_par.ies_comissao = 'N'
   END IF

END FUNCTION

#--------------------------------#
FUNCTION pol1406_par_valid_form()#
#--------------------------------#

   IF mr_par.cod_nat_oper IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe a natureza de operação\n'
   END IF
   
   IF mr_par.cod_cnd_pgto IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe a condição de pagamento\n'
   END IF

   IF mr_par.num_list_preco IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe a lista de preço\n'
   END IF

   IF mr_par.cod_tip_carteira IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe o tipo de carteira\n'
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol1406_par_ins_par()#
#-----------------------------#

   INSERT INTO par_api_cairu (
      cnpj_empresa,    
      cod_nat_oper,    
      pct_comissao,    
      ies_finalidade,  
      ies_frete,       
      ies_preco,       
      cod_cnd_pgto,    
      ies_embal_padrao,
      ies_tip_entrega, 
      ies_sit_pedido,  
      num_list_preco,  
      cod_repres,      
      cod_tip_venda,   
      cod_moeda,       
      ies_comissao,    
      cod_tip_carteira,
      cod_local_estoq,
      bloqueio_estoque)
   VALUES(mr_par.cnpj_empresa,     
          mr_par.cod_nat_oper,    
          mr_par.pct_comissao,    
          mr_par.ies_finalidade,  
          mr_par.ies_frete,       
          mr_par.ies_preco,       
          mr_par.cod_cnd_pgto,    
          mr_par.ies_embal_padrao,
          mr_par.ies_tip_entrega, 
          mr_par.ies_sit_pedido,  
          mr_par.num_list_preco,  
          mr_par.cod_repres,      
          mr_par.cod_tip_venda,   
          mr_par.cod_moeda,       
          mr_par.ies_comissao,    
          mr_par.cod_tip_carteira,
          mr_par.cod_local_estoq,
          mr_par.bloqueio_estoque) 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','par_api_cairu')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1406_par_find()#
#--------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    LET m_op_par = 'P'
    LET m_cnpj_empresa = m_cnpj_empresaa
    
    IF m_par_construct IS NULL THEN
       LET m_par_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_par_construct,"CONSTRUCT_NAME","pol1406_FILTER")
       CALL _ADVPL_set_property(m_par_construct,"ADD_VIRTUAL_TABLE","par_api_cairu","parametro")
       CALL _ADVPL_set_property(m_par_construct,"ADD_VIRTUAL_COLUMN","par_api_cairu","cnpj_empresa","CNPJ",1 {CHAR},19,0)
       CALL _ADVPL_set_property(m_par_construct,"ADD_VIRTUAL_COLUMN","par_api_cairu","cod_nat_oper","Nat operação",1 {INT},4,0)
       CALL _ADVPL_set_property(m_par_construct,"ADD_VIRTUAL_COLUMN","par_api_cairu","cod_tip_carteira","CNPJ",1 {CHAR},2,0)
       CALL _ADVPL_set_property(m_par_construct,"ADD_VIRTUAL_COLUMN","par_api_cairu","cod_repres","Nat operação",1 {INT},4,0)
    END IF

    LET l_status = _ADVPL_get_property(m_par_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_par_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_par_construct,"ORDER_BY")
       CALL pol1406_par_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#---------------------------------------------------#
FUNCTION pol1406_par_create_cursor(l_where, l_order)#
#---------------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)
    DEFINE l_ind        INTEGER

    IF l_order IS NULL THEN
       LET l_order = " cnpj_empresa "
    END IF
    
    LET l_sql_stmt = 
       " SELECT cnpj_empresa ",
       " FROM par_api_cairu ",
        " WHERE ",l_where CLIPPED,
        " ORDER BY ",l_order

   PREPARE var_pesq_par FROM l_sql_stmt
    
   IF  Status <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","prepare:var_pesq_par")
       RETURN 
   END IF   

   DECLARE cq_cons SCROLL CURSOR WITH HOLD FOR var_pesq_par
      
   OPEN cq_cons

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE","OPEN:cq_cons")
       RETURN 
   END IF

   FETCH cq_cons INTO m_cnpj_empresa


   IF STATUS <> 0 THEN
      IF STATUS <> 100 THEN
         CALL log003_err_sql("FETCH CURSOR","cq_cons")
      ELSE
         LET m_msg = 'Não a dados, para os argumentos informados.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN 
   END IF
   
   CALL pol1406_par_exibe_dados() RETURNING p_status

   LET m_cnpj_empresaa = m_cnpj_empresa
   LET m_ies_cons = TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1406_par_exibe_dados()#
#---------------------------------#
   
   LET m_excluiu = FALSE
   
   SELECT cnpj_empresa,    
          cod_nat_oper,    
          pct_comissao,    
          ies_finalidade,  
          ies_frete,       
          ies_preco,       
          cod_cnd_pgto,    
          ies_embal_padrao,
          ies_tip_entrega, 
          ies_sit_pedido,  
          num_list_preco,  
          cod_repres,      
          cod_tip_venda,   
          cod_moeda,       
          ies_comissao,    
          cod_tip_carteira,
          cod_local_estoq,
          bloqueio_estoque
     INTO mr_par.cnpj_empresa,      
          mr_par.cod_nat_oper,         
          mr_par.pct_comissao,         
          mr_par.ies_finalidade,       
          mr_par.ies_frete,            
          mr_par.ies_preco,            
          mr_par.cod_cnd_pgto,         
          mr_par.ies_embal_padrao,     
          mr_par.ies_tip_entrega,      
          mr_par.ies_sit_pedido,       
          mr_par.num_list_preco,       
          mr_par.cod_repres,           
          mr_par.cod_tip_venda,        
          mr_par.cod_moeda,            
          mr_par.ies_comissao,         
          mr_par.cod_tip_carteira,     
          mr_par.cod_local_estoq,
          mr_par.bloqueio_estoque    
     FROM par_api_cairu
    WHERE cnpj_empresa = m_cnpj_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("SELECT","par_api_cairu")
      RETURN FALSE
   END IF
   
   CALL pol1406_par_valid_cnpj() RETURNING p_status
   CALL pol1406_par_valid_nat() RETURNING p_status
   CALL pol1406_par_valid_cond() RETURNING p_status
   CALL pol1406_par_valid_lista() RETURNING p_status
   CALL pol1406_par_valid_local() RETURNING p_status
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1406_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1406_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_cnpj_empresaa = m_cnpj_empresa

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_cnpj_empresa
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_cnpj_empresa
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_cnpj_empresa
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_cnpj_empresa
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_cnpj_empresa = m_cnpj_empresaa
         EXIT WHILE
      ELSE
         SELECT 1
           FROM par_api_cairu
          WHERE cnpj_empresa = m_cnpj_empresa
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1406_par_exibe_dados() RETURNING p_status
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

#--------------------------#
FUNCTION pol1406_ies_cons()#
#--------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", "")
   
   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa. Faça uma pesquisa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1406_first()#
#-----------------------#

   IF NOT pol1406_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1406_next()#
#----------------------#

   IF NOT pol1406_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1406_previous()#
#--------------------------#

   IF NOT pol1406_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1406_last()#
#----------------------#

   IF NOT pol1406_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#------------------------------#
 FUNCTION pol1406_par_prende()#
#------------------------------#
   
   CALL LOG_transaction_begin()
   
   DECLARE cq_par_prende CURSOR FOR
    SELECT 1
      FROM par_api_cairu
     WHERE cnpj_empresa = m_cnpj_empresa
     FOR UPDATE 
    
    OPEN cq_par_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_par_prende")
       CALL LOG_transaction_rollback()
       RETURN FALSE
    END IF
    
   FETCH cq_par_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_par_prende")
      CALL LOG_transaction_rollback()
      CLOSE cq_par_prende
      RETURN FALSE
   END IF

END FUNCTION
   
#-----------------------------#
FUNCTION pol1406_par_update()#
#-----------------------------#   
   
      
   IF NOT pol1406_ies_cons() THEN
      RETURN FALSE
   END IF

   IF m_excluiu THEN
      LET m_msg = 'Selecione previamente um regsitro'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1406_par_prende() THEN
      RETURN FALSE
   END IF
   
   LET m_op_par = 'M'
   CALL pol1406_par_ativa(TRUE)
   CALL _ADVPL_set_property(m_nat_par,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1406_par_upd_canc()#
#----------------------------------#   
   
   CLOSE cq_par_prende
   CALL LOG_transaction_rollback()
   
   INITIALIZE mr_par.* TO NULL
   
   CALL pol1406_par_exibe_dados() RETURNING p_status         
   CALL pol1406_par_ativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1406_par_upd_conf()#
#----------------------------------#   
   
   CALL pol1406_par_default()
   
   UPDATE par_api_cairu 
      SET cod_nat_oper       = mr_par.cod_nat_oper,     
          pct_comissao       = mr_par.pct_comissao,    
          ies_finalidade     = mr_par.ies_finalidade,  
          ies_frete          = mr_par.ies_frete,       
          ies_preco          = mr_par.ies_preco,       
          cod_cnd_pgto       = mr_par.cod_cnd_pgto,    
          ies_embal_padrao   = mr_par.ies_embal_padrao,
          ies_tip_entrega    = mr_par.ies_tip_entrega, 
          ies_sit_pedido     = mr_par.ies_sit_pedido,  
          num_list_preco     = mr_par.num_list_preco,  
          cod_repres         = mr_par.cod_repres,      
          cod_tip_venda      = mr_par.cod_tip_venda,   
          cod_moeda          = mr_par.cod_moeda,       
          ies_comissao       = mr_par.ies_comissao,    
          cod_tip_carteira   = mr_par.cod_tip_carteira,
          cod_local_estoq    = mr_par.cod_local_estoq,
          bloqueio_estoque   = mr_par.bloqueio_estoque
    WHERE cnpj_empresa = m_cnpj_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','par_api_cairu')
      CALL pol1406_par_update_canc()
      RETURN FALSE
   END IF
      
   CALL LOG_transaction_commit()
   
   CLOSE cq_par_prende
   CALL pol1406_par_ativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1406_par_delete()#
#----------------------------#
   
   DEFINE l_ret   SMALLINT

   IF NOT pol1406_ies_cons() THEN
      RETURN FALSE
   END IF

   IF m_excluiu THEN
      LET m_msg = 'Não há dados na tela a serem excluídos'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1406_par_prende() THEN
      RETURN FALSE
   END IF

   LET l_ret = FALSE

   DELETE FROM par_api_cairu
    WHERE cnpj_empresa = m_cnpj_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','par_api_cairu')
   ELSE
      LET l_ret = TRUE
   END IF
      
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_par.* TO NULL
      LET m_excluiu = TRUE
   ELSE
      CALL LOG_transaction_commit()     
   END IF
   
   CLOSE cq_par_prende
   
   RETURN l_ret
        
END FUNCTION

   