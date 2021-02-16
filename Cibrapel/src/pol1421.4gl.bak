#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1421                                                 #
# OBJETIVO: TIPO DE PAPELÃO PARA IDENTIFICAÇÃO DO FSC               #
# DATA....: 22/01/2021                                              #
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
       m_construct       VARCHAR(10),
       m_brz_item        VARCHAR(10),
       m_pnl_cabec       VARCHAR(10),
       m_pnl_item        VARCHAR(10),
       m_tipo            VARCHAR(10),
       m_texto           VARCHAR(10),
       m_fsc             VARCHAR(10),
       m_zoom_tipo       VARCHAR(10)

DEFINE mr_cabec          RECORD
       cod_empresa       VARCHAR(02),
       cod_tip_papel     VARCHAR(01),
       texto_fsc	       VARCHAR(50),
       cod_fsc	         VARCHAR(15)
END RECORD
       
DEFINE ma_item           ARRAY[100] OF RECORD
       cod_empresa       VARCHAR(02),
       cod_tip_papel     VARCHAR(01),
       texto_fsc	       VARCHAR(50),
       cod_fsc	         VARCHAR(15),
       filler            CHAR(01)
END RECORD

DEFINE m_ies_cons        SMALLINT,
       m_qtd_item        INTEGER,
       m_msg             CHAR(120),
       m_ind             INTEGER,
       m_carregando      SMALLINT,
       m_opcao           VARCHAR(01),
       m_linha           INTEGER

DEFINE m_den_item        LIKE item.den_item
       
#-----------------#
FUNCTION pol1421()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   IF NOT log0150_verifica_se_tabela_existe("papelao_fsc_885") THEN 
      IF NOT pol1421_cria_tabela() THEN
         RETURN FALSE
      END IF
   END IF

   LET p_versao = "pol1421-12.00.00  "   
   CALL pol1421_menu()

END FUNCTION

#-----------------------------#
FUNCTION pol1421_cria_tabela()#
#-----------------------------#

   CREATE TABLE papelao_fsc_885 (
       cod_empresa       VARCHAR(02),
       cod_tip_papel     VARCHAR(01),
       texto_fsc	       VARCHAR(50),
       cod_fsc	         VARCHAR(15)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','papelao_fsc_885')
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX ix_papelao_fsc_885
    ON papelao_fsc_885(cod_empresa, cod_tip_papel);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','ix_papelao_fsc_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE      
   
END FUNCTION

#----------------------#
FUNCTION pol1421_menu()#
#----------------------#

    DEFINE l_menubar,
           l_create,
           l_delete,
           l_find,
           l_update,
           l_panel,
           l_titulo  VARCHAR(80)

    LET l_titulo = 'TIPO DE PAPELÃO PARA IDENTIFICAÇÃO DO FSC - ',p_versao
    
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
    CALL _ADVPL_set_property(l_find,"EVENT","pol1421_find")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1421_insert")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1421_insert_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1421_insert_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1421_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1421_update_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1421_update_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1421_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1421_monta_cabec(l_panel)
    CALL pol1421_monta_item(l_panel)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1421_monta_cabec(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_lupa            VARCHAR(10)

    LET m_pnl_cabec = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pnl_cabec,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pnl_cabec,"HEIGHT",40)
    CALL _ADVPL_set_property(m_pnl_cabec,"ENABLE",FALSE) 
    #CALL _ADVPL_set_property(m_pnl_cabec,"BACKGROUND_COLOR",231,237,237)
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pnl_cabec)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",8)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"cod_empresa")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",2)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","  Papel:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_tipo = _ADVPL_create_component(NULL,"LCOMBOBOX",l_layout)
    CALL _ADVPL_set_property(m_tipo,"ADD_ITEM"," ","        ")     
    CALL _ADVPL_set_property(m_tipo,"ADD_ITEM","B","Papel branco")     
    CALL _ADVPL_set_property(m_tipo,"ADD_ITEM","K","Papel pardo")     
    CALL _ADVPL_set_property(m_tipo,"VARIABLE",mr_cabec,"cod_tip_papel")    
    CALL _ADVPL_set_property(m_tipo,"VALID","pol1421_valid_item")     

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","  Texto FSC:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_texto = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_texto,"VARIABLE",mr_cabec,"texto_fsc")
    CALL _ADVPL_set_property(m_texto,"LENGTH",50)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","  Código FSC:")    

    LET m_fsc = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_fsc,"VARIABLE",mr_cabec,"cod_fsc")
    CALL _ADVPL_set_property(m_fsc,"LENGTH",15)

END FUNCTION

#---------------------------------------#
FUNCTION pol1421_monta_item(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_pnl_item = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pnl_item,"ALIGN","CENTER")
          
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pnl_item)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brz_item = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_item,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_item,"BEFORE_ROW_EVENT","pol1421_before_row")
    

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Empresa")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_empresa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Papel")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_tip_papel")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Texto FSC")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","texto_fsc")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Código FSC")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_fsc")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_item,"SET_ROWS",ma_item,1)
    CALL _ADVPL_set_property(m_brz_item,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_item,"CAN_REMOVE_ROW",FALSE)

END FUNCTION

#----------------------------#
FUNCTION pol1421_before_row()#
#----------------------------#
      
   LET m_opcao = 'R'
   
   IF m_carregando THEN
      RETURN TRUE
   END IF
      
   LET m_linha = _ADVPL_get_property(m_brz_item,"ROW_SELECTED")

   IF m_linha IS NULL OR m_linha = 0 THEN
      RETURN TRUE
   END IF
   
   CALL pol1421_set_item(m_linha)         
   CALL pol1421_set_compon (TRUE)
   CALL _ADVPL_set_property(m_tipo,"GET_FOCUS")
   CALL pol1421_set_compon(FALSE)
   CALL _ADVPL_set_property(m_brz_item,"SELECT_ITEM",m_linha,1)

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1421_valid_item()#
#----------------------------#      
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF m_opcao <> 'I' THEN
      RETURN TRUE
   END IF

   IF mr_cabec.cod_tip_papel IS NULL THEN
      LET m_msg = 'Informe o tipo de papel'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   SELECT 1 FROM papelao_fsc_885
    WHERE cod_empresa = mr_cabec.cod_empresa
      AND cod_tip_papel = mr_cabec.cod_tip_papel

   IF STATUS = 0 THEN
      LET m_msg = 'Tipo de papel já cadastrado no pol1421'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','item_bloqueio_547')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION
   
#----------------------#
FUNCTION pol1421_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    LET m_opcao = 'P'
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1421_find")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","papelao_fsc_885","papel")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","papelao_fsc_885","cod_tip_papel","Papel",1 {CHAR},1,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","papelao_fsc_885","texto_fsc","Texto FSC",1 {CHAR},50,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1421_pesquisa(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#------------------------------------------#
FUNCTION pol1421_pesquisa(l_where, l_order)#
#------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)
    DEFINE l_ind        INTEGER

    IF l_order IS NULL THEN
       LET l_order = " cod_tip_papel "
    END IF
    
    LET l_sql_stmt = 
       " SELECT * ",
       " FROM papelao_fsc_885 ",
        " WHERE ",l_where CLIPPED,
        " AND cod_empresa =  '",p_cod_empresa,"' ",
        " ORDER BY ",l_order
   
   CALL pol1421_exibe_item(l_sql_stmt)
   CALL pol1421_set_item(1)
   
END FUNCTION

#-------------------------#
FUNCTION pol1421_prepare()#
#-------------------------#

   DEFINE l_sql_stmt CHAR(2000)
                        
   LET l_sql_stmt =
       " SELECT * ",
    "  FROM papelao_fsc_885 ",
    " WHERE cod_empresa =  '",p_cod_empresa,"' "

   CALL pol1421_exibe_item(l_sql_stmt)

END FUNCTION

#--------------------------------------#
FUNCTION pol1421_exibe_item(l_sql_stmt)#
#--------------------------------------#
   
   DEFINE l_sql_stmt   CHAR(2000),
          l_ind        INTEGER

   CALL _ADVPL_set_property(m_brz_item,"CLEAR")
   LET m_carregando = TRUE
   INITIALIZE ma_item TO NULL
   LET l_ind = 1
   
    PREPARE prep_query FROM l_sql_stmt

    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","preparando query")
       RETURN FALSE
    END IF

   DECLARE cq_query CURSOR FOR prep_query
   
   FOREACH cq_query INTO ma_item[l_ind].*
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','carregando dados para a grade')
         EXIT FOREACH
      END IF

      LET l_ind = l_ind + 1
      
      IF l_ind > 100 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou\n',
                     'Serão exibidos apenas 100 registros.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   IF l_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_item,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'Não há registros para os parâmetros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   LET m_carregando = FALSE
        
END FUNCTION

#---------------------------------#
FUNCTION pol1421_set_item(l_linha)#
#---------------------------------#
   
   DEFINE l_linha     INTEGER
   
   LET mr_cabec.cod_empresa = ma_item[l_linha].cod_empresa
   LET mr_cabec.cod_tip_papel = ma_item[l_linha].cod_tip_papel
   LET mr_cabec.texto_fsc = ma_item[l_linha].texto_fsc
   LET mr_cabec.cod_fsc = ma_item[l_linha].cod_fsc

END FUNCTION

#------------------------------------#
FUNCTION pol1421_set_compon(l_status)#
#------------------------------------#

   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pnl_cabec,"ENABLE",l_status)
   LET m_carregando = l_status
               
