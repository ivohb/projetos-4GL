#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1301                                                 #
# OBJETIVO: APONTAMENTO DE PRODUÇÃO POR OPERAÇÃO                    #
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
       m_form_item       VARCHAR(10),
       m_bar_item        VARCHAR(10),
       m_cent_trab       VARCHAR(10),
       m_cod_operac      VARCHAR(10),
       m_datini          VARCHAR(10),
       m_datfim          VARCHAR(10),
       m_dat_pesquisa    VARCHAR(10),
       m_semana          VARCHAR(10),
       m_ordem           VARCHAR(10),
       m_docum           VARCHAR(10),
       m_ies_data        VARCHAR(10),
       m_lupa_cent_trab  VARCHAR(10),
       m_lupa_operac     VARCHAR(10),
       m_lupa_profis     VARCHAR(10),
       m_zoom_cent_trab  VARCHAR(10),
       m_zoom_operac     VARCHAR(10),       
       m_zoom_profis     VARCHAR(10),
       m_item            VARCHAR(10),
       m_zoom_item       VARCHAR(10),       
       m_familia         VARCHAR(10),
       m_zoom_familia    VARCHAR(10),  
            
       m_browse          VARCHAR(10),
       m_brow_item       VARCHAR(10),
       m_brow_familia    VARCHAR(10),
       m_brow_est        VARCHAR(10),
       m_cod_profis      VARCHAR(10),
       m_form_estorna    VARCHAR(10),
       m_bar_estorna     VARCHAR(10)
       
DEFINE m_ies_info        SMALLINT,
       m_ies_mod         SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ind             INTEGER,
       m_checa_linha     SMALLINT,
       m_data            DATE,
       m_qtd_linha       INTEGER,
       m_cod_item_pai    CHAR(15),
       m_ies_proces      SMALLINT

DEFINE m_saldo          LIKE ord_oper.qtd_boas,
       m_qtd_apont      LIKE ord_oper.qtd_boas,
       m_den_item       LIKE item.den_item,
       m_den_familia    LIKE familia.den_familia

DEFINE mr_dados          RECORD
       cod_empresa       CHAR(02),
       usuario           CHAR(08),     
       num_processo      INTEGER,   
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
       cod_cent_trab     CHAR(05),
       qtd_planejada     DECIMAL(6,0),
       qtd_saldo         DECIMAL(6,0),
       data              DATE,
	     cod_status        CHAR(01),
	     dat_geracao       DATE,
	     hor_geracao       CHAR(08)       
END RECORD
       
#ARRAY que armazenará os dados da grade

DEFINE ma_ordem     ARRAY[5000] OF RECORD
       cod_empresa       CHAR(02),
       usuario           CHAR(08),     
       num_processo      INTEGER,   
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
       cod_cent_trab     CHAR(05),
       qtd_planejada     DECIMAL(6,0),
       qtd_saldo         DECIMAL(6,0),
       data              DATE,
	     cod_status        CHAR(01),      
	     dat_geracao       DATE,
	     hor_geracao       CHAR(08),
	     ies_selecionar    CHAR(01),
	     filler            CHAR(1)       
END RECORD

DEFINE mr_parametro      RECORD
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
       nom_profis        CHAR(40)
END RECORD

DEFINE ma_item           ARRAY[50] OF RECORD
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item
END RECORD

DEFINE ma_familia        ARRAY[50] OF RECORD
       cod_familia       LIKE familia.cod_familia,
       den_familia       LIKE familia.den_familia
END RECORD





#---VARIÁVEIS PARA O APONTAMENTO---------#

DEFINE p_man               RECORD LIKE man_apont_pol1301.* 

DEFINE m_num_processo      LIKE processo_apont_pol1301.num_processo,
       m_qtd_planejada     LIKE ord_oper.qtd_planejada,
       m_dat_fecha_ult_man LIKE par_estoque.dat_fecha_ult_man,
       m_dat_fecha_ult_sup LIKE par_estoque.dat_fecha_ult_sup,
       m_tot_apont         LIKE ord_oper.qtd_planejada

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
       p_cod_oper_sucata    LIKE par_pcp.cod_estoque_rn   
                 

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
       p_tip_producao       CHAR(01)
       
DEFINE m_dat_atu         DATE,
       m_hor_atu         CHAR(08),
       p_criticou        SMALLINT,
       m_dat_processo    CHAR(20),
       m_index           INTEGER

   DEFINE p_msg                CHAR(250),
          p_num_trans_atual    INTEGER,
          p_transac_apont      INTEGER,
          p_transac_pai        INTEGER
   
   DEFINE p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*

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

DEFINE ma_estorno        ARRAY[1000] OF RECORD
       ies_estornar      CHAR(01),
       dat_processo      CHAR(10),     
       hor_processo      CHAR(08),   
       filler            CHAR(01)
END RECORD

#-----------------#
FUNCTION pol1301()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1301-12.00.00  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1301_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1301_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_pesquisa    VARCHAR(10),
           l_modifica    VARCHAR(10),
           l_proces      VARCHAR(10),
           l_estorno     VARCHAR(10)
    
    CALL pol1301_limpa_campos()

    LET m_ies_info = FALSE
    LET m_ies_mod = FALSE

       #Criação da janela do programa
    LET m_form_aponta = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_aponta,"SIZE",640,480)
    CALL _ADVPL_set_property(m_form_aponta,"TITLE","APONTAMENTO POR OPERAÇÃO")

       #Criação da barra de status
    LET m_bar_aponta = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_aponta)

       #Criação da barra de menu
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_aponta)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

       #Criação do botão informar
    LET l_pesquisa = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_pesquisa,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_pesquisa,"EVENT","pol1301_pesquisar")

    LET l_modifica = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_modifica,"EVENT","pol1301_modifica")
    CALL _ADVPL_set_property(l_modifica,"CONFIRM_EVENT","pol1301_conf_mod")
    CALL _ADVPL_set_property(l_modifica,"CANCEL_EVENT","pol1301_canc_mod")

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

    CALL pol1301_cria_grade(l_panel)

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
   INITIALIZE ma_item TO NULL
   INITIALIZE ma_familia TO NULL
   INITIALIZE ma_ordem TO NULL
   INITIALIZE ma_estorno  TO NULL
       
END FUNCTION

#---------------------------------------#
FUNCTION pol1301_cria_grade(l_container)#
#---------------------------------------#

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
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","semana")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Eep")
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
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","C Trab")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cent_trab")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Planej")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_planejada")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_saldo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
        
    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_ordem,1)
        
END FUNCTION

#---------------------------#
FUNCTION pol1301_pesquisar()#
#---------------------------#   

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_confirma    VARCHAR(10),
           l_cancela     VARCHAR(10)
   
   IF NOT pol1301_cria_tabs() THEN
      RETURN FALSE
   END IF
       
    CALL pol1301_limpa_campos()

    LET m_ies_info = FALSE
    LET m_ies_mod = FALSE

       #Criação da janela do programa
    LET m_form_pesquisa = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_pesquisa,"SIZE",580,400)
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
   CALL _ADVPL_set_property(l_confirma,"EVENT","pol1301_conf_pesq")     

   LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancela,"EVENT","pol1301_canc_pesq")     

       #Criação do botão sair
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    #Chama FUNCTION para criação dos campos
    CALL pol1301_cria_campos(m_form_pesquisa)

    #CALL pol1301_ativa_desativa(FALSE)

       #Exibe a janela do programa
    CALL _ADVPL_set_property(m_form_pesquisa,"ACTIVATE",TRUE)
 
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

#-------------------------------------#
FUNCTION pol1301_cria_campos(l_dialog)#
#-------------------------------------#

    DEFINE l_dialog          VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_den_cent_trab   VARCHAR(10),
           l_den_operac      VARCHAR(10),           
           l_tabcolumn       VARCHAR(10),
           l_nom_profis      VARCHAR(10)


    #criação de um painel central
    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    #criação um LLAYOUT c/ 4 colunas, para distribuiçao dos campos com popup 
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",4)

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

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

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

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

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

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

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    #criação do campo para entrada do numero da semana
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Semana:")
    
    LET m_semana = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_semana,"VARIABLE",mr_parametro,"num_semana")
    CALL _ADVPL_set_property(m_semana,"EDITABLE",FALSE)
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

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    #criação do campo para entrada da familia
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Familia:")    

    LET m_familia = _ADVPL_create_component(NULL,"LCOMBOBOX",l_layout)    
    CALL _ADVPL_set_property(m_familia,"ADD_ITEM","N","          ")     
    CALL _ADVPL_set_property(m_familia,"ADD_ITEM","S","Selecionar")     
    CALL _ADVPL_set_property(m_familia,"VARIABLE",mr_parametro,"ies_familia")
    CALL _ADVPL_set_property(m_familia,"VALID","pol1301_familia")

    #criação do campo para entrada do item
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Item:")    

    LET m_item = _ADVPL_create_component(NULL,"LCOMBOBOX",l_layout)    
    CALL _ADVPL_set_property(m_item,"ADD_ITEM","N","          ")     
    CALL _ADVPL_set_property(m_item,"ADD_ITEM","S","Selecionar")     
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_parametro,"ies_item")
    CALL _ADVPL_set_property(m_item,"VALID","pol1301_item")

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    #criação do campo para entrada do código do profissional
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

   CALL _ADVPL_set_property(m_bar_pesquisa,"CLEAR_TEXT")
   
   INITIALIZE mr_parametro.nom_profis TO NULL

   IF mr_parametro.cod_profis IS NULL THEN
      CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT",
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
      CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT",
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

