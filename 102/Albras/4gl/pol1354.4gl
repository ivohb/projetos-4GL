#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1354                                                 #
# OBJETIVO: Estorno de apontamentos de produção                     #
# AUTOR...: IVO                                                     #
# DATA....: 27/08/2016                                              #
#-------------------------------------------------------------------#
#A partir de uma OP informada pelo usuário, e da data do ultimo     #
#fechamento da manufatura, exibe os apontamentos efetuados no logix,#  
#para que o usuário possa selecionar os registros a estornar.       #
#-------------------------------------------------------------------#
# Alterações                                                        #
#                                                                   #
#                                                                   #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003),
           g_msg           CHAR(150)
END GLOBALS

DEFINE mr_control         RECORD
       cod_empresa        LIKE empresa.cod_empresa,
       raiz_cgc           LIKE empresa.num_cgc,
       dias_valid         INTEGER
END RECORD

DEFINE mr_cabec          RECORD
       num_ordem         INTEGER,
       cod_item          VARCHAR(15),
       den_item          VARCHAR(50),
       qtd_planej        DECIMAL(10,3),
       qtd_saldo         DECIMAL(10,3),
       ies_situa         CHAR(01),
       liberada          CHAR(01),
       encerrada         CHAR(01),
       cancelada         CHAR(01),
       quantidade        CHAR(01),
       tempo             CHAR(01),
       dat_producao      DATE,
       dat_ate           DATE,
       ies_liberaop      CHAR(01),
       nom_programa      CHAR(08)       
END RECORD

DEFINE ma_itens          ARRAY[1000] OF RECORD
       seq_reg_mestre    INTEGER,
       operacao          CHAR(05),
       data_producao     DATE,
       dat_ini_prod      CHAR(19),
       dat_fim_prod      CHAR(19),
       seq_registro_item INTEGER,
       item_produzido    CHAR(15),
       qtd_produzida     DECIMAL(10,3),
       qtd_convertida    DECIMAL(10,3),
       tip_producao      CHAR(06),
       qtd_estornada     DECIMAL(10,3),
       sdo_apont         DECIMAL(10,3),
       estornar          CHAR(01),
       nom_programa      CHAR(12),
 	     mensagem          CHAR(80)       
END RECORD       

DEFINE ma_erros          ARRAY[500] OF RECORD
       registro          INTEGER,
       erro              CHAR(150)
END RECORD

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_panel           VARCHAR(10),
       m_browse          VARCHAR(10),
       m_ordem           VARCHAR(10),
       m_lupa_op         VARCHAR(10),
       m_zoom_op         VARCHAR(10),
       m_item            VARCHAR(10),
       m_lupa_it         VARCHAR(10),
       m_zoom_it         VARCHAR(10),
       m_apont           VARCHAR(10),
       m_liberada        VARCHAR(10),
       m_encerrada       VARCHAR(10),
       m_cancelada       VARCHAR(10),
       m_quantidade      VARCHAR(10),
       m_tempo           VARCHAR(10),
       m_lib_op          VARCHAR(10),
       m_datini          VARCHAR(10),
       m_datfim          VARCHAR(10),
       m_estornar        VARCHAR(10),
       m_ies_estornar    SMALLINT,
       m_qtd_item        INTEGER

DEFINE m_ies_info        SMALLINT,
       m_msg             CHAR(150),
       m_ies_situa       CHAR(01),
       m_carregando      SMALLINT,
       m_query           CHAR(3000),
       m_num_ordem       INTEGER,
       m_num_ordema      INTEGER,
       m_count           INTEGER,
       m_ind             INTEGER,
       m_id_registro     INTEGER,
       m_cod_status      CHAR(01),
       m_qtd_erro        INTEGER,
	     m_cod_item        CHAR(15),
	     m_cod_sucata      CHAR(15),
	     m_num_docum       CHAR(15),
	     m_cod_operac      CHAR(05),
	     m_num_seq_operac  DECIMAL(3,0),
	     m_cod_local_prod  CHAR(10),
	     m_cod_local_estoq CHAR(10),
			 m_qtd_movto       DECIMAL(10,3),
			 m_dat_producao    DATE,
			 m_seq_reg_mestre  INTEGER,
			 m_seq_item        INTEGER,
			 m_tip_prod        CHAR(01),
       m_qtd_apont       DECIMAL(10,3), 
       m_qtd_produzida   DECIMAL(10,3), 
       m_qtd_convertida  DECIMAL(10,3),
       m_fat_conver      DECIMAL(12,5),
       m_qtd_conver      DECIMAL(15,3),
       m_ies_fecha_op    SMALLINT,
       m_clik_cab        SMALLINT

DEFINE m_cod_motivo      LIKE defeito.cod_defeito,
       m_unid_item       LIKE item.cod_unid_med, 
       m_unid_sucata     LIKE item.cod_unid_med,
       m_pes_unit        LIKE item.pes_unit
       
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
   finaliza_operacao   char(1)
END RECORD
       
#-----------------#
FUNCTION pol1354()#
#-----------------#
   
   DEFINE l_tamanho      INTEGER,
          l_ctrl         CHAR(01)
   
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "POL1354-12.00.03F "
   CALL func002_versao_prg(p_versao)

   LET l_tamanho = LENGTH(p_versao CLIPPED)
   LET l_ctrl = p_versao[l_tamanho,l_tamanho]
   
   IF l_ctrl = 'T' THEN
   
      LET mr_control.cod_empresa = p_cod_empresa
      LET mr_control.raiz_cgc = '043.730.415'

      IF NOT func002_pega_pirata(mr_control) THEN
         RETURN
      END IF
   
      LET mr_control.dias_valid = 5
   
      IF NOT func002_checa_controle(mr_control) THEN
         RETURN 
      END IF

      LET m_ies_estornar = func002_checa_validade(mr_control)   
   ELSE
      LET m_ies_estornar = TRUE
   END IF
   
   IF NOT log0150_verifica_se_tabela_existe("estorno_erro_304") THEN 
      IF NOT pol1354_cria_estorno_erro_304() THEN
         RETURN 
      END IF
   END IF
      
   LET m_qtd_erro = 0
   CALL pol1354_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1354_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_first       VARCHAR(10),
           l_previous    VARCHAR(10),
           l_next        VARCHAR(10),
           l_last        VARCHAR(10),
           l_erro        VARCHAR(10),      
           l_titulo      CHAR(80)
    
    LET p_cod_empresa = mr_control.cod_empresa 
       
    LET l_titulo = "ESTORNO DE APTO DE PRODUÇÃO - ", p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1354_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1354_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1354_cancelar")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1354_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1354_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1354_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1354_last")

    LET m_estornar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(m_estornar,"IMAGE","ESTORNO_EX") 
    CALL _ADVPL_set_property(m_estornar,"TYPE","CONFIRM")    
    CALL _ADVPL_set_property(m_estornar,"ENABLE",m_ies_estornar)    
    CALL _ADVPL_set_property(m_estornar,"EVENT","pol1354_estornar")
    CALL _ADVPL_set_property(m_estornar,"CONFIRM_EVENT","pol1354_confirma_estorno")
    CALL _ADVPL_set_property(m_estornar,"CANCEL_EVENT","pol1354_cancela_estorno")

    LET l_erro = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_erro,"IMAGE","RUN_ERR") 
    CALL _ADVPL_set_property(l_erro,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(l_erro,"TOOLTIP","Exibe erros de estorno")
    CALL _ADVPL_set_property(l_erro,"EVENT","pol1354_exibe_erros")    

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1354_cria_campos(l_panel)
   CALL pol1354_cria_grade(l_panel)
   CALL pol1354_cria_tab_temp()
   
   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1354_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_den_item        VARCHAR(10),
           l_planejada       VARCHAR(10),
           l_saldo           VARCHAR(10),
           l_status          VARCHAR(10),
           l_programa        VARCHAR(10)

    LET m_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_panel,"HEIGHT",80)
    CALL _ADVPL_set_property(m_panel,"EDITABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Número da OP:")    

    LET m_ordem = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_ordem,"POSITION",110,10)     
    CALL _ADVPL_set_property(m_ordem,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_ordem,"PICTURE","@E #########")
    CALL _ADVPL_set_property(m_ordem,"VARIABLE",mr_cabec,"num_ordem")
    CALL _ADVPL_set_property(m_ordem,"VALID","pol1354_valid_ordem")

    LET m_lupa_op = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_op,"POSITION",200,10)     
    CALL _ADVPL_set_property(m_lupa_op,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_op,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_op,"CLICK_EVENT","pol1354_zoom_ordem")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",230,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Produto:")    

    LET m_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(m_item,"POSITION",280,10)     
    CALL _ADVPL_set_property(m_item,"LENGTH",15) 
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_cabec,"cod_item")
    CALL _ADVPL_set_property(m_item,"VALID","pol1354_valid_item")
    

    LET m_lupa_it = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_it,"POSITION",410,10)     
    CALL _ADVPL_set_property(m_lupa_it,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_it,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_it,"CLICK_EVENT","pol1354_zoom_item")

    LET l_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_item,"POSITION",440,10)     
    CALL _ADVPL_set_property(l_den_item,"LENGTH",50) 
    CALL _ADVPL_set_property(l_den_item,"VARIABLE",mr_cabec,"den_item")
    CALL _ADVPL_set_property(l_den_item,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",860,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd planejada:")    

    LET l_planejada = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_planejada,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_planejada,"POSITION",945,10)     
    CALL _ADVPL_set_property(l_planejada,"LENGTH",12) 
    CALL _ADVPL_set_property(l_planejada,"VARIABLE",mr_cabec,"qtd_planej")
    CALL _ADVPL_set_property(l_planejada,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1065,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Saldo da OF:")    

    LET l_saldo = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_saldo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_saldo,"POSITION",1135,10)     
    CALL _ADVPL_set_property(l_saldo,"LENGTH",12) 
    CALL _ADVPL_set_property(l_saldo,"VARIABLE",mr_cabec,"qtd_saldo")
    CALL _ADVPL_set_property(l_saldo,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1250,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","St:")    

    LET l_status = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_status,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_status,"POSITION",1270,10)     
    CALL _ADVPL_set_property(l_status,"LENGTH",2) 
    CALL _ADVPL_set_property(l_status,"VARIABLE",mr_cabec,"ies_situa")
    CALL _ADVPL_set_property(l_status,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,40)
    CALL _ADVPL_set_property(l_label,"TEXT","Situação:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_liberada = _ADVPL_create_component(NULL,"LCHECKBOX",m_panel)
    CALL _ADVPL_set_property(m_liberada,"POSITION",80,40)     
    CALL _ADVPL_set_property(m_liberada,"TEXT","Liberada")     
    CALL _ADVPL_set_property(m_liberada,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_liberada,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_liberada,"VARIABLE",mr_cabec,"liberada")

    LET m_encerrada = _ADVPL_create_component(NULL,"LCHECKBOX",m_panel)
    CALL _ADVPL_set_property(m_encerrada,"POSITION",160,40)     
    CALL _ADVPL_set_property(m_encerrada,"TEXT","Encerrada")     
    CALL _ADVPL_set_property(m_encerrada,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_encerrada,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_encerrada,"VARIABLE",mr_cabec,"encerrada")

    LET m_cancelada = _ADVPL_create_component(NULL,"LCHECKBOX",m_panel)
    CALL _ADVPL_set_property(m_cancelada,"POSITION",240,40)     
    CALL _ADVPL_set_property(m_cancelada,"TEXT","Cancelada")     
    CALL _ADVPL_set_property(m_cancelada,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_cancelada,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_cancelada,"VARIABLE",mr_cabec,"cancelada")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",400,40)
    CALL _ADVPL_set_property(l_label,"TEXT","Apontamento de:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_quantidade = _ADVPL_create_component(NULL,"LCHECKBOX",m_panel)
    CALL _ADVPL_set_property(m_quantidade,"POSITION",500,40)     
    CALL _ADVPL_set_property(m_quantidade,"TEXT","Quantidade")     
    CALL _ADVPL_set_property(m_quantidade,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_quantidade,"VALUE_NCHECKED","N")   
    CALL _ADVPL_set_property(m_quantidade,"ENABLE",FALSE)  
    CALL _ADVPL_set_property(m_quantidade,"VARIABLE",mr_cabec,"quantidade")

    LET m_tempo = _ADVPL_create_component(NULL,"LCHECKBOX",m_panel)
    CALL _ADVPL_set_property(m_tempo,"POSITION",580,40)     
    CALL _ADVPL_set_property(m_tempo,"TEXT","Tempo")     
    CALL _ADVPL_set_property(m_tempo,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_tempo,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_tempo,"ENABLE",FALSE)  
    CALL _ADVPL_set_property(m_tempo,"VARIABLE",mr_cabec,"tempo")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",725,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Período de:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_datini = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel)
    CALL _ADVPL_set_property(m_datini,"POSITION",795,40)     
    CALL _ADVPL_set_property(m_datini,"VARIABLE",mr_cabec,"dat_producao")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",910,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Até:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_datfim = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel)
    CALL _ADVPL_set_property(m_datfim,"POSITION",945,40)     
    CALL _ADVPL_set_property(m_datfim,"VARIABLE",mr_cabec,"dat_ate")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1065,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Programa:")

    LET l_programa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_programa,"POSITION",1125,40)     
    CALL _ADVPL_set_property(l_programa,"LENGTH",8) 
    CALL _ADVPL_set_property(l_programa,"PICTURE","@!") 
    CALL _ADVPL_set_property(l_programa,"VARIABLE",mr_cabec,"nom_programa")

END FUNCTION

#----------------------------#
FUNCTION pol1354_zoom_ordem()#
#----------------------------#
    
   DEFINE l_ordem       LIKE ordens.num_ordem,
          l_filtro      CHAR(300)

   IF m_zoom_op IS NULL THEN
      LET m_zoom_op = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_zoom_op,"ZOOM","zoom_ordem_producao")
   END IF

    LET l_filtro = " ordens.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_zoom_op,"ACTIVATE")

   LET l_ordem = _ADVPL_get_property(m_zoom_op,"RETURN_BY_TABLE_COLUMN","ordens","num_ordem")
   
   IF l_ordem IS NOT NULL THEN
      LET mr_cabec.num_ordem = l_ordem
   END IF
   
   CALL _ADVPL_set_property(m_ordem,"GET_FOCUS")
   
END FUNCTION

#----------------------------#
FUNCTION pol1354_valid_ordem()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_cabec.num_ordem IS NULL THEN
      CALL _ADVPL_set_property(m_item,"EDITABLE",TRUE) 
      CALL _ADVPL_set_property(m_lupa_it,"EDITABLE",TRUE)       
      RETURN TRUE
   END IF
   
   SELECT cod_item,
          ies_situa,
          qtd_planej,
          (qtd_planej - qtd_boas - qtd_refug - qtd_sucata)
     INTO mr_cabec.cod_item,
          mr_cabec.ies_situa,
          mr_cabec.qtd_planej,
          mr_cabec.qtd_saldo
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = mr_cabec.num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens')
      RETURN FALSE
   END IF
   
   IF mr_cabec.ies_situa MATCHES "[456]" THEN
   ELSE
      LET m_msg = 'Status da OP inválido - ',m_ies_situa
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET mr_cabec.den_item = func002_le_den_item(mr_cabec.cod_item) 
   
   CALL _ADVPL_set_property(m_item,"EDITABLE",FALSE) 
   CALL _ADVPL_set_property(m_lupa_it,"EDITABLE",FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1354_zoom_item()#
#---------------------------#
    
   DEFINE l_item        LIKE item.cod_item,
          l_desc        LIKE item.den_item,
          l_filtro      CHAR(300)
          
   IF m_zoom_it IS NULL THEN
      LET m_zoom_it = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_zoom_it,"ZOOM","zoom_item")
   END IF

    LET l_filtro = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_zoom_it,"ACTIVATE")

   LET l_item = _ADVPL_get_property(m_zoom_it,"RETURN_BY_TABLE_COLUMN","item","cod_item")
   LET l_desc = _ADVPL_get_property(m_zoom_it,"RETURN_BY_TABLE_COLUMN","item","den_item")

   IF l_item IS NOT NULL THEN
      LET mr_cabec.cod_item = l_item
      LET mr_cabec.den_item = func002_le_den_item(l_item)       
   END IF
   
   CALL _ADVPL_set_property(m_item,"GET_FOCUS")
   
END FUNCTION

#---------------------------#
FUNCTION pol1354_valid_item()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_cabec.cod_item IS NULL THEN
      RETURN TRUE
   END IF
   
   LET mr_cabec.den_item = func002_le_den_item(mr_cabec.cod_item) 
   
   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION pol1354_cria_grade(l_container)#
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
    #CALL _ADVPL_set_property(m_browse,"AFTER_ROW_EVENT","pol1354_limpa_status")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Registro")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","seq_reg_mestre")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Operação")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","operacao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dat produção")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","data_producao")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ini produção")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_ini_prod")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Fim produção")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_fim_prod")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Seq apont")
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
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
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
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","estornar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1354_checa_linha")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER_CLICK_EVENT","pol1354_marca_desmarca")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Programa")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_programa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)


END FUNCTION


#----------------------------#
FUNCTION pol1354_checa_linha()#
#----------------------------#
   
   DEFINE l_lin_atu    INTEGER
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   LET m_seq_reg_mestre = ma_itens[l_lin_atu].seq_reg_mestre
   
   IF m_seq_reg_mestre IS NULL THEN
      LET ma_itens[l_lin_atu].estornar = 'N'
   END IF
   
   #CALL log0030_mensagem(m_seq_reg_mestre,'info')
   
   RETURN TRUE

END FUNCTION
   
#--------------------------------#
FUNCTION pol1354_marca_desmarca()#
#--------------------------------#
   
   DEFINE l_ind       INTEGER,
          l_sel       CHAR(01),
          l_seq       INTEGER
   
   LET m_clik_cab = NOT m_clik_cab
   
   IF m_clik_cab THEN
      LET l_sel = 'S'
   ELSE
      LET l_sel = 'N'
   END IF
   
   FOR l_ind = 1 TO m_ind
      
       LET l_seq = ma_itens[l_ind].seq_reg_mestre
   
      IF l_seq IS NULL THEN
        CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","estornar",l_ind,'N')
      ELSE
        CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","estornar",l_ind,l_sel)
      END IF
             
   END FOR
      
   RETURN TRUE

END FUNCTION


#------------------------------#
FUNCTION pol1354_cria_tab_temp()#
#------------------------------#

   CREATE TEMP TABLE status_912 (
      ies_situa      CHAR(01)
   );

END FUNCTION

#---------------------------------------#
FUNCTION pol1354_ativa_desativa(l_status)#
#---------------------------------------#

   DEFINE l_status SMALLINT
   
   CALL _ADVPL_set_property(m_panel,"EDITABLE",l_status) 

END FUNCTION

#-----------------------------#
FUNCTION pol1354_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_itens TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")

END FUNCTION

#------------------------------#
FUNCTION pol1354_limpa_status()#
#------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
         
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1354_informar()#
#--------------------------#
      
   CALL pol1354_limpa_campos()
   CALL pol1354_ativa_desativa(TRUE)
   LET m_ies_info = FALSE
   CALL pol1354_set_default()

   CALL _ADVPL_set_property(m_ordem,"GET_FOCUS")
      
   RETURN TRUE 
    
END FUNCTION

#-----------------------------#
FUNCTION pol1354_set_default()#
#-----------------------------#

   LET mr_cabec.liberada = 'S'
   LET mr_cabec.quantidade = 'S'
   LET mr_cabec.tempo = 'S'
   LET mr_cabec.dat_producao = func002_le_fec_man()
   LET mr_cabec.dat_ate = TODAY

END FUNCTION
   
#--------------------------#
FUNCTION pol1354_cancelar()#
#--------------------------#

   CALL pol1354_limpa_campos()
   CALL pol1354_ativa_desativa(FALSE)
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1354_confirmar()#
#---------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   DELETE FROM status_912
      
   IF mr_cabec.liberada = 'S' THEN
      INSERT INTO status_912 VALUES("4")
   END IF
   
   IF mr_cabec.encerrada = 'S' THEN
      INSERT INTO status_912 VALUES("5")
   END IF
   
   IF mr_cabec.cancelada = 'S' THEN
      INSERT INTO status_912 VALUES("9")
   END IF

   SELECT COUNT(*) INTO m_count FROM status_912
      
   IF m_count = 0 THEN
      LET m_msg = 'Informe o(s) status da OP.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF mr_cabec.quantidade = 'N' AND mr_cabec.tempo = 'N' THEN
      LET m_msg = 'Informe o(s) tipo(s) de apontamento'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET m_msg = NULL
   
   IF NOT pol1354_ler_dados() THEN
      IF m_msg IS NOT NULL THEN 
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN FALSE
   END IF
   
   LET m_ies_info = TRUE
   
   RETURN TRUE
    
END FUNCTION

#---------------------------#
FUNCTION pol1354_ler_dados()#
#---------------------------#
   
   CALL pol1354_monta_select()

   PREPARE var_pesquisa FROM m_query
    
   IF  STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE","prepare:var_pesquisa")
       RETURN FALSE
   END IF   

   DECLARE cq_cons SCROLL CURSOR WITH HOLD FOR var_pesquisa
   
   OPEN cq_cons
   
   FETCH cq_cons INTO m_num_ordem
   
   IF STATUS = 0 THEN
   ELSE
      IF STATUS = 100 THEN
         LET m_msg = 'Argumentos de pesquisa não encontrados.'
      ELSE
         CALL log003_err_sql("FETCH","cq_dados")
      END IF
      RETURN FALSE
   END IF
   
   IF NOT pol1354_exibe_dados() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1354_monta_select()#
#------------------------------#
      
   LET m_query = 
    "SELECT DISTINCT a.ordem_producao ",
    "  FROM man_apo_mestre a, man_apo_detalhe b, ordens c ",
    " WHERE a.empresa = '",p_cod_empresa,"' ", 
      " AND a.sit_apontamento = 'A' ",
      " AND a.data_producao >= '",mr_cabec.dat_producao,"' ",
      " AND a.data_producao <= '",mr_cabec.dat_ate,"' ",
      " AND a.empresa = b.empresa ",
      " AND a.seq_reg_mestre = b.seq_reg_mestre ",
      " AND a.empresa = c.cod_empresa ",
      " AND a.ordem_producao = c.num_ordem ",
      " AND c.ies_situa IN (SELECT s.ies_situa FROM status_912 s) "

   IF mr_cabec.num_ordem IS NOT NULL THEN
      LET m_query = m_query CLIPPED,
          " AND c.num_ordem = ", mr_cabec.num_ordem
   END IF

   IF mr_cabec.cod_item IS NOT NULL THEN
      LET m_query = m_query CLIPPED,
          " AND c.cod_item = '",mr_cabec.cod_item,"' "
   END IF
      
   IF mr_cabec.nom_programa IS NOT NULL THEN
      LET m_query = m_query CLIPPED,
          " AND b.nome_programa = '",mr_cabec.nom_programa,"' "
   END IF
   
END FUNCTION

#----------------------------#
FUNCTION pol1354_exibe_dados()#
#----------------------------#
   
   LET mr_cabec.num_ordem = m_num_ordem
   
   SELECT cod_item,
          ies_situa,
          qtd_planej,
          (qtd_planej - qtd_boas - qtd_refug - qtd_sucata)
     INTO mr_cabec.cod_item,
          mr_cabec.ies_situa,
          mr_cabec.qtd_planej,
          mr_cabec.qtd_saldo
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens')
      RETURN FALSE
   END IF
   
   
   LET mr_cabec.den_item = func002_le_den_item(mr_cabec.cod_item) 
   LET m_carregando = TRUE
   LET m_clik_cab = FALSE
 
   CALL LOG_progresspopup_start("Carregando...","pol1354_carrega","PROCESS") 
      
   LET m_carregando = FALSE

   RETURN p_status

END FUNCTION   

#------------------------#
FUNCTION pol1354_carrega()#
#------------------------#

   CALL LOG_progresspopup_set_total("PROCESS",100)
   
   LET p_status = TRUE
   
   IF NOT pol1354_le_items() THEN
      LET p_status = FALSE
   ELSE
      CALL _ADVPL_set_property(m_browse,"SELECT_ITEM",1,13)
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol1354_le_items()#
#-----------------------------#
   
   DEFINE l_tip_producao    CHAR(01),
          l_qtde            DECIMAL(10,3),
          l_seq_mestre      INTEGER,
          l_boas            DECIMAL(10,3),
          l_refugo          DECIMAL(10,3),
          l_sucata          DECIMAL(10,3),
          l_estornada       DECIMAL(10,3),
          l_dat_ini         DATE,
          l_hor_ini         CHAR(05),
          l_dat_fim         DATE,
          l_hor_fim         CHAR(05),
          l_progres         SMALLINT,
          l_eh_tempo        SMALLINT

   INITIALIZE ma_itens TO NULL
   LET m_ind = 1
         
   DECLARE cq_ap_mest CURSOR FOR
    SELECT a.seq_reg_mestre,
           a.data_producao,
           b.operacao,
           c.data_ini_producao,  
           c.hor_ini_producao,  
           c.dat_final_producao,  
           c.hor_final_producao,
           b.nome_programa 
      FROM man_apo_mestre a, 
           man_apo_detalhe b,
           man_tempo_producao c
     WHERE a.empresa = p_cod_empresa 
       AND a.ordem_producao = m_num_ordem
       AND a.sit_apontamento = 'A'
       AND b.empresa = a.empresa
       AND b.seq_reg_mestre = a.seq_reg_mestre
       AND c.empresa = a.empresa
       AND c.seq_reg_mestre = a.seq_reg_mestre
       AND a.data_producao >= mr_cabec.dat_producao
       AND a.data_producao <= mr_cabec.dat_ate
   ORDER BY c.data_ini_producao, c.hor_ini_producao

   FOREACH cq_ap_mest INTO
           ma_itens[m_ind].seq_reg_mestre,
           ma_itens[m_ind].data_producao,   
           ma_itens[m_ind].operacao,
           l_dat_ini,
           l_hor_ini,
           l_dat_fim,
           l_hor_fim,
           ma_itens[m_ind].nom_programa

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','man_apo_mestre')
         RETURN FALSE
      END IF
      
      LET l_eh_tempo = TRUE
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      LET l_seq_mestre = ma_itens[m_ind].seq_reg_mestre
      LET ma_itens[m_ind].dat_ini_prod = l_dat_ini, ' ', l_hor_ini
      LET ma_itens[m_ind].dat_fim_prod = l_dat_fim, ' ', l_hor_fim

      LET ma_itens[m_ind].qtd_produzida = 0
      LET ma_itens[m_ind].qtd_convertida = 0
      LET ma_itens[m_ind].seq_registro_item = 0
      LET ma_itens[m_ind].item_produzido = ' ' 
      LET ma_itens[m_ind].tip_producao = 'TEMPO'
      LET ma_itens[m_ind].qtd_produzida = 0
      LET ma_itens[m_ind].sdo_apont = 0
      LET ma_itens[m_ind].estornar = 'N'
             
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
         
         LET l_eh_tempo = FALSE
         
         IF l_tip_producao = 'S' THEN
            
            LET l_qtde = ma_itens[m_ind].qtd_produzida
            LET ma_itens[m_ind].qtd_produzida = ma_itens[m_ind].qtd_convertida
            LET ma_itens[m_ind].qtd_convertida = l_qtde
         
            SELECT SUM(qtd_convertida)
              INTO ma_itens[m_ind].qtd_estornada
              FROM man_item_produzido
             WHERE empresa = p_cod_empresa 
               AND seq_reg_mestre = l_seq_mestre
               AND seq_reg_normal = ma_itens[m_ind].seq_registro_item
               AND tip_movto = 'E'

         ELSE

            SELECT SUM(qtd_produzida)
              INTO ma_itens[m_ind].qtd_estornada
              FROM man_item_produzido
             WHERE empresa = p_cod_empresa 
               AND seq_reg_mestre = l_seq_mestre
               AND seq_reg_normal = ma_itens[m_ind].seq_registro_item
               AND tip_movto = 'E'
         END IF
            
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','man_item_produzido:sum')
            RETURN FALSE
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
         CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_ind,0,0,0)
         
         LET m_ind = m_ind + 1
         
         IF m_ind > 1000 THEN
            LET m_msg = 'O numero de apontamentos superou /n o número de linhas da grade'
            CALL log0030_mensagem(m_msg,'info')
            EXIT FOREACH
         END IF
         
      END FOREACH
      
      IF l_eh_tempo THEN
         LET m_ind = m_ind + 1
         IF m_ind > 1000 THEN
            LET m_msg = 'O numero de apontamentos superou /n o número de linhas da grade'
            CALL log0030_mensagem(m_msg,'info')
            EXIT FOREACH
         END IF         
      END IF
      
   END FOREACH

   LET m_qtd_item = m_ind - 1
   
   IF m_qtd_item = 0 THEN
      LET m_msg = 'Não há registros a estornar.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   ELSE
      CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_item)
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1354_ies_cons()#
#--------------------------#

   IF NOT m_ies_info THEN
      LET m_msg = 'Informe previamente os parâmetros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#----------------------------------#
FUNCTION pol1354_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1354_ies_cons() THEN
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
               CALL pol1354_exibe_dados() RETURNING p_status
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
FUNCTION pol1354_first()#
#-----------------------#

   IF NOT pol1354_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1354_next()#
#----------------------#

   IF NOT pol1354_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1354_previous()#
#--------------------------#

   IF NOT pol1354_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1354_last()#
#----------------------#

   IF NOT pol1354_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#-------------------------#
FUNCTION pol1354_estornar()#
#-------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT pol1354_ies_cons() THEN
      RETURN FALSE
   END IF

   IF m_qtd_item = 0 THEN   
      LET m_msg = 'Não há registros a estornar.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      CALL _ADVPL_set_property(m_browse,"EDITABLE",TRUE)
      CALL _ADVPL_set_property(m_browse,"SELECT_ITEM",1,13)
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1354_cancela_estorno()#
#---------------------------------#

   CALL pol1354_exibe_dados() RETURNING p_status
   CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

   RETURN TRUE

END FUNCTION


#----------------------------------#
FUNCTION pol1354_confirma_estorno()#
#----------------------------------#
   
   DEFINE l_qtd_lin    SMALLINT
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET l_qtd_lin = _ADVPL_get_property(m_browse,"ITEM_COUNT")
   LET m_count = 0
   
   FOR m_ind = 1 TO l_qtd_lin
       IF ma_itens[m_ind].estornar = 'S' THEN
          LET m_count = m_count + 1
       END IF          
   END FOR

   IF m_count = 0 THEN
      LET m_msg = 'Nenhum apontemaento foi selecionado p/ estorno.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF  
   
   DELETE FROM estorno_erro_304
   
   CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
   
   LET m_qtd_erro = 1
   
   CALL LOG_progresspopup_start("Estornando...","pol1354_proces_estorno","PROCESS")   
   
   IF m_qtd_erro > 1 THEN   
      LET m_msg = 'Um ou mais registros não foi estornado.\n',
                  'Consulte os erros de estorno.'
      CALL log0030_mensagem(m_msg,'info')
      LET m_qtd_erro = m_qtd_erro - 1
   END IF

   LET p_status = pol1354_exibe_dados()
      
   RETURN TRUE
            
   
END FUNCTION

#-------------------------------#
FUNCTION pol1354_proces_estorno()#
#-------------------------------#

   DEFINE l_qtd_lin    SMALLINT,
          l_progres    SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
      
   LET l_qtd_lin = _ADVPL_get_property(m_browse,"ITEM_COUNT")

   FOR m_ind = 1 TO l_qtd_lin
       IF ma_itens[m_ind].estornar = 'S' THEN
          LET m_seq_reg_mestre =	ma_itens[m_ind].seq_reg_mestre
          CALL log085_transacao("BEGIN")
          IF NOT func019_estorna_apto(p_cod_empresa, p_user, m_seq_reg_mestre) THEN
             CALL pol1354_le_erros()
             CALL log085_transacao("ROLLBACK")
             LET ma_itens[m_ind].mensagem = 'Erro' 
             CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","mensagem",m_ind,"Erro")
             CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_ind,249,75,32)
          ELSE
             CALL log085_transacao("COMMIT")
             LET ma_itens[m_ind].mensagem = 'Estornado' 
             CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","mensagem",m_ind,"Estornado")
          END IF
          LET l_progres = LOG_progresspopup_increment("PROCESS")
       END IF
   END FOR
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
END FUNCTION

#------------------------------#
FUNCTION pol1354_estorna_apont()#
#------------------------------#
   
   DEFINE lr_tip_sucata     RECORD
          cod_empresa       CHAR(02),
			    seq_reg_mestre    INTEGER,
			    estorno_total     CHAR(01),
			    tip_apont_sucata  CHAR(01), 
			    item_trata_qea    SMALLINT
   END RECORD      
         				         
   LET m_seq_reg_mestre =	ma_itens[m_ind].seq_reg_mestre
   LET m_seq_item =	ma_itens[m_ind].seq_registro_item
   LET m_cod_item = ma_itens[m_ind].item_produzido
   LET m_tip_prod = ma_itens[m_ind].tip_producao[1,1]
   LET m_qtd_movto = ma_itens[m_ind].sdo_apont

   LET m_qtd_produzida = ma_itens[m_ind].qtd_produzida
   LET m_qtd_convertida = ma_itens[m_ind].qtd_convertida

   IF m_tip_prod = 'S' THEN
      LET m_qtd_apont = m_qtd_convertida
      LET m_cod_sucata = m_cod_item
   ELSE
      LET m_qtd_apont = m_qtd_produzida
   END IF

   SELECT cod_item 
     INTO m_cod_item
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = mr_cabec.num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens')
      RETURN FALSE
   END IF
   
   IF m_tip_prod = 'S' THEN
      IF NOT pol1354_gra_sucata() THEN
         RETURN
    	END IF
   END IF
   
   IF m_tip_prod = 'R' THEN
      IF NOT pol1354_gra_defeito() THEN
         RETURN FALSE
    	END IF
   END IF
                                        
   IF NOT pol1354_le_dados() THEN
      RETURN FALSE
   END IF

   LET m_cod_status = 'C'
                  
   IF NOT manr24_cria_w_apont_prod(0) THEN  
      LET m_msg = 'Problemas criando a tabela \n w_pont_prod ', STATUS                                       
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
 	 CALL man8246_cria_temp_fifo()
	 CALL man8237_cria_tables_man8237()  
	          
   LET m_ies_fecha_op = FALSE
         
   IF m_ies_situa MATCHES "[59]" {AND mr_cabec.ies_liberaop = 'S'}  THEN
      CALL log085_transacao("BEGIN")
      IF NOT pol1354_libera_op() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      CALL log085_transacao("COMMIT")
      LET m_ies_fecha_op = TRUE
   END IF
   
   LET p_status = TRUE
           
   IF manr24_inclui_w_apont_prod(p_w_apont_prod.*,1) THEN        

      SELECT log_defn_parametro.val_padrao
        INTO lr_tip_sucata.tip_apont_sucata
        FROM log_defn_parametro 
       WHERE log_defn_parametro.parametro='tipo_apont_sucata'
       
	    LET lr_tip_sucata.cod_empresa = p_w_apont_prod.cod_empresa                      
		  LET lr_tip_sucata.seq_reg_mestre = p_w_apont_prod.num_seq_registro     	      
		  LET lr_tip_sucata.estorno_total = 'S'			                             	      
		  LET lr_tip_sucata.item_trata_qea = 1                                   	      
      CALL man8232_carrega_sucata(lr_tip_sucata.*,1) RETURNING p_status               
 	    
 	    IF manr27_processa_apontamento()  THEN 
	       LET m_cod_status = 'A'                                              			    
	    END IF                                                                 			    
	 ELSE                                                                      	        
	    LET m_msg = 'Problemas incluindo registro \n na tabela w_apont_prod ', STATUS
	    CALL log0030_mensagem(m_msg,'info')
	    LET p_status = FALSE
	 END IF                                                                    	        
	                                                                           	     
   IF m_ies_fecha_op THEN
      CALL log085_transacao("BEGIN")
      IF NOT pol1354_fecha_op() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      ELSE
         CALL log085_transacao("COMMIT")
      END IF
   END IF
   
   IF m_cod_status = 'C' THEN
      IF NOT pol1354_le_log_erros() THEN
         LET p_status = FALSE
      END IF			     
   END IF
	 	     
   DELETE FROM w_apont_prod 
   
   RETURN p_status
    
END FUNCTION

#--------------------------#
FUNCTION pol1354_le_dados()#
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
    man_item_produzido.sit_est_producao,
    man_item_produzido.qtd_produzida
    
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
        p_w_apont_prod.ies_sit_qtd,        
        p_w_apont_prod.qtd_boas_ant
    
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
     AND man_item_produzido.tip_movto = 'N'
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','man_apo_mestre:join')
      RETURN FALSE
   END IF 
   
   SELECT cod_local_prod,
          cod_local_estoq,
          num_lote,
          ies_situa
     INTO p_w_apont_prod.cod_local,
          p_w_apont_prod.cod_local_est,	
          p_w_apont_prod.num_lote,
          m_ies_situa
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens:join')
      RETURN FALSE
   END IF       
         
   LET p_w_apont_prod.cod_tip_movto = 'E'            
   LET p_w_apont_prod.ies_parada = 0
   LET p_w_apont_prod.ies_apontamento	= '1'	
   LET p_w_apont_prod.abre_transacao = 1
   LET p_w_apont_prod.modo_exibicao_msg	= 0
   LET p_w_apont_prod.endereco = ' '
   LET p_w_apont_prod.identif_estoque	= NULL
   LET p_w_apont_prod.sku	= NULL 
   LET p_w_apont_prod.num_docum = ''
   LET p_w_apont_prod.observacao = '  '
   LET p_w_apont_prod.finaliza_operacao = 'N'
   LET p_w_apont_prod.tip_servico = ' '

   LET p_w_apont_prod.qtd_refug = 0			
   LET p_w_apont_prod.qtd_refug_ant = 0			
   LET p_w_apont_prod.ies_defeito = 0
   LET p_w_apont_prod.ies_sucata = 0

   IF m_qtd_movto < m_qtd_apont THEN
      LET p_w_apont_prod.estorno_total = 'N' 
   ELSE
      LET p_w_apont_prod.estorno_total = 'S' 
   END IF

   IF m_tip_prod = 'B' THEN
      LET p_w_apont_prod.qtd_boas = m_qtd_movto
   END IF

   IF m_tip_prod = 'R' THEN
      LET p_w_apont_prod.qtd_refug = m_qtd_movto
      LET p_w_apont_prod.ies_defeito = 1
      LET p_w_apont_prod.qtd_boas = 0
      LET p_w_apont_prod.qtd_boas_ant = 0 
      LET p_w_apont_prod.qtd_refug_ant = m_qtd_produzida		
   END IF
   
   IF m_tip_prod = 'S' THEN
      LET p_w_apont_prod.ies_sucata = 1
      LET p_w_apont_prod.estorno_total = 'S' 
		  LET p_w_apont_prod.qtd_boas = 0     
		  LET p_w_apont_prod.qtd_boas_ant = 0 
		  LET p_w_apont_prod.ies_sit_qtd =  ' '
		  LET p_w_apont_prod.cod_roteiro = '               '      
		  LET p_w_apont_prod.num_altern = 0
		  LET p_w_apont_prod.observacao =  ' '
		  LET p_w_apont_prod.num_lote = NULL
		  LET p_w_apont_prod.cod_local_est = NULL
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION pol1354_cria_estorno_erro_304()#
#---------------------------------------#
   
   CREATE  TABLE estorno_erro_304 (
    cod_empresa            char(02),
    seq_reg_mestre         integer,
    den_erro               char(150)
   );
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE', 'estorno_erro_304')
      RETURN FALSE
   END IF

   CREATE INDEX ix_estorno_erro_304
    ON estorno_erro_304(cod_empresa, seq_reg_mestre);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE', 'ix_estorno_erro_304')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1354_gra_sucata()#
