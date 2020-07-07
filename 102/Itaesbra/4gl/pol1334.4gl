#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1334                                                 #
# OBJETIVO: SOLICITAÇÃO DE FATURAMENTO                              #
# AUTOR...: IVO                                                     #
# DATA....: 16/10/17                                                #
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
           g_msg           CHAR(150)
           
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_browse          VARCHAR(10),
       m_empresa         VARCHAR(10),
       m_pedido          VARCHAR(10),
       m_lpedido         VARCHAR(10),
       m_zpedido         VARCHAR(10),
       m_cliente         VARCHAR(10),
       m_lcliente        VARCHAR(10),
       m_zcliente        VARCHAR(10),
       m_panel           VARCHAR(10),
       m_desc_cli        VARCHAR(10),
       m_placa           VARCHAR(10),
       m_estado          VARCHAR(10),
       m_solicit         VARCHAR(10),
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
       m_stat_bar        VARCHAR(10)
       

DEFINE m_from_agrupa     VARCHAR(10),
       m_brw_agrupa      VARCHAR(10)

DEFINE m_ies_cons        SMALLINT,
       m_ies_sel         SMALLINT,
       m_houve_erro      SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ind             INTEGER,
       m_dat_atu         DATE,
       m_qtd_om          INTEGER,
       m_index           INTEGER,
       m_carregando      SMALLINT,
       m_query           CHAR(3000),
       m_cod_transpor    CHAR(15),
       m_cod_cliente     CHAR(15),
       m_num_solicit     INTEGER,
       m_num_pedido      INTEGER,
       m_controle        INTEGER,
       m_sequencia       INTEGER,
       m_clik_cab        SMALLINT,
       m_num_transac     INTEGER,
       m_qtd_linha       INTEGER,
       m_ies_agrupar     SMALLINT,
       m_qtd_itens       INTEGER,
       m_clik_sel        SMALLINT

DEFINE mr_cabec          RECORD
       cod_empresa       CHAR(02),
       cod_cliente       CHAR(15),
       num_pedido        DECIMAL(6,0),
       num_placa         CHAR(07),
       cod_estado        CHAR(02),
			 cod_texto_1       DECIMAL(3,0),
			 cod_texto_2       DECIMAL(3,0),
			 cod_texto_3       DECIMAL(3,0),
			 cod_via           DECIMAL(2,0),
			 num_solicit       INTEGER
END RECORD

DEFINE ma_ordem           ARRAY[1000] OF RECORD
       ies_faturar        CHAR(01),
       cod_cliente        CHAR(15),
       nom_cliente        CHAR(15),
       num_om             INTEGER,
       dat_emis           DATE,
       qtd_volume_om      INTEGER,
       cod_transpor       CHAR(15),
       nom_transpor       CHAR(15),
       filler             CHAR(01)
END RECORD

DEFINE ma_item            ARRAY[100] OF RECORD
       num_om             INTEGER,
       num_pedido         INTEGER,
       num_sequencia      DECIMAL(5,0),
       cod_item           CHAR(15),
       den_item_reduz     CHAR(15),
       qtd_reservada      DECIMAL(10,3),
       cod_embal_int      CHAR(03),
       qtd_volume_item    INTEGER,
       filler             CHAR(01)
END RECORD

DEFINE m_brz_item         VARCHAR(10)

DEFINE m_num_om           INTEGER

DEFINE m_nser             LIKE vdp_num_docum.serie_docum,
       m_sser             LIKE vdp_num_docum.subserie_docum,
       m_espcie           LIKE vdp_num_docum.especie_docum,
       m_tip_docum        LIKE vdp_num_docum.tip_docum,
       m_tip_solic        LIKE vdp_num_docum.tip_solicitacao

DEFINE p_num_transac      INTEGER,      
       p_controle         INTEGER,      
       p_num_om           INTEGER,      
       p_num_pedido       INTEGER,      
       p_cod_cliente      CHAR(15),     
       p_cod_nat_oper     INTEGER,      
       p_cod_tip_carteira CHAR(06),     
       p_nom_cliente      CHAR(18),     
       p_index            INTEGER,
       p_qtd_linha        INTEGER      

DEFINE pr_pedido           ARRAY[300] OF RECORD
       num_om              INTEGER,                         
       num_pedido          INTEGER,                            
       cod_cliente         CHAR(15),                           
       nom_cliente         CHAR(18),                           
       cod_nat_oper        LIKE pedidos.cod_nat_oper,          
       cod_tip_carteira    LIKE pedidos.cod_tip_carteira,      
       controle            DECIMAL(2,0),
       filler              CHAR(01)                 
END RECORD

#-----------------#
FUNCTION pol1334()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 30

   LET g_tipo_sgbd = LOG_getCurrentDBType()
   
   LET p_versao = "pol1334-12.00.04  "
   CALL func002_versao_prg(p_versao)
   
   CALL pol1334_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1334_menu()#
