#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1374                                                 #
# OBJETIVO: CADASTRO DE ENDEREÇOS DO ITEM                           #
# AUTOR...: IVO                                                     #
# DATA....: 24/06/19                                                #
#-------------------------------------------------------------------#
{
CREATE TABLE etiq_item_970 (
 cod_item          VARCHAR(15),
 den_item          VARCHAR(76),
 cod_unid_med      VARCHAR(03),
 cod_local         VARCHAR(10),
 primary key(cod_item)
}

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
       m_fold_local      VARCHAR(10),
       m_aba_etiq        VARCHAR(10),
       m_fold_etiq       VARCHAR(10),
       m_fold_relac      VARCHAR(10),
       m_fold_linha      VARCHAR(10),
       m_fold_predio     VARCHAR(10),
       m_fold_andar      VARCHAR(10),
       m_fold_apto       VARCHAR(10),
       m_form_popup      VARCHAR(10),
       m_brow_popup      VARCHAR(10)
       
DEFINE m_pan_arq         VARCHAR(10),
       m_item            VARCHAR(10),
       m_local           VARCHAR(10),
       m_etiq_item       VARCHAR(10),
       m_etiq_local      VARCHAR(10),
       m_construct       VARCHAR(10)

DEFINE m_pan_item         VARCHAR(10),
       m_pan_etiq         VARCHAR(10),
       m_pan_relac        VARCHAR(10),
       m_pan_linha        VARCHAR(10),
       m_pan_predio       VARCHAR(10),
       m_pan_andar        VARCHAR(10),
       m_pan_apto         VARCHAR(10)

DEFINE m_brz_local        VARCHAR(10),
       m_brz_etiq         VARCHAR(10),
       m_brz_relac        VARCHAR(10),
       m_brz_linha        VARCHAR(10),
       m_brz_predio       VARCHAR(10),
       m_brz_andar        VARCHAR(10),
       m_brz_apto         VARCHAR(10)

DEFINE m_cod_linha        VARCHAR(10),
       m_cod_predio       VARCHAR(10),
       m_cod_andar        VARCHAR(10),
       m_cod_apto         VARCHAR(10),
       m_linha            VARCHAR(10),
       m_predio           VARCHAR(10),
       m_andar            VARCHAR(10),
       m_apto             VARCHAR(10),
       m_relacto          VARCHAR(10)
       
DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_id_registro     INTEGER,
       m_id_registroa    INTEGER,
       m_carregando      SMALLINT,
       m_ind             INTEGER,
       m_lin_atu         INTEGER,
       m_pred_atu        INTEGER,
       m_and_atu         INTEGER,
       m_apto_atu        INTEGER,
       m_relac_atu       INTEGER,
       m_cod_relac       CHAR(10),
       m_index           INTEGER,
       m_num_relac       CHAR(10),
       m_info_etiq       SMALLINT,
       m_sel_etiq        SMALLINT,
       m_imp_etiq        VARCHAR(01),
       m_car_etiq        SMALLINT,
       m_item_etiq       INTEGER
              

DEFINE mr_linha          RECORD
       cod_linha         CHAR(02)
END RECORD
       
DEFINE ma_linha          ARRAY[500] OF RECORD
       cod_linha         CHAR(02),
       filler            CHAR(01)
END RECORD

DEFINE mr_predio         RECORD
       cod_predio        CHAR(02)
END RECORD
       
DEFINE ma_predio         ARRAY[500] OF RECORD
       cod_predio        CHAR(02),
       filler            CHAR(01)
END RECORD

DEFINE mr_andar          RECORD
       cod_andar         CHAR(02)
END RECORD
       
DEFINE ma_andar          ARRAY[500] OF RECORD
       cod_andar         CHAR(02),
       filler            CHAR(01)
END RECORD

DEFINE mr_apto           RECORD
       cod_apto          CHAR(02)
END RECORD
       
DEFINE ma_apto           ARRAY[500] OF RECORD
       cod_apto          CHAR(02),
       filler            CHAR(01)
END RECORD

DEFINE mr_relac          RECORD
       cod_relac         CHAR(10),   
       cod_linha         CHAR(02),  
       cod_predio        CHAR(02),  
       cod_andar         CHAR(02),  
       cod_apto          CHAR(02),
       den_relac         CHAR(30)   
END RECORD
       
DEFINE ma_relac          ARRAY[500] OF RECORD
       cod_relac         CHAR(10),   
       cod_linha         CHAR(02),  
       cod_predio        CHAR(02),  
       cod_andar         CHAR(02),  
       cod_apto          CHAR(02),  
       den_relac         CHAR(30),     
       filler            CHAR(01)
END RECORD

DEFINE ma_zoom           ARRAY[500] OF RECORD
       cod_relac         CHAR(10),   
       den_relac         CHAR(30)   
END RECORD

DEFINE m_zoom_item       VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_lupa_local      VARCHAR(10),
       m_zoom_etiq_local VARCHAR(10),
       m_et_lup_local    VARCHAR(10),
       m_zoom_etiq_item  VARCHAR(10),
       m_et_lup_item     VARCHAR(10)

DEFINE mr_local          RECORD
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item,
       cod_local         LIKE local.cod_local,
       den_local         LIKE local.den_local,
       new_local         LIKE local.cod_local,
       new_desc          LIKE local.den_local
END RECORD

DEFINE ma_local          ARRAY[20] OF RECORD
       cod_item          LIKE item.cod_item,
       cod_local         LIKE local.cod_local,
       den_local         LIKE local.den_local,
       num_lote          LIKE estoque_lote.num_lote,
       qtd_saldo         LIKE estoque_lote.qtd_saldo,
       ies_situa_qtd     LIKE estoque_lote.ies_situa_qtd,
       filler            CHAR(01)  
END RECORD

DEFINE mr_etiq           RECORD
       cod_local         LIKE local.cod_local,
       den_local         LIKE local.den_local,
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item
END RECORD

DEFINE ma_etiq           ARRAY[10000] OF RECORD
       ies_etiq          VARCHAR(01),
       cod_local         LIKE local.cod_local,
       den_local         LIKE local.den_local,
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item,
       cod_unid_med      VARCHAR(03)
END RECORD
       
DEFINE m_cod_item       VARCHAR(10),
       m_new_local      VARCHAR(10)

DEFINE m_info_item      SMALLINT
             
#-----------------#
FUNCTION pol1374()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1374-12.00.01  "
   CALL func002_versao_prg(p_versao)

   IF NOT log0150_verifica_se_tabela_existe("etiq_item_970") THEN 
      IF NOT pol1374_cria_tab() THEN
         RETURN FALSE
      END IF
   END IF
   
   LET m_carregando = TRUE
   CALL pol1374_menu()

END FUNCTION

#--------------------------#
FUNCTION pol1374_cria_tab()#
#--------------------------#

   CREATE TABLE etiq_item_970 (
    cod_item          VARCHAR(15),
    den_item          VARCHAR(76),
    cod_unid_med      VARCHAR(03),
    cod_local         VARCHAR(10)
   );

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX ix_etiq_item_970
    ON etiq_item_970(cod_item);

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
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

    LET m_fold_local = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_local,"TITLE","Local")
		CALL pol1374_local(m_fold_local)
    
    # FOLDER relacionamento 

    LET m_fold_relac = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_relac,"TITLE","Relacionamento")
    CALL pol1374_relac(m_fold_relac)

    # FOLDER linha 

    LET m_fold_linha = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_linha,"TITLE","Linha")
    CALL pol1374_linha(m_fold_linha)

    # FOLDER predio 

    LET m_fold_predio = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_predio,"TITLE","Prédio")
    CALL pol1374_predio(m_fold_predio)

    # FOLDER andar 

    LET m_fold_andar = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_andar,"TITLE","Andar")
    CALL pol1374_andar(m_fold_andar)

    # FOLDER apto 

    LET m_fold_apto = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_apto,"TITLE","Apto.")
    CALL pol1374_apto(m_fold_apto)

    # FOLDER etiqueta 

    LET m_fold_etiq = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_etiq,"TITLE","Etiqueta")
		CALL pol1374_etiqueta(m_fold_etiq)

    CALL _ADVPL_set_property(m_folder,"FOLDER_SELECTED",1)
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------#
FUNCTION pol1374_folder_sel()#
#----------------------------#
   
   CALL log0030_mensagem('pol1374_folder_sel','info')
   
   RETURN TRUE
   
END FUNCTION
   
#------------------------#
FUNCTION pol1374_fechar()#
#------------------------#

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1374_linha(l_fpanel)#
#-------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_create    VARCHAR(10),
           l_delete    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1374_lin_inc")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1374_lin_inc_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1374_lin_inc_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1374_linha_ler")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1374_lin_excluir")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1374_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1374_linha_cabec(l_panel)
    CALL pol1374_linha_grade(l_panel)
    CALL pol1374_lin_ativ_desativ(FALSE)
    
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
    CALL _ADVPL_set_property(m_cod_linha,"PICTURE","@!")  
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
    CALL _ADVPL_set_property(m_brz_linha,"BEFORE_ROW_EVENT","pol1374_lin_before_row")
    
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

#------------------------------------------#
FUNCTION pol1374_lin_ativ_desativ(l_status)#
#------------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_brz_linha,"CAN_ADD_ROW",l_status)
   CALL _ADVPL_set_property(m_pan_linha,"ENABLE",l_status)
      
END FUNCTION

#--------------------------------#
FUNCTION pol1374_lin_before_row()#
#--------------------------------#
  
   IF m_carregando THEN
      RETURN TRUE
   END IF
   
   LET m_lin_atu = _ADVPL_get_property(m_brz_linha,"ROW_SELECTED")
   
   RETURN TRUE

END FUNCTION   


#-------------------------#
FUNCTION pol1374_lin_inc()#
#-------------------------#

   CALL pol1374_lin_ativ_desativ(TRUE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_linha.* TO NULL
   CALL pol1374_desativa_folder("3")
   CALL _ADVPL_set_property(m_cod_linha,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1374_lin_inc_cancel()#
#--------------------------------#

   CALL pol1374_lin_ativ_desativ(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1374_ativa_folder()
   INITIALIZE mr_linha.* TO NULL
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1374_lin_inc_conf()#
#------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   INSERT INTO linha_547
    VALUES(p_cod_empresa, mr_linha.cod_linha)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','linha_547')
      RETURN FALSE
   END IF   
   
   CALL pol1374_linha_ler()
   CALL pol1374_lin_ativ_desativ(FALSE)
   LET m_lin_atu = 0
   CALL pol1374_ativa_folder()
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol1374_prende_linha()#
#-------------------------------#
   
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
   
#-----------------------------#
FUNCTION pol1374_lin_excluir()#
#-----------------------------#
   
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

   IF NOT pol1374_prende_linha() THEN
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
           l_create    VARCHAR(10),
           l_delete    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1374_pred_inc")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1374_pred_inc_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1374_pred_inc_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1374_predio_ler")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1374_pred_excluir")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1374_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1374_predio_cabec(l_panel)
    CALL pol1374_predio_grade(l_panel)
    CALL pol1374_pred_ativ_desativ(FALSE)
    
END FUNCTION

#-----------------------------------------#
FUNCTION pol1374_predio_cabec(l_container)#
#-----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10)
           
    LET m_pan_predio = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_predio,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_predio,"HEIGHT",40)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_predio)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",30,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Prédio:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET m_cod_predio = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_predio)     
    CALL _ADVPL_set_property(m_cod_predio,"POSITION",80,10) 
    CALL _ADVPL_set_property(m_cod_predio,"LENGTH",3,0)    
    CALL _ADVPL_set_property(m_cod_predio,"PICTURE","@!")  
    CALL _ADVPL_set_property(m_cod_predio,"VARIABLE",mr_predio,"cod_predio")
    CALL _ADVPL_set_property(m_cod_predio,"VALID","pol1374_valida_predio")

END FUNCTION

#-------------------------------#
FUNCTION pol1374_valida_predio()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_predio.cod_predio IS NULL THEN
      LET m_msg = 'Informe o código da prédio.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT 1 FROM predio_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_predio = mr_predio.cod_predio

   IF STATUS = 0 THEN
      LET m_msg = 'predio já cadastrado.'      
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#----------------------------------------#
FUNCTION pol1374_predio_grade(l_container)#
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
   
    LET m_brz_predio = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_predio,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_predio,"BEFORE_ROW_EVENT","pol1374_pred_before_row")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_predio)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Prédio")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_predio")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_predio)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(m_brz_predio,"SET_ROWS",ma_predio,1)
    CALL _ADVPL_set_property(m_brz_predio,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_brz_predio,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#---------------------------#
FUNCTION pol1374_predio_ler()#
#---------------------------#

   CALL _ADVPL_set_property(m_brz_predio,"CLEAR")

   LET m_carregando = TRUE
   LET mr_predio.cod_predio = NULL
   INITIALIZE ma_predio TO NULL
   LET m_ind = 1
   
   DECLARE cq_le_pred CURSOR FOR
    SELECT cod_predio
      FROM predio_547
     WHERE cod_empresa = p_cod_empresa
   
   FOREACH cq_le_pred INTO ma_predio[m_ind].cod_predio
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','predio_547:cq_le_pred')
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
      CALL _ADVPL_set_property(m_brz_predio,"ITEM_COUNT", m_ind)
   END IF

   LET m_carregando = FALSE
   
END FUNCTION

#-------------------------------------------#
FUNCTION pol1374_pred_ativ_desativ(l_status)#
#-------------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_brz_predio,"CAN_ADD_ROW",l_status)
   CALL _ADVPL_set_property(m_pan_predio,"ENABLE",l_status)
      
END FUNCTION

#---------------------------------#
FUNCTION pol1374_pred_before_row()#
#---------------------------------#
  
   IF m_carregando THEN
      RETURN TRUE
   END IF
   
   LET m_pred_atu = _ADVPL_get_property(m_brz_predio,"ROW_SELECTED")
   
   RETURN TRUE

END FUNCTION   


#--------------------------#
FUNCTION pol1374_pred_inc()#
#--------------------------#

   CALL pol1374_pred_ativ_desativ(TRUE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_predio.* TO NULL
   CALL pol1374_desativa_folder("4")
   CALL _ADVPL_set_property(m_cod_predio,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1374_pred_inc_cancel()#
#---------------------------------#

   CALL pol1374_pred_ativ_desativ(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_predio.* TO NULL
   CALL pol1374_ativa_folder()
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1374_pred_inc_conf()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   INSERT INTO predio_547
    VALUES(p_cod_empresa, mr_predio.cod_predio)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','predio_547')
      RETURN false
   END IF   
   
   CALL pol1374_predio_ler()
   CALL pol1374_pred_ativ_desativ(FALSE)
   LET m_pred_atu = 0
   CALL pol1374_ativa_folder()
   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1374_prende_predio()#
#--------------------------------#
   
   DEFINE l_codigo     CHAR(02)
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM predio_547
     WHERE cod_empresa =  p_cod_empresa
       AND cod_predio = mr_predio.cod_predio
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
   
#------------------------------#
FUNCTION pol1374_pred_excluir()#
#------------------------------#
   
   DEFINE l_ret       SMALLINT

   IF m_pred_atu = 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Selecione o registro a ser excluido.")
      RETURN FALSE
   END IF

   LET mr_predio.cod_predio = ma_predio[m_pred_atu].cod_predio
   
   IF mr_predio.cod_predio IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados a serem excluidos.")
      RETURN FALSE
   END IF
   
   LET m_msg = 'Confirma a exclusão da prédio ', mr_predio.cod_predio, ' ? '

   IF NOT LOG_question(m_msg) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      LET mr_predio.cod_predio = NULL
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_cod_predio,"GET_FOCUS")

   IF NOT pol1374_prende_predio() THEN
      LET mr_predio.cod_predio = NULL
      RETURN FALSE
   END IF

   DELETE FROM predio_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_predio = mr_predio.cod_predio

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','predio_547')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   LET mr_predio.cod_predio = NULL
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1374_predio_ler()
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION





#-----ANDAR---------------------#

#-------------------------------#
FUNCTION pol1374_andar(l_fpanel)#
#-------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_create    VARCHAR(10),
           l_delete    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1374_and_inc")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1374_and_inc_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1374_and_inc_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1374_andar_ler")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1374_and_excluir")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1374_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1374_andar_cabec(l_panel)
    CALL pol1374_andar_grade(l_panel)
    CALL pol1374_and_ativ_desativ(FALSE)
    
END FUNCTION

#-----------------------------------------#
FUNCTION pol1374_andar_cabec(l_container)#
#-----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10)
           
    LET m_pan_andar = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_andar,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_andar,"HEIGHT",40)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_andar)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",30,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Andar:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET m_cod_andar = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_andar)     
    CALL _ADVPL_set_property(m_cod_andar,"POSITION",80,10) 
    CALL _ADVPL_set_property(m_cod_andar,"LENGTH",3,0)    
    CALL _ADVPL_set_property(m_cod_andar,"PICTURE","@!")  
    CALL _ADVPL_set_property(m_cod_andar,"VARIABLE",mr_andar,"cod_andar")
    CALL _ADVPL_set_property(m_cod_andar,"VALID","pol1374_valida_andar")

END FUNCTION

