#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1320                                                 #
# OBJETIVO: ALTERAÇÃO DE DADOS DE CREDITO                           #
# AUTOR...: IVO                                                     #
# DATA....: 06/02/17                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_pedido          VARCHAR(10),
       m_duplicata       VARCHAR(10),
       m_medio           VARCHAR(10),
       m_motivo          VARCHAR(10),
       m_limpar          VARCHAR(10),
       m_lupa_ped        VARCHAR(10),
       m_zoom_ped        VARCHAR(10),
       m_browse          VARCHAR(10),
       m_hist            VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_ies_hist        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150)

DEFINE mr_cabec          RECORD
       num_pedido        INTEGER,
       cod_cliente       VARCHAR(15),
       nom_cliente       VARCHAR(40),
       qtd_dias_atr_dupl INTEGER,
       qtd_dias_atr_med  INTEGER,
       motivo            CHAR(90)
END RECORD

DEFINE ma_itens          ARRAY[300] OF RECORD
       cod_empresa         char(02),   
       pedido              integer,    
       limpeza             char(20),   
       usuario             char(08),   
       dias_atr_duplicata  integer,    
       dias_atr_medio      integer,    
       motivo              char(90)   
END RECORD       
 
#-----------------#
FUNCTION pol1320()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1320-11.00.01  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1320_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1320_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_proces      VARCHAR(10)
     
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE","ALTERAÇÃO DE DADOS DE CREDITO")

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1320_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1320_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1320_cancelar")

    LET m_limpar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(m_limpar,"IMAGE","LIMPAR_ITEM") 
    CALL _ADVPL_set_property(m_limpar,"EVENT","pol1320_limpar")
    CALL _ADVPL_set_property(m_limpar,"TYPE","CONFIRM")    
    CALL _ADVPL_set_property(m_limpar,"CONFIRM_EVENT","pol1320_limpar_conf")
    CALL _ADVPL_set_property(m_limpar,"CANCEL_EVENT","pol1320_limpar_canc")

    LET m_hist = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(m_hist,"IMAGE","CONSUL_HIST") 
    CALL _ADVPL_set_property(m_hist,"EVENT","pol1320_historico")
    CALL _ADVPL_set_property(m_hist,"TYPE","NO_CONFIRM")    

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1320_cria_campos(l_panel)
    CALL pol1320_cria_grade(l_panel)

    CALL pol1320_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1320_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_cod_clinete     VARCHAR(10),
           l_nom_cliente     VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",170)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Pedido:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_pedido = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_pedido,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_pedido,"POSITION",140,10)     
    CALL _ADVPL_set_property(m_pedido,"LENGTH",6,0)
    CALL _ADVPL_set_property(m_pedido,"PICTURE","@E ######")
    CALL _ADVPL_set_property(m_pedido,"VARIABLE",mr_cabec,"num_pedido")
    CALL _ADVPL_set_property(m_pedido,"VALID","pol1320_valida_pedido")

    LET m_lupa_ped = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_ped,"POSITION",195,10)     
    CALL _ADVPL_set_property(m_lupa_ped,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_ped,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_ped,"CLICK_EVENT","pol1320_zoom_pedido")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,35)     
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    

    LET l_cod_clinete = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_cod_clinete,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_cod_clinete,"POSITION",140,35)     
    CALL _ADVPL_set_property(l_cod_clinete,"LENGTH",15) 
    CALL _ADVPL_set_property(l_cod_clinete,"VARIABLE",mr_cabec,"cod_cliente")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,60)     
    CALL _ADVPL_set_property(l_label,"TEXT","Razão social:")    

    LET l_nom_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_nom_cliente,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_nom_cliente,"POSITION",140,60)     
    CALL _ADVPL_set_property(l_nom_cliente,"LENGTH",40) 
    CALL _ADVPL_set_property(l_nom_cliente,"VARIABLE",mr_cabec,"nom_cliente")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,85)     
    CALL _ADVPL_set_property(l_label,"TEXT","Dias atraso duplicata:")    

    LET m_duplicata = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_duplicata,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_duplicata,"POSITION",140,85)     
    CALL _ADVPL_set_property(m_duplicata,"LENGTH",6,0)
    CALL _ADVPL_set_property(m_duplicata,"PICTURE","@E ######")
    CALL _ADVPL_set_property(m_duplicata,"VARIABLE",mr_cabec,"qtd_dias_atr_dupl")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,110)     
    CALL _ADVPL_set_property(l_label,"TEXT","Dias atraso médido:")    

    LET m_medio = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_medio,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_medio,"POSITION",140,110)     
    CALL _ADVPL_set_property(m_medio,"VARIABLE",mr_cabec,"qtd_dias_atr_med")
    CALL _ADVPL_set_property(m_medio,"LENGTH",6,0)
    CALL _ADVPL_set_property(m_medio,"PICTURE","@E ######")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,135)     
    CALL _ADVPL_set_property(l_label,"TEXT","Motivo da limpeza:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_motivo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_motivo,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_motivo,"POSITION",140,135)     
    CALL _ADVPL_set_property(m_motivo,"LENGTH",90,0)
    CALL _ADVPL_set_property(m_motivo,"PICTURE","@!")
    CALL _ADVPL_set_property(m_motivo,"VARIABLE",mr_cabec,"motivo")
    CALL _ADVPL_set_property(m_motivo,"VALID","pol1320_checa_motivo")

END FUNCTION


#---------------------------------------#
FUNCTION pol1320_cria_grade(l_container)#
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
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pedido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Limpeza")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","limpeza")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Usuário")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","usuario")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dias atr dupl")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dias_atr_duplicata")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dias atr médio")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dias_atr_medio")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Motivo")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","motivo")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CLEAR")

