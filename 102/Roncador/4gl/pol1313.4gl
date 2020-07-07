#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1313                                                 #
# OBJETIVO: PERCENTUAL DE RATEIO DE DESPESAS                        #
# AUTOR...: IVO                                                     #
# DATA....: 18/11/16                                                #
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
       m_nom_cent_cust   LIKE cad_cc.nom_cent_cust

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_ceo             VARCHAR(10),
       m_lupa_ceo        VARCHAR(10),
       m_zoom_ceo        VARCHAR(10),
       m_deo             VARCHAR(10),
       m_ano             VARCHAR(10),
       m_mes             VARCHAR(10),
       m_construct       VARCHAR(10),
       m_browse          VARCHAR(10)

DEFINE m_ies_cons        SMALLINT,
       m_ies_inc         SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ind             INTEGER,
       m_dat_atu         DATE,
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
       m_qtd_linha       INTEGER


DEFINE mr_cabec          RECORD
       cod_emp_orig      VARCHAR(02),
       den_emp_orig      VARCHAR(40),
       ano               CHAR(04),
       mes               CHAR(02)
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

#-----------------#
FUNCTION pol1313()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 11
   DEFER INTERRUPT
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   LET g_tipo_sgbd = LOG_getCurrentDBType()
   
   LET p_versao = "pol1313-12.00.03  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1313_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1313_menu()#
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
           l_delete  VARCHAR(10)
    
    CALL pol1313_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE","RATEIO DE DESPESA MENSAL - TIMESHEET")
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1313_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1313_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1313_create_cancel")
    
    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1313_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1313_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1313_update_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1313_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1313_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1313_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1313_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1313_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1313_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1313_cria_campos(l_panel)
    CALL pol1313_cria_grade(l_panel)

    CALL pol1313_ativa_desativa(FALSE)

    CALL pol1313_set_emp_orig()
    
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#------------------------------#
FUNCTION pol1313_set_emp_orig()#
#------------------------------#

    LET mr_cabec.cod_emp_orig = p_cod_empresa
    CALL pol1313_le_empresa(mr_cabec.cod_emp_orig) RETURNING p_status
    LET mr_cabec.den_emp_orig = m_den_empresa

END FUNCTION

#------------------------------------#
FUNCTION pol1313_le_par_cap(l_codigo)#
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
FUNCTION pol1313_ck_cap(l_codigo)#
#--------------------------------#

   DEFINE l_codigo     CHAR(02)
   
   RETURN TRUE
   
   LET m_msg = ''
   
   SELECT COUNT(cod_empresa_destin)
     INTO m_count
     FROM emp_orig_destino
    WHERE cod_empresa_orig = l_codigo

   IF m_count = 0 THEN
      LET m_msg = 'Empresa ', l_codigo, ' não tem contas a pagar.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
     
#-----------------------------#
FUNCTION pol1313_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_itens TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1313_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   IF m_opcao = 'M' THEN
      ##CALL _ADVPL_set_property(m_ceo,"EDITABLE",FALSE)
      ##CALL _ADVPL_set_property(m_lupa_ceo,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_mes,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_ano,"EDITABLE",FALSE)
   ELSE
      #CALL _ADVPL_set_property(m_ceo,"EDITABLE",l_status)
      #CALL _ADVPL_set_property(m_lupa_ceo,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_mes,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_ano,"EDITABLE",l_status)
   END IF
   
   CALL _ADVPL_set_property(m_browse,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",l_status)
   

END FUNCTION

#----------------------------------------#
FUNCTION pol1313_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",100)
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",10)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW") 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa origem:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_ceo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_ceo,"LENGTH",2)
    CALL _ADVPL_set_property(m_ceo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_ceo,"VARIABLE",mr_cabec,"cod_emp_orig")
    CALL _ADVPL_set_property(m_ceo,"PICTURE","@!")
    CALL _ADVPL_set_property(m_ceo,"VALID","pol1313_valida_emp_orig")

    LET m_lupa_ceo = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_ceo,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_ceo,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_ceo,"CLICK_EVENT","pol1313_zoom_emp_orig")
    
    LET m_deo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_deo,"LENGTH",40) 
    CALL _ADVPL_set_property(m_deo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_deo,"VARIABLE",mr_cabec,"den_emp_orig")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Período:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_mes = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_mes,"LENGTH",2)
    CALL _ADVPL_set_property(m_mes,"VARIABLE",mr_cabec,"mes")
    CALL _ADVPL_set_property(m_mes,"PICTURE","99")
    CALL _ADVPL_set_property(m_mes,"VALID","pol1313_valida_mes")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","/")    

    LET m_ano = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_ano,"LENGTH",4)
    CALL _ADVPL_set_property(m_ano,"VARIABLE",mr_cabec,"ano")
    CALL _ADVPL_set_property(m_ano,"PICTURE","9999")
    CALL _ADVPL_set_property(m_ano,"VALID","pol1313_valida_ano")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")


END FUNCTION

#---------------------------------------#
FUNCTION pol1313_cria_grade(l_container)#
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
    CALL _ADVPL_set_property(m_browse,"BEFORE_ADD_ROW_EVENT","pol1313_add_linha")
    CALL _ADVPL_set_property(m_browse,"AFTER_ROW_EVENT","pol1313_after_linha")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Empresa dest")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_emp_dest")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",2)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1313_ck_emp_dest")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1313_zoom_emp_dest")

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
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1313_ck_cent_cust")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1313_zoom_cent_cust")

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
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1313_ck_aen")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1313_zoom_aen")

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
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1313_ck_pct")
  
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CANCEL_EX")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Excluir")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER_CLICK_EVENT","pol1313_del_linha")
    
    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",TRUE)
    CALL _ADVPL_set_property(m_browse,"CLEAR")


END FUNCTION

#-----------------------#
FUNCTION pol1313_create()
#-----------------------#
    
    LET m_opcao = 'I'    
    CALL pol1313_limpa_campos()
    CALL pol1313_set_emp_orig()

    CALL _ADVPL_set_property(m_browse,"CLEAR")
    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)   
    CALL pol1313_ativa_desativa(TRUE)
    LET m_ies_inc = FALSE
    CALL _ADVPL_set_property(m_mes,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1313_create_confirm()
#-------------------------------#
   
   DEFINE l_linha       INTEGER
                     
   IF  mr_cabec.mes IS NULL THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o mês")
       CALL _ADVPL_set_property(m_mes,"GET_FOCUS")
       RETURN FALSE
   END IF

   IF  mr_cabec.ano IS NULL THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o ano")
       CALL _ADVPL_set_property(m_ano,"GET_FOCUS")
       RETURN FALSE
   END IF
   
   IF pol1313_grade_existe() THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       CALL _ADVPL_set_property(m_ceo,"GET_FOCUS")
       RETURN FALSE
   END IF
      
   CALL log085_transacao("BEGIN")

   IF NOT pol1313_insere_orig() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   IF NOT pol1313_grava_dest() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF     
   
   CALL log085_transacao("COMMIT")
                  
   CALL pol1313_ativa_desativa(FALSE)
   
   LET m_ies_inc = TRUE
   LET m_num_rateioa = m_num_rateio
   LET m_opcao = NULL
   LET m_ies_cons = FALSE

   RETURN TRUE
        
END FUNCTION

#------------------------------#
FUNCTION pol1313_grade_existe()#
#------------------------------#
   
   LET m_msg = ''
   
   SELECT 1
     FROM rateio_mensal_orig912
    WHERE empresa_orig = mr_cabec.cod_emp_orig
      AND ano = mr_cabec.ano
      AND mes = mr_cabec.mes

   IF STATUS = 100 THEN
      RETURN FALSE
   ELSE
      IF STATUS = 0 THEN
         LET m_msg = 'Já existe grade para a empresa origem/periodo.'
      ELSE
         CALL log003_err_sql('SELECT','rateio_mensal_orig912')
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1313_insere_orig()#
#-----------------------------#

   DEFINE l_ind    SMALLINT
      
   SELECT MAX(num_rateio)
     INTO m_num_rateio
     FROM rateio_mensal_orig912

   IF STATUS <> 0 THEN     
      CALL log003_err_sql('SELECT','rateio_mensal_orig912')
      RETURN FALSE
   END IF
   
   IF m_num_rateio IS NULL THEN
      LET m_num_rateio = 0
   END IF
   
   LET m_num_rateio = m_num_rateio + 1
     
   INSERT INTO rateio_mensal_orig912(    
     num_rateio,
     empresa_orig, 
     ano,
     mes)
   VALUES(
       m_num_rateio,
       mr_cabec.cod_emp_orig,
       mr_cabec.ano,
       mr_cabec.mes)
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','rateio_mensal_orig912')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION               

#----------------------------#
FUNCTION pol1313_grava_dest()#
#----------------------------#
   
   DEFINE l_info        SMALLINT,
          l_linha       SMALLINT,
          l_pct         DECIMAL(6,2)
   
   LET l_info = FALSE
   LET l_pct = 0

   LET m_qtd_linha = _ADVPL_get_property(m_browse,"ITEM_COUNT")
   
   FOR l_linha = 1 TO m_qtd_linha
   
       IF ma_itens[l_linha].pct_rateio IS NULL OR 
             ma_itens[l_linha].pct_rateio <= 0 THEN
          EXIT FOR
       END IF

       IF NOT pol1313_checa_linha(l_linha) THEN
          RETURN FALSE
       END IF
      
      LET l_pct = l_pct + ma_itens[l_linha].pct_rateio

      IF l_pct > 100 THEN
         LET m_msg = 'A somatória da coluna Rateio ultrapassou 100%'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
       
      LET l_info = TRUE
       
      IF NOT pol1313_insere_dest(l_linha) THEN
         RETURN FALSE
      END IF
       
   END FOR
      
   IF NOT l_info THEN
      LET m_msg = 'Informe pelo menos \n uma empresa destino.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_browse,"REMOVE_EMPTY_ROWS")
   
   RETURN TRUE

END FUNCTION
   
#----------------------------------#
FUNCTION pol1313_insere_dest(l_ind)#
#----------------------------------#

   DEFINE l_ind    SMALLINT
      
   INSERT INTO rateio_mensal_dest912(   
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
      CALL log003_err_sql('INSERT','rateio_mensal_dest912')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION               

#-------------------------------#
FUNCTION pol1313_create_cancel()#
#-------------------------------#

    CALL pol1313_ativa_desativa(FALSE)
    CALL pol1313_limpa_campos()
    CALL _ADVPL_set_property(m_browse,"CLEAR")
    LET m_opcao = NULL
    
    RETURN TRUE
        
END FUNCTION

#---------------------------------#
FUNCTION pol1313_valida_emp_orig()#
#---------------------------------#
    
    CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
    IF  mr_cabec.cod_emp_orig IS NULL THEN
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a empresa origem.")
        RETURN FALSE
    END IF
      
   IF NOT pol1313_le_empresa(mr_cabec.cod_emp_orig) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1313_ck_cap(mr_cabec.cod_emp_orig) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
        
   LET mr_cabec.den_emp_orig = m_den_empresa
   CALL _ADVPL_set_property(m_mes,"GET_FOCUS")   
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1313_le_empresa(l_codigo)#
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
FUNCTION pol1313_zoom_emp_orig()#
#-------------------------------#
    
   DEFINE l_codigo       LIKE empresa.cod_empresa,
          l_descricao    LIKE empresa.den_empresa

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

#----------------------------#
FUNCTION pol1313_valida_mes()#
#----------------------------#

   DEFINE l_mes            INTEGER

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
   IF mr_cabec.mes IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o mês.")
      RETURN FALSE
   END IF
   
   LET l_mes = mr_cabec.mes

   IF l_mes < 1 OR l_mes > 12 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Mês inválido.")
      RETURN FALSE
   END IF
         
   LET mr_cabec.mes = func002_strzero(l_mes,2)

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1313_valida_ano()#
#----------------------------#

   DEFINE l_ano            INTEGER

    CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
    IF  mr_cabec.ano IS NULL THEN
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o ano.")
        RETURN FALSE
    END IF
   
   LET l_ano = mr_cabec.ano
   
   IF l_ano < 999 THEN
      LET l_ano = l_ano + 2000
   END IF
   
   LET mr_cabec.ano = func002_strzero(l_ano,4)

   IF pol1313_grade_existe() THEN
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       CALL _ADVPL_set_property(m_ceo,"GET_FOCUS")
       RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1313_ck_emp_dest()#
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
      LET m_msg = 'Empresa destino não pode ser igual a empresa origem.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT pol1313_le_empresa(l_codigo) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET ma_itens[l_lin_atu].den_emp_dest = m_den_empresa
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1313_zoom_emp_dest()#
#-------------------------------#
    
   DEFINE l_codigo      LIKE empresa.cod_empresa,
          l_descricao   LIKE empresa.den_empresa,
          l_lin_atu     SMALLINT,
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
FUNCTION pol1313_zoom_cent_cust()#
#--------------------------------#
    
   DEFINE l_codigo       LIKE cad_cc.cod_cent_cust,
          l_descricao    LIKE cad_cc.nom_cent_cust,
          l_lin_atu      SMALLINT,
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
FUNCTION pol1313_ck_cent_cust()#
#------------------------------#

   DEFINE l_lin_atu       SMALLINT,
          l_codigo        LIKE cad_cc.cod_cent_cust          
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
      
   LET ma_itens[l_lin_atu].nom_cent_cust = ''
   
   LET l_codigo = ma_itens[l_lin_atu].cod_cent_cust
   
   IF l_codigo IS NULL THEN
      RETURN TRUE
   END IF
   
   IF NOT pol1313_le_cad_cc(ma_itens[l_lin_atu].cod_emp_dest, l_codigo) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET ma_itens[l_lin_atu].nom_cent_cust = m_nom_cent_cust
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------------#
FUNCTION pol1313_le_cad_cc(l_emp, l_cust)#
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
FUNCTION pol1313_zoom_aen()#
#--------------------------#

   DEFINE l_descricao    LIKE linha_prod.den_estr_linprod,
          l_codigo       CHAR(08),
          l_lin_atu      SMALLINT

   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   CALL pol1313_le_par_cap(ma_itens[l_lin_atu].cod_emp_dest)
   
   IF m_par_aen = 'N' THEN
      LET ma_itens[l_lin_atu].cod_aen = ''
      LET ma_itens[l_lin_atu].den_aen = ''
      LET m_msg = 'Empresa não utiliza AEN'
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
FUNCTION pol1313_zoom_linha()#
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
FUNCTION pol1313_ck_aen()#
#------------------------#

   DEFINE l_lin_atu   SMALLINT

   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
    
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
   LET ma_itens[l_lin_atu].den_aen = ''
   
   CALL pol1313_le_par_cap(ma_itens[l_lin_atu].cod_emp_dest)
   
   IF m_par_aen = 'N' THEN
      LET ma_itens[l_lin_atu].cod_aen = ''
      RETURN TRUE
   END IF

   IF ma_itens[l_lin_atu].cod_aen IS NULL THEN
      RETURN TRUE
   END IF
       
   CALL pol1313_separa_aen(ma_itens[l_lin_atu].cod_aen)
   
   IF NOT pol1313_le_aen() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET ma_itens[l_lin_atu].den_aen = m_den_aen
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1313_ck_pct()#
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
FUNCTION pol1313_separa_aen(l_cod)#
#---------------------------------#
   
   DEFINE l_cod      CHAR(08)
   
   LET m_lin_pord = l_cod[1,2]
   LET m_lin_recei = l_cod[3,4]
   LET m_seg_merc = l_cod[5,6]
   LET m_cla_uso = l_cod[7,8]

END FUNCTION

#------------------------#
FUNCTION pol1313_le_aen()#
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
FUNCTION pol1313_del_linha()#
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
FUNCTION pol1313_add_linha()#
#---------------------------#

   DEFINE l_lin_atu       INTEGER

   IF m_carregando OR m_opcao IS NULL THEN
      RETURN TRUE
   END IF
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
      
   IF l_lin_atu <= 0 OR l_lin_atu IS NULL THEN
      RETURN TRUE
   END IF

   IF NOT pol1313_checa_linha(l_lin_atu) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1313_after_linha()#
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
   
   IF NOT pol1313_checa_linha(l_lin_atu) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
   
#--------------------------------------#
FUNCTION pol1313_checa_linha(l_lin_atu)#
#--------------------------------------#

   DEFINE l_lin_atu       INTEGER
   
   IF ma_itens[l_lin_atu].cod_emp_dest IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a empresa destino.")
      RETURN FALSE
   END IF

   IF NOT pol1313_ck_cap(ma_itens[l_lin_atu].cod_emp_dest) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF ma_itens[l_lin_atu].cod_emp_dest = mr_cabec.cod_emp_orig THEN
      LET m_msg = 'Empresa destino não pode ser igual a empresa origem.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
       
   IF ma_itens[l_lin_atu].cod_cent_cust IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe centro de custo.")
      RETURN FALSE
   END IF
   
   CALL pol1313_le_par_cap(ma_itens[l_lin_atu].cod_emp_dest)

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
FUNCTION pol1313_find()#
#----------------------#

    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)
    
    LET m_num_rateioa = m_num_rateio
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","PESQUISA RATEIO MENSAL")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","rateio_mensal_orig912","Rateio")
       #CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","rateio_mensal_orig912","empresa_orig","Empresa origem",1 {CHAR},2,0,"zoom_empresa")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","rateio_mensal_orig912","ano","Ano",1 {CHAR},4,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","rateio_mensal_orig912","mes","Mês",1 {CHAR},2,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF  l_status THEN
        LET l_where_clause = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_construct,"ORDER_BY")
        CALL pol1313_cria_cursor(l_where_clause,l_order_by)
    ELSE
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
    LET m_num_rateio = m_num_rateioa
    
END FUNCTION

#------------------------------------------------------#
FUNCTION pol1313_cria_cursor(l_where_clause,l_order_by)#
#------------------------------------------------------#
 
   DEFINE l_where_clause CHAR(800)
   DEFINE l_order_by     CHAR(200)

   DEFINE l_sql_stmt     CHAR(2000)

    IF  l_order_by IS NULL THEN
        LET l_order_by = "empresa_orig, ano, mes"
    END IF

   LET l_sql_stmt = "SELECT num_rateio, empresa_orig, ano, mes ",
                     " FROM rateio_mensal_orig912 ",
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
         LET m_msg = 'Não a dados, para os argumentos informados.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN 
   END IF

    IF NOT pol1313_exibe_dados() THEN
       LET m_msg = 'Operação cancelada'
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN 
    END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
    
   LET m_ies_cons = TRUE
   LET m_ies_inc = FALSE
   
   LET m_num_rateioa = m_num_rateio
   
END FUNCTION

#-----------------------------#
FUNCTION pol1313_exibe_dados()#
#-----------------------------#

   DEFINE l_prod, l_recei, l_merc, l_uso CHAR(02),
          l_id   INTEGER
   
   LET m_excluiu = FALSE
   CALL pol1313_limpa_campos()

   SELECT empresa_orig,
          ano,         
          mes         
     INTO mr_cabec.cod_emp_orig,
          mr_cabec.ano,
          mr_cabec.mes          
    FROM rateio_mensal_orig912
   WHERE num_rateio = m_num_rateio

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','rateio_mensal_orig912:ED')
      RETURN FALSE 
   END IF
         
   CALL pol1313_le_empresa(mr_cabec.cod_emp_orig) RETURNING p_status
   LET mr_cabec.den_emp_orig = m_den_empresa

   CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",TRUE)
   LET m_carregando = TRUE
   LET p_status = pol1313_le_itens()
   CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
   LET m_carregando = FALSE
      
   RETURN p_status

END FUNCTION

#--------------------------#  
FUNCTION pol1313_le_itens()#
#--------------------------#
   
   DEFINE l_ind       SMALLINT
   
   INITIALIZE ma_itens TO NULL
   LET l_ind = 1
      
   DECLARE cq_itens CURSOR FOR
    SELECT empresa_dest, 
           cod_cent_cust,
           cod_aen,      
           pct_rateio   
      FROM rateio_mensal_dest912
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
      
      CALL pol1313_le_empresa(ma_itens[l_ind].cod_emp_dest) RETURNING p_status
      LET ma_itens[l_ind].den_emp_dest = m_den_empresa

      CALL pol1313_le_cad_cc(
         ma_itens[l_ind].cod_emp_dest, ma_itens[l_ind].cod_cent_cust) RETURNING p_status           
      LET ma_itens[l_ind].nom_cent_cust = m_nom_cent_cust

      CALL pol1313_separa_aen(ma_itens[l_ind].cod_aen)
   
      CALL pol1313_le_aen() RETURNING p_status
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

#--------------------------#
FUNCTION pol1313_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1313_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1313_ies_cons() THEN
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
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_num_rateio = m_num_rateioa
         EXIT WHILE
      ELSE
         SELECT 1
           FROM rateio_mensal_orig912
          WHERE num_rateio = m_num_rateio
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1313_exibe_dados()
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
FUNCTION pol1313_first()#
#-----------------------#

   IF NOT pol1313_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1313_next()#
#----------------------#

   IF NOT pol1313_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1313_previous()#
#--------------------------#

   IF NOT pol1313_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1313_last()#
#----------------------#

   IF NOT pol1313_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1313_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM rateio_mensal_orig912
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
FUNCTION pol1313_update()#
#------------------------#

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT m_ies_inc THEN
      IF NOT pol1313_ies_cons() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1313_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'M'    

   CALL pol1313_ativa_desativa(TRUE)
   CALL _ADVPL_set_property(m_mes,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1313_update_confirm()#
#--------------------------------#
   
   DEFINE l_ret   SMALLINT
   
   LET l_ret = FALSE
   
   IF pol1313_del_dest() THEN
      IF pol1313_grava_dest() THEN
         LET l_ret = TRUE
      END IF
   END IF
         
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1313_ativa_desativa(FALSE)
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   LET m_opcao = NULL
   
   RETURN l_ret
   
END FUNCTION

#------------------------------#
FUNCTION pol1313_update_cancel()
#------------------------------#

   CALL log085_transacao("ROLLBACK")      
   CLOSE cq_prende
    
   LET m_num_rateio = m_num_rateioa
   CALL pol1313_exibe_dados()
   CALL pol1313_ativa_desativa(FALSE)
   LET m_opcao = NULL
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1313_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT m_ies_inc THEN
      IF NOT pol1313_ies_cons() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1313_prende_registro() THEN
      RETURN FALSE
   END IF

   LET l_ret = TRUE

   IF NOT pol1313_del_orig() THEN
      LET l_ret = FALSE
   END IF

   IF NOT pol1313_del_dest() THEN
      LET l_ret = FALSE
   END IF

   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1313_limpa_campos()
      LET m_excluiu = TRUE
      CALL _ADVPL_set_property(m_browse,"CLEAR")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF
         
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION

#--------------------------#
FUNCTION pol1313_del_orig()#
#--------------------------#

   DELETE FROM rateio_mensal_orig912
     WHERE num_rateio = m_num_rateio

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','rateio_mensal_orig912')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1313_del_dest()#
#--------------------------#
   
   DELETE FROM rateio_mensal_dest912
     WHERE num_rateio = m_num_rateio

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','rateio_mensal_dest912')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
          