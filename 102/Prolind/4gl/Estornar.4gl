
#--------------------------#
FUNCTION pol1301_estornar()#
#--------------------------#
      
    DEFINE l_menubar       VARCHAR(10),
           l_panel         VARCHAR(10),
           l_inform        VARCHAR(10)

    LET m_form_estorna = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_estorna,"SIZE",1000,400)
    CALL _ADVPL_set_property(m_form_estorna,"TITLE","ESTONO DE APONTAMENTO")

    LET m_bar_estorna = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_estorna)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_estorna)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1301_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1301_info_conf")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1301_info_cancelar")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_estorna)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) #vermelho,verde,azul

    CALL pol1301_gera_grade(l_panel)

    CALL _ADVPL_set_property(m_brow_est,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brow_est,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_brow_est,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_form_estorna,"ACTIVATE",TRUE)

   RETURN TRUE
  
END FUNCTION

#---------------------------------------#
FUNCTION pol1301_gera_grade(l_container)#
#---------------------------------------#

    DEFINE l_container           VARCHAR(10),
           l_panel               VARCHAR(10),
           l_layout              VARCHAR(10),
           l_label               VARCHAR(10),
           l_field               VARCHAR(10),
           l_tabcolumn           VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    
    LET m_brow_est = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brow_est,"ALIGN","CENTER")
    
    CALL _ADVPL_set_property(m_brow_est,"AFTER_ROW_EVENT","pol1301_cheka_linha")
    
    # colunas da grade

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Estornar ?")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_estornar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Data do apontamento")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_processo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Hora do apontamento")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_processo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Processo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_processo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
        
    CALL _ADVPL_set_property(m_brow_est,"SET_ROWS",ma_estorno,1)
        
END FUNCTION

#-----------------------------#
FUNCTION pol1301_cheka_linha()#
#-----------------------------#
   
   DEFINE l_lin_atu       SMALLINT

   LET l_lin_atu = _ADVPL_get_property(m_brow_est,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN


   END IF   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1301_le_processo()#
#-----------------------------#
   
   DEFINE l_ind     INTEGER
   
   INITIALIZE ma_estorno TO NULL
   
   LET l_ind = 1
   
   DECLARE cq_le_proces CURSOR FOR
    SELECT *
      FROM processo_apont_pol1301
     WHERE cod_empresa = p_cod_empresa
       AND usuario = p_user
       AND cod_status = 'A'
     ORDER BY dat_processo, hor_processo
   
   FOREACH cq_le_proces INTO ma_estorno[l_ind].*      
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','processo_apont_pol1301')
         RETURN FALSE
      END IF
            
      LET l_ind = l_ind + 1
      
      IF l_ind > 1000 THEN
         CALL log0030_mensagem("Limite de linhas da grade ultrapassou!","excl")
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   FREE cq_le_proces
   
   LET m_qtd_linha = l_ind - 1

   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_linha)

END FUNCTION

#--------------------------#
FUNCTION pol1301_informar()#
#--------------------------#

    IF NOT pol1301_le_processo() THEN
       RETURN FALSE
    END IF

   IF NOT m_qtd_linha <= 0 THEN
      LET m_msg = 'Usuário sem processo de\n',
                  'apontamento p/ estornar.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   CALL _ADVPL_set_property(m_bar_estorna,"ERROR_TEXT", 
          " ENTER ou 2 Clicks -> Marca/Desmarca")     
          
   CALL _ADVPL_set_property(m_brow_est,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_brow_est,"SELECT_ITEM",1,1)
               
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1301_info_cancelar()#
#-------------------------------#

   CALL _ADVPL_set_property(m_brow_est,"EDITABLE",FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1301_info_conf()#
#---------------------------#
   
   DEFINE l_ind      INTEGER,
          l_ies_sel  SMALLINT
   
   LET l_ies_sel = FALSE
   
   FOR l_ind = 1 TO m_qtd_linha
       IF ma_estorno[l_ind].ies_estornar = 'S' THEN
          LET l_ies_sel = TRUE
          EXIT
       END IF       
   END FOR

   IF NOT l_ies_sel THEN
      CALL _ADVPL_set_property(m_bar_estorna,"ERROR_TEXT",
             "Selecione pelo menos um apontamento a estornar.")
      RETURN FALSE
   END IF
   
   LET m_msg = "Confirma o estorno dos\n itens selecionados?"
   
   IF NOT LOG_question(m_msg) THEN
      RETURN FALSE
   END IF
   
   LET m_critica = FALSE
   
   FOR m_ind = 1 TO m_qtd_linha
       IF ma_estorno[m_ind].ies_estornar = 'S' THEN
          IF NOT pol1301_exec_estorno() THEN
             EXIT
          END IF
       END IF
   END FOR

   IF m_critica THEN
   
   END IF

   RETURN TRUE
   
END FUNCTION
 
#------------------------------#
FUNCTION pol1301_exec_estorno()#
#------------------------------#

   LET m_num_processo = ma_estorno[m_ind].num_processo





   LET p_dat_atu = TODAY
   LET p_hor_atu = TIME
   LET p_cod_tip_movto = 'R'
   
   LET p_criticou = FALSE
   LET p_qtd_erro = 0
   INITIALIZE pr_erro_est TO NULL
   
   IF NOT pol0803_le_parametros() THEN
      RETURN FALSE
   END IF
   
   DECLARE cq_aptos CURSOR FOR
    SELECT * 
      FROM man_apont_1054
     WHERE cod_empresa  = p_cod_empresa
       AND num_processo = p_num_processo
       AND cod_status   = 'A'
     ORDER BY num_seq_apont DESC

   FOREACH cq_aptos INTO p_man.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_man')
         RETURN FALSE
      END IF                                           

      LET p_num_seq_apont = p_man.num_seq_apont

      SELECT seq_apo_oper,  
             seq_apo_mestre
        INTO p_num_seq_reg, 
             p_seq_reg_mestre
        FROM sequencia_apo_1054
       WHERE cod_empresa   = p_cod_empresa
         AND num_processo  = p_num_processo
         AND num_seq_apont = p_num_seq_apont

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','sequencia_apo_1054')
         RETURN FALSE
      END IF                                           

      IF NOT pol0803_checa_apont() THEN
         RETURN FALSE
      END IF       

      IF p_man.oper_final = 'S' THEN
         IF NOT pol0803_eh_possivel() THEN
           RETURN FALSE
         END IF
      END IF

      IF p_criticou THEN
         RETURN FALSE
      END IF
      
      IF NOT pol0803_estorna_novas() THEN
         RETURN FALSE
      END IF       

      IF NOT pol0803_estorna_velhas() THEN
         RETURN FALSE
      END IF       
         
      IF p_man.oper_final = 'S' THEN
         IF NOT pol0803_estorna_estoq() THEN
           RETURN FALSE
         END IF
      END IF

   END FOREACH
   
   UPDATE processo_apont_1054
      SET ies_estornado = 'S'
    WHERE cod_empresa = p_cod_empresa
      AND usuario = p_nom_usuario
      AND dat_processo = p_dat_processo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','processo_apont_1054')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION      
