#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1419                                                 #
# OBJETIVO: CARGA DO EDI FORECAST  - USIMATIC (VDP6590/VDP1024)     #
# AUTOR...: IVO                                                     #
# DATA....: 27/01/21                                                #
#-------------------------------------------------------------------#

{
Forecast

1-	Qual carteira usar?
2-	Qual pre�o vamos usar na carga do Plano de vendas ?
}

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa  LIKE empresa.cod_empresa,
           p_user         LIKE usuarios.cod_usuario,
           p_status       SMALLINT,
           p_den_empresa  VARCHAR(36),
           p_versao       CHAR(18),
           g_msg          CHAR(150)
END GLOBALS

DEFINE m_caminho         CHAR(80),
       m_ies_ambiente    CHAR(01),
       m_comando         CHAR(100),
       m_nom_arquivo     CHAR(40),
       m_qtd_arq         INTEGER,
       m_posi_arq        INTEGER,
       m_id_arquivo      INTEGER,
       m_id_arquivoa     INTEGER,
       m_cod_cliente     CHAR(15),
       m_arq_origem      CHAR(100),
       m_ind             INTEGER,
       m_index           INTEGER,
       m_tem_erro        SMALLINT,
       m_qtd_erro        INTEGER,
       m_prz_entrega     DATE,
       m_qtd_entrega     DECIMAL(10,3),
       m_dat_abertura    DATE,
       m_ies_prog        CHAR(01),
       m_num_seq         INTEGER,
       m_operacao        VARCHAR(10),
       m_mensagem        VARCHAR(60),
       m_qtd_solic       DECIMAL(10,3),
       m_qtd_atual       DECIMAL(10,3),
       m_qtd_atend       DECIMAL(10,3),
       m_qtd_romaneio    DECIMAL(10,3),
       m_qtd_planej      DECIMAL(10,3),
       m_qtd_cancel      DECIMAL(10,3),
       m_qtd_oper        DECIMAL(10,3),
       m_linha           CHAR(300),
       m_qtd_item        INTEGER,
       m_ind_canc        INTEGER,
       m_qtd_prog        INTEGER,
       m_lin_atu         INTEGER,
       m_situacao        CHAR(01),
       m_item_cliente    CHAR(30),
       m_qtd_antes       DECIMAL(10,3),
       m_ind_print       INTEGER,
       m_page_length     INTEGER,
       m_ies_situa       CHAR(01),
       m_tip_prog        CHAR(01),
       m_ies_status      CHAR(01),
       m_num_ped_cli     VARCHAR(30),
       m_cod_item        VARCHAR(15),
       m_registro        VARCHAR(2000),
       m_pos_ini         INTEGER,
       m_pos_fim         INTEGER,
       m_per_firme       DECIMAL(3,0),
       m_excluiu         SMALLINT,
       m_cliticou        SMALLINT,
       m_qtd_planos      INTEGER,
       m_progres         SMALLINT,
       m_clik_cab        SMALLINT,
       m_ja_tem          SMALLINT,
       m_ies_origem      VARCHAR(01),
       m_opcao           VARCHAR(01),
       m_id_item         INTEGER,
       m_num_pc          VARCHAR(15),
       m_seq_pc          INTEGER,
       m_id_audit        INTEGER,
       m_dat_atu         DATE,
       m_hor_atu         VARCHAR(08),
       m_houve_erro      SMALLINT,
       m_pedido_comp     VARCHAR(17),
       m_dat_hor         VARCHAR(20),
       m_qtd_firme       INTEGER,
       m_qtd_prev        INTEGER,
       m_quant_plano     DECIMAL(10,3),
       m_preco_plano     DECIMAL(12,2)
       
DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_stat_prog       VARCHAR(10),
       m_stat_imp        VARCHAR(10),
       m_panel_cabec     VARCHAR(10),
       m_panel_item      VARCHAR(10),
       m_panel_prog      VARCHAR(10),
       m_brz_plano      VARCHAR(10),
       m_brz_prog        VARCHAR(10),
       m_form_proc       VARCHAR(10),
       m_form_print      VARCHAR(10),
       m_cli_imp         VARCHAR(10),
       m_arq_imp         VARCHAR(10),
       m_ped_imp         VARCHAR(10),
       m_dat_de          VARCHAR(10),
       m_dat_ate         VARCHAR(10),
       m_prz_de          VARCHAR(10),
       m_prz_ate         VARCHAR(10),
       m_per_de          VARCHAR(10),
       m_per_ate         VARCHAR(10)
       
DEFINE m_ies_info        VARCHAR(01),
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_car_plan         SMALLINT,
       m_ordenou         SMALLINT,
       m_num_id          INTEGER

DEFINE mr_arquivo        RECORD
       cod_empresa       CHAR(02),
       cod_cliente       VARCHAR(15),
       nom_cliente        CHAR(50),       
       per_firme         DECIMAL(3,0),
       dat_de            DATE,
       dat_ate           DATE,
       den_arquivo       CHAR(40),
       nom_arquivo       CHAR(100),
       dat_carga         VARCHAR(10),
       hor_carga         CHAR(08),
       processado        CHAR(01),
       tip_prog          CHAR(01),
       cod_tip_carteira  CHAR(02),
       mercado           CHAR(02),
       pais              CHAR(03)
END RECORD

DEFINE ma_data            ARRAY[100] OF RECORD
       dat_prog           VARCHAR(10),
       tip_prog           VARCHAR(08),
       qtd_prog           VARCHAR(12),
       erro               VARCHAR(40)
END RECORD       

DEFINE ma_files ARRAY[50] OF CHAR(100)

DEFINE ma_plano           ARRAY[2000] OF RECORD
   id_item                INTEGER,     
   cod_cliente            VARCHAR(15), 
   item_cliente           CHAR(15),    
   cod_item               CHAR(15),    
   ano_plano              DECIMAL(4,0),   
   mes_plano              DECIMAL(2,0),
   qtd_firme              DECIMAL(10,3),
   qtd_planej             DECIMAL(10,3),
   preco_plano            DECIMAL(12,2),
   preco_item             DECIMAL(12,2),
   carteira               VARCHAR(02),
   situacao               VARCHAR(01),      
   ies_origem             VARCHAR(01),
   ies_select             VARCHAR(01),
   mensagem               VARCHAR(120)  
END RECORD

DEFINE ma_prog            ARRAY[1000] OF RECORD
   ies_select             VARCHAR(01),
   id_arquivo             INTEGER,
   id_item                INTEGER,
   cod_item               VARCHAR(15),
   dat_prog               VARCHAR(10),
   qtd_prog               VARCHAR(12),
   tip_prog               VARCHAR(08),
   ano_plano              DECIMAL(4,0),
   mes_plano              DECIMAL(2,0),
   qtd_plano              DECIMAL(10,3),
   mensagem               VARCHAR(40),
   operacao               VARCHAR(15),
   qtd_plan_log           DECIMAL(10,3),
   pre_unit_log           DECIMAL(12,2)
END RECORD

DEFINE mr_itens          RECORD
   id_arquivo            INTEGER,
   id_item               INTEGER,
   linha_plano           INTEGER,       
   forec                 VARCHAR(15), 
   fornec                VARCHAR(15),
   cliente               VARCHAR(15),
   item                  VARCHAR(15),
   item_logix            VARCHAR(15),
   descricao             VARCHAR(76),
   revisao               VARCHAR(04),
   preco                 VARCHAR(12),
   vigencia              VARCHAR(10),
   unidade               VARCHAR(03),
   ipi                   VARCHAR(12),
   nf                    VARCHAR(10),
   clf                   VARCHAR(15),
   almox                 VARCHAR(15),
   local_almox           VARCHAR(15),
   ent_ac                VARCHAR(15),
   de_para               VARCHAR(15),
   atras                 VARCHAR(15),
   quatro_sem_1          VARCHAR(15),
   quatro_sem_2          VARCHAR(15),
   cod_it_fornec         VARCHAR(15),
   rese                  VARCHAR(15),
   recof                 VARCHAR(15),
   local_geogr           VARCHAR(15),
   ano_plano             DECIMAL(4,0),
   mes_plano             DECIMAL(2,0),
   qtd_firme             DECIMAL(10,3),
   qtd_preve             DECIMAL(10,3),
   mensagem              VARCHAR(80),
   situacao              VARCHAR(01)   
END RECORD

DEFINE m_den_arquivo      VARCHAR(10),
       m_empresa          VARCHAR(10),
       m_arquivo          VARCHAR(10),
       m_dat_carga        VARCHAR(10),
       m_cliente          VARCHAR(10),
       m_lupa_cli         VARCHAR(10),       
       m_zoom_cliente     VARCHAR(10),
       m_firme            VARCHAR(10),
       m_processado       VARCHAR(10),
       m_programacao      VARCHAR(10)

DEFINE m_num_lista        LIKE pedidos.num_list_preco,
       m_pre_unit         LIKE ped_itens.pre_unit,
       m_num_plano        LIKE num_plano_vendas.num_plano_vendas,
       m_cod_moeda        LIKE num_plano_vendas.cod_moeda

DEFINE mr_audit  RECORD
   id_registro   SERIAL,    
   cod_empresa   CHAR(02),
   num_pedido    INTEGER,
   cod_item      CHAR(15),
   prz_entrega   DATE,
   qtd_solic     DECIMAL(10,3),
   mensagem      CHAR(50),
   usuario       CHAR(08),
   dat_operacao  DATE,
   cod_cliente   CHAR(15),
   qtd_operacao  DECIMAL(10,3),
   item_cliente  CHAR(30),
   qtd_antes     DECIMAL(10,3),
   id_arquivo    INTEGER,
   id_pe1        INTEGER,
   situacao      CHAR(01),
   programacao   CHAR(11),
   qtd_atual     DECIMAL(10,3),
   operacao      char(20)
END RECORD

DEFINE mr_print           RECORD
       cod_cliente        CHAR(15),
       nom_cliente        CHAR(50),
       num_pedido         DECIMAL(6,0),
       dat_de             DATE,
       dat_ate            DATE,
       prz_de             DATE,
       prz_ate            DATE,
       tip_proces         CHAR(01)
END RECORD

DEFINE mr_relat          RECORD
      cod_cliente        CHAR(15),
      nom_cliente        VARCHAR(36),
      num_pc             VARCHAR(15), 
      seq_pc             INTEGER,
      item_cliente       VARCHAR(30), 
      num_pedido         INTEGER, 
      cod_item           VARCHAR(15), 
      den_item_reduz     VARCHAR(18), 
      prz_entrega        DATE,
      qtd_solic          DECIMAL(10,3), 
      qtd_atual          DECIMAL(10,3), 
      qtd_operacao       DECIMAL(10,3), 
      mensagem           VARCHAR(15), 
      usuario            VARCHAR(08), 
      dat_operacao       DATE, 
      hor_operacao       VARCHAR(08)       
END RECORD

#-----------------#
FUNCTION pol1419()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300

   LET p_versao = "pol1419-12.00.00  "
   LET m_car_plan = TRUE
   
   IF pol1419_cria_tabs() THEN
      CALL pol1419_menu()
   END IF
    
END FUNCTION

#---------------------------#
FUNCTION pol1419_cria_tabs()#
#---------------------------#

   DROP TABLE w_prog_komatsu;

   CREATE TEMP TABLE w_prog_komatsu (
    plano_vendas          VARCHAR(15),
    ano_plano             DECIMAL(4,0),
    mes_plano             DECIMAL(2,0)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','tabele w_prog_komatsu')
      RETURN FALSE
   END IF
   
   CREATE INDEX ix_w_prog_komatsu ON w_prog_komatsu(plano_vendas)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','indice ix_w_prog_komatsu')
      RETURN FALSE
   END IF
  
   RETURN TRUE
   
END FUNCTION
   
#----------------------#
FUNCTION pol1419_menu()#
#----------------------#

    DEFINE l_menubar      VARCHAR(10),
           l_panel        VARCHAR(10),
           l_carga        VARCHAR(10),
           l_consist      VARCHAR(10),
           l_proces       VARCHAR(10),
           l_titulo       VARCHAR(80),
           l_find         VARCHAR(80),
           l_first        VARCHAR(80),
           l_previous     VARCHAR(80),
           l_next         VARCHAR(80),
           l_last         VARCHAR(80),
           l_delete       VARCHAR(80),
           l_proc_all     VARCHAR(80),
           l_print        VARCHAR(80)
    
    LET l_titulo = 'CARGA E PROCESSAMENTO DE FORECAST EDI - ', p_versao
    
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
    CALL _ADVPL_set_property(l_carga,"TOOLTIP","Importar um arquivo FORECAST")
    CALL _ADVPL_set_property(l_carga,"EVENT","pol1419_carga")
    CALL _ADVPL_set_property(l_carga,"CONFIRM_EVENT","pol1419_carga_conf")
    CALL _ADVPL_set_property(l_carga,"CANCEL_EVENT","pol1419_carga_canc")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TOOLTIP","Pesquisar caragas efetuadas")
    CALL _ADVPL_set_property(l_find,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1419_pesquisar")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1419_pesq_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1419_pesq_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"TOOLTIP","Excluir arquivo importado")
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1419_exclui_arq")

    LET l_consist = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_consist,"IMAGE","CONSISTIR_EX")     
    CALL _ADVPL_set_property(l_consist,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_consist,"TOOLTIP","Processa consist�ncia geral dos dados")
    CALL _ADVPL_set_property(l_consist,"EVENT","pol1419_consistir")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Processa itens selecionados")
    CALL _ADVPL_set_property(l_proces,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1419_processar")
    CALL _ADVPL_set_property(l_proces,"CONFIRM_EVENT","pol1419_processar_conf")
    CALL _ADVPL_set_property(l_proces,"CANCEL_EVENT","pol1419_processar_canc")

    LET l_proc_all = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proc_all,"IMAGE","PROC_ALL")     
    CALL _ADVPL_set_property(l_proc_all,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_proc_all,"ENABLE",TRUE) 
    CALL _ADVPL_set_property(l_proc_all,"TOOLTIP","Processa todos os itens")
    CALL _ADVPL_set_property(l_proc_all,"EVENT","pol1419_proc_all")

    LET l_print = _ADVPL_create_component(NULL,"LPRINTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_print,"EVENT","pol1419_tela_print")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1419_parametros(l_panel)
    CALL pol1419_planos(l_panel)
    CALL pol1419_programacoes(l_panel)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#---------------------------------------#
FUNCTION pol1419_parametros(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)
    
    LET m_panel_cabec = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel_cabec,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_panel_cabec,"HEIGHT",40)
    CALL _ADVPL_set_property(m_panel_cabec,"BACKGROUND_COLOR",231,237,237)
    CALL _ADVPL_set_property(m_panel_cabec,"ENABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",13,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_den_arquivo = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_cabec)     
    CALL _ADVPL_set_property(m_den_arquivo,"POSITION",68,10)     
    CALL _ADVPL_set_property(m_den_arquivo,"VARIABLE",mr_arquivo,"den_arquivo")
    CALL _ADVPL_set_property(m_den_arquivo,"LENGTH",40) 
    CALL _ADVPL_set_property(m_den_arquivo,"VISIBLE",TRUE)
    CALL _ADVPL_set_property(m_den_arquivo,"VISIBLE",TRUE)     
    CALL _ADVPL_set_property(m_den_arquivo,"EDITABLE",FALSE)     
    CALL _ADVPL_set_property(m_den_arquivo,"CAN_GOT_FOCUS",FALSE)

    LET m_arquivo = _ADVPL_create_component(NULL,"LCOMBOBOX",m_panel_cabec)     
    CALL _ADVPL_set_property(m_arquivo,"POSITION",68,10)     
    CALL _ADVPL_set_property(m_arquivo,"ADD_ITEM","0","Select    ")
    CALL _ADVPL_set_property(m_arquivo,"VARIABLE",mr_arquivo,"nom_arquivo")
    CALL _ADVPL_set_property(m_arquivo,"VISIBLE",FALSE)     

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",405,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Carga:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    

    LET m_dat_carga = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_cabec)     
    CALL _ADVPL_set_property(m_dat_carga,"POSITION",448,10)     
    CALL _ADVPL_set_property(m_dat_carga,"LENGTH",10) 
    CALL _ADVPL_set_property(m_dat_carga,"ENABLE",FALSE)     
    CALL _ADVPL_set_property(m_dat_carga,"VARIABLE",mr_arquivo,"dat_carga")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",543,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","As:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    

    LET m_dat_carga = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_cabec)     
    CALL _ADVPL_set_property(m_dat_carga,"POSITION",564,10)     
    CALL _ADVPL_set_property(m_dat_carga,"LENGTH",8) 
    CALL _ADVPL_set_property(m_dat_carga,"ENABLE",FALSE)     
    CALL _ADVPL_set_property(m_dat_carga,"VARIABLE",mr_arquivo,"hor_carga")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",645,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Proces:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    

    LET m_processado = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_cabec)
    CALL _ADVPL_set_property(m_processado,"POSITION",692,10)
    CALL _ADVPL_set_property(m_processado,"LENGTH",1) 
    CALL _ADVPL_set_property(m_processado,"ENABLE",FALSE)     
    CALL _ADVPL_set_property(m_processado,"VARIABLE",mr_arquivo,"processado")
    
END FUNCTION

#-----------------------------------#
FUNCTION pol1419_planos(l_container)#
#-----------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_panel_item = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel_item,"ALIGN","LEFT")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_item)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_plano = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_plano,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_plano,"BEFORE_ROW_EVENT","pol1419_plan_before_row")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_plano)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Status")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","situacao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_plano)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_plano)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item ciente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","item_cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_plano)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item logix")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_plano)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pre�o")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","preco_plano")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_plano)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",280)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_brz_plano,"SET_ROWS",ma_plano,1)
    CALL _ADVPL_set_property(m_brz_plano,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_plano,"CAN_REMOVE_ROW",FALSE)

END FUNCTION

#-----------------------------------------#
FUNCTION pol1419_programacoes(l_container)#
#-----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_panel_prog = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel_prog,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_panel_prog,"EDITABLE",FALSE)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_prog)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_prog = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_prog,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","UNCHECKED")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sel")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_select")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1419_chec_selecao")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER_CLICK_EVENT","pol1419_marca_desmarca")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ano")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ano_plano")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","M�s")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mes_plano")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd EDI")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_plano")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd logix")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_plan_log")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pre�o logix")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pre_unit_log")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Opera��o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","operacao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_brz_prog,"SET_ROWS",ma_prog,1)
    CALL _ADVPL_set_property(m_brz_prog,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_prog,"CAN_REMOVE_ROW",FALSE)

END FUNCTION
#---------------------------------#
FUNCTION pol1419_plan_before_row()#
#---------------------------------#

   IF m_car_plan THEN
      RETURN TRUE
   END IF
      
   LET m_lin_atu = _ADVPL_get_property(m_brz_plano,"ROW_SELECTED")

   LET p_status = pol1419_set_programacao()
      
   RETURN TRUE

END FUNCTION   

#---------------------------------#
FUNCTION pol1419_set_programacao()#
#---------------------------------#

   LET m_id_item = ma_plano[m_lin_atu].id_item
   LET m_cod_cliente = ma_plano[m_lin_atu].cod_cliente
   LET m_item_cliente = ma_plano[m_lin_atu].item_cliente
   LET m_cod_item = ma_plano[m_lin_atu].cod_item
   LET m_ies_status = ma_plano[m_lin_atu].situacao

   INITIALIZE ma_prog TO NULL
   CALL _ADVPL_set_property(m_brz_prog,"CLEAR")
   
   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1419_le_programacao","PROCESS")  
   
   RETURN p_status
   
END FUNCTION

#-----------------------#
FUNCTION pol1419_carga()#
#-----------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   CALL pol1419_limpa_campos()
   LET m_ies_info = 'N'
   LET mr_arquivo.cod_empresa = p_cod_empresa
   LET mr_arquivo.cod_tip_carteira = '01'
   LET mr_arquivo.mercado = 'IN'
   LET mr_arquivo.pais = '001'
   
   IF NOT pol1419_ck_empresa() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'C'
   
   CALL pol1419_set_carga(TRUE)
   CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1419_limpa_campos()#
#------------------------------#
   
   LET m_car_plan = TRUE
   INITIALIZE mr_arquivo.* TO NULL
   INITIALIZE ma_plano, ma_prog TO NULL
   CALL _ADVPL_set_property(m_brz_plano,"SET_ROWS",ma_plano,1)
   CALL _ADVPL_set_property(m_brz_prog,"SET_ROWS",ma_prog,1)
   
END FUNCTION

#----------------------------#
FUNCTION pol1419_ck_empresa()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_arquivo.cod_empresa IS NULL THEN
      LET m_msg = 'Selecione a empresa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1419_le_caminho() THEN
      RETURN FALSE
   END IF

   IF NOT pol1419_carrega_lista() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1419_le_caminho()#
#----------------------------#

   SELECT nom_caminho, ies_ambiente
     INTO m_caminho, m_ies_ambiente
   FROM path_logix_v2
   WHERE cod_empresa = mr_arquivo.cod_empresa 
     AND cod_sistema = 'PVK'

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema PVK n�o cadastrado na LOG1100/log00098'
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

#-------------------------------#
FUNCTION pol1419_carrega_lista()#
#-------------------------------#     

   DEFINE l_ind     INTEGER,
          t_ind     CHAR(03)

   CALL _ADVPL_set_property(m_arquivo,"CLEAR") 
   CALL _ADVPL_set_property(m_arquivo,"ADD_ITEM","0","Select    ") 
   
   LET m_posi_arq = LENGTH(m_caminho) + 1
   LET m_qtd_arq = LOG_file_getListCount(m_caminho,"*.csv",FALSE,FALSE,TRUE)
   
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
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1419_set_carga(l_status)#
#-----------------------------------#
   
   DEFINE l_status      SMALLINT
   
   CALL _ADVPL_set_property(m_panel_cabec,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_arquivo,"VISIBLE",l_status)  
   CALL _ADVPL_set_property(m_den_arquivo,"VISIBLE",NOT l_status)  

END FUNCTION
      
#---------------------------------#
FUNCTION pol1419_carrega_empresa()#
#---------------------------------#
   
   DEFINE lr_empresa        RECORD
          cod_empresa       LIKE empresa.cod_empresa, 
          den_reduz         LIKE empresa.den_reduz
   END RECORD
   
   CALL _ADVPL_set_property(m_empresa,"CLEAR")
   CALL _ADVPL_set_property(m_empresa,"ADD_ITEM","0","Select     ")
      
   DECLARE cq_empresa CURSOR FOR
    SELECT cod_empresa, den_reduz
      FROM empresa
   FOREACH cq_empresa INTO lr_empresa.*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','empresa:cq_empresa')
         RETURN FALSE
      END IF
      
      CALL _ADVPL_set_property(m_empresa,"ADD_ITEM",lr_empresa.cod_empresa,lr_empresa.den_reduz)

   END FOREACH
   
   RETURN TRUE

END FUNCTION
   
#----------------------------#
FUNCTION pol1419_carga_canc()#
#----------------------------#

   CALL pol1419_limpa_campos()
   LET m_ies_info = 'N'
   CALL pol1419_set_carga(FALSE)
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1419_carga_conf()#
#----------------------------#

   IF NOT pol1419_valid_form() THEN
      RETURN FALSE
   END IF

   IF NOT pol1419_valid_arquivo() THEN
      RETURN FALSE
   END IF

   IF NOT pol1419_cria_tab() THEN
      RETURN FALSE
   END IF

   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1419_load_arq","PROCESS")  
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF

   CALL pol1419_set_carga(FALSE)

   CALL LOG_transaction_begin()
   
   IF NOT pol1419_limpa_tabelas() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   IF NOT pol1419_ins_arq_komatsu() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1419_separar","PROCESS")  
   
   IF NOT p_status THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
      
   CALL LOG_transaction_commit()

   #LET p_status = pol1419_move_arquivo() 
      
   LET m_car_plan = TRUE

   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1419_monta_grades","PROCESS")  
   
   IF NOT p_status  THEN
      RETURN FALSE
   END IF

   LET m_lin_atu = 1   
   LET p_status = pol1419_set_programacao()

   IF p_status  THEN
      LET m_ies_info = 'C'
   END IF
    
   LET m_car_plan = FALSE
   LET m_excluiu = FALSE
         
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1419_valid_form()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_arquivo.cod_empresa = "0" THEN
      LET m_msg = 'Selecione a empresa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_empresa,"GET_FOCUS") 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-------------------------------#
FUNCTION pol1419_valid_arquivo()#
#-------------------------------#
           
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_arquivo.nom_arquivo = "0" THEN
      LET m_msg = 'Selecione um arquivo para carga.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS") 
      RETURN FALSE
   END IF

   LET m_count = mr_arquivo.nom_arquivo
   LET m_arq_origem = ma_files[m_count] CLIPPED
   
   LET m_nom_arquivo = m_arq_origem[m_posi_arq, LENGTH(m_arq_origem)]

   IF NOT pol1419_chec_carga() THEN
      CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS") 
      RETURN FALSE
   END IF
      
   LET mr_arquivo.den_arquivo = m_nom_arquivo
   LET mr_arquivo.processado = 'N'
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1419_chec_carga()#
#----------------------------#   
   
   DEFINE l_dat_carga    DATE
   
   SELECT MAX(id_arquivo) 
     INTO m_id_arquivo
     FROM forecast_komatsu
    WHERE cod_empresa = mr_arquivo.cod_empresa
      AND nom_arquivo = m_nom_arquivo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','forecast_komatsu:max(id)')
      RETURN FALSE
   END IF
   
   IF m_id_arquivo > 0 THEN
      LET m_msg = 'Esse arquivo j� foi carregado.\n ',
                  'Deseja recarreg�-lo?\n\n'
      IF NOT LOG_question(m_msg) THEN
         RETURN FALSE
      END IF
   END IF
        
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1419_cria_tab()#
#--------------------------#

   DROP TABLE qfptran_komatsu;
   
   CREATE  TABLE qfptran_komatsu (
    qfp_tran_txt    CHAR(2000)
   );

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CREATE",'qfptran_komatsu:CREATE')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1419_load_arq()#
#--------------------------#

   DEFINE l_progres         SMALLINT
      
   CALL LOG_progresspopup_set_total("PROCESS",3)

   LET l_progres = LOG_progresspopup_increment("PROCESS") 
   
   DELETE FROM qfptran_komatsu
   
   LET l_progres = LOG_progresspopup_increment("PROCESS") 
      
   LOAD FROM m_arq_origem INSERT INTO qfptran_komatsu
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("LOAD",m_arq_origem)
      RETURN FALSE
   END IF

   DELETE FROM qfptran WHERE qfp_tran_txt IS NULL OR qfp_tran_txt[1,10] =  ';;;;;;;;;;'
   
   SELECT COUNT(*) INTO m_count FROM qfptran_komatsu
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','qfptran_komatsu:count')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'O arquivo selecionado est� vazio.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF        

   LET l_progres = LOG_progresspopup_increment("PROCESS") 
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1419_limpa_tabelas()#
#-------------------------------#
   
   DECLARE cq_del_tat CURSOR FOR
    SELECT id_arquivo 
      FROM forecast_komatsu
     WHERE cod_empresa = mr_arquivo.cod_empresa 
   
   FOREACH cq_del_tat INTO m_id_arquivo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','forecast_komatsu:cq_del_tat')
         RETURN FALSE
      END IF
      
      DELETE FROM forecast_komatsu
       WHERE id_arquivo = m_id_arquivo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','forecast_komatsu:cq_del_tat')
         RETURN FALSE
      END IF

      DELETE FROM plano_komatsu
       WHERE id_arquivo = m_id_arquivo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','plano_komatsu:cq_del_tat')
         RETURN FALSE
      END IF

      DELETE FROM prog_komatsu
       WHERE id_arquivo = m_id_arquivo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','prog_komatsu:cq_del_tat')
         RETURN FALSE
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1419_ins_arq_komatsu()#
#---------------------------------#

   SELECT MAX(id_arquivo) 
     INTO m_id_arquivo
     FROM forecast_komatsu

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','plano_komatsu')
      RETURN FALSE
   END IF
   
   IF m_id_arquivo IS NULL THEN
      LET m_id_arquivo = 0
   END IF
      
   LET m_id_arquivo = m_id_arquivo + 1
   LET mr_arquivo.dat_carga = TODAY
   LET mr_arquivo.hor_carga = TIME
      
   INSERT INTO forecast_komatsu (
      id_arquivo,  
      cod_empresa, 
      nom_arquivo, 
      dat_carga,   
      hor_carga,   
      cod_usuario, 
      processado)  
    VALUES(m_id_arquivo,
           mr_arquivo.cod_empresa,
           m_nom_arquivo,
           mr_arquivo.dat_carga,
           mr_arquivo.hor_carga,
           p_user,
           mr_arquivo.processado) 
                 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','forecast_komatsu')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1419_separar()#
#-------------------------#
   
   DEFINE l_it_cliente    CHAR(30),
          l_prz_entrega   CHAR(10),
          l_qtd_solict    CHAR(10),
          l_num_pedido    INTEGER,
          l_cod_item      CHAR(15),
          l_achou         SMALLINT,
          l_it_cli_ant    CHAR(30),
          l_progres       SMALLINT,
          l_ies_firme     SMALLINT,
          l_ies_forec     SMALLINT,
          l_ies_item      SMALLINT,
          l_regiao        CHAR(03),
          l_digitos       INTEGER,
          l_ind_1         INTEGER,
          l_ind_2         INTEGER,
          l_ind_3         INTEGER,
          l_ind_prev      INTEGER,
          l_txt           VARCHAR(02),
          l_quant         VARCHAR(10),
          l_qtd_tot       INTEGER
         
   INITIALIZE ma_erro TO NULL
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   SELECT MAX(id_item) 
     INTO m_id_item
     FROM prog_komatsu

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','prog_komatsu:max')
      RETURN FALSE
   END IF
      
   IF m_id_item IS NULL THEN
      LET m_id_item = 0
   END IF
   
   LET mr_itens.id_arquivo = m_id_arquivo
   
   LET m_car_plan = TRUE
   LET m_qtd_firme = 0
   LET m_qtd_prev = 0
   LET l_ies_firme = FALSE
   LET l_ies_forec = FALSE
   LET l_ies_item = FALSE
   LET m_index = 0

   DECLARE cq_qfp CURSOR FOR
    SELECT qfp_tran_txt
      FROM qfptran_komatsu 
     WHERE qfp_tran_txt IS NOT NULL
     
   FOREACH cq_qfp INTO m_registro
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','qfptran_komatsu:cq_qfp')
         RETURN FALSE
      END IF
            
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET m_registro = m_registro CLIPPED
      
      IF m_registro IS NULL OR m_registro = ' ' OR m_registro[1,3] = ';;;' THEN
         CONTINUE FOREACH
      END IF
            
      LET l_digitos = LENGTH(m_registro)
      
      IF NOT l_ies_firme THEN
         LET l_ies_firme = TRUE
         LET l_ind_prev = 1

         FOR l_ind_1 = 1 TO l_digitos
             LET l_ind_2 = l_ind_1 + 1
             LET l_txt = UPSHIFT(m_registro[l_ind_1, l_ind_2])
             IF l_txt = 'PE' THEN           
                FOR l_ind_3 = l_ind_2 TO l_digitos
                    IF m_registro[l_ind_3] = ';' THEN
                       LET m_qtd_firme = m_qtd_firme + 1
                    ELSE
                       IF UPSHIFT(m_registro[l_ind_3]) = 'P' THEN
                          LET l_ind_prev = l_ind_1
                          LET l_ind_1 = l_digitos
                          EXIT FOR
                       END IF
                    END IF
                END FOR
             END IF
         END FOR                  
         CONTINUE FOREACH         
      END IF

      IF NOT l_ies_forec THEN
         LET m_pos_ini = 1
         LET mr_itens.linha_plano = pol1419_divide_texto()
         LET mr_itens.forec = pol1419_divide_texto()
         IF UPSHIFT(mr_itens.forec) = 'FOREC' THEN
            LET l_ies_forec = TRUE
            IF NOT pol1419_pega_datas() THEN
               RETURN FALSE
            END IF
         END IF
         CONTINUE FOREACH         
      END IF

      IF NOT l_ies_item THEN 
         LET l_ies_item = TRUE
         LET m_pos_ini = 1
         LET mr_itens.linha_plano = pol1419_divide_texto()
         LET mr_itens.forec = pol1419_divide_texto()
         LET mr_itens.fornec     = pol1419_divide_texto()
         LET mr_itens.item       = pol1419_divide_texto()
         LET mr_itens.descricao  = pol1419_divide_texto()
         LET mr_itens.revisao    = pol1419_divide_texto()
         LET mr_itens.preco      = pol1419_divide_texto()
         LET mr_itens.vigencia   = pol1419_divide_texto()
         LET mr_itens.unidade    = pol1419_divide_texto()
         LET mr_itens.ipi        = pol1419_divide_texto()
         LET mr_itens.nf         = pol1419_divide_texto()
         LET mr_itens.clf        = pol1419_divide_texto()
         LET mr_itens.almox      = pol1419_divide_texto()
         LET mr_itens.local_almox= pol1419_divide_texto()
         LET mr_itens.ent_ac     = pol1419_divide_texto()
         LET mr_itens.de_para    = pol1419_divide_texto()
         LET mr_itens.atras      = pol1419_divide_texto()
         CONTINUE FOREACH
      END IF
      
      LET m_id_item = m_id_item + 1
      LET m_pos_ini = 1
      
      FOR l_ind_1 = 1 TO l_digitos
         LET l_quant = pol1419_divide_texto()
         IF UPSHIFT(l_quant) = 'PARA' THEN
            LET l_quant = pol1419_divide_texto()
            LET l_qtd_tot = m_qtd_firme + m_qtd_prev
            FOR m_ind = 1 TO l_qtd_tot       
                LET l_quant = pol1419_divide_texto()
                IF l_quant IS NULL OR l_quant = ';' THEN
                   LET l_quant = 0
                END IF
                LET ma_data[m_ind].qtd_prog = l_quant
								IF NOT pol1419_ins_prog() THEN
								   RETURN FALSE
								END IF
            END FOR
            LET mr_itens.quatro_sem_1  = pol1419_divide_texto() 
            LET mr_itens.quatro_sem_2  = pol1419_divide_texto() 
            LET mr_itens.cod_it_fornec = pol1419_divide_texto() 
            LET mr_itens.rese          = pol1419_divide_texto() 
            LET mr_itens.recof         = pol1419_divide_texto() 
            LET mr_itens.local_geogr   = pol1419_divide_texto() 
         END IF
      END FOR                  
      
      LET mr_itens.id_item = m_id_item

      LET mr_itens.mensagem = NULL
      LET mr_itens.situacao = 'N'
      LET m_msg = ''
      
      IF mr_itens.item IS NULL THEN
         LET m_msg = 'Item cliente inv�lido;'
      END IF
      
      IF mr_itens.local_geogr IS NULL THEN
         LET m_msg = m_msg CLIPPED, 'Regi�o geogr�fica inv�lida;'
      END IF
      
      IF m_msg IS NOT NULL THEN
         LET mr_itens.mensagem = m_msg
         LET mr_itens.situacao = 'E'
      ELSE
         IF NOT pol1419_pega_cliente() THEN
            RETURN FALSE
         END IF
      END IF

      INSERT INTO plano_komatsu VALUES(mr_itens.*)
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','plano_komatsu')
         RETURN FALSE
      END IF
      
      UPDATE prog_komatsu SET item_logix = mr_itens.item_logix
       WHERE id_arquivo = m_id_arquivo AND id_item = m_id_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','prog_komatsu')
         RETURN FALSE
      END IF
      
      LET l_ies_item = FALSE
      
   END FOREACH
   
   IF NOT l_ies_forec THEN
      LET m_msg = 'Arquivo selecionado est� fora\n do lay-out para forecast'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1419_pega_datas()#
#----------------------------#
   
   DEFINE l_data             VARCHAR(10)
   
   LET mr_itens.fornec     = pol1419_divide_texto()
   LET mr_itens.item       = pol1419_divide_texto()
   LET mr_itens.descricao  = pol1419_divide_texto()
   LET mr_itens.revisao    = pol1419_divide_texto()
   LET mr_itens.preco      = pol1419_divide_texto()
   LET mr_itens.vigencia   = pol1419_divide_texto()
   LET mr_itens.unidade    = pol1419_divide_texto()
   LET mr_itens.ipi        = pol1419_divide_texto()
   LET mr_itens.nf         = pol1419_divide_texto()
   LET mr_itens.clf        = pol1419_divide_texto()
   LET mr_itens.almox      = pol1419_divide_texto()
   LET mr_itens.local_almox= pol1419_divide_texto() 
   LET mr_itens.ent_ac     = pol1419_divide_texto()
   LET mr_itens.de_para    = pol1419_divide_texto()
   LET mr_itens.atras      = pol1419_divide_texto()

   LET m_ind = 1
   INITIALIZE ma_data TO NULL
   
   WHILE m_ind <= m_qtd_firme
      LET l_data = pol1419_divide_texto()
      LET ma_data[m_ind].dat_prog = l_data
      IF ma_data[m_ind].dat_prog IS NULL THEN
         LET ma_data[m_ind].erro = 'Data diaria do plano inv�lida'
      END IF
      LET ma_data[m_ind].tip_prog = 'FIRME'
      LET m_ind = m_ind + 1      
   END WHILE
   
   LET m_qtd_prev = 0
   
   WHILE TRUE
      LET l_data = pol1419_divide_texto()
      IF LENGTH(l_data) < 10 THEN
         EXIT WHILE
      END IF
      LET m_qtd_prev = m_qtd_prev + 1
      LET ma_data[m_ind].dat_prog = l_data
      LET ma_data[m_ind].tip_prog = 'PREVISAO'
      LET m_ind = m_ind + 1      
   END WHILE
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1419_pega_cliente()#
#------------------------------#
      
   LET mr_itens.cliente = NULL
   LET mr_itens.item_logix = NULL
  
   SELECT cod_cliente 
     INTO mr_itens.cliente
     FROM cliente_komatsu 
    WHERE loc_geograf = mr_itens.local_geogr
        
   IF STATUS = 100 THEN
      LET m_msg = 'Item cliente n�o cadastrado no MAN10021'
      LET mr_itens.mensagem = m_msg
      LET mr_itens.situacao = 'E'
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','programacao_komatsu:cq_qfp')   
         RETURN FALSE
      END IF
   END IF
   
   SELECT COUNT(DISTINCT cod_item) INTO m_count
     FROM cliente_item
    WHERE cod_empresa = mr_arquivo.cod_empresa
      AND cod_cliente_matriz = mr_itens.cliente
      AND cod_item_cliente = mr_itens.item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cliente_item:01')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = m_msg CLIPPED, ' - Item cliente n�o cadastrado no man10021;'
      LET mr_itens.mensagem = m_msg
      LET mr_itens.situacao = 'E'
      RETURN TRUE
   ELSE
      IF m_count > 1 THEN
         LET m_msg = m_msg CLIPPED, ' - Item cliente com mais de um cadastrado no man10021;'
         LET mr_itens.mensagem = m_msg
         LET mr_itens.situacao = 'E'
         RETURN TRUE
      END IF
   END IF
   
   SELECT cod_item 
     INTO mr_itens.item_logix
     FROM cliente_item
    WHERE cod_empresa = mr_arquivo.cod_empresa
      AND cod_cliente_matriz = mr_itens.cliente
      AND cod_item_cliente = mr_itens.item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cliente_item:02')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1419_ins_prog()#
#--------------------------#

   DEFINE l_data   DATE,
          l_quant  DECIMAL(10,3),
          l_ano    DECIMAL(4,0),
          l_mes    DECIMAL(2,0)
   
   LET l_quant = ma_data[m_ind].qtd_prog
   LET l_data = ma_data[m_ind].dat_prog
   
   IF l_data IS NULL THEN
      LET ma_data[m_ind].erro = 'Data inv�lida'
   ELSE
      LET ma_data[m_ind].erro = NULL
      LET l_ano = YEAR(l_data)
      LET l_mes = MONTH(l_data)
   END IF
      
   INSERT INTO prog_komatsu(
      id_arquivo,
      id_item,
      dat_prog, 
      tip_prog, 
      qtd_prog,
      mensagem,
      ano_plano,
      mes_plano,
      qtd_plano)
   VALUES(m_id_arquivo,
          m_id_item,
          ma_data[m_ind].dat_prog, 
          ma_data[m_ind].tip_prog, 
          ma_data[m_ind].qtd_prog, 
          ma_data[m_ind].erro,
          l_ano,
          l_mes,
          l_quant)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','prog_komatsu')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION   
   
#------------------------------#
FUNCTION pol1419_divide_texto()#
#------------------------------#
   
   DEFINE l_ind        INTEGER,
          l_conteudo   CHAR(30)
   
   LET m_pos_fim = 0
       
   FOR l_ind = m_pos_ini TO LENGTH(m_registro)
       IF m_registro[l_ind] = ';' THEN
          LET m_pos_fim = l_ind - 1
          EXIT FOR
       END IF
   END FOR
   
   IF m_pos_fim = 0 THEN
      LET m_pos_fim = l_ind - 1
   END IF

   IF m_pos_fim < m_pos_ini THEN
      LET m_pos_ini = m_pos_ini + 1
      RETURN l_conteudo CLIPPED
   END IF
      
   LET l_conteudo = m_registro[m_pos_ini, m_pos_fim]
   LET m_pos_ini = m_pos_fim + 2
   
   RETURN l_conteudo CLIPPED

END FUNCTION

#------------------------------#
FUNCTION pol1419_move_arquivo()#
#------------------------------#
   
   DEFINE l_arq_dest       CHAR(100),
          l_comando        CHAR(120),
          l_tamanho        integer

   LET l_tamanho = LENGTH(m_arq_origem CLIPPED) - 4
   LET l_arq_dest = m_arq_origem[1, l_tamanho], '.pro'
   
   CALL log0030_mensagem(m_arq_origem, 'info')
   CALL log0030_mensagem(l_arq_dest, 'info')
   
   IF m_ies_ambiente = 'W' THEN
      LET l_comando = 'move ', m_arq_origem CLIPPED, ' ', l_arq_dest
   ELSE
      LET l_comando = 'mv ', m_arq_origem CLIPPED, ' ', l_arq_dest
   END IF
 
   RUN l_comando RETURNING p_status
   
   IF p_status = 1 THEN
      LET m_msg = 'N�o foi possivel renomear o arquivo de .csv para .csv-proces'
      CALL log0030_mensagem(m_msg,'info')      
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1419_monta_grades()#
#------------------------------#
  
   DEFINE l_qtd_item      SMALLINT,
          l_progres       SMALLINT
      
   INITIALIZE ma_plano TO NULL
   CALL _ADVPL_set_property(m_brz_plano,"CLEAR")
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   SELECT COUNT(*) INTO m_count
     FROM plano_komatsu
    WHERE id_arquivo = m_id_arquivo
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','plano_komatsu:mg')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Arquivo n�o cont�m pedidos.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN TRUE
   END IF
      
   LET m_ind = 1
   LET m_qtd_erro = 0
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
         
   DECLARE cq_monta CURSOR FOR
    SELECT id_item,   
           cliente,   
           item,      
           item_logix,
           mensagem,  
           situacao,
           preco  
      FROM plano_komatsu 
     WHERE id_arquivo = m_id_arquivo
       AND situacao <> 'P'

   FOREACH cq_monta INTO 
      ma_plano[m_ind].id_item,
      ma_plano[m_ind].cod_cliente,
      ma_plano[m_ind].item_cliente,
      ma_plano[m_ind].cod_item,
      ma_plano[m_ind].mensagem,
      ma_plano[m_ind].situacao,
      ma_plano[m_ind].preco_plano
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cq_monta')
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      IF ma_plano[m_ind].situacao = 'E' THEN
         LET m_qtd_erro = m_qtd_erro + 1
      END IF

      CALL _ADVPL_set_property(m_brz_plano,"LINE_FONT_COLOR",m_ind,0,0,0)                  
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 2000 THEN
         LET m_msg = 'Limite de itens previstos ultrapassou 2000.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   LET m_qtd_planos = m_ind - 1
     
   LET m_qtd_item = m_ind - 1
   CALL _ADVPL_set_property(m_brz_plano,"ITEM_COUNT", m_qtd_item)

   LET l_progres = LOG_progresspopup_increment("PROCESS")
            
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1419_le_programacao()#
#--------------------------------#
   
   DEFINE l_ies_prog      CHAR(1),
          l_dat_abertura  DATE,
          l_situacao      CHAR(01),
          l_count         INTEGER,
          l_progres       SMALLINT
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   SELECT COUNT(*) INTO m_count
     FROM prog_komatsu
    WHERE id_arquivo = m_id_arquivo
      AND id_item = m_id_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','prog_komatsu:lp')
      RETURN
   END IF
      
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DELETE FROM w_prog_komatsu
   
   SELECT COUNT(*) INTO l_count FROM w_prog_komatsu
   
   IF l_count > 0 THEN
      LET m_msg = 'Erro limpando tabela tempor�ria w_prog_komatsu'
      CALL log0030_mensagem(m_msg,'info')
      RETURN
   END IF      
         
   LET m_ind = 1
   LET m_clik_cab = FALSE

   DECLARE cq_le_prog CURSOR FOR                                               
     SELECT ano_plano,
            mes_plano,
            SUM(qtd_plano)
       FROM prog_komatsu               
      WHERE id_arquivo = m_id_arquivo  
        AND id_item = m_id_item  
        AND mensagem IS NULL  
      GROUP BY ano_plano, mes_plano
      ORDER BY ano_plano, mes_plano
   FOREACH cq_le_prog INTO             
      ma_prog[m_ind].ano_plano,
      ma_prog[m_ind].mes_plano,          
      ma_prog[m_ind].qtd_plano
                                       
      IF STATUS <> 0 THEN                               
         CALL log003_err_sql('SELECT','prog_komatsu:cq_le_prog')     
         RETURN                                   
      END IF                                            
        
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      LET ma_prog[m_ind].ies_select = 'N'                                                                                                                                                                                                        
      LET  ma_prog[m_ind].mensagem = NULL
      
      IF NOT pol1419_le_plano() THEN
         RETURN 
      END IF
      
      IF ma_prog[m_ind].mensagem IS NOT NULL THEN                               
         CALL _ADVPL_set_property(m_brz_prog,"LINE_FONT_COLOR",m_ind,255,0,0)
      ELSE
         CALL _ADVPL_set_property(m_brz_prog,"LINE_FONT_COLOR",m_ind,0,0,0)   
      END IF                                            
      
      INSERT INTO w_prog_komatsu(
       plano_vendas,  
       ano_plano,      
       mes_plano) VALUES(
            m_num_plano,
            ma_prog[m_ind].ano_plano,
            ma_prog[m_ind].mes_plano)         
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','w_prog_komatsu')
         RETURN
      END IF   

      LET m_ind = m_ind + 1

      IF m_ind > 1000 THEN                                                                                  
         LET m_msg = 'Limite de programa��es ultrapassou a 1000.'                                        
         CALL log0030_mensagem(m_msg,'info')                                                                
         EXIT FOREACH                                                                                       
      END IF                                                                                                
        
   END FOREACH    
                     
   FREE cq_le_prog

   DECLARE cq_nao_env CURSOR FOR
    SELECT pve_plano_vendas.ano_plano_vendas,
           pve_plano_vendas.mes_plano_vendas,
           pve_plano_vendas.qtd_plano_vendas, 
           pve_plano_vendas.pre_unit_pl_vendas  
      FROM pve_plano_vendas                                                        
     WHERE pve_plano_vendas.empresa = p_cod_empresa                                      
       AND pve_plano_vendas.cliente = m_cod_cliente                           
       AND pve_plano_vendas.item = m_cod_item                                
       AND pve_plano_vendas.carteira = mr_arquivo.cod_tip_carteira                                      
       AND pve_plano_vendas.mercado = mr_arquivo.mercado                 
       AND pve_plano_vendas.pais = mr_arquivo.pais                           
       AND pve_plano_vendas.plano_vendas NOT IN                                     
     ( SELECT w_prog_komatsu.plano_vendas 
         FROM w_prog_komatsu                      
        WHERE w_prog_komatsu.ano_plano = pve_plano_vendas.ano_plano_vendas            
          AND w_prog_komatsu.mes_plano = pve_plano_vendas.mes_plano_vendas)           
   
   FOREACH cq_nao_env INTO
      ma_prog[m_ind].ano_plano,
      ma_prog[m_ind].mes_plano,          
      ma_prog[m_ind].qtd_plan_log,
      ma_prog[m_ind].pre_unit_log

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','pve_plano_vendas:cq_nao_env')
         RETURN
      END IF   

      LET ma_prog[m_ind].qtd_plano = NULL
      LET ma_prog[m_ind].operacao = 'CANCELAR'
      LET ma_prog[m_ind].ies_select = 'N'
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")

      LET m_ind = m_ind + 1

      IF m_ind > 1000 THEN                                                                                  
         LET m_msg = 'Limite de programa��es ultrapassou a 1000.'                                        
         CALL log0030_mensagem(m_msg,'info')                                                                
         EXIT FOREACH                                                                                       
      END IF                                                                                                
        
   END FOREACH    
                     
   FREE cq_nao_env
                                                                                                            
   LET m_qtd_prog = m_ind - 1
   CALL _ADVPL_set_property(m_brz_prog,"ITEM_COUNT", m_qtd_prog)
         
END FUNCTION

#--------------------------#
FUNCTION pol1419_le_plano()#
#--------------------------#

   LET ma_prog[m_ind].qtd_plan_log = NULL
   LET ma_prog[m_ind].pre_unit_log = NULL

   SELECT num_plano_vendas, 
          cod_moeda
     INTO m_num_plano,
          m_cod_moeda     
     FROM num_plano_vendas
    WHERE cod_empresa = p_cod_empresa
      AND cod_tip_carteira = mr_arquivo.cod_tip_carteira
      AND ano_ini_plano <= ma_prog[m_ind].ano_plano
      AND ano_fim_plano >= ma_prog[m_ind].ano_plano
      AND mes_ini_plano <= ma_prog[m_ind].mes_plano
      AND mes_fim_plano >= ma_prog[m_ind].mes_plano

   IF STATUS = 100 THEN                               
      LET ma_prog[m_ind].mensagem = 'Plano n�o cadastrado no Logix'
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','num_plano_vendas:cq_le_plano')     
         RETURN FALSE
      END IF
   END IF                                            
   
   SELECT qtd_plano_vendas, 
          pre_unit_pl_vendas  
     INTO ma_prog[m_ind].qtd_plan_log,
          ma_prog[m_ind].pre_unit_log
     FROM pve_plano_vendas 
    WHERE empresa = p_cod_empresa 
      AND plano_vendas = m_num_plano
      AND cliente = m_cod_cliente
      AND item = m_cod_item 
      AND ano_plano_vendas = ma_prog[m_ind].ano_plano 
      AND mes_plano_vendas = ma_prog[m_ind].mes_plano
      AND carteira = mr_arquivo.cod_tip_carteira
      AND mercado = mr_arquivo.mercado 
      AND pais = mr_arquivo.pais

   IF STATUS = 100 THEN                               
      LET ma_prog[m_ind].operacao = 'INCLUIR'
   ELSE
      IF STATUS = 0 THEN 
         LET ma_prog[m_ind].operacao = 'ATUALIZAR'
      ELSE
         CALL log003_err_sql('SELECT','pve_plano_vendas:cq_le_plano')    
         RETURN FALSE
      END IF
   END IF                                                  
   
   RETURN TRUE

END FUNCTION

   