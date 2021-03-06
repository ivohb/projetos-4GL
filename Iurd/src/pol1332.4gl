#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1332                                                 #
# OBJETIVO: PAR�METROS POR TIPO DE DESPESA - GI IMOVEL              #
# AUTOR...: IVO                                                     #
# DATA....: 12/09/17                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_menubar         VARCHAR(10),
       m_statusbar       VARCHAR(10)
                     

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_ind             INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_ies_inc         SMALLINT,
       m_excluiu         SMALLINT,
       m_opcao           CHAR(01),
       m_den_empresa     CHAR(36)

DEFINE m_despesa         VARCHAR(10),
       m_descricao       VARCHAR(10),
       m_especie         VARCHAR(10),
       m_operacao        VARCHAR(10),
       m_cnd_pgto        VARCHAR(10),
       m_produto         VARCHAR(10)

DEFINE m_lupa_operacao   VARCHAR(10),
       m_zoom_operacao   VARCHAR(10),
       m_lupa_produto    VARCHAR(10),       
       m_zoom_item       VARCHAR(10),
       m_lupa_despesa    VARCHAR(10),       
       m_zoom_despesa    VARCHAR(10),
       m_lupa_cnd        VARCHAR(10),
       m_zoom_cnd        VARCHAR(10),
       m_zoom_funcio     VARCHAR(10),
       m_construct       VARCHAR(10),
       m_browse          VARCHAR(10),
       m_funcio          VARCHAR(10),
       m_lupa_funcio     VARCHAR(10)
       
DEFINE mr_campos         RECORD
   tip_obrigacao         INTEGER,       
   den_parametro         VARCHAR(100),
   especie_nf            CHAR(03),
   cod_item              CHAR(15),
   den_item              CHAR(76),
   cnd_pgto              DECIMAL(4,0),
   den_cnd_pgto          CHAR(30),
   cod_uni_funcio        CHAR(10),
   den_uni_funcio        CHAR(30)
END RECORD

DEFINE m_tipo_obrigacao   INTEGER,
       m_tipo_obrigacaoa  INTEGER

DEFINE ma_cfop            ARRAY[100] OF RECORD
       cod_cfop           CHAR(05),
       den_cfop           VARCHAR(40)
END RECORD
       
#-----------------#
FUNCTION pol1332()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 11

   LET p_versao = "pol1332-12.00.08  "
   CALL func002_versao_prg(p_versao)
   
   CALL pol1332_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1332_menu()#
#----------------------#

    DEFINE l_create,
           l_find, 
           l_update,
           l_first,
           l_previous,
           l_next,
           l_last,
           l_delete VARCHAR(10)

    DEFINE l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_titulo    VARCHAR(120) 
    
    LET l_titulo = 'PAR�METROS POR TIPO DE DESPESA - GI IMOVEL: ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1332_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1332_create_yes")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1332_create_no")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1332_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1332_update_yes")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1332_update_no")
    
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1332_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1332_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1332_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1332_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1332_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1332_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1332_cria_campos(l_panel)
    CALL pol1332_cria_grade(l_panel)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1332_cria_campos(l_container)#