#----------------------------#

   INITIALIZE m_cod_motivo to NULL
       
   SELECT motivo_sucata
     FROM man_motivo_sucata 
    WHERE empresa = p_cod_empresa
      AND seq_reg_mestre = m_seq_reg_mestre
      AND seq_registro_item = m_seq_item

   IF STATUS <> 0 THEN
      LET m_cod_motivo = 13
   END IF

   IF NOT pol1354_le_itens() THEN                                           
      RETURN                                                                      
   END IF                                                                         
                                                                                  
   IF m_unid_item = m_unid_sucata THEN                                            
      LET m_fat_conver = 1                                                        
      LET m_qtd_conver = m_qtd_movto                                              
   ELSE                                                                           
      LET m_fat_conver = m_pes_unit                                               
      LET m_qtd_conver = m_qtd_movto * m_fat_conver                               
   END IF                                                                         
                                                                                  
	 IF NOT pol1354_w_cria_sucata() THEN                                                		 
		  RETURN FALSE
	 END IF
		
	 INSERT INTO w_sucata                                                   		 
		  VALUES(m_cod_sucata, m_qtd_conver, 
		         m_fat_conver, m_qtd_movto, m_cod_motivo)    		 
    
   IF STATUS <> 0 THEN         
      CALL log003_err_sql('INSERT','w_sucata')                                           	   
      RETURN FALSE
	 END IF                                                                    		 
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1354_w_cria_sucata()#
#--------------------------------#
	
	DROP TABLE w_sucata

  CREATE TEMP TABLE w_sucata	(	
     cod_sucata      	CHAR(15),
     qtd_apont	        DECIMAL(15,3),
     fat_conversao	    DECIMAL(12,5),
     qtd_convertida  	DECIMAL(15,3),
     motivo_sucata 	  DECIMAL(3,0)
   );	

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','w_sucata')
      RETURN FALSE
   END IF 

   RETURN TRUE

END FUNCTION 

#--------------------------#
FUNCTION pol1354_le_itens()#
#--------------------------#

   SELECT pes_unit,
          cod_unid_med
     INTO m_pes_unit, m_unid_item
     FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = m_cod_item
	        
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'item:pes_unit')
	    RETURN FALSE
	 END IF

   SELECT cod_unid_med
     INTO m_unid_sucata
     FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = m_cod_sucata
	        
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'item:unid_med')	    
      RETURN FALSE
	 END IF
	 
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1354_gra_defeito()#
#-----------------------------#

   SELECT motivo_defeito
     FROM man_def_producao 
    WHERE empresa = p_cod_empresa
      AND seq_reg_mestre = m_seq_reg_mestre
      AND seq_registro_item = m_seq_item

   IF STATUS <> 0 THEN
      LET m_cod_motivo = 13
   END IF

   IF NOT pol1354_cria_w_defeito() THEN 
		 	RETURN FALSE
	 END IF   
	 
	 INSERT INTO w_defeito 
		  VALUES(m_cod_motivo, m_qtd_movto)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','w_defeito')
	    RETURN FALSE
   END IF 

   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION pol1354_cria_w_defeito()#
#---------------------------------#
	
	DROP TABLE w_defeito

	CREATE TEMP TABLE w_defeito(
				cod_defeito		DECIMAL(3,0),
				qtd_refugo		DECIMAL(10,3)
		)

	IF STATUS <> 0 THEN
	   CALL log003_err_sql('CREATE','w_defeito')
     RETURN FALSE
	END IF

	RETURN TRUE

END FUNCTION 

#---------------------------#
FUNCTION pol1354_libera_op()#
#---------------------------#
   
   UPDATE ordens SET ies_situa = '4'
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN  
      CALL log003_err_sql('UPDATE','ordens:lib_op')
      RETURN FALSE
   END IF
               
   UPDATE necessidades SET ies_situa = '4'
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN  
      CALL log003_err_sql('UPDATE','necessidades:lib_op')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1354_fecha_op()#
#--------------------------#
   
   UPDATE ordens SET ies_situa = m_ies_situa
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN  
      CALL log003_err_sql('UPDATE','ordens:fop')
      RETURN FALSE
   END IF
               
   UPDATE necessidades SET ies_situa = m_ies_situa
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN  
      CALL log003_err_sql('UPDATE','necessidades:fop')
      RETURN FALSE
   END IF
     
END FUNCTION

#------------------------------#
FUNCTION pol1354_le_log_erros()#
#------------------------------#
   
   DEFINE l_erro  CHAR(500)
   
   LET m_msg = ''
   
   DECLARE cq_erro CURSOR FOR 	
		SELECT texto_detalhado  	
		 	FROM man_log_apo_prod	
     WHERE empresa = p_cod_empresa
       AND ordem_producao = mr_cabec.num_ordem
		  
   FOREACH cq_erro INTO l_erro	
  				
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','man_log_apo_prod:cq_erro')
         RETURN FALSE
      END IF 
      
      LET m_msg = l_erro 

 	    IF NOT pol1354_ins_erro() THEN
 	       RETURN FALSE
 	    END IF
   
   END FOREACH
   
   LET m_msg = ''
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1354_ins_erro()#
#--------------------------#
   
   LET m_qtd_erro = m_qtd_erro + 1
   
   INSERT INTO estorno_erro_304
    VALUES(p_cod_empresa, m_seq_reg_mestre, m_msg)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','estorno_erro_304')
      RETURN FALSE
   END IF 
   
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1354_exibe_erros()#
#----------------------------#

   DEFINE l_dialog     VARCHAR(10),
          l_panel      VARCHAR(10),
          l_layout     VARCHAR(10),
          l_browse     VARCHAR(10),
          l_tabcolumn  VARCHAR(10)
        
    LET l_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(l_dialog,"SIZE",1200,400) #480
    CALL _ADVPL_set_property(l_dialog,"TITLE","ERROS DO PROCESSAMENTO")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) 

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    
    LET l_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(l_browse,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",l_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Registro")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","registro")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",l_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","erro")
   
    CALL _ADVPL_set_property(l_browse,"SET_ROWS",ma_erros,m_qtd_erro)
    CALL _ADVPL_set_property(l_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(l_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(l_browse,"EDITABLE",FALSE)

   CALL _ADVPL_set_property(l_dialog,"ACTIVATE",TRUE)


END FUNCTION

#-------------------------#
FUNCTION pol1354_le_erros()#
#-------------------------#
   
   DECLARE cq_le_erro CURSOR FOR
    SELECT seq_reg_mestre,  den_erro
      FROM estorno_erro_304
   
   FOREACH cq_le_erro INTO ma_erros[m_qtd_erro].*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','estorno_erro_304:cq_le_erro')
         RETURN FALSE
      END IF
      
      LET m_qtd_erro = m_qtd_erro + 1

      IF m_qtd_erro > 500 THEN
         LET m_msg = 'Limite de erros ultrapassou o previsto.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
      
   RETURN TRUE
   
END FUNCTION   
