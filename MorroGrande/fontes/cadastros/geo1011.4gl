#-----------------------------------------------------------------#
# MODULO..: GEO                                                   #
# SISTEMA.: CADASTRO DE ROTEIROS                                  #
# PROGRAMA: geo1011                                               #
# AUTOR...: ADOLAR ROSSKAMP JUNIOR                                #
# DATA....: 11/12/2015                                            #
#-----------------------------------------------------------------#
#


DATABASE logix

GLOBALS

   DEFINE p_versao            CHAR(18)
   DEFINE p_cod_empresa       LIKE empresa.cod_empresa
   DEFINE p_user              LIKE usuarios.cod_usuario

END GLOBALS

   DEFINE m_ind                  INTEGER
   DEFINE m_rotina_automatica    SMALLINT

   DEFINE m_ies_onsulta          SMALLINT

 
  
   define mr_filtro  record 
                cod_repres char(4) 
                     end record 
           
   define m_botao_find  char(50) 
   define m_refer_filtro_2 char(50)
         
   DEFINE ma_tela             ARRAY[5000] OF RECORD
             cod_roteiro             decimal(4,0) ,
             den_roteiro             char(30) 
                                 END RECORD
DEFINE ma_clientes             ARRAY[5000] OF RECORD
             cod_roteiro            SMALLINT,
             seq_visita             SMALLINT,
             cod_cliente             CHAR(15) ,
             nom_cliente             LIKE clientes.nom_cliente,
             cod_vendedor            integer,
             nom_vendedor            char(36),
             situacao                char(20) 
                                 END RECORD

 define mr_tela, mr_telar   record
                         cod_empresa char(2),
                         cod_repres  decimal(4,0),
                         raz_social  char(36)
                  end record 
                  
 
  DEFINE m_column_cod_cliente     VARCHAR(50)
  DEFINE m_column_nom_cliente     VARCHAR(50)
  DEFINE m_column_cod_roteiro2     VARCHAR(50)
  DEFINE m_column_seq_visita      VARCHAR(50)
 define m_agrupa_itens char(1)
 
 define m_btn_zoom_repres char(20)

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
   define m_table_reference2           varchar(50)

   define m_column_reference           varchar(50)
   define m_column_cod_roteiro          varchar(50)
   define m_column_den_roteiro          varchar(50)

   define m_refer_cod_empresa          varchar(50)
   define m_refer_cod_repres            varchar(50)
   define m_refer_descricao            varchar(50)
   define m_refer_ies_situacao         varchar(50)
   define m_refer_den_situacao         varchar(50)
   

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
 FUNCTION geo1011()
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
      CALL geo1011_tela()
   END IF

END FUNCTION

#-------------------#
 FUNCTION geo1011_tela()
#-------------------#

   DEFINE l_label  VARCHAR(50)
        , l_splitter                   VARCHAR(50)
        , l_status SMALLINT
     
     
     CALL geo1011_temp_roteiros()
     
     #cria janela principal do tipo LDIALOG
     LET m_form_principal = _ADVPL_create_component(NULL,"LDIALOG")
     CALL _ADVPL_set_property(m_form_principal,"TITLE","ROTEIROS POR VENDEDOR")
     CALL _ADVPL_set_property(m_form_principal,"ENABLE_ESC_CLOSE",FALSE)
     CALL _ADVPL_set_property(m_form_principal,"SIZE",1024,700)#   1024,725)

     #
     #
     #
     # INICIO MENU

     #cria menu
     LET m_toolbar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_principal)

     #botao INCLUIR
     LET m_botao_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_create,"EVENT","geo1011_incluir")
     CALL _ADVPL_set_property(m_botao_create,"CONFIRM_EVENT","geo1011_confirmar_inclusao")
     CALL _ADVPL_set_property(m_botao_create,"CANCEL_EVENT","geo1011_cancelar_inclusao")

     #botao MODIFICAR
     LET m_botao_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_update,"EVENT","geo1011_modificar")
     CALL _ADVPL_set_property(m_botao_update,"CONFIRM_EVENT","geo1011_confirmar_modificacao")
     CALL _ADVPL_set_property(m_botao_update,"CANCEL_EVENT","geo1011_cancelar_modificacao")

     #botao EXCLUIR
     LET m_botao_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_delete,"EVENT","geo1011_excluir")

     #botao LOCALIZAR
     LET m_botao_find_principal = _ADVPL_create_component(NULL,"LFINDBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_find_principal,"EVENT","geo1011_pesquisar")
     CALL _ADVPL_set_property(m_botao_find_principal,"TYPE","NO_CONFIRM")
     
     #botao primeiro registro
      LET m_botao_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_first,"EVENT","geo1011_primeiro")
      
      #botao anterior
      LET m_botao_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_previous,"EVENT","geo1011_anterior")
      
      #botao seguinte
      LET m_botao_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_next,"EVENT","geo1011_seguinte")
      
      #botao ultimo registro
      LET m_botao_last = _ADVPL_create_component(NULL,"LLASTBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_last,"EVENT","geo1011_ultimo")
      

     #botao sair
     LET m_botao_quit = _ADVPL_create_component(NULL,"LQUITBUTTON",m_toolbar)


     LET m_status_bar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_principal)

     #  FIM MENU
     #
     #
     #

   

    # LET l_splitter = _ADVPL_create_component(NULL,"LSPLITTER",m_form_principal)
    # CALL _ADVPL_set_property(l_splitter,"ALIGN","CENTER")
    # CALL _ADVPL_set_property(l_splitter,"ORIENTATION","HORIZONTAL")
     
      #cria panel para campos de filtro 
      LET m_panel_1 = _ADVPL_create_component(NULL,"LPANEL",m_form_principal)
      CALL _ADVPL_set_property(m_panel_1,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_panel_1,"HEIGHT",120)
      
      #cria panel para campos de filtro 
      LET m_panel_2 = _ADVPL_create_component(NULL,"LPANEL",m_form_principal)
      CALL _ADVPL_set_property(m_panel_2,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_panel_2,"HEIGHT",450)
      
     
     #cria panel  
     LET m_panel_reference1 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel_1)
     CALL _ADVPL_set_property(m_panel_reference1,"TITLE","ROTEIRO: ")
     CALL _ADVPL_set_property(m_panel_reference1,"ALIGN","CENTER")
     #CALL _ADVPL_set_property(m_panel_reference2,"HEIGHT",900)
     
     #cria panel  
     LET m_panel_reference2 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel_2)
     CALL _ADVPL_set_property(m_panel_reference2,"TITLE","SELECIONAR ROTEIROS: ")
     CALL _ADVPL_set_property(m_panel_reference2,"ALIGN","TOP")
     #CALL _ADVPL_set_property(m_panel_reference2,"HEIGHT",900)

  
     
     LET m_layoutmanager_refence_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_reference1)
     CALL _ADVPL_set_property(m_layoutmanager_refence_1,"MARGIN",TRUE)
     CALL _ADVPL_set_property(m_layoutmanager_refence_1,"COLUMNS_COUNT",3)


     LET m_layoutmanager_refence_2 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_reference2)
     CALL _ADVPL_set_property(m_layoutmanager_refence_2,"MARGIN",TRUE)
     CALL _ADVPL_set_property(m_layoutmanager_refence_2,"COLUMNS_COUNT",10)

     #
     #
     # CABEÇALHO

       #cria campo cod_empresa
       LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_layoutmanager_refence_1)
       CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")
       #CALL _ADVPL_set_property(l_label,"POSITION",5,5)
       CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
       CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

