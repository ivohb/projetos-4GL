#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1363                                                 #
# OBJETIVO: ALTERAÇÃO DE PEDIDOS E SOLICITAÇÃO DE FATURAMENTO       #
# AUTOR...: IVO                                                     #
# DATA....: 03/01/19                                                #
#-------------------------------------------------------------------#

DATABASE logix 

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_den_empresa   LIKE empresa.den_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_versao        CHAR(18),
           comando         CHAR(80),
           p_ies_impressao CHAR(01),
           g_ies_ambiente  CHAR(01),
           p_caminho       CHAR(080),
           p_nom_arquivo   CHAR(100),
           g_tipo_sgbd     CHAR(003),
           g_msg           CHAR(150),
           p_qtd_lote      DECIMAL(10,3)           
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_browse          VARCHAR(10)

DEFINE m_pedido          VARCHAR(10),
       m_panel           VARCHAR(10),
       m_zoom_ped        VARCHAR(10)

DEFINE m_ies_cons        SMALLINT,
       m_num_pedio       DECIMAL(6,0),
       m_msg             VARCHAR(150),
       m_index           INTEGER,
       m_lin_atu         INTEGER,
       m_carregando      SMALLINT,
       m_cod_item        CHAR(15),
       m_opcao           CHAR(01),
       m_it_sem_saldo    SMALLINT,
       m_nom_transp      CHAR(36),
       m_lin_lote        INTEGER,
       m_count           INTEGER,
       m_lin_reser       INTEGER,
       m_ies_lote        SMALLINT,
       m_qtd_saldo       DECIMAL(10,3),
       m_num_solicit     INTEGER
       
DEFINE mr_cabec          RECORD
       num_pedido        DECIMAL(6,0),
       cod_cliente       CHAR(15),
       nom_cliente       CHAR(36),
       num_list_preco    DECIMAL(6,0),
       cod_repres        DECIMAL(6,0),
       num_solicit       DECIMAL(9,0)
END RECORD

DEFINE ma_itens          ARRAY[1000] OF RECORD
       num_sequencia     DECIMAL(5,0),
       cod_item          CHAR(15),
       den_item          CHAR(76),
       cod_unid          CHAR(03),
       prz_entrega       DATE,
       qtd_pecas_solic   DECIMAL(10,3),
       pre_unit          DECIMAL(12,2),
       qtd_saldo         DECIMAL(10,3),
       qtd_estoq         DECIMAL(10,3),
       ctr_lote          CHAR(01),
       ctr_estoq         CHAR(01),
       filler            CHAR(01)
END RECORD

DEFINE m_zproduto        VARCHAR(10),
       m_zlote           VARCHAR(10),
       m_dlg_edit        VARCHAR(10),
       m_bar_edit        VARCHAR(10),
       m_panel_edit      VARCHAR(10),
       m_item            VARCHAR(10),
       m_quant           VARCHAR(10),
       m_preco           VARCHAR(10),
       m_entrega         VARCHAR(10),
       m_dlg_lote        VARCHAR(10),
       m_bar_lote        VARCHAR(10),
       m_panel_lote      VARCHAR(10),
       m_brz_lote        VARCHAR(10),
       m_brz_reser       VARCHAR(10)
       

DEFINE mr_item           RECORD
   num_seq               INTEGER,
   cod_item              CHAR(15),
   den_item              CHAR(50),
   qtd_item              DECIMAL(10,3),
   pre_unit              DECIMAL(12,2),
   dat_entrega           DATE
END RECORD

DEFINE m_tip_inf         CHAR(01),
       m_tip_mov         CHAR(01),
       m_texto           CHAR(100),
       m_num_seq         INTEGER,
       m_val_cred        DECIMAL(12,2),
       m_val_creda       DECIMAL(12,2)

DEFINE mr_parametro      RECORD
       cod_empresa      CHAR(02),
       cod_item         CHAR(15),
       cod_local        CHAR(10)
END RECORD

DEFINE mr_transp         RECORD
       trans_solic       INTEGER,
       num_solicit       DECIMAL(9,0),
       dat_refer         DATE,
       cod_usuario       CHAR(08),
       cod_transpor      CHAR(15),
       nom_transpor      CHAR(36),
       num_placa         CHAR(10),
       uf_veiculo        CHAR(02),
			 cod_texto_1       DECIMAL(3,0),
			 cod_texto_2       DECIMAL(3,0),
			 cod_texto_3       DECIMAL(3,0),
			 cod_via           DECIMAL(2,0),
			 tip_frete         CHAR(01)       
END RECORD

DEFINE m_transpor        VARCHAR(10),
       m_texto_1         VARCHAR(10),
       m_texto_2         VARCHAR(10),
       m_texto_3         VARCHAR(10),
       m_lupa_tx1        VARCHAR(10),
       m_lupa_tx2        VARCHAR(10),
       m_lupa_tx3        VARCHAR(10),
       m_zoom_txt        VARCHAR(10),
       m_via             VARCHAR(10),
       m_lupa_via        VARCHAR(10),
       m_zoom_via        VARCHAR(10),
       m_solicit         VARCHAR(10),
       m_ztransp         VARCHAR(10)

DEFINE ma_reserva        ARRAY[500] OF RECORD
       num_sequencia     DECIMAL(5,0),
       cod_item          CHAR(15),
       den_item          CHAR(76),
       cod_unid          CHAR(03),
       qtd_saldo         DECIMAL(10,3),
       qtd_lote          DECIMAL(10,3)       
END RECORD

DEFINE ma_lote           ARRAY[100] OF RECORD
       ies_select        CHAR(01),
       num_lote          CHAR(15),
       ies_tipo          CHAR(01),
       qtd_saldo         DECIMAL(10,3),
       qtd_faturar       DECIMAL(10,3)
END RECORD

DEFINE m_num_pedido      INTEGER, 
       m_num_sequencia   INTEGER,
       m_cod_unid_med    CHAR(03),
       m_qtd_faturar     DECIMAL(10,3),
       m_lote_om         INTEGER,
       m_num_om          INTEGER,
       m_num_lote        CHAR(15), 
       m_qtd_lote        DECIMAL(10,3),
       m_local_estoq     CHAR(10),
       m_qtd_reservada   DECIMAL(10,3),
       m_ies_ctr_lote    CHAR(01),
       m_dat_atu         DATE
             
       
DEFINE m_peso_unit        LIKE item.pes_unit,
       m_tot_volume       LIKE ordem_montag_item.qtd_volume_item,
       m_cod_tip_carteira LIKE pedidos.cod_tip_carteira
       
DEFINE mr_lote_ender     RECORD LIKE estoque_lote_ender.*

DEFINE m_nser             LIKE vdp_num_docum.serie_docum,
       m_sser             LIKE vdp_num_docum.subserie_docum,
       m_espcie           LIKE vdp_num_docum.especie_docum,
       m_tip_docum        LIKE vdp_num_docum.tip_docum,
       m_tip_solic        LIKE vdp_num_docum.tip_solicitacao,
       m_txt_placa_veic   LIKE fat_solic_fatura.texto_1,
       m_txt_uf_veic      LIKE fat_solic_fatura.texto_2,
       m_ies_solic        CHAR(01)
       

DEFINE m_num_transac      INTEGER,
       m_controle         INTEGER,
       m_sequencia        INTEGER,
       m_qtd_volume       DECIMAL(10,3),
       m_seq_fatura       INTEGER,
       m_ctr_fatura       INTEGER,
       m_ies_modalidade   CHAR(01)

#-----------------#
FUNCTION pol1363()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 30
   DEFER INTERRUPT
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   LET g_tipo_sgbd = LOG_getCurrentDBType()
   
   LET p_versao = "pol1363-12.00.01  "
   CALL func002_versao_prg(p_versao)
   LET m_carregando = TRUE
   
   CALL pol1363_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1363_menu()#
#----------------------#

    DEFINE l_menubar    VARCHAR(10),
           l_panel      VARCHAR(10),
           l_create     VARCHAR(10),
           l_update     VARCHAR(10),
           l_delete     VARCHAR(10),
           l_inform     VARCHAR(10),
           l_solic      VARCHAR(10),
           l_cancel     VARCHAR(10),
           l_titulo     CHAR(50)

    LET l_titulo = "ALTERAÇÃO DE PEDIDOS E SOLICITAÇÃO DE FATURAMENTO"
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1363_informar")
    CALL _ADVPL_set_property(l_inform,"TOOLTIP","Informar pedido para alterar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1363_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1363_cancelar")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"TOOLTIP","Incluir um novo item") 
    CALL _ADVPL_set_property(l_create,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_create,"EVENT","pol1363_incluir")
        
    LET l_update = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"IMAGE","UPDATE_EX") 
    CALL _ADVPL_set_property(l_update,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_update,"TOOLTIP","Modificar item do pedido")
    CALL _ADVPL_set_property(l_update,"EVENT","pol1363_alterar")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1363_deletar")

    LET l_solic = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)      
    CALL _ADVPL_set_property(l_solic,"IMAGE","INCLUI_SOLICITACAO") 
    CALL _ADVPL_set_property(l_solic,"TOOLTIP","Gerar solicitação de faturamento") 
    CALL _ADVPL_set_property(l_solic,"EVENT","pol1363_gera_solict")

    LET l_cancel = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)      
    CALL _ADVPL_set_property(l_cancel,"IMAGE","CANCELAR_SOLICITACAO") 
    CALL _ADVPL_set_property(l_cancel,"TOOLTIP","Cancelar solicitação de faturamento") 
    CALL _ADVPL_set_property(l_cancel,"EVENT","pol1363_cancel_solict")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    CALL pol1363_cabecalho(l_panel)
    CALL pol1363_itens(l_panel)
    CALL pol1363_ativa_desativa(FALSE)
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#--------------------------------------#
FUNCTION pol1363_cabecalho(l_container)#
#--------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_lupa_ped        VARCHAR(10)

    LET m_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_panel,"HEIGHT",40)
    CALL _ADVPL_set_property(m_panel,"BACKGROUND_COLOR",231,237,237)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Número pedido:")    

    LET m_pedido = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_pedido,"POSITION",110,10)     
    CALL _ADVPL_set_property(m_pedido,"VARIABLE",mr_cabec,"num_pedido")
    CALL _ADVPL_set_property(m_pedido,"LENGTH",6,0)
    CALL _ADVPL_set_property(m_pedido,"VALID","pol1363_valid_pedido")

    LET l_lupa_ped = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(l_lupa_ped,"POSITION",170,10)     
    CALL _ADVPL_set_property(l_lupa_ped,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa_ped,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa_ped,"CLICK_EVENT","pol1363_zoom_pedido")
    CALL _ADVPL_set_property(l_lupa_ped,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",210,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",255,10)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"cod_cliente")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",15,0)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",400,10)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"nom_cliente")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30,0)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",680,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Lista:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",720,10)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"num_list_preco")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",6,0)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",800,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Representante:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",885,10)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"cod_repres")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",6,0)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",960,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Solicit:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",1010,10)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"num_solicit")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",9,0)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

END FUNCTION

#----------------------------------#
FUNCTION pol1363_itens(l_container)#
#----------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_browse,"BEFORE_ROW_EVENT","pol1363_before_linha")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sequenc")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_sequencia")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E #####")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Produto")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD") 
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",300)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Unid")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_unid")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LDATEFIELD") 
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","prz_entrega")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Quantidade")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_pecas_solic")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ########.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Preço")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pre_unit")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ########.##")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ########.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Estoque")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_estoq")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ########.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ctrl lote")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ctr_lote")
    CALL _ADVPL_set_property(l_tabcolumn,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ctrl estoq")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ctr_estoq")
    CALL _ADVPL_set_property(l_tabcolumn,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
    
    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#------------------------------#
FUNCTION pol1363_before_linha()#
#------------------------------#
   
   IF m_carregando  THEN
      RETURN TRUE
   END IF
      
   LET m_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   LET m_cod_item = ma_itens[m_lin_atu].cod_item

   RETURN TRUE

END FUNCTION
   
#----------------------------------------#
FUNCTION pol1363_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   CALL _ADVPL_set_property(m_panel,"ENABLE",l_status)

END FUNCTION

#------------------------------#
FUNCTION pol1363_limpa_campos()#
#------------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_itens TO NULL
   LET m_num_solicit = NULL
   CALL _ADVPL_set_property(m_browse,'CLEAR')
    
END FUNCTION

#-----------------------------#
FUNCTION pol1363_zoom_pedido()#
#-----------------------------#

    DEFINE l_num_pedido   LIKE pedidos.num_pedido,
           l_filtro       CHAR(300)
    
    IF  m_zoom_ped IS NULL THEN
        LET m_zoom_ped = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_ped,"ZOOM","zoom_pedidos")
    END IF

    LET l_filtro = " pedidos.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_ped,"ACTIVATE")
    
    LET l_num_pedido = _ADVPL_get_property(m_zoom_ped,"RETURN_BY_TABLE_COLUMN","pedidos","num_pedido")

    IF l_num_pedido IS NOT NULL THEN
       LET mr_cabec.num_pedido = l_num_pedido
       CALL pol1363_valid_pedido() RETURN p_status
    END IF
    
    CALL _ADVPL_set_property(m_pedido,"GET_FOCUS")

END FUNCTION

#------------------------------#
FUNCTION pol1363_valid_pedido()#
#------------------------------#
   
   DEFINE l_ies_sit_pedido   CHAR(01)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   SELECT p.cod_cliente, c.nom_cliente,
          p.num_list_preco, p.cod_repres,
          p.ies_sit_pedido
     INTO mr_cabec.cod_cliente, 
          mr_cabec.nom_cliente,
          mr_cabec.num_list_preco,
          mr_cabec.cod_repres,
          l_ies_sit_pedido
     FROM pedidos p INNER JOIN clientes c
       ON p.cod_cliente = c.cod_cliente
    WHERE p.cod_empresa = p_cod_empresa
      AND p.num_pedido = mr_cabec.num_pedido

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','pedidos/clientes')
      RETURN FALSE
   END IF
   
   IF l_ies_sit_pedido = '9' THEN
      LET m_msg = 'Peiddo cancelado.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1363_informar()#
