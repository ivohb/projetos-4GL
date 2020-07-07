#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1339                                                 #
# OBJETIVO: TROCA DE COMPONENTES DA ESTRUTURA                       #
# AUTOR...: IVO                                                     #
# DATA....: 04/04/18                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18)
           
END GLOBALS

DEFINE m_cod_empresa_plano   LIKE empresa.cod_empresa

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_cod_operac      VARCHAR(10),
       m_den_operac      VARCHAR(10),
       m_zoom_operac     VARCHAR(10),
       m_lupa_operac     VARCHAR(10),
       m_cod_item        VARCHAR(10),
       m_den_item        VARCHAR(10),
       m_zoom_item       VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_num_op          VARCHAR(10),
       m_qtd_movto       VARCHAR(10),
       m_tip_movto       VARCHAR(10),
       m_tip_oper        VARCHAR(10),
       m_cod_motivo      VARCHAR(10),
       m_cod_turno       VARCHAR(10),
       m_dat_ini         VARCHAR(10),
       m_dat_fim         VARCHAR(10),
       m_hor_ini         VARCHAR(10),
       m_hor_fim         VARCHAR(10),
       m_cent_trab       VARCHAR(10),
       m_cent_cust       VARCHAR(10),
       m_arranjo         VARCHAR(10),
       m_equipto         VARCHAR(10),
       m_browse          VARCHAR(10)

DEFINE m_item_sai        VARCHAR(10),
       m_zoom_sai        VARCHAR(10),
       m_lupa_sai        VARCHAR(10),
       m_item_ent        VARCHAR(10),
       m_zoom_ent        VARCHAR(10),
       m_lupa_ent        VARCHAR(10)
       
DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_ind             INTEGER
       
DEFINE mr_campos         RECORD
       cod_item_sai      CHAR(15),
       den_item_sai      CHAR(18),
       cod_item_ent      CHAR(15),
       den_item_ent      CHAR(18)
END RECORD

#-----------------#
FUNCTION pol1339()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1339-12.00.02  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1339_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1339_menu()#
#----------------------#

    DEFINE l_menubar,
           l_panel,
           l_inform,
           l_find,
           l_proces  CHAR(10),
           l_titulo  CHAR(40)

    LET l_titulo = 'TROCA DE COMPONENTES DA ESTRUTURA'
    CALL pol1339_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1339_informar")
    CALL _ADVPL_set_property(l_inform,"TOOLTIP","Informar itens para troca")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1339_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1339_cancelar")
    
    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Prcessa a troca dos itens")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1339_processar")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1339_cria_campos(l_panel)

    CALL pol1339_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#--------------------------#
FUNCTION pol1339_informar()#
#--------------------------#
   
   DEFINE l_data    DATE
   
   LET m_ies_cons = FALSE
      
   CALL pol1339_ativa_desativa(TRUE)
   CALL pol1339_limpa_campos()
   CALL _ADVPL_set_property(m_item_sai,"GET_FOCUS")
      
   RETURN TRUE 
    
END FUNCTION

#---------------------------#
FUNCTION pol1339_confirmar()#
#---------------------------#
         
   IF NOT pol1339_checa_itens() THEN
      RETURN FALSE
   END IF

   IF NOT pol1339_checa_estrutura() THEN
      CALL _ADVPL_set_property(m_item_sai,"GET_FOCUS")
      RETURN FALSE
   END IF

   CALL pol1339_ativa_desativa(FALSE)
   
   LET m_ies_cons = TRUE
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1339_checa_itens()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_campos.cod_item_sai IS NULL THEN
      LET m_msg = 'Preenchimento obrigatório.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)   
      CALL _ADVPL_set_property(m_item_sai,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_campos.cod_item_ent IS NULL THEN
      LET m_msg = 'Preenchimento obrigatório.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)   
      CALL _ADVPL_set_property(m_item_ent,"GET_FOCUS")
      RETURN FALSE
   END IF
            
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1339_le_item(l_cod)#
#------------------------------#
   
   DEFINE l_cod        CHAR(15),
          l_desc       CHAR(18)
   
   SELECT den_item_reduz
     INTO l_desc
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      LET l_desc = NULL
   END IF
   
   RETURN l_desc

END FUNCTION

#---------------------------------#
FUNCTION pol1339_checa_estrutura()#
#---------------------------------#

   SELECT COUNT(cod_item_pai)
     INTO m_count
     FROM estrut_grade
    WHERE cod_empresa = p_cod_empresa
      AND cod_item_compon = mr_campos.cod_item_sai

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estrut_grade')
      RETURN FALSE
   END IF

   IF m_count = 0 THEN
      LET m_msg = 'Componente de saida não encontrado\n na estrutura dos produtos'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
   
#--------------------------#
FUNCTION pol1339_cancelar()#
#--------------------------#

    CALL pol1339_limpa_campos()
    CALL pol1339_ativa_desativa(FALSE)
    LET m_ies_cons = FALSE
    RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1339_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
    
END FUNCTION

#---------------------------#
FUNCTION pol1339_processar()#
#---------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Informe a OP previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)    
      RETURN FALSE
   END IF

   LET m_msg = 'Deseja mesmo efetuar a troca do componente ?'
   
   IF NOT LOG_question(m_msg) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_begin()
   
   CALL LOG_progresspopup_start("Processando...","pol1339_trocar","PROCESS")   
   
   IF NOT p_status THEN
      CALL LOG_transaction_rollback()
   ELSE
      CALL LOG_transaction_commit()
      CALL log0030_mensagem('Operação efetuada com sucesso.','info')
   END IF
   
END FUNCTION

#------------------------#
FUNCTION pol1339_trocar()#
#------------------------#

   DEFINE l_progres     SMALLINT,
          l_data        DATE,
          l_filtro      CHAR(05)
   
   LET p_status = FALSE

   CALL LOG_progresspopup_set_total("PROCESS",5)

   UPDATE estrut_grade 
      SET cod_item_compon = mr_campos.cod_item_ent
    WHERE cod_empresa = p_cod_empresa
      AND cod_item_compon = mr_campos.cod_item_sai

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'estrut_grade')
      RETURN 
   END IF

   LET l_progres = LOG_progresspopup_increment("PROCESS")

   UPDATE estrutura
      SET cod_item_compon = mr_campos.cod_item_ent
    WHERE cod_empresa = p_cod_empresa
      AND cod_item_compon = mr_campos.cod_item_sai

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'estrutura')
      RETURN 
   END IF

   LET l_progres = LOG_progresspopup_increment("PROCESS")

   UPDATE man_it_altern_grd 
      SET item_componente = mr_campos.cod_item_ent
    WHERE empresa = p_cod_empresa
      AND item_componente = mr_campos.cod_item_sai

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'man_it_altern_grd')
      RETURN 
   END IF

   LET l_progres = LOG_progresspopup_increment("PROCESS")

   LET l_filtro = "%F",p_cod_empresa,"%"
   
   UPDATE orcamento_nivel_1 
      SET cod_item_pai = mr_campos.cod_item_ent
    WHERE num_orc LIKE l_filtro
      AND cod_item_pai = mr_campos.cod_item_sai
      AND atual='S'
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT', 'orcamento_nivel_1')
      RETURN 
   END IF

   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   UPDATE orcamento_nivel_2 
      SET cod_item_compon = mr_campos.cod_item_ent
    WHERE num_orc LIKE l_filtro
      AND cod_item_compon = mr_campos.cod_item_sai
      AND atual='S'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT', 'orcamento_nivel_2')
      RETURN 
   END IF

   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   LET p_status = TRUE
   LET m_ies_cons = FALSE
   
END FUNCTION
   
#----------------------------------------#
FUNCTION pol1339_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   CALL _ADVPL_set_property(m_item_sai,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_item_ent,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_sai,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_ent,"EDITABLE",l_status)
   