END FUNCTION

#------------------------#
FUNCTION pol1421_insert()#
#------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   LET m_opcao = 'I'
   INITIALIZE mr_cabec.* TO NULL
   LET mr_cabec.cod_empresa = p_cod_empresa      
   CALL pol1421_set_compon(TRUE)
   CALL _ADVPL_set_property(m_tipo,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1421_insert_canc()#
#-----------------------------#

   CALL pol1421_set_compon(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_cabec.* TO NULL
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1421_insert_conf()#
#-----------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT pol1421_valid_form() THEN
      RETURN FALSE
   END IF
   
   LET m_msg = NULL
   
   CALL  LOG_transaction_begin()   
   
   IF NOT pol1421_insert_dados() THEN
      CALL  LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL  LOG_transaction_commit()
   CALL pol1421_prepare()
   CALL pol1421_set_compon(FALSE)
   
   RETURN TRUE

END FUNCTION        

#----------------------------#
FUNCTION pol1421_valid_form()#
#----------------------------#
   
   DEFINE l_retorno      SMALLINT
   
   LET l_retorno = TRUE
   
   IF mr_cabec.texto_fsc IS NULL THEN
      LET m_msg = 'Infome o texto FSC a sair da nota fiscal'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      LET l_retorno = FALSE
   END IF
   
   RETURN l_retorno

END FUNCTION
   
#------------------------------#
FUNCTION pol1421_insert_dados()#
#------------------------------#
   
   INSERT INTO papelao_fsc_885
    VALUES(mr_cabec.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','papelao_fsc_885')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#-------------------------#
 FUNCTION pol1421_prende()#
#-------------------------#
   
   CALL  LOG_transaction_begin()
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM papelao_fsc_885
     WHERE cod_empresa = mr_cabec.cod_empresa
       AND cod_tip_papel = mr_cabec.cod_tip_papel
     FOR UPDATE 
    
    OPEN cq_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_prende")
       CALL LOG_transaction_rollback()
       RETURN FALSE
    END IF
    
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_prende")
      CALL LOG_transaction_rollback()
      CLOSE cq_prende
      RETURN FALSE
   END IF

END FUNCTION

#------------------------#
FUNCTION pol1421_update()#
#-----------------------#   
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_cabec.cod_tip_papel IS NULL THEN
      LET m_msg = 'Selecione previamente um item na grade'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1421_prende() THEN
      RETURN FALSE
   END IF
   
   LET m_opcao = 'M'
   CALL pol1421_set_compon(TRUE)
   LET m_carregando = TRUE
   CALL _ADVPL_set_property(m_texto,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1421_update_canc()#
#-----------------------------#   
   
   CLOSE cq_prende
   CALL LOG_transaction_rollback()
   CALL pol1421_set_item(m_linha)         
   CALL pol1421_set_compon(FALSE)
   LET m_carregando = FALSE
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1421_update_conf()#
#-----------------------------#   

   UPDATE papelao_fsc_885 
      SET texto_fsc = mr_cabec.texto_fsc,
          cod_fsc = mr_cabec.cod_fsc
    WHERE cod_empresa = mr_cabec.cod_empresa
      AND cod_tip_papel = mr_cabec.cod_tip_papel
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','papelao_fsc_885:uc')
      CALL pol1421_update_canc()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   CLOSE cq_prende
   CALL pol1421_set_compon(FALSE)
   LET m_carregando = FALSE
   CALL pol1421_prepare()
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1421_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF mr_cabec.cod_tip_papel IS NULL THEN
      LET m_msg = 'Selecione um registro para excluir'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1421_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM papelao_fsc_885
     WHERE cod_empresa = mr_cabec.cod_empresa
       AND cod_tip_papel = mr_cabec.cod_tip_papel

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','papelao_fsc_885')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_cabec.* TO NULL
      CALL pol1421_prepare()
   ELSE
      CALL LOG_transaction_rollback()     
   END IF
   
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION
