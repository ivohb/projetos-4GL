#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1303                                                 #
# OBJETIVO: INCLUSÃO DE BENS A PARTIR DE RESENVA DE ESTOQUE         #
# AUTOR...: IVO                                                     #
# DATA....: 02/12/15                                                #
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
       m_item            VARCHAR(10),
       m_datini          VARCHAR(10),
       m_datfim          VARCHAR(10),
       m_lupa_item       VARCHAR(10),
       m_zoom_item       VARCHAR(10),
       m_browse          VARCHAR(10),
       m_invent          VARCHAR(10),
       m_lupa_invent     VARCHAR(10),
       m_zoom_invent     VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_ies_mod         SMALLFLOAT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ind             INTEGER,
       m_dat_atu         DATE,
       m_checa_linha     SMALLINT,
       m_num_parcela     INTEGER,
       m_cod_agrupam     CHAR(04),
       m_conta_contabil  CHAR(23),
       m_qtd_moeda       INTEGER


DEFINE mr_parametro      RECORD
       cod_item          VARCHAR(15),
       den_item          VARCHAR(40),
       dat_ini           DATE,
       dat_fim           DATE,
       num_invent        CHAR(10)
END RECORD

DEFINE ma_reserva        ARRAY[1000] OF RECORD
       num_reserva       DECIMAL(9,0),
       cod_item          VARCHAR(15),
       den_item          VARCHAR(18),
       qtd_reservada     DECIMAL(10,3),
       cod_unid_med      CHAR(03),
       dat_solicitacao   DATE,
       ies_incluir       VARCHAR(01),
       filler            VARCHAR(1)
END RECORD

DEFINE ma_moeda          ARRAY[100] OF RECORD
       cod_moeda         LIKE cotacao.cod_moeda,
       val_cotacao       LIKE cotacao.val_cotacao
END RECORD

DEFINE m_cus_unit_medio  LIKE estoque_hist.cus_unit_medio,
       m_seq_baixa       LIKE pat_dad_compl_ent.seq_baixa,
       m_cod_moeda       LIKE cotacao.cod_moeda,
       m_val_cotacao     LIKE cotacao.val_cotacao,
       m_val_pago_orig   LIKE patrval.val_pago_orig_um

#-----------------#
FUNCTION pol1303()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1303-12.00.07  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1303_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1303_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_modifica    VARCHAR(10),
           l_proces      VARCHAR(10)
    
    LET m_ies_mod = FALSE   
    LET m_ies_info = FALSE

       #Criação da janela do programa
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE","INCLUSÃO DE PARCELAS DE BENS")

       #Criação da barra de status
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

       #Criação da barra de menu
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

       #Criação do botão informar
    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1303_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1303_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1303_cancelar")
    
       #Criação do botão modificar
    LET l_modifica = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_modifica,"EVENT","pol1303_modifica")
    CALL _ADVPL_set_property(l_modifica,"CONFIRM_EVENT","pol1303_conf_mod")
    CALL _ADVPL_set_property(l_modifica,"CANCEL_EVENT","pol1303_cancelar")

       #Criação do botão processar
    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1303_processar")

       #Criação do botão sair
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    #Criação de um painel, para organizar os campos de pesquisa.    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    #Chama FUNCTION para criação dos campos
    CALL pol1303_cria_campos(l_panel)

    CALL pol1303_cria_grade(l_panel)

    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

    CALL pol1303_ativa_desativa(FALSE)

       #Exibe a janela do programa
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1303_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_den_item        VARCHAR(10),
           l_panel_campos    VARCHAR(10)

    CALL pol1303_limpa_campos()
    
    #criação de painel no topo para os campos de pesquisa
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)
    
    #criação um LLAYOUT c/ 4 colunas, para distribuiçao dos campos - o link abaixo ajuda 
    #http://tdn.totvs.com/display/public/lg/LLayoutManager;jsessionid=0FE4A7070C40A67B07EB4E2DC73F1009
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",12)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW") 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    #criação do campo para entrada do item
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Item:")    

    LET m_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_item,"LENGTH",15)
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_parametro,"cod_item")
    CALL _ADVPL_set_property(m_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_item,"VALID","pol1303_checa_item")

    #criação/definição do icone do zoom
    LET m_lupa_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_item,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_item,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_item,"CLICK_EVENT","pol1303_zoom_item")

    #criação/definição do campos para exibir a descrição do item
    LET l_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_den_item,"LENGTH",40) 
    CALL _ADVPL_set_property(l_den_item,"EDITABLE",FALSE) #não permite edição do conteúdo
    CALL _ADVPL_set_property(l_den_item,"VARIABLE",mr_parametro,"den_item")

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","   Periodo - De:")
    
    LET m_datini = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_datini,"VARIABLE",mr_parametro,"dat_ini")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","   Até:")
    
    LET m_datfim = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_datfim,"VARIABLE",mr_parametro,"dat_fim")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","  Inventário:")

    LET m_invent = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_invent,"LENGTH",10)
    CALL _ADVPL_set_property(m_invent,"VARIABLE",mr_parametro,"num_invent")
    CALL _ADVPL_set_property(m_invent,"PICTURE","@!")
    CALL _ADVPL_set_property(m_invent,"VALID","pol1303_checa_invent")

    #criação/definição do icone do zoom
    LET m_lupa_invent = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_invent,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_invent,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_invent,"CLICK_EVENT","pol1303_zoom_invent")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")
      
END FUNCTION

#---------------------------------------#
FUNCTION pol1303_cria_grade(l_container)#
#---------------------------------------#

    DEFINE l_container           VARCHAR(10),
           l_panel               VARCHAR(10),
           l_layout              VARCHAR(10),
           l_tabcolumn           VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    
    CALL _ADVPL_set_property(m_browse,"AFTER_ROW_EVENT","pol1303_checa_linha")
    
    # colunas da grade    

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Reserva")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_reserva")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Quantidade")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_reservada")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Unid")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_unid_med")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dat movto")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_solicitacao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Incluir ?")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_incluir")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
        
    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_reserva,1)
        
END FUNCTION
    

#habilita/desabilita os campos de tela

#----------------------------------------#
FUNCTION pol1303_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
    
   CALL _ADVPL_set_property(m_item,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_item,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_datini,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_datfim,"EDITABLE",l_status)

   CALL _ADVPL_set_property(m_invent,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_invent,"EDITABLE",l_status)

END FUNCTION


#--------------------------#
FUNCTION pol1303_informar()#
#--------------------------#
   
   DEFINE l_data    DATE
   
   LET m_ies_info = FALSE
   LET m_ies_mod = FALSE

   SELECT parametro_dat
     INTO l_data 
     FROM min_par_modulo
    WHERE empresa = p_cod_empresa
      AND parametro = 'DAT_CORTE_POL1303'
      
   IF STATUS = 100 THEN
      LET m_msg = 'Parâmetro DAT_CORTE_POL1303\n ',
                  'Não cadastrado na tabela\n ',   
                  'min_par_modulo.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','min_par_modulo')
         RETURN FALSE
      ELSE
         IF l_data IS NULL THEN
            LET m_msg = 'Conteúdo do parâmetro DAT_CORTE_POL1303\n ',
                        'está vazio na tabela min_par_modulo.'
            CALL log0030_mensagem(m_msg,'info')
            RETURN FALSE
         END IF
      END IF
   END IF
   
   CALL _ADVPL_set_property(m_browse,"CLEAR_LINE_FONT_COLOR",m_ind)

   CALL pol1303_ativa_desativa(TRUE)
   CALL pol1303_limpa_campos()
   
   LET mr_parametro.dat_ini = l_data
   LET mr_parametro.dat_fim = TODAY
   
   RETURN TRUE 
    
END FUNCTION

#-----------------------------#
FUNCTION pol1303_limpa_campos()
#-----------------------------#

   INITIALIZE mr_parametro.* TO NULL
   INITIALIZE ma_reserva TO NULL
    
END FUNCTION

#Chamada quando o usuário 
#confirma a edição dos parametros

#---------------------------#
FUNCTION pol1303_confirmar()#
#---------------------------#
   
   IF mr_parametro.dat_ini IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a data inicial")
      CALL _ADVPL_set_property(m_datini,"GET_FOCUS")
      RETURN FALSE      
   END IF
   
   IF mr_parametro.dat_fim IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a data final")
      CALL _ADVPL_set_property(m_datfim,"GET_FOCUS")
      RETURN FALSE      
   END IF
   
   IF mr_parametro.dat_fim IS NOT NULL AND
        mr_parametro.dat_ini IS NOT NULL THEN
      IF mr_parametro.dat_fim < mr_parametro.dat_ini THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Período inválido!")
         CALL _ADVPL_set_property(m_datini,"GET_FOCUS")
         RETURN FALSE      
      END IF
   END IF

   IF mr_parametro.num_invent IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o inventário.")
      CALL _ADVPL_set_property(m_invent,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   CALL LOG_progresspopup_start("Pesquisa das reservas","pol1303_pesquisar","PROCESS")
  
   IF NOT p_status THEN 
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
                "Operação cancelada")
      CALL _ADVPL_set_property(m_item,"GET_FOCUS")
      RETURN FALSE
   END IF

   LET m_ies_info = TRUE
   CALL pol1303_ativa_desativa(FALSE)
   
   RETURN TRUE

END FUNCTION


#Chamada quando o usuário 
#cancela a edição dos parametros

#--------------------------#
FUNCTION pol1303_cancelar()#
#--------------------------#

    CALL pol1303_limpa_campos()
    CALL pol1303_ativa_desativa(FALSE)
    LET m_ies_info = FALSE
    LET m_ies_mod = FALSE
    RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1303_checa_item()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   INITIALIZE mr_parametro.den_item TO NULL
   
   IF mr_parametro.cod_item IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT den_item
     INTO mr_parametro.den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_parametro.cod_item
   
   IF STATUS = 100 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Item inexistente.")
      RETURN FALSE
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1303_zoom_item()#
#---------------------------#

    DEFINE l_cod_item       LIKE item.cod_item,
           l_den_item       LIKE item.den_item
    
    IF  m_zoom_item IS NULL THEN
        LET m_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_item,"ZOOM","zoom_item")
    END IF
    
    #exibe a janela do zoom
    CALL _ADVPL_get_property(m_zoom_item,"ACTIVATE")
    
    #obtém o código e nome do item da linha atual da grade de zoom
    LET l_cod_item = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")
    LET l_den_item = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","den_item")

    IF  l_cod_item IS NOT NULL THEN
        LET mr_parametro.cod_item = l_cod_item
        LET mr_parametro.den_item = l_den_item
    END IF
    
    CALL _ADVPL_set_property(m_item,"GET_FOCUS")

END FUNCTION

#------------------------------#
FUNCTION pol1303_checa_invent()#
#------------------------------#
   
   DEFINE l_cod_grupo LIKE agrupam.cod_grupo
   
   LET m_dat_atu = TODAY
   
   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
      
   IF mr_parametro.num_invent IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o inventário.")
      RETURN FALSE
   END IF
   
   SELECT cod_agrupam
     INTO m_cod_agrupam
     FROM patrimonio
    WHERE cod_empresa = p_cod_empresa
      AND cod_empresa_estab = p_cod_empresa
      AND num_invent = mr_parametro.num_invent
      AND dat_validade_ini <= m_dat_atu
      AND dat_validade_fim >= m_dat_atu
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','patrimonio')
      RETURN FALSE
   END IF

   SELECT cod_grupo
     INTO l_cod_grupo
     FROM agrupam
    WHERE cod_empresa = p_cod_empresa
      AND cod_empresa_estab = p_cod_empresa
      AND cod_agrupam = m_cod_agrupam
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','agrupam')
      RETURN FALSE
   END IF

   SELECT num_conta_contabil 
     INTO m_conta_contabil
     FROM grupo_patrim 
    WHERE cod_empresa = p_cod_empresa
      AND cod_empresa_estab = p_cod_empresa
      AND cod_grupo = l_cod_grupo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','grupo_patrim')
      RETURN FALSE
   END IF
  
   SELECT MAX(num_parcela)
     INTO m_num_parcela
     FROM patrparc 
    WHERE cod_empresa = p_cod_empresa
      AND cod_empresa_estab = p_cod_empresa
      AND num_invent = mr_parametro.num_invent

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','patrparc')
      RETURN FALSE
   END IF
   
   IF m_num_parcela IS NULL THEN
      LET m_num_parcela = 0
   END IF
   
   IF m_num_parcela >= 99 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Esse inventário já possui o limite de parcelas")
      RETURN FALSE
   END IF
      
   LET m_num_parcela = m_num_parcela + 1   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1303_zoom_invent()#
#-----------------------------#

    DEFINE l_num_invent     LIKE patrimonio.num_invent
    
    IF  m_zoom_invent IS NULL THEN
        LET m_zoom_invent = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_invent,"ZOOM","zoom_patrimonio")
    END IF
    
    #exibe a janela do zoom
    CALL _ADVPL_get_property(m_zoom_invent,"ACTIVATE")
    
    LET l_num_invent = _ADVPL_get_property(m_zoom_invent,"RETURN_BY_TABLE_COLUMN","patrimonio","num_invent")
    #LET l_den_item = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","den_item")

    IF  l_num_invent IS NOT NULL THEN
        LET mr_parametro.num_invent = l_num_invent
        #LET mr_parametro.den_item = l_den_item
    END IF
    
    CALL _ADVPL_set_property(m_invent,"GET_FOCUS")

END FUNCTION
      
#---------------------------#
FUNCTION pol1303_pesquisar()#
#---------------------------#
   
   LET p_status = pol1303_le_reservas()
   LET m_ies_info = FALSE
   RETURN p_status

END FUNCTION

#-----------------------------#
FUNCTION pol1303_le_reservas()#
#-----------------------------#
   
   DEFINE sql_stmt      VARCHAR(9000),
          l_progres     SMALLINT

   LET sql_stmt =
     "SELECT COUNT(e.cod_empresa) \n",
      " FROM estoque_loc_reser e, item i, conta_contabil_ronc c, \n",
           " estoque_trans f, sup_resv_est_trans g \n",
     " WHERE e.cod_empresa = '",p_cod_empresa,"' \n",
       " AND e.ies_situacao = 'L' \n",
       " AND e.num_reserva NOT IN \n",
    " (SELECT p.num_reserva FROM parcela_ronc p WHERE p.cod_empresa = '",p_cod_empresa,"' ) \n",
       " AND e.cod_empresa = i.cod_empresa  \n",
       " AND e.cod_item = i.cod_item \n",
       " AND e.cod_empresa = c.cod_empresa \n",
       " AND e.num_conta_deb = c.num_conta_reduz \n",
       " AND f.cod_empresa = e.cod_empresa \n",
       " AND f.cod_item = e.cod_item \n",
       " AND g.empresa = e.cod_empresa \n",
       " AND g.num_trans_resv_est = e.num_reserva \n",
       " AND g.num_trans_mov_est = f.num_transac \n"

   IF mr_parametro.cod_item IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND e.cod_item = '",mr_parametro.cod_item,"' \n"
   END IF

   IF mr_parametro.dat_ini IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED,
       " AND f.dat_movto >= '",mr_parametro.dat_ini,"' \n"
   END IF

   IF mr_parametro.dat_fim IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED,
       " AND f.dat_movto <= '",mr_parametro.dat_fim,"' \n"
   END IF
   
   LET sql_stmt = sql_stmt CLIPPED
      
   PREPARE var_count FROM sql_stmt   

   IF STATUS <> 0 THEN
      CALL log003_err_sql("PREPARE","var_count")  
      RETURN FALSE          
   END IF 
   
   DECLARE cq_count CURSOR FOR var_count

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DECLARE','cq_count:var_count')
   END IF
   
   FOREACH cq_count INTO m_count
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_count')
      END IF
      EXIT FOREACH
   END FOREACH
   
   IF m_count = 0 THEN
      LET m_msg = 'Nenhum registro foi encontrado,\n',
                  'para os parâmetros informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE   
   END IF
   
   LET m_checa_linha = FALSE
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   LET sql_stmt =
     "SELECT distinct e.num_reserva, e.cod_item, i.den_item_reduz, \n",
           " e.qtd_reservada, i.cod_unid_med, f.dat_movto \n",
      " FROM estoque_loc_reser e, item i, conta_contabil_ronc c, \n",
           " estoque_trans f, sup_resv_est_trans g \n",
     " WHERE e.cod_empresa = '",p_cod_empresa,"' \n",
       " AND e.ies_situacao = 'L' \n",
       " AND e.num_reserva NOT IN \n",
    " (SELECT p.num_reserva FROM parcela_ronc p WHERE p.cod_empresa = '",p_cod_empresa,"' ) \n",
       " AND e.cod_empresa = i.cod_empresa  \n",
       " AND e.cod_item = i.cod_item \n",
       " AND e.cod_empresa = c.cod_empresa \n",
       " AND e.num_conta_deb = c.num_conta_reduz \n",
       " AND f.cod_empresa = e.cod_empresa \n",
       " AND f.cod_item = e.cod_item \n",
       " AND g.empresa = e.cod_empresa \n",
       " AND g.num_trans_resv_est = e.num_reserva \n",
       " AND g.num_trans_mov_est = f.num_transac \n"

   IF mr_parametro.cod_item IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND e.cod_item = '",mr_parametro.cod_item,"' \n"
   END IF

   IF mr_parametro.dat_ini IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED,
       " AND f.dat_movto >= '",mr_parametro.dat_ini,"' \n"
   END IF

   IF mr_parametro.dat_fim IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED,
       " AND f.dat_movto <= '",mr_parametro.dat_fim,"' \n"
   END IF

   LET sql_stmt = sql_stmt CLIPPED, " ORDER BY e.cod_item "
    
   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','var_query')
      RETURN FALSE
   END IF
   
   CALL LOG_progresspopup_set_total("PROCESS",500)
   
   LET m_ind = 1
   
   DECLARE cq_padrao CURSOR WITH HOLD FOR var_query

   FOREACH cq_padrao INTO 
      ma_reserva[m_ind].num_reserva,
      ma_reserva[m_ind].cod_item,
      ma_reserva[m_ind].den_item,
      ma_reserva[m_ind].qtd_reservada,
      ma_reserva[m_ind].cod_unid_med,
      ma_reserva[m_ind].dat_solicitacao

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_padrao')
         RETURN FALSE
      END IF          

      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET m_ind = m_ind + 1
                     
   END FOREACH

   FREE cq_padrao

   IF m_ind = 1 THEN
      LET m_msg = 'Não foram encontrados registros,\n',
                  'para os parâmetros informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE   
   END IF

   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT",m_ind - 1)

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1303_modifica()#
#--------------------------#

   IF NOT m_ies_info THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe os parâmetros previamente")
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_browse,"CLEAR_LINE_FONT_COLOR",m_ind)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", 
          " ENTER ou 2 Clicks -> Marca/Desmarca")     
          
   CALL _ADVPL_set_property(m_browse,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_browse,"SELECT_ITEM",1,5)

   LET m_checa_linha = TRUE
               
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1303_checa_linha()#
#-----------------------------#
   
   DEFINE l_lin_atu       SMALLINT
   
   IF NOT m_checa_linha THEN
      RETURN TRUE
   END IF       

   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN

      IF ma_reserva[l_lin_atu].ies_incluir MATCHES '[SN]' THEN
      ELSE
         IF ma_reserva[l_lin_atu].ies_incluir = ' ' OR
             ma_reserva[l_lin_atu].ies_incluir IS NULL THEN
         ELSE
            LET m_msg = 'Valor impróprio para a coluna Incluir'
            CALL log0030_mensagem(m_msg,'excl')
            RETURN FALSE
         END IF
      END IF
   END IF   
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1303_conf_mod()#
#--------------------------#
   
   DEFINE l_ind      INTEGER,
          l_qtd_sel  INTEGER
   
   IF NOT pol1303_checa_linha() THEN
      RETURN FALSE
   END IF
   
   LET m_count = _ADVPL_get_property(m_browse,"ITEM_COUNT")
   LET m_msg = NULL
   LET l_qtd_sel = 0
    
   FOR l_ind = 1 TO m_count
       IF ma_reserva[l_ind].ies_incluir = 'S' THEN
          LET m_ind = l_ind
          LET l_qtd_sel = l_qtd_sel + 1
       END IF       
   END FOR
   
   IF l_qtd_sel = 0 THEN
      LET m_msg = 'Você precisa selecionar uma linha.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   IF l_qtd_sel > 1 THEN
      LET m_msg = 'Você deve selecionar apenas uma linha.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   IF NOT pol1303_cotacao() THEN
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

   CALL _ADVPL_set_property(m_browse,"LINE_FONT_COLOR",m_ind,255,113,113)
   
   LET m_checa_linha = FALSE
   LET m_ies_mod = TRUE
   
   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol1303_cotacao()#
#-------------------------#

   DEFINE l_cod_moeda       LIKE moeda.cod_moeda,
          l_val_cotacao     LIKE cotacao.val_cotacao,
          l_dat_refer       DATE,
          l_erro            SMALLINT,
          p_empresa_moeda   CHAR(02)
   
   INITIALIZE ma_moeda TO NULL
   LET l_erro = FALSE
   LET m_qtd_moeda = 0
   LET l_dat_refer = ma_reserva[m_ind].dat_solicitacao
   
   LET p_empresa_moeda = '99'
   
   DECLARE cq_moeda CURSOR FOR
    SELECT cod_moeda
      FROM moeda_pat
     WHERE cod_empresa = p_empresa_moeda
   
   FOREACH cq_moeda INTO l_cod_moeda
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_moeda')
         RETURN FALSE
      END IF
      
      SELECT val_cotacao
        INTO l_val_cotacao
        FROM cotacao
       WHERE cod_moeda = l_cod_moeda
         AND dat_ref = l_dat_refer

      IF STATUS = 100 THEN
         LET l_erro = TRUE
         LET m_msg = 'Na data ',l_dat_refer, ' não há cotação\n',
                     'para a moeda ', l_cod_moeda
         CALL log0030_mensagem(m_msg, 'info')
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_moeda')
            RETURN FALSE
         END IF
      END IF
      
      LET m_qtd_moeda = m_qtd_moeda + 1
      
      LET ma_moeda[m_qtd_moeda].cod_moeda = l_cod_moeda
      LET ma_moeda[m_qtd_moeda].val_cotacao = l_val_cotacao
   
   END FOREACH
   
   IF l_erro THEN
      RETURN FALSE
   END IF
   
   IF m_qtd_moeda = 0 THEN
      LET m_msg = 'Não há moedas cadastradas\n para o módulo patrimônio'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION   
     
#---------------------------#
FUNCTION pol1303_processar()#
#---------------------------#

   IF NOT m_ies_mod THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Selecione um item da grade previamente")
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a inclusão da parcela?") THEN
      CALL pol1303_cancelar()
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   #CALL log085_transacao("BEGIN")
   BEGIN WORK
    
   IF pol1303_inclui_bem() THEN
      #CALL log085_transacao("COMMIT")
      COMMIT WORK
      LET m_msg = 'Inclusão de parcela\n efetuada com sucesso.'
   ELSE
      #CALL log085_transacao("ROLLBACK")
      ROLLBACK WORK
      LET m_msg = 'Operação cancelada.'
   END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)

   LET m_ies_mod = FALSE   
   LET m_ies_info = FALSE

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1303_inclui_bem()#
#----------------------------#
   
   DEFINE l_custo          LIKE estoque_hist.cus_unit_medio
   
   DEFINE l_dat_ref        DATE,
          l_mes            CHAR(02),
          l_ano            CHAR(04),
          l_ano_mes_ref    INTEGER,
          l_anomes         CHAR(06),
          l_cod_item       CHAR(15),
          l_ind            INTEGER
   
   LET m_cus_unit_medio = 0
   LET l_cod_item = ma_reserva[m_ind].cod_item
   LET l_dat_ref = ma_reserva[m_ind].dat_solicitacao
   LET l_mes = MONTH(l_dat_ref) USING '<<'
   LET l_ano = YEAR(l_dat_ref) USING '<<<<'
   LET l_anomes = l_ano, l_mes
   LET l_ano_mes_ref = l_anomes
   LET m_seq_baixa = 0
   
   DECLARE cq_hist CURSOR FOR
    SELECT ano_mes_ref, cus_unit_medio
      FROM estoque_hist 
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = l_cod_item
       AND ano_mes_ref <= l_ano_mes_ref 
     ORDER BY ano_mes_ref DESC
    
   FOREACH cq_hist INTO l_anomes, l_custo
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_hist')
         RETURN FALSE
      END IF
      
      LET m_cus_unit_medio = l_custo
      EXIT FOREACH
   
   END FOREACH
   
   IF NOT pol1303_ins_pat_dad() THEN
      RETURN FALSE
   END IF

   IF NOT pol1303_ins_patrparc() THEN
      RETURN FALSE
   END IF
   
   FOR l_ind = 1 TO m_qtd_moeda
      LET m_cod_moeda = ma_moeda[l_ind].cod_moeda
      LET m_val_cotacao = ma_moeda[l_ind].val_cotacao
      
      IF NOT pol1303_ins_patrval() THEN
         RETURN FALSE
      END IF

      IF NOT pol1303_ins_pat_audit() THEN
         RETURN FALSE
      END IF
      
   END FOR
   
   IF NOT pol1303_gra_valor_econ() THEN
      RETURN FALSE
   END IF         

   IF NOT pol1303_ins_par_ronc() THEN
      RETURN FALSE
   END IF         
      
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1303_ins_pat_dad()#
#-----------------------------#

   INSERT INTO pat_dad_compl_ent (
     empresa, 
     emp_estab, 
     inventario, 
     parcela_inventario, 
     seq_baixa, 
     nf_entrada, 
     ser_subser_nf, 
     area_livre, 
     descricao_funcao_inventario) 
   VALUES(p_cod_empresa,
          p_cod_empresa,
          mr_parametro.num_invent,
          m_num_parcela,
          m_seq_baixa,  
          0,
          ' ',
          '1',
          'POL1303')

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','PAT_DAD_COMPL_ENT')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1303_ins_patrparc()#
#------------------------------#

   DEFINE lr_patrparc    RECORD LIKE patrparc.*,
          l_des_docum    CHAR(30),
          l_des_invent   CHAR(40)
   
   IF m_num_parcela > 1 THEN
      SELECT ies_situacao_anter, 
             ies_taxa_seguro,
             dat_validade_ini,
             dat_validade_fim
        INTO lr_patrparc.ies_situacao_anter,
             lr_patrparc.ies_taxa_seguro,
             lr_patrparc.dat_validade_ini,
             lr_patrparc.dat_validade_fim
        FROM patrparc
       WHERE cod_empresa = p_cod_empresa
         AND cod_empresa_estab = p_cod_empresa
         AND num_invent = mr_parametro.num_invent
         AND num_parcela = (m_num_parcela - 1)
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','patrparc')
         RETURN FALSE
      END IF
   ELSE
      LET lr_patrparc.ies_situacao_anter = '1'
      LET lr_patrparc.ies_taxa_seguro    = '2'
      LET lr_patrparc.dat_validade_ini   = NULL
      LET lr_patrparc.dat_validade_fim   = NULL
   END IF

   LET l_des_docum = 'Reserva: ', ma_reserva[m_ind].num_reserva USING '<<<<<<<<<'
   LET l_des_invent = ma_reserva[m_ind].cod_item CLIPPED, ' - ', ma_reserva[m_ind].den_item
   
   LET lr_patrparc.cod_empresa        = p_cod_empresa
   LET lr_patrparc.cod_empresa_estab  = p_cod_empresa
   LET lr_patrparc.num_invent         = mr_parametro.num_invent
   LET lr_patrparc.num_parcela        = m_num_parcela
   LET lr_patrparc.num_seq_baixa      = m_seq_baixa
   LET lr_patrparc.num_invent_pai     = mr_parametro.num_invent
   LET lr_patrparc.num_conta_contabil = m_conta_contabil
   LET lr_patrparc.ies_situacao       = '1'
   LET lr_patrparc.dat_aquis          = TODAY
   LET lr_patrparc.qtd_meses_depr     = 0
   LET lr_patrparc.des_docum_aquis    = l_des_docum
   LET lr_patrparc.val_pago_orig      = m_cus_unit_medio
   LET lr_patrparc.val_pago_orig_vp   = NULL
   LET lr_patrparc.val_depr_acu_s_cor = 0
   LET lr_patrparc.des_invent         = l_des_invent CLIPPED
   LET lr_patrparc.val_transfer       = 0
   LET lr_patrparc.val_co_mon_compl   = 0
   LET lr_patrparc.val_co_mo_com_de   = 0
   LET lr_patrparc.dat_baixa          = NULL
   LET lr_patrparc.des_baixa          = NULL
   LET lr_patrparc.num_plaqueta       = NULL
   
   INSERT INTO patrparc VALUES(lr_patrparc.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','PATRPARC')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1303_ins_patrval()#
#-----------------------------#

   DEFINE lr_patrval  RECORD LIKE patrval.*
   
   LET m_val_pago_orig = m_cus_unit_medio / m_val_cotacao
   
   LET lr_patrval.cod_empresa        = p_cod_empresa
   LET lr_patrval.cod_empresa_estab  = p_cod_empresa
   LET lr_patrval.num_invent         = mr_parametro.num_invent
   LET lr_patrval.num_parcela        = m_num_parcela
   LET lr_patrval.num_seq_baixa      = m_seq_baixa
   LET lr_patrval.cod_moeda          = m_cod_moeda
   LET lr_patrval.val_pago_orig_um   = m_val_pago_orig
   LET lr_patrval.val_depr_acum_um   = 0
   LET lr_patrval.val_transfer_um    = 0
   LET lr_patrval.val_co_mon_comp_um = 0
   LET lr_patrval.val_co_mo_co_de_um = 0
   LET lr_patrval.val_depr_mes_um    = 0
   LET lr_patrval.val_corr_mes_um    = 0
   LET lr_patrval.val_de_mes_co_um   = 0
   LET lr_patrval.val_co_mes_co_um   = 0
   LET lr_patrval.val_co_depr_mes_um = 0
   LET lr_patrval.val_co_de_mes_c_um = 0
   LET lr_patrval.mes_calculo        = MONTH(TODAY)
   LET lr_patrval.ano_calculo        = YEAR(TODAY)

   INSERT INTO patrval VALUES(lr_patrval.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','PATRVAL')
      RETURN FALSE
   END IF
  
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1303_ins_pat_audit()#
#-------------------------------#

   DEFINE lr_pat_audit    RECORD LIKE pat_audit_inventario_cotacao.*
   
   LET lr_pat_audit.empresa               = p_cod_empresa
   LET lr_pat_audit.inventario            = mr_parametro.num_invent
   LET lr_pat_audit.parcela_inventario    = m_num_parcela
   LET lr_pat_audit.moeda                 = m_cod_moeda
   LET lr_pat_audit.val_cotacao           = m_val_cotacao
   LET lr_pat_audit.permite_alteracao_val = 'S'
   LET lr_pat_audit.dat_atualizacao       = TODAY
   LET lr_pat_audit.usuario               = p_user
   
   INSERT INTO pat_audit_inventario_cotacao VALUES(lr_pat_audit.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','PAT_AUDIT_INVENTARIO_COTACAO')
      RETURN FALSE
   END IF
  
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1303_gra_valor_econ()#
#--------------------------------#
   
   DEFINE lr_valor_econ    RECORD LIKE valor_econ.*
   
   SELECT val_pg_orig_econ
     FROM valor_econ
    WHERE cod_empresa = p_cod_empresa
      AND cod_empresa_estab = p_cod_empresa
      AND num_invent = mr_parametro.num_invent
   
   IF STATUS = 0 OR STATUS = 100 THEN
   ELSE
      CALL log003_err_sql('SELECT','valor_econ')
      RETURN FALSE
   END IF
   
   IF STATUS = 0 THEN
      UPDATE valor_econ
         SET val_pg_orig_econ = val_pg_orig_econ + m_val_pago_orig
       WHERE cod_empresa = p_cod_empresa
         AND cod_empresa_estab = p_cod_empresa
         AND num_invent = mr_parametro.num_invent
   ELSE
      LET lr_valor_econ.cod_empresa       = p_cod_empresa
      LET lr_valor_econ.cod_empresa_estab = p_cod_empresa
      LET lr_valor_econ.num_invent        = mr_parametro.num_invent
      LET lr_valor_econ.val_pg_orig_econ  = m_val_pago_orig
      LET lr_valor_econ.val_dep_acu_econ  = NULL
      INSERT INTO valor_econ VALUES(lr_valor_econ.*)
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('GRAVANDO','valor_econ')
      RETURN FALSE 
   END IF
   
   RETURN TRUE

END FUNCTION              

#------------------------------#
FUNCTION pol1303_ins_par_ronc()#
#------------------------------#
   
   DEFINE l_dat_atu    DATE,
          l_hor_atu    CHAR(08)
   
   LET l_dat_atu = TODAY
   LET l_hor_atu = TIME
   
   INSERT INTO parcela_ronc
    VALUES(p_cod_empresa, 
           ma_reserva[m_ind].num_reserva,
           mr_parametro.num_invent,
           p_user,
           l_dat_atu,
           l_hor_atu)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','parcela_ronc')
      RETURN FALSE 
   END IF
   
   RETURN TRUE

END FUNCTION              

#-------------------FIM DO PROGRAMA--------------------#
