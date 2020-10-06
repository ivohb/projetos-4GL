#-----------------------------------------------------------------#
# MODULO..: GEO                                                   #
# SISTEMA.: CADASTRO DE ROTEIROS                                  #
# PROGRAMA: geo1010                                               #
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
             cod_cliente             LIKE clientes.cod_cliente
           , nom_cliente             LIKE clientes.nom_cliente
           , seq_visita              integer 
                                 END RECORD

 define mr_tela, mr_telar   record
                         cod_empresa char(2),
                         cod_roteiro   integer,
                         den_roteiro   char(30)
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
   define m_column_cod_cliente          varchar(50)

   define m_refer_cod_empresa          varchar(50)
   define m_refer_cod_roteiro            varchar(50)
   define m_refer_den_roteiro            varchar(50)
   define m_refer_descricao            varchar(50)
   define m_refer_ies_situacao         varchar(50)
   define m_refer_den_situacao         varchar(50)
   define m_column_seq_visita          varchar(50)
   define m_tst2 char(1)

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
 FUNCTION geo1010()
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
      CALL geo1010_tela()
   END IF

END FUNCTION

#-------------------#
 FUNCTION geo1010_tela()
#-------------------#

   DEFINE l_label  VARCHAR(50)
        , l_splitter                   VARCHAR(50)
        , l_status SMALLINT
 
     #cria janela principal do tipo LDIALOG
     LET m_form_principal = _ADVPL_create_component(NULL,"LDIALOG")
     CALL _ADVPL_set_property(m_form_principal,"TITLE","ROTEIROS POR CLIENTES")
     CALL _ADVPL_set_property(m_form_principal,"ENABLE_ESC_CLOSE",FALSE)
     CALL _ADVPL_set_property(m_form_principal,"SIZE",1024,825)#   1024,725)

     #
     #
     #
     # INICIO MENU

     #cria menu
     LET m_toolbar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_principal)

     #botao INCLUIR
     LET m_botao_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_create,"EVENT","geo1010_incluir")
     CALL _ADVPL_set_property(m_botao_create,"CONFIRM_EVENT","geo1010_confirmar_inclusao")
     CALL _ADVPL_set_property(m_botao_create,"CANCEL_EVENT","geo1010_cancelar_inclusao")

     #botao MODIFICAR
     LET m_botao_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_update,"EVENT","geo1010_modificar")
     CALL _ADVPL_set_property(m_botao_update,"CONFIRM_EVENT","geo1010_confirmar_modificacao")
     CALL _ADVPL_set_property(m_botao_update,"CANCEL_EVENT","geo1010_cancelar_modificacao")

     #botao EXCLUIR
     LET m_botao_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_delete,"EVENT","geo1010_excluir")

     #botao LOCALIZAR
     LET m_botao_find_principal = _ADVPL_create_component(NULL,"LFINDBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_find_principal,"EVENT","geo1010_pesquisar")
     CALL _ADVPL_set_property(m_botao_find_principal,"TYPE","NO_CONFIRM")
     
     #botao primeiro registro
      LET m_botao_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_first,"EVENT","geo1010_primeiro")
      
      #botao anterior
      LET m_botao_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_previous,"EVENT","geo1010_anterior")
      
      #botao seguinte
      LET m_botao_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_next,"EVENT","geo1010_seguinte")
      
      #botao ultimo registro
      LET m_botao_last = _ADVPL_create_component(NULL,"LLASTBUTTON",m_toolbar)
      CALL _ADVPL_set_property(m_botao_last,"EVENT","geo1010_ultimo")
      

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
      CALL _ADVPL_set_property(m_panel_2,"HEIGHT",600)
      
     
     #cria panel  
     LET m_panel_reference1 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel_1)
     CALL _ADVPL_set_property(m_panel_reference1,"TITLE","ROTEIRO: ")
     CALL _ADVPL_set_property(m_panel_reference1,"ALIGN","CENTER")
     #CALL _ADVPL_set_property(m_panel_reference2,"HEIGHT",900)
     
     #cria panel  
     LET m_panel_reference2 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel_2)
     CALL _ADVPL_set_property(m_panel_reference2,"TITLE","SELECIONAR CIDADES: ")
     CALL _ADVPL_set_property(m_panel_reference2,"ALIGN","TOP")
     #CALL _ADVPL_set_property(m_panel_reference2,"HEIGHT",900)

  
     
     LET m_layoutmanager_refence_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_reference1)
     CALL _ADVPL_set_property(m_layoutmanager_refence_1,"MARGIN",TRUE)
     CALL _ADVPL_set_property(m_layoutmanager_refence_1,"COLUMNS_COUNT",2)


     LET m_layoutmanager_refence_2 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_reference2)
     CALL _ADVPL_set_property(m_layoutmanager_refence_2,"MARGIN",TRUE)
     CALL _ADVPL_set_property(m_layoutmanager_refence_2,"COLUMNS_COUNT",1)

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

#
#
#cria campo cod_roteiro
#
       LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_layoutmanager_refence_1)
       CALL _ADVPL_set_property(l_label,"TEXT","Código Roteiro:") 
       #CALL _ADVPL_set_property(l_label,"POSITION",5,30)
       CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
       CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
       

       
 #     LET m_refer_cod_roteiro = LOG_cria_textfield(m_layoutmanager_refence_1,1)
 #     CALL _ADVPL_set_property(m_refer_cod_roteiro,"LENGTH",10)
 #     CALL _ADVPL_set_property(m_refer_cod_roteiro,"VARIABLE",mr_tela,"cod_roteiro")
 #     CALL _ADVPL_set_property(m_refer_cod_roteiro,"ENABLE",FALSE)
 #     CALL _ADVPL_set_property(m_refer_cod_roteiro,"POSITION",90,30) 
 
      #cria campo cod_roteiro
      
      LET m_refer_cod_roteiro = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_layoutmanager_refence_1,10); #LOG_cria_textfield(m_layoutmanager_refence_1,10)
      CALL _ADVPL_set_property(m_refer_cod_roteiro,"VARIABLE",mr_tela,"cod_roteiro")
      CALL _ADVPL_set_property(m_refer_cod_roteiro,"ENABLE",FALSE)
     # CALL _ADVPL_set_property(m_refer_cod_roteiro,"POSITION",90,30)
      
      CALL _ADVPL_set_property(m_refer_cod_roteiro,"VALID","geo1010_valid_roteiro")
     

#
#
#cria campo den_roteiro
#
       LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_layoutmanager_refence_1)
       CALL _ADVPL_set_property(l_label,"TEXT","Descrição Roteiro:") 
       #CALL _ADVPL_set_property(l_label,"POSITION",5,30)
       CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
       CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
       

      #cria campo den_roteiro
      
      LET m_refer_den_roteiro = LOG_cria_textfield(m_layoutmanager_refence_1,30)
      CALL _ADVPL_set_property(m_refer_den_roteiro,"VARIABLE",mr_tela,"den_roteiro")
      CALL _ADVPL_set_property(m_refer_den_roteiro,"ENABLE",FALSE)
     # CALL _ADVPL_set_property(m_refer_den_roteiro,"POSITION",90,30) 
      #CALL _ADVPL_set_property(m_refer_den_roteiro,"VALID","geo1010_valid_roteiro")
     



   #ARRAY 1 - m_layoutmanager_refence_2

      #cria array
      LET m_table_reference1 = _ADVPL_create_component(NULL,"LBROWSEEX",m_layoutmanager_refence_2)
      CALL _ADVPL_set_property(m_table_reference1,"SIZE",950,400)
      CALL _ADVPL_set_property(m_table_reference1,"CAN_ADD_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference1,"CAN_REMOVE_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference1,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_table_reference1,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_table_reference1,"ENABLE",TRUE)

      #CALL _ADVPL_set_property(m_table_etapa,"BEFORE_REMOVE_ROW_EVENT","man10217_before_remove_row_event_table_etapa")
      #CALL _ADVPL_set_property(m_table_reference1,"BEFORE_EDIT_EVENT","")
      
      
       # 
      #cria campo do array: seq_visita
      LET m_column_seq_visita = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_seq_visita,"VARIABLE","seq_visita")
      CALL _ADVPL_set_property(m_column_seq_visita,"HEADER","Sequencia")
      CALL _ADVPL_set_property(m_column_seq_visita,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_column_seq_visita,"EDITABLE", TRUE)
      CALL _ADVPL_set_property(m_column_seq_visita,"ORDER",TRUE)
      
     CALL _ADVPL_set_property(m_column_seq_visita,"EDIT_COMPONENT","LNUMERICFIELD")
     CALL _ADVPL_set_property(m_column_seq_visita,"EDIT_PROPERTY","LENGTH",5,0)
     

      #cria campo do array: cod_cliente
      LET m_column_cod_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_cod_cliente,"VARIABLE","cod_cliente")
      CALL _ADVPL_set_property(m_column_cod_cliente,"HEADER","Cliente")
      CALL _ADVPL_set_property(m_column_cod_cliente,"COLUMN_SIZE", 70)
      CALL _ADVPL_set_property(m_column_cod_cliente,"EDITABLE", TRUE)

      CALL _ADVPL_set_property(m_column_cod_cliente,"ORDER",TRUE)

      CALL _ADVPL_set_property(m_column_cod_cliente,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_column_cod_cliente,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_column_cod_cliente,"EDIT_PROPERTY","VALID","geo1010_valid_cod_cliente")
      CALL _ADVPL_set_property(m_column_cod_cliente,"EDITABLE", FALSE)
      
       
      #-- Zoom
      LET m_column_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_table_reference1)
      CALL _ADVPL_set_property(m_column_reference,"COLUMN_SIZE",10)
      CALL _ADVPL_set_property(m_column_reference,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_column_reference,"NO_VARIABLE",TRUE)
      CALL _ADVPL_set_property(m_column_reference,"IMAGE", "BTPESQ")
      CALL _ADVPL_set_property(m_column_reference,"BEFORE_EDIT_EVENT","geo1010_zoom_clientes")
 
      #cria campo do array: nom_cliente
      LET m_column_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_reference,"VARIABLE","nom_cliente")
      CALL _ADVPL_set_property(m_column_reference,"HEADER","Nome Cliente")
      CALL _ADVPL_set_property(m_column_reference,"COLUMN_SIZE", 200)
      CALL _ADVPL_set_property(m_column_reference,"EDITABLE", TRUE)
      CALL _ADVPL_set_property(m_column_reference,"ORDER",TRUE)
     
      
      
    # let ma_pedidos[1].num_pedido = '123'
     CALL _ADVPL_set_property(m_table_reference1,"SET_ROWS",ma_tela,0)
     CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)

  

     CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
 

      CALL _ADVPL_set_property(m_form_principal,"ACTIVATE",TRUE)

 END FUNCTION

#---------------------------#
FUNCTION geo1010_incluir()
#---------------------------#

   INITIALIZE mr_tela.*, ma_tela to null

   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
 

   LET mr_tela.cod_empresa  = p_cod_empresa
     

   CALL geo1010_habilita_campos_manutencao(TRUE,'INCLUIR')

END FUNCTION

#-----------------------------#
 function geo1010_modificar()
#-----------------------------#
   define l_msg char(80)

   

  call geo1010_habilita_campos_manutencao(TRUE,'MODIFICAR')

 end function

#-----------------------------#
 function geo1010_excluir()
#-----------------------------#
   define l_msg char(80)

 

    let l_msg = 'Confirma a exclusão do roteiro: ', mr_tela.cod_roteiro, '?'
    IF LOG_pergunta(l_msg) THEN
    else
       return false
    end if

       delete from geo_roteiros
       where cod_empresa = p_cod_empresa
         and cod_roteiro = mr_tela.cod_roteiro  



  initialize mr_tela.* to null
  initialize ma_tela  to null
  CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)
  CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
 
END FUNCTION
 
#---------------------------#
 function geo1010_confirmar_inclusao()
#---------------------------#

   
   CALL geo1010_atualiza_dados('INCLUSAO')
   CALL geo1010_habilita_campos_manutencao(FALSE,'INCLUIR')

   RETURN TRUE

 end function

#---------------------------#
 function  geo1010_cancelar_inclusao()
#---------------------------#
  call geo1010_habilita_campos_manutencao(FALSE,'INCLUIR')

 end function

#---------------------------#
 function geo1010_confirmar_modificacao()
#---------------------------#

   
   CALL geo1010_habilita_campos_manutencao(FALSE,'MODIFICAR')
   CALL geo1010_atualiza_dados('MODIFICACAO')

   RETURN TRUE

 end function
#
#---------------------------#
 function  geo1010_cancelar_modificacao()
#---------------------------#

  CALL geo1010_habilita_campos_manutencao(FALSE,'MODIFICAR')

 end function

#----------------------------------------------#
 function geo1010_atualiza_dados(l_funcao)
#----------------------------------------------#

   DEFINE l_funcao char(20)
   DEFINE l_ind    integer
   DEFINE l_data   date
   DEFINE l_hora   char(8)
   
   LET l_data = TODAY
   LET l_hora = TIME
   
   CALL log085_transacao('BEGIN')
   
   
   
   if l_funcao = 'MODIFICACAO' then
      delete from geo_roteiros
       where cod_empresa = p_cod_empresa
         and cod_roteiro = mr_tela.cod_roteiro 
   end if

   for l_ind = 1 to 5000
      if ma_tela[l_ind].cod_cliente is null then
         exit for
      end if

      insert into geo_roteiros ( cod_empresa
                               , cod_roteiro
                               , seq_visita
                               , cod_cliente ) values
                               (
                                p_cod_empresa,
                                mr_tela.cod_roteiro,
                                ma_tela[l_ind].seq_visita,
                                ma_tela[l_ind].cod_cliente
                                )
   end for
 
   CALL log085_transacao('COMMIT')

END FUNCTION

#----------------------------------------------#
 function geo1010_habilita_campos_manutencao(l_status,l_funcao)
#----------------------------------------------#

   DEFINE l_status smallint
   
   define l_funcao char(20)

   if l_funcao = 'INCLUIR' then
      CALL _ADVPL_set_property(m_refer_cod_roteiro,"ENABLE",l_status) 
   end if
   
   CALL _ADVPL_set_property(m_table_reference1,"CAN_ADD_ROW",l_status)
   CALL _ADVPL_set_property(m_table_reference1,"CAN_REMOVE_ROW",l_status)
 
   CALL _ADVPL_set_property(m_table_reference1,"EDITABLE",l_status)
   
   CALL _ADVPL_set_property(m_column_cod_cliente,"EDITABLE", l_status)
   CALL _ADVPL_set_property(m_column_seq_visita,"EDITABLE", l_status)
   
#   seq_visita

END FUNCTION
#
       
#---------------------------------------#
 function geo1010_zoom_clientes()
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


   FOR l_ind = 1 TO 1000
      INITIALIZE ma_zclientes[l_ind].* TO NULL
   END FOR


   LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
   CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
   CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_zclientes)
   CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_clientes")
    
    # let l_cod_cliente = ma_zclientes[1].cod_cliente
     
    let l_ind = 1
    let ma_tela[l_selecao].cod_cliente = ma_zclientes[1].cod_cliente
    let ma_tela[l_selecao].nom_cliente = ma_zclientes[1].nom_cliente
    
    for l_ind = 1 to 5000
       if ma_tela[l_ind].cod_cliente is null or ma_tela[l_ind].cod_cliente = ' ' then
          exit for
       end if
       
    end for 
    let l_ind = l_ind - 1
   
   
   
    CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",l_ind)
    CALL _ADVPL_set_property(m_table_reference1,"REFRESH")

 end function
#
 
#-------------------------------------------#
 function geo1010_pesquisar()
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
      CALL _ADVPL_set_property(m_botao_find,"EVENT","geo1010_entrada_dadaos_filtro")
      CALL _ADVPL_set_property(m_botao_find,"CONFIRM_EVENT","geo1010_confirmar_filtro")
      CALL _ADVPL_set_property(m_botao_find,"CANCEL_EVENT","geo1010_cancela_filtro")
 
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

      #cria campo cod_cliente
      CALL LOG_cria_rotulo(l_layoutmanager_refence_1,"Roteiro:")
      LET m_refer_filtro_2 = _ADVPL_create_component(NULL, "LNUMERICFIELD", l_layoutmanager_refence_1,10) #LOG_cria_textfield(l_layoutmanager_refence_1,15)
      CALL _ADVPL_set_property(m_refer_filtro_2,"VARIABLE",mr_filtro,"cod_roteiro")
      CALL _ADVPL_set_property(m_refer_filtro_2,"ENABLE",FALSE)

      LET m_btn_selecionar_1 = _ADVPL_create_component(NULL, "LBUTTON", l_layoutmanager_refence_2)
      CALL _ADVPL_set_property(m_btn_selecionar_1,"TEXT", "Selecionar Roteiro")
      CALL _ADVPL_set_property(m_btn_selecionar_1,"CLICK_EVENT","geo1010_zoom_roteiros")
      CALL _ADVPL_set_property(m_btn_selecionar_1,"SIZE",100,20)
      CALL _ADVPL_set_property(m_btn_selecionar_1,"POSITION",415,118)

      CALL _ADVPL_set_property(m_btn_selecionar_1,"ENABLE",FALSE)
 
      CALL _ADVPL_set_property(m_form_filtro,"ACTIVATE",TRUE)

end function 


#--------------------------------------------------------------------#
  function geo1010_entrada_dadaos_filtro()
#--------------------------------------------------------------------#
   initialize mr_filtro.* to null
 
 
   CALL _ADVPL_set_property(m_refer_filtro_2,"ENABLE",TRUE)
   

   CALL _ADVPL_set_property(m_btn_selecionar_1,"ENABLE",TRUE)

 end function
 
#--------------------------------------------------------------------#
  function geo1010_confirmar_filtro()
#--------------------------------------------------------------------#
    define l_sql_stmt  char(5000)
   CALL _ADVPL_set_property(m_form_filtro,"ACTIVATE",FALSE)
   
   let mr_tela.cod_roteiro = null
   let mr_tela.cod_roteiro  = mr_filtro.cod_roteiro
   
   let l_sql_stmt  =
   ' select a.cod_empresa, a.cod_roteiro, b.den_roteiro   ',
   '   from geo_roteiros a, geo_rot_repres b ',
   '  where a.cod_empresa  = "', p_cod_empresa, '" ',
   '    and a.cod_empresa = b.cod_empresa ',
   '    and a.cod_roteiro = b.cod_roteiro '


   if mr_tela.cod_roteiro is not null then
      let l_sql_stmt = l_sql_stmt clipped,
                       ' AND a.cod_roteiro = "', mr_tela.cod_roteiro, '" '
      
   end if

   let l_sql_stmt = l_sql_stmt clipped,
   ' group by a.cod_empresa, a.cod_roteiro, b.den_roteiro   ',
   ' order by a.cod_roteiro        '

   prepare var_query from l_sql_stmt
   declare cq_consulta SCROLL cursor  WITH HOLD for var_query

   open cq_consulta
   fetch cq_consulta into mr_tela.cod_empresa, mr_tela.cod_roteiro, mr_tela.den_roteiro
   
   
   if sqlca.sqlcode = 0 then
      LET m_ies_onsulta = TRUE
      CALL geo1010_exibe_dados()
      CALL _ADVPL_set_property(m_table_reference1,"EDITABLE",FALSE)
   end if
   
 end function
 
#--------------------------------------------------------------------#
  function geo1010_cancela_filtro()
#--------------------------------------------------------------------#
 
   CALL _ADVPL_set_property(m_form_filtro,"ACTIVATE",FALSE)

 end function
 
#-------------------------------------------#
 function geo1010_zoom_roteiros()
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
 FUNCTION geo1010_primeiro()
#-------------------------------------#
    CALL geo1010_paginacao("PRIMEIRO")
 end function

#-------------------------------------#
 FUNCTION geo1010_anterior()
#-------------------------------------#
   CALL geo1010_paginacao("ANTERIOR")
 end function

#-------------------------------------#
 FUNCTION geo1010_seguinte()
#-------------------------------------#
     CALL geo1010_paginacao("SEGUINTE")
 end function

#-------------------------------------#
 FUNCTION geo1010_ultimo()
#-------------------------------------#
    CALL geo1010_paginacao("ULTIMO")
 end function

#
#-------------------------------------#
 FUNCTION geo1010_paginacao(l_funcao)
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
                                              mr_tela.cod_roteiro ,
                                              mr_tela.den_roteiro   

               IF sqlca.sqlcode <> 0 THEN
                  #CALL log003_err_sql ("NEXT","cq_orcamentos")
                  #EXIT WHILE
               END IF

            WHEN l_funcao = "ANTERIOR"

                 FETCH PREVIOUS cq_consulta INTO mr_tela.cod_empresa ,
                                                 mr_tela.cod_roteiro  ,
                                              mr_tela.den_roteiro  

               IF sqlca.sqlcode <> 0 THEN
                  #CALL log003_err_sql ("PREVIOUS","cq_orcamentos")
                  #EXIT WHILE
               END IF

            WHEN l_funcao = "PRIMEIRO"

                  FETCH FIRST cq_consulta INTO mr_tela.cod_empresa ,
                                               mr_tela.cod_roteiro  ,
                                              mr_tela.den_roteiro  

               IF sqlca.sqlcode <> 0 THEN
                  #CALL log003_err_sql ("FIRST","cq_orcamentos")
                  #EXIT WHILE
               END IF

            WHEN l_funcao = "ULTIMO"

                  FETCH LAST cq_consulta INTO mr_tela.cod_empresa ,
                                              mr_tela.cod_roteiro  ,
                                              mr_tela.den_roteiro  

            IF sqlca.sqlcode <> 0 THEN
               #CALL log003_err_sql ("LAST","cq_orcamentos")
               #EXIT WHILE
            END IF
         END CASE
         IF sqlca.sqlcode = NOTFOUND THEN
            CALL geo1010_exibe_mensagem_barra_status("Não existem mais itens nesta direcao.","ERRO")
            let mr_tela.* = mr_telar.*
            EXIT WHILE
         ELSE
            LET m_ies_onsulta = TRUE
         END IF

         select a.cod_empresa, a.cod_roteiro, b.den_roteiro 
           INTO mr_tela.cod_empresa ,
                mr_tela.cod_roteiro  ,
                                              mr_tela.den_roteiro  
          from geo_roteiros a, geo_rot_repres b
         where a.cod_empresa  = p_cod_empresa
           and a.cod_empresa = b.cod_empresa
           and a.cod_roteiro    = mr_tela.cod_roteiro
           and a.cod_roteiro = b.cod_roteiro 
         group by a.cod_empresa, a.cod_roteiro, b.den_roteiro  

         IF sqlca.sqlcode = 0 THEN

            EXIT WHILE

         END IF

      END WHILE
   ELSE
      CALL geo1010_exibe_mensagem_barra_status("Efetue primeiramente a consulta.","ERRO")
   END IF


  CALL geo1010_exibe_dados()

 END FUNCTION
 
 #--------------------------------------------------------------------#
 FUNCTION geo1010_exibe_mensagem_barra_status(l_mensagem,l_tipo_mensagem)
#--------------------------------------------------------------------#

   DEFINE l_mensagem               CHAR(500),
          l_tipo_mensagem          CHAR(010),
          l_tipo_mensagem_original CHAR(015)

   LET l_tipo_mensagem_original = LOG_retorna_tipo_mensagem_original(UPSHIFT(l_tipo_mensagem),TRUE)
   CALL _ADVPL_set_property(m_status_bar,l_tipo_mensagem_original CLIPPED," "||l_mensagem CLIPPED)

 END FUNCTION

 
#--------------------------------------------------------------------#
 function geo1010_exibe_dados()
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
 function geo1010_valid_cod_cliente()
#--------------------------------------------------------------------#
   define l_selecao integer 
   
   LET l_selecao = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   
   if l_selecao < 1 then
     return true 
   end if 
   
   select nom_cliente
   into ma_tela[l_selecao].nom_cliente
    from clientes
   where cod_cliente = ma_tela[l_selecao].cod_cliente
 
   IF sqlca.sqlcode = 100 THEN
      CALL _ADVPL_message_box("Cliente não encontrado.")
      RETURN FALSE
   END IF
  #
 return true 
 
 end function 
#--------------------------------------------------------------------#
 function geo1010_valid_roteiro()
#--------------------------------------------------------------------#
   SELECT den_roteiro
     into mr_tela.den_roteiro
     FROM geo_rot_repres
    WHERE cod_empresa = p_cod_empresa
      AND cod_roteiro = mr_tela.cod_roteiro

   select distinct(cod_empresa)
     from geo_roteiros 
    where cod_empresa = p_cod_empresa
     and cod_roteiro   = mr_tela.cod_roteiro  
     
   IF sqlca.sqlcode = 0 THEN
      CALL _ADVPL_message_box("Roteiro já cadastrado.")
      RETURN FALSE
   END IF
  #
 return true 
 
 
 end function 
 