#--------------------------#
   
   DEFINE l_data    DATE
   
   LET m_ies_cons = FALSE
      
   CALL pol1363_ativa_desativa(TRUE)
   CALL pol1363_limpa_campos()
   CALL _ADVPL_set_property(m_pedido,"GET_FOCUS")
      
   RETURN TRUE 
    
END FUNCTION

#--------------------------#
FUNCTION pol1363_cancelar()#
#--------------------------#

    CALL pol1363_limpa_campos()
    CALL pol1363_ativa_desativa(FALSE)
    LET m_ies_cons = FALSE
    RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1363_confirmar()#
#---------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF mr_cabec.num_pedido IS NULL OR mr_cabec.num_pedido = 0 THEN
      LET m_msg = 'Informe o pedido.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      CALL _ADVPL_set_property(m_pedido,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   LET m_num_pedio = mr_cabec.num_pedido
   LET m_num_om = NULL
   LET m_num_solicit = NULL

   DECLARE cq_oms CURSOR FOR
   SELECT m.num_om 
     FROM ordem_montag_mest m
    INNER JOIN ordem_montag_item i
       ON i.cod_empresa = m.cod_empresa
      AND i.num_om = m.num_om
      AND i.num_pedido = m_num_pedio
    WHERE m.cod_empresa = p_cod_empresa
      AND m.num_nff IS NULL
   FOREACH cq_oms  INTO m_num_om
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordem_montag_mest')
         RETURN FALSE
      END IF
      EXIT FOREACH
   END FOREACH
   
   IF m_num_om IS NOT NULL THEN       
      SELECT DISTINCT a.solicitacao_fatura, a.trans_solic_fatura    
        INTO m_num_solicit, m_num_transac
        FROM fat_solic_mestre a, fat_solic_fatura b
       WHERE a.empresa = p_cod_empresa
         AND a.trans_solic_fatura = b.trans_solic_fatura
         AND b.ord_montag = m_num_om
      IF STATUS = 100 THEN
         LET m_msg = 'Esse pedido já possui romaneio sem faturar.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
         CALL _ADVPL_set_property(m_pedido,"GET_FOCUS")
         RETURN FALSE
      END IF
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','fat_solic_mestre')
         RETURN FALSE
      END IF      
   END IF
     
   LET m_carregando = TRUE

   IF NOT pol1363_le_itens() THEN
      LET m_carregando = FALSE
      RETURN FALSE
   END IF

   LET m_carregando = FALSE      

   CALL pol1363_ativa_desativa(FALSE)
   
   IF m_num_solicit IS NULL THEN
      LET m_ies_cons = TRUE
   ELSE
      LET m_ies_cons = FALSE
      LET mr_cabec.num_solicit = m_num_solicit
   END IF   
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1363_le_itens()#
#--------------------------#

   
   INITIALIZE ma_itens TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   
   LET m_index = 1
   LET m_it_sem_saldo = FALSE
   
   DECLARE cq_ped_it CURSOR FOR
    SELECT num_sequencia,
           cod_item,
           prz_entrega,
           qtd_pecas_solic,
           pre_unit,
           (qtd_pecas_solic - qtd_pecas_atend - 
               qtd_pecas_cancel - qtd_pecas_romaneio)
      FROM ped_itens
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido = m_num_pedio
       AND (qtd_pecas_solic - qtd_pecas_atend - 
               qtd_pecas_cancel {- qtd_pecas_romaneio}) > 0
    
   FOREACH cq_ped_it INTO 
      ma_itens[m_index].num_sequencia,
      ma_itens[m_index].cod_item,
      ma_itens[m_index].prz_entrega,
      ma_itens[m_index].qtd_pecas_solic,
      ma_itens[m_index].pre_unit,
      ma_itens[m_index].qtd_saldo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','pedidos/clientes')
         RETURN FALSE
      END IF
      
      LET mr_parametro.cod_empresa = p_cod_empresa
      LET mr_parametro.cod_item = ma_itens[m_index].cod_item
      
      SELECT den_item, cod_local_estoq, 
             cod_unid_med, ies_ctr_lote, ies_ctr_estoque
        INTO ma_itens[m_index].den_item, 
             mr_parametro.cod_local,
             ma_itens[m_index].cod_unid,
             ma_itens[m_index].ctr_lote,
             ma_itens[m_index].ctr_estoq
        FROM item 
       WHERE cod_empresa = p_cod_empresa 
         AND cod_item = mr_parametro.cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item')
         RETURN FALSE
      END IF
      
      IF ma_itens[m_index].ctr_estoq = 'S' THEN
      
         CALL func002_le_estoque(mr_parametro)                                     
            RETURNING m_msg, ma_itens[m_index].qtd_estoq                           
                                                                                   
         IF m_msg IS NOT NULL THEN                                                 
            CALL log0030_mensagem(m_msg,'info')                                    
            LET ma_itens[m_index].qtd_estoq = 0                                    
         END IF                                                                    
                                                                                   
         IF ma_itens[m_index].qtd_estoq < ma_itens[m_index].qtd_saldo AND          
              ma_itens[m_index].ctr_estoq = 'S' THEN                               
            LET m_it_sem_saldo = TRUE                                              
            CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_index,241,84,91) 
         ELSE                                                                      
            CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_index,0,0,0)     
         END IF                                                                    
      ELSE
         CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_index,0,0,0)
      END IF
      
      LET m_index = m_index + 1
      
      IF m_index > 1000 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassou.')
         EXIT FOREACH
      END IF
   
   END FOREACH
    
   LET m_index = m_index - 1
        
   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_index)
   
   IF m_index > 0 THEN
      LET m_lin_atu = 1
   ELSE
      LET m_lin_atu = 0
   END IF        
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1363_incluir()#
#-------------------------#
   
   DEFINE l_seq       INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')

   IF NOT m_ies_cons THEN
      IF mr_cabec.num_solicit IS NULL THEN
         LET m_msg = 'Informe um pedido previamente'
      ELSE
         LET m_msg = 'Pedido já contém solicitação de faturamento pronta'
      END IF
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
   
   IF NOT func002_verifica_credito(mr_cabec.cod_cliente) THEN
      CALL log0030_mensagem(g_msg,'info')
      RETURN FALSE
   END IF
   
   LET m_opcao = 'I'
   INITIALIZE mr_item.* TO NULL

   SELECT MAX(num_sequencia) INTO l_seq
     FROM ped_itens 
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = mr_cabec.num_pedido
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ped_itens')
      RETURN FALSE
   END IF
   
   IF l_seq IS NULL THEN
      LET l_seq = 0
   END IF
   
   LET mr_item.num_seq = l_seq + 1
        
   CALL pol1363_tela_item()
   
END FUNCTION

#--------------------------#
FUNCTION pol1363_le_lista()#
#--------------------------#

   DEFINE l_transacao  INTEGER
   
   LET l_transacao = func016_le_lista(p_cod_empresa,
      mr_cabec.num_list_preco, mr_cabec.cod_cliente, mr_item.cod_item)
   
   IF l_transacao = 0 THEN
      LET mr_item.pre_unit = 0
      IF g_msg IS NOT NULL THEN
         CALL log0030_mensagem(g_msg,'info')
         RETURN FALSE
      END IF
   ELSE
      SELECT pre_unit INTO mr_item.pre_unit
        FROM desc_preco_item 
       WHERE cod_empresa = p_cod_empresa
         AND num_transacao = l_transacao
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','desc_preco_item')
         RETURN FALSE
      END IF
   END IF   
   
   RETURN TRUE

END FUNCTION 

#-------------------------#
FUNCTION pol1363_alterar()#
#-------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')

   IF NOT m_ies_cons THEN
      IF mr_cabec.num_solicit IS NULL THEN
         LET m_msg = 'Informe um pedido previamente'
      ELSE
         LET m_msg = 'Pedido já contém solicitação de faturamento pronta'
      END IF
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
   
   IF m_lin_atu <= 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", 'Selecione previamente um item')
      RETURN FALSE
   END IF
   
   IF NOT func002_verifica_credito(mr_cabec.cod_cliente) THEN
      CALL log0030_mensagem(g_msg,'info')
      RETURN FALSE
   END IF
   
   LET m_opcao = 'A'
   INITIALIZE mr_item.* TO NULL
   LET mr_item.num_seq  = ma_itens[m_lin_atu].num_sequencia
   LET mr_item.cod_item = ma_itens[m_lin_atu].cod_item
   LET mr_item.den_item = ma_itens[m_lin_atu].den_item
   LET mr_item.qtd_item = ma_itens[m_lin_atu].qtd_pecas_solic
   LET mr_item.pre_unit = ma_itens[m_lin_atu].pre_unit
   LET mr_item.dat_entrega = ma_itens[m_lin_atu].prz_entrega

   LET m_val_creda = mr_item.qtd_item * mr_item.pre_unit

   CALL pol1363_tela_item()
      
   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol1363_deletar()#
#-------------------------#
   
   DEFINE l_pecas_atend     DECIMAL(10,3),
          l_pecas_roma      DECIMAL(10,3),
          l_pecas_solic     DECIMAL(10,3),
          l_pre_unit        DECIMAL(12,2)
          
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')

   IF NOT m_ies_cons THEN
      IF mr_cabec.num_solicit IS NULL THEN
         LET m_msg = 'Informe um pedido previamente'
      ELSE
         LET m_msg = 'Pedido já contém solicitação de faturamento pronta'
      END IF
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   IF m_lin_atu <= 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", 'Selecione previamente um item')
      RETURN FALSE
   END IF
   
   LET m_num_seq = ma_itens[m_lin_atu].num_sequencia
   
   SELECT qtd_pecas_atend, qtd_pecas_romaneio,
          qtd_pecas_solic, pre_unit
     INTO l_pecas_atend, l_pecas_roma,
          l_pecas_solic, l_pre_unit
     FROM ped_itens
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = mr_cabec.num_pedido
      AND num_sequencia = m_num_seq
   
   IF l_pecas_atend > 0 THEN
      LET m_msg = 'Item do pedido já possui faturamento.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
   
   IF l_pecas_roma > 0 THEN
      LET m_msg = 'Item do pedido possui romaneio pendente de faturamento'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF
   
   LET m_val_cred = l_pecas_solic * l_pre_unit
   LET m_tip_inf = 'E'
   LET m_tip_mov = 'E'
   LET m_texto = 'EXCLUSÃO DA SEQUENCIA:',m_num_seq USING '<<<'
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1363_apaga_item() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
      LET m_carregando = TRUE
      CALL pol1363_le_itens()
      LET m_carregando = FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1363_tela_item()#
#---------------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_confirma    VARCHAR(10),
           l_cancela     VARCHAR(10),
           l_label       VARCHAR(10)


    LET m_dlg_edit = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dlg_edit,"SIZE",700,300) #largura x alterua
    CALL _ADVPL_set_property(m_dlg_edit,"TITLE","EDIÇÃO DE ITENS")
    CALL _ADVPL_set_property(m_dlg_edit,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dlg_edit,"INIT_EVENT","pol1363_foca_item")

    LET m_bar_edit = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dlg_edit)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dlg_edit)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)    

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
   CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirma,"EVENT","pol1363_conf_edicao")  

   {LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancela,"EVENT","pol1363_canc_edicao")  }   

   LET m_panel_edit = _ADVPL_create_component(NULL,"LPANEL",m_dlg_edit)
   CALL _ADVPL_set_property(m_panel_edit,"ALIGN","CENTER")
   CALL _ADVPL_set_property(m_panel_edit,"BACKGROUND_COLOR",225,232,232) 
   
   CALL pol1363_dig_item()
   
   CALL _ADVPL_set_property(m_dlg_edit,"ACTIVATE",TRUE)

   RETURN TRUE
    
END FUNCTION

#---------------------------#
FUNCTION pol1363_foca_item()#
#---------------------------#

   CALL _ADVPL_set_property(m_item,"GET_FOCUS")

END FUNCTION

#--------------------------#
FUNCTION pol1363_dig_item()#
#--------------------------#
   
   DEFINE l_label       VARCHAR(10),
          l_lupa_it     VARCHAR(10),
          l_caixa       VARCHAR(10)

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_edit)
   CALL _ADVPL_set_property(l_label,"POSITION",10,20)     
   CALL _ADVPL_set_property(l_label,"TEXT","Sequencia:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

   LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_edit)
   CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 
   CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)
   CALL _ADVPL_set_property(l_caixa,"POSITION",80,20)     
   CALL _ADVPL_set_property(l_caixa,"LENGTH",5,0)
   CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_item,"num_seq")
   
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_edit)
   CALL _ADVPL_set_property(l_label,"POSITION",10,50)     
   CALL _ADVPL_set_property(l_label,"TEXT","Item:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

   LET m_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_edit)
   CALL _ADVPL_set_property(m_item,"EDITABLE",TRUE) 
   CALL _ADVPL_set_property(m_item,"POSITION",80,50)     
   CALL _ADVPL_set_property(m_item,"LENGTH",15,0)
   CALL _ADVPL_set_property(m_item,"PICTURE","@E!")
   CALL _ADVPL_set_property(m_item,"VARIABLE",mr_item,"cod_item")
   CALL _ADVPL_set_property(m_item,"VALID","pol1363_valida_item")

   LET l_lupa_it = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_edit)
   CALL _ADVPL_set_property(l_lupa_it,"POSITION",210,50)     
   CALL _ADVPL_set_property(l_lupa_it,"SIZE",24,20)
   CALL _ADVPL_set_property(l_lupa_it,"IMAGE","BTPESQ")
   CALL _ADVPL_set_property(l_lupa_it,"CLICK_EVENT","pol1363_zoom_item")

   LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_edit)
   CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 
   CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)
   CALL _ADVPL_set_property(l_caixa,"POSITION",240,50)     
   CALL _ADVPL_set_property(l_caixa,"LENGTH",50) 
   CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_item,"den_item")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_edit)
   CALL _ADVPL_set_property(l_label,"POSITION",10,80)     
   CALL _ADVPL_set_property(l_label,"TEXT","Quant:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

   LET m_quant = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_edit)
   CALL _ADVPL_set_property(m_quant,"EDITABLE",TRUE) 
   CALL _ADVPL_set_property(m_quant,"POSITION",80,80)     
   CALL _ADVPL_set_property(m_quant,"LENGTH",12,0)
   CALL _ADVPL_set_property(m_quant,"PICTURE","@E #######.###")
   CALL _ADVPL_set_property(m_quant,"VARIABLE",mr_item,"qtd_item")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_edit)
   CALL _ADVPL_set_property(l_label,"POSITION",240,80)     
   CALL _ADVPL_set_property(l_label,"TEXT","Preço:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

   LET m_preco = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_edit)
   CALL _ADVPL_set_property(m_preco,"EDITABLE",TRUE) 
   CALL _ADVPL_set_property(m_preco,"POSITION",300,80)     
   CALL _ADVPL_set_property(m_preco,"LENGTH",12,0)
   CALL _ADVPL_set_property(m_preco,"PICTURE","@E ########.##")
   CALL _ADVPL_set_property(m_preco,"VARIABLE",mr_item,"pre_unit")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_edit)
   CALL _ADVPL_set_property(l_label,"POSITION",10,120)     
   CALL _ADVPL_set_property(l_label,"TEXT","Entrega:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_entrega = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel_edit)
    CALL _ADVPL_set_property(m_entrega,"POSITION",80,120)
    CALL _ADVPL_set_property(m_entrega,"VARIABLE",mr_item,"dat_entrega")

END FUNCTION

#---------------------------#
FUNCTION pol1363_zoom_item()#
#---------------------------#

    DEFINE l_cod_item       LIKE item.cod_item,
           l_den_item       LIKE item.den_item,
           l_filtro         CHAR(300)
    
    IF  m_zproduto IS NULL THEN
        LET m_zproduto = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zproduto,"ZOOM","zoom_item")
    END IF

    LET l_filtro = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)
    
    CALL _ADVPL_get_property(m_zproduto,"ACTIVATE")
    
    LET l_cod_item = _ADVPL_get_property(m_zproduto,"RETURN_BY_TABLE_COLUMN","item","cod_item")

    IF l_cod_item IS NOT NULL THEN
        LET mr_item.cod_item = l_cod_item
        CALL pol1363_valida_item() RETURNING p_status
    END IF
    