END FUNCTION

#habilita/desabilita os campos de tela

#----------------------------------------#
FUNCTION pol1320_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
    
   CALL _ADVPL_set_property(m_pedido,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_ped,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_motivo,"EDITABLE",FALSE)

END FUNCTION

#--------------------------#
FUNCTION pol1320_informar()#
#--------------------------#

   CALL pol1320_ativa_desativa(TRUE)
   CALL pol1320_limpa_campos()
   
   LET m_ies_info = FALSE
   LET m_ies_hist = FALSE
   CALL _ADVPL_set_property(m_pedido,"GET_FOCUS")
   
   RETURN TRUE 
    
END FUNCTION

#-----------------------------#
FUNCTION pol1320_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_itens TO NULL

END FUNCTION

#---------------------------#
FUNCTION pol1320_confirmar()#
#---------------------------#
   
   LET m_ies_info = TRUE
   LET m_ies_hist = TRUE
   CALL pol1320_ativa_desativa(FALSE)
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1320_cancelar()#
#--------------------------#

   CALL pol1320_limpa_campos()
   CALL pol1320_ativa_desativa(FALSE)
   LET m_ies_info = FALSE
   LET m_ies_hist = FALSE
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1320_zoom_pedido()#
#-----------------------------#

   DEFINE l_pedido       LIKE pedidos.num_pedido,
          l_cliente      LIKE pedidos.cod_cliente

   IF  m_zoom_ped IS NULL THEN
       LET m_zoom_ped = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_ped,"ZOOM","zoom_pedidos")
   END IF

   CALL _ADVPL_get_property(m_zoom_ped,"ACTIVATE")

   LET l_pedido  = _ADVPL_get_property(m_zoom_ped,"RETURN_BY_TABLE_COLUMN","pedidos","num_pedido")
   LET l_cliente = _ADVPL_get_property(m_zoom_ped,"RETURN_BY_TABLE_COLUMN","pedidos","cod_cliente")

   IF l_pedido IS NOT NULL THEN
      LET mr_cabec.num_pedido = l_pedido
      LET mr_cabec.cod_cliente = l_cliente
      LET p_status =  pol1320_le_cliente()
      LET p_status =  pol1320_le_cli_credito()
   END IF
    
END FUNCTION

#-------------------------------#
FUNCTION pol1320_valida_pedido()#
#-------------------------------#

   IF mr_cabec.num_pedido IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o pedido")
      CALL _ADVPL_set_property(m_pedido,"GET_FOCUS")
      RETURN FALSE      
   END IF   

   IF NOT pol1320_le_pedido() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1320_le_cliente() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   CALL pol1320_le_cli_credito()
   
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1320_le_pedido()#
#---------------------------#

   SELECT cod_cliente
     INTO mr_cabec.cod_cliente
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = mr_cabec.num_pedido
   
   IF STATUS = 0 THEN
   ELSE
      LET mr_cabec.cod_cliente = ''
      IF STATUS = 100 THEN
         LET m_msg = 'Pedido inexistente!'
      ELSE
         CALL log003_err_sql('SELECT','pedidos')
      END IF
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1320_le_cliente()#
#----------------------------#
   
   SELECT nom_cliente
     INTO mr_cabec.nom_cliente
     FROM clientes
    WHERE cod_cliente = mr_cabec.cod_cliente
   
   IF STATUS = 0 THEN
   ELSE
      LET mr_cabec.nom_cliente = ''
      IF STATUS = 100 THEN
         LET m_msg = 'Cliente inexistente!'
      ELSE
         CALL log003_err_sql('SELECT','clientes')
      END IF
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1320_le_cli_credito()#
#--------------------------------#

   SELECT qtd_dias_atr_dupl,
          qtd_dias_atr_med
     INTO mr_cabec.qtd_dias_atr_dupl,
          mr_cabec.qtd_dias_atr_med
     FROM cli_credito
    WHERE cod_cliente = mr_cabec.cod_cliente
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cli_credito')
      LET mr_cabec.qtd_dias_atr_dupl = NULL
      LET mr_cabec.qtd_dias_atr_med = NULL
   END IF

END FUNCTION

#------------------------#
FUNCTION pol1320_limpar()#
#------------------------#

   IF NOT m_ies_info  THEN
      LET m_msg = "Informe o pedido previamente"
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE      
   END IF

   IF mr_cabec.qtd_dias_atr_dupl IS NULL OR 
          mr_cabec.qtd_dias_atr_dupl = 0 THEN
      IF mr_cabec.qtd_dias_atr_med IS NULL OR 
            mr_cabec.qtd_dias_atr_med = 0 THEN
         LET m_msg = "Os campos de crédito já estão limpos."
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE 
      END IF     
   END IF
   
   CALL _ADVPL_set_property(m_motivo,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_motivo,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1320_limpar_conf()#
#-----------------------------#   
      
   CALL log085_transacao("BEGIN")

   IF NOT pol1320_gravar() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")

   LET mr_cabec.qtd_dias_atr_dupl = 0
   LET mr_cabec.qtd_dias_atr_med = 0
                        
   CALL pol1320_ativa_desativa(FALSE)
   
   LET m_ies_info = FALSE
   LET m_msg = 'Limpeza de dados efetuda com sucesso.'
   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1320_limpar_canc()#
#-----------------------------#   

   LET mr_cabec.motivo = ''
   CALL _ADVPL_set_property(m_motivo,"EDITABLE",FALSE)
   
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1320_checa_motivo()#
#------------------------------#

   IF mr_cabec.motivo IS NULL  THEN
      LET m_msg = 'Informe o motivo da limprza.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_motivo,"GET_FOCUS")
      RETURN FALSE      
   END IF
   
   RETURN TRUE

END FUNCTION   

#------------------------#
FUNCTION pol1320_gravar()#
#------------------------#
   
   DEFINE l_dat_atu char(20)
   DEFINE l_atd_dupl    LIKE cli_credito.qtd_dias_atr_dupl,
          l_atd_med     LIKE cli_credito.qtd_dias_atr_med
          
   LET l_atd_dupl = 0
   LET l_atd_med = 0
   LET l_dat_atu = CURRENT

   UPDATE cli_credito
      SET qtd_dias_atr_dupl = l_atd_dupl,
          qtd_dias_atr_med = l_atd_med
    WHERE cod_cliente = mr_cabec.cod_cliente
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','cli_credito')
      RETURN FALSE
   END IF
   
   INSERT INTO audit_cre_912
    VALUES(p_cod_empresa,
           mr_cabec.num_pedido,
           l_dat_atu,
           p_user,
           mr_cabec.qtd_dias_atr_dupl,
           mr_cabec.qtd_dias_atr_med,
           mr_cabec.motivo)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','audit_cre_912')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#   
FUNCTION pol1320_historico()#
#---------------------------#

   IF NOT m_ies_hist THEN
      LET m_msg = "Informe o pedido previamente"
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE      
   END IF
   
   CALL pol1320_le_historico()

   RETURN TRUE
   
END FUNCTION
   
#------------------------------#   
FUNCTION pol1320_le_historico()#
#------------------------------#
   
   DEFINE l_ind     integer
   
   LET l_ind = 1
   
   DECLARE cq_hist CURSOR FOR
    SELECT *
      FROM audit_cre_912
     WHERE cod_empresa = p_cod_empresa
       AND pedido = mr_cabec.num_pedido
   
   FOREACH cq_hist INTO ma_itens[l_ind].*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','audit_cre_912')
         EXIT FOREACH    
      END IF
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 300 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapasou')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   IF l_ind = 0 THEN
      LET m_msg = 'Não há histórico de limpeza para esse pedido.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
   
   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", l_ind)

END FUNCTION