#---------------------------#
FUNCTION pol1301_conf_pesq()#
#---------------------------#

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

   IF mr_parametro.cod_profis IS NULL THEN
      CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT",
             "Informe o operador p/ apontamento")
      CALL _ADVPL_set_property(m_cod_profis,"GET_FOCUS")
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT", "Aguarde! Coletando dados...")           
   
   LET p_status = pol1280_le_ordens()
     
   IF NOT p_status THEN 
      CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT",
                "Operação cancelada")           
   ELSE
      CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT",
             "Operação efetuada com sucesso.")
   END IF
   
   LET m_ies_info = TRUE
                  
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
          l_cod_familia   CHAR(05)
   
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
   
   LET sql_stmt =
       " SELECT num_ordem, cod_item, num_docum, dat_abert, dat_entrega, dat_liberac, ",
       "   cod_item_pai, qtd_planej, (qtd_planej-qtd_boas-qtd_refug-qtd_sucata) FROM ordens ",
       "  WHERE cod_empresa = '",p_cod_empresa,"' ",
       "    AND ies_situa  = '4' ",
       "    AND qtd_planej > (qtd_boas + qtd_refug + qtd_sucata) "

   IF l_item THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND cod_item IN (SELECT cod_item FROM item_pol1301) "
   END IF

   IF mr_parametro.num_ordem IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND num_ordem = ", mr_parametro.num_ordem
   END IF

   IF mr_parametro.num_docum IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND num_docum = '",mr_parametro.num_docum,"' "
   END IF

   IF mr_parametro.dat_ini IS NOT NULL THEN
      IF mr_parametro.dat_pesquisa = 'A' THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND dat_abert >= '",mr_parametro.dat_ini,"' "
      END IF
      IF mr_parametro.dat_pesquisa = 'E' THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND dat_entrega >= '",mr_parametro.dat_ini,"' "
      END IF
      IF mr_parametro.dat_pesquisa = 'L' THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND dat_liberac >= '",mr_parametro.dat_ini,"' "
      END IF      
   END IF

   IF mr_parametro.dat_fim IS NOT NULL THEN
      IF mr_parametro.dat_pesquisa = 'A' THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND dat_abert <= '",mr_parametro.dat_fim,"' "
      END IF
      IF mr_parametro.dat_pesquisa = 'E' THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND dat_entrega <= '",mr_parametro.dat_fim,"' "
      END IF
      IF mr_parametro.dat_pesquisa = 'L' THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND dat_liberac <= '",mr_parametro.dat_fim,"' "
      END IF      
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
      l_dat_abert,  
      l_dat_entrega,
      l_dat_liberac,
      m_cod_item_pai,
      mr_dados.qtd_planejada,
      mr_dados.qtd_saldo
      
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
           INTO m_count
           FROM familia_pol1301
          WHERE cod_familia = l_cod_familia

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','Familia')
            RETURN FALSE
         END IF
         
         IF m_count = 0 THEN
            CONTINUE FOREACH
         END IF
         
      END IF
      
      IF NOT pol1301_le_cotas() THEN
         RETURN FALSE
      END IF
            
      IF mr_parametro.dat_pesquisa = 'A' THEN
         LET mr_dados.data = l_dat_abert
      END IF
      IF mr_parametro.dat_pesquisa = 'E' THEN
         LET mr_dados.data = l_dat_entrega
      END IF
      IF mr_parametro.dat_pesquisa = 'L' THEN
         LET mr_dados.data = l_dat_liberac
      END IF                  

      LET mr_dados.cod_empresa = p_cod_empresa
      LET mr_dados.ano = YEAR(mr_dados.data)
      LET mr_dados.mes = MONTH(mr_dados.data)
      #LET mr_dados.Semana = week_of_year(mr_dados.data)
      LET mr_dados.dat_geracao = TODAY
      LET mr_dados.hor_geracao = TIME

      SELECT den_item_reduz
        INTO mr_dados.den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = mr_dados.cod_item
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ITEM')
         RETURN FALSE
      END IF      
      
      LET mr_dados.cod_status = 'P'
      
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
   
   CALL _ADVPL_set_property(m_bar_pesquisa,"ERROR_TEXT", "")   

   IF NOT pol1301_le_operacao() THEN
      RETURN FALSE
   END IF      
   
   RETURN TRUE   

END FUNCTION

#--------------------------#
FUNCTION pol1301_le_cotas()#
#--------------------------#
   
   DECLARE cq_cotas CURSOR FOR
    SELECT num_pedido, num_orc, pos, comp, 
           larg, esp, peso, m2           
      FROM cfg_val_cotas912
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = mr_dados.cod_item
       AND cod_pai = m_cod_item_pai
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

#-----------------------------#
FUNCTION pol1301_le_operacao()#
#-----------------------------#
   
   DEFINE l_ind     INTEGER
   
   INITIALIZE ma_ordem TO NULL
   
   LET l_ind = 1
   
   DECLARE cq_le_oper CURSOR FOR
    SELECT *
      FROM pol1301_1054
     WHERE cod_empresa = p_cod_empresa
       AND usuario = p_user
       AND cod_status = 'P'
     ORDER BY num_ordem DESC
   
   FOREACH cq_le_oper INTO ma_ordem[l_ind].*      
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_le_oper')
         RETURN FALSE
      END IF
            
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

#-------------------------#
FUNCTION pol1301_familia()#
#-------------------------#

   DEFINE l_menubar     VARCHAR(10),
          l_panel       VARCHAR(10),
          l_confirma    VARCHAR(10),
          l_cancela     VARCHAR(10)

   IF mr_parametro.ies_familia = 'N' THEN
      RETURN TRUE
   END IF
   
       #Criação da janela do programa
   LET m_form_familia = _ADVPL_create_component(NULL,"LDIALOG")
   CALL _ADVPL_set_property(m_form_pesquisa,"SIZE",400,300)
   CALL _ADVPL_set_property(m_form_pesquisa,"TITLE","FAMÍLIAS PARA PESQUISA")

       #Criação da barra de status
   LET m_bar_familia = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_familia)

   LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_familia)
   CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   #LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   #CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
   #CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
   #CALL _ADVPL_set_property(l_confirma,"EVENT","pol1301_conf_familia")     

   LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancela,"EVENT","pol1301_canc_familia")     

       #Criação do botão sair
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    #Chama FUNCTION para criação dos campos
    CALL pol1301_grade_familia(m_form_familia)

       #Exibe a janela do programa
    CALL _ADVPL_set_property(m_form_pesquisa,"ACTIVATE",TRUE)
 
   RETURN TRUE 
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1301_grade_familia(l_dialog)#
#---------------------------------------#

    DEFINE l_dialog          VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    #CALL _ADVPL_set_property(l_layout,"MIN_SIZE",300,400)

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

#--------------------------#
FUNCTION pol1301_item()#
#--------------------------#

   DEFINE l_menubar     VARCHAR(10),
          l_panel       VARCHAR(10),
          l_confirma    VARCHAR(10),
          l_cancela     VARCHAR(10)

   IF mr_parametro.ies_item = 'N' THEN
      RETURN TRUE
   END IF
   
       #Criação da janela do programa
   LET m_form_item = _ADVPL_create_component(NULL,"LDIALOG")
   CALL _ADVPL_set_property(m_form_item,"SIZE",580,400)
   CALL _ADVPL_set_property(m_form_item,"TITLE","ITENS PARA PESQUISA")

       #Criação da barra de status
   LET m_bar_item = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_item)

   LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_item)
   CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
   CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirma,"EVENT","pol1301_conf_item")     

   LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancela,"EVENT","pol1301_canc_item")     

       #Criação do botão sair
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    #Chama FUNCTION para criação dos campos
    CALL pol1301_grade_item(m_form_item)

       #Exibe a janela do programa
    CALL _ADVPL_set_property(m_form_item,"ACTIVATE",TRUE)
 
   RETURN TRUE 
    
END FUNCTION

#------------------------------------#
FUNCTION pol1301_grade_item(l_dialog)#
#------------------------------------#

    DEFINE l_dialog          VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    #CALL _ADVPL_set_property(l_layout,"MIN_SIZE",300,400)

    LET m_brow_item = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brow_familia,"ALIGN","CENTER")    
    CALL _ADVPL_set_property(m_brow_familia,"AFTER_ROW_EVENT","pol1301_row_item")

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