#----------------------------------------#
FUNCTION pol1374_andar_grade(l_container)#
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
   
    LET m_brz_andar = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_andar,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_andar,"BEFORE_ROW_EVENT","pol1374_and_before_row")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_andar)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Andar")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_andar")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_andar)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(m_brz_andar,"SET_ROWS",ma_andar,1)
    CALL _ADVPL_set_property(m_brz_andar,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_brz_andar,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#---------------------------#
FUNCTION pol1374_andar_ler()#
#---------------------------#

   CALL _ADVPL_set_property(m_brz_andar,"CLEAR")

   LET m_carregando = TRUE
   LET mr_andar.cod_andar = NULL
   INITIALIZE ma_andar TO NULL
   LET m_ind = 1
   
   DECLARE cq_le_and CURSOR FOR
    SELECT cod_andar
      FROM andar_547
     WHERE cod_empresa = p_cod_empresa
   
   FOREACH cq_le_and INTO ma_andar[m_ind].cod_andar
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','andar_547:cq_le_and')
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
      CALL _ADVPL_set_property(m_brz_andar,"ITEM_COUNT", m_ind)
   END IF

   LET m_carregando = FALSE
   
END FUNCTION

#-------------------------------------------#
FUNCTION pol1374_and_ativ_desativ(l_status)#
#-------------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_brz_andar,"CAN_ADD_ROW",l_status)
   CALL _ADVPL_set_property(m_pan_andar,"ENABLE",l_status)
      
END FUNCTION

#---------------------------------#
FUNCTION pol1374_and_before_row()#
#---------------------------------#
  
   IF m_carregando THEN
      RETURN TRUE
   END IF
   
   LET m_and_atu = _ADVPL_get_property(m_brz_andar,"ROW_SELECTED")
   
   RETURN TRUE

END FUNCTION   

#-------------------------------#
FUNCTION pol1374_valida_andar()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_andar.cod_andar IS NULL THEN
      LET m_msg = 'Informe o código da andar.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT 1 FROM andar_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_andar = mr_andar.cod_andar

   IF STATUS = 0 THEN
      LET m_msg = 'andar já cadastrado.'      
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   

#--------------------------#
FUNCTION pol1374_and_inc()#
#--------------------------#

   CALL pol1374_and_ativ_desativ(TRUE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_andar.* TO NULL
   CALL pol1374_desativa_folder("5")
   CALL _ADVPL_set_property(m_cod_andar,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1374_and_inc_cancel()#
#---------------------------------#

   CALL pol1374_and_ativ_desativ(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_andar.* TO NULL
   CALL pol1374_ativa_folder()
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1374_and_inc_conf()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   INSERT INTO andar_547
    VALUES(p_cod_empresa, mr_andar.cod_andar)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','andar_547')
      RETURN FALSE
   END IF   
   
   CALL pol1374_andar_ler()
   CALL pol1374_and_ativ_desativ(FALSE)
   LET m_and_atu = 0
   CALL pol1374_ativa_folder()
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1374_prende_andar()#
#--------------------------------#
   
   DEFINE l_codigo     CHAR(02)
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM andar_547
     WHERE cod_empresa =  p_cod_empresa
       AND cod_andar = mr_andar.cod_andar
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
   
#------------------------------#
FUNCTION pol1374_and_excluir()#
#------------------------------#
   
   DEFINE l_ret       SMALLINT

   IF m_and_atu = 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Selecione o registro a ser excluido.")
      RETURN FALSE
   END IF

   LET mr_andar.cod_andar = ma_andar[m_and_atu].cod_andar
   
   IF mr_andar.cod_andar IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados a serem excluidos.")
      RETURN FALSE
   END IF
   
   LET m_msg = 'Confirma a exclusão da andar ', mr_andar.cod_andar, ' ? '

   IF NOT LOG_question(m_msg) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      LET mr_andar.cod_andar = NULL
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_cod_andar,"GET_FOCUS")

   IF NOT pol1374_prende_andar() THEN
      LET mr_andar.cod_andar = NULL
      RETURN FALSE
   END IF

   DELETE FROM andar_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_andar = mr_andar.cod_andar

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','andar_547')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   LET mr_andar.cod_andar = NULL
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1374_andar_ler()
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION




#-----APTO---------------------#

#------------------------------#
FUNCTION pol1374_apto(l_fpanel)#
#------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_create    VARCHAR(10),
           l_delete    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1374_apto_inc")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1374_apto_inc_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1374_apto_inc_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1374_apto_ler")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1374_apto_excluir")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1374_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1374_apto_cabec(l_panel)
    CALL pol1374_apto_grade(l_panel)
    CALL pol1374_apto_ativ_desativ(FALSE)
    
END FUNCTION

#-----------------------------------------#
FUNCTION pol1374_apto_cabec(l_container)#
#-----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10)
           
    LET m_pan_apto = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_apto,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_apto,"HEIGHT",40)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_apto)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",30,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","apto:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET m_cod_apto = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_apto)     
    CALL _ADVPL_set_property(m_cod_apto,"POSITION",80,10) 
    CALL _ADVPL_set_property(m_cod_apto,"LENGTH",2,0)    
    CALL _ADVPL_set_property(m_cod_apto,"PICTURE","@!")  
    CALL _ADVPL_set_property(m_cod_apto,"VARIABLE",mr_apto,"cod_apto")
    CALL _ADVPL_set_property(m_cod_apto,"VALID","pol1374_valida_apto")

END FUNCTION

#----------------------------------------#
FUNCTION pol1374_apto_grade(l_container)#
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
   
    LET m_brz_apto = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_apto,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_apto,"BEFORE_ROW_EVENT","pol1374_apto_before_row")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_apto)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","apto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_apto")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_apto)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(m_brz_apto,"SET_ROWS",ma_apto,1)
    CALL _ADVPL_set_property(m_brz_apto,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_brz_apto,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#--------------------------#
FUNCTION pol1374_apto_ler()#
#--------------------------#

   CALL _ADVPL_set_property(m_brz_apto,"CLEAR")

   LET m_carregando = TRUE
   LET mr_apto.cod_apto = NULL
   INITIALIZE ma_apto TO NULL
   LET m_ind = 1
   
   DECLARE cq_le_apto CURSOR FOR
    SELECT cod_apto
      FROM apto_547
     WHERE cod_empresa = p_cod_empresa
   
   FOREACH cq_le_apto INTO ma_apto[m_ind].cod_apto
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','apto_547:cq_le_apto')
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
      CALL _ADVPL_set_property(m_brz_apto,"ITEM_COUNT", m_ind)
   END IF

   LET m_carregando = FALSE
   
END FUNCTION

#-------------------------------------------#
FUNCTION pol1374_apto_ativ_desativ(l_status)#
#-------------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_brz_apto,"CAN_ADD_ROW",l_status)
   CALL _ADVPL_set_property(m_pan_apto,"ENABLE",l_status)
      
END FUNCTION

#---------------------------------#
FUNCTION pol1374_apto_before_row()#
#---------------------------------#
  
   IF m_carregando THEN
      RETURN TRUE
   END IF
   
   LET m_apto_atu = _ADVPL_get_property(m_brz_apto,"ROW_SELECTED")
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1374_valida_apto()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_apto.cod_apto IS NULL THEN
      LET m_msg = 'Informe o código da apto.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT 1 FROM apto_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_apto = mr_apto.cod_apto

   IF STATUS = 0 THEN
      LET m_msg = 'Apto já cadastrado.'      
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   

#--------------------------#
FUNCTION pol1374_apto_inc()#
#--------------------------#

   CALL pol1374_apto_ativ_desativ(TRUE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_apto.* TO NULL
   CALL pol1374_desativa_folder("6")
   CALL _ADVPL_set_property(m_cod_apto,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1374_apto_inc_cancel()#
#---------------------------------#

   CALL pol1374_apto_ativ_desativ(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_apto.* TO NULL
   CALL pol1374_ativa_folder()
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1374_apto_inc_conf()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   INSERT INTO apto_547
    VALUES(p_cod_empresa, mr_apto.cod_apto)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','apto_547')
      RETURN false
   END IF   
   
   CALL pol1374_apto_ler()
   CALL pol1374_apto_ativ_desativ(FALSE)
   LET m_apto_atu = 0
   CALL pol1374_ativa_folder()
   
   RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION pol1374_prende_apto()#
#------------------------------#
   
   DEFINE l_codigo     CHAR(02)
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM apto_547
     WHERE cod_empresa =  p_cod_empresa
       AND cod_apto = mr_apto.cod_apto
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
   
#------------------------------#
FUNCTION pol1374_apto_excluir()#
#------------------------------#
   
   DEFINE l_ret       SMALLINT

   IF m_apto_atu = 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Selecione o registro a ser excluido.")
      RETURN FALSE
   END IF

   LET mr_apto.cod_apto = ma_apto[m_apto_atu].cod_apto
   
   IF mr_apto.cod_apto IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados a serem excluidos.")
      RETURN FALSE
   END IF
   
   LET m_msg = 'Confirma a exclusão da apto ', mr_apto.cod_apto, ' ? '

   IF NOT LOG_question(m_msg) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      LET mr_apto.cod_apto = NULL
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_cod_apto,"GET_FOCUS")

   IF NOT pol1374_prende_apto() THEN
      LET mr_apto.cod_apto = NULL
      RETURN FALSE
   END IF

   DELETE FROM apto_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_apto = mr_apto.cod_apto

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','apto_547')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   LET mr_apto.cod_apto = NULL
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1374_apto_ler()
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION



#-----RELACIONAMENTO-----------#

#------------------------------#
FUNCTION pol1374_relac(l_fpanel)#
#------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_create    VARCHAR(10),
           l_delete    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1374_relac_inc")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1374_relac_inc_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1374_relac_inc_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1374_relac_ler")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1374_relac_excluir")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1374_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1374_relac_cabec(l_panel)
    CALL pol1374_relac_grade(l_panel)
    CALL pol1374_relac_ativ_desativ(FALSE)
    
END FUNCTION

#-----------------------------------------#
FUNCTION pol1374_relac_cabec(l_container)#
#-----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_desc            VARCHAR(10)
           
    LET m_pan_relac = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_relac,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_relac,"HEIGHT",40)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_relac)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",30,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Relacto:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET m_relacto = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_relac)     
    CALL _ADVPL_set_property(m_relacto,"POSITION",90,10) 
    CALL _ADVPL_set_property(m_relacto,"LENGTH",10,0)    
    CALL _ADVPL_set_property(m_relacto,"ENABLE",FALSE)  
    CALL _ADVPL_set_property(m_relacto,"VARIABLE",mr_relac,"cod_relac")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_relac)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",200,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Linha:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET m_linha = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_relac)     
    CALL _ADVPL_set_property(m_linha,"POSITION",260,10) 
    CALL _ADVPL_set_property(m_linha,"VARIABLE",mr_relac,"cod_linha")
    CALL _ADVPL_set_property(m_linha,"ADD_ITEM","  ","  ")
    CALL _ADVPL_set_property(m_linha,"FONT",NULL,11,TRUE,FALSE)
    CALL _ADVPL_set_property(m_linha,"VALID","pol1374_set_relac")     

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_relac)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",320,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Prédio:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET m_predio = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_relac)     
    CALL _ADVPL_set_property(m_predio,"POSITION",380,10) 
    CALL _ADVPL_set_property(m_predio,"VARIABLE",mr_relac,"cod_predio")
    CALL _ADVPL_set_property(m_predio,"ADD_ITEM","  ","  ")
    CALL _ADVPL_set_property(m_predio,"FONT",NULL,11,TRUE,FALSE)
    CALL _ADVPL_set_property(m_predio,"VALID","pol1374_set_relac")     

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_relac)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",450,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Andar:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET m_andar = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_relac)     
    CALL _ADVPL_set_property(m_andar,"POSITION",505,10) 
    CALL _ADVPL_set_property(m_andar,"VARIABLE",mr_relac,"cod_andar")
    CALL _ADVPL_set_property(m_andar,"ADD_ITEM","  ","  ")
    CALL _ADVPL_set_property(m_andar,"FONT",NULL,11,TRUE,FALSE)
    CALL _ADVPL_set_property(m_andar,"VALID","pol1374_set_relac")     

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_relac)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",570,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Apto:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET m_apto = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_relac)     
    CALL _ADVPL_set_property(m_apto,"POSITION",620,10) 
    CALL _ADVPL_set_property(m_apto,"VARIABLE",mr_relac,"cod_apto")
    CALL _ADVPL_set_property(m_apto,"ADD_ITEM","  ","  ")
    CALL _ADVPL_set_property(m_apto,"FONT",NULL,11,TRUE,FALSE)
    CALL _ADVPL_set_property(m_apto,"VALID","pol1374_set_relac")     

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_relac)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",690,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Descrição:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET m_relacto = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_relac)     
    CALL _ADVPL_set_property(m_relacto,"POSITION",780,10) 
    CALL _ADVPL_set_property(m_relacto,"LENGTH",30,0)    
    CALL _ADVPL_set_property(m_relacto,"ENABLE",FALSE)  
    CALL _ADVPL_set_property(m_relacto,"VARIABLE",mr_relac,"den_relac")


END FUNCTION

#---------------------------#
FUNCTION pol1374_set_relac()#
#---------------------------#

   LET mr_relac.cod_relac = 
        mr_relac.cod_linha CLIPPED, 
        mr_relac.cod_predio CLIPPED,
        mr_relac.cod_andar CLIPPED,
        mr_relac.cod_apto CLIPPED

   LET mr_relac.den_relac = 
        'LI: ',mr_relac.cod_linha CLIPPED,', ', 
        'PR: ',mr_relac.cod_predio CLIPPED,', ',
        'AN: ',mr_relac.cod_andar CLIPPED,', ',
        'AP: ',mr_relac.cod_apto CLIPPED

   RETURN TRUE
   
END FUNCTION

#----------------------------------------#
FUNCTION pol1374_relac_grade(l_container)#
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
   
    LET m_brz_relac = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_relac,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_relac,"BEFORE_ROW_EVENT","pol1374_relac_before_row")
        
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_relac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Relacto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_relac")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_relac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Linha")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_linha")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_relac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Prédio")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_predio")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_relac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Andar")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_andar")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_relac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Apto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_apto")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_relac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_relac")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_relac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(m_brz_relac,"SET_ROWS",ma_relac,1)
    CALL _ADVPL_set_property(m_brz_relac,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_brz_relac,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#--------------------------#
FUNCTION pol1374_relac_ler()#
#--------------------------#

   CALL _ADVPL_set_property(m_brz_relac,"CLEAR")

   LET m_carregando = TRUE
   INITIALIZE ma_relac, mr_relac.* TO NULL
   LET m_ind = 1
   
   DECLARE cq_le_relac CURSOR FOR
    SELECT cod_relac,
           cod_linha,
           cod_predio,
           cod_andar,
           cod_apto,
           den_relac
      FROM relacto_547
     WHERE cod_empresa = p_cod_empresa
   
   FOREACH cq_le_relac INTO 
      ma_relac[m_ind].cod_relac, 
      ma_relac[m_ind].cod_linha,  
      ma_relac[m_ind].cod_predio, 
      ma_relac[m_ind].cod_andar,  
      ma_relac[m_ind].cod_apto, 
      ma_relac[m_ind].den_relac
            
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','relacto_547:cq_le_relac')
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
      CALL _ADVPL_set_property(m_brz_relac,"ITEM_COUNT", m_ind)
   END IF

   LET m_carregando = FALSE
   
END FUNCTION

#-------------------------------------------#
FUNCTION pol1374_relac_ativ_desativ(l_status)#
#-------------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_brz_relac,"CAN_ADD_ROW",l_status)
   CALL _ADVPL_set_property(m_pan_relac,"ENABLE",l_status)
      
END FUNCTION

#---------------------------------#
FUNCTION pol1374_relac_before_row()#
#---------------------------------#
  
   IF m_carregando THEN
      RETURN TRUE
   END IF
   
   LET m_relac_atu = _ADVPL_get_property(m_brz_relac,"ROW_SELECTED")
   
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1374_valida_relac()#
#------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_relac.cod_linha IS NULL THEN
      LET m_msg = 'Informe o código da linha.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_linha,"GET_FOCUS")
      RETURN FALSE
   END IF   

   IF mr_relac.cod_predio IS NULL THEN
      LET m_msg = 'Informe o código do prédio.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_predio,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_relac.cod_andar IS NULL THEN
      LET m_msg = 'Informe o código do andar.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_andar,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_relac.cod_apto IS NULL THEN
      LET m_msg = 'Informe o código do apto.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_apto,"GET_FOCUS")
      RETURN FALSE
   END IF      
      
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1374_le_relac()#
#--------------------------#
   
   DEFINE l_msg       CHAR(80)
   
   SELECT cod_relac
     FROM relacto_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_relac = mr_relac.cod_relac
   
   IF STATUS = 0 THEN
      LET l_msg = 'Relacionamento já cadastrado.'
   ELSE
      IF STATUS <> 100 THEN
         LET l_msg = 'Erro ',STATUS, ' lendo tabela relacto_547.'
      END IF
   END IF
   
   RETURN l_msg

END FUNCTION
   
#---------------------------#
FUNCTION pol1374_relac_inc()#
#---------------------------#

   CALL pol1374_relac_ativ_desativ(TRUE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_relac.* TO NULL
   CALL pol1374_desativa_folder("2")
   CALL pol1374_relac_carrega()
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1374_relac_inc_cancel()#
#---------------------------------#

   CALL pol1374_relac_ativ_desativ(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_relac.* TO NULL
   CALL pol1374_ativa_folder()
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1374_relac_inc_conf()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT pol1374_valida_relac() THEN
      RETURN FALSE
   END IF

   LET m_msg = pol1374_le_relac()

   IF m_msg IS NOT NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF         
         
   CALL LOG_transaction_begin()
   
   INSERT INTO relacto_547
    VALUES(p_cod_empresa, 
           mr_relac.cod_relac,
           mr_relac.cod_linha,
           mr_relac.cod_predio,
           mr_relac.cod_andar,
           mr_relac.cod_apto,
           mr_relac.den_relac)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','relacto_547')
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF   
   
   CALL LOG_transaction_commit()
   
   CALL pol1374_relac_ler()
   CALL pol1374_relac_ativ_desativ(FALSE)
   LET m_relac_atu = 0
   CALL pol1374_ativa_folder()
   RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION pol1374_prende_relac()#
#------------------------------#
   
   DEFINE l_codigo     CHAR(02)
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM relacto_547
     WHERE cod_empresa =  p_cod_empresa
       AND cod_relac = m_cod_relac
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
   
#-------------------------------#
FUNCTION pol1374_relac_excluir()#
#-------------------------------#
   
   DEFINE l_ret       SMALLINT

   IF m_relac_atu = 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Selecione o registro a ser excluido.")
      RETURN FALSE
   END IF

   LET m_cod_relac = ma_relac[m_relac_atu].cod_relac
   
   IF m_cod_relac IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados a serem excluidos.")
      RETURN FALSE
   END IF
   
   LET m_msg = 'Confirma a exclusão da relacto ', m_cod_relac, ' ? '

   IF NOT LOG_question(m_msg) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      INITIALIZE mr_relac.* TO NULL
      RETURN FALSE
   END IF

   IF NOT pol1374_prende_relac() THEN
      INITIALIZE mr_relac.* TO NULL
      RETURN FALSE
   END IF

   DELETE FROM relacto_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_relac = m_cod_relac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','relacto_547')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   INITIALIZE mr_relac.* TO NULL
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1374_relac_ler()
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION

#-------------------------------#
FUNCTION pol1374_relac_carrega()#
#-------------------------------#
   
   DEFINE l_codigo    CHAR(02)
  
   CALL _ADVPL_set_property(m_linha,"CLEAR") 
   CALL _ADVPL_set_property(m_linha,"ADD_ITEM","  ","  ") 

   DECLARE cq_car_lin CURSOR FOR
    SELECT cod_linha FROM linha_547
     WHERE cod_empresa = p_cod_empresa
   
   FOREACH cq_car_lin INTO l_codigo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_car_lin')
         EXIT FOREACH
      END IF
      
      CALL _ADVPL_set_property(m_linha,"ADD_ITEM",l_codigo,l_codigo)          
   
   END FOREACH

   CALL _ADVPL_set_property(m_predio,"CLEAR") 
   CALL _ADVPL_set_property(m_predio,"ADD_ITEM","  ","  ") 

   DECLARE cq_car_pred CURSOR FOR
    SELECT cod_predio FROM predio_547
     WHERE cod_empresa = p_cod_empresa
   
   FOREACH cq_car_pred INTO l_codigo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_car_pred')
         EXIT FOREACH
      END IF
      
      CALL _ADVPL_set_property(m_predio,"ADD_ITEM",l_codigo,l_codigo)          
   
   END FOREACH

   CALL _ADVPL_set_property(m_andar,"CLEAR") 
   CALL _ADVPL_set_property(m_andar,"ADD_ITEM","  ","  ") 

   DECLARE cq_car_and CURSOR FOR
    SELECT cod_andar FROM andar_547
     WHERE cod_empresa = p_cod_empresa
   
   FOREACH cq_car_and INTO l_codigo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_car_and')
         EXIT FOREACH
      END IF
      
      CALL _ADVPL_set_property(m_andar,"ADD_ITEM",l_codigo,l_codigo)          
   
   END FOREACH

   CALL _ADVPL_set_property(m_apto,"CLEAR") 
   CALL _ADVPL_set_property(m_apto,"ADD_ITEM","  ","  ") 

   DECLARE cq_car_apt CURSOR FOR
    SELECT cod_apto FROM apto_547
     WHERE cod_empresa = p_cod_empresa
   
   FOREACH cq_car_apt INTO l_codigo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_car_apt')
         EXIT FOREACH
      END IF
      
      CALL _ADVPL_set_property(m_apto,"ADD_ITEM",l_codigo,l_codigo)          
   
   END FOREACH

END FUNCTION


#---LOCAL DE ESTOQUE----#

#------------------------------#
FUNCTION pol1374_local(l_fpanel)#
#------------------------------#

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
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1374_info_item")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1374_info_item_conf")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1374_info_item_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1374_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1374_update_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1374_update_canc")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1374_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1374_local_item(l_panel)
    CALL pol1374_local_grade(l_panel)
    CALL pol1374_local_ativa_item(FALSE)
    CALL pol1374_local_ativa_local(FALSE)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1374_local_item(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_item = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_item,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_item,"HEIGHT",40)
    #CALL _ADVPL_set_property(m_pan_item,"BACKGROUND_COLOR",225,232,232) 
              
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_item)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Item:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_item)     
    CALL _ADVPL_set_property(m_cod_item,"POSITION",45,10) 
    CALL _ADVPL_set_property(m_cod_item,"LENGTH",15,0)    
    CALL _ADVPL_set_property(m_cod_item,"VARIABLE",mr_local,"cod_item")
    CALL _ADVPL_set_property(m_cod_item,"VALID","pol1374_valid_item")    

    LET m_lupa_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_item)
    CALL _ADVPL_set_property(m_lupa_item,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_item,"POSITION",175,10)     
    CALL _ADVPL_set_property(m_lupa_item,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_item,"CLICK_EVENT","pol1374_zoom_item")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_item)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",200,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",35,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_local,"den_item")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_item)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",500,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Local:")    
    #CALL _ADVPL_set_property(l_label,"FONT",NULL,10,TRUE,TRUE) 
    #CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_item)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",535,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_local,"cod_local")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_item)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",640,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_local,"den_local")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_item)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",900,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Novo local:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_new_local = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_item)     
    CALL _ADVPL_set_property(m_new_local,"POSITION",970,10) 
    CALL _ADVPL_set_property(m_new_local,"LENGTH",10,0)    
    CALL _ADVPL_set_property(m_new_local,"VARIABLE",mr_local,"new_local")
    CALL _ADVPL_set_property(m_new_local,"VALID","pol1374_valid_local")    

    LET m_lupa_local = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_item)
    CALL _ADVPL_set_property(m_lupa_local,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_local,"POSITION",1060,10)     
    CALL _ADVPL_set_property(m_lupa_local,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_local,"CLICK_EVENT","pol1374_zoom_local")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_item)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",1090,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",25,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_local,"new_desc")

END FUNCTION

#----------------------------------------#
FUNCTION pol1374_local_grade(l_container)#
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
   
    LET m_brz_local = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_local,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_local)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_local)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Local")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_local")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_local)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Local")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_local")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_local)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Lote")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_lote")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_local)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",10,3)  
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E #######.###")  
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_local)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Status")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_situa_qtd")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_local)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    CALL _ADVPL_set_property(m_brz_local,"SET_ROWS",ma_local,1)
    CALL _ADVPL_set_property(m_brz_local,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_brz_local,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#------------------------------------------#
FUNCTION pol1374_local_ativa_item(l_status)#
#------------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_cod_item,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_item,"ENABLE",l_status)
      
END FUNCTION

#-------------------------------------------#
FUNCTION pol1374_local_ativa_local(l_status)#
#-------------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_new_local,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_local,"ENABLE",l_status)
      
END FUNCTION

#---------------------------#
FUNCTION pol1374_zoom_item()#
#---------------------------#

    DEFINE l_codigo         LIKE item.cod_item,
           l_descri         LIKE item.den_item,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_item IS NULL THEN
       LET m_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_item,"ZOOM","zoom_item")
    END IF

    LET l_where_clause = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_item,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")
    LET l_descri = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","den_item")

    IF l_codigo IS NOT NULL THEN
       LET mr_local.cod_item = l_codigo
       LET mr_local.den_item = l_descri
    END IF        
    
END FUNCTION

#----------------------------#
FUNCTION pol1374_valid_item()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_local.cod_item IS NULL THEN
      LET m_msg = 'Informe o item.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT pol1374_le_item() THEN
      RETURN FALSE
   END IF

   IF NOT pol1374_le_local() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#-------------------------#   
FUNCTION pol1374_le_item()#
#-------------------------#

   SELECT den_item,
          cod_local_estoq
     INTO mr_local.den_item,
          mr_local.cod_local
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_local.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      LET mr_local.den_item = NULL
      LET mr_local.cod_local = NULL
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION    

#--------------------------#
FUNCTION pol1374_le_local()#
#--------------------------#

   SELECT den_local
     INTO mr_local.den_local
     FROM local
    WHERE cod_empresa = p_cod_empresa
      AND cod_local = mr_local.cod_local

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','local')
      LET mr_local.den_local = NULL
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   
   
