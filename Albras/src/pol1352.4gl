#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1352                                                 #
# OBJETIVO: PER�ODOS QUE A INTEGRA��O COM PPI N�O PODE RODAR        #
# AUTOR...: IVO                                                     #
# DATA....: 20/09/16                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           p_cod_operac    CHAR(05),
           p_cod_operaca   CHAR(05)
END GLOBALS

DEFINE m_cod_empresa_plano   LIKE empresa.cod_empresa

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_dia_semana      VARCHAR(10),
       m_hor_inicial     VARCHAR(10),
       m_hor_final       VARCHAR(10)
       
DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT
       
DEFINE mr_campos         RECORD
  dia_semana          char(01),
  hora_ini            char(08),
  hora_fim            char(08)
END RECORD

DEFINE lr_campos         RECORD
  dia_semana          char(01),
  hora_ini            char(08),
  hora_fim            char(08)
END RECORD

#-----------------#
FUNCTION pol1352()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1352-12.00.00  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1352_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1352_menu()#
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
           l_delete  VARCHAR(10),
           l_titulo  VARCHAR(100)

        
    CALL pol1352_limpa_campos()
    LET l_titulo = 'ER�ODOS QUE A INTEGRA��O COM PPI N�O PODE RODAR'
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1352_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1352_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1352_create_cancel")
    
    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1352_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1352_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1352_update_cancel")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1352_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1352_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1352_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1352_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1352_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1352_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1352_cria_campos(l_panel)

    CALL pol1352_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1352_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1352_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",40)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
    CALL _ADVPL_set_property(l_panel,"WIDTH",200)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",2)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Dia da semana:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dia_semana = _ADVPL_create_component(NULL,"LCOMBOBOX",l_layout)
    CALL _ADVPL_set_property(m_dia_semana,"ADD_ITEM","0"," ")     
    CALL _ADVPL_set_property(m_dia_semana,"ADD_ITEM","1","Domingo")     
    CALL _ADVPL_set_property(m_dia_semana,"ADD_ITEM","2","Segunda")     
    CALL _ADVPL_set_property(m_dia_semana,"ADD_ITEM","3","Ter�a")     
    CALL _ADVPL_set_property(m_dia_semana,"ADD_ITEM","4","Quarta")     
    CALL _ADVPL_set_property(m_dia_semana,"ADD_ITEM","5","Quinta")     
    CALL _ADVPL_set_property(m_dia_semana,"ADD_ITEM","6","Sexta")     
    CALL _ADVPL_set_property(m_dia_semana,"ADD_ITEM","7","S�bado")         
    CALL _ADVPL_set_property(m_dia_semana,"VARIABLE",mr_campos,"dia_semana")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Hora inicial:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_hor_inicial = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_hor_inicial,"LENGTH",6)
    CALL _ADVPL_set_property(m_hor_inicial,"VARIABLE",mr_campos,"hora_ini")
    CALL _ADVPL_set_property(m_hor_inicial,"PICTURE","##:##:##")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Hora final:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_hor_final = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_hor_final,"LENGTH",6)
    CALL _ADVPL_set_property(m_hor_final,"VARIABLE",mr_campos,"hora_fim")
    CALL _ADVPL_set_property(m_hor_final,"PICTURE","##:##:##")


END FUNCTION

#----------------------------------------#
FUNCTION pol1352_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   IF m_opcao = 'M' THEN
      CALL _ADVPL_set_property(m_dia_semana,"EDITABLE",FALSE)
   ELSE
      CALL _ADVPL_set_property(m_dia_semana,"EDITABLE",l_status)
   END IF
   
   CALL _ADVPL_set_property(m_hor_inicial,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_hor_final,"EDITABLE",l_status)

END FUNCTION

#-----------------------#
FUNCTION pol1352_create()
#-----------------------#
    
    LET m_opcao = 'I'    
    CALL pol1352_limpa_campos()
    CALL pol1352_ativa_desativa(TRUE)
    
    LET m_ies_cons = FALSE
    
    CALL _ADVPL_set_property(m_dia_semana,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1352_create_confirm()
#-------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
   
   IF mr_campos.dia_semana = '0' THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", 'Campo obrigat�rio.')
      CALL _ADVPL_set_property(m_dia_semana,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_campos.hora_ini IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", 'Campo obrigat�rio.')
      CALL _ADVPL_set_property(m_hor_inicial,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_campos.hora_fim IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", 'Campo obrigat�rio.')
      CALL _ADVPL_set_property(m_hor_final,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   INSERT INTO calendar_apont_304
   VALUES(mr_campos.dia_semana, mr_campos.hora_ini, mr_campos.hora_fim)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','calendar_apont_304')
      RETURN FALSE
   END IF
            
    CALL pol1352_ativa_desativa(FALSE)

    RETURN TRUE
        
END FUNCTION

#-------------------------------#
FUNCTION pol1352_create_cancel()#
#-------------------------------#

    CALL pol1352_ativa_desativa(FALSE)
    CALL pol1352_limpa_campos()
    
    RETURN TRUE
        
END FUNCTION

#----------------------#
FUNCTION pol1352_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1352_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","calendar_apont_304","calendario")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","calendar_apont_304","dia_semana","Dia semana",1 {CHAR},1,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","calendar_apont_304","hora_ini","Hora inicial",1 {CHAR},8,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","calendar_apont_304","hora_fim","Hora final",1 {CHAR},8,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1352_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1352_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " dia_semana "
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT * ",
                      " FROM calendar_apont_304",
                     " WHERE ",l_where CLIPPED,
                     " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","calendar_apont_304")
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

    FETCH cq_cons INTO mr_campos.*

    IF STATUS <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","cq_cons")
       ELSE
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Argumentos de pesquisa n�o encontrados.")
       END IF
       CALL pol1352_limpa_campos()
       RETURN FALSE
    END IF
    
    LET m_ies_cons = TRUE
    LET lr_campos.* = mr_campos.*
    LET m_excluiu = FALSE
    
    RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1352_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'N�o h� consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1352_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT
   
   LET m_excluiu = FALSE
   
   IF NOT pol1352_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET lr_campos.* = mr_campos.*

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO mr_campos.*
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO mr_campos.*
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO mr_campos.*
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO mr_campos.*
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","N�o existem mais registros nesta dire��o.")
         END IF
         LET mr_campos.* = lr_campos.*
         EXIT WHILE
      ELSE
         SELECT 1
           FROM calendar_apont_304
          WHERE dia_semana =  mr_campos.dia_semana
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
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
FUNCTION pol1352_first()#
#-----------------------#

   IF NOT pol1352_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1352_next()#
#----------------------#

   IF NOT pol1352_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1352_previous()#
#--------------------------#

   IF NOT pol1352_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1352_last()#
#----------------------#

   IF NOT pol1352_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1352_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM calendar_apont_304
     WHERE dia_semana = mr_campos.dia_semana
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
FUNCTION pol1352_update()#
#------------------------#

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "N�o h� dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT pol1352_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1352_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'M'    

   CALL pol1352_ativa_desativa(TRUE)
      
   CALL _ADVPL_set_property(m_hor_inicial,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1352_update_confirm()#
#--------------------------------#
   
   DEFINE l_ret   SMALLINT
   
   UPDATE calendar_apont_304
      SET hora_ini = mr_campos.hora_ini,
          hora_fim = mr_campos.hora_fim
    WHERE dia_semana = mr_campos.dia_semana

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','calendar_apont_304')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1352_ativa_desativa(FALSE)
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
   
END FUNCTION

#------------------------------#
FUNCTION pol1352_update_cancel()
#------------------------------#
    
    LET mr_campos.* = lr_campos.*
    CALL pol1352_ativa_desativa(FALSE)
    LET m_excluiu = FALSE
    
    RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1352_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "N�o h� dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1352_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclus�o do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1352_prende_registro() THEN
      RETURN FALSE
   END IF

   DELETE FROM calendar_apont_304
    WHERE dia_semana = mr_campos.dia_semana

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','calendar_apont_304')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1352_limpa_campos()
      LET m_excluiu = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION
