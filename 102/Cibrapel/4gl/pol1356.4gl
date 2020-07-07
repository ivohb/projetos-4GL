#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1356                                                 #
# OBJETIVO: Estorno de apontamentos de produção                     #
# AUTOR...: IVO                                                     #
# DATA....: 27/07/2019                                              #
#-------------------------------------------------------------------#
# Alterações:                                                       #
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
       num_ordem         CHAR(10),
       operacao          CHAR(05),
       data_producao     DATE,
       seq_registro_item INTEGER,
       item_produzido    CHAR(15),
       qtd_produzida     DECIMAL(10,3),
       qtd_convertida    DECIMAL(10,3),
       tip_producao      CHAR(06),
       qtd_estornada     DECIMAL(10,3),
       sdo_apont         DECIMAL(10,3),
       num_lote          CHAR(15),
       estornar          CHAR(01),
 	     mensagem          CHAR(80),
 	     nom_programa      CHAR(08)      
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
       m_estornar        VARCHAR(10)

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
       
       
#-----------------#
FUNCTION pol1356()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   
   LET p_versao = "pol1356-12.00.01  "
   CALL func002_versao_prg(p_versao)
   
   IF NOT log0150_verifica_se_tabela_existe("estorno_erro_304") THEN 
      IF NOT pol1356_cria_estorno_erro_304() THEN
         RETURN FALSE
      END IF
   END IF
   
   LET m_qtd_erro = 0
   CALL pol1356_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1356_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_first       VARCHAR(10),
           l_previous    VARCHAR(10),
           l_next        VARCHAR(10),
           l_last        VARCHAR(10),
           l_erro        VARCHAR(10),      
           l_titulo      CHAR(43)

    
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
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1356_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1356_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1356_cancelar")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1356_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1356_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1356_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1356_last")

    LET m_estornar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(m_estornar,"IMAGE","ESTORNO_EX") 
    CALL _ADVPL_set_property(m_estornar,"TYPE","CONFIRM")    
    CALL _ADVPL_set_property(m_estornar,"EVENT","pol1356_estornar")
    CALL _ADVPL_set_property(m_estornar,"CONFIRM_EVENT","pol1356_confirma_estorno")
    CALL _ADVPL_set_property(m_estornar,"CANCEL_EVENT","pol1356_cancela_estorno")

    LET l_erro = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_erro,"IMAGE","RUN_ERR") 
    CALL _ADVPL_set_property(l_erro,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(l_erro,"TOOLTIP","Exibe erros de estorno")
    CALL _ADVPL_set_property(l_erro,"EVENT","pol1356_exibe_erros")    

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1356_cria_campos(l_panel)
   CALL pol1356_cria_grade(l_panel)
   CALL pol1356_cria_tab_temp()
   
   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1356_cria_campos(l_container)#
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
    CALL _ADVPL_set_property(l_label,"TEXT","Produto:")    

    LET m_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(m_item,"POSITION",80,10)     
    CALL _ADVPL_set_property(m_item,"LENGTH",15) 
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_cabec,"cod_item")
    CALL _ADVPL_set_property(m_item,"VALID","pol1356_valid_item")    
    CALL _ADVPL_set_property(m_item,"PICTURE","@!")

    LET m_lupa_it = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_it,"POSITION",210,10)     
    CALL _ADVPL_set_property(m_lupa_it,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_it,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_it,"CLICK_EVENT","pol1356_zoom_item")

    LET l_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_item,"POSITION",240,10)     
    CALL _ADVPL_set_property(l_den_item,"LENGTH",40) 
    CALL _ADVPL_set_property(l_den_item,"VARIABLE",mr_cabec,"den_item")
    CALL _ADVPL_set_property(l_den_item,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",600,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Número da OP:")    

    LET m_ordem = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_ordem,"POSITION",680,10)     
    CALL _ADVPL_set_property(m_ordem,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_ordem,"PICTURE","@E #########")
    CALL _ADVPL_set_property(m_ordem,"VARIABLE",mr_cabec,"num_ordem")
    CALL _ADVPL_set_property(m_ordem,"VALID","pol1356_valid_ordem")

    LET m_lupa_op = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_op,"POSITION",780,10)     
    CALL _ADVPL_set_property(m_lupa_op,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_op,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_op,"CLICK_EVENT","pol1356_zoom_ordem")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",820,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Período de:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_datini = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel)
    CALL _ADVPL_set_property(m_datini,"POSITION",890,10)     
    CALL _ADVPL_set_property(m_datini,"VARIABLE",mr_cabec,"dat_producao")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1010,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Até:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_datfim = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel)
    CALL _ADVPL_set_property(m_datfim,"POSITION",1040,10)     
    CALL _ADVPL_set_property(m_datfim,"VARIABLE",mr_cabec,"dat_ate")

    {LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
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

    {LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",350,40)
    CALL _ADVPL_set_property(l_label,"TEXT","Tip apont:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_quantidade = _ADVPL_create_component(NULL,"LCHECKBOX",m_panel)
    CALL _ADVPL_set_property(m_quantidade,"POSITION",420,40)     
    CALL _ADVPL_set_property(m_quantidade,"TEXT","Quantidade")     
    CALL _ADVPL_set_property(m_quantidade,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_quantidade,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_quantidade,"VARIABLE",mr_cabec,"quantidade")

    LET m_tempo = _ADVPL_create_component(NULL,"LCHECKBOX",m_panel)
    CALL _ADVPL_set_property(m_tempo,"POSITION",520,40)     
    CALL _ADVPL_set_property(m_tempo,"TEXT","Tempo")     
    CALL _ADVPL_set_property(m_tempo,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_tempo,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_tempo,"VARIABLE",mr_cabec,"tempo")}


    {LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",800,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Programa:")

    LET l_programa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_programa,"POSITION",860,40)     
    CALL _ADVPL_set_property(l_programa,"LENGTH",8) 
    CALL _ADVPL_set_property(l_programa,"PICTURE","@!") 
    CALL _ADVPL_set_property(l_programa,"VARIABLE",mr_cabec,"nom_programa")}

END FUNCTION

#----------------------------#
FUNCTION pol1356_zoom_ordem()#
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
FUNCTION pol1356_valid_ordem()#
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
FUNCTION pol1356_zoom_item()#
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
FUNCTION pol1356_valid_item()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_cabec.cod_item IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Informe o produto')
      RETURN FALSE
   END IF
   
   LET mr_cabec.den_item = func002_le_den_item(mr_cabec.cod_item) 
   
   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION pol1356_cria_grade(l_container)#
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
    #CALL _ADVPL_set_property(m_browse,"AFTER_ROW_EVENT","pol1356_limpa_status")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Registro")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","seq_reg_mestre")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ordem")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Operação")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","operacao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dat produção")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","data_producao")
    
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
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Lote")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_lote")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CHECKED")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Estornar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","estornar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1356_checa_linha")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER_CLICK_EVENT","pol1356_marca_desmarca")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")
    
    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)


END FUNCTION


#----------------------------#
FUNCTION pol1356_checa_linha()#
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
FUNCTION pol1356_marca_desmarca()#
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
FUNCTION pol1356_cria_tab_temp()#
#------------------------------#

   CREATE TEMP TABLE status_912 (
      ies_situa      CHAR(01)
   );

END FUNCTION

#---------------------------------------#
FUNCTION pol1356_ativa_desativa(l_status)#
#---------------------------------------#

   DEFINE l_status SMALLINT
   
   CALL _ADVPL_set_property(m_panel,"EDITABLE",l_status) 

END FUNCTION

#-----------------------------#
FUNCTION pol1356_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_itens TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")

END FUNCTION

#------------------------------#
FUNCTION pol1356_limpa_status()#
#------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
         
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1356_informar()#
#--------------------------#
      
   CALL pol1356_limpa_campos()
   CALL pol1356_ativa_desativa(TRUE)
   LET m_ies_info = FALSE
   CALL pol1356_set_default()

   CALL _ADVPL_set_property(m_item,"GET_FOCUS")
      
   RETURN TRUE 
    
END FUNCTION

#-----------------------------#
FUNCTION pol1356_set_default()#
#-----------------------------#

   LET mr_cabec.liberada = 'S'
   LET mr_cabec.quantidade = 'S'
   LET mr_cabec.tempo = 'S'
   LET mr_cabec.dat_producao = func002_le_fec_man()
   LET mr_cabec.dat_ate = TODAY

END FUNCTION
   
#--------------------------#
FUNCTION pol1356_cancelar()#
#--------------------------#

   CALL pol1356_limpa_campos()
   CALL pol1356_ativa_desativa(FALSE)
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1356_confirmar()#
#---------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   DELETE FROM status_912
      
   #IF mr_cabec.liberada = 'S' THEN
      INSERT INTO status_912 VALUES("4")
   #END IF
   
   #IF mr_cabec.encerrada = 'S' THEN
      INSERT INTO status_912 VALUES("5")
   #END IF
   
   #IF mr_cabec.cancelada = 'S' THEN
      INSERT INTO status_912 VALUES("9")
   #END IF

   #SELECT COUNT(*) INTO m_count FROM status_912
      
   {IF m_count = 0 THEN
      LET m_msg = 'Informe o(s) status da OP.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF}

   {IF mr_cabec.quantidade = 'N' AND mr_cabec.tempo = 'N' THEN
      LET m_msg = 'Informe o(s) tipo(s) de apontamento'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF}
   
   LET m_msg = NULL
 
   LET m_carregando = TRUE
   LET m_clik_cab = FALSE

   LET p_status = LOG_progresspopup_start("Carregando...","pol1356_ler_dados","PROCESS") 

   LET m_carregando = FALSE
      
   IF NOT p_status THEN
      IF m_msg IS NOT NULL THEN 
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN FALSE
   END IF
   
   LET m_ies_info = TRUE
   
   RETURN TRUE
    
END FUNCTION

#---------------------------#
FUNCTION pol1356_ler_dados()#
#---------------------------#
   
   DEFINE l_progres      SMALLINT,
          l_qtde         DECIMAL(10,3),
          l_tip_producao CHAR(01)
   
   CALL LOG_progresspopup_set_total("PROCESS",100)
   
   LET m_carregando = TRUE
   
   CALL pol1356_monta_select()
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")

   PREPARE var_pesquisa FROM m_query
    
   IF  STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE","prepare:var_pesquisa")
       RETURN FALSE
   END IF   
   
   LET m_ind = 1
   
   DECLARE cq_cons CURSOR FOR var_pesquisa
     
   FOREACH cq_cons INTO 
      ma_itens[m_ind].seq_reg_mestre,
      ma_itens[m_ind].num_ordem,
      ma_itens[m_ind].operacao,
      ma_itens[m_ind].data_producao,   
      ma_itens[m_ind].seq_registro_item,
      ma_itens[m_ind].item_produzido,
      ma_itens[m_ind].qtd_produzida,
      ma_itens[m_ind].qtd_convertida,
      l_tip_producao,      
      ma_itens[m_ind].num_lote

      IF STATUS <> 0 THEN
         CALL log003_err_sql("FOREACH","cq_cons:lendo apontamentos")
         RETURN FALSE
      END IF   
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")

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

   LET l_progres = LOG_progresspopup_increment("PROCESS")

   LET m_ind = m_ind - 1
               
   IF m_ind > 0 THEN
      CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_ind)
   ELSE
      LET m_msg = 'Argumentos de pesquisa não encontrados.'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1356_monta_select()#
#------------------------------#
      
   LET m_query = 
    "SELECT ",
      " a.seq_reg_mestre, a.ordem_producao, d.operacao, a.data_producao,  ",
      " p.seq_registro_item, p.item_produzido, p.qtd_produzida, p.qtd_convertida, ",
      " p.tip_producao, t.num_lote_dest ",
      " FROM man_apo_mestre a, ordens c, man_item_produzido p, ",
      " estoque_trans t, estoque_lote e, man_apo_detalhe d, ord_oper o ",
      " WHERE a.empresa = '",p_cod_empresa,"' ", 
      " AND a.sit_apontamento = 'A' ",
      " AND a.data_producao >= '",mr_cabec.dat_producao,"' ",
      " AND a.data_producao <= '",mr_cabec.dat_ate,"' ",
      " AND a.empresa = c.cod_empresa ",
      " AND a.ordem_producao = c.num_ordem ",
      " AND c.ies_situa IN (SELECT s.ies_situa FROM status_912 s) ",
      " AND a.empresa = d.empresa ",
      " and a.seq_reg_mestre = d.seq_reg_mestre ",
      " and o.cod_empresa = c.cod_empresa ",
      " and o.num_ordem = c.num_ordem ",
      " and o.cod_operac = d.operacao ",
      " and o.ies_oper_final = 'S' ",
      " AND a.empresa = p.empresa ",
      " and a.seq_reg_mestre = p.seq_reg_mestre ",
      " AND p.tip_movto = 'N' ",
      " AND t.cod_empresa = p.empresa ",
      " and t.num_transac = p.moviment_estoque ",
      " and t.ies_tip_movto = 'N' ",
      " and e.cod_empresa = t.cod_empresa ",
      " and e.cod_item = t.cod_item ",
      " and e.cod_local = t.cod_local_est_dest ",
      " and e.num_lote = t.num_lote_dest ",
      " and e.ies_situa_qtd = t.ies_sit_est_dest "

   IF mr_cabec.num_ordem IS NOT NULL THEN
      LET m_query = m_query CLIPPED,
          " AND c.num_ordem = ", mr_cabec.num_ordem
   END IF

   IF mr_cabec.cod_item IS NOT NULL THEN
      LET m_query = m_query CLIPPED,
          " AND c.cod_item = '",mr_cabec.cod_item,"' "
   END IF

   
END FUNCTION




#--------------------------#
FUNCTION pol1356_ies_cons()#
#--------------------------#

   IF NOT m_ies_info THEN
      LET m_msg = 'Informe previamente os parâmetros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1356_estornar()#
#-------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT pol1356_ies_cons() THEN
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_browse,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_browse,"SELECT_ITEM",1,13)

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1356_cancela_estorno()#
#---------------------------------#

   LET m_ies_info = FALSE
   CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1356_confirma_estorno()#
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
   
   CALL LOG_progresspopup_start("Estornando...","pol1356_proces_estorno","PROCESS")   
         
   IF m_qtd_erro > 1 THEN   
      LET m_msg = 'Um ou mais registros não foi estornado.\n',
                  'Consulte os erros de estorno.'
      CALL log0030_mensagem(m_msg,'info')
      LET m_qtd_erro = m_qtd_erro  - 1
   END IF
   
   LET m_ies_info = FALSE
   
   RETURN TRUE
            
   
END FUNCTION

#-------------------------------#
FUNCTION pol1356_proces_estorno()#
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
             CALL pol1356_le_erros()
             CALL log085_transacao("ROLLBACK")
          ELSE
             CALL log085_transacao("COMMIT")
             LET ma_itens[m_ind].mensagem = 'Estornado' 
             CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","mensagem",m_ind,"Estornado")
             CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_ind,249,75,32)
          END IF
          LET l_progres = LOG_progresspopup_increment("PROCESS")
       END IF
   END FOR
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
END FUNCTION

#--------------------------------------#
FUNCTION pol1356_cria_estorno_erro_304()#
#--------------------------------------#
   
   DROP TABLE estorno_erro_304
   
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

#-----------------------------#
FUNCTION pol1356_exibe_erros()#
#-----------------------------#

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
FUNCTION pol1356_le_erros()#
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
