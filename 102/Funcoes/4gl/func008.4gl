
#-------------------------------------------------------------#
#------------------zoom da tabela linha_prod------------------#
#-------------------------------------------------------------#
# Retorno: códigos concatenados e a descrição                 #
#-------------------------------------------------------------#

DATABASE logix

DEFINE m_lin_pord        DECIMAL(2,0),
       m_lin_recei       DECIMAL(2,0),
       m_seg_merc        DECIMAL(2,0),
       m_cla_uso         DECIMAL(2,0),
       m_codigo          CHAR(08),
       m_qtd_aen         INTEGER,
       m_msg             CHAR(150)

DEFINE m_descricao       LIKE linha_prod.den_estr_linprod

DEFINE ma_linha          ARRAY[20000] OF RECORD
       cod_linha         CHAR(08),
       descricao         CHAR(30)
END RECORD

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_browse          VARCHAR(10)

#---------------------------------#
FUNCTION func008_zoom_area_linha()#
#---------------------------------#

    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","PESQUISA DE ÁREA E LINHA")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","linha_prod","AEN")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","linha_prod","cod_lin_prod","Linha produto",1 {INT},2,0)        	       
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","linha_prod","cod_lin_recei","Linha receita",1 {INT},2,0)        	       
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","linha_prod","cod_seg_merc","Seg. mercado",1 {INT},2,0)        	       
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","linha_prod","cod_cla_uso","Classe de uso",1 {INT},2,0)        	       
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","linha_prod","den_estr_linprod","Descrição",1 {CHAR},30,0)        	       
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF  l_status THEN
        LET l_where_clause = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_construct,"ORDER_BY")
        CALL func008_le_linhas(l_where_clause,l_order_by)
    END IF
    
    RETURN m_codigo, m_descricao
            
END FUNCTION

#----------------------------------------------------#
FUNCTION func008_le_linhas(l_where_clause,l_order_by)#
#----------------------------------------------------#
 
   DEFINE l_where_clause CHAR(800),
          l_order_by     CHAR(200),
          l_sql_stmt     CHAR(2000),
          l_ind          INTEGER,
          l_descricao    CHAR(30)

    IF  l_order_by IS NULL THEN
        LET l_order_by = " den_estr_linprod"
    END IF

   LET l_sql_stmt = "SELECT cod_lin_prod, cod_lin_recei, cod_seg_merc, ",
                    " cod_cla_uso, den_estr_linprod ",
                     " FROM linha_prod ",
                    " WHERE ", l_where_clause CLIPPED,
                    " ORDER BY ", l_order_by

   PREPARE var_aen FROM l_sql_stmt
    
   IF  Status <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","var_aen")
       RETURN 
   END IF

   DECLARE cq_aen CURSOR FOR var_aen

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE CURSOR","cq_aen")
       RETURN 
   END IF
   
   LET l_ind = 1
   INITIALIZE ma_linha TO NULL
   
   FOREACH cq_aen INTO 
      m_lin_pord, m_lin_recei, m_seg_merc,
      m_cla_uso, l_descricao
   
      IF  STATUS <> 0 THEN
          CALL log003_err_sql("FOREACH","cq_aen")
          RETURN 
      END IF
       
      LET ma_linha[l_ind].cod_linha = func002_strzero(m_lin_pord, 2),
          func002_strzero(m_lin_recei, 2), func002_strzero(m_seg_merc, 2),
          func002_strzero(m_cla_uso, 2)
      LET ma_linha[l_ind].descricao = l_descricao
      
      LET l_ind = l_ind + 1

      IF l_ind > 20000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF l_ind = 1 THEN
      LET m_msg = 'Não a dados, para os argumentos informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN
   END IF
   
   LET m_qtd_aen = l_ind - 1
   
   CALL func008_mostra_aens()
   
END FUNCTION

#-----------------------------#
FUNCTION func008_mostra_aens()#
#-----------------------------#

   DEFINE l_menubar     VARCHAR(10),
          l_panel       VARCHAR(10),
          l_select      VARCHAR(10),
          l_cancel      VARCHAR(10)

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",800,450)
    CALL _ADVPL_set_property(m_dialog,"TITLE","SELEÇÃO DE AEN")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL func008_grade_aen(l_panel)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) #vermelho,verde,azul
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   #FIND_EX / QUIT_EX / CONFIRM_EX / UPDATE_EX / RUN_EX / NEW_EX
   #CANCEL_EX / DELETE_EX / LANCAMENTOS_EX / ESTORNO_EX / SAVEPROFILE
   LET l_select = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_select,"IMAGE","CONFIRM_EX")
   CALL _ADVPL_set_property(l_select,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_select,"EVENT","func008_seleciona")     

   LET l_cancel = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancel,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancel,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancel,"EVENT","func008_descarta")     

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)


END FUNCTION

#--------------------------------------#
FUNCTION func008_grade_aen(l_container)#
#--------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",200,190,230)
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 

    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")    
    CALL _ADVPL_set_property(m_browse,"BEFORE_ROW_EVENT","func008_row_aen")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Código")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_linha")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","descricao")
    
    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_linha,m_qtd_aen)

END FUNCTION

#-------------------------#
FUNCTION func008_row_aen()#
#-------------------------#

   DEFINE l_lin_atu       SMALLINT
      
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN
      LET m_codigo = ma_linha[l_lin_atu].cod_linha
      LET m_descricao = ma_linha[l_lin_atu].descricao
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION func008_seleciona()#
#---------------------------#

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION func008_descarta()#
#--------------------------#

   INITIALIZE m_codigo, m_descricao TO NULL
   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION
