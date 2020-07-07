#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1302                                                 #
# OBJETIVO: CONTAS CONTÁBEIS P/ INCLUSÃO DE PARCELA DE BENS         #
# AUTOR...: IVO                                                     #
# DATA....: 25/11/15                                                #
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
       m_num_conta       VARCHAR(10),
       m_num_conta_reduz VARCHAR(10),
       m_den_conta       VARCHAR(10),
       m_zoom_conta      VARCHAR(10),
       m_lupa_conta      VARCHAR(10),
       m_construct       VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT
       
DEFINE mr_campos         RECORD
       num_conta         CHAR(23),
       num_conta_reduz   CHAR(10),
       den_conta         CHAR(50)
END RECORD

DEFINE m_conta_ant       CHAR(13)

#-----------------#
FUNCTION pol1302()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1302-12.00.02  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1302_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1302_menu()#
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

    
    CALL pol1302_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE","CONTAS CONTÁBEIS P/ INCLUSÃO DE PARCELAS DE BENS")

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1302_create")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1302_create_confirm")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1302_create_cancel")
    
    {LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1302_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1302_update_confirm")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1302_update_cancel")}

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1302_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1302_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1302_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1302_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1302_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1302_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1302_cria_campos(l_panel)

    CALL pol1302_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1302_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1302_cria_campos(l_container)#
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
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",4)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Conta contábil:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_num_conta = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_num_conta,"LENGTH",13)
    CALL _ADVPL_set_property(m_num_conta,"VARIABLE",mr_campos,"num_conta")
    CALL _ADVPL_set_property(m_num_conta,"PICTURE","@!")
    CALL _ADVPL_set_property(m_num_conta,"VALID","pol1302_valida_conta")

    LET m_lupa_conta = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_conta,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_conta,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_conta,"CLICK_EVENT","pol1302_zoom_conta")

    LET m_den_conta = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_den_conta,"LENGTH",50) 
    CALL _ADVPL_set_property(m_den_conta,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_den_conta,"VARIABLE",mr_campos,"den_conta")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Conta reduzida:")    

    LET m_num_conta_reduz = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_num_conta_reduz,"LENGTH",10) 
    CALL _ADVPL_set_property(m_num_conta_reduz,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_num_conta_reduz,"VARIABLE",mr_campos,"num_conta_reduz")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

END FUNCTION

#------------------------------#
FUNCTION pol1302_zoom_conta()#
#------------------------------#

    DEFINE l_codigo       LIKE plano_contas.num_conta,
           l_descricao    LIKE plano_contas.den_conta,
           l_cod_reduz    LIKE plano_contas.num_conta_reduz
    
    IF  m_zoom_conta IS NULL THEN
        LET m_zoom_conta = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_conta,"ZOOM","zoom_plano_contas")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_conta,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_conta,"RETURN_BY_TABLE_COLUMN","plano_contas","num_conta")
    LET l_descricao = _ADVPL_get_property(m_zoom_conta,"RETURN_BY_TABLE_COLUMN","plano_contas","den_conta")
    LET l_cod_reduz = _ADVPL_get_property(m_zoom_conta,"RETURN_BY_TABLE_COLUMN","plano_contas","num_conta_reduz")

    IF  l_cod_empresa IS NOT NULL THEN
        LET mr_campos.num_conta = l_codigo
        LET mr_campos.den_conta = l_descricao
        LET mr_campos.num_conta_reduz = l_cod_reduz
    END IF

END FUNCTION

#------------------------------#
FUNCTION pol1302_valida_conta()#
#------------------------------#

    IF  mr_campos.num_conta IS NULL THEN
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a conta contábil.")
        RETURN FALSE
    END IF

   IF NOT pol1302_le_plano(mr_campos.num_conta) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF pol1302_conta_ja_existe(mr_campos.num_conta) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1302_le_plano(l_conta)#
#---------------------------------#
   
   DEFINE l_conta CHAR(13)
   
   LET m_msg = ''

   IF m_cod_empresa_plano IS NULL OR
        m_cod_empresa_plano = ' ' THEN
      CALL pol1302_le_par_con() RETURNING p_status
   END IF
      
   SELECT den_conta,
          num_conta_reduz
     INTO mr_campos.den_conta,
          mr_campos.num_conta_reduz
     FROM plano_contas
    WHERE cod_empresa =  m_cod_empresa_plano
      AND num_conta = l_conta
   
   IF STATUS = 100 THEN
      LET m_msg = 'Conta inexistente no logix.'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','plano_contas')         
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------------#
FUNCTION pol1302_conta_ja_existe(l_conta)#
#----------------------------------------#
   
   DEFINE l_conta CHAR(13)
   
   LET m_msg = ''
   
   SELECT 1
     FROM conta_contabil_ronc
    WHERE cod_empresa =  p_cod_empresa
      AND num_conta = l_conta
   
   IF STATUS = 100 THEN
      RETURN FALSE
   ELSE
      IF STATUS = 0 THEN
         LET m_msg = 'Conta já cadastrada no POL1302.'
      ELSE
         CALL log003_err_sql('SELECT','conta_contabil_ronc')
      END IF
   END IF   
   
   RETURN TRUE

END FUNCTION

#----------------------------------------#
FUNCTION pol1302_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
    
   CALL _ADVPL_set_property(m_num_conta,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_conta,"EDITABLE",l_status)

END FUNCTION


#---------------------------#
FUNCTION pol1302_le_par_con()
#---------------------------#

    SELECT cod_empresa_plano
      INTO m_cod_empresa_plano
      FROM par_con
     WHERE cod_empresa = p_cod_empresa
    
    IF STATUS = 100 THEN
       LET m_cod_empresa_plano = p_cod_empresa
    ELSE
       IF STATUS = 0 THEN
          IF m_cod_empresa_plano IS NULL OR m_cod_empresa_plano = ' ' THEN
             LET m_cod_empresa_plano = p_cod_empresa
          END IF
       ELSE
          CALL log003_err_sql('SELECT','par_con')
          RETURN FALSE
       END IF
    END IF    

   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1302_create()
#-----------------------#
    
    IF NOT pol1302_le_par_con() THEN
       RETURN FALSE
    END IF
    
    CALL pol1302_limpa_campos()
    CALL pol1302_ativa_desativa(TRUE)
    
    LET m_ies_cons = FALSE
    
    CALL _ADVPL_set_property(m_num_conta,"GET_FOCUS")
    
    RETURN TRUE 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1302_create_confirm()
#-------------------------------#
    
   INSERT INTO conta_contabil_ronc(
      cod_empresa, num_conta, num_conta_reduz)
   VALUES(p_cod_empresa, mr_campos.num_conta, mr_campos.num_conta_reduz)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','conta_contabil_ronc')
      RETURN FALSE
   END IF
            
    CALL pol1302_ativa_desativa(FALSE)

    RETURN TRUE
        
END FUNCTION

#-------------------------------#
FUNCTION pol1302_create_cancel()#
#-------------------------------#

    CALL pol1302_ativa_desativa(FALSE)
    CALL pol1302_limpa_campos()
    
    RETURN TRUE
        
END FUNCTION

#------------------------#
FUNCTION pol1302_update()#
#------------------------#

   IF NOT pol1302_ies_cons() THEN
      RETURN FALSE
   END IF
   
   CALL pol1302_ativa_desativa(TRUE)
      
   CALL _ADVPL_set_property(m_num_conta,"GET_FOCUS")

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1302_update_confirm()#
#--------------------------------#

{      UPDATE conta_contabil_ronc
         SET ...
       WHERE cod_empresa = p_cod_empresa
         AND num_conta = mr_campos.num_conta
}   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1302_update_cancel()
#------------------------------#

    CALL pol1302_ativa_desativa(FALSE)

    RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1302_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------#
FUNCTION pol1302_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","POL1302_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","conta_contabil_ronc","Contas")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","conta_contabil_ronc","num_conta","Conta",1 {CHAR},23,0,"zoom_plano_contas")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","conta_contabil_ronc","num_conta_reduz","Reduzida",1 {CHAR},10,0,"zoom_plano_contas")
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1302_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1302_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = "1"
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT num_conta ",
                      " FROM conta_contabil_ronc",
                     " WHERE ",l_where CLIPPED,
                       " AND cod_empresa = '",p_cod_empresa,"' ",
                     " ORDER BY ",l_order

    PREPARE var_conta FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","conta_contabil_ronc")
       RETURN FALSE
    END IF

    DECLARE cq_conta SCROLL CURSOR WITH HOLD FOR var_conta

    IF  sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("DECLARE CURSOR","cq_conta")
        RETURN FALSE
    END IF

    FREE var_conta

    OPEN cq_conta

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_conta")
       RETURN FALSE
    END IF

    FETCH cq_conta INTO mr_campos.num_conta

    IF sqlca.sqlcode <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","cq_conta")
       ELSE
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Argumentos de pesquisa não encontrados.")
       END IF
       CALL pol1302_limpa_campos()
       RETURN FALSE
    END IF

    CALL pol1302_le_plano(mr_campos.num_conta) RETURNING p_status
    LET m_ies_cons = TRUE
    
    RETURN TRUE
    
END FUNCTION

#----------------------------------#
FUNCTION pol1302_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1302_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_conta_ant = mr_campos.num_conta

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_conta INTO mr_campos.num_conta
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_conta INTO mr_campos.num_conta
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_conta INTO mr_campos.num_conta
         WHEN 'P' 
            FETCH PREVIOUS cq_conta INTO mr_campos.num_conta
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_conta")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET mr_campos.num_conta = m_conta_ant
         EXIT WHILE
      ELSE
         SELECT num_conta
           FROM conta_contabil_ronc
          WHERE cod_empresa =  p_cod_empresa
            AND num_conta = mr_campos.num_conta
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1302_le_plano(mr_campos.num_conta) RETURNING p_status
               LET l_achou = TRUE
               EXIT WHILE
            ELSE 
               CALL log003_err_sql("FETCH CURSOR","cq_conta")
               EXIT WHILE
            END IF
         END IF
      END IF               
   
   END WHILE
   
   RETURN l_achou
   
END FUNCTION

#-----------------------#
FUNCTION pol1302_first()#
#-----------------------#

   IF NOT pol1302_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1302_next()#
#----------------------#

   IF NOT pol1302_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1302_previous()#
#--------------------------#

   IF NOT pol1302_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1302_last()#
#----------------------#

   IF NOT pol1302_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION POL1302_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT num_conta
      FROM conta_contabil_ronc
     WHERE cod_empresa =  p_cod_empresa
       AND num_conta = mr_campos.num_conta
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
FUNCTION pol1302_delete()#
#------------------------#

   IF NOT pol1302_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT POL1302_prende_registro() THEN
      RETURN FALSE
   END IF

   DELETE FROM conta_contabil_ronc
    WHERE cod_empresa = p_cod_empresa
      AND num_conta = mr_campos.num_conta

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','conta_contabil_ronc')
      CALL log085_transacao("ROLLBACK")
      CLOSE cq_prende
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   CLOSE cq_prende
   CALL pol1302_limpa_campos()
   CALL pol1302_ativa_desativa(FALSE)
    
   RETURN TRUE
    
END FUNCTION


#-----------------FIM DO PROGRAMA-------------------#