END FUNCTION

#-----------------------------# 
FUNCTION pol1363_valida_item()#
#-----------------------------# 
   
   DEFINE l_ctr_estoque     CHAR(01)
   
   CALL _ADVPL_set_property(m_bar_edit,"ERROR_TEXT", '')
   
   IF mr_item.cod_item  IS NULL THEN
      CALL _ADVPL_set_property(m_bar_edit,"ERROR_TEXT", 'Campo obrigatório')
      CALL _ADVPL_set_property(m_item,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   SELECT den_item, ies_ctr_estoque INTO mr_item.den_item, l_ctr_estoque
     FROM item WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_item.cod_item

   IF STATUS = 100 THEN
      CALL _ADVPL_set_property(m_bar_edit,"ERROR_TEXT", 'Item não cadastrado.')
      CALL _ADVPL_set_property(m_item,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      CALL _ADVPL_set_property(m_item,"GET_FOCUS")
      RETURN FALSE
   END IF

   {IF l_ctr_estoque = 'N' THEN
      CALL _ADVPL_set_property(m_bar_edit,"ERROR_TEXT", 'Item não controla estoque.')
      CALL _ADVPL_set_property(m_item,"GET_FOCUS")
      RETURN FALSE
   END IF}
   
   IF mr_item.pre_unit = 0 THEN
      IF NOT pol1363_le_lista() THEN
         RETURN FALSE
      END IF   
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1363_canc_edicao()#
#-----------------------------#

   CALL _ADVPL_set_property(m_bar_edit,"ERROR_TEXT", '')   
   
   CALL _ADVPL_set_property(m_dlg_edit,"ACTIVATE",FALSE)
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1363_conf_edicao()#
#-----------------------------#
   
   DEFINE l_texto      CHAR(15)
   
   CALL _ADVPL_set_property(m_bar_edit,"ERROR_TEXT", '')
   
   IF NOT pol1363_valida_item() THEN
      RETURN FALSE
   END IF
   
   IF mr_item.qtd_item <= 0 THEN
      CALL _ADVPL_set_property(m_bar_edit,"ERROR_TEXT", 'Campo obrigatório.')
      CALL _ADVPL_set_property(m_quant,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_item.pre_unit <= 0 THEN
      CALL _ADVPL_set_property(m_bar_edit,"ERROR_TEXT", 'Campo obrigatório.')
      CALL _ADVPL_set_property(m_preco,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_item.dat_entrega IS NULL THEN
      CALL _ADVPL_set_property(m_bar_edit,"ERROR_TEXT", 'Campo obrigatório.')
      CALL _ADVPL_set_property(m_entrega,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   LET l_texto = mr_item.qtd_item
   
   IF m_opcao = 'A' THEN
      LET m_tip_inf = 'A'
      LET m_tip_mov = 'A'
      LET m_texto = 'ALTERACAO DA SEQUENCIA:',mr_item.num_seq USING '<<<'
      LET m_val_cred = mr_item.qtd_item * mr_item.pre_unit
      LET m_val_cred = m_val_cred - m_val_creda
   ELSE
      LET m_tip_inf = 'I'
      LET m_tip_mov = 'I'
      LET m_texto = 'INCLUSAO DE UM NOVO ITEM:',mr_item.cod_item
      LET m_texto = m_texto CLIPPED, ' SEQUENCIA: ',mr_item.num_seq USING '<<<'
      LET m_texto = m_texto CLIPPED, ' QUANT. SOLICITADA: ', l_texto
      LET m_val_cred = mr_item.qtd_item * mr_item.pre_unit
   END IF   
   
   CALL LOG_progresspopup_start("Salvando item...","pol1363_salvar","PROCESS") 
      
   CALL _ADVPL_set_property(m_dlg_edit,"ACTIVATE",FALSE)
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1363_salvar()#
#------------------------#

   CALL log085_transacao("BEGIN")
   
   IF NOT pol1363_grava_item() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
      LET m_carregando = TRUE
      CALL pol1363_le_itens()
      LET m_carregando = FALSE
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol1363_grava_item()#
#----------------------------#
   
   DEFINE l_progres SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",4)

   IF m_opcao = 'A' THEN
      LET m_num_seq = ma_itens[m_lin_atu].num_sequencia
      IF NOT pol1363_apaga_item() THEN
         RETURN FALSE
      END IF
      #IF NOT pol1363_atu_ped_itens() THEN
      #   RETURN FALSE
      #END IF
      IF NOT pol1363_ins_ped_itens() THEN
         RETURN FALSE
      END IF
   ELSE   
      IF NOT pol1363_ins_ped_itens() THEN
         RETURN FALSE
      END IF
   END IF
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   IF NOT pol1363_ins_audit_vdp() THEN
      RETURN FALSE
   END IF
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   IF NOT pol1363_ins_vdp_ped() THEN
      RETURN FALSE
   END IF
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   IF NOT pol1363_atu_cli_credito() THEN
      RETURN FALSE
   END IF
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1363_atu_ped_itens()#
#-------------------------------#

   UPDATE ped_itens
      SET cod_item = mr_item.cod_item,
          qtd_pecas_solic = mr_item.qtd_item,
          pre_unit = mr_item.pre_unit,
          prz_entrega = mr_item.dat_entrega
    WHERE cod_empresa = p_cod_empresa      
      AND num_sequencia = mr_item.num_seq 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ped_itens')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   

#-------------------------------#
FUNCTION pol1363_ins_ped_itens()#
#-------------------------------#
   
   DEFINE lr_ped_itens    RECORD LIKE ped_itens.*
   
   LET lr_ped_itens.cod_empresa = p_cod_empresa      
   LET lr_ped_itens.num_pedido  = mr_cabec.num_pedido
   LET lr_ped_itens.num_sequencia = mr_item.num_seq  
   LET lr_ped_itens.cod_item = mr_item.cod_item      
   LET lr_ped_itens.pct_desc_adic = 0                
   LET lr_ped_itens.pre_unit = mr_item.pre_unit      
   LET lr_ped_itens.qtd_pecas_solic = mr_item.qtd_item 
   LET lr_ped_itens.qtd_pecas_atend = 0              
   LET lr_ped_itens.qtd_pecas_cancel = 0             
   LET lr_ped_itens.qtd_pecas_reserv = 0             
   LET lr_ped_itens.prz_entrega = mr_item.dat_entrega 
   LET lr_ped_itens.val_desc_com_unit = 0            
   LET lr_ped_itens.val_frete_unit = 0               
   LET lr_ped_itens.val_seguro_unit = 0              
   LET lr_ped_itens.qtd_pecas_romaneio = 0           
   LET lr_ped_itens.pct_desc_bruto = 0               

   INSERT INTO ped_itens VALUES(lr_ped_itens.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ped_itens')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1363_ins_audit_vdp()#
#-------------------------------#
   
   DEFINE lr_audit_vdp    RECORD LIKE audit_vdp.*
   
   LET lr_audit_vdp.cod_empresa = p_cod_empresa       
   LET lr_audit_vdp.num_pedido  = mr_cabec.num_pedido 
   LET lr_audit_vdp.tipo_informacao = m_tip_inf       
   LET lr_audit_vdp.tipo_movto = m_tip_mov            
   LET lr_audit_vdp.texto = m_texto                   
   LET lr_audit_vdp.num_programa = 'POL1363'          
   LET lr_audit_vdp.data  = TODAY                     
   LET lr_audit_vdp.hora  = TIME                      
   LET lr_audit_vdp.usuario = p_user                  
   LET lr_audit_vdp.num_transacao = 0                 
   
   INSERT INTO audit_vdp VALUES(lr_audit_vdp.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','audit_vdp')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1363_ins_vdp_ped()#
#-----------------------------#
   
   DEFINE lr_vdp_ped    RECORD LIKE vdp_ped_item_compl.*
   
   DELETE FROM vdp_ped_item_compl
    WHERE empresa = p_cod_empresa
      AND pedido = mr_cabec.num_pedido
      AND sequencia_pedido = mr_item.num_seq            
      
   LET lr_vdp_ped.empresa = p_cod_empresa                        
   LET lr_vdp_ped.pedido = mr_cabec.num_pedido                   
   LET lr_vdp_ped.sequencia_pedido = mr_item.num_seq            
   LET lr_vdp_ped.campo ='dat_atualiz_item'                      
   LET lr_vdp_ped.par_existencia = NULL                          
   LET lr_vdp_ped.parametro_texto = NULL                         
   LET lr_vdp_ped.parametro_val = NULL                           
   LET lr_vdp_ped.parametro_dat = EXTEND(CURRENT, YEAR TO SECOND)

   INSERT INTO vdp_ped_item_compl VALUES(lr_vdp_ped.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','vdp_ped_item_compl')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1363_atu_cli_credito()#
#---------------------------------#
      
   UPDATE cli_credito 
      SET val_ped_carteira = val_ped_carteira + m_val_cred
    WHERE cod_cliente = mr_cabec.cod_cliente
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','cli_credito')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1363_apaga_item()#
#----------------------------#

   DELETE FROM ped_itens 
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = mr_cabec.num_pedido
      AND num_sequencia = m_num_seq
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','ped_itens')
      RETURN FALSE
   END IF

   DELETE FROM vdp_ped_item_compl
    WHERE empresa = p_cod_empresa
      AND pedido = mr_cabec.num_pedido
      AND sequencia_pedido = m_num_seq            

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','vdp_ped_item_compl')
      RETURN FALSE
   END IF
   
   LET m_val_cred = m_val_cred * (-1)
   
   IF NOT pol1363_atu_cli_credito() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1363_gera_solict()#
#-----------------------------#
   
   DEFINE l_dat_refer     DATE,
          l_qtd_item      INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')

   IF NOT m_ies_cons THEN
      IF mr_cabec.num_solicit IS NULL THEN
         LET m_msg = 'Informe um pedido previamente'
      ELSE
         LET m_msg = 'Pedido já contém solicitação de faturamento pronta'
      END IF
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   IF m_it_sem_saldo THEN
      LET m_msg = 'Pedio possui itens sem saldo suficiente para faturar.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN 
   END IF

   LET l_qtd_item = _ADVPL_get_property(m_browse,"ITEM_COUNT") 
   
   IF l_qtd_item = 0 THEN
      LET m_msg = 'Pedido não possui itens a faturar.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN 
   END IF

   LET l_dat_refer = TODAY
   
   SELECT COUNT(*)
     INTO m_count
     FROM fat_solic_mestre
    WHERE empresa = p_cod_empresa
      AND tip_docum = 'SOLPRDSV'
      AND dat_refer < l_dat_refer
   
   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql('SELECT','fat_solic_mestre',0)
      RETURN FALSE
   END IF
   
   IF m_count > 0 THEN
      LET m_msg = 'Existem solicitações não faturadas\n',
                  'com datas anteriores a atual.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF  

   CALL log085_transacao("BEGIN")
   
   IF NOT pol1363_seleciona_lote() THEN
      CALL log085_transacao("ROLLBACK")
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", "Operação cancelada.")
   ELSE
      CALL log085_transacao("COMMIT")
      LET mr_cabec.num_solicit = mr_transp.num_solicit
      CALL log0030_mensagem('Operação efetuada com sucesso.','info')
      LET m_ies_cons = FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1363_seleciona_lote()#
#--------------------------------#

   IF NOT pol1363_cria_numero() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1363_cria_tabs() THEN
      RETURN FALSE
   END IF

   IF NOT pol1363_grava_temp() THEN
      RETURN FALSE
   END IF
      
   IF m_count > 0 THEN
      LET m_ies_lote = FALSE
      CALL pol1363_tela_lote()
      IF NOT m_ies_lote THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", 'Operação cancelada.')
         RETURN FALSE
      END IF
   END IF
   
   IF NOT pol1363_chek_it_sem_lot() THEN 
      RETURN FALSE
   END IF
   
   LET p_status = TRUE
   
   CALL LOG_progresspopup_start("Gerando solicitação...","pol1363_proc_solic","PROCESS") 
   
   IF NOT p_status  THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1363_cria_numero()#
#-----------------------------#
   
   DEFINE l_numero     DECIMAL(3,0),
          l_data       CHAR(19),
          l_solic      CHAR(10)
   
   INITIALIZE mr_transp.* TO NULL

   LET l_data = EXTEND(CURRENT, YEAR TO SECOND)
   
   LET l_numero = mr_cabec.cod_cliente[1,3]
   
   SELECT MAX(num_solic) INTO mr_transp.num_solicit
     FROM num_solic_970 WHERE cod_empresa = p_cod_empresa
      AND prefixo = l_numero
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','num_solic_970')
      RETURN FALSE
   END IF
   
   IF mr_transp.num_solicit IS NULL THEN
      LET l_solic = l_numero USING '<<<'
      LET l_solic = l_solic  CLIPPED,'1'
      LET mr_transp.num_solicit = l_solic 
      INSERT INTO num_solic_970
       VALUES(p_cod_empresa, l_numero, mr_transp.num_solicit, l_data)
   ELSE      
      LET mr_transp.num_solicit = mr_transp.num_solicit + 1
      UPDATE num_solic_970 
       SET num_solic =  mr_transp.num_solicit, dat_geracao = l_data
      WHERE cod_empresa = p_cod_empresa
        AND prefixo = l_numero
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('atualizando','num_solic_970')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1363_cria_tabs()#
#---------------------------#
   
   DROP TABLE item_reser_970;
   
   CREATE TEMP TABLE item_reser_970 (
       num_pedido        DECIMAL(6,0),
       num_sequencia     DECIMAL(5,0),
       cod_item          CHAR(15),
       den_item          CHAR(76),
       cod_unid          CHAR(03),
       prz_entrega       DATE,
       qtd_pecas_solic   DECIMAL(10,3),
       pre_unit          DECIMAL(12,2),
       qtd_saldo         DECIMAL(10,3),
       qtd_estoq         DECIMAL(10,3),
       ctr_lote          CHAR(01),
       ctr_estoq         CHAR(01),
       tip_item          CHAR(01)
   );
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','item_reser_970')
      RETURN FALSE
   END IF
   
   CREATE UNIQUE INDEX ix_item_reser_970 ON
    item_reser_970(num_pedido,num_sequencia);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','ix_item_reser_970')
      RETURN FALSE
   END IF
    
   DROP TABLE lote_reser_970;
   
   CREATE TEMP TABLE lote_reser_970 (
       num_pedido        DECIMAL(6,0),
       num_sequencia     DECIMAL(5,0),
       num_lote          CHAR(15),
       qtd_reser         DECIMAL(10,3)
    );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','lote_reser_970')
      RETURN FALSE
   END IF
    
   CREATE INDEX ix_lote_reser_970 ON
    lote_reser_970(num_pedido,num_sequencia);
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','ix_lote_reser_970')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1363_grava_temp()#
#----------------------------#
   
   DEFINE l_ind          INTEGER,
          l_tipo         CHAR(01),
          l_cod_item     CHAR(15)
   
   LET m_count = 0
   
   LET m_index = _ADVPL_get_property(m_browse,"ITEM_COUNT")   
   
   FOR l_ind = 1 TO m_index
       
       IF ma_itens[l_ind].qtd_saldo <= 0 THEN
          LET m_msg = 'Pedido poosui item sem saldo.'
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
          RETURN FALSE
       END IF
       
       LET l_cod_item = ma_itens[l_ind].cod_item CLIPPED
       
       IF l_cod_item[1,2] = 'EM' THEN
          LET l_tipo = 'E'
       ELSE
          LET l_tipo = 'B'
       END IF
       
       INSERT INTO item_reser_970
        VALUES(mr_cabec.num_pedido,
               ma_itens[l_ind].num_sequencia,
               ma_itens[l_ind].cod_item,      
               ma_itens[l_ind].den_item,       
               ma_itens[l_ind].cod_unid,       
               ma_itens[l_ind].prz_entrega,    
               ma_itens[l_ind].qtd_pecas_solic,
               ma_itens[l_ind].pre_unit,       
               ma_itens[l_ind].qtd_saldo,      
               ma_itens[l_ind].qtd_estoq,      
               ma_itens[l_ind].ctr_lote,  
               ma_itens[l_ind].ctr_estoq,  
               l_tipo)
       
       IF STATUS <> 0 THEN
          CALL log003_err_sql('INSERT','item_reser_970')
          RETURN FALSE
       END IF
       
       IF ma_itens[l_ind].ctr_lote = 'S' AND ma_itens[l_ind].ctr_estoq = 'S' THEN
          LET m_count = m_count + 1
       END IF
                      
   END FOR
              
   RETURN TRUE

END FUNCTION
   
#---------------------------#
FUNCTION pol1363_tela_lote()#
#---------------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_confirma    VARCHAR(10),
           l_cancela     VARCHAR(10),
           l_label       VARCHAR(10)

    LET mr_transp.tip_frete = 'N'
    LET m_carregando = TRUE
    
    LET m_dlg_lote = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dlg_lote,"SIZE",1250,500) #largura x alterua
    CALL _ADVPL_set_property(m_dlg_lote,"TITLE","SELEÇÃO DE LOTES E TRASPORTADORA")
    CALL _ADVPL_set_property(m_dlg_lote,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dlg_lote,"INIT_EVENT","pol1363_foca_campo")

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dlg_lote)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
   CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirma,"EVENT","pol1363_conf_lote")  

   LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancela,"EVENT","pol1363_canc_lote")     

   LET m_bar_lote = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dlg_lote)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dlg_lote)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
   
   #CALL pol1363_campos_transp(l_panel)
   LET mr_transp.cod_transpor = '0'
   LET mr_transp.tip_frete = 'F'
   LET mr_transp.cod_via = '1'
   
   CALL pol1363_grade_lote(l_panel)
   CALL pol1363_grade_reserva(l_panel)

   LET m_carregando = TRUE
   CALL pol1363_le_it_reser() RETURNING p_status
   LET m_carregando = FALSE
   
   IF NOT p_status THEN
      RETURN
   END IF
      
   CALL _ADVPL_set_property(m_dlg_lote,"ACTIVATE",TRUE)
    
END FUNCTION

#----------------------------#
FUNCTION pol1363_foca_campo()#
#----------------------------#

   #CALL _ADVPL_set_property(m_transpor,"GET_FOCUS")

END FUNCTION

#------------------------------------------#
FUNCTION pol1363_campos_transp(l_container)#
#------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_lupa            VARCHAR(10),
           l_caixa           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",70)    
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Num solicit:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_solicit = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_solicit,"POSITION",100,10)     
    CALL _ADVPL_set_property(m_solicit,"VARIABLE",mr_transp,"num_solicit")
    CALL _ADVPL_set_property(m_solicit,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_solicit,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_solicit,"CAN_GOT_FOCUS",FALSE)
    #CALL _ADVPL_set_property(m_solicit,"VALID","pol1363_valid_solic")
       
    LET l_label = _ADVPL_create_component(NULL,"LCLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",190,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Transportador:")    

    LET m_transpor = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_transpor,"POSITION",280,10)     
    CALL _ADVPL_set_property(m_transpor,"LENGTH",15)
    CALL _ADVPL_set_property(m_transpor,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_transpor,"PICTURE","@E!")
    CALL _ADVPL_set_property(m_transpor,"VARIABLE",mr_transp,"cod_transpor")
    CALL _ADVPL_set_property(m_transpor,"VALID","pol1363_valid_transp")

    LET l_lupa = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(l_lupa,"POSITION",420,10)     
    CALL _ADVPL_set_property(l_lupa,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa,"CLICK_EVENT","pol1363_zoom_trasport")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",450,10)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",36)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E!")
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_transp,"nom_transpor")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",760,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Tipo frete:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LCOMBOBOX",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",830,10)     
    CALL _ADVPL_set_property(l_caixa,"ADD_ITEM","N","  ")     
    CALL _ADVPL_set_property(l_caixa,"ADD_ITEM","C","CIF")     
    CALL _ADVPL_set_property(l_caixa,"ADD_ITEM","F","FOB")     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_transp,"tip_frete")

    LET l_label = _ADVPL_create_component(NULL,"LCLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",880,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Plava veículo:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",970,10)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E!")
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_transp,"num_placa")

    LET l_label = _ADVPL_create_component(NULL,"LCLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1075,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","UF:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",1105,10)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",4)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E!")
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_transp,"uf_veiculo")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Cód texto1:")    

    LET m_texto_1 = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_texto_1,"POSITION",100,40)     
    CALL _ADVPL_set_property(m_texto_1,"VARIABLE",mr_transp,"cod_texto_1")
    CALL _ADVPL_set_property(m_texto_1,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_texto_1,"VALID","pol1363_ck_texto1")
    
    LET m_lupa_tx1 = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_tx1,"POSITION",190,40)     
    CALL _ADVPL_set_property(m_lupa_tx1,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_tx1,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_tx1,"CLICK_EVENT","pol1363_zoom_txt_1")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",220,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Cód texto2:")    

    LET m_texto_2 = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_texto_2,"POSITION",300,40)     
    CALL _ADVPL_set_property(m_texto_2,"VARIABLE",mr_transp,"cod_texto_2")
    CALL _ADVPL_set_property(m_texto_2,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_texto_2,"VALID","pol1363_ck_texto2")

    LET m_lupa_tx2 = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_tx2,"POSITION",390,40)     
    CALL _ADVPL_set_property(m_lupa_tx2,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_tx2,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_tx2,"CLICK_EVENT","pol1363_zoom_txt_2")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",420,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Cód texto3:")    

    LET m_texto_3 = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_texto_3,"POSITION",500,40)     
    CALL _ADVPL_set_property(m_texto_3,"VARIABLE",mr_transp,"cod_texto_3")
    CALL _ADVPL_set_property(m_texto_3,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_texto_3,"VALID","pol1363_ck_texto3")

    LET m_lupa_tx3 = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_tx3,"POSITION",590,40)     
    CALL _ADVPL_set_property(m_lupa_tx3,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_tx3,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_tx3,"CLICK_EVENT","pol1363_zoom_txt_3")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",620,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Via transp:")    

    LET m_via = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_via,"POSITION",700,40)     
    CALL _ADVPL_set_property(m_via,"VARIABLE",mr_transp,"cod_via")
    CALL _ADVPL_set_property(m_via,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_via,"VALID","pol1363_ck_via")

    LET m_lupa_via = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_via,"POSITION",790,40)     
    CALL _ADVPL_set_property(m_lupa_via,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_via,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_via,"CLICK_EVENT","pol1363_zoom_via")

