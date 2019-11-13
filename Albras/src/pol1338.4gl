#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1338                                                 #
# OBJETIVO: REABERTURA DA ORDEM DE PRODUÇÃO                         #
# AUTOR...: IVO                                                     #
# DATA....: 28/03/18                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
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

DEFINE m_ordem           VARCHAR(10),
       m_zoom_op         VARCHAR(10),
       m_lupa_op         VARCHAR(10),
       m_motivo          VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_id_registro     INTEGER,
       m_id_registroa    INTEGER,
       m_ind             INTEGER,
       m_mot_retrab      CHAR(15),
       m_mot_refugo      CHAR(15)
       
DEFINE mr_campos         RECORD
       num_ordem         INTEGER,
       cod_item          CHAR(15),
       den_item          CHAR(18),
       qtd_planej        DECIMAL(10,3),
       qtd_saldo         DECIMAL(10,3),
       ies_situa         CHAR(01),
       desc_situa        CHAR(10),
       motivo            CHAR(150)
END RECORD

DEFINE ma_audit           ARRAY[5000] OF RECORD
       num_op             INTEGER,
       usuario            CHAR(08),
       data               DATE,
       motivo             CHAR(150)
END RECORD

#-----------------#
FUNCTION pol1338()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1338-12.00.03  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1338_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1338_menu()#
#----------------------#

    DEFINE l_menubar,
           l_panel,
           l_inform,
           l_find,
           l_proces  CHAR(10),
           l_titulo  CHAR(40)

    LET l_titulo = 'REABERTURA DA ORDEM DE PRODUÇÃO'
    CALL pol1338_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1338_informar")
    CALL _ADVPL_set_property(l_inform,"TOOLTIP","Informar OP para reabertura")
    CALL _ADVPL_set_property(l_inform,"TOOLTIP","Informar boletim para baixa")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1338_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1338_cancelar")
    
    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Prcessa a reabertura da OP")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1338_processar")
    CALL _ADVPL_set_property(l_proces,"CONFIRM_EVENT","pol1338_yes_processar")
    CALL _ADVPL_set_property(l_proces,"CANCEL_EVENT","pol1338_no_processar")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"TOOLTIP","Consultar auditoria de reabetura")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1338_le_audit")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1338_cria_campos(l_panel)
    CALL pol1338_cria_grade(l_panel)

    CALL pol1338_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#--------------------------#
FUNCTION pol1338_informar()#
#--------------------------#
   
   DEFINE l_data    DATE
   
   LET m_ies_cons = FALSE
      
   CALL pol1338_ativa_desativa(TRUE)
   CALL pol1338_limpa_campos()
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_audit,1)
   CALL _ADVPL_set_property(m_ordem,"GET_FOCUS")
      
   RETURN TRUE 
    
END FUNCTION

#---------------------------#
FUNCTION pol1338_confirmar()#
#---------------------------#
         
   IF NOT pol1338_checa_op() THEN
      RETURN FALSE
   END IF

   CALL pol1338_ativa_desativa(FALSE)
   
   LET m_ies_cons = TRUE
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1338_checa_op()#
#--------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL _ADVPL_set_property(m_ordem,"GET_FOCUS")   

   IF mr_campos.num_ordem IS NULL THEN
      LET m_msg = 'Informe o número da OP.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)   
      RETURN FALSE
   END IF
   
   SELECT cod_item, qtd_planej, ies_situa,
          (qtd_planej - qtd_boas - qtd_refug - qtd_sucata)
     INTO mr_campos.cod_item,
          mr_campos.qtd_planej,
          mr_campos.ies_situa,
          mr_campos.qtd_saldo
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = mr_campos.num_ordem
      
   IF STATUS = 100 THEN
      LET m_msg = 'OP inexistente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)      
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordens')
         RETURN FALSE
      END IF
   END IF
   
   CASE mr_campos.ies_situa 
      WHEN '5' LET mr_campos.desc_situa = 'Encerrada'
      WHEN '9' LET mr_campos.desc_situa = 'Cancelada'
      OTHERWISE
         LET m_msg = 'Informe uma OP encerrada/cancelada'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)      
         RETURN FALSE
   END CASE
   
   SELECT den_item_reduz
     INTO mr_campos.den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_campos.cod_item

   IF STATUS = 100 THEN
      LET mr_campos.den_item = 'Não cadastrado'
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item')
         RETURN FALSE
      END IF
   END IF
   

   LET m_msg = pol1338_checa_apontamentos()
   
   IF m_msg IS NOT NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)      
      RETURN FALSE
   END IF
         
   RETURN TRUE

END FUNCTION   

#------------------------------------#
FUNCTION pol1338_checa_apontamentos()#
#------------------------------------#

   DEFINE l_dat_fecha_ult_man   LIKE par_estoque.dat_fecha_ult_man,    
          l_dat_fecha_ult_sup   LIKE par_estoque.dat_fecha_ult_sup
          
   SELECT dat_fecha_ult_man,
          dat_fecha_ult_sup
     INTO l_dat_fecha_ult_man,
          l_dat_fecha_ult_sup
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO:(',STATUS, ') LENDO TABELA PAR_ESTOQUE'
      RETURN 
   END IF

   SELECT COUNT(ordem_producao)
     INTO m_count
     FROM man_apo_mestre
    WHERE empresa = p_cod_empresa
      AND ordem_producao = mr_campos.num_ordem 
      AND (data_producao <= l_dat_fecha_ult_man 
             OR data_producao <= l_dat_fecha_ult_sup)
      
   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO:(',STATUS, ') LENDO TABELA MAN_APO_MESTRE'
      RETURN 
   END IF

   IF m_count > 0 THEN
      LET m_msg = 'OP POSSUI APONTAMENTO COM DATA INFERIOR AO ULTIMO FECHAMENTO'
      RETURN 
   END IF

END FUNCTION
   
#--------------------------#
FUNCTION pol1338_cancelar()#
#--------------------------#

    CALL pol1338_limpa_campos()
    CALL pol1338_ativa_desativa(FALSE)
    LET m_ies_cons = FALSE
    RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1338_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
   INITIALIZE ma_audit TO NULL
    
END FUNCTION

#---------------------------#
FUNCTION pol1338_processar()#
#---------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Informe a OP previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)    
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_motivo,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_motivo,"GET_FOCUS")
   RETURN TRUE

END FUNCTION   

#-------------------------------#
FUNCTION pol1338_yes_processar()#
#-------------------------------#

   IF mr_campos.motivo IS NULL OR
        LENGTH(mr_campos.motivo) < 5 THEN
      LET m_msg = 'Escreva de forma clara o motivo da reabertura da OP.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)    
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_begin()
   
   LET p_status = LOG_progresspopup_start("Processando...","pol1338_reabir","PROCESS")   
   
   IF NOT p_status THEN
      CALL LOG_transaction_rollback()
   ELSE
      CALL LOG_transaction_commit()
      CALL log0030_mensagem('OP liberada com sucesso.','info')
   END IF
   
END FUNCTION

#------------------------#
FUNCTION pol1338_reabir()#
#------------------------#

   DEFINE l_progres     SMALLINT,
          l_data        DATE
   
   CALL LOG_progresspopup_set_total("PROCESS",3)
      
   UPDATE ordens
      SET ies_situa = '4'
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = mr_campos.num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'ordens')
      RETURN FALSE
   END IF

   LET l_progres = LOG_progresspopup_increment("PROCESS")

   UPDATE necessidades
      SET ies_situa = '4'
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = mr_campos.num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'necessidades')
      RETURN FALSE
   END IF

   LET l_progres = LOG_progresspopup_increment("PROCESS")
   LET l_data = TODAY
   
   INSERT INTO reabertura_op_304
    VALUES(p_cod_empresa,
           mr_campos.num_ordem,
           p_user,
           l_data,
           mr_campos.motivo)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT', 'reabertura_op_304')
      RETURN FALSE
   END IF

   CALL man0515_integra_mes('upsert',
        p_cod_empresa,
        mr_campos.num_ordem,
        TRUE,
        TRUE,
        NULL,
         "A")

   LET l_progres = LOG_progresspopup_increment("PROCESS")
   LET mr_campos.ies_situa = '4'
   LET mr_campos.desc_situa = 'Liberada'
   LET m_ies_cons = FALSE

   RETURN TRUE
      
END FUNCTION


#-------------------------------#
FUNCTION pol1338_no_processar()#
#-------------------------------#

   CALL _ADVPL_set_property(m_ordem,"EDITABLE",FALSE)
   RETURN TRUE

END FUNCTION   
   
#----------------------------------------#
FUNCTION pol1338_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   CALL _ADVPL_set_property(m_ordem,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_op,"EDITABLE",l_status)
   
END FUNCTION

