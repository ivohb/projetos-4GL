#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1281                                                 #
# OBJETIVO: ALTERAÇÃO DO PCT DE JUROS DE MORA DOS TITULOS DO CRE    #
# AUTOR...: IVO                                                     #
# DATA....: 25/02/15                                                #
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
       m_portador        VARCHAR(10),
       m_cliente         VARCHAR(10),
       m_datini          VARCHAR(10),
       m_datfim          VARCHAR(10),
       m_empresa         VARCHAR(10),
       m_tipo            VARCHAR(10),
       m_docum           VARCHAR(10),
       m_lupa_empresa    VARCHAR(10),
       m_lupa_portador   VARCHAR(10),
       m_lupa_cliente    VARCHAR(10),
       m_zoom_empresa    VARCHAR(10),
       m_zoom_portador   VARCHAR(10),
       m_zoom_cliente    VARCHAR(10),
       m_juro            VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_base_calc       DECIMAL(12,2),
       m_tip_calc        VARCHAR(01),
       m_pct_cli         DECIMAL(5,2),
       m_pct_mora        DECIMAL(5,2),
       m_pct_juro        DECIMAL(5,2),
       m_tip_juros       VARCHAR(01),
       m_tip_dias        VARCHAR(01),
       m_qtd_dias        INTEGER,
       m_val_juros       DECIMAL(12,2),
       m_tot_juros       DECIMAL(12,2),
       m_dat_atualiz     DATE

DEFINE mr_parametro      RECORD
       cod_empresa       VARCHAR(02),
       den_empresa       VARCHAR(36),
       dat_ini           DATE,
       dat_fim           DATE,
       cod_portador      DECIMAL(4,0),
       nom_portador      VARCHAR(40),
       cod_cliente       VARCHAR(15),
       nom_cliente       VARCHAR(40),
       ies_tip_docum     VARCHAR(02),
       num_docum         VARCHAR(14),
       pct_info          DECIMAL(5,2)       
END RECORD

DEFINE mr_docum          RECORD
       cod_empresa       VARCHAR(02),
       num_docum         VARCHAR(14),
       ies_tip_docum     VARCHAR(02),
       pct_juro_mora     DECIMAL(5,2)
END RECORD
 
#-----------------#
FUNCTION pol1281()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1281-11.00.03  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1281_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1281_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_print       VARCHAR(10)
     
       #Criação da janela do programa
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE","ALTERAÇÃO DO PERCENTUAL DE JUROS DE MORA DOS DOCUMENTOS")

       #Criação da barra de status
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

       #Criação da barra de menu
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

       #Criação do botão informar
    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1281_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1281_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1281_cancelar")

       #Criação do botão processar
    LET l_print = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_print,"EVENT","pol1281_processar")

       #Criação do botão sair
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    #Criação de um painel, para organizar os campos de pesquisa.    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    #Chama FUNCTION para criação dos campos
    CALL pol1281_cria_campos(l_panel)

    CALL pol1281_ativa_desativa(FALSE)

       #Exibe a janela do programa
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1281_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_den_empresa     VARCHAR(10),
           l_nom_portador    VARCHAR(10),
           l_nom_cliente     VARCHAR(10),
           l_panel_campos    VARCHAR(10)

    #criação de painel no topo utilizado como margem superior
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",40)

    {#criação de painel da esquerda utilizado como margem esquerda
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
    CALL _ADVPL_set_property(l_panel,"WIDTH",300)}

    #criação de painel para distribuição dos campos de tela
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    #criação um LLAYOUT c/ 4 colunas, para distribuiçao dos campos com popup 
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",4)

    #criação do campo para entrada da empresa
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    

    LET m_empresa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_empresa,"LENGTH",2)
    CALL _ADVPL_set_property(m_empresa,"VARIABLE",mr_parametro,"cod_empresa")
    CALL _ADVPL_set_property(m_empresa,"PICTURE","@!")
    #FUNCTION para validação da entrada. Se retornar TRUE, a entrada será válida. Se 
    #retornar FALSE, o usuário terá que re-digitar a informação
    CALL _ADVPL_set_property(m_empresa,"VALID","pol1281_checa_empresa")

    #criação/definição do icone do zoom
    LET m_lupa_empresa = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_empresa,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_empresa,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_empresa,"CLICK_EVENT","pol1281_zoom_empresa")

    #criação/definição do campos para exibir o nome da empresa
    LET l_den_empresa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_den_empresa,"LENGTH",36) 
    CALL _ADVPL_set_property(l_den_empresa,"EDITABLE",FALSE) #não permite edição do conteúdo
    CALL _ADVPL_set_property(l_den_empresa,"VARIABLE",mr_parametro,"den_empresa")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    #criação do campo para entrada do portador
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Portador:")    

    LET m_portador = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_portador,"VARIABLE",mr_parametro,"cod_portador")
    CALL _ADVPL_set_property(m_portador,"LENGTH",4,0)
    CALL _ADVPL_set_property(m_portador,"PICTURE","@E ####")
    CALL _ADVPL_set_property(m_portador,"VALID","pol1281_checa_portador")

    #criação/definição do icone do zoom
    LET m_lupa_portador = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_portador,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_portador,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_portador,"CLICK_EVENT","pol1281_zoom_portador")

    #criação/definição do campos para exibir o nome do portador
    LET l_nom_portador = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_nom_portador,"LENGTH",40) 
    CALL _ADVPL_set_property(l_nom_portador,"EDITABLE",FALSE) #não permite edição do conteúdo
    CALL _ADVPL_set_property(l_nom_portador,"VARIABLE",mr_parametro,"nom_portador")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    #criação do campo para entrada do cliente
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    

    LET m_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cliente,"VARIABLE",mr_parametro,"cod_cliente")
    CALL _ADVPL_set_property(m_cliente,"LENGTH",15)
    CALL _ADVPL_set_property(m_cliente,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cliente,"VALID","pol1281_checa_cliente")

    #criação/definição do icone do zoom
    LET m_lupa_cliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_cliente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cliente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cliente,"CLICK_EVENT","pol1281_zoom_cliente")

    #criação/definição do campos para exibir o nome do cliente
    LET l_nom_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_nom_cliente,"LENGTH",40) 
    CALL _ADVPL_set_property(l_nom_cliente,"EDITABLE",FALSE) #não permite edição do conteúdo
    CALL _ADVPL_set_property(l_nom_cliente,"VARIABLE",mr_parametro,"nom_cliente")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    #criação do campo para entrada do número do titulo
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Titulo:")
    
    LET m_docum = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_docum,"VARIABLE",mr_parametro,"num_docum")
    CALL _ADVPL_set_property(m_docum,"LENGTH",14)
    CALL _ADVPL_set_property(m_docum,"PICTURE","@!")
    CALL _ADVPL_set_property(m_docum,"VALID","pol1281_checa_docum")

    #criação do campo para entrada do tipo de documento
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Tip:")
    
    LET m_tipo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_tipo,"VARIABLE",mr_parametro,"ies_tip_docum")
    CALL _ADVPL_set_property(m_tipo,"LENGTH",3)
    CALL _ADVPL_set_property(m_tipo,"PICTURE","@!")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Vencto de:")
    
    LET m_datini = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_datini,"VARIABLE",mr_parametro,"dat_ini")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Até:")
    
    LET m_datfim = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_datfim,"VARIABLE",mr_parametro,"dat_fim")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")
    
    #criação/definição do campos para entrada da taxa de juros

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Pct juros:")    

    LET m_juro = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_juro,"VARIABLE",mr_parametro,"pct_info")
    CALL _ADVPL_set_property(m_juro,"LENGTH",5,2)
    CALL _ADVPL_set_property(m_juro,"PICTURE","@E ###.##")

END FUNCTION


#habilita/desabilita os campos de tela

#----------------------------------------#
FUNCTION pol1281_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
    
   CALL _ADVPL_set_property(m_empresa,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_empresa,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_portador,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_portador,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_cliente,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_cliente,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_docum,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_tipo,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_datini,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_datfim,"EDITABLE",l_status)

END FUNCTION

#--------------------------#
FUNCTION pol1281_informar()#
#--------------------------#

   CALL pol1281_ativa_desativa(TRUE)
   CALL pol1281_limpa_campos()
   
   LET m_ies_info = FALSE
   
   RETURN TRUE 
    
END FUNCTION

#-----------------------------#
FUNCTION pol1281_limpa_campos()
#-----------------------------#

   INITIALIZE mr_parametro.* TO NULL
    
END FUNCTION

#Chamada quando o usuário 
#confirma a edição dos parametros

#---------------------------#
FUNCTION pol1281_confirmar()#
#---------------------------#
   
   {IF mr_parametro.dat_ini IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a data inicial")
      CALL _ADVPL_set_property(m_datini,"GET_FOCUS")
      RETURN FALSE      
   END IF
   
   IF mr_parametro.dat_fim IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a data final")
      CALL _ADVPL_set_property(m_datfim,"GET_FOCUS")
      RETURN FALSE      
   END IF}

   IF mr_parametro.dat_fim IS NOT NULL AND
        mr_parametro.dat_ini IS NOT NULL THEN
      IF mr_parametro.dat_fim < mr_parametro.dat_ini THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Período inválido!")
         CALL _ADVPL_set_property(m_datini,"GET_FOCUS")
         RETURN FALSE      
      END IF
   END IF
   
   LET m_ies_info = TRUE
   
   RETURN TRUE

END FUNCTION


#Chamada quando o usuário 
#cancela a edição dos parametros

#--------------------------#
FUNCTION pol1281_cancelar()#
#--------------------------#

    CALL pol1281_limpa_campos()
    CALL pol1281_ativa_desativa(FALSE)
    RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1281_checa_empresa()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   INITIALIZE mr_parametro.den_empresa TO NULL
   
   IF mr_parametro.cod_empresa IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT den_empresa
     INTO mr_parametro.den_empresa
     FROM empresa
    WHERE cod_empresa = mr_parametro.cod_empresa
   
   IF STATUS = 100 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Empresa inexistente.")
      RETURN FALSE
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1281_zoom_empresa()#
#------------------------------#

    DEFINE l_cod_empresa       LIKE empresa.cod_empresa,
           l_den_empresa       LIKE empresa.den_empresa
    
    IF  m_zoom_empresa IS NULL THEN
        #Se chamado pela 1a. vez, cria o zoom
        LET m_zoom_empresa = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_empresa,"ZOOM","zoom_empresa")
    END IF
    
    #exibe a janela do zoom
    CALL _ADVPL_get_property(m_zoom_empresa,"ACTIVATE")
    
    #obtém o código e nome da empresa da linha atual da grade de zoom
    LET l_cod_empresa = _ADVPL_get_property(m_zoom_empresa,"RETURN_BY_TABLE_COLUMN","empresa","cod_empresa")
    LET l_den_empresa = _ADVPL_get_property(m_zoom_empresa,"RETURN_BY_TABLE_COLUMN","empresa","den_empresa")

    IF  l_cod_empresa IS NOT NULL THEN
        LET mr_parametro.cod_empresa = l_cod_empresa
        LET mr_parametro.den_empresa = l_den_empresa
    END IF

END FUNCTION
      
#--------------------------------#
FUNCTION pol1281_checa_portador()#
#--------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   INITIALIZE mr_parametro.nom_portador TO NULL

   IF mr_parametro.cod_portador IS NULL THEN
      RETURN TRUE
   END IF

   SELECT nom_portador
     INTO mr_parametro.nom_portador
     FROM portador
    WHERE cod_portador = mr_parametro.cod_portador
   
   IF STATUS = 100 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Portador inexistente.")
      RETURN FALSE
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','Portador')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1281_zoom_portador()#
#-------------------------------#

    DEFINE l_cod_portador       LIKE portador.cod_portador,
           l_nom_portador       LIKE portador.nom_portador
    
    IF  m_zoom_portador IS NULL THEN
        #Se chamado pela 1a. vez, cria o zoom
        LET m_zoom_portador = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_portador,"ZOOM","zoom_portador")
    END IF
    
    #exibe a janela do zoom
    CALL _ADVPL_get_property(m_zoom_portador,"ACTIVATE")
    
    #obtém o código e nome do portador da linha atual da grade de zoom
    LET l_cod_portador = _ADVPL_get_property(m_zoom_portador,"RETURN_BY_TABLE_COLUMN","portador","cod_portador")
    LET l_nom_portador = _ADVPL_get_property(m_zoom_portador,"RETURN_BY_TABLE_COLUMN","portador","nom_portador")

    IF  l_cod_portador IS NOT NULL THEN
        LET mr_parametro.cod_portador = l_cod_portador
        LET mr_parametro.nom_portador = l_nom_portador
    END IF

END FUNCTION
      
#-------------------------------#
FUNCTION pol1281_checa_cliente()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   INITIALIZE mr_parametro.nom_cliente TO NULL

   IF mr_parametro.cod_cliente IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT nom_cliente
     INTO mr_parametro.nom_cliente
     FROM clientes
    WHERE cod_cliente = mr_parametro.cod_cliente
   
   IF STATUS = 100 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Cliente inexistente.")
      RETURN FALSE
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','Cliente')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1281_zoom_cliente()#
#------------------------------#

    DEFINE l_cod_cliente       LIKE clientes.cod_cliente,
           l_nom_cliente       LIKE clientes.nom_cliente
    
    IF  m_zoom_cliente IS NULL THEN
        #Se chamado pela 1a. vez, cria o zoom
        LET m_zoom_cliente = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_cliente,"ZOOM","zoom_clientes")
    END IF
    
    #exibe a janela do zoom
    CALL _ADVPL_get_property(m_zoom_cliente,"ACTIVATE")
    
    #obtém o código e nome da cliente da linha atual da grade de zoom
    LET l_cod_cliente = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_nom_cliente = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")

    IF  l_cod_cliente IS NOT NULL THEN
        LET mr_parametro.cod_cliente = l_cod_cliente
        LET mr_parametro.nom_cliente = l_nom_cliente
    END IF

END FUNCTION

#-----------------------------#
FUNCTION pol1281_checa_docum()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   IF mr_parametro.num_docum IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT COUNT(num_docum)   
     INTO m_count
     FROM docum
    WHERE num_docum = mr_parametro.num_docum

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','docum')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Título inexistente.")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1281_processar()#
#---------------------------#

   IF NOT m_ies_info THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe os parâmetros previamente")
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a alteração da taxa de juros?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   CALL LOG_progresspopup_start("Alteração de % de juro","pol1281_alterar","PROCESS")
  
   IF NOT p_status THEN 
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
                "Operação cancelada")
      RETURN FALSE
   ELSE
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação efetuada com sucesso.")
   END IF
               
   RETURN FALSE
   
END FUNCTION

#-------------------------#
FUNCTION pol1281_alterar()#
#-------------------------#
   
   LET p_status = pol1281_le_titulos()
   
   RETURN p_status

END FUNCTION

#------------------------------#
FUNCTION pol1281_le_titulos()#
#------------------------------#
   
   DEFINE sql_stmt      VARCHAR(5000),
          l_progres     SMALLINT

   LET sql_stmt =
       " SELECT COUNT(*) FROM docum d ",
       "  WHERE d.val_saldo > 0 ",
       "    AND d.ies_pgto_docum <> 'T' ",
       "    AND d.ies_situa_docum <> 'C' "

   IF mr_parametro.dat_ini IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED,
       " AND d.dat_vencto_s_desc >= '",mr_parametro.dat_ini,"' "
   END IF

   IF mr_parametro.dat_fim IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED,
       " AND d.dat_vencto_s_desc <= '",mr_parametro.dat_fim,"' "
   END IF
       
   IF mr_parametro.cod_empresa IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND d.cod_empresa = '",mr_parametro.cod_empresa,"' "
   END IF

   IF mr_parametro.cod_portador IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND d.cod_portador = ", mr_parametro.cod_portador
   END IF

   IF mr_parametro.cod_cliente IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND d.cod_cliente = '",mr_parametro.cod_cliente,"' "
   END IF

   IF mr_parametro.num_docum IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND d.num_docum = '",mr_parametro.num_docum,"' "
   END IF

   IF mr_parametro.ies_tip_docum IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND d.ies_tip_docum = '",mr_parametro.ies_tip_docum,"' "
   END IF
   
   PREPARE var_count FROM sql_stmt   

   IF STATUS <> 0 THEN
      CALL log003_err_sql("PREPARE","var_count")  
      RETURN FALSE          
   END IF 
   
   DECLARE cq_count CURSOR FOR var_count
   OPEN cq_count
   FETCH cq_count INTO m_count
   CLOSE cq_count
   
   IF m_count = 0 THEN
      LET m_msg = 'Nenhum registro foi encontrado,\n',
                  'para os parâmetros informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE   
   END IF

   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   SELECT par_cre.dat_proces_doc 
     INTO m_dat_atualiz 
     FROM par_cre
             
   LET sql_stmt =
       " SELECT d.cod_empresa, d.num_docum, d.ies_tip_docum, d.pct_juro_mora ",
       "   FROM docum d ",
       "  WHERE d.val_saldo > 0 ",
       "    AND d.ies_pgto_docum <> 'T' ",
       "    AND d.ies_situa_docum <> 'C' "

   IF mr_parametro.dat_ini IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED,
       " AND d.dat_vencto_s_desc >= '",mr_parametro.dat_ini,"' "
   END IF

   IF mr_parametro.dat_fim IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED,
       " AND d.dat_vencto_s_desc <= '",mr_parametro.dat_fim,"' "
   END IF

   IF mr_parametro.cod_empresa IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND d.cod_empresa = '",mr_parametro.cod_empresa,"' "
   END IF

   IF mr_parametro.cod_portador IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND d.cod_portador = ", mr_parametro.cod_portador
   END IF

   IF mr_parametro.cod_cliente IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND d.cod_cliente = '",mr_parametro.cod_cliente,"' "
   END IF

   IF mr_parametro.num_docum IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND d.num_docum = '",mr_parametro.num_docum,"' "
   END IF

   IF mr_parametro.ies_tip_docum IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND d.ies_tip_docum = '",mr_parametro.ies_tip_docum,"' "
   END IF
      
   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','var_query')
      RETURN FALSE
   END IF
      
   DECLARE cq_padrao CURSOR WITH HOLD FOR var_query

   FOREACH cq_padrao INTO 
      mr_docum.cod_empresa, 
      mr_docum.num_docum,   
      mr_docum.ies_tip_docum,
      mr_docum.pct_juro_mora

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_padrao')
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      CALL log085_transacao("BEGIN")
      
      IF NOT pol1281_atu_docum() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
      CALL log085_transacao("COMMIT")
         
   END FOREACH

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1281_atu_docum()#
#---------------------------#

   UPDATE docum
      SET pct_juro_mora = mr_parametro.pct_info,
          dat_atualiz = m_dat_atualiz
    WHERE cod_empresa = mr_docum.cod_empresa
      AND num_docum = mr_docum.num_docum
      AND ies_tip_docum = mr_docum.ies_tip_docum

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','docum')
      RETURN FALSE
   END IF
   
    IF NOT pol1281_ins_obs() THEN
       RETURN FALSE
    END IF
   
   RETURN TRUE

END FUNCTION


#-------------------------#
FUNCTION pol1281_ins_obs()#
#-------------------------#

   DEFINE l_docum_obs       RECORD
       cod_empresa          CHAR(2), 
       num_docum            CHAR(14),
       ies_tip_docum        CHAR(2), 
       num_seq_docum        INTEGER, 
       dat_obs              DATE,    
       tex_obs_1            CHAR(70),
       tex_obs_2            CHAR(70),
       tex_obs_3            CHAR(70),
       dat_atualiz          DATE    
   END RECORD
   
   DEFINE l_dat_txt         CHAR(10),
          l_hor_txt         CHAR(08),
          l_pct_ant         CHAR(10),
          l_pct_dep         CHAR(10)

   LET l_dat_txt = TODAY
   LET l_hor_txt = TIME
   LET l_pct_ant = mr_docum.pct_juro_mora
   LET l_pct_dep = mr_parametro.pct_info
   
   LET l_docum_obs.cod_empresa = mr_docum.cod_empresa
   LET l_docum_obs.num_docum = mr_docum.num_docum
   LET l_docum_obs.ies_tip_docum = mr_docum.ies_tip_docum
   LET l_docum_obs.dat_obs = m_dat_atualiz
   LET l_docum_obs.tex_obs_1 = 
        'ALTERACAO DO PCT DE JUROS DE  ', l_pct_ant CLIPPED, ' P/ ', l_pct_dep
   LET l_docum_obs.tex_obs_2 = 'OCORRIDO EM ', l_dat_txt CLIPPED, ' AS ', l_hor_txt
   LET l_docum_obs.tex_obs_3 = 'PELO LOGIN DO ', p_user CLIPPED, ' NO POL1281'
   LET l_docum_obs.dat_atualiz = TODAY
   
   SELECT MAX(num_seq_docum)
     INTO l_docum_obs.num_seq_docum
     FROM docum_obs
    WHERE cod_empresa = mr_docum.cod_empresa
      AND num_docum = mr_docum.num_docum
      AND ies_tip_docum = mr_docum.ies_tip_docum
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','docum_obs')
      RETURN FALSE
   END IF

   IF l_docum_obs.num_seq_docum IS NULL THEN
      LET l_docum_obs.num_seq_docum = 1
   ELSE
      LET l_docum_obs.num_seq_docum = l_docum_obs.num_seq_docum + 1
   END IF
   
   INSERT INTO docum_obs
    VALUES(l_docum_obs.*)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','docum_obs')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
            