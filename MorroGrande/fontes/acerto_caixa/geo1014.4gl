#-----------------------------------------------------------------#
# MODULO..: GEO                                                   #
# SISTEMA.: ACERTO DE CAIXA                                       #
# PROGRAMA: geo1014                                               #
# AUTOR...: EVANDRO SIMENES                                       #
# DATA....: 25/02/2016                                            #
#-----------------------------------------------------------------#



{
######################VIEW DE SALDO ATUAL DA CONTA CORRENTE DOS VENDEDORES###################################
create view vw_saldos_cc as
SELECT (SELECT cod_repres FROM geo_repres_paramet WHERE cod_cliente = a.cod_resp) cod_vendedor,
       a.sit_manifesto,
       a.cod_manifesto, 
       isnull((SELECT SUM(val_cheque)
                 FROM geo_acerto_chq
                WHERE cod_empresa = a.cod_empresa
                  AND cod_manifesto = a.cod_manifesto),0) val_cheques,
       isnull((SELECT val_dinheiro
         		 FROM geo_acerto_dhr
   			    WHERE cod_empresa = a.cod_empresa
			      AND cod_manifesto = a.cod_manifesto    ),0) val_dinheiro,
	   isnull((SELECT ISNULL(SUM(val_despesa),0)
                 FROM geo_acerto_despesas
                WHERE cod_empresa = a.cod_empresa
                  AND cod_manifesto = a.cod_manifesto),0) val_despesas,
       isnull((SELECT ISNULL(SUM(val_cheque + val_dinheiro + val_juros),0)
                 FROM geo_acerto_cobranca
                WHERE cod_empresa = a.cod_empresa
                  AND cod_manifesto = a.cod_manifesto),0) val_cobrancas,
       isnull((SELECT SUM(b.val_duplicata_item)
	             FROM fat_nf_mestre a2, fat_nf_item b, geo_remessa_movto c, cond_pgto d
	            WHERE a2.empresa = b.empresa
	              AND a2.trans_nota_fiscal = b.trans_nota_fiscal
	              AND c.cod_empresa = a2.empresa
	              AND c.trans_nota_fiscal = a2.trans_nota_fiscal
	              AND c.tipo_movto = 'S'
	              AND d.cod_cnd_pgto = a2.cond_pagto
	              AND d.cod_cnd_pgto <> '999'
	              AND d.ies_tipo = 'V'
	              AND b.item = c.cod_item
	              AND a2.sit_nota_fiscal = 'N'
	              AND a2.empresa = a.cod_empresa
	              AND c.cod_manifesto = a.cod_manifesto ),0) val_a_vista,
	   isnull((isnull((SELECT SUM(val_cheque)
                         FROM geo_acerto_chq
                        WHERE cod_empresa = a.cod_empresa
                          AND cod_manifesto = a.cod_manifesto),0) +
               isnull((SELECT val_dinheiro
                  		 FROM geo_acerto_dhr
   			            WHERE cod_empresa = a.cod_empresa
        			      AND cod_manifesto = a.cod_manifesto    ),0) +
        	   isnull((SELECT ISNULL(SUM(val_despesa),0)
                         FROM geo_acerto_despesas
                        WHERE cod_empresa = a.cod_empresa
                          AND cod_manifesto = a.cod_manifesto),0)),0) tot_cdd,
       isnull((isnull((SELECT ISNULL(SUM(val_cheque + val_dinheiro + val_juros),0)
                         FROM geo_acerto_cobranca
                        WHERE cod_empresa = a.cod_empresa
                          AND cod_manifesto = a.cod_manifesto),0) +
               isnull((SELECT SUM(b.val_duplicata_item)
	                     FROM fat_nf_mestre a2, fat_nf_item b, geo_remessa_movto c, cond_pgto d
         	            WHERE a2.empresa = b.empresa
	                      AND a2.trans_nota_fiscal = b.trans_nota_fiscal
         	              AND c.cod_empresa = a2.empresa
        	              AND c.trans_nota_fiscal = a2.trans_nota_fiscal
        	              AND c.tipo_movto = 'S'
          	              AND d.cod_cnd_pgto = a2.cond_pagto
           	              AND d.cod_cnd_pgto <> '999'
           	              AND d.ies_tipo = 'V'
         	              AND b.item = c.cod_item
          	              AND a2.sit_nota_fiscal = 'N'
          	              AND a2.empresa = a.cod_empresa
        	              AND c.cod_manifesto = a.cod_manifesto ),0)),0) tot_vco,
       (isnull((isnull((isnull((SELECT ISNULL(SUM(val_cheque + val_dinheiro + val_juros),0)
                         FROM geo_acerto_cobranca
                        WHERE cod_empresa = a.cod_empresa
                          AND cod_manifesto = a.cod_manifesto),0) +
               isnull((SELECT SUM(b.val_duplicata_item)
	                     FROM fat_nf_mestre a2, fat_nf_item b, geo_remessa_movto c, cond_pgto d
         	            WHERE a2.empresa = b.empresa
	                      AND a2.trans_nota_fiscal = b.trans_nota_fiscal
         	              AND c.cod_empresa = a2.empresa
        	              AND c.trans_nota_fiscal = a2.trans_nota_fiscal
        	              AND c.tipo_movto = 'S'
          	              AND d.cod_cnd_pgto = a2.cond_pagto
           	              AND d.cod_cnd_pgto <> '999'
           	              AND d.ies_tipo = 'V'
         	              AND b.item = c.cod_item
          	              AND a2.sit_nota_fiscal = 'N'
          	              AND a2.empresa = a.cod_empresa
        	              AND c.cod_manifesto = a.cod_manifesto ),0)),0) - 
        	  isnull((isnull((SELECT SUM(val_cheque)
                         FROM geo_acerto_chq
                        WHERE cod_empresa = a.cod_empresa
                          AND cod_manifesto = a.cod_manifesto),0) +
               isnull((SELECT val_dinheiro
                  		 FROM geo_acerto_dhr
   			            WHERE cod_empresa = a.cod_empresa
        			      AND cod_manifesto = a.cod_manifesto    ),0) +
        	   isnull((SELECT ISNULL(SUM(val_despesa),0)
                         FROM geo_acerto_despesas
                        WHERE cod_empresa = a.cod_empresa
                          AND cod_manifesto = a.cod_manifesto),0)),0)),0) * (-1)) diferenca
  FROM geo_manifesto a 
 WHERE a.cod_empresa = '01'
######################################### FIM DA VIEW #################################################
}

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
   DEFINE mr_icms                          RECORD LIKE icms.*
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
   DEFINE m_column_titulo       VARCHAR(50)
   DEFINE m_column_val_bruto    VARCHAR(50)
   DEFINE m_refer_tot_pagto     VARCHAR(50)
   DEFINE m_refer_tot_saldo     VARCHAR(50)
   DEFINE m_refer_saldo_vendedor VARCHAR(50)
   DEFINE m_refer_tot_bruto     VARCHAR(50)
   DEFINE m_refer_saldo_cc     VARCHAR(50)
   DEFINE m_button_baixa_titulos_que_deveriam_estar_baixados VARCHAR(50)
   DEFINE m_column_val_saldo    VARCHAR(50)
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
                  dat_cheque  date,
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
   DEFINE ma_tela ARRAY[5000] OF RECORD
                 # selecionado  CHAR(1),
                 # cod_empresa  CHAR(2),
                  cod_cliente  CHAR(15),
                  num_nf       INTEGER,
                  ser_nf       CHAR(3),
                  titulo       CHAR(20),
                  val_bruto    DECIMAL(20,2),
                  data_pagto   date,
                  portador     CHAR(20),
                  val_cheque  DECIMAL(20,2),
                  val_dinheiro DECIMAL(20,2),
                  val_saldo    DECIMAL(20,2)
              END RECORD
   DEFINE ma_tipo ARRAY[5000] OF RECORD
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
             val_bruto DECIMAL(20,2)
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
                         saldo_vendedor DECIMAL(20,2),
                         data_movto    date,
                         num_aviso_rec INTEGER,
                         val_tot_cobrancas DECIMAL(20,2)
                  end record 
   DEFINE M_REFER_NUM_AVISO_REC VARCHAR(50)
   DEFINE m_refer_val_tot_cobrancas VARCHAR(50)
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
   DEFINE m_botao_estornar             varchar(50)
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
   DEFINE m_refer_data_movto 		   VARCHAR(50)
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
   define m_button_geranf              varchar(50)
   define m_cancel_button              varchar(50)

   define m_menuitem2                  varchar(50)
   define m_ok_button2                 varchar(50)
   define m_cancel_button2             varchar(50)
   DEFINE m_confirma_item              SMALLINT

#-------------------#
 FUNCTION geo1014()
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
   	  CALL geo1014_exec_proc()
      CALL geo1014_tela()
   END IF

END FUNCTION

#-------------------#
 FUNCTION geo1014_tela()
#-------------------#

   DEFINE l_label        VARCHAR(50)
        , l_splitter     VARCHAR(50)
        , l_status       SMALLINT
        , l_panel_center VARCHAR(10)
        , l_tst CHAR(99)
     
     
     #CALL vdp0749y_reprocessa_boleto(1034)
     #CALL vdp0749y_reprocessa_boleto(1070)
     
     #LET mr_tela.data_movto = TODAY
     
     #cria janela principal do tipo LDIALOG
     LET m_form_principal = _ADVPL_create_component(NULL,"LDIALOG")
     CALL _ADVPL_set_property(m_form_principal,"TITLE","ACERTO DE CAIXA")
     CALL _ADVPL_set_property(m_form_principal,"ENABLE_ESC_CLOSE",FALSE)
     CALL _ADVPL_set_property(m_form_principal,"SIZE",1200,650)#   1024,725)
     
     #
     #
     #
     # INICIO MENU

     #cria menu
     LET m_toolbar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_principal)

     
     
	#botao INFORMAR
	 {LET m_consulta_ativa = FALSE
     LET m_botao_inform = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_inform,"EVENT","geo1014_teste")}
     
     LET m_botao_incluir = _ADVPL_create_component(NULL,"LCREATEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_incluir,"EVENT","geo1014_incluir")
     CALL _ADVPL_set_property(m_botao_incluir,"CONFIRM_EVENT","geo1014_grava_acerto")
     CALL _ADVPL_set_property(m_botao_incluir,"CANCEL_EVENT","geo1014_cancelar_informar")

     LET m_botao_modificar = _ADVPL_create_component(NULL,"LUPDATEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_modificar,"EVENT","geo1014_modificar")
     CALL _ADVPL_set_property(m_botao_modificar,"CONFIRM_EVENT","geo1014_grava_acerto")
     CALL _ADVPL_set_property(m_botao_modificar,"CANCEL_EVENT","geo1014_cancelar_informar")

     LET m_botao_excluir = _ADVPL_create_component(NULL,"LDELETEBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_excluir,"EVENT","geo1014_excluir")
     
     LET m_botao_consultar = _ADVPL_create_component(NULL,"LFINDBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_consultar,"EVENT","geo1014_consultar")
     CALL _ADVPL_set_property(m_botao_consultar,"CONFIRM_EVENT","geo1014_confirma_consulta")
     CALL _ADVPL_set_property(m_botao_consultar,"CANCEL_EVENT","geo1014_cancelar_consulta")

     LET m_botao_primeiro = _ADVPL_create_component(NULL,"LFIRSTBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_primeiro,"EVENT","geo1014_primeiro")
     
     LET m_botao_anterior = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_anterior,"EVENT","geo1014_anterior")
     
     LET m_botao_seguinte = _ADVPL_create_component(NULL,"LNEXTBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_seguinte,"EVENT","geo1014_seguinte")
     
     LET m_botao_ultimo = _ADVPL_create_component(NULL,"LLASTBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_ultimo,"EVENT","geo1014_ultimo")
     
   
     #botao RELATORIO
     LET m_botao_print = _ADVPL_create_component(NULL,"LPRINTBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_print,"EVENT","geo1014_processa_relatorio")

     #botao PROCESSAR
     LET m_botao_process = _ADVPL_create_component(NULL,"LPROCESSBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_process,"EVENT","geo1014_processar")
     
    #botao ESTORNAR
     LET m_botao_estornar = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_estornar,"IMAGE","ESTORNO_EX")
     CALL _ADVPL_set_property(m_botao_estornar,"EVENT","geo1014_estornar")
    
     LET m_botao_despesas   = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_despesas,"EVENT","geo1014_despesas")
     CALL _ADVPL_set_property(m_botao_despesas,"IMAGE","despesas")
     CALL _ADVPL_set_property(m_botao_despesas,"TYPE","NO_CONFIRM")
     
     LET m_botao_manifesto   = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_manifesto,"EVENT","geo1014_manifesto")
     CALL _ADVPL_set_property(m_botao_manifesto,"IMAGE","IconManifesto")
     CALL _ADVPL_set_property(m_botao_manifesto,"TYPE","NO_CONFIRM")
     
     LET m_botao_retorno   = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_retorno,"EVENT","geo1014_retorno")
     CALL _ADVPL_set_property(m_botao_retorno,"IMAGE","IconRetorno")
     CALL _ADVPL_set_property(m_botao_retorno,"TYPE","NO_CONFIRM")
     
     LET m_botao_carga   = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_carga,"EVENT","geo1014_carga")
     CALL _ADVPL_set_property(m_botao_carga,"IMAGE","RetornoCarga")
     CALL _ADVPL_set_property(m_botao_carga,"TYPE","NO_CONFIRM")
     
     LET m_botao_cobranca   = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_botao_cobranca,"EVENT","geo1014_cobranca")
     CALL _ADVPL_set_property(m_botao_cobranca,"IMAGE","IconCobranca")
     CALL _ADVPL_set_property(m_botao_cobranca,"TYPE","NO_CONFIRM")
     
    LET m_button_geranf   = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar)
     CALL _ADVPL_set_property(m_button_geranf,"EVENT","geo1014_gera_nfr")
     CALL _ADVPL_set_property(m_button_geranf,"IMAGE","GERAR_NF")
     CALL _ADVPL_set_property(m_button_geranf,"TYPE","NO_CONFIRM")
     
     
     #botao sair
     LET m_botao_quit = _ADVPL_create_component(NULL,"LQUITBUTTON",m_toolbar)
     
     #BOTAO UTILIZADO PARA ARRUMAR OS TITULOS QUE ESTAVAM EM ABERTO INDEVIDAMENTE
     #LET m_button_baixa_titulos_que_deveriam_estar_baixados   = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar)
     #CALL _ADVPL_set_property(m_button_baixa_titulos_que_deveriam_estar_baixados,"EVENT","geo1014_baixa_titulos_que_deveriam_estar_baixados")
     #CALL _ADVPL_set_property(m_button_baixa_titulos_que_deveriam_estar_baixados,"TYPE","NO_CONFIRM")
     


     LET m_status_bar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_principal)

     #  FIM MENU
 
      #cria panel para campos de filtro 
      LET m_panel_1 = _ADVPL_create_component(NULL,"LPANEL",m_form_principal)
      CALL _ADVPL_set_property(m_panel_1,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_panel_1,"HEIGHT",550)
      
     #cria panel  
     LET m_panel_reference1 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel_1)
     CALL _ADVPL_set_property(m_panel_reference1,"TITLE","ACERTO DE CAIXA")
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
	  CALL _ADVPL_set_property(m_refer_cod_manifesto,"VALID","geo1014_valid_cod_manifesto")
	  CALL _ADVPL_set_property(m_refer_cod_manifesto,"POSITION",100,29)
      #cria campo den_roteiro
     
     LET m_zoom_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_reference1)
	   CALL _ADVPL_set_property(m_zoom_item,"EDITABLE",TRUE)
	   CALL _ADVPL_set_property(m_zoom_item,"POSITION",201,29)
	   CALL _ADVPL_set_property(m_zoom_item,"IMAGE", "BTPESQ")
	   CALL _ADVPL_set_property(m_zoom_item,"CLICK_EVENT","geo1014_zoom_manifesto")
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
	  #CALL _ADVPL_set_property(m_refer_campos,"VALID","geo1014_valid_")
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
	  #CALL _ADVPL_set_property(m_refer_campos,"VALID","geo1014_valid_")
	  CALL _ADVPL_set_property(m_refer_campos,"POSITION",530,59)
      #cria campo den_roteiro
    
  LET m_refer_campos = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_campos,"VARIABLE",mr_tela,"den_transp")
  CALL _ADVPL_set_property(m_refer_campos,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_campos,"LENGTH",25)
  CALL _ADVPL_set_property(m_refer_campos,"POSITION",622,59)
  
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
	  CALL _ADVPL_set_property(l_label,"TEXT","Placa:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",860,60)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
	LET m_refer_campos = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
	  CALL _ADVPL_set_property(m_refer_campos,"VARIABLE",mr_tela,"placa_veic")
	  CALL _ADVPL_set_property(m_refer_campos,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_refer_campos,"LENGTH",15)
	  #CALL _ADVPL_set_property(m_refer_campos,"VALID","geo1014_valid_")
	  CALL _ADVPL_set_property(m_refer_campos,"POSITION",910,59)
      #cria campo den_roteiro
    
LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
	  CALL _ADVPL_set_property(l_label,"TEXT","Data Movimentação:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",860,30)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
	LET m_refer_data_movto = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel_reference1)
	  CALL _ADVPL_set_property(m_refer_data_movto,"VARIABLE",mr_tela,"data_movto")
	  CALL _ADVPL_set_property(m_refer_data_movto,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_refer_data_movto,"POSITION",910,29)
      #cria campo den_roteiro
    
LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
	  CALL _ADVPL_set_property(l_label,"TEXT","AR:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",1050,30)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
	LET m_refer_num_aviso_rec = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
	  CALL _ADVPL_set_property(m_refer_num_aviso_rec,"VARIABLE",mr_tela,"num_aviso_rec")
	  CALL _ADVPL_set_property(m_refer_num_aviso_rec,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_refer_num_aviso_rec,"POSITION",1100,29)
      #cria campo den_roteiro
    

#cria panel para campos de filtro 
      LET l_panel_center = _ADVPL_create_component(NULL,"LPANEL",m_panel_reference1)
      CALL _ADVPL_set_property(l_panel_center,"ALIGN","BOTTOM")
      CALL _ADVPL_set_property(l_panel_center,"HEIGHT",450)
      
  
  #cria panel  
     LET m_panel_reference2 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel_center)
     CALL _ADVPL_set_property(m_panel_reference2,"TITLE","")
     CALL _ADVPL_set_property(m_panel_reference2,"ALIGN","TOP")
     CALL _ADVPL_set_property(m_panel_reference2,"HEIGHT",400)


 #cria array
      LET m_table_reference1 = _ADVPL_create_component(NULL,"LBROWSEEX",m_panel_reference2)
      CALL _ADVPL_set_property(m_table_reference1,"SIZE",1100,400)
      CALL _ADVPL_set_property(m_table_reference1,"CAN_ADD_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference1,"CAN_REMOVE_ROW",FALSE)
      CALL _ADVPL_set_property(m_table_reference1,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_table_reference1,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_table_reference1,"ENABLE",TRUE)
	  CALL _ADVPL_set_property(m_table_reference1,"POSITION",10,400)
      
      
      {LET m_column_selecionado = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_table_reference3)
      CALL _ADVPL_set_property(m_refer_ies_seleciona,"VARIABLE","selecionado")
      CALL _ADVPL_set_property(m_refer_ies_seleciona,"HEADER"," ")
      CALL _ADVPL_set_property(m_refer_ies_seleciona,"COLUMN_SIZE",10)
      CALL _ADVPL_set_property(m_refer_ies_seleciona,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_refer_ies_seleciona,"EDIT_COMPONENT","LCHECKBOX")
      CALL _ADVPL_set_property(m_refer_ies_seleciona,"EDIT_PROPERTY","VALUE_CHECKED","S")
      CALL _ADVPL_set_property(m_refer_ies_seleciona,"EDIT_PROPERTY","VALUE_NCHECKED","N")
      CALL _ADVPL_set_property(m_refer_ies_seleciona,"IMAGE_HEADER","CHECKED")
      CALL _ADVPL_set_property(m_refer_ies_seleciona,"HEADER_CLICK_EVENT","impe1001_checkbox_header")
      }
      
      #cria campo do array: cod_cliente
      LET m_column_cod_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_cod_cliente,"VARIABLE","cod_cliente")
      CALL _ADVPL_set_property(m_column_cod_cliente,"HEADER","Cliente")
      CALL _ADVPL_set_property(m_column_cod_cliente,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_column_cod_cliente,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_cod_cliente,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_column_cod_cliente,"EDIT_PROPERTY","LENGTH",15) 
      #CALL _ADVPL_set_property(m_column_cod_cliente,"EDIT_PROPERTY","VALID","geo1014_valid_cod_item")
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
      
       
     {   #cria campo do array: cod_cliente
      LET m_column_val_pagto = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_val_pagto,"VARIABLE","val_pagto")
      CALL _ADVPL_set_property(m_column_val_pagto,"HEADER","Vl. Pagto")
      CALL _ADVPL_set_property(m_column_val_pagto,"COLUMN_SIZE", 35)
      CALL _ADVPL_set_property(m_column_val_pagto,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_val_pagto,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_column_val_pagto,"EDIT_PROPERTY","LENGTH",20,2) 
      CALL _ADVPL_set_property(m_column_val_pagto,"EDITABLE", FALSE)
      CALL _ADVPL_set_property(m_column_val_pagto,"PICTURE","@E R$999999999999999999.99")
      }
      
       
  #cria campo do array: cod_cliente
      LET m_column_data_pagto = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference1)
      CALL _ADVPL_set_property(m_column_data_pagto,"VARIABLE","data_pagto")
      CALL _ADVPL_set_property(m_column_data_pagto,"HEADER","Dt. Pagto")
      CALL _ADVPL_set_property(m_column_data_pagto,"COLUMN_SIZE", 35)
      CALL _ADVPL_set_property(m_column_data_pagto,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_column_data_pagto,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_column_data_pagto,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_column_data_pagto,"EDITABLE", FALSE)
      
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
      
      
      LET m_column_cheque = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_table_reference1)
      CALL _ADVPL_set_property(m_column_cheque,"COLUMN_SIZE",20)
      CALL _ADVPL_set_property(m_column_cheque,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_column_cheque,"NO_VARIABLE",TRUE)
      CALL _ADVPL_set_property(m_column_cheque,"IMAGE", "MAN_EDIT")
      CALL _ADVPL_set_property(m_column_cheque,"BEFORE_EDIT_EVENT","geo1014_vincula_cheque")
 
    # let ma_pedidos[1].num_pedido = '123'
     CALL _ADVPL_set_property(m_table_reference1,"SET_ROWS",ma_tela,0)
     CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)
 
   
  
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Saldo Atual Vendedor:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",50,485)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  LET m_refer_saldo_cc = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_saldo_cc,"VARIABLE",mr_tela,"saldo_cc")
  CALL _ADVPL_set_property(m_refer_saldo_cc,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_saldo_cc,"LENGTH",10,2)
  CALL _ADVPL_set_property(m_refer_saldo_cc,"POSITION",50,499)
  
  
      #cria campo den_roteiro
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Total Bruto:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",200,485)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  LET m_refer_tot_bruto = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_tot_bruto,"VARIABLE",mr_tela,"tot_bruto")
  CALL _ADVPL_set_property(m_refer_tot_bruto,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_tot_bruto,"LENGTH",10,2)
  CALL _ADVPL_set_property(m_refer_tot_bruto,"POSITION",200,499)
      #cria campo den_roteiro
      
   #cria campo den_roteiro
      
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Total Despesas:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",350,485)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  LET m_refer_tot_pagto = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_tot_pagto,"VARIABLE",mr_tela,"tot_desp")
  CALL _ADVPL_set_property(m_refer_tot_pagto,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_tot_pagto,"LENGTH",10,2)
  CALL _ADVPL_set_property(m_refer_tot_pagto,"POSITION",350,499)

  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Recebido em Cheque:")
  CALL _ADVPL_set_property(l_label,"SIZE",150,15)
  CALL _ADVPL_set_property(l_label,"POSITION",500,485)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  LET m_refer_tot_chq_receb = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_tot_chq_receb,"VARIABLE",mr_tela,"tot_chq_receb")
  CALL _ADVPL_set_property(m_refer_tot_chq_receb,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_tot_chq_receb,"LENGTH",10,2)
  CALL _ADVPL_set_property(m_refer_tot_chq_receb,"POSITION",500,499)
  
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
   CALL _ADVPL_set_property(l_label,"TEXT","Recebido em Dinheiro:")
   CALL _ADVPL_set_property(l_label,"SIZE",150,15)
   CALL _ADVPL_set_property(l_label,"POSITION",650,485)
   CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

   LET m_refer_tot_din_receb = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
   CALL _ADVPL_set_property(m_refer_tot_din_receb,"VARIABLE",mr_tela,"tot_din_receb")
   CALL _ADVPL_set_property(m_refer_tot_din_receb,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_tot_din_receb,"LENGTH",12,2)
   CALL _ADVPL_set_property(m_refer_tot_din_receb,"VALID","geo1014_calcula_despesas")
   CALL _ADVPL_set_property(m_refer_tot_din_receb,"POSITION",650,499)

  #cria campo den_roteiro
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Saldo Acerto:")
  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
  CALL _ADVPL_set_property(l_label,"POSITION",800,485)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  LET m_refer_tot_saldo = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_tot_saldo,"VARIABLE",mr_tela,"tot_saldo")
  CALL _ADVPL_set_property(m_refer_tot_saldo,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_tot_saldo,"LENGTH",10,2)
  CALL _ADVPL_set_property(m_refer_tot_saldo,"POSITION",800,499)

  #cria campo den_roteiro
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Novo Saldo Vendedor:")
  CALL _ADVPL_set_property(l_label,"SIZE",150,15)
  CALL _ADVPL_set_property(l_label,"POSITION",950,485)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  LET m_refer_saldo_vendedor = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_saldo_vendedor,"VARIABLE",mr_tela,"saldo_vendedor")
  CALL _ADVPL_set_property(m_refer_saldo_vendedor,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_saldo_vendedor,"LENGTH",10,2)
  CALL _ADVPL_set_property(m_refer_saldo_vendedor,"POSITION",950,499)

  #cria campo den_roteiro
  LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
  CALL _ADVPL_set_property(l_label,"TEXT","Valor Cobranças:")
  CALL _ADVPL_set_property(l_label,"SIZE",150,15)
  CALL _ADVPL_set_property(l_label,"POSITION",1100,485)
  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)

  LET m_refer_val_tot_cobrancas = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
  CALL _ADVPL_set_property(m_refer_val_tot_cobrancas,"VARIABLE",mr_tela,"val_tot_cobrancas")
  CALL _ADVPL_set_property(m_refer_val_tot_cobrancas,"ENABLE",FALSE)
  CALL _ADVPL_set_property(m_refer_val_tot_cobrancas,"LENGTH",10,2)
  CALL _ADVPL_set_property(m_refer_val_tot_cobrancas,"POSITION",1100,499)

  CALL _ADVPL_set_property(m_table_reference1,"REFRESH")

  CALL _ADVPL_set_property(m_form_principal,"ACTIVATE",TRUE)

 END FUNCTION

