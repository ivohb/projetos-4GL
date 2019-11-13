#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1366                                                 #
# OBJETIVO: APONTAMENTOS NEST - ERROS DE INTEGRAÇÃO                 #
# AUTOR...: IVO                                                     #
# DATA....: 25/02/19                                                #
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

DEFINE m_num_prog        VARCHAR(50),
       m_num_proga       VARCHAR(50)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_id_registro     INTEGER,
       m_ind             INTEGER
       
DEFINE mr_campos         RECORD
       cod_empresa       CHAR(50),
       num_programa      CHAR(50),
       dat_integracao    CHAR(19)
END RECORD

DEFINE mr_rodape         RECORD
 dat_exec                char(19),
 mensagem                char(150)
END RECORD


DEFINE ma_erro           ARRAY[1000] OF RECORD
       num_ordem         DECIMAL(8,0),
       cod_operac        CHAR(05),
       den_operac        CHAR(18),       
       cod_item          CHAR(15),
       den_item          CHAR(18),
       qtd_item          DECIMAL(10,3),
       cod_compon        CHAR(15),
       den_compon        CHAR(18),
       qtd_compon        DECIMAL(10,3),
       den_critica       CHAR(150),
       id_registro       INTEGER
END RECORD

#-----------------#
FUNCTION pol1366()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1366-12.00.00  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1366_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1366_menu()#
#----------------------#

    DEFINE l_menubar,
           l_panel,
           l_find,
           l_first,
           l_previous,
           l_next,
           l_last,
           l_titulo  VARCHAR(50)

    LET l_titulo = 'APONTAMENTOS NEST - ERROS DE INTEGRAÇÃO'
    
    CALL pol1366_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)
    
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1366_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1366_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1366_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1366_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1366_last")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1366_cria_cabec(l_panel)
    CALL pol1366_cria_rodape(l_panel)
    CALL pol1366_grade_erro(l_panel)

    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1366_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
   INITIALIZE ma_erro TO NULL
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1366_cria_cabec(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_num_prog        VARCHAR(10),
           l_cod_emprea      VARCHAR(10),
           l_dat_integ       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",30)
    CALL _ADVPL_set_property(l_panel,"EDITABLE",FALSE) 
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",8)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    

    LET l_cod_emprea = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_cod_emprea,"VARIABLE",mr_campos,"cod_empresa")
    CALL _ADVPL_set_property(l_cod_emprea,"LENGTH",2,0)
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Programa:")    

    LET l_num_prog = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_num_prog,"VARIABLE",mr_campos,"num_programa")
    CALL _ADVPL_set_property(l_num_prog,"LENGTH",30,0)
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Integração:")    

    LET l_dat_integ = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_dat_integ,"VARIABLE",mr_campos,"dat_integracao")
    CALL _ADVPL_set_property(l_dat_integ,"LENGTH",20,0)
    

END FUNCTION

#---------------------------------------#
FUNCTION pol1366_grade_erro(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ordem")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Oper")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_operac")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_operac")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Produto")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd apont")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Componente")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd baixar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_critica")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_erro,1)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1366_cria_rodape(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_num_prog        VARCHAR(10),
           l_cod_emprea      VARCHAR(10),
           l_dat_integ       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",30)
    CALL _ADVPL_set_property(l_panel,"EDITABLE",FALSE) 
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",5)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Última integração:")    

    LET l_cod_emprea = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_cod_emprea,"VARIABLE",mr_rodape,"dat_exec")
    CALL _ADVPL_set_property(l_cod_emprea,"LENGTH",19,0)
    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Resultado:")    

    LET l_num_prog = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_num_prog,"VARIABLE",mr_rodape,"mensagem")
    CALL _ADVPL_set_property(l_num_prog,"LENGTH",110,0)
        

END FUNCTION

#----------------------#
FUNCTION pol1366_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1366_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","man_apo_nest_405","apont")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","man_apo_nest_405","num_programa","Programa",1 {CHAR},30,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","man_apo_nest_405","num_ordem","Ordem",1 {INT},10,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","man_apo_nest_405","cod_operac","Operação",1 {CHAR},5,0,"zoom_operacao")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","man_apo_nest_405","cod_item","Item",1 {CHAR},15,0,"zoom_item")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","man_apo_nest_405","cod_item_compon","Compon",1 {CHAR},15,0,"zoom_item")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1366_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1366_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    SELECT dat_exec, mensagem 
      INTO mr_rodape.dat_exec, mr_rodape.mensagem
      FROM exec_proces_405
     WHERE cod_empresa = p_cod_empresa
       AND id_registro = (
            SELECT MAX(id_registro) 
              FROM exec_proces_405 
             WHERE cod_empresa = p_cod_empresa)
    
    IF STATUS = 100 THEN
       INITIALIZE mr_rodape.* TO NULL
    ELSE
       IF STATUS <> 0 THEN
          CALL log003_err_sql('SELECT','exec_proces_405')
       END IF
    END IF

    IF l_order IS NULL THEN
       LET l_order = " num_programa "
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT DISTINCT num_programa ",
                      " FROM man_apo_nest_405 ",
                     " WHERE ",l_where CLIPPED,
                      " AND tip_registro = 'C' ",
                       " AND cod_empresa = '",p_cod_empresa,"' ",
                     " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","man_apo_nest_405")
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

    FETCH cq_cons INTO m_num_prog

    IF STATUS <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","cq_cons")
       ELSE
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Argumentos de pesquisa não encontrados.")
       END IF
       CALL pol1366_limpa_campos()
       RETURN FALSE
    END IF
    
    CALL pol1366_exibe_dados() 
    
    LET m_ies_cons = TRUE
    LET m_num_proga = m_num_prog
        
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1366_exibe_dados()#
#-----------------------------#
   
   INITIALIZE ma_erro TO NULL   
   INITIALIZE mr_campos.* TO NULL
   
   LET m_ind = 1
   
   LET mr_campos.cod_empresa = p_cod_empresa
   LET mr_campos.num_programa = m_num_prog
   
   DECLARE cq_erros	CURSOR FOR
    SELECT a.dat_integracao, a.num_ordem, a.cod_operac,
           a.cod_item, a.cod_item_compon, a.qtd_produzida,
           a.pes_unit, e.den_critica, o.den_operac,
           a.id_registro
      FROM man_apo_nest_405 a, man_erro_405 e, operacao o
     WHERE a.cod_empresa = p_cod_empresa
       AND a.num_programa = m_num_prog
       AND a.tip_registro = 'C'
       AND e.cod_empresa = a.cod_empresa
       AND e.num_programa = a.num_programa
       AND a.num_ordem = e.num_ordem
       AND o.cod_empresa = a.cod_empresa
       AND o.cod_operac = a.cod_operac
   
    FOREACH cq_erros INTO mr_campos.dat_integracao,
       ma_erro[m_ind].num_ordem,
       ma_erro[m_ind].cod_operac,
       ma_erro[m_ind].cod_item,
       ma_erro[m_ind].cod_compon,
       ma_erro[m_ind].qtd_item,
       ma_erro[m_ind].qtd_compon,
       ma_erro[m_ind].den_critica,
       ma_erro[m_ind].den_operac,
       m_id_registro

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','APONT_ERRO_912:cq_erros')
         RETURN FALSE
      END IF          

      LET ma_erro[m_ind].den_item = func002_le_den_item(ma_erro[m_ind].cod_item)
      LET ma_erro[m_ind].den_compon = func002_le_den_item(ma_erro[m_ind].cod_compon)
      
      LET ma_erro[m_ind].id_registro =  m_id_registro
      LET m_ind = m_ind + 1
      
      IF m_ind > 1000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.\n',
                     'Somente 1000 registros serão exibidos.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH

   FREE cq_erros

   IF m_ind = 1 THEN
      LET m_msg = 'Não foi possivel ler as mensagens de erro'
   ELSE
      CALL _ADVPL_set_property(m_browse,"ITEM_COUNT",m_ind - 1)
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol1366_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1366_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1366_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_num_proga = m_num_prog

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_num_prog
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_num_prog
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_num_prog
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_num_prog
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_num_prog = m_num_proga
         EXIT WHILE
      ELSE
         SELECT DISTINCT num_programa
           FROM man_apo_nest_405 
          WHERE cod_empresa =  p_cod_empresa
            AND num_programa = m_num_prog
            AND tip_registro = 'C'
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1366_exibe_dados()
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
FUNCTION pol1366_first()#
#-----------------------#

   IF NOT pol1366_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1366_next()#
#----------------------#

   IF NOT pol1366_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1366_previous()#
#--------------------------#

   IF NOT pol1366_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1366_last()#
#----------------------#

   IF NOT pol1366_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
