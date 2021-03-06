#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1408                                                 #
# OBJETIVO: CONSULTA INTEGRA��O lOGIX X e COMMERCE                  #
# AUTOR...: IVO                                                     #
# DATA....: 18/11/2020                                              #
#-------------------------------------------------------------------#

{Lista de pre�o
VPD10102 � Tabela Mestre
VPD0270 � Item

Pendencias:

Ver com a cairu politica de envio de estoque
Ver como enviar estoque para santa catarina
Desenvolver envio de produto
Desenvolver envio de pedido cancelado
}

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           m_panel         VARCHAR(10),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_nom_func        LIKE usuarios.nom_funcionario

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_folder          VARCHAR(10),
       m_fold_om         VARCHAR(10),
       m_pan_sys         VARCHAR(10),
       m_brz_om         VARCHAR(10),
       m_om_construct   VARCHAR(10)
       
DEFINE m_count           INTEGER,
       m_msg             VARCHAR(200),
       m_op_sys          CHAR(01),
       m_car_om         SMALLINT,
       m_ind             INTEGER,
       m_nom_sys         VARCHAR(15),
       m_sen_env_crip    VARCHAR(80),
       m_sen_req_crip    VARCHAR(80)

                               
DEFINE mr_sys            RECORD
       cod_sys           VARCHAR(1), 
       user_req_serv     VARCHAR(15), 
       senha_req_serv    VARCHAR(80), 
       user_erp          VARCHAR(08), 
       qtd_lin_page      INTEGER,     
       max_lin_page      INTEGER,     
       user_envio        VARCHAR(15), 
       senha_envio       VARCHAR(80), 
       uri_inc_prod      VARCHAR(80), 
       uri_alt_prod      VARCHAR(80), 
       uri_alt_estoq     VARCHAR(80), 
       uri_canc_pedido   VARCHAR(80)
END RECORD

DEFINE ma_om             ARRAY[2000] OF RECORD
       id                INTEGER,
       pedido            INTEGER, 
       ordem             INTEGER, 
       data              DATE,
       filler            CHAR(01)  
END RECORD

DEFINE m_cod_sys         VARCHAR(10),
       m_user_envio      VARCHAR(10),
       m_senha_envio     VARCHAR(10),
       m_user_req        VARCHAR(10),
       m_senha_req       VARCHAR(10),
       m_user_erp        VARCHAR(10),
       m_inc_prod        VARCHAR(10),
       m_alt_prod        VARCHAR(10),
       m_alt_estoq       VARCHAR(10),
       m_uri_canc_ped    VARCHAR(10),
       m_qtd_lin         VARCHAR(10),
       m_max_lin         VARCHAR(10)       

DEFINE m_brz_aen         VARCHAR(10),
       m_zoom_aen        VARCHAR(10),
       m_lupa_aen        VARCHAR(10),
       m_fold_erro        VARCHAR(10),
       m_pan_aen         VARCHAR(10),
       m_aen_construct   VARCHAR(10),
       m_op_aen          CHAR(01),
       m_car_aen         SMALLINT

DEFINE mr_aen            RECORD
       cod_sys           VARCHAR(15), 
       cnpj              VARCHAR(19), 
       cod_lin_prod      DECIMAL(2,0),
       desc_linha        VARCHAR(30) 
END RECORD

DEFINE ma_aen            ARRAY[100] OF RECORD
       nom_sys           VARCHAR(15), 
       cnpj              VARCHAR(19), 
       cod_lin_prod      DECIMAL(2,0),
       desc_linha        VARCHAR(30), 
       filler            CHAR(01)
END RECORD

DEFINE m_aen_sys         VARCHAR(10),
       m_lin_prod        VARCHAR(10),
       m_cgc_emp         VARCHAR(10),
       m_aen_nom_sys     VARCHAR(15)

DEFINE m_brz_emp         VARCHAR(10),
       m_fold_emp        VARCHAR(10),
       m_pan_emp         VARCHAR(10),
       m_cnpj_emp        VARCHAR(10),
       m_emp_emp         VARCHAR(10),
       m_env_aut         VARCHAR(10),
       m_emp_construct   VARCHAR(10),
       m_zoom_cnpj       VARCHAR(10),
       m_zoom_emp        VARCHAR(10),
       m_car_emp         smallint,
       m_op_emp          char(01)

DEFINE mr_emp          RECORD
       cnpj            VARCHAR(19),
       empresa         VARCHAR(02),
       descricao       VARCHAR(36),
       uf              VARCHAR(02),
       enviar          VARCHAR(01)
END RECORD

DEFINE ma_emp            ARRAY[100] OF RECORD
       cnpj              VARCHAR(19),
       empresa           VARCHAR(02),
       uf                CHAR(02),
       descricao         VARCHAR(36),
       enviar            CHAR(01),
       filler            CHAR(01)
END RECORD

DEFINE m_par_construct   VARCHAR(10),
       m_op_par          CHAR(01),
       m_ies_cons        SMALLINT,
       m_excluiu         SMALLINT

DEFINE m_fold_par        VARCHAR(10),
       m_pan_par         VARCHAR(10),
       m_cnpj_empresa    VARCHAR(19),
       m_cnpj_empresaa   VARCHAR(19)

DEFINE mr_par            RECORD        
   cnpj_empresa          VARCHAR(19),  
   cod_empresa           CHAR(02),
   cod_nat_oper          DECIMAL(4,0), 
   den_nat_oper          VARCHAR(30),
   pct_comissao          DECIMAL(5,2), 
   ies_finalidade        DECIMAL(1,0), 
   ies_frete             DECIMAL(1,0), 
   ies_preco             CHAR(01),     
   cod_cnd_pgto          DECIMAL(4,0), 
   den_cnd_pgto          VARCHAR(30),
   ies_embal_padrao      CHAR(01),     
   ies_tip_entrega       DECIMAL(1,0), 
   ies_sit_pedido        CHAR(01),     
   num_list_preco        DECIMAL(4,0), 
   den_list_preco        VARCHAR(30),
   cod_repres            DECIMAL(4,0), 
   cod_tip_venda         DECIMAL(1,0), 
   cod_moeda             DECIMAL(1,0), 
   ies_comissao          CHAR(01),     
   cod_tip_carteira      CHAR(02),     
   cod_local_estoq       CHAR(10),
   den_local             VARCHAR(30),
   bloqueio_estoque      CHAR(01)      
END RECORD

DEFINE m_cnpj_par        VARCHAR(10),
       m_nat_par         VARCHAR(10),
       m_zoom_nat        VARCHAR(10),
       m_zoom_cond       VARCHAR(10),
       m_zoom_lista      VARCHAR(10),
       m_zoom_local      VARCHAR(10),
       m_pct_comis       VARCHAR(10),
       m_finalidade      VARCHAR(10),
       m_frete           VARCHAR(10),
       m_preco           VARCHAR(10),
       m_condicao        VARCHAR(10),
       m_embal           VARCHAR(10),
       m_carteira        VARCHAR(10),
       m_entrega         VARCHAR(10),
       m_situacao        VARCHAR(10),
       m_lista           VARCHAR(10),
       m_repres          VARCHAR(10),
       m_venda           VARCHAR(10),
       m_moeda           VARCHAR(10),
       m_ies_comis       VARCHAR(10),
       m_local           VARCHAR(10),
       m_bloq_estoq      VARCHAR(10)

                   
#-----------------#
FUNCTION pol1408()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1408-12.00.00  "
   CALL func002_versao_prg(p_versao)
   
   LET m_car_om = TRUE
   LET m_car_aen = TRUE
   LET m_car_emp = TRUE
   INITIALIZE mr_sys.* TO NULL
   INITIALIZE mr_aen.* TO NULL
   INITIALIZE mr_emp.* TO NULL
   INITIALIZE mr_par.* TO NULL
   
   CALL pol1408_menu()

END FUNCTION
 
#----------------------#
FUNCTION pol1408_menu()#
#----------------------#

    DEFINE l_titulo        CHAR(80)

    LET l_titulo = 'CONSULTA INTEGRA��O lOGIX X eCOMMERCE - ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET m_folder = _ADVPL_create_component(NULL,"LFOLDER",m_dialog)
    CALL _ADVPL_set_property(m_folder,"ALIGN","CENTER")

    # FOLDER PEDIDO/OM 

    LET m_fold_om = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_om,"TITLE","Ordem montagem")
		CALL pol1408_ordem(m_fold_om)
    
    # FOLDER ERROS 

    LET m_fold_erro = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_erro,"TITLE","Erros de integra��o")
   # CALL pol1408_erro(m_fold_erro)

    CALL _ADVPL_set_property(m_folder,"FOLDER_SELECTED",1)
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION
   