#
       LET m_refer_cod_empresa = LOG_cria_textfield(m_layoutmanager_refence_1,2)
       CALL _ADVPL_set_property(m_refer_cod_empresa,"VARIABLE",mr_tela,"cod_empresa")
       CALL _ADVPL_set_property(m_refer_cod_empresa,"ENABLE",FALSE)

       #CALL _ADVPL_set_property(m_refer_cod_empresa,"POSITION",90,5)
       
       #campo em branco
     LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_layoutmanager_refence_1)
       CALL _ADVPL_set_property(l_label,"TEXT"," ") 
       CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
       CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

#
#
#cria campo cod_repres
#
       LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_layoutmanager_refence_1)
       CALL _ADVPL_set_property(l_label,"TEXT","Código Vendedor:") 
       CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
       CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
      
      
        
       #cria campo cod_repres
       
      LET m_refer_cod_repres = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_layoutmanager_refence_1)
      CALL _ADVPL_set_property(m_refer_cod_repres,"LENGTH",4) 
      CALL _ADVPL_set_property(m_refer_cod_repres,"VARIABLE",mr_tela,"cod_repres")
      CALL _ADVPL_set_property(m_refer_cod_repres,"ENABLE",FALSE) 
      CALL _ADVPL_set_property(m_refer_cod_repres,"VALID","geo1011_valid_repres")
      
      
      #zoom
      LET m_btn_zoom_repres = _ADVPL_create_component(NULL, "LIMAGEBUTTON", m_layoutmanager_refence_1)
      CALL _ADVPL_set_property(m_btn_zoom_repres,"IMAGE","BTPESQ")
      CALL _ADVPL_set_property(m_btn_zoom_repres,"TOOLTIP","Zoom Repres")
      CALL _ADVPL_set_property(m_btn_zoom_repres,"CLICK_EVENT","geo1011_zoom_representante")
      CALL _ADVPL_set_property(m_btn_zoom_repres,"ENABLE",FALSE)    
     
     #cria campo rotulo raz_social 
     LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_layoutmanager_refence_1)
     CALL _ADVPL_set_property(l_label,"TEXT","Nome Vendedor:") 
       CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
       CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
    
        
       #cria campo raz_social 
      LET m_column_reference = LOG_cria_textfield(m_layoutmanager_refence_1,30) 
      CALL _ADVPL_set_property(m_column_reference,"VARIABLE",mr_tela,"raz_social")
      CALL _ADVPL_set_property(m_column_reference,"ENABLE",FALSE)
     # CALL _ADVPL_set_property(m_refer_cod_repres,"POSITION",90,30) 

     
     #campo em branco
     LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_layoutmanager_refence_1)
       CALL _ADVPL_set_property(l_label,"TEXT"," ") 
       CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
       CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

      #cria array
      LET m_table_reference1 = _ADVPL_create_component(NULL,"LBROWSEEX",m_layoutmanager_refence_2)
      CALL _ADVPL_set_property(m_table_reference1,"SIZE",500,400)
      CALL _ADVPL_set_property(m_table_reference1,"CAN_ADD_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference1,"CAN_REMOVE_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference1,"ALIGN","LEFT")
      CALL _ADVPL_set_property(m_table_reference1,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_table_reference1,"ENABLE",TRUE)
      CALL _ADVPL_set_property(m_table_reference1,"BEFORE_ROW_EVENT","geo1011_exibe_clientes")
      CALL _ADVPL_set_property(m_table_reference1,"AFTER_ROW_EVENT","geo1011_after_row")

      #cria campo do array: cod_roteiro
      LET m_column_cod_roteiro = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_cod_roteiro,"VARIABLE","cod_roteiro")
      CALL _ADVPL_set_property(m_column_cod_roteiro,"HEADER","Roteiro")
      CALL _ADVPL_set_property(m_column_cod_roteiro,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_column_cod_roteiro,"EDITABLE", TRUE)

      CALL _ADVPL_set_property(m_column_cod_roteiro,"ORDER",TRUE)

      CALL _ADVPL_set_property(m_column_cod_roteiro,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_column_cod_roteiro,"EDIT_PROPERTY","LENGTH",4,0)
      CALL _ADVPL_set_property(m_column_cod_roteiro,"EDIT_PROPERTY","VALID","geo1011_valid_cod_roteiro")
      CALL _ADVPL_set_property(m_column_cod_roteiro,"EDITABLE", FALSE)
       
      #cria campo do array: den_roteiro
      LET m_column_den_roteiro = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_den_roteiro,"VARIABLE","den_roteiro")
      CALL _ADVPL_set_property(m_column_den_roteiro,"HEADER","Descrição do Roteiro")
      CALL _ADVPL_set_property(m_column_den_roteiro,"COLUMN_SIZE", 150)
      CALL _ADVPL_set_property(m_column_den_roteiro,"EDITABLE", FALSE)

      CALL _ADVPL_set_property(m_column_den_roteiro,"ORDER",TRUE)

      CALL _ADVPL_set_property(m_column_den_roteiro,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_column_den_roteiro,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_column_den_roteiro,"EDIT_PROPERTY","VALID","geo1011_valid_den_roteiro")
      CALL _ADVPL_set_property(m_column_den_roteiro,"EDITABLE", FALSE)
      
       
      #-- Zoom
      LET m_column_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_table_reference1)
      CALL _ADVPL_set_property(m_column_reference,"COLUMN_SIZE",10)
      CALL _ADVPL_set_property(m_column_reference,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_column_reference,"NO_VARIABLE",TRUE)
      CALL _ADVPL_set_property(m_column_reference,"IMAGE", "BTPESQ")
      CALL _ADVPL_set_property(m_column_reference,"BEFORE_EDIT_EVENT","geo1011_zoom_roteiro")
      
    # let ma_pedidos[1].num_pedido = '123'
     CALL _ADVPL_set_property(m_table_reference1,"SET_ROWS",ma_tela,0)
     CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)

     CALL _ADVPL_set_property(m_table_reference1,"REFRESH")

