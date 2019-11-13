#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1329                                                 #
# OBJETIVO: Tranasferência de saldo para sucata                     #
# AUTOR...: IVO                                                     #
# DATA....: 27/08/20197                                             #
#-------------------------------------------------------------------#
# Alteração                                                         #
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
          g_msg           CHAR(150),
          p_msg           CHAR(150)
END GLOBALS

DEFINE mr_cabec          RECORD
       cod_familia       CHAR(05),
       den_familia       CHAR(30),    
       cod_local         CHAR(30),    
       den_local         CHAR(30),  
       cod_item          CHAR(15),
       den_item          CHAR(50),
       cod_unid_med      CHAR(03),
       ies_tip_item      CHAR(01),
       saldo_ate         DECIMAL(10,0)
END RECORD

DEFINE ma_itens          ARRAY[10000] OF RECORD
       cod_item          CHAR(15),
       den_item_reduz    CHAR(18),
       cod_local         CHAR(10),
       num_lote          CHAR(15),
       ies_situa_qtd     CHAR(01),
       qtd_saldo         DECIMAL(10,3),
 	     pedido            CHAR(35),       
       ies_transf        CHAR(01),
       mensagem          CHAR(150)
END RECORD       

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_cabec           VARCHAR(10),
       m_grade           VARCHAR(10),
       m_browse          VARCHAR(10),
       m_item            VARCHAR(10),
       m_local           VARCHAR(10),
       m_descricao       VARCHAR(10),
       m_tipo            VARCHAR(10),
       m_familia         VARCHAR(10),
       m_lupa_fami       VARCHAR(10),
       m_zoom_fami       VARCHAR(10),
       m_sel_manu        VARCHAR(10),
       m_sel_tudo        VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_msg             CHAR(150),
       m_ies_situa       CHAR(01),
       m_carregando      SMALLINT,
       m_query           CHAR(3000),
       m_where           CHAR(3000),
       m_count           INTEGER,
       m_ind             INTEGER,
	     m_cod_item        CHAR(15),
	     m_cod_sucata      CHAR(15),
	     m_cod_local       CHAR(10),
			 m_qtd_movto       DECIMAL(10,3),
       m_qtd_convertida  DECIMAL(10,3),
       m_fat_conver      DECIMAL(12,5),
       m_qtd_itens       INTEGER,
       m_qtd_selec       INTEGER,
       m_num_lote        CHAR(15)

DEFINE m_unid_item       LIKE item.cod_unid_med, 
       m_unid_sucata     LIKE item.cod_unid_med,
       m_pes_unit        LIKE item.pes_unit,
       m_cod_operacao    LIKE estoque_trans.cod_operacao,
       m_ies_tip_movto   LIKE estoque_trans.ies_tip_movto,
       m_num_docum       LIKE estoque_trans.num_docum,
       m_comprimento     LIKE estoque_lote_ender.comprimento,
       m_largura         LIKE estoque_lote_ender.largura,    
       m_altura          LIKE estoque_lote_ender.altura,     
       m_diametro        LIKE estoque_lote_ender.diametro   
       
DEFINE m_tip_operacao    CHAR(01)
 
DEFINE mr_param_885      RECORD LIKE parametros_885.*
              
#-----------------#
FUNCTION pol1329()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "POL1329-12.00.00  "
   
   CALL func002_versao_prg(p_versao)      
   CALL pol1329_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1329_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_first       VARCHAR(10),
           l_previous    VARCHAR(10),
           l_next        VARCHAR(10),
           l_last        VARCHAR(10),
           l_titulo      VARCHAR(80)
    
    LET l_titulo = "TRANSFERÊNCIA DE SALDOS PARA APARAS - ", p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1329_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1329_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1329_cancelar")

    LET m_sel_tudo = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(m_sel_tudo,"IMAGE","SELALLEX") 
    CALL _ADVPL_set_property(m_sel_tudo,"TOOLTIP","Marcar ou Desmarar todos")
    CALL _ADVPL_set_property(m_sel_tudo,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(m_sel_tudo,"EVENT","pol1329_marca_desmarca")

    LET m_sel_manu = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(m_sel_manu,"IMAGE","SELECAO_MANUAL") 
    CALL _ADVPL_set_property(m_sel_manu,"TOOLTIP","Marcar itens a transferir")
    CALL _ADVPL_set_property(m_sel_manu,"TYPE","CONFIRM")    
    CALL _ADVPL_set_property(m_sel_manu,"EVENT","pol1329_selecionar")
    CALL _ADVPL_set_property(m_sel_manu,"CONFIRM_EVENT","pol1329_sel_conf")
    CALL _ADVPL_set_property(m_sel_manu,"CANCEL_EVENT","pol1329_sel_canc")

    LET m_sel_tudo = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(m_sel_tudo,"IMAGE","TRANSFER_ESTQUE") 
    CALL _ADVPL_set_property(m_sel_tudo,"TOOLTIP","Processar a transferência")
    CALL _ADVPL_set_property(m_sel_tudo,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(m_sel_tudo,"EVENT","pol1329_processar")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1329_monta_cabec(l_panel)
   CALL pol1329_monta_grade(l_panel)
   
   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1329_monta_cabec(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_den_item        VARCHAR(10),
           l_tip_item        VARCHAR(10),
           l_den_fami        VARCHAR(10),
           l_saldo_ate       VARCHAR(10)

    LET m_cabec = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_cabec,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_cabec,"HEIGHT",60)    
    CALL _ADVPL_set_property(m_cabec,"ENABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",20,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Família:") 
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)   

    LET m_familia = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cabec)
    CALL _ADVPL_set_property(m_familia,"POSITION",110,10)     
    CALL _ADVPL_set_property(m_familia,"LENGTH",5) 
    CALL _ADVPL_set_property(m_familia,"VARIABLE",mr_cabec,"cod_familia")
    CALL _ADVPL_set_property(m_familia,"VALID","pol1369_valid_familia") 
    
    LET m_lupa_fami = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_cabec)
    CALL _ADVPL_set_property(m_lupa_fami,"POSITION",170,10)     
    CALL _ADVPL_set_property(m_lupa_fami,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_fami,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_fami,"CLICK_EVENT","pol1369_zoom_fami")
    
    LET l_den_fami = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cabec)
    CALL _ADVPL_set_property(l_den_fami,"POSITION",200,10)     
    CALL _ADVPL_set_property(l_den_fami,"LENGTH",30) 
    CALL _ADVPL_set_property(l_den_fami,"VARIABLE",mr_cabec,"den_familia")
    CALL _ADVPL_set_property(l_den_fami,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_fami,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",480,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Local:")    

    LET m_local = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cabec)
    CALL _ADVPL_set_property(m_local,"POSITION",520,10)     
    CALL _ADVPL_set_property(m_local,"LENGTH",10) 
    CALL _ADVPL_set_property(m_local,"VARIABLE",mr_cabec,"cod_local")

    LET m_local = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cabec)
    CALL _ADVPL_set_property(m_local,"POSITION",620,10)     
    CALL _ADVPL_set_property(m_local,"LENGTH",30) 
    CALL _ADVPL_set_property(m_local,"VARIABLE",mr_cabec,"den_local")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",900,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Saldo até:")    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",20,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Produto:")    

    LET m_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cabec)
    CALL _ADVPL_set_property(m_item,"POSITION",110,40)     
    CALL _ADVPL_set_property(m_item,"LENGTH",15) 
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_cabec,"cod_item")    
    
    LET l_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cabec)
    CALL _ADVPL_set_property(l_den_item,"POSITION",270,40)     
    CALL _ADVPL_set_property(l_den_item,"LENGTH",50) 
    CALL _ADVPL_set_property(l_den_item,"VARIABLE",mr_cabec,"den_item")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",710,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Unid:")    

    LET l_tip_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cabec)
    CALL _ADVPL_set_property(l_tip_item,"POSITION",750,40)     
    CALL _ADVPL_set_property(l_tip_item,"LENGTH",3) 
    CALL _ADVPL_set_property(l_tip_item,"PICTURE","@!") 
    CALL _ADVPL_set_property(l_tip_item,"VARIABLE",mr_cabec,"cod_unid_med")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cabec)
    CALL _ADVPL_set_property(l_label,"POSITION",800,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Tipo:")    

    LET l_tip_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cabec)
    CALL _ADVPL_set_property(l_tip_item,"POSITION",840,40)     
    CALL _ADVPL_set_property(l_tip_item,"LENGTH",2) 
    CALL _ADVPL_set_property(l_tip_item,"PICTURE","@!") 
    CALL _ADVPL_set_property(l_tip_item,"VARIABLE",mr_cabec,"ies_tip_item")

    LET l_saldo_ate = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_cabec)
    CALL _ADVPL_set_property(l_saldo_ate,"POSITION",900,40)     
    CALL _ADVPL_set_property(l_saldo_ate,"LENGTH",12) 
    CALL _ADVPL_set_property(l_saldo_ate,"VARIABLE",mr_cabec,"saldo_ate")


END FUNCTION

#----------------------------------------#
FUNCTION pol1329_monta_grade(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_grade = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_grade,"ALIGN","CENTER")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_grade)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE) 

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item_reduz")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Local")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_local")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","lote")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_lote")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Stat")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_situa_qtd")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_saldo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pedido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CHECKED")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Transf")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_transf")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1329_checa_linha")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CLEAR")
    
END FUNCTION

#-------------------------------#
FUNCTION pol1369_valid_familia()#
#-------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_cabec.cod_familia IS NULL THEN 
      LET m_msg = 'Informe a família'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_familia,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   SELECT den_familia
     INTO mr_cabec.den_familia
     FROM familia
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = mr_cabec.cod_familia

   IF STATUS = 100 THEN
      LET m_msg = 'Familia inexistente'
   ELSE
      IF STATUS = 0 THEN
         RETURN TRUE
      ELSE
         CALL log003_err_sql('SELECT','Familia')
      END IF
   END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   CALL _ADVPL_set_property(m_familia,"GET_FOCUS")
            
   RETURN FALSE

END FUNCTION

#---------------------------#
FUNCTION pol1369_zoom_fami()#
#---------------------------#
    
   DEFINE l_codi        CHAR(15),
          l_desc        CHAR(50),
          l_filtro      CHAR(300)
          
   IF m_zoom_fami IS NULL THEN
      LET m_zoom_fami = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_zoom_fami,"ZOOM","zoom_familia")
   END IF

    LET l_filtro = " familia.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_zoom_fami,"ACTIVATE")

   LET l_codi = _ADVPL_get_property(m_zoom_fami,"RETURN_BY_TABLE_COLUMN","familia","cod_familia")
   LET l_desc = _ADVPL_get_property(m_zoom_fami,"RETURN_BY_TABLE_COLUMN","familia","den_familia")

   IF l_codi IS NOT NULL THEN
      LET mr_cabec.cod_familia = l_codi
      LET mr_cabec.den_familia = l_desc      
   END IF
   
   CALL _ADVPL_set_property(m_familia,"GET_FOCUS")
   
END FUNCTION

#--------------------------#
FUNCTION pol1329_informar()#
#--------------------------#

   CALL pol1329_limpar()
   
   CALL _ADVPL_set_property(m_cabec,"ENABLE",TRUE) 
   CALL _ADVPL_set_property(m_familia,"GET_FOCUS")
      
   RETURN TRUE 
    
END FUNCTION

#------------------------#
FUNCTION pol1329_limpar()#
#------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_itens TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   LET m_ies_info = FALSE
   LET m_qtd_selec = 0
   LET m_qtd_itens = 0

END FUNCTION

#--------------------------#
FUNCTION pol1329_cancelar()#
#--------------------------#

    INITIALIZE mr_cabec.* TO NULL    
    CALL _ADVPL_set_property(m_cabec,"ENABLE",FALSE)
    RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1329_confirmar()#
