#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1311                                                 #
# OBJETIVO: RELACIONAMENTO AEN X LOCAL SGIURD                       #
# AUTOR...: IVO                                                     #
# DATA....: 13/10/16                                                #
#-------------------------------------------------------------------#
{
COD_LIN_PROD            NUMBER(2)     
COD_LIN_RECEI           NUMBER(2)     
COD_SEG_MERC            NUMBER(2)     
COD_CLA_USO             NUMBER(2)     
COD_IGREJA              CHAR(12)      
PRC_AEN                 NUMBER(6,2)   
DT_ATUALIZACAO          DATE          
COD_USUARIO             VARCHAR2(255) 
ORIGEM_GRAV             CHAR(1)       


Alimentar da seguinte forma:


Prc_aen                               ?  sempre 100%
DT_ATUALIZACAO           ? data que incluiu ou alterou 
COD_USUARIO                ? Código do usuário que incluiu ou alterou     
ORIGEM_GRAV                ? ‘X’ indica que a alteração foi feita pelo Logix. 
}

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003)
           
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_cod_aen         VARCHAR(10),
       m_den_aen         VARCHAR(10),
       m_zoom_aen        VARCHAR(10),
       m_lupa_aen        VARCHAR(10),
       m_cod_igreja      VARCHAR(10),
       m_den_igreja      VARCHAR(10),
       m_zoom_igreja     VARCHAR(10),
       m_lupa_igreja     VARCHAR(10),
       m_construct       VARCHAR(10),
       m_browse          VARCHAR(10)

DEFINE m_cod_tipo        VARCHAR(10),
       m_den_tipo        VARCHAR(10),
       m_cod_regiao      VARCHAR(10),
       m_den_regiao      VARCHAR(10),
       m_cod_area        VARCHAR(10),
       m_den_area        VARCHAR(10),
       m_cod_estado      VARCHAR(10),
       m_den_estado      VARCHAR(10)
       
       

DEFINE m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_lin_pord        DECIMAL(2,0),
       m_lin_recei       DECIMAL(2,0),
       m_seg_merc        DECIMAL(2,0),
       m_cla_uso         DECIMAL(2,0),
       m_cod_local       CHAR(12),
       m_id_registro     INTEGER,
       m_id_registroa    INTEGER,
       m_index           INTEGER,
       m_qtd_aen         INTEGER,
       m_cod_linha       CHAR(08),
       m_where           CHAR(800),
       m_order           CHAR(200),
       m_page_length     INTEGER
       
DEFINE mr_campos         RECORD
       cod_aen           CHAR(08),
       den_aen           CHAR(30),
       cod_igreja        CHAR(12),
       den_igreja        CHAR(255),
       cod_tipo          DECIMAL(5,0),
       den_tipo          CHAR(255),
       cod_regiao        DECIMAL(5,0),      
       den_regiao        CHAR(255),
       cod_area          DECIMAL(5,0),      
       den_area          CHAR(255),
       cod_estado        CHAR(03),      
       den_estado        CHAR(255),
       prc_aen           DECIMAL(6,2),   
       dt_atualizacao    DATE,          
       cod_usuario       CHAR(08), 
       origem_grav       CHAR(01)              
END RECORD

DEFINE ma_hist           ARRAY[3000] OF RECORD
       dat_hor           DATE,
       historico         CHAR(120)
END RECORD

DEFINE   m_form_popup   VARCHAR(10),
         m_bar_popup    VARCHAR(10),
         m_const_popup  VARCHAR(10),
         m_brow_popup   VARCHAR(10),
         m_form_aen     VARCHAR(10),
         m_bar_aen      VARCHAR(10),
         m_const_aen    VARCHAR(10),
         m_brow_aen     VARCHAR(10)

DEFINE mr_parametro      RECORD
       cod_tipo          DECIMAL(5,0),
       den_tipo          CHAR(255),
       cod_regiao        DECIMAL(5,0),      
       den_regiao        CHAR(255),
       cod_area          DECIMAL(5,0),      
       den_area          CHAR(255),
       cod_estado        CHAR(03),      
       den_estado        CHAR(255)
END RECORD

DEFINE ma_local          ARRAY[20000] OF RECORD
       cod_igreja        CHAR(12),
       den_igreja        CHAR(255),
       den_local         CHAR(255),
       den_uf            CHAR(255),
       den_area          CHAR(255),
       den_regiao        CHAR(255)
       
END RECORD

DEFINE ma_linha          ARRAY[5000] OF RECORD
       cod_linha         CHAR(08),
       descricao         CHAR(30)
END RECORD

DEFINE mr_audit      RECORD
       cod_empresa   LIKE audit_logix.cod_empresa,
       texto         LIKE audit_logix.texto,
       num_programa  LIKE audit_logix.num_programa,
       usuario       LIKE audit_logix.usuario
END RECORD

DEFINE mr_relat          RECORD
       cod_aen           CHAR(08),
       den_aen           CHAR(30),
       cod_local         CHAR(12),
       den_local         CHAR(40),
       cod_tipo          DECIMAL(5,0),
       den_tipo          CHAR(20),
       cod_regiao        DECIMAL(5,0),      
       den_regiao        CHAR(20),
       cod_bloco         DECIMAL(5,0),      
       den_bloco         CHAR(20),
       cod_estado        CHAR(03),      
       den_estado        CHAR(20)
END RECORD
         
#-----------------#
FUNCTION pol1311()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1311-12.00.11  "
   CALL func002_versao_prg(p_versao)
   LET g_tipo_sgbd = LOG_getCurrentDBType()   
   
   CALL pol1311_cria_tab()
   CALL pol1311_menu()
    
END FUNCTION

#--------------------------#
FUNCTION pol1311_cria_tab()#
#--------------------------#

    CREATE TEMP TABLE w_hist_tmp (
     cod_pais          CHAR(03), 
     cod_estado        CHAR(03), 
     cod_area          DECIMAL(5,0), 
     cod_regiao        DECIMAL(5,0) 
    );
    
    CREATE INDEX ix_w_hist_tmp ON 
     w_hist_tmp(cod_pais, cod_estado, cod_area, cod_regiao );

END FUNCTION

#----------------------#
FUNCTION pol1311_menu()#
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
           l_delete, l_print  VARCHAR(10)
    
    LET mr_audit.cod_empresa = p_cod_empresa
    LET mr_audit.num_programa = 'POL1311'
    LET mr_audit.usuario = p_user
        
    CALL pol1311_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE","RELACIONAMENTO AEN X LOCAL SGIURD")
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1311_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1311_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1311_create_cancel")
    
    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1311_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1311_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1311_update_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1311_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1311_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1311_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1311_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1311_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1311_delete")

    LET l_print = _ADVPL_create_component(NULL,"LPRINTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_print,"EVENT","pol1311_print")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1311_cria_campos(l_panel)
    CALL pol1311_historico(l_panel)

    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

    CALL pol1311_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1311_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_top             VARCHAR(10),
           l_right           VARCHAR(10),
           l_caixa           VARCHAR(10)

    LET l_top = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_top,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_top,"HEIGHT",150)
    CALL _ADVPL_set_property(l_top,"BACKGROUND_COLOR",225,232,232) 

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_top)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")

    LET l_right = _ADVPL_create_component(NULL,"LPANEL",l_top)
    CALL _ADVPL_set_property(l_right,"ALIGN","CENTER")    
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",5)

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW") 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Área de negócio:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_aen = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_aen,"LENGTH",8)
    CALL _ADVPL_set_property(m_cod_aen,"VARIABLE",mr_campos,"cod_aen")
    CALL _ADVPL_set_property(m_cod_aen,"PICTURE","########")
    CALL _ADVPL_set_property(m_cod_aen,"VALID","pol1311_valida_aen")

    LET m_lupa_aen = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_aen,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_aen,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_aen,"CLICK_EVENT","pol1311_zoom_linha")
    
    LET m_den_aen = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_aen,"LENGTH",30) 
    CALL _ADVPL_set_property(m_den_aen,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_den_aen,"VARIABLE",mr_campos,"den_aen")

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Local SGIURD:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_igreja = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_igreja,"LENGTH",12)
    CALL _ADVPL_set_property(m_cod_igreja,"VARIABLE",mr_campos,"cod_igreja")
    CALL _ADVPL_set_property(m_cod_igreja,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_igreja,"VALID","pol1311_valida_igreja")

    LET m_lupa_igreja = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_igreja,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_igreja,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_igreja,"CLICK_EVENT","pol1311_zoom_igreja")

    LET m_den_igreja = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_igreja,"LENGTH",50) 
    CALL _ADVPL_set_property(m_den_igreja,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_den_igreja,"VARIABLE",mr_campos,"den_igreja")

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Tipo de local:")    

    LET m_cod_tipo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_tipo,"LENGTH",12)
    CALL _ADVPL_set_property(m_cod_tipo,"VARIABLE",mr_campos,"cod_tipo")
    CALL _ADVPL_set_property(m_cod_tipo,"EDITABLE",FALSE) 

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_den_tipo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_tipo,"LENGTH",50)
    CALL _ADVPL_set_property(m_den_tipo,"VARIABLE",mr_campos,"den_tipo")
    CALL _ADVPL_set_property(m_den_tipo,"EDITABLE",FALSE) 

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Regional SGIURD:")    

    LET m_cod_regiao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_regiao,"LENGTH",12)
    CALL _ADVPL_set_property(m_cod_regiao,"VARIABLE",mr_campos,"cod_regiao")
    CALL _ADVPL_set_property(m_cod_regiao,"EDITABLE",FALSE) 

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_den_regiao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_regiao,"LENGTH",50)
    CALL _ADVPL_set_property(m_den_regiao,"VARIABLE",mr_campos,"den_regiao")
    CALL _ADVPL_set_property(m_den_regiao,"EDITABLE",FALSE) 

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Bloco SGIURD:")    

    LET m_cod_area = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_area,"LENGTH",12)
    CALL _ADVPL_set_property(m_cod_area,"VARIABLE",mr_campos,"cod_area")
    CALL _ADVPL_set_property(m_cod_area,"EDITABLE",FALSE) 

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_den_area = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_area,"LENGTH",50)
    CALL _ADVPL_set_property(m_den_area,"VARIABLE",mr_campos,"den_area")
    CALL _ADVPL_set_property(m_den_area,"EDITABLE",FALSE) 

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Estadual SGIURD:")    

    LET m_cod_estado = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_estado,"LENGTH",12)
    CALL _ADVPL_set_property(m_cod_estado,"VARIABLE",mr_campos,"cod_estado")
    CALL _ADVPL_set_property(m_cod_estado,"EDITABLE",FALSE) 

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_den_estado = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_estado,"LENGTH",50)
    CALL _ADVPL_set_property(m_den_estado,"VARIABLE",mr_campos,"den_estado")
    CALL _ADVPL_set_property(m_den_estado,"EDITABLE",FALSE) 

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_right)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",2)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Pct aen:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",3)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_campos,"prc_aen")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Data:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_campos,"dt_atualizacao")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Usuario:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",8)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_campos,"cod_usuario")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Origem:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",2)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_campos,"origem_grav")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 


END FUNCTION

#--------------------------------------#
FUNCTION pol1311_historico(l_container)#
#--------------------------------------#

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
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Data/Hora")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_hor")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Histórico")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    #CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",800)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","historico")

    {LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",10)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")}

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_hist,1)

END FUNCTION

#-----------------------------#
FUNCTION pol1311_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
   INITIALIZE ma_hist TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1311_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   IF m_opcao = 'M' THEN
      CALL _ADVPL_set_property(m_cod_aen,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_lupa_aen,"EDITABLE",FALSE)
   ELSE
      CALL _ADVPL_set_property(m_cod_aen,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_lupa_aen,"EDITABLE",l_status)
   END IF
   
   CALL _ADVPL_set_property(m_cod_igreja,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_igreja,"EDITABLE",l_status)

END FUNCTION

#-----------------------#
FUNCTION pol1311_create()
#-----------------------#
    
    LET m_opcao = 'I'    
    CALL pol1311_limpa_campos()
    CALL pol1311_ativa_desativa(TRUE)
    LET mr_campos.prc_aen = 100
    LET mr_campos.cod_usuario = p_user
    LET mr_campos.dt_atualizacao = TODAY
    LET mr_campos.origem_grav = 'X'
    LET m_ies_cons = FALSE
    
    CALL _ADVPL_set_property(m_cod_aen,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1311_create_confirm()
#-------------------------------#
   
   SELECT MAX(id_registro)
     INTO m_id_registro
    FROM linha_prod_sgiurd_912

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','linha_prod_sgiurd_912:ID')
      RETURN FALSE
   END IF
   
   IF m_id_registro IS NULL THEN
     LET m_id_registro = 0
   END IF
   
   LET m_id_registro = m_id_registro + 1
     
   INSERT INTO linha_prod_sgiurd_912(
     id_registro,
     cod_lin_prod, 
     cod_lin_recei,
     cod_seg_merc, 
     cod_cla_uso,  
     cod_igreja,
     prc_aen,
     dt_atualizacao,
     cod_usuario,
     origem_grav)   
   VALUES(m_id_registro,
          m_lin_pord,
          m_lin_recei,
          m_seg_merc,
          m_cla_uso,
          mr_campos.cod_igreja,
          mr_campos.prc_aen,
          mr_campos.dt_atualizacao,
          mr_campos.cod_usuario,
          mr_campos.origem_grav)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','linha_prod_sgiurd_912')
      RETURN FALSE
   END IF

   LET mr_audit.texto = 'INCLUSAO DA AEN ', mr_campos.cod_aen
   LET p_status = func002_grava_auadit(mr_audit.*)
            
   CALL pol1311_ativa_desativa(FALSE)

   RETURN TRUE
        
END FUNCTION

#-------------------------------#
FUNCTION pol1311_create_cancel()#
#-------------------------------#

    CALL pol1311_ativa_desativa(FALSE)
    CALL pol1311_limpa_campos()
    
    RETURN TRUE
        
END FUNCTION

#--------------------------#
FUNCTION pol1311_zoom_aen()#
#--------------------------#

    DEFINE l_codigo    CHAR(08),
           l_descricao CHAR(30)
    
    IF  m_zoom_aen IS NULL THEN
        LET m_zoom_aen = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_aen,"ZOOM","zoom_aen")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_aen,"ACTIVATE")


    LET l_codigo    = _ADVPL_get_property(m_zoom_aen,"RETURN_BY_TABLE_COLUMN","linha_prod","cod_aen")
    LET l_descricao = _ADVPL_get_property(m_zoom_aen,"RETURN_BY_TABLE_COLUMN","linha_prod","den_estr_linprod")

    IF  l_codigo IS NOT NULL THEN
        LET mr_campos.cod_aen = l_codigo
        LET mr_campos.den_aen = l_descricao
    END IF

END FUNCTION

#----------------------------#
FUNCTION pol1311_valida_aen()#
#----------------------------#
    
    CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
    IF  mr_campos.cod_aen IS NULL THEN
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a AEN.")
        RETURN FALSE
    END IF
   
   CALL pol1311_separa_aen(mr_campos.cod_aen)
   
   IF NOT pol1311_le_aen() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF pol1311_aen_existe() THEN
      LET m_msg = 'AEN já cadastrado no POL1311.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1311_aen_existe()#
#----------------------------#

   SELECT 1
     FROM linha_prod_sgiurd_912
    WHERE cod_lin_prod =  m_lin_pord
      AND cod_lin_recei = m_lin_recei
      AND cod_seg_merc = m_seg_merc
      AND cod_cla_uso = m_cla_uso
   
   IF STATUS = 100 THEN
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','linha_prod_sgiurd_912')
      END IF
   END IF   
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1311_separa_aen(l_cod)#
#---------------------------------#
   
   DEFINE l_cod      CHAR(08)
   
   LET m_lin_pord = l_cod[1,2]
   LET m_lin_recei = l_cod[3,4]
   LET m_seg_merc = l_cod[5,6]
   LET m_cla_uso = l_cod[7,8]

END FUNCTION

#------------------------#
FUNCTION pol1311_le_aen()#
#------------------------#
   
   LET m_msg = ''
   LET mr_campos.den_aen = ''
   
   SELECT den_estr_linprod
     INTO mr_campos.den_aen
     FROM linha_prod
    WHERE cod_lin_prod =  m_lin_pord
      AND cod_lin_recei = m_lin_recei
      AND cod_seg_merc = m_seg_merc
      AND cod_cla_uso = m_cla_uso
   
   IF STATUS = 100 THEN
      LET m_msg = 'AEN inexistente no logix.'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','linha_prod')   
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1311_local_ja_existe()#
#---------------------------------#
      
   DEFINE l_prod, l_recei, l_merc, l_uso INTEGER

   LET m_msg = ''
   
   SELECT cod_lin_prod, 
          cod_lin_recei,
          cod_seg_merc, 
          cod_cla_uso
     INTO l_prod, l_recei, l_merc, l_uso
     FROM linha_prod_sgiurd_912
    WHERE cod_igreja = mr_campos.cod_igreja
   
   IF STATUS = 100 THEN
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','linha_prod_sgiurd_912')
      ELSE   
         IF m_opcao = 'I' THEN
            LET m_msg = 'Local já relacionado com outa AEN'
            RETURN TRUE
         END IF
         IF l_prod = m_lin_pord AND 
            l_recei = m_lin_recei AND
            l_merc = m_seg_merc AND
            l_uso = m_cla_uso THEN
            RETURN FALSE
         ELSE
            LET m_msg = 'Local já relacionado com outa AEN'
         END IF
      END IF
   END IF   
   
   RETURN TRUE

END FUNCTION


#-------------------------------#
FUNCTION pol1311_valida_igreja()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF  mr_campos.cod_igreja IS NULL THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o Local SGIURD.")
       RETURN FALSE
   END IF

   IF NOT pol1311_le_igreja(mr_campos.cod_igreja) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF pol1311_local_ja_existe() THEN
      IF m_msg IS NOT NULL THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1311_le_igreja(l_cod)#
#--------------------------------#
   
   DEFINE l_cod        CHAR(12)
   
   LET m_msg = ''
   
   SELECT cod_estado,
          den_estado,
          cod_regiao,
          den_regiao,
          den_igreja,
          cod_tip_local,
          den_tip_local,
          cod_area,
          den_area
     INTO mr_campos.cod_estado,
          mr_campos.den_estado,
          mr_campos.cod_regiao,
          mr_campos.den_regiao,
          mr_campos.den_igreja,
          mr_campos.cod_tipo,
          mr_campos.den_tipo,
          mr_campos.cod_area,
          mr_campos.den_area          
     FROM vw_igreja
    WHERE cod_igreja =  l_cod    
      AND bloqueada = 'N'
      AND dt_fim_igreja IS NULL
      AND cod_language = 'pt-br'
      AND cod_pais = '001'

   IF STATUS = 100 THEN
      LET m_msg = 'Local IURD inexistente'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','vw_igreja')   
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------#
FUNCTION pol1311_find()#
#----------------------#

    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)
    
    LET m_id_registroa = m_id_registro
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","PESQUISA RELACIONAMENTO")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","linha_prod_sgiurd_912","Relacionamentos")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","linha_prod_sgiurd_912","cod_lin_prod","Linha de produto",1 {INT},2,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","linha_prod_sgiurd_912","cod_lin_recei","Linha de receita",1 {INT},2,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","linha_prod_sgiurd_912","cod_seg_merc","Seg. mercado",1 {INT},2,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","linha_prod_sgiurd_912","cod_cla_uso","Classe de uso",1 {INT},2,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","linha_prod_sgiurd_912","cod_igreja","Local IURD",1 {CHAR},12,0)        	
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF  l_status THEN
        LET l_where_clause = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_construct,"ORDER_BY")
        CALL pol1311_cria_cursor(l_where_clause,l_order_by)
    ELSE
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
    LET m_id_registro = m_id_registroa
    
END FUNCTION

#------------------------------------------------------#
FUNCTION pol1311_cria_cursor(l_where_clause,l_order_by)#
#------------------------------------------------------#
 
   DEFINE l_where_clause CHAR(800)
   DEFINE l_order_by     CHAR(200)

   DEFINE l_sql_stmt     CHAR(2000)

    IF  l_order_by IS NULL THEN
        LET l_order_by = "id_registro"
    END IF

   LET l_sql_stmt = "SELECT id_registro ",
                     " FROM linha_prod_sgiurd_912 ",
                    " WHERE ", l_where_clause CLIPPED,
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
   
   LET m_ies_cons = FALSE
   
   FETCH cq_cons INTO m_id_registro

   IF STATUS <> 0 THEN
      IF STATUS <> 100 THEN
         CALL log003_err_sql("FETCH CURSOR","cq_cons")
      ELSE
         LET m_msg = 'Não a dados, para os argumentos informados.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN 
   END IF

    IF NOT pol1311_exibe_dados() THEN
       LET m_msg = 'Operação cancelada'
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN 
    END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
    
   LET m_ies_cons = TRUE
   
   LET m_id_registroa = m_id_registro

   LET m_where =  l_where_clause 
   LET m_order =  l_order_by
   
   
END FUNCTION

#-----------------------------#
FUNCTION pol1311_exibe_dados()#
#-----------------------------#

   DEFINE l_prod, l_recei, l_merc, l_uso CHAR(02),
          l_id   INTEGER
   
   LET m_excluiu = FALSE
   CALL pol1311_limpa_campos()

   SELECT *
     INTO l_id,
          m_lin_pord, 
          m_lin_recei, 
          m_seg_merc, 
          m_cla_uso, 
          m_cod_local,
          mr_campos.prc_aen,
          mr_campos.dt_atualizacao,
          mr_campos.cod_usuario,
          mr_campos.origem_grav
    FROM linha_prod_sgiurd_912
   WHERE id_registro = m_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','linha_prod_sgiurd_912:ED')
      RETURN FALSE 
   END IF

   LET l_prod = func002_strzero(m_lin_pord,2)
   LET l_recei = func002_strzero(m_lin_recei,2)
   LET l_merc = func002_strzero(m_seg_merc,2)
   LET l_uso = func002_strzero(m_cla_uso,2)
      
   LET mr_campos.cod_aen = l_prod, l_recei, l_merc, l_uso 
   LET mr_campos.cod_igreja = m_cod_local
   
   IF NOT pol1311_le_aen() THEN
      IF m_msg IS NOT NULL THEN
         CALL log0030_mensagem(m_msg,'info')
      END IF
      RETURN FALSE
   END IF

   IF NOT pol1311_le_igreja(m_cod_local) THEN
      IF m_msg IS NOT NULL THEN
         CALL log0030_mensagem(m_msg,'info')
      END IF
      RETURN FALSE
   END IF

   #invoca rotina para leitura do histórico
   
   IF NOT pol1311_le_historico() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#  