END FUNCTION

#----------------------------------------#
FUNCTION pol1339_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_campo           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP") 
    CALL _ADVPL_set_property(l_panel,"HEIGHT",80)
    CALL _ADVPL_set_property(l_panel,"FOREGROUND_COLOR",255,0,0)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",4)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Componente a sair:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_item_sai = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_item_sai,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_item_sai,"LENGTH",15,0)
    CALL _ADVPL_set_property(m_item_sai,"PICTURE","@!")
    CALL _ADVPL_set_property(m_item_sai,"VARIABLE",mr_campos,"cod_item_sai")
    CALL _ADVPL_set_property(m_item_sai,"VALID","pol1339_ck_itsai")

    LET m_lupa_sai = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_sai,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_lupa_sai,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_sai,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_sai,"CLICK_EVENT","pol1339_zoom_itsai")

    LET l_campo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_campo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_campo,"LENGTH",18) 
    CALL _ADVPL_set_property(l_campo,"VARIABLE",mr_campos,"den_item_sai")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Componente a entrar:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_item_ent = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_item_ent,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_item_ent,"LENGTH",15,0)
    CALL _ADVPL_set_property(m_item_ent,"PICTURE","@!")
    CALL _ADVPL_set_property(m_item_ent,"VARIABLE",mr_campos,"cod_item_ent")
    CALL _ADVPL_set_property(m_item_ent,"VALID","pol1339_ck_itent")

    LET m_lupa_ent = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_ent,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_lupa_ent,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_ent,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_ent,"CLICK_EVENT","pol1339_zoom_itent")

    LET l_campo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_campo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_campo,"LENGTH",18) 
    CALL _ADVPL_set_property(l_campo,"VARIABLE",mr_campos,"den_item_ent")


END FUNCTION

#--------------------------#
FUNCTION pol1339_ck_itsai()#
#--------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_campos.cod_item_sai IS NOT NULL THEN
      LET mr_campos.den_item_sai = pol1339_le_item(mr_campos.cod_item_sai)
      IF mr_campos.den_item_sai IS NULL THEN
         LET m_msg = 'Item inexistente!'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1339_ck_itent()#
#--------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_campos.cod_item_ent IS NOT NULL THEN
      LET mr_campos.den_item_ent = pol1339_le_item(mr_campos.cod_item_ent)
      IF mr_campos.den_item_ent IS NULL THEN
         LET m_msg = 'Item inexistente!'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1339_zoom_itsai()#
#----------------------------#
    
   DEFINE l_codigo      LIKE item.cod_item,
          l_where       CHAR(300)

   IF  m_zoom_sai IS NULL THEN
       LET m_zoom_sai = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_sai,"ZOOM","zoom_item")
   END IF

    LET l_where = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where CLIPPED)

   CALL _ADVPL_get_property(m_zoom_sai,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_zoom_sai,"RETURN_BY_TABLE_COLUMN","item","cod_item")

   IF l_codigo IS NOT NULL THEN
      LET mr_campos.cod_item_sai = l_codigo
      LET mr_campos.den_item_sai = pol1339_le_item(l_codigo)
   END IF
    
END FUNCTION

#----------------------------#
FUNCTION pol1339_zoom_itent()#
#----------------------------#
    
   DEFINE l_codigo      LIKE item.cod_item,
          l_where       CHAR(300)

   IF  m_zoom_ent IS NULL THEN
       LET m_zoom_ent = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_ent,"ZOOM","zoom_item")
   END IF

    LET l_where = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where CLIPPED)

   CALL _ADVPL_get_property(m_zoom_ent,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_zoom_ent,"RETURN_BY_TABLE_COLUMN","item","cod_item")

   IF l_codigo IS NOT NULL THEN
      LET mr_campos.cod_item_ent = l_codigo
      LET mr_campos.den_item_ent = pol1339_le_item(l_codigo)
   END IF
    
END FUNCTION


