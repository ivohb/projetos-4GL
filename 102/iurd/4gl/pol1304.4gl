#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1304                                                 #
# OBJETIVO: Alteração da data de inclusão do                        #
#              Conjunto Veículo X Motorista                         #
# AUTOR...: IVO                                                     #
# DATA....: 24/05/16                                                #
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
       m_conjunto        VARCHAR(10),
       m_motorista       VARCHAR(10),
       m_veiculo         VARCHAR(10),
       m_nao_traci_1     VARCHAR(10),
       m_nao_traci_2     VARCHAR(10),
       m_coordenador     VARCHAR(10),
       m_dat_inclusao    VARCHAR(10),
       m_hor_inclusao    VARCHAR(10),
       m_usuario_inc     VARCHAR(10),
       m_dat_fim         VARCHAR(10),
       m_hor_fim         VARCHAR(10),
       m_usuario_fim     VARCHAR(10),
       m_programa_fim    VARCHAR(10),
       m_construct       VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_dat_ant         DATE,
       m_hor_ant         CHAR(08)
       
DEFINE mr_campos         RECORD
       num_conta         CHAR(13),
       den_conta         CHAR(50)
END RECORD

DEFINE m_conta_ant       CHAR(13)

DEFINE mr_conjunto       RECORD
       conjunto                   integer,  
       motorista                  char(12), 
       veiculo                    char(10), 
       veiculo_nao_tracionado_1   char(10), 
       veiculo_nao_tracionado_2   char(10), 
       dat_inclusao               DATETIME YEAR TO SECOND,
       hor_inclusao               char(08),
       usuario_inclusao           char(8),  
       programa_inclusao          char(8),  
       dat_fim                    date, 
       hor_fim                    char(08),
       usuario_fim                char(8),  
       programa_fim               char(8),  
       coordenador                char(8),
       dat_inicial                datetime YEAR TO SECOND,
       dat_final                  datetime YEAR TO SECOND
END RECORD

#-----------------#
FUNCTION pol1304()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1304-12.00.03  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1304_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1304_menu()#
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
           l_modifica  VARCHAR(10)
   
   DEFINE l_titulo   CHAR(65)           

    LET l_titulo = 'ALTERAÇÃO DA DATA DE INCLUSÃO DO CONJUNTO VEÍCULO X MOTORISTA'
    
    CALL pol1304_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1304_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1304_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1304_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1304_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1304_last")

    LET l_modifica = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_modifica,"EVENT","pol1304_modifica")
    CALL _ADVPL_set_property(l_modifica,"CONFIRM_EVENT","pol1304_confirma")
    CALL _ADVPL_set_property(l_modifica,"CANCEL_EVENT","pol1304_cancelar")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1304_cria_campos(l_panel)

    CALL pol1304_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1304_limpa_campos()
#-----------------------------#

   INITIALIZE mr_conjunto.* TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1304_cria_campos(l_container)#
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
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",8)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Conjunto:")    

    LET m_conjunto = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_conjunto,"LENGTH",10)
    CALL _ADVPL_set_property(m_conjunto,"VARIABLE",mr_conjunto,"conjunto")
    CALL _ADVPL_set_property(m_conjunto,"EDITABLE",FALSE) 
    
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Motorista:")    

    LET m_motorista = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_motorista,"LENGTH",12)
    CALL _ADVPL_set_property(m_motorista,"VARIABLE",mr_conjunto,"motorista")
    CALL _ADVPL_set_property(m_motorista,"EDITABLE",FALSE) 

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Veiculo:")    

    LET m_veiculo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_veiculo,"LENGTH",10)
    CALL _ADVPL_set_property(m_veiculo,"VARIABLE",mr_conjunto,"veiculo")
    CALL _ADVPL_set_property(m_veiculo,"EDITABLE",FALSE) 

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Não tracionado 1:")    

    LET m_nao_traci_1 = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_nao_traci_1,"LENGTH",10)
    CALL _ADVPL_set_property(m_nao_traci_1,"VARIABLE",mr_conjunto,"veiculo_nao_tracionado_1")
    CALL _ADVPL_set_property(m_nao_traci_1,"EDITABLE",FALSE) 

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Não tracionado 2:")    

    LET m_nao_traci_2 = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_nao_traci_2,"LENGTH",10)
    CALL _ADVPL_set_property(m_nao_traci_2,"VARIABLE",mr_conjunto,"veiculo_nao_tracionado_2")
    CALL _ADVPL_set_property(m_nao_traci_2,"EDITABLE",FALSE) 

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Coordenador:")    

    LET m_coordenador = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_coordenador,"LENGTH",8)
    CALL _ADVPL_set_property(m_coordenador,"VARIABLE",mr_conjunto,"coordenador")
    CALL _ADVPL_set_property(m_coordenador,"EDITABLE",FALSE) 

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Data Inclusão:")    

    LET m_dat_inclusao = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_inclusao,"VARIABLE",mr_conjunto,"dat_inclusao")
    CALL _ADVPL_set_property(m_dat_inclusao,"EDITABLE",TRUE) 

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Hora Inclusão:")    

    LET m_hor_inclusao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_hor_inclusao,"LENGTH",8)
    CALL _ADVPL_set_property(m_hor_inclusao,"VARIABLE",mr_conjunto,"hor_inclusao")
    CALL _ADVPL_set_property(m_hor_inclusao,"PICTURE","##:##:##")
    CALL _ADVPL_set_property(m_hor_inclusao,"EDITABLE",TRUE) 

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","user Inclusão:")    

    LET m_usuario_inc = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_usuario_inc,"LENGTH",8)
    CALL _ADVPL_set_property(m_usuario_inc,"VARIABLE",mr_conjunto,"usuario_inclusao")
    CALL _ADVPL_set_property(m_usuario_inc,"EDITABLE",FALSE) 

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Data fim:")    

    LET m_dat_fim = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_fim,"LENGTH",10)
    CALL _ADVPL_set_property(m_dat_fim,"VARIABLE",mr_conjunto,"dat_fim")
    CALL _ADVPL_set_property(m_dat_fim,"EDITABLE",FALSE) 

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Hora fim:")    

    LET m_hor_fim = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_hor_fim,"LENGTH",8)
    CALL _ADVPL_set_property(m_hor_fim,"VARIABLE",mr_conjunto,"hor_fim")
    CALL _ADVPL_set_property(m_hor_fim,"EDITABLE",FALSE) 

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","User fim:")    

    LET m_usuario_fim = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_usuario_fim,"LENGTH",8)
    CALL _ADVPL_set_property(m_usuario_fim,"VARIABLE",mr_conjunto,"usuario_fim")
    CALL _ADVPL_set_property(m_usuario_fim,"EDITABLE",FALSE) 

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

END FUNCTION

#----------------------------------------#
FUNCTION pol1304_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
    
   CALL _ADVPL_set_property(m_dat_inclusao,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_hor_inclusao,"EDITABLE",l_status)

END FUNCTION

#----------------------#
FUNCTION pol1304_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","POL1304_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","frt_conjunto_veiculo_motorista","Conjuntos")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","frt_conjunto_veiculo_motorista","conjunto","Conjunto",1 {CHAR},10,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","frt_conjunto_veiculo_motorista","motorista","Motorista",1 {CHAR},12,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","frt_conjunto_veiculo_motorista","veiculo","Veiculo",1 {CHAR},10,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","frt_conjunto_veiculo_motorista","dat_inclusao","Inclusão",1 {CHAR},19,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","frt_conjunto_veiculo_motorista","coordenador","Coordenador",1 {CHAR},08,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1304_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1304_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = "1"
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = "SELECT conjunto ",
                      " FROM frt_conjunto_veiculo_motorista",
                     " WHERE ",l_where CLIPPED,
                     " ORDER BY ",l_order

    PREPARE var_conjunto FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","frt_conjunto_veiculo_motorista:prepare")
       RETURN FALSE
    END IF

    DECLARE cq_conjunto SCROLL CURSOR WITH HOLD FOR var_conjunto

    IF  sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("DECLARE CURSOR","cq_conjunto")
        RETURN FALSE
    END IF

    FREE var_conjunto

    OPEN cq_conjunto

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_conjunto")
       RETURN FALSE
    END IF

    FETCH cq_conjunto INTO mr_conjunto.conjunto

    IF sqlca.sqlcode <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","cq_conjunto")
       ELSE
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Argumentos de pesquisa não encontrados.")
       END IF
       CALL pol1304_limpa_campos()
       RETURN FALSE
    END IF

    CALL pol1304_le_conjunto(mr_conjunto.conjunto) RETURNING p_status
    LET m_ies_cons = TRUE
    
    RETURN TRUE
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1304_le_conjunto(l_conjunto)#
#---------------------------------------#
   
   DEFINE l_conjunto INTEGER
   
   LET m_msg = ''

   SELECT motorista,               
          veiculo,                 
          veiculo_nao_tracionado_1,
          veiculo_nao_tracionado_2,
          dat_inclusao,            
          usuario_inclusao,        
          programa_inclusao,       
          dat_fim,                 
          usuario_fim,             
          programa_fim,            
          coordenador 
     INTO mr_conjunto.motorista,                
          mr_conjunto.veiculo,                  
          mr_conjunto.veiculo_nao_tracionado_1, 
          mr_conjunto.veiculo_nao_tracionado_2, 
          mr_conjunto.dat_inicial,
          mr_conjunto.usuario_inclusao, 
          mr_conjunto.programa_inclusao,
          mr_conjunto.dat_final,
          mr_conjunto.usuario_fim, 
          mr_conjunto.programa_fim,
          mr_conjunto.coordenador  
     FROM frt_conjunto_veiculo_motorista
    WHERE conjunto =  l_conjunto         
      
   IF STATUS = 100 THEN
      LET m_msg = 'Conjunto inexistente no logix.'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','frt_conjunto_veiculo_motorista:le_conjunto')         
         RETURN FALSE
      END IF
   END IF
   
   LET mr_conjunto.dat_inclusao = EXTEND(mr_conjunto.dat_inicial, YEAR TO DAY)
   LET mr_conjunto.hor_inclusao = EXTEND(mr_conjunto.dat_inicial, HOUR TO SECOND)
   LET mr_conjunto.dat_fim = EXTEND(mr_conjunto.dat_final, YEAR TO DAY)
   LET mr_conjunto.hor_fim = EXTEND(mr_conjunto.dat_final, HOUR TO SECOND)   
   
   RETURN TRUE

