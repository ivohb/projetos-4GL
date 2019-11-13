#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1308                                                 #
# OBJETIVO: ERROS DE INTEGRAÇÃO DE APONTAMENTOS                     #
# AUTOR...: IVO                                                     #
# DATA....: 20/09/16                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18)
           
END GLOBALS

DEFINE m_cod_empresa_plano   LIKE empresa.cod_empresa

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_cod_operac      VARCHAR(10),
       m_den_operac      VARCHAR(10),
       m_zoom_operac     VARCHAR(10),
       m_lupa_operac     VARCHAR(10),
       m_cod_item        VARCHAR(10),
       m_den_item        VARCHAR(10),
       m_zoom_item       VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_num_op          VARCHAR(10),
       m_qtd_movto       VARCHAR(10),
       m_tip_movto       VARCHAR(10),
       m_tip_oper        VARCHAR(10),
       m_cod_motivo      VARCHAR(10),
       m_cod_turno       VARCHAR(10),
       m_dat_ini         VARCHAR(10),
       m_dat_fim         VARCHAR(10),
       m_hor_ini         VARCHAR(10),
       m_hor_fim         VARCHAR(10),
       m_cent_trab       VARCHAR(10),
       m_cent_cust       VARCHAR(10),
       m_arranjo         VARCHAR(10),
       m_equipto         VARCHAR(10),
       m_browse          VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_id_registro     INTEGER,
       m_id_registroa    INTEGER,
       m_ind             INTEGER,
       m_mot_retrab      CHAR(15),
       m_mot_refugo      CHAR(15)
       
DEFINE mr_campos         RECORD
       num_ordem         INTEGER,
       cod_operac        CHAR(05),
       den_operac        CHAR(18),
       cod_item          CHAR(15),
       den_item          CHAR(18),
       qtd_movto         DECIMAL(10,3),
       tip_movto         CHAR(06),
       tip_oper          CHAR(08),
       cod_motivo        CHAR(15),
       dat_ini           DATE,
       dat_fim           DATE,
       cod_turno         CHAR(01),
       hor_ini           CHAR(05),
       hor_fim           CHAR(05),
       cent_trab         CHAR(10),
       cent_cust         CHAR(10),
       arranjo           CHAR(05),
       equipto           CHAR(10)
END RECORD

DEFINE ma_erro           ARRAY[1000] OF RECORD
       id_registro       INTEGER,
       num_seq           INTEGER,
       den_erro          CHAR(150),
       filler            VARCHAR(1)
END RECORD

#-----------------#
FUNCTION pol1308()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1308-12.00.03  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1308_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1308_menu()#
#----------------------#

    DEFINE l_menubar,
           l_panel,
           l_create,
           l_update,
           l_find,
           l_first,
           l_previous,
           l_next,
           l_last,
           l_delete  VARCHAR(10)

    
    CALL pol1308_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE","APONTAMENTOS CRITICADOS")

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)
    
    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1308_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1308_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1308_update_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1308_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1308_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1308_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1308_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1308_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1308_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1308_cria_campos(l_panel)
    CALL pol1308_grade_erro(l_panel)

    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

    CALL pol1308_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1308_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
   INITIALIZE ma_erro TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1308_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   CALL _ADVPL_set_property(m_qtd_movto,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_dat_ini,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_dat_fim,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_hor_ini,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_hor_fim,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_cod_motivo,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_cod_turno,"EDITABLE",l_status)
   
END FUNCTION

#----------------------------------------#
FUNCTION pol1308_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
    CALL _ADVPL_set_property(l_panel,"WIDTH",50)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",18)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","ordem:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Item:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Descrição:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Operação:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Descrição:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Quantidade:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Tipo:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Movto:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cód defeito:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_num_op = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_num_op,"VARIABLE",mr_campos,"num_ordem")
    CALL _ADVPL_set_property(m_num_op,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_num_op,"PICTURE","##########")
    CALL _ADVPL_set_property(m_num_op,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_cod_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_item,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_item,"VARIABLE",mr_campos,"cod_item")
    CALL _ADVPL_set_property(m_cod_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET m_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_item,"LENGTH",18) 
    CALL _ADVPL_set_property(m_den_item,"VARIABLE",mr_campos,"den_item")
    CALL _ADVPL_set_property(m_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_cod_operac = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_operac,"LENGTH",5)
    CALL _ADVPL_set_property(m_cod_operac,"VARIABLE",mr_campos,"cod_operac")
    CALL _ADVPL_set_property(m_cod_operac,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_operac,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_den_operac = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_operac,"LENGTH",18) 
    CALL _ADVPL_set_property(m_den_operac,"VARIABLE",mr_campos,"den_operac")
    CALL _ADVPL_set_property(m_den_operac,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_qtd_movto = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_qtd_movto,"VARIABLE",mr_campos,"qtd_movto")
    CALL _ADVPL_set_property(m_qtd_movto,"LENGTH",10)
    CALL _ADVPL_set_property(m_qtd_movto,"PICTURE","@E ######9.999")
    CALL _ADVPL_set_property(m_qtd_movto,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_tip_movto = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_tip_movto,"LENGTH",6) 
    CALL _ADVPL_set_property(m_tip_movto,"VARIABLE",mr_campos,"tip_movto")
    CALL _ADVPL_set_property(m_tip_movto,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_tip_oper = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_tip_oper,"LENGTH",8) 
    CALL _ADVPL_set_property(m_tip_oper,"VARIABLE",mr_campos,"tip_oper")
    CALL _ADVPL_set_property(m_tip_oper,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_cod_motivo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_motivo,"LENGTH",8) 
    CALL _ADVPL_set_property(m_cod_motivo,"VARIABLE",mr_campos,"cod_motivo")
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Dat inicial:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Dat final:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Turno:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Hor inicial:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Hor final:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cent trab:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cent custo:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Aranjo:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Equipto:")    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_dat_ini = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_ini,"VARIABLE",mr_campos,"dat_ini")
    CALL _ADVPL_set_property(m_dat_ini,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_dat_fim = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_fim,"VARIABLE",mr_campos,"dat_fim")
    CALL _ADVPL_set_property(m_dat_fim,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_cod_turno = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_turno,"LENGTH",5)
    CALL _ADVPL_set_property(m_cod_turno,"VARIABLE",mr_campos,"cod_turno")
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_hor_ini = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_hor_ini,"LENGTH",5)
    CALL _ADVPL_set_property(m_hor_ini,"PICTURE","##:##") 
    CALL _ADVPL_set_property(m_hor_ini,"VARIABLE",mr_campos,"hor_ini")
    CALL _ADVPL_set_property(m_hor_ini,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_hor_fim = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_hor_fim,"LENGTH",5) 
    CALL _ADVPL_set_property(m_hor_fim,"PICTURE","##:##") 
    CALL _ADVPL_set_property(m_hor_fim,"VARIABLE",mr_campos,"hor_fim")
    CALL _ADVPL_set_property(m_hor_fim,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_cent_trab = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cent_trab,"LENGTH",10) 
    CALL _ADVPL_set_property(m_cent_trab,"VARIABLE",mr_campos,"cent_trab")
    CALL _ADVPL_set_property(m_cent_trab,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_cent_cust = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cent_cust,"LENGTH",10) 
    CALL _ADVPL_set_property(m_cent_cust,"VARIABLE",mr_campos,"cent_cust")
    CALL _ADVPL_set_property(m_cent_cust,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_arranjo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_arranjo,"LENGTH",8) 
    CALL _ADVPL_set_property(m_arranjo,"VARIABLE",mr_campos,"arranjo")
    CALL _ADVPL_set_property(m_arranjo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_equipto = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_equipto,"LENGTH",8) 
    CALL _ADVPL_set_property(m_equipto,"VARIABLE",mr_campos,"equipto")
    CALL _ADVPL_set_property(m_equipto,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

END FUNCTION

#---------------------------------------#
FUNCTION pol1308_grade_erro(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    
    # colunas da grade    

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Registro")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","id_registro")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Seq")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_seq")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_erro")

    {LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")}

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_erro,1)

END FUNCTION


