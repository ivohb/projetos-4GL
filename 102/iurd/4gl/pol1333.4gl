#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1333                                                 #
# OBJETIVO: PARÂMETROS GERAIS - GI IMOVEL                           #
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

DEFINE m_parametro       VARCHAR(10),
       m_descricao       VARCHAR(10),
       m_tipo            VARCHAR(10),
       m_data            VARCHAR(10),
       m_decimal         VARCHAR(10),
       m_inteiro         VARCHAR(10),
       m_texto           VARCHAR(10),
       m_ativo           VARCHAR(10)

DEFINE m_construct       VARCHAR(10)
       
DEFINE mr_campos         RECORD
       cod_parametro     VARCHAR(60),            
       den_parametro     VARCHAR(100),           
       tip_dado          CHAR(1),                
       val_texto         VARCHAR(30),            
       val_data          DATE,                   
       val_valor         DECIMAL(15,2),          
       val_inteiro       INTEGER,                
       ies_ativo         CHAR(1)                
END RECORD

DEFINE m_cod_parametro   varchar(60),
       m_cod_parametroa  varchar(60)
       
#-----------------#
FUNCTION pol1333()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 11

   LET p_versao = "pol1333-12.00.00  "
   CALL func002_versao_prg(p_versao)
   
   CALL pol1333_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1333_menu()#
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
    
    LET l_titulo = 'PARÂMETROS GERAIS - GI IMOVEL'
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1333_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1333_create_yes")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1333_create_no")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1333_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1333_update_yes")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1333_update_no")
    
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1333_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1333_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1333_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1333_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1333_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1333_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1333_cria_campos(l_panel)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#------------------------------------#
FUNCTION pol1333_cria_campos(l_panel)#
#------------------------------------#
    
   DEFINE l_panel         VARCHAR(10),
          l_label         VARCHAR(10),
          l_den_parametro  VARCHAR(10),
          l_den_item      VARCHAR(10)
    
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
   CALL _ADVPL_set_property(l_label,"POSITION",30,20)
   CALL _ADVPL_set_property(l_label,"TEXT","Parâmetro:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

   LET m_parametro = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
   CALL _ADVPL_set_property(m_parametro,"POSITION",110,20)
   CALL _ADVPL_set_property(m_parametro,"LENGTH",60)
   CALL _ADVPL_set_property(m_parametro,"EDITABLE",TRUE) 
   CALL _ADVPL_set_property(m_parametro,"VARIABLE",mr_campos,"cod_parametro")
   CALL _ADVPL_set_property(m_parametro,"PICTURE","@!")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
   CALL _ADVPL_set_property(l_label,"POSITION",30,50)
   CALL _ADVPL_set_property(l_label,"TEXT","Descrição:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

   LET m_descricao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
   CALL _ADVPL_set_property(m_descricao,"POSITION",110,50)
   CALL _ADVPL_set_property(m_descricao,"LENGTH",100)
   CALL _ADVPL_set_property(m_descricao,"EDITABLE",TRUE) 
   CALL _ADVPL_set_property(m_descricao,"VARIABLE",mr_campos,"den_parametro")
   CALL _ADVPL_set_property(m_descricao,"PICTURE","@!")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
   CALL _ADVPL_set_property(l_label,"POSITION",30,80)
   CALL _ADVPL_set_property(l_label,"TEXT","Tip dado:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

   LET m_tipo = _ADVPL_create_component(NULL,"LCOMBOBOX",l_panel)
   CALL _ADVPL_set_property(m_tipo,"POSITION",110,80)
   CALL _ADVPL_set_property(m_tipo,"ADD_ITEM"," "," ")     
   CALL _ADVPL_set_property(m_tipo,"ADD_ITEM","D","Data")     
   CALL _ADVPL_set_property(m_tipo,"ADD_ITEM","N","Decimal")     
   CALL _ADVPL_set_property(m_tipo,"ADD_ITEM","I","Inteiro")     
   CALL _ADVPL_set_property(m_tipo,"ADD_ITEM","T","Texto")     
   CALL _ADVPL_set_property(m_tipo,"VARIABLE",mr_campos,"Tip_dado")
   CALL _ADVPL_set_property(m_tipo,"VALID","pol1333_ativa_campos")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
   CALL _ADVPL_set_property(l_label,"POSITION",30,110)
   CALL _ADVPL_set_property(l_label,"TEXT","Valor data:")    

   LET m_data = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel)
   CALL _ADVPL_set_property(m_data,"POSITION",110,110)
   CALL _ADVPL_set_property(m_data,"VARIABLE",mr_campos,"val_data")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
   CALL _ADVPL_set_property(l_label,"POSITION",30,140)
   CALL _ADVPL_set_property(l_label,"TEXT","Valor decimal:")    

   LET m_decimal = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
   CALL _ADVPL_set_property(m_decimal,"POSITION",110,140)     
   CALL _ADVPL_set_property(m_decimal,"VARIABLE",mr_campos,"val_valor")
   CALL _ADVPL_set_property(m_decimal,"LENGTH",15,2)
   CALL _ADVPL_set_property(m_decimal,"PICTURE","@E #############.##")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
   CALL _ADVPL_set_property(l_label,"POSITION",30,170)
   CALL _ADVPL_set_property(l_label,"TEXT","Valor inteiro:")    

   LET m_inteiro = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
   CALL _ADVPL_set_property(m_inteiro,"POSITION",110,170)     
   CALL _ADVPL_set_property(m_inteiro,"VARIABLE",mr_campos,"val_inteiro")
   CALL _ADVPL_set_property(m_inteiro,"LENGTH",10,0)
   CALL _ADVPL_set_property(m_inteiro,"PICTURE","@E ##########")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
   CALL _ADVPL_set_property(l_label,"POSITION",30,200)
   CALL _ADVPL_set_property(l_label,"TEXT","Valor texto:")    

   LET m_texto = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
   CALL _ADVPL_set_property(m_texto,"POSITION",110,200)
   CALL _ADVPL_set_property(m_texto,"LENGTH",30)
   CALL _ADVPL_set_property(m_texto,"EDITABLE",TRUE) 
   CALL _ADVPL_set_property(m_texto,"VARIABLE",mr_campos,"val_texto")
   CALL _ADVPL_set_property(m_texto,"PICTURE","@!")

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
   CALL _ADVPL_set_property(l_label,"POSITION",30,230)
   CALL _ADVPL_set_property(l_label,"TEXT","Ativo:")    
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

   LET m_ativo = _ADVPL_create_component(NULL,"LCHECKBOX",l_panel)
   CALL _ADVPL_set_property(m_ativo,"POSITION",110,230)
   CALL _ADVPL_set_property(m_ativo,"VARIABLE",mr_campos,"ies_ativo")
   CALL _ADVPL_set_property(m_ativo,"VALUE_CHECKED","S")     
   CALL _ADVPL_set_property(m_ativo,"VALUE_NCHECKED","N")     
   
   CALL pol1333_ativa_desativa(FALSE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1333_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   IF m_opcao = 'M' THEN
      CALL _ADVPL_set_property(m_parametro,"EDITABLE",FALSE)
   ELSE
      CALL _ADVPL_set_property(m_parametro,"EDITABLE",l_status)
   END IF
   
   CALL _ADVPL_set_property(m_descricao,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_tipo,"EDITABLE",l_status)   
   CALL _ADVPL_set_property(m_ativo,"EDITABLE",l_status)   
   CALL pol1333_desativa_campos()
   
END FUNCTION

#---------------------------------#
FUNCTION pol1333_desativa_campos()#
#---------------------------------#

   CALL _ADVPL_set_property(m_data,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_data,"CAN_GOT_FOCUS",FALSE)
   CALL _ADVPL_set_property(m_decimal,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_decimal,"CAN_GOT_FOCUS",FALSE)
   CALL _ADVPL_set_property(m_inteiro,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_inteiro,"CAN_GOT_FOCUS",FALSE)
   CALL _ADVPL_set_property(m_texto,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_texto,"CAN_GOT_FOCUS",FALSE)

END FUNCTION

#------------------------------#
FUNCTION pol1333_ativa_campos()#
#------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   CASE mr_campos.tip_dado
      WHEN 'D'
         CALL _ADVPL_set_property(m_data,"EDITABLE",TRUE)
         CALL _ADVPL_set_property(m_data,"CAN_GOT_FOCUS",TRUE)
      WHEN 'N'
         CALL _ADVPL_set_property(m_decimal,"EDITABLE",TRUE)
         CALL _ADVPL_set_property(m_decimal,"CAN_GOT_FOCUS",TRUE)
      WHEN 'I'
         CALL _ADVPL_set_property(m_inteiro,"EDITABLE",TRUE)
         CALL _ADVPL_set_property(m_inteiro,"CAN_GOT_FOCUS",TRUE)
      WHEN 'T'
         CALL _ADVPL_set_property(m_texto,"EDITABLE",TRUE)
         CALL _ADVPL_set_property(m_texto,"CAN_GOT_FOCUS",TRUE)
      OTHERWISE
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Selecione o tipo.')
         CALL _ADVPL_set_property(m_tipo,"GET_FOCUS")
   END CASE

END FUNCTION

#----------------------#
FUNCTION pol1333_find()#
#----------------------#

    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)
        
    CALL _ADVPL_cursor_wait()
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","PESQUISA PARÃMETROS")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","gi_param_integracao_912","Parametro")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","gi_param_integracao_912","cod_parametro","Parâmetro",1 {INT},60,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","gi_param_integracao_912","den_parametro","Descrição",1 {CHAR},60,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","gi_param_integracao_912","tip_dado","Tip dado",1 {CHAR},1,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","gi_param_integracao_912","ies_ativo","Ativo",1 {CHAR},1,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")
    
    CALL _ADVPL_cursor_arrow()
    
    IF  l_status THEN
        LET l_where_clause = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_construct,"ORDER_BY")
        CALL pol1333_cria_cursor(l_where_clause,l_order_by)
    ELSE
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
        
END FUNCTION

#------------------------------------------------------#
FUNCTION pol1333_cria_cursor(l_where_clause,l_order_by)#
#------------------------------------------------------#
 
   DEFINE l_where_clause CHAR(800)
   DEFINE l_order_by     CHAR(200)

   DEFINE l_sql_stmt     CHAR(2000)

    IF  l_order_by IS NULL OR l_order_by = '1' THEN
        LET l_order_by = "cod_parametro"
    END IF

   LET l_sql_stmt = "SELECT * ",
                     " FROM gi_param_integracao_912 ",
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

   OPEN cq_cons

   IF  STATUS <> 0 THEN
       CALL log0030_processa_err_sql("OPEN CURSOR","cq_cons",0)
       RETURN 
   END IF
   
   #LET m_ies_cons = FALSE
   
   FETCH cq_cons INTO m_cod_parametro

   IF STATUS <> 0 THEN
      IF STATUS <> 100 THEN
         CALL log0030_processa_err_sql("FETCH CURSOR","cq_cons",0)
      ELSE
         LET m_msg = 'Não a dados, para os argumentos informados.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN 
   END IF
      
    IF NOT pol1333_exibe_dados() THEN
       LET m_msg = 'Operação cancelada'
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN 
    END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Consulta efetuada com sucesso')

   LET m_ies_cons = TRUE
   LET m_ies_inc = FALSE
      
