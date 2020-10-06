#-----------------------------------------------------------------#
# MODULO..: GEO                                                   #
# SISTEMA.: ACERTO DE CAIXA (COBRANCAS)                           #
# PROGRAMA: geo1025                                               #
# AUTOR...: EVANDRO SIMENES                                       #
# DATA....: 01/04/2016                                            #
#-----------------------------------------------------------------#


DATABASE logix

GLOBALS

   DEFINE p_versao            CHAR(18)
   DEFINE p_cod_empresa       LIKE empresa.cod_empresa
   DEFINE p_user              LIKE usuarios.cod_usuario
   

END GLOBALS
   DEFINE m_programa                   VARCHAR(10)
   DEFINE m_ind_manual         CHAR(01)
   DEFINE m_val_gera_nc        CHAR(01)
   DEFINE m_par_cre_txt        LIKE par_cre_txt.parametro
   DEFINE m_val_depos_concil   DECIMAL(15,2)
   DEFINE m_num_lote_pgto      LIKE conc_pgto.num_lote #Número do lote de baixa.
   DEFINE m_ind                  INTEGER
   DEFINE m_funcao               CHAR(20)
   DEFINE m_page_length          SMALLINT
   DEFINE m_ind_cheque 			 INTEGER
   DEFINE m_ind_despesa		 INTEGER
   DEFINE m_ind_carga		 INTEGER
   DEFINE m_rotina_automatica    SMALLINT
   DEFINE m_status               SMALLINT

   DEFINE m_ies_onsulta          SMALLINT
   
   DEFINE m_consulta_ativa       SMALLINT
   define mr_filtro  record 
                cod_roteiro integer
                     end record 
           
   define m_botao_find          char(50)
   DEFINE m_botao_inform_despesa VARCHAR(50)
   DEFINE m_botao_quit_despesa VARCHAR(50)
   DEFINE m_status_bar_despesa VARCHAR(50)
   DEFINE m_botao_quit_carga VARCHAR(50)
   DEFINE m_status_bar_carga VARCHAR(50)
   DEFINE m_panel_despesa VARCHAR(50)
   DEFINE m_panel_reference_despesa VARCHAR(50)
   DEFINE m_panel_carga VARCHAR(50)
   DEFINE m_panel_reference_carga VARCHAR(50)
   DEFINE m_despesa_cod_operacao VARCHAR(50)
   DEFINE m_despesa_den_operacao VARCHAR(50)
   DEFINE m_despesa_zoom_cod_operacao VARCHAR(50)
   DEFINE m_despesa_cod_cc VARCHAR(50)
   DEFINE m_despesa_den_cc VARCHAR(50)
   DEFINE m_despesa_zoom_cod_cc VARCHAR(50)
   DEFINE m_despesa_num_docum VARCHAR(50)
   DEFINE m_despesa_val_despesa VARCHAR(50)
   DEFINE m_despesa_descricao VARCHAR(50)
  
   DEFINE m_botao_despesas      CHAR(50)
   DEFINE m_botao_manifesto      CHAR(50)
   DEFINE m_botao_retorno      CHAR(50)
   DEFINE m_botao_carga         CHAR(50)
   DEFINE m_botao_cobranca      CHAR(50) 
   DEFINE m_botao_incluir       CHAR(50) 
   DEFINE m_botao_modificar     CHAR(50) 
   DEFINE m_botao_excluir       CHAR(50) 
   DEFINE m_botao_consultar     CHAR(50) 
   DEFINE m_botao_primeiro      CHAR(50) 
   DEFINE m_botao_anterior      CHAR(50) 
   DEFINE m_botao_seguinte      CHAR(50) 
   DEFINE m_botao_ultimo        CHAR(50) 
   define m_refer_filtro_2      char(50)
   define m_refer_filtro_3      char(50)
   define m_zoom_item           VARCHAR(15)
   DEFINE m_den_item_pai        VARCHAR(15)
   DEFINE m_column_cod_empresa  VARCHAR(50)
   DEFINE m_column_cod_cliente  VARCHAR(50)
   DEFINE m_column_cod_manifesto VARCHAR(50)
   DEFINE m_column_num_nf       VARCHAR(50)
   DEFINE m_column_ser_nf       VARCHAR(50)
   DEFINE m_refer_cod_manifesto VARCHAR(50)
   
   DEFINE ma_desp_zoom           ARRAY[5000] OF RECORD
             operacao            DECIMAL(5,0),
             des_operacao        CHAR(100)
                END RECORD
   DEFINE ma_cad_cc           ARRAY[5000] OF RECORD
             cod_cent_custo        DECIMAL(4,0),
             ies_cod_versao        DECIMAL(3,0),
             nom_cent_custo        CHAR(50)
                END RECORD
   DEFINE ma_manifesto           ARRAY[5000] OF RECORD
             cod_manifesto            LIKE clientes.cod_cliente
                                 END RECORD
   DEFINE m_field_val_cheques   VARCHAR(50)
   DEFINE m_field_val_despesas   VARCHAR(50)
   DEFINE m_field_val_dinheiro  VARCHAR(50)
   DEFINE m_field_val_juros     VARCHAR(50)
   DEFINE m_column_titulo       VARCHAR(50)
   DEFINE m_column_val_bruto    VARCHAR(50)
   DEFINE m_refer_tot_pagto     VARCHAR(50)
   DEFINE m_refer_tot_saldo     VARCHAR(50)
   DEFINE m_refer_saldo_vendedor VARCHAR(50)
   DEFINE m_refer_tot_bruto     VARCHAR(50)
   DEFINE m_refer_saldo_cc     VARCHAR(50)
   DEFINE m_column_val_saldo    VARCHAR(50)
   DEFINE m_column_val_juros    VARCHAR(50)
   DEFINE m_column_val_pagto    VARCHAR(50)
   DEFINE m_column_data_pagto   VARCHAR(50)
   DEFINE m_column_portador     VARCHAR(50)
   DEFINE m_column_val_despesa   VARCHAR(50)
   DEFINE m_column_val_cheque   VARCHAR(50)
   DEFINE m_column_val_dinheiro VARCHAR(50)
   DEFINE m_column_cheque       VARCHAR(50)
   DEFINE m_column_despesa       VARCHAR(50)
   define mr_cliente RECORD
             nom_cliente LIKE clientes.nom_cliente
             END RECORD
             
   DEFINE ma_cheque ARRAY[99] OF RECORD
                  check       CHAR(1),
                  num_cheque  CHAR(10),
                  dat_cheque  DATE,
                  val_cheque  DECIMAL(15,2),
                  titul_relac  CHAR(200)
                  
              END RECORD
     DEFINE ma_despesas ARRAY[99] OF RECORD
                  cod_operacao LIKE mcx_movto.operacao,
                  den_operacao CHAR(30),
                  cod_cc       CHAR(04),
                  den_cc       CHAR(50),
                  num_docum    LIKE mcx_movto.docum,
                  val_despesa  DECIMAL(20,2),
                  den_despesa  CHAR(500)
                  
              END RECORD
     DEFINE ma_carga ARRAY[999] OF RECORD
              num_remessa   LIKE fat_nf_mestre.nota_fiscal,
              ser_remessa   LIKE fat_nf_mestre.serie_nota_fiscal,
              cod_item      CHAR(15),
              den_item      CHAR(76),
              unid_med      CHAR(3),
              qtd_remessa   DECIMAL(17,6),
              qtd_vendido   DECIMAL(17,6),
              qtd_retornado DECIMAL(17,6),
              qtd_diferenca DECIMAL(17,6)
           END RECORD
   DEFINE ma_tela ARRAY[9999] OF RECORD
                 # selecionado  CHAR(1),
                 # cod_empresa  CHAR(2),
                  cod_manifesto  INTEGER,
                  cod_cliente  CHAR(15),
                  num_nf       INTEGER,
                  ser_nf       CHAR(3),
                  titulo       CHAR(20),
                  val_bruto    DECIMAL(20,2),
                  portador     CHAR(20),
                  val_cheque  DECIMAL(20,2),
                  val_dinheiro DECIMAL(20,2),
                  val_saldo    DECIMAL(20,2),
                  val_juros    DECIMAL(20,2)
              END RECORD
   DEFINE ma_tipo ARRAY[9999] OF RECORD
            tipo CHAR(1)
         END RECORD
   DEFINE mr_receb RECORD
             cod_cliente CHAR(15),
             nom_cliente CHAR(50),
             num_nf INTEGER,
             ser_nf CHAR(3),
             titulo CHAR(14),
             #val_pagto DECIMAL(20,2),
             val_cheque DECIMAL(20,2),
             val_dinheiro DECIMAL(20,2),
             val_bruto DECIMAL(20,2),
             val_juros DECIMAL(20,2)
             END RECORD
   define mr_tela, mr_telar   record
                         cod_manifesto INTEGER,
                         cod_resp      LIKE clientes.cod_cliente,
                         den_resp      LIKE clientes.nom_cliente,
                         dat_manifesto LIKE representante.raz_social,
                         cod_transp    LIKE fornecedor.cod_fornecedor,
                         den_transp    LIKE fornecedor.raz_social,
                         placa_veic    CHAR(10),
                         sit_manifesto CHAR(1),
                         tot_bruto     DECIMAL(20,2),
                         tot_saldo     DECIMAL(20,2),
                         tot_chq_receb DECIMAL(20,2),
                         tot_desp      DECIMAL(20,2),
                         tot_din_receb DECIMAL(20,2),
                         saldo_cc      DECIMAL(20,2),
                         saldo_vendedor DECIMAL(20,2)
                  end record 
   DEFINE m_cod_repres DECIMAL(4,0)  
   define mr_filtro record
                           cod_empresa char(2),
                           cod_rota     integer,
                           cod_cliente  LIKE clientes.cod_cliente
                    end record


 define m_agrupa_itens char(1)

# variaveis referencias form

   # tela principal
   DEFINE m_form_principal             VARCHAR(10)
   DEFINE m_form_cheque             	VARCHAR(10)
   DEFINE m_form_despesa             	VARCHAR(10)
   DEFINE m_form_carga             	VARCHAR(10)
   DEFINE m_cheque_check				VARCHAR(10)
   DEFINE m_cheque_num_cheque			VARCHAR(10)
   DEFINE m_cheque_dat_cheque			VARCHAR(10)
   DEFINE m_cheque_val_cheque			VARCHAR(10)
   DEFINE m_cheque_titul_relac			VARCHAR(10)
   DEFINE m_cheque_titulo				VARCHAR(10)
   DEFINE m_cheque_campos				VARCHAR(10)
   define m_toolbar                    VARCHAR(50)
   define m_toolbar_cheque             VARCHAR(50)
   define m_toolbar_despesa            VARCHAR(50)
   define m_toolbar_carga            VARCHAR(50)

   define m_botao_inform               varchar(50)
   define m_botao_cheque_confirma        varchar(50)
   define m_botao_cheque_cancela        varchar(50)
   define m_botao_cheque_novo          varchar(50)
   
   define m_botao_inform_cheque        varchar(50)
   define m_botao_process              varchar(50)
   define m_botao_print                varchar(50)
   define m_botao_quit                 varchar(50)
   define m_botao_quit_cheque          varchar(50)
   define m_status_bar                 varchar(50)
   define m_status_bar_cheque          varchar(50)

   DEFINE m_splitter_reference         VARCHAR(50)
   define m_panel_1                    varchar(50)
   define m_panel_cheque               varchar(50)
   define m_panel_2                    varchar(50)
   define m_panel_reference1           varchar(50)
   define m_panel_reference_cheque     varchar(50)
   define m_panel_reference2           varchar(50)
   define m_layoutmanager_refence_1    varchar(50)
   define m_layoutmanager_refence_2    varchar(50)
   define m_layoutmanager_refence_3    varchar(50)
   define m_table_reference1           varchar(50)
   define m_table_reference2           varchar(50)
   define m_table_reference3           varchar(50)
   define m_table_reference4           varchar(50)
   
   define m_carga_num_remessa          varchar(50)
   define m_carga_ser_remessa          varchar(50)
   define m_carga_cod_item             varchar(50)
   define m_carga_den_item             varchar(50)
   define m_carga_um                   varchar(50)
   define m_carga_qtd_remessa          varchar(50)
   define m_carga_qtd_vendido          varchar(50)
   define m_carga_qtd_retornado        varchar(50)
   define m_carga_qtd_diferenca        varchar(50)
   
   
   

   define m_column_reference           varchar(50)
   
   #tela filtro

   define m_form_filtro                varchar(50)
   define m_toolbar_filtro             varchar(50)
   define m_botao_find_filtro          varchar(50)
   define m_splitter_filtro            varchar(50)
   define m_panel_reference_filtro_1   varchar(50)
   define m_panel_reference_filtro_2   varchar(50)
   define m_panel_reference_filtro_3   varchar(50)
   define m_layoutmanager_filtro_1     varchar(50)
   define m_layoutmanager_filtro_2     varchar(50)

   define m_refer_filtro_data_ini      varchar(50)
   DEFINE m_refer_campos			   VARCHAR(50)
   DEFINE m_refer_tot_din_receb		   VARCHAR(50)
   DEFINE m_refer_tot_chq_receb		   VARCHAR(50)
   define m_refer_filtro_data_fin      varchar(50)

   define m_btn_selecionar_1           varchar(50)
   define m_btn_selecionar_2           varchar(50)
   define m_btn_selecionar_3           varchar(50)
   define m_btn_selecionar_4           varchar(50)
   define m_btn_selecionar_5           varchar(50)
   define m_btn_selecionar_6           varchar(50)
   define m_btn_selecionar_7           varchar(50)

      #tela itens
   define m_grc_altura_largura         CHAR(1)

   define m_form_itens                 varchar(50)
   define m_form_itens_array           varchar(50)
   define m_splitter_itens             varchar(50)
   define m_splitter_itens2            VARCHAR(50)
   define m_panel_reference_item_1     varchar(50)
   define m_panel_reference_item_2     varchar(50)
   define m_panel_reference_item_3     varchar(50)
   define m_panel_reference_item_4     varchar(50)
   define m_layoutmanager_item_1       varchar(10)
   define m_layoutmanager_item_2       varchar(10)
   DEFINE m_botao_find_principal       VARCHAR(10)

   define m_refer_item_agrupa          VARCHAR(50)

   define m_table_item                 varchar(50)

   define m_menuitem                   varchar(50)
   define m_ok_button                  varchar(50)
   define m_cancel_button              varchar(50)

   define m_menuitem2                  varchar(50)
   define m_ok_button2                 varchar(50)
   define m_cancel_button2             varchar(50)
   DEFINE m_confirma_item              SMALLINT

#-------------------#
 FUNCTION geo1025()
#-------------------#
   DEFINE l_label                      VARCHAR(50)
        , l_status                     SMALLINT

   CALL fgl_setenv("ADVPL","1")
   CALL LOG_connectDatabase("DEFAULT")

   CALL log1400_isolation()
   CALL log0180_conecta_usuario()

   CALL LOG_initApp('VDPLOG') RETURNING l_status

   LET m_ind = 0

   IF NOT l_status THEN
      CALL geo1025_tela()
   END IF

END FUNCTION

#--------------------------------------#
FUNCTION geo1025_args(l_cod_manifesto)
#--------------------------------------#
   DEFINE l_cod_manifesto    INTEGER
   
   LET mr_tela.cod_manifesto = l_cod_manifesto
   
   CALL geo1025_tela()
   
END FUNCTION

#-------------------#
 FUNCTION geo1025_tela()
#-------------------#

   DEFINE l_label        VARCHAR(50)
        , l_splitter     VARCHAR(50)
        , l_status       SMALLINT
        , l_panel_center VARCHAR(10)
        , l_tst CHAR(99)
     
     CALL geo1025_cria_temp()
     
     #cria janela principal do tipo LDIALOG
     LET m_form_principal = _ADVPL_create_component(NULL,"LDIALOG")
     CALL _ADVPL_set_property(m_form_principal,"TITLE","ACERTO DE CAIXA - COBRANCAS")
     CALL _ADVPL_set_property(m_form_principal,"ENABLE_ESC_CLOSE",FALSE)
     CALL _ADVPL_set_property(m_form_principal,"SIZE",1000,550)#   1024,725)

     #cria menu
     LET m_toolbar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_principal)
     
     LET m_botao_incluir = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_incluir,"TYPE","NO_CONFIRM")
     CALL _ADVPL_set_property(m_botao_incluir,"IMAGE","CONFIRM_EX")
     CALL _ADVPL_set_property(m_botao_incluir,"CLICK_EVENT","geo1025_grava_cobranca")

     LET m_botao_modificar = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_modificar,"TYPE","NO_CONFIRM")
     CALL _ADVPL_set_property(m_botao_modificar,"IMAGE","CANCEL_EX")
     CALL _ADVPL_set_property(m_botao_modificar,"CLICK_EVENT","geo1025_cancela_cobranca")#botao sair
     
     
     
     #botao sair
     LET m_botao_quit = _ADVPL_create_component(NULL,"LQUITBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_quit, "VISIBLE", FALSE)


     LET m_status_bar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_principal)

     #  FIM MENU
 
      #cria panel para campos de filtro 
      LET m_panel_1 = _ADVPL_create_component(NULL,"LPANEL",m_form_principal)
      CALL _ADVPL_set_property(m_panel_1,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_panel_1,"HEIGHT",440)
      
     #cria panel  
     LET m_panel_reference1 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel_1)
     CALL _ADVPL_set_property(m_panel_reference1,"TITLE","ACERTO DE CAIXA - COBRANCAS")
     CALL _ADVPL_set_property(m_panel_reference1,"ALIGN","CENTER")
     #CALL _ADVPL_set_property(m_panel_reference2,"HEIGHT",900)
     
     
     LET m_layoutmanager_refence_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_reference1)
     CALL _ADVPL_set_property(m_layoutmanager_refence_1,"MARGIN",TRUE)
     CALL _ADVPL_set_property(m_layoutmanager_refence_1,"COLUMNS_COUNT",2)
     
     LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
	  CALL _ADVPL_set_property(l_label,"TEXT","Manifesto:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",10,30)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
	
	LET m_refer_cod_manifesto = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
	  CALL _ADVPL_set_property(m_refer_cod_manifesto,"VARIABLE",mr_tela,"cod_manifesto")
	  CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_refer_cod_manifesto,"LENGTH",15)
	  CALL _ADVPL_set_property(m_refer_cod_manifesto,"VALID","geo1025_valid_cod_manifesto")
	  CALL _ADVPL_set_property(m_refer_cod_manifesto,"POSITION",100,29)
      #cria campo den_roteiro
     
     LET m_zoom_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_reference1)
	   CALL _ADVPL_set_property(m_zoom_item,"EDITABLE",TRUE)
	   CALL _ADVPL_set_property(m_zoom_item,"POSITION",201,29)
	   CALL _ADVPL_set_property(m_zoom_item,"IMAGE", "BTPESQ")
	   CALL _ADVPL_set_property(m_zoom_item,"CLICK_EVENT","geo1025_zoom_manifesto")
	   CALL _ADVPL_set_property(m_zoom_item,"SIZE",24,20)
	   CALL _ADVPL_set_property(m_zoom_item,"TOOLTIP","Zoom Manifesto")
	
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
	  CALL _ADVPL_set_property(l_label,"TEXT","Data:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",300,30)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
	LET m_refer_campos = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel_reference1)
	  CALL _ADVPL_set_property(m_refer_campos,"VARIABLE",mr_tela,"dat_manifesto")
	  CALL _ADVPL_set_property(m_refer_campos,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_refer_campos,"POSITION",360,29)
      #cria campo den_roteiro
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
	  CALL _ADVPL_set_property(l_label,"TEXT","Situação:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",550,30)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
	LET m_refer_campos = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
	  CALL _ADVPL_set_property(m_refer_campos,"VARIABLE",mr_tela,"sit_manifesto")
	  CALL _ADVPL_set_property(m_refer_campos,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_refer_campos,"LENGTH",15)
	  CALL _ADVPL_set_property(m_refer_campos,"POSITION",620,29)
      #cria campo den_roteiro
    
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
	  CALL _ADVPL_set_property(l_label,"TEXT","Responsável:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",10,60)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
	LET m_refer_campos = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
	  CALL _ADVPL_set_property(m_refer_campos,"VARIABLE",mr_tela,"cod_resp")
	  CALL _ADVPL_set_property(m_refer_campos,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_refer_campos,"LENGTH",10)
	  #CALL _ADVPL_set_property(m_refer_campos,"VALID","geo1025_valid_")
	  CALL _ADVPL_set_property(m_refer_campos,"POSITION",100,59)
      #cria campo den_roteiro
    
  LET m_refer_campos = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_campos,"VARIABLE",mr_tela,"den_resp")
  CALL _ADVPL_set_property(m_refer_campos,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_campos,"LENGTH",25)
  CALL _ADVPL_set_property(m_refer_campos,"POSITION",191,59)
  
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
	  CALL _ADVPL_set_property(l_label,"TEXT","Transportadora:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",430,60)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
	LET m_refer_campos = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
	  CALL _ADVPL_set_property(m_refer_campos,"VARIABLE",mr_tela,"cod_transp")
	  CALL _ADVPL_set_property(m_refer_campos,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_refer_campos,"LENGTH",10)
	  #CALL _ADVPL_set_property(m_refer_campos,"VALID","geo1025_valid_")
	  CALL _ADVPL_set_property(m_refer_campos,"POSITION",530,59)
      #cria campo den_roteiro
    
  LET m_refer_campos = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_campos,"VARIABLE",mr_tela,"den_transp")
  CALL _ADVPL_set_property(m_refer_campos,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_campos,"LENGTH",25)
  CALL _ADVPL_set_property(m_refer_campos,"POSITION",622,59)
  
#cria panel para campos de filtro 
      LET l_panel_center = _ADVPL_create_component(NULL,"LPANEL",m_panel_reference1)
      CALL _ADVPL_set_property(l_panel_center,"ALIGN","BOTTOM")
      CALL _ADVPL_set_property(l_panel_center,"HEIGHT",340)
      
  
  #cria panel  
     LET m_panel_reference2 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel_center)
     CALL _ADVPL_set_property(m_panel_reference2,"TITLE","")
     CALL _ADVPL_set_property(m_panel_reference2,"ALIGN","TOP")
     CALL _ADVPL_set_property(m_panel_reference2,"HEIGHT",340)


 #cria array
      LET m_table_reference1 = _ADVPL_create_component(NULL,"LBROWSEEX",m_panel_reference2)
      CALL _ADVPL_set_property(m_table_reference1,"SIZE",900,340)
      CALL _ADVPL_set_property(m_table_reference1,"CAN_ADD_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference1,"CAN_REMOVE_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference1,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_table_reference1,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_table_reference1,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_table_reference1,"POSITION",10,400)
      
      #mpo do array: cod_cliente
      LET m_column_cod_manifesto = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_cod_manifesto,"VARIABLE","cod_manifesto")
      CALL _ADVPL_set_property(m_column_cod_manifesto,"HEADER","Manifesto")
      CALL _ADVPL_set_property(m_column_cod_manifesto,"COLUMN_SIZE", 20)
      CALL _ADVPL_set_property(m_column_cod_manifesto,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_cod_manifesto,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_column_cod_manifesto,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_column_cod_manifesto,"EDITABLE", FALSE)
      
      #mpo do array: cod_cliente
      LET m_column_cod_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_cod_cliente,"VARIABLE","cod_cliente")
      CALL _ADVPL_set_property(m_column_cod_cliente,"HEADER","Cliente")
      CALL _ADVPL_set_property(m_column_cod_cliente,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_column_cod_cliente,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_cod_cliente,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_column_cod_cliente,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(m_column_cod_cliente,"EDIT_PROPERTY","VALID","geo1025_valid_cod_item")
      CALL _ADVPL_set_property(m_column_cod_cliente,"EDITABLE", FALSE)
      
        #cria campo do array: cod_cliente
      LET m_column_num_nf = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_num_nf,"VARIABLE","num_nf")
      CALL _ADVPL_set_property(m_column_num_nf,"HEADER","NF")
      CALL _ADVPL_set_property(m_column_num_nf,"COLUMN_SIZE", 30)
      CALL _ADVPL_set_property(m_column_num_nf,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_num_nf,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_column_num_nf,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_column_num_nf,"EDITABLE", FALSE)
      
        #cria campo do array: cod_cliente
      LET m_column_ser_nf = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_ser_nf,"VARIABLE","ser_nf")
      CALL _ADVPL_set_property(m_column_ser_nf,"HEADER","Série")
      CALL _ADVPL_set_property(m_column_ser_nf,"COLUMN_SIZE", 30)
      CALL _ADVPL_set_property(m_column_ser_nf,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_ser_nf,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_column_ser_nf,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_column_ser_nf,"EDITABLE", FALSE)
      
        #cria campo do array: cod_cliente
      LET m_column_titulo = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_titulo,"VARIABLE","titulo")
      CALL _ADVPL_set_property(m_column_titulo,"HEADER","Título")
      CALL _ADVPL_set_property(m_column_titulo,"COLUMN_SIZE", 35)
      CALL _ADVPL_set_property(m_column_titulo,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_titulo,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_column_titulo,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_column_titulo,"EDITABLE", FALSE)
      
        #cria campo do array: cod_cliente
      LET m_column_val_bruto = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_val_bruto,"VARIABLE","val_bruto")
      CALL _ADVPL_set_property(m_column_val_bruto,"HEADER","Vl. Bruto")
      CALL _ADVPL_set_property(m_column_val_bruto,"COLUMN_SIZE", 35)
      CALL _ADVPL_set_property(m_column_val_bruto,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_val_bruto,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_column_val_bruto,"EDIT_PROPERTY","LENGTH",20,2) 
      CALL _ADVPL_set_property(m_column_val_bruto,"EDITABLE", FALSE)
      CALL _ADVPL_set_property(m_column_val_bruto,"PICTURE","@E R$999999999999999999.99")
       
        #cria campo do array: cod_cliente
      LET m_column_portador = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_portador,"VARIABLE","portador")
      CALL _ADVPL_set_property(m_column_portador,"HEADER","Portador")
      CALL _ADVPL_set_property(m_column_portador,"COLUMN_SIZE", 30)
      CALL _ADVPL_set_property(m_column_portador,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_portador,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_column_portador,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_column_portador,"EDITABLE", FALSE)
      
        #cria campo do array: cod_cliente
      LET m_column_val_cheque = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_val_cheque,"VARIABLE","val_cheque")
      CALL _ADVPL_set_property(m_column_val_cheque,"HEADER","Vl. Cheque")
      CALL _ADVPL_set_property(m_column_val_cheque,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(m_column_val_cheque,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_val_cheque,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_column_val_cheque,"EDIT_PROPERTY","LENGTH",20,2) 
      CALL _ADVPL_set_property(m_column_val_cheque,"PICTURE","@E R$999999999999999999.99")
      CALL _ADVPL_set_property(m_column_val_cheque,"EDITABLE", FALSE)
      
        #cria campo do array: cod_cliente
      LET m_column_val_dinheiro = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_val_dinheiro,"VARIABLE","val_dinheiro")
      CALL _ADVPL_set_property(m_column_val_dinheiro,"HEADER","Vl. Dinheiro")
      CALL _ADVPL_set_property(m_column_val_dinheiro,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(m_column_val_dinheiro,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_val_dinheiro,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_column_val_dinheiro,"EDIT_PROPERTY","LENGTH",20,2) 
      CALL _ADVPL_set_property(m_column_val_dinheiro,"PICTURE","@E R$999999999999999999.99")
      CALL _ADVPL_set_property(m_column_val_dinheiro,"EDITABLE", FALSE)
      
      #cria campo do array: cod_cliente
      LET m_column_val_saldo = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_val_saldo,"VARIABLE","val_saldo")
      CALL _ADVPL_set_property(m_column_val_saldo,"HEADER","Vl. Saldo")
      CALL _ADVPL_set_property(m_column_val_saldo,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(m_column_val_saldo,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_val_saldo,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_column_val_saldo,"EDIT_PROPERTY","LENGTH",20,2) 
      CALL _ADVPL_set_property(m_column_val_saldo,"EDITABLE", FALSE)
      CALL _ADVPL_set_property(m_column_val_saldo,"PICTURE","@E R$999999999999999999.99")
      
      
      #cria campo do array: cod_cliente
      LET m_column_val_juros = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_val_juros,"VARIABLE","val_juros")
      CALL _ADVPL_set_property(m_column_val_juros,"HEADER","Vl. Juros")
      CALL _ADVPL_set_property(m_column_val_juros,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(m_column_val_juros,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_val_juros,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_column_val_juros,"EDIT_PROPERTY","LENGTH",20,2) 
      CALL _ADVPL_set_property(m_column_val_juros,"EDITABLE", FALSE)
      CALL _ADVPL_set_property(m_column_val_juros,"PICTURE","@E R$999999999999999999.99")
      
      
      LET m_column_cheque = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_table_reference1)
      CALL _ADVPL_set_property(m_column_cheque,"COLUMN_SIZE",20)
      CALL _ADVPL_set_property(m_column_cheque,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_column_cheque,"NO_VARIABLE",TRUE)
      CALL _ADVPL_set_property(m_column_cheque,"IMAGE", "MAN_EDIT")
      CALL _ADVPL_set_property(m_column_cheque,"BEFORE_EDIT_EVENT","geo1025_vincula_cheque")
 
    # let ma_pedidos[1].num_pedido = '123'
     CALL _ADVPL_set_property(m_table_reference1,"SET_ROWS",ma_tela,0)
     CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)
 
  CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
  
  IF mr_tela.cod_manifesto IS NOT NULL AND mr_tela.cod_manifesto <> " " AND mr_tela.cod_manifesto <> 0 THEN
     CALL geo1025_valid_cod_manifesto()
  END IF 
  
  CALL _ADVPL_set_property(m_form_principal,"ACTIVATE",TRUE)
  
 END FUNCTION

#--------------------------------------#
FUNCTION geo1025_carrega_movto_repres()
#--------------------------------------#
   DEFINE l_sql_stmt CHAR(5000)
   DEFINE l_count    INTEGER
   DEFINE l_ind      INTEGER
   DEFINE l_existe_dhr SMALLINT
   DEFINE l_tip_manifesto CHAR(1)
   
   INITIALIZE ma_tela TO NULL
   
   SELECT COUNT(*)
     INTO l_count
     FROM geo_acerto_cobranca
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF l_count IS NULL or l_count = "" THEN
      LET l_count = 0
   END IF 
   
   SELECT tip_manifesto
     INTO l_tip_manifesto
     FROM geo_manifesto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   
   IF l_count > 0 THEN
   	   LET l_sql_stmt = " SELECT cod_manifesto_orig, ",
   	                           " cod_cliente, ",
   	                           " num_nf, ",
   	                           " ser_nf, ",
   	                           " cod_titulo, ",
   	                           " val_bruto, ",
   	                           " portador, ",
   	                           " val_cheque, ",
   	                           " val_dinheiro, ",
   	                           " val_saldo, ",
   	                           " val_juros, ",
   	                           " 'V' ",
                          " FROM geo_acerto_cobranca ",
                         " WHERE cod_empresa = '",p_cod_empresa,"'",
                         "   AND cod_manifesto = '",mr_tela.cod_manifesto,"'"
   	   LET l_sql_stmt = l_sql_stmt CLIPPED, " UNION ALL "
   	   
	   	{LET l_sql_stmt = l_sql_stmt CLIPPED," SELECT h.cod_manifesto, ",
                               " a.cliente, ",
                               " a.nota_fiscal,  ",
                               " a.serie_nota_fiscal, ", 
                               " c.docum_cre,  ",
                               " c.val_duplicata, ", 
                               " e.cod_portador, ", 
                               " 0, ",
                               " 0, ", 
                               " c.val_duplicata,  ",
                               " g.ies_tipo  ",
                          " FROM fat_nf_mestre a, ", 
                               " fat_nf_repr b,  ",
                               " fat_nf_duplicata c, ", 
                               " docum e,  ",
                               " cond_pgto g, ", 
                               " geo_manifesto h, ", 
                               " geo_remessa_movto i, ", 
                               " geo_repres_paramet j ",
                        " WHERE a.empresa           = c.empresa ",
                        "   AND e.cod_empresa       = a.empresa ",
                        "   AND a.trans_nota_fiscal = c.trans_nota_fiscal ",
                        "   AND c.docum_cre         = e.num_docum ",
                        "   AND a.cond_pagto        = g.cod_cnd_pgto ",
                        "   AND h.cod_empresa       = a.empresa ",
                        "   AND i.cod_empresa       = a.empresa ",
                        "   AND h.cod_manifesto     = i.cod_manifesto ",
                        "   AND a.trans_nota_fiscal = i.trans_nota_fiscal ",
                        "   AND h.cod_resp          = j.cod_cliente ",
                        "   AND j.cod_repres        = b.representante ",
                        "   AND b.empresa           = a.empresa ",
                        "   AND b.trans_nota_fiscal = a.trans_nota_fiscal ",
                        "   AND h.sit_manifesto     = 'E' ",
                        "   AND j.cod_repres        = '",m_cod_repres,"' ",
                        "   AND h.cod_empresa       = '",p_cod_empresa,"' ",
                        "   AND i.cod_manifesto     <> '",mr_tela.cod_manifesto,"' ",
                        "   AND e.num_docum NOT IN (SELECT DISTINCT cod_titulo ",
	   						  "                       FROM geo_acerto_cobranca ",
	   						  "                      WHERE cod_empresa = h.cod_empresa ",
	   						  "                        AND cod_manifesto = '",mr_tela.cod_manifesto,"')"}
	   LET l_sql_stmt = l_sql_stmt CLIPPED," SELECT DISTINCT h.cod_manifesto, a.cliente, ",
                               " a.nota_fiscal,  ",
                               " a.serie_nota_fiscal, ", 
                               " c.docum_cre,  ",
                               " c.val_duplicata, ", 
                               " e.cod_portador, ", 
                               " 0, ",
                               " 0, ", 
                               " c.val_duplicata,  ",
                               " 0, ", 
                               " g.ies_tipo  ",
                          " FROM fat_nf_mestre a, "
             IF l_tip_manifesto = "R" THEN
                LET l_sql_stmt = l_sql_stmt CLIPPED,
                               " fat_nf_repr b,  "
             END IF
             LET l_sql_stmt = l_sql_stmt CLIPPED,
                               " fat_nf_duplicata c, ", 
                               " docum e,  ",
                               " cond_pgto g, ", 
                               " geo_manifesto h, ", 
                               " geo_remessa_movto i, ", 
                               " geo_repres_paramet j ",
                        " WHERE a.empresa           = c.empresa ",
                        "   AND e.cod_empresa       = a.empresa ",
                        "   AND a.trans_nota_fiscal = c.trans_nota_fiscal ",
                        "   AND e.ies_situa_docum = 'N'",
                        "   AND e.ies_pgto_docum <> 'T'",
                        "   AND e.val_saldo > 0",
                        "   AND c.docum_cre         = e.num_docum ",
                        "   AND a.cond_pagto        = g.cod_cnd_pgto ",
                        "   AND h.cod_empresa       = a.empresa ",
                        "   AND i.cod_empresa       = a.empresa ",
                        " AND h.sit_manifesto     = 'E' ",
                        "   AND h.cod_manifesto     = i.cod_manifesto "
                        
       IF l_tip_manifesto = "B" THEN
          LET l_sql_stmt = l_sql_stmt CLIPPED," AND a.trans_nota_fiscal = i.trans_remessa  "
       ELSE
          LET l_sql_stmt = l_sql_stmt CLIPPED," AND a.trans_nota_fiscal = i.trans_nota_fiscal  ",
                                              " AND h.cod_resp          = j.cod_cliente ",
                                              " AND j.cod_repres        = '",m_cod_repres,"' ",
                                              "   AND j.cod_repres        = b.representante ",
						                        "   AND b.empresa           = a.empresa ",
						                        "   AND b.trans_nota_fiscal = a.trans_nota_fiscal "
						                        
       END IF 
       
       LET l_sql_stmt = l_sql_stmt CLIPPED,"   AND a.sit_nota_fiscal   = 'N' ",
                        "   AND h.cod_empresa       = '",p_cod_empresa,"' ",
                        "   AND i.cod_manifesto     <> '",mr_tela.cod_manifesto,"' ",
                        "   AND e.num_docum NOT IN (SELECT DISTINCT cod_titulo ",
	   						  "                       FROM geo_acerto_cobranca ",
	   						  "                      WHERE cod_empresa = h.cod_empresa ",
	   						  "                        AND cod_manifesto = '",mr_tela.cod_manifesto,"')"
	   						  
                        #"   ORDER BY g.ies_tipo "
   ELSE
	   {LET l_sql_stmt = " SELECT h.cod_manifesto, ",
                               " a.cliente, ",
                               " a.nota_fiscal,  ",
                               " a.serie_nota_fiscal, ", 
                               " c.docum_cre,  ",
                               " c.val_duplicata, ", 
                               " e.cod_portador, ", 
                               " 0, ",
                               " 0, ", 
                               " c.val_duplicata,  ",
                               " g.ies_tipo  ",
                          " FROM fat_nf_mestre a, ", 
                               " fat_nf_repr b,  ",
                               " fat_nf_duplicata c, ", 
                               " docum e,  ",
                               " cond_pgto g, ", 
                               " geo_manifesto h, ", 
                               " geo_remessa_movto i, ", 
                               " geo_repres_paramet j ",
                        " WHERE a.empresa           = c.empresa ",
                        "   AND e.cod_empresa       = a.empresa ",
                        "   AND a.trans_nota_fiscal = c.trans_nota_fiscal ",
                        "   AND c.docum_cre         = e.num_docum ",
                        "   AND a.cond_pagto        = g.cod_cnd_pgto ",
                        "   AND h.cod_empresa       = a.empresa ",
                        "   AND i.cod_empresa       = a.empresa ",
                        "   AND h.cod_manifesto     = i.cod_manifesto ",
                        "   AND a.trans_nota_fiscal = i.trans_nota_fiscal ",
                        "   AND h.cod_resp          = j.cod_cliente ",
                        "   AND j.cod_repres        = b.representante ",
                        "   AND b.empresa           = a.empresa ",
                        "   AND b.trans_nota_fiscal = a.trans_nota_fiscal ",
                        "   AND h.sit_manifesto     = 'E' ",
                        "   AND j.cod_repres        = '",m_cod_repres,"' ",
                        "   AND h.cod_empresa       = '",p_cod_empresa,"' ",
                        "   AND i.cod_manifesto     <> '",mr_tela.cod_manifesto,"' ",
                        "   ORDER BY g.ies_tipo "}
        LET l_sql_stmt = " SELECT DISTINCT h.cod_manifesto, a.cliente, ",
                               " a.nota_fiscal,  ",
                               " a.serie_nota_fiscal, ", 
                               " c.docum_cre,  ",
                               " c.val_duplicata, ", 
                               " e.cod_portador, ", 
                               " 0, ",
                               " 0, ", 
                               " c.val_duplicata,  ",
                               " 0, ", 
                               " g.ies_tipo  ",
                          " FROM fat_nf_mestre a, "
       IF l_tip_manifesto = "R" THEN
          LET l_sql_stmt = l_sql_stmt CLIPPED," fat_nf_repr b,  "
       END IF 
       LET l_sql_stmt = l_sql_stmt CLIPPED,
                               " fat_nf_duplicata c, ", 
                               " docum e,  ",
                               " cond_pgto g, ", 
                               " geo_manifesto h, ", 
                               " geo_remessa_movto i, ", 
                               " geo_repres_paramet j ",
                        " WHERE a.empresa           = c.empresa ",
                        "   AND e.cod_empresa       = a.empresa ",
                        "   AND e.ies_situa_docum = 'N'",
                        "   AND e.ies_pgto_docum <> 'T'",
                        "   AND e.val_saldo > 0",
                        "   AND a.trans_nota_fiscal = c.trans_nota_fiscal ",
                        "   AND c.docum_cre         = e.num_docum ",
                        "   AND a.cond_pagto        = g.cod_cnd_pgto ",
                        "   AND h.cod_empresa       = a.empresa ",
                        "   AND i.cod_empresa       = a.empresa ",
                        "   AND h.sit_manifesto     = 'E' ",
                        "   AND h.cod_manifesto     = i.cod_manifesto "
         
       IF l_tip_manifesto = "B" THEN
          LET l_sql_stmt = l_sql_stmt CLIPPED," AND a.trans_nota_fiscal = i.trans_remessa  "
       ELSE
          LET l_sql_stmt = l_sql_stmt CLIPPED," AND a.trans_nota_fiscal = i.trans_nota_fiscal  ",
                                              " AND h.cod_resp          = j.cod_cliente ",
                                              " AND j.cod_repres        = '",m_cod_repres,"' ",
                                              "   AND j.cod_repres        = b.representante ",
						                        "   AND b.empresa           = a.empresa ",
						                        "   AND b.trans_nota_fiscal = a.trans_nota_fiscal "
                        
       END IF 
       
       LET l_sql_stmt = l_sql_stmt CLIPPED,"  AND a.sit_nota_fiscal   = 'N' ",
                        "   AND h.cod_empresa       = '",p_cod_empresa,"' ",
                        "   AND i.cod_manifesto     <> '",mr_tela.cod_manifesto,"' ",
                        "   ORDER BY g.ies_tipo "
	
	END IF
	PREPARE var_query FROM l_sql_stmt
	DECLARE cq_caixa CURSOR WITH HOLD FOR var_query
	
	LET m_ind = 1
	LET mr_tela.tot_bruto = 0
	LET mr_tela.tot_saldo = 0
	LET mr_tela.tot_chq_receb = 0
	LET mr_tela.tot_din_receb = 0
	LET mr_tela.saldo_vendedor = 0
	
	LET l_existe_dhr = TRUE
	
	FOREACH cq_caixa INTO ma_tela[m_ind].*, ma_tipo[m_ind].tipo
	    
		IF ma_tipo[m_ind].tipo = "N" AND ma_tela[m_ind].portador <> 999 THEN
		   LET ma_tela[m_ind].val_dinheiro = 0
		   CALL _ADVPL_set_property(m_table_reference1,"LINE_COLOR",m_ind,255,224,163)
		ELSE
		   LET mr_tela.tot_bruto = mr_tela.tot_bruto + ma_tela[m_ind].val_bruto
		   IF ma_tela[m_ind].val_cheque IS NULL OR ma_tela[m_ind].val_cheque = "" THEN
		      LET ma_tela[m_ind].val_cheque = 0
		   END IF
		   IF ma_tela[m_ind].val_dinheiro IS NULL OR ma_tela[m_ind].val_dinheiro = "" THEN
		      LET ma_tela[m_ind].val_dinheiro = 0
		   END IF
		   CALL _ADVPL_set_property(m_table_reference1,"CLEAR_LINE_COLOR",m_ind)
		END IF 
		
		LET m_ind = m_ind + 1
		
	END FOREACH
	
	IF m_ind > 1 THEN
		LET m_ind = m_ind - 1
	END IF 
	
	IF l_count > 0 THEN
	   DELETE FROM t_cheques2 WHERE 1=1;
	   INSERT INTO t_cheques2
	   SELECT cod_empresa, cod_manifesto_orig, num_cheque, val_cheque, cod_titulo
	     FROM geo_acerto_chq_cobr
	    WHERE cod_empresa = p_cod_empresa
	      AND cod_manifesto = mr_tela.cod_manifesto
	   
	   IF sqlca.sqlcode <> 0 THEN
	      CALL log003_err_sql("INSERT","t_cheques2")
	   END IF
	END IF 
	LET mr_tela.tot_din_receb = 0
	CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",m_ind)
    CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
	
	CALL _ADVPL_set_property(m_table_reference1,"ENABLE",TRUE)
	
END FUNCTION
 
#---------------------------#
 function geo1025_confirmar_informar()
#---------------------------#

   CALL geo1025_habilita_campos_manutencao(FALSE,'INCLUIR')

   RETURN TRUE

 end function

#--------------------------------------------------------------------#
FUNCTION geo1025_exibe_mensagem_barra_status(l_mensagem,l_tipo_mensagem)
#--------------------------------------------------------------------#

   DEFINE l_mensagem               CHAR(500),
          l_tipo_mensagem          CHAR(010),
          l_tipo_mensagem_original CHAR(015)

   LET l_tipo_mensagem_original = LOG_retorna_tipo_mensagem_original(UPSHIFT(l_tipo_mensagem),TRUE)
   CALL _ADVPL_set_property(m_status_bar,l_tipo_mensagem_original CLIPPED," "||l_mensagem CLIPPED)

 END FUNCTION

 #---------------------------------------#
 function geo1025_valid_cod_manifesto()
#---------------------------------------#
   DEFINE l_cnpj LIKE clientes.num_cgc_cpf
   
   SELECT cod_resp, 
          dat_manifesto, 
          cod_transp, 
          placa_veic, 
          sit_manifesto
     INTO mr_tela.cod_resp,
          mr_tela.dat_manifesto,
          mr_tela.cod_transp,
          mr_tela.placa_veic,
          mr_tela.sit_manifesto
     FROM geo_manifesto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto

   IF sqlca.sqlcode = 100 THEN
      CALL _ADVPL_message_box("Manifesto não encontrado.")
      RETURN FALSE
   END IF

   SELECT nom_cliente, num_cgc_cpf
     INTO mr_tela.den_resp, l_cnpj
     FROM clientes
    WHERE cod_cliente = mr_tela.cod_resp
   
   SELECT cod_repres
     INTO m_cod_repres
     FROM representante
    WHERE num_cgc = l_cnpj
   
   IF m_cod_repres IS NULL OR m_cod_repres = "" THEN
      CALL _ADVPL_message_box("Representante não encontrado")
      RETURN FALSE
   END IF 
   
   SELECT raz_social
     INTO mr_tela.den_transp
     FROM fornecedor 
    WHERE cod_fornecedor = mr_tela.cod_transp
  
    
    CALL geo1025_carrega_movto_repres()
    
    
     
    LET mr_tela.tot_saldo = (mr_tela.tot_bruto + mr_tela.tot_desp) - (mr_tela.tot_din_receb + mr_tela.tot_chq_receb)
    LET mr_tela.saldo_vendedor = mr_tela.saldo_cc - mr_tela.tot_saldo
    
    #CALL _ADVPL_set_property(m_refer_tot_din_receb,"ENABLE",TRUE)
    #CALL _ADVPL_set_property(m_refer_tot_saldo,"REFRESH")
    #CALL _ADVPL_set_property(m_refer_saldo_vendedor,"REFRESH")
    
    return true 
 
 end function 
 
 #--------------------------------#
 FUNCTION geo1025_vincula_cheque()
 #--------------------------------#
   DEFINE l_label            VARCHAR(50)
        , l_splitter         VARCHAR(50)
        , l_status           SMALLINT
        , l_panel_center     VARCHAR(10)
        , l_panel_reference2 VARCHAR(10)
        , l_arr_curr         SMALLINT
        
    
    LET l_arr_curr = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
    
    LET mr_receb.cod_cliente = ma_tela[l_arr_curr].cod_cliente
    
    SELECT nom_cliente
      INTO mr_receb.nom_cliente
      FROM clientes
     WHERE cod_cliente = mr_receb.cod_cliente
    
    initialize ma_cheque to null
    
    LET mr_receb.num_nf = ma_tela[l_arr_curr].num_nf
    LET mr_receb.ser_nf = ma_tela[l_arr_curr].ser_nf
    LET mr_receb.titulo = ma_tela[l_arr_curr].titulo
    #LET mr_receb.val_pagto = ma_tela[l_arr_curr].val_pagto
    LET mr_receb.val_cheque = 0
    
    SELECT val_dinheiro, val_juros
      INTO mr_receb.val_dinheiro, mr_receb.val_juros
      FROM geo_acerto_cobranca
     WHERE cod_empresa = p_cod_empresa
       AND cod_manifesto = mr_tela.cod_manifesto
       AND num_nf = ma_tela[l_arr_curr].num_nf
       AND ser_nf = ma_tela[l_arr_curr].ser_nf
       AND cod_titulo = ma_tela[l_arr_curr].titulo
    
    IF mr_receb.val_dinheiro IS NULL OR mr_receb.val_dinheiro = " " THEN
       LET mr_receb.val_dinheiro = ma_tela[l_arr_curr].val_bruto
    END IF 
    
    LET mr_receb.val_bruto = ma_tela[l_arr_curr].val_bruto
    
     #cria janela principal do tipo LDIALOG
     LET m_form_cheque = _ADVPL_create_component(NULL,"LDIALOG")
     CALL _ADVPL_set_property(m_form_cheque,"TITLE","EFETUAR RECEBIMENTO")
     CALL _ADVPL_set_property(m_form_cheque,"ENABLE_ESC_CLOSE",FALSE)
     CALL _ADVPL_set_property(m_form_cheque,"SIZE",700,500)#   1024,725)

     # INICIO MENU

     #cria menu
     LET m_toolbar_cheque = _ADVPL_create_component(NULL,"LMENUBAR",m_form_cheque)
     
     LET m_botao_cheque_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar_cheque)
     CALL _ADVPL_set_property(m_botao_cheque_confirma,"TYPE","NO_CONFIRM")
     CALL _ADVPL_set_property(m_botao_cheque_confirma,"IMAGE","CONFIRM_EX")
     CALL _ADVPL_set_property(m_botao_cheque_confirma,"CLICK_EVENT","geo1025_grava_cheques")

     LET m_botao_cheque_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar_cheque)
     CALL _ADVPL_set_property(m_botao_cheque_cancela,"TYPE","NO_CONFIRM")
     CALL _ADVPL_set_property(m_botao_cheque_cancela,"IMAGE","CANCEL_EX")
     CALL _ADVPL_set_property(m_botao_cheque_cancela,"CLICK_EVENT","geo1025_cancela_cheques")#botao sair
     
     LET m_botao_cheque_novo = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar_cheque)
     CALL _ADVPL_set_property(m_botao_cheque_novo,"TYPE","NO_CONFIRM")
     CALL _ADVPL_set_property(m_botao_cheque_novo,"IMAGE","IconCheque")
     CALL _ADVPL_set_property(m_botao_cheque_novo,"CLICK_EVENT","geo1025_novo_cheque")#botao sair
     
     
     
     #botao sair
     LET m_botao_quit_cheque = _ADVPL_create_component(NULL,"LQUITBUTTON",m_toolbar_cheque)
     CALL _ADVPL_set_property(m_botao_quit_cheque,"VISIBLE",FALSE)

     LET m_status_bar_cheque = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_cheque)

     #  FIM MENU
 
      #cria panel para campos de filtro 
      LET m_panel_cheque = _ADVPL_create_component(NULL,"LPANEL",m_form_cheque)
      CALL _ADVPL_set_property(m_panel_cheque,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_panel_cheque,"HEIGHT",390)
      
     
     #cria panel  
     LET m_panel_reference_cheque = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel_cheque)
     CALL _ADVPL_set_property(m_panel_reference_cheque,"TITLE","EFETUAR RECEBIMENTO")
     CALL _ADVPL_set_property(m_panel_reference_cheque,"ALIGN","CENTER")
     #CALL _ADVPL_set_property(m_panel_reference2,"HEIGHT",500)
     
      LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",10,30)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
	  LET m_cheque_campos = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(m_cheque_campos,"VARIABLE",mr_receb,"cod_cliente")
	  CALL _ADVPL_set_property(m_cheque_campos,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_cheque_campos,"LENGTH",15)
	  CALL _ADVPL_set_property(m_cheque_campos,"POSITION",90,29)
      #cria campo den_roteiro
  
      LET m_cheque_campos = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(m_cheque_campos,"VARIABLE",mr_receb,"nom_cliente")
	  CALL _ADVPL_set_property(m_cheque_campos,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_cheque_campos,"LENGTH",25)
	  CALL _ADVPL_set_property(m_cheque_campos,"POSITION",230,29)
      #cria campo den_roteiro
      
      LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(l_label,"TEXT","Nº Título:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",470,30)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
	  LET m_cheque_campos = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(m_cheque_campos,"VARIABLE",mr_receb,"titulo")
	  CALL _ADVPL_set_property(m_cheque_campos,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_cheque_campos,"LENGTH",12)
	  CALL _ADVPL_set_property(m_cheque_campos,"POSITION",560,29)
      #cria campo den_roteiro
  
  
      LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(l_label,"TEXT","Nº NF:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",10,60)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
	  LET m_cheque_campos = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(m_cheque_campos,"VARIABLE",mr_receb,"num_nf")
	  CALL _ADVPL_set_property(m_cheque_campos,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_cheque_campos,"LENGTH",15)
	  CALL _ADVPL_set_property(m_cheque_campos,"POSITION",90,59)
      #cria campo den_roteiro
  
  
      LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(l_label,"TEXT","Série:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",10,90)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
	  LET m_cheque_campos = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(m_cheque_campos,"VARIABLE",mr_receb,"ser_nf")
	  CALL _ADVPL_set_property(m_cheque_campos,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_cheque_campos,"LENGTH",15)
	  CALL _ADVPL_set_property(m_cheque_campos,"POSITION",90,89)
      #cria campo den_roteiro
  
  
      LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(l_label,"TEXT","Valor Bruto:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",250,60)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
	  LET m_cheque_campos = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(m_cheque_campos,"VARIABLE",mr_receb,"val_bruto")
	  CALL _ADVPL_set_property(m_cheque_campos,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_cheque_campos,"LENGTH",8,2)
	  CALL _ADVPL_set_property(m_cheque_campos,"POSITION",330,59)
      #cria campo den_roteiro
  
  	  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(l_label,"TEXT","Valor Cheques:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",470,60)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	  
	  LET m_field_val_cheques = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(m_field_val_cheques,"VARIABLE",mr_receb,"val_cheque")
	  CALL _ADVPL_set_property(m_field_val_cheques,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_field_val_cheques,"LENGTH",8,2)
	  CALL _ADVPL_set_property(m_field_val_cheques,"POSITION",560,59)
      #cria campo den_roteiro
  
  
      LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(l_label,"TEXT","Valor Dinheiro:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",470,90)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	  
	  LET m_field_val_dinheiro = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(m_field_val_dinheiro,"VARIABLE",mr_receb,"val_dinheiro")
	  CALL _ADVPL_set_property(m_field_val_dinheiro,"ENABLE",TRUE)
	  CALL _ADVPL_set_property(m_field_val_dinheiro,"LENGTH",8,2)
	  CALL _ADVPL_set_property(m_field_val_dinheiro,"POSITION",560,89)
      #cria campo den_roteiro
  
  	  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(l_label,"TEXT","Valor Juros:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",250,90)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
	  LET m_field_val_juros = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(m_field_val_juros,"VARIABLE",mr_receb,"val_juros")
	  CALL _ADVPL_set_property(m_field_val_juros,"ENABLE",TRUE)
	  CALL _ADVPL_set_property(m_field_val_juros,"LENGTH",8,2)
	  CALL _ADVPL_set_property(m_field_val_juros,"POSITION",330,89)
  
      #cria panel para campos de filtro 
      LET l_panel_center = _ADVPL_create_component(NULL,"LPANEL",m_panel_reference_cheque)
      CALL _ADVPL_set_property(l_panel_center,"ALIGN","BOTTOM")
      CALL _ADVPL_set_property(l_panel_center,"HEIGHT",250)
      
  
     #cria panel  
     LET l_panel_reference2 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel_center)
     CALL _ADVPL_set_property(l_panel_reference2,"TITLE","")
     CALL _ADVPL_set_property(l_panel_reference2,"ALIGN","TOP")
     CALL _ADVPL_set_property(l_panel_reference2,"HEIGHT",250)


      #cria array
      LET m_table_reference2 = _ADVPL_create_component(NULL,"LBROWSEEX",l_panel_reference2)
      CALL _ADVPL_set_property(m_table_reference2,"SIZE",800,250)
      CALL _ADVPL_set_property(m_table_reference2,"CAN_ADD_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference2,"CAN_REMOVE_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference2,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_table_reference2,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_table_reference2,"ENABLE",TRUE)
	  CALL _ADVPL_set_property(m_table_reference2,"POSITION",10,100)

      #cria campo do array: cod_cliente
      LET m_cheque_check = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference2)
      CALL _ADVPL_set_property(m_cheque_check,"VARIABLE","check")
      CALL _ADVPL_set_property(m_cheque_check,"HEADER","#")
      CALL _ADVPL_set_property(m_cheque_check,"COLUMN_SIZE", 20)
      CALL _ADVPL_set_property(m_cheque_check,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_cheque_check,"EDITABLE", TRUE)
      CALL _ADVPL_set_property(m_cheque_check,"EDIT_COMPONENT","LCHECKBOX")
	  CALL _ADVPL_set_property(m_cheque_check,"EDIT_PROPERTY","VALUE_CHECKED","S")
	  CALL _ADVPL_set_property(m_cheque_check,"EDIT_PROPERTY","VALUE_NCHECKED","N")
	  CALL _ADVPL_set_property(m_cheque_check,"EDIT_PROPERTY","CHANGE_EVENT","geo1025_calcula_total")
      
      
      #cria campo do array: cod_cliente
      LET m_cheque_num_cheque = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference2)
      CALL _ADVPL_set_property(m_cheque_num_cheque,"VARIABLE","num_cheque")
      CALL _ADVPL_set_property(m_cheque_num_cheque,"HEADER","Nº Cheque")
      CALL _ADVPL_set_property(m_cheque_num_cheque,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_cheque_num_cheque,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_cheque_num_cheque,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_cheque_num_cheque,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_cheque_num_cheque,"EDITABLE", FALSE)
      
      #cria campo do array: cod_cliente
      LET m_cheque_dat_cheque = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference2)
      CALL _ADVPL_set_property(m_cheque_dat_cheque,"VARIABLE","dat_cheque")
      CALL _ADVPL_set_property(m_cheque_dat_cheque,"HEADER","Data do Cheque")
      CALL _ADVPL_set_property(m_cheque_dat_cheque,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_cheque_dat_cheque,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_cheque_dat_cheque,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_cheque_dat_cheque,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_cheque_dat_cheque,"EDITABLE", FALSE)
      
      #cria campo do array: cod_cliente
      LET m_cheque_val_cheque = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference2)
      CALL _ADVPL_set_property(m_cheque_val_cheque,"VARIABLE","val_cheque")
      CALL _ADVPL_set_property(m_cheque_val_cheque,"HEADER","Valor do Cheque")
      CALL _ADVPL_set_property(m_cheque_val_cheque,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_cheque_val_cheque,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_cheque_val_cheque,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_cheque_val_cheque,"EDIT_PROPERTY","LENGTH",15,2)
      CALL _ADVPL_set_property(m_cheque_val_cheque,"PICTURE","@E R$999999999999999.99") 
      CALL _ADVPL_set_property(m_cheque_val_cheque,"EDITABLE", FALSE)
      
      
      #cria campo do array: cod_cliente
      LET m_cheque_titul_relac = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference2)
      CALL _ADVPL_set_property(m_cheque_titul_relac,"VARIABLE","titul_relac")
      CALL _ADVPL_set_property(m_cheque_titul_relac,"HEADER","Títulos Relacionados")
      CALL _ADVPL_set_property(m_cheque_titul_relac,"COLUMN_SIZE", 100)
      CALL _ADVPL_set_property(m_cheque_titul_relac,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_cheque_titul_relac,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_cheque_titul_relac,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_cheque_titul_relac,"EDITABLE", FALSE)
      
      CALL geo1025_carrega_cheques()
      
      CALL _ADVPL_set_property(m_table_reference2,"SET_ROWS",ma_cheque,0)
      CALL _ADVPL_set_property(m_table_reference2,"ITEM_COUNT",m_ind_cheque)
   
      CALL _ADVPL_set_property(m_table_reference2,"REFRESH")
	  
	  #CALL _ADVPL_get_property(m_botao_inform_cheque,"DO_CLICK")
      CALL _ADVPL_set_property(m_form_cheque,"ACTIVATE",TRUE)
      
 END FUNCTION 
 
 
 #--------------------------------#
 FUNCTION geo1025_carrega_cheques()
 #--------------------------------#
 	DEFINE l_count     INTEGER
 	DEFINE l_arr_curr  INTEGER
 	DEFINE l_cod_tit_rel  CHAR(14)
 	DEFINE l_soma      DECIMAL(20,2)
 	DEFINE l_ind       INTEGER
 	
 	LET l_arr_curr = _ADVPL_get_property(m_table_reference1, "ITEM_SELECTED")
 	
 	DECLARE cq_cheques_vinc CURSOR FOR
 	SELECT 'N', num_cheque, dat_vencto, val_bruto  
 	  FROM geo_rel_chq
 	 WHERE cod_empresa = p_cod_empresa
 	   AND num_cheque NOT IN (SELECT DISTINCT num_cheque
 	                            FROM geo_acerto_chq_cobr
 	                           WHERE cod_empresa = p_cod_empresa
 	                             AND cod_manifesto <> mr_tela.cod_manifesto)
 	   AND num_cheque NOT IN (SELECT DISTINCT num_cheque
 	                            FROM geo_acerto_chq
 	                           WHERE cod_empresa = p_cod_empresa
 	                             AND cod_manifesto <> mr_tela.cod_manifesto)
 	   #AND (cod_tit_rel IS NULL OR cod_tit_rel = "")
 	
 	
 	
 	LET m_ind_cheque = 1
 	FOREACH cq_cheques_vinc INTO ma_cheque[m_ind_cheque].*
 	   
 	   SELECT COUNT(*)
 	     INTO l_count
 	     FROM t_cheques2
 	    WHERE cod_empresa = p_cod_empresa
 	      AND cod_tit_rel = ma_tela[l_arr_curr].titulo
 	      AND num_cheque = ma_cheque[m_ind_cheque].num_cheque
 	   IF l_count IS NULL OR l_count = "" THEN
 	      LET l_count = 0
 	   END IF 
 	   
 	   IF l_count > 0 THEN
 	      LET ma_cheque[m_ind_cheque].check = "S"
 	   END IF
 	   
 	   DECLARE cq_rel_titul CURSOR FOR 
 	   SELECT cod_tit_rel
 	     FROM t_cheques2
 	    WHERE cod_empresa = p_cod_empresa
 	      AND num_cheque = ma_cheque[m_ind_cheque].num_cheque
 	      AND cod_tit_rel <> ma_tela[l_arr_curr].titulo
 	   
 	   LET ma_cheque[m_ind_cheque].titul_relac = ""
 	   FOREACH cq_rel_titul INTO l_cod_tit_rel
 	      IF ma_cheque[m_ind_cheque].titul_relac IS NULL OR ma_cheque[m_ind_cheque].titul_relac = "" THEN
 	         LET ma_cheque[m_ind_cheque].titul_relac = l_cod_tit_rel CLIPPED
 	      ELSE
 	         LET ma_cheque[m_ind_cheque].titul_relac = ma_cheque[m_ind_cheque].titul_relac CLIPPED,", ",l_cod_tit_rel CLIPPED
 	      END IF 
 	   END FOREACH
       LET m_ind_cheque = m_ind_cheque + 1
    END FOREACH
    
    LET m_ind_cheque = m_ind_cheque - 1
    
    LET l_soma = 0
    FOR l_ind = 1 TO 99
       IF ma_cheque[l_ind].check = 'S' THEN
         LET l_soma = l_soma + ma_cheque[l_ind].val_cheque
       END IF 
    END FOR
    
    LET mr_receb.val_cheque = l_soma
    
    CALL _ADVPL_set_property(m_field_val_cheques,"REFRESH")
    #CALL geo1025_calcula_total()
 END FUNCTION

#--------------------------------#
 FUNCTION geo1025_calcula_total()
#--------------------------------#
   DEFINE l_ind            SMALLINT
   DEFINE l_soma           DECIMAL(12,2)
   DEFINE l_tst            CHAR(20)
   DEFINE l_dhr            DECIMAL(20,2)
   DEFINE l_sum            DECIMAL(20,2)
   DEFINE l_arr_curr       SMALLINT
   DEFINE l_funcao         CHAR(20)
   
   LET l_soma = 0
   FOR l_ind = 1 TO 99
      IF ma_cheque[l_ind].check = 'S' THEN
        LET l_soma = l_soma + ma_cheque[l_ind].val_cheque
      END IF 
   END FOR
   
   LET mr_receb.val_cheque = l_soma
   
   LET mr_receb.val_dinheiro = mr_receb.val_bruto - mr_receb.val_cheque
   
   IF mr_receb.val_dinheiro < 0 THEN
      LET mr_receb.val_dinheiro = 0
   END IF 
   
   CALL _ADVPL_set_property(m_field_val_cheques,"REFRESH")
   CALL _ADVPL_set_property(m_field_val_dinheiro,"REFRESH")
   
END FUNCTION

#---------------------------------#
FUNCTION geo1025_informar_cheque()
#---------------------------------#

   

END FUNCTION

#--------------------------------#
FUNCTION geo1025_grava_cheques()
#--------------------------------#
   DEFINE l_ind       SMALLINT
   DEFINE l_arr_curr  SMALLINT
   DEFINE l_arr_count SMALLINT
   DEFINE l_dhr       DECIMAL(20,2)
   DEFINE l_sum       DECIMAL(20,2)
   
   LET l_arr_count = _ADVPL_get_property(m_table_reference1,"ITEM_COUNT")
   LET l_arr_curr = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   
   SELECT SUM(val_dinheiro)
     INTO l_sum
     FROM geo_acerto_cobranca
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF l_sum IS NULL OR l_sum = " " THEN
      LET l_sum = 0
   END IF 
   
   LET l_dhr = l_dhr - l_sum
   
   DELETE 
     FROM t_cheques2
    WHERE cod_empresa = p_cod_empresa
      AND cod_tit_rel = mr_receb.titulo
   
   FOR l_ind = 1 TO 99
      IF ma_cheque[l_ind].num_cheque IS NULL OR ma_cheque[l_ind].num_cheque = "" THEN
         EXIT FOR
      END IF 
      
      IF ma_cheque[l_ind].check = "S" THEN
         
         INSERT INTO t_cheques2 VALUES (p_cod_empresa, ma_tela[l_arr_curr].cod_manifesto, ma_cheque[l_ind].num_cheque, ma_cheque[l_ind].val_cheque, mr_receb.titulo)  
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("INSERT","t_cheques2")
            RETURN FALSE
         END IF
      END IF 
      
   END FOR 
   
   LET ma_tela[l_arr_curr].val_dinheiro = mr_receb.val_dinheiro
   LET ma_tela[l_arr_curr].val_juros = mr_receb.val_juros
   LET ma_tela[l_arr_curr].val_cheque = mr_receb.val_cheque
   LET ma_tela[l_arr_curr].val_saldo = ma_tela[l_arr_curr].val_bruto - (mr_receb.val_cheque + mr_receb.val_dinheiro)
   
   LET mr_tela.tot_din_receb = 0
   LET mr_tela.tot_chq_receb = 0
   FOR l_ind = 1 TO l_arr_count
      IF ma_tela[l_ind].val_dinheiro IS NULL OR ma_tela[l_ind].val_dinheiro = "" THEN
         LET ma_tela[l_ind].val_dinheiro = 0
      END IF 
      LET mr_tela.tot_din_receb = mr_tela.tot_din_receb + ma_tela[l_ind].val_dinheiro
      
      IF ma_tela[l_ind].val_cheque IS NULL OR ma_tela[l_ind].val_cheque = "" THEN
         LET ma_tela[l_ind].val_cheque = 0
      END IF 
      LET mr_tela.tot_chq_receb = mr_tela.tot_chq_receb + ma_tela[l_ind].val_cheque
   END FOR 
   
   IF mr_receb.val_dinheiro < 0 THEN
      LET mr_receb.val_dinheiro = 0
   END IF 
   
   LET mr_tela.tot_din_receb = mr_tela.tot_din_receb + l_dhr
   
   
   
   #CALL _ADVPL_set_property(m_refer_tot_chq_receb,"REFRESH")
   #CALL _ADVPL_set_property(m_refer_tot_din_receb,"REFRESH")
   
   IF mr_receb.val_cheque > 0 OR mr_receb.val_dinheiro > 0 THEN
      CALL _ADVPL_set_property(m_table_reference1,"CLEAR_LINE_COLOR",l_arr_curr)
   ELSE
      CALL _ADVPL_set_property(m_table_reference1,"LINE_COLOR",l_arr_curr,255,224,163)
   END IF 
   
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
   
   CALL _ADVPL_get_property(m_botao_quit_cheque,"DO_CLICK")
   
   RETURN TRUE
END FUNCTION

#---------------------------------#
FUNCTION geo1025_cancela_cobranca()
#---------------------------------#
   CALL _ADVPL_get_property(m_botao_quit,"DO_CLICK") 
END FUNCTION
#---------------------------------#
FUNCTION geo1025_cancela_cheques()
#---------------------------------#
   CALL _ADVPL_get_property(m_botao_quit_cheque,"DO_CLICK") 
END FUNCTION
#----------------------------#
FUNCTION geo1025_cria_temp()
#----------------------------#
   WHENEVER ERROR CONTINUE
   DROP TABLE t_cheques2;
   CREATE TEMP TABLE t_cheques2(
      cod_empresa CHAR(2),
      cod_manifesto INTEGER,
      num_cheque CHAR(10),
      val_cheque DECIMAL(20,2),
      cod_tit_rel CHAR(14)
   );
   WHENEVER ERROR STOP
END FUNCTION
#-----------------------------#
FUNCTION geo1025_novo_cheque()
#-----------------------------#
   DEFINE l_arr_curr     SMALLINT
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   
   CALL chq0001_args(ma_tela[l_arr_curr].cod_cliente, m_cod_repres)
   
   CALL geo1025_carrega_cheques()
   CALL _ADVPL_set_property(m_table_reference2,"ITEM_COUNT",m_ind_cheque)
   CALL _ADVPL_set_property(m_table_reference2,"REFRESH")
   
END FUNCTION

#-------------------------------#
FUNCTION geo1025_grava_cobranca()
#-------------------------------#
   DEFINE l_ind        SMALLINT
   DEFINE l_arr_curr   SMALLINT
   DEFINE lr_t_cheques RECORD
              cod_empresa CHAR(2),
              cod_manifesto INTEGER,
              num_cheque CHAR(10),
              val_cheque DECIMAL(20,2),
              cod_tit_rel CHAR(14)
           END RECORD
   
   IF mr_tela.cod_manifesto IS NULL OR mr_tela.cod_manifesto = "" THEN
      CALL _ADVPL_message_box("Informe um manifesto")
      RETURN FALSE
   END IF
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   
   CALL log085_transacao("BEGIN")
   
   DELETE 
     FROM geo_acerto_cobranca
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","geo_acerto_cobranca")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   FOR l_ind = 1 TO _ADVPL_get_property(m_table_reference1,"ITEM_COUNT")
      IF ma_tela[l_ind].val_dinheiro > 0 OR ma_tela[l_ind].val_cheque > 0 THEN
         INSERT INTO geo_acerto_cobranca VALUES (p_cod_empresa,
                                        mr_tela.cod_manifesto,
                                        ma_tela[l_ind].cod_manifesto,
                                        ma_tela[l_ind].cod_cliente,
                                        ma_tela[l_ind].num_nf,
                                        ma_tela[l_ind].ser_nf,
                                        ma_tela[l_ind].titulo,
                                        ma_tela[l_ind].val_bruto,
                                        ma_tela[l_ind].val_bruto,
                                        #ma_tela[l_ind].val_pagto,
                                        TODAY,
                                        ma_tela[l_ind].portador,
                                        ma_tela[l_ind].val_cheque,
                                        ma_tela[l_ind].val_dinheiro,
                                        ma_tela[l_ind].val_saldo,
                                        ma_tela[l_ind].val_juros)
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("INSERT","geo_acerto_cobranca")
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
      END IF  
   END FOR 
   
   DELETE 
     FROM geo_acerto_chq_cobr
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","geo_acerto_chq_cobr")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   
   DECLARE cq_temp_cheque CURSOR WITH HOLD FOR
   SELECT *
     FROM t_cheques2
   
   LET l_ind = 0
   FOREACH cq_temp_cheque INTO lr_t_cheques.*
      LET l_ind = l_ind + 1
      INSERT INTO geo_acerto_chq_cobr VALUES (lr_t_cheques.cod_empresa,
                                         mr_tela.cod_manifesto,
                                         lr_t_cheques.cod_manifesto,
                                         l_ind,
                                         lr_t_cheques.cod_tit_rel,
                                         lr_t_cheques.num_cheque,
                                         lr_t_cheques.val_cheque)
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","geo_acerto_chq_cobr")
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
   END FOREACH
   CALL log085_transacao("COMMIT")
   
   CALL geo1025_cancela_cobranca()
END FUNCTION