END FUNCTION


#----------------------#
FUNCTION pol1304_first()
#----------------------#

   IF NOT pol1304_tem_consulta() THEN
      RETURN FALSE
   END IF

    FETCH FIRST cq_conjunto INTO mr_conjunto.conjunto

    IF  sqlca.sqlcode <> 0 THEN
        IF  sqlca.sqlcode <> NOTFOUND THEN
            CALL log003_err_sql("FETCH CURSOR","cq_conjunto")
        ELSE
            LET m_msg = "Não existem mais registros nesta direção."
            CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
        END IF

        RETURN FALSE
    END IF

    CALL pol1304_le_conjunto(mr_conjunto.conjunto) RETURNING p_status

    RETURN TRUE
    
END FUNCTION

#---------------------#
FUNCTION pol1304_next()
#---------------------#

   IF NOT pol1304_tem_consulta() THEN
      RETURN FALSE
   END IF

    FETCH NEXT cq_conjunto INTO mr_conjunto.conjunto

    IF  sqlca.sqlcode <> 0 THEN
        IF  sqlca.sqlcode <> NOTFOUND THEN
            CALL log003_err_sql("FETCH CURSOR","cq_conjunto")
        ELSE
            LET m_msg = "Não existem mais registros nesta direção."
            CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
        END IF

        RETURN FALSE
    END IF

    CALL pol1304_le_conjunto(mr_conjunto.conjunto) RETURNING p_status

    RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1304_previous()
#-------------------------#

   IF NOT pol1304_tem_consulta() THEN
      RETURN FALSE
   END IF

    FETCH PREVIOUS cq_conjunto INTO mr_conjunto.conjunto

    IF  sqlca.sqlcode <> 0 THEN
        IF  sqlca.sqlcode <> NOTFOUND THEN
            CALL log003_err_sql("FETCH CURSOR","cq_conjunto")
        ELSE
            LET m_msg = "Não existem mais registros nesta direção."
            CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
        END IF

        RETURN FALSE
    END IF

    CALL pol1304_le_conjunto(mr_conjunto.conjunto) RETURNING p_status

    RETURN TRUE

END FUNCTION

#----------------------#
FUNCTION pol1304_last()
#----------------------#

   IF NOT pol1304_tem_consulta() THEN
      RETURN FALSE
   END IF

    FETCH LAST cq_conjunto INTO mr_conjunto.conjunto

    IF  sqlca.sqlcode <> 0 THEN
        IF  sqlca.sqlcode <> NOTFOUND THEN
            CALL log003_err_sql("FETCH CURSOR","cq_conjunto")
        ELSE
            LET m_msg = "Não existem mais registros nesta direção."
            CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
        END IF

        RETURN FALSE
    END IF

    CALL pol1304_le_conjunto(mr_conjunto.conjunto) RETURNING p_status

    RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1304_modifica()#
