#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1393                                                 #
# OBJETIVO: GERAÇÃO DE TÍTULOS - INTEGRAÇÃO CONCUR                  #
# AUTOR...: IVO                                                     #
# DATA....: 10/06/2020     cap1040 e/ou cap9991 /cap2360            #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003)
           
END GLOBALS

DEFINE     m_den_empresa   VARCHAR(36)

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_pnl_info        VARCHAR(10),
       m_browse          VARCHAR(10),
       m_brz_erro        VARCHAR(10),
       m_label           VARCHAR(10)
       
DEFINE m_arquivo         VARCHAR(10),
       m_carga           VARCHAR(10),
       m_hora            VARCHAR(10),
       m_ident           VARCHAR(10),
       m_ad              VARCHAR(10),
       m_ap              VARCHAR(10)
       
DEFINE m_ies_carga       SMALLINT,
       m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_cod_empresa     CHAR(02),
       m_num_lista       INTEGER,
       m_ies_print       SMALLINT,
       m_index           INTEGER,
       m_page_length     INTEGER,
       m_arq_gravar      varchar(80)


DEFINE mr_cabec          RECORD
       cod_empresa       CHAR(02),
       nom_arquivo       VARCHAR(80),
       dat_carga  	     DATE, 
       hor_carga         VARCHAR(08),
       id_arquivo        INTEGER,     
       num_ad            INTEGER,
       num_ap            INTEGER
END RECORD

DEFINE m_caminho         VARCHAR(120),
       m_caminho_pro     VARCHAR(120),
       m_caminho_pgi     VARCHAR(120),
       m_ies_ambiente    CHAR(01),
       m_carregando      SMALLINT,
       m_posi_arq        INTEGER,
       m_qtd_arq         INTEGER,
       m_nom_arquivo     VARCHAR(80),
       m_arq_origem      VARCHAR(100),
       m_progres         SMALLINT,
       m_qtd_item        INTEGER,
       m_qtd_ad          INTEGER,
       m_ind             INTEGER,
       m_linha           VARCHAR(250),
       m_id_arquivo      INTEGER,
       m_id_arquivoa     INTEGER,
       m_dat_atu         DATE,
       m_hor_atu         VARCHAR(08),
       m_arq_convert     VARCHAR(200),
       m_arq_renomeado   VARCHAR(200),
       m_pos_ini         INTEGER,
       m_pos_fim         INTEGER,
       m_qtd_reg         CHAR(10),
       m_ies_erro        SMALLINT,
       m_ssr_nf          INTEGER,
       m_cent_cust       CHAR(15),
       m_ctrl_aen        CHAR(01),
       m_ctrl_con        CHAR(01),
       m_query           VARCHAR(1000)

DEFINE ma_files ARRAY[150] OF CHAR(100)

DEFINE ma_itens ARRAY[2000] OF RECORD
       cod_empresa       char(02),
       id_arquivo        integer,
       pessoal           CHAR(01),        
       funcionario       VARCHAR(60),  
       funcio_id         VARCHAR(15),
       relat_key         VARCHAR(15),    
       empresa           VARCHAR(15),      
       despesa           VARCHAR(15),      
       moeda             VARCHAR(15),        
       tip_desp          VARCHAR(15),        
       den_desp          VARCHAR(50),     
       cent_cust         VARCHAR(15),    
       situacao          VARCHAR(40),     
       dat_emissao       VARCHAR(25),  
       dat_pagto         VARCHAR(25),    
       tip_pgto          VARCHAR(30),
       num_ad            INTEGER,
       num_ap            INTEGER,
       cod_tip_despesa   INTEGER 
END RECORD

DEFINE mr_arquivo        RECORD
       cod_empresa      char(02),   
       id_arquivo       integer,    
       nom_arquivo      varchar(80),
       dat_carga        date,       
       hor_carga        char(08),   
       usuario          char(08)
END RECORD

DEFINE mr_titulo          RECORD
       ies_sup_cap        LIKE ad_mestre.ies_sup_cap,
       cod_tip_despesa    LIKE ad_mestre.cod_tip_despesa,
       num_nf             LIKE ad_mestre.num_nf,
       ser_nf             LIKE ad_mestre.ser_nf,
       ssr_nf             LIKE ad_mestre.ssr_nf,
       dat_vencto         LIKE ad_mestre.dat_venc,
       cod_fornecedor     LIKE ad_mestre.cod_fornecedor,
       val_total          LIKE ad_mestre.val_tot_nf,
       observ             LIKE ad_mestre.observ,
       ies_dep_cred       LIKE fornecedor.ies_dep_cred,
       cod_banco          LIKE fornecedor.cod_banco,
       cod_agencia        LIKE fornecedor.num_agencia,
       num_conta_banco    LIKE fornecedor.num_conta_banco,
       branco_1           CHAR(02),
       branco_2           CHAR(02),
       branco_3           CHAR(02),
       branco_4           CHAR(02),
       branco_5           CHAR(02),
       branco_6           CHAR(02),
       dat_inclusao       DATE              
END RECORD

DEFINE m_result           SMALLINT, 
       m_mensa            VARCHAR(120), 
       m_num_ad           INTEGER, 
       m_num_ap           INTEGER,
       m_cod_cc           INTEGER,
       m_qtd_erro         INTEGER,
       m_funcio_id        VARCHAR(15), 
       m_relat_key        VARCHAR(15),
       m_relat_key_ant    VARCHAR(15),
       m_cod_tip_despesa  INTEGER,
       m_val_ad           DECIMAL(12,2)
       
DEFINE ma_erros          ARRAY[500] OF RECORD
       cod_empresa       CHAR(02),
       funcio_id         VARCHAR(15),      
       relat_key         VARCHAR(15),          
       tip_desp          VARCHAR(15),              
       cent_cust         VARCHAR(15),          
       erro              VARCHAR(120)
END RECORD

#-----------------#
FUNCTION pol1393()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1393-12.00.11  "
   CALL func002_versao_prg(p_versao)

   IF pol1393_atu_titulos() THEN
      CALL pol1393_menu()
   END IF
    
END FUNCTION

#-----------------------------#
FUNCTION pol1393_atu_titulos()#
#-----------------------------#

   UPDATE itens_concur
      SET num_ad = NULL,
          num_ap = NULL
    WHERE cod_empresa = p_cod_empresa
      AND num_ad IS NOT NULL
      AND num_ad NOT IN (SELECT num_ad FROM ad_mestre
          WHERE cod_empresa_orig = p_cod_empresa)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','itens_concur')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION         
       
#----------------------#
FUNCTION pol1393_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_proces      VARCHAR(10),
           l_carga       VARCHAR(10),
           l_find        VARCHAR(10),
           l_fechar      VARCHAR(10),
           l_titulo      VARCHAR(100),
           l_erro        VARCHAR(100),
           l_first       VARCHAR(10),
           l_previous    VARCHAR(10),
           l_next        VARCHAR(10),
           l_last        VARCHAR(10),
           l_print       VARCHAR(10)

    LET l_titulo = "GERAÇÃO DE TÍTULOS - INTEGRAÇÃO CONCUR - ",p_versao
    
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
    CALL _ADVPL_set_property(l_carga,"EVENT","pol1393_carga_informar")
    CALL _ADVPL_set_property(l_carga,"CONFIRM_EVENT","pol1393_carga_info_conf")
    CALL _ADVPL_set_property(l_carga,"CANCEL_EVENT","pol1393_carga_info_canc")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Proessa a carga do arquivo")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1393_processar")

    LET l_erro = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_erro,"IMAGE","ZOOM_ERROS")     
    CALL _ADVPL_set_property(l_erro,"TYPE","NOCONFIRM")     
    CALL _ADVPL_set_property(l_erro,"TOOLTIP","Consultar erros")
    CALL _ADVPL_set_property(l_erro,"EVENT","pol1393_erros")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    #CALL _ADVPL_set_property(l_fechar,"EVENT","pol1393_fechar")

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1393_cria_campos(l_panel)
   CALL pol1393_cria_grade(l_panel)

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1393_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)

    LET m_pnl_info = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pnl_info,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pnl_info,"HEIGHT",40)
    #CALL _ADVPL_set_property(m_pnl_info,"ENABLE",FALSE)
    CALL _ADVPL_set_property(m_pnl_info,"BACKGROUND_COLOR",231,237,237)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_arquivo = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pnl_info)     
    CALL _ADVPL_set_property(m_arquivo,"POSITION",70,10)     
    CALL _ADVPL_set_property(m_arquivo,"ADD_ITEM","0","Select    ")
    CALL _ADVPL_set_property(m_arquivo,"ENABLE",FALSE)
    CALL _ADVPL_set_property(m_arquivo,"VARIABLE",mr_cabec,"nom_arquivo")

    LET m_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(m_label,"POSITION",580,10) 
    CALL _ADVPL_set_property(m_label,"FOREGROUND_COLOR",237,28,36)
    CALL _ADVPL_set_property(m_label,"TEXT","")    
    CALL _ADVPL_set_property(m_label,"FONT",NULL,NULL,TRUE,FALSE)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1393_cria_grade(l_container)#
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
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Per")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pessoal")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Funcionário")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",160)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","funcionario")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Identif")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","funcio_id")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Relatorio")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","relat_key")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Empresa")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","empresa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Despesa")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","despesa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Moeda")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","moeda")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tp Desp")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","tip_desp")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",140)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_desp")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cent cust")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cent_cust")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Status")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","situacao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dt emis")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_emissao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dt pgto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_pagto")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tip pgto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","tip_pgto")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Num AD")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ad")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Num AP")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ap")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#--------------------------------#
FUNCTION pol1393_carga_informar()#
#--------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL _ADVPL_set_property(m_label,"TEXT","")
   LET m_ies_print = FALSE
   
   IF NOT pol1393_atu_titulos() THEN
      RETURN FALSE
   END IF
   
   LET m_ies_carga = FALSE
   LET m_ies_info = FALSE
   
   IF NOT pol1393_le_caminho() THEN
      RETURN FALSE
   END IF
   
   CALL pol1393_limpa_campos()
   LET m_carregando = FALSE
   
   IF NOT pol1393_carrega_lista() THEN
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_arquivo,"ENABLE",TRUE) 
   CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1393_le_caminho()#
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
         CALL log003_err_sql("SELECT","path_logix_v2:CSV")
         RETURN FALSE
      END IF
   END IF
   
   IF NOT pol1393_dirExist(m_caminho) THEN
      RETURN FALSE
   END IF
   
   SELECT nom_caminho
     INTO m_caminho_pro
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "PRO"

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema PRO não cadastrado na LOG1100.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("SELECT","path_logix_v2:PRO")
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1393_dirExist(m_caminho_pro) THEN
      RETURN FALSE
   END IF

   SELECT nom_caminho
     INTO m_caminho_pgi
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "PGI"

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema PGI não cadastrado na LOG1100.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("SELECT","path_logix_v2:PGI")
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1393_dirExist(m_caminho_pgi) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1393_dirExist(l_dir)#
#-------------------------------#

  DEFINE l_dir  CHAR(250),
         l_msg  CHAR(250)
 
  LET l_dir = l_dir CLIPPED
 
  IF NOT LOG_dir_exist(l_dir,0) THEN
     IF NOT LOG_dir_exist(l_dir,1) THEN
        LET l_msg = "Diretório não existe:\n ",l_dir
        CALL log0030_mensagem(l_msg,'info')
        RETURN FALSE
     END IF     
  END IF
  
  RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1393_limpa_campos()#
