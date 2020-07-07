#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1322                                                 #
# OBJETIVO: Apontamento de consumo                                  #
# AUTOR...: IVO                                                     #
# DATA....: 25/05/17                                                #
#-------------------------------------------------------------------#
# 30/10/2017 - Alterado para fazer a abixa do papel a partir do     #
#              boletim de produção da onduladeira                   #
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
           g_qtd_saldo     DECIMAL(10,3),
           p_msg           CHAR(150),
           p_num_trans_atual    INTEGER
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_lupa_it         VARCHAR(10),
       m_zoom_it         VARCHAR(10),
       m_brz_mat         VARCHAR(10),
       m_brz_op          VARCHAR(10),
       m_unidade         VARCHAR(10),
       m_boletim         VARCHAR(10),
       m_producao        VARCHAR(10),
       m_item            VARCHAR(10),
       m_baixar          VARCHAR(10),
       m_construct       VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_ies_cons        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_cod_item        CHAR(15),
       m_cod_material    CHAR(15),
       m_cod_baixar      CHAR(15),
       m_ies_relac       CHAR(01),
       m_data_cons       CHAR(20),
       m_erro            SMALLINT,
       m_ind             INTEGER,
       m_num_ordem       INTEGER,
       m_qtd_compon      INTEGER,
       m_promove         SMALLINT,
       m_lin_op          INTEGER,
       m_troca_cor       SMALLINT,
       m_qtd_baixar      DECIMAL(10,3),
       m_pct_ajuste      DECIMAL(5,2),
       m_qtd_neces       DECIMAL(17,7),
       m_pct_rateio      DECIMAL(17,7),
       m_dif_arredond    DECIMAL(10,3),
       m_qtd_linha       INTEGER,
       m_linha_op        INTEGER,
       m_num_sequencia   INTEGER,
       m_chav_acesso     DECIMAL(14,0),
       m_chav_acessoa    DECIMAL(14,0),
       m_num_versao      INTEGER,
       m_critica         SMALLINT,
       m_qtd_consumo     DECIMAL(10,3),
       m_qtd_saldo       DECIMAL(10,3),
       m_proces_ok       SMALLINT,
       m_ies_sofre_baixa CHAR(01),
       m_op_chapa        INTEGER,
       m_item_of         CHAR(15),
       m_processado      SMALLINT,
       m_num_transac     INTEGER,
       m_houve_erro      SMALLINT,
       m_bole_imp        INTEGER,
       m_dat_consumo     DATE
       

DEFINE mr_cabec          RECORD
       num_boletim       DECIMAL(14,0),
       dat_producao      DATE,
       cod_composicao    CHAR(15),
       den_item          CHAR(70),       
       cod_unid_med      CHAR(03),
       status            CHAR(10)
END RECORD

DEFINE ma_material     ARRAY[30] OF RECORD
       cod_material    CHAR(15),
       den_item        CHAR(76),
       qtd_consumo     DECIMAL(10,3),
       qtd_estoque     DECIMAL(10,3),
       cod_unid_med    CHAR(03),
       cod_baixar      CHAR(15),
       qtd_baixar      DECIMAL(10,3),
       pct_ajuste      DECIMAL(5,2),
 	     mensagem        CHAR(100)       
END RECORD

DEFINE ma_boletim     ARRAY[3000] OF RECORD
       chav_acesso      DECIMAL(14,0), 
       num_boletim      INTEGER,           
       dat_producao     DATE,
       cod_composicao   CHAR(15),
       cod_material     CHAR(15),
       qtd_consumo      DECIMAL(10,3), 
       cod_baixar       CHAR(15),
       qtd_baixar       DECIMAL(10,3) 
END RECORD
                   
DEFINE m_dat_fecha_ult_man   LIKE par_estoque.dat_fecha_ult_man,    
       m_dat_fecha_ult_sup   LIKE par_estoque.dat_fecha_ult_sup,
       m_cod_local_baixa     LIKE item.cod_local_estoq,
       m_num_docum           LIKE ordens.num_docum 

DEFINE m_cod_produto      VARCHAR(10),
       m_den_produto      VARCHAR(10),
       m_zoom_produto     VARCHAR(10),
       m_lupa_produto     VARCHAR(10),
       m_tela_prod        VARCHAR(10),
       m_stat_prod        VARCHAR(10),
       m_qtd_produto      VARCHAR(10),
       m_consumo          VARCHAR(10)

DEFINE mr_produto         RECORD
       cod_produto        CHAR(15),
       den_produto        CHAR(50),
       qtd_produto        DECIMAL(10,3),
       qtd_estoque        DECIMAL(10,3),
       dat_consumo        DATE
END RECORD

DEFINE m_cod_operacao   CHAR(01),
       m_cod_status     CHAR(01)

DEFINE mr_relat         RECORD
       chav_acesso      DECIMAL(14,0), 
       num_boletim      INTEGER,           
       dat_producao     DATE,
       cod_composicao   CHAR(15),
       cod_material     CHAR(15),
       qtd_consumo      DECIMAL(10,3), 
       cod_baixar       CHAR(15),
       qtd_baixar       DECIMAL(10,3) 
END RECORD
              
#-----------------#
FUNCTION pol1322()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1322-12.00.03  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1322_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1322_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_proces      VARCHAR(10),
           l_estorno     VARCHAR(10),
           l_inform      VARCHAR(10),
           l_baixar      VARCHAR(10),
           l_create      VARCHAR(10),
           l_update      VARCHAR(10),
           l_find        VARCHAR(10),
           l_first       VARCHAR(10),
           l_previous    VARCHAR(10),
           l_next        VARCHAR(10),
           l_last        VARCHAR(10),
           l_relat       VARCHAR(10),
           l_titulo      CHAR(43)
    
    LET l_titulo = "APONTAMENTO DE CONSUMO - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1322_informar")
    CALL _ADVPL_set_property(l_inform,"TOOLTIP","Informar boletim para baixa")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1322_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1322_cancelar")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1322_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1322_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1322_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1322_last")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"TOOLTIP","Adicionar material a baixar")
    CALL _ADVPL_set_property(l_create,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_create,"EVENT","pol1322_create")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"TOOLTIP","Modificar material a baixar")
    CALL _ADVPL_set_property(l_update,"EVENT","pol1322_modifica")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1322_mod_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1322_mod_cancel")

    LET l_baixar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_baixar,"IMAGE","BAIXAR_EX")     
    CALL _ADVPL_set_property(l_baixar,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_baixar,"TOOLTIP","Processar a baixa do material")
    CALL _ADVPL_set_property(l_baixar,"EVENT","pol1322_baixar")

    LET l_estorno = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_estorno,"IMAGE","ESTORNO_EX")     
    CALL _ADVPL_set_property(l_estorno,"TOOLTIP","Estorna a baixa do material")
    CALL _ADVPL_set_property(l_estorno,"TYPE","N_CONFIRM")     
    CALL _ADVPL_set_property(l_estorno,"EVENT","pol1322_estornar")     

    LET l_relat = _ADVPL_create_component(NULL,"LPRINTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_relat,"EVENT","pol1322_relatorio")
    CALL _ADVPL_set_property(l_relat,"TOOLTIP","Impressão de Boletins")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1322_cria_campos(l_panel)
   CALL pol1322_grade_mat(l_panel)
   
   CALL pol1322_ativa_desativa(FALSE)
   CALL pol1322_limpa_campos()

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1322_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_cod_item        VARCHAR(10),
           l_den_item        VARCHAR(10),
           l_unidade         VARCHAR(10),
           l_status          VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP") 
    CALL _ADVPL_set_property(l_panel,"HEIGHT",80)
    #CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)
    #CALL _ADVPL_set_property(l_panel,"WIDTH",400)
    #CALL _ADVPL_set_property(l_panel,"BOUNDS",10,10,600,160)
    #CALL _ADVPL_set_property(l_panel,"FOREGROUND_COLOR",255,0,0)
    #CALL _ADVPL_set_property(l_panel,"FONT","Courier New",18,FALSE,FALSE)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",13)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Boletim:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_boletim = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_boletim,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_boletim,"LENGTH",14,0)
    CALL _ADVPL_set_property(m_boletim,"PICTURE","@E ##############")
    CALL _ADVPL_set_property(m_boletim,"VARIABLE",mr_cabec,"num_boletim")
    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    #CALL _ADVPL_set_property(l_label,"POSITION",50,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Produção:")
    
    LET m_producao = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    #CALL _ADVPL_set_property(m_producao,"POSITION",150,40)     
    CALL _ADVPL_set_property(m_producao,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_producao,"VARIABLE",mr_cabec,"dat_producao")
    CALL _ADVPL_set_property(m_producao,"CAN_GOT_FOCUS",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Composição:")    

    LET m_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_item,"LENGTH",15) 
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_cabec,"cod_composicao")

    LET l_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_item,"LENGTH",50) 
    CALL _ADVPL_set_property(l_den_item,"VARIABLE",mr_cabec,"den_item")

    LET l_unidade = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_unidade,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_unidade,"LENGTH",4) 
    CALL _ADVPL_set_property(l_unidade,"VARIABLE",mr_cabec,"cod_unid_med")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Status:")    

    LET l_status = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_status,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_status,"LENGTH",10) 
    CALL _ADVPL_set_property(l_status,"VARIABLE",mr_cabec,"status")

END FUNCTION

#--------------------------------------#
FUNCTION pol1322_grade_mat(l_container)#
#--------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    #CALL _ADVPL_set_property(l_layout,"MIN_SIZE",650,100)
   
    LET m_brz_mat = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_mat,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(m_brz_mat,"BEFORE_ROW_EVENT","pol1322_exib_comp")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Código")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",130)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_material")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E!")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descricão")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",250)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Unid")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_unid_med")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd consumida")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_consumo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ##,###,###.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd estoque")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_estoque")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ##,###,###.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cód baixar")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",130)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_baixar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E!")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1322_valida_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1322_zoom_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd Baixar")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_baixar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ##,###,###.###")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1322_valida_qtd")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pct ajuste")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",55)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pct_ajuste")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ###.##")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E!")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_brz_mat,"SET_ROWS",ma_material,1)
    CALL _ADVPL_set_property(m_brz_mat,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_mat,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_mat,"EDITABLE",FALSE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1322_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
    
   CALL _ADVPL_set_property(m_boletim,"EDITABLE",l_status)
   #CALL _ADVPL_set_property(m_producao,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_item,"EDITABLE",l_status)

END FUNCTION

#-----------------------------#
FUNCTION pol1322_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_material TO NULL
   
END FUNCTION

#--------------------------#
FUNCTION pol1322_informar()#
#--------------------------#
   
   DEFINE l_data    DATE
   
   LET m_ies_cons = FALSE
      
   CALL pol1322_ativa_desativa(TRUE)
   CALL pol1322_limpa_campos()
   CALL _ADVPL_set_property(m_boletim,"GET_FOCUS")
      
   RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1322_le_parametros()#
#-------------------------------#
      
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

#---------------------------#
FUNCTION pol1322_confirmar()#
#---------------------------#
         
   IF NOT pol1322_pesquisa() THEN
      RETURN FALSE
   END IF

   CALL pol1322_ativa_desativa(FALSE)
   
   LET m_ies_cons = TRUE
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1322_pesquisa()#
#--------------------------#
   
   DEFINE l_sql_stmt     CHAR(2000)
   
   LET l_sql_stmt = 
      "SELECT MAX(chav_acesso) FROM boletim_ond_885 WHERE 1=1 "
   
   IF mr_cabec.num_boletim IS NOT NULL THEN 
      LET l_sql_stmt = l_sql_stmt CLIPPED, " AND num_boletim = ", mr_cabec.num_boletim
   END IF

   IF mr_cabec.dat_producao IS NOT NULL THEN 
      LET l_sql_stmt = l_sql_stmt CLIPPED, " AND dat_producao = '",mr_cabec.dat_producao,"' "
   END IF

   IF mr_cabec.cod_composicao IS NOT NULL THEN 
      LET l_sql_stmt = l_sql_stmt CLIPPED, " AND cod_composicao = '",mr_cabec.cod_composicao,"' "
   END IF
            
   PREPARE var_pesquisa FROM l_sql_stmt
    
   IF  Status <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","var_pesquisa")
       RETURN FALSE
   END IF

   DECLARE cq_cons SCROLL CURSOR WITH HOLD FOR var_pesquisa

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE CURSOR","cq_cons")
       RETURN FALSE
   END IF

   FREE var_pesquisa

   OPEN cq_cons

   IF  STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_cons")
       RETURN FALSE
   END IF

   INITIALIZE ma_boletim TO NULL
   
   LET m_msg = NULL
   
   FETCH cq_cons INTO m_chav_acesso

   IF STATUS <> 0 THEN
      IF STATUS <> 100 THEN
         CALL log003_err_sql("FETCH CURSOR","cq_cons")
      ELSE
         LET m_msg = 'Não a dados, para os argumentos informados.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
       RETURN FALSE
   END IF

    IF NOT pol1322_exibe_dados() THEN
       LET m_msg = 'Operação cancelada'
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN FALSE
    END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   RETURN TRUE
          
END FUNCTION

#-----------------------------#
FUNCTION pol1322_exibe_dados()#
#-----------------------------#

   IF NOT pol1322_dados_compl() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1322_le_consumo() THEN
     RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1322_cancelar()#
#--------------------------#

    CALL pol1322_limpa_campos()
    CALL pol1322_ativa_desativa(FALSE)
    LET m_ies_cons = FALSE
    RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1322_first()#
#-----------------------#

   IF NOT pol1322_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1322_next()#
#----------------------#

   IF NOT pol1322_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1322_previous()#
#--------------------------#

   IF NOT pol1322_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1322_last()#
#----------------------#

   IF NOT pol1322_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
FUNCTION pol1322_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1322_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_chav_acessoa = m_chav_acesso

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_chav_acesso
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_chav_acesso
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_chav_acesso
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_chav_acesso
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_chav_acesso = m_chav_acessoa
         EXIT WHILE
      ELSE
         SELECT COUNT(*)
           INTO m_count
           FROM boletim_ond_885
          WHERE chav_acesso = m_chav_acesso
         IF m_count > 0 THEN
            CALL pol1322_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      END IF               
   
   END WHILE
   
   RETURN l_achou
   
END FUNCTION

#--------------------------#
FUNCTION pol1322_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa. Faça uma pesquisa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1322_dados_compl()#
#-----------------------------#

   SELECT DISTINCT 
          num_boletim,
          cod_operacao,
          status_registro,
          cod_composicao,
          status_registro
     INTO mr_cabec.num_boletim,
          m_cod_operacao,
          m_cod_status,
          mr_cabec.cod_composicao,
          mr_cabec.status
     FROM boletim_ond_885
    WHERE chav_acesso = m_chav_acesso

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','boletim_ond_885:leitura')
      RETURN FALSE
   END IF   
   
   SELECT den_item,
          cod_unid_med
     INTO mr_cabec.den_item,
          mr_cabec.cod_unid_med
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_cabec.cod_composicao

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF   
   
   IF mr_cabec.status = '1' THEN
      LET mr_cabec.status = 'PROCESSADO'
      LET m_processado = TRUE
   ELSE
      LET mr_cabec.status = 'EM ABRTO'
      LET m_processado = FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#----------------------------#
FUNCTION pol1322_le_consumo()#
#----------------------------#
   
   INITIALIZE ma_material TO NULL
   CALL _ADVPL_set_property(m_brz_mat,"CLEAR")
   CALL _ADVPL_set_property(m_brz_mat,"SET_ROWS",ma_material,1)

   LET m_critica = FALSE
   LET m_ind =  1
   LET m_msg = ''
      
   DECLARE cq_mat CURSOR FOR
    SELECT cod_material,
           SUM(qtd_consumo)
      FROM boletim_ond_885
     WHERE chav_acesso = m_chav_acesso
     GROUP BY cod_material

   FOREACH cq_mat INTO 
      ma_material[m_ind].cod_material,
      ma_material[m_ind].qtd_consumo
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','boletim_ond_885:cq_mat')
         RETURN FALSE
      END IF
      
      IF ma_material[m_ind].cod_material IS NULL THEN
         LET m_msg = 'Esse boletim contém papel \n a abixar com código nulo.'
         CALL log0030_mensagem(m_msg, 'info')
         RETURN FALSE
      END IF
      
      IF ma_material[m_ind].qtd_consumo IS NULL OR 
         ma_material[m_ind].qtd_consumo = 0 THEN
         LET m_msg = 'Esse boletim contém papel a abixar \n com quantidade zero ou nula.'
         CALL log0030_mensagem(m_msg, 'info')
         RETURN FALSE
      END IF
      
      LET ma_material[m_ind].cod_baixar = ma_material[m_ind].cod_material
      LET ma_material[m_ind].qtd_baixar = ma_material[m_ind].qtd_consumo
      LET m_cod_item = ma_material[m_ind].cod_material
      
      SELECT den_item,
             cod_unid_med,
             cod_local_estoq
        INTO ma_material[m_ind].den_item,
             ma_material[m_ind].cod_unid_med,
             m_cod_local_baixa
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = m_cod_item
         
      IF STATUS <> 0 AND STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','item')
         RETURN FALSE
      END IF
      
      IF STATUS = 100 THEN
         LET m_msg = 
              'O material ', m_cod_item CLIPPED, ' não existe no Logix\n'
         LET ma_material[m_ind].mensagem = m_msg
         LET m_critica = TRUE
      ELSE
         IF NOT pol1322_le_manufatura(m_cod_item) THEN
            RETURN FALSE
         END IF
         
         IF m_ies_sofre_baixa = 'S' THEN
            LET m_msg = 
              'O material ', m_cod_item CLIPPED, ' deve ser baixado no apto. de produção\n'
            LET ma_material[m_ind].mensagem = m_msg
            LET m_critica = TRUE
         END IF
         
         CALL pol1322_le_estoque()
         LET ma_material[m_ind].qtd_estoque = m_qtd_saldo
         IF m_qtd_saldo < ma_material[m_ind].qtd_baixar THEN
            CALL _ADVPL_set_property(m_brz_mat,"LINE_FONT_COLOR",m_ind,197,16,26)
         ELSE
            CALL _ADVPL_set_property(m_brz_mat,"LINE_FONT_COLOR",m_ind,0,0,0)
         END IF
      END IF
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 30 THEN
         CALL log0030_mensagem('Limite de linha da grade de consumo ultrapassou.')
         EXIT FOREACH
      END IF      
   
   END FOREACH
   
   LET m_qtd_linha = m_ind - 1
   
   CALL _ADVPL_set_property(m_brz_mat,"SET_ROWS",ma_material,m_qtd_linha)
      
   IF m_critica THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION

#------------------------------------#
FUNCTION pol1322_le_manufatura(l_cod)#
#------------------------------------#

   DEFINE l_cod           CHAR(15)
   
   SELECT ies_sofre_baixa
     INTO m_ies_sofre_baixa
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item_man')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION         

#----------------------------#
FUNCTION pol1322_le_estoque()#
#----------------------------#

   DEFINE l_qtd_reservada   DECIMAL(10,3)
          
   SELECT SUM(qtd_saldo)
     INTO m_qtd_saldo
     FROM estoque_lote_ender
    WHERE cod_empresa   = p_cod_empresa
	    AND cod_item      = m_cod_item
	    AND cod_local     = m_cod_local_baixa
      AND ies_situa_qtd = 'L'
      AND comprimento = 0
      AND largura     = 0
      AND altura      = 0
      AND diametro    = 0
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_lote_ender')
      LET m_qtd_saldo = 0
      RETURN
   END IF  

   IF m_qtd_saldo IS NULL THEN
      LET m_qtd_saldo = 0
      RETURN 
   END IF

   SELECT SUM(qtd_reservada)
     INTO l_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = m_cod_item
      AND cod_local   = m_cod_local_baixa
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_loc_reser')
      LET m_qtd_saldo = 0
      RETURN
   END IF  
               
   IF l_qtd_reservada IS NULL OR l_qtd_reservada < 0 THEN
      LET l_qtd_reservada = 0
   END IF
   
   LET m_qtd_saldo = m_qtd_saldo - l_qtd_reservada
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1322_modifica()#
#--------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,'CLEAR_TEXT')   
   
   IF NOT m_ies_cons THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe previamente o Boletim.")
      RETURN FALSE
   END IF

   IF m_processado THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação não permitida, para boletim processado.")
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_brz_mat,"EDITABLE",TRUE)  
   CALL _ADVPL_set_property(m_brz_mat,"GET_FOCUS")    
   CALL _ADVPL_set_property(m_brz_mat,"SELECT_ITEM",1,6)
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1322_mod_confirm()#
#-----------------------------#

   #IF NOT pol1322_salva_edicao() THEN
   #   RETURN FALSE
   #END IF
   
   CALL _ADVPL_set_property(m_brz_mat,"EDITABLE",FALSE)  
   
   RETURN TRUE