#------------------------#
FUNCTION pol1408_fechar()#
#------------------------#

   RETURN TRUE
   
END FUNCTION

#-----------------------------------------#
FUNCTION pol1408_desativa_folder(l_folder)#
#-----------------------------------------#

   DEFINE l_folder             CHAR(01)
             
   CASE l_folder
        WHEN '1' 
           CALL _ADVPL_set_property(m_fold_erro,"ENABLE",FALSE)
        WHEN '2' 
           CALL _ADVPL_set_property(m_fold_om,"ENABLE",FALSE)   
   END CASE
   
END FUNCTION

#------------------------------#
FUNCTION pol1408_ativa_folder()#
#------------------------------#

   CALL _ADVPL_set_property(m_fold_om,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_erro,"ENABLE",TRUE)

END FUNCTION




#---Rotinas consulta de OMs ----#

#---------------------------------#
FUNCTION pol1408_ordem(l_fpanel)#
#---------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1408_om_find")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1408_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1408_om_grade(l_panel)
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1408_om_grade(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_om = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_om,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(m_brz_om,"BEFORE_ROW_EVENT","pol1408_om_before_row")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_om)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Id")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","id")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_om)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_om)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_om)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Gera��o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","data")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_om)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)    
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_om,"SET_ROWS",ma_om,1)
    CALL _ADVPL_set_property(m_brz_om,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_om,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_om,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#---------------------------#
FUNCTION pol1408_om_find()#
#---------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    LET m_op_sys = 'P'
    
    IF m_om_construct IS NULL THEN
       LET m_om_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_om_construct,"CONSTRUCT_NAME","pol1408_FILTER")
       CALL _ADVPL_set_property(m_om_construct,"ADD_VIRTUAL_TABLE","pedido_om","parametro")
       CALL _ADVPL_set_property(m_om_construct,"ADD_VIRTUAL_COLUMN","pedido_om","num_pedido","Pededo",1 {int},6,0)
       CALL _ADVPL_set_property(m_om_construct,"ADD_VIRTUAL_COLUMN","pedido_om","num_om","Ordem",1 {int},6,0)
       CALL _ADVPL_set_property(m_om_construct,"ADD_VIRTUAL_COLUMN","pedido_om","dat_geracao","Gera��o",1 {Date},10)
    END IF

    LET l_status = _ADVPL_get_property(m_om_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_om_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_om_construct,"ORDER_BY")
       CALL pol1408_om_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#--------------------------------------------------#
FUNCTION pol1408_om_create_cursor(l_where, l_order)#
#--------------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)
    DEFINE l_ind        INTEGER

    IF l_order IS NULL THEN
       LET l_order = " num_pedido "
    END IF
    
    LET l_sql_stmt = 
       " SELECT id, num_pedido, num_om, dat_geracao ",
       " FROM pedido_om ",
        " WHERE ",l_where CLIPPED,
        " ORDER BY ",l_order
   
   CALL pol1408_om_exibe(l_sql_stmt)
   
END FUNCTION

#------------------------------------#
FUNCTION pol1408_om_exibe(l_sql_stmt)#
#------------------------------------#
   
   DEFINE l_sql_stmt   CHAR(2000),
          l_ind        INTEGER

   CALL _ADVPL_set_property(m_brz_om,"CLEAR")
   LET m_car_om = TRUE
   INITIALIZE ma_om TO NULL
   LET l_ind = 1
   
    PREPARE var_om FROM l_sql_stmt

    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","pedido_om")
       RETURN FALSE
    END IF

   DECLARE cq_om CURSOR FOR var_om
   
   FOREACH cq_sys INTO 
      ma_om[l_ind].id,
      ma_om[l_ind].pedido,
      ma_om[l_ind].ordem,
      ma_om[l_ind].data

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','cq_om:01')
         EXIT FOREACH
      END IF

      LET l_ind = l_ind + 1
      
      IF l_ind > 20 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   IF l_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_om,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'N�o h� registros para os par�metros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   LET m_car_om = FALSE
        
END FUNCTION
