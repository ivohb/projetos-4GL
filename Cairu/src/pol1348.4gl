--------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1348                                                 #
# OBJETIVO: RELATÓRIO DE TITULOS A RECEBER - CRE1500                #
# AUTOR...: IVO                                                     #
# DATA....: 30/05/18                                                #
#-------------------------------------------------------------------#

DATABASE logix 

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_den_empresa   LIKE empresa.den_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_versao        CHAR(18),
           comando         CHAR(80),
           p_ies_impressao CHAR(01),
           g_ies_ambiente  CHAR(01),
           p_caminho       CHAR(080),
           p_nom_arquivo   CHAR(100),
           g_tipo_sgbd     CHAR(003),
           g_msg           CHAR(150),
           p_qtd_lote      DECIMAL(10,3)
           
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_browse          VARCHAR(10),
       m_empresa         VARCHAR(10),
       m_lupa_emp        VARCHAR(10),
       m_zoom_emp        VARCHAR(10),
       m_per_ini         VARCHAR(10),
       m_per_fim         VARCHAR(10),
       m_cliente         VARCHAR(10),
       m_dat_base        VARCHAR(10),
       m_lupa_cli        VARCHAR(10),
       m_zoom_cli        VARCHAR(10),
       m_panel           VARCHAR(10)

DEFINE m_ies_cons        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ind             INTEGER,
       m_dat_atu         DATE,
       m_qtd_linha       INTEGER,
       m_index           INTEGER,
       m_carregando      SMALLINT,
       m_query           CHAR(3000),
       m_removeu         SMALLINT

       
DEFINE mr_cabec          RECORD     
       dat_base          DATE,     #data p/ calculo do atraso
       empresa           CHAR(01), #T=todas S=Selecionar
       cliente           CHAR(01), #T=todas S=Selecionar
       dat_ini           DATE,
       dat_fim           DATE,
       tipo              CHAR(01)   
END RECORD

DEFINE ma_empresa        ARRAY[100] OF RECORD
       cod_empresa       CHAR(02),
       den_empresa       CHAR(36),
       filler            CHAR(01)
END RECORD

DEFINE m_ldialog        VARCHAR(10),
       m_lstatusbar     VARCHAR(10),
       m_lbrowse        VARCHAR(10),
       m_cli_zoom       VARCHAR(10)
       
DEFINE m_nom_cliente    LIKE clientes.nom_cliente,
       m_num_cgc_cpf    LIKE clientes.num_cgc_cpf,
       m_num_telefone   LIKE clientes.num_telefone

DEFINE ma_cliente       ARRAY[1000] OF RECORD
       cod_cliente      CHAR(15),
       nom_cliente      CHAR(40),
       filler           CHAR(01)
END RECORD

DEFINE ma_tipo          ARRAY[100] OF RECORD
       ies_select       CHAR(01),
       ies_tip_docum    CHAR(03),
       des_tipo_docum   CHAR(40),
       filler           CHAR(01)
END RECORD

DEFINE mr_relat         RECORD
       cod_empresa       LIKE docum.cod_empresa,
       ies_tip_docum     LIKE docum.ies_tip_docum,
       num_docum         LIKE docum.num_docum,
       cod_cliente       LIKE docum.cod_cliente,
       dat_emis          LIKE docum.dat_emis,
       dat_vencto_s_desc LIKE docum.dat_vencto_s_desc,
       dat_prorrogada    LIKE docum.dat_prorrogada,
       val_docum         LIKE docum.val_saldo,
       cod_repres_1      LIKE docum.cod_repres_1,
       cod_portador      LIKE docum.cod_portador
END RECORD

DEFINE m_des_titulo      CHAR(65),
       m_dat_vencto      DATE,
       m_dias_atraso     DECIMAL(6,0)

#-----------------#
FUNCTION pol1348()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 30
   DEFER INTERRUPT

   LET g_tipo_sgbd = LOG_getCurrentDBType()

   LET p_versao = "pol1348-12.00.02  "
   CALL func002_versao_prg(p_versao)
   
   CALL pol1348_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1348_menu()#
#----------------------#

    DEFINE l_menubar    VARCHAR(10),
           l_panel      VARCHAR(10),
           l_info       VARCHAR(10),
           l_print      VARCHAR(10),
           l_titulo     CHAR(50)

    LET m_carregando = TRUE
    LET m_dat_atu = TODAY
    LET m_ies_cons = FALSE
    LET l_titulo = "RELATÓRIO DE TITULOS - CRE1500 BASE "
    
    CALL pol1348_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)
        
    LET l_info = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_info,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_info,"EVENT","pol1348_informar")
    CALL _ADVPL_set_property(l_info,"CONFIRM_EVENT","pol1348_confirmar")
    CALL _ADVPL_set_property(l_info,"CANCEL_EVENT","pol1348_cancelar")

    LET l_print = _ADVPL_create_component(NULL,"LPRINTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_print,"EVENT","pol1348_imprimir")
    CALL _ADVPL_set_property(l_print,"TOOLTIP","Imprimir titulos")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET m_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(m_panel,"ALIGN","CENTER")

    CALL pol1348_cria_campos(m_panel)
    CALL pol1348_ativa_desativa(FALSE)
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1348_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,20)
    CALL _ADVPL_set_property(l_label,"TEXT","Data base:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dat_base = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel)
    CALL _ADVPL_set_property(m_dat_base,"POSITION",70,20)
    CALL _ADVPL_set_property(m_dat_base,"VARIABLE",mr_cabec,"dat_base")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",190,20)
    CALL _ADVPL_set_property(l_label,"TEXT","Período:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_per_ini = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel)
    CALL _ADVPL_set_property(m_per_ini,"POSITION",240,20)
    CALL _ADVPL_set_property(m_per_ini,"VARIABLE",mr_cabec,"dat_ini")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",360,20)
    CALL _ADVPL_set_property(l_label,"TEXT","Até:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_per_fim = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel)
    CALL _ADVPL_set_property(m_per_fim,"POSITION",390,20)
    CALL _ADVPL_set_property(m_per_fim,"VARIABLE",mr_cabec,"dat_fim")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",510,20)
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cliente = _ADVPL_create_component(NULL,"LCOMBOBOX",l_panel)
    CALL _ADVPL_set_property(m_cliente,"POSITION",560,20)
    CALL _ADVPL_set_property(m_cliente,"ADD_ITEM","T","Todos")     
    CALL _ADVPL_set_property(m_cliente,"ADD_ITEM","S","Selecionar")     
    CALL _ADVPL_set_property(m_cliente,"VARIABLE",mr_cabec,"Cliente")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",680,20)
    CALL _ADVPL_set_property(l_label,"TEXT","Tip duplicata:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_empresa = _ADVPL_create_component(NULL,"LCOMBOBOX",l_panel)
    CALL _ADVPL_set_property(m_empresa,"POSITION",755,20)
    CALL _ADVPL_set_property(m_empresa,"ADD_ITEM","T","Todos")     
    CALL _ADVPL_set_property(m_empresa,"ADD_ITEM","S","Selecionar")     
    CALL _ADVPL_set_property(m_empresa,"VARIABLE",mr_cabec,"tipo")


END FUNCTION






#-----------------------------#
FUNCTION pol1348_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL

        
END FUNCTION

#----------------------------------------#
FUNCTION pol1348_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT   
   
   CALL _ADVPL_set_property(m_panel,"EDITABLE",l_status)
   
END FUNCTION


#--------------------------#
FUNCTION pol1348_informar()#
#--------------------------#
   
   DEFINE l_data    DATE
   
   LET m_ies_cons = FALSE

    DROP TABLE cli_select_pol1348
    CREATE  TABLE cli_select_pol1348 (cod_cliente CHAR(15));

    IF STATUS <> 0 THEN
       CALL log003_err_sql('CREATE','cli_select_pol1348')
       RETURN FALSE
    END IF     

    DROP TABLE tip_select_pol1348
    CREATE  TABLE tip_select_pol1348 (cod_tipo CHAR(03));

    IF STATUS <> 0 THEN
       CALL log003_err_sql('CREATE','tip_select_pol1348')
       RETURN FALSE
    END IF     
    
    DROP TABLE docum_proces_pol1348
    CREATE  TABLE docum_proces_pol1348 (
       cod_empresa       LIKE docum.cod_empresa,
       ies_tip_docum     LIKE docum.ies_tip_docum,
       num_docum         LIKE docum.num_docum,
       cod_cliente       LIKE docum.cod_cliente,
       dat_emis          LIKE docum.dat_emis,
       dat_vencto_s_desc LIKE docum.dat_vencto_s_desc,
       dat_prorrogada    LIKE docum.dat_prorrogada,
       val_docum         LIKE docum.val_saldo,
       cod_repres_1      LIKE docum.cod_repres_1,
       cod_portador      LIKE docum.cod_portador
    );

    IF STATUS <> 0 THEN
       CALL log003_err_sql('CREATE','docum_proces_pol1348')
       RETURN FALSE
    END IF     
    
    CREATE INDEX ix_docum_proces_pol1348 ON docum_proces_pol1348
     (cod_empresa, cod_cliente, dat_vencto_s_desc); 
             
   CALL pol1348_ativa_desativa(TRUE)
   CALL pol1348_limpa_campos()
   
   SELECT dat_proces_doc 
     INTO mr_cabec.dat_base FROM par_cre
   
   IF mr_cabec.dat_base IS NULL THEN
      LET mr_cabec.dat_base = TODAY
   END IF
   
   LET mr_cabec.dat_ini = mr_cabec.dat_base
   LET mr_cabec.dat_fim = mr_cabec.dat_base
   LET mr_cabec.cliente = 'T'
   LET mr_cabec.tipo = 'T'
   
   CALL _ADVPL_set_property(m_dat_base,"GET_FOCUS")
      
   RETURN TRUE 
    
END FUNCTION

#--------------------------#
FUNCTION pol1348_cancelar()#
#--------------------------#

    CALL pol1348_limpa_campos()
    CALL pol1348_ativa_desativa(FALSE)
    LET m_ies_cons = FALSE
    RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1348_confirmar()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,'CLEAR_TEXT')   
   
   IF mr_cabec.dat_ini IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe a data inicial.")
      CALL _ADVPL_set_property(m_per_ini,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_cabec.dat_fim IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe a data final.")
      CALL _ADVPL_set_property(m_per_fim,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_cabec.dat_fim < mr_cabec.dat_ini THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Data Inicial nao pode ser maior que data Final.")
      CALL _ADVPL_set_property(m_per_ini,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_cabec.cliente = 'S' THEN      
      INITIALIZE ma_cliente TO NULL
      IF NOT pol1348_sel_cliente() THEN
         LET m_msg = 'Operação cancelada.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg);
         RETURN FALSE
      END IF
   END IF

   IF mr_cabec.tipo = 'S' THEN
      IF NOT pol1348_sel_tipo() THEN
         LET m_msg = 'Operação cancelada.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg);
         RETURN FALSE
      END IF
   END IF
   
   CALL pol1348_ativa_desativa(FALSE)
   LET m_ies_cons = TRUE


   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1348_sel_cliente()#
#-----------------------------#
  
   DEFINE l_titulo        VARCHAR(40),
          l_panel         VARCHAR(10),
          l_confirma      VARCHAR(10),
          l_cancela       VARCHAR(10),
          l_menubar       VARCHAR(10)
          
    LET l_titulo = 'SELECÇÃO DE CLIENTES PARA O RELATÓRIO'
      
    LET m_ldialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_ldialog,"SIZE",800,480) #480
    CALL _ADVPL_set_property(m_ldialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_ldialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_ldialog,"INIT_EVENT","pol1348_posiciona")
    
    LET m_lstatusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_ldialog)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_ldialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)
    
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
    CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_confirma,"EVENT","pol1348_cli_confirma")  

    LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
    CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_cancela,"EVENT","pol1348_cli_cancela")     

    CALL pol1348_cli_grade()
    CALL _ADVPL_set_property(m_ldialog,"ACTIVATE",TRUE)
            
    
END FUNCTION

#---------------------------#
FUNCTION pol1348_posiciona()#
#---------------------------#

   CALL _ADVPL_set_property(m_lbrowse,"SELECT_ITEM",1,1)

END FUNCTION

#------------------------------#
FUNCTION pol1348_cli_confirma()#
#------------------------------#
  
   LET m_count = _ADVPL_get_property(m_lbrowse,"ITEM_COUNT")
   
   FOR m_ind = 1 TO m_count
      IF ma_cliente[m_ind].cod_cliente IS NOT NULL THEN
         INSERT INTO cli_select_pol1348 VALUES(ma_cliente[m_ind].cod_cliente)
         IF STATUS <> 0 THEN
            CALL log003_err_sql('INSERT','cli_select_pol1348')
            RETURN FALSE
         END IF
      END IF
   END FOR
   
   CALL _ADVPL_set_property(m_ldialog,"ACTIVATE",FALSE)
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1348_cli_cancela()#
#-----------------------------#

   CALL _ADVPL_set_property(m_ldialog,"ACTIVATE",FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1348_cli_grade()#
#---------------------------#

    DEFINE l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)
  
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_ldialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_lbrowse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_lbrowse,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_lbrowse,"AFTER_ROW_EVENT","pol1348_after_line")    
    #CALL _ADVPL_set_property(m_lbrowse,"AFTER_EDIT_ROW","pol1348_cli_valida") 
    CALL _ADVPL_set_property(m_lbrowse,"BEFORE_REMOVE_ROW_EVENT","pol1348_before_remove") 
   
   
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_lbrowse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_lbrowse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1348_cli_zoom")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_lbrowse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome do cliemte")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_lbrowse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(m_lbrowse,"SET_ROWS",ma_cliente,1)
    CALL _ADVPL_set_property(m_lbrowse,"EDITABLE",TRUE)