#---------------------------#

   IF NOT pol1369_valid_familia() THEN
      RETURN FALSE
   END IF
     
   LET m_msg = NULL
   
   IF mr_cabec.saldo_ate IS NULL OR mr_cabec.saldo_ate = 0 THEN
      LET mr_cabec.saldo_ate = 999999999
   END IF
   
   LET p_status = LOG_progresspopup_start("Pesquisando...","pol1329_ler_dados","PROCESS") 
   
   IF NOT p_status THEN
      IF m_msg IS NOT NULL THEN 
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN FALSE
   END IF
   
   LET m_ies_info = TRUE
   CALL _ADVPL_set_property(m_cabec,"ENABLE",FALSE)

   
   RETURN TRUE
    
END FUNCTION
    
    
#---------------------------#
FUNCTION pol1329_ler_dados()#
#---------------------------#
   
   DEFINE l_progres SMALLINT,
          l_select  VARCHAR(300)
      
   LET m_msg = NULL
   
   CALL pol1329_monta_fitro()
   
   LET l_select = 
       " SELECT COUNT(*) ",
       " FROM estoque_lote e, item i, familia f, local l "                                

   LET m_query = l_select CLIPPED, m_where CLIPPED
   
   PREPARE var_count FROM m_query
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("PREPARE","prepare:var_count")
      RETURN FALSE
   END IF   

   DECLARE cq_count CURSOR FOR var_count
   
   OPEN cq_count
      
   FETCH cq_count INTO m_count
   
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql("FETCH","cq_count")
      RETURN FALSE
   END IF
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   IF m_count = 0 THEN
      LET m_msg = 'Argumentos de pesquisa não encontrados.'
      RETURN FALSE
   END IF
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   LET m_ind = 1
   LET m_qtd_itens = 0
   
   LET l_select = 
       " SELECT e.cod_item, i.den_item_reduz, e.cod_local, ",           
       " e.num_lote, e.ies_situa_qtd, e.qtd_saldo ",
       " FROM estoque_lote e, item i, familia f, local l "                             

   LET m_query = l_select CLIPPED, m_where CLIPPED

   LET l_progres = LOG_progresspopup_increment("PROCESS")

   PREPARE var_pesquisa FROM m_query
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("PREPARE","prepare:var_pesquisa")
      RETURN FALSE
   END IF   

   DECLARE cq_cons CURSOR FOR var_pesquisa
   
   FOREACH cq_cons INTO ma_itens[m_ind].*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("FOREACH","cq_cons")
         RETURN FALSE
      END IF
   
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET ma_itens[m_ind].ies_transf = 'N'
      
      LET m_num_lote = ma_itens[m_ind].num_lote
      LET ma_itens[m_ind].pedido = pol1329_le_pedido()

      CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_ind,0,0,0)
         
      LET m_ind = m_ind + 1
      
      IF m_ind > 10000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou 10 mil'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH

   LET m_qtd_itens = m_ind - 1
   
   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_itens)
      
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1329_monta_fitro()#
#-----------------------------#
      
   LET m_where =                                                                             
       " WHERE e.cod_empresa = '",p_cod_empresa,"' ",
       " AND e.cod_item LIKE '","%",mr_cabec.cod_item CLIPPED,"%","' ",   
       " AND e.cod_local LIKE '","%",mr_cabec.cod_local CLIPPED,"%","' ",   
       " AND i.cod_empresa = e.cod_empresa ",                                   
       " AND i.cod_item = e.cod_item ",
       " AND i.den_item LIKE '","%",mr_cabec.den_item CLIPPED,"%","' ",  
       " AND i.cod_unid_med LIKE '","%",mr_cabec.cod_unid_med CLIPPED,"%","' ",  
       " and f.cod_empresa = e.cod_empresa ",
       " and f.cod_familia = i.cod_familia ",
       " and f.cod_familia = '",mr_cabec.cod_familia,"' ",
       " and l.cod_empresa = e.cod_empresa ",
       " and l.cod_local = e.cod_local ",  
       " and l.cod_local LIKE '","%",mr_cabec.cod_local CLIPPED,"%","' ",    
       " and l.den_local LIKE '","%",mr_cabec.den_local CLIPPED,"%","' ",
       " and e.qtd_saldo < ", mr_cabec.saldo_ate 
                                                
