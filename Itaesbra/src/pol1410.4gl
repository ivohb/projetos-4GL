#-------------------------------------------------------------------#
# SISTEMA.: LOGIX      ETHOS METALURGICA                            #
# PROGRAMA: pol1410                                                 #
# OBJETIVO: RELAT�RIO DO CONSUMO REAL DA ORDEM DE PRODU��O          #
# AUTOR...: IVO                                                     #
# DATA....: 11/12/2020                                              #
#-------------------------------------------------------------------#
# Altera��es                                                        #
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

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_pan_top         VARCHAR(10),
       m_pan_left        VARCHAR(10),
       m_pan_center      VARCHAR(10),
       m_brz_ordem       VARCHAR(10),
       m_ordem           VARCHAR(10),
       m_dat_ini         VARCHAR(10),
       m_dat_fim         VARCHAR(10),
       m_lupa_op         VARCHAR(10),
       m_zoom_op         VARCHAR(10),
       m_datini          VARCHAR(10),
       m_datfim          VARCHAR(10),
       m_exibe           VARCHAR(10)

DEFINE m_msg             VARCHAR(120),
       m_car_ordem       SMALLINT,
       m_car_compon      SMALLINT,
       m_ies_info        SMALLINT,
       m_query           VARCHAR(800),
       m_ind             INTEGER,
       m_cust_med        DECIMAL(12,4),
       m_num_ordem       INTEGER,
       m_qtd_produz      DECIMAL(10,3),
       m_count           INTEGER,
       m_page_length     INTEGER,
       m_ies_imp         SMALLINT,
       m_cod_operacao    VARCHAR(04),
       m_num_docum       VARCHAR(10)

DEFINE mr_param           RECORD
       dat_ini            DATE,
       dat_fim            DATE,
       num_ordem          INTEGER,
       exib_na_grad       CHAR(01)
END RECORD

DEFINE ma_ordem          ARRAY[15000] OF RECORD
   num_ordem             INTEGER,
   cod_item              VARCHAR(15),
   den_item              VARCHAR(40),
   cod_unid_med          VARCHAR(03),
   ult_cust_med          DECIMAL(12,2),
   qtd_planej            DECIMAL(10,3),
   qtd_produzida         DECIMAL(10,3),
   cod_item_compon       VARCHAR(15),
   den_compon            VARCHAR(40),
   cod_unid_compon       VARCHAR(03),
   consumo_prev          DECIMAL(10,3),
   consumo_real          DECIMAL(10,3),
   dif_consumo           DECIMAL(10,3),
   sinal                 CHAR(01),
   ult_cust_compon       DECIMAL(12,2)
END RECORD

DEFINE mr_relat      RECORD        
   num_ordem         INTEGER,            
   cod_item          VARCHAR(15),            
   den_item          VARCHAR(40),            
   cod_unid_med      VARCHAR(03),            
   qtd_planej        DECIMAL(10,3),          
   qtd_produzida     DECIMAL(10,3),          
   ult_cust_med      DECIMAL(12,2)           
END RECORD                            

DEFINE mr_consumo       RECORD
   cod_item_compon      VARCHAR(15),
   den_item             VARCHAR(40),
   cod_unid_med         VARCHAR(03),
   consumo_prev         DECIMAL(10,3),
   consumo_real         DECIMAL(10,3),
   dif_consumo          DECIMAL(10,3),
   sinal                CHAR(01),
   ult_cust_med         DECIMAL(12,2)
END RECORD

#-----------------#
FUNCTION pol1410()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   
   LET p_versao = "pol1410-12.00.03  "
   CALL func002_versao_prg(p_versao)
   
   IF pol1410_cria_tab_con() THEN
      CALL pol1410_menu()
   END IF
    
END FUNCTION    

#----------------------#
FUNCTION pol1410_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_print       VARCHAR(10),      
           l_titulo      VARCHAR(80)

    
    LET l_titulo = "RELAT�RIO DO CONSUMO REAL DA ORDEM DE PRODU��O - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1410_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1410_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1410_cancelar")

    LET l_print = _ADVPL_create_component(NULL,"LPRINTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_print,"EVENT","pol1410_tela_print")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1410_panel_top(l_panel)
   CALL pol1410_panel_center(l_panel)
   
   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#--------------------------------------#
FUNCTION pol1410_panel_top(l_container)#
#--------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_layout          VARCHAR(10)

    LET m_pan_top = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_top,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_top,"HEIGHT",70)
    CALL _ADVPL_set_property(m_pan_top,"ENABLE",FALSE) 

   LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pan_top)
   CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",9)

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
   CALL _ADVPL_set_property(l_label,"TEXT","Ordens encerradas de:")    

   LET m_dat_ini = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
   CALL _ADVPL_set_property(m_dat_ini,"VARIABLE",mr_param,"dat_ini")
   CALL _ADVPL_set_property(m_dat_ini,"ENABLE",TRUE)

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
   CALL _ADVPL_set_property(l_label,"TEXT","   At�:")    

   LET m_dat_fim = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
   CALL _ADVPL_set_property(m_dat_fim,"VARIABLE",mr_param,"dat_fim")
   CALL _ADVPL_set_property(m_dat_fim,"ENABLE",TRUE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","     N�m ordem:")    

    LET m_ordem = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_ordem,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_ordem,"PICTURE","@E #########")
    CALL _ADVPL_set_property(m_ordem,"VARIABLE",mr_param,"num_ordem")
    CALL _ADVPL_set_property(m_ordem,"VALID","pol1410_valid_ordem")

    LET m_lupa_op = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_op,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_op,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_op,"CLICK_EVENT","pol1410_zoom_ordem")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET m_exibe = _ADVPL_create_component(NULL,"LCHECKBOX",l_layout)
    CALL _ADVPL_set_property(m_exibe,"TEXT","Exibir na grade?")     
    CALL _ADVPL_set_property(m_exibe,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_exibe,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_exibe,"VARIABLE",mr_param,"exib_na_grad")


END FUNCTION

#-----------------------------------------#
FUNCTION pol1410_panel_center(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_pan_left = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_left,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pan_left)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_ordem= _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_ordem,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ordem")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Unid")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_unid_med")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Planejado")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_planej")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Produzido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_produzida")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Custo med")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ult_cust_med")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Componente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Unid")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_unid_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd. padr�o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","consumo_prev")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd. real")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","consumo_real")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Diferen�a")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dif_consumo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Custo med")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ult_cust_compon")

    CALL _ADVPL_set_property(m_brz_ordem,"SET_ROWS",ma_ordem,1)
    CALL _ADVPL_set_property(m_brz_ordem,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_ordem,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_ordem,"EDITABLE",FALSE)

END FUNCTION

#-----------------------------#
FUNCTION pol1410_valid_ordem()#
#-----------------------------#
   
   DEFINE l_ies_situa    CHAR(01)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_param.num_ordem IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT ies_situa
     INTO l_ies_situa
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = mr_param.num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens')
      RETURN FALSE
   END IF
   
   IF l_ies_situa <> '5' THEN
      LET m_msg = 'Ordem n�o est� encerrada: ',l_ies_situa
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1410_zoom_ordem()#
#----------------------------#
    
   DEFINE l_ordem       LIKE ordens.num_ordem,
          l_filtro      CHAR(300)

   IF m_zoom_op IS NULL THEN
      LET m_zoom_op = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_zoom_op,"ZOOM","zoom_ordem_producao")
   END IF

    LET l_filtro = " ordens.cod_empresa = '",p_cod_empresa CLIPPED,"' AND ordens.ies_situa = '3' "
    CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_zoom_op,"ACTIVATE")

   LET l_ordem = _ADVPL_get_property(m_zoom_op,"RETURN_BY_TABLE_COLUMN","ordens","num_ordem")
   
   IF l_ordem IS NOT NULL THEN
      LET mr_param.num_ordem = l_ordem
   END IF
   
   CALL _ADVPL_set_property(m_ordem,"GET_FOCUS")
   
END FUNCTION

#------------------------------#
FUNCTION pol1410_limpa_campos()#
#------------------------------#

   INITIALIZE mr_param.*, ma_ordem TO NULL
   
   CALL _ADVPL_set_property(m_brz_ordem,"CLEAR")

END FUNCTION

#--------------------------#
FUNCTION pol1410_informar()#
#--------------------------#
      
   CALL pol1410_limpa_campos()
   LET m_ies_info = FALSE
   CALL _ADVPL_set_property(m_pan_top,"ENABLE",TRUE) 
   CALL _ADVPL_set_property(m_dat_ini,"GET_FOCUS")
      
   RETURN TRUE 
    
END FUNCTION

#--------------------------#
FUNCTION pol1410_cancelar()#
#--------------------------#

   CALL pol1410_limpa_campos()
   CALL _ADVPL_set_property(m_pan_top,"ENABLE",FALSE) 
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1410_confirmar()#
#---------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   IF mr_param.dat_ini IS NOT NULL AND mr_param.dat_fim IS NOT NULL THEN
      IF mr_param.dat_ini > mr_param.dat_fim THEN
         LET m_msg = 'Per�odo inv�lido.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         CALL _ADVPL_set_property(m_dat_ini,"GET_FOCUS")
         RETURN FALSE
      END IF
   END IF
   
   IF mr_param.num_ordem IS NULL OR mr_param.num_ordem = 0 THEN
      IF mr_param.dat_ini IS NULL THEN
         LET m_msg = 'Informe a data inicial.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         CALL _ADVPL_set_property(m_dat_ini,"GET_FOCUS")
         RETURN FALSE
      END IF
      IF mr_param.dat_fim IS NULL THEN
         LET m_msg = 'Informe a data final.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         CALL _ADVPL_set_property(m_dat_fim,"GET_FOCUS")
         RETURN FALSE
      END IF
      LET mr_param.num_ordem = NULL
   END IF
   
   CALL pol1410_prepare_query()
   
   LET m_ies_info = TRUE
   
   CALL _ADVPL_set_property(m_pan_top,"ENABLE",FALSE)

   IF NOT pol1410_carrega_temp() THEN
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o a dados para os par�metros informados.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF mr_param.exib_na_grad = 'N' THEN
      RETURN TRUE
   END IF

   LET m_car_ordem = TRUE
      
   LET p_status = LOG_progresspopup_start(
       "Preenchendo grade...","pol1410_exib_ordens","PROCESS")  

   LET m_car_ordem = FALSE   
   
   RETURN TRUE
    
END FUNCTION

#-------------------------------#
FUNCTION pol1410_prepare_query()#
#-------------------------------#
   
   DEFINE l_num_ordem     VARCHAR(10)
   
   LET m_query = 
        "SELECT o.num_ordem, o.cod_item, o.qtd_planej, ",
        "(o.qtd_boas + o.qtd_refug + o.qtd_sucata), ",
        "i.den_item_reduz, i.cod_unid_med from ordens o ",
        "inner join item i on i.cod_empresa = o.cod_empresa ",
        " and i.cod_item = o.cod_item "

   IF mr_param.num_ordem IS NULL THEN        
      LET m_query = m_query CLIPPED,
          " inner join cst_audit_op c on c.empresa = o.cod_empresa ",
          " and c.ordem_producao = o.num_ordem ",
          " and c.dat_encerram >= '",mr_param.dat_ini,"' ",
          " and c.dat_encerram <= '",mr_param.dat_fim,"' "
   END IF
   
   LET m_query = m_query CLIPPED,
       " where o.cod_empresa = '",p_cod_empresa,"' ",
       " and o.ies_situa = '5' ",
       " and o.cod_item[1,3] <> 'SOL' ",
       " and o.cod_item[1,3] <> 'EMB' "
       
   IF mr_param.num_ordem IS NOT NULL THEN    
      LET l_num_ordem = mr_param.num_ordem
      LET m_query = m_query CLIPPED,
          " and o.num_ordem = '",l_num_ordem,"' "
   END IF
             
END FUNCTION

#------------------------------#
FUNCTION pol1410_carrega_temp()#
#------------------------------#

   LET p_status = LOG_progresspopup_start(
       "Carregando dados...","pol1410_grava_temp","PROCESS")  

   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   SELECT COUNT(*) INTO m_count
    FROM w_ordens

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('SELECT','w_ordens:count')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol1410_exib_ordens()#
#-----------------------------#

   DEFINE l_progres    SMALLINT,
          l_status     SMALLINT

   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   LET m_ind = 1
   
   DECLARE cq_exib CURSOR FOR
    SELECT * FROM w_ordens
     ORDER BY num_ordem
   
   FOREACH cq_exib INTO
      ma_ordem[m_ind].num_ordem,    
      ma_ordem[m_ind].cod_item,     
      ma_ordem[m_ind].den_item,     
      ma_ordem[m_ind].cod_unid_med,
      ma_ordem[m_ind].qtd_planej,   
      ma_ordem[m_ind].qtd_produzida,
      ma_ordem[m_ind].ult_cust_med

      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("PREPARE","cq_exib",0)
         RETURN FALSE
      END IF

      LET m_num_ordem = ma_ordem[m_ind].num_ordem
      LET m_qtd_produz = ma_ordem[m_ind].qtd_produzida
      LET m_num_docum = m_num_ordem
   
      IF NOT pol1410_le_consumo() THEN  
         RETURN FALSE
      END IF

      DECLARE cq_le_comp CURSOR FOR
       SELECT * FROM w_consumo_temp
   
      FOREACH cq_le_comp INTO mr_consumo.*

         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','w_consumo_temp:RELAT')
            RETURN FALSE
         END IF

         LET m_ind = m_ind + 1
     
         IF m_ind > 15000 THEN
            LET m_msg = 'Limite de linhas da grade\n de ordens ultrapassou'
            CALL log0030_mensagem(m_msg,'info')
            EXIT FOREACH
         END IF
         
         LET ma_ordem[m_ind].cod_item_compon = mr_consumo.cod_item_compon 
         LET ma_ordem[m_ind].den_compon      = mr_consumo.den_item        
         LET ma_ordem[m_ind].cod_unid_compon = mr_consumo.cod_unid_med    
         LET ma_ordem[m_ind].consumo_prev    = mr_consumo.consumo_prev    
         LET ma_ordem[m_ind].consumo_real    = mr_consumo.consumo_real    
         LET ma_ordem[m_ind].dif_consumo     = mr_consumo.dif_consumo     
         LET ma_ordem[m_ind].sinal           = mr_consumo.sinal           
         LET ma_ordem[m_ind].ult_cust_compon = mr_consumo.ult_cust_med             

         LET l_progres = LOG_progresspopup_increment("PROCESS")
              
      END FOREACH

      LET m_ind = m_ind + 1
     
      IF m_ind > 15000 THEN
         LET m_msg = 'Limite de linhas da grade\n de ordens ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   IF m_ind = 1 THEN
      LET m_msg = 'N�o h� dados para os\n par�metros informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   LET m_ind = m_ind - 1
   
   CALL _ADVPL_set_property(m_brz_ordem,"ITEM_COUNT", m_ind)

   LET l_progres = LOG_progresspopup_increment("PROCESS")

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1410_le_custo(l_item)#
#--------------------------------#
   
   DEFINE l_item        VARCHAR(15),
          l_ano_mes     INTEGER
   
   SELECT MAX(ano_mes_ref) 
     INTO l_ano_mes
     FROM estoque_hist 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_item

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql("SELECT","estoque_hist:ano_mes",0)
      RETURN FALSE
   END IF
   
   IF l_ano_mes IS NULL THEN
      LET m_cust_med = 0
      RETURN TRUE
   END IF
            
   SELECT cus_unit_medio 
     INTO m_cust_med
     FROM estoque_hist 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_item
      AND ano_mes_ref = l_ano_mes
      
   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql("SELECT","estoque_hist:custo",0)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1410_cria_tab_con()#
#------------------------------#
 
    SELECT cod_estoque_sp
     INTO m_cod_operacao
     FROM par_pcp 
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql("SELECT","par_pcp",0)
      RETURN FALSE
   END IF

   DROP TABLE w_consumo_temp
   
   CREATE TEMP TABLE w_consumo_temp(
   cod_item_compon      VARCHAR(15),
   den_item             VARCHAR(40),
   cod_unid_med         VARCHAR(03),
   consumo_prev         DECIMAL(10,3),
   consumo_real         DECIMAL(10,3),
   dif_consumo          DECIMAL(10,3),
   sinal                CHAR(01),
   ult_cust_med         DECIMAL(12,2))

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql("CREATE","w_consumo_temp",0)
      RETURN FALSE
   END IF
   
   CREATE INDEX ix_w_consumo_temp ON w_consumo_temp(cod_item_compon)
   
   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql("CREATE","ix_w_consumo_temp",0)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1410_le_consumo()#
#----------------------------#
   
   DEFINE l_qtd_baixa   LIKE man_comp_consumido.qtd_baixa_real,
          l_qtd_estorno LIKE man_comp_consumido.qtd_baixa_real,
          l_compon      LIKE man_comp_consumido.item_componente,
          l_qtd_prev    LIKE ord_compon.qtd_necessaria,
          l_dif_consumo LIKE ord_compon.qtd_necessaria,
          l_ind         INTEGER,
          l_desc        VARCHAR(40), 
          l_uni         VARCHAR(03),
          l_sinal       CHAR(01)
   
   DELETE FROM w_consumo_temp

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql("DELETE","w_consumo_temp",0)
      RETURN FALSE
   END IF
      
   DECLARE cq_it_comp CURSOR FOR
    SELECT cod_item_compon,  
       SUM(qtd_necessaria * m_qtd_produz) 
      FROM ord_compon 
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem = m_num_ordem
       AND cod_item_compon[1,3] <> 'SOL' 
       AND cod_item_compon[1,3] <> 'EMB' 
     GROUP BY cod_item_compon

   FOREACH cq_it_comp INTO l_compon, l_qtd_prev
   
      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("FOREACH","ord_compon:cq_it_comp",0)
         RETURN FALSE
      END IF

      SELECT SUM(qtd_movto) INTO l_qtd_baixa
        FROM estoque_trans 
       WHERE cod_empresa = p_cod_empresa
         AND num_docum =  m_num_docum
         AND cod_operacao = m_cod_operacao 
         AND cod_item = l_compon
         AND ies_tip_movto = 'N'  
         
      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("SELECT","estoque_trans:N",0)
         RETURN FALSE
      END IF
      
      IF l_qtd_baixa IS NULL THEN
         LET l_qtd_baixa = 0
      END IF
         
      SELECT SUM(qtd_movto) INTO l_qtd_estorno
        FROM estoque_trans 
       WHERE cod_empresa = p_cod_empresa
         AND num_docum =  m_num_docum
         AND cod_operacao = m_cod_operacao 
         AND cod_item = l_compon
         AND ies_tip_movto = 'R'  
         
      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("SELECT","estoque_trans:R",0)
         RETURN FALSE
      END IF

      IF l_qtd_estorno IS NULL THEN
         LET l_qtd_estorno = 0
      END IF

      LET l_qtd_baixa = l_qtd_baixa - l_qtd_estorno                          
      LET l_dif_consumo = l_qtd_baixa - l_qtd_prev 
      
      IF l_dif_consumo < 0 THEN
         LET l_sinal = '-'
      ELSE
         IF l_dif_consumo > 0 THEN
            LET l_sinal = '+'
         ELSE
            LET l_sinal = ' '
         END IF
      END IF
      
      IF NOT pol1410_le_custo(l_compon) THEN
         RETURN FALSE
      END IF           
      
      SELECT den_item_reduz,
             cod_unid_med
        INTO l_desc, l_uni
        FROM item
       WHERE cod_empresa = p_cod_empresa 
         AND cod_item = l_compon 

      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("SELECT","item(1)",0)
         RETURN FALSE
      END IF
      
      INSERT INTO w_consumo_temp
       VALUES(l_compon, l_desc, l_uni, l_qtd_prev, l_qtd_baixa, l_dif_consumo, l_sinal, m_cust_med)
        
      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("INSERT","w_consumo_temp",0)
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1410_cria_temp()#
#---------------------------#

   DROP TABLE w_ordens
   
   CREATE TEMP TABLE w_ordens (
      num_ordem             INTEGER,
      cod_item              VARCHAR(15),
      den_item              VARCHAR(40),
      cod_unid_med          VARCHAR(03),
      qtd_planej            DECIMAL(10,3),
      qtd_produzida         DECIMAL(10,3),
      ult_cust_med          DECIMAL(12,2)
   )

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('CREATE','w_ordens')
      RETURN FALSE
   END IF
   
   CREATE INDEX ix_w_ordens ON w_ordens
    (num_ordem)

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('CREATE','ix_w_ordens')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
   
#----------------------------#
FUNCTION pol1410_grava_temp()#
#----------------------------#
   
   DEFINE l_progres     SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",1000)

   IF NOT pol1410_cria_temp() THEN
      RETURN FALSE
   END IF

   PREPARE var_temp FROM m_query
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('PREPARE','var_temp')
      RETURN FALSE
   END IF
   
   DECLARE cq_temp CURSOR FOR var_temp

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql("DECLARE","cq_temp",0)
      RETURN FALSE
   END IF
   
   LET m_ind = 1
   
   FOREACH cq_temp INTO 
      mr_relat.num_ordem,    
      mr_relat.cod_item,     
      mr_relat.qtd_planej,   
      mr_relat.qtd_produzida,
      mr_relat.den_item,     
      mr_relat.cod_unid_med

      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("PREPARE","cq_temp",0)
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      IF NOT pol1410_le_custo(mr_relat.cod_item) THEN
         RETURN FALSE
      END IF
     
      LET mr_relat.ult_cust_med = m_cust_med
     
      INSERT INTO w_ordens VALUES(mr_relat.*)   
     
      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("INSERT","w_ordens",0)
         RETURN FALSE
      END IF
   
   END FOREACH
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   RETURN TRUE

END FUNCTION

#----------------------------#      
FUNCTION pol1410_tela_print()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF NOT m_ies_info  THEN
      LET m_msg = 'Informe previamente os par�metros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
   
   LET p_status = StartReport(
       "pol1410_relatorio","pol1410","RELAT�RIO DO CONSUMO REAL DA ORDEM DE PRODU��O",153,TRUE,TRUE)

   RETURN p_status

END FUNCTION

#-----------------------------------#
FUNCTION pol1410_relatorio(l_report)#
#-----------------------------------#
   
   DEFINE l_report    CHAR(300),
          l_cod_cli   CHAR(15),
          l_status    SMALLINT,
          l_sql       CHAR(800)
   
   LET l_status = TRUE   
   LET m_page_length = ReportPageLength("pol1410")
       
   START REPORT pol1410_relat TO l_report

   CALL pol1410_le_den_empresa() RETURNING l_status
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   LET p_status = LOG_progresspopup_start(
       "Preenchendo grade...","pol1410_imprime","PROCESS")  
   
   RETURN p_status

END FUNCTION
   
#-------------------------#
FUNCTION pol1410_imprime()#
#-------------------------#
   
   DEFINE l_progres   SMALLINT,
          l_status    SMALLINT
          
   LET l_status = TRUE
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   DECLARE cq_rel CURSOR FOR 
    SELECT * FROM w_ordens          
     ORDER BY num_ordem

   FOREACH cq_rel INTO mr_relat.*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','w_ordens:cq_rel')
         LET l_status = FALSE
         EXIT FOREACH
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS") 
      
      OUTPUT TO REPORT pol1410_relat()

   END FOREACH

   FINISH REPORT pol1410_relat

   CALL FinishReport("pol1410")
   
   RETURN l_status
   
END FUNCTION

#--------------------------------#
 FUNCTION pol1410_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
   
#---------------------#
REPORT pol1410_relat()#
#---------------------#

   DEFINE l_num_ordem   INTEGER,
          l_linha       VARCHAR(114)
   
    OUTPUT
        TOP    MARGIN 0
        LEFT   MARGIN 0
        RIGHT  MARGIN 0
        BOTTOM MARGIN 0
        PAGE   LENGTH m_page_length
   
    FORMAT

    PAGE HEADER

      CALL ReportPageHeader("pol1410")
            
      PRINT COLUMN 001, 'ORDEM     ITEM            DESCRICAO          UND CUSTO MED PRODUZIDO  COMPONENETE     DESCRCAO           UND QTD PADRAO QTD REAL   DIFRENCA   CUSTO MED'
      PRINT COLUMN 001, '--------- --------------- ------------------ --- --------- ---------- --------------- ------------------ --- ---------- ---------- ---------- ---------'
      SKIP 1 LINE
           
    ON EVERY ROW

      PRINT COLUMN 001, mr_relat.num_ordem USING '#########',
            COLUMN 011, mr_relat.cod_item,
            COLUMN 027, mr_relat.den_item[1,18],
            COLUMN 046, mr_relat.cod_unid_med,
            COLUMN 050, mr_relat.ult_cust_med  USING '#####&.&&',   
            COLUMN 060, mr_relat.qtd_produzida USING '######&.&&' 
            
       LET m_num_ordem = mr_relat.num_ordem
       LET m_qtd_produz = mr_relat.qtd_produzida
       LET m_num_docum = m_num_ordem

       CALL pol1410_le_consumo() RETURNING p_status

       DECLARE cq_le_cons CURSOR FOR
        SELECT * FROM w_consumo_temp
   
       FOREACH cq_le_cons INTO mr_consumo.*

          IF STATUS <> 0 THEN
             CALL log003_err_sql('FOREACH','w_consumo_temp:RELAT')
             EXIT FOREACH
          END IF
       
          PRINT COLUMN 071, mr_consumo.cod_item_compon,
                COLUMN 087, mr_consumo.den_item[1,18],
                COLUMN 106, mr_consumo.cod_unid_med,
                COLUMN 110, mr_consumo.consumo_prev USING '#####&.&&&',     
                COLUMN 121, mr_consumo.consumo_real USING '#####&.&&&',     
                COLUMN 132, mr_consumo.dif_consumo  USING '#####&.&&&',     
                COLUMN 142, mr_consumo.sinal,
                COLUMN 143, mr_consumo.ult_cust_med USING '###&.&&&&'   
       END FOREACH
        
END REPORT