#----------------------#
FUNCTION pol1308_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1308_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","man_apont_304","apont")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","man_apont_304","num_ordem","Ordem",1 {INT},10,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","man_apont_304","cod_operac","Operação",1 {CHAR},5,0,"zoom_operacao")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","man_apont_304","cod_item","Item",1 {CHAR},15,0,"zoom_item")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1308_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1308_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " num_ordem, id_registro "
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT id_registro ",
                      " FROM man_apont_304 ",
                     " WHERE ",l_where CLIPPED,
                       " AND integrado = 3 ",
                       " AND cod_empresa = '",p_cod_empresa,"' ",
                     " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","man_apont_304")
       RETURN FALSE
    END IF

    DECLARE cq_cons SCROLL CURSOR WITH HOLD FOR var_cons

    IF  STATUS <> 0 THEN
        CALL log003_err_sql("DECLARE CURSOR","cq_cons")
        RETURN FALSE
    END IF

    FREE var_cons

    OPEN cq_cons

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_cons")
       RETURN FALSE
    END IF

    FETCH cq_cons INTO m_id_registro

    IF STATUS <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","cq_cons")
       ELSE
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Argumentos de pesquisa não encontrados.")
       END IF
       CALL pol1308_limpa_campos()
       RETURN FALSE
    END IF
    
    CALL pol1308_exibe_dados() 
    
    LET m_ies_cons = TRUE
    LET m_id_registroa = m_id_registro
    
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1308_exibe_dados()#
#-----------------------------#
      
   LET m_excluiu = FALSE
   
   SELECT num_ordem,
          m.cod_operac,
          o.den_operac,
          m.cod_item,
          i.den_item_reduz,
          m.qtd_movto,
          m.tip_movto,
          m.tip_integra,
          m.dat_inicial,
          m.dat_final,
          m.cod_turno,
          m.hor_inicial,
          m.hor_final,
          m.cod_cent_trab,
          m.cod_cent_cust,
          m.cod_arranjo,
          m.cod_eqpto,
          m.motivo_retrab,
          m.motivo_refugo
     INTO mr_campos.num_ordem,
          mr_campos.cod_operac,
          mr_campos.den_operac,
          mr_campos.cod_item,
          mr_campos.den_item,
          mr_campos.qtd_movto,
          mr_campos.tip_movto,
          mr_campos.tip_oper,
          mr_campos.dat_ini,  
          mr_campos.dat_fim,  
          mr_campos.cod_turno,
          mr_campos.hor_ini,  
          mr_campos.hor_fim,  
          mr_campos.cent_trab,
          mr_campos.cent_cust,
          mr_campos.arranjo,  
          mr_campos.equipto,
          m_mot_retrab,
          m_mot_refugo  
     FROM man_apont_304 m, item i, operacao o
    WHERE m.cod_empresa = p_cod_empresa
      AND m.id_registro = m_id_registro
      AND m.cod_empresa = i.cod_empresa
      AND m.cod_item = i.cod_item
      AND m.cod_empresa = o.cod_empresa
      AND m.cod_operac = o.cod_operac     

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','man_apont_304/item/operacao')
      RETURN
   END IF
   
   IF l_mot_retrab IS NOT NULL THEN
      LET mr_campos.cod_motivo = m_mot_retrab
   ELSE
      LET mr_campos.cod_motivo = m_mot_refugo
   END IF
   
   IF mr_campos.tip_movto = '1' THEN
      LET mr_campos.tip_movto = 'Boas'
   ELSE
      LET mr_campos.tip_movto = 'Sucata'
   END IF
   
   IF mr_campos.tip_oper = 'A' THEN
      LET mr_campos.tip_oper = 'Apontar'
   ELSE
      IF mr_campos.tip_oper = 'E' THEN
         LET mr_campos.tip_oper = 'Estornar'
      ELSE
         LET mr_campos.tip_movto = 'Tempo'
      END IF
   END IF   

   IF NOT pol1308_le_erros() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
   
        
END FUNCTION

