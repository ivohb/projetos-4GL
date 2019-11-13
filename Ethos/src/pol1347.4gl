#-------------------------------------------------------------------#
# SISTEMA.: LOGIX      ETHOS METALURGICA                            #
# PROGRAMA: pol1347                                                 #
# OBJETIVO: LIBERAÇÃO DE ORDENS E TRANSFERÊNCIA DE MATERIAL         #
# AUTOR...: IVO                                                     #
# DATA....: 27/04/2018                                              #
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

DEFINE mr_cabec          RECORD
       num_ordem         INTEGER,
       cod_item          CHAR(15),
       den_item          CHAR(30),
       num_docum         CHAR(10),
       qtd_planej        DECIMAL(10,3),
       ies_situa         CHAR(01),
       entrega_de        DATE,
       entrega_ate       DATE
END RECORD

DEFINE ma_ordem          ARRAY[2000] OF RECORD
   ies_sel               CHAR(01),
   num_ordem             INTEGER,
   ies_situa             CHAR(01),
   cod_item              CHAR(15),
   den_item              CHAR(30),
   dat_entrega           DATE,
   qtd_planej            DECIMAL(10,3)
END RECORD

DEFINE ma_compon        ARRAY[500] OF RECORD
   cod_item             CHAR(15),
   den_item             CHAR(30),
   ies_tipo             CHAR(01),
   qtd_necessaria       DECIMAL(10,3),
   qtd_transferida      DECIMAL(10,3),
   qtd_saldo            DECIMAL(10,3),
   qtd_pendente         DECIMAL(10,3),
   ies_transf           CHAR(01),
   num_neces            INTEGER,
   cod_local_baixa      CHAR(10)
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
       m_encerrada       VARCHAR(10),
       m_cancelada       VARCHAR(10),
       m_quantidade      VARCHAR(10),
       m_tempo           VARCHAR(10),
       m_datini          VARCHAR(10),
       m_datfim          VARCHAR(10),
       m_docum           VARCHAR(10)

DEFINE m_transfer        VARCHAR(10),
       m_liber           VARCHAR(10)

DEFINE m_brz_compon      VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_msg             CHAR(150),
       m_ies_situa       CHAR(01),
       m_carregando      SMALLINT,
       m_ordenou         SMALLINT,
       m_query           CHAR(3000),
       m_num_ordem       INTEGER,
       m_num_ordema      INTEGER,
       m_count           INTEGER,
       m_ind             INTEGER,
       m_qtd_ordens      INTEGER,
       m_qtd_compon      INTEGER,
       m_qtd_op_select   INTEGER,
       m_num_op          INTEGER,
       m_ord_prod        INTEGER,
       m_cod_item        CHAR(15),
       m_tip_operacao    CHAR(01),
       m_cod_operac      CHAR(05),
       m_local_estoq     CHAR(10),
       m_local_baixa     CHAR(10),
       m_qtd_transf      DECIMAL(10,3),
       m_index           INTEGER,
       m_ies_transf      SMALLINT,
       m_ies_liber       SMALLINT,
       m_primeiro_clik   SMALLINT,
       m_lin_ant         INTEGER,
       m_lin_atu         INTEGER,
       m_lib_op          SMALLINT
       
#-----------------#
FUNCTION pol1347()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   
   LET p_versao = "pol1347-12.00.11  "
   CALL func002_versao_prg(p_versao)
   CALL pol1347_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1347_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_erro        VARCHAR(10),      
           l_titulo      CHAR(43)

    
    LET l_titulo = "LIBERAÇÃO DE ORDENS E TRANSFERÊNCIA DE MATERIAL"
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1347_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1347_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1347_cancelar")


    LET m_transfer = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(m_transfer,"IMAGE","TRANSFER") 
    CALL _ADVPL_set_property(m_transfer,"TOOLTIP","Transferir material")
    CALL _ADVPL_set_property(m_transfer,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(m_transfer,"EVENT","pol1347_transferir")
    CALL _ADVPL_set_property(m_transfer,"ENABLE",FALSE) 

    LET m_liber = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(m_liber,"IMAGE","LIBERAR  ") 
    CALL _ADVPL_set_property(m_liber,"TOOLTIP","Liberar ordem de produção")
    CALL _ADVPL_set_property(m_liber,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(m_liber,"EVENT","pol1347_liberar")
    CALL _ADVPL_set_property(m_liber,"ENABLE",FALSE) 

    {LET l_erro = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_erro,"IMAGE","RUN_ERR") 
    CALL _ADVPL_set_property(l_erro,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(l_erro,"TOOLTIP","Exibe erros de estorno")
    CALL _ADVPL_set_property(l_erro,"EVENT","pol1347_exibe_erros")}    

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1347_cria_campos(l_panel)
   LET m_carregando = TRUE
   CALL pol1347_cria_grade_ordem(l_panel)
   CALL pol1347_cria_grade_compon(l_panel)
   
   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1347_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_den_item        VARCHAR(10),
           l_planejada       VARCHAR(10),
           l_saldo           VARCHAR(10),
           l_status          VARCHAR(10),
           l_panel           VARCHAR(10)

    CALL pol1347_limpa_campos()
    
    LET m_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_panel,"HEIGHT",70)
    CALL _ADVPL_set_property(m_panel,"EDITABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Número da OP:")    

    LET m_ordem = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_ordem,"POSITION",110,10)     
    CALL _ADVPL_set_property(m_ordem,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_ordem,"PICTURE","@E #########")
    CALL _ADVPL_set_property(m_ordem,"VARIABLE",mr_cabec,"num_ordem")
    CALL _ADVPL_set_property(m_ordem,"VALID","pol1347_valid_ordem")

    LET m_lupa_op = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_op,"POSITION",200,10)     
    CALL _ADVPL_set_property(m_lupa_op,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_op,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_op,"CLICK_EVENT","pol1347_zoom_ordem")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",230,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Produto:")    

    LET m_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(m_item,"POSITION",280,10)     
    CALL _ADVPL_set_property(m_item,"LENGTH",15) 
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_cabec,"cod_item")
    CALL _ADVPL_set_property(m_item,"VALID","pol1347_valid_item")
    
    LET m_lupa_it = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_it,"POSITION",410,10)     
    CALL _ADVPL_set_property(m_lupa_it,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_it,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_it,"CLICK_EVENT","pol1347_zoom_item")

    LET l_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_item,"POSITION",440,10)     
    CALL _ADVPL_set_property(l_den_item,"LENGTH",30) 
    CALL _ADVPL_set_property(l_den_item,"VARIABLE",mr_cabec,"den_item")
    CALL _ADVPL_set_property(l_den_item,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",720,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Docum:")    

    LET m_docum = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(m_docum,"POSITION",770,10)     
    CALL _ADVPL_set_property(m_docum,"LENGTH",10) 
    CALL _ADVPL_set_property(m_docum,"VARIABLE",mr_cabec,"num_docum")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",880,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Entrega:")
    
    LET m_datini = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel)
    CALL _ADVPL_set_property(m_datini,"POSITION",930,10)     
    CALL _ADVPL_set_property(m_datini,"VARIABLE",mr_cabec,"entrega_de")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1050,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Até:")
    
    LET m_datfim = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel)
    CALL _ADVPL_set_property(m_datfim,"POSITION",1080,10)     
    CALL _ADVPL_set_property(m_datfim,"VARIABLE",mr_cabec,"entrega_ate")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",600,50)     
    CALL _ADVPL_set_property(l_label,"TEXT","Possibilidade de transferência:")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_panel)
    CALL _ADVPL_set_property(l_panel,"SIZE",10,10)
    CALL _ADVPL_set_property(l_panel,"POSITION",790,50)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",0,128,0) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",810,50)     
    CALL _ADVPL_set_property(l_label,"TEXT","Total")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_panel)
    CALL _ADVPL_set_property(l_panel,"SIZE",10,10)
    CALL _ADVPL_set_property(l_panel,"POSITION",860,50)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",128,0,255) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",880,50)     
    CALL _ADVPL_set_property(l_label,"TEXT","Parcial")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_panel)
    CALL _ADVPL_set_property(l_panel,"SIZE",10,10)
    CALL _ADVPL_set_property(l_panel,"POSITION",940,50)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",255,128,128) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",960,50)     
    CALL _ADVPL_set_property(l_label,"TEXT","Nenhuma")

    
END FUNCTION