#cria array
      LET m_table_reference2 = _ADVPL_create_component(NULL,"LBROWSEEX",m_layoutmanager_refence_2)
      CALL _ADVPL_set_property(m_table_reference2,"SIZE",800,400)
      CALL _ADVPL_set_property(m_table_reference2,"CAN_ADD_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference2,"CAN_REMOVE_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference2,"ALIGN","CENTER")
      CALL _ADVPL_set_property(m_table_reference2,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_table_reference2,"ENABLE",TRUE)
      CALL _ADVPL_set_property(m_table_reference2,"BEFORE_REMOVE_ROW_EVENT","geo1011_delete_row")

      #cria campo do array: cod_roteiro
      LET m_column_cod_roteiro2 = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference2)
      CALL _ADVPL_set_property(m_column_cod_roteiro2,"VARIABLE","cod_roteiro")
      CALL _ADVPL_set_property(m_column_cod_roteiro2,"HEADER","Roteiro")
      CALL _ADVPL_set_property(m_column_cod_roteiro2,"COLUMN_SIZE", 20)
      CALL _ADVPL_set_property(m_column_cod_roteiro2,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_cod_roteiro2,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_column_cod_roteiro2,"EDIT_PROPERTY","LENGTH",15)
      #CALL _ADVPL_set_property(m_column_cod_roteiro2,"EDIT_PROPERTY","VALID","geo1011_valid_cod_cliente")
      CALL _ADVPL_set_property(m_column_cod_roteiro2,"EDITABLE", FALSE)
      
      #cria campo do array: cod_roteiro
      LET m_column_seq_visita = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference2)
      CALL _ADVPL_set_property(m_column_seq_visita,"VARIABLE","seq_visita")
      CALL _ADVPL_set_property(m_column_seq_visita,"HEADER","Seq")
      CALL _ADVPL_set_property(m_column_seq_visita,"COLUMN_SIZE", 20)
      CALL _ADVPL_set_property(m_column_seq_visita,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_seq_visita,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_column_seq_visita,"EDIT_PROPERTY","LENGTH",15)
      #CALL _ADVPL_set_property(m_column_seq_visita,"EDIT_PROPERTY","VALID","geo1011_valid_cod_cliente")
      CALL _ADVPL_set_property(m_column_seq_visita,"EDITABLE", FALSE)
      
       
      #cria campo do array: cod_roteiro
      LET m_column_cod_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference2)
      CALL _ADVPL_set_property(m_column_cod_cliente,"VARIABLE","cod_cliente")
      CALL _ADVPL_set_property(m_column_cod_cliente,"HEADER","Cliente")
      CALL _ADVPL_set_property(m_column_cod_cliente,"COLUMN_SIZE", 20)
      CALL _ADVPL_set_property(m_column_cod_cliente,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_cod_cliente,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_column_cod_cliente,"EDIT_PROPERTY","LENGTH",15)
      CALL _ADVPL_set_property(m_column_cod_cliente,"EDIT_PROPERTY","VALID","geo1011_valid_cod_cliente")
      CALL _ADVPL_set_property(m_column_cod_cliente,"EDITABLE", FALSE)
      
       
      #cria campo do array: den_roteiro
      LET m_column_nom_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference2)
      CALL _ADVPL_set_property(m_column_nom_cliente,"VARIABLE","nom_cliente")
      CALL _ADVPL_set_property(m_column_nom_cliente,"HEADER","Nome Cliente")
      CALL _ADVPL_set_property(m_column_nom_cliente,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_column_nom_cliente,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_nom_cliente,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_column_nom_cliente,"EDIT_PROPERTY","LENGTH",36) 
      #CALL _ADVPL_set_property(m_column_nom_cliente,"EDIT_PROPERTY","VALID","geo1011_valid_den_roteiro")
      CALL _ADVPL_set_property(m_column_nom_cliente,"EDITABLE", FALSE)
      
      
      #-- Zoom
      LET m_column_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_table_reference2)
      CALL _ADVPL_set_property(m_column_reference,"COLUMN_SIZE",10)
      CALL _ADVPL_set_property(m_column_reference,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_column_reference,"NO_VARIABLE",TRUE)
      CALL _ADVPL_set_property(m_column_reference,"IMAGE", "BTPESQ")
      CALL _ADVPL_set_property(m_column_reference,"BEFORE_EDIT_EVENT","geo1011_zoom_roteiro")
      
      
       #cria campo do array: den_roteiro
       LET m_column_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference2)
       CALL _ADVPL_set_property(m_column_reference,"VARIABLE","cod_vendedor")
       CALL _ADVPL_set_property(m_column_reference,"HEADER","Cód.Vendedor")
       CALL _ADVPL_set_property(m_column_reference,"COLUMN_SIZE", 25)
       CALL _ADVPL_set_property(m_column_reference,"ORDER",TRUE)
    
       #cria campo do array: den_roteiro
       LET m_column_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference2)
       CALL _ADVPL_set_property(m_column_reference,"VARIABLE","nom_vendedor")
       CALL _ADVPL_set_property(m_column_reference,"HEADER","Nome Vendedor")
       CALL _ADVPL_set_property(m_column_reference,"COLUMN_SIZE", 25)
       CALL _ADVPL_set_property(m_column_reference,"ORDER",TRUE)
  
       #cria campo do array: den_roteiro
       LET m_column_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference2)
       CALL _ADVPL_set_property(m_column_reference,"VARIABLE","situacao")
       CALL _ADVPL_set_property(m_column_reference,"HEADER","Situação")
       CALL _ADVPL_set_property(m_column_reference,"COLUMN_SIZE", 25)
       CALL _ADVPL_set_property(m_column_reference,"ORDER",TRUE)
  
  
  
  
             
    # let ma_pedidos[1].num_pedido = '123'
     CALL _ADVPL_set_property(m_table_reference2,"SET_ROWS",ma_clientes,0)
     CALL _ADVPL_set_property(m_table_reference2,"ITEM_COUNT",0)
     CALL _ADVPL_set_property(m_table_reference2,"REFRESH")
     CALL _ADVPL_set_property(m_form_principal,"ACTIVATE",TRUE)

 END FUNCTION

#---------------------------#
FUNCTION geo1011_incluir()
#---------------------------#

   INITIALIZE mr_tela.*, ma_tela to null

   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
 

   LET mr_tela.cod_empresa  = p_cod_empresa
     

   CALL geo1011_habilita_campos_manutencao(TRUE,'INCLUIR')

END FUNCTION

#-----------------------------#
 function geo1011_modificar()
#-----------------------------#
   define l_msg char(80)

   

  call geo1011_habilita_campos_manutencao(TRUE,'MODIFICAR')

 end function

#-----------------------------#
 function geo1011_excluir()
#-----------------------------#
   define l_msg char(80)

 

    let l_msg = 'Confirma a exclusão da rota do Vendedor: ', mr_tela.cod_repres, '?'
    IF LOG_pergunta(l_msg) THEN
    else
       return false
    end if

       delete from geo_rot_repres
       where cod_empresa = p_cod_empresa
         and cod_repres = mr_tela.cod_repres  



  initialize mr_tela.* to null
  initialize ma_tela  to null
  CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)
  CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
 
END FUNCTION
 
#---------------------------#
 function geo1011_confirmar_inclusao()
#---------------------------#
   CALL LOG_progress_start("Processa","geo1011_processa_inclusao","PROCESS")
   
end function

#---------------------------#
function geo1011_processa_inclusao()  
#---------------------------# 
   CALL geo1011_after_row()
   CALL geo1011_atualiza_dados('INCLUSAO')
   CALL geo1011_habilita_campos_manutencao(FALSE,'INCLUIR')

   RETURN TRUE

 end function

#---------------------------#
 function  geo1011_cancelar_inclusao()
#---------------------------#
  call geo1011_habilita_campos_manutencao(FALSE,'INCLUIR')

 end function

#---------------------------#
 function geo1011_confirmar_modificacao()
#---------------------------#
   
   CALL LOG_progress_start("Processa","geo1011_processa_modificacao","PROCESS")
END FUNCTION
#---------------------------#
function geo1011_processa_modificacao()  
#---------------------------# 
   CALL geo1011_after_row()
   CALL geo1011_habilita_campos_manutencao(FALSE,'MODIFICAR')
   CALL geo1011_atualiza_dados('MODIFICACAO')

   RETURN TRUE

 end function
#
#---------------------------#
 function  geo1011_cancelar_modificacao()
#---------------------------#

  CALL geo1011_habilita_campos_manutencao(FALSE,'MODIFICAR')

 end function

#----------------------------------------------#
 function geo1011_atualiza_dados(l_funcao)
#----------------------------------------------#

   DEFINE l_funcao char(20)
   DEFINE l_ind    integer
   DEFINE l_data   date
   DEFINE l_hora   char(8)
   DEFINE l_roteiro    SMALLINT
   DEFINE lr_roteiros RECORD
             cod_empresa CHAR(2),
             cod_roteiro INTEGER,
             seq_visita  INTEGER,
             cod_cliente CHAR(15)
         END RECORD
   
   LET l_data = TODAY
   LET l_hora = TIME
   
   CALL log085_transacao('BEGIN')
   
   
   
   if l_funcao = 'MODIFICACAO' then
      delete from geo_rot_repres
       where cod_empresa = p_cod_empresa
         and cod_repres = mr_tela.cod_repres 
   end if

   for l_ind = 1 to 5000
      if ma_tela[l_ind].cod_roteiro is null then
         exit for
      end if

      insert into geo_rot_repres ( cod_empresa
                                 , cod_repres
                                 , cod_roteiro 
                                 , den_roteiro) values
                                (
                                 p_cod_empresa,
                                 mr_tela.cod_repres,
                                 ma_tela[l_ind].cod_roteiro, 
                                 ma_tela[l_ind].den_roteiro 
                                 )
   end for
   
   
   DECLARE cq_temp1 CURSOR WITH HOLD FOR
   SELECT DISTINCT cod_roteiro
     FROM t_roteiros
   FOREACH cq_temp1 INTO l_roteiro
      DELETE
        FROM geo_roteiros
       WHERE cod_empresa = p_cod_empresa
         AND cod_roteiro = l_roteiro
   END FOREACH
   
   DECLARE cq_temp CURSOR WITH HOLD FOR
   SELECT *
     FROM t_roteiros
   FOREACH cq_temp INTO lr_roteiros.*
      IF lr_roteiros.cod_cliente IS NULL OR lr_roteiros.cod_cliente = " " THEN
         CONTINUE FOREACH
      END IF
      INSERT INTO geo_roteiros VALUES (lr_roteiros.*)
   END FOREACH
   CALL log085_transacao('COMMIT')

END FUNCTION

#----------------------------------------------#
 function geo1011_habilita_campos_manutencao(l_status,l_funcao)
#----------------------------------------------#

   DEFINE l_status smallint
   
   define l_funcao char(20)

   IF l_funcao = 'INCLUIR' THEN
      CALL _ADVPL_set_property(m_refer_cod_repres,"ENABLE",l_status) 
      CALL _ADVPL_set_property(m_btn_zoom_repres,"ENABLE",l_status) 
   END IF 
   
   CALL _ADVPL_set_property(m_table_reference1,"CAN_ADD_ROW",l_status)
   CALL _ADVPL_set_property(m_table_reference1,"CAN_REMOVE_ROW",l_status)
   CALL _ADVPL_set_property(m_table_reference1,"EDITABLE",l_status)
   
   CALL _ADVPL_set_property(m_table_reference2,"CAN_ADD_ROW",l_status)
   CALL _ADVPL_set_property(m_table_reference2,"CAN_REMOVE_ROW",l_status)
   CALL _ADVPL_set_property(m_table_reference2,"EDITABLE",l_status)
   
   CALL _ADVPL_set_property(m_column_cod_roteiro,"EDITABLE", l_status)
   CALL _ADVPL_set_property(m_column_den_roteiro,"EDITABLE", l_status)
   CALL _ADVPL_set_property(m_column_seq_visita,"EDITABLE", l_status)
   CALL _ADVPL_set_property(m_column_cod_cliente,"EDITABLE", l_status)
   
#   seq_visita

END FUNCTION
#
       
 
#-------------------------------------------#
 function geo1011_pesquisar()
#-------------------------------------------#

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

      #################  cria campos tela

      #cria janela principal do tipo LDIALOG
      LET m_form_filtro = _ADVPL_create_component(NULL,"LDIALOG")
      CALL _ADVPL_set_property(m_form_filtro,"TITLE","FILTROS")
      CALL _ADVPL_set_property(m_form_filtro,"ENABLE_ESC_CLOSE",FALSE)
      CALL _ADVPL_set_property(m_form_filtro,"SIZE",500,540) 

      #cria menu
      LET l_toolbar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_filtro)

      #botao informar
      LET m_botao_find = _ADVPL_create_component(NULL,"LInformButton",l_toolbar)
      CALL _ADVPL_set_property(m_botao_find,"EVENT","geo1011_entrada_dadaos_filtro")
      CALL _ADVPL_set_property(m_botao_find,"CONFIRM_EVENT","geo1011_confirmar_filtro")
      CALL _ADVPL_set_property(m_botao_find,"CANCEL_EVENT","geo1011_cancela_filtro")
 
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
      
      #
      #
      #    CABEÇALHO
      #
      LET l_layoutmanager_refence_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference_1)
      CALL _ADVPL_set_property(l_layoutmanager_refence_1,"MARGIN",TRUE)
      CALL _ADVPL_set_property(l_layoutmanager_refence_1,"COLUMNS_COUNT",2)
 
      LET l_layoutmanager_refence_2 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference_2)
      CALL _ADVPL_set_property(l_layoutmanager_refence_2,"MARGIN",TRUE)
      CALL _ADVPL_set_property(l_layoutmanager_refence_2,"COLUMNS_COUNT",2)

      #cria campo cod_roteiro
      CALL LOG_cria_rotulo(l_layoutmanager_refence_1,"Vendedor:")
      LET m_refer_filtro_2 = LOG_cria_textfield(l_layoutmanager_refence_1,15)
      CALL _ADVPL_set_property(m_refer_filtro_2,"VARIABLE",mr_filtro,"cod_repres")
      CALL _ADVPL_set_property(m_refer_filtro_2,"ENABLE",FALSE)

      LET m_btn_selecionar_1 = _ADVPL_create_component(NULL, "LBUTTON", l_layoutmanager_refence_2)
      CALL _ADVPL_set_property(m_btn_selecionar_1,"TEXT", "Selecionar Vendedor")
      CALL _ADVPL_set_property(m_btn_selecionar_1,"CLICK_EVENT","geo1011_zoom_rot_repres")
      CALL _ADVPL_set_property(m_btn_selecionar_1,"SIZE",100,20)
      CALL _ADVPL_set_property(m_btn_selecionar_1,"POSITION",415,118)

      CALL _ADVPL_set_property(m_btn_selecionar_1,"ENABLE",FALSE)
 
      CALL _ADVPL_set_property(m_form_filtro,"ACTIVATE",TRUE)

end function 


#--------------------------------------------------------------------#
  function geo1011_entrada_dadaos_filtro()
#--------------------------------------------------------------------#
   initialize mr_filtro.* to null
 
 
   CALL _ADVPL_set_property(m_refer_filtro_2,"ENABLE",TRUE)
   

   CALL _ADVPL_set_property(m_btn_selecionar_1,"ENABLE",TRUE)

 end function
 
#--------------------------------------------------------------------#
  function geo1011_confirmar_filtro()
#--------------------------------------------------------------------#
    define l_sql_stmt  char(5000)
   CALL _ADVPL_set_property(m_form_filtro,"ACTIVATE",FALSE)
   
   let mr_tela.cod_repres = null
   let mr_tela.cod_repres  = mr_filtro.cod_repres
   
   let l_sql_stmt  =
   ' select cod_empresa, cod_repres   ',
   '   from geo_rot_repres                                                                            ',
   '  where cod_empresa  = "', p_cod_empresa, '" '


   if mr_tela.cod_repres is not null then
      let l_sql_stmt = l_sql_stmt clipped,
                       ' AND cod_repres = "', mr_tela.cod_repres, '" '
      
   end if

   let l_sql_stmt = l_sql_stmt clipped,
   ' group by cod_empresa, cod_repres   ',
   ' order by cod_repres        '

   prepare var_query from l_sql_stmt
   declare cq_consulta SCROLL cursor  WITH HOLD for var_query

   open cq_consulta
   fetch cq_consulta into mr_tela.cod_empresa, mr_tela.cod_repres
   
   
   if sqlca.sqlcode = 0 then
      LET m_ies_onsulta = TRUE
      CALL geo1011_exibe_dados()
      CALL _ADVPL_set_property(m_table_reference1,"EDITABLE",FALSE)
      
   end if
   
 end function
 
#--------------------------------------------------------------------#
  function geo1011_cancela_filtro()
#--------------------------------------------------------------------#
 
   CALL _ADVPL_set_property(m_form_filtro,"ACTIVATE",FALSE)

 end function

#-------------------------------------------#
 function geo1011_zoom_roteiro()
#-------------------------------------------#
   
   define l_ind integer 
   define l_selecao integer  
   
   define l_sql_stmt char(4000)
   
   LET l_selecao = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   
   if l_selecao < 1 then
     return true 
   end if 
   

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

   
   
   let l_ind = 1
    let ma_tela[l_selecao].cod_roteiro = ip_zoom_get_valorb()
    
    for l_ind = 1 to 5000
       if ma_tela[l_ind].cod_roteiro is null or ma_tela[l_ind].cod_roteiro = ' ' then
          exit for
       end if
       
    end for 
    let l_ind = l_ind - 1
   
    CALL geo1011_valid_cod_roteiro()
    CALL geo1011_exibe_clientes()
    CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",l_ind)
    CALL _ADVPL_set_property(m_table_reference1,"REFRESH")

 end function
 
#-------------------------------------------#
 function geo1011_zoom_rot_repres()
