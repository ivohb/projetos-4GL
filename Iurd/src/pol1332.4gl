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

DEFINE m_despesa       VARCHAR(10),
       m_descricao       VARCHAR(10),
       m_operacao        VARCHAR(10),
       m_produto         VARCHAR(10)

DEFINE m_lupa_operacao   VARCHAR(10),
       m_zoom_operacao   VARCHAR(10),
       m_lupa_produto    VARCHAR(10),       
       m_zoom_item       VARCHAR(10),
       m_lupa_despesa    VARCHAR(10),       
       m_zoom_despesa    VARCHAR(10),
       m_construct       VARCHAR(10)
       
DEFINE mr_campos         RECORD
   tip_obrigacao         INTEGER,       
   den_parametro         VARCHAR(100),
   cod_operacao          CHAR(07),  
   den_operacao          CHAR(40),    
   cod_item              CHAR(15),
   den_item              CHAR(76)     
END RECORD

DEFINE m_tipo_obrigacao   INTEGER,
       m_tipo_obrigacaoa  INTEGER
       
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

   LET p_versao = "pol1332-12.00.03  "
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
           l_titulo    VARCHAR(100) 
    
    LET l_titulo = 'PAR�METROS POR TIPO DE DESPESA - GI IMOVEL'
    
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

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#------------------------------------#
FUNCTION pol1332_cria_campos(l_panel)#
#------------------------------------#
    
   DEFINE l_panel         VARCHAR(10),
          l_label         VARCHAR(10),
          l_den_operacao  VARCHAR(10),
          l_den_item      VARCHAR(10)
    
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
   CALL _ADVPL_set_property(l_label,"TEXT","C�d CFOP:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

   LET m_operacao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
   CALL _ADVPL_set_property(m_operacao,"POSITION",110,80)
   CALL _ADVPL_set_property(m_operacao,"LENGTH",15)
   CALL _ADVPL_set_property(m_operacao,"EDITABLE",TRUE) 
   CALL _ADVPL_set_property(m_operacao,"VARIABLE",mr_campos,"cod_operacao")
   CALL _ADVPL_set_property(m_operacao,"PICTURE","@E!")
   CALL _ADVPL_set_property(m_operacao,"VALID","pol1332_valida_operacao")

   LET m_lupa_operacao = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
   CALL _ADVPL_set_property(m_lupa_operacao,"POSITION",250,80)
   CALL _ADVPL_set_property(m_lupa_operacao,"IMAGE","BTPESQ")
   CALL _ADVPL_set_property(m_lupa_operacao,"SIZE",24,20)
   CALL _ADVPL_set_property(m_lupa_operacao,"CLICK_EVENT","pol1332_zoom_operacao")

   LET l_den_operacao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
   CALL _ADVPL_set_property(l_den_operacao,"POSITION",280,80)
   CALL _ADVPL_set_property(l_den_operacao,"LENGTH",40)
   CALL _ADVPL_set_property(l_den_operacao,"EDITABLE",FALSE) 
   CALL _ADVPL_set_property(l_den_operacao,"CAN_GOT_FOCUS",FALSE)
   CALL _ADVPL_set_property(l_den_operacao,"VARIABLE",mr_campos,"den_operacao")

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
   
   CALL pol1332_ativa_desativa(FALSE)

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
   CALL _ADVPL_set_property(m_operacao,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_operacao,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_produto,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_produto,"EDITABLE",l_status)
   

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
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","gi_param_ar_912","cod_tipo_obrigacao","Obrigacao",1 {INT},9,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","gi_param_ar_912","den_parametro","Descri��o",1 {CHAR},40,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","gi_param_ar_912","cod_item","Produto",1 {CHAR},15,0,"zoom_item")
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

   SELECT *
     INTO mr_campos.tip_obrigacao,
          mr_campos.den_parametro,
          mr_campos.cod_operacao,
          mr_campos.cod_item
    FROM gi_param_ar_912
   WHERE cod_tipo_obrigacao = m_tipo_obrigacao

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql('SELECT','gi_param_ar_912:ED',0)
      RETURN FALSE 
   END IF
         
   CALL pol1332_le_operacao(mr_campos.cod_operacao) RETURNING p_status

   CALL pol1332_le_item(mr_campos.cod_item) RETURNING p_status
      
   RETURN p_status

END FUNCTION

#---------------------------------#
FUNCTION pol1332_valida_operacao()#
#---------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_campos.cod_operacao IS NOT NULL THEN
      IF NOT pol1332_le_operacao(mr_campos.cod_operacao) THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      END IF
   END IF
   
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
         

#-------------------------------------#
FUNCTION pol1332_le_operacao(l_codigo)#
#-------------------------------------#

   DEFINE l_codigo LIKE cod_fiscal_sup.cod_fiscal 
   
   LET m_msg = ''
   LET mr_campos.den_operacao = ''
   
   SELECT den_cod_fiscal
     INTO mr_campos.den_operacao
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

#-----------------------#
FUNCTION pol1332_create()
#-----------------------#
    
    LET m_opcao = 'I'    
    INITIALIZE mr_campos.* TO NULL
    CALL pol1332_ativa_desativa(TRUE)
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

   IF mr_campos.tip_obrigacao IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
         "Informe o tipo de obriga��o")
      CALL _ADVPL_set_property(m_despesa,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_campos.den_parametro IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
         "Informe a descri��o da obriga��o")
      CALL _ADVPL_set_property(m_descricao,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_campos.cod_operacao IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
         "Informe o c�digo da opera��o")
      CALL _ADVPL_set_property(m_operacao,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_campos.cod_item IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
         "Informe o c�digo do produto")
      CALL _ADVPL_set_property(m_produto,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF NOT pol1332_le_operacao(mr_campos.cod_operacao)  THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_operacao,"GET_FOCUS")
      RETURN FALSE
   END IF
         
   IF NOT pol1332_le_item(mr_campos.cod_item)  THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_produto,"GET_FOCUS")
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

