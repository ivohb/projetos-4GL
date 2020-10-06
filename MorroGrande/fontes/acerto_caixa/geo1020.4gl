#-----------------------------------------------------------------#
# MODULO..: GEO                                                   #
# SISTEMA.: RETORNO DE CARGA                                      #
# PROGRAMA: geo1020                                               #
# AUTOR...: EVANDRO SIMENES                                       #
# DATA....: 17/03/2016                                            #
#-----------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_versao            CHAR(18)
   DEFINE p_cod_empresa       LIKE empresa.cod_empresa
   DEFINE p_user              LIKE usuarios.cod_usuario

END GLOBALS

   DEFINE m_ind                  INTEGER
   DEFINE m_rotina_automatica    SMALLINT
   DEFINE m_ind_carga		 INTEGER
   
   DEFINE ma_carga ARRAY[999] OF RECORD
              num_remessa   LIKE fat_nf_mestre.nota_fiscal,
              ser_remessa   LIKE fat_nf_mestre.serie_nota_fiscal,
              cod_item      CHAR(15),
              den_item      CHAR(76),
              unid_med      CHAR(3),
              qtd_remessa   DECIMAL(17,6),
              qtd_vendido   DECIMAL(17,6),
              qtd_diferenca DECIMAL(17,6),
              qtd_retornado DECIMAL(17,6),
              val_unit      DECIMAL(17,6),
              val_tot       DECIMAL(17,6),
              base_icms     DECIMAL(17,6),
              val_icms      DECIMAL(17,6),
              base_st       DECIMAL(17,6),
              val_st       DECIMAL(17,6)
           END RECORD
   define m_carga_num_remessa          varchar(50)
   define m_carga_ser_remessa          varchar(50)
   define m_carga_cod_item             varchar(50)
   define m_carga_den_item             varchar(50)
   define m_carga_um                   varchar(50)
   define m_carga_qtd_remessa          varchar(50)
   define m_carga_qtd_vendido          varchar(50)
   define m_carga_qtd_retornado        varchar(50)
   define m_carga_val_unit        varchar(50)
   define m_carga_val_tot        varchar(50)
   define m_carga_base_icms        varchar(50)
   define m_carga_val_icms        varchar(50)
   define m_carga_base_st        varchar(50)
   define m_carga_val_st        varchar(50)
   define m_carga_qtd_diferenca        varchar(50)
   

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
         
   DEFINE ma_tela             ARRAY[5000] OF RECORD
             num_nf             LIKE fat_nf_mestre.nota_fiscal
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
                         placa_veic char(8)
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
   define m_column_cod_cliente         varchar(50)

   DEFINE m_refer_cod_empresa          varchar(50)
   DEFINE m_refer_cod_manifesto        varchar(50)
   DEFINE m_refer_cod_resp             varchar(50)
   DEFINE m_refer_den_resp             varchar(50)
   DEFINE m_refer_dat_manifesto        varchar(50)
   DEFINE m_refer_cod_transp           varchar(50)
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

#-------------------#
 FUNCTION geo1020()
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
      CALL geo1020_tela()
   END IF

END FUNCTION

#-------------------#
 FUNCTION geo1020_tela()
#-------------------#

   DEFINE l_label  VARCHAR(50)
        , l_splitter                   VARCHAR(50)
        , l_status SMALLINT,
        l_panel_center           VARCHAR(10)
 
 
 
     #cria janela principal do tipo LDIALOG
     LET m_form_principal = _ADVPL_create_component(NULL,"LDIALOG")
     CALL _ADVPL_set_property(m_form_principal,"TITLE","INFORME DE CARGA RETORNADA")
     CALL _ADVPL_set_property(m_form_principal,"ENABLE_ESC_CLOSE",FALSE)
     CALL _ADVPL_set_property(m_form_principal,"SIZE",1024,625)#   1024,725)

     #
     #
     #
     # INICIO MENU

     #cria menu
     LET m_toolbar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_principal)

     {#botao INCLUIR
     LET m_botao_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_create,"EVENT","geo1020_incluir")
     CALL _ADVPL_set_property(m_botao_create,"CONFIRM_EVENT","geo1020_confirmar_inclusao")
     CALL _ADVPL_set_property(m_botao_create,"CANCEL_EVENT","geo1020_cancelar_inclusao")}

     #botao MODIFICAR
     LET m_botao_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_update,"EVENT","geo1020_modificar")
     CALL _ADVPL_set_property(m_botao_update,"CONFIRM_EVENT","geo1020_confirmar_modificacao")
     CALL _ADVPL_set_property(m_botao_update,"CANCEL_EVENT","geo1020_cancelar_modificacao")

     {#botao EXCLUIR
     LET m_botao_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_delete,"EVENT","geo1020_excluir")}

     #botao LOCALIZAR
     LET m_botao_find_principal = _ADVPL_create_component(NULL,"LFINDBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_find_principal,"EVENT","geo1020_pesquisar")
     CALL _ADVPL_set_property(m_botao_find_principal,"CONFIRM_EVENT","geo1020_confirmar_pesquisar")
     CALL _ADVPL_set_property(m_botao_find_principal,"CANCEL_EVENT","geo1020_cancelar_pesquisar")
     
     #botao primeiro registro
      LET m_botao_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_first,"EVENT","geo1020_primeiro")
      
      #botao anterior
      LET m_botao_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_previous,"EVENT","geo1020_anterior")
      
      #botao seguinte
      LET m_botao_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_next,"EVENT","geo1020_seguinte")
      
      #botao ultimo registro
      LET m_botao_last = _ADVPL_create_component(NULL,"LLASTBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_last,"EVENT","geo1020_ultimo")
      

     #botao sair
     LET m_botao_quit = _ADVPL_create_component(NULL,"LQUITBUTTON",m_toolbar)


     LET m_status_bar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_principal)

     #  FIM MENU

     
