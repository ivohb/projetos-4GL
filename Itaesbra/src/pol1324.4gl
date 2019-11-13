#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1324                                                 #
# OBJETIVO: EXPEDIÇÃO DE PEDIDOS                                    #
# AUTOR...: IVO                                                     #
# DATA....: 30/05/17                                                #
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

DEFINE m_den_empresa     LIKE empresa.den_empresa,
       m_cod_empresa     LIKE empresa.cod_empresa,
       m_qtd_volume_int  LIKE ordem_montag_item.qtd_volume_item,
       m_qtd_volume_ext  LIKE ordem_montag_item.qtd_volume_item,
       m_tot_volume      LIKE ordem_montag_item.qtd_volume_item,
       m_nom_cliente     LIKE clientes.nom_cliente,
       m_par_vdp_txt     LIKE par_vdp.par_vdp_txt

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_browse          VARCHAR(10),
       m_empresa         VARCHAR(10),
       m_per_ini         VARCHAR(10),
       m_per_fim         VARCHAR(10),
       m_item            VARCHAR(10),
       m_pedido          VARCHAR(10),
       m_lpedido         VARCHAR(10),
       m_zpedido         VARCHAR(10),
       m_cliente         VARCHAR(10),
       m_lcliente        VARCHAR(10),
       m_zcliente        VARCHAR(10),
       m_ztransp         VARCHAR(10),
       m_produto         VARCHAR(10),
       m_lproduto        VARCHAR(10),
       m_zproduto        VARCHAR(10),
       m_panel           VARCHAR(10),
       m_brz_mont        VARCHAR(10),
       m_faturar         VARCHAR(10),
       m_embal           VARCHAR(10),
       m_transpor        VARCHAR(10),
       m_qtd_sel         VARCHAR(10),
       m_cod_imp         VARCHAR(10),
       m_lupa_emp        VARCHAR(10),
       m_zoom_emp        VARCHAR(10),
       m_lupa_om         VARCHAR(10),
       m_zoom_om         VARCHAR(10),
       m_desc_cli        VARCHAR(10),
       m_etiqueta        VARCHAR(10),
       m_re_imp          VARCHAR(10),
       m_rel_cli         VARCHAR(10)

DEFINE m_ies_cons        SMALLINT,
       m_houve_erro      SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ind             INTEGER,
       m_dat_atu         DATE,
       m_qtd_linha       INTEGER,
       m_index           INTEGER,
       m_carregando      SMALLINT,
       m_query           CHAR(3000),
       m_linha           INTEGER,
       m_linhaa          INTEGER,
       m_ies_ctr_estoque CHAR(01),
       m_local_estoq     CHAR(10),
       m_ies_ctr_lote    CHAR(01),
       m_num_lote        CHAR(15),
       m_qtd_saldo       DECIMAL(10,3),
       m_qtd_item        INTEGER,
       m_qtd_next        INTEGER,
       m_fat_parcial     SMALLINT,
       m_qtd_parcial     DECIMAL(10,3),
       m_num_om          INTEGER,
       m_lote_om         INTEGER,
       m_gerou_om        SMALLINT,
       m_bar_prog        INTEGER,
       m_num_carga       INTEGER,
       m_ies_imp         CHAR(01),
       m_ies_roma        CHAR(01),
       m_texto           CHAR(10),
       m_ies_sel         SMALLINT,
       m_sel_lote        SMALLINT,
       m_tot_sel         DECIMAL(6,0),
       m_saldo_lote      DECIMAL(10,3),
       m_lin_sel         INTEGER,
       m_sdo_sel         DECIMAL(10,3),
       m_qtd_lote        DECIMAL(10,3),
       m_qtd_reservada   DECIMAL(10,3),
       m_cod_transpor    CHAR(15),
       m_cod_oper_sai    CHAR(04),
       m_cod_oper_ent    CHAR(04),
       m_cod_oper_trans  CHAR(04),
       m_id_registro     INTEGER,
       m_qtd_estoque     DECIMAL(10,3),
       m_page_length     INTEGER,
       m_rastro          CHAR(18),
       m_par_info        CHAR(01),
       m_tem_lote        SMALLINT,
       m_usuario         CHAR(08),
       m_cod_transp      CHAR(02),
       m_cod_transp_auto CHAR(02),
       m_nom_transp      CHAR(36),
       m_classif         CHAR(01)

       
DEFINE mr_cabec          RECORD
       cod_empresa       CHAR(02),
       dat_ini           DATE,
       dat_fim           DATE,
       sel_item          INTEGER,
       num_pedido        DECIMAL(6,0),
       cod_cliente       CHAR(15),
       cod_item          CHAR(15)
END RECORD

DEFINE ma_itens           ARRAY[1000] OF RECORD
       ies_select         CHAR(01),
       cod_empresa        CHAR(02),
       cod_item           CHAR(15),
       item_cliente       CHAR(30),
       num_pedido         DECIMAL(6,0),
       cod_tip_venda      INTEGER,
       cod_status         CHAR(01),
       num_sequencia      DECIMAL(5,0),
       prz_entrega        DATE,
       qtd_pecas_solic    DECIMAL(6,0),
       qtd_pecas_atend    DECIMAL(6,0),
       qtd_pecas_cancel   DECIMAL(6,0),
       qtd_pecas_reserv   DECIMAL(6,0),
       qtd_pecas_romaneio DECIMAL(6,0),
       qtd_saldo          DECIMAL(6,0),
       qtd_estoque        DECIMAL(10,3),
       cod_cliente        CHAR(15),
       nom_cliente        CHAR(15),
       filler             CHAR(01)
END RECORD

DEFINE m_dlg_det         VARCHAR(10),
       m_bar_det         VARCHAR(10),
       m_brz_lote        VARCHAR(10),
       m_brz_fat         VARCHAR(10),
       m_brz_embal       VARCHAR(10),
       m_dlg_lote        VARCHAR(10),
       m_bar_lote        VARCHAR(10),
       m_dlg_om          VARCHAR(10),
       m_bar_om          VARCHAR(10),
       m_dlg_rel         VARCHAR(10),
       m_bar_rel         VARCHAR(10),
       m_copias          VARCHAR(10),
       m_rua             VARCHAR(10),
       m_vao             VARCHAR(10),
       m_obs             VARCHAR(10),
       m_cod_lote        VARCHAR(10),
       m_cod_produto     VARCHAR(10)
       

DEFINE ma_lotes          ARRAY[50] OF RECORD
       modificar         CHAR(01),
       cod_local         CHAR(10),
       num_lote          CHAR(15),
       ies_tipo          CHAR(01),
       qtd_saldo         DECIMAL(10,3),
       faturar           CHAR(01),
       filler            CHAR(01)
END RECORD

DEFINE ma_faturar        ARRAY[10] OF RECORD
       num_lote          CHAR(15),
       num_pedido        DECIMAL(6,0),
       num_sequencia     DECIMAL(5,0),
       qtd_faturar       DECIMAL(10,3),
       qtd_etiqueta      DECIMAL(4,0),
       excluir           CHAR(01),
       filler            CHAR(01)
END RECORD

DEFINE mr_embal          RECORD
       cod_tip_venda     CHAR(03),
       tipo              CHAR(20),
       qtd_padrao        DECIMAL(10,0),
       cod_embal         CHAR(03),
       den_embal         CHAR(36)
END RECORD

DEFINE mr_detalhe           RECORD
       linha                INTEGER,
       cod_empresa          CHAR(02),
       cod_item             CHAR(15),
       item_cliente         CHAR(30),
       num_pedido           DECIMAL(6,0),
       num_sequencia        DECIMAL(5,0),
       prz_entrega          CHAR(10),
       num_contrato         CHAR(30),
       cod_cliente          CHAR(15),
       nom_cliente          CHAR(15),
       cod_fabrica          CHAR(06),
       cod_doca             CHAR(06),
       hora                 CHAR(08),
       tipo_prg_honda       CHAR(06),
       slip_number_honda    CHAR(15),
       seppen_honda         CHAR(15),
       lote_prod_honda      CHAR(15),
       tbxcpi_honda         CHAR(15),  
       observacao_honda     CHAR(40),
       hora_entrega_honda   CHAR(08),
       manuseio             CHAR(15),
       estoquista           CHAR(15),
       xped                 CHAR(15),
       nitemped             CHAR(15),
       cod_unid_med         CHAR(03),
       qtd_pecas_solic      DECIMAL(10,3),
       qtd_pecas_atend      DECIMAL(10,3),
       qtd_pecas_cancel     DECIMAL(10,3),
       qtd_pecas_reserv     DECIMAL(10,3),
       qtd_pecas_romaneio   DECIMAL(10,3),
       qtd_saldo            DECIMAL(10,3),
       qtd_faturar          DECIMAL(10,3)
END RECORD

DEFINE mr_lote              RECORD
       num_lote             CHAR(15),
       qtd_saldo            DECIMAL(10,3)
END RECORD

DEFINE mr_om                RECORD
       num_om               INTEGER,
       cod_empresa          CHAR(02)
END RECORD

DEFINE ma_montagem          ARRAY[100] OF RECORD
       cod_empresa          CHAR(02),
       cod_cliente          CHAR(15),
       num_pedido           INTEGER,
       num_sequencia        INTEGER,
       cod_item             CHAR(15),
       num_lote             CHAR(15),
       cod_local            CHAR(10),
       qtd_faturar          DECIMAL(10,3),
       qtd_etiqueta         DECIMAL(4,0)
END RECORD

DEFINE mr_pcp               RECORD
       qtd_pcp              DECIMAL(10,3),
       qtd_faturar          DECIMAL(10,3),
       num_om               INTEGER,
       num_lote_om          INTEGER,
       qtd_etiqueta         DECIMAL(4,0),
       cap_embal            DECIMAL(8,0),
       cod_transpor         CHAR(15),
       nom_transpor         CHAR(36)
END RECORD

DEFINE m_num_seq            INTEGER,
       m_cod_item           CHAR(15),
       m_qtd_faturar        DECIMAL(10,3),
       m_num_pedido         INTEGER,
       m_cod_cliente        CHAR(15),
       m_qtd_etiqueta       INTEGER

DEFINE m_peso_unit          LIKE item.pes_unit,
       m_peso_item          LIKE ordem_montag_item.pes_total_item,
       m_cod_tip_carteira   LIKE pedidos.cod_tip_carteira,
       m_item_cliente       LIKE cliente_item.cod_item_cliente,
       m_den_item           LIKE item.den_item,
       m_peso_embal         LIKE item.pes_unit,
       m_cod_tip_venda      LIKE pedidos.cod_tip_venda,
       m_cod_embal          LIKE embal_itaesbra.cod_embal,
       m_qtd_embal          LIKE embal_itaesbra.qtd_padr_embal
       

DEFINE m_qtd_volume         INTEGER

DEFINE m_lote_ender         RECORD LIKE estoque_lote_ender.*

DEFINE mr_relat             RECORD
       cod_cliente          CHAR(15),        
       cod_item             CHAR(15),           
       den_item             CHAR(76),           
       peso_unit            DECIMAL(12,5),          
       peso_item            DECIMAL(12,5),          
       cod_embal            CHAR(03),          
       peso_embal           DECIMAL(12,5),         
       num_lote             CHAR(15),           
       qtd_lote             DECIMAL(10,3),           
       dat_user             CHAR(30),       
       peso_bruto           DECIMAL(12,5),
       qtd_etiqueta         INTEGER,
       num_seq              INTEGER  
END RECORD


   DEFINE mr_tela1           RECORD
         cod_empresa         LIKE empresa.cod_empresa,
         den_empresa         LIKE empresa.den_empresa,
         cod_cliente         LIKE clientes.cod_cliente,
         nom_cliente         LIKE clientes.nom_cliente,
         num_lote_om         LIKE ordem_montag_mest.num_lote_om,
         qtd_infor           LIKE estoque.qtd_reservada,
         qtd_dif             LIKE estoque.qtd_reservada,
         reimpressao         CHAR(01),
         num_om              INTEGER
   END RECORD

   DEFINE p_count            SMALLINT,
         p_seq               INTEGER,
         p_cod_embal_int     CHAR(05),  
         p_cod_embal_int_dp  CHAR(07),  
         p_qtd_embal_int     INTEGER,     
         p_cod_embal_ext     CHAR(05),          
         p_cod_embal_ext_dp  CHAR(07),          
         p_qtd_embal_ext     INTEGER,
         p_qtd_vol_int       INTEGER,
         p_qtd_vol_ext       INTEGER,
         l_qtd_vol           CHAR(10),
         p_resto             INTEGER,
         p_ies_lote          CHAR(01),
         p_num_seq           INTEGER


   DEFINE p_relat               RECORD
      cod_cliente               LIKE clientes.cod_cliente,  
      nom_cliente               LIKE clientes.nom_cliente,  
      num_lote_om               INTEGER,
      num_om                    LIKE ordem_montag_mest.num_om,
      num_pedido                LIKE pedidos.num_pedido,  
      num_sequencia             LIKE ordem_montag_item.num_sequencia,
      cod_item                  LIKE ordem_montag_item.cod_item,
      den_item                  LIKE item.den_item,
      qtd_reservada             LIKE ordem_montag_item.qtd_reservada,
      cod_transpor              LIKE ordem_montag_lote.cod_transpor,
      nom_transpor              LIKE transport.den_transpor,
      num_placa                 LIKE ordem_montag_lote.num_placa,
      cod_unid_med              LIKE item.cod_unid_med,
      cod_embal                 LIKE embal_itaesbra.cod_embal,
      qtd_padr_embal            LIKE embal_itaesbra.qtd_padr_embal,
      qtd_vol                   LIKE ordem_montag_item.num_om,
      cod_item_cliente          LIKE cliente_item.cod_item_cliente
   END RECORD

   DEFINE p_qtd_faturada        LIKE ordem_montag_item.qtd_reservada
   
   DEFINE mr_om_list            RECORD LIKE om_list.*


   DEFINE p_tela RECORD
      num_om        INTEGER,
      dat_inclusao  DATE,
      cod_nat_oper  INTEGER
   END RECORD

   DEFINE 
      m_erro                  CHAR(150),
      p_num_om                INTEGER,
      p_cod_cliente           CHAR(15),
      p_num_pedido            INTEGER,
      p_num_sequencia         INTEGER,
      p_cod_item              CHAR(15),
      p_cod_fornecedor        CHAR(15),
      p_qtd_saldo             DECIMAL(10,3),
      p_qtd_consumida         DECIMAL(10,3)                                                                        

   DEFINE p_ordem_montag_tran  RECORD LIKE ordem_montag_tran_970.*,
          p_estrut_item_indus  RECORD LIKE estrut_item_indus.*,
          p_ordem_montag_item  RECORD LIKE ordem_montag_item.*,
          p_item_de_terc       RECORD LIKE item_de_terc.*

   DEFINE p_ies_especie_nf     LIKE item_de_terc.ies_especie_nf,
          p_seq_tabulacao      LIKE sup_item_terc_end.seq_tabulacao,
          p_qtd_dev_ldi        LIKE ordem_montag_tran_970.qtd_devolvida,
          p_qtd_tot_devolvida  LIKE item_de_terc.qtd_tot_devolvida,
          p_pre_unit           LIKE ped_itens.pre_unit,
          p_qtd_neces          LIKE ordem_montag_tran_970.qtd_devolvida

DEFINE mr_ficha       RECORD
    id_registro       INTEGER,
    cod_empresa      	CHAR(2),
    cod_item         	CHAR(15),
    cod_item_cliente  CHAR(30),
    rua   			      CHAR(3),
    vao 			        CHAR(6),
    data              DATE,
    rastro            CHAR(15),   
    observacao    	  CHAR(34),
    num_seq          	DECIMAL(3,0),
    num_sub_seq      	DECIMAL(3,0),
    opprox           	CHAR(10),
    setatual         	CHAR(10),
    setprox         	CHAR(10),
    ies_impresso      CHAR(01),
    numero_copias  	  DECIMAL(3,0),
    quantidade        DECIMAL(10,3)
END RECORD
            
#-----------------#
FUNCTION pol1324()#
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
   
   LET p_versao = "POL1324-12.00.23  "
   CALL func002_versao_prg(p_versao)

   IF NOT pol1324_cria_tab_temp() THEN
      RETURN FALSE
   END IF
   
   LET m_par_info = 'P'
   
   CALL pol1324_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1324_menu()#
#----------------------#

    DEFINE l_menubar    VARCHAR(10),
           l_panel      VARCHAR(10),
           l_find       VARCHAR(10),
           l_pedido     VARCHAR(10),
           l_print      VARCHAR(10),
           l_oper       VARCHAR(10),
           l_relat      VARCHAR(10),
           l_lote       VARCHAR(10),
           l_titulo     CHAR(50)

    LET m_carregando = TRUE
    LET m_dat_atu = TODAY
    LET m_ies_cons = FALSE
    LET l_titulo = "MONTAGEM DE CARGA DE PRODUTOS "
    
    CALL pol1324_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)
        
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1324_find")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1324_find_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1324_find_cancel")

    LET l_print = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_print,"IMAGE","ETIQUETAS") 
    CALL _ADVPL_set_property(l_print,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_print,"TOOLTIP","Imprimir etiquetas")
    CALL _ADVPL_set_property(l_print,"EVENT","pol1324_imp_etiqueta")

    LET l_relat = _ADVPL_create_component(NULL,"LPRINTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_relat,"EVENT","pol1324_listar")
    CALL _ADVPL_set_property(l_relat,"TOOLTIP","Imprimir OMs")

    LET l_lote = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_lote,"IMAGE","REIMPRESSAO") 
    CALL _ADVPL_set_property(l_lote,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_lote,"TOOLTIP","Reimprimir lote")
    CALL _ADVPL_set_property(l_lote,"EVENT","pol1324_imp_lote")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1324_cria_campos(l_panel)
    CALL pol1324_grade_pedido(l_panel)
    CALL pol1324_ativa_desativa(FALSE)
    CALL pol1324_exibe_default()
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1324_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Filial:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_empresa = _ADVPL_create_component(NULL,"LCOMBOBOX",l_panel)
    CALL _ADVPL_set_property(m_empresa,"POSITION",70,10)
    CALL _ADVPL_set_property(m_empresa,"ADD_ITEM","01","Diadema")     
    CALL _ADVPL_set_property(m_empresa,"ADD_ITEM","10","São Carlos")     
    CALL _ADVPL_set_property(m_empresa,"ADD_ITEM","XX","Todas")     
    CALL _ADVPL_set_property(m_empresa,"VARIABLE",mr_cabec,"cod_empresa")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",190,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Período:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_per_ini = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel)
    CALL _ADVPL_set_property(m_per_ini,"POSITION",240,10)
    CALL _ADVPL_set_property(m_per_ini,"VARIABLE",mr_cabec,"dat_ini")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",360,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Até:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_per_fim = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel)
    CALL _ADVPL_set_property(m_per_fim,"POSITION",400,10)
    CALL _ADVPL_set_property(m_per_fim,"VARIABLE",mr_cabec,"dat_fim")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",520,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Itens:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_item = _ADVPL_create_component(NULL,"LRADIOGROUP",l_panel)
    CALL _ADVPL_set_property(m_item,"POSITION",560,5)
    CALL _ADVPL_set_property(m_item,"ADD_ITEM",1,"Com saldo")
    CALL _ADVPL_set_property(m_item,"ADD_ITEM",2,"Sem saldo")
    CALL _ADVPL_set_property(m_item,"ADD_ITEM",3,"Todos")
    CALL _ADVPL_set_property(m_item,"SELECT_ITEM",1)
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_cabec,"sel_item")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",660,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Pedido:")    

    LET m_pedido = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_pedido,"POSITION",710,10)     
    CALL _ADVPL_set_property(m_pedido,"VARIABLE",mr_cabec,"num_pedido")
    #CALL _ADVPL_set_property(m_pedido,"LENGTH",6,0)

    LET m_lpedido = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lpedido,"POSITION",770,10)     
    CALL _ADVPL_set_property(m_lpedido,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lpedido,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lpedido,"CLICK_EVENT","pol1324_zoom_pedido")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",815,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    

    LET m_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_cliente,"POSITION",865,10)     
    CALL _ADVPL_set_property(m_cliente,"VARIABLE",mr_cabec,"cod_cliente")
    CALL _ADVPL_set_property(m_cliente,"LENGTH",15,0)
    CALL _ADVPL_set_property(m_cliente,"PICTURE","@!")

    LET m_lcliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lcliente,"POSITION",1000,10)     
    CALL _ADVPL_set_property(m_lcliente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lcliente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lcliente,"CLICK_EVENT","pol1324_zoom_cliente")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1050,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Produto:")    

    LET m_produto = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_produto,"POSITION",1100,10)     
    CALL _ADVPL_set_property(m_produto,"VARIABLE",mr_cabec,"cod_item")
    CALL _ADVPL_set_property(m_produto,"LENGTH",15,0)
    CALL _ADVPL_set_property(m_produto,"PICTURE","@!")

    LET m_lproduto = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lproduto,"POSITION",1240,10)     
    CALL _ADVPL_set_property(m_lproduto,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lproduto,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lproduto,"CLICK_EVENT","pol1324_zoom_item")

END FUNCTION


#-----------------------------------------#
FUNCTION pol1324_grade_pedido(l_container)#
#-----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(l_panel,"WIDTH",900)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(m_browse,"BEFORE_ROW_EVENT","pol1324_before_linha")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CONFIRM_EX")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sel")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_select")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1324_checa_sel")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Filial")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    #CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_empresa")
    #CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","SELECAO_MANUAL")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cod item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    #CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",110)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    #CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","item_cliente")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Status")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",25)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_status")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","TV")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",25)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_tip_venda")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ###")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Seq")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_sequencia")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    #CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","prz_entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    #CALL _ADVPL_set_property(l_tabcolumn,"HEADER_CLICK_EVENT","pol1324_clasif_entrega")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd prog")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_pecas_solic")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd atend")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_pecas_atend")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd cancel")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_pecas_cancel")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Reservada")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_pecas_romaneio")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Estoque")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_estoque")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E #######")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    #CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",110)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    #CALL _ADVPL_set_property(l_tabcolumn,"HEADER_CLICK_EVENT","pol1324_clasif_cliente")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    #CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",110)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_cliente")

    {LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")}
    
    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CLEAR")

END FUNCTION

#-----------------------------#
FUNCTION pol1324_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_itens TO NULL

   DELETE FROM ped_item_sel_912
    WHERE usuario = p_user
        
END FUNCTION

#----------------------------------------#
FUNCTION pol1324_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT   
   
   CALL _ADVPL_set_property(m_empresa,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_per_ini,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_per_fim,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_item,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_pedido,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_lpedido,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_cliente,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_lcliente,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_produto,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_lproduto,"EDITABLE",l_status)      
   #CALL _ADVPL_set_property(m_browse,"EDITABLE",l_status)
   
END FUNCTION

#-------------------------------#
FUNCTION pol1324_exibe_default()#
#-------------------------------#
   
   LET mr_cabec.cod_empresa = p_cod_empresa
   LET mr_cabec.dat_fim = TODAY
   LET mr_cabec.dat_ini = mr_cabec.dat_fim - 7
   LET mr_cabec.sel_item = 1
   
   CALL pol1324_find_conf()
   
END FUNCTION

#-----------------------------#
FUNCTION pol1324_zoom_pedido()#
#-----------------------------#

    DEFINE l_pedido        LIKE pedidos.num_pedido,
           l_cliente       LIKE pedidos.cod_cliente,
           l_where_clause  CHAR(300)
    
    IF  m_zpedido IS NULL THEN
        LET m_zpedido = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zpedido,"ZOOM","zoom_pedidos")
    END IF

    LET l_where_clause = " pedidos.ies_sit_pedido <> '9' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zpedido,"ACTIVATE")
    
    LET l_pedido =  _ADVPL_get_property(m_zpedido,"RETURN_BY_TABLE_COLUMN","pedidos","num_pedido")
    LET l_cliente = _ADVPL_get_property(m_zpedido,"RETURN_BY_TABLE_COLUMN","pedidos","cod_cliente")

    IF  l_pedido IS NOT NULL THEN
        LET mr_cabec.num_pedido = l_pedido
        LET mr_cabec.cod_cliente = l_cliente
    END IF
    
    CALL _ADVPL_set_property(m_pedido,"GET_FOCUS")

END FUNCTION

#------------------------------#
FUNCTION pol1324_zoom_cliente()#
#------------------------------#

    DEFINE l_codigo       LIKE clientes.cod_cliente,
           l_descri       LIKE clientes.nom_cliente
    
    IF  m_zcliente IS NULL THEN
        LET m_zcliente = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zcliente,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_zcliente,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zcliente,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_descri = _ADVPL_get_property(m_zcliente,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")

    IF l_codigo IS NOT NULL THEN
       IF m_par_info = 'P' THEN 
          LET mr_cabec.cod_cliente = l_codigo
       ELSE
          LET mr_tela1.cod_cliente = l_codigo
          LET mr_tela1.nom_cliente = l_descri
       END IF
    END IF
    
    CALL _ADVPL_set_property(m_cliente,"GET_FOCUS")

END FUNCTION

#-------------------------------#
FUNCTION pol1324_zoom_trasport()#
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
       LET mr_pcp.cod_transpor = l_codigo
       LET mr_pcp.nom_transpor = l_descri
    END IF
    
    CALL _ADVPL_set_property(m_transpor,"GET_FOCUS")

END FUNCTION

#---------------------------#
FUNCTION pol1324_zoom_item()#
#---------------------------#

    DEFINE l_cod_item       LIKE item.cod_item,
           l_den_item       LIKE item.den_item
    
    IF  m_zproduto IS NULL THEN
        LET m_zproduto = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zproduto,"ZOOM","zoom_item")
    END IF
    
    CALL _ADVPL_get_property(m_zproduto,"ACTIVATE")
    
    LET l_cod_item = _ADVPL_get_property(m_zproduto,"RETURN_BY_TABLE_COLUMN","item","cod_item")
    LET l_den_item = _ADVPL_get_property(m_zproduto,"RETURN_BY_TABLE_COLUMN","item","den_item")

    IF  l_cod_item IS NOT NULL THEN
        LET mr_cabec.cod_item = l_cod_item
    END IF
    
    CALL _ADVPL_set_property(m_item,"GET_FOCUS")

END FUNCTION

#----------------------#
FUNCTION pol1324_find()#
#----------------------#
   
   LET m_ies_cons = FALSE
   
   CALL pol1324_ativa_desativa(TRUE)
   CALL pol1324_limpa_campos()
   CALL _ADVPL_set_property(m_empresa,"GET_FOCUS")
      
   RETURN TRUE 
    
END FUNCTION

#-----------------------------#
FUNCTION pol1324_find_cancel()#
#-----------------------------#

    CALL pol1324_limpa_campos()
    CALL pol1324_ativa_desativa(FALSE)
    LET m_ies_cons = FALSE
    
    RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1324_find_conf()#
#---------------------------#
   
   IF mr_cabec.dat_ini IS NULL THEN
      LET m_msg = "Informe a data inicial"
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_per_ini,"GET_FOCUS")
      RETURN FALSE      
   END IF

   IF mr_cabec.dat_fim IS NULL THEN
      LET m_msg = "Informe a data final"
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_per_fim,"GET_FOCUS")
      RETURN FALSE      
   END IF

   IF mr_cabec.dat_fim < mr_cabec.dat_ini THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Período inválido!")
      CALL _ADVPL_set_property(m_per_ini,"GET_FOCUS")
      RETURN FALSE      
   END IF
   
   CALL LOG_progresspopup_start("Lendo pesidos...","pol1324_monta_tela","PROCESS") 
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   LET m_ies_cons = TRUE
   LET m_ies_sel = FALSE
   CALL pol1324_ativa_desativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1324_monta_tela()#
#----------------------------#     
   
   LET p_status = pol1324_carrega_pedidos()
   
END FUNCTION


#---------------------------------#
FUNCTION pol1324_carrega_pedidos()#
#---------------------------------#
   
   DEFINE l_item_cliente   LIKE cliente_item.cod_item_cliente,
          l_progres        SMALLINT,
          l_prz_entrega    CHAR(10),
          l_dat_atraso     CHAR(10),
          l_qtd_reservada  DECIMAL(10,3)

   CALL LOG_progresspopup_set_total("PROCESS",50)
   
   IF NOT pol1324_del_tab_temp() THEN
      RETURN FALSE
   END IF
   
   CALL pol1324_monta_select()
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   LET l_dat_atraso = EXTEND(m_dat_atu, YEAR TO DAY)
   
   INITIALIZE ma_itens TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")

   PREPARE var_pesquisa FROM m_query
    
   IF  STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE","var_pesquisa")
       RETURN FALSE
   END IF

   DECLARE cq_carrega CURSOR FOR var_pesquisa

   IF  STATUS <> 0 THEN
       CALL log003_err_sql("DECLARE","cq_carrega")
       RETURN FALSE
   END IF
   
   LET m_ind = 1
   
   FOREACH cq_carrega INTO
           ma_itens[m_ind].cod_empresa,
           ma_itens[m_ind].cod_item,
           ma_itens[m_ind].num_pedido,
           ma_itens[m_ind].cod_status,
           ma_itens[m_ind].num_sequencia,
           ma_itens[m_ind].prz_entrega,
           ma_itens[m_ind].qtd_pecas_solic, 
           ma_itens[m_ind].qtd_pecas_atend, 
           ma_itens[m_ind].qtd_pecas_cancel,
           ma_itens[m_ind].cod_cliente,
           ma_itens[m_ind].nom_cliente,
           ma_itens[m_ind].qtd_pecas_romaneio,
           ma_itens[m_ind].qtd_pecas_reserv,
           ma_itens[m_ind].cod_tip_venda
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql("FOREACH","cq_carrega")
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      LET l_prz_entrega = EXTEND(ma_itens[m_ind].prz_entrega, YEAR TO DAY)
      LET ma_itens[m_ind].ies_select = 'N'
      
      IF l_prz_entrega < l_dat_atraso THEN
         CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_ind,197,16,26)
      ELSE
         CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_ind,0,0,0)
      END IF
      
      LET ma_itens[m_ind].qtd_saldo = ma_itens[m_ind].qtd_pecas_solic -
          ma_itens[m_ind].qtd_pecas_atend - ma_itens[m_ind].qtd_pecas_cancel - 
          ma_itens[m_ind].qtd_pecas_romaneio

      IF mr_cabec.sel_item = 3 THEN
      ELSE
         IF mr_cabec.sel_item = 1 THEN
            IF ma_itens[m_ind].qtd_saldo <= 0 THEN
               CONTINUE FOREACH
            END IF
         ELSE
            IF ma_itens[m_ind].qtd_saldo > 0 THEN
               CONTINUE FOREACH
            END IF
         END IF
      END IF
      
      SELECT SUM(qtd_saldo)
        INTO m_qtd_estoque
        FROM estoque_lote
       WHERE cod_empresa = ma_itens[m_ind].cod_empresa
         AND cod_item = ma_itens[m_ind].cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque_lote')
         RETURN FALSE
      END IF
      
      SELECT SUM(qtd_reservada)
        INTO l_qtd_reservada
        FROM estoque_loc_reser
       WHERE cod_empresa = ma_itens[m_ind].cod_empresa
         AND cod_item    = ma_itens[m_ind].cod_item
         AND qtd_reservada > 0

      IF STATUS <> 0 THEN
          CALL log003_err_sql("SELECT","estoque_loc_reser")
          RETURN FALSE
      END IF
      
      IF l_qtd_reservada IS NULL THEN
         LET l_qtd_reservada = 0
      END IF

      IF m_qtd_estoque IS NULL THEN      
         LET m_qtd_estoque = 0
      ELSE
         LET m_qtd_estoque = m_qtd_estoque - l_qtd_reservada
      END IF
      
      LET ma_itens[m_ind].qtd_estoque = m_qtd_estoque
      
      SELECT cod_item_cliente
        INTO l_item_cliente
        FROM cliente_item
       WHERE cod_empresa = ma_itens[m_ind].cod_empresa
         AND cod_cliente_matriz = ma_itens[m_ind].cod_cliente
         AND cod_item = ma_itens[m_ind].cod_item

      IF STATUS = 100 THEN
         LET l_item_cliente = ''
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql("SELECT","cliente_item")
           RETURN FALSE
         END IF        
      END IF
      
      LET ma_itens[m_ind].item_cliente = l_item_cliente
      
      INSERT INTO itens_tela_912
       VALUES(ma_itens[m_ind].*)
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql("SELECT","itens_tela_912")
        RETURN FALSE
      END IF        
      
      LET m_ind = m_ind + 1
   
      IF m_ind > 1000 THEN
         LET m_msg = 'Limite de linhas da\n grade ultrapasou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF m_ind > 1 THEN
      LET m_qtd_linha = m_ind - 1
      CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_linha)
   ELSE
      LET m_msg = 'Não há dados para o período\n ',
           mr_cabec.dat_ini,' - ',mr_cabec.dat_fim
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1324_monta_select()#
#------------------------------#

   LET m_query = 
       "SELECT a.cod_empresa, a.cod_item, a.num_pedido, b.ies_sit_pedido, a.num_sequencia, ",
       " a.prz_entrega, a.qtd_pecas_solic, a.qtd_pecas_atend, a.qtd_pecas_cancel, ",
       " b.cod_cliente, c.nom_reduzido, a.qtd_pecas_romaneio, a.qtd_pecas_reserv, b.cod_tip_venda ",
       " FROM ped_itens a, pedidos b, clientes c ",
       " WHERE b.ies_sit_pedido NOT IN ('9','B','S') AND b.cod_cliente = c.cod_cliente ",
       "  AND b.num_pedido = a.num_pedido ",
       "  AND a.prz_entrega >= '",mr_cabec.dat_ini,"' ",
       "  AND a.prz_entrega <= '",mr_cabec.dat_fim,"' ",
       "  AND b.cod_cliente LIKE '",mr_cabec.cod_cliente CLIPPED,"%","' "

   IF mr_cabec.cod_empresa <> 'XX' THEN
      LET m_query = m_query CLIPPED, " AND a.cod_empresa = '",mr_cabec.cod_empresa,"' "
   END IF

   IF mr_cabec.num_pedido IS NOT NULL THEN
      LET m_query = m_query CLIPPED, " AND b.num_pedido = ",mr_cabec.num_pedido
   END IF

   #IF mr_cabec.cod_cliente IS NOT NULL THEN
   #   LET m_query = m_query CLIPPED, " AND b.cod_cliente = '",mr_cabec.cod_cliente,"' "
   #END IF

   IF mr_cabec.cod_item IS NOT NULL THEN
      LET m_query = m_query CLIPPED, " AND a.cod_item = '",mr_cabec.cod_item,"' "
   END IF
   
   LET m_query = m_query CLIPPED, " ORDER BY b.cod_cliente, a.num_pedido, a.prz_entrega "
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1324_cria_tab_temp()#
#-------------------------------#

   DROP TABLE w_ped_item_912;
   CREATE TEMP TABLE w_ped_item_912 (
       linha             INTEGER,
       cod_empresa       CHAR(02),
       cod_item          CHAR(15),
       item_cliente      CHAR(30),
       num_pedido        DECIMAL(6,0),
       num_sequencia     DECIMAL(5,0),
       prz_entrega       DATE,
       qtd_pecas_solic   DECIMAL(6,0),
       qtd_pecas_atend   DECIMAL(6,0),
       qtd_pecas_cancel  DECIMAL(6,0),
       qtd_pecas_romaneio DECIMAL(6,0),
       qtd_pecas_reserv  DECIMAL(6,0),
       qtd_saldo         DECIMAL(6,0),
       cod_cliente       CHAR(15),
       nom_cliente       CHAR(15));
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','w_ped_item_912')
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX index_w_ped_item ON w_ped_item_912(linha);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','index_w_ped_item')
      RETURN FALSE
   END IF
   
   DROP TABLE lote_fat_912;
   CREATE TEMP TABLE lote_fat_912 (
      cod_empresa       CHAR(02),
      cod_cliente       CHAR(15),
      num_pedido        INTEGER,
      num_sequencia     INTEGER,
      cod_item          CHAR(15),
      num_lote          CHAR(15),
      cod_local         CHAR(10),
      qtd_faturar       DECIMAL(10,3),
      qtd_etiqueta      DECIMAL(4,0)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','lote_fat_912')
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX index_lote_fat ON
    lote_fat_912(cod_empresa, num_pedido, num_sequencia, num_lote); 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','index_lote_fat')
      RETURN FALSE
   END IF

   DROP TABLE lote_sel_912; 
   CREATE TEMP TABLE lote_sel_912 (
      num_lote          CHAR(15),
      qtd_lote          DECIMAL(10,3),
      num_seq           INTEGER
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','lote_sel_912')
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX lote_sel_912 ON
    lote_sel_912(num_lote); 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','index_lote_sel')
      RETURN FALSE
   END IF

   DROP TABLE resumo_embal;   
   CREATE TEMP TABLE resumo_embal
     (
      cod_embal        CHAR(15),
      qtd_vol          DECIMAL(6,0)
     );
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql("CRIACAO","TABELA-resumo_embal")
      RETURN FALSE
   END IF
   
   DROP TABLE w_om_list;
   CREATE TEMP TABLE w_om_list
     (
      cod_empresa    CHAR(2),  
      num_om         DEC(6,0), 
      num_pedido     DEC(6,0), 
      dat_emis       DATE,
      nom_usuario    CHAR(8)      
     );
     
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-W_OM_LIST")
      RETURN FALSE
   END IF

   DROP TABLE w_lote;
   CREATE TEMP TABLE w_lote
     (
      cod_empresa    CHAR(2),  
      cod_item       CHAR(015),
      num_seq        SMALLINT,
      cod_local      CHAR(010),
      num_lote       CHAR(015),
      qtd_reservada  DECIMAL(15,3),
      qtd_saldo      DECIMAL(15,3)
     );

   IF STATUS  <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-W_LOTE")
      RETURN FALSE
   END IF

   
   DROP TABLE lote_tmp_304;
   CREATE TEMP TABLE lote_tmp_304
     (
      num_seq        SMALLINT,  
      qtd_reservada  DEC(7,0), 
      num_lote       CHAR(15)
     )
     
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-lote_tmp_304")
      RETURN FALSE
   END IF

   DROP TABLE itens_tela_912;
   CREATE TEMP TABLE itens_tela_912
     (
       ies_select         CHAR(01),
       cod_empresa        CHAR(02),
       cod_item           CHAR(15),
       item_cliente       CHAR(30),
       num_pedido         DECIMAL(6,0),
       cod_tip_venda      INTEGER,
       cod_status         CHAR(01),
       num_sequencia      DECIMAL(5,0),
       prz_entrega        DATE,
       qtd_pecas_solic    DECIMAL(6,0),
       qtd_pecas_atend    DECIMAL(6,0),
       qtd_pecas_cancel   DECIMAL(6,0),
       qtd_pecas_reserv   DECIMAL(6,0),
       qtd_pecas_romaneio DECIMAL(6,0),
       qtd_saldo          DECIMAL(6,0),
       qtd_estoque        DECIMAL(10,3),
       cod_cliente        CHAR(15),
       nom_cliente        CHAR(15),
       filler             CHAR(01)
     );
     
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-itens_tela_912")
      RETURN FALSE
   END IF

   CREATE INDEX ix_itens_912 
    ON itens_tela_912(cod_empresa, cod_item);
   
   DROP TABLE lotes_912 ;
   CREATE TEMP TABLE lotes_912 (
       modificar         CHAR(01),
       cod_local         CHAR(10),
       num_lote          CHAR(15),
       ies_tipo          CHAR(01),
       qtd_saldo         DECIMAL(10,3),
       faturar           CHAR(01),
       filler            CHAR(01)
   );

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-lotes_912")
      RETURN FALSE
   END IF

   CREATE INDEX ix_lotes_912 
    ON lotes_912(num_lote);
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1324_del_tab_temp()#
#------------------------------#

   DELETE FROM w_ped_item_912
   DELETE FROM lote_fat_912
   DELETE FROM lote_sel_912
   DELETE FROM itens_tela_912
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1324_clasif_entrega()#
#--------------------------------#

   IF m_classif = 'D' THEN
      RETURN TRUE
   END IF
   
   LET m_classif = 'D'
   
   IF NOT pol1324_le_itens_912() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1324_clasif_cliente()#
#--------------------------------#

   IF m_classif = 'C' THEN
      RETURN TRUE
   END IF

   LET m_classif = 'C'

   IF NOT pol1324_le_itens_912() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1324_le_itens_912()#
#------------------------------#
   
   DEFINE l_query           CHAR(3000)
   
   INITIALIZE ma_itens TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   LET m_ind = 1
   
   IF m_classif = 'D' THEN
      DECLARE cq_temp CURSOR FOR
       SELECT *
         FROM itens_tela_912
        ORDER BY prz_entrega
   ELSE
      IF m_classif = 'C' THEN
         DECLARE cq_temp CURSOR FOR
          SELECT *
            FROM itens_tela_912
           ORDER BY cod_cliente
      ELSE
         DECLARE cq_temp CURSOR FOR
          SELECT *
            FROM itens_tela_912
           ORDER BY cod_cliente, num_pedido, prz_entrega
      END IF
   END IF
       
   IF  STATUS <> 0 THEN
       CALL log003_err_sql("DECLARE","cq_temp")
       RETURN FALSE
   END IF
   
   FOREACH cq_temp INTO ma_itens[m_ind].*

      IF STATUS <> 0 THEN
         CALL log003_err_sql("SELECT","itens_tela_912:cq_temp")
        RETURN FALSE
      END IF        
      
      LET m_ind = m_ind + 1
   
      IF m_ind > 1000 THEN
         LET m_msg = 'Limite de linhas da\n grade ultrapasou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF m_ind > 1 THEN
      LET m_qtd_linha = m_ind - 1
      CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_linha)
   ELSE
      LET m_msg = 'Não há dados para serem exibidos'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1324_checa_sel()#
#---------------------------#

   DEFINE l_lin_atu       INTEGER,
          l_num_pedido    INTEGER,
          l_usuario       CHAR(08),
          l_empresa       CHAR(02)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   IF ma_itens[l_lin_atu].ies_select = 'N' THEN
      DELETE FROM w_ped_item_912 WHERE linha = l_lin_atu
      LET p_status = pol1324_del_ped(l_lin_atu)
      LET m_ies_sel = FALSE
      RETURN TRUE
   END IF
   
   LET l_usuario = pol1324_checa_usu(l_lin_atu)
   LET l_empresa = ma_itens[l_lin_atu].cod_empresa
   
   IF l_usuario IS NOT NULL THEN
      LET m_msg = 'Pedido/item está sendo usado\n',
                  'pelo Usuário ',l_usuario
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      LET ma_itens[l_lin_atu].ies_select = 'N'
      RETURN FALSE
   END IF    
   
   IF m_ies_sel THEN
      LET m_msg = 'Somente um item pode ser selecionado.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      LET ma_itens[l_lin_atu].ies_select = 'N'
      RETURN FALSE
   END IF
   
   IF NOT pol1324_verifica_embalagem(l_lin_atu) THEN
      LET ma_itens[l_lin_atu].ies_select = 'N'
      RETURN FALSE
   END IF
   
   LET m_cod_cliente = ma_itens[l_lin_atu].cod_cliente
   LET m_msg = NULL
   
   IF ma_itens[l_lin_atu].cod_cliente MATCHES '[AF]' THEN
   ELSE
      IF NOT pol1324_verifica_credito(l_empresa) THEN
         IF m_msg IS NOT NULL THEN
            CALL log0030_mensagem(m_msg,'info')
         END IF
         LET ma_itens[l_lin_atu].ies_select = 'N'
         RETURN FALSE
      END IF
   END IF
   
   IF NOT pol1324_ins_pedido(l_lin_atu) THEN
      LET ma_itens[l_lin_atu].ies_select = 'N'
      RETURN FALSE
   END IF
   
   LET m_ies_sel = TRUE 
   LET m_lin_sel = l_lin_atu

   CALL LOG_progresspopup_start("Carregando lotes...","pol1324_car_lote","PROCESS")
   
   #LET m_ies_cons = FALSE
   #CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
   
   IF mr_pcp.qtd_faturar > 0 AND m_gerou_om THEN
      LET ma_itens[m_lin_sel].qtd_saldo = 
          ma_itens[m_lin_sel].qtd_saldo - mr_pcp.qtd_faturar
      LET ma_itens[m_lin_sel].qtd_pecas_romaneio = 
          ma_itens[m_lin_sel].qtd_pecas_romaneio + mr_pcp.qtd_faturar
      CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_lin_sel,171,124,186)      
   END IF

   LET ma_itens[m_lin_sel].ies_select = 'N' 
   LET m_ies_sel = FALSE

   DELETE FROM w_ped_item_912 WHERE linha = l_lin_atu
   DELETE FROM lote_fat_912
   DELETE FROM lote_sel_912
   
   RETURN TRUE

END FUNCTION   

#--------------------------------#
FUNCTION pol1324_checa_usu(l_ind)#
#--------------------------------#

   DEFINE l_ind        INTEGER,
          l_user       CHAR(08)
          
   SELECT usuario
     INTO l_user
     FROM ped_item_sel_912
    WHERE cod_empresa = ma_itens[l_ind].cod_empresa
      AND num_pedido = ma_itens[l_ind].num_pedido
      AND num_sequencia = ma_itens[l_ind].num_sequencia

   IF STATUS = 100 THEN
      LET l_user = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ped_item_sel_912')
         LET l_user = NULL
      END IF
   END IF
   
   RETURN l_user

END FUNCTION

#------------------------------#
FUNCTION pol1324_del_ped(l_ind)#
#------------------------------#

   DEFINE l_ind        INTEGER
          
   DELETE FROM ped_item_sel_912
    WHERE cod_empresa = ma_itens[l_ind].cod_empresa
      AND num_pedido = ma_itens[l_ind].num_pedido
      AND num_sequencia = ma_itens[l_ind].num_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ped_item_sel_912')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------------#
FUNCTION pol1324_verifica_embalagem(l_ind)#
#-----------------------------------------#

   DEFINE l_ind      INTEGER
   
   SELECT cod_embal, 
          qtd_padr_embal
     INTO mr_embal.cod_embal,
          mr_embal.qtd_padrao
     FROM embal_itaesbra
    WHERE cod_empresa = ma_itens[l_ind].cod_empresa
      AND cod_item = ma_itens[l_ind].cod_item
      AND cod_cliente = ma_itens[l_ind].cod_cliente
      AND cod_tip_venda = ma_itens[l_ind].cod_tip_venda
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','embal_itaesbra:ve')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   
   
#-------------------------------------------#
 FUNCTION pol1324_verifica_credito(l_empresa)
#-------------------------------------------#
   
   DEFINE l_empresa            CHAR(02),
          lr_par_vdp           RECORD LIKE par_vdp.*,
          lr_cli_credito       RECORD LIKE cli_credito.*,
          l_valor_cli          DECIMAL(15,2),
          l_parametro          CHAR(1)
          
   SELECT *
     INTO lr_cli_credito.*
     FROM cli_credito
    WHERE cod_cliente = m_cod_cliente
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cli_credito')
      RETURN FALSE
   END IF

   SELECT *
     INTO lr_par_vdp.*
     FROM par_vdp
    WHERE cod_empresa = l_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','par_vdp')
      RETURN FALSE
   END IF

   IF lr_par_vdp.par_vdp_txt[367] = 'S' THEN
      IF lr_cli_credito.qtd_dias_atr_dupl > lr_par_vdp.qtd_dias_atr_dupl THEN
         LET m_msg = 'Cliente com duplicatas em atraso excedido.'
         RETURN FALSE
      END IF
      IF lr_cli_credito.qtd_dias_atr_med > lr_par_vdp.qtd_dias_atr_med THEN
         LET m_msg = 'Cliente com atraso médio excedido.'
         RETURN FALSE
      END IF
   END IF

   SELECT par_ies
     INTO l_parametro
     FROM par_vdp_pad
    WHERE cod_empresa   = l_empresa
      AND cod_parametro = 'ies_limite_credito'

   IF STATUS = 100 THEN
      LET l_parametro = 'N'
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','par_vdp')
         RETURN FALSE
      END IF
   END IF
    
   IF l_parametro = 'S' THEN         
      LET l_valor_cli = lr_cli_credito.val_ped_carteira + 
                        lr_cli_credito.val_dup_aberto
      IF l_valor_cli > lr_cli_credito.val_limite_cred THEN
         LET m_msg = 'Limite de crédito excedido.'
         RETURN FALSE
      END IF
   END IF

   IF lr_cli_credito.dat_val_lmt_cr IS NOT NULL THEN
      IF lr_cli_credito.dat_val_lmt_cr < TODAY THEN
         LET m_msg =  'Data crédito expirada.'
         RETURN FALSE
      END IF
   END IF    
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1324_ins_pedido(l_linha)#
#-----------------------------------#
   
   DEFINE l_linha    INTEGER
   
   INSERT INTO w_ped_item_912
    VALUES(l_linha,
           ma_itens[l_linha].cod_empresa,     
           ma_itens[l_linha].cod_item,        
           ma_itens[l_linha].item_cliente,    
           ma_itens[l_linha].num_pedido,      
           ma_itens[l_linha].num_sequencia,   
           ma_itens[l_linha].prz_entrega,     
           ma_itens[l_linha].qtd_pecas_solic, 
           ma_itens[l_linha].qtd_pecas_atend, 
           ma_itens[l_linha].qtd_pecas_cancel,
           ma_itens[l_linha].qtd_pecas_romaneio,
           ma_itens[l_linha].qtd_pecas_reserv,
           ma_itens[l_linha].qtd_saldo,       
           ma_itens[l_linha].cod_cliente,     
           ma_itens[l_linha].nom_cliente)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','w_ped_item_912')
      RETURN FALSE
   END IF
   
   INSERT INTO ped_item_sel_912
    VALUES (ma_itens[l_linha].cod_empresa,
            ma_itens[l_linha].num_pedido,
            ma_itens[l_linha].num_sequencia,
            p_user)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ped_item_sel_912')
      RETURN FALSE
   END IF
                
   RETURN TRUE

END FUNCTION


#--------------------------#
FUNCTION pol1324_car_lote()#
#--------------------------#
   
   INITIALIZE mr_ficha.* TO NULL
   
   CALL LOG_progresspopup_set_total("PROCESS",1)   
   CALL pol1324_detalhe()

END FUNCTION

#-------------------------#
FUNCTION pol1324_detalhe()#
#-------------------------#

    DEFINE l_menubar    VARCHAR(10),
           l_panel      VARCHAR(10),
           l_gerar      VARCHAR(10),
           l_etiq       VARCHAR(10),
           l_lote       VARCHAR(10),
           l_confirm    VARCHAR(10),
           l_next       VARCHAR(10),
           l_sair       VARCHAR(10)

    LET m_qtd_next = 1
    LET m_gerou_om = FALSE
    LET m_ies_imp = 'N'
    LET m_ies_roma = 'N'
    LET m_num_seq = 0
    LET m_sdo_sel = 0
    
    DELETE FROM lote_fat_912
    
    LET m_dlg_det = _ADVPL_create_component(NULL,"LFRAME")
    #CALL _ADVPL_set_property(m_dlg_det,"SIZE",1200,500)
    CALL _ADVPL_set_property(m_dlg_det,"TITLE","SELEÇÃO DE LOTES E GERAÇÃO DE OM")
    CALL _ADVPL_set_property(m_dlg_det,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dlg_det,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dlg_det,"INIT_EVENT","pol1324_init_form")

    LET m_bar_det = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dlg_det)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dlg_det)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_confirm = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirm,"IMAGE","CONFIRM_EX")
   CALL _ADVPL_set_property(l_confirm,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirm,"TOOLTIP","Confirmar lotes selecionados")
   CALL _ADVPL_set_property(l_confirm,"EVENT","pol1324_conf_lotes")

   LET l_gerar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_gerar,"IMAGE","GERAR_EX")
   CALL _ADVPL_set_property(l_gerar,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_gerar,"TOOLTIP","Gerar romaneios")
   CALL _ADVPL_set_property(l_gerar,"EVENT","pol1324_gerar")
   CALL _ADVPL_set_property(l_gerar,"OPERATION","Gerar OM")

    LET l_etiq = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_etiq,"IMAGE","ETIQUETAS") 
    CALL _ADVPL_set_property(l_etiq,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_etiq,"TOOLTIP","Imprimir etiquetas")
    CALL _ADVPL_set_property(l_etiq,"EVENT","pol1324_imp_etiqueta")

    LET l_lote = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_lote,"IMAGE","REIMPRESSAO") 
    CALL _ADVPL_set_property(l_lote,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_lote,"TOOLTIP","Reimprimir lote")
    CALL _ADVPL_set_property(l_lote,"EVENT","pol1324_tela_lote")

   LET l_sair = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
   CALL _ADVPL_set_property(l_sair,"EVENT","pol1324_sair_det")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dlg_det)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1324_campos_det(l_panel)
    CALL pol1324_grade_lote(l_panel)
    CALL pol1324_grade_faturar(l_panel)
    CALL pol1324_campos_exped(l_panel)
    
    CALL pol1324_le_w_ped_item()

    CALL _ADVPL_set_property(m_dlg_det,"ACTIVATE",TRUE)    
    
END FUNCTION

#---------------------------#
FUNCTION pol1324_init_form()#
#---------------------------#

   LET m_sel_lote = FALSE
   LET m_tot_sel = 0
   
   CALL _ADVPL_set_property(m_brz_lote,"REFRESH")
   CALL _ADVPL_set_property(m_faturar,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------------#
FUNCTION pol1324_campos_det(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_empresa         VARCHAR(10),
           l_pedido          VARCHAR(10),
           l_sequenc         VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",185)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)
    CALL _ADVPL_set_property(l_panel,"EDITABLE",FALSE)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",15,5)
    CALL _ADVPL_set_property(l_label,"TEXT","Filial:")    

    LET l_empresa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_empresa,"POSITION",15,25)     
    CALL _ADVPL_set_property(l_empresa,"VARIABLE",mr_detalhe,"cod_empresa")
    CALL _ADVPL_set_property(l_empresa,"LENGTH",2,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",60,5)
    CALL _ADVPL_set_property(l_label,"TEXT","Pedido:")    

    LET l_pedido = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(l_pedido,"POSITION",60,25)     
    CALL _ADVPL_set_property(l_pedido,"VARIABLE",mr_detalhe,"num_pedido")
    CALL _ADVPL_set_property(l_pedido,"LENGTH",6,0)
    CALL _ADVPL_set_property(l_pedido,"PICTURE","@E ######")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",130,5)
    CALL _ADVPL_set_property(l_label,"TEXT","Sequenc:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",130,25)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"num_sequencia")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",5,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",185,5)
    CALL _ADVPL_set_property(l_label,"TEXT","Entrega:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",185,25)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"prz_entrega")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",293,5)
    CALL _ADVPL_set_property(l_label,"TEXT","Contrato:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",293,25)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"num_contrato")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",560,5)
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    

    LET m_desc_cli = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(m_desc_cli,"POSITION",615,5)
    CALL _ADVPL_set_property(m_desc_cli,"TEXT","")    
    CALL _ADVPL_set_property(m_desc_cli,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",560,25)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"cod_cliente")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",15,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",15,50)
    CALL _ADVPL_set_property(l_label,"TEXT","Item Logix:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",15,65)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"cod_item")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",15,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",160,50)
    CALL _ADVPL_set_property(l_label,"TEXT","Item Cliente:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",160,65)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"item_cliente")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",25,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",380,50)
    CALL _ADVPL_set_property(l_label,"TEXT","Cod fab:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",380,65)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"cod_fabrica")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",6,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",455,50)
    CALL _ADVPL_set_property(l_label,"TEXT","Cod doca:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",455,65)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"cod_doca")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",6,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",532,50)
    CALL _ADVPL_set_property(l_label,"TEXT","Hora:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",532,65)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"hora")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",8,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",615,50)
    CALL _ADVPL_set_property(l_label,"TEXT","Tip prog:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",615,65)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"tipo_prg_honda")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",8,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",15,90)
    CALL _ADVPL_set_property(l_label,"TEXT","Slip Honda:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",15,105)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"slip_number_honda")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",15,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",160,90)
    CALL _ADVPL_set_property(l_label,"TEXT","Chamado/entrega:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",160,105)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"seppen_honda")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",12,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",283,90)
    CALL _ADVPL_set_property(l_label,"TEXT","Lote Honda:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",283,105)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"lote_prod_honda")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",13,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",415,90)
    CALL _ADVPL_set_property(l_label,"TEXT","Obs Honda:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",415,105)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"observacao_honda")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",38,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",15,130)
    CALL _ADVPL_set_property(l_label,"TEXT","Cpi Honda:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",15,145)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"tbxcpi_honda")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",15,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",160,130)
    CALL _ADVPL_set_property(l_label,"TEXT","Entrega Honda:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",160,145)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"hora_entrega_honda")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",8,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",245,130)
    CALL _ADVPL_set_property(l_label,"TEXT","Manuseio:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",245,145)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"manuseio")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",13,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",365,130)
    CALL _ADVPL_set_property(l_label,"TEXT","Estoquista:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",365,145)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"estoquista")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",13,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",495,130)
    CALL _ADVPL_set_property(l_label,"TEXT","xped:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",495,145)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"xped")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",12,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",615,130)
    CALL _ADVPL_set_property(l_label,"TEXT","Item ped:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",615,145)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"nitemped")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",13,0)

    #----------------------------------------------------------------#

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",760,28)
    CALL _ADVPL_set_property(l_label,"TEXT","Embalagem")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",760,51)
    CALL _ADVPL_set_property(l_label,"TEXT","Tipo venda:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",830,51)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",3)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_embal,"cod_tip_venda")
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@!")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",760,74)
    CALL _ADVPL_set_property(l_label,"TEXT","Tipo embal:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",830,74)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",20)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_embal,"tipo")
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@!")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",760,97)
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd padrão:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",830,97)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_embal,"qtd_padrao")
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E #######")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",780,120)
    CALL _ADVPL_set_property(l_label,"TEXT","Código:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",830,120)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",3)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_embal,"cod_embal")
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@!")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",760,143)
    CALL _ADVPL_set_property(l_label,"TEXT"," Descrição:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",830,143)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",20)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_embal,"den_embal")
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@!")


    #----------------------------------------------------------------#



    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",980,5)
    CALL _ADVPL_set_property(l_label,"TEXT","Quantidades do pedido:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",1135,5)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"cod_unid_med")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",3,0)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1015,28)
    CALL _ADVPL_set_property(l_label,"TEXT","Solicitada:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",1080,28)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"qtd_pecas_solic")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E ######.###")
    
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1015,51)
    CALL _ADVPL_set_property(l_label,"TEXT","Entregue:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",1080,51)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"qtd_pecas_atend")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E ######.###")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1015,74)
    CALL _ADVPL_set_property(l_label,"TEXT","Cancelada:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",1080,74)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"qtd_pecas_cancel")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E ######.###")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1015,97)
    CALL _ADVPL_set_property(l_label,"TEXT","Reservada:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",1080,97)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"qtd_pecas_reserv")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E ######.###")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1015,120)
    CALL _ADVPL_set_property(l_label,"TEXT","Romaneio:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",1080,120)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"qtd_pecas_romaneio")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E ######.###")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1015,143)
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd saldo:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",1080,143)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"qtd_saldo")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E ######.###")
    
    #-------------------------------------------------------------#
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",60,170)     
    CALL _ADVPL_set_property(l_label,"TEXT","Lotes em estoque")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",200,170)     
    CALL _ADVPL_set_property(l_label,"TEXT","Total selecionado:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,FALSE,FALSE)

    LET m_qtd_sel = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(m_qtd_sel,"POSITION",300,170)     
    CALL _ADVPL_set_property(m_qtd_sel,"TEXT","")    
    CALL _ADVPL_set_property(m_qtd_sel,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",1080,120)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_detalhe,"qtd_pecas_romaneio")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E ######.###")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",450,170)     
    CALL _ADVPL_set_property(l_label,"TEXT","Lote para faturar")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    {LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",900,170)     
    CALL _ADVPL_set_property(l_label,"TEXT","Montagem da carga")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)}

END FUNCTION


#---------------------------------------#
FUNCTION pol1324_grade_lote(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_label           VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
    #CALL _ADVPL_set_property(l_panel,"WIDTH",350)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brz_lote = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_lote,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_lote)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","MODIFICAR_LOTE")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Modif")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",55)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","modificar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1324_sel_lote")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1324_valida_pcp")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_lote)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Local")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_local")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_lote)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Lote")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_lote")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    #CALL _ADVPL_set_property(l_tabcolumn,"HEADER_CLICK_EVENT","pol1324_clasif_lote")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_lote)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_lote)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ##########")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_lote)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","FATURAR")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Fat")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","faturar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1324_fat_lote")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1324_valida_pcp")

    {LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_lote)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)}

    CALL _ADVPL_set_property(m_brz_lote,"SET_ROWS",ma_lotes,1)
    CALL _ADVPL_set_property(m_brz_lote,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_brz_lote,"CAN_REMOVE_ROW",FALSE)

END FUNCTION

#--------------------------#
FUNCTION pol1324_fat_lote()#
#--------------------------#
  
   DEFINE l_lin_atu       INTEGER,
          l_qtd_fat       INTEGER
   
   CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",'')
   
   LET l_qtd_fat = _ADVPL_get_property(m_brz_fat,"ITEM_COUNT")

   IF l_qtd_fat > 0 THEN
      LET m_msg = 'Você já selecionou o lote a faturar'
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET l_lin_atu = _ADVPL_get_property(m_brz_lote,"ROW_SELECTED")
   LET ma_lotes[l_lin_atu].faturar = 'N'

   IF ma_lotes[l_lin_atu].modificar = 'S' THEN
      LET m_msg = 'Você já marcou esse lote para modifcar'
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF mr_detalhe.qtd_saldo <= 0 THEN
      LET m_msg = 'Item do pedido sem saldo para faturar.'
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   IF NOT pol1324_checa_lote(l_lin_atu) THEN
      RETURN FALSE
   END IF   

   IF ma_lotes[l_lin_atu].qtd_saldo < mr_pcp.qtd_faturar THEN
      LET m_msg = 'Saldo do lote é inferior à quantidade a faturar.'
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET m_num_lote  = ma_lotes[l_lin_atu].num_lote
   
   CALL pol1324_add_lote_fat()      
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1324_checa_lote(l_ind)#
#---------------------------------#
   
   DEFINE l_ind          INTEGER
   
   IF ma_lotes[l_ind].ies_tipo = 'L' THEN
   ELSE
      LET m_msg = 'Somente lote tipo L pode ser utilizado.'
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1324_le_item() THEN
      RETURN FALSE
   END IF
   
   IF ma_lotes[l_ind].cod_local <> m_local_estoq THEN
      LET m_msg = 'Somente lote do local ',
           m_local_estoq CLIPPED,' pode ser utilizado.'
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------------------#
FUNCTION pol1324_grade_faturar(l_container)#
#------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(l_panel,"WIDTH",250)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brz_fat = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_fat,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_fat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Lote")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_lote")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",75)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_fat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)


    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_fat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Seq")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_sequencia")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_fat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Faturar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_faturar")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ##########")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_fat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd etiq")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_etiqueta")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ####")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_fat)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CANCEL_EX")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Excluir")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","excluir")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1324_exc_lote")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_fat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_fat,"SET_ROWS",ma_faturar,1)
    CALL _ADVPL_set_property(m_brz_fat,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_fat,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_brz_fat,"CLEAR")
    
END FUNCTION

#-----------------------------------------#
FUNCTION pol1324_campos_exped(l_container)#
#-----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_etiq            VARCHAR(10),
           l_rastro          VARCHAR(10),
           l_om              VARCHAR(10),
           l_caixa           VARCHAR(10)
           
    INITIALIZE mr_pcp.* TO NULL
    
    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","RIGHT")
    CALL _ADVPL_set_property(l_panel,"WIDTH",380)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,20)
    CALL _ADVPL_set_property(l_label,"TEXT","Quantidades trânsito PCP:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",40,50)
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd faturar:")    

    LET m_faturar = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_faturar,"POSITION",120,50)     
    CALL _ADVPL_set_property(m_faturar,"LENGTH",10)
    CALL _ADVPL_set_property(m_faturar,"PICTURE","@E #,###,###.###")
    CALL _ADVPL_set_property(m_faturar,"VARIABLE",mr_pcp,"qtd_faturar")
    CALL _ADVPL_set_property(m_faturar,"VALID","pol1324_valid_qtd")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",5,80)
    CALL _ADVPL_set_property(l_label,"TEXT","Capac embalagem:")    

    LET m_embal = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_embal,"POSITION",120,80)     
    CALL _ADVPL_set_property(m_embal,"LENGTH",10)
    CALL _ADVPL_set_property(m_embal,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_embal,"PICTURE","@E ##########")
    CALL _ADVPL_set_property(m_embal,"VARIABLE",mr_pcp,"cap_embal")
    CALL _ADVPL_set_property(m_embal,"VALID","pol1324_valid_embal")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,110)
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd Etiquetas:")    

    LET m_etiqueta = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_etiqueta,"POSITION",120,110)     
    CALL _ADVPL_set_property(m_etiqueta,"LENGTH",10)
    CALL _ADVPL_set_property(m_etiqueta,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_etiqueta,"PICTURE","@E ##########")
    CALL _ADVPL_set_property(m_etiqueta,"VARIABLE",mr_pcp,"qtd_etiqueta")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,140)
    CALL _ADVPL_set_property(l_label,"TEXT","Transportador:")    

    LET m_transpor = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_transpor,"POSITION",120,140)     
    CALL _ADVPL_set_property(m_transpor,"LENGTH",15)
    CALL _ADVPL_set_property(m_transpor,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_transpor,"PICTURE","@E!")
    CALL _ADVPL_set_property(m_transpor,"VARIABLE",mr_pcp,"cod_transpor")
    CALL _ADVPL_set_property(m_transpor,"VALID","pol1324_valid_transp")

    LET l_caixa = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",260,140)     
    CALL _ADVPL_set_property(l_caixa,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_caixa,"SIZE",24,20)
    CALL _ADVPL_set_property(l_caixa,"CLICK_EVENT","pol1324_zoom_trasport")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",10,170)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",36)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E!")
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_pcp,"nom_transpor")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",40,200)
    CALL _ADVPL_set_property(l_label,"TEXT","Número OM:")    

    LET l_om = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(l_om,"POSITION",120,200)     
    CALL _ADVPL_set_property(l_om,"LENGTH",9,0)
    CALL _ADVPL_set_property(l_om,"PICTURE","@E #########")
    CALL _ADVPL_set_property(l_om,"ENABLE",FALSE)
    CALL _ADVPL_set_property(l_om,"VARIABLE",mr_pcp,"num_om")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",40,230)
    CALL _ADVPL_set_property(l_label,"TEXT","Num lot OM:")    

    LET l_om = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(l_om,"POSITION",120,230)     
    CALL _ADVPL_set_property(l_om,"LENGTH",9,0)
    CALL _ADVPL_set_property(l_om,"PICTURE","@E #########")
    CALL _ADVPL_set_property(l_om,"ENABLE",FALSE)
    CALL _ADVPL_set_property(l_om,"VARIABLE",mr_pcp,"num_lote_om")

END FUNCTION

#----------------------------#
FUNCTION pol1324_valida_pcp()#
#----------------------------#
   
   DEFINE l_qtd_etiqueta INTEGER
   
   IF mr_pcp.qtd_faturar IS NULL OR mr_pcp.qtd_faturar <= 0 THEN
      LET m_msg = 'Informe a quantidade a faturar'
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_faturar,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_pcp.cap_embal IS NULL OR mr_pcp.cap_embal <= 0 THEN
      LET m_msg = 'Informe a capacidade da embalagem'
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_embal,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_pcp.cod_transpor IS NULL THEN
      LET m_msg = 'Informe o Transportador'
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_transpor,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#---------------------------#
FUNCTION pol1324_valid_qtd()#
#---------------------------#
   
   DEFINE l_qtd_etiqueta INTEGER
   
   IF mr_pcp.qtd_faturar IS NULL OR mr_pcp.qtd_faturar <= 0 THEN
      RETURN TRUE
      LET m_msg = 'Informe a quantidade a faturar'
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_faturar,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   IF mr_pcp.qtd_faturar >  mr_detalhe.qtd_saldo  THEN
      LET m_msg = 'Quantidade a faturar maior\n que saldo do pedido'
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_faturar,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_pcp.qtd_faturar >  m_saldo_lote  THEN
      LET m_msg = 'Quantidade a faturar maior\n que saldo dos lotes'
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_faturar,"GET_FOCUS")
      RETURN FALSE
   END IF

   LET l_qtd_etiqueta = mr_pcp.qtd_faturar / mr_embal.qtd_padrao
   
   IF ( mr_pcp.qtd_faturar MOD mr_embal.qtd_padrao ) > 0 THEN
      LET l_qtd_etiqueta = l_qtd_etiqueta + 1
   END IF
      
   LET mr_pcp.qtd_etiqueta = l_qtd_etiqueta
   CALL _ADVPL_set_property(m_embal,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1324_valid_embal()#
#-----------------------------#
   
   DEFINE l_qtd_etiqueta INTEGER
   
   IF mr_pcp.cap_embal IS NULL OR mr_pcp.cap_embal <= 0 THEN
      RETURN TRUE
      LET m_msg = 'Informe a capacidade da embalagem'
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_embal,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   LET mr_embal.qtd_padrao = mr_pcp.cap_embal
   LET l_qtd_etiqueta = mr_pcp.qtd_faturar / mr_embal.qtd_padrao
   
   IF ( mr_pcp.qtd_faturar MOD mr_embal.qtd_padrao ) > 0 THEN
      LET l_qtd_etiqueta = l_qtd_etiqueta + 1
   END IF
      
   LET mr_pcp.qtd_etiqueta = l_qtd_etiqueta
   
   CALL _ADVPL_set_property(m_transpor,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1324_valid_transp()#
#------------------------------#
      
   IF mr_pcp.cod_transpor IS NULL THEN
      RETURN TRUE
      LET m_msg = 'Informe o Transportador'
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_transpor,"GET_FOCUS")
      RETURN FALSE
   END IF

   CALL pol1324_le_transp(mr_pcp.cod_transpor)
   
   IF m_nom_transp IS NULL THEN
      LET m_msg = 'Transportador inválido.'
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_transpor,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   LET m_cod_transpor = mr_pcp.cod_transpor
   LET mr_pcp.nom_transpor = m_nom_transp
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1324_le_transp(l_cod)#
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
FUNCTION pol1324_le_w_ped_item()#
#-------------------------------#

   DECLARE cq_cons SCROLL CURSOR WITH HOLD FOR
    SELECT linha FROM w_ped_item_912
     ORDER BY num_pedido, num_sequencia

   OPEN cq_cons

   IF  STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_cons")
       RETURN 
   END IF
   
   FETCH cq_cons INTO m_linha

   IF STATUS <> 0 THEN
      CALL log003_err_sql("FETCH CURSOR","cq_cons")
      RETURN 
   END IF

    IF NOT pol1324_exibe_dados() THEN
       RETURN 
    END IF

    SELECT par_vdp_txt
      INTO m_par_vdp_txt
      FROM par_vdp
     WHERE cod_empresa = mr_detalhe.cod_empresa
   
    IF STATUS <> 0 THEN
       CALL log003_err_sql('Lendo','par_vdp')
    END IF
    
    LET m_cod_transp = m_par_vdp_txt[215,216]

    SELECT par_txt
      INTO m_cod_transp_auto
      FROM par_vdp_pad
     WHERE cod_empresa   = mr_detalhe.cod_empresa
       AND cod_parametro = 'cod_tip_transp_aut'
   
    IF STATUS <> 0 THEN
       CALL log003_err_sql('Lendo','par_vdp_pad')
    END IF
        
    LET m_linhaa = m_linha
 
END FUNCTION

#-----------------------------#
FUNCTION pol1324_exibe_dados()#
#-----------------------------#

   INITIALIZE mr_detalhe TO NULL
   
   INITIALIZE ma_faturar TO NULL
   CALL _ADVPL_set_property(m_brz_fat,"CLEAR")

   SELECT * 
     INTO mr_detalhe.linha,           
          mr_detalhe.cod_empresa,     
          mr_detalhe.cod_item,        
          mr_detalhe.item_cliente,    
          mr_detalhe.num_pedido,      
          mr_detalhe.num_sequencia,   
          mr_detalhe.prz_entrega,     
          mr_detalhe.qtd_pecas_solic, 
          mr_detalhe.qtd_pecas_atend, 
          mr_detalhe.qtd_pecas_cancel,
          mr_detalhe.qtd_pecas_romaneio,
          mr_detalhe.qtd_pecas_reserv,
          mr_detalhe.qtd_saldo,       
          mr_detalhe.cod_cliente,     
          mr_detalhe.nom_cliente
     FROM w_ped_item_912
    WHERE linha = m_linha

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Selecione","w_ped_item_912")
      RETURN FALSE
   END IF
      
   SELECT 
       num_contrato,        
       cod_fabrica,         
       cod_doca,            
       hora,               
       tipo_prg_honda,      
       slip_number_honda,   
       seppen_honda,        
       lote_prod_honda,     
       cpi_honda,        
       observacao_honda,    
       hora_entrega_honda,  
       estoquista
    INTO mr_detalhe.num_contrato,      
         mr_detalhe.cod_fabrica,       
         mr_detalhe.cod_doca,          
         mr_detalhe.hora,              
         mr_detalhe.tipo_prg_honda,    
         mr_detalhe.slip_number_honda, 
         mr_detalhe.seppen_honda,      
         mr_detalhe.lote_prod_honda,   
         mr_detalhe.tbxcpi_honda,         
         mr_detalhe.observacao_honda,  
         mr_detalhe.hora_entrega_honda,
         mr_detalhe.estoquista         
    FROM ped_item_edi
   WHERE cod_empresa = mr_detalhe.cod_empresa    
     AND num_pedido = mr_detalhe.num_pedido
     AND num_sequencia = mr_detalhe.num_sequencia      
   
   IF STATUS = 100 THEN
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Selecione","ped_item_edi")
         RETURN FALSE
      END IF
   END IF

   SELECT 
       xped,                
       nitemped    
    INTO mr_detalhe.xped,
         mr_detalhe.nitemped
    FROM ped_seq_ped_cliente
   WHERE empresa = mr_detalhe.cod_empresa 
     AND pedido = mr_detalhe.num_pedido
     AND seq_item_ped = mr_detalhe.num_sequencia

   IF STATUS = 100 THEN
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Selecione","ped_seq_ped_cliente")
         RETURN FALSE
      END IF
   END IF
    
   SELECT handling          
     INTO mr_detalhe.manuseio
     FROM ped_itens_mgr
   WHERE cod_empresa = mr_detalhe.cod_empresa    
     AND num_pedido = mr_detalhe.num_pedido
     AND num_sequencia = mr_detalhe.num_sequencia      
   
   IF STATUS = 100 THEN
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Selecione","ped_itens_mgr")
         RETURN FALSE
      END IF
   END IF
   

   IF NOT pol1324_le_embalagem() THEN
      RETURN FALSE
   END IF 

   IF NOT pol1324_le_lotes() THEN
      RETURN FALSE
   END IF 
   
   CALL _ADVPL_set_property(m_desc_cli,"TEXT",mr_detalhe.nom_cliente)       
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1324_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")   
   
   LET l_achou = FALSE
   LET m_linhaa = m_linha

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_linha
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_linha
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_linha
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_linha
      END CASE

      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_bar_det,
               "ERROR_TEXT","Não existem mais registros nessa direção.")
         END IF
         LET m_linha = m_linhaa
         EXIT WHILE
      ELSE
         CALL pol1324_exibe_dados() RETURNING l_achou
         EXIT WHILE
      END IF               
   
   END WHILE
   
   RETURN l_achou
   
