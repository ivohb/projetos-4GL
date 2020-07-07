#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1323                                                 #
# OBJETIVO: TROCA COMPONENTE DA ESTRUTURA                           #
# AUTOR...: IVO                                                     #
# DATA....: 06/09/17                                                #
#-------------------------------------------------------------------#

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
       m_panel           VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_item            VARCHAR(10),
       m_novo            VARCHAR(10),
       m_quant           VARCHAR(10),
       m_lupa_it         VARCHAR(10),
       m_zoom_it         VARCHAR(10),
       m_browse          VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_cod_item        CHAR(15),
       m_cod_novo        CHAR(15),
       m_cod_pai         CHAR(15),
       m_situa           CHAR(01)

DEFINE mr_cabec          RECORD
       cod_item          CHAR(15),
       den_item          CHAR(70),
       cod_novo          CHAR(15),
       den_novo          CHAR(70)
END RECORD

DEFINE lr_estrut       RECORD LIKE estrut_grade.*
DEFINE mr_estrut       RECORD LIKE estrutura.*

DEFINE ma_audit        ARRAY[3000] OF RECORD
       cod_empresa     CHAR(02),
       cod_compon      CHAR(15),
       den_compon      CHAR(18),
       cod_subst       CHAR(15),
       den_subst       CHAR(18),
       dat_subst       CHAR(19),
       usuario         CHAR(08),
       qtd_troca       INTEGER,
       filler          CHAR(01)
END RECORD

DEFINE m_ind           INTEGER

#-----------------#
FUNCTION pol1323()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1323-12.00.07  "
   CALL func002_versao_prg(p_versao)
   
   IF pol1323_cria_tab() THEN
      CALL pol1323_menu()
   END IF
    
END FUNCTION

#----------------------#
FUNCTION pol1323_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_proces      VARCHAR(10),
           l_inform      VARCHAR(10),
           l_auditoria   VARCHAR(10),
           l_titulo      CHAR(100)
    
    LET l_titulo = "TROCA DE COMPONENTE DA ESTRUTURA "
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    
    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1323_informar")
    CALL _ADVPL_set_property(l_inform,"TOOLTIP","Informar componentes para troca")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1323_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1323_cancelar")
        
    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"TOOLTIP","Processa a troca do conponente")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1323_processar")

    LET l_auditoria = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_auditoria,"IMAGE","AUDITORIA") 
    CALL _ADVPL_set_property(l_auditoria,"TOOLTIP","Consulta trocas já efetuadas")
    CALL _ADVPL_set_property(l_auditoria,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(l_auditoria,"EVENT","pol1323_auditoria")
    #CALL _ADVPL_set_property(l_auditoria,"ENABLE",m_enable)

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1323_cria_campos(l_panel)
   CALL pol1323_cria_grade(l_panel)
   
   CALL pol1323_ativa_desativa(FALSE)

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1323_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_cod_item        VARCHAR(10),
           l_den_item        VARCHAR(10)

    LET m_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_panel,"HEIGHT",60)
    CALL _ADVPL_set_property(m_panel,"EDITABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,20)     
    CALL _ADVPL_set_property(l_label,"TEXT","Componente:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(m_item,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_item,"POSITION",85,20)     
    CALL _ADVPL_set_property(m_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_item,"LENGTH",15) 
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_cabec,"cod_item")
    CALL _ADVPL_set_property(m_item,"VALID","pol1323_checa_item")

    LET m_lupa_it = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_it,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_it,"POSITION",215,20)     
    CALL _ADVPL_set_property(m_lupa_it,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_it,"CLICK_EVENT","pol1323_zoom_comp_atu")

    LET l_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_item,"POSITION",245,20)     
    CALL _ADVPL_set_property(l_den_item,"LENGTH",40) 
    CALL _ADVPL_set_property(l_den_item,"VARIABLE",mr_cabec,"den_item")
    CALL _ADVPL_set_property(l_den_item,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",610,20)     
    CALL _ADVPL_set_property(l_label,"TEXT","Substituto:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_novo = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(m_novo,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_novo,"POSITION",670,20)     
    CALL _ADVPL_set_property(m_novo,"PICTURE","@!")
    CALL _ADVPL_set_property(m_novo,"LENGTH",15) 
    CALL _ADVPL_set_property(m_novo,"VARIABLE",mr_cabec,"cod_novo")
    CALL _ADVPL_set_property(m_novo,"VALID","pol1323_checa_novo")

    LET m_lupa_it = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_it,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_it,"POSITION",800,20)     
    CALL _ADVPL_set_property(m_lupa_it,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_it,"CLICK_EVENT","pol1323_zoom_comp_subs")

    LET l_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_item,"POSITION",825,20)     
    CALL _ADVPL_set_property(l_den_item,"LENGTH",40) 
    CALL _ADVPL_set_property(l_den_item,"VARIABLE",mr_cabec,"den_novo")
    CALL _ADVPL_set_property(l_den_item,"CAN_GOT_FOCUS",FALSE)

END FUNCTION

#---------------------------------------#
FUNCTION pol1323_cria_grade(l_container)#
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
    #CALL _ADVPL_set_property(m_browse,"AFTER_ROW_EVENT","alb001_limpa_status")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Componente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_compon")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Substituto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_subst")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_subst")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dt Substituição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_subst")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Usuario")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","usuario")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Trocas efetuadas")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_troca")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_audit,1)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)


END FUNCTION


#----------------------------#
FUNCTION pol1323_checa_item()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   INITIALIZE mr_cabec.den_item TO NULL
   
   IF mr_cabec.cod_item IS NULL THEN
      RETURN TRUE
   END IF
      
   SELECT den_item
     INTO mr_cabec.den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_cabec.cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1323_checa_novo()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   INITIALIZE mr_cabec.den_novo TO NULL
   
   IF mr_cabec.cod_novo IS NULL THEN
      RETURN TRUE
   END IF
      
   SELECT den_item
     INTO mr_cabec.den_novo
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_cabec.cod_novo
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1323_zoom_comp_atu()#
#-------------------------------#

    DEFINE l_cod_item       LIKE item.cod_item,
           l_den_item       LIKE item.den_item,
           l_filtro         CHAR(300)
    
    IF  m_zoom_it IS NULL THEN
        LET m_zoom_it = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_it,"ZOOM","zoom_item")
    END IF
    
    LET l_filtro = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_it,"ACTIVATE")
    
    LET l_cod_item = _ADVPL_get_property(m_zoom_it,"RETURN_BY_TABLE_COLUMN","item","cod_item")
    LET l_den_item = _ADVPL_get_property(m_zoom_it,"RETURN_BY_TABLE_COLUMN","item","den_item")

    IF  l_cod_item IS NOT NULL THEN
        LET mr_cabec.cod_item = l_cod_item
        LET mr_cabec.den_item = l_den_item
    END IF

    LET p_status = pol1323_checa_item()
    
    CALL _ADVPL_set_property(m_item,"GET_FOCUS")

END FUNCTION

#--------------------------------#
FUNCTION pol1323_zoom_comp_subs()#
#--------------------------------#

    DEFINE l_cod_item       LIKE item.cod_item,
           l_den_item       LIKE item.den_item,
           l_filtro         CHAR(300)
    
    IF  m_zoom_it IS NULL THEN
        LET m_zoom_it = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_it,"ZOOM","zoom_item")
    END IF

    LET l_filtro = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_it,"ACTIVATE")
    
    LET l_cod_item = _ADVPL_get_property(m_zoom_it,"RETURN_BY_TABLE_COLUMN","item","cod_item")
    LET l_den_item = _ADVPL_get_property(m_zoom_it,"RETURN_BY_TABLE_COLUMN","item","den_item")

    IF  l_cod_item IS NOT NULL THEN
        LET mr_cabec.cod_novo = l_cod_item
        LET mr_cabec.den_novo = l_den_item
    END IF
    
    LET p_status = pol1323_checa_novo()
    
    CALL _ADVPL_set_property(m_novo,"GET_FOCUS")

END FUNCTION