FUNCTION pol1311_le_historico()#
#------------------------------#
   
   DEFINE lr_hist            RECORD
           den_pais          CHAR(255), 
           den_estado        CHAR(255), 
           den_area          CHAR(255), 
           den_regiao        CHAR(255),    
           nom_tip_igreja    CHAR(255),  
           den_tip_igreja    CHAR(255), 
           den_igreja        CHAR(255)   
   END RECORD

   DEFINE l_cod_pais          CHAR(03), 
          l_cod_estado        CHAR(03), 
          l_cod_area          DECIMAL(5,0), 
          l_cod_regiao        DECIMAL(5,0) 
  
   
   DELETE FROM w_hist_tmp
   
   INITIALIZE ma_hist TO NULL
   LET m_index = 1
      
   DECLARE cq_hist CURSOR FOR
    SELECT dt_ini_hist, 
           den_pais, 
           den_estado, 
           den_area,
           den_regiao, 
           nom_tip_igreja, 
           den_tip_igreja, 
           den_igreja,
           cod_pais,  
           cod_estado,
           cod_area,  
           cod_regiao
      FROM vw_igreja_historico
     WHERE cod_igreja = mr_campos.cod_igreja
      AND cod_language = 'pt-br'
      AND cod_pais = '001'
      ORDER BY dt_ini_hist

   FOREACH cq_hist INTO 
      ma_hist[m_index].dat_hor, lr_hist.*,
      l_cod_pais, l_cod_estado,
      l_cod_area, l_cod_regiao  
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_hist')
         RETURN FALSE
      END IF
      
      SELECT * FROM w_hist_tmp
       WHERE cod_pais = l_cod_pais
         AND cod_estado = l_cod_estado
         AND cod_area = l_cod_area
         AND cod_regiao = l_cod_regiao

      IF STATUS = 0 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS = 100 THEN
            INSERT INTO w_hist_tmp
             VALUES(l_cod_pais,l_cod_estado,l_cod_area,l_cod_regiao)
            IF STATUS <> 0 THEN
               CALL log003_err_sql('INSERT','w_hist_tmp')
               RETURN FALSE
            END IF
         ELSE
            CALL log003_err_sql('SELECT','w_hist_tmp')
            RETURN FALSE
         END IF
      END IF
      
      LET ma_hist[m_index].historico = 
           lr_hist.den_pais CLIPPED, ' - ',
           lr_hist.den_estado CLIPPED, ' - ',
           lr_hist.den_area CLIPPED, ' - ',
           lr_hist.den_regiao CLIPPED, ' - ',
           lr_hist.nom_tip_igreja CLIPPED, ' - ',
           lr_hist.den_tip_igreja CLIPPED, ' - ',
           lr_hist.den_igreja CLIPPED
      
      LET m_index = m_index + 1
      
      IF m_index > 3000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   FREE cq_hist
   
   LET m_index = m_index - 1

   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_index)
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1311_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1311_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1311_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_id_registroa = m_id_registro

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
         LET m_id_registro = m_id_registroa
         EXIT WHILE
      ELSE
         SELECT 1
           FROM linha_prod_sgiurd_912
          WHERE id_registro = m_id_registro
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1311_exibe_dados()
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
FUNCTION pol1311_first()#
#-----------------------#

   IF NOT pol1311_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1311_next()#
#----------------------#

   IF NOT pol1311_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1311_previous()#
#--------------------------#

   IF NOT pol1311_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1311_last()#
#----------------------#

   IF NOT pol1311_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1311_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM linha_prod_sgiurd_912
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

#------------------------#
FUNCTION pol1311_update()#
#------------------------#

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT pol1311_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1311_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'M'    

   CALL pol1311_ativa_desativa(TRUE)
      
   CALL _ADVPL_set_property(m_cod_igreja,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1311_update_confirm()#
#--------------------------------#
   
   DEFINE l_ret   SMALLINT
   
   UPDATE linha_prod_sgiurd_912
      SET cod_igreja = mr_campos.cod_igreja
     WHERE id_registro = m_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','linha_prod_sgiurd_912')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1311_ativa_desativa(FALSE)
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende

   LET mr_audit.texto = 'ALTERACAO DO LOCAL DA AEN ', mr_campos.cod_aen
   LET p_status = func002_grava_auadit(mr_audit.*)
   
   RETURN l_ret
   
END FUNCTION

#------------------------------#
FUNCTION pol1311_update_cancel()
#------------------------------#
    
    LET m_id_registro = m_id_registroa
    CALL pol1311_exibe_dados()
    CALL pol1311_ativa_desativa(FALSE)

    RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1311_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1311_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1311_prende_registro() THEN
      RETURN FALSE
   END IF

   DELETE FROM linha_prod_sgiurd_912
     WHERE id_registro = m_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','linha_prod_sgiurd_912')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1311_limpa_campos()
      LET m_excluiu = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende

   LET mr_audit.texto = 'DELECAO DO RELACIONAMENTO DA AEN ', mr_campos.cod_aen
   LET p_status = func002_grava_auadit(mr_audit.*)
   
   RETURN l_ret
        
END FUNCTION

#-----------------------------#
FUNCTION pol1311_zoom_igreja()#
#-----------------------------#


    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)
    
    IF m_const_popup IS NULL THEN
       LET m_const_popup = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_const_popup,"CONSTRUCT_NAME","PESQUISA Local IURD")
       CALL _ADVPL_set_property(m_const_popup,"ADD_VIRTUAL_TABLE","vw_igreja","Locais")
       CALL _ADVPL_set_property(m_const_popup,"ADD_VIRTUAL_COLUMN","vw_igreja","den_uf","UF",1 {CHAR},2,0)        	       
       CALL _ADVPL_set_property(m_const_popup,"ADD_VIRTUAL_COLUMN","vw_igreja","cod_igreja","Cod local:",1 {CHAR},12,0)        	
       CALL _ADVPL_set_property(m_const_popup,"ADD_VIRTUAL_COLUMN","vw_igreja","den_igreja","Desc local:",1 {CHAR},255,0)        	
       CALL _ADVPL_set_property(m_const_popup,"ADD_VIRTUAL_COLUMN","vw_igreja","cod_tip_local","Tip local:",1 {INT},5,0)        	
       CALL _ADVPL_set_property(m_const_popup,"ADD_VIRTUAL_COLUMN","vw_igreja","den_tip_local","Desc tip local:",1 {CHAR},255,0)        	
       CALL _ADVPL_set_property(m_const_popup,"ADD_VIRTUAL_COLUMN","vw_igreja","cod_regiao","Cod região:",1 {INT},5,0)        	
       CALL _ADVPL_set_property(m_const_popup,"ADD_VIRTUAL_COLUMN","vw_igreja","den_regiao","Desc região:",1 {CHAR},255,0)        	
       CALL _ADVPL_set_property(m_const_popup,"ADD_VIRTUAL_COLUMN","vw_igreja","cod_area","Cod bloco:",1 {INT},5,0)        	
       CALL _ADVPL_set_property(m_const_popup,"ADD_VIRTUAL_COLUMN","vw_igreja","den_area","Desc bloco:",1 {CHAR},255,0)        	
    END IF

    LET l_status = _ADVPL_get_property(m_const_popup,"INIT_CONSTRUCT")

    IF  l_status THEN
        LET l_where_clause = _ADVPL_get_property(m_const_popup,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_const_popup,"ORDER_BY")
        CALL pol1311_le_locais(l_where_clause,l_order_by)
    END IF
        
