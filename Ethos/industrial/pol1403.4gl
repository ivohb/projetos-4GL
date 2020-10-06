#-------------------------------------------------------------------#
# PROGRAMA: pol1403                                                 #
# OBJETIVO: APURA��O DE DEMANDA E GERA��O DE ORDENS DE PRODU��O     #
# CLIENTE.: ETHOS IND                                               #
# DATA....: 27/07/2018                                              #
# DATA   ALTERA��O                                                  #
#                                                                   #
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
       m_arq_denam       VARCHAR(10)

DEFINE m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ind             INTEGER,
       m_lin_atu         INTEGER,
       m_nom_reduz       VARCHAR(15),
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
       m_hor_atu         CHAR(08)

DEFINE ma_files ARRAY[150] OF CHAR(100)

DEFINE mr_deman          RECORD
       cod_empresa       CHAR(02),
       nom_arquivo       VARCHAR(80)
END RECORD
                     
DEFINE ma_deman          ARRAY[12000] OF RECORD
       cod_cliente       CHAR(15),
       nom_reduzido      CHAR(15),
       num_pedido        CHAR(06),
       cod_item          CHAR(15),
       den_item_reduz    CHAR(18),
       prz_entrega       CHAR(10),
       estoque           CHAR(10),
       faturar           CHAR(10),
       abrir             CHAR(10),
       mensagem          VARCHAR(120)
END RECORD
         
             
#-----------------#
FUNCTION pol1403()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1403-12.00.00  "
   CALL func002_versao_prg(p_versao)
   CALL pol1403_teste()
   CALL pol1403_menu()

END FUNCTION

FUNCTION pol1403_teste()

DECLARE cq_teste cursor for
select CASE WHEN (x1.num_lanc IS NULL )  THEN '0' ::decimal(17,
    2)  ELSE x1.num_lanc  END ,x0.num_conta_reduz ,x0.cod_empresa 
    ,x1.num_conta ,x0.den_conta ,x1.den_sistema_ger ,x1.ies_sit_lanc 
    ,x1.ies_tip_lanc ,LEFT (x0.num_conta_reduz ,4 ),CASE WHEN 
    (x1.dat_movto ::date IS NULL )  THEN x7.parametro_dat  ELSE 
    x1.dat_movto ::date  END ,CASE WHEN (x1.per_contabil ::decimal(17,
    2) IS NULL )  THEN '1900' ::decimal(17,2)  ELSE x1.per_contabil 
    ::decimal(17,2)  END ,x1.cod_seg_periodo ,((TRIM ( BOTH ' '
     FROM x2.tex_hist ) || ' ' ) || TRIM ( BOTH ' ' FROM x3.tex_hist 
    ) ) ,((TRIM ( BOTH ' ' FROM x2.tex_hist ) || ' ' ) || TRIM 
    ( BOTH ' ' FROM x4.tex_hist ) ) ,((TRIM ( BOTH ' ' FROM x2.tex_hist 
    ) || ' ' ) || TRIM ( BOTH ' ' FROM x5.tex_hist ) ) ,CASE WHEN 
    (x1.val_lanc IS NULL )  THEN '0' ::decimal(17,2)  ELSE x1.val_lanc 
     END ,CASE WHEN (x6.val_debito_seg IS NULL )  THEN '0' ::decimal(17,
    2)  ELSE x6.val_debito_seg  END ,CASE WHEN ((x6.val_saldo_acum 
    * -1 ) ::decimal(17,2) IS NULL )  THEN '0' ::decimal(17,2) 
     ELSE (x6.val_saldo_acum * -1 ) ::decimal(17,2)  END from 
    (((((((plano_contas1 x0 left join lancamentos 
    x1 on ((x0.cod_empresa = x1.cod_empresa ) AND (x0.num_conta 
    = x1.num_conta ) ) )left join hist_padrao x2 on 
    (((x1.cod_empresa = x2.cod_empresa ) AND (x1.cod_hist = x2.cod_hist 
    ) ) AND (x1.ies_compl_hist = x2.ies_complemento ) ) )left 
    join hist_compl_1 x3 on ((((((x1.cod_empresa = 
    x3.cod_empresa ) AND (x1.den_sistema_ger = x3.den_sistema_ger 
    ) ) AND (x1.per_contabil = x3.per_contabil ) ) AND (x1.cod_seg_periodo 
    = x3.cod_seg_periodo ) ) AND (x1.num_lote = x3.num_lote ) 
    ) AND (x1.num_lanc = x3.num_lanc ) ) )left join 
    hist_compl_2 x4 on ((((((x1.cod_empresa = x4.cod_empresa 
    ) AND (x1.den_sistema_ger = x4.den_sistema_ger ) ) AND (x1.per_contabil 
    = x4.per_contabil ) ) AND (x1.cod_seg_periodo = x4.cod_seg_periodo 
    ) ) AND (x1.num_lote = x4.num_lote ) ) AND (x1.num_lanc = 
    x4.num_lanc ) ) )left join hist_compl_3 x5 on ((((((x1.cod_empresa 
    = x5.cod_empresa ) AND (x1.den_sistema_ger = x5.den_sistema_ger 
    ) ) AND (x1.per_contabil = x5.per_contabil ) ) AND (x1.cod_seg_periodo 
    = x5.cod_seg_periodo ) ) AND (x1.num_lote = x5.num_lote ) 
    ) AND (x1.num_lanc = x5.num_lanc ) ) )left join 
    saldos x6 on (((((x0.cod_empresa = x6.cod_empresa ) AND 
    (x0.num_conta = x6.num_conta ) ) AND (x1.per_contabil = x6.per_contabil 
    ) ) AND (x1.cod_seg_periodo = x6.cod_seg_periodo ) ) AND 
    (x6.cod_moeda = x1.cod_moeda ) ) )left join min_par_modulo 
    x7 on ((x7.empresa = x0.cod_empresa ) AND (x7.parametro = 
    'DATA_INICIO' ) ) )where (x0.cod_empresa IN ('06' ,'08' ));

