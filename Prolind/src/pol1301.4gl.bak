#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1301                                                 #
# OBJETIVO: APONTAMENTO DE PRODUÇÃO POR LOTE                        #
# AUTOR...: IVO                                                     #
# DATA....: 06/11/15                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_versao        CHAR(18)

END GLOBALS

DEFINE m_form_aponta     VARCHAR(10),
       m_bar_aponta      VARCHAR(10),
       m_form_pesquisa   VARCHAR(10),
       m_bar_pesquisa    VARCHAR(10),
       m_form_familia    VARCHAR(10),
       m_bar_familia     VARCHAR(10),
       m_form_operac     VARCHAR(10),
       m_bar_operac      VARCHAR(10),
       m_form_item       VARCHAR(10),
       m_bar_item        VARCHAR(10),
       m_form_compl      VARCHAR(10),
       m_bar_compl       VARCHAR(10),
       m_cent_trab       VARCHAR(10),
       m_cod_local       VARCHAR(10),
       m_cod_operac      VARCHAR(10),
       m_datini          VARCHAR(10),
       m_datfim          VARCHAR(10),
       m_dat_pesquisa    VARCHAR(10),
       m_semana          VARCHAR(10),
       m_ordem           VARCHAR(10),
       m_docum           VARCHAR(10),
       m_ies_data        VARCHAR(10),
       m_lupa_cod_local  VARCHAR(10),
       m_lupa_cent_trab  VARCHAR(10),
       m_lupa_operac     VARCHAR(10),
       m_lupa_profis     VARCHAR(10),
       m_zoom_cod_local  VARCHAR(10),
       m_zoom_cent_trab  VARCHAR(10),
       m_zoom_operac     VARCHAR(10),       
       m_zoom_profis     VARCHAR(10),
       m_item            VARCHAR(10),
       m_zoom_item       VARCHAR(10),       
       m_zoom_def_suc    VARCHAR(10),       
       m_zoom_def_ref    VARCHAR(10),       
       m_familia         VARCHAR(10),
       m_zoom_familia    VARCHAR(10),              
       m_browse          VARCHAR(10),
       m_brow_item       VARCHAR(10),
       m_brow_familia    VARCHAR(10),
       m_brow_est_cab    VARCHAR(10),
       m_brow_est_item   VARCHAR(10),
       m_brow_operac     VARCHAR(10),
       m_cod_profis      VARCHAR(10),
       m_form_estorna    VARCHAR(10),
       m_bar_estorna     VARCHAR(10),
       m_lote            VARCHAR(10),
       m_data            VARCHAR(10),
       m_hora            VARCHAR(10),
       m_status          VARCHAR(10),
       m_usuario         VARCHAR(10),
       m_construct       VARCHAR(10),
       m_item_sucata     VARCHAR(10),
       m_lupa_sucata     VARCHAR(10),
       m_cod_mot_refugo  VARCHAR(10),
       m_motivo_refugo   VARCHAR(10),
       m_cod_mot_sucata  VARCHAR(10),
       m_motivo_sucata   VARCHAR(10),
       m_lupa_mot_refugo VARCHAR(10),
       m_lupa_mot_sucata VARCHAR(10),
       m_dat_prod_ini    VARCHAR(10),
       m_hor_prod_ini    VARCHAR(10),
       m_dat_prod_fim    VARCHAR(10),
       m_hor_prod_fim    VARCHAR(10),
       m_cod_turno       VARCHAR(10),
       m_lupa_turno      VARCHAR(10),
       m_zoom_turno      VARCHAR(10),
       m_confirma        VARCHAR(10)

       
DEFINE m_ies_info        SMALLINT,
       m_ies_mod         SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ind             INTEGER,
       m_checa_linha     SMALLINT,
       m_checa_qtds      SMALLINT,
       m_qtd_linha       INTEGER,
       m_qtd_processo    INTEGER,
       m_cod_item_pai    CHAR(15),
       m_ies_proces      SMALLINT,
       m_num_lote        INTEGER,
       m_num_ordem       INTEGER,
       m_cod_item        CHAR(15),
       m_qtd_oper        INTEGER,
       m_ies_apont       CHAR(01),
       m_apontar         SMALLINT,
       m_periodo         SMALLINT,
       m_refugo          SMALLINT,
       m_sucata          SMALLINT,
       m_clik_cab        SMALLINT,
       m_row_estorno     SMALLINT,
       m_estornar        SMALLINT,
       m_criticou        SMALLINT,
       m_qtd_erro        INTEGER

DEFINE m_saldo          LIKE ord_oper.qtd_boas,
       m_qtd_apont      LIKE ord_oper.qtd_boas,
       m_den_item       LIKE item.den_item,
       m_den_familia    LIKE familia.den_familia

DEFINE mr_dados         RECORD LIKE pol1301_1054.*

DEFINE mr_cabec         RECORD LIKE lote_pol1301.*,
       mr_cabeca        RECORD LIKE lote_pol1301.*
       
#ARRAY que armazenará os dados da grade

DEFINE ma_ordem     ARRAY[5000] OF RECORD
       cod_empresa       CHAR(02),      
       usuario           char(08),  
       ano               CHAR(04),
       mes               CHAR(02),
       semana            DECIMAL(2,0),
       comp              CHAR (30),
       larg              CHAR (30),
       esp               CHAR (30),
       peso              CHAR (30),
       m2                CHAR (30),
	     num_pedido        CHAR (10),
	     num_orc           CHAR (13),
	     pos               CHAR (6),
       cod_item          CHAR(15),
       den_item          CHAR(18),
       num_ordem         DECIMAL(9,0),
       num_docum         CHAR(10),
       cod_local         CHAR(10),
       qtd_planejada     DECIMAL(6,0),
       qtd_saldo         DECIMAL(6,0),
       data              DATE,
	     ies_selecionar    CHAR(01),
	     filler            CHAR(1)       
END RECORD

DEFINE mr_parametro      RECORD
       cod_local         CHAR(10),
       den_local         CHAR(30),
       cod_cent_trab     CHAR(05),
       den_cent_trab     CHAR(30),
       cod_operac        CHAR(05),
       den_operac        CHAR(30),
       num_ordem         DECIMAL(9,0),
       num_docum         CHAR(10),
       num_semana        DECIMAL(2,0),
       dat_pesquisa      CHAR(01),
       dat_ini           DATE,
       dat_fim           DATE,
       ies_familia       CHAR(01),
       ies_item          CHAR(01),
       cod_profis        CHAR(15),
       nom_profis        CHAR(40),
       cod_item_sucata   CHAR(15),
       den_item_sucata   CHAR(50),
       cod_mot_refugo    LIKE defeito.cod_defeito,
       den_mot_refugo    CHAR(40),
       cod_mot_sucata    LIKE defeito.cod_defeito,
       den_mot_sucata    CHAR(40),
       dat_prod_ini      DATE,
       hor_prod_ini      CHAR(05),
       dat_prod_fim      DATE,
       hor_prod_fim      CHAR(05),
       cod_turno         INTEGER,
       den_turno         CHAR(25)
END RECORD

DEFINE ma_item           ARRAY[50] OF RECORD
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item
END RECORD

DEFINE ma_familia        ARRAY[50] OF RECORD
       cod_familia       LIKE familia.cod_familia,
       den_familia       LIKE familia.den_familia
END RECORD

DEFINE ma_operacao     ARRAY[5000] OF RECORD
       num_ordem         DECIMAL(9,0),
       cod_item          CHAR(15),
       cod_operac        CHAR(05),
       num_seq_operac    DECIMAL(3,0),
       qtd_planejada     DECIMAL(6,0),
       qtd_saldo         DECIMAL(6,0),
       qtd_boas          DECIMAL(6,0),
       qtd_refugo        DECIMAL(6,0),
       qtd_sucata        DECIMAL(6,0),
       ies_finaliza      CHAR(01),
       oper_anterior     CHAR(05),
       qtd_anterior      DECIMAL(6,0),
       filler            CHAR(01)
END RECORD

DEFINE m_den_defeito     LIKE defeito.den_defeito


#---VARIÁVEIS PARA O APONTAMENTO---------#

DEFINE p_man                      RECORD LIKE man_apont_pol1301.*, 
       p_man_item_produzido       RECORD LIKE  man_item_produzido.*,
       p_estoque_lote_ender       RECORD LIKE estoque_lote_ender.*,
       p_man_comp_consumido       RECORD LIKE man_comp_consumido.*

DEFINE m_num_processo      LIKE processo_apont_pol1301.num_processo,
       m_qtd_planejada     LIKE ord_oper.qtd_planejada,
       m_dat_fecha_ult_man LIKE par_estoque.dat_fecha_ult_man,
       m_dat_fecha_ult_sup LIKE par_estoque.dat_fecha_ult_sup

DEFINE p_dat_inicio         LIKE ord_oper.dat_inicio,
       p_cod_roteiro        LIKE ordens.cod_roteiro,
       p_num_altern_roteiro LIKE ordens.num_altern_roteiro,
       p_cod_operacao       LIKE estoque_trans.cod_operacao,
       p_cod_unid_prod      LIKE cent_trabalho.cod_unid_prod,
       p_num_seq_reg        LIKE cfp_apms.num_seq_registro,
       p_pct_refug          LIKE ord_compon.pct_refug,
       p_cod_compon         LIKE item.cod_item, 
       p_qtd_necessaria     LIKE ord_compon.qtd_necessaria,
       p_cod_local_baixa    LIKE ord_compon.cod_local_baixa,
       p_num_neces          LIKE necessidades.num_neces,
       p_cod_local_estoq    LIKE ord_compon.cod_local_baixa,
       p_cod_local_insp     LIKE ord_compon.cod_local_baixa,
       p_cod_oper_sp        LIKE par_pcp.cod_estoque_sp,        
       p_cod_oper_rp        LIKE par_pcp.cod_estoque_rp,           
       p_cod_oper_sucata    LIKE par_pcp.cod_estoque_rn,   
       p_dat_fecha_ult_man  LIKE par_estoque.dat_fecha_ult_man,    
       p_dat_fecha_ult_sup  LIKE par_estoque.dat_fecha_ult_sup                      

DEFINE p_seq_reg_mestre     INTEGER,
       p_dat_char           CHAR(23),
       p_qtd_prod           DECIMAL(10,3),
       p_qtd_baixar         DECIMAL(10,3),
       p_qtd_sucata         DECIMAL(10,3),
       p_tip_operac         CHAR(01),
       p_ies_ctr_estoque    CHAR(01),
       p_ies_ctr_lote       CHAR(01),
       p_ies_tip_item       CHAR(01),
       p_sofre_baixa        CHAR(01),
       p_ies_situa          CHAR(01),
       p_ies_tem_inspecao   CHAR(01),
       p_cod_tip_apon       CHAR(01),
       p_ies_tip_movto      CHAR(01),
       p_tip_producao       CHAR(01),
       p_num_seq_apont      INTEGER,
       p_cod_item           CHAR(15),
       p_dat_movto          DATE,
       p_qtd_movto          DECIMAL(10,3),
       p_num_lote           CHAR(15),
       p_largura            INTEGER,
       p_altura             INTEGER,
       p_diametro           INTEGER,
       p_comprimento        INTEGER,
		   p_qtd_saldo          DECIMAL(10,3),
		   p_trans_ender        INTEGER,
       p_qtd_reservada      DECIMAL(10,3),
       p_trans_lote         INTEGER,
       p_qtd_estorno        DECIMAL(10,3),
       p_qtd_ordem          DECIMAL(10,3),
       p_ies_operacao       CHAR(01),
       p_qtd_apont          DECIMAL(10,3),
       p_seq_txt            CHAR(15),
       p_qtd_oper           DECIMAL(10,3)

       
DEFINE m_dat_atu         DATE,
       m_hor_atu         CHAR(08),
       p_criticou        SMALLINT,
       m_dat_processo    CHAR(20),
       m_index           INTEGER,
       m_dat_geracao     DATE,
       m_hor_geracao     CHAR(08)

   DEFINE p_msg                CHAR(250),
          p_num_trans_atual    INTEGER,
          p_transac_apont      INTEGER,
          p_transac_pai        INTEGER
   
  DEFINE p_movto       RECORD
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01)
  END RECORD

#--variáveis modular de uso geral--#
  
  DEFINE p_num_transac      INTEGER,
         p_num_trans_ant    INTEGER,
         p_erro             CHAR(10),
         p_ies_estoque      CHAR(01)
         
  DEFINE p_estoque_trans      RECORD LIKE estoque_trans.*,
         p_estoque_trans_end  RECORD LIKE estoque_trans_end.*

DEFINE ma_est_cabec      ARRAY[1000] OF RECORD
       num_lote          INTEGER,
       num_processo      INTEGER,
       dat_processo      DATE,     
       hor_processo      CHAR(08),   
       ies_estornar      CHAR(01),
       usuario           CHAR(08),
       filler            CHAR(01)
END RECORD

DEFINE ma_est_item      ARRAY[1000] OF RECORD
       num_ordem         INTEGER,
       cod_item          CHAR(15),
       cod_cent_trab     CHAR(05),     
       cod_operac        CHAR(05),   
       num_seq_operac    DECIMAL(3,0),
       qtd_boas          DECIMAL(6,0),
       qtd_refugo        DECIMAL(6,0),
       qtd_sucata        DECIMAL(6,0),
       ies_finaliza      CHAR(01),
       filler            CHAR(01)
END RECORD

DEFINE mr_erro_est       ARRAY[100] OF RECORD
       den_erro          CHAR(80)
END RECORD

#-----------------#
FUNCTION pol1301()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1301-12.00.09  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1301_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1301_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_pesquisa    VARCHAR(10),
           l_inclui      VARCHAR(10),
           l_modifica    VARCHAR(10),
           l_proces      VARCHAR(10),
           l_estorno     VARCHAR(10),
           l_delete      VARCHAR(10),
           l_previous    VARCHAR(10),
           l_next        VARCHAR(10)
    
    CALL pol1301_limpa_campos()
    INITIALIZE ma_ordem TO NULL
    INITIALIZE ma_estorno  TO NULL

    LET m_ies_info = FALSE
    LET m_ies_mod = FALSE

       #Criação da janela do programa
    LET m_form_aponta = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_aponta,"SIZE",640,480)
    CALL _ADVPL_set_property(m_form_aponta,"TITLE","APONTAMENTO POR LOTE")

       #Criação da barra de status
    LET m_bar_aponta = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_aponta)

       #Criação da barra de menu
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_aponta)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

       #Criação do botão informar
    LET l_pesquisa = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_pesquisa,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_pesquisa,"EVENT","pol1301_pesquisar")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1301_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1301_next")

   #FIND_EX / QUIT_EX / CONFIRM_EX / UPDATE_EX / RUN_EX / NEW_EX
   #CANCEL_EX / DELETE_EX / LANCAMENTOS_EX / ESTORNO_EX / SAVEPROFILE
   LET l_inclui = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_inclui,"IMAGE","NEW_EX")     
   CALL _ADVPL_set_property(l_inclui,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_inclui,"EVENT","pol1301_incluir")     

    LET l_modifica = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_modifica,"EVENT","pol1301_modifica")
    CALL _ADVPL_set_property(l_modifica,"CONFIRM_EVENT","pol1301_conf_mod")
    CALL _ADVPL_set_property(l_modifica,"CANCEL_EVENT","pol1301_canc_mod")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1301_delete")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1301_processar")

       #Criação do botão estornar
   LET l_estorno = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_estorno,"IMAGE","ESTORNO_EX")     
   CALL _ADVPL_set_property(l_estorno,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_estorno,"EVENT","pol1301_estornar")        

       #Criação do botão sair
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_aponta)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) #vermelho,verde,azul

    CALL pol1301_cria_detalhe(l_panel)
    CALL pol1301_cria_cabec(l_panel)

    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_form_aponta,"ACTIVATE",TRUE)
       
       #Exibe a janela do programa
    CALL _ADVPL_set_property(m_form_aponta,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1301_limpa_campos()
#-----------------------------#

   INITIALIZE mr_parametro.* TO NULL
   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_item TO NULL
   INITIALIZE ma_familia TO NULL
       
END FUNCTION

#---------------------------------------#
FUNCTION pol1301_cria_cabec(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10)
    
    #criação de painel no topo para os campos de pesquisa
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",40)
    
    #http://tdn.totvs.com/display/public/lg/LLayoutManager;jsessionid=0FE4A7070C40A67B07EB4E2DC73F1009
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",10)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Lote:")    
    LET m_lote = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_lote,"LENGTH",10)
    CALL _ADVPL_set_property(m_lote,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_lote,"VARIABLE",mr_cabec,"num_lote")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","   Geração:")    
    LET m_data = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    #CALL _ADVPL_set_property(m_data,"LENGTH",10)
    CALL _ADVPL_set_property(m_data,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_data,"VARIABLE",mr_cabec,"dat_geracao")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","   Às:")    
    LET m_hora = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_hora,"LENGTH",08)
    CALL _ADVPL_set_property(m_hora,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_hora,"VARIABLE",mr_cabec,"hor_geracao")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","   Status:")    
    LET m_status = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_status,"LENGTH",1)
    CALL _ADVPL_set_property(m_status,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_status,"VARIABLE",mr_cabec,"cod_status")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","   Usuário:")    
    LET m_usuario = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_usuario,"LENGTH",8)
    CALL _ADVPL_set_property(m_usuario,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_usuario,"VARIABLE",mr_cabec,"usuario")

END FUNCTION

#-----------------------------------------#
FUNCTION pol1301_cria_detalhe(l_container)#
#-----------------------------------------#

    DEFINE l_container           VARCHAR(10),
           l_panel               VARCHAR(10),
           l_layout              VARCHAR(10),
           l_label               VARCHAR(10),
           l_field               VARCHAR(10),
           l_tabcolumn           VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    
    CALL _ADVPL_set_property(m_browse,"AFTER_ROW_EVENT","pol1301_checa_linha")
    
    # colunas da grade

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sel")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_selecionar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
          # UNCHECKED / CHECKED
    #CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CHECKED")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER_CLICK_EVENT","pol1301_marca_desmarca")


    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ordem")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Documento")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_docum")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Local")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_local")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Planejada")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",55)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_planejada")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_saldo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ano")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ano")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mês")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mes")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Semana")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","semana")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Esp")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","esp")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Comp")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","comp")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Larg")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","larg")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Peso")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","peso")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","M2")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","m2")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_pedido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Orçamento")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_orc")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pos")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pos")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
        
    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_ordem,1)
        
END FUNCTION

#--------------------------------#
FUNCTION pol1301_marca_desmarca()#
#--------------------------------#
   
   DEFINE l_ind       INTEGER,
          l_sel       CHAR(01)
   
   LET m_clik_cab = NOT m_clik_cab
   
   IF m_clik_cab THEN
      LET l_sel = 'S'
   ELSE
      LET l_sel = 'N'
   END IF
   
   FOR l_ind = 1 TO m_qtd_linha
       CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","ies_selecionar",l_ind,l_sel)
   END FOR
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1301_pesquisar()#
#---------------------------#   

    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","PESQUISA DE LOTES")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","lote_item_pol1301","Lotes")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","lote_item_pol1301","num_lote","Num lote",1 {INT},10,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","lote_item_pol1301","dat_geracao","Dat geração",1 {DATE},10,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","lote_item_pol1301","semana","Semana",1 {INT},2,0)        	
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","lote_item_pol1301","comp","Comprimento",1 {CHAR},30,0)        	
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","lote_item_pol1301","larg","Largura",1 {CHAR},30,0)        	
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","lote_item_pol1301","esp","Espessura",1 {CHAR},30,0)        	
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","lote_item_pol1301","num_pedido","Pedido",1 {CHAR},10,0)        	
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","lote_item_pol1301","num_orc","Orçamento",1 {CHAR},13,0)        	
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","lote_item_pol1301","pos","Posição",1 {CHAR},6,0)        	
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","lote_item_pol1301","cod_item","Produto",1 {CHAR},15,0)        	
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","lote_item_pol1301","num_ordem","Ordem",1 {INT},10,0)        	
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","lote_item_pol1301","num_docum","Documento",1 {CHAR},15,0)        	
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","lote_item_pol1301","cod_local","Local",1 {CHAR},10,0)        	
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF  l_status THEN
        LET l_where_clause = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_construct,"ORDER_BY")
        CALL pol1301_cria_cursor(l_where_clause,l_order_by)
    ELSE
        CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#------------------------------------------------------#
FUNCTION pol1301_cria_cursor(l_where_clause,l_order_by)#
#------------------------------------------------------#
 
    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)

    DEFINE l_sql_stmt     CHAR(2000)

    IF  l_order_by IS NULL THEN
        LET l_order_by = "3"
    END IF

    LET l_sql_stmt = "SELECT DISTINCT lote_pol1301.* ",
                      " FROM lote_item_pol1301, lote_pol1301  ",
                     " WHERE ", l_where_clause CLIPPED,
                     "   AND lote_item_pol1301.cod_empresa = '",p_cod_empresa,"' ",
                     "   AND lote_item_pol1301.cod_empresa = lote_pol1301.cod_empresa ",
                     "   AND lote_item_pol1301.num_lote = lote_pol1301.num_lote ",                     
                     " ORDER BY ", l_order_by

    PREPARE var_pesquisa FROM l_sql_stmt
    
    IF  Status <> 0 THEN
        CALL log003_err_sql("PREPARE SQL","var_pesquisa")
        RETURN FALSE
    END IF

    DECLARE cq_pesquisa SCROLL CURSOR WITH HOLD FOR var_pesquisa

    IF  Status <> 0 THEN
        CALL log003_err_sql("DECLARE CURSOR","cq_pesquisa")
        RETURN FALSE
    END IF

    FREE var_pesquisa

    OPEN cq_pesquisa

    IF  STATUS <> 0 THEN
        CALL log003_err_sql("OPEN CURSOR","cq_pesquisa")
        RETURN FALSE
    END IF

    FETCH cq_pesquisa INTO mr_cabec.*

    IF STATUS <> 0 THEN
       IF STATUS <> 100 THEN
          CALL log003_err_sql("FETCH CURSOR","cq_pesquisa")
       ELSE
          LET m_msg = 'Não a dados, para os argumentos informados.'
          CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT",m_msg)
       END IF

       RETURN FALSE
    END IF

    #invoca rotina para leitura dos itens do lote
    
    LET m_num_lote = mr_cabec.num_lote
    CALL pol1301_le_lote() RETURNING p_status

    LET m_msg = 'Pesquisa efetuada com sucesso.'
    CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT",m_msg)
    
    LET m_ies_info = TRUE
    
    RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1301_previous()#
#--------------------------#

   IF NOT pol1301_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1301_next()#
#----------------------#

   IF NOT pol1301_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
FUNCTION pol1301_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1301_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET mr_cabeca.* = mr_cabec.*

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_pesquisa INTO mr_cabec.*
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_pesquisa INTO mr_cabec.*
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_pesquisa INTO mr_cabec.*
         WHEN 'P' 
            FETCH PREVIOUS cq_pesquisa INTO mr_cabec.*
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_conta")
         ELSE
            CALL _ADVPL_set_property(m_bar_aponta,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET mr_cabec.* = mr_cabeca.*
         EXIT WHILE
      ELSE
         SELECT DISTINCT num_lote
           FROM lote_pol1301
          WHERE cod_empresa =  p_cod_empresa
            AND num_lote = mr_cabec.num_lote
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               LET m_num_lote = mr_cabec.num_lote
               CALL pol1301_le_lote() RETURNING p_status
               LET l_achou = TRUE
               EXIT WHILE
            ELSE 
               CALL log003_err_sql("FETCH CURSOR","cq_conta")
               EXIT WHILE
            END IF
         END IF
      END IF               
   
   END WHILE
   
   RETURN l_achou
   
END FUNCTION

#--------------------------#
FUNCTION pol1301_ies_cons()#
#--------------------------#

   IF NOT m_ies_info THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1301_incluir()#
#-------------------------#   

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_confirma    VARCHAR(10),
           l_cancela     VARCHAR(10)
      
   IF NOT pol1301_del_pesquisa() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1301_cria_tabs() THEN
      RETURN FALSE
   END IF
       
    CALL pol1301_limpa_campos()

    LET m_ies_mod = FALSE
    LET m_num_lote = 0
    LET mr_parametro.dat_ini = TODAY - 2500
    LET mr_parametro.dat_fim = TODAY

       #Criação da janela do programa
    LET m_form_pesquisa = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_pesquisa,"SIZE",600,530)
    CALL _ADVPL_set_property(m_form_pesquisa,"TITLE","PARÂMETROS PARA PESQUISA")

       #Criação da barra de status
    LET m_bar_pesquisa = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_pesquisa)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_pesquisa)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   #FIND_EX / QUIT_EX / CONFIRM_EX / UPDATE_EX / RUN_EX / NEW_EX
   #CANCEL_EX / DELETE_EX / LANCAMENTOS_EX / ESTORNO_EX / SAVEPROFILE

   LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
   CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirma,"EVENT","pol1301_conf_inclusao")  

   LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancela,"EVENT","pol1301_canc_inclusao")     

    #criação de um painel em toda area da janela
    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_pesquisa)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    #Chama FUNCTION para criação dos campos
    CALL pol1301_cria_campos(l_panel)

       #Exibe a janela do programa
    CALL _ADVPL_set_property(m_form_pesquisa,"ACTIVATE",TRUE)
    
    CALL log0030_mensagem(m_msg,'info')                       

   RETURN TRUE 
    
END FUNCTION

#------------------------------#
FUNCTION pol1301_del_pesquisa()#
#------------------------------#

   DELETE FROM pol1301_1054 
    WHERE cod_empresa = p_cod_empresa
      AND usuario = p_user

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','pol1301_1054')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1301_cria_tabs()#
#---------------------------#

   DROP TABLE item_pol1301
   
   CREATE TEMP TABLE item_pol1301 (
      cod_item         CHAR(15) 
   );

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","item_pol1301")
			RETURN FALSE
	 END IF

   DROP TABLE familia_pol1301
   
   CREATE TEMP TABLE familia_pol1301 (
      cod_familia    CHAR(05) 
   );

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","familia_pol1301")
			RETURN FALSE
	 END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------------#
FUNCTION pol1301_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_den_local       VARCHAR(10),
           l_den_cent_trab   VARCHAR(10),
           l_den_operac      VARCHAR(10)           

    #criação de um painel central
    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",300)
    
    #criação um LLAYOUT c/ 4 colunas, para distribuiçao dos campos com popup 
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",5)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    #criação do campo para entrada do local de produção
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Local prod:")    

    LET m_cod_local= _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_local,"LENGTH",10)
    CALL _ADVPL_set_property(m_cod_local,"VARIABLE",mr_parametro,"cod_local")
    CALL _ADVPL_set_property(m_cod_local,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_local,"VALID","pol1301_checa_local")

    #criação/definição do icone do zoom do local
    LET m_lupa_cod_local = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_cod_local,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cod_local,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cod_local,"CLICK_EVENT","pol1301_zoom_local")

    #criação/definição do campos para exibir o nome do local
    LET l_den_local = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_den_local,"LENGTH",30) 
    CALL _ADVPL_set_property(l_den_local,"EDITABLE",FALSE) #não permite edição do conteúdo
    CALL _ADVPL_set_property(l_den_local,"VARIABLE",mr_parametro,"den_local")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    #criação do campo para entrada do centro de trabalho
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cent trabalho:")    

    LET m_cent_trab = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cent_trab,"LENGTH",5)
    CALL _ADVPL_set_property(m_cent_trab,"VARIABLE",mr_parametro,"cod_cent_trab")
    CALL _ADVPL_set_property(m_cent_trab,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cent_trab,"VALID","pol1301_checa_cent_traba")

    #criação/definição do icone do zoom do centro de trabalho
    LET m_lupa_cent_trab = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_cent_trab,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cent_trab,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cent_trab,"CLICK_EVENT","pol1301_zoom_cent_trab")

    #criação/definição do campos para exibir o nome do centro de tabalho
    LET l_den_cent_trab = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_den_cent_trab,"LENGTH",30) 
    CALL _ADVPL_set_property(l_den_cent_trab,"EDITABLE",FALSE) #não permite edição do conteúdo
    CALL _ADVPL_set_property(l_den_cent_trab,"VARIABLE",mr_parametro,"den_cent_trab")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    #criação do campo para entrada da operação
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Operação:")    

    LET m_cod_operac = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_operac,"VARIABLE",mr_parametro,"cod_operac")
    CALL _ADVPL_set_property(m_cod_operac,"LENGTH",5)
    CALL _ADVPL_set_property(m_cod_operac,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_operac,"VALID","pol1301_checa_operacao")

    #criação/definição do icone do zoom
    LET m_lupa_operac = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_operac,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_operac,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_operac,"CLICK_EVENT","pol1301_zoom_operacao")

    #criação/definição do campos para exibir o nome da operação
    LET l_den_operac = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_den_operac,"LENGTH",30) 
    CALL _ADVPL_set_property(l_den_operac,"EDITABLE",FALSE) #não permite edição do conteúdo
    CALL _ADVPL_set_property(l_den_operac,"VARIABLE",mr_parametro,"den_operac")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    #criação do campo para entrada do numero do documento
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Documento:")    
    
    LET m_docum = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_docum,"VARIABLE",mr_parametro,"num_docum")
    CALL _ADVPL_set_property(m_docum,"LENGTH",10)
    CALL _ADVPL_set_property(m_docum,"PICTURE","@!")
    CALL _ADVPL_set_property(m_docum,"VALID","pol1301_checa_docum")

    #criação do campo para entrada do numero da ordem
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Ordem:")    
    
    LET m_ordem = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_ordem,"VARIABLE",mr_parametro,"num_ordem")
    CALL _ADVPL_set_property(m_ordem,"LENGTH",9,0)
    CALL _ADVPL_set_property(m_ordem,"PICTURE","@E #########")
    CALL _ADVPL_set_property(m_ordem,"VALID","pol1301_checa_ordem")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    #criação do campo para entrada do numero da semana
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Semana:")
    
    LET m_semana = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_semana,"VARIABLE",mr_parametro,"num_semana")
    CALL _ADVPL_set_property(m_semana,"LENGTH",2,0)
    CALL _ADVPL_set_property(m_semana,"PICTURE","@E ##")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Data de:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_dat_pesquisa = _ADVPL_create_component(NULL,"LCOMBOBOX",l_layout)    
    CALL _ADVPL_set_property(m_dat_pesquisa,"ADD_ITEM","A","Abertura")     
    CALL _ADVPL_set_property(m_dat_pesquisa,"ADD_ITEM","E","Entrega")     
    CALL _ADVPL_set_property(m_dat_pesquisa,"ADD_ITEM","L","Liberação")     
    CALL _ADVPL_set_property(m_dat_pesquisa,"VARIABLE",mr_parametro,"dat_pesquisa")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    #criação do campo para entrada do periodo p/ pesquisa
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Inicial:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_datini = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_datini,"VARIABLE",mr_parametro,"dat_ini")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Final:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_datfim = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_datfim,"VARIABLE",mr_parametro,"dat_fim")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    CALL pol1301_grade_familia(l_container)
    CALL pol1301_grade_item(l_container)

END FUNCTION

#-----------------------------#
FUNCTION pol1301_checa_local()#
#-----------------------------#

   CALL _ADVPL_set_property(m_bar_pesquisa,"CLEAR_TEXT")
   
   INITIALIZE mr_parametro.den_local TO NULL
   
   IF mr_parametro.cod_local IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT den_local
     INTO mr_parametro.den_local
     FROM local
    WHERE cod_empresa = p_cod_empresa
      AND cod_local = mr_parametro.cod_local
   
   IF STATUS = 100 THEN
      CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT",
             "Local inexistente.")
      RETURN FALSE
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','local')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_zoom_local()#
#----------------------------#

    DEFINE l_codigo          LIKE local.cod_local,
           l_descricao       LIKE local.den_local,
           l_where_clause    CHAR(300)
    
    IF  m_zoom_cod_local IS NULL THEN
        LET m_zoom_cod_local = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_cod_local,"ZOOM","zoom_local")
    END IF
 
    # Define a WHERE CLAUSE do zoom.
    LET l_where_clause = " local.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
     
    CALL _ADVPL_get_property(m_zoom_cod_local,"ACTIVATE")
    
    LET l_codigo    = _ADVPL_get_property(m_zoom_cod_local,"RETURN_BY_TABLE_COLUMN","local","cod_local")
    LET l_descricao = _ADVPL_get_property(m_zoom_cod_local,"RETURN_BY_TABLE_COLUMN","local","den_local")

    IF  l_codigo IS NOT NULL THEN
        LET mr_parametro.cod_local = l_codigo
        LET mr_parametro.den_local = l_descricao
    END IF

END FUNCTION

#----------------------------------#
FUNCTION pol1301_checa_cent_traba()#
#----------------------------------#

   CALL _ADVPL_set_property(m_bar_pesquisa,"CLEAR_TEXT")
   
   INITIALIZE mr_parametro.den_cent_trab TO NULL
   
   IF mr_parametro.cod_cent_trab IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT den_cent_trab
     INTO mr_parametro.den_cent_trab
     FROM cent_trabalho
    WHERE cod_empresa = p_cod_empresa
      AND cod_cent_trab = mr_parametro.cod_cent_trab
   
   IF STATUS = 100 THEN
      CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT",
             "Centro de trabalho inexistente.")
      RETURN FALSE
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cent_trabalho')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1301_zoom_cent_trab()#
#--------------------------------#

    DEFINE l_cod_cent_trab       LIKE cent_trabalho.cod_cent_trab,
           l_den_cent_trab       LIKE cent_trabalho.den_cent_trab
    
    IF  m_zoom_cent_trab IS NULL THEN
        LET m_zoom_cent_trab = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_cent_trab,"ZOOM","zoom_cent_trabalho")
    END IF
    
    #exibe a janela do zoom
    CALL _ADVPL_get_property(m_zoom_cent_trab,"ACTIVATE")
    
    #obtém o código e nome do ct da linha atual da grade de zoom
    LET l_cod_cent_trab = _ADVPL_get_property(m_zoom_cent_trab,"RETURN_BY_TABLE_COLUMN","cent_trabalho","cod_cent_trab")
    LET l_den_cent_trab = _ADVPL_get_property(m_zoom_cent_trab,"RETURN_BY_TABLE_COLUMN","cent_trabalho","den_cent_trab")

    IF  l_cod_cent_trab IS NOT NULL THEN
        LET mr_parametro.cod_cent_trab = l_cod_cent_trab
        LET mr_parametro.den_cent_trab = l_den_cent_trab
    END IF

END FUNCTION

#--------------------------------#
FUNCTION pol1301_checa_operacao()#
#--------------------------------#

   CALL _ADVPL_set_property(m_bar_pesquisa,"CLEAR_TEXT")
   
   INITIALIZE mr_parametro.den_operac TO NULL

   IF mr_parametro.cod_operac IS NULL THEN
      RETURN TRUE
   END IF

   SELECT den_operac
     INTO mr_parametro.den_operac
     FROM operacao
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac = mr_parametro.cod_operac
   
   IF STATUS = 100 THEN
      CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT",
             "Operação inexistente.")
      RETURN FALSE
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','operacao')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1301_zoom_operacao()#
#-------------------------------#

    DEFINE l_cod_operac       LIKE operacao.cod_operac,
           l_den_operac       LIKE operacao.den_operac
    
    IF  m_zoom_operac IS NULL THEN
        LET m_zoom_operac = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_operac,"ZOOM","zoom_operacao")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_operac,"ACTIVATE")
    
    LET l_cod_operac = _ADVPL_get_property(m_zoom_operac,"RETURN_BY_TABLE_COLUMN","operacao","cod_operac")
    LET l_den_operac = _ADVPL_get_property(m_zoom_operac,"RETURN_BY_TABLE_COLUMN","operacao","den_operac")

    IF  l_cod_operac IS NOT NULL THEN
        LET mr_parametro.cod_operac = l_cod_operac
        LET mr_parametro.den_operac = l_den_operac
    END IF

END FUNCTION      

#-----------------------------#
FUNCTION pol1301_checa_docum()#
#-----------------------------#

   CALL _ADVPL_set_property(m_bar_pesquisa,"CLEAR_TEXT")
   
   IF mr_parametro.num_docum IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT COUNT(num_docum)   
     INTO m_count
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_docum = mr_parametro.num_docum
      AND ies_situa = '4'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT",
             "Não existem ordens liberadas p/ o documento informado")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1301_checa_ordem()#
#-----------------------------#

   CALL _ADVPL_set_property(m_bar_pesquisa,"CLEAR_TEXT")
   
   IF mr_parametro.num_ordem IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT COUNT(num_docum)   
     INTO m_count
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = mr_parametro.num_ordem
      AND ies_situa = '4'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT",
             "A ordem infromada não existe ou não está liberada")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_checa_profis()#
#------------------------------#

   CALL _ADVPL_set_property(m_bar_compl,"CLEAR_TEXT")
   
   INITIALIZE mr_parametro.nom_profis TO NULL

   IF mr_parametro.cod_profis IS NULL THEN
      CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",
             "Informe o operador.")
      RETURN FALSE
   END IF

   SELECT nom_profis
     INTO mr_parametro.nom_profis
     FROM tx_profissional
    WHERE cod_empresa = p_cod_empresa
      AND cod_profis = mr_parametro.cod_profis
      AND cod_tip_profis = 'F'
   
   IF STATUS = 100 THEN
      CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",
             "Operador inexistente ou não é um funcionário")
      RETURN FALSE
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','tx_profissional')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1301_zoom_profis()#
#-----------------------------#

    DEFINE l_codigo       LIKE tx_profissional.cod_profis,
           l_descricao    LIKE tx_profissional.nom_profis
    
    IF  m_zoom_profis IS NULL THEN
        LET m_zoom_profis = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_profis,"ZOOM","zoom_tx_profissional")
    END IF
    
    #exibe a janela do zoom
    CALL _ADVPL_get_property(m_zoom_profis,"ACTIVATE")
    
    #obtém o código e nome do profissional
    LET l_codigo    = _ADVPL_get_property(m_zoom_profis,"RETURN_BY_TABLE_COLUMN","tx_profissional","cod_profis")
    LET l_descricao = _ADVPL_get_property(m_zoom_profis,"RETURN_BY_TABLE_COLUMN","tx_profissional","nom_profis")

    IF  l_codigo IS NOT NULL THEN
        LET mr_parametro.cod_profis = l_codigo
        LET mr_parametro.nom_profis = l_descricao
    END IF

END FUNCTION

#-------------------------------#
FUNCTION pol1301_conf_inclusao()#
#-------------------------------#

   IF mr_parametro.dat_ini IS NULL THEN
      CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT","Informe a data inicial!")
      CALL _ADVPL_set_property(m_datini,"GET_FOCUS")
      RETURN FALSE      
   END IF

   IF mr_parametro.dat_fim IS NULL THEN
      CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT","Informe a data final!")
      CALL _ADVPL_set_property(m_datfim,"GET_FOCUS")
      RETURN FALSE      
   END IF
   
   IF mr_parametro.dat_fim < mr_parametro.dat_ini THEN
      CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT","Período inválido!")
      CALL _ADVPL_set_property(m_datini,"GET_FOCUS")
      RETURN FALSE      
   END IF

   CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT", "Aguarde! Coletando dados...")           
   
   LET p_status = pol1280_le_ordens()
     
   IF NOT p_status THEN 
      LET m_msg = 'Operação cancelada.'
   ELSE
      LET m_ies_info = TRUE
      LET m_msg = 'Para salvar sua pesquisa em um novo lote,\n',
                  'Clique em Modificar e selecione as ordens.'
   END IF
   
   CALL _ADVPL_set_property(m_form_pesquisa,"ACTIVATE",FALSE)
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1301_canc_inclusao()#
#-------------------------------#

   CALL _ADVPL_set_property(m_form_pesquisa,"ACTIVATE",FALSE)
   
   LET m_msg = 'Operação cancelada.'
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1280_le_ordens()#
#---------------------------#
   
   DEFINE sql_stmt        VARCHAR(5000),
          l_progres       SMALLINT,
          l_dat_abert     DATE,
          l_dat_entrega   DATE, 
          l_dat_liberac   DATE,
          l_ind           INTEGER,
          l_item          SMALLINT,
          l_familia       SMALLINT,
          l_cod_familia   CHAR(05),
          l_count         INTEGER
   
   LET l_item = FALSE
   LET l_familia = FALSE
   
   DELETE FROM item_pol1301
   DELETE FROM familia_pol1301
   
   FOR l_ind = 1 TO 50

       IF ma_item[l_ind].cod_item IS NOT NULL THEN
          INSERT INTO item_pol1301 VALUES(ma_item[l_ind].cod_item)
          LET l_item = TRUE
       END IF

       IF ma_familia[l_ind].cod_familia IS NOT NULL THEN
          INSERT INTO familia_pol1301 VALUES(ma_familia[l_ind].cod_familia)
          LET l_familia = TRUE
       END IF
       
   END FOR

   IF mr_parametro.dat_pesquisa = 'A' THEN
      LET sql_stmt =
       " SELECT num_ordem, cod_item, num_docum, dat_abert, cod_item_pai,  ",
       "   qtd_planej, (qtd_planej-qtd_boas-qtd_refug-qtd_sucata), ",
       "   cod_local_prod,  retsemana(dat_abert) FROM ordens ",
       "  WHERE cod_empresa = '",p_cod_empresa,"' ",
       "    AND ies_situa  = '4' ",
       "    AND qtd_planej > (qtd_boas + qtd_refug + qtd_sucata) ",
       "    AND dat_abert >= '",mr_parametro.dat_ini,"' ",
       "    AND dat_abert <= '",mr_parametro.dat_fim,"' "

      IF mr_parametro.num_semana IS NOT NULL THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND retsemana(dat_abert) = ", mr_parametro.num_semana
      END IF
      
   END IF
   
   IF mr_parametro.dat_pesquisa = 'E' THEN
      LET sql_stmt =
       " SELECT num_ordem, cod_item, num_docum, dat_entrega, cod_item_pai, ",
       "   qtd_planej, (qtd_planej-qtd_boas-qtd_refug-qtd_sucata), ",
       "   cod_local_prod,  retsemana(dat_entrega) FROM ordens ",
       "  WHERE cod_empresa = '",p_cod_empresa,"' ",
       "    AND ies_situa  = '4' ",
       "    AND qtd_planej > (qtd_boas + qtd_refug + qtd_sucata) ",
       "    AND dat_entrega >= '",mr_parametro.dat_ini,"' ",
       "    AND dat_entrega <= '",mr_parametro.dat_fim,"' "

      IF mr_parametro.num_semana IS NOT NULL THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND retsemana(dat_entrega) = ", mr_parametro.num_semana
      END IF
      
   END IF

   IF mr_parametro.dat_pesquisa = 'L' THEN
      LET sql_stmt =
       " SELECT num_ordem, cod_item, num_docum, dat_liberac, cod_item_pai, ",
       "   qtd_planej, (qtd_planej-qtd_boas-qtd_refug-qtd_sucata), ",
       "   cod_local_prod,  retsemana(dat_liberac) FROM ordens ",
       "  WHERE cod_empresa = '",p_cod_empresa,"' ",
       "    AND ies_situa  = '4' ",
       "    AND qtd_planej > (qtd_boas + qtd_refug + qtd_sucata) ",
       "    AND dat_liberac >= '",mr_parametro.dat_ini,"' ",
       "    AND dat_liberac <= '",mr_parametro.dat_fim,"' "

      IF mr_parametro.num_semana IS NOT NULL THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND retsemana(dat_liberac) = ", mr_parametro.num_semana
      END IF
      
   END IF

   IF mr_parametro.cod_local IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND cod_local_prod = '",mr_parametro.cod_local,"' "
   END IF

   IF l_item THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND cod_item IN (SELECT cod_item FROM item_pol1301) "
   END IF

   IF mr_parametro.num_ordem IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND num_ordem = ", mr_parametro.num_ordem
   END IF

   IF mr_parametro.num_docum IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND num_docum = '",mr_parametro.num_docum,"' "
   END IF
  
   PREPARE var_ordem FROM sql_stmt   

   IF STATUS <> 0 THEN
      CALL log003_err_sql("PREPARE","var_ordem")  
      RETURN FALSE          
   END IF 
   
   LET m_count = 0
   
   DECLARE cq_ordem CURSOR FOR var_ordem

   FOREACH cq_ordem INTO 
      mr_dados.num_ordem, 
      mr_dados.cod_item, 
      mr_dados.num_docum,  
      mr_dados.data,
      m_cod_item_pai,
      mr_dados.qtd_planejada,
      mr_dados.qtd_saldo,
      mr_dados.cod_local,
      mr_dados.semana
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','ORDENS:CQ_ORDEM')
         RETURN FALSE
      END IF
      
      IF l_familia THEN
      
         SELECT cod_familia
           INTO l_cod_familia
           FROM Item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = mr_dados.cod_item

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','Item')
            RETURN FALSE
         END IF
         
         SELECT COUNT(cod_familia)
           INTO l_count
           FROM familia_pol1301
          WHERE cod_familia = l_cod_familia

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','Familia')
            RETURN FALSE
         END IF
         
         IF l_count = 0 THEN
            CONTINUE FOREACH
         END IF
         
      END IF
      
      IF mr_parametro.cod_cent_trab IS NOT NULL THEN
         
         SELECT COUNT(centro_trabalho)
           INTO l_count
           FROM man_processo_item
          WHERE empresa = p_cod_empresa
            AND item = mr_dados.cod_item
            AND centro_trabalho = mr_parametro.cod_cent_trab

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','man_processo_item.centro_trabalho')
            RETURN FALSE
         END IF
      
         IF l_count = 0 THEN
            CONTINUE FOREACH
         END IF
         
      END IF

      IF mr_parametro.cod_operac IS NOT NULL THEN

         SELECT COUNT(operacao)
           INTO l_count
           FROM man_processo_item
          WHERE empresa = p_cod_empresa
            AND item = mr_dados.cod_item
            AND operacao = mr_parametro.cod_operac

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','man_processo_item.operacao')
            RETURN FALSE
         END IF
      
         IF l_count = 0 THEN
            CONTINUE FOREACH
         END IF
         
      END IF
      
      IF NOT pol1301_le_cotas() THEN
         RETURN FALSE
      END IF
            
      LET mr_dados.cod_empresa = p_cod_empresa
      LET mr_dados.ano = YEAR(mr_dados.data)
      LET mr_dados.mes = MONTH(mr_dados.data)

      SELECT den_item_reduz
        INTO mr_dados.den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = mr_dados.cod_item
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ITEM')
         RETURN FALSE
      END IF      
      
      LET mr_dados.usuario = p_user
      
      INSERT INTO pol1301_1054 VALUES(mr_dados.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','pol1301_1054')
         RETURN FALSE
      END IF      

      LET m_count = m_count + 1         
         
   END FOREACH
   
   IF m_count = 0 THEN
      LET m_msg = 'Nenhum registro foi encontrado,\n',
                  'para os parâmetros informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE 
   END IF 

   IF NOT pol1301_le_registros() THEN
      RETURN FALSE
   END IF      
   
   CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT", "")   
   
   RETURN TRUE   

END FUNCTION

#--------------------------#
FUNCTION pol1301_le_cotas()#
#--------------------------#
   
   DEFINE l_ped_repres     LIKE pedidos.num_pedido_repres,
          l_ped_cli        LIKE pedidos.num_pedido_cli,
          l_num_pedido     LIKE pedidos.num_pedido
   
   DEFINE l_pos            CHAR(03),
          l_num_ped_cli    CHAR(10)          
   
   LET l_num_pedido = mr_dados.num_docum
          
   SELECT num_pedido_repres,
          num_pedido_cli
     INTO l_ped_repres, l_ped_cli
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = l_num_pedido

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','pedidos')
      RETURN FALSE
   END IF
   
   LET l_num_ped_cli = l_ped_cli[1,10]
   LET l_pos = l_ped_cli[12,14], l_ped_repres CLIPPED
   
   DECLARE cq_cotas CURSOR FOR
    SELECT num_pedido, num_orc, pos, comp, 
           larg, esp, peso, m2           
      FROM cfg_val_cotas912
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = mr_dados.cod_item
       AND num_pedido = l_num_ped_cli
       AND pos = l_pos
       
   FOREACH cq_cotas INTO
       mr_dados.num_pedido, 
       mr_dados.num_orc, 
       mr_dados.pos,
       mr_dados.comp,
       mr_dados.larg,
       mr_dados.esp,
       mr_dados.peso,
       mr_dados.m2
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cfg_val_cotas912')
         RETURN FALSE
      END IF
      
      EXIT FOREACH
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_le_registros()#
#------------------------------#
   
   DEFINE l_ind     INTEGER
   
   INITIALIZE ma_ordem TO NULL
   
   LET m_checa_linha = FALSE
   LET l_ind = 1
   
   DECLARE cq_le_oper CURSOR FOR
    SELECT *
      FROM pol1301_1054
     WHERE cod_empresa = p_cod_empresa
       AND usuario = p_user
     ORDER BY cod_item, num_ordem
   
   FOREACH cq_le_oper INTO ma_ordem[l_ind].*      
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_le_oper')
         RETURN FALSE
      END IF
      
      LET ma_ordem[l_ind].ies_selecionar = 'N'
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 5000 THEN
         CALL log0030_mensagem("Limite de linhas da grade ultrapassou!","excl")
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   FREE cq_le_oper
   
   LET m_qtd_linha = l_ind - 1

   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_linha)

END FUNCTION

#------------------------------------------#
FUNCTION pol1301_grade_familia(l_container)#
#------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",300)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",200,190,230)
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    CALL _ADVPL_set_property(l_layout,"MAX_SIZE",400,130)

    LET m_brow_familia = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brow_familia,"ALIGN","CENTER")    
    CALL _ADVPL_set_property(m_brow_familia,"AFTER_ROW_EVENT","pol1301_row_familia")
    
    # código da familia

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_familia)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Familia")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",5)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1301_checa_familia")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_familia")

    # zoom da familia
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_familia)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1301_zoom_br_familia")

    #descrição da familia
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_familia)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição da familia")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",185)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_familia")

    CALL _ADVPL_set_property(m_brow_familia,"SET_ROWS",ma_familia,1)

END FUNCTION

#-----------------------------#
FUNCTION pol1301_row_familia()#
#-----------------------------#

   DEFINE l_lin_atu       SMALLINT
      
   LET l_lin_atu = _ADVPL_get_property(m_brow_familia,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN
      IF ma_familia[l_lin_atu].cod_familia IS NULL OR 
         ma_familia[l_lin_atu].cod_familia = ' ' THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1301_checa_familia()#
#-------------------------------#

   DEFINE l_lin_atu       SMALLINT
   
   LET l_lin_atu = _ADVPL_get_property(m_brow_familia,"ROW_SELECTED")
      
   LET ma_familia[l_lin_atu].den_familia = ''
   
   IF ma_familia[l_lin_atu].cod_familia IS NULL THEN
      RETURN TRUE
   END IF
       
   IF NOT pol1301_le_familia(ma_familia[l_lin_atu].cod_familia) THEN
      LET m_msg = 'Familia não existe.'
      CALL log0030_mensagem(m_msg,'excl')
      RETURN FALSE
   END IF
   
   LET ma_familia[l_lin_atu].den_familia = m_den_familia
      
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1301_zoom_br_familia()#
#---------------------------------#
    
   DEFINE l_codigo      LIKE Familia.cod_familia,
          l_lin_atu     INTEGER
          
   IF  m_zoom_familia IS NULL THEN
       LET m_zoom_familia = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_familia,"ZOOM","zoom_familia")
   END IF

   CALL _ADVPL_get_property(m_zoom_familia,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_zoom_familia,"RETURN_BY_TABLE_COLUMN","familia","cod_familia")

   IF l_codigo IS NOT NULL THEN
      LET l_lin_atu = _ADVPL_get_property(m_brow_familia,"ROW_SELECTED")
      LET ma_familia[l_lin_atu].cod_familia = l_codigo
      CALL pol1301_le_familia(l_codigo) RETURNING p_status
      LET ma_familia[l_lin_atu].den_familia = m_den_familia   
   END IF
    
END FUNCTION

#-------------------------------------#
FUNCTION pol1301_le_familia(l_familia)#
#-------------------------------------#

   DEFINE l_familia     LIKE familia.cod_familia
   
   SELECT den_familia
     INTO m_den_familia
     FROM familia
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = l_familia
      
   IF STATUS <> 0 THEN
      LET m_den_familia = ''
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------------#
FUNCTION pol1301_grade_item(l_container)#
#---------------------------------------#

    DEFINE l_container          VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    CALL _ADVPL_set_property(l_layout,"MAX_SIZE",400,130)

    LET m_brow_item = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brow_item,"ALIGN","CENTER")    
    CALL _ADVPL_set_property(m_brow_item,"AFTER_ROW_EVENT","pol1301_row_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",15)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1301_checa_item")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1301_zoom_br_item")

    #descrição do item
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição do item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",250)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    CALL _ADVPL_set_property(m_brow_item,"SET_ROWS",ma_item,1)

END FUNCTION

#--------------------------#
FUNCTION pol1301_row_item()#
#--------------------------#

   DEFINE l_lin_atu       SMALLINT
      
   LET l_lin_atu = _ADVPL_get_property(m_brow_item,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN
      IF ma_item[l_lin_atu].cod_item IS NULL OR 
         ma_item[l_lin_atu].cod_item = ' ' THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_checa_item()#
#----------------------------#

   DEFINE l_lin_atu       SMALLINT
   
   LET l_lin_atu = _ADVPL_get_property(m_brow_item,"ROW_SELECTED")
      
   LET ma_item[l_lin_atu].den_item = ''
   
   IF ma_item[l_lin_atu].cod_item IS NULL THEN
      RETURN TRUE
   END IF

   IF NOT pol1301_le_item(ma_item[l_lin_atu].cod_item) THEN
      LET m_msg = 'Item não existe.'
      CALL log0030_mensagem(m_msg,'excl')
      RETURN FALSE
   END IF
   
   LET ma_item[l_lin_atu].den_item = m_den_item
      
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_zoom_br_item()#
#------------------------------#
    
   DEFINE l_item        LIKE item.cod_item,
          l_lin_atu     INTEGER
          
   IF  m_zoom_item IS NULL THEN
       LET m_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_item,"ZOOM","zoom_item")
   END IF

   CALL _ADVPL_get_property(m_zoom_item,"ACTIVATE")

   LET l_item = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")

   IF l_item IS NOT NULL THEN
      LET l_lin_atu = _ADVPL_get_property(m_brow_item,"ROW_SELECTED")
      LET ma_item[l_lin_atu].cod_item = l_item
      CALL pol1301_le_item(l_item) RETURNING p_status
      LET ma_item[l_lin_atu].den_item = m_den_item   
   END IF
    
END FUNCTION

#-----------------------------------#
FUNCTION pol1301_le_item(l_cod_item)#
#-----------------------------------#
   
   DEFINE l_cod_item       LIKE item.cod_item

   SELECT den_item
     INTO m_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_cod_item
   
   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1301_modifica()#
#--------------------------#
      
   IF NOT m_ies_info THEN
      CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT",
             "Execute a pesquisa previamente!")
      RETURN FALSE
   END IF
   
   IF NOT pol1301_chek_apont() THEN
      RETURN FALSE
   END IF
   
   IF m_ies_proces THEN
      CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT",
             "Lote já possui apontamentos e não pode ser modificado!")
      RETURN FALSE
   END IF

   LET m_checa_linha = TRUE
   
   CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT", 
         "ENTER ou 2 Cliks = Marcar/Desmarcar - Clic em Sel: marca/desmarca tudo")   
          
   CALL _ADVPL_set_property(m_browse,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_browse,"SELECT_ITEM",1,1)
   
   LET m_clik_cab = TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1301_chek_apont()#
#----------------------------#

   SELECT COUNT(*)
     INTO m_count
     FROM lote_pol1301
    WHERE cod_empresa = p_cod_empresa
      AND num_lote = m_num_lote
      AND cod_status <> 'P'
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','lote_pol1301')
      RETURN FALSE
   END IF   

   IF m_count = 0 THEN
      LET m_ies_proces = FALSE
   ELSE 
      LET m_ies_proces = TRUE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1301_checa_linha()#
#-----------------------------#
   
   DEFINE l_lin_atu       SMALLINT,
          l_tot_apo       DECIMAL(10,3)
   
   IF NOT m_checa_linha THEN
      RETURN TRUE
   END IF       

   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN


   END IF   
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1301_canc_mod()#
#--------------------------#

   LET m_checa_linha = FALSE

   CALL pol1301_le_lote() RETURNING p_status
   CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

   CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT", 
          "Operação cancelada.")   
      
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1301_conf_mod()#
#--------------------------#
   
   DEFINE l_ind         INTEGER,
          l_new_lote    SMALLINT
   
   LET m_count = _ADVPL_get_property(m_browse,"ITEM_COUNT")
   LET m_msg = NULL
   
   IF NOT pol1301_checa_linha() THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")

   IF m_num_lote = 0 THEN
      SELECT MAX(num_lote)
        INTO m_num_lote
        FROM lote_pol1301
       WHERE cod_empresa = p_cod_empresa
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','lote_pol1301:num_lote')
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
   
      IF m_num_lote IS NULL THEN
         LET m_num_lote = 0
      END IF
   
      LET m_num_lote = m_num_lote + 1
      LET m_dat_geracao = TODAY
      LET m_hor_geracao = TIME
      LET m_ies_proces = FALSE
      LET l_new_lote = TRUE
      
      IF NOT pol1301_ins_lote() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
   ELSE
      DELETE FROM lote_item_pol1301
       WHERE cod_empresa = p_cod_empresa
         AND num_lote = m_num_lote
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','lote_item_pol1301')
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF   
      LET l_new_lote = FALSE
   END IF
          
   FOR l_ind = 1 TO m_qtd_linha
       IF ma_ordem[l_ind].ies_selecionar = 'S' THEN
          IF NOT pol1301_ins_item(l_ind) THEN
             CALL log085_transacao("ROLLBACK")
             LET m_msg = 'Modificação cancelada.'
             EXIT FOR
          END IF
       END IF
   END FOR
    
   IF l_ind = 1 THEN
      CALL log085_transacao("ROLLBACK")
      LET m_msg = 'Selecione pelo menos uma ordem.'
      CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")   
   CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
      
   CALL pol1301_le_lote() RETURNING p_status
   
   LET m_checa_linha = FALSE
   LET m_ies_mod = TRUE
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1301_ins_lote()#
#--------------------------#
   
   DEFINE l_lote         RECORD LIKE lote_pol1301.*

   LET l_lote.cod_empresa   = p_cod_empresa
   LET l_lote.usuario       = p_user
   LET l_lote.num_lote      = m_num_lote
   LET l_lote.dat_geracao   = m_dat_geracao
   LET l_lote.hor_geracao   = m_hor_geracao
   LET l_lote.cod_status    = 'P'

   INSERT INTO lote_pol1301(
      cod_empresa,  
      usuario,      
      num_lote,
      dat_geracao,  
      hor_geracao,
      cod_status)  
   VALUES(l_lote.cod_empresa,  
          l_lote.usuario,
          l_lote.num_lote,
          l_lote.dat_geracao,  
          l_lote.hor_geracao,  
          l_lote.cod_status)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','lote_pol1301')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1301_ins_item(l_ind)#
#-------------------------------#
   
   DEFINE l_ind          INTEGER
   DEFINE l_lote         RECORD LIKE lote_item_pol1301.*   

   LET l_lote.cod_empresa   = p_cod_empresa
   LET l_lote.num_lote      = m_num_lote
   LET l_lote.ano           = ma_ordem[l_ind].ano          
   LET l_lote.mes           = ma_ordem[l_ind].mes          
   LET l_lote.semana        = ma_ordem[l_ind].semana       
   LET l_lote.comp          = ma_ordem[l_ind].comp         
   LET l_lote.larg          = ma_ordem[l_ind].larg         
   LET l_lote.esp           = ma_ordem[l_ind].esp          
   LET l_lote.peso          = ma_ordem[l_ind].peso         
   LET l_lote.m2            = ma_ordem[l_ind].m2           
   LET l_lote.num_pedido    = ma_ordem[l_ind].num_pedido   
   LET l_lote.num_orc       = ma_ordem[l_ind].num_orc      
   LET l_lote.pos           = ma_ordem[l_ind].pos          
   LET l_lote.cod_item      = ma_ordem[l_ind].cod_item     
   LET l_lote.den_item      = ma_ordem[l_ind].den_item     
   LET l_lote.num_ordem     = ma_ordem[l_ind].num_ordem    
   LET l_lote.num_docum     = ma_ordem[l_ind].num_docum    
   LET l_lote.cod_local     = ma_ordem[l_ind].cod_local    
   LET l_lote.qtd_planejada = ma_ordem[l_ind].qtd_planejada
   LET l_lote.qtd_saldo     = ma_ordem[l_ind].qtd_saldo    
   LET l_lote.data          = ma_ordem[l_ind].data         
   LET l_lote.dat_geracao   = m_dat_geracao         

   INSERT INTO lote_item_pol1301(
      cod_empresa,  
      num_lote,
      ano,          
      mes,          
      semana,       
      comp,         
      larg,         
      esp,          
      peso,         
      m2,           
      num_pedido,   
      num_orc,      
      pos,          
      cod_item,     
      den_item,     
      num_ordem,    
      num_docum,    
      cod_local,    
      qtd_planejada,
      qtd_saldo,    
      data,
      dat_geracao)         
   VALUES(l_lote.cod_empresa,  
          l_lote.num_lote,
          l_lote.ano,          
          l_lote.mes,          
          l_lote.semana,       
          l_lote.comp,         
          l_lote.larg,         
          l_lote.esp,          
          l_lote.peso,         
          l_lote.m2,           
          l_lote.num_pedido,   
          l_lote.num_orc,      
          l_lote.pos,          
          l_lote.cod_item,     
          l_lote.den_item,     
          l_lote.num_ordem,    
          l_lote.num_docum,    
          l_lote.cod_local,    
          l_lote.qtd_planejada,
          l_lote.qtd_saldo,    
          l_lote.data,
          l_lote.dat_geracao)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','lote_item_pol1301')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1301_le_lote()#
#-------------------------#
   
   DEFINE l_ind     INTEGER
   
   INITIALIZE ma_ordem TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   
   SELECT *
     INTO mr_cabec.*
     FROM lote_pol1301
    WHERE cod_empresa = p_cod_empresa
      AND num_lote = m_num_lote

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','lote_pol1301')
      RETURN FALSE
   END IF
               
   LET m_checa_linha = FALSE
   LET l_ind = 1
   
   DECLARE cq_le_lote CURSOR FOR
    SELECT *
      FROM lote_item_pol1301
     WHERE cod_empresa = p_cod_empresa
       AND num_lote = m_num_lote
     ORDER BY cod_item, num_ordem
   
   FOREACH cq_le_lote INTO ma_ordem[l_ind].*      
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_le_lote')
         RETURN FALSE
      END IF
      
      LET ma_ordem[l_ind].ies_selecionar = 'S'
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 5000 THEN
         CALL log0030_mensagem("Limite de linhas da grade ultrapassou!","excl")
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   FREE cq_le_lote
   
   LET m_qtd_linha = l_ind - 1

   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_linha)

END FUNCTION

#------------------------#
FUNCTION pol1301_delete()#
#------------------------#

   IF NOT m_ies_info THEN
      CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT",
             "Execute a pesquisa previamente!")
      RETURN FALSE
   END IF
   
   IF NOT pol1301_chek_apont() THEN
      RETURN FALSE
   END IF
   
   IF m_ies_proces THEN
      CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT",
             "Lote já possui apontamentos e não pode ser excluído!")
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclusão do lote?") THEN
      CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")

   DELETE FROM lote_pol1301
    WHERE cod_empresa = p_cod_empresa
      AND num_lote = m_num_lote

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','lote_pol1301')
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF   

   DELETE FROM lote_item_pol1301
    WHERE cod_empresa = p_cod_empresa
      AND num_lote = m_num_lote

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','lote_item_pol1301')
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF   
   
   CALL log085_transacao("COMMIT")
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   
   INITIALIZE ma_ordem TO NULL
   INITIALIZE mr_cabec TO NULL
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1301_processar()#
#---------------------------#

   IF NOT m_ies_info THEN
      CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT",
             "Execute a pesquisa previamente!")
      RETURN FALSE
   END IF

   INITIALIZE mr_parametro TO NULL
   INITIALIZE ma_operacao TO NULL              
   INITIALIZE m_msg TO NULL
         
   LET m_checa_qtds = FALSE
   LET m_apontar = FALSE
   CALL pol1301_info_param()
   
   IF m_apontar THEN
      LET m_apontar = FALSE
      CALL pol1301_info_compl() 
   ELSE
      RETURN FALSE
   END IF

   IF m_apontar THEN
      IF NOT LOG_question("Confirma o apontamento ?") THEN
         LET m_msg = 'Operação cancelada.'
         CALL log0030_mensagem(m_msg,'info')                       
         RETURN FALSE
      END IF
   ELSE
      RETURN FALSE
   END IF
      
   LET p_status = TRUE
   
   CALL LOG_progresspopup_start("Apontando ordens...","pol1301_apontar","PROCESS")

   IF NOT p_status THEN 
      LET m_msg = 'Operação cancelada.'
   ELSE
      LET m_msg = 'Operação efetuada com sucesso.'
      CALL pol1301_atu_sdo_ops_dolote()
   END IF
   
   CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT",'')

   CALL log0030_mensagem(m_msg,'info') 
   
   RETURN p_status

END FUNCTION   

#------------------------------------#
FUNCTION pol1301_atu_sdo_ops_dolote()#
#------------------------------------#

   DEFINE l_saldo          DECIMAL(10,3)
   
   DECLARE cq_sdo CURSOR FOR
    SELECT num_ordem
      FROM lote_item_pol1301
     WHERE cod_empresa = p_cod_empresa
       AND num_lote = m_num_lote

   FOREACH cq_sdo INTO m_num_ordem
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','lote_item_pol1301:cq_sdo')
         RETURN
      END IF
      
      SELECT (qtd_planej - qtd_boas - qtd_refug - qtd_sucata)
        INTO l_saldo
        FROM ordens
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem = m_num_ordem
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordens:cq_sdo')
         RETURN
      END IF
      
      UPDATE lote_item_pol1301
         SET qtd_saldo = l_saldo
       WHERE cod_empresa = p_cod_empresa
         AND num_lote = m_num_lote
         AND num_ordem = m_num_ordem

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','ordens:cq_sdo')
         RETURN
      END IF
      
   END FOREACH
   
   CALL pol1301_le_lote() RETURNING p_status

END FUNCTION

#----------------------------#
FUNCTION pol1301_info_param()#
#----------------------------#   

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_cancela     VARCHAR(10)

    LET m_form_operac = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_operac,"SIZE",870,530)
    CALL _ADVPL_set_property(m_form_operac,"TITLE","SELEÇÃO DA OPERAÇÃO / CENTRO DE TRABALHO")

       #Criação da barra de status
    LET m_bar_operac = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_operac)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_operac)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET m_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(m_confirma,"IMAGE","CONFIRM_EX")     
   CALL _ADVPL_set_property(m_confirma,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(m_confirma,"EVENT","pol1301_conf_apon")  
   CALL _ADVPL_set_property(m_confirma,"ENABLE",FALSE)  

   #LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   #CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   #CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   #CALL _ADVPL_set_property(l_cancela,"EVENT","pol1301_canc_apon")     

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_operac)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1301_info_oper(l_panel)
    CALL pol1301_info_qtds(l_panel)

    CALL _ADVPL_set_property(m_brow_operac,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brow_operac,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_brow_operac,"EDITABLE",FALSE)
    
    CALL _ADVPL_set_property(m_form_operac,"ACTIVATE",TRUE)
        
END FUNCTION

#---------------------------------------#
FUNCTION pol1301_info_oper(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_den_cent_trab   VARCHAR(10),
           l_den_operac      VARCHAR(10),           
           l_tabcolumn       VARCHAR(10)
    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",80)
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",8)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cent trabalho:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cent_trab = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cent_trab,"LENGTH",5)
    CALL _ADVPL_set_property(m_cent_trab,"VARIABLE",mr_parametro,"cod_cent_trab")
    CALL _ADVPL_set_property(m_cent_trab,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cent_trab,"VALID","pol1301_ck_cent_traba")

    LET m_lupa_cent_trab = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_cent_trab,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cent_trab,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cent_trab,"CLICK_EVENT","pol1301_zoom_cent_trab")

    LET l_den_cent_trab = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_den_cent_trab,"LENGTH",30) 
    CALL _ADVPL_set_property(l_den_cent_trab,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_cent_trab,"VARIABLE",mr_parametro,"den_cent_trab")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","   Operação:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_operac = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_operac,"VARIABLE",mr_parametro,"cod_operac")
    CALL _ADVPL_set_property(m_cod_operac,"LENGTH",5)
    CALL _ADVPL_set_property(m_cod_operac,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_operac,"VALID","pol1301_ck_operacao")

    LET m_lupa_operac = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_operac,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_operac,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_operac,"CLICK_EVENT","pol1301_zoom_operacao")

    LET l_den_operac = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_den_operac,"LENGTH",30) 
    CALL _ADVPL_set_property(l_den_operac,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_operac,"VARIABLE",mr_parametro,"den_operac")    

    CALL _ADVPL_set_property(m_cent_trab,"GET_FOCUS")

END FUNCTION

#-------------------------------#
FUNCTION pol1301_ck_cent_traba()#
#-------------------------------#
   
   INITIALIZE mr_parametro.den_cent_trab TO NULL
   CALL _ADVPL_set_property(m_bar_operac,"ERROR_TEXT",'')

   IF mr_parametro.cod_cent_trab IS NULL THEN
      CALL _ADVPL_set_property(m_bar_operac,"ERROR_TEXT",
             "Informe o centro de trabalho.")
      RETURN FALSE
   END IF
      
   SELECT den_cent_trab
     INTO mr_parametro.den_cent_trab
     FROM cent_trabalho
    WHERE cod_empresa = p_cod_empresa
      AND cod_cent_trab = mr_parametro.cod_cent_trab
   
   IF STATUS = 100 THEN
      CALL _ADVPL_set_property(m_bar_operac,"ERROR_TEXT",
             "Centro de trabalho inexistente.")
      RETURN FALSE
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cent_trabalho')
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_cod_operac,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1301_ck_operacao()#
#-----------------------------#
   
   INITIALIZE mr_parametro.den_operac TO NULL
   CALL _ADVPL_set_property(m_bar_operac,"ERROR_TEXT",'')
   
   IF mr_parametro.cod_operac IS NULL THEN
      CALL _ADVPL_set_property(m_bar_operac,"ERROR_TEXT",
             "Informe a operação.")
      RETURN FALSE
   END IF

   SELECT den_operac
     INTO mr_parametro.den_operac
     FROM operacao
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac = mr_parametro.cod_operac
   
   IF STATUS = 100 THEN
      CALL _ADVPL_set_property(m_bar_operac,"ERROR_TEXT",
             "Operação inexistente.")
      RETURN FALSE
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','operacao')
      RETURN FALSE
   END IF
   
   IF NOT pol1301_carrega_operacao() THEN
      RETURN FALSE
   END IF
   
   LET m_checa_qtds = TRUE
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1301_carrega_operacao()#
#----------------------------------#
      
   INITIALIZE ma_operacao TO NULL
   CALL _ADVPL_set_property(m_brow_operac,"CLEAR")
                  
   LET m_checa_qtds = FALSE
   LET m_index = 1
   
   DECLARE cq_carrega CURSOR FOR
    SELECT num_ordem, cod_item
      FROM lote_item_pol1301
     WHERE cod_empresa = p_cod_empresa
       AND num_lote = m_num_lote
     ORDER BY num_ordem DESC
   
   FOREACH cq_carrega INTO m_num_ordem, m_cod_item      
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','lote_item_pol1301:cq_carrega')
         RETURN FALSE
      END IF

      LET ma_operacao[m_index].num_ordem = m_num_ordem
      LET ma_operacao[m_index].cod_item = m_cod_item
      LET ma_operacao[m_index].qtd_refugo = 0
      LET ma_operacao[m_index].qtd_sucata = 0
      LET ma_operacao[m_index].ies_finaliza = 'N'
 
      IF NOT pol1301_le_ies_apont(m_cod_item) THEN
         RETURN FALSE
      END IF
      
      IF m_ies_apont = '2' THEN
         IF NOT pol1031_le_man_processo() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol1031_le_ord_oper() THEN
            RETURN FALSE
         END IF
      END IF
              
      IF m_index > 5000 THEN
         CALL log0030_mensagem("Limite de linhas da grade ultrapassou!","excl")
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   FREE cq_carrega
   
   LET m_qtd_oper = m_index - 1

   CALL _ADVPL_set_property(m_brow_operac,"ITEM_COUNT", m_qtd_oper)
   
   IF m_qtd_oper <= 0 THEN
      LET m_msg = "Não há Ordens  a apontar, para o\n ",
                  "centro de trabalho e/ou operação\n ", 
                  "informados."
      CALL log0030_mensagem(m_msg,'info')
      CALL _ADVPL_set_property(m_cent_trab,"GET_FOCUS")
      RETURN FALSE
   END IF      
   
   CALL pol1301_controla_acesso(FALSE)
   
   CALL _ADVPL_set_property(m_confirma,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_brow_operac,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_brow_operac,"SELECT_ITEM",1,6)
   LET m_checa_qtds = TRUE
   
   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol1301_le_ies_apont(l_item)#
#------------------------------------#
   
   DEFINE l_item         CHAR(15)
   
   SELECT ies_apontamento
     INTO m_ies_apont
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = l_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item_man:cq_carrega')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------------#
FUNCTION pol1301_controla_acesso(l_status)#
#-----------------------------------------#
   
   DEFINE l_status         SMALLINT
   
   CALL _ADVPL_set_property(m_cent_trab,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_cent_trab,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_cod_operac,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_operac,"EDITABLE",l_status)

END FUNCTION

#---------------------------------#
FUNCTION pol1031_le_man_processo()#
#---------------------------------#
   
   DEFINE l_ies_situa         CHAR(01)
   
   SELECT qtd_planej, 
          (qtd_planej - qtd_boas - qtd_refug - qtd_sucata),
          ies_situa
     INTO ma_operacao[m_index].qtd_planejada,
          ma_operacao[m_index].qtd_saldo,
          l_ies_situa
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens')
      RETURN FALSE
   END IF
   
   IF l_ies_situa <> '4' OR
      ma_operacao[m_index].qtd_saldo <= 0 THEN
      RETURN TRUE
   END IF      

   LET ma_operacao[m_index].cod_operac = mr_parametro.cod_operac
   LET ma_operacao[m_index].qtd_boas = ma_operacao[m_index].qtd_saldo
   
   DECLARE cq_man_proc CURSOR FOR
    SELECT seq_operacao 
      FROM man_processo_item
     WHERE empresa = p_cod_empresa
       AND item = m_cod_item
       AND operacao = mr_parametro.cod_operac
       AND centro_trabalho = mr_parametro.cod_cent_trab

   FOREACH cq_man_proc INTO ma_operacao[m_index].num_seq_operac

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','man_processo_item.cq_man_proc')
         RETURN FALSE
      END IF
      
      LET m_index = m_index + 1
      EXIT FOREACH
   
   END FOREACH
      
   FREE cq_man_proc
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1031_le_ord_oper()#
#-----------------------------#

   DEFINE l_seq_ant          INTEGER

   DECLARE cq_oper CURSOR FOR 
    SELECT cod_operac, num_seq_operac, qtd_planejada,
           (qtd_planejada - qtd_boas - qtd_refugo - qtd_sucata)
      FROM ord_oper
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem = m_num_ordem
       AND cod_operac = mr_parametro.cod_operac
       AND cod_cent_trab = mr_parametro.cod_cent_trab
       AND ies_apontamento = 'S'
     ORDER BY num_seq_operac

   FOREACH cq_oper INTO
      ma_operacao[m_index].cod_operac,
      ma_operacao[m_index].num_seq_operac,
      ma_operacao[m_index].qtd_planejada,
      ma_operacao[m_index].qtd_saldo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','ord_oper:cq_oper')
         RETURN FALSE
      END IF
      
      IF ma_operacao[m_index].qtd_saldo <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      LET ma_operacao[m_index].qtd_boas = ma_operacao[m_index].qtd_saldo
      
      IF ma_operacao[m_index].num_seq_operac > 1 THEN
         LET l_seq_ant = ma_operacao[m_index].num_seq_operac - 1
         
         SELECT cod_operac, qtd_boas
           INTO ma_operacao[m_index].oper_anterior,
                ma_operacao[m_index].qtd_anterior
           FROM ord_oper
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem = m_num_ordem
            AND num_seq_operac = l_seq_ant

         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','ord_oper:cq_oper')
            RETURN FALSE
         END IF
         
         IF ma_operacao[m_index].qtd_boas > ma_operacao[m_index].qtd_anterior THEN
            LET ma_operacao[m_index].qtd_boas = ma_operacao[m_index].qtd_anterior
         END IF
         
      END IF
      
      LET m_index = m_index + 1                   
      
      EXIT FOREACH
      
   END FOREACH
   
   FREE cq_oper
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1301_canc_apon()#
#---------------------------#

   LET m_msg = 'Operação cancelada'
   
   CALL _ADVPL_set_property(m_form_operac,"ACTIVATE",FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1301_conf_apon()#
#---------------------------#

   DEFINE l_qtd_boas       LIKE ord_oper.qtd_boas,
          l_qtd_refugo     LIKE ord_oper.qtd_boas,
          l_qtd_sucata     LIKE ord_oper.qtd_boas,
          l_tot_apon       LIKE ord_oper.qtd_boas,
          l_ies_apont      SMALLINT
          
   LET l_qtd_boas = 0
   LET l_qtd_refugo = 0
   LET l_qtd_sucata = 0
   LET m_periodo = FALSE
   LET m_refugo = FALSE
   LET m_sucata = FALSE
   
   FOR m_ind = 1 TO m_qtd_oper
   
       LET l_qtd_boas = l_qtd_boas + ma_operacao[m_ind].qtd_boas
       LET l_qtd_refugo = l_qtd_refugo + ma_operacao[m_ind].qtd_refugo
       LET l_qtd_sucata = l_qtd_sucata + ma_operacao[m_ind].qtd_sucata
       
       LET l_tot_apon = ma_operacao[m_ind].qtd_boas + 
              ma_operacao[m_ind].qtd_refugo + ma_operacao[m_ind].qtd_sucata
       
       IF l_tot_apon > ma_operacao[m_ind].qtd_saldo THEN
         LET m_msg = 'Ordem: ', ma_operacao[m_ind].num_ordem,' ', 
                     'Operação:',ma_operacao[m_ind].cod_operac, '\n',
                     'Quantidade total informada\n',
                     'supera o saldo da operação.'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
       END IF      
      
       IF ma_operacao[m_ind].qtd_anterior IS NOT NULL THEN
          IF l_tot_apon > ma_operacao[m_ind].qtd_anterior THEN
             LET m_msg = 'Ordem: ', ma_operacao[m_ind].num_ordem,' ', 
                         'Operação:',ma_operacao[m_ind].cod_operac, '\n',
                         'Quantidade total informada supera\n',
                         'o apontamento da operação anterior.'
             CALL log0030_mensagem(m_msg,'info')
             RETURN FALSE
          END IF      
       END IF
       
       IF ma_operacao[m_ind].qtd_boas > 0 OR
          ma_operacao[m_ind].qtd_refugo > 0 OR
          ma_operacao[m_ind].qtd_sucata > 0 THEN
          
         IF NOT pol1301_le_ies_apont(ma_operacao[m_ind].cod_item) THEN
            RETURN FALSE
         END IF
         
         IF m_ies_apont = '1' THEN
            LET m_periodo = TRUE
         END IF
         
       END IF
          
   END FOR
   
   IF l_qtd_boas = 0 AND l_qtd_refugo = 0 AND l_qtd_sucata = 0 THEN
      LET m_msg = 'Você precisa informar as quantidades\n',
                  'de pelomenos uma ordem/operação.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   IF l_qtd_refugo > 0 THEN
      LET m_refugo = TRUE
   END IF
   
   IF l_qtd_sucata > 0 THEN
      LET m_sucata = TRUE
   END IF

   LET m_apontar = TRUE
   
   CALL _ADVPL_set_property(m_form_operac,"ACTIVATE",FALSE)

   RETURN TRUE
   
END FUNCTION

#--------------------------------------#
FUNCTION pol1301_info_qtds(l_container)#
#--------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    #CALL _ADVPL_set_property(l_layout,"MAX_SIZE",400,130)

    LET m_brow_operac = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brow_operac,"ALIGN","CENTER")    
    CALL _ADVPL_set_property(m_brow_operac,"AFTER_ROW_EVENT","pol1301_checa_qtds")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_operac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ordem")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_operac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Operação")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_operac")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_operac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Num Seq")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_seq_operac")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_operac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Planejada")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_planejada")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_operac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_saldo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_operac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd boas")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",6,0)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1301_boas_valid")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_boas")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_operac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd refugo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",6,0)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1301_refugo_valid")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_refugo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_operac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd sucata")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",6,0)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1301_sucata_valid")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_sucata")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_operac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Finaliza?")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_finaliza")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_operac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_operac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Oper ant")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","oper_anterior")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_operac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Apontado")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_anterior")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_operac)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brow_operac,"SET_ROWS",ma_operacao,1)

END FUNCTION

#----------------------------#
FUNCTION pol1301_checa_qtds()#
#----------------------------#
   
   DEFINE l_lin_atu       SMALLINT,
          l_tot_apo       DECIMAL(10,3)
   
   IF NOT m_checa_qtds THEN
      RETURN TRUE
   END IF       
   
   CALL _ADVPL_set_property(m_bar_operac,"ERROR_TEXT", '')
   
   LET l_lin_atu = _ADVPL_get_property(m_brow_operac,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN
   
      LET l_tot_apo = ma_operacao[l_lin_atu].qtd_boas +
            ma_operacao[l_lin_atu].qtd_refugo + ma_operacao[l_lin_atu].qtd_sucata
            
      IF l_tot_apo > ma_operacao[l_lin_atu].qtd_saldo THEN
         LET m_msg = ' Quantidade total informada\n',
                     'supera o saldo da operação.'
         CALL _ADVPL_set_property(m_bar_operac,"ERROR_TEXT", m_msg)
         RETURN FALSE
      END IF      
      
      IF ma_operacao[l_lin_atu].qtd_anterior IS NOT NULL THEN
         IF l_tot_apo > ma_operacao[l_lin_atu].qtd_anterior THEN
            LET m_msg = ' Quantidade total informada supera\n',
                        'o apontamento da operação anterior.'
            CALL _ADVPL_set_property(m_bar_operac,"ERROR_TEXT", m_msg)
            RETURN FALSE
         END IF      
      END IF
            
   END IF   
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_boas_valid()#
#----------------------------#
   
   DEFINE l_lin_atu       SMALLINT
   
   LET l_lin_atu = _ADVPL_get_property(m_brow_operac,"ROW_SELECTED")

   IF l_lin_atu > 0 THEN
      IF ma_operacao[l_lin_atu].qtd_boas IS NULL OR
           ma_operacao[l_lin_atu].qtd_boas < 0 THEN
         LET ma_operacao[l_lin_atu].qtd_boas = 0
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_refugo_valid()#
#------------------------------#
   
   DEFINE l_lin_atu       SMALLINT
   
   LET l_lin_atu = _ADVPL_get_property(m_brow_operac,"ROW_SELECTED")

   IF l_lin_atu > 0 THEN
      IF ma_operacao[l_lin_atu].qtd_refugo IS NULL OR
           ma_operacao[l_lin_atu].qtd_refugo < 0 THEN
         LET ma_operacao[l_lin_atu].qtd_refugo = 0
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_sucata_valid()#
#------------------------------#
   
   DEFINE l_lin_atu       SMALLINT
   
   LET l_lin_atu = _ADVPL_get_property(m_brow_operac,"ROW_SELECTED")

   IF l_lin_atu > 0 THEN
      IF ma_operacao[l_lin_atu].qtd_sucata IS NULL OR
           ma_operacao[l_lin_atu].qtd_sucata < 0 THEN
         LET ma_operacao[l_lin_atu].qtd_sucata = 0
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_info_compl()#
#----------------------------#   

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_cancela     VARCHAR(10),
           l_confirma    VARCHAR(10)
                
    LET m_form_compl = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_compl,"SIZE",700,400)
    CALL _ADVPL_set_property(m_form_compl,"TITLE","INFORMAÇÕES COMPLEMENTARES")

    LET m_bar_compl = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_compl)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_compl)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
   CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirma,"EVENT","pol1301_conf_compl")  

   #LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   #CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   #CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   #CALL _ADVPL_set_property(l_cancela,"EVENT","pol1301_canc_compl")     

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_compl)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1301_info_periodo(l_panel)
    CALL pol1301_habilita_campos()
    
    CALL _ADVPL_set_property(m_form_compl,"ACTIVATE",TRUE)
        
END FUNCTION

#----------------------------------------#
FUNCTION pol1301_info_periodo(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_esquerdo        VARCHAR(10),
           l_direito         VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_den_item        VARCHAR(10),
           l_motivo_refugo   VARCHAR(10),
           l_motivo_sucata   VARCHAR(10),
           l_den_turno       VARCHAR(10),
           l_nom_profis      VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",4)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Operador:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_profis = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_profis,"VARIABLE",mr_parametro,"cod_profis")
    CALL _ADVPL_set_property(m_cod_profis,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_profis,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_profis,"VALID","pol1301_checa_profis")

    #criação/definição do icone do zoom
    LET m_lupa_profis = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_profis,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_profis,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_profis,"CLICK_EVENT","pol1301_zoom_profis")

    #criação/definição do campos para exibir o nome d profissional
    LET l_nom_profis = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_nom_profis,"LENGTH",30) 
    CALL _ADVPL_set_property(l_nom_profis,"EDITABLE",FALSE) #não permite edição do conteúdo
    CALL _ADVPL_set_property(l_nom_profis,"VARIABLE",mr_parametro,"nom_profis")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Codigo do turno:")  
    IF m_periodo then  
       CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    END IF

    LET m_cod_turno = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_turno,"LENGTH",6,0)
    CALL _ADVPL_set_property(m_cod_turno,"VARIABLE",mr_parametro,"cod_turno")
    CALL _ADVPL_set_property(m_cod_turno,"PICTURE","@E ######")
    CALL _ADVPL_set_property(m_cod_turno,"VALID","pol1301_checa_turno")

    LET m_lupa_turno = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_turno,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_turno,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_turno,"CLICK_EVENT","pol1301_zoom_turno")

    LET l_den_turno = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_den_turno,"LENGTH",25) 
    CALL _ADVPL_set_property(l_den_turno,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_turno,"VARIABLE",mr_parametro,"den_turno")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Início da produção:") 
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_dat_prod_ini = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_prod_ini,"VARIABLE",mr_parametro,"dat_prod_ini")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Às:")
    IF m_periodo then  
       CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    END IF

    LET m_hor_prod_ini = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_hor_prod_ini,"LENGTH",5)
    CALL _ADVPL_set_property(m_hor_prod_ini,"VARIABLE",mr_parametro,"hor_prod_ini")
    CALL _ADVPL_set_property(m_hor_prod_ini,"PICTURE","99:99")
    CALL _ADVPL_set_property(m_hor_prod_ini,"VALID","pol1301_checa_hor_ini")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Final da produção:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_dat_prod_fim = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_prod_fim,"VARIABLE",mr_parametro,"dat_prod_fim")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Às:")
    IF m_periodo then  
       CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    END IF

    LET m_hor_prod_fim = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_hor_prod_fim,"LENGTH",5)
    CALL _ADVPL_set_property(m_hor_prod_fim,"VARIABLE",mr_parametro,"hor_prod_fim")
    CALL _ADVPL_set_property(m_hor_prod_fim,"PICTURE","99:99")
    CALL _ADVPL_set_property(m_hor_prod_fim,"VALID","pol1301_checa_hor_fim")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cod Item sucata:")    
    IF m_sucata then  
       CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    END IF

    LET m_item_sucata = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_item_sucata,"LENGTH",15)
    CALL _ADVPL_set_property(m_item_sucata,"VARIABLE",mr_parametro,"cod_item_sucata")
    CALL _ADVPL_set_property(m_item_sucata,"PICTURE","@!")
    CALL _ADVPL_set_property(m_item_sucata,"VALID","pol1301_checa_sucata")

    LET m_lupa_sucata = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_sucata,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_sucata,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_sucata,"CLICK_EVENT","pol1301_zoom_sucata")

    LET l_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_den_item,"LENGTH",50) 
    CALL _ADVPL_set_property(l_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_item,"VARIABLE",mr_parametro,"den_item_sucata")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Motivo da sucata:")    
    IF m_sucata then  
       CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    END IF

    LET m_cod_mot_sucata = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_mot_sucata,"LENGTH",6,0)
    CALL _ADVPL_set_property(m_cod_mot_sucata,"VARIABLE",mr_parametro,"cod_mot_sucata")
    CALL _ADVPL_set_property(m_cod_mot_sucata,"PICTURE","@E ###")
    CALL _ADVPL_set_property(m_cod_mot_sucata,"VALID","pol1301_checa_mot_suc")


    LET m_lupa_mot_sucata = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_mot_sucata,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_mot_sucata,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_mot_sucata,"CLICK_EVENT","pol1301_zoom_mot_suc")

    LET m_motivo_sucata = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_motivo_sucata,"LENGTH",50)
    CALL _ADVPL_set_property(m_motivo_sucata,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_motivo_sucata,"VARIABLE",mr_parametro,"den_mot_sucata")
    CALL _ADVPL_set_property(m_motivo_sucata,"PICTURE","@!")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Motivo do refugo:")    
    IF m_refugo then  
       CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    END IF

    LET m_cod_mot_refugo = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_mot_refugo,"LENGTH",6,0)
    CALL _ADVPL_set_property(m_cod_mot_refugo,"VARIABLE",mr_parametro,"cod_mot_refugo")
    CALL _ADVPL_set_property(m_cod_mot_refugo,"PICTURE","@E ###")
    CALL _ADVPL_set_property(m_cod_mot_refugo,"VALID","pol1301_checa_mot_ref")

    LET m_lupa_mot_refugo = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_mot_refugo,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_mot_refugo,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_mot_refugo,"CLICK_EVENT","pol1301_zoom_mot_ref")

    LET m_motivo_refugo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_motivo_refugo,"LENGTH",50)
    CALL _ADVPL_set_property(m_motivo_refugo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_motivo_refugo,"VARIABLE",mr_parametro,"den_mot_refugo")
    CALL _ADVPL_set_property(m_motivo_refugo,"PICTURE","@!")

END FUNCTION

#---------------------------------#
FUNCTION pol1301_habilita_campos()#
#---------------------------------#

   CALL _ADVPL_set_property(m_cod_turno,"EDITABLE",m_periodo)
   CALL _ADVPL_set_property(m_lupa_turno,"EDITABLE",m_periodo)
   CALL _ADVPL_set_property(m_hor_prod_ini,"EDITABLE",m_periodo)
   CALL _ADVPL_set_property(m_hor_prod_fim,"EDITABLE",m_periodo)

   CALL _ADVPL_set_property(m_item_sucata,"EDITABLE",m_sucata)
   CALL _ADVPL_set_property(m_lupa_sucata,"EDITABLE",m_sucata)
   CALL _ADVPL_set_property(m_cod_mot_sucata,"EDITABLE",m_sucata)
   CALL _ADVPL_set_property(m_lupa_mot_sucata,"EDITABLE",m_sucata)
   
   CALL _ADVPL_set_property(m_cod_mot_refugo,"EDITABLE",m_refugo)
   CALL _ADVPL_set_property(m_lupa_mot_refugo,"EDITABLE",m_refugo)

   LET mr_parametro.dat_prod_ini = TODAY - 1
   LET mr_parametro.dat_prod_fim = TODAY - 1 

   IF m_periodo THEN
      LET mr_parametro.hor_prod_ini = TIME
   ELSE
      LET mr_parametro.hor_prod_ini = '00:00'
      LET mr_parametro.hor_prod_fim = '00:00'
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol1301_checa_turno()#
#-----------------------------#
   
   INITIALIZE mr_parametro.den_turno TO NULL
   CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",'')
   
   IF mr_parametro.cod_turno IS NOT NULL THEN
      
      SELECT den_turno
        INTO mr_parametro.den_turno
        FROM turno
       WHERE cod_empresa = p_cod_empresa
         AND cod_turno = mr_parametro.cod_turno
   
      IF STATUS = 100 THEN
         CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",
                "Turno inexistente.")
         RETURN FALSE
      END IF

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','turno')
         RETURN FALSE
      END IF
   
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_zoom_turno()#
#----------------------------#

    DEFINE l_codigo          LIKE turno.cod_turno,
           l_descricao       LIKE turno.den_turno
    
    IF  m_zoom_turno IS NULL THEN
        LET m_zoom_turno = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_turno,"ZOOM","zoom_turno")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_turno,"ACTIVATE")
    
    LET l_codigo    = _ADVPL_get_property(m_zoom_turno,"RETURN_BY_TABLE_COLUMN","turno","cod_turno")
    LET l_descricao = _ADVPL_get_property(m_zoom_turno,"RETURN_BY_TABLE_COLUMN","turno","den_turno")

    IF  l_codigo IS NOT NULL THEN
        LET mr_parametro.cod_turno = l_codigo
        LET mr_parametro.den_turno = l_descricao
    END IF

END FUNCTION

#------------------------------#
FUNCTION pol1301_checa_sucata()#
#------------------------------#
      
   INITIALIZE mr_parametro.den_item_sucata TO NULL
   CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",'')
   
   IF mr_parametro.cod_item_sucata IS NOT NULL THEN
      IF NOT pol1301_le_item(mr_parametro.cod_item_sucata) THEN
         LET m_msg = 'Item não existe.'
         CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",'Item não existe.')
         RETURN FALSE
      END IF
   END IF
   
   LET  mr_parametro.den_item_sucata = m_den_item
      
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1301_zoom_sucata()#
#-----------------------------#
    
   DEFINE l_item        LIKE item.cod_item,
          l_lin_atu     INTEGER
          
   IF  m_zoom_item IS NULL THEN
       LET m_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_item,"ZOOM","zoom_item")
   END IF

   CALL _ADVPL_get_property(m_zoom_item,"ACTIVATE")

   LET l_item = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")

   IF l_item IS NOT NULL THEN
      LET mr_parametro.cod_item_sucata = l_item
      CALL pol1301_le_item(l_item) RETURNING p_status
      LET mr_parametro.den_item_sucata = m_den_item   
   END IF
    
END FUNCTION

#------------------------------#
FUNCTION pol1301_zoom_mot_suc()#
#------------------------------#
    
    DEFINE l_codigo          LIKE defeito.cod_defeito,
           l_descri          LIKE defeito.den_defeito
          
   IF  m_zoom_def_suc IS NULL THEN
       LET m_zoom_def_suc = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_def_suc,"ZOOM","zoom_defeito")
   END IF

   CALL _ADVPL_get_property(m_zoom_def_suc,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_zoom_def_suc,"RETURN_BY_TABLE_COLUMN","defeito","cod_defeito")
   LET l_descri = _ADVPL_get_property(m_zoom_def_suc,"RETURN_BY_TABLE_COLUMN","defeito","den_defeito")

   IF l_codigo IS NOT NULL THEN
      LET mr_parametro.cod_mot_sucata = l_codigo
      LET mr_parametro.den_mot_sucata = l_descri
   END IF
    
END FUNCTION

#-------------------------------#
FUNCTION pol1301_checa_mot_suc()#
#-------------------------------#
      
   INITIALIZE mr_parametro.den_mot_sucata TO NULL
   CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",'')
   
   IF mr_parametro.cod_mot_sucata IS NOT NULL THEN
      IF NOT pol1301_le_defeito(mr_parametro.cod_mot_sucata) THEN
         LET m_msg = 'Motivo de defeito inexistente.'
         CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   END IF
   
   LET  mr_parametro.den_mot_sucata = m_den_defeito
      
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_zoom_mot_ref()#
#------------------------------#
    
    DEFINE l_codigo          LIKE defeito.cod_defeito,
           l_descri          LIKE defeito.den_defeito
          
   IF  m_zoom_def_ref IS NULL THEN
       LET m_zoom_def_ref = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_def_ref,"ZOOM","zoom_defeito")
   END IF

   CALL _ADVPL_get_property(m_zoom_def_ref,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_zoom_def_ref,"RETURN_BY_TABLE_COLUMN","defeito","cod_defeito")
   LET l_descri = _ADVPL_get_property(m_zoom_def_ref,"RETURN_BY_TABLE_COLUMN","defeito","den_defeito")

   IF l_codigo IS NOT NULL THEN
      LET mr_parametro.cod_mot_refugo = l_codigo
      LET mr_parametro.den_mot_refugo = l_descri
   END IF
    
END FUNCTION

#-------------------------------#
FUNCTION pol1301_checa_mot_ref()#
#-------------------------------#
      
   INITIALIZE mr_parametro.den_mot_refugo TO NULL
   CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",'')
   
   IF mr_parametro.cod_mot_refugo IS NOT NULL THEN
      IF NOT pol1301_le_defeito(mr_parametro.cod_mot_refugo) THEN
         LET m_msg = 'Motivo de defeito inexistente.'
         CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   END IF
   
   LET  mr_parametro.den_mot_refugo = m_den_defeito
      
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1301_le_defeito(l_codigo)#
#------------------------------------#
   
   DEFINE l_codigo      LIKE defeito.cod_defeito
   
   SELECT den_defeito
     INTO m_den_defeito
     FROM defeito
    WHERE cod_empresa = p_cod_empresa
      AND cod_defeito = l_codigo
      
   IF STATUS <> 0 THEN
      IF STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','defeito')
      END IF
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
   
#-------------------------------#
FUNCTION pol1301_checa_hor_ini()#
#-------------------------------#
   
   DEFINE l_hor        INTEGER,
          l_min        INTEGER
   
   CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",'')
   
   IF mr_parametro.hor_prod_ini IS NOT NULL THEN
      LET m_msg = NULL
      LET l_hor = mr_parametro.hor_prod_ini[1,2]
      LET l_min = mr_parametro.hor_prod_ini[4,5]
      
      IF l_hor > 23 THEN
         LET m_msg = 'Hora inválida.'
      END IF

      IF l_min > 59 THEN
         LET m_msg = m_msg CLIPPED, ' - Minuto inválido.'
      END IF
      
      IF m_msg IS NOT NULL THEN
         CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF

   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1301_checa_hor_fim()#
#-------------------------------#
   
   DEFINE l_hor        INTEGER,
          l_min        INTEGER
   
   CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",'')
   
   IF mr_parametro.hor_prod_fim IS NOT NULL THEN
      LET m_msg = NULL
      LET l_hor = mr_parametro.hor_prod_fim[1,2]
      LET l_min = mr_parametro.hor_prod_fim[4,5]
      
      IF l_hor > 23 THEN
         LET m_msg = 'Hora inválida.'
      END IF

      IF l_min > 59 THEN
         LET m_msg = m_msg CLIPPED, ' - Minuto inválido.'
      END IF
      
      IF m_msg IS NOT NULL THEN
         CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF

   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_conf_compl()#
#----------------------------#

   IF mr_parametro.cod_profis IS NULL THEN
      CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",
             "Informe o operador p/ apontamento")
      CALL _ADVPL_set_property(m_cod_profis,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_parametro.dat_prod_ini IS NULL THEN
      CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",
            'Informe a data inicial.')
      CALL _ADVPL_set_property(m_dat_prod_ini,"GET_FOCUS")
      RETURN FALSE
   END IF 

   IF mr_parametro.dat_prod_fim IS NULL THEN
      CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",
            'Informe a data final.')
      CALL _ADVPL_set_property(m_dat_prod_fim,"GET_FOCUS")
      RETURN FALSE
   END IF 

   IF mr_parametro.dat_prod_fim < mr_parametro.dat_prod_ini THEN
      CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",
            'Período de produção inválido.')
      CALL _ADVPL_set_property(m_dat_prod_ini,"GET_FOCUS")
      RETURN FALSE
   END IF 

   IF m_periodo THEN
   
      IF mr_parametro.cod_turno IS NULL THEN
         CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",
               'Informe o turno.')
         CALL _ADVPL_set_property(m_cod_turno,"GET_FOCUS")
         RETURN FALSE
      END IF 
       
      IF mr_parametro.hor_prod_ini IS NULL THEN
         CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",
               'Informe a hora inicial.')
         CALL _ADVPL_set_property(m_hor_prod_ini,"GET_FOCUS")
         RETURN FALSE
      END IF 
      
      IF mr_parametro.hor_prod_fim IS NULL THEN
         CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",
               'Informe a hora final.')
         CALL _ADVPL_set_property(m_hor_prod_fim,"GET_FOCUS")
         RETURN FALSE
      END IF 
   ELSE
      LET mr_parametro.cod_turno = 1      
   END IF

   IF m_sucata THEN
   
      IF mr_parametro.cod_item_sucata IS NULL THEN
         CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",
               'Informe o item sucata.')
         CALL _ADVPL_set_property(m_item_sucata,"GET_FOCUS")
         RETURN FALSE
      END IF 

      IF mr_parametro.cod_mot_sucata IS NULL THEN
         CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",
               'Informe o motivo da sucata.')
         CALL _ADVPL_set_property(m_cod_mot_sucata,"GET_FOCUS")
         RETURN FALSE
      END IF 
   
   END IF

   IF m_refugo THEN
   
      IF mr_parametro.cod_mot_refugo IS NULL THEN
         CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT",
               'Informe o motivo do refugo.')
         CALL _ADVPL_set_property(m_cod_mot_refugo,"GET_FOCUS")
         RETURN FALSE
      END IF 
   
   END IF
   
   IF NOT pol1301_ck_fechamento() THEN
      RETURN FALSE
   END IF
   
   LET m_msg = NULL
   
   CALL _ADVPL_set_property(m_form_compl,"ACTIVATE",FALSE)
   
   LET m_apontar = TRUE
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1301_ck_fechamento()#
#-------------------------------#

   IF NOT pol1301_le_par_estoque() THEN
      RETURN FALSE
   END IF
   
   IF m_dat_fecha_ult_man IS NOT NULL THEN
      IF mr_parametro.dat_prod_fim <= m_dat_fecha_ult_man THEN
         LET m_msg = 'DATA DE PRODUÇÃO INFERIOR AO FECHAMENTO DA MANUFATURA.'
         CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT", m_msg)
         RETURN FALSE
      END IF
   END IF

   IF m_dat_fecha_ult_sup IS NOT NULL THEN
      IF mr_parametro.dat_prod_fim < m_dat_fecha_ult_sup THEN
         LET m_msg = 'DATA DE PRODUÇÃO INFERIOR AO FECHAMENTO DO ESTOQUE.'
         CALL _ADVPL_set_property(m_bar_compl,"ERROR_TEXT", m_msg)
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------------#
FUNCTION pol1301_le_par_estoque()#
#--------------------------------#

   SELECT dat_fecha_ult_man,
          dat_fecha_ult_sup
     INTO m_dat_fecha_ult_man,
          m_dat_fecha_ult_sup
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','par_estoque')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_canc_compl()#
#----------------------------#

   CALL _ADVPL_set_property(m_form_compl,"ACTIVATE",FALSE)
   
   LET m_apontar = FALSE
   
   LET m_msg = 'Operação cancelada.'
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1301_apontar()#
#-------------------------#
   
   CALL log085_transacao("BEGIN")

   IF NOT pol1301_prepara_apo() THEN
      CALL log085_transacao("ROLLBACK")
      LET p_status = FALSE
      RETURN
   END IF   
      
   IF NOT pol1301_processa_apo() THEN
      #CALL pol1301_carrega_erros()
      CALL log085_transacao("ROLLBACK")
      LET p_status = FALSE
      #IF m_index > 1 THEN
      #   CALL pol1301_exibe_erros()
      #END IF
   ELSE
      CALL log085_transacao("COMMIT")
      LET p_status = TRUE
   END IF
            
END FUNCTION

#-----------------------------#
FUNCTION pol1301_prepara_apo()#
#-----------------------------#

   INITIALIZE p_man TO NULL

   IF NOT pol1301_le_oper_estoq() THEN
      RETURN FALSE
   END IF

   IF NOT pol1301_del_erro() THEN
      RETURN FALSE
   END IF

   IF NOT pol1301_ins_processo() THEN
      RETURN FALSE
   END IF

   IF NOT pol1301_le_info_compl() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION 

#-------------------------------#
FUNCTION pol1301_le_oper_estoq()#
#-------------------------------#

   SELECT cod_estoque_sp,
          cod_estoque_rp,
          cod_estoque_rn
     INTO p_cod_oper_sp,
          p_cod_oper_rp,
          p_cod_oper_sucata
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_pcp')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1301_del_erro()#
#--------------------------#

   DELETE FROM apont_erro_pol1301

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Deletando','apont_erro_pol1301')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_ins_processo()#
#------------------------------#

   DEFINE l_processo   RECORD LIKE processo_apont_pol1301.*
   DEFINE l_ind        INTEGER

   LET l_processo.cod_empresa    = p_cod_empresa
   LET l_processo.num_processo   = 0
   LET l_processo.num_lote       = m_num_lote
   LET l_processo.usuario        = p_user
   LET l_processo.dat_processo   = TODAY
   LET l_processo.hor_processo   = TIME
   LET l_processo.cod_status     = 'A'   
      
   INSERT INTO processo_apont_pol1301(
      cod_empresa,  
      #num_processo,
      num_lote,
      usuario,      
      dat_processo, 
      hor_processo,
      cod_status)
     VALUES(
      l_processo.cod_empresa,  
      #l_processo.num_processo,
      l_processo.num_lote,
      l_processo.usuario,      
      l_processo.dat_processo, 
      l_processo.hor_processo, 
      l_processo.cod_status)
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','processo_apont_pol1301')
      RETURN FALSE
   END IF       
   
   LET m_num_processo = SQLCA.SQLERRD[2]
   
   IF NOT pol1301_ins_oper_sel() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_ins_oper_sel()#
#------------------------------#
   
   DEFINE l_ind       INTEGER
   
   FOR l_ind = 1 TO m_qtd_oper
       
       IF ma_operacao[l_ind].qtd_boas > 0 OR
          ma_operacao[l_ind].qtd_refugo > 0 OR
          ma_operacao[l_ind].qtd_sucata > 0 THEN
          
          INSERT INTO processo_item_pol1301
           VALUES(p_cod_empresa,
                  m_num_processo,
                  ma_operacao[l_ind].num_ordem,
                  ma_operacao[l_ind].cod_item,
                  mr_parametro.cod_cent_trab,
                  ma_operacao[l_ind].cod_operac,
                  ma_operacao[l_ind].num_seq_operac,
                  ma_operacao[l_ind].qtd_boas,
                  ma_operacao[l_ind].qtd_refugo,
                  ma_operacao[l_ind].qtd_sucata,
                  ma_operacao[l_ind].ies_finaliza)
          
          IF STATUS <> 0 THEN
             CALL log003_err_sql('INSERT','processo_item_pol1301')
             RETURN FALSE
          END IF
          
       END IF
               
   END FOR
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1301_le_info_compl()#
#-------------------------------#
                           
   DECLARE cq_aponta CURSOR WITH HOLD FOR
    SELECT *
      FROM processo_item_pol1301
     WHERE cod_empresa = p_cod_empresa
       AND num_processo = m_num_processo
     ORDER BY num_ordem DESC, num_seq_operac ASC

   FOREACH cq_aponta INTO 
           p_man.cod_empresa,
           p_man.num_processo,
           p_man.num_ordem,
           p_man.cod_item,
           p_man.cod_cent_trab, 
           p_man.cod_operac, 
           p_man.num_seq_operac,
           p_man.qtd_boas,
           p_man.qtd_refugo,
           p_man.qtd_sucata,
           p_man.ies_finaliza
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','processo_item_pol1301')
         RETURN FALSE
      END IF                                                 
                      
      LET m_msg = 'Preparando para apontar a OP ', p_man.num_ordem 
      CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT", m_msg) 

      LET p_man.cod_sucata = mr_parametro.cod_item_sucata
      LET p_man.cod_turno = mr_parametro.cod_turno
      LET p_man.dat_inicial = mr_parametro.dat_prod_ini
      LET p_man.hor_inicial = mr_parametro.hor_prod_ini
      LET p_man.dat_final = mr_parametro.dat_prod_fim
      LET p_man.hor_final = mr_parametro.hor_prod_fim

      IF NOT pol1301_coleta_dados() THEN
         RETURN FALSE
      END IF

      IF NOT pol1301_ins_man_apont() THEN
         RETURN FALSE
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION
                                       
#-------------------------------#
FUNCTION pol1301_coleta_dados()
#-------------------------------#

   DEFINE l_ies_recur      SMALLINT,
          l_tem_oper_final SMALLINT,
          l_ctr_lote       CHAR(01),
          l_hor_ini        CHAR(08),
          l_ies_apont      CHAR(01)

   LET p_man.cod_empresa = p_cod_empresa
   LET p_man.tip_movto = 'N'
   LET p_man.num_processo = m_num_processo
   
   SELECT cod_local_prod,
          num_lote,
          qtd_planej
     INTO p_man.cod_local,
          p_man.num_lote,
          m_qtd_planejada
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_man.num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ordens')
      RETURN FALSE
   END IF
   
   SELECT ies_apontamento
     INTO l_ies_apont
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_man.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item_man')
      RETURN FALSE
   END IF

   IF l_ies_apont = '2' THEN
      LET p_man.cod_operac = '     '
      LET p_man.num_seq_operac = NULL
      LET p_man.cod_cent_trab = '     '
      LET p_man.cod_arranjo = '     '
      LET p_man.cod_cent_cust = 0
      LET p_man.qtd_hor = 0
      LET p_man.oper_final = 'S'
      LET p_man.cod_recur = '     '      
      RETURN TRUE
   END IF

   SELECT cod_arranjo,
          cod_cent_cust,
          ies_oper_final
     INTO p_man.cod_arranjo,
          p_man.cod_cent_cust,
          p_man.oper_final
		 FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.num_ordem
      AND num_seq_operac = p_man.num_seq_operac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ord_oper')
      RETURN FALSE
   END IF
            
   LET l_ies_recur = FALSE
      
   DECLARE cq_recurso CURSOR FOR
    SELECT a.cod_recur
      FROM rec_arranjo a,
           recurso b
     WHERE a.cod_empresa   = p_cod_empresa
       AND a.cod_arranjo   = p_man.cod_arranjo
       AND b.cod_empresa   = a.cod_empresa
       AND b.cod_recur     = a.cod_recur
       AND b.ies_tip_recur = '2'
       
   FOREACH cq_recurso INTO p_man.cod_recur

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_recurso')
         RETURN FALSE
      END IF
         
      LET l_ies_recur = TRUE
         
   END FOREACH

   IF NOT l_ies_recur THEN
      LET p_man.cod_recur = ' '
   END IF

   IF NOT pol1301_calc_qtd_horas() THEN
      RETURN FALSE
   END IF
         
   RETURN TRUE   