END FUNCTION

#----------------------------#
FUNCTION pol1348_after_line()#
#----------------------------#

   DEFINE l_lin_atu       SMALLINT,
          l_ind           SMALLINT
         
   CALL _ADVPL_set_property(m_lstatusbar,"ERROR_TEXT",'')
   
   IF m_removeu THEN
      LET m_removeu = FALSE
      RETURN TRUE
   END IF
   
   LET l_lin_atu = _ADVPL_get_property(m_lbrowse,"ROW_SELECTED")   
   LET m_count = _ADVPL_get_property(m_lbrowse,"ITEM_COUNT")

   FOR l_ind = 1 TO m_count
      IF l_ind <> l_lin_atu THEN
         IF ma_cliente[l_lin_atu].cod_cliente = ma_cliente[l_ind].cod_cliente THEN
            LET m_msg = 'Cliente já informado.'
            CALL _ADVPL_set_property(m_lstatusbar,"ERROR_TEXT",m_msg)
            RETURN FALSE
         END IF
      END IF
   END FOR      
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1348_before_remove()#
#-------------------------------#   

   LET m_removeu = TRUE
   RETURN TRUE
   
END FUNCTION
 
#--------------------------#
FUNCTION pol1348_cli_zoom()#
#--------------------------#

    DEFINE l_codigo       LIKE clientes.cod_cliente,
           l_descri       LIKE clientes.nom_cliente,
           l_lin_atu      SMALLINT
   
    LET l_lin_atu = _ADVPL_get_property(m_lbrowse,"ROW_SELECTED")
    
    IF  m_cli_zoom IS NULL THEN
        LET m_cli_zoom = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_cli_zoom,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_cli_zoom,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_cli_zoom,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_descri = _ADVPL_get_property(m_cli_zoom,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")

    IF l_codigo IS NOT NULL THEN
       LET ma_cliente[l_lin_atu].cod_cliente = l_codigo
       CALL pol1348_le_cliente(l_codigo)
       LET ma_cliente[l_lin_atu].nom_cliente = m_nom_cliente
    END IF
    
END FUNCTION

#---------------------------------#
FUNCTION pol1348_le_cliente(l_cod)#
#---------------------------------#

   DEFINE l_cod        CHAR(15)
   
   SELECT nom_cliente,
          num_cgc_cpf,
          num_telefone
     INTO m_nom_cliente,
          m_num_cgc_cpf,
          m_num_telefone
     FROM clientes
    WHERE cod_cliente = l_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','clientes')
      LET m_nom_cliente = ''
   END IF

END FUNCTION

   

#--------------------------#
FUNCTION pol1348_sel_tipo()#
#--------------------------#

   DEFINE l_titulo        VARCHAR(40),
          l_panel         VARCHAR(10),
          l_confirma      VARCHAR(10),
          l_cancela       VARCHAR(10),
          l_menubar       VARCHAR(10)
          
    LET l_titulo = 'SELECÇÃO DE TIPOS DE DOCUMENTOS'
      
    LET m_ldialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_ldialog,"SIZE",800,480) #480
    CALL _ADVPL_set_property(m_ldialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_ldialog,"ENABLE_ESC_CLOSE",FALSE)
    
    LET m_lstatusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_ldialog)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_ldialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)
    
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
    CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_confirma,"EVENT","pol1348_tip_confirma")  

    LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
    CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_cancela,"EVENT","pol1348_tip_cancela")     

    CALL pol1348_tip_grade()
    CALL pol1348_le_tipos()
    CALL _ADVPL_set_property(m_ldialog,"ACTIVATE",TRUE)
            
    
