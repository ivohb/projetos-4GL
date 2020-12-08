#-------------------------------------------------------------------#
# PROGRAMA: pol1343                                                 #
# OBJETIVO: GERA��O DE ORDENS DE PRODU��O POR DEMANDA               #
# CLIENTE.: ETHOS IND                                               #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003),
           p_nom_arquivo   CHAR(100),
           p_caminho       CHAR(080)
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_pan_cabec       VARCHAR(10),
       m_pan_item        VARCHAR(10),
       m_brz_item        VARCHAR(10),
       m_arq_denam       VARCHAR(10),
       m_dat_de          VARCHAR(10),
       m_dat_ate         VARCHAR(10),
       m_cod_cliente     VARCHAR(10),
       m_zoom_cliente    VARCHAR(10),
       m_lupa_cli        VARCHAR(10),
       m_estoque         VARCHAR(10)

DEFINE m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ind             INTEGER,
       m_lin_atu         INTEGER,
       m_nom_cliente     VARCHAR(36),
       m_den_reduz       VARCHAR(18),
       m_ies_deman       SMALLINT,
       m_caminho         VARCHAR(120),
       m_ies_ambiente    CHAR(01),
       m_pos_ini         INTEGER,
       m_pos_fim         INTEGER,
       m_cliente         VARCHAR(60),
       m_qtd_deman       INTEGER,
       m_car_deman       SMALLINT,
       m_posi_arq        INTEGER,
       m_qtd_arq         INTEGER,
       m_nom_arquivo     CHAR(40),
       m_arq_origem      CHAR(100),
       m_linha           VARCHAR(120),
       m_qtd_erro        INTEGER,
       m_dat_atu         DATE,
       m_hor_atu         CHAR(08),
       m_ies_info        SMALLINT,
       m_query           VARCHAR(800)

DEFINE ma_files ARRAY[150] OF CHAR(100)

DEFINE mr_cabec          RECORD
       cod_empresa       CHAR(02),
       nom_arquivo       VARCHAR(80),
       cod_cliente       VARCHAR(15),
       dat_de            DATE,
       dat_ate           DATE,
       ies_estoque       CHAR(01)
END RECORD
                     
DEFINE ma_deman          ARRAY[12000] OF RECORD
       cod_cliente       CHAR(15),
       nom_reduzido      CHAR(15),
       num_pedido        VARCHAR(06),
       cod_item          CHAR(15),
       den_item_reduz    CHAR(18),
       demanda           DECIMAL(10,3),
       estoque           DECIMAL(10,3),
       pri_entrega       DATE,
       ult_entrega       DATE,
       mensagem          VARCHAR(120)
END RECORD

DEFINE mr_deman          RECORD
       cod_cliente       CHAR(15),
       num_pedido        VARCHAR(06),
       cod_item          CHAR(15),
       prz_entrega       DATE,
       demanda           DECIMAL(10,3),
       mensagem          VARCHAR(120)
END RECORD
                      
#-----------------#
FUNCTION pol1343()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1343-12.00.00  "
   
   IF pol1343_cria_temp() THEN
      CALL pol1343_menu()
   END IF
   
END FUNCTION

#---------------------------#
FUNCTION pol1343_cria_temp()#
#---------------------------#

   DROP TABLE w_pedido_temp
   
   CREATE TEMP TABLE w_pedido_temp (
       cod_cliente       CHAR(15),
       num_pedido        VARCHAR(06),
       cod_item          CHAR(15),
       prz_entrega       DATE,
       demanda           DECIMAL(10,3),
       mensagem          VARCHAR(120)
   )
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','w_pedido_temp')
      RETURN FALSE
   END IF
   
   CREATE INDEX ix_w_pedido_temp ON w_pedido_temp
    (cod_cliente, num_pedido)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','ix_w_pedido_temp')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#----------------------#
FUNCTION pol1343_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_import      VARCHAR(10),
           l_ordem       VARCHAR(10),
           l_titulo      CHAR(80)
    
    LET l_titulo = "GERA��O DE ORDENS DE PRODU��O POR DEMANDA - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"TOOLTIP","Par�metros p/ apura��o da demanda")
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1343_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1343_info_conf")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1343_info_canc")

    LET l_import = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_import,"IMAGE","IMPORTAR_ARQUIVO")     
    CALL _ADVPL_set_property(l_import,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_import,"TOOLTIP","Iportar demanda de arquivo CSV")
    CALL _ADVPL_set_property(l_import,"EVENT","pol1343_deman_info")
    CALL _ADVPL_set_property(l_import,"CONFIRM_EVENT","pol1343_deman_conf")
    CALL _ADVPL_set_property(l_import,"CANCEL_EVENT","pol1343_deman_canc")

    LET l_ordem = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_ordem,"IMAGE","ORDENS") 
    CALL _ADVPL_set_property(l_ordem,"TOOLTIP","Gerar ordens de produ��o")
    CALL _ADVPL_set_property(l_ordem,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(l_ordem,"EVENT","pol1343_gerar")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1343_cabec(l_panel)
    CALL pol1343_item(l_panel)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------#
FUNCTION pol1343_cabec(l_container)#
#----------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_cabec = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_cabec,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_cabec,"HEIGHT",40)
    CALL _ADVPL_set_property(m_pan_cabec,"ENABLE",FALSE)
    CALL _ADVPL_set_property(m_pan_cabec,"BACKGROUND_COLOR",217,227,253) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_cabec)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",70,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",2,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"cod_empresa")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",100,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_arq_denam = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_cabec)     
    CALL _ADVPL_set_property(m_arq_denam,"POSITION",160,10)     
    CALL _ADVPL_set_property(m_arq_denam,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(m_arq_denam,"ADD_ITEM","0","Select    ")
    CALL _ADVPL_set_property(m_arq_denam,"VARIABLE",mr_cabec,"nom_arquivo")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",635,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    

    LET m_cod_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_cabec)
    CALL _ADVPL_set_property(m_cod_cliente,"POSITION",675,10)     
    CALL _ADVPL_set_property(m_cod_cliente,"LENGTH",15)   
    CALL _ADVPL_set_property(m_cod_cliente,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(m_cod_cliente,"VARIABLE",mr_cabec,"cod_cliente")

    LET m_lupa_cli = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_cabec)
    CALL _ADVPL_set_property(m_lupa_cli,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cli,"POSITION",809,10)     
    CALL _ADVPL_set_property(m_lupa_cli,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cli,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_lupa_cli,"CLICK_EVENT","pol1343_zoom_cliente")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",836,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Per�odo de:")    

    LET m_dat_de = _ADVPL_create_component(NULL,"LDATEFIELD",m_pan_cabec)
    CALL _ADVPL_set_property(m_dat_de,"POSITION",895,10)     
    CALL _ADVPL_set_property(m_dat_de,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(m_dat_de,"VARIABLE",mr_cabec,"dat_de")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",1005,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","-")   

    LET m_dat_ate = _ADVPL_create_component(NULL,"LDATEFIELD",m_pan_cabec)
    CALL _ADVPL_set_property(m_dat_ate,"POSITION",1020,10)     
    CALL _ADVPL_set_property(m_dat_ate,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(m_dat_ate,"VARIABLE",mr_cabec,"dat_ate")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",1140,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Considerar estoq?")    

    LET m_estoque = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_cabec)
    CALL _ADVPL_set_property(m_estoque,"POSITION",1240,10)     
    CALL _ADVPL_set_property(m_estoque,"LENGTH",02)   
    CALL _ADVPL_set_property(m_estoque,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(m_estoque,"PICTURE","!")   
    CALL _ADVPL_set_property(m_estoque,"VARIABLE",mr_cabec,"ies_estoque")

END FUNCTION

#---------------------------------#
FUNCTION pol1343_item(l_container)#
#---------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_item = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_item,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(m_pan_item,"ENABLE",FALSE)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pan_item)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_item = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_item,"ALIGN","CENTER")
        
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_reduzido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item_reduz")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Demanda")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","demanda")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Estoque")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","estoque")
       
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pri entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pri_entrega")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ult entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ult_entrega")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_brz_item,"SET_ROWS",ma_deman,1)
    CALL _ADVPL_set_property(m_brz_item,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_item,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_item,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#----------------------------#
FUNCTION pol1343_deman_info()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_ies_deman = FALSE
   
   IF NOT pol1343_le_caminho() THEN
      RETURN FALSE
   END IF
   
   CALL pol1343_limpa_deman()
   LET m_car_deman = FALSE

   IF NOT pol1343_dirExist() THEN
      RETURN FALSE
   END IF
      
   IF NOT pol1343_deman_lista() THEN
      RETURN FALSE
   END IF
   
   LET mr_cabec.cod_empresa = p_cod_empresa
   CALL _ADVPL_set_property(m_pan_cabec,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_arq_denam,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_arq_denam,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1343_le_caminho()#
#----------------------------#

   SELECT nom_caminho, ies_ambiente
     INTO m_caminho, m_ies_ambiente
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "PCP"

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema PCP n�o cadastrado na LOG1100.'
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
FUNCTION pol1343_dirExist()#
#--------------------------#

  DEFINE l_dir  CHAR(250),
         l_msg  CHAR(250)
 
  LET l_dir = m_caminho CLIPPED
 
  IF LOG_dir_exist(l_dir,0) THEN
  ELSE
     IF LOG_dir_exist(l_dir,1) THEN
     ELSE
        CALL LOG_consoleMessage("FALHA. Motivo: "||log0030_mensagem_get_texto())
        LET l_msg = "FALHA. Motivo: ", log0030_mensagem_get_texto()
        CALL log0030_mensagem(l_msg,'info')
        RETURN FALSE
     END IF
     
  END IF
  
  RETURN TRUE
   
END FUNCTION

#----------------------------#
 FUNCTION pol1343_fileExist()#
#----------------------------#
  
  DEFINE l_file  CHAR(250)
 
  LET l_file = m_caminho CLIPPED, 'arquivo_01.txt'
 
  IF LOG_file_exist(l_file,0) THEN
     LET m_msg = l_file CLIPPED, " Arquivo existe no servidor"
  ELSE
     LET m_msg = l_file CLIPPED, " Arquivo N�O existe no servidor"
  END IF
 
  CALL log0030_mensagem(m_msg,'info')

  IF LOG_file_exist(l_file,1) THEN
     LET m_msg = l_file CLIPPED, " Arquivo existe no client"
  ELSE
     LET m_msg = l_file CLIPPED, " Arquivo N�O existe no client"
  END IF
 
  CALL log0030_mensagem(m_msg,'info')
  
  RETURN FALSE
  
END FUNCTION

#-----------------------------#
FUNCTION pol1343_limpa_deman()#
#-----------------------------#
   
   LET m_car_deman = TRUE
   INITIALIZE mr_cabec.*, ma_deman TO NULL
   CALL _ADVPL_set_property(m_brz_item,"CLEAR")
   
END FUNCTION

#-----------------------------#
FUNCTION pol1343_deman_lista()#
#-----------------------------#     

   DEFINE l_ind     INTEGER,
          t_ind     CHAR(03)

   CALL _ADVPL_set_property(m_arq_denam,"CLEAR") 
   CALL _ADVPL_set_property(m_arq_denam,"ADD_ITEM","0","Select    ") 
   
   LET m_posi_arq = LENGTH(m_caminho) + 1
   LET m_qtd_arq = LOG_file_getListCount(m_caminho,"*.csv",FALSE,FALSE,FALSE)
   
   IF m_qtd_arq = 0 THEN
      LET m_msg = 'Nenhum arquivo foi encontrado no caminho ', m_caminho
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF m_qtd_arq > 150 THEN
         LET m_msg = 'Arquivos previstos na pasta: 50 - ',
                     'Arquivos encontrados: ', m_qtd_arq USING '<<<<<<'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   END IF
   
   INITIALIZE ma_files TO NULL
   
   FOR l_ind = 1 TO m_qtd_arq
       LET t_ind = l_ind
       LET ma_files[l_ind] = LOG_file_getFromList(l_ind)
       CALL _ADVPL_set_property(m_arq_denam,"ADD_ITEM",t_ind,ma_files[l_ind])   
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1343_deman_canc()#
#----------------------------#

   CALL pol1343_limpa_deman()
   CALL _ADVPL_set_property(m_pan_cabec,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_arq_denam,"ENABLE",FALSE)
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1343_deman_conf()#
#----------------------------#

   DEFINE l_status        SMALLINT
   
   IF NOT pol1343_deman_valid_arq() THEN
      RETURN FALSE
   END IF
   
   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1343_carrega_demanda","PROCESS")  
   
   IF NOT p_status THEN
      CALL pol1343_deman_canc() RETURNING l_status
      RETURN FALSE
   END IF

   LET m_car_deman = TRUE

   LET p_status = LOG_progresspopup_start(
       "Lendo demandas...","pol1343_exibe_demanda","PROCESS")  

   LET m_car_deman = FALSE
   
   IF NOT p_status THEN
      CALL pol1343_deman_canc() RETURNING l_status
      RETURN FALSE
   END IF
      
   LET m_ies_deman = TRUE

   IF m_qtd_erro > 0 THEN
      LET m_msg = 'Foram encontrados ',m_qtd_erro USING '<<<<', ' registos com erro'
   ELSE
      LET m_msg = 'Opera��o efetuada com sucesso'
   END IF

   CALL _ADVPL_set_property(m_pan_cabec,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_arq_denam,"ENABLE",FALSE)
   
   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE   
    
END FUNCTION

#---------------------------------#
FUNCTION pol1343_deman_valid_arq()#
#---------------------------------#
           
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_cabec.nom_arquivo = "0" THEN
      LET m_msg = 'Selecione um arquivo para carga.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_arq_denam,"GET_FOCUS")
      RETURN FALSE
   END IF

   LET m_count = mr_cabec.nom_arquivo
   LET m_arq_origem = ma_files[m_count] CLIPPED
   
   LET m_nom_arquivo = m_arq_origem[m_posi_arq, LENGTH(m_arq_origem)]

   CALL LOG_consoleMessage("Arquivo: "||m_arq_origem)
         
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1343_carrega_demanda()#
#---------------------------------#
   
   DEFINE l_lista, l_moeda INTEGER,
          l_empresa        CHAR(02)
   
   IF NOT pol1343_deman_cria_temp() THEN
      RETURN FALSE
   END IF
      
   CALL LOG_transaction_begin()
   
   LOAD FROM m_arq_origem INSERT INTO w_demanda
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('SELECT','w_demanda:LOAD')
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   SELECT COUNT(*) INTO m_count
     FROM w_demanda
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','w_demanda:COUNT')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'O arquivo selecionado est� vazio.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   IF NOT pol1343_separa_culunas() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1343_deman_cria_temp()#
#---------------------------------#
   
   DROP TABLE w_demanda
   
   CREATE TEMP TABLE w_demanda (
      linha          CHAR(120)
   );
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','w_demanda')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1343_del_temp()#
#--------------------------#
   
   DEFINE l_count   INTEGER
   
   DELETE FROM w_pedido_temp

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','w_demanda')
      RETURN FALSE
   END IF
   
   SELECT COUNT(*) INTO l_count
     FROM w_pedido_temp

   IF l_count > 0 THEN
      LET m_msg = 'N�o foi possivel limpar a tabela w_pedido_temp'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#--------------------------------#
FUNCTION pol1343_separa_culunas()#
#--------------------------------#
   
   DEFINE l_progres     SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   IF NOT pol1343_del_temp() THEN
      RETURN FALSE
   END IF
   
   DECLARE cq_separa CURSOR FOR
   SELECT linha
     FROM w_demanda
   
   FOREACH cq_separa INTO m_linha
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','w_demanda:cq_separa')
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      IF m_linha[1,7] = 'Cliente' THEN
         CONTINUE FOREACH
      END IF

      LET m_ind = m_ind + 1             
      
      IF m_ind > 12000 THEN
         LET m_msg = 'Limite previsto de itens ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
      
      LET m_pos_ini = 1
      LET m_cliente = pol1343_divide_texto()      
      LET mr_deman.cod_cliente = pol1343_pega_codigo()
      LET mr_deman.num_pedido = pol1343_divide_texto()   
      LET mr_deman.cod_item = pol1343_divide_texto()   
      LET mr_deman.prz_entrega = pol1343_divide_texto()   
      LET mr_deman.demanda = pol1343_divide_texto()   

      IF NOT pol1343_consist_pedido() THEN
         RETURN FALSE
      END IF

      LET mr_deman.mensagem = m_msg
      
      INSERT INTO w_pedido_temp VALUES(mr_deman.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','w_pedido_temp')
         RETURN FALSE
      END IF
            
   END FOREACH

   RETURN TRUE

END FUNCTION      

#------------------------------#
FUNCTION pol1343_divide_texto()#
#------------------------------#
   
   DEFINE l_ind        INTEGER,
          l_conteudo   CHAR(120)
                   
   FOR l_ind = m_pos_ini TO LENGTH(m_linha)
       IF m_linha[l_ind] = ';' THEN
          LET m_pos_fim = l_ind - 1
          EXIT FOR
       END IF
   END FOR
   
   IF m_pos_fim < m_pos_ini THEN
      LET m_pos_fim = l_ind - 1
   END IF
      
   LET l_conteudo = m_linha[m_pos_ini, m_pos_fim]
   LET m_pos_ini = m_pos_fim + 2
   
   RETURN l_conteudo

END FUNCTION

#-----------------------------#
FUNCTION pol1343_pega_codigo()#
#-----------------------------#
   
   DEFINE l_ind        INTEGER,
          l_codigo     CHAR(15),
          l_pos_ini    INTEGER,
          l_pos_fim    INTEGER
                   
   FOR l_ind = 1 TO LENGTH(m_cliente)
       IF m_cliente[l_ind] = '(' THEN
          LET l_pos_ini = l_ind + 1
          EXIT FOR
       END IF
   END FOR

   FOR l_ind = l_pos_ini TO LENGTH(m_cliente)
       IF m_cliente[l_ind] = ')' THEN
          LET l_pos_fim = l_ind - 1
          EXIT FOR
       END IF
   END FOR
   
   IF l_pos_fim < l_pos_ini THEN
      LET l_pos_fim = l_pos_ini
   END IF
      
   LET l_codigo = m_linha[l_pos_ini, l_pos_fim]
   
   RETURN l_codigo

END FUNCTION

#--------------------------------#
FUNCTION pol1343_consist_pedido()#
#--------------------------------#
   
   DEFINE l_ies_situa    CHAR(01),
          l_count        INTEGER,
          l_data         DATE
   
   LET m_msg = NULL
   LET l_data = mr_deman.prz_entrega
   
   SELECT ies_sit_pedido 
     INTO l_ies_situa
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_deman.cod_cliente
      AND num_pedido = mr_deman.num_pedido
   
   IF STATUS = 100 THEN
      LET m_msg = 'Pedido n�o existe'
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','pedidos')
         RETURN FALSE
      END IF
   END IF
   
   IF l_ies_situa = 'N' THEN
   ELSE
      IF l_ies_situa = 'E' THEN
         LET m_msg = 'Pedido em an�lise'
         RETURN TRUE
      ELSE
         IF l_ies_situa = 'B' THEN
            LET m_msg = 'Pedido bloqueado'
            RETURN TRUE
         END IF
      END IF
   END IF

   SELECT num_sequencia
     FROM ped_itens
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = mr_deman.num_pedido
      AND cod_item = mr_deman.cod_item
      AND prz_entrega = l_data
   
   IF STATUS = 0 THEN
   ELSE
      IF STATUS = 100 THEN
         LET m_msg = 'Programa��o de entrega n�o existe'
      ELSE   
         CALL log003_err_sql('SELECT','ped_itens')
         RETURN FALSE
      END IF
   END IF
         
   RETURN TRUE

END FUNCTION

#---------------------------------#   
FUNCTION pol1343_le_cliente(l_cod)#
#---------------------------------#

   DEFINE l_cod       CHAR(15)
   
   SELECT nom_cliente
     INTO m_nom_cliente
     FROM clientes
    WHERE cod_cliente = l_cod

   IF STATUS <> 0 THEN
      #CALL log003_err_sql('SELECT','clientes')
      LET m_nom_cliente = NULL
   END IF  
         
END FUNCTION    

#------------------------------#   
FUNCTION pol1343_le_item(l_cod)#
#------------------------------#

   DEFINE l_cod       CHAR(15)
   
   SELECT den_item_reduz
     INTO m_den_reduz
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_cod

   IF STATUS <> 0 THEN
      LET m_den_reduz = NULL
      IF STATUS = 100 THEN
         LET m_den_reduz = 'Item n�o existe'
      END IF
   END IF
            
END FUNCTION    

#-------------------------------#
FUNCTION pol1343_exibe_demanda()#
#-------------------------------#
   
   DEFINE l_progres     SMALLINT,
          l_mensagem    VARCHAR(12)

   DEFINE l_parametro      RECORD
          cod_empresa      CHAR(02),
          cod_item         CHAR(15),
          cod_local        CHAR(10)
   END RECORD
   
   INITIALIZE ma_deman TO NULL
   CALL _ADVPL_set_property(m_brz_item,"CLEAR")
   CALL _ADVPL_set_property(m_brz_item,"CLEAR_ALL_LINE_FONT_COLOR")
   LET m_ind = 1
   LET m_qtd_erro = 0
   
   SELECT COUNT(*) INTO m_count FROM w_pedido_temp
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DECLARE cq_deman CURSOR FOR
   SELECT cod_cliente,       
          num_pedido,  
          cod_item,          
          SUM(demanda)           
     FROM w_pedido_temp
    GROUP BY cod_cliente, num_pedido, cod_item
    ORDER BY cod_cliente, num_pedido, cod_item
   
   FOREACH cq_deman INTO 
      ma_deman[m_ind].cod_cliente,
      ma_deman[m_ind].num_pedido,
      ma_deman[m_ind].cod_item,
      ma_deman[m_ind].demanda
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','w_pedido_temp:cq_deman')
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")

      SELECT MIN(prz_entrega) 
        INTO ma_deman[m_ind].pri_entrega
        FROM w_pedido_temp 
       WHERE cod_cliente = ma_deman[m_ind].cod_cliente
         AND num_pedido = ma_deman[m_ind].num_pedido 
         AND cod_item = ma_deman[m_ind].cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','w_pedido_temp:MIN')
         RETURN FALSE
      END IF
         
      SELECT MAX(prz_entrega) 
        INTO ma_deman[m_ind].ult_entrega
        FROM w_pedido_temp 
       WHERE cod_cliente = ma_deman[m_ind].cod_cliente
         AND num_pedido = ma_deman[m_ind].num_pedido 
         AND cod_item = ma_deman[m_ind].cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','w_pedido_temp:MAX')
         RETURN FALSE
      END IF
      
      LET ma_deman[m_ind].mensagem = NULL
      
      DECLARE cq_msg CURSOR FOR
       SELECT mensagem 
         FROM w_pedido_temp 
        WHERE cod_cliente = ma_deman[m_ind].cod_cliente
          AND num_pedido = ma_deman[m_ind].num_pedido 
          AND cod_item = ma_deman[m_ind].cod_item
          AND mensagem IS NOT NULL
      
      FOREACH cq_msg INTO l_mensagem
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','w_pedido_temp:MAX')
            RETURN FALSE
         END IF
         
         LET ma_deman[m_ind].mensagem = l_mensagem
         EXIT FOREACH
         
      END FOREACH
      
      CALL pol1343_le_cliente(ma_deman[m_ind].cod_cliente)
      LET ma_deman[m_ind].nom_reduzido = m_nom_cliente
      CALL pol1343_le_item(ma_deman[m_ind].cod_item)
      LET ma_deman[m_ind].den_item_reduz = m_den_reduz  
      
      LET l_parametro.cod_empresa = p_cod_empresa
      LET l_parametro.cod_item = ma_deman[m_ind].cod_item

      SELECT cod_local_estoq
        INTO l_parametro.cod_local
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = l_parametro.cod_item    

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item:local')
         RETURN FALSE
      END IF
      
      CALL func002_le_estoque(l_parametro) RETURNING m_msg, ma_deman[m_ind].estoque
      
      IF m_msg IS NOT NULL THEN
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
      
      IF ma_deman[m_ind].mensagem IS NOT NULL THEN
         LET m_qtd_erro = m_qtd_erro + 1
         CALL _ADVPL_set_property(m_brz_item,"LINE_FONT_COLOR",m_ind,255,0,0)
      ELSE
         CALL _ADVPL_set_property(m_brz_item,"LINE_FONT_COLOR",m_ind,0,0,0)
      END IF      

      LET m_ind = m_ind + 1             
      
      IF m_ind >= 12000 THEN
         LET m_msg = 'Limite previsto de itens ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
      
   END FOREACH

   LET m_qtd_deman = m_ind - 1
   CALL _ADVPL_set_property(m_brz_item,"ITEM_COUNT", m_qtd_deman)

   RETURN TRUE

END FUNCTION      


#------------------------------#
FUNCTION pol1343_zoom_cliente()#
#------------------------------#

    DEFINE l_codigo         LIKE clientes.cod_cliente,
           l_descri         LIKE clientes.nom_cliente
    
    IF m_zoom_cliente IS NULL THEN
       LET m_zoom_cliente = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_cliente,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_cliente,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_descri = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")
    
    IF l_codigo IS NOT NULL THEN
       LET mr_cabec.cod_cliente = l_codigo
    END IF        
    
END FUNCTION


#--------------------------#
FUNCTION pol1343_informar()#
#--------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_ies_info = FALSE
   
   
   CALL pol1343_limpa_deman()
   LET m_car_deman = FALSE
   
   LET mr_cabec.cod_empresa = p_cod_empresa
   CALL _ADVPL_set_property(m_pan_cabec,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_dat_de,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_dat_ate,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_estoque,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_cod_cliente,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_lupa_cli,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_cod_cliente,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1343_info_canc()#
#---------------------------#

   CALL pol1343_limpa_deman()
   CALL _ADVPL_set_property(m_pan_cabec,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_dat_de,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_dat_ate,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_estoque,"ENABLE",FALSE)   
   CALL _ADVPL_set_property(m_cod_cliente,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_lupa_cli,"EDITABLE",FALSE)
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1343_info_conf()#
#----------------------------#

   DEFINE l_status        SMALLINT
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_cabec.dat_de IS NULL THEN
      LET m_msg = 'Informe o per�odo de:'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_dat_de,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_cabec.dat_ate IS NULL THEN
      LET m_msg = 'Informe o per�odo at�:'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_dat_ate,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   IF mr_cabec.dat_de > mr_cabec.dat_ate THEN
      LET m_msg = 'Per�odo inv�lido'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_dat_de,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_cabec.ies_estoque MATCHES '[SN]' THEN
   ELSE
      LET m_msg = 'Conte�do inv�lido!'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_estoque,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   IF NOT pol1343_del_temp() THEN
      RETURN FALSE
   END IF

   CALL pol1343_monta_select()
   
   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1343_le_demanda","PROCESS")  
   
   IF NOT p_status THEN
      CALL pol1343_info_canc() RETURNING l_status
      RETURN FALSE
   END IF

   LET m_car_deman = TRUE

   LET p_status = LOG_progresspopup_start(
       "Lendo demandas...","pol1343_exibe_demanda","PROCESS")  

   LET m_car_deman = FALSE
   
   IF NOT p_status THEN
      CALL pol1343_info_canc() RETURNING l_status
      RETURN FALSE
   END IF
   
   LET m_ies_info = TRUE

   IF m_qtd_erro > 0 THEN
      LET m_msg = 'Foram encontrados ',m_qtd_erro USING '<<<<', ' registos com erro'
      CALL log0030_mensagem(m_msg,'info')
   END IF

   CALL _ADVPL_set_property(m_pan_cabec,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_dat_de,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_dat_ate,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_estoque,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_cod_cliente,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_lupa_cli,"EDITABLE",FALSE)
      
   RETURN TRUE   
    
END FUNCTION

#------------------------------#
FUNCTION pol1343_monta_select()#
#------------------------------#

   LET m_query = " SELECT p.cod_cliente, i.num_pedido, i.cod_item, ",
       " i.prz_entrega, (i.qtd_pecas_solic - i.qtd_pecas_cancel) ",
       " FROM ped_itens i, pedidos p",
       " WHERE i.cod_empresa = '",p_cod_empresa,"' ",
       " AND i.cod_empresa = p.cod_empresa",
       " AND i.num_pedido = p.num_pedido",
       " AND p.ies_sit_pedido <> '9' ",
       " AND i.qtd_pecas_atend = 0",
       " AND i.qtd_pecas_romaneio = 0",
       " AND (i.qtd_pecas_solic - i.qtd_pecas_cancel) > 0 ",
       " AND i.prz_entrega >= '",mr_cabec.dat_de,"' ",
       " AND i.prz_entrega <= '",mr_cabec.dat_ate,"' "
       
   IF mr_cabec.cod_cliente IS NOT NULL THEN
      LET m_query = m_query CLIPPED, " AND p.cod_cliente = '",mr_cabec.cod_cliente,"' "
   END IF   
      
END FUNCTION          
       
#----------------------------#
FUNCTION pol1343_le_demanda()#
#----------------------------#

   DEFINE l_progres     SMALLINT

   CALL LOG_progresspopup_set_total("PROCESS",100)

   PREPARE var_pesq FROM m_query
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('PREPARE','var_pesq')
      RETURN FALSE
   END IF
   
   DECLARE cq_pesq CURSOR  FOR var_pesq
   FOREACH cq_pesq INTO
      mr_deman.cod_cliente,
      mr_deman.num_pedido, 
      mr_deman.cod_item,   
      mr_deman.prz_entrega,
      mr_deman.demanda    
   
      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("FOREACH","cq_pesq",0)
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")

      INSERT INTO w_pedido_temp VALUES(mr_deman.*)

   END FOREACH
   
   RETURN TRUE

END FUNCTION