END FUNCTION

#--------------------------------#
FUNCTION pol1301_calc_qtd_horas()#
#--------------------------------#

   DEFINE l_hi             INTEGER,
          l_mi             INTEGER,
          l_hf             INTEGER,
          l_mf             INTEGER,
          l_qtd_dia        INTEGER,
          l_qtd_hor        DECIMAL(8,2),
          l_qtd_min        INTEGER

   LET l_qtd_dia = p_man.dat_final - p_man.dat_inicial      
   LET l_qtd_hor = l_qtd_dia * 24
   
   LET l_hi = p_man.hor_inicial[1,2]
   LET l_mi = p_man.hor_inicial[4,5]
   LET l_hf = p_man.hor_final[1,2]
   LET l_mf = p_man.hor_final[4,5]
   
   IF l_hf > l_hi THEN
      LET l_qtd_hor = l_qtd_hor + (l_hf - l_hi)
   END IF

   IF l_hf < l_hi THEN
      LET l_qtd_hor = l_qtd_hor - (l_hi - l_hf)
   END IF
   
   IF l_mf > l_mi THEN
      LET l_qtd_min = l_mf - l_mi
      LET l_qtd_hor = l_qtd_hor + (l_qtd_min / 60)
   END IF

   IF l_mf < l_mi THEN
      LET l_qtd_min = l_mi - l_mf 
      LET l_qtd_hor = l_qtd_hor - (l_qtd_min / 60)
   END IF
   
   LET p_man.qtd_hor = l_qtd_hor

END FUNCTION

#-------------------------------#
FUNCTION pol1301_ins_man_apont()#
#-------------------------------#
                 
   LET p_man.nom_prog = 'POL1301'
   LET p_man.nom_usuario = p_user
   LET p_man.cod_status = 'I'
   LET p_man.dat_atualiz = TODAY
   LET p_man.num_seq_apont = 0
   LET p_man.integr_min = 'N'
   LET p_man.matricula = mr_parametro.cod_profis CLIPPED
   LET p_man.num_processo = m_num_processo
   LET p_man.comprimento = 0   
   LET p_man.largura = 0    
   LET p_man.altura = 0    
   LET p_man.diametro = 0     

   INSERT INTO man_apont_pol1301 (
      cod_empresa,   
      #num_seq_apont, 
      num_processo,  
      num_ordem,     
      num_pedido,    
      num_seq_pedido,
      cod_item,      
      num_lote,      
      dat_inicial,   
      dat_final,     
      cod_recur,     
      cod_operac,    
      num_seq_operac,
      oper_final,    
      ies_finaliza,
      cod_cent_trab, 
      cod_cent_cust, 
      cod_arranjo,   
      qtd_refugo,    
      qtd_sucata,    
      qtd_boas,      
      comprimento,   
      largura,       
      altura,        
      diametro,      
      tip_movto,     
      cod_local,     
      qtd_hor,       
      matricula,     
      cod_turno,     
      hor_inicial,   
      hor_final,     
      unid_funcional,
      dat_atualiz,   
      ies_terminado, 
      cod_eqpto,     
      cod_ferramenta,
      integr_min,    
      nom_prog,      
      nom_usuario,   
      cod_status,
      cod_sucata)    
    VALUES(
       p_man.cod_empresa,   
       #p_man.num_seq_apont, 
       p_man.num_processo,  
       p_man.num_ordem,     
       p_man.num_pedido,    
       p_man.num_seq_pedido,
       p_man.cod_item,      
       p_man.num_lote,      
       p_man.dat_inicial,   
       p_man.dat_final,     
       p_man.cod_recur,     
       p_man.cod_operac,    
       p_man.num_seq_operac,
       p_man.oper_final,   
       p_man.ies_finaliza, 
       p_man.cod_cent_trab, 
       p_man.cod_cent_cust, 
       p_man.cod_arranjo,   
       p_man.qtd_refugo,    
       p_man.qtd_sucata,    
       p_man.qtd_boas,      
       p_man.comprimento,   
       p_man.largura,       
       p_man.altura,        
       p_man.diametro,      
       p_man.tip_movto,     
       p_man.cod_local,     
       p_man.qtd_hor,       
       p_man.matricula,     
       p_man.cod_turno,     
       p_man.hor_inicial,   
       p_man.hor_final,     
       p_man.unid_funcional,
       p_man.dat_atualiz,   
       p_man.ies_terminado, 
       p_man.cod_eqpto,     
       p_man.cod_ferramenta,
       p_man.integr_min,    
       p_man.nom_prog,      
       p_man.nom_usuario,   
       p_man.cod_status,
       p_man.cod_sucata)
          
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Inserindo','man_apont_pol1301')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#------------------------------#   
FUNCTION pol1301_processa_apo()#
#------------------------------#
   
   IF NOT pol1301_grava_apont() THEN
      RETURN FALSE
   END IF
   
   IF p_criticou THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1301_upd_man() THEN
      RETURN FALSE
   END IF

   IF NOT pol1301_upd_lote() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION      

#-------------------------#
FUNCTION pol1301_upd_man()#
#-------------------------#

   UPDATE man_apont_pol1301
      SET cod_status = 'A'
    WHERE cod_empresa  = p_cod_empresa
      AND num_processo = m_num_processo
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizado','man_apont_pol1301')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1301_upd_lote()#
#----------------------------#

   UPDATE lote_pol1301
     SET cod_status = 'A'
    WHERE cod_empresa = p_cod_empresa
      AND num_lote = m_num_lote
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','lote_pol1301')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1301_grava_apont()#
#-----------------------------#
   
   DECLARE cq_man CURSOR FOR
    SELECT *
      FROM man_apont_pol1301
     WHERE cod_empresa  = p_cod_empresa
       AND num_processo = m_num_processo
       AND cod_status   = 'I'
     ORDER BY num_seq_apont

   FOREACH cq_man INTO p_man.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_man')
         RETURN FALSE
      END IF                                           

      LET p_criticou = FALSE
   
      IF NOT pol1301_le_roteiros() THEN
         RETURN FALSE
      END IF

      IF NOT pol1301_ins_mestre() THEN
         RETURN FALSE
      END IF

      IF NOT pol1301_ins_tempo() THEN
         RETURN FALSE
      END IF

      IF p_man.num_seq_operac IS NOT NULL THEN
         IF NOT pol1301_atuali_ord_oper() THEN
            RETURN FALSE
         END IF
      END IF
      
      IF NOT pol1301_ins_detalhe() THEN
         RETURN FALSE
      END IF

      IF NOT pol1301_gra_tabs_velhas() THEN
         RETURN FALSE 
      END IF
      
      INSERT INTO sequencia_apo_pol1301
       VALUES(p_cod_empresa, m_num_processo, p_man.num_seq_apont,
              p_num_seq_reg, p_seq_reg_mestre)
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Insert','sequencia_apo_pol1301')
         RETURN FALSE
      END IF

      IF p_man.oper_final = 'N' THEN
         LET p_man.qtd_boas = 0
      END IF
      
      LET m_qtd_apont = p_man.qtd_boas + p_man.qtd_refugo + p_man.qtd_sucata
      
      IF m_qtd_apont > 0 THEN
         IF NOT pol1301_move_estoq() THEN
            RETURN FALSE
         END IF
      END IF

   END FOREACH
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_le_roteiros()
#----------------------------#

   SELECT cod_roteiro,                                 
          num_altern_roteiro,                             
          dat_ini                                         
     INTO p_cod_roteiro,                                  
          p_num_altern_roteiro,                           
          p_dat_inicio                                    
     FROM ordens                                          
    WHERE cod_empresa = p_cod_empresa                     
      AND num_ordem   = p_man.num_ordem                   
                                                         
   IF STATUS <> 0 THEN                                    
      CALL log003_err_sql('Lendo','ordens')               
      RETURN FALSE                                        
   END IF                                                 
                                                       
   IF p_dat_inicio IS NULL OR p_dat_inicio = ' ' THEN     
      LET p_dat_inicio = TODAY           
   END IF                                                 

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_ins_mestre()
#----------------------------#
   
   DEFINE p_cod_uni_funcio     LIKE uni_funcional.cod_uni_funcio,
          p_man_apo_mestre     RECORD LIKE man_apo_mestre.*

   LET p_cod_uni_funcio = ''

   DECLARE cq_funcio CURSOR FOR 
		SELECT cod_uni_funcio 
		  FROM uni_funcional 
		 WHERE cod_empresa     = p_cod_empresa
			AND cod_centro_custo = p_man.cod_cent_cust
   
   FOREACH cq_funcio INTO p_cod_uni_funcio
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','uni_funcional')
      END IF
      
      EXIT FOREACH
   
   END FOREACH
   
   LET p_man_apo_mestre.empresa         = p_cod_empresa
   LET p_man_apo_mestre.seq_reg_mestre  = 0
   LET p_man_apo_mestre.sit_apontamento = 'A'
   LET p_man_apo_mestre.tip_moviment    = 'N'
   LET p_man_apo_mestre.data_producao   = p_man.dat_inicial
   LET p_man_apo_mestre.ordem_producao  = p_man.num_ordem
   LET p_man_apo_mestre.item_produzido  = p_man.cod_item
   LET p_man_apo_mestre.secao_requisn   = p_cod_uni_funcio
   LET p_man_apo_mestre.usu_apontamento = p_user
   LET p_man_apo_mestre.data_apontamento= TODAY  
   LET p_man_apo_mestre.hor_apontamento = TIME
   LET p_man_apo_mestre.usuario_estorno = ''
   LET p_man_apo_mestre.data_estorno    = ''
   LET p_man_apo_mestre.hor_estorno     = ''
   LET p_man_apo_mestre.apo_automatico  = 'N'
   LET p_man_apo_mestre.seq_reg_origem  = ''
   LET p_man_apo_mestre.observacao      = ''
   LET p_man_apo_mestre.seq_registro_integracao = ''

   INSERT INTO man_apo_mestre (
      empresa, 
      #seq_reg_mestre,
      sit_apontamento, 
      tip_moviment, 
      data_producao, 
      ordem_producao, 
      item_produzido, 
      secao_requisn, 
      usu_apontamento, 
      data_apontamento, 
      hor_apontamento, 
      usuario_estorno, 
      data_estorno, 
      hor_estorno, 
      apo_automatico, 
      seq_reg_origem, 
      observacao, 
      seq_registro_integracao) 
   VALUES(p_man_apo_mestre.empresa,  
          #p_man_apo_mestre.seq_reg_mestre,       
          p_man_apo_mestre.sit_apontamento, 
          p_man_apo_mestre.tip_moviment,    
          p_man_apo_mestre.data_producao,   
          p_man_apo_mestre.ordem_producao,  
          p_man_apo_mestre.item_produzido,  
          p_man_apo_mestre.secao_requisn,   
          p_man_apo_mestre.usu_apontamento, 
          p_man_apo_mestre.data_apontamento,
          p_man_apo_mestre.hor_apontamento, 
          p_man_apo_mestre.usuario_estorno, 
          p_man_apo_mestre.data_estorno,    
          p_man_apo_mestre.hor_estorno,     
          p_man_apo_mestre.apo_automatico,  
          p_man_apo_mestre.seq_reg_origem,  
          p_man_apo_mestre.observacao,      
          p_man_apo_mestre.seq_registro_integracao)
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','man_apo_mestre')
      RETURN FALSE
   END IF

   LET p_seq_reg_mestre = SQLCA.SQLERRD[2]

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1301_ins_tempo()
#--------------------------#

   DEFINE p_man_tempo_producao RECORD LIKE man_tempo_producao.*

   LET p_man_tempo_producao.empresa            = p_cod_empresa
   LET p_man_tempo_producao.seq_reg_mestre     = p_seq_reg_mestre
   LET p_man_tempo_producao.seq_registro_tempo = 0
   LET p_man_tempo_producao.turno_producao     = p_man.cod_turno
   LET p_man_tempo_producao.data_ini_producao  = p_man.dat_inicial
   LET p_man_tempo_producao.hor_ini_producao   = p_man.hor_inicial
   LET p_man_tempo_producao.dat_final_producao = p_man.dat_final
   LET p_man_tempo_producao.hor_final_producao = p_man.hor_final
   LET p_man_tempo_producao.periodo_produtivo  = 'A' # Tipo A=produção Tipo I=parada
   LET p_man_tempo_producao.tempo_tot_producao = p_man.qtd_hor 
   LET p_man_tempo_producao.tmp_ativo_producao = p_man.qtd_hor #descontar tempo de paradas, se houver
   LET p_man_tempo_producao.tmp_inatv_producao = 0 # tempo da parada, se for tipo I
      
   INSERT INTO man_tempo_producao(
      empresa,           
      seq_reg_mestre,    
      #seq_registro_tempo,
      turno_producao,    
      data_ini_producao, 
      hor_ini_producao,  
      dat_final_producao,
      hor_final_producao,
      periodo_produtivo, 
      tempo_tot_producao,
      tmp_ativo_producao,
      tmp_inatv_producao)
   VALUES(p_man_tempo_producao.empresa,           
          p_man_tempo_producao.seq_reg_mestre,    
          #p_man_tempo_producao.seq_registro_tempo,
          p_man_tempo_producao.turno_producao,    
          p_man_tempo_producao.data_ini_producao, 
          p_man_tempo_producao.hor_ini_producao,  
          p_man_tempo_producao.dat_final_producao,
          p_man_tempo_producao.hor_final_producao,
          p_man_tempo_producao.periodo_produtivo, 
          p_man_tempo_producao.tempo_tot_producao,
          p_man_tempo_producao.tmp_ativo_producao,
          p_man_tempo_producao.tmp_inatv_producao)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','man_tempo_producao')
      RETURN FALSE
   END IF
  
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1301_atuali_ord_oper()
#---------------------------------#
   
   DEFINE p_qtd_sdo_op     LIKE ord_oper.qtd_planejada,
          p_qtd_sdo_opa    LIKE ord_oper.qtd_planejada,
          l_dat_iniio      LIKE ord_oper.dat_inicio,
          l_seq_ant        INTEGER,
          l_ies_apont      CHAR(01)
   
   SELECT dat_inicio,
          ies_apontamento
     INTO l_dat_iniio, l_ies_apont
     FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.num_ordem
	    AND cod_operac     = p_man.cod_operac
	    AND num_seq_operac = p_man.num_seq_operac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ord_oper:dat_inicio')
      RETURN FALSE
   END IF
   
   IF l_dat_iniio IS NULL OR l_dat_iniio = ' ' THEN
      LET l_dat_iniio = p_dat_inicio
   END IF
   
   IF p_man.ies_finaliza = 'S' THEN
      LET l_ies_apont = 'F'
   END IF
   
   UPDATE ord_oper
      SET qtd_boas   = qtd_boas + p_man.qtd_boas,
          qtd_refugo = qtd_refugo + p_man.qtd_refugo,
          qtd_sucata = qtd_sucata + p_man.qtd_sucata,
          dat_inicio = p_dat_inicio,
          ies_apontamento = l_ies_apont
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.num_ordem
	    AND cod_operac     = p_man.cod_operac
	    AND num_seq_operac = p_man.num_seq_operac
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ord_oper:qtds')
      RETURN FALSE
   END IF
      
   IF p_man.num_seq_operac > 1 THEN
      LET l_seq_ant = p_man.num_seq_operac - 1
      SELECT qtd_boas 
        INTO p_qtd_sdo_opa 
        FROM ord_oper
       WHERE cod_empresa    = p_cod_empresa
	       AND num_ordem      = p_man.num_ordem
	       AND num_seq_operac = l_seq_ant
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ord_oper:seq.anterior')
         RETURN FALSE
      END IF
      IF p_qtd_sdo_opa IS NULL THEN
         LET p_qtd_sdo_opa = 0
      END IF
      IF p_qtd_sdo_opa > p_qtd_sdo_op THEN
         LET p_msg = 'Ordem.....: ', p_man.num_ordem USING '<<<<<<<<<','\n',
                     'Operação..: ', p_man.cod_operac CLIPPED,'\n',
                     'Seq operac: ', p_man.num_seq_operac USING '<<<','\n\n',
                     'A operação anterior não possui\n',
                     'apontamentos sufucientes.'
         CALL log0030_mensagem(p_msg, 'info')
         RETURN FALSE  
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_ins_detalhe()
#----------------------------#
   
   DEFINE p_man_apo_detalhe     RECORD LIKE man_apo_detalhe.*

   SELECT cod_unid_prod 
     INTO p_cod_unid_prod
     FROM cent_trabalho
    WHERE cod_empresa   = p_cod_empresa
      AND cod_cent_trab = p_man.cod_cent_trab

   IF STATUS <> 0 THEN
      LET p_cod_unid_prod = '     '
   END IF

   LET p_man_apo_detalhe.empresa            = p_cod_empresa
   LET p_man_apo_detalhe.seq_reg_mestre     = p_seq_reg_mestre
   LET p_man_apo_detalhe.roteiro_fabr       = p_cod_roteiro
   LET p_man_apo_detalhe.altern_roteiro     = p_num_altern_roteiro
   LET p_man_apo_detalhe.sequencia_operacao = p_man.num_seq_operac
   LET p_man_apo_detalhe.operacao           = p_man.cod_operac
   LET p_man_apo_detalhe.unid_produtiva     = p_cod_unid_prod
   LET p_man_apo_detalhe.centro_trabalho    = p_man.cod_cent_trab
   LET p_man_apo_detalhe.arranjo_fisico     = p_man.cod_arranjo
   LET p_man_apo_detalhe.centro_custo       = p_man.cod_cent_cust
   LET p_man_apo_detalhe.atualiza_eqpto_min = 'N'
   LET p_man_apo_detalhe.eqpto              = p_man.cod_eqpto
   LET p_man_apo_detalhe.atlz_ferr_min      = 'N'
   LET p_man_apo_detalhe.ferramental        = '0' #pol1301_le_ferramenta()
   LET p_man_apo_detalhe.operador           = p_man.matricula
   LET p_man_apo_detalhe.observacao         = ''
   LET p_man_apo_detalhe.nome_programa      = p_man.nom_prog

  INSERT INTO man_apo_detalhe (
     empresa, 
     seq_reg_mestre, 
     roteiro_fabr, 
     altern_roteiro, 
     sequencia_operacao, 
     operacao, 
     unid_produtiva, 
     centro_trabalho, 
     arranjo_fisico, 
     centro_custo, 
     atualiza_eqpto_min, 
     eqpto, 
     atlz_ferr_min, 
     ferramental, 
     operador, 
     observacao,
     nome_programa)
  VALUES(p_man_apo_detalhe.empresa,           
         p_man_apo_detalhe.seq_reg_mestre,    
         p_man_apo_detalhe.roteiro_fabr,      
         p_man_apo_detalhe.altern_roteiro,    
         p_man_apo_detalhe.sequencia_operacao,
         p_man_apo_detalhe.operacao,          
         p_man_apo_detalhe.unid_produtiva,    
         p_man_apo_detalhe.centro_trabalho,   
         p_man_apo_detalhe.arranjo_fisico,    
         p_man_apo_detalhe.centro_custo,      
         p_man_apo_detalhe.atualiza_eqpto_min,
         p_man_apo_detalhe.eqpto,             
         p_man_apo_detalhe.atlz_ferr_min,     
         p_man_apo_detalhe.ferramental,       
         p_man_apo_detalhe.operador,    
         p_man_apo_detalhe.observacao,    
         p_man_apo_detalhe.nome_programa)
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','man_apo_detalhe')
      RETURN FALSE
   END IF
  
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1301_le_ferramenta()
#-------------------------------#

   DEFINE p_cod_ferramenta CHAR(15),
          p_seq_processo   INTEGER

   LET p_cod_ferramenta = NULL

   DECLARE cq_consumo CURSOR FOR
   SELECT seq_processo
     FROM man_processo_item
    WHERE empresa             = p_cod_empresa
      AND item                = p_man.cod_item
      AND roteiro             = p_cod_roteiro
      AND roteiro_alternativo = p_num_altern_roteiro
      AND operacao            = p_man.cod_operac
      AND seq_operacao        = p_man.num_seq_operac
   
   FOREACH cq_consumo INTO p_seq_processo
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','consumo')
         EXIT FOREACH
      END IF

      DECLARE cq_fer CURSOR FOR
       SELECT ferramenta
         FROM man_ferramenta_processo
        WHERE empresa  = p_cod_empresa
          AND seq_processo = p_seq_processo

      FOREACH cq_fer INTO p_cod_ferramenta
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','man_ferramenta_processo')
            EXIT FOREACH
         END IF
         
         EXIT FOREACH
         
      END FOREACH

   END FOREACH 
   
   IF p_cod_ferramenta IS NULL THEN
      LET p_cod_ferramenta = '0'
   END IF
   
   RETURN (p_cod_ferramenta) 
   
END FUNCTION