#------------------------------#
FUNCTION pol1332_ins_registro()#
#------------------------------#

   INSERT INTO gi_param_ar_912
    VALUES(mr_campos.tip_obrigacao,
           mr_campos.den_parametro,
           mr_campos.cod_operacao, 
           mr_campos.cod_item)     

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql('INSERT','gi_param_ar_912',0)
      RETURN FALSE
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

#-------------------------------#
FUNCTION pol1332_zoom_operacao()#
#-------------------------------#
    
   DEFINE l_codi            LIKE cod_fiscal_sup.cod_fiscal,
          l_desc            LIKE cod_fiscal_sup.den_cod_fiscal,
          l_where_clause    CHAR(300)
          
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
      LET mr_campos.cod_operacao = l_codi
      LET mr_campos.den_operacao = l_desc
   END IF
    
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
   CALL _ADVPL_set_property(m_descricao,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1332_update_yes()#
#----------------------------#
   
   UPDATE gi_param_ar_912
      SET den_parametro = mr_campos.den_parametro,
          cod_operacao = mr_campos.cod_operacao,
          cod_item = mr_campos.cod_item
    WHERE cod_tipo_obrigacao = m_tipo_obrigacao
   
   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql('UPDATE','gi_param_ar_912',0)
      CALL LOG_transaction_rollback()
      CLOSE cq_prende
      RETURN FALSE
   END IF
   
   CLOSE cq_prende
   
   LET m_opcao = NULL
   
   CALL pol1332_ativa_desativa(FALSE)
   
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
   
   CALL LOG_transaction_commit()
      
   LET m_excluiu = TRUE
   INITIALIZE mr_campos.* TO NULL
         
   CLOSE cq_prende
   
   RETURN TRUE
        
END FUNCTION
