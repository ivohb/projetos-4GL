#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1389                                                 #
# OBJETIVO: PLANO DE CORTE DE CHAPA                                 #
# AUTOR...: IVO                                                     #
# DATA....: 28/01/2020                                              #
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
       m_statusbar       VARCHAR(10),
       m_pasta           VARCHAR(10),
       m_arquivo         VARCHAR(10),
       m_pnl_info        VARCHAR(10),
       m_browse          VARCHAR(10),
       m_pedido          VARCHAR(10),
       m_entrega         VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150)

DEFINE m_num_docum       LIKE ordens.num_docum,
       m_num_programa    CHAR(30),
       m_num_ordem       INTEGER,
       m_cod_item        CHAR(15)
       

DEFINE mr_cabec          RECORD
       caminho           VARCHAR(50),
       arquivo           VARCHAR(30),
       num_pedido        DECIMAL(6,0),
       prz_entrega       DATE,
       mensagem          VARCHAR(80)
END RECORD

DEFINE m_caminho         VARCHAR(120),
       m_ies_ambiente    CHAR(01),
       m_carregando      SMALLINT,
       m_posi_arq        INTEGER,
       m_qtd_arq         INTEGER,
       m_nom_arquivo     CHAR(40),
       m_arq_arigem      CHAR(150),
       m_progres         SMALLINT,
       m_qtd_item        INTEGER,
       m_ies_lista       SMALLINT,
       m_ind             INTEGER

DEFINE ma_files ARRAY[50] OF CHAR(100)

DEFINE ma_ordens ARRAY[500] OF RECORD
       num_programa         CHAR(30),
       num_ordem            INTEGER,   
       cod_item             CHAR(15),
       qtd_arranjada        DECIMAL(10,3),
       pes_unit             DECIMAL(14,7),
       tmp_de_corte         CHAR(10),
       pct_sucata           DECIMAL(6,2),
       qtd_op_por_plano     INTEGER, 
       peso_liquido         DECIMAL(14,7),
       metro_linear         DECIMAL(14,4),
       mensagem             CHAR(80),
       id_registro          INTEGER,
       tip_registro         CHAR(01)
       
END RECORD

#-----------------#
FUNCTION pol1389()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1389-12.00.00  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1389_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1389_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_proces      VARCHAR(10),
           l_carga       VARCHAR(10),
           l_titulo      CHAR(100),
           l_consist     VARCHAR(10)
    
    LET l_titulo = "PLANO DE CORTE DE CHAPA - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_carga = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_carga,"IMAGE","IMPORTAR_ARQUIVO")     
    CALL _ADVPL_set_property(l_carga,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_carga,"TOOLTIP","Infrmar parâmetro para o processamento")
    CALL _ADVPL_set_property(l_carga,"EVENT","pol1389_carga_informar")
    CALL _ADVPL_set_property(l_carga,"CONFIRM_EVENT","pol1389_carga_info_conf")
    CALL _ADVPL_set_property(l_carga,"CANCEL_EVENT","pol1389_carga_info_canc")

    LET l_consist = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_consist,"IMAGE","CONSISTIR_EX")     
    CALL _ADVPL_set_property(l_consist,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_consist,"TOOLTIP","Processa a consistência/validação do arquivo")
    CALL _ADVPL_set_property(l_consist,"EVENT","pol1389_consistir")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Processa a carga do arquivo")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1389_processar")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1389_cria_campos(l_panel)
   CALL pol1389_cria_grade(l_panel)

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1389_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)

    LET m_pnl_info = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_container)
    CALL _ADVPL_set_property(m_pnl_info,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pnl_info,"HEIGHT",60)
    CALL _ADVPL_set_property(m_pnl_info,"ENABLE",FALSE)
    CALL _ADVPL_set_property(m_pnl_info,"BACKGROUND_COLOR",231,237,237)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Caminho:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_pasta = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_pasta,"POSITION",70,10)     
    CALL _ADVPL_set_property(m_pasta,"LENGTH",50)
    CALL _ADVPL_set_property(m_pasta,"ENABLE",FALSE)
    CALL _ADVPL_set_property(m_pasta,"VARIABLE",mr_cabec,"caminho")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",500,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_arquivo = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_arquivo,"POSITION",550,10)     
    CALL _ADVPL_set_property(m_arquivo,"LENGTH",30)
    CALL _ADVPL_set_property(m_arquivo,"VARIABLE",mr_cabec,"arquivo")
    CALL _ADVPL_set_property(m_arquivo,"VALID","pol1389_valid_arquivo")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",820,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Pedido:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_pedido = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_pedido,"POSITION",870,10)     
    CALL _ADVPL_set_property(m_pedido,"LENGTH",6,0)
    CALL _ADVPL_set_property(m_pedido,"VARIABLE",mr_cabec,"num_pedido")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",970,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Prz entrega:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_entrega = _ADVPL_create_component(NULL,"LDATEFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_entrega,"POSITION",1040,10)     
    CALL _ADVPL_set_property(m_entrega,"VARIABLE",mr_cabec,"prz_entrega")