END FUNCTION

#---------------------------#
FUNCTION pol1348_tip_grade()#
#---------------------------#
   
    DEFINE l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_ldialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_lbrowse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_lbrowse,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_lbrowse)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CONFIRM_EX")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sel")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_select")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
   
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_lbrowse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_tip_docum")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_lbrowse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","des_tipo_docum")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_lbrowse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

END FUNCTION

#--------------------------#
FUNCTION pol1348_le_tipos()#
#--------------------------#

   INITIALIZE ma_tipo TO NULL
   CALL _ADVPL_set_property(m_lbrowse,"CLEAR")
   LET m_index = 1
   
   DECLARE cq_tipos CURSOR FOR
    SELECT 'N', ies_tip_docum,
           des_tipo_docum
      FROM par_tipo_docum
     WHERE cod_empresa = p_cod_empresa
     ORDER BY ies_tip_docum

   FOREACH cq_tipos INTO 
           ma_tipo[m_index].ies_select,
           ma_tipo[m_index].ies_tip_docum,
           ma_tipo[m_index].des_tipo_docum

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_tipos')
         EXIT FOREACH
      END IF
      
      LET m_index = m_index + 1
      
      IF m_index > 100 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET m_index = m_index - 1
   CALL _ADVPL_set_property(m_lbrowse,"SET_ROWS",ma_tipo,m_index)

END FUNCTION

#-----------------------------#
FUNCTION pol1348_tip_cancela()#
#-----------------------------#

   CALL _ADVPL_set_property(m_ldialog,"ACTIVATE",FALSE)
   
   RETURN TRUE

END FUNCTION
                 
#------------------------------#
FUNCTION pol1348_tip_confirma()#
#------------------------------#
   
   LET m_count = _ADVPL_get_property(m_lbrowse,"ITEM_COUNT")
   
   FOR m_ind = 1 TO m_count
      IF ma_tipo[m_ind].ies_select = 'S' THEN
         INSERT INTO tip_select_pol1348 VALUES(ma_tipo[m_ind].ies_tip_docum)
         IF STATUS <> 0 THEN
            CALL log003_err_sql('INSERT','tip_select_pol1348')
            RETURN FALSE
         END IF
      END IF
   END FOR

   CALL _ADVPL_set_property(m_ldialog,"ACTIVATE",FALSE)
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1348_imprimir()#
#--------------------------#
                 
   IF NOT m_ies_cons THEN
      LET m_msg = 'Informe os parâmetros previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg);
      RETURN FALSE
   END IF
   
   LET m_ies_cons = FALSE

   IF NOT pol1348_monta_select() THEN
      RETURN FALSE
   END IF
   
   SELECT COUNT(*) INTO m_count
    FROM docum_proces_pol1348
   
   IF m_count = 0 THEN
      LET m_msg = 'Não a dados a processar, para os parâmetros informados.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg);
      RETURN FALSE
   END IF
      
   CALL LOG_progresspopup_start("Imprimindo...","pol1348_start_print","PROCESS")

   IF NOT p_status THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", 'Impressão cancelada.')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#                