FOREACH cq_teste  INTO m_msg

END FOREACH

END FUNCTION

#----------------------#
FUNCTION pol1403_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_import      VARCHAR(10),
           l_ordem       VARCHAR(10),
           l_titulo      CHAR(80)
    
    LET l_titulo = "APURA��O DE DEMANDA E GERA��O DE ORDENS DE PRODU��O - ",p_versao
    
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
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1403_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1403_info_conf")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1403_info_canc")

    LET l_import = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_import,"IMAGE","IMPORTAR_ARQUIVO")     
    CALL _ADVPL_set_property(l_import,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_import,"TOOLTIP","Iportar demanda de arquivo CSV")
    CALL _ADVPL_set_property(l_import,"EVENT","pol1403_deman_info")
    CALL _ADVPL_set_property(l_import,"CONFIRM_EVENT","pol1403_deman_conf")
    CALL _ADVPL_set_property(l_import,"CANCEL_EVENT","pol1403_deman_canc")

    LET l_ordem = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_ordem,"IMAGE","ORDENS") 
    CALL _ADVPL_set_property(l_ordem,"TOOLTIP","Gerar ordens de produ��o")
    CALL _ADVPL_set_property(l_ordem,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(l_ordem,"EVENT","pol1403_gerar")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1403_cabec(l_panel)
    CALL pol1403_item(l_panel)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------#
FUNCTION pol1403_cabec(l_container)#
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
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_deman,"cod_empresa")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",100,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_arq_denam = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pan_cabec)     
    CALL _ADVPL_set_property(m_arq_denam,"POSITION",160,10)     
    CALL _ADVPL_set_property(m_arq_denam,"ADD_ITEM","0","Select    ")
    CALL _ADVPL_set_property(m_arq_denam,"VARIABLE",mr_deman,"nom_arquivo")

END FUNCTION

#---------------------------------#
FUNCTION pol1403_item(l_container)#
#---------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET m_pan_item = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_item,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_pan_item,"ENABLE",FALSE)

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
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dat entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","prz_entrega")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Estoq")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","estoque")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Fat")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","faturar")
       
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Abrir")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","abrir")

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
FUNCTION pol1403_deman_info()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_ies_deman = FALSE
   
   IF NOT pol1403_le_caminho() THEN
      RETURN FALSE
   END IF
   
   CALL pol1403_limpa_deman()
   LET m_car_deman = FALSE

   IF NOT pol1403_dirExist() THEN
      RETURN FALSE
   END IF
      
   IF NOT pol1403_deman_lista() THEN
      RETURN FALSE
   END IF
   
   LET mr_deman.cod_empresa = p_cod_empresa
   CALL _ADVPL_set_property(m_pan_cabec,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_arq_denam,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1403_le_caminho()#
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
FUNCTION pol1403_dirExist()#
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
 FUNCTION pol1403_fileExist()#
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
FUNCTION pol1403_limpa_deman()#
#-----------------------------#
   
   LET m_car_deman = TRUE
   INITIALIZE mr_deman.* TO NULL
   CALL _ADVPL_set_property(m_brz_item,"CLEAR")
   
END FUNCTION

#-----------------------------#
FUNCTION pol1403_deman_lista()#
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
FUNCTION pol1403_deman_canc()#
#----------------------------#

   CALL pol1403_limpa_deman()
   CALL _ADVPL_set_property(m_pan_cabec,"ENABLE",FALSE)
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1403_deman_conf()#
#----------------------------#

   DEFINE l_status        SMALLINT
   
   IF NOT pol1403_deman_valid_arq() THEN
      RETURN FALSE
   END IF
   
   LET m_car_deman = TRUE

   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1403_deman_load_arq","PROCESS")  
   
   LET m_car_deman = FALSE

   IF NOT p_status THEN
      CALL pol1403_deman_canc() RETURNING l_status
      RETURN FALSE
   END IF
   
   LET m_ies_deman = TRUE

   IF m_qtd_erro > 0 THEN
      LET m_msg = 'Foram encontrados ',m_qtd_erro USING '<<<<', ' registos com erro'
   ELSE
      LET m_msg = 'Opera��o efetuada com sucesso'
   END IF
   
   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE   
    
END FUNCTION

#---------------------------------#
FUNCTION pol1403_deman_valid_arq()#
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
FUNCTION pol1403_deman_load_arq()#
#--------------------------------#
   
   DEFINE l_lista, l_moeda INTEGER,
          l_empresa        CHAR(02)
   
   IF NOT pol1403_deman_cria_temp() THEN
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
   
   IF NOT pol1403_exibe_deman() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1403_deman_cria_temp()#
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

#-----------------------------#
FUNCTION pol1403_exibe_deman()#
#-----------------------------#
   
   DEFINE l_progres     SMALLINT

   DEFINE l_parametro      RECORD
          cod_empresa      CHAR(02),
          cod_item         CHAR(15),
          cod_local        CHAR(10)
   END RECORD
   
   INITIALIZE ma_deman TO NULL
   CALL _ADVPL_set_property(m_brz_item,"CLEAR")
   CALL _ADVPL_set_property(m_brz_item,"CLEAR_ALL_LINE_FONT_COLOR")
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
      
      IF m_ind > 12000 THEN
         LET m_msg = 'Limite previsto de itens ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
      
      LET m_pos_ini = 1
      LET m_cliente = pol1403_divide_texto()      
      LET ma_deman[m_ind].cod_cliente = pol1403_pega_codigo()
      CALL pol1403_le_cliente(ma_deman[m_ind].cod_cliente)
      LET ma_deman[m_ind].nom_reduzido = m_nom_reduz
      LET ma_deman[m_ind].num_pedido = pol1403_divide_texto()   
      LET ma_deman[m_ind].cod_item = pol1403_divide_texto()   
      CALL pol1403_le_item(ma_deman[m_ind].cod_item)
      LET ma_deman[m_ind].den_item_reduz = m_den_reduz  
      LET ma_deman[m_ind].prz_entrega = pol1403_divide_texto()   
      LET ma_deman[m_ind].abrir = pol1403_divide_texto()   
      
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
         IF NOT pol1403_consist_pedido() THEN
            RETURN FALSE
         END IF
      END IF
      
      LET ma_deman[m_ind].mensagem = m_msg
      
      IF m_msg IS NOT NULL THEN
         LET m_qtd_erro = m_qtd_erro + 1
         CALL _ADVPL_set_property(m_brz_item,"LINE_FONT_COLOR",m_ind,255,0,0)
      ELSE
         CALL _ADVPL_set_property(m_brz_item,"LINE_FONT_COLOR",m_ind,0,0,0)
      END IF      
      
   END FOREACH

   LET m_qtd_deman = m_ind 
   CALL _ADVPL_set_property(m_brz_item,"ITEM_COUNT", m_qtd_deman)

   RETURN TRUE

END FUNCTION      

#------------------------------#
FUNCTION pol1403_divide_texto()#
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
FUNCTION pol1403_pega_codigo()#
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
FUNCTION pol1403_consist_pedido()#
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

   SELECT (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel )
     INTO ma_deman[m_ind].faturar
     FROM ped_itens
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = ma_deman[m_ind].num_pedido
      AND cod_item = ma_deman[m_ind].cod_item
      AND prz_entrega = l_data
   
   IF STATUS = 0 THEN
   ELSE
      LET ma_deman[m_ind].faturar = 0
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
FUNCTION pol1403_le_cliente(l_cod)#
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

#------------------------------#   
FUNCTION pol1403_le_item(l_cod)#
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