#---------------------------#
FUNCTION pol1374_info_item()#
#---------------------------#

   CALL _ADVPL_set_property(m_pan_item,"ENABLE",TRUE)
   INITIALIZE mr_local.* TO NULL
   CALL pol1374_local_ativa_item(TRUE)
   LET m_info_item = FALSE   
   CALL pol1374_desativa_folder("1")
   CALL _ADVPL_set_property(m_cod_item,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1374_info_item_canc()#
#--------------------------------#

   CALL _ADVPL_set_property(m_pan_item,"ENABLE",FALSE)
   INITIALIZE mr_local.* TO NULL
   CALL pol1374_local_ativa_item(FALSE)
   CALL pol1374_ativa_folder()
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1374_info_item_conf()#
#--------------------------------#

   CALL pol1374_local_ativa_item(FALSE)
   LET m_info_item = TRUE

   IF NOT pol1374_le_estoq() THEN
      RETURN FALSE
   END IF
      
   CALL pol1374_ativa_folder()      
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1374_le_estoq()#
#--------------------------#
   
   DEFINE l_ind    INTEGER
   
   INITIALIZE ma_local TO NULL
   LET l_ind = 1
   
   DECLARE cq_estoq CURSOR FOR
    SELECT cod_item,
           cod_local,
           num_lote,
           qtd_saldo,
           ies_situa_qtd
      FROM estoque_lote
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = mr_local.cod_item
       AND qtd_saldo > 0

   FOREACH cq_estoq INTO 
      ma_local[l_ind].cod_item,
      ma_local[l_ind].cod_local,
      ma_local[l_ind].num_lote,
      ma_local[l_ind].qtd_saldo,
      ma_local[l_ind].ies_situa_qtd

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','estoque_lote:cq_estoq')
         RETURN FALSE
      END IF

      SELECT den_local INTO ma_local[l_ind].den_local
        FROM local WHERE cod_empresa = p_cod_empresa
         AND cod_local = ma_local[l_ind].cod_local
      IF STATUS = 100 THEN
         LET ma_local[l_ind].den_local = 'Não cadastrado.'
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','local:cq_estoq')
            RETURN FALSE
         END IF
      END IF
      
      LET l_ind = l_ind + 1
   
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   CALL _ADVPL_set_property(m_brz_local,"SET_ROWS",ma_local,l_ind)
    
   RETURN TRUE

END FUNCTION   
 
    
      

#-----------------------------#
FUNCTION pol1374_valid_local()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_local.new_local IS NULL THEN
      LET m_msg = 'Informe o novo local.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET m_msg = pol1374_le_relacto()
   
   IF m_msg IS NOT NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#----------------------------#
FUNCTION pol1374_le_relacto()#
#----------------------------#
   
   DEFINE l_msg       CHAR(80)
   
   SELECT den_relac
     INTO mr_local.new_desc
     FROM relacto_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_relac = mr_local.new_local
   
   IF STATUS = 100 THEN
      LET l_msg = 'Relacionamento não cadastrado cadastrado.'
   ELSE
      IF STATUS <> 0 THEN
         LET l_msg = 'Erro ',STATUS, ' lendo tabela relacto_547.'
      END IF
   END IF
   
   RETURN l_msg

END FUNCTION

#------------------------#
FUNCTION pol1374_update()#
#------------------------#   
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT m_info_item THEN
      LET m_msg = 'Informe o item previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   INITIALIZE mr_local.new_local, mr_local.new_desc TO NULL
   CALL pol1374_local_ativa_local(TRUE)
   CALL _ADVPL_set_property(m_new_local,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1374_update_canc()#
#-----------------------------#   

   INITIALIZE mr_local.new_local, mr_local.new_desc TO NULL
   CALL pol1374_local_ativa_local(FALSE)
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1374_update_conf()#
#-----------------------------#   

   CALL pol1374_local_ativa_local(FALSE)
   
   CALL LOG_transaction_begin()
   
   IF NOT pol1374_grava_local() THEN
      CALL  LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1374_grava_local()#
#-----------------------------#
   
   UPDATE item 
      SET cod_local_estoq = mr_local.new_local
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_local.cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','local')
      RETURN FALSE
   END IF
      
   SELECT 1 FROM local
    WHERE cod_empresa = p_cod_empresa
      AND cod_local = mr_local.new_local
   
   IF STATUS = 0 THEN
   ELSE
      IF STATUS = 100 THEN
         IF NOT pol1374_ins_local() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('SELECT','local')
         RETURN FALSE
      END IF
   END IF   
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1374_ins_local()#
#---------------------------#

   INSERT INTO local
    VALUES(p_cod_empresa,
           mr_local.new_local,
           mr_local.new_desc,0)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','local')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
           
#-----------------------------------------#
FUNCTION pol1374_desativa_folder(l_folder)#
#-----------------------------------------#

   DEFINE l_folder             CHAR(01)
             
   CASE l_folder
        WHEN '1' 
           CALL _ADVPL_set_property(m_fold_andar,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_apto,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_linha,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_predio,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_relac,"ENABLE",FALSE)        
           CALL _ADVPL_set_property(m_fold_etiq,"ENABLE",FALSE)        
        WHEN '2' 
           CALL _ADVPL_set_property(m_fold_andar,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_apto,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_linha,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_predio,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_local,"ENABLE",FALSE)        
           CALL _ADVPL_set_property(m_fold_etiq,"ENABLE",FALSE)        
        WHEN '3' 
           CALL _ADVPL_set_property(m_fold_andar,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_apto,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_local,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_predio,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_relac,"ENABLE",FALSE)        
           CALL _ADVPL_set_property(m_fold_etiq,"ENABLE",FALSE)        
        WHEN '4' 
           CALL _ADVPL_set_property(m_fold_local,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_apto,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_linha,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_andar,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_relac,"ENABLE",FALSE)        
           CALL _ADVPL_set_property(m_fold_etiq,"ENABLE",FALSE)        
        WHEN '5' 
           CALL _ADVPL_set_property(m_fold_apto,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_local,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_linha,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_predio,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_relac,"ENABLE",FALSE)        
           CALL _ADVPL_set_property(m_fold_etiq,"ENABLE",FALSE)        
        WHEN '6' 
           CALL _ADVPL_set_property(m_fold_andar,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_local,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_linha,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_predio,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_relac,"ENABLE",FALSE)        
           CALL _ADVPL_set_property(m_fold_etiq,"ENABLE",FALSE)        
        WHEN '7' 
           CALL _ADVPL_set_property(m_fold_apto,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_andar,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_local,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_linha,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_predio,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_relac,"ENABLE",FALSE)        
   END CASE
   
END FUNCTION

#------------------------------#
FUNCTION pol1374_ativa_folder()#
#------------------------------#

   CALL _ADVPL_set_property(m_fold_andar,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_apto,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_linha,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_local,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_predio,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_relac,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_etiq,"ENABLE",TRUE)

END FUNCTION

#----------------------------#
FUNCTION pol1374_zoom_local()#
#----------------------------#

    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","ZOOM LOCAL")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","relacto_547","local")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","relacto_547","cod_relac","Relac",1 {CHAR},10,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","relacto_547","cod_linha","Linha",1 {CHAR},2,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","relacto_547","cod_predio","Prédio",1 {CHAR},2,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","relacto_547","cod_andar","Andar",1 {CHAR},2,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","relacto_547","cod_apto","Apto",1 {CHAR},2,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF  l_status THEN
        LET l_where_clause = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_construct,"ORDER_BY")
        CALL pol1374_cria_cursor(l_where_clause,l_order_by)
    ELSE
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
    CALL _ADVPL_set_property(m_new_local,"GET_FOCUS")
    
END FUNCTION

#------------------------------------------------------#
FUNCTION pol1374_cria_cursor(l_where_clause,l_order_by)#
#------------------------------------------------------#
 
   DEFINE l_where_clause CHAR(800)
   DEFINE l_order_by     CHAR(200)

   DEFINE l_sql_stmt     CHAR(2000),
          l_ind          INTEGER,
          l_ano          CHAR(04),
          l_mes          CHAR(02)

   IF  l_order_by IS NULL THEN
       LET l_order_by = "cod_relac"
   END IF

   INITIALIZE ma_rateio TO NULL
   LET l_ind = 1
   
   LET l_sql_stmt = "SELECT cod_relac,den_relac ",
                     " FROM relacto_547 ",
                    " WHERE ", l_where_clause CLIPPED,
                    "   AND cod_empresa = '",p_cod_empresa,"' ",
                    " ORDER BY ", l_order_by

   PREPARE var_pesquisa FROM l_sql_stmt
    
   IF  Status <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","var_pesquisa")
       RETURN 
   END IF

   DECLARE cq_cons SCROLL CURSOR FOR var_pesquisa

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE CURSOR","cq_cons")
       RETURN 
   END IF
   
   INITIALIZE ma_zoom TO NULL
   
   FOREACH cq_cons INTO 
      ma_zoom[l_ind].cod_relac, 
      ma_zoom[l_ind].den_relac
            
      IF  STATUS <> 0 THEN
          CALL log003_err_sql("FOREACH","cq_cons")
          RETURN 
      END IF

      LET l_ind = l_ind + 1

      IF l_ind > 500 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF l_ind = 1 THEN
      LET m_msg = 'Não há dados, para os argumentos informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN
   END IF
   
   LET m_index = l_ind - 1
   
   CALL pol1374_tela_zoom()
   
