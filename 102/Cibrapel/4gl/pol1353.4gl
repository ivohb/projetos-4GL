#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1353                                                 #
# OBJETIVO: ERROS CONSUMO DE APARAS - USUÁRIOS P/ NOTIFICAÇÃO       #
# AUTOR...: IVO                                                     #
# DATA....: 23/04/18                                                #
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
       m_cod_usuario     VARCHAR(10),
       m_nom_usuario     VARCHAR(10),
       m_e_mail          VARCHAR(10),
       m_ies_envia       VARCHAR(10),
       m_zoom_usuario    VARCHAR(10),
       m_lupa_usuario    VARCHAR(10),
       m_construct       VARCHAR(10),
       m_panel           VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_cod_user         CHAR(15)
       
DEFINE mr_campos      RECORD
 cod_usuario          CHAR(15),
 nom_usuario          CHAR(36),
 email                CHAR(50),
 enviar               CHAR(01)
END RECORD

#-----------------#
FUNCTION pol1353()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1353-12.00.00  "
   CALL func002_versao_prg(p_versao)

   IF NOT log0150_verifica_se_tabela_existe("usuario_notif_885") THEN
      IF NOT pol1353_cria_tabela() THEN
         RETURN 
      END IF
   END IF
    
   CALL pol1353_menu()
    
END FUNCTION

#-----------------------------#
FUNCTION pol1353_cria_tabela()#
#-----------------------------#

   CREATE TABLE usuario_notif_885 (
      cod_usuario     CHAR(15),
      email           CHAR(50),
      enviar          CHAR(01)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','usuario_notif_885')
      RETURN FALSE
   END IF
   
   CREATE UNIQUE INDEX ix_usuario_notif_885 ON
    usuario_notif_885(cod_usuario);
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','ix_usuario_notif_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#----------------------#
FUNCTION pol1353_menu()#
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

    DEFINE l_titulo  VARCHAR(80)
    
    LET l_titulo  = "USUÁRIOS P/ NOTIFICAÇÃO DE ERROS CONSUMO APARAS"
    
    CALL pol1353_limpa_campos()
    LET m_ies_cons = FALSE

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1353_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1353_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1353_create_cancel")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1353_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1353_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1353_update_cancel")
    
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1353_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1353_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1353_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1353_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1353_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1353_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1353_cria_campos(l_panel)

    CALL pol1353_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1353_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1353_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)

    LET m_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",10)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Usuario:")    

    LET m_cod_usuario = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_usuario,"LENGTH",8)
    CALL _ADVPL_set_property(m_cod_usuario,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_cod_usuario,"VARIABLE",mr_campos,"cod_usuario")
    CALL _ADVPL_set_property(m_cod_usuario,"VALID","pol1353_valida_usuario")

    LET m_lupa_usuario = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_usuario,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_usuario,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_usuario,"CLICK_EVENT","pol1353_zoom_usuario")

    LET m_nom_usuario = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_nom_usuario,"LENGTH",50) 
    CALL _ADVPL_set_property(m_nom_usuario,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_nom_usuario,"VARIABLE",mr_campos,"nom_usuario")
    CALL _ADVPL_set_property(m_nom_usuario,"CAN_GOT_FOCUS",FALSE)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Email:")    

    LET m_e_mail = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_e_mail,"LENGTH",50)
    CALL _ADVPL_set_property(m_e_mail,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_e_mail,"VARIABLE",mr_campos,"email")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET m_ies_envia = _ADVPL_create_component(NULL,"LCHECKBOX",l_layout)
    CALL _ADVPL_set_property(m_ies_envia,"TEXT","Enviar")     
    CALL _ADVPL_set_property(m_ies_envia,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_ies_envia,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_ies_envia,"VARIABLE",mr_campos,"enviar")
    CALL _ADVPL_set_property(m_ies_envia,"FONT",NULL,11,FALSE,TRUE)
            
END FUNCTION

#------------------------------#
FUNCTION pol1353_zoom_usuario()#
#------------------------------#

    DEFINE l_codigo    LIKE usuarios.cod_usuario,
           l_descri    LIKE usuarios.nom_funcionario
    
    IF  m_zoom_usuario IS NULL THEN
        LET m_zoom_usuario = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_usuario,"ZOOM","zoom_usuarios")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_usuario,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_usuario,"RETURN_BY_TABLE_COLUMN","usuarios","cod_usuario")
    LET l_descri = _ADVPL_get_property(m_zoom_usuario,"RETURN_BY_TABLE_COLUMN","usuarios","nom_funcionario")

    IF  l_codigo IS NOT NULL THEN
        LET mr_campos.cod_usuario = l_codigo
        CALL pol1353_le_usuario(l_codigo)        
    END IF

    CALL _ADVPL_set_property(m_cod_usuario,"GET_FOCUS")

END FUNCTION

#----------------------------------#
FUNCTION pol1353_le_usuario(l_cod)#
#----------------------------------#
   
   DEFINE l_cod CHAR(15)

   IF l_cod IS NULL THEN
      LET mr_campos.nom_usuario = ''
      RETURN TRUE
   END IF
   
   LET m_msg = ''
      
   SELECT nom_funcionario,
          e_mail
     INTO mr_campos.nom_usuario,
          mr_campos.email
     FROM usuarios
    WHERE cod_usuario = l_cod
   
   IF STATUS = 100 THEN
      LET m_msg = 'usuario inexistente no Logix'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','usuario')    
         LET m_msg = 'ERRO ',STATUS, ' LENDO TABELA USUARIOS'       
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1353_valida_usuario()#
#--------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')

   IF mr_campos.cod_usuario IS NULL THEN
      LET m_msg = 'Infome o código do usuário'      
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT pol1353_le_usuario(mr_campos.cod_usuario) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF pol1353_user_ja_existe(mr_campos.cod_usuario) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1353_user_ja_existe(l_cod)#
#-------------------------------------#
   
   DEFINE l_cod CHAR(15)
   
   LET m_msg = ''

   SELECT COUNT(*)
     INTO m_count
     FROM usuario_notif_885
    WHERE cod_usuario = l_cod

   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO ',STATUS, 'LENDO TABELA USUARIO_NOTIF_885'   
      RETURN TRUE
   END IF
         
   IF m_count > 0 THEN
      LET m_msg = 'usuario já cadastrado no pol1353.'
      RETURN TRUE
   END IF   
   
   RETURN FALSE

END FUNCTION

#----------------------------------------#
FUNCTION pol1353_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   IF m_opcao = 'M' THEN
      CALL _ADVPL_set_property(m_cod_usuario,"EDITABLE",FALSE)
   ELSE
      CALL _ADVPL_set_property(m_cod_usuario,"EDITABLE",l_status)
   END IF
   
   CALL _ADVPL_set_property(m_e_mail,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_ies_envia,"EDITABLE",l_status)

END FUNCTION

#-----------------------#
FUNCTION pol1353_create()
#-----------------------#
    
    LET m_opcao = 'I'

    CALL pol1353_limpa_campos()
    CALL pol1353_ativa_desativa(TRUE)
    
    LET m_ies_cons = FALSE
    LET mr_campos.enviar = 'S'
    
    CALL _ADVPL_set_property(m_cod_usuario,"GET_FOCUS")    
        
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1353_create_confirm()
#-------------------------------#
   
   IF NOT pol1353_valid_form() THEN
      RETURN FALSE
   END IF
   
   INSERT INTO usuario_notif_885(
      cod_usuario, email, enviar)  
   VALUES(mr_campos.cod_usuario, mr_campos.email, mr_campos.enviar)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','usuario_notif_885')
      RETURN FALSE
   END IF
            
   CALL pol1353_ativa_desativa(FALSE)

   RETURN TRUE
        
END FUNCTION
   
#-------------------------------#
FUNCTION pol1353_create_cancel()#
#-------------------------------#

    CALL pol1353_ativa_desativa(FALSE)
    CALL pol1353_limpa_campos()
    
    RETURN TRUE
        
END FUNCTION

#----------------------------#
FUNCTION pol1353_valid_form()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')

   IF mr_campos.cod_usuario IS NULL THEN
      LET m_msg = 'infome o código do usuário'      
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_cod_usuario,"GET_FOCUS")   
      RETURN FALSE
   END IF

   IF mr_campos.email IS NULL THEN
      LET m_msg = 'infome o e_mail do usuário'      
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_e_mail,"GET_FOCUS")   
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#----------------------#
FUNCTION pol1353_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1353_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","usuario_notif_885","usuarios")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","usuario_notif_885","cod_usuario","Código",1 {CHAR},8,0,"zoom_usuarios")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","usuario_notif_885","email","Email",1 {CHAR},50,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1353_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1353_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " cod_usuario "
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT cod_usuario ",
                      " FROM usuario_notif_885",
                     " WHERE ",l_where CLIPPED,
                     " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","usuario_notif_885")
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

    FETCH cq_cons INTO mr_campos.cod_usuario

    IF STATUS <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","cq_cons")
       ELSE
          LET m_msg = "Argumentos de pesquisa não encontrados."
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       END IF
       CALL pol1353_limpa_campos()
       RETURN FALSE
    END IF
    
    CALL pol1353_exibe_dados() RETURNING p_status 
    
    LET m_ies_cons = TRUE
    LET m_cod_user = mr_campos.cod_usuario
    
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1353_exibe_dados()#
#-----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_excluiu = FALSE

   SELECT email, enviar, nom_funcionario
     INTO mr_campos.email, mr_campos.enviar, mr_campos.nom_usuario
     FROM usuario_notif_885 INNER JOIN usuarios
          ON usuario_notif_885.cod_usuario = usuarios.cod_usuario
    WHERE usuario_notif_885.cod_usuario = mr_campos.cod_usuario

    IF STATUS <> 0 THEN
       CALL log003_err_sql('SELECT','usuario_notif_885')
       RETURN FALSE      
    END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1353_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1353_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1353_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_cod_user = mr_campos.cod_usuario

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO mr_campos.cod_usuario
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO mr_campos.cod_usuario
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO mr_campos.cod_usuario
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO mr_campos.cod_usuario
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET mr_campos.cod_usuario = m_cod_user
         EXIT WHILE
      ELSE
         SELECT 1
           FROM usuario_notif_885
          WHERE cod_usuario = mr_campos.cod_usuario
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1353_exibe_dados()
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
FUNCTION pol1353_first()#
#-----------------------#

   IF NOT pol1353_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1353_next()#
#----------------------#

   IF NOT pol1353_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1353_previous()#
#--------------------------#

   IF NOT pol1353_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1353_last()#
#----------------------#

   IF NOT pol1353_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1353_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM usuario_notif_885
     WHERE cod_usuario = mr_campos.cod_usuario
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
FUNCTION pol1353_update()#
#------------------------#

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT pol1353_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1353_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'M'

   CALL pol1353_ativa_desativa(TRUE)      
   CALL _ADVPL_set_property(m_e_mail,"GET_FOCUS")
      
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1353_update_confirm()#
#--------------------------------#
   
   DEFINE l_ret   SMALLINT

   IF NOT pol1353_valid_form() THEN
      RETURN FALSE
   END IF
   
   UPDATE usuario_notif_885
      SET email = mr_campos.email,
          enviar = mr_campos.enviar
    WHERE cod_usuario = mr_campos.cod_usuario

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','usuario_notif_885')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1353_ativa_desativa(FALSE)
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
   
END FUNCTION

#------------------------------#
FUNCTION pol1353_update_cancel()
#------------------------------#
    
    CALL pol1353_exibe_dados()
    CALL pol1353_ativa_desativa(FALSE)

    RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1353_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1353_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1353_prende_registro() THEN
      RETURN FALSE
   END IF

   DELETE FROM usuario_notif_885
    WHERE cod_usuario = mr_campos.cod_usuario

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','usuario_notif_885')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1353_limpa_campos()
      LET m_excluiu = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION


{ #-------------FIM DO PROGRAMA----------------#


}