#cria panel para campos de filtro 
      LET m_panel_1 = _ADVPL_create_component(NULL,"LPANEL",m_form_principal)
      CALL _ADVPL_set_property(m_panel_1,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_panel_1,"HEIGHT",518)
      
      
     
     #cria panel  
     LET m_panel_reference1 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel_1)
     CALL _ADVPL_set_property(m_panel_reference1,"TITLE","INFORME DE CARGA RETORNADA")
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
  CALL _ADVPL_set_property(m_refer_cod_manifesto,"POSITION",100,29)
      #cria campo den_roteiro
  
  
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Data:")
  CALL _ADVPL_set_property(l_label,"SIZE",90,15)
  CALL _ADVPL_set_property(l_label,"POSITION",300,30)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  
  
  
  LET m_refer_dat_manifesto = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_dat_manifesto,"VARIABLE",mr_tela,"dat_manifesto")
  CALL _ADVPL_set_property(m_refer_dat_manifesto,"ENABLE",FALSE)
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
  CALL _ADVPL_set_property(m_refer_cod_resp,"VALID","geo1020_valid_cod_resp")
  CALL _ADVPL_set_property(m_refer_cod_resp,"POSITION",100,59)
      #cria campo den_roteiro
  
  
  LET m_zoom_resp = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_reference1)
  CALL _ADVPL_set_property(m_zoom_resp,"SIZE",24,20)
  CALL _ADVPL_set_property(m_zoom_resp,"IMAGE","BTPESQ")
  CALL _ADVPL_set_property(m_zoom_resp,"TOOLTIP","Zoom Responsável")
  CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_zoom_resp,"CLICK_EVENT","geo1020_zoom_resp")
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
  CALL _ADVPL_set_property(m_refer_cod_transp,"VALID","geo1020_valid_cod_transp")
  CALL _ADVPL_set_property(m_refer_cod_transp,"POSITION",100,89)
      #cria campo den_roteiro
  
  
  LET m_zoom_transp = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_reference1)
  CALL _ADVPL_set_property(m_zoom_transp,"SIZE",24,20)
  CALL _ADVPL_set_property(m_zoom_transp,"IMAGE","BTPESQ")
  CALL _ADVPL_set_property(m_zoom_transp,"TOOLTIP","Zoom Transportadora")
  CALL _ADVPL_set_property(m_zoom_transp,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_zoom_transp,"CLICK_EVENT","geo1020_zoom_transp")
  CALL _ADVPL_set_property(m_zoom_transp,"POSITION",230,89)

  LET m_refer_den_transp = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_den_transp,"VARIABLE",mr_tela,"den_transp")
  CALL _ADVPL_set_property(m_refer_den_transp,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_den_transp,"LENGTH",30)
  CALL _ADVPL_set_property(m_refer_den_transp,"POSITION",260,89)
  
  
  
  #cria panel para campos de filtro 
      LET l_panel_center = _ADVPL_create_component(NULL,"LPANEL",m_panel_reference1)
      CALL _ADVPL_set_property(l_panel_center,"ALIGN","BOTTOM")
      CALL _ADVPL_set_property(l_panel_center,"HEIGHT",380)
      
  
  #cria panel  
     LET m_panel_reference2 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel_center)
     CALL _ADVPL_set_property(m_panel_reference2,"TITLE","")
     CALL _ADVPL_set_property(m_panel_reference2,"ALIGN","TOP")
     CALL _ADVPL_set_property(m_panel_reference2,"HEIGHT",380)
  
      #cria array
      LET m_table_reference1 = _ADVPL_create_component(NULL,"LBROWSEEX",m_panel_reference2)
      CALL _ADVPL_set_property(m_table_reference1,"SIZE",800,360)
      CALL _ADVPL_set_property(m_table_reference1,"CAN_ADD_ROW",TRUE)
      CALL _ADVPL_set_property(m_table_reference1,"CAN_REMOVE_ROW",TRUE)
      CALL _ADVPL_set_property(m_table_reference1,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_table_reference1,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_table_reference1,"ENABLE",TRUE)
	  CALL _ADVPL_set_property(m_table_reference1,"POSITION",10,10)

      #cria campo do array: cod_cliente
      LET m_carga_num_remessa = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_carga_num_remessa,"VARIABLE","num_remessa")
      CALL _ADVPL_set_property(m_carga_num_remessa,"HEADER","Remessa")
      CALL _ADVPL_set_property(m_carga_num_remessa,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(m_carga_num_remessa,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_num_remessa,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_num_remessa,"EDIT_PROPERTY","LENGTH",10) 
      CALL _ADVPL_set_property(m_carga_num_remessa,"EDITABLE", FALSE)
      
      
      #cria campo do array: cod_cliente
      LET m_carga_ser_remessa = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_carga_ser_remessa,"VARIABLE","ser_remessa")
      CALL _ADVPL_set_property(m_carga_ser_remessa,"HEADER","Série")
      CALL _ADVPL_set_property(m_carga_ser_remessa,"COLUMN_SIZE", 30)
      CALL _ADVPL_set_property(m_carga_ser_remessa,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_ser_remessa,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_carga_ser_remessa,"EDIT_PROPERTY","LENGTH",5) 
      CALL _ADVPL_set_property(m_carga_ser_remessa,"EDITABLE", FALSE)
      
      
      #cria campo do array: cod_cliente
      LET m_carga_cod_item = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_carga_cod_item,"VARIABLE","cod_item")
      CALL _ADVPL_set_property(m_carga_cod_item,"HEADER","Item")
      CALL _ADVPL_set_property(m_carga_cod_item,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_cod_item,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_cod_item,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_carga_cod_item,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_carga_cod_item,"EDITABLE", FALSE)
      
      
      #cria campo do array: cod_cliente
      LET m_carga_den_item = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_carga_den_item,"VARIABLE","den_item")
      CALL _ADVPL_set_property(m_carga_den_item,"HEADER","Descrição")
      CALL _ADVPL_set_property(m_carga_den_item,"COLUMN_SIZE", 120)
      CALL _ADVPL_set_property(m_carga_den_item,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_den_item,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_carga_den_item,"EDIT_PROPERTY","LENGTH",76) 
      CALL _ADVPL_set_property(m_carga_den_item,"EDITABLE", FALSE)
      
      #cria campo do array: cod_cliente
      LET m_carga_um = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_carga_um,"VARIABLE","unid_med")
      CALL _ADVPL_set_property(m_carga_um,"HEADER","Unid. Med.")
      CALL _ADVPL_set_property(m_carga_um,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(m_carga_um,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_um,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_carga_um,"EDIT_PROPERTY","LENGTH",3) 
      CALL _ADVPL_set_property(m_carga_um,"EDITABLE", FALSE)
      
      #cria campo do array: cod_cliente
      LET m_carga_qtd_remessa = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"VARIABLE","qtd_remessa")
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"HEADER","Qtd. Remessa")
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"EDIT_PROPERTY","LENGTH",17,6) 
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"PICTURE","@E 999999999999999.99")
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"EDITABLE", FALSE)
      
      #cria campo do array: cod_cliente
      LET m_carga_qtd_vendido = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"VARIABLE","qtd_vendido")
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"HEADER","Qtd. Vendido")
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"EDIT_PROPERTY","LENGTH",17,6) 
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"PICTURE","@E 999999999999999.99")
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"EDITABLE", FALSE)
      
      
      #cria campo do array: cod_cliente
      LET m_carga_qtd_diferenca = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"VARIABLE","qtd_diferenca")
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"HEADER","Qtd. Diferença")
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"EDIT_PROPERTY","LENGTH",17,6) 
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"PICTURE","@E 999999999999999.99")
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"EDITABLE", FALSE)
      
      #cria campo do array: cod_cliente
      LET m_carga_qtd_retornado = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"VARIABLE","qtd_retornado")
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"HEADER","Qtd. Retornado")
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"EDIT_PROPERTY","LENGTH",17,6) 
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"PICTURE","@E 999999999999999.99")
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"EDITABLE", FALSE)
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"EDIT_PROPERTY","VALID","geo1020_calcula_dif")
      
      
      #cria campo do array: cod_cliente
      LET m_carga_val_unit = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_carga_val_unit,"VARIABLE","val_unit")
      CALL _ADVPL_set_property(m_carga_val_unit,"HEADER","Vlr.Unit")
      CALL _ADVPL_set_property(m_carga_val_unit,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_val_unit,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_val_unit,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_val_unit,"EDIT_PROPERTY","LENGTH",17,6) 
      CALL _ADVPL_set_property(m_carga_val_unit,"PICTURE","@E 999999999999999.99")
      CALL _ADVPL_set_property(m_carga_val_unit,"EDITABLE", FALSE)
      
      
      
      #cria campo do array: cod_cliente
      LET m_carga_val_tot = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_carga_val_tot,"VARIABLE","val_tot")
      CALL _ADVPL_set_property(m_carga_val_tot,"HEADER","Vlr.Total")
      CALL _ADVPL_set_property(m_carga_val_tot,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_val_tot,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_val_tot,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_val_tot,"EDIT_PROPERTY","LENGTH",17,6) 
      CALL _ADVPL_set_property(m_carga_val_tot,"PICTURE","@E 999999999999999.99")
      CALL _ADVPL_set_property(m_carga_val_tot,"EDITABLE", FALSE)
      
      
      
      #cria campo do array: cod_cliente
      LET m_carga_base_icms = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_carga_base_icms,"VARIABLE","base_icms")
      CALL _ADVPL_set_property(m_carga_base_icms,"HEADER","Base ICMS")
      CALL _ADVPL_set_property(m_carga_base_icms,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_base_icms,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_base_icms,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_base_icms,"EDIT_PROPERTY","LENGTH",17,6) 
      CALL _ADVPL_set_property(m_carga_base_icms,"PICTURE","@E 999999999999999.99")
      CALL _ADVPL_set_property(m_carga_base_icms,"EDITABLE", FALSE)
      
      
      
      #cria campo do array: cod_cliente
      LET m_carga_val_icms = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_carga_val_icms,"VARIABLE","val_icms")
      CALL _ADVPL_set_property(m_carga_val_icms,"HEADER","ICMS")
      CALL _ADVPL_set_property(m_carga_val_icms,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_val_icms,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_val_icms,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_val_icms,"EDIT_PROPERTY","LENGTH",17,6) 
      CALL _ADVPL_set_property(m_carga_val_icms,"PICTURE","@E 999999999999999.99")
      CALL _ADVPL_set_property(m_carga_val_icms,"EDITABLE", FALSE)
      
      
      
      #cria campo do array: cod_cliente
      LET m_carga_base_st = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_carga_base_st,"VARIABLE","base_st")
      CALL _ADVPL_set_property(m_carga_base_st,"HEADER","Base ST")
      CALL _ADVPL_set_property(m_carga_base_st,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_base_st,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_base_st,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_base_st,"EDIT_PROPERTY","LENGTH",17,6) 
      CALL _ADVPL_set_property(m_carga_base_st,"PICTURE","@E 999999999999999.99")
      CALL _ADVPL_set_property(m_carga_base_st,"EDITABLE", FALSE)
      
      
      #cria campo do array: cod_cliente
      LET m_carga_val_st = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_carga_val_st,"VARIABLE","val_st")
      CALL _ADVPL_set_property(m_carga_val_st,"HEADER","ICMS ST")
      CALL _ADVPL_set_property(m_carga_val_st,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_val_st,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_val_st,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_val_st,"EDIT_PROPERTY","LENGTH",17,6) 
      CALL _ADVPL_set_property(m_carga_val_st,"PICTURE","@E 999999999999999.99")
      CALL _ADVPL_set_property(m_carga_val_st,"EDITABLE", FALSE)
      
      
      CALL _ADVPL_set_property(m_table_reference1,"SET_ROWS",ma_carga,0)
      CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)
   
      CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
	  

 

      CALL _ADVPL_set_property(m_form_principal,"ACTIVATE",TRUE)

 END FUNCTION

#---------------------------#
FUNCTION geo1020_pesquisar()
#---------------------------#
   INITIALIZE mr_tela.*, ma_tela, ma_carga to null
   LET mr_tela.cod_empresa  = p_cod_empresa
   CALL geo1020_habilita_campos_manutencao(TRUE,'PESQUISAR')
END FUNCTION

#-----------------------------#
 function geo1020_modificar()
#-----------------------------#
   define l_msg char(80)
   
   IF NOT m_ies_onsulta THEN
      CALL _ADVPL_message_box("Execute a consulta antes de modificar")
      RETURN FALSE
   END IF 
   
   SELECT DISTINCT cod_empresa
     FROM geo_manifesto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
      AND sit_manifesto <> "E"
   IF sqlca.sqlcode <> 0 THEN
      CALL _ADVPL_message_box("Manifesto já foi encerrado e não pode ser modificado.")
      RETURN FALSE
   END IF

   call geo1020_habilita_campos_manutencao(TRUE,'MODIFICAR')
   RETURN TRUE
 end function
 
#--------------------------------------#
 function geo1020_confirmar_pesquisar()
#--------------------------------------#
   DEFINE l_ind         SMALLINT
   DEFINE l_status      SMALLINT
   
   CALL geo1020_carrega_dados() 
   CALL geo1020_habilita_campos_manutencao(FALSE,'PESQUISAR')
   RETURN TRUE
 end function

#---------------------------#
 function  geo1020_cancelar_pesquisar()
#---------------------------#
  call geo1020_habilita_campos_manutencao(FALSE,'PESQUISAR')
 end function

#---------------------------#
 function geo1020_confirmar_modificacao()
#---------------------------#
   CALL geo1020_habilita_campos_manutencao(FALSE,'MODIFICAR')
   CALL geo1020_atualiza_dados('MODIFICACAO')
   RETURN TRUE
 end function
#
#---------------------------#
 function  geo1020_cancelar_modificacao()
#---------------------------#
  CALL geo1020_habilita_campos_manutencao(FALSE,'MODIFICAR')
 end function

#----------------------------------------------#
 function geo1020_atualiza_dados(l_funcao)
#----------------------------------------------#
   DEFINE l_funcao char(20)
   DEFINE l_ind    integer
   DEFINE l_trans_remessa INTEGER
   
   CALL log085_transacao('BEGIN')
   
      delete from geo_remessa_movto
       where cod_empresa = p_cod_empresa
         and cod_manifesto = mr_tela.cod_manifesto
         AND tipo_movto = 'R'
      IF sqlca.sqlcode <> 0 THEN
	     CALL log003_err_sql("DELETE","geo_remessa_movto")
	     CALL log085_transacao("ROLLBACK")
	     RETURN FALSE
	  END IF 
	  
	  
      UPDATE geo_manifesto
         SET sit_manifesto = "R"
       WHERE cod_empresa = p_cod_empresa
         AND cod_manifesto = mr_tela.cod_manifesto
      IF sqlca.sqlcode <> 0 THEN
	     CALL log003_err_sql("UPDATE","geo_manifesto")
	     CALL log085_transacao("ROLLBACK")
	     RETURN FALSE
	  END IF 

   for l_ind = 1 to _ADVPL_get_property(m_table_reference1,"ITEM_COUNT")
       
       SELECT DISTINCT trans_remessa
         INTO l_trans_remessa
         FROM geo_remessa_movto
        WHERE cod_empresa = p_cod_empresa 
          AND cod_manifesto = mr_tela.cod_manifesto
          AND cod_item = ma_carga[l_ind].cod_item
          AND tipo_movto = 'E'
          AND num_remessa = ma_carga[l_ind].num_remessa
          AND ser_remessa = ma_carga[l_ind].ser_remessa
          IF ma_carga[l_ind].num_remessa IS NULL OR ma_carga[l_ind].num_remessa = " " OR ma_carga[l_ind].num_remessa = 0 THEN
             CONTINUE FOR
          END IF 
          INSERT INTO geo_remessa_movto VALUES (p_cod_empresa,
	      										mr_tela.cod_manifesto,
	      										ma_carga[l_ind].num_remessa,
	      										ma_carga[l_ind].ser_remessa,
	      										l_trans_remessa,
	      										"R",
	      										ma_carga[l_ind].cod_item,
	      										ma_carga[l_ind].qtd_retornado,
	      										NULL,
	      										NULL,
	      										NULL,
	      										TODAY)
	      IF sqlca.sqlcode <> 0 THEN
	         CALL log003_err_sql("INSERT","geo_remessa_movto")
	         CALL log085_transacao("ROLLBACK")
	         RETURN FALSE
	      END IF 							
   end for
 
   CALL log085_transacao('COMMIT')
   
END FUNCTION

#----------------------------------------------#
 function geo1020_habilita_campos_manutencao(l_status,l_funcao)
#----------------------------------------------#

   DEFINE l_status smallint
   
   define l_funcao char(20)

   if l_funcao = 'PESQUISAR' then
      CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",l_status)
      CALL _ADVPL_set_property(m_refer_dat_manifesto,"ENABLE",l_status)
      CALL _ADVPL_set_property(m_refer_placa_veic,"ENABLE",l_status)
      CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",l_status)
      CALL _ADVPL_set_property(m_refer_cod_transp,"ENABLE",l_status)
   end if
   if l_funcao = 'MODIFICAR' then
      CALL _ADVPL_set_property(m_table_reference1,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"EDITABLE", l_status)
   END IF
   
END FUNCTION
#
       

#-------------------------------------#
 FUNCTION geo1020_primeiro()
#-------------------------------------#
    CALL geo1020_paginacao("PRIMEIRO")
 end function

#-------------------------------------#
 FUNCTION geo1020_anterior()
#-------------------------------------#
   CALL geo1020_paginacao("ANTERIOR")
 end function

#-------------------------------------#
 FUNCTION geo1020_seguinte()
#-------------------------------------#
     CALL geo1020_paginacao("SEGUINTE")
 end function

#-------------------------------------#
 FUNCTION geo1020_ultimo()
#-------------------------------------#
    CALL geo1020_paginacao("ULTIMO")
 end function

##---------------------------------#
 FUNCTION geo1020_carrega_dados()
 #---------------------------------#
    DEFINE l_sql            CHAR(2000)
    
    LET l_sql = "  SELECT cod_manifesto, ",
                "         dat_manifesto, ",
                "         cod_resp, ",
                "         cod_transp, ",
                "         placa_veic ",
                "    FROM geo_manifesto ",
                "   WHERE cod_empresa = '",p_cod_empresa,"'"
                
    IF mr_tela.cod_manifesto <> 0 THEN
       LET l_sql = l_sql CLIPPED, " AND cod_manifesto = '",mr_tela.cod_manifesto,"'"
    END IF 
    IF mr_tela.cod_resp IS NOT NULL AND mr_tela.cod_resp <> " " THEN
       LET l_sql = l_sql CLIPPED, " AND cod_resp = '",mr_tela.cod_resp,"'"
    END IF 
    IF mr_tela.placa_veic IS NOT NULL AND mr_tela.placa_veic <> " " THEN
       LET l_sql = l_sql CLIPPED, " AND placa_veic = '",mr_tela.placa_veic,"'"
    END IF 
    IF mr_tela.cod_transp IS NOT NULL AND mr_tela.cod_transp <> " " THEN
       LET l_sql = l_sql CLIPPED, " AND cod_transp = '",mr_tela.cod_transp,"'"
    END IF 
    IF mr_tela.dat_manifesto IS NOT NULL AND mr_tela.dat_manifesto <> " " THEN
       LET l_sql = l_sql CLIPPED, " AND dat_manifesto = '",mr_tela.dat_manifesto,"'"
    END IF 
    
    
    
    PREPARE var_query FROM l_sql
    DECLARE cq_dados_cons SCROLL CURSOR FOR var_query
    OPEN cq_dados_cons
    FETCH FIRST cq_dados_cons INTO mr_tela.cod_manifesto,
                               mr_tela.dat_manifesto,
                               mr_tela.cod_resp,
                               mr_tela.cod_transp,
                               mr_tela.placa_veic
    IF sqlca.sqlcode = 0 THEN
       LET m_ies_onsulta = TRUE
    ELSE
       LET m_ies_onsulta = FALSE
       CALL _ADVPL_message_box("Argumentos de pesquisa não encontrados")
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
        
    CALL geo1020_exibe_array()
 END FUNCTION
#-------------------------------------#
 FUNCTION geo1020_paginacao(l_funcao)
#-------------------------------------#

   DEFINE l_funcao    CHAR(10),
          l_status    SMALLINT

   INITIALIZE ma_carga TO NULL
   LET l_funcao = l_funcao CLIPPED

   let mr_telar.* = mr_tela.*
   LET mr_tela.den_resp = NULL
   LET mr_tela.den_transp = NULL
   IF m_ies_onsulta THEN


      WHILE TRUE
         CASE
            WHEN l_funcao = "SEGUINTE"

                  FETCH NEXT cq_dados_cons INTO mr_tela.cod_manifesto,
                               mr_tela.dat_manifesto,
                               mr_tela.cod_resp,
                               mr_tela.cod_transp,
                               mr_tela.placa_veic
    
       

               IF sqlca.sqlcode <> 0 THEN
                  #CALL log003_err_sql ("NEXT","cq_orcamentos")
                  #EXIT WHILE
               END IF

            WHEN l_funcao = "ANTERIOR"

                 FETCH PREVIOUS cq_dados_cons INTO mr_tela.cod_manifesto,
                               mr_tela.dat_manifesto,
                               mr_tela.cod_resp,
                               mr_tela.cod_transp,
                               mr_tela.placa_veic
    
      
               IF sqlca.sqlcode <> 0 THEN
                  #CALL log003_err_sql ("PREVIOUS","cq_orcamentos")
                  #EXIT WHILE
               END IF

            WHEN l_funcao = "PRIMEIRO"

                  FETCH FIRST cq_dados_cons INTO mr_tela.cod_manifesto,
                               mr_tela.dat_manifesto,
                               mr_tela.cod_resp,
                               mr_tela.cod_transp,
                               mr_tela.placa_veic
    
       

               IF sqlca.sqlcode <> 0 THEN
                  #CALL log003_err_sql ("FIRST","cq_orcamentos")
                  #EXIT WHILE
               END IF

            WHEN l_funcao = "ULTIMO"

                  FETCH LAST cq_dados_cons INTO mr_tela.cod_manifesto,
                               mr_tela.dat_manifesto,
                               mr_tela.cod_resp,
                               mr_tela.cod_transp,
                               mr_tela.placa_veic
    
       

            IF sqlca.sqlcode <> 0 THEN
               #CALL log003_err_sql ("LAST","cq_orcamentos")
               #EXIT WHILE
            END IF
         END CASE
         IF sqlca.sqlcode = NOTFOUND THEN
            CALL geo1020_exibe_mensagem_barra_status("Não existem mais itens nesta direcao.","ERRO")
            let mr_tela.* = mr_telar.*
            EXIT WHILE
         ELSE
            LET m_ies_onsulta = TRUE
         END IF

         SELECT cod_manifesto,
                dat_manifesto,
                cod_resp,
                cod_transp,
                placa_veic
           INTO mr_tela.cod_manifesto,
                mr_tela.dat_manifesto,
                mr_tela.cod_resp,
                mr_tela.cod_transp,
                mr_tela.placa_veic
          from geo_manifesto
         where cod_empresa  = p_cod_empresa
           and cod_manifesto = mr_tela.cod_manifesto
           
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
      CALL geo1020_exibe_mensagem_barra_status("Efetue primeiramente a consulta.","ERRO")
   END IF

  #CALL geo1020_exibe_dados()
   CALL geo1020_exibe_array()
 END FUNCTION
 
 #--------------------------------------------------------------------#
 FUNCTION geo1020_exibe_mensagem_barra_status(l_mensagem,l_tipo_mensagem)
#--------------------------------------------------------------------#

   DEFINE l_mensagem               CHAR(500),
          l_tipo_mensagem          CHAR(010),
          l_tipo_mensagem_original CHAR(015)

   LET l_tipo_mensagem_original = LOG_retorna_tipo_mensagem_original(UPSHIFT(l_tipo_mensagem),TRUE)
   CALL _ADVPL_set_property(m_status_bar,l_tipo_mensagem_original CLIPPED," "||l_mensagem CLIPPED)

 END FUNCTION

  
 #-------------------------------#
 FUNCTION geo1020_valid_cod_resp()
 #-------------------------------#
    
    IF mr_tela.cod_resp IS NOT NULL AND mr_tela.cod_resp <> " " THEN
       SELECT nom_cliente
         INTO mr_tela.den_resp
         FROM clientes
        WHERE cod_cliente = mr_tela.cod_resp
       IF sqlca.sqlcode <> 0 THEN
          CALL _ADVPL_message_box("Cliente não cadastrado.")
          RETURN FALSE
       END IF 
    END IF
 	RETURN TRUE
 END FUNCTION
 
 
 #----------------------------------#
 FUNCTION geo1020_valid_cod_transp() 
 #----------------------------------#
    
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
 	RETURN TRUE
    
 END FUNCTION
 
 #---------------------------------------#
 function geo1020_zoom_resp()
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
    
    CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",l_ind)
    CALL _ADVPL_set_property(m_table_reference1,"REFRESH")

 end function
#

#---------------------------------------#
 function geo1020_zoom_transp()
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
    
    CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",l_ind)
    CALL _ADVPL_set_property(m_table_reference1,"REFRESH")

 end function

 
 
#------------------------------#
 FUNCTION geo1020_exibe_array()
#------------------------------#
    DEFINE l_aliquota     DECIMAL(15,4)
    DEFINE l_red_bas      DECIMAL(15,4)
    DEFINE l_pct_margem_lucro DECIMAL(15,4)
    DEFINE l_sit_manifesto CHAR(1)
   
    DECLARE cq_cargas1 CURSOR FOR
    SELECT DISTINCT d.num_remessa,
           d.ser_remessa,
           a.cod_item,
           a.den_item,
           a.cod_unid_med,
           d.qtd_movto, #QUANTIDADE REMESSA
           0,
           0,
           0,
           b.preco_unit_bruto
      FROM item a, fat_nf_item b, fat_nf_mestre c, geo_remessa_movto d
     WHERE a.cod_empresa = b.empresa
       AND b.empresa = c.empresa
       AND c.empresa = d.cod_empresa
       AND a.cod_item = b.item
       AND b.trans_nota_fiscal = c.trans_nota_fiscal
       AND c.trans_nota_fiscal = d.trans_remessa
       AND d.tipo_movto = 'E'
       AND a.cod_item = d.cod_item
       AND d.cod_manifesto = mr_tela.cod_manifesto
       AND d.cod_empresa = p_cod_empresa
       AND c.sit_nota_fiscal = 'N'
    
    LET m_ind_carga = 1
    FOREACH cq_cargas1 INTO ma_carga[m_ind_carga].*
    
       SELECT SUM(a.qtd_movto)
         INTO ma_carga[m_ind_carga].qtd_vendido
         FROM geo_remessa_movto a, fat_nf_mestre b
        WHERE a.cod_empresa = p_cod_empresa
          AND a.cod_manifesto = mr_tela.cod_manifesto
          AND a.tipo_movto = 'S'
          AND a.cod_item = ma_carga[m_ind_carga].cod_item
          AND a.num_remessa = ma_carga[m_ind_carga].num_remessa
          AND a.ser_remessa = ma_carga[m_ind_carga].ser_remessa
          AND a.cod_empresa = b.empresa
          AND a.trans_nota_fiscal = b.trans_nota_fiscal
          AND b.sit_nota_fiscal = 'N'
       IF ma_carga[m_ind_carga].qtd_vendido IS NULL OR ma_carga[m_ind_carga].qtd_vendido = "" THEN
          LET ma_carga[m_ind_carga].qtd_vendido = 0
       END IF 
       
       SELECT DISTINCT cod_empresa
         FROM geo_manifesto
        WHERE cod_empresa = p_cod_empresa
          AND cod_manifesto = mr_tela.cod_manifesto
          AND tip_manifesto = "B"
       IF sqlca.sqlcode = 0 THEN
          LET ma_carga[m_ind_carga].qtd_vendido = ma_carga[m_ind_carga].qtd_remessa
       END IF
       
       SELECT SUM(qtd_movto)
         INTO ma_carga[m_ind_carga].qtd_retornado
         FROM geo_remessa_movto
        WHERE cod_empresa = p_cod_empresa
          AND cod_manifesto = mr_tela.cod_manifesto
          AND tipo_movto = 'R'
          AND cod_item = ma_carga[m_ind_carga].cod_item
          AND num_remessa = ma_carga[m_ind_carga].num_remessa
          AND ser_remessa = ma_carga[m_ind_carga].ser_remessa
       IF ma_carga[m_ind_carga].qtd_retornado IS NULL OR ma_carga[m_ind_carga].qtd_retornado = "" THEN
          LET ma_carga[m_ind_carga].qtd_retornado = 0
       END IF 
       
       LET ma_carga[m_ind_carga].qtd_diferenca = ma_carga[m_ind_carga].qtd_remessa - (ma_carga[m_ind_carga].qtd_vendido + ma_carga[m_ind_carga].qtd_retornado)
       
       LET ma_carga[m_ind_carga].val_tot = ma_carga[m_ind_carga].qtd_retornado * ma_carga[m_ind_carga].val_unit
   
	   LET l_aliquota = 0
	   SELECT DISTINCT c.aliquota, c.pct_red_bas_calc
	     INTO l_aliquota, l_red_bas
	     FROM fat_nf_mestre a, fat_nf_item b, fat_nf_item_fisc c
	    WHERE a.empresa = p_cod_empresa
	      AND a.trans_nota_fiscal = b.trans_nota_fiscal
	      AND a.nota_fiscal = ma_carga[m_ind_carga].num_remessa
	      AND a.serie_nota_fiscal = ma_carga[m_ind_carga].ser_remessa
	      AND b.item = ma_carga[m_ind_carga].cod_item
	      AND b.empresa = a.empresa
	      AND a.trans_nota_fiscal = c.trans_nota_fiscal
	      AND c.empresa = b.empresa
	      AND c.seq_item_nf = b.seq_item_nf
	      AND tributo_benef = 'ICMS'
	   IF l_aliquota IS NULL OR l_aliquota = " " THEN
	      LET l_aliquota = 0
	   END IF 
	   IF l_red_bas IS NULL OR l_red_bas = " " THEN
	      LET l_red_bas = 0
	   END IF 
	   
	   LET ma_carga[m_ind_carga].base_icms = ma_carga[m_ind_carga].val_tot - (ma_carga[m_ind_carga].val_tot * l_red_bas / 100)
	   LET ma_carga[m_ind_carga].val_icms = ma_carga[m_ind_carga].base_icms * l_aliquota / 100
	   
	   LET l_aliquota = 0
	   LET l_pct_margem_lucro = 0
	   SELECT DISTINCT c.aliquota, c.pct_red_bas_calc, c.pct_margem_lucro
	     INTO l_aliquota, l_red_bas, l_pct_margem_lucro
	     FROM fat_nf_mestre a, fat_nf_item b, fat_nf_item_fisc c
	    WHERE a.empresa = p_cod_empresa
	      AND a.trans_nota_fiscal = b.trans_nota_fiscal
	      AND a.nota_fiscal = ma_carga[m_ind_carga].num_remessa
	      AND a.serie_nota_fiscal = ma_carga[m_ind_carga].ser_remessa
	      AND b.item = ma_carga[m_ind_carga].cod_item
	      AND b.empresa = a.empresa
	      AND a.trans_nota_fiscal = c.trans_nota_fiscal
	      AND c.empresa = b.empresa
	      AND c.seq_item_nf = b.seq_item_nf
	      AND tributo_benef = 'ICMS_ST'
	   IF l_aliquota IS NULL OR l_aliquota = " " THEN
	      LET l_aliquota = 0
	   END IF 
	   IF l_red_bas IS NULL OR l_red_bas = " " THEN
	      LET l_red_bas = 0
	   END IF 
	   IF l_pct_margem_lucro IS NULL OR l_pct_margem_lucro = " " THEN
	      LET l_pct_margem_lucro = 0
	   END IF 
	   
	   IF l_red_bas = 0 THEN
	      LET ma_carga[m_ind_carga].base_st = ma_carga[m_ind_carga].val_tot + (ma_carga[m_ind_carga].val_tot * l_pct_margem_lucro / 100)
	      LET ma_carga[m_ind_carga].val_st = (ma_carga[m_ind_carga].base_st - ma_carga[m_ind_carga].base_icms) * l_aliquota / 100
	   ELSE
	      LET ma_carga[m_ind_carga].base_st = ma_carga[m_ind_carga].base_icms + (ma_carga[m_ind_carga].base_icms * l_pct_margem_lucro / 100)
	      LET ma_carga[m_ind_carga].val_st = (ma_carga[m_ind_carga].base_st - ma_carga[m_ind_carga].base_icms) * l_aliquota / 100
	   END IF 
	   
	   IF ma_carga[m_ind_carga].val_st = 0 THEN
	      LET ma_carga[m_ind_carga].base_st = 0
	   END IF 
	   
	   IF ma_carga[m_ind_carga].val_icms = 0 THEN
	      LET ma_carga[m_ind_carga].base_icms = 0
	   END IF 
	   
       LET m_ind_carga = m_ind_carga + 1
    END FOREACH
    IF m_ind_carga > 1 THEN
       LET m_ind_carga = m_ind_carga - 1
    END IF 
    
    CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",m_ind_carga)
   
    CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
 
 END FUNCTION

 
#------------------------------#
FUNCTION geo1020_calcula_dif()
#------------------------------#
   DEFINE l_arr_curr     INTEGER
   DEFINE l_aliquota     DECIMAL(15,4)
   DEFINE l_red_bas      DECIMAL(15,4)
   DEFINE l_pct_margem_lucro DECIMAL(15,4)
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   LET ma_carga[l_arr_curr].qtd_diferenca = ma_carga[l_arr_curr].qtd_remessa - (ma_carga[l_arr_curr].qtd_vendido + ma_carga[l_arr_curr].qtd_retornado)
   
   IF ma_carga[l_arr_curr].qtd_retornado IS NULL OR ma_carga[l_arr_curr].qtd_retornado = " " THEN
      LET ma_carga[l_arr_curr].qtd_retornado = 0
   END IF 
   
   LET ma_carga[l_arr_curr].val_tot = ma_carga[l_arr_curr].qtd_retornado * ma_carga[l_arr_curr].val_unit
   
   LET l_aliquota = 0
   SELECT DISTINCT c.aliquota, c.pct_red_bas_calc
     INTO l_aliquota, l_red_bas
     FROM fat_nf_mestre a, fat_nf_item b, fat_nf_item_fisc c
    WHERE a.empresa = p_cod_empresa
      AND a.trans_nota_fiscal = b.trans_nota_fiscal
      AND a.nota_fiscal = ma_carga[l_arr_curr].num_remessa
      AND a.serie_nota_fiscal = ma_carga[l_arr_curr].ser_remessa
      AND b.item = ma_carga[l_arr_curr].cod_item
      AND b.empresa = a.empresa
      AND a.trans_nota_fiscal = c.trans_nota_fiscal
      AND c.empresa = b.empresa
      AND c.seq_item_nf = b.seq_item_nf
      AND tributo_benef = 'ICMS'
   IF l_aliquota IS NULL OR l_aliquota = " " THEN
      LET l_aliquota = 0
   END IF 
   IF l_red_bas IS NULL OR l_red_bas = " " THEN
      LET l_red_bas = 0
   END IF 
   
   LET ma_carga[l_arr_curr].base_icms = ma_carga[l_arr_curr].val_tot - (ma_carga[l_arr_curr].val_tot * l_red_bas / 100)
   LET ma_carga[l_arr_curr].val_icms = ma_carga[l_arr_curr].base_icms * l_aliquota / 100
   
   LET l_aliquota = 0
   LET l_pct_margem_lucro = 0
   SELECT DISTINCT c.aliquota, c.pct_red_bas_calc, c.pct_margem_lucro
     INTO l_aliquota, l_red_bas, l_pct_margem_lucro
     FROM fat_nf_mestre a, fat_nf_item b, fat_nf_item_fisc c
    WHERE a.empresa = p_cod_empresa
      AND a.trans_nota_fiscal = b.trans_nota_fiscal
      AND a.nota_fiscal = ma_carga[l_arr_curr].num_remessa
      AND a.serie_nota_fiscal = ma_carga[l_arr_curr].ser_remessa
      AND b.item = ma_carga[l_arr_curr].cod_item
      AND b.empresa = a.empresa
      AND a.trans_nota_fiscal = c.trans_nota_fiscal
      AND c.empresa = b.empresa
      AND c.seq_item_nf = b.seq_item_nf
      AND tributo_benef = 'ICMS_ST'
   IF l_aliquota IS NULL OR l_aliquota = " " THEN
      LET l_aliquota = 0
   END IF 
   IF l_red_bas IS NULL OR l_red_bas = " " THEN
      LET l_red_bas = 0
   END IF 
   IF l_pct_margem_lucro IS NULL OR l_pct_margem_lucro = " " THEN
      LET l_pct_margem_lucro = 0
   END IF 
   
   IF l_red_bas = 0 THEN
      LET ma_carga[l_arr_curr].base_st = ma_carga[l_arr_curr].val_tot + (ma_carga[l_arr_curr].val_tot * l_pct_margem_lucro / 100)
      LET ma_carga[l_arr_curr].val_st = (ma_carga[l_arr_curr].base_st - ma_carga[l_arr_curr].base_icms) * l_aliquota / 100
   ELSE
      LET ma_carga[l_arr_curr].base_st = ma_carga[l_arr_curr].base_icms + (ma_carga[l_arr_curr].base_icms * l_pct_margem_lucro / 100)
      LET ma_carga[l_arr_curr].val_st = (ma_carga[l_arr_curr].base_st - ma_carga[l_arr_curr].base_icms) * l_aliquota / 100
   END IF 
   
   IF ma_carga[l_arr_curr].val_st = 0 THEN
      LET ma_carga[l_arr_curr].base_st = 0
   END IF 
   
   IF ma_carga[l_arr_curr].val_icms = 0 THEN
      LET ma_carga[l_arr_curr].base_icms = 0
   END IF 
   
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
END FUNCTION