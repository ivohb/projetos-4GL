#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1370                                                 #
# OBJETIVO: CARGA E PROCESSAMENTO DO EDI  - ETHOS                   #
# AUTOR...: IVO                                                     #
# DATA....: 14/05/19                                                #
#-------------------------------------------------------------------#

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
       m_cnpj_cli        CHAR(19),
       m_cnpj_emp        CHAR(19),
       m_arq_arigem      CHAR(100),
       m_ind             INTEGER,
       m_index           INTEGER,
       m_num_trans       INTEGER,
       m_reg_lido        CHAR(03),
       m_reg_ant         CHAR(03),
       m_tem_erro        SMALLINT,
       m_qtd_erro        INTEGER,
       m_leu_pe1         SMALLINT,
       m_qtd_dec         DECIMAL(1,0),
       m_ind_pe3         INTEGER,
       m_ind_pe5         INTEGER,
       m_prz_entrega     DATE,
       m_qtd_entrega     DECIMAL(10,3),
       m_dat_abertura    DATE,
       m_ies_prog        CHAR(01),
       m_ident_prog      CHAR(01),
       m_num_seq         INTEGER,
       m_qtd_solic       DECIMAL(10,3),
       m_qtd_nova        DECIMAL(10,3),
       m_qtd_atend       DECIMAL(10,3),
       m_qtd_saldo       DECIMAL(10,3),
       m_num_pedido      INTEGER,
       m_id_pe1          INTEGER,
       m_linha           CHAR(300),
       m_qtd_item        INTEGER,
       m_qtd_prog        INTEGER,
       m_lin_atu         INTEGER,
       m_situacao        CHAR(01),
       m_item_cliente    CHAR(30),
       m_critica         CHAR(30),
       m_excluiu         SMALLINT,
       m_importou        SMALLINT,
       m_clik_cab        SMALLINT,
       m_lin_ped         INTEGER,
       m_seq_prog        INTEGER,
       m_progres         SMALLINT

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_panel_cabec     VARCHAR(10),
       m_panel_item      VARCHAR(10),
       m_panel_prog      VARCHAR(10),
       m_brz_pedido      VARCHAR(10),
       m_brz_prog        VARCHAR(10)
       

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_carregando      SMALLINT,
       m_ordenou         SMALLINT,
       m_num_id          INTEGER

DEFINE mr_arquivo        RECORD
       den_arquivo       CHAR(40),
       nom_arquivo       CHAR(100),
       dat_carga         DATE,
       hor_carga         CHAR(08),
       cnpj_cliente      CHAR(19),
       cod_cliente       CHAR(15),
       nom_cliente       CHAR(40),
       processado        CHAR(01),
       programacao       CHAR(01)
END RECORD

DEFINE ma_files ARRAY[50] OF CHAR(100)


DEFINE mr_edi_pe1         RECORD 
       cod_empresa        CHAR(02),
       num_pedido         INTEGER,              
       cod_fabr_dest      CHAR(03),
       identif_prog_atual CHAR(09),
       dat_prog_atual     DATE,
       identif_prog_ant   CHAR(09),
       dat_prog_anterior  DATE,
       cod_item_cliente   CHAR(30),
       cod_item           CHAR(30),
       num_pedido_compra  CHAR(10),
       cod_local_destino  CHAR(05),
       nom_contato        CHAR(11),
       cod_unid_med       CHAR(02),
       qtd_casas_decimais CHAR(01),
       cod_tip_fornec     CHAR(01),
       situacao           CHAR(01),
       mensagem           CHAR(120),
       id_arquivo         integer,
       id_pe1             integer
END RECORD

DEFINE mr_edi_pe2         RECORD 
       cod_empresa        CHAR(02),       
       num_pedido         INTEGER,              
       dat_ult_embar      DATE,       
       num_ult_nff        CHAR(06),
       ser_ult_nff        CHAR(04),
       dat_rec_ult_nff    DATE,
       qtd_recebida       DECIMAL(10,3),
       qtd_receb_acum     DECIMAL(10,3),
       qtd_lote_minimo    DECIMAL(10,3),
       cod_freq_fornec    CHAR(03),
       dat_lib_producao   CHAR(04),
       dat_lib_mat_prima  CHAR(04),
       cod_local_descarga CHAR(07),
       periodo_entrega    CHAR(04),
       cod_sit_item       CHAR(02),
       identif_tip_prog   CHAR(01),
       pedido_revenda     CHAR(03),
       qualif_progr       CHAR(01),
       id_pe1             INTEGER
END RECORD

DEFINE ma_edi_pe3         ARRAY[500] OF RECORD 
       cod_empresa        CHAR(02),
       num_pedido         INTEGER,       
       num_sequencia      INTEGER,                                                 
       dat_entrega_1      DATE,
       hor_entrega_1      CHAR(02),   
       qtd_entrega_1      DECIMAL(10,0),   
       dat_entrega_2      DATE,
       hor_entrega_2      CHAR(02),   
       qtd_entrega_2      DECIMAL(10,0),   
       dat_entrega_3      DATE,
       hor_entrega_3      CHAR(02),   
       qtd_entrega_3      DECIMAL(10,0),   
       dat_entrega_4      DATE,
       hor_entrega_4      CHAR(02),   
       qtd_entrega_4      DECIMAL(10,0),   
       dat_entrega_5      DATE,
       hor_entrega_5      CHAR(02),   
       qtd_entrega_5      DECIMAL(10,0),   
       dat_entrega_6      DATE,
       hor_entrega_6      CHAR(02),   
       qtd_entrega_6      DECIMAL(10,0),   
       dat_entrega_7      DATE,
       hor_entrega_7      CHAR(02),   
       qtd_entrega_7      DECIMAL(10,0),
       id_pe1             INTEGER  
END RECORD              

DEFINE ma_edi_pe5         ARRAY[500] OF RECORD 
       cod_empresa        CHAR(02),
       num_pedido         INTEGER,       
       num_sequencia      INTEGER,                                                 
       dat_entrega_1      DATE,
       identif_programa_1 CHAR(01),
       ident_prog_atual_1 CHAR(09),
       dat_entrega_2      DATE,
       identif_programa_2 CHAR(01),
       ident_prog_atual_2 CHAR(09),
       dat_entrega_3      DATE,
       identif_programa_3 CHAR(01),
       ident_prog_atual_3 CHAR(09),
       dat_entrega_4      DATE,
       identif_programa_4 CHAR(01),
       ident_prog_atual_4 CHAR(09),
       dat_entrega_5      DATE,
       identif_programa_5 CHAR(01),
       ident_prog_atual_5 CHAR(09),
       dat_entrega_6      DATE,
       identif_programa_6 CHAR(01),
       ident_prog_atual_6 CHAR(09),
       dat_entrega_7      DATE,
       identif_programa_7 CHAR(01),
       ident_prog_atual_7 CHAR(09),
       id_pe1             integer
END RECORD

DEFINE mr_pedidos         RECORD 
       cod_empresa        CHAR(02),
       num_pedido         INTEGER,   
       num_prog_atual     CHAR(10),
       dat_prog_atual     DATE,
       num_prog_ant       CHAR(10),
       dat_prog_ant       DATE,
       cod_frequencia     CHAR(03),
       cod_item_cliente   CHAR(30),
       num_nff_ult        INTEGER
END RECORD              
       
DEFINE m_tot_registros       INTEGER,
       m_zerados             INTEGER

DEFINE m_num_ped_comp        LIKE pedidos.num_pedido_cli,
       m_cod_item            LIKE item.cod_item     

DEFINE ma_erro            ARRAY[1000] OF RECORD
       num_trans          INTEGER, 
       tip_reg            CHAR(03),
       registro           CHAR(128),
       msg                CHAR(120)      
END RECORD

DEFINE ma_pedido         ARRAY[500] OF RECORD
       num_pedido        INTEGER,
       cod_item          CHAR(15),
       item_cliente      CHAR(15),
       num_pc            CHAR(30),
       mensagem          CHAR(120),
       id_arquivo        INTEGER,
       id_pe1            INTEGER,
       situacao          CHAR(01)
END RECORD

DEFINE ma_prog            ARRAY[500] OF RECORD
       num_pedido         CHAR(06),
       ies_select         CHAR(01),
       prz_entrega        DATE,
       programacao        CHAR(11),
       qtd_solic          DECIMAL(10,3),
       qtd_saldo          DECIMAL(10,3),
       qtd_solic_nova     DECIMAL(10,3),
       mensagem           CHAR(30),
       num_sequencia      INTEGER
END RECORD

DEFINE m_den_arquivo      VARCHAR(10),
       m_arquivo          VARCHAR(10),
       m_dat_carga        VARCHAR(10),
       m_cliente          VARCHAR(10),
       m_lupa_cli         VARCHAR(10),
       m_zoom_cliente     VARCHAR(10),
       m_processado       VARCHAR(10),
       m_programacao      VARCHAR(10)

DEFINE m_num_lista        LIKE pedidos.num_list_preco,
       m_pre_unit         LIKE ped_itens.pre_unit

DEFINE mr_audit           RECORD
       cod_empresa        CHAR(02),   
       num_pedido         INTEGER,    
       cod_item           CHAR(15),   
       prz_entrega        DATE,   
       mensagem           CHAR(50),
       usuario            CHAR(08),
       dat_operacao       DATE   
END RECORD

#-----------------#
FUNCTION pol1370()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300

   LET p_versao = "POL1370-12.00.11  "
   CALL func002_versao_prg(p_versao)
   LET m_carregando = TRUE
   CALL pol1370_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1370_menu()#
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
           l_proc_all     VARCHAR(80)
    
    LET l_titulo = 'CARGA E PROCESSAMENTO DO EDI - ', p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TOOLTIP","Pesquisar caragas efetuadas")
    CALL _ADVPL_set_property(l_find,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1370_pesquisar")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1370_pesq_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1370_pesq_canc")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1370_pesq_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1370_pesq_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1370_pesq_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1370_pesq_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"TOOLTIP","Excluir arquivo importado")
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1370_exclui_arq")

    LET l_carga = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_carga,"IMAGE","IMPORTAR_ARQUIVO")     
    CALL _ADVPL_set_property(l_carga,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_carga,"TOOLTIP","Importar um arquivo EDI")
    CALL _ADVPL_set_property(l_carga,"EVENT","pol1370_carga_informar")
    CALL _ADVPL_set_property(l_carga,"CONFIRM_EVENT","pol1370_carga_info_conf")
    CALL _ADVPL_set_property(l_carga,"CANCEL_EVENT","pol1370_carga_info_canc")

    LET l_consist = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_consist,"IMAGE","CONSISTIR_EX")     
    CALL _ADVPL_set_property(l_consist,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_consist,"TOOLTIP","Processa consistência geral dos dados")
    CALL _ADVPL_set_property(l_consist,"EVENT","pol1370_consistir")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Atualiza carteira de pedidos")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1370_processar")

    LET l_proc_all = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proc_all,"IMAGE","PROC_ALL")     
    CALL _ADVPL_set_property(l_proc_all,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_proc_all,"TOOLTIP","Processa a atualiza dos pedidos")
    CALL _ADVPL_set_property(l_proc_all,"EVENT","pol1370_proc_all")
    CALL _ADVPL_set_property(l_proc_all,"CONFIRM_EVENT","pol1370_proc_all_conf")
    CALL _ADVPL_set_property(l_proc_all,"CANCEL_EVENT","pol1370_proc_all_canc")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1370_parametros(l_panel)
    CALL pol1370_pedidos(l_panel)
    CALL pol1370_programacoes(l_panel)
    CALL pol1370_limpa_campos()              

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#---------------------------------------#
FUNCTION pol1370_parametros(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)
    
    LET m_panel_cabec = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel_cabec,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_panel_cabec,"HEIGHT",70)
    CALL _ADVPL_set_property(m_panel_cabec,"BACKGROUND_COLOR",231,237,237)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)

    LET m_den_arquivo = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_cabec)     
    CALL _ADVPL_set_property(m_den_arquivo,"POSITION",70,10)     
    CALL _ADVPL_set_property(m_den_arquivo,"VARIABLE",mr_arquivo,"den_arquivo")
    CALL _ADVPL_set_property(m_den_arquivo,"LENGTH",40) 
    CALL _ADVPL_set_property(m_den_arquivo,"VISIBLE",TRUE)
    CALL _ADVPL_set_property(m_den_arquivo,"FONT",NULL,11,TRUE,FALSE)
    CALL _ADVPL_set_property(m_den_arquivo,"EDITABLE",FALSE)     
    CALL _ADVPL_set_property(m_den_arquivo,"CAN_GOT_FOCUS",FALSE)

    LET m_arquivo = _ADVPL_create_component(NULL,"LCOMBOBOX",m_panel_cabec)     
    CALL _ADVPL_set_property(m_arquivo,"POSITION",70,10)     
    CALL _ADVPL_set_property(m_arquivo,"ADD_ITEM","0","Select    ")
    CALL _ADVPL_set_property(m_arquivo,"VARIABLE",mr_arquivo,"nom_arquivo")
    CALL _ADVPL_set_property(m_arquivo,"VISIBLE",FALSE)     
    CALL _ADVPL_set_property(m_arquivo,"FONT",NULL,11,TRUE,FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",600,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Carga:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)

    LET m_dat_carga = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel_cabec)     
    CALL _ADVPL_set_property(m_dat_carga,"POSITION",650,10)     
    CALL _ADVPL_set_property(m_dat_carga,"VARIABLE",mr_arquivo,"dat_carga")
    #CALL _ADVPL_set_property(m_dat_carga,"LENGTH",10) 
    CALL _ADVPL_set_property(m_dat_carga,"EDITABLE",FALSE)     
    CALL _ADVPL_set_property(m_dat_carga,"FONT",NULL,11,TRUE,FALSE)
    CALL _ADVPL_set_property(m_dat_carga,"EDITABLE",FALSE)     
    CALL _ADVPL_set_property(m_dat_carga,"CAN_GOT_FOCUS",FALSE)

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_cabec)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",770,10)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_arquivo,"hor_carga")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10) 
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)     
    CALL _ADVPL_set_property(l_caixa,"FONT",NULL,11,TRUE,FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",990,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Finalizado:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)

    LET m_processado = _ADVPL_create_component(NULL,"LCOMBOBOX",m_panel_cabec)
    CALL _ADVPL_set_property(m_processado,"POSITION",1090,10)
    CALL _ADVPL_set_property(m_processado,"ADD_ITEM","N","Não")     
    CALL _ADVPL_set_property(m_processado,"ADD_ITEM","S","Sim")     
    CALL _ADVPL_set_property(m_processado,"ADD_ITEM","T","Todos")     
    CALL _ADVPL_set_property(m_processado,"VARIABLE",mr_arquivo,"processado")    
    CALL _ADVPL_set_property(m_processado,"EDITABLE",FALSE)     
    CALL _ADVPL_set_property(m_processado,"FONT",NULL,11,TRUE,FALSE)
    CALL _ADVPL_set_property(m_processado,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",10,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","CNPJ cliente:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_cabec)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",110,40)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_arquivo,"cnpj_cliente")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",20) 
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)     
    CALL _ADVPL_set_property(l_caixa,"FONT",NULL,11,TRUE,FALSE)
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",310,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Cod. cliente:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)

    LET m_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_cabec)     
    CALL _ADVPL_set_property(m_cliente,"POSITION",410,40)     
    CALL _ADVPL_set_property(m_cliente,"VARIABLE",mr_arquivo,"cod_cliente")
    CALL _ADVPL_set_property(m_cliente,"LENGTH",20) 
    CALL _ADVPL_set_property(m_cliente,"EDITABLE",FALSE)     
    CALL _ADVPL_set_property(m_cliente,"FONT",NULL,11,TRUE,FALSE)
    #CALL _ADVPL_set_property(m_cliente,"VALID","pol1370_ck_cliente")

    LET m_lupa_cli = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_cabec)
    CALL _ADVPL_set_property(m_lupa_cli,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cli,"POSITION",590,40)     
    CALL _ADVPL_set_property(m_lupa_cli,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cli,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_lupa_cli,"CLICK_EVENT","pol1370_zoom_cliente")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_cabec)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",630,40)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_arquivo,"nom_cliente")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",40) 
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)     
    CALL _ADVPL_set_property(l_caixa,"FONT",NULL,11,TRUE,FALSE)
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",990,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Programação:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)

    LET m_programacao = _ADVPL_create_component(NULL,"LCOMBOBOX",m_panel_cabec)
    CALL _ADVPL_set_property(m_programacao,"POSITION",1090,40)
    CALL _ADVPL_set_property(m_programacao,"ADD_ITEM"," ","    ")     
    CALL _ADVPL_set_property(m_programacao,"ADD_ITEM","1","Firme")     
    CALL _ADVPL_set_property(m_programacao,"ADD_ITEM","3","Requisição")     
    CALL _ADVPL_set_property(m_programacao,"ADD_ITEM","4","Planejado")     
    CALL _ADVPL_set_property(m_programacao,"ADD_ITEM","T","Todos")     
    CALL _ADVPL_set_property(m_programacao,"VARIABLE",mr_arquivo,"programacao")    
    CALL _ADVPL_set_property(m_programacao,"EDITABLE",FALSE)     
    CALL _ADVPL_set_property(m_programacao,"FONT",NULL,11,TRUE,FALSE)
    CALL _ADVPL_set_property(m_programacao,"CAN_GOT_FOCUS",FALSE)

    CALL pol1370_ativa_desativa(FALSE)
    
END FUNCTION

#------------------------------------#
FUNCTION pol1370_pedidos(l_container)#
#------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_panel_item = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel_item,"ALIGN","LEFT")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_item)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_pedido = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_pedido,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(m_brz_pedido,"AFTER_ROW_EVENT","pol1370_ped_after_row")
    CALL _ADVPL_set_property(m_brz_pedido,"BEFORE_ROW_EVENT","pol1370_ped_before_row")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","St")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","situacao")
    #CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item ciente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","item_cliente")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ped. compra")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_pc")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",280)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_brz_pedido,"SET_ROWS",ma_pedido,1)
    CALL _ADVPL_set_property(m_brz_pedido,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_pedido,"CAN_REMOVE_ROW",FALSE)

END FUNCTION
      
#-----------------------------------------#
FUNCTION pol1370_programacoes(l_container)#
#-----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_panel_prog = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel_prog,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_prog)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_prog = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_prog,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_pedido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","UNCHECKED")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sel")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_select")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1370_checa_prog")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER_CLICK_EVENT","pol1370_marca_desmarca")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","prz_entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tp. Prog.")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","programacao")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_solic")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sdo pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_saldo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nova solic")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_solic_nova")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_brz_prog,"SET_ROWS",ma_prog,1)
    CALL _ADVPL_set_property(m_brz_prog,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_prog,"CAN_REMOVE_ROW",FALSE)

END FUNCTION

#----------------------------#
FUNCTION pol1370_checa_prog()#
#----------------------------#

   DEFINE l_lin_atu       INTEGER,
          l_estornar      CHAR(01)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET l_lin_atu = _ADVPL_get_property(m_brz_prog,"ROW_SELECTED")

   IF ma_prog[l_lin_atu].mensagem = 'INCLUIR' OR 
        ma_prog[l_lin_atu].mensagem = 'ATUALIZAR' OR
        ma_prog[l_lin_atu].mensagem = 'CANCELAR' THEN
   ELSE
      CALL _ADVPL_set_property(m_brz_prog,"COLUMN_VALUE","ies_select",l_lin_atu,'N')
      LET m_msg = 'Operação não disponível para Programação vencida, processada ou descartada.' 
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
      
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1370_marca_desmarca()#
#--------------------------------#
   
   DEFINE l_ind       INTEGER,
          l_sel       CHAR(01)
   
   LET m_clik_cab = NOT m_clik_cab
   
   IF m_clik_cab THEN
      LET l_sel = 'S'
   ELSE
      LET l_sel = 'N'
   END IF
   
   FOR l_ind = 1 TO m_qtd_prog
       IF ma_prog[l_ind].mensagem = 'INCLUIR' OR 
            ma_prog[l_ind].mensagem = 'ATUALIZAR' THEN
          CALL _ADVPL_set_property(m_brz_prog,"COLUMN_VALUE","ies_select",l_ind,l_sel)
       ELSE
          CALL _ADVPL_set_property(m_brz_prog,"COLUMN_VALUE","ies_select",l_ind,'N')
       END IF
   END FOR
      
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1370_ped_after_row()#
#--------------------------------#

   IF m_carregando THEN
      RETURN TRUE
   END IF

CALL _ADVPL_set_property(m_brz_pedido,"CLEAR_ALL_LINE_FONT_COLOR")

   LET m_lin_atu = _ADVPL_get_property(m_brz_pedido,"ROW_SELECTED")
   #CALL _ADVPL_set_property(m_brz_pedido,"LINE_FONT_COLOR",m_lin_atu,0,0,0)

CALL _ADVPL_set_property(m_brz_pedido,"LINE_FONT_COLOR",m_lin_atu,197,16,26)
         
   RETURN p_status

END FUNCTION   

#--------------------------------#
FUNCTION pol1370_ped_before_row()#
#--------------------------------#

   IF m_carregando THEN
      RETURN TRUE
   END IF
   
   #CALL _ADVPL_set_property(m_brz_pedido,"CLEAR_ALL_LINE_FONT_COLOR")
   
   LET m_lin_atu = _ADVPL_get_property(m_brz_pedido,"ROW_SELECTED")
   #CALL _ADVPL_set_property(m_brz_pedido,"LINE_FONT_COLOR",m_lin_atu,197,16,26)
   LET m_id_pe1 = ma_pedido[m_lin_atu].id_pe1
   
   CALL pol1370_le_programacao() 
   
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1370_zoom_cliente()#
#------------------------------#

    DEFINE l_codigo         LIKE clientes.cod_cliente,
           l_descri         LIKE clientes.nom_cliente,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_cliente IS NULL THEN
       LET m_zoom_cliente = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_cliente,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_cliente,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_descri = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")

    IF l_codigo IS NOT NULL THEN
       LET mr_arquivo.cod_cliente = l_codigo
       LET mr_arquivo.nom_cliente = l_descri
    END IF        
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1370_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
      
   CALL _ADVPL_set_property(m_panel_cabec,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_arquivo,"VISIBLE",l_status)  
   CALL _ADVPL_set_property(m_den_arquivo,"VISIBLE",NOT l_status)  

END FUNCTION

#------------------------------#
FUNCTION pol1370_limpa_campos()#
#------------------------------#
   
   LET m_carregando = TRUE
   INITIALIZE mr_arquivo.* TO NULL
   INITIALIZE ma_pedido, ma_prog TO NULL
   CALL _ADVPL_set_property(m_brz_pedido,"SET_ROWS",ma_pedido,1)
   CALL _ADVPL_set_property(m_brz_prog,"SET_ROWS",ma_prog,1)
   
END FUNCTION

#--------------------------------#
FUNCTION pol1370_carga_informar()#
#--------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT pol1370_le_caminho() THEN
      RETURN FALSE
   END IF
   
   CALL pol1370_limpa_campos()
   LET m_carregando = FALSE

   IF NOT pol1370_carrega_lista() THEN
      RETURN FALSE
   END IF
   
   CALL pol1370_ativa_desativa(TRUE)   
   CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1370_le_caminho()#
#----------------------------#

   SELECT nom_caminho, ies_ambiente
     INTO m_caminho, m_ies_ambiente
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "EDI"

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema EDI não cadastrado na LOG1100.'
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
FUNCTION pol1370_carrega_lista()#
#-------------------------------#     

   DEFINE l_ind     INTEGER,
          t_ind     CHAR(03)

   CALL _ADVPL_set_property(m_arquivo,"CLEAR") 
   CALL _ADVPL_set_property(m_arquivo,"ADD_ITEM","0","Select    ") 
   
   LET m_caminho = m_caminho CLIPPED,'\\'
   LET m_posi_arq = LENGTH(m_caminho) + 1
   LET m_qtd_arq = LOG_file_getListCount(m_caminho,"*.txt",FALSE,FALSE,TRUE)
   
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
FUNCTION pol1370_carga_info_canc()#
#---------------------------------#

   CALL pol1370_limpa_campos()
   CALL pol1370_ativa_desativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1370_carga_info_conf()#
#---------------------------------#
         
   IF NOT pol1370_valid_arquivo() THEN
      RETURN FALSE
   END IF
   
   CALL pol1370_ativa_desativa(FALSE)
   CALL LOG_transaction_begin()

   IF NOT pol1370_ins_arq_edi() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   IF NOT pol1370_separar() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   IF NOT pol1370_move_arquivo() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()

   LET m_msg = 'Operação efetuada com sucesso.'

   CALL log0030_mensagem(m_msg,'info')
   
   LET m_carregando = TRUE

   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1370_monta_grades","PROCESS")  
      
   LET m_carregando = FALSE

   RETURN TRUE   
    
END FUNCTION

#-------------------------------#
FUNCTION pol1370_valid_arquivo()#
#-------------------------------#
   
   {IF NOT pol1370_limpa_tabelas() THEN
      RETURN FALSE
   END IF}
        
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_arquivo.nom_arquivo = "0" THEN
      LET m_msg = 'Selecione um arquivo para carga.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS") 
      RETURN FALSE
   END IF

   LET m_count = mr_arquivo.nom_arquivo
   LET m_arq_arigem = ma_files[m_count] CLIPPED
   
   LET m_nom_arquivo = m_arq_arigem[m_posi_arq, LENGTH(m_arq_arigem)]

   IF pol1370_ja_carregou() THEN
      CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS") 
      RETURN FALSE
   END IF

   LET m_msg = 'A tabela qfptran_547 será limpa, para\n receber o novo arquivo. Continuar ?'
   
   IF NOT LOG_question(m_msg) THEN
      RETURN FALSE
   END IF

   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1370_load_arq","PROCESS")  
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1370_pega_cliente() THEN
      RETURN FALSE
   END IF
   
   LET mr_arquivo.den_arquivo = m_nom_arquivo
   LET mr_arquivo.processado = 'N'
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1370_load_arq()#
#--------------------------#

   DEFINE l_progres         SMALLINT
      
   CALL LOG_progresspopup_set_total("PROCESS",3)

   DELETE FROM qfptran_547

   LET l_progres = LOG_progresspopup_increment("PROCESS") 
      
   LOAD FROM m_arq_arigem INSERT INTO qfptran_547(qfp_tran_txt)
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("LOAD",m_arq_arigem)
      RETURN FALSE
   END IF

   LET l_progres = LOG_progresspopup_increment("PROCESS") 
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1370_ja_carregou()#
#-----------------------------#   
   
   DEFINE l_dat_carga    DATE
   
   SELECT dat_carga INTO l_dat_carga
     FROM arquivo_edi_547
    WHERE cod_empresa = p_cod_empresa
      AND nom_arquivo = m_nom_arquivo

   IF STATUS = 0 THEN
      LET m_msg = 'Esse arquivo já foi carregado em ', l_dat_carga
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN TRUE
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','arquivo_edi_547')
         RETURN TRUE
      END IF
   END IF
      
   RETURN FALSE

END FUNCTION   

#------------------------------#
FUNCTION pol1370_pega_cliente()#
#------------------------------#

   DEFINE l_cnpj     CHAR(14),
          l_empresa  CHAR(02)
   
   SELECT qfp_tran_txt
     INTO m_linha
     FROM qfptran_547
    WHERE qfp_tran_txt[1,3] = 'ITP'

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("SELECT",'qfptran_547')
      RETURN FALSE
   END IF
   
   LET l_cnpj = m_linha[26,39]
   LET m_cnpj_cli = '0', l_cnpj[1,2],'.',l_cnpj[3,5],'.',l_cnpj[6,8],'/',l_cnpj[9,12],'-',l_cnpj[13,14]
   
   IF m_cnpj_cli = '0' THEN
      LET m_msg = 'Esse arquivo não contém CNPJ do cliente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF   
              
   IF NOT pol1370_checa_cnpj() THEN
      RETURN FALSE
   END IF
      
   IF m_cod_cliente IS NULL THEN 
      LET m_msg = 'CNPJ contido no arquivo não existe no Logix.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET l_cnpj = m_linha[40,53]
   LET m_cnpj_emp = '0', l_cnpj[1,2],'.',l_cnpj[3,5],'.',l_cnpj[6,8],'/',l_cnpj[9,12],'-',l_cnpj[13,14]
   
   IF m_cnpj_emp = '0' THEN
      LET m_msg = 'Esse arquivo não contém CNPJ da empresa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF   
              
   SELECT cod_empresa 
     INTO l_empresa
     FROM empresa
    WHERE num_cgc = m_cnpj_emp   
   
   IF STATUS = 100 THEN
      LET m_msg = 'CNPJ da empresa informado nesse arquivo não cadastrado no Logix.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("SELECT",'empresa')
         RETURN FALSE
      END IF
   END IF
      
   IF l_empresa <> p_cod_empresa THEN 
      LET m_msg = 'CNPJ da empresa dese arquivo não é o da empresa selecionada no login'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1370_ck_cliente()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_arquivo.cod_cliente IS NULL THEN
      LET m_msg = 'Informe o cliente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_cliente,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1370_checa_cnpj()#
#----------------------------#

   LET mr_arquivo.cnpj_cliente = m_cnpj_cli
   LET m_cod_cliente = NULL

   DECLARE cq_pri_cli CURSOR FOR
    SELECT cod_cliente, nom_cliente 
      FROM clientes 
     WHERE num_cgc_cpf = m_cnpj_cli    
   FOREACH cq_pri_cli INTO 
           mr_arquivo.cod_cliente,
           mr_arquivo.nom_cliente

      IF STATUS <> 0 THEN 
         CALL log003_err_sql("SELECT",'clientes:cq_pri_cli')
         RETURN FALSE
      END IF
      
      LET m_cod_cliente = mr_arquivo.cod_cliente
      EXIT FOREACH
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION
   
#------------------------------#
FUNCTION pol1370_move_arquivo()#
#------------------------------#
   
   DEFINE l_arq_dest       CHAR(100),
          l_comando        CHAR(120)
          
   LET l_arq_dest = m_arq_arigem CLIPPED,'-proces'

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

#-----------------------------#
FUNCTION pol1370_ins_arq_edi()#
#-----------------------------#

   SELECT MAX(id_arquivo) 
     INTO m_id_arquivo
     FROM arquivo_edi_547
    WHERE cod_empresa = p_cod_empresa    

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','arquivo_edi_547')
      RETURN FALSE
   END IF
   
   IF m_id_arquivo IS NULL THEN
      LET m_id_arquivo = 0
   END IF
      
   LET m_id_arquivo = m_id_arquivo + 1
   LET mr_arquivo.dat_carga = TODAY
   LET mr_arquivo.hor_carga = TIME
      
   INSERT INTO arquivo_edi_547
    VALUES(p_cod_empresa, 
           m_id_arquivo,
           mr_arquivo.dat_carga,
           mr_arquivo.hor_carga,
           m_nom_arquivo,
           m_cod_cliente, 
           p_user,
           mr_arquivo.processado)
                 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','arquivo_edi_547')
      RETURN FALSE
   END IF

   UPDATE qfptran_547 SET id_arquivo = m_id_arquivo
    WHERE id_arquivo IS NULL

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','qfptran_547')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1370_add_erro()#
#--------------------------#
     
   LET m_index = m_index + 1
   
   IF m_index <= 1000 THEN
      LET ma_erro[m_index].tip_reg = m_reg_lido
      LET ma_erro[m_index].msg = m_msg
      LET ma_erro[m_index].num_trans = m_num_trans
      LET ma_erro[m_index].registro = m_linha
      LET m_tem_erro = TRUE
      LET m_qtd_erro = m_qtd_erro + 1
   END IF
   
END FUNCTION

#----------------------------#
FUNCTION pol1370_grava_erro()#
#----------------------------#   
 
   DEFINE l_ind     INTEGER
 
   FOR l_ind = 1 TO m_index
     
     INSERT INTO erro_edi_547
     VALUES(p_cod_empresa,
           ma_erro[l_ind].num_trans,
           ma_erro[l_ind].tip_reg,
           ma_erro[l_ind].registro,
           ma_erro[l_ind].msg,
           m_id_arquivo)
     
     IF STATUS <> 0 THEN
        CALL log003_err_sql('INSERT','ero_edi_547')
        RETURN FALSE
     END IF
   END FOR
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1370_separar()#
#-------------------------#

   DELETE FROM qfptran_547 WHERE qfp_tran_txt IS NULL
   
   SELECT COUNT(*) INTO m_count FROM qfptran_547
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','qfptran_547:count')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Não há dados a serem consistidos. Tabela está vazia.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF        
   
   LET m_qtd_erro = 0
   
   LET p_status = LOG_progresspopup_start(
       "Separando informações...","pol1370_sepa_info","PROCESS")  
   
   IF NOT p_status THEN
      LET m_msg = 'Operação cancelada..'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1370_sepa_info()#
#---------------------------#
      
   INITIALIZE ma_item, ma_prog, ma_erro TO NULL
   LET m_ind = 1
   LET m_index = 0

   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   {IF NOT pol1370_limpa_tabelas() THEN
      RETURN FALSE
   END IF}
   
   LET m_progres = LOG_progresspopup_increment("PROCESS")
   
   LET m_carregando = TRUE

   DECLARE cq_itp CURSOR FOR
    SELECT qfp_tran_txt,
           num_trans,
           id_arquivo
      FROM qfptran_547 
     WHERE qfp_tran_txt[1,3] = 'ITP'
   FOREACH cq_itp INTO m_linha, m_num_trans, m_id_arquivo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cq_itp')
         RETURN FALSE
      END IF
            
      LET m_progres = LOG_progresspopup_increment("PROCESS")
      
      INITIALIZE ma_erro TO NULL
      LET m_index = 0
      LET m_tem_erro = FALSE
      
      LET m_reg_lido = 'ITP'
      
      {IF NOT pol1370_checa_itp() THEN
         RETURN FALSE
      END IF
      
      IF m_tem_erro THEN
         CONTINUE FOREACH
      END IF}   

      IF NOT pol1370_proces_pe() THEN
         RETURN FALSE
      END IF
      
   END FOREACH
   
   LET m_progres = LOG_progresspopup_increment("PROCESS")

   IF m_index > 0 THEN
      IF NOT pol1370_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   DELETE FROM qfptran_547
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','qfptran_547')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1370_limpa_tabelas()#
#-------------------------------#

   DELETE FROM erro_edi_547
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','erro_edi_547')
      RETURN FALSE
   END IF

   DELETE FROM edi_pe1_547
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','edi_pe1_547')
      RETURN FALSE
   END IF

   DELETE FROM edi_pe2_547
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','edi_pe2_547')
      RETURN FALSE
   END IF

   DELETE FROM edi_pe3_547
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','edi_pe3_547')
      RETURN FALSE
   END IF

   DELETE FROM edi_pe5_547
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','edi_pe5_547')
      RETURN FALSE
   END IF

   DELETE FROM pedidos_edi_547
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','pedidos_edi_547')
      RETURN FALSE
   END IF

   DELETE FROM ped_itens_edi_547
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','ped_itens_edi_547')
      RETURN FALSE
   END IF

   DELETE FROM ped_itens_edi_pe5_547
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','ped_itens_edi_pe5_547')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#---------------------------#
FUNCTION pol1370_checa_itp()#
#---------------------------#
 
   DEFINE l_cnpj     CHAR(14),
          l_empresa  CHAR(02)

   LET l_cnpj = m_linha[26,39]
   LET m_cnpj_cli = '0', l_cnpj[1,2],'.',l_cnpj[3,5],'.',l_cnpj[6,8],'/',l_cnpj[9,12],'-',l_cnpj[13,14]
   
   IF m_cnpj_cli = '0' THEN
      LET m_msg = 'Esse arquivo não contém CNPJ do cliente.'
      CALL pol1370_add_erro()
   ELSE
      IF NOT pol1370_checa_cnpj() THEN
         RETURN FALSE
      END IF
      IF m_cod_cliente IS NULL THEN 
         LET m_msg = 'CNPJ contido no arquivo não existe no Logix.'
         CALL pol1370_add_erro()
      END IF   
   END IF   

   LET l_cnpj = m_linha[40,53]
   LET m_cnpj_emp = '0', l_cnpj[1,2],'.',l_cnpj[3,5],'.',l_cnpj[6,8],'/',l_cnpj[9,12],'-',l_cnpj[13,14]
   
   IF m_cnpj_emp = '0' THEN
      LET m_msg = 'Esse arquivo não contém CNPJ da empresa.'
      CALL pol1370_add_erro()
   ELSE
      SELECT cod_empresa 
        INTO l_empresa
        FROM empresa
       WHERE num_cgc = m_cnpj_emp   
      IF STATUS = 100 THEN
         LET m_msg = 'CNPJ da empresa informado nesse arquivo não cadastrado no Logix.'
         CALL pol1370_add_erro()
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql("SELECT",'empresa')
            RETURN FALSE
         ELSE
           IF l_empresa <> p_cod_empresa THEN 
              LET m_msg = 'CNPJ da empresa dese arquivo não é o da empresa selecionada no login'
              CALL pol1370_add_erro()
           END IF
         END IF 
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1370_proces_pe()#
#---------------------------#
   
   SELECT MAX(id_pe1) INTO m_id_pe1
     FROM edi_pe1_547
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','edi_pe1_547')
      RETURN FALSE
   END IF
   
   IF m_id_pe1 IS NULL THEN
      LET m_id_pe1 = 0
   END IF
   
   LET m_leu_pe1 = FALSE
      
   DECLARE cq_carga CURSOR FOR
    SELECT qfp_tran_txt,
           num_trans,
           id_arquivo
      FROM qfptran_547 
     WHERE num_trans > m_num_trans
     ORDER BY num_trans
   FOREACH cq_carga INTO m_linha, m_num_trans, m_id_arquivo    
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cq_carga')
         RETURN FALSE
      END IF
      
      LET m_progres = LOG_progresspopup_increment("PROCESS")

      LET m_reg_lido = m_linha[1,3]
      
      IF m_reg_lido = 'ITP' OR m_reg_lido = 'FTP' THEN
         EXIT FOREACH
      END IF
      
      IF m_reg_lido = 'PE1' THEN
         
         IF m_leu_pe1 THEN
            IF NOT pol1370_grava_ped() THEN
               RETURN FALSE
            END IF
         END IF
         
         IF NOT pol1370_checa_pe1() THEN
            RETURN FALSE
         END IF
                  
         CONTINUE FOREACH
             
      END IF
      
      IF NOT m_leu_pe1 THEN
         CONTINUE FOREACH
      END IF
      
      IF m_reg_lido = 'PE2' THEN
         CALL pol1370_checa_pe2() 
         CONTINUE FOREACH
      END IF

      IF m_reg_lido = 'PE3' THEN
         CALL pol1370_checa_pe3() 
         CONTINUE FOREACH
      END IF
 
      IF m_reg_lido = 'PE5' THEN
         CALL pol1370_checa_pe5() 
      END IF

   END FOREACH
    
   IF m_leu_pe1 THEN
      IF NOT pol1370_grava_ped() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION
   
#---------------------------#
FUNCTION pol1370_checa_pe1()#
#---------------------------#
   
   DEFINE l_cod_item     CHAR(15),
          l_ind          INTEGER,
          l_data         CHAR(08)
   
   INITIALIZE mr_edi_pe1.* TO NULL
   INITIALIZE mr_edi_pe2.* TO NULL
   INITIALIZE ma_edi_pe3 TO NULL
   INITIALIZE ma_edi_pe5 TO NULL
   
   LET m_ind_pe3 = 0
   LET m_ind_pe5 = 0
   LET m_tem_erro = FALSE
   LET m_msg = ''
   LET m_leu_pe1 = TRUE

   LET mr_edi_pe1.cod_fabr_dest      = m_linha[4,6] CLIPPED
   LET mr_edi_pe1.identif_prog_atual = m_linha[7,15] CLIPPED
   LET l_data = '20',m_linha[16,21] CLIPPED 
   LET mr_edi_pe1.dat_prog_atual     = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET mr_edi_pe1.identif_prog_ant   = m_linha[22,30] CLIPPED
   LET l_data = '20',m_linha[31,36] CLIPPED
   LET mr_edi_pe1.dat_prog_anterior     = MDY(l_data[5,6],l_data[7,8],l_data[1,4])  
   LET mr_edi_pe1.dat_prog_anterior  = m_linha[31,36] CLIPPED    
   LET mr_edi_pe1.cod_item_cliente   = m_linha[37,66] CLIPPED
   LET mr_edi_pe1.cod_item           = m_linha[67,96] CLIPPED
   LET mr_edi_pe1.num_pedido_compra  = m_linha[97,106] CLIPPED
   LET mr_edi_pe1.cod_local_destino  = m_linha[109,113] CLIPPED
   LET mr_edi_pe1.nom_contato        = m_linha[114,124] CLIPPED
   LET mr_edi_pe1.cod_unid_med       = m_linha[125,126] CLIPPED
   LET mr_edi_pe1.qtd_casas_decimais = m_linha[127,127] CLIPPED
   LET mr_edi_pe1.cod_tip_fornec     = m_linha[128,128] CLIPPED

   LET mr_edi_pe1.cod_empresa        = p_cod_empresa
   LET m_cod_item = mr_edi_pe1.cod_item CLIPPED
   LET m_num_ped_comp = mr_edi_pe1.num_pedido_compra
   LET m_item_cliente = mr_edi_pe1.cod_item_cliente
   LET m_qtd_dec = mr_edi_pe1.qtd_casas_decimais

   LET m_situacao = 'N' #novo
   
   IF NOT pol1370_pega_pedido() THEN
      RETURN FALSE
   END IF
   
   IF m_cod_item IS NULL THEN
      IF m_msg IS NULL THEN
         LET m_msg = 'Não foi possivel localizar um pedido/item correspodente no Logix.'
      END IF         
      LET m_situacao = 'C' #criticado
      #CALL pol1370_add_erro()
   ELSE
      IF m_num_pedido IS NULL THEN
         IF m_msg IS NULL THEN
            LET m_msg = 'Não há pedido para o item ', m_cod_item
         END IF
         LET m_situacao = 'C' 
         #CALL pol1370_add_erro()
      END IF   
   END IF
   
   LET mr_edi_pe1.num_pedido = m_num_pedido
   LET mr_edi_pe1.cod_item = m_cod_item

   LET m_id_pe1 = m_id_pe1 + 1
   LET mr_edi_pe1.id_arquivo = m_id_arquivo
   LET mr_edi_pe1.id_pe1 = m_id_pe1
   LET mr_edi_pe1.mensagem = m_msg
   LET mr_edi_pe1.situacao = m_situacao
   
   RETURN TRUE   
      
END FUNCTION

#-----------------------------#
FUNCTION pol1370_pega_pedido()#
#-----------------------------#

   DEFINE l_cod_item    LIKE cliente_item.cod_item
   
   LET m_num_pedido = NULL
   LET m_cod_item = NULL

   SELECT num_pedido, cod_it_logix
     INTO m_num_pedido, m_cod_item
     FROM cliente_item_edi_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = m_cod_cliente
      AND cod_it_cli = m_item_cliente
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 100 THEN
      ELSE
         CALL log003_err_sql('SELECT','cliente_item:cq_cli_item')
         RETURN FALSE
      END IF
   END IF
      
   
   DECLARE cq_cli_item CURSOR FOR                                
    SELECT cod_item                                                 
      FROM cliente_item                                             
     WHERE cod_empresa = p_cod_empresa                              
       AND cod_item_cliente = m_item_cliente                        
       AND cod_cliente_matriz = m_cod_cliente                       
       AND cod_item IN (                                            
           SELECT cod_item FROM item                                
            WHERE cod_empresa = p_cod_empresa                       
              AND ies_situacao = 'A')                               
                                                                 
   FOREACH cq_cli_item INTO l_cod_item                              
                                                                 
      IF STATUS <> 0 THEN                                           
         CALL log003_err_sql('SELECT','cliente_item:cq_cli_item')   
         RETURN FALSE                                               
      END IF                                                        
                                                                    
      LET m_cod_item = l_cod_item                                   
      EXIT FOREACH                                                  
                                                                 
   END FOREACH                                                      
      
   IF m_cod_item IS NOT NULL THEN
      IF NOT pol1370_lepedido() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol1370_leped_e_item() THEN
         RETURN FALSE
      END IF
   END IF
      
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1370_lepedido()#
#--------------------------#

   SELECT MAX(p.num_pedido)
     INTO m_num_pedido  
     FROM ped_itens i, pedidos p
    WHERE i.cod_empresa = p_cod_empresa
      AND i.cod_item = m_cod_item
      AND i.cod_empresa = p.cod_empresa
      AND i.num_pedido = p.num_pedido
      AND p.ies_sit_pedido <> '9'
      AND p.cod_cliente = m_cod_cliente
      AND p.num_pedido_cli = m_num_ped_comp

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','pedidos/ped_itens')
      RETURN FALSE
   END IF

   IF m_num_pedido IS NULL THEN
      LET m_msg = 'Não há pedido para o item ', m_cod_item
      LET m_situacao = 'C' 
      LET m_num_pedido = NULL
      RETURN TRUE
   END IF
   
   RETURN TRUE
   
   IF m_count > 1 THEN
      LET m_msg = 'Há  mais de um pedido para o item ', m_cod_item                   
      LET m_situacao = 'C' 
      RETURN TRUE
   END IF
   
   SELECT DISTINCT p.num_pedido 
     INTO m_num_pedido   
     FROM ped_itens i, pedidos p
    WHERE i.cod_empresa = p_cod_empresa
      AND i.cod_item = m_cod_item
      AND i.cod_empresa = p.cod_empresa
      AND i.num_pedido = p.num_pedido
      AND p.ies_sit_pedido <> '9'
      AND p.cod_cliente = m_cod_cliente
      AND p.num_pedido_cli = m_num_ped_comp
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ped_itens')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#------------------------------#   
FUNCTION pol1370_leped_e_item()#
#------------------------------#
   
   LET m_num_pedido = NULL
   LET m_cod_item = NULL
   
   SELECT MAX(num_pedido)
     INTO m_num_pedido  
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido_cli = m_num_ped_comp
      AND cod_cliente = m_cod_cliente
      AND ies_sit_pedido <> '9'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','pedidos/ped_itens')
      RETURN FALSE
   END IF

   IF m_num_pedido IS NULL THEN
      LET m_msg = 'Não há pedido de venda para o pedido de compra ', m_num_ped_comp
      LET m_situacao = 'C' 
      RETURN TRUE
   END IF
   
   SELECT COUNT(cod_item)                             
     INTO m_count                         
     FROM ped_itens                             
    WHERE cod_empresa = p_cod_empresa          
      AND num_pedido = m_num_pedido               
   
   IF m_count > 1 THEN
      LET m_msg = 'Item cliente ', m_item_cliente CLIPPED,
                  ' sem cadastro no POL1372 e não há PV exclusivo p/ ele'
      LET m_situacao = 'C' 
      RETURN TRUE
   END IF
   
   SELECT DISTINCT cod_item                               
     INTO m_cod_item                         
     FROM ped_itens                             
    WHERE cod_empresa = p_cod_empresa          
      AND num_pedido = m_num_pedido               

   IF STATUS = 100 THEN
      LET m_msg = 'Não foi possivel localizar item logix p/ item cliente ', m_item_cliente
      LET m_situacao = 'C' 
   ELSE   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ped_itens')
         RETURN FALSE
      END IF
   END IF
                                          
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1370_checa_pe2()#
#---------------------------#
   
   DEFINE l_data     CHAR(08)
   
   LET mr_edi_pe2.cod_empresa = p_cod_empresa
   LET mr_edi_pe2.num_pedido = m_num_pedido
   
   LET l_data = '20',m_linha[4,9] CLIPPED 
   LET mr_edi_pe2.dat_ult_embar      = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET mr_edi_pe2.num_ult_nff        = m_linha[10,15]
   LET mr_edi_pe2.ser_ult_nff        = m_linha[16,19]
   LET l_data = '20',m_linha[20,25] CLIPPED 
   LET mr_edi_pe2.dat_rec_ult_nff    = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET mr_edi_pe2.qtd_recebida       = m_linha[26,37] CLIPPED
   LET mr_edi_pe2.qtd_receb_acum     = m_linha[38,51] CLIPPED
   LET mr_edi_pe2.qtd_lote_minimo    = m_linha[66,77] CLIPPED
   LET mr_edi_pe2.cod_freq_fornec    = m_linha[78,80] CLIPPED
   LET mr_edi_pe2.dat_lib_producao   = m_linha[81,84] CLIPPED
   LET mr_edi_pe2.dat_lib_mat_prima  = m_linha[85,88] CLIPPED
   LET mr_edi_pe2.cod_local_descarga = m_linha[89,95] CLIPPED
   LET mr_edi_pe2.periodo_entrega    = m_linha[96,99] CLIPPED
   LET mr_edi_pe2.cod_sit_item       = m_linha[100,101] CLIPPED
   LET mr_edi_pe2.identif_tip_prog   = m_linha[102,102] CLIPPED
   LET mr_edi_pe2.pedido_revenda     = m_linha[103,115] CLIPPED
   LET mr_edi_pe2.qualif_progr       = m_linha[116,116] CLIPPED
   LET mr_edi_pe2.id_pe1             = m_id_pe1
   
END FUNCTION

#---------------------------#
FUNCTION pol1370_checa_pe3()#
#---------------------------#
   
   DEFINE l_data       CHAR(08),
          l_divisor    INTEGER
   
   LET m_ind_pe3 = m_ind_pe3 + 1
   LET ma_edi_pe3[m_ind_pe3].cod_empresa    = p_cod_empresa
   LET ma_edi_pe3[m_ind_pe3].num_pedido     = m_num_pedido
   LET ma_edi_pe3[m_ind_pe3].num_sequencia  = m_ind_pe3

   LET l_data = '20',m_linha[4,9] CLIPPED 
   LET ma_edi_pe3[m_ind_pe3].dat_entrega_1  = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET ma_edi_pe3[m_ind_pe3].hor_entrega_1  = m_linha[10,11]
   LET ma_edi_pe3[m_ind_pe3].qtd_entrega_1  = m_linha[12,20]

   LET l_data = '20',m_linha[21,26] CLIPPED 
   LET ma_edi_pe3[m_ind_pe3].dat_entrega_2  = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET ma_edi_pe3[m_ind_pe3].hor_entrega_2  = m_linha[27,28]
   LET ma_edi_pe3[m_ind_pe3].qtd_entrega_2  = m_linha[29,37]

   LET l_data = '20',m_linha[38,43] CLIPPED 
   LET ma_edi_pe3[m_ind_pe3].dat_entrega_3  = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET ma_edi_pe3[m_ind_pe3].hor_entrega_3  = m_linha[44,45]
   LET ma_edi_pe3[m_ind_pe3].qtd_entrega_3  = m_linha[46,54]

   LET l_data = '20',m_linha[55,60] CLIPPED 
   LET ma_edi_pe3[m_ind_pe3].dat_entrega_4  = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET ma_edi_pe3[m_ind_pe3].hor_entrega_4  = m_linha[61,62]
   LET ma_edi_pe3[m_ind_pe3].qtd_entrega_4  = m_linha[63,71]

   LET l_data = '20',m_linha[72,77] CLIPPED 
   LET ma_edi_pe3[m_ind_pe3].dat_entrega_5  = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET ma_edi_pe3[m_ind_pe3].hor_entrega_5  = m_linha[78,79]
   LET ma_edi_pe3[m_ind_pe3].qtd_entrega_5  = m_linha[80,88]

   LET l_data = '20',m_linha[89,94] CLIPPED 
   LET ma_edi_pe3[m_ind_pe3].dat_entrega_6  = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET ma_edi_pe3[m_ind_pe3].hor_entrega_6  = m_linha[95,96]
   LET ma_edi_pe3[m_ind_pe3].qtd_entrega_6  = m_linha[97,105]

   LET l_data = '20',m_linha[106,111] CLIPPED 
   LET ma_edi_pe3[m_ind_pe3].dat_entrega_7  = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET ma_edi_pe3[m_ind_pe3].hor_entrega_7  = m_linha[112,113]
   LET ma_edi_pe3[m_ind_pe3].qtd_entrega_7  = m_linha[114,122]
   LET ma_edi_pe3[m_ind_pe3].id_pe1 = m_id_pe1
   
   SELECT div_qtd_por
     INTO l_divisor
     FROM client_edi_547
    WHERE cod_cliente = m_cod_cliente

   IF STATUS <> 0 OR l_divisor <= 0 THEN    
      RETURN
   END IF

   LET ma_edi_pe3[m_ind_pe3].qtd_entrega_1 = ma_edi_pe3[m_ind_pe3].qtd_entrega_1 / l_divisor
   LET ma_edi_pe3[m_ind_pe3].qtd_entrega_2 = ma_edi_pe3[m_ind_pe3].qtd_entrega_2 / l_divisor
   LET ma_edi_pe3[m_ind_pe3].qtd_entrega_3 = ma_edi_pe3[m_ind_pe3].qtd_entrega_3 / l_divisor
   LET ma_edi_pe3[m_ind_pe3].qtd_entrega_4 = ma_edi_pe3[m_ind_pe3].qtd_entrega_4 / l_divisor
   LET ma_edi_pe3[m_ind_pe3].qtd_entrega_5 = ma_edi_pe3[m_ind_pe3].qtd_entrega_5 / l_divisor
   LET ma_edi_pe3[m_ind_pe3].qtd_entrega_6 = ma_edi_pe3[m_ind_pe3].qtd_entrega_6 / l_divisor
   LET ma_edi_pe3[m_ind_pe3].qtd_entrega_7 = ma_edi_pe3[m_ind_pe3].qtd_entrega_7 / l_divisor
      
END FUNCTION

#---------------------------#
FUNCTION pol1370_checa_pe5()#
#---------------------------#
   
   DEFINE l_data       CHAR(08)
   
   LET m_ind_pe5 = m_ind_pe5 + 1
   LET ma_edi_pe5[m_ind_pe5].cod_empresa    = p_cod_empresa
   LET ma_edi_pe5[m_ind_pe5].num_pedido     = m_num_pedido
   LET ma_edi_pe5[m_ind_pe5].num_sequencia  = m_ind_pe5

   LET l_data = '20',m_linha[4,9] CLIPPED 
   LET ma_edi_pe5[m_ind_pe5].dat_entrega_1  = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET ma_edi_pe5[m_ind_pe5].identif_programa_1  = m_linha[10,10]
   LET ma_edi_pe5[m_ind_pe5].ident_prog_atual_1  = m_linha[11,19]

   LET l_data = '20',m_linha[20,25] CLIPPED 
   LET ma_edi_pe5[m_ind_pe5].dat_entrega_2  = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET ma_edi_pe5[m_ind_pe5].identif_programa_2  = m_linha[26,26]
   LET ma_edi_pe5[m_ind_pe5].ident_prog_atual_2  = m_linha[27,35]

   LET l_data = '20',m_linha[36,41] CLIPPED 
   LET ma_edi_pe5[m_ind_pe5].dat_entrega_3  = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET ma_edi_pe5[m_ind_pe5].identif_programa_3  = m_linha[42,42]
   LET ma_edi_pe5[m_ind_pe5].ident_prog_atual_3  = m_linha[43,51]

   LET l_data = '20',m_linha[52,57] CLIPPED 
   LET ma_edi_pe5[m_ind_pe5].dat_entrega_4  = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET ma_edi_pe5[m_ind_pe5].identif_programa_4  = m_linha[58,58]
   LET ma_edi_pe5[m_ind_pe5].ident_prog_atual_4  = m_linha[59,67]

   LET l_data = '20',m_linha[68,73] CLIPPED 
   LET ma_edi_pe5[m_ind_pe5].dat_entrega_5  = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET ma_edi_pe5[m_ind_pe5].identif_programa_5  = m_linha[74,74]
   LET ma_edi_pe5[m_ind_pe5].ident_prog_atual_5  = m_linha[75,83]

   LET l_data = '20',m_linha[84,89] CLIPPED 
   LET ma_edi_pe5[m_ind_pe5].dat_entrega_6 = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET ma_edi_pe5[m_ind_pe5].identif_programa_6  = m_linha[90,90]
   LET ma_edi_pe5[m_ind_pe5].ident_prog_atual_6  = m_linha[91,99]

   LET l_data = '20',m_linha[100,105] CLIPPED 
   LET ma_edi_pe5[m_ind_pe5].dat_entrega_7 = MDY(l_data[5,6],l_data[7,8],l_data[1,4])
   LET ma_edi_pe5[m_ind_pe5].identif_programa_7  = m_linha[106,106]
   LET ma_edi_pe5[m_ind_pe5].ident_prog_atual_7  = m_linha[107,115]
   LET ma_edi_pe5[m_ind_pe5].id_pe1 = m_id_pe1
   
END FUNCTION

#---------------------------#
FUNCTION pol1370_grava_ped()#
#---------------------------#

   IF NOT pol1370_ins_pe1() THEN
      RETURN FALSE
   END IF
   
   IF mr_edi_pe2.cod_empresa IS NOT NULL THEN
      IF NOT pol1370_ins_pe2() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF m_ind_pe3 > 0 THEN
      IF NOT pol1370_ins_pe3() THEN
         RETURN FALSE
      END IF
      IF m_num_pedido IS NOT NULL THEN
         IF NOT pol1370_gra_ped_itens() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
   
   IF m_ind_pe5 > 0 THEN
      IF NOT pol1370_ins_pe5() THEN
         RETURN FALSE
      END IF
      IF m_num_pedido IS NOT NULL THEN
         IF NOT pol1370_gra_progs_pe5() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF NOT pol1370_ins_pedidos_edi() THEN
      RETURN FALSE
   END IF

   IF NOT pol1370_compara_itens() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1370_ins_pe1()#
#-------------------------#
                
   INSERT INTO edi_pe1_547
    VALUES(mr_edi_pe1.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','edi_pe1_547')                  
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1370_ins_pe2()#
#-------------------------#
                
   INSERT INTO edi_pe2_547
    VALUES(mr_edi_pe2.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','edi_pe2_547')                  
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1370_ins_pe3()#
#-------------------------#
   
   DEFINE l_ind       INTEGER
   
   FOR l_ind = 1 TO m_ind_pe3
       INSERT INTO edi_pe3_547
        VALUES(ma_edi_pe3[l_ind].*)
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','edi_pe3_547')                  
         RETURN FALSE
      END IF        
   END FOR
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1370_ins_pe5()#
#-------------------------#
   
   DEFINE l_ind       INTEGER
   
   FOR l_ind = 1 TO m_ind_pe5
       
       INSERT INTO edi_pe5_547
        VALUES(ma_edi_pe5[l_ind].*)
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','edi_pe5_547')                  
         RETURN FALSE
      END IF                  
   END FOR
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1370_gra_progs_pe5()#
#-------------------------------#

   DEFINE l_ind               INTEGER
   
   # PARA CADA OCORRENCIA DO ma_edi_pe5 PODEMOS TER ATÉ 7 PROGRAMAÇÕES
   
   LET m_num_seq = 0
                   
   FOR l_ind = 1 TO m_ind_pe5
   
       IF ma_edi_pe5[l_ind].dat_entrega_1 IS NOT NULL THEN
          LET m_prz_entrega = ma_edi_pe5[l_ind].dat_entrega_1
          LET m_ident_prog = ma_edi_pe5[l_ind].identif_programa_1
          IF NOT pol1370_ins_progs_pe5() THEN
             RETURN FALSE
          END IF
       END IF

       IF ma_edi_pe5[l_ind].dat_entrega_2 IS NOT NULL THEN
          LET m_prz_entrega = ma_edi_pe5[l_ind].dat_entrega_2
          LET m_ident_prog = ma_edi_pe5[l_ind].identif_programa_2
          IF NOT pol1370_ins_progs_pe5() THEN
             RETURN FALSE
          END IF
       END IF

       IF ma_edi_pe5[l_ind].dat_entrega_3 IS NOT NULL THEN
          LET m_prz_entrega = ma_edi_pe5[l_ind].dat_entrega_3
          LET m_ident_prog = ma_edi_pe5[l_ind].identif_programa_3
          IF NOT pol1370_ins_progs_pe5() THEN
             RETURN FALSE
          END IF
       END IF

       IF ma_edi_pe5[l_ind].dat_entrega_4 IS NOT NULL THEN
          LET m_prz_entrega = ma_edi_pe5[l_ind].dat_entrega_4
          LET m_ident_prog = ma_edi_pe5[l_ind].identif_programa_4
          IF NOT pol1370_ins_progs_pe5() THEN
             RETURN FALSE
          END IF
       END IF

       IF ma_edi_pe5[l_ind].dat_entrega_5 IS NOT NULL THEN
          LET m_prz_entrega = ma_edi_pe5[l_ind].dat_entrega_5
          LET m_ident_prog = ma_edi_pe5[l_ind].identif_programa_5
          IF NOT pol1370_ins_progs_pe5() THEN
             RETURN FALSE
          END IF
       END IF

       IF ma_edi_pe5[l_ind].dat_entrega_6 IS NOT NULL THEN
          LET m_prz_entrega = ma_edi_pe5[l_ind].dat_entrega_6
          LET m_ident_prog = ma_edi_pe5[l_ind].identif_programa_6
          IF NOT pol1370_ins_progs_pe5() THEN
             RETURN FALSE
          END IF
       END IF

       IF ma_edi_pe5[l_ind].dat_entrega_7 IS NOT NULL THEN
          LET m_prz_entrega = ma_edi_pe5[l_ind].dat_entrega_7
          LET m_ident_prog = ma_edi_pe5[l_ind].identif_programa_7
          IF NOT pol1370_ins_progs_pe5() THEN
             RETURN FALSE
          END IF
       END IF
   
   END FOR
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1370_ins_progs_pe5()#
#-------------------------------#
   
   CALL pol1370_calc_data(m_prz_entrega)

   LET m_num_seq = m_num_seq + 1
   
   INSERT INTO ped_itens_edi_pe5_547
    VALUES(p_cod_empresa,
           m_num_pedido,
           m_cod_item,
           m_num_seq,
           m_prz_entrega,
           m_ident_prog,
           m_id_pe1)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ped_itens_edi_pe5_547')                  
      RETURN FALSE
   END IF        
   
   RETURN TRUE        
       
END FUNCTION   

#---------------------------------#
FUNCTION pol1370_ins_pedidos_edi()#
#---------------------------------#

   INSERT INTO pedidos_edi_547
    VALUES(p_cod_empresa,
           m_num_pedido,
           mr_edi_pe1.identif_prog_atual,
           mr_edi_pe1.dat_prog_atual,
           mr_edi_pe1.identif_prog_ant,
           mr_edi_pe1.dat_prog_anterior,
           mr_edi_pe2.cod_freq_fornec,
           mr_edi_pe1.cod_item_cliente,
           mr_edi_pe2.num_ult_nff, m_id_pe1)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','pedidos_edi_547')                  
      RETURN FALSE
   END IF        

   RETURN TRUE

END FUNCTION
   
#-------------------------------#   
FUNCTION pol1370_gra_ped_itens()#
#-------------------------------#

   DEFINE l_ind               INTEGER
   
   # GRAVA AS PROGRAMAÇÕES CARREGADAS SO REGISTRO PE3
   # PARA CADA REGISTRO, PODEMOS TER ATÉ 7 PROGRAMAÇÕES
   
   LET m_num_seq = 0
                   
   FOR l_ind = 1 TO m_ind_pe3
   
       IF ma_edi_pe3[l_ind].dat_entrega_1 IS NOT NULL THEN
          LET m_prz_entrega = ma_edi_pe3[l_ind].dat_entrega_1
          LET m_qtd_entrega = ma_edi_pe3[l_ind].qtd_entrega_1
          IF NOT pol1370_ins_ped_itens() THEN
             RETURN FALSE
          END IF
       END IF

       IF ma_edi_pe3[l_ind].dat_entrega_2 IS NOT NULL THEN
          LET m_prz_entrega = ma_edi_pe3[l_ind].dat_entrega_2
          LET m_qtd_entrega = ma_edi_pe3[l_ind].qtd_entrega_2
          IF NOT pol1370_ins_ped_itens() THEN
             RETURN FALSE
          END IF
       END IF

       IF ma_edi_pe3[l_ind].dat_entrega_3 IS NOT NULL THEN
          LET m_prz_entrega = ma_edi_pe3[l_ind].dat_entrega_3
          LET m_qtd_entrega = ma_edi_pe3[l_ind].qtd_entrega_3
          IF NOT pol1370_ins_ped_itens() THEN
             RETURN FALSE
          END IF
       END IF

       IF ma_edi_pe3[l_ind].dat_entrega_4 IS NOT NULL THEN
          LET m_prz_entrega = ma_edi_pe3[l_ind].dat_entrega_4
          LET m_qtd_entrega = ma_edi_pe3[l_ind].qtd_entrega_4
          IF NOT pol1370_ins_ped_itens() THEN
             RETURN FALSE
          END IF
       END IF

       IF ma_edi_pe3[l_ind].dat_entrega_5 IS NOT NULL THEN
          LET m_prz_entrega = ma_edi_pe3[l_ind].dat_entrega_5
          LET m_qtd_entrega = ma_edi_pe3[l_ind].qtd_entrega_5
          IF NOT pol1370_ins_ped_itens() THEN
             RETURN FALSE
          END IF
       END IF

       IF ma_edi_pe3[l_ind].dat_entrega_6 IS NOT NULL THEN
          LET m_prz_entrega = ma_edi_pe3[l_ind].dat_entrega_6
          LET m_qtd_entrega = ma_edi_pe3[l_ind].qtd_entrega_6
          IF NOT pol1370_ins_ped_itens() THEN
             RETURN FALSE
          END IF
       END IF

       IF ma_edi_pe3[l_ind].dat_entrega_7 IS NOT NULL THEN
          LET m_prz_entrega = ma_edi_pe3[l_ind].dat_entrega_7
          LET m_qtd_entrega = ma_edi_pe3[l_ind].qtd_entrega_7
          IF NOT pol1370_ins_ped_itens() THEN
             RETURN FALSE
          END IF
       END IF       
   
   END FOR
      
   RETURN TRUE
   
END FUNCTION
   
#-------------------------------#
FUNCTION pol1370_ins_ped_itens()#
#-------------------------------#
   
   IF NOT pol1370_le_ped_itens() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1370_ins_itens_edi_547() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1370_le_ped_itens()#
#------------------------------#
   
   DEFINE  l_achou    SMALLINT
   
   # busca posição atual do item do pedido
  
  LET l_achou = FALSE
  
  DECLARE cq_pos_atu CURSOR FOR 
   SELECT (qtd_pecas_solic - 
           qtd_pecas_atend - qtd_pecas_cancel), 
           qtd_pecas_atend,
           qtd_pecas_solic
      FROM ped_itens 
     WHERE cod_empresa = p_cod_empresa 
       AND num_pedido = m_num_pedido
       AND cod_item  = m_cod_item
       AND prz_entrega =  m_prz_entrega
  
  FOREACH cq_pos_atu INTO m_qtd_saldo, m_qtd_atend, m_qtd_solic

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ped_itens:cq_pos_atu')
         RETURN FALSE
      END IF
      
      LET l_achou = TRUE
      EXIT FOREACH
  
  END FOREACH
  
   IF NOT l_achou THEN
      LET m_qtd_solic = 0
      LET m_qtd_atend = 0
      LET m_qtd_saldo = 0
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-----------------------------------#
FUNCTION pol1370_ins_itens_edi_547()#
#-----------------------------------#
      
   CALL pol1370_calc_data(m_prz_entrega)
   CALL pol1370_ve_prazo(m_prz_entrega)
   
   LET m_num_seq = m_num_seq + 1
   
   INSERT INTO ped_itens_edi_547
    VALUES(p_cod_empresa,
           m_num_pedido,
           m_num_seq,
           m_cod_item,
           m_prz_entrega,
           m_qtd_solic,      
           m_qtd_atend,
           m_qtd_saldo,
           m_qtd_entrega,    
           m_qtd_entrega,
           m_id_pe1,
           m_critica)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ped_itens_edi_547')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1370_calc_data(l_data)#
#---------------------------------#

   DEFINE l_data       DATE,
          l_dia        INTEGER
   
   LET l_dia = WEEKDAY(l_data)
   
   IF l_dia = 6 THEN
      LET l_data = l_data + 2
   ELSE
      IF l_dia = 0 THEN
         LET l_data = l_data + 1
      END IF
   END IF
   
  RETURN l_data

END FUNCTION  

#--------------------------------#
FUNCTION pol1370_ve_prazo(l_data)#
#--------------------------------#

   DEFINE l_data      DATE
   
   LET m_critica = NULL
   
   IF l_data < TODAY THEN
      LET m_critica = "PRZ VENCIDO"
      RETURN
   END IF      
   
   IF m_qtd_solic > 0 THEN
      IF m_qtd_saldo <> m_qtd_entrega THEN
         LET m_critica = "ATUALIZAR"
      ELSE
         LET m_critica = "DESCARTAR"
      END IF      
   ELSE
      IF m_qtd_entrega > 0 THEN
         LET m_critica = "INCLUIR"
      ELSE
         LET m_critica = "DESCARTAR"
      END IF
   END IF

END FUNCTION

#---------------------------#
FUNCTION pol1370_pesquisar()#
#---------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   CALL pol1370_limpa_campos()
   LET m_carregando = FALSE
   CALL pol1370_set_param(TRUE)
   LET mr_arquivo.processado = 'T'
   LET m_ies_cons = FALSE
   CALL _ADVPL_set_property(m_cliente,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1370_set_param(l_status)#
#-----------------------------------#
   
   DEFINE l_status         SMALLINT
   
   CALL _ADVPL_set_property(m_panel_cabec,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_dat_carga,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_processado,"EDITABLE",FALSE)   
   CALL _ADVPL_set_property(m_cliente,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_cli,"EDITABLE",l_status)

END FUNCTION

#---------------------------#
FUNCTION pol1370_pesq_canc()#
#---------------------------#

   CALL pol1370_limpa_campos()
   CALL pol1370_ativa_desativa(FALSE)
   CALL pol1370_set_param(FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1370_pesq_conf()#
#---------------------------#

   DEFINE l_query     CHAR(800)
   
   LET m_id_arquivoa = m_id_arquivo
   
   IF mr_arquivo.processado = 'T' THEN
      LET mr_arquivo.processado = ''
   END IF

   LET l_query = 
         " SELECT max(id_arquivo) FROM arquivo_edi_547 ",
         " WHERE cod_empresa = '",p_cod_empresa,"' ",
         "  AND cod_cliente LIKE '","%",mr_arquivo.cod_cliente CLIPPED,"%","' ",
         " GROUP BY cod_cliente "
               
   PREPARE var_pesq FROM l_query
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('PREPARE','var_pesq')
      RETURN FALSE
   END IF
   
   DECLARE cq_pesq SCROLL CURSOR WITH HOLD FOR var_pesq

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql("DECLARE","cq_pesq",0)
      RETURN FALSE
   END IF
    
   OPEN cq_pesq
    
   FETCH cq_pesq INTO m_id_arquivo
    
   IF STATUS = 100 THEN
      LET m_msg = 'Não há registros p/ o parêmtros informados.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("FETCH","cq_pesq",0)
         RETURN FALSE
      END IF
   END IF

   LET m_id_arquivoa = m_id_arquivo
    
   IF NOT pol1370_pesq_exibe() THEN
      RETURN FALSE
   END IF
   
   CALL pol1370_ativa_desativa(FALSE)
   CALL pol1370_set_param(FALSE)
      
   LET m_ies_cons = TRUE

   RETURN TRUE   
    
END FUNCTION

#----------------------------#
FUNCTION pol1370_pesq_exibe()#
#----------------------------#

   LET m_carregando = TRUE
   LET m_excluiu = FALSE
   
   SELECT dat_carga, hor_carga, 
          nom_arquivo, cod_cliente, 
          processado
     INTO mr_arquivo.dat_carga,
          mr_arquivo.hor_carga,
          mr_arquivo.den_arquivo,
          mr_arquivo.cod_cliente,
          mr_arquivo.processado
     FROM arquivo_edi_547
    WHERE cod_empresa = p_cod_empresa
      AND id_arquivo = m_id_arquivo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','arquivo_edi_547')
      RETURN FALSE
   END IF
   
   SELECT num_cgc_cpf, nom_cliente 
      INTO mr_arquivo.cnpj_cliente,
           mr_arquivo.nom_cliente 
      FROM clientes 
     WHERE cod_cliente = mr_arquivo.cod_cliente    

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','clientes')
      RETURN FALSE
   END IF
           
   LET p_status = LOG_progresspopup_start(
       "Processando...","pol1370_monta_grades","PROCESS")  
      
   LET m_carregando = FALSE
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#----------------------------#
FUNCTION pol1370_pesq_first()#
#----------------------------#

   IF NOT pol1370_pesq_pagina('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#---------------------------#
FUNCTION pol1370_pesq_next()#
#---------------------------#

   IF NOT pol1370_pesq_pagina('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#-------------------------------#
FUNCTION pol1370_pesq_previous()#
#-------------------------------#

   IF NOT pol1370_pesq_pagina('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#---------------------------#
FUNCTION pol1370_pesq_last()#
#---------------------------#

   IF NOT pol1370_pesq_pagina('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#------------------------------------#
FUNCTION pol1370_pesq_pagina(l_opcao)#
#------------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1370_pesq_informou() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_id_arquivoa = m_id_arquivo

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_pesq INTO m_id_arquivo
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_pesq INTO m_id_arquivo
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_pesq INTO m_id_arquivo
         WHEN 'P' 
            FETCH PREVIOUS cq_pesq INTO m_id_arquivo
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_pesq")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_id_arquivo = m_id_arquivoa
         EXIT WHILE
      ELSE
         SELECT 1
           FROM arquivo_edi_547
          WHERE cod_empresa = p_cod_empresa
            AND id_arquivo = m_id_arquivo
         IF STATUS = 0 THEN
            IF pol1370_pesq_exibe() THEN
               LET l_achou = TRUE
            END IF
            EXIT WHILE
         END IF
      END IF               
   
   END WHILE
   
   RETURN l_achou
   
END FUNCTION

#-------------------------------#
FUNCTION pol1370_pesq_informou()#
#-------------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Pesquise uma importação previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1370_monta_grades()#
#------------------------------#
  
   DEFINE l_qtd_pedido    SMALLINT
   
   
   INITIALIZE ma_pedido TO NULL
   CALL _ADVPL_set_property(m_brz_pedido,"CLEAR")
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   SELECT COUNT(*) INTO m_count
     FROM edi_pe1_547
    WHERE cod_empresa = p_cod_empresa
      AND id_arquivo = m_id_arquivo
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','edi_pe1_547')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Arquivo não contém pdidos.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN TRUE
   END IF
   
   LET m_count = m_count + 10
   
   LET m_ind = 1
   LET ma_pedido[m_ind].mensagem = 'ITENS DO ARQUIVO EDI'
   
   CALL _ADVPL_set_property(m_brz_pedido,"LINE_FONT_COLOR",m_ind,63,72,204)
   
   LET m_ind = 2
   LET m_qtd_erro = 0
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
         
   DECLARE cq_monta CURSOR FOR
    SELECT num_pedido,
           cod_item,
           cod_item_cliente,
           num_pedido_compra,
           mensagem,
           id_pe1,
           situacao
      FROM edi_pe1_547 
     WHERE cod_empresa = p_cod_empresa
       AND id_arquivo = m_id_arquivo

   FOREACH cq_monta INTO 
      ma_pedido[m_ind].num_pedido,        
      ma_pedido[m_ind].cod_item,          
      ma_pedido[m_ind].item_cliente,  
      ma_pedido[m_ind].num_pc, 
      ma_pedido[m_ind].mensagem,          
      ma_pedido[m_ind].id_pe1,
      ma_pedido[m_ind].situacao           
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cq_monta')
         RETURN FALSE
      END IF
      
      LET m_progres = LOG_progresspopup_increment("PROCESS")

      IF ma_pedido[m_ind].mensagem IS NOT NULL THEN
         LET m_qtd_erro = m_qtd_erro + 1
      END IF

      CALL _ADVPL_set_property(m_brz_pedido,"LINE_FONT_COLOR",m_ind,0,0,0)
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 500 THEN
         LET m_msg = 'Limite de itens previstos ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH

   LET ma_pedido[m_ind].mensagem = 'ITENS SÓ NA CARTEIRA DE PEDIDOS'
   CALL _ADVPL_set_property(m_brz_pedido,"LINE_FONT_COLOR",m_ind,255,0,0)

   LET m_ind = m_ind + 1
   CALL pol1370_le_carteira() 
      
   LET m_qtd_item = m_ind - 1
   CALL _ADVPL_set_property(m_brz_pedido,"ITEM_COUNT", m_qtd_item)
   LET m_id_pe1 = ma_pedido[2].id_pe1
   CALL pol1370_le_programacao()
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1370_le_carteira()#
#-----------------------------#
   
   DEFINE l_id_pe1      INTEGER,
          l_item_cli    CHAR(30)
   
   SELECT MAX(id_pe1) INTO l_id_pe1 
     FROM edi_pe1_547  
    WHERE cod_empresa = p_cod_empresa 
      AND id_arquivo = m_id_arquivo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','edi_pe1_547')
      RETURN
   END IF
   
   IF l_id_pe1 IS NULL THEN
      LET l_id_pe1 = 0
   END IF
   
   LET m_num_id = l_id_pe1
   
   DECLARE cq_carteira CURSOR FOR
    SELECT distinct
           p.num_pedido, 
           i.cod_item, 
           p.num_pedido_cli, 
           ' ','N'
      FROM pedidos p, ped_itens i
     WHERE p.cod_empresa = p_cod_empresa
       AND p.cod_cliente = mr_arquivo.cod_cliente 
       AND p.ies_sit_pedido <> '9'
       AND i.cod_empresa = p.cod_empresa 
       AND i.num_pedido = p.num_pedido
       AND i.qtd_pecas_atend = 0 
       AND i.qtd_pecas_romaneio = 0 
       AND (i.qtd_pecas_solic - i.qtd_pecas_cancel) > 0
       AND i.cod_item NOT IN 
             (SELECT e.cod_item FROM edi_pe1_547 e 
               WHERE e.cod_empresa = i.cod_empresa AND  e.id_arquivo = m_id_arquivo)
     ORDER BY p.num_pedido, i.cod_item

   FOREACH cq_carteira INTO

      ma_pedido[m_ind].num_pedido,        
      ma_pedido[m_ind].cod_item,          
      ma_pedido[m_ind].num_pc, 
      ma_pedido[m_ind].mensagem,          
      ma_pedido[m_ind].situacao           

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cq_monta')
         RETURN 
      END IF
      
      LET m_progres = LOG_progresspopup_increment("PROCESS")
      
      LET l_id_pe1 = l_id_pe1 + 1
      LET  ma_pedido[m_ind].id_pe1 = l_id_pe1
      
      DECLARE cq_cli_item CURSOR FOR
       SELECT cod_item_cliente                                                 
         FROM cliente_item                                             
        WHERE cod_empresa = p_cod_empresa                              
          AND cod_cliente_matriz = mr_arquivo.cod_cliente                       
          AND cod_item = ma_pedido[m_ind].cod_item                        
      
      FOREACH cq_cli_item INTO l_item_cli
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','cliente_item:cq_cli_item')
            RETURN 
         END IF
      
         LET ma_pedido[m_ind].item_cliente = l_item_cli
      
      END FOREACH 

      CALL _ADVPL_set_property(m_brz_pedido,"LINE_FONT_COLOR",m_ind,0,0,0)
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 500 THEN
         LET m_msg = 'Limite de itens previstos ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH

END FUNCTION                  
   
#--------------------------------#
FUNCTION pol1370_le_programacao()#
#--------------------------------#
   
   DEFINE l_ies_prog      CHAR(1),
          l_dat_abertura  DATE,
          l_situacao      CHAR(01),
          l_num_pedido    INTEGER,
          l_cod_item      CHAR(15)

   DROP TABLE w_progs_edi;
   
   CREATE TABLE w_progs_edi (
       num_pedido         CHAR(06),
       ies_select         CHAR(01),
       prz_entrega        DATE,
       programacao        CHAR(11),
       qtd_solic          DECIMAL(10,3),
       qtd_saldo          DECIMAL(10,3),
       qtd_solic_nova     DECIMAL(10,3),
       mensagem           CHAR(30),
       num_sequencia      INTEGER
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','tabele w_progs_edi')
      RETURN 
   END IF
   
   CREATE INDEX ix_w_progs_edi ON w_progs_edi(num_pedido)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','indice w_progs_edi')
      RETURN 
   END IF
       
   INITIALIZE ma_prog TO NULL
   CALL _ADVPL_set_property(m_brz_prog,"CLEAR")

   IF m_id_pe1 IS NULL OR m_id_pe1 = 0 THEN
      RETURN 
   END IF
      
   LET m_ind = 1
   LET m_clik_cab = FALSE

   IF m_id_pe1 > m_num_id THEN
      LET l_num_pedido = ma_pedido[m_lin_atu].num_pedido
      LET l_cod_item = ma_pedido[m_lin_atu].cod_item
      LET l_situacao = 'N'      
   ELSE   
    SELECT situacao INTO l_situacao
      FROM edi_pe1_547
      WHERE cod_empresa = p_cod_empresa
        AND id_pe1 = m_id_pe1

    IF STATUS <> 0 THEN
       CALL log003_err_sql('SELECT','edi_pe1_547:situacao')
       LET l_situacao = 'C'
    END IF
   
    DECLARE cq_le_prog CURSOR FOR
    SELECT ped_itens_edi_547.prz_entrega,
           ped_itens_edi_547.num_pedido,
           ped_itens_edi_547.qtd_solic,
           ped_itens_edi_547.qtd_saldo,
           ped_itens_edi_547.qtd_solic_nova,
           ped_itens_edi_547.mensagem,
           ped_itens_edi_547.num_sequencia,
           ped_itens_edi_pe5_547.ies_programacao,
           ped_itens_edi_pe5_547.dat_abertura,
           ped_itens_edi_pe5_547.cod_item
      FROM ped_itens_edi_547, ped_itens_edi_pe5_547
     WHERE ped_itens_edi_547.cod_empresa = p_cod_empresa
       AND ped_itens_edi_547.id_pe1 = m_id_pe1
       AND ped_itens_edi_547.cod_empresa = ped_itens_edi_pe5_547.cod_empresa
       AND ped_itens_edi_547.id_pe1 = ped_itens_edi_pe5_547.id_pe1
       AND ped_itens_edi_547.num_sequencia = ped_itens_edi_pe5_547.num_sequencia
       
   FOREACH cq_le_prog INTO
      ma_prog[m_ind].prz_entrega,  
      ma_prog[m_ind].num_pedido,
      ma_prog[m_ind].qtd_solic,     
      ma_prog[m_ind].qtd_saldo, 
      ma_prog[m_ind].qtd_solic_nova,
      ma_prog[m_ind].mensagem,
      ma_prog[m_ind].num_sequencia,
      l_ies_prog,
      l_dat_abertura,
      m_cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cq_le_prog')
         EXIT FOREACH
      END IF
      
      LET m_num_pedido = ma_prog[m_ind].num_pedido
      
      IF l_num_pedido IS NULL OR l_num_pedido = 0 THEN
         LET l_num_pedido = m_num_pedido
         LET l_cod_item = m_cod_item
      END IF
      
      LET ma_prog[m_ind].ies_select = 'N'
      
      IF l_dat_abertura IS NOT NULL THEN
         LET ma_prog[m_ind].prz_entrega = l_dat_abertura
      END IF
      
      LET m_prz_entrega = ma_prog[m_ind].prz_entrega

      IF NOT pol1370_le_ped_itens() THEN
         RETURN FALSE
      END IF
      
      LET ma_prog[m_ind].qtd_solic = m_qtd_solic
      LET ma_prog[m_ind].qtd_saldo = m_qtd_saldo
      
      CASE l_ies_prog
         WHEN '1' 
            LET ma_prog[m_ind].programacao = 'FIRME'
         WHEN '3' 
            LET ma_prog[m_ind].programacao = 'REQUISIC.'
         WHEN '4' 
            LET ma_prog[m_ind].programacao = 'PLANEJADO'
         OTHERWISE
            LET ma_prog[m_ind].programacao = 'DOL'
      END CASE
            
      IF ma_prog[m_ind].mensagem = 'PROCESSADO' THEN
      ELSE
         LET m_qtd_entrega = ma_prog[m_ind].qtd_solic_nova
         CALL pol1370_ve_prazo(m_prz_entrega)
         LET ma_prog[m_ind].mensagem = m_critica
      END IF      
      
      DELETE FROM w_progs_edi 
       WHERE num_pedido = m_num_pedido
         AND prz_entrega = m_prz_entrega
         
      INSERT INTO w_progs_edi VALUES(ma_prog[m_ind].*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','w_progs_edi:cq_le_prog')
         EXIT FOREACH
      END IF
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 500 THEN
         LET m_msg = 'Limite de programações previstas ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
    END FOREACH
    FREE cq_le_prog

   END IF
      
   IF l_num_pedido IS NOT NULL THEN
   
      DECLARE cq_prog_antes CURSOR FOR
       SELECT num_pedido, prz_entrega, 'NAO ENVIADA', qtd_pecas_solic,
              (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio),
              'CANCELAR',  num_sequencia
         FROM ped_itens 
        WHERE cod_empresa = p_cod_empresa 
          AND num_pedido = l_num_pedido
          AND cod_item = l_cod_item
          AND qtd_pecas_atend = 0
          AND qtd_pecas_romaneio = 0
          AND (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio) > 0
          AND prz_entrega NOT IN (select prz_entrega from w_progs_edi)

      FOREACH cq_prog_antes INTO 
         ma_prog[1].num_pedido,  
         ma_prog[1].prz_entrega, 
         ma_prog[1].programacao, 
         ma_prog[1].qtd_solic,   
         ma_prog[1].qtd_saldo,   
         ma_prog[1].mensagem,    
         ma_prog[1].num_sequencia

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','ped_itens:cq_prog_antes')
            EXIT FOREACH
         END IF

         LET ma_prog[1].qtd_solic_nova = NULL
         LET ma_prog[1].ies_select = 'N'

         INSERT INTO w_progs_edi VALUES(ma_prog[1].*)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('INSERT','w_progs_edi:cq_prog_antes')
            EXIT FOREACH
         END IF
      
      END FOREACH
      
      FREE cq_prog_antes
      
      LET m_ind = 1
      
      CALL _ADVPL_set_property(m_brz_prog,"CLEAR_ALL_LINE_FONT_COLOR")
      
      DECLARE cq_prog_temp CURSOR FOR
       SELECT *
         FROM w_progs_edi
        ORDER BY prz_entrega        

      FOREACH cq_prog_temp INTO ma_prog[m_ind].*

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','w_progs_edi:cq_prog_temp')
            EXIT FOREACH
         END IF
         
         IF ma_prog[m_ind].programacao = 'FIRME' THEN 
            CALL _ADVPL_set_property(m_brz_prog,"LINE_FONT_COLOR",m_ind,34,177,76)
         ELSE
            CALL _ADVPL_set_property(m_brz_prog,"LINE_FONT_COLOR",m_ind,0,0,0)
         END IF
         
         IF ma_prog[m_ind].mensagem = 'CANCELAR' THEN 
            CALL _ADVPL_set_property(m_brz_prog,"LINE_FONT_COLOR",m_ind,255,0,0)
         END IF

         LET m_ind = m_ind + 1
      
         IF m_ind > 500 THEN
            LET m_msg = 'Limite de programações previstas ultrapassou.'
            CALL log0030_mensagem(m_msg,'info')
            EXIT FOREACH
         END IF
      
      END FOREACH
      
      FREE cq_prog_temp     
      
   END IF
   
   LET m_qtd_prog = m_ind - 1
   CALL _ADVPL_set_property(m_brz_prog,"ITEM_COUNT", m_qtd_prog)

   IF l_situacao = 'N' THEN
      CALL _ADVPL_set_property(m_brz_prog,"ENABLE",TRUE)
   ELSE
      CALL _ADVPL_set_property(m_brz_prog,"ENABLE",FALSE)
   END IF
         
END FUNCTION

#----------------------------------#
 FUNCTION pol1370_prende_registro()#
#----------------------------------#
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM arquivo_edi_547
     WHERE cod_empresa =  p_cod_empresa
       AND id_arquivo = m_id_arquivo
     FOR UPDATE 
    
    OPEN cq_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_prende")
       RETURN FALSE
    END IF
    
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_prende")
      CLOSE cq_prende
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------------#
FUNCTION pol1370_ve_possibilidade()#
#----------------------------------#

   IF mr_arquivo.cod_cliente IS NULL OR m_excluiu THEN
      LET m_msg = 'Não há arquivo na tela a ser excluído'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF   
   
   IF mr_arquivo.processado = 'S' THEN
      LET m_msg = 'Esse arquivo já está processado'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#----------------------------#
FUNCTION pol1370_exclui_arq()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   IF NOT pol1370_ve_possibilidade() THEN
      RETURN FALSE
   END IF

   LET m_msg = 'Dese mesmo excluir o arquivo ?'

   IF NOT LOG_question(m_msg) THEN
      RETURN FALSE
   END IF
      
   CALL LOG_transaction_begin()

   IF NOT pol1370_prende_registro() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   LET p_status = LOG_progresspopup_start(
       "Processando...","pol1370_proc_exclusao","PROCESS")  
   
   IF NOT p_status THEN
      LET m_msg = 'Operação cancelada..'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL LOG_transaction_rollback()
      CLOSE cq_prende
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   CLOSE cq_prende
   CALL pol1370_limpa_campos()
   LET m_excluiu = TRUE

   LET m_qtd_erro = 0
   LET m_msg = 'Operação efetuada com sucesso.'
   CALL pol1370_ativa_desativa(FALSE)
   
   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1370_proc_exclusao()#
#-------------------------------#
   
   DEFINE l_progres      SMALLINT

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')   
   
   LET m_count = _ADVPL_get_property(m_brz_pedido,"ITEM_COUNT")
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   FOR m_ind = 1 TO m_count
       LET l_progres = LOG_progresspopup_increment("PROCESS")
       LET m_id_pe1 = ma_pedido[m_ind].id_pe1
       IF NOT pol1370_exclusao() THEN
          RETURN FALSE
       END IF
   END FOR

   DELETE FROM arquivo_edi_547
    WHERE cod_empresa = p_cod_empresa
      AND id_arquivo = m_id_arquivo
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','arquivo_edi_547')
      RETURN FALSE
   END IF      

   DELETE FROM edi_pe1_547
    WHERE cod_empresa = p_cod_empresa
      AND id_arquivo = m_id_arquivo
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','edi_pe1_547')
      RETURN FALSE
   END IF      

   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1370_exclusao()#
#--------------------------#

   DELETE FROM edi_pe2_547
    WHERE cod_empresa = p_cod_empresa
      AND id_pe1 = m_id_pe1
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','edi_pe2_547')
      RETURN FALSE
   END IF         

   DELETE FROM edi_pe3_547
    WHERE cod_empresa = p_cod_empresa
      AND id_pe1 = m_id_pe1
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','edi_pe3_547')
      RETURN FALSE
   END IF      

   DELETE FROM edi_pe5_547
    WHERE cod_empresa = p_cod_empresa
      AND id_pe1 = m_id_pe1
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','edi_pe5_547')
      RETURN FALSE
   END IF      

   DELETE FROM pedidos_edi_547
    WHERE cod_empresa = p_cod_empresa
      AND id_pe1 = m_id_pe1
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','pedidos_edi_547')
      RETURN FALSE
   END IF      

   DELETE FROM ped_itens_edi_547
    WHERE cod_empresa = p_cod_empresa
      AND id_pe1 = m_id_pe1
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','ped_itens_edi_547')
      RETURN FALSE
   END IF      

   DELETE FROM ped_itens_edi_pe5_547
    WHERE cod_empresa = p_cod_empresa
      AND id_pe1 = m_id_pe1
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','ped_itens_edi_pe5_547')
      RETURN FALSE
   END IF      
   
   RETURN TRUE

END FUNCTION
   
#---------------------------#
FUNCTION pol1370_consistir()#
#---------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   IF NOT pol1370_ve_possibilidade() THEN
      RETURN FALSE
   END IF
   
   IF m_qtd_erro = 0 THEN
      LET m_msg = 'Não há erros de importaçã nesse arquivo.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF        
   
   #LET m_qtd_erro = 0
   
   CALL LOG_transaction_begin()

   LET p_status = LOG_progresspopup_start(
       "Processando...","pol1370_proc_consist","PROCESS")  
   
   IF NOT p_status THEN
      LET m_msg = 'Operação cancelada..'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()

   IF m_qtd_erro > 0 THEN
      LET m_msg = 'Alguns pedidos foram criticados..'
   ELSE
      LET m_msg = 'Operação efetuada com sucesso.'
   END IF

   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1370_proc_consist()#
#------------------------------#
  
   DEFINE l_progres         SMALLINT
     
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')   
   LET m_count = _ADVPL_get_property(m_brz_pedido,"ITEM_COUNT")      
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   FOR m_ind = 1 TO m_count
       LET l_progres = LOG_progresspopup_increment("PROCESS")
       IF ma_pedido[m_ind].situacao = 'C' THEN
          IF NOT pol1370_le_item_ped() THEN
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   RETURN TRUE
   
END FUNCTION
   
#-----------------------------#
FUNCTION pol1370_le_item_ped()#
#-----------------------------#

   LET m_cod_item = ma_pedido[m_ind].cod_item
   LET m_num_ped_comp = ma_pedido[m_ind].num_pc
   LET m_cod_cliente = mr_arquivo.cod_cliente
   LET m_id_pe1 = ma_pedido[m_ind].id_pe1
   LET m_item_cliente = ma_pedido[m_ind].item_cliente
   LET m_situacao = 'N'
   LET m_msg = ''
      
   IF NOT pol1370_pega_pedido() THEN
      RETURN FALSE
   END IF
   
   IF m_cod_item IS NULL THEN
      IF m_msg IS NULL THEN
         LET m_msg = 'Não foi possivel localizar um pedido/item correspodente no Logix.'
      END IF      
      LET m_situacao = 'C' 
   ELSE
      IF m_num_pedido IS NULL THEN
         IF m_msg IS NULL THEN
            LET m_msg = 'Não há pedido para o item ', m_cod_item
         END IF
         LET m_situacao = 'C' 
      ELSE
      END IF   
   END IF

   LET ma_pedido[m_ind].num_pedido = m_num_pedido
   LET ma_pedido[m_ind].cod_item = m_cod_item
   
   CALL LOG_transaction_begin()

   IF NOT pol1370_grava_info() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   LET ma_pedido[m_ind].mensagem = m_msg
   
   RETURN TRUE

END FUNCTION

#----------------------------#   
FUNCTION pol1370_grava_info()#
#----------------------------#  

   UPDATE edi_pe1_547 
      SET cod_item = m_cod_item,
          num_pedido = m_num_pedido,
          mensagem = m_msg,
          situacao = m_situacao
    WHERE cod_empresa = p_cod_empresa
      AND id_pe1 = m_id_pe1   

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','edi_pe1_547')
      RETURN FALSE
   END IF

   UPDATE edi_pe2_547 
      SET num_pedido = m_num_pedido
    WHERE cod_empresa = p_cod_empresa
      AND id_pe1 = m_id_pe1   

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','edi_pe2_547')
      RETURN FALSE
   END IF

   UPDATE pedidos_edi_547 
      SET num_pedido = m_num_pedido
    WHERE cod_empresa = p_cod_empresa
      AND id_pe1 = m_id_pe1   

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','pedidos_edi_547')
      RETURN FALSE
   END IF

   UPDATE edi_pe3_547 
      SET num_pedido = m_num_pedido
    WHERE cod_empresa = p_cod_empresa
      AND id_pe1 = m_id_pe1   

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','edi_pe3_547')
      RETURN FALSE
   END IF

   UPDATE edi_pe5_547 
      SET num_pedido = m_num_pedido
    WHERE cod_empresa = p_cod_empresa
      AND id_pe1 = m_id_pe1   

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','edi_pe5_547')
      RETURN FALSE
   END IF
   
   IF m_situacao = 'N' THEN      
      IF NOT pol1370_grv_itens_pe5() THEN
         RETURN FALSE
      END IF   
      IF NOT pol1370_grav_itens() THEN
         RETURN FALSE
      END IF
      IF m_ind_pe3 > 0 THEN
         IF NOT pol1370_gra_ped_itens() THEN
            RETURN FALSE
         END IF
      END IF      
      IF m_ind_pe5 > 0 THEN
         IF NOT pol1370_gra_progs_pe5() THEN
            RETURN FALSE
         END IF
      END IF      
      CALL pol1370_le_programacao()  
   END IF

   IF NOT pol1370_compara_itens() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1370_grav_itens()#
#----------------------------#
   
   DEFINE l_ind       INTEGER
   
   INITIALIZE ma_edi_pe3 TO NULL
   
   LET l_ind = 1
   
   DECLARE cq_pe3 CURSOR FOR
    SELECT * FROM edi_pe3_547
     WHERE cod_empresa = p_cod_empresa
       AND id_pe1 = m_id_pe1   
   
   FOREACH cq_pe3 INTO ma_edi_pe3[l_ind].*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_pe3')
         RETURN FALSE
      END IF
      
      IF l_ind <= m_ind_pe5 THEN
         IF ma_edi_pe5[l_ind].dat_entrega_1 IS NOT NULL THEN
            LET ma_edi_pe3[l_ind].dat_entrega_1 = ma_edi_pe5[l_ind].dat_entrega_1
         END IF
         IF ma_edi_pe5[l_ind].dat_entrega_2 IS NOT NULL THEN
            LET ma_edi_pe3[l_ind].dat_entrega_2 = ma_edi_pe5[l_ind].dat_entrega_2
         END IF
         IF ma_edi_pe5[l_ind].dat_entrega_3 IS NOT NULL THEN
            LET ma_edi_pe3[l_ind].dat_entrega_3 = ma_edi_pe5[l_ind].dat_entrega_3
         END IF
         IF ma_edi_pe5[l_ind].dat_entrega_4 IS NOT NULL THEN
            LET ma_edi_pe3[l_ind].dat_entrega_4 = ma_edi_pe5[l_ind].dat_entrega_4
         END IF
         IF ma_edi_pe5[l_ind].dat_entrega_5 IS NOT NULL THEN
            LET ma_edi_pe3[l_ind].dat_entrega_5 = ma_edi_pe5[l_ind].dat_entrega_5
         END IF
         IF ma_edi_pe5[l_ind].dat_entrega_6 IS NOT NULL THEN
            LET ma_edi_pe3[l_ind].dat_entrega_6 = ma_edi_pe5[l_ind].dat_entrega_6
         END IF
         IF ma_edi_pe5[l_ind].dat_entrega_7 IS NOT NULL THEN
            LET ma_edi_pe3[l_ind].dat_entrega_7 = ma_edi_pe5[l_ind].dat_entrega_7
         END IF
      END IF       
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 500 THEN
         CALL log0030_mensagem('Qtd programações previstas ultrapassou.')   
         RETURN FALSE
      END IF           
   
   END FOREACH
   
   LET m_ind_pe3 = l_ind - 1
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1370_grv_itens_pe5()#
#-------------------------------#
   
   DEFINE l_ind       INTEGER
   
   INITIALIZE ma_edi_pe5 TO NULL
   
   LET l_ind = 1
   
   DECLARE cq_pe5 CURSOR FOR
    SELECT * FROM edi_pe5_547
     WHERE cod_empresa = p_cod_empresa
       AND id_pe1 = m_id_pe1   
   
   FOREACH cq_pe5 INTO ma_edi_pe5[l_ind].*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_pe5')
         RETURN FALSE
      END IF
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 500 THEN
         CALL log0030_mensagem('Qtd programações previstas ultrapassou.')   
         RETURN FALSE
      END IF           
   
   END FOREACH
   
   LET m_ind_pe5 = l_ind - 1
      
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1370_processar()#
#---------------------------#    
   
   DEFINE l_ind       INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_arquivo.cod_cliente IS NULL OR m_excluiu THEN
      LET m_msg = 'Não há arquivo na tela a ser excluído'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF   
   
   LET m_lin_ped = _ADVPL_get_property(m_brz_pedido,"ROW_SELECTED")

   IF ma_pedido[m_lin_ped].num_pedido IS NULL OR
      ma_pedido[m_lin_ped].num_pedido = 0 THEN
      LET m_msg = 'Selecione uma inha com pedido'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF   
   
   IF ma_pedido[m_lin_ped].mensagem IS NULL OR ma_pedido[m_lin_ped].mensagem = ' ' THEN
   ELSE
      LET m_msg = 'O pedido selecionado contém erro.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF   

   {IF ma_pedido[m_lin_ped].situacao = 'P' THEN
      LET m_msg = 'O pedido/item selecionado já foi processado.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF   }
   
   LET m_count = 0
   
   FOR l_ind = 1 TO m_qtd_prog
       IF ma_prog[l_ind].ies_select = 'S' THEN
          LET m_count = m_count + 1
       END IF
   END FOR
   
   IF m_count = 0 THEN
      LET m_msg = 'Nunhuma programação foi selecionada p/ atualização'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF   
      
   LET m_msg = 'A carteira de pedidos será atualzada com\n',
               'as programações Marcadas. Deseja continuar ?'

   IF NOT LOG_question(m_msg) THEN
      RETURN FALSE
   END IF

   LET m_id_pe1 = ma_pedido[m_lin_ped].id_pe1   
   LET m_num_pedido = ma_pedido[m_lin_ped].num_pedido
   LET m_cod_item = ma_pedido[m_lin_ped].cod_item
   
   CALL LOG_transaction_begin()
   
   LET p_status = LOG_progresspopup_start(
       "Processando...","pol1370_proc_edi","PROCESS")  

   IF NOT p_status THEN
      LET m_msg = 'Operação cancelada..'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   #LET mr_arquivo.processado = 'S'
   #LET ma_pedido[m_lin_ped].situacao = 'P'
   
   LET m_msg = 'Operação efetuada com sucesso.'

   CALL log0030_mensagem(m_msg,'info')
   
   CALL pol1370_le_programacao()  
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1370_proc_edi()#
#--------------------------#
   
   DEFINE l_progres      SMALLINT,
          l_ind          INTEGER
          
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')   
   
   CALL LOG_progresspopup_set_total("PROCESS",m_qtd_prog)

   FOR l_ind = 1 TO m_qtd_prog
   
       LET l_progres = LOG_progresspopup_increment("PROCESS")

       IF ma_prog[l_ind].ies_select = 'S' THEN
          LET m_qtd_solic = ma_prog[l_ind].qtd_solic
          LET m_qtd_nova = ma_prog[l_ind].qtd_solic_nova
          LET m_qtd_saldo = ma_prog[l_ind].qtd_saldo
          #LET m_dat_abertura = ma_prog[l_ind].prz_entrega
          LET m_prz_entrega = ma_prog[l_ind].prz_entrega
          LET m_seq_prog = ma_prog[l_ind].num_sequencia
          
          IF ma_prog[l_ind].mensagem = 'CANCELAR' THEN          
             UPDATE ped_itens 
                SET qtd_pecas_cancel = qtd_pecas_cancel + m_qtd_saldo
              WHERE cod_empresa = p_cod_empresa
                AND num_pedido = ma_prog[l_ind].num_pedido
                AND num_sequencia  = ma_prog[l_ind].num_sequencia

             IF STATUS <> 0 THEN
                CALL log003_err_sql('UPDATE','ped_itens')
                RETURN FALSE
             END IF
             LET mr_audit.mensagem = 'CANCELOU SALDO DA PROGRAMAÇÃO '
             IF NOT pol1370_ins_audit() THEN
                RETURN FALSE
             END IF
          ELSE
             IF m_qtd_nova <> m_qtd_saldo THEN
                IF NOT pol1370_grv_programacao() THEN
                   RETURN FALSE
                END IF
             END IF
          END IF      
       END IF
       
   END FOR
      
   {IF NOT pol1370_atu_pe1() THEN
      RETURN FALSE
   END IF}

   {IF NOT pol1370_atu_arq_edi() THEN
      RETURN FALSE
   END IF}
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1370_grv_programacao()#
#---------------------------------#
                                             
   IF m_qtd_nova = 0 THEN                     
      IF m_qtd_saldo > 0 THEN        
         LET mr_audit.mensagem = 'CANCELOU SALDO DA PROGRAMAÇÃO '
         IF NOT pol1370_atu_prog('C') THEN    
            RETURN FALSE                      
         END IF   
      ELSE
         LET mr_audit.mensagem = NULL                            
      END IF                                  
   ELSE                                       
      IF m_qtd_solic = 0 THEN                 
         IF NOT pol1370_add_prog() THEN       
            RETURN FALSE                      
         END IF         
         LET mr_audit.mensagem = 'INCLUIU A PROGRAMAÇÃO '                     
      ELSE                       
         LET mr_audit.mensagem = 'ALTEROU SALDO DA PROGRAMAÇÃO '
         IF NOT pol1370_atu_prog('A') THEN    
            RETURN FALSE                      
         END IF                               
      END IF                                  
   END IF                                     
  
   IF mr_audit.mensagem IS NOT NULL THEN
      IF NOT pol1370_ins_audit() THEN
         RETURN FALSE
      END IF
   END IF
     
   SELECT qtd_pecas_solic,
          qtd_pecas_atend,
          (qtd_pecas_solic - 
           qtd_pecas_atend - 
           qtd_pecas_cancel - 
           qtd_pecas_romaneio) 
    INTO m_qtd_solic,
         m_qtd_atend,
         m_qtd_saldo
    FROM ped_itens
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido = m_num_pedido 
     AND num_sequencia = m_num_seq

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ped_itens:saldo')
      RETURN FALSE
   END IF
   
   UPDATE ped_itens_edi_547
      SET qtd_solic = m_qtd_solic,
          qtd_atend = m_qtd_atend,
          qtd_saldo = m_qtd_saldo,
          mensagem = 'PROCESSADO'
    WHERE cod_empresa = p_cod_empresa
      AND id_pe1 = m_id_pe1
      AND num_pedido = m_num_pedido 
      AND num_sequencia = m_seq_prog

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ped_itens_edi_547')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1370_ins_audit()#
#---------------------------#
   
   LET mr_audit.cod_empresa = p_cod_empresa
   LET mr_audit.num_pedido = m_num_pedido
   LET mr_audit.cod_item = m_cod_item
   LET mr_audit.prz_entrega = m_prz_entrega
   LET mr_audit.usuario = p_user
   LET mr_audit.dat_operacao = TODAY
   
   INSERT INTO edi_audit_547
    VALUES(mr_audit.*)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','edi_audit_547')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
   

#------------------------------#
FUNCTION pol1370_atu_prog(l_op)#
#------------------------------#
   
   DEFINE l_op           CHAR(01),
          l_qtd_saldo    DECIMAL(10,3),
          l_num_seq      INTEGER,
          l_qtd_canc     DECIMAL(10,3)
   
   LET m_num_seq = 0
   
   DECLARE cq_cancel CURSOR FOR      
    SELECT num_sequencia,
           qtd_pecas_solic,
           (qtd_pecas_solic - 
            qtd_pecas_atend - 
            qtd_pecas_cancel - 
            qtd_pecas_romaneio) 
     FROM ped_itens
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido 
      AND cod_item  = m_cod_item
      AND prz_entrega = m_prz_entrega
         
   FOREACH cq_cancel INTO l_num_seq, m_qtd_solic, l_qtd_saldo           

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_cancel')
         RETURN FALSE
      END IF
      
      LET m_num_seq = l_num_seq
      EXIT FOREACH
      
   END FOREACH
   
   IF m_num_seq > 0 THEN
      IF l_op = 'A' THEN
         IF m_qtd_nova > l_qtd_saldo THEN
            LET m_qtd_solic = m_qtd_solic + m_qtd_nova - l_qtd_saldo
            LET l_qtd_canc = 0
         ELSE
            LET l_qtd_canc = l_qtd_saldo - m_qtd_nova
         END IF
      ELSE
         LET l_qtd_canc = l_qtd_saldo
      END IF
            
      UPDATE ped_itens 
         SET qtd_pecas_cancel = qtd_pecas_cancel + l_qtd_canc,
             qtd_pecas_solic = m_qtd_solic
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = m_num_pedido 
         AND num_sequencia  = m_num_seq

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','ped_itens')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1370_add_prog()#
#--------------------------#
   
   DEFINE l_qtd_saldo    DECIMAL(10,3),
          l_num_seq      INTEGER

   SELECT num_list_preco,
          cod_cliente
     INTO m_num_lista,
          m_cod_cliente
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','pedidos:add_prog')
      RETURN FALSE
   END IF

   IF NOT pol1370_le_lista() THEN
      RETURN FALSE
   END IF   
   
   IF m_pre_unit = 0 THEN
      LET m_msg = 
       'Não foi possivel encontrar o preço do item \n a partir da lista de preço ', m_num_lista
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   SELECT MAX(num_sequencia)
     INTO m_num_seq
     FROM ped_itens
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido 
      AND cod_item  = m_cod_item
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ped_itens:max1')
      RETURN FALSE
   END IF
   
   IF m_num_seq IS NULL THEN
      SELECT MAX(num_sequencia)
        INTO m_num_seq
        FROM ped_itens
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = m_num_pedido 
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ped_itens:max2')
         RETURN FALSE
      END IF
   END IF

   IF m_num_seq IS NULL THEN
      LET m_num_seq = 0
   END IF
      
   LET m_num_seq = m_num_seq + 1
     
   INSERT INTO ped_itens
    VALUES(p_cod_empresa, 
           m_num_pedido,
           m_num_seq,
           m_cod_item,0,
           m_pre_unit,
           m_qtd_nova,0,0,0,
           m_prz_entrega,
           0,0,0,0,0)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ped_itens')
      RETURN FALSE
   END IF
   
   RETURN TRUE           

END FUNCTION

#--------------------------#
FUNCTION pol1370_le_lista()#
#--------------------------#

   DEFINE l_transacao  INTEGER
   
   LET l_transacao = func016_le_lista(
      m_num_lista, m_cod_cliente, m_cod_item)
   
   IF l_transacao = 0 THEN
      LET m_pre_unit = 0
      IF g_msg IS NOT NULL THEN
         CALL log0030_mensagem(g_msg,'info')
         RETURN FALSE
      END IF
   ELSE
      SELECT pre_unit 
        INTO m_pre_unit
        FROM desc_preco_item 
       WHERE cod_empresa = p_cod_empresa
         AND cod_cliente = m_cod_cliente
         AND num_transacao = l_transacao
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','desc_preco_item')
         RETURN FALSE
      END IF
   END IF   
   
   RETURN TRUE

END FUNCTION 

#-------------------------#
FUNCTION pol1370_atu_pe1()#
#-------------------------#

   UPDATE edi_pe1_547 SET situacao = 'P'
    WHERE cod_empresa = p_cod_empresa
      AND id_pe1 = m_id_pe1

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','edi_pe1_547')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol1370_atu_arq_edi()#
#-----------------------------#

   UPDATE arquivo_edi_547 SET processado = 'S'
    WHERE cod_empresa = p_cod_empresa
      AND id_arquivo = m_id_arquivo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','arquivo_edi_547')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1370_proc_all()#
#--------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT pol1370_ve_possibilidade() THEN
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_programacao,"EDITABLE",TRUE)  
   CALL _ADVPL_set_property(m_panel_cabec,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_den_arquivo,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_programacao,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1370_proc_all_canc()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')      
   CALL _ADVPL_set_property(m_programacao,"EDITABLE",FALSE)  
   CALL _ADVPL_set_property(m_panel_cabec,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_den_arquivo,"EDITABLE",TRUE)

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1370_proc_all_conf()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')  
   
   IF mr_arquivo.programacao IS NULL THEN
      LET m_msg = 'Selecione o tipo de programação.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_programacao,"GET_FOCUS")
      RETURN FALSE
   END IF
      
   CALL _ADVPL_set_property(m_programacao,"EDITABLE",FALSE)  
   CALL _ADVPL_set_property(m_panel_cabec,"EDITABLE",FALSE) 
   CALL _ADVPL_set_property(m_den_arquivo,"EDITABLE",TRUE)

   CALL LOG_transaction_begin()
   
   LET p_status = LOG_progresspopup_start(
       "Processando...","pol1370_proc_todos","PROCESS")  

   IF NOT p_status THEN
      LET m_msg = 'Operação cancelada..'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   LET mr_arquivo.processado = 'S'
   LET m_msg = 'Operação efetuada com sucesso.'

   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1370_proc_todos()#
#----------------------------#
   
   DEFINE l_progres      SMALLINT,
          l_qtd_pe1      INTEGER

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')   
   
   LET l_qtd_pe1 = _ADVPL_get_property(m_brz_pedido,"ITEM_COUNT")   
   
   CALL LOG_progresspopup_set_total("PROCESS",l_qtd_pe1)
   
   FOR m_ind = 1 TO l_qtd_pe1
   
       LET l_progres = LOG_progresspopup_increment("PROCESS")
       
       IF ma_pedido[m_ind].situacao = 'C' THEN
       ELSE
          LET m_id_pe1 = ma_pedido[m_ind].id_pe1
          IF NOT pol1370_atu_carteira() THEN
             RETURN FALSE
          END IF
          IF NOT pol1370_atu_pe1() THEN
             RETURN FALSE
          END IF
       END IF
   END FOR

   IF NOT pol1370_atu_arq_edi() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1370_atu_carteira()#
#------------------------------#
         
   DECLARE cq_progs CURSOR FOR
    SELECT ped_itens_edi_547.num_pedido, 
           ped_itens_edi_547.num_sequencia,
           ped_itens_edi_547.cod_item, 
           ped_itens_edi_547.prz_entrega, 
           ped_itens_edi_547.qtd_solic,
           ped_itens_edi_547.qtd_solic_nova,
           ped_itens_edi_pe5_547.dat_abertura, 
           ped_itens_edi_pe5_547.ies_programacao
      FROM ped_itens_edi_547, ped_itens_edi_pe5_547
     WHERE ped_itens_edi_547.cod_empresa = p_cod_empresa
       AND ped_itens_edi_547.id_pe1 = m_id_pe1
       AND ped_itens_edi_547.cod_empresa = ped_itens_edi_pe5_547.cod_empresa
       AND ped_itens_edi_547.id_pe1 = ped_itens_edi_pe5_547.id_pe1
        AND ped_itens_edi_547.num_sequencia = ped_itens_edi_pe5_547.num_sequencia        
        AND ((ped_itens_edi_pe5_547.ies_programacao = mr_arquivo.programacao
             AND mr_arquivo.programacao <> 'T') OR (1=1 AND mr_arquivo.programacao = 'T'))
        
   FOREACH cq_progs INTO 
      m_num_pedido,
      m_seq_prog,
      m_cod_item,
      m_prz_entrega,
      m_qtd_solic,
      m_qtd_nova,
      m_dat_abertura,
      m_ies_prog
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_progs')
         RETURN FALSE
      END IF

      IF m_dat_abertura IS NOT NULL THEN
         LET m_prz_entrega = m_dat_abertura
      END IF
      
      IF NOT pol1370_le_ped_itens() THEN
         RETURN FALSE
      END IF

      IF m_qtd_nova = m_qtd_solic THEN
         CONTINUE FOREACH
      END IF
      
      IF NOT pol1370_grv_programacao() THEN
         RETURN FALSE
      END IF
               
   END FOREACH
   
   RETURN TRUE

END FUNCTION   

#-------------------------------#
FUNCTION pol1370_compara_itens()#
#-------------------------------#

   DECLARE cq_ci_pe3 CURSOR FOR
    SELECT num_pedido,
           cod_item,
           num_sequencia,
           prz_entrega
      FROM ped_itens_edi_547      
     WHERE cod_empresa = p_cod_empresa
       AND id_pe1 = m_id_pe1

   FOREACH cq_ci_pe3 INTO
           m_num_pedido,                
           m_cod_item,                  
           m_num_seq,                   
           m_prz_entrega
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ped_itens_edi_547:cq_ci_pe3')                  
         RETURN FALSE
      END IF        

      SELECT dat_abertura
        INTO m_dat_abertura
        FROM ped_itens_edi_pe5_547      
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido =  m_num_pedido
         AND num_sequencia = m_num_seq
         AND cod_item = m_cod_item
         AND id_pe1 = m_id_pe1

      IF STATUS = 100 THEN
         INSERT INTO ped_itens_edi_pe5_547                        
          VALUES(p_cod_empresa,                                   
                 m_num_pedido,                                    
                 m_cod_item,                                      
                 m_num_seq,                                       
                 m_prz_entrega,                                   
                 '2',m_id_pe1)                                        
                                                                  
         IF STATUS <> 0 THEN                                      
            CALL log003_err_sql('INSERT','ped_itens_edi_pe5_547') 
            RETURN FALSE                                          
         END IF                                                   
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','ped_itens_edi_547:cq_ci_pe3')                  
            RETURN FALSE
         END IF
      END IF        
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION
   
  