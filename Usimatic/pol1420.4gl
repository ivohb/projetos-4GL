#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1420                                                 #
# OBJETIVO: CARGA E PROCESSAMENTO DE PEDIDOS EDI  - USIMATIC        #
# AUTOR...: IVO                                                     #
# DATA....: 27/01/21                                                #
#-------------------------------------------------------------------#


{
Segue as anota��es que fiz durante a apresenta��o do EDI KOMATSU


1-	Num mesmo arquivo tem programa��o de mais de um c�digo de cliente LUGAR GEOGRAFICO , SUZ E ARU.
2-	Fazer programa de cadastro que liga LUGAR GEOGRAFICO  com CODIGO DE CLIENTE, SUZ E ARU.
3-	Criar filtro pra permitir sele��o para processamento, Cancelamento, Erro, Inclus�o
4-	Pedir confirma��o no bot�o PROCESSAR TOTAL 
5-	Agravar texto item e tabela XPED ITEMPED
6-	Incluir seq no relat�rio
7-	Tem que haver a rela��o entre o ITEM DO CLIENTE x ITEM LOGIX, se n�o houver consistir e n�o carregar nada desse item.
8-	Se  encontrar mais de um pedido no Logix para o item do cliente, usar o de data de emiss�o mais atual
9-	Se encontrar dois itens num mesmo pedido de venda, dar mensagem para a Raissa cancelar o saldo do item que n�o pode estar naquele pedido, ent�o tem que fazer essa valida��o apenas para itens com saldo, sen�o a Raissa vai cancelar o saldo e a consist�ncia vai continuar continuar considerando dois itens para um pedido. 

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
       m_num_pedido      INTEGER,
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
       m_registro        VARCHAR(200),
       m_pos_ini         INTEGER,
       m_pos_fim         INTEGER,
       m_per_firme       DECIMAL(3,0),
       m_excluiu         SMALLINT,
       m_cliticou        SMALLINT,
       m_qtd_itens_edi   INTEGER,
       m_progres         SMALLINT,
       m_clik_cab        SMALLINT,
       m_ja_tem          SMALLINT,
       m_ies_origem      VARCHAR(01),
       m_id_pedido       INTEGER,
       m_opcao           VARCHAR(01),
       m_id_item         INTEGER,
       m_num_pc          VARCHAR(15),
       m_seq_pc          INTEGER,
       m_id_audit        INTEGER,
       m_dat_atu         DATE,
       m_hor_atu         VARCHAR(08),
       m_houve_erro      SMALLINT,
       m_pedido_comp     VARCHAR(17),
       m_dat_hor         VARCHAR(20)
       
DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_stat_prog       VARCHAR(10),
       m_stat_imp        VARCHAR(10),
       m_panel_cabec     VARCHAR(10),
       m_panel_item      VARCHAR(10),
       m_panel_prog      VARCHAR(10),
       m_brz_pedido      VARCHAR(10),
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
       m_car_ped         SMALLINT,
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
       tip_prog          CHAR(01)
END RECORD

DEFINE ma_files ARRAY[50] OF CHAR(100)

DEFINE ma_pedido         ARRAY[2000] OF RECORD
   id_pedido             INTEGER,     
   situacao              CHAR(01),    
   cod_cliente           varchar(15), 
   item_cliente          CHAR(15),    
   num_pedido            DECIMAL(6,0),    
   cod_item              CHAR(15),    
   mensagem              CHAR(120) 
END RECORD

DEFINE ma_prog            ARRAY[1000] OF RECORD
       num_pedido         CHAR(06),
       ies_select         CHAR(01),
       prz_entrega        DATE,
       qtd_solic          DECIMAL(10,3),
       qtd_atual          DECIMAL(10,3),
       operacao           VARCHAR(10),
       mensagem           VARCHAR(60),
       situacao           CHAR(01),
       ies_origem         CHAR(01),
       id_item            INTEGER,
       num_pc             VARCHAR(15),
       seq_pc             INTEGER       
END RECORD

DEFINE ma_erro            ARRAY[3000] OF RECORD
    id_arquivo            integer,
    id_pedido             INTEGER,   
    mensagem              char(120)
END RECORD

DEFINE mr_pedido          RECORD
   id_arquivo             INTEGER,       
   id_pedido              INTEGER,       
   cod_empresa            varchar(02),   
   cod_cliente            varchar(15),   
   item_cliente           CHAR(15),      
   num_pedido             DECIMAL(6,0),   
   cod_item               CHAR(15),      
   mensagem               CHAR(120),     
   situacao               CHAR(01)      
END RECORD

DEFINE mr_itens          RECORD
   id_arquivo            INTEGER,
   id_pedido             INTEGER,       
   id_item               INTEGER,       
   cod_empresa           VARCHAR(02),   
   num_pc                VARCHAR(15),   
   seq_pc                DECIMAL(6,0),  
   prz_entrega           DATE,          
   qtd_solic             DECIMAL(10,3), 
   qtd_atual             DECIMAL(10,3), 
   operacao              VARCHAR(10),
   mensagem              VARCHAR(60),
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
       m_pre_unit         LIKE ped_itens.pre_unit

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

DEFINE mr_prog           RECORD
   id_arquivo            INTEGER,     
   cod_empresa           VARCHAR(02),
   cod_cliente           VARCHAR(15),
   fornecedor            VARCHAR(30), 
   item_cliente          VARCHAR(30), 
   und                   VARCHAR(03), 
   revisao	             VARCHAR(10), 
   data	                 VARCHAR(10), 
   prazo	               VARCHAR(10), 
   alm	                 VARCHAR(30), 
   ordem	               VARCHAR(15), 
   pos	                 VARCHAR(10), 
   op	                   VARCHAR(30), 
   valor_unit	           VARCHAR(12), 
   valor_total	         VARCHAR(14), 
   ordenado	             VARCHAR(10), 
   entregue	             VARCHAR(10), 
   pendente	             VARCHAR(10), 
   data_2	               VARCHAR(10), 
   nf	                   VARCHAR(10), 
   rese	                 VARCHAR(30), 
   rcf                   VARCHAR(05), 
   local_geogr           VARCHAR(30)  
END RECORD

#-----------------#
FUNCTION pol1420()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300

   LET p_versao = "pol1420-12.00.01  "
   LET m_car_ped = TRUE
   
   IF pol1420_cria_tabs() THEN
      CALL pol1420_menu()
   END IF
    
END FUNCTION

#---------------------------#
FUNCTION pol1420_cria_tabs()#
#---------------------------#

   DROP TABLE w_progs_komatsu;
   
   CREATE TEMP TABLE w_progs_komatsu (
       num_pedido         CHAR(06),
       ies_origem         CHAR(01),
       prz_entrega        DATE,             
       qtd_solic          DECIMAL(10,3),    
       qtd_atual          DECIMAL(10,3),    
       operacao           VARCHAR(10),
       mensagem           VARCHAR(60),
       situacao           CHAR(01),
       id_item            INTEGER,
       num_pc             VARCHAR(15),
       seq_pc             INTEGER
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','tabele w_progs_komatsu')
      RETURN FALSE
   END IF
   
   CREATE INDEX ix_w_progs_komatsu ON w_progs_komatsu(num_pedido)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','indice ix_w_progs_komatsu')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION
   
#----------------------#
FUNCTION pol1420_menu()#
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
    
    LET l_titulo = 'CARGA E PROCESSAMENTO DE PEDIDOS EDI - ', p_versao
    
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
    CALL _ADVPL_set_property(l_carga,"TOOLTIP","Importar um arquivo EDI")
    CALL _ADVPL_set_property(l_carga,"EVENT","pol1420_carga")
    CALL _ADVPL_set_property(l_carga,"CONFIRM_EVENT","pol1420_carga_conf")
    CALL _ADVPL_set_property(l_carga,"CANCEL_EVENT","pol1420_carga_canc")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TOOLTIP","Pesquisar caragas efetuadas")
    CALL _ADVPL_set_property(l_find,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1420_pesquisar")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1420_pesq_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1420_pesq_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"TOOLTIP","Excluir arquivo importado")
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1420_exclui_arq")

    LET l_consist = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_consist,"IMAGE","CONSISTIR_EX")     
    CALL _ADVPL_set_property(l_consist,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_consist,"TOOLTIP","Processa consist�ncia geral dos dados")
    CALL _ADVPL_set_property(l_consist,"EVENT","pol1420_consistir")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Processa itens selecionados")
    CALL _ADVPL_set_property(l_proces,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1420_processar")
    CALL _ADVPL_set_property(l_proces,"CONFIRM_EVENT","pol1420_processar_conf")
    CALL _ADVPL_set_property(l_proces,"CANCEL_EVENT","pol1420_processar_canc")

    LET l_proc_all = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proc_all,"IMAGE","PROC_ALL")     
    CALL _ADVPL_set_property(l_proc_all,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_proc_all,"ENABLE",TRUE) 
    CALL _ADVPL_set_property(l_proc_all,"TOOLTIP","Processa todos os itens")
    CALL _ADVPL_set_property(l_proc_all,"EVENT","pol1420_proc_all")

    LET l_print = _ADVPL_create_component(NULL,"LPRINTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_print,"EVENT","pol1420_tela_print")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1420_parametros(l_panel)
    CALL pol1420_pedidos(l_panel)
    CALL pol1420_programacoes(l_panel)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#---------------------------------------#
FUNCTION pol1420_parametros(l_container)#
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
    CALL _ADVPL_set_property(l_label,"POSITION",07,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_cabec)     
    CALL _ADVPL_set_property(m_cliente,"POSITION",55,10)     
    CALL _ADVPL_set_property(m_cliente,"VARIABLE",mr_arquivo,"cod_cliente")
    CALL _ADVPL_set_property(m_cliente,"LENGTH",15) 
    CALL _ADVPL_set_property(m_cliente,"EDITABLE",FALSE)     
    CALL _ADVPL_set_property(m_cliente,"VALID","pol1420_ck_cliente")

    LET m_lupa_cli = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_cabec)
    CALL _ADVPL_set_property(m_lupa_cli,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cli,"POSITION",187,10)     
    CALL _ADVPL_set_property(m_lupa_cli,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cli,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_lupa_cli,"CLICK_EVENT","pol1420_pesq_cliente")

    {LET m_empresa = _ADVPL_create_component(NULL,"LCOMBOBOX",m_panel_cabec)     
    CALL _ADVPL_set_property(m_empresa,"POSITION",70,10)     
    CALL _ADVPL_set_property(m_empresa,"ADD_ITEM","0","Select     ")
    CALL _ADVPL_set_property(m_empresa,"VARIABLE",mr_arquivo,"cod_empresa")
    CALL _ADVPL_set_property(m_empresa,"VALID","pol1420_ck_empresa")}

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",210,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Per�odo firme:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_firme = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_cabec)     
    CALL _ADVPL_set_property(m_firme,"POSITION",290,10)     
    CALL _ADVPL_set_property(m_firme,"VARIABLE",mr_arquivo,"per_firme")
    CALL _ADVPL_set_property(m_firme,"LENGTH",3) 
    CALL _ADVPL_set_property(m_firme,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_firme,"VALID","pol1420_ck_periodo")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",325,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Dias")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",365,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","At� data:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    

    LET m_dat_de = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel_cabec)     
    CALL _ADVPL_set_property(m_dat_de,"POSITION",445,10)     
    CALL _ADVPL_set_property(m_dat_de,"ENABLE",FALSE)     
    CALL _ADVPL_set_property(m_dat_de,"VARIABLE",mr_arquivo,"dat_ate")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",613,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_den_arquivo = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_cabec)     
    CALL _ADVPL_set_property(m_den_arquivo,"POSITION",668,10)     
    CALL _ADVPL_set_property(m_den_arquivo,"VARIABLE",mr_arquivo,"den_arquivo")
    CALL _ADVPL_set_property(m_den_arquivo,"LENGTH",40) 
    CALL _ADVPL_set_property(m_den_arquivo,"VISIBLE",TRUE)
    CALL _ADVPL_set_property(m_den_arquivo,"VISIBLE",TRUE)     
    CALL _ADVPL_set_property(m_den_arquivo,"EDITABLE",FALSE)     
    CALL _ADVPL_set_property(m_den_arquivo,"CAN_GOT_FOCUS",FALSE)

    LET m_arquivo = _ADVPL_create_component(NULL,"LCOMBOBOX",m_panel_cabec)     
    CALL _ADVPL_set_property(m_arquivo,"POSITION",668,10)     
    CALL _ADVPL_set_property(m_arquivo,"ADD_ITEM","0","Select    ")
    CALL _ADVPL_set_property(m_arquivo,"VARIABLE",mr_arquivo,"nom_arquivo")
    CALL _ADVPL_set_property(m_arquivo,"VISIBLE",FALSE)     

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",1005,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Carga:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    

    LET m_dat_carga = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_cabec)     
    CALL _ADVPL_set_property(m_dat_carga,"POSITION",1048,10)     
    CALL _ADVPL_set_property(m_dat_carga,"LENGTH",10) 
    CALL _ADVPL_set_property(m_dat_carga,"ENABLE",FALSE)     
    CALL _ADVPL_set_property(m_dat_carga,"VARIABLE",mr_arquivo,"dat_carga")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",1143,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","As:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    

    LET m_dat_carga = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_cabec)     
    CALL _ADVPL_set_property(m_dat_carga,"POSITION",1164,10)     
    CALL _ADVPL_set_property(m_dat_carga,"LENGTH",8) 
    CALL _ADVPL_set_property(m_dat_carga,"ENABLE",FALSE)     
    CALL _ADVPL_set_property(m_dat_carga,"VARIABLE",mr_arquivo,"hor_carga")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",1245,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Proces:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    

    LET m_processado = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_cabec)
    CALL _ADVPL_set_property(m_processado,"POSITION",1292,10)
    CALL _ADVPL_set_property(m_processado,"LENGTH",1) 
    CALL _ADVPL_set_property(m_processado,"ENABLE",FALSE)     
    CALL _ADVPL_set_property(m_processado,"VARIABLE",mr_arquivo,"processado")
    
END FUNCTION

#------------------------------------#
FUNCTION pol1420_pedidos(l_container)#
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
    #CALL _ADVPL_set_property(m_brz_pedido,"AFTER_ROW_EVENT","pol1420_ped_after_row")
    CALL _ADVPL_set_property(m_brz_pedido,"BEFORE_ROW_EVENT","pol1420_ped_before_row")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","St")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","situacao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ciente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cliente")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_pedido)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item ciente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","item_cliente")

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
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",280)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    CALL _ADVPL_set_property(m_brz_pedido,"SET_ROWS",ma_pedido,1)
    CALL _ADVPL_set_property(m_brz_pedido,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_pedido,"CAN_REMOVE_ROW",FALSE)

END FUNCTION

#-----------------------------------------#
FUNCTION pol1420_programacoes(l_container)#
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
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1420_chec_selecao")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER_CLICK_EVENT","pol1420_marca_desmarca")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","prz_entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd EDI")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_solic")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd carteira")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_atual")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Opera��o")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","operacao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_prog)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_brz_prog,"SET_ROWS",ma_prog,1)
    CALL _ADVPL_set_property(m_brz_prog,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_prog,"CAN_REMOVE_ROW",FALSE)

END FUNCTION

#----------------------------#
FUNCTION pol1420_ck_cliente()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_arquivo.cod_cliente IS NULL THEN
      LET m_msg = 'Informe o cliente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET mr_arquivo.nom_cliente = pol1420_le_cliente(mr_arquivo.cod_cliente)
   
   IF mr_arquivo.nom_cliente IS NULL THEN
      LET m_msg = 'Cliente n�o existe.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1420_ck_empresa()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_arquivo.cod_empresa IS NULL THEN
      LET m_msg = 'Selecione a empresa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1420_le_caminho() THEN
      RETURN FALSE
   END IF

   IF NOT pol1420_carrega_lista() THEN
      RETURN FALSE
   END IF

   IF NOT pol1420_le_periodo() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1420_le_cliente(l_cod)#
#---------------------------------#
   
   DEFINE l_cod      LIKE clientes.cod_cliente,
          l_desc     LIKE clientes.nom_cliente
   
   SELECT nom_cliente 
     INTO l_desc
     FROM clientes 
    WHERE cod_cliente = l_cod    

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("SELECT",'clientes:pcpl')
   END IF
         
   RETURN l_desc

END FUNCTION

#------------------------------#
FUNCTION pol1420_pesq_cliente()#
#------------------------------#

   CALL pol1420_zoom_cliente('P') 

END FUNCTION

#----------------------------------#
FUNCTION pol1420_zoom_cliente(l_op)#
#----------------------------------#

    DEFINE l_codigo         LIKE clientes.cod_cliente,
           l_descri         LIKE clientes.nom_cliente,
           l_lin_atu        INTEGER,
           l_op             CHAR(01)
    
    IF m_zoom_cliente IS NULL THEN
       LET m_zoom_cliente = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_cliente,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_cliente,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_descri = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")
    
    IF l_codigo IS NOT NULL THEN
       IF l_op = 'P' THEN
          LET mr_arquivo.cod_cliente = l_codigo
          LET mr_arquivo.nom_cliente = l_descri
          CALL _ADVPL_set_property(m_cliente,"GET_FOCUS")
       ELSE
          LET mr_print.cod_cliente = l_codigo
          LET mr_print.nom_cliente = l_descri
       END IF
    END IF        
    
END FUNCTION
      
#--------------------------------#
FUNCTION pol1420_ped_before_row()#
#--------------------------------#

   IF m_car_ped THEN
      RETURN TRUE
   END IF
      
   LET m_lin_atu = _ADVPL_get_property(m_brz_pedido,"ROW_SELECTED")

   LET p_status = pol1420_set_programacao()
      
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1420_limpa_campos()#
#------------------------------#
   
   LET m_car_ped = TRUE
   INITIALIZE mr_arquivo.* TO NULL
   INITIALIZE ma_pedido, ma_prog TO NULL
   CALL _ADVPL_set_property(m_brz_pedido,"SET_ROWS",ma_pedido,1)
   CALL _ADVPL_set_property(m_brz_prog,"SET_ROWS",ma_prog,1)
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1420_set_carga(l_status)#
#-----------------------------------#
   
   DEFINE l_status      SMALLINT
   
   CALL _ADVPL_set_property(m_panel_cabec,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_arquivo,"VISIBLE",l_status)  
   CALL _ADVPL_set_property(m_den_arquivo,"VISIBLE",NOT l_status)  
   CALL _ADVPL_set_property(m_cliente,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_cli,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_firme,"EDITABLE",l_status)

END FUNCTION

#-----------------------#
FUNCTION pol1420_carga()#
#-----------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   CALL pol1420_limpa_campos()
   LET m_ies_info = 'N'
   LET mr_arquivo.cod_empresa = p_cod_empresa
   
   IF NOT pol1420_ck_empresa() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'C'
   
   CALL pol1420_set_carga(TRUE)
   CALL _ADVPL_set_property(m_cliente,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1420_carrega_empresa()#
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
FUNCTION pol1420_carga_canc()#
#----------------------------#

   CALL pol1420_limpa_campos()
   LET m_ies_info = 'N'
   CALL pol1420_set_carga(FALSE)
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1420_ck_periodo()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_arquivo.per_firme IS NULL OR mr_arquivo.per_firme < 0 THEN
      LET m_msg = 'Informe a quantidade de dias do periodo firme.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET mr_arquivo.dat_ate = TODAY + mr_arquivo.per_firme
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1420_le_periodo()#
#----------------------------#

   SELECT per_firme
     INTO mr_arquivo.per_firme
     FROM periodo_firme_komatsu
    WHERE cod_empresa = mr_arquivo.cod_empresa 

   IF STATUS = 100 THEN
      LET mr_arquivo.per_firme = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','periodo_firme_komatsu')
         RETURN FALSE
      END IF
   END IF
   
   LET m_per_firme = mr_arquivo.per_firme
   LET mr_arquivo.dat_ate = TODAY + mr_arquivo.per_firme
   
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1420_le_caminho()#
#----------------------------#

   SELECT nom_caminho, ies_ambiente
     INTO m_caminho, m_ies_ambiente
   FROM path_logix_v2
   WHERE cod_empresa = mr_arquivo.cod_empresa 
     AND cod_sistema = 'PPK'

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema EDI n�o cadastrado na LOG1100.'
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
FUNCTION pol1420_carrega_lista()#
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

#----------------------------#
FUNCTION pol1420_carga_conf()#
#----------------------------#

   IF NOT pol1420_valid_form() THEN
      RETURN FALSE
   END IF

   IF NOT pol1420_valid_arquivo() THEN
      RETURN FALSE
   END IF

   IF NOT pol1420_cria_tab() THEN
      RETURN FALSE
   END IF

   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1420_load_arq","PROCESS")  
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF

   CALL pol1420_set_carga(FALSE)

   CALL LOG_transaction_begin()
   
   IF NOT pol1420_limpa_tabelas() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   IF NOT pol1420_ins_arq_komatsu() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1420_separar","PROCESS")  
   
   IF NOT p_status THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1420_checa_dados","PROCESS")  

   IF NOT p_status THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   IF NOT pol1420_atu_peridodo() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()

   LET p_status = pol1420_move_arquivo() 
      
   LET m_car_ped = TRUE

   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1420_monta_grades","PROCESS")  
   
   IF NOT p_status  THEN
      RETURN FALSE
   END IF

   LET m_lin_atu = 1   
   LET p_status = pol1420_set_programacao()

   IF p_status  THEN
      LET m_ies_info = 'C'
   END IF
    
   LET m_car_ped = FALSE
   LET m_excluiu = FALSE
         
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1420_set_programacao()#
#---------------------------------#

   LET m_num_pedido = ma_pedido[m_lin_atu].num_pedido
   LET m_id_pedido = ma_pedido[m_lin_atu].id_pedido
   LET m_cod_item = ma_pedido[m_lin_atu].cod_item
   LET m_ies_status = ma_pedido[m_lin_atu].situacao
   LET m_item_cliente = ma_pedido[m_lin_atu].item_cliente

   INITIALIZE ma_prog TO NULL
   CALL _ADVPL_set_property(m_brz_prog,"CLEAR")
   
   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1420_le_programacao","PROCESS")  
   
   RETURN p_status
   
END FUNCTION

#------------------------------#
FUNCTION pol1420_atu_peridodo()#
#------------------------------#

   IF m_per_firme IS NULL THEN
      INSERT INTO periodo_firme_komatsu 
         VALUES(mr_arquivo.cod_empresa, mr_arquivo.per_firme)
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','periodo_firme_komatsu')
         RETURN FALSE
      END IF
   ELSE         
      IF mr_arquivo.per_firme <> m_per_firme THEN
         UPDATE periodo_firme_komatsu 
            SET per_firme = mr_arquivo.per_firme
          WHERE cod_empresa = mr_arquivo.cod_empresa 

         IF STATUS <> 0 THEN
            CALL log003_err_sql('UPDATE','periodo_firme_komatsu')
            RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE

END FUNCTION
   
#----------------------------#
FUNCTION pol1420_valid_form()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_arquivo.cod_empresa = "0" THEN
      LET m_msg = 'Selecione a empresa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_empresa,"GET_FOCUS") 
      RETURN FALSE
   END IF

   IF mr_arquivo.per_firme IS NULL OR mr_arquivo.per_firme < 0 THEN
      LET m_msg = 'Per�odo firme inv�lido.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_firme,"GET_FOCUS") 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-------------------------------#
FUNCTION pol1420_valid_arquivo()#
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

   IF NOT pol1420_chec_carga() THEN
      CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS") 
      RETURN FALSE
   END IF
      
   LET mr_arquivo.den_arquivo = m_nom_arquivo
   LET mr_arquivo.processado = 'N'
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1420_chec_carga()#
#----------------------------#   
   
   DEFINE l_dat_carga    DATE
   
   SELECT MAX(id_arquivo) 
     INTO m_id_arquivo
     FROM arquivo_komatsu
    WHERE cod_empresa = mr_arquivo.cod_empresa
      AND cod_cliente = mr_arquivo.cod_cliente
      AND nom_arquivo = m_nom_arquivo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','arquivo_komatsu:max(id)')
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
FUNCTION pol1420_cria_tab()#
#--------------------------#

   DROP TABLE qfptran_komatsu;
   
   CREATE TABLE qfptran_komatsu (
    qfp_tran_txt    char(300)
   );

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CREATE",'qfptran_komatsu:CREATE')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1420_load_arq()#
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

   DELETE FROM qfptran WHERE qfp_tran_txt IS NULL
   
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
FUNCTION pol1420_limpa_tabelas()#
#-------------------------------#
   
   DECLARE cq_del_tat CURSOR FOR
    SELECT id_arquivo 
      FROM arquivo_komatsu
     WHERE cod_empresa = mr_arquivo.cod_empresa 
       AND cod_cliente = mr_arquivo.cod_cliente
   
   FOREACH cq_del_tat INTO m_id_arquivo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','arquivo_komatsu:cq_del_tat')
         RETURN FALSE
      END IF
      
      DELETE FROM arquivo_komatsu
       WHERE id_arquivo = m_id_arquivo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','arquivo_komatsu:cq_del_tat')
         RETURN FALSE
      END IF

      DELETE FROM programacao_komatsu
       WHERE id_arquivo = m_id_arquivo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','programacao_komatsu:cq_del_tat')
         RETURN FALSE
      END IF

      DELETE FROM pedidos_komatsu
       WHERE id_arquivo = m_id_arquivo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','pedidos_komatsu:cq_del_tat')
         RETURN FALSE
      END IF

      DELETE FROM itens_komatsu
       WHERE id_arquivo = m_id_arquivo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','itens_komatsu:cq_del_tat')
         RETURN FALSE
      END IF

      DELETE FROM erro_komatsu
       WHERE id_arquivo = m_id_arquivo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','erro_komatsu:cq_del_tat')
         RETURN FALSE
      END IF
         
   END FOREACH

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1420_ins_arq_komatsu()#
#---------------------------------#

   SELECT MAX(id_arquivo) 
     INTO m_id_arquivo
     FROM arquivo_komatsu

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','arquivo_komatsu')
      RETURN FALSE
   END IF
   
   IF m_id_arquivo IS NULL THEN
      LET m_id_arquivo = 0
   END IF
      
   LET m_id_arquivo = m_id_arquivo + 1
   LET mr_arquivo.dat_carga = TODAY
   LET mr_arquivo.hor_carga = TIME
      
   INSERT INTO arquivo_komatsu (
      id_arquivo,  
      cod_empresa, 
      cod_cliente, 
      nom_arquivo, 
      dat_carga,   
      hor_carga,   
      cod_usuario, 
      processado)  
    VALUES(m_id_arquivo,
           mr_arquivo.cod_empresa,
           mr_arquivo.cod_cliente,
           m_nom_arquivo,
           mr_arquivo.dat_carga,
           mr_arquivo.hor_carga,
           p_user,
           mr_arquivo.processado) 
                 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','arquivo_komatsu')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1420_separar()#
#-------------------------#
   
   DEFINE l_it_cliente    CHAR(30),
          l_prz_entrega   CHAR(10),
          l_qtd_solict    CHAR(10),
          l_num_pedido    INTEGER,
          l_cod_item      CHAR(15),
          l_achou         SMALLINT,
          l_it_cli_ant    CHAR(30),
          l_progres       SMALLINT,
          l_regiao        CHAR(03)
         
   INITIALIZE ma_erro TO NULL
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
        
   LET m_car_ped = TRUE

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
      
      IF m_registro IS NULL OR m_registro = ' ' THEN
         CONTINUE FOREACH
      END IF
      
      IF m_registro[1,4] <> '7546' THEN
         CONTINUE FOREACH
      END IF
      
      LET m_index = 0
      LET m_tem_erro = FALSE

      INITIALIZE mr_prog.* TO NULL

      LET mr_prog.id_arquivo = m_id_arquivo
      LET mr_prog.cod_empresa = mr_arquivo.cod_empresa
      LET m_pos_ini = 1
      
      LET mr_prog.fornecedor      = pol1420_divide_texto()
      LET mr_prog.item_cliente    = pol1420_divide_texto()
      LET mr_prog.und             = pol1420_divide_texto()
      LET mr_prog.revisao	        = pol1420_divide_texto()
      LET mr_prog.data	          = pol1420_divide_texto()
      LET mr_prog.prazo	          = pol1420_divide_texto()
      LET mr_prog.alm	            = pol1420_divide_texto()
      LET mr_prog.ordem	          = pol1420_divide_texto()
      LET mr_prog.pos	            = pol1420_divide_texto()
      LET mr_prog.op	            = pol1420_divide_texto()
      LET mr_prog.valor_unit	    = pol1420_divide_texto()
      LET mr_prog.valor_total	    = pol1420_divide_texto()
      LET mr_prog.ordenado	      = pol1420_divide_texto()
      LET mr_prog.entregue	      = pol1420_divide_texto()
      LET mr_prog.pendente	      = pol1420_divide_texto()
      LET mr_prog.data_2	        = pol1420_divide_texto()
      LET mr_prog.nf	            = pol1420_divide_texto()
      LET mr_prog.rese	          = pol1420_divide_texto()
      LET mr_prog.rcf	            = pol1420_divide_texto()
      LET mr_prog.local_geogr     = pol1420_divide_texto()
      
      LET l_regiao = mr_prog.local_geogr[1,3]
      
      SELECT cod_cliente 
        INTO mr_prog.cod_cliente
        FROM cliente_komatsu 
       WHERE loc_geograf = l_regiao
        
      IF STATUS = 100 THEN
         LET mr_prog.cod_cliente = NULL
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('INSERT','programacao_komatsu:cq_qfp')   
            RETURN FALSE
         END IF
      END IF
       
      INSERT INTO programacao_komatsu VALUES(mr_prog.*)
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','programacao_komatsu:cq_qfp')   
         RETURN FALSE
      END IF
      
   END FOREACH

   FREE cq_qfp                                                   
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   SELECT COUNT(DISTINCT cod_cliente) 
     INTO m_count
     FROM programacao_komatsu
    WHERE id_arquivo = m_id_arquivo
      AND cod_cliente IS NOT NULL

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','programacao_komatsu:count')   
      RETURN FALSE
   END IF
   
   IF m_count > 1 THEN
      LET m_msg = 'Arquivo cont�m programa��es\n de mais de um cliente.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   SELECT DISTINCT cod_cliente
     INTO m_cod_cliente
     FROM programacao_komatsu
    WHERE id_arquivo = m_id_arquivo
      AND cod_cliente IS NOT NULL

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','programacao_komatsu:select')   
      RETURN FALSE
   END IF
   
   IF m_cod_cliente <> mr_arquivo.cod_cliente THEN
      LET m_msg = 'O cliente do arquivo � diferente\n do cliente informado na tela.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1420_divide_texto()#
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
FUNCTION pol1420_move_arquivo()#
#------------------------------#
   
   DEFINE l_arq_dest       CHAR(100),
          l_comando        CHAR(120),
          l_tamanho        integer

   LET l_tamanho = LENGTH(m_arq_origem CLIPPED) - 4
   LET l_arq_dest = m_arq_origem[1, l_tamanho], '.pro'
   
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

#-----------------------------#
FUNCTION pol1420_checa_dados()#
#-----------------------------#
   
   DEFINE l_progres         SMALLINT,
          l_prazo	          VARCHAR(10),   
          l_ordem	          VARCHAR(15),   
          l_pos	            VARCHAR(10),   
          l_pendente	      VARCHAR(10) 
       
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   SELECT COUNT(*) INTO m_count
     FROM programacao_komatsu
    WHERE cod_empresa = mr_arquivo.cod_empresa
      AND id_arquivo = m_id_arquivo
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','programacao_komatsu:COUNT')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Arquivo selecionado cont�m pedidos.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
      
   DECLARE cq_agupa CURSOR FOR
    SELECT cod_cliente, item_cliente    
      FROM programacao_komatsu          
     WHERE cod_empresa = mr_arquivo.cod_empresa           
       AND id_arquivo = m_id_arquivo             
     GROUP BY cod_cliente, item_cliente 

   FOREACH cq_agupa INTO 
      mr_pedido.cod_cliente,  
      mr_pedido.item_cliente
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','programacao_komatsu:cq_agupa')
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")               
      LET m_cliticou = FALSE
      LET m_msg = ''
      
      IF mr_pedido.cod_cliente IS NULL THEN
         LET m_msg = m_msg CLIPPED, ' - Cliente inv�lido;'
         LET m_cliticou = TRUE
      END IF

      IF mr_pedido.item_cliente IS NULL THEN
         LET m_msg = m_msg CLIPPED, ' - Item inv�lido;'
         LET m_cliticou = TRUE
      END IF
      
      IF m_msg IS NULL THEN
         IF NOT pol1420_pega_pedido() THEN
            RETURN FALSE
         END IF         
      END IF
            
      SELECT MAX(id_pedido) 
        INTO mr_pedido.id_pedido
        FROM pedidos_komatsu

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','pedidos_komatsu:cq_agupa')
         RETURN FALSE
      END IF
      
      IF mr_pedido.id_pedido IS NULL THEN
         LET mr_pedido.id_pedido = 0
      END IF
      
      LET mr_pedido.id_arquivo = m_id_arquivo
      LET mr_pedido.id_pedido = mr_pedido.id_pedido + 1
      LET mr_pedido.cod_empresa = mr_arquivo.cod_empresa
      LET mr_pedido.mensagem = m_msg

      IF m_cliticou THEN
         LET mr_pedido.situacao = 'E'
      ELSE
         LET mr_pedido.situacao = 'N'
      END IF

      INSERT INTO pedidos_komatsu
       VALUES(mr_pedido.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','pedidos_komatsu')
         RETURN FALSE
      END IF
            
      DECLARE cq_itens_ped CURSOR FOR                                          
       SELECT prazo, ordem, pos, pendente                                     
         FROM programacao_komatsu                                             
        WHERE cod_empresa = mr_pedido.cod_empresa                                          
          AND id_arquivo = mr_pedido.id_arquivo                                                  
          AND cod_cliente = mr_pedido.cod_cliente                                
          AND item_cliente = mr_pedido.item_cliente                                        
                                                                              
      FOREACH cq_itens_ped INTO                                                
         l_prazo,                                                       
         l_ordem,                                                       
         l_pos,                                                         
         l_pendente                                                     
                                                                              
         IF STATUS <> 0 THEN                                                  
            CALL log003_err_sql('SELECT','programacao_komatsu:cq_itens_ped')   
            RETURN FALSE                                                      
         END IF                                                               
         
         LET m_msg = NULL
         LET mr_itens.situacao = 'N'
         LET m_cliticou = FALSE
         LET mr_itens.prz_entrega = l_prazo
         
         IF pol1420_isNumero(l_pendente) THEN
            LET mr_itens.qtd_solic = l_pendente
         ELSE
            LET m_msg = m_msg CLIPPED, ' - Pend�ncia inv�lida'
            LET m_cliticou = TRUE
            LET mr_itens.situacao = 'E'
            LET mr_itens.qtd_solic = NULL
         END IF
         
         IF l_ordem IS NULL THEN
            LET m_msg = ' - AMOSTRA;'
         END IF
         
         IF mr_itens.prz_entrega IS NULL THEN
            LET m_msg = m_msg CLIPPED, ' - Prazo inv�lido'
            LET m_cliticou = TRUE
            LET mr_itens.situacao = 'E'
         END IF

         SELECT MAX(id_item) 
           INTO mr_itens.id_item
           FROM itens_komatsu

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','itens_komatsu:cq_itens_ped')
            RETURN FALSE
         END IF
      
         IF mr_itens.id_item IS NULL THEN
            LET mr_itens.id_item = 0
         END IF
      
         LET mr_itens.id_arquivo = m_id_arquivo
         LET mr_itens.id_pedido = mr_pedido.id_pedido
         LET mr_itens.id_item = mr_itens.id_item + 1
         LET mr_itens.cod_empresa = mr_arquivo.cod_empresa
         LET mr_itens.num_pc = l_ordem
         LET mr_itens.seq_pc = l_pos
         LET mr_itens.mensagem = m_msg
         LET mr_itens.qtd_atual = NULL
         
         IF mr_itens.situacao = 'N' AND mr_pedido.situacao = 'N' THEN
            LET m_num_pedido = mr_pedido.num_pedido
            LET m_cod_item = mr_pedido.cod_item
            LET m_prz_entrega = mr_itens.prz_entrega
            LET p_status = pol1420_le_ped_itens() 
            LET mr_itens.qtd_atual = m_qtd_atual
         END IF    
         
         IF mr_itens.qtd_atual IS NOT NULL THEN
            IF mr_itens.qtd_solic = mr_itens.qtd_atual THEN
               CONTINUE FOREACH
            END IF
         END IF

         INSERT INTO itens_komatsu
          VALUES(mr_itens.*)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('INSERT','itens_komatsu')
            RETURN FALSE
         END IF
                                                                              
      END FOREACH                                                             
   
   END FOREACH
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")               
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1420_isNumero(l_conteudo)#
#------------------------------------#
   
   DEFINE l_conteudo         CHAR(30),
          l_ind              INTEGER,
          l_char             CHAR(01)          

   FOR l_ind = 1 to LENGTH(l_conteudo CLIPPED)
       LET l_char = l_conteudo[l_ind]
       IF l_char MATCHES '[.0123456789]' THEN
       ELSE
          RETURN FALSE
       END IF       
   END FOR
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1420_pega_pedido()#
#-----------------------------#
   
   DEFINE l_num_pedido      DECIMAL(6,0)
   
   LET mr_pedido.num_pedido = NULL
   LET mr_pedido.cod_item = NULL
   
   SELECT COUNT(DISTINCT cod_item) INTO m_count
     FROM cliente_item
    WHERE cod_empresa = mr_arquivo.cod_empresa
      AND cod_cliente_matriz = mr_pedido.cod_cliente
      AND cod_item_cliente = mr_pedido.item_cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cliente_item:01')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = m_msg CLIPPED, ' - Item cliente n�o cadastrado no man10021;'
      LET m_cliticou = TRUE
   ELSE
      IF m_count > 1 THEN
         LET m_msg = m_msg CLIPPED, ' - Item cliente com mais de um cadastrado no man10021;'
         LET m_cliticou = TRUE
      END IF
   END IF
   
   IF m_msg IS NOT NULL THEN
      RETURN TRUE
   END IF

   SELECT cod_item INTO mr_pedido.cod_item
     FROM cliente_item
    WHERE cod_empresa = mr_arquivo.cod_empresa
      AND cod_cliente_matriz = mr_pedido.cod_cliente
      AND cod_item_cliente = mr_pedido.item_cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cliente_item:02')
      RETURN FALSE
   END IF
   
   IF mr_pedido.cod_item IS NULL THEN
      LET m_msg = m_msg CLIPPED, ' - N�o h� item logix p/ o item cliente no man10021;'
      LET m_cliticou = TRUE
      RETURN TRUE
   END IF
   
   LET m_count = 0
   
   DECLARE cq_busca_pedido CURSOR FOR
    SELECT DISTINCT ped_itens.num_pedido
     FROM ped_itens
          INNER JOIN pedidos 
             ON pedidos.cod_empresa = ped_itens.cod_empresa
            AND pedidos.num_pedido = ped_itens.num_pedido
            AND pedidos.ies_sit_pedido <> '9'
            AND pedidos.cod_cliente = mr_pedido.cod_cliente
    WHERE ped_itens.cod_empresa = mr_arquivo.cod_empresa
      AND ped_itens.cod_item = mr_pedido.cod_item
   
   FOREACH cq_busca_pedido INTO l_num_pedido     

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ped_itens/pedidos')
         RETURN FALSE
      END IF
      
      LET m_count = m_count + 1
   
   END FOREACH
   
   IF m_count = 0 THEN
      LET m_msg = m_msg CLIPPED, ' - Item logix sem pedido aberto no vdp2000;'
      LET m_cliticou = TRUE
   ELSE
      IF m_count > 1 THEN
         LET m_msg = m_msg CLIPPED, ' - Item logix com mais de um pedido aberto no vdp2000;'
         LET m_cliticou = TRUE
      ELSE
         LET mr_pedido.num_pedido = l_num_pedido
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION
   

#------------------------------#
FUNCTION pol1420_monta_grades()#
#------------------------------#
  
   DEFINE l_qtd_pedido    SMALLINT,
          l_progres       SMALLINT
      
   INITIALIZE ma_pedido TO NULL
   CALL _ADVPL_set_property(m_brz_pedido,"CLEAR")
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   SELECT COUNT(*) INTO m_count
     FROM pedidos_komatsu
    WHERE id_arquivo = m_id_arquivo
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','pedidos_komatsu:mg')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Arquivo n�o cont�m pedidos.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN TRUE
   END IF
      
   LET m_ind = 1
   LET m_qtd_erro = 0
   LET m_cod_cliente = mr_arquivo.cod_cliente
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
         
   DECLARE cq_monta CURSOR FOR
    SELECT id_pedido,   
           situacao,    
           cod_cliente,
           item_cliente,
           num_pedido,  
           cod_item,    
           mensagem    
      FROM pedidos_komatsu 
     WHERE cod_empresa = p_cod_empresa
       AND id_arquivo = m_id_arquivo
       AND situacao <> 'P'

   FOREACH cq_monta INTO 
      ma_pedido[m_ind].id_pedido,    
      ma_pedido[m_ind].situacao,     
      ma_pedido[m_ind].cod_cliente, 
      ma_pedido[m_ind].item_cliente,
      ma_pedido[m_ind].num_pedido,   
      ma_pedido[m_ind].cod_item,    
      ma_pedido[m_ind].mensagem      
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cq_monta')
         RETURN FALSE
      END IF
            
      IF ma_pedido[m_ind].situacao = 'E' THEN
         LET m_qtd_erro = m_qtd_erro + 1
      END IF

      CALL _ADVPL_set_property(m_brz_pedido,"LINE_FONT_COLOR",m_ind,0,0,0)                  
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 2000 THEN
         LET m_msg = 'Limite de itens previstos ultrapassou 2000.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   LET m_qtd_itens_edi = m_ind - 1
   
   IF m_cod_cliente IS NOT NULL THEN
      IF NOT pol1420_le_carteira() THEN 
         RETURN FALSE
      END IF
   END IF
   
   LET m_qtd_item = m_ind - 1
   CALL _ADVPL_set_property(m_brz_pedido,"ITEM_COUNT", m_qtd_item)

   LET l_progres = LOG_progresspopup_increment("PROCESS")
            
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1420_le_carteira()#
#-----------------------------#
   
   DEFINE l_id_pedido   INTEGER,
          l_item_cli    CHAR(30),
          l_dat_proces  DATE

   LET l_dat_proces = TODAY
   
   SELECT MAX(id_pedido) INTO l_id_pedido 
     FROM pedidos_komatsu  
    WHERE id_arquivo = m_id_arquivo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','pedidos_komatsu:lc')
      RETURN
   END IF
   
   IF l_id_pedido IS NULL THEN
      LET l_id_pedido = 0
   END IF
      
   DECLARE cq_carteira CURSOR FOR
    SELECT DISTINCT pedidos.num_pedido 
      FROM pedidos
     INNER JOIN ped_itens
        ON ped_itens.cod_empresa = pedidos.cod_empresa 
       AND ped_itens.num_pedido = pedidos.num_pedido
       AND ped_itens.qtd_pecas_romaneio = 0
       AND (ped_itens.qtd_pecas_solic - ped_itens.qtd_pecas_atend - 
             ped_itens.qtd_pecas_cancel - ped_itens.qtd_pecas_romaneio) > 0
     WHERE pedidos.cod_empresa = p_cod_empresa 
       AND pedidos.cod_cliente = m_cod_cliente 
       AND pedidos.ies_sit_pedido <> '9'
       AND pedidos.num_pedido not in
           (SELECT DISTINCT pedidos_komatsu.num_pedido 
              FROM pedidos_komatsu 
             WHERE pedidos_komatsu.id_arquivo = m_id_arquivo
               AND pedidos_komatsu.num_pedido IS NOT NULL)

   FOREACH cq_carteira INTO m_num_pedido
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','pedidos:cq_carteira')
         RETURN FALSE
      END IF
      
      LET m_progres = LOG_progresspopup_increment("PROCESS")

      SELECT COUNT(DISTINCT cod_item) INTO m_count
        FROM ped_itens
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = m_num_pedido

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ped_itens-count:cq_carteira')
         RETURN FALSE
      END IF
      
      IF m_count = 1 THEN
      ELSE
         CONTINUE FOREACH
      END IF

      SELECT DISTINCT cod_item 
        INTO m_cod_item
        FROM ped_itens
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = m_num_pedido

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ped_itens:cq_carteira')
         RETURN FALSE
      END IF
      
      LET m_item_cliente = NULL
                                     
      DECLARE cq_cli_item CURSOR FOR
       SELECT cod_item_cliente                                                 
         FROM cliente_item                                             
        WHERE cod_empresa = p_cod_empresa                              
          AND cod_cliente_matriz = m_cod_cliente                      
          AND cod_item = m_cod_item                        
      
      FOREACH cq_cli_item INTO l_item_cli
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','cliente_item:cq_cli_item')
            RETURN 
         END IF
      
         LET m_item_cliente = l_item_cli
         EXIT FOREACH
         
      END FOREACH 
      
      LET l_id_pedido = l_id_pedido + 1
      LET ma_pedido[m_ind].id_pedido = l_id_pedido   
      LET ma_pedido[m_ind].situacao = 'C'   
      LET ma_pedido[m_ind].cod_cliente = m_cod_cliente	 
      LET ma_pedido[m_ind].item_cliente = m_item_cliente
      LET ma_pedido[m_ind].num_pedido = m_num_pedido
      LET ma_pedido[m_ind].cod_item = m_cod_item
      LET ma_pedido[m_ind].mensagem = 'N�o enviado no EDI'

      CALL _ADVPL_set_property(m_brz_pedido,"LINE_FONT_COLOR",m_ind,94,94,255)
               
      LET m_ind = m_ind + 1
      
      IF m_ind > 2000 THEN
         LET m_msg = 'Limite de itens previstos ultrapassou 2000'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH

END FUNCTION                  

#--------------------------------#
FUNCTION pol1420_le_programacao()#
#--------------------------------#
   
   DEFINE l_ies_prog      CHAR(1),
          l_dat_abertura  DATE,
          l_situacao      CHAR(01),
          l_count         INTEGER,
          l_progres       SMALLINT
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   SELECT COUNT(*) INTO m_count
     FROM itens_komatsu
    WHERE id_arquivo = m_id_arquivo
      AND id_pedido = m_id_pedido

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','itens_komatsu:lp')
      RETURN
   END IF
   
   LET m_count = m_count + 20
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DELETE FROM w_progs_komatsu
   SELECT COUNT(*) INTO l_count FROM w_progs_komatsu
   
   IF l_count > 0 THEN
      LET m_msg = 'Erro limpando tabela tempor�ria w_progs_komatsu'
      CALL log0030_mensagem(m_msg,'info')
      RETURN
   END IF      
         
   LET m_ind = 1
   LET m_clik_cab = FALSE

   IF m_ies_status = 'C' THEN
   ELSE   
      DECLARE cq_le_prog CURSOR FOR                                               
       SELECT prz_entrega,
              qtd_solic,  
              operacao,   
              mensagem,
              situacao,
              id_item,
              num_pc, 
              seq_pc        
         FROM itens_komatsu    
        WHERE id_arquivo = m_id_arquivo
          AND id_pedido = m_id_pedido
          AND situacao <> 'P'
     FOREACH cq_le_prog INTO  
        m_prz_entrega,
        m_qtd_solic,  
        m_operacao,   
        m_mensagem,
        m_ies_situa,
        m_id_item,
        m_num_pc, 
        m_seq_pc  
      
        IF STATUS <> 0 THEN                               
           CALL log003_err_sql('SELECT','itens_komatsu:cq_le_prog')     
           RETURN                                   
        END IF                                            
        
        LET l_progres = LOG_progresspopup_increment("PROCESS")
        
        IF m_ies_situa = 'E' OR m_ies_status = 'E' THEN
           LET m_qtd_atual = NULL
           LET m_operacao = 'DESCARTAR'
        ELSE
           IF NOT pol1420_le_ped_itens() THEN                     
              RETURN                                         
           END IF           
           IF m_ja_tem THEN
              LET m_operacao = 'ATUALIZAR'
           ELSE
              LET m_operacao = 'INCLUIR'
           END IF
        END IF
               
        IF m_qtd_atual = m_qtd_solic THEN
           CONTINUE FOREACH
        END IF                           
                
        IF m_num_pc IS NULL THEN
           LET m_mensagem = 'AMOSTRA'
        END IF
        
        LET m_ies_origem = 'E'
                                                   
        IF NOT pol1420_ins_temp() THEN
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

   END IF
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   IF m_ind <= 1000 AND m_ies_status <> 'E' THEN
      IF NOT pol1420_prog_nao_enviada() THEN
         RETURN
      END IF
   END IF
   
   LET m_ind = 1
   
   DECLARE cq_prog_temp CURSOR FOR                                                                       
    SELECT ies_origem, 
           prz_entrega,
           qtd_solic,  
           qtd_atual,  
           operacao,   
           mensagem,
           situacao,
           id_item,
           num_pc,
           seq_pc                                                                                          
      FROM w_progs_komatsu      
     WHERE (num_pedido = m_num_pedido OR num_pedido IS NULL)                                                                             
     ORDER BY prz_entrega                                                                                   
                                                                                                            
   FOREACH cq_prog_temp INTO 
      ma_prog[m_ind].ies_origem,
      ma_prog[m_ind].prz_entrega,
      ma_prog[m_ind].qtd_solic, 
      ma_prog[m_ind].qtd_atual, 
      ma_prog[m_ind].operacao,  
      ma_prog[m_ind].mensagem,
      ma_prog[m_ind].situacao,
      ma_prog[m_ind].id_item,
      ma_prog[m_ind].num_pc, 
      ma_prog[m_ind].seq_pc  
                                                                                             
      IF STATUS <> 0 THEN                                                                                
         CALL log003_err_sql('SELECT','w_progs_komatsu:cq_prog_temp')                                           
         EXIT FOREACH                                                                                       
      END IF                                                                                                
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")

      IF ma_prog[m_ind].situacao = 'E' THEN
         CALL _ADVPL_set_property(m_brz_prog,"LINE_FONT_COLOR",m_ind,255,0,0)   
      ELSE      
         IF ma_prog[m_ind].prz_entrega <= mr_arquivo.dat_ate THEN                                                          
            LET ma_prog[m_ind].mensagem = '(FIRME) ', ma_prog[m_ind].mensagem
            CALL _ADVPL_set_property(m_brz_prog,"LINE_FONT_COLOR",m_ind,255,128,0)   
         ELSE
            LET ma_prog[m_ind].mensagem = '(PLANEJADA) ', ma_prog[m_ind].mensagem
            CALL _ADVPL_set_property(m_brz_prog,"LINE_FONT_COLOR",m_ind,0,0,0)     
         END IF
      END IF

      LET ma_prog[m_ind].ies_select = 'N'                                                                                                                                                                                                        
      LET m_ind = m_ind + 1                                                                              
                                                                                                            
      IF m_ind > 1000 THEN                                                                                  
         LET m_msg = 'Limite de programa��es previstas\n ultrapassou a 1000'                                        
         CALL log0030_mensagem(m_msg,'info')                                                                
         EXIT FOREACH                                                                                       
      END IF                                                                                                
                                                                                                            
   END FOREACH                                                                                              
                                                                                                            
   FREE cq_prog_temp                                                                                                    
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   LET m_qtd_prog = m_ind - 1
   CALL _ADVPL_set_property(m_brz_prog,"ITEM_COUNT", m_qtd_prog)
         
END FUNCTION

#----------------------------------#
FUNCTION pol1420_prog_nao_enviada()#
#----------------------------------#

   DECLARE cq_prog_antes CURSOR FOR                                                                      
    SELECT prz_entrega,                                     
           (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio)
      FROM ped_itens                                                                                        
     WHERE cod_empresa = p_cod_empresa                                                                      
       AND num_pedido = m_num_pedido                                                                        
       AND cod_item = m_cod_item                                                                            
       AND (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio) > 0                  
       AND prz_entrega NOT IN (select prz_entrega FROM w_progs_komatsu)                                         
                                                                                                            
   FOREACH cq_prog_antes INTO                                                                            
      m_prz_entrega,                                                                               
      m_qtd_atual                                                                                 
                                                                                                            
      IF STATUS <> 0 THEN                                                                                
         CALL log003_err_sql('SELECT','ped_itens:cq_prog_antes')                                            
         RETURN FALSE                                                                                       
      END IF                                                                                                
      
      LET m_qtd_solic = NULL                                                                                                            
      LET m_operacao = 'CANCELAR'   
      LET m_ies_origem = 'C'       
      LET m_ies_situa = 'N'       
      LET m_mensagem = 'PROG N�O ENVIADA'   
      LET m_id_item = 0
      LET m_num_pc = NULL
      LET m_seq_pc = 0                                              
                                                                                                            
      IF NOT pol1420_ins_temp() THEN
         RETURN
      END IF
      
      LET m_ind = m_ind + 1

      IF m_ind > 1000 THEN                                                                                  
         LET m_msg = 'Limite de programa��es ultrapassou a 1000.'                                        
         CALL log0030_mensagem(m_msg,'info')                                                                
         EXIT FOREACH                                                                                       
      END IF                                                                                                
                                                                                                            
   END FOREACH                                                                                              
                                                                                                            
   FREE cq_prog_antes                                                                                       
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1420_le_ped_itens()#
#------------------------------#
      
  LET m_ja_tem = FALSE
  
  DECLARE cq_pos_atu CURSOR FOR 
   SELECT (qtd_pecas_solic - qtd_pecas_atend - 
           qtd_pecas_cancel - qtd_pecas_romaneio ), 
           qtd_pecas_atend,
           qtd_pecas_romaneio,
           num_sequencia,
           qtd_pecas_solic,
           qtd_pecas_cancel
      FROM ped_itens 
     WHERE cod_empresa = p_cod_empresa 
       AND num_pedido = m_num_pedido
       AND cod_item  = m_cod_item
       AND prz_entrega =  m_prz_entrega
  
  FOREACH cq_pos_atu INTO m_qtd_atual, m_qtd_atend,
      m_qtd_romaneio, m_num_seq, m_qtd_planej, m_qtd_cancel

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ped_itens:cq_pos_atu')
         RETURN FALSE
      END IF
      
      LET m_ja_tem = TRUE
      EXIT FOREACH
  
  END FOREACH
  
   IF NOT m_ja_tem THEN
      LET m_qtd_atend = 0
      LET m_qtd_atual = 0
      LET m_qtd_romaneio = 0
      LET m_num_seq = 0
      LET m_qtd_planej = 0
      LET m_qtd_cancel = 0
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1420_ins_temp()#
#--------------------------#

   INSERT INTO w_progs_komatsu(
       num_pedido, 
       ies_origem, 
       prz_entrega,
       qtd_solic,  
       qtd_atual,  
       operacao,
       mensagem,
       situacao,
       id_item,
       num_pc, 
       seq_pc)   
   VALUES(m_num_pedido,
          m_ies_origem,
          m_prz_entrega,
          m_qtd_solic,  
          m_qtd_atual,  
          m_operacao,
          m_mensagem,
          m_ies_situa,
          m_id_item,
          m_num_pc, 
          m_seq_pc)
                                                                 
   IF STATUS <> 0 THEN                                      
      CALL log003_err_sql('INSERT','w_progs_komatsu')
      RETURN FALSE
   END IF                                                   
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1420_pesquisar()#
#---------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   CALL pol1420_limpa_campos()
   LET m_ies_info = 'N'
   LET mr_arquivo.cod_empresa = p_cod_empresa
   
   IF NOT pol1420_le_periodo() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'P'

   CALL pol1420_set_pesquisa(TRUE)   
   CALL _ADVPL_set_property(m_cliente,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol1420_set_pesquisa(l_status)#
#--------------------------------------#
   
   DEFINE l_status      SMALLINT
   
   CALL _ADVPL_set_property(m_panel_cabec,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_cliente,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_cli,"EDITABLE",l_status)

END FUNCTION
   
#---------------------------#
FUNCTION pol1420_pesq_canc()#
#---------------------------#

   CALL pol1420_limpa_campos()
   LET m_ies_info = 'N'
   CALL pol1420_set_pesquisa(FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1420_pesq_conf()#
#---------------------------#
   
   DEFINE l_query     CHAR(1500),
          l_cod_cli   CHAR(15)
   
   SELECT max(id_arquivo) 
     INTO m_id_arquivo
     FROM arquivo_komatsu
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_arquivo.cod_cliente
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('SELECT','arquivo_komatsu:pc')
      RETURN FALSE
   END IF
    
   IF m_id_arquivo IS NULL THEN
      LET m_msg = 'Cliente n�o possui carga a consultar'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
    
   IF NOT pol1420_pesq_exibe() THEN
      RETURN FALSE
   END IF
   
   CALL pol1420_set_pesquisa(FALSE)
      
   RETURN TRUE   
    
END FUNCTION

#----------------------------#
FUNCTION pol1420_pesq_exibe()#
#----------------------------#
   
   SELECT nom_arquivo, 
          dat_carga,   
          hor_carga,   
          processado            
     INTO mr_arquivo.den_arquivo,
          mr_arquivo.dat_carga,  
          mr_arquivo.hor_carga,  
          mr_arquivo.processado  
     FROM arquivo_komatsu
    WHERE id_arquivo = m_id_arquivo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','arquivo_komatsu:pe')
      RETURN FALSE
   END IF
              
   LET m_car_ped = TRUE

   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1420_monta_grades","PROCESS")  

   IF not p_status  THEN
      RETURN FALSE
   END IF

   LET m_lin_atu = 1   
   LET p_status = pol1420_set_programacao()
   
   IF p_status  THEN
      LET m_ies_info = 'P'
   END IF
    
   LET m_car_ped = FALSE
   LET m_excluiu = FALSE
         
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1420_processar()#
#---------------------------#    
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT pol1420_ve_possibilidade('P') THEN
      RETURN FALSE
   END IF
      
   LET m_lin_atu = _ADVPL_get_property(m_brz_pedido,"ROW_SELECTED")

   IF ma_pedido[m_lin_atu].situacao = 'E' THEN
      LET m_msg = 'O item selecionado cont�m erro.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF   

   IF ma_pedido[m_lin_atu].situacao = 'P' THEN
      LET m_msg = 'O item selecionado j� foi processado.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF   
   
   CALL _ADVPL_set_property(m_panel_item,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_panel_prog,"EDITABLE",TRUE)

   LET m_msg = 'Marque as programa��es que desena processar'
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1420_processar_canc()#
#--------------------------------#    

   CALL _ADVPL_set_property(m_panel_item,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_panel_prog,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1420_processar_conf()#
#--------------------------------#
   
   DEFINE l_ind       INTEGER,
          l_firme     INTEGER,
          l_planej    INTEGER
   
   LET l_firme = 0
   LET l_planej = 0
   
   FOR l_ind = 1 TO m_qtd_prog
       IF ma_prog[l_ind].ies_select = 'S' THEN
          IF ma_prog[l_ind].mensagem[1,7] = '(FIRME)' THEN
             LET l_firme = l_firme + 1
          ELSE
             LET l_planej = l_planej + 1
          END IF
       END IF
   END FOR
   
   LET m_count = l_planej + l_firme
   
   IF m_count = 0 THEN
      LET m_msg = 'Nunhuma programa��o foi selecionada'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF   

   IF l_firme > 0 THEN
      LET m_msg = 'Programa��es firmes foram selecionadas.\nDeseja continuar ?\n'
   ELSE
      LET m_msg = 'A carteira de pedidos ser� atualzada.\nDeseja continuar ?\n'
   END IF         

   IF NOT LOG_question(m_msg) THEN
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_panel_item,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_panel_prog,"EDITABLE",FALSE)
      
   LET m_id_pedido = ma_pedido[m_lin_atu].id_pedido 
   LET m_num_pedido = ma_pedido[m_lin_atu].num_pedido
   LET m_cod_item = ma_pedido[m_lin_atu].cod_item
   LET m_item_cliente = ma_pedido[m_lin_atu].item_cliente
   LET m_ies_status = ma_pedido[m_lin_atu].situacao
   LET m_ies_origem = ma_prog[m_lin_atu].ies_origem
   
   CALL LOG_transaction_begin()
   
   LET p_status = LOG_progresspopup_start(
       "Processando...","pol1420_proc_edi","PROCESS")  

   IF NOT p_status THEN
      LET m_msg = 'Opera��o cancelada..'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   LET ma_pedido[m_lin_atu].situacao = 'P'
   
   LET m_msg = 'Opera��o efetuada com sucesso.'

   CALL log0030_mensagem(m_msg,'info')

   LET m_ies_situa = pol1420_atu_pedido_komatsu()

   IF m_ies_situa = 'P' THEN
      CALL _ADVPL_set_property(m_brz_pedido,"COLUMN_VALUE","situacao",m_lin_atu,'P')
   END IF
   
   #LET p_status = pol1420_atu_arquivo_komatsu()
   
   CALL pol1420_le_programacao()  
         
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1420_atu_pedido_komatsu()#
#------------------------------------#
   
   DEFINE l_count         INTEGER,
          l_ies_situa     CHAR(01)
   
   LET l_ies_situa = 'N'
   LET m_houve_erro = FALSE
   
   SELECT COUNT(*) INTO l_count
     FROM itens_komatsu
    WHERE id_arquivo = m_id_arquivo
      AND id_pedido = m_id_pedido
      AND situacao = 'N'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','itens_komatsu:apk')
      LET m_houve_erro = TRUE
      RETURN l_ies_situa
   END IF
   
   IF l_count = 0 THEN
      UPDATE pedidos_komatsu
         SET situacao = 'P'
       WHERE id_pedido = m_id_pedido
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','pedidos_komatsu:apk')
         LET m_houve_erro = TRUE
         RETURN l_ies_situa
      END IF
      LET m_ies_situa = 'P'      
   END IF
   
   RETURN l_ies_situa

END FUNCTION   


#-------------------------------------#
FUNCTION pol1420_atu_arquivo_komatsu()#
#-------------------------------------#
   
   DEFINE l_count         INTEGER
      
   SELECT COUNT(*) INTO l_count
     FROM pedidos_komatsu
    WHERE id_arquivo = m_id_arquivo
      AND situacao <> 'P'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','arquivo_komatsu:aak')
      RETURN FALSE
   END IF
   
   IF l_count = 0 THEN
      UPDATE arquivo_komatsu
         SET processado = 'S'
       WHERE id_arquivo = m_id_arquivo
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','arquivo_komatsu:aak')
         RETURN FALSE
      END IF
      LET mr_arquivo.processado = 'S'
   END IF
   
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1420_chec_selecao()#
#------------------------------#

   DEFINE l_lin_atu       INTEGER,
          l_estornar      CHAR(01)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET l_lin_atu = _ADVPL_get_property(m_brz_prog,"ROW_SELECTED")

   IF ma_prog[l_lin_atu].mensagem[1,7] = '(FIRME)' THEN

   ELSE

   END IF

   IF ma_prog[l_lin_atu].situacao = 'E' THEN
      CALL _ADVPL_set_property(m_brz_prog,"COLUMN_VALUE","ies_select",l_lin_atu,'N')
      LET m_msg = 'Essa programa��o contem erros.' 
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
      
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1420_marca_desmarca()#
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
       IF ma_prog[l_ind].situacao = 'E' THEN
          CALL _ADVPL_set_property(m_brz_prog,"COLUMN_VALUE","ies_select",l_ind,'N')
       ELSE
          CALL _ADVPL_set_property(m_brz_prog,"COLUMN_VALUE","ies_select",l_ind,l_sel)
       END IF
   END FOR
      
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1420_consistir()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   IF NOT pol1420_ve_possibilidade('C') THEN
      RETURN FALSE
   END IF
   
   IF m_qtd_erro = 0 THEN
      LET m_msg = 'Nenhum item importado comtem erro (situa��o = E)'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF        
      
   CALL LOG_transaction_begin()

   LET p_status = LOG_progresspopup_start(
       "Processando...","pol1420_proc_consist","PROCESS")  
   
   IF NOT p_status THEN
      LET m_msg = 'Opera��o cancelada..'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()

   IF m_qtd_erro > 0 THEN
      LET m_msg = 'Alguns Itens foram criticados..'
   ELSE
      LET m_msg = 'Opera��o efetuada com sucesso.'
   END IF

   CALL log0030_mensagem(m_msg,'info')

   LET m_car_ped = TRUE

   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1420_monta_grades","PROCESS")  

   IF NOT p_status  THEN
      LET m_lin_atu = 1   
      LET p_status = pol1420_set_programacao()
   END IF
    
   LET m_car_ped = FALSE
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol1420_ve_possibilidade(l_op)#
#--------------------------------------#
   
   DEFINE l_op    CHAR(01)
   
   IF mr_arquivo.cod_cliente IS NULL OR m_excluiu THEN
      LET m_msg = 'N�o h� arquivo na tela. Selecione um previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF   
   
   IF mr_arquivo.processado = 'S' THEN
      LET m_msg = 'Esse arquivo j� est� processado'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1420_proc_consist()#
#------------------------------#
   
   DEFINE l_progres      SMALLINT

   CALL LOG_progresspopup_set_total("PROCESS",m_qtd_itens_edi)

   FOR m_ind = 1 TO m_qtd_itens_edi
       LET l_progres = LOG_progresspopup_increment("PROCESS")
       IF ma_pedido[m_ind].situacao = 'E' THEN
          IF NOT pol1420_checa_itens() THEN
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   RETURN TRUE

END FUNCTION

#-----------------------------#      
FUNCTION pol1420_checa_itens()#
#-----------------------------#

   LET m_cliticou = FALSE
   LET m_msg = ''
   
   LET mr_pedido.id_pedido = ma_pedido[m_ind].id_pedido
   LET mr_pedido.cod_cliente = ma_pedido[m_ind].cod_cliente
   LET mr_pedido.item_cliente = ma_pedido[m_ind].item_cliente
   LET mr_pedido.num_pedido = ma_pedido[m_ind].num_pedido
   LET mr_pedido.cod_item = ma_pedido[m_ind].cod_item
         
   IF mr_pedido.cod_cliente IS NULL THEN                  
      LET m_msg = m_msg CLIPPED, ' - Cliente inv�lido;'   
      LET m_cliticou = TRUE                               
   END IF                                                 
                                                          
   IF mr_pedido.item_cliente IS NULL THEN              
      LET m_msg = m_msg CLIPPED, ' - Item inv�lido;'      
      LET m_cliticou = TRUE                               
   END IF                                                 
                                                          
   IF NOT m_cliticou THEN                                  
      IF NOT pol1420_pega_pedido() THEN                   
         RETURN FALSE                                     
      END IF                                              
   END IF                                                 

   IF NOT m_cliticou THEN         
      LET mr_pedido.situacao = 'N'             
   ELSE
      LET mr_pedido.situacao = 'E'             
   END IF                                                 
                                                          
   LET mr_pedido.mensagem = m_msg                         
   
   UPDATE pedidos_komatsu
      SET num_pedido = mr_pedido.num_pedido,
          cod_item = mr_pedido.cod_item,
          mensagem = mr_pedido.mensagem,
          situacao =  mr_pedido.situacao
    WHERE id_pedido = mr_pedido.id_pedido
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','pedidos_komatsu')
      RETURN FALSE
   END IF

   {IF NOT pol1420_checa_progs() THEN
       RETURN FALSE
   END IF}
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1420_checa_progs()#
#-----------------------------#

   DEFINE l_prz_entrega       VARCHAR(15),   
          l_num_pc	          VARCHAR(15),   
          l_qtd_solic	        VARCHAR(15),
          l_id_item           INTEGER
   
   DECLARE cq_chec_it CURSOR FOR
    SELECT id_item,
           num_pc,
           prz_entrega,
           qtd_solic
      FROM itens_komatsu
     WHERE id_arquivo = m_id_arquivo
       AND id_pedido = mr_pedido.id_pedido
       AND situacao = 'E'
   
   FOREACH cq_chec_it INTO  
      l_id_item, l_num_pc, l_prz_entrega, l_qtd_solic                                                 
                                                                              
      IF STATUS <> 0 THEN                                                     
         CALL log003_err_sql('SELECT','itens_komatsu:cq_chec_it')     
         RETURN FALSE                                                         
      END IF                                                                   
                                                                              
      LET m_msg = NULL      
      LET mr_itens.situacao = 'N'     
      LET m_cliticou = FALSE                                             
                                                                              
      IF l_num_pc IS NULL THEN                                                 
         LET m_msg = ' - AMOSTRA;'                                         
      END IF                                                                  
                                                                              
      IF l_prz_entrega IS NULL THEN                                                 
         LET m_msg = m_msg CLIPPED, ' - Prazo inv�lido'                       
         LET m_cliticou = TRUE      
         LET mr_itens.situacao = 'E'                                          
      END IF                                                                  
                                                                              
      IF l_qtd_solic IS NULL THEN                                              
         LET m_msg = m_msg CLIPPED, ' - Qtd EDI inv�lida'                
         LET m_cliticou = TRUE        
         LET mr_itens.situacao = 'E'                                        
      END IF                                                                  
      
      UPDATE itens_komatsu
         SET situacao = mr_itens.situacao,
             mensagem = m_msg                                                           
       WHERE id_item = l_id_item             

      IF STATUS <> 0 THEN                                                     
         CALL log003_err_sql('UPDATE','itens_komatsu:cq_chec_it')     
         RETURN FALSE                                                         
      END IF                                                                   
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION   

#-------------------------------------#
FUNCTION pol1420_atu_pedido_komatisu()#
#-------------------------------------#      

   UPDATE pedidos_komatsu
      SET situacao = 'P'
    WHERE id_pedido = m_id_pedido
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','pedidos_komatsu:apk')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1420_proc_edi()#
#--------------------------#
   
   DEFINE l_progres      SMALLINT,
          l_ind          INTEGER,
          l_atu_pe1      SMALLINT
   
   LET m_dat_atu = TODAY
   LET m_hor_atu = TIME
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')   
   
   CALL LOG_progresspopup_set_total("PROCESS",m_qtd_prog)

   FOR l_ind = 1 TO m_qtd_prog
   
       LET l_progres = LOG_progresspopup_increment("PROCESS")

       IF ma_prog[l_ind].ies_select = 'S' THEN
          LET m_prz_entrega = ma_prog[l_ind].prz_entrega   
          LET m_qtd_solic = ma_prog[l_ind].qtd_solic      
          LET m_id_item = ma_prog[l_ind].id_item      
          LET m_num_pc = ma_prog[l_ind].num_pc      
          LET m_seq_pc = ma_prog[l_ind].seq_pc   
          LET m_operacao = ma_prog[l_ind].operacao
             
          IF NOT pol1420_atu_carteira() THEN
             RETURN FALSE
          END IF          
       END IF
              
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1420_atu_carteira()#
#------------------------------#

   IF NOT pol1420_le_ped_itens() THEN                     
      RETURN FALSE
   END IF           
   
   IF m_qtd_solic IS NULL THEN
      LET m_qtd_solic = 0
   END IF                                                               
   
   IF m_ja_tem THEN
      LET m_mensagem = 'ALTEROU PROGRAMACAO'
      IF m_qtd_solic > m_qtd_atual THEN
         LET m_qtd_planej = m_qtd_planej + (m_qtd_solic - m_qtd_atual)
      ELSE
         LET m_qtd_cancel = m_qtd_cancel +(m_qtd_atual - m_qtd_solic)
         IF m_qtd_solic = 0 THEN
            LET m_mensagem = 'CANCELOU SALDO'
         END IF
      END IF
      IF NOT pol1420_atu_prog() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol1420_add_prog() THEN
         RETURN FALSE
      END IF
      LET m_mensagem = 'INCLUIU PROGRAMACAO'
   END IF
   
   IF NOT pol1420_atu_item_komatsu() THEN                              
      RETURN FALSE                                              
   END IF                                                       

   IF m_qtd_solic > m_qtd_atual THEN
      LET m_qtd_oper = m_qtd_solic - m_qtd_atual 
   ELSE
      LET m_qtd_oper = m_qtd_atual - m_qtd_solic 
   END IF
                                                                   
   IF NOT pol1420_ins_audit() THEN                              
      RETURN FALSE                                              
   END IF                                                       
   
   IF m_ies_origem <> 'C' THEN
      IF NOT pol1420_gra_ped_cli() THEN
         RETURN FALSE
      END IF
   END IF
    
   RETURN TRUE

END FUNCTION                                                            
                                                                
#--------------------------#
FUNCTION pol1420_add_prog()#
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

   IF NOT pol1420_le_lista() THEN
      RETURN FALSE
   END IF   
   
   IF m_pre_unit = 0 THEN
      LET m_msg = 
       'N�o foi possivel encontrar o pre�o do item \n a partir da lista de pre�o ', m_num_lista
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   SELECT MAX(num_sequencia)
     INTO m_num_seq
     FROM ped_itens
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido 
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ped_itens:max1')
      RETURN FALSE
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
           m_qtd_solic,0,0,0,
           m_prz_entrega,
           0,0,0,0,0)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ped_itens')
      RETURN FALSE
   END IF
      
   RETURN TRUE           

END FUNCTION

#--------------------------#
FUNCTION pol1420_atu_prog()#
#--------------------------#
   
   UPDATE ped_itens 
      SET qtd_pecas_solic = m_qtd_planej,
          qtd_pecas_cancel = m_qtd_cancel
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido 
      AND num_sequencia  = m_num_seq

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ped_itens:ap')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1420_le_lista()#
#--------------------------#

   DEFINE l_transacao  INTEGER
   
   LET l_transacao = func016_le_lista(p_cod_empresa,
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
         #AND cod_cliente = m_cod_cliente
         AND num_transacao = l_transacao
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','desc_preco_item')
         RETURN FALSE
      END IF
   END IF   
   
   RETURN TRUE

END FUNCTION 

#----------------------------------#
FUNCTION pol1420_atu_item_komatsu()#
#----------------------------------#

   UPDATE itens_komatsu
      SET situacao = 'P'
    WHERE id_item = m_id_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','itens_komatsu:aik')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1420_ins_audit()#
#---------------------------#
      
   SELECT MAX(id_audit) INTO m_id_audit
     FROM audit_komatsu

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','audit_komatsu:ia')
      RETURN FALSE
   END IF
   
   IF m_id_audit IS NULL THEN
      LET m_id_audit = 0
   END IF
   
   LET m_id_audit = m_id_audit + 1
         
   INSERT INTO audit_komatsu (
      id_audit,       
      id_arquivo,     
      id_pedido,      
      id_item,        
      cod_empresa,    
      cod_cliente,    
      item_cliente,   
      num_pc,         
      seq_pc,         
      num_pedido,     
      cod_item,       
      prz_entrega,    
      qtd_solic,      
      qtd_atual,      
      qtd_operacao,   
      mensagem,       
      usuario,        
      dat_operacao,   
      hor_operacao)   
   VALUES(m_id_audit,            
          m_id_arquivo,   
          m_id_pedido,    
          m_id_item,      
          p_cod_empresa,  
          m_cod_cliente,  
          m_item_cliente, 
          m_num_pc,       
          m_seq_pc,       
          m_num_pedido,   
          m_cod_item,     
          m_prz_entrega,  
          m_qtd_solic,    
          m_qtd_atual,    
          m_qtd_oper,     
          m_mensagem,     
          p_user,         
          m_dat_atu,      
          m_hor_atu)      

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','audit_komatsu:ia')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#-----------------------------#   
FUNCTION pol1420_gra_ped_cli()#
#-----------------------------#

   SELECT 1 FROM ped_seq_ped_cliente   
    WHERE empresa = p_cod_empresa
      AND pedido = m_num_pedido
      AND seq_item_ped = m_num_seq

   IF STATUS = 0 THEN
      UPDATE ped_seq_ped_cliente
         SET xped = m_num_pc,
             nitemped = m_seq_pc
       WHERE empresa = p_cod_empresa
         AND pedido = m_num_pedido
         AND seq_item_ped = m_num_seq
   ELSE
      IF STATUS = 100 THEN
         INSERT INTO ped_seq_ped_cliente(
            empresa,                     
            pedido,                      
            seq_item_ped,                
            xped,                        
            nitemped)                
         VALUES(p_cod_empresa,           
                m_num_pedido,            
                m_num_seq,               
                m_num_pc,                
                m_seq_pc)                
      ELSE
         CALL log003_err_sql('SELECT','ped_seq_ped_cliente:lendo')
         RETURN FALSE
      END IF
   END IF

   IF STATUS <> 0 THEN   
      CALL log003_err_sql('atualizando','ped_seq_ped_cliente:atu')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1420_proc_all()#
#--------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT pol1420_ve_possibilidade('T') THEN
      RETURN FALSE
   END IF
   
   CALL pol1420_sel_prog()

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1420_sel_prog()#
#--------------------------#

   DEFINE l_menubar     VARCHAR(10),
          l_panel       VARCHAR(10),
          l_confirm     VARCHAR(10),
          l_cancel      VARCHAR(10)

    LET m_form_proc = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_proc,"SIZE",800,450)
    CALL _ADVPL_set_property(m_form_proc,"TITLE","SELEC��O DE PROGRAMA��O")
    CALL _ADVPL_set_property(m_form_proc,"INIT_EVENT","pol1420_init_prog")

    LET m_stat_prog = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_proc)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_proc)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    CALL pol1420_par_prog(l_panel)
    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_proc)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) 
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_confirm = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirm,"IMAGE","CONFIRM_EX")
   CALL _ADVPL_set_property(l_confirm,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirm,"EVENT","pol1420_conf_all")     

   LET l_cancel = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancel,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancel,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancel,"EVENT","pol1420_canc_all")    

   CALL _ADVPL_set_property(m_form_proc,"ACTIVATE",TRUE)