FUNCTION pol1348_monta_select()#
#------------------------------#
   
   DEFINE l_sel_cli      INTEGER,
          l_sel_tip      INTEGER,
          l_erro         CHAR(10)        
       
   SELECT COUNT(*) INTO l_sel_cli FROM cli_select_pol1348    

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cli_select_pol1348')
      RETURN FALSE
   END IF
       
   SELECT COUNT(*) INTO l_sel_tip FROM tip_select_pol1348

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','tip_select_pol1348')
      RETURN FALSE
   END IF
      
   LET m_query = 
       "SELECT cod_empresa, ies_tip_docum, num_docum, cod_cliente, ",
       " dat_emis, dat_vencto_s_desc, dat_prorrogada, val_saldo, cod_repres_1, ",
       " cod_portador FROM docum WHERE cod_empresa = '",p_cod_empresa,"' ",
       " AND ies_situa_docum NOT IN ('C','E') ",
       " AND val_saldo > 0 ",
       " AND DATE(dat_vencto_s_desc) >= '",mr_cabec.dat_ini,"' ",
       " AND DATE(dat_vencto_s_desc) <= '",mr_cabec.dat_fim,"' "
    
   IF l_sel_cli > 0 THEN
      LET m_query = m_query CLIPPED,
          " AND cod_cliente IN (SELECT cod_cliente FROM cli_select_pol1348) "
   END IF
   
   IF l_sel_tip > 0 THEN
      LET m_query = m_query CLIPPED,
          " AND ies_tip_docum IN (SELECT cod_tipo FROM tip_select_pol1348) "
   END IF
   
   PREPARE le_reg FROM m_query   
   
   DECLARE cq_reg CURSOR FOR le_reg
         
   FOREACH cq_reg INTO mr_relat.* 

      IF STATUS <> 0 THEN
         LET l_erro = STATUS
         CALL log003_err_sql(l_erro,'lendo documentos a processar')
         RETURN FALSE
      END IF

      IF mr_relat.dat_prorrogada IS NOT NULL THEN
         LET mr_relat.dat_vencto_s_desc = mr_relat.dat_prorrogada
      END IF
      
      INSERT INTO docum_proces_pol1348 VALUES (mr_relat.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','docum_proces_pol1348')
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1348_start_print()#
#-----------------------------#

   LET m_des_titulo = 'DOCUMENTOS EM ABERTO COM VENCTO DE',
       mr_cabec.dat_ini, ' A ', mr_cabec.dat_fim

   LET p_status = StartReport(
      "pol1348_le_docs","pol1348",m_des_titulo,132,TRUE,TRUE)

END FUNCTION

#---------------------------------#
FUNCTION pol1348_le_docs(l_report)#
#---------------------------------#

   DEFINE l_report             CHAR(300),
          l_status             SMALLINT
      
   START REPORT pol1348_relat TO l_report

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_den_empresa = NULL
   END IF
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DECLARE cq_relat CURSOR FOR
    SELECT * 
      FROM docum_proces_pol1348 
     ORDER BY cod_cliente, dat_vencto_s_desc   
   
   FOREACH cq_relat INTO mr_relat.*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','docum_proces_pol1348:cq_relat')
         EXIT FOREACH
      END IF
      
      LET m_dat_vencto = mr_relat.dat_vencto_s_desc
      
      IF m_dat_vencto < mr_cabec.dat_base THEN
         LET m_dias_atraso = mr_cabec.dat_base - m_dat_vencto
      ELSE
         LET m_dias_atraso = 0
      END IF
      
      CALL pol1348_le_cliente(mr_relat.cod_cliente)
      
      OUTPUT TO REPORT pol1348_relat(mr_relat.cod_cliente)

      LET l_status = LOG_progresspopup_increment("PROCESS")
            
   END FOREACH
   
   FINISH REPORT pol1348_relat 
   CALL FinishReport("pol1348")

END FUNCTION

#----------------------------------#
REPORT pol1348_relat(l_cod_cliente)#
#----------------------------------# 

   DEFINE l_cod_cliente     CHAR(15),
          l_titulo          CHAR(65)

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3

   ORDER EXTERNAL BY l_cod_cliente

   FORMAT

   PAGE HEADER
      PRINT
      #PRINT COLUMN 001, m_des_titulo
      PRINT COLUMN 001, 'ESP DOCUMENTO      CLIENTE                        DT EMISSÃO DT VENCTO    VALOR (R$) ATRASO PORTADOR REPRES.'
      PRINT COLUMN 001, '--- -------------- ------------------------------ ---------- ---------- ------------ ------ -------- -------'
         
   ON EVERY ROW

      PRINT COLUMN 001, mr_relat.ies_tip_docum,
            COLUMN 005, mr_relat.num_docum,
            COLUMN 020, m_nom_cliente[1,30],
            COLUMN 051, mr_relat.dat_emis,
            COLUMN 062, m_dat_vencto,
            COLUMN 073, mr_relat.val_docum USING '########&.&&',
            COLUMN 086, m_dias_atraso USING '######',
            COLUMN 097, mr_relat.cod_portador USING '####',
            COLUMN 105, mr_relat.cod_repres_1 USING '####'

   AFTER GROUP OF l_cod_cliente

      PRINT COLUMN 001, '------------------------------------------------------------------------------------------------------------'
      PRINT COLUMN 001, 'FONE: ', m_num_telefone,
            COLUMN 073, GROUP SUM(mr_relat.val_docum) USING '########&.&&'
      PRINT COLUMN 001, 'CNPJ: ', m_num_cgc_cpf
      PRINT COLUMN 001, '------------------------------------------------------------------------------------------------------------'
      PRINT                        
                   
   ON LAST ROW
      
      PRINT
      PRINT COLUMN 001, 'TOTAL EMPRESA: ', 
            COLUMN 067,  SUM(mr_relat.val_docum) USING '###,###,###,##&.&&'

END REPORT



   