#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1383                                                 #
# OBJETIVO: CARGA DE LISTA DE PREÇO                                 #
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
       m_arquivo         VARCHAR(10),
       m_pnl_info        VARCHAR(10),
       m_browse          VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_cod_moeda       INTEGER,
       m_cod_empresa     CHAR(02),
       m_num_lista       INTEGER

DEFINE mr_cabec          RECORD
       cod_empresa       CHAR(02),
       nom_arquivo       VARCHAR(80),
       num_lista         INTEGER,
       den_lista         VARCHAR(40),
       dat_val_ini	     DATE, 
       dat_val_fim	     DATE,
       bloqueia_pedido	 CHAR(01),
       bloqueia_fatur    CHAR(01),
       mensagem          VARCHAR(80)
END RECORD

DEFINE m_caminho         VARCHAR(120),
       m_ies_ambiente    CHAR(01),
       m_carregando      SMALLINT,
       m_posi_arq        INTEGER,
       m_qtd_arq         INTEGER,
       m_nom_arquivo     CHAR(40),
       m_arq_arigem      CHAR(100),
       m_progres         SMALLINT,
       m_qtd_item        INTEGER,
       m_ies_lista       SMALLINT,
       m_ind             INTEGER

DEFINE ma_files ARRAY[50] OF CHAR(100)

DEFINE ma_itens ARRAY[5000] OF RECORD
       cod_empresa	          char(02),   
       num_Lista	            integer,   
       den_lista         VARCHAR(40), 
       dat_val_ini	          date,       
       dat_val_fim	          date,       
       bloqueia_pedido	      char(01),   
       bloqueia_faturamento  char(01),    
       cod_moeda	            integer,    
       unid_medida	          char(03),   
       cod_cliente	          char(15),   
       area_e_linha	        char(08),     
       cod_item	            char(15),     
       preco_unit	          char(20),     
       preco_minimo          char(20),
       mensagem             VARCHAR(40),
       ies_lista            char(01)           
END RECORD


#-----------------#
FUNCTION pol1383()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1383-12.00.11  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1383_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1383_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_proces      VARCHAR(10),
           l_carga       VARCHAR(10),
           l_titulo      CHAR(100)
    
    LET l_titulo = "CARGA DE LISTA DE PREÇO - ",p_versao
    
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
    CALL _ADVPL_set_property(l_carga,"TOOLTIP","Selecionar um arquivo para carga")
    CALL _ADVPL_set_property(l_carga,"EVENT","pol1383_carga_informar")
    CALL _ADVPL_set_property(l_carga,"CONFIRM_EVENT","pol1383_carga_info_conf")
    CALL _ADVPL_set_property(l_carga,"CANCEL_EVENT","pol1383_carga_info_canc")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Proessa a carga do arquivo")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1383_processar")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1383_cria_campos(l_panel)
   CALL pol1383_cria_grade(l_panel)

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1383_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)

    LET m_pnl_info = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_container)
    CALL _ADVPL_set_property(m_pnl_info,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pnl_info,"HEIGHT",60)
    CALL _ADVPL_set_property(m_pnl_info,"ENABLE",FALSE)
    #CALL _ADVPL_set_property(m_pnl_info,"BACKGROUND_COLOR",231,237,237)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_arquivo = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pnl_info)     
    CALL _ADVPL_set_property(m_arquivo,"POSITION",70,10)     
    CALL _ADVPL_set_property(m_arquivo,"ADD_ITEM","0","Select    ")
    CALL _ADVPL_set_property(m_arquivo,"VARIABLE",mr_cabec,"nom_arquivo")

    {LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",650,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Lista:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",700,10)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10) 
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"num_Lista")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",800,10)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30) 
    CALL _ADVPL_set_property(l_caixa,"ENABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"mensagem")}

END FUNCTION

#---------------------------------------#
FUNCTION pol1383_cria_grade(l_container)#
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
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Emp")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_empresa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Lista")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_Lista")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_Lista")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Valid ini")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_val_ini")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Valid fim")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_val_fim")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","B. ped")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","bloqueia_pedido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","B. fat")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","bloqueia_faturamento")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Moeda")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_moeda")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","U Med")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","unid_medida")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cliente")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","AEN")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","area_e_linha")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pre Unit")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","preco_unit")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pre mínimo")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","preco_minimo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#--------------------------------#
FUNCTION pol1383_carga_informar()#
#--------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_ies_info = FALSE
   
   IF NOT pol1383_le_caminho() THEN
      RETURN FALSE
   END IF
   
   CALL pol1383_limpa_campos()
   LET m_carregando = FALSE

   {IF NOT pol1383_dirExist() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1383_fileExist() THEN
      RETURN FALSE
   END IF}
   
   IF NOT pol1383_carrega_lista() THEN
      RETURN FALSE
   END IF
   
   CALL pol1383_ativa_desativa(TRUE)   
   CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------------#
FUNCTION pol1383_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
      
   CALL _ADVPL_set_property(m_pnl_info,"ENABLE",l_status)

END FUNCTION

#------------------------------#
FUNCTION pol1383_limpa_campos()#
#------------------------------#
   
   LET m_carregando = TRUE
   INITIALIZE mr_cabec.* TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   
END FUNCTION

#----------------------------#
FUNCTION pol1383_le_caminho()#
#----------------------------#

   SELECT nom_caminho, ies_ambiente
     INTO m_caminho, m_ies_ambiente
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "TXT"

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema TXT não cadastrado na LOG1100.'
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
FUNCTION pol1383_dirExist()#
#--------------------------#

  DEFINE l_dir  CHAR(250),
         l_msg  CHAR(250)
 
  LET l_dir = m_caminho CLIPPED
 
  IF LOG_dir_exist(l_dir,0) THEN
  ELSE
     
     CALL LOG_consoleMessage("FALHA. Motivo: "||log0030_mensagem_get_texto())
     LET l_msg = "FALHA. Motivo: ", log0030_mensagem_get_texto()
     CALL log0030_mensagem(l_msg,'info')
     
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
 FUNCTION pol1383_fileExist()#
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

#-------------------------------#
FUNCTION pol1383_carrega_lista()#
#-------------------------------#     

   DEFINE l_ind     INTEGER,
          t_ind     CHAR(03)

   CALL _ADVPL_set_property(m_arquivo,"CLEAR") 
   CALL _ADVPL_set_property(m_arquivo,"ADD_ITEM","0","Select    ") 
   
   LET m_posi_arq = LENGTH(m_caminho) + 1
   LET m_qtd_arq = LOG_file_getListCount(m_caminho,"*.txt",FALSE,FALSE,FALSE)
   
   IF m_qtd_arq = 0 THEN
      LET m_msg = 'Nenhum arquivo foi encontrado no caminho ', m_caminho
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF m_qtd_arq > 50 THEN
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
       CALL _ADVPL_set_property(m_arquivo,"ADD_ITEM",t_ind,ma_files[l_ind])                    
   END FOR
    
END FUNCTION

#---------------------------------#
FUNCTION pol1383_carga_info_canc()#
#---------------------------------#

   CALL pol1383_limpa_campos()
   CALL pol1383_ativa_desativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1383_carga_info_conf()#
#---------------------------------#
   
   DEFINE l_status        SMALLINT
   
   IF NOT pol1383_valid_arquivo() THEN
      RETURN FALSE
   END IF
   
   LET m_carregando = TRUE

   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1383_load_arq","PROCESS")  
   
   LET m_carregando = FALSE

   IF NOT p_status THEN
      CALL pol1383_carga_info_canc() RETURNING l_status
      RETURN FALSE
   END IF
   
   LET m_ies_info = TRUE
   LET m_msg = 'Arquivo selecionado e exibido \n na grade com sucesso. '
   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE   
    
END FUNCTION

#-------------------------------#
FUNCTION pol1383_valid_arquivo()#
#-------------------------------#
           
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_cabec.nom_arquivo = "0" THEN
      LET m_msg = 'Selecione um arquivo para carga.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS") 
      RETURN FALSE
   END IF

   LET m_count = mr_cabec.nom_arquivo
   LET m_arq_arigem = ma_files[m_count] CLIPPED
   
   LET m_nom_arquivo = m_arq_arigem[m_posi_arq, LENGTH(m_arq_arigem)]

   CALL LOG_consoleMessage("Arquivo: "||m_arq_arigem)
   
   IF NOT pol1383_checa_carga() THEN
      CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS") 
      RETURN FALSE
   END IF
   
   IF m_msg IS NOT NULL THEN
      IF NOT LOG_question(m_msg) THEN
         RETURN FALSE
      END IF
   END IF
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1383_checa_carga()#
#-----------------------------#   
   
   DEFINE l_dat_carga    DATE
   
   LET m_msg = NULL
      
   SELECT DISTINCT dat_carga INTO l_dat_carga
     FROM lista_schulman
    WHERE cod_empresa = p_cod_empresa
      AND nom_arquivo = m_nom_arquivo

   IF STATUS = 0 THEN
      LET m_msg = 'Esse arquivo já foi \n',
                  'carregado em ', l_dat_carga, '\n',
                  'Deseja recarregá-lo ?'
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','lista_schulman')
         RETURN FALSE
      END IF
   END IF
      
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1383_load_arq()#
#--------------------------#
   
   DEFINE l_lista, l_moeda INTEGER,
          l_empresa        CHAR(02)
   
   IF NOT pol1383_cria_temp() THEN
      RETURN FALSE
   END IF
      
   CALL LOG_transaction_begin()
   
   LOAD FROM m_arq_arigem 
     INSERT INTO lista_temp_schulman(
        cod_empresa,	         
        num_Lista,	           
        den_lista,	           
        dat_val_ini,	         
        dat_val_fim,	         
        bloqueia_pedido,	     
        bloqueia_faturamento, 
        cod_moeda,	           
        unid_medida,	         
        cod_cliente,	         
        area_e_linha,	       
        cod_item,	           
        preco_unit,	         
        preco_minimo)         
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('SELECT','lista_temp_schulman:LOAD')
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   SELECT COUNT(*) INTO m_count
     FROM lista_temp_schulman
   
   IF STATUS <> 0 THEN
      LET m_msg = "FALHA. Motivo: ", log0030_mensagem_get_texto()
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'O arquivo selecionado está vazio.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   DECLARE cq_count CURSOR FOR
   SELECT  empresa, num_lista, count(DISTINCT parametro_val) 
     FROM vdp_pre_mst_compl where empresa = p_cod_empresa
    GROUP BY  empresa, num_lista
    HAVING  count(distinct parametro_val)  > 1
   
   OPEN cq_count
   FETCH cq_count INTO l_empresa, l_lista, l_moeda

   IF STATUS = 0 THEN
      LET m_msg = 'Lista ', l_lista, ' contém mais de um tipo de moeda'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

{   #usuário monta o arquivo com espaçõ no inicio da informação
    #os blocos a seguir estão em desenvolvimento
    
   IF NOT pol1383_gera_id() THEN
      RETURN FALSE
   END IF

   IF NOT pol1383_tira_espaco() THEN
      RETURN FALSE
   END IF
}
   IF NOT pol1383_exibe_dados() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1383_cria_temp()#
#---------------------------#
   
   DROP TABLE lista_temp_schulman
   
   CREATE  TABLE lista_temp_schulman (
      cod_empresa	          char(80),     
      num_Lista	            integer,      
      den_lista	            char(80),  
      dat_val_ini	          date,         
      dat_val_fim	          date,         
      bloqueia_pedido	      char(80),     
      bloqueia_faturamento  char(80),     
      cod_moeda	            integer,      
      unid_medida	          char(80),     
      cod_cliente	          char(80),     
      area_e_linha	        char(80),     
      cod_item	            char(80),     
      preco_unit	          char(80),     
      preco_minimo          char(80),
      id_registro           integer
   )
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','lista_temp_schulman')
      RETURN FALSE
   END IF
   
   CREATE INDEX ix1_lista_temp_schulman on
      lista_temp_schulman(cod_empresa, num_Lista);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','ix1_lista_temp_schulman')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

{
#-------------------------#
FUNCTION pol1383_gera_id()#
#-------------------------#

   DEFINE l_id    INTEGER
   
   LET l_id = 0

   DECLARE cq_id CURSOR FOR
   SELECT *
     FROM lista_temp_schulman
   
   FOREACH cq_id INTO lr_lista.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','lista_temp_schulman:cq_espaco')
         RETURN FALSE
      END IF
   
   

#-----------------------------#
FUNCTION pol1383_tira_espaco()#
#-----------------------------#
   
   DEFINE lr_lista       RECORD
      cod_empresa	          char(80),     
      num_Lista	            integer,      
      den_lista	            char(80),  
      dat_val_ini	          date,         
      dat_val_fim	          date,         
      bloqueia_pedido	      char(80),     
      bloqueia_faturamento  char(80),     
      cod_moeda	            integer,      
      unid_medida	          char(80),     
      cod_cliente	          char(80)),     
      area_e_linha	        char(80),     
      cod_item	            char(80),     
      preco_unit	          char(80),     
      preco_minimo          char(80)
   END RECORD   
   
   
   DECLARE cq_espaco CURSOR FOR
   SELECT *
     FROM lista_temp_schulman
   
   FOREACH cq_espaco INTO lr_lista.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','lista_temp_schulman:cq_espaco')
         RETURN FALSE
      END IF

      LET lr_lista.cod_empresa = func002_trim(lr_lista.cod_empresa)
      LET lr_lista.den_lista = func002_trim(lr_lista.den_lista)
      LET lr_lista.bloqueia_pedido = func002_trim(lr_lista.bloqueia_pedido)
      LET lr_lista.bloqueia_faturamento = func002_trim(lr_lista.bloqueia_faturamento)
      LET lr_lista.unid_medida = func002_trim(lr_lista.unid_medida)
      LET lr_lista.cod_cliente = func002_trim(lr_lista.cod_cliente)
      LET lr_lista.area_e_linha = func002_trim(lr_lista.area_e_linha)
      LET lr_lista.cod_item = func002_trim(lr_lista.cod_item)
      LET lr_lista.preco_unit = func002_trim(lr_lista.preco_unit)
      LET lr_lista.preco_minimo = func002_trim(lr_lista.preco_minimo)
}

#-----------------------------#
FUNCTION pol1383_exibe_dados()#
#-----------------------------#

   INITIALIZE ma_itens TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   LET m_ind = 1
   LET m_ies_lista = FALSE
         
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DECLARE cq_lista CURSOR FOR
   SELECT DISTINCT 
          cod_empresa,
          num_Lista 
     FROM lista_temp_schulman
    ORDER BY cod_empresa, num_Lista
   
   FOREACH cq_lista INTO 
           mr_cabec.cod_empresa,
           mr_cabec.num_Lista
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','lista_temp_schulman:cq_lista')
         RETURN FALSE
      END IF
      
      SELECT 1 FROM desc_preco_mest
       WHERE cod_empresa = mr_cabec.cod_empresa
         AND num_list_preco = mr_cabec.num_Lista

      IF STATUS = 0 THEN
         LET mr_cabec.mensagem = 'Lista já existe no Logix.'
         LET m_ies_lista = TRUE
      ELSE
         IF STATUS = 100 THEN
            LET mr_cabec.mensagem = NULL
         ELSE
            CALL log003_err_sql('SELECT','desc_preco_mest')
            RETURN FALSE
         END  IF
      END IF
      
      IF NOT pol1383_exibe_itens() THEN
         RETURN FALSE
      END IF
      
   END FOREACH

   RETURN TRUE

END FUNCTION      

#_----------------------------#
FUNCTION pol1383_exibe_itens()#
#_----------------------------#
   
   DECLARE cq_exib CURSOR FOR
    SELECT cod_empresa,	        
           num_Lista,	   
           den_lista,      
           dat_val_ini,	        
           dat_val_fim,	        
           bloqueia_pedido,	    
           bloqueia_faturamento, 
           cod_moeda,	          
           unid_medida,	        
           cod_cliente,	        
           area_e_linha,	        
           cod_item,	            
           preco_unit,
           preco_minimo
      FROM lista_temp_schulman
     WHERE cod_empresa = mr_cabec.cod_empresa
       AND num_Lista = mr_cabec.num_lista
       
   FOREACH cq_exib INTO 
      ma_itens[m_ind].cod_empresa,	         
      ma_itens[m_ind].num_Lista,	           
      ma_itens[m_ind].den_Lista,	           
      ma_itens[m_ind].dat_val_ini,	         
      ma_itens[m_ind].dat_val_fim,	         
      ma_itens[m_ind].bloqueia_pedido,	     
      ma_itens[m_ind].bloqueia_faturamento, 
      ma_itens[m_ind].cod_moeda,	           
      ma_itens[m_ind].unid_medida,	         
      ma_itens[m_ind].cod_cliente,	         
      ma_itens[m_ind].area_e_linha,	       
      ma_itens[m_ind].cod_item,	           
      ma_itens[m_ind].preco_unit,
      ma_itens[m_ind].preco_minimo
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','lista_temp_schulman:cq_exib')
         RETURN FALSE
      END IF
               
      LET m_progres = LOG_progresspopup_increment("PROCESS") 
      
      LET ma_itens[m_ind].mensagem = mr_cabec.mensagem
      
      IF m_ies_lista THEN
         LET ma_itens[m_ind].ies_lista = 'S'
      ELSE
         LET ma_itens[m_ind].ies_lista = 'N'
      END IF
      
      LET m_ind = m_ind + 1

      IF m_ind > 5000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapasou'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
      
   END FOREACH
   
   LET m_qtd_item = m_ind - 1
   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT",m_qtd_item)
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1383_processar()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')   
   
   IF NOT m_ies_info THEN
      LET m_msg = 'Selecione previamente um arquivo.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)   
      RETURN FALSE
   END IF

   IF m_ies_lista THEN
      LET m_msg = 'Uma ou mais listas já existem no Logix.\n',
                  'Excluí-las do Logix e gerar novamente ?'
      IF NOT LOG_question(m_msg) THEN
         RETURN FALSE
      END IF
   END IF

   CALL LOG_transaction_begin()

   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1383_gera_lista","PROCESS")  
   
   IF NOT p_status THEN
      CALL LOG_transaction_rollback()
      LET m_msg = 'Processamento cancelado.'
   ELSE
      CALL LOG_transaction_commit()
      LET m_msg = 'Processamento efetuado com sucesso.'
      LET mr_cabec.mensagem = 'Lista cadastrada com sucesso'
      LET m_ies_lista = TRUE
      LET m_ies_info = FALSE
   END IF
   
   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1383_gera_lista()#
#----------------------------#

   DEFINE l_ind      INTEGER,
          l_progres  SMALLINT
   
   LET m_cod_empresa = '00'
   LET m_num_lista = 0
   
   CALL LOG_progresspopup_set_total("PROCESS",m_qtd_item)
      
   FOR m_ind = 1 TO m_qtd_item
      LET l_progres = LOG_progresspopup_increment("PROCESS") 
      IF NOT pol1383_ins_item() THEN
         RETURN FALSE
      END IF
   END FOR
      
   IF NOT pol1383_ins_arquivo() THEN
      RETURN FALSE
   END IF

   IF NOT pol1383_move_arquivo() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
    
END FUNCTION  

#---------------------------#
FUNCTION pol1383_del_lista()#
#---------------------------#   
   
   DEFINE l_dat_atu     DATE,
          l_hor_atu     CHAR(08)
   
   LET l_dat_atu = TODAY
   LET l_hor_atu = TIME
   
   DELETE FROM desc_preco_item
    WHERE cod_empresa = mr_cabec.cod_empresa
      AND num_list_preco = mr_cabec.num_Lista

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','desc_preco_item')
      RETURN FALSE
   END IF
      
   DELETE FROM desc_preco_mest
    WHERE cod_empresa = mr_cabec.cod_empresa
      AND num_list_preco = mr_cabec.num_Lista

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','desc_preco_mest')
      RETURN FALSE
   END IF
 
   DELETE FROM lista_schulman
    WHERE cod_empresa = mr_cabec.cod_empresa
      AND num_Lista = mr_cabec.num_Lista

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','lista_schulman')
      RETURN FALSE
   END IF

   DELETE FROM vdp_pre_mst_compl
    WHERE empresa = mr_cabec.cod_empresa
      AND num_lista = mr_cabec.num_Lista
      AND campo = 'COD_MOEDA'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','vdp_pre_mst_compl')
      RETURN FALSE
   END IF

   DELETE FROM ctr_acesso
    WHERE cod_refer = mr_cabec.num_Lista

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','ctr_acesso')
      RETURN FALSE
   END IF

   LET m_msg = 'Excluído Item da Lista de Preço ', mr_cabec.num_Lista
   
   INSERT INTO audit_vdp (
     cod_empresa, 
     num_pedido, 
     tipo_informacao, 
     tipo_movto, 
     texto, 
     num_programa, 
     data, 
     hora, 
     usuario) VALUES( 
        mr_cabec.cod_empresa,0,'I','E',
        m_msg,'POL1383',l_dat_atu,l_hor_atu,p_user)
        
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','audit_vdp')
      RETURN FALSE
   END IF  
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1383_ins_item()#
#--------------------------#
   
   DEFINE lr_lista_item    RECORD LIKE desc_preco_item.*
   DEFINE l_campo          VARCHAR(30),
          l_num_trans      INTEGER,
          l_pre_min        LIKE desc_preco_item.pre_unit
   DEFINE l_dat_atu        DATE,
          l_hor_atu        CHAR(08)
   
   LET l_dat_atu = TODAY
   LET l_hor_atu = TIME
   
   LET mr_cabec.cod_empresa      = ma_itens[m_ind].cod_empresa           
   LET mr_cabec.num_Lista        = ma_itens[m_ind].num_Lista             
   LET mr_cabec.den_lista        = ma_itens[m_ind].den_Lista             
   LET mr_cabec.dat_val_ini      = ma_itens[m_ind].dat_val_ini           
   LET mr_cabec.dat_val_fim      = ma_itens[m_ind].dat_val_fim           
   LET mr_cabec.bloqueia_pedido  = ma_itens[m_ind].bloqueia_pedido       
   LET mr_cabec.bloqueia_fatur   = ma_itens[m_ind].bloqueia_faturamento  
   LET m_cod_moeda = ma_itens[m_ind].cod_moeda                                                                   
   
   IF m_cod_empresa <> mr_cabec.cod_empresa OR
       m_num_lista <> mr_cabec.num_Lista THEN
      IF NOT pol1383_ins_mest() THEN
         RETURN FALSE
      END IF 
      IF NOT pol1383_ins_moeda() THEN
         RETURN FALSE
      END IF
      LET m_cod_empresa = mr_cabec.cod_empresa
      LET m_num_lista = mr_cabec.num_Lista
   END IF
   
   LET lr_lista_item.cod_empresa       = mr_cabec.cod_empresa
   LET lr_lista_item.num_list_preco    = ma_itens[m_ind].num_Lista
   LET lr_lista_item.cod_uni_feder     = ma_itens[m_ind].unid_medida
   LET lr_lista_item.cod_cliente       = ma_itens[m_ind].cod_cliente
   LET lr_lista_item.cod_lin_prod      = ma_itens[m_ind].area_e_linha[1,2]
   LET lr_lista_item.cod_lin_recei     = ma_itens[m_ind].area_e_linha[3,4]
   LET lr_lista_item.cod_seg_merc      = ma_itens[m_ind].area_e_linha[5,6]
   LET lr_lista_item.cod_cla_uso       = ma_itens[m_ind].area_e_linha[7,8]
   LET lr_lista_item.cod_item          = ma_itens[m_ind].cod_item
   LET lr_lista_item.pre_unit          = ma_itens[m_ind].preco_unit
   LET lr_lista_item.pct_desc          = 0
   LET lr_lista_item.pct_desc_adic     = 0
   LET lr_lista_item.cod_grupo         = 0
   LET lr_lista_item.cod_acabam        = '0'
   LET lr_lista_item.cod_cnd_pgto      = 0
   LET lr_lista_item.pre_unit_adic     = 0
   LET lr_lista_item.pre_unit_ant      = 0
   LET lr_lista_item.pre_unit_adic_ant = 0
   LET lr_lista_item.num_transacao     = 0
   
   INSERT INTO desc_preco_item(
     cod_empresa,      
     num_list_preco,   
     cod_uni_feder,    
     cod_cliente,      
     cod_lin_prod,     
     cod_lin_recei,    
     cod_seg_merc,     
     cod_cla_uso,      
     cod_item,         
     pre_unit,         
     pct_desc,         
     pct_desc_adic,    
     cod_grupo,        
     cod_acabam,       
     cod_cnd_pgto,     
     pre_unit_adic,    
     pre_unit_ant,     
     pre_unit_adic_ant)
     VALUES(lr_lista_item.cod_empresa,      
            lr_lista_item.num_list_preco,   
            lr_lista_item.cod_uni_feder,    
            lr_lista_item.cod_cliente,      
            lr_lista_item.cod_lin_prod,     
            lr_lista_item.cod_lin_recei,    
            lr_lista_item.cod_seg_merc,     
            lr_lista_item.cod_cla_uso,      
            lr_lista_item.cod_item,         
            lr_lista_item.pre_unit,         
            lr_lista_item.pct_desc,         
            lr_lista_item.pct_desc_adic,    
            lr_lista_item.cod_grupo,        
            lr_lista_item.cod_acabam,       
            lr_lista_item.cod_cnd_pgto,     
            lr_lista_item.pre_unit_adic,    
            lr_lista_item.pre_unit_ant,     
            lr_lista_item.pre_unit_adic_ant)
        
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','desc_preco_item')
      RETURN FALSE
   END IF

   SELECT COUNT (cod_refer)
     INTO m_count 
     FROM ctr_acesso  
    WHERE cod_refer = lr_lista_item.num_list_preco
      AND ies_tip_infor = '3' 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ctr_acesso')
      RETURN FALSE
   END IF
   
   LET m_count = m_count + 1
   
   INSERT INTO ctr_acesso (
      cod_refer, ies_tip_infor, num_ctr_acesso) 
   VALUES(lr_lista_item.num_list_preco,'3',m_count)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ctr_acesso')
      RETURN FALSE
   END IF

   LET l_pre_min = ma_itens[m_ind].preco_minimo

   IF l_pre_min IS NULL THEN
      LET l_pre_min = 0
   END IF

   INSERT INTO vdp_pre_it_audit ( 
    empresa,            
    lista_preco,        
    estado,             
    cliente,            
    linha_produto,      
    linha_receita,      
    segmento_mercado,   
    classe_uso,         
    item,               
    preco_unitario,     
    desc_lista_preco,   
    desc_adic_lpre,     
    grupo,              
    acabamento,         
    condicao_pagto,     
    pre_unit_adicional, 
    pre_unit_anterior,  
    pre_unit_adic_ant,  
    preco_minimo,       
    dat_auditoria,      
    usuario) VALUES (lr_lista_item.cod_empresa,     
                     lr_lista_item.num_list_preco,
                     lr_lista_item.cod_uni_feder,
                     lr_lista_item.cod_cliente,
                     lr_lista_item.cod_lin_prod, 
                     lr_lista_item.cod_lin_recei,
                     lr_lista_item.cod_seg_merc, 
                     lr_lista_item.cod_cla_uso,  
                     lr_lista_item.cod_item,      
                     lr_lista_item.pre_unit,                           
                     lr_lista_item.pct_desc,                           
                     lr_lista_item.pct_desc_adic,                      
                     lr_lista_item.cod_grupo,                          
                     lr_lista_item.cod_acabam,                         
                     lr_lista_item.cod_cnd_pgto,                       
                     lr_lista_item.pre_unit_adic,                       
                     lr_lista_item.pre_unit_ant,                  
                     lr_lista_item.pre_unit_adic_ant,             
                     l_pre_min,   
                     l_dat_atu,
                     p_user)                  

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','vdp_pre_it_audit')
      RETURN FALSE
   END IF

   LET m_msg = 'Incluido de lista de preco 2001 ',lr_lista_item.num_list_preco

   INSERT INTO audit_vdp (   
     cod_empresa,            
     num_pedido,             
     tipo_informacao,        
     tipo_movto,             
     texto,                  
     num_programa,           
     data,                   
     hora,                   
     usuario) VALUES(mr_cabec.cod_empresa,              
                     0,'I','I',m_msg,'POL1383',  
                     l_dat_atu,l_hor_atu,p_user) 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','audit_vdp')
      RETURN FALSE
   END IF
                                            
   INSERT INTO vdp_audit_lpre (
      empresa,                    
      lista_preco,                
      unid_federal,               
      cliente,                    
      linha_produto,              
      linha_receita,              
      segmto_mercado,             
      classe_uso,                 
      item,                       
      preco_unit,                 
      pct_desc,                   
      pct_desc_adicional,         
      grupo,                      
      acabamto,                   
      cond_pagto,                 
      pre_unit_adicional,         
      preco_unit_ant,             
      pre_uni_adic_ant,           
      usuario,                    
      dat_alteracao,              
      programa) 
    VALUES(mr_cabec.cod_empresa, 
           lr_lista_item.num_list_preco,   
           lr_lista_item.cod_uni_feder,              
           lr_lista_item.cod_cliente,                
           lr_lista_item.cod_lin_prod,               
           lr_lista_item.cod_lin_recei,              
           lr_lista_item.cod_seg_merc,               
           lr_lista_item.cod_cla_uso,                
           lr_lista_item.cod_item,                   
           lr_lista_item.pre_unit,                                     
           lr_lista_item.pct_desc,                                     
           lr_lista_item.pct_desc_adic,                                
           lr_lista_item.cod_grupo,                                    
           lr_lista_item.cod_acabam,                                   
           lr_lista_item.cod_cnd_pgto,                                 
           lr_lista_item.pre_unit_adic,                                 
           lr_lista_item.pre_unit_ant,                            
           lr_lista_item.pre_unit_adic_ant,              
           p_user,                                   
           l_dat_atu,                                
           'POL1383')                                

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','vdp_audit_lpre')
      RETURN FALSE
   END IF
   
   DELETE FROM vdp_pre_item_compl
    WHERE empresa = lr_lista_item.cod_empresa
      AND lista_preco = lr_lista_item.num_list_preco
      AND (estado = lr_lista_item.cod_uni_feder OR estado IS NULL)    
      AND (cliente = lr_lista_item.cod_cliente OR cliente IS NULL)    
      AND linha_produto = lr_lista_item.cod_lin_prod   
      AND linha_receita = lr_lista_item.cod_lin_recei 
      AND segmto_mercado = lr_lista_item.cod_seg_merc
      AND item = lr_lista_item.cod_item
      AND campo = 'PRECO MINIMO'
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','vdp_pre_item_compl')
      RETURN FALSE
   END IF
   
   SELECT MAX(num_trans) INTO l_num_trans
     FROM vdp_pre_item_compl
    WHERE empresa = lr_lista_item.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','vdp_pre_item_compl')
      RETURN FALSE
   END IF
   
   IF l_num_trans IS NULL THEN
      LET l_num_trans = 0
   END IF
   
   LET l_num_trans = l_num_trans + 1
   LET l_campo = 'PRECO MINIMO'
   
   INSERT INTO vdp_pre_item_compl(
      empresa,        
      lista_preco,    
      estado,         
      cliente,        
      linha_produto,  
      linha_receita,  
      segmto_mercado, 
      classe_uso,     
      item,           
      num_trans,      
      campo,          
      parametro_val,  
      parametro_qtd)
       VALUES(lr_lista_item.cod_empresa,
         lr_lista_item.num_list_preco,
         lr_lista_item.cod_uni_feder,
         lr_lista_item.cod_cliente,
         lr_lista_item.cod_lin_prod, 
         lr_lista_item.cod_lin_recei,
         lr_lista_item.cod_seg_merc, 
         lr_lista_item.cod_cla_uso,  
         lr_lista_item.cod_item,
         l_num_trans,
         l_campo,
         0, 
         l_pre_min)
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','vdp_pre_item_compl')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION 
 
#--------------------------#
FUNCTION pol1383_ins_mest()#
#--------------------------#

   DEFINE lr_lista_mest    RECORD LIKE desc_preco_mest.*

   IF ma_itens[m_ind].ies_lista = 'S' THEN  
      IF NOT pol1383_del_lista() THEN
         RETURN FALSE
      END IF
   END IF
   
   LET lr_lista_mest.cod_empresa    = mr_cabec.cod_empresa
   LET lr_lista_mest.num_list_preco = mr_cabec.num_Lista
   LET lr_lista_mest.den_list_preco = mr_cabec.den_lista
   LET lr_lista_mest.dat_ini_vig    = mr_cabec.dat_val_ini 
   LET lr_lista_mest.dat_fim_vig    = mr_cabec.dat_val_fim 
   LET lr_lista_mest.ies_bloq_pedido= mr_cabec.bloqueia_pedido
   LET lr_lista_mest.ies_bloq_fatur = mr_cabec.bloqueia_fatur

   INSERT INTO desc_preco_mest VALUES(lr_lista_mest.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','desc_preco_mest')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1383_ins_moeda()#
#---------------------------#

   DELETE FROM vdp_pre_mst_compl
    WHERE empresa = mr_cabec.cod_empresa
      AND num_lista = mr_cabec.num_Lista
      AND campo = 'COD_MOEDA'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','vdp_pre_mst_compl')
      RETURN FALSE
   END IF
   
   INSERT INTO vdp_pre_mst_compl(empresa, num_lista, campo, parametro_val)
     VALUES(mr_cabec.cod_empresa, mr_cabec.num_Lista, 'COD_MOEDA', m_cod_moeda)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','vdp_pre_mst_compl')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1383_ins_arquivo()#
#-----------------------------#
   
   DEFINE l_data        date
   
   LET l_data = TODAY
   
   INSERT INTO lista_schulman (
     cod_empresa,	        
     num_Lista,	          
     den_lista,	          
     dat_val_ini,	        
     dat_val_fim,	        
     bloqueia_pedido,	    
     bloqueia_faturamento, 
     cod_moeda,	          
     unid_medida,	        
     cod_cliente,	        
     area_e_linha,	        
     cod_item,	            
     preco_unit,	          
     preco_minimo,
     nom_arquivo) SELECT
     cod_empresa,	        
     num_Lista,	          
     den_lista,	          
     dat_val_ini,	        
     dat_val_fim,	        
     bloqueia_pedido,	    
     bloqueia_faturamento, 
     cod_moeda,	          
     unid_medida,	        
     cod_cliente,	        
     area_e_linha,	        
     cod_item,	            
     preco_unit,	          
     preco_minimo, 'XXY' FROM lista_temp_schulman     

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','lista_schulman')
      RETURN FALSE
   END IF
   
   UPDATE lista_schulman 
      SET nom_arquivo = m_nom_arquivo,
          dat_carga = l_data
    WHERE cod_empresa = mr_cabec.cod_empresa
      AND nom_arquivo = 'XXY'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','lista_schulman')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1383_move_arquivo()#
#------------------------------#
   
   DEFINE l_arq_dest       CHAR(100),
          l_comando        CHAR(120),
          l_tamanho        integer
   
   LET m_arq_arigem = m_arq_arigem CLIPPED
   
   LET l_tamanho = LENGTH(m_arq_arigem)
   
   LET l_arq_dest = m_arq_arigem[1,(l_tamanho-4)],'.pro'

   IF m_ies_ambiente = 'W' THEN
      LET l_comando = 'move ', m_arq_arigem CLIPPED, ' ', l_arq_dest
   ELSE
      LET l_comando = 'mv ', m_arq_arigem CLIPPED, ' ', l_arq_dest
   END IF
 
   RUN l_comando RETURNING p_status
   
   IF p_status = 1 THEN
      LET m_msg = 'Não foi possivel renomear o arquivo de .txt para .txt-proces'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   
   