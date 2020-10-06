#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1401                                                 #
# OBJETIVO: ACERTO DE ESTOQUE DE BOBINA                             #
# AUTOR...: IVO                                                     #
# DATA....: 10/09/2020                                              #
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
       m_linha           VARCHAR(400)

DEFINE mr_cabec          RECORD
       nom_arquivo       VARCHAR(80)
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
       m_pos_ini         INTEGER,
       m_pos_fim         INTEGER,
       m_ind             INTEGER,
       m_peso_trim       DECIMAL(10,3), 
       m_peso_logix      DECIMAL(10,3),
       m_peso_difer      DECIMAL(10,3)
       
DEFINE ma_files ARRAY[50] OF CHAR(100)

DEFINE ma_itens ARRAY[2000] OF RECORD
       bobina	            VARCHAR(15),   
       produto            VARCHAR(15), 
       largura            VARCHAR(15),
       tubete             VARCHAR(15),
       diametro           VARCHAR(15),
       dat_geracao        DATE,
       peso_trim          VARCHAR(15),
       peso_logix         DECIMAL(10,3),
       peso_difer         DECIMAL(10,3),
       num_transac        INTEGER
END RECORD

#-----------------#
FUNCTION pol1401()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1401-12.00.00  "
   CALL func002_versao_prg(p_versao)

   IF NOT log0150_verifica_se_tabela_existe("acerto_estoque_885") THEN 
      IF NOT pol1401_cria_tab() THEN
         RETURN FALSE
      END IF
   END IF
    
   CALL pol1401_menu()
    
END FUNCTION

#--------------------------#
FUNCTION pol1401_cria_tab()#
#--------------------------#

   CREATE TABLE acerto_estoque_885 (
       bobina	            VARCHAR(15),   
       produto            VARCHAR(15), 
       largura            VARCHAR(15),
       tubete             VARCHAR(15),
       diametro           VARCHAR(15),
       dat_geracao        DATE,
       peso_trim          DECIMAL(10,3),
       peso_logix         DECIMAL(10,3),
       peso_difer         DECIMAL(10,3),
       num_transac        INTEGER
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','TABLE.acerto_estoque_885')
      RETURN FALSE
   END IF

   CREATE INDEX ix_acerto_estoque_885
    ON acerto_estoque_885(bobina);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','INDEX.acerto_estoque_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE      
   
END FUNCTION

#----------------------#
FUNCTION pol1401_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_proces      VARCHAR(10),
           l_carga       VARCHAR(10),
           l_titulo      CHAR(100)
    
    LET l_titulo = "ACERTO DE ESTOQUE DE BOBINA - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_carga = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_carga,"IMAGE","IMPORTAR_ARQUIVO")     
    CALL _ADVPL_set_property(l_carga,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_carga,"TOOLTIP","Selecionar um arquivo para carga")
    CALL _ADVPL_set_property(l_carga,"EVENT","pol1401_carga_informar")
    CALL _ADVPL_set_property(l_carga,"CONFIRM_EVENT","pol1401_carga_info_conf")
    CALL _ADVPL_set_property(l_carga,"CANCEL_EVENT","pol1401_carga_info_canc")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Proessa a carga do arquivo")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1401_processar")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1401_cria_campos(l_panel)
   CALL pol1401_cria_grade(l_panel)

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1401_cria_campos(l_container)#
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

END FUNCTION

#---------------------------------------#
FUNCTION pol1401_cria_grade(l_container)#
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
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Bobina")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","bobina")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Produto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","produto")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Largura")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","largura")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tubete")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","tubete")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Diametro")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","diametro")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Geração")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_geracao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Peso Trim")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","peso_trim")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Peso Logix")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","peso_logix")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Diferença")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","peso_difer")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#--------------------------------#
FUNCTION pol1401_carga_informar()#
#--------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_ies_info = FALSE
   
   IF NOT pol1401_le_caminho() THEN
      RETURN FALSE
   END IF
   
   CALL pol1401_limpa_campos()
   LET m_carregando = FALSE

   IF NOT pol1401_dirExist() THEN
      RETURN FALSE
   END IF
      
   IF NOT pol1401_carrega_lista() THEN
      RETURN FALSE
   END IF
   
   CALL pol1401_ativa_desativa(TRUE)   
   CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------------#
FUNCTION pol1401_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
      
   CALL _ADVPL_set_property(m_pnl_info,"ENABLE",l_status)

END FUNCTION

#------------------------------#
FUNCTION pol1401_limpa_campos()#
#------------------------------#
   
   LET m_carregando = TRUE
   INITIALIZE mr_cabec.*, ma_itens TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   
END FUNCTION

#----------------------------#
FUNCTION pol1401_le_caminho()#
#----------------------------#

   SELECT nom_caminho, ies_ambiente
     INTO m_caminho, m_ies_ambiente
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "CSV"

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema CSV não cadastrado na LOG1100.'
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
FUNCTION pol1401_dirExist()#
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

#-------------------------------#
FUNCTION pol1401_carrega_lista()#
#-------------------------------#     

   DEFINE l_ind     INTEGER,
          t_ind     CHAR(03)

   CALL _ADVPL_set_property(m_arquivo,"CLEAR") 
   CALL _ADVPL_set_property(m_arquivo,"ADD_ITEM","0","Select    ") 
   
   LET m_posi_arq = LENGTH(m_caminho) + 1
   LET m_qtd_arq = LOG_file_getListCount(m_caminho,"*.csv",FALSE,FALSE,FALSE)
   
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
FUNCTION pol1401_carga_info_canc()#
#---------------------------------#

   CALL pol1401_limpa_campos()
   CALL pol1401_ativa_desativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1401_carga_info_conf()#
#---------------------------------#
   
   DEFINE l_status        SMALLINT
   
   IF NOT pol1401_valid_arquivo() THEN
      RETURN FALSE
   END IF
   
   LET m_carregando = TRUE

   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1401_load_arq","PROCESS")  
   
   LET m_carregando = FALSE

   IF NOT p_status THEN
      CALL pol1401_carga_info_canc() RETURNING l_status
      RETURN FALSE
   END IF
   
   LET m_ies_info = TRUE
   LET m_msg = 'Arquivo carregado com sucesso. '
   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE   
    
END FUNCTION

#-------------------------------#
FUNCTION pol1401_valid_arquivo()#
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
            
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1401_load_arq()#
#--------------------------#
   
   DEFINE l_lista, l_moeda INTEGER,
          l_empresa        CHAR(02)
   
   IF NOT pol1401_cria_temp() THEN
      RETURN FALSE
   END IF
      
   CALL LOG_transaction_begin()
   
   LOAD FROM m_arq_arigem 
     INSERT INTO w_bobina_temp

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('SELECT','w_bobina_temp:LOAD')
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   SELECT COUNT(*) INTO m_count
     FROM w_bobina_temp
   
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
   
   IF NOT pol1401_separa() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1401_cria_temp()#
#---------------------------#
   
   DROP TABLE w_bobina_temp
   
   CREATE  TABLE w_bobina_temp (
      linha     	          VARCHAR(400)
   )   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','w_bobina_temp')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1401_separa()#
#------------------------#

   DEFINE l_nome, 
          l_sobre_nome  VARCHAR(30),
          l_tamanho     INTEGER,
          l_peso        DECIMAL(10,3),
          l_pula        VARCHAR(400),
          l_dat_geracao VARCHAR(19)
   
   LET m_count = m_count + 100
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   INITIALIZE ma_itens TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   CALL _ADVPL_set_property(m_browse,"CLEAR_ALL_LINE_FONT_COLOR")
   
   DELETE FROM acerto_estoque_885

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','acerto_estoque_885')
      RETURN FALSE
   END IF
   
   LET m_ind = 0
   
   DECLARE cq_temp CURSOR FOR
   SELECT linha 
     FROM w_bobina_temp
   
   FOREACH cq_temp INTO m_linha
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','w_bobina_temp:cq_temp')
         RETURN FALSE
      END IF

      LET m_progres = LOG_progresspopup_increment("PROCESS")
            
      LET m_ind = m_ind + 1
      
      IF m_ind > 5000 THEN
         LET m_msg = 'Limite previsto de itens ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF

      LET m_pos_ini = 1
      LET ma_itens[m_ind].bobina = pol1401_divide_texto()
      LET l_pula = pol1401_divide_texto()
      LET ma_itens[m_ind].produto = pol1401_divide_texto()
      LET l_pula = pol1401_divide_texto()
      LET ma_itens[m_ind].largura = pol1401_divide_texto()
      LET ma_itens[m_ind].peso_trim = pol1401_divide_texto()
      LET l_pula = pol1401_divide_texto()
      LET l_pula = pol1401_divide_texto()
      LET ma_itens[m_ind].tubete = pol1401_divide_texto()
      LET ma_itens[m_ind].diametro = pol1401_divide_texto()
      LET l_pula = pol1401_divide_texto()
      LET l_pula = pol1401_divide_texto()
      LET l_pula = pol1401_divide_texto()
      LET l_dat_geracao = pol1401_divide_texto()
      LET ma_itens[m_ind].dat_geracao = l_dat_geracao[1,10]
      
      IF NOT pol1401_le_peso_logix() THEN
         RETURN FALSE
      END IF
      
      #IF func002_isNumero(ma_itens[m_ind].peso_trim) THEN
         LET l_peso = ma_itens[m_ind].peso_trim
         LET ma_itens[m_ind].peso_difer = ma_itens[m_ind].peso_logix - l_peso
      #END IF

      IF ma_itens[m_ind].peso_difer <> 0 THEN
         CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_ind,255,127,39)
      ELSE
         CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_ind,0,0,0)
      END IF
      
      LET ma_itens[m_ind].num_transac = 0
      
      INSERT INTO acerto_estoque_885
       VALUES(ma_itens[m_ind].*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','acerto_estoque_885')
         RETURN FALSE
      END IF
               
   END FOREACH      
   
   LET m_ind = m_ind + 1
   
   IF NOT pol1401_le_duplicidade() THEN
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_ind)

   SELECT SUM(peso_trim), 
          SUM(peso_logix), 
          SUM(peso_difer)
     INTO m_peso_trim, 
          m_peso_logix, 
          m_peso_difer
     FROM acerto_estoque_885

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','acerto_estoque_885:SUM')
   ELSE
      LET m_msg = 'Estoque Trim.: ', m_peso_trim,'\n',
                  'Estoque Logix: ', m_peso_logix,'\n',
                  'Diferença....: ', m_peso_difer,'\n'
      CALL log0030_mensagem(m_msg,'info')                  
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1401_divide_texto()#
#------------------------------#
   
   DEFINE l_ind        INTEGER,
          l_conteudo   CHAR(20)
   
   LET m_pos_fim = 0
   
   IF m_linha[m_pos_ini] = ';' THEN
      LET m_pos_ini = m_pos_ini + 1
      RETURN ''
   END IF
   
   FOR l_ind = m_pos_ini TO LENGTH(m_linha)
       IF m_linha[l_ind] = ';' THEN
          LET m_pos_fim = l_ind - 1
          EXIT FOR
       END IF
   END FOR
   
   IF m_pos_fim < m_pos_ini THEN
      LET m_pos_fim = m_pos_ini
   END IF

   IF m_pos_fim > LENGTH(m_linha)  THEN
      LET l_conteudo = ''
   ELSE
      LET l_conteudo = m_linha[m_pos_ini, m_pos_fim]
   END IF
      
   LET m_pos_ini = m_pos_fim + 2
   
   RETURN l_conteudo

END FUNCTION

#-------------------------------#
FUNCTION pol1401_le_peso_logix()#
#-------------------------------#

   SELECT qtd_saldo
     INTO ma_itens[m_ind].peso_logix
     FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = ma_itens[m_ind].produto
      AND num_lote = ma_itens[m_ind].bobina

   IF STATUS = 100 THEN
      LET ma_itens[m_ind].peso_logix = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque_lote_ender.le_peso_logix')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION
     
#--------------------------------#
FUNCTION pol1401_le_duplicidade()#
#--------------------------------#
   
   DEFINE l_dat_geracao     DATE
   
   SELECT MIN(dat_geracao) 
     INTO l_dat_geracao
     FROM acerto_estoque_885

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','acerto_estoque_885:le_dupl')
      RETURN FALSE
   END IF
   
   DECLARE cq_dupl CURSOR FOR
   SELECT num_transac, 
          cod_item,
          num_lote, 
          qtd_saldo,
          largura,
          altura,
          diametro
     FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND largura > 0
      AND qtd_saldo > 0

   FOREACH cq_dupl INTO 
          ma_itens[m_ind].num_transac,
          ma_itens[m_ind].produto,
          ma_itens[m_ind].bobina,
          ma_itens[m_ind].peso_logix,
          ma_itens[m_ind].largura,
          ma_itens[m_ind].tubete,
          ma_itens[m_ind].diametro

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque_lote_ender')
         RETURN FALSE
      END IF
      
      LET m_progres = LOG_progresspopup_increment("PROCESS")
      
      SELECT COUNT(*) INTO m_count
        FROM acerto_estoque_885
       WHERE produto = ma_itens[m_ind].produto
         AND bobina = ma_itens[m_ind].bobina

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','acerto_estoque_885:COUNT')
         RETURN FALSE
      END IF
      
      IF m_count > 0 THEN
         CONTINUE FOREACH
      END IF
      
      LET ma_itens[m_ind].peso_trim = 0
      
      SELECT MIN(dat_movto) 
         INTO ma_itens[m_ind].dat_geracao
         FROM estoque_trans 
        WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_itens[m_ind].produto
         AND num_lote_dest = ma_itens[m_ind].bobina
         AND cod_operacao = 'APON'
         AND num_transac NOT IN 
            (SELECT num_transac_normal FROM estoque_trans_rev WHERE cod_empresa = p_cod_empresa )

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque_trans:dat_movto')
         RETURN FALSE
      END IF

      LET ma_itens[m_ind].peso_difer = ma_itens[m_ind].peso_logix - ma_itens[m_ind].peso_trim
      CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_ind,197,16,26)
      
      INSERT INTO acerto_estoque_885
       VALUES(ma_itens[m_ind].*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','acerto_estoque_885')
         RETURN FALSE
      END IF
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 2000 THEN
         LET m_msg = 'Limite de itens previstos ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH      
   
   RETURN TRUE

END FUNCTION




#---------------------------#
FUNCTION pol1401_processar()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')   
   
   IF NOT m_ies_info THEN
      LET m_msg = 'Selecione previamente um arquivo.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)   
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Em desenvolvimento') 

   RETURN FALSE
   
END FUNCTION