#---------------------------------#
FUNCTION pol1301_gra_tabs_velhas()
#---------------------------------#

   DEFINE p_apo_oper           RECORD LIKE apo_oper.*,
          p_cfp_aptm           RECORD LIKE cfp_aptm.*,
          p_cfp_apms           RECORD LIKE cfp_apms.*,
          p_cfp_appr           RECORD LIKE cfp_appr.*
  
  DEFINE l_qtd_apont           DECIMAL(10,3)
  
  LET p_apo_oper.cod_empresa     = p_cod_empresa
  LET p_apo_oper.dat_producao    = p_man.dat_inicial
  LET p_apo_oper.cod_item        = p_man.cod_item
  LET p_apo_oper.num_ordem       = p_man.num_ordem
  
  IF p_man.num_seq_operac IS NULL THEN
     LET p_apo_oper.num_seq_operac  = 0
  ELSE
     LET p_apo_oper.num_seq_operac  = p_man.num_seq_operac
  END IF
  
  LET p_apo_oper.cod_operac      = p_man.cod_operac
  LET p_apo_oper.cod_cent_trab   = p_man.cod_cent_trab
  LET p_apo_oper.cod_arranjo     = p_man.cod_arranjo
  LET p_apo_oper.cod_cent_cust   = p_man.cod_cent_cust
  LET p_apo_oper.cod_turno       = p_man.cod_turno
  LET p_apo_oper.hor_inicio      = p_man.hor_inicial
  LET p_apo_oper.hor_fim         = p_man.hor_final
  LET p_apo_oper.qtd_boas        = p_man.qtd_boas
  LET p_apo_oper.qtd_refugo      = p_man.qtd_refugo
  LET p_apo_oper.qtd_sucata      = p_man.qtd_sucata
  LET p_apo_oper.num_conta       = ' '
  LET p_apo_oper.cod_local       = p_man.cod_local
  LET p_apo_oper.cod_tip_movto   = p_man.tip_movto
  LET p_apo_oper.qtd_horas       = p_man.qtd_hor
  LET p_apo_oper.dat_apontamento = CURRENT YEAR TO SECOND
  LET p_apo_oper.nom_usuario     = p_user
  LET p_apo_oper.num_processo    = 0

  INSERT INTO apo_oper(
     cod_empresa,
     dat_producao,
     cod_item,
     num_ordem,
     num_seq_operac,
     cod_operac,
     cod_cent_trab,
     cod_arranjo,
     cod_cent_cust,
     cod_turno,
     hor_inicio,
     hor_fim,
     qtd_boas,
     qtd_refugo,
     qtd_sucata,
     cod_tip_movto,
     num_conta,
     cod_local,
     qtd_horas,
     dat_apontamento,
     nom_usuario)
     #num_processo)
     
   VALUES(
     p_apo_oper.cod_empresa,
     p_apo_oper.dat_producao,
     p_apo_oper.cod_item,
     p_apo_oper.num_ordem,
     p_apo_oper.num_seq_operac,
     p_apo_oper.cod_operac,
     p_apo_oper.cod_cent_trab,
     p_apo_oper.cod_arranjo,
     p_apo_oper.cod_cent_cust,
     p_apo_oper.cod_turno,
     p_apo_oper.hor_inicio,
     p_apo_oper.hor_fim,
     p_apo_oper.qtd_boas,
     p_apo_oper.qtd_refugo,
     p_apo_oper.qtd_sucata,
     p_apo_oper.cod_tip_movto,
     p_apo_oper.num_conta,
     p_apo_oper.cod_local,
     p_apo_oper.qtd_horas,
     p_apo_oper.dat_apontamento,
     p_apo_oper.nom_usuario)
     #p_apo_oper.num_processo)

 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','apo_oper')
      RETURN FALSE
   END IF
  
  LET p_num_seq_reg = SQLCA.SQLERRD[2] # apo_oper.num_processo

  LET p_cfp_apms.cod_empresa      = p_apo_oper.cod_empresa
  LET p_cfp_apms.num_seq_registro = p_num_seq_reg
  LET p_cfp_apms.cod_tip_movto    = p_apo_oper.cod_tip_movto

  IF p_man.tip_movto  = "E" THEN
    LET p_cfp_apms.ies_situa    = "C"
  ELSE
    LET p_cfp_apms.ies_situa    = "A"
  END IF

  LET p_cfp_apms.dat_producao   = p_apo_oper.dat_producao
  LET p_cfp_apms.num_ordem      = p_apo_oper.num_ordem
  
  IF p_man.cod_eqpto IS NOT NULL THEN
     LET  p_cfp_apms.cod_equip  = p_man.cod_eqpto
  ELSE
     LET  p_cfp_apms.cod_equip  = '0'
  END IF
  
  IF p_man.cod_ferramenta IS NOT NULL THEN
     LET  p_cfp_apms.cod_ferram = p_man.cod_ferramenta
  ELSE
     LET  p_cfp_apms.cod_ferram = '0'
  END IF
  
  LET  p_cfp_apms.cod_cent_trab     = p_apo_oper.cod_cent_trab
  LET p_cfp_apms.cod_unid_prod      = p_cod_unid_prod
  LET p_cfp_apms.cod_roteiro        = p_cod_roteiro
  LET p_cfp_apms.num_altern_roteiro = p_num_altern_roteiro
  LET p_cfp_apms.num_seq_operac     = p_man.num_seq_operac
  LET p_cfp_apms.cod_operacao       = p_apo_oper.cod_operac
  LET p_cfp_apms.cod_item           = p_apo_oper.cod_item
  LET p_cfp_apms.num_conta          = p_apo_oper.num_conta
  LET p_cfp_apms.cod_local          = p_apo_oper.cod_local
  LET p_cfp_apms.dat_apontamento    = EXTEND(p_apo_oper.dat_apontamento, YEAR TO DAY)
  LET p_cfp_apms.hor_apontamento    = EXTEND(p_apo_oper.dat_apontamento, HOUR TO SECOND)
  LET p_cfp_apms.nom_usuario_resp   = p_user
  LET p_cfp_apms.tex_apont          = NULL

  IF p_man.tip_movto = "E"  THEN
    LET p_cfp_apms.dat_estorno     = TODAY
    LET p_cfp_apms.hor_estorno     = TIME
    LET p_cfp_apms.nom_usu_estorno = p_user
  ELSE
    LET p_cfp_apms.dat_estorno     = NULL
    LET p_cfp_apms.hor_estorno     = NULL
    LET p_cfp_apms.nom_usu_estorno = NULL
  END IF

  INSERT INTO cfp_apms VALUES(p_cfp_apms.*)
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','cfp_apms')
      RETURN FALSE
   END IF

  LET l_qtd_apont = p_apo_oper.qtd_boas + p_apo_oper.qtd_refugo + p_apo_oper.qtd_sucata

  LET p_cfp_appr.cod_empresa        = p_apo_oper.cod_empresa
  LET p_cfp_appr.num_seq_registro   = p_num_seq_reg
  LET p_cfp_appr.dat_producao       = p_apo_oper.dat_producao
  LET p_cfp_appr.cod_item           = p_apo_oper.cod_item
  LET p_cfp_appr.cod_turno          = p_apo_oper.cod_turno
  LET p_cfp_appr.qtd_produzidas     = l_qtd_apont
  LET p_cfp_appr.qtd_pecas_boas     = p_apo_oper.qtd_boas
  LET p_cfp_appr.qtd_sucata         = p_apo_oper.qtd_refugo + p_apo_oper.qtd_sucata
  LET p_cfp_appr.qtd_defeito_real   = 0
  LET p_cfp_appr.qtd_defeito_padrao = 0
  LET p_cfp_appr.qtd_ciclos         = 0
  LET p_cfp_appr.num_operador       = p_man.matricula

  INSERT INTO cfp_appr VALUES(p_cfp_appr.*)
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','cfp_appr')
      RETURN FALSE
   END IF

  LET p_cfp_aptm.cod_empresa      = p_apo_oper.cod_empresa
  LET p_cfp_aptm.num_seq_registro = p_num_seq_reg
  LET p_cfp_aptm.dat_producao     = p_apo_oper.dat_producao
  LET p_cfp_aptm.cod_turno        = p_apo_oper.cod_turno
  LET p_cfp_aptm.ies_periodo      = "A"
  LET p_cfp_aptm.cod_parada       = NULL

  LET p_dat_char = 
      EXTEND(p_apo_oper.dat_producao, YEAR TO DAY), " ", p_apo_oper.hor_fim
  LET p_cfp_aptm.hor_fim_periodo = p_dat_char
  LET p_dat_char = 
      EXTEND(p_apo_oper.dat_producao, YEAR TO DAY), " ", p_apo_oper.hor_inicio
  LET p_cfp_aptm.hor_ini_periodo = p_dat_char

  LET p_cfp_aptm.hor_ini_assumido = p_cfp_aptm.hor_ini_periodo
  LET p_cfp_aptm.hor_fim_assumido = p_cfp_aptm.hor_fim_periodo
  LET p_cfp_aptm.hor_tot_periodo  = p_man.qtd_hor 
  LET p_cfp_aptm.hor_tot_assumido = p_cfp_aptm.hor_tot_periodo

  INSERT INTO cfp_aptm VALUES(p_cfp_aptm.*)
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','cfp_aptm')
      RETURN FALSE
   END IF
   
   INSERT INTO man_relc_tabela
    VALUES(p_cod_empresa,
           p_seq_reg_mestre,
           p_num_seq_reg,
           "B")

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','man_relc_tabela')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1301_material()#
#--------------------------#

   DECLARE cq_compon CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           cod_local_baixa,
           cod_item_pai,
           pct_refug
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_man.num_ordem

   FOREACH cq_compon INTO 
           p_cod_compon, 
           p_qtd_necessaria,
           p_cod_local_baixa,
           p_num_neces,
           p_pct_refug

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_compon')
         RETURN FALSE
      END IF  
      
      IF NOT pol1301_le_item_man() THEN
         RETURN FALSE
      END IF
      
      IF p_ies_tip_item = 'T' OR 
         p_ies_ctr_estoque = 'N'  OR
         p_sofre_baixa = 'N'  THEN
         CONTINUE FOREACH
      END IF

      LET p_qtd_baixar = p_qtd_necessaria * p_qtd_prod
         
      IF p_qtd_baixar > 0 THEN
         IF NOT pol1301_baixa_neces() THEN
            RETURN FALSE
         END IF
         IF NOT pol1301_baixa_compon() THEN
            RETURN FALSE
         END IF
      END IF
     
      IF p_qtd_baixar < 0 THEN
            
         LET p_qtd_sucata = p_qtd_baixar * (-1)
         
         IF NOT pol1301_aponta_sucata() THEN
            RETURN FALSE
         END IF
         
         IF NOT pol1301_baixa_neces() THEN
            RETURN FALSE
         END IF

      END IF
            
   END FOREACH
      
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1301_baixa_neces()
#-----------------------------#

   UPDATE necessidades
      SET qtd_saida = qtd_saida + p_qtd_baixar
    WHERE cod_empresa = p_cod_empresa
      AND num_neces   = p_num_neces

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','necessidades')
      RETURN FALSE
   END IF     

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_baixa_compon()#
#------------------------------#   
   
   DEFINE p_qtd_reservada   DECIMAL(10,3), 
          p_qtd_saldo       DECIMAL(10,3),
          p_baixa_do_lote   DECIMAL(10,3),
          p_sdo_lote        DECIMAL(10,3)

   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01)
   END RECORD
   
   IF p_ies_ctr_lote = 'S' THEN
      DECLARE cq_fifo CURSOR FOR
       SELECT *
         FROM estoque_lote_ender
        WHERE cod_empresa = p_cod_empresa
          AND cod_item = p_cod_compon
          AND cod_local = p_cod_local_baixa
          AND ies_situa_qtd = 'L'
          AND qtd_saldo > 0
          AND num_lote IS NOT NULL
          AND num_lote <> ' '
        ORDER BY dat_hor_producao     
   ELSE
      DECLARE cq_fifo CURSOR FOR
       SELECT *
         FROM estoque_lote_ender
        WHERE cod_empresa = p_cod_empresa
          AND cod_item = p_cod_compon
          AND cod_local = p_cod_local_baixa
          AND ies_situa_qtd = 'L'
          AND qtd_saldo > 0
          AND (num_lote IS NULL OR num_lote = ' ')
        ORDER BY dat_hor_producao     
   END IF
         
   FOREACH cq_fifo INTO p_estoque_lote_ender.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','estoque_lote_ender')
         RETURN FALSE
      END IF
      
      IF p_ies_ctr_lote = 'S' THEN
         SELECT SUM(qtd_reservada)
           INTO p_qtd_reservada 
           FROM estoque_loc_reser
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_estoque_lote_ender.cod_item
            AND cod_local= p_estoque_lote_ender.cod_local
            AND num_lote = p_estoque_lote_ender.num_lote
      ELSE
         SELECT SUM(qtd_reservada)
           INTO p_qtd_reservada 
           FROM estoque_loc_reser
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_estoque_lote_ender.cod_item
            AND cod_local= p_estoque_lote_ender.cod_local
            AND (num_lote IS NULL OR num_lote = ' ')
      END IF
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','estoque_lote_ender')
         RETURN FALSE
      END IF  

      IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
         LET p_qtd_reservada = 0
      END IF
      
      LET p_qtd_saldo = p_estoque_lote_ender.qtd_saldo - p_qtd_reservada
      
      IF p_qtd_saldo <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF p_qtd_saldo < p_qtd_baixar THEN
         LET p_baixa_do_lote = p_qtd_saldo
         LET p_qtd_baixar = p_qtd_baixar - p_qtd_saldo
      ELSE
         LET p_baixa_do_lote = p_qtd_baixar
         LET p_qtd_baixar = 0
      END IF
                 
      LET p_item.cod_empresa   = p_estoque_lote_ender.cod_empresa
      LET p_item.cod_item      = p_estoque_lote_ender.cod_item
      LET p_item.cod_local     = p_estoque_lote_ender.cod_local
      LET p_item.num_lote      = p_estoque_lote_ender.num_lote
      LET p_item.comprimento   = p_estoque_lote_ender.comprimento
      LET p_item.largura       = p_estoque_lote_ender.largura    
      LET p_item.altura        = p_estoque_lote_ender.altura     
      LET p_item.diametro      = p_estoque_lote_ender.diametro   
      LET p_item.cod_operacao  = p_cod_oper_sp
      LET p_item.ies_situa     = p_estoque_lote_ender.ies_situa_qtd
      LET p_item.qtd_movto     = p_baixa_do_lote      
      LET p_item.dat_movto     = TODAY
      LET p_item.ies_tip_movto = p_ies_tip_movto
      LET p_item.dat_proces    = TODAY
      LET p_item.hor_operac    = TIME
      LET p_item.num_prog      = p_man.nom_prog
      LET p_item.num_docum     = p_man.num_ordem
      LET p_item.num_seq       = 0
      LET p_item.tip_operacao  = 'S' #Saída
      LET p_item.usuario       = p_man.nom_usuario
      LET p_item.cod_turno     = p_man.cod_turno
      LET p_item.trans_origem  = 0
      LET p_item.ies_ctr_lote  = p_ies_ctr_lote
   
      IF NOT estoque_insere_movto(p_item) THEN
         LET m_msg = 'Problemas baixando material:\n', p_msg CLIPPED
         CALL log0030_mensagem(m_msg,'Info')
         RETURN FALSE
      END IF
      
      LET p_tip_operac = 'S'
      LET p_qtd_prod = p_baixa_do_lote
      LET p_transac_apont = p_num_trans_atual
      
      IF NOT pol1301_chf_componente() THEN            
         RETURN FALSE                                        
      END IF                                                 

      IF NOT pol1301_man_consumo() THEN            
         RETURN FALSE                                        
      END IF                                 
      
      IF NOT pol1301_insere_trans_apont() THEN
         RETURN FALSE
      END IF
      
      IF p_qtd_baixar <= 0 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH

   IF p_qtd_baixar > 0 THEN
      LET p_msg = 'Ordem.....: ', p_man.num_ordem USING '<<<<<<<<<','\n',
                  'Componente: ', p_cod_compon CLIPPED,'\n',
                  'Local.....: ', p_cod_local_baixa CLIPPED,'\n\n',
                  'Sem estoque para baixar.'
      CALL log0030_mensagem(p_msg, 'info')
      RETURN FALSE  
   END IF
   
   LET p_qtd_baixar = 0
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1301_le_item_man()
#-----------------------------#

   SELECT a.cod_local_estoq,
          a.ies_ctr_estoque,
          a.ies_ctr_lote,
          a.ies_tip_item,
          b.ies_sofre_baixa
     INTO p_cod_local_estoq,
          p_ies_ctr_estoque,
          p_ies_ctr_lote,
          p_ies_tip_item,
          p_sofre_baixa          
     FROM item a,
          item_man b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.cod_item    = p_cod_compon
      AND b.cod_empresa = a.cod_empresa
      AND b.cod_item    = a.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ITEM/ITEM_MAN')  
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1301_move_estoq()
#----------------------------#
      
   UPDATE ordens
      SET qtd_boas   = qtd_boas + p_man.qtd_boas,
          qtd_refug  = qtd_refug + p_man.qtd_refugo,
          qtd_sucata = qtd_sucata + p_man.qtd_sucata,
          dat_ini    = p_dat_inicio
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_man.num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','ordens')
      RETURN FALSE
   END IF
   
   LET p_ies_tip_movto = 'N'
   LET p_tip_operac = 'E'                                  
   
   IF p_man.qtd_boas > 0 THEN
      LET p_qtd_prod = p_man.qtd_boas
      LET p_tip_producao = 'B'
      LET p_ies_situa = 'L'
      IF NOT pol1301_aponta_estoque() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_man.qtd_refugo > 0 THEN
      LET p_qtd_prod = p_man.qtd_refugo
      LET p_tip_producao = 'R'
      LET p_ies_situa = 'R'
      IF NOT pol1301_aponta_estoque() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_man.qtd_sucata > 0 THEN
      LET p_man.cod_item = p_man.cod_sucata
      LET p_qtd_prod = p_man.qtd_sucata
      LET p_tip_producao = 'B'
      LET p_ies_situa = 'L'
      IF NOT pol1301_aponta_estoque() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1301_aponta_estoque()
#--------------------------------#

   IF NOT pol1301_le_info_item(p_man.cod_item) THEN
      RETURN FALSE
   END IF
      
   IF p_ies_ctr_lote = 'S' THEN
      IF p_man.num_lote IS NULL OR p_man.num_lote = ' ' THEN
         LET p_man.num_lote = p_man.num_ordem
      END IF
   ELSE
      LET p_man.num_lote = NULL    
   END IF

   IF p_ies_ctr_estoque = 'S' THEN
      
      IF NOT pol1301_movta_estoque() THEN
         RETURN FALSE
      END IF
      IF NOT pol1301_item_produzido() THEN                  
         RETURN FALSE                                        
      END IF                                                 
                                                          
      IF NOT pol1301_chf_componente() THEN            
         RETURN FALSE                                        
      END IF                                                 

   END IF
   
   IF NOT pol1301_material() THEN 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1301_le_info_item(p_cod)#
#-----------------------------------#
   
   DEFINE p_cod  char(15)
   
   SELECT cod_local_estoq,
          cod_local_insp,
          ies_ctr_estoque,
          ies_ctr_lote,
          ies_tem_inspecao
     INTO p_cod_local_estoq,
          p_cod_local_insp,
          p_ies_ctr_estoque,
          p_ies_ctr_lote,
          p_ies_tem_inspecao
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item:fli')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1301_movta_estoque()#
#-------------------------------#
 
   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01)
   END RECORD
      
   LET p_cod_tip_apon = 'A'
      
   LET p_item.cod_empresa   = p_man.cod_empresa
   LET p_item.cod_item      = p_man.cod_item
   LET p_item.cod_local     = p_cod_local_estoq
   LET p_item.num_lote      = p_man.num_lote
   LET p_item.comprimento   = p_man.comprimento
   LET p_item.largura       = p_man.largura    
   LET p_item.altura        = p_man.altura     
   LET p_item.diametro      = p_man.diametro  
    
   LET p_item.cod_operacao  = p_cod_oper_rp
   
   LET p_item.ies_situa     = p_ies_situa
   LET p_item.qtd_movto     = p_qtd_prod
   LET p_item.dat_movto     = TODAY
   LET p_item.ies_tip_movto = p_ies_tip_movto
   LET p_item.dat_proces    = TODAY
   LET p_item.hor_operac    = TIME
   LET p_item.num_prog      = p_man.nom_prog
   LET p_item.num_docum     = p_man.num_ordem
   LET p_item.num_seq       = 0
   
   LET p_item.tip_operacao  = 'E' #Entrada
   
   LET p_item.usuario       = p_man.nom_usuario
   LET p_item.cod_turno     = p_man.cod_turno
   LET p_item.trans_origem  = 0
   LET p_item.ies_ctr_lote  = p_ies_ctr_lote
   
   IF NOT estoque_insere_movto(p_item) THEN
         LET m_msg = 'Problemas apontando estoque:\n', p_msg CLIPPED
         CALL log0030_mensagem(m_msg,'Info')
      RETURN FALSE
   END IF
   
   LET p_transac_apont = p_num_trans_atual
   LET p_transac_pai = p_num_trans_atual

   IF NOT pol1301_insere_trans_apont() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1301_insere_trans_apont()
#-----------------------------------#
       
  INSERT INTO trans_apont_pol1301 
     VALUES(p_cod_empresa, 
            m_num_processo,
            p_transac_apont, 
            p_man.num_seq_apont,
            p_tip_operac)
            
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','trans_apont_pol1301')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1301_item_produzido()#
#--------------------------------#
      
   LET p_man_item_produzido.empresa               = p_man.cod_empresa
   LET p_man_item_produzido.seq_reg_mestre        = p_seq_reg_mestre
   LET p_man_item_produzido.seq_registro_item     = 0 #campo serial
   LET p_man_item_produzido.tip_movto             = 'N'
   LET p_man_item_produzido.item_produzido        = p_estoque_lote_ender.cod_item
   LET p_man_item_produzido.lote_produzido        = p_estoque_lote_ender.num_lote
   LET p_man_item_produzido.grade_1               = p_estoque_lote_ender.cod_grade_1
   LET p_man_item_produzido.grade_2               = p_estoque_lote_ender.cod_grade_2
   LET p_man_item_produzido.grade_3               = p_estoque_lote_ender.cod_grade_3
   LET p_man_item_produzido.grade_4               = p_estoque_lote_ender.cod_grade_4
   LET p_man_item_produzido.grade_5               = p_estoque_lote_ender.cod_grade_5
   LET p_man_item_produzido.num_peca              = p_estoque_lote_ender.num_peca
   LET p_man_item_produzido.serie                 = p_estoque_lote_ender.num_serie
   LET p_man_item_produzido.volume                = p_estoque_lote_ender.num_volume
   LET p_man_item_produzido.comprimento           = p_estoque_lote_ender.comprimento
   LET p_man_item_produzido.largura               = p_estoque_lote_ender.largura
   LET p_man_item_produzido.altura                = p_estoque_lote_ender.altura
   LET p_man_item_produzido.diametro              = p_estoque_lote_ender.diametro
   LET p_man_item_produzido.local                 = p_estoque_lote_ender.cod_local
   LET p_man_item_produzido.endereco              = p_estoque_lote_ender.endereco
   LET p_man_item_produzido.tip_producao          = p_tip_producao
   LET p_man_item_produzido.qtd_produzida         = p_qtd_prod
   LET p_man_item_produzido.qtd_convertida        = 0
   LET p_man_item_produzido.sit_est_producao      = p_estoque_lote_ender.ies_situa_qtd
   LET p_man_item_produzido.data_producao         = p_estoque_lote_ender.dat_hor_producao
   LET p_man_item_produzido.data_valid            = p_estoque_lote_ender.dat_hor_validade
   LET p_man_item_produzido.conta_ctbl            = ''
   LET p_man_item_produzido.moviment_estoque      = p_transac_pai
   LET p_man_item_produzido.seq_reg_normal        = ''
   LET p_man_item_produzido.observacao            = p_estoque_lote_ender.tex_reservado
   LET p_man_item_produzido.identificacao_estoque = ' '

   IF NOT pol1301_ins_item_produzido() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1301_ins_item_produzido()#
#------------------------------------#

      
  INSERT INTO man_item_produzido(
     empresa,              
     seq_reg_mestre,       
     #seq_registro_item,    
     tip_movto,            
     item_produzido,       
     lote_produzido,       
     grade_1,              
     grade_2,              
     grade_3,              
     grade_4,              
     grade_5,              
     num_peca,             
     serie,                
     volume,               
     comprimento,          
     largura,              
     altura,               
     diametro,             
     local,                
     endereco,             
     tip_producao,         
     qtd_produzida,        
     qtd_convertida,       
     sit_est_producao,     
     data_producao,        
     data_valid,           
     conta_ctbl,           
     moviment_estoque,     
     seq_reg_normal,       
     observacao,           
     identificacao_estoque)
   VALUES(
     p_man_item_produzido.empresa,              
     p_man_item_produzido.seq_reg_mestre,       
     #p_man_item_produzido.seq_registro_item,    
     p_man_item_produzido.tip_movto,            
     p_man_item_produzido.item_produzido,       
     p_man_item_produzido.lote_produzido,       
     p_man_item_produzido.grade_1,              
     p_man_item_produzido.grade_2,              
     p_man_item_produzido.grade_3,              
     p_man_item_produzido.grade_4,              
     p_man_item_produzido.grade_5,              
     p_man_item_produzido.num_peca,             
     p_man_item_produzido.serie,                
     p_man_item_produzido.volume,               
     p_man_item_produzido.comprimento,          
     p_man_item_produzido.largura,              
     p_man_item_produzido.altura,               
     p_man_item_produzido.diametro,             
     p_man_item_produzido.local,                
     p_man_item_produzido.endereco,             
     p_man_item_produzido.tip_producao,         
     p_man_item_produzido.qtd_produzida,        
     p_man_item_produzido.qtd_convertida,       
     p_man_item_produzido.sit_est_producao,     
     p_man_item_produzido.data_producao,        
     p_man_item_produzido.data_valid,           
     p_man_item_produzido.conta_ctbl,           
     p_man_item_produzido.moviment_estoque,     
     p_man_item_produzido.seq_reg_normal,       
     p_man_item_produzido.observacao,           
     p_man_item_produzido.identificacao_estoque)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','man_item_produzido')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1301_chf_componente()#
#--------------------------------#
  
  DEFINE p_chf_compon    RECORD LIKE chf_componente.*
  
  LET p_chf_compon.empresa            = p_estoque_lote_ender.cod_empresa
  LET p_chf_compon.sequencia_registro = p_num_seq_reg
  LET p_chf_compon.tip_movto          = p_tip_operac
  LET p_chf_compon.item_componente    = p_estoque_lote_ender.cod_item
  LET p_chf_compon.qtd_movto          = p_qtd_prod
  LET p_chf_compon.local_estocagem    = p_estoque_lote_ender.cod_local
  LET p_chf_compon.endereco           = p_estoque_lote_ender.endereco
  LET p_chf_compon.num_volume         = p_estoque_lote_ender.num_volume
  LET p_chf_compon.grade_1            = p_estoque_lote_ender.cod_grade_1
  LET p_chf_compon.grade_2            = p_estoque_lote_ender.cod_grade_2
  LET p_chf_compon.grade_3            = p_estoque_lote_ender.cod_grade_3
  LET p_chf_compon.grade_4            = p_estoque_lote_ender.cod_grade_4
  LET p_chf_compon.grade_5            = p_estoque_lote_ender.cod_grade_5
  LET p_chf_compon.pedido_venda       = p_estoque_lote_ender.num_ped_ven
  LET p_chf_compon.seq_pedido_venda   = p_estoque_lote_ender.num_seq_ped_ven
  LET p_chf_compon.sit_qtd_item       = p_estoque_lote_ender.ies_situa_qtd
  LET p_chf_compon.peca               = p_estoque_lote_ender.num_peca
  LET p_chf_compon.serie_componente   = p_estoque_lote_ender.num_serie
  LET p_chf_compon.comprimento        = p_estoque_lote_ender.comprimento
  LET p_chf_compon.largura            = p_estoque_lote_ender.largura
  LET p_chf_compon.altura             = p_estoque_lote_ender.altura
  LET p_chf_compon.diametro           = p_estoque_lote_ender.diametro
  LET p_chf_compon.lote               = p_estoque_lote_ender.num_lote
  LET p_chf_compon.dat_hor_producao   = p_estoque_lote_ender.dat_hor_producao
  LET p_chf_compon.dat_hor_validade   = p_estoque_lote_ender.dat_hor_validade
  
  if p_tip_operac = 'S' then
     LET p_chf_compon.reservado = p_tip_producao
  else
     LET p_chf_compon.reservado = null
  end if
  
  INSERT INTO chf_componente VALUES(p_chf_compon.*)
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','chf_componente')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1301_man_consumo()#
#-----------------------------#
      
   LET p_man_comp_consumido.empresa            = p_estoque_lote_ender.cod_empresa
   LET p_man_comp_consumido.seq_reg_mestre     = p_seq_reg_mestre
   LET p_man_comp_consumido.seq_registro_item  = 0
   LET p_man_comp_consumido.tip_movto          = p_ies_tip_movto
   LET p_man_comp_consumido.item_componente    = p_estoque_lote_ender.cod_item
   LET p_man_comp_consumido.grade_1            = p_estoque_lote_ender.cod_grade_1  
   LET p_man_comp_consumido.grade_2            = p_estoque_lote_ender.cod_grade_2  
   LET p_man_comp_consumido.grade_3            = p_estoque_lote_ender.cod_grade_3  
   LET p_man_comp_consumido.grade_4            = p_estoque_lote_ender.cod_grade_4  
   LET p_man_comp_consumido.grade_5            = p_estoque_lote_ender.cod_grade_5  
   LET p_man_comp_consumido.num_peca           = p_estoque_lote_ender.num_peca     
   LET p_man_comp_consumido.serie              = p_estoque_lote_ender.num_serie    
   LET p_man_comp_consumido.volume             = p_estoque_lote_ender.num_volume   
   LET p_man_comp_consumido.comprimento        = p_estoque_lote_ender.comprimento  
   LET p_man_comp_consumido.largura            = p_estoque_lote_ender.largura      
   LET p_man_comp_consumido.altura             = p_estoque_lote_ender.altura       
   LET p_man_comp_consumido.diametro           = p_estoque_lote_ender.diametro     
   LET p_man_comp_consumido.lote_componente    = p_estoque_lote_ender.num_lote    
   LET p_man_comp_consumido.local_estoque      = p_estoque_lote_ender.cod_local     
   LET p_man_comp_consumido.endereco           = p_estoque_lote_ender.endereco
   LET p_man_comp_consumido.qtd_baixa_prevista = p_qtd_prod                       
   LET p_man_comp_consumido.qtd_baixa_real     = p_qtd_prod                        
   LET p_man_comp_consumido.sit_est_componente = p_estoque_lote_ender.ies_situa_qtd
   LET p_man_comp_consumido.data_producao      = p_estoque_lote_ender.dat_hor_producao
   LET p_man_comp_consumido.data_valid         = p_estoque_lote_ender.dat_hor_validade
   LET p_man_comp_consumido.conta_ctbl         = ' '
   LET p_man_comp_consumido.moviment_estoque   = p_transac_apont
   LET p_man_comp_consumido.mov_estoque_pai    = p_transac_pai
   LET p_man_comp_consumido.seq_reg_normal     = ''
   LET p_man_comp_consumido.observacao         = p_tip_producao
   LET p_man_comp_consumido.identificacao_estoque = ''
   LET p_man_comp_consumido.depositante        = ''

   IF NOT pol1301_ins_item_consumido() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1301_ins_item_consumido()#
#------------------------------------#
   
   INSERT INTO man_comp_consumido(
     empresa,            
     seq_reg_mestre,    
     #seq_registro_item, 
     tip_movto,         
     item_componente,   
     grade_1,           
     grade_2,           
     grade_3,           
     grade_4,           
     grade_5,           
     num_peca,          
     serie,             
     volume,            
     comprimento,       
     largura,           
     altura,            
     diametro,          
     lote_componente,   
     local_estoque,     
     endereco,          
     qtd_baixa_prevista,
     qtd_baixa_real,    
     sit_est_componente,
     data_producao,     
     data_valid,        
     conta_ctbl,        
     moviment_estoque,  
     mov_estoque_pai,   
     seq_reg_normal,    
     observacao,        
     identificacao_estoque,
     depositante)
   VALUES (
     p_man_comp_consumido.empresa,                   
     p_man_comp_consumido.seq_reg_mestre,    
     #p_man_comp_consumido.seq_registro_item, 
     p_man_comp_consumido.tip_movto,         
     p_man_comp_consumido.item_componente,   
     p_man_comp_consumido.grade_1,           
     p_man_comp_consumido.grade_2,           
     p_man_comp_consumido.grade_3,           
     p_man_comp_consumido.grade_4,           
     p_man_comp_consumido.grade_5,           
     p_man_comp_consumido.num_peca,         
     p_man_comp_consumido.serie,             
     p_man_comp_consumido.volume,            
     p_man_comp_consumido.comprimento,       
     p_man_comp_consumido.largura,           
     p_man_comp_consumido.altura,            
     p_man_comp_consumido.diametro,          
     p_man_comp_consumido.lote_componente,   
     p_man_comp_consumido.local_estoque,     
     p_man_comp_consumido.endereco,          
     p_man_comp_consumido.qtd_baixa_prevista,
     p_man_comp_consumido.qtd_baixa_real,    
     p_man_comp_consumido.sit_est_componente,
     p_man_comp_consumido.data_producao,     
     p_man_comp_consumido.data_valid,        
     p_man_comp_consumido.conta_ctbl,        
     p_man_comp_consumido.moviment_estoque,  
     p_man_comp_consumido.mov_estoque_pai,   
     p_man_comp_consumido.seq_reg_normal,    
     p_man_comp_consumido.observacao,        
     p_man_comp_consumido.identificacao_estoque,
     p_man_comp_consumido.depositante)     
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','man_comp_consumido')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION


#--------------------------#
FUNCTION pol1301_estornar()#
#--------------------------#

   IF NOT m_ies_info THEN
      CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT",
             "Execute a pesquisa previamente!")
      RETURN FALSE
   END IF

   SELECT COUNT(num_processo)
      INTO m_count
      FROM processo_apont_pol1301
     WHERE cod_empresa = p_cod_empresa
       AND num_lote = m_num_lote
       AND cod_status = 'A'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','processo_apont_pol1301')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT",
             "Esse lote não possui apontamentos a estornar.")
      RETURN FALSE
   END IF

   INITIALIZE m_msg TO NULL
         
   LET m_estornar = FALSE
   LET m_row_estorno = FALSE
   CALL pol1301_sel_processo()
   
   IF NOT m_estornar THEN
      CALL log0030_mensagem("Operação cancelada.",'info') 
      RETURN FALSE
   END IF
      
   LET p_status = TRUE
   
   CALL LOG_progresspopup_start("Estornando ordens...","pol1301_proc_estorno","PROCESS")

   IF NOT p_status THEN 
      LET m_msg = 'Operação cancelada.'
   ELSE
      LET m_msg = 'Operação efetuada com sucesso.'
      CALL pol1301_atu_sdo_ops_dolote()
   END IF
   
   CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT",'')

   CALL log0030_mensagem(m_msg,'info') 
   
   RETURN p_status

END FUNCTION   

#------------------------------#
FUNCTION pol1301_sel_processo()#
#------------------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_confirma    VARCHAR(10)

    LET m_form_estorna = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_estorna,"SIZE",870,530)
    CALL _ADVPL_set_property(m_form_estorna,"TITLE","SELEÇÃO DO PROCESSO A ESTORNAR")

    LET m_bar_estorna = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_estorna)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_estorna)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
   CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirma,"EVENT","pol1301_conf_estorno")  
   CALL _ADVPL_set_property(l_confirma,"ENABLE",TRUE)  

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_estorna)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    CALL pol1301_monta_cabec(l_panel)
    CALL pol1301_monta_item(l_panel)
    
    CALL _ADVPL_set_property(m_form_estorna,"ACTIVATE",TRUE)
            
END FUNCTION

#------------------------------#
FUNCTION pol1301_conf_estorno()#
#------------------------------#
   
   DEFINE l_sel      SMALLINT
   
   LET l_sel = FALSE
      
   FOR m_ind = 1 TO m_qtd_processo
       IF ma_est_cabec[m_ind].ies_estornar = 'S' THEN
          LET l_sel = TRUE
          EXIT FOR
       END IF
   END FOR
   
   IF NOT l_sel THEN
      LET m_msg = 'Para prcessar o estorno, você precisa\n',
                  'marcar pelomenos um processo.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   LET m_msg = 'Estornar o(s) processo(s) selecuonado(s) ?'

   IF NOT LOG_question(m_msg) THEN
      RETURN FALSE
   END IF
   
   LET m_estornar = TRUE
   
   CALL _ADVPL_set_property(m_form_estorna,"ACTIVATE",FALSE)
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------------#
FUNCTION pol1301_monta_cabec(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_tabcolumn       VARCHAR(10)
    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",80)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    CALL _ADVPL_set_property(l_layout,"MAX_SIZE",400,130)

    LET m_brow_est_cab = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brow_est_cab,"ALIGN","CENTER")    
    CALL _ADVPL_set_property(m_brow_est_cab,"BEFORE_ROW_EVENT","pol1301_exibe_itens")

    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_cab)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Lote")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_lote")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_cab)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Processo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_processo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_cab)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Data geração")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LDATEFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_processo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_cab)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Hora geração")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","hor_processo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_cab)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Estornar?")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_estornar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')


    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_cab)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Usuário")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","usuario")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_cab)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brow_est_cab,"SET_ROWS",ma_est_cabec,1)

    CALL _ADVPL_set_property(m_brow_est_cab,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brow_est_cab,"CAN_REMOVE_ROW",FALSE)
    
    CALL pol1301_le_processos()
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1301_monta_item(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    #CALL _ADVPL_set_property(l_layout,"MAX_SIZE",400,130)

    LET m_brow_est_item = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brow_est_item,"ALIGN","CENTER")    
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ordem")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cent Trab")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cent_trab")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Operação")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_operac")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sequencia")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_seq_operac")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd boas")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_boas")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd refugo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_refugo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd sucata")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_sucata")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Finalçizou")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_finaliza")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_est_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brow_est_item,"SET_ROWS",ma_est_item,1)

    CALL _ADVPL_set_property(m_brow_est_item,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brow_est_item,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_brow_est_item,"EDITABLE",FALSE)
    
    CALL pol1301_le_processo_itens()
    
END FUNCTION

#-----------------------------#
FUNCTION pol1301_exibe_itens()#
#-----------------------------#

   DEFINE l_lin_atu       SMALLINT
    
   IF NOT m_row_estorno THEN
      RETURN TRUE
   END IF

   LET l_lin_atu = _ADVPL_get_property(m_brow_est_cab,"ROW_SELECTED")
      
   IF l_lin_atu > 0 THEN
      LET m_num_processo = ma_est_cabec[l_lin_atu].num_processo 
      CALL pol1301_le_processo_itens()
   END IF         
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_le_processos()#
#------------------------------#
   
   INITIALIZE ma_est_cabec TO NULL
   LET m_ind = 1
   LET m_row_estorno = TRUE
   
   DECLARE cq_processos CURSOR FOR
    SELECT num_lote, num_processo,
           dat_processo, hor_processo,
           usuario
      FROM processo_apont_pol1301
     WHERE cod_empresa = p_cod_empresa
       AND num_lote = m_num_lote
       AND cod_status = 'A'

   FOREACH cq_processos INTO
      ma_est_cabec[m_ind].num_lote,    
      ma_est_cabec[m_ind].num_processo,
      ma_est_cabec[m_ind].dat_processo,
      ma_est_cabec[m_ind].hor_processo,
      ma_est_cabec[m_ind].usuario

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','processo_apont_pol1301:cq_processos')
         EXIT FOREACH
      END IF
      
      LET ma_est_cabec[m_ind].ies_estornar = 'N'
      LET m_ind = m_ind + 1
      
      IF m_ind > 1000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   LET m_qtd_processo = m_ind - 1
    
   IF m_qtd_processo > 0 THEN
      LET m_num_processo = ma_est_cabec[1].num_processo   
   ELSE  
      LET m_num_processo = 0
   END IF

   CALL _ADVPL_set_property(m_brow_est_cab,"ITEM_COUNT", m_qtd_processo)

END FUNCTION
           
#-----------------------------------#           
FUNCTION pol1301_le_processo_itens()#
#-----------------------------------#
   
   DEFINE l_qtd_itens     INTEGER
   
   INITIALIZE ma_est_item TO NULL
   CALL _ADVPL_set_property(m_brow_est_item,"CLEAR")
   LET m_ind = 1
    
   DECLARE cq_proces_item CURSOR FOR
    SELECT num_ordem,        
           cod_item,      
           cod_cent_trab, 
           cod_operac,    
           num_seq_operac,
           qtd_boas,      
           qtd_refugo,    
           qtd_sucata,    
           ies_finaliza      
      FROM processo_item_pol1301
     WHERE cod_empresa = p_cod_empresa
       AND num_processo = m_num_processo
     ORDER BY num_ordem
     
   FOREACH cq_proces_item INTO
      ma_est_item[m_ind].num_ordem,     
      ma_est_item[m_ind].cod_item,      
      ma_est_item[m_ind].cod_cent_trab, 
      ma_est_item[m_ind].cod_operac,    
      ma_est_item[m_ind].num_seq_operac,
      ma_est_item[m_ind].qtd_boas,      
      ma_est_item[m_ind].qtd_refugo,    
      ma_est_item[m_ind].qtd_sucata,    
      ma_est_item[m_ind].ies_finaliza  

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','processo_item_pol1301:cq_proces_item')
         EXIT FOREACH
      END IF
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 1000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   LET l_qtd_itens = m_ind - 1
    
   CALL _ADVPL_set_property(m_brow_est_item,"ITEM_COUNT", l_qtd_itens)

END FUNCTION

#------------------------------#
FUNCTION pol1301_proc_estorno()#
#------------------------------#

   LET m_dat_atu = TODAY
   LET m_hor_atu = TIME
   
   LET m_criticou = FALSE
   LET m_qtd_erro = 0
   INITIALIZE mr_erro_est TO NULL
   
   IF NOT pol1301_le_par_estoque() THEN
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")
   
   IF NOT pol1301_le_array_estorno() THEN
      CALL log085_transacao("ROLLBACK")
      LET p_status = FALSE
   ELSE
      CALL log085_transacao("COMMIT")
      LET p_status = TRUE
   END IF
   
END FUNCTION

#----------------------------------#
FUNCTION pol1301_le_array_estorno()#
#----------------------------------#
   
   FOR m_ind = 1 TO m_qtd_processo
       IF ma_est_cabec[m_ind].ies_estornar = 'S' THEN
          LET m_num_processo = ma_est_cabec[m_ind].num_processo
          IF NOT pol1301_revert_apon() THEN
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1301_revert_apon()#
#-----------------------------#

   DECLARE cq_aptos CURSOR FOR
    SELECT * 
      FROM man_apont_pol1301
     WHERE cod_empresa  = p_cod_empresa
       AND num_processo = m_num_processo
       AND cod_status   = 'A'
     ORDER BY num_seq_apont DESC

   FOREACH cq_aptos INTO p_man.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','man_apont_pol1301:cq_man')
         RETURN FALSE
      END IF                                           

      SELECT ies_situa,
             dat_ini,
             (qtd_boas + qtd_refug + qtd_sucata)
        INTO p_ies_situa,
             p_dat_inicio,
             p_qtd_ordem
        FROM ordens
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem = p_man.num_ordem        

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordens:cq_aptos')
         RETURN FALSE
      END IF
   
      IF p_ies_situa = '4' THEN
      ELSE
         LET p_seq_txt = p_man.num_ordem        
         LET p_msg = 'ORDEM ', p_seq_txt CLIPPED, 
                     ' NAO ESTA LIBERADA'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF

      LET p_num_seq_apont = p_man.num_seq_apont
      LET p_qtd_apont = p_man.qtd_refugo + p_man.qtd_sucata
      
      IF p_man.oper_final = 'S' THEN
         LET p_qtd_apont = p_qtd_apont + p_man.qtd_boas
      ELSE
         LET p_man.qtd_boas = 0
      END IF
      
      IF p_qtd_apont >= p_qtd_ordem THEN
         LET p_dat_inicio = NULL
      END IF
      
      IF NOT pol1301_estorna_aponts() THEN
         RETURN FALSE
      END IF
      
      IF p_qtd_apont > 0 THEN
         IF NOT pol1301_estorna_ordem() THEN
            RETURN FALSE
         END IF
      END IF
      
      IF NOT pol1301_estorna_movtos() THEN
         RETURN FALSE
      END IF

   END FOREACH
   
   UPDATE processo_apont_pol1301
      SET cod_status = 'E'
    WHERE cod_empresa = p_cod_empresa
      AND num_processo = m_num_processo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','processo_apont_pol1301')
      RETURN FALSE
   END IF

   UPDATE man_apont_pol1301
      SET cod_status = 'E'
    WHERE cod_empresa = p_cod_empresa
      AND num_processo = m_num_processo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','man_apont_pol1301')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION      

#--------------------------------#
FUNCTION pol1301_estorna_aponts()#
#--------------------------------#
   
   DECLARE cq_sequenc CURSOR FOR
    SELECT seq_apo_oper,  
           seq_apo_mestre
      FROM sequencia_apo_pol1301
     WHERE cod_empresa   = p_cod_empresa
       AND num_processo  = m_num_processo
       AND num_seq_apont = p_num_seq_apont

   FOREACH cq_sequenc INTO p_num_seq_reg, p_seq_reg_mestre

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','sequencia_apo_pol1301:cq_sequenc')
         RETURN FALSE
      END IF                                           

      IF NOT pol1301_checa_apont() THEN
         RETURN FALSE
      END IF       
      
      IF NOT pol1301_estorna_novas() THEN
         RETURN FALSE
      END IF       

      IF NOT pol1301_estorna_velhas() THEN
         RETURN FALSE
      END IF       
   
   END FOREACH

   IF p_man.num_seq_operac IS NOT NULL THEN
      
      UPDATE ord_oper
         SET qtd_boas   = qtd_boas - p_man.qtd_boas,
             qtd_refugo = qtd_refugo - p_man.qtd_refugo,
             qtd_sucata = qtd_sucata - p_man.qtd_sucata,
             ies_apontamento = 'S'
       WHERE cod_empresa    = p_cod_empresa
	       AND num_ordem      = p_man.num_ordem
	       AND cod_operac     = p_man.cod_operac
	       AND num_seq_operac = p_man.num_seq_operac

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','ORD_OPER')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION pol1301_erro_estorno()
#------------------------------#

   LET m_criticou = TRUE

   LET m_qtd_erro = m_qtd_erro + 1
   LET mr_erro_est [m_qtd_erro].den_erro = m_msg
      
END FUNCTION

#-----------------------------#
FUNCTION pol1301_checa_apont()#
#-----------------------------#

   SELECT empresa
     FROM man_apo_mestre
    WHERE empresa = p_cod_empresa
      AND seq_reg_mestre = p_seq_reg_mestre

   IF STATUS = 100 THEN   
      LET p_seq_txt = p_seq_reg_mestre
      LET m_msg = 'APONTAMENTO DE SEQUENCIA ', p_seq_txt CLIPPED, 
                  ' NAO ENCONTRADO NA TAB MAN_APO_MESTRE'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','MAN_APO_MESTRE')
         RETURN FALSE
      END IF
   END IF

   SELECT cod_empresa
     FROM apo_oper
    WHERE cod_empresa = p_cod_empresa
      AND num_processo = p_num_seq_reg

   IF STATUS = 100 THEN   
      LET p_seq_txt = p_num_seq_reg
      LET m_msg = 'APONTAMENTO DE SEQUENCIA ', p_seq_txt CLIPPED, 
                  ' NAO ENCONTRADO NA TAB APO_OPER'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','APO_OPER')
         RETURN FALSE
      END IF
   END IF
   
   IF p_man.num_seq_operac IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT qtd_boas + qtd_refugo + qtd_sucata
     INTO p_qtd_oper
     FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.num_ordem
	    AND cod_operac     = p_man.cod_operac
	    AND num_seq_operac = p_man.num_seq_operac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ord_oper')
      RETURN FALSE
   END IF
   
   LET p_qtd_estorno = p_man.qtd_boas + p_man.qtd_refugo + p_man.qtd_sucata 
   
   IF p_qtd_estorno > p_qtd_oper THEN
      LET p_seq_txt = p_man.num_ordem  
      LET p_seq_txt = p_seq_txt CLIPPED, '/', p_man.cod_operac
      LET p_msg = 'ORDEM/OPERACAO ', p_seq_txt CLIPPED, 
                  ' - QTD APONTADA MENOR QUE QTD A ESTORNAR'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1301_estorna_novas()#
#-------------------------------#
   
   UPDATE man_apo_mestre 
      SET sit_apontamento = 'C',
          tip_moviment = 'E',
          usuario_estorno = p_user,
          data_estorno = m_dat_atu,
          hor_estorno = m_hor_atu
    WHERE empresa = p_cod_empresa
      AND seq_reg_mestre = p_seq_reg_mestre

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','MAN_APO_MESTRE')
      RETURN FALSE
   END IF

   DECLARE cq_est_produzido CURSOR FOR
    SELECT * 
      FROM man_item_produzido
     WHERE empresa = p_cod_empresa
       AND seq_reg_mestre = p_seq_reg_mestre
   
   FOREACH cq_est_produzido INTO p_man_item_produzido.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_est_produzido')
         RETURN FALSE
      END IF

      LET p_man_item_produzido.tip_movto = 'E'
      LET p_man_item_produzido.seq_registro_item     = 0 #campo serial
   
      IF NOT pol1301_ins_item_produzido() THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   DECLARE cq_consumo CURSOR FOR
    SELECT * 
      FROM man_comp_consumido
     WHERE empresa = p_cod_empresa
       AND seq_reg_mestre = p_seq_reg_mestre
   
   FOREACH cq_consumo  INTO p_man_comp_consumido.*   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_CONSUMO')
         RETURN FALSE
      END IF

      LET p_man_comp_consumido.tip_movto = 'E'
      LET p_man_comp_consumido.seq_registro_item = 0 #campo serial
   
      IF NOT pol1301_ins_item_consumido() THEN
         RETURN FALSE
      END IF
   
   END FOREACH

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1301_estorna_velhas()#
#--------------------------------#
   
   UPDATE apo_oper
      SET cod_tip_movto = 'E'
    WHERE cod_empresa  = p_cod_empresa
      AND num_processo = p_num_seq_reg

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','APO_OPER')
      RETURN FALSE
   END IF

   UPDATE cfp_apms 
      SET cod_tip_movto = 'E',
          ies_situa = 'C', 
          dat_estorno = m_dat_atu,
          hor_estorno = m_hor_atu,
          nom_usu_estorno = p_user
    WHERE cod_empresa      = p_cod_empresa
      AND num_seq_registro = p_num_seq_reg

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','CFP_APMS')
      RETURN FALSE
   END IF

   UPDATE chf_componente
      SET tip_movto = 'R'
    WHERE empresa            = p_cod_empresa
      AND sequencia_registro = p_num_seq_reg

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','CHF_COMPONENTE')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1301_estorna_ordem()#
#-------------------------------#

   UPDATE ordens
      SET qtd_boas = qtd_boas - p_man.qtd_boas,
          qtd_refug = qtd_refug - p_man.qtd_refugo,
          qtd_sucata = qtd_sucata - p_man.qtd_sucata,
          dat_ini = p_dat_inicio
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_man.num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ORDENS')
      RETURN FALSE
   END IF

   DECLARE cq_neces CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           cod_item_pai
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_man.num_ordem

   FOREACH cq_neces INTO 
           p_cod_compon, 
           p_qtd_necessaria,
           p_num_neces

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_neces')
         RETURN FALSE
      END IF  

      LET p_qtd_baixar = p_qtd_necessaria * p_qtd_apont

      IF NOT pol1301_le_item_man() THEN
         RETURN FALSE
      END IF
      
      IF p_ies_tip_item MATCHES '[T]' OR 
         p_ies_ctr_estoque = 'N'      OR
         p_sofre_baixa = 'N'        THEN
         CONTINUE FOREACH
      END IF

      UPDATE necessidades
         SET qtd_saida = qtd_saida - p_qtd_baixar
       WHERE cod_empresa = p_cod_empresa
         AND num_neces   = p_num_neces

      IF STATUS <> 0 THEN
         CALL log003_err_sql('update','necessidades')
         RETURN FALSE
      END IF  
         
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1301_estorna_movtos()#
#--------------------------------#

   LET p_tip_operac = 'E'
   LET p_ies_tip_movto = 'R'
   
   DECLARE cq_trans_e CURSOR FOR
    SELECT num_transac
      FROM trans_apont_pol1301
     WHERE cod_empresa = p_cod_empresa
       AND num_processo = m_num_processo
       AND cod_operacao = 'E'
       AND num_seq_apont = p_num_seq_apont
   
   FOREACH cq_trans_e INTO p_num_transac
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','trans_apont_pol1301:cq_trans_e') 
         RETURN FALSE
      END IF

      IF NOT pol1301_eh_possivel() THEN
         RETURN FALSE
      END IF
            
      IF NOT pol1301_estorna_estoq() THEN
         RETURN FALSE
      END IF
   
   END FOREACH

   LET p_tip_operac = 'S'
   
   DECLARE cq_trans_s CURSOR FOR
    SELECT num_transac
      FROM trans_apont_pol1301
     WHERE cod_empresa = p_cod_empresa
       AND num_processo = m_num_processo
       AND cod_operacao = 'S'
       AND num_seq_apont = p_num_seq_apont
   
   FOREACH cq_trans_s INTO p_num_transac
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','trans_apont_pol1301:cq_trans_s') 
         RETURN FALSE
      END IF
            
      IF NOT pol1301_estorna_estoq() THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1301_eh_possivel()#
#-----------------------------#
         
   SELECT cod_item, 
          dat_movto,
          qtd_movto,
          cod_local_est_dest,
          num_lote_dest,
          ies_sit_est_dest
     INTO p_cod_item,
          p_dat_movto,
          p_qtd_movto,
          p_cod_local_estoq,
          p_num_lote,
          p_ies_situa
     FROM estoque_trans 
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_trans')
      RETURN FALSE
   END IF

   SELECT largura,
          altura,
          diametro,
          comprimento
     INTO p_largura,
          p_altura,
          p_diametro,
          p_comprimento
     FROM estoque_trans_end
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ESTOQUE_TRANS_END')
      RETURN FALSE
   END IF

   IF NOT pol1301_chek_estoque() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION                

#-----------------------------#
FUNCTION pol1301_chek_estoque()
#-----------------------------#

   IF p_dat_fecha_ult_man IS NOT NULL THEN
      IF p_dat_movto <= p_dat_fecha_ult_man THEN
         LET m_msg = 'A DATA DA PRODUCAO EH MENOR QUE A DATA DO FECHEMENTO DA MANUFATURA'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
   END IF

   IF p_dat_fecha_ult_sup IS NOT NULL THEN
      IF p_dat_movto < p_dat_fecha_ult_sup THEN
         LET m_msg = 'A DATA DA PRODUCAO EH MENOR QUE A DATA DO FECHEMENTO DO ESTOQUE'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
   END IF
   
   CALL pol1301_le_ender()
   
   IF STATUS = 100 THEN
      LET p_qtd_saldo = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ESTOQUE_LOTE_ENDER')
         RETURN FALSE
      END IF
   END IF  
   
   IF p_num_lote IS NULL THEN
      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada 
        FROM estoque_loc_reser
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
         AND cod_local   = p_cod_local_estoq
         AND num_lote IS NULL
   ELSE
      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada 
        FROM estoque_loc_reser
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
         AND cod_local   = p_cod_local_estoq
         AND num_lote = p_num_lote
   END IF
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_loc_reser')
      RETURN FALSE
   END IF  

   IF p_qtd_saldo IS NULL OR p_qtd_saldo < 0 THEN
      LET p_qtd_saldo = 0
   END IF
   
   IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
      LET p_qtd_reservada = 0
   END IF

   IF p_qtd_saldo > p_qtd_reservada THEN
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
   ELSE
      LET p_qtd_saldo = 0
   END IF

   IF p_qtd_saldo < p_qtd_movto THEN  
      LET m_msg = 'Item:', p_cod_item CLIPPED, '\n',
                  'Lote:', p_num_lote CLIPPED, '\n',
                  'Tabela: estoque_lote_ender \n',
                  'Não a salado p/ estornar'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   CALL pol1301_le_estok_lote()

   IF STATUS = 100 THEN
      LET p_qtd_saldo = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ESTOQUE_LOTE')
         RETURN FALSE
      END IF
   END IF  

   IF p_qtd_saldo IS NULL OR p_qtd_saldo < 0 THEN
      LET p_qtd_saldo = 0
   END IF
   
   IF p_qtd_saldo > p_qtd_reservada THEN
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
   ELSE
      LET p_qtd_saldo = 0
   END IF

   IF p_qtd_saldo < p_qtd_movto THEN   
      LET m_msg = 'Item:', p_cod_item CLIPPED, '\n',
                  'Lote:', p_num_lote CLIPPED, '\n',
                  'Tabela: estoque_lote \n',
                  'Não a salado p/ estornar'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1301_le_ender()#
#--------------------------#

   IF p_num_lote IS NULL THEN
    	SELECT qtd_saldo,
    	       num_transac
		    INTO p_qtd_saldo,
		         p_trans_ender
		    FROM estoque_lote_ender
		   WHERE cod_empresa   = p_cod_empresa
		     AND cod_item      = p_cod_item
		     AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa
         AND largura       = p_largura
         AND altura        = p_altura        
         AND diametro      = p_diametro      
         AND comprimento   = p_comprimento    
         AND num_lote IS NULL
   ELSE
    	SELECT qtd_saldo,
    	       num_transac
		    INTO p_qtd_saldo,
		         p_trans_ender
		    FROM estoque_lote_ender
		   WHERE cod_empresa   = p_cod_empresa
		     AND cod_item      = p_cod_item
		     AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa
         AND largura       = p_largura
         AND altura        = p_altura        
         AND diametro      = p_diametro      
         AND comprimento   = p_comprimento    
         AND num_lote      = p_num_lote
   END IF

END FUNCTION

#-------------------------------#
FUNCTION pol1301_le_estok_lote()#
#-------------------------------#

   IF p_num_lote IS NULL THEN
    	SELECT qtd_saldo,
    	       num_transac
		    INTO p_qtd_saldo,
		         p_trans_lote
		    FROM estoque_lote
		   WHERE cod_empresa   = p_cod_empresa
		     AND cod_item      = p_cod_item
		     AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa
         AND num_lote IS NULL
   ELSE
    	SELECT qtd_saldo,
    	       num_transac
		    INTO p_qtd_saldo,
		         p_trans_lote
		    FROM estoque_lote
		   WHERE cod_empresa   = p_cod_empresa
		     AND cod_item      = p_cod_item
		     AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa
         AND num_lote = p_num_lote
   END IF

END FUNCTION
   
#-------------------------------#
FUNCTION pol1301_estorna_estoq()#
#-------------------------------#

   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01)
   END RECORD
   
   SELECT *
     INTO p_estoque_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_trans')
      RETURN FALSE
   END IF
      
   LET p_item.cod_empresa   = p_estoque_trans.cod_empresa
   LET p_item.cod_item      = p_estoque_trans.cod_item
   LET p_item.cod_operacao  = p_estoque_trans.cod_operacao
   LET p_item.qtd_movto     = p_estoque_trans.qtd_movto   
   LET p_item.dat_movto     = p_estoque_trans.dat_movto   
   LET p_item.num_prog      = p_estoque_trans.num_prog 
   LET p_item.num_docum     = p_estoque_trans.num_docum
   LET p_item.num_seq       = p_estoque_trans.num_seq  
   LET p_item.trans_origem  = p_estoque_trans.num_transac
      
   IF p_tip_operac = 'S' THEN
      LET p_item.cod_local     = p_estoque_trans.cod_local_est_orig
      LET p_item.num_lote      = p_estoque_trans.num_lote_orig
      LET p_item.ies_situa     = p_estoque_trans.ies_sit_est_orig
   ELSE
      LET p_item.cod_local     = p_estoque_trans.cod_local_est_dest
      LET p_item.num_lote      = p_estoque_trans.num_lote_dest
      LET p_item.ies_situa     = p_estoque_trans.ies_sit_est_dest  
   END IF

   SELECT comprimento,
          largura,    
          altura,     
          diametro   
     INTO p_item.comprimento,  
          p_item.largura,      
          p_item.altura,       
          p_item.diametro     
     FROM estoque_trans_end
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ESTOQUE_TRANS_END'  
      RETURN FALSE
   END IF
      
   LET p_item.tip_operacao  = p_tip_operac
   LET p_item.ies_tip_movto = p_ies_tip_movto
   LET p_item.dat_proces    = TODAY
   LET p_item.hor_operac    = TIME 
   LET p_item.usuario       = p_man.nom_usuario
   LET p_item.cod_turno     = p_man.cod_turno
   
   IF p_item.num_lote IS NULL OR
         p_item.num_lote = ' ' OR LENGTH(p_item.num_lote) = 0 THEN
      LET p_item.num_lote = NULL
      LET p_item.ies_ctr_lote  = 'N'
   ELSE
      LET p_item.ies_ctr_lote  = 'S'
   END IF
      
   IF NOT estoque_insere_movto(p_item) THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION




      

#----ROTINAS PARA ATUALIZAÇÃO DE ESTOQUE-------#

#------------------------------------#
FUNCTION estoque_insere_movto(p_item)#
#------------------------------------#

