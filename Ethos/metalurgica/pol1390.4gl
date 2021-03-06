#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1390                                                 #
# OBJETIVO: CONFER�NCIA DE PEDIDOS                                  #
# AUTOR...: IVO                                                     #
# DATA....: 10/03/20                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003)
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_browse          VARCHAR(10),
       m_pnl_cabec       VARCHAR(10),
       m_pnl_item        VARCHAR(10),
       m_pnl_rod         VARCHAR(10),
       m_dat_carga       VARCHAR(10)
       
DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_carregando      SMALLINT,
       m_progres         SMALLINT,
       m_ind             INTEGER,
       m_item_cliente    CHAR(30),
       m_tip_pedido      CHAR(02),
       m_qtd_dias        DECIMAL(3,0),
       m_dias_pad        DECIMAL(3,0),
       m_qtd_linha       INTEGER,
       m_cap_dia_fab     INTEGER,
       m_dias_prod       INTEGER

DEFINE mr_cabec          RECORD
       dat_proc_edi      DATE        
END RECORD

DEFINE ma_itens ARRAY[1000] OF RECORD
       nom_reduzido         CHAR(15),       
       num_pedido           DECIMAL(6,0),
       num_ped_cli          CHAR(30),
       num_sequencia        DECIMAL(4,0),
       observacao           CHAR(03),
       divergencia          CHAR(03),
       amostra              CHAR(03),
       cod_item_cliente     CHAR(30),
       cod_item             CHAR(15),
       tamanho              CHAR(01),
       den_item             CHAR(18),
       dat_abertura         DATE,
       ship_date_cli        DATE,
       ship_sugerido        DATE,
       qtd_aceita           DECIMAL(5,0),
       tip_pedido           CHAR(02),
       qtd_dia_pad          DECIMAL(3,0),
       qtd_dia_util         DECIMAL(3,0),
       qtd_dia_min          DECIMAL(3,0),
       ini_prod_pad         DATE,
       fim_prod_pad         DATE,
       ini_prod_esp         DATE,
       fim_prod_esp         DATE,
       cod_cliente          CHAR(15),
       men_ger_edi          CHAR(09),
       men_ger_conf         CHAR(20)
END RECORD
   
#-----------------#
FUNCTION pol1390()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 90
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1390-12.00.00  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1390_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1390_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_info        VARCHAR(10),
           l_proces      VARCHAR(10),
           l_carga       VARCHAR(10),
           l_titulo      CHAR(100)
    
    LET l_titulo = "CONFER�NCIA DE PEDIDOS - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_info = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_info,"TOOLTIP","Informar data da carga do EDI")
    CALL _ADVPL_set_property(l_info,"EVENT","pol1390_informar")
    CALL _ADVPL_set_property(l_info,"CONFIRM_EVENT","pol1390_confirmar")
    CALL _ADVPL_set_property(l_info,"CANCEL_EVENT","pol1390_cancelar")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Processa a confer�ncia dos pedidos")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1390_processar")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1390_cria_cabec(l_panel)
   CALL pol1390_cria_rodape(l_panel)
   CALL pol1390_cria_item(l_panel)

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------------#
FUNCTION pol1390_cria_cabec(l_panel)#
#-----------------------------------#

    DEFINE l_panel, l_label           VARCHAR(10)

    LET m_pnl_cabec = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel)
    CALL _ADVPL_set_property(m_pnl_cabec,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pnl_cabec,"HEIGHT",60)
    CALL _ADVPL_set_property(m_pnl_cabec,"ENABLE",FALSE)
    CALL _ADVPL_set_property(m_pnl_cabec,"BACKGROUND_COLOR",231,237,237)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Dat carga EDI:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dat_carga = _ADVPL_create_component(NULL,"LDATEFIELD",m_pnl_cabec)     
    CALL _ADVPL_set_property(m_dat_carga,"POSITION",120,10)   
    CALL _ADVPL_set_property(m_dat_carga,"VARIABLE",mr_cabec,"dat_proc_edi")

END FUNCTION

#------------------------------------#
FUNCTION pol1390_cria_rodape(l_panel)#
#------------------------------------#

    DEFINE l_panel, l_label           VARCHAR(10)

    LET m_pnl_rod = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel)
    CALL _ADVPL_set_property(m_pnl_rod,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(m_pnl_rod,"HEIGHT",60)
    CALL _ADVPL_set_property(m_pnl_rod,"ENABLE",FALSE)
    CALL _ADVPL_set_property(m_pnl_rod,"BACKGROUND_COLOR",231,237,237)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_rod)
    CALL _ADVPL_set_property(l_label,"POSITION",5,5) 
    CALL _ADVPL_set_property(l_label,"TEXT","A - TIPO DO PEDIDO (KA=KANBAN)")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_rod)
    CALL _ADVPL_set_property(l_label,"POSITION",5,25) 
    CALL _ADVPL_set_property(l_label,"TEXT","B - QTD DIAS PADR�O CONFORME O TIPO DO PEDIDO")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_rod)
    CALL _ADVPL_set_property(l_label,"POSITION",350,5) 
    CALL _ADVPL_set_property(l_label,"TEXT","C - DIAS �TEIS ENRE A ENTREGA DO PEDIDO E O SHIP DATE")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_rod)
    CALL _ADVPL_set_property(l_label,"POSITION",350,25) 
    CALL _ADVPL_set_property(l_label,"TEXT","D - QTD M�NIMA DE DIAS �TEIS PARA PRODUZIR O ITEM")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

END FUNCTION

#----------------------------------#
FUNCTION pol1390_cria_item(l_panel)#
#----------------------------------#

    DEFINE l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_pnl_item = _ADVPL_create_component(NULL,"LPANEL",l_panel)
    CALL _ADVPL_set_property(m_pnl_item,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pnl_item)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_reduzido")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_pedido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Seq")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_sequencia")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Obs")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","observacao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Div")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",25)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","divergencia")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Amos")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","amostra")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item_cliente")
                    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item logix")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
           
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tam")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","tamanho")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd prog")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_aceita")
                   
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Abertura")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_abertura")
                    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ship Date")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ship_date_cli")
                   
    {LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ship sugerido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ship_sugerido")}
                             
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","A")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",25)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","tip_pedido")
              
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","B")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",25)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_dia_pad")
                
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","C")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",25)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_dia_util")
                 
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","D")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",25)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_dia_min")
                
    {LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ini prod pad")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ini_prod_pad")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Fim prod pad")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","fim_prod_pad")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ini prod esp")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ini_prod_esp")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Fim prod esp")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","fim_prod_esp")}

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Msg Confer�ncia")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","men_ger_conf")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Msg EDI")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","men_ger_edi")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
    

END FUNCTION

#--------------------------#
FUNCTION pol1390_informar()#
#--------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_itens TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   
   LET m_ies_info = FALSE
   
   CALL _ADVPL_set_property(m_pnl_cabec,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_dat_carga,"GET_FOCUS")
      
   RETURN TRUE 
    
END FUNCTION

#--------------------------#
FUNCTION pol1390_cancelar()#
#--------------------------#

   INITIALIZE mr_cabec.* TO NULL    
   CALL _ADVPL_set_property(m_pnl_cabec,"ENABLE",FALSE)

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1390_confirmar()#
#---------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_cabec.dat_proc_edi IS NULL THEN
      LET m_msg = 'Informe a data do processamento do EDI'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_dat_carga,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   SELECT COUNT(dat_proces) INTO m_count
     FROM prog_efetivada_547
    WHERE cod_empresa = p_cod_empresa
      AND dat_proces = mr_cabec.dat_proc_edi

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','prog_efetivada_547:p1')
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_pnl_cabec,"ENABLE",FALSE)
   
   IF m_count = 0 THEN
      LET m_msg = 'Nenhuma programa��o foi efetivada nessa data'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE      
   END IF
   
   LET m_ies_info = TRUE
      
   RETURN TRUE
    
END FUNCTION

#---------------------------#
FUNCTION pol1390_processar()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   IF NOT m_ies_info THEN
      LET m_msg = 'Informe a data do EDI previamene.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET m_ies_info = FALSE
   
   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1390_le_prog_efetiv","PROCESS")  
   
   IF NOT p_status THEN
      LET m_msg = 'Opera��o cancelada.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE   

END FUNCTION

#--------------------------------#
FUNCTION pol1390_le_prog_efetiv()#
#--------------------------------#

   DEFINE l_progres         SMALLINT,
          l_param           CHAR(20),
          l_cap_dia_fab     CHAR(05)

   LET m_ind = 1
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DECLARE cq_prog_efetiv CURSOR FOR
    SELECT a.num_pedido,
           a.num_sequencia,
           a.cod_item,
           a.qtd_aceita,
           a.prz_entrega,
           a.sit_programa,
           b.cod_cliente,
           b.num_pedido_cli
      FROM prog_efetivada_547 a,
           pedidos b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.dat_proces = mr_cabec.dat_proc_edi
      AND b.cod_empresa = a.cod_empresa
      AND b.num_pedido = a.num_pedido
      AND b.ies_sit_pedido <> '9'

   FOREACH cq_prog_efetiv INTO
           ma_itens[m_ind].num_pedido,
           ma_itens[m_ind].num_sequencia,
           ma_itens[m_ind].cod_item,
           ma_itens[m_ind].qtd_aceita,
           ma_itens[m_ind].dat_abertura,
           ma_itens[m_ind].men_ger_edi,
           ma_itens[m_ind].cod_cliente,
           ma_itens[m_ind].num_ped_cli
           
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','prog_efetivada_547:cq_prog_efetiv')
         RETURN FALSE
      END IF
      
      SELECT den_item_reduz
        INTO ma_itens[m_ind].den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_itens[m_ind].cod_item

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','item:cq_prog_efetiv')
         RETURN FALSE
      END IF

      SELECT cod_etapa
        INTO ma_itens[m_ind].tamanho
        FROM item_man
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_itens[m_ind].cod_item

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','item_man:cq_prog_efetiv')
         RETURN FALSE
      END IF

      SELECT nom_reduzido
        INTO ma_itens[m_ind].nom_reduzido
        FROM clientes
       WHERE cod_cliente = ma_itens[m_ind].cod_cliente

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','clientes:cq_prog_efetiv')
         RETURN FALSE
      END IF

      IF NOT pol1390_le_item_cliente(
      			ma_itens[m_ind].cod_item, ma_itens[m_ind].cod_cliente) THEN
         RETURN FALSE
      END IF
      
      LET ma_itens[m_ind].cod_item_cliente = m_item_cliente
      
      SELECT qtd_dias
        INTO m_qtd_dias
        FROM item_kanban_547
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_itens[m_ind].cod_item
         AND cod_item_cliente = ma_itens[m_ind].cod_item_cliente
         AND dat_inicio <= TODAY
         AND dat_termino >= TODAY

      IF STATUS = 0 THEN
         LET m_tip_pedido = 'KA'
      ELSE
         IF STATUS = 100 THEN
            
            LET m_tip_pedido = ma_itens[m_ind].num_ped_cli[1,2]
            
            IF m_tip_pedido = 'QA' THEN
               LET l_param = 'QTD_DIAS_ITEM_QA'
            ELSE
               IF m_tip_pedido = 'QH' THEN
                  LET l_param = 'QTD_DIAS_ITEM_QH'
               ELSE
                  LET l_param = 'QTD_DIAS_ITEM_COMUM'
               END IF
            END IF
                    
            SELECT parametro_numerico
              INTO m_qtd_dias
              FROM min_par_modulo
             WHERE empresa = p_cod_empresa
               AND parametro = l_param
           
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','min_par_modulo')
               RETURN FALSE
            END IF
         ELSE
            CALL log003_err_sql('SELECT','item_kanban_547')
            RETURN FALSE
         END IF
      END IF
     
      IF m_qtd_dias IS NULL THEN
         LET m_qtd_dias = 0
      END IF
     
      LET ma_itens[m_ind].tip_pedido = m_tip_pedido
      LET ma_itens[m_ind].qtd_dia_pad = m_qtd_dias
      LET m_dias_pad = m_qtd_dias
       
      SELECT ship_date 
        INTO ma_itens[m_ind].ship_date_cli
        FROM ped_itens_ethos
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = ma_itens[m_ind].num_pedido
         AND num_sequencia = ma_itens[m_ind].num_sequencia
      
      IF STATUS = 100 THEN
         LET ma_itens[m_ind].ship_date_cli = ma_itens[m_ind].dat_abertura
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','min_par_modulo')
            RETURN FALSE
         END IF
      END IF
     
      SELECT COUNT(*) INTO m_count
        FROM ped_itens_texto
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = ma_itens[m_ind].num_pedido
         AND den_texto_1  LIKE '%AMOSTRA%'

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ped_itens_texto')
         RETURN FALSE
      END IF
      
      IF m_count > 0 THEN
         LET ma_itens[m_ind].amostra = 'SIM'
      ELSE
         LET ma_itens[m_ind].amostra = NULL
      END IF
            
      SELECT des_inf_tecnica 
        INTO l_cap_dia_fab
        FROM info_tecnicas
       WHERE cod_empresa = p_cod_empresa
         AND cod_compon =  ma_itens[m_ind].cod_item
         AND cod_pdr_info_tec = 980

      IF STATUS =  100 THEN
         LET m_cap_dia_fab = NULL
      ELSE
         IF STATUS = 0 THEN
            LET m_cap_dia_fab = l_cap_dia_fab
         ELSE
            CALL log003_err_sql('SELECT','ped_itens_texto')
            RETURN FALSE
         END IF
      END IF
      
      LET m_dias_prod = 0
      LET ma_itens[m_ind].qtd_dia_min = NULL
      
      IF m_cap_dia_fab IS NOT NULL THEN
         IF m_cap_dia_fab > 0 THEN
            LET m_dias_prod = ma_itens[m_ind].qtd_aceita / m_cap_dia_fab
            LET ma_itens[m_ind].qtd_dia_min = m_dias_prod
         END IF
      END IF
            
      IF NOT pol1390_calc_col_c() THEN
         RETURN FALSE
      END IF
      
      LET ma_itens[m_ind].qtd_dia_util = m_qtd_dias

      IF m_dias_prod > m_qtd_dias OR m_qtd_dias < m_dias_pad THEN      
         LET ma_itens[m_ind].men_ger_conf = 'PRAZO CURTO'
         CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_ind,180,14,22)
      ELSE
         LET ma_itens[m_ind].men_ger_conf = 'PRAZO OK'
         CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_ind,0,0,0)
      END IF
         
      LET m_ind = m_ind + 1
      
      IF m_ind > 1000 THEN
         LET m_msg = 'Limite de linhas da grade\n de pedidos ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET m_qtd_linha = m_ind - 1
   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_linha)
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------------------------#      
FUNCTION pol1390_le_item_cliente(l_item, l_cliente)#
#--------------------------------------------------#

   DEFINE l_item, l_cliente     CHAR(15),
          l_item_cli            CHAR(30)
   
   LET m_item_cliente = NULL
   
   DECLARE cq_cli_it CURSOR FOR
    SELECT cod_item_cliente
      FROM cliente_item
     WHERE cod_cliente_matriz = l_cliente
       AND cod_item = l_item

   FOREACH cq_cli_it INTO l_item_cli

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','cliente_item:cq_cli_it')
         RETURN FALSE
      END IF
      
      LET m_item_cliente = l_item_cli
      EXIT FOREACH
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1390_calc_col_c()#
#----------------------------#

   DEFINE lr_param               RECORD
          cod_empresa            CHAR(02),
          dat_proces             DATE,
          dat_abertura           DATE,
          dat_ship               DATE
   END RECORD
   
   LET lr_param.dat_proces = mr_cabec.dat_proc_edi
   
   LET lr_param.cod_empresa = p_cod_empresa      
   LET lr_param.dat_abertura = ma_itens[m_ind].dat_abertura
   LET lr_param.dat_ship = ma_itens[m_ind].ship_date_cli
      
   CALL func023_calc_dias(lr_param) RETURNING m_qtd_dias, m_msg
   
   IF m_msg IS NOT NULL THEN
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION




         