#----------------------#

    DEFINE l_menubar    VARCHAR(10),
           l_panel      VARCHAR(10),
           l_find       VARCHAR(10),
           l_select     VARCHAR(10),
           l_proces     VARCHAR(10),
           l_agrupar    VARCHAR(10),
           l_titulo     CHAR(50)

    LET m_carregando = TRUE
    LET l_titulo = "SOLICITAÇÃO DE FATURAMENTO "
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)
        
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1334_find")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1334_find_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1334_find_cancel")

    LET l_select = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_select,"IMAGE","SELECAO_MANUAL") 
    CALL _ADVPL_set_property(l_select,"TOOLTIP","Selecionar OMs para faturar")
    CALL _ADVPL_set_property(l_select,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_select,"EVENT","pol1334_selec_oms")
    CALL _ADVPL_set_property(l_select,"CONFIRM_EVENT","pol1334_yes_selec")
    CALL _ADVPL_set_property(l_select,"CANCEL_EVENT","pol1334_no_selec")

    LET l_proces = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_proces,"IMAGE","INCLUI_SOLICITACAO") 
    CALL _ADVPL_set_property(l_proces,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Gerar solicitação")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1334_gerar")

    LET l_agrupar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_agrupar,"IMAGE","AGRUPAR_EX") 
    CALL _ADVPL_set_property(l_agrupar,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_agrupar,"TOOLTIP","Agrupar OMs")
    CALL _ADVPL_set_property(l_agrupar,"EVENT","pol1334_agrupar")
    CALL _ADVPL_set_property(l_agrupar,"CONFIRM_EVENT","pol1334_yes_agrupa")
    CALL _ADVPL_set_property(l_agrupar,"CANCEL_EVENT","pol1334_no_agrupa")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1334_limpa_campos()
    CALL pol1334_cabec(l_panel)
    CALL pol1334_ordens(l_panel)
    CALL pol1334_itnes(l_panel)
    CALL pol1334_ativa_desativa(FALSE)
    CALL pol1334_set_solicit(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1334_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_ordem TO NULL
   INITIALIZE ma_item TO NULL
   
   LET mr_cabec.cod_empresa = p_cod_empresa
   
END FUNCTION

#----------------------------------#
FUNCTION pol1334_cabec(l_container)#
#----------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",40)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Filial:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",50,10)     
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"cod_empresa")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",3,0)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@!")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",105,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")    

    LET m_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_cliente,"POSITION",155,10)     
    CALL _ADVPL_set_property(m_cliente,"VARIABLE",mr_cabec,"cod_cliente")
    CALL _ADVPL_set_property(m_cliente,"LENGTH",15,0)
    CALL _ADVPL_set_property(m_cliente,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cliente,"VALID","pol1334_checa_cli")

    LET m_lcliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lcliente,"POSITION",290,10)     
    CALL _ADVPL_set_property(m_lcliente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lcliente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lcliente,"CLICK_EVENT","pol1334_zoom_cliente")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",330,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Pedido:")    

    LET m_pedido = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_pedido,"POSITION",380,10)     
    CALL _ADVPL_set_property(m_pedido,"VARIABLE",mr_cabec,"num_pedido")
    CALL _ADVPL_set_property(m_pedido,"LENGTH",6,0)

    {LET m_lpedido = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lpedido,"POSITION",470,10)     
    CALL _ADVPL_set_property(m_lpedido,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lpedido,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lpedido,"CLICK_EVENT","pol1334_zoom_pedido")}

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",473,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Solicit:")   
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_solicit = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_solicit,"POSITION",520,10)   
    CALL _ADVPL_set_property(m_solicit,"EDITABLE",FALSE)   
    CALL _ADVPL_set_property(m_solicit,"VARIABLE",mr_cabec,"num_solicit")
    CALL _ADVPL_set_property(m_solicit,"LENGTH",7,0)
    CALL _ADVPL_set_property(m_solicit,"VALID","pol1334_ck_solicit")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",600,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Texto1:")    

    LET m_texto_1 = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_texto_1,"POSITION",650,10)     
    CALL _ADVPL_set_property(m_texto_1,"VARIABLE",mr_cabec,"cod_texto_1")
    CALL _ADVPL_set_property(m_texto_1,"LENGTH",3,0)
    CALL _ADVPL_set_property(m_texto_1,"VALID","pol1334_ck_texto1")
    
    LET m_lupa_tx1 = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_tx1,"POSITION",690,10)     
    CALL _ADVPL_set_property(m_lupa_tx1,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_tx1,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_tx1,"CLICK_EVENT","pol1334_zoom_txt_1")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",730,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Texto2:")    

    LET m_texto_2 = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_texto_2,"POSITION",780,10)     
    CALL _ADVPL_set_property(m_texto_2,"VARIABLE",mr_cabec,"cod_texto_2")
    CALL _ADVPL_set_property(m_texto_2,"LENGTH",3,0)
    CALL _ADVPL_set_property(m_texto_2,"VALID","pol1334_ck_texto2")

    LET m_lupa_tx2 = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_tx2,"POSITION",820,10)     
    CALL _ADVPL_set_property(m_lupa_tx2,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_tx2,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_tx2,"CLICK_EVENT","pol1334_zoom_txt_2")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",850,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Texto3:")    

    LET m_texto_3 = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_texto_3,"POSITION",900,10)     
    CALL _ADVPL_set_property(m_texto_3,"VARIABLE",mr_cabec,"cod_texto_3")
    CALL _ADVPL_set_property(m_texto_3,"LENGTH",3,0)
    CALL _ADVPL_set_property(m_texto_3,"VALID","pol1334_ck_texto3")

    LET m_lupa_tx3 = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_tx3,"POSITION",940,10)     
    CALL _ADVPL_set_property(m_lupa_tx3,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_tx3,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_tx3,"CLICK_EVENT","pol1334_zoom_txt_3")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",980,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Placa:")    

    LET m_placa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_placa,"POSITION",1025,10)     
    CALL _ADVPL_set_property(m_placa,"VARIABLE",mr_cabec,"num_placa")
    CALL _ADVPL_set_property(m_placa,"LENGTH",7,0)
    CALL _ADVPL_set_property(m_placa,"PICTURE","@!")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1110,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Estado:")    

    LET m_estado = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_estado,"POSITION",1160,10)     
    CALL _ADVPL_set_property(m_estado,"VARIABLE",mr_cabec,"cod_estado")
    CALL _ADVPL_set_property(m_estado,"LENGTH",2,0)
    CALL _ADVPL_set_property(m_estado,"PICTURE","@!")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1200,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Via:")    

    LET m_via = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_via,"POSITION",1230,10)     
    CALL _ADVPL_set_property(m_via,"VARIABLE",mr_cabec,"cod_via")
    CALL _ADVPL_set_property(m_via,"LENGTH",2,0)
    CALL _ADVPL_set_property(m_via,"VALID","pol1334_ck_via")

    LET m_lupa_via = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_via,"POSITION",1260,10)     
    CALL _ADVPL_set_property(m_lupa_via,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_via,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_via,"CLICK_EVENT","pol1334_zoom_via")

END FUNCTION

#------------------------------#
FUNCTION pol1334_zoom_cliente()#
#------------------------------#

    DEFINE l_codigo       LIKE clientes.cod_cliente,
           l_descri       LIKE clientes.nom_cliente
    
    IF  m_zcliente IS NULL THEN
        LET m_zcliente = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zcliente,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_zcliente,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zcliente,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_descri = _ADVPL_get_property(m_zcliente,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")

    IF l_codigo IS NOT NULL THEN
       LET mr_cabec.cod_cliente = l_codigo
    END IF
    
    CALL _ADVPL_set_property(m_cliente,"GET_FOCUS")

END FUNCTION

#---------------------------#
FUNCTION pol1334_ck_solicit()#
#---------------------------#
   
   DEFINE l_cod_cliente   CHAR(15)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_cabec.num_solicit IS NULL OR
        mr_cabec.num_solicit <= 0 THEN
      LET m_msg = 'Informe o número da solicitação.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_solicit,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   SELECT DISTINCT(trans_solic_fatura)
     INTO p_num_transac
     FROM fat_solic_mestre
    WHERE empresa = p_cod_empresa
      AND solicitacao_fatura = mr_cabec.num_solicit

   IF STATUS = 100 THEN      
      LET m_msg = 'Solicitação inexistente ou já faturada.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','fat_solic_mestre:1')
         CALL _ADVPL_set_property(m_solicit,"EDITABLE",FALSE)
         RETURN FALSE
      END IF
   END IF   

   SELECT DISTINCT a.cod_cliente
     INTO l_cod_cliente
     FROM pedidos a,
          ordem_montag_item b,
          fat_solic_fatura c
    WHERE c.trans_solic_fatura = p_num_transac
      AND a.cod_empresa = p_cod_empresa
      AND a.cod_empresa = b.cod_empresa
      AND a.num_pedido = b.num_pedido
      AND c.ord_montag = b.num_om

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','fat_solic_mestre:2')
      RETURN FALSE
   END IF

   SELECT 1
     FROM cliente_agrupa_970
    WHERE cod_cliente = l_cod_cliente
   
   IF STATUS = 100 THEN
   ELSE
      IF STATUS = 0 THEN
         LET m_msg = 'O Cliente ',l_cod_cliente CLIPPED,' não permite agrupamento.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      ELSE
         CALL log003_err_sql('SELECT','cliente_agrupa_970')
         CALL _ADVPL_set_property(m_solicit,"EDITABLE",FALSE)
         RETURN FALSE 
      END IF
   END IF   
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1334_zoom_txt_1()#
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
       LET mr_cabec.cod_texto_1 = l_codigo
    END IF
    
    CALL _ADVPL_set_property(m_texto_1,"GET_FOCUS")

END FUNCTION

#---------------------------#
FUNCTION pol1334_ck_texto1()#
#---------------------------#

   IF NOT pol1334_le_texto(mr_cabec.cod_texto_1) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1334_ck_texto2()#
#---------------------------#

   IF NOT pol1334_le_texto(mr_cabec.cod_texto_2) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1334_ck_texto3()#
#---------------------------#

   IF NOT pol1334_le_texto(mr_cabec.cod_texto_3) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1334_le_texto(l_cod)#
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
FUNCTION pol1334_zoom_txt_2()#
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
       LET mr_cabec.cod_texto_2 = l_codigo
    END IF
    
    CALL _ADVPL_set_property(m_texto_2,"GET_FOCUS")

END FUNCTION


#----------------------------#
FUNCTION pol1334_zoom_txt_3()#
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
       LET mr_cabec.cod_texto_3 = l_codigo
    END IF
    
    CALL _ADVPL_set_property(m_texto_3,"GET_FOCUS")

END FUNCTION

#--------------------------#
FUNCTION pol1334_zoom_via()#
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
       LET mr_cabec.cod_via = l_codigo
    END IF
    
    CALL _ADVPL_set_property(m_via,"GET_FOCUS")

END FUNCTION

#------------------------#
FUNCTION pol1334_ck_via()#
#------------------------#

   IF mr_cabec.cod_via IS NOT NULL THEN
      SELECT den_via_transporte
        FROM via_transporte
       WHERE cod_via_transporte = mr_cabec.cod_via
      IF STATUS <> 0 THEN
         CALL log0030_processa_err_sql("SELECT","via_transporte",0)
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------------#
FUNCTION pol1334_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT   
   
   CALL _ADVPL_set_property(m_cliente,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_lcliente,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_pedido,"EDITABLE",l_status)      
   #CALL _ADVPL_set_property(m_lpedido,"EDITABLE",l_status)      
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1334_set_solicit(l_status)#
#-------------------------------------#

   DEFINE l_status SMALLINT   

   CALL _ADVPL_set_property(m_solicit,"EDITABLE",FALSE)      
   CALL _ADVPL_set_property(m_texto_1,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_texto_2,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_texto_3,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_lupa_tx1,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_lupa_tx2,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_lupa_tx3,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_placa,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_estado,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_via,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_lupa_via,"EDITABLE",l_status)      
   CALL _ADVPL_set_property(m_browse,"EDITABLE",l_status)
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1334_ordens(l_container)#
#-----------------------------------#

    DEFINE l_container           VARCHAR(10),
           l_panel               VARCHAR(10),
           l_layout              VARCHAR(10),
           l_tabcolumn           VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
    #CALL _ADVPL_set_property(l_panel,"WIDTH",280)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_browse,"BEFORE_ROW_EVENT","pol1334_om_before_linha")
    CALL _ADVPL_set_property(m_browse,"AFTER_ROW_EVENT","pol1334_om_after_linha")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CONFIRM_EX")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sel")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_faturar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER_CLICK_EVENT","pol1334_marca_desmarca")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_cliente")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ord Montag")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_om")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Emissão")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_emis")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Volumes")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_volume_om")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Transportador")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_transpor")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Raz social")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_transpor")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_ordem,1)
    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#---------------------------------#
FUNCTION pol1334_om_before_linha()#
#---------------------------------#
   
   DEFINE l_lin_atu       SMALLINT,
          l_tot_apo       DECIMAL(10,3)
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1334_om_after_linha()#
#--------------------------------#
   
   DEFINE l_lin_atu       SMALLINT,
          l_tot_apo       DECIMAL(10,3)
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   LET m_num_om = ma_ordem[l_lin_atu].num_om
   CALL pol1334_le_om_itens()
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1334_itnes(l_container)#
#----------------------------------#

    DEFINE l_container           VARCHAR(10),
           l_panel               VARCHAR(10),
           l_layout              VARCHAR(10),
           l_tabcolumn           VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(l_panel,"WIDTH",300)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    
    LET m_brz_item = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_item,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","O.M.")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_om")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Seq")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_sequencia")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Produto")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    #CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    #CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item_reduz")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Quant")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_reservada")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Emb")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_embal_int")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Volume")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    #CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_volume_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_item,"SET_ROWS",ma_item,1)
    CALL _ADVPL_set_property(m_brz_item,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_item,"EDITABLE",FALSE)

END FUNCTION

#----------------------#
FUNCTION pol1334_find()#
#----------------------#
   
   LET m_ies_cons = FALSE
   
   CALL pol1334_ativa_desativa(TRUE)
   CALL pol1334_limpa_campos()
   CALL _ADVPL_set_property(m_cliente,"GET_FOCUS")
      
   RETURN TRUE 
    
END FUNCTION

#-----------------------------#
FUNCTION pol1334_find_cancel()#
#-----------------------------#

    CALL pol1334_limpa_campos()
    CALL pol1334_ativa_desativa(FALSE)
    LET m_ies_cons = FALSE
    
    RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1334_find_conf()#
#---------------------------#
   
   
   CALL LOG_progresspopup_start("Lendo ordens...","pol1334_monta_tela","PROCESS") 
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   LET m_ies_cons = TRUE
   LET m_ies_sel = FALSE
   CALL pol1334_ativa_desativa(FALSE)
   
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1334_monta_tela()#
#----------------------------#     
   
   LET p_status = pol1334_carrega_ordens()
   
END FUNCTION

