# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1321                                                 #
# OBJETIVO: Apontamento de produção                                 #
# AUTOR...: IVO                                                     #
# DATA....: 01/03/17                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003),
           g_id_man_apont  INTEGER,
           g_tem_critica   SMALLINT,
           p_num_trans_atual INTEGER,
           p_msg             CHAR(150)
           
END GLOBALS

DEFINE l_parametro      RECORD
       cod_empresa      CHAR(02),
       num_ordem        INTEGER,
       qtd_apont        DECIMAL(10,3)
END RECORD

DEFINE m_num_docum         CHAR(10),
	     m_cod_operac        CHAR(05),
	     m_num_seq_operac    INTEGER,
			 m_seq_reg_mestre    INTEGER,
			 m_seq_registro_item INTEGER,
			 m_comprimento       INTEGER,
			 m_largura           INTEGER,
			 m_altura            INTEGER,
			 m_diametro          INTEGER,
			 m_ies_situa         CHAR(01),
			 m_ies_tip_movto     CHAR(01),
			 m_tip_operacao      CHAR(01),
			 m_qtd_movto         DECIMAL(10,3),
			 m_qtd_retrab        DECIMAL(10,3),
			 m_dat_movto         DATE,
			 m_num_seq_apont     INTEGER,
			 m_num_transac_orig  INTEGER,
			 m_num_transac_dest  INTEGER,
			 m_ies_lote          CHAR(01),
       m_acessorio         SMALLINT,
       m_refaz_compon      SMALLINT,
       m_refaz_man         SMALLINT,
       m_num_neces         INTEGER,
       m_neces_op          INTEGER,
       l_tipo_item         CHAR(10),
       m_sdo_chapa         DECIMAL(10,3),
       m_op_chapa          INTEGER,
       m_sem_chapa         SMALLINT
      

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_browse          VARCHAR(10),
       m_ordem           VARCHAR(10),
       m_turno           VARCHAR(10),
       m_lupa_tur        VARCHAR(10),
       m_zoom_tur        VARCHAR(10),
       m_dat_ini         VARCHAR(10),
       m_hor_ini         VARCHAR(10),
       m_dat_fim         VARCHAR(10),
       m_hor_fim         VARCHAR(10),
       m_boa             VARCHAR(10),
       m_boa_retrab      VARCHAR(10),
       m_refugo          VARCHAR(10),
       m_refugo_retrab   VARCHAR(10),
       m_defeito         VARCHAR(10),
       m_lupa_def        VARCHAR(10),
       m_zoom_def        VARCHAR(10),
       m_construct       VARCHAR(10),
       m_sucata          VARCHAR(10),
       m_sucata_retrab   VARCHAR(10),
       m_barra_apont     VARCHAR(10),
       m_form_apont      VARCHAR(10),
       m_peso_item       DECIMAL(15,7)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150)

DEFINE mr_cabec          RECORD
       num_ordem         INTEGER,
       cod_item          VARCHAR(15),
       den_item          VARCHAR(50),
       qtd_planej        DECIMAL(10,3),
       qtd_saldo         DECIMAL(10,3),
       num_docum         CHAR(10),
       cod_cliente       CHAR(15),
       nom_cliente       CHAR(36),
       sdo_estoque       DECIMAL(10,3),
       tip_produto       CHAR(10)
END RECORD

DEFINE mr_apont          RECORD
       cod_turno         DECIMAL(3,0),
       den_turno         CHAR(40),
       dat_ini           DATE,
       hor_ini           CHAR(05),
       dat_fim           DATE,
       hor_fim           CHAR(05),
       boa               DECIMAL(10,3),
       boa_retrab        DECIMAL(10,3),
       refugo            DECIMAL(10,3),
       refugo_retrab     DECIMAL(10,3),
       cod_defeito       DECIMAL(3,0),
       den_defeito       CHAR(30),
       sucata            DECIMAL(10,3),
       sucata_retrab     DECIMAL(10,3)
END RECORD

DEFINE ma_itens          ARRAY[100] OF RECORD
       seq_reg_mestre    INTEGER,
       data_producao     DATE,
       data_apontamento  DATE,
       hor_apontamento   CHAR(08),
       usu_apontamento   CHAR(08),
       seq_registro_item INTEGER,
       item_produzido    CHAR(15),
       qtd_produzida     DECIMAL(10,3),
       qtd_convertida    DECIMAL(10,3),
       tip_producao      CHAR(10),
       qtd_estornada     DECIMAL(10,3),
       sdo_apont         DECIMAL(10,3),
       estornar          CHAR(01),
       qtd_estornar      DECIMAL(10,3),
 	     filler            CHAR(1)       
END RECORD       

DEFINE ma_erros          ARRAY[100] OF RECORD
       num_ordem         INTEGER,
       erro              CHAR(500)
END RECORD

DEFINE m_num_ordem       INTEGER,
       m_num_ordema      INTEGER,
       m_carregando      SMALLINT,
       m_cod_cliente     CHAR(15),
       m_nom_cliente     CHAR(36),
       m_den_item        CHAR(76),
       m_ies_cons        SMALLINT,
       m_num_pedido      INTEGER,
       m_num_seq         INTEGER,
       m_ind             INTEGER,
       m_ini             CHAR(4),
       m_fim             CHAR(4),
       m_ies_forca       CHAR(01),
       m_ies_apont       CHAR(01),
       m_apontou         SMALLINT,
       m_cod_roteiro     CHAR(15),
       m_num_altern      DECIMAL(2,0),
       m_cod_local_estoq CHAR(10),
       m_cod_local_prod  CHAR(10),
       m_total           DECIMAL(10,3),
       m_qtd_chapa       DECIMAL(10,3),
       m_qtd_estornar    DECIMAL(10,3),
       m_qtd_sucata      DECIMAL(10,3),
       m_cod_status      CHAR(01),
			 m_tip_integra     CHAR(01),
			 m_tip_movto       CHAR(01),
			 m_qtd_tempo       INTEGER,
	     m_pes_unit        LIKE item.pes_unit,
	     m_unid_item       LIKE item.cod_unid_med,
	     m_unid_sucata     LIKE item.cod_unid_med,
       m_cod_sucata      CHAR(15),
       m_fat_conver      DECIMAL(12,5),
       m_qtd_conver      DECIMAL(15,3),
       m_cod_item        CHAR(15),
       m_erro            CHAR(10),
       m_txt_resumo      CHAR(80),
       m_qtd_erro        INTEGER,
       m_deu_erro        SMALLINT,
       m_qtd_apontada    DECIMAL(10,3),
       m_sdo_apont       DECIMAL(10,3),
       m_num_lote        CHAR(15),
       m_ies_baixa       CHAR(01),
       m_cod_unid        CHAR(03)

DEFINE 
       p_parametros_885  RECORD LIKE parametros_885.*,
       p_est_trans_relac RECORD LIKE est_trans_relac.*

DEFINE mr_man_apont      RECORD 
       cod_empresa           char(02),         
       id_registro           integer,          
       num_ordem             integer,          
       num_pedido            integer,          
       num_seq_pedido        integer,          
       cod_item             char(15),          
       cod_roteiro          char(15),          
       num_rot_alt          decimal(3,0),      
       num_lote             char(15),          
       dat_inicial          date,          
       dat_final            date,          
       cod_recur            char(05),          
       cod_operac           char(05),          
       num_seq_operac       decimal(3,0),      
       oper_final           char(01),          
       cod_cent_trab        char(05),          
       cod_cent_cust        decimal(4,0),      
       cod_unid_prod        char(05),          
       cod_arranjo          char(05),          
       qtd_refugo           decimal(10,3),     
       qtd_sucata           decimal(10,3),     
       qtd_boas             decimal(10,3),     
       comprimento          integer,           
       largura              integer,           
       altura               integer,           
       diametro             integer,           
       tip_apon             char(01),          
       tip_operacao         char(01),          
       cod_local_prod       char(10),          
       cod_local_est        char(10),          
       qtd_hor              decimal(11,7),     
       matricula            char(08),          
       cod_turno            char(01),          
       hor_inicial          char(05),          
       hor_final            char(05),          
       unid_funcional       char(10),          
       dat_atualiz          datetime YEAR TO SECOND,          
       ies_terminado        char(01),          
       cod_eqpto            char(15),          
       cod_ferramenta       char(15),          
       integr_min           char(01),          
       nom_prog             char(08),          
       nom_usuario          char(08),          
       cod_status           char(01),          
       num_processo         integer,           
       num_proc_ant         integer,           
       num_proc_dep         integer,           
       num_transac          integer,           
       mensagem             char(210),         
       dat_process          datetime YEAR TO SECOND,          
       id_apont             integer,           
       id_tempo             integer,           
       integrado            integer,           
       den_erro             char(500),         
       dat_integra          char(20),          
       usuario              char(08),          
       tip_integra          char(01),          
       concluido            char(01),          
       num_docum            char(15),          
       qtd_movto            decimal(10,3),     
       tip_movto            char(01),          
       qtd_tempo            integer,           
       dat_criacao          datetime YEAR TO SECOND,         
       qtd_retrab           decimal(10,3),     
       seq_reg_mestre       integer,           
       qtd_estornada        decimal(10,3)    
END RECORD




DEFINE p_w_apont_prod   RECORD 													
   cod_empresa         char(2),                         
   cod_item            char(15), 
   num_ordem           integer, 
   num_docum           char(10), 
   cod_roteiro         char(15), 
   num_altern          dec(2,0), 
   cod_operacao        char(5), 
   num_seq_operac      dec(3,0), 
   cod_cent_trab       char(5), 
   cod_arranjo         char(5), 
   cod_equip           char(15), 
   cod_ferram          char(15), 
   num_operador        char(15), 
   num_lote            char(15), 
   hor_ini_periodo     datetime hour to minute, 
   hor_fim_periodo     datetime hour to minute, 
   cod_turno           dec(3,0), 
   qtd_boas            dec(10,3), 
   qtd_refug           dec(10,3), 
   qtd_total_horas     dec(10,2), 
   cod_local           char(10), 
   cod_local_est       char(10), 
   dat_producao        date, 
   dat_ini_prod        date, 
   dat_fim_prod        date, 
   cod_tip_movto       char(1), 
   estorno_total       char(1), 
   ies_parada          smallint, 
   ies_defeito         smallint, 
   ies_sucata          smallint, 
   ies_equip_min       char(1), 
   ies_ferram_min      char(1), 
   ies_sit_qtd         char(1), 
   ies_apontamento     char(1), 
   tex_apont           char(255), 
   num_secao_requis    char(10), 
   num_conta_ent       char(23), 
   num_conta_saida     char(23), 
   num_programa        char(8), 
   nom_usuario         char(8), 
   num_seq_registro    integer, 
   observacao          char(200), 
   cod_item_grade1     char(15), 
   cod_item_grade2     char(15), 
   cod_item_grade3     char(15), 
   cod_item_grade4     char(15), 
   cod_item_grade5     char(15), 
   qtd_refug_ant       dec(10,3), 
   qtd_boas_ant        dec(10,3), 
   tip_servico         char(1), 
   abre_transacao      smallint, 
   modo_exibicao_msg   smallint, 
   seq_reg_integra     integer, 
   endereco            integer, 
   identif_estoque     char(30), 
   sku                 char(25), 
   finaliza_operacao   char(1),
   seq_processo        decimal(10,0)
END RECORD

DEFINE ma_compon       ARRAY[15] OF RECORD
       num_neces       INTEGER,
       cod_compon      CHAR(15),
       den_compon      CHAR(76),
       qtd_neces       DECIMAL(17,7),
 	     filler          CHAR(1)       
END RECORD

DEFINE m_brz_compon    CHAR(10),
       m_form_compon   CHAR(10),
       m_bar_compon    CHAR(10),
       m_zoom_item     CHAR(10),
       m_lupa_item     CHAR(10),
       m_qtd_compon    INTEGER


#-----------------#
FUNCTION pol1321()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "POL1321-12.00.01  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1321_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1321_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_estornar    VARCHAR(10),
           l_apontar     VARCHAR(10),
           l_find        VARCHAR(10),
           l_first       VARCHAR(10),
           l_previous    VARCHAR(10),
           l_next        VARCHAR(10),
           l_last        VARCHAR(10),
           l_compon      VARCHAR(10),
           l_titulo      CHAR(43),
           l_inform      VARCHAR(10)

    
    LET l_titulo = "APONTAMENTO DE PRODUÇÃO - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1321_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1321_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1321_cancelar")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1321_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1321_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1321_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1321_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1321_last")

    LET l_apontar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_apontar,"IMAGE","APONTAR_EX") 
    CALL _ADVPL_set_property(l_apontar,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(l_apontar,"EVENT","pol1321_apontar")    

    LET l_estornar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_estornar,"IMAGE","ESTORNO_EX") 
    CALL _ADVPL_set_property(l_estornar,"TYPE","CONFIRM")    
    CALL _ADVPL_set_property(l_estornar,"EVENT","pol1321_estornar")
    CALL _ADVPL_set_property(l_estornar,"CONFIRM_EVENT","pol1321_confirma_estorno")
    CALL _ADVPL_set_property(l_estornar,"CANCEL_EVENT","pol1321_cancela_estorno")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1321_cria_campos(l_panel)
   CALL pol1321_cria_grade(l_panel)

   CALL pol1321_ativa_desativa(FALSE)

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1321_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_ordem           VARCHAR(10),
           l_cod_item        VARCHAR(10),
           l_den_item        VARCHAR(10),
           l_planejada       VARCHAR(10),
           l_saldo           VARCHAR(10),
           l_docum           VARCHAR(10),
           l_cliente         VARCHAR(10),
           l_nome            VARCHAR(10),
           l_tipo            VARCHAR(10),
           l_estoque         VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",80)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Número da OF:")    

    LET m_ordem = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_ordem,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_ordem,"POSITION",100,10)     
    CALL _ADVPL_set_property(m_ordem,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_ordem,"PICTURE","@E #########")
    CALL _ADVPL_set_property(m_ordem,"VARIABLE",mr_cabec,"num_ordem")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",200,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Produto:")    

    LET l_cod_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_cod_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_cod_item,"POSITION",250,10)     
    CALL _ADVPL_set_property(l_cod_item,"LENGTH",15) 
    CALL _ADVPL_set_property(l_cod_item,"VARIABLE",mr_cabec,"cod_item")

    LET l_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_item,"POSITION",400,10)     
    CALL _ADVPL_set_property(l_den_item,"LENGTH",50) 
    CALL _ADVPL_set_property(l_den_item,"VARIABLE",mr_cabec,"den_item")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",830,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd planejada:")    

    LET l_planejada = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_planejada,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_planejada,"POSITION",915,10)     
    CALL _ADVPL_set_property(l_planejada,"LENGTH",12) 
    CALL _ADVPL_set_property(l_planejada,"VARIABLE",mr_cabec,"qtd_planej")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1035,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Saldo da OF:")    

    LET l_saldo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_saldo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_saldo,"POSITION",1105,10)     
    CALL _ADVPL_set_property(l_saldo,"LENGTH",12) 
    CALL _ADVPL_set_property(l_saldo,"VARIABLE",mr_cabec,"qtd_saldo")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Pedido:")    

    LET l_docum = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_docum,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_docum,"POSITION",100,40)     
    CALL _ADVPL_set_property(l_docum,"LENGTH",10)
    CALL _ADVPL_set_property(l_docum,"VARIABLE",mr_cabec,"num_docum")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",200,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    

    LET l_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_cliente,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_cliente,"POSITION",250,40)     
    CALL _ADVPL_set_property(l_cliente,"LENGTH",15)
    CALL _ADVPL_set_property(l_cliente,"VARIABLE",mr_cabec,"cod_cliente")

    LET l_nome = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_nome,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_nome,"POSITION",400,40)     
    CALL _ADVPL_set_property(l_nome,"LENGTH",36)
    CALL _ADVPL_set_property(l_nome,"VARIABLE",mr_cabec,"nom_cliente")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",760,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Tip produto:")    

    LET l_tipo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_tipo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_tipo,"POSITION",830,40)     
    CALL _ADVPL_set_property(l_tipo,"LENGTH",12)
    CALL _ADVPL_set_property(l_tipo,"VARIABLE",mr_cabec,"tip_produto")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1000,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Estoque do produto:")    

    LET l_estoque = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_estoque,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_estoque,"POSITION",1105,40)     
    CALL _ADVPL_set_property(l_estoque,"LENGTH",12)
    CALL _ADVPL_set_property(l_estoque,"VARIABLE",mr_cabec,"sdo_estoque")

END FUNCTION

#---------------------------------------#
FUNCTION pol1321_cria_grade(l_container)#
#---------------------------------------#

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
    CALL _ADVPL_set_property(m_browse,"AFTER_ROW_EVENT","pol1321_limpa_status")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Seq apont")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","seq_reg_mestre")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dat produção")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","data_producao")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dat apontamento")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",85)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","data_apontamento")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Hor apontamento")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",85)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","hor_apontamento")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Usuário")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","usu_apontamento")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Seq item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","seq_registro_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item produzido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","item_produzido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd produzida")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_produzida")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd convertida")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_convertida")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","tip_producao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd estornada")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_estornada")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Saldo apont")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","sdo_apont")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CHECKED")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Estornar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","estornar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1321_checa_linha")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd estornar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_estornar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",10,3)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E #######.###")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1321_chec_qtd_est")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")


    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CLEAR")

END FUNCTION


#----------------------------------------#
FUNCTION pol1321_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
    
   CALL _ADVPL_set_property(m_browse,"EDITABLE",l_status)

END FUNCTION

#-----------------------------#
FUNCTION pol1321_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_itens TO NULL

END FUNCTION

#------------------------------#
FUNCTION pol1321_limpa_status()#
#------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
         
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1321_checa_linha()#
#-----------------------------#

   DEFINE l_lin_atu       INTEGER,
          l_estornar      CHAR(01)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   LET l_estornar = ma_itens[l_lin_atu].estornar

   IF l_estornar = 'S' THEN
      LET ma_itens[l_lin_atu].qtd_estornar = ma_itens[l_lin_atu].sdo_apont
      CALL _ADVPL_set_property(m_browse,"SELECT_ITEM",l_lin_atu,13)
   ELSE
      LET ma_itens[l_lin_atu].qtd_estornar = 0
   END IF 
      
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1321_chec_qtd_est()#
#------------------------------#

   DEFINE l_lin_atu       INTEGER,
          l_estornar      CHAR(01)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   LET l_estornar = ma_itens[l_lin_atu].estornar

   IF l_estornar = 'N' THEN
      LET ma_itens[l_lin_atu].qtd_estornar = 0
      CALL _ADVPL_set_property(m_browse,"SELECT_ITEM",l_lin_atu,12)
      RETURN TRUE
   END IF 

   IF ma_itens[l_lin_atu].qtd_estornar < 0 THEN
      LET ma_itens[l_lin_atu].qtd_estornar = 0
   END IF

   IF ma_itens[l_lin_atu].qtd_estornar > ma_itens[l_lin_atu].sdo_apont THEN
      LET m_msg = 'Qtd a estornar não pode ser maior que saldo do apontamento.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF


   IF ma_itens[l_lin_atu].qtd_estornar = 0 THEN
      LET ma_itens[l_lin_atu].estornar = 'N'
   ELSE
      IF ma_itens[l_lin_atu].tip_producao[1] = 'B' THEN
      ELSE
         IF ma_itens[l_lin_atu].qtd_estornar <> ma_itens[l_lin_atu].qtd_produzida THEN 
            LET ma_itens[l_lin_atu].qtd_estornar = ma_itens[l_lin_atu].qtd_produzida 
            LET m_msg = 'Não é permitido estorno parcial de refugo/sucata.'
            CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         END IF
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1321_informar()#
#--------------------------#
   
   DEFINE l_data    DATE
   
   LET m_ies_info = FALSE
   
   IF NOT pol1321_le_parametros() THEN
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_ordem,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_ordem,"GET_FOCUS")
      
   RETURN TRUE 
    
END FUNCTION

#----------------------#
FUNCTION pol1321_find()#
#----------------------#

    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)
    
    CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
    LET m_num_ordema = m_num_ordem
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","PESQUISA ORDENS")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","ordens","ordem")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","ordens","num_ordem","Num OF",1 {INT},9,0,"zoom_ordem_producao")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","ordens","cod_item","Produto",1 {CHAR},15,0,"zoom_item")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","ordens","num_docum","Pedido",1 {CHAR},15,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF  l_status THEN
        LET l_where_clause = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_construct,"ORDER_BY")
        CALL pol1321_cria_cursor(l_where_clause,l_order_by)
    ELSE
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
    LET m_num_ordem = m_num_ordema
    
END FUNCTION

#------------------------------------------------------#
FUNCTION pol1321_cria_cursor(l_where_clause,l_order_by)#
#------------------------------------------------------#
 
   DEFINE l_where_clause CHAR(800)
   DEFINE l_order_by     CHAR(200)

   DEFINE l_sql_stmt     CHAR(2000)

    IF  l_order_by IS NULL THEN
        LET l_order_by = "num_ordem"
    END IF

   LET l_sql_stmt = "SELECT num_ordem FROM ordens ",
                    " WHERE ", l_where_clause CLIPPED,
                    "   AND cod_empresa = '",p_cod_empresa,"' ",
                    "   AND ies_situa = '4' ",
                    " ORDER BY ", l_order_by

   PREPARE var_pesquisa FROM l_sql_stmt
    
   IF  Status <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","var_pesquisa")
       RETURN 
   END IF

   DECLARE cq_cons SCROLL CURSOR WITH HOLD FOR var_pesquisa

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE CURSOR","cq_cons")
       RETURN 
   END IF

   FREE var_pesquisa

   OPEN cq_cons

   IF  STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_cons")
       RETURN 
   END IF
      
   FETCH cq_cons INTO m_num_ordem


   IF STATUS <> 0 THEN
      IF STATUS <> 100 THEN
         CALL log003_err_sql("FETCH CURSOR","cq_cons")
      ELSE
         LET m_msg = 'Não a dados, para os argumentos informados.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN 
   END IF

    IF NOT pol1321_exibe_dados() THEN
       LET m_msg = 'Operação cancelada'
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN 
    END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
    
   LET m_ies_cons = TRUE
   
   LET m_num_ordema = m_num_ordem
   
END FUNCTION

#-----------------------------#
FUNCTION pol1321_exibe_dados()#
#-----------------------------#
   
   CALL pol1321_limpa_campos()

   SELECT cod_item, qtd_planej, num_docum, 
          (qtd_planej - qtd_refug - qtd_boas - qtd_sucata),
          cod_roteiro,
          num_altern_roteiro,
          cod_local_estoq,
          cod_local_prod,
          num_lote,
          ies_baixa_comp,
          num_neces
     INTO mr_cabec.cod_item,
          mr_cabec.qtd_planej,
          mr_cabec.num_docum,
          mr_cabec.qtd_saldo,
          m_cod_roteiro,
          m_num_altern,
          m_cod_local_estoq,
          m_cod_local_prod,
          m_num_lote,
          m_ies_baixa,
          m_neces_op         
    FROM ordens
   WHERE cod_empresa = p_cod_empresa
     AND num_ordem = m_num_ordem
                    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens:ED')
      RETURN FALSE 
   END IF
   
   LET mr_cabec.num_ordem = m_num_ordem
   CALL pol1321_le_item(mr_cabec.cod_item) RETURNING p_status
   LET mr_cabec.den_item = m_den_item

   CALL pol1321_le_pedido(mr_cabec.num_docum) RETURNING p_status
   LET mr_cabec.cod_cliente = m_cod_cliente
   LET mr_cabec.nom_cliente = m_nom_cliente
   LET mr_cabec.sdo_estoque = pol1321_le_estoque(mr_cabec.cod_item)
   LET mr_cabec.tip_produto = pol1321_le_tipo(mr_cabec.cod_item)
   
   CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",TRUE)
   LET m_carregando = TRUE
   LET p_status = pol1321_le_apo_mest()
   CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
   LET m_carregando = FALSE
      
   RETURN p_status

END FUNCTION

#------------------------------#
FUNCTION pol1321_le_item(l_cod)#
#------------------------------#

   DEFINE l_cod        CHAR(15)
   
   SELECT den_item,
          cod_unid_med
     INTO m_den_item,
          m_cod_unid
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_cod

   IF STATUS <> 0 THEN
      LET m_den_item = ''
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1321_le_pedido(l_docum)#
#----------------------------------#

   DEFINE l_docum        CHAR(15)
   
   CALL pol1321_pega_pedido(l_docum)
   
   SELECT cod_cliente
     INTO m_cod_cliente
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido

   IF STATUS <> 0 THEN
      LET m_cod_cliente = ''
      LET m_nom_cliente = ''
      RETURN TRUE
   END IF
   
   SELECT nom_cliente
     INTO m_nom_cliente
     FROM clientes
    WHERE cod_cliente = m_cod_cliente
    
   IF STATUS <> 0 THEN
      LET m_nom_cliente = ''
   END IF
    
   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol1321_pega_pedido(l_docum)#
#------------------------------------#

   DEFINE p_carac     CHAR(01),
          p_numpedido CHAR(6),
          p_numseq    CHAR(3),
          l_docum     CHAR(15),
          p_ind       INTEGER

   INITIALIZE p_numpedido, p_numseq TO NULL

   FOR p_ind = 1 TO LENGTH(l_docum)
       LET p_carac = l_docum[p_ind]
       IF p_carac = '/' THEN
          EXIT FOR
       END IF
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numpedido = p_numpedido CLIPPED, p_carac
       END IF
   END FOR
         
   FOR p_ind = p_ind + 1 TO LENGTH(l_docum)
       LET p_carac = l_docum[p_ind]
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numseq = p_numseq CLIPPED, p_carac
       END IF
   END FOR
   
   LET m_num_pedido = p_numpedido
   LET m_num_seq = p_numseq

END FUNCTION

#---------------------------------#
FUNCTION pol1321_le_estoque(l_cod)#
#---------------------------------#
   
   DEFINE l_qtd_reservada   DECIMAL(10,3),
          l_qtd_saldo       DECIMAL(10,3),
          l_cod             CHAR(15)
   
          
   SELECT SUM(qtd_saldo)
     INTO l_qtd_saldo
     FROM estoque_lote_ender
    WHERE cod_empresa   = p_cod_empresa
	    AND cod_item      = l_cod
	    AND cod_local     = m_cod_local_estoq
      AND ies_situa_qtd = 'L'
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_lote_ender')
      RETURN NULL
   END IF  

   IF m_qtd_saldo IS NULL THEN
      LET l_qtd_saldo = 0
      RETURN l_qtd_saldo
   END IF

   SELECT SUM(qtd_reservada)
     INTO l_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = l_cod
      AND cod_local   = m_cod_local_estoq
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_loc_reser')
      RETURN NULL
   END IF  
               
   IF l_qtd_reservada IS NULL OR l_qtd_reservada < 0 THEN
      LET l_qtd_reservada = 0
   END IF
   
   LET l_qtd_saldo = l_qtd_saldo - l_qtd_reservada
   
   RETURN l_qtd_saldo

END FUNCTION

#-------------------------------#
FUNCTION pol1321_le_tipo(l_item)#
#-------------------------------#

   DEFINE l_item      CHAR(15),
          l_familia   CHAR(05)
   
   LET l_tipo_item = NULL
   LET m_acessorio = FALSE
   
   SELECT cod_familia
	   INTO l_familia
	   FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item    = l_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item;cod_familia')
      RETURN l_tipo_item
   END IF

   IF l_familia = '202' THEN
      LET l_tipo_item = 'ACESSÓRIO'
      LET m_acessorio = TRUE
      RETURN l_tipo_item
   END IF
   
   SELECT COUNT(cod_empresa)
     INTO m_count
     FROM item_chapa_885
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido
      AND num_sequencia = m_num_seq
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item_chapa_885')
      RETURN l_tipo_item
   END IF
   
   IF m_count > 0 THEN
      LET l_tipo_item = 'CHAPA'
      RETURN l_tipo_item
   END IF
   
   SELECT COUNT(cod_empresa)
     INTO m_count
     FROM item_caixa_885
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido
      AND num_sequencia = m_num_seq
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item_caixa_885')
      RETURN l_tipo_item
   END IF
   
   IF m_count > 0 THEN
      LET l_tipo_item = 'CAIXA'
   END IF

   RETURN l_tipo_item

END FUNCTION