#----------------------------------------#
    
   DEFINE l_container     VARCHAR(10),
          l_panel         VARCHAR(10),
          l_label         VARCHAR(10),
          l_den_item      VARCHAR(10),
          l_den_cnd       VARCHAR(10),
          l_den_funcio    VARCHAR(10)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
   CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
   CALL _ADVPL_set_property(l_panel,"HEIGHT",200)
   CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)
    
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
   CALL _ADVPL_set_property(l_label,"POSITION",30,20)
   CALL _ADVPL_set_property(l_label,"TEXT","Obrigacao:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

   LET m_despesa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
   CALL _ADVPL_set_property(m_despesa,"POSITION",110,20)
   CALL _ADVPL_set_property(m_despesa,"LENGTH",4)
   CALL _ADVPL_set_property(m_despesa,"EDITABLE",TRUE) 
   CALL _ADVPL_set_property(m_despesa,"VARIABLE",mr_campos,"tip_obrigacao")
   CALL _ADVPL_set_property(m_despesa,"PICTURE","@E ####")
   CALL _ADVPL_set_property(m_despesa,"VALID","pol1332_valida_obrigacao")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
   CALL _ADVPL_set_property(l_label,"POSITION",30,50)
   CALL _ADVPL_set_property(l_label,"TEXT","Descri��o:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

   LET m_descricao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
   CALL _ADVPL_set_property(m_descricao,"POSITION",110,50)
   CALL _ADVPL_set_property(m_descricao,"LENGTH",50)
   CALL _ADVPL_set_property(m_descricao,"EDITABLE",TRUE) 
   CALL _ADVPL_set_property(m_descricao,"VARIABLE",mr_campos,"den_parametro")
   CALL _ADVPL_set_property(m_descricao,"PICTURE","@E!")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
   CALL _ADVPL_set_property(l_label,"POSITION",30,80)
   CALL _ADVPL_set_property(l_label,"TEXT","Espcie NF:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

   LET m_especie = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
   CALL _ADVPL_set_property(m_especie,"POSITION",110,80)
   CALL _ADVPL_set_property(m_especie,"LENGTH",15)
   CALL _ADVPL_set_property(m_especie,"EDITABLE",TRUE) 
   CALL _ADVPL_set_property(m_especie,"VARIABLE",mr_campos,"especie_nf")
   CALL _ADVPL_set_property(m_especie,"PICTURE","@E!")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
   CALL _ADVPL_set_property(l_label,"POSITION",35,110)
   CALL _ADVPL_set_property(l_label,"TEXT","Produto:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

   LET m_produto = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
   CALL _ADVPL_set_property(m_produto,"POSITION",110,110)
   CALL _ADVPL_set_property(m_produto,"LENGTH",15)
   CALL _ADVPL_set_property(m_produto,"EDITABLE",TRUE) 
   CALL _ADVPL_set_property(m_produto,"VARIABLE",mr_campos,"cod_item")
   CALL _ADVPL_set_property(m_produto,"PICTURE","@E!")
   CALL _ADVPL_set_property(m_produto,"VALID","pol1332_valida_item")

   LET m_lupa_produto = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
   CALL _ADVPL_set_property(m_lupa_produto,"POSITION",250,110)
   CALL _ADVPL_set_property(m_lupa_produto,"IMAGE","BTPESQ")
   CALL _ADVPL_set_property(m_lupa_produto,"SIZE",24,20)
   CALL _ADVPL_set_property(m_lupa_produto,"CLICK_EVENT","pol1332_zoom_item")

   LET l_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
   CALL _ADVPL_set_property(l_den_item,"POSITION",280,110)
   CALL _ADVPL_set_property(l_den_item,"LENGTH",60)
   CALL _ADVPL_set_property(l_den_item,"EDITABLE",FALSE) 
   CALL _ADVPL_set_property(l_den_item,"CAN_GOT_FOCUS",FALSE)   
   CALL _ADVPL_set_property(l_den_item,"VARIABLE",mr_campos,"den_item")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
   CALL _ADVPL_set_property(l_label,"POSITION",35,140)
   CALL _ADVPL_set_property(l_label,"TEXT","Cnd. pgto:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

   LET m_cnd_pgto = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
   CALL _ADVPL_set_property(m_cnd_pgto,"POSITION",110,140)
   CALL _ADVPL_set_property(m_cnd_pgto,"LENGTH",15)
   CALL _ADVPL_set_property(m_cnd_pgto,"EDITABLE",TRUE) 
   CALL _ADVPL_set_property(m_cnd_pgto,"VARIABLE",mr_campos,"cnd_pgto")
   CALL _ADVPL_set_property(m_cnd_pgto,"PICTURE","####")
   CALL _ADVPL_set_property(m_cnd_pgto,"VALID","pol1332_valida_cnd_pgto")

   LET m_lupa_cnd = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
   CALL _ADVPL_set_property(m_lupa_cnd,"POSITION",250,140)
   CALL _ADVPL_set_property(m_lupa_cnd,"IMAGE","BTPESQ")
   CALL _ADVPL_set_property(m_lupa_cnd,"SIZE",24,20)
   CALL _ADVPL_set_property(m_lupa_cnd,"CLICK_EVENT","pol1332_zoom_cnd_pgto")

   LET l_den_cnd = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
   CALL _ADVPL_set_property(l_den_cnd,"POSITION",280,140)
   CALL _ADVPL_set_property(l_den_cnd,"LENGTH",60)
   CALL _ADVPL_set_property(l_den_cnd,"EDITABLE",FALSE) 
   CALL _ADVPL_set_property(l_den_cnd,"CAN_GOT_FOCUS",FALSE)   
   CALL _ADVPL_set_property(l_den_cnd,"VARIABLE",mr_campos,"den_cnd_pgto")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
   CALL _ADVPL_set_property(l_label,"POSITION",35,170)
   CALL _ADVPL_set_property(l_label,"TEXT","Unid funcional:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

   {LET m_funcio = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
   CALL _ADVPL_set_property(m_funcio,"POSITION",110,170)
   CALL _ADVPL_set_property(m_funcio,"LENGTH",15)
   CALL _ADVPL_set_property(m_funcio,"EDITABLE",TRUE) 
   CALL _ADVPL_set_property(m_funcio,"VARIABLE",mr_campos,"cod_uni_funcio")
   CALL _ADVPL_set_property(m_funcio,"PICTURE","@E!")
   CALL _ADVPL_set_property(m_funcio,"VALID","pol1332_valida_funcio")

   LET m_lupa_funcio = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
   CALL _ADVPL_set_property(m_lupa_funcio,"POSITION",250,170)
   CALL _ADVPL_set_property(m_lupa_funcio,"IMAGE","BTPESQ")
   CALL _ADVPL_set_property(m_lupa_funcio,"SIZE",24,20)
   CALL _ADVPL_set_property(m_lupa_funcio,"CLICK_EVENT","pol1332_zoom_funcio")

   LET l_den_funcio = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
   CALL _ADVPL_set_property(l_den_funcio,"POSITION",280,170)
   CALL _ADVPL_set_property(l_den_funcio,"LENGTH",60)
   CALL _ADVPL_set_property(l_den_funcio,"EDITABLE",FALSE) 
   CALL _ADVPL_set_property(l_den_funcio,"CAN_GOT_FOCUS",FALSE)   
   CALL _ADVPL_set_property(l_den_funcio,"VARIABLE",mr_campos,"den_uni_funcio")}
   
   CALL pol1332_ativa_desativa(FALSE)

END FUNCTION

#---------------------------------------#
FUNCTION pol1332_cria_grade(l_container)#
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
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CFOP")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cfop")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",5)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1332_valida_operacao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1332_zoom_operacao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",270)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_cfop")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_cfop,1)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

    
#----------------------------------------#
FUNCTION pol1332_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   IF m_opcao = 'M' THEN
      CALL _ADVPL_set_property(m_despesa,"EDITABLE",FALSE)
   ELSE
      CALL _ADVPL_set_property(m_despesa,"EDITABLE",l_status)
   END IF
   
   CALL _ADVPL_set_property(m_descricao,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_produto,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_produto,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_cnd_pgto,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_cnd,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_especie,"EDITABLE",l_status)
   #CALL _ADVPL_set_property(m_funcio,"EDITABLE",l_status)
   #CALL _ADVPL_set_property(m_lupa_funcio,"EDITABLE",l_status)
   

END FUNCTION

#----------------------#
FUNCTION pol1332_find()#
#----------------------#

    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)
    
    LET m_tipo_obrigacaoa = m_tipo_obrigacao
    
    CALL _ADVPL_cursor_wait()
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","PESQUISA DESPESAS")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","gi_param_ar_912","Obrigacao")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","gi_param_ar_912","cod_tipo_obrigacao","Obrigacao",1 {INT},4,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","gi_param_ar_912","den_parametro","Descri��o",1 {CHAR},40,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","gi_param_ar_912","cod_item","Produto",1 {CHAR},15,0,"zoom_item")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","gi_param_ar_912","especie_nf","Especie",1 {CHAR},3,0,"zoom_item")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","gi_param_ar_912","cnd_pgto","Cnd pgto",1 {INT},4,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")
    
    CALL _ADVPL_cursor_arrow()
    
    IF  l_status THEN
        LET l_where_clause = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_construct,"ORDER_BY")
        CALL pol1332_cria_cursor(l_where_clause,l_order_by)
    ELSE
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
    LET m_tipo_obrigacao = m_tipo_obrigacaoa
    
END FUNCTION

#------------------------------------------------------#
FUNCTION pol1332_cria_cursor(l_where_clause,l_order_by)#
#------------------------------------------------------#
 
   DEFINE l_where_clause CHAR(800)
   DEFINE l_order_by     CHAR(200)

   DEFINE l_sql_stmt     CHAR(2000)

    IF  l_order_by IS NULL THEN
        LET l_order_by = "cod_tipo_obrigacao"
    END IF

   LET l_sql_stmt = "SELECT * ",
                     " FROM gi_param_ar_912 ",
                    " WHERE ", l_where_clause CLIPPED,
                    " ORDER BY ", l_order_by

   PREPARE var_pesquisa FROM l_sql_stmt
    
   IF  Status <> 0 THEN
       CALL log0030_processa_err_sql("PREPARE SQL","var_pesquisa",0)
       RETURN 
   END IF

   DECLARE cq_cons SCROLL CURSOR WITH HOLD FOR var_pesquisa

   IF  Status <> 0 THEN
       CALL log0030_processa_err_sql("DECLARE CURSOR","cq_cons",0)
       RETURN 
   END IF

   FREE var_pesquisa

   OPEN cq_cons

   IF  STATUS <> 0 THEN
       CALL log0030_processa_err_sql("OPEN CURSOR","cq_cons",0)
       RETURN 
   END IF
   
   #LET m_ies_cons = FALSE
   
   FETCH cq_cons INTO m_tipo_obrigacao


   IF STATUS <> 0 THEN
      IF STATUS <> 100 THEN
         CALL log0030_processa_err_sql("FETCH CURSOR","cq_cons",0)
      ELSE
         LET m_msg = 'N�o a dados, para os argumentos informados.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN 
   END IF
      
    IF NOT pol1332_exibe_dados() THEN
       LET m_msg = 'Opera��o cancelada'
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN 
    END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
    
   LET m_ies_cons = TRUE
   LET m_ies_inc = FALSE
   
   LET m_tipo_obrigacaoa = m_tipo_obrigacao
   
END FUNCTION

#-----------------------------#
FUNCTION pol1332_exibe_dados()#
#-----------------------------#

   DEFINE l_prod, l_recei, l_merc, l_uso CHAR(02),
          l_id   INTEGER
   
   LET m_excluiu = FALSE
   
   INITIALIZE mr_campos.* TO NULL

   SELECT cod_tipo_obrigacao,
          den_parametro,     
          cod_item,          
          especie_nf,        
          cnd_pgto
          #cod_uni_funcio          
     INTO mr_campos.tip_obrigacao,
          mr_campos.den_parametro,
          mr_campos.cod_item,
          mr_campos.especie_nf,
          mr_campos.cnd_pgto
          #mr_campos.cod_uni_funcio
    FROM gi_param_ar_912
   WHERE cod_tipo_obrigacao = m_tipo_obrigacao

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql('SELECT','gi_param_ar_912:ED',0)
      RETURN FALSE 
   END IF
         
   CALL pol1332_le_item(mr_campos.cod_item) RETURNING p_status
   CALL pol1332_le_cond(mr_campos.cnd_pgto) RETURNING p_status
   #CALL pol1332_le_funcio (mr_campos.cod_uni_funcio) RETURNING p_status
   
   LET p_status = pol1332_carga_grade()
   
   RETURN p_status

END FUNCTION

#-----------------------------#
FUNCTION pol1332_carga_grade()#
#-----------------------------#
   
   INITIALIZE ma_cfop TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")    
   
   LET m_ind = 1
   
   DECLARE cq_grade CURSOR FOR
    SELECT a.cod_operacao, b.den_cod_fiscal
      FROM gi_param_cfop_912 a, cod_fiscal_sup b
     WHERE a.cod_tipo_obrigacao = m_tipo_obrigacao
       AND b.cod_fiscal = a.cod_operacao

   FOREACH cq_grade INTO ma_cfop[m_ind].*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','gi_param_cfop_912:cq_grade')
         EXIT FOREACH
      END IF
      
      LET m_ind = m_ind + 1
      
   END FOREACH
   
   IF m_ind > 1 THEN
      LET m_ind = m_ind - 1      
      CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_cfop,m_ind)
   ELSE
      CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_cfop,1)
   END IF
   
   CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
   
   RETURN TRUE
   
END FUNCTION
    
#-----------------------------#
FUNCTION pol1332_valida_item()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   IF mr_campos.cod_item IS NOT NULL THEN
      IF NOT pol1332_le_item(mr_campos.cod_item) THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION   
         
#---------------------------------#
FUNCTION pol1332_valida_cnd_pgto()#
#---------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   IF mr_campos.cnd_pgto IS NOT NULL THEN
      IF NOT pol1332_le_cond(mr_campos.cnd_pgto) THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION   

#-------------------------------------#
FUNCTION pol1332_le_item(l_codigo)#
#-------------------------------------#

   DEFINE l_codigo    LIKE item.cod_item,
          l_situacao  CHAR(01)
   
   LET m_msg = ''
   LET mr_campos.den_item = ''
   
   SELECT den_item, ies_situacao
     INTO mr_campos.den_item, l_situacao
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_codigo

   IF STATUS = 0 THEN
      IF l_situacao = 'A' THEN
         RETURN TRUE
      END IF
      LET m_msg = 'Item inativo.'    
   ELSE
      IF STATUS = 100 THEN
         LET m_msg = 'Produto inexistente no Logix.'    
      ELSE
         CALL log0030_processa_err_sql('SELECT','item',0)
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#---------------------------------#
FUNCTION pol1332_le_cond(l_codigo)#
#---------------------------------#

   DEFINE l_codigo LIKE cond_pgto.cod_cnd_pgto 
   
   LET m_msg = ''
   LET mr_campos.den_cnd_pgto = ''
   
   IF l_codigo IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT den_cnd_pgto
     INTO mr_campos.den_cnd_pgto
     FROM cond_pgto
    WHERE cod_cnd_pgto = l_codigo

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 100 THEN
         LET m_msg = 'Condi��o de pagamento inexistente no Logix.'    
      ELSE
         CALL log0030_processa_err_sql('SELECT','cond_pgto',0)
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#-----------------------#
FUNCTION pol1332_create()
#-----------------------#
    
    LET m_opcao = 'I'    
    INITIALIZE mr_campos.* TO NULL
    INITIALIZE ma_cfop TO NULL
    CALL pol1332_ativa_desativa(TRUE)
    CALL _ADVPL_set_property(m_browse,"CLEAR")
    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_cfop,1)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",TRUE)
    LET m_ies_inc = FALSE
    CALL _ADVPL_set_property(m_despesa,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#---------------------------#
FUNCTION pol1332_create_no()#
#---------------------------#

    CALL pol1332_ativa_desativa(FALSE)
    INITIALIZE mr_campos.* TO NULL
    LET m_opcao = NULL
    
    RETURN TRUE
        
END FUNCTION

#----------------------------#
FUNCTION pol1332_create_yes()#
#----------------------------#
   
    IF NOT pol1332_valida_campos() THEN
       RETURN FALSE
    END IF

    IF NOT pol1332_valida_itens() THEN
       RETURN FALSE
    END IF
            
   CALL LOG_transaction_begin()
   IF NOT pol1332_ins_registro() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()   
   CALL pol1332_ativa_desativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1332_valida_campos()#
#-------------------------------#

   DEFINE l_par_ies     CHAR(01)
   
   IF mr_campos.tip_obrigacao IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
         "Informe o tipo de obriga��o")
      CALL _ADVPL_set_property(m_despesa,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_campos.den_parametro IS NULL OR mr_campos.den_parametro = ' ' THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
         "Informe a descri��o da obriga��o")
      CALL _ADVPL_set_property(m_descricao,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_campos.especie_nf IS NULL OR mr_campos.especie_nf = ' ' THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
         "Informe a esp�cie da NF")
      CALL _ADVPL_set_property(m_especie,"GET_FOCUS")
      RETURN FALSE
   END IF
         
   IF mr_campos.cod_item IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
         "Informe o c�digo do produto")
      CALL _ADVPL_set_property(m_produto,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_campos.cnd_pgto IS NOT NULL THEN
      IF NOT pol1332_le_cond(mr_campos.cnd_pgto)  THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         CALL _ADVPL_set_property(m_produto,"GET_FOCUS")
         RETURN FALSE
      END IF
   END IF
         
   IF NOT pol1332_le_item(mr_campos.cod_item)  THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_produto,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1332_valida_itens()#
#------------------------------#
   
   DEFINE l_ok           SMALLINT,
          l_par_ies      CHAR(01)
   
   LET l_ok = FALSE
   
   LET m_count = _ADVPL_get_property(m_browse,"ITEM_COUNT")

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   FOR m_ind = 1 TO m_count
       
       IF ma_cfop[m_ind].cod_cfop IS NOT NULL THEN
          LET l_ok = TRUE
          EXIT FOR
       END IF
       
   END FOR
   
   IF NOT l_ok THEN
      IF mr_campos.especie_nf <> 'NFS' THEN   
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe pelo menos 1 CFOP")
         RETURN FALSE
      END IF

      SELECT par_ies 
        INTO l_par_ies
        FROM par_sup_pad
       WHERE cod_empresa = p_cod_empresa
         AND cod_parametro = 'cfop_nfs'
      IF STATUS = 0 THEN
         IF l_par_ies = 'S' THEN
            CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe pelo menos 1 CFOP")
            RETURN FALSE
         END IF
      END IF      
   END IF
   
   RETURN TRUE

END FUNCTION
   
#------------------------------#
FUNCTION pol1332_ins_registro()#
#------------------------------#
      
   INSERT INTO gi_param_ar_912(
      cod_tipo_obrigacao,
      den_parametro,     
      cod_operacao,
      cod_item,          
      especie_nf,        
      cnd_pgto)
      #cod_uni_funcio)             
    VALUES(mr_campos.tip_obrigacao,
           mr_campos.den_parametro,
           ' ',
           mr_campos.cod_item,
           mr_campos.especie_nf,
           mr_campos.cnd_pgto)
           #mr_campos.cod_uni_funcio)     

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql('INSERT','gi_param_ar_912',0)
      RETURN FALSE
   END IF
   
   IF NOT pol1332_ins_itens() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1332_ins_itens()#
#---------------------------#

   LET m_count = _ADVPL_get_property(m_browse,"ITEM_COUNT")

   FOR m_ind = 1 TO m_count
       IF ma_cfop[m_ind].cod_cfop IS NOT NULL THEN
         IF NOT pol1332_ins_cfop() THEN
            RETURN FALSE
         END IF
       END IF
   END FOR

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1332_ins_cfop()#
#--------------------------#
   
   SELECT 1 FROM gi_param_cfop_912
    WHERE cod_tipo_obrigacao = mr_campos.tip_obrigacao 
      AND cod_operacao = ma_cfop[m_ind].cod_cfop 
   
   IF STATUS = 100 THEN
      INSERT INTO gi_param_cfop_912
       VALUES(mr_campos.tip_obrigacao,
              ma_cfop[m_ind].cod_cfop)
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','gi_param_cfop_912')
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','gi_param_cfop_912')
         RETURN FALSE
      END IF      
   END IF
   
   RETURN TRUE
   
END FUNCTION
                 
#-----------------------------------#
FUNCTION pol1332_le_obrigacao(l_Cod)#
#-----------------------------------#
   
   DEFINE l_cod       INTEGER
   
   SELECT den_parametro 
     INTO mr_campos.den_parametro
     FROM gi_param_ar_912
    WHERE cod_tipo_obrigacao = l_cod

   IF STATUS <> 0 THEN
      LET mr_campos.den_parametro = ' '
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1332_valida_obrigacao()#
#-----------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", "")
   
   IF mr_campos.tip_obrigacao IS NULL THEN
      LET m_msg = 'Informe o tipo de obriga��o'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
   
   IF pol1332_le_obrigacao(mr_campos.tip_obrigacao) THEN
      LET m_msg = 'Obriga��o j� cadastrada'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION    

#---------------------------#
FUNCTION pol1332_zoom_item()#
#---------------------------#
    
   DEFINE l_item        LIKE item.cod_item,
          l_desc        LIKE item.den_item
          
   IF m_zoom_item IS NULL THEN
      LET m_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_zoom_item,"ZOOM","zoom_item")
   END IF

   CALL _ADVPL_get_property(m_zoom_item,"ACTIVATE")

   LET l_item = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")
   LET l_desc = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","den_item")

   IF l_item IS NOT NULL THEN
      LET mr_campos.cod_item = l_item
      LET mr_campos.den_item = l_desc
   END IF
    
END FUNCTION

#-------------------------------#
FUNCTION pol1332_zoom_cnd_pgto()#
#-------------------------------#
    
   DEFINE l_codi            LIKE cond_pgto.cod_cnd_pgto,
          l_desc            LIKE cond_pgto.den_cnd_pgto
          
   IF m_zoom_cnd IS NULL THEN
      LET m_zoom_cnd = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_zoom_cnd,"ZOOM","zoom_cond_pgto")
   END IF

   CALL _ADVPL_get_property(m_zoom_cnd,"ACTIVATE")

   LET l_codi = _ADVPL_get_property(m_zoom_cnd,"RETURN_BY_TABLE_COLUMN","cond_pgto","cod_cnd_pgto")
   LET l_desc = _ADVPL_get_property(m_zoom_cnd,"RETURN_BY_TABLE_COLUMN","cond_pgto","den_cnd_pgto")

   IF l_codi IS NOT NULL THEN
      LET mr_campos.cnd_pgto = l_codi
      LET mr_campos.den_cnd_pgto = l_desc
   END IF
    
END FUNCTION

#-------------------------------#
FUNCTION pol1332_zoom_operacao()#
#-------------------------------#
    
   DEFINE l_codi            LIKE cod_fiscal_sup.cod_fiscal,
          l_desc            LIKE cod_fiscal_sup.den_cod_fiscal,
          l_where_clause    CHAR(300),
          l_lin_atu         SMALLINT

          
   IF m_zoom_operacao IS NULL THEN
      LET m_zoom_operacao = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_zoom_operacao,"ZOOM","zoom_cod_fiscal_sup")
   END IF

   LET l_where_clause = " cod_fiscal_sup.cod_fiscal >= '5' "
   CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)

   CALL _ADVPL_get_property(m_zoom_operacao,"ACTIVATE")

   LET l_codi = _ADVPL_get_property(m_zoom_operacao,"RETURN_BY_TABLE_COLUMN","cod_fiscal_sup","cod_fiscal")
   LET l_desc = _ADVPL_get_property(m_zoom_operacao,"RETURN_BY_TABLE_COLUMN","cod_fiscal_sup","den_cod_fiscal")

   IF l_codi IS NOT NULL THEN
      LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
      IF l_lin_atu > 0 THEN
         LET ma_cfop[l_lin_atu].cod_cfop = l_codi
         CALL pol1332_le_operacao(l_codi, l_lin_atu) RETURN p_status
      END IF
   END IF
    
END FUNCTION

#---------------------------------#
FUNCTION pol1332_valida_operacao()#
#---------------------------------#
   
   DEFINE l_lin_atu         SMALLINT,
          l_cfop            CHAR(05)

   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
  
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   LET l_cfop = ma_cfop[l_lin_atu].cod_cfop CLIPPED
   
   IF l_cfop[1] = ' ' THEN
      LET l_cfop = NULL
   END IF
   
   LET ma_cfop[l_lin_atu].cod_cfop = l_cfop
      
   IF l_cfop IS NOT NULL THEN
      IF NOT pol1332_le_operacao(l_cfop, l_lin_atu) THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION   

#------------------------------------------------#
FUNCTION pol1332_le_operacao(l_codigo, l_lin_atu)#
#------------------------------------------------#

   DEFINE l_codigo LIKE cod_fiscal_sup.cod_fiscal,
          l_lin_atu       INTEGER
   
   LET m_msg = ''
   LET ma_cfop[l_lin_atu].den_cfop = ''
   
   SELECT den_cod_fiscal
     INTO ma_cfop[l_lin_atu].den_cfop
     FROM cod_fiscal_sup
    WHERE cod_fiscal = l_codigo

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 100 THEN
         LET m_msg = 'Opera��o inexistente no Logix.'    
      ELSE
         CALL log0030_processa_err_sql('SELECT','cod_fiscal_sup',0)
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#-------------------------------#
FUNCTION pol1332_valida_funcio()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   IF mr_campos.cod_uni_funcio IS NOT NULL THEN
      IF NOT pol1332_le_funcio(mr_campos.cod_uni_funcio) THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         CALL _ADVPL_set_property(m_funcio,"GET_FOCUS")
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION   

#-----------------------------------#
FUNCTION pol1332_le_funcio(l_codigo)#
#-----------------------------------#

   DEFINE l_codigo CHAR(15) 
   
   LET m_msg = ''
   LET mr_campos.den_uni_funcio = ''
   
   IF l_codigo IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT den_uni_funcio
     INTO mr_campos.den_uni_funcio
     FROM uni_funcional
    WHERE cod_empresa = p_cod_empresa
      AND cod_uni_funcio= l_codigo

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 100 THEN
         LET m_msg = 'Unidade funcional inexistente no Logix.'    
      ELSE
         CALL log0030_processa_err_sql('SELECT','uni_funcional',0)
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#-----------------------------#
FUNCTION pol1332_zoom_funcio()#
#-----------------------------#
    
   DEFINE l_codi            VARCHAR(15),
          l_desc            VARCHAR(80)
          
   IF m_zoom_funcio IS NULL THEN
      LET m_zoom_funcio = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_zoom_funcio,"ZOOM","zoom_uni_funcional")
   END IF

   CALL _ADVPL_get_property(m_zoom_funcio,"ACTIVATE")

   LET l_codi = _ADVPL_get_property(m_zoom_funcio,"RETURN_BY_TABLE_COLUMN","uni_funcional","cod_uni_funcio")
   LET l_desc = _ADVPL_get_property(m_zoom_funcio,"RETURN_BY_TABLE_COLUMN","uni_funcional","den_uni_funcio")

   IF l_codi IS NOT NULL THEN
      LET mr_campos.cod_uni_funcio = l_codi
      LET mr_campos.den_uni_funcio = l_desc
   END IF
    
END FUNCTION