END FUNCTION

#-----------------------------#
FUNCTION pol1363_valid_solic()#
#-----------------------------#

   CALL _ADVPL_set_property(m_bar_lote,"ERROR_TEXT", '')
      
   IF mr_transp.num_solicit IS NULL OR mr_transp.num_solicit <= 0 THEN
      LET m_msg = 'informe o número da solicitação.'
      CALL _ADVPL_set_property(m_bar_lote,"ERROR_TEXT", m_msg)
      CALL _ADVPL_set_property(m_solicit,"GET_FOCUS")
      RETURN FALSE
   END IF   
   
   SELECT COUNT(*) INTO m_count
     FROM fat_solic_mestre
    WHERE empresa = p_cod_empresa
      AND solicitacao_fatura = mr_transp.num_solicit

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','fat_solic_mestre')
      RETURN FALSE
   END IF
   
   IF m_count > 0 THEN
      LET m_msg = 'Já existe uma solicitação com esse número sem faturar.'
      CALL _ADVPL_set_property(m_bar_lote,"ERROR_TEXT", m_msg)
      CALL _ADVPL_set_property(m_solicit,"GET_FOCUS")
      RETURN FALSE
   END IF   
        
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1363_valid_transp()#
#------------------------------#

   CALL _ADVPL_set_property(m_bar_lote,"ERROR_TEXT", '')
      
   IF mr_transp.cod_transpor IS NULL THEN
      RETURN TRUE
   END IF   

   CALL pol1363_le_transp(mr_transp.cod_transpor)
   LET mr_transp.nom_transpor = m_nom_transp
   
   IF mr_transp.nom_transpor IS NULL THEN
      LET m_msg = 'Transportador inexistente.'
      CALL _ADVPL_set_property(m_bar_lote,"ERROR_TEXT", m_msg)
      CALL _ADVPL_set_property(m_transpor,"GET_FOCUS")
      RETURN FALSE
   END IF      
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1363_le_transp(l_cod)#
#--------------------------------#

   DEFINE l_cod        CHAR(15)
   
   SELECT nom_cliente
     INTO m_nom_transp
     FROM clientes
    WHERE cod_cliente = l_cod
      AND ies_situacao = "A" 
      #AND (cod_tip_cli = m_cod_transp  OR cod_tip_cli = m_cod_transp_auto)

   IF STATUS = 100 THEN
      LET m_nom_transp = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','transportador')
         LET m_nom_transp = NULL
      END IF
   END IF

END FUNCTION

#-------------------------------#
FUNCTION pol1363_zoom_trasport()#
#-------------------------------#

    DEFINE l_codigo       LIKE clientes.cod_cliente,
           l_descri       LIKE clientes.nom_cliente
    
    IF  m_ztransp IS NULL THEN
        LET m_ztransp = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_ztransp,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_ztransp,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_ztransp,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_descri = _ADVPL_get_property(m_ztransp,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")

    IF l_codigo IS NOT NULL THEN
       LET mr_transp.cod_transpor = l_codigo
       LET mr_transp.nom_transpor = l_descri
    END IF
    
    CALL _ADVPL_set_property(m_transpor,"GET_FOCUS")

END FUNCTION

#----------------------------#
FUNCTION pol1363_zoom_txt_1()#
#----------------------------#

    DEFINE l_codigo       LIKE texto_nf.cod_texto,
           l_descri       LIKE texto_nf.des_texto
    
    IF  m_zoom_txt IS NULL THEN
        LET m_zoom_txt = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_txt,"ZOOM","zoom_texto_nf")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_txt,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_txt,"RETURN_BY_TABLE_COLUMN","texto_nf","cod_texto")
    LET l_descri = _ADVPL_get_property(m_zoom_txt,"RETURN_BY_TABLE_COLUMN","texto_nf","des_texto")

    IF l_codigo IS NOT NULL THEN
       LET mr_transp.cod_texto_1 = l_codigo
    END IF
    
    CALL _ADVPL_set_property(m_texto_1,"GET_FOCUS")