#-------------------------------------------#

   define l_sql_stmt char(4000)

   #
   call ip_zoom_zoom_cadastro_2_colunas('geo_rot_repres',
                                'cod_empresa',
                                '2',
                                'cod_repres',
                                '30',
                                'Empresa: ',
                                'Representante: ',
                                'cod_empresa',
                                'GROUP BY cod_empresa, cod_repres  ORDER BY cod_repres   ')

   let mr_filtro.cod_repres =  ip_zoom_get_valorb()
   #
    
    
   

  

 end function
# 

#-------------------------------------#
 FUNCTION geo1011_primeiro()
#-------------------------------------#
    CALL geo1011_paginacao("PRIMEIRO")
 end function

#-------------------------------------#
 FUNCTION geo1011_anterior()
#-------------------------------------#
   CALL geo1011_paginacao("ANTERIOR")
 end function

#-------------------------------------#
 FUNCTION geo1011_seguinte()
#-------------------------------------#
     CALL geo1011_paginacao("SEGUINTE")
 end function

#-------------------------------------#
 FUNCTION geo1011_ultimo()
#-------------------------------------#
    CALL geo1011_paginacao("ULTIMO")
 end function

#
#-------------------------------------#
 FUNCTION geo1011_paginacao(l_funcao)
#-------------------------------------#

   DEFINE l_funcao    CHAR(10),
          l_status    SMALLINT

   LET l_funcao = l_funcao CLIPPED

   let mr_telar.* = mr_tela.*

   IF m_ies_onsulta THEN


      WHILE TRUE
         CASE
            WHEN l_funcao = "SEGUINTE"

                  FETCH NEXT cq_consulta INTO mr_tela.cod_empresa ,
                                              mr_tela.cod_repres    

               IF sqlca.sqlcode <> 0 THEN
                  #CALL log003_err_sql ("NEXT","cq_orcamentos")
                  #EXIT WHILE
               END IF

            WHEN l_funcao = "ANTERIOR"

                 FETCH PREVIOUS cq_consulta INTO mr_tela.cod_empresa ,
                                                 mr_tela.cod_repres  

               IF sqlca.sqlcode <> 0 THEN
                  #CALL log003_err_sql ("PREVIOUS","cq_orcamentos")
                  #EXIT WHILE
               END IF

            WHEN l_funcao = "PRIMEIRO"

                  FETCH FIRST cq_consulta INTO mr_tela.cod_empresa ,
                                               mr_tela.cod_repres  

               IF sqlca.sqlcode <> 0 THEN
                  #CALL log003_err_sql ("FIRST","cq_orcamentos")
                  #EXIT WHILE
               END IF

            WHEN l_funcao = "ULTIMO"

                  FETCH LAST cq_consulta INTO mr_tela.cod_empresa ,
                                              mr_tela.cod_repres  

            IF sqlca.sqlcode <> 0 THEN
               #CALL log003_err_sql ("LAST","cq_orcamentos")
               #EXIT WHILE
            END IF
         END CASE
         IF sqlca.sqlcode = NOTFOUND THEN
            CALL geo1011_exibe_mensagem_barra_status("Não existem mais itens nesta direcao.","ERRO")
            let mr_tela.* = mr_telar.*
            EXIT WHILE
         ELSE
            LET m_ies_onsulta = TRUE
         END IF

         select cod_empresa, cod_repres 
           INTO mr_tela.cod_empresa ,
                mr_tela.cod_repres  
          from geo_rot_repres
         where cod_empresa  = p_cod_empresa
           and cod_repres    = mr_tela.cod_repres 
         group by cod_empresa, cod_repres  

         IF sqlca.sqlcode = 0 THEN

            EXIT WHILE

         END IF

      END WHILE
   ELSE
      CALL geo1011_exibe_mensagem_barra_status("Efetue primeiramente a consulta.","ERRO")
   END IF


  CALL geo1011_exibe_dados()

 END FUNCTION
 
 #--------------------------------------------------------------------#
 FUNCTION geo1011_exibe_mensagem_barra_status(l_mensagem,l_tipo_mensagem)
#--------------------------------------------------------------------#

   DEFINE l_mensagem               CHAR(500),
          l_tipo_mensagem          CHAR(010),
          l_tipo_mensagem_original CHAR(015)

   LET l_tipo_mensagem_original = LOG_retorna_tipo_mensagem_original(UPSHIFT(l_tipo_mensagem),TRUE)
   CALL _ADVPL_set_property(m_status_bar,l_tipo_mensagem_original CLIPPED," "||l_mensagem CLIPPED)

 END FUNCTION

 
#--------------------------------------------------------------------#
 function geo1011_exibe_dados()
#--------------------------------------------------------------------#
 
   define l_seq_visita   integer 
   define l_cod_roteiro  decimal(4,0)   
   define l_den_roteiro  char(30)   
 
   define l_ind          integer
  
   let l_ind = 0 
   
   select raz_social
     into mr_tela.raz_social
    from representante
   where cod_repres = mr_tela.cod_repres  
   
   initialize ma_tela to null
   
   declare cq_roteiros cursor for
   select a.cod_roteiro, a.den_roteiro 
     from geo_rot_repres a 
    where a.cod_empresa = p_cod_empresa
      and a.cod_repres = mr_tela.cod_repres 
      
   foreach cq_roteiros into l_cod_roteiro, l_den_roteiro
   
      let l_ind = l_ind + 1
      let ma_tela[l_ind].cod_roteiro    = l_cod_roteiro 
      let ma_tela[l_ind].den_roteiro    = l_den_roteiro 
      
   end foreach 
   
   DELETE FROM t_roteiros WHERE 1=1
   
  INSERT INTO t_roteiros
  SELECT *
    FROM geo_roteiros
   WHERE cod_empresa = p_cod_empresa
     AND cod_roteiro IN (SELECT cod_roteiro 
                           FROM geo_rot_repres 
                          WHERE cod_repres = mr_tela.cod_repres)
   
   
   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",l_ind)              
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")                       
   
 end function

