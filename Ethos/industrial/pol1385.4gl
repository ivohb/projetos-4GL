#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1385                                                 #
# OBJETIVO: IMPORTAÇÃO DE ARQUIVOS CSV DEMANDA E ITEM               #
# AUTOR...: IVO                                                     #
# DATA....: 12/02/2020                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           m_panel           VARCHAR(10),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_cod_empresa_plano   LIKE empresa.cod_empresa

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_folder          VARCHAR(10),
       m_fold_deman      VARCHAR(10),
       m_fold_item       VARCHAR(10),
       m_construct       VARCHAR(10)

DEFINE m_pan_deman       VARCHAR(10),
       m_pan_item        VARCHAR(10),
       m_arq_denam       VARCHAR(10),
       m_arq_item        VARCHAR(10)
       
DEFINE m_brz_deman       VARCHAR(10),
       m_brz_item        VARCHAR(10),
       m_car_deman       SMALLINT,
       m_car_item        SMALLINT,
       m_posi_arq        INTEGER,
       m_qtd_arq         INTEGER,
       m_nom_arquivo     CHAR(40),
       m_arq_origem      CHAR(100),
       m_linha           VARCHAR(120),
       m_qtd_erro        INTEGER,
       m_dat_atu         DATE,
       m_hor_atu         CHAR(08)
       
DEFINE m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ind             INTEGER,
       m_lin_atu         INTEGER,
       m_nom_reduz       VARCHAR(15),
       m_den_reduz       VARCHAR(18),
       m_ies_deman       SMALLINT,
       m_ies_item        SMALLINT,
       m_caminho         VARCHAR(120),
       m_ies_ambiente    CHAR(01),
       m_pos_ini         INTEGER,
       m_pos_fim         INTEGER,
       m_cliente         VARCHAR(60),
       m_qtd_deman       INTEGER,
       m_qtd_item        INTEGER

DEFINE ma_files ARRAY[150] OF CHAR(100)

DEFINE mr_deman          RECORD
       cod_empresa       CHAR(02),
       nom_arquivo       VARCHAR(80)
END RECORD
                     
DEFINE ma_deman          ARRAY[20000] OF RECORD
       cod_cliente       CHAR(15),
       nom_reduzido      CHAR(15),
       num_pedido        CHAR(06),
       cod_item          CHAR(15),
       den_item_reduz    CHAR(18),
       prz_entrega       CHAR(10),
       ops               CHAR(10),
       estoque           CHAR(10),
       faturar           CHAR(10),
       abrir             CHAR(10),
       mensagem          VARCHAR(120)
END RECORD
       
DEFINE mr_item           RECORD
       cod_empresa       CHAR(02),
       nom_arquivo       VARCHAR(80)
END RECORD

DEFINE ma_item          ARRAY[20000] OF RECORD
       cod_empresa       CHAR(02),
       cod_item          CHAR(15),
       den_item_reduz    CHAR(18),
       cod_grade_1       CHAR(15),
       cod_grade_2       CHAR(15),
       cod_grade_3       CHAR(15),
       cod_grade_4       CHAR(15),
       cod_grade_5       CHAR(15),
       mes_ref           DECIMAL(2,0),
       ano_ref           DECIMAL(4,0),
       qtd_plano         DECIMAL(15,3),
       mensagem          VARCHAR(120)
END RECORD

             
#-----------------#
FUNCTION pol1385()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1385-12.00.08  "
   CALL func002_versao_prg(p_versao)
   
   LET m_car_deman = TRUE
   LET m_car_item = TRUE
   
   CALL pol1385_menu()

END FUNCTION
 
#----------------------#
FUNCTION pol1385_menu()#
#----------------------#

    DEFINE l_menubar       VARCHAR(10),
           l_fechar        VARCHAR(10),
           l_panel         VARCHAR(10),
           l_fpanel        VARCHAR(10),
           l_label         VARCHAR(10),
           l_titulo        CHAR(80)

    LET l_titulo = 'IMPORTAÇÃO DE ARQUIVOS CSV DEMANDA E ITEM - ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET m_folder = _ADVPL_create_component(NULL,"LFOLDER",m_dialog)
    CALL _ADVPL_set_property(m_folder,"ALIGN","CENTER")

    # FOLDER demanda 

    LET m_fold_deman = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_deman,"TITLE","Demanda")
		CALL pol1385_deman(m_fold_deman)   

    # FOLDER item 

    LET m_fold_item = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_item,"TITLE","Item")
    CALL pol1385_item(m_fold_item)

    CALL _ADVPL_set_property(m_folder,"FOLDER_SELECTED",1)
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION
   
#------------------------#
FUNCTION pol1385_fechar()#
#------------------------#

   RETURN TRUE
   
END FUNCTION

#-----------------------------------------#
FUNCTION pol1385_desativa_folder(l_folder)#
#-----------------------------------------#

   DEFINE l_folder             CHAR(01)
             
   CASE l_folder
        WHEN '1' 
           CALL _ADVPL_set_property(m_fold_item,"ENABLE",FALSE)        
        WHEN '2' 
           CALL _ADVPL_set_property(m_fold_deman,"ENABLE",FALSE)   
   END CASE
   
END FUNCTION

#------------------------------#
FUNCTION pol1385_ativa_folder()#
#------------------------------#

   CALL _ADVPL_set_property(m_fold_deman,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_item,"ENABLE",TRUE)

END FUNCTION

#---Rotinas de importaçao de demanda ----#

#-------------------------------#
FUNCTION pol1385_deman(l_fpanel)#
#-------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_carga     VARCHAR(10),
           l_proces    VARCHAR(10),
           l_fechar    VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_carga = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_carga,"IMAGE","IMPORTAR_ARQUIVO")     
    CALL _ADVPL_set_property(l_carga,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_carga,"TOOLTIP","Selecionar um arquivo para carga")
    CALL _ADVPL_set_property(l_carga,"EVENT","pol1385_deman_info")
    CALL _ADVPL_set_property(l_carga,"CONFIRM_EVENT","pol1385_deman_conf")
    CALL _ADVPL_set_property(l_carga,"CANCEL_EVENT","pol1385_deman_canc")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Proessa a carga do arquivo")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1385_deman_proces")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1385_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1385_deman_campo(l_panel)
    CALL pol1385_deman_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1385_deman_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_deman = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_deman,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_deman,"HEIGHT",40)
    #CALL _ADVPL_set_property(m_pan_deman,"BACKGROUND_COLOR",225,232,232) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_deman)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_deman)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",70,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",2,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_deman,"cod_empresa")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_deman)
    CALL _ADVPL_set_property(l_label,"POSITION",100,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_arq_denam = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_deman)     
    CALL _ADVPL_set_property(m_arq_denam,"POSITION",160,10)     
    CALL _ADVPL_set_property(m_arq_denam,"ADD_ITEM","0","Select    ")
    CALL _ADVPL_set_property(m_arq_denam,"VARIABLE",mr_deman,"nom_arquivo")

    CALL _ADVPL_set_property(m_pan_deman,"ENABLE",FALSE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1385_deman_grade(l_container)#
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
   
    LET m_brz_deman = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_deman,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(m_brz_deman,"BEFORE_ROW_EVENT","pol1385_deman_before_row")
        
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_deman)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_deman)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_reduzido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_deman)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_deman)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_deman)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item_reduz")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_deman)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dat entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","prz_entrega")

    {LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_deman)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ops")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ops")}

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_deman)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Estoq")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","estoque")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_deman)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Fat")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","faturar")
       
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_deman)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Abrir")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","abrir")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_deman)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_brz_deman,"SET_ROWS",ma_deman,1)
    CALL _ADVPL_set_property(m_brz_deman,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_deman,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_deman,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#---------------------------------#   
FUNCTION pol1385_le_cliente(l_cod)#
#---------------------------------#

   DEFINE l_cod       CHAR(15)
   
   SELECT nom_reduzido
     INTO m_nom_reduz
     FROM clientes
    WHERE cod_cliente = l_cod

   IF STATUS <> 0 THEN
      #CALL log003_err_sql('SELECT','clientes')
      LET m_nom_reduz = NULL
   END IF  
         
END FUNCTION    

#----------------------------#
FUNCTION pol1385_deman_info()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_ies_deman = FALSE
   
   IF NOT pol1385_le_caminho() THEN
      RETURN FALSE
   END IF
   
   CALL pol1385_limpa_deman()
   LET m_car_deman = FALSE

   IF NOT pol1385_dirExist() THEN
      RETURN FALSE
   END IF
      
   IF NOT pol1385_deman_lista() THEN
      RETURN FALSE
   END IF
   
   LET mr_deman.cod_empresa = p_cod_empresa
   CALL _ADVPL_set_property(m_pan_deman,"ENABLE",TRUE) 
   CALL _ADVPL_set_property(m_arq_denam,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1385_limpa_deman()#
#-----------------------------#
   
   LET m_car_deman = TRUE
   INITIALIZE mr_deman.* TO NULL
   CALL _ADVPL_set_property(m_brz_deman,"CLEAR")
   
END FUNCTION

#----------------------------#
FUNCTION pol1385_le_caminho()#
#----------------------------#

   SELECT nom_caminho, ies_ambiente
     INTO m_caminho, m_ies_ambiente
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "PCP"

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema PCP não cadastrado na LOG1100.'
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
FUNCTION pol1385_dirExist()#
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
 FUNCTION pol1385_fileExist()#
#----------------------------#
  
  DEFINE l_file  CHAR(250)
 
  LET l_file = m_caminho CLIPPED, 'arquivo_01.txt'
 
  IF LOG_file_exist(l_file,0) THEN
     LET m_msg = l_file CLIPPED, " Arquivo existe no servidor"
  ELSE
     LET m_msg = l_file CLIPPED, " Arquivo NÂO existe no servidor"
  END IF
 
  CALL log0030_mensagem(m_msg,'info')

  IF LOG_file_exist(l_file,1) THEN
     LET m_msg = l_file CLIPPED, " Arquivo existe no client"
  ELSE
     LET m_msg = l_file CLIPPED, " Arquivo NÂO existe no client"
  END IF
 
  CALL log0030_mensagem(m_msg,'info')
  
  RETURN FALSE
  
END FUNCTION

#-----------------------------#
FUNCTION pol1385_deman_lista()#
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
FUNCTION pol1385_deman_canc()#
#----------------------------#

   CALL pol1385_limpa_deman()
   CALL _ADVPL_set_property(m_pan_deman,"ENABLE",FALSE)
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1385_deman_conf()#
#----------------------------#

   DEFINE l_status        SMALLINT
   
   IF NOT pol1385_deman_valid_arq() THEN
      RETURN FALSE
   END IF
   
   LET m_car_deman = TRUE

   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1385_deman_load_arq","PROCESS")  
   
   LET m_car_deman = FALSE

   IF NOT p_status THEN
      CALL pol1385_deman_canc() RETURNING l_status
      RETURN FALSE
   END IF
   
   LET m_ies_deman = TRUE

   IF m_qtd_erro > 0 THEN
      LET m_msg = 'Foram encontrados ',m_qtd_erro USING '<<<<', ' registos com erro'
   ELSE
      LET m_msg = 'Operação efetuada com sucesso'
   END IF
   
   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE   
    
END FUNCTION

#---------------------------------#
FUNCTION pol1385_deman_valid_arq()#
#---------------------------------#
           
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_deman.nom_arquivo = "0" THEN
      LET m_msg = 'Selecione um arquivo para carga.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_arq_denam,"GET_FOCUS")
      RETURN FALSE
   END IF

   LET m_count = mr_deman.nom_arquivo
   LET m_arq_origem = ma_files[m_count] CLIPPED
   
   LET m_nom_arquivo = m_arq_origem[m_posi_arq, LENGTH(m_arq_origem)]

   CALL LOG_consoleMessage("Arquivo: "||m_arq_origem)
         
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1385_deman_load_arq()#
#--------------------------------#
   
   DEFINE l_lista, l_moeda INTEGER,
          l_empresa        CHAR(02)
   
   IF NOT pol1385_deman_cria_temp() THEN
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
      LET m_msg = 'O arquivo selecionado está vazio.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   IF NOT pol1385_exibe_deman() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1385_deman_cria_temp()#
#---------------------------------#
   
   DROP TABLE w_demanda
   
   CREATE TEMP TABLE w_demanda (
      linha          CHAR(120)
   );
   
   DELETE FROM w_demanda

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','w_demanda:dct')
      RETURN FALSE
   END IF
   
   SELECT COUNT(*) INTO m_count
     FROM w_demanda
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','w_demanda:dct:COUNT')
      RETURN FALSE
   END IF
   
   IF m_count > 0 THEN
      LET m_msg = 'Não foi posivel inicializar a tabela w_demanda.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1385_exibe_deman()#
#-----------------------------#
   
   DEFINE l_progres     SMALLINT

   DEFINE l_parametro      RECORD
          cod_empresa      CHAR(02),
          cod_item         CHAR(15),
          cod_local        CHAR(10)
   END RECORD
   
   INITIALIZE ma_deman TO NULL
   CALL _ADVPL_set_property(m_brz_deman,"CLEAR")
   CALL _ADVPL_set_property(m_brz_deman,"CLEAR_ALL_LINE_FONT_COLOR")
   LET m_ind = 0
   LET m_qtd_erro = 0
         
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DECLARE cq_deman CURSOR FOR
   SELECT linha
     FROM w_demanda
   
   FOREACH cq_deman INTO m_linha
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','w_demanda:cq_deman')
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      IF m_linha[1,7] = 'Cliente' THEN
         CONTINUE FOREACH
      END IF

      LET m_ind = m_ind + 1             
      
      IF m_ind > 20000 THEN
         LET m_msg = 'Limite previsto de itens ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
      
      LET m_pos_ini = 1
      LET m_cliente = pol1385_divide_texto()      
      LET ma_deman[m_ind].cod_cliente = pol1385_pega_codigo()
      CALL pol1385_le_cliente(ma_deman[m_ind].cod_cliente)
      LET ma_deman[m_ind].nom_reduzido = m_nom_reduz
      LET ma_deman[m_ind].num_pedido = pol1385_divide_texto()   
      LET ma_deman[m_ind].cod_item = pol1385_divide_texto()   
      CALL pol1385_le_item(ma_deman[m_ind].cod_item)
      LET ma_deman[m_ind].den_item_reduz = m_den_reduz  
      LET ma_deman[m_ind].prz_entrega = pol1385_divide_texto()   
      {LET ma_deman[m_ind].ops = pol1385_divide_texto() 
      LET ma_deman[m_ind].estoque = pol1385_divide_texto()   
      LET ma_deman[m_ind].faturar = pol1385_divide_texto()} 
      LET ma_deman[m_ind].abrir = pol1385_divide_texto()   
      
      LET l_parametro.cod_empresa = p_cod_empresa
      LET l_parametro.cod_item = ma_deman[m_ind].cod_item
      
      SELECT cod_local_estoq
        INTO l_parametro.cod_local
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_deman[m_ind].cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item')
         RETURN FALSE
      END IF
      
      LET m_msg = NULL

      CALL func002_le_estoque(l_parametro) RETURNING m_msg, ma_deman[m_ind].estoque
      
      IF m_msg IS NULL THEN
         IF NOT pol1385_consist_pedido() THEN
            RETURN FALSE
         END IF
      END IF
      
      LET ma_deman[m_ind].mensagem = m_msg
      
      IF m_msg IS NOT NULL THEN
         LET m_qtd_erro = m_qtd_erro + 1
         CALL _ADVPL_set_property(m_brz_deman,"LINE_FONT_COLOR",m_ind,255,0,0)
      ELSE
         CALL _ADVPL_set_property(m_brz_deman,"LINE_FONT_COLOR",m_ind,0,0,0)
      END IF      
      
   END FOREACH

   LET m_qtd_deman = m_ind 
   CALL _ADVPL_set_property(m_brz_deman,"ITEM_COUNT", m_qtd_deman)

   RETURN TRUE

END FUNCTION      

#------------------------------#
FUNCTION pol1385_divide_texto()#
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
FUNCTION pol1385_pega_codigo()#
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
FUNCTION pol1385_consist_pedido()#
#--------------------------------#
   
   DEFINE l_ies_situa    CHAR(01),
          l_count        INTEGER,
          l_data         DATE
          
   LET l_data = ma_deman[m_ind].prz_entrega
   
   SELECT ies_sit_pedido 
     INTO l_ies_situa
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = ma_deman[m_ind].cod_cliente
      AND num_pedido = ma_deman[m_ind].num_pedido
   
   IF STATUS = 100 THEN
      LET m_msg = 'Pedido não existe'
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','pedidos')
         RETURN FALSE
      END IF
   END IF
   
   IF l_ies_situa = 'N' THEN
   ELSE
      IF l_ies_situa = 'E' THEN
         LET m_msg = 'Pedido em análise'
         RETURN TRUE
      ELSE
         IF l_ies_situa = 'B' THEN
            LET m_msg = 'Pedido bloqueado'
            RETURN TRUE
         END IF
      END IF
   END IF

   SELECT SUM(qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel )
     INTO ma_deman[m_ind].faturar
     FROM ped_itens
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = ma_deman[m_ind].num_pedido
      AND cod_item = ma_deman[m_ind].cod_item
      AND prz_entrega = l_data
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ped_itens')
      RETURN FALSE
   END IF

   IF  ma_deman[m_ind].faturar IS NULL THEN
       LET ma_deman[m_ind].faturar = 0
       LET m_msg = 'Programação de entrega não existe'
   END IF
         
   RETURN TRUE

END FUNCTION

#------------------------------#   
FUNCTION pol1385_deman_proces()#
#------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT m_ies_deman THEN
      LET m_msg = 'Informe um arquivo previamente'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF m_qtd_erro > 0 THEN
      LET m_msg = 'Os registros com erro não serão carregados para\n',
                  'a tabela de demanda. Continuar mesmo assim?'
                  
      IF NOT LOG_question(m_msg) THEN
         RETURN FALSE
      END IF
   END IF
      
   CALL LOG_transaction_begin()
   
   IF NOT pol1385_grava_deman() THEN
      CALL LOG_transaction_rollback()
      LET m_msg = 'Operação cancelada'
      CALL log0030_mensagem(m_msg, 'info')  
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   CALL pol1385_move_arquivo()
   
   LET m_ies_deman = FALSE
   LET m_msg = 'Operação efetuada com sucesso'
   CALL log0030_mensagem(m_msg, 'info')   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1385_grava_deman()#
#-----------------------------#
   
   FOR m_ind = 1 TO m_qtd_deman
       IF ma_deman[m_ind].num_pedido IS NOT NULL THEN
          IF ma_deman[m_ind].mensagem IS NULL THEN
             IF NOT pol1385_ins_deman() THEN
                RETURN FALSE
             END IF
             CALL _ADVPL_set_property(m_brz_deman,"COLUMN_VALUE","mensagem",m_ind,'IMPORTADO')
          END IF
       END IF        
   END FOR
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1385_ins_deman()#
#---------------------------#

   LET m_dat_atu = TODAY
   LET m_hor_atu = TIME

   SELECT 1 FROM ethosi_demandas
    WHERE cod_empresa = p_cod_empresa
      AND nro_documento = ma_deman[m_ind].num_pedido
      AND pai_principal = ma_deman[m_ind].cod_item
      AND dat_inclus = m_dat_atu
      AND hor_inclus = m_hor_atu
   
   IF STATUS = 0 THEN
      SLEEP(1)
      LET m_hor_atu = TIME
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','ethosi_demandas')
         RETURN FALSE
      END IF
   END IF
   
   INSERT INTO ethosi_demandas(
      cod_empresa,    
      nro_documento,   
      pai_principal,   
      prazo_entrega,   
      qtd_a_produzir,  
      dat_inclus,      
      hor_inclus,      
      ja_processado,   
      usuario_inclusao) VALUES (
         p_cod_empresa,
         ma_deman[m_ind].num_pedido,   
         ma_deman[m_ind].cod_item,    
         ma_deman[m_ind].prz_entrega,    
         ma_deman[m_ind].abrir,    
         m_dat_atu,    
         m_hor_atu,
         'N',    
         p_user)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ethosi_demandas')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1385_move_arquivo()#
#------------------------------#

   DEFINE l_arq_dest       CHAR(100),
          l_comando        CHAR(120),
          l_tamanho        integer
   
   LET m_arq_origem = m_arq_origem CLIPPED
   
   LET l_tamanho = LENGTH(m_arq_origem)
   
   LET l_arq_dest = m_arq_origem[1,(l_tamanho-4)],'.pro'

   IF m_ies_ambiente = 'W' THEN
      LET l_comando = 'move ', m_arq_origem CLIPPED, ' ', l_arq_dest
   ELSE
      LET l_comando = 'mv ', m_arq_origem CLIPPED, ' ', l_arq_dest
   END IF

   IF NOT LOG_file_move( m_arq_origem ,l_arq_dest , 0) THEN
      IF NOT LOG_file_copy( m_arq_origem ,l_arq_dest , 0) THEN
 
         RUN l_comando RETURNING p_status
   
         IF p_status = 1 THEN
            LET m_msg = 'Não foi possivel renomear o arquivo de .csv para .pro'
            CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         END IF
      
      END IF
      
   END IF

END FUNCTION   

   

#---Rotinas de importaçao de itens ----#

#-------------------------------#
FUNCTION pol1385_item(l_fpanel)#
#-------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_carga     VARCHAR(10),
           l_proces    VARCHAR(10),
           l_fechar    VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_carga = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_carga,"IMAGE","IMPORTAR_ARQUIVO")     
    CALL _ADVPL_set_property(l_carga,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_carga,"TOOLTIP","Selecionar um arquivo para carga")
    CALL _ADVPL_set_property(l_carga,"EVENT","pol1385_item_info")
    CALL _ADVPL_set_property(l_carga,"CONFIRM_EVENT","pol1385_item_conf")
    CALL _ADVPL_set_property(l_carga,"CANCEL_EVENT","pol1385_item_canc")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Proessa a carga do arquivo")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1385_item_proces")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1385_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1385_item_campo(l_panel)
    CALL pol1385_item_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1385_item_campo(l_container)#
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
    CALL _ADVPL_set_property(l_label,"POSITION",10,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_item)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",70,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",2,0)    
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_item,"cod_empresa")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_item)
    CALL _ADVPL_set_property(l_label,"POSITION",100,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_arq_item = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_item)     
    CALL _ADVPL_set_property(m_arq_item,"POSITION",160,10)     
    CALL _ADVPL_set_property(m_arq_item,"ADD_ITEM","0","Select    ")
    CALL _ADVPL_set_property(m_arq_item,"VARIABLE",mr_item,"nom_arquivo")
        
    CALL _ADVPL_set_property(m_pan_item,"ENABLE",FALSE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1385_item_grade(l_container)#
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
   
    LET m_brz_item = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_item,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(m_brz_item,"BEFORE_ROW_EVENT","pol1385_item_before_row")
        
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item_reduz")
       
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Grade 1")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_grade_1")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Grade 2")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_grade_2")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Grade 3")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_grade_3")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Grade 4")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_grade_4")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Grade 5")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_grade_5")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mês")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mes_ref")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ano")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ano_ref")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd plano")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_plano")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_brz_item,"SET_ROWS",ma_item,1)
    CALL _ADVPL_set_property(m_brz_item,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_item,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_item,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#------------------------------#   
FUNCTION pol1385_le_item(l_cod)#
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
         LET m_den_reduz = 'Item não existe'
      END IF
   END IF
            
END FUNCTION    

#---------------------------#
FUNCTION pol1385_item_info()#
#---------------------------#
   
   LET m_ies_item = FALSE
   
   IF NOT pol1385_le_caminho() THEN
      RETURN FALSE
   END IF
   
   CALL pol1385_limpa_item()
   LET m_car_item = FALSE

   IF NOT pol1385_dirExist() THEN
      RETURN FALSE
   END IF
      
   IF NOT pol1385_item_lista() THEN
      RETURN FALSE
   END IF
   
   LET mr_item.cod_empresa = p_cod_empresa
   CALL _ADVPL_set_property(m_pan_item,"ENABLE",TRUE) 
   CALL _ADVPL_set_property(m_arq_item,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1385_limpa_item()#
#----------------------------#
   
   LET m_car_item = TRUE
   INITIALIZE mr_item.* TO NULL
   CALL _ADVPL_set_property(m_brz_item,"CLEAR")
   
END FUNCTION

#---------------------------#
FUNCTION pol1385_item_canc()#
#---------------------------#

   CALL pol1385_limpa_item()
   CALL _ADVPL_set_property(m_pan_item,"ENABLE",FALSE)
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1385_item_lista()#
#----------------------------#     

   DEFINE l_ind     INTEGER,
          t_ind     CHAR(03)

   CALL _ADVPL_set_property(m_arq_item,"CLEAR") 
   CALL _ADVPL_set_property(m_arq_item,"ADD_ITEM","0","Select    ") 
   
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
       CALL _ADVPL_set_property(m_arq_item,"ADD_ITEM",t_ind,ma_files[l_ind])   
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1385_item_conf()#
#---------------------------#

   DEFINE l_status        SMALLINT

   IF NOT pol1385_item_valid_arq() THEN
      RETURN FALSE
   END IF
   
   LET m_car_item = TRUE

   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1385_item_load_arq","PROCESS")  
   
   LET m_car_deman = FALSE

   IF NOT p_status THEN
      CALL pol1385_item_canc() RETURNING l_status
      RETURN FALSE
   END IF
   
   LET m_ies_item = TRUE
   
   IF m_qtd_erro > 0 THEN
      LET m_msg = 'Foram encontrados ',m_qtd_erro USING '<<<<', ' registos com erro'
   ELSE
      LET m_msg = 'Operação efetuada com sucesso'
   END IF
   
   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE   
    
END FUNCTION

#--------------------------------#
FUNCTION pol1385_item_valid_arq()#
#--------------------------------#
           
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_item.nom_arquivo = "0" THEN
      LET m_msg = 'Selecione um arquivo para carga.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_arq_item,"GET_FOCUS")
      RETURN FALSE
   END IF

   LET m_count = mr_item.nom_arquivo
   LET m_arq_origem = ma_files[m_count] CLIPPED
   
   LET m_nom_arquivo = m_arq_origem[m_posi_arq, LENGTH(m_arq_origem)]

   CALL LOG_consoleMessage("Arquivo: "||m_arq_origem)
         
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1385_item_load_arq()#
#-------------------------------#
   
   DEFINE l_lista, l_moeda INTEGER,
          l_empresa        CHAR(02)
   
   IF NOT pol1385_item_cria_temp() THEN
      RETURN FALSE
   END IF
      
   CALL LOG_transaction_begin()
   
   LOAD FROM m_arq_origem INSERT INTO w_item
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('SELECT','w_item:LOAD')
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   SELECT COUNT(*) INTO m_count
     FROM w_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','w_item:COUNT')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'O arquivo selecionado está vazio.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   IF NOT pol1385_exibe_item() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1385_item_cria_temp()#
#--------------------------------#
   
   DROP TABLE w_item
   
   CREATE TEMP TABLE w_item (
      linha          CHAR(120)
   );
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','w_item')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1385_exibe_item()#
#----------------------------#
   
   DEFINE l_progres     SMALLINT
   
   INITIALIZE ma_item TO NULL
   CALL _ADVPL_set_property(m_brz_item,"CLEAR")
   LET m_ind = 0
   LET m_qtd_erro = 0
         
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DECLARE cq_item CURSOR FOR
   SELECT linha
     FROM w_item
   
   FOREACH cq_item INTO m_linha
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','w_item:cq_item')
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET m_ind = m_ind + 1             
      
      IF m_ind > 20000 THEN
         LET m_msg = 'Limite previsto de demandas ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
      
      LET m_pos_ini = 1
      LET ma_item[m_ind].cod_item = pol1385_divide_texto()      
      CALL pol1385_le_item(ma_item[m_ind].cod_item)
      LET ma_item[m_ind].den_item_reduz = m_den_reduz
      LET ma_item[m_ind].mes_ref = pol1385_divide_texto()   
      LET ma_item[m_ind].ano_ref = pol1385_divide_texto()   
      LET ma_item[m_ind].qtd_plano = pol1385_divide_texto()        
      LET ma_item[m_ind].mensagem = NULL
            
   END FOREACH

   LET m_qtd_item = m_ind 
   CALL _ADVPL_set_property(m_brz_item,"ITEM_COUNT", m_qtd_item)

   RETURN TRUE

END FUNCTION      

#-----------------------------#
FUNCTION pol1385_item_proces()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT m_ies_item THEN
      LET m_msg = 'Informe um arquivo previamente'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF m_qtd_erro > 0 THEN
      LET m_msg = 'Os registros com erro não serão carregados para\n',
                  'a tabela de pl_it_me_grade. Continuar mesmo assim?'
                  
      IF NOT LOG_question(m_msg) THEN
         RETURN FALSE
      END IF
   END IF
      
   CALL LOG_transaction_begin()
   
   IF NOT pol1385_grava_item() THEN
      CALL LOG_transaction_rollback()
      LET m_msg = 'Operação cancelada'
      CALL log0030_mensagem(m_msg, 'info')  
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   CALL pol1385_move_arquivo()
   
   LET m_ies_item = FALSE
   LET m_msg = 'Operação efetuada com sucesso'
   CALL log0030_mensagem(m_msg, 'info')   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1385_grava_item()#
#-----------------------------#

   DELETE FROM pl_it_me_grade
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','pl_it_me_grade')
      RETURN FALSE
   END IF
   
   FOR m_ind = 1 TO m_qtd_item
       IF ma_item[m_ind].cod_item IS NOT NULL THEN
          IF ma_item[m_ind].mensagem IS NULL THEN
             IF NOT pol1385_ins_item() THEN
                RETURN FALSE
             END IF
             CALL _ADVPL_set_property(m_brz_item,"COLUMN_VALUE","mensagem",m_ind,m_msg)
          END IF
       END IF        
   END FOR
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1385_ins_item()#
#--------------------------#

   {SELECT 1 FROM pl_it_me_grade
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = ma_item[m_ind].cod_item
      AND mes_ref = ma_item[m_ind].mes_ref
      AND ano_ref = ma_item[m_ind].ano_ref
   
   IF STATUS = 0 THEN
      LET m_msg = 'Produto / periodo já existe na tabela pl_it_me_grade'
      RETURN TRUE
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','pl_it_me_grade')
         RETURN FALSE
      END IF
   END IF}

   INSERT INTO pl_it_me_grade(
      cod_empresa,    
      cod_item,   
      cod_grade_1,
      cod_grade_2,
      cod_grade_3,
      cod_grade_4,
      cod_grade_5,     
      mes_ref,
      ano_ref,
      qtd_plano) VALUES (
         p_cod_empresa,
         ma_item[m_ind].cod_item,  
         ' ',' ',' ',' ',' ',  
         ma_item[m_ind].mes_ref,    
         ma_item[m_ind].ano_ref,    
         ma_item[m_ind].qtd_plano)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','pl_it_me_grade')
      RETURN FALSE
   END IF
   
   LET m_msg = 'IMPORTADO'
   
   RETURN TRUE

END FUNCTION