#--------------------------#
FUNCTION geo1014_incluir()
#--------------------------#
   INITIALIZE mr_tela.*, ma_tela to null
   
   LET m_ind = 0
   #LET mr_tela.data_movto = TODAY
   LET m_funcao = "INCLUIR"
   LET m_consulta_ativa = FALSE
   CALL geo1014_cria_temp()
   
   CALL geo1014_carrega_cc_repres()
   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
   CALL _ADVPL_set_property(m_table_reference1,"SELECT_ITEM",1,1)
   
   #CALL _ADVPL_set_property(m_table_reference2,"ITEM_COUNT",0)
   #CALL _ADVPL_set_property(m_table_reference2,"REFRESH")

   CALL geo1014_habilita_campos_manutencao(TRUE,'INCLUIR')

END FUNCTION

#---------------------------#
FUNCTION geo1014_consultar()
#---------------------------#
   INITIALIZE mr_tela.*, ma_tela to null
   LET m_ind = 0
   LET m_funcao = "CONSULTAR"
   CALL geo1014_cria_temp()
   CALL geo1014_carrega_cc_repres()
   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
   CALL _ADVPL_set_property(m_table_reference1,"SELECT_ITEM",1,1)
   
   #CALL _ADVPL_set_property(m_table_reference2,"ITEM_COUNT",0)
   #CALL _ADVPL_set_property(m_table_reference2,"REFRESH")

   CALL geo1014_habilita_campos_manutencao(TRUE,'CONSULTAR')
END FUNCTION

#-----------------------------------#
FUNCTION geo1014_confirma_consulta()
#-----------------------------------#
   DEFINE l_sql     CHAR(5000)
   DEFINE l_manif   INTEGER
   
  LET l_sql = " SELECT DISTINCT cod_manifesto ",
              "   FROM geo_acerto ",
              "  WHERE cod_empresa = '",p_cod_empresa CLIPPED,"'"
  IF mr_tela.cod_manifesto <> 0 THEN
     LET l_sql = l_sql CLIPPED, " AND cod_manifesto = '",mr_tela.cod_manifesto,"'"
  END IF  
  
  PREPARE var_sql FROM l_sql
  DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_sql
  OPEN cq_consulta
  FETCH FIRST cq_consulta INTO mr_tela.cod_manifesto
  
  IF mr_tela.cod_manifesto IS NULL OR mr_tela.cod_manifesto = "" THEN
     CALL _ADVPL_message_box("Argumentos de pesquisa não encontrados")
     CALL geo1014_habilita_campos_manutencao(FALSE,'CONSULTAR')
     RETURN TRUE
  END IF 
  CALL geo1014_valid_cod_manifesto()
  CALL geo1014_habilita_campos_manutencao(FALSE,'CONSULTAR')
  LET m_consulta_ativa = TRUE
  RETURN TRUE
END FUNCTION

#------------------------------------#
FUNCTION geo1014_cancelar_consulta()
#------------------------------------#
   LET m_consulta_ativa = FALSE
   CALL geo1014_habilita_campos_manutencao(FALSE,'CONSULTAR')
END FUNCTION

#--------------------------#
FUNCTION geo1014_modificar()
#--------------------------#
   
   IF NOT m_consulta_ativa THEN
 	  CALL _ADVPL_message_box("Informe um manifesto antes de modificar o acerto.")
 	  RETURN FALSE
   END IF 
   
   IF mr_tela.sit_manifesto = "E" THEN
      CALL _ADVPL_message_box("O acerto desse manifesto já foi encerrado e não pode ser modificado.")
      RETURN FALSE
   END IF
   IF mr_tela.sit_manifesto = "T" THEN
      CALL _ADVPL_message_box("Este manifesto ainda está em trânsito e não pode ser modificado.")
      RETURN FALSE
   END IF  
   
   LET m_funcao = "MODIFICAR"
   CALL geo1014_carrega_cc_repres()
   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
   CALL _ADVPL_set_property(m_table_reference1,"SELECT_ITEM",1,1)
   
   #CALL _ADVPL_set_property(m_table_reference2,"ITEM_COUNT",0)
   #CALL _ADVPL_set_property(m_table_reference2,"REFRESH")

   CALL geo1014_habilita_campos_manutencao(TRUE,'MODIFICAR')
   
   
END FUNCTION


#---------------------------#
FUNCTION geo1014_informar()
#---------------------------#

   INITIALIZE mr_tela.*, ma_tela to null
   
   CALL geo1014_cria_temp()
   
   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
   CALL _ADVPL_set_property(m_table_reference1,"SELECT_ITEM",1,1)
   
   #CALL _ADVPL_set_property(m_table_reference2,"ITEM_COUNT",0)
   #CALL _ADVPL_set_property(m_table_reference2,"REFRESH")


   CALL geo1014_habilita_campos_manutencao(TRUE,'INCLUIR')
   
END FUNCTION

#--------------------------------------#
FUNCTION geo1014_carrega_movto_repres()
#--------------------------------------#
   DEFINE l_sql_stmt CHAR(5000)
   DEFINE l_count    INTEGER
   DEFINE l_ind      INTEGER
   DEFINE l_existe_dhr SMALLINT
   DEFINE l_tip_manifesto CHAR(1)
   
   INITIALIZE ma_tela TO NULL
   
   SELECT COUNT(*)
     INTO l_count
     FROM geo_acerto
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
   	   LET l_sql_stmt = " SELECT DISTINCT ",
   	                           " cod_cliente, ",
   	                           " num_nf, ",
   	                           " ser_nf, ",
   	                           " cod_titulo, ",
   	                           " val_bruto, ",
   	                           " dat_pagto, ",
   	                           " portador, ",
   	                           " val_cheque, ",
   	                           " val_dinheiro, ",
   	                           " val_saldo, ",
   	                           " 'V' ",
                          " FROM geo_acerto ",
                         " WHERE cod_empresa = '",p_cod_empresa,"'",
                         "   AND cod_manifesto = '",mr_tela.cod_manifesto,"'"
   	   LET l_sql_stmt = l_sql_stmt CLIPPED, " UNION ALL "
   	   {LET l_sql_stmt = l_sql_stmt CLIPPED, " SELECT    ",
							     "  a.codcli, ",
							     "  b.nota_fiscal, ",
							     "  b.serie_nota_fiscal, ",
							     "  c.docum_cre, ",
							     "  c.val_duplicata, ",
							     "  a.valpag, ",
							     "  a.datpag, ",
							     "  e.cod_portador, ",
							     "  0,",
							     "  a.valpag, ",
							     "  (c.val_duplicata - a.valpag), ",
							     "  g.ies_tipo ",
							 " FROM bd_ssm_prontaentrega_morrogrande.dbo.svnpag a, ",
							     "  geo_ope_env b, ",
							     "  fat_nf_duplicata c, ",
							     "  bd_ssm_prontaentrega_morrogrande.dbo.svnope d, ",
							     "  docum e, ",
							     "  fat_nf_mestre f, ",
							     "  cond_pgto g ",
							" WHERE a.codemp = b.cod_empresa ",
							  " AND a.numpag = d.numpag ",
							  " AND b.cod_ope= d.numope ",
							  " AND d.codven = a.codven ",
							  " AND a.codemp = d.codemp ",
							  " AND f.empresa = c.empresa ",
							  " AND f.trans_nota_fiscal = c.trans_nota_fiscal ",
							  " AND f.cond_pagto = g.cod_cnd_pgto",
							  " AND a.codven = b.cod_repres ",
							  " AND b.trans_nota_fiscal = c.trans_nota_fiscal ",
							  " AND b.cod_empresa = c.empresa ",
							  " AND d.codven = '",m_cod_repres,"'",
							  " AND b.cod_empresa = '",p_cod_empresa CLIPPED,"'",
							  " AND b.cod_empresa = e.cod_empresa ",
	   						  " AND c.docum_cre = e.num_docum ",
	   						  " AND e.num_docum NOT IN (SELECT DISTINCT cod_titulo ",
	   						  "                           FROM geo_acerto ",
	   						  "                          WHERE cod_empresa = '",p_cod_empresa,"' ",
	   						  "                            AND cod_manifesto = '",mr_tela.cod_manifesto,"')"
	   						  #" AND e.cod_portador >= 900 ",
	   						  #" ORDER BY g.ies_tipo DESC "}
	   	LET l_sql_stmt = l_sql_stmt CLIPPED," SELECT DISTINCT a.cliente, ",
                               " a.nota_fiscal,  ",
                               " a.serie_nota_fiscal, ", 
                               " c.docum_cre,  ",
                               " c.val_duplicata, ", 
                               " e.dat_emis,  ",
                               " e.cod_portador, ", 
                               " 0, ",
                               " c.val_duplicata, ", 
                               " c.val_duplicata,  ",
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
                        "   AND c.docum_cre         = e.num_docum ",
                        "   AND a.cond_pagto        = g.cod_cnd_pgto ",
                        "   AND h.cod_empresa       = a.empresa ",
                        "   AND i.cod_empresa       = a.empresa ",
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
                        "   AND i.cod_manifesto     = '",mr_tela.cod_manifesto,"' ",
                        " AND e.num_docum NOT IN (SELECT DISTINCT cod_titulo ",
	   						  "                           FROM geo_acerto ",
	   						  "                          WHERE cod_empresa = h.cod_empresa ",
	   						  "                            AND cod_manifesto = i.cod_manifesto)"
	   						  
                        #"   ORDER BY g.ies_tipo "
   ELSE
	   {LET l_sql_stmt = " SELECT    ",
							     "  a.codcli, ",
							     "  b.nota_fiscal, ",
							     "  b.serie_nota_fiscal, ",
							     "  c.docum_cre, ",
							     "  c.val_duplicata, ",
							     "  a.valpag, ",
							     "  a.datpag, ",
							     "  e.cod_portador, ",
							     "  0,",
							     "  a.valpag, ",
							     "  (c.val_duplicata - a.valpag), ",
							     "  g.ies_tipo ",
							 " FROM bd_ssm_prontaentrega_morrogrande.dbo.svnpag a, ",
							     "  geo_ope_env b, ",
							     "  fat_nf_duplicata c, ",
							     "  bd_ssm_prontaentrega_morrogrande.dbo.svnope d, ",
							     "  docum e, ",
							     "  fat_nf_mestre f, ",
							     "  cond_pgto g ",
							" WHERE a.codemp = b.cod_empresa ",
							  " AND a.numpag = d.numpag ",
							  " AND b.cod_ope= d.numope ",
							  " AND d.codven = a.codven ",
							  " AND a.codemp = d.codemp ",
							  " AND f.empresa = c.empresa ",
							  " AND f.trans_nota_fiscal = c.trans_nota_fiscal ",
							  " AND f.cond_pagto = g.cod_cnd_pgto",
							  " AND a.codven = b.cod_repres ",
							  " AND b.trans_nota_fiscal = c.trans_nota_fiscal ",
							  " AND b.cod_empresa = c.empresa ",
							  " AND d.codven = '",m_cod_repres,"'",
							  " AND b.cod_empresa = '",p_cod_empresa CLIPPED,"'",
							  " AND b.cod_empresa = e.cod_empresa ",
	   						  " AND c.docum_cre = e.num_docum ",
	   						  #" AND e.cod_portador >= 900 ",
	   						  " ORDER BY g.ies_tipo DESC "}
	   LET l_sql_stmt = " SELECT DISTINCT a.cliente, ",
                               " a.nota_fiscal,  ",
                               " a.serie_nota_fiscal, ", 
                               " c.docum_cre,  ",
                               " c.val_duplicata, ", 
                               " e.dat_emis,  ",
                               " e.cod_portador, ", 
                               " 0, ",
                               " c.val_duplicata, ", 
                               " c.val_duplicata,  ",
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
                        "   AND a.trans_nota_fiscal = c.trans_nota_fiscal ",
                        "   AND c.docum_cre         = e.num_docum ",
                        "   AND a.cond_pagto        = g.cod_cnd_pgto ",
                        "   AND h.cod_empresa       = a.empresa ",
                        "   AND i.cod_empresa       = a.empresa ",
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
                        "   AND i.cod_manifesto     = '",mr_tela.cod_manifesto,"' ",
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
	SELECT val_dinheiro
	  INTO mr_tela.tot_din_receb
	  FROM geo_acerto_dhr
	 WHERE cod_empresa = p_cod_empresa
	   AND cod_manifesto = mr_tela.cod_manifesto
	IF sqlca.sqlcode <> 0 THEN
	   LET mr_tela.tot_din_receb = 0
	   LET l_existe_dhr = FALSE
	END IF 
	
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
		   LET mr_tela.tot_chq_receb = mr_tela.tot_chq_receb + ma_tela[m_ind].val_cheque
		
		   IF NOT l_existe_dhr THEN
		      LET mr_tela.tot_din_receb = mr_tela.tot_din_receb + ma_tela[m_ind].val_dinheiro
 		   END IF 
		
		   CALL _ADVPL_set_property(m_table_reference1,"CLEAR_LINE_COLOR",m_ind)
		END IF 
		
		LET m_ind = m_ind + 1
		
	END FOREACH
	
	IF m_ind > 1 THEN
		LET m_ind = m_ind - 1
	END IF 
	
	IF l_count > 0 THEN
	   DELETE FROM t_cheques WHERE 1=1;
	   INSERT INTO t_cheques
	   SELECT cod_empresa, num_cheque, val_cheque, cod_titulo
	     FROM geo_acerto_chq
	    WHERE cod_empresa = p_cod_empresa
	      AND cod_manifesto = mr_tela.cod_manifesto
	   
	   IF sqlca.sqlcode <> 0 THEN
	      CALL log003_err_sql("INSERT","t_cheques")
	   END IF
	END IF 
	
	CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",m_ind)
    CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
	#CALL geo1014_cancelar_informar()
	CALL _ADVPL_set_property(m_table_reference1,"ENABLE",TRUE)
	
END FUNCTION
 
#---------------------------#
 function geo1014_confirmar_informar()
#---------------------------#

   CALL geo1014_habilita_campos_manutencao(FALSE,'INCLUIR')

   RETURN TRUE

 end function

#-----------------------------------#
function geo1014_cancelar_informar()
#-----------------------------------#
   call geo1014_habilita_campos_manutencao(FALSE,'INCLUIR')
   RETURN TRUE
end function

#-------------------------------------------------------------#
 function geo1014_habilita_campos_manutencao(l_status,l_funcao)
#-------------------------------------------------------------#
   DEFINE l_status smallint
   define l_funcao char(20)
   
   IF l_funcao <> "MODIFICAR" THEN
      CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",l_status)
      CALL _ADVPL_set_property(m_zoom_item,"ENABLE",l_status) 
   END IF
   CALL _ADVPL_set_property(m_refer_data_movto,"ENABLE",l_status)  
   CALL _ADVPL_set_property(m_refer_data_movto,"EDITABLE",l_status)  
   CALL _ADVPL_set_property(m_column_cheque,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_refer_tot_din_receb,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_table_reference1,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_table_reference1,"CAN_REMOVE_ROW",l_status)
   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",m_ind)
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")

END FUNCTION


#--------------------------------------------------------------------#
FUNCTION geo1014_exibe_mensagem_barra_status(l_mensagem,l_tipo_mensagem)
#--------------------------------------------------------------------#

   DEFINE l_mensagem               CHAR(500),
          l_tipo_mensagem          CHAR(010),
          l_tipo_mensagem_original CHAR(015)

   LET l_tipo_mensagem_original = LOG_retorna_tipo_mensagem_original(UPSHIFT(l_tipo_mensagem),TRUE)
   CALL _ADVPL_set_property(m_status_bar,l_tipo_mensagem_original CLIPPED," "||l_mensagem CLIPPED)

 END FUNCTION

 
#--------------------------------------------------------------------#
 function geo1014_exibe_dados()
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
#---------------------------------#
FUNCTION geo1014_calcula_despesas()
#---------------------------------#

   SELECT SUM(val_despesa)
     INTO mr_tela.tot_desp
     FROM geo_acerto_despesas
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   
   IF mr_tela.tot_desp IS NULL OR mr_tela.tot_desp = " " THEN
      LET mr_tela.tot_desp = 0
   END IF 
   
   LET mr_tela.tot_saldo = (mr_tela.tot_bruto) - (mr_tela.tot_desp + mr_tela.tot_din_receb + mr_tela.tot_chq_receb - mr_tela.val_tot_cobrancas)
   LET mr_tela.saldo_vendedor = mr_tela.saldo_cc - mr_tela.tot_saldo
   LET mr_tela.tot_saldo = mr_tela.tot_saldo * (-1)
   
   CALL geo1014_busca_tot_cobrancas()
   
   CALL _ADVPL_set_property(m_refer_tot_saldo,"REFRESH")
   CALL _ADVPL_set_property(m_refer_saldo_vendedor,"REFRESH")
END FUNCTION

#------------------------------------#
FUNCTION geo1014_busca_tot_cobrancas()
#------------------------------------#
    LET mr_tela.val_tot_cobrancas = 0
	SELECT SUM(val_dinheiro + val_cheque + val_juros)
	  INTO mr_tela.val_tot_cobrancas
	  FROM geo_acerto_cobranca
	 WHERE cod_empresa = p_cod_empresa
	   AND cod_manifesto = mr_tela.cod_manifesto
	IF mr_tela.val_tot_cobrancas IS NULL OR mr_tela.val_tot_cobrancas = " " THEN
		LET mr_tela.val_tot_cobrancas = 0
	END IF
END FUNCTION
 
#---------------------------------------#
 function geo1014_valid_cod_manifesto()
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

   IF m_funcao = "INCLUIR" THEN
      IF mr_tela.sit_manifesto = "T" THEN
         CALL _ADVPL_message_box("Este manifesto ainda está em trânsito e não pode ser acertado.")
         RETURN FALSE
      END IF  
   
      SELECT DISTINCT cod_empresa
        FROM geo_acerto
       WHERE cod_empresa = p_cod_empresa
         AND cod_manifesto = mr_tela.cod_manifesto
      IF sqlca.sqlcode = 0 THEN
         CALL _ADVPL_message_box("Manifesto já possui acerto.")
         RETURN FALSE
      END IF 
      
      SELECT MAX(dat_hor_emissao)
        #INTO mr_tela.data_movto
        FROM fat_nf_mestre
       WHERE empresa = p_cod_empresa
         AND trans_nota_fiscal IN (SELECT trans_nota_fiscal
                                     FROM geo_remessa_movto
                                    WHERE cod_empresa = p_cod_empresa
                                      AND cod_manifesto = mr_tela.cod_manifesto)
        
   END IF  
   
   IF m_funcao = "MODIFICAR" OR m_funcao = "CONSULTAR" THEN
      SELECT DISTINCT cod_empresa
        FROM geo_acerto
       WHERE cod_empresa = p_cod_empresa
         AND cod_manifesto = mr_tela.cod_manifesto
      IF sqlca.sqlcode <> 0 THEN
         CALL _ADVPL_message_box("Manifesto não tem acerto.")
         RETURN FALSE
      END IF 
      
      SELECT DISTINCT data_movto
        INTO mr_tela.data_movto
        FROM geo_acerto
       WHERE cod_empresa = p_cod_empresa
         AND cod_manifesto = mr_tela.cod_manifesto
   END IF  
   
   IF m_funcao = "MODIFICAR" THEN
      IF mr_tela.sit_manifesto = "E" THEN
         CALL _ADVPL_message_box("O acerto desse manifesto já está encerrado e não pode ser modificado.")
         RETURN FALSE
      END IF
      IF mr_tela.sit_manifesto = "T" THEN
         CALL _ADVPL_message_box("Este manifesto ainda está em trânsito e não pode ser modificado.")
         RETURN FALSE
      END IF  
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
  
    
    CALL geo1014_carrega_movto_repres()
    
    CALL geo1014_calcula_despesas()
    CALL geo1014_carrega_cc_repres() 
    LET mr_tela.tot_saldo = (mr_tela.tot_bruto) - (mr_tela.tot_desp + mr_tela.tot_din_receb + mr_tela.tot_chq_receb - mr_tela.val_tot_cobrancas)
    LET mr_tela.saldo_vendedor = mr_tela.saldo_cc - mr_tela.tot_saldo
    LET mr_tela.tot_saldo = mr_tela.tot_saldo * (-1)
    
    
    LET mr_tela.num_aviso_rec = 0
    
    
    SELECT num_aviso_rec
      INTO mr_tela.num_aviso_rec
      FROM geo_manifesto_ar
     WHERE cod_empresa = p_cod_empresa
       AND cod_manifesto = mr_tela.cod_manifesto
    
    CALL _ADVPL_set_property(m_refer_tot_din_receb,"ENABLE",TRUE)
    CALL _ADVPL_set_property(m_refer_tot_saldo,"REFRESH")
    CALL _ADVPL_set_property(m_refer_saldo_vendedor,"REFRESH")
    
    return true 
 
 end function 
 
 #--------------------------------#
 FUNCTION geo1014_vincula_cheque()
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
    
    SELECT val_dinheiro
      INTO mr_receb.val_dinheiro
      FROM geo_acerto
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
     
	 {#botao INFORMAR
     LET m_botao_inform_cheque = _ADVPL_create_component(NULL,"LINFORMBUTTON",m_toolbar_cheque)
     CALL _ADVPL_set_property(m_botao_inform_cheque,"EVENT","geo1014_informar_cheque")
     CALL _ADVPL_set_property(m_botao_inform_cheque,"CONFIRM_EVENT","geo1014_grava_cheques")
     CALL _ADVPL_set_property(m_botao_inform_cheque,"CANCEL_EVENT","geo1014_cancela_cheques")}
	 
     
     LET m_botao_cheque_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar_cheque)
     CALL _ADVPL_set_property(m_botao_cheque_confirma,"TYPE","NO_CONFIRM")
     CALL _ADVPL_set_property(m_botao_cheque_confirma,"IMAGE","CONFIRM_EX")
     CALL _ADVPL_set_property(m_botao_cheque_confirma,"CLICK_EVENT","geo1014_grava_cheques")

     LET m_botao_cheque_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar_cheque)
     CALL _ADVPL_set_property(m_botao_cheque_cancela,"TYPE","NO_CONFIRM")
     CALL _ADVPL_set_property(m_botao_cheque_cancela,"IMAGE","CANCEL_EX")
     CALL _ADVPL_set_property(m_botao_cheque_cancela,"CLICK_EVENT","geo1014_cancela_cheques")#botao sair
     
     LET m_botao_cheque_novo = _ADVPL_create_component(NULL,"LMENUBUTTON",m_toolbar_cheque)
     CALL _ADVPL_set_property(m_botao_cheque_novo,"TYPE","NO_CONFIRM")
     CALL _ADVPL_set_property(m_botao_cheque_novo,"IMAGE","IconCheque")
     CALL _ADVPL_set_property(m_botao_cheque_novo,"CLICK_EVENT","geo1014_novo_cheque")#botao sair
     
     
     
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
     
     
     #LET m_layoutmanager_refence_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_reference_cheque)
     #CALL _ADVPL_set_property(m_layoutmanager_refence_1,"MARGIN",TRUE)
     #CALL _ADVPL_set_property(m_layoutmanager_refence_1,"COLUMNS_COUNT",2)

     # CABEÇALHO
     
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
  
  
      {LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(l_label,"TEXT","Valor Pagto:")
	  CALL _ADVPL_set_property(l_label,"SIZE",100,15)
	  CALL _ADVPL_set_property(l_label,"POSITION",250,90)
	  CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	  CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
	  LET m_cheque_campos = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference_cheque)
	  CALL _ADVPL_set_property(m_cheque_campos,"VARIABLE",mr_receb,"val_pagto")
	  CALL _ADVPL_set_property(m_cheque_campos,"ENABLE",FALSE)
	  CALL _ADVPL_set_property(m_cheque_campos,"LENGTH",8,2)
	  CALL _ADVPL_set_property(m_cheque_campos,"POSITION",330,89)
      #cria campo den_roteiro
  }
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
	  CALL _ADVPL_set_property(m_cheque_check,"EDIT_PROPERTY","CHANGE_EVENT","geo1014_calcula_total")
      
      
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
      
      CALL geo1014_carrega_cheques()
      
      CALL _ADVPL_set_property(m_table_reference2,"SET_ROWS",ma_cheque,0)
      CALL _ADVPL_set_property(m_table_reference2,"ITEM_COUNT",m_ind_cheque)
   
      CALL _ADVPL_set_property(m_table_reference2,"REFRESH")
	  
	  #CALL _ADVPL_get_property(m_botao_inform_cheque,"DO_CLICK")
      CALL _ADVPL_set_property(m_form_cheque,"ACTIVATE",TRUE)
      
 END FUNCTION 
 
 
 #--------------------------------#
 FUNCTION geo1014_carrega_cheques()
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
 	                            FROM geo_acerto_chq
 	                           WHERE cod_empresa = p_cod_empresa
 	                             AND cod_manifesto <> mr_tela.cod_manifesto
 	                             AND val_cheque = geo_rel_chq.val_bruto)
 	   #AND (cod_tit_rel IS NULL OR cod_tit_rel = "")
 	
 	
 	
 	LET m_ind_cheque = 1
 	FOREACH cq_cheques_vinc INTO ma_cheque[m_ind_cheque].*
 	   
 	   SELECT COUNT(*)
 	     INTO l_count
 	     FROM t_cheques
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
 	     FROM t_cheques
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
    #CALL geo1014_calcula_total()
 END FUNCTION

#--------------------------------#
 FUNCTION geo1014_calcula_total()
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
FUNCTION geo1014_informar_cheque()
#---------------------------------#

   

END FUNCTION

#--------------------------------#
FUNCTION geo1014_grava_cheques()
#--------------------------------#
   DEFINE l_ind       SMALLINT
   DEFINE l_arr_curr  SMALLINT
   DEFINE l_arr_count SMALLINT
   DEFINE l_dhr       DECIMAL(20,2)
   DEFINE l_sum       DECIMAL(20,2)
   
   LET l_arr_count = _ADVPL_get_property(m_table_reference1,"ITEM_COUNT")
   LET l_arr_curr = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   
   SELECT val_dinheiro
     INTO l_dhr
     FROM geo_acerto_dhr
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF l_dhr IS NULL OR l_dhr = " " THEN
      LET l_dhr = 0
   END IF 
   
   SELECT SUM(val_dinheiro)
     INTO l_sum
     FROM geo_acerto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF l_sum IS NULL OR l_sum = " " THEN
      LET l_sum = 0
   END IF 
   
   LET l_dhr = l_dhr - l_sum
   
   DELETE 
     FROM t_cheques
    WHERE cod_empresa = p_cod_empresa
      AND cod_tit_rel = mr_receb.titulo
   
   FOR l_ind = 1 TO 99
      IF ma_cheque[l_ind].num_cheque IS NULL OR ma_cheque[l_ind].num_cheque = "" THEN
         EXIT FOR
      END IF 
      
      IF ma_cheque[l_ind].check = "S" THEN
         
         INSERT INTO t_cheques VALUES (p_cod_empresa, ma_cheque[l_ind].num_cheque, ma_cheque[l_ind].val_cheque, mr_receb.titulo)  
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("INSERT","t_cheques")
            RETURN FALSE
         END IF
      END IF 
      
   END FOR 
   
   LET ma_tela[l_arr_curr].val_dinheiro = mr_receb.val_dinheiro
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
   
   CALL geo1014_recalcula_totais()
   
   CALL _ADVPL_set_property(m_refer_tot_chq_receb,"REFRESH")
   CALL _ADVPL_set_property(m_refer_tot_din_receb,"REFRESH")
   
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
FUNCTION geo1014_cancela_cheques()
#---------------------------------#
   CALL _ADVPL_get_property(m_botao_quit_cheque,"DO_CLICK") 
END FUNCTION

#---------------------------------------#
 function geo1014_zoom_manifesto()
#---------------------------------------#
   DEFINE l_where_clause   CHAR(1000)
   DEFINE l_ind            SMALLINT
   define l_zoom_item varchar(10)
   define l_selecao integer 
   define l_cod_cliente char(15)
   
    FOR l_ind = 1 TO 1000
       INITIALIZE ma_manifesto[l_ind].* TO NULL
    END FOR

    LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
    CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
    CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_manifesto)
    CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_manifesto")
    
    let mr_tela.cod_manifesto = ma_manifesto[1].cod_manifesto
    
    CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",l_ind)
    CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
	
 end function

#--------------------------------#
FUNCTION geo1014_grava_acerto()
#--------------------------------#
   DEFINE l_ind        SMALLINT
   DEFINE l_arr_curr   SMALLINT
   DEFINE lr_t_cheques RECORD
              cod_empresa CHAR(2),
              num_cheque CHAR(10),
              val_cheque DECIMAL(20,2),
              cod_tit_rel CHAR(14)
           END RECORD
   
   IF mr_tela.cod_manifesto IS NULL OR mr_tela.cod_manifesto = "" THEN
      CALL _ADVPL_message_box("Informe um manifesto")
      RETURN FALSE
   END IF
   
   IF mr_tela.data_movto IS NULL OR mr_tela.data_movto = " " THEN
      CALL _ADVPL_message_box("Informe a data de movimentação")
      RETURN FALSE
   END IF 
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   
   CALL log085_transacao("BEGIN")
   
   DELETE 
     FROM geo_acerto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","geo_acerto")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   FOR l_ind = 1 TO _ADVPL_get_property(m_table_reference1,"ITEM_COUNT")
      IF ma_tela[l_ind].val_dinheiro > 0 OR ma_tela[l_ind].val_cheque > 0 THEN
         INSERT INTO geo_acerto VALUES (p_cod_empresa,
                                        mr_tela.cod_manifesto,
                                        ma_tela[l_ind].cod_cliente,
                                        ma_tela[l_ind].num_nf,
                                        ma_tela[l_ind].ser_nf,
                                        ma_tela[l_ind].titulo,
                                        ma_tela[l_ind].val_bruto,
                                        ma_tela[l_ind].val_bruto,
                                        #ma_tela[l_ind].val_pagto,
                                        ma_tela[l_ind].data_pagto,
                                        ma_tela[l_ind].portador,
                                        ma_tela[l_ind].val_cheque,
                                        ma_tela[l_ind].val_dinheiro,
                                        ma_tela[l_ind].val_saldo,
                                        mr_tela.data_movto)
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("INSERT","geo_acerto")
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
      END IF  
   END FOR 
   
   DELETE 
     FROM geo_acerto_chq
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","geo_acerto_chq")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   
   DECLARE cq_temp_cheque CURSOR WITH HOLD FOR
   SELECT *
     FROM t_cheques
   
   LET l_ind = 0
   FOREACH cq_temp_cheque INTO lr_t_cheques.*
      LET l_ind = l_ind + 1
      INSERT INTO geo_acerto_chq VALUES (lr_t_cheques.cod_empresa,
                                         mr_tela.cod_manifesto,
                                         l_ind,
                                         lr_t_cheques.cod_tit_rel,
                                         lr_t_cheques.num_cheque,
                                         lr_t_cheques.val_cheque)
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","geo_acerto_chq")
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
   END FOREACH
   
   DELETE 
     FROM geo_acerto_dhr
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","geo_acerto_dhr")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   INSERT INTO geo_acerto_dhr VALUES (p_cod_empresa,
                                      mr_tela.cod_manifesto,
                                      mr_tela.tot_din_receb)
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","geo_acerto_chq")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   
   DELETE 
     FROM geo_acerto_cc
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","geo_acerto_cc")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   INSERT INTO geo_acerto_cc VALUES (p_cod_empresa,
                                      mr_tela.cod_manifesto,
                                      mr_tela.saldo_vendedor,
                                      mr_tela.saldo_cc)
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","geo_acerto_cc")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   CALL geo1014_habilita_campos_manutencao(FALSE,'INCLUIR')
   LET m_consulta_ativa = TRUE
   RETURN TRUE
END FUNCTION

#----------------------------#
FUNCTION geo1014_cria_temp()
#----------------------------#
   WHENEVER ERROR CONTINUE
   DROP TABLE t_cheques;
   CREATE TEMP TABLE t_cheques(
      cod_empresa CHAR(2),
      num_cheque CHAR(10),
      val_cheque DECIMAL(20,2),
      cod_tit_rel CHAR(14)
   );
   WHENEVER ERROR STOP
END FUNCTION


#--------------------------------#
 FUNCTION geo1014_despesas()
#--------------------------------#
   DEFINE l_label            VARCHAR(50)
        , l_splitter         VARCHAR(50)
        , l_status           SMALLINT
        , l_panel_center     VARCHAR(10)
        , l_panel_reference2 VARCHAR(10)
        , l_arr_curr         SMALLINT
   
   IF NOT m_consulta_ativa THEN
 	   CALL _ADVPL_message_box("Informe um manifesto antes de informar suas despesas.")
 	   RETURN FALSE
 	END IF 
   
   initialize ma_despesas to null
    
     LET m_form_despesa = _ADVPL_create_component(NULL,"LDIALOG")
     CALL _ADVPL_set_property(m_form_despesa,"TITLE","DESPESAS")
     CALL _ADVPL_set_property(m_form_despesa,"ENABLE_ESC_CLOSE",FALSE)
     CALL _ADVPL_set_property(m_form_despesa,"SIZE",1000,500)#   1024,725)

     # INICIO MENU

     #cria menu
     LET m_toolbar_despesa = _ADVPL_create_component(NULL,"LMENUBAR",m_form_despesa)
     
     IF mr_tela.sit_manifesto = "R" THEN
    	 #botao INFORMAR
        LET m_botao_inform_despesa = _ADVPL_create_component(NULL,"LINFORMBUTTON",m_toolbar_despesa)
        CALL _ADVPL_set_property(m_botao_inform_despesa,"EVENT","geo1014_informar_despesas")
        CALL _ADVPL_set_property(m_botao_inform_despesa,"CONFIRM_EVENT","geo1014_grava_despesas")
        CALL _ADVPL_set_property(m_botao_inform_despesa,"CANCEL_EVENT","geo1014_cancela_despesas")
	 END IF 
     
     #botao sair
     LET m_botao_quit_despesa = _ADVPL_create_component(NULL,"LQUITBUTTON",m_toolbar_despesa)


     LET m_status_bar_despesa = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_despesa)

     #  FIM MENU
 
      #cria panel para campos de filtro 
      LET m_panel_despesa = _ADVPL_create_component(NULL,"LPANEL",m_form_despesa)
      CALL _ADVPL_set_property(m_panel_despesa,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_panel_despesa,"HEIGHT",390)
      
     
     #cria panel  
     LET m_panel_reference_despesa = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel_despesa)
     CALL _ADVPL_set_property(m_panel_reference_despesa,"TITLE","DESPESAS")
     CALL _ADVPL_set_property(m_panel_reference_despesa,"ALIGN","CENTER")

      #cria panel para campos de filtro 
      LET l_panel_center = _ADVPL_create_component(NULL,"LPANEL",m_panel_reference_despesa)
      CALL _ADVPL_set_property(l_panel_center,"ALIGN","BOTTOM")
      CALL _ADVPL_set_property(l_panel_center,"HEIGHT",380)
      
  
     #cria panel  
     LET l_panel_reference2 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel_center)
     CALL _ADVPL_set_property(l_panel_reference2,"TITLE","")
     CALL _ADVPL_set_property(l_panel_reference2,"ALIGN","TOP")
     CALL _ADVPL_set_property(l_panel_reference2,"HEIGHT",380)


      #cria array
      LET m_table_reference3 = _ADVPL_create_component(NULL,"LBROWSEEX",l_panel_reference2)
      CALL _ADVPL_set_property(m_table_reference3,"SIZE",800,380)
      CALL _ADVPL_set_property(m_table_reference3,"CAN_ADD_ROW",TRUE)
      CALL _ADVPL_set_property(m_table_reference3,"CAN_REMOVE_ROW",TRUE)
      CALL _ADVPL_set_property(m_table_reference3,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_table_reference3,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_table_reference3,"ENABLE",TRUE)
	  CALL _ADVPL_set_property(m_table_reference3,"POSITION",10,10)
	  CALL _ADVPL_set_property(m_table_reference3,"AFTER_ROW_EVENT",'geo1014_after_row')

      #cria campo do array: cod_cliente
      LET m_despesa_cod_operacao = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(m_despesa_cod_operacao,"VARIABLE","cod_operacao")
      CALL _ADVPL_set_property(m_despesa_cod_operacao,"HEADER","Operacao")
      CALL _ADVPL_set_property(m_despesa_cod_operacao,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(m_despesa_cod_operacao,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_despesa_cod_operacao,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_despesa_cod_operacao,"EDIT_PROPERTY","LENGTH",5) 
      CALL _ADVPL_set_property(m_despesa_cod_operacao,"EDIT_PROPERTY","VALID","geo1014_valid_cod_operacao") 
      CALL _ADVPL_set_property(m_despesa_cod_operacao,"EDITABLE", TRUE)
      
      LET m_despesa_zoom_cod_operacao = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_table_reference3)
      CALL _ADVPL_set_property(m_despesa_zoom_cod_operacao,"COLUMN_SIZE",20)
      CALL _ADVPL_set_property(m_despesa_zoom_cod_operacao,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_despesa_zoom_cod_operacao,"NO_VARIABLE",TRUE)
      CALL _ADVPL_set_property(m_despesa_zoom_cod_operacao,"IMAGE", "BTPESQ")
      CALL _ADVPL_set_property(m_despesa_zoom_cod_operacao,"BEFORE_EDIT_EVENT","geo1016_zoom_operacao")
      
      LET m_despesa_den_operacao = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(m_despesa_den_operacao,"VARIABLE","den_operacao")
      CALL _ADVPL_set_property(m_despesa_den_operacao,"HEADER","Desc.Operacao")
      CALL _ADVPL_set_property(m_despesa_den_operacao,"COLUMN_SIZE", 80)
      CALL _ADVPL_set_property(m_despesa_den_operacao,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_despesa_den_operacao,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_despesa_den_operacao,"EDIT_PROPERTY","LENGTH",100) 
      CALL _ADVPL_set_property(m_despesa_den_operacao,"EDITABLE", FALSE)
      
      #cria campo do array: cod_cliente
      LET m_despesa_cod_cc = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(m_despesa_cod_cc,"VARIABLE","cod_cc")
      CALL _ADVPL_set_property(m_despesa_cod_cc,"HEADER","Centro Custo")
      CALL _ADVPL_set_property(m_despesa_cod_cc,"COLUMN_SIZE", 45)
      CALL _ADVPL_set_property(m_despesa_cod_cc,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_despesa_cod_cc,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_despesa_cod_cc,"EDIT_PROPERTY","LENGTH",4)
      CALL _ADVPL_set_property(m_despesa_cod_cc,"EDIT_PROPERTY","VALID","geo1014_valid_cod_cc") 
      CALL _ADVPL_set_property(m_despesa_cod_cc,"EDITABLE", TRUE)
      
      LET m_despesa_zoom_cod_cc = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_table_reference3)
      CALL _ADVPL_set_property(m_despesa_zoom_cod_cc,"COLUMN_SIZE",20)
      CALL _ADVPL_set_property(m_despesa_zoom_cod_cc,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_despesa_zoom_cod_cc,"NO_VARIABLE",TRUE)
      CALL _ADVPL_set_property(m_despesa_zoom_cod_cc,"IMAGE", "BTPESQ")
      CALL _ADVPL_set_property(m_despesa_zoom_cod_cc,"BEFORE_EDIT_EVENT","geo1016_zoom_cc")
      
      LET m_despesa_den_cc = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(m_despesa_den_cc,"VARIABLE","den_cc")
      CALL _ADVPL_set_property(m_despesa_den_cc,"HEADER","Desc. Centro Custo")
      CALL _ADVPL_set_property(m_despesa_den_cc,"COLUMN_SIZE", 80)
      CALL _ADVPL_set_property(m_despesa_den_cc,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_despesa_den_cc,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_despesa_den_cc,"EDIT_PROPERTY","LENGTH",100) 
      CALL _ADVPL_set_property(m_despesa_den_cc,"EDITABLE", FALSE)
      
      
      #cria campo do array: cod_cliente
      LET m_despesa_num_docum = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(m_despesa_num_docum,"VARIABLE","num_docum")
      CALL _ADVPL_set_property(m_despesa_num_docum,"HEADER","Documento")
      CALL _ADVPL_set_property(m_despesa_num_docum,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(m_despesa_num_docum,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_despesa_num_docum,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_despesa_num_docum,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_despesa_num_docum,"EDITABLE", TRUE)
      
      
      #cria campo do array: cod_cliente
      LET m_despesa_val_despesa = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(m_despesa_val_despesa,"VARIABLE","val_despesa")
      CALL _ADVPL_set_property(m_despesa_val_despesa,"HEADER","Valor da Despesa")
      CALL _ADVPL_set_property(m_despesa_val_despesa,"COLUMN_SIZE", 60)
      CALL _ADVPL_set_property(m_despesa_val_despesa,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_despesa_val_despesa,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_despesa_val_despesa,"EDIT_PROPERTY","LENGTH",8,2) 
      CALL _ADVPL_set_property(m_despesa_val_despesa,"PICTURE","@E R$999999.99")
      CALL _ADVPL_set_property(m_despesa_val_despesa,"EDITABLE", TRUE)
      
      
      #cria campo do array: cod_cliente
      LET m_despesa_descricao = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference3)
      CALL _ADVPL_set_property(m_despesa_descricao,"VARIABLE","den_despesa")
      CALL _ADVPL_set_property(m_despesa_descricao,"HEADER","Descrição")
      CALL _ADVPL_set_property(m_despesa_descricao,"COLUMN_SIZE", 190)
      CALL _ADVPL_set_property(m_despesa_descricao,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_despesa_descricao,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_despesa_descricao,"EDIT_PROPERTY","LENGTH",500) 
      CALL _ADVPL_set_property(m_despesa_descricao,"EDITABLE", TRUE)
      
      CALL geo1014_carrega_despesas()
      
      CALL _ADVPL_set_property(m_table_reference3,"SET_ROWS",ma_despesas,0)
      CALL _ADVPL_set_property(m_table_reference3,"ITEM_COUNT",m_ind_despesa)
   
      CALL _ADVPL_set_property(m_table_reference3,"REFRESH")
	  
	  IF mr_tela.sit_manifesto = "R" THEN
	     CALL _ADVPL_get_property(m_botao_inform_despesa,"DO_CLICK")
	  ELSE
	     CALL _ADVPL_set_property(m_table_reference3,"ENABLE",FALSE);
	  END IF 
      CALL _ADVPL_set_property(m_form_despesa,"ACTIVATE",TRUE)
      
 END FUNCTION 

 
 #--------------------------------#
 FUNCTION geo1014_carrega_despesas()
 #--------------------------------#
 	
 	DECLARE cq_despesas_vinc CURSOR FOR
 	SELECT cod_operacao, cod_cc, num_docum, val_despesa, descricao  
 	  FROM geo_acerto_despesas
 	 WHERE cod_empresa = p_cod_empresa
 	   AND cod_manifesto = mr_tela.cod_manifesto
 	
 	LET m_ind_despesa = 1
 	FOREACH cq_despesas_vinc INTO ma_despesas[m_ind_despesa].cod_operacao,
 	                              ma_despesas[m_ind_despesa].cod_cc,
 	                              ma_despesas[m_ind_despesa].num_docum,
 	                              ma_despesas[m_ind_despesa].val_despesa,
 	                              ma_despesas[m_ind_despesa].den_despesa
 	   SELECT nom_cent_cust
 	     INTO ma_despesas[m_ind_despesa].den_cc
 	     FROM cad_cc
 	    WHERE cod_empresa = p_cod_empresa
 	      AND cod_cent_cust = ma_despesas[m_ind_despesa].cod_cc
 	   
 	   SELECT des_operacao
 	     INTO ma_despesas[m_ind_despesa].den_operacao
 	     FROM mcx_operacao_caixa
 	    WHERE empresa = p_cod_empresa
 	      AND operacao = ma_despesas[m_ind_despesa].cod_operacao
 	      
 	   LET m_ind_despesa = m_ind_despesa + 1
    END FOREACH
    
    IF m_ind_despesa > 1 THEN 
    	LET m_ind_despesa = m_ind_despesa - 1
    END IF 
    
 END FUNCTION
 
 
 #------------------------------------#
 FUNCTION geo1014_informar_despesas()
 #------------------------------------#
 
 	
 END FUNCTION 
 
 #-----------------------------------#
 FUNCTION geo1014_cancela_despesas()
 #-----------------------------------#
 	CALL geo1014_calcula_despesas()
    CALL _ADVPL_get_property(m_botao_quit_despesa,"DO_CLICK")
 END FUNCTION 
 
 #------------------------------#
 FUNCTION geo1014_grava_despesas()
 #------------------------------#
    DEFINE l_ind      SMALLINT
    
    IF NOT geo1014_after_input() THEN
       RETURN FALSE
    END IF 
    
    CALL log085_transacao("BEGIN")
    DELETE
      FROM geo_acerto_despesas
     WHERE cod_empresa = p_cod_empresa
       AND cod_manifesto = mr_tela.cod_manifesto
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("DELETE","geo_acerto_despesas")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
    
    FOR l_ind = 1 TO _ADVPL_get_property(m_table_reference3,"ITEM_COUNT")
       INSERT INTO geo_acerto_despesas VALUES (p_cod_empresa,
                                               mr_tela.cod_manifesto,
                                               l_ind,
                                               ma_despesas[l_ind].cod_operacao,
                                               ma_despesas[l_ind].cod_cc,
                                               ma_despesas[l_ind].num_docum,
                                               ma_despesas[l_ind].val_despesa,
                                               ma_despesas[l_ind].den_despesa)
       IF sqlca.sqlcode <> 0 THEN
          CALL log003_err_sql("INSERT","geo_acerto_despesas")
          CALL log085_transacao("ROLLBACK")
          RETURN FALSE
       END IF
    END FOR
    
    CALL log085_transacao("COMMIT")
    
    CALL geo1014_calcula_despesas()
    CALL geo1014_cancela_despesas()
    
    RETURN TRUE
 END FUNCTION
 
 #-------------------------------------#
 FUNCTION geo1014_primeiro()
#-------------------------------------#
    CALL geo1014_paginacao("PRIMEIRO")
 end function

#-------------------------------------#
 FUNCTION geo1014_anterior()
#-------------------------------------#
   CALL geo1014_paginacao("ANTERIOR")
 end function

#-------------------------------------#
 FUNCTION geo1014_seguinte()
#-------------------------------------#
     CALL geo1014_paginacao("SEGUINTE")
 end function

#-------------------------------------#
 FUNCTION geo1014_ultimo()
#-------------------------------------#
    CALL geo1014_paginacao("ULTIMO")
 end function

#
#-------------------------------------#
 FUNCTION geo1014_paginacao(l_funcao)
#-------------------------------------#

   DEFINE l_funcao    CHAR(10),
          l_status    SMALLINT
   
   IF NOT m_consulta_ativa THEN
 	  CALL _ADVPL_message_box("Informe um manifesto antes de paginar.")
 	  RETURN FALSE
   END IF 
   
   LET l_funcao = l_funcao CLIPPED
   
   LET mr_telar.* = mr_tela.*
   
   IF m_consulta_ativa THEN

      WHILE TRUE
         CASE
            WHEN l_funcao = "SEGUINTE"

                  FETCH NEXT cq_consulta INTO mr_tela.cod_manifesto 

               IF sqlca.sqlcode <> 0 THEN
                  #CALL log003_err_sql ("NEXT","cq_orcamentos")
                  #EXIT WHILE
               END IF

            WHEN l_funcao = "ANTERIOR"

                 FETCH PREVIOUS cq_consulta INTO mr_tela.cod_manifesto 

               IF sqlca.sqlcode <> 0 THEN
                  #CALL log003_err_sql ("PREVIOUS","cq_orcamentos")
                  #EXIT WHILE
               END IF

            WHEN l_funcao = "PRIMEIRO"

                  FETCH FIRST cq_consulta INTO mr_tela.cod_manifesto 

               IF sqlca.sqlcode <> 0 THEN
                  #CALL log003_err_sql ("FIRST","cq_orcamentos")
                  #EXIT WHILE
               END IF

            WHEN l_funcao = "ULTIMO"

                  FETCH LAST cq_consulta INTO mr_tela.cod_manifesto 

            IF sqlca.sqlcode <> 0 THEN
               #CALL log003_err_sql ("LAST","cq_orcamentos")
               #EXIT WHILE
            END IF
         END CASE
         IF sqlca.sqlcode = NOTFOUND THEN
            CALL geo1014_exibe_mensagem_barra_status("Não existem mais itens nesta direcao.","ERRO")
            let mr_tela.* = mr_telar.*
            EXIT WHILE
         ELSE
            LET m_consulta_ativa = TRUE
         END IF

         select DISTINCT cod_manifesto 
           INTO mr_tela.cod_manifesto  
          from geo_acerto 
         where cod_empresa  = p_cod_empresa
           and cod_manifesto    = mr_tela.cod_manifesto
        
         IF sqlca.sqlcode = 0 THEN

            EXIT WHILE

         END IF

      END WHILE
   ELSE
      CALL geo1014_exibe_mensagem_barra_status("Efetue primeiramente a consulta.","ERRO")
   END IF
   
   CALL geo1014_valid_cod_manifesto()
   CALL geo1014_habilita_campos_manutencao(FALSE,'CONSULTAR')
 END FUNCTION


#--------------------------------#
 FUNCTION geo1014_carga()
#--------------------------------#
   DEFINE l_label            VARCHAR(50)
        , l_splitter         VARCHAR(50)
        , l_status           SMALLINT
        , l_panel_center     VARCHAR(10)
        , l_panel_reference2 VARCHAR(10)
        , l_arr_curr         SMALLINT
   
     IF NOT m_consulta_ativa THEN
 	    CALL _ADVPL_message_box("Informe um manifesto antes de consultar a carga.")
 	    RETURN FALSE
 	 END IF 
   
     initialize ma_carga to null
    
     LET m_form_carga = _ADVPL_create_component(NULL,"LDIALOG")
     CALL _ADVPL_set_property(m_form_carga,"TITLE","CARGAS")
     CALL _ADVPL_set_property(m_form_carga,"ENABLE_ESC_CLOSE",FALSE)
     CALL _ADVPL_set_property(m_form_carga,"SIZE",1000,600)#   1024,725)

     # INICIO MENU

     #cria menu
     LET m_toolbar_carga = _ADVPL_create_component(NULL,"LMENUBAR",m_form_carga)
     
	 #botao sair
     LET m_botao_quit_carga = _ADVPL_create_component(NULL,"LQUITBUTTON",m_toolbar_carga)

     LET m_status_bar_carga = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_carga)

     #  FIM MENU
 
      #cria panel para campos de filtro 
      LET m_panel_carga = _ADVPL_create_component(NULL,"LPANEL",m_form_carga)
      CALL _ADVPL_set_property(m_panel_carga,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_panel_carga,"HEIGHT",490)
      
     
     #cria panel  
     LET m_panel_reference_carga = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel_carga)
     CALL _ADVPL_set_property(m_panel_reference_carga,"TITLE","CARGAS")
     CALL _ADVPL_set_property(m_panel_reference_carga,"ALIGN","CENTER")

      #cria panel para campos de filtro 
      LET l_panel_center = _ADVPL_create_component(NULL,"LPANEL",m_panel_reference_carga)
      CALL _ADVPL_set_property(l_panel_center,"ALIGN","BOTTOM")
      CALL _ADVPL_set_property(l_panel_center,"HEIGHT",480)
      
  
     #cria panel  
     LET l_panel_reference2 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel_center)
     CALL _ADVPL_set_property(l_panel_reference2,"TITLE","")
     CALL _ADVPL_set_property(l_panel_reference2,"ALIGN","TOP")
     CALL _ADVPL_set_property(l_panel_reference2,"HEIGHT",480)


      #cria array
      LET m_table_reference4 = _ADVPL_create_component(NULL,"LBROWSEEX",l_panel_reference2)
      CALL _ADVPL_set_property(m_table_reference4,"SIZE",600,480)
      CALL _ADVPL_set_property(m_table_reference4,"CAN_ADD_ROW",TRUE)
      CALL _ADVPL_set_property(m_table_reference4,"CAN_REMOVE_ROW",TRUE)
      CALL _ADVPL_set_property(m_table_reference4,"ALIGN","TOP")
      CALL _ADVPL_set_property(m_table_reference4,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_table_reference4,"ENABLE",TRUE)
	  CALL _ADVPL_set_property(m_table_reference4,"POSITION",10,10)

      #cria campo do array: cod_cliente
      LET m_carga_num_remessa = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(m_carga_num_remessa,"VARIABLE","num_remessa")
      CALL _ADVPL_set_property(m_carga_num_remessa,"HEADER","Remessa")
      CALL _ADVPL_set_property(m_carga_num_remessa,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(m_carga_num_remessa,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_num_remessa,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_num_remessa,"EDIT_PROPERTY","LENGTH",10) 
      CALL _ADVPL_set_property(m_carga_num_remessa,"EDITABLE", TRUE)
      
      
      LET m_carga_ser_remessa = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(m_carga_ser_remessa,"VARIABLE","ser_remessa")
      CALL _ADVPL_set_property(m_carga_ser_remessa,"HEADER","Série")
      CALL _ADVPL_set_property(m_carga_ser_remessa,"COLUMN_SIZE", 30)
      CALL _ADVPL_set_property(m_carga_ser_remessa,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_ser_remessa,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_carga_ser_remessa,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_carga_ser_remessa,"EDITABLE", TRUE)
      
      
      LET m_carga_cod_item = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(m_carga_cod_item,"VARIABLE","cod_item")
      CALL _ADVPL_set_property(m_carga_cod_item,"HEADER","Item")
      CALL _ADVPL_set_property(m_carga_cod_item,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_cod_item,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_cod_item,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_carga_cod_item,"EDIT_PROPERTY","LENGTH",15) 
      CALL _ADVPL_set_property(m_carga_cod_item,"EDITABLE", TRUE)
      
      
      #cria campo do array: cod_cliente
      LET m_carga_den_item = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(m_carga_den_item,"VARIABLE","den_item")
      CALL _ADVPL_set_property(m_carga_den_item,"HEADER","Descrição")
      CALL _ADVPL_set_property(m_carga_den_item,"COLUMN_SIZE", 120)
      CALL _ADVPL_set_property(m_carga_den_item,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_den_item,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_carga_den_item,"EDIT_PROPERTY","LENGTH",76) 
      CALL _ADVPL_set_property(m_carga_den_item,"EDITABLE", TRUE)
      
      #cria campo do array: cod_cliente
      LET m_carga_um = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(m_carga_um,"VARIABLE","unid_med")
      CALL _ADVPL_set_property(m_carga_um,"HEADER","Unid. Med.")
      CALL _ADVPL_set_property(m_carga_um,"COLUMN_SIZE", 40)
      CALL _ADVPL_set_property(m_carga_um,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_um,"EDIT_COMPONENT","LTEXTFIELD")
      CALL _ADVPL_set_property(m_carga_um,"EDIT_PROPERTY","LENGTH",3) 
      CALL _ADVPL_set_property(m_carga_um,"EDITABLE", TRUE)
      
      #cria campo do array: cod_cliente
      LET m_carga_qtd_remessa = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"VARIABLE","qtd_remessa")
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"HEADER","Qtd. Remessa")
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"EDIT_PROPERTY","LENGTH",17,6) 
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"PICTURE","@E 999999999999999.99")
      CALL _ADVPL_set_property(m_carga_qtd_remessa,"EDITABLE", TRUE)
      
      #cria campo do array: cod_cliente
      LET m_carga_qtd_vendido = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"VARIABLE","qtd_vendido")
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"HEADER","Qtd. Vendido")
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"EDIT_PROPERTY","LENGTH",17,6) 
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"PICTURE","@E 999999999999999.99")
      CALL _ADVPL_set_property(m_carga_qtd_vendido,"EDITABLE", TRUE)
      
      #cria campo do array: cod_cliente
      LET m_carga_qtd_retornado = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"VARIABLE","qtd_retornado")
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"HEADER","Qtd. Retornado")
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"EDIT_PROPERTY","LENGTH",17,6) 
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"PICTURE","@E 999999999999999.99")
      CALL _ADVPL_set_property(m_carga_qtd_retornado,"EDITABLE", TRUE)
      
      #cria campo do array: cod_cliente
      LET m_carga_qtd_diferenca = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_table_reference4)
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"VARIABLE","qtd_diferenca")
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"HEADER","Qtd. Diferença")
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"COLUMN_SIZE", 50)
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"ORDER",TRUE)
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"EDIT_COMPONENT","LNUMERICFIELD")
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"EDIT_PROPERTY","LENGTH",17,6) 
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"PICTURE","@E 999999999999999.99")
      CALL _ADVPL_set_property(m_carga_qtd_diferenca,"EDITABLE", TRUE)
      
      CALL geo1014_carrega_cargas()
      
      CALL _ADVPL_set_property(m_table_reference4,"SET_ROWS",ma_carga,0)
      CALL _ADVPL_set_property(m_table_reference4,"ITEM_COUNT",m_ind_carga)
   
      CALL _ADVPL_set_property(m_table_reference4,"REFRESH")
	  
	  CALL _ADVPL_set_property(m_form_carga,"ACTIVATE",TRUE)
      
 END FUNCTION 
 
 #---------------------------------#
 FUNCTION geo1014_carrega_cargas()
 #---------------------------------#
    
    DECLARE cq_cargas1 CURSOR FOR
    SELECT DISTINCT d.num_remessa,
           d.ser_remessa,
           a.cod_item,
           a.den_item,
           a.cod_unid_med,
           d.qtd_movto #QUANTIDADE REMESSA
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
       
       LET m_ind_carga = m_ind_carga + 1
    END FOREACH
    IF m_ind_carga > 1 THEN
       LET m_ind_carga = m_ind_carga - 1
    END IF 
 END FUNCTION
 
#--------------------------------#
FUNCTION geo1014_verif_dif_carga()
#--------------------------------#
   DEFINE l_qtd_remessa    DECIMAL(17,6)
   DEFINE l_qtd_vend_ret   DECIMAL(17,6)
   DEFINE l_qtd_diferenca  DECIMAL(17,6)
   DEFINE l_ind            SMALLINT
   
   {SELECT SUM(qtd_movto)
     INTO l_qtd_remessa
     FROM geo_remessa_movto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
      AND tipo_movto = 'E'
   IF l_qtd_remessa IS NULL OR l_qtd_remessa = "" THEN
      LET l_qtd_remessa = 0
   END IF 
   
   SELECT SUM(qtd_movto)
     INTO l_qtd_vend_ret
     FROM geo_remessa_movto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
      AND tipo_movto IN ('S','R')
   IF l_qtd_vend_ret IS NULL OR l_qtd_vend_ret = "" THEN
      LET l_qtd_vend_ret = 0
   END IF 
   
   LET l_qtd_diferenca = l_qtd_remessa - l_qtd_vend_ret
   
   IF l_qtd_diferenca = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF }
   
   FOR l_ind = 1 TO m_ind_carga
      IF ma_carga[l_ind].qtd_diferenca <> 0 THEN
         RETURN FALSE
      END IF 
   END FOR
   
   RETURN TRUE
END FUNCTION


#---------------------------#
FUNCTION geo1014_excluir()
#---------------------------#
   IF NOT m_consulta_ativa THEN
 	  CALL _ADVPL_message_box("Informe um manifesto antes de excluir o acerto.")
 	  RETURN FALSE
   END IF 
   
   IF mr_tela.sit_manifesto = "E" THEN
      CALL _ADVPL_message_box("O acerto desse manifesto já está encerrado e não pode ser excluído.")
      RETURN FALSE
   END IF
   
   IF NOT LOG_pergunta("Deseja realmente excluir este acerto?") THEN
      RETURN FALSE
   END IF 
   
   CALL log085_transacao("BEGIN")
   DELETE 
     FROM geo_acerto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","geo_acerto")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 

   DELETE 
     FROM geo_acerto_chq
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","geo_acerto_chq")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   DELETE 
     FROM geo_acerto_despesas
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","geo_acerto_despesas")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   DELETE 
     FROM geo_acerto_dhr
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","geo_acerto_dhr")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   CALL log085_transacao("COMMIT")
   CALL _ADVPL_message_box("Acerto foi excluído com sucesso")
   CALL geo1014_reset()
   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION geo1014_reset()
#-----------------------#

   INITIALIZE mr_tela.* TO NULL
   INITIALIZE ma_tela TO NULL
   INITIALIZE ma_cheque TO NULL
   INITIALIZE ma_despesas TO NULL
   INITIALIZE ma_carga TO NULL
   
   CALL _ADVPL_set_property(m_table_reference1,"ITEM_COUNT",0)
   CALL _ADVPL_set_property(m_table_reference1,"REFRESH")
   CALL _ADVPL_set_property(m_table_reference2,"ITEM_COUNT",0)
   CALL _ADVPL_set_property(m_table_reference2,"REFRESH")
   CALL _ADVPL_set_property(m_table_reference3,"ITEM_COUNT",0)
   CALL _ADVPL_set_property(m_table_reference3,"REFRESH")
   CALL _ADVPL_set_property(m_table_reference4,"ITEM_COUNT",0)
   CALL _ADVPL_set_property(m_table_reference4,"REFRESH")
   
   call geo1014_habilita_campos_manutencao(FALSE,'INCLUIR')
   RETURN TRUE

END FUNCTION

#----------------------------------------------#
FUNCTION geo1014_baixa_titulos_cre(l_num_docum)
#----------------------------------------------#
   DEFINE l_num_docum           LIKE docum.num_docum
   DEFINE l_parametro           CHAR(99)
   DEFINE l_status              SMALLINT
   
   DEFINE lr_tela               RECORD
          cod_empresa                  LIKE adocum_pgto.cod_empresa     ,
          num_docum                    LIKE docum.num_docum             ,
          ies_tip_docum                LIKE docum.ies_tip_docum         ,
          ies_tip_pgto                 LIKE docum_pgto.ies_tip_pgto     ,
          ies_forma_pgto               LIKE docum_pgto.ies_forma_pgto   ,
          cod_portador                 LIKE docum.cod_portador          ,
          ies_tip_portador             LIKE docum.ies_tip_portador      ,
          dat_pgto                     LIKE docum_pgto.dat_pgto         ,
          dat_credito                  LIKE docum_pgto.dat_credito      ,
          val_saldo                    LIKE docum.val_saldo             ,
          val_desc_conc                LIKE docum_pgto.val_desc_conc    ,
          val_juro_pago                LIKE docum_pgto.val_juro_pago    ,
          ies_abono_juros              CHAR(01)                         ,
          val_desp_cartorio            LIKE docum_pgto.val_desp_cartorio,
          val_despesas                 LIKE docum_pgto.val_despesas     ,
          val_multa                    DECIMAL(15,2)                    ,
          val_glosa                    DECIMAL(15,2)
                                END RECORD
                                
   LET lr_tela.cod_empresa       = p_cod_empresa
   LET lr_tela.num_docum         = l_num_docum
   
   SELECT ies_tip_docum, val_saldo
     INTO lr_tela.ies_tip_docum, lr_tela.val_saldo
     FROM docum
    WHERE cod_empresa = p_cod_empresa
      AND num_docum = l_num_docum
   
   
   LET lr_tela.ies_tip_pgto      = "N"
   
   CALL log2250_busca_parametro(p_cod_empresa,'geo_forma_bx_din')
   RETURNING l_parametro, l_status
   IF l_parametro IS NULL OR l_parametro = " " THEN
      LET l_parametro = "CX"
   END IF 
   LET lr_tela.ies_forma_pgto    = l_parametro CLIPPED
   
   CALL log2250_busca_parametro(p_cod_empresa,'geo_port_bx_din')
   RETURNING l_parametro, l_status
   IF l_parametro IS NULL OR l_parametro = " " THEN
      LET l_parametro = "900"
   END IF 
   LET lr_tela.cod_portador      = l_parametro CLIPPED
   
   CALL log2250_busca_parametro(p_cod_empresa,'geo_tip_port_bx_din')
   RETURNING l_parametro, l_status
   IF l_parametro IS NULL OR l_parametro = " " THEN
      LET l_parametro = "C"
   END IF 
   LET lr_tela.ies_tip_portador  = l_parametro CLIPPED
   
   LET lr_tela.dat_pgto          = mr_tela.data_movto
   LET lr_tela.dat_credito       = mr_tela.data_movto
   
   LET lr_tela.val_desc_conc     = 0
   LET lr_tela.val_juro_pago     = 0
   LET lr_tela.ies_abono_juros   = "N"
   LET lr_tela.val_desp_cartorio = 0
   LET lr_tela.val_despesas      = 0
   LET lr_tela.val_multa         = 0
   LET lr_tela.val_glosa         = 0
   
   IF geo1017_controle(lr_tela) THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF 
       
END FUNCTION

#-----------------------------#
FUNCTION geo1016_zoom_operacao()
#-----------------------------#
   DEFINE l_arr_curr     SMALLINT
   DEFINE l_arr_count    SMALLINT
   DEFINE l_zoom_item    CHAR(50)
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference3,"ITEM_SELECTED")
   LET l_arr_count = _ADVPL_get_property(m_table_reference3,"ITEM_COUNT")
   
   call ip_zoom_zoom_cadastro_2_colunas('mcx_operacao_caixa',
                                'operacao',
                                '2',
                                'des_operacao',
                                '30',
                                'Operação: ',
                                'Descrição: ',
                                'empresa',
                                ' AND tip_contab_cc = "M" AND tip_operacao = "S" ORDER BY operacao ')

    
   let ma_despesas[l_arr_curr].cod_operacao = ip_zoom_get_valor()
   let ma_despesas[l_arr_curr].den_operacao = ip_zoom_get_valorb()
    
   CALL _ADVPL_set_property(m_table_reference3,"ITEM_COUNT",l_arr_count)
   CALL _ADVPL_set_property(m_table_reference3,"REFRESH")
END FUNCTION


#--------------------------#
FUNCTION geo1016_zoom_cc()
#--------------------------#
   DEFINE l_arr_curr     SMALLINT
   DEFINE l_arr_count    SMALLINT
   DEFINE l_zoom_item    CHAR(50)
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference3,"ITEM_SELECTED")
   LET l_arr_count = _ADVPL_get_property(m_table_reference3,"ITEM_COUNT")
   call ip_zoom_zoom_cadastro_2_colunas('cad_cc',
                                'cod_cent_cust',
                                '2',
                                'nom_cent_cust',
                                '30',
                                'Centro Custo: ',
                                'Descrição: ',
                                'cod_empresa',
                                'ORDER BY cod_cent_cust   ')

   let ma_despesas[l_arr_curr].cod_cc = ip_zoom_get_valor()
   let ma_despesas[l_arr_curr].den_cc = ip_zoom_get_valorb()
    
   CALL _ADVPL_set_property(m_table_reference3,"ITEM_COUNT",l_arr_count)
   CALL _ADVPL_set_property(m_table_reference3,"REFRESH")
END FUNCTION


#---------------------------#
FUNCTION geo1014_after_row()
#---------------------------#
   DEFINE l_arr_curr     SMALLINT
   DEFINE l_arr_count    SMALLINT
   
   
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference3,"ITEM_SELECTED")
   LET l_arr_count = _ADVPL_get_property(m_table_reference3,"ITEM_COUNT")
   
   SELECT DISTINCT empresa
     FROM mcx_operacao_caixa
    WHERE empresa = p_cod_empresa
      AND operacao = ma_despesas[l_arr_curr].cod_operacao
   IF sqlca.sqlcode <> 0 THEN
      CALL _ADVPL_message_box("Operação "||ma_despesas[l_arr_curr].cod_operacao||" não encontrada")
      RETURN FALSE
   END IF
   
   SELECT DISTINCT cod_empresa
     FROM cad_cc
    WHERE cod_empresa = p_cod_empresa
      AND cod_cent_cust = ma_despesas[l_arr_curr].cod_cc
   IF sqlca.sqlcode <> 0 THEN
      CALL _ADVPL_message_box("Centro de Custo "||ma_despesas[l_arr_curr].cod_cc||" não encontrado")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#---------------------------#
FUNCTION geo1014_after_input()
#---------------------------#
   DEFINE l_arr_curr     SMALLINT
   DEFINE l_arr_count    SMALLINT
   DEFINE l_ind          SMALLINT
   
   
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference3,"ITEM_SELECTED")
   LET l_arr_count = _ADVPL_get_property(m_table_reference3,"ITEM_COUNT")
   
   FOR l_ind = 1 TO l_arr_count
      SELECT DISTINCT empresa
        FROM mcx_operacao_caixa
       WHERE empresa = p_cod_empresa
         AND operacao = ma_despesas[l_ind].cod_operacao
      IF sqlca.sqlcode <> 0 THEN
         CALL _ADVPL_message_box("Operação "||ma_despesas[l_ind].cod_operacao||" não encontrada")
         RETURN FALSE
      END IF
   
      SELECT DISTINCT cod_empresa
        FROM cad_cc
       WHERE cod_empresa = p_cod_empresa
         AND cod_cent_cust = ma_despesas[l_ind].cod_cc
      IF sqlca.sqlcode <> 0 THEN
         CALL _ADVPL_message_box("Centro de Custo "||ma_despesas[l_ind].cod_cc||" não encontrado")
         RETURN FALSE
      END IF
   END FOR
   RETURN TRUE

END FUNCTION


#-------------------------------------#
FUNCTION geo1014_valid_cod_operacao()
#-------------------------------------#
   DEFINE l_arr_curr         SMALLINT
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference3,"ITEM_SELECTED")
   
   SELECT des_operacao
     INTO ma_despesas[l_arr_curr].den_operacao
     FROM mcx_operacao_caixa
    WHERE empresa = p_cod_empresa
      AND operacao = ma_despesas[l_arr_curr].cod_operacao
   IF sqlca.sqlcode <> 0 THEN
      CALL _ADVPL_message_box("Operação "||ma_despesas[l_arr_curr].cod_operacao||" não cadastrada")
      RETURN FALSE
   END IF 
   
   CALL _ADVPL_set_property(m_table_reference3,"REFRESH")
   
   RETURN TRUE
END FUNCTION


#-------------------------------------#
FUNCTION geo1014_valid_cod_cc()
#-------------------------------------#
   DEFINE l_arr_curr         SMALLINT
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference3,"ITEM_SELECTED")
   
   SELECT nom_cent_cust
     INTO ma_despesas[l_arr_curr].den_cc
     FROM cad_cc
    WHERE cod_empresa = p_cod_empresa
      AND cod_cent_cust = ma_despesas[l_arr_curr].cod_cc
   IF sqlca.sqlcode <> 0 THEN
      CALL _ADVPL_message_box("Centro de Custo "||ma_despesas[l_arr_curr].cod_cc||" não cadastrado")
      RETURN FALSE
   END IF 
   
   CALL _ADVPL_set_property(m_table_reference3,"REFRESH")
   
   RETURN TRUE
END FUNCTION


#---------------------------#
FUNCTION geo1014_manifesto()
#---------------------------#
   DEFINE l_process VARCHAR(15)
   CALL geo1016()
END FUNCTION

#---------------------------#
FUNCTION geo1014_retorno()
#---------------------------#
   DEFINE l_process VARCHAR(15)
   CALL geo1020()
END FUNCTION

#----------------------------------#
FUNCTION geo1014_recalcula_totais()
#----------------------------------#
   DEFINE l_ind             SMALLINT
   DEFINE l_soma1           DECIMAL(20,2)
   DEFINE l_soma2           DECIMAL(20,2)
   DEFINE l_soma3           DECIMAL(20,2)
   DEFINE l_soma4           DECIMAL(20,2)
   
   LET l_soma1 = 0
   LET l_soma2 = 0
   LET l_soma3 = 0
   LET l_soma4 = 0
   
   FOR l_ind = 1 TO _ADVPL_get_property(m_table_reference1,"ITEM_COUNT")
      IF ma_tela[l_ind].val_cheque > 0 OR ma_tela[l_ind].val_dinheiro > 0 THEN
         LET l_soma1 = l_soma1 + ma_tela[l_ind].val_bruto
      END IF
   END FOR 
   
   LET mr_tela.tot_bruto = l_soma1
   LET mr_tela.tot_saldo = (mr_tela.tot_bruto) - (mr_tela.tot_desp + mr_tela.tot_din_receb + mr_tela.tot_chq_receb - mr_tela.val_tot_cobrancas)
   LET mr_tela.saldo_vendedor = mr_tela.saldo_cc - mr_tela.tot_saldo
   LET mr_tela.tot_saldo = mr_tela.tot_saldo * (-1)
   CALL _ADVPL_set_property(m_refer_tot_bruto,"REFRESH")
   CALL _ADVPL_set_property(m_refer_tot_saldo,"REFRESH")
   CALL _ADVPL_set_property(m_refer_saldo_vendedor,"REFRESH")
   
END FUNCTION

#-----------------------------------#
FUNCTION geo1014_carrega_cc_repres()
#-----------------------------------#
   
   IF mr_tela.sit_manifesto = "E" THEN
      SELECT saldo_anterior
        INTO mr_tela.saldo_cc
        FROM geo_acerto_cc
       WHERE cod_empresa = p_cod_empresa
         AND cod_manifesto = mr_tela.cod_manifesto
   ELSE
      #SELECT saldo_cc
      #  INTO mr_tela.saldo_cc
      #  FROM geo_repres_paramet
      # WHERE cod_repres = m_cod_repres
      CALL geo1014_saldo_cc_real()
   END IF 
   IF mr_tela.saldo_cc IS NULL OR mr_tela.saldo_cc = " " THEN
      LET mr_tela.saldo_cc = 0
   END IF 
   CALL _ADVPL_set_property(m_refer_saldo_cc,"REFRESH")
END FUNCTION

#-----------------------------#
FUNCTION geo1014_novo_cheque()
#-----------------------------#
   DEFINE l_arr_curr     SMALLINT
   
   LET l_arr_curr = _ADVPL_get_property(m_table_reference1,"ITEM_SELECTED")
   
   CALL chq0001_args(ma_tela[l_arr_curr].cod_cliente, m_cod_repres)
   
   CALL geo1014_carrega_cheques()
   CALL _ADVPL_set_property(m_table_reference2,"ITEM_COUNT",m_ind_cheque)
   CALL _ADVPL_set_property(m_table_reference2,"REFRESH")
   
END FUNCTION

#--------------------------------#
FUNCTION geo1014_estorna_acerto()
#--------------------------------#


{
delete from tran_arg where 1=1;
delete from mcx_mov_baixa_cap where 1=1;
delete from mcx_mov_baixa_cre where 1=1;
delete from mcx_lancto_contab where 1=1;
delete from mcx_movto where 1=1;
delete from pgto_det where 1=1;
delete from docum_obs where dat_obs = '22/03/2016';
delete from pgto_capa where 1=1;
delete from adocum_pgto where 1=1;
delete from adocum_pgto_capa where 1=1;
delete from docum_pgto where 1=1;
UPDATE docum SET ies_pgto_docum = 'A', val_saldo = val_bruto  WHERE cod_empresa = '01' and num_docum IN (select distinct cod_titulo from geo_acerto);
UPDATE geo_manifesto set sit_manifesto = 'R' where cod_manifesto = '1';
}

END FUNCTION
#-------------------------------------#
FUNCTION geo1014_processa_relatorio()
#-------------------------------------#
   IF NOT m_consulta_ativa THEN
      CALL _ADVPL_message_box("Informe um manifesto antes de tirar relatório")
 	  RETURN FALSE
   END IF
   
   CALL geo1023_args("A",mr_tela.cod_manifesto)
   
   RETURN TRUE
END FUNCTION

#--------------------------#
FUNCTION geo1014_cobranca()
#--------------------------#
   
   IF NOT m_consulta_ativa THEN
      CALL _ADVPL_message_box("Informe um manifesto antes de informar as cobrancas")
 	  RETURN FALSE
   END IF
   
   CALL geo1025_args(mr_tela.cod_manifesto)
   
   CALL geo1014_confirma_consulta()
   
   RETURN TRUE
   
END FUNCTION


#---------------------------#
FUNCTION geo1014_processar()
#---------------------------#
   DEFINE l_ind                 SMALLINT
   DEFINE l_val_despesa         DECIMAL(20,2)
   DEFINE l_descricao           CHAR(500)
   DEFINE l_sequencia           INTEGER
   DEFINE l_titulo              CHAR(14)
   DEFINE l_operacao            LIKE mcx_operacao_caixa.operacao
   DEFINE l_cod_cc              LIKE cad_cc.cod_cent_cust
   DEFINE l_num_docum           LIKE mcx_movto.docum
   DEFINE l_txt                 CHAR(20)
   DEFINE l_cod_titulo          CHAR(14)
   DEFINE l_val_receita         DECIMAL(20,2)
   DEFINE l_cod_cliente         CHAR(15)
   DEFINE l_parametro1           CHAR(99)
   DEFINE l_parametro2,l_parametro3           CHAR(99)
   DEFINE l_parametro           CHAR(99)
   DEFINE l_status              SMALLINT
   
   DEFINE lr_geo_acerto RECORD
               cod_empresa char(2),
			   cod_manifesto integer,
			   cod_cliente char(15),
			   num_nf integer,
			   ser_nf char(3),
			   cod_titulo char(14),
			   val_bruto decimal(20,2),
			   val_pagto decimal(20,2),
			   dat_pagto date,
			   portador decimal(4,0),
			   val_cheque decimal(20,2),
			   val_dinheiro decimal(20,2),
			   val_saldo decimal(20,2)
          END RECORD
   
   DEFINE lr_geo_acerto_cobranca RECORD
               cod_empresa char(2),
			   cod_manifesto integer,
			   cod_manifesto_orig integer,
			   cod_cliente char(15),
			   num_nf integer,
			   ser_nf char(3),
			   cod_titulo char(14),
			   val_bruto decimal(20,2),
			   val_pagto decimal(20,2),
			   dat_pagto date,
			   portador decimal(4,0),
			   val_cheque decimal(20,2),
			   val_dinheiro decimal(20,2),
			   val_saldo decimal(20,2)
          END RECORD
   
   DEFINE la_dados     ARRAY[9999] OF RECORD
                        caixa            LIKE mcx_caixa.caixa,
                        des_caixa        LIKE mcx_caixa.des_caixa,
                        dat_movto        LIKE mcx_movto.dat_movto,
                        tip_operacao     LIKE mcx_operacao_caixa.tip_operacao,
                        operacao         LIKE mcx_operacao_caixa.operacao,
                        des_operacao     LIKE mcx_operacao_caixa.des_operacao,
                        docum            LIKE mcx_movto.docum,
                        val_docum        LIKE mcx_movto.val_docum,
                        hist_movto       LIKE mcx_movto.hist_movto,
                        sequencia_caixa  LIKE mcx_movto.sequencia_caixa,
                        centro_custo     LIKE cad_cc.cod_cent_cust,
                        cod_titulo       CHAR(14),
                        cod_cliente      CHAR(15),
                        tip_docum        LIKE docum.ies_tip_docum
                     END RECORD
                     
   IF NOT m_consulta_ativa THEN
 	  CALL _ADVPL_message_box("Informe um manifesto antes de processar o acerto.")
 	  RETURN FALSE
   END IF 
   
   IF NOT log_pergunta("Confirma a data de movimentação "||mr_tela.data_movto|| " ?") THEN
      RETURN FALSE
   END IF
   
   IF mr_tela.sit_manifesto = "E" THEN
      CALL _ADVPL_message_box("O acerto desse manifesto já está encerrado e não pode ser processado.")
      RETURN FALSE
   END IF
   
   IF NOT geo1014_verif_dif_carga() THEN
      CALL _ADVPL_message_box("Hà divergências entre as cargas remetidas, vendidas e retornadas. Verifique as cargas")
      CALL _ADVPL_get_property(m_botao_carga,"DO_CLICK")
      RETURN FALSE
   END IF 
   
   CALL geo1014_exec_proc() ##SIMENES 04/08/2017
   CALL geo1014_saldo_cc_real() ##SIMENES 04/08/2017
   
   DECLARE cq_cre_titulos CURSOR WITH HOLD FOR
   SELECT *
     FROM geo_acerto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
      
   FOREACH cq_cre_titulos INTO lr_geo_acerto.*
   
      ### BAIXA OS TITULOS NO CRE
      IF NOT geo1014_baixa_titulos_cre(lr_geo_acerto.cod_titulo) THEN
         #RETURN FALSE
      END IF
      
   END FOREACH 
   
   DECLARE cq_cre_titulos CURSOR WITH HOLD FOR
   SELECT *
     FROM geo_acerto_cobranca
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
      
   FOREACH cq_cre_titulos INTO lr_geo_acerto_cobranca.*
   
      ### BAIXA OS TITULOS NO CRE
      IF NOT geo1014_baixa_titulos_cre(lr_geo_acerto_cobranca.cod_titulo) THEN
         #RETURN FALSE
      END IF
      
   END FOREACH 
   
   DECLARE cq_mcx_despesas CURSOR WITH HOLD FOR
   SELECT val_despesa, descricao, sequencia, cod_operacao, cod_cc, num_docum
     FROM geo_acerto_despesas
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   ORDER BY sequencia
   
   LET l_ind = 0
   CALL log2250_busca_parametro(p_cod_empresa,'geo_cod_caixa_acerto')
   RETURNING l_parametro, l_status
   IF l_parametro IS NULL OR l_parametro = " " THEN
      LET l_parametro = "1"
   END IF 
   
   FOREACH cq_mcx_despesas INTO l_val_despesa, l_descricao, l_sequencia, l_operacao, l_cod_cc, l_num_docum
      LET l_ind = l_ind + 1
      LET la_dados[l_ind].caixa            = l_parametro CLIPPED
   
      SELECT des_caixa
        INTO la_dados[l_ind].des_caixa
        FROM mcx_caixa
       WHERE empresa = p_cod_empresa
         AND caixa = la_dados[l_ind].caixa
   
      LET la_dados[l_ind].dat_movto        = mr_tela.data_movto
      LET la_dados[l_ind].operacao         = l_operacao
      
      SELECT tip_operacao
        INTO la_dados[l_ind].tip_operacao
        FROM mcx_operacao_caixa
       WHERE empresa = p_cod_empresa
         AND operacao = la_dados[l_ind].operacao
      
      
      SELECT des_operacao
        INTO la_dados[l_ind].des_operacao
        FROM mcx_operacao_caixa
       WHERE empresa = p_cod_empresa
         AND operacao = la_dados[l_ind].operacao
      
      LET l_txt = mr_tela.cod_manifesto
      LET la_dados[l_ind].docum            = l_num_docum
      LET la_dados[l_ind].val_docum        = l_val_despesa
      LET la_dados[l_ind].hist_movto       = l_descricao
      LET la_dados[l_ind].centro_custo     = l_cod_cc
      
   
   END FOREACH
   
   
   
   DECLARE cq_mcx_receitas CURSOR WITH HOLD FOR
   SELECT cod_titulo, 
          val_bruto, 
          "REC TIT "||cod_titulo,
          "5003",
          cod_cliente
     FROM geo_acerto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   UNION ALL
   SELECT cod_titulo, 
          val_bruto, 
          "COB TIT "||cod_titulo,
          "5002",
          cod_cliente
     FROM geo_acerto_cobranca
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   UNION ALL
   SELECT cod_titulo, 
          val_juros, 
          "JUR TIT "||cod_titulo,
          "5006",
          cod_cliente
     FROM geo_acerto_cobranca
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   
   CALL log2250_busca_parametro(p_cod_empresa,'geo_cod_oper_mcx')
   RETURNING l_parametro1, l_status
   IF l_parametro1 IS NULL OR l_parametro1 = " " THEN
      LET l_parametro1 = "5003"
   END IF 
   
   CALL log2250_busca_parametro(p_cod_empresa,'geo_cod_oper_mcx_cob')
   RETURNING l_parametro2, l_status
   IF l_parametro2 IS NULL OR l_parametro2 = " " THEN
      LET l_parametro2 = "5002"
   END IF 
   
   CALL log2250_busca_parametro(p_cod_empresa,'geo_cod_oper_mcx_jur')
   RETURNING l_parametro3, l_status
   IF l_parametro3 IS NULL OR l_parametro3 = " " THEN
      LET l_parametro3 = "5006"
   END IF 
   
   FOREACH cq_mcx_receitas INTO l_cod_titulo, l_val_receita, l_descricao, l_operacao, l_cod_cliente
      
      IF l_val_receita = 0 THEN
         CONTINUE FOREACH
      END IF
      
      LET l_ind = l_ind + 1
      
      
      LET la_dados[l_ind].caixa            = l_parametro CLIPPED
      
      
      SELECT des_caixa
        INTO la_dados[l_ind].des_caixa
        FROM mcx_caixa
       WHERE empresa = p_cod_empresa
         AND caixa = la_dados[l_ind].caixa
   
      LET la_dados[l_ind].dat_movto        = mr_tela.data_movto
      IF l_operacao = "5003" THEN
         LET la_dados[l_ind].operacao         = l_parametro1
      ELSE
         IF l_operacao = "5002" THEN
         	LET la_dados[l_ind].operacao         = l_parametro2
         ELSE
         	LET la_dados[l_ind].operacao         = l_parametro3
         END IF
      END IF
      
      SELECT tip_operacao
        INTO la_dados[l_ind].tip_operacao
        FROM mcx_operacao_caixa
       WHERE empresa = p_cod_empresa
         AND operacao = la_dados[l_ind].operacao
      
      
      SELECT des_operacao
        INTO la_dados[l_ind].des_operacao
        FROM mcx_operacao_caixa
       WHERE empresa = p_cod_empresa
         AND operacao = la_dados[l_ind].operacao
      
      LET l_txt = mr_tela.cod_manifesto
      LET la_dados[l_ind].docum            = l_cod_titulo
      LET la_dados[l_ind].val_docum        = l_val_receita
      LET la_dados[l_ind].hist_movto       = l_descricao
      #LET la_dados[l_ind].centro_custo     = l_cod_cc
      LET la_dados[l_ind].cod_titulo       = l_cod_titulo
      LET la_dados[l_ind].cod_cliente      = l_cod_cliente
      
      SELECT ies_tip_docum
        INTO la_dados[l_ind].tip_docum
        FROM docum
       WHERE cod_empresa = p_cod_empresa
         AND num_docum = l_cod_titulo
      
   END FOREACH
   
   ### EXECUTA ENTRADA NO MCX
   IF NOT geo1018_controle(la_dados) THEN
      RETURN FALSE
   END IF 
   
   UPDATE geo_manifesto
      SET sit_manifesto = 'E',
          dat_fechamento = TODAY
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","geo_manifesto")
   END IF 
   
   DELETE 
     FROM geo_acerto_cc
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","geo_acerto_cc")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   INSERT INTO geo_acerto_cc VALUES (p_cod_empresa,
                                      mr_tela.cod_manifesto,
                                      mr_tela.saldo_vendedor,
                                      mr_tela.saldo_cc)
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","geo_acerto_cc")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL geo1014_saldo_cc_real()
   UPDATE geo_repres_paramet
      SET saldo_cc_ant = saldo_cc,
          saldo_cc = mr_tela.saldo_cc
    WHERE cod_repres = m_cod_repres
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","geo_manifesto")
   END IF
   
   ####### FIX PARA TITULOS NAO BAIXADOS
   CALL geo1014_baixa_titulos_que_deveriam_estar_baixados()
   #######
   
   CALL _ADVPL_message_box("Processamento finalizado com sucesso")
   
   LET mr_tela.sit_manifesto = "E"
   
   RETURN TRUE
END FUNCTION

#--------------------------#
FUNCTION geo1014_estornar()
#--------------------------#
   DEFINE l_num_docum    CHAR(15)
   DEFINE l_hist_movto CHAR(50)
   DEFINE l_parametro CHAR(9)
   DEFINE l_status SMALLINT
   DEFINE l_seq_caixa SMALLINT
   DEFINE l_num_remessa INTEGER
   DEFINE l_ser_remessa INTEGER
   DEFINE l_aviso_rec INTEGER
   DEFINE l_cod_titulo LIKE docum.num_docum
   DEFINE l_num_seq_docum INTEGER
   DEFINE l_obs CHAR(70)
   
   
   IF NOT m_consulta_ativa THEN
 	  CALL _ADVPL_message_box("Informe um manifesto antes de estornar o acerto.")
 	  RETURN FALSE
   END IF 
   
   IF mr_tela.sit_manifesto <> "E" THEN
      CALL _ADVPL_message_box("O acerto precisa estar encerrado para efetuar o estorno")
      RETURN FALSE
   END IF
   
   IF NOT log_pergunta("Confirma o estorno do manifesto "||mr_tela.cod_manifesto|| " ?") THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   
   CALL log2250_busca_parametro(p_cod_empresa,'geo_cod_caixa_acerto')
   RETURNING l_parametro, l_status
   IF l_parametro IS NULL OR l_parametro = " " THEN
      LET l_parametro = "1"
   END IF 
   
   DECLARE cq_est_desp CURSOR WITH HOLD FOR
   SELECT num_docum, descricao
     FROM geo_acerto_despesas
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   FOREACH cq_est_desp INTO l_num_docum, l_hist_movto
      
      DECLARE cq_seq_cx CURSOR WITH HOLD FOR
      SELECT sequencia_caixa
        FROM mcx_movto 
       WHERE empresa = p_cod_empresa
         AND caixa = l_parametro
         AND dat_movto = mr_tela.data_movto
         AND docum = l_num_docum
         AND hist_movto = l_hist_movto
   	  FOREACH cq_seq_cx INTO l_seq_caixa
	      DELETE
	        FROM mcx_lancto_contab 
	       WHERE empresa = p_cod_empresa
	         AND caixa = l_parametro
	         AND dat_movto = mr_tela.data_movto
	         AND sequencia_caixa = l_seq_caixa
	      IF sqlca.sqlcode <> 0 THEN
	         CALL log085_transacao("ROLLBACK")
	         CALL log003_err_sql("DELETE","mcx_lancto_contab")
	         RETURN FALSE
	      END IF 
	      DELETE
	        FROM mcx_movto 
	       WHERE empresa = p_cod_empresa
	         AND caixa = l_parametro
	         AND dat_movto = mr_tela.data_movto
	         AND docum = l_num_docum
	         AND sequencia_caixa = l_seq_caixa
	      IF sqlca.sqlcode <> 0 THEN
	         CALL log085_transacao("ROLLBACK")
	         CALL log003_err_sql("DELETE","mcx_movto")
	         RETURN FALSE
	      END IF 
	   END FOREACH
      
   END FOREACH
   
   DECLARE cq_mcx_est_receitas CURSOR WITH HOLD FOR
   SELECT cod_titulo, 
          "REC TIT "||cod_titulo
     FROM geo_acerto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   UNION ALL
   SELECT cod_titulo, 
          "COB TIT "||cod_titulo
     FROM geo_acerto_cobranca
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   UNION ALL
   SELECT cod_titulo, 
          "JUR TIT "||cod_titulo
     FROM geo_acerto_cobranca
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   
   FOREACH cq_mcx_est_receitas INTO l_num_docum, l_hist_movto
      
      DECLARE cq_seq_mcx CURSOR WITH HOLD FOR
      SELECT sequencia_caixa
        FROM mcx_movto 
       WHERE empresa = p_cod_empresa
         AND caixa = l_parametro
         AND dat_movto = mr_tela.data_movto
        # AND docum = l_num_docum
         AND hist_movto = l_hist_movto
     FOREACH cq_seq_mcx INTO l_seq_caixa
         
	      DELETE
	        FROM mcx_lancto_contab 
	       WHERE empresa = p_cod_empresa
	         AND caixa = l_parametro
	         AND dat_movto = mr_tela.data_movto
	         AND sequencia_caixa = l_seq_caixa
	         
	      IF sqlca.sqlcode <> 0 THEN
	         CALL log085_transacao("ROLLBACK")
	         CALL log003_err_sql("DELETE","mcx_lancto_contab")
	         RETURN FALSE
	      END IF 
	      
	      DELETE
	        FROM mcx_mov_baixa_cre
	       WHERE empresa = p_cod_empresa
	         AND caixa = l_parametro
	         AND dat_movto = mr_tela.data_movto
	         AND sequencia_caixa = l_seq_caixa
	         #AND docum = l_num_docum
	      IF sqlca.sqlcode <> 0 THEN
	         CALL log085_transacao("ROLLBACK")
	         CALL log003_err_sql("DELETE","mcx_mov_baixa_cre")
	         RETURN FALSE
	      END IF 
	      DELETE
	        FROM mcx_movto 
	       WHERE empresa = p_cod_empresa
	         AND caixa = l_parametro
	         AND dat_movto = mr_tela.data_movto
	         #AND docum = l_num_docum
	         AND sequencia_caixa = l_seq_caixa
	      IF sqlca.sqlcode <> 0 THEN
	         CALL log085_transacao("ROLLBACK")
	         CALL log003_err_sql("DELETE","mcx_movto")
	         RETURN FALSE
	      END IF 
	   END FOREACH
      
   END FOREACH
   
   
   DELETE 
     FROM pgto_det 
    WHERE cod_empresa = p_cod_empresa
      AND num_docum IN (SELECT DISTINCT cod_titulo 
                          FROM geo_acerto
                         WHERE cod_empresa = p_cod_empresa
                           AND cod_manifesto = mr_tela.cod_manifesto
                        UNION ALL
                        SELECT DISTINCT cod_titulo
                          FROM geo_acerto_cobranca
                         WHERE cod_empresa = p_cod_empresa
                           AND cod_manifesto = mr_tela.cod_manifesto)
   IF sqlca.sqlcode <> 0 THEN
      CALL log085_transacao("ROLLBACK")
      CALL log003_err_sql("DELETE","pgto_det")
      RETURN FALSE
   END IF  
   #DELETE 
   #  FROM docum_obs 
   # WHERE cod_empresa = p_cod_empresa
   #   AND num_docum IN (SELECT DISTINCT cod_titulo 
   #                       FROM geo_acerto
   #                      WHERE cod_empresa = p_cod_empresa
   #                        AND cod_manifesto = mr_tela.cod_manifesto
   #                     UNION ALL
   #                     SELECT DISTINCT cod_titulo
   #                       FROM geo_acerto_cobranca
   #                      WHERE cod_empresa = p_cod_empresa
   #                        AND cod_manifesto = mr_tela.cod_manifesto)
   #IF sqlca.sqlcode <> 0 THEN
   #   CALL log085_transacao("ROLLBACK")
   #   CALL log003_err_sql("DELETE","docum_obs")
   #   RETURN FALSE
   #END IF  
   
   DECLARE cq_est_doc_obs CURSOR WITH HOLD FOR
   SELECT DISTINCT cod_titulo 
      FROM geo_acerto
     WHERE cod_empresa = p_cod_empresa
       AND cod_manifesto = mr_tela.cod_manifesto
    UNION ALL
    SELECT DISTINCT cod_titulo
      FROM geo_acerto_cobranca
     WHERE cod_empresa = p_cod_empresa
       AND cod_manifesto = mr_tela.cod_manifesto
   FOREACH cq_est_doc_obs INTO l_cod_titulo
      SELECT MAX(num_seq_docum)
        INTO l_num_seq_docum
        FROM docum_obs
       WHERE cod_empresa = p_cod_empresa
         AND num_docum = l_cod_titulo
         AND ies_tip_docum = 'DP'
      
      IF l_num_seq_docum IS NULL THEN
      	 LET l_num_seq_docum = 0
      END IF
      
      LET l_num_seq_docum = l_num_seq_docum + 1
   	  
   	  LET l_obs = 'ESTORNO DE TITULO VIA GEO1014 EM',TODAY," AS ",EXTEND(CURRENT, HOUR TO SECOND)
   	  INSERT INTO docum_obs VALUES (p_cod_empresa,
   	                                l_cod_titulo,
   	                                'DP',
   	                                l_num_seq_docum,
   	                                TODAY,
   	                                l_obs,
   	                                ' ',
   	                                ' ',
   	                                TODAY)
   	  IF sqlca.sqlcode <> 0 THEN
	      CALL log085_transacao("ROLLBACK")
	      CALL log003_err_sql("UPDATE","docum")
	      RETURN FALSE
	   END IF                      
   END FOREACH 
   
   DELETE
     FROM docum_pgto 
    WHERE cod_empresa = p_cod_empresa
      AND num_docum IN (SELECT DISTINCT cod_titulo 
                          FROM geo_acerto
                         WHERE cod_empresa = p_cod_empresa
                           AND cod_manifesto = mr_tela.cod_manifesto
                        UNION ALL
                        SELECT DISTINCT cod_titulo
                          FROM geo_acerto_cobranca
                         WHERE cod_empresa = p_cod_empresa
                           AND cod_manifesto = mr_tela.cod_manifesto)
   IF sqlca.sqlcode <> 0 THEN
      CALL log085_transacao("ROLLBACK")
      CALL log003_err_sql("DELETE","docum_pgto")
      RETURN FALSE
   END IF  
   UPDATE docum 
      SET ies_pgto_docum = 'A', 
          val_saldo = val_bruto  
    WHERE cod_empresa = p_cod_empresa 
      AND num_docum IN (SELECT DISTINCT cod_titulo 
                          FROM geo_acerto
                         WHERE cod_empresa = p_cod_empresa
                           AND cod_manifesto = mr_tela.cod_manifesto
                        UNION ALL
                        SELECT DISTINCT cod_titulo
                          FROM geo_acerto_cobranca
                         WHERE cod_empresa = p_cod_empresa
                           AND cod_manifesto = mr_tela.cod_manifesto)
   IF sqlca.sqlcode <> 0 THEN
      CALL log085_transacao("ROLLBACK")
      CALL log003_err_sql("UPDATE","docum")
      RETURN FALSE
   END IF          
   UPDATE geo_manifesto 
      SET sit_manifesto = 'R' 
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto;
   IF sqlca.sqlcode <> 0 THEN
      CALL log085_transacao("ROLLBACK")
      CALL log003_err_sql("UPDATE","geo_manifesto")
      RETURN FALSE
   END IF  
   
   CALL log085_transacao("COMMIT")
   
   CALL geo1014_saldo_cc_real()
   UPDATE geo_repres_paramet
      SET saldo_cc = mr_tela.saldo_cc
    WHERE cod_repres = m_cod_repres
   IF sqlca.sqlcode <> 0 THEN
      CALL log085_transacao("ROLLBACK")
      CALL log003_err_sql("UPDATE","geo_repres_paramet")
      RETURN FALSE
   END IF   
   
   LET mr_tela.sit_manifesto = "R"
   RETURN TRUE  
   
END FUNCTION

#--------------------------#
FUNCTION geo1014_gera_nfr()
#--------------------------#
	CALL LOG_progress_start("Gerando NFR","geo1014_processa_gera_nfr","PROCESS")
END FUNCTION
#----------------------------------#
FUNCTION geo1014_processa_gera_nfr()
#----------------------------------#
    define l_qtd_vendido  decimal(17,6)
    define l_qtd_retornado decimal(17,6)
    define l_qtd_remessa  decimal(17,6)
    define l_tem_divergencia smallint
    define l_cod_item char(15)
	DEFINE l_reservado    LIKE sup_compl_nf_sup.reservado
	define l_modelo_nf    char(2)
	DEFINE l_primeiro            SMALLINT
	DEFINE l_ind                 INTEGER
	DEFINE lr_nf_sup_erro        RECORD LIKE nf_sup_erro.*
	DEFINE lr_nfe_sup_compl      RECORD LIKE nfe_sup_compl.*
	DEFINE lr_aviso_rec_compl    RECORD  cod_empresa char(2),      
                                         num_aviso_rec decimal(6), 
                                         cod_transpor char(19),             
                                         den_transpor char(50),             
                                         num_placa_veic char(10),           
                                         num_di decimal(10,0),                
                                         ies_incl_import char(1),           
                                         num_lote_pat decimal(3,0),           
                                         cod_operacao char(4),              
                                         cod_empresa_orig char(2),          
                                         cod_moeda_forn decimal(2,0),         
                                         num_embarque char(15),             
                                         ies_situacao char(1),              
                                         nom_usuario char(8),               
                                         dat_proces date,               
                                         hor_operac char(8),                
                                         cod_fiscal_compl intEGER,     
                                         filial decimal(10)      
	                             END RECORD
	                              
	DEFINE lr_aviso_rec_compl_sq RECORD LIKE aviso_rec_compl_sq.*
	DEFINE lr_obf_nf_integr      RECORD LIKE obf_nf_integr.*
	DEFINE lr_ar_subst_tribut    RECORD LIKE ar_subst_tribut.*
	DEFINE lr_dest_aviso_rec     RECORD LIKE dest_aviso_rec.*
	DEFINE lr_audit_ar           RECORD LIKE audit_ar.*
	DEFINE lr_nf_sup             RECORD LIKE nf_sup.*
	DEFINE lr_SUP_RELC_FTRE_INDT RECORD LIKE SUP_RELC_FTRE_INDT.*
	DEFINE lr_SUP_PAR_DEVOL_CLI  RECORD LIKE SUP_PAR_DEVOL_CLI.*
	DEFINE l_comando             CHAR(999)
	DEFINE l_cancel              SMALLINT
	DEFINE lr_aviso_rec          RECORD LIKE aviso_rec.*
	DEFINE lr_sup_par_ar         RECORD LIKE sup_par_ar.*
	DEFINE l_nota, l_serie, l_emis CHAR(20)
	DEFINE l_trans_remessa INTEGER
	DEFINE l_trans_config  INTEGER
	DEFINE l_tributacao    INTEGER
	DEFINE lr_remessa_movto      RECORD 
	      	cod_empresa char(2),
			cod_manifesto integer,
			num_remessa integer,
			ser_remessa char(3),
			trans_remessa integer,
			tipo_movto char(1),
			cod_item char(15),
			qtd_movto decimal(20,5),
			num_nf integer,
			ser_nf char(3),
			trans_nota_fiscal integer,
			dat_movto date
	   END RECORD
	
	IF NOT log_pergunta("Este processo irá gerar NF de Retorno de carga. Deseja continuar?") THEN
		RETURN FALSE
	END IF 
	
	IF mr_tela.cod_manifesto IS NULL OR mr_tela.cod_manifesto = " " THEN
		CALL _ADVPL_message_box("Pesquise a NF antes de gerar a NF")
		RETURN FALSE
	END IF
	
	let l_tem_divergencia = false
	#adolar ini
	declare cq_item_geo cursor for 
	SELECT distinct(cod_item)
	  FROM geo_remessa_movto
	 WHERE cod_empresa = p_cod_empresa
	   AND cod_manifesto = mr_tela.cod_manifesto
	   AND tipo_movto = "R"
	   AND qtd_movto > 0
	foreach cq_item_geo into l_cod_item 
	
	 let l_qtd_remessa = 0 
	 SELECT sum(d.qtd_movto)     
	   into l_qtd_remessa       
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
       and d.cod_item = l_cod_item
       IF l_qtd_remessa IS NULL OR l_qtd_remessa = "" THEN
          LET l_qtd_remessa = 0
       END IF 
       
         
	   let l_qtd_vendido = 0
	   SELECT SUM(a.qtd_movto)
         INTO l_qtd_vendido
         FROM geo_remessa_movto a, fat_nf_mestre b
        WHERE a.cod_empresa = p_cod_empresa
          AND a.cod_manifesto = mr_tela.cod_manifesto
          AND a.tipo_movto = 'S'          
          AND a.cod_empresa = b.empresa
          AND a.trans_nota_fiscal = b.trans_nota_fiscal
          AND b.sit_nota_fiscal = 'N'
          and a.cod_item = l_cod_item
       IF l_qtd_vendido IS NULL OR l_qtd_vendido = "" THEN
          LET l_qtd_vendido = 0
       END IF 
       
       let l_qtd_retornado = 0
       SELECT SUM(qtd_movto)
         INTO l_qtd_retornado
         FROM geo_remessa_movto
        WHERE cod_empresa = p_cod_empresa
          AND cod_manifesto = mr_tela.cod_manifesto
          AND tipo_movto = 'R'
          and cod_item = l_cod_item
       IF l_qtd_retornado IS NULL OR l_qtd_retornado = "" THEN
          LET l_qtd_retornado = 0
       END IF 
       
       if (l_qtd_remessa - l_qtd_vendido - l_qtd_retornado) <> 0 then
		   let l_tem_divergencia = true
		   IF NOT log_pergunta("Divergencia no item "||l_cod_item|| " de: "|| (l_qtd_remessa - l_qtd_vendido - l_qtd_retornado) using '<<<<<<.<<' ||" confirma o processamento ?") THEN
		      RETURN FALSE
		   END IF
	   end if 
   
    
    end foreach
    
    if l_tem_divergencia then	
		IF NOT log_pergunta("Deseja realmente confirmar as divergencias?") THEN
			RETURN FALSE
		END IF 
	end if
	  
     
	#adolar fin 2846
	
	DECLARE cq_nf_retorno CURSOR WITH HOLD FOR
	SELECT *
	  FROM geo_remessa_movto
	 WHERE cod_empresa = p_cod_empresa
	   AND cod_manifesto = mr_tela.cod_manifesto
	   AND tipo_movto = "R"
	   AND qtd_movto > 0
	
	LET l_primeiro = TRUE
	LET l_ind = 1
	FOREACH cq_nf_retorno INTO lr_remessa_movto.*
		IF lr_remessa_movto.cod_item IS NULL OR lr_remessa_movto.cod_item = " " THEN
			CONTINUE FOREACH
		END IF 
		IF lr_remessa_movto.qtd_movto IS NULL OR lr_remessa_movto.qtd_movto = " " OR lr_remessa_movto.qtd_movto = 0 THEN
			CONTINUE FOREACH
		END IF 
		IF l_primeiro THEN
		   	LET l_primeiro = FALSE
		   	
		   	INITIALIZE lr_nf_sup.* TO NULL
		   	
		   	SELECT cod_cliente
		   	  INTO lr_nf_sup.cod_fornecedor
		   	  FROM empresa
		   	 WHERE cod_empresa = p_cod_empresa
		   	 
		   	SELECT DISTINCT cod_empresa
		   	  FROM nf_sup
		   	 WHERE cod_empresa = p_cod_empresa
		   	   AND cod_fornecedor = lr_nf_sup.cod_fornecedor
		   	   AND ies_especie_nf = 'NFR'
		   	   AND num_nf = lr_remessa_movto.num_remessa
		   	   AND ser_nf = lr_remessa_movto.ser_remessa
		   	IF sqlca.sqlcode = 0 THEN
		   		CALL _ADVPL_message_box("Já foi gerada NF para este manifesto. Consulte via sup3760.")
		   		RETURN FALSE
		   	END IF 
		   	
		    SELECT DISTINCT a.empresa
		      FROM obf_nf_eletr a, nf_sup b
		     WHERE a.empresa = p_cod_empresa
		       AND a.aviso_recebto = (SELECT num_aviso_rec FROM geo_manifesto_ar WHERE cod_empresa = p_cod_empresa AND cod_manifesto = mr_tela.cod_manifesto)
		       AND a.sit_atual_nf_eletr = "N"
		       AND a.empresa = b.cod_empresa
		       AND a.aviso_recebto = b.num_aviso_rec
		       
		   	   #sit_atual_nf_eletr = C AND protoc_env_normal = NULL  - INUTILIZADA
		   	   #sit_atual_nf_eletr = C AND protoc_env_normal <> NULL - CANCELADA
		   	
		   	    
		   	IF sqlca.sqlcode = 0 THEN
		   		CALL _ADVPL_message_box("Já foi gerada NF para este manifesto. Consulte via sup3760.")
		   		RETURN FALSE
		   	END IF 
		   	
		   	LET lr_nf_sup.cod_empresa          = p_cod_empresa 
			LET lr_nf_sup.cod_empresa_estab    = NULL
			LET lr_nf_sup.num_nf               = lr_remessa_movto.num_remessa
			LET lr_nf_sup.ser_nf               = lr_remessa_movto.ser_remessa
			LET lr_nf_sup.ssr_nf               = "0"
			LET lr_nf_sup.ies_especie_nf       = "NFR"
			 
			LET lr_nf_sup.num_conhec           = "0"
			LET lr_nf_sup.ser_conhec           = " "
			LET lr_nf_sup.ssr_conhec           = "0"
			LET lr_nf_sup.cod_transpor         = "0"
			
			SELECT par_val
			  INTO lr_nf_sup.num_aviso_rec
			  FROM par_sup_pad 
			 WHERE cod_empresa = p_cod_empresa 
			   AND cod_parametro = 'num_prx_ar'
			IF sqlca.sqlcode <> 0 THEN
			   	CALL _ADVPL_message_box("O parametro num_prx_ar não foi encontrado na tabela par_sup_pad")
			   	RETURN FALSE
			ELSE
			   	UPDATE par_sup_pad 
			       SET par_val = par_val + 1 
			     WHERE cod_empresa = p_cod_empresa 
			       AND cod_parametro = 'num_prx_ar'
			   	IF sqlca.sqlcode <> 0 THEN
			   		CALL _ADVPL_message_box("Ocorreu uma falha ao atualizar o parametro num_prx_ar na tabela par_sup_pad")
			   		RETURN FALSE
			   	END IF 
			END IF 
			
			
			CALL log085_transacao("BEGIN")
			
			LET lr_nf_sup.dat_emis_nf          = TODAY
			LET lr_nf_sup.dat_entrada_nf       = TODAY
			LET lr_nf_sup.cod_regist_entrada   = "1"
			
			SELECT SUM(a.qtd_movto * (b.val_contab_item/b.qtd_item))
			  INTO lr_nf_sup.val_tot_nf_d
			  FROM geo_remessa_movto a, fat_nf_item b
			 WHERE a.cod_empresa = p_cod_empresa
			   AND a.cod_manifesto = mr_tela.cod_manifesto
			   AND a.tipo_movto = 'R'
			   AND a.cod_empresa = b.empresa
			   AND a.trans_remessa = b.trans_nota_fiscal
			   AND a.cod_item = b.item
			
			LET lr_nf_sup.val_tot_nf_c         = lr_nf_sup.val_tot_nf_d
			
			SELECT SUM(a.qtd_movto * (c.val_tributo_tot/b.qtd_item))
			  INTO lr_nf_sup.val_tot_icms_nf_d
			  FROM geo_remessa_movto a, fat_nf_item b, fat_nf_item_fisc c
			 WHERE a.cod_empresa = p_cod_empresa
			   AND a.cod_manifesto = mr_tela.cod_manifesto
			   AND a.tipo_movto = 'R'
			   AND a.cod_empresa = b.empresa
			   AND a.trans_remessa = b.trans_nota_fiscal
			   AND a.cod_item = b.item
			   AND b.empresa = c.empresa
			   AND b.trans_nota_fiscal = c.trans_nota_fiscal
			   AND c.tributo_benef = 'ICMS'
			   AND b.seq_item_nf = c.seq_item_nf
			
			LET lr_nf_sup.val_tot_icms_nf_c    = 0
			LET lr_nf_sup.val_tot_desc         = 0
			LET lr_nf_sup.val_tot_acresc       = 0
			
			SELECT SUM(a.qtd_movto * (c.val_tributo_tot/b.qtd_item))
			  INTO lr_nf_sup.val_ipi_nf
			  FROM geo_remessa_movto a, fat_nf_item b, fat_nf_item_fisc c
			 WHERE a.cod_empresa = p_cod_empresa
			   AND a.cod_manifesto = mr_tela.cod_manifesto
			   AND a.tipo_movto = 'R'
			   AND a.cod_empresa = b.empresa
			   AND a.trans_remessa = b.trans_nota_fiscal
			   AND a.cod_item = b.item
			   AND b.empresa = c.empresa
			   AND b.trans_nota_fiscal = c.trans_nota_fiscal
			   AND c.tributo_benef = 'IPI'
			   AND b.seq_item_nf = c.seq_item_nf
			   
			LET lr_nf_sup.val_ipi_calc         = lr_nf_sup.val_ipi_nf 
			LET lr_nf_sup.val_despesa_aces     = 0
			LET lr_nf_sup.val_adiant           = 0
			LET lr_nf_sup.ies_tip_frete        = 0
			LET lr_nf_sup.cnd_pgto_nf          = 999
			LET lr_nf_sup.cod_mod_embar        = 3
			LET lr_nf_sup.ies_nf_com_erro      = "S"
			LET lr_nf_sup.nom_resp_aceite_er   = NULL
			LET lr_nf_sup.ies_incl_cap         = "N"
			LET lr_nf_sup.ies_incl_contab      = "N"
			LET lr_nf_sup.cod_operacao         = "5.414"
			LET lr_nf_sup.ies_calc_subst       = ""
			
			SELECT SUM(a.qtd_movto * (c.bc_tributo_tot/b.qtd_item)),SUM(a.qtd_movto * (c.val_tributo_tot/b.qtd_item))
			  INTO lr_nf_sup.val_bc_subst_d, lr_nf_sup.val_icms_subst_d
			  FROM geo_remessa_movto a, fat_nf_item b, fat_nf_item_fisc c
			 WHERE a.cod_empresa = p_cod_empresa
			   AND a.cod_manifesto = mr_tela.cod_manifesto
			   AND a.tipo_movto = 'R'
			   AND a.cod_empresa = b.empresa
			   AND a.trans_remessa = b.trans_nota_fiscal
			   AND a.cod_item = b.item
			   AND b.empresa = c.empresa
			   AND b.trans_nota_fiscal = c.trans_nota_fiscal
			   AND c.tributo_benef = 'ICMS_ST'
			   AND b.seq_item_nf = c.seq_item_nf
			
			#IF lr_nf_sup.val_bc_subst_d IS NULL OR lr_nf_sup.val_bc_subst_d = " " THEN
				LET lr_nf_sup.val_bc_subst_d = 0
			#END IF 
			#IF lr_nf_sup.val_icms_subst_d IS NULL OR lr_nf_sup.val_icms_subst_d = " " THEN
				LET lr_nf_sup.val_icms_subst_d = 0
			#END IF 
			LET lr_nf_sup.val_bc_subst_c       = 0 
			LET lr_nf_sup.val_icms_subst_c     = 0 
			LET lr_nf_sup.cod_imp_renda        = NULL
			LET lr_nf_sup.val_imp_renda        = 0
			LET lr_nf_sup.ies_situa_import     = " "
			LET lr_nf_sup.val_bc_imp_renda     = 0
			LET lr_nf_sup.ies_nf_aguard_nfe    = "7"
		   
		    INSERT INTO nf_sup VALUES (lr_nf_sup.*)
		    IF sqlca.sqlcode <> 0 THEN
		    	CALL log085_transacao("ROLLBACK")
		    	RETURN FALSE
		    END IF 
		    
		    LET lr_sup_par_ar.empresa           = p_cod_empresa
			LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
			LET lr_sup_par_ar.seq_aviso_recebto = 0
			LET lr_sup_par_ar.parametro         = "data_hora_nf_entrada"
			LET lr_sup_par_ar.par_ind_especial  = " "
			LET lr_sup_par_ar.parametro_texto   = CURRENT
			LET lr_sup_par_ar.parametro_val     = NULL
			LET lr_sup_par_ar.parametro_dat     = NULL
			INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
			IF sqlca.sqlcode <> 0 THEN
		    	CALL log085_transacao("ROLLBACK")
		    	RETURN FALSE
		    END IF 
		    
			{LET lr_sup_par_ar.empresa           = p_cod_empresa
			LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
			LET lr_sup_par_ar.seq_aviso_recebto = 0
			LET lr_sup_par_ar.parametro         = "meio_transp_ar"
			LET lr_sup_par_ar.par_ind_especial  = NULL
			LET lr_sup_par_ar.parametro_texto   = NULL
			LET lr_sup_par_ar.parametro_val     = 1
			LET lr_sup_par_ar.parametro_dat     = NULL
			INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
			IF sqlca.sqlcode <> 0 THEN
		    	CALL log085_transacao("ROLLBACK")
		    	RETURN FALSE
		    END IF }
		    
			LET lr_sup_par_ar.empresa           = p_cod_empresa
			LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
			LET lr_sup_par_ar.seq_aviso_recebto = 0
			LET lr_sup_par_ar.parametro         = "num_nf_inclusao"
			LET lr_sup_par_ar.par_ind_especial  = " "
			LET lr_sup_par_ar.parametro_texto   = " "
			LET lr_sup_par_ar.parametro_val     = lr_nf_sup.num_nf
			LET lr_sup_par_ar.parametro_dat     = TODAY
			INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
			IF sqlca.sqlcode <> 0 THEN
		    	CALL log085_transacao("ROLLBACK")
		    	RETURN FALSE
		    END IF 
		    
			{LET lr_sup_par_ar.empresa           = p_cod_empresa
			LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
			LET lr_sup_par_ar.seq_aviso_recebto = 0
			LET lr_sup_par_ar.parametro         = "finalidade_nfe"
			LET lr_sup_par_ar.par_ind_especial  = NULL
			LET lr_sup_par_ar.parametro_texto   = NULL
			LET lr_sup_par_ar.parametro_val     = 1
			LET lr_sup_par_ar.parametro_dat     = TODAY
			INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
			IF sqlca.sqlcode <> 0 THEN
		    	CALL log085_transacao("ROLLBACK")
		    	RETURN FALSE
		    END IF 
		    
			LET lr_sup_par_ar.empresa           = p_cod_empresa
			LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
			LET lr_sup_par_ar.seq_aviso_recebto = 0
			LET lr_sup_par_ar.parametro         = "id_consum_final"
			LET lr_sup_par_ar.par_ind_especial  = NULL
			LET lr_sup_par_ar.parametro_texto   = NULL
			LET lr_sup_par_ar.parametro_val     = 0
			LET lr_sup_par_ar.parametro_dat     = TODAY
			INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
			IF sqlca.sqlcode <> 0 THEN
		    	CALL log085_transacao("ROLLBACK")
		    	RETURN FALSE
		    END IF 
		    
			LET lr_sup_par_ar.empresa           = p_cod_empresa
			LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
			LET lr_sup_par_ar.seq_aviso_recebto = 0
			LET lr_sup_par_ar.parametro         = "id_consum_pres"
			LET lr_sup_par_ar.par_ind_especial  = NULL
			LET lr_sup_par_ar.parametro_texto   = "Outros"
			LET lr_sup_par_ar.parametro_val     = 9
			LET lr_sup_par_ar.parametro_dat     = TODAY
			INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
			IF sqlca.sqlcode <> 0 THEN
		    	CALL log085_transacao("ROLLBACK")
		    	RETURN FALSE
		    END IF }
		    
			LET lr_sup_par_ar.empresa           = p_cod_empresa
			LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
			LET lr_sup_par_ar.seq_aviso_recebto = 0
			LET lr_sup_par_ar.parametro         = "ind_ie_dest"
			LET lr_sup_par_ar.par_ind_especial  = NULL
			LET lr_sup_par_ar.parametro_texto   = "535038505118"
			LET lr_sup_par_ar.parametro_val     = 1
			LET lr_sup_par_ar.parametro_dat     = TODAY
			INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
			IF sqlca.sqlcode <> 0 THEN
		    	CALL log085_transacao("ROLLBACK")
		    	RETURN FALSE
		    END IF 
		    
			{LET lr_sup_par_ar.empresa           = p_cod_empresa
			LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
			LET lr_sup_par_ar.seq_aviso_recebto = 0
			LET lr_sup_par_ar.parametro         = "pend_calc_decl"
			LET lr_sup_par_ar.par_ind_especial  = "S"
			LET lr_sup_par_ar.parametro_texto   = NULL
			LET lr_sup_par_ar.parametro_val     = NULL
			LET lr_sup_par_ar.parametro_dat     = TODAY
			INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
			IF sqlca.sqlcode <> 0 THEN
		    	CALL log085_transacao("ROLLBACK")
		    	RETURN FALSE
		    END IF }
		    
		    
		    
		    
			LET lr_aviso_rec_compl.cod_empresa       = p_cod_empresa
			LET lr_aviso_rec_compl.num_aviso_rec     = lr_nf_sup.num_aviso_rec
			LET lr_aviso_rec_compl.cod_transpor      = NULL
			LET lr_aviso_rec_compl.den_transpor      = NULL
			LET lr_aviso_rec_compl.num_placa_veic    = NULL
			LET lr_aviso_rec_compl.num_di            = NULL
			LET lr_aviso_rec_compl.ies_incl_import   = NULL
			LET lr_aviso_rec_compl.num_lote_pat      = NULL
			LET lr_aviso_rec_compl.cod_operacao      = '   '
			LET lr_aviso_rec_compl.cod_empresa_orig  = NULL
			LET lr_aviso_rec_compl.cod_moeda_forn    = NULL
			LET lr_aviso_rec_compl.num_embarque      = NULL
			LET lr_aviso_rec_compl.ies_situacao      = 'N'
			LET lr_aviso_rec_compl.nom_usuario       = NULL
			LET lr_aviso_rec_compl.dat_proces        = NULL
			LET lr_aviso_rec_compl.hor_operac        = NULL
			LET lr_aviso_rec_compl.cod_fiscal_compl  = 0
			LET lr_aviso_rec_compl.filial            = NULL
			
			INSERT INTO aviso_rec_compl VALUES (lr_aviso_rec_compl.*)
			IF sqlca.sqlcode <> 0 THEN
		    	CALL log085_transacao("ROLLBACK")
		    	RETURN FALSE
		    END IF 
		    
			LET lr_obf_nf_integr.empresa             = p_cod_empresa
			LET lr_obf_nf_integr.empresa_estab       = NULL
			LET lr_obf_nf_integr.aviso_recebto       = lr_nf_sup.num_aviso_rec
			LET lr_obf_nf_integr.num_conhecimento    = 0
			LET lr_obf_nf_integr.serie_conhecimento  = '0'
			LET lr_obf_nf_integr.subser_conhecimento = 0
			LET lr_obf_nf_integr.transportador       = '0'
			LET lr_obf_nf_integr.sit_nota_fiscal     = 'N'
			LET lr_obf_nf_integr.status_integr       = 'E'
			LET lr_obf_nf_integr.data_hor_integr_obf = CURRENT
			LET lr_obf_nf_integr.usuario             = p_user
			INSERT INTO obf_nf_integr VALUES (lr_obf_nf_integr.*)
			IF sqlca.sqlcode <> 0 THEN
		    	CALL log085_transacao("ROLLBACK")
		    	RETURN FALSE
		    END IF 
		    
			
			
		END IF 
		
		LET lr_aviso_rec.cod_empresa           = lr_nf_sup.cod_empresa
		LET lr_aviso_rec.cod_empresa_estab     = NULL
		LET lr_aviso_rec.num_aviso_rec         = lr_nf_sup.num_aviso_rec
		LET lr_aviso_rec.num_seq               = l_ind
		LET lr_aviso_rec.dat_inclusao_seq      = TODAY
		LET lr_aviso_rec.ies_situa_ar          = "E"
		LET lr_aviso_rec.ies_incl_almox        = "N"
		LET lr_aviso_rec.ies_receb_fiscal      = "S"
		LET lr_aviso_rec.ies_liberacao_ar      = "2"
		LET lr_aviso_rec.ies_liberacao_cont    = "S"
		LET lr_aviso_rec.ies_liberacao_insp    = "S"
		LET lr_aviso_rec.ies_diverg_listada    = "S"
		LET lr_aviso_rec.ies_item_estoq        = "N"
		LET lr_aviso_rec.ies_controle_lote     = "S"
		LET lr_aviso_rec.num_pedido            = NULL
		LET lr_aviso_rec.num_oc                = NULL
		LET lr_aviso_rec.cod_item              = lr_remessa_movto.cod_item
		
		SELECT DISTINCT des_item, unid_medida, preco_unit_bruto
		  INTO lr_aviso_rec.den_item, lr_aviso_rec.cod_unid_med_nf, lr_aviso_rec.pre_unit_nf
		  FROM fat_nf_item
		 WHERE empresa = p_cod_empresa
		   AND trans_nota_fiscal = lr_remessa_movto.trans_remessa
		   AND item = lr_remessa_movto.cod_item
		
		SELECT cod_cla_fisc
		  INTO lr_aviso_rec.cod_cla_fisc
		  FROM item
		 WHERE cod_empresa = p_cod_empresa
		   AND cod_item = lr_remessa_movto.cod_item
		   
		LET lr_aviso_rec.val_despesa_aces_i    = 0 
		LET lr_aviso_rec.ies_da_bc_ipi         = 'S'
		LET lr_aviso_rec.cod_incid_ipi         = '3'
		LET lr_aviso_rec.pct_direito_cred      = 0
		LET lr_aviso_rec.pct_ipi_declarad      = 0
		LET lr_aviso_rec.pct_ipi_tabela        = 0
		LET lr_aviso_rec.ies_bitributacao      = 'N'
		LET lr_aviso_rec.val_base_c_ipi_it     = lr_nf_sup.val_ipi_nf 
		LET lr_aviso_rec.val_base_c_ipi_da     = 0
		
		SELECT SUM(a.qtd_movto * (c.val_tributo_tot/b.qtd_item))
		  INTO lr_aviso_rec.val_ipi_decl_item
		  FROM geo_remessa_movto a, fat_nf_item b, fat_nf_item_fisc c
		 WHERE a.cod_empresa = p_cod_empresa
		   AND a.cod_manifesto = mr_tela.cod_manifesto
		   AND a.tipo_movto = 'R'
		   AND a.cod_empresa = b.empresa
		   AND a.trans_remessa = b.trans_nota_fiscal
		   AND a.cod_item = b.item
		   AND b.empresa = c.empresa
		   AND b.trans_nota_fiscal = c.trans_nota_fiscal
		   AND c.tributo_benef = 'IPI'
		   AND b.seq_item_nf = c.seq_item_nf
		   AND a.cod_item = lr_remessa_movto.cod_item
		
		IF lr_aviso_rec.val_ipi_decl_item IS NULL OR lr_aviso_rec.val_ipi_decl_item <> " " THEN
			LET lr_aviso_rec.val_ipi_decl_item = 0
		END IF
		
		LET lr_aviso_rec.val_ipi_calc_item     = 0
		LET lr_aviso_rec.val_ipi_desp_aces     = 0
		LET lr_aviso_rec.val_desc_item         = 0
		LET lr_aviso_rec.val_liquido_item      = lr_aviso_rec.pre_unit_nf * lr_remessa_movto.qtd_movto
		LET lr_aviso_rec.val_contabil_item     = lr_aviso_rec.val_liquido_item 
		LET lr_aviso_rec.qtd_declarad_nf       = lr_remessa_movto.qtd_movto
		LET lr_aviso_rec.qtd_recebida          = 0
		LET lr_aviso_rec.qtd_devolvid          = 0
		LET lr_aviso_rec.dat_devoluc           = NULL
		LET lr_aviso_rec.val_devoluc           = 0
		LET lr_aviso_rec.num_nf_dev            = 0
		LET lr_aviso_rec.qtd_rejeit            = 0
		LET lr_aviso_rec.qtd_liber             = lr_remessa_movto.qtd_movto
		LET lr_aviso_rec.qtd_liber_excep       = 0
		LET lr_aviso_rec.cus_tot_item          = 0
		
		SELECT gru_ctr_desp, 
		       cod_fiscal, 
		       cod_tip_despesa, 
		       ies_tip_incid_ipi,
		       cod_comprador,
		       ies_tip_incid_icms
		  INTO lr_aviso_rec.gru_ctr_desp_item, 
		       lr_aviso_rec.cod_fiscal_item, 
		       lr_aviso_rec.cod_tip_despesa, 
		       lr_aviso_rec.ies_tip_incid_ipi,
		       lr_aviso_rec.cod_comprador,
		       lr_aviso_rec.ies_incid_icms_ite
		  FROM item_sup
		 WHERE cod_empresa = p_cod_empresa
		   AND cod_item = lr_remessa_movto.cod_item
		
		
		IF lr_nf_sup.cod_operacao[1] = "6" THEN
			LET lr_aviso_rec.cod_fiscal_item = "2.",lr_aviso_rec.cod_fiscal_item CLIPPED
		ELSE
		   	IF lr_nf_sup.cod_operacao[1] = "7" THEN
		   		LET lr_aviso_rec.cod_fiscal_item = "3.",lr_aviso_rec.cod_fiscal_item CLIPPED
		   	ELSE
		   		LET lr_aviso_rec.cod_fiscal_item = "1.",lr_aviso_rec.cod_fiscal_item CLIPPED
		   	END IF
		END IF
		
		INITIALIZE mr_icms.* TO NULL
		   	 
	   	  SELECT * INTO mr_icms.*
		    FROM icms
		   WHERE icms.cod_empresa   = p_cod_empresa
		     AND icms.gru_ctr_desp  = lr_aviso_rec.gru_ctr_desp_item
		     AND icms.cod_uni_feder = "SP"
		IF sqlca.sqlcode <> 0 THEN
			CALL _ADVPL_message_box("Alíquota ICMS não encontrada para o grupo de despesa "||lr_aviso_rec.gru_ctr_desp_item||" ITEM: "||lr_remessa_movto.cod_item)
			CALL log085_transacao("ROLLBACK")
			RETURN FALSE
		END IF 
		
		LET lr_aviso_rec.cod_local_estoq       = " "
		LET lr_aviso_rec.num_lote              = NULL
		LET lr_aviso_rec.cod_operac_estoq      = " "
		LET lr_aviso_rec.val_base_c_item_c     = 0
		
		{SELECT SUM(a.qtd_movto * (c.val_tributo_tot/b.qtd_item)), 
		       SUM(c.aliquota), 
		       SUM(c.pct_red_bas_calc), 
		       SUM(a.qtd_movto * (c.bc_tributo_tot/b.qtd_item))
		  INTO lr_aviso_rec.val_icms_item_d, 
		       lr_aviso_rec.pct_icms_item_d, 
		       lr_aviso_rec.pct_red_bc_item_d, 
		       lr_aviso_rec.val_base_c_item_d
		  FROM geo_remessa_movto a, fat_nf_item b, fat_nf_item_fisc c
		 WHERE a.cod_empresa = p_cod_empresa
		   AND a.cod_manifesto = mr_tela.cod_manifesto
		   AND a.tipo_movto = 'R'
		   AND a.cod_empresa = b.empresa
		   AND a.trans_remessa = b.trans_nota_fiscal
		   AND a.cod_item = b.item
		   AND b.empresa = c.empresa
		   AND b.trans_nota_fiscal = c.trans_nota_fiscal
		   AND c.tributo_benef = 'ICMS'
		   AND b.seq_item_nf = c.seq_item_nf
		   AND a.cod_item = lr_remessa_movto.cod_item}
		   
		   
		LET lr_aviso_rec.pct_icms_item_d = mr_icms.pct_icms
		IF lr_aviso_rec.pct_icms_item_d IS NULL OR lr_aviso_rec.pct_icms_item_d = " " THEN
			LET lr_aviso_rec.pct_icms_item_d = 0
		END IF 
		LET lr_aviso_rec.pct_red_bc_item_d = mr_icms.pct_red_base_calc
		IF lr_aviso_rec.pct_red_bc_item_d IS NULL OR lr_aviso_rec.pct_red_bc_item_d = " " THEN
			LET lr_aviso_rec.pct_red_bc_item_d = 0
		END IF 
		LET lr_aviso_rec.val_base_c_item_d = lr_aviso_rec.val_liquido_item - (lr_aviso_rec.val_liquido_item * lr_aviso_rec.pct_red_bc_item_d / 100)
		IF lr_aviso_rec.val_base_c_item_d IS NULL OR lr_aviso_rec.val_base_c_item_d = " " THEN
			LET lr_aviso_rec.val_base_c_item_d = 0
		END IF 
		LET lr_aviso_rec.val_icms_item_d = lr_aviso_rec.val_base_c_item_d * lr_aviso_rec.pct_icms_item_d / 100
		IF lr_aviso_rec.val_icms_item_d IS NULL OR lr_aviso_rec.val_icms_item_d = " " THEN
			LET lr_aviso_rec.val_icms_item_d = 0
		END IF 
		
		
		
		LET lr_aviso_rec.pct_icms_item_c       = 0
		LET lr_aviso_rec.pct_red_bc_item_c     = 0
		LET lr_aviso_rec.pct_diferen_item_d    = mr_icms.pct_diferen_icms
		IF lr_aviso_rec.pct_diferen_item_d IS NULL OR lr_aviso_rec.pct_diferen_item_d = " " THEN
			LET lr_aviso_rec.pct_diferen_item_d = 0
		END IF
		LET lr_aviso_rec.pct_diferen_item_c    = 0
		LET lr_aviso_rec.val_icms_item_c       = 0
		LET lr_aviso_rec.val_base_c_icms_da    = 0
		LET lr_aviso_rec.val_icms_diferen_i    = 0
		LET lr_aviso_rec.val_icms_desp_aces    = 0
		
		LET lr_aviso_rec.val_frete             = 0
		LET lr_aviso_rec.val_icms_frete_d      = 0
		LET lr_aviso_rec.val_icms_frete_c      = 0
		LET lr_aviso_rec.val_base_c_frete_d    = 0
		LET lr_aviso_rec.val_base_c_frete_c    = 0
		LET lr_aviso_rec.val_icms_diferen_f    = 0
		LET lr_aviso_rec.pct_icms_frete_d      = 0
		LET lr_aviso_rec.pct_icms_frete_c      = 0
		LET lr_aviso_rec.pct_red_bc_frete_d    = 0
		LET lr_aviso_rec.pct_red_bc_frete_c    = 0
		LET lr_aviso_rec.pct_diferen_fret_d    = 0
		LET lr_aviso_rec.pct_diferen_fret_c    = 0
		LET lr_aviso_rec.val_acrescimos        = 0
		LET lr_aviso_rec.val_enc_financ        = 0
		LET lr_aviso_rec.ies_contabil          = 'N'
		LET lr_aviso_rec.ies_total_nf          = 'S'
		LET lr_aviso_rec.val_compl_estoque     = 0
		LET lr_aviso_rec.dat_ref_val_compl     = NULL
		LET lr_aviso_rec.pct_enc_financ        = 0
		LET lr_aviso_rec.cod_cla_fisc_nf       = " "
		LET lr_aviso_rec.observacao            = NULL
		
		INSERT INTO aviso_rec VALUES (lr_aviso_rec.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF 
	    
		
		{LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "desconto_fiscal"
		LET lr_sup_par_ar.par_ind_especial  = NULL
		LET lr_sup_par_ar.parametro_texto   = NULL
		LET lr_sup_par_ar.parametro_val     = 0
		LET lr_sup_par_ar.parametro_dat     = NULL
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF 
	    
		
		LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "cod_cest"
		LET lr_sup_par_ar.par_ind_especial  = NULL
		LET lr_sup_par_ar.parametro_texto   = NULL
		LET lr_sup_par_ar.parametro_val     = 1709600
		LET lr_sup_par_ar.parametro_dat     = NULL
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF }
	    
		
		{LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "cod_cst_IPI"
		LET lr_sup_par_ar.par_ind_especial  = NULL
		LET lr_sup_par_ar.parametro_texto   = NULL
		LET lr_sup_par_ar.parametro_val     = NULL
		LET lr_sup_par_ar.parametro_dat     = NULL
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF }
	    
		
		{LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "enquadr_legal_ipi"
		LET lr_sup_par_ar.par_ind_especial  = NULL
		LET lr_sup_par_ar.parametro_texto   = "1965"
		LET lr_sup_par_ar.parametro_val     = "999"
		LET lr_sup_par_ar.parametro_dat     = NULL
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF }
	    
		
		{LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "cod_cst_PIS"
		LET lr_sup_par_ar.par_ind_especial  = NULL
		LET lr_sup_par_ar.parametro_texto   = NULL
		LET lr_sup_par_ar.parametro_val     = NULL
		LET lr_sup_par_ar.parametro_dat     = NULL
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF}
	    
		
		{LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "cod_cst_COFINS"
		LET lr_sup_par_ar.par_ind_especial  = NULL
		LET lr_sup_par_ar.parametro_texto   = NULL
		LET lr_sup_par_ar.parametro_val     = NULL
		LET lr_sup_par_ar.parametro_dat     = NULL
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF}
	    
		
		{LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "bc_icms_sem_red_fix"
		LET lr_sup_par_ar.par_ind_especial  = NULL
		LET lr_sup_par_ar.parametro_texto   = NULL
		LET lr_sup_par_ar.parametro_val     = "1500"
		LET lr_sup_par_ar.parametro_dat     = NULL
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF }
	    
		
		{LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "val_icms_sem_red_fix"
		LET lr_sup_par_ar.par_ind_especial  = NULL
		LET lr_sup_par_ar.parametro_texto   = NULL
		LET lr_sup_par_ar.parametro_val     = "0"
		LET lr_sup_par_ar.parametro_dat     = NULL
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF }
	    
		
		{LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "pct_icms_sem_red_fix"
		LET lr_sup_par_ar.par_ind_especial  = NULL
		LET lr_sup_par_ar.parametro_texto   = NULL
		LET lr_sup_par_ar.parametro_val     = "0"
		LET lr_sup_par_ar.parametro_dat     = NULL
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF }
	    
		
		{LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "calc_st_formula"
		LET lr_sup_par_ar.par_ind_especial  = "U"
		LET lr_sup_par_ar.parametro_texto   = NULL
		LET lr_sup_par_ar.parametro_val     = NULL
		LET lr_sup_par_ar.parametro_dat     = NULL
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF }
	    
		
		{LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "trans_config_st"
		LET lr_sup_par_ar.par_ind_especial  = NULL
		LET lr_sup_par_ar.parametro_texto   = EXTEND(CURRENT, HOUR TO SECOND)
		LET lr_sup_par_ar.parametro_val     = "1842"
		LET lr_sup_par_ar.parametro_dat     = TODAY
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF }
	    
		
		{LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "tem_credito_st"
		LET lr_sup_par_ar.par_ind_especial  = "S"
		LET lr_sup_par_ar.parametro_texto   = NULL
		LET lr_sup_par_ar.parametro_val     = NULL
		LET lr_sup_par_ar.parametro_dat     = NULL
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF }
	    
		
		{LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "icms_st_base_piscof"
		LET lr_sup_par_ar.par_ind_especial  = "S"
		LET lr_sup_par_ar.parametro_texto   = NULL
		LET lr_sup_par_ar.parametro_val     = NULL
		LET lr_sup_par_ar.parametro_dat     = TODAY
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF }
	    
		
		{LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "conhec_possui_st"
		LET lr_sup_par_ar.par_ind_especial  = "N"
		LET lr_sup_par_ar.parametro_texto   = NULL
		LET lr_sup_par_ar.parametro_val     = NULL
		LET lr_sup_par_ar.parametro_dat     = TODAY
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF }
	    
		
		{LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "conhec_preco_efetivo"
		LET lr_sup_par_ar.par_ind_especial  = "N"
		LET lr_sup_par_ar.parametro_texto   = NULL
		LET lr_sup_par_ar.parametro_val     = NULL
		LET lr_sup_par_ar.parametro_dat     = TODAY
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF 
	    
		
		LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "cod_municipal_serv"
		LET lr_sup_par_ar.par_ind_especial  = NULL
		LET lr_sup_par_ar.parametro_texto   = NULL
		LET lr_sup_par_ar.parametro_val     = NULL
		LET lr_sup_par_ar.parametro_dat     = NULL
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF 
	    
		
		LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "num_drawback"
		LET lr_sup_par_ar.par_ind_especial  = NULL
		LET lr_sup_par_ar.parametro_texto   = ' '
		LET lr_sup_par_ar.parametro_val     = NULL
		LET lr_sup_par_ar.parametro_dat     = NULL
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF 
	    
		
		LET lr_sup_par_ar.empresa           = p_cod_empresa
		LET lr_sup_par_ar.aviso_recebto     = lr_nf_sup.num_aviso_rec
		LET lr_sup_par_ar.seq_aviso_recebto = lr_aviso_rec.num_seq
		LET lr_sup_par_ar.parametro         = "mat_aplicado_fornec"
		LET lr_sup_par_ar.par_ind_especial  = "N"
		LET lr_sup_par_ar.parametro_texto   = NULL
		LET lr_sup_par_ar.parametro_val     = NULL
		LET lr_sup_par_ar.parametro_dat     = NULL
		INSERT INTO sup_par_ar VALUES(lr_sup_par_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF 
	    
		
		LET lr_ar_subst_tribut.cod_empresa       = p_cod_empresa
		LET lr_ar_subst_tribut.cod_empresa_estab = NULL
		LET lr_ar_subst_tribut.num_aviso_rec     = lr_nf_sup.num_aviso_rec
		LET lr_ar_subst_tribut.num_seq           = lr_aviso_rec.num_seq
		LET lr_ar_subst_tribut.ies_tipo_icms     = 'R'
		LET lr_ar_subst_tribut.pct_agregado      = 0 ## SUP3760 RECALCULA
		LET lr_ar_subst_tribut.val_base_calc_st  = 0 ## SUP3760 RECALCULA
		LET lr_ar_subst_tribut.val_icms_st       = 0 ## SUP3760 RECALCULA
		LET lr_ar_subst_tribut.val_icms_dev_ret  = 0 ## SUP3760 RECALCULA
		INSERT INTO ar_subst_tribut (cod_empresa
									,cod_empresa_estab
									,num_aviso_rec
									,num_seq
									,ies_tipo_icms
									,pct_agregado
									,val_base_calc_st
									,val_icms_st
									,val_icms_dev_ret)
							VALUES (lr_ar_subst_tribut.cod_empresa
									,lr_ar_subst_tribut.cod_empresa_estab
									,lr_ar_subst_tribut.num_aviso_rec
									,lr_ar_subst_tribut.num_seq
									,lr_ar_subst_tribut.ies_tipo_icms
									,lr_ar_subst_tribut.pct_agregado
									,lr_ar_subst_tribut.val_base_calc_st
									,lr_ar_subst_tribut.val_icms_st
									,lr_ar_subst_tribut.val_icms_dev_ret)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF }
	    
		
		LET lr_aviso_rec_compl_sq.cod_empresa       = p_cod_empresa
		LET lr_aviso_rec_compl_sq.cod_empresa_estab = NULL
		LET lr_aviso_rec_compl_sq.num_aviso_rec     = lr_nf_sup.num_aviso_rec
		LET lr_aviso_rec_compl_sq.num_seq           = lr_aviso_rec.num_seq
		LET lr_aviso_rec_compl_sq.cod_fiscal_compl  = 0
		LET lr_aviso_rec_compl_sq.val_base_d_ipi_it = 0
		LET lr_aviso_rec_compl_sq.dat_ini_garantia  = NULL
		LET lr_aviso_rec_compl_sq.dat_fim_garantia  = NULL
		INSERT INTO aviso_rec_compl_sq VALUES (lr_aviso_rec_compl_sq.*) 
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF 
	    
		
		LET lr_dest_aviso_rec.cod_empresa        = p_cod_empresa
		LET lr_dest_aviso_rec.num_aviso_rec      = lr_nf_sup.num_aviso_rec
		LET lr_dest_aviso_rec.num_seq            = lr_aviso_rec.num_seq
		LET lr_dest_aviso_rec.sequencia          = 1
		LET lr_dest_aviso_rec.cod_area_negocio   = 0
		LET lr_dest_aviso_rec.cod_lin_negocio    = 0
		LET lr_dest_aviso_rec.pct_particip_comp  = 100
		LET lr_dest_aviso_rec.num_conta_deb_desp = '10000104'
		LET lr_dest_aviso_rec.cod_secao_receb    = ' '
		LET lr_dest_aviso_rec.qtd_recebida       = 0
		LET lr_dest_aviso_rec.ies_contagem       = 'N'
		LET lr_dest_aviso_rec.num_docum          = NULL
		INSERT INTO dest_aviso_rec VALUES (lr_dest_aviso_rec.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF 
	    
	    #adolar
	     WHENEVER ERROR CONTINUE
         SELECT par_txt
           INTO l_modelo_nf
           FROM par_sup_pad
          WHERE par_sup_pad.cod_empresa   = p_cod_empresa
            AND par_sup_pad.cod_parametro = "modelo_nf"
         WHENEVER ERROR STOP
         IF sqlca.sqlcode <> 0 THEN
            LET l_modelo_nf = "  "
         END IF
         
         LET l_reservado[05,06] = l_modelo_nf
         
	    WHENEVER ERROR CONTINUE
        SELECT reservado
          INTO l_reservado
          FROM sup_compl_nf_sup
         WHERE sup_compl_nf_sup.empresa       = p_cod_empresa
           AND sup_compl_nf_sup.aviso_recebto = lr_nf_sup.num_aviso_rec
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = NOTFOUND THEN
        
            
           INSERT INTO sup_compl_nf_sup VALUES (p_cod_empresa,
                                                lr_nf_sup.num_aviso_rec,
                                                l_reservado)
           
        ELSE 
             
           UPDATE sup_compl_nf_sup
              SET sup_compl_nf_sup.reservado = l_reservado
            WHERE sup_compl_nf_sup.empresa       = p_cod_empresa
              AND sup_compl_nf_sup.aviso_recebto = lr_nf_sup.num_aviso_rec
         
          
        END IF
	    #fim adolar
		
		LET lr_audit_ar.cod_empresa        = p_cod_empresa
		LET lr_audit_ar.num_aviso_rec      = lr_nf_sup.num_aviso_rec
		LET lr_audit_ar.num_seq            = lr_aviso_rec.num_seq
		LET lr_audit_ar.nom_usuario        = p_user
		LET lr_audit_ar.dat_hor_proces     = CURRENT
		LET lr_audit_ar.num_prog           = 'GEO1014'
		LET lr_audit_ar.ies_tipo_auditoria = '1'
		INSERT INTO audit_ar VALUES (lr_audit_ar.*)
		IF sqlca.sqlcode <> 0 THEN
	    	CALL log085_transacao("ROLLBACK")
	    	RETURN FALSE
	    END IF 
	    
	    {LET lr_SUP_RELC_FTRE_INDT.EMPRESA = p_cod_empresa
	    LET lr_SUP_RELC_FTRE_INDT.AVISO_RECEBTO = lr_nf_sup.num_aviso_rec
	    LET lr_SUP_RELC_FTRE_INDT.SEQ_AVISO_RECEBTO = lr_aviso_rec.num_seq
	    
	    SELECT b.pedido,
	           b.seq_item_pedido,
	           a.cliente,
	           c.representante,
	           b.item,
			   b.seq_item_nf,
			   a.dat_hor_emissao
	      INTO lr_SUP_RELC_FTRE_INDT.PED_NF_FATURA,
	           lr_SUP_RELC_FTRE_INDT.SEQ_NF_FATURA,
	           lr_SUP_RELC_FTRE_INDT.CLIENTE,
	           lr_SUP_RELC_FTRE_INDT.REPRESENTANTE,
	           lr_SUP_RELC_FTRE_INDT.ITEM,
	           lr_SUP_RELC_FTRE_INDT.SEQ_ITEM_NOTA_FISCAL_FATURA,
	           lr_SUP_RELC_FTRE_INDT.DAT_HR_EMIS_NOTA_FISCAL_FATURA
	      FROM fat_nf_mestre a, fat_nf_item b, fat_nf_repr c
	     WHERE a.empresa = b.empresa
	       AND a.empresa = c.empresa
	       AND a.trans_nota_fiscal = b.trans_nota_fiscal
	       AND a.trans_nota_fiscal = c.trans_nota_fiscal
	       AND a.sit_nota_fiscal = "N"
	       AND a.trans_nota_fiscal = lr_remessa_movto.trans_remessa
	       AND a.empresa = p_cod_empresa
	       AND b.item = lr_aviso_rec.cod_item
	    
		LET lr_SUP_RELC_FTRE_INDT.NOTA_FISCAL_FATURA = lr_remessa_movto.num_remessa
		LET lr_SUP_RELC_FTRE_INDT.SER_NF_FATURA = lr_remessa_movto.ser_remessa
		LET lr_SUP_RELC_FTRE_INDT.ORD_MONTAG = 0
		LET lr_SUP_RELC_FTRE_INDT.DAT_LANCTO = TODAY
		LET lr_SUP_RELC_FTRE_INDT.MOTIVO_DEVOLUCAO = 0
		LET lr_SUP_RELC_FTRE_INDT.QTD_ITEM = lr_aviso_rec.qtd_declarad_nf
		LET lr_SUP_RELC_FTRE_INDT.PRECO_UNIT_ITEM = 0
		LET lr_SUP_RELC_FTRE_INDT.TRANS_NOTA_FISCAL_FATURA = lr_remessa_movto.trans_remessa 
		LET lr_SUP_RELC_FTRE_INDT.SUBSERIE_NOTA_FISCAL_FATURA = 0
			    
	    
	    INSERT INTO SUP_RELC_FTRE_INDT VALUES (lr_SUP_RELC_FTRE_INDT.*)
	    
	    LET lr_SUP_PAR_DEVOL_CLI.EMPRESA                        = p_cod_empresa
		LET lr_SUP_PAR_DEVOL_CLI.AVISO_RECEBTO                  = lr_nf_sup.num_aviso_rec
		LET lr_SUP_PAR_DEVOL_CLI.SEQ_AVISO_RECEBTO              = lr_aviso_rec.num_seq
		LET lr_SUP_PAR_DEVOL_CLI.NOTA_FISCAL_FATURA             = lr_SUP_RELC_FTRE_INDT.NOTA_FISCAL_FATURA
		LET lr_SUP_PAR_DEVOL_CLI.SER_NF_FATURA                  = lr_SUP_RELC_FTRE_INDT.SER_NF_FATURA
		LET lr_SUP_PAR_DEVOL_CLI.PED_NF_FATURA                  = lr_SUP_RELC_FTRE_INDT.PED_NF_FATURA
		LET lr_SUP_PAR_DEVOL_CLI.SEQ_NF_FATURA                  = lr_SUP_RELC_FTRE_INDT.SEQ_NF_FATURA
		LET lr_SUP_PAR_DEVOL_CLI.ORD_MONTAG                     = 0
		LET lr_SUP_PAR_DEVOL_CLI.PARAMETRO                      = 'dat_envio_hist_nfr'
		LET lr_SUP_PAR_DEVOL_CLI.DES_PARAMETRO                  = 'Data de envio da NF de saida para historico - SUP5242'
		LET lr_SUP_PAR_DEVOL_CLI.PARAMETRO_DAT                  = NULL
		LET lr_SUP_PAR_DEVOL_CLI.TRANS_NOTA_FISCAL_FATURA       = lr_SUP_RELC_FTRE_INDT.TRANS_NOTA_FISCAL_FATURA
		LET lr_SUP_PAR_DEVOL_CLI.SEQ_ITEM_NOTA_FISCAL_FATURA    = lr_SUP_RELC_FTRE_INDT.SEQ_ITEM_NOTA_FISCAL_FATURA
		LET lr_SUP_PAR_DEVOL_CLI.SUBSERIE_NOTA_FISCAL_FATURA    = 0
		LET lr_SUP_PAR_DEVOL_CLI.DAT_HR_EMIS_NOTA_FISCAL_FATURA = lr_SUP_RELC_FTRE_INDT.DAT_HR_EMIS_NOTA_FISCAL_FATURA
	           
		INSERT INTO SUP_PAR_DEVOL_CLI VALUES (lr_SUP_PAR_DEVOL_CLI.*)}
		
		
		LET l_ind = l_ind + 1
	END FOREACH
	
	SELECT DISTINCT trans_remessa
	  INTO l_trans_remessa
	  FROM geo_remessa_movto
	 WHERE cod_empresa = p_cod_empresa
	   AND cod_manifesto = mr_tela.cod_manifesto
	   AND tipo_movto = "R"
	
	SELECT a.nota_fiscal,
	       a.serie_nota_fiscal,
	       DATE(a.dat_hor_emissao)
      INTO l_nota,
           l_serie,
           l_emis
      FROM fat_nf_mestre a
     WHERE a.sit_nota_fiscal = "N"
       AND a.trans_nota_fiscal = l_trans_remessa
       AND a.empresa = p_cod_empresa
	
	LET lr_nfe_sup_compl.cod_empresa      = p_cod_empresa
	LET lr_nfe_sup_compl.num_aviso_rec    = lr_nf_sup.num_aviso_rec
	LET lr_nfe_sup_compl.den_embal        = ' '
	LET lr_nfe_sup_compl.qtd_volumes      = 0
	LET lr_nfe_sup_compl.peso_bruto       = 0
	LET lr_nfe_sup_compl.peso_liquido     = 0
	LET lr_nfe_sup_compl.ies_proc_nfs     = '2'
	LET lr_nfe_sup_compl.num_proc_imp_nfs = NULL
	LET lr_nfe_sup_compl.texto_obs1       = 0
	LET lr_nfe_sup_compl.texto_obs2       = 0
	LET lr_nfe_sup_compl.texto_compl1     = "REFERENTE NF ",l_nota CLIPPED," SERIE ",l_serie CLIPPED," EMISSAO ",l_emis CLIPPED
	LET lr_nfe_sup_compl.texto_compl2     = ' '
	LET lr_nfe_sup_compl.ies_nfe_emit     = 'N'
	INSERT INTO nfe_sup_compl VALUES (lr_nfe_sup_compl.*)
	IF sqlca.sqlcode <> 0 THEN
    	CALL log085_transacao("ROLLBACK")
    	RETURN FALSE
    END IF 
	
	UPDATE nf_sup
       SET val_tot_icms_nf_d = (SELECT SUM(val_icms_item_d) FROM aviso_rec WHERE cod_empresa = p_cod_empresa AND num_aviso_rec = lr_nf_sup.num_aviso_rec)
     WHERE cod_empresa = p_cod_empresa
       AND num_aviso_rec = lr_nf_sup.num_aviso_rec
    
    UPDATE aviso_rec
       SET pct_icms_item_d = 0
         , pct_red_bc_item_d = 0
         , val_base_c_item_d = 0
         , val_icms_item_d = 0
         , val_ipi_decl_item = 0
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = lr_nf_sup.num_aviso_rec
		
    DELETE 
      FROM geo_manifesto_ar 
     WHERE cod_empresa = p_cod_empresa 
       AND cod_manifesto = mr_tela.cod_manifesto
    
    INSERT INTO geo_manifesto_ar VALUES (p_cod_empresa, mr_tela.cod_manifesto, lr_nf_sup.num_aviso_rec)
    
    LET mr_tela.num_aviso_rec = lr_nf_sup.num_aviso_rec
    
	CALL log085_transacao("COMMIT")
	
    CALL _ADVPL_message_box("Processamento concluido com sucesso")
	RETURN TRUE
END FUNCTION

#---------------------------#
FUNCTION geo1014_baixa_titulos_que_deveriam_estar_baixados()
#---------------------------#
   DEFINE l_cod_titulo          CHAR(14)
   DEFINE l_data_movto          date
   
   DECLARE cq_baixa_titulos_q_deveriam_estar_baixados CURSOR WITH HOLD FOR          
   SELECT DISTINCT b.cod_titulo, b.data_movto
	 FROM docum a, geo_acerto b, geo_manifesto c
	WHERE a.ies_situa_docum = 'N'
	  AND a.ies_pgto_docum = 'A'
	  AND a.num_docum = b.cod_titulo 
	  AND a.cod_empresa = b.cod_empresa
	  AND a.cod_empresa = c.cod_empresa
	  AND b.cod_manifesto = c.cod_manifesto
	  AND c.sit_manifesto = 'E'
    ORDER BY b.data_movto DESC
    
   FOREACH cq_baixa_titulos_q_deveriam_estar_baixados INTO l_cod_titulo, l_data_movto
   
      ### BAIXA OS TITULOS NO CRE
      IF NOT geo1014_baixa_titulos_cre22222(l_cod_titulo, l_data_movto) THEN
         #RETURN FALSE
      END IF
      
   END FOREACH 
   
   CALL _ADVPL_message_box("Processamento finalizado com sucesso")
   RETURN TRUE
END FUNCTION

#----------------------------------------------#
FUNCTION geo1014_baixa_titulos_cre22222(l_num_docum, l_data_movto)
#----------------------------------------------#
   DEFINE l_num_docum           LIKE docum.num_docum
   DEFINE l_data_movto          date
   DEFINE l_parametro           CHAR(99)
   DEFINE l_status              SMALLINT
   
   DEFINE lr_tela               RECORD
          cod_empresa                  LIKE adocum_pgto.cod_empresa     ,
          num_docum                    LIKE docum.num_docum             ,
          ies_tip_docum                LIKE docum.ies_tip_docum         ,
          ies_tip_pgto                 LIKE docum_pgto.ies_tip_pgto     ,
          ies_forma_pgto               LIKE docum_pgto.ies_forma_pgto   ,
          cod_portador                 LIKE docum.cod_portador          ,
          ies_tip_portador             LIKE docum.ies_tip_portador      ,
          dat_pgto                     LIKE docum_pgto.dat_pgto         ,
          dat_credito                  LIKE docum_pgto.dat_credito      ,
          val_saldo                    LIKE docum.val_saldo             ,
          val_desc_conc                LIKE docum_pgto.val_desc_conc    ,
          val_juro_pago                LIKE docum_pgto.val_juro_pago    ,
          ies_abono_juros              CHAR(01)                         ,
          val_desp_cartorio            LIKE docum_pgto.val_desp_cartorio,
          val_despesas                 LIKE docum_pgto.val_despesas     ,
          val_multa                    DECIMAL(15,2)                    ,
          val_glosa                    DECIMAL(15,2)
                                END RECORD
                                
   LET lr_tela.cod_empresa       = p_cod_empresa
   LET lr_tela.num_docum         = l_num_docum
   
   SELECT ies_tip_docum, val_saldo
     INTO lr_tela.ies_tip_docum, lr_tela.val_saldo
     FROM docum
    WHERE cod_empresa = p_cod_empresa
      AND num_docum = l_num_docum
   
   
   LET lr_tela.ies_tip_pgto      = "N"
   
   CALL log2250_busca_parametro(p_cod_empresa,'geo_forma_bx_din')
   RETURNING l_parametro, l_status
   IF l_parametro IS NULL OR l_parametro = " " THEN
      LET l_parametro = "CX"
   END IF 
   LET lr_tela.ies_forma_pgto    = l_parametro CLIPPED
   
   CALL log2250_busca_parametro(p_cod_empresa,'geo_port_bx_din')
   RETURNING l_parametro, l_status
   IF l_parametro IS NULL OR l_parametro = " " THEN
      LET l_parametro = "900"
   END IF 
   LET lr_tela.cod_portador      = l_parametro CLIPPED
   
   CALL log2250_busca_parametro(p_cod_empresa,'geo_tip_port_bx_din')
   RETURNING l_parametro, l_status
   IF l_parametro IS NULL OR l_parametro = " " THEN
      LET l_parametro = "C"
   END IF 
   LET lr_tela.ies_tip_portador  = l_parametro CLIPPED
   
   LET lr_tela.dat_pgto          = l_data_movto
   LET lr_tela.dat_credito       = l_data_movto
   
   LET lr_tela.val_desc_conc     = 0
   LET lr_tela.val_juro_pago     = 0
   LET lr_tela.ies_abono_juros   = "N"
   LET lr_tela.val_desp_cartorio = 0
   LET lr_tela.val_despesas      = 0
   LET lr_tela.val_multa         = 0
   LET lr_tela.val_glosa         = 0
   
   IF geo1017_controle(lr_tela) THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF 
       
END FUNCTION

#-------------------------------#
FUNCTION geo1014_saldo_cc_real()
#-------------------------------#
	DEFINE l_diferencas DECIMAL(15,2)
	DEFINE l_saldo_inicial DECIMAL(15,2)
	DEFINE l_cod_repres like representante.cod_repres
	
	SELECT saldo_inicial, cod_repres
	  INTO l_saldo_inicial, l_cod_repres
	  FROM geo_repres_paramet
	 WHERE cod_cliente = mr_tela.cod_resp
	
	IF l_saldo_inicial IS NULL THEN
		LET l_saldo_inicial= 0
	END IF
	
	SELECT SUM(diferenca)
	  INTO l_diferencas 
	  FROM vw_saldos_cc 
	 WHERE cod_vendedor = l_cod_repres
	   AND sit_manifesto = 'E'
	   AND tip_manifesto = 'R'
	
	IF l_diferencas IS NULL THEN
		LET l_diferencas = 0
	END IF
	
	LET mr_tela.saldo_cc = l_diferencas + l_saldo_inicial
	
END FUNCTION

#---------------------------#
FUNCTION geo1014_exec_proc()
#---------------------------#
	DEFINE l_sql CHAR(999)
	
	LET l_sql = "execute geo_proc_fix_movto"
	PREPARE var_proc FROM l_sql
	EXECUTE var_proc
	
END FUNCTION