#------------------------------#
   
   LET m_carregando = TRUE
   INITIALIZE mr_cabec.*, ma_itens TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   LET m_qtd_reg = NULL
   LET m_ies_erro = FALSE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1393_carrega_lista()#
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
      IF m_qtd_arq > 150 THEN
         LET m_msg = 'Arquivos previstos na pasta: 150 - ',
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
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1393_carga_info_canc()#
#---------------------------------#

   CALL pol1393_limpa_campos()
  CALL _ADVPL_set_property(m_arquivo,"ENABLE",FALSE) 
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1393_carga_info_conf()#
#---------------------------------#
   
   DEFINE l_status        SMALLINT,
          l_data          CHAR(10),
          l_hora          CHAR(06)

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_cabec.nom_arquivo = "0" THEN
      LET m_msg = 'Selecione um arquivo para carga.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET m_count = mr_cabec.nom_arquivo
   LET m_arq_origem = ma_files[m_count] CLIPPED   
   LET m_nom_arquivo = m_arq_origem[m_posi_arq, LENGTH(m_arq_origem)]
   LET m_arq_gravar = m_nom_arquivo
   LET m_dat_atu = TODAY
   LET m_hor_atu = TIME
   LET l_data = EXTEND(m_dat_atu, YEAR TO DAY)
   LET l_hora = m_hor_atu[1,2],m_hor_atu[4,5],m_hor_atu[7,8]
   LET m_nom_arquivo = 'concur',l_data,'-',l_hora CLIPPED
   LET m_arq_convert  = m_caminho_pro CLIPPED, m_nom_arquivo CLIPPED
   LET m_arq_renomeado = m_arq_convert CLIPPED,'.csv'
   LET m_nom_arquivo = m_nom_arquivo CLIPPED,'.csv'
   LET m_arq_convert = m_arq_convert CLIPPED,'.txt'

   IF NOT LOG_file_copy(m_arq_origem,m_arq_renomeado,1,0) THEN
      LET m_msg = 'Erro ao copiar arquivo para\n ',m_arq_renomeado
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE      
   END IF

   LET p_status = LOG_progresspopup_start(
       "Integração com PGI...","pol1393_integ_delphi","PROCESS")  
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   #IF NOT pol1393_le_por_linha() THEN
   #   RETURN FALSE
   #END IF
      
   IF NOT pol1393_carga_arquivo() THEN
      RETURN FALSE
   END IF
            
   LET m_carregando = TRUE

   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1393_le_itens","PROCESS")  
   
   LET m_carregando = FALSE

   IF NOT p_status THEN
      CALL pol1393_carga_info_canc() RETURNING l_status
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_arquivo,"ENABLE",FALSE)
   LET m_ies_carga = TRUE
   LET m_msg = 'Qtd reg: ', m_qtd_item USING '<<<<<<'
   
   CALL _ADVPL_set_property(m_label,"TEXT",m_msg)
   
   RETURN TRUE   
    
END FUNCTION

#-------------------------------#
FUNCTION pol1393_carga_arquivo()#
#-------------------------------#

   IF NOT pol1393_cria_temp() THEN
      RETURN FALSE
   END IF
           
   CALL LOG_transaction_begin()
      
   LOAD FROM m_arq_convert 
     INSERT INTO w_arq_temp(linha)

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('LOAD','w_arq_temp:LOAD')
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   SELECT COUNT(*) INTO m_count
     FROM w_arq_temp
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("SELECT','w_arq_temp:count")
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'O arquivo selecionado está vazio.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1393_cria_temp()#
#---------------------------#
   
   DROP TABLE w_arq_temp
   
   CREATE  TABLE w_arq_temp (
      linha	     varchar(250)      
   )
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','w_arq_temp')
      RETURN FALSE
   END IF
     
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1393_le_por_linha()#
#------------------------------#

  DEFINE l_handle_r    SMALLINT,
         l_text        CHAR(1000),
         l_file_w      VARCHAR(250),
         l_handle_w    SMALLINT         
    
    
  LET l_handle_r = LOG_file_open(m_arq_origem,0)

  LET l_file_w = m_caminho_pro CLIPPED, 'ivo.txt'
  LET l_handle_w = LOG_file_openMode(l_file_w,0,1)

  CALL log0030_mensagem(m_arq_origem,'info')
  CALL log0030_mensagem(l_file_w,'info')
  
  IF l_handle_r >= 0 AND l_handle_w >= 0 THEN
     LET l_text = LOG_file_readln(l_handle_r)
     WHILE l_text IS NOT NULL
        LET l_text = LOG_file_readln(l_handle_r)        
        IF NOT LOG_file_write(l_handle_w,l_text) THEN
           LET m_msg = 'Erro ao gravar no arquivo\n ',m_arq_convert
           CALL log0030_mensagem(m_msg,'info')
           RETURN FALSE
        END IF
     END WHILE
     LET l_handle_r = LOG_file_close(l_handle_r)
     LET l_handle_w = LOG_file_close(l_handle_w)
  ELSE
     LET m_msg = 'Erro na abetura do arquivo\n de leitura e/ou escrita'
     CALL log0030_mensagem(m_msg,'info')
     RETURN FALSE
  END IF
  
  RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1393_integ_delphi()#