#---------------------------------#
FUNCTION pol1334_carrega_ordens()#
#---------------------------------#
   
   DEFINE l_progres       SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",10)
      
   CALL pol1334_monta_select()
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   INITIALIZE ma_ordem TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")

   PREPARE var_ordens FROM m_query
    
   IF  STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE","var_ordens")
       RETURN FALSE
   END IF

   DECLARE cq_ordens CURSOR FOR var_ordens

   IF  STATUS <> 0 THEN
       CALL log003_err_sql("DECLARE","cq_ordens")
       RETURN FALSE
   END IF
   
   LET m_ind = 1
   
   FOREACH cq_ordens INTO
           ma_ordem[m_ind].cod_cliente,
           ma_ordem[m_ind].num_om,
           ma_ordem[m_ind].dat_emis,
           ma_ordem[m_ind].qtd_volume_om,
           ma_ordem[m_ind].cod_transpor

      IF STATUS <> 0 THEN
         CALL log003_err_sql("FOREACH","cq_ordens")
         RETURN FALSE
      END IF
      
      LET ma_ordem[m_ind].ies_faturar = 'N'
           
      LET ma_ordem[m_ind].nom_cliente = pol1334_le_nom_cli(ma_ordem[m_ind].cod_cliente)
      LET ma_ordem[m_ind].nom_transpor = pol1334_le_nom_cli(ma_ordem[m_ind].cod_transpor)
                 
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      LET m_ind = m_ind + 1
   
      IF m_ind > 1000 THEN
         LET m_msg = 'Número de ordens lidas ultrapassou a\n',
                     'quantidade de linhas previstas na grade.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF m_ind > 1 THEN
      LET m_qtd_om = m_ind - 1
      CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_om)
      LET m_num_om = ma_ordem[1].num_om
      CALL pol1334_le_om_itens()
   ELSE
      LET m_msg = 'Não há ordens de montagem para\n os parâmetros informados. '
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1334_checa_cli()#
#---------------------------#
   
   DEFINE l_cod_cliente CHAR(15)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_cabec.cod_cliente IS NULL OR mr_cabec.cod_cliente = ' ' THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Informe o cliente')
      RETURN FALSE
   END IF

   LET m_query =      
   " SELECT cod_cliente FROM clientes ",
   " WHERE cod_cliente LIKE '",mr_cabec.cod_cliente CLIPPED,"%","' ",
   " ORDER BY cod_cliente "
   
   PREPARE var_cli FROM m_query
    
   IF  STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE","var_cli")
       RETURN FALSE
   END IF

   DECLARE cq_cli SCROLL CURSOR WITH HOLD FOR var_cli

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE CURSOR","cq_cli")
       RETURN FALSE
   END IF

   FREE var_cli

   OPEN cq_cli

   IF  STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_cli")
       RETURN FALSE
   END IF
   
   FETCH cq_cli INTO l_cod_cliente

   IF STATUS <> 0 THEN
      IF STATUS <> 100 THEN
         CALL log003_err_sql("FETCH CURSOR","cq_cons")
      ELSE
         LET m_msg = 'Não há cliente com o prefixo informado'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
       RETURN FALSE
   END IF
     
   LET mr_cabec.cod_cliente = l_cod_cliente  
   
   RETURN TRUE

END FUNCTION
   
      
#------------------------------#
FUNCTION pol1334_monta_select()#
#------------------------------#

   LET m_query = 
       "SELECT DISTINCT c.cod_cliente, a.num_om, a.dat_emis, a.qtd_volume_om, a.cod_transpor ",
       " FROM ordem_montag_mest a, ordem_montag_item b, pedidos c ",
       " WHERE a.cod_empresa = '",p_cod_empresa,"' ",
       "  AND a.num_nff IS NULL ",
       "  AND b.cod_empresa = a.cod_empresa ",
       "  AND b.num_om = a.num_om ",
       "  AND c.cod_empresa = b.cod_empresa ",
       "  AND c.num_pedido = b.num_pedido ",
       "  AND c.cod_cliente = '",mr_cabec.cod_cliente CLIPPED,"' "

   IF mr_cabec.num_pedido IS NOT NULL THEN
      LET m_query = m_query CLIPPED, " AND c.num_pedido = ",mr_cabec.num_pedido
   END IF
   
   LET m_query = m_query CLIPPED, " ORDER BY c.cod_cliente, a.num_om "
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1334_le_nom_cli(l_Cod)#
#---------------------------------#

   DEFINE l_cod           LIKE clientes.cod_cliente,
          l_nom           LIKE clientes.nom_cliente
          
   
   SELECT nom_cliente
     INTO l_nom
     FROM clientes
    WHERE cod_cliente = l_cod

   IF STATUS <> 0 THEN
      #CALL log003_err_sql('SELECT','clientes')
      LET l_nom = NULL
   END IF             

   RETURN l_nom

END FUNCTION

#-----------------------------#
FUNCTION pol1334_le_om_itens()#
#-----------------------------#

   INITIALIZE ma_item TO NULL
   CALL _ADVPL_set_property(m_brz_item,"CLEAR")
   LET m_ind = 1
   
   DECLARE cq_om_item CURSOR FOR
    SELECT num_pedido,
           num_sequencia,
           cod_item,
           qtd_reservada,
           qtd_volume_item
      FROM ordem_montag_item
     WHERE cod_empresa = p_cod_empresa
       AND num_om = m_num_om
   
   FOREACH cq_om_item INTO
      ma_item[m_ind].num_pedido,      
      ma_item[m_ind].num_sequencia,   
      ma_item[m_ind].cod_item,        
      ma_item[m_ind].qtd_reservada,   
      ma_item[m_ind].qtd_volume_item  
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_om_item')
         EXIT FOREACH
      END IF             
      
      LET ma_item[m_ind].num_om = m_num_om
      LET ma_item[m_ind].den_item_reduz = pol1334_le_den_item(ma_item[m_ind].cod_item)
      
      SELECT cod_embal_int
        INTO ma_item[m_ind].cod_embal_int
        FROM ordem_montag_embal
       WHERE cod_empresa = p_cod_empresa
         AND num_om = m_num_om
         AND cod_item = ma_item[m_ind].cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECAO_MANUAL','ordem_montag_embal:loi')
         EXIT FOREACH
      END IF             
      
      LET m_ind = m_ind + 1
   
      IF m_ind > 1000 THEN
         LET m_msg = 'Número de itens ultrapassou a quantidade\n',
                     'de linhas previstas na grade de itens'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF

   END FOREACH
   
   IF m_ind > 1 THEN
      LET m_ind = m_ind - 1
      CALL _ADVPL_set_property(m_brz_item,"ITEM_COUNT", m_ind)
   ELSE
      LET m_msg = 'Não há itens na ordem de montagem ', m_num_om
      CALL log0030_mensagem(m_msg,'info')
   END IF

END FUNCTION

#----------------------------------#
FUNCTION pol1334_le_den_item(l_cod)#
#----------------------------------#

   DEFINE l_cod          LIKE item.cod_item,
          l_den          LIKE item.den_item_reduz

   SELECT den_item_reduz
     INTO l_den
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      LET l_den = NULL
   END IF
   
   RETURN l_den

END FUNCTION

#---------------------------#
FUNCTION pol1334_selec_oms()#
#---------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Execute a pesquisa previamente'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1334_cria_temp() THEN
      RETURN FALSE
   END IF
      
   SELECT MAX(num_solicit)
     INTO mr_cabec.num_solicit
     FROM num_solicit_970
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      IF STATUS = -206 THEN
         CREATE TABLE num_solicit_970(
           cod_empresa CHAR(02),
           num_solicit      INTEGER
         )
         CREATE UNIQUE INDEX ix_num_solicit_970 ON num_solicit_970(cod_empresa);
      ELSE     
         CALL log003_err_sql('SELECT','num_solicit_970')
         RETURN FALSE
      END IF
   END IF
   
   IF mr_cabec.num_solicit IS NULL THEN
      LET mr_cabec.num_solicit = 1
   ELSE
      LET mr_cabec.num_solicit = mr_cabec.num_solicit + 1
   END IF
   
   CALL pol1334_set_solicit(TRUE)
   CALL _ADVPL_set_property(m_texto_1,"GET_FOCUS")
   
   LET m_clik_cab = TRUE
   LET m_clik_sel = TRUE
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#  
FUNCTION pol1334_cria_temp()#
#---------------------------#
 
   DROP TABLE om_select_912 ;
   CREATE TEMP TABLE om_select_912 (
       cod_cliente        CHAR(15),
       num_om             INTEGER,
       cod_transpor       CHAR(15)
   );

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-om_select_912")
      RETURN FALSE
   END IF
   
   CREATE INDEX ix_om_select_912
    ON om_select_912(cod_cliente);

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CRIACAO","INDEX-ix_om_select_912")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION  

#--------------------------#
FUNCTION pol1334_no_selec()#
#--------------------------#      
   
   DEFINE l_ind  INTEGER
   
   FOR l_ind = 1 TO m_qtd_om
       LET ma_ordem[l_ind].ies_faturar = 'N'
   END FOR
   
   DELETE FROM om_select_912
   
   LET m_num_om = ma_ordem[1].num_om
   CALL pol1334_le_om_itens()
   LET m_ies_sel = FALSE
   
   CALL pol1334_set_solicit(FALSE)
   
   LET m_clik_sel = FALSE
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1334_yes_selec()#
#---------------------------#

   DEFINE l_ind  INTEGER
   
   DELETE FROM om_select_912

   FOR l_ind = 1 TO m_qtd_om
       IF ma_ordem[l_ind].ies_faturar = 'S' THEN
          INSERT INTO om_select_912
           VALUES(ma_ordem[l_ind].cod_cliente,
                  ma_ordem[l_ind].num_om,
                  ma_ordem[l_ind].cod_transpor)
          IF STATUS <> 0 THEN
             CALL log003_err_sql('INSERT','om_select_912')
             RETURN FALSE
          END IF  
       END IF
   END FOR


   SELECT COUNT(DISTINCT cod_transpor)
     INTO m_count
     FROM om_select_912

   
   IF m_count = 0 THEN
      LET m_msg = 'Selecione pelo menos uma OM a faturar.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   IF m_count > 1 THEN
      LET m_msg = 'Selecione somente OMs com o mesmo Transportador.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   LET m_ies_sel = TRUE
   LET m_clik_sel = FALSE
      
   CALL pol1334_set_solicit(FALSE)
   
   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1334_gerar()#
#-----------------------#
   
   DEFINE l_dat_refer   DATE
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT m_ies_sel THEN
      LET m_msg = 'Selecione as OMs previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET l_dat_refer = TODAY
   
   SELECT COUNT(*)
     INTO m_count
     FROM fat_solic_mestre
    WHERE empresa = p_cod_empresa
      AND tip_docum = 'SOLPRDSV'
      AND dat_refer < l_dat_refer
   
   IF STATUS <> 0 THEN
      CALL log0030_processa_err_sql('SELECT','fat_solic_mestre',0)
      RETURN FALSE
   END IF
   
   IF m_count > 0 THEN
      LET m_msg = 'Existem solicitações não faturadas\n',
                  'com datas anteriores a atual.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF  

   LET m_msg = 'Deseja mesmo gerar a solicitação de faturamento\n',
               'para a(s) OM(s) selecionada(s) ?'

   IF NOT LOG_question(m_msg) THEN
      CALL pol1334_no_selec()
      RETURN FALSE
   END IF
   
   LET p_status = TRUE
   
   CALL LOG_progresspopup_start("Gerando solicitação...","pol1334_processa","PROCESS") 
   
   IF NOT p_status THEN
      LET m_msg = 'Operação cancelada.'
   ELSE
      LET m_msg = 'Solicitação de faturamento\n ',
                  'gerada com sucesso.'
   END IF
   
   CALL log0030_mensagem(m_msg,'info')
   
   LET m_ies_sel = FALSE
   LET m_ies_cons = FALSE
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1334_processa()#
#--------------------------#     

   SELECT COUNT(num_om)
     INTO m_count
     FROM om_select_912

   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   CALL LOG_transaction_begin()

   IF NOT pol1334_gera_solicit() THEN
      CALL LOG_transaction_rollback()
      LET p_status = FALSE
   ELSE
      CALL LOG_transaction_commit()
      LET p_status = TRUE
   END IF
   
END FUNCTION

#------------------------------#
FUNCTION pol1334_gera_solicit()#                  
#------------------------------#

   DEFINE l_progres    SMALLINT

   SELECT UNIQUE 
    tip_solicitacao,
		serie_docum,  
    subserie_docum,
    especie_docum,  
    tip_docum
   INTO m_tip_solic,
        m_nser,
        m_sser,
        m_espcie,
        m_tip_docum
    FROM vdp_num_docum 
   WHERE empresa = p_cod_empresa
     AND tip_solicitacao = 'SOLPRDSV'
	   AND serie_docum = '1'  
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','vdp_num_docum')
      RETURN FALSE
   END IF
   
   IF NOT pol1334_insere_mestre() THEN
      RETURN FALSE
   END IF
   
   LET m_sequencia = 0
   LET m_controle  = 0
   
   DECLARE cq_temp CURSOR FOR
    SELECT cod_cliente, 
           num_om,      
           cod_transpor
      FROM om_select_912
     ORDER BY cod_cliente, num_om
   
   FOREACH cq_temp INTO
      m_cod_cliente,
      m_num_om,
      m_cod_transpor
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_temp')
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")      

      IF NOT pol1334_insere_fatura() THEN
         RETURN FALSE
      END IF
                       
   END FOREACH
   
   IF NOT pol1334_isere_embalagem() THEN
      RETURN FALSE
   END IF
   
   UPDATE num_solicit_970
      SET num_solicit = mr_cabec.num_solicit
    WHERE cod_empresa = p_cod_empresa
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1334_insere_mestre()#
#-------------------------------#

    DEFINE lr_fat_solic_mestre      RECORD LIKE fat_solic_mestre.*
   
		LET lr_fat_solic_mestre.trans_solic_fatura 	= 0
		LET lr_fat_solic_mestre.empresa = p_cod_empresa
		LET lr_fat_solic_mestre.tip_docum	= m_tip_solic
		LET lr_fat_solic_mestre.serie_fatura = m_nser
		LET lr_fat_solic_mestre.subserie_fatura	= m_sser
		LET lr_fat_solic_mestre.especie_fatura = m_espcie
		LET lr_fat_solic_mestre.solicitacao_fatura = mr_cabec.num_solicit
		LET lr_fat_solic_mestre.usuario	= p_user
		LET lr_fat_solic_mestre.inscricao_estadual = NULL
		LET lr_fat_solic_mestre.dat_refer	= TODAY
		LET lr_fat_solic_mestre.tip_solicitacao	= 'L'
		LET lr_fat_solic_mestre.lote_geral = 'N' 
		LET lr_fat_solic_mestre.tip_carteira = NULL
		LET lr_fat_solic_mestre.sit_solic_fatura = 'C'
		
		INSERT INTO fat_solic_mestre (		
		        empresa,                                           
						tip_docum,                               					
						serie_fatura,                            					
						subserie_fatura,                         					
						especie_fatura,                          					
						solicitacao_fatura,                      					
						usuario,                                 					
						inscricao_estadual,                      					
						dat_refer,                               					
						tip_solicitacao,                         					
						lote_geral,                              					
						tip_carteira,                            					
						sit_solic_fatura)                        					
				VALUES (lr_fat_solic_mestre.empresa,         					
						lr_fat_solic_mestre.tip_docum,           					
						lr_fat_solic_mestre.serie_fatura,        					
						lr_fat_solic_mestre.subserie_fatura,     					
						lr_fat_solic_mestre.especie_fatura,      					
						lr_fat_solic_mestre.solicitacao_fatura,  					
						lr_fat_solic_mestre.usuario,             					
						lr_fat_solic_mestre.inscricao_estadual,  					
						lr_fat_solic_mestre.dat_refer,           					
						lr_fat_solic_mestre.tip_solicitacao,     					
						lr_fat_solic_mestre.lote_geral,          					
						lr_fat_solic_mestre.tip_carteira,        					
						lr_fat_solic_mestre.sit_solic_fatura)    					

	 IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','fat_solic_mestre')
      RETURN FALSE
	 END IF
											
   LET m_num_transac = SQLCA.SQLERRD[2]
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1334_insere_fatura()#
#-------------------------------#

   DEFINE l_cod_pais         LIKE uni_feder.cod_pais,
          l_mercado          LIKE fat_solic_fatura.mercado,         
          l_modo_embarque    LIKE fat_solic_fatura.modo_embarque,   
          l_local_embarque   LIKE fat_solic_fatura.local_embarque,  
          l_cidade_embarque  LIKE fat_solic_fatura.cidade_embarque, 
          l_dat_hor_embarque LIKE fat_solic_fatura.dat_hor_embarque,
          l_volume           LIKE fat_solic_fatura.primeiro_volume,
          l_volume_cubico    LIKE fat_solic_fatura.volume_cubico,
          l_peso_om_item     LIKE fat_solic_fatura.peso_liquido,
          l_local_despacho   INTEGER,
          l_cod_uni_feder    CHAR(02),
          l_num_pedido       INTEGER,
          l_lote_om          INTEGER,
          l_val_frete        DECIMAL(12,2),
          l_val_seguro       DECIMAL(12,2)
          
   LET l_mercado = ' '
   LET l_modo_embarque = ' '
   LET l_local_embarque =  ' '
   LET l_cidade_embarque = ' '
   LET l_dat_hor_embarque = ' '
   
   SELECT a.cod_uni_feder
     INTO l_cod_uni_feder
     FROM cidades a,
          clientes b
    WHERE b.cod_cliente = m_cod_cliente
      AND b.cod_cidade  = a.cod_cidade
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','cidades/clientes')
      RETURN FALSE
   END IF
      
   SELECT cod_pais
     INTO l_cod_pais
     FROM uni_feder
    WHERE cod_uni_feder = l_cod_uni_feder
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','uni_feder')
      LET l_cod_pais = '001'
   END IF

   LET m_num_pedido = NULL

   IF l_cod_pais <> '001' THEN
      
      DECLARE cq_pedido CURSOR FOR
       SELECT DISTINCT num_pedido
         FROM ordem_montag_item
        WHERE cod_empresa = p_cod_empresa
          AND num_om = m_num_om
      FOREACH cq_pedido INTO l_num_pedido
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_pedido')
            RETURN FALSE
         END IF
         
         LET m_num_pedido = l_num_pedido
         
         EXIT FOREACH
      END FOREACH
   
   END IF
       
   IF l_cod_pais <> '001' AND m_num_pedido IS NOT NULL THEN
      
      SELECT parametro_texto
        INTO L_cidade_embarque
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = M_num_pedido                                  
         AND ped_info_compl.campo   = 'CIDADE_EMBARQUE'                     

      SELECT parametro_dat
        INTO l_dat_hor_embarque
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = m_num_pedido                                  
         AND ped_info_compl.campo   = 'DAT_HOR_EMBARQUE'                     

      SELECT parametro_texto
        INTO l_local_embarque
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = m_num_pedido                                  
         AND ped_info_compl.campo   = 'LOCAL_EMBARQUE'                     

      SELECT parametro_texto
        INTO l_mercado
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = m_num_pedido                                  
         AND ped_info_compl.campo   = 'MERCADO'                     


      SELECT parametro_texto
        INTO l_modo_embarque
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = m_num_pedido                                  
         AND ped_info_compl.campo   = 'MODO_EMBARQUE'                     

      SELECT parametro_val
        INTO l_local_despacho
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = m_num_pedido                                  
         AND ped_info_compl.campo   = 'LOCAL_DESPACHO'                     

   END IF

   SELECT num_lote_om,
          qtd_volume_om
     INTO l_lote_om,
          l_volume
     FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om = m_num_om

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordem_montag_mest:lote')
      RETURN FALSE
   END IF
   
   SELECT SUM(pes_total_item)
     INTO l_peso_om_item
     FROM ordem_montag_item
    WHERE cod_empresa = p_cod_empresa
      AND num_om = m_num_om     

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordem_montag_item:peso')
      RETURN FALSE
   END IF
   
   IF l_peso_om_item IS NULL THEN
      LET l_peso_om_item = 0
   END IF
   
   LET m_sequencia = m_sequencia + 1
   LET m_controle = m_controle + 1
   LET l_val_frete = 0
   LET l_val_seguro = 0
   LET l_volume_cubico = 0
   
   INSERT INTO fat_solic_fatura (
      trans_solic_fatura,
      ord_montag,        
      lote_ord_montag,   
      seq_solic_fatura,  
      controle,          
      texto_1,           
      texto_2,           
      texto_3,           
      via_transporte,    
      transportadora,    
      placa_veiculo,     
      estado_placa_veic, 
      val_frete,         
      val_seguro,        
      peso_liquido,      
      peso_bruto,        
      primeiro_volume,   
      volume_cubico,     
      mercado,           
      local_embarque,    
      modo_embarque,
      dat_hor_embarque,
      cidade_embarque,
      local_despacho)
    VALUES(m_num_transac,
           m_num_om,
           l_lote_om,
           m_sequencia,
           m_controle,
           mr_cabec.cod_texto_1,
           mr_cabec.cod_texto_2,
           mr_cabec.cod_texto_3,
           mr_cabec.cod_via,
           m_cod_transpor,
           mr_cabec.num_placa,
           mr_cabec.cod_estado,                    
           l_val_frete,
           l_val_seguro,           
           l_peso_om_item,
           l_peso_om_item,           
           l_volume,                              
           l_volume_cubico,           
           l_mercado,           
           l_local_embarque,
           l_modo_embarque,
           l_dat_hor_embarque,
           l_cidade_embarque,
           l_local_despacho)   
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql("INCLUSAO", "fat_solic_fatura")
      RETURN FALSE
   END IF

   SELECT empresa
     FROM fat_exp_nf
    WHERE empresa = p_cod_empresa
      AND trans_nota_fiscal = m_num_transac
   
   IF STATUS = 0 THEN
      DELETE FROM fat_exp_nf
       WHERE empresa = p_cod_empresa
         AND trans_nota_fiscal = m_num_transac
   END IF
   
   INSERT INTO fat_exp_nf (
    empresa,
    trans_nota_fiscal, 
    modo_embarq,     
    local_embarq,    
    dat_hor_embarq,
    mercado,     
    cidade_embarque,
    local_despacho)
   VALUES (p_cod_empresa,
           m_num_transac,
           l_modo_embarque,    
           l_local_embarque,   
           l_dat_hor_embarque, 
           l_mercado,         
           l_cidade_embarque,
           l_local_despacho)  
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql("INCLUSAO", "fat_exp_nf")
      RETURN FALSE
   END IF
         
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1334_isere_embalagem()#
#---------------------------------#
   
   DEFINE l_num_om        LIKE fat_solic_fatura.ord_montag,
          l_num_lote      LIKE fat_solic_fatura.lote_ord_montag,
          l_cod_embal     LIKE fat_solic_embal.embalagem,
          l_qtd_embal     LIKE fat_solic_embal.qtd_embalagem 
          
   DECLARE cq_fat CURSOR FOR
    SELECT ord_montag,
           lote_ord_montag
      FROM fat_solic_fatura
     WHERE trans_solic_fatura = m_num_transac
   
   FOREACH cq_fat INTO l_num_om, l_num_lote   
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','fat_solic_fatura:cq_fat')
         RETURN FALSE
      END IF
      
      DECLARE cq_embal CURSOR FOR
       SELECT cod_embal_int,
              qtd_embal_int
         FROM ordem_montag_embal
        WHERE cod_empresa = p_cod_empresa
          AND num_om = l_num_om
      
      FOREACH cq_embal INTO l_cod_embal, l_qtd_embal

         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','ordem_montag_embal:cq_embal')
            RETURN FALSE
         END IF
         
         INSERT INTO fat_solic_embal(
            trans_solic_fatura,
            ord_montag,			  
            lote_ord_montag,		
            embalagem,			    
            qtd_embalagem)
         VALUES(m_num_transac,
                l_num_om,
                l_num_lote,
                l_cod_embal,
                l_qtd_embal)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo','fat_solic_embal')
            RETURN FALSE
         END IF
      
      END FOREACH
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1334_marca_desmarca()#
#--------------------------------#
   
   DEFINE l_ind       INTEGER,
          l_sel       CHAR(01)
   
   IF NOT m_clik_sel THEN
      RETURN FALSE
   END IF
   
   LET m_clik_cab = NOT m_clik_cab
   
   IF m_clik_cab THEN
      LET l_sel = 'S'
   ELSE
      LET l_sel = 'N'
   END IF
   
   FOR l_ind = 1 TO m_qtd_om
       CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","ies_faturar",l_ind,l_sel)
       LET ma_ordem[l_ind].ies_faturar = l_sel
   END FOR
   
   RETURN TRUE

