#-----------------------------------------------------------------#
# MODULO..: GEO                                                   #
# SISTEMA.: CADASTRO DE MANIFESTO                                 #
# PROGRAMA: geo1016                                               #
# AUTOR...: EVANDRO SIMENES                                       #
# DATA....: 01/03/2016                                            #
#-----------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_versao            CHAR(18)
   DEFINE p_cod_empresa       LIKE empresa.cod_empresa
   DEFINE p_user              LIKE usuarios.cod_usuario

END GLOBALS

   DEFINE m_ind                  INTEGER
   DEFINE m_rotina_automatica    SMALLINT

   DEFINE m_ies_onsulta          SMALLINT
DEFINE ma_resp           ARRAY[5000] OF RECORD
             cod_cliente            LIKE clientes.cod_cliente
           , nom_cliente            LIKE clientes.nom_cliente
                                 END RECORD
DEFINE ma_nf           ARRAY[5000] OF RECORD
             empresa            LIKE fat_nf_mestre.empresa
           , nota_fiscal        LIKE fat_nf_mestre.nota_fiscal
           , serie_nota_fiscal  LIKE fat_nf_mestre.serie_nota_fiscal
           , subserie_nf        LIKE fat_nf_mestre.subserie_nf
           , tip_nota_fiscal    LIKE fat_nf_mestre.tip_nota_fiscal
                                 END RECORD
DEFINE ma_transp           ARRAY[5000] OF RECORD
             cod_fornecedor            LIKE fornecedor.cod_fornecedor
           , raz_social            LIKE fornecedor.raz_social
                                 END RECORD

   DEFINE ma_zclientes           ARRAY[5000] OF RECORD
             cod_cliente            LIKE clientes.cod_cliente
           , nom_cliente            LIKE clientes.nom_cliente
           , num_cgc_cpf            LIKE clientes.num_cgc_cpf
           , den_cidade             LIKE cidades.den_cidade
           , cod_uni_feder          LIKE cidades.cod_uni_feder
                                 END RECORD
  
   define mr_filtro  record 
                cod_roteiro integer
                     end record 
           
   define m_botao_find  char(50) 
   define m_refer_filtro_2 char(50)
   DEFINE m_refer_carregar_nf CHAR(50)
   DEFINE m_refer_tip_manifesto    VARCHAR(50)
         
   DEFINE ma_tela             ARRAY[5000] OF RECORD
             selecionado        CHAR(1)
           , num_nf             LIKE fat_nf_mestre.nota_fiscal
           , ser_nf             LIKE fat_nf_mestre.serie_nota_fiscal
                                 END RECORD

 define mr_tela, mr_telar   record
                         cod_empresa char(2),
                         cod_manifesto   integer,
                         cod_resp LIKE clientes.cod_cliente,
                         den_resp LIKE clientes.nom_cliente,
                         dat_manifesto date,
                         cod_transp LIKE fornecedor.cod_fornecedor,
                         den_transp LIKE fornecedor.raz_social,
                         placa_veic char(8),
                         tip_manifesto CHAR(1),
                         data_de date,
                         data_ate date
                  end record 
                  
 define mr_filtro record
                           cod_empresa char(2),
                           cod_rota     integer,
                           cod_cliente  LIKE clientes.cod_cliente
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
   DEFINE m_column_selecionado         VARCHAR(50)
   define m_column_cod_cliente         varchar(50)

   DEFINE m_refer_cod_empresa          varchar(50)
   DEFINE m_refer_cod_manifesto        varchar(50)
   DEFINE m_refer_cod_resp             varchar(50)
   DEFINE m_refer_den_resp             varchar(50)
   DEFINE m_refer_dat_manifesto        varchar(50)
   DEFINE m_refer_cod_transp           varchar(50)
   DEFINE m_refer_data_de              varchar(50)
   DEFINE m_refer_data_ate             varchar(50)
   DEFINE m_refer_den_transp           varchar(50)
   DEFINE m_refer_placa_veic           varchar(50)
   DEFINE m_zoom_resp                  varchar(50)
   DEFINE m_zoom_transp                varchar(50)
   
   DEFINE m_column_num_nf VARCHAR(50)
   DEFINE m_column_zoom   VARCHAR(50)
   DEFINE m_column_ser_nf VARCHAR(50)
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
   DEFINE m_funcao                     CHAR(20)

#-------------------#
 FUNCTION geo1016()
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
      CALL geo1016_tela()
   END IF

END FUNCTION

#-------------------#
 FUNCTION geo1016_tela()
#-------------------#

   DEFINE l_label  VARCHAR(50)
        , l_splitter                   VARCHAR(50)
        , l_status SMALLINT,
        l_panel_center           VARCHAR(10),
        l_data CHAR(10)
 
     #cria janela principal do tipo LDIALOG
     LET m_form_principal = _ADVPL_create_component(NULL,"LDIALOG")
     CALL _ADVPL_set_property(m_form_principal,"TITLE","CADASTRO DE MANIFESTO")
     CALL _ADVPL_set_property(m_form_principal,"ENABLE_ESC_CLOSE",FALSE)
     CALL _ADVPL_set_property(m_form_principal,"SIZE",824,560)#   1024,725)

     #
     #
     #
     # INICIO MENU

     #cria menu
     LET m_toolbar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_principal)

     #botao INCLUIR
     LET m_botao_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_create,"EVENT","geo1016_incluir")
     CALL _ADVPL_set_property(m_botao_create,"CONFIRM_EVENT","geo1016_confirmar_inclusao")
     CALL _ADVPL_set_property(m_botao_create,"CANCEL_EVENT","geo1016_cancelar_inclusao")

     #botao MODIFICAR
     LET m_botao_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_update,"EVENT","geo1016_modificar")
     CALL _ADVPL_set_property(m_botao_update,"CONFIRM_EVENT","geo1016_confirmar_modificacao")
     CALL _ADVPL_set_property(m_botao_update,"CANCEL_EVENT","geo1016_cancelar_modificacao")

     #botao EXCLUIR
     LET m_botao_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_delete,"EVENT","geo1016_excluir")

     #botao LOCALIZAR
     LET m_botao_find_principal = _ADVPL_create_component(NULL,"LFINDBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_find_principal,"EVENT","geo1016_pesquisar")
     CALL _ADVPL_set_property(m_botao_find_principal,"CONFIRM_EVENT","geo1016_confirmar_pesquisar")
     CALL _ADVPL_set_property(m_botao_find_principal,"CANCEL_EVENT","geo1016_cancelar_modificacao")

     #botao primeiro registro
      LET m_botao_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_first,"EVENT","geo1016_primeiro")
      
      #botao anterior
      LET m_botao_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_previous,"EVENT","geo1016_anterior")
      
      #botao seguinte
      LET m_botao_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_next,"EVENT","geo1016_seguinte")
      
      #botao ultimo registro
      LET m_botao_last = _ADVPL_create_component(NULL,"LLASTBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_last,"EVENT","geo1016_ultimo")
      

     #botao sair
     LET m_botao_quit = _ADVPL_create_component(NULL,"LQUITBUTTON",m_toolbar)


     LET m_status_bar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_principal)

     #  FIM MENU

     
#cria panel para campos de filtro 
      LET m_panel_1 = _ADVPL_create_component(NULL,"LPANEL",m_form_principal)
      CALL _ADVPL_set_property(m_panel_1,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_panel_1,"HEIGHT",450)
      
      
     
     #cria panel  
     LET m_panel_reference1 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel_1)
     CALL _ADVPL_set_property(m_panel_reference1,"TITLE","CADASTRO DE MANIFESTO")
     CALL _ADVPL_set_property(m_panel_reference1,"ALIGN","CENTER")
     #CALL _ADVPL_set_property(m_panel_reference1,"HEIGHT",600)
     
     
     LET m_layoutmanager_refence_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_reference1)
     CALL _ADVPL_set_property(m_layoutmanager_refence_1,"MARGIN",TRUE)
     CALL _ADVPL_set_property(m_layoutmanager_refence_1,"COLUMNS_COUNT",2)

     
     LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
	  CALL _ADVPL_set_property(l_label,"TEXT","Manifesto:")
	  CALL _ADVPL_set_property(l_label,"SIZE",90,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",10,30)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  
     
     
  LET m_refer_cod_manifesto = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_cod_manifesto,"VARIABLE",mr_tela,"cod_manifesto")
  CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_cod_manifesto,"LENGTH",15)
  CALL _ADVPL_set_property(m_refer_cod_manifesto,"VALID","geo1016_valid_cod_manifesto")
  CALL _ADVPL_set_property(m_refer_cod_manifesto,"POSITION",100,29)
      #cria campo den_roteiro
  
  
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Data:")
  CALL _ADVPL_set_property(l_label,"SIZE",90,15)
  CALL _ADVPL_set_property(l_label,"POSITION",300,30)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  
  
  LET mr_tela.dat_manifesto = TODAY
  LET m_refer_dat_manifesto = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_dat_manifesto,"VARIABLE",mr_tela,"dat_manifesto")
  CALL _ADVPL_set_property(m_refer_dat_manifesto,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_dat_manifesto,"BUTTON",FALSE)  
  #CALL _ADVPL_set_property(m_refer_dat_manifesto,"VALID","geo1016_valid_dat_manifesto")
  CALL _ADVPL_set_property(m_refer_dat_manifesto,"POSITION",340,29)
      #cria campo den_roteiro
  
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Placa:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",500,30)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  
  

LET m_refer_placa_veic = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_placa_veic,"VARIABLE",mr_tela,"placa_veic")
  CALL _ADVPL_set_property(m_refer_placa_veic,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_placa_veic,"LENGTH",15)
  CALL _ADVPL_set_property(m_refer_placa_veic,"POSITION",540,29)
      #cria campo den_roteiro
  
  
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Responsável:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",10,60)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  
  

LET m_refer_cod_resp = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_cod_resp,"VARIABLE",mr_tela,"cod_resp")
  CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_cod_resp,"LENGTH",15)
  CALL _ADVPL_set_property(m_refer_cod_resp,"VALID","geo1016_valid_cod_resp")
  CALL _ADVPL_set_property(m_refer_cod_resp,"POSITION",100,59)
      #cria campo den_roteiro
  
  
  LET m_zoom_resp = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_reference1)
  CALL _ADVPL_set_property(m_zoom_resp,"SIZE",24,20)
  CALL _ADVPL_set_property(m_zoom_resp,"IMAGE","BTPESQ")
  CALL _ADVPL_set_property(m_zoom_resp,"TOOLTIP","Zoom Responsável")
  CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_zoom_resp,"CLICK_EVENT","geo1016_zoom_resp")
  CALL _ADVPL_set_property(m_zoom_resp,"POSITION",230,59)

  LET m_refer_den_resp = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_den_resp,"VARIABLE",mr_tela,"den_resp")
  CALL _ADVPL_set_property(m_refer_den_resp,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_den_resp,"LENGTH",30)
  CALL _ADVPL_set_property(m_refer_den_resp,"POSITION",260,59)
  
  
  
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Transportadora:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",10,90)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  LET m_refer_cod_transp = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_cod_transp,"VARIABLE",mr_tela,"cod_transp")
  CALL _ADVPL_set_property(m_refer_cod_transp,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_cod_transp,"LENGTH",15)
  CALL _ADVPL_set_property(m_refer_cod_transp,"VALID","geo1016_valid_cod_transp")
  CALL _ADVPL_set_property(m_refer_cod_transp,"POSITION",100,89)
      #cria campo den_roteiro
  
  
  LET m_zoom_transp = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_reference1)
  CALL _ADVPL_set_property(m_zoom_transp,"SIZE",24,20)
  CALL _ADVPL_set_property(m_zoom_transp,"IMAGE","BTPESQ")
  CALL _ADVPL_set_property(m_zoom_transp,"TOOLTIP","Zoom Transportadora")
  CALL _ADVPL_set_property(m_zoom_transp,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_zoom_transp,"CLICK_EVENT","geo1016_zoom_transp")
  CALL _ADVPL_set_property(m_zoom_transp,"POSITION",230,89)

  LET m_refer_den_transp = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_den_transp,"VARIABLE",mr_tela,"den_transp")
  CALL _ADVPL_set_property(m_refer_den_transp,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_den_transp,"LENGTH",30)
  CALL _ADVPL_set_property(m_refer_den_transp,"POSITION",260,89)
  
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Tipo Manifesto:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",10,120)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  
  LET m_refer_tip_manifesto = _ADVPL_create_component(NULL,"LCOMBOBOX",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_tip_manifesto,"WIDTH",150)
  CALL _ADVPL_set_property(m_refer_tip_manifesto,"POSITION",100,119)
  CALL _ADVPL_set_property(m_refer_tip_manifesto,"VARIABLE",mr_tela,"tip_manifesto")
  CALL _ADVPL_set_property(m_refer_tip_manifesto,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_tip_manifesto,"ADD_ITEM","R","REMESSA")
  CALL _ADVPL_set_property(m_refer_tip_manifesto,"ADD_ITEM","B","BALCAO")
  #CALL _ADVPL_set_property(m_refer_tip_manifesto,"VALID","geo1016_init_load_nf")
  
  
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Periodo de:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",10,150)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  LET m_refer_data_de = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_data_de,"VARIABLE",mr_tela,"data_de")
  CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_data_de,"BUTTON",FALSE)  
  CALL _ADVPL_set_property(m_refer_data_de,"POSITION",100,149)
  #CALL _ADVPL_set_property(m_refer_data_de,"VALID","geo1016_init_load_nf")
  
  
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Até:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",300,150)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  LET m_refer_data_ate = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_data_ate,"VARIABLE",mr_tela,"data_ate")
  CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_data_ate,"BUTTON",FALSE)  
  CALL _ADVPL_set_property(m_refer_data_ate,"POSITION",390,149)
  #CALL _ADVPL_set_property(m_refer_data_ate,"VALID","geo1016_init_load_nf")
  
  #Cria botões Voltar, Avançar (Concluir) e Cancelar
  LET m_refer_carregar_nf = _ADVPL_create_component(NULL, "LBUTTON", m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_carregar_nf,"TEXT", "Carregar NF's")
  CALL _ADVPL_set_property(m_refer_carregar_nf,"CLICK_EVENT","geo1016_init_load_nf")
  CALL _ADVPL_set_property(m_refer_carregar_nf,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_carregar_nf,"SIZE",100,25)
  CALL _ADVPL_set_property(m_refer_carregar_nf,"POSITION",600,145)
  
  
  #cria panel para campos de filtro 
      LET l_panel_center = _ADVPL_create_component(NULL,"LPANEL",m_panel_reference1)
      CALL _ADVPL_set_property(l_panel_center,"ALIGN","BOTTOM")
      CALL _ADVPL_set_property(l_panel_center,"HEIGHT",250)
      
  
  #cria panel  
     LET m_panel_reference2 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel_center)
     CALL _ADVPL_set_property(m_panel_reference2,"TITLE","")
     CALL _ADVPL_set_property(m_panel_reference2,"ALIGN","TOP")
     CALL _ADVPL_set_property(m_panel_reference2,"HEIGHT",250)
     
  
 #cria array
      LET m_table_reference1 = _ADVPL_create_component(NULL,"LBROWSEEX",m_panel_reference2)
      CALL _ADVPL_set_property(m_table_reference1,"SIZE",200,230)
      CALL _ADVPL_set_property(m_table_reference1,"CAN_ADD_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference1,"CAN_REMOVE_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference1,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_table_reference1,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_table_reference1,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_table_reference1,"POSITION",10,120)
	  CALL _ADVPL_set_property(m_table_reference1,"AFTER_ROW_EVENT",'geo1016_after_row')
      
      #cria campo do array: ies_seleciona
      LET m_column_selecionado = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_table_reference1)
      CALL _ADVPL_set_property(m_column_selecionado,"VARIABLE","selecionado")
      CALL _ADVPL_set_property(m_column_selecionado,"HEADER"," ")
      CALL _ADVPL_set_property(m_column_selecionado,"COLUMN_SIZE",10)
      CALL _ADVPL_set_property(m_column_selecionado,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_column_selecionado,"EDIT_COMPONENT","LCHECKBOX")
      CALL _ADVPL_set_property(m_column_selecionado,"EDIT_PROPERTY","VALUE_CHECKED","S")
      CALL _ADVPL_set_property(m_column_selecionado,"EDIT_PROPERTY","VALUE_NCHECKED","N")
      CALL _ADVPL_set_property(m_column_selecionado,"EDIT_PROPERTY","CHANGE_EVENT","geo1016_valid_selecionado")
      CALL _ADVPL_set_property(m_column_selecionado,"IMAGE_HEADER","CHECKED")
      CALL _ADVPL_set_property(m_column_selecionado,"HEADER_CLICK_EVENT","geo1016_header_checkbox")
   
      
      
      #cria campo do array: cod_cliente
      LET m_column_num_nf = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_num_nf,"VARIABLE","num_nf")
      CALL _ADVPL_set_property(m_column_num_nf,"HEADER","NF")
      CALL _ADVPL_set_property(m_column_num_nf,"COLUMN_SIZE", 90)
      CALL _ADVPL_set_property(m_column_num_nf,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_num_nf,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_column_num_nf,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(m_column_num_nf,"EDIT_PROPERTY","VALID","geo1016_valid_num_nf")
      CALL _ADVPL_set_property(m_column_num_nf,"EDITABLE", TRUE)
      
      LET m_column_zoom = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_table_reference1)
      CALL _ADVPL_set_property(m_column_zoom,"COLUMN_SIZE",20)
      CALL _ADVPL_set_property(m_column_zoom,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_column_zoom,"NO_VARIABLE",TRUE)
      CALL _ADVPL_set_property(m_column_zoom,"IMAGE", "BTPESQ")
      CALL _ADVPL_set_property(m_column_zoom,"BEFORE_EDIT_EVENT","geo1016_zoom_nf")
 
      
      #cria campo do array: cod_cliente
      LET m_column_ser_nf = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_ser_nf,"VARIABLE","ser_nf")
      CALL _ADVPL_set_property(m_column_ser_nf,"HEADER","Série")
      CALL _ADVPL_set_property(m_column_ser_nf,"COLUMN_SIZE", 90)
      CALL _ADVPL_set_property(m_column_ser_nf,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_ser_nf,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_column_ser_nf,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(m_column_ser_nf,"EDIT_PROPERTY","VALID","geo1016_valid_cod_item")
      CALL _ADVPL_set_property(m_column_ser_nf,"EDITABLE", TRUE)
      
       	
    # let ma_pedidos[1].num_pedido = '123'
     CALL _ADVPL_set_property(m_table_reference1,"SET_ROWS",ma_tela,0)
     CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)
   
     CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
 

      CALL _ADVPL_set_property(m_form_principal,"ACTIVATE",TRUE)

 END FUNCTION

#---------------------------#
FUNCTION geo1016_incluir()
#---------------------------#
   DEFINE l_data   CHAR(10)
   LET m_funcao = "INCLUSAO"
   INITIALIZE mr_tela.*, ma_tela to null
   LET l_data = "01/",EXTEND(CURRENT, MONTH TO MONTH),"/",EXTEND(CURRENT,YEAR TO YEAR)
   LET mr_tela.data_de = l_data
   LET mr_tela.data_ate = TODAY
   
   SELECT MAX(cod_manifesto)
     INTO mr_tela.cod_manifesto
     FROM geo_manifesto
    WHERE cod_empresa = p_cod_empresa
   IF mr_tela.cod_manifesto IS NULL OR mr_tela.cod_manifesto = "" THEN
      LET mr_tela.cod_manifesto = 0
   END IF 
   
   LET mr_tela.cod_manifesto = mr_tela.cod_manifesto + 1
   LET mr_tela.tip_manifesto = "R"
   
   LET mr_tela.dat_manifesto = TODAY
   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",1)
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
 

   LET mr_tela.cod_empresa  = p_cod_empresa
     

   CALL geo1016_habilita_campos_manutencao(TRUE,'INCLUIR')
   
   
   #CALL geo1016_init_load_nf()
END FUNCTION

#-----------------------------#
 function geo1016_modificar()
#-----------------------------#
   define l_msg char(80)
   LET m_funcao = "MODIFICACAO"
   SELECT DISTINCT cod_empresa
     FROM geo_manifesto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
      AND sit_manifesto <> "E"
   IF sqlca.sqlcode <> 0 THEN
      CALL _ADVPL_message_box("Manifesto já foi encerrado e não pode ser modificado.")
      RETURN FALSE
   END IF

  call geo1016_habilita_campos_manutencao(TRUE,'MODIFICAR')

 end function

#-----------------------------#
 function geo1016_excluir()
#-----------------------------#
   define l_msg char(80)

 SELECT DISTINCT cod_empresa
     FROM geo_manifesto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
      AND sit_manifesto <> "E"
   IF sqlca.sqlcode <> 0 THEN
      CALL _ADVPL_message_box("Manifesto já foi encerrado e não pode ser excluído.")
      RETURN FALSE
   END IF

    let l_msg = 'Confirma a exclusão do manifesto: ', mr_tela.cod_manifesto, '?'
    IF LOG_pergunta(l_msg) THEN
    else
       return false
    end if

       delete from geo_manifesto
       where cod_empresa = p_cod_empresa
         and cod_manifesto = mr_tela.cod_manifesto 
         AND sit_manifesto <> "E" 
       
       delete from geo_remessa_movto
       where cod_empresa = p_cod_empresa
         and cod_manifesto = mr_tela.cod_manifesto
         and tipo_movto = 'E'


  initialize mr_tela.* to null
  initialize ma_tela  to null
  CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)
  CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
 
END FUNCTION
 
#------------------------------------#
function geo1016_confirmar_inclusao()
#------------------------------------#
   DEFINE l_ind         SMALLINT
   DEFINE l_status      SMALLINT
   
   IF mr_tela.cod_manifesto IS NULL OR mr_tela.cod_manifesto = "" THEN
      CALL _ADVPL_message_box("Informe um manifesto")
      RETURN FALSE
   END IF 
   IF mr_tela.cod_resp IS NULL OR mr_tela.cod_resp = "" THEN
      CALL _ADVPL_message_box("Informe um responsável do manifesto")
      RETURN FALSE
   END IF 
   IF mr_tela.dat_manifesto IS NULL OR mr_tela.dat_manifesto = "" THEN
      CALL _ADVPL_message_box("Informe uma data para o manifesto")
      RETURN FALSE
   END IF 
   
   IF mr_tela.tip_manifesto = "R" AND mr_tela.dat_manifesto < TODAY THEN
   	  CALL _ADVPL_message_box("A data do manifestos de remessa não pode ser retroativa.")
   	  RETURN FALSE
   END IF
   
   SELECT DISTINCT cod_empresa
      FROM geo_manifesto
     WHERE cod_empresa = p_cod_empresa
       AND cod_resp = mr_tela.cod_resp
       AND sit_manifesto = "T"
     IF sqlca.sqlcode = 0 THEN
        CALL _ADVPL_message_box("Este responsável já possuí um manifesto em transito.")
        CALL _ADVPL_set_property(m_refer_cod_resp, "FORCE_GET_FOCUS")
        RETURN FALSE
     END IF 
     
     
   #adolar 
	select distinct(a.empresa) 
	
	from fat_nf_mestre a, fat_nf_repr b, geo_repres_paramet c
	where a.empresa = p_cod_empresa
    and a.sit_nota_fiscal = 'N'
	and a.natureza_operacao = 11
	and a.empresa = b.empresa
	and a.trans_nota_fiscal = b.trans_nota_fiscal
	and c.cod_repres = b.representante
	and c.cod_cliente = mr_tela.cod_resp
	and dat_hor_emissao >= mr_tela.data_de
	and dat_hor_emissao <= mr_tela.data_ate
  
	IF sqlca.sqlcode = 0 THEN
        CALL _ADVPL_message_box("Este responsável já possuí nota no período.")
        CALL _ADVPL_set_property(m_refer_cod_resp, "FORCE_GET_FOCUS")
        RETURN FALSE
    END IF 
   #fim  
   
   LET l_status = geo1016_after_row()
   
   IF l_status THEN
      LET l_status = FALSE
      FOR l_ind = 1 TO _ADVPL_get_property(m_table_reference1,"ITEM_COUNT")
         IF ma_tela[l_ind].selecionado = "S" THEN
            LET l_status = TRUE
            EXIT FOR
         END IF 
      END FOR
      
      IF NOT l_status THEN
         CALL _ADVPL_message_box("Selecione ao menos uma NF")
         RETURN FALSE
      END IF 
   ELSE
      RETURN FALSE
   END IF
   
   CALL geo1016_atualiza_dados('INCLUSAO') 
   CALL geo1016_habilita_campos_manutencao(FALSE,'INCLUIR')
   RETURN TRUE
 end function

#---------------------------#
 function  geo1016_cancelar_inclusao()
#---------------------------#
  call geo1016_habilita_campos_manutencao(FALSE,'INCLUIR')
 end function

#---------------------------#
 function geo1016_confirmar_modificacao()
#---------------------------#
   DEFINE l_status       SMALLINT
   DEFINE l_ind          SMALLINT
   IF mr_tela.cod_manifesto IS NULL OR mr_tela.cod_manifesto = "" THEN
      CALL _ADVPL_message_box("Informe um manifesto")
      RETURN FALSE
   END IF 
   IF mr_tela.cod_resp IS NULL OR mr_tela.cod_resp = "" THEN
      CALL _ADVPL_message_box("Informe um responsável do manifesto")
      RETURN FALSE
   END IF 
   IF mr_tela.dat_manifesto IS NULL OR mr_tela.dat_manifesto = "" THEN
      CALL _ADVPL_message_box("Informe uma data para o manifesto")
      RETURN FALSE
   END IF 
   
   
   
   LET l_status = geo1016_after_row()
   
   IF l_status THEN
      LET l_status = FALSE
      FOR l_ind = 1 TO _ADVPL_get_property(m_table_reference1,"ITEM_COUNT")
         IF ma_tela[l_ind].selecionado = "S" THEN
            LET l_status = TRUE
            EXIT FOR
         END IF 
      END FOR
      
      IF NOT l_status THEN
         CALL _ADVPL_message_box("Selecione ao menos uma NF")
         RETURN FALSE
      END IF 
   ELSE
      RETURN FALSE
   END IF
   CALL geo1016_habilita_campos_manutencao(FALSE,'MODIFICAR')
   CALL geo1016_atualiza_dados('MODIFICACAO')
   RETURN TRUE
 end function
#
#---------------------------#
 function  geo1016_cancelar_modificacao()
#---------------------------#
  CALL geo1016_habilita_campos_manutencao(FALSE,'MODIFICAR')
 end function

#----------------------------------------------#
 function geo1016_atualiza_dados(l_funcao)
#----------------------------------------------#
   DEFINE l_funcao char(20)
   DEFINE l_ind    integer
   DEFINE l_data   date
   DEFINE l_hora   char(8)
   DEFINE l_trans_remessa INTEGER
   DEFINE l_cod_item char(15)
   DEFINE l_qtd_item LIKE fat_nf_item.qtd_item
   
   LET l_data = TODAY
   LET l_hora = TIME
   
   CALL log085_transacao('BEGIN')
   
   IF l_funcao = 'MODIFICACAO' then
      DELETE FROM geo_remessa_movto
       WHERE cod_empresa = p_cod_empresa
         AND cod_manifesto = mr_tela.cod_manifesto
         AND tipo_movto = 'E'
      
      UPDATE geo_manifesto
         SET cod_resp = mr_tela.cod_resp,
             dat_manifesto = mr_tela.dat_manifesto,
             cod_transp = mr_tela.cod_transp,
             placa_veic = mr_tela.placa_veic
       WHERE cod_empresa = p_cod_empresa
         AND cod_manifesto = mr_tela.cod_manifesto
   ELSE
      
      INSERT INTO geo_manifesto VALUES (p_cod_empresa, 
      									mr_tela.cod_manifesto, 
      									mr_tela.cod_resp, 
      									mr_tela.dat_manifesto, 
      									mr_tela.cod_transp, 
      									mr_tela.placa_veic,
      									"T",
      									mr_tela.tip_manifesto,
      									mr_tela.data_de,
      									mr_tela.data_ate,
      									NULL)

   END IF 

   FOR l_ind = 1 to 5000
      IF ma_tela[l_ind].selecionado = "S" THEN
         
         DECLARE cq_nf CURSOR WITH HOLD FOR
         SELECT a.trans_nota_fiscal, b.item, b.qtd_item
           INTO l_trans_remessa, l_cod_item, l_qtd_item
           FROM fat_nf_mestre a, fat_nf_item b
          WHERE a.empresa = b.empresa
            AND a.trans_nota_fiscal = b.trans_nota_fiscal
            AND a.empresa = p_cod_empresa
            AND a.nota_fiscal = ma_tela[l_ind].num_nf
            AND a.serie_nota_fiscal = ma_tela[l_ind].ser_nf
         
      
         FOREACH cq_nf INTO l_trans_remessa, l_cod_item, l_qtd_item
      
	         INSERT INTO geo_remessa_movto VALUES (p_cod_empresa,
	      										   mr_tela.cod_manifesto,
	      										   ma_tela[l_ind].num_nf,
	      										   ma_tela[l_ind].ser_nf,
	      										   l_trans_remessa,
	      										   "E",
	      										   l_cod_item,
	      										   l_qtd_item,
	      										   NULL,
	      										   NULL,
	      										   NULL,
	      										   TODAY)
	     END FOREACH
	  END IF
	      										
   END FOR
 
   CALL log085_transacao('COMMIT')
   
END FUNCTION

#----------------------------------------------#
 function geo1016_habilita_campos_manutencao(l_status,l_funcao)
#----------------------------------------------#

   DEFINE l_status smallint
   
   define l_funcao char(20)

   if l_funcao = 'CONSULTAR' then
      CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",l_status) 
   end if
   
   CALL _ADVPL_set_property(m_table_reference1,"CAN_ADD_ROW",l_status)
   CALL _ADVPL_set_property(m_table_reference1,"CAN_REMOVE_ROW",l_status)
   CALL _ADVPL_set_property(m_table_reference1,"EDITABLE",l_status)
   
   CALL _ADVPL_set_property(m_refer_cod_transp,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_tip_manifesto,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",l_status)
   #CALL _ADVPL_set_property(m_refer_den_transp,"ENABLE",l_status)
   #CALL _ADVPL_set_property(m_refer_den_resp,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_table_reference1,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_carregar_nf,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_zoom_transp,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_dat_manifesto,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_placa_veic,"ENABLE",l_status)
   
#   seq_visita

END FUNCTION
#
       
#---------------------------#
FUNCTION geo1016_pesquisar()
#---------------------------#
   LET m_funcao = "CONSULTA"
   INITIALIZE mr_tela.*, ma_tela to null
   
   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",1)
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
 
   LET mr_tela.cod_empresa  = p_cod_empresa
   CALL geo1016_habilita_campos_manutencao(TRUE,'CONSULTAR')

END FUNCTION
 
#-------------------------------------#
 FUNCTION geo1016_primeiro()
#-------------------------------------#
    CALL geo1016_paginacao("PRIMEIRO")
 end function

#-------------------------------------#
 FUNCTION geo1016_anterior()
#-------------------------------------#
   CALL geo1016_paginacao("ANTERIOR")
 end function

#-------------------------------------#
 FUNCTION geo1016_seguinte()
#-------------------------------------#
     CALL geo1016_paginacao("SEGUINTE")
 end function

#-------------------------------------#
 FUNCTION geo1016_ultimo()
#-------------------------------------#
    CALL geo1016_paginacao("ULTIMO")
 end function
#--------------------------------------#
FUNCTION geo1016_confirmar_pesquisar()
#--------------------------------------#
   DEFINE l_sql             CHAR(999)
   
   LET l_sql = " SELECT cod_empresa, ",
               "        cod_manifesto, ",
               "        cod_resp, ",
               "        '', ",
               "        dat_manifesto, ",
               "        cod_transp, ",
               "        '', ",
               "        placa_veic, ",
               "        tip_manifesto, ",
               "        periodo_de, ",
               "        periodo_ate ",
               "   FROM geo_manifesto ",
               "  WHERE cod_empresa = '",p_cod_empresa,"'"
   
   IF ma_tela[1].num_nf IS NOT NULL AND ma_tela[1].num_nf <> " " AND ma_tela[1].num_nf <> 0 THEN
      LET l_sql = l_sql CLIPPED," AND cod_manifesto IN ",
                                "    (SELECT DISTINCT cod_manifesto ",
                                "       FROM geo_remessa_movto ",
                                "      WHERE cod_empresa = '",p_cod_empresa,"'",
                                "        AND num_remessa = '",ma_tela[1].num_nf,"')"
   END IF
   IF mr_tela.cod_manifesto IS NOT NULL AND mr_tela.cod_manifesto <> " " AND mr_tela.cod_manifesto <> 0 THEN
      LET l_sql = l_sql CLIPPED,
                  " AND cod_manifesto = '",mr_tela.cod_manifesto,"'"
   END IF 
   
   IF mr_tela.dat_manifesto IS NOT NULL AND mr_tela.dat_manifesto <> " " THEN
      LET l_sql = l_sql CLIPPED,
                  " AND dat_manifesto = '",mr_tela.dat_manifesto,"'"
   END IF
   
   IF mr_tela.placa_veic IS NOT NULL AND mr_tela.placa_veic <> " " THEN
      LET l_sql = l_sql CLIPPED,
                  " AND placa_veic = '",mr_tela.placa_veic,"'"
   END IF
   
   IF mr_tela.cod_resp IS NOT NULL AND mr_tela.cod_resp <> " " THEN
      LET l_sql = l_sql CLIPPED,
                  " AND cod_resp = '",mr_tela.cod_resp,"'"
   END IF
   
   IF mr_tela.cod_transp IS NOT NULL AND mr_tela.cod_transp <> " " THEN
      LET l_sql = l_sql CLIPPED,
                  " AND cod_transp = '",mr_tela.cod_transp,"'"
   END IF
   
   PREPARE var_sql FROM l_sql
   DECLARE cq_consulta SCROLL CURSOR FOR var_sql
   OPEN cq_consulta
   FETCH FIRST cq_consulta INTO mr_tela.*
   
   IF sqlca.sqlcode <> 0 THEN
      CALL _ADVPL_message_box("Argumentos de pesquisa não encontrados")
      CALL geo1016_habilita_campos_manutencao(FALSE, "CONSULTAR")
      RETURN FALSE
   END IF 
   
   SELECT nom_cliente
     INTO mr_tela.den_resp
     FROM clientes
    WHERE cod_cliente = mr_tela.cod_resp
    
   SELECT raz_social
     INTO mr_tela.den_transp
     FROM fornecedor
    WHERE cod_fornecedor = mr_tela.cod_transp
   
   LET m_ies_onsulta = TRUE
   CALL geo1016_carrega_nfs(mr_tela.cod_manifesto)
   CALL geo1016_habilita_campos_manutencao(FALSE, "CONSULTAR")
END FUNCTION

#
#-------------------------------------#
 FUNCTION geo1016_paginacao(l_funcao)
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
            CALL geo1016_exibe_mensagem_barra_status("Não existem mais itens nesta direcao.","ERRO")
            let mr_tela.* = mr_telar.*
            EXIT WHILE
         ELSE
            LET m_ies_onsulta = TRUE
         END IF

         SELECT cod_empresa, 
               cod_manifesto, 
               cod_resp, 
               '', 
               dat_manifesto, 
               cod_transp, 
               '', 
               placa_veic,
               tip_manifesto,
               periodo_de,
               periodo_ate
           INTO mr_tela.*
          from geo_manifesto
         where cod_empresa = p_cod_empresa
           AND cod_manifesto = mr_tela.cod_manifesto  

         IF sqlca.sqlcode = 0 THEN
            SELECT nom_cliente
		      INTO mr_tela.den_resp
		      FROM clientes
		     WHERE cod_cliente = mr_tela.cod_resp
		    
		    SELECT raz_social
		      INTO mr_tela.den_transp
		      FROM fornecedor
		     WHERE cod_fornecedor = mr_tela.cod_transp
            
            EXIT WHILE
         END IF

      END WHILE
   ELSE
      CALL geo1016_exibe_mensagem_barra_status("Efetue primeiramente a consulta.","ERRO")
   END IF
   
   CALL geo1016_carrega_nfs(mr_tela.cod_manifesto)

 END FUNCTION
 
 #--------------------------------------------------------------------#
 FUNCTION geo1016_exibe_mensagem_barra_status(l_mensagem,l_tipo_mensagem)
#--------------------------------------------------------------------#

   DEFINE l_mensagem               CHAR(500),
          l_tipo_mensagem          CHAR(010),
          l_tipo_mensagem_original CHAR(015)

   LET l_tipo_mensagem_original = LOG_retorna_tipo_mensagem_original(UPSHIFT(l_tipo_mensagem),TRUE)
   CALL _ADVPL_set_property(m_status_bar,l_tipo_mensagem_original CLIPPED," "||l_mensagem CLIPPED)

 END FUNCTION

#--------------------------------------------------------------------#
 function geo1016_valid_cod_manifesto()
#--------------------------------------------------------------------#
   
   IF m_funcao <> "CONSULTA" THEN
      SELECT cod_manifesto
        FROM geo_manifesto
       WHERE cod_empresa = p_cod_empresa
         AND cod_manifesto = mr_tela.cod_manifesto

      IF sqlca.sqlcode = 0 THEN
         CALL _ADVPL_message_box("Manifesto já cadastrado.")
         RETURN FALSE
      END IF
   END IF
   return true 
 end function 
 
 #-------------------------------#
 FUNCTION geo1016_valid_cod_resp()
 #-------------------------------#
    DEFINE l_cont           SMALLINT
    IF m_funcao <> "CONSULTA" THEN
        SELECT nom_cliente
	      INTO mr_tela.den_resp
	      FROM clientes
	     WHERE cod_cliente = mr_tela.cod_resp
	    IF sqlca.sqlcode <> 0 THEN
	       CALL _ADVPL_message_box("Cliente não cadastrado.")
	       RETURN FALSE
	    END IF
	    
	    LET l_cont = 0
	    SELECT COUNT(*)
	      INTO l_cont
	      FROM geo_manifesto
	     WHERE cod_empresa = p_cod_empresa
	       AND cod_resp = mr_tela.cod_resp
	       AND sit_manifesto = "T"
	     IF l_cont > 0 THEN
	        CALL _ADVPL_message_box("Este responsável já possuí um manifesto em transito.")
	        LET mr_tela.cod_resp = ""
	        LET mr_tela.den_resp = ""
	        CALL _ADVPL_set_property(m_refer_cod_resp,"REFRESH")
	        CALL _ADVPL_set_property(m_refer_den_resp,"REFRESH")
	        CALL _ADVPL_set_property(m_refer_placa_veic, "FORCE_GET_FOCUS")
	        RETURN FALSE
	     END IF 
    END IF 
    
    
 	RETURN TRUE
 END FUNCTION
 
 
 #----------------------------------#
 FUNCTION geo1016_valid_cod_transp() 
 #----------------------------------#
    IF m_funcao <> "CONSULTA" THEN
	    IF mr_tela.cod_transp IS NOT NULL AND mr_tela.cod_transp <> "" THEN
	       SELECT raz_social
	         INTO mr_tela.den_transp
	         FROM fornecedor
	        WHERE cod_fornecedor = mr_tela.cod_transp
	       IF sqlca.sqlcode <> 0 THEN
	          CALL _ADVPL_message_box("Transportadora não cadastrado.")
	          RETURN FALSE
	       END IF
	    END IF  
	END IF 
 	RETURN TRUE
    
 END FUNCTION
 
 #---------------------------------------#
 function geo1016_zoom_resp()
#---------------------------------------#
   DEFINE l_where_clause   CHAR(1000)
   DEFINE l_ind            SMALLINT
   define l_zoom_item varchar(10)
   define l_selecao integer 
   define l_cod_cliente char(15)
   
    FOR l_ind = 1 TO 1000
       INITIALIZE ma_resp[l_ind].* TO NULL
    END FOR

    LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
    CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
    CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_resp)
    CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_clientes")
    
    let mr_tela.cod_resp = ma_resp[1].cod_cliente
    let mr_tela.den_resp = ma_resp[1].nom_cliente
    
    CALL geo1016_valid_cod_resp()
    #CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",l_ind)
    #CALL _ADVPL_set_property(m_table_reference1,"REFRESH")

 end function
#

#---------------------------------------#
 function geo1016_zoom_transp()
#---------------------------------------#
   DEFINE l_where_clause   CHAR(1000)
   DEFINE l_ind            SMALLINT
   define l_zoom_item varchar(10)
   define l_selecao integer 
   define l_cod_cliente char(15)
   
    FOR l_ind = 1 TO 1000
       INITIALIZE ma_transp[l_ind].* TO NULL
    END FOR

    LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
    CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
    CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_transp)
    CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_fornecedor")
    
    let mr_tela.cod_transp = ma_transp[1].cod_fornecedor
    let mr_tela.den_transp = ma_transp[1].raz_social
    
    #CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",l_ind)
    #CALL _ADVPL_set_property(m_table_reference1,"REFRESH")

 end function
#

#-------------------------#
FUNCTION geo1016_zoom_nf()
#-------------------------#
   DEFINE l_where_clause   CHAR(1000)
   DEFINE l_ind            SMALLINT
   DEFINE l_arr_curr       SMALLINT
   DEFINE l_arr_count      SMALLINT
   define l_zoom_item      varchar(10)
   define l_selecao        integer 
   define l_cod_cliente    char(15)
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   LET l_arr_count = _ADVPL_get_property(m_table_reference1,"ITEM_COUNT")
   
    FOR l_ind = 1 TO 1000
       INITIALIZE ma_nf[l_ind].* TO NULL
    END FOR

    LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
    CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
    CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_nf)
    CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_fat_nf_mestre")
    
    let ma_tela[l_arr_curr].num_nf = ma_nf[1].nota_fiscal
    let ma_tela[l_arr_curr].ser_nf = ma_nf[1].serie_nota_fiscal
    
    CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",l_arr_count)
    CALL _ADVPL_set_property(m_table_reference1,"REFRESH")

END FUNCTION


#------------------------------#
FUNCTION geo1016_after_row()
#------------------------------#
   DEFINE l_ind           SMALLINT
   DEFINE l_arr_curr      SMALLINT
   DEFINE l_arr_count     SMALLINT
   DEFINE l_parametro     CHAR(99)
   DEFINE l_status        SMALLINT
   DEFINE l_count         INTEGER
   DEFINE l_tem_remessa   SMALLINT
   
   {LET l_tem_remessa = FALSE
   
   LET l_arr_curr  = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   LET l_arr_count = _ADVPL_get_property(m_table_reference1,"ITEM_COUNT")
   
   #CALL _ADVPL_message_box("stst "||l_arr_curr||" - "||l_arr_count)
   
   CALL log2250_busca_parametro(p_cod_empresa,'geo_nat_oper_remessa')
   RETURNING l_parametro, l_status
   IF l_parametro IS NULL OR l_parametro = " " THEN
      LET l_parametro = "10"
   END IF 
   
   
   FOR l_ind = 1 TO l_arr_count
   
      SELECT COUNT(*)
        INTO l_count
        FROM fat_nf_mestre
       WHERE empresa = p_cod_empresa
         AND nota_fiscal = ma_tela[l_arr_curr].num_nf
         AND serie_nota_fiscal = ma_tela[l_arr_curr].ser_nf
         AND natureza_operacao = l_parametro
      IF l_count > 0 THEN
         IF l_ind > 1 THEN
            CALL _ADVPL_message_box("Não é possível adicionar NF de remessa "||ma_tela[l_arr_curr].num_nf||" em um manifesto que contém mais que 1 NF.")
            LET ma_tela[l_arr_curr].num_nf = NULL
            LET ma_tela[l_arr_curr].ser_nf = NULL 
            CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",l_arr_count-1)
            CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
            RETURN FALSE
         ELSE
            LET l_tem_remessa = TRUE
         END IF 
      END IF 
      
      IF l_ind <> l_arr_curr THEN
         IF ma_tela[l_arr_curr].num_nf IS NOT NULL AND ma_tela[l_arr_curr].num_nf <> "" OR ma_tela[l_arr_curr].num_nf <> 0 THEN
            IF ma_tela[l_arr_curr].num_nf = ma_tela[l_ind].num_nf AND ma_tela[l_arr_curr].ser_nf = ma_tela[l_ind].ser_nf THEN
               CALL _ADVPL_message_box("Nota fiscal já foi informada neste manifesto")
               INITIALIZE ma_tela[l_arr_curr].* TO NULL
               CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
               RETURN FALSE
            END IF 
         END IF  
      END IF 
   END FOR
   
   SELECT DISTINCT cod_empresa
     FROM geo_remessa_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_remessa = ma_tela[l_arr_curr].num_nf
      AND ser_remessa = ma_tela[l_arr_curr].ser_nf
   IF sqlca.sqlcode = 0 THEN
      CALL _ADVPL_message_box("Nota fiscal já foi informada em outro manifesto")
      INITIALIZE ma_tela[l_arr_curr].* TO NULL
      CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
      RETURN FALSE
   END IF 
   
   
   
   IF l_tem_remessa THEN
      IF l_arr_count > 1 THEN
         CALL _ADVPL_message_box("Este manifesto já contém uma NF de Remessa. Não será permitido mais que 1 NF para este manifesto.")
         CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",1)
         CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
         RETURN FALSE
      END IF 
   END IF 
   	
   }
   RETURN TRUE
   
END FUNCTION




#--------------------------------------------#
FUNCTION geo1016_carrega_nfs(l_cod_manifesto)
#--------------------------------------------#
   DEFINE l_cod_manifesto          INTEGER
   DEFINE l_ind                    INTEGER
   
   INITIALIZE ma_tela TO NULL
   DECLARE cq_nfs CURSOR FOR
   SELECT DISTINCT 'S', num_remessa, ser_remessa
     FROM geo_remessa_movto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = l_cod_manifesto
      AND tipo_movto = "E"
   
   LET l_ind = 1
   FOREACH cq_nfs INTO ma_tela[l_ind].*
      LET l_ind = l_ind + 1
   END FOREACH
   
   IF l_ind > 1 THEN
      LET l_ind = l_ind - 1
   END IF 
   
   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",l_ind)
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
   
END FUNCTION

#------------------------------#
FUNCTION geo1016_init_load_nf()
#------------------------------#
   INITIALIZE ma_tela TO NULL
   CALL LOG_progress_start(" Processando...","geo1016_load_nf","PROCESS")
   CALL LOG_progress_finish(TRUE)
END FUNCTION
#--------------------------#
FUNCTION geo1016_load_nf()
#--------------------------#
   DEFINE l_sql    CHAR(999)
   DEFINE l_status    INTEGER
   DEFINE l_parametro CHAR(99)
   DEFINE l_ind       SMALLINT
   DEFINE l_cod_repres DECIMAL(4,0)
   
   LET l_sql = "   nota_fiscal, serie_nota_fiscal ",
               "   FROM fat_nf_mestre ",
               "  WHERE empresa = '",p_cod_empresa,"'",
               "    AND sit_nota_fiscal = 'N'",
               "    AND trans_nota_fiscal NOT IN (SELECT trans_remessa ", 
                                                 "  FROM geo_remessa_movto ",
                                                 " WHERE cod_empresa = fat_nf_mestre.empresa ",
                                                 "   AND tipo_movto = 'E' ",
                                                 "   AND trans_remessa = fat_nf_mestre.trans_nota_fiscal) "
               
   CALL log2250_busca_parametro(p_cod_empresa,'geo_nat_oper_remessa')
   RETURNING l_parametro, l_status
   IF l_parametro IS NULL OR l_parametro = " " THEN
      LET l_parametro = "10"
   END IF 
   
   IF mr_tela.tip_manifesto = "R" THEN
      SELECT cod_repres
        INTO l_cod_repres
        FROM geo_repres_paramet
       WHERE cod_cliente = mr_tela.cod_resp
      IF sqlca.sqlcode <> 0 THEN
         CALL _ADVPL_message_box("Parametros do representante não encontrados na tabela geo_repres_paramet para o código cliente "||mr_tela.cod_resp)
      END IF
      LET l_sql = " SELECT 'N', ",l_sql CLIPPED, 
                  " AND natureza_operacao = '",l_parametro CLIPPED,"'",
                  " AND dat_hor_saida >= '",mr_tela.data_de,"'",
                  " AND dat_hor_saida <= '",mr_tela.data_ate," 23:59:59'",
                  " AND trans_nota_fiscal IN (SELECT trans_nota_fiscal ",
                                             "  FROM fat_nf_repr ",
                                             " WHERE empresa = fat_nf_mestre.empresa ",
                                             "   AND trans_nota_fiscal = fat_nf_mestre.trans_nota_fiscal ",
                                             "   AND representante = '",l_cod_repres,"')"
   ELSE
      LET l_sql = " SELECT 'S', ",l_sql CLIPPED, " AND natureza_operacao <> '",l_parametro CLIPPED,"'",
                  "    AND dat_hor_emissao >= '",mr_tela.data_de,"'",
                  "    AND dat_hor_emissao <= '",mr_tela.data_ate," 23:59:59'"
   END IF 
   
   PREPARE var_load FROM l_sql
   DECLARE cq_load CURSOR FOR var_load
   
   LET l_ind = 1
   FOREACH cq_load INTO ma_tela[l_ind].*
      LET l_ind = l_ind + 1
   END FOREACH
   
   IF l_ind > 1 THEN
      LET l_ind = l_ind -1
   END IF
   
   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",l_ind)
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
   
END FUNCTION

#---------------------------------#
FUNCTION geo1016_header_checkbox()
#---------------------------------#
   DEFINE l_ind            SMALLINT
   DEFINE l_char           CHAR(1)
   
   IF m_funcao = "INCLUSAO" THEN
      IF ma_tela[1].selecionado = "S" THEN
         LET l_char = "N"
      ELSE
         LET l_char = "S"
      END IF
   
      FOR l_ind = 1 TO _ADVPL_get_property(m_table_reference1,"ITEM_COUNT")
         LET ma_tela[l_ind].selecionado = l_char
      END FOR
   
      CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
   END IF 
END FUNCTION


#-----------------------------------#
FUNCTION geo1016_valid_selecionado()
#-----------------------------------#
   DEFINE l_ind           SMALLINT
   DEFINE l_arr_curr      SMALLINT
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   
   IF mr_tela.tip_manifesto = "R" THEN
      FOR l_ind = 1 TO _ADVPL_get_property(m_table_reference1,"ITEM_COUNT")
         IF l_ind <> l_arr_curr THEN
            LET ma_tela[l_ind].selecionado = "N"
         END IF 
      END FOR
   END IF
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")

END FUNCTION

#-------------------------------------#
FUNCTION geo1016_valid_dat_manifesto()
#-------------------------------------#
	IF m_funcao <> "CONSULTA" THEN
		IF mr_tela.dat_manifesto < TODAY THEN
			CALL _ADVPL_message_box("Data do manifesto não pode ser retroativa.")
			RETURN FALSE
		END IF
	END IF
	RETURN TRUE
END FUNCTION