#------------------------------#

   DEFINE l_param         VARCHAR(200),
          p_comando       VARCHAR(300),
          l_proces        CHAR(01),
          l_carac         CHAR(01),
          l_file          CHAR(250),
          l_tenta         INTEGER,
          l_progres       SMALLINT        
   
   LET l_file = m_caminho_pgi CLIPPED, 'pgi1393.exe'
  
   IF NOT LOG_file_exist(l_file,0) THEN
     IF NOT LOG_file_exist(l_file,1) THEN
        LET m_msg = "Arquivo não encontrado ", l_file CLIPPED
        CALL log0030_mensagem(m_msg,'info')
        RETURN FALSE
     END IF
   END IF
      
   LET l_param = m_arq_renomeado,' ',m_arq_convert         
   LET p_comando = m_caminho_pgi CLIPPED, 'pgi1393.exe ' , l_param 
     
   CALL conout(p_comando)      
      
   #CALL runOnClient(p_comando)    
   CALL LOG_RunOnServer(p_comando)   
   
   CALL LOG_progresspopup_set_total("PROCESS",30)
   
   LET l_tenta = 0
   LET l_proces = 'S'
   
   WHILE l_proces = 'S'
       
       LET l_tenta = l_tenta + 1
       
       IF l_tenta > 30 THEN
          LET m_msg = "Não foi possivel a comunicação com PGI1393. Verifique\n ",
                      "local/existência do arquivo e tente mais tarde. "
          CALL log0030_mensagem(m_msg,'info')
          RETURN FALSE
       END IF
       
       SLEEP 1
       
       LET l_progres = LOG_progresspopup_increment("PROCESS")
       
       IF LOG_file_exist(m_arq_convert,0) THEN
          LET l_proces = 'N'
       END IF

       IF LOG_file_exist(m_arq_convert,1) THEN
          LET l_proces = 'N'
       END IF
       
   END WHILE    
  
   RETURN TRUE      

END FUNCTION   


#--------------------------#
FUNCTION pol1393_le_itens()#
#--------------------------#
   
   DEFINE l_nome, 
          l_sobre_nome  VARCHAR(30),
          l_tamanho     INTEGER
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   
   LET m_ind = 0
   
   DECLARE cq_temp CURSOR FOR
   SELECT linha 
     FROM w_arq_temp
   
   FOREACH cq_temp INTO m_linha
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','w_arq_temp:cq_temp')
         RETURN FALSE
      END IF

      LET m_progres = LOG_progresspopup_increment("PROCESS")
      
      IF m_linha[1,4] = 'Memo' OR m_linha[1,4] = 'Pers'THEN
         CONTINUE FOREACH
      END IF
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 2000 THEN
         LET m_msg = 'Limite previsto de itens ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF

      LET m_pos_ini = 1
      LET ma_itens[m_ind].cod_empresa = p_cod_empresa
      LET ma_itens[m_ind].pessoal = pol1393_divide_texto()
      LET m_pos_ini = m_pos_ini + 1
      LET l_nome = pol1393_divide_texto()
      LET l_sobre_nome = pol1393_divide_texto()
      LET l_tamanho = LENGTH(l_sobre_nome) - 1
      LET l_sobre_nome = l_sobre_nome[1,l_tamanho]
      LET ma_itens[m_ind].funcionario =  l_nome CLIPPED,',',l_sobre_nome
      LET ma_itens[m_ind].funcio_id = pol1393_divide_texto()

      LET ma_itens[m_ind].relat_key = pol1393_divide_texto()
      LET ma_itens[m_ind].empresa = pol1393_divide_texto()
      LET ma_itens[m_ind].despesa = pol1393_divide_texto()
      LET ma_itens[m_ind].moeda = pol1393_divide_texto()
      LET ma_itens[m_ind].tip_desp = pol1393_divide_texto()
      LET ma_itens[m_ind].den_desp = pol1393_divide_texto()
      LET ma_itens[m_ind].cent_cust = pol1393_divide_texto()
      LET ma_itens[m_ind].situacao = pol1393_divide_texto()
      LET ma_itens[m_ind].dat_emissao = pol1393_divide_texto()
      LET ma_itens[m_ind].dat_pagto = pol1393_divide_texto()
      LET ma_itens[m_ind].tip_pgto = pol1393_divide_texto()
      
      INITIALIZE m_num_ad, m_num_ad TO NULL
      
      SELECT DISTINCT num_ad, num_ap 
        INTO m_num_ad, m_num_ap
        FROM itens_concur 
       WHERE cod_empresa = p_cod_empresa
         AND funcio_id = ma_itens[m_ind].funcio_id
         AND relat_key = ma_itens[m_ind].relat_key
         AND tip_desp = ma_itens[m_ind].tip_desp
         AND num_ad IS NOT NULL
      
      IF m_num_ad IS NOT NULL THEN
         LET ma_itens[m_ind].num_ad = m_num_ad
         LET ma_itens[m_ind].num_ap = m_num_ap
      END IF
      
   END FOREACH      

   LET m_qtd_item = m_ind 
   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_item)
   LET m_qtd_reg = m_qtd_item
   LET m_ies_print = TRUE
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1393_divide_texto()#
#------------------------------#
   
   DEFINE l_ind        INTEGER,
          l_conteudo   CHAR(20)
                   
   FOR l_ind = m_pos_ini TO LENGTH(m_linha)
       IF m_linha[l_ind] = ',' THEN
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

#---------------------------#
FUNCTION pol1393_processar()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT m_ies_carga THEN
      LET m_msg = 'Selecione previamente um arquivo.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET m_ies_erro = FALSE

   CALL LOG_transaction_begin()
   
   LET p_status = LOG_progresspopup_start(
       "Consistindo dados...","pol1393_consiste","PROCESS")  
   
   IF NOT p_status THEN
      CALL LOG_transaction_rollback()
   ELSE
      CALL LOG_transaction_commit()
   END IF
   
   IF m_ies_erro THEN
      LET m_msg = 'Algumas inconsistências foram\n',
                  'detectadas.Consulte os erros.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   IF m_qtd_ad = m_qtd_item THEN
      LET m_msg = 'Todos os registros já possuem titulos'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   ELSE
      IF m_qtd_ad > 0 THEN
         LET m_msg = 'Alguns registros já possuem titulos.\n',
                     'Gerar titulos para os que não possuem?'
         IF NOT LOG_question(m_msg) THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   CALL LOG_transaction_begin()

   LET p_status = LOG_progresspopup_start(
       "Gerando títulos...","pol1393_gera_titulo","PROCESS")  

   IF NOT p_status THEN
      CALL LOG_transaction_rollback()
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Operação cancelada')
   ELSE
      CALL LOG_transaction_commit()
      LET m_ies_carga = FALSE
      LET m_msg = 'Titulos gerados com sucesso.\n Efetue a pesquisa.'
      CALL log0030_mensagem(m_msg,'info')
      LET p_status = LOG_progresspopup_start(
          "Lendo dados...","pol1393_exibe_dados","PROCESS")  
   END IF
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1393_consiste()#
#--------------------------#

   DEFINE l_progres  SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",m_qtd_item)
   
   DELETE FROM erro_concur
   LET m_qtd_ad = 0
   
   FOR m_ind = 1 TO m_qtd_item
      LET l_progres = LOG_progresspopup_increment("PROCESS") 
      IF NOT pol1393_checa_dados() THEN
         RETURN FALSE
      END IF
   END FOR
         
   LET l_progres = LOG_progresspopup_increment("PROCESS") 

   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1393_checa_dados()#
#-----------------------------#

   IF ma_itens[m_ind].num_ad IS NOT NULL THEN
      LET m_qtd_ad = m_qtd_ad + 1
   END IF 

   SELECT cod_fornecedor
     INTO mr_titulo.cod_fornecedor
     FROM func_fornec_concur
    WHERE cod_empresa = p_cod_empresa
      AND funcio_id = ma_itens[m_ind].funcio_id
   
   IF STATUS = 100 THEN
      LET m_msg = 'Funcionário não cadastrado no POL1392'
      IF NOT pol1393_ins_erro() THEN
         RETURN FALSE
      END IF
   END IF

   SELECT cod_cc_logix
     INTO m_cod_cc
     FROM cent_cust_concur
    WHERE cod_empresa = p_cod_empresa
      AND cod_cc_concor = ma_itens[m_ind].cent_cust
   
   IF STATUS = 100 THEN
      LET m_msg = 'Centro de custo não cadastrado no POL1392'
      IF NOT pol1393_ins_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   SELECT tip_desp_logix
     INTO mr_titulo.cod_tip_despesa
     FROM tip_desp_concur
    WHERE cod_empresa = p_cod_empresa
      AND tip_desp_concur = ma_itens[m_ind].tip_desp
   
   IF STATUS = 100 THEN
      LET m_msg = 'Tipo de despesa não cadastrado no POL1392'
      IF NOT pol1393_ins_erro() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1393_ins_erro()#
#--------------------------#

   INSERT INTO erro_concur
    VALUES(p_cod_empresa,
       ma_itens[m_ind].funcio_id,
       ma_itens[m_ind].relat_key,
       ma_itens[m_ind].tip_desp,
       ma_itens[m_ind].cent_cust,
       m_msg)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT', 'erro_concur')
      RETURN FALSE
   END IF
   
   LET m_ies_erro = TRUE
   
   RETURN TRUE

END FUNCTION      

#-----------------------#   
FUNCTION pol1393_erros()#
#-----------------------#

   DEFINE l_dialog     VARCHAR(10),
          l_panel      VARCHAR(10),
          l_layout     VARCHAR(10),
          l_tabcolumn  VARCHAR(10)
   
   IF NOT m_ies_erro THEN
      LET m_msg = 'Não há erros a exibir.'
      CALL log0030_mensagem(m_msg, 'info')
      RETURN
   END IF
   
    LET l_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(l_dialog,"SIZE",1200,400) 
    CALL _ADVPL_set_property(l_dialog,"TITLE","ERROS DETECTADOS")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) 

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    
    LET m_brz_erro = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_erro,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_erro)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Funcionário")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","funcio_id")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_erro)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Relat")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","relat_key")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_erro)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tip desp")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","tip_desp")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_erro)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cent custo")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cent_cust")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_erro)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","erro")
    
    CALL pol1393_le_erros()
    
    CALL _ADVPL_set_property(m_brz_erro,"SET_ROWS",ma_erros,m_qtd_erro)
    CALL _ADVPL_set_property(m_brz_erro,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_erro,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_erro,"EDITABLE",FALSE)

   CALL _ADVPL_set_property(l_dialog,"ACTIVATE",TRUE)

END FUNCTION

#--------------------------#   
FUNCTION pol1393_le_erros()#
#--------------------------#
   
   INITIALIZE ma_erros TO NULL
   LET m_qtd_erro = 1
   
   DECLARE cq_erros CURSOR FOR
    SELECT * FROM erro_concur
   FOREACH cq_erros INTO ma_erros[m_qtd_erro].*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','erro_concur:cq_erros')
         EXIT FOREACH
      END IF
      
      LET m_qtd_erro = m_qtd_erro + 1
      
      IF m_qtd_erro > 500 THEN
         LET m_msg = 'Limite de linhas da grade ultrapaoou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET m_qtd_erro = m_qtd_erro - 1
   
END FUNCTION
    
