#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1315                                                 #
# OBJETIVO: APROVADORES DE GRADE DE RATEIO DE DESPESAS              #
# AUTOR...: IVO                                                     #
# DATA....: 29/11/16                                                #
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
       m_statusbar       VARCHAR(10),
       m_aprovador       VARCHAR(10),
       m_nom_aprov       VARCHAR(10),
       m_zoom_aprov      VARCHAR(10),
       m_lupa_aprov      VARCHAR(10),
       m_ce_aprov        VARCHAR(10),
       m_de_aprov        VARCHAR(10),
       m_zoom_empaprov   VARCHAR(10),
       m_lupa_empaprov   VARCHAR(10),
       m_construct       VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_cod_aprov       CHAR(08),
       m_cod_aprova      CHAR(08),
       m_nom_usuario     CHAR(40),
       m_excluiu         SMALLINT,
       m_opcao           CHAR(01),
       m_den_empresa     CHAR(02)
              
DEFINE mr_campos         RECORD
       cod_empresa       CHAR(02),
       den_empresa       CHAR(40),
       cod_user          CHAR(08),
       nom_user          CHAR(40)
END RECORD

DEFINE mr_audit      RECORD
       cod_empresa   LIKE audit_logix.cod_empresa,
       texto         LIKE audit_logix.texto,
       num_programa  LIKE audit_logix.num_programa,
       usuario       LIKE audit_logix.usuario
END RECORD

#-----------------#
FUNCTION pol1315()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 11

   LET p_versao = "pol1315-12.00.05  "
   CALL func002_versao_prg(p_versao)
   
   LET mr_audit.cod_empresa = p_cod_empresa
   LET mr_audit.num_programa = 'POL1315'
   LET mr_audit.usuario = p_user
       
   CALL pol1315_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1315_menu()#
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

    
    CALL pol1315_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE","ARPOVADORES DE GRADE DE RATEIO")
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1315_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1315_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1315_create_cancel")
    
    {LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1315_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1315_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1315_update_cancel")}

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1315_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1315_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1315_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1315_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1315_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1315_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1315_cria_campos(l_panel)

    CALL pol1315_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1315_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1315_cria_campos(l_useriner)#
#----------------------------------------#

    DEFINE l_useriner       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_useriner)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",40)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_useriner)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
    CALL _ADVPL_set_property(l_panel,"WIDTH",200)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_useriner)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",4)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cód empresa:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_ce_aprov = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_ce_aprov,"LENGTH",2)
    CALL _ADVPL_set_property(m_ce_aprov,"VARIABLE",mr_campos,"cod_empresa")
    CALL _ADVPL_set_property(m_ce_aprov,"VALID","pol1315_valida_empresa")

    LET m_lupa_empaprov = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_empaprov,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_empaprov,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_empaprov,"CLICK_EVENT","pol1315_zoom_empresa")

    LET m_de_aprov = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_de_aprov,"LENGTH",36) 
    CALL _ADVPL_set_property(m_de_aprov,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_de_aprov,"VARIABLE",mr_campos,"den_empresa")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cód usuário:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_aprovador = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_aprovador,"LENGTH",8)
    CALL _ADVPL_set_property(m_aprovador,"VARIABLE",mr_campos,"cod_user")
    CALL _ADVPL_set_property(m_aprovador,"VALID","pol1315_valida_usuario")

    LET m_lupa_aprov = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_aprov,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_aprov,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_aprov,"CLICK_EVENT","pol1315_zoom_usuario")

    LET m_nom_aprov = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_nom_aprov,"LENGTH",50) 
    CALL _ADVPL_set_property(m_nom_aprov,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_nom_aprov,"VARIABLE",mr_campos,"nom_user")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

END FUNCTION

#------------------------------#
FUNCTION pol1315_zoom_empresa()#
#------------------------------#

   DEFINE l_codigo       LIKE empresa.cod_empresa,
          l_descricao    LIKE empresa.den_empresa

   IF  m_zoom_empaprov IS NULL THEN
       LET m_zoom_empaprov = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_empaprov,"ZOOM","zoom_empresa")
   END IF

   CALL _ADVPL_get_property(m_zoom_empaprov,"ACTIVATE")

   LET l_codigo    = _ADVPL_get_property(m_zoom_empaprov,"RETURN_BY_TABLE_COLUMN","empresa","cod_empresa")
   LET l_descricao = _ADVPL_get_property(m_zoom_empaprov,"RETURN_BY_TABLE_COLUMN","empresa","den_empresa")

   IF l_codigo IS NOT NULL THEN
      LET mr_campos.cod_empresa = l_codigo
      LET mr_campos.den_empresa = l_descricao
   END IF
    
END FUNCTION

#--------------------------------#
FUNCTION pol1315_valida_empresa()#
#--------------------------------#
    
    CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
    IF  mr_campos.cod_empresa IS NULL THEN
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a empresa.")
        RETURN FALSE
    END IF
      
   IF NOT pol1315_le_empresa(mr_campos.cod_empresa) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
        
   LET mr_campos.den_empresa = m_den_empresa
   CALL _ADVPL_set_property(m_aprovador,"GET_FOCUS")   
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1315_le_empresa(l_codigo)#
#------------------------------------#

   DEFINE l_codigo LIKE empresa.cod_empresa  
   
   LET m_msg = ''
   
   SELECT den_empresa
     INTO m_den_empresa
     FROM empresa
    WHERE cod_empresa = l_codigo

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      LET m_den_empresa = ''
      IF STATUS = 100 THEN
         LET m_msg = 'Empresa inexistente.'    
      ELSE
         CALL log003_err_sql('SELECT','empresa')
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
FUNCTION pol1315_zoom_usuario()#
#------------------------------#

    DEFINE l_codigo       LIKE usuarios.cod_usuario,
           l_descricao    LIKE usuarios.nom_funcionario
    
    IF  m_zoom_aprov IS NULL THEN
        LET m_zoom_aprov = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_aprov,"ZOOM","zoom_usuarios")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_aprov,"ACTIVATE")
    
    LET l_codigo    = _ADVPL_get_property(m_zoom_aprov,"RETURN_BY_TABLE_COLUMN","usuarios","cod_usuario")
    LET l_descricao = _ADVPL_get_property(m_zoom_aprov,"RETURN_BY_TABLE_COLUMN","usuarios","nom_funcionario")

    IF l_codigo IS NOT NULL THEN
       LET mr_campos.cod_user = l_codigo
       LET mr_campos.nom_user = l_descricao
    END IF

END FUNCTION

#--------------------------------#
FUNCTION pol1315_valida_usuario()#
#--------------------------------#
    
    LET mr_campos.nom_user = ''
    
    IF  mr_campos.cod_user IS NULL THEN
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o usuário.")
        RETURN FALSE
    END IF
   
   LET mr_campos.cod_user = DOWNSHIFT(mr_campos.cod_user)
   
   IF NOT pol1315_le_usuario(mr_campos.cod_user) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF pol1315_aprov_ja_existe(mr_campos.cod_user) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET mr_campos.nom_user = m_nom_usuario
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1315_le_usuario(l_user)#
#----------------------------------#
   
   DEFINE l_user CHAR(13)
   
   LET m_msg = ''
      
   SELECT nom_funcionario
     INTO m_nom_usuario
     FROM usuarios
    WHERE cod_usuario =  l_user
   
   IF STATUS = 100 THEN
      LET m_msg = 'Usuário inexistente no logix.'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','usuarios')   
         LET m_msg = 'Erro ',STATUS, ' lendo tabela usuarios.'      
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------------#
FUNCTION pol1315_aprov_ja_existe(l_codigo)#
#-----------------------------------------#
   
   DEFINE l_codigo CHAR(08)
   
   LET m_msg = ''
   
   SELECT 1
     FROM aprovador_912
    WHERE cod_empresa =  mr_campos.cod_empresa
      AND cod_user = l_codigo
   
   IF STATUS = 100 THEN
      RETURN FALSE
   ELSE
      IF STATUS = 0 THEN
         LET m_msg = 'Arpvador ja cadastrado par a empresa ', mr_campos.cod_empresa
      ELSE
         CALL log003_err_sql('SELECT','aprovador_912')
         LET m_msg = 'Erro ',STATUS, ' lendo tabela aprovador_912.' 
      END IF
   END IF   
   
   RETURN TRUE

END FUNCTION

#----------------------------------------#
FUNCTION pol1315_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT

   IF m_opcao = 'M' THEN
      CALL _ADVPL_set_property(m_aprovador,"EDITABLE",FALSE)
      CALL _ADVPL_set_property(m_lupa_aprov,"EDITABLE",FALSE)
   ELSE
      CALL _ADVPL_set_property(m_aprovador,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_lupa_aprov,"EDITABLE",l_status)
   END IF
      
   CALL _ADVPL_set_property(m_ce_aprov,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_empaprov,"EDITABLE",l_status)

END FUNCTION


#-----------------------#
FUNCTION pol1315_create()
#-----------------------#

    LET m_opcao = 'I'    
        
    CALL pol1315_limpa_campos()
    CALL pol1315_ativa_desativa(TRUE)
    
    LET m_ies_cons = FALSE
    
    CALL _ADVPL_set_property(m_ce_aprov,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1315_create_confirm()
#-------------------------------#
    
   INSERT INTO aprovador_912(
      cod_empresa, cod_user)
   VALUES(mr_campos.cod_empresa, mr_campos.cod_user)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','aprovador_912')
      RETURN FALSE
   END IF
   
   LET mr_audit.texto = 'INCLUSAO DO APROVANETE ',  mr_campos.cod_user
   LET p_status = func002_grava_auadit(mr_audit.*)
       
   CALL pol1315_ativa_desativa(FALSE)
   LET m_opcao = NULL

   RETURN TRUE
        
END FUNCTION

#-------------------------------#
FUNCTION pol1315_create_cancel()#
#-------------------------------#

    CALL pol1315_ativa_desativa(FALSE)
    CALL pol1315_limpa_campos()
    LET m_opcao = NULL
    
    RETURN TRUE
        
END FUNCTION

#------------------------#
FUNCTION pol1315_update()#
#------------------------#

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT pol1315_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1315_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'M'    
   
   CALL pol1315_ativa_desativa(TRUE)
      
   CALL _ADVPL_set_property(m_aprovador,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1315_update_confirm()#
#--------------------------------#

    UPDATE aprovador_912
         SET cod_user = ''
       WHERE cod_empresa = mr_campos.cod_empresa
         AND cod_user = mr_campos.cod_user
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1315_update_cancel()
#------------------------------#

    CALL pol1315_ativa_desativa(FALSE)

    RETURN TRUE

END FUNCTION


#--------------------------#
FUNCTION pol1315_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------#
FUNCTION pol1315_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1315_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","aprovador_912","Aprovadores")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","aprovador_912","cod_empresa","Cod Empresa",1 {CHAR},2,0,"zoom_empresa")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","aprovador_912","cod_user","Cod Usuário",1 {CHAR},8,0,"zoom_usuarios")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1315_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1315_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = "1"
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT * ",
                      " FROM aprovador_912",
                     " WHERE ",l_where CLIPPED,
                     " ORDER BY ",l_order

    PREPARE var_user FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","aprovador_912")
       RETURN FALSE
    END IF

    DECLARE cq_user SCROLL CURSOR WITH HOLD FOR var_user

    IF  sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("DECLARE CURSOR","cq_user")
        RETURN FALSE
    END IF

    FREE var_user

    OPEN cq_user

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_user")
       RETURN FALSE
    END IF

    FETCH cq_user INTO 
       mr_campos.cod_empresa, mr_campos.cod_user

    IF sqlca.sqlcode <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","cq_user")
       ELSE
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Argumentos de pesquisa não encontrados.")
       END IF
       CALL pol1315_limpa_campos()
       RETURN FALSE
    END IF

    CALL pol1315_exibe_dados()
    
    LET m_ies_cons = TRUE
    
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1315_exibe_dados()#
#-----------------------------#

   CALL pol1315_le_empresa(mr_campos.cod_empresa) RETURNING p_status
   LET mr_campos.den_empresa = m_den_empresa

   CALL pol1315_le_usuario(mr_campos.cod_user) RETURNING p_status
   LET mr_campos.nom_user = m_nom_usuario
   LET m_excluiu = FALSE
   
END FUNCTION   

#----------------------------------#
FUNCTION pol1315_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1315_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_cod_aprova = mr_campos.cod_user

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_user INTO mr_campos.cod_empresa, mr_campos.cod_user
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_user INTO mr_campos.cod_empresa, mr_campos.cod_user
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_user INTO mr_campos.cod_empresa, mr_campos.cod_user
         WHEN 'P' 
            FETCH PREVIOUS cq_user INTO mr_campos.cod_empresa, mr_campos.cod_user
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_user")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET mr_campos.cod_user = m_cod_aprova
         EXIT WHILE
      ELSE
         SELECT cod_user
           FROM aprovador_912
          WHERE cod_empresa =  mr_campos.cod_empresa
            AND cod_user = mr_campos.cod_user
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1315_exibe_dados()
               LET l_achou = TRUE
               EXIT WHILE
            ELSE 
               CALL log003_err_sql("FETCH CURSOR","cq_user")
               EXIT WHILE
            END IF
         END IF
      END IF               
   
   END WHILE
   
   RETURN l_achou
   
END FUNCTION

#-----------------------#
FUNCTION pol1315_first()#
#-----------------------#

   IF NOT pol1315_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1315_next()#
#----------------------#

   IF NOT pol1315_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1315_previous()#
#--------------------------#

   IF NOT pol1315_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1315_last()#
#----------------------#

   IF NOT pol1315_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1315_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT cod_user
      FROM aprovador_912
     WHERE cod_empresa =  mr_campos.cod_empresa
       AND cod_user = mr_campos.cod_user
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
FUNCTION pol1315_delete()#
#------------------------#

   IF NOT pol1315_ies_cons() THEN
      RETURN FALSE
   END IF

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1315_prende_registro() THEN
      RETURN FALSE
   END IF

   DELETE FROM aprovador_912
    WHERE cod_empresa = mr_campos.cod_empresa
      AND cod_user = mr_campos.cod_user

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','aprovador_912')
      CALL log085_transacao("ROLLBACK")
      CLOSE cq_prende
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   LET m_excluiu = TRUE
   CLOSE cq_prende

   LET mr_audit.texto = 'EXCLUSAO DO APROVANETE ',  mr_campos.cod_user
   LET p_status = func002_grava_auadit(mr_audit.*)

   CALL pol1315_limpa_campos()
   CALL pol1315_ativa_desativa(FALSE)
    
   RETURN TRUE
    
END FUNCTION


#-----------------FIM DO PROGRAMA-------------------#