#--------------------------#

   IF NOT pol1304_tem_consulta() THEN
      RETURN FALSE
   END IF
   
   IF mr_conjunto.dat_fim IS NOT NULL THEN
      LET m_msg = 'Conjunto já encerrado não pode ser alterado.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
      
   
   LET m_dat_ant = mr_conjunto.dat_inclusao
   LET m_hor_ant = mr_conjunto.hor_inclusao
   
   CALL pol1304_ativa_desativa(TRUE)   
   CALL _ADVPL_set_property(m_dat_inclusao,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1304_tem_consulta()#
#------------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa. Clique em Pesquisar.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#_-------------------------#
FUNCTION pol1304_cancelar()#
#_-------------------------#

   LET mr_conjunto.dat_inclusao = m_dat_ant 
   LET mr_conjunto.hor_inclusao = m_hor_ant

   CALL pol1304_ativa_desativa(FALSE)
      
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1304_confirma()#
#--------------------------#

   IF mr_conjunto.dat_inclusao IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a DATA da inclusão.")
      CALL _ADVPL_set_property(m_dat_inclusao,"GET_FOCUS")
      RETURN FALSE      
   END IF

   IF mr_conjunto.hor_inclusao IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a HORA da inclusão.")
      CALL _ADVPL_set_property(m_hor_inclusao,"GET_FOCUS")
      RETURN FALSE      
   END IF
   
   IF mr_conjunto.hor_inclusao[1,2] > 23 OR mr_conjunto.hor_inclusao[1,2] = ' ' OR
      mr_conjunto.hor_inclusao[4,5] > 59 OR mr_conjunto.hor_inclusao[4,5] = ' ' OR
      mr_conjunto.hor_inclusao[7,8] > 59 OR mr_conjunto.hor_inclusao[7,8] = ' ' THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Hora inválida.")
      CALL _ADVPL_set_property(m_hor_inclusao,"GET_FOCUS")
      RETURN FALSE      
   END IF
      
   BEGIN WORK
   
   IF NOT pol1304_salva_alteracao() THEN
      ROLLBACK WORK
      RETURN FALSE
   END IF
   
   COMMIT WORK
   
   CALL pol1304_ativa_desativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1304_salva_alteracao()#
#---------------------------------#
   
   DEFINE l_new_date CHAR(10),
          l_new_date_time CHAR(19)

   LET l_new_date = EXTEND(mr_conjunto.dat_inclusao, YEAR TO DAY)
   
  SELECT COUNT (*) 
    INTO m_count
    FROM frt_conjunto_veiculo_motorista  
   WHERE veiculo = mr_conjunto.veiculo
     AND motorista = mr_conjunto.motorista
     AND TO_CHAR(dat_inclusao, 'YYYY-MM-DD') <= l_new_date
     AND TO_CHAR(dat_fim, 'YYYY-MM-DD') >= l_new_date
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','frt_conjunto_veiculo_motorista:count')
      RETURN FALSE
   END IF
   
   IF m_count > 0 THEN
      LET m_msg = 'Na tada/hora informadas o veiculo já está reservado.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_dat_inclusao,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   LET l_new_date_time = EXTEND(mr_conjunto.dat_inclusao, YEAR TO DAY)
   LET l_new_date_time = l_new_date_time CLIPPED, ' ', mr_conjunto.hor_inclusao CLIPPED
   LET mr_conjunto.dat_inclusao = l_new_date_time
      
   UPDATE frt_conjunto_veiculo_motorista
      SET dat_inclusao = mr_conjunto.dat_inclusao
    WHERE conjunto = mr_conjunto.conjunto
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','frt_conjunto_veiculo_motorista')
      RETURN FALSE
   END IF
   
   IF NOT pol1304_ins_audit() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1304_ins_audit()#
#---------------------------#

   DEFINE l_parametro     RECORD
       cod_empresa   LIKE audit_logix.cod_empresa,
       texto         LIKE audit_logix.texto,
       num_programa  LIKE audit_logix.num_programa,
       usuario       LIKE audit_logix.usuario
   END RECORD
   
   DEFINE l_conjunto CHAR(12)
   
   LET l_conjunto = mr_conjunto.conjunto

   LET l_parametro.cod_empresa = p_cod_empresa
   LET l_parametro.num_programa = 'POL1304'
   LET l_parametro.usuario = p_user
   
   LET l_parametro.texto = 'ALTERACAO DA DATA DE INCLUSAO DO CONJUNTO ', l_conjunto CLIPPED

   IF NOT func002_grava_auadit(l_parametro) THEN
      RETURN FALSE
   END IF
         
   RETURN TRUE

END FUNCTION
   