#--------------------------#
FUNCTION pol1308_le_erros()#
#--------------------------#
   
   LET m_ind = 1
   INITIALIZE ma_erro TO NULL
   
   DECLARE cq_erros CURSOR FOR
    SELECT den_erro
      FROM apont_erro_912
     WHERE cod_empresa = p_cod_empresa
       AND id_man_apont = m_id_registro
       
   FOREACH cq_erros INTO 
      ma_erro[m_ind].den_erro

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','APONT_ERRO_912:cq_erros')
         LET m_msg = 'Não foi possivel ler as mensagens de erro'
         RETURN FALSE
      END IF          

      LET ma_erro[m_ind].id_registro =  m_id_registro
      LET ma_erro[m_ind].num_seq =  m_ind
      LET m_ind = m_ind + 1
                     
   END FOREACH

   FREE cq_erros

   IF m_ind = 1 THEN
      LET m_msg = 'Não foi possivel ler as mensagens de erro'
      RETURN FALSE   
   END IF

   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT",m_ind - 1)

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1308_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1308_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1308_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_id_registroa = m_id_registro

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_id_registro
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_id_registro
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_id_registro
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_id_registro
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_id_registro = m_id_registroa
         EXIT WHILE
      ELSE
         SELECT 1
           FROM man_apont_304
          WHERE cod_empresa =  p_cod_empresa
            AND id_registro = m_id_registro
            AND integrado = 3
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1308_exibe_dados()
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
FUNCTION pol1308_first()#
#-----------------------#

   IF NOT pol1308_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1308_next()#
#----------------------#

   IF NOT pol1308_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1308_previous()#
#--------------------------#

   IF NOT pol1308_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1308_last()#
#----------------------#

   IF NOT pol1308_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1308_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM man_apont_304
     WHERE cod_empresa =  p_cod_empresa
       AND id_registro = m_id_registro
     FOR UPDATE 
    
    OPEN cq_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_prende")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
    
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_prende")
      CALL log085_transacao("ROLLBACK")
      CLOSE cq_prende
      RETURN FALSE
   END IF

END FUNCTION

#------------------------#
FUNCTION pol1308_update()#
#------------------------#

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT pol1308_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1308_prende_registro() THEN
      RETURN FALSE
   END IF
   
   CALL pol1308_ativa_desativa(TRUE)
      
   CALL _ADVPL_set_property(m_qtd_movto,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1308_update_confirm()#
#--------------------------------#
   
   DEFINE l_ret   SMALLINT
   
   LET l_ret = TRUE

   IF m_mot_retrab IS NOT NULL THEN
      LET m_mot_retrab = mr_campos.cod_motivo
   ELSE
      LET m_mot_refugo = mr_campos.cod_motivo
   END IF
   
   UPDATE man_apont_304
      SET qtd_movto = mr_campos.qtd_movto,
          dat_inicial = mr_campos.dat_ini,
          dat_final = mr_campos.dat_fim,
          hor_inicial = mr_campos.hor_ini,
          hor_final = mr_campos.hor_fim,
          cod_turno = mr_campos.cod_turno,
          motivo_retrab = m_mot_retrab,
          motivo_refugo = m_mot_refugo,
          integrado = 1
    WHERE cod_empresa = p_cod_empresa
      AND id_registro = m_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','man_apont_304')
      LET l_ret = FALSE
   ELSE
      IF NOT pol1308_del_erros() THEN
         LET l_ret = FALSE
      END IF
   END IF
         
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1308_ativa_desativa(FALSE)
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
   
END FUNCTION

#------------------------------#
FUNCTION pol1308_update_cancel()
#------------------------------#
    
    CALL pol1308_exibe_dados()
    CALL pol1308_ativa_desativa(FALSE)

    RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1308_delete()#
#------------------------#

   DEFINE l_ret   SMALLINT
   
   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluídos!")
      RETURN FALSE
   END IF

   IF NOT pol1308_ies_cons() THEN
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1308_prende_registro() THEN
      RETURN FALSE
   END IF

   LET l_ret = TRUE

   DELETE FROM man_apont_304
    WHERE cod_empresa = p_cod_empresa
      AND id_registro = m_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','man_apont_304')
      LET l_ret = FALSE
   ELSE
      IF NOT pol1308_del_erros() THEN
         LET l_ret = FALSE
      END IF
   END IF
               
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL _ADVPL_set_property(m_browse,"CLEAR")
      CALL pol1308_limpa_campos()
      LET m_excluiu = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret

END FUNCTION

#---------------------------#
FUNCTION pol1308_del_erros()#
#---------------------------#

   DELETE FROM APONT_ERRO_912
    WHERE cod_empresa = p_cod_empresa
      AND id_man_apont = m_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','APONT_ERRO_912')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION
