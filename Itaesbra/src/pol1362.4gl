#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1362                                                 #
# OBJETIVO: TRANSPORTADOR P/ SOLICITAÇÃO DE FATURAMENTO             #
# AUTOR...: IVO                                                     #
# DATA....: 26/12/18                                                #
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

DEFINE m_trans_solic   INTEGER,
       m_trans_solica  INTEGER

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_nom_cliente     VARCHAR(10),
       m_zoom_cliente    VARCHAR(10),
       m_lupa_cliente    VARCHAR(10),
       m_construct       VARCHAR(10)

DEFINE m_transpor        VARCHAR(10),
       m_texto_1         VARCHAR(10),
       m_texto_2         VARCHAR(10),
       m_texto_3         VARCHAR(10),
       m_lupa_tx1        VARCHAR(10),
       m_lupa_tx2        VARCHAR(10),
       m_lupa_tx3        VARCHAR(10),
       m_zoom_txt        VARCHAR(10),
       m_via             VARCHAR(10),
       m_lupa_via        VARCHAR(10),
       m_zoom_via        VARCHAR(10),
       m_solicit         VARCHAR(10),
       m_panel           VARCHAR(10),
       m_ztransp         VARCHAR(10)
       
DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ies_cons        SMALLINT,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_nom_transp      CHAR(36),
       m_ies_modalidade  CHAR(01)
       
DEFINE mr_campos         RECORD
       trans_solic       INTEGER,
       num_solicit       INTEGER,
       dat_refer         DATE,
       cod_usuario       CHAR(08),
       cod_transpor      CHAR(15),
       nom_transpor      CHAR(36),
       num_placa         CHAR(10),
       uf_veiculo        CHAR(02),
			 cod_texto_1       DECIMAL(3,0),
			 cod_texto_2       DECIMAL(3,0),
			 cod_texto_3       DECIMAL(3,0),
			 cod_via           DECIMAL(2,0),
			 tip_frete         CHAR(01)       
END RECORD

#-----------------#
FUNCTION pol1362()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1362-12.00.01  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1362_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1362_menu()#
#----------------------#

    DEFINE l_menubar,
           l_create,
           l_update,
           l_find,
           l_first,
           l_previous,
           l_next,
           l_last,
           l_delete  VARCHAR(10)

    DEFINE l_titulo  CHAR(40)
    
    LET l_titulo  = "TRANSPORTADOR P/ SOLICITAÇÃO DE FATURAMENTO"
    CALL pol1362_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)
    
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1362_find")

    LET l_update = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"IMAGE","UPDATE_EX") 
    CALL _ADVPL_set_property(l_update,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_update,"TOOLTIP","Modificar dados da solicitação")
    CALL _ADVPL_set_property(l_update,"EVENT","pol1362_alterar")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1362_ies_alterar")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1362_no_alterar")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1362_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1362_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1362_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1362_last")

    #LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    #CALL _ADVPL_set_property(l_delete,"EVENT","pol1362_delete")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET m_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(m_panel,"ALIGN","CENTER")

    CALL pol1362_cria_campos()

    CALL pol1362_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1362_limpa_campos()
#-----------------------------#

   INITIALIZE mr_campos.* TO NULL
    
END FUNCTION

#-----------------------------#
FUNCTION pol1362_cria_campos()#
#-----------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_lupa            VARCHAR(10),
           l_caixa           VARCHAR(10)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Num solicit:")    

    LET m_solicit = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_solicit,"POSITION",100,10)     
    CALL _ADVPL_set_property(m_solicit,"EDITABLE",FALSE)     
    CALL _ADVPL_set_property(m_solicit,"VARIABLE",mr_campos,"num_solicit")
    CALL _ADVPL_set_property(m_solicit,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_solicit,"CAN_GOT_FOCUS",FALSE)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",270,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Identificação:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",350,10)     
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_campos,"trans_solic")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10,0)
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)
    
    LET l_label = _ADVPL_create_component(NULL,"LCLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Transportador:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_transpor = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(m_transpor,"POSITION",100,40)     
    CALL _ADVPL_set_property(m_transpor,"LENGTH",15)
    CALL _ADVPL_set_property(m_transpor,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(m_transpor,"PICTURE","@E!")
    CALL _ADVPL_set_property(m_transpor,"VARIABLE",mr_campos,"cod_transpor")
    CALL _ADVPL_set_property(m_transpor,"VALID","pol1362_valid_transp")

    LET l_lupa = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(l_lupa,"POSITION",245,40)     
    CALL _ADVPL_set_property(l_lupa,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa,"CLICK_EVENT","pol1362_zoom_trasport")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",270,40)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",36)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E!")
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_campos,"nom_transpor")
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,70)     
    CALL _ADVPL_set_property(l_label,"TEXT","Tipo frete:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET l_caixa = _ADVPL_create_component(NULL,"LCOMBOBOX",m_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",100,70)     
    CALL _ADVPL_set_property(l_caixa,"ADD_ITEM","C","CIF")     
    CALL _ADVPL_set_property(l_caixa,"ADD_ITEM","F","FOB")     
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_campos,"tip_frete")

    LET l_label = _ADVPL_create_component(NULL,"LCLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,100)     
    CALL _ADVPL_set_property(l_label,"TEXT","Plava veículo:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",100,100)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E!")
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_campos,"num_placa")

    LET l_label = _ADVPL_create_component(NULL,"LCLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",245,100)     
    CALL _ADVPL_set_property(l_label,"TEXT","UF:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",270,100)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",4)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@E!")
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_campos,"uf_veiculo")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,130)     
    CALL _ADVPL_set_property(l_label,"TEXT","Cód texto1:")    

    LET m_texto_1 = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_texto_1,"POSITION",100,130)     
    CALL _ADVPL_set_property(m_texto_1,"VARIABLE",mr_campos,"cod_texto_1")
    CALL _ADVPL_set_property(m_texto_1,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_texto_1,"VALID","pol1362_ck_texto1")
    
    LET m_lupa_tx1 = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_tx1,"POSITION",208,130)     
    CALL _ADVPL_set_property(m_lupa_tx1,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_tx1,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_tx1,"CLICK_EVENT","pol1362_zoom_txt_1")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,160)     
    CALL _ADVPL_set_property(l_label,"TEXT","Cód texto2:")    

    LET m_texto_2 = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_texto_2,"POSITION",100,160)     
    CALL _ADVPL_set_property(m_texto_2,"VARIABLE",mr_campos,"cod_texto_2")
    CALL _ADVPL_set_property(m_texto_2,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_texto_2,"VALID","pol1362_ck_texto2")

    LET m_lupa_tx2 = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_tx2,"POSITION",208,160)     
    CALL _ADVPL_set_property(m_lupa_tx2,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_tx2,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_tx2,"CLICK_EVENT","pol1362_zoom_txt_2")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,190)     
    CALL _ADVPL_set_property(l_label,"TEXT","Cód texto3:")    

    LET m_texto_3 = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_texto_3,"POSITION",100,190)     
    CALL _ADVPL_set_property(m_texto_3,"VARIABLE",mr_campos,"cod_texto_3")
    CALL _ADVPL_set_property(m_texto_3,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_texto_3,"VALID","pol1362_ck_texto3")

    LET m_lupa_tx3 = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_tx3,"POSITION",208,190)     
    CALL _ADVPL_set_property(m_lupa_tx3,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_tx3,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_tx3,"CLICK_EVENT","pol1362_zoom_txt_3")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,220)     
    CALL _ADVPL_set_property(l_label,"TEXT","Via transp:")    

    LET m_via = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_via,"POSITION",100,220)     
    CALL _ADVPL_set_property(m_via,"VARIABLE",mr_campos,"cod_via")
    CALL _ADVPL_set_property(m_via,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_via,"VALID","pol1362_ck_via")

    LET m_lupa_via = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_via,"POSITION",208,220)     
    CALL _ADVPL_set_property(m_lupa_via,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_via,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_via,"CLICK_EVENT","pol1362_zoom_via")

END FUNCTION

#----------------------------------------#
FUNCTION pol1362_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
   
   CALL _ADVPL_set_property(m_panel,"ENABLE",l_status)

END FUNCTION

#----------------------#
FUNCTION pol1362_find()#
#----------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","pol1362_FILTER")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","fat_solic_mestre","solicitacao")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","fat_solic_mestre","solicitacao_fatura","Númeo",1 {INT},15,0,"zoom_vdp_solicitacao_romaneio")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","fat_solic_mestre","usuario","Usuário",1 {CHAR},8,0,"zoom_usuarios")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","fat_solic_mestre","dat_refer","Dat refer",1 {DATE},10,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_construct,"ORDER_BY")
       CALL pol1362_create_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1362_create_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " solicitacao_fatura "
    END IF
    
    LET m_ies_cons = FALSE

    LET l_sql_stmt = 
      "SELECT trans_solic_fatura",
      " FROM fat_solic_mestre", 
      " WHERE ",l_where CLIPPED,
      " AND empresa = '",p_cod_empresa,"' ",
      " ORDER BY ",l_order

    PREPARE var_cons FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","cliente_agrupa_970")
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

    FETCH cq_cons INTO m_trans_solic

    IF STATUS <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","cq_cons")
       ELSE
          LET m_msg = "Argumentos de pesquisa não encontrados."
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       END IF
       CALL pol1362_limpa_campos()
       RETURN FALSE
    END IF

    IF NOT pol1362_exibe_dados() THEN
       RETURN FALSE
    END IF
    
    LET m_ies_cons = TRUE
    LET m_trans_solica = m_trans_solic
    
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1362_exibe_dados()#
#-----------------------------#
   
   LET m_excluiu = FALSE
   LET mr_campos.trans_solic = m_trans_solic

   SELECT solicitacao_fatura, usuario, dat_refer 
     INTO 
       mr_campos.num_solicit,
       mr_campos.cod_usuario,
       mr_campos.dat_refer
     FROM fat_solic_mestre
    WHERE trans_solic_fatura = m_trans_solic

		IF STATUS <> 0 THEN
		   CALL log003_err_sql('SELECT','fat_solic_mestre:fed')
		   RETURN FALSE
		END IF

   SELECT DISTINCT
          transportadora,
          via_transporte,
          placa_veiculo,
          estado_placa_veic,
          texto_1,
          texto_2,
          texto_3
     INTO mr_campos.cod_transpor,
          mr_campos.cod_via,
          mr_campos.num_placa,
          mr_campos.uf_veiculo,
          mr_campos.cod_texto_1,
          mr_campos.cod_texto_2,
          mr_campos.cod_texto_3
     FROM fat_solic_fatura
    WHERE trans_solic_fatura = m_trans_solic

		IF STATUS <> 0 THEN
		   CALL log003_err_sql('SELECT','fat_solic_fatura')
		   RETURN FALSE
		END IF

   CALL pol1362_le_transp(mr_campos.cod_transpor)
   LET mr_campos.nom_transpor = m_nom_transp
                 
END FUNCTION

#--------------------------------#
FUNCTION pol1362_le_transp(l_cod)#
#--------------------------------#

   DEFINE l_cod        CHAR(15)
   
   SELECT nom_cliente
     INTO m_nom_transp
     FROM clientes
    WHERE cod_cliente = l_cod
      AND ies_situacao = "A" 
      #AND (cod_tip_cli = m_cod_transp  OR cod_tip_cli = m_cod_transp_auto)

   IF STATUS = 100 THEN
      LET m_nom_transp = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','transportador')
         LET m_nom_transp = NULL
      END IF
   END IF

END FUNCTION

#------------------------------#
FUNCTION pol1362_valid_transp()#
#------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
      
   IF mr_campos.cod_transpor IS NULL THEN
      LET m_msg = 'Informe o Transportador'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      CALL _ADVPL_set_property(m_transpor,"GET_FOCUS")
      RETURN FALSE
   END IF   

   CALL pol1362_le_transp(mr_campos.cod_transpor)
   LET mr_campos.nom_transpor = m_nom_transp
   
   IF mr_campos.nom_transpor IS NULL THEN
      LET m_msg = 'Transportador inexistente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      CALL _ADVPL_set_property(m_transpor,"GET_FOCUS")
      RETURN FALSE
   END IF      
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1362_zoom_trasport()#
#-------------------------------#

    DEFINE l_codigo       LIKE clientes.cod_cliente,
           l_descri       LIKE clientes.nom_cliente
    
    IF  m_ztransp IS NULL THEN
        LET m_ztransp = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_ztransp,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_ztransp,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_ztransp,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_descri = _ADVPL_get_property(m_ztransp,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")

    IF l_codigo IS NOT NULL THEN
       LET mr_campos.cod_transpor = l_codigo
       LET mr_campos.nom_transpor = l_descri
    END IF
    
    CALL _ADVPL_set_property(m_transpor,"GET_FOCUS")

END FUNCTION

#----------------------------#
FUNCTION pol1362_zoom_txt_1()#
#----------------------------#

    DEFINE l_codigo       LIKE texto_nf.cod_texto,
           l_descri       LIKE texto_nf.des_texto
    
    IF  m_zoom_txt IS NULL THEN
        LET m_zoom_txt = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_txt,"ZOOM","zoom_texto_nf")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_txt,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_txt,"RETURN_BY_TABLE_COLUMN","texto_nf","cod_texto")
    LET l_descri = _ADVPL_get_property(m_zoom_txt,"RETURN_BY_TABLE_COLUMN","texto_nf","des_texto")

    IF l_codigo IS NOT NULL THEN
       LET mr_campos.cod_texto_1 = l_codigo
    END IF
    
    CALL _ADVPL_set_property(m_texto_1,"GET_FOCUS")

END FUNCTION

#---------------------------#
FUNCTION pol1362_ck_texto1()#
#---------------------------#

   IF NOT pol1362_le_texto(mr_campos.cod_texto_1) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1362_ck_texto2()#
#---------------------------#

   IF NOT pol1362_le_texto(mr_campos.cod_texto_2) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1362_ck_texto3()#
#---------------------------#

   IF NOT pol1362_le_texto(mr_campos.cod_texto_3) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1362_le_texto(l_cod)#
#-------------------------------#
   
   DEFINE l_cod        LIKE texto_nf.cod_texto
   
   IF l_cod IS NOT NULL THEN
      SELECT des_texto
        FROM texto_nf
       WHERE cod_texto = l_cod
      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("SELECT","texto_nf",0)
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1362_zoom_txt_2()#
#----------------------------#

    DEFINE l_codigo       LIKE texto_nf.cod_texto,
           l_descri       LIKE texto_nf.des_texto
    
    IF  m_zoom_txt IS NULL THEN
        LET m_zoom_txt = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_txt,"ZOOM","zoom_texto_nf")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_txt,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_txt,"RETURN_BY_TABLE_COLUMN","texto_nf","cod_texto")
    LET l_descri = _ADVPL_get_property(m_zoom_txt,"RETURN_BY_TABLE_COLUMN","texto_nf","des_texto")

    IF l_codigo IS NOT NULL THEN
       LET mr_campos.cod_texto_2 = l_codigo
    END IF
    
    CALL _ADVPL_set_property(m_texto_2,"GET_FOCUS")

END FUNCTION


#----------------------------#
FUNCTION pol1362_zoom_txt_3()#
#----------------------------#

    DEFINE l_codigo       LIKE texto_nf.cod_texto,
           l_descri       LIKE texto_nf.des_texto
    
    IF  m_zoom_txt IS NULL THEN
        LET m_zoom_txt = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_txt,"ZOOM","zoom_texto_nf")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_txt,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_txt,"RETURN_BY_TABLE_COLUMN","texto_nf","cod_texto")
    LET l_descri = _ADVPL_get_property(m_zoom_txt,"RETURN_BY_TABLE_COLUMN","texto_nf","des_texto")

    IF l_codigo IS NOT NULL THEN
       LET mr_campos.cod_texto_3 = l_codigo
    END IF
    
    CALL _ADVPL_set_property(m_texto_3,"GET_FOCUS")

END FUNCTION

#--------------------------#
FUNCTION pol1362_zoom_via()#
#--------------------------#

    DEFINE l_codigo       LIKE via_transporte.cod_via_transporte,
           l_descri       LIKE via_transporte.den_via_transporte
    
    IF  m_zoom_via IS NULL THEN
        LET m_zoom_via = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_via,"ZOOM","zoom_via_transporte")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_via,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_via,"RETURN_BY_TABLE_COLUMN","via_transporte","cod_via_transporte")
    LET l_descri = _ADVPL_get_property(m_zoom_via,"RETURN_BY_TABLE_COLUMN","via_transporte","den_via_transporte")

    IF l_codigo IS NOT NULL THEN
       LET mr_campos.cod_via = l_codigo
    END IF
    
    CALL _ADVPL_set_property(m_via,"GET_FOCUS")

END FUNCTION

#------------------------#
FUNCTION pol1362_ck_via()#
#------------------------#

   IF mr_campos.cod_via IS NOT NULL THEN
      SELECT den_via_transporte
        FROM via_transporte
       WHERE cod_via_transporte = mr_campos.cod_via
      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("SELECT","via_transporte",0)
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1362_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1362_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1362_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_trans_solica = m_trans_solic

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_trans_solic
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_trans_solic
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_trans_solic
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_trans_solic
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_trans_solic = m_trans_solica
         EXIT WHILE
      ELSE
         SELECT 1
           FROM fat_solic_mestre
          WHERE trans_solic_fatura = m_trans_solic
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1362_exibe_dados()
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
FUNCTION pol1362_first()#
#-----------------------#

   IF NOT pol1362_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1362_next()#
#----------------------#

   IF NOT pol1362_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1362_previous()#
#--------------------------#

   IF NOT pol1362_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1362_last()#
#----------------------#

   IF NOT pol1362_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1362_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM fat_solic_mestre
     WHERE trans_solic_fatura = mr_campos.trans_solic
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