#--------------------------------#
FUNCTION geo1011_exibe_clientes()
#--------------------------------#
   DEFINE l_ind             SMALLINT
   DEFINE l_arr_curr        SMALLINT
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   
   INITIALIZE ma_clientes TO NULL
   
   #SELECT DISTINCT cod_empresa
   #  FROM t_roteiros 
   # WHERE cod_empresa = p_cod_empresa
   #   AND cod_roteiro IN (SELECT cod_roteiro FROM geo_rot_repres WHERE cod_repres = mr_tela.cod_repres)
   #IF sqlca.sqlcode = NOTFOUND THEN
   #   INSERT INTO t_roteiros
   #   SELECT *
   #     FROM geo_roteiros
   #    WHERE cod_empresa = p_cod_empresa
   #      AND cod_roteiro IN (SELECT cod_roteiro FROM geo_rot_repres WHERE cod_repres = mr_tela.cod_repres)
   #END IF 
   
   DECLARE cq_clientes CURSOR FOR
   SELECT a.cod_roteiro, a.seq_visita, a.cod_cliente, b.nom_cliente
     FROM t_roteiros a, clientes b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.cod_roteiro = ma_tela[l_arr_curr].cod_roteiro
      AND a.cod_cliente = b.cod_cliente
   ORDER BY a.seq_visita
   LET l_ind = 1
   FOREACH cq_clientes INTO ma_clientes[l_ind].*
    
    
   declare cq_nivel3 cursor for 
   select cod_nivel_3, raz_social 
   from cli_canal_venda a, representante b
   where cod_cliente =  ma_clientes[l_ind].cod_cliente
   and a.cod_nivel_3 = b.cod_repres
   open cq_nivel3 
   fetch cq_nivel3 into ma_clientes[l_ind].cod_vendedor, ma_clientes[l_ind].nom_vendedor 
  
  declare cq_credcadcli cursor for 
   select des_forma 
    from credcad_cli   a,
      forma_aprovacao b
     where b.ies_forma_aprov = a.ies_aprovacao
     and cod_cliente = ma_clientes[l_ind].cod_cliente
  open cq_credcadcli
  fetch cq_credcadcli into ma_clientes[l_ind].situacao
 
 
 
   

      LET l_ind = l_ind + 1
   END FOREACH
   
   IF l_ind > 1 THEN
      LET l_ind = l_ind - 1
   END IF 
   
   CALL _ADVPL_set_property(m_table_reference2,"ITEM_COUNT", l_ind)
   CALL _ADVPL_set_property(m_table_reference2,"REFRESH")
   
END FUNCTION
#------------------------------------#
 function geo1011_valid_cod_roteiro()
#------------------------------------#
   DEFINE l_selecao            INTEGER 
   DEFINE l_ind                SMALLINT
   
   LET l_selecao = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   
   if l_selecao < 1 then
     return true 
   end if
   
   FOR l_ind = 1 TO _ADVPL_get_property(m_table_reference1,"ITEM_COUNT")
      IF l_ind <> l_selecao THEN
         IF ma_tela[l_ind].cod_roteiro = ma_tela[l_selecao].cod_roteiro THEN
            CALL _ADVPL_message_box("O roteiro "||ma_tela[l_selecao].cod_roteiro||" já foi informado para o vendedor "||mr_tela.cod_repres)
            LET ma_tela[l_selecao].cod_roteiro = ""
            CALL _ADVPL_set_property(m_column_cod_roteiro,"REFRESH")
            RETURN FALSE
         END IF 
      END IF 
   END FOR 
   
   DECLARE cq_ver_cod_rot CURSOR FOR 
   SELECT DISTINCT a.cod_cliente
     FROM geo_roteiros a, geo_rot_repres b
    WHERE a.cod_empresa = b.cod_empresa
      AND a.cod_roteiro = b.cod_roteiro
      AND b.cod_repres = mr_tela.cod_repres
      AND a.cod_roteiro <> ma_tela[l_selecao].cod_roteiro
      AND a.cod_cliente IN (SELECT cod_cliente 
                              FROM geo_roteiros 
                             WHERE cod_empresa = p_cod_empresa
                               AND cod_roteiro = ma_tela[l_selecao].cod_roteiro)
    

   OPEN cq_ver_cod_rot
   FETCH cq_ver_cod_rot
   IF sqlca.sqlcode = 0 THEN
      CALL _ADVPL_message_box("Este roteiro contém clientes já incluídos em outros roteiros do vendedor.")
      LET ma_tela[l_selecao].cod_roteiro = ""
      CALL _ADVPL_set_property(m_column_cod_roteiro,"REFRESH")
      RETURN FALSE
   END IF 
   
   CALL geo1011_exibe_clientes()
   
 return true 
 
 end function 
 
 
 
 #--------------------------------------------------------------------#
 function geo1011_valid_den_roteiro()
#--------------------------------------------------------------------#
   define l_selecao integer 
   
   LET l_selecao = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   
   if l_selecao < 1 then
     return true 
   end if 
   
   IF ma_tela[l_selecao].den_roteiro IS NULL or ma_tela[l_selecao].den_roteiro = "" THEN
      CALL _ADVPL_message_box("Descrição do Roteiro deve ser preenchido")
      RETURN FALSE
   END IF
  #
 return true 
 
 end function 
 
#--------------------------------------------------------------------#
 function geo1011_valid_repres()
#--------------------------------------------------------------------#
   
   select raz_social
     into mr_tela.raz_social
    from representante
   where cod_repres = mr_tela.cod_repres  
 
   IF sqlca.sqlcode = 100 THEN
      CALL _ADVPL_message_box("Representante não encontrado.")
      RETURN FALSE
   END IF
   
   
   select distinct(cod_empresa)
     from geo_rot_repres
    where cod_empresa = p_cod_empresa
     and cod_repres   = mr_tela.cod_repres  
   IF sqlca.sqlcode = 0 THEN
      CALL _ADVPL_message_box("Representante já cadastrado.")
      RETURN FALSE
   END IF
  #
 return true 
 end function 
 
 
 
 
 #-------------------------------------------#
 function geo1011_zoom_representante()
#-------------------------------------------#

   define l_sql_stmt char(4000)

   #
   call ip_zoom_zoom_cadastro_2_colunas('representante',
                                'cod_repres',
                                '4',
                                'raz_social',
                                '36',
                                'Código: ',
                                'Nome: ',
                                ' ',
                                'ORDER BY cod_repres   ')

   let mr_tela.cod_repres =  ip_zoom_get_valor()
   let mr_tela.raz_social =  ip_zoom_get_valorb()
   #
    
 end function
#------------------------------------#
FUNCTION geo1011_valid_cod_cliente()
#------------------------------------#
   DEFINE l_arr_curr          SMALLINT
   
   IF NOT geo1011_valida_cli_vend() THEN
      RETURN FALSE
   END IF 
   LET l_arr_curr = _ADVPL_get_property(m_table_reference2,"ITEM_SELECTED")
   
   SELECT nom_cliente
     INTO ma_clientes[l_arr_curr].nom_cliente
     FROM clientes
    WHERE cod_cliente = ma_clientes[l_arr_curr].cod_cliente
END FUNCTION


#------------------------------#
FUNCTION geo1011_temp_roteiros()
#------------------------------#
   WHENEVER ERROR CONTINUE
   DROP TABLE t_roteiros;
   CREATE  TABLE t_roteiros (
      cod_empresa CHAR(2),
      cod_roteiro INTEGER,
      seq_visita  INTEGER,
      cod_cliente CHAR(15)
   );
   CREATE INDEX idx1_t_roteiros ON t_roteiros (cod_empresa);
   CREATE INDEX idx2_t_roteiros ON t_roteiros (cod_empresa, cod_roteiro);
   CREATE INDEX idx3_t_roteiros ON t_roteiros (cod_empresa, cod_roteiro, seq_visita);
   CREATE INDEX idx4_t_roteiros ON t_roteiros (cod_empresa, cod_roteiro, seq_visita, cod_cliente);
   CREATE INDEX idx5_t_roteiros ON t_roteiros (cod_roteiro);
   CREATE INDEX idx6_t_roteiros ON t_roteiros (cod_cliente);
   CREATE INDEX idx7_t_roteiros ON t_roteiros (cod_empresa, cod_roteiro);
   CREATE INDEX idx8_t_roteiros ON t_roteiros (cod_empresa, cod_cliente);
   CREATE INDEX idx9_t_roteiros ON t_roteiros (cod_empresa, cod_roteiro, cod_cliente);
   WHENEVER ERROR STOP
END FUNCTION


#--------------------------#
FUNCTION geo1011_after_row()
#--------------------------#
   DEFINE l_arr_curr     SMALLINT
   DEFINE l_arr_count    SMALLINT
   DEFINE l_ind          SMALLINT
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference1, "ITEM_SELECTED")
   LET l_arr_count = _ADVPL_get_property(m_table_reference2, "ITEM_COUNT")
   
   #DELETE 
   #  FROM t_roteiros
   # WHERE cod_empresa = p_cod_empresa
   #   AND cod_roteiro IN (SELECT cod_roteiro FROM geo_rot_repres WHERE cod_repres = mr_tela.cod_repres)
   #FOR l_ind = 1 TO l_arr_count
   #   INSERT INTO t_roteiros VALUES (p_cod_empresa, 
   #                                  ma_tela[l_arr_curr].cod_roteiro,
   #                                  ma_clientes[l_ind].seq_visita,
   #                                  ma_clientes[l_ind].cod_cliente)
   #                                  
   #END FOR 
   
END FUNCTION


#---------------------------------#
FUNCTION geo1011_valida_cli_vend()
#---------------------------------#
   DEFINE l_arr_curr1        SMALLINT
   DEFINE l_arr_curr        SMALLINT
   DEFINE l_ind             SMALLINT
   DEFINE l_roteiro         INTEGER
   DEFINE l_rots            CHAR(99)
   
   LET l_arr_curr1 = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   LET l_arr_curr = _ADVPL_get_property(m_table_reference2,"ITEM_SELECTED")
   
   FOR l_ind = 1 TO _ADVPL_get_property(m_table_reference2,"ITEM_COUNT")
      IF l_ind <> l_arr_curr THEN
         IF ma_clientes[l_ind].cod_cliente = ma_clientes[l_arr_curr].cod_cliente THEN
            CALL _ADVPL_message_box("Cliente "||ma_clientes[l_arr_curr].cod_cliente||" já cadastrado neste roteiro")
            LET ma_clientes[l_arr_curr].cod_cliente = ""
            RETURN FALSE
         END IF 
      END IF 
   END FOR
   
   LET l_rots = ""
   DECLARE cq_ver_rot_cli_vend CURSOR FOR
   SELECT DISTINCT a.cod_roteiro
     FROM t_roteiros a, geo_rot_repres b
    WHERE a.cod_empresa = b.cod_empresa
      AND a.cod_roteiro = b.cod_roteiro
      AND a.cod_cliente = ma_clientes[l_arr_curr].cod_cliente
      AND b.cod_repres = mr_tela.cod_repres
      AND a.cod_roteiro <> ma_tela[l_arr_curr1].cod_roteiro
   FOREACH cq_ver_rot_cli_vend INTO l_roteiro
      LET l_rots = l_rots CLIPPED,",",l_roteiro
   END FOREACH
   IF l_rots IS NOT NULL AND l_rots <> " " THEN
      LET l_rots = l_rots[2,99]
      CALL _ADVPL_message_box("Cliente "||ma_clientes[l_arr_curr].cod_cliente||" já cadastrado nos roteiros "||l_rots)
      LET ma_clientes[l_arr_curr].cod_cliente = ""
      CALL _ADVPL_set_property(m_column_cod_cliente,"REFRESH")
      RETURN FALSE
   END IF 
   
   SELECT *
     FROM clientes
    WHERE cod_cliente = ma_clientes[l_arr_curr].cod_cliente
   IF sqlca.sqlcode <> 0 THEN
      CALL _ADVPL_message_box("Cliente não encontrado")
      RETURN FALSE
   END IF 
   
   SELECT *
     FROM t_roteiros
    WHERE cod_empresa = p_cod_empresa
      AND cod_roteiro = ma_tela[l_arr_curr1].cod_roteiro
      AND cod_cliente = ma_clientes[l_arr_curr].cod_cliente
   IF sqlca.sqlcode <> 0 THEN
   
      INSERT INTO t_roteiros VALUES (p_cod_empresa,
                                     ma_tela[l_arr_curr1].cod_roteiro,
                                     ma_clientes[l_arr_curr].seq_visita,
                                     ma_clientes[l_arr_curr].cod_cliente)
   END IF 
                                  
                                  
   RETURN TRUE
END FUNCTION

#----------------------------#
FUNCTION geo1011_delete_row()
#----------------------------#
   DEFINE l_arr_curr1    INTEGER
   DEFINE l_arr_curr2    INTEGER
   
   LET l_arr_curr1 = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   LET l_arr_curr2 = _ADVPL_get_property(m_table_reference2,"ITEM_SELECTED")
   
   DELETE 
     FROM t_roteiros
    WHERE cod_empresa = p_cod_empresa
      AND cod_roteiro = ma_tela[l_arr_curr1].cod_roteiro
      AND cod_cliente = ma_clientes[l_arr_curr2].cod_cliente

END FUNCTION