END FUNCTION

#---------------------------#
FUNCTION pol1374_tela_zoom()#
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

    CALL pol1374_exibe_rateio(l_panel)

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
   CALL _ADVPL_set_property(l_select,"EVENT","pol1374_select")     

   LET l_cancel = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancel,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancel,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancel,"EVENT","pol1374_cancel")     

   CALL _ADVPL_set_property(m_form_popup,"ACTIVATE",TRUE)


END FUNCTION

#-----------------------------------------#
FUNCTION pol1374_exibe_rateio(l_container)#
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
    CALL _ADVPL_set_property(m_brow_popup,"BEFORE_ROW_EVENT","pol1374_row_popup")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_popup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Local")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_relac")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_popup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",300)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_relac")
   
    CALL _ADVPL_set_property(m_brow_popup,"SET_ROWS",ma_zoom,m_index)
    CALL _ADVPL_set_property(m_brow_popup,"CAN_ADD_ROW",FALSE)
    

END FUNCTION

#---------------------------#
FUNCTION pol1374_row_popup()#
#---------------------------#

   DEFINE l_lin_atu       SMALLINT
      
   LET l_lin_atu = _ADVPL_get_property(m_brow_popup,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN
      LET m_num_relac = ma_zoom[l_lin_atu].cod_relac
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1374_select()#
#------------------------#

   CALL _ADVPL_set_property(m_form_popup,"ACTIVATE",FALSE)
   LET mr_local.new_local = m_num_relac

   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1374_cancel()#
#------------------------#

   CALL _ADVPL_set_property(m_form_popup,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION

#---IMPRESSÃO DE ETIQUETA----#

#----------------------------------#
FUNCTION pol1374_etiqueta(l_fpanel)#
#----------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_inform    VARCHAR(10),
           l_select    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10),
           l_print     VARCHAR(10),
           l_print_all VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1374_etiq_info")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1374_etiq_info_conf")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1374_etiq_info_canc")

    LET l_select = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_select,"IMAGE","SELECIONAR_OPCAO")
    CALL _ADVPL_set_property(l_select,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_select,"TOOLTIP","Selecionar itens para etiqueta")
    CALL _ADVPL_set_property(l_select,"EVENT","pol1374_etiq_selec")
    CALL _ADVPL_set_property(l_select,"CONFIRM_EVENT","pol1374_etiq_selec_conf")
    CALL _ADVPL_set_property(l_select,"CANCEL_EVENT","pol1374_etiq_selec_canc")

    LET l_print = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_print,"IMAGE","ETIQUETAS") 
    CALL _ADVPL_set_property(l_print,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_print,"TOOLTIP","Imprimir etiquetas de itens selecionados")
    CALL _ADVPL_set_property(l_print,"EVENT","pol1324_print_etiqueta")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1374_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1374_etiq_cabec(l_panel)
    CALL pol1374_etiq_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1374_etiq_cabec(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_etiq = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_etiq,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_etiq,"HEIGHT",40)
    CALL _ADVPL_set_property(m_pan_etiq,"ENABLE",FALSE)
    #CALL _ADVPL_set_property(m_pan_etiq,"BACKGROUND_COLOR",225,232,232) 
              
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_etiq)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)   
    CALL _ADVPL_set_property(l_label,"TEXT","Local:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_etiq_local = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_etiq)     
    CALL _ADVPL_set_property(m_etiq_local,"POSITION",45,10) 
    CALL _ADVPL_set_property(m_etiq_local,"LENGTH",10,0)    
    CALL _ADVPL_set_property(m_etiq_local,"VARIABLE",mr_etiq,"cod_local")
    CALL _ADVPL_set_property(m_etiq_local,"VALID","pol1374_etiq_valid_local")

    LET m_et_lup_local = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_etiq)
    CALL _ADVPL_set_property(m_et_lup_local,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_et_lup_local,"POSITION",145,10)     
    CALL _ADVPL_set_property(m_et_lup_local,"SIZE",24,20)
    CALL _ADVPL_set_property(m_et_lup_local,"CLICK_EVENT","pol1374_zoom_etiq_local")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_etiq)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",185,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",TRUE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_etiq,"den_local")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_etiq)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",535,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Item:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_etiq_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_etiq)     
    CALL _ADVPL_set_property(m_etiq_item,"POSITION",570,10) 
    CALL _ADVPL_set_property(m_etiq_item,"LENGTH",15,0)    
    CALL _ADVPL_set_property(m_etiq_item,"VARIABLE",mr_etiq,"cod_item")
    CALL _ADVPL_set_property(m_etiq_item,"VALID","pol1374_etiq_valid_item")

    LET m_et_lup_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_etiq)
    CALL _ADVPL_set_property(m_et_lup_item,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_et_lup_item,"POSITION",710,10)     
    CALL _ADVPL_set_property(m_et_lup_item,"SIZE",24,20)
    CALL _ADVPL_set_property(m_et_lup_item,"CLICK_EVENT","pol1374_zoom_etiq_item")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_etiq)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",750,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",35,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",TRUE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_etiq,"den_item")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1374_etiq_grade(l_container)#
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
   
    LET m_brz_etiq = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_etiq,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_etiq)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CONFIRM_EX")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Select")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_etiq")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_etiq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Local")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_local")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_etiq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_local")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_etiq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_etiq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_etiq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Unidade")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_unid_med")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    CALL _ADVPL_set_property(m_brz_etiq,"SET_ROWS",ma_etiq,1)
    CALL _ADVPL_set_property(m_brz_etiq,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_etiq,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#----------------------------------#
FUNCTION pol1374_etiq_valid_local()#
#----------------------------------#
   
   IF mr_etiq.cod_local IS NOT NULL THEN
      IF NOT pol1374_etiq_le_local() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1374_etiq_le_local()#
#-------------------------------#

   SELECT den_local 
     INTO mr_etiq.den_local
     FROM local 
    WHERE cod_empresa = p_cod_empresa
      AND cod_local = mr_etiq.cod_local

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','local')
      RETURN FALSE
   END IF
   
   RETURN TRUE   

END FUNCTION

#---------------------------------#
FUNCTION pol1374_etiq_valid_item()#
#---------------------------------#
   
   IF mr_etiq.cod_item IS NOT NULL THEN
      IF NOT pol1374_etiq_le_item() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#   
FUNCTION pol1374_etiq_le_item()#
#------------------------------#

   SELECT den_item
     INTO mr_etiq.den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_etiq.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION    

#---------------------------------#
FUNCTION pol1374_zoom_etiq_local()#
#---------------------------------#

    DEFINE l_codigo         LIKE local.cod_local,
           l_descri         LIKE local.den_local,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_etiq_local IS NULL THEN
       LET m_zoom_etiq_local = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_etiq_local,"ZOOM","zoom_local")
    END IF

    LET l_where_clause = " local.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_etiq_local,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_etiq_local,"RETURN_BY_TABLE_COLUMN","local","cod_local")
    LET l_descri = _ADVPL_get_property(m_zoom_etiq_local,"RETURN_BY_TABLE_COLUMN","local","den_local")

    IF l_codigo IS NOT NULL THEN
       LET mr_etiq.cod_local = l_codigo
       LET mr_etiq.den_local = l_descri
    END IF        
    
    CALL _ADVPL_set_property(m_etiq_local,"GET_FOCUS")
    
END FUNCTION

#--------------------------------#
FUNCTION pol1374_zoom_etiq_item()#
#--------------------------------#

    DEFINE l_codigo         LIKE item.cod_item,
           l_descri         LIKE item.den_item,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_etiq_item IS NULL THEN
       LET m_zoom_etiq_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_etiq_item,"ZOOM","zoom_item")
    END IF

    LET l_where_clause = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_etiq_item,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_etiq_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")
    LET l_descri = _ADVPL_get_property(m_zoom_etiq_item,"RETURN_BY_TABLE_COLUMN","item","den_item")

    IF l_codigo IS NOT NULL THEN
       LET mr_etiq.cod_item = l_codigo
       LET mr_etiq.den_item = l_descri
    END IF        
    
    CALL _ADVPL_set_property(m_etiq_item,"GET_FOCUS")
    
END FUNCTION

#---------------------------#
FUNCTION pol1374_etiq_info()#
#---------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL _ADVPL_set_property(m_pan_etiq,"ENABLE",TRUE)
   INITIALIZE mr_local.* TO NULL
   LET m_info_etiq = FALSE   
   CALL pol1374_desativa_folder("7")
   CALL _ADVPL_set_property(m_etiq_local,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1374_etiq_info_canc()#
#--------------------------------#

   CALL _ADVPL_set_property(m_pan_etiq,"ENABLE",FALSE)
   INITIALIZE mr_etiq.* TO NULL
   CALL pol1374_ativa_folder()
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1374_etiq_info_conf()#
#--------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')     
   
   IF NOT pol1374_etiq_le_dados() THEN
      RETURN FALSE
   END IF
    
   CALL _ADVPL_set_property(m_pan_etiq,"ENABLE",FALSE)
   LET m_info_etiq = TRUE
   CALL pol1374_ativa_folder()
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1374_etiq_le_dados()#
#-------------------------------#
   
   SELECT COUNT(*) INTO m_count
     FROM item i, local l
    WHERE i.cod_empresa = l.cod_empresa
      AND i.cod_local_estoq = l.cod_local
      AND i.cod_empresa = p_cod_empresa
      AND ((i.cod_item = mr_etiq.cod_item AND mr_etiq.cod_item IS NOT NULL) OR
           (1=1 AND mr_etiq.cod_item IS NULL))
      AND ((i.cod_local_estoq = mr_etiq.cod_local AND mr_etiq.cod_local IS NOT NULL) OR
           (1=1 AND mr_etiq.cod_local IS NULL))
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item/local:count')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Não ha dados para os parãmetros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg) 
      RETURN FALSE
   END IF

   LET p_status = LOG_progresspopup_start(
     "Carregando...","pol1374_etiq_carrega","PROCESS") 
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1374_etiq_carrega()#
#------------------------------#
   
   DEFINE l_progres       SMALLINT,
          l_ind           INTEGER
   
   LET m_car_etiq = TRUE
   
   INITIALIZE ma_etiq TO NULL
   CALL _ADVPL_set_property(m_brz_etiq,"CLEAR")
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   LET l_ind = 1
   
   DECLARE cq_car_etiq CURSOR FOR
    SELECT 'N', l.cod_local, l.den_local, i.cod_item, i.den_item, i.cod_unid_med
     FROM item i, local l
    WHERE i.cod_empresa = l.cod_empresa
      AND i.cod_local_estoq = l.cod_local
      AND i.cod_empresa = p_cod_empresa
      AND ((i.cod_item = mr_etiq.cod_item AND mr_etiq.cod_item IS NOT NULL) OR
           (1=1 AND mr_etiq.cod_item IS NULL))
      AND ((i.cod_local_estoq = mr_etiq.cod_local AND mr_etiq.cod_local IS NOT NULL) OR
           (1=1 AND mr_etiq.cod_local IS NULL))
   
   FOREACH cq_car_etiq INTO
      ma_etiq[l_ind].ies_etiq,
      ma_etiq[l_ind].cod_local,
      ma_etiq[l_ind].den_local,
      ma_etiq[l_ind].cod_item,
      ma_etiq[l_ind].den_item,
      ma_etiq[l_ind].cod_unid_med
                
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item/local:cq_car_etiq')
         RETURN FALSE
      END IF   
     
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 10000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.\n	',
                     'Serão exibidos apenas 1000 registros.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   LET m_item_etiq = l_ind - 1
   
   CALL _ADVPL_set_property(m_brz_etiq,"ITEM_COUNT", m_item_etiq)
   LET m_car_etiq = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1374_etiq_selec()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')     
   
   IF NOT m_info_etiq THEN
      LET m_msg = 'Informe previamente os parâmetros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)   
      RETURN FALSE
   END IF
   
   LET m_sel_etiq = FALSE
   CALL _ADVPL_set_property(m_brz_etiq,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_brz_etiq,"SELECT_ITEM",1,1)

END FUNCTION

#---------------------------------#
FUNCTION pol1374_etiq_selec_canc()#
#---------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')     
   CALL _ADVPL_set_property(m_brz_etiq,"EDITABLE",FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1374_etiq_selec_conf()#
#---------------------------------#

   DEFINE l_ind       INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')     
   
   FOR l_ind = 1 TO m_item_etiq
       IF ma_etiq[l_ind].ies_etiq = 'S' THEN
          LET m_sel_etiq = TRUE
          RETURN TRUE
       END IF
   END FOR
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Selecione ao menos um item')     
   
   RETURN FALSE
      
END FUNCTION

#--------------------------------#
FUNCTION pol1324_print_etiqueta()#
#--------------------------------#
   
   DEFINE l_count      INTEGER
   
   IF NOT m_info_etiq THEN
      LET m_msg = 'Informe previamente os parâmetros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)   
      RETURN FALSE
   END IF

   IF NOT m_sel_etiq THEN
      LET m_msg = 'Não há itens selecionados.\n Deseja imprimir etiqueta p/ todos?'
      IF NOT LOG_question(m_msg) THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Operação cancelada.")
         RETURN FALSE
      END IF
      LET m_imp_etiq = 'T'
   ELSE
      LET m_imp_etiq = 'S'
   END IF

   CALL log085_transacao("BEGIN")

   LET p_status = LOG_progresspopup_start(
     "Salvando dados...","pol1374_etiq_salvar","PROCESS") 

   IF NOT p_status THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")

   SELECT COUNT(*) INTO l_count FROM etiq_item_970
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','etiq_item_970:count-2')
      RETURN FALSE
   END IF   
   
   IF l_count = 0 THEN
      LET m_msg = 'Não há itens selecionados para imprimir.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF   

   IF NOT pol1374_chama_delphi() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1374_etiq_salvar()#
#-----------------------------#
   
   DEFINE l_ind      INTEGER,
          l_progres  SMALLINT

   LOCK TABLE etiq_item_970 IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Bloqueando','etiq_item_970')
      RETURN FALSE
   END IF   
      
   DELETE FROM etiq_item_970
   
   SELECT COUNT(*) INTO l_ind FROM etiq_item_970
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','etiq_item_970:count-1')
      RETURN FALSE
   END IF   
   
   IF l_ind > 0 THEN
      LET m_msg = 'Não foi possivel limpar a tabela etiq_item_970'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF   
   
   CALL LOG_progresspopup_set_total("PROCESS",m_item_etiq)
   
   FOR l_ind = 1 TO m_item_etiq
       IF m_imp_etiq = 'S' THEN
          IF ma_etiq[l_ind].ies_etiq = 'S' THEN
             IF NOT pol1374_ins_item(l_ind) THEN
                RETURN FALSE
             END IF
          END IF
       ELSE
          IF NOT pol1374_ins_item(l_ind) THEN
             RETURN FALSE
          END IF
       END IF          
       LET l_progres = LOG_progresspopup_increment("PROCESS")              
   END FOR
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1374_ins_item(l_ind)#
#-------------------------------#
   
   DEFINE l_ind     INTEGER
   
   INSERT INTO etiq_item_970 VALUES(                           
      ma_etiq[l_ind].cod_item,                                 
      ma_etiq[l_ind].den_item,                                 
      ma_etiq[l_ind].cod_unid_med,                             
      ma_etiq[l_ind].cod_local)                                
   
   IF STATUS <> 0 THEN                                         
      CALL log003_err_sql('INSERT','etiq_item_970')            
      RETURN FALSE      
   END IF
   
   RETURN TRUE

END FUNCTION                                          

#------------------------------#
FUNCTION pol1374_chama_delphi()#
#------------------------------#
   
   DEFINE l_caminho_pgi   VARCHAR(120),
          l_param         VARCHAR(200),
          p_comando       VARCHAR(300),
          l_proces        CHAR(01),
          l_carac         CHAR(01),
          l_file          CHAR(250),
          l_tenta         INTEGER,
          l_progres       SMALLINT        
   
   SELECT nom_caminho
     INTO l_caminho_pgi
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "PGI"

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema PGI não cadastrado na LOG1100.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("SELECT","path_logix_v2:PGI")
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1374_dirExist(l_caminho_pgi) THEN
      RETURN FALSE
   END IF
   
   LET l_file = l_caminho_pgi CLIPPED, 'pgi1374.exe'
  
   IF NOT LOG_file_exist(l_file,0) THEN
     IF NOT LOG_file_exist(l_file,1) THEN
        LET m_msg = "Arquivo não encontrado ", l_file CLIPPED
        CALL log0030_mensagem(m_msg,'info')
        RETURN FALSE
     END IF
   END IF
      
   LET p_comando = l_caminho_pgi CLIPPED, 'pgi1393.exe ' 
     
   CALL conout(p_comando)      
      
   #CALL runOnClient(p_comando)    
   CALL LOG_RunOnServer(p_comando)   
     
   RETURN TRUE      

END FUNCTION   

#-------------------------------#
FUNCTION pol1374_dirExist(l_dir)#
#-------------------------------#

  DEFINE l_dir  CHAR(250),
         l_msg  CHAR(250)
 
  LET l_dir = l_dir CLIPPED
 
  IF NOT LOG_dir_exist(l_dir,0) THEN
     IF NOT LOG_dir_exist(l_dir,1) THEN
        LET l_msg = "Diretório não existe:\n ",l_dir
        CALL log0030_mensagem(l_msg,'info')
        RETURN FALSE
     END IF     
  END IF
  
  RETURN TRUE
   
END FUNCTION