END FUNCTION

#--------------------------#
FUNCTION pol1324_le_lotes()#
#--------------------------#
   
   DEFINE l_qtd_reservada    DECIMAL(10,3),
          l_num_lote         CHAR(15),
          l_ind              INTEGER,
          l_qtd_fat          INTEGER
   
   INITIALIZE ma_lotes TO NULL
   CALL _ADVPL_set_property(m_brz_lote,"CLEAR")

   IF NOT pol1324_le_item() THEN
      RETURN FALSE
   END IF
      
   IF m_ies_ctr_estoque = 'N' THEN
      RETURN TRUE
   END IF
   
   LET m_query = 
       "SELECT cod_local, num_lote, ies_situa_qtd, qtd_saldo",
       " FROM estoque_lote_ender",
       " WHERE cod_empresa = '",mr_detalhe.cod_empresa,"' ",
       "   AND cod_item = '",mr_detalhe.cod_item,"' "
     
   IF m_ies_ctr_lote = 'S' THEN
      LET m_query = m_query CLIPPED, " AND num_lote IS NOT NULL "
   ELSE
      LET m_query = m_query CLIPPED, " AND num_lote IS NULL  "
   END IF
   
   LET m_query = m_query CLIPPED, " ORDER BY num_lote  "
   
   PREPARE var_lote FROM m_query
    
   IF  STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE","var_lote")
       RETURN FALSE
   END IF

   DECLARE cq_lote CURSOR FOR var_lote

   IF STATUS <> 0 THEN
       CALL log003_err_sql("DECLARE","cq_lote")
       RETURN FALSE
   END IF
   
   LET m_ind = 1
   LET m_saldo_lote = 0
   CALL _ADVPL_set_property(m_brz_lote,"CAN_ADD_ROW",TRUE)
   DELETE FROM lotes_912
     
   FOREACH cq_lote INTO
      ma_lotes[m_ind].cod_local,
      ma_lotes[m_ind].num_lote, 
      ma_lotes[m_ind].ies_tipo, 
      ma_lotes[m_ind].qtd_saldo

      IF STATUS <> 0 THEN
          CALL log003_err_sql("FOREACH","cq_lote")
          RETURN FALSE
      END IF
 
     LET l_num_lote = ma_lotes[m_ind].num_lote
     
     SELECT SUM(qtd_reservada)
       INTO l_qtd_reservada
       FROM estoque_loc_reser
      WHERE cod_empresa = mr_detalhe.cod_empresa
        AND cod_item    = mr_detalhe.cod_item
        AND cod_local   = ma_lotes[m_ind].cod_local
        AND ((num_lote = l_num_lote AND m_ies_ctr_lote =  'S') OR
             (num_lote IS NULL AND m_ies_ctr_lote =  'N'))

      IF STATUS <> 0 THEN
          CALL log003_err_sql("Selecione","estoque_loc_reser:cq_lote")
          RETURN FALSE
      END IF

      IF l_qtd_reservada IS NULL OR l_qtd_reservada < 0 THEN
         LET l_qtd_reservada = 0
      END IF
         
      LET ma_lotes[m_ind].qtd_saldo = ma_lotes[m_ind].qtd_saldo - l_qtd_reservada
      
      IF ma_lotes[m_ind].qtd_saldo <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      {LET l_qtd_fat = _ADVPL_get_property(m_brz_fat,"ITEM_COUNT")
      
      FOR l_ind = 1 TO l_qtd_fat
          IF (l_num_lote = ma_faturar[l_ind].num_lote) OR
             (l_num_lote IS NULL AND ma_faturar[l_ind].num_lote IS NULL) THEN
             LET ma_lotes[m_ind].qtd_saldo = 
                 ma_lotes[m_ind].qtd_saldo - ma_faturar[l_ind].qtd_faturar
          END IF                 
      END FOR

      IF ma_lotes[m_ind].qtd_saldo <= 0 THEN
         CONTINUE FOREACH
      END IF}
      
      LET ma_lotes[m_ind].modificar = 'N'
      LET ma_lotes[m_ind].faturar = 'N'
      
      IF ma_lotes[m_ind].ies_tipo = 'L' THEN
         LET m_saldo_lote = m_saldo_lote + ma_lotes[m_ind].qtd_saldo
      END IF
      
      INSERT INTO lotes_912 VALUES(ma_lotes[m_ind].*)

      IF STATUS <> 0 THEN
          CALL log003_err_sql("INSERT","lotes_912:cq_lote")
          RETURN FALSE
      END IF
            
      LET m_ind = m_ind + 1
      
      IF m_ind > 50 THEN
         LET m_msg = 'Limite de linhas da\n grade ultrapasou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF

   END FOREACH

   IF m_ind > 1 THEN
      LET m_ind = m_ind - 1
      CALL _ADVPL_set_property(m_brz_lote,"ITEM_COUNT", m_ind)
      LET m_tem_lote = TRUE
   ELSE
      LET m_tem_lote = FALSE
   END IF

   CALL _ADVPL_set_property(m_brz_lote,"CAN_ADD_ROW",FALSE)
      
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1324_clasif_lote()#
#-----------------------------#

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1324_le_item()#
#-------------------------#

   SELECT ies_ctr_estoque,
          cod_local_estoq,
          ies_ctr_lote,
          cod_unid_med
     INTO m_ies_ctr_estoque,
          m_local_estoq,
          m_ies_ctr_lote,
          mr_detalhe.cod_unid_med
     FROM item 
    WHERE cod_empresa = mr_detalhe.cod_empresa
      AND cod_item = mr_detalhe.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1324_le_embalagem()#