END FUNCTION

#----------------------------------------------------#
FUNCTION pol1311_le_locais(l_where_clause,l_order_by)#
#----------------------------------------------------#
 
   DEFINE l_where_clause CHAR(800),
          l_order_by     CHAR(200),
          l_sql_stmt     CHAR(2000),
          l_ind          INTEGER

    IF  l_order_by IS NULL THEN
        LET l_order_by = " cod_igreja "
    END IF

   LET l_sql_stmt = "SELECT cod_igreja, den_igreja, den_tip_local, ",
                     " den_uf, den_area, den_regiao ",
                     " FROM vw_igreja ",
                    " WHERE ", l_where_clause CLIPPED,
                    " AND cod_language = 'pt-br' ",
                    " AND cod_pais = '001' ",
                    " and dt_fim_igreja IS NULL ",
                    " ORDER BY ", l_order_by

   PREPARE var_local FROM l_sql_stmt
    
   IF  Status <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","var_local")
       RETURN 
   END IF

   DECLARE cq_local CURSOR FOR var_local

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE CURSOR","cq_local")
       RETURN 
   END IF
   
   LET l_ind = 1
   INITIALIZE ma_local TO NULL
   
   FOREACH cq_local INTO 
      ma_local[l_ind].cod_igreja, 
      ma_local[l_ind].den_igreja, 
      ma_local[l_ind].den_local,
      ma_local[l_ind].den_uf,
      ma_local[l_ind].den_area,
      ma_local[l_ind].den_regiao

      IF  STATUS <> 0 THEN
          CALL log003_err_sql("FOREACH","cq_local")
          RETURN 
      END IF
      
      LET l_ind = l_ind + 1

      IF l_ind > 20000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF l_ind = 1 THEN
      LET m_msg = 'Não a dados, para os argumentos informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN
   END IF
   
   LET m_index = l_ind - 1
   
   CALL pol1311_tela_zoom()
   
END FUNCTION

#---------------------------#
FUNCTION pol1311_tela_zoom()#
#---------------------------#

   DEFINE l_menubar     VARCHAR(10),
          l_panel       VARCHAR(10),
          l_select      VARCHAR(10),
          l_cancel      VARCHAR(10)

    LET m_form_popup = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_popup,"SIZE",800,450)
    CALL _ADVPL_set_property(m_form_popup,"TITLE","SELECÇÃO DE LOCAL")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_popup)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1311_exibe_locais(l_panel)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_popup)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) #vermelho,verde,azul
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   #FIND_EX / QUIT_EX / CONFIRM_EX / UPDATE_EX / RUN_EX / NEW_EX
   #CANCEL_EX / DELETE_EX / LANCAMENTOS_EX / ESTORNO_EX / SAVEPROFILE
   LET l_select = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_select,"IMAGE","CONFIRM_EX")
   CALL _ADVPL_set_property(l_select,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_select,"EVENT","pol1311_select")     

   LET l_cancel = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancel,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancel,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancel,"EVENT","pol1311_cancel")     

   CALL _ADVPL_set_property(m_form_popup,"ACTIVATE",TRUE)


END FUNCTION

#-----------------------------------------#
FUNCTION pol1311_exibe_locais(l_container)#
#-----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",200,190,230)
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 

    LET m_brow_popup = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brow_popup,"ALIGN","CENTER")    
    CALL _ADVPL_set_property(m_brow_popup,"BEFORE_ROW_EVENT","pol1311_row_popup")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_popup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Local")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_igreja")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_popup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_igreja")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_popup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_local")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_popup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","UF")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_uf")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_popup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Área")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_area")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_popup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","região")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_regiao")
    
    CALL _ADVPL_set_property(m_brow_popup,"SET_ROWS",ma_local,m_index)

END FUNCTION

#---------------------------#
FUNCTION pol1311_row_popup()#
#---------------------------#

   DEFINE l_lin_atu       SMALLINT
      
   LET l_lin_atu = _ADVPL_get_property(m_brow_popup,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN
      LET m_cod_local = ma_local[l_lin_atu].cod_igreja
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1311_select()#
#------------------------#

   LET mr_campos.cod_igreja = m_cod_local
   CALL pol1311_le_igreja(mr_campos.cod_igreja)
   CALL _ADVPL_set_property(m_form_popup,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1311_cancel()#
#------------------------#

   CALL _ADVPL_set_property(m_form_popup,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1311_zoom_linha()#
#----------------------------#

    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)
    
    IF m_const_aen IS NULL THEN
       LET m_const_aen = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_const_aen,"CONSTRUCT_NAME","PESQUISA DE ÁREA E LINHA")
       CALL _ADVPL_set_property(m_const_aen,"ADD_VIRTUAL_TABLE","linha_prod","AEN")
       CALL _ADVPL_set_property(m_const_aen,"ADD_VIRTUAL_COLUMN","linha_prod","cod_lin_prod","Linha produto",1 {INT},2,0)        	       
       CALL _ADVPL_set_property(m_const_aen,"ADD_VIRTUAL_COLUMN","linha_prod","cod_lin_recei","Linha receita",1 {INT},2,0)        	       
       CALL _ADVPL_set_property(m_const_aen,"ADD_VIRTUAL_COLUMN","linha_prod","cod_seg_merc","Seg. mercado",1 {INT},2,0)        	       
       CALL _ADVPL_set_property(m_const_aen,"ADD_VIRTUAL_COLUMN","linha_prod","cod_cla_uso","Classe de uso",1 {INT},2,0)        	       
       CALL _ADVPL_set_property(m_const_aen,"ADD_VIRTUAL_COLUMN","linha_prod","den_estr_linprod","Descrição",1 {CHAR},30,0)        	       
    END IF

    LET l_status = _ADVPL_get_property(m_const_aen,"INIT_CONSTRUCT")

    IF  l_status THEN
        LET l_where_clause = _ADVPL_get_property(m_const_aen,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_const_aen,"ORDER_BY")
        CALL pol1311_le_linhas(l_where_clause,l_order_by)
    END IF
        
END FUNCTION

#----------------------------------------------------#
FUNCTION pol1311_le_linhas(l_where_clause,l_order_by)#
#----------------------------------------------------#
 
   DEFINE l_where_clause CHAR(800),
          l_order_by     CHAR(200),
          l_sql_stmt     CHAR(2000),
          l_ind          INTEGER,
          l_descricao    CHAR(30)

    IF  l_order_by IS NULL THEN
        LET l_order_by = " den_estr_linprod"
    END IF

   LET l_sql_stmt = "SELECT cod_lin_prod, cod_lin_recei, cod_seg_merc, ",
                    " cod_cla_uso, den_estr_linprod ",
                     " FROM linha_prod ",
                    " WHERE ", l_where_clause CLIPPED,
                    " ORDER BY ", l_order_by

   PREPARE var_aen FROM l_sql_stmt
    
   IF  Status <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","var_aen")
       RETURN 
   END IF

   DECLARE cq_aen CURSOR FOR var_aen

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE CURSOR","cq_aen")
       RETURN 
   END IF
   
   LET l_ind = 1
   INITIALIZE ma_linha TO NULL
   
   FOREACH cq_aen INTO 
      m_lin_pord, m_lin_recei, m_seg_merc,
      m_cla_uso, l_descricao
   
      IF  STATUS <> 0 THEN
          CALL log003_err_sql("FOREACH","cq_aen")
          RETURN 
      END IF
       
      LET ma_linha[l_ind].cod_linha = func002_strzero(m_lin_pord, 2),
          func002_strzero(m_lin_recei, 2), func002_strzero(m_seg_merc, 2),
          func002_strzero(m_cla_uso, 2)
      LET ma_linha[l_ind].descricao = l_descricao
      
      LET l_ind = l_ind + 1

      IF l_ind > 5000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF l_ind = 1 THEN
      LET m_msg = 'Não a dados, para os argumentos informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN
   END IF
   
   LET m_qtd_aen = l_ind - 1
   
   CALL pol1311_mostra_aens()
   
END FUNCTION

#-----------------------------#
FUNCTION pol1311_mostra_aens()#
#-----------------------------#

   DEFINE l_menubar     VARCHAR(10),
          l_panel       VARCHAR(10),
          l_select      VARCHAR(10),
          l_cancel      VARCHAR(10)

    LET m_form_aen = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_aen,"SIZE",800,450)
    CALL _ADVPL_set_property(m_form_aen,"TITLE","SELEÇÃO DE AEN")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_aen)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1311_grade_aen(l_panel)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_aen)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) #vermelho,verde,azul
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   #FIND_EX / QUIT_EX / CONFIRM_EX / UPDATE_EX / RUN_EX / NEW_EX
   #CANCEL_EX / DELETE_EX / LANCAMENTOS_EX / ESTORNO_EX / SAVEPROFILE
   LET l_select = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_select,"IMAGE","CONFIRM_EX")
   CALL _ADVPL_set_property(l_select,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_select,"EVENT","pol1311_seleciona")     

   LET l_cancel = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancel,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancel,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancel,"EVENT","pol1311_descarta")     

   CALL _ADVPL_set_property(m_form_aen,"ACTIVATE",TRUE)


END FUNCTION

#--------------------------------------#
FUNCTION pol1311_grade_aen(l_container)#
#--------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",200,190,230)
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 

    LET m_brow_aen = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brow_aen,"ALIGN","CENTER")    
    CALL _ADVPL_set_property(m_brow_aen,"BEFORE_ROW_EVENT","pol1311_row_aen")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_aen)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Código")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_linha")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_aen)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","descricao")
    
    CALL _ADVPL_set_property(m_brow_aen,"SET_ROWS",ma_linha,m_qtd_aen)

END FUNCTION

#-------------------------#
FUNCTION pol1311_row_aen()#
#-------------------------#

   DEFINE l_lin_atu       SMALLINT
      
   LET l_lin_atu = _ADVPL_get_property(m_brow_aen,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN
      LET m_cod_linha = ma_linha[l_lin_atu].cod_linha
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1311_seleciona()#
#---------------------------#

   LET mr_campos.cod_aen = m_cod_linha
   CALL _ADVPL_set_property(m_form_aen,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1311_descarta()#
#--------------------------#

   CALL _ADVPL_set_property(m_form_aen,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1311_print()#
#-----------------------#

   IF NOT pol1311_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET p_status = FALSE
   
   CALL LOG_progresspopup_start("Imprimindo...","pol1311_imprimir","PROCESS")
   
   RETURN p_status

END FUNCTION

#--------------------------#
FUNCTION pol1311_imprimir()#
#--------------------------#

 LET p_status = StartReport(
   "pol1311_relatorio","pol1311","RELACIONAMENTO LOCAL X AEN",80,TRUE,TRUE)

END FUNCTION

#-----------------------------------#
FUNCTION pol1311_relatorio(l_report)#
#-----------------------------------#

   DEFINE l_report       CHAR(300),
          l_status       SMALLINT,
          l_sql_stmt     CHAR(2000),
          l_prod         CHAR(02),
          l_recei        CHAR(02),
          l_merc         CHAR(02),
          l_uso          CHAR(02)

    #*** ANTES DO START REPORT DO 4GL. ***#
    
   LET m_page_length = ReportPageLength("pol1311")
   LET m_page_length = m_page_length / 3
       
   START REPORT pol1311_relat TO l_report

   CALL pol1311_le_den_empresa() RETURNING p_status

   LET l_sql_stmt = 
       "SELECT linha_prod_sgiurd_912.cod_lin_prod, linha_prod_sgiurd_912.cod_lin_recei, ",
             " linha_prod_sgiurd_912.cod_seg_merc, linha_prod_sgiurd_912.cod_cla_uso, ",
             " linha_prod_sgiurd_912.cod_igreja, ",
             " vw_igreja.cod_estado, vw_igreja.den_estado, vw_igreja.cod_regiao, ",
             " vw_igreja.den_regiao, vw_igreja.den_igreja, vw_igreja.cod_tip_local, ",
             " vw_igreja.den_tip_local, vw_igreja.cod_area, vw_igreja.den_area ",
       " FROM linha_prod_sgiurd_912 , vw_igreja  ",
       " WHERE ", m_where CLIPPED,
       "   AND vw_igreja.cod_igreja = linha_prod_sgiurd_912.cod_igreja ",
       "   AND vw_igreja.bloqueada = 'N' ",
       "   AND vw_igreja.dt_fim_igreja IS NULL ",
       "   AND vw_igreja.cod_language = 'pt-br' ",
       "   AND vw_igreja.cod_pais = '001' ",       
       " ORDER BY vw_igreja.den_estado "

   PREPARE var_relat FROM l_sql_stmt
    
   IF  Status <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","var_relat")
       RETURN 
   END IF

   DECLARE cq_relat SCROLL CURSOR FOR var_relat

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE CURSOR","cq_relat")
       RETURN 
   END IF

   FOREACH cq_relat INTO
          m_lin_pord, 
          m_lin_recei, 
          m_seg_merc, 
          m_cla_uso, 
          m_cod_local,
          mr_relat.cod_estado,
          mr_relat.den_estado,
          mr_relat.cod_regiao,
          mr_relat.den_regiao,
          mr_relat.den_local,
          mr_relat.cod_tipo,
          mr_relat.den_tipo,
          mr_relat.cod_bloco,
          mr_relat.den_bloco         

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','linha_prod_sgiurd_912')
         EXIT FOREACH 
      END IF
   
      LET l_prod = func002_strzero(m_lin_pord,2)
      LET l_recei = func002_strzero(m_lin_recei,2)
      LET l_merc = func002_strzero(m_seg_merc,2)
      LET l_uso = func002_strzero(m_cla_uso,2)
      
      LET mr_relat.cod_aen = l_prod, l_recei, l_merc, l_uso 
      LET mr_relat.cod_local = m_cod_local

      SELECT den_estr_linprod
        INTO mr_relat.den_aen
        FROM linha_prod
       WHERE cod_lin_prod =  m_lin_pord
         AND cod_lin_recei = m_lin_recei
         AND cod_seg_merc = m_seg_merc
         AND cod_cla_uso = m_cla_uso
      
      IF STATUS <> 0 THEN
         LET mr_relat.den_aen = ''
      END IF

      {SELECT 
          cod_estado,
          den_estado,
          cod_regiao,
          den_regiao,
          den_igreja,
          cod_tip_local,
          den_tip_local,
          cod_area,
          den_area
      INTO 
          mr_relat.cod_estado,
          mr_relat.den_estado,
          mr_relat.cod_regiao,
          mr_relat.den_regiao,
          mr_relat.den_local,
          mr_relat.cod_tipo,
          mr_relat.den_tipo,
          mr_relat.cod_bloco,
          mr_relat.den_bloco         
       FROM vw_igreja
      WHERE cod_igreja =  m_cod_local    
        AND bloqueada = 'N'
        AND dt_fim_igreja IS NULL
        AND cod_language = 'pt-br'
        AND cod_pais = '001'

      IF STATUS = 100 THEN
         CONTINUE FOREACH
      END IF}

      OUTPUT TO REPORT pol1311_relat(mr_relat.cod_estado)

   END FOREACH      

   FREE cq_relat
      
   FINISH REPORT pol1311_relat

   CALL FinishReport("pol1311")
    
END FUNCTION

#--------------------------------#
 FUNCTION pol1311_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
REPORT pol1311_relat(l_cod_estado)#
#---------------------------------#

   DEFINE l_cod_estado   CHAR(03)
   
    OUTPUT
        TOP    MARGIN 0
        LEFT   MARGIN 0
        RIGHT  MARGIN 0
        BOTTOM MARGIN 0
        PAGE   LENGTH m_page_length
   
    ORDER EXTERNAL BY l_cod_estado

    FORMAT

    PAGE HEADER

      CALL ReportPageHeader("pol1311")

      PRINT COLUMN 001, 'ESTADO:', mr_relat.cod_estado, ' ', mr_relat.den_estado

      SKIP 1 LINE
           
   BEFORE GROUP OF l_cod_estado
      SKIP TO TOP OF PAGE
      
    ON EVERY ROW
        PRINT COLUMN 001, 'AEN...:', mr_relat.cod_aen, '  - ', mr_relat.den_aen
        PRINT COLUMN 001, 'LOCAL.:', mr_relat.cod_local, ' - ', mr_relat.den_local
        PRINT COLUMN 001, 'TIPO..:', mr_relat.cod_tipo, ' - ', mr_relat.den_tipo,
              COLUMN 041, 'REGIAO:', mr_relat.cod_regiao, ' - ', mr_relat.den_regiao
        PRINT COLUMN 001, 'BLOCO.:', mr_relat.cod_bloco, ' - ', mr_relat.den_bloco,
              COLUMN 041, 'ESTADO:', mr_relat.cod_estado, ' - ', mr_relat.den_estado
        
        PRINT

END REPORT

{

Que  informações você precisa nesse relatório ?   Seriam as seguintes ?

•         Código da AEN, 
•         Descrição da AEN,
•         Código do Local SGIURD, 
•         Descrição  do Local SGIURD,
•         Região do Local SGIURD,
•         Bloco do Local SGIURD,, 
•         Estado do Local SGIURD

Com quebra por Estado 

Em que ordem ?     