END FUNCTION



#-----rotinas para agrupamento de pedido na mesma notra------#

#-------------------------#
FUNCTION pol1334_agrupar()#
#-------------------------#

   LET m_num_solicit = mr_cabec.num_solicit

   CALL _ADVPL_set_property(m_solicit,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_solicit,"GET_FOCUS")

END FUNCTION

#---------------------------#
FUNCTION pol1334_no_agrupa()#
#---------------------------#

   LET mr_cabec.num_solicit = m_num_solicit
   CALL _ADVPL_set_property(m_solicit,"EDITABLE",TRUE)

END FUNCTION

#----------------------------#
FUNCTION pol1334_yes_agrupa()#
#----------------------------#
   
   DEFINE l_titulo        VARCHAR(40),
          l_panel         VARCHAR(10),
          l_confirma      VARCHAR(10),
          l_cancela       VARCHAR(10),
          l_menubar       VARCHAR(10)
   
   
   LET l_titulo = 'AGRUPAMENTO DE PEDIDOS NA NF'
   
   
    LET m_from_agrupa = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_from_agrupa,"SIZE",800,480) #480
    CALL _ADVPL_set_property(m_from_agrupa,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_from_agrupa,"ENABLE_ESC_CLOSE",FALSE)
    #CALL _ADVPL_set_property(m_from_agrupa,"INIT_EVENT","pol1334_posiciona")
    
    LET m_stat_bar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_from_agrupa)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_from_agrupa)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)
    
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
    CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_confirma,"EVENT","pol1334_conf_agrup")  

    LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
    CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_cancela,"EVENT","pol1334_canc_agrup")     

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_from_agrupa)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1334_grade_solicit(l_panel)
    CALL pol1334_load_solicit()

    CALL _ADVPL_set_property(m_from_agrupa,"ACTIVATE",TRUE)
            
    
END FUNCTION


#--------------------------------------#
FUNCTION pol1334_grade_solicit(l_panel)#
#--------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brw_agrupa = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brw_agrupa,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(m_brw_agrupa,"AFTER_ROW_EVENT","pol1334_valid_agrup")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brw_agrupa)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Num OM")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_om")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brw_agrupa)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Num pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brw_agrupa)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cod cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brw_agrupa)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome cliemte")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brw_agrupa)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nat oper")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_nat_oper")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brw_agrupa)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Carteira")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_tip_carteira")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brw_agrupa)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Controle")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","controle")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ###")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1334_valid_ctrl")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brw_agrupa)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)

    CALL _ADVPL_set_property(m_brw_agrupa,"SET_ROWS",pr_pedido,1)

END FUNCTION

#----------------------------#
FUNCTION pol1334_valid_ctrl()#
#----------------------------#

   DEFINE l_lin_atu     SMALLINT,
          l_invalido    SMALLINT,
          l_ind         SMALLINT,
          l_controle    SMALLINT,
          l_juntou      SMALLINT

   CALL _ADVPL_set_property(m_stat_bar,"CLEAR_TEXT")

   LET l_lin_atu = _ADVPL_get_property(m_brw_agrupa,"ROW_SELECTED")

   IF pr_pedido[l_lin_atu].controle IS NULL OR
        pr_pedido[l_lin_atu].controle <= 0 THEN
      LET m_msg = 'Informe um controle maior que zero'
      CALL _ADVPL_set_property(m_stat_bar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF   

   LET l_invalido = FALSE

   FOR m_ind = 1 to m_qtd_itens
       IF m_ind <> l_lin_atu THEN
          IF pr_pedido[m_ind].controle = pr_pedido[l_lin_atu].controle THEN
             IF pr_pedido[m_ind].cod_cliente <> pr_pedido[l_lin_atu].cod_cliente THEN
                LET l_invalido = TRUE
             END IF
             IF pr_pedido[m_ind].cod_nat_oper <> pr_pedido[l_lin_atu].cod_nat_oper THEN
                LET l_invalido = TRUE
             END IF
             IF pr_pedido[m_ind].cod_tip_carteira <> pr_pedido[l_lin_atu].cod_tip_carteira THEN
                LET l_invalido = TRUE
             END IF
          END IF
       END IF
   END FOR
                  
   IF l_invalido THEN
      LET m_msg = 'Não é permitido jantar pedidos\n',
                  'com clientes, operações ou\n',
                  'carteiras diferentes'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1334_canc_agrup()#
#----------------------------#

   CALL _ADVPL_set_property(m_from_agrupa,"ACTIVATE",FALSE)
   LET mr_cabec.num_solicit = m_num_solicit
   CALL _ADVPL_set_property(m_solicit,"EDITABLE",FALSE)
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1334_conf_agrup()#
#----------------------------#

   CALL LOG_transaction_begin()

   IF NOT pol1334_save_agrup() THEN
      CALL LOG_transaction_rollback()
   ELSE
      CALL LOG_transaction_commit()
   END IF

   CALL _ADVPL_set_property(m_from_agrupa,"ACTIVATE",FALSE)
   LET mr_cabec.num_solicit = m_num_solicit
   CALL _ADVPL_set_property(m_solicit,"EDITABLE",FALSE)
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1334_save_agrup()#
#----------------------------#
   
   FOR m_ind = 1 to m_qtd_itens
       IF pr_pedido[m_ind].controle IS NOT NULL THEN

          UPDATE fat_solic_fatura 
             SET controle = pr_pedido[m_ind].controle
           WHERE trans_solic_fatura = p_num_transac
             AND ord_montag = pr_pedido[m_ind].num_om
         
          IF STATUS <> 0 THEN
             CALL log003_err_sql('UPDATE','fat_solic_fatura:AC')
             RETURN FALSE
          END IF
          
       END IF
   END FOR   

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1334_load_solicit()#
#------------------------------#

   DEFINE p_controle   INTEGER
   
   INITIALIZE pr_pedido TO NULL

   
   CALL _ADVPL_set_property(m_brw_agrupa,"CLEAR")
   CALL _ADVPL_set_property(m_brw_agrupa,"SET_ROWS",pr_pedido,1)
   
   LET p_index = 1
   
   DECLARE cq_pedido CURSOR FOR
   SELECT b.controle,
          c.num_om,
          c.num_pedido,
          d.cod_cliente,    
          d.cod_nat_oper,
          d.cod_tip_carteira          
     FROM fat_solic_mestre a, 
          fat_solic_fatura b,
          ordem_montag_item c,
          pedidos d
    WHERE a.empresa = p_cod_empresa
      AND c.cod_empresa = a.empresa
      AND a.solicitacao_fatura = mr_cabec.num_solicit
      AND b.trans_solic_fatura = a.trans_solic_fatura
      AND b.ord_montag = c.num_om
      AND d.cod_empresa = a.empresa
      AND d.num_pedido  = c.num_pedido
    ORDER BY d.cod_cliente, d.cod_nat_oper, d.cod_tip_carteira

   FOREACH cq_pedido INTO
           p_controle,
           p_num_om,
           p_num_pedido,
           p_cod_cliente,
           p_cod_nat_oper,
           p_cod_tip_carteira

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_pedido')
         RETURN 
      END IF
      
      SELECT nom_cliente
        INTO p_nom_cliente
        FROM clientes
       WHERE cod_cliente = p_cod_cliente

      IF STATUS <> 0 THEN
         LET p_nom_cliente = NULL
      END IF
            
      LET pr_pedido[p_index].num_om = p_num_om 
      LET pr_pedido[p_index].num_pedido = p_num_pedido
      LET pr_pedido[p_index].cod_cliente = p_cod_cliente
      LET pr_pedido[p_index].nom_cliente = p_nom_cliente
      LET pr_pedido[p_index].controle = p_controle
      LET pr_pedido[p_index].cod_nat_oper = p_cod_nat_oper
      LET pr_pedido[p_index].cod_tip_carteira = p_cod_tip_carteira
      
      LET p_index = p_index + 1
      
      IF p_index > 300 THEN
         LET m_msg = 'Limite de linhas da\n',
                     'grade superou a pre-\n',
                     'visão de 300 linhas.' 
         CALL log0030_mensagem(m_msg, 'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
      
   LET m_qtd_itens = p_index - 1

   CALL _ADVPL_set_property(m_brw_agrupa,"SET_ROWS",pr_pedido,m_qtd_itens)
   CALL _ADVPL_set_property(m_brw_agrupa,"CAN_REMOVE_ROW",FALSE)
   CALL _ADVPL_set_property(m_brw_agrupa,"CAN_ADD_ROW",FALSE)

   CALL _ADVPL_set_property(m_brw_agrupa,"EDITABLE",TRUE)  
   CALL _ADVPL_set_property(m_brw_agrupa,"GET_FOCUS")    
   CALL _ADVPL_set_property(m_brw_agrupa,"SELECT_ITEM",1,7)
   
END FUNCTION

   

  