#---parâmetros recebidos com visibilidade local

   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01)
  END RECORD

   LET p_msg = ''
      
   LET p_movto.* = p_item.*

   CASE p_movto.tip_operacao
      WHEN 'E' #entrada
         IF p_movto.ies_tip_movto = 'N' THEN
            LET p_ies_estoque = 'E'
            IF NOT estoque_grava_entrada() THEN
               RETURN FALSE
            END IF
         ELSE
            LET p_ies_estoque = 'S'
            IF NOT estoque_reverte_entrada() THEN
               RETURN FALSE
            END IF
         END IF
      WHEN 'S' #saida
         IF p_movto.ies_tip_movto = 'N' THEN
            LET p_ies_estoque = 'S'
            IF NOT estoque_grava_saida() THEN
               RETURN FALSE
            END IF
         ELSE
            LET p_ies_estoque = 'E'
            IF NOT estoque_reverte_saida() THEN
               RETURN FALSE
            END IF
         END IF

   END CASE

   IF NOT estoque_atu_estoque() THEN
      RETURN FALSE
   END IF
   
   DELETE FROM estoque_lote 
    WHERE cod_empresa = p_movto.cod_empresa
      AND qtd_saldo <= 0

   DELETE FROM estoque_lote_ender 
    WHERE cod_empresa = p_movto.cod_empresa
      AND qtd_saldo <= 0
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION estoque_atu_estoque()#
#-----------------------------#

   DEFINE p_qtd_liberada       DECIMAL(10,3),
          p_qtd_lib_excep      DECIMAL(10,3),
          p_qtd_rejeitada      DECIMAL(10,3),
          p_qtd_impedida       DECIMAL(10,3)

   SELECT SUM(qtd_saldo) 
     INTO p_qtd_liberada
     FROM estoque_lote_ender
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item
      AND ies_situa_qtd = 'L' 
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, 
                  ' SOMANDO SALDO LIBERADO DA TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF
   
   IF p_qtd_liberada IS NULL THEN
      LET p_qtd_liberada = 0
   END IF

   SELECT SUM(qtd_saldo) 
     INTO p_qtd_lib_excep
     FROM estoque_lote_ender
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item
      AND ies_situa_qtd = 'E' 
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, 
                  ' SOMANDO SALDO LIBERADO EXCEPCIONAL DA TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF
   
   IF p_qtd_lib_excep IS NULL THEN
      LET p_qtd_lib_excep = 0
   END IF

   SELECT SUM(qtd_saldo) 
     INTO p_qtd_rejeitada
     FROM estoque_lote_ender
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item
      AND ies_situa_qtd = 'R' 
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, 
                  ' SOMANDO SALDO REJEITADO DA TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF
   
   IF p_qtd_rejeitada IS NULL THEN
      LET p_qtd_rejeitada = 0
   END IF

   SELECT SUM(qtd_saldo) 
     INTO p_qtd_impedida
     FROM estoque_lote_ender
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item
      AND ies_situa_qtd = 'I' 
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, 
                  ' SOMANDO SALDO IMPEDIDO DA TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF
   
   IF p_qtd_impedida IS NULL THEN
      LET p_qtd_impedida = 0
   END IF
   
   UPDATE estoque
      SET qtd_liberada = p_qtd_liberada,
          qtd_lib_excep = p_qtd_lib_excep,
          qtd_rejeitada = p_qtd_rejeitada,
          qtd_impedida  = p_qtd_impedida
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item
     
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' ATUALIZANDO SALDO DA TABELA ESTOQUE'  
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION estoque_grava_entrada()#
#-------------------------------#

   IF NOT estoque_gra_lote() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_lot_ender() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoque() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_auditoria() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION estoque_gra_lote()#
#--------------------------#

   CALL estoque_le_lote()
      
   IF STATUS = 100 THEN
      IF NOT estoque_ins_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 0 THEN
         IF NOT estoque_atu_lote(p_movto.qtd_movto) THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO ESTOQUE_LOTE.'  
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION estoque_le_lote()#
#-------------------------#
      
   IF p_movto.ies_ctr_lote = 'S' THEN
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa = p_movto.cod_empresa
         AND cod_item = p_movto.cod_item
         AND cod_local = p_movto.cod_local
         AND ies_situa_qtd = p_movto.ies_situa
         AND num_lote = p_movto.num_lote 
   ELSE
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa = p_movto.cod_empresa
         AND cod_item = p_movto.cod_item
         AND cod_local = p_movto.cod_local
         AND ies_situa_qtd = p_movto.ies_situa
         AND (num_lote IS NULL OR num_lote = ' ')
   END IF   

END FUNCTION

#--------------------------#
FUNCTION estoque_ins_lote()#
#--------------------------#

   INSERT INTO estoque_lote(
          cod_empresa, 
          cod_item, 
          cod_local, 
          num_lote, 
          ies_situa_qtd, 
          qtd_saldo)  
          VALUES(p_movto.cod_empresa,
                 p_movto.cod_item,
                 p_movto.cod_local,
                 p_movto.num_lote,
                 p_movto.ies_situa,
                 p_movto.qtd_movto)
                 
   IF STATUS <> 0 THEN
     LET p_erro = STATUS
     LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ESTOQUE_LOTE.'  
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
         
#-------------------------------------#
FUNCTION estoque_atu_lote(p_qtd_movto)#
#-------------------------------------#
   
   DEFINE p_qtd_movto DECIMAL(10,3),
          p_qtd_saldo DECIMAL(10,3),
          p_saldo     DECIMAL(10,3)

   IF p_qtd_movto < 0 THEN
      SELECT qtd_saldo
        INTO p_qtd_saldo
        FROM estoque_lote
       WHERE cod_empresa = p_movto.cod_empresa
         AND num_transac = p_num_transac

      IF STATUS <> 0 THEN
        LET p_erro = STATUS
        LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO ESTOQUE_LOTE.'  
        RETURN FALSE
      END IF
      
      LET p_saldo = p_qtd_movto * (-1)
      
      IF p_qtd_saldo < p_saldo THEN
         LET p_msg = 'TABELA ESTOQUE_LOTE SEM SALDO PARA BAIXAR'  
         RETURN FALSE
      END IF
   END IF
   
   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_movto.cod_empresa
      AND num_transac = p_num_transac
                 
   IF STATUS <> 0 THEN
     LET p_erro = STATUS
     LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO ESTOQUE_LOTE.'  
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
         
#-------------------------------#
FUNCTION estoque_gra_lot_ender()#
#-------------------------------#
      
   CALL estoque_le_lot_ender()
      
   IF STATUS = 100 THEN
      IF NOT estoque_ins_lote_ender() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 0 THEN
         LET p_num_transac = p_estoque_lote_ender.num_transac
         IF NOT estoque_atu_lote_ender(p_movto.qtd_movto) THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO ESTOQUE_LOTE_ENDER'  
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION estoque_le_lot_ender()#
#------------------------------#

   IF p_movto.ies_ctr_lote = 'S' THEN
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa = p_movto.cod_empresa
         AND cod_item = p_movto.cod_item
         AND cod_local = p_movto.cod_local
         AND ies_situa_qtd = p_movto.ies_situa
         AND comprimento = p_movto.comprimento
         AND largura = p_movto.largura
         AND altura = p_movto.altura
         AND diametro = p_movto.diametro
         AND num_lote = p_movto.num_lote 
   ELSE
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa = p_movto.cod_empresa
         AND cod_item = p_movto.cod_item
         AND cod_local = p_movto.cod_local
         AND ies_situa_qtd = p_movto.ies_situa
         AND comprimento = p_movto.comprimento
         AND largura = p_movto.largura
         AND altura = p_movto.altura
         AND diametro = p_movto.diametro
         AND (num_lote IS NULL OR num_lote = ' ')
   END IF
   
END FUNCTION

#--------------------------------#
FUNCTION estoque_ins_lote_ender()#
#--------------------------------#

   CALL estoque_carrega_campos() 

   INSERT INTO estoque_lote_ender(
          cod_empresa,
          cod_item,
          cod_local,
          num_lote,
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
          ies_situa_qtd,
          qtd_saldo,
          ies_origem_entrada,
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
          tex_reservado) 
          VALUES(p_estoque_lote_ender.cod_empresa,
                 p_estoque_lote_ender.cod_item,
                 p_estoque_lote_ender.cod_local,
                 p_estoque_lote_ender.num_lote,
                 p_estoque_lote_ender.endereco,
                 p_estoque_lote_ender.num_volume,
                 p_estoque_lote_ender.cod_grade_1,
                 p_estoque_lote_ender.cod_grade_2,
                 p_estoque_lote_ender.cod_grade_3,
                 p_estoque_lote_ender.cod_grade_4,
                 p_estoque_lote_ender.cod_grade_5,
                 p_estoque_lote_ender.dat_hor_producao,
                 p_estoque_lote_ender.num_ped_ven,
                 p_estoque_lote_ender.num_seq_ped_ven,
                 p_estoque_lote_ender.ies_situa_qtd,
                 p_estoque_lote_ender.qtd_saldo,
                 p_estoque_lote_ender.ies_origem_entrada,
                 p_estoque_lote_ender.dat_hor_validade,
                 p_estoque_lote_ender.num_peca,
                 p_estoque_lote_ender.num_serie,
                 p_estoque_lote_ender.comprimento,
                 p_estoque_lote_ender.largura,
                 p_estoque_lote_ender.altura,
                 p_estoque_lote_ender.diametro,
                 p_estoque_lote_ender.dat_hor_reserv_1,
                 p_estoque_lote_ender.dat_hor_reserv_2,
                 p_estoque_lote_ender.dat_hor_reserv_3,
                 p_estoque_lote_ender.qtd_reserv_1,
                 p_estoque_lote_ender.qtd_reserv_2,
                 p_estoque_lote_ender.qtd_reserv_3,
                 p_estoque_lote_ender.num_reserv_1,
                 p_estoque_lote_ender.num_reserv_2,
                 p_estoque_lote_ender.num_reserv_3,
                 p_estoque_lote_ender.tex_reservado)
              
   IF STATUS <> 0 THEN
     LET p_erro = STATUS
     LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ESTOQUE_LOTE_ENDER.'  
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION estoque_carrega_campos()
#-------------------------------#
   
   INITIALIZE p_estoque_lote_ender TO NULL
   
   LET p_estoque_lote_ender.cod_empresa        = p_movto.cod_empresa
	 LET p_estoque_lote_ender.cod_item           = p_movto.cod_item 
	 LET p_estoque_lote_ender.cod_local          = p_movto.cod_local
	 LET p_estoque_lote_ender.num_lote           = p_movto.num_lote
	 LET p_estoque_lote_ender.ies_situa_qtd      = p_movto.ies_situa
	 LET p_estoque_lote_ender.qtd_saldo          = p_movto.qtd_movto
   LET p_estoque_lote_ender.largura            = p_movto.largura
   LET p_estoque_lote_ender.altura             = p_movto.altura
   LET p_estoque_lote_ender.diametro           = p_movto.diametro
   LET p_estoque_lote_ender.comprimento        = p_movto.comprimento
   LET p_estoque_lote_ender.dat_hor_producao   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_validade   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_1   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_2   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_3   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.num_serie          = ' '
   LET p_estoque_lote_ender.endereco           = ' '
   LET p_estoque_lote_ender.num_volume         = '0'
   LET p_estoque_lote_ender.cod_grade_1        = ' '
   LET p_estoque_lote_ender.cod_grade_2        = ' '
   LET p_estoque_lote_ender.cod_grade_3        = ' '
   LET p_estoque_lote_ender.cod_grade_4        = ' '
   LET p_estoque_lote_ender.cod_grade_5        = ' '
   LET p_estoque_lote_ender.num_ped_ven        = 0
   LET p_estoque_lote_ender.num_seq_ped_ven    = 0
   LET p_estoque_lote_ender.ies_origem_entrada = ' '
   LET p_estoque_lote_ender.num_peca           = ' '
   LET p_estoque_lote_ender.qtd_reserv_1       = 0
   LET p_estoque_lote_ender.qtd_reserv_2       = 0
   LET p_estoque_lote_ender.qtd_reserv_3       = 0
   LET p_estoque_lote_ender.num_reserv_1       = 0
   LET p_estoque_lote_ender.num_reserv_2       = 0
   LET p_estoque_lote_ender.num_reserv_3       = 0
   LET p_estoque_lote_ender.tex_reservado      = ' '
   
END FUNCTION
         
#-------------------------------------------#
FUNCTION estoque_atu_lote_ender(p_qtd_movto)#
#-------------------------------------------#

   DEFINE p_qtd_movto DECIMAL(10,3),
          p_qtd_saldo DECIMAL(10,3),
          p_saldo     DECIMAL(10,3)
   
   IF p_qtd_movto < 0 THEN
      SELECT qtd_saldo
        INTO p_qtd_saldo
        FROM estoque_lote_ender
       WHERE cod_empresa = p_movto.cod_empresa
         AND num_transac = p_num_transac

      IF STATUS <> 0 THEN
        LET p_erro = STATUS
        LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO ESTOQUE_LOTE_ENDER.'  
        RETURN FALSE
      END IF
      
      LET p_saldo = p_qtd_movto * (-1)

      IF p_qtd_saldo < p_saldo THEN
         LET p_msg = 'TABELA ESTOQUE_LOTE_ENDER SEM SALDO PARA BAIXAR'  
         RETURN FALSE
      END IF
   END IF
   
   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_movto.cod_empresa
      AND num_transac = p_num_transac
                 
   IF STATUS <> 0 THEN
     LET p_erro = STATUS
     LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO ESTOQUE_LOTE_ENDER.'  
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
         
#-----------------------------#         
FUNCTION estoque_gra_estoque()#
#-----------------------------#
   
   DEFINE p_qtd_estoq      DECIMAL(10,3)
   DEFINE p_estoque record LIKE estoque.*
   
   SELECT *
     INTO p_estoque.*
     FROM estoque
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item

   IF STATUS = 100 THEN
      INITIALIZE p_estoque.* TO NULL
      LET p_estoque.cod_empresa = p_movto.cod_empresa
      LET p_estoque.cod_item = p_movto.cod_item
      LET p_estoque.qtd_liberada  = 0
      LET p_estoque.qtd_impedida  = 0
      LET p_estoque.qtd_rejeitada = 0
      LET p_estoque.qtd_lib_excep = 0
      LET p_estoque.qtd_disp_venda = 0
      LET p_estoque.qtd_reservada = 0
      
      INSERT INTO estoque
       VALUES(p_estoque.*)
      
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ESTOQUE.'  
         RETURN FALSE
      END IF   
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO TABELA ESTOQUE.'  
         RETURN FALSE
      END IF   
   END IF
   
   IF p_ies_estoque = 'S' THEN
      LET p_estoque.dat_ult_saida = p_movto.dat_movto
   ELSE
      LET p_estoque.dat_ult_entrada = p_movto.dat_movto
   END IF
         
   UPDATE estoque
      SET dat_ult_entrada = p_estoque.dat_ult_entrada,
          dat_ult_saida   = p_estoque.dat_ult_saida
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO TABELA ESTOQUE.'  
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION estoque_gra_estoq_trans()#
#---------------------------------#

   DEFINE p_ies_com_detalhe CHAR(01),
          p_num_conta       CHAR(20)

   INITIALIZE p_estoque_trans.* TO NULL      
                                                                                       
   SELECT ies_com_detalhe                                                                                     
     INTO p_ies_com_detalhe                                                                                   
     FROM estoque_operac                                                                                      
    WHERE cod_empresa  = p_movto.cod_empresa                                                                        
      AND cod_operacao = p_movto.cod_operacao                                                                       
                                                                                                                 
   IF STATUS <> 0 THEN   
      LET p_erro =  STATUS                                                                                     
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_OPERAC - OPER:',p_movto.cod_operacao
      RETURN FALSE                                                                                             
   END IF                                                                                                     
                                                                                                                 
   IF p_ies_com_detalhe = 'S' THEN                                                                            
      IF p_movto.tip_operacao = 'S' THEN        #operação de saida                                                                        
         SELECT num_conta_debito                                                                           
           INTO p_num_conta                                                                                
           FROM estoque_operac_ct                                                                          
          WHERE cod_empresa  = p_movto.cod_empresa                                                               
            AND cod_operacao = p_movto.cod_operacao                                                              
      ELSE                                                                                                    
         SELECT num_conta_credito                                                                             
           INTO p_num_conta                                                                                  
           FROM estoque_operac_ct                                                                             
          WHERE cod_empresa  = p_movto.cod_empresa                                                                  
            AND cod_operacao = p_movto.cod_operacao                                                                 
      END IF                                                                                                  
   ELSE                                                                                                       
      LET p_num_conta = NULL                                                                                  
   END IF                                                                                                     
                                                                                                                 
   IF STATUS <> 0 THEN                                                                                        
     LET p_erro =  STATUS                                                                                     
     LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_OPERAC_CT - OPER:', p_movto.cod_operacao
     RETURN FALSE                                                                                             
   END IF                                                                                                     

   LET p_estoque_trans.cod_empresa        = p_movto.cod_empresa
   LET p_estoque_trans.num_transac        = 0
   LET p_estoque_trans.cod_item           = p_movto.cod_item
   LET p_estoque_trans.dat_movto          = p_movto.dat_movto
   LET p_estoque_trans.dat_ref_moeda_fort = p_movto.dat_movto
   LET p_estoque_trans.cod_operacao       = p_movto.cod_operacao
   LET p_estoque_trans.num_docum          = p_movto.num_docum
   LET p_estoque_trans.num_seq            = p_movto.num_seq
   LET p_estoque_trans.ies_tip_movto      = p_movto.ies_tip_movto
   LET p_estoque_trans.qtd_movto          = p_movto.qtd_movto
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = NULL

   IF p_movto.tip_operacao = 'S' THEN      #se for uma operação de saída
      LET p_estoque_trans.cod_local_est_orig = p_movto.cod_local
      LET p_estoque_trans.num_lote_orig = p_movto.num_lote
      LET p_estoque_trans.ies_sit_est_orig = p_movto.ies_situa
   ELSE
      LET p_estoque_trans.cod_local_est_dest = p_movto.cod_local
      LET p_estoque_trans.num_lote_dest = p_movto.num_lote
      LET p_estoque_trans.ies_sit_est_dest = p_movto.ies_situa
   END IF
   
   LET p_estoque_trans.cod_turno   = p_movto.cod_turno
   LET p_estoque_trans.nom_usuario = p_movto.usuario
   LET p_estoque_trans.dat_proces  = p_movto.dat_proces
   LET p_estoque_trans.hor_operac  = p_movto.hor_operac
   LET p_estoque_trans.num_prog    = p_movto.num_prog

   IF NOT estoque_ins_estoq_trans() THEN
      RETURN FALSE
   END IF
     
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION estoque_ins_estoq_trans()#
#---------------------------------#

   INSERT INTO estoque_trans(
          cod_empresa,
          cod_item,
          dat_movto,
          dat_ref_moeda_fort,
          cod_operacao,
          num_docum,
          num_seq,
          ies_tip_movto,
          qtd_movto,
          cus_unit_movto_p,
          cus_tot_movto_p,
          cus_unit_movto_f,
          cus_tot_movto_f,
          num_conta,
          num_secao_requis,
          cod_local_est_orig,
          cod_local_est_dest,
          num_lote_orig,
          num_lote_dest,
          ies_sit_est_orig,
          ies_sit_est_dest,
          cod_turno,
          nom_usuario,
          dat_proces,
          hor_operac,
          num_prog)   
          VALUES (p_estoque_trans.cod_empresa,
                  p_estoque_trans.cod_item,
                  p_estoque_trans.dat_movto,
                  p_estoque_trans.dat_ref_moeda_fort,
                  p_estoque_trans.cod_operacao,
                  p_estoque_trans.num_docum,
                  p_estoque_trans.num_seq,
                  p_estoque_trans.ies_tip_movto,
                  p_estoque_trans.qtd_movto,
                  p_estoque_trans.cus_unit_movto_p,
                  p_estoque_trans.cus_tot_movto_p,
                  p_estoque_trans.cus_unit_movto_f,
                  p_estoque_trans.cus_tot_movto_f,
                  p_estoque_trans.num_conta,
                  p_estoque_trans.num_secao_requis,
                  p_estoque_trans.cod_local_est_orig,
                  p_estoque_trans.cod_local_est_dest,
                  p_estoque_trans.num_lote_orig,
                  p_estoque_trans.num_lote_dest,
                  p_estoque_trans.ies_sit_est_orig,
                  p_estoque_trans.ies_sit_est_dest,
                  p_estoque_trans.cod_turno,
                  p_estoque_trans.nom_usuario,
                  p_estoque_trans.dat_proces,
                  p_estoque_trans.hor_operac,
                  p_estoque_trans.num_prog)   

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO TABELA ESTOQUE_TRANS'  
      RETURN FALSE
   END IF

   LET p_num_trans_atual = SQLCA.SQLERRD[2]

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION estoque_rev_estoq_trans()#
#---------------------------------#
    
   SELECT * 
     INTO p_estoque_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_movto.cod_empresa
      AND num_transac = p_movto.trans_origem

   IF STATUS <> 0 THEN
      LET p_erro =  STATUS                                                                                     
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_TRANS'
      RETURN FALSE
   END IF

   LET p_estoque_trans.dat_proces         = p_movto.dat_proces
   LET p_estoque_trans.hor_operac         = p_movto.hor_operac
   LET p_estoque_trans.ies_tip_movto      = p_movto.ies_tip_movto

   IF NOT estoque_ins_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_ins_estoque_trans_rev() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION estoque_gra_est_trans_end()#
#-----------------------------------#

 #---para chamar essa rotina é necessário ter lido a estoque_lote_ender previamente---#
   INITIALIZE p_estoque_trans_end.*  TO NULL
 
   LET p_estoque_trans_end.num_transac      = p_num_trans_atual                        
   LET p_estoque_trans_end.endereco         = p_estoque_lote_ender.endereco               
   LET p_estoque_trans_end.cod_grade_1      = p_estoque_lote_ender.cod_grade_1            
   LET p_estoque_trans_end.cod_grade_2      = p_estoque_lote_ender.cod_grade_2            
   LET p_estoque_trans_end.cod_grade_3      = p_estoque_lote_ender.cod_grade_3            
   LET p_estoque_trans_end.cod_grade_4      = p_estoque_lote_ender.cod_grade_4            
   LET p_estoque_trans_end.cod_grade_5      = p_estoque_lote_ender.cod_grade_5            
   LET p_estoque_trans_end.num_ped_ven      = p_estoque_lote_ender.num_ped_ven            
   LET p_estoque_trans_end.num_seq_ped_ven  = p_estoque_lote_ender.num_seq_ped_ven        
   LET p_estoque_trans_end.dat_hor_producao = p_estoque_lote_ender.dat_hor_producao       
   LET p_estoque_trans_end.dat_hor_validade = p_estoque_lote_ender.dat_hor_validade       
   LET p_estoque_trans_end.num_peca         = p_estoque_lote_ender.num_peca               
   LET p_estoque_trans_end.num_serie        = p_estoque_lote_ender.num_serie              
   LET p_estoque_trans_end.comprimento      = p_estoque_lote_ender.comprimento            
   LET p_estoque_trans_end.largura          = p_estoque_lote_ender.largura                
   LET p_estoque_trans_end.altura           = p_estoque_lote_ender.altura                 
   LET p_estoque_trans_end.diametro         = p_estoque_lote_ender.diametro               
   LET p_estoque_trans_end.dat_hor_reserv_1 = p_estoque_lote_ender.dat_hor_reserv_1       
   LET p_estoque_trans_end.dat_hor_reserv_2 = p_estoque_lote_ender.dat_hor_reserv_2       
   LET p_estoque_trans_end.dat_hor_reserv_3 = p_estoque_lote_ender.dat_hor_reserv_3       
   LET p_estoque_trans_end.qtd_reserv_1     = p_estoque_lote_ender.qtd_reserv_1           
   LET p_estoque_trans_end.qtd_reserv_2     = p_estoque_lote_ender.qtd_reserv_2           
   LET p_estoque_trans_end.qtd_reserv_3     = p_estoque_lote_ender.qtd_reserv_3           
   LET p_estoque_trans_end.num_reserv_1     = p_estoque_lote_ender.num_reserv_1           
   LET p_estoque_trans_end.num_reserv_2     = p_estoque_lote_ender.num_reserv_2           
   LET p_estoque_trans_end.num_reserv_3     = p_estoque_lote_ender.num_reserv_3           
   LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa                 
   LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item                    
   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto                   
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto                   
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao                
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto               
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog                    
   LET p_estoque_trans_end.cus_unit_movto_p = p_estoque_trans.cus_unit_movto_p                                           
   LET p_estoque_trans_end.cus_unit_movto_f = p_estoque_trans.cus_unit_movto_f                                            
   LET p_estoque_trans_end.cus_tot_movto_p  = p_estoque_trans.cus_tot_movto_p                                           
   LET p_estoque_trans_end.cus_tot_movto_f  = p_estoque_trans.cus_tot_movto_f                                            
   LET p_estoque_trans_end.num_volume       = 0                                           
   LET p_estoque_trans_end.dat_hor_prod_ini = '1900-01-01 00:00:00'                       
   LET p_estoque_trans_end.dat_hor_prod_fim = '1900-01-01 00:00:00'                       
   LET p_estoque_trans_end.vlr_temperatura  = 0                                           
   LET p_estoque_trans_end.endereco_origem  = ' '                                         
   LET p_estoque_trans_end.tex_reservado    = ' '                                        
   
   IF NOT estoque_ins_est_trans_end() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION estoque_ins_est_trans_end()#
#-----------------------------------#
      
   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO NA TAB ESTOQUE_TRANS_END'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION estoque_rev_trans_end()#
#-------------------------------#

   SELECT * 
     INTO p_estoque_trans_end.*
     FROM estoque_trans_end
    WHERE cod_empresa = p_movto.cod_empresa
      AND num_transac = p_movto.trans_origem

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO MOVTO NORMAL DA ESTOQUE_TRANS_END'  
      RETURN FALSE
   END IF

   LET p_estoque_trans_end.num_transac = p_num_trans_atual
   LET p_estoque_trans_end.ies_tip_movto = p_movto.ies_tip_movto    

   IF NOT estoque_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION estoque_gra_estoq_auditoria()#
#-------------------------------------#
  
  INSERT INTO estoque_auditoria(
   cod_empresa,
   num_transac,
   nom_usuario,
   dat_hor_proces,
   num_programa)
  VALUES(p_movto.cod_empresa, 
      p_num_trans_atual, 
      p_movto.usuario, 
      p_movto.dat_proces, 
      p_movto.num_prog)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO MOVTO NORMAL DA ESTOQUE_AUDITORIA'  
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#---------------------------------#
FUNCTION estoque_reverte_entrada()#
#---------------------------------#

   CALL estoque_le_lote()

   IF STATUS = 0 THEN
      IF NOT estoque_atu_lote(-p_movto.qtd_movto) THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_LOTE'  
      RETURN FALSE
   END IF
   
   CALL estoque_le_lot_ender()

   IF STATUS = 0 THEN
      LET p_num_transac = p_estoque_lote_ender.num_transac
      IF NOT estoque_atu_lote_ender(-p_movto.qtd_movto) THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoque() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_rev_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_rev_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_auditoria() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION estoque_ins_estoque_trans_rev()#
#---------------------------------------#

   INSERT INTO estoque_trans_rev
    VALUES(p_estoque_trans.cod_empresa,
           p_estoque_trans.num_transac,
           p_num_trans_atual)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO TABELA ESTOQUE_TRANS_REV'  
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION estoque_grava_saida()#
#-----------------------------#
   
   DEFINE p_qtd_saldo DECIMAL(10,3)
   
   CALL estoque_le_lote()

   IF STATUS = 0 THEN               
      IF NOT estoque_atu_lote(-p_movto.qtd_movto) THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_LOTE'  
      RETURN FALSE
   END IF
   
   CALL estoque_le_lot_ender()

   IF STATUS = 0 THEN
      LET p_num_transac = p_estoque_lote_ender.num_transac
      IF NOT estoque_atu_lote_ender(-p_movto.qtd_movto) THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_LOTE'  
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoque() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_auditoria() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION estoque_reverte_saida()#
#-------------------------------#

   IF NOT estoque_gra_lote() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_lot_ender() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoque() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_rev_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_rev_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_auditoria() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