#----------------------------------------#
FUNCTION pol1338_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_campo           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP") 
    CALL _ADVPL_set_property(l_panel,"HEIGHT",30)
    #CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)
    #CALL _ADVPL_set_property(l_panel,"WIDTH",400)
    #CALL _ADVPL_set_property(l_panel,"BOUNDS",10,10,600,160)
    CALL _ADVPL_set_property(l_panel,"FOREGROUND_COLOR",255,0,0)
    #CALL _ADVPL_set_property(l_panel,"FONT","Courier New",18,FALSE,FALSE)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",17)

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Ordem:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_ordem = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_ordem,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_ordem,"LENGTH",9,0)
    CALL _ADVPL_set_property(m_ordem,"PICTURE","@E #########")
    CALL _ADVPL_set_property(m_ordem,"VARIABLE",mr_campos,"num_ordem")

    LET m_lupa_op = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_op,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_lupa_op,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_op,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_op,"CLICK_EVENT","pol1338_zoom_op")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Item:")    

    LET l_campo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_campo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_campo,"LENGTH",15) 
    CALL _ADVPL_set_property(l_campo,"VARIABLE",mr_campos,"cod_item")

    LET l_campo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_campo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_campo,"LENGTH",18) 
    CALL _ADVPL_set_property(l_campo,"VARIABLE",mr_campos,"den_item")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Planejada:")    

    LET l_campo = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(l_campo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_campo,"LENGTH",9,0)
    CALL _ADVPL_set_property(l_campo,"PICTURE","@E #########")
    CALL _ADVPL_set_property(l_campo,"VARIABLE",mr_campos,"qtd_planej")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Saldo:")    

    LET l_campo = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(l_campo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_campo,"LENGTH",9,0)
    CALL _ADVPL_set_property(l_campo,"PICTURE","@E #########")
    CALL _ADVPL_set_property(l_campo,"VARIABLE",mr_campos,"qtd_saldo")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Status:")    

    LET l_campo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_campo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_campo,"LENGTH",2) 
    CALL _ADVPL_set_property(l_campo,"VARIABLE",mr_campos,"ies_situa")

    LET l_campo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_campo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_campo,"LENGTH",10) 
    CALL _ADVPL_set_property(l_campo,"VARIABLE",mr_campos,"desc_situa")
    
    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

END FUNCTION

#----------------------------#
FUNCTION pol1338_zoom_op()#
#----------------------------#
    
   DEFINE l_codigo      LIKE ordens.num_ordem,
          l_where       CHAR(300)

   IF  m_zoom_op IS NULL THEN
       LET m_zoom_op = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_op,"ZOOM","zoom_ordem_producao")
   END IF

    LET l_where = " ordens.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    LET l_where = l_where CLIPPED, " and ordens.ies_situa in ('5','6') "
    CALL LOG_zoom_set_where_clause(l_where CLIPPED)

   CALL _ADVPL_get_property(m_zoom_op,"ACTIVATE")

   LET l_codigo    = _ADVPL_get_property(m_zoom_op,"RETURN_BY_TABLE_COLUMN","ordens","num_ordem")

   IF l_codigo IS NOT NULL THEN
      LET mr_campos.num_ordem = l_codigo
      CALL pol1338_checa_op()
   END IF
    
END FUNCTION


#---------------------------------------#
FUNCTION pol1338_cria_grade(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel_center    VARCHAR(10)

    LET l_panel_center = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel_center,"ALIGN","CENTER")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_panel_center)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",221,231,237)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",30)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,5)   
    CALL _ADVPL_set_property(l_label,"TEXT","Motivo:")    

    LET m_motivo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_motivo,"POSITION",80,5)   
    CALL _ADVPL_set_property(m_motivo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_motivo,"LENGTH",150) 
    CALL _ADVPL_set_property(m_motivo,"VARIABLE",mr_campos,"motivo")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_panel_center)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    #CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_op")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Usuário")
    #CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","usuario")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Data")
    #CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","data")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Motivo")
    #CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","motivo")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)


    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_audit,1)
    #CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#--------------------------#
FUNCTION pol1338_le_audit()#
#--------------------------#
   
   LET m_ind = 1
   INITIALIZE ma_audit TO NULL
   
   DECLARE cq_audit CURSOR FOR
    SELECT num_op, usuario, data, motivo
      FROM reabertura_op_304
     WHERE cod_empresa = p_cod_empresa
     ORDER BY usuario, data
       
   FOREACH cq_audit INTO 
      ma_audit[m_ind].num_op,
      ma_audit[m_ind].usuario,
      ma_audit[m_ind].data,
      ma_audit[m_ind].motivo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','reabertura_op_304:cq_audit')
         RETURN FALSE
      END IF          

      LET m_ind = m_ind + 1
      
      IF m_ind > 5000 THEN
         LET m_msg = 'Limite de linhas da grade\n ultrapassou seu limite.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
                     
   END FOREACH

   FREE cq_audit

   IF m_ind = 1 THEN
      LET m_msg = 'Não há auditoria a exibir.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)   
      RETURN FALSE   
   END IF

   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT",m_ind - 1)

   RETURN TRUE

END FUNCTION