#-----------------------------#
FUNCTION pol1321_le_apo_mest()#
#-----------------------------#
   
   DEFINE l_tip_producao    CHAR(01),
          l_qtde            DECIMAL(10,3),
          l_seq_mestre      INTEGER,
          l_boas            DECIMAL(10,3),
          l_refugo          DECIMAL(10,3),
          l_sucata          DECIMAL(10,3),
          l_estornada       DECIMAL(10,3)
   

   IF mr_cabec.tip_produto[1,2] = 'CH' AND m_neces_op > 0 THEN # CHAPA
      IF NOT POL1321_le_peso() THEN
         RETURN FALSE
      END IF
      LET m_peso_item = 1
   ELSE
      LET m_peso_item = 1
   END IF
   
   LET m_ind = 1
   
   DECLARE cq_ap_mest CURSOR FOR
    SELECT a.seq_reg_mestre,
           a.data_producao,
           a.data_apontamento,
           a.hor_apontamento,
           a.usu_apontamento
      FROM man_apo_mestre a, man_apo_detalhe b
     WHERE a.empresa = p_cod_empresa 
       AND a.ordem_producao = m_num_ordem
       AND a.sit_apontamento = 'A'
       AND b.empresa = a.empresa
       AND b.seq_reg_mestre = a.seq_reg_mestre
       AND b.nome_programa = 'POL1321'

   FOREACH cq_ap_mest INTO
           l_seq_mestre,  
           ma_itens[m_ind].data_producao,   
           ma_itens[m_ind].data_apontamento,
           ma_itens[m_ind].hor_apontamento, 
           ma_itens[m_ind].usu_apontamento  

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','man_apo_mestre')
         RETURN FALSE
      END IF

      DECLARE cq_item CURSOR FOR
       SELECT tip_producao,
              qtd_produzida,
              qtd_convertida,
              seq_registro_item,
              item_produzido
         FROM man_item_produzido
        WHERE empresa = p_cod_empresa 
          AND seq_reg_mestre = l_seq_mestre
          AND tip_movto = 'N'
              
      FOREACH cq_item INTO
              l_tip_producao,
              ma_itens[m_ind].qtd_produzida,
              ma_itens[m_ind].qtd_convertida,
              ma_itens[m_ind].seq_registro_item,
              ma_itens[m_ind].item_produzido

         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','man_item_produzido:cq_item')
            RETURN FALSE
         END IF
         
         LET ma_itens[m_ind].seq_reg_mestre = l_seq_mestre
         
         IF mr_cabec.tip_produto[1,2] = 'CH' AND m_neces_op > 0 THEN
         
            SELECT qtd_boas, qtd_refugo, qtd_sucata, qtd_estornada
              INTO l_boas, l_refugo, l_sucata, l_estornada
              FROM man_apont_912 
             WHERE cod_empresa = p_cod_empresa
               AND seq_reg_mestre = l_seq_mestre
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','man_apont_912:1')
               RETURN FALSE
            END IF
            
            LET ma_itens[m_ind].qtd_estornada = l_estornada
            LET ma_itens[m_ind].qtd_convertida = ma_itens[m_ind].qtd_produzida
            
            IF l_tip_producao = 'B' THEN
               LET ma_itens[m_ind].qtd_produzida = l_boas
            END IF

            IF l_tip_producao = 'R' THEN
               LET ma_itens[m_ind].qtd_produzida = l_refugo
            END IF
            
            IF l_tip_producao = 'S' THEN
               LET ma_itens[m_ind].qtd_produzida = l_sucata
            END IF
        
         ELSE
            IF l_tip_producao = 'S' THEN
               LET l_qtde = ma_itens[m_ind].qtd_produzida
               LET ma_itens[m_ind].qtd_produzida = ma_itens[m_ind].qtd_convertida
               LET ma_itens[m_ind].qtd_convertida = l_qtde
         
               SELECT SUM(qtd_convertida)
                 INTO ma_itens[m_ind].qtd_estornada
                 FROM man_item_produzido
                WHERE empresa = p_cod_empresa 
                  AND seq_reg_mestre = ma_itens[m_ind].seq_reg_mestre
                  AND seq_reg_normal = ma_itens[m_ind].seq_registro_item
                  AND tip_movto = 'E'
            ELSE
               SELECT SUM(qtd_produzida)
                 INTO ma_itens[m_ind].qtd_estornada
                 FROM man_item_produzido
                WHERE empresa = p_cod_empresa 
                  AND seq_reg_mestre = ma_itens[m_ind].seq_reg_mestre
                  AND seq_reg_normal = ma_itens[m_ind].seq_registro_item
                  AND tip_movto = 'E'
            END IF
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','man_item_produzido:sum')
               RETURN FALSE
            END IF
         END IF
         
         IF ma_itens[m_ind].qtd_estornada IS NULL THEN
            LET ma_itens[m_ind].qtd_estornada = 0
         END IF
                                    
         LET ma_itens[m_ind].sdo_apont = 
             ma_itens[m_ind].qtd_produzida - ma_itens[m_ind].qtd_estornada
         
         IF l_tip_producao = 'B' THEN
            LET ma_itens[m_ind].tip_producao = 'BOA'
         ELSE
            IF l_tip_producao = 'S' THEN
               LET ma_itens[m_ind].tip_producao = 'SUCATA'
            ELSE
               LET ma_itens[m_ind].tip_producao = 'REFUGO'
            END IF
         END IF
                  
         LET ma_itens[m_ind].estornar = 'N'
         LET ma_itens[m_ind].qtd_estornar = 0
         
         LET m_ind = m_ind + 1
         
         IF m_ind > 100 THEN
            LET m_msg = 'O numero de apontamentos superou /n o número de linhas da grade'
            CALL log0030_mensagem(m_msg,'info')
            EXIT FOREACH
         END IF
         
      END FOREACH
      
   END FOREACH

   LET m_ind = m_ind - 1

   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_ind)
   
   RETURN TRUE

END FUNCTION


#--------------------------#
FUNCTION pol1321_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa. Faça uma pesquisa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#----------------------------------#
FUNCTION pol1321_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1321_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_num_ordema = m_num_ordem

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_num_ordem
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_num_ordem
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_num_ordem
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_num_ordem
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_num_ordem = m_num_ordema
         EXIT WHILE
      ELSE
         SELECT 1
           FROM ordens
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem = m_num_ordem
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1321_exibe_dados()
               LET l_achou = TRUE
               EXIT WHILE
            ELSE 
               CALL log003_err_sql("FETCH CURSOR","cq_cons")
               EXIT WHILE
            END IF
         END IF
      END IF               
   
   END WHILE
   
   RETURN l_achou
   
END FUNCTION

#-----------------------#
FUNCTION pol1321_first()#
#-----------------------#

   IF NOT pol1321_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1321_next()#
#----------------------#

   IF NOT pol1321_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1321_previous()#
#--------------------------#

   IF NOT pol1321_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1321_last()#
#----------------------#

   IF NOT pol1321_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1321_estornar()#
#--------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT pol1321_ies_cons() THEN
      RETURN FALSE
   END IF
   
   CALL pol1321_ativa_desativa(TRUE)
   CALL _ADVPL_set_property(m_browse,"SELECT_ITEM",1,12)

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1321_confirma_estorno()#
#----------------------------------#
   
   DEFINE l_qtd_lin    SMALLINT
   
   LET l_qtd_lin = _ADVPL_get_property(m_browse,"ITEM_COUNT")
   LET m_count = 0
   
   FOR m_ind = 1 TO l_qtd_lin
       IF ma_itens[m_ind].estornar = 'S' THEN
          LET m_count = m_count + 1
       END IF          
   END FOR

   IF m_count = 0 THEN
      LET m_msg = 'Nelhum apontemaento foi selecionado p/ estorno.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF  
   
   CALL pol1321_ativa_desativa(FALSE)

   LET m_deu_erro = FALSE
   
   CALL LOG_progresspopup_start("Estornando...","pol1321_proces_estorno","PROCESS")   
   
   IF m_deu_erro THEN   
      CALL pol1321_add_error()
   END IF

   IF m_cod_status = '2' THEN   
      CALL pol1321_mostra_erro_apont()
   END IF

   LET p_status = pol1321_exibe_dados()
      
   RETURN TRUE
            
   
END FUNCTION

#---------------------------#
FUNCTION pol1321_add_error()#
#---------------------------#
   
   LET m_qtd_erro = m_qtd_erro + 1
   
   DECLARE cq_add_er CURSOR FOR
    SELECT num_ordem,  erro
      FROM apont_erro_912
   
   FOREACH cq_add_er INTO ma_erros[m_qtd_erro].*
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_add_er')
         EXIT FOREACH
      END IF
      
      LET m_qtd_erro = m_qtd_erro + 1

      IF m_qtd_erro > 100 THEN
         LET m_msg = 'Limite de erros ultrapassou o previsto.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH

END FUNCTION   

#------------------------------#
FUNCTION pol1321_cancela_estorno()
#------------------------------#

   CALL log085_transacao("ROLLBACK")      
    
   LET m_num_ordem = m_num_ordema
   CALL pol1321_exibe_dados()
   CALL pol1321_ativa_desativa(FALSE)

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1321_apontar()#
#-------------------------#
   
    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_confirma    VARCHAR(10),
           l_cancela     VARCHAR(10),
           l_label       VARCHAR(10)

    IF NOT pol1321_ies_cons() THEN
       RETURN FALSE
    END IF

   IF NOT pol1321_le_item_man(mr_cabec.cod_item) THEN
      RETURN FALSE
   END IF
   
   IF m_ies_apont = '2' THEN
   ELSE
      LET m_msg = 'A opção Aponta por Operação está ativada.\n',
                  'Desmarque essa opção antes de apontar a OF.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

    INITIALIZE mr_apont TO NULL
    
    LET m_form_apont = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_apont,"SIZE",900,500) #400
    CALL _ADVPL_set_property(m_form_apont,"TITLE","INFORMAÇÕES PARA O APONTAMENTO")
    CALL _ADVPL_set_property(m_form_apont,"ENABLE_ESC_CLOSE",FALSE)

    LET m_barra_apont = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_apont)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_apont)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",40)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) #vermelho,verde,azul

    LET l_label = _ADVPL_create_component(NULL,"LCLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",160,20)     
    CALL _ADVPL_set_property(l_label,"TEXT","OC CAMPOS EM NEGRITO SÃO OBRIGATÓRIOS")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_apont)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1321_info_dados(l_panel)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_apont)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)
    
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
   CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirma,"EVENT","pol1301_conf_apont")  

   LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancela,"EVENT","pol1301_canc_apont")     

    CALL _ADVPL_set_property(m_form_apont,"ACTIVATE",TRUE)
            
    RETURN TRUE
    
END FUNCTION

#-----------------------------------#
FUNCTION pol1321_info_dados(l_panel)#
#-----------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_turno           VARCHAR(10),
           l_label           VARCHAR(10),
           l_defeito         VARCHAR(10),
           l_den_cent_trab   VARCHAR(10),
           l_den_operac      VARCHAR(10)

    LET mr_apont.cod_turno = 3
    LET mr_apont.hor_ini = '00:00'
    LET mr_apont.hor_fim = '00:00'
    LET mr_apont.dat_ini = TODAY
    LET mr_apont.dat_fim = TODAY
    
    {LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,20)     
    CALL _ADVPL_set_property(l_label,"TEXT","Turno:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_turno = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_turno,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_turno,"POSITION",80,20)     
    CALL _ADVPL_set_property(m_turno,"LENGTH",3,0)
    CALL _ADVPL_set_property(m_turno,"PICTURE","@E ###")
    CALL _ADVPL_set_property(m_turno,"VARIABLE",mr_apont,"cod_turno")
    CALL _ADVPL_set_property(m_turno,"VALID","pol1321_valida_turno")

    LET m_lupa_tur = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_tur,"POSITION",120,20)     
    CALL _ADVPL_set_property(m_lupa_tur,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_tur,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_tur,"CLICK_EVENT","pol1321_zoom_turno")

    LET l_turno = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_turno,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_turno,"POSITION",160,20)     
    CALL _ADVPL_set_property(l_turno,"LENGTH",40) 
    CALL _ADVPL_set_property(l_turno,"VARIABLE",mr_apont,"den_turno")}

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,50)     
    CALL _ADVPL_set_property(l_label,"TEXT","Data inicial:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dat_ini = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel)
    CALL _ADVPL_set_property(m_dat_ini,"POSITION",105,50)     
    CALL _ADVPL_set_property(m_dat_ini,"VARIABLE",mr_apont,"dat_ini")

    {LET m_hor_ini = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_hor_ini,"POSITION",240,50)     
    CALL _ADVPL_set_property(m_hor_ini,"LENGTH",30) 
    CALL _ADVPL_set_property(m_hor_ini,"PICTURE","@E ##:##")
    CALL _ADVPL_set_property(m_hor_ini,"VARIABLE",mr_apont,"hor_ini")}

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",265,50)     
    CALL _ADVPL_set_property(l_label,"TEXT","Data final:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_dat_fim = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel)
    CALL _ADVPL_set_property(m_dat_fim,"POSITION",340,50)     
    CALL _ADVPL_set_property(m_dat_fim,"VARIABLE",mr_apont,"dat_fim")

    {LET m_hor_fim = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_hor_fim,"POSITION",240,80)     
    CALL _ADVPL_set_property(m_hor_fim,"LENGTH",30) 
    CALL _ADVPL_set_property(m_hor_fim,"PICTURE","@E ##:##")
    CALL _ADVPL_set_property(m_hor_fim,"VARIABLE",mr_apont,"hor_fim")}

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,80)     
    CALL _ADVPL_set_property(l_label,"TEXT","Qtde boas:")    

    LET m_boa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_boa,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_boa,"POSITION",105,80)     
    CALL _ADVPL_set_property(m_boa,"LENGTH",6,0)
    CALL _ADVPL_set_property(m_boa,"PICTURE","@E ######")
    CALL _ADVPL_set_property(m_boa,"VARIABLE",mr_apont,"boa")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",175,80)     
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd retrabalho:")    

    LET m_boa_retrab = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_boa_retrab,"EDITABLE",m_acessorio) 
    CALL _ADVPL_set_property(m_boa_retrab,"POSITION",265,80)     
    CALL _ADVPL_set_property(m_boa_retrab,"LENGTH",6,0)
    CALL _ADVPL_set_property(m_boa_retrab,"PICTURE","@E ######")
    CALL _ADVPL_set_property(m_boa_retrab,"VARIABLE",mr_apont,"boa_retrab")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,110)     
    CALL _ADVPL_set_property(l_label,"TEXT","Qtde sucatas:")    

    LET m_sucata = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_sucata,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_sucata,"POSITION",105,110)     
    CALL _ADVPL_set_property(m_sucata,"LENGTH",6,0)
    CALL _ADVPL_set_property(m_sucata,"PICTURE","@E ######")
    CALL _ADVPL_set_property(m_sucata,"VARIABLE",mr_apont,"sucata")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",175,110)     
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd retrabalho:")    

    LET m_sucata_retrab = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_sucata_retrab,"EDITABLE",m_acessorio) 
    CALL _ADVPL_set_property(m_sucata_retrab,"POSITION",265,110)     
    CALL _ADVPL_set_property(m_sucata_retrab,"LENGTH",6,0)
    CALL _ADVPL_set_property(m_sucata_retrab,"PICTURE","@E ######")
    CALL _ADVPL_set_property(m_sucata_retrab,"VARIABLE",mr_apont,"sucata_retrab")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,140)     
    CALL _ADVPL_set_property(l_label,"TEXT","Qtde refugos:")    

    LET m_refugo = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_refugo,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_refugo,"POSITION",105,140)     
    CALL _ADVPL_set_property(m_refugo,"LENGTH",6,0)
    CALL _ADVPL_set_property(m_refugo,"PICTURE","@E ######")
    CALL _ADVPL_set_property(m_refugo,"VARIABLE",mr_apont,"refugo")
    CALL _ADVPL_set_property(m_refugo,"VALID","pol1321_valida_refugo")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",175,140)     
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd retrabalho:")    

    LET m_refugo_retrab = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_refugo_retrab,"EDITABLE",m_acessorio) 
    CALL _ADVPL_set_property(m_refugo_retrab,"POSITION",265,140)     
    CALL _ADVPL_set_property(m_refugo_retrab,"LENGTH",6,0)
    CALL _ADVPL_set_property(m_refugo_retrab,"PICTURE","@E ######")
    CALL _ADVPL_set_property(m_refugo_retrab,"VARIABLE",mr_apont,"refugo_retrab")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,170)     
    CALL _ADVPL_set_property(l_label,"TEXT","Defeito:")    

    LET m_defeito = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_defeito,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_defeito,"POSITION",105,170)     
    CALL _ADVPL_set_property(m_defeito,"LENGTH",3,0)
    CALL _ADVPL_set_property(m_defeito,"PICTURE","@E ###")
    CALL _ADVPL_set_property(m_defeito,"VARIABLE",mr_apont,"cod_defeito")
    CALL _ADVPL_set_property(m_defeito,"VALID","pol1321_valida_defeito")

    LET m_lupa_def = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_def,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_lupa_def,"POSITION",140,170)     
    CALL _ADVPL_set_property(m_lupa_def,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_def,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_def,"CLICK_EVENT","pol1321_zoom_defeito")

    LET l_defeito = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_defeito,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_defeito,"POSITION",180,170)     
    CALL _ADVPL_set_property(l_defeito,"LENGTH",30) 
    CALL _ADVPL_set_property(l_defeito,"VARIABLE",mr_apont,"den_defeito")

    CALL _ADVPL_set_property(m_boa,"GET_FOCUS")

END FUNCTION

#------------------------------#
FUNCTION pol1321_valida_turno()#
#------------------------------#

    CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT", '')
    
    IF  mr_apont.cod_turno IS NULL THEN
        CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT","Informe o turno.")
        RETURN FALSE
    END IF
      
   IF NOT pol1321_le_turno(mr_apont.cod_turno) THEN
      CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION 
   
#-------------------------------#
FUNCTION pol1321_le_turno(l_cod)#
#-------------------------------#

   DEFINE l_cod       INTEGER
   
   LET m_msg = NULL
   
   SELECT den_turno,
          hor_ini_normal,
          hor_fim_normal
     INTO mr_apont.den_turno, m_ini, m_fim
     FROM turno
    WHERE cod_empresa = p_cod_empresa
      AND cod_turno = l_cod

   IF STATUS = 100 THEN
      LET m_msg = 'Turno inexistente no Logix.'
   ELSE
      IF STATUS = 0 THEN
         LET mr_apont.den_turno = mr_apont.den_turno CLIPPED , 
              '  ', m_ini, ' - ', m_fim
         RETURN TRUE
      ELSE
         CALL log003_err_sql('SELECT','turno')
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION
                       
#----------------------------#
FUNCTION pol1321_zoom_turno()#
#----------------------------#
    
   DEFINE l_codigo      LIKE turno.cod_turno,
          l_descricao   LIKE turno.den_turno
          
   IF  m_zoom_tur IS NULL THEN
       LET m_zoom_tur = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_tur,"ZOOM","zoom_turno")
   END IF

   CALL _ADVPL_get_property(m_zoom_tur,"ACTIVATE")

   LET l_codigo    = _ADVPL_get_property(m_zoom_tur,"RETURN_BY_TABLE_COLUMN","turno","cod_turno")
   LET l_descricao = _ADVPL_get_property(m_zoom_tur,"RETURN_BY_TABLE_COLUMN","turno","den_turno")

   IF l_codigo IS NOT NULL THEN
      LET mr_apont.cod_turno = l_codigo
      CALL pol1321_le_turno(l_codigo)
   END IF
    
END FUNCTION

#-------------------------------#
FUNCTION pol1321_valida_refugo()#
#-------------------------------#

    CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT", '')

    IF  mr_apont.refugo IS NULL OR 
           mr_apont.refugo = ' ' OR
           mr_apont.refugo = 0 THEN
        LET mr_apont.cod_defeito = NULL
        LET mr_apont.den_defeito = NULL
        CALL _ADVPL_set_property(m_defeito,"EDITABLE",FALSE)
        CALL _ADVPL_set_property(m_lupa_def,"EDITABLE",FALSE)
        RETURN TRUE
    END IF

    CALL _ADVPL_set_property(m_defeito,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_lupa_def,"EDITABLE",TRUE)

    RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1321_valida_defeito()#
#--------------------------------#

    CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT", '')
    
    IF  mr_apont.cod_defeito IS NULL THEN
        CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT","Informe o defeito.")
        RETURN FALSE
    END IF
      
   IF NOT pol1321_le_defeito(mr_apont.cod_defeito) THEN
      CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION 
   
#---------------------------------#
FUNCTION pol1321_le_defeito(l_cod)#
#---------------------------------#

   DEFINE l_cod       DECIMAL(3,0)
   
   LET m_msg = NULL
   
   SELECT den_defeito
     INTO mr_apont.den_defeito
     FROM defeito
    WHERE cod_empresa = p_cod_empresa
      AND cod_defeito = l_cod

   IF STATUS = 100 THEN
      LET m_msg = 'Defeito não cadastrado no Logix.'
   ELSE
      IF STATUS = 0 THEN
         RETURN TRUE
      ELSE
         CALL log003_err_sql('SELECT','turno')
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION
                       
#------------------------------#
FUNCTION pol1321_zoom_defeito()#
#------------------------------#
    
   DEFINE l_codigo      LIKE defeito.cod_defeito,
          l_descricao   LIKE defeito.den_defeito
          
   IF  m_zoom_def IS NULL THEN
       LET m_zoom_def = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_def,"ZOOM","zoom_defeito")
   END IF

   CALL _ADVPL_get_property(m_zoom_def,"ACTIVATE")

   LET l_codigo    = _ADVPL_get_property(m_zoom_def,"RETURN_BY_TABLE_COLUMN","defeito","cod_defeito")
   LET l_descricao = _ADVPL_get_property(m_zoom_def,"RETURN_BY_TABLE_COLUMN","defeito","den_defeito")

   IF l_codigo IS NOT NULL THEN
      LET mr_apont.cod_defeito = l_codigo
      LET mr_apont.den_defeito = l_descricao
   END IF
    
END FUNCTION

    
#----------------------------#
FUNCTION pol1301_canc_apont()#
#----------------------------#

   CALL _ADVPL_set_property(m_form_apont,"ACTIVATE",FALSE)
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_conf_apont()#
#----------------------------#
   
   DEFINE l_hor_ini, l_hor_fim CHAR(04)
   
   CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT", '')
    
   IF  mr_apont.cod_turno IS NULL THEN
       CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT","Informe o turno.")
       RETURN FALSE
   END IF

   IF mr_apont.dat_ini IS NULL THEN
      CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT","Informe a data inicial!")
      CALL _ADVPL_set_property(m_dat_ini,"GET_FOCUS")
      RETURN FALSE      
   END IF

   IF mr_apont.dat_fim IS NULL THEN
      CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT","Informe a data final!")
      CALL _ADVPL_set_property(m_dat_fim,"GET_FOCUS")
      RETURN FALSE      
   END IF
   
   IF mr_apont.dat_fim < mr_apont.dat_ini THEN
      CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT","Período inválido!")
      CALL _ADVPL_set_property(m_dat_ini,"GET_FOCUS")
      RETURN FALSE      
   END IF

   IF mr_apont.hor_ini IS NULL THEN
      CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT","Informe a data inicial!")
      CALL _ADVPL_set_property(m_hor_ini,"GET_FOCUS")
      RETURN FALSE      
   END IF

   IF mr_apont.hor_fim IS NULL THEN
      CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT","Informe a data final!")
      CALL _ADVPL_set_property(m_hor_fim,"GET_FOCUS")
      RETURN FALSE      
   END IF
   
   IF mr_apont.hor_fim < mr_apont.hor_ini THEN
      CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT","Horário inválido!")
      CALL _ADVPL_set_property(m_hor_ini,"GET_FOCUS")
      RETURN FALSE      
   END IF

   LET l_hor_ini = mr_apont.hor_ini[1,2],mr_apont.hor_ini[4,5]
   LET l_hor_fim = mr_apont.hor_fim[1,2],mr_apont.hor_fim[4,5]
   
   IF l_hor_ini < m_ini OR l_hor_fim > m_fim THEN
      LET m_msg = 'Horário informado está fora do horário do turno.'
      CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_hor_ini,"GET_FOCUS")
      RETURN FALSE      
   END IF   

   IF mr_apont.boa IS NULL OR mr_apont.boa <= 0 THEN
      LET mr_apont.boa = 0
      LET mr_apont.boa_retrab = 0
   END IF

   IF mr_apont.sucata IS NULL OR mr_apont.sucata <= 0 THEN
      LET mr_apont.sucata = 0
      LET mr_apont.sucata_retrab = 0
   END IF

   IF mr_apont.refugo IS NULL OR mr_apont.refugo <= 0 THEN
      LET mr_apont.refugo = 0
      LET mr_apont.refugo_retrab = 0
   END IF

   LET m_total = mr_apont.boa + mr_apont.sucata + mr_apont.refugo

   IF m_total = 0 THEN
      LET m_msg = 'Informe a qtd boas e/ou qtd_sucata e/ou qtd refugo.'
      CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_boa,"GET_FOCUS")
      RETURN FALSE      
   END IF
      
   IF m_total > mr_cabec.qtd_saldo AND m_ies_forca = 'N' THEN
      LET m_msg = 'Somatória dos apontamentos maior que saldo da OF.'
      CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_boa,"GET_FOCUS")
      RETURN FALSE      
   END IF

   IF mr_apont.refugo > 0 THEN 
      IF mr_apont.cod_defeito IS NULL THEN
         LET m_msg = 'Informe o código do defeito.'
         CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT",m_msg)
         CALL _ADVPL_set_property(m_defeito,"GET_FOCUS")
         RETURN FALSE   
      ELSE
         IF NOT pol1321_le_defeito(mr_apont.cod_defeito) THEN
            CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT",m_msg)
            RETURN FALSE
         END IF
      END IF
   END IF
   
   {IF NOT LOG_question("Confirma o apontamento?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF}
   
   IF NOT m_acessorio THEN
      LET mr_apont.boa_retrab = 0
      LET mr_apont.refugo_retrab = 0
      LET mr_apont.sucata_retrab = 0
   END IF   
   
   IF mr_apont.boa_retrab IS NULL THEN
      LET mr_apont.boa_retrab = 0
   END IF

   IF mr_apont.refugo_retrab IS NULL THEN
      LET mr_apont.refugo_retrab = 0
   END IF

   IF mr_apont.sucata_retrab IS NULL THEN
      LET mr_apont.sucata_retrab = 0
   END IF
      
   LET m_qtd_retrab = mr_apont.boa_retrab + mr_apont.refugo_retrab + mr_apont.sucata_retrab
   
   IF m_qtd_retrab IS NULL THEN
      LET m_qtd_retrab = 0
   END IF
   
   LET m_qtd_chapa = m_total - m_qtd_retrab
   
   CALL _ADVPL_set_property(m_barra_apont,"ERROR_TEXT", "Aguarde! Apontando...")           
   
   CALL LOG_progresspopup_start("Apontando...","pol1321_proces_apont","PROCESS")   
   
   CALL _ADVPL_set_property(m_form_apont,"ACTIVATE",FALSE)
   
   IF m_deu_erro THEN   
      CALL pol1321_add_error()
   END IF

   IF m_qtd_erro = 0 THEN   
      LET p_status = pol1321_exibe_dados()
   ELSE
      CALL pol1321_mostra_erro_apont()
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1321_le_item_man(l_cod)#
#----------------------------------#

   DEFINE l_cod       CHAR(15)
   
   SELECT ies_forca_apont,
          ies_apontamento
     INTO m_ies_forca,
          m_ies_apont
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item_man')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
         
#------------------------------#
FUNCTION pol1321_proces_apont()#
#------------------------------#

   DEFINE l_progres     SMALLINT

   CALL LOG_progresspopup_set_total("PROCESS",3)
   
   DELETE FROM man_apont_912
    WHERE cod_empresa = p_cod_empresa
      AND cod_status = '0'

   DELETE FROM apont_erro_912
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','apont_erro_912')
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1321_coleta_dados() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN 
   END IF
   
   CALL log085_transacao("COMMIT")
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")

   LET m_msg = NULL
   
   CALL log085_transacao("BEGIN")

   IF NOT pol1321_le_apont() THEN
      CALL log085_transacao("ROLLBACK")
      IF m_msg IS NOT NULL THEN
         CALL log0030_mensagem(m_msg,'info')
      END IF
   END IF

   CALL log085_transacao("BEGIN")

   LET l_progres = LOG_progresspopup_increment("PROCESS")

END FUNCTION

#------------------------------#
FUNCTION pol1321_coleta_dados()#
#------------------------------#
   
   DEFINE l_qtd_boas        DECIMAL(10,3)
   
   INITIALIZE mr_man_apont.* TO NULL
       
   SELECT *
     INTO p_parametros_885.*
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('select','parametros_885')
      RETURN FALSE
   END IF

   SELECT MAX(id_registro)
     INTO mr_man_apont.id_registro
     FROM man_apont_912
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','man_apont_912:2')
      RETURN FALSE
   END IF
   
   IF mr_man_apont.id_registro IS NULL THEN
      LET mr_man_apont.id_registro = 0
   END IF

   LET mr_man_apont.cod_empresa = p_cod_empresa    
   LET mr_man_apont.cod_recur = '     '   
   LET mr_man_apont.cod_operac = '     '
   LET mr_man_apont.oper_final = 'S'
   LET mr_man_apont.cod_cent_trab = '     '   
   LET mr_man_apont.cod_cent_cust = 0
   LET mr_man_apont.cod_unid_prod = '     '   
   LET mr_man_apont.cod_arranjo = '     '    
   LET mr_man_apont.comprimento = 0
   LET mr_man_apont.largura = 0
   LET mr_man_apont.altura = 0
   LET mr_man_apont.diametro = 0
   LET mr_man_apont.qtd_hor = 0
   LET mr_man_apont.dat_atualiz = TODAY   
   LET mr_man_apont.ies_terminado = 'N'      
   LET mr_man_apont.nom_prog = 'POL1321' 
   LET mr_man_apont.nom_usuario = p_user
   LET mr_man_apont.dat_process = TODAY     
   LET mr_man_apont.integrado =  0 
   LET mr_man_apont.usuario = p_user        
   LET mr_man_apont.tip_integra = 'A'    
   LET mr_man_apont.concluido = 'N'     
   LET mr_man_apont.qtd_tempo = 0
   LET mr_man_apont.dat_criacao = CURRENT
   LET mr_man_apont.cod_status = '0'
   LET mr_man_apont.tip_operacao = 'A'   
   LET mr_man_apont.qtd_estornada = 0
   LET mr_man_apont.qtd_retrab = 0
   LET mr_man_apont.num_lote = NULL
   LET mr_man_apont.qtd_refugo = 0
   LET mr_man_apont.qtd_sucata = 0
   LET mr_man_apont.qtd_boas = 0
   LET mr_man_apont.tip_movto = 'B'
   LET mr_man_apont.num_pedido = m_num_pedido
   LET mr_man_apont.num_seq_pedido = m_num_seq
   LET mr_man_apont.cod_turno = mr_apont.cod_turno
   LET mr_man_apont.hor_inicial = mr_apont.hor_ini
   LET mr_man_apont.hor_final = mr_apont.hor_fim
   LET mr_man_apont.num_docum = mr_cabec.num_docum 
   LET mr_man_apont.qtd_movto = m_total
   LET mr_man_apont.dat_inicial = mr_apont.dat_ini   
   LET mr_man_apont.dat_final = mr_apont.dat_fim
   
   IF NOT pol1321_le_op_chapa('A') THEN #se não quiser apontar a chapa, comente esse if
      RETURN FALSE
   END IF
   
   LET mr_man_apont.num_ordem = mr_cabec.num_ordem   
   LET mr_man_apont.cod_item = mr_cabec.cod_item      
   LET mr_man_apont.cod_roteiro = m_cod_roteiro
   LET mr_man_apont.num_rot_alt = m_num_altern
   LET mr_man_apont.cod_local_prod = m_cod_local_prod
   LET mr_man_apont.cod_local_est = m_cod_local_estoq

   IF NOT pol1321_le_ctr_lote(mr_cabec.cod_item) THEN
      RETURN FALSE
   END IF

   IF m_ies_lote = 'S' THEN
      LET mr_man_apont.num_lote = m_num_lote
   END IF

   LET l_qtd_boas = mr_apont.boa + mr_apont.refugo + mr_apont.sucata
   
   LET g_tem_critica = FALSE
   LET l_parametro.cod_empresa = p_cod_empresa
   LET l_parametro.num_ordem = mr_man_apont.num_ordem
   LET l_parametro.qtd_apont = l_qtd_boas
   
   IF NOT pol1321_checa_saldo(l_parametro) THEN
      RETURN FALSE
   END IF
            
   IF g_tem_critica THEN
      LET m_qtd_erro = 0
      CALL pol1321_add_error()
      LET m_deu_erro = FALSE
      RETURN FALSE
   END IF
      
   IF mr_apont.boa > 0 THEN   
      LET mr_man_apont.qtd_refugo = 0
      LET mr_man_apont.qtd_sucata = 0
      LET mr_man_apont.qtd_boas = mr_apont.boa 
      LET mr_man_apont.tip_movto = 'B'
      IF m_acessorio THEN
         LET mr_man_apont.qtd_retrab = mr_apont.boa_retrab
      END IF
      IF NOT pol1321_ins_man_912() THEN
         RETURN FALSE
      END IF
   END IF

   IF mr_apont.refugo > 0 THEN   
      LET mr_man_apont.qtd_sucata = 0
      LET mr_man_apont.qtd_boas = 0
      LET mr_man_apont.qtd_refugo = mr_apont.refugo 
      LET mr_man_apont.tip_movto = 'R'
      IF m_acessorio THEN
         LET mr_man_apont.qtd_retrab = mr_apont.refugo_retrab
      END IF
      IF NOT pol1321_ins_man_912() THEN
         RETURN FALSE
      END IF
   END IF

   IF mr_apont.sucata > 0 THEN   
      IF NOT pol1321_le_ctr_lote(p_parametros_885.cod_item_sucata) THEN
         RETURN FALSE
      END IF
      IF m_ies_lote = 'S' THEN
         LET mr_man_apont.num_lote = p_parametros_885.num_lote_sucata
      ELSE
         LET mr_man_apont.num_lote = NULL
      END IF
      LET mr_man_apont.qtd_boas = 0
      LET mr_man_apont.qtd_refugo = 0
      LET mr_man_apont.qtd_sucata = mr_apont.sucata 
      LET mr_man_apont.tip_movto = 'S'      
      IF m_acessorio THEN
         LET mr_man_apont.qtd_retrab = mr_apont.sucata_retrab
      END IF
      IF NOT pol1321_ins_man_912() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1321_le_ctr_lote(l_cod)#
#----------------------------------#

   DEFINE l_cod            CHAR(15)
   
   SELECT ies_ctr_lote
     INTO m_ies_lote
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1321_ins_man_912()#
#-----------------------------#

   LET mr_man_apont.id_registro = mr_man_apont.id_registro + 1

   INSERT INTO man_apont_912
    VALUES(mr_man_apont.*)
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','man_apont_912')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION POL1321_le_peso()#
#-------------------------#
   
   SELECT qtd_necessaria
     INTO m_peso_item
     FROM ord_compon
    WHERE cod_empresa = p_cod_empresa
      AND cod_item_pai = m_neces_op

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ord_compon')
      RETURN FALSE
   END IF 
   
   RETURN TRUE

END FUNCTION   
 
#--------------------------#
FUNCTION pol1321_le_apont()#
#--------------------------#
         
   LET m_qtd_erro = 0
      				     
   DECLARE cq_apont CURSOR WITH HOLD FOR 	
    SELECT cod_empresa,
           cod_item,
           num_ordem,
           num_docum,
           cod_operac,
           num_seq_operac,
           cod_cent_trab,
           cod_turno,
           cod_arranjo,
           cod_eqpto,
           cod_ferramenta,
           hor_inicial,
           hor_final,
           qtd_refugo,
		       qtd_boas,
		       qtd_sucata,
           qtd_hor,
           cod_local_prod,
           cod_local_est, 
           dat_inicial,
           dat_final,
           matricula,
		       ies_terminado, 
		       id_registro,
		       num_lote, 
		       cod_roteiro, 
		       num_rot_alt,
		       unid_funcional,
		       cod_status,
		       tip_integra,
		       tip_movto,
		       qtd_tempo,
		       comprimento,
		       largura,
		       altura,
		       diametro,
		       qtd_retrab
      FROM man_apont_912
		 WHERE tip_operacao = 'A'
		   AND cod_status = '0'
		   AND cod_empresa = p_cod_empresa
	   ORDER BY id_registro
			         	 
	 FOREACH cq_apont INTO 	
	    p_w_apont_prod.cod_empresa,
			p_w_apont_prod.cod_item,
			p_w_apont_prod.num_ordem,
			p_w_apont_prod.num_docum,
			p_w_apont_prod.cod_operacao ,
			p_w_apont_prod.num_seq_operac,
			p_w_apont_prod.cod_cent_trab ,
			p_w_apont_prod.cod_turno ,
			p_w_apont_prod.cod_arranjo ,
			p_w_apont_prod.cod_equip ,
			p_w_apont_prod.cod_ferram ,
			p_w_apont_prod.hor_ini_periodo,
			p_w_apont_prod.hor_fim_periodo,
			p_w_apont_prod.qtd_refug,
			p_w_apont_prod.qtd_boas,
			m_qtd_sucata,
			p_w_apont_prod.qtd_total_horas ,
			p_w_apont_prod.cod_local ,
			p_w_apont_prod.cod_local_est ,
			p_w_apont_prod.dat_ini_prod ,
			p_w_apont_prod.dat_fim_prod ,
			p_w_apont_prod.num_operador ,
			p_w_apont_prod.finaliza_operacao,
			g_id_man_apont,
			p_w_apont_prod.num_lote,
			p_w_apont_prod.cod_roteiro,
			p_w_apont_prod.num_altern,
			p_w_apont_prod.num_secao_requis,
			m_cod_status,
			m_tip_integra,
			m_tip_movto,
			m_qtd_tempo,
		  m_comprimento,
		  m_largura,
		  m_altura,
		  m_diametro,
		  m_qtd_retrab

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO TABELA MAN_APONT_304'
         RETURN FALSE
      END IF 

      LET m_cod_status = '2'                                                                          
            
      DELETE FROM man_log_apo_prod
      DELETE FROM w_apont_prod
      
      LET p_w_apont_prod.seq_processo = 1
			LET p_w_apont_prod.qtd_refug = p_w_apont_prod.qtd_refug * m_peso_item
			LET p_w_apont_prod.qtd_boas = p_w_apont_prod.qtd_boas * m_peso_item
			LET m_qtd_sucata = m_qtd_sucata * m_peso_item
            
      IF NOT pol1321_ins_apont() THEN
         RETURN FALSE
      END IF

	    IF NOT pol1321_atu_man() THEN                                                                   	  
	       RETURN FALSE                                                                                      	  
	    END IF                                                                                          	  
            
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1321_ins_apont()#
#---------------------------#
   
   LET m_deu_erro = FALSE
   LET m_cod_item =  p_w_apont_prod.cod_item                                                            
          											                                                                      
   IF p_w_apont_prod.cod_ferram = ' '   OR                                                            
		   p_w_apont_prod.cod_ferram IS NULL THEN                                                       	
			 INITIALIZE p_w_apont_prod.cod_ferram  TO NULL                                                 	
			 LET p_w_apont_prod.ies_ferram_min =  "N"                                                      	
		ELSE                                                                                            	
				LET p_w_apont_prod.ies_ferram_min =  "S"                                                     	
		END IF 				                                                                                 	
		                                                                                                	
		IF p_w_apont_prod.cod_equip = ' '   OR                                                          	
		   p_w_apont_prod.cod_equip IS NULL THEN                                                        	
			 LET p_w_apont_prod.ies_equip_min = "N"                                                        	
		   INITIALIZE p_w_apont_prod.cod_equip  TO NULL		                                             	
   ELSE                                                                                               
			 LET p_w_apont_prod.ies_equip_min = "S"	                                                       	
	 END IF                                                                                          	
		
		LET m_qtd_conver = 0
		      			                                                                                     	
		IF m_qtd_sucata = 0 THEN                                                                        	
		   LET p_w_apont_prod.ies_sucata = 0                                                            	
		ELSE                                                                                            	
		   LET p_w_apont_prod.ies_sucata = 1                                                            	
		   LET m_cod_sucata = p_parametros_885.cod_item_sucata                                          	
                                                                                                      
      IF NOT pol1321_le_itens() THEN                                                                  
        RETURN FALSE                                                                                       
      END IF                                                                                          
                                                                                                      
      IF m_unid_item = m_unid_sucata THEN                                                             
         LET m_fat_conver = 1                                                                         
         LET m_qtd_conver = m_qtd_sucata                                                              
      ELSE                                                                                            
         LET m_fat_conver = m_pes_unit                                                                
         LET m_qtd_conver = m_qtd_sucata * m_fat_conver                                               
      END IF                                                                                          
                                                                                                      
      IF pol1321_w_sucata() THEN                                                                      
         INSERT INTO w_sucata                                                                         
   		     VALUES(m_cod_sucata, m_qtd_conver, m_fat_conver, m_qtd_sucata, 0  )                        
				  IF STATUS <> 0 THEN                                                  	                      	
				     LET m_msg = 'ERRO: ',m_erro CLIPPED, ' INSERINDO NA TAB W_SUCATA' 	                      	
		         RETURN FALSE                                                          	                    	
         END IF                                                                	                    	
   	 END IF                                                                                         	
	 END IF                                                                                             
	                                                                                                    
   IF p_w_apont_prod.qtd_refug > 0 THEN                                                            
      LET p_w_apont_prod.ies_defeito = 1                                                              
   ELSE                                                                                               
      LET p_w_apont_prod.ies_defeito = 0                                                              
   END IF                                                                                             
                                                                                                                                                                                                            
    LET p_w_apont_prod.dat_producao	        =	p_w_apont_prod.dat_ini_prod                             
		LET p_w_apont_prod.estorno_total        = "N"                                                   	
		LET p_w_apont_prod.cod_tip_movto        = 'N'                                                   	
		LET p_w_apont_prod.ies_sit_qtd 					=	'L'                                                  	
		LET p_w_apont_prod.ies_apontamento 			= '2'	                                                 	
		LET p_w_apont_prod.num_conta_ent				= NULL                                                   	
		LET p_w_apont_prod.num_conta_saida 			= NULL                                                 	
		LET p_w_apont_prod.num_programa 				= 'POL1321'                                              	
		LET p_w_apont_prod.nom_usuario 					= p_user                                               	
		LET p_w_apont_prod.cod_item_grade1 			= NULL                                                 	
		LET p_w_apont_prod.cod_item_grade2 			= NULL                                                 	
		LET p_w_apont_prod.cod_item_grade3 			= NULL                                                 	
		LET p_w_apont_prod.cod_item_grade4 			= NULL                                                 	
		LET p_w_apont_prod.cod_item_grade5 			= NULL                                                 	
		LET p_w_apont_prod.qtd_refug_ant 				= NULL                                                 	
		LET p_w_apont_prod.qtd_boas_ant 				= NULL                                                   	
		LET p_w_apont_prod.abre_transacao 			= 1                                                    	
		LET p_w_apont_prod.modo_exibicao_msg 		= 0                                                    	
		LET p_w_apont_prod.seq_reg_integra 			= NULL                                                 	
		LET p_w_apont_prod.endereco 						= ' '                                                    	
		LET p_w_apont_prod.identif_estoque 			= ' '                                                  	
		LET p_w_apont_prod.sku 									= ' '                                                  	
		LET p_w_apont_prod.ies_parada           = 0                                                     	
   
   LET m_refaz_compon = FALSE
   LET m_num_neces = 0
   
   IF m_acessorio AND m_qtd_retrab > 0 THEN
      IF NOT pol1321_alt_compon() THEN
         RETURN FALSE
      END IF      
      LET m_refaz_compon = TRUE
   END IF

   LET m_refaz_man = FALSE

   IF mr_cabec.tip_produto[1,2] = 'CA' THEN # CAIXA
      IF p_w_apont_prod.ies_sucata = 1 OR p_w_apont_prod.ies_defeito = 1 THEN
         IF NOT pol1321_alt_item_man() THEN
            RETURN FALSE
         END IF      
         LET m_refaz_man = TRUE
      END IF
   END IF         
                                                                                                         
   IF manr24_cria_w_comp_baixa (0) THEN                                                            
   END IF                                                                                             
                                                                                                      
   IF manr24_cria_w_apont_prod(0)  THEN                                                               
	                                                                                                 	  
      CALL man8246_cria_temp_fifo()                                                                
	    CALL man8237_cria_tables_man8237()                                                           		
	   								                                                                               		
      IF manr24_inclui_w_apont_prod(p_w_apont_prod.*) THEN # incluindo apontamento                  
	                                                                                                 		
   	    IF p_w_apont_prod.ies_defeito = 1  THEN             #apontando defeitos                    
 	 		     IF pol1321_w_defeito() THEN                                                             		
					      INSERT INTO w_defeito                                                                 	
					        VALUES(mr_apont.cod_defeito ,p_w_apont_prod.qtd_refug)                              	
				     END IF                                                                                   	
			    END IF                                                                                      	
				 				                                                                                      	
	 	    IF manr27_processa_apontamento()  THEN #processando apontamento                            		
	 	       LET m_cod_status = '1'                                                                  		
	 	    END IF                                                                                     		
	    ELSE                                                                                         		
	       LET m_txt_resumo = 'ERRO:',STATUS,'INCLUINDO TAB W_APONT_PROD'                            	  
	       INSERT INTO man_log_apo_prod(empresa,ordem_producao,texto_resumo)                         	  
	        VALUES(p_cod_empresa, m_num_ordem, m_txt_resumo)                                         	  
	    END IF                                                                                       	  
	 ELSE                                                                                            	  
	    LET m_txt_resumo = 'ERRO:',STATUS,'INCLUINDO TAB W_APONT_PROD'                               	  
	    INSERT INTO man_log_apo_prod(empresa,ordem_producao,texto_resumo)                            	  
	      VALUES(p_cod_empresa, m_num_ordem, m_txt_resumo)                                           	  
	 END IF                                                                                          	  

	 DELETE FROM w_apont_prod                                                                        	  
   
   IF m_cod_status = '2' THEN   
      INITIALIZE ma_erros TO NULL                                                                   
      LET p_status = pol1321_le_erros(p_w_apont_prod.num_ordem)                                                              
 	    RETURN  FALSE                                                                                      
	 END IF                                                                                          		
	 
	 IF m_refaz_compon THEN
   	  CALL pol1321_refaz_neces()
   END IF

	 IF m_refaz_man THEN
   	  CALL pol1321_atu_item_man()
   END IF
	                                                                                               	  	                                                                                             	  
   CALL pol1321_le_seq_req(p_w_apont_prod.cod_item) RETURNING p_status 
	                                                                                                 	  
 	 IF p_w_apont_prod.qtd_refug > 0 THEN
      IF NOT pol1321_transf_item() THEN
         CALL pol1321_ins_erro()
         RETURN FALSE
      END IF
   END IF
 	 IF m_qtd_conver > 0 THEN #aqui
      IF NOT pol1321_descarta_sucata() THEN
         CALL pol1321_ins_erro()
         RETURN FALSE
      END IF
   END IF
	 	 	 
	 RETURN TRUE
	        	                                                                                   	  
END FUNCTION

#----------------------------#
FUNCTION pol1321_alt_compon()#
#----------------------------#
   
   DEFINE l_compon     CHAR(15),
          l_baixa      CHAR(01),
          l_local      CHAR(10),
          l_data       DATE

   IF NOT pol1321_w_compon() THEN
      RETURN FALSE
   END IF
   
   DECLARE cq_compon CURSOR FOR
    SELECT DISTINCT cod_item_compon
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem = m_num_ordem
       AND qtd_necessaria > 0
   
   FOREACH cq_compon INTO  l_compon
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED,' LENDO TABELA ORD_COMPON'
         RETURN FALSE
      END IF 
      
      SELECT ies_sofre_baixa
        INTO l_baixa 
        FROM item_man
       WHERE cod_empresa = p_cod_empresa
         AND cod_item =  l_compon

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED,' LENDO TABELA ITEM_MAN'
         RETURN FALSE
      END IF 
      
      IF l_baixa = 'S' THEN
         UPDATE item_man SET ies_sofre_baixa = 'N'
          WHERE cod_empresa = p_cod_empresa
            AND cod_item =  l_compon
         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'ERRO ',m_erro CLIPPED,' UPDATE TABELA ITEM_MAN'
            RETURN FALSE
         END IF 
         
         INSERT INTO w_compon
          VALUES(p_cod_empresa, l_compon, l_baixa)
         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'ERRO ',m_erro CLIPPED,' INSERINDO TABELA w_compon'
            RETURN FALSE
         END IF 
         
      END IF
      
   END FOREACH
   
   IF m_ies_baixa = '1' THEN
      SELECT cod_local_prod
        INTO l_local 
        FROM item_man
       WHERE cod_empresa = p_cod_empresa
         AND cod_item =  p_parametros_885.cod_item_retrab

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED,' LENDO TABELA ITEM_MAN'
         RETURN FALSE
      END IF 
   ELSE
      SELECT cod_local_estoq
        INTO l_local 
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item =  p_parametros_885.cod_item_retrab

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED,' LENDO TABELA ITEM'
         RETURN FALSE
      END IF 
   END IF
   
   SELECT prx_num_neces
    INTO m_num_neces
    FROM par_mrp
   WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED,' LENDO TABELA PAR_MRP'
      RETURN FALSE
   END IF 

   IF m_num_neces IS NULL THEN
      LET m_num_neces = 0
   END IF
   
   LET m_num_neces = m_num_neces + 1
             
   UPDATE par_mrp
      SET prx_num_neces = m_num_neces
    WHERE cod_empresa   = p_cod_empresa
         
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED,' UPDATE TABELA PAR_MRP'
      RETURN FALSE
   END IF 
   
   LET l_data = TODAY
   
   INSERT INTO necessidades
    VALUES(p_cod_empresa, m_num_neces, 0,
           p_parametros_885.cod_item_retrab, p_w_apont_prod.cod_item, m_num_ordem,
           l_data, m_qtd_retrab, 0, mr_cabec.num_docum,'3','4',0)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED,' INSERINDO TABELA NECESSIDADES'
      RETURN FALSE
   END IF 
   
   INSERT INTO neces_complement (
        cod_empresa, 
        num_neces, 
        cod_grade_1, 
        cod_grade_2, 
        cod_grade_3, 
        cod_grade_4, 
        cod_grade_5)
      VALUES(p_cod_empresa, m_num_neces ,' ',' ',' ',' ',' ')

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED,' INSERINDO TABELA NECES_COMPLEMENT'
      RETURN FALSE
   END IF 
   
   INSERT INTO ord_compon(
    cod_empresa, num_ordem, cod_item_pai, cod_item_compon, ies_tip_item,
    dat_entrega, qtd_necessaria, cod_local_baixa, cod_cent_trab, pct_refug)
    VALUES(p_cod_empresa, m_num_ordem, m_num_neces, 
           p_parametros_885.cod_item_retrab, 'P', l_data, 1, l_local, 'ACE', 0)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED,' INSERINDO TABELA ORD_COMPON'
      RETURN FALSE
   END IF 
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1321_refaz_neces()#
#-----------------------------#

   DELETE FROM necessidades
    WHERE cod_empresa = p_cod_empresa
      AND num_neces = m_num_neces

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE', 'NECESSIDADES')
   END IF 
      
   DELETE FROM ord_compon
    WHERE cod_empresa = p_cod_empresa
      AND cod_item_pai = m_num_neces

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE', 'ORD_COMPON')
   END IF 

   CALL pol1321_atu_item_man()

END FUNCTION

#------------------------------#
FUNCTION pol1321_atu_item_man()#
#------------------------------#

   DEFINE l_compon      CHAR(15)
   
   DECLARE cq_man CURSOR FOR
    SELECT cod_compon
      FROM w_compon
     WHERE cod_empresa = p_cod_empresa

   FOREACH cq_man INTO l_compon

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'w_compon')
         EXIT FOREACH
      END IF 

      UPDATE item_man SET ies_sofre_baixa = 'S'
       WHERE cod_empresa = p_cod_empresa
         AND cod_item =  l_compon
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE', 'item_man')
         EXIT FOREACH
      END IF 
   
   END FOREACH

END FUNCTION   
   
#---------------------------#
 FUNCTION pol1321_w_compon()#
#---------------------------#
	
	DROP TABLE w_compon

	CREATE TEMP TABLE w_compon(
				cod_empresa		CHAR(02),
				cod_compon		CHAR(15),
				ies_baixa     CHAR(01)
		)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED,' CRIANDO TABELA W_COMPON'
      RETURN FALSE
   END IF 

	RETURN TRUE

END FUNCTION 
        
#----------------------------#
 FUNCTION pol1321_w_defeito()#
#----------------------------#
	
	DROP TABLE w_defeito

	CREATE TEMP TABLE w_defeito(
				cod_defeito		DECIMAL(3,0),
				qtd_refugo		DECIMAL(10,3)
		)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED,' CRIANDO TABELA W_DEFEITO'
      RETURN FALSE
   END IF 

	RETURN TRUE

END FUNCTION 

#---------------------------#
 FUNCTION pol1321_w_sucata()
#---------------------------#
	
	DROP TABLE w_sucata

  CREATE TEMP TABLE w_sucata	(	
     cod_sucata      	CHAR(15),
     qtd_apont	      DECIMAL(15,3),
     fat_conversao	  DECIMAL(12,5),
     qtd_convertida  	DECIMAL(15,3),
     motivo_sucata 	  DECIMAL(3,0)
   );	

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' CRIANDO TABELA W_SUCATA '
      RETURN FALSE
   END IF 

   RETURN TRUE

END FUNCTION 

#--------------------------#
FUNCTION pol1321_le_itens()#
#--------------------------#

   SELECT pes_unit,
          cod_unid_med
     INTO m_pes_unit, m_unid_item
     FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = m_cod_item
	        
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
	    LET m_msg = 'ERRO: ',m_erro CLIPPED, ' LENDO TAB ITEM:PESO'
	    RETURN FALSE
	 END IF

   SELECT cod_unid_med
     INTO m_unid_sucata
     FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = m_cod_sucata
	        
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
	    LET m_msg = 'ERRO: ',m_erro CLIPPED, ' LENDO TAB ITEM:SUCATA'
	    RETURN FALSE
	 END IF
	 
   RETURN TRUE

END FUNCTION
			
#-------------------------#
FUNCTION pol1321_atu_man()#
#-------------------------#

   IF m_cod_status = '1' THEN
      UPDATE man_apont_912
         SET cod_status = m_cod_status,
             seq_reg_mestre = m_seq_reg_mestre
       WHERE id_registro = g_id_man_apont
         AND cod_empresa = p_cod_empresa
   ELSE
      DELETE FROM man_apont_912
       WHERE id_registro = g_id_man_apont
         AND cod_empresa = p_cod_empresa
   END IF

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' ATUALIZANDO TAB MAN_APONT_304 '
      RETURN FALSE
   END IF 
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1321_le_erros(l_op)#
#------------------------------#
   
   DEFINE l_erro  CHAR(500),
          l_ind   SMALLINT,
          l_seq   INTEGER,
          l_op    INTEGER
      
   DECLARE cq_erro CURSOR FOR 	
		SELECT ordem_producao,
		       texto_detalhado 	
		 	FROM man_log_apo_prod	
     WHERE empresa = p_cod_empresa
       AND ordem_producao = l_op
       AND seq_reg_mestre > 0
		  
   FOREACH cq_erro INTO l_seq, l_erro	
  				
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO ERROS DA TAB MAN_LOG_APO_PROD '
         RETURN FALSE
      END IF 
      
      LET m_qtd_erro = m_qtd_erro + 1
      
      IF m_qtd_erro > 100 THEN
         LET m_msg = 'Limite de erros ultrapassou o previsto.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
      LET ma_erros[m_qtd_erro].num_ordem  = l_seq             
      LET ma_erros[m_qtd_erro].erro = l_erro             
         
   END FOREACH
      
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1321_mostra_erro_apont()#
#-----------------------------------#
   
   DEFINE l_dialog     VARCHAR(10),
          l_panel      VARCHAR(10),
          l_layout     VARCHAR(10),
          l_browse     VARCHAR(10),
          l_tabcolumn  VARCHAR(10)
   
    LET l_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(l_dialog,"SIZE",800,400) #480
    CALL _ADVPL_set_property(l_dialog,"TITLE","ERROS NO APONTAMENTO")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) 

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    
    LET l_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(l_browse,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",l_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ordem")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",l_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ERRO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","erro")
   
    CALL _ADVPL_set_property(l_browse,"SET_ROWS",ma_erros,m_qtd_erro)
    CALL _ADVPL_set_property(l_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(l_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(l_browse,"EDITABLE",FALSE)

   CALL _ADVPL_set_property(l_dialog,"ACTIVATE",TRUE)

END FUNCTION

#--------------------------------#
FUNCTION pol1321_proces_estorno()#
#--------------------------------#

   DEFINE l_qtd_lin     SMALLINT,
          l_progres     SMALLINT

   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DELETE FROM apont_erro_912
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','apont_erro_912')
      RETURN
   END IF
       
   LET l_qtd_lin = _ADVPL_get_property(m_browse,"ITEM_COUNT")
   LET m_qtd_erro = 0

   FOR m_ind = 1 TO l_qtd_lin
       IF ma_itens[m_ind].estornar = 'S' THEN
          LET m_tip_movto = ma_itens[m_ind].tip_producao[1]
          LET m_seq_reg_mestre = ma_itens[m_ind].seq_reg_mestre
          LET m_cod_sucata = ma_itens[m_ind].item_produzido
          LET m_seq_registro_item = ma_itens[m_ind].seq_registro_item 
          LET m_qtd_estornar = ma_itens[m_ind].qtd_estornar
          LET m_qtd_apontada = ma_itens[m_ind].qtd_produzida
          LET m_sdo_apont = ma_itens[m_ind].sdo_apont
          CALL log085_transacao("BEGIN")
          IF NOT pol1321_est_apont('1') THEN
             CALL log085_transacao("ROLLBACK")
             RETURN
          END IF
          IF m_cod_status = '2' THEN
             CALL log085_transacao("ROLLBACK")
             RETURN
          END IF          
          IF NOT pol1321_estorna_chapa() THEN
             CALL log085_transacao("ROLLBACK")
             RETURN
          END IF
          IF m_cod_status = '2' THEN
             CALL log085_transacao("ROLLBACK")
             RETURN
          END IF          
          CALL log085_transacao("COMMIT")
       END IF          
       LET l_progres = LOG_progresspopup_increment("PROCESS")
   END FOR

END FUNCTION

#-------------------------------#
FUNCTION pol1321_estorna_chapa()#
#-------------------------------#
   
   DEFINE l_seq_reg_mestre INTEGER,
          l_num_ordem      INTEGER,
          l_qtd_storno     DECIMAL(10,3),
          l_retorno        SMALLINT
   
   IF NOT pol1321_le_op_chapa('E') THEN
      RETURN FALSE
   END IF
   
   IF m_sem_chapa THEN
      RETURN TRUE
   END IF
   
   LET l_seq_reg_mestre = 0
   
   DECLARE cq_est_chapa CURSOR FOR
    SELECT seq_reg_mestre 
      FROM man_apont_912 
     WHERE cod_empresa = p_cod_empresa 
       AND num_ordem = m_op_chapa 
       AND seq_reg_mestre < m_seq_reg_mestre
     ORDER BY seq_reg_mestre DESC
   
   FOREACH cq_est_chapa INTO l_seq_reg_mestre
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_est_chapa')
         RETURN FALSE
      END IF

      EXIT FOREACH

   END FOREACH
      
   IF l_seq_reg_mestre = 0 OR l_seq_reg_mestre IS NULL THEN
      LET m_msg = 'Não foi possivel estornar a chapa que\n foi consumida pelo apontamento.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   LET m_seq_reg_mestre = l_seq_reg_mestre

   SELECT seq_registro_item, 
          qtd_produzida 
     INTO m_seq_registro_item,
          m_qtd_apontada
     FROM man_item_produzido 
    WHERE empresa = p_cod_empresa 
      AND seq_reg_mestre = m_seq_reg_mestre
      AND tip_movto = 'N'
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','man_item_produzido:1')
      RETURN FALSE
   END IF

   SELECT SUM(qtd_produzida)
     INTO l_qtd_storno
     FROM man_item_produzido 
    WHERE empresa = p_cod_empresa 
      AND seq_reg_mestre = m_seq_reg_mestre
      AND tip_movto = 'E'
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','man_item_produzido:2')
      RETURN FALSE
   END IF
   
   IF l_qtd_storno IS NULL THEN
      LET l_qtd_storno = 0
   END IF

   LET m_sdo_apont = m_qtd_apontada - l_qtd_storno

   IF m_sdo_apont <= 0 THEN
      RETURN TRUE
   END IF
   
   LET m_qtd_estornar = m_qtd_chapa
   LET m_tip_movto = 'B'
   LET l_num_ordem = m_num_ordem
   LET m_num_ordem = m_op_chapa

   IF NOT pol1321_est_apont('2') THEN
      LET l_retorno = FALSE
   ELSE
      LET l_retorno = TRUE
   END IF
      
   LET m_num_ordem = l_num_ordem
   
   RETURN l_retorno

END FUNCTION

#--------------------------#
FUNCTION pol1321_ins_erro()#
#--------------------------#

   INSERT INTO apont_erro_912
    VALUES(p_cod_empresa,m_seq_reg_mestre,m_msg,p_w_apont_prod.num_ordem)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','apont_erro_912:2')
   END IF
   
   LET m_deu_erro = TRUE
   
END FUNCTION    

#--------------------------------#
FUNCTION pol1321_est_apont(l_opc)#
#--------------------------------#
   
   DEFINE l_opc       CHAR(01)
   
   INITIALIZE ma_erros to NULL
   
   IF m_tip_movto MATCHES '[RS]' AND l_opc = '1' THEN #aqui
      IF NOT pol1321_reverte_transf() THEN
         LET m_cod_status = '2'
         RETURN FALSE
      END IF
   END IF
      				
	 LET m_num_docum = mr_cabec.num_docum
	 LET m_cod_operac = '     '
	 LET m_num_seq_operac = NULL   
         
   SELECT cod_item,
          cod_roteiro,
          num_altern_roteiro,
          cod_local_estoq,
          cod_local_prod,
          num_lote
     INTO m_cod_item,
          m_cod_roteiro,
          m_num_altern,
          m_cod_local_estoq,
          m_cod_local_prod,
          m_num_lote         
    FROM ordens
   WHERE cod_empresa = p_cod_empresa
     AND num_ordem = m_num_ordem
			
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, 'LENDO TABELA ORDENS'
      CALL pol1321_ins_erro()
      RETURN FALSE
   END IF

   IF NOT pol1321_le_item_man(m_cod_item) THEN
      RETURN 
   END IF
      
	 IF m_tip_movto = 'S' THEN
      IF NOT POL1321_le_itens() THEN
         RETURN FALSE
      END IF
      IF m_unid_item = m_unid_sucata THEN
         LET m_fat_conver = 1
         LET m_qtd_conver = m_qtd_estornar
      ELSE
         LET m_fat_conver = m_pes_unit
         LET m_qtd_conver = m_qtd_estornar * m_fat_conver
      END IF
      IF POL1321_w_sucata() THEN 
	       INSERT INTO w_sucata 
		       VALUES(m_cod_sucata, m_qtd_conver, m_fat_conver, m_qtd_estornar, 11  )
         IF STATUS <> 0 THEN
            LET m_msg = 'ERRO: ',m_erro CLIPPED, ' INSERINDO NA TAB W_SUCATA'
            CALL pol1321_ins_erro()
	          RETURN FALSE
	       END IF
		  END IF 
      LET m_cod_item = m_cod_sucata               
	 END IF 
   
   LET m_cod_status = '2'                                                                          

   IF NOT pol1306_le_dados() THEN
      RETURN FALSE
   END IF
   
   LET p_w_apont_prod.seq_processo = 1
   
   IF manr24_cria_w_apont_prod(0)  THEN                                                                   
 		  CALL man8246_cria_temp_fifo()                                                                            
	    CALL man8237_cria_tables_man8237()                                                                        

	    IF manr24_inclui_w_apont_prod(p_w_apont_prod.*) THEN 
         IF manr27_processa_apontamento()  THEN #processando ESTORNO                                         
	          LET m_cod_status = '1'                                                                     			 
	       END IF                                                                                        			 
	    ELSE                                                                                                	     
	       LET m_txt_resumo = 'ERRO:',STATUS,'INCLUINDO TAB W_APONT_PROD'                                   	     
	       INSERT INTO man_log_apo_prod(empresa,ordem_producao,texto_resumo)                                	     
	         VALUES(p_cod_empresa, m_num_ordem, m_txt_resumo)                                                	     
   	     IF STATUS <> 0 THEN
	          CALL log003_err_sql('INSERT','man_log_apo_prod')
	          RETURN FALSE
	       END IF
	    END IF                                                                                              	     
	 ELSE                                                                                                   	     
      LET m_txt_resumo = 'ERRO:',STATUS,'CRIANDO TAB W_APONT_PROD'                                              
      INSERT INTO man_log_apo_prod(empresa,ordem_producao,texto_resumo)                                         
	      VALUES(p_cod_empresa, m_num_ordem, m_txt_resumo) 	 	                                              	     
      IF STATUS <> 0 THEN
	       CALL log003_err_sql('INSERT','man_log_apo_prod')
	       RETURN FALSE
	    END IF
	 END IF                                                                                                 	     

   IF m_cod_status = '2' THEN                                                                      
      IF NOT pol1321_le_erros(p_w_apont_prod.num_ordem) THEN    
         CALL pol1321_ins_erro()                                                              
	 	 END IF			                                                                                   		
	 ELSE
      UPDATE man_apont_912
         SET qtd_estornada = m_qtd_estornar
       WHERE seq_reg_mestre = m_seq_reg_mestre
         AND cod_empresa = p_cod_empresa
	    IF STATUS <> 0 THEN
	       CALL log003_err_sql('UPDATE','man_apont_912')
	       RETURN FALSE
	    END IF
   END IF
	                                                                                                 	  
	 DELETE FROM w_apont_prod 
	 DELETE FROM man_log_apo_prod                                                                      	  

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1306_le_dados()#
#--------------------------#
   
   INITIALIZE p_w_apont_prod TO NULL
   
   SELECT
    man_apo_mestre.empresa,                   
    man_apo_mestre.seq_reg_mestre,
    man_apo_mestre.item_produzido,  
    man_apo_mestre.ordem_producao,
    man_apo_mestre.data_producao,
    man_apo_mestre.usu_apontamento,
    man_apo_mestre.secao_requisn,   
    man_tempo_producao.data_ini_producao,  
    man_tempo_producao.hor_ini_producao,  
    man_tempo_producao.dat_final_producao,  
    man_tempo_producao.hor_final_producao,  
    man_tempo_producao.turno_producao,
    man_apo_detalhe.roteiro_fabr,
    man_apo_detalhe.altern_roteiro,
    man_apo_detalhe.operacao,  
    man_apo_detalhe.sequencia_operacao,
    man_apo_detalhe.centro_trabalho,
    man_apo_detalhe.arranjo_fisico,
    man_apo_detalhe.ferramental,  
    man_apo_detalhe.atlz_ferr_min,      
    man_apo_detalhe.eqpto,  
    man_apo_detalhe.atualiza_eqpto_min,  
    man_apo_detalhe.operador,
    man_apo_detalhe.nome_programa,  
    man_item_produzido.lote_produzido,
    man_item_produzido.grade_1,
    man_item_produzido.grade_2,
    man_item_produzido.grade_3,
    man_item_produzido.grade_4,
    man_item_produzido.grade_5,
    man_item_produzido.local,
    man_item_produzido.sit_est_producao
    
   INTO p_w_apont_prod.cod_empresa,            
        p_w_apont_prod.num_seq_registro,  	 
        p_w_apont_prod.cod_item,        		 
        p_w_apont_prod.num_ordem,           
        p_w_apont_prod.dat_producao,     
        p_w_apont_prod.nom_usuario,   
        p_w_apont_prod.num_secao_requis,    
        p_w_apont_prod.dat_ini_prod,        
        p_w_apont_prod.hor_ini_periodo,     
        p_w_apont_prod.dat_fim_prod,        
        p_w_apont_prod.hor_fim_periodo,     
        p_w_apont_prod.cod_turno,           
 	      p_w_apont_prod.cod_roteiro,     
        p_w_apont_prod.num_altern,      
        p_w_apont_prod.cod_operacao,        
        p_w_apont_prod.num_seq_operac,      
        p_w_apont_prod.cod_cent_trab,       
        p_w_apont_prod.cod_arranjo,         
        p_w_apont_prod.cod_ferram,          
        p_w_apont_prod.ies_ferram_min,      
        p_w_apont_prod.cod_equip,           
        p_w_apont_prod.ies_equip_min,       
        p_w_apont_prod.num_operador,        
        p_w_apont_prod.num_programa,        
        p_w_apont_prod.num_lote,            
        p_w_apont_prod.cod_item_grade1,     
        p_w_apont_prod.cod_item_grade2,     
        p_w_apont_prod.cod_item_grade3,     
        p_w_apont_prod.cod_item_grade4,     
        p_w_apont_prod.cod_item_grade5,     
        p_w_apont_prod.cod_local,
        p_w_apont_prod.ies_sit_qtd       

   FROM man_apo_mestre, 
        man_tempo_producao,
        man_apo_detalhe,
        man_item_produzido 
   
   WHERE man_apo_mestre.empresa = p_cod_empresa
     AND man_apo_mestre.seq_reg_mestre = m_seq_reg_mestre
     AND man_tempo_producao.empresa = man_apo_mestre.empresa
     AND man_tempo_producao.seq_reg_mestre = man_apo_mestre.seq_reg_mestre
     AND man_apo_detalhe.empresa = man_apo_mestre.empresa  
     AND man_apo_detalhe.seq_reg_mestre = man_apo_mestre.seq_reg_mestre  
     AND man_item_produzido.empresa = man_apo_mestre.empresa
     AND man_item_produzido.seq_reg_mestre = man_apo_mestre.seq_reg_mestre
     AND man_item_produzido.seq_registro_item = m_seq_registro_item
     AND man_item_produzido.tip_movto = 'N'
     
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO APONTAMENTO A ESTORNAR'
      CALL pol1321_ins_erro()
      RETURN FALSE
   END IF 

   LET p_w_apont_prod.cod_local = m_cod_local_prod
   LET p_w_apont_prod.cod_local_est = m_cod_local_estoq
   LET p_w_apont_prod.num_lote = m_num_lote
   LET p_w_apont_prod.cod_tip_movto = 'E'
      
   IF m_qtd_estornar = m_sdo_apont THEN
      LET p_w_apont_prod.estorno_total = 'S' 
   ELSE
      LET p_w_apont_prod.estorno_total = 'N' 
   END IF
   
   LET p_w_apont_prod.ies_parada = 0
   LET p_w_apont_prod.ies_apontamento	= m_ies_apont
   LET p_w_apont_prod.abre_transacao = 1
   LET p_w_apont_prod.modo_exibicao_msg	= 0
   LET p_w_apont_prod.endereco = ' '
   LET p_w_apont_prod.identif_estoque	= NULL
   LET p_w_apont_prod.sku	= NULL 
   LET p_w_apont_prod.num_docum = m_num_docum
   LET p_w_apont_prod.observacao = '  '
   LET p_w_apont_prod.finaliza_operacao = 'N'
   LET p_w_apont_prod.tip_servico = ' '

   IF m_tip_movto = 'B' THEN
      LET p_w_apont_prod.ies_sucata = 0
      LET p_w_apont_prod.ies_defeito = 0
      LET p_w_apont_prod.qtd_refug = 0			
      LET p_w_apont_prod.qtd_refug_ant = 0			
      LET p_w_apont_prod.qtd_boas_ant = m_qtd_apontada
      LET p_w_apont_prod.qtd_boas = m_qtd_estornar
   ELSE
      IF m_tip_movto = 'S' THEN
         LET p_w_apont_prod.ies_sucata = 1
		     LET p_w_apont_prod.qtd_boas = 0     
		     LET p_w_apont_prod.qtd_boas_ant = 0 
         LET p_w_apont_prod.ies_defeito = 0
         LET p_w_apont_prod.qtd_refug = 0			
         LET p_w_apont_prod.qtd_refug_ant = 0			
		     #LET p_w_apont_prod.ies_sit_qtd =  ' '
		     #LET p_w_apont_prod.cod_roteiro = '               '      
		     #LET p_w_apont_prod.num_altern = 0
		     LET p_w_apont_prod.observacao =  ' '
		     #LET p_w_apont_prod.num_lote = NULL
		     #LET p_w_apont_prod.cod_local_est = NULL
		  ELSE
         LET p_w_apont_prod.ies_defeito = 1
         LET p_w_apont_prod.qtd_refug = m_qtd_estornar	
         LET p_w_apont_prod.qtd_refug_ant = m_qtd_apontada		  
		     LET p_w_apont_prod.qtd_boas = 0     
		     LET p_w_apont_prod.qtd_boas_ant = 0 
         LET p_w_apont_prod.ies_sucata = 0
		  END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1321_le_seq_req(l_cod)#
#----------------------------------#

   DEFINE l_cod          CHAR(15),
          l_seq          INTEGER
   
   INITIALIZE p_est_trans_relac.* TO NULL
   LET m_seq_reg_mestre = 0
   
   SELECT MAX(seq_reg_mestre)
     INTO l_seq
     FROM man_apo_mestre 
    WHERE empresa = p_cod_empresa
      AND item_produzido = l_cod 
      AND sit_apontamento = 'A'

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
	    LET m_msg = 'ERRO: ',m_erro CLIPPED, ' LENDO TAB MAN_APO_MESTRE'
	    RETURN FALSE
	 END IF
   
   IF m_seq_reg_mestre IS NULL THEN
	    LET m_msg = 'ERRO LENDO SEQUENCIA DO APONTAMENO DA TAB MAN_APO_MESTRE'
	    RETURN FALSE
	 END IF   
   
   LET m_seq_reg_mestre =  l_seq
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1321_transf_item()#
#-----------------------------#
   
   IF NOT pol1321_le_seq_req(p_w_apont_prod.cod_item) THEN 
      RETURN FALSE
   END IF

    #faz a saída do item origem rescen-apontado                                                       
                                                                                                              
    LET m_ies_situa = 'R'                                                                                     
    LET m_ies_tip_movto = 'N'                                                                                 
    LET m_tip_operacao = 'S'                                                                                  
    LET m_qtd_movto = p_w_apont_prod.qtd_refug                                                                
    LET m_cod_operac = p_parametros_885.oper_sai_tp_refugo                                                  
    LET m_cod_item = p_w_apont_prod.cod_item
    LET m_num_lote = p_w_apont_prod.num_lote
    LET m_dat_movto = p_w_apont_prod.dat_producao
                                                                                                                     
    IF NOT pol1321_movto_estoque() THEN                                                                       
       RETURN FALSE                                                                                           
    END IF                                                                                                    
                                                                                                              
    LET p_est_trans_relac.num_transac_orig = p_num_trans_atual                                                
    LET p_est_trans_relac.cod_item_orig = m_cod_item                                                          
                                                                                                              
    #faz a entrada no item de retrabalho    
                                                                      
    LET m_ies_situa = 'L'                                                                                     
    LET m_ies_tip_movto = 'N'                                                                                 
    LET m_tip_operacao = 'E'      
    
    #faz a conversão entre unidades
    
    LET m_cod_sucata = p_parametros_885.cod_item_retrab
    
    IF NOT POL1321_le_itens() THEN
       RETURN FALSE
    END IF
    
    IF m_unid_item = m_unid_sucata THEN
       LET m_fat_conver = 1
       LET m_qtd_movto = p_w_apont_prod.qtd_refug  
    ELSE
       LET m_fat_conver = m_pes_unit
       LET m_qtd_movto = p_w_apont_prod.qtd_refug * m_fat_conver
    END IF
                                                                                
    LET m_cod_item = p_parametros_885.cod_item_retrab                                                                                                                      
    LET m_cod_operac = p_parametros_885.oper_ent_tp_refugo                                                  

    IF NOT pol1321_le_ctr_lote(m_cod_item) THEN
       RETURN FALSE
    END IF

    IF m_ies_lote = 'S' THEN
       LET m_num_lote = p_parametros_885.num_lote_retrab
    ELSE
       LET m_num_lote = NULL
    END IF
                                                                                                            
    IF NOT pol1321_movto_estoque() THEN                                                                       
       RETURN FALSE                                                                                           
    END IF                                                                                                    
                                                                                                      
    LET p_est_trans_relac.num_transac_dest = p_num_trans_atual                                                
    LET p_est_trans_relac.cod_item_dest = p_parametros_885.cod_item_retrab                                    
                                                                                                       
    IF NOT pol1321_insere_relac() THEN                                                                        
       RETURN FALSE                                                                                           
    END IF                                                                                                    

    IF NOT pol1321_insere_transac() THEN                                                                        
       RETURN FALSE                                                                                           
    END IF                                                                                                    
    
    RETURN TRUE

END FUNCTION    

#-------------------------------#
FUNCTION pol1321_movto_estoque()#
#-------------------------------#   
   
   DEFINE l_item       RECORD                   
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
   
   DEFINE l_ies_ctr_lote CHAR(01)
                        
   SELECT cod_local_estoq,
          ies_ctr_lote
     INTO l_item.cod_local,
          l_ies_ctr_lote
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO TAB ITEM - TRANFERINDO ITEM '
      RETURN FALSE
   END IF
      
   LET l_item.cod_empresa   = p_cod_empresa
   LET l_item.cod_item      = m_cod_item
   
   IF l_ies_ctr_lote = 'N' THEN
      LET l_item.num_lote = NULL
   ELSE
      LET l_item.num_lote = m_num_lote
   END IF
      
   LET l_item.comprimento   = m_comprimento
   LET l_item.largura       = m_largura  
   LET l_item.altura        = m_altura    
   LET l_item.diametro      = m_diametro       
   LET l_item.cod_operacao  = m_cod_operac  
   LET l_item.ies_situa     = m_ies_situa
   LET l_item.qtd_movto     = m_qtd_movto   
   LET l_item.dat_movto     = m_dat_movto   
   LET l_item.ies_tip_movto = m_ies_tip_movto
   LET l_item.dat_proces    = TODAY
   LET l_item.hor_operac    = TIME
   LET l_item.num_docum     = p_w_apont_prod.num_ordem
   LET l_item.num_seq       = 0   
   LET l_item.tip_operacao  = m_tip_operacao   
   LET l_item.trans_origem  = 0
   LET l_item.ies_ctr_lote  = l_ies_ctr_lote
   LET l_item.usuario       = p_w_apont_prod.nom_usuario
   LET l_item.cod_turno     = p_w_apont_prod.cod_turno
   LET l_item.num_prog      = 'POL1321'
   
   IF NOT func005_insere_movto(l_item) THEN
      LET m_msg = p_msg
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1321_insere_relac()#
#------------------------------#
   
   LET p_est_trans_relac.cod_empresa = p_cod_empresa
   LET p_est_trans_relac.num_nivel = 0
   LET p_est_trans_relac.dat_movto = m_dat_movto
      
   INSERT INTO est_trans_relac(
      cod_empresa,
      num_nivel,
      num_transac_orig,
      cod_item_orig,
      num_transac_dest,
      cod_item_dest,
      dat_movto)
   VALUES(p_est_trans_relac.*)

   IF STATUS <> 0 THEN 
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' INSERINDO TAB EST_TRANS_RELAC '
      RETURN FALSE
   END IF 

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1321_insere_transac()#
#--------------------------------# 

   INSERT INTO trans_relac_885
    VALUES(p_cod_empresa,
           m_seq_reg_mestre,
           p_est_trans_relac.num_transac_orig,
           p_est_trans_relac.num_transac_dest)
           
   IF STATUS <> 0 THEN 
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' INSERINDO TAB TRANS_RELAC_885 '
      RETURN FALSE
   END IF 

   RETURN TRUE
   
END FUNCTION
           
#--------------------------------#
FUNCTION pol1321_reverte_transf()#
#--------------------------------#

   SELECT num_transac_orig,
          num_transac_dest
     INTO m_num_transac_orig,
          m_num_transac_dest
     FROM trans_relac_885
    WHERE cod_empresa = p_cod_empresa
      AND seq_reg_mestre = m_seq_reg_mestre
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, 'LENDO TABELA TRANS_RELAC_885'
      CALL pol1321_ins_erro()
      RETURN FALSE
   END IF
      
   IF m_num_transac_dest > 0 THEN
      IF NOT pol1321b_estorna_estoq(m_num_transac_dest,'E') THEN
         CALL pol1321_ins_erro()
         RETURN FALSE
      END IF
   END IF
   
   IF NOT pol1321b_estorna_estoq(m_num_transac_orig,'S') THEN
      CALL pol1321_ins_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------------------------#
FUNCTION pol1321b_estorna_estoq(l_transac, l_tip_oper)#
#-----------------------------------------------------#

   DEFINE l_transac    INTEGER,
          l_tip_oper   CHAR(01)
   
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
   
   DEFINE p_estoque_trans RECORD LIKE estoque_trans.*
   
   SELECT *
     INTO p_estoque_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = l_transac

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, 'LENDO TABELA ESTOQUE_TRANS'
      RETURN FALSE
   END IF
   
   LET m_num_ordem = p_estoque_trans.num_docum
   LET m_cod_item = p_estoque_trans.cod_item
   
   LET p_item.cod_empresa   = p_estoque_trans.cod_empresa
   LET p_item.cod_item      = p_estoque_trans.cod_item
   LET p_item.cod_operacao  = p_estoque_trans.cod_operacao
   LET p_item.qtd_movto     = p_estoque_trans.qtd_movto   
   LET p_item.dat_movto     = p_estoque_trans.dat_movto   
   LET p_item.num_prog      = p_estoque_trans.num_prog 
   LET p_item.num_docum     = p_estoque_trans.num_docum
   LET p_item.num_seq       = p_estoque_trans.num_seq  
   LET p_item.trans_origem  = p_estoque_trans.num_transac
      
   IF l_tip_oper = 'S' THEN
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
      AND num_transac = l_transac

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, 'LENDO TABELA ESTOQUE_TRANS_END'
      RETURN FALSE
   END IF
      
   LET p_item.tip_operacao  = l_tip_oper 
   LET p_item.ies_tip_movto = 'R'
   LET p_item.dat_proces    = TODAY
   LET p_item.hor_operac    = TIME 
   LET p_item.usuario       = p_estoque_trans.nom_usuario
   LET p_item.cod_turno     = p_estoque_trans.cod_turno
   
   IF p_item.num_lote IS NULL OR
         p_item.num_lote = ' ' OR LENGTH(p_item.num_lote) = 0 THEN
      LET p_item.num_lote = NULL
      LET p_item.ies_ctr_lote  = 'N'
   ELSE
      LET p_item.ies_ctr_lote  = 'S'
   END IF
      
   IF NOT func005_insere_movto(p_item) THEN
      LET m_msg = p_msg
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1321_descarta_sucata()#
#---------------------------------#

   IF NOT pol1321_le_seq_req(p_w_apont_prod.cod_item) THEN 
      RETURN FALSE
   END IF
   
    #faz a saída da produção de sucata,
    #pois a mesma será alimetada posteriormente
    #após picotada e pesada
                                                                                                              
    LET m_ies_situa = 'L'                                                                                     
    LET m_ies_tip_movto = 'N'                                                                                 
    LET m_tip_operacao = 'S'                                                                                  
    LET m_qtd_movto = m_qtd_conver
    LET m_cod_operac = p_parametros_885.oper_sucateamento                                                  
    LET m_cod_item = m_cod_sucata
    LET m_dat_movto = p_w_apont_prod.dat_producao
    LET m_comprimento = 0
    LET m_largura     = 0
    LET m_altura      = 0
    LET m_diametro    = 0

    IF NOT pol1321_le_ctr_lote(m_cod_item) THEN
       RETURN FALSE
    END IF

    IF m_ies_lote = 'S' THEN
       LET m_num_lote = p_w_apont_prod.num_lote
    ELSE
       LET m_num_lote = NULL
    END IF
                                                                                                            
    IF NOT pol1321_movto_estoque() THEN                                                                       
       RETURN FALSE                                                                                           
    END IF                                                                                                    

    LET p_est_trans_relac.num_transac_orig = p_num_trans_atual                                                
    LET p_est_trans_relac.cod_item_orig = m_cod_item                                                          
    LET p_est_trans_relac.num_transac_dest = 0                                               

    IF NOT pol1321_insere_transac() THEN                                                                        
       RETURN FALSE                                                                                           
    END IF                                                                                                    
    
    RETURN TRUE

END FUNCTION
                                                                                                                
#------------------------------#
FUNCTION pol1321_alt_item_man()#
#------------------------------#
   
   DEFINE l_compon     CHAR(15),
          l_baixa      CHAR(01),
          l_familia    CHAR(05)

   IF NOT pol1321_w_compon() THEN
      RETURN FALSE
   END IF
   
   DECLARE cq_alt_man CURSOR FOR
    SELECT DISTINCT cod_item_compon
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem = m_num_ordem
       AND qtd_necessaria > 0
   
   FOREACH cq_alt_man INTO  l_compon
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED,' LENDO TABELA ORD_COMPON'
         RETURN FALSE
      END IF 
      
      SELECT cod_familia
        INTO l_familia
        FROM item
       WHERE cod_empresa = p_cod_empresa 
         AND cod_item = l_compon
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED,' LENDO TABELA ITEM'
         RETURN FALSE
      END IF 
      
      IF l_familia <> '202' THEN
         CONTINUE FOREACH
      END IF
      
      SELECT ies_sofre_baixa
        INTO l_baixa 
        FROM item_man
       WHERE cod_empresa = p_cod_empresa
         AND cod_item =  l_compon

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED,' LENDO TABELA ITEM_MAN'
         RETURN FALSE
      END IF 
      
      IF l_baixa = 'S' THEN
         UPDATE item_man SET ies_sofre_baixa = 'N'
          WHERE cod_empresa = p_cod_empresa
            AND cod_item =  l_compon
         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'ERRO ',m_erro CLIPPED,' UPDATE TABELA ITEM_MAN'
            RETURN FALSE
         END IF 
         
         INSERT INTO w_compon
          VALUES(p_cod_empresa, l_compon, l_baixa)
         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'ERRO ',m_erro CLIPPED,' INSERINDO TABELA w_compon'
            RETURN FALSE
         END IF 
         
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1321_zoom_br_item()#
#------------------------------#
    
   DEFINE l_item        LIKE item.cod_item,
          l_desc        LIKE item.den_item,
          l_lin_atu     INTEGER
          
   IF  m_zoom_item IS NULL THEN
       LET m_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_item,"ZOOM","zoom_item")
   END IF

   CALL _ADVPL_get_property(m_zoom_item,"ACTIVATE")

   LET l_item = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")
   LET l_desc = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","den_item")

   IF l_item IS NOT NULL THEN
      LET l_lin_atu = _ADVPL_get_property(m_brz_compon,"ROW_SELECTED")
      LET ma_compon[l_lin_atu].cod_compon = l_item
      CALL pol1321_le_den_compon(l_item, l_lin_atu) RETURNING p_status      
   END IF
    
END FUNCTION

#-------------------------------#
FUNCTION pol1321_valida_compon()#
#-------------------------------#

   DEFINE l_lin_atu       SMALLINT,
          l_codigo        CHAR(15)
   
   LET l_lin_atu = _ADVPL_get_property(m_brz_compon,"ROW_SELECTED")
   CALL _ADVPL_set_property(m_bar_compon,"ERROR_TEXT","")
      
   LET ma_compon[l_lin_atu].den_compon = ''
   
   LET l_codigo = ma_compon[l_lin_atu].cod_compon
   
   IF l_codigo IS NULL THEN
      LET m_msg = 'Informe o código do componente.'
      CALL _ADVPL_set_property(m_bar_compon,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT pol1321_le_den_compon(l_codigo, l_lin_atu) THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------------------------#
FUNCTION pol1321_le_den_compon(l_codigo,l_lin_atu)#
#-------------------------------------------------#

   DEFINE l_lin_atu       SMALLINT,
          l_codigo        CHAR(15)

   SELECT den_item 
     INTO ma_compon[l_lin_atu].den_compon
     FROM item 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_codigo
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
  
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1321_le_op_chapa(l_param)#
#------------------------------------#
   
   DEFINE l_param       CHAR(01)
   
   DEFINE l_num_ordem   INTEGER,
          l_cod_item    CHAR(15)
          
   DEFINE l_qtd_neces   LIKE ord_compon.qtd_necessaria,
          l_roteiro     LIKE ordens.cod_roteiro,
          l_rot_alter   LIKE ordens.num_altern_roteiro,
          l_loc_est     LIKE ordens.cod_local_estoq,
          l_loc_prod    LIKE ordens.cod_local_prod,
          l_qtd_boas    LIKE ordens.qtd_boas
   
   LET m_sem_chapa = FALSE
   
   SELECT num_ordem,
          cod_item,
          cod_roteiro, 
          num_altern_roteiro,
          cod_local_estoq,
          cod_local_prod
     INTO l_num_ordem,
          l_cod_item,
          l_roteiro,
          l_rot_alter,
          l_loc_est,
          l_loc_prod
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_docum = mr_cabec.num_docum
      AND cod_item_pai = mr_cabec.cod_item
      AND substring(cod_item,1,1) >= 'A'
   
   IF STATUS = 100 THEN
      LET m_sem_chapa = TRUE
      RETURN TRUE
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens:chapa')
      RETURN FALSE
   END IF
   
   SELECT qtd_necessaria
     INTO l_qtd_neces
     FROM ord_compon
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = mr_cabec.num_ordem
      AND cod_item_compon = l_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ord_compon:chapa')
      RETURN FALSE
   END IF
   
   IF l_param = 'E' THEN
      LET m_qtd_chapa = m_qtd_estornar * l_qtd_neces
      LET m_op_chapa = l_num_ordem
      RETURN TRUE
   END IF
   
   LET l_qtd_boas = m_qtd_chapa * l_qtd_neces
   
   LET g_tem_critica = FALSE
   LET l_parametro.cod_empresa = p_cod_empresa
   LET l_parametro.num_ordem = l_num_ordem
   LET l_parametro.qtd_apont = l_qtd_boas
   
   IF NOT pol1321_checa_saldo(l_parametro) THEN
      RETURN FALSE
   END IF
            
   IF g_tem_critica THEN
      LET m_qtd_erro = 0
      CALL pol1321_add_error()
      LET m_deu_erro = FALSE
      RETURN FALSE
   END IF
   
   LET mr_man_apont.num_ordem = l_num_ordem   
   LET mr_man_apont.cod_item = l_cod_item  
   LET mr_man_apont.qtd_boas = m_qtd_chapa * l_qtd_neces
   LET mr_man_apont.cod_roteiro = l_roteiro
   LET mr_man_apont.num_rot_alt = l_rot_alter
   LET mr_man_apont.cod_local_est = l_loc_est
   LET mr_man_apont.cod_local_prod = l_loc_prod
   
   IF NOT pol1321_ins_man_912() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------------#
FUNCTION pol1321_checa_saldo(l_parametro)#
#----------------------------------------#

   DEFINE l_parametro      RECORD
          cod_empresa      CHAR(02),
          num_ordem        INTEGER,
          qtd_apont        DECIMAL(10,3)
   END RECORD

   DEFINE l_cod_compon      LIKE ord_compon.cod_item_compon,
          l_qtd_necessaria  LIKE ord_compon.qtd_necessaria,
          l_cod_local_baixa LIKE ord_compon.cod_local_baixa,
          l_cod_familia     LIKE item.cod_familia

   DEFINE l_ies_ctr_estoque   CHAR(01),
          l_ies_sofre_baixa   CHAR(01),
          l_qtd_saldo         DECIMAL(17,5),
          l_qtd_reservada     DECIMAL(17,5),
          l_saldo             CHAR(15),
          l_neces             CHAR(15),
          l_pri_dig           CHAR(01)

   DECLARE cq_structure CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           cod_local_baixa
      FROM ord_compon
     WHERE cod_empresa = l_parametro.cod_empresa
       AND num_ordem   = l_parametro.num_ordem
       AND qtd_necessaria > 0        

   FOREACH cq_structure INTO 
           l_cod_compon, 
           l_qtd_necessaria,
           l_cod_local_baixa

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_structure')
         RETURN FALSE
      END IF  
            
      SELECT a.ies_ctr_estoque,
             b.ies_sofre_baixa,
             a.cod_familia
        INTO l_ies_ctr_estoque,
             l_ies_sofre_baixa,
             l_cod_familia
        FROM item a,
             item_man b
       WHERE a.cod_empresa = l_parametro.cod_empresa
         AND a.cod_item    = l_cod_compon
         AND b.cod_empresa = a.cod_empresa
         AND b.cod_item    = a.cod_item

      IF l_ies_ctr_estoque = 'N' OR l_ies_sofre_baixa = 'N' THEN
         CONTINUE FOREACH
      END IF
      
      IF l_cod_familia = '201' THEN
         LET l_pri_dig = l_cod_compon[1]
         IF l_cod_compon MATCHES "[0123456789]" THEN
         ELSE
            CONTINUE FOREACH
         END IF
      END IF
      
      LET l_qtd_necessaria = l_qtd_necessaria * l_parametro.qtd_apont
         
      SELECT SUM(qtd_saldo)
        INTO l_qtd_saldo
        FROM estoque_lote_ender
       WHERE cod_empresa   = l_parametro.cod_empresa
	       AND cod_item      = l_cod_compon
	       AND cod_local     = l_cod_local_baixa
         AND ies_situa_qtd = 'L'
          
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT', 'estoque_lote_ender:sum')
         RETURN FALSE
      END IF  

      IF l_qtd_saldo IS NULL THEN
         LET l_qtd_saldo = 0
      END IF

      SELECT SUM(qtd_reservada)
        INTO l_qtd_reservada 
        FROM estoque_loc_reser
       WHERE cod_empresa = l_parametro.cod_empresa
         AND cod_item    = L_cod_compon
         AND cod_local   = L_cod_local_baixa
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT', 'estoque_loc_reser:sum')
         RETURN FALSE
      END IF  
               
      IF l_qtd_reservada IS NULL OR l_qtd_reservada < 0 THEN
         LET l_qtd_reservada = 0
      END IF
   
      LET l_qtd_saldo = l_qtd_saldo - l_qtd_reservada

      IF l_qtd_saldo < l_qtd_necessaria THEN
         LET g_tem_critica = TRUE
         LET l_saldo = l_qtd_saldo
         LET l_neces = l_qtd_necessaria
         LET m_msg =  'PRODUTO: ',L_cod_compon CLIPPED, ' SALDO ATUAL: ',l_saldo CLIPPED,
          ' NECESSIDADE: ', l_neces
         INSERT INTO apont_erro_912
         VALUES(l_parametro.cod_empresa,0,m_msg,l_parametro.num_ordem)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('INSERT','apont_erro_912:1')
            RETURN FALSE
         END IF

      END IF        

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION
