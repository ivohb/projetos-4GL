#-----------------------------------------------------------------#
# MODULO..: GEO                                                   #
# SISTEMA.: CADASTRO DE CONTRATOS DE LOCACAO                      #
# PROGRAMA: geo1013                                               #
# AUTOR...: EVANDRO SIMENES                                       #
# DATA....: 22/02/2016                                            #
#-----------------------------------------------------------------#


DATABASE logix

GLOBALS

   DEFINE p_versao            CHAR(18)
   DEFINE p_cod_empresa       LIKE empresa.cod_empresa
   DEFINE p_user              LIKE usuarios.cod_usuario
   DEFINE g_ies_ambiente  CHAR(01)

END GLOBALS

	#::: Variaveis utilizadas para a impressão em PDF :::#
 DEFINE ma_config_pdf ARRAY[999999] OF RECORD
        linha         CHAR(1000)
        END RECORD
 DEFINE m_comando CHAR(200)
 DEFINE m_ind              INTEGER
 DEFINE m_diretorio_pdf    CHAR(150)
 DEFINE m_diretorio_img    CHAR(150)
 DEFINE m_diretorio_padrao CHAR(150)
 DEFINE m_trans_nota_fiscal INTEGER
 DEFINE m_qtd_vias         CHAR(01)
#:::
	
   DEFINE m_arquivo CHAR(200)
   DEFINE m_rotina_automatica    SMALLINT
   DEFINE m_zoom_cond            VARCHAR(10)
   DEFINE m_botao_print          VARCHAR(10)
   DEFINE m_page_length          VARCHAR(10)

   DEFINE m_ies_onsulta          SMALLINT
   DEFINE m_column_zoom_item     VARCHAR(10)
   DEFINE m_botao_faturar        VARCHAR(10)
   DEFINE m_table_reference3     VARCHAR(10)
   DEFINE m_table_reference4     VARCHAR(10)
   DEFINE ma_zcond           ARRAY[5000] OF RECORD
             cod_cnd_pgto          LIKE cond_pgto.cod_cnd_pgto,
             den_cnd_pgto          LIKE cond_pgto.den_cnd_pgto
             END RECORD
   
   DEFINE ma_zitem               ARRAY[5000] OF RECORD
             cod_item          LIKE item.cod_item,
             den_item          LIKE item.den_item,
             den_item_reduz    LIKE item.den_item_reduz
             END RECORD

   DEFINE ma_zrepres               ARRAY[5000] OF RECORD
             cod_repres          LIKE representante.cod_repres,
             nom_repres          LIKE representante.raz_social,
             raz_social          LIKE representante.raz_social
             END RECORD
   DEFINE ma_faturar             ARRAY[5000] OF RECORD
             checkbox            CHAR(1),
             num_nf            INTEGER,
             cod_contrato      INTEGER,
             cod_cliente       CHAR(15),
             cod_repres        DECIMAL(4,0),
             ser_fabric        CHAR(15),
             dat_instal        DATE,
             val_loc_mes       DECIMAL(20,2),
             periodo_de        DATE,
             periodo_ate       DATE,
             nom_cliente       CHAR(36)
                                END RECORD
               
   DEFINE ma_relat             ARRAY[5000] OF RECORD
             checkbox            CHAR(1),
             num_nf            INTEGER,
             cod_contrato      INTEGER,
             cod_cliente       CHAR(15),
             cod_repres        DECIMAL(4,0),
             ser_fabric        CHAR(15),
             dat_instal        DATE,
             val_loc_mes       DECIMAL(20,2),
             periodo_de        DATE,
             periodo_ate       DATE,
             nom_cliente       CHAR(36)
                                END RECORD
               
   DEFINE ma_zclientes           ARRAY[5000] OF RECORD
             cod_cliente            LIKE clientes.cod_cliente
           , nom_cliente            LIKE clientes.nom_cliente
           , num_cgc_cpf            LIKE clientes.num_cgc_cpf
           , den_cidade             LIKE cidades.den_cidade
           , cod_uni_feder          LIKE cidades.cod_uni_feder
                                 END RECORD
  
   define mr_filtro  record 
                num_nf integer,
                cod_contrato integer,
                cod_cliente char(15),
                cod_repres decimal(4,0),
                ser_fabric char(15),
                data_de date,
                data_ate date,
                valor_de DECIMAL(20,2),
                valor_ate DECIMAL(20,2)
                     end record 
           
   define m_botao_find  char(50) 
   define m_filtro_num_nf char(50)
   define m_filtro_cod_contrato char(50)
   define m_filtro_cod_cliente char(50)
   define m_filtro_cod_repres char(50)
   #define m_filtro_ser_fabric char(50)
   define m_filtro_data_de char(50)
   define m_filtro_data_ate char(50)
   define m_filtro_valor_de char(50)
   define m_filtro_valor_ate char(50)
   define m_zoom_cliente                    VARCHAR(15)
   define m_zoom_repres                    VARCHAR(15)
   DEFINE m_den_item_pai                 VARCHAR(15)
   define m_column_cod_item          varchar(50)
   define m_column_den_item          varchar(50)
   define mr_cliente RECORD
             nom_cliente LIKE clientes.nom_cliente
             END RECORD
   DEFINE ma_tela             ARRAY[5000] OF RECORD
             cod_item   LIKE item.cod_item 
             ,den_item   LIKE item.den_item 
                                 END RECORD

   define mr_tela, mr_telar   record
                         num_nf LIKE fat_nf_mestre.nota_fiscal,
                         cod_contrato INTEGER,
                         ser_fabric CHAR(15),
                         dat_instal DATE,
                         cod_cliente LIKE clientes.cod_cliente,
                         nom_cliente LIKE clientes.nom_cliente,
                         cod_repres LIKE representante.cod_repres,
                         raz_social LIKE representante.raz_social,
                         observacao CHAR(999),
                         ies_suspenso CHAR(1),
                         dat_suspensao DATE,
                         ies_emite_nf CHAR(1) ,
                         val_loc_mes decimal(20,2),
                         cod_cnd_pgto decimal(3,0),
                         den_cnd_pgto char(30)
                  end record 
                  
 define m_agrupa_itens char(1)

# variaveis referencias form

   # tela principal
   DEFINE m_form_principal             VARCHAR(10)
   define m_toolbar                    VARCHAR(50)

   define m_botao_create               varchar(50)
   define m_botao_update               varchar(50)
   define m_botao_delete               varchar(50)
   define m_botao_find_principal       varchar(50)
   define m_botao_item                 varchar(50)
   define m_botao_first                varchar(50)
   define m_botao_previous             varchar(50)
   define m_botao_next                 varchar(50)
   define m_botao_last                 varchar(50)
   define m_botao_quit                 varchar(50)
   define m_status_bar                 varchar(50)

   DEFINE m_splitter_reference         VARCHAR(50)
   define m_panel_1          varchar(50)
   define m_panel_2          varchar(50)
   define m_panel_reference1           varchar(50)
   define m_panel_reference2           varchar(50)
   define m_layoutmanager_refence_1    varchar(50)
   define m_layoutmanager_refence_2    varchar(50)
   define m_layoutmanager_refence_3    varchar(50)
   define m_table_reference1           varchar(50)

   define m_column_reference           varchar(50)
   define m_column_cod_cliente          varchar(50)


   	DEFINE m_refer_num_nf        VARCHAR(50)
	DEFINE m_refer_cod_contrato  VARCHAR(50)
	DEFINE m_refer_dat_instal    VARCHAR(50)
	DEFINE m_refer_ser_fabric    VARCHAR(50)
	DEFINE m_refer_cod_cliente   VARCHAR(50)
	DEFINE m_refer_val_loc_mes   VARCHAR(50)
	DEFINE m_refer_cod_repres  VARCHAR(50)
	DEFINE m_refer_observacao    VARCHAR(50)
	DEFINE m_refer_cod_cnd_pgto    VARCHAR(50)
	DEFINE m_refer_den_cnd_pgto    VARCHAR(50)
	DEFINE m_refer_ies_suspenso  VARCHAR(50)
	DEFINE m_refer_dat_suspensao VARCHAR(50)
	DEFINE m_refer_ies_emite_nf  VARCHAR(50)

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

   define m_refer_filtro_empresa       varchar(50)
   define m_refer_filtro_data_ini      varchar(50)
   define m_refer_filtro_data_fin      varchar(50)

   define m_btn_selecionar_1           varchar(50)
   define m_btn_selecionar_2           varchar(50)
   define m_btn_selecionar_3           varchar(50)
   define m_btn_selecionar_4           varchar(50)
   define m_btn_selecionar_5           varchar(50)
   define m_btn_selecionar_6           varchar(50)
   define m_btn_selecionar_7           varchar(50)

   define m_refer_motorista            varchar(50)
   define m_refer_nom_motorista        varchar(50)
   define m_refer_placa_veiculo        varchar(50)
   define m_refer_peso_total           varchar(50)
   define m_refer_cubagem_total        varchar(50)
        , m_refer_volume_total         VARCHAR(50)

   define m_zoom_veiculo               varchar(50)
   define m_zoom_motorista             varchar(50)

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
 FUNCTION geo1013()
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
      CALL geo1013_tela()
   END IF

END FUNCTION

#-------------------#
 FUNCTION geo1013_tela()
#-------------------#

   DEFINE l_label  VARCHAR(50)
        , l_splitter                   VARCHAR(50)
        , l_status SMALLINT,
        l_panel_center           VARCHAR(10)

     #cria janela principal do tipo LDIALOG
     LET m_form_principal = _ADVPL_create_component(NULL,"LDIALOG")
     CALL _ADVPL_set_property(m_form_principal,"TITLE","CONTRATOS DE LOCAÇÃO")
     CALL _ADVPL_set_property(m_form_principal,"ENABLE_ESC_CLOSE",FALSE)
     CALL _ADVPL_set_property(m_form_principal,"SIZE",800,610)#   1024,725)

     #
     #
     #
     # INICIO MENU

     #cria menu
     LET m_toolbar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_principal)

     #botao INCLUIR
     LET m_botao_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_create,"EVENT","geo1013_incluir")
     CALL _ADVPL_set_property(m_botao_create,"CONFIRM_EVENT","geo1013_confirmar_inclusao")
     CALL _ADVPL_set_property(m_botao_create,"CANCEL_EVENT","geo1013_cancelar_inclusao")

     #botao MODIFICAR
     LET m_botao_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_update,"EVENT","geo1013_modificar")
     CALL _ADVPL_set_property(m_botao_update,"CONFIRM_EVENT","geo1013_confirmar_modificacao")
     CALL _ADVPL_set_property(m_botao_update,"CANCEL_EVENT","geo1013_cancelar_modificacao")

     #botao EXCLUIR
     LET m_botao_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_delete,"EVENT","geo1013_excluir")

     #botao LOCALIZAR
     LET m_botao_find_principal = _ADVPL_create_component(NULL,"LFINDBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_find_principal,"EVENT","geo1013_pesquisar")
     CALL _ADVPL_set_property(m_botao_find_principal,"TYPE","NO_CONFIRM")
     
     #botao primeiro registro
      LET m_botao_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_first,"EVENT","geo1013_primeiro")
      
      #botao anterior
      LET m_botao_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_previous,"EVENT","geo1013_anterior")
      
      #botao seguinte
      LET m_botao_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_next,"EVENT","geo1013_seguinte")
      
      #botao ultimo registro
      LET m_botao_last = _ADVPL_create_component(NULL,"LLASTBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_last,"EVENT","geo1013_ultimo")
      
		#botao ultimo registro
      LET m_botao_faturar = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_faturar,"EVENT","geo1013_form_faturar")
      CALL _ADVPL_set_property(m_botao_faturar,"IMAGE","FATURAR")
      
     #botao RELATORIO
     LET m_botao_print = _ADVPL_create_component(NULL,"LPRINTBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_print,"EVENT","geo1013_form_relat")
     
     
     #botao sair
     LET m_botao_quit = _ADVPL_create_component(NULL,"LQUITBUTTON",m_toolbar)


     LET m_status_bar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_principal)

     #  FIM MENU
 
      #cria panel para campos de filtro 
      LET m_panel_1 = _ADVPL_create_component(NULL,"LPANEL",m_form_principal)
      CALL _ADVPL_set_property(m_panel_1,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_panel_1,"HEIGHT",500)
      
     
     #cria panel  
     LET m_panel_reference1 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel_1)
     CALL _ADVPL_set_property(m_panel_reference1,"TITLE","CONTRATO DE LOCAÇÃO")
     CALL _ADVPL_set_property(m_panel_reference1,"ALIGN","CENTER")
     #CALL _ADVPL_set_property(m_panel_reference2,"HEIGHT",900)
     
     
     LET m_layoutmanager_refence_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_reference1)
     CALL _ADVPL_set_property(m_layoutmanager_refence_1,"MARGIN",TRUE)
     CALL _ADVPL_set_property(m_layoutmanager_refence_1,"COLUMNS_COUNT",2)


     {#cria panel  
     LET m_panel_reference2 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel_2)
     CALL _ADVPL_set_property(m_panel_reference2,"TITLE","SELECIONAR CIDADES: ")
     CALL _ADVPL_set_property(m_panel_reference2,"ALIGN","TOP")
     #CALL _ADVPL_set_property(m_panel_reference2,"HEIGHT",900)

     
     LET m_layoutmanager_refence_2 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_reference2)
     CALL _ADVPL_set_property(m_layoutmanager_refence_2,"MARGIN",TRUE)
     CALL _ADVPL_set_property(m_layoutmanager_refence_2,"COLUMNS_COUNT",1)
}
     #
     #
     # CABEÇALHO


LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Nº Remessa:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",10,20)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

LET m_refer_num_nf = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_num_nf,"VARIABLE",mr_tela,"num_nf")
  CALL _ADVPL_set_property(m_refer_num_nf,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_num_nf,"LENGTH",15)
  #CALL _ADVPL_set_property(m_refer_num_nf,"PICTURE","@!XXXXXXXXXXXXXXXX")
  #CALL _ADVPL_set_property(m_refer_num_nf,"VALID","man10002_valid_cod_item_pai")
  #CALL _ADVPL_set_property(m_refer_num_nf,"GOT_FOCUS_EVENT","man10002_before_field_cod_item_pai")
  #CALL _ADVPL_set_property(m_refer_num_nf,"LOST_FOCUS_EVENT","man10002_after_field_cod_item_pai")
  CALL _ADVPL_set_property(m_refer_num_nf,"POSITION",100,19)
      #cria campo den_roteiro
  
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Nº Contrato:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",370,20)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

LET m_refer_cod_contrato = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_cod_contrato,"VARIABLE",mr_tela,"cod_contrato")
  CALL _ADVPL_set_property(m_refer_cod_contrato,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_cod_contrato,"LENGTH",15)
  #CALL _ADVPL_set_property(m_refer_cod_contrato,"PICTURE","@!XXXXXXXXXXXXXXXX")
  #CALL _ADVPL_set_property(m_refer_cod_contrato,"VALID","man10002_valid_cod_item_pai")
  #CALL _ADVPL_set_property(m_refer_cod_contrato,"GOT_FOCUS_EVENT","man10002_before_field_cod_item_pai")
  #CALL _ADVPL_set_property(m_refer_cod_contrato,"LOST_FOCUS_EVENT","man10002_after_field_cod_item_pai")
  CALL _ADVPL_set_property(m_refer_cod_contrato,"POSITION",460,19)
  
  
      #cria campo den_roteiro
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Série Fabricante:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",10,50)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

LET m_refer_ser_fabric = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_ser_fabric,"VARIABLE",mr_tela,"ser_fabric")
  CALL _ADVPL_set_property(m_refer_ser_fabric,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_ser_fabric,"LENGTH",15)
  #CALL _ADVPL_set_property(m_refer_ser_fabric,"PICTURE","@!XXXXXXXXXXXXXXXX")
  #CALL _ADVPL_set_property(m_refer_ser_fabric,"VALID","man10002_valid_cod_item_pai")
  #CALL _ADVPL_set_property(m_refer_ser_fabric,"GOT_FOCUS_EVENT","man10002_before_field_cod_item_pai")
  #CALL _ADVPL_set_property(m_refer_ser_fabric,"LOST_FOCUS_EVENT","man10002_after_field_cod_item_pai")
  CALL _ADVPL_set_property(m_refer_ser_fabric,"POSITION",100,49)
      #cria campo den_roteiro
      
      
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Data Instalação:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",370,50)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

LET m_refer_dat_instal = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_dat_instal,"VARIABLE",mr_tela,"dat_instal")
  CALL _ADVPL_set_property(m_refer_dat_instal,"ENABLE",FALSE)
  #CALL _ADVPL_set_property(m_refer_dat_instal,"PICTURE","@!XXXXXXXXXXXXXXXX")
  #CALL _ADVPL_set_property(m_refer_dat_instal,"VALID","man10002_valid_cod_item_pai")
  #CALL _ADVPL_set_property(m_refer_dat_instal,"GOT_FOCUS_EVENT","man10002_before_field_cod_item_pai")
  #CALL _ADVPL_set_property(m_refer_dat_instal,"LOST_FOCUS_EVENT","man10002_after_field_cod_item_pai")
  CALL _ADVPL_set_property(m_refer_dat_instal,"POSITION",460,49)
      #cria campo den_roteiro
      
 
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",10,80)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

LET m_refer_cod_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_cod_cliente,"VARIABLE",mr_tela,"cod_cliente")
  CALL _ADVPL_set_property(m_refer_cod_cliente,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_cod_cliente,"LENGTH",15)
  #CALL _ADVPL_set_property(m_refer_cod_cliente,"PICTURE","@!XXXXXXXXXXXXXXXX")
  CALL _ADVPL_set_property(m_refer_cod_cliente,"VALID","geo1013_valid_cod_cliente")
  #CALL _ADVPL_set_property(m_refer_cod_cliente,"GOT_FOCUS_EVENT","man10002_before_field_cod_item_pai")
  #CALL _ADVPL_set_property(m_refer_cod_cliente,"LOST_FOCUS_EVENT","man10002_after_field_cod_item_pai")
  CALL _ADVPL_set_property(m_refer_cod_cliente,"POSITION",100,79)
      #cria campo den_roteiro
      
  LET m_zoom_cliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_reference1)
  CALL _ADVPL_set_property(m_zoom_cliente,"SIZE",24,20)
  CALL _ADVPL_set_property(m_zoom_cliente,"IMAGE","BTPESQ")
  CALL _ADVPL_set_property(m_zoom_cliente,"TOOLTIP","Zoom Clientes")
  CALL _ADVPL_set_property(m_zoom_cliente,"CLICK_EVENT","geo1013_zoom_clientes")
  CALL _ADVPL_set_property(m_zoom_cliente,"POSITION",233,79)

  LET m_den_item_pai = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_den_item_pai,"VARIABLE",mr_tela,"nom_cliente")
  CALL _ADVPL_set_property(m_den_item_pai,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_den_item_pai,"LENGTH",50)
  CALL _ADVPL_set_property(m_den_item_pai,"POSITION",260,79)
  

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Vendedor:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",10,110)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

LET m_refer_cod_repres = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_cod_repres,"VARIABLE",mr_tela,"cod_repres")
  CALL _ADVPL_set_property(m_refer_cod_repres,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_cod_repres,"LENGTH",15)
  #CALL _ADVPL_set_property(m_refer_cod_repres,"PICTURE","@!XXXXXXXXXXXXXXXX")
  CALL _ADVPL_set_property(m_refer_cod_repres,"VALID","geo1013_valid_cod_repres")
  #CALL _ADVPL_set_property(m_refer_cod_repres,"GOT_FOCUS_EVENT","man10002_before_field_cod_item_pai")
  #CALL _ADVPL_set_property(m_refer_cod_repres,"LOST_FOCUS_EVENT","man10002_after_field_cod_item_pai")
  CALL _ADVPL_set_property(m_refer_cod_repres,"POSITION",100,109)
      #cria campo den_roteiro
      
  LET m_zoom_repres = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_reference1)
  CALL _ADVPL_set_property(m_zoom_repres,"SIZE",24,20)
  CALL _ADVPL_set_property(m_zoom_repres,"IMAGE","BTPESQ")
  CALL _ADVPL_set_property(m_zoom_repres,"TOOLTIP","Zoom Representante")
  CALL _ADVPL_set_property(m_zoom_repres,"CLICK_EVENT","geo1013_zoom_representante")
  CALL _ADVPL_set_property(m_zoom_repres,"POSITION",233,109)

  LET m_den_item_pai = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_den_item_pai,"VARIABLE",mr_tela,"raz_social")
  CALL _ADVPL_set_property(m_den_item_pai,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_den_item_pai,"LENGTH",50)
  CALL _ADVPL_set_property(m_den_item_pai,"POSITION",260,109)
  
  
 
  #cria panel para campos de filtro 
      LET l_panel_center = _ADVPL_create_component(NULL,"LPANEL",m_panel_reference1)
      CALL _ADVPL_set_property(l_panel_center,"ALIGN","BOTTOM")
      CALL _ADVPL_set_property(l_panel_center,"HEIGHT",345)
      
  
  #cria panel  
     LET m_panel_reference2 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel_center)
     CALL _ADVPL_set_property(m_panel_reference2,"TITLE","ITENS DO CONTRATO")
     CALL _ADVPL_set_property(m_panel_reference2,"ALIGN","TOP")
     CALL _ADVPL_set_property(m_panel_reference2,"HEIGHT",170)
     
  
 #cria array
      LET m_table_reference1 = _ADVPL_create_component(NULL,"LBROWSEEX",m_panel_reference2)
      CALL _ADVPL_set_property(m_table_reference1,"SIZE",500,150)
      CALL _ADVPL_set_property(m_table_reference1,"CAN_ADD_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference1,"CAN_REMOVE_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference1,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_table_reference1,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_table_reference1,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_table_reference1,"POSITION",10,400)

      #CALL _ADVPL_set_property(m_table_etapa,"BEFORE_REMOVE_ROW_EVENT","man10217_before_remove_row_event_table_etapa")
      #CALL _ADVPL_set_property(m_table_reference1,"BEFORE_EDIT_EVENT","")
      
      
      #cria campo do array: cod_cliente
      LET m_column_cod_item = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_cod_item,"VARIABLE","cod_item")
      CALL _ADVPL_set_property(m_column_cod_item,"HEADER","Código do Item")
      CALL _ADVPL_set_property(m_column_cod_item,"COLUMN_SIZE", 70)
      CALL _ADVPL_set_property(m_column_cod_item,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_cod_item,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_column_cod_item,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_column_cod_item,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(m_column_cod_item,"EDITABLE", FALSE)
      
      LET m_column_zoom_item = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_table_reference1)
      CALL _ADVPL_set_property(m_column_zoom_item,"COLUMN_SIZE",10)
      CALL _ADVPL_set_property(m_column_zoom_item,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_column_zoom_item,"NO_VARIABLE",TRUE)
      CALL _ADVPL_set_property(m_column_zoom_item,"IMAGE", "BTPESQ")
      CALL _ADVPL_set_property(m_column_zoom_item,"BEFORE_EDIT_EVENT","geo1013_zoom_item")
    
       #cria campo do array: cod_cliente
      LET m_column_den_item = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_den_item,"VARIABLE","den_item")
      CALL _ADVPL_set_property(m_column_den_item,"HEADER","Descrição do Item")
      CALL _ADVPL_set_property(m_column_den_item,"COLUMN_SIZE", 170)
      CALL _ADVPL_set_property(m_column_den_item,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_den_item,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_column_den_item,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_column_den_item,"EDITABLE", FALSE)
      
       
    # let ma_pedidos[1].num_pedido = '123'
     CALL _ADVPL_set_property(m_table_reference1,"SET_ROWS",ma_tela,1)
     CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",1)
 
 
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Observação:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",10,320)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
  
  
  
LET m_refer_observacao = _ADVPL_create_component(NULL,"LTEXTAREA",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_observacao,"WORD_WRAP",TRUE)
  CALL _ADVPL_set_property(m_refer_observacao,"LENGTH",7,50)
  CALL _ADVPL_set_property(m_refer_observacao,"VERTICAL_SCROLL",TRUE)
  #CALL _ADVPL_set_property(m_refer_observacao,"ALIGN","CENTER")
  CALL _ADVPL_set_property(m_refer_observacao,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_observacao,"VARIABLE",mr_tela,"observacao")
  CALL _ADVPL_set_property(m_refer_observacao,"POSITION",100,320)
      #cria campo den_roteiro
      
LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Cond. Pagto:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",10,450)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
  
  
  
LET m_refer_cod_cnd_pgto = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_cod_cnd_pgto,"LENGTH",3)
  #CALL _ADVPL_set_property(m_refer_cod_cnd_pgto,"ALIGN","CENTER")
  CALL _ADVPL_set_property(m_refer_cod_cnd_pgto,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_cod_cnd_pgto,"VARIABLE",mr_tela,"cod_cnd_pgto")
  CALL _ADVPL_set_property(m_refer_cod_cnd_pgto,"VALID","geo1013_valid_cod_cnd_pgto")
  CALL _ADVPL_set_property(m_refer_cod_cnd_pgto,"POSITION",100,450)
      #cria campo den_roteiro
      
LET m_zoom_cond = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_reference1)
  CALL _ADVPL_set_property(m_zoom_cond,"SIZE",24,20)
  CALL _ADVPL_set_property(m_zoom_cond,"IMAGE","BTPESQ")
  CALL _ADVPL_set_property(m_zoom_cond,"TOOLTIP","Zoom Condições de Pagamento")
  CALL _ADVPL_set_property(m_zoom_cond,"CLICK_EVENT","geo1013_zoom_cond")
  CALL _ADVPL_set_property(m_zoom_cond,"POSITION",130,450)

  LET m_refer_den_cnd_pgto = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_den_cnd_pgto,"VARIABLE",mr_tela,"den_cnd_pgto")
  CALL _ADVPL_set_property(m_refer_den_cnd_pgto,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_den_cnd_pgto,"LENGTH",20)
  CALL _ADVPL_set_property(m_refer_den_cnd_pgto,"POSITION",155,450)
  
LET m_refer_ies_suspenso = _ADVPL_create_component(NULL,"LCHECKBOX",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_ies_suspenso,"POSITION",530,320)
  CALL _ADVPL_set_property(m_refer_ies_suspenso,"TEXT","Aluguel Suspenso")
  CALL _ADVPL_set_property(m_refer_ies_suspenso,"VALUE_CHECKED","S")
  CALL _ADVPL_set_property(m_refer_ies_suspenso,"VALUE_NCHECKED","N")
  CALL _ADVPL_set_property(m_refer_ies_suspenso,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_ies_suspenso,"VARIABLE",mr_tela,"ies_suspenso")
  
  
LET m_refer_dat_suspensao = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_dat_suspensao,"VARIABLE",mr_tela,"dat_suspensao")
  CALL _ADVPL_set_property(m_refer_dat_suspensao,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_dat_suspensao,"POSITION",670,320)
      #cria campo den_roteiro
  
  LET mr_tela.ies_emite_nf = "S"
  LET m_refer_ies_emite_nf = _ADVPL_create_component(NULL,"LCHECKBOX",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_ies_emite_nf,"POSITION",530,350)
  CALL _ADVPL_set_property(m_refer_ies_emite_nf,"TEXT","Emite NF")
  CALL _ADVPL_set_property(m_refer_ies_emite_nf,"VALUE_CHECKED","S")
  CALL _ADVPL_set_property(m_refer_ies_emite_nf,"VALUE_NCHECKED","N")
  CALL _ADVPL_set_property(m_refer_ies_emite_nf,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_ies_emite_nf,"VARIABLE",mr_tela,"ies_emite_nf")

   
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Valor da Locação Mensal")
  CALL _ADVPL_set_property(l_label,"SIZE",150,15)
  CALL _ADVPL_set_property(l_label,"POSITION",530,403)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

LET m_refer_val_loc_mes = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_val_loc_mes,"VARIABLE",mr_tela,"val_loc_mes")
  CALL _ADVPL_set_property(m_refer_val_loc_mes,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_val_loc_mes,"LENGTH",20,2)
  #CALL _ADVPL_set_property(m_refer_val_loc_mes,"PICTURE","@!XXXXXXXXXXXXXXXX")
  CALL _ADVPL_set_property(m_refer_val_loc_mes,"VALID","geo1013_valid_val_loc_mes")
  #CALL _ADVPL_set_property(m_refer_val_loc_mes,"GOT_FOCUS_EVENT","man10002_before_field_cod_item_pai")
  #CALL _ADVPL_set_property(m_refer_val_loc_mes,"LOST_FOCUS_EVENT","man10002_after_field_cod_item_pai")
  CALL _ADVPL_set_property(m_refer_val_loc_mes,"POSITION",530,417)
      #cria campo den_roteiro
       
  
  
  CALL _ADVPL_set_property(m_table_reference1,"REFRESH")

  CALL _ADVPL_set_property(m_form_principal,"ACTIVATE",TRUE)

 END FUNCTION

#---------------------------#
FUNCTION geo1013_incluir()
#---------------------------#

   INITIALIZE mr_tela.*, ma_tela to null
   LET mr_tela.ies_emite_nf = "S"
  
   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",1)
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
 

   #LET mr_tela.cod_empresa  = p_cod_empresa
     

   CALL geo1013_habilita_campos_manutencao(TRUE,'INCLUIR')

END FUNCTION

#-----------------------------#
 function geo1013_modificar()
#-----------------------------#
   define l_msg char(80)
   IF m_ies_onsulta = FALSE THEN
      CALL _ADVPL_message_box("Efetue a consulta primeiro")
      RETURN FALSE
   END IF 

   

  call geo1013_habilita_campos_manutencao(TRUE,'MODIFICAR')

 end function

#-----------------------------#
 function geo1013_excluir()
#-----------------------------#
   define l_msg char(80)

   IF m_ies_onsulta = FALSE THEN
      CALL _ADVPL_message_box("Efetue a consulta primeiro")
      RETURN FALSE
   END IF 

    let l_msg = 'Confirma a exclusão do contrato: ', mr_tela.cod_contrato, '?'
    IF LOG_pergunta(l_msg) THEN
    else
       return false
    end if

    CALL log085_transacao("BEGIN")
    DELETE
      FROM geo_loc_mestre
     WHERE cod_empresa = p_cod_empresa
       AND cod_contrato = mr_tela.cod_contrato
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("DELETE","geo_loc_mestre")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF 
    
    DELETE
      FROM geo_loc_itens
     WHERE cod_empresa = p_cod_empresa
       AND cod_contrato = mr_tela.cod_contrato
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("DELETE","geo_loc_itens")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF 
    
    


  initialize mr_tela.* to null
  initialize ma_tela  to null
  CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)
  CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
  CALL log085_transacao("COMMIT")
  LET m_ies_onsulta = FALSE
  RETURN TRUE
END FUNCTION
 
#---------------------------#
 function geo1013_confirmar_inclusao()
#---------------------------#

   
   CALL geo1013_atualiza_dados('INCLUSAO')
   CALL geo1013_habilita_campos_manutencao(FALSE,'INCLUIR')

   RETURN TRUE

 end function

#---------------------------#
 function  geo1013_cancelar_inclusao()
#---------------------------#
  call geo1013_habilita_campos_manutencao(FALSE,'INCLUIR')

 end function

#---------------------------#
 function geo1013_confirmar_modificacao()
#---------------------------#

   
   CALL geo1013_habilita_campos_manutencao(FALSE,'MODIFICAR')
   CALL geo1013_atualiza_dados('MODIFICACAO')

   RETURN TRUE

 end function
#
#---------------------------#
 function  geo1013_cancelar_modificacao()
#---------------------------#

  CALL geo1013_habilita_campos_manutencao(FALSE,'MODIFICAR')

 end function

#----------------------------------------------#
 function geo1013_atualiza_dados(l_funcao)
#----------------------------------------------#

   DEFINE l_funcao char(20)
   DEFINE l_ind    integer
   DEFINE l_data   date
   DEFINE l_hora   char(8)
   DEFINE l_dat_suspenso DATE
   
   LET l_data = TODAY
   LET l_hora = TIME
   
   CALL log085_transacao('BEGIN')
   
   INITIALIZE mr_tela.dat_suspensao TO NULL 
   IF mr_tela.ies_suspenso = "S" THEN
   	  LET mr_tela.dat_suspensao = TODAY
   END IF
   IF mr_tela.ies_emite_nf = "N" THEN
   	  LET mr_tela.dat_suspensao = TODAY
   END IF
   
   
   SELECT *
     FROM geo_loc_mestre
    WHERE cod_empresa = p_cod_empresa
      AND cod_contrato = mr_tela.cod_contrato
   
   if l_funcao = 'MODIFICACAO' then
      if sqlca.sqlcode <> 0 THEN
         CALL log0030_mensagem("O Contrato "||mr_tela.cod_contrato||" não foi encontrado.","excl")
         CALL log085_transacao('ROLLBACK')
         RETURN
      END IF
      
      UPDATE geo_loc_mestre
	   SET dat_instal = mr_tela.dat_instal,
	       ser_fabric = mr_tela.ser_fabric,
	       cod_cliente = mr_tela.cod_cliente,
	       cod_repres = mr_tela.cod_repres,
	       observacao = mr_tela.observacao,
	       ies_suspenso = mr_tela.ies_suspenso,
	       val_loc_mes = mr_tela.val_loc_mes,
	       dat_suspensao = mr_tela.dat_suspensao,
	       cod_cnd_pgto = mr_tela.cod_cnd_pgto,
	       ies_emite_nf = mr_tela.ies_emite_nf
	 WHERE cod_empresa = p_cod_empresa
	   AND cod_contrato = mr_tela.cod_contrato
      if sqlca.sqlcode <> 0 then
         CALL log003_err_sql("UPDATE","geo_loc_mestre")
         CALL log085_transacao('ROLLBACK')
         RETURN
      end if 
      delete from geo_loc_itens
       where cod_empresa = p_cod_empresa
         and cod_contrato = mr_tela.cod_contrato 
      if sqlca.sqlcode <> 0 then
         CALL log003_err_sql("DELETE","geo_loc_itens")
         CALL log085_transacao('ROLLBACK')
         RETURN
      end if 
   ELSE
      if sqlca.sqlcode = 0 THEN
         CALL log0030_mensagem("O Contrato "||mr_tela.cod_contrato||" já existe.","excl")
         CALL log085_transacao('ROLLBACK')
         RETURN
      END IF
      
	  INSERT INTO geo_loc_mestre VALUES (p_cod_empresa, mr_tela.cod_contrato, mr_tela.num_nf, mr_tela.dat_instal, mr_tela.ser_fabric, mr_tela.cod_cliente, mr_tela.cod_repres, mr_tela.observacao, mr_tela.ies_suspenso, mr_tela.dat_suspensao, mr_tela.ies_emite_nf, mr_tela.val_loc_mes, mr_tela.cod_cnd_pgto)
      if sqlca.sqlcode <> 0 then
         CALL log003_err_sql("INSERT","geo_loc_mestre")
         CALL log085_transacao('ROLLBACK')
         RETURN
      end if 
   end if

   for l_ind = 1 to 5000
      if ma_tela[l_ind].cod_item is null then
         exit for
      end if

      insert into geo_loc_itens ( cod_empresa
                               , cod_contrato
                               , cod_item ) values
                               (
                                p_cod_empresa,
                                mr_tela.cod_contrato,
                                ma_tela[l_ind].cod_item
                                )
       if sqlca.sqlcode <> 0 then
         CALL log003_err_sql("INSERT","geo_loc_itens")
         CALL log085_transacao('ROLLBACK')
         RETURN
      end if 
   end for
   LET m_ies_onsulta = FALSE
   CALL log085_transacao('COMMIT')

END FUNCTION

#----------------------------------------------#
 function geo1013_habilita_campos_manutencao(l_status,l_funcao)
#----------------------------------------------#

   DEFINE l_status smallint
   
   define l_funcao char(20)

   if l_funcao = 'INCLUIR' then
      CALL _ADVPL_set_property(m_refer_num_nf,"ENABLE",l_status) 
      CALL _ADVPL_set_property(m_refer_cod_contrato,"ENABLE",l_status) 
   end if
   
   CALL _ADVPL_set_property(m_refer_dat_instal,"ENABLE",l_status) 
   CALL _ADVPL_set_property(m_refer_ser_fabric,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_cod_cliente,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_cod_repres,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_observacao,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_ies_suspenso,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_ies_emite_nf,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_val_loc_mes,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_cod_cnd_pgto,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_zoom_cond,"ENABLE",l_status)
   
   #CALL _ADVPL_set_property(m_table_reference1,"CAN_ADD_ROW",l_status)
   #CALL _ADVPL_set_property(m_table_reference1,"CAN_REMOVE_ROW",l_status)
   CALL _ADVPL_set_property(m_table_reference1,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_table_reference1,"EDITABLE",l_status)
   
   CALL _ADVPL_set_property(m_column_cod_item,"EDITABLE", l_status)
   CALL _ADVPL_set_property(m_column_zoom_item,"EDITABLE", l_status)
   #CALL _ADVPL_set_property(m_column_seq_visita,"EDITABLE", l_status)
   
#   seq_visita

END FUNCTION
#
       
#---------------------------------------#
 function geo1013_zoom_clientes()
#---------------------------------------#
   DEFINE l_where_clause   CHAR(1000)
   DEFINE l_ind            SMALLINT
   define l_zoom_item varchar(10)
   define l_selecao integer 
   define l_cod_cliente char(15)
   
   INITIALIZE ma_zclientes TO NULL
   
   LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
   CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
   CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_zclientes)
   CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_clientes")
    
    let mr_tela.cod_cliente = ma_zclientes[1].cod_cliente
    let mr_tela.nom_cliente = ma_zclientes[1].nom_cliente
    
 end function
#
#---------------------------------------#
 function geo1013_zoom_representante()
#---------------------------------------#
   DEFINE l_where_clause   CHAR(1000)
   DEFINE l_ind            SMALLINT
   define l_zoom_item varchar(10)
   define l_selecao integer 
   define l_cod_cliente char(15)
   
   INITIALIZE ma_zrepres TO NULL

   LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
   CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
   CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_zrepres)
   CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_representante")
    
    let mr_tela.cod_repres = ma_zrepres[1].cod_repres
    let mr_tela.raz_social = ma_zrepres[1].raz_social
    
 end function
#
 
#---------------------------------------#
 function geo1013_zoom_item()
#---------------------------------------#
   DEFINE l_where_clause   CHAR(1000)
   DEFINE l_ind            SMALLINT
   define l_zoom_item varchar(10)
   define l_selecao integer 
   define l_cod_cliente char(15)
   
   LET l_selecao = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   
   if l_selecao < 1 then
     return true 
   end if 

   INITIALIZE ma_zitem TO NULL

   LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
   CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
   CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_zitem)
   CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_item")
    
    let ma_tela[l_selecao].cod_item = ma_zitem[1].cod_item
    let ma_tela[l_selecao].den_item = ma_zitem[1].den_item_reduz
    
    CALL _ADVPL_set_property(m_table_reference1,"REFRESH")

 end function
#
 
#-------------------------------------------#
 function geo1013_pesquisar()
#-------------------------------------------#

   CALL geo1013_tela_filtros('PESQUISAR')
   
 end function
 
#-------------------------------------------#
function geo1013_tela_filtros(l_opcao)
#-------------------------------------------#

DEFINE l_opcao char(20)
DEFINE l_panel_filtro,
         l_toolbar            VARCHAR(10)

  DEFINE l_panel_reference,
         l_panel_reference_1,
         l_panel_reference_2,
         l_panel_reference_0        VARCHAR(10)

  DEFINE l_layoutmanager_refence_1,
         l_layoutmanager_refence_2 VARCHAR(10)

  define l_layoutmanager_filtro varchar(10)
  define l_layoutmanager_array varchar(10)
  define l_column_reference         varchar(10)

  DEFINE l_status SMALLINT

  DEFINE l_splitter_reference VARCHAR(10)
DEFINE l_data    CHAR(10)
   initialize mr_filtro.* to null
   
   
   LET l_data = "01/01/",EXTEND(CURRENT, YEAR TO YEAR)
   LET mr_filtro.data_de = l_data
   LET l_data = "31/12/",EXTEND(CURRENT, YEAR TO YEAR)
   LET mr_filtro.data_ate = l_data
   LET mr_filtro.valor_de = 0
   LET mr_filtro.valor_ate = 999999
   
      #cria janela principal do tipo LDIALOG
      LET m_form_filtro = _ADVPL_create_component(NULL,"LDIALOG")
      CALL _ADVPL_set_property(m_form_filtro,"TITLE","FILTROS")
      CALL _ADVPL_set_property(m_form_filtro,"ENABLE_ESC_CLOSE",FALSE)
      CALL _ADVPL_set_property(m_form_filtro,"SIZE",500,400) 

      #cria menu
      LET l_toolbar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_filtro)

      #botao informar
      LET m_botao_find = _ADVPL_create_component(NULL,"LInformButton",l_toolbar)
      CALL _ADVPL_set_property(m_botao_find,"EVENT","geo1013_entrada_dados_filtro")
      
      CASE l_opcao 
      	WHEN 'PESQUISAR'
      		CALL _ADVPL_set_property(m_botao_find,"CONFIRM_EVENT","geo1013_confirmar_filtro")
      	WHEN 'FATURAR'
      		CALL _ADVPL_set_property(m_botao_find,"CONFIRM_EVENT","geo1013_tela_faturar")
      	WHEN 'RELAT'
      		CALL _ADVPL_set_property(m_botao_find,"CONFIRM_EVENT","geo1013_tela_relat")
      END case
      
      CALL _ADVPL_set_property(m_botao_find,"CANCEL_EVENT","geo1013_cancela_filtro")
 
      #cria splitter
      LET l_splitter_reference = _ADVPL_create_component(NULL,"LSPLITTER",m_form_filtro)
      CALL _ADVPL_set_property(l_splitter_reference,"ALIGN","CENTER")
      CALL _ADVPL_set_property(l_splitter_reference,"ORIENTATION","HORIZONTAL")

      #cria panel para campos de filtro
      LET l_panel_reference_0 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_splitter_reference)
      CALL _ADVPL_set_property(l_panel_reference_0,"TITLE","INFORMAR FILTROS DA PESQUISA")
 
      LET l_panel_reference_1 = _ADVPL_create_component(NULL,"LPANEL",l_panel_reference_0)
      CALL _ADVPL_set_property(l_panel_reference_1,"ALIGN","CENTER")
      CALL _ADVPL_set_property(l_panel_reference_1,"HEIGHT",10)
      
      LET l_panel_reference_2 = _ADVPL_create_component(NULL,"LPANEL",l_panel_reference_0)
      CALL _ADVPL_set_property(l_panel_reference_2,"ALIGN","BOTTOM")
      CALL _ADVPL_set_property(l_panel_reference_2,"HEIGHT",10)
      
      LET l_layoutmanager_refence_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference_1)
      CALL _ADVPL_set_property(l_layoutmanager_refence_1,"MARGIN",TRUE)
      CALL _ADVPL_set_property(l_layoutmanager_refence_1,"COLUMNS_COUNT",4)
 
      LET l_layoutmanager_refence_2 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference_2)
      CALL _ADVPL_set_property(l_layoutmanager_refence_2,"MARGIN",TRUE)
      CALL _ADVPL_set_property(l_layoutmanager_refence_2,"COLUMNS_COUNT",4)

      #cria campo cod_cliente
      
      CALL LOG_cria_rotulo(l_layoutmanager_refence_1,"Nº Remessa:")
      LET m_filtro_num_nf = _ADVPL_create_component(NULL, "LNUMERICFIELD", l_layoutmanager_refence_1,10) #LOG_cria_textfield(l_layoutmanager_refence_1,15)
      CALL _ADVPL_set_property(m_filtro_num_nf,"VARIABLE",mr_filtro,"num_nf")
      CALL _ADVPL_set_property(m_filtro_num_nf,"ENABLE",TRUE)
      
      CALL LOG_cria_rotulo(l_layoutmanager_refence_1,"Nº Contrato:")
      LET m_filtro_cod_contrato = _ADVPL_create_component(NULL, "LNUMERICFIELD", l_layoutmanager_refence_1,10) #LOG_cria_textfield(l_layoutmanager_refence_1,15)
      CALL _ADVPL_set_property(m_filtro_cod_contrato,"VARIABLE",mr_filtro,"cod_contrato")
      CALL _ADVPL_set_property(m_filtro_cod_contrato,"ENABLE",TRUE)
      
      CALL LOG_cria_rotulo(l_layoutmanager_refence_1,"Cliente:")
      LET m_filtro_cod_cliente = _ADVPL_create_component(NULL, "LTEXTFIELD", l_layoutmanager_refence_1,10) #LOG_cria_textfield(l_layoutmanager_refence_1,15)
      CALL _ADVPL_set_property(m_filtro_cod_cliente,"VARIABLE",mr_filtro,"cod_cliente")
      CALL _ADVPL_set_property(m_filtro_cod_cliente,"ENABLE",TRUE)
      
      CALL LOG_cria_rotulo(l_layoutmanager_refence_1,"Vendedor:")
      LET m_filtro_cod_repres = _ADVPL_create_component(NULL, "LNUMERICFIELD", l_layoutmanager_refence_1,10) #LOG_cria_textfield(l_layoutmanager_refence_1,15)
      CALL _ADVPL_set_property(m_filtro_cod_repres,"VARIABLE",mr_filtro,"cod_repres")
      CALL _ADVPL_set_property(m_filtro_cod_repres,"ENABLE",TRUE)
      
      #CALL LOG_cria_rotulo(l_layoutmanager_refence_1,"Série Fabricante:")
      #LET m_filtro_ser_fabric = _ADVPL_create_component(NULL, "LNUMERICFIELD", l_layoutmanager_refence_1,10) #LOG_cria_textfield(l_layoutmanager_refence_1,15)
      #CALL _ADVPL_set_property(m_filtro_ser_fabric,"VARIABLE",mr_filtro,"ser_fabric")
      #CALL _ADVPL_set_property(m_filtro_ser_fabric,"ENABLE",FALSE)
      
      CALL LOG_cria_rotulo(l_layoutmanager_refence_1,"Data Instalação De:")
      LET m_filtro_data_de = _ADVPL_create_component(NULL, "LDATEFIELD", l_layoutmanager_refence_1,10) #LOG_cria_textfield(l_layoutmanager_refence_1,15)
      CALL _ADVPL_set_property(m_filtro_data_de,"VARIABLE",mr_filtro,"data_de")
      CALL _ADVPL_set_property(m_filtro_data_de,"ENABLE",TRUE)
      
      CALL LOG_cria_rotulo(l_layoutmanager_refence_1,"Até:")
      LET m_filtro_data_ate = _ADVPL_create_component(NULL, "LDATEFIELD", l_layoutmanager_refence_1,10) #LOG_cria_textfield(l_layoutmanager_refence_1,15)
      CALL _ADVPL_set_property(m_filtro_data_ate,"VARIABLE",mr_filtro,"data_ate")
      CALL _ADVPL_set_property(m_filtro_data_ate,"ENABLE",TRUE)
      
      CALL LOG_cria_rotulo(l_layoutmanager_refence_1,"Valor Mensal De:")
      LET m_filtro_valor_de = _ADVPL_create_component(NULL, "LNUMERICFIELD", l_layoutmanager_refence_1,10) #LOG_cria_textfield(l_layoutmanager_refence_1,15)
      CALL _ADVPL_set_property(m_filtro_valor_de,"VARIABLE",mr_filtro,"valor_de")
      CALL _ADVPL_set_property(m_filtro_valor_de,"ENABLE",TRUE)
      CALL _ADVPL_set_property(m_filtro_valor_de,"LENGTH",8,2)
      CALL _ADVPL_set_property(m_filtro_valor_de,"PICTURE","@E 9999999.99")
      
      CALL LOG_cria_rotulo(l_layoutmanager_refence_1,"Até:")
      LET m_filtro_valor_ate = _ADVPL_create_component(NULL, "LNUMERICFIELD", l_layoutmanager_refence_1,10) #LOG_cria_textfield(l_layoutmanager_refence_1,15)
      CALL _ADVPL_set_property(m_filtro_valor_ate,"VARIABLE",mr_filtro,"valor_ate")
      CALL _ADVPL_set_property(m_filtro_valor_ate,"ENABLE",TRUE)
      CALL _ADVPL_set_property(m_filtro_valor_ate,"LENGTH",8,2)
      CALL _ADVPL_set_property(m_filtro_valor_ate,"PICTURE","@E 9999999.99")
      
      CALL _ADVPL_get_property(m_botao_find,"DO_CLICK")
      CALL _ADVPL_set_property(m_form_filtro,"ACTIVATE",TRUE)
END FUNCTION


#--------------------------------------------------------------------#
  function geo1013_entrada_dados_filtro()
#--------------------------------------------------------------------#
   
   
   
   #CALL _ADVPL_set_property(m_filtro_num_nf,"ENABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_num_nf,"EDITABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_cod_contrato,"ENABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_cod_contrato,"EDITABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_cod_cliente,"ENABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_cod_cliente,"EDITABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_cod_repres,"ENABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_cod_repres,"EDITABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_ser_fabric,"ENABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_ser_fabric,"EDITABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_data_de,"ENABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_data_de,"EDITABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_data_ate,"ENABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_data_ate,"EDITABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_valor_de,"ENABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_valor_de,"EDITABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_valor_ate,"ENABLE",TRUE)
   #CALL _ADVPL_set_property(m_filtro_valor_ate,"EDITABLE",TRUE)
     
 end function
 
#--------------------------------------------------------------------#
  function geo1013_confirmar_filtro()
#--------------------------------------------------------------------#
    define l_sql_stmt  char(5000)
   CALL _ADVPL_set_property(m_form_filtro,"ACTIVATE",FALSE)
   initialize mr_tela.* to null
   initialize ma_tela to null
   
   let l_sql_stmt  = " SELECT num_nf, ",
                     "        cod_contrato, ",
                     "        ser_fabric, ",
                     "        dat_instal, ",
                     "        cod_cliente,",
                     "        '',",
                     "        cod_repres,",
                     "        '',",
                     "        observacao, ",
                     "        ies_suspenso,  ",
                     "        dat_suspensao,  ",
                     "        ies_emite_nf,  ",
                     "        val_loc_mes,  ",
                     "        cod_cnd_pgto, ",
                     "        ''",  
                     "   FROM geo_loc_mestre ",
                     "  WHERE cod_empresa = '",p_cod_empresa,"'",
                     "    AND dat_instal >= '",mr_filtro.data_de,"'",
                     "    AND dat_instal <= '",mr_filtro.data_ate,"'",
                     "    AND val_loc_mes >= ",log0800_replace(mr_filtro.valor_de,",","."),"",
                     "    AND val_loc_mes <= ",log0800_replace(mr_filtro.valor_ate,",","."),""
    
   IF mr_filtro.num_nf <> 0 THEN
      LET l_sql_stmt = l_sql_stmt CLIPPED, " AND num_nf = '",mr_filtro.num_nf,"'" 
   END IF 
   IF mr_filtro.cod_contrato <> 0 THEN
      LET l_sql_stmt = l_sql_stmt CLIPPED, " AND cod_contrato = '",mr_filtro.cod_contrato,"'" 
   END IF 
   IF mr_filtro.ser_fabric IS NOT NULL AND mr_filtro.ser_fabric <> " " THEN
      LET l_sql_stmt = l_sql_stmt CLIPPED, " AND ser_fabric = '",mr_filtro.ser_fabric,"'" 
   END IF 
   IF mr_filtro.cod_cliente IS NOT NULL AND mr_filtro.cod_cliente <> " " THEN
      LET l_sql_stmt = l_sql_stmt CLIPPED, " AND cod_cliente = '",mr_filtro.cod_cliente,"'" 
   END IF 
   IF mr_filtro.cod_repres <> 0 THEN
      LET l_sql_stmt = l_sql_stmt CLIPPED, " AND cod_repres = '",mr_filtro.cod_repres,"'" 
   END IF 
   
   PREPARE var_query FROM l_sql_stmt
   DECLARE cq_consulta SCROLL CURSOR FOR var_query
   OPEN cq_consulta
   FETCH FIRST cq_consulta INTO mr_tela.*
   
   IF sqlca.sqlcode <> 0 THEN
      CALL _ADVPL_message_box("Argumentos de pesquisa não encontrados")
      RETURN FALSE
   END IF 
   
   SELECT nom_cliente
     INTO mr_tela.nom_cliente
     FROM clientes
    WHERE cod_cliente = mr_tela.cod_cliente
   
   SELECT raz_social
     INTO mr_tela.raz_social
     FROM representante
    WHERE cod_repres = mr_tela.cod_repres
    
   SELECT den_cnd_pgto
     INTO mr_tela.den_cnd_pgto
     FROM cond_pgto
    WHERE cod_cnd_pgto = mr_tela.cod_cnd_pgto
    
   CALL geo1013_exibe_itens()
   LET m_ies_onsulta = TRUE
   RETURN TRUE
 end function
 
#----------------------------#
FUNCTION geo1013_exibe_itens()
#----------------------------#
   DEFINE l_ind      SMALLINT
   
   INITIALIZE ma_tela TO NULL
   
   DECLARE cq_exibe_itens CURSOR FOR
   SELECT cod_item
     FROM geo_loc_itens
    WHERE cod_empresa = p_cod_empresa
      AND cod_contrato = mr_tela.cod_contrato
   
   LET l_ind = 1
   FOREACH cq_exibe_itens INTO ma_tela[l_ind].cod_item
      SELECT den_item
        INTO ma_tela[l_ind].den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_tela[l_ind].cod_item 
      LET l_ind = l_ind + 1
   END FOREACH
   LET l_ind = l_ind - 1
   IF l_ind < 1 THEN
      CALL _ADVPL_message_box("Não foi possível localizar os itens desse contrato")
      RETURN FALSE
   END IF 
   
   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",l_ind)
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
   
   RETURN TRUE

END FUNCTION
 
#--------------------------------------------------------------------#
  function geo1013_cancela_filtro()
#--------------------------------------------------------------------#
 
   CALL _ADVPL_set_property(m_form_filtro,"ACTIVATE",FALSE)

 end function
 
#-------------------------------------------#
 function geo1013_zoom_roteiros()
#-------------------------------------------#

   define l_sql_stmt char(4000)

   #
   call ip_zoom_zoom_cadastro_2_colunas('geo_roteiros',
                                'cod_empresa',
                                '2',
                                'cod_roteiro',
                                '30',
                                'Empresa: ',
                                'Roteiro: ',
                                'cod_empresa',
                                'GROUP BY cod_empresa, cod_roteiro  ORDER BY cod_roteiro   ')

   let mr_filtro.cod_roteiro =  ip_zoom_get_valorb()
   #

   

  

 end function
# 

#-------------------------------------#
 FUNCTION geo1013_primeiro()
#-------------------------------------#
    CALL geo1013_paginacao("PRIMEIRO")
 end function

#-------------------------------------#
 FUNCTION geo1013_anterior()
#-------------------------------------#
   CALL geo1013_paginacao("ANTERIOR")
 end function

#-------------------------------------#
 FUNCTION geo1013_seguinte()
#-------------------------------------#
     CALL geo1013_paginacao("SEGUINTE")
 end function

#-------------------------------------#
 FUNCTION geo1013_ultimo()
#-------------------------------------#
    CALL geo1013_paginacao("ULTIMO")
 end function

#
#-------------------------------------#
 FUNCTION geo1013_paginacao(l_funcao)
#-------------------------------------#

   DEFINE l_funcao    CHAR(10),
          l_status    SMALLINT

   LET l_funcao = l_funcao CLIPPED

   let mr_telar.* = mr_tela.*

   IF m_ies_onsulta THEN

      WHILE TRUE
         CASE
            WHEN l_funcao = "SEGUINTE"

                  FETCH NEXT cq_consulta INTO mr_tela.*   

               IF sqlca.sqlcode <> 0 THEN
                  #CALL log003_err_sql ("NEXT","cq_orcamentos")
                  #EXIT WHILE
               END IF

            WHEN l_funcao = "ANTERIOR"

                 FETCH PREVIOUS cq_consulta INTO mr_tela.*

               IF sqlca.sqlcode <> 0 THEN
                  #CALL log003_err_sql ("PREVIOUS","cq_orcamentos")
                  #EXIT WHILE
               END IF

            WHEN l_funcao = "PRIMEIRO"

                  FETCH FIRST cq_consulta INTO mr_tela.*

               IF sqlca.sqlcode <> 0 THEN
                  #CALL log003_err_sql ("FIRST","cq_orcamentos")
                  #EXIT WHILE
               END IF

            WHEN l_funcao = "ULTIMO"

                  FETCH LAST cq_consulta INTO mr_tela.*

            IF sqlca.sqlcode <> 0 THEN
               #CALL log003_err_sql ("LAST","cq_orcamentos")
               #EXIT WHILE
            END IF
         END CASE
         IF sqlca.sqlcode = NOTFOUND THEN
            CALL geo1013_exibe_mensagem_barra_status("Não existem mais itens nesta direcao.","ERRO")
            let mr_tela.* = mr_telar.*
            EXIT WHILE
         ELSE
            LET m_ies_onsulta = TRUE
         END IF

         SELECT num_nf,
                cod_contrato, 
                ser_fabric, 
                dat_instal, 
                cod_cliente,
                '',
                cod_repres,
                '',
                observacao, 
                ies_suspenso,  
                dat_suspensao,  
                ies_emite_nf,  
                val_loc_mes 
          into mr_tela.* 
          from geo_loc_mestre
         where cod_empresa  = p_cod_empresa
           and cod_contrato = mr_tela.cod_contrato  

         IF sqlca.sqlcode = 0 THEN

            EXIT WHILE

         END IF

      END WHILE
   ELSE
      CALL geo1013_exibe_mensagem_barra_status("Efetue primeiramente a consulta.","ERRO")
   END IF


  SELECT nom_cliente
     INTO mr_tela.nom_cliente
     FROM clientes
    WHERE cod_cliente = mr_tela.cod_cliente
   
   SELECT raz_social
     INTO mr_tela.raz_social
     FROM representante
    WHERE cod_repres = mr_tela.cod_repres
   
   SELECT den_cnd_pgto
     INTO mr_tela.den_cnd_pgto
     FROM cond_pgto
    WHERE cod_cnd_pgto = mr_tela.cod_cnd_pgto
   
   CALL geo1013_exibe_itens()

 END FUNCTION
 
 #--------------------------------------------------------------------#
 FUNCTION geo1013_exibe_mensagem_barra_status(l_mensagem,l_tipo_mensagem)
#--------------------------------------------------------------------#

   DEFINE l_mensagem               CHAR(500),
          l_tipo_mensagem          CHAR(010),
          l_tipo_mensagem_original CHAR(015)

   LET l_tipo_mensagem_original = LOG_retorna_tipo_mensagem_original(UPSHIFT(l_tipo_mensagem),TRUE)
   CALL _ADVPL_set_property(m_status_bar,l_tipo_mensagem_original CLIPPED," "||l_mensagem CLIPPED)

 END FUNCTION

 
#--------------------------------------------------------------------#
 function geo1013_exibe_dados()
#--------------------------------------------------------------------#
 
   define l_seq_visita   integer 
   define l_cod_cliente  like clientes.cod_cliente
   define l_nom_cliente  like clientes.nom_cliente
 
   define l_ind          integer
  
   let l_ind = 0 
   
   initialize ma_tela to null
   
   declare cq_roteiros cursor for
   select a.seq_visita, a.cod_cliente, b.nom_cliente
     from geo_roteiros a, clientes b
    where a.cod_empresa = p_cod_empresa
      and a.cod_roteiro = mr_tela.cod_roteiro
      and b.cod_cliente = a.cod_cliente
      
   foreach cq_roteiros into l_seq_visita
                          , l_cod_cliente
                          , l_nom_cliente
      let l_ind = l_ind + 1
      let ma_tela[l_ind].seq_visita    = l_seq_visita
      let ma_tela[l_ind].cod_cliente   = l_cod_cliente
      let ma_tela[l_ind].nom_cliente   = l_nom_cliente 
         
   end foreach 

   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",l_ind)              
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")                       

 end function
 

#--------------------------------------------------------------------#
 function geo1013_valid_cod_cliente()
#--------------------------------------------------------------------#
   
   select nom_cliente
   into mr_tela.nom_cliente
    from clientes
   where cod_cliente = mr_tela.cod_cliente
 
   IF sqlca.sqlcode = 100 THEN
      CALL _ADVPL_message_box("Cliente não encontrado.")
      RETURN FALSE
   END IF
  #
 return true 
 
 end function 
 #--------------------------------------------------------------------#
 function geo1013_valid_cod_repres()
#--------------------------------------------------------------------#
   
   select raz_social
   into mr_tela.raz_social
    from representante
   where cod_repres = mr_tela.cod_repres
 
   IF sqlca.sqlcode = 100 THEN
      CALL _ADVPL_message_box("Vendedor não encontrado.")
      RETURN FALSE
   END IF
  #
 return true 
 
 end function 
 
 #--------------------------------------------------------------------#
 function geo1013_valid_cod_item()
#--------------------------------------------------------------------#
   define l_selecao integer 
   
   LET l_selecao = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   
   if l_selecao < 1 then
     return true 
   end if 
   
   select den_item
   into ma_tela[l_selecao].den_item
    from item
   where cod_item = ma_tela[l_selecao].cod_item
 
   IF sqlca.sqlcode = 100 AND ma_tela[l_selecao].cod_item IS NOT NULL AND ma_tela[l_selecao].cod_item <> " " THEN
      CALL _ADVPL_message_box("Item não encontrado.")
      RETURN FALSE
   END IF
  #
 return true 
 
 end function 
 
 #--------------------------------#
 FUNCTION geo1013_check_suspenso()
 #--------------------------------#
    
    IF mr_tela.ies_suspenso = "S" THEN
       LET mr_tela.dat_suspensao = TODAY
    ELSE 
    	INITIALIZE mr_tela.dat_suspensao TO NULL
    END IF 
    
 END FUNCTION
 
 #-----------------------------------#
 FUNCTION geo1013_valid_val_loc_mes()
 #-----------------------------------#
    if mr_tela.val_loc_mes IS NOT NULL AND mr_tela.val_loc_mes <> 0 THEN
       if mr_tela.val_loc_mes = 0 THEN
          CALL _ADVPL_message_box("Valor não pode ser zero.")
          RETURN FALSE
       END IF 
    ELSE
       CALL _ADVPL_message_box("Valor deve ser preenchido.")
       RETURN FALSE
    END IF 
 END FUNCTION

#--------------------------------#
FUNCTION geo1013_form_faturar()
#--------------------------------#

CALL geo1013_tela_filtros('FATURAR')

CALL LOG_progress_start("Processa","geo1013_tela_faturar","PROCESS")

END FUNCTION

#--------------------------------#
FUNCTION geo1013_form_relat()
#--------------------------------#

CALL geo1013_tela_filtros('RELAT')

CALL LOG_progress_start("Processa","geo1013_tela_relat","PROCESS")
#CALL LOG_progress_start("Processa","geo1013_processa_relat","PROCESS")

END FUNCTION
  
#------------------------------#
FUNCTION geo1013_tela_faturar()
#------------------------------#
   DEFINE l_form    VARCHAR(10)
   
   DEFINE l_panel_filtro,
         l_toolbar            VARCHAR(10)

  DEFINE l_panel_reference,
         l_panel_reference_1,
         l_panel_reference_2,
         l_panel_reference_0,
         l_table_reference,
         l_checkbox,
         l_num_nf,
         l_cod_contrato,
         l_cod_cliente,
         l_nom_cliente,
         l_cod_repres,
         l_ser_fabric,
         l_dat_instal,
         l_val_loc_mes,
         l_data_de,
         l_data_ate,
         l_observacao        VARCHAR(10)

  DEFINE l_layoutmanager_refence_1,
         l_layoutmanager_refence_2 VARCHAR(10)

  define l_layoutmanager_filtro varchar(10)
  define l_layoutmanager_array varchar(10)
  define l_column_reference         varchar(10)

  DEFINE l_status SMALLINT

  DEFINE l_splitter_reference VARCHAR(10)

      #cria janela principal do tipo LDIALOG
      LET m_form_filtro = _ADVPL_create_component(NULL,"LDIALOG")
      CALL _ADVPL_set_property(m_form_filtro,"TITLE","FATURAMENTO")
      CALL _ADVPL_set_property(m_form_filtro,"ENABLE_ESC_CLOSE",FALSE)
      CALL _ADVPL_set_property(m_form_filtro,"SIZE",1000,500) 

      #cria menu
      LET l_toolbar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_filtro)

      #botao informar
      LET m_botao_find = _ADVPL_create_component(NULL,"LInformButton",l_toolbar)
      CALL _ADVPL_set_property(m_botao_find,"EVENT","geo1013_entrada_dados_filtro")
      CALL _ADVPL_set_property(m_botao_find,"CONFIRM_EVENT","geo1013_faturar")
      CALL _ADVPL_set_property(m_botao_find,"CANCEL_EVENT","geo1013_cancela_filtro")
 
      #cria splitter
      LET l_splitter_reference = _ADVPL_create_component(NULL,"LSPLITTER",m_form_filtro)
      CALL _ADVPL_set_property(l_splitter_reference,"ALIGN","CENTER")
      CALL _ADVPL_set_property(l_splitter_reference,"ORIENTATION","HORIZONTAL")

      #cria panel para campos de filtro
      LET l_panel_reference_0 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_splitter_reference)
      CALL _ADVPL_set_property(l_panel_reference_0,"TITLE","INFORMAR FILTROS DA PESQUISA")
 
      LET l_panel_reference_1 = _ADVPL_create_component(NULL,"LPANEL",l_panel_reference_0)
      CALL _ADVPL_set_property(l_panel_reference_1,"ALIGN","CENTER")
      CALL _ADVPL_set_property(l_panel_reference_1,"HEIGHT",10)
      
      LET l_panel_reference_2 = _ADVPL_create_component(NULL,"LPANEL",l_panel_reference_0)
      CALL _ADVPL_set_property(l_panel_reference_2,"ALIGN","BOTTOM")
      CALL _ADVPL_set_property(l_panel_reference_2,"HEIGHT",10)
      
      LET l_layoutmanager_refence_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference_1)
      CALL _ADVPL_set_property(l_layoutmanager_refence_1,"MARGIN",TRUE)
      CALL _ADVPL_set_property(l_layoutmanager_refence_1,"COLUMNS_COUNT",4)
 
      LET l_layoutmanager_refence_2 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference_2)
      CALL _ADVPL_set_property(l_layoutmanager_refence_2,"MARGIN",TRUE)
      CALL _ADVPL_set_property(l_layoutmanager_refence_2,"COLUMNS_COUNT",4)

      LET m_table_reference3 = _ADVPL_create_component(NULL,"LBROWSEEX",l_layoutmanager_refence_1)
      CALL _ADVPL_set_property(m_table_reference3,"SIZE",980,500)
      CALL _ADVPL_set_property(m_table_reference3,"CAN_ADD_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference3,"CAN_REMOVE_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference3,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_table_reference3,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_table_reference3,"ENABLE",TRUE)
	  CALL _ADVPL_set_property(m_table_reference3,"POSITION",10,10)

      #CALL _ADVPL_set_property(m_table_etapa,"BEFORE_REMOVE_ROW_EVENT","man10217_before_remove_row_event_table_etapa")
      #CALL _ADVPL_set_property(m_table_reference3,"BEFORE_EDIT_EVENT","")
      
      
      #cria campo do array: cod_cliente
      LET l_checkbox = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(l_checkbox,"VARIABLE","checkbox")
      CALL _ADVPL_set_property(l_checkbox,"HEADER"," ")
      CALL _ADVPL_set_property(l_checkbox,"COLUMN_SIZE", 10)
      CALL _ADVPL_set_property(l_checkbox,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_checkbox,"EDIT_COMPONENT","LCHECKBOX")
      CALL _ADVPL_set_property(l_checkbox,"EDIT_PROPERTY","VALUE_CHECKED","S")
      CALL _ADVPL_set_property(l_checkbox,"EDIT_PROPERTY","VALUE_NCHECKED","N")
      CALL _ADVPL_set_property(l_checkbox,"IMAGE_HEADER","CHECKED")
      CALL _ADVPL_set_property(l_checkbox,"EDIT_PROPERTY","CHANGE_EVENT","geo1013_verifica_checkbox")
      CALL _ADVPL_set_property(l_checkbox,"HEADER_CLICK_EVENT","geo1013_seleciona_todos1")
      #CALL _ADVPL_set_property(l_checkbox,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(l_checkbox,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_checkbox,"EDITABLE", TRUE)
      
      #cria campo do array: cod_cliente
      LET l_num_nf = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(l_num_nf,"VARIABLE","num_nf")
      CALL _ADVPL_set_property(l_num_nf,"HEADER","Remessa")
      CALL _ADVPL_set_property(l_num_nf,"COLUMN_SIZE", 30)
      CALL _ADVPL_set_property(l_num_nf,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_num_nf,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(l_num_nf,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(l_num_nf,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_num_nf,"EDITABLE", FALSE)
      
       #cria campo do array: cod_cliente
      LET l_cod_contrato = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(l_cod_contrato,"VARIABLE","cod_contrato")
      CALL _ADVPL_set_property(l_cod_contrato,"HEADER","Contrato")
      CALL _ADVPL_set_property(l_cod_contrato,"COLUMN_SIZE", 30)
      CALL _ADVPL_set_property(l_cod_contrato,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_cod_contrato,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(l_cod_contrato,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(l_cod_contrato,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_cod_contrato,"EDITABLE", FALSE)
      
        #cria campo do array: cod_cliente
      LET l_cod_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(l_cod_cliente,"VARIABLE","cod_cliente")
      CALL _ADVPL_set_property(l_cod_cliente,"HEADER","Cliente")
      CALL _ADVPL_set_property(l_cod_cliente,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(l_cod_cliente,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_cod_cliente,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(l_cod_cliente,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(l_cod_cliente,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_cod_cliente,"EDITABLE", FALSE)
      
        #cria campo do array: cod_cliente
       #cria campo do array: cod_cliente
      LET l_nom_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(l_nom_cliente,"VARIABLE","nom_cliente")
      CALL _ADVPL_set_property(l_nom_cliente,"HEADER","Cliente")
      CALL _ADVPL_set_property(l_nom_cliente,"COLUMN_SIZE", 120)
      CALL _ADVPL_set_property(l_nom_cliente,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_nom_cliente,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(l_nom_cliente,"EDIT_PROPERTY","LENGTH",36) 
      #CALL _ADVPL_set_property(l_nom_cliente,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_nom_cliente,"EDITABLE", FALSE)
      
        #cria campo do array: cod_cliente
      LET l_cod_repres = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(l_cod_repres,"VARIABLE","cod_repres")
      CALL _ADVPL_set_property(l_cod_repres,"HEADER","Vendedor")
      CALL _ADVPL_set_property(l_cod_repres,"COLUMN_SIZE", 30)
      CALL _ADVPL_set_property(l_cod_repres,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_cod_repres,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(l_cod_repres,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(l_cod_repres,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_cod_repres,"EDITABLE", FALSE)
      
       #cria campo do array: cod_cliente
      LET l_ser_fabric = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(l_ser_fabric,"VARIABLE","ser_fabric")
      CALL _ADVPL_set_property(l_ser_fabric,"HEADER","Serie")
      CALL _ADVPL_set_property(l_ser_fabric,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(l_ser_fabric,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_ser_fabric,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(l_ser_fabric,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(l_ser_fabric,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_ser_fabric,"EDITABLE", FALSE)
      
       #cria campo do array: cod_cliente
      LET l_dat_instal = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(l_dat_instal,"VARIABLE","dat_instal")
      CALL _ADVPL_set_property(l_dat_instal,"HEADER","Instalação")
      CALL _ADVPL_set_property(l_dat_instal,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(l_dat_instal,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_dat_instal,"EDIT_COMPONENT","LDATEFIELD")
      #CALL _ADVPL_set_property(l_dat_instal,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(l_dat_instal,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_dat_instal,"EDITABLE", FALSE)
      
       #cria campo do array: cod_cliente
      LET l_val_loc_mes = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(l_val_loc_mes,"VARIABLE","val_loc_mes")
      CALL _ADVPL_set_property(l_val_loc_mes,"HEADER","Valor")
      CALL _ADVPL_set_property(l_val_loc_mes,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(l_val_loc_mes,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_val_loc_mes,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(l_val_loc_mes,"EDIT_PROPERTY","LENGTH",15,2) 
      #CALL _ADVPL_set_property(l_val_loc_mes,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_val_loc_mes,"EDITABLE", FALSE)
      
       #cria campo do array: cod_cliente
      LET l_data_de = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(l_data_de,"VARIABLE","periodo_de")
      CALL _ADVPL_set_property(l_data_de,"HEADER","De")
      CALL _ADVPL_set_property(l_data_de,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(l_data_de,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_data_de,"EDIT_COMPONENT","LDATEFIELD")
      CALL _ADVPL_set_property(l_data_de,"EDITABLE", FALSE)
      
       #cria campo do array: cod_cliente
      LET l_data_ate = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(l_data_ate,"VARIABLE","periodo_ate")
      CALL _ADVPL_set_property(l_data_ate,"HEADER","Até")
      CALL _ADVPL_set_property(l_data_ate,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(l_data_ate,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_data_ate,"EDIT_COMPONENT","LDATEFIELD")
      CALL _ADVPL_set_property(l_data_ate,"EDITABLE", FALSE)
      
       
      
           # let ma_pedidos[1].num_pedido = '123'
      CALL _ADVPL_set_property(m_table_reference3,"SET_ROWS",ma_faturar,1)
      CALL _ADVPL_set_property(m_table_reference3,"ITEM_COUNT",1)
      CALL _ADVPL_set_property(m_table_reference3,"REFRESH")
 
      CALL geo1013_carrega_array_faturar()
      
      CALL _ADVPL_get_property(m_botao_find,"DO_CLICK")
      CALL _ADVPL_set_property(m_form_filtro,"ACTIVATE",TRUE)
END FUNCTION

#------------------------------#
FUNCTION geo1013_tela_relat()
#------------------------------#
   DEFINE l_form    VARCHAR(10)
   
   DEFINE l_panel_filtro,
         l_toolbar            VARCHAR(10)

  DEFINE l_panel_reference,
         l_panel_reference_1,
         l_panel_reference_2,
         l_panel_reference_0,
         l_table_reference,
         l_checkbox,
         l_num_nf,
         l_cod_contrato,
         l_cod_cliente,
         l_nom_cliente,
         l_cod_repres,
         l_ser_fabric,
         l_dat_instal,
         l_val_loc_mes,
         l_data_de,
         l_data_ate,
         l_observacao        VARCHAR(10)

  DEFINE l_layoutmanager_refence_1,
         l_layoutmanager_refence_2 VARCHAR(10)

  define l_layoutmanager_filtro varchar(10)
  define l_layoutmanager_array varchar(10)
  define l_column_reference         varchar(10)

  DEFINE l_status SMALLINT

  DEFINE l_splitter_reference VARCHAR(10)

      #cria janela principal do tipo LDIALOG
      LET m_form_filtro = _ADVPL_create_component(NULL,"LDIALOG")
      CALL _ADVPL_set_property(m_form_filtro,"TITLE","RELATORIO")
      CALL _ADVPL_set_property(m_form_filtro,"ENABLE_ESC_CLOSE",FALSE)
      CALL _ADVPL_set_property(m_form_filtro,"SIZE",1000,500) 

      #cria menu
      LET l_toolbar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_filtro)

      #botao informar
      LET m_botao_find = _ADVPL_create_component(NULL,"LInformButton",l_toolbar)
      CALL _ADVPL_set_property(m_botao_find,"EVENT","geo1013_entrada_dados_filtro")
      CALL _ADVPL_set_property(m_botao_find,"CONFIRM_EVENT","geo1013_processa_relat")
      CALL _ADVPL_set_property(m_botao_find,"CANCEL_EVENT","geo1013_cancela_filtro")
 
      #cria splitter
      LET l_splitter_reference = _ADVPL_create_component(NULL,"LSPLITTER",m_form_filtro)
      CALL _ADVPL_set_property(l_splitter_reference,"ALIGN","CENTER")
      CALL _ADVPL_set_property(l_splitter_reference,"ORIENTATION","HORIZONTAL")

      #cria panel para campos de filtro
      LET l_panel_reference_0 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_splitter_reference)
      CALL _ADVPL_set_property(l_panel_reference_0,"TITLE","INFORMAR FILTROS DA PESQUISA")
 
      LET l_panel_reference_1 = _ADVPL_create_component(NULL,"LPANEL",l_panel_reference_0)
      CALL _ADVPL_set_property(l_panel_reference_1,"ALIGN","CENTER")
      CALL _ADVPL_set_property(l_panel_reference_1,"HEIGHT",10)
      
      LET l_panel_reference_2 = _ADVPL_create_component(NULL,"LPANEL",l_panel_reference_0)
      CALL _ADVPL_set_property(l_panel_reference_2,"ALIGN","BOTTOM")
      CALL _ADVPL_set_property(l_panel_reference_2,"HEIGHT",10)
      
      LET l_layoutmanager_refence_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference_1)
      CALL _ADVPL_set_property(l_layoutmanager_refence_1,"MARGIN",TRUE)
      CALL _ADVPL_set_property(l_layoutmanager_refence_1,"COLUMNS_COUNT",4)
 
      LET l_layoutmanager_refence_2 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference_2)
      CALL _ADVPL_set_property(l_layoutmanager_refence_2,"MARGIN",TRUE)
      CALL _ADVPL_set_property(l_layoutmanager_refence_2,"COLUMNS_COUNT",4)

      LET m_table_reference4 = _ADVPL_create_component(NULL,"LBROWSEEX",l_layoutmanager_refence_1)
      CALL _ADVPL_set_property(m_table_reference4,"SIZE",980,500)
      CALL _ADVPL_set_property(m_table_reference4,"CAN_ADD_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference4,"CAN_REMOVE_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference4,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_table_reference4,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_table_reference4,"ENABLE",TRUE)
	  CALL _ADVPL_set_property(m_table_reference4,"POSITION",10,10)

      #CALL _ADVPL_set_property(m_table_etapa,"BEFORE_REMOVE_ROW_EVENT","man10217_before_remove_row_event_table_etapa")
      #CALL _ADVPL_set_property(m_table_reference4,"BEFORE_EDIT_EVENT","")
      
      
      #cria campo do array: cod_cliente
      LET l_checkbox = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(l_checkbox,"VARIABLE","checkbox")
      CALL _ADVPL_set_property(l_checkbox,"HEADER"," ")
      CALL _ADVPL_set_property(l_checkbox,"COLUMN_SIZE", 10)
      CALL _ADVPL_set_property(l_checkbox,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_checkbox,"EDIT_COMPONENT","LCHECKBOX")
      CALL _ADVPL_set_property(l_checkbox,"EDIT_PROPERTY","VALUE_CHECKED","S")
      CALL _ADVPL_set_property(l_checkbox,"EDIT_PROPERTY","VALUE_NCHECKED","N")
      CALL _ADVPL_set_property(l_checkbox,"IMAGE_HEADER","CHECKED")
      CALL _ADVPL_set_property(l_checkbox,"HEADER_CLICK_EVENT","geo1013_seleciona_todos2")
      CALL _ADVPL_set_property(l_checkbox,"EDITABLE", TRUE)
      
      #cria campo do array: cod_cliente
      LET l_num_nf = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(l_num_nf,"VARIABLE","num_nf")
      CALL _ADVPL_set_property(l_num_nf,"HEADER","Remessa")
      CALL _ADVPL_set_property(l_num_nf,"COLUMN_SIZE", 30)
      CALL _ADVPL_set_property(l_num_nf,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_num_nf,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(l_num_nf,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(l_num_nf,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_num_nf,"EDITABLE", FALSE)
      
       #cria campo do array: cod_cliente
      LET l_cod_contrato = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(l_cod_contrato,"VARIABLE","cod_contrato")
      CALL _ADVPL_set_property(l_cod_contrato,"HEADER","Contrato")
      CALL _ADVPL_set_property(l_cod_contrato,"COLUMN_SIZE", 30)
      CALL _ADVPL_set_property(l_cod_contrato,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_cod_contrato,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(l_cod_contrato,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(l_cod_contrato,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_cod_contrato,"EDITABLE", FALSE)
      
        #cria campo do array: cod_cliente
      LET l_cod_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(l_cod_cliente,"VARIABLE","cod_cliente")
      CALL _ADVPL_set_property(l_cod_cliente,"HEADER","Cliente")
      CALL _ADVPL_set_property(l_cod_cliente,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(l_cod_cliente,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_cod_cliente,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(l_cod_cliente,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(l_cod_cliente,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_cod_cliente,"EDITABLE", FALSE)
      
       #cria campo do array: cod_cliente
      LET l_nom_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(l_nom_cliente,"VARIABLE","nom_cliente")
      CALL _ADVPL_set_property(l_nom_cliente,"HEADER","Cliente")
      CALL _ADVPL_set_property(l_nom_cliente,"COLUMN_SIZE", 120)
      CALL _ADVPL_set_property(l_nom_cliente,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_nom_cliente,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(l_nom_cliente,"EDIT_PROPERTY","LENGTH",36) 
      #CALL _ADVPL_set_property(l_nom_cliente,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_nom_cliente,"EDITABLE", FALSE)
      
        #cria campo do array: cod_cliente
      LET l_cod_repres = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(l_cod_repres,"VARIABLE","cod_repres")
      CALL _ADVPL_set_property(l_cod_repres,"HEADER","Vendedor")
      CALL _ADVPL_set_property(l_cod_repres,"COLUMN_SIZE", 30)
      CALL _ADVPL_set_property(l_cod_repres,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_cod_repres,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(l_cod_repres,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(l_cod_repres,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_cod_repres,"EDITABLE", FALSE)
      
       #cria campo do array: cod_cliente
      LET l_ser_fabric = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(l_ser_fabric,"VARIABLE","ser_fabric")
      CALL _ADVPL_set_property(l_ser_fabric,"HEADER","Serie")
      CALL _ADVPL_set_property(l_ser_fabric,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(l_ser_fabric,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_ser_fabric,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(l_ser_fabric,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(l_ser_fabric,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_ser_fabric,"EDITABLE", FALSE)
      
       #cria campo do array: cod_cliente
      LET l_dat_instal = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(l_dat_instal,"VARIABLE","dat_instal")
      CALL _ADVPL_set_property(l_dat_instal,"HEADER","Instalação")
      CALL _ADVPL_set_property(l_dat_instal,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(l_dat_instal,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_dat_instal,"EDIT_COMPONENT","LDATEFIELD")
      #CALL _ADVPL_set_property(l_dat_instal,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(l_dat_instal,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_dat_instal,"EDITABLE", FALSE)
      
       #cria campo do array: cod_cliente
      LET l_val_loc_mes = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(l_val_loc_mes,"VARIABLE","val_loc_mes")
      CALL _ADVPL_set_property(l_val_loc_mes,"HEADER","Valor")
      CALL _ADVPL_set_property(l_val_loc_mes,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(l_val_loc_mes,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_val_loc_mes,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(l_val_loc_mes,"EDIT_PROPERTY","LENGTH",15,2) 
      #CALL _ADVPL_set_property(l_val_loc_mes,"EDIT_PROPERTY","VALID","geo1013_valid_cod_item")
      CALL _ADVPL_set_property(l_val_loc_mes,"EDITABLE", FALSE)
      
      #cria campo do array: cod_cliente
      LET l_data_de = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(l_data_de,"VARIABLE","periodo_de")
      CALL _ADVPL_set_property(l_data_de,"HEADER","De")
      CALL _ADVPL_set_property(l_data_de,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(l_data_de,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_data_de,"EDIT_COMPONENT","LDATEFIELD")
      CALL _ADVPL_set_property(l_data_de,"EDITABLE", FALSE)
      
       #cria campo do array: cod_cliente
      LET l_data_ate = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(l_data_ate,"VARIABLE","periodo_ate")
      CALL _ADVPL_set_property(l_data_ate,"HEADER","Até")
      CALL _ADVPL_set_property(l_data_ate,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(l_data_ate,"ORDER",TRUE)
      CALL _ADVPL_set_property(l_data_ate,"EDIT_COMPONENT","LDATEFIELD")
      CALL _ADVPL_set_property(l_data_ate,"EDITABLE", FALSE)
      
       
           # let ma_pedidos[1].num_pedido = '123'
      CALL _ADVPL_set_property(m_table_reference4,"SET_ROWS",ma_relat,1)
      CALL _ADVPL_set_property(m_table_reference4,"ITEM_COUNT",1)
      CALL _ADVPL_set_property(m_table_reference4,"REFRESH")
 
      CALL geo1013_carrega_array_relat()
      
      CALL _ADVPL_get_property(m_botao_find,"DO_CLICK")
      CALL _ADVPL_set_property(m_form_filtro,"ACTIVATE",TRUE)
END FUNCTION

#----------------------------------------#
FUNCTION geo1013_carrega_array_faturar()
#----------------------------------------#
   DEFINE l_ind       SMALLINT
   DEFINE l_data      CHAR(10)
   DEFINE l_dia       CHAR(02)
   DEFINE l_cont      INTEGER
   DEFINE lr_mestre    RECORD
			    cod_empresa char(2),
				cod_contrato integer,
				num_nf integer,
				dat_instal date,
				ser_fabric char(15),
				cod_cliente char(15),
				cod_repres decimal(4),
				observacao char(999),
				ies_suspenso char(1),
				dat_suspensao date,
				ies_emite_nf char(1),
				val_loc_mes decimal(20,2),
				cod_cnd_pgto decimal(3,0)
          END RECORD
   INITIALIZE ma_faturar TO NULL
   DECLARE cq_array_faturar CURSOR WITH HOLD FOR
    SELECT *
      FROM geo_loc_mestre
     WHERE cod_empresa = p_cod_empresa
       AND ies_suspenso = 'N'
       AND ies_emite_nf = 'S'
    
    LET l_ind = 1
    FOREACH cq_array_faturar INTO lr_mestre.*
       LET ma_faturar[l_ind].val_loc_mes = lr_mestre.val_loc_mes  
       
       LET l_data = "01/",EXTEND(TODAY, MONTH TO MONTH),"/",EXTEND(TODAY, YEAR TO YEAR);
       LET ma_faturar[l_ind].periodo_de = l_data
       LET ma_faturar[l_ind].periodo_ate = rhu999_last_day_month(TODAY)
          
       IF EXTEND(lr_mestre.dat_instal, YEAR TO MONTH) = EXTEND(ma_faturar[l_ind].periodo_de, YEAR TO MONTH) THEN
          LET l_dia = EXTEND(lr_mestre.dat_instal, DAY TO DAY)
          LET l_cont = l_dia
          IF l_cont > 1 THEN
             LET ma_faturar[l_ind].periodo_de = lr_mestre.dat_instal
             LET ma_faturar[l_ind].val_loc_mes = (lr_mestre.val_loc_mes / 30) * (30 - l_cont)
          END IF 
       END IF 
        
       SELECT DISTINCT periodo_de, periodo_ate
         INTO ma_faturar[l_ind].periodo_de, ma_faturar[l_ind].periodo_ate
         FROM geo_loc_faturado
        WHERE cod_empresa = p_cod_empresa
          AND cod_contrato = lr_mestre.cod_contrato
          AND num_nf = lr_mestre.num_nf
          AND cod_cliente = lr_mestre.cod_cliente
          AND cod_repres = lr_mestre.cod_repres
          AND periodo_de = ma_faturar[l_ind].periodo_de
          AND periodo_ate = ma_faturar[l_ind].periodo_ate
          AND num_pedido IN (SELECT DISTINCT a.pedido
                           FROM fat_nf_item a, fat_nf_mestre b
                          WHERE a.empresa = b.empresa
                            AND a.empresa = geo_loc_faturado.cod_empresa
                            AND a.trans_nota_fiscal = b.trans_nota_fiscal
                            AND b.sit_nota_fiscal = 'N'
                            AND b.serie_nota_fiscal = 'LC')
                            
       IF sqlca.sqlcode = 0 THEN
          LET ma_faturar[l_ind].checkbox = "N"
          CALL _ADVPL_set_property(m_table_reference3,"LINE_COLOR",l_ind,200,200,200)
       ELSE
          LET ma_faturar[l_ind].checkbox = "S"
          CALL _ADVPL_set_property(m_table_reference3,"CLEAR_LINE_COLOR",l_ind)
       END IF 
       
       LET ma_faturar[l_ind].num_nf = lr_mestre.num_nf
       LET ma_faturar[l_ind].cod_contrato = lr_mestre.cod_contrato   
       LET ma_faturar[l_ind].cod_cliente = lr_mestre.cod_cliente   
       LET ma_faturar[l_ind].cod_repres = lr_mestre.cod_repres    
       LET ma_faturar[l_ind].ser_fabric = lr_mestre.ser_fabric    
       LET ma_faturar[l_ind].dat_instal = lr_mestre.dat_instal    
       
       SELECT nom_cliente
         INTO ma_faturar[l_ind].nom_cliente
         FROM clientes
        WHERE cod_cliente = lr_mestre.cod_cliente   
       
       LET l_ind = l_ind + 1
    END FOREACH
    LET l_ind = l_ind - 1
    
    CALL _ADVPL_set_property(m_table_reference3,"ITEM_COUNT",l_ind)
    CALL _ADVPL_set_property(m_table_reference3,"REFRESH")
    
END FUNCTION
   
#----------------------------------------#
FUNCTION geo1013_carrega_array_relat()
#----------------------------------------#
   DEFINE l_ind       SMALLINT
   DEFINE l_sql_stmt char(50000)
   DEFINE lr_mestre    RECORD
			    cod_empresa char(2),
				cod_contrato integer,
				num_nf integer,
				dat_instal date,
				ser_fabric char(15),
				cod_cliente char(15),
				cod_repres decimal(4),
				observacao char(999),
				ies_suspenso char(1),
				dat_suspensao date,
				ies_emite_nf char(1),
				val_loc_mes decimal(20,2),
				cod_cnd_pgto decimal(3,0),
				periodo_de date,
				periodo_ate date,
				valor decimal(20,2)
          END RECORD
   INITIALIZE ma_relat TO NULL
   
   
   
   
   let l_sql_stmt  = 
   
   
   " SELECT a.*, b.periodo_de, b.periodo_ate, b.valor                          ",
   "    FROM geo_loc_mestre a, geo_loc_faturado b                              ",
   "   WHERE a.cod_empresa = '",p_cod_empresa,"'",
   "     AND a.cod_empresa = b.cod_empresa                                     ",
   "     AND a.cod_contrato = b.cod_contrato                                   ",
   "     AND a.cod_cliente = b.cod_cliente                                     ",
   "     AND a.cod_repres = b.cod_repres                                       ",
   "     AND a.ies_suspenso = 'N'                                              ",
   "     AND a.ies_emite_nf = 'S'                                              ",
   "     AND b.num_pedido IN (SELECT DISTINCT d.pedido                         ",
   "                            FROM fat_nf_mestre c, fat_nf_item d            ",
   "                           WHERE c.empresa = d.empresa                     ",
   "                             AND c.trans_nota_fiscal = d.trans_nota_fiscal ",
   "                             AND c.empresa = a.cod_empresa                 ",
   "                             AND c.sit_nota_fiscal = 'N'                   ",
   "                             AND c.serie_nota_fiscal = 'LC')               ", 
   "    AND dat_instal >= '",mr_filtro.data_de,"'",
   "    AND dat_instal <= '",mr_filtro.data_ate,"'",
   "    AND val_loc_mes >= ",log0800_replace(mr_filtro.valor_de,",","."),"",
   "    AND val_loc_mes <= ",log0800_replace(mr_filtro.valor_ate,",","."),"",
   "  ORDER BY b.data_process DESC                                             "
    
   IF mr_filtro.num_nf <> 0 THEN
      LET l_sql_stmt = l_sql_stmt CLIPPED, " AND num_nf = '",mr_filtro.num_nf,"'" 
   END IF 
   IF mr_filtro.cod_contrato <> 0 THEN
      LET l_sql_stmt = l_sql_stmt CLIPPED, " AND cod_contrato = '",mr_filtro.cod_contrato,"'" 
   END IF 
   IF mr_filtro.ser_fabric IS NOT NULL AND mr_filtro.ser_fabric <> " " THEN
      LET l_sql_stmt = l_sql_stmt CLIPPED, " AND ser_fabric = '",mr_filtro.ser_fabric,"'" 
   END IF 
   IF mr_filtro.cod_cliente IS NOT NULL AND mr_filtro.cod_cliente <> " " THEN
      LET l_sql_stmt = l_sql_stmt CLIPPED, " AND cod_cliente = '",mr_filtro.cod_cliente,"'" 
   END IF 
   IF mr_filtro.cod_repres <> 0 THEN
      LET l_sql_stmt = l_sql_stmt CLIPPED, " AND cod_repres = '",mr_filtro.cod_repres,"'" 
   END IF 
   
   
       LET l_sql_stmt = l_sql_stmt CLIPPED, "  ORDER BY b.data_process DESC                                             " 
   
   PREPARE var_query FROM l_sql_stmt
   DECLARE cq_array_relat SCROLL CURSOR FOR var_query
   OPEN cq_array_relat
   #FETCH FIRST cq_consulta INTO mr_tela.*
   
   
   
   
  # DECLARE cq_array_relat CURSOR WITH HOLD FOR
  #  SELECT a.*, b.periodo_de, b.periodo_ate, b.valor
  #    FROM geo_loc_mestre a, geo_loc_faturado b 
  #   WHERE a.cod_empresa = p_cod_empresa
  #     AND a.cod_empresa = b.cod_empresa
  #     AND a.cod_contrato = b.cod_contrato
  #     AND a.cod_cliente = b.cod_cliente
  #     AND a.cod_repres = b.cod_repres
  #     AND a.ies_suspenso = 'N'
  #     AND a.ies_emite_nf = 'S'
  #     AND b.num_pedido IN (SELECT DISTINCT d.pedido
  #                            FROM fat_nf_mestre c, fat_nf_item d
  #                           WHERE c.empresa = d.empresa
  #                             AND c.trans_nota_fiscal = d.trans_nota_fiscal
  #                             AND c.empresa = a.cod_empresa
  #                             AND c.sit_nota_fiscal = 'N'
  #                             AND c.serie_nota_fiscal = 'LC')
  #  ORDER BY b.data_process DESC
  #     
       
    LET l_ind = 1
    FOREACH cq_array_relat INTO lr_mestre.*
       
       LET ma_relat[l_ind].checkbox = "N"
       
       LET ma_relat[l_ind].num_nf = lr_mestre.num_nf
       LET ma_relat[l_ind].cod_contrato = lr_mestre.cod_contrato   
       LET ma_relat[l_ind].cod_cliente = lr_mestre.cod_cliente   
       LET ma_relat[l_ind].cod_repres = lr_mestre.cod_repres    
       LET ma_relat[l_ind].ser_fabric = lr_mestre.ser_fabric    
       LET ma_relat[l_ind].dat_instal = lr_mestre.dat_instal    
       LET ma_relat[l_ind].val_loc_mes = lr_mestre.valor   
       LET ma_relat[l_ind].periodo_de = lr_mestre.periodo_de    
       LET ma_relat[l_ind].periodo_ate = lr_mestre.periodo_ate    
       
       SELECT nom_cliente
         INTO ma_relat[l_ind].nom_cliente
         FROM clientes
        WHERE cod_cliente = ma_relat[l_ind].cod_cliente
       LET l_ind = l_ind + 1
    END FOREACH
    LET l_ind = l_ind - 1
    
    CALL _ADVPL_set_property(m_table_reference4,"ITEM_COUNT",l_ind)
    CALL _ADVPL_set_property(m_table_reference4,"REFRESH")
    
END FUNCTION
   
#-----------------------------------#
FUNCTION geo1013_verifica_checkbox()
#-----------------------------------#
   DEFINE l_arr_curr     SMALLINT
   DEFINE l_data CHAR(10)
   DEFINE l_dia CHAR(2)
   DEFINE l_cont SMALLINT
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference3,"ITEM_SELECTED")
   
   LET l_data = "01/",EXTEND(TODAY, MONTH TO MONTH),"/",EXTEND(TODAY, YEAR TO YEAR);
   LET ma_faturar[l_arr_curr].periodo_de = l_data
   LET ma_faturar[l_arr_curr].periodo_ate = rhu999_last_day_month(TODAY)
       
   IF EXTEND(ma_faturar[l_arr_curr].dat_instal, YEAR TO MONTH) = EXTEND(ma_faturar[l_arr_curr].periodo_de, YEAR TO MONTH) THEN
      LET l_dia = EXTEND(ma_faturar[l_arr_curr].dat_instal, DAY TO DAY)
      LET l_cont = l_dia
      IF l_cont > 1 THEN
         LET ma_faturar[l_arr_curr].periodo_de = ma_faturar[l_arr_curr].dat_instal
         LET ma_faturar[l_arr_curr].val_loc_mes = (ma_faturar[l_arr_curr].val_loc_mes / 30) * (30 - l_cont)
      END IF 
   END IF 
       
   
   SELECT DISTINCT cod_empresa
     FROM geo_loc_faturado
    WHERE cod_empresa = p_cod_empresa
      AND num_nf = ma_faturar[l_arr_curr].num_nf
      AND cod_contrato = ma_faturar[l_arr_curr].cod_contrato
      AND cod_cliente = ma_faturar[l_arr_curr].cod_cliente
      AND cod_repres = ma_faturar[l_arr_curr].cod_repres
      AND periodo_de = ma_faturar[l_arr_curr].periodo_de
      AND periodo_ate = ma_faturar[l_arr_curr].periodo_ate
      AND num_pedido IN (SELECT DISTINCT a.pedido
                           FROM fat_nf_item a, fat_nf_mestre b
                          WHERE a.empresa = b.empresa
                            AND a.trans_nota_fiscal = b.trans_nota_fiscal
                            AND a.empresa = geo_loc_faturado.cod_empresa
                            AND b.sit_nota_fiscal = 'N'
                            AND b.serie_nota_fiscal = 'LC')
   IF sqlca.sqlcode = 0 THEN
      IF log_pergunta("Esse contrato já foi processado esse mês. Deseja reprocessá-lo ?") THEN
         CALL _ADVPL_set_property(m_table_reference3,"CLEAR_LINE_COLOR",l_arr_curr)
      ELSE
         LET ma_faturar[l_arr_curr].checkbox = "N"
      END IF 
   END IF 
   
   IF ma_faturar[l_arr_curr].checkbox = "N" THEN
      SELECT val_loc_mes
        INTO ma_faturar[l_arr_curr].val_loc_mes
        FROM geo_loc_mestre
       WHERE cod_empresa = p_cod_empresa
         AND cod_contrato = ma_faturar[l_arr_curr].cod_contrato
         AND cod_cliente = ma_faturar[l_arr_curr].cod_cliente
         AND cod_repres = ma_faturar[l_arr_curr].cod_repres
         
   END IF 
   
   CALL _ADVPL_set_property(m_table_reference3,"REFRESH")
END FUNCTION

#----------------------------#
FUNCTION geo1013_zoom_cond()
#----------------------------#
   DEFINE l_where_clause   CHAR(1000)
   DEFINE l_ind            SMALLINT
   define l_zoom_item varchar(10)
   define l_selecao integer 
   define l_cod_cliente char(15)
   
   INITIALIZE ma_zcond TO NULL

   LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
   CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
   CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_zcond)
   CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_cond_pgto")
    
    let mr_tela.cod_cnd_pgto = ma_zcond[1].cod_cnd_pgto
    let mr_tela.den_cnd_pgto = ma_zcond[1].den_cnd_pgto
   
END FUNCTION 

#------------------------------------#
FUNCTION geo1013_valid_cod_cnd_pgto()
#------------------------------------#
   
   SELECT den_cnd_pgto
     INTO mr_tela.den_cnd_pgto
     FROM cond_pgto
    WHERE cod_cnd_pgto = mr_tela.cod_cnd_pgto
   IF sqlca.sqlcode <> 0 THEN
      CALL _ADVPL_message_box("Condição de pagamento não encontrada")
      RETURN FALSE
   END IF 
   
   RETURN TRUE
END FUNCTION

#--------------------------------#
FUNCTION geo1013_faturar()
#--------------------------------#
CALL LOG_progress_start("Processa","geo1013_processa_faturar","PROCESS")

END FUNCTION

#-----------------------------------#
 FUNCTION geo1013_processa_faturar()
 #----------------------------------#
    define l_sql_stmt char(5000)
    DEFINE l_sql_stmt2 char(5000)
    DEFINE l_data1 CHAR(10)
    DEFINE l_data0 DATE
    DEFINE l_data2 DATE
    define l_sequencia smallint
    DEFINE l_num_pedido LIKE pedidos.num_pedido
    DEFINE l_trans_solic_fatura LIKE fat_solic_mestre.trans_solic_fatura
    DEFINE l_nat_oper VARCHAR(3)
    DEFINE l_msg CHAR(76)
    DEFINE l_erro char(999)
    DEFINE l_serie_fatura varchar(3)
    DEFINE l_finalidade varchar(1)
    DEFINE l_dat_refer CHAR(10)
    DEFINE l_dat_refer2 DATE
    DEFINE l_status SMALLINT
    DEFINE l_sqlcode char(10)
    DEFINE l_solicitacao_fatura INTEGER
    DEFINE l_cod_cliente char(15)
    DEFINE l_cod_vendedor char(15)
    DEFINE l_cod_manifesto  INTEGER
    DEFINE l_num_remessa    INTEGER
    DEFINE l_ser_remessa    CHAR(3)
    DEFINE l_trans_remessa  INTEGER
    DEFINE l_qtd_item    LIKE fat_nf_item.qtd_item
    DEFINE l_cod_item    LIKE fat_nf_item.item
    DEFINE l_parametro   CHAR(99)
    DEFINE l_desconto    LIKE ped_itens.pct_desc_adic
    DEFINE l_pct_desc    LIKE ped_itens.pct_desc_adic
    DEFINE l_pct_desc_adic LIKE ped_itens.pct_desc_adic
    DEFINE l_trans_nota_fiscal   INTEGER
    
    DEFINE l_insc_estadual LIKE clientes.ins_estadual
    DEFINE lr_mestre    RECORD
			    cod_empresa char(2),
				cod_contrato integer,
				num_nf integer,
				dat_instal date,
				ser_fabric char(15),
				cod_cliente char(15),
				cod_repres decimal(4),
				observacao char(999),
				ies_suspenso char(1),
				dat_suspensao date,
				ies_emite_nf char(1),
				val_loc_mes decimal(20,2),
				cod_cnd_pgto decimal(3,0)
          END RECORD
    DEFINE lr_itens      RECORD
                cod_empresa char(2),
				cod_contrato integer,
				cod_item char(15)
          END RECORD
    DEFINE l_ind                INTEGER      
    
    IF NOT log_pergunta("Deseja processar os contratos selecionados ?") THEN
       RETURN FALSE
    END IF 
    
    
    
    FOR l_ind = 1 TO _ADVPL_get_property(m_table_reference3,"ITEM_COUNT")
       IF ma_faturar[l_ind].checkbox = "S" THEN
          DECLARE cq_faturar CURSOR WITH HOLD FOR
          SELECT *
            FROM geo_loc_mestre
           WHERE cod_empresa = p_cod_empresa
             AND ies_suspenso = 'N'
             AND ies_emite_nf = 'S'
             AND num_nf = ma_faturar[l_ind].num_nf
             AND cod_contrato = ma_faturar[l_ind].cod_contrato
             AND cod_cliente = ma_faturar[l_ind].cod_cliente
             AND cod_repres = ma_faturar[l_ind].cod_repres
          LET l_dat_refer2 =  TODAY
          FOREACH cq_faturar INTO lr_mestre.*
             
             CALL log085_transacao("BEGIN")
             
             #LET l_dat_refer = EXTEND(lr_mestre.dat_instal, DAY TO DAY),"/", EXTEND(TODAY, MONTH TO MONTH),"/",EXTEND(TODAY,YEAR TO YEAR)
             #LET l_dat_refer2= l_dat_refer
             
		     CALL vdpr100_criar_temps_pedido_fatura(TRUE)
		     CALL supr11_cria_temporarias_reserva()
		     CALL supr9_cria_temporarias_estoque()
		     
		     SELECT val_parametro
		       INTO l_num_pedido
		       FROM log_val_parametro
		      WHERE empresa = p_cod_empresa
		        AND parametro = 'num_prx_pedido'
		     if sqlca.sqlcode = 0 then 
		     	UPDATE log_val_parametro
		     	   SET val_parametro = l_num_pedido + 1
		     	 WHERE empresa = p_cod_empresa
		     	   AND parametro = 'num_prx_pedido'
		     	if sqlca.sqlcode = 0 then
	     		   UPDATE par_vdp
		    	      SET num_prx_pedido = l_num_pedido + 1
		    	    WHERE cod_empresa = p_cod_empresa
		    	   if sqlca.sqlcode = 0 then
		    	      CALL log085_transacao("COMMIT")
		    	   ELSE 
		    	      let l_sqlcode = sqlca.sqlcode
		    	   	  CALL log085_transacao("ROLLBACK")
		    	   	  LET l_erro = "ERRO AO ATUALIZAR par_vdp. sqlcode: ",l_sqlcode
		    	   	  CALL _ADVPL_message_box(l_erro)
		    	   	  CONTINUE FOREACH
		    	   end if 
		    	ELSE
		    	   let l_sqlcode = sqlca.sqlcode
		    	   CALL log085_transacao("ROLLBACK")
		    	   LET l_erro = "ERRO AO ATUALIZAR log_val_parametro PARAMETRO num_prx_pedido. sqlcode: ",l_sqlcode
		    	   CALL _ADVPL_message_box(l_erro)
		    	   CONTINUE FOREACH
		    	end if 
		    ELSE
		       let l_sqlcode = sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       LET l_erro = "PARAMETRO num_prx_pedido NAO FOI ENCONTRADO NA TABELA log_val_parametro. sqlcode: ",l_sqlcode
		       CALL _ADVPL_message_box(l_erro)
		       CONTINUE FOREACH
            end if 
		       	
		    CALL log085_transacao("BEGIN")
		       	
	        CALL log2250_busca_parametro(p_cod_empresa,'geo_nat_oper_contrato')
	        RETURNING l_parametro, l_status
	           
	        IF l_parametro IS NULL OR l_parametro = " " THEN
	           LET l_parametro = "12"
	        END IF 
	        
	        LET l_nat_oper = l_parametro CLIPPED
		    
		    SELECT ins_estadual
		      INTO l_insc_estadual
		      FROM clientes
		     WHERE cod_cliente = lr_mestre.cod_cliente
		    
		    if UPSHIFT(l_insc_estadual) = "ISENTO" OR l_insc_estadual IS NULL OR l_insc_estadual = " " THEN
		       LET l_finalidade = "2"
		    ELSE
		       LET l_finalidade = "1"
		    END IF
		       	
		    CALL vdpm46_pedidos_set_null()
	       	CALL vdpm46_pedidos_set_cod_empresa(p_cod_empresa)
			CALL vdpm46_pedidos_set_num_pedido(l_num_pedido)
			CALL vdpm46_pedidos_set_cod_cliente(lr_mestre.cod_cliente)
			CALL vdpm46_pedidos_set_pct_comissao(0)
			CALL vdpm46_pedidos_set_num_pedido_repres(NULL)
			CALL vdpm46_pedidos_set_dat_emis_repres(TODAY)
			CALL vdpm46_pedidos_set_cod_nat_oper(l_nat_oper)
			CALL vdpm46_pedidos_set_cod_transpor(NULL)
			CALL vdpm46_pedidos_set_cod_consig(NULL)
			CALL vdpm46_pedidos_set_ies_finalidade(l_finalidade)
			CALL vdpm46_pedidos_set_ies_frete(1)
			CALL vdpm46_pedidos_set_ies_preco("F")
			CALL vdpm46_pedidos_set_cod_cnd_pgto(lr_mestre.cod_cnd_pgto)
			CALL vdpm46_pedidos_set_pct_desc_financ(0)
			CALL vdpm46_pedidos_set_ies_embal_padrao(3)
			CALL vdpm46_pedidos_set_ies_tip_entrega(1)
			CALL vdpm46_pedidos_set_ies_aceite("N")
			CALL vdpm46_pedidos_set_ies_sit_pedido("N")
			CALL vdpm46_pedidos_set_dat_pedido(TODAY)
			CALL vdpm46_pedidos_set_num_pedido_cli(NULL) 
			CALL vdpm46_pedidos_set_pct_desc_adic(0) 
			CALL vdpm46_pedidos_set_num_list_preco(NULL) 
			CALL vdpm46_pedidos_set_cod_repres(lr_mestre.cod_repres)
			CALL vdpm46_pedidos_set_cod_repres_adic(NULL)
			CALL vdpm46_pedidos_set_dat_alt_sit(TODAY)
			CALL vdpm46_pedidos_set_dat_cancel(NULL)
			CALL vdpm46_pedidos_set_cod_tip_venda(1)
			CALL vdpm46_pedidos_set_cod_motivo_can(NULL)
			CALL vdpm46_pedidos_set_dat_ult_fatur(NULL)
			CALL vdpm46_pedidos_set_cod_moeda(1)
			CALL vdpm46_pedidos_set_ies_comissao("S")
			CALL vdpm46_pedidos_set_pct_frete(0)
			CALL vdpm46_pedidos_set_cod_tip_carteira("01")
			CALL vdpm46_pedidos_set_num_versao_lista(0)
			CALL vdpm46_pedidos_set_cod_local_estoq(NULL)
			
			IF NOT vdpt46_pedidos_inclui(TRUE,TRUE) THEN
			   let l_sqlcode = sqlca.sqlcode
	           CALL log085_transacao("ROLLBACK")
	           LET l_erro = "FALHA AO INSERIR DADOS NA TABELA pedidos. sqlcode: ",l_sqlcode
	       	   CALL _ADVPL_message_box(l_erro)
	           CONTINUE FOREACH
	        END IF
   
             
            DELETE
              FROM geo_loc_faturado
             WHERE cod_empresa = p_cod_empresa
               AND num_nf = lr_mestre.num_nf
               AND cod_contrato = lr_mestre.cod_contrato
               AND cod_cliente = lr_mestre.cod_cliente
               AND cod_repres = lr_mestre.cod_repres
               AND periodo_de = ma_faturar[l_ind].periodo_de
               AND periodo_ate = ma_faturar[l_ind].periodo_ate
             
            DECLARE cq_faturar_itens CURSOR WITH HOLD FOR
            SELECT *
              FROM geo_loc_itens
             WHERE cod_empresa = p_cod_empresa
               AND cod_contrato = lr_mestre.cod_contrato
            LET l_sequencia = 1
            
            SELECT COUNT(*)
              FROM geo_loc_itens
             WHERE cod_empresa = p_cod_empresa
               AND cod_contrato = lr_mestre.cod_contrato
            
            FOREACH cq_faturar_itens INTO lr_itens.*
               CALL vdpm29_ped_itens_set_null()
               CALL vdpm29_ped_itens_set_cod_empresa(p_cod_empresa)
               CALL vdpm29_ped_itens_set_num_pedido(l_num_pedido)
               CALL vdpm29_ped_itens_set_num_sequencia(l_sequencia)
               CALL vdpm29_ped_itens_set_cod_item(lr_itens.cod_item)
               CALL vdpm29_ped_itens_set_pct_desc_adic(0) #GEOSALES TEM QUE ENVIAR
               CALL vdpm29_ped_itens_set_pre_unit(ma_faturar[l_ind].val_loc_mes)
               CALL vdpm29_ped_itens_set_qtd_pecas_solic(1)
               CALL vdpm29_ped_itens_set_qtd_pecas_atend(0)
               CALL vdpm29_ped_itens_set_qtd_pecas_cancel(0)
               CALL vdpm29_ped_itens_set_qtd_pecas_reserv(0)
               CALL vdpm29_ped_itens_set_prz_entrega(TODAY)
               CALL vdpm29_ped_itens_set_val_desc_com_unit(0)
               CALL vdpm29_ped_itens_set_val_frete_unit(0)
               CALL vdpm29_ped_itens_set_val_seguro_unit(0)
               CALL vdpm29_ped_itens_set_qtd_pecas_romaneio(0)
               CALL vdpm29_ped_itens_set_pct_desc_bruto(0)

               IF NOT vdpt29_ped_itens_inclui(TRUE,TRUE) THEN
                  let l_sqlcode = sqlca.sqlcode
                  CALL log085_transacao("ROLLBACK")
                  LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_itens. sqlcode: ",l_sqlcode
       	   		  CALL _ADVPL_message_box(l_erro)
       	   		  RETURN FALSE
               END IF
               LET l_sequencia = l_sequencia + 1
            END FOREACH
            
            CALL vdpm64_ped_info_compl_set_null()
	        CALL vdpm64_ped_info_compl_set_empresa(p_cod_empresa)
	        CALL vdpm64_ped_info_compl_set_pedido(l_num_pedido)
	        CALL vdpm64_ped_info_compl_set_campo("pedido_paletizado")
	        CALL vdpm64_ped_info_compl_set_par_existencia("N")
	        CALL vdpm64_ped_info_compl_set_parametro_texto(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_val(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_qtd(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_dat(NULL)
	         
	        IF NOT vdpt64_ped_info_compl_inclui(TRUE,TRUE) THEN
	           let l_sqlcode = sqlca.sqlcode
				CALL log085_transacao("ROLLBACK")
				LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_info_compl CAMPO pedido_paletizado. sqlcode: ",l_sqlcode
	       	   		CALL _ADVPL_message_box(l_erro)
		           CONTINUE FOREACH
	   		END IF
	        
		    CALL vdpm64_ped_info_compl_set_null()
	        CALL vdpm64_ped_info_compl_set_empresa(p_cod_empresa)
	        CALL vdpm64_ped_info_compl_set_pedido(l_num_pedido)
	        CALL vdpm64_ped_info_compl_set_campo("pct_tolerancia_maximo")
	        CALL vdpm64_ped_info_compl_set_par_existencia(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_texto(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_val(0)
	        CALL vdpm64_ped_info_compl_set_parametro_qtd(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_dat(NULL)
	         
	        IF NOT vdpt64_ped_info_compl_inclui(TRUE,TRUE) THEN
	           let l_sqlcode = sqlca.sqlcode
				CALL log085_transacao("ROLLBACK")
				LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_info_compl CAMPO pct_tolerancia_maximo. sqlcode: ",l_sqlcode
	       	   		CALL _ADVPL_message_box(l_erro)
		           CONTINUE FOREACH
	   		END IF
	        
		    CALL vdpm64_ped_info_compl_set_null()
	        CALL vdpm64_ped_info_compl_set_empresa(p_cod_empresa)
	        CALL vdpm64_ped_info_compl_set_pedido(l_num_pedido)
	        CALL vdpm64_ped_info_compl_set_campo("pct_tolerancia_minimo")
	        CALL vdpm64_ped_info_compl_set_par_existencia(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_texto(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_val(0)
	        CALL vdpm64_ped_info_compl_set_parametro_qtd(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_dat(NULL)
	         
	        IF NOT vdpt64_ped_info_compl_inclui(TRUE,TRUE) THEN
	           let l_sqlcode = sqlca.sqlcode
				CALL log085_transacao("ROLLBACK")
				LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_info_compl CAMPO pct_tolerancia_minimo. sqlcode: ",l_sqlcode
	       	   		CALL _ADVPL_message_box(l_erro)
		           CONTINUE FOREACH
	   		END IF
	        
		    CALL vdpm64_ped_info_compl_set_null()
	        CALL vdpm64_ped_info_compl_set_empresa(p_cod_empresa)
	        CALL vdpm64_ped_info_compl_set_pedido(l_num_pedido)
	        CALL vdpm64_ped_info_compl_set_campo("nota_empenho")
	        CALL vdpm64_ped_info_compl_set_par_existencia(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_texto(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_val(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_qtd(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_dat(NULL)
	         
	        IF NOT vdpt64_ped_info_compl_inclui(TRUE,TRUE) THEN
	           let l_sqlcode = sqlca.sqlcode
				CALL log085_transacao("ROLLBACK")
				LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_info_compl CAMPO nota_empenho. sqlcode: ",l_sqlcode
	       	   		CALL _ADVPL_message_box(l_erro)
		           CONTINUE FOREACH
	   		END IF
	        
		    CALL vdpm64_ped_info_compl_set_null()
	        CALL vdpm64_ped_info_compl_set_empresa(p_cod_empresa)
	        CALL vdpm64_ped_info_compl_set_pedido(l_num_pedido)
	        CALL vdpm64_ped_info_compl_set_campo("contrato_compra")
	        CALL vdpm64_ped_info_compl_set_par_existencia(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_texto(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_val(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_qtd(NULL)
	        CALL vdpm64_ped_info_compl_set_parametro_dat(NULL)
	         
	        IF NOT vdpt64_ped_info_compl_inclui(TRUE,TRUE) THEN
	           let l_sqlcode = sqlca.sqlcode
				CALL log085_transacao("ROLLBACK")
				LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_info_compl CAMPO contrato_compra. sqlcode: ",l_sqlcode
	       	   		CALL _ADVPL_message_box(l_erro)
		           CONTINUE FOREACH
	   		END IF
	   		
	   		CALL vdpm34_ped_itens_texto_set_null()
	        CALL vdpm34_ped_itens_texto_set_cod_empresa(p_cod_empresa)
	        CALL vdpm34_ped_itens_texto_set_num_pedido(l_num_pedido)
	        CALL vdpm34_ped_itens_texto_set_num_sequencia(0)
	        
	        LET l_msg = "CONTRATO: ",lr_mestre.cod_contrato
	        CALL vdpm34_ped_itens_texto_set_den_texto_1(l_msg CLIPPED)
	        CALL vdpm34_ped_itens_texto_set_den_texto_2("")
	        CALL vdpm34_ped_itens_texto_set_den_texto_3("")
	        CALL vdpm34_ped_itens_texto_set_den_texto_4("")
	        CALL vdpm34_ped_itens_texto_set_den_texto_5("")
	
	        IF NOT vdpt34_ped_itens_texto_inclui(TRUE,TRUE) THEN
	           let l_sqlcode = sqlca.sqlcode
	           CALL log085_transacao("ROLLBACK")
	           LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_itens_texto. sqlcode: ",l_sqlcode
	       	   		CALL _ADVPL_message_box(l_erro)
		           CONTINUE FOREACH
	        END IF
	        
	        CALL log2250_busca_parametro(p_cod_empresa,'geo_serie_fatura_contrato')
	        RETURNING l_parametro, l_status
	           
	        IF l_parametro IS NULL OR l_parametro = " " THEN
	           LET l_parametro = "LC"
	        END IF 
	        
	        LET l_serie_fatura = l_parametro
	        
	        LET l_solicitacao_fatura = lr_mestre.cod_contrato
	        WHILE TRUE
	           SELECT *
	             FROM fat_solic_mestre
	            WHERE empresa = p_cod_empresa
	              AND tip_docum = "SOLSERV"
	              AND serie_fatura = l_serie_fatura
	              AND subserie_fatura = 0
	              AND especie_fatura = "NF"
	              AND solicitacao_fatura = l_solicitacao_fatura
	           if sqlca.sqlcode <> 0 THEN
	              EXIT WHILE
	           END IF 
	           LET l_solicitacao_fatura = l_solicitacao_fatura + 1
	        END WHILE
	        
	        LET l_trans_solic_fatura = 0
	        CALL vdpm98_fat_solic_mestre_set_null()
		    CALL vdpm98_fat_solic_mestre_set_trans_solic_fatura(l_trans_solic_fatura)
		    CALL vdpm98_fat_solic_mestre_set_empresa(p_cod_empresa)
		    CALL vdpm98_fat_solic_mestre_set_tip_docum("SOLSERV")
		    CALL vdpm98_fat_solic_mestre_set_serie_fatura(l_serie_fatura)
		    CALL vdpm98_fat_solic_mestre_set_subserie_fatura(0)
		    CALL vdpm98_fat_solic_mestre_set_especie_fatura("NF")
		    CALL vdpm98_fat_solic_mestre_set_solicitacao_fatura(l_solicitacao_fatura)
		    CALL vdpm98_fat_solic_mestre_set_usuario(p_user)
		    CALL vdpm98_fat_solic_mestre_set_inscricao_estadual(NULL)
		    CALL vdpm98_fat_solic_mestre_set_dat_refer(l_dat_refer2)
		    CALL vdpm98_fat_solic_mestre_set_tip_solicitacao("P")
		    CALL vdpm98_fat_solic_mestre_set_lote_geral("N")
		    CALL vdpm98_fat_solic_mestre_set_tip_carteira(NULL)
		    CALL vdpm98_fat_solic_mestre_set_sit_solic_fatura("N")
	        
	        IF NOT vdpt98_fat_solic_mestre_inclui(TRUE,TRUE) THEN
	           let l_sqlcode = sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       LET l_erro = "FALHA AO INSERIR DADOS NA TABELA fat_solic_mestre. sqlcode: ",l_sqlcode
	       	   		CALL _ADVPL_message_box(l_erro)
		           CONTINUE FOREACH
		    END IF
		    
		    LET l_trans_solic_fatura = sqlca.sqlerrd[2]   {Transação da solicitação - serial}
	        
	        CALL vdpm101_fat_solic_fatura_set_null()
	        CALL vdpm101_fat_solic_fatura_set_trans_solic_fatura(l_trans_solic_fatura)
	        CALL vdpm101_fat_solic_fatura_set_ord_montag(l_num_pedido)
	        CALL vdpm101_fat_solic_fatura_set_lote_ord_montag(0)
	        CALL vdpm101_fat_solic_fatura_set_seq_solic_fatura(1)
	        CALL vdpm101_fat_solic_fatura_set_controle(NULL)
	        CALL vdpm101_fat_solic_fatura_set_cond_pagto(NULL)
	        CALL vdpm101_fat_solic_fatura_set_qtd_dia_acre_dupl(NULL)
	        CALL vdpm101_fat_solic_fatura_set_texto_1(NULL)
	        CALL vdpm101_fat_solic_fatura_set_texto_2(NULL)
	        CALL vdpm101_fat_solic_fatura_set_texto_3(NULL)
	        CALL vdpm101_fat_solic_fatura_set_via_transporte(1)
	        CALL vdpm101_fat_solic_fatura_set_tabela_frete(NULL)
	        CALL vdpm101_fat_solic_fatura_set_seq_tabela_frete(NULL)
	        CALL vdpm101_fat_solic_fatura_set_sequencia_faixa(NULL)
	        CALL vdpm101_fat_solic_fatura_set_cidade_dest_frete(NULL)
	        CALL vdpm101_fat_solic_fatura_set_transportadora(NULL)
	        CALL vdpm101_fat_solic_fatura_set_placa_veiculo(NULL)
	        CALL vdpm101_fat_solic_fatura_set_placa_carreta_1(NULL)
	        CALL vdpm101_fat_solic_fatura_set_placa_carreta_2(NULL)
	        CALL vdpm101_fat_solic_fatura_set_estado_placa_veic(NULL)
	        CALL vdpm101_fat_solic_fatura_set_estado_plac_carr_1(NULL)
	        CALL vdpm101_fat_solic_fatura_set_estado_plac_carr_2(NULL)
	        CALL vdpm101_fat_solic_fatura_set_val_frete(0)
	        CALL vdpm101_fat_solic_fatura_set_val_seguro(0)
	        CALL vdpm101_fat_solic_fatura_set_peso_liquido(0)
	        CALL vdpm101_fat_solic_fatura_set_peso_bruto(0)
	        CALL vdpm101_fat_solic_fatura_set_primeiro_volume(1)
	        CALL vdpm101_fat_solic_fatura_set_volume_cubico(0)
	        CALL vdpm101_fat_solic_fatura_set_mercado(NULL)
	        CALL vdpm101_fat_solic_fatura_set_local_embarque(NULL)
	        CALL vdpm101_fat_solic_fatura_set_modo_embarque(NULL)
	        CALL vdpm101_fat_solic_fatura_set_dat_hor_embarque(NULL)
	        CALL vdpm101_fat_solic_fatura_set_cidade_embarque(NULL)
	        CALL vdpm101_fat_solic_fatura_set_sit_solic_fatura("C")
	        
	        IF find4GLFunction("vdpm101_fat_solic_fatura_get_val_fret_exp") THEN
	           CALL vdpm101_fat_solic_fatura_set_val_fret_exp(NULL)
	           CALL vdpm101_fat_solic_fatura_set_val_segr_exp(NULL)
	           CALL vdpm101_fat_solic_fatura_set_aplic_fret_exp(NULL)
	           CALL vdpm101_fat_solic_fatura_set_tip_rat_fret_exp(NULL)
	        END IF
	        
	        IF NOT vdpt101_fat_solic_fatura_inclui(TRUE,TRUE) THEN
	           let l_sqlcode = sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       LET l_erro = "FALHA AO INSERIR DADOS NA TABELA fat_solic_fatura. sqlcode: ",l_sqlcode
	       	   		CALL _ADVPL_message_box(l_erro)
		           CONTINUE FOREACH
		    END IF
	        
	        {CALL vdpm102_fat_solic_embal_set_null()
	        CALL vdpm102_fat_solic_embal_set_trans_solic_fatura(l_trans_solic_fatura)
	        CALL vdpm102_fat_solic_embal_set_ord_montag(l_num_pedido)
	        CALL vdpm102_fat_solic_embal_set_lote_ord_montag(0)
	        CALL vdpm102_fat_solic_embal_set_embalagem(1)
	        CALL vdpm102_fat_solic_embal_set_qtd_embalagem(1)
	        
	        IF NOT vdpt102_fat_solic_embal_inclui(TRUE,TRUE) THEN
	           let l_sqlcode = sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       LET l_erro = "FALHA AO INSERIR DADOS NA TABELA fat_solic_embal. sqlcode: ",l_sqlcode
	       	   		CALL _ADVPL_message_box(l_erro)
		       
		           CONTINUE FOREACH
		    END IF}
	        
	        IF find4GLFunction("vdpm554_fat_s_nf_eletr_set_null") THEN
	           CALL vdpm554_fat_s_nf_eletr_set_null()
	           CALL vdpm554_fat_s_nf_eletr_set_trans_solic_fatura(l_trans_solic_fatura)
	           CALL vdpm554_fat_s_nf_eletr_set_ord_montag(l_num_pedido)
	           CALL vdpm554_fat_s_nf_eletr_set_lote_ord_montag(0)
	           CALL vdpm554_fat_s_nf_eletr_set_modalidade_frete_nfe('9')
	           CALL vdpm554_fat_s_nf_eletr_set_inf_adic_fisco(NULL)
	           CALL vdpm554_fat_s_nf_eletr_set_dat_hor_saida(NULL)
	           
	           IF NOT vdpt554_fat_s_nf_eletr_inclui(TRUE,TRUE) THEN
	              let l_sqlcode = sqlca.sqlcode
	              CALL log085_transacao("ROLLBACK")
		          LET l_erro = "FALHA AO INSERIR DADOS NA TABELA fat_s_nf_eletr. sqlcode: ",l_sqlcode
	       	   		CALL _ADVPL_message_box(l_erro)
		        CONTINUE FOREACH
	           END IF
	        END IF
	        
	        
	   		CALL vdpr100_valida_pedido_tipo_entrega(p_cod_empresa ,
	                                              l_num_pedido,
	                                              "M",
	                                              FALSE) RETURNING l_status
	   		IF NOT vdpr100_gerar_reservas_pedido(p_cod_empresa, l_num_pedido, FALSE) THEN
	           LET l_erro = "FALHA AO VALIDAR PEDIDO TIPO ENTREGA DO PEDIDO ",l_num_pedido,". sqlcode: ",l_sqlcode
	       	   		CALL _ADVPL_message_box(l_erro)
	        END IF
        
            INSERT INTO geo_loc_faturado VALUES (p_cod_empresa,
                                                 lr_mestre.cod_contrato,
                                                 lr_mestre.num_nf,
                                                 lr_mestre.cod_cliente,
                                                 lr_mestre.cod_repres,
                                                 TODAY,
                                                 ma_faturar[l_ind].periodo_de,
                                                 ma_faturar[l_ind].periodo_ate,
                                                 ma_faturar[l_ind].val_loc_mes,
                                                 l_num_pedido)
            DELETE FROM tran_arg
	         WHERE cod_empresa   = p_cod_empresa
	           AND num_programa  = 'vdp0745'
	           AND login_usuario = p_user
	           AND num_arg       = 1
	           AND indice_arg    = 0
	        if sqlca.sqlcode <> 0 then
	           let l_sqlcode = sqlca.sqlcode
	           CALL log085_transacao("ROLLBACK")
	           LET l_erro = "FALHA AO DELETAR DADOS DA TABELA tran_arg. sqlcode: ",l_sqlcode
       	   	   CALL _ADVPL_message_box(l_erro)
	           CONTINUE FOREACH
	        end if 
	        INSERT INTO tran_arg VALUES (p_cod_empresa,'vdp0745',p_user, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),1,0,'',l_trans_solic_fatura,NULL,NULL,NULL)
	        IF sqlca.sqlcode = 0 THEN
	           CALL log085_transacao("COMMIT")
	           CALL log1200_executa_programa_background('vdp0745')
	           
	       	ELSE
	       	
	       	   let l_sqlcode = sqlca.sqlcode
	       	   CALL log085_transacao("ROLLBACK")
		       LET l_erro = "FALHA AO INSERIR DADOS NA TABELA tran_arg. sqlcode: ",l_sqlcode
       	   	   CALL _ADVPL_message_box(l_erro)
	           CONTINUE FOREACH
	       	END IF 
   
          END FOREACH
       END IF 
    END FOR
    CALL _ADVPL_message_box("Faturamento efetuado com sucesso")
    CALL geo1013_cancela_filtro()
 END FUNCTION

#-------------------------------------#
 FUNCTION geo1013_processa_relat()
#-------------------------------------#
   DEFINE l_options         SMALLINT
   
   #CALL StartReport("geo1013_relat","geo1013","Ficha",132,TRUE,TRUE)
   
   CALL LOG_progress_start("Processando","geo1013_relat_pdf","PROCESS")
   CALL geo1013_cancela_filtro()
   RETURN TRUE
END FUNCTION

#-------------------------------------#
FUNCTION geo1013_relat(reportfile)
#-------------------------------------#
   ### PRESTACAO DE CONTAS - RESUMO DE VENDAS
   DEFINE reportfile          CHAR(250)
   DEFINE l_sql               CHAR(999)
   DEFINE l_ind               SMALLINT
   
   DEFINE lr_dados    RECORD
             cod_empresa char(2),
			 cod_contrato integer,
			 num_nf integer,
			 dat_instal date,
			 ser_fabric char(15),
			 cod_cliente char(15),
			 cod_repres decimal(4),
			 observacao char(999),
			 ies_suspenso char(1),
			 dat_suspensao date,
			 ies_emite_nf char(1),
			 val_loc_mes decimal(20,2),
			 cod_cnd_pgto decimal(3),
			 cod_item char(15),
			 periodo_de date,
			 periodo_ate date,
			 valor decimal(20,2),
			 data_process date,
			 num_pedido DECIMAL(6,0),
			 data_venc date,
			 num_titulo CHAR(15)
          END RECORD
   
   LET m_page_length = ReportPageLength("geo1013")
   START REPORT geo1013_report TO reportfile
   
   FOR l_ind = 1 TO _ADVPL_get_property(m_table_reference4,"ITEM_COUNT")
      IF ma_relat[l_ind].checkbox = "S" THEN
         DECLARE cq_relat CURSOR FOR
         SELECT a.*, b.cod_item, c.periodo_de, c.periodo_ate, c.valor, c.data_process, c.num_pedido
           FROM geo_loc_mestre a, geo_loc_itens b, geo_loc_faturado c
          WHERE a.cod_empresa = b.cod_empresa
            AND a.cod_empresa = p_cod_empresa
            AND a.cod_empresa = c.cod_empresa
            AND a.cod_contrato = c.cod_contrato
            AND a.cod_cliente = c.cod_cliente
            AND a.cod_repres = c.cod_repres
            AND a.cod_contrato = b.cod_contrato
            AND a.cod_contrato = ma_relat[l_ind].cod_contrato
            AND a.cod_cliente = ma_relat[l_ind].cod_cliente
            AND a.cod_repres = ma_relat[l_ind].cod_repres
            AND c.periodo_de = ma_relat[l_ind].periodo_de
            AND c.periodo_ate = ma_relat[l_ind].periodo_ate
            
            
         FOREACH cq_relat INTO lr_dados.*
         
         	DECLARE cq_docum CURSOR FOR
            SELECT DISTINCT a.num_docum
              FROM docum a, fat_nf_duplicata b, fat_nf_item c, fat_nf_mestre d
			 WHERE a.cod_empresa = b.empresa
			   ANd b.empresa = c.empresa
			   AND b.trans_nota_fiscal = c.trans_nota_fiscal
			   AND b.docum_cre = a.num_docum
			   AND d.empresa = b.empresa
			   AND d.trans_nota_fiscal = b.trans_nota_fiscal
			   AND d.sit_nota_fiscal = 'N'
			   AND c.pedido = lr_dados.num_pedido
			OPEN cq_docum
			FETCH cq_docum INTO lr_dados.num_titulo
			CLOSE cq_docum
			FREE cq_docum
            
            OUTPUT TO REPORT geo1013_report(lr_dados.*)
         END FOREACH
      END IF 
   END FOR
   
   FINISH REPORT geo1013_report
   
   CALL FinishReport("geo1013")
   
   CALL geo1013_cancela_filtro()
END FUNCTION


#------------------------------#
 REPORT geo1013_report(lr_relat)
#------------------------------#
  DEFINE lr_relat          RECORD
             cod_empresa char(2),
			 cod_contrato integer,
			 num_nf integer,
			 dat_instal date,
			 ser_fabric char(15),
			 cod_cliente char(15),
			 cod_repres decimal(4),
			 observacao char(999),
			 ies_suspenso char(1),
			 dat_suspensao date,
			 ies_emite_nf char(1),
			 val_loc_mes decimal(20,2),
			 cod_cnd_pgto decimal(3),
			 cod_item char(15),
			 periodo_de date,
			 periodo_ate date,
			 valor decimal(20,2),
			 data_process date,
			 num_pedido decimal(6,0),
			 data_venc date,
			 num_titulo CHAR(15)
         END RECORD
         
  DEFINE lr_total_dia          RECORD
            val_vista       DECIMAL(15,2),
            val_prazo       DECIMAL(15,2),
            tot_vendas      DECIMAL(15,2),
            val_cheques     DECIMAL(15,2),
            val_dinheiro    DECIMAL(15,2),
            val_despesas    DECIMAL(15,2),
            val_cobranca    DECIMAL(15,2),
            val_outros      DECIMAL(15,2),
            val_diferenca   DECIMAL(15,2)
         END RECORD
  DEFINE lr_empresa  RECORD LIKE empresa.*
  DEFINE lr_total_geral          RECORD
            val_vista       DECIMAL(15,2),
            val_prazo       DECIMAL(15,2),
            tot_vendas      DECIMAL(15,2),
            val_cheques     DECIMAL(15,2),
            val_dinheiro    DECIMAL(15,2),
            val_despesas    DECIMAL(15,2),
            val_cobranca    DECIMAL(15,2),
            val_outros      DECIMAL(15,2),
            val_diferenca   DECIMAL(15,2)
         END RECORD
         
  DEFINE l_last_row          SMALLINT
  DEFINE l_den_empresa       LIKE empresa.den_empresa
  DEFINE l_condicao_ant      CHAR(50)
  DEFINE l_primeiro          SMALLINT
  DEFINE l_quantidade        DECIMAL(20,2)
  DEFINE l_total             DECIMAL(20,2)
  DEFINE l_parametro CHAR(1)
  DEFINE l_parametro2 CHAR(3)
  DEFINE l_parametro3 DECIMAL(15,2)
  DEFINE l_status SMALLINT
  DEFINE l_geral             DECIMAL(20,2)
  DEFINE l_den_cidade        LIKE cidades.den_cidade
  DEFINE l_uni_feder         LIKE cidades.cod_uni_feder
  DEFINE l_cod_repres        DECIMAL(4,0)
  DEFINE lr_clientes RECORD LIKE clientes.*
  DEFINE l_num_docum LIKE docum.num_docum
  DEFINE l_dat_vencto_s_desc LIKE docum.dat_vencto_s_desc
  DEFINE l_val_saldo LIKE docum.val_saldo
  DEFINE l_data_calculada DATE
  DEFINE l_count INTEGER
  
  
  OUTPUT
    RIGHT  MARGIN 0
    LEFT   MARGIN 0
    TOP    MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH m_page_length
    #ORDER EXTERNAL BY lr_relat.cod_resp
  
  FORMAT

    ON EVERY ROW
       SELECT *
         INTO lr_empresa.*
         FROM empresa
        WHERE cod_empresa = p_cod_empresa
        
       SELECT DISTINCT a.dat_vencto_s_desc
          INTO lr_relat.data_venc
		  FROM docum a, fat_nf_duplicata b, fat_nf_item c, geo_loc_faturado d, fat_nf_mestre e
		 WHERE a.cod_empresa = b.empresa
		   AND b.empresa = c.empresa
		   AND c.empresa = d.cod_empresa
		   AND a.num_docum = b.docum_cre
		   AND b.trans_nota_fiscal = c.trans_nota_fiscal
		   AND c.pedido = d.num_pedido
		   AND c.seq_item_nf = 1
		   AND d.cod_empresa = p_cod_empresa
		   AND d.cod_contrato = lr_relat.cod_contrato
		   AND d.cod_cliente = lr_relat.cod_cliente
		   AND d.cod_repres = lr_relat.cod_repres
		   AND d.num_pedido = lr_relat.num_pedido
		   AND e.empresa = c.empresa
   		   AND e.trans_nota_fiscal = c.trans_nota_fiscal
   		   AND e.sit_nota_fiscal = 'N'
		   
        
       CALL ReportPageHeader("geo1013")
       PRINT COLUMN 049,lr_empresa.den_empresa CLIPPED 
       LET l_last_row = FALSE
       SKIP 01 LINE
       PRINT COLUMN 015,"INSCRIÇÃO CNPJ(MF):   ",lr_empresa.num_cgc CLIPPED,
             COLUMN 080,"INSCRIÇÃO ESTADUAL:   ",lr_empresa.ins_estadual CLIPPED
       PRINT COLUMN 015,"RUA   ",lr_empresa.end_empresa CLIPPED,"   ",lr_empresa.den_bairro CLIPPED
       PRINT COLUMN 015,"CEP:   ",lr_empresa.cod_cep CLIPPED,"  -  ",lr_empresa.den_munic CLIPPED,"  -  ",lr_empresa.uni_feder CLIPPED
       PRINT COLUMN 015,"TELEFONE:   ",lr_empresa.num_telefone CLIPPED
       #SKIP 01 LINE
       CALL ReportThinLine("geo1013")
       PRINT COLUMN 050,"N O T A   D E   D E B I T O"
       CALL ReportThinLine("geo1013")
       PRINT COLUMN 020,"Documento",
             COLUMN 045,"Titulo",
             COLUMN 069,"Emissão",
             COLUMN 090,"Valor",
             COLUMN 107,"Vencimento"
             
       PRINT COLUMN 015,"-------------------",
             COLUMN 041,"---------------",
             COLUMN 065,"---------------",
             COLUMN 085,"---------------",
             COLUMN 105,"--------------"
       
        
       
       PRINT COLUMN 017,lr_relat.ser_fabric CLIPPED,
             COLUMN 027,lr_relat.num_nf CLIPPED USING "&&&&&&",
             COLUMN 043,lr_relat.num_titulo CLIPPED,
             COLUMN 068,lr_relat.data_process,
             COLUMN 090,lr_relat.valor USING "######&.&&",
             COLUMN 107,lr_relat.data_venc
       
       PRINT COLUMN 015,"-------------------",
             COLUMN 041,"---------------",
             COLUMN 065,"---------------",
             COLUMN 085,"---------------",
             COLUMN 105,"--------------"
       #SKIP 01 LINE
       CALL log2250_busca_parametro(p_cod_empresa,'geo_impr_dupl_vencidas')
	    RETURNING l_parametro, l_status
	       
	    IF l_parametro IS NULL OR l_parametro = " " THEN
	       LET l_parametro = "N"
	    END IF 
	    
	   CALL log2250_busca_parametro(p_cod_empresa,'geo_qtd_dias_dupl_vencidas')
	    RETURNING l_parametro2, l_status
	       
	    IF l_parametro2 IS NULL OR l_parametro2 = " " THEN
	       LET l_parametro2 = "15"
	    END IF 
	    
	   CALL log2250_busca_parametro(p_cod_empresa,'geo_val_acima_dupl_vencidas')
	    RETURNING l_parametro3, l_status
	       
	    IF l_parametro3 IS NULL OR l_parametro3 = " " THEN
	       LET l_parametro3 = "0"
	    END IF 
	    
	   IF l_parametro = "S" THEN
	   
	      LET l_data_calculada = TODAY - l_parametro2 UNITS DAY
	      
	      SELECT COUNT(*)
	        INTO l_count
  			FROM docum
		   WHERE cod_empresa = p_cod_empresa
		     AND ies_tip_docum = 'DP'
		     AND ies_pgto_docum <> 'T'
		     AND val_bruto >= val_saldo
		     AND val_saldo >= l_parametro3
		     AND dat_vencto_s_desc <= l_data_calculada
		     AND cod_cliente = lr_relat.cod_cliente
		     AND ies_situa_docum = 'N'
		  IF l_count > 0 THEN
		     PRINT COLUMN 035,"***Constam em nossos sistemas duplicatas vencidas a mais de ",l_parametro2," dias."
		     PRINT   COLUMN 045,"Duplicata",
		             COLUMN 061,"Vencimento",
		             COLUMN 077,"Valor em Aberto"
		  END IF
	      
	      DECLARE cq_dp_vencidos CURSOR FOR
	      SELECT num_docum, dat_vencto_s_desc, val_saldo
  			FROM docum
		   WHERE cod_empresa = p_cod_empresa
		     AND ies_tip_docum = 'DP'
		     AND ies_pgto_docum <> 'T'
		     AND val_bruto >= val_saldo
		     AND val_saldo >= l_parametro3
		     AND dat_vencto_s_desc <= l_data_calculada
		     AND cod_cliente = lr_relat.cod_cliente
		     AND ies_situa_docum = 'N'
		   ORDER BY dat_vencto_s_desc DESC
		  
		  FOREACH cq_dp_vencidos INTO l_num_docum, l_dat_vencto_s_desc, l_val_saldo
		     PRINT COLUMN 045,l_num_docum CLIPPED,
		             COLUMN 061,l_dat_vencto_s_desc CLIPPED,
		             COLUMN 077,l_val_saldo USING "######&.&&"
		  END FOREACH
		  
		  IF l_count > 0 THEN
		     PRINT COLUMN 025,"***Caso o pagamento destas já tenha sido providenciado, favor desconsiderar esta mensagem."
		  END IF
	   END IF 
	        
       CALL ReportThinLine("geo1013")
       #SKIP 01 LINE
       
       SELECT *
         INTO lr_clientes.*
         FROM clientes
        WHERE cod_cliente = lr_relat.cod_cliente
       
       SELECT den_cidade, cod_uni_feder
         INTO l_den_cidade, l_uni_feder
         FROM cidades
        WHERE cod_cidade = lr_clientes.cod_cidade
       
       IF lr_clientes.ins_estadual IS NULL OR lr_clientes.ins_estadual = " " THEN
          LET lr_clientes.ins_estadual = "ISENTO"
       END IF 
       
       PRINT COLUMN 015, "SACADO:   ",lr_clientes.nom_cliente CLIPPED,
             COLUMN 100, lr_clientes.cod_cliente CLIPPED
       PRINT COLUMN 015, "ENDEREÇO:   ",lr_clientes.end_cliente CLIPPED,
             COLUMN 100, "BAIRRO:   ",lr_clientes.den_bairro CLIPPED
       PRINT COLUMN 015, "CEP:   ",lr_clientes.cod_cep CLIPPED,
             COLUMN 055, "MUNICÍPIO:   ",l_den_cidade CLIPPED,
             COLUMN 100, "UF:   ",l_uni_feder CLIPPED
       PRINT COLUMN 015, "CNPJ/CPF:   ",lr_clientes.num_cgc_cpf CLIPPED,
             COLUMN 100, "INSC. ESTADUAL:   ", lr_clientes.ins_estadual
       SKIP 01 LINE
       
       CALL ReportThinLine("geo1013")
       PRINT COLUMN 015,geo1013_extenso(lr_relat.valor) CLIPPED
       #SKIP 01 LINE
       CALL ReportThinLine("geo1013")
       #SKIP 01 LINE
       PRINT COLUMN 015,"CONTRATO DE LOCAÇÃO: ", lr_relat.cod_contrato CLIPPED ," - PERÍODO:   ",lr_relat.periodo_de,"  ATÉ  ",lr_relat.periodo_ate
       #SKIP 01 LINE     
       CALL ReportThinLine("geo1013")
       SKIP 01 LINE
       PRINT COLUMN 015,"Data: ___/___/_____",
             COLUMN 045,"DOCUMENTO: ____________________________",
             COLUMN 090,"NOME LEGÍVEL: ___________________________"
       #SKIP 01 LINE
       CALL ReportThinLine("geo1013")
       
       ########################## SEGUNDA ##############################
       
       PRINT COLUMN 001,"------------------------------------------------------------------------------------------------------------------------------------"
       CALL ReportThinLine("geo1013")
       PRINT COLUMN 049,lr_empresa.den_empresa CLIPPED 
       LET l_last_row = FALSE
       SKIP 01 LINE
       PRINT COLUMN 015,"INSCRIÇÃO CNPJ(MF):   ",lr_empresa.num_cgc CLIPPED,
             COLUMN 080,"INSCRIÇÃO ESTADUAL:   ",lr_empresa.ins_estadual CLIPPED
       PRINT COLUMN 015,"RUA   ",lr_empresa.end_empresa CLIPPED,"   ",lr_empresa.den_bairro CLIPPED
       PRINT COLUMN 015,"CEP:   ",lr_empresa.cod_cep CLIPPED,"  -  ",lr_empresa.den_munic CLIPPED,"  -  ",lr_empresa.uni_feder CLIPPED
       PRINT COLUMN 015,"TELEFONE:   ",lr_empresa.num_telefone CLIPPED
       #SKIP 01 LINE
       CALL ReportThinLine("geo1013")
       PRINT COLUMN 050,"N O T A   D E   D E B I T O"
       CALL ReportThinLine("geo1013")
       PRINT COLUMN 020,"Documento",
             COLUMN 045,"Titulo",
             COLUMN 069,"Emissão",
             COLUMN 090,"Valor",
             COLUMN 107,"Vencimento"
             
       PRINT COLUMN 015,"-------------------",
             COLUMN 041,"---------------",
             COLUMN 065,"---------------",
             COLUMN 085,"---------------",
             COLUMN 105,"--------------"
       
        
       
       PRINT COLUMN 017,lr_relat.ser_fabric CLIPPED,
             COLUMN 027,lr_relat.num_nf CLIPPED USING "&&&&&&",
             COLUMN 043,lr_relat.num_titulo CLIPPED,
             COLUMN 068,lr_relat.data_process,
             COLUMN 090,lr_relat.valor USING "######&.&&",
             COLUMN 107,lr_relat.data_venc
       
       PRINT COLUMN 015,"-------------------",
             COLUMN 041,"---------------",
             COLUMN 065,"---------------",
             COLUMN 085,"---------------",
             COLUMN 105,"--------------"
       
       CALL log2250_busca_parametro(p_cod_empresa,'geo_impr_dupl_vencidas')
	    RETURNING l_parametro, l_status
	       
	    IF l_parametro IS NULL OR l_parametro = " " THEN
	       LET l_parametro = "N"
	    END IF 
	    
	   CALL log2250_busca_parametro(p_cod_empresa,'geo_qtd_dias_dupl_vencidas')
	    RETURNING l_parametro2, l_status
	       
	    IF l_parametro2 IS NULL OR l_parametro2 = " " THEN
	       LET l_parametro2 = "15"
	    END IF 
	    
	    CALL log2250_busca_parametro(p_cod_empresa,'geo_val_acima_dupl_vencidas')
	    RETURNING l_parametro3, l_status
	       
	    IF l_parametro3 IS NULL OR l_parametro3 = " " THEN
	       LET l_parametro3 = "0"
	    END IF 
	    
	   IF l_parametro = "S" THEN
	   
	      LET l_data_calculada = TODAY - l_parametro2 UNITS DAY
	      
	      SELECT COUNT(*)
	        INTO l_count
  			FROM docum
		   WHERE cod_empresa = p_cod_empresa
		     AND ies_tip_docum = 'DP'
		     AND ies_pgto_docum <> 'T'
		     AND val_bruto >= val_saldo
		     AND val_saldo >= l_parametro3
		     AND dat_vencto_s_desc <= l_data_calculada
		     AND cod_cliente = lr_relat.cod_cliente
		     AND ies_situa_docum = 'N'
		  IF l_count > 0 THEN
		     PRINT COLUMN 035,"***Constam em nossos sistemas duplicatas vencidas a mais de ",l_parametro2," dias."
		     PRINT   COLUMN 045,"Duplicata",
		             COLUMN 061,"Vencimento",
		             COLUMN 077,"Valor em Aberto"
		  END IF
	      
	      DECLARE cq_dp_vencidos2 CURSOR FOR
	      SELECT num_docum, dat_vencto_s_desc, val_saldo
  			FROM docum
		   WHERE cod_empresa = p_cod_empresa
		     AND ies_tip_docum = 'DP'
		     AND ies_pgto_docum <> 'T'
		     AND val_bruto >= val_saldo
		     AND val_saldo >= l_parametro3
		     AND dat_vencto_s_desc <= l_data_calculada
		     AND cod_cliente = lr_relat.cod_cliente
		     AND ies_situa_docum = 'N'
		   ORDER BY dat_vencto_s_desc DESC
		  
		  FOREACH cq_dp_vencidos2 INTO l_num_docum, l_dat_vencto_s_desc, l_val_saldo
		     PRINT COLUMN 045,l_num_docum CLIPPED,
		             COLUMN 061,l_dat_vencto_s_desc CLIPPED,
		             COLUMN 077,l_val_saldo USING "######&.&&"
		  END FOREACH
		  
		  IF l_count > 0 THEN
		     PRINT COLUMN 025,"***Caso o pagamento destas já tenha sido providenciado, favor desconsiderar esta mensagem."
		  END IF
	   END IF 
       #SKIP 01 LINE
       CALL ReportThinLine("geo1013")
       #SKIP 01 LINE
       
       SELECT *
         INTO lr_clientes.*
         FROM clientes
        WHERE cod_cliente = lr_relat.cod_cliente
       
       SELECT den_cidade, cod_uni_feder
         INTO l_den_cidade, l_uni_feder
         FROM cidades
        WHERE cod_cidade = lr_clientes.cod_cidade
       
       IF lr_clientes.ins_estadual IS NULL OR lr_clientes.ins_estadual = " " THEN
          LET lr_clientes.ins_estadual = "ISENTO"
       END IF 
       
       PRINT COLUMN 015, "SACADO:   ",lr_clientes.nom_cliente CLIPPED,
             COLUMN 100, lr_clientes.cod_cliente CLIPPED
       PRINT COLUMN 015, "ENDEREÇO:   ",lr_clientes.end_cliente CLIPPED,
             COLUMN 100, "BAIRRO:   ",lr_clientes.den_bairro CLIPPED
       PRINT COLUMN 015, "CEP:   ",lr_clientes.cod_cep CLIPPED,
             COLUMN 055, "MUNICÍPIO:   ",l_den_cidade CLIPPED,
             COLUMN 100, "UF:   ",l_uni_feder CLIPPED
       PRINT COLUMN 015, "CNPJ/CPF:   ",lr_clientes.num_cgc_cpf CLIPPED,
             COLUMN 100, "INSC. ESTADUAL:   ", lr_clientes.ins_estadual
       #SKIP 01 LINE
       
       CALL ReportThinLine("geo1013")
       PRINT COLUMN 015, geo1013_extenso(lr_relat.valor) CLIPPED
       #SKIP 01 LINE
       CALL ReportThinLine("geo1013")
       #SKIP 01 LINE
       PRINT COLUMN 015,"CONTRATO DE LOCAÇÃO: ", lr_relat.cod_contrato CLIPPED ," - PERÍODO:   ",lr_relat.periodo_de,"  ATÉ  ",lr_relat.periodo_ate
       #SKIP 01 LINE
       CALL ReportThinLine("geo1013")
       SKIP 01 LINE
       PRINT COLUMN 015,"Data: ___/___/_____",
             COLUMN 045,"DOCUMENTO: ____________________________",
             COLUMN 090,"NOME LEGÍVEL: ___________________________"
       #SKIP 01 LINE
       #CALL ReportThinLine("geo1013")
       
       SKIP TO TOP OF PAGE
END REPORT


#---------------------------------#
 FUNCTION geo1013_extenso(l_valor)
#---------------------------------#
  DEFINE l_lin1,
         l_lin2,
         l_lin3,
         l_lin4 CHAR(200)
  DEFINE l_comp_l1,
         l_comp_l2,
         l_comp_l3,
         l_comp_l4 SMALLINT
         
  DEFINE l_valor  DECIMAL(15,2)
  DEFINE l_texto  CHAR(800)
         
  INITIALIZE l_lin1,
             l_lin2,
             l_lin3,
             l_lin4  TO NULL


  LET l_comp_l1 = 95
  LET l_comp_l2 = 110
  LET l_comp_l3 = 50
  LET l_comp_l4 = 50

   CALL log038_extenso(l_valor,
                       l_comp_l1,
                       l_comp_l2,
                       l_comp_l3,
                       l_comp_l4)
       RETURNING l_lin1, 
                 l_lin2, 
                 l_lin3, 
                 l_lin4
   
   LET l_texto = l_lin1 CLIPPED,
                 l_lin2 CLIPPED,
                 l_lin3 CLIPPED,
                 l_lin4 CLIPPED
                 
   RETURN l_texto CLIPPED
   
END FUNCTION


#----------------------------------#
FUNCTION geo1013_seleciona_todos1()
#----------------------------------#
   DEFINE l_ind             SMALLINT
   DEFINE l_valor           CHAR(1)
   
   
   IF ma_faturar[1].checkbox = "S" THEN
      LET l_valor = "N"
   ELSE
      LET l_valor = "S"
   END IF 
   FOR l_ind = 1 TO _ADVPL_get_property(m_table_reference3,"ITEM_COUNT")
      LET ma_faturar[l_ind].checkbox = l_valor
      
   END FOR 
   
   CALL _ADVPL_set_property(m_table_reference3,"REFRESH")

END FUNCTION

#----------------------------------#
FUNCTION geo1013_seleciona_todos2()
#----------------------------------#
   DEFINE l_ind             SMALLINT
   DEFINE l_valor           CHAR(1)
   
   
   IF ma_relat[1].checkbox = "S" THEN
      LET l_valor = "N"
   ELSE
      LET l_valor = "S"
   END IF 
   FOR l_ind = 1 TO _ADVPL_get_property(m_table_reference4,"ITEM_COUNT")
      LET ma_relat[l_ind].checkbox = l_valor
   END FOR 
   
   CALL _ADVPL_set_property(m_table_reference4,"REFRESH")

END FUNCTION


#-------------------------------------#
FUNCTION geo1013_cancela_nf_indevida()
#-------------------------------------#
{	DEFINE l_pedido DECIMAL(6,0)
	DEFINE l_count INTEGER
	DEFINE l_trans_nota_fiscal INTEGER
	DEFINE l_comando char(200)
	DEFINE l_ind INTEGER
	DEFINE l_mot_cancel           LIKE mot_cancel.cod_motivo
	
	DECLARE cq_canc_peds_dup CURSOR WITH HOLD FOR
	SELECT pedido, count(*)
	  FROM fat_nf_item
	 WHERE empresa = p_cod_empresa
	   AND trans_nota_fiscal IN (SELECT trans_nota_fiscal 
	                               FROM fat_nf_mestre 
	                              WHERE sit_nota_fiscal = 'N' 
	                                AND serie_nota_fiscal = 'LC' 
	                                AND empresa = p_cod_empresa)
	 GROUP BY pedido
	 HAVING COUNT(*) > 1
	
	FOREACH cq_canc_peds_dup INTO l_pedido, l_count
		DECLARE cq_get_trans CURSOR WITH HOLD FOR
		SELECT trans_nota_fiscal
		  FROM fat_nf_item
		 WHERE empresa = p_cod_empresa
		   AND pedido = l_pedido
		   AND trans_nota_fiscal IN (SELECT trans_nota_fiscal FROM fat_nf_mestre WHERE sit_nota_fiscal = 'N' AND serie_nota_fiscal = 'LC' AND empresa = p_cod_empresa)
		LET l_ind = 1
		FOREACH cq_get_trans INTO l_trans_nota_fiscal
		    IF l_ind > 1 THEN

       
		    	CALL log120_procura_caminho("VDP0753") RETURNING l_comando
		    	LET l_mot_cancel = '1'
			    LET l_comando = l_comando CLIPPED," ",p_cod_empresa CLIPPED,
			                         " ", l_trans_nota_fiscal USING "<<<<<<<<<<",
			                         " ", l_mot_cancel USING "<<<<<",
			                         " S"
			                         
			    RUN l_comando
		    END IF
			LET l_ind = l_ind + 1
		END FOREACH
	END FOREACH
	}
END FUNCTION


#--------------------------------------------#
 FUNCTION geo1013_monta_arquivo_formato_pdf(l_arquivo)
#--------------------------------------------#
   define l_arquivo char(40)
   let m_arquivo =     l_arquivo
   CALL geo1013_inicializa_processo_pdf()
   CALL geo1013_monta_layout_pdf()
   CALL geo1013_gera_pdf()
END FUNCTION
 
 #-----------------------------------------#
 FUNCTION geo1013_inicializa_processo_pdf()
#-----------------------------------------#
 DEFINE l_arquivo_remove   CHAR(150)
 DEFINE l_diretorio_config CHAR(150)

 define l_data  date

 define l_hora char(8)

 DEFINE l_tamanho          SMALLINT,
        l_indice           SMALLINT,
        l_nome_arquivo     CHAR(50),
        l_diretorio        CHAR(100)

 #::: INICIALIZAÇÃO DO PDF :::#
 LET m_ind = 0
 INITIALIZE ma_config_pdf TO NULL
 #:::::

 #::: DIRETORIO QUE SERÁ GRAVADO E DIRETORIO DE IMAGEM :::#
 CALL log150_procura_caminho('LST') RETURNING m_diretorio_pdf
 CALL log150_procura_caminho('IMG') RETURNING m_diretorio_img
 #:::

 #LET m_diretorio_pdf = "D:\\LST\\" ###RETIRAR ANTES DE ENVIAR AO CLIENTE

 LET m_diretorio_padrao = m_diretorio_pdf

 LET l_diretorio_config = m_diretorio_pdf CLIPPED,"configuracao.",p_user CLIPPED,".txt"

 IF g_ies_ambiente = "W" THEN
    LET l_arquivo_remove = 'del ',l_diretorio_config CLIPPED
 ELSE
    LET l_arquivo_remove = 'rm ',l_diretorio_config CLIPPED
 END IF

 RUN l_arquivo_remove

 #::: CONCATENAR :::#
 LET m_ind = m_ind + 1
 LET ma_config_pdf[m_ind].linha = "concatenar=nao;"

 LET l_tamanho = LENGTH(mr_docum.num_docum)
 FOR l_indice = 1 TO l_tamanho
     IF mr_docum.num_docum[l_indice] <> "/" THEN
        LET l_nome_arquivo = l_nome_arquivo CLIPPED, mr_docum.num_docum[l_indice]
     ELSE
        CONTINUE FOR
     END IF
 END FOR

 let l_data = today
 let l_hora = time
 #::: DIRETORIO + NOME DO PDF QUE SERÁ GERADO.
 LET m_diretorio_pdf =  m_diretorio_pdf        CLIPPED,
                                              m_arquivo clipped, p_user CLIPPED, l_data using 'ddmmyy', l_hora[1,2], l_hora[4,5], l_hora[7,8],  '.pdf'

 LET m_ind = m_ind + 1
 LET ma_config_pdf[m_ind].linha ="caminho=", m_diretorio_pdf


 #::: DIRETORIO TEMPORARIO :::#
 LET m_ind = m_ind + 1
 LET ma_config_pdf[m_ind].linha = "temporario=",m_diretorio_pdf CLIPPED

 #::: DEBUG :::#
 LET m_ind = m_ind + 1
 LET ma_config_pdf[m_ind].linha = "debug=true"

 #::: WEIGHT :::#
 LET m_ind = m_ind + 1
 LET ma_config_pdf[m_ind].linha = "weight=595"

 #::: HEIGHT :::#
 LET m_ind = m_ind + 1
 LET ma_config_pdf[m_ind].linha = "height=842"

 #::: CRIAR UMA PÁGINA EM BRANCO.
 LET m_ind = m_ind + 1
 LET ma_config_pdf[m_ind].linha = "easypdf=criarNovaPagina;"
 #:::::::::::::::::::::::::::::::::::#


 END FUNCTION

#---------------------------#
 FUNCTION geo1013_gera_pdf()
#---------------------------#
 DEFINE l_ind     SMALLINT
 DEFINE l_comando  CHAR(100)
 DEFINE l_tst SMALLINT

 DEFINE l_diretorio_config CHAR(100),
        l_diretorio_pdf    CHAR(100),
        l_caminho_pdf      CHAR(100),
        l_caminho_imp      CHAR(200)

 DEFINE l_mensagem         CHAR(100),
        l_arquivo          CHAR(30)

 LET l_diretorio_config = m_diretorio_pdf CLIPPED,"configuracao.",p_user CLIPPED,".txt"

 CALL log4070_channel_open_file("configuracao",l_diretorio_config,"w")

 CALL log4070_channel_set_delimiter("configuracao","")

 FOR l_ind = 1 TO m_ind
    CALL log4070_channel_write("configuracao",ma_config_pdf[l_ind].linha)
 END FOR

 CALL log4070_channel_close("configuracao")

# LET m_comando = "java -Dfile.encoding=ISO-8859-1 easyPDF ",l_diretorio_config

 LET m_comando = "java easyPDF ",l_diretorio_config
 RUN m_comando


    CALL _advpl_LOG_file_previewInClient(m_diretorio_pdf,FALSE,NULL)

 #call _ADVPL_u_abrepdflogix(m_diretorio_pdf)


 END FUNCTION

 
 
#--------------------------------#
FUNCTION geo1013_relat_pdf()
#--------------------------------#

	CALL geo1013_monta_arquivo_formato_pdf("geo1013.")
	
	RETURN TRUE
END FUNCTION


#----------------------------------------------------------#
 FUNCTION geo1013_monta_layout_pdf()
#----------------------------------------------------------#

	DEFINE l_linha, l_coluna  INTEGER
	DEFINE l_linha2 INTEGER
	DEFINE l_texto            CHAR(500)
	define l_conta            integer
	
	DEFINE l_ind               integer
	DEFINE l_ind2              integer
	DEFINE l_pagina_atual      INTEGER
	
	DEFINE lr_empresa RECORD LIKE empresa.*
	DEFINE l_data_venc DATE
	DEFINE l_parametro CHAR(99)
	DEFINE l_parametro2 CHAR(99)
	DEFINE l_parametro3 CHAR(99)
	DEFINE l_status SMALLINT
	DEFINE l_valor_char CHAR(50)
	
	DEFINE lr_clientes RECORD LIKE clientes.*
	DEFINE l_ind_venc INTEGER
	DEFINE l_den_cidade LIKE cidades.den_cidade
	DEFINE l_uni_feder LIKE cidades.cod_uni_feder
	DEFINE l_count INTEGER
	DEFINE l_data_calculada DATE
	DEFINE l_num_docum LIKE docum.num_docum
	DEFINE l_dat_vencto_s_desc LIKE docum.dat_vencto_s_desc
	DEFINE l_val_saldo LIKE docum.val_saldo
	DEFINE la_vencidos ARRAY[99] OF RECORD
		num_docum LIKE docum.num_docum,
		dat_vencto_s_desc LIKE docum.dat_vencto_s_desc,
		val_saldo LIKE docum.val_saldo
	END RECORD
	
	DEFINE l_primeiro smallint
	DEFINE l_logo CHAR(999)
	
	DEFINE lr_dados    RECORD
             cod_empresa char(2),
			 cod_contrato integer,
			 num_nf integer,
			 dat_instal date,
			 ser_fabric char(15),
			 cod_cliente char(15),
			 cod_repres decimal(4),
			 observacao char(999),
			 ies_suspenso char(1),
			 dat_suspensao date,
			 ies_emite_nf char(1),
			 val_loc_mes decimal(20,2),
			 cod_cnd_pgto decimal(3),
			 cod_item char(15),
			 periodo_de date,
			 periodo_ate date,
			 valor decimal(20,2),
			 data_process date,
			 num_pedido DECIMAL(6,0),
			 data_venc date,
			 num_titulo CHAR(15)
          END RECORD
	       
	LET l_linha  = 830
	LET l_linha2 = 1
	LET l_pagina_atual = 1

	let l_conta = 0
	
	CALL log2250_busca_parametro(p_cod_empresa,'geo_impr_dupl_vencidas')
	RETURNING l_parametro, l_status
       
    IF l_parametro IS NULL OR l_parametro = " " THEN
       LET l_parametro = "N"
    END IF 
    
   CALL log2250_busca_parametro(p_cod_empresa,'geo_qtd_dias_dupl_vencidas')
    RETURNING l_parametro2, l_status
       
    IF l_parametro2 IS NULL OR l_parametro2 = " " THEN
       LET l_parametro2 = "15"
    END IF 
    
   CALL log2250_busca_parametro(p_cod_empresa,'geo_val_acima_dupl_vencidas')
    RETURNING l_parametro3, l_status
       
    IF l_parametro3 IS NULL OR l_parametro3 = " " THEN
       LET l_parametro3 = "0"
    END IF 
    
    SELECT camh_logtip_emp 
      INTO l_logo
      FROM vdp_par_nf_eletr 
     WHERE empresa = p_cod_empresa
	
	SELECT *
      INTO lr_empresa.*
      FROM empresa
     WHERE cod_empresa = p_cod_empresa
	
	
	LET l_primeiro = TRUE
	FOR l_ind = 1 TO _ADVPL_get_property(m_table_reference4,"ITEM_COUNT")
      IF ma_relat[l_ind].checkbox = "S" THEN
      	IF l_primeiro THEN
      		LET l_primeiro = FALSE
      	ELSE
	      	LET m_ind = m_ind + 1
	 		LET ma_config_pdf[m_ind].linha = "easypdf=criarNovaPagina;"
	 		LET l_linha  = 830
			LET l_linha2 = 1
			LET l_pagina_atual = 1
		
			let l_conta = 0
	 	END IF
         DECLARE cq_relat CURSOR FOR
         SELECT a.*, b.cod_item, c.periodo_de, c.periodo_ate, c.valor, c.data_process, c.num_pedido
           FROM geo_loc_mestre a, geo_loc_itens b, geo_loc_faturado c
          WHERE a.cod_empresa = b.cod_empresa
            AND a.cod_empresa = p_cod_empresa
            AND a.cod_empresa = c.cod_empresa
            AND a.cod_contrato = c.cod_contrato
            AND a.cod_cliente = c.cod_cliente
            AND a.cod_repres = c.cod_repres
            AND a.cod_contrato = b.cod_contrato
            AND a.cod_contrato = ma_relat[l_ind].cod_contrato
            AND a.cod_cliente = ma_relat[l_ind].cod_cliente
            AND a.cod_repres = ma_relat[l_ind].cod_repres
            AND c.periodo_de = ma_relat[l_ind].periodo_de
            AND c.periodo_ate = ma_relat[l_ind].periodo_ate
            
            
         FOREACH cq_relat INTO lr_dados.*
         
         	DECLARE cq_docum CURSOR FOR
            SELECT DISTINCT a.num_docum
              FROM docum a, fat_nf_duplicata b, fat_nf_item c, fat_nf_mestre d
			 WHERE a.cod_empresa = b.empresa
			   ANd b.empresa = c.empresa
			   AND b.trans_nota_fiscal = c.trans_nota_fiscal
			   AND b.docum_cre = a.num_docum
			   AND d.empresa = b.empresa
			   AND d.trans_nota_fiscal = b.trans_nota_fiscal
			   AND d.sit_nota_fiscal = 'N'
			   AND c.pedido = lr_dados.num_pedido
			OPEN cq_docum
			FETCH cq_docum INTO lr_dados.num_titulo
			CLOSE cq_docum
			FREE cq_docum
			
			
	        
	       SELECT DISTINCT a.dat_vencto_s_desc
	          INTO l_data_venc
			  FROM docum a, fat_nf_duplicata b, fat_nf_item c, geo_loc_faturado d, fat_nf_mestre e
			 WHERE a.cod_empresa = b.empresa
			   AND b.empresa = c.empresa
			   AND c.empresa = d.cod_empresa
			   AND a.num_docum = b.docum_cre
			   AND b.trans_nota_fiscal = c.trans_nota_fiscal
			   AND c.pedido = d.num_pedido
			   AND c.seq_item_nf = 1
			   AND d.cod_empresa = p_cod_empresa
			   AND d.cod_contrato = lr_dados.cod_contrato
			   AND d.cod_cliente = lr_dados.cod_cliente
			   AND d.cod_repres = lr_dados.cod_repres
			   AND d.num_pedido = lr_dados.num_pedido
			   AND e.empresa = c.empresa
	   		   AND e.trans_nota_fiscal = c.trans_nota_fiscal
	   		   AND e.sit_nota_fiscal = 'N'
	   		   
			LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET m_ind = m_ind + 1
		    LET l_coluna = 40
 			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaImagem(",l_logo CLIPPED," ; ","88"," ; ","72"," ; ",l_coluna," ; ",l_linha-77," );"
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 190
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 15);"
			LET m_ind = m_ind + 1
			LET l_texto = "TORREFAÇÕES NOIVACOLINENSES LTDA"#lr_empresa.den_empresa
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 150
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Inscrição Cnpj(MF): ",lr_empresa.num_cgc CLIPPED,"                   Inscrição Estadual: ",lr_empresa.ins_estadual
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 150
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "RUA ",lr_empresa.end_empresa CLIPPED," - ",lr_empresa.den_bairro
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 150
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Cep: ",lr_empresa.cod_cep CLIPPED," - ",lr_empresa.den_munic CLIPPED," - ",lr_empresa.uni_feder,"                           Telefone: ",lr_empresa.num_telefone
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
			
		    LET l_linha  = l_linha
			LET l_coluna = 210
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 13);"
			LET m_ind = m_ind + 1
			LET l_texto = "N O T A   D E   D E B I T O"#lr_empresa.den_empresa
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha-5," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|                                       |                                       |                                       |                                       |"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha - 4
			LET l_coluna = 55
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Documento                              Título                                Emissão                                Valor                             Vencimento"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
			LET l_linha  = l_linha - 5
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|                                       |                                       |                                       |                                       |"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|                   |                   |                                       |                                       |                                       |"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    LET l_linha  = l_linha - 4
			LET l_coluna = 45
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_dados.ser_fabric CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 90
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_dados.num_nf USING "&&&&&&"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 160
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_dados.num_titulo CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 280
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_dados.data_process CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_valor_char = lr_dados.valor
		    LET l_linha  = l_linha
			LET l_coluna = 400
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "R$ ",l_valor_char
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 500
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = l_data_venc
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
			LET l_linha  = l_linha - 5
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|                   |                   |                                       |                                       |                                       |"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    SELECT *
	         INTO lr_clientes.*
	         FROM clientes
	        WHERE cod_cliente = lr_dados.cod_cliente
	       
	       SELECT den_cidade, cod_uni_feder
	         INTO l_den_cidade, l_uni_feder
	         FROM cidades
	        WHERE cod_cidade = lr_clientes.cod_cidade
		    
		    LET l_linha  = l_linha
			LET l_coluna = 40
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Sacado: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 90
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_clientes.nom_cliente CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 450
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_clientes.cod_cliente CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    LET l_linha  = l_linha
			LET l_coluna = 40
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Endereço: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			
			LET l_linha  = l_linha
			LET l_coluna = 90
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_clientes.end_cliente CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha
			LET l_coluna = 400
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Bairro: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 440
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_clientes.den_bairro CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 40
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "CEP: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 90
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_clientes.cod_cep CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			
		    LET l_linha  = l_linha
			LET l_coluna = 200
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Município: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 250
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = l_den_cidade CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			
		    LET l_linha  = l_linha
			LET l_coluna = 400
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "UF: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 420
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = l_uni_feder CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 40
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Cnpj/Cpf: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 90
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_clientes.num_cgc_cpf CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			
			LET l_linha  = l_linha
			LET l_coluna = 300
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Insc.Estadual: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 370
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_clientes.ins_estadual
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
	    
		    LET l_count = 0
		    INITIALIZE la_vencidos TO NULL
		    IF l_parametro = "S" THEN
		   
		      LET l_data_calculada = TODAY - l_parametro2 UNITS DAY
		      
		      SELECT COUNT(*)
		        INTO l_count
	  			FROM docum
			   WHERE cod_empresa = p_cod_empresa
			     AND ies_tip_docum = 'DP'
			     AND ies_pgto_docum <> 'T'
			     AND val_bruto >= val_saldo
			     AND val_saldo >= l_parametro3
			     AND dat_vencto_s_desc <= l_data_calculada
			     AND cod_cliente = lr_dados.cod_cliente
			     AND ies_situa_docum = 'N'
			     
			  DECLARE cq_dp_vencidos CURSOR FOR
		      SELECT num_docum, dat_vencto_s_desc, val_saldo
	  			FROM docum
			   WHERE cod_empresa = p_cod_empresa
			     AND ies_tip_docum = 'DP'
			     AND ies_pgto_docum <> 'T'
			     AND val_bruto >= val_saldo
			     AND val_saldo >= l_parametro3
			     AND dat_vencto_s_desc <= l_data_calculada
			     AND cod_cliente = lr_dados.cod_cliente
			     AND ies_situa_docum = 'N'
			   ORDER BY dat_vencto_s_desc DESC
			  
			  LET l_ind_venc = 1
			  
			  FOREACH cq_dp_vencidos INTO l_num_docum, l_dat_vencto_s_desc, l_val_saldo
			  	 LET la_vencidos[l_ind_venc].num_docum = l_num_docum
			  	 LET la_vencidos[l_ind_venc].dat_vencto_s_desc = l_dat_vencto_s_desc
			  	 LET la_vencidos[l_ind_venc].val_saldo = l_val_saldo
			  	 LET l_ind_venc = l_ind_venc + 1
			  	 
			  	 IF l_ind_venc > 10 THEN
			  	 	EXIT FOREACH
			  	 END IF
			  END FOREACH
			END IF
		    
		    IF l_count > 0 THEN
			    LET l_linha  = l_linha
				LET l_coluna = 40
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "******************************************Constam em nossos sistemas duplicatas vencidas a mais de ",l_parametro2 CLIPPED," dias.******************************************"
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    END IF
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    IF l_count > 0 THEN
			    LET l_linha  = l_linha
				LET l_coluna = 40
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "Duplicata          Vencimento           Valor"
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    END IF
		    
		    IF l_count > 3 THEN
			    LET l_linha  = l_linha
				LET l_coluna = 225
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "Duplicata          Vencimento           Valor"
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    END IF
		    
		    IF l_count > 6 THEN
			    LET l_linha  = l_linha
				LET l_coluna = 420
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "Duplicata          Vencimento           Valor"
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    END IF
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
		    IF la_vencidos[1].num_docum IS NOT NULL AND la_vencidos[1].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 40
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[1].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 103
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[1].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[1].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 160
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
		    
		    IF la_vencidos[4].num_docum IS NOT NULL AND la_vencidos[4].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 225
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[4].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 288
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[4].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[4].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 345
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
			
			IF la_vencidos[7].num_docum IS NOT NULL AND la_vencidos[7].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 420
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[7].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 483
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[7].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[7].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 540
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    IF la_vencidos[2].num_docum IS NOT NULL AND la_vencidos[2].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 40
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[2].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 103
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[2].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[2].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 160
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
		    
		    IF la_vencidos[5].num_docum IS NOT NULL AND la_vencidos[5].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 225
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[5].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 288
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[5].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[5].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 345
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
			
			IF la_vencidos[8].num_docum IS NOT NULL AND la_vencidos[8].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 420
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[8].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 483
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[8].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[8].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 540
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    IF la_vencidos[3].num_docum IS NOT NULL AND la_vencidos[3].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 40
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[3].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 103
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[3].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[3].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 160
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
		    
		    IF la_vencidos[6].num_docum IS NOT NULL AND la_vencidos[6].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 225
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[6].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 288
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[6].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[6].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 345
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
			
			IF la_vencidos[9].num_docum IS NOT NULL AND la_vencidos[9].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 420
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[9].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 483
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[9].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[9].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 540
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
		    
			
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    IF l_count > 0 THEN
		        LET l_linha  = l_linha
				LET l_coluna = 40
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "****************************Caso o pagamento destas já tenha sido providenciado, favor desconsiderar esta mensagem.***************************"
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    END IF
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
		    LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 40
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = geo1013_extenso(lr_dados.valor) CLIPPED
			LET l_texto = l_texto[1,100]
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			
		    
			{LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    }
		    
			
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		   
		    LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 40
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Contato de Locação: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 150
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_dados.cod_contrato CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 400
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Período: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 450
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "de ",lr_dados.periodo_de," a ",lr_dados.periodo_ate
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			{LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    }
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 40
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Data: _____/_____/__________         Documento: _____________________      Nome Legível: ___________________________ "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			
			LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = 830
			LET l_linha2 = 1
			LET l_pagina_atual = 1
		
			let l_conta = 0
			
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		
				    
		
			LET l_linha  = 415
			LET l_linha2 = 1
			LET l_pagina_atual = 1
		
			let l_conta = 0
			
	
	
	
            LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET m_ind = m_ind + 1
		    LET l_coluna = 40
 			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaImagem(",l_logo CLIPPED," ; ","88"," ; ","72"," ; ",l_coluna," ; ",l_linha-77," );"
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 190
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 15);"
			LET m_ind = m_ind + 1
			LET l_texto = "TORREFAÇÕES NOIVACOLINENSES LTDA"#lr_empresa.den_empresa
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 150
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Inscrição Cnpj(MF): ",lr_empresa.num_cgc CLIPPED,"                   Inscrição Estadual: ",lr_empresa.ins_estadual
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 150
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "RUA ",lr_empresa.end_empresa CLIPPED," - ",lr_empresa.den_bairro
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 150
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Cep: ",lr_empresa.cod_cep CLIPPED," - ",lr_empresa.den_munic CLIPPED," - ",lr_empresa.uni_feder,"                           Telefone: ",lr_empresa.num_telefone
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
			
		    LET l_linha  = l_linha
			LET l_coluna = 210
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 13);"
			LET m_ind = m_ind + 1
			LET l_texto = "N O T A   D E   D E B I T O"#lr_empresa.den_empresa
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha-5," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|                                       |                                       |                                       |                                       |"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha - 4
			LET l_coluna = 55
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Documento                              Título                                Emissão                                Valor                             Vencimento"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
			LET l_linha  = l_linha - 5
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|                                       |                                       |                                       |                                       |"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|                   |                   |                                       |                                       |                                       |"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    LET l_linha  = l_linha - 4
			LET l_coluna = 45
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_dados.ser_fabric CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 90
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_dados.num_nf USING "&&&&&&"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 160
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_dados.num_titulo CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 280
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_dados.data_process CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_valor_char = lr_dados.valor
		    LET l_linha  = l_linha
			LET l_coluna = 400
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "R$ ",l_valor_char
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 500
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = l_data_venc
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
			LET l_linha  = l_linha - 5
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|                   |                   |                                       |                                       |                                       |"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    SELECT *
	         INTO lr_clientes.*
	         FROM clientes
	        WHERE cod_cliente = lr_dados.cod_cliente
	       
	       SELECT den_cidade, cod_uni_feder
	         INTO l_den_cidade, l_uni_feder
	         FROM cidades
	        WHERE cod_cidade = lr_clientes.cod_cidade
		    
		    LET l_linha  = l_linha
			LET l_coluna = 40
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Sacado: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 90
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_clientes.nom_cliente CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 450
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_clientes.cod_cliente CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    LET l_linha  = l_linha
			LET l_coluna = 40
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Endereço: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			
			LET l_linha  = l_linha
			LET l_coluna = 90
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_clientes.end_cliente CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha
			LET l_coluna = 400
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Bairro: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 440
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_clientes.den_bairro CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 40
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "CEP: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 90
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_clientes.cod_cep CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			
		    LET l_linha  = l_linha
			LET l_coluna = 200
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Município: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 250
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = l_den_cidade CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			
		    LET l_linha  = l_linha
			LET l_coluna = 400
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "UF: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 420
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = l_uni_feder CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 40
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Cnpj/Cpf: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 90
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_clientes.num_cgc_cpf CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			
			LET l_linha  = l_linha
			LET l_coluna = 300
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Insc.Estadual: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 370
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_clientes.ins_estadual
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
	    
		    LET l_count = 0
		    INITIALIZE la_vencidos TO NULL
		    IF l_parametro = "S" THEN
		   
		      LET l_data_calculada = TODAY - l_parametro2 UNITS DAY
		      
		      SELECT COUNT(*)
		        INTO l_count
	  			FROM docum
			   WHERE cod_empresa = p_cod_empresa
			     AND ies_tip_docum = 'DP'
			     AND ies_pgto_docum <> 'T'
			     AND val_bruto >= val_saldo
			     AND val_saldo >= l_parametro3
			     AND dat_vencto_s_desc <= l_data_calculada
			     AND cod_cliente = lr_dados.cod_cliente
			     AND ies_situa_docum = 'N'
			     
			  DECLARE cq_dp_vencidos CURSOR FOR
		      SELECT num_docum, dat_vencto_s_desc, val_saldo
	  			FROM docum
			   WHERE cod_empresa = p_cod_empresa
			     AND ies_tip_docum = 'DP'
			     AND ies_pgto_docum <> 'T'
			     AND val_bruto >= val_saldo
			     AND val_saldo >= l_parametro3
			     AND dat_vencto_s_desc <= l_data_calculada
			     AND cod_cliente = lr_dados.cod_cliente
			     AND ies_situa_docum = 'N'
			   ORDER BY dat_vencto_s_desc DESC
			  
			  LET l_ind_venc = 1
			  FOREACH cq_dp_vencidos INTO l_num_docum, l_dat_vencto_s_desc, l_val_saldo
			  	 LET la_vencidos[l_ind_venc].num_docum = l_num_docum
			  	 LET la_vencidos[l_ind_venc].dat_vencto_s_desc = l_dat_vencto_s_desc
			  	 LET la_vencidos[l_ind_venc].val_saldo = l_val_saldo
			  	 LET l_ind_venc = l_ind_venc + 1
			  	 
			  	 IF l_ind_venc > 10 THEN
			  	 	EXIT FOREACH
			  	 END IF
			  END FOREACH
			END IF
		    
		    IF l_count > 0 THEN
			    LET l_linha  = l_linha
				LET l_coluna = 40
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "******************************************Constam em nossos sistemas duplicatas vencidas a mais de ",l_parametro2 CLIPPED," dias.******************************************"
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    END IF
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    IF l_count > 0 THEN
			    LET l_linha  = l_linha
				LET l_coluna = 40
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "Duplicata          Vencimento           Valor"
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    END IF
		    
		    IF l_count > 3 THEN
			    LET l_linha  = l_linha
				LET l_coluna = 225
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "Duplicata          Vencimento           Valor"
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    END IF
		    
		    IF l_count > 6 THEN
			    LET l_linha  = l_linha
				LET l_coluna = 420
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "Duplicata          Vencimento           Valor"
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    END IF
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
		    IF la_vencidos[1].num_docum IS NOT NULL AND la_vencidos[1].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 40
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[1].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 103
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[1].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[1].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 160
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
		    
		    IF la_vencidos[4].num_docum IS NOT NULL AND la_vencidos[4].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 225
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[4].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 288
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[4].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[4].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 345
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
			
			IF la_vencidos[7].num_docum IS NOT NULL AND la_vencidos[7].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 420
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[7].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 483
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[7].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[7].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 540
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    IF la_vencidos[2].num_docum IS NOT NULL AND la_vencidos[2].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 40
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[2].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 103
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[2].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[2].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 160
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
		    
		    IF la_vencidos[5].num_docum IS NOT NULL AND la_vencidos[5].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 225
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[5].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 288
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[5].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[5].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 345
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
			
			IF la_vencidos[8].num_docum IS NOT NULL AND la_vencidos[8].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 420
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[8].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 483
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[8].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[8].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 540
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    IF la_vencidos[3].num_docum IS NOT NULL AND la_vencidos[3].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 40
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[3].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 103
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[3].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[3].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 160
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
		    
		    IF la_vencidos[6].num_docum IS NOT NULL AND la_vencidos[6].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 225
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[6].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 288
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[6].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[6].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 345
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
			
			IF la_vencidos[9].num_docum IS NOT NULL AND la_vencidos[9].num_docum <> " " THEN
			    LET l_linha  = l_linha
				LET l_coluna = 420
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[9].num_docum
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_linha  = l_linha
				LET l_coluna = 483
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = la_vencidos[9].dat_vencto_s_desc
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
				
				LET l_valor_char = la_vencidos[9].val_saldo
				IF l_valor_char IS NULL OR l_valor_char = " " THEN
					LET l_valor_char = "  0,00"
				END IF
				IF LENGTH(l_valor_char) < 6 THEN
					LET l_valor_char = " ",l_valor_char
				END IF
				LET l_linha  = l_linha
				LET l_coluna = 540
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "R$ ",l_valor_char CLIPPED
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			END IF
		    
			
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    IF l_count > 0 THEN
		        LET l_linha  = l_linha
				LET l_coluna = 40
				LET m_ind = m_ind + 1
				LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 8);"
				LET m_ind = m_ind + 1
				LET l_texto = "****************************Caso o pagamento destas já tenha sido providenciado, favor desconsiderar esta mensagem.***************************"
				LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    END IF
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
		    LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 40
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = geo1013_extenso(lr_dados.valor) CLIPPED
			LET l_texto = l_texto[1,100]
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			
		    
			{LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    }
		    
			
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		   
		    LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 40
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Contato de Locação: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 150
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = lr_dados.cod_contrato CLIPPED
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 400
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Período: "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 450
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "de ",lr_dados.periodo_de," a ",lr_dados.periodo_ate
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			{LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    }
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha
			LET l_coluna = 40
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica-Bold","; 9);"
			LET m_ind = m_ind + 1
			LET l_texto = "Data: _____/_____/__________         Documento: _____________________      Nome Legível: ___________________________ "
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 25
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
			
			LET l_linha  = l_linha
			LET l_coluna = 26
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "___________________________________________________________________________________________________"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    
			LET l_linha  = 415
			LET l_linha2 = 1
			LET l_pagina_atual = 1
		
			let l_conta = 0
			
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		    LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
			LET l_linha  = l_linha - 9
			LET l_coluna = 575
			LET m_ind = m_ind + 1
			LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Helvetica","; 10);"
			LET m_ind = m_ind + 1
			LET l_texto = "|"
			LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto CLIPPED," ; ",l_coluna," ; ",l_linha," ; ","0)",";"
		    
		
				    
		
			LET l_linha  = 790
			LET l_linha2 = 1
			LET l_pagina_atual = 1
		
			let l_conta = 0
			
	
	
	
            
            
            
            
         END FOREACH
      END IF 
   	END FOR
	
	
		
END FUNCTION