#----------------------------------------#
FUNCTION pol1323_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
    
   CALL _ADVPL_set_property(m_panel,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#--------------------------#
FUNCTION pol1323_informar()#
#--------------------------#
   
   DEFINE l_data    DATE
   
   LET m_ies_info = FALSE
      
   CALL pol1323_ativa_desativa(TRUE)
   CALL pol1323_limpa_campos()
   
   CALL _ADVPL_set_property(m_item,"GET_FOCUS")
   
   RETURN TRUE 
    
END FUNCTION

#-----------------------------#
FUNCTION pol1323_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
    
END FUNCTION

#---------------------------#
FUNCTION pol1323_confirmar()#
#---------------------------#
   
   IF mr_cabec.cod_item IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o componente")
      CALL _ADVPL_set_property(m_item,"GET_FOCUS")
      RETURN FALSE      
   END IF

   IF mr_cabec.cod_novo IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o substituto")
      CALL _ADVPL_set_property(m_novo,"GET_FOCUS")
      RETURN FALSE      
   END IF
      
   LET m_ies_info = TRUE
   CALL pol1323_ativa_desativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1323_cancelar()#
#--------------------------#

    CALL pol1323_limpa_campos()
    CALL pol1323_ativa_desativa(FALSE)
    LET m_ies_info = FALSE
    RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1323_processar()#
#---------------------------#

   IF NOT m_ies_info THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe os parâmetros previamente.")
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a alteração da estrutura?") THEN
      CALL pol1323_cancelar()
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   LET p_status = LOG_progresspopup_start("Carregando...","pol1323_le_estrut","PROCESS") 
   
   IF NOT p_status THEN
      LET m_msg = 'Operação cancelada.'
   ELSE
      LET m_msg = 'Operação efetuada com sucesso.'
   END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)

   LET m_ies_info = FALSE

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1323_le_estrut()#
#---------------------------#

   LET m_cod_item = mr_cabec.cod_item
   LET m_cod_novo = mr_cabec.cod_novo

   SELECT COUNT(cod_item_pai)
     INTO m_count
     FROM estrut_grade
    WHERE cod_empresa = p_cod_empresa
      AND cod_item_compon = m_cod_item
      AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
       OR  (dat_validade_ini IS NULL AND dat_validade_fim >= getdate())
       OR  (dat_validade_fim IS NULL AND dat_validade_ini <= getdate())
       OR  (dat_validade_ini <= getdate() AND dat_validade_fim IS NULL)
       OR  (getdate() BETWEEN dat_validade_ini AND dat_validade_fim))

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estrut_grade.COUNT')
      RETURN FALSE
   END IF
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
        
   CALL log085_transacao("BEGIN")
     
   IF NOT pol1323_alt_est_grade() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
     
   CALL log085_transacao("COMMIT")
      
   RETURN TRUE   

END FUNCTION
     
#-------------------------------#
FUNCTION pol1323_alt_est_grade()#
#-------------------------------#

   DEFINE lr_est_grade     RECORD LIKE estrut_grade.*,
          lr_estrutura     RECORD LIKE estrutura.*
          
   DEFINE l_dat_atu        DATE,
          l_progres        SMALLINT
   
   LET l_dat_atu = TODAY
               
   DECLARE cq_grade CURSOR FOR
    SELECT * FROM estrut_grade
     WHERE cod_empresa = p_cod_empresa
       AND cod_item_compon = m_cod_item
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
        OR  (dat_validade_ini IS NULL AND dat_validade_fim >= getdate())
        OR  (dat_validade_fim IS NULL AND dat_validade_ini <= getdate())
        OR  (dat_validade_ini <= getdate() AND dat_validade_fim IS NULL)
        OR  (getdate() BETWEEN dat_validade_ini AND dat_validade_fim))
   
   FOREACH cq_grade INTO lr_est_grade.*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_grade')
         RETURN FALSE
      END IF
      
      UPDATE estrut_grade
         SET cod_item_compon = m_cod_novo,
             dat_validade_ini = l_dat_atu
     WHERE cod_empresa = p_cod_empresa
       AND cod_item_pai = lr_est_grade.cod_item_pai
       AND cod_item_compon = lr_est_grade.cod_item_compon
       AND num_sequencia = lr_est_grade.num_sequencia
       AND cod_posicao = lr_est_grade.cod_posicao

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE', 'estrut_grade')
         RETURN FALSE
      END IF
      
      DECLARE cq_estrutura CURSOR FOR
       SELECT * FROM estrutura
        WHERE cod_empresa = p_cod_empresa
          AND cod_item_pai = lr_est_grade.cod_item_pai
          AND cod_item_compon = lr_est_grade.cod_item_compon
          AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
           OR  (dat_validade_ini IS NULL AND dat_validade_fim >= getdate())
           OR  (dat_validade_fim IS NULL AND dat_validade_ini <= getdate())
           OR  (dat_validade_ini <= getdate() AND dat_validade_fim IS NULL)
           OR  (getdate() BETWEEN dat_validade_ini AND dat_validade_fim))
      
      FOREACH cq_estrutura INTO lr_estrutura.*
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH', 'cq_estrutura')
            RETURN FALSE
         END IF

         UPDATE estrutura
            SET cod_item_compon = m_cod_novo,
                dat_validade_ini = l_dat_atu
          WHERE cod_empresa = p_cod_empresa
            AND cod_item_pai = lr_estrutura.cod_item_pai
            AND cod_item_compon = lr_estrutura.cod_item_compon
            AND parametros = lr_estrutura.parametros
            
         IF STATUS <> 0 THEN
            CALL log003_err_sql('UPDATE', 'estrutura')
            RETURN FALSE
         END IF

      END FOREACH
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
   END FOREACH

   IF NOT pol1323_ins_comp() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1323_ins_comp()#