END FUNCTION

#---------------------------#
FUNCTION pol1329_le_pedido()#
#---------------------------#

   DEFINE p_carac     CHAR(01),
          p_numpedido CHAR(6),
          p_numseq    CHAR(3),
          p_ind       INTEGER,
          l_retorno   CHAR(15),
          l_pedido    DECIMAL(6,0),
          l_sequenc   DECIMAL(3,0),
          l_situacao  CHAR(01)
          
   LET l_retorno = 'NÃO LOCALIZADO'
   
   IF m_num_lote IS NULL THEN
      RETURN l_retorno
   END IF
             
   INITIALIZE p_numpedido, p_numseq TO NULL

   FOR p_ind = 1 TO LENGTH(m_num_lote)
       LET p_carac = m_num_lote[p_ind]
       IF p_carac = '/' THEN
          EXIT FOR
       END IF
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numpedido = p_numpedido CLIPPED, p_carac
       END IF
   END FOR
   
   FOR p_ind = p_ind + 1 TO LENGTH(m_num_lote)
       LET p_carac = m_num_lote[p_ind]
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numseq = p_numseq CLIPPED, p_carac
       END IF
   END FOR
   
   IF NOT func002_isNumero(p_numpedido) THEN
      RETURN l_retorno
   END IF

   IF NOT func002_isNumero(p_numseq) THEN
      RETURN l_retorno
   END IF
   
   LET l_pedido = p_numpedido
   LET l_sequenc = p_numseq
   
   SELECT 1 FROM pedido_finalizado_885
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = l_pedido
      AND num_sequencia = l_sequenc
       
   IF STATUS = 0 THEN
      RETURN 'FINALIZADO'  
   ELSE
      IF STATUS <> 100 THEN 
         CALL log003_err_sql('SELECT','pedido_finalizado_885')
         RETURN 'ERRO LENDO PEDIDO_FINALIZADO_885'
      END IF
   END IF
   
   SELECT ies_sit_pedido
     INTO l_situacao
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = l_pedido
       
   IF STATUS = 100 THEN
      RETURN l_retorno
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','pedidos')
         RETURN 'ERRO LENDO TAB PEDIDOS'
      END IF
   END IF
   
   IF l_situacao = '9' THEN
      RETURN 'CANCELADO'
   ELSE
      RETURN 'NÃO FINALIZADO'
   END IF
   
END FUNCTION

#--------------------------#
FUNCTION pol1329_ies_info()#
#--------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF NOT m_ies_info THEN
      LET m_msg = 'Informe previamente os parâmetros'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1329_checa_linha()#
#-----------------------------#

   DEFINE l_lin_atu       INTEGER

   IF m_carregando THEN
      RETURN TRUE
   END IF    
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   
   IF ma_itens[l_lin_atu].mensagem = 'Transferido' THEN
      CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","ies_transf",l_lin_atu,"N")
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------------#
FUNCTION pol1329_marca_desmarca()#
#--------------------------------#

   DEFINE l_ind       INTEGER,
          l_sel       CHAR(01)
   
   IF NOT pol1329_ies_info() THEN
      RETURN FALSE
   END IF
      
   IF m_qtd_selec = 0 THEN
      LET l_sel = 'S'
      LET m_qtd_selec = m_qtd_itens
   ELSE
      LET l_sel = 'N'
      LET m_qtd_selec = 0
   END IF
   
   LET m_carregando = TRUE
   
   FOR l_ind = 1 TO m_qtd_itens
       IF ma_itens[l_ind].mensagem = 'Transferido' THEN
          CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","ies_transf",l_ind,"N")
       ELSE
          CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","ies_transf",l_ind,l_sel)
       END IF
   END FOR
   
   LET m_carregando = FALSE
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1329_selecionar()#
#----------------------------#

   DEFINE l_ind       INTEGER,
          l_sel       CHAR(01)
   
   IF NOT pol1329_ies_info() THEN
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_browse,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_browse,"SELECT_ITEM",1,8)
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1329_sel_conf()#
#--------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   LET m_qtd_selec = 0
   
   FOR m_ind = 1 TO m_qtd_itens
       IF ma_itens[m_ind].ies_transf = 'S' THEN
          LET m_qtd_selec = 1
          EXIT FOR
       END IF
   END FOR
       
   IF m_qtd_selec = 0 THEN
      LET m_msg = 'Marque ao menos um iem para transferir saldo'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1329_sel_canc()#
#--------------------------#
   
   LET m_qtd_selec = 1
   
   CALL pol1329_marca_desmarca()
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1329_processar()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF m_qtd_selec = 0 THEN
      LET m_msg = 'Marque previamente os iens a transferir'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   SELECT *
     INTO mr_param_885.*
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','parametros_885')
      RETURN FALSE
   END IF
   
   IF mr_param_885.cod_item_refugo IS NULL THEN
      LET m_msg = 'Item refugo não cadastrado no POL0779'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   LET p_status = LOG_progresspopup_start("Transferindo...","pol1329_transferir","PROCESS") 
   
   IF NOT p_status THEN
      IF m_msg IS NOT NULL THEN 
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN FALSE
   ELSE
      LET m_msg = 'Transferência efetuada com sucesso.'
   END IF
   
   #CALL pol1329_limpar()
   LET m_qtd_selec = 0
   
   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1329_transferir()#
#----------------------------#

   DEFINE l_progres SMALLINT
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   FOR m_ind = 1 TO m_qtd_itens
      IF ma_itens[m_ind].ies_transf = 'S' THEN
         
         LET m_cod_item = ma_itens[m_ind].cod_item
         LET m_cod_local = ma_itens[m_ind].cod_local
         LET m_num_lote = ma_itens[m_ind].num_lote
         LET m_ies_situa = ma_itens[m_ind].ies_situa_qtd
         LET m_qtd_movto = ma_itens[m_ind].qtd_saldo
         
         CALL log085_transacao("BEGIN")
         
         IF NOT pol1329_proc_transf() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
         
         CALL log085_transacao("COMMIT")
         LET ma_itens[m_ind].mensagem = m_msg
         CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","mensagem",m_ind,m_msg)
         LET ma_itens[m_ind].ies_transf = 'N'
         CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","ies_transf",m_ind,"N")
         
         IF m_msg = 'Transferido' THEN
            CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_ind,249,75,32)
         END IF 
         
      END IF
      
      CALL LOG_progresspopup_set_total("PROCESS",m_count)
   END FOR
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1329_proc_transf()#
#-----------------------------#
   
   DEFINE l_cod_unid_item   LIKE item.cod_unid_med
   
   LET m_cod_operacao = mr_param_885.oper_sai_tp_refugo
   LET m_ies_tip_movto = 'N'
   LET m_tip_operacao = 'S'
   LET m_num_docum = m_num_lote
   LET m_msg = NULL
   
   IF m_num_docum IS NULL THEN
      LET m_num_docum = '1'
   END IF   
         
   IF NOT pol1329_le_lote_ender() THEN
      RETURN FALSE
   END IF
   
   IF m_msg IS NOT NULL THEN
      RETURN TRUE
   END IF
   
   IF NOT pol1329_efet_transf() THEN
      RETURN FALSE
   END IF
   
   SELECT cod_unid_med, pes_unit
     INTO l_cod_unid_item, m_pes_unit
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item:pes_unit')
      RETURN FALSE
   END IF
   
   IF l_cod_unid_item <> "KG" THEN
      LET m_qtd_movto = m_qtd_movto * m_pes_unit
   END IF
      
   LET m_cod_operacao = mr_param_885.oper_ent_tp_refugo
   LET m_cod_item = mr_param_885.cod_item_refugo
   LET m_num_lote = mr_param_885.num_lote_refugo
   LET m_ies_situa = 'L'
   LET m_tip_operacao = 'E'
   LET m_comprimento = 0
   LET m_largura     = 0
   LET m_altura      = 0
   LET m_diametro    = 0
   
   SELECT cod_local_estoq
     INTO m_cod_local
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item:refugo')
      RETURN FALSE
   END IF

   IF NOT pol1329_efet_transf() THEN
      RETURN FALSE
   END IF
   
   LET m_msg = 'Transferido'
   
   RETURN TRUE

END FUNCTION    

#-------------------------------#
FUNCTION pol1329_le_lote_ender()#
#-------------------------------#
   
   DEFINE l_qtd_reservada   LIKE estoque_loc_reser.qtd_reservada
   DEFINE lr_est_ender      RECORD LIKE estoque_lote_ender.*
   
   SELECT *
     INTO lr_est_ender.*
     FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item
      AND cod_local = m_cod_local
      AND ies_situa_qtd = m_ies_situa
      AND ((num_lote = m_num_lote AND m_num_lote IS NOT NULL) OR
           (1=1 AND m_num_lote IS NULL))

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_lote_ender')
      RETURN FALSE
   END IF
   
   LET m_comprimento = lr_est_ender.comprimento   
   LET m_largura     = lr_est_ender.largura       
   LET m_altura      = lr_est_ender.altura        
   LET m_diametro    = lr_est_ender.diametro      

   SELECT SUM(qtd_reservada)
     INTO l_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item
      AND cod_local = m_cod_local
      AND ies_situacao = m_ies_situa
      AND ((num_lote = m_num_lote AND m_num_lote IS NOT NULL) OR
           (1=1 AND m_num_lote IS NULL))

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_loc_reser')
      RETURN FALSE
   END IF
         
   IF l_qtd_reservada IS NULL THEN
      LET l_qtd_reservada = 0
   END IF
   
   IF lr_est_ender.qtd_saldo > l_qtd_reservada THEN
      LET lr_est_ender.qtd_saldo = lr_est_ender.qtd_saldo - l_qtd_reservada
   ELSE
      LET lr_est_ender.qtd_saldo = 0
   END IF
   
   IF m_qtd_movto > lr_est_ender.qtd_saldo THEN
      LET m_msg = 'Estoque insufciete p/ tranferir'
   END IF
   
   RETURN TRUE
   
END FUNCTION
   

#-----------------------------#
FUNCTION pol1329_efet_transf()#
#-----------------------------#   
   
   DEFINE lr_item       RECORD                   
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
         ies_ctr_lote  CHAR(01),
         num_conta     CHAR(20),
         cus_unit      DECIMAL(12,2),
         cus_tot       DECIMAL(12,2)
   END RECORD

   LET lr_item.cus_unit      = 0
   LET lr_item.cus_tot       = 0


   LET lr_item.cod_empresa   = p_cod_empresa
   LET lr_item.cod_item      = m_cod_item
   LET lr_item.cod_local     = m_cod_local   
   LET lr_item.num_lote      = m_num_lote
   LET lr_item.comprimento   = m_comprimento 
   LET lr_item.largura       = m_largura     
   LET lr_item.altura        = m_altura      
   LET lr_item.diametro      = m_diametro    
   LET lr_item.cod_operacao  = m_cod_operacao
   LET lr_item.ies_situa     = m_ies_situa
   LET lr_item.qtd_movto     = m_qtd_movto
   LET lr_item.dat_movto     = TODAY
   LET lr_item.ies_tip_movto = m_ies_tip_movto
   LET lr_item.dat_proces    = TODAY
   LET lr_item.hor_operac    = TIME
   LET lr_item.num_prog      = 'POL1329'
   LET lr_item.num_docum     = m_num_docum
   LET lr_item.num_seq       = 0   
   LET lr_item.tip_operacao  = m_tip_operacao
   LET lr_item.usuario       = p_user
   LET lr_item.cod_turno     = NULL
   LET lr_item.trans_origem  = 0
   LET lr_item.ies_ctr_lote  = NULL 
   
   LET p_msg = NULL
   
   IF NOT func005_insere_movto(lr_item) THEN
      LET m_msg = p_msg
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