END FUNCTION
   
#----------------------------#
FUNCTION pol1322_mod_cancel()#
#----------------------------#
   
   CALL pol1322_reflesh()
   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol1322_reflesh()#
#-------------------------#

   IF NOT pol1322_le_consumo() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   CALL _ADVPL_set_property(m_brz_mat,"EDITABLE",FALSE) 
   CALL _ADVPL_set_property(m_brz_mat,"CAN_ADD_ROW",FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1322_zoom_item()#
#---------------------------#

    DEFINE l_cod_item       LIKE item.cod_item,
           l_den_item       LIKE item.den_item,
           l_cod_ant        LIKE item.cod_item,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_it IS NULL THEN
       LET m_zoom_it = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_it,"ZOOM","zoom_item")
    END IF

    LET l_where_clause = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_it,"ACTIVATE")
    
    LET l_cod_item = _ADVPL_get_property(m_zoom_it,"RETURN_BY_TABLE_COLUMN","item","cod_item")
    #LET l_den_item = _ADVPL_get_property(m_zoom_it,"RETURN_BY_TABLE_COLUMN","item","den_item")

    IF l_cod_item IS NOT NULL THEN
       LET l_lin_atu = _ADVPL_get_property(m_brz_mat,"ROW_SELECTED")
       LET l_cod_ant = ma_material[l_lin_atu].cod_baixar
       LET ma_material[l_lin_atu].cod_baixar = l_cod_item
       IF pol1322_valida_item() THEN
          CALL _ADVPL_set_property(m_brz_mat,"SELECT_ITEM",l_lin_atu,8)
       ELSE
          LET ma_material[l_lin_atu].cod_baixar = l_cod_ant
       END IF
    END IF        
    
END FUNCTION

#----------------------------#
FUNCTION pol1322_valida_item()
#----------------------------#
    
    DEFINE l_lin_atu SMALLINT

    CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")

    LET l_lin_atu = _ADVPL_get_property(m_brz_mat,"ROW_SELECTED")

    IF ma_material[l_lin_atu].cod_baixar IS NULL THEN
       LET m_msg = 'Informe o código a ser baixado.'
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN FALSE
    END IF   
    
    LET m_cod_item = ma_material[l_lin_atu].cod_baixar
    
    SELECT cod_local_estoq
      INTO m_cod_local_baixa
      FROM item
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = m_cod_item

    IF STATUS <> 0 AND STATUS <> 100 THEN
        CALL log003_err_sql("SELECT","log_grupos")
        RETURN FALSE
    END IF
    
    IF STATUS = 100 THEN
       LET m_msg = 'Item não cadastrado no Logix.'
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN FALSE
    END IF   

    IF NOT pol1322_le_manufatura(m_cod_item) THEN
       RETURN FALSE
    END IF
         
    IF m_ies_sofre_baixa = 'S' THEN
       LET m_msg = 'Esse item deve ser baixado no apto. de produção\n'
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN FALSE
    END IF
        
    CALL pol1322_le_estoque()

    IF ma_material[l_lin_atu].cod_baixar <> ma_material[l_lin_atu].cod_material THEN
       LET m_msg = 'Estoque disponíel: ', m_qtd_saldo USING '<<<<<<<<<<.<<<'
       LET ma_material[l_lin_atu].mensagem = m_msg
    ELSE
       LET ma_material[l_lin_atu].mensagem = NULL
    END IF

    IF m_qtd_saldo < ma_material[l_lin_atu].qtd_baixar THEN
       CALL _ADVPL_set_property(m_brz_mat,"LINE_FONT_COLOR",l_lin_atu,197,16,26)
    ELSE
       CALL _ADVPL_set_property(m_brz_mat,"LINE_FONT_COLOR",l_lin_atu,0,0,0)
    END IF
    
    RETURN TRUE
    
END FUNCTION


#----------------------------#
FUNCTION pol1322_valida_qtd()#
#----------------------------#

   DEFINE l_lin_atu     SMALLINT,
          l_qtd_consumo DECIMAL(10,3)

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")

   LET l_lin_atu = _ADVPL_get_property(m_brz_mat,"ROW_SELECTED")

   IF ma_material[l_lin_atu].qtd_baixar IS NULL OR
        ma_material[l_lin_atu].qtd_baixar <= 0 THEN
      LET m_msg = 'Quantidae a baixar inválida.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF   
   
   IF ma_material[l_lin_atu].qtd_baixar = ma_material[l_lin_atu].qtd_consumo THEN
      LET ma_material[l_lin_atu].pct_ajuste = NULL
   ELSE
      LET l_qtd_consumo = ma_material[l_lin_atu].qtd_consumo
      LET ma_material[l_lin_atu].pct_ajuste = 
       (ma_material[l_lin_atu].qtd_baixar - l_qtd_consumo) / l_qtd_consumo * 100
   END IF
   
   LET m_cod_item = ma_material[l_lin_atu].cod_baixar
   CALL pol1322_le_estoque()

   IF m_qtd_saldo < ma_material[l_lin_atu].qtd_baixar THEN
      CALL _ADVPL_set_property(m_brz_mat,"LINE_FONT_COLOR",l_lin_atu,197,16,26)
   ELSE
      CALL _ADVPL_set_property(m_brz_mat,"LINE_FONT_COLOR",l_lin_atu,0,0,0)
   END IF
      
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1322_baixar()#
#------------------------#

   CALL _ADVPL_set_property(m_statusbar,'CLEAR_TEXT')   
   
   IF m_ies_cons THEN
      IF m_processado THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
                "Operação não permitida, para boletim processado.")
         RETURN FALSE
      END IF   
   ELSE
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe previamente o Boletim.")
      RETURN FALSE
   END IF
      
   LET m_msg = 'Deseja mesmo efetuar a baixa do material ?'
   
   IF NOT LOG_question(m_msg) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN TRUE
   END IF

   IF NOT pol1322_le_parametros() THEN
      RETURN FALSE
   END IF
      
   CALL LOG_transaction_begin()
   
   IF NOT pol1322_proces_baixa() THEN
      CALL LOG_transaction_rollback()
   ELSE
      CALL LOG_transaction_commit()   
      CALL pol1322_reflesh()
      LET mr_cabec.status = 'PROCESSADO'
      LET m_processado = TRUE
      LET m_msg = 'Baixa do material \n efetuada com sucesso.'
      CALL log0030_mensagem(m_msg,'info')
   END IF
      
   RETURN TRUE         
   
END FUNCTION

#-----------------------------#
FUNCTION pol1322_checa_saldo()#
#-----------------------------#
   
   LET m_msg = ''
   
   DECLARE cq_sdo CURSOR FOR
    SELECT cod_baixar,
           SUM(qtd_baixar)
      FROM boletim_ond_885
     WHERE chav_acesso = m_chav_acesso
     GROUP BY cod_baixar
   FOREACH cq_sdo INTO m_cod_item, m_qtd_baixar

       IF STATUS <> 0 THEN
          CALL log003_err_sql('FOREACH','boletim_ond_885:cq_sdo')
          RETURN FALSE
       END IF
             
       SELECT cod_local_estoq
         INTO m_cod_local_baixa
         FROM Item
        WHERE cod_empresa = p_cod_empresa
          AND cod_item = m_cod_item
       
       IF STATUS <> 0 THEN
          CALL log003_err_sql('SELECT','item')
          RETURN FALSE
       END IF
       
       CALL pol1322_le_estoque()
       
       IF m_qtd_saldo < m_qtd_baixar THEN
          LET m_msg = m_msg, '- Material: ',m_cod_item CLIPPED, 
                             ' Saldo: ', m_qtd_saldo USING '<<<<<<<<.<<'
          LET m_msg = m_msg, ' Neces: ', m_qtd_baixar USING '<<<<<<<<.<<','\n'
       END IF
       
   END FOREACH
   
   IF m_msg IS NOT NULL THEN
      CALL log0030_mensagem(m_msg,'info')   
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1322_proces_baixa()#
#------------------------------#

   IF NOT pol1322_salva_edicao() THEN
      RETURN FALSE
   END IF

   IF NOT pol1322_checa_saldo() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1322_troca_of() THEN
      RETURN FALSE
   END IF
   
   LET m_proces_ok = FALSE
   CALL LOG_progresspopup_start("Processando...","pol1322_baixa_material","PROCESS")   
   
   RETURN m_proces_ok

END FUNCTION

#------------------------------#
FUNCTION pol1322_salva_edicao()#
#------------------------------#
      
   FOR m_ind =  1 TO m_qtd_linha
       LET m_cod_material = ma_material[m_ind].cod_material
       LET m_cod_baixar = ma_material[m_ind].cod_baixar
       LET m_pct_ajuste = ma_material[m_ind].pct_ajuste
       IF m_pct_ajuste IS NULL THEN
          LET m_pct_ajuste = 0
       END IF
       IF NOT pol1322_atu_boletim() THEN
          RETURN FALSE
       END IF
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1322_atu_boletim()#
#-----------------------------#

   DECLARE cq_atu_bole CURSOR FOR
    SELECT num_sequencia, qtd_consumo 
      FROM boletim_ond_885
     WHERE chav_acesso = m_chav_acesso 
       AND cod_material = m_cod_material

   FOREACH cq_atu_bole INTO
      m_num_sequencia,
      m_qtd_consumo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_atu_bole')
         RETURN FALSE
      END IF
      
      IF m_pct_ajuste <> 0 THEN
         LET m_qtd_consumo = m_qtd_consumo + (m_qtd_consumo * m_pct_ajuste / 100)
      END IF
      
      UPDATE boletim_ond_885
         SET cod_baixar = m_cod_baixar,
             qtd_baixar = m_qtd_consumo
       WHERE chav_acesso = m_chav_acesso 
         AND num_sequencia = m_num_sequencia

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','boletim_ond_885')
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1322_troca_of()#
#--------------------------#

   DECLARE cq_troca CURSOR FOR
    SELECT DISTINCT num_of
      FROM boletim_ond_885
     WHERE chav_acesso = m_chav_acesso

   FOREACH cq_troca INTO m_num_ordem
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_troca')
         RETURN FALSE
      END IF

      SELECT cod_item,
             num_docum
        INTO m_item_of,
             m_num_docum
        FROM ordens
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem = m_num_ordem

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordens:cq_troca')
         RETURN FALSE
      END IF
   
      LET m_op_chapa = 0
      
      IF NOT pol1322_le_op_chapa() THEN
         RETURN FALSE
      END IF
      
      IF m_op_chapa = 0 THEN
         LET m_msg = 'Não foi possivel localizar a OF\n',
                     'da chapa do produto ', m_item_of CLIPPED
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
      
      UPDATE boletim_ond_885
         SET num_of_chapa = m_op_chapa
       WHERE chav_acesso = m_chav_acesso
         AND num_of = m_num_ordem

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','boletim_ond_885:cq_troca')
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1322_le_op_chapa()#
#-----------------------------#

   DEFINE l_op_chapa     LIKE ordens.num_ordem,
          l_it_chapa     LIKE ordens.cod_item,
          l_num_docum    LIKE ordens.num_docum,
          l_cod_item     LIKE ordens.cod_item
         
   DECLARE cq_chapa CURSOR FOR
    SELECT num_ordem,
           cod_item
      FROM ordens
     WHERE cod_empresa = p_cod_empresa
       AND num_docum = m_num_docum
       AND cod_item_pai = m_item_of
   
   FOREACH cq_chapa INTO 
          l_op_chapa,
          l_it_chapa
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_chapa')
         RETURN FALSE
      END IF  
      
      IF NOT pol1322_le_item_vdp(l_op_chapa, l_it_chapa) THEN
         RETURN FALSE
      END IF
            
      IF m_op_chapa > 0 THEN
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#---------------------------------------------------#
FUNCTION pol1322_le_item_vdp(l_op_chapa, l_it_chapa)#
#---------------------------------------------------#
   
   DEFINE l_op_chapa       LIKE ordens.num_ordem,
          l_it_chapa       LIKE item.cod_item,
          l_cod_grupo_item LIKE item_vdp.cod_grupo_item,
          l_cod_tipo       LIKE grupo_produto_885.cod_tipo
   
	  SELECT cod_grupo_item
	    INTO l_cod_grupo_item
	    FROM item_vdp
	   WHERE cod_empresa = p_cod_empresa
	     AND cod_item    = l_it_chapa

   IF STATUS = 100 THEN
      RETURN TRUE
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item_vdp')
      RETURN FALSE
   END IF

   SELECT cod_tipo
     INTO l_cod_tipo
     FROM grupo_produto_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_grupo   = l_cod_grupo_item

   IF STATUS = 100 THEN
      RETURN TRUE
   END IF
	  
	 IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','grupo_produto_885')
      RETURN FALSE
   END IF

   IF l_cod_tipo = '2' THEN
      LET m_op_chapa = l_op_chapa
   END IF	 
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1322_baixa_material()#
#--------------------------------#

   DEFINE l_progres     SMALLINT,
          l_tot_rateio  DECIMAL(10,3)

   SELECT COUNT(*)
     INTO m_count
     FROM boletim_ond_885
    WHERE chav_acesso = m_chav_acesso

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','boletim_ond_885:COUNT')
      RETURN 
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Não há dados a baixar na tabela boletim_ond_885'
      CALL log0030_mensagem(m_msg,'info')
      RETURN
   END IF      
       
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DECLARE cq_proces CURSOR FOR
   SELECT num_of_chapa,
          cod_baixar,
          qtd_baixar,
          num_sequencia,
          dat_producao
     FROM boletim_ond_885
    WHERE chav_acesso = m_chav_acesso
   
   FOREACH cq_proces INTO 
      m_num_ordem, m_cod_item, m_qtd_baixar, m_num_sequencia, m_dat_consumo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','boletim_ond_885:cq_proces')
         RETURN 
      END IF
   
      LET l_progres = LOG_progresspopup_increment("PROCESS")

      IF NOT pol1322_exec_baixa() THEN
         RETURN
      END IF
      
      IF NOT pol1322_grav_alternat() THEN
         RETURN
      END IF
         
   END FOREACH
      
   LET m_proces_ok = TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1322_exec_baixa()#
#------------------------------#

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
         ies_ctr_lote  CHAR(01),
         num_conta     CHAR(20),
         cus_unit      DECIMAL(12,2),
         cus_tot       DECIMAL(12,2)
   END RECORD
      
   SELECT cod_local_estoq,
          ies_ctr_lote
     INTO p_item.cod_local,
          p_item.ies_ctr_lote
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
      
   LET p_item.cod_empresa   = p_cod_empresa
   LET p_item.cod_item      = m_cod_item
   LET p_item.num_lote      = NULL
   LET p_item.comprimento   = 0
   LET p_item.largura       = 0    
   LET p_item.altura        = 0     
   LET p_item.diametro      = 0  

   SELECT cod_estoque_sp
     INTO p_item.cod_operacao
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','par_pcp')
      RETURN FALSE
   END IF
    
   LET p_item.ies_situa     = 'L'
   LET p_item.qtd_movto     = m_qtd_baixar
   LET p_item.dat_movto     = m_dat_consumo
   LET p_item.ies_tip_movto = 'N'
   LET p_item.dat_proces    = TODAY
   LET p_item.hor_operac    = TIME
   LET p_item.num_prog      = 'POL1322'
   LET p_item.num_docum     = m_num_ordem
   LET p_item.num_seq       = NULL
   
   LET p_item.tip_operacao  = 'S' 
   
   LET p_item.usuario       = p_user
   LET p_item.cod_turno     = NULL
   LET p_item.trans_origem  = 0

   SELECT cus_unit_medio 
     INTO p_item.cus_unit
     FROM item_custo  
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      LET p_item.cus_unit = 0
   END IF
   
   LET p_item.cus_tot = p_item.cus_unit * p_item.qtd_movto
   
   IF NOT func005_insere_movto(p_item) THEN
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   IF NOT pol1322_baixa_neces('B') THEN
      RETURN FALSE
   END IF

   IF NOT pol1322_grava_bolet('1') THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1322_baixa_neces(l_op)#
#---------------------------------#
   
   DEFINE l_count     INTEGER,
          l_qtd_baixa DECIMAL(17,7),
          l_op        CHAR(01)
   
   SELECT COUNT(cod_item)
     INTO l_count
     FROM necessidades
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem
      AND cod_item =  m_cod_item
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','necessidades')
      RETURN FALSE
   END IF
   
   IF l_count = 0 THEN
      RETURN TRUE
   END IF
   
   LET l_qtd_baixa = m_qtd_baixar / l_count
   
   IF l_op = 'E' THEN
      LET l_qtd_baixa = l_qtd_baixa * (-1)
   END IF
   
   UPDATE necessidades
      SET qtd_saida = qtd_saida + l_qtd_baixa
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem
      AND cod_item =  m_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','necessidades')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1322_grava_bolet(l_status)#
#-------------------------------------#
   
   DEFINE l_status   CHAR(01)
   
   UPDATE boletim_ond_885
      SET status_registro = l_status,
          num_transac = p_num_trans_atual
    WHERE chav_acesso = m_chav_acesso
      AND num_sequencia = m_num_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','boletim_ond_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-------------------------------#
FUNCTION pol1322_grav_alternat()#
#-------------------------------#
   
   DEFINE l_cod_compon   LIKE ord_compon.cod_item_compon,
          l_qtd_neces    LIKE ord_compon.qtd_necessaria,
          l_cod_pai      LIKE ord_compon.cod_item_compon
             
   SELECT COUNT(*)
     INTO m_count
     FROM ord_compon
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem
      AND cod_item_compon = m_cod_item
     
   IF STATUS <> 0 THEN                                                              
      CALL log003_err_sql('SELECT','ord_compon:COUNT')      
      RETURN FALSE                                                                  
   END IF                                                                           
   
   IF m_count > 0 THEN
      RETURN TRUE
   END IF
   
   SELECT cod_item
     INTO l_cod_pai
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem
     
   IF STATUS <> 0 THEN                                                              
      CALL log003_err_sql('SELECT','ordens:ga')      
      RETURN FALSE                                                                  
   END IF                                                                           

   DECLARE cq_compon CURSOR FOR
    SELECT a.cod_item_compon,
           SUM(a.qtd_necessaria)
     FROM ord_compon a, item b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.num_ordem = m_num_ordem
      AND b.cod_empresa = a.cod_empresa
      AND b.cod_item = a.cod_item_compon
      AND b.cod_familia = '001'
    GROUP BY a.cod_item_compon

   FOREACH cq_compon INTO l_cod_compon, l_qtd_neces   
   
      IF STATUS <> 0 THEN                                                              
         CALL log003_err_sql('FOREACH','ord_compon:cq_compon')      
         RETURN FALSE                                                                  
      END IF                                                                           
   
      SELECT COUNT(*)
        INTO m_count
        FROM item_altern
       WHERE cod_empresa = p_cod_empresa
         AND cod_item_pai = l_cod_pai
         AND cod_item_compon = l_cod_compon
         AND cod_item_altern = m_cod_item
      
      IF STATUS <> 0 THEN                                                              
         CALL log003_err_sql('SELECT','item_altern:COUNT')      
         RETURN FALSE                                                                  
      END IF                                                                           

      IF m_count > 0 THEN
         CONTINUE FOREACH
      END IF

      INSERT INTO item_altern(                                                            
         cod_empresa,                                                                     
         cod_item_pai,                                                                    
         cod_item_compon,                                                                 
         cod_item_altern,                                                                 
         qtd_necessaria,                                                                  
         pct_refug,                                                                       
         tmp_ressup_sobr) 
     VALUES(p_cod_empresa,                                                                   
         l_cod_pai,                                                                      
         l_cod_compon,                                                         
         m_cod_item,                                                             
         l_qtd_neces,0,0)                                                            
                                                                                       
      IF STATUS <> 0 THEN                                                              
         CALL log003_err_sql('INSERT','item_altern')      
         RETURN FALSE                                                                  
      END IF                                                                           

   END FOREACH
   
   RETURN TRUE

END FUNCTION


#-------rotinas para inclusão de um novo material a abixar--------#

#------------------------#
FUNCTION pol1322_create()#
#------------------------#

   CALL _ADVPL_set_property(m_statusbar,'CLEAR_TEXT')   
   
   IF NOT m_ies_cons THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe previamente o Boletim.")
      RETURN FALSE
   END IF

   IF m_processado THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação não permitida, para boletim processado.")
      RETURN FALSE
   END IF
   
   INITIALIZE   mr_produto TO NULL
      
   CALL pol1322_form_create()   

   RETURN TRUE
   
END FUNCTION
        
#-----------------------------#
FUNCTION pol1322_form_create()#
#-----------------------------#

   DEFINE l_panel      VARCHAR(10),
          l_menubar    VARCHAR(10),
          l_browse     VARCHAR(10),
          l_label      VARCHAR(10),
          l_confirma   VARCHAR(10),
          l_cancela    VARCHAR(10),
          l_qtd_estoq  VARCHAR(10)
   
    LET m_tela_prod = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_tela_prod,"SIZE",800,400) #480
    CALL _ADVPL_set_property(m_tela_prod,"TITLE","INCLUSÃO DE MATERIAL")
    CALL _ADVPL_set_property(m_tela_prod,"ENABLE_ESC_CLOSE",FALSE)
     CALL _ADVPL_set_property(m_tela_prod,"INIT_EVENT","pol1322_posiciona")
    
    LET m_stat_prod = _ADVPL_create_component(NULL,"LSTATUSBAR",m_tela_prod)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_tela_prod)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,20)
    CALL _ADVPL_set_property(l_label,"TEXT","Cod material:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_produto = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_cod_produto,"POSITION",100,20)
    CALL _ADVPL_set_property(m_cod_produto,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_produto,"VARIABLE",mr_produto,"cod_produto")
    CALL _ADVPL_set_property(m_cod_produto,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_produto,"VALID","pol1322_valida_produto")

    LET m_lupa_produto = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_produto,"POSITION",240,20)
    CALL _ADVPL_set_property(m_lupa_produto,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_produto,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_produto,"CLICK_EVENT","pol1322_zoom_produto")

    LET m_den_produto = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_den_produto,"POSITION",290,20)
    CALL _ADVPL_set_property(m_den_produto,"LENGTH",50) 
    CALL _ADVPL_set_property(m_den_produto,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_den_produto,"VARIABLE",mr_produto,"den_produto")
    CALL _ADVPL_set_property(m_den_produto,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,50)
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd baixar:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_qtd_produto = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_qtd_produto,"POSITION",100,50)
    CALL _ADVPL_set_property(m_qtd_produto,"LENGTH",15)
    CALL _ADVPL_set_property(m_qtd_produto,"VARIABLE",mr_produto,"qtd_produto")
    CALL _ADVPL_set_property(m_qtd_produto,"PICTURE","@E #,###,###.###")
    CALL _ADVPL_set_property(m_qtd_produto,"VALID","pol1322_valid_qtd_prod")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",290,50)
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd Estoque:")    

    LET l_qtd_estoq = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(l_qtd_estoq,"POSITION",390,50)
    CALL _ADVPL_set_property(l_qtd_estoq,"LENGTH",10,3) 
    CALL _ADVPL_set_property(l_qtd_estoq,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_qtd_estoq,"VARIABLE",mr_produto,"qtd_estoque")
    CALL _ADVPL_set_property(l_qtd_estoq,"PICTURE","@E ##,###,###.###")
    CALL _ADVPL_set_property(l_qtd_estoq,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,80)
    CALL _ADVPL_set_property(l_label,"TEXT","Dat consumo:")    

    LET m_consumo = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel)
    CALL _ADVPL_set_property(m_consumo,"POSITION",100,80)     
    CALL _ADVPL_set_property(m_consumo,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_consumo,"VARIABLE",mr_produto,"dat_consumo")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_tela_prod)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)
    
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
   CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirma,"EVENT","pol1322_conf_add")  

   LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancela,"EVENT","pol1322_canc_add")     
    
   CALL _ADVPL_set_property(m_tela_prod,"ACTIVATE",TRUE)

END FUNCTION

#---------------------------#
FUNCTION pol1322_posiciona()#
#---------------------------#

   CALL _ADVPL_set_property(m_cod_produto,"GET_FOCUS")

END FUNCTION

#------------------------------#
FUNCTION pol1322_zoom_produto()#
#------------------------------#

    DEFINE l_cod_item       LIKE item.cod_item,
           l_den_item       LIKE item.den_item,
           l_where_clause   CHAR(300)
    
    IF m_zoom_produto IS NULL THEN
       LET m_zoom_produto = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_produto,"ZOOM","zoom_item")
    END IF

    LET l_where_clause = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_produto,"ACTIVATE")
    
    LET l_cod_item = _ADVPL_get_property(m_zoom_produto,"RETURN_BY_TABLE_COLUMN","item","cod_item")
    #LET l_den_item = _ADVPL_get_property(m_zoom_produto,"RETURN_BY_TABLE_COLUMN","item","den_item")

    IF l_cod_item IS NOT NULL THEN
       LET mr_produto.cod_produto = l_cod_item
       CALL pol1322_valida_produto()
    END IF
    
END FUNCTION

#--------------------------------#
FUNCTION pol1322_valida_produto()#
#--------------------------------#
    
    CALL _ADVPL_set_property(m_stat_prod,"ERROR_TEXT",'')
    
    IF mr_produto.cod_produto IS NULL THEN
       LET m_msg = 'Informe o código do material.'
       CALL _ADVPL_set_property(m_stat_prod,"ERROR_TEXT",m_msg)
       CALL _ADVPL_set_property(m_cod_produto,"GET_FOCUS")
       RETURN FALSE
    END IF   
    
    SELECT den_item,
           cod_local_estoq
      INTO mr_produto.den_produto,
           m_cod_local_baixa
      FROM item
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = mr_produto.cod_produto

    IF STATUS <> 0 AND STATUS <> 100 THEN
        CALL log003_err_sql("SELECT","item")
        RETURN FALSE
    END IF
    
    IF STATUS = 100 THEN
       LET m_msg = 'Material não cadastrado no Logix.'
       CALL _ADVPL_set_property(m_stat_prod,"ERROR_TEXT",m_msg)
       RETURN FALSE
    END IF   

    IF NOT pol1322_le_manufatura(mr_produto.cod_produto) THEN
       RETURN FALSE
    END IF
         
    IF m_ies_sofre_baixa = 'S' THEN
       LET m_msg = 'Esse item deve ser baixado no apto. de produção\n'
       CALL _ADVPL_set_property(m_stat_prod,"ERROR_TEXT",m_msg)
       RETURN FALSE
    END IF

   SELECT COUNT(cod_material)
     INTO m_count
     FROM boletim_ond_885   
    WHERE chav_acesso = m_chav_acesso
      AND cod_material = mr_produto.cod_produto

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','boletim_ond_885:COUNT:cod_material')
      RETURN FALSE
   END IF
   
   IF m_count > 0 THEN
      LET m_msg = 'Esse material já existe no boletim' 
      CALL log0030_mensagem(m_msg,'INFO')
      RETURN FALSE
   END IF
    
    LET m_cod_item = mr_produto.cod_produto
    CALL pol1322_le_estoque()
    LET mr_produto.qtd_estoque = m_qtd_saldo
    
    RETURN TRUE
    
END FUNCTION

#--------------------------------#
FUNCTION pol1322_valid_qtd_prod()#
#--------------------------------#
    
    CALL _ADVPL_set_property(m_stat_prod,"ERROR_TEXT",'')
    
    IF mr_produto.qtd_produto IS NULL OR mr_produto.qtd_produto <= 0 THEN
       LET m_msg = 'Preencha o campo Qtd baixar'
       CALL _ADVPL_set_property(m_stat_prod,"ERROR_TEXT",m_msg)
       RETURN FALSE
    END IF   
    
    IF mr_produto.qtd_produto > mr_produto.qtd_estoque THEN
       LET m_msg = 'Quantidade superior ao saldo em estoque.'
       CALL _ADVPL_set_property(m_stat_prod,"ERROR_TEXT",m_msg)
       RETURN FALSE
    END IF    
    
    RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1322_canc_add()#
#--------------------------#

   CALL _ADVPL_set_property(m_tela_prod,"ACTIVATE",FALSE)
   
   RETURN TRUE

END FUNCTION


#--------------------------#
FUNCTION pol1322_conf_add()#
#--------------------------#
   
    CALL _ADVPL_set_property(m_stat_prod,"ERROR_TEXT",'')
    
    IF mr_produto.cod_produto IS NULL THEN
       LET m_msg = 'Informe o código do material.'
       CALL _ADVPL_set_property(m_stat_prod,"ERROR_TEXT",m_msg)
       RETURN FALSE
    END IF   

    IF mr_produto.qtd_produto IS NULL OR mr_produto.qtd_produto <= 0 THEN
       LET m_msg = 'Preencha o campo Qtd baixar'
       CALL _ADVPL_set_property(m_stat_prod,"ERROR_TEXT",m_msg)
       RETURN FALSE
    END IF   
    
    IF mr_produto.dat_consumo IS NULL THEN
       LET m_msg = 'Informe a data do consumo.'
       CALL _ADVPL_set_property(m_stat_prod,"ERROR_TEXT",m_msg)
       RETURN FALSE
    END IF   
                
   CALL LOG_transaction_begin()
   
   IF NOT pol1322_add_produto() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   CALL LOG_transaction_commit()
   
   CALL _ADVPL_set_property(m_tela_prod,"ACTIVATE",FALSE)
   
   CALL pol1322_reflesh()
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1322_add_produto()#
#-----------------------------#
   
   DEFINE l_qtd_baixar    DECIMAL(10,3),
          l_num_of        INTEGER,
          l_cod_mat       CHAR(15),
          l_status        CHAR(01)
   
   LET l_cod_mat = mr_produto.cod_produto
   
   SELECT COUNT(DISTINCT num_of)
     INTO m_count 
     FROM boletim_ond_885   
    WHERE chav_acesso = m_chav_acesso

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','boletim_ond_885:COUNT')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Não foi possivel identificar\n as OFs do boletim' 
      CALL log0030_mensagem(m_msg,'INFO')
      RETURN FALSE
   END IF
   
   LET l_qtd_baixar = mr_produto.qtd_produto / m_count
   
   DECLARE cq_of CURSOR WITH HOLD FOR
    SELECT DISTINCT num_of, status_registro
     FROM boletim_ond_885   
    WHERE chav_acesso = m_chav_acesso
   
   FOREACH cq_of INTO l_num_of, l_status  

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','boletim_ond_885:cq_of')
         RETURN FALSE
      END IF
      
      INSERT INTO boletim_ond_885(
         chav_acesso,    
         num_boletim,    
         num_versao,     
         dat_producao,   
         cod_composicao, 
         num_of,         
         cod_material,   
         qtd_consumo,    
         cod_operacao,   
         status_registro)
      VALUES(m_chav_acesso,
             mr_cabec.num_boletim,
             0,
             mr_produto.dat_consumo,
             mr_cabec.cod_composicao,
             l_num_of,
             l_cod_mat,
             l_qtd_baixar,
             'A',
             l_status)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','boletim_ond_885:INSERT')
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1322_estornar()#
#--------------------------#

   CALL _ADVPL_set_property(m_statusbar,'CLEAR_TEXT')   
   
   IF m_ies_cons THEN
      IF NOT m_processado THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
                "Operação não permitida, para boletim em aberto.")
         RETURN FALSE
      END IF   
   ELSE
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe previamente o Boletim.")
      RETURN FALSE
   END IF
      
   LET m_msg = 'Deseja mesmo efetuar o estorno ?'
   
   IF NOT LOG_question(m_msg) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN TRUE
   END IF

   IF NOT pol1322_le_parametros() THEN
      RETURN FALSE
   END IF
      
   CALL LOG_transaction_begin()
   
   IF NOT pol1322_proces_estorno() THEN
      CALL LOG_transaction_rollback()
   ELSE
      CALL LOG_transaction_commit()   
      CALL pol1322_reflesh()
      LET mr_cabec.status = 'EM ABRTO'
      LET m_processado = FALSE
      LET m_msg = ' Estorno de baixa de material \n efetuado com sucesso.'
      CALL log0030_mensagem(m_msg,'info')
   END IF
      
   RETURN TRUE         
   
END FUNCTION

#--------------------------------#
FUNCTION pol1322_proces_estorno()#
#--------------------------------#

   LET m_proces_ok = FALSE
   CALL LOG_progresspopup_start("Processando...","pol1322_estorna_material","PROCESS")   
   
   RETURN m_proces_ok

END FUNCTION

#----------------------------------#
FUNCTION pol1322_estorna_material()#
#----------------------------------#

   DEFINE l_progres     SMALLINT,
          l_tot_rateio  DECIMAL(10,3)

   SELECT COUNT(*)
     INTO m_count
     FROM boletim_ond_885
    WHERE chav_acesso = m_chav_acesso

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','boletim_ond_885:COUNT')
      RETURN 
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Não há dados a baixar na tabela boletim_ond_885'
      CALL log0030_mensagem(m_msg,'info')
      RETURN
   END IF      
       
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DECLARE cq_storna CURSOR FOR
   SELECT num_transac,
          num_sequencia
     FROM boletim_ond_885
    WHERE chav_acesso = m_chav_acesso
   
   FOREACH cq_storna INTO m_num_transac, m_num_sequencia
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','boletim_ond_885:cq_storna')
         RETURN 
      END IF
   
      LET l_progres = LOG_progresspopup_increment("PROCESS")

      IF NOT pol1322_exec_storno() THEN
         RETURN
      END IF
               
   END FOREACH
      
   LET m_proces_ok = TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1322_exec_storno()#
#-----------------------------#

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
         ies_ctr_lote  CHAR(01),
         num_conta     CHAR(20),
         cus_unit      DECIMAL(12,2),
         cus_tot       DECIMAL(12,2)
   END RECORD
   
   DEFINE l_estoque_trans RECORD LIKE estoque_trans.*
   
   SELECT *
     INTO l_estoque_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = m_num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_trans')
      RETURN FALSE
   END IF
      
   LET p_item.cod_empresa   = l_estoque_trans.cod_empresa
   LET p_item.cod_item      = l_estoque_trans.cod_item
   LET p_item.cod_operacao  = l_estoque_trans.cod_operacao
   LET p_item.qtd_movto     = l_estoque_trans.qtd_movto   
   LET p_item.dat_movto     = l_estoque_trans.dat_movto   
   LET p_item.num_prog      = l_estoque_trans.num_prog 
   LET p_item.num_docum     = l_estoque_trans.num_docum
   LET p_item.num_seq       = l_estoque_trans.num_seq  
   LET p_item.usuario       = l_estoque_trans.nom_usuario
   LET p_item.cod_turno     = l_estoque_trans.cod_turno
   LET p_item.trans_origem  = l_estoque_trans.num_transac
      
   LET p_item.cod_local     = l_estoque_trans.cod_local_est_orig
   LET p_item.num_lote      = l_estoque_trans.num_lote_orig
   LET p_item.ies_situa     = l_estoque_trans.ies_sit_est_orig

   LET p_item.num_conta     = l_estoque_trans.num_conta
   LET p_item.cus_unit      = l_estoque_trans.cus_unit_movto_p
   LET p_item.cus_tot       = l_estoque_trans.cus_tot_movto_p

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
      AND num_transac = m_num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_trans_end')
      RETURN FALSE
   END IF
      
   LET p_item.tip_operacao  = 'S' 
   LET p_item.ies_tip_movto = 'R'
   LET p_item.dat_proces    = TODAY
   LET p_item.hor_operac    = TIME 
   
   IF p_item.num_lote IS NULL OR
         p_item.num_lote = ' ' OR LENGTH(p_item.num_lote) = 0 THEN
      LET p_item.num_lote = NULL
      LET p_item.ies_ctr_lote  = 'N'
   ELSE
      LET p_item.ies_ctr_lote  = 'S'
   END IF
      
   IF NOT func005_insere_movto(p_item) THEN
      RETURN FALSE
   END IF
   
   LET m_qtd_baixar = l_estoque_trans.qtd_movto
   LET m_num_ordem = l_estoque_trans.num_docum
   LET m_cod_item = l_estoque_trans.cod_item
   
   IF NOT pol1322_baixa_neces('E') THEN
      RETURN FALSE
   END IF

   IF NOT pol1322_grava_bolet('2') THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1322_relatorio()#
#---------------------------#


   CALL LOG_progresspopup_start("Imprimindo...","pol1322_imp_bolet","PROCESS")

   IF NOT p_status THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", 'Impressão cancelada.')
   END IF
   
END FUNCTION

#---------------------------#
FUNCTION pol1322_imp_bolet()#
#---------------------------#

   LET p_status = StartReport(
      "pol1322_le_boletins","pol1322","",132,TRUE,TRUE)

END FUNCTION

#-------------------------------------#
FUNCTION pol1322_le_boletins(l_report)#
#-------------------------------------#

   DEFINE l_report             CHAR(300),
          l_num_boletim        INTEGER,
          l_status             SMALLINT
   
   LET m_houve_erro = FALSE
   LET m_bole_imp = 0

   START REPORT pol1322_relat TO l_report

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_den_empresa = NULL
   END IF
   
   DECLARE cq_relat CURSOR FOR
    SELECT MAX(chav_acesso), 
           num_boletim           
      FROM boletim_ond_885 WHERE 1=1 
     GROUP BY num_boletim
     ORDER BY num_boletim
   
   FOREACH cq_relat INTO mr_relat.chav_acesso, l_num_boletim
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','boletim_ond_885:cq_relat')
         EXIT FOREACH
      END IF
      
      LET l_status = LOG_progresspopup_increment("PROCESS")
      
      OUTPUT TO REPORT pol1322_relat(l_num_boletim)
      
      IF m_houve_erro THEN
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   FINISH REPORT pol1322_relat 
   CALL FinishReport("pol1322")

END FUNCTION

#----------------------------------#
REPORT pol1322_relat(l_num_boletim)#
#----------------------------------# 

   DEFINE l_num_boletim     INTEGER,
          l_status          CHAR(10),
          l_num_of          INTEGER,
          l_of_print        CHAR(94)

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3

   ORDER EXTERNAL BY l_num_boletim

   FORMAT

      PAGE HEADER

         PRINT
         PRINT COLUMN 001, p_den_empresa[1,20],
               COLUMN 085, "PAG.:", PAGENO USING "##&"
         PRINT COLUMN 001, "POL1322 - LISTAGEM DE BOETINS EXPORTADOS PELO TRIM BOX",
               COLUMN 066, "EMISSAO: ", TODAY USING "DD/MM/YYYY", ' ', TIME 
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------"
                                                                                          
      BEFORE GROUP OF l_num_boletim
         
         IF m_bole_imp = 4 THEN
            SKIP TO TOP OF PAGE
            LET m_bole_imp = 0
         END IF

         PRINT
         PRINT COLUMN 001, " BOLETIM    PRODUCAO  COMPOSICAO ITEM ENVIADO QTD ENVIADA ITEM BAIXADO QTD BAIXADA  STATUS"
         PRINT COLUMN 001, "---------- ---------- ---------- ------------ ----------- ------------ ----------- ----------"
         PRINT
                  
         SELECT DISTINCT cod_composicao, status_registro
           INTO mr_relat.cod_composicao,
                l_status
           FROM boletim_ond_885
          WHERE chav_acesso = mr_relat.chav_acesso
            AND num_boletim = l_num_boletim

         IF STATUS <> 0 THEN
            #CALL log003_err_sql('SELECT','boletim_ond_885:listagem')
            #LET m_houve_erro = TRUE
            RETURN
         END IF
         
         IF l_status = '1' THEN
            LET l_status = 'Processado'
         ELSE
            LET l_status = 'Em aberto'
         END IF
         
         DECLARE cq_itens_bolet CURSOR FOR
          SELECT cod_material,
                 SUM(qtd_consumo),
                 cod_baixar,
                 SUM(qtd_baixar),
                 dat_producao
            FROM boletim_ond_885
           WHERE chav_acesso = mr_relat.chav_acesso
             AND num_boletim = l_num_boletim
           GROUP BY cod_material, cod_baixar, dat_producao
         FOREACH cq_itens_bolet INTO 
            mr_relat.cod_material,
            mr_relat.qtd_consumo,
            mr_relat.cod_baixar,
            mr_relat.qtd_baixar,
            mr_relat.dat_producao
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('FOREACH','boletim_ond_885:cq_itens_bolet')
               LET m_houve_erro = TRUE
               RETURN
            END IF
            
            PRINT COLUMN 001, l_num_boletim USING '#########&',
                  COLUMN 012, mr_relat.dat_producao,
                  COLUMN 023, mr_relat.cod_composicao[1,10],
                  COLUMN 034, mr_relat.cod_material[1,12],
                  COLUMN 047, mr_relat.qtd_consumo USING '#####&.&&&',
                  COLUMN 059, mr_relat.cod_baixar[1,12],
                  COLUMN 072, mr_relat.qtd_baixar USING '######&.&&&',
                  COLUMN 084, l_status
            
         END FOREACH

         LET m_bole_imp = m_bole_imp + 1
   
      ON EVERY ROW
         
         PRINT
         
         LET l_of_print = 'OFs:'
         
         DECLARE cq_of CURSOR FOR
          SELECT num_of FROM boletim_ond_885
           WHERE chav_acesso = mr_relat.chav_acesso
             AND num_boletim = l_num_boletim

         FOREACH cq_of INTO 
            l_num_of
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('FOREACH','boletim_ond_885:cq_of')
               LET m_houve_erro = TRUE
               RETURN
            END IF
            
            LET l_of_print = l_of_print CLIPPED, l_num_of USING '<<<<<<<<<<'
            
            IF LENGTH(l_of_print) > 80 THEN
               PRINT COLUMN 003, l_of_print
               LET l_of_print = 'OFs:'
            ELSE
               LET l_of_print = l_of_print CLIPPED,'/'
            END IF
            
         END FOREACH

         IF l_of_print <> 'OFs:' THEN
            PRINT COLUMN 003, l_of_print
         END IF
      
      AFTER GROUP OF l_num_boletim
         
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------"
          
      ON LAST ROW

END REPORT
   