#-----------------------------#
FUNCTION pol1347_valid_ordem()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_cabec.num_ordem IS NULL THEN
      CALL pol1347_ativa_desativa(TRUE)
      RETURN TRUE
   END IF
   
   SELECT cod_item,
          ies_situa,
          qtd_planej
     INTO mr_cabec.cod_item,
          mr_cabec.ies_situa,
          mr_cabec.qtd_planej
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = mr_cabec.num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens')
      RETURN FALSE
   END IF
   
   IF mr_cabec.ies_situa MATCHES "[3]" THEN
   ELSE
      LET m_msg = 'Status da OP inválido - ',mr_cabec.ies_situa
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT 1 FROM op_local_547
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = mr_cabec.num_ordem

   IF STATUS = 100 THEN
      LET m_msg = 'Ordem ainda não foi processada pelo POL1346.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordens')
         RETURN FALSE
      END IF
   END IF
   
   LET mr_cabec.den_item = func002_le_den_item(mr_cabec.cod_item) 
   
   CALL pol1347_ativa_desativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1347_zoom_ordem()#
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
      LET mr_cabec.num_ordem = l_ordem
   END IF
   
   CALL _ADVPL_set_property(m_ordem,"GET_FOCUS")
   
END FUNCTION

#----------------------------#
FUNCTION pol1347_valid_item()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_cabec.cod_item IS NULL THEN
      RETURN TRUE
   END IF
   
   LET mr_cabec.den_item = func002_le_den_item(mr_cabec.cod_item) 
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1347_zoom_item()#
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


#---------------------------------------#
FUNCTION pol1347_ativa_desativa(l_status)#
#---------------------------------------#

   DEFINE l_status SMALLINT

   CALL _ADVPL_set_property(m_item,"EDITABLE",l_status) 
   CALL _ADVPL_set_property(m_lupa_it,"EDITABLE",l_status)       
   CALL _ADVPL_set_property(m_docum,"EDITABLE",l_status) 
   CALL _ADVPL_set_property(m_datini,"EDITABLE",l_status)       
   CALL _ADVPL_set_property(m_datfim,"EDITABLE",l_status)       
   
END FUNCTION

#-----------------------------#
FUNCTION pol1347_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_ordem TO NULL
   INITIALIZE ma_compon TO NULL

END FUNCTION

#--------------------------#
FUNCTION pol1347_informar()#
#--------------------------#
      
   CALL pol1347_limpa_campos()
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   CALL _ADVPL_set_property(m_brz_compon,"CLEAR")
   CALL _ADVPL_set_property(m_panel,"EDITABLE",TRUE) 
   LET m_ies_info = FALSE

   CALL _ADVPL_set_property(m_ordem,"GET_FOCUS")

   CALL _ADVPL_set_property(m_liber,"ENABLE",FALSE) 
   CALL _ADVPL_set_property(m_transfer,"ENABLE",FALSE) 
      
   RETURN TRUE 
    
END FUNCTION

#--------------------------#
FUNCTION pol1347_cancelar()#
#--------------------------#

   CALL pol1347_limpa_campos()
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   CALL _ADVPL_set_property(m_brz_compon,"CLEAR")
   CALL _ADVPL_set_property(m_panel,"EDITABLE",FALSE) 
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1347_confirmar()#
#---------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   IF mr_cabec.entrega_de IS NOT NULL AND mr_cabec.entrega_ate IS NOT NULL THEN
      IF mr_cabec.entrega_de > mr_cabec.entrega_ate THEN
         LET m_msg = 'Periodo inválido.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   END IF
   
   LET m_msg = NULL
   LET m_carregando = TRUE
   LET m_primeiro_clik = TRUE
   
   IF NOT pol1347_le_ordens() THEN
      IF m_msg IS NOT NULL THEN 
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN FALSE
   END IF
   
   CALL pol1347_ativa_desativa(FALSE)
   LET m_ies_info = TRUE
   LET m_carregando = FALSE
   CALL _ADVPL_set_property(m_panel,"EDITABLE",FALSE)
   
   RETURN TRUE
    
END FUNCTION

#---------------------------------------------#
FUNCTION pol1347_cria_grade_ordem(l_container)#
#---------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
    #CALL _ADVPL_set_property(l_panel,"WIDTH",280)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_browse,"BEFORE_ROW_EVENT","pol1347_before_row")
    CALL _ADVPL_set_property(m_browse,"BEFORE_ORDER_EVENT","pol1347_before_order")      
    CALL _ADVPL_set_property(m_browse,"AFTER_ORDER_EVENT","pol1347_after_order")      

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CONFIRM_EX")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sel")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_sel")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","St")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",15)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_situa")

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
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qt planej")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_planej")
    #CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ##,###,###.###")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_ordem,1)
    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)


END FUNCTION

#---------------------------------------------#
FUNCTION pol1347_cria_grade_compon(l_container)#
#---------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(l_panel,"WIDTH",280)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_compon = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_compon,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_compon)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Componente")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    #CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_compon)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    #CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_compon)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tp")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_tipo")
    #CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_compon)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Necessidade")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_necessaria")
    #CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ##,###,###.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_compon)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Transferida")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_transferida")
    #CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ##,###,###.###")    

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_compon)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Em estoque")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_saldo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_compon)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pendência")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_pendente")
    #CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ##,###,###.###")    

    CALL _ADVPL_set_property(m_brz_compon,"SET_ROWS",ma_compon,1)
    CALL _ADVPL_set_property(m_brz_compon,"CAN_ADD_ROW",FALSE)


END FUNCTION

#----------------------------#
FUNCTION pol1347_before_row()#
#----------------------------#
   
   IF m_carregando THEN
      RETURN TRUE
   END IF

   IF m_ordenou THEN
      LET m_ordenou = FALSE
      RETURN TRUE
   END IF
   
   LET m_lin_ant = m_lin_atu
   LET m_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
      
   LET m_ies_situa = ma_ordem[m_lin_atu].ies_situa
   LET p_status = pol1347_le_compon(ma_ordem[m_lin_atu].num_ordem)

   if m_lin_ant > 0 then
      LET ma_ordem[m_lin_ant].ies_sel = 'N'
      CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","ies_sel",m_lin_ant,"N")
   end if
   
   LET ma_ordem[m_lin_atu].ies_sel = 'S'
   CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","ies_sel",m_lin_atu,"S")
   
   RETURN p_status

END FUNCTION   

#------------------------------#
FUNCTION pol1347_before_order()#
#------------------------------#

   LET m_carregando = TRUE
   LET m_ord_prod = ma_ordem[m_lin_atu].num_ordem

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1347_after_order()#
#-----------------------------#
   
   DEFINE l_ind      INTEGER
   
   FOR l_ind = 1 TO m_qtd_ordens
      IF m_ord_prod = ma_ordem[l_ind].num_ordem THEN
         LET m_lin_atu = l_ind
         EXIT FOR
      END IF
   END FOR

   LET m_ies_situa = ma_ordem[m_lin_atu].ies_situa
   LET m_ordenou = TRUE
   LET m_carregando = FALSE   
   
   CALL _ADVPL_set_property(m_browse,"SELECT_ITEM",m_lin_atu,1)
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1347_monta_select()#
#------------------------------#

   LET m_query = 
      "SELECT 'N', num_ordem, ies_situa, cod_item, dat_entrega, qtd_planej ",
      " FROM ordens WHERE cod_empresa = '",p_cod_empresa,"' ",
      " AND ies_situa = '3' ",
      " AND num_ordem IN (SELECT x.num_ordem FROM op_local_547 x ",
      " WHERE x.cod_empresa = '",p_cod_empresa,"') "      
   
   IF mr_cabec.num_ordem IS NOT NULL THEN 
      LET m_query = m_query CLIPPED, " AND num_ordem = ", mr_cabec.num_ordem
   ELSE
      IF mr_cabec.cod_item IS NOT NULL THEN 
         LET m_query = m_query CLIPPED, " AND cod_item = '",mr_cabec.cod_item,"' "
      END IF
      IF mr_cabec.num_docum IS NOT NULL THEN 
         LET m_query = m_query CLIPPED, " AND num_docum = '",mr_cabec.num_docum,"' "
      END IF
      IF mr_cabec.entrega_de IS NOT NULL THEN 
         LET m_query = m_query CLIPPED, " AND dat_entrega >= '",mr_cabec.entrega_de,"' "
      END IF   
      IF mr_cabec.entrega_ate IS NOT NULL THEN 
         LET m_query = m_query CLIPPED, " AND dat_entrega <= '",mr_cabec.entrega_ate,"' "
      END IF   
   END IF
            
END FUNCTION

#---------------------------#
FUNCTION pol1347_le_ordens()#
#---------------------------#

   DEFINE l_ind       SMALLINT
   
   INITIALIZE ma_ordem, ma_compon TO NULL
   LET l_ind = 1
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   CALL _ADVPL_set_property(m_brz_compon,"CLEAR")
   CALL pol1347_monta_select()
   
   PREPARE var_pesquisa FROM m_query
    
   IF  Status <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","var_pesquisa")
       RETURN FALSE
   END IF

   DECLARE cq_ordens CURSOR FOR var_pesquisa

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE CURSOR","cq_ordens")
       RETURN FALSE
   END IF

   FREE var_pesquisa

   FOREACH cq_ordens INTO
      ma_ordem[l_ind].ies_sel,
      ma_ordem[l_ind].num_ordem,
      ma_ordem[l_ind].ies_situa,
      ma_ordem[l_ind].cod_item,
      ma_ordem[l_ind].dat_entrega,
      ma_ordem[l_ind].qtd_planej

      IF  Status <> 0 THEN
          CALL log003_err_sql("FOREACH","CURSOR:cq_ordens")
          RETURN FALSE
      END IF
            
      LET ma_ordem[l_ind].den_item = func002_le_den_item(ma_ordem[l_ind].cod_item)
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 2000 THEN
         LET m_msg = 'Quntidade de ordens ultrapassou capacidade da grade.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   FREE cq_ordens
   
   LET m_qtd_ordens = l_ind - 1

   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_ordens)
         
   IF m_qtd_ordens >= 1 THEN
      LET m_ies_situa = ma_ordem[1].ies_situa
      LET p_status = pol1347_le_compon(ma_ordem[1].num_ordem)
      CALL _ADVPL_set_property(m_browse,"SELECT_ITEM",1,1)
      LET m_lin_atu = 1
      LET ma_ordem[m_lin_atu].ies_sel = 'S'
   ELSE 
      LET m_msg = 'Não há dados para os parâmetros informados.'
      LET p_status = FALSE
   END IF
   
   RETURN p_status

END FUNCTION

#-----------------------------------#
FUNCTION pol1347_le_compon(l_num_op)#
#-----------------------------------#
   DEFINE l_num_op        INTEGER
   
   LET m_num_op = l_num_op
   
   SELECT COUNT(*) INTO m_count
     FROM necessidades
    WHERE cod_empresa = p_cod_empresa 
      AND num_ordem = l_num_op
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','necessidades.count')
      RETURN FALSE
   END IF
   
   IF m_count > 12 THEN  
      LET p_status = LOG_progresspopup_start("Carregando...","pol1347_carrega_compon","PROCESS") 
   ELSE
      LET p_status = pol1347_carrega_compon()
   END IF

   RETURN p_status

END FUNCTION

#--------------------------------#
FUNCTION pol1347_carrega_compon()#
#--------------------------------#

   DEFINE l_progres         SMALLINT

   DEFINE l_num_op        INTEGER,
          l_ind           INTEGER,
          l_qtd_saldo     DECIMAL(10,3),
          l_local_estoq   CHAR(10),
          l_qtd_pedenc    DECIMAL(10,3)

   DEFINE l_parametro      RECORD
          cod_empresa      CHAR(02),
          cod_item         CHAR(15),
          cod_local        CHAR(10)
   END RECORD
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   INITIALIZE ma_compon TO NULL
   LET l_num_op = m_num_op
   LET l_ind = 1
   CALL _ADVPL_set_property(m_brz_compon,"CLEAR")
   
   LET m_ies_transf = FALSE
   LET m_ies_liber = TRUE
      
   LET l_ind = 1
   
   DECLARE cq_neces CURSOR FOR
    SELECT o.cod_item_compon, o.cod_local_baixa, 
           o.ies_tip_item, SUM(n.qtd_necessaria)
      FROM necessidades n, ord_compon o, item i
     WHERE n.cod_empresa = p_cod_empresa 
       AND n.num_ordem = l_num_op
       AND n.cod_empresa = o.cod_empresa
       AND n.num_neces = o.cod_item_pai
       AND n.num_ordem = o.num_ordem
       AND o.ies_tip_item NOT IN ('P','F')
       AND o.cod_empresa = i.cod_empresa 
       AND o.cod_item_compon = i.cod_item
       AND o.cod_local_baixa <> i.cod_local_estoq
     GROUP BY o.cod_item_compon, o.cod_local_baixa, o.ies_tip_item
     ORDER BY o.ies_tip_item
     
   FOREACH cq_neces INTO 
      ma_compon[l_ind].cod_item,
      ma_compon[l_ind].cod_local_baixa,
      ma_compon[l_ind].ies_tipo,
      ma_compon[l_ind].qtd_necessaria
      
      IF STATUS <> 0 THEN
          CALL log003_err_sql("FOREACH","CURSOR:cq_neces")
          RETURN FALSE
      END IF

      SELECT cod_local_estoq
        INTO l_local_estoq
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_compon[l_ind].cod_item

      IF STATUS <> 0 THEN
          CALL log003_err_sql("SELECT","item.local")
          RETURN FALSE
      END IF

      LET ma_compon[l_ind].den_item = func002_le_den_item(ma_compon[l_ind].cod_item)
      LET l_parametro.cod_empresa = p_cod_empresa
      LET l_parametro.cod_item = ma_compon[l_ind].cod_item
      LET l_parametro.cod_local = l_local_estoq
      CALL func002_le_estoque(l_parametro) RETURNING m_msg, l_qtd_saldo
      
      IF m_msg IS NOT NULL THEN
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF

      LET ma_compon[l_ind].qtd_saldo = l_qtd_saldo
      
      LET l_parametro.cod_local = ma_compon[l_ind].cod_local_baixa                                    
      CALL func002_le_estoque(l_parametro) RETURNING m_msg, l_qtd_saldo            
                                                                                   
      IF m_msg IS NOT NULL THEN                                                    
         CALL log0030_mensagem(m_msg,'info')                                       
         RETURN FALSE                                                              
      END IF                                                                       
                                                                                   
      LET ma_compon[l_ind].qtd_transferida = l_qtd_saldo                           
      
      IF ma_compon[l_ind].qtd_transferida >= ma_compon[l_ind].qtd_necessaria THEN
         CONTINUE FOREACH
      END IF
      
      IF ma_compon[l_ind].qtd_saldo > 0 THEN
         LET ma_compon[l_ind].ies_transf = 'S'  
         LET m_ies_transf = TRUE
      ELSE
         LET ma_compon[l_ind].ies_transf = 'N' 
      END IF

      LET l_qtd_pedenc = ma_compon[l_ind].qtd_necessaria - ma_compon[l_ind].qtd_transferida
      
      IF l_qtd_pedenc > ma_compon[l_ind].qtd_saldo THEN
         LET l_qtd_pedenc = l_qtd_pedenc - ma_compon[l_ind].qtd_saldo 
         LET m_ies_liber = FALSE
         IF ma_compon[l_ind].qtd_saldo > 0 THEN
            CALL _ADVPL_set_property(m_brz_compon,"LINE_FONT_COLOR",l_ind,128,0,255)
         ELSE
            CALL _ADVPL_set_property(m_brz_compon,"LINE_FONT_COLOR",l_ind,255,128,128)
         END IF
      ELSE
         LET l_qtd_pedenc = 0
         CALL _ADVPL_set_property(m_brz_compon,"LINE_FONT_COLOR",l_ind,0,128,0)
      END IF
      
      LET ma_compon[l_ind].qtd_pendente = l_qtd_pedenc
             
      LET l_ind = l_ind + 1
      
      IF l_ind > 500 THEN
         LET m_msg = 'Quntidade de componetes ultrapassou capacidade da grade.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
      IF m_count > 12 THEN
         LET l_progres = LOG_progresspopup_increment("PROCESS")
      END IF
      
   END FOREACH
   
   FREE cq_neces
   
   LET m_qtd_compon = l_ind - 1
   
   CALL _ADVPL_set_property(m_brz_compon,"ITEM_COUNT", m_qtd_compon)
   
   CALL _ADVPL_set_property(m_transfer,"ENABLE",m_ies_transf) 
   CALL _ADVPL_set_property(m_liber,"ENABLE",m_ies_liber) 
   
   IF m_qtd_compon > 0 THEN
      CALL _ADVPL_set_property(m_liber,"ENABLE",FALSE) 
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1347_ies_info()#
#--------------------------#
   
   DEFINE l_ies_sel     SMALLINT
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   IF NOT m_ies_info THEN
      LET m_msg = 'Informe previamente os parâmetros'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET l_ies_sel = FALSE
   
   FOR m_ind = 1 TO m_qtd_ordens
      IF ma_ordem[m_ind].ies_sel = 'S' THEN
         LET l_ies_sel = TRUE
         EXIT FOR
      END IF
   END FOR
   
   IF NOT l_ies_sel THEN
      LET m_msg = 'Selecione pelo menos uma ordem de produção'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION


#----------------------------#
FUNCTION pol1347_transferir()#
#----------------------------#
   
   DEFINE l_linha    integer
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
      
   #IF NOT pol1347_ies_info() THEN
   IF NOT m_ies_info THEN
      LET m_msg = 'Informe os parâmetros previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET l_linha = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   
   IF ma_ordem[l_linha].ies_sel = 'S' THEN
   ELSE
      LET m_msg = 'Nenhuma ordem foi selecionada'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      

   IF NOT LOG_question("Confirma a TRANSFERÊNCIA do material ?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF
   
   LET m_num_ordem = ma_ordem[l_linha].num_ordem
   LET m_ies_situa = ma_ordem[l_linha].ies_situa
   
   LET p_status = LOG_progresspopup_start("Transferindo...","pol1347_proc_trans","PROCESS") 

   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   IF m_lib_op THEN
      LET p_status = pol1347_le_compon(m_num_ordem)
      IF m_qtd_compon <= 0 THEN
         LET p_status = pol1347_lib_op(l_linha)
      END IF            
   ELSE
      LET p_status = pol1347_le_compon(m_num_ordem)
   END IF           
   
   RETURN TRUE
    
END FUNCTION

#----------------------------#
FUNCTION pol1347_proc_trans()#
#----------------------------#

   CALL log085_transacao("BEGIN")
          
   IF NOT pol1347_trans_mat() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
      
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1347_trans_mat()#
#---------------------------#

   DEFINE l_progres         SMALLINT

   CALL LOG_progresspopup_set_total("PROCESS",m_qtd_compon)          
   LET m_lib_op = TRUE
   
   FOR m_index = 1 TO m_qtd_compon
       #IF ma_compon[m_index].ies_transf = 'S' THEN
          IF NOT pol1347_exec_transf() THEN
             RETURN FALSE
          END IF
       #END IF       
       LET l_progres = LOG_progresspopup_increment("PROCESS")   
   END FOR
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1347_exec_transf()#
#-----------------------------#

   DEFINE l_num_op        INTEGER,
          l_ind           INTEGER,
          l_qtd_estoq     DECIMAL(10,3),
          l_transferida   DECIMAL(10,3),
          l_qtd_neces     DECIMAL(10,3),
          l_ctr_estoque   CHAR(01)

   DEFINE l_parametro      RECORD
          cod_empresa      CHAR(02),
          cod_item         CHAR(15),
          cod_local        CHAR(10)
   END RECORD

   LET l_parametro.cod_empresa = p_cod_empresa
   LET l_parametro.cod_item = ma_compon[m_index].cod_item
   LET m_cod_item = l_parametro.cod_item
   
   SELECT cod_local_estoq,
          ies_ctr_estoque
     INTO m_local_estoq,
          l_ctr_estoque
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_parametro.cod_item

   IF STATUS <> 0 THEN
       CALL log003_err_sql("SELECT","item.local_estoq")
       RETURN FALSE
   END IF
   
   IF l_ctr_estoque = 'N' THEN
      RETURN TRUE
   END IF
   
   LET l_parametro.cod_local = m_local_estoq
   CALL func002_le_estoque(l_parametro) RETURNING m_msg, l_qtd_estoq
      
   IF m_msg IS NOT NULL THEN
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   LET l_qtd_neces = ma_compon[m_index].qtd_necessaria
   LET m_local_baixa = ma_compon[m_index].cod_local_baixa
   
   LET l_parametro.cod_local = m_local_baixa
   CALL func002_le_estoque(l_parametro) RETURNING m_msg, l_transferida
 
   IF m_msg IS NOT NULL THEN
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   IF l_qtd_estoq <= 0 THEN
      IF l_transferida < l_qtd_neces THEN
         LET m_lib_op = FALSE
      END IF
      RETURN TRUE
   END IF

   IF l_transferida >= l_qtd_neces THEN
      RETURN TRUE
   END IF
   
   LET m_qtd_transf = l_qtd_neces - l_transferida
   
   IF m_qtd_transf > l_qtd_estoq THEN
      LET m_qtd_transf = l_qtd_estoq
      LET m_lib_op = FALSE
   END IF
   
   SELECT cod_estoque_ac INTO m_cod_operac
     FROM par_pcp 
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
       CALL log003_err_sql("SELECT","par_pcp.cod_estoque_ac")
       RETURN FALSE
   END IF

   IF NOT pol1347_movto_estoque() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#-------------------------------#
FUNCTION pol1347_movto_estoque()#
#-------------------------------#   
   
   DEFINE l_item       RECORD                   
       cod_empresa   LIKE item.cod_empresa,
       num_docum     LIKE estoque_trans.num_docum,
       cod_item      LIKE item.cod_item,
       cod_loc_orig  LIKE item.cod_local_estoq,
       cod_loc_dest  LIKE item.cod_local_estoq,
       num_lote      LIKE estoque_lote.num_lote,
       ies_situa_qtd LIKE estoque_lote.ies_situa_qtd,
       qtd_transf    LIKE estoque_lote.qtd_saldo,
       comprimento   LIKE estoque_lote_ender.comprimento,
       largura       LIKE estoque_lote_ender.largura,
       altura        LIKE estoque_lote_ender.altura,
       diametro      LIKE estoque_lote_ender.diametro,
       num_programa  CHAR(08),
       cod_operacao  CHAR(04)
   END RECORD
             
   LET l_item.cod_empresa   = p_cod_empresa
   LET l_item.num_docum     = m_num_op
   LET l_item.cod_item      = m_cod_item
   LET l_item.cod_loc_orig  = m_local_estoq
   LET l_item.cod_loc_dest  = m_local_baixa
   LET l_item.num_lote      = NULL  
   LET l_item.ies_situa_qtd = 'L'
   LET l_item.qtd_transf    = m_qtd_transf
   LET l_item.comprimento   = 0
   LET l_item.largura       = 0  
   LET l_item.altura        = 0    
   LET l_item.diametro      = 0 
   LET l_item.num_programa  = 'POL1347'
   LET l_item.cod_operacao  = m_cod_operac  
     
   IF NOT func014_transf_local(l_item) THEN
      CALL log0030_mensagem(g_msg,'info')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1347_liberar()#
#-------------------------#
   
   DEFINE l_linha    integer
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
      
   IF NOT m_ies_info THEN
      LET m_msg = 'Informe os parâmetros previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET l_linha = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   
   IF ma_ordem[l_linha].ies_sel = 'S' THEN
   ELSE
      LET m_msg = 'Nenhuma ordem foi selecionada'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
   
   IF m_qtd_compon > 0 THEN
      LET m_msg = 'Ordem ainda precisa de transferências.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      

   IF NOT LOG_question("Confirma a LIBERAÇÃO da OP ?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1347_lib_op(l_linha) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
    
END FUNCTION

#-------------------------------#
FUNCTION pol1347_lib_op(l_linha)#
#-------------------------------#

   DEFINE l_linha    integer

   LET m_num_ordem = ma_ordem[l_linha].num_ordem
      
   LET p_status = LOG_progresspopup_start("Processando...","pol1347_proc_liber","PROCESS") 

   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   #CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","ies_situa",l_linha,"4")
   
   CALL _ADVPL_set_property(m_browse,"REMOVE_ROW",l_linha)
   CALL _ADVPL_set_property(m_liber,"ENABLE",FALSE) 
   CALL _ADVPL_set_property(m_transfer,"ENABLE",FALSE) 
   
   LET m_msg = 'A OP ', m_num_ordem USING '<<<<<<<<<', ' foi liberada.'
      
   CALL log0030_mensagem(m_msg, 'info')
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1347_proc_liber()#
#----------------------------#

   CALL log085_transacao("BEGIN")
          
   IF NOT pol1347_libera_op() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
      
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1347_libera_op()#
#---------------------------#

   DEFINE l_progres         SMALLINT,
          l_dat_atu         DATE,
          l_dat_txt         CHAR(19)

   CALL LOG_progresspopup_set_total("PROCESS",2)          
   LET l_progres = LOG_progresspopup_increment("PROCESS") 
   LET l_dat_atu = TODAY
   LET l_dat_txt = EXTEND(CURRENT, YEAR TO SECOND)
   
   UPDATE ordens 
      SET ies_situa = '4',
      dat_atualiz = l_dat_atu
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ordens')
      RETURN FALSE
   END IF         
   
   LET l_progres = LOG_progresspopup_increment("PROCESS") 
   
   UPDATE necessidades SET ies_situa = '4'
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','necessidades')
      RETURN FALSE
   END IF         
   
   INSERT INTO op_liber_pol1347(
    cod_empresa, num_ordem, dat_proces, cod_usuario)
    VALUES(p_cod_empresa, m_num_ordem, l_dat_txt, p_user)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','op_liber_pol1347')
      RETURN FALSE
   END IF         
       
   RETURN TRUE

END FUNCTION   


   