#--------------------------#
FUNCTION pol1332_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'N�o h� consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1332_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1332_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_tipo_obrigacaoa = m_tipo_obrigacao

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_tipo_obrigacao
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_tipo_obrigacao
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_tipo_obrigacao
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_tipo_obrigacao
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","N�o existem mais registros nesta dire��o.")
         END IF
         LET m_tipo_obrigacao = m_tipo_obrigacaoa
         EXIT WHILE
      ELSE
         SELECT 1
           FROM gi_param_ar_912
          WHERE cod_tipo_obrigacao = m_tipo_obrigacao
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1332_exibe_dados()
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
FUNCTION pol1332_first()#
#-----------------------#

   IF NOT pol1332_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1332_next()#
#----------------------#

   IF NOT pol1332_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1332_previous()#
#--------------------------#

   IF NOT pol1332_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1332_last()#
#----------------------#

   IF NOT pol1332_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1332_prende_registro()#
#----------------------------------#
   
   CALL LOG_transaction_begin()
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM gi_param_ar_912
     WHERE cod_tipo_obrigacao = m_tipo_obrigacao
     FOR UPDATE 
    
    OPEN cq_prende

    IF STATUS <> 0 THEN
       CALL log0030_processa_err_sql ("OPEN CURSOR","cq_prende",0)
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
    
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log0030_processa_err_sql("FETCH CURSOR","cq_prende",0)
      CALL LOG_transaction_rollback()
      CLOSE cq_prende
      RETURN FALSE
   END IF

END FUNCTION

#------------------------#
FUNCTION pol1332_update()#
#------------------------#

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "N�o h� dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT m_ies_inc THEN
      IF NOT pol1332_ies_cons() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1332_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'M'    

   CALL pol1332_ativa_desativa(TRUE)
   CALL _ADVPL_set_property(m_browse,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_descricao,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1332_update_yes()#
#----------------------------#

    IF NOT pol1332_valida_campos() THEN
       RETURN FALSE
    END IF

   IF NOT pol1332_atu_tabs() THEN
      CALL LOG_transaction_rollback()
      CLOSE cq_prende
      RETURN FALSE
   END IF
            
   CALL LOG_transaction_commit()
   
   CLOSE cq_prende
   
   LET m_opcao = NULL
   
   CALL pol1332_ativa_desativa(FALSE)
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1332_atu_tabs()#
#--------------------------#

   UPDATE gi_param_ar_912
      SET den_parametro = mr_campos.den_parametro,
          cod_item = mr_campos.cod_item,
          especie_nf = mr_campos.especie_nf,
          cnd_pgto =  mr_campos.cnd_pgto
          #cod_uni_funcio = mr_campos.cod_uni_funcio
    WHERE cod_tipo_obrigacao = m_tipo_obrigacao
   
   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql('UPDATE','gi_param_ar_912',0)
      RETURN FALSE
   END IF
   
   DELETE FROM gi_param_cfop_912
    WHERE cod_tipo_obrigacao = m_tipo_obrigacao

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql('DELETE','gi_param_cfop_912',0)
      RETURN FALSE
   END IF
   
   IF NOT pol1332_ins_itens() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1332_update_no()#
#---------------------------#

   CALL LOG_transaction_rollback()
        
   CLOSE cq_prende
    
   LET m_tipo_obrigacao = m_tipo_obrigacaoa
   CALL pol1332_exibe_dados()
   CALL pol1332_ativa_desativa(FALSE)
   LET m_opcao = NULL
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1332_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "N�o h� dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT m_ies_inc THEN
      IF NOT pol1332_ies_cons() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT LOG_question("Confirma a exclus�o do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1332_prende_registro() THEN
      RETURN FALSE
   END IF

   DELETE FROM gi_param_ar_912
    WHERE cod_tipo_obrigacao = m_tipo_obrigacao

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql('DELETE','gi_param_ar_912',0)
      CALL LOG_transaction_rollback()
      CLOSE cq_prende
      RETURN FALSE
   END IF

   DELETE FROM gi_param_cfop_912
    WHERE cod_tipo_obrigacao = m_tipo_obrigacao

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql('DELETE','gi_param_cfop_912',0)
      CALL LOG_transaction_rollback()
      CLOSE cq_prende
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
      
   LET m_excluiu = TRUE
   INITIALIZE mr_campos.* TO NULL
   INITIALIZE ma_cfop TO NULL
   CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_cfop,1)
         
   CLOSE cq_prende
   
   RETURN TRUE
        
END FUNCTION