END FUNCTION

#---------------------------#
FUNCTION pol1420_init_prog()#
#---------------------------#

   CALL _ADVPL_set_property(m_programacao,"GET_FOCUS")

END FUNCTION    

#-------------------------------------#
FUNCTION pol1420_par_prog(l_container)#
#-------------------------------------#

   DEFINE l_container       VARCHAR(10),
          l_layout          VARCHAR(10),
          l_label           VARCHAR(10),
          l_caixa           VARCHAR(10),
          l_lupa_cli        VARCHAR(10)
   
   INITIALIZE mr_print.* TO NULL
   
   LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_container)
   CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",3)

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
   CALL _ADVPL_set_property(l_label,"TEXT","Programa��o:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)

   LET m_programacao = _ADVPL_create_component(NULL,"LCOMBOBOX",l_layout)  
   CALL _ADVPL_set_property(m_programacao,"ADD_ITEM"," ","    ")            
   CALL _ADVPL_set_property(m_programacao,"ADD_ITEM","T","Todas")           
   CALL _ADVPL_set_property(m_programacao,"ADD_ITEM","P","Planejado")       
   CALL _ADVPL_set_property(m_programacao,"ADD_ITEM","F","Firme")           
   CALL _ADVPL_set_property(m_programacao,"VARIABLE",mr_arquivo,"tip_prog")     

END FUNCTION

#--------------------------#   
FUNCTION pol1420_canc_all()#
#--------------------------#

   CALL _ADVPL_set_property(m_form_proc,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION

#--------------------------#  
FUNCTION pol1420_conf_all()#
#--------------------------#
   
   CALL _ADVPL_set_property(m_stat_prog,"ERROR_TEXT",'')
   
   IF mr_arquivo.tip_prog IS NULL THEN
      LET m_msg = 'Selecione o tipo de programa��o.'
      CALL _ADVPL_set_property(m_stat_prog,"ERROR_TEXT",'')
      RETURN FALSE
   END IF

   CALL LOG_transaction_begin()
   
   LET p_status = LOG_progresspopup_start(
       "Processando...","pol1420_proc_all_itens","PROCESS")  

   IF NOT p_status THEN
      LET m_msg = 'Opera��o cancelada..'
      CALL _ADVPL_set_property(m_stat_prog,"ERROR_TEXT",m_msg)
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   LET p_status = pol1420_atu_arquivo_komatsu()
      
   LET m_msg = 'Opera��o efetuada com sucesso.'

   CALL log0030_mensagem(m_msg,'info')
      
   CALL _ADVPL_set_property(m_form_proc,"ACTIVATE",FALSE)

   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1420_monta_grades","PROCESS")  

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1420_proc_all_itens()#
#--------------------------------#
   
   DEFINE l_progres      SMALLINT,
          l_qtd_ped      INTEGER,
          l_ind          INTEGER
          
   LET m_dat_atu = TODAY
   LET m_hor_atu = TIME
   
   CALL _ADVPL_set_property(m_stat_prog,"ERROR_TEXT",'')   
   
   LET l_qtd_ped = _ADVPL_get_property(m_brz_pedido,"ITEM_COUNT")   
   
   CALL LOG_progresspopup_set_total("PROCESS",l_qtd_ped)
   
   FOR l_ind = 1 TO m_qtd_itens_edi
   
       LET l_progres = LOG_progresspopup_increment("PROCESS")
       
       IF ma_pedido[l_ind].situacao = 'N' THEN
          LET m_id_pedido = ma_pedido[l_ind].id_pedido      
          LET m_num_pedido = ma_pedido[l_ind].num_pedido    
          LET m_cod_item = ma_pedido[l_ind].cod_item        
          LET m_item_cliente = ma_pedido[l_ind].item_cliente
          LET m_ies_status = ma_pedido[l_ind].situacao      
          LET m_ies_origem = ma_prog[l_ind].ies_origem      

          IF NOT pol1420_proc_all_progs() THEN
             RETURN FALSE
          END IF                    

          IF NOT pol1420_canc_all_progs() THEN
             RETURN FALSE
          END IF     

       END IF       
   END FOR
   
   DELETE FROM w_progs_komatsu
   LET m_id_pedido = NULL
      
   LET m_ind_canc = m_qtd_itens_edi + 1

   FOR l_ind = m_ind_canc TO m_qtd_item

       LET l_progres = LOG_progresspopup_increment("PROCESS")
   
       LET m_num_pedido = ma_pedido[l_ind].num_pedido
       LET m_cod_item = ma_pedido[l_ind].cod_item
       LET m_item_cliente = ma_pedido[l_ind].item_cliente

       IF m_cod_item IS NOT NULL THEN
          IF NOT pol1420_canc_all_progs() THEN
             RETURN FALSE
          END IF     
      END IF
      
   END FOR

   LET l_progres = LOG_progresspopup_increment("PROCESS")
      
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1420_proc_all_progs()#
#--------------------------------#
   
   DELETE FROM w_progs_komatsu
   
   DECLARE cq_all_prog CURSOR FOR                                               
     SELECT prz_entrega,                                               
            qtd_solic,                                                 
            operacao,                                                  
            mensagem,                                                  
            situacao,                                                  
            id_item,                                                   
            num_pc,                                                    
            seq_pc                                                     
       FROM itens_komatsu                                              
      WHERE id_arquivo = m_id_arquivo                                  
        AND id_pedido = m_id_pedido                                    
        AND situacao = 'N'                                          
   FOREACH cq_all_prog INTO                                             
      m_prz_entrega,                                                   
      m_qtd_solic,                                                     
      m_operacao,                                                      
      m_mensagem,                                                      
      m_ies_situa,                                                     
      m_id_item,                                                       
      m_num_pc,                                                        
      m_seq_pc                                                         
                                                                       
      IF STATUS <> 0 THEN                                              
         CALL log003_err_sql('SELECT','itens_komatsu:cq_le_prog')       
         RETURN FALSE                                                       
      END IF                                                           

      IF pol1420_descarta() THEN
         CONTINUE FOREACH
      END IF
			
      IF NOT pol1420_ins_temp() THEN
         RETURN FALSE
      END IF
			
      IF NOT pol1420_atu_carteira() THEN
         RETURN FALSE
      END IF
            
   END FOREACH
   
   LET m_ies_situa = pol1420_atu_pedido_komatsu()
   
   IF m_houve_erro THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------------#   
FUNCTION pol1420_canc_all_progs()#
#--------------------------------#

   LET m_mensagem = 'CANCELOU SALDO'
   LET m_id_item = 0
   LET m_num_pc = NULL       
   LET m_seq_pc = NULL 
   LET m_qtd_solic = NULL   

   DECLARE cq_canc_prog CURSOR FOR
    SELECT num_sequencia,
           prz_entrega,                                     
           (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio),
           qtd_pecas_solic,
           qtd_pecas_cancel
      FROM ped_itens                                                                                        
     WHERE cod_empresa = p_cod_empresa                                                                      
       AND num_pedido = m_num_pedido                                                                        
       AND cod_item = m_cod_item                                                                            
       AND (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio) > 0                  
       AND prz_entrega NOT IN (SELECT prz_entrega FROM w_progs_komatsu)                                         
                                                                                                            
   FOREACH cq_canc_prog INTO                                                                            
      m_num_seq,
      m_prz_entrega,                                                                               
      m_qtd_atual,
      m_qtd_planej,
      m_qtd_cancel                                                                              
                                                                                                            
      IF STATUS <> 0 THEN                                                                                
         CALL log003_err_sql('SELECT','ped_itens:cq_canc_prog')                                            
         RETURN FALSE                                                                                       
      END IF                                                                                                
      
      IF pol1420_descarta() THEN
         CONTINUE FOREACH
      END IF

      LET m_qtd_oper = m_qtd_atual    
      LET m_qtd_cancel = m_qtd_cancel + m_qtd_atual
      
      IF NOT pol1420_atu_prog() THEN
         RETURN FALSE
      END IF
                                                                      
      IF NOT pol1420_ins_audit() THEN                              
         RETURN FALSE                                              
      END IF                                                       
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1420_descarta()#
#--------------------------#

   IF mr_arquivo.tip_prog = 'T' THEN                 
	 ELSE                                              	
      IF mr_arquivo.tip_prog = 'F' THEN                	
		     IF m_prz_entrega > mr_arquivo.dat_ate THEN  	
		        RETURN TRUE                         	
		     END IF                                      	
		  ELSE                                           	
		     IF m_prz_entrega <= mr_arquivo.dat_ate THEN 	
		        RETURN TRUE                   	
		     END IF                                      	
		  END IF                                         	
   END IF			                                       	
   
   RETURN FALSE

END FUNCTION

#----------------------------#    
FUNCTION pol1420_tela_print()#
#----------------------------#

   DEFINE l_menubar     VARCHAR(10),
          l_panel       VARCHAR(10),
          l_confirm     VARCHAR(10),
          l_cancel      VARCHAR(10)

    LET m_form_print = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_print,"SIZE",800,450)
    CALL _ADVPL_set_property(m_form_print,"TITLE","IMPRESS�O DE AUDITORIA")
    CALL _ADVPL_set_property(m_form_print,"INIT_EVENT","pol1420_init_print")

    LET m_stat_imp = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_print)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_print)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    CALL pol1420_par_print(l_panel)
    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_print)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) 
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_confirm = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirm,"IMAGE","CONFIRM_EX")
   CALL _ADVPL_set_property(l_confirm,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirm,"EVENT","pol1420_conf_imp")     

   LET l_cancel = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancel,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancel,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancel,"EVENT","pol1420_canc_imp")    

   CALL _ADVPL_set_property(m_form_print,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------#
FUNCTION pol1420_init_print()#
#----------------------------#

   CALL _ADVPL_set_property(m_cli_imp,"GET_FOCUS")

END FUNCTION    

#--------------------------------------#
FUNCTION pol1420_par_print(l_container)#
#--------------------------------------#

   DEFINE l_container       VARCHAR(10),
          l_layout          VARCHAR(10),
          l_label           VARCHAR(10),
          l_caixa           VARCHAR(10),
          l_lupa_cli        VARCHAR(10)
   
   INITIALIZE mr_print.* TO NULL
   
   LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_container)
   CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",3)

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
   CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    

   LET m_cli_imp = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
   CALL _ADVPL_set_property(m_cli_imp,"LENGTH",15)
   CALL _ADVPL_set_property(m_cli_imp,"VARIABLE",mr_print,"cod_cliente")
   CALL _ADVPL_set_property(m_cli_imp,"PICTURE","@E!")
   CALL _ADVPL_set_property(m_cli_imp,"VALID","pol1420_chec_cli")

   LET l_lupa_cli = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
   CALL _ADVPL_set_property(l_lupa_cli,"IMAGE","BTPESQ")
   CALL _ADVPL_set_property(l_lupa_cli,"SIZE",24,20)
   CALL _ADVPL_set_property(l_lupa_cli,"CLICK_EVENT","pol1420_zoom_cli_imp")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
   CALL _ADVPL_set_property(l_label,"TEXT","Nome:")    
   
   LET m_arq_imp = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
   CALL _ADVPL_set_property(m_arq_imp,"LENGTH",25)
   CALL _ADVPL_set_property(m_arq_imp,"VARIABLE",mr_print,"nom_cliente")
   CALL _ADVPL_set_property(m_arq_imp,"ENABLE",FALSE)

   CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")           
   
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
   CALL _ADVPL_set_property(l_label,"TEXT","Pedido:")    
   
   LET m_ped_imp = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
   CALL _ADVPL_set_property(m_ped_imp,"LENGTH",10)
   CALL _ADVPL_set_property(m_ped_imp,"VARIABLE",mr_print,"num_pedido")
   CALL _ADVPL_set_property(m_ped_imp,"PICTURE","######")

   CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")           

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
   CALL _ADVPL_set_property(l_label,"TEXT","Dat proces de:")    
   
   LET m_dat_de = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
   CALL _ADVPL_set_property(m_dat_de,"VARIABLE",mr_print,"dat_de")
   CALL _ADVPL_set_property(m_dat_de,"ENABLE",TRUE)

   CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")           

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
   CALL _ADVPL_set_property(l_label,"TEXT","Dat proces at�:")    
   
   LET m_dat_ate = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
   CALL _ADVPL_set_property(m_dat_ate,"VARIABLE",mr_print,"dat_ate")
   CALL _ADVPL_set_property(m_dat_ate,"ENABLE",TRUE)

   CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")           

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
   CALL _ADVPL_set_property(l_label,"TEXT","Prz entrega de:")    
   
   LET m_prz_de = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
   CALL _ADVPL_set_property(m_prz_de,"VARIABLE",mr_print,"prz_de")
   CALL _ADVPL_set_property(m_prz_de,"ENABLE",TRUE)

   CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")           

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
   CALL _ADVPL_set_property(l_label,"TEXT","Prz entrega at�:")    
   
   LET m_prz_ate = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
   CALL _ADVPL_set_property(m_prz_ate,"VARIABLE",mr_print,"prz_ate")
   CALL _ADVPL_set_property(m_prz_ate,"ENABLE",TRUE)

END FUNCTION

#------------------------------#
FUNCTION pol1420_zoom_cli_imp()#
#------------------------------#

   CALL pol1420_zoom_cliente('I') 

END FUNCTION

#--------------------------#
FUNCTION pol1420_chec_cli()#
#--------------------------#
   
   DEFINE l_id      INTEGER
   
   CALL _ADVPL_set_property(m_stat_imp,"ERROR_TEXT",'')
   
   IF mr_print.cod_cliente IS NULL THEN
      RETURN TRUE
   END IF

   SELECT COUNT(id_arquivo)
     INTO m_count 
     FROM audit_komatsu
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_print.cod_cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','audit_komatsu:3')
      RETURN FALSE
   END IF

   IF m_count = 0 THEN
      LET m_msg = 'Cliente n�o contem EDI processado'
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_cli_imp,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   SELECT nom_cliente 
     INTO mr_print.nom_cliente
     FROM clientes
    WHERE cod_cliente = mr_print.cod_cliente

   IF STATUS <> 0 THEN
      LET mr_print.nom_cliente = NULL
   END IF
   
   RETURN TRUE

END FUNCTION   
                 
#--------------------------#   
FUNCTION pol1420_canc_imp()#
#--------------------------#

   CALL _ADVPL_set_property(m_form_print,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION

#--------------------------#  
FUNCTION pol1420_conf_imp()#
#--------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
      
   IF mr_print.dat_de IS NOT NULL AND mr_print.dat_ate IS NOT NULL THEN
      IF mr_print.dat_ate < mr_print.dat_de THEN
         LET m_msg = 'Per�odo de processamento inv�lido.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         CALL _ADVPL_set_property(m_dat_de,"GET_FOCUS")
         RETURN FALSE
      END IF
   END IF

   IF mr_print.prz_de IS NOT NULL AND mr_print.prz_ate IS NOT NULL THEN
      IF mr_print.prz_ate < mr_print.prz_de THEN
         LET m_msg = 'Per�odo de prazo de entrega inv�lido.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         CALL _ADVPL_set_property(m_prz_de,"GET_FOCUS")
         RETURN FALSE
      END IF
   END IF
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1420_le_audit","PROCESS")  

   CALL _ADVPL_set_property(m_form_print,"ACTIVATE",FALSE)

   IF NOT p_status THEN
      LET m_msg = "Impress�o cancelada."
   ELSE
   
   END IF
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      
   RETURN TRUE

END FUNCTION
      
#--------------------------#
FUNCTION pol1420_le_audit()#
#--------------------------#
   
   DEFINE l_status SMALLINT,
          l_sql    CHAR(800)
   
   LET l_sql = "SELECT COUNT(*) FROM audit_komatsu WHERE cod_empresa = '",p_cod_empresa,"' "

   IF mr_print.cod_cliente IS NOT NULL THEN
      LET l_sql = l_sql CLIPPED, " AND cod_cliente = '",mr_print.cod_cliente,"' "
   END IF
   
   IF mr_print.num_pedido IS NULL OR mr_print.num_pedido <= 0 THEN
   ELSE
      LET l_sql = l_sql CLIPPED, " AND num_pedido = '",mr_print.num_pedido,"' "
   END IF

   IF mr_print.dat_de IS NOT NULL THEN
      LET l_sql = l_sql CLIPPED, " AND dat_operacao >= '",mr_print.dat_de,"' "
   END IF

   IF mr_print.dat_ate IS NOT NULL THEN
      LET l_sql = l_sql CLIPPED, " AND dat_operacao <= '",mr_print.dat_ate,"' "
   END IF

   IF mr_print.prz_de IS NOT NULL THEN
      LET l_sql = l_sql CLIPPED, " AND prz_entrega >= '",mr_print.prz_de,"' "
   END IF

   IF mr_print.prz_ate IS NOT NULL THEN
      LET l_sql = l_sql CLIPPED, " AND prz_entrega <= '",mr_print.prz_ate,"' "
   END IF
      
   PREPARE var_imp FROM l_sql
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('PREPARE','var_imp')
      RETURN FALSE
   END IF
   
   DECLARE cq_cont CURSOR FOR var_imp

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql("DECLARE","cq_cont",0)
      RETURN FALSE
   END IF
    
   OPEN cq_cont
    
   FETCH cq_cont INTO m_count
    
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log0030_processa_err_sql("FETCH","cq_cont",0)
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� dados p/ o par�mtros informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   LET m_msg = 'Ser�o impressos ', m_count USING '<<<<<<<<<<', ' registros.\n'
   LET m_msg = m_msg CLIPPED, 'Confirma a impress�o ?'

   IF  NOT LOG_question(m_msg) THEN
       RETURN FALSE
   END IF

   LET l_status = StartReport(
       "pol1420_relatorio","pol1420","ATUALIZACAO DE PEDIDOS VIA EDI - POL1420",157,TRUE,TRUE)
   
   RETURN l_status

END FUNCTION

#-----------------------------------#
FUNCTION pol1420_relatorio(l_report)#
#-----------------------------------#
   
   DEFINE l_report    CHAR(300),
          l_progres   SMALLINT,
          l_cod_cli   CHAR(15),
          l_status    SMALLINT,
          l_sql       CHAR(800)
   
   LET l_status = TRUE   
   LET m_page_length = ReportPageLength("pol1420")
       
   START REPORT pol1420_relat TO l_report

   CALL pol1420_le_den_empresa() RETURNING l_progres
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   LET m_ind_print = 1
   

   LET l_sql = 
       "SELECT cod_cliente, num_pc, seq_pc, item_cliente, num_pedido, cod_item, prz_entrega, ",
       "qtd_solic, qtd_atual, qtd_operacao, mensagem, usuario, dat_operacao, hor_operacao ",  
       "FROM audit_komatsu WHERE cod_empresa = '",p_cod_empresa,"' "                 

   IF mr_print.cod_cliente IS NOT NULL THEN
      LET l_sql = l_sql CLIPPED, " AND cod_cliente = '",mr_print.cod_cliente,"' "
   END IF
   
   IF mr_print.num_pedido IS NULL OR mr_print.num_pedido <= 0 THEN
   ELSE
      LET l_sql = l_sql CLIPPED, " AND num_pedido = '",mr_print.num_pedido,"' "
   END IF

   IF mr_print.dat_de IS NOT NULL THEN
      LET l_sql = l_sql CLIPPED, " AND dat_operacao >= '",mr_print.dat_de,"' "
   END IF

   IF mr_print.dat_ate IS NOT NULL THEN
      LET l_sql = l_sql CLIPPED, " AND dat_operacao <= '",mr_print.dat_ate,"' "
   END IF

   IF mr_print.prz_de IS NOT NULL THEN
      LET l_sql = l_sql CLIPPED, " AND prz_entrega >= '",mr_print.prz_de,"' "
   END IF

   IF mr_print.prz_ate IS NOT NULL THEN
      LET l_sql = l_sql CLIPPED, " AND prz_entrega <= '",mr_print.prz_ate,"' "
   END IF
   
   LET l_sql = l_sql CLIPPED, " ORDER BY cod_cliente, cod_item, prz_entrega "
   
   PREPARE var_rel FROM l_sql
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('PREPARE','var_rel')
      RETURN FALSE
   END IF
   
   DECLARE cq_rel CURSOR FOR var_rel
          
   FOREACH cq_rel INTO 
      mr_relat.cod_cliente,  
      mr_relat.num_pc,       
      mr_relat.seq_pc,       
      mr_relat.item_cliente, 
      mr_relat.num_pedido,   
      mr_relat.cod_item,     
      mr_relat.prz_entrega,  
      mr_relat.qtd_solic,    
      mr_relat.qtd_atual,    
      mr_relat.qtd_operacao, 
      mr_relat.mensagem,     
      mr_relat.usuario,      
      mr_relat.dat_operacao, 
      mr_relat.hor_operacao 
            
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','audit_komatsu:cq_rel')
         LET l_status = FALSE
         EXIT FOREACH
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS") 
      
      LET l_cod_cli = mr_relat.cod_cliente
      
      SELECT nom_cliente 
        INTO mr_relat.nom_cliente
        FROM clientes
       WHERE cod_cliente = l_cod_cli

      IF STATUS <> 0 THEN
         LET mr_relat.nom_cliente = NULL
      END IF

      SELECT den_item_reduz
        INTO mr_relat.den_item_reduz
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = mr_relat.cod_item

      IF STATUS <> 0 THEN
         LET mr_relat.den_item_reduz = NULL
      END IF         
      
      LET m_pedido_comp = ''
      
      IF mr_relat.num_pc IS NOT NULL THEN
         LET m_pedido_comp = mr_relat.num_pc
         IF mr_relat.seq_pc IS NOT NULL THEN
            LET m_pedido_comp = m_pedido_comp CLIPPED,'/',mr_relat.seq_pc USING '<<<<<'
         END IF
      END IF
      
      LET m_dat_hor = mr_relat.dat_operacao,' ',mr_relat.hor_operacao
      
      OUTPUT TO REPORT pol1420_relat(l_cod_cli)

   END FOREACH

   FINISH REPORT pol1420_relat

   CALL FinishReport("pol1420")
   
   RETURN l_status
   
END FUNCTION

#--------------------------------#
 FUNCTION pol1420_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
   
#----------------------------------#
REPORT pol1420_relat(l_cod_cliente)#
#----------------------------------#

   DEFINE l_cod_cliente   CHAR(15)
   
    OUTPUT
        TOP    MARGIN 0
        LEFT   MARGIN 0
        RIGHT  MARGIN 0
        BOTTOM MARGIN 0
        PAGE   LENGTH m_page_length
   
    ORDER EXTERNAL BY l_cod_cliente

    FORMAT

    PAGE HEADER

      CALL ReportPageHeader("pol1420")

      SKIP 1 LINE
           
   BEFORE GROUP OF l_cod_cliente
      SKIP TO TOP OF PAGE
      SKIP 1 LINE
      PRINT COLUMN 001, l_cod_cliente CLIPPED, ' - ', mr_relat.nom_cliente
      PRINT 
      PRINT COLUMN 001, 'PEDIDO ITEM            DESCRICAO          PRZ ENTREG QTD EDI  QTD CART VARIACAO OPERACAO        ITEM CLIETE     PEDIDO DO CLIENTE USUARIO    DATA DA OPERACAO'
      PRINT COLUMN 001, '------ --------------- ------------------ ---------- -------- -------- -------- --------------- --------------- ----------------- ---------- ----------------'
           
    ON EVERY ROW
        PRINT COLUMN 001, mr_relat.num_pedido USING '######',
              COLUMN 008, mr_relat.cod_item,
              COLUMN 024, mr_relat.den_item_reduz,
              COLUMN 043, mr_relat.prz_entrega,                            
              COLUMN 054, mr_relat.qtd_solic USING '#######&',              
              COLUMN 063, mr_relat.qtd_atual USING '#######&',              
              COLUMN 072, mr_relat.qtd_operacao USING '#######&',     
              COLUMN 081, mr_relat.mensagem,
              COLUMN 097, mr_relat.item_cliente[1,15],              
              COLUMN 113, m_pedido_comp,
              COLUMN 131, mr_relat.usuario,                            
              COLUMN 142, m_dat_hor

END REPORT