#-----------------------------#
FUNCTION pol1393_gera_titulo()#
#-----------------------------#

   DEFINE l_progres  SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",m_qtd_item)
   LET l_progres = LOG_progresspopup_increment("PROCESS") 

   IF NOT pol1393_ins_capa() THEN
      RETURN FALSE
   END IF
   
   FOR m_ind = 1 TO m_qtd_item
      IF NOT pol1393_ins_item() THEN
         RETURN FALSE
      END IF
   END FOR  

   SELECT par_ies
     INTO m_ctrl_aen
     FROM par_cap_pad
    WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_area_linha_neg"

   IF STATUS <> 0 OR m_ctrl_aen IS NULL THEN
      LET m_ctrl_aen = 'N'
   END IF
   
   IF m_ctrl_aen = 'N' THEN
   ELSE
      IF NOT pol1393_atu_par_cap_pad('N') THEN
         RETURN FALSE
      END IF
   END IF
   
   SELECT ies_contab_aen
     INTO m_ctrl_con
     FROM par_con  
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 OR m_ctrl_con IS NULL THEN
      LET m_ctrl_con = 'N'
   END IF
   
   IF m_ctrl_con = 'N' THEN
   ELSE
      IF NOT pol1393_atu_par_con('N') THEN
         RETURN FALSE
      END IF
   END IF
   
   LET l_progres = LOG_progresspopup_increment("PROCESS") 
   LET m_relat_key_ant = NULL

   DECLARE cq_agrupa CURSOR FOR
    SELECT funcio_id, 
           relat_key, 
           cod_tip_despesa, 
           SUM(despesa) 
      FROM itens_concur
     WHERE cod_empresa = p_cod_empresa
       AND id_arquivo = m_id_arquivo
       AND num_ad IS NULL
     GROUP BY funcio_id, relat_key, cod_tip_despesa  
     ORDER BY funcio_id, relat_key, cod_tip_despesa

   FOREACH cq_agrupa 
      INTO m_funcio_id, 
           m_relat_key, 
           m_cod_tip_despesa, 
           m_val_ad  
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT', 'itens_concur:cq_agrupa')
         RETURN FALSE
      END IF

      SELECT DISTINCT cent_cust 
        INTO m_cent_cust
        FROM itens_concur 
       WHERE cod_empresa = p_cod_empresa
         AND id_arquivo = m_id_arquivo
         AND funcio_id = m_funcio_id 
         AND relat_key = m_relat_key
         AND cod_tip_despesa = m_cod_tip_despesa

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT', 'itens_concur:cq_agrupa')
         RETURN FALSE
      END IF
      
      IF m_relat_key_ant IS NULL THEN
         LET m_ssr_nf = 0
      ELSE
         IF m_relat_key_ant = m_relat_key THEN
            LET m_ssr_nf = m_ssr_nf + 1
         ELSE
            LET m_ssr_nf = 0
         END IF
      END IF
      
      LET m_relat_key_ant = m_relat_key
      
      IF NOT POL1393_exec_cap() THEN
         RETURN FALSE
      END IF
      
   END FOREACH

   IF m_ctrl_aen = 'N' THEN
   ELSE
      IF NOT pol1393_atu_par_cap_pad(m_ctrl_aen) THEN
         RETURN FALSE
      END IF
   END IF

   IF m_ctrl_con = 'N' THEN
   ELSE
      IF NOT pol1393_atu_par_con(m_ctrl_con) THEN
         RETURN FALSE
      END IF
   END IF

   LET mr_cabec.dat_carga = m_dat_atu
   LET mr_cabec.hor_carga = m_hor_atu
   LET mr_cabec.id_arquivo = m_id_arquivo

   IF NOT pol1393_move_arquivo() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION   

#------------------------------------------#
FUNCTION pol1393_atu_par_cap_pad(l_par_ies)#
#------------------------------------------#

   DEFINE l_par_ies     CHAR(01)
   
   UPDATE par_cap_pad SET par_ies = l_par_ies
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = "ies_area_linha_neg"

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','par_cap_pad')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION            

#--------------------------------------#
FUNCTION pol1393_atu_par_con(l_par_ies)#
#--------------------------------------#

   DEFINE l_par_ies     CHAR(01)

   SELECT ies_contab_aen
     INTO m_ctrl_con
     FROM par_con  
    WHERE cod_empresa = p_cod_empresa

   
   UPDATE par_con SET ies_contab_aen = l_par_ies
    WHERE cod_empresa   = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','par_con')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION            

#------------------------------#
FUNCTION pol1393_move_arquivo()#
#------------------------------#
   
   DEFINE l_arq_dest       CHAR(100),
          l_comando        CHAR(120),
          l_tamanho        integer
   
   LET m_arq_origem = m_arq_origem CLIPPED
   
   LET l_tamanho = LENGTH(m_arq_origem)
   
   LET l_arq_dest = m_arq_origem[1,(l_tamanho-4)],'.prc'
     
   IF m_ies_ambiente = 'W' THEN
      LET l_comando = 'move ', m_arq_origem CLIPPED, ' ', l_arq_dest
   ELSE
      LET l_comando = 'mv ', m_arq_origem CLIPPED, ' ', l_arq_dest
   END IF

   IF NOT LOG_file_move( m_arq_origem ,l_arq_dest , 0) THEN
      IF NOT LOG_file_copy( m_arq_origem ,l_arq_dest , 0) THEN
 
         RUN l_comando RETURNING p_status
   
         IF p_status = 1 THEN
            LET m_msg = 'Não foi possivel renomear o arquivo de .csv para .prc'
            CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         END IF
      
      END IF
      
   END IF
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1393_ins_capa()#
#--------------------------#   

   SELECT MAX(id_arquivo)
     INTO m_id_arquivo
     FROM arquivo_concur

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','arquivo_concur')
      RETURN FALSE
   END IF
   
   IF m_id_arquivo IS NULL THEN
      LET m_id_arquivo = 0
   END IF
   
   LET m_id_arquivo = m_id_arquivo + 1
   
   INSERT INTO arquivo_concur
    VALUES(p_cod_empresa,
           m_id_arquivo,
           m_arq_gravar,
           m_dat_atu,
           m_hor_atu,
           p_user)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','arquivo_concur')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION       

#--------------------------#
FUNCTION pol1393_ins_item()#
#--------------------------#   
   
   DEFINE l_tip_desp     LIKE ad_mestre.cod_tip_despesa
   
   SELECT tip_desp_logix
     INTO l_tip_desp
     FROM tip_desp_concur
    WHERE cod_empresa = p_cod_empresa
      AND tip_desp_concur = ma_itens[m_ind].tip_desp
   
   IF STATUS = 100 THEN
      CALL log003_err_sql('SELECT','tip_desp_concur')
      RETURN FALSE
   END IF

   INSERT INTO itens_concur
    VALUES(p_cod_empresa,
           m_id_arquivo,
           ma_itens[m_ind].pessoal,  
           ma_itens[m_ind].funcionario, 
           ma_itens[m_ind].funcio_id,   
           ma_itens[m_ind].relat_key,   
           ma_itens[m_ind].empresa,     
           ma_itens[m_ind].despesa,     
           ma_itens[m_ind].moeda,       
           ma_itens[m_ind].tip_desp,    
           ma_itens[m_ind].den_desp,    
           ma_itens[m_ind].cent_cust,   
           ma_itens[m_ind].situacao,    
           ma_itens[m_ind].dat_emissao, 
           ma_itens[m_ind].dat_pagto,   
           ma_itens[m_ind].tip_pgto,    
           ma_itens[m_ind].num_ad,      
           ma_itens[m_ind].num_ap,      
           l_tip_desp)

   IF STATUS = 100 THEN
      CALL log003_err_sql('SELECT','itens_concur')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#   
FUNCTION POL1393_exec_cap()#
#--------------------------#
   
   DEFINE l_dia       INTEGER,
          l_dif       INTEGER,
          l_data      DATE,
          l_cod_cc    INTEGER,
          l_tamanho   INTEGER
          
   DEFINE l_num_conta LIKE lanc_cont_cap.num_conta_cont,
          l_new_cont  LIKE lanc_cont_cap.num_conta_cont

       
   INITIALIZE mr_titulo TO NULL
   
   LET mr_titulo.ies_sup_cap = 'C'
   LET mr_titulo.cod_tip_despesa = m_cod_tip_despesa
   LET mr_titulo.num_nf = m_relat_key
   LET mr_titulo.ssr_nf = m_ssr_nf
   
   SELECT cod_fornecedor
     INTO mr_titulo.cod_fornecedor
     FROM func_fornec_concur
    WHERE cod_empresa = p_cod_empresa
      AND funcio_id = m_funcio_id
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','func_fornec_concur:sc')
      RETURN FALSE
   END IF

      SELECT num_ad  
        INTO m_num_ad
        FROM ad_mestre
       WHERE cod_empresa_orig = p_cod_empresa
         AND num_nf = m_relat_key
         AND ser_nf  IS NULL
         AND ssr_nf = m_ssr_nf
         AND cod_fornecedor = mr_titulo.cod_fornecedor

      IF STATUS = 100 THEN
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT', 'ad_mestre:cq_agrupa')
            RETURN FALSE
         END IF
         LET m_msg = 'Funcionário ', m_funcio_id CLIPPED,'\n',
                     'Relarório ', m_relat_key CLIPPED,'\n',
                     'Já possui a AD ', m_num_ad USING '<<<<<<'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE         
      END IF
   
   LET mr_titulo.val_total = m_val_ad
   LET mr_titulo.observ = 'INCLUSAO VIA POL1393'

   SELECT cod_banco, 
          num_agencia, 
          num_conta_banco, 
          ies_dep_cred
     INTO mr_titulo.cod_banco, 
          mr_titulo.cod_agencia, 
          mr_titulo.num_conta_banco,
          mr_titulo.ies_dep_cred 
     FROM fornecedor
    WHERE cod_fornecedor = mr_titulo.cod_fornecedor
 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','fornecedor')
      RETURN FALSE
   END IF
   
   LET l_data = TODAY + 5
   LET l_dia = WEEKDAY(l_data) 
   
   IF l_dia < 3 THEN
      LET l_dif = 3 - l_dia
      LET l_data = l_data + l_dif
   ELSE
      IF l_dia > 3 THEN
         LET l_dif = l_dia - 3
         LET l_dif = 7 - l_dif
         LET l_data = l_data + l_dif
      END IF
   END IF

   LET mr_titulo.dat_inclusao = TODAY
   LET mr_titulo.dat_vencto = l_data
    
   CALL cap309_gera_informacoes_cap(mr_titulo.*) 
      RETURNING m_result, m_mensa, m_num_ad, m_num_ap 
   
   IF NOT m_result THEN
      IF m_mensa IS NOT NULL THEN
         CALL log0030_mensagem(m_mensa,'info')
      END IF
      RETURN FALSE
   END IF
   
   IF m_ctrl_aen = 'N' THEN
   ELSE
      IF NOT pol1393_ins_ad_aen() THEN
         RETURN FALSE
      END IF
   END IF
      
   UPDATE itens_concur 
      SET num_ad = m_num_ad,
          num_ap = m_num_ap
    WHERE cod_empresa = p_cod_empresa
      AND id_arquivo = m_id_arquivo
      AND funcio_id = m_funcio_id
      AND cod_tip_despesa = m_cod_tip_despesa
      AND relat_key = m_relat_key

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','itens_concur')
      RETURN FALSE
   END IF

  SELECT num_conta_cont 
    INTO l_num_conta
    FROM lanc_cont_cap
   WHERE cod_empresa = p_cod_empresa
     AND num_ad_ap = m_num_ad
     AND ies_tipo_lanc = 'D'
   
   IF STATUS = 100 THEN
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','lanc_cont_cap')
         RETURN FALSE
      END IF
   END IF

   LET l_tamanho = LENGTH(l_num_conta)
   
   IF l_tamanho < 5 THEN
      RETURN TRUE
   END IF
   
   SELECT cod_cc_logix
     INTO l_cod_cc
     FROM cent_cust_concur
    WHERE cod_empresa = p_cod_empresa
      AND cod_cc_concor = m_cent_cust

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cent_cust_concur:2')
      RETURN FALSE
   END IF
   
   LET l_new_cont = l_cod_cc USING '<<<<'
   LET l_new_cont = l_new_cont CLIPPED, l_num_conta[5,l_tamanho]
   
   UPDATE ctb_lanc_ctbl_cap 
      SET cta_deb = l_new_cont
    WHERE empresa = p_cod_empresa
      AND num_ad_ap = m_num_ad 
      AND eh_ad_ap = '1' 
      AND cta_deb = l_num_conta

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ctb_lanc_ctbl_cap.cta_deb')
      RETURN FALSE
   END IF

   UPDATE lanc_cont_cap
      SET num_conta_cont = l_new_cont
    WHERE cod_empresa = p_cod_empresa
      AND num_ad_ap = m_num_ad
      AND ies_tipo_lanc = 'D'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','lanc_cont_cap.num_conta_cont')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1393_ins_ad_aen()#
#----------------------------#
   
   DEFINE l_cod_aen   CHAR(08),
          l_qtd_niv   CHAR(01)   
   DEFINE lr_ad_aen   RECORD LIKE ad_aen_4.*

   SELECT par_ies 
     INTO l_qtd_niv
     FROM par_cap_pad 
    WHERE cod_empresa = p_cod_empresa
      AND cod_parametro = 'ies_aen_2_4'

   IF STATUS = 100 THEN
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','par_cap_pad:2')
         RETURN FALSE
      END IF
   END IF
      
   SELECT cod_lin_prod,  
          cod_lin_recei, 
          cod_seg_merc,  
          cod_cla_uso   
     INTO lr_ad_aen.cod_lin_prod, 
          lr_ad_aen.cod_lin_recei,
          lr_ad_aen.cod_seg_merc, 
          lr_ad_aen.cod_cla_uso 
     FROM cent_cust_concur
    WHERE cod_empresa = p_cod_empresa
      AND cod_cc_concor = m_cent_cust

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cent_cust_concur:aen')
      RETURN FALSE
   END IF

   UPDATE ctb_lanc_ctbl_cap 
      SET linha_produto =  lr_ad_aen.cod_lin_prod, 
          linha_receita =  lr_ad_aen.cod_lin_recei,
          segmto_mercado = lr_ad_aen.cod_seg_merc, 
          classe_uso = lr_ad_aen.cod_cla_uso   
    WHERE empresa = p_cod_empresa
      AND num_ad_ap = m_num_ad 
      AND eh_ad_ap = '1' 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ctb_lanc_ctbl_cap.aen')
      RETURN FALSE
   END IF
   
   SELECT cod_empresa,
          val_tot_nf 
     INTO lr_ad_aen.cod_empresa,
          lr_ad_aen.val_aen
     FROM ad_mestre
    WHERE cod_empresa_orig = p_cod_empresa
      AND num_ad = m_num_ad

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ad_mestre:aen')
      RETURN FALSE
   END IF
     
   LET lr_ad_aen.num_ad = m_num_ad             

   IF l_qtd_niv = '2' THEN
      INSERT INTO ad_aen(
         cod_empresa, num_ad, val_item, cod_area_negocio, cod_lin_negocio)
       VALUES(lr_ad_aen.cod_empresa, m_num_ad, 
              lr_ad_aen.val_aen, lr_ad_aen.cod_lin_prod, lr_ad_aen.cod_lin_recei)
   ELSE
      INSERT INTO ad_aen_4 VALUES(lr_ad_aen.*)
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ad_aen e/ou ad_aen_4')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1393_exibe_dados()#
#-----------------------------#

   DEFINE l_progres   SMALLINT

   CALL LOG_progresspopup_set_total("PROCESS",m_qtd_item)
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   INITIALIZE ma_itens TO NULL
   
   SELECT id_arquivo, dat_carga, hor_carga
     INTO mr_cabec.id_arquivo,
          mr_cabec.dat_carga,
          mr_cabec.hor_carga
     FROM arquivo_concur
    WHERE id_arquivo = m_id_arquivo   

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','arquivo_concur:cq_exib')
   END IF

   LET m_ind = 1
   
   DECLARE cq_exib CURSOR FOR
   SELECT * 
     FROM itens_concur
    WHERE cod_empresa = p_cod_empresa
      AND id_arquivo = m_id_arquivo
   
   FOREACH cq_exib INTO ma_itens[m_ind].*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','itens_concur:cq_exib')
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 2000 THEN
         LET m_msg = 'Limite previsto de itens ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
   
   END FOREACH
   
   LET m_qtd_item = m_ind - 1 
   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_item)
   LET m_msg = 'Qtd reg: ', m_qtd_item USING '<<<<<<'
   CALL _ADVPL_set_property(m_label,"TEXT",m_msg)
   LET m_ies_print = TRUE
   
   RETURN TRUE

END FUNCTION

#LOG1700             
#-------------------------------#
 FUNCTION pol1393_version_info()
#-------------------------------#

  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/solicitacao de faturameto/programas/pol1393.4gl $|$Revision: 11 $|$Date: 21/08/2020 13:23 $|$Modtime: 26/06/2020 07:40 $" 

 END FUNCTION