END FUNCTION

#-----------------------------#
FUNCTION pol1333_exibe_dados()#
#-----------------------------#

   DEFINE l_prod, l_recei, l_merc, l_uso CHAR(02),
          l_id   INTEGER
   
   LET m_excluiu = FALSE

   INITIALIZE mr_campos.* TO NULL

   SELECT *
     INTO mr_campos.*
     FROM gi_param_integracao_912
    WHERE cod_parametro = m_cod_parametro

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql('SELECT','gi_param_integracao_912:ED',0)
      RETURN FALSE 
   END IF
               
   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1333_create()
#-----------------------#
    
    LET m_opcao = 'I'    
    INITIALIZE mr_campos.* TO NULL
    LET mr_campos.ies_ativo = 'S'
    CALL pol1333_ativa_desativa(TRUE)
    LET m_ies_inc = FALSE
    CALL _ADVPL_set_property(m_parametro,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#---------------------------#
FUNCTION pol1333_create_no()#
#---------------------------#

    CALL pol1333_ativa_desativa(FALSE)
    INITIALIZE mr_campos.* TO NULL
    LET m_opcao = NULL
    
    RETURN TRUE
        
END FUNCTION

#----------------------------#
FUNCTION pol1333_create_yes()#
#----------------------------#

   IF mr_campos.cod_parametro IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
         "Preencha o campo parâmetro")
      CALL _ADVPL_set_property(m_parametro,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_campos.den_parametro IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
         "Preencha o campo descrição")
      CALL _ADVPL_set_property(m_descricao,"GET_FOCUS")
      RETURN FALSE
   END IF
      
   SELECT 1 FROM gi_param_integracao_912
    WHERE cod_parametro = mr_campos.cod_parametro
   
   IF STATUS = 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
         "Parâmetro já cadastrado no pol1333.")
      CALL _ADVPL_set_property(m_parametro,"GET_FOCUS")
      RETURN FALSE
   ELSE
      IF STATUS <> 100 THEN
         CALL log0030_processa_err_sql('SELECT','gi_param_integracao_912',0)
         RETURN FALSE
      END IF
   END IF
   
   CALL LOG_transaction_begin()
   IF NOT pol1333_ins_registro() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()

   CALL pol1333_ativa_desativa(FALSE)

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1333_ins_registro()#
#------------------------------#

   INSERT INTO gi_param_integracao_912
    VALUES(mr_campos.*)

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql('INSERT','gi_param_integracao_912',0)
      RETURN FALSE
   END IF
    
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1333_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1333_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1333_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_cod_parametroa = m_cod_parametro

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_cod_parametro
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_cod_parametro
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_cod_parametro
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_cod_parametro
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_cod_parametro = m_cod_parametroa
         EXIT WHILE
      ELSE
         SELECT 1
           FROM gi_param_integracao_912
          WHERE cod_parametro = m_cod_parametro
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1333_exibe_dados()
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
FUNCTION pol1333_first()#
#-----------------------#

   IF NOT pol1333_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1333_next()#
#----------------------#

   IF NOT pol1333_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1333_previous()#
#--------------------------#

   IF NOT pol1333_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1333_last()#
#----------------------#

   IF NOT pol1333_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1333_prende_registro()#
#----------------------------------#
   
   CALL LOG_transaction_begin()
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM gi_param_integracao_912
     WHERE cod_parametro = m_cod_parametro
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
FUNCTION pol1333_update()#
#------------------------#

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT m_ies_inc THEN
      IF NOT pol1333_ies_cons() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1333_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'M'    

   CALL pol1333_ativa_desativa(TRUE)
   CALL _ADVPL_set_property(m_descricao,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1333_update_yes()#
#----------------------------#
   
   UPDATE gi_param_integracao_912
      SET den_parametro = mr_campos.den_parametro,
          tip_dado = mr_campos.tip_dado,
          val_texto = mr_campos.val_texto,
          val_data = mr_campos.val_data,
          val_valor = mr_campos.val_valor,
          val_inteiro = mr_campos.val_inteiro,
          ies_ativo = mr_campos.ies_ativo
    WHERE cod_parametro = m_cod_parametro
   
   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql('UPDATE','gi_param_integracao_912',0)
      CALL LOG_transaction_rollback()
      CLOSE cq_prende
      RETURN FALSE
   END IF
   
   CLOSE cq_prende
   
   LET m_opcao = NULL
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1333_update_no()#
#---------------------------#

   CALL LOG_transaction_rollback()
        
   CLOSE cq_prende
    
   LET m_cod_parametro = m_cod_parametroa
   CALL pol1333_exibe_dados()
   CALL pol1333_ativa_desativa(FALSE)
   LET m_opcao = NULL
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1333_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT m_ies_inc THEN
      IF NOT pol1333_ies_cons() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1333_prende_registro() THEN
      RETURN FALSE
   END IF

   DELETE FROM gi_param_integracao_912
    WHERE cod_parametro = m_cod_parametro

   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql('DELETE','gi_param_integracao_912',0)
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