#------------------------------#
   
   DEFINE l_tipo         CHAR(01)
   
   INITIALIZE mr_embal.* TO NULL

   SELECT cod_tip_venda
     INTO mr_embal.cod_tip_venda
     FROM pedidos
    WHERE cod_empresa = mr_detalhe.cod_empresa
      AND num_pedido = mr_detalhe.num_pedido

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','pedidos')
      RETURN FALSE
   END IF

   SELECT cod_embal, 
          qtd_padr_embal
     INTO mr_embal.cod_embal,
          mr_embal.qtd_padrao
     FROM embal_itaesbra
    WHERE cod_empresa = mr_detalhe.cod_empresa
      AND cod_item = mr_detalhe.cod_item
      AND cod_cliente = mr_detalhe.cod_cliente
      AND cod_tip_venda = mr_embal.cod_tip_venda

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','embal_itaesbra:le')
      RETURN FALSE
   END IF

   LET mr_pcp.cap_embal = mr_embal.qtd_padrao

   SELECT ies_etiqueta_exp,
          den_embal
     INTO l_tipo,
          mr_embal.den_embal
     FROM embalagem
    WHERE cod_embal = mr_embal.cod_embal
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','embalagem')
      RETURN FALSE
   END IF
 
   IF l_tipo = 'N' THEN
      LET mr_embal.tipo = l_tipo, ' - ', 'NORMAL'
   ELSE
      LET mr_embal.tipo = l_tipo, ' - ', 'INTERNA'
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1324_sel_lote()#
#--------------------------#

   DEFINE l_lin_atu       INTEGER,
          l_qtd_lote      CHAR(10),
          l_qtd_fat       INTEGER
   
   CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",'')

   LET l_lin_atu = _ADVPL_get_property(m_brz_lote,"ROW_SELECTED")   
   LET l_qtd_fat = _ADVPL_get_property(m_brz_fat,"ITEM_COUNT")

   IF l_qtd_fat > 0 THEN
      LET m_msg = 'Você já selecionou o lote a faturar'
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      LET ma_lotes[l_lin_atu].modificar = 'N'
      RETURN FALSE
   END IF

   IF ma_lotes[l_lin_atu].modificar = 'N' THEN
      LET m_tot_sel = m_tot_sel - ma_lotes[l_lin_atu].qtd_saldo
      LET l_qtd_lote = m_tot_sel
      CALL _ADVPL_set_property(m_qtd_sel,"TEXT",l_qtd_lote)  
      DELETE FROM lote_sel_912 WHERE num_lote = ma_lotes[l_lin_atu].num_lote
      LET m_sdo_sel = pol1324_soma_lote()
      RETURN TRUE
   END IF

   IF mr_pcp.qtd_faturar <= 0 THEN
      LET m_msg = 'Informe a quantidade a faturar'
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      LET ma_lotes[l_lin_atu].modificar = 'N'
      CALL _ADVPL_set_property(m_faturar,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF m_sdo_sel >= mr_pcp.qtd_faturar THEN
      LET m_msg = 'Você já selecionou lotes suficientes'
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      LET ma_lotes[l_lin_atu].modificar = 'N'
      RETURN FALSE
   END IF

   {IF m_ies_ctr_lote = 'N' THEN
      LET m_msg = 'Item não controla lote - modificação não permitida.'
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      LET ma_lotes[l_lin_atu].modificar = 'N'
      RETURN FALSE
   END IF}

   IF ma_lotes[l_lin_atu].ies_tipo = 'L' THEN
   ELSE
      LET m_msg = 'Somente lote tipo L pode ser utilizado.'
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      LET ma_lotes[l_lin_atu].modificar = 'N'
      RETURN FALSE
   END IF

   IF NOT pol1324_le_item() THEN
      RETURN FALSE
   END IF
   
   IF ma_lotes[l_lin_atu].cod_local <> m_local_estoq THEN
      LET m_msg = 'Somente lote do local ',
           m_local_estoq CLIPPED,' pode ser utilizado.'
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      LET ma_lotes[l_lin_atu].modificar = 'N'
      RETURN FALSE
   END IF
   
   LET m_num_lote = ma_lotes[l_lin_atu].num_lote
   LET m_tot_sel = m_tot_sel + ma_lotes[l_lin_atu].qtd_saldo
   LET m_qtd_saldo = ma_lotes[l_lin_atu].qtd_saldo
   LET l_qtd_lote = m_tot_sel
   CALL _ADVPL_set_property(m_qtd_sel,"TEXT",l_qtd_lote)  
   
   IF NOT pol1324_ins_lot_tmp() THEN
      LET ma_lotes[l_lin_atu].modificar = 'N'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1324_ins_lot_tmp()#
#-----------------------------#
   
   LET m_num_seq = m_num_seq + 1
   
   INSERT INTO lote_sel_912
    VALUES(m_num_lote, m_qtd_saldo, m_num_seq)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','lote_sel_912')
      RETURN FALSE
   END IF
   
   LET m_sdo_sel = pol1324_soma_lote()
    
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1324_soma_lote()#
#---------------------------#

   DEFINE l_saldo      DECIMAL(10,3)

   SELECT SUM(qtd_lote)
     INTO l_saldo
     FROM lote_sel_912

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELEÇÃO','lote_sel_912')
      LET l_saldo = 0
   END IF
   
   IF l_saldo IS NULL THEN
      LET l_saldo = 0
   END IF
   
   RETURN l_saldo

END FUNCTION

#---------------------------#
FUNCTION pol1324_gera_lote()#
#---------------------------#
   
   DEFINE l_lote      CHAR(15)
   
   SELECT COUNT(*)
     INTO m_count
     FROM cliente_lote_912
    WHERE cod_cliente = mr_detalhe.cod_cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cliente_lote_912')
      RETURN FALSE
   END IF   
   
   LET m_count = m_count + 1
   LET l_lote = m_count
   LET mr_lote.num_lote = mr_detalhe.cod_cliente[1,4] 
   LET mr_lote.num_lote = mr_lote.num_lote CLIPPED,'-',l_lote CLIPPED
   
   IF NOT pol1324_novo_lote() THEN
      RETURN FALSE
   END IF      
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1324_add_lote_fat()#
#------------------------------#

   DEFINE l_qtd_etiqueta    INTEGER,
          l_ind             INTEGER

   LET l_ind = _ADVPL_get_property(m_brz_fat,"ITEM_COUNT")
   LET l_ind = l_ind + 1
   
   LET ma_faturar[l_ind].num_lote = m_num_lote
   LET ma_faturar[l_ind].num_pedido = mr_detalhe.num_pedido
   LET ma_faturar[l_ind].num_sequencia = mr_detalhe.num_sequencia
   LET ma_faturar[l_ind].qtd_faturar = mr_pcp.qtd_faturar
   LET ma_faturar[l_ind].excluir = 'N'
      
   LET l_qtd_etiqueta = mr_pcp.qtd_faturar / mr_embal.qtd_padrao
   
   IF ( mr_pcp.qtd_faturar MOD mr_embal.qtd_padrao ) > 0 THEN
      LET l_qtd_etiqueta = l_qtd_etiqueta + 1
   END IF
   
   LET ma_faturar[l_ind].qtd_etiqueta = l_qtd_etiqueta
   LET m_sel_lote = TRUE
                     
   CALL _ADVPL_set_property(m_brz_fat,"SET_ROWS",ma_faturar,l_ind)   
   
END FUNCTION

#---------------------------#
FUNCTION pol1324_novo_lote()#
#---------------------------#
   
   DEFINE l_seq, l_ind      INTEGER,
          l_qtd_faturar     DECIMAL(10,3),
          l_qtd_saldo       DECIMAL(10,3),
          l_sobra_lote      DECIMAL(10,3)
          
   LET l_qtd_faturar = mr_pcp.qtd_faturar          

   SELECT par_txt 
     INTO m_cod_oper_trans
     FROM par_sup_pad 
    WHERE cod_empresa = mr_detalhe.cod_empresa
      AND cod_parametro = 'operac_est_sup879'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','par_sup_pad')
      RETURN FALSE
   END IF
   
   BEGIN WORK

   #LET l_lote = _ADVPL_get_property(m_brz_lote,"ITEM_COUNT")

   DECLARE cq_gra CURSOR FOR
    SELECT num_lote, qtd_lote, num_seq
      FROM lote_sel_912
     ORDER BY num_seq
   
   FOREACH cq_gra INTO m_num_lote, l_qtd_saldo, l_seq

      IF l_qtd_saldo > l_qtd_faturar THEN
         LET l_sobra_lote = l_qtd_saldo - l_qtd_faturar
         LET m_qtd_saldo = l_qtd_faturar
         LET l_qtd_faturar = 0
      ELSE
         LET m_qtd_saldo = l_qtd_saldo
         LET l_qtd_faturar = l_qtd_faturar - m_qtd_saldo
         LET l_sobra_lote = 0
      END IF          
      
      IF NOT pol1324_grava_lote() THEN
         ROLLBACK WORK
         RETURN FALSE
      END IF

      IF l_sobra_lote > 0 THEN
         IF NOT pol1324_grava_etiq(m_num_lote, l_sobra_lote) THEN
            ROLLBACK WORK
            RETURN FALSE
         END IF
      END IF
            
      IF l_qtd_faturar <= 0 THEN
         EXIT FOREACH
      END IF

   END FOREACH
   
   INSERT INTO cliente_lote_912
    VALUES(mr_detalhe.cod_cliente, mr_lote.num_lote)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','cliente_lote_912')
      RETURN FALSE
   END IF   

   COMMIT WORK

   LET p_status = pol1324_le_lotes()
   LET m_num_lote = mr_lote.num_lote
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1324_grava_lote()#
#----------------------------#
     
   DEFINE lr_item      RECORD
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote_orig LIKE estoque_lote.num_lote,
         num_lote_dest LIKE estoque_lote.num_lote,
         ies_situa_qtd LIKE estoque_lote.ies_situa_qtd,
         qtd_saldo     LIKE estoque_lote.qtd_saldo,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         num_programa  CHAR(08),
         opcao         CHAR(01),
         cod_operacao  CHAR(04)
   END RECORD
               
   LET lr_item.cod_empresa   = mr_detalhe.cod_empresa
   LET lr_item.cod_item      = mr_detalhe.cod_item
   LET lr_item.cod_local     = m_local_estoq
   LET lr_item.num_lote_orig = m_num_lote
   LET lr_item.num_lote_dest = mr_lote.num_lote
   LET lr_item.ies_situa_qtd = 'L'   
   LET lr_item.qtd_saldo     = m_qtd_saldo  
   LET lr_item.comprimento   = 0
   LET lr_item.largura       = 0    
   LET lr_item.altura        = 0     
   LET lr_item.diametro      = 0         
   LET lr_item.num_programa  = 'POL1324'
   
   LET lr_item.cod_operacao = m_cod_oper_trans
      
   LET g_msg = NULL

   IF NOT func013_transf_lote(lr_item) THEN
      IF g_msg IS NOT NULL THEN
         CALL log0030_mensagem(g_msg,'info')
      END IF       
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------------------#
FUNCTION pol1324_grava_etiq(l_lote, l_sobra)#
#-------------------------------------------#
   
   DEFINE l_lote             CHAR(15),
          l_sobra            DECIMAL(10,3)

   INITIALIZE mr_ficha.* TO NULL

   LET mr_ficha.id_registro = 0
   LET mr_ficha.cod_empresa = mr_detalhe.cod_empresa    
   LET mr_ficha.cod_item =  mr_detalhe.cod_item   
   LET mr_ficha.cod_item_cliente = mr_detalhe.item_cliente
   LET mr_ficha.data  = TODAY          
   LET mr_ficha.rastro = l_lote        
   LET mr_ficha.ies_impresso ='N'
   LET mr_ficha.quantidade = l_sobra
         
   SELECT num_seq,           
          num_sub_seq,
          opprox,     
          setatual,   
          setprox    
     INTO mr_ficha.num_seq,    
          mr_ficha.num_sub_seq,
          mr_ficha.opprox,     
          mr_ficha.setatual,   
          mr_ficha.setprox    
     FROM ciclo_peca_970
    WHERE cod_empresa = mr_detalhe.cod_empresa
      AND cod_item = mr_detalhe.cod_item 

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('SELECT','ciclo_peca_970')
      RETURN FALSE
   END IF
   
   DELETE FROM ficha_cacamba_970
    WHERE cod_empresa = mr_detalhe.cod_empresa
      AND cod_item = mr_detalhe.cod_item
      AND rastro = l_lote

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('DELETE','ficha_cacamba_970')
      RETURN FALSE
   END IF    
    
   INSERT INTO ficha_cacamba_970(
     {id_registro,}    
     cod_empresa,      
     cod_item,         
     cod_item_cliente, 
     rua,   			      
     vao, 			        
     data,             
     rastro,           
     observacao,    	  
     num_seq,          
     num_sub_seq,      
     opprox,           
     setatual,         
     setprox,          
     ies_impresso,     
     numero_copias,  	
     quantidade)       
    VALUES(
       {mr_ficha.id_registro,}       
       mr_ficha.cod_empresa,       
       mr_ficha.cod_item,          
       mr_ficha.cod_item_cliente,  
       mr_ficha.rua,   			       
       mr_ficha.vao, 			         
       mr_ficha.data,              
       mr_ficha.rastro,            
       mr_ficha.observacao,    	   
       mr_ficha.num_seq,           
       mr_ficha.num_sub_seq,       
       mr_ficha.opprox,            
       mr_ficha.setatual,          
       mr_ficha.setprox,           
       mr_ficha.ies_impresso,      
       mr_ficha.numero_copias,  	 
       mr_ficha.quantidade)        

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('INSERT','ficha_cacamba_970')
      RETURN FALSE
   END IF
       
   RETURN TRUE
     
END FUNCTION

#--------------------------#   
FUNCTION pol1324_exc_lote()#
#--------------------------#

   DEFINE l_lin_atu       INTEGER,
          l_ind           INTEGER
      
   LET l_lin_atu = _ADVPL_get_property(m_brz_fat,"ROW_SELECTED")
   
   DELETE FROM lote_fat_912
    WHERE num_lote = ma_faturar[l_lin_atu].num_lote

   DELETE FROM lote_sel_912
    WHERE num_lote = ma_faturar[l_lin_atu].num_lote
        
   LET m_sdo_sel = pol1324_soma_lote()
   CALL _ADVPL_set_property(m_brz_fat,"REMOVE_ROW",l_lin_atu)

   IF m_sdo_sel <= 0 THEN
      LET m_sel_lote = FALSE
   END IF
            
   RETURN TRUE

END FUNCTION

#----------------------------#  
FUNCTION pol1324_conf_lotes()#
#----------------------------#
   
   DEFINE l_ind          INTEGER,
          l_lote         INTEGER,
          l_qtd_saldo    DECIMAL(10,3),
          l_qtd_fat      INTEGER,
          l_qtd_lote     CHAR(10),
          l_lin_atu      INTEGER

   LET l_lin_atu = _ADVPL_get_property(m_brz_lote,"ROW_SELECTED")   

   IF NOT m_tem_lote  THEN
      LET m_msg = 'Não há lotes em estoque para faturar'
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_faturar,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_pcp.qtd_faturar <= 0 THEN
      LET m_msg = 'Informe a quantidade a faturar.'
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_faturar,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF m_gerou_om THEN
      LET m_msg = 'Você já gerou a OM ',m_num_om
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET l_qtd_fat = _ADVPL_get_property(m_brz_fat,"ITEM_COUNT")

   IF l_qtd_fat > 0 THEN
      LET m_msg = 'Você já selecionou o lote a faturar'
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      LET ma_lotes[l_lin_atu].modificar = 'N'
      RETURN FALSE
   END IF

   LET l_lote = _ADVPL_get_property(m_brz_lote,"ITEM_COUNT")
   LET l_qtd_saldo = 0

   FOR l_ind = 1 TO l_lote
       IF ma_lotes[l_ind].modificar = 'S' THEN
          LET l_qtd_saldo = l_qtd_saldo + ma_lotes[l_ind].qtd_saldo
          LET m_num_lote = ma_lotes[l_ind].num_lote
       END IF
   END FOR
   
   IF l_qtd_saldo < mr_pcp.qtd_faturar THEN
      LET m_msg = 'Saldo dos lotes selecionados é\n inferior à quantidade a faturar.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   IF m_ies_ctr_lote = 'S' THEN
      IF NOT pol1324_gera_lote() THEN
         RETURN FALSE
      END IF
      LET m_tot_sel = 0
      LET l_qtd_lote = m_tot_sel
      CALL _ADVPL_set_property(m_qtd_sel,"TEXT",l_qtd_lote)  
   ELSE 
      LET m_num_lote = NULL
   END IF
   
   CALL pol1324_add_lote_fat()
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1324_sair_det()#
#--------------------------#
   
   IF NOT m_gerou_om AND mr_pcp.qtd_faturar > 0 THEN
      LET m_msg = 'Descartar a montagem da carga ?'
      IF NOT LOG_question(m_msg) THEN
         RETURN FALSE
      END IF
   END IF

   DELETE FROM ped_item_sel_912
    WHERE usuario = p_user
      
   RETURN TRUE

END FUNCTION
   
#-----------------------#
FUNCTION pol1324_gerar()#
#-----------------------#
      
   IF m_gerou_om THEN
      LET m_msg = 'Você já gerou a OM ',m_num_om
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF m_cod_transp IS NULL THEN
      LET m_msg = 'Informe o Transportador.'
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_transpor,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF NOT m_sel_lote THEN
      LET m_msg = 'Selecione um lote previamente.'
      CALL _ADVPL_set_property(m_bar_det,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF     
   
   IF m_qtd_item > m_qtd_next THEN
      LET m_msg = 'Há pedido/item sem definição de lotes.\n',
                  'Deseja gerar o romaneio mesmo assim ?'
   ELSE
      LET m_msg = 'Deseja mesmo gerar o romaneio agora ?'
   END IF

   IF NOT LOG_question(m_msg) THEN
      RETURN FALSE
   END IF

   LET g_msg = 'Romaneio gerado: '
   LET m_houve_erro = TRUE
   
   CALL LOG_progresspopup_start("Gerando romaneios...","pol1324_processa","PROCESS")
   
   IF m_houve_erro THEN
      LET g_msg = 'Operação cancelada!'
   ELSE
      LET m_gerou_om = TRUE
      LET mr_pcp.num_om = m_num_om
      LET mr_pcp.num_lote_om = m_lote_om
      LET mr_detalhe.qtd_pecas_romaneio = mr_detalhe.qtd_pecas_romaneio + mr_pcp.qtd_faturar
      LET mr_detalhe.qtd_saldo = mr_detalhe.qtd_saldo - mr_pcp.qtd_faturar   
      LET g_msg = g_msg CLIPPED,'\n','Num lote OM: ',m_lote_om
   END IF
   
   CALL log0030_mensagem(g_msg,'info')
   
   SELECT cod_cliente
     FROM client_dev_mat_912
    WHERE cod_cliente = mr_detalhe.cod_cliente
   
   IF STATUS = 0 THEN
      CALL LOG_transaction_begin()
      IF pol1324_devolv_mat() THEN
         CALL LOG_transaction_commit()
         LET m_msg = 'A devolução de material também\n foi gerada com sucesso.'
      ELSE
         CALL LOG_transaction_rollback()
         LET m_msg = 'Não foi possivel gerar a devolução do material.\n',
                     'Utilize o pol0440 para essa finalidade.'
      END IF
      CALL log0030_mensagem(m_msg,'info')
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1324_processa()#
#--------------------------#
   
   DEFINE l_lote, l_ind    INTEGER
   
   LET l_lote = _ADVPL_get_property(m_brz_fat,"ITEM_COUNT")
   
   DELETE FROM lote_fat_912
   
   FOR l_ind = 1 TO l_lote
      INSERT INTO lote_fat_912
       VALUES(mr_detalhe.cod_empresa,
              mr_detalhe.cod_cliente,
              mr_detalhe.num_pedido,
              mr_detalhe.num_sequencia,
              mr_detalhe.cod_item,
              ma_faturar[l_ind].num_lote,
              m_local_estoq,
              ma_faturar[l_ind].qtd_faturar,
              ma_faturar[l_ind].qtd_etiqueta)
              
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','lote_fat_912')
         RETURN
      END IF
      
   END FOR
   
   SELECT COUNT(num_pedido) 
     INTO m_bar_prog
     FROM lote_fat_912

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','lote_fat_912:pedido')
      RETURN
   END IF
   
   LET m_bar_prog = m_bar_prog * 12
   
   BEGIN WORK
   
   IF NOT pol1324_ger_oms() THEN
      ROLLBACK WORK
   ELSE
      COMMIT WORK
      LET m_houve_erro = FALSE
   END IF

END FUNCTION

#---------------------------#
FUNCTION pol1324_ins_carga()#
#---------------------------#

   SELECT MAX(num_carga)
     INTO m_num_carga
     FROM carga_mestre_912
    WHERE cod_empresa = m_cod_empresa
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','carga_mestre_912:num_carga')
      RETURN FALSE
   END IF
   
   IF m_num_carga IS NULL THEN
      LET m_num_carga = 0
   END IF

   LET m_num_carga = m_num_carga + 1
   LET m_ies_roma = 'S'

   INSERT INTO carga_mestre_912
    VALUES(m_cod_empresa,
           m_num_carga,
           m_dat_atu,
           p_user,
           m_ies_imp,
           m_ies_roma)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','carga_mestre_912')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1324_ger_oms()#
#-------------------------#

   DEFINE l_progres   SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",m_bar_prog)

   DECLARE cq_empresa CURSOR FOR
    SELECT DISTINCT cod_empresa
      FROM lote_fat_912

   FOREACH cq_empresa INTO m_cod_empresa

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','m_cod_empresa')
         RETURN FALSE
      END IF

      IF NOT pol1324_ins_carga() THEN
         RETURN FALSE
      END IF
            
      IF NOT pol1324_le_pedidos() THEN
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION
       
#----------------------------#       
FUNCTION pol1324_le_pedidos()#
#----------------------------#         

   DEFINE l_progres   SMALLINT
         
   DECLARE cq_pedido CURSOR FOR
    SELECT DISTINCT num_pedido
      FROM lote_fat_912
     WHERE cod_empresa = m_cod_empresa
     ORDER BY num_pedido
   
   FOREACH cq_pedido INTO m_num_pedido
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_pedido')
         RETURN FALSE
      END IF
      
      SELECT cod_cliente,
             cod_tip_carteira
        INTO m_cod_cliente,
             m_cod_tip_carteira
        FROM pedidos
       WHERE cod_empresa = m_cod_empresa
         AND num_pedido = m_num_pedido
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','pedidos:cq_pedido')
         RETURN FALSE
      END IF

      IF NOT pol1324_prox_num() THEN
         RETURN FALSE
      END IF
      
      LET m_texto = m_num_om
      LET g_msg = g_msg CLIPPED, m_texto CLIPPED, '\n'

      DECLARE cq_itens CURSOR FOR
       SELECT num_sequencia,
              cod_item,
              SUM(qtd_faturar)
         FROM lote_fat_912
        WHERE cod_empresa = m_cod_empresa
          AND num_pedido = m_num_pedido
        GROUP BY num_sequencia, cod_item
        ORDER BY num_sequencia
       
      FOREACH cq_itens INTO m_num_seq, m_cod_item, m_qtd_faturar
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_itens')
            RETURN FALSE
         END IF

         LET l_progres = LOG_progresspopup_increment("PROCESS")  
  
         IF NOT pol1324_ped_sem_sdo() THEN
            RETURN FALSE
         END IF
         
         IF NOT pol1324_ins_om() THEN
            RETURN FALSE
         END IF
         
      END FOREACH
      
      IF NOT pol1324_om_mest() THEN
         RETURN FALSE
      END IF
            
   END FOREACH

   LET l_progres = LOG_progresspopup_increment("PROCESS")  
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1324_prox_num()#
#--------------------------#

   DEFINE l_par_vdp_txt   LIKE par_vdp.par_vdp_txt
   
   DEFINE l_lote_om    CHAR(05)

   SELECT par_vdp_txt                         
     INTO l_par_vdp_txt                                    
     FROM par_vdp                                              
    WHERE cod_empresa = m_cod_empresa                          

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
    WHERE cod_empresa = m_cod_empresa                          
      
   IF STATUS <> 0 THEN                                  
      CALL log003_err_sql("ALTERACAO","PAR_VDP")               
      RETURN FALSE                       
   END IF                                                      

   SELECT num_ult_om
     INTO m_num_om
     FROM par_vdp
    WHERE cod_empresa = m_cod_empresa

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
    WHERE cod_empresa = m_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('atualizando','par_vdp')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1324_ped_sem_sdo()#
#-----------------------------#

   DEFINE l_sdo_ped     DECIMAL(10,3)
   
   SELECT (qtd_pecas_solic - qtd_pecas_cancel - qtd_pecas_atend -
           qtd_pecas_reserv - qtd_pecas_romaneio)
     INTO l_sdo_ped
     FROM ped_itens
    WHERE cod_empresa = m_cod_empresa
      AND num_pedido = m_num_pedido
      AND num_sequencia = m_num_seq

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ped_itens')
      RETURN FALSE
   END IF
   
   IF l_sdo_ped < m_qtd_faturar THEN
      LET m_msg = 'Pedido: ',m_num_pedido,'\n',
                  'Item: ',m_cod_item,'\n',
                  'Sem saldo p/ faturar'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1324_ins_om()#
#------------------------#

   IF NOT pol1324_embalagem() THEN
      RETURN FALSE
   END IF

   IF NOT pol1324_om_item() THEN
      RETURN FALSE
   END IF

   IF NOT pol1324_reserva() THEN
      RETURN FALSE
   END IF
      
   IF NOT pol1324_atu_saldos() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1324_embalagem()#
#---------------------------#

   DEFINE l_om_embal          RECORD LIKE ordem_montag_embal.*,
          l_cod_embal_matriz  LIKE embalagem.cod_embal_matriz,
          l_cod_embal_int     LIKE item_embalagem.cod_embal,
          l_cod_embal_ext     LIKE item_embalagem.cod_embal,
          l_qtd_volume        LIKE ordem_montag_item.qtd_volume_item,
		      l_qtd_emb_int       LIKE ordem_montag_embal.qtd_embal_int,
		      l_qtd_emb_ext       LIKE ordem_montag_embal.qtd_embal_ext,
          l_qtd_volume_int    INTEGER,
          l_qtd_volume_ext    INTEGER,
          l_qtd_vol           CHAR(10),
          l_resto             INTEGER
          
   {SELECT qtd_padr_embal,                                                    
          cod_embal                                                             
     INTO l_qtd_emb_int,                                                     
          l_cod_embal_int                                                       
     FROM embal_itaesbra                                                        
    WHERE cod_empresa   = m_cod_empresa                                         
      AND cod_cliente   = m_cod_cliente                                
      AND cod_item      = m_cod_item                              
      AND cod_tip_venda = mr_embal.cod_tip_venda                                       
      AND ies_tip_embal = 'N'                                                   
                                                                             
   IF STATUS = 100 THEN                                                         
      SELECT l_qtd_emb_int,                                                    
             cod_embal                                                          
        INTO l_qtd_emb_int,                                                  
             l_cod_embal_int                                                    
        FROM embal_itaesbra                                                     
       WHERE cod_empresa   = m_cod_empresa                                      
         AND cod_cliente   = m_cod_cliente                             
         AND cod_item      = m_cod_item                           
         AND cod_tip_venda = mr_embal.cod_tip_venda                                    
         AND ies_tip_embal = 'I'                                                
   END IF                                                                   
                                                                             
   IF STATUS <> 0 THEN                                                         
      CALL log003_err_sql('SELECT','embal_itaesbra:N/I')
      RETURN FALSE
   END IF

   IF l_qtd_emb_int > 0 THEN                                                 
      LET l_qtd_volume_int = m_qtd_faturar / l_qtd_emb_int    
      LET l_resto = m_qtd_faturar MOD l_qtd_emb_int           
      IF l_resto > 0 THEN                                                       
         LET l_qtd_volume_int = l_qtd_volume_int + 1                            
      END IF      
      LET m_qtd_volume_int = l_qtd_volume_int                                                              
	 ELSE	                                                                        
	    LET m_qtd_volume_int = 0                                                  
   END IF                                                                       
   
   }      
   
   LET l_cod_embal_int = mr_embal.cod_embal
   LET l_qtd_emb_int = mr_pcp.cap_embal
   LET m_qtd_volume_int = mr_pcp.qtd_etiqueta

   SELECT qtd_padr_embal,                                                    
          cod_embal                                                             
     INTO l_qtd_emb_ext,                                                     
          l_cod_embal_ext                                                       
     FROM embal_itaesbra                                                        
    WHERE cod_empresa   = m_cod_empresa                                         
      AND cod_cliente   = m_cod_cliente                                
      AND cod_item      = m_cod_item                              
      AND cod_tip_venda = mr_embal.cod_tip_venda                                       
      AND ies_tip_embal = 'C'                                                   
                                                                             
   IF STATUS = 100 THEN                                                         
      SELECT qtd_padr_embal,                                                    
             cod_embal                                                          
        INTO l_qtd_emb_ext,                                                  
             l_cod_embal_ext                                                    
        FROM embal_itaesbra                                                     
       WHERE cod_empresa   = m_cod_empresa                                      
         AND cod_cliente   = m_cod_cliente                             
         AND cod_item      = m_cod_item                           
         AND cod_tip_venda = mr_embal.cod_tip_venda                                    
         AND ies_tip_embal = 'E'                                                
   END IF                                                                       
                                                                                                                                                          
   IF STATUS = 100 THEN                                                         
      LET l_cod_embal_ext = NULL                                                  
      LET l_qtd_emb_ext = 0                                               
   ELSE            
      IF STATUS <> 0 THEN                                                         
         CALL log003_err_sql('SELECT','embal_itaesbra:C/E')
         RETURN FALSE
      END IF      
   END IF

   IF l_cod_embal_ext IS NOT NULL THEN
      LET l_cod_embal_matriz = NULL                                          
   
      SELECT cod_embal_matriz                                                
        INTO l_cod_embal_matriz                                              
        FROM embalagem                                                       
       WHERE cod_embal = l_cod_embal_ext                                     
   
      IF l_cod_embal_matriz IS NOT NULL THEN                                 
         LET l_cod_embal_ext = l_cod_embal_matriz                            
      END IF                                                                 
   END IF                                                                          
                                                                             
   IF l_qtd_emb_ext > 0 THEN                                                  
      LET l_qtd_volume_ext = m_qtd_faturar / l_qtd_emb_ext     
      LET l_resto = m_qtd_faturar MOD l_qtd_emb_ext            
      IF l_resto > 0 THEN                                                       
         LET l_qtd_volume_ext = l_qtd_volume_ext + 1                            
      END IF                                                                    
      LET m_qtd_volume_ext  = l_qtd_volume_ext                                      
	 ELSE	                                                                        
	    LET m_qtd_volume_ext = 0                                                  
   END IF                                                                       
                                                                             
   LET m_tot_volume = m_qtd_volume_int + m_qtd_volume_ext
                                                                                
   LET l_om_embal.cod_empresa = m_cod_empresa
   LET l_om_embal.num_om = m_num_om
   LET l_om_embal.num_sequencia = 1
   LET l_om_embal.cod_item = m_cod_item
   LET l_om_embal.cod_embal_int = l_cod_embal_int
   LET l_om_embal.qtd_embal_int = m_qtd_volume_int
   LET l_om_embal.cod_embal_ext = l_cod_embal_ext
   LET l_om_embal.qtd_embal_ext = m_qtd_volume_ext   
   LET l_om_embal.ies_lotacao = 'T'
   LET l_om_embal.num_embal_inicio = 1
   LET l_om_embal.num_embal_final = 1
   LET l_om_embal.qtd_pecas = m_qtd_faturar
   
   SELECT COUNT(cod_empresa)
     INTO m_count
     FROM ordem_montag_embal
    WHERE cod_empresa = m_cod_empresa
      AND num_om = m_num_om
      AND cod_item = m_cod_item
      AND cod_embal_int = l_om_embal.cod_embal_int
      AND cod_embal_ext = l_om_embal.cod_embal_ext

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordem_montag_embal')
      RETURN FALSE
   END IF
   
   IF m_count > 0 THEN
      UPDATE ordem_montag_embal
         SET qtd_embal_int = qtd_embal_int + l_om_embal.qtd_embal_int,
             qtd_embal_ext = qtd_embal_ext + l_om_embal.qtd_embal_ext,
             qtd_pecas = qtd_pecas + l_om_embal.qtd_pecas
       WHERE cod_empresa = m_cod_empresa
         AND num_om = m_num_om
         AND cod_item = m_cod_item
         AND cod_embal_int = l_om_embal.cod_embal_int
         AND cod_embal_ext = l_om_embal.cod_embal_ext

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','ordem_montag_embal')
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   INSERT INTO ordem_montag_embal(
      cod_empresa,     
      num_om,          
      num_sequencia,   
      cod_item,        
      cod_embal_int,   
      qtd_embal_int,   
      cod_embal_ext,   
      qtd_embal_ext,   
      ies_lotacao,     
      num_embal_inicio,
      num_embal_final, 
      qtd_pecas) VALUES(l_om_embal.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ordem_montag_embal')
      RETURN FALSE
   END IF          

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1324_om_item()#
#-------------------------#

   DEFINE l_om_item RECORD LIKE ordem_montag_item.*
   
   IF NOT pol1324_le_peso_item() THEN
      RETURN FALSE
   END IF
   
   IF m_tot_volume = 0 THEN
      LET m_tot_volume = m_qtd_faturar
   END IF
   
   LET l_om_item.cod_empresa = m_cod_empresa    
   LET l_om_item.num_om = m_num_om
   LET l_om_item.num_pedido = m_num_pedido
   LET l_om_item.num_sequencia = m_num_seq  
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

#------------------------------#
FUNCTION pol1324_le_peso_item()#
#------------------------------#
   
   SELECT pes_unit,
          ies_ctr_lote,
          cod_local_estoq
     INTO m_peso_unit,
          m_ies_ctr_lote,
          m_local_estoq 
     FROM item
    WHERE cod_empresa = m_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item.pes_item')
      RETURN FALSE
   END IF          

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1324_reserva()#
#-------------------------#

   DECLARE cq_reserva CURSOR FOR
    SELECT num_lote, 
           qtd_faturar,
           qtd_etiqueta
      FROM lote_fat_912
     WHERE cod_empresa = m_cod_empresa
       AND cod_item = m_cod_item
       AND num_pedido = m_num_pedido
       AND num_sequencia = m_num_seq
   
   FOREACH cq_reserva 
      INTO m_num_lote, m_qtd_lote, m_qtd_etiqueta
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_reserva')
         RETURN FALSE
      END IF
      
      IF NOT pol1324_chec_estoq() THEN
         RETURN FALSE
      END IF

      IF NOT pol1324_ins_reserva() THEN
         RETURN FALSE
      END IF
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1324_chec_estoq()#
#----------------------------#

   DEFINE l_msg        CHAR(300)
   
   SELECT * 
     INTO m_lote_ender.*
     FROM estoque_lote_ender
    WHERE cod_empresa = m_cod_empresa
      AND cod_item = m_cod_item
      AND cod_local= m_local_estoq
      AND ies_situa_qtd = 'L'
      AND ((num_lote = m_num_lote AND m_ies_ctr_lote = 'S') OR
           (num_lote IS NULL AND m_ies_ctr_lote = 'N'))

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_lote_ender')
      RETURN FALSE
   END IF
      
   IF NOT pol1324_le_reservas() THEN
      RETURN FALSE
   END IF

   LET m_lote_ender.qtd_saldo = 
       m_lote_ender.qtd_saldo - m_qtd_reservada
    
   IF m_lote_ender.qtd_saldo < m_qtd_lote THEN
      LET l_msg = 
          'Tabela: estoque_lote_ender \n',
          'Empresa ',m_cod_empresa,'\n',
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
FUNCTION pol1324_le_reservas()#
#-----------------------------#     
            
   SELECT SUM(qtd_reservada)
     INTO m_qtd_reservada
     FROM estoque_loc_reser
    WHERE cod_empresa = m_cod_empresa
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
FUNCTION pol1324_ins_reserva()#
#-----------------------------#
   
   DEFINE l_est_loc     RECORD LIKE est_loc_reser_end.*,
          l_estoque_loc RECORD LIKE estoque_loc_reser.*
   
   DEFINE l_num_reserva INTEGER
      
   LET l_estoque_loc.num_reserva = 0

   LET l_estoque_loc.cod_empresa     = m_lote_ender.cod_empresa      
   LET l_estoque_loc.cod_item        = m_lote_ender.cod_item         
   LET l_estoque_loc.cod_local       = m_lote_ender.cod_local        
   LET l_estoque_loc.qtd_reservada   = m_qtd_lote                 
   LET l_estoque_loc.num_lote        = m_lote_ender.num_lote         
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
     
   LET l_est_loc.cod_empresa     = m_lote_ender.cod_empresa     
   LET l_est_loc.num_reserva     = l_num_reserva        
   LET l_est_loc.endereco        = m_lote_ender.endereco        
   LET l_est_loc.num_volume      = m_lote_ender.num_volume      
   LET l_est_loc.cod_grade_1     = m_lote_ender.cod_grade_1     
   LET l_est_loc.cod_grade_2     = m_lote_ender.cod_grade_2     
   LET l_est_loc.cod_grade_3     = m_lote_ender.cod_grade_3     
   LET l_est_loc.cod_grade_4     = m_lote_ender.cod_grade_4     
   LET l_est_loc.cod_grade_5     = m_lote_ender.cod_grade_5     
   LET l_est_loc.dat_hor_producao= m_lote_ender.dat_hor_producao
   LET l_est_loc.num_ped_ven     = m_lote_ender.num_ped_ven     
   LET l_est_loc.num_seq_ped_ven = m_lote_ender.num_seq_ped_ven 
   LET l_est_loc.dat_hor_validade= m_lote_ender.dat_hor_validade
   LET l_est_loc.num_peca        = m_lote_ender.num_peca        
   LET l_est_loc.num_serie       = m_lote_ender.num_serie       
   LET l_est_loc.comprimento     = m_lote_ender.comprimento     
   LET l_est_loc.largura         = m_lote_ender.largura         
   LET l_est_loc.altura          = m_lote_ender.altura          
   LET l_est_loc.diametro        = m_lote_ender.diametro        
   LET l_est_loc.dat_hor_reserv_1= m_lote_ender.dat_hor_reserv_1
   LET l_est_loc.dat_hor_reserv_2= m_lote_ender.dat_hor_reserv_2
   LET l_est_loc.dat_hor_reserv_3= m_lote_ender.dat_hor_reserv_3
   LET l_est_loc.qtd_reserv_1    = m_lote_ender.qtd_reserv_1    
   LET l_est_loc.qtd_reserv_2    = m_lote_ender.qtd_reserv_2    
   LET l_est_loc.qtd_reserv_3    = m_lote_ender.qtd_reserv_3   
   LET l_est_loc.num_reserv_1    = m_lote_ender.num_reserv_1   
   LET l_est_loc.num_reserv_2    = m_lote_ender.num_reserv_2   
   LET l_est_loc.num_reserv_3    = m_lote_ender.num_reserv_3   
   LET l_est_loc.tex_reservado   = m_lote_ender.tex_reservado  
   LET l_est_loc.identif_estoque = m_lote_ender.identif_estoque
   LET l_est_loc.deposit         = m_lote_ender.deposit        
   
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
      VALUES(m_cod_empresa,
         m_num_om,                                         
         m_num_pedido,                                  
         m_num_seq,                     
         m_cod_item,                          
         m_qtd_lote,                                
         l_num_reserva,                                 
         m_lote_ender.cod_grade_1,              
         m_lote_ender.cod_grade_2,              
         m_lote_ender.cod_grade_3,              
         m_lote_ender.cod_grade_4,              
         m_lote_ender.cod_grade_5,              
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
      VALUES(m_cod_empresa,
             m_num_om,
             m_num_pedido,
             m_num_seq,
             l_num_reserva,
             "N")
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ldi_om_grade_compl')
      RETURN FALSE
   END IF

   IF NOT pol1324_ins_area_linha(l_num_reserva) THEN
      RETURN FALSE
   END IF

   INSERT INTO carga_item_912(
    cod_empresa,
    num_carga,        
    num_om,           
    cod_cliente,      
    num_pedido,       
    num_sequencia,    
    cod_item,         
    num_lote,         
    cod_local,        
    qtd_lote,         
    qtd_etiqueta,
    qtd_embal,
    num_reserva)
    VALUES(m_cod_empresa,
           m_num_carga,
           m_num_om,
           m_cod_cliente,
           m_num_pedido,
           m_num_seq,
           m_cod_item,
           m_num_lote,
           m_local_estoq,
           m_qtd_lote,
           m_qtd_etiqueta,
           mr_pcp.cap_embal,
           l_num_reserva)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','carga_item_912')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------------#
FUNCTION pol1324_ins_area_linha(l_num_reserva)#
#---------------------------------------------#
      
   DEFINE l_cod_lin_prod  DECIMAL(2,0),
          l_cod_lin_recei DECIMAL(2,0),
          l_cod_seg_merc  DECIMAL(2,0),
          l_cod_cla_uso   DECIMAL(2,0),
          l_num_reserva   INTEGER
   
   SELECT cod_lin_prod,
          cod_lin_recei,
          cod_seg_merc,
          cod_cla_uso
     INTO l_cod_lin_prod, 
          l_cod_lin_recei,
          l_cod_seg_merc, 
          l_cod_cla_uso  
     FROM item
    WHERE cod_empresa = m_lote_ender.cod_empresa
      AND cod_item = m_lote_ender.cod_item

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
   VALUES(m_cod_empresa, l_num_reserva,
          m_lote_ender.num_transac, m_qtd_lote, 0)
         
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
   VALUES(m_cod_empresa,  l_num_reserva,
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
   VALUES(m_cod_empresa,  l_num_reserva,
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
   VALUES(m_cod_empresa,  l_num_reserva,
          'sit_est_reservada',                        
          'Situação do estoque que está sendo reservado.','L')
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','sup_par_resv_est:2')
      RETURN FALSE
   END IF

   
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1324_atu_saldos()#
#----------------------------#

   UPDATE ped_itens
      SET qtd_pecas_romaneio = qtd_pecas_romaneio + m_qtd_faturar
    WHERE cod_empresa = m_cod_empresa
      AND num_pedido = m_num_pedido
      AND num_sequencia = m_num_seq
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ped_itens')
      RETURN FALSE
   END IF

   UPDATE estoque
      SET qtd_reservada = qtd_reservada + m_qtd_faturar
    WHERE cod_empresa = m_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','estoque')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1324_om_mest()#
#-------------------------#

   DEFINE l_qtd_volume     DECIMAL(10,3),
          l_num_pedido     INTEGER

   SELECT SUM(qtd_volume_item)
     INTO l_qtd_volume
     FROM ordem_montag_item
    WHERE cod_empresa = m_cod_empresa
      AND num_om = m_num_om

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordem_montag_item:SUM(qtd_volume_item)')
      RETURN FALSE
   END IF
   
   IF l_qtd_volume IS NULL THEN
      LET l_qtd_volume = 0
   END IF
   
   INSERT INTO ordem_montag_mest(
      cod_empresa,   
      num_om,        
      num_lote_om,   
      ies_sit_om,    
      cod_transpor,  
      qtd_volume_om, 
      dat_emis)
   VALUES(m_cod_empresa,
          m_num_om,
          m_lote_om,
          'N',
          m_cod_transpor,
          l_qtd_volume,
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
   VALUES(m_cod_empresa,
          m_lote_om,
          'N',
          m_cod_transpor,
          m_dat_atu,
          1,
          m_cod_tip_carteira,
          NULL,0,0,0)
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ordem_montag_lote')
      RETURN FALSE
   END IF

   DECLARE cq_list CURSOR FOR
    SELECT DISTINCT num_pedido
      FROM ordem_montag_item
     WHERE cod_empresa = m_cod_empresa
       AND num_om = m_num_om
   
   FOREACH cq_list INTO l_num_pedido       

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordem_montag_item:pedido')
         RETURN FALSE
      END IF
      
      INSERT INTO om_list (                     
            cod_empresa,                           
            num_om,                                
            num_pedido,                            
            dat_emis,                              
            nom_usuario)                           
         VALUES(m_cod_empresa,                     
                m_num_om,                          
                l_num_pedido,                      
                m_dat_atu,                      
                p_user)                            
                                                   
      IF STATUS <> 0 THEN                       
         CALL log003_err_sql('INSERT','om_list')
         RETURN FALSE                           
      END IF                                    
            
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION





#-------------------FIM DO ROMANEIRO--------------------#


#--------------IMPRESSÃO DA ETIQUETA--------------------#

#------------------------------#
FUNCTION pol1324_imp_etiqueta()#
#------------------------------#

   LET mr_om.cod_empresa = mr_cabec.cod_empresa
   LET mr_om.num_om = m_num_om
   LET m_cod_empresa = mr_om.cod_empresa
   
   CALL pol1324_info_om()

   IF m_num_om = 0 THEN
      RETURN FALSE
   END IF   

   IF NOT pol1324_le_om_item() THEN
      RETURN FALSE
   END IF

   LET p_status = pol1324_chama_delphi()
           
   #CALL LOG_progresspopup_start("Imprimindo...","pol1324_imprimir","PROCESS")
   
   IF NOT p_status THEN
      LET m_msg = 'Operação cancelada.'
      CALL log0030_mensagem(m_msg,'info')
   END IF
      
   RETURN TRUE
      
END FUNCTION               

#-------------------------#
FUNCTION pol1324_info_om()#
#-------------------------#

   DEFINE l_menubar     VARCHAR(10),
          l_panel       VARCHAR(10),
          l_select      VARCHAR(10),
          l_cancel      VARCHAR(10)

    LET m_dlg_om = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dlg_om,"SIZE",400,200)
    CALL _ADVPL_set_property(m_dlg_om,"TITLE","OM PARA IMPRESAÃO")
    CALL _ADVPL_set_property(m_dlg_om,"INIT_EVENT","pol1324_inicia_form")

    LET m_bar_om = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dlg_om)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dlg_om)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    CALL pol1324_par_imp(l_panel)
    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dlg_om)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232)
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_select = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_select,"IMAGE","CONFIRM_EX")
   CALL _ADVPL_set_property(l_select,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_select,"EVENT","pol1324_conf_om")     

   LET l_cancel = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancel,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancel,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancel,"EVENT","pol1324_canc_om")     

   CALL _ADVPL_set_property(m_dlg_om,"ACTIVATE",TRUE)


END FUNCTION

#-----------------------------#
FUNCTION pol1324_inicia_form()#
#-----------------------------#

   CALL _ADVPL_set_property(m_cod_imp,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1324_par_imp(l_panel)#
#--------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)
              
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",3)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_imp = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_imp,"LENGTH",2)
    CALL _ADVPL_set_property(m_cod_imp,"VARIABLE",mr_om,"cod_empresa")
    CALL _ADVPL_set_property(m_cod_imp,"PICTURE","@!")

    LET m_lupa_emp = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_emp,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_emp,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_emp,"CLICK_EVENT","pol1324_zoom_empresa")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Num OM:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",9)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_om,"num_om")
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E #########")

    {LET m_lupa_om = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_om,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_om,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_om,"CLICK_EVENT","pol1324_zoom_om")}

END FUNCTION

#------------------------------#
FUNCTION pol1324_zoom_empresa()#
#------------------------------#

    DEFINE l_codigo          LIKE empresa.cod_empresa,
           l_descri          LIKE empresa.den_empresa
    
    IF  m_zoom_emp IS NULL THEN
        LET m_zoom_emp = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_emp,"ZOOM","zoom_empresa")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_emp,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_emp,"RETURN_BY_TABLE_COLUMN","empresa","cod_empresa")
    LET l_descri = _ADVPL_get_property(m_zoom_emp,"RETURN_BY_TABLE_COLUMN","empresa","den_empresa")

    IF  l_codigo IS NOT NULL THEN
        IF m_par_info = 'P' THEN 
           LET mr_om.cod_empresa = l_codigo
        ELSE
           LET mr_tela1.cod_empresa = l_codigo
           LET mr_tela1.den_empresa = l_descri
        END IF
    END IF
    
    #CALL _ADVPL_set_property(m_item,"GET_FOCUS")

END FUNCTION

                               
#-------------------------#
FUNCTION pol1324_zoom_om()#
#-------------------------#

    DEFINE l_codigo    CHAR(15)
    
    IF  m_zoom_om IS NULL THEN
        LET m_zoom_om = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_om,"ZOOM","zoom_ordem_montagem")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_om,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_om,"RETURN_BY_TABLE_COLUMN","ordem_montag_mest","num_om")

    IF  l_codigo IS NOT NULL THEN
        LET mr_om.num_om = l_codigo
        #LET mr_parametro.den_item = l_den_item
    END IF
    
    #CALL _ADVPL_set_property(m_item,"GET_FOCUS")

END FUNCTION

#-------------------------#
FUNCTION pol1324_conf_om()#
#-------------------------#

   CALL _ADVPL_set_property(m_bar_om,"ERROR_TEXT", '')

   IF mr_om.cod_empresa IS NULL THEN
      LET m_msg = 'Informe a Empresa'
      CALL _ADVPL_set_property(m_bar_om,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF mr_om.num_om IS NULL THEN
      LET m_msg = 'Informe a Ordem de Montagem'
      CALL _ADVPL_set_property(m_bar_om,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT cod_empresa
     FROM ordem_montag_mest
    WHERE cod_empresa = mr_om.cod_empresa
      AND num_om = mr_om.num_om
   
   IF STATUS = 100 THEN
      LET m_msg = 'Empresa e/ou OM inexistentes'
      CALL _ADVPL_set_property(m_bar_om,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordem_montag_mest')
         RETURN FALSE
      END IF
   END IF
   
   LET m_cod_empresa = mr_om.cod_empresa
   LET m_num_om = mr_om.num_om
   
   CALL _ADVPL_set_property(m_dlg_om,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION
   
#-------------------------#
FUNCTION pol1324_canc_om()#
#-------------------------#

   INITIALIZE m_cod_empresa TO NULL
   LET m_num_om = 0
   
   CALL _ADVPL_set_property(m_dlg_om,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1324_le_om_item()#
#----------------------------#
   
   DEFINE l_num_docum    LIKE estoque_loc_reser.num_docum,
          l_dat_user     CHAR(30),
          l_imp          CHAR(01)
   
   LET l_num_docum = m_num_om
   
   LET l_dat_user = EXTEND(CURRENT, YEAR TO DAY)
   LET l_dat_user = l_dat_user CLIPPED, ' ', p_user
   LET l_imp = 'N'
   
   DECLARE cq_imp CURSOR FOR
    SELECT num_pedido, 
           num_sequencia,
           cod_item,
           qtd_volume_item,
           qtd_reservada,
           pes_total_item      
      FROM ordem_montag_item
     WHERE cod_empresa = m_cod_empresa
       AND num_om = m_num_om
   
   FOREACH cq_imp INTO 
      m_num_pedido,
      m_num_seq,
      m_cod_item,
      m_qtd_etiqueta,
      m_qtd_lote,
      m_peso_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordem_montag_item')
         RETURN FALSE
      END IF
      
      IF NOT pol1324_le_compl() THEN
         RETURN FALSE
      END IF
      
      DECLARE cq_lreser CURSOR FOR
       SELECT num_lote
         FROM estoque_loc_reser
        WHERE cod_empresa = m_cod_empresa
          AND num_docum = l_num_docum
          AND cod_item = m_cod_item
          AND cod_local = m_local_estoq
          
      FOREACH cq_lreser INTO m_num_lote
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','estoque_loc_reser')
            RETURN FALSE
         END IF
         
         DELETE FROM etiqueta_912
          WHERE cod_empresa = m_cod_empresa
            AND num_om = m_num_om
            AND num_pedido = m_num_pedido
            AND cod_item = m_cod_item
            AND num_lote = m_num_lote

         IF STATUS <> 0 THEN
            CALL log003_err_sql('DELETE','etiqueta_912')
            RETURN FALSE
         END IF
            
         SELECT MAX(id_registro)
           INTO m_id_registro
           FROM etiqueta_912
          WHERE cod_empresa = m_cod_empresa
          
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','etiqueta_912')
            RETURN FALSE
         END IF
         
         IF m_id_registro IS NULL THEN
            LET m_id_registro = 0
         END IF
         
         LET m_id_registro = m_id_registro + 1
                  
         INSERT INTO etiqueta_912
          VALUES(m_id_registro,
                 m_cod_empresa,
                 p_den_empresa,
                 m_num_om, 
                 m_num_pedido,
                 m_num_seq,
                 m_cod_item, 
                 m_den_item,
                 m_peso_unit,
                 m_item_cliente,
                 m_cod_cliente,
                 m_nom_cliente,
                 m_num_lote, 
                 m_qtd_lote,
                 m_qtd_etiqueta,
                 m_peso_item,
                 m_cod_embal,
                 m_peso_embal,
                 l_dat_user,
                 l_imp,
                 m_qtd_embal)
                 
         IF STATUS <> 0 THEN
            CALL log003_err_sql('INSERT','etiqueta_912')
            RETURN FALSE
         END IF
                 
      END FOREACH
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1324_le_compl()#
#--------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = m_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   SELECT cod_cliente,
          cod_tip_venda
     INTO m_cod_cliente,
          m_cod_tip_venda
     FROM pedidos
    WHERE cod_empresa = m_cod_empresa
      AND num_pedido = m_num_pedido

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','pedidos')
      RETURN FALSE
   END IF

   SELECT nom_cliente
     INTO m_nom_cliente
     FROM clientes
    WHERE cod_cliente = m_cod_cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','clientes')
      RETURN FALSE
   END IF

   SELECT cod_item_cliente
     INTO m_item_cliente
     FROM cliente_item
    WHERE cod_empresa = m_cod_empresa
      AND cod_cliente_matriz = m_cod_cliente
      AND cod_item = m_cod_item

   IF STATUS = 100 THEN
      LET m_item_cliente = ''
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("SELECT","cliente_item")
        RETURN FALSE
      END IF        
   END IF

   SELECT den_item,
          pes_unit,
          cod_local_estoq
     INTO m_den_item,
          m_peso_unit,
          m_local_estoq
     FROM Item
    WHERE cod_empresa = m_cod_empresa
      AND cod_item = m_cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','Item:peso-item')
      RETURN FALSE
   END IF

   SELECT cod_embal_int
     INTO m_cod_embal
     FROM ordem_montag_embal
    WHERE cod_empresa = m_cod_empresa
      AND num_om = m_num_om
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordem_montag_embal:lc')
      RETURN FALSE
   END IF

   SELECT qtd_embal
     INTO m_qtd_embal
     FROM carga_item_912
    WHERE cod_empresa = m_cod_empresa
      AND num_om = m_num_om
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','carga_item_912:lc')
      RETURN FALSE
   END IF    

   SELECT pes_unit
     INTO m_peso_embal
     FROM embalagem
    WHERE cod_embal = m_cod_embal
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','embalagem:peso-embal')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1324_imprimir()#
#--------------------------#

 LET p_status = StartReport(
   "pol1324_relatorio","pol1324","",80,TRUE,TRUE)

END FUNCTION

#-----------------------------------#
FUNCTION pol1324_relatorio(l_report)#
#-----------------------------------#

   DEFINE l_report       CHAR(300),
          l_status       SMALLINT

   LET m_page_length = ReportPageLength("pol1324")

   START REPORT pol1324_relat TO l_report
    
   LET p_status = pol1324_le_etiq()

   FINISH REPORT pol1324_relat 
   CALL FinishReport("pol1324")

END FUNCTION

#-------------------------#
FUNCTION pol1324_le_etiq()#
#-------------------------#
   
   DEFINE l_ind      INTEGER,
          l_qtd_imp  DECIMAL(10,3),
          l_qtd_item DECIMAL(10,3),
          l_num_seq  CHAR(03)

   LET l_qtd_imp = 0
   
   DECLARE cq_etiq CURSOR FOR
    SELECT cod_cliente,
           cod_item,
           den_item,
           peso_unit,
           peso_item,
           cod_embal,
           peso_embal,
           num_lote,
           qtd_lote,
           dat_user,
           qtd_etiqueta,
           qtd_embal
      FROM etiqueta_912
     WHERE cod_empresa = m_cod_empresa
       AND num_om =  m_num_om

   FOREACH cq_etiq INTO
      mr_relat.cod_cliente, 
      mr_relat.cod_item,    
      mr_relat.den_item,    
      mr_relat.peso_unit,   
      mr_relat.peso_item,   
      mr_relat.cod_embal,   
      mr_relat.peso_embal,  
      mr_relat.num_lote,  
      l_qtd_item,  
      mr_relat.dat_user,
      mr_relat.qtd_etiqueta,
      p_qtd_lote 
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','etiqueta_912:cq_etiq')             
         RETURN FALSE
      END IF

      LET mr_relat.peso_bruto = mr_relat.peso_item = mr_relat.peso_embal
      
      FOR l_ind = 1 TO (mr_relat.qtd_etiqueta - 1)
          LET l_qtd_imp = l_qtd_imp + p_qtd_lote
          LET mr_relat.num_seq = l_ind
          LET l_num_seq = func002_strzero(l_ind, 3)
          LET m_rastro = mr_relat.num_lote CLIPPED, l_num_seq
          LET mr_relat.qtd_lote = p_qtd_lote
          OUTPUT TO REPORT pol1324_relat()
      END FOR

      LET mr_relat.num_seq = l_ind
      LET mr_relat.qtd_lote = l_qtd_item - l_qtd_imp
      OUTPUT TO REPORT pol1324_relat()
   
   END FOREACH
   
   RETURN TRUE
         
END FUNCTION

#---------------------#
REPORT pol1324_relat()#
#---------------------#

    OUTPUT
        TOP    MARGIN 0
        LEFT   MARGIN 0
        RIGHT  MARGIN 0
        BOTTOM MARGIN 0
        PAGE   LENGTH 15
   
   FORMAT
      
   ON EVERY ROW            
      
      PRINT COLUMN 001,"^XA"
      PRINT COLUMN 001,"^MMT"
      PRINT COLUMN 001,"^PW703"
      PRINT COLUMN 001,"^LL0839"
      PRINT COLUMN 001,"^LS0"
      PRINT COLUMN 001,"^FT320,128^XG000.GRF,1,1^FS"
      PRINT COLUMN 001,"^FT128,128^XG001.GRF,1,1^FS"
      PRINT COLUMN 001,"^FT32,160^XG002.GRF,1,1^FS"
      PRINT COLUMN 001,"^FT320,160^XG003.GRF,1,1^FS"
      PRINT COLUMN 001,"^FT32,256^XG004.GRF,1,1^FS"
      PRINT COLUMN 001,"^FT32,448^XG005.GRF,1,1^FS"
      PRINT COLUMN 001,"^FT32,384^XG006.GRF,1,1^FS"
      PRINT COLUMN 001,"^FT32,768^XG007.GRF,1,1^FS"
      PRINT COLUMN 001,"^FT32,544^XG008.GRF,1,1^FS"
      PRINT COLUMN 001,"^FT224,576^XG009.GRF,1,1^FS"
      PRINT COLUMN 001,"^FT480,640^XG010.GRF,1,1^FS"
      PRINT COLUMN 001,"^FT64,640^XG011.GRF,1,1^FS"
      PRINT COLUMN 001,"^FT256,640^XG012.GRF,1,1^FS"
      PRINT COLUMN 001,"^FO667,41^GB0,754,1^FS"
      PRINT COLUMN 001,"^FO33,317^GB632,0,3^FS"
      PRINT COLUMN 001,"^FO34,224^GB632,0,2^FS"
      PRINT COLUMN 001,"^FO34,686^GB632,0,3^FS"
      PRINT COLUMN 001,"^FO34,591^GB633,0,3^FS"
      PRINT COLUMN 001,"^FO34,496^GB633,0,3^FS"
      PRINT COLUMN 001,"^FO33,411^GB632,0,2^FS"
      PRINT COLUMN 001,"^FO34,128^GB633,0,3^FS"
      PRINT COLUMN 001,"^FO33,793^GB632,0,1^FS"
      PRINT COLUMN 001,"^FO32,40^GB0,754,1^FS"
      PRINT COLUMN 001,"^FO34,40^GB633,0,2^FS"
      PRINT COLUMN 001,"^FT47,196^A0N,28,28^FH\^FD",mr_relat.cod_item,"^FS"      
      PRINT COLUMN 001,"^FT316,196^A0N,28,28^FH\^FD",mr_relat.dat_user,"^FS"
      PRINT COLUMN 001,"^FO423,593^GB0,94,3^FS"
      PRINT COLUMN 001,"^FO222,593^GB0,94,3^FS"
      PRINT COLUMN 001,"^FO221,500^GB0,94,3^FS"
      PRINT COLUMN 001,"^FO299,129^GB0,94,3^FS"            
      PRINT COLUMN 001,"^FT451,672^A0N,28,28^FH\^FD",mr_relat.peso_bruto,"^FS"     
      PRINT COLUMN 001,"^FT248,672^A0N,28,28^FH\^FD",mr_relat.peso_embal,"^FS"                     
      PRINT COLUMN 001,"^FT47,295^A0N,28,28^FH\^FD",mr_relat.num_lote,"^FS"          
      PRINT COLUMN 001,"^FT52,672^A0N,28,28^FH\^FD",mr_relat.peso_item,"^FS"          
      PRINT COLUMN 001,"^FT47,580^A0N,28,28^FH\^FD",mr_relat.peso_unit,"^FS"         
      PRINT COLUMN 001,"^FT47,478^A0N,28,28^FH\^FD",mr_relat.den_item,"^FS"    
      PRINT COLUMN 001,"^FT247,580^A0N,28,28^FH\^FD",mr_relat.qtd_lote,"^FS"             
      PRINT COLUMN 001,"^FT47,393^A0N,28,28^FH\^FD",mr_relat.cod_item,"^FS"    
      PRINT COLUMN 001,"^BY1,3,87^FT423,588^BCN,,N,N"
      PRINT COLUMN 001,"^FD>:",mr_relat.qtd_lote,"^FS"
      PRINT COLUMN 001,"^BY1,3,82^FT349,406^BCN,,N,N"
      PRINT COLUMN 001,"^FD>:",mr_relat.cod_item,"^FS"
      PRINT COLUMN 001,"^BY1,3,78^FT349,309^BCN,,N,N"
      PRINT COLUMN 001,"^FD>:",mr_relat.num_lote,"^FS"
      PRINT COLUMN 001,"^PQ1,0,1,Y^XZ"
      PRINT COLUMN 001,"^XA^ID000.GRF^FS^XZ"
      PRINT COLUMN 001,"^XA^ID001.GRF^FS^XZ"
      PRINT COLUMN 001,"^XA^ID002.GRF^FS^XZ"
      PRINT COLUMN 001,"^XA^ID003.GRF^FS^XZ"
      PRINT COLUMN 001,"^XA^ID004.GRF^FS^XZ"
      PRINT COLUMN 001,"^XA^ID005.GRF^FS^XZ"
      PRINT COLUMN 001,"^XA^ID006.GRF^FS^XZ"
      PRINT COLUMN 001,"^XA^ID007.GRF^FS^XZ"
      PRINT COLUMN 001,"^XA^ID008.GRF^FS^XZ"
      PRINT COLUMN 001,"^XA^ID009.GRF^FS^XZ"
      PRINT COLUMN 001,"^XA^ID010.GRF^FS^XZ"
      PRINT COLUMN 001,"^XA^ID011.GRF^FS^XZ"
      PRINT COLUMN 001,"^XA^ID012.GRF^FS^XZ"
      

END REPORT



#------------------------------#
FUNCTION pol1324_chama_delphi()#
#------------------------------#

   DEFINE p_param    CHAR(42),
          p_comando  CHAR(200),
          l_om       CHAR(10)

   LET l_om = m_num_om
   LET p_param = m_cod_empresa CLIPPED, ' ', l_om CLIPPED
      
   SELECT nom_caminho
     INTO p_caminho
     FROM path_logix_v2
    WHERE cod_empresa = m_cod_empresa 
      AND cod_sistema = 'DPH'
  
   IF p_caminho IS NULL THEN
      LET p_caminho = 'Caminho do sistema DPH não en-\n',
                      'contrado. Consulte a log1100.'
      CALL log0030_mensagem(p_caminho,'Info')
      RETURN FALSE
   END IF

   LET p_comando = p_caminho CLIPPED, 'PGI000.exe ' , p_param

   CALL conout(p_comando)

   CALL runOnClient(p_comando)
  
   RETURN TRUE      

END FUNCTION   



#-------------------LISTAGEM DE OMs-------------------------#


#------------------------#
 FUNCTION pol1324_listar()
#------------------------#

   DEFINE l_menubar     VARCHAR(10),
          l_panel       VARCHAR(10),
          l_select      VARCHAR(10),
          l_cancel      VARCHAR(10)

    LET m_par_info = 'R'
    
    LET m_dlg_rel = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dlg_rel,"SIZE",600,250)
    CALL _ADVPL_set_property(m_dlg_rel,"TITLE","PARÂMETROS PARA IMPRESAÃO")
    CALL _ADVPL_set_property(m_dlg_rel,"INIT_EVENT","pol1324_rel_inicia")

    LET m_bar_rel = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dlg_rel)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dlg_rel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    CALL pol1324_par_rel(l_panel)
    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dlg_rel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232)
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_select = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_select,"IMAGE","CONFIRM_EX")
   CALL _ADVPL_set_property(l_select,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_select,"EVENT","pol1324_relat_conf")     

   LET l_cancel = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancel,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancel,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancel,"EVENT","pol1324_relat_canc")     

   CALL _ADVPL_set_property(m_dlg_rel,"ACTIVATE",TRUE)
         
END FUNCTION

#----------------------------#
FUNCTION pol1324_rel_inicia()#
#----------------------------#

   CALL _ADVPL_set_property(m_re_imp,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1324_par_rel(l_panel)#
#--------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_lupa            VARCHAR(10)
    
    LET mr_tela1.cod_empresa = p_cod_empresa        
    LET mr_tela1.reimpressao = 'N'
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",4)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Re-impressão:")    

    LET m_re_imp = _ADVPL_create_component(NULL,"LCHECKBOX",l_layout)
    CALL _ADVPL_set_property(m_re_imp,"VARIABLE",mr_tela1,"reimpressao")
    CALL _ADVPL_set_property(m_re_imp,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_re_imp,"VALUE_NCHECKED","N")     

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN") 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN") 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT"," Cod empresa:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_imp = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_imp,"LENGTH",2)
    CALL _ADVPL_set_property(m_cod_imp,"VARIABLE",mr_tela1,"cod_empresa")
    CALL _ADVPL_set_property(m_cod_imp,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_imp,"VALID","pol1324_valid_empresa")

    LET l_lupa = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(l_lupa,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa,"CLICK_EVENT","pol1324_zoom_empresa")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",36)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_tela1,"den_empresa")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT"," Cod cliente:")    

    LET m_rel_cli = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_rel_cli,"LENGTH",15)
    CALL _ADVPL_set_property(m_rel_cli,"VARIABLE",mr_tela1,"cod_cliente")
    CALL _ADVPL_set_property(m_rel_cli,"PICTURE","@E!")
    CALL _ADVPL_set_property(m_rel_cli,"VALID","pol1324_valid_cliente")

    LET l_lupa = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(l_lupa,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa,"CLICK_EVENT","pol1324_zoom_cliente")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN") 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Número da OM:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_tela1,"num_om")
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E ##########")
    CALL _ADVPL_set_property(l_caixa,"VALID","pol1324_valid_om")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Lot OM:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_tela1,"num_lote_om")
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E ##########")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

END FUNCTION

#-------------------------------#
FUNCTION pol1324_valid_empresa()#
#-------------------------------#
   
   CALL _ADVPL_set_property(m_bar_rel,"ERROR_TEXT","")

   IF mr_tela1.cod_empresa IS NULL THEN
      CALL _ADVPL_set_property(m_bar_rel,"ERROR_TEXT","Informe a empresa")
   END IF
   
   SELECT den_empresa
     INTO mr_tela1.den_empresa
     FROM empresa
    WHERE cod_empresa = mr_tela1.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#-------------------------------#
FUNCTION pol1324_valid_cliente()#
#-------------------------------#
   
   CALL _ADVPL_set_property(m_bar_rel,"ERROR_TEXT","")
   
   IF mr_tela1.cod_cliente IS NOT NULL THEN
      IF NOT pol1324_le_cliente() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1324_le_cliente()#
#----------------------------#

   DEFINE l_cod         CHAR(15)
   
   LET l_cod = mr_tela1.cod_cliente CLIPPED,'%'

   SELECT COUNT(nom_cliente)
     INTO m_count
     FROM clientes
    WHERE cod_cliente LIKE l_cod 
        
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','clientes')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Não há clientes com o prefixo informado'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION


#--------------------------#
FUNCTION pol1324_valid_om()#
#--------------------------#
   
   CALL _ADVPL_set_property(m_bar_rel,"ERROR_TEXT","")
   
   IF mr_tela1.num_om IS NULL OR
      mr_tela1.num_om <= 0 THEN
      LET mr_tela1.num_om = NULL
      LET mr_tela1.num_lote_om = NULL
      RETURN TRUE
   END IF
      
   SELECT num_lote_om
     INTO mr_tela1.num_lote_om
     FROM ordem_montag_mest
    WHERE cod_empresa = mr_tela1.cod_empresa
      AND num_om = mr_tela1.num_om
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordem_montag_mest')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1324_relat_canc()#
#----------------------------#
   
   LET m_par_info = 'P'
   CALL _ADVPL_set_property(m_dlg_rel,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION
      
#----------------------------#
FUNCTION pol1324_relat_conf()#
#----------------------------#

   DEFINE l_comando      CHAR(150),
          l_cod          CHAR(15),
          l_lote_om      CHAR(15)
   
   CALL _ADVPL_set_property(m_bar_rel,"ERROR_TEXT", '')

   IF mr_tela1.num_om IS NULL OR
      mr_tela1.num_om <= 0 THEN
      LET mr_tela1.num_om = NULL
      LET mr_tela1.num_lote_om = NULL
   END IF

   CALL pol1324_del_tab_resumo()
   
   CALL LOG_progresspopup_start("Imprimindo...","pol1324_imp_oms","PROCESS")

   IF NOT p_status THEN
      CALL _ADVPL_set_property(m_bar_rel,"ERROR_TEXT", 'Impressão cancelada.')
      RETURN FALSE
   END IF
   
   LET m_par_info = 'P'
   CALL _ADVPL_set_property(m_dlg_rel,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION pol1324_del_tab_resumo()#
#---------------------------------# 

   DELETE FROM resumo_embal
   DELETE FROM w_om_list
   
END FUNCTION
   
#-------------------------#
FUNCTION pol1324_imp_oms()#
#-------------------------#

 LET p_status = StartReport(
   "pol1324_le_oms","pol1324om","",132,TRUE,TRUE)

END FUNCTION

#---------------------------------#
 FUNCTION pol1324_le_oms(l_report)#
#---------------------------------#

   DEFINE l_report             CHAR(300),
          p_sql_stmt           VARCHAR(1000),                      
          l_qtd_embal          LIKE embal_itaesbra.qtd_padr_embal, 
          p_data               CHAR(10),                           
          p_hora               CHAR(08),                           
          p_tamanho            INTEGER,
          l_status             SMALLINT,
          l_cod                CHAR(15)
   
   LET l_cod = mr_tela1.cod_cliente CLIPPED,'%'

   LET m_page_length = ReportPageLength("pol1324om")

   START REPORT pol1324om_relat TO l_report

    LET p_data = TODAY USING "yyyy-mm-dd"
    LET p_hora = TIME
    
   LET p_count = 0

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = mr_tela1.cod_empresa
      
   IF mr_tela1.reimpressao = "S" THEN

      LET p_sql_stmt = " SELECT DISTINCT a.num_lote_om, ",                         
                     " a.num_om, ",
                     " b.num_sequencia, ",
                     " b.cod_item, ",
                     " b.qtd_reservada, ",
                     " c.cod_transpor, ",
                     " c.num_placa, ",
                     " d.num_pedido, ",
                     " d.cod_cliente ",
                     " FROM ordem_montag_mest a, ordem_montag_item b, ",
                     " ordem_montag_lote c, pedidos d ",
                     " WHERE a.cod_empresa = b.cod_empresa ",
                     " AND b.cod_empresa = c.cod_empresa ",
                     " AND c.cod_empresa = d.cod_empresa ",
                     " AND a.num_om = b.num_om ",
                     " AND a.num_lote_om = c.num_lote_om ",
                     " AND a.cod_empresa = '",mr_tela1.cod_empresa,"' ",
                     " AND b.num_pedido = d.num_pedido ",
                     " AND a.num_nff IS NULL ",
                     " AND a.ies_sit_om = 'N' ",
                     " AND d.cod_cliente LIKE '",l_cod,"' "
      
   END IF
   
   IF mr_tela1.reimpressao = "N" THEN
       
      LET p_sql_stmt = " SELECT DISTINCT a.num_lote_om, ",
                     " a.num_om, ",
                     " b.num_sequencia, ",
                     " b.cod_item, ",
                     " b.qtd_reservada, ",
                     " c.cod_transpor, ",
                     " c.num_placa, ",
                     " d.num_pedido, ",
                     " d.cod_cliente ",
                     " FROM ordem_montag_mest a, ordem_montag_item b, ",
                     " ordem_montag_lote c, pedidos d, om_list e ",
                     " WHERE a.cod_empresa = b.cod_empresa ",
                     " AND b.cod_empresa = c.cod_empresa ",
                     " AND c.cod_empresa = d.cod_empresa ",
                     " AND d.cod_empresa = e.cod_empresa ",
                     " AND a.num_om = b.num_om ",
                     " AND b.num_om = e.num_om ",
                     " AND a.num_lote_om = c.num_lote_om ",
                     " AND a.cod_empresa = '",mr_tela1.cod_empresa,"' ",
                     " AND b.num_pedido = d.num_pedido ",
                     " AND a.num_nff IS NULL ",
                     " AND a.ies_sit_om = 'N' ",
                     " AND e.nom_usuario = '",p_user,"' ",
                     " AND d.cod_cliente LIKE '",l_cod,"' "


   END IF

   IF mr_tela1.num_lote_om IS NOT NULL THEN
      LET p_sql_stmt = p_sql_stmt CLIPPED,
             " AND c.num_lote_om = '",mr_tela1.num_lote_om,"' "
   END IF
   
   LET p_sql_stmt = p_sql_stmt CLIPPED, " ORDER BY 9,1,4 "
      
   CALL LOG_progresspopup_set_total("PROCESS",10)
   
   PREPARE var_query1 FROM p_sql_stmt   
   DECLARE cq_relat CURSOR FOR var_query1

   LET l_qtd_vol   = 0
   LET l_qtd_embal = 0
   DELETE FROM  resumo_embal

   FOREACH cq_relat INTO p_relat.num_lote_om,
                         p_relat.num_om,
                         p_relat.num_sequencia,
                         p_relat.cod_item, 
                         p_qtd_faturada,
                         p_relat.cod_transpor,  
                         p_relat.num_placa,
                         p_relat.num_pedido,
                         p_relat.cod_cliente
                         

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_relat')
         EXIT FOREACH
      END IF
      
      SELECT cod_item_cliente
        INTO p_relat.cod_item_cliente
        FROM cliente_item
       WHERE cod_empresa = mr_tela1.cod_empresa
         AND cod_cliente_matriz = p_relat.cod_cliente
         AND cod_item = p_relat.cod_item

      IF STATUS <> 0 THEN
         LET p_relat.cod_item_cliente = ''
      END IF
      
      SELECT den_item,
             cod_unid_med
        INTO p_relat.den_item,
             p_relat.cod_unid_med
        FROM item
       WHERE cod_empresa = mr_tela1.cod_empresa 
         AND cod_item = p_relat.cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item')
         EXIT FOREACH
      END IF

      SELECT usuario 
        INTO m_usuario
        FROM user_romaneio_304
       WHERE cod_empresa = mr_tela1.cod_empresa 
         AND num_om      = p_relat.num_om
         
      IF STATUS = 100 THEN 
         LET m_usuario = NULL 
      ELSE 
         IF STATUS <> 0 THEN 
            #CALL log003_err_sql('lendo', 'user_romaneio_304')
            #RETURN FALSE 
            LET m_usuario = p_user
         END IF 
      END IF 

      SELECT cod_tip_venda
        INTO m_cod_tip_venda
        FROM pedidos
       WHERE cod_empresa = mr_tela1.cod_empresa
         AND num_pedido = p_relat.num_pedido

      SELECT cod_embal_int, 
             qtd_embal_int, 
             cod_embal_ext, 
             qtd_embal_ext 
        INTO p_cod_embal_int,  
             p_qtd_vol_int,  
             p_cod_embal_ext,  
             p_qtd_vol_ext   
        FROM ordem_montag_embal
       WHERE cod_empresa   = mr_tela1.cod_empresa 
         AND num_om        = p_relat.num_om
         AND num_sequencia = p_relat.num_sequencia

      IF p_qtd_vol_int IS NOT NULL AND p_qtd_vol_int > 0 THEN
         SELECT qtd_padr_embal
           INTO p_qtd_embal_int
           FROM embal_itaesbra
          WHERE cod_empresa = mr_tela1.cod_empresa
            AND cod_item = p_relat.cod_item
            AND cod_cliente = p_relat.cod_cliente
            AND cod_tip_venda = m_cod_tip_venda
            AND cod_embal = p_cod_embal_int
            AND ies_tip_embal = 'N'
      
         IF STATUS = 100 THEN
         SELECT qtd_padr_embal
           INTO p_qtd_embal_int
           FROM embal_itaesbra
          WHERE cod_empresa = mr_tela1.cod_empresa
            AND cod_item = p_relat.cod_item
            AND cod_cliente = p_relat.cod_cliente
            AND cod_tip_venda = m_cod_tip_venda
            AND cod_embal = p_cod_embal_int
            AND ies_tip_embal = 'I'
         END IF
      ELSE
         LET p_qtd_vol_int = 0
         LET p_cod_embal_int = NULL
         LET p_qtd_embal_int = NULL
      END IF     

      IF p_qtd_vol_ext IS NOT NULL AND p_qtd_vol_ext > 0 THEN
         SELECT qtd_padr_embal
           INTO p_cod_embal_ext
           FROM embal_itaesbra
          WHERE cod_empresa = mr_tela1.cod_empresa
            AND cod_item = p_relat.cod_item
            AND cod_cliente = p_relat.cod_cliente
            AND cod_tip_venda = m_cod_tip_venda
            AND cod_embal = p_cod_embal_ext
            AND ies_tip_embal = 'C'
      
         IF STATUS = 100 THEN
         SELECT qtd_padr_embal
           INTO p_cod_embal_ext
           FROM embal_itaesbra
          WHERE cod_empresa = mr_tela1.cod_empresa
            AND cod_item = p_relat.cod_item
            AND cod_cliente = p_relat.cod_cliente
            AND cod_tip_venda = m_cod_tip_venda
            AND cod_embal = p_cod_embal_ext
            AND ies_tip_embal = 'C'
         END IF

      ELSE
         LET p_qtd_vol_ext = 0
         LET p_cod_embal_ext = NULL
         LET p_qtd_embal_ext = NULL
      END IF

      IF p_cod_embal_int IS NOT NULL THEN
         SELECT cod_embal_item
           INTO p_cod_embal_int_dp
           FROM de_para_embal
          WHERE cod_empresa   = mr_tela1.cod_empresa
            AND cod_embal_vdp = p_cod_embal_int
      
         IF STATUS <> 0 THEN
            LET p_cod_embal_int_dp = p_cod_embal_int
         END IF
      ELSE
         LET p_cod_embal_int_dp = NULL
      END IF
      
      IF p_cod_embal_ext IS NOT NULL THEN
         SELECT cod_embal_item
           INTO p_cod_embal_ext_dp
           FROM de_para_embal
          WHERE cod_empresa   = mr_tela1.cod_empresa
            AND cod_embal_vdp = p_cod_embal_ext
      
         IF STATUS <> 0 THEN
            LET p_cod_embal_ext_dp = p_cod_embal_ext
         END IF
      ELSE
         LET p_cod_embal_ext_dp = NULL
      END IF
      
      LET p_count = 1
      
      OUTPUT TO REPORT pol1324om_relat(
         p_relat.cod_cliente, p_relat.num_lote_om, p_relat.cod_item_cliente)
         
      IF p_cod_embal_int IS NOT NULL THEN
         INSERT INTO resumo_embal 
            VALUES (p_cod_embal_int, p_qtd_vol_int)
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql("INCLUSAO","RESUMO_EMBAL_INT")
            EXIT FOREACH 
         END IF
      END IF
      
      IF p_cod_embal_ext IS NOT NULL THEN
         INSERT INTO resumo_embal 
            VALUES (p_cod_embal_ext, p_qtd_vol_ext)
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql("INCLUSAO","RESUMO_EMBAL_EXT")
            EXIT FOREACH 
         END IF
      END IF
             
      IF mr_tela1.reimpressao = "N" THEN

         INSERT INTO w_om_list
            VALUES (mr_tela1.cod_empresa,
                    p_relat.num_om,
                    p_relat.num_pedido,
                    TODAY,
                    p_user)
         IF STATUS <> 0 THEN   
            CALL log003_err_sql("INCLUSAO","W_OM_LIST")
            EXIT FOREACH
         END IF

      END IF
      
      INITIALIZE p_relat.* TO NULL
      LET l_status = LOG_progresspopup_increment("PROCESS")
      
   END FOREACH

   FINISH REPORT pol1324om_relat 
   CALL FinishReport("pol1324om")

   IF mr_tela1.reimpressao = "N" THEN

      DECLARE cq_om_list CURSOR FOR
      SELECT * FROM w_om_list
   
      FOREACH cq_om_list INTO mr_om_list.*

         DELETE FROM om_list
         WHERE cod_empresa = p_cod_empresa
           AND num_om = mr_om_list.num_om
           AND nom_usuario = p_user
         
         IF STATUS <> 0 THEN   
            CALL log003_err_sql("EXCLUSAO","OM_LIST")
            EXIT FOREACH
         END IF

      END FOREACH

   END IF
   
END FUNCTION

#--------------------------------------------------#
REPORT pol1324om_relat(
    p_cod_cliente, p_num_lote_om,p_cod_item_cliente)
#--------------------------------------------------# 
      
   DEFINE p_cod_embal         CHAR(05),
          p_cod_embal_item    CHAR(07),
          p_den_embal         CHAR(26),
          p_qtd_vol           DECIMAL(6,0),
          p_primeira          CHAR(01),
          p_num_lote_om       LIKE ordem_montag_lote.num_lote_om,
          p_cod_cliente       CHAR(15),
          p_cod_item_cliente  CHAR(30),
          p_embalagens        CHAR(12),
          l_num_pedido_repres LIKE pedidos.num_pedido_repres,
          l_cod_cidade        LIKE cidades.cod_cidade,
          l_den_cidade        LIKE cidades.den_cidade
   
   DEFINE mr_estoque_loc_reser RECORD
          qtd_reservada        LIKE estoque_loc_reser.qtd_reservada,
          num_lote             LIKE estoque_loc_reser.num_lote
   END RECORD
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3

   ORDER EXTERNAL BY p_cod_cliente,
                     p_num_lote_om,
                     p_cod_item_cliente

   FORMAT

      FIRST PAGE HEADER
	  
	    #PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;


         PRINT COLUMN 001, p_den_empresa[1,20],
               COLUMN 054, "LISTAGEM O.M. NAO FATURADAS",
               COLUMN 125, "PAG.: ", PAGENO USING "######&"
         IF mr_tela1.reimpressao = "S" THEN
            PRINT COLUMN 001, "pol1324                                                       REIMPRESSAO";
         ELSE
            PRINT COLUMN 001, "pol1324                                                         IMPRESSAO";
         END IF 
         PRINT COLUMN 110, "EMISSAO: ", TODAY USING "DD/MM/YYYY", ' ', TIME 
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------"
      PAGE HEADER

         PRINT
         PRINT COLUMN 001, p_den_empresa[1,20],
               COLUMN 028, "LISTAGEM O.M. NAO FATURADAS",
               COLUMN 125, "PAG. :    ", PAGENO USING "######&"
         PRINT COLUMN 001, "pol1324",
               COLUMN 110, "EMISSAO : ", TODAY USING "DD/MM/YYYY", ' ', TIME 
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------"

      BEFORE GROUP OF p_cod_cliente

         SKIP TO TOP OF PAGE

         SELECT nom_cliente,
                cod_cidade
            INTO p_relat.nom_cliente,
                 l_cod_cidade
         FROM clientes
         WHERE cod_cliente = p_relat.cod_cliente    

         SELECT den_cidade
            INTO l_den_cidade
         FROM cidades
         WHERE cod_cidade = l_cod_cidade

         SELECT num_pedido_repres
            INTO l_num_pedido_repres
         FROM pedidos
         WHERE cod_empresa = mr_tela1.cod_empresa      
           AND num_pedido = p_relat.num_pedido

         IF l_num_pedido_repres IS NOT NULL THEN
            PRINT COLUMN 001, "Cliente        : ", p_relat.cod_cliente, " - ", 
                              p_relat.nom_cliente[1,23], 
                  COLUMN 063, "PLANTA : ", l_num_pedido_repres
         ELSE
            PRINT COLUMN 001, "Cliente        : ", p_relat.cod_cliente, " - ", 
                              p_relat.nom_cliente
         END IF

      BEFORE GROUP OF p_num_lote_om

         SELECT nom_cliente
            INTO p_relat.nom_transpor
         FROM clientes
         WHERE cod_cliente = p_relat.cod_transpor   

         #NEED 9 LINES

         PRINT COLUMN 001, "Lote           : ", 
                           p_relat.num_lote_om USING "#####&",
               COLUMN 036, l_den_cidade
         PRINT COLUMN 001, "Transportadora : ", 
                           p_relat.cod_transpor, " - ", p_relat.nom_transpor
         PRINT COLUMN 001, "Placa          : ", p_relat.num_placa,
               COLUMN 065, "N.F.: __________"

         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------"

         PRINT COLUMN 001, "USUARIO   O.M.  PEDIDO SQ     PRODUTO      IT.CLIENTE          QDE FAT LoteOM UN CODIGO  PAD   EMB   CODIGO  PAD   EMB   QTD IT   LOTE ITEM"
         PRINT COLUMN 001, "-------- ------ ------ ---- -------------- -------------------- ------ ------ -- ------- ----- ----- ------- ----- ----- ------ ---------------"
         SKIP 1 LINE

      ON EVERY ROW

         DELETE FROM lote_tmp_304

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Deletando','lote_tmp_304')
         END IF
         
         LET p_num_seq = 0
         
         DECLARE cq_om_rel CURSOR FOR
         SELECT a.qtd_reservada,
                a.num_lote
         FROM estoque_loc_reser a, ordem_montag_grade b
         WHERE a.cod_empresa = b.cod_empresa
           AND a.cod_empresa = mr_tela1.cod_empresa
           AND a.num_reserva = b.num_reserva
           AND a.cod_item = b.cod_item
           AND a.cod_item = p_relat.cod_item
           AND b.num_om = p_relat.num_om
           AND b.num_pedido = p_relat.num_pedido
           AND b.num_sequencia = p_relat.num_sequencia

         FOREACH cq_om_rel INTO 
                 mr_estoque_loc_reser.qtd_reservada,
                 mr_estoque_loc_reser.num_lote
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','estoque_loc_reser:cq_om_rel')
            END IF
            
            LET p_num_seq = p_num_seq + 1
            
            INSERT INTO lote_tmp_304 
            VALUES (p_num_seq,
                    mr_estoque_loc_reser.qtd_reservada,
                    mr_estoque_loc_reser.num_lote)
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Inserindo','lote_tmp_304:cq_om_rel')
            END IF
                    
         END FOREACH
         
         SELECT * INTO 
                  p_num_seq,
                  mr_estoque_loc_reser.qtd_reservada,
                  mr_estoque_loc_reser.num_lote
             FROM lote_tmp_304 WHERE num_seq = 1

         DELETE FROM lote_tmp_304 WHERE num_seq = 1
         
         PRINT COLUMN 001, m_usuario,
               COLUMN 010, p_relat.num_om         USING "#####&",
               COLUMN 017, p_relat.num_pedido     USING "#####&",
               COLUMN 024, p_relat.num_sequencia  USING "###&",
               COLUMN 029, p_relat.cod_item,
               COLUMN 044, p_relat.cod_item_cliente[1,20],
               COLUMN 065, p_qtd_faturada  USING "#####&",
               COLUMN 072, p_relat.num_lote_om    USING "######",
               COLUMN 079, p_relat.cod_unid_med[1,2],
               COLUMN 084, p_cod_embal_int_dp,
               COLUMN 089, p_qtd_embal_int        USING "####&", 
               COLUMN 096, p_qtd_vol_int          USING "####&",
               COLUMN 103, p_cod_embal_ext_dp,
               COLUMN 110, p_qtd_embal_ext        USING "####&", 
               COLUMN 116, p_qtd_vol_ext          USING "####&",
               COLUMN 122, mr_estoque_loc_reser.qtd_reservada USING "#####&",
               COLUMN 129, mr_estoque_loc_reser.num_lote

         DECLARE cq_rel CURSOR FOR
         SELECT qtd_reservada,
                num_lote
         FROM lote_tmp_304

         FOREACH cq_rel INTO 
                 mr_estoque_loc_reser.qtd_reservada,
                 mr_estoque_loc_reser.num_lote
            PRINT COLUMN 122, mr_estoque_loc_reser.qtd_reservada USING "######&",
                  COLUMN 129, mr_estoque_loc_reser.num_lote
         END FOREACH
         

      AFTER GROUP OF p_num_lote_om

        PRINT 
         PRINT COLUMN 064, 'Total de volumes do lote:',
               COLUMN 095,GROUP SUM(p_qtd_vol_int) USING "#####&",
               COLUMN 115,GROUP SUM(p_qtd_vol_ext) USING "#####&"
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------"

      ON LAST ROW

         PRINT 
         LET p_primeira = "S"
         
         DECLARE cq_resumo CURSOR FOR
         SELECT cod_embal,
                SUM(qtd_vol)
           FROM resumo_embal
          GROUP BY cod_embal
          ORDER BY cod_embal 

         FOREACH cq_resumo INTO p_cod_embal,
                                p_qtd_vol

            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','cq_resumo')
               EXIT FOREACH
            END IF
            
            SELECT den_embal
              INTO p_den_embal
              FROM embalagem
             WHERE cod_embal = p_cod_embal
            
            SELECT cod_embal_item
              INTO p_cod_embal_item
              FROM de_para_embal
             WHERE cod_empresa   = mr_tela1.cod_empresa
               AND cod_embal_vdp = p_cod_embal
            
            IF STATUS <> 0 THEN
               LET p_cod_embal_item = NULL
            END IF

            IF p_primeira = "S" THEN
               LET p_embalagens = "Embalagens: "
               LET p_primeira = "N"
            ELSE
               LET p_embalagens = "            "
            END IF
            
            PRINT COLUMN 035, p_embalagens, 
                  COLUMN 047, p_cod_embal ,
                  COLUMN 053, p_cod_embal_item,
                  COLUMN 061, p_den_embal,
                  COLUMN 095, p_qtd_vol USING "#####&"
                                          
         END FOREACH

         SKIP 1 LINES  
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------"
         SKIP 1 LINES
         PRINT COLUMN 035, "Total Geral : ",
               COLUMN 065, SUM(p_qtd_faturada)  USING "######&",
               COLUMN 095, SUM(p_qtd_vol_int)   USING "#####&",
               COLUMN 116, SUM(p_qtd_vol_ext)   USING "#####&"


END REPORT

#------------FIM DO RELATÓRIO----------------------------------------------------#

#----------------------------#
FUNCTION pol1324_devolv_mat()#
#----------------------------#
   
   DEFINE l_dat_inclusao DATE,
          l_num_cgc_cpf  CHAR(20)

   SELECT cod_nat_oper
     INTO p_tela.cod_nat_oper
     FROM natoper_dev_mat_912
   
   IF STATUS = 100 THEN
      LET m_msg = 'Não há naturweza de operação cadasrada\n',
                  'para devolução de material. Use o pol1325.'
      CALL log0030_mensagem(g_msg,'info')
      RETURN FALSE
   ELSE   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','natoper_dev_mat_912')
         RETURN FALSE
      END IF
   END IF
   
   DECLARE cq_mat CURSOR FOR 
    SELECT num_om,           
           cod_cliente,      
           num_pedido,     
           num_sequencia,  
           cod_item         
      FROM carga_item_912
     WHERE cod_empresa = m_cod_empresa
       AND num_carga = m_num_carga
   
   FOREACH cq_mat INTO 
      p_num_om,
      p_cod_cliente,
      p_num_pedido,
      p_num_sequencia,
      p_cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','carga_item_912')
         RETURN FALSE
      END IF
       
      LET l_dat_inclusao = TODAY
   
      SELECT MAX(dat_inclusao)
        INTO p_tela.dat_inclusao
        FROM estrut_item_indus 
       WHERE cod_empresa = m_cod_empresa
         AND cod_cliente = p_cod_cliente
         AND cod_item_prd = p_cod_item
         AND dat_inclusao <= l_dat_inclusao

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','estrut_item_indus:max')
         RETURN FALSE
      END IF
      
      IF p_tela.dat_inclusao IS NULL THEN
         LET m_msg = 'Não a estrutura cadastrada para o item ', p_cod_item CLIPPED,'\n',
                     'na tabela estrut_item_indus.'
         CALL log0030_mensagem(g_msg,'info')
         RETURN FALSE
      END IF
      
      LET p_tela.num_om = p_num_om
      
      INITIALIZE p_cod_fornecedor to null             
                                                   
      SELECT fornecedor                               
        INTO p_cod_fornecedor                         
        FROM vdp_relc_cliente_fornecedor              
       WHERE cliente =  p_cod_cliente                 
                                                   
      IF STATUS = 0 THEN                              
         DECLARE cq_cgc CURSOR FOR                    
          SELECT num_cgc_cpf                          
            FROM fornecedor                           
           WHERE cod_fornecedor = p_cod_fornecedor    
         FOREACH cq_cgc INTO l_num_cgc_cpf            
            EXIT FOREACH                              
         END FOREACH                                  
      ELSE                                            
         SELECT num_cgc_cpf                           
           INTO l_num_cgc_cpf                         
           FROM clientes                              
          WHERE cod_cliente =  p_cod_cliente          
                                                
         SELECT cod_fornecedor                        
           INTO p_cod_fornecedor                      
           FROM fornecedor                            
          WHERE num_cgc_cpf = l_num_cgc_cpf           
      END IF                                          

      IF p_cod_fornecedor is null THEN
         LET m_msg = "Não foi possivel localizar o fornecedor\n do material a devolver "
         CALL log0030_mensagem(g_msg,'info')
         RETURN FALSE
      END IF
  
      IF NOT pol1324_dev_mat() THEN
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1324_dev_mat()#
#-------------------------#
           
   DEFINE p_ord_montag INTEGER
   
   DECLARE cq_omit CURSOR FOR                                                                                   
      SELECT *                                                                                               
        FROM ordem_montag_item                                                                               
       WHERE cod_empresa = m_cod_empresa                                                                     
         AND num_om = p_tela.num_om                                                                          
   FOREACH cq_omit INTO p_ordem_montag_item.*                                                                

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_omit')
         RETURN FALSE
      END IF

      SELECT COUNT(*)
      INTO m_count                                                                                               
      FROM estrut_item_indus                                                                                 
      WHERE cod_empresa  = m_cod_empresa                                                                     
        AND cod_item_prd = p_ordem_montag_item.cod_item                                                      
        AND dat_inclusao = p_tela.dat_inclusao                                                               
        AND cod_cliente  = p_cod_cliente                                                                     
      
      IF m_count = 0 THEN
         LET m_msg = 'Não há material na estrutura do item ', 
               p_ordem_montag_item.cod_item CLIPPED,',\n',
           'para o cliente ', p_cod_cliente CLIPPED, '\n',
           'e data de vigência = ', p_tela.dat_inclusao, '\n',
           'Consulte o POL0272.'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
                                                                                                                
      LET p_cod_item = null                                                                                  
                                                                                                             
      DECLARE cq_estrut_item CURSOR WITH HOLD FOR                                                            
      SELECT *                                                                                               
      FROM estrut_item_indus                                                                                 
      WHERE cod_empresa  = m_cod_empresa                                                                     
        AND cod_item_prd = p_ordem_montag_item.cod_item                                                      
        AND dat_inclusao = p_tela.dat_inclusao                                                               
        AND cod_cliente  = p_cod_cliente                                                                     
                                                                                                             
      FOREACH cq_estrut_item INTO p_estrut_item_indus.*                                                      

         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_omit')
            RETURN FALSE
         END IF
                                                                                                             
         LET p_qtd_neces = p_ordem_montag_item.qtd_reservada * p_estrut_item_indus.qtd_item_ret    
         LET p_cod_item = p_estrut_item_indus.cod_item_ret            

         DECLARE cq_item_terc CURSOR WITH HOLD FOR                                                           
          SELECT nota_fiscal,                                                                                
		             serie_nota_fiscal,                                                                         
		             subserie_nf,                                                                               
		             seq_aviso_recebto,                                                                         
		             seq_tabulacao,                                                                             
		             espc_nota_fiscal,                                                                          
		             qtd_receb,
		             qtd_consumida
		         FROM sup_item_terc_end                                                                          
		        WHERE empresa    = m_cod_empresa                                                                 
		          AND fornecedor = p_cod_fornecedor                                                              
		          AND item       = p_cod_item                                             
		          AND (qtd_receb - qtd_consumida) > 0                                                            
		        ORDER BY aviso_recebto, seq_tabulacao                                                            
                                                                                                             
         FOREACH cq_item_terc INTO                                                                           
                 p_item_de_terc.num_nf,                                                                      
                 p_item_de_terc.ser_nf,                                                                      
                 p_item_de_terc.ssr_nf,                                                                      
                 p_item_de_terc.num_sequencia,                                                               
                 p_seq_tabulacao,                                                                            
                 p_ies_especie_nf,                                                                           
                 p_qtd_saldo,
                 p_qtd_consumida                                                                                 
            
            LET p_qtd_saldo = p_qtd_saldo - p_qtd_consumida                                                                                                            
            LET p_item_de_terc.cod_item = p_estrut_item_indus.cod_item_ret                                   

            SELECT SUM(qtd_devolvida)
              INTO p_qtd_dev_ldi
              FROM ldi_retn_terc_grd                   #contém retornos pendentes e faturados
             WHERE empresa            = m_cod_empresa
               AND nf_entrada         = p_item_de_terc.num_nf
               AND serie_nf_entrada   = p_item_de_terc.ser_nf
               AND subserie_nfe       = p_item_de_terc.ssr_nf
               AND seq_aviso_recebto  = p_item_de_terc.num_sequencia
               AND seq_tabulacao      = p_seq_tabulacao          
               AND especie_nf_entrada = p_ies_especie_nf
               AND fornecedor         = p_cod_fornecedor
               AND ord_montag IN 
                   (SELECT num_om FROM ordem_montag_mest
                     WHERE cod_empresa = m_cod_empresa
                       AND ies_sit_om = 'N')
                             
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','ldi_retn_terc_grd')
               RETURN FALSE
            END IF
               
            IF p_qtd_dev_ldi IS NULL THEN
               LET p_qtd_dev_ldi = 0
            END IF
               
            LET p_qtd_saldo = p_qtd_saldo - p_qtd_dev_ldi

            IF p_qtd_saldo <= 0 THEN                                                                         
               CONTINUE FOREACH                                                                              
            END IF                                                                                           
                                                                                                    
            SELECT val_remessa,                                                                              
                   qtd_tot_recebida,                                                                         
                   qtd_tot_devolvida                                                                         
              INTO p_item_de_terc.val_remessa,                                                               
                   p_item_de_terc.qtd_tot_recebida,                                                          
                   p_qtd_tot_devolvida                                                                       
              FROM item_de_terc                                                                              
             WHERE cod_empresa    = p_cod_empresa                                                            
		            AND num_nf         = p_item_de_terc.num_nf                                           				
		            AND ser_nf         = p_item_de_terc.ser_nf                                           				
		            AND ssr_nf         = p_item_de_terc.ssr_nf                                           				
		            AND ies_especie_nf = p_ies_especie_nf                                                				
		            AND cod_fornecedor = p_cod_fornecedor                                                				
		            AND num_sequencia  = p_item_de_terc.num_sequencia                                    				
                                                                                                           
             IF STATUS <> 0 THEN                                                                             
                CALL log003_err_sql("LEITURA","ITEM_DE_TERC")                                                
                RETURN FALSE                                                                                 
             END IF                                                                                          
                                                                                                    
             LET p_pre_unit = p_item_de_terc.val_remessa / p_item_de_terc.qtd_tot_recebida

             IF p_qtd_saldo < p_qtd_neces THEN                                                                
                LET p_qtd_neces = p_qtd_neces - p_qtd_saldo                                                   
             ELSE                                                                                             
                LET p_qtd_saldo = p_qtd_neces
                LET p_qtd_neces = 0
             END IF                                                                                           
                                                                                                             
            IF NOT pol1324_grava_tabs() THEN                                                                 
               EXIT FOREACH                                                                                  
            END IF                                                                                           
            
            IF p_qtd_neces <= 0 THEN
               EXIT FOREACH
            END IF                                                                                                             
                                                                                                             
         END FOREACH                                                                                         

         IF p_qtd_neces > 0 THEN
            LET m_msg = 'Item ', p_cod_item CLIPPED, ' sem estoque\n',
                        'estoque sufuciente, p/ devolução.'
            CALL log0030_mensagem(m_msg,'excla')
            RETURN FALSE
         END IF                                                                                                             
                                                                                                             
      END FOREACH                                                                                            
                                                                                                                                                                                                        
   END FOREACH                                                                                               

   RETURN TRUE

END FUNCTION
         

#----------------------------#
FUNCTION pol1324_grava_tabs()#
#----------------------------#
   
   DEFINE p_num_trans INTEGER
   
   LET p_ordem_montag_tran.qtd_devolvida  = p_qtd_saldo
   LET p_ordem_montag_tran.cod_empresa    = m_cod_empresa
   LET p_ordem_montag_tran.num_om         = p_tela.num_om
   LET p_ordem_montag_tran.num_pedido     = p_ordem_montag_item.num_pedido
   LET p_ordem_montag_tran.num_seq_item   = p_ordem_montag_item.num_sequencia
   LET p_ordem_montag_tran.cod_item       = p_estrut_item_indus.cod_item_ret
   LET p_ordem_montag_tran.num_nf         = p_item_de_terc.num_nf
   LET p_ordem_montag_tran.ser_nf         = p_item_de_terc.ser_nf
   LET p_ordem_montag_tran.ssr_nf         = p_item_de_terc.ssr_nf
   LET p_ordem_montag_tran.ies_especie_nf = p_ies_especie_nf
   LET p_ordem_montag_tran.num_seq_nf     = p_item_de_terc.num_sequencia
   LET p_ordem_montag_tran.pre_unit       = p_pre_unit
   LET p_ordem_montag_tran.cod_nat_oper   = p_tela.cod_nat_oper
   LET p_ordem_montag_tran.num_transacao  = 0

   INSERT INTO ordem_montag_tran_970 VALUES (p_ordem_montag_tran.*)
  
   IF SQLCA.SQLCODE <> 0 THEN 
	    CALL log003_err_sql("INCLUSAO","ordem_montag_tran_970")
      RETURN FALSE
   END IF
   
   LET p_num_trans = SQLCA.SQLERRD[2]
   
   {INSERT INTO ldi_om_trfor_inf_c 
      VALUES (p_ordem_montag_tran.cod_empresa,p_num_trans,p_cod_fornecedor)

   IF SQLCA.SQLCODE <> 0 THEN 
	    CALL log003_err_sql("INCLUSAO","LDI_OM_TRFOR_INF_C")
      RETURN FALSE
   END IF}

   INSERT INTO ldi_retn_terc_grd 
     VALUES(m_cod_empresa,
            p_ordem_montag_tran.num_om,
            p_ordem_montag_tran.num_pedido,
            p_ordem_montag_tran.num_seq_item,
            0,0,0,0,0,
	          p_ordem_montag_tran.num_nf,
	          p_ordem_montag_tran.ser_nf,
	          p_ordem_montag_tran.ssr_nf,
	          p_ordem_montag_tran.ies_especie_nf,
	          p_cod_fornecedor,
	          p_ordem_montag_tran.num_seq_nf,
	          p_seq_tabulacao,
	          p_ordem_montag_tran.qtd_devolvida,
	          p_ordem_montag_tran.pre_unit,
	          p_ordem_montag_tran.cod_nat_oper,
	          0,12)
	          
	 IF SQLCA.SQLCODE <> 0 THEN 
	    CALL log003_err_sql("INCLUSAO","LDI_RETN_TERC_GRD")
	    RETURN FALSE
	 END IF

   RETURN TRUE

END FUNCTION



#--------------REIMPRESSÃO DO LOTE--------------------#

#--------------------------#
FUNCTION pol1324_imp_lote()#
#--------------------------#

   INITIALIZE mr_ficha.* TO NULL
   CALL pol1324_tela_lote()
   
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1324_tela_lote()#
#---------------------------#

   DEFINE l_menubar     VARCHAR(10),
          l_panel       VARCHAR(10),
          l_select      VARCHAR(10),
          l_cancel      VARCHAR(10)

    LET m_dlg_lote = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dlg_lote,"SIZE",650,380)
    CALL _ADVPL_set_property(m_dlg_lote,"TITLE","REIMPRESAÃO DE LOTE")
    CALL _ADVPL_set_property(m_dlg_lote,"INIT_EVENT","pol1324_posiciona")

    LET m_bar_lote = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dlg_lote)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dlg_lote)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    CALL pol1324_edita_lote(l_panel)
    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dlg_lote)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232)
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_select = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_select,"IMAGE","CONFIRM_EX")
   CALL _ADVPL_set_property(l_select,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_select,"EVENT","pol1324_yes_imp_lote")     
      
   CALL _ADVPL_set_property(m_dlg_lote,"ACTIVATE",TRUE)


END FUNCTION

#-----------------------------------#
FUNCTION pol1324_edita_lote(l_panel)#
#-----------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)
              
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",6)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")
    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Lote:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_lote = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_lote,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_lote,"VARIABLE",mr_ficha,"rastro")
    CALL _ADVPL_set_property(m_cod_lote,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_lote,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_cod_lote,"VALID","pol1324_valida_lote")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Produto:")    

    LET m_cod_produto = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_produto,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_produto,"VARIABLE",mr_ficha,"cod_item")
    CALL _ADVPL_set_property(m_cod_produto,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_produto,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_cod_produto,"VALID","pol1324_valida_produto")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cópias:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_copias = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_copias,"LENGTH",3)
    CALL _ADVPL_set_property(m_copias,"VARIABLE",mr_ficha,"numero_copias")
    CALL _ADVPL_set_property(m_copias,"PICTURE","@E###")
    CALL _ADVPL_set_property(m_copias,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Rua:")    

    LET m_rua = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_rua,"LENGTH",3)
    CALL _ADVPL_set_property(m_rua,"VARIABLE",mr_ficha,"rua")
    CALL _ADVPL_set_property(m_rua,"PICTURE","@!")
    CALL _ADVPL_set_property(m_rua,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Vão:")    

    LET m_vao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_vao,"LENGTH",6)
    CALL _ADVPL_set_property(m_vao,"VARIABLE",mr_ficha,"vao")
    CALL _ADVPL_set_property(m_vao,"PICTURE","@!")
    CALL _ADVPL_set_property(m_vao,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Obs.:")    

    LET m_obs = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_obs,"LENGTH",34)
    CALL _ADVPL_set_property(m_obs,"VARIABLE",mr_ficha,"observacao")
    CALL _ADVPL_set_property(m_obs,"PICTURE","@!")
    CALL _ADVPL_set_property(m_obs,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Quantidade:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_ficha,"quantidade")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Item cli.:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_ficha,"cod_item_cliente")
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@!")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Sequência:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",3)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_ficha,"num_seq")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Sub Sequênc:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",3)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_ficha,"num_sub_seq")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Op próx:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_ficha,"opprox")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Set atual:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_ficha,"setatual")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Set próx:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_ficha,"setprox")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)

END FUNCTION

#---------------------------#
FUNCTION pol1324_posiciona()#
#---------------------------#

   IF mr_ficha.rastro IS NULL THEN
      LET mr_ficha.cod_empresa = mr_cabec.cod_empresa
      CALL _ADVPL_set_property(m_cod_lote,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_cod_produto,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_cod_lote,"GET_FOCUS")
   ELSE
      CALL pol1324_set_compon(TRUE)
      CALL _ADVPL_set_property(m_copias,"GET_FOCUS")
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1324_valida_lote()#
#-----------------------------#

   CALL _ADVPL_set_property(m_bar_lote,"CLEAR_TEXT")
   
   IF mr_ficha.rastro IS NULL THEN
      CALL _ADVPL_set_property(m_bar_lote,"ERROR_TEXT",
             "Informe o lote a ser reimpresso.")
      CALL _ADVPL_set_property(m_cod_lote,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_cod_produto,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1324_valida_produto()#
#--------------------------------#

   CALL _ADVPL_set_property(m_bar_lote,"CLEAR_TEXT")
   
   IF mr_ficha.cod_item IS NULL THEN
      CALL _ADVPL_set_property(m_bar_lote,"ERROR_TEXT",
             "Informe o produto do lote ser reimpresso.")
      CALL _ADVPL_set_property(m_cod_produto,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   SELECT * 
     INTO mr_ficha.*
     FROM ficha_cacamba_970
    WHERE cod_empresa = mr_ficha.cod_empresa
      AND cod_item = mr_ficha.cod_item
      AND rastro = mr_ficha.rastro
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ficha_cacamba_970')
      CALL _ADVPL_set_property(m_cod_lote,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   CALL pol1324_set_compon(TRUE)
   CALL _ADVPL_set_property(m_copias,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1324_set_compon(l_status)#
#------------------------------------#

   DEFINE l_status SMALLINT
   
   CALL _ADVPL_set_property(m_copias,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_rua,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_vao,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_obs,"EDITABLE",l_status)

END FUNCTION

#------------------------------#
FUNCTION pol1324_yes_imp_lote()#
#------------------------------#
   
   UPDATE ficha_cacamba_970
      SET numero_copias = mr_ficha.numero_copias,
          rua = mr_ficha.rua,
          vao = mr_ficha.vao,
          observacao = mr_ficha.observacao
    WHERE cod_empresa = mr_ficha.cod_empresa
      AND cod_item = mr_ficha.cod_item
      AND rastro = mr_ficha.rastro
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ficha_cacamba_970')
   ELSE    
      CALL pol1324_start_print()
   END IF

   CALL _ADVPL_set_property(m_dlg_lote,"ACTIVATE",FALSE)
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1324_start_print()#
#-----------------------------#

   DEFINE p_param    CHAR(42),
          p_comando  CHAR(200)

   LET p_param = mr_ficha.cod_empresa CLIPPED
      
   SELECT nom_caminho
     INTO p_caminho
     FROM path_logix_v2
    WHERE cod_empresa = mr_ficha.cod_empresa 
      AND cod_sistema = 'DPH'
  
   IF p_caminho IS NULL THEN
      LET p_caminho = 'Caminho do sistema DPH não en-\n',
                      'contrado. Consulte a log1100.'
      CALL log0030_mensagem(p_caminho,'Info')
      RETURN 
   END IF

   LET p_comando = p_caminho CLIPPED, 'PGI1335.exe ' , p_param

   CALL conout(p_comando)

   CALL runOnClient(p_comando)
  
   RETURN TRUE      

END FUNCTION   




   