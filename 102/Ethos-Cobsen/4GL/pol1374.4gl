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
       m_aba_local       VARCHAR(10),
       m_fpanel          VARCHAR(10)
       
DEFINE m_pan_arq         VARCHAR(10),
       m_item            VARCHAR(10),
       m_zoom_item       VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_local           VARCHAR(10),
       m_construct       VARCHAR(10)

DEFINE m_pan_local        VARCHAR(10),
       m_pan_relac        VARCHAR(10),
       m_pan_linha        VARCHAR(10),
       m_pan_predio       VARCHAR(10),
       m_pan_andar        VARCHAR(10),
       m_pan_apto         VARCHAR(10)

DEFINE m_brz_local        VARCHAR(10),
       m_brz_relac        VARCHAR(10),
       m_brz_linha        VARCHAR(10),
       m_brz_predio       VARCHAR(10),
       m_brz_andar        VARCHAR(10),
       m_brz_apto         VARCHAR(10)

DEFINE m_cod_linha        VARCHAR(10)
       
DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_id_registro     INTEGER,
       m_id_registroa    INTEGER,
       m_cod_item        CHAR(15),
       m_carregando      SMALLINT,
       m_ind             INTEGER,
       m_lin_atu         INTEGER
       
DEFINE mr_cabec          RECORD
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item,
       cod_local         LIKE local.cod_local,
       den_local         LIKE local.den_local
       
END RECORD

DEFINE mr_linha          RECORD
       cod_linha         CHAR(02)
END RECORD
       
DEFINE ma_linha          ARRAY[500] OF RECORD
       ies_excluir       CHAR(01),
       cod_linha         CHAR(02),
       filler            CHAR(01)
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
   
   LET m_carregando = TRUE
   CALL pol1374_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1374_menu()#
#----------------------#

    DEFINE l_menubar       VARCHAR(10),
           l_fechar        VARCHAR(10),
           l_panel         VARCHAR(10),
           l_fpanel        VARCHAR(10),
           l_label         VARCHAR(10),
           l_titulo        CHAR(80)

    LET l_titulo = 'CADASTRO DE ENDEREÇOS DO ITEM - ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET m_folder = _ADVPL_create_component(NULL,"LFOLDER",m_dialog)
    CALL _ADVPL_set_property(m_folder,"ALIGN","CENTER")

    # FOLDER local 

    LET l_fpanel = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(l_fpanel,"TITLE","Local")
		CALL pol1374_local(l_fpanel)
    
    # FOLDER relacionamento 

    LET l_fpanel = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(l_fpanel,"TITLE","Relacionamento")
    CALL pol1374_relac(l_fpanel)

    # FOLDER linha 

    LET m_fpanel = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fpanel,"TITLE","Linha")
    CALL _ADVPL_set_property(m_fpanel,"CLICK_EVENT","pol1374_linha_ler")
    CALL pol1374_linha(m_fpanel)

    # FOLDER predio 

    LET l_fpanel = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(l_fpanel,"TITLE","Prédio")
    CALL pol1374_predio(l_fpanel)

    # FOLDER andar 

    LET l_fpanel = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(l_fpanel,"TITLE","Andar")
    CALL pol1374_andar(l_fpanel)

    # FOLDER apto 

    LET l_fpanel = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(l_fpanel,"TITLE","Apto.")
    CALL pol1374_apto(l_fpanel)

    CALL _ADVPL_set_property(m_folder,"FOLDER_SELECTED",1)
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#------------------------#
FUNCTION pol1374_fechar()#
#------------------------#

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1374_local(l_fpanel)#
#-------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_fechar    VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1374_fechar")
    

END FUNCTION

#-------------------------------#
FUNCTION pol1374_relac(l_fpanel)#
#-------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_update    VARCHAR(10),
           l_fechar    VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"TOOLTIP","Modificar cadastro de linhas")   
    CALL _ADVPL_set_property(l_update,"EVENT","pol1374_lin_modif")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1374_lin_modif_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1374_lin_modif_canc")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1374_fechar")

END FUNCTION

#-------------------------------#
FUNCTION pol1374_linha(l_fpanel)#
#-------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_create    VARCHAR(10),
           l_delete    VARCHAR(10),
           l_fechar    VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1374_incluir")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1374_incluir_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1374_incluir_cancel")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1374_excluir")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1374_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1374_linha_cabec(l_panel)
    CALL pol1374_linha_grade(l_panel)
    CALL pol1374_linha_ler()
    CALL pol1374_lin_ativ_seativ(FALSE)
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1374_linha_cabec(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10)
           
    LET m_pan_linha = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_linha,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_linha,"HEIGHT",40)
    #CALL _ADVPL_set_property(m_pan_linha,"BACKGROUND_COLOR",231,237,237)
    #CALL _ADVPL_set_property(m_pan_linha,"ENABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_linha)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",30,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Linha:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET m_cod_linha = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_linha)     
    CALL _ADVPL_set_property(m_cod_linha,"POSITION",80,10) 
    CALL _ADVPL_set_property(m_cod_linha,"LENGTH",3,0)    
    CALL _ADVPL_set_property(m_cod_linha,"VARIABLE",mr_linha,"cod_linha")
    CALL _ADVPL_set_property(m_cod_linha,"VALID","pol1374_valida_linha")

END FUNCTION

#------------------------------#
FUNCTION pol1374_valida_linha()#
#------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_linha.cod_linha IS NULL THEN
      LET m_msg = 'Informe o código da linha.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT 1 FROM linha_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_linha = mr_linha.cod_linha

   IF STATUS = 0 THEN
      LET m_msg = 'Linha já cadastrada.'      
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#----------------------------------------#
FUNCTION pol1374_linha_grade(l_container)#
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
   
    LET m_brz_linha = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_linha,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_linha,"BEFORE_ROW_EVENT","pol1374_before_row")
    CALL _ADVPL_set_property(m_brz_linha,"CLICK_EVENT","pol1374_on_click")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_linha)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Linha")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_linha")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_linha)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(m_brz_linha,"SET_ROWS",ma_linha,1)
    CALL _ADVPL_set_property(m_brz_linha,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_brz_linha,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#---------------------------#
FUNCTION pol1374_linha_ler()#
#---------------------------#

   CALL _ADVPL_set_property(m_brz_linha,"CLEAR")

   LET m_carregando = TRUE
   LET mr_linha.cod_linha = NULL
   INITIALIZE ma_linha TO NULL
   LET m_ind = 1
   
   DECLARE cq_le_lin CURSOR FOR
    SELECT cod_linha
      FROM linha_547
     WHERE cod_empresa = p_cod_empresa
   
   FOREACH cq_le_lin INTO ma_linha[m_ind].cod_linha
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','linha_547:cq_le_lin')
         EXIT FOREACH
      END IF
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 500 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   IF m_ind > 1 THEN
      LET m_ind = m_ind - 1
      CALL _ADVPL_set_property(m_brz_linha,"ITEM_COUNT", m_ind)
   END IF

   LET m_carregando = FALSE
   
END FUNCTION

#-----------------------------------------#
FUNCTION pol1374_lin_ativ_seativ(l_status)#
#-----------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_brz_linha,"CAN_ADD_ROW",l_status)
   CALL _ADVPL_set_property(m_pan_linha,"ENABLE",l_status)
      
END FUNCTION

#----------------------------#
FUNCTION pol1374_before_row()#
#----------------------------#
   
   IF m_carregando THEN
      RETURN TRUE
   END IF
   
   LET m_lin_atu = _ADVPL_get_property(m_brz_linha,"ROW_SELECTED")
   
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1374_on_click()#
#----------------------------#
   
   
   LET m_lin_atu = _ADVPL_get_property(m_brz_linha,"ROW_SELECTED")
   CALL log0030_mensagem(m_lin_atu,'info')
   
   RETURN TRUE

END FUNCTION   


#-------------------------#
FUNCTION pol1374_incluir()#
#-------------------------#

   CALL pol1374_lin_ativ_seativ(TRUE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_linha.* TO NULL
   CALL _ADVPL_set_property(m_cod_linha,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1374_incluir_cancel()#
#--------------------------------#

   CALL pol1374_lin_ativ_seativ(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_linha.* TO NULL
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1374_incluir_conf()#
#------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   INSERT INTO linha_547
    VALUES(p_cod_empresa, mr_linha.cod_linha)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','linha_547')
      RETURN false
   END IF   
   
   CALL pol1374_linha_ler()
   CALL pol1374_lin_ativ_seativ(FALSE)
   LET m_lin_atu = 0
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION pol1374_prende_registro()#
#----------------------------------#
   
   DEFINE l_codigo     CHAR(02)
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM linha_547
     WHERE cod_empresa =  p_cod_empresa
       AND cod_linha = mr_linha.cod_linha
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
FUNCTION pol1374_excluir()#
#-------------------------#
   
   DEFINE l_ret       SMALLINT

   IF m_lin_atu = 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Selecione o registro a ser excluido.")
      RETURN FALSE
   END IF

   LET mr_linha.cod_linha = ma_linha[m_lin_atu].cod_linha
   
   IF mr_linha.cod_linha IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados a serem excluidos.")
      RETURN FALSE
   END IF
   
   LET m_msg = 'Confirma a exclusão da linha ', mr_linha.cod_linha, ' ? '

   IF NOT LOG_question(m_msg) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      LET mr_linha.cod_linha = NULL
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_cod_linha,"GET_FOCUS")

   IF NOT pol1374_prende_registro() THEN
      LET mr_linha.cod_linha = NULL
      RETURN FALSE
   END IF

   DELETE FROM linha_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_linha = mr_linha.cod_linha

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','linha_547')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   LET mr_linha.cod_linha = NULL
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1374_linha_ler()
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION

#-----PRÉDIO---------------------#

#--------------------------------#
FUNCTION pol1374_predio(l_fpanel)#
#--------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_fechar    VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1374_fechar")

END FUNCTION





#-----PRÉDIO---------------------#

#-------------------------------#
FUNCTION pol1374_andar(l_fpanel)#
#-------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_fechar    VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1374_fechar")

END FUNCTION



#-----PRÉDIO---------------------#

#------------------------------#
FUNCTION pol1374_apto(l_fpanel)#
#------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_fechar    VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1374_fechar")

END FUNCTION
   