END FUNCTION

#---------------------------------------#
FUNCTION pol1389_cria_grade(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Plano")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_programa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Num OP")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ordem")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd prod")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_arranjada")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Peso unit")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pes_unit")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tmp corte")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","tmp_de_corte")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","% Sucata")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pct_sucata")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","OP/Plano")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_op_por_plano")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Peso liq")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","peso_liquido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Metro linear")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","metro_linear")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_ordens,1)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",TRUE)
    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)

END FUNCTION

#--------------------------------#
FUNCTION pol1389_carga_informar()#
#--------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_ies_info = FALSE
   
   IF NOT pol1389_le_caminho() THEN
      RETURN FALSE
   END IF
   
   CALL pol1389_limpa_campos()

   IF NOT pol1389_dirExist() THEN
      LET m_msg = 'Caminho ',m_caminho CLIPPED, ' não existe.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET mr_cabec.caminho = m_caminho      
     
   CALL pol1389_ativa_desativa(TRUE)   
   CALL _ADVPL_set_property(m_arquivo,"ENABLE", TRUE)
   CALL _ADVPL_set_property(m_pedido,"ENABLE", FALSE)
   CALL _ADVPL_set_property(m_entrega,"ENABLE", FALSE)
   CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1389_limpa_campos()#
#------------------------------#
   
   LET m_carregando = TRUE
   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_ordens TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   
END FUNCTION

#----------------------------------------#
FUNCTION pol1389_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status      SMALLINT
   
   CALL _ADVPL_set_property(m_pnl_info,"ENABLE",l_status)

END FUNCTION

#----------------------------#
FUNCTION pol1389_le_caminho()#
#----------------------------#

   SELECT nom_caminho, ies_ambiente
     INTO m_caminho, m_ies_ambiente
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "PCC"

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema PCC não cadastrado na LOG1100.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("SELECT","path_logix_v2")
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1389_dirExist()#
#--------------------------#
 
  LET m_caminho = m_caminho CLIPPED
 
  IF LOG_dir_exist(m_caminho,0) THEN
  ELSE
     
     CALL LOG_consoleMessage("FALHA. Motivo: "||log0030_mensagem_get_texto())
     
     IF LOG_dir_exist(m_caminho,1) THEN
     ELSE
        CALL LOG_consoleMessage("FALHA. Motivo: "||log0030_mensagem_get_texto())
        LET m_msg = "FALHA. Motivo: ", log0030_mensagem_get_texto()
        CALL log0030_mensagem(m_msg,'info')
        RETURN FALSE
     END IF
     
  END IF
  
  RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1389_valid_arquivo()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_cabec.arquivo IS NULL THEN
      LET m_msg = 'Informe um arquivo para carga.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS") 
      RETURN FALSE
   END IF

   IF NOT pol1389_fileExist() THEN
      RETURN FALSE
   END IF

   LET m_carregando = TRUE

   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1389_load_arq","PROCESS")  
   
   LET m_carregando = FALSE

   IF NOT p_status THEN
      CALL pol1389_carga_info_canc() RETURNING p_status
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_arquivo,"ENABLE", FALSE)
   CALL _ADVPL_set_property(m_pedido,"ENABLE", TRUE)
   CALL _ADVPL_set_property(m_entrega,"ENABLE", TRUE)
   CALL _ADVPL_set_property(m_pedido,"GET_FOCUS") 
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
 FUNCTION pol1389_fileExist()#
#----------------------------#
  
   LET m_arq_arigem = m_caminho CLIPPED, mr_cabec.arquivo
   LET m_arq_arigem = m_arq_arigem CLIPPED
 
   IF LOG_file_exist(m_arq_arigem,0) THEN
   ELSE
      IF NOT LOG_file_exist(m_arq_arigem,1) THEN
         LET m_msg = ' Arquivo não existe ',m_arq_arigem  
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
   END IF
    
   RETURN TRUE
  
END FUNCTION

#--------------------------#
FUNCTION pol1389_load_arq()#
#--------------------------#
   
   IF NOT pol1389_cria_temp() THEN
      RETURN FALSE
   END IF
      
   CALL LOG_transaction_begin()
   
   LOAD FROM m_arq_arigem 
      INSERT INTO plano_corte_tmp(
         num_programa,    
         num_ordem,       
         cod_item,        
         qtd_arranjada,   
         pes_unit,        
         tmp_de_corte,    
         pct_sucata,      
         qtd_op_por_plano,
         peso_liquido,    
         metro_linear)    
         
   IF STATUS <> 0 THEN 
      CALL LOG_transaction_rollback()
      LET m_msg = 'Erro: ', STATUS USING '<<<<<', ' na carga do ', m_arq_arigem
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   SELECT COUNT(*) INTO m_count
     FROM plano_corte_tmp
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','plano_corte_tmp:COUNT')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'O arquivo selecionado está vazio.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   IF NOT pol1389_exibe_dados() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1389_cria_temp()#
#---------------------------#
   
   DROP TABLE plano_corte_tmp
   
   CREATE  TABLE plano_corte_tmp (
       num_programa         CHAR(30),
       num_ordem            INTEGER,   
       cod_item             CHAR(15),
       qtd_arranjada        DECIMAL(10,3),
       pes_unit             DECIMAL(14,7),
       tmp_de_corte         CHAR(10),
       pct_sucata           DECIMAL(6,2),
       qtd_op_por_plano     INTEGER, 
       peso_liquido         DECIMAL(14,7),
       metro_linear         DECIMAL(14,4)
   )
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','plano_corte_tmp')
      RETURN FALSE
   END IF
   
   CREATE INDEX ix1_plano_corte_tmp ON
      plano_corte_tmp(num_programa, num_ordem);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','ix1_plano_corte_tmp')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1389_exibe_dados()#
#-----------------------------#
   
   DEFINE l_progres   SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   LET m_ind = 1
   
   DECLARE cq_exib CURSOR FOR
    SELECT 
         num_programa,    
         num_ordem,       
         cod_item,        
         qtd_arranjada,   
         pes_unit,        
         tmp_de_corte,    
         pct_sucata,      
         qtd_op_por_plano,
         peso_liquido,    
         metro_linear 
    FROM plano_corte_tmp   

   FOREACH cq_exib INTO
      ma_ordens[m_ind].num_programa,    
      ma_ordens[m_ind].num_ordem,       
      ma_ordens[m_ind].cod_item,        
      ma_ordens[m_ind].qtd_arranjada,   
      ma_ordens[m_ind].pes_unit,        
      ma_ordens[m_ind].tmp_de_corte,    
      ma_ordens[m_ind].pct_sucata,      
      ma_ordens[m_ind].qtd_op_por_plano,
      ma_ordens[m_ind].peso_liquido,    
      ma_ordens[m_ind].metro_linear    
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','plano_corte_tmp:cq_exib')
         RETURN FALSE
      END IF
      
      LET m_progres = LOG_progresspopup_increment("PROCESS")

      IF NOT pol1389_chec_apont() THEN
         RETURN FALSE
      END IF
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 500 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET m_qtd_item = m_ind - 1
   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_item)
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1389_chec_apont()#
#----------------------------#
   
   DECLARE cq_chec_apont CURSOR FOR
   SELECT  tip_registro,
           id_registro
     FROM man_apo_nest_405 
    WHERE cod_empresa = p_cod_empresa
      AND num_programa = ma_ordens[m_ind].num_programa 
      AND num_ordem = ma_ordens[m_ind].num_ordem

   FOREACH cq_chec_apont 
      INTO ma_ordens[m_ind].tip_registro, ma_ordens[m_ind].id_registro
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','man_apo_nest_405:cq_chec_apont')
         RETURN FALSE
      END IF
      
      IF ma_ordens[m_ind].tip_registro = 'A' THEN
         LET ma_ordens[m_ind].mensagem = NULL
      ELSE
         LET ma_ordens[m_ind].mensagem = 'Ordem não apontada'
      END IF
      
      EXIT FOREACH
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1389_carga_info_canc()#
#---------------------------------#

   CALL pol1389_limpa_campos()
   CALL pol1389_ativa_desativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1389_carga_info_conf()#
#---------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_cabec.num_pedido IS NULL THEN
      LET m_msg = 'Informe o número do pedido.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_pedido,"GET_FOCUS") 
      RETURN FALSE
   END IF
   
   LET m_num_docum = mr_cabec.num_pedido
   
   IF mr_cabec.prz_entrega IS NULL THEN
      LET m_msg = 'Informe o prazo de entrega.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_entrega,"GET_FOCUS") 
      RETURN FALSE
   END IF
   
   SELECT COUNT(num_ordem)
     INTO m_count
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_docum = m_num_docum
      AND dat_entrega = mr_cabec.prz_entrega
      AND ies_situa = '4'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens:COUNT')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Não há ordens liberadas para o pedido/entrega informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET m_ies_info = TRUE
               
   RETURN TRUE   
    
END FUNCTION

#---------------------------#
FUNCTION pol1389_consistir()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT m_ies_info THEN
      LET m_msg = 'Informe previamente os parâmetros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1389_valid_dados","PROCESS")  

   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol1389_valid_dados()#
#-----------------------------#
   
   DEFINE l_progres    SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",m_qtd_item)
   
   DECLARE  cq_consit CURSOR FOR   
   SELECT DISTINCT num_programa
     FROM plano_corte_tmp
   
   FOREACH cq_consit INTO m_num_programa
   
      LET m_progres = LOG_progresspopup_increment("PROCESS")
      
      
   END FOREACH

   RETURN TRUE

END FUNCTION
   
   