END FUNCTION

#---------------------------#
FUNCTION pol1363_ck_texto1()#
#---------------------------#

   IF NOT pol1363_le_texto(mr_transp.cod_texto_1) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1363_ck_texto2()#
#---------------------------#

   IF NOT pol1363_le_texto(mr_transp.cod_texto_2) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1363_ck_texto3()#
#---------------------------#

   IF NOT pol1363_le_texto(mr_transp.cod_texto_3) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1363_le_texto(l_cod)#
#-------------------------------#
   
   DEFINE l_cod        LIKE texto_nf.cod_texto
   
   IF l_cod IS NOT NULL THEN
      SELECT des_texto
        FROM texto_nf
       WHERE cod_texto = l_cod
      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("SELECT","texto_nf",0)
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1363_zoom_txt_2()#
#----------------------------#

    DEFINE l_codigo       LIKE texto_nf.cod_texto,
           l_descri       LIKE texto_nf.des_texto
    
    IF  m_zoom_txt IS NULL THEN
        LET m_zoom_txt = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_txt,"ZOOM","zoom_texto_nf")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_txt,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_txt,"RETURN_BY_TABLE_COLUMN","texto_nf","cod_texto")
    LET l_descri = _ADVPL_get_property(m_zoom_txt,"RETURN_BY_TABLE_COLUMN","texto_nf","des_texto")

    IF l_codigo IS NOT NULL THEN
       LET mr_transp.cod_texto_2 = l_codigo
    END IF
    
    CALL _ADVPL_set_property(m_texto_2,"GET_FOCUS")

END FUNCTION


#----------------------------#
FUNCTION pol1363_zoom_txt_3()#
#----------------------------#

    DEFINE l_codigo       LIKE texto_nf.cod_texto,
           l_descri       LIKE texto_nf.des_texto
    
    IF  m_zoom_txt IS NULL THEN
        LET m_zoom_txt = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_txt,"ZOOM","zoom_texto_nf")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_txt,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_txt,"RETURN_BY_TABLE_COLUMN","texto_nf","cod_texto")
    LET l_descri = _ADVPL_get_property(m_zoom_txt,"RETURN_BY_TABLE_COLUMN","texto_nf","des_texto")

    IF l_codigo IS NOT NULL THEN
       LET mr_transp.cod_texto_3 = l_codigo
    END IF
    
    CALL _ADVPL_set_property(m_texto_3,"GET_FOCUS")

END FUNCTION

#--------------------------#
FUNCTION pol1363_zoom_via()#
#--------------------------#

    DEFINE l_codigo       LIKE via_transporte.cod_via_transporte,
           l_descri       LIKE via_transporte.den_via_transporte
    
    IF  m_zoom_via IS NULL THEN
        LET m_zoom_via = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_via,"ZOOM","zoom_via_transporte")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_via,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_via,"RETURN_BY_TABLE_COLUMN","via_transporte","cod_via_transporte")
    LET l_descri = _ADVPL_get_property(m_zoom_via,"RETURN_BY_TABLE_COLUMN","via_transporte","den_via_transporte")

    IF l_codigo IS NOT NULL THEN
       LET mr_transp.cod_via = l_codigo
    END IF
    
    CALL _ADVPL_set_property(m_via,"GET_FOCUS")

END FUNCTION

#------------------------#
FUNCTION pol1363_ck_via()#
#------------------------#

   IF mr_transp.cod_via IS NOT NULL THEN
      SELECT den_via_transporte
        FROM via_transporte
       WHERE cod_via_transporte = mr_transp.cod_via
      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("SELECT","via_transporte",0)
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1363_zoom_lote()#
#---------------------------#

    DEFINE l_num_lote       LIKE estoque_lote_ender.num_lote,
           l_qtd_saldo      LIKE estoque_lote_ender.qtd_saldo,
           l_filtro         CHAR(300)
    
    IF  m_zlote IS NULL THEN
        LET m_zlote = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zlote,"ZOOM","zoom_estoque_lote_ender")
    END IF

    LET l_filtro = " estoque_lote_ender.cod_empresa = '",p_cod_empresa,"' "
    LET l_filtro = l_filtro CLIPPED, " and estoque_lote_ender.cod_item = '",m_cod_item,"' "
    
    CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)
    
    CALL _ADVPL_get_property(m_zlote,"ACTIVATE")
    
    LET l_num_lote = _ADVPL_get_property(m_zlote,"RETURN_BY_TABLE_COLUMN","estoque_lote_ender","num_lote")
    LET l_qtd_saldo = _ADVPL_get_property(m_zlote,"RETURN_BY_TABLE_COLUMN","estoque_lote_ender","qtd_saldo")

    IF l_num_lote IS NOT NULL THEN
        LET ma_itens[m_lin_atu].num_lote = l_num_lote
        CALL log0030_mensagem(l_num_lote,'info')
        CALL log0030_mensagem(l_qtd_saldo,'info')
    END IF
      
END FUNCTION

#------------------------------------------#
FUNCTION pol1363_grade_reserva(l_container)#
#------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(l_panel,"WIDTH",800)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_reser = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_reser,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_reser,"BEFORE_ROW_EVENT","pol1363_before_reserva")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_reser)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sequenc")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_sequencia")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E #####")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_reser)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Produto")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD") 
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_reser)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",300)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_reser)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Unid")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_unid")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_reser)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd faturar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ########.###")

    CALL _ADVPL_set_property(m_brz_reser,"SET_ROWS",ma_reserva,1)
    CALL _ADVPL_set_property(m_brz_reser,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_reser,"CAN_REMOVE_ROW",FALSE)

END FUNCTION

#---------------------------------------#
FUNCTION pol1363_grade_lote(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_label           VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","RIGHT")
    #CALL _ADVPL_set_property(l_panel,"WIDTH",350)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brz_lote = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_lote,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_lote)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sel")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",55)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_select")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1363_sel_lote")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_lote)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Lote")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_lote")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_lote)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_tipo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_lote)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ##########")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_lote)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Selecionado")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_faturar")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E #######.###")

    CALL _ADVPL_set_property(m_brz_lote,"SET_ROWS",ma_lote,1)
    CALL _ADVPL_set_property(m_brz_lote,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_brz_lote,"CAN_REMOVE_ROW",FALSE)

END FUNCTION

#--------------------------------#
FUNCTION pol1363_before_reserva()#
#--------------------------------#

   IF m_carregando THEN
      RETURN
   END IF
   
   LET m_lin_reser = _ADVPL_get_property(m_brz_reser,"ROW_SELECTED")
   LET m_cod_item = ma_reserva[m_lin_reser].cod_item
   
   IF NOT pol1363_le_lote() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1363_le_it_reser()#
#-----------------------------#
   
   DEFINE l_ind       INTEGER
   
   CALL _ADVPL_set_property(m_brz_reser,"CLEAR")   
   INITIALIZE ma_reserva TO NULL
   LET l_ind = 1
   
   DECLARE cq_it_reser CURSOR FOR
    SELECT num_sequencia,
           cod_item,     
           den_item,     
           cod_unid,     
           qtd_saldo
      FROM item_reser_970 
     WHERE ctr_lote = 'S'    
       AND ctr_estoq = 'S'

   FOREACH cq_it_reser INTO 
        ma_reserva[l_ind].num_sequencia,                         
        ma_reserva[l_ind].cod_item,                              
        ma_reserva[l_ind].den_item,                              
        ma_reserva[l_ind].cod_unid,                              
        ma_reserva[l_ind].qtd_saldo                         
            
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_it_reser')
         RETURN FALSE
      END IF
      
      LET ma_reserva[l_ind].qtd_lote = 0
      
      LET l_ind = l_ind + 1
      IF l_ind > 500 THEN
         LET m_msg = 'Limite de linhas da grade\n de itens ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
    
   END FOREACH
         
   IF l_ind > 1 THEN                              
      LET l_ind = l_ind - 1
      CALL _ADVPL_set_property(m_brz_reser,"ITEM_COUNT", l_ind)
      LET m_lin_reser = 1
      LET m_cod_item = ma_reserva[m_lin_reser].cod_item
      IF NOT pol1363_le_lote() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION   
    
#-------------------------#
FUNCTION pol1363_le_lote()#
#-------------------------#

   DEFINE l_qtd_reservada    DECIMAL(10,3),
          l_num_lote         CHAR(15),
          l_ind              INTEGER,
          l_qtd_fat          INTEGER,
          l_local_estoq      CHAR(10)
   
   INITIALIZE ma_lote TO NULL
   CALL _ADVPL_set_property(m_brz_lote,"CLEAR")

   SELECT cod_local_estoq
     INTO l_local_estoq
     FROM item 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   LET l_ind = 1
   
   DECLARE cq_lote CURSOR FOR
    SELECT num_lote, ies_situa_qtd, qtd_saldo
      FROM estoque_lote_ender
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = m_cod_item
       AND cod_local = l_local_estoq
       AND qtd_saldo > 0
       AND ies_situa_qtd = 'L'
       
   FOREACH cq_lote INTO
      ma_lote[l_ind].num_lote, 
      ma_lote[l_ind].ies_tipo, 
      ma_lote[l_ind].qtd_saldo

      IF STATUS <> 0 THEN
          CALL log003_err_sql("FOREACH","cq_lote")
          RETURN FALSE
      END IF
 
     LET l_num_lote = ma_lote[l_ind].num_lote
     
     SELECT SUM(qtd_reservada)
       INTO l_qtd_reservada
       FROM estoque_loc_reser
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = m_cod_item
        AND cod_local = l_local_estoq
        AND num_lote = l_num_lote 

      IF STATUS <> 0 THEN
          CALL log003_err_sql("Selecione","estoque_loc_reser:cq_lote")
          RETURN FALSE
      END IF

      IF l_qtd_reservada IS NULL OR l_qtd_reservada < 0 THEN
         LET l_qtd_reservada = 0
      END IF
         
      LET ma_lote[l_ind].qtd_saldo = ma_lote[l_ind].qtd_saldo - l_qtd_reservada
      
      IF ma_lote[l_ind].qtd_saldo <= 0 THEN
         DELETE FROM lote_reser_970
          WHERE num_pedido = mr_cabec.num_pedido
            AND num_sequencia = ma_reserva[m_lin_reser].num_sequencia
            AND num_lote = l_num_lote         
         CONTINUE FOREACH
      END IF

      SELECT qtd_reser INTO ma_lote[l_ind].qtd_faturar FROM lote_reser_970
       WHERE num_pedido = mr_cabec.num_pedido
         AND num_sequencia = ma_reserva[m_lin_reser].num_sequencia
         AND num_lote = l_num_lote
    
      IF STATUS = 100 THEN
         LET ma_lote[l_ind].ies_select = 'N'
         LET ma_lote[l_ind].qtd_faturar = 0
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','lote_reser_970:cq_lote')
            RETURN FALSE
         ELSE
            LET ma_lote[l_ind].ies_select = 'S'
         END IF
      END IF
                                 
      LET l_ind = l_ind + 1
      
      IF l_ind > 100 THEN
         LET m_msg = 'Limite de linhas de\n lotes ultrapasou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF

   END FOREACH

   LET l_ind = l_ind - 1
   CALL _ADVPL_set_property(m_brz_lote,"ITEM_COUNT", l_ind)

   CALL _ADVPL_set_property(m_brz_lote,"CAN_ADD_ROW",FALSE)
      
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1363_sel_lote()#
#--------------------------#

   DEFINE l_lin_lote      INTEGER,
          l_qtd_saldo     DECIMAL(10,3),
          l_qtd_sel       DECIMAL(10,3),
          l_qtd_falta     DECIMAL(10,3),
          l_qtd_fat      DECIMAL(10,3)
   
   CALL _ADVPL_set_property(m_bar_lote,"ERROR_TEXT",'')

   LET l_lin_lote = _ADVPL_get_property(m_brz_lote,"ROW_SELECTED")  
   LET l_qtd_saldo =  ma_lote[l_lin_lote].qtd_saldo
   LET l_qtd_falta = ma_reserva[m_lin_reser].qtd_saldo - ma_reserva[m_lin_reser].qtd_lote
   
   IF ma_lote[l_lin_lote].ies_select = 'S' THEN
      IF l_qtd_falta <= 0 THEN
         LET m_msg = 'Você já selecionou  lote suficiente a faturar'
         CALL _ADVPL_set_property(m_bar_lote,"ERROR_TEXT",m_msg)
         LET ma_lote[l_lin_lote].ies_select = 'N'
         RETURN FALSE
      ELSE
         IF l_qtd_falta > l_qtd_saldo THEN
            LET l_qtd_fat = l_qtd_saldo
         ELSE
            LET l_qtd_fat = l_qtd_falta
         END IF

         LET ma_lote[l_lin_lote].qtd_faturar = l_qtd_fat
         LET ma_reserva[m_lin_reser].qtd_lote = ma_reserva[m_lin_reser].qtd_lote + l_qtd_fat

         INSERT INTO lote_reser_970 
           VALUES(mr_cabec.num_pedido,
                  ma_reserva[m_lin_reser].num_sequencia,
                  ma_lote[l_lin_lote].num_lote,
                  l_qtd_fat)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('INSERT','lote_reser_970')
            RETURN FALSE
         END IF
         
         RETURN TRUE     
      END IF 
   END IF
   
   LET l_qtd_fat = ma_lote[l_lin_lote].qtd_faturar
   LET ma_lote[l_lin_lote].qtd_faturar = 0
   
   IF ma_reserva[m_lin_reser].qtd_lote > l_qtd_fat THEN
      LET ma_reserva[m_lin_reser].qtd_lote = ma_reserva[m_lin_reser].qtd_lote - l_qtd_fat 
   ELSE
      LET ma_reserva[m_lin_reser].qtd_lote = 0
   END IF
   
   DELETE FROM lote_reser_970
    WHERE num_pedido = mr_cabec.num_pedido
      AND num_sequencia = ma_reserva[m_lin_reser].num_sequencia
      AND num_lote = ma_lote[l_lin_lote].num_lote

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','lote_reser_970')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1363_canc_lote()#
#---------------------------#

   CALL _ADVPL_set_property(m_dlg_lote,"ACTIVATE",FALSE) 
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1363_conf_lote()#
#---------------------------#
   
   DEFINE l_it_reser     INTEGER,
          l_ind          INTEGER
   
   LET m_msg = "";
   
   LET l_it_reser = _ADVPL_get_property(m_brz_reser,"ITEM_COUNT")  
   
   FOR l_ind = 1 TO l_it_reser
       
       IF ma_reserva[l_ind].qtd_saldo <> ma_reserva[l_ind].qtd_lote THEN
          LET m_msg = m_msg CLIPPED, 'Sequencia: ', ma_reserva[l_ind].num_sequencia USING '<<<<<'
          LET m_msg = m_msg CLIPPED, '. Você não selecionou lotes suficientes.\n'
       END IF
       
   END FOR
   
   IF m_msg IS NOT NULL THEN
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   LET m_ies_lote = TRUE
   
   CALL _ADVPL_set_property(m_dlg_lote,"ACTIVATE",FALSE) 

END FUNCTION

#---------------------------------#
FUNCTION pol1363_chek_it_sem_lot()#
#---------------------------------#

   DECLARE cq_it_sem_lot CURSOR FOR
    SELECT num_pedido, num_sequencia, 
           cod_item, qtd_saldo
      FROM item_reser_970
     WHERE ctr_lote = 'N'
       AND ctr_estoq = 'S'

   FOREACH cq_it_sem_lot INTO
      m_num_pedio, m_num_seq, m_cod_item, m_qtd_saldo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_it_sem_lot')
         RETURN FALSE
      END IF
      
      INSERT INTO lote_reser_970
       VALUES(m_num_pedio, m_num_seq, NULL, m_qtd_saldo)
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','lote_reser_970')
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION
   
#----------------------------#   
FUNCTION pol1363_proc_solic()#
#----------------------------#
   
   SELECT COUNT(num_sequencia) 
     INTO m_count
     FROM item_reser_970
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','lote_reser_970')
      LET p_status = FALSE
      RETURN p_status
   END IF

   IF mr_transp.tip_frete = 'F' THEN 
      LET m_ies_modalidade = '1'
   ELSE
      LET m_ies_modalidade = '0'
   END IF
   
   LET p_status = pol1363_processa()
   
   RETURN p_status

END FUNCTION

#--------------------------#
FUNCTION pol1363_processa()#
#--------------------------#

   DEFINE l_count     INTEGER,
          l_qtd_om    INTEGER,
          l_controle  INTEGER,
          l_progres   SMALLINT,
          l_ind       INTEGER
   
   LET m_dat_atu = TODAY
         
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   SELECT cod_cliente
     FROM cliente_nf_970
    WHERE cod_cliente = mr_cabec.cod_cliente

   IF STATUS = 0 THEN
      LET l_qtd_om = 2
   ELSE
      IF STATUS = 100 THEN
         LET l_qtd_om = 1
      ELSE
         CALL log003_err_sql('SELECT','cliente_nf_970')
         RETURN FALSE
      END IF      
   END IF

   IF NOT pol1363_le_vdp_num_docum() THEN
      RETURN FALSE
   END IF
   
   LET m_ies_solic = 'O' 
   
   IF NOT pol1363_ins_solic_mest() THEN
      RETURN FALSE
   END IF
   
   LET m_seq_fatura = 0
   LET m_ctr_fatura = 0
   
   LET l_controle = l_qtd_om
   
   FOR l_ind = 1 TO l_qtd_om

       IF NOT pol1363_prox_num() THEN
          RETURN FALSE
       END IF
       
       LET l_progres = LOG_progresspopup_increment("PROCESS")  
   
       DECLARE cq_oms CURSOR FOR
        SELECT num_pedido, num_sequencia, cod_item,
               cod_unid, qtd_saldo, ctr_lote
          FROM item_reser_970
         WHERE (tip_item = 'B' AND l_controle = 2) 
            OR (tip_item IN ('B','E') AND l_controle = 1) 
            OR (tip_item = 'E' AND l_controle = 3) 

    
       FOREACH cq_oms INTO m_num_pedido, m_num_sequencia,
          m_cod_item, m_cod_unid_med, m_qtd_faturar, m_ies_ctr_lote
          
          IF STATUS <> 0 THEN
             CALL log003_err_sql('FOREACH','cq_oms')
             RETURN FALSE
          END IF
             
          IF NOT pol1363_ins_om_item() THEN
             RETURN FALSE
          END IF
                 
       END FOREACH

       IF NOT pol1363_ins_om_mest() THEN
          RETURN FALSE
       END IF

       IF NOT pol1363_ins_solic_fatura() THEN
          RETURN FALSE
       END IF
       
       FREE cq_oms

       LET l_controle = 3
   
   END FOR
   
   LET l_progres = LOG_progresspopup_increment("PROCESS") 
   
   #gerar solicit
   
END FUNCTION

#----------------------------------#
FUNCTION pol1363_le_vdp_num_docum()#
#----------------------------------#

   SELECT UNIQUE 
    tip_solicitacao,
		serie_docum,  
    subserie_docum,
    especie_docum,  
    tip_docum
   INTO m_tip_solic,
        m_nser,
        m_sser,
        m_espcie,
        m_tip_docum
    FROM vdp_num_docum 
   WHERE empresa = p_cod_empresa
     AND tip_solicitacao = 'SOLPRDSV'
	   AND serie_docum = '1'  
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','vdp_num_docum')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1363_ins_solic_mest()#
#--------------------------------#

   DEFINE lr_fat_solic_mestre      RECORD LIKE fat_solic_mestre.*
   

		LET lr_fat_solic_mestre.trans_solic_fatura 	= 0
		LET lr_fat_solic_mestre.empresa = p_cod_empresa
		LET lr_fat_solic_mestre.tip_docum	= m_tip_solic
		LET lr_fat_solic_mestre.serie_fatura = m_nser
		LET lr_fat_solic_mestre.subserie_fatura	= m_sser
		LET lr_fat_solic_mestre.especie_fatura = m_espcie
		LET lr_fat_solic_mestre.solicitacao_fatura = mr_transp.num_solicit
		LET lr_fat_solic_mestre.usuario	= p_user
		LET lr_fat_solic_mestre.inscricao_estadual = NULL
		LET lr_fat_solic_mestre.dat_refer	= TODAY
		LET lr_fat_solic_mestre.tip_solicitacao	= m_ies_solic
		LET lr_fat_solic_mestre.lote_geral = 'N' 
		LET lr_fat_solic_mestre.tip_carteira = NULL
		LET lr_fat_solic_mestre.sit_solic_fatura = 'C'
		
		INSERT INTO fat_solic_mestre (		
		        empresa,                                           
						tip_docum,                               					
						serie_fatura,                            					
						subserie_fatura,                         					
						especie_fatura,                          					
						solicitacao_fatura,                      					
						usuario,                                 					
						inscricao_estadual,                      					
						dat_refer,                               					
						tip_solicitacao,                         					
						lote_geral,                              					
						tip_carteira,                            					
						sit_solic_fatura)                        					
				VALUES (lr_fat_solic_mestre.empresa,         					
						lr_fat_solic_mestre.tip_docum,           					
						lr_fat_solic_mestre.serie_fatura,        					
						lr_fat_solic_mestre.subserie_fatura,     					
						lr_fat_solic_mestre.especie_fatura,      					
						lr_fat_solic_mestre.solicitacao_fatura,  					
						lr_fat_solic_mestre.usuario,             					
						lr_fat_solic_mestre.inscricao_estadual,  					
						lr_fat_solic_mestre.dat_refer,           					
						lr_fat_solic_mestre.tip_solicitacao,     					
						lr_fat_solic_mestre.lote_geral,          					
						lr_fat_solic_mestre.tip_carteira,        					
						lr_fat_solic_mestre.sit_solic_fatura)    					

	 IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','fat_solic_mestre')
      RETURN FALSE
	 END IF
											
   LET m_num_transac = SQLCA.SQLERRD[2]
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1363_prox_num()#
#--------------------------#

   DEFINE l_par_vdp_txt   LIKE par_vdp.par_vdp_txt
   
   DEFINE l_lote_om    CHAR(05)

   SELECT par_vdp_txt                         
     INTO l_par_vdp_txt                                    
     FROM par_vdp                                              
    WHERE cod_empresa = p_cod_empresa                          

   IF STATUS = 100 THEN                                 
      LET m_lote_om = 0                                 
   ELSE                 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','par_vdp:lote')
         RETURN FALSE
      END IF
      IF l_par_vdp_txt IS NULL THEN
         LET m_lote_om =  0
      ELSE                    
         LET l_lote_om = l_par_vdp_txt[92,96]           
         LET m_lote_om = l_lote_om
      END IF
   END IF                                                      
      
   LET m_lote_om = m_lote_om + 1
   LET l_lote_om = m_lote_om USING "&&&&&" 
   LET l_par_vdp_txt[92,96] = l_lote_om
   
   UPDATE par_vdp                                              
      SET par_vdp_txt = l_par_vdp_txt                      
    WHERE cod_empresa = p_cod_empresa                          
      
   IF STATUS <> 0 THEN                                  
      CALL log003_err_sql("ALTERACAO","PAR_VDP")               
      RETURN FALSE                       
   END IF                                                      

   SELECT num_ult_om
     INTO m_num_om
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 100 THEN
      LET m_num_om = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','par_vdp')
         RETURN FALSE
      END IF
   END IF
   
   IF m_num_om IS NULL THEN
      LET m_num_om = 0
   END IF

   LET m_num_om = m_num_om + 1
 
   UPDATE par_vdp
      SET num_ult_om = m_num_om
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('atualizando','par_vdp')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1363_ins_om_item()#
#-----------------------------#

   IF NOT pol1363_reserva() THEN
      RETURN FALSE
   END IF

   IF NOT pol1363_embalagem() THEN
      RETURN FALSE
   END IF
 
   IF NOT pol1363_om_item() THEN
      RETURN FALSE
   END IF

   IF NOT pol1363_atu_saldos() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol1363_reserva()#
#-------------------------#

   DECLARE cq_reserva CURSOR FOR
    SELECT num_lote, 
           qtd_reser
      FROM lote_reser_970
     WHERE num_pedido = m_num_pedido
       AND num_sequencia = m_num_sequencia
   
   FOREACH cq_reserva 
      INTO m_num_lote, m_qtd_lote
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_reserva')
         RETURN FALSE
      END IF
      
      IF NOT pol1363_chec_estoq() THEN
         RETURN FALSE
      END IF

      IF NOT pol1363_ins_reserva() THEN
         RETURN FALSE
      END IF
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1363_chec_estoq()#
#----------------------------#

   DEFINE l_msg        CHAR(300)
   
   SELECT cod_local_estoq
     INTO m_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item:local')
      RETURN FALSE
   END IF
   
   SELECT * 
     INTO mr_lote_ender.*
     FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item
      AND cod_local = m_local_estoq
      AND ies_situa_qtd = 'L'
      AND qtd_saldo > 0
      AND ((num_lote = m_num_lote AND m_ies_ctr_lote = 'S') OR
           (num_lote IS NULL AND m_ies_ctr_lote = 'N'))

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_lote_ender')
      RETURN FALSE
   END IF
      
   IF NOT pol1363_le_reservas() THEN
      RETURN FALSE
   END IF

   LET mr_lote_ender.qtd_saldo = 
       mr_lote_ender.qtd_saldo - m_qtd_reservada
    
   IF mr_lote_ender.qtd_saldo < m_qtd_lote THEN
      LET l_msg = 
          'Tabela: estoque_lote_ender \n',
          'Empresa ',p_cod_empresa,'\n',
          'Pedido ',m_num_pedido,'\n',
          'Item ',m_cod_item,'\n',
          'Lote ',m_num_lote,'\n',
          'Local ',m_local_estoq,'\n',
          'Não há mais saldo sufuciente.'
      CALL log0030_mensagem(l_msg,'info')
      RETURN FALSE
   END IF 
                  
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1363_le_reservas()#
#-----------------------------#     

   SELECT SUM(qtd_reservada)
     INTO m_qtd_reservada
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = m_cod_item
      AND cod_local   = m_local_estoq
      AND qtd_reservada > 0
      AND ((num_lote = m_num_lote AND m_ies_ctr_lote = 'S') OR
           (num_lote IS NULL AND m_ies_ctr_lote = 'N'))
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_loc_reser')
      RETURN FALSE
   END IF
      
   IF m_qtd_reservada IS NULL THEN
      LET m_qtd_reservada = 0
   END IF

   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1363_ins_reserva()#
#-----------------------------#
   
   DEFINE l_est_loc     RECORD LIKE est_loc_reser_end.*,
          l_estoque_loc RECORD LIKE estoque_loc_reser.*
   
   DEFINE l_num_reserva  INTEGER
      
   LET l_estoque_loc.num_reserva = 0

   LET l_estoque_loc.cod_empresa     = mr_lote_ender.cod_empresa      
   LET l_estoque_loc.cod_item        = mr_lote_ender.cod_item         
   LET l_estoque_loc.cod_local       = mr_lote_ender.cod_local        
   LET l_estoque_loc.qtd_reservada   = m_qtd_lote                 
   LET l_estoque_loc.num_lote        = mr_lote_ender.num_lote         
   LET l_estoque_loc.ies_origem      = 'V'                           
   LET l_estoque_loc.num_docum       = m_num_om                     
   LET l_estoque_loc.num_referencia  = NULL                          
   LET l_estoque_loc.ies_situacao    = 'N'                          
   LET l_estoque_loc.dat_prev_baixa  = NULL                         
   LET l_estoque_loc.num_conta_deb   = NULL                          
   LET l_estoque_loc.cod_uni_funcio  = NULL                          
   LET l_estoque_loc.nom_solicitante = NULL                          
   LET l_estoque_loc.dat_solicitacao = m_dat_atu                     
   LET l_estoque_loc.nom_aprovante   = NULL                          
   LET l_estoque_loc.dat_aprovacao   = NULL                          
   LET l_estoque_loc.qtd_atendida    = 0                             
   LET l_estoque_loc.dat_ult_atualiz = NULL                          
   
   IF g_tipo_sgbd = 'MSV' THEN
         
      INSERT INTO estoque_loc_reser(
      cod_empresa,    
      cod_item,                   
      cod_local,                  
      qtd_reservada,              
      num_lote,                   
      ies_origem,                 
      num_docum,                  
      num_referencia,             
      ies_situacao,               
      dat_prev_baixa,             
      num_conta_deb,              
      cod_uni_funcio,             
      nom_solicitante,            
      dat_solicitacao,            
      nom_aprovante,              
      dat_aprovacao,              
      qtd_atendida,               
      dat_ult_atualiz)            
      VALUES(l_estoque_loc.cod_empresa,                     
          l_estoque_loc.cod_item,             
          l_estoque_loc.cod_local,            
          l_estoque_loc.qtd_reservada,                
          l_estoque_loc.num_lote,             
          l_estoque_loc.ies_origem,                   
          l_estoque_loc.num_docum,                        
          l_estoque_loc.num_referencia,               
          l_estoque_loc.ies_situacao,                 
          l_estoque_loc.dat_prev_baixa,               
          l_estoque_loc.num_conta_deb,                
          l_estoque_loc.cod_uni_funcio,               
          l_estoque_loc.nom_solicitante,              
          l_estoque_loc.dat_solicitacao,           
          l_estoque_loc.nom_aprovante,                
          l_estoque_loc.dat_aprovacao,                
          l_estoque_loc.qtd_atendida,                 
          l_estoque_loc.dat_ult_atualiz)              
   ELSE
      INSERT INTO estoque_loc_reser
       VALUES(l_estoque_loc.*)
   END IF   
                                      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','estoque_loc_reser')
      RETURN FALSE
   END IF

   LET l_num_reserva = SQLCA.SQLERRD[2]
     
   LET l_est_loc.cod_empresa     = mr_lote_ender.cod_empresa     
   LET l_est_loc.num_reserva     = l_num_reserva        
   LET l_est_loc.endereco        = mr_lote_ender.endereco        
   LET l_est_loc.num_volume      = mr_lote_ender.num_volume      
   LET l_est_loc.cod_grade_1     = mr_lote_ender.cod_grade_1     
   LET l_est_loc.cod_grade_2     = mr_lote_ender.cod_grade_2     
   LET l_est_loc.cod_grade_3     = mr_lote_ender.cod_grade_3     
   LET l_est_loc.cod_grade_4     = mr_lote_ender.cod_grade_4     
   LET l_est_loc.cod_grade_5     = mr_lote_ender.cod_grade_5     
   LET l_est_loc.dat_hor_producao= mr_lote_ender.dat_hor_producao
   LET l_est_loc.num_ped_ven     = mr_lote_ender.num_ped_ven     
   LET l_est_loc.num_seq_ped_ven = mr_lote_ender.num_seq_ped_ven 
   LET l_est_loc.dat_hor_validade= mr_lote_ender.dat_hor_validade
   LET l_est_loc.num_peca        = mr_lote_ender.num_peca        
   LET l_est_loc.num_serie       = mr_lote_ender.num_serie       
   LET l_est_loc.comprimento     = mr_lote_ender.comprimento     
   LET l_est_loc.largura         = mr_lote_ender.largura         
   LET l_est_loc.altura          = mr_lote_ender.altura          
   LET l_est_loc.diametro        = mr_lote_ender.diametro        
   LET l_est_loc.dat_hor_reserv_1= mr_lote_ender.dat_hor_reserv_1
   LET l_est_loc.dat_hor_reserv_2= mr_lote_ender.dat_hor_reserv_2
   LET l_est_loc.dat_hor_reserv_3= mr_lote_ender.dat_hor_reserv_3
   LET l_est_loc.qtd_reserv_1    = mr_lote_ender.qtd_reserv_1    
   LET l_est_loc.qtd_reserv_2    = mr_lote_ender.qtd_reserv_2    
   LET l_est_loc.qtd_reserv_3    = mr_lote_ender.qtd_reserv_3   
   LET l_est_loc.num_reserv_1    = mr_lote_ender.num_reserv_1   
   LET l_est_loc.num_reserv_2    = mr_lote_ender.num_reserv_2   
   LET l_est_loc.num_reserv_3    = mr_lote_ender.num_reserv_3   
   LET l_est_loc.tex_reservado   = mr_lote_ender.tex_reservado  
   LET l_est_loc.identif_estoque = mr_lote_ender.identif_estoque
   LET l_est_loc.deposit         = mr_lote_ender.deposit        
   
   INSERT INTO est_loc_reser_end(
      cod_empresa,     
      num_reserva,     
      endereco,        
      num_volume,      
      cod_grade_1,     
      cod_grade_2,     
      cod_grade_3,     
      cod_grade_4,     
      cod_grade_5,     
      dat_hor_producao,
      num_ped_ven,     
      num_seq_ped_ven, 
      dat_hor_validade,
      num_peca,        
      num_serie,       
      comprimento,     
      largura,         
      altura,          
      diametro,        
      dat_hor_reserv_1,
      dat_hor_reserv_2,
      dat_hor_reserv_3,
      qtd_reserv_1,    
      qtd_reserv_2,    
      qtd_reserv_3,    
      num_reserv_1,    
      num_reserv_2,    
      num_reserv_3,    
      tex_reservado,   
      identif_estoque, 
      deposit)         
   VALUES(l_est_loc.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','est_loc_reser_end')
      RETURN FALSE
   END IF

   INSERT INTO ordem_montag_grade(
      cod_empresa,   
      num_om,        
      num_pedido,    
      num_sequencia, 
      cod_item,      
      qtd_reservada, 
      num_reserva,   
      cod_grade_1,   
      cod_grade_2,   
      cod_grade_3,   
      cod_grade_4,   
      cod_grade_5,   
      cod_composicao)
      VALUES(p_cod_empresa,
         m_num_om,                                         
         m_num_pedido,                                  
         m_num_sequencia,                     
         m_cod_item,                          
         m_qtd_lote,                                
         l_num_reserva,                                 
         mr_lote_ender.cod_grade_1,              
         mr_lote_ender.cod_grade_2,              
         mr_lote_ender.cod_grade_3,              
         mr_lote_ender.cod_grade_4,              
         mr_lote_ender.cod_grade_5,              
         NULL)                                          

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ordem_montag_grade')
      RETURN FALSE
   END IF

   INSERT INTO ldi_om_grade_compl(
      empresa,         
      ord_montag,      
      pedido,          
      sequencia_pedido,
      reserva,         
      eh_bonific)      
      VALUES(p_cod_empresa,
             m_num_om,
             m_num_pedido,
             m_num_sequencia,
             l_num_reserva,
             "N")
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ldi_om_grade_compl')
      RETURN FALSE
   END IF

   IF NOT pol1363_ins_area_linha(l_num_reserva) THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------------#
FUNCTION pol1363_ins_area_linha(l_num_reserva)#
#---------------------------------------------#
      
   DEFINE l_cod_lin_prod  DECIMAL(2,0),
          l_cod_lin_recei DECIMAL(2,0),
          l_cod_seg_merc  DECIMAL(2,0),
          l_cod_cla_uso   DECIMAL(2,0),
          l_num_reserva   INTEGER
   
   SELECT cod_lin_prod,
          cod_lin_recei,
          cod_seg_merc,
          cod_cla_uso,
          pes_unit
     INTO l_cod_lin_prod, 
          l_cod_lin_recei,
          l_cod_seg_merc, 
          l_cod_cla_uso,
          m_peso_unit
     FROM item
    WHERE cod_empresa = mr_lote_ender.cod_empresa
      AND cod_item = mr_lote_ender.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ITEM:AEN')
      RETURN FALSE
   END IF                

   INSERT INTO sup_resv_lote_est(
      empresa,           
      num_trans_resv_est,
      num_trans_lote_est,
      qtd_reservada,     
      qtd_atendida)
   VALUES(p_cod_empresa, l_num_reserva,
          mr_lote_ender.num_transac, m_qtd_lote, 0)
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','sup_resv_lote_est')
      RETURN FALSE
   END IF

   INSERT INTO est_reser_area_lin(
      cod_empresa,     
      num_reserva,     
      cod_area_negocio,  
      cod_lin_negocio, 
      cod_seg_merc,    
      cod_cla_uso)
   VALUES(p_cod_empresa,  l_num_reserva,
          l_cod_lin_prod, l_cod_lin_recei,
          l_cod_seg_merc, l_cod_cla_uso)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','est_reser_area_lin')
      RETURN FALSE
   END IF

   INSERT INTO sup_par_resv_est(
      empresa, 
      reserva, 
      parametro, 
      des_parametro)
   VALUES(p_cod_empresa,  l_num_reserva,
          'efetiva_parcial',                                        
          'Reserva de vendas que permite efetivação parcial')

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','sup_par_resv_est:1')
      RETURN FALSE
   END IF

   INSERT INTO sup_par_resv_est(
      empresa, 
      reserva, 
      parametro, 
      des_parametro,
      parametro_ind)
   VALUES(p_cod_empresa,  l_num_reserva,
          'sit_est_reservada',                        
          'Situação do estoque que está sendo reservado.','L')
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','sup_par_resv_est:2')
      RETURN FALSE
   END IF

   
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1363_embalagem()#
#---------------------------#
   
   DEFINE lr_embal    RECORD LIKE ordem_montag_embal.*
   
   LET lr_embal.cod_empresa     =  p_cod_empresa
   LET lr_embal.num_om          =  m_num_om
   LET lr_embal.num_sequencia   =  m_num_sequencia
   LET lr_embal.cod_item        =  m_cod_item
   LET lr_embal.cod_embal_int   =  NULL
   LET lr_embal.qtd_embal_int   =  NULL
   LET lr_embal.cod_embal_ext   =  NULL
   LET lr_embal.qtd_embal_ext   =  NULL
   LET lr_embal.ies_lotacao     =  'T'
   LET lr_embal.num_embal_inicio=  0
   LET lr_embal.num_embal_final =  0
   LET lr_embal.qtd_pecas       =  0

   INSERT INTO ordem_montag_embal
      VALUES(lr_embal.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ordem_montag_embal')
      RETURN FALSE
   END IF          

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1363_om_item()#
#-------------------------#

   DEFINE l_om_item RECORD LIKE ordem_montag_item.*
      
   LET m_tot_volume = m_qtd_faturar
   
   LET l_om_item.cod_empresa = p_cod_empresa    
   LET l_om_item.num_om = m_num_om
   LET l_om_item.num_pedido = m_num_pedido
   LET l_om_item.num_sequencia = m_num_sequencia  
   LET l_om_item.cod_item = m_cod_item       
   LET l_om_item.qtd_volume_item = m_tot_volume
   LET l_om_item.qtd_reservada = m_qtd_faturar
   LET l_om_item.ies_bonificacao = 'N'
   LET l_om_item.pes_total_item = m_qtd_faturar * m_peso_unit
   
   INSERT INTO ordem_montag_item(
      cod_empresa,    
      num_om,         
      num_pedido,     
      num_sequencia,  
      cod_item,       
      qtd_volume_item,
      qtd_reservada,  
      ies_bonificacao,
      pes_total_item) VALUES(l_om_item.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ordem_montag_item')
      RETURN FALSE
   END IF          
      
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1363_atu_saldos()#
#----------------------------#

   UPDATE ped_itens
      SET qtd_pecas_romaneio = qtd_pecas_romaneio + m_qtd_faturar
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido
      AND num_sequencia = m_num_sequencia
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ped_itens')
      RETURN FALSE
   END IF

   UPDATE estoque
      SET qtd_reservada = qtd_reservada + m_qtd_faturar
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','estoque')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1363_ins_om_mest()#
#-----------------------------#
   
   IF mr_transp.cod_transpor IS NULL THEN
      LET mr_transp.cod_transpor = '0'
   END IF
   
   SELECT SUM(qtd_volume_item)
     INTO m_qtd_volume
     FROM ordem_montag_item
    WHERE cod_empresa = p_cod_empresa
      AND num_om = m_num_om

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordem_montag_item:SUM(qtd_volume_item)')
      RETURN FALSE
   END IF
   
   IF m_qtd_volume IS NULL THEN
      LET m_qtd_volume = 0
   END IF

   SELECT cod_tip_carteira          
     INTO m_cod_tip_carteira
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','pedidos:2')
      RETURN FALSE
   END IF
   
   INSERT INTO ordem_montag_mest(
      cod_empresa,   
      num_om,        
      num_lote_om,   
      ies_sit_om,    
      cod_transpor,  
      qtd_volume_om, 
      dat_emis)
   VALUES(p_cod_empresa,
          m_num_om,
          m_lote_om,
          'N',
          mr_transp.cod_transpor,
          m_qtd_volume,
          m_dat_atu)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ordem_montag_mest')
      RETURN FALSE
   END IF

   INSERT INTO ordem_montag_lote (
      cod_empresa,       
      num_lote_om,       
      ies_sit_lote,      
      cod_transpor,      
      dat_emis,          
      cod_entrega,       
      cod_tip_carteira,  
      num_placa,         
      val_frete_lote,    
      cod_consig,        
      val_frete_lote_con)
   VALUES(p_cod_empresa,
          m_lote_om,
          'N',
          mr_transp.cod_transpor,
          m_dat_atu,
          1,
          m_cod_tip_carteira,
          mr_transp.num_placa,0,0,0)
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ordem_montag_lote')
      RETURN FALSE
   END IF
      
   INSERT INTO om_list (                     
         cod_empresa,                              
         num_om,                                   
         num_pedido,                               
         dat_emis,                                 
         nom_usuario)                              
      VALUES(p_cod_empresa,                        
             m_num_om,                             
             m_num_pedido,                         
             m_dat_atu,                         
             p_user)                               
                                                   
   IF STATUS <> 0 THEN                          
      CALL log003_err_sql('INSERT','om_list')   
      RETURN FALSE                              
   END IF                                                   
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1363_ins_solic_fatura()#
#----------------------------------#

   DEFINE l_cod_pais         LIKE uni_feder.cod_pais,
          l_mercado          LIKE fat_solic_fatura.mercado,         
          l_modo_embarque    LIKE fat_solic_fatura.modo_embarque,   
          l_local_embarque   LIKE fat_solic_fatura.local_embarque,  
          l_cidade_embarque  LIKE fat_solic_fatura.cidade_embarque, 
          l_dat_hor_embarque LIKE fat_solic_fatura.dat_hor_embarque,
          l_volume           LIKE fat_solic_fatura.primeiro_volume,
          l_volume_cubico    LIKE fat_solic_fatura.volume_cubico,
          l_peso_om_item     LIKE fat_solic_fatura.peso_liquido,
          l_local_despacho   INTEGER,
          l_cod_uni_feder    CHAR(02),
          l_num_pedido       INTEGER,
          l_lote_om          INTEGER,
          l_val_frete        DECIMAL(12,2),
          l_val_seguro       DECIMAL(12,2)
          
   LET l_mercado = ' '
   LET l_modo_embarque = ' '
   LET l_local_embarque =  ' '
   LET l_cidade_embarque = ' '
   LET l_dat_hor_embarque = ' '
   
   SELECT a.cod_uni_feder
     INTO l_cod_uni_feder
     FROM cidades a,
          clientes b
    WHERE b.cod_cliente = mr_cabec.cod_cliente
      AND b.cod_cidade  = a.cod_cidade
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','cidades/clientes')
      RETURN FALSE
   END IF
      
   SELECT cod_pais
     INTO l_cod_pais
     FROM uni_feder
    WHERE cod_uni_feder = l_cod_uni_feder
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','uni_feder')
      LET l_cod_pais = '001'
   END IF

   IF l_cod_pais = '001' THEN
      LET m_num_pedido = NULL
   END IF
       
   IF l_cod_pais <> '001' THEN
      
      SELECT parametro_texto
        INTO l_cidade_embarque
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = M_num_pedido                                  
         AND ped_info_compl.campo   = 'CIDADE_EMBARQUE'                     

      SELECT parametro_dat
        INTO l_dat_hor_embarque
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = m_num_pedido                                  
         AND ped_info_compl.campo   = 'DAT_HOR_EMBARQUE'                     

      SELECT parametro_texto
        INTO l_local_embarque
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = m_num_pedido                                  
         AND ped_info_compl.campo   = 'LOCAL_EMBARQUE'                     

      SELECT parametro_texto
        INTO l_mercado
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = m_num_pedido                                  
         AND ped_info_compl.campo   = 'MERCADO'                     


      SELECT parametro_texto
        INTO l_modo_embarque
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = m_num_pedido                                  
         AND ped_info_compl.campo   = 'MODO_EMBARQUE'                     

      SELECT parametro_val
        INTO l_local_despacho
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = m_num_pedido                                  
         AND ped_info_compl.campo   = 'LOCAL_DESPACHO'                     

   END IF
   
   SELECT SUM(pes_total_item)
     INTO l_peso_om_item
     FROM ordem_montag_item
    WHERE cod_empresa = p_cod_empresa
      AND num_om = m_num_om     

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordem_montag_item:peso')
      RETURN FALSE
   END IF
   
   IF l_peso_om_item IS NULL THEN
      LET l_peso_om_item = 0
   END IF
   
   LET m_seq_fatura = m_seq_fatura + 1
   LET m_ctr_fatura = m_ctr_fatura + 1
   LET l_val_frete = 0
   LET l_val_seguro = 0
   LET l_volume_cubico = 0
   
   IF m_ies_solic = 'L' THEN
      LET m_num_om = 0
   ELSE
      LET m_lote_om = 0
   END IF
   
   INSERT INTO fat_solic_fatura (
      trans_solic_fatura,
      ord_montag,        
      lote_ord_montag,   
      seq_solic_fatura,  
      controle,          
      texto_1,           
      texto_2,           
      texto_3,           
      via_transporte,    
      transportadora,    
      placa_veiculo,     
      estado_placa_veic, 
      val_frete,         
      val_seguro,        
      peso_liquido,      
      peso_bruto,        
      primeiro_volume,   
      volume_cubico,     
      mercado,           
      local_embarque,    
      modo_embarque,
      dat_hor_embarque,
      cidade_embarque,
      local_despacho)
    VALUES(m_num_transac,
           m_num_om,
           m_lote_om,
           m_seq_fatura,
           m_ctr_fatura,
           mr_transp.cod_texto_1,
           mr_transp.cod_texto_2,
           mr_transp.cod_texto_3,
           mr_transp.cod_via,
           mr_transp.cod_transpor,
           mr_transp.num_placa,
           mr_transp.uf_veiculo,                    
           l_val_frete,
           l_val_seguro,           
           l_peso_om_item,
           l_peso_om_item,           
           m_qtd_volume,                              
           l_volume_cubico,           
           l_mercado,           
           l_local_embarque,
           l_modo_embarque,
           l_dat_hor_embarque,
           l_cidade_embarque,
           l_local_despacho)   
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql("INCLUSAO", "fat_solic_fatura")
      RETURN FALSE
   END IF

   DELETE FROM fat_exp_nf
    WHERE empresa = p_cod_empresa
      AND trans_nota_fiscal = m_num_transac
   
   INSERT INTO fat_exp_nf (
    empresa,
    trans_nota_fiscal, 
    modo_embarq,     
    local_embarq,    
    dat_hor_embarq,
    mercado,     
    cidade_embarque,
    local_despacho)
   VALUES (p_cod_empresa,
           m_num_transac,
           l_modo_embarque,    
           l_local_embarque,   
           l_dat_hor_embarque, 
           l_mercado,         
           l_cidade_embarque,
           l_local_despacho)  
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql("INCLUSAO", "fat_exp_nf")
      RETURN FALSE
   END IF

   INSERT INTO fat_s_nf_eletr(
    trans_solic_fatura, 
    ord_montag, 
    lote_ord_montag, 
    modalidade_frete_nfe) 
  VALUES(m_num_transac,
         m_num_om,        
         m_lote_om, 
         m_ies_modalidade)  
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','fat_s_nf_eletr')
      RETURN FALSE
	 END IF
    
   {IF NOT pol1363_isere_embalagem(l_lote_om) THEN
      RETURN FALSE
   END IF}
         
   RETURN TRUE

END FUNCTION

#------------------------------------------#
FUNCTION pol1363_isere_embalagem(l_lote_om)#
#------------------------------------------#
   
   DEFINE l_lote_om      LIKE fat_solic_fatura.lote_ord_montag,
          l_cod_embal     LIKE fat_solic_embal.embalagem,
          l_qtd_embal     LIKE fat_solic_embal.qtd_embalagem 
          
   DECLARE cq_embal CURSOR FOR                                                  
    SELECT cod_embal_int,                                                    
           qtd_embal_int                                                     
      FROM ordem_montag_embal                                                
     WHERE cod_empresa = p_cod_empresa                                       
       AND num_om = m_num_om  
       AND cod_embal_int IS NOT NULL                                             
                                                                             
   FOREACH cq_embal INTO l_cod_embal, l_qtd_embal                            
                                                                          
      IF STATUS <> 0 THEN                                                    
         CALL log003_err_sql('FOREACH','ordem_montag_embal:cq_embal')        
         RETURN FALSE                                                        
      END IF                                                                 
                                                                             
      INSERT INTO fat_solic_embal(                                           
         trans_solic_fatura,                                                 
         ord_montag,			                                                   
         lote_ord_montag,		                                                 
         embalagem,			                                                     
         qtd_embalagem)                                                      
      VALUES(m_num_transac,                                                  
             m_num_om,                                                       
             m_lote_om,                                                     
             l_cod_embal,                                                    
             l_qtd_embal)                                                    
                                                                          
      IF STATUS <> 0 THEN                                                    
         CALL log003_err_sql('Inserindo','fat_solic_embal')                  
         RETURN FALSE                                                        
      END IF                                                                 
                                                                             
   END FOREACH                                                                        
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1363_cancel_solict()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')

   IF mr_cabec.num_solicit IS NULL THEN
      LET m_msg = 'Informe um pedido com solicitação pronta previamente'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE   
   END IF
   
   LET m_msg = 'Confirma o cancelamento da \n Solicitação de faturamento ?'
   
   IF NOT LOG_question(m_msg) THEN
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_begin()
   
   LET p_status = LOG_progresspopup_start(
      "Cancelando solicit...","pol1363_proc_cancel","PROCESS")
   
   IF NOT p_status THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   ELSE
      CALL LOG_transaction_commit()
   END IF
   
   LET m_msg = 'Cancelamento efetuado com sucesso.'
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
   CALL pol1363_limpa_campos()
   LET m_ies_cons = FALSE
      
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1363_proc_cancel()#
#-----------------------------#
   
   DEFINE l_progres       SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",3)
   
   DECLARE cq_om_fat CURSOR FOR
    SELECT ord_montag
      FROM fat_solic_fatura
     WHERE trans_solic_fatura = m_num_transac
   
   FOREACH cq_om_fat INTO m_num_om
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_om_fat')
         RETURN FALSE
      END IF
       
      LET l_progres = LOG_progresspopup_increment("PROCESS")

      IF NOT pol1363_exec_cancel() THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   IF NOT pol1363_exc_solicit() THEN
      RETURN FALSE
   END IF
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
      
   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol1363_exec_cancel()#
#-----------------------------#

   DEFINE l_num_reserva   LIKE ordem_montag_grade.num_reserva,
          l_num_pedido    LIKE ped_itens.num_pedido,
          l_num_sequencia LIKE ped_itens.num_sequencia,
          l_qtd_reservada LIKE ordem_montag_item.qtd_reservada,
          l_cod_item      LIKE ordem_montag_item.cod_item,
          l_num_lote_om   LIKE ordem_montag_mest.num_lote_om,
          l_texto         CHAR(40),
          l_hor_atu       CHAR(08),
          l_dat_atu       DATE


   DECLARE cq_ped CURSOR FOR 
    SELECT num_pedido,
           num_sequencia,
           cod_item,
           qtd_reservada
      FROM ordem_montag_item
     WHERE cod_empresa = p_cod_empresa
       AND num_om      = m_num_om

   FOREACH cq_ped INTO 
           l_num_pedido, 
           l_num_sequencia, 
           l_cod_item,
           l_qtd_reservada

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','ordem_montag_item:cq_ped')
         RETURN FALSE
      END IF
   
      UPDATE ped_itens
         SET qtd_pecas_romaneio = qtd_pecas_romaneio - l_qtd_reservada
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = l_num_pedido
         AND num_sequencia = l_num_sequencia

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Atualizando','ped_itens')
         RETURN FALSE
      END IF
      
      UPDATE estoque
         SET qtd_reservada = qtd_reservada - l_qtd_reservada
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = l_cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Atualizando','estoque')
         RETURN FALSE
      END IF
         
   END FOREACH

   DELETE FROM ordem_montag_item
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_om
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_item')
      RETURN FALSE
   END IF

   DELETE FROM ordem_montag_embal
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_om
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_embal')
      RETURN FALSE
   END IF

   DECLARE cq_reser CURSOR FOR
    SELECT num_reserva
      FROM ordem_montag_grade
     WHERE cod_empresa = p_cod_empresa
       AND num_om      = m_num_om
      
   FOREACH cq_reser INTO l_num_reserva

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordem_montag_grade:cq_reser')
         RETURN FALSE
      END IF
  
      DELETE estoque_loc_reser
       WHERE cod_empresa = p_cod_empresa
         AND num_reserva = l_num_reserva
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','estoque_loc_reser')
         RETURN FALSE
      END IF

      DELETE est_loc_reser_end
       WHERE cod_empresa = p_cod_empresa
         AND num_reserva = l_num_reserva
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','est_loc_reser_end')
         RETURN FALSE
      END IF
  
   END FOREACH
  
   DELETE FROM ordem_montag_grade
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_om
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_grade')
      RETURN FALSE
   END IF

   SELECT num_lote_om
     INTO l_num_lote_om
     FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_om

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ordem_montag_mest')
      RETURN FALSE
   END IF
     
   DELETE FROM ordem_montag_lote
    WHERE cod_empresa = p_cod_empresa
      AND num_lote_om = l_num_lote_om
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_lote')
      RETURN FALSE
   END IF

   DELETE FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_om
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_mest')
      RETURN FALSE
   END IF

   DELETE FROM om_list
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','om_list')
      RETURN FALSE
   END IF
    
   LET l_hor_atu = CURRENT HOUR TO SECOND
   LET l_dat_atu = TODAY
   
   LET l_texto = "CANCELAMENTO DA OM Nr.", m_num_om USING '&&&&&&&&&&'
   
   INSERT INTO audit_vdp (
      cod_empresa,
      num_pedido,
      tipo_informacao,
      tipo_movto,
      texto,
      num_programa,
      data,
      hora,
      usuario)
    VALUES(p_cod_empresa,
           0,
           'C',
           'C', 
           l_texto,
           '.pol1363',
           l_dat_atu,
           l_hor_atu,
           p_user)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','audit_vdp')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1363_exc_solicit()#
#-----------------------------#

   DEFINE l_trans_solic_fatura 	INTEGER
   
   LET l_trans_solic_fatura = m_num_transac
            
   DELETE FROM fat_solic_fatura 
		WHERE trans_solic_fatura = l_trans_solic_fatura 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','fat_solic_fatura')
      RETURN FALSE
   END IF
	
	 DELETE FROM fat_solic_embal	 
		WHERE trans_solic_fatura = l_trans_solic_fatura 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','fat_solic_embal')
      RETURN FALSE
   END IF

   DELETE FROM fat_exp_nf
    WHERE empresa = p_cod_empresa
      AND trans_nota_fiscal = l_trans_solic_fatura

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','fat_exp_nf')
      RETURN FALSE
   END IF
   
   DELETE FROM fat_s_nf_eletr
    WHERE trans_solic_fatura = l_trans_solic_fatura

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','fat_s_nf_eletr')
      RETURN FALSE
   END IF

   DELETE FROM fat_solic_mestre
    WHERE empresa = p_cod_empresa
      AND trans_solic_fatura = l_trans_solic_fatura

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','fat_solic_mestre')
      RETURN FALSE
   END IF

END FUNCTION

#---------------FIM DO PROGRAMA------------------#