#--------------------------#
   
   DEFINE l_dat_subs  CHAR(19)
   
   LET l_dat_subs = EXTEND(CURRENT, YEAR TO SECOND)
   
   INSERT INTO compon_subs_885
    VALUES(p_cod_empresa,
           mr_cabec.cod_item,
           mr_cabec.cod_novo,
           getdate(),
           p_user, m_count)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','compon_subs_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1323_cria_tab()#
#--------------------------#
   
   DEFINE l_tab     CHAR(30)
   
   LET l_tab = 'compon_subs_885'
   
   IF NOT log0150_verifica_se_tabela_existe(l_tab) THEN
      CREATE TABLE compon_subs_885 (
       cod_empresa       CHAR(02),
       cod_compon        CHAR(15),
       cod_subst         CHAR(15),
       dat_subst         DATETIME YEAR TO SECOND,
       usuario           CHAR(08),
       qtd_troca         INTEGER
      );

      IF STATUS <> 0 THEN
         CALL log003_err_sql('CREATE','troca_compon_885')
         RETURN FALSE
      END IF
      
      create index ix_compon_subs_885 ON 
       compon_subs_885(cod_empresa);

      IF STATUS <> 0 THEN
         CALL log003_err_sql('CREATE','troca_compon_885.INDEX')
         RETURN FALSE
      END IF
       
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1323_auditoria()#
#---------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1323_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","compon_subs_885","compon")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","compon_subs_885","cod_compon","Componente",1 {CHAR},15,0,"zoom_item")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","compon_subs_885","cod_subst","Substitu",1 {CHAR},15,0,"zoom_item")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","compon_subs_885","usuario","Usuário",1 {CHAR},15,0,"zoom_usuario")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1323_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1323_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " cod_compon "
    END IF
    
    LET m_ind = 1

    CALL _ADVPL_set_property(m_browse,"CLEAR")
    
    LET l_sql_stmt = 
      "SELECT * ",
      " FROM compon_subs_885 ",
      " WHERE ",l_where CLIPPED,
      " AND cod_empresa = '",p_cod_empresa,"' ",
      " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","compon_subs_885")
       RETURN FALSE
    END IF

    DECLARE cq_cons CURSOR FOR var_cons

    IF STATUS <> 0 THEN
       CALL log003_err_sql("DECLARE CURSOR","cq_cons")
       RETURN FALSE
    END IF

    FOREACH cq_cons INTO 
       ma_audit[m_ind].cod_empresa,
       ma_audit[m_ind].cod_compon,
       ma_audit[m_ind].cod_subst,
       ma_audit[m_ind].dat_subst,
       ma_audit[m_ind].usuario,
       ma_audit[m_ind].qtd_troca

       IF STATUS <> 0 THEN
          CALL log003_err_sql("FOREACH","cq_cons")
          RETURN FALSE
       END IF
       
       LET ma_audit[m_ind].den_compon = 
           pol1323_le_descricao(ma_audit[m_ind].cod_compon)
       LET ma_audit[m_ind].den_subst = 
           pol1323_le_descricao(ma_audit[m_ind].cod_subst)
       
       LET m_ind = m_ind + 1
       
    END FOREACH

   IF m_ind > 1 THEN
      LET m_ind = m_ind - 1
      CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_ind)
   ELSE
      LET m_msg = "Não há dados para os parâmetros informados."
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
    
   RETURN TRUE
    
END FUNCTION

#-----------------------------------#
FUNCTION pol1323_le_descricao(l_cod)#
#-----------------------------------#

   DEFINE l_cod       CHAR(15),
          l_descricao CHAR(18)
   
   SELECT den_item_reduz 
     INTO l_descricao
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_cod

   IF STATUS <> 0 THEN
      LET l_descricao = ''
   END IF
   
   RETURN l_descricao

END FUNCTION