#-------------------------#
FUNCTION pol1362_alterar()#
#-------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1362_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1362_prende_registro() THEN
      RETURN FALSE
   END IF
   
   CALL pol1362_ativa_desativa(TRUE)
   CALL _ADVPL_set_property(m_transpor,'GET_FOCUS')
   
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1362_no_alterar()#
#----------------------------#
   
   CLOSE cq_prende
   CALL pol1362_exibe_dados()
   CALL pol1362_ativa_desativa(FALSE)

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1362_ies_alterar()#
#-----------------------------#
   
   IF pol1362_alt_solic() THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   CALL pol1362_ativa_desativa(FALSE)

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1362_alt_solic()#
#---------------------------#

   IF mr_campos.tip_frete = 'F' THEN 
      LET m_ies_modalidade = '1'
   ELSE
      LET m_ies_modalidade = '0'
   END IF

   UPDATE fat_solic_mestre SET usuario = p_user
    WHERE trans_solic_fatura = m_trans_solic     
      AND empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','fat_solic_mestre')
      RETURN FALSE
   END IF
   
   UPDATE fat_solic_fatura
      SET texto_1 = mr_campos.cod_texto_1,
          texto_2 = mr_campos.cod_texto_2,
          texto_3 = mr_campos.cod_texto_3,
          via_transporte = mr_campos.cod_via,
          transportadora = mr_campos.cod_transpor,
          placa_veiculo = mr_campos.num_placa,
          estado_placa_veic = mr_campos.uf_veiculo
    WHERE trans_solic_fatura = m_trans_solic         
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','fat_solic_fatura')
      RETURN FALSE
   END IF
   
   UPDATE fat_s_nf_eletr
      SET modalidade_frete_nfe = m_ies_modalidade
    WHERE trans_solic_fatura = m_trans_solic         
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','fat_s_nf_eletr')
      RETURN FALSE
   END IF

   IF NOT pol1362_atu_oms(
          mr_campos.cod_transpor, mr_campos.num_placa) THEN
      RETURN FALSE
   END IF
          
   RETURN TRUE

END FUNCTION

#------------------------------------------#
FUNCTION pol1362_atu_oms(l_transp, l_placa)#
#------------------------------------------#
   
   DEFINE l_transp     CHAR(15),
          l_placa      CHAR(15)
          
   UPDATE ordem_montag_mest
      SET cod_transpor = l_transp
    WHERE cod_empresa = p_cod_empresa
      AND num_om IN (SELECT ord_montag FROM fat_solic_fatura
                       WHERE trans_solic_fatura = m_trans_solic)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ordem_montag_mest')
      RETURN FALSE
	 END IF
    
   UPDATE ordem_montag_lote
      SET cod_transpor = l_transp,
          num_placa = l_placa
    WHERE cod_empresa = p_cod_empresa
      AND num_lote_om IN (SELECT lote_ord_montag FROM fat_solic_fatura
                       WHERE trans_solic_fatura = m_trans_solic)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ordem_montag_lote')
      RETURN FALSE
	 END IF
   
   RETURN TRUE

END FUNCTION
   
#------------------------#
FUNCTION pol1362_delete()#
#------------------------#
   
   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1362_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a exclusão do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1362_prende_registro() THEN
      RETURN FALSE
   END IF
  
   IF pol1362_del_solic() THEN
      CALL log085_transacao("COMMIT")
      CALL pol1362_limpa_campos()
      LET m_excluiu = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")      
   END IF
   
   CLOSE cq_prende
   
   RETURN TRUE
        
END FUNCTION

#---------------------------#
FUNCTION pol1362_del_solic()#
#---------------------------#

   DELETE FROM fat_solic_mestre
    WHERE trans_solic_fatura = m_trans_solic

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','fat_solic_mestre')
      RETURN FALSE
   END IF

   IF NOT pol1362_atu_oms('0','') THEN
      RETURN FALSE
   END IF
   
   DELETE FROM fat_solic_fatura
    WHERE trans_solic_fatura = m_trans_solic

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','fat_solic_fatura')
      RETURN FALSE
   END IF

   DELETE FROM fat_solic_embal
    WHERE trans_solic_fatura = m_trans_solic

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','fat_solic_embal')
      RETURN FALSE
   END IF

   DELETE FROM fat_exp_nf
    WHERE trans_nota_fiscal = m_trans_solic

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','fat_exp_nf')
      RETURN FALSE
   END IF

   DELETE FROM fat_s_nf_eletr
    WHERE trans_solic_fatura = m_trans_solic

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','fat_s_nf_eletr')
      RETURN FALSE
   END IF

   UPDATE carga_fiat_970
      SET ies_situa = 'ABERTA',
          num_solicit = NULL
    WHERE num_solicit = mr_campos.num_solicit

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','carga_fiat_970')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
