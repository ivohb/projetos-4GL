#-----------------------------------------------------------------#
# MODULO..: GEO                                                   #
# SISTEMA.: CADASTRO DE DESCONTOS                                 #
# PROGRAMA: geo1027                                               #
# AUTOR...: EVANDRO SIMENES                                       #
# DATA....: 06/04/2016                                            #
#-----------------------------------------------------------------#

DATABASE logix

GLOBALS

	DEFINE p_versao            CHAR(18)
	DEFINE p_cod_empresa       LIKE empresa.cod_empresa
	DEFINE p_user              LIKE usuarios.cod_usuario


END GLOBALS

define m_refer_tabela_funil varchar(50)
DEFINE m_refer_item_de varchar(50)
DEFINE m_refer_item_para varchar(50)

DEFINE mr_copia RECORD
	item_de char(15),
	item_para char(15)
END record


define m_form_funil varchar(50)
DEFINE m_form_desconto varchar(50)
DEFINE m_refer_desconto varchar(50)
DEFINE m_refer_pct_desc_adic varchar(50)
DEFINE m_refer_dat_final_desc varchar(50)

DEFINE m_refer_tabela1 varchar(50)
DEFINE m_refer_tabela2 varchar(50)

DEFINE mr_desconto RECORD
	pct_desc          DECIMAL(4,2),
	pct_desc_adic     DECIMAL(4,2),
	dat_final_desc    DATE
END RECORD

define ma_funil_repres   array[9999] of record
	cod_repres like representante.cod_repres
end record
									  
define ma_funil_cliente   array[9999] of record
	cod_cliente char(15)
end record

define ma_funil_item   array[9999] of record
	cod_item char(15)
end record
						

define ma_funil_cidade   array[9999] of record
	cod_cidade char(5)
end record
DEFINE ma_resp           ARRAY[9999] OF RECORD
	cod_cliente            LIKE clientes.cod_cliente
, nom_cliente            LIKE clientes.nom_cliente
END RECORD
DEFINE ma_resp3           ARRAY[9999] OF RECORD
	cod_repres            LIKE representante.cod_repres
, nom_repres            LIKE representante.raz_social
, raz_social            LIKE representante.raz_social
END RECORD
DEFINE ma_resp2           ARRAY[9999] OF RECORD
	cod_item            LIKE item.cod_item
, den_item            LIKE item.den_item
, den_item_reduz      LIKE item.den_item_reduz
END RECORD
DEFINE ma_zcidade           ARRAY[9999] OF RECORD
	cod_cidade             char(5)
, den_cidade           char(30)
, cod_uni_feder      char(2)
END RECORD

DEFINE m_ies_consulta      SMALLINT
DEFINE ma_tela             ARRAY[9999] OF RECORD
	ies_selecionado   char(1),
	cod_cliente       CHAR(15),
	nom_cliente       LIKE clientes.nom_cliente,
	cod_item          CHAR(15),
	den_item          CHAR(76),
	desc_especial     CHAR(1),
	pct_desc          DECIMAL(4,2),
	preco_tabela      decimal(17,6),
	preco_calculado   decimal(17,6),
	pct_desc_adic     DECIMAL(4,2),
	preco_final   decimal(17,6),
	dat_final_desc    DATE
END RECORD
DEFINE ma_clientes             ARRAY[9999] OF RECORD
	cod_cliente       CHAR(15),
	nom_cliente       LIKE clientes.nom_cliente
END RECORD
DEFINE ma_itens             ARRAY[9999] OF RECORD
	cod_item          CHAR(15),
	den_item          CHAR(76)
END RECORD
DEFINE ma_telae             ARRAY[9999] OF RECORD
	cod_cliente       CHAR(15),
	nom_cliente       CHAR(76),
	cod_item          CHAR(15),
	den_item          CHAR(76),
	desc_especial     CHAR(1),
	pct_desc          DECIMAL(4,2),
	preco_tabela      decimal(17,6),
	preco_calculado   decimal(17,6),
	pct_desc_adic     DECIMAL(4,2),
	preco_final   decimal(17,6),
	dat_final_desc    DATE
END RECORD
DEFINE m_array             RECORD
	dados             VARCHAR(50),
	ies_selecionado   varchar(50),
	cod_cliente       VARCHAR(50),
	zoom_cliente      VARCHAR(50),
	nom_cliente       VARCHAR(50),
	cod_item          VARCHAR(50),
	zoom_item         VARCHAR(50),
	den_item          VARCHAR(50),
	desc_especial     VARCHAR(50),
	pct_desc          VARCHAR(50),
	preco_tabela      VARCHAR(50),
	preco_calculado   VARCHAR(50),
	pct_desc_adic     VARCHAR(50),
	preco_final       varchar(50),
	dat_final_desc    VARCHAR(50)
END RECORD
DEFINE m_refer             RECORD
	cod_cliente       VARCHAR(50),
	zoom_cliente      VARCHAR(50),
	funil_cliente      VARCHAR(50),
	nom_cliente       VARCHAR(50),
	cod_repres        VARCHAR(50),
	zoom_repres       VARCHAR(50),
	funil_repres       VARCHAR(50),
	raz_social        VARCHAR(50),
	cod_item          VARCHAR(50),
	zoom_item         VARCHAR(50),
	funil_item         VARCHAR(50),
	den_item          VARCHAR(50),
	cod_cidade        varchar(50),
	zoom_cidade       varchar(50),
	den_cidade        varchar(50),
	funil_cidade      VARCHAR(50),
	desc_especial     VARCHAR(50),
	pct_desc_de       VARCHAR(50),
	pct_desc_ate      VARCHAR(50),
	pct_desc_adic_de  VARCHAR(50),
	pct_desc_adic_ate VARCHAR(50),
	dat_final_desc_de VARCHAR(50),
	dat_final_desc_ate VARCHAR(50),
	aplica_listagem   VARCHAR(50),
	ies_suspenso VARCHAR(50),
	ies_novo VARCHAR(50),
	ies_inativo VARCHAR(50),
	ies_cancelado VARCHAR(50),
	ies_ativo         varchar(50),
	cep_de    varchar(50),
	cep_ate   varchar(50),
	num_list_preco     varchar(50)
END RECORD
define mr_tela, mr_telar   record
	cod_repres          decimal(4,0),
	raz_social          CHAR(36),
	cod_cliente         char(15),
	nom_cliente         CHAR(36),
	cod_item            char(15),
	den_item            CHAR(50),
	cod_cidade          char(5),
	den_cidade          char(30),
	desc_especial       char(1),
	pct_desc_de         DECIMAL(5,2),
	pct_desc_ate        DECIMAL(5,2),
	pct_desc_adic_de    DECIMAL(5,2),
	pct_desc_adic_ate   DECIMAL(5,2),
	dat_final_desc_de   DATE,
	dat_final_desc_ate  DATE,
	ies_suspenso  char(1),
	ies_novo  char(1),
	ies_inativo  char(1),
	ies_cancelado  char(1),
	ies_ativo char(1),
	cep_de char(9) ,
	cep_ate char(9) ,
	num_list_preco     integer
end record
define mr_dialog   record
	desc_especial       char(1),
	pct_desc            DECIMAL(4,2),
	pct_desc_adic       DECIMAL(4,2),
	pct_desc_ind            DECIMAL(4,2),
	pct_desc_adic_ind       DECIMAL(4,2),
	dat_final_desc      DATE
end record
DEFINE m_ind                SMALLINT
DEFINE m_layout             RECORD
	panel1             VARCHAR(50),
	form_principal     VARCHAR(50),
	toolbar            VARCHAR(50),
	status_bar         VARCHAR(50)
END RECORD
DEFINE m_botao       RECORD
	incluir      VARCHAR(50),
	modificar    VARCHAR(50),
	pesquisar    VARCHAR(50),
	zerar        varchar(50),
	marcar       varchar(50),
	desmarcar    varchar(50),
	sair         VARCHAR(50)
END RECORD



#-------------------#
FUNCTION geo1027()
	#-------------------#

	DEFINE l_label                      VARCHAR(50)
	, l_status                     SMALLINT

	CALL fgl_setenv("ADVPL","1")
	CALL LOG_connectDatabase("DEFAULT")

	CALL log1400_isolation()
	CALL log0180_conecta_usuario()

	CALL LOG_initApp('VDPLOG') RETURNING l_status

	LET m_ind = 0

	IF NOT l_status THEN
		CALL geo1027_tela()
	END IF

END FUNCTION

#-----------------------#
FUNCTION geo1027_tela()
	#-----------------------#

	CALL geo1027_menu()
	CALL geo1027_form()

END FUNCTION

#-----------------------#
FUNCTION geo1027_menu()
	#-----------------------#
	DEFINE l_label  VARCHAR(50)
	, l_splitter                   VARCHAR(50)
	, l_status SMALLINT


	#cria janela principal do tipo LDIALOG
	LET m_layout.form_principal = _ADVPL_create_component(NULL,"LDIALOG")
	CALL _ADVPL_set_property(m_layout.form_principal,"TITLE","LISTA DE DESCONTOS")
	CALL _ADVPL_set_property(m_layout.form_principal,"ENABLE_ESC_CLOSE",FALSE)
	CALL _ADVPL_set_property(m_layout.form_principal,"SIZE",1124,700)#   1024,725)

	#cria menu
	LET m_layout.toolbar = _ADVPL_create_component(NULL,"LMENUBAR",m_layout.form_principal)

	#botao INCLUIR
	LET m_botao.incluir = _ADVPL_create_component(NULL,"LCREATEBUTTON",m_layout.toolbar)
	CALL _ADVPL_set_property(m_botao.incluir,"EVENT","geo1027_incluir")
	CALL _ADVPL_set_property(m_botao.incluir,"CONFIRM_EVENT","geo1027_confirmar_incluir")
	CALL _ADVPL_set_property(m_botao.incluir,"CANCEL_EVENT","geo1027_cancelar_incluir")

	#botao INCLUIR
	LET m_botao.modificar = _ADVPL_create_component(NULL,"LUPDATEBUTTON",m_layout.toolbar)
	CALL _ADVPL_set_property(m_botao.modificar,"EVENT","geo1027_modificar")
	CALL _ADVPL_set_property(m_botao.modificar,"CONFIRM_EVENT","geo1027_confirmar_modificacao")
	CALL _ADVPL_set_property(m_botao.modificar,"CANCEL_EVENT","geo1027_cancelar_modificacao")

	#botao INCLUIR
	LET m_botao.pesquisar = _ADVPL_create_component(NULL,"LFINDBUTTON",m_layout.toolbar)
	CALL _ADVPL_set_property(m_botao.pesquisar,"EVENT","geo1027_pesquisar")
	CALL _ADVPL_set_property(m_botao.pesquisar,"CONFIRM_EVENT","geo1027_confirmar_pesquisar")
	CALL _ADVPL_set_property(m_botao.pesquisar,"CANCEL_EVENT","geo1027_cancela_pesquisar")
	
	#botao marcar todos
	LET m_botao.marcar = _ADVPL_create_component(NULL,"LMENUBUTTON",m_layout.toolbar)
	CALL _ADVPL_set_property(m_botao.marcar,"EVENT","geo1027_marcar_todos_painel")
	CALL _ADVPL_set_property(m_botao.marcar,"IMAGE","dSELALLEX")
	CALL _ADVPL_set_property(m_botao.marcar,"TYPE" ,"NO_CONFIRM")

    #botao desmarcar todos
	LET m_botao.desmarcar = _ADVPL_create_component(NULL,"LMENUBUTTON",m_layout.toolbar)
	CALL _ADVPL_set_property(m_botao.desmarcar,"EVENT","geo1027_desmarcar_todos_painel")
	CALL _ADVPL_set_property(m_botao.desmarcar,"IMAGE","dSELNONEEX")
	CALL _ADVPL_set_property(m_botao.desmarcar,"TYPE" ,"NO_CONFIRM")
     
	#botao ZERAR
	LET m_botao.zerar = _ADVPL_create_component(NULL, "LMENUBUTTON", m_layout.toolbar)
	CALL _ADVPL_set_property(m_botao.zerar,"IMAGE","ZERARTABELA")
	CALL _ADVPL_set_property(m_botao.zerar,"EVENT","geo1027_zerar")
	CALL _ADVPL_set_property(m_botao.zerar,"TYPE","NO_CONFIRM")

	#botao alterar desconto
	LET m_botao.zerar = _ADVPL_create_component(NULL, "LMENUBUTTON", m_layout.toolbar)
	CALL _ADVPL_set_property(m_botao.zerar,"IMAGE","DESCONTO_ACRESCIMO")
	CALL _ADVPL_set_property(m_botao.zerar,"EVENT","geo1027_alterar_desconto")
	CALL _ADVPL_set_property(m_botao.zerar,"TYPE","NO_CONFIRM")

	#botao alterar desconto
	LET m_botao.zerar = _ADVPL_create_component(NULL, "LMENUBUTTON", m_layout.toolbar)
	CALL _ADVPL_set_property(m_botao.zerar,"IMAGE","COPY_EX")
	CALL _ADVPL_set_property(m_botao.zerar,"EVENT","geo1027_copiar_desconto")
	CALL _ADVPL_set_property(m_botao.zerar,"TYPE","NO_CONFIRM")
	
	#botao Inclusão em Massa
	LET m_botao.zerar = _ADVPL_create_component(NULL, "LMENUBUTTON", m_layout.toolbar)
	CALL _ADVPL_set_property(m_botao.zerar,"IMAGE","CARGA_UNL")
	CALL _ADVPL_set_property(m_botao.zerar,"EVENT","geo1027_incluir_massa")
	CALL _ADVPL_set_property(m_botao.zerar,"TYPE","NO_CONFIRM")
	



	#botao sair
	LET m_botao.sair = _ADVPL_create_component(NULL,"LQUITBUTTON",m_layout.toolbar)

	LET m_layout.status_bar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_layout.form_principal)

END FUNCTION
#--------------------------#
FUNCTION geo1027_form()
	#--------------------------#
	DEFINE l_panel1               VARCHAR(50)
	DEFINE l_panel2               VARCHAR(50)
	DEFINE l_fieldset1            VARCHAR(50)
	DEFINE l_fieldset2            VARCHAR(50)
	DEFINE l_layout1              VARCHAR(50)
	DEFINE l_layout2              VARCHAR(50)
	DEFINE l_label                VARCHAR(50)

	#cria panel para campos de filtro 
	LET m_layout.panel1 = _ADVPL_create_component(NULL,"LPANEL",m_layout.form_principal)
	CALL _ADVPL_set_property(m_layout.panel1,"ALIGN","TOP")
	CALL _ADVPL_set_property(m_layout.panel1,"HEIGHT",570)

	#cria panel  
	LET l_panel1 = _ADVPL_create_component(NULL,"LPANEL",m_layout.panel1)
	CALL _ADVPL_set_property(l_panel1,"HEIGHT",200)
	CALL _ADVPL_set_property(l_panel1,"ALIGN","TOP")

	#cria panel  
	LET l_fieldset1 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel1)
	CALL _ADVPL_set_property(l_fieldset1,"TITLE","FILTROS")
	CALL _ADVPL_set_property(l_fieldset1,"ALIGN","CENTER")

	LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
	CALL _ADVPL_set_property(l_label,"TEXT","Representante:")
	CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	CALL _ADVPL_set_property(l_label,"POSITION",20,30)

	#cod_repres
	LET m_refer.cod_repres = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.cod_repres,"LENGTH",15)
	CALL _ADVPL_set_property(m_refer.cod_repres,"VARIABLE",mr_tela,"cod_repres")
	CALL _ADVPL_set_property(m_refer.cod_repres,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cod_repres,"VALID","geo1027_valid_cod_repres1")
	CALL _ADVPL_set_property(m_refer.cod_repres,"POSITION",130,30)

	#zoom
	LET m_refer.zoom_repres = _ADVPL_create_component(NULL, "LIMAGEBUTTON", l_panel1)
	CALL _ADVPL_set_property(m_refer.zoom_repres,"IMAGE","BTPESQ")
	CALL _ADVPL_set_property(m_refer.zoom_repres,"SIZE",24,20)
	CALL _ADVPL_set_property(m_refer.zoom_repres,"TOOLTIP","Zoom Representante")
	CALL _ADVPL_set_property(m_refer.zoom_repres,"CLICK_EVENT","geo1027_zoom_repres")
	CALL _ADVPL_set_property(m_refer.zoom_repres,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.zoom_repres,"POSITION",260,30)

	#descricao
	LET m_refer.raz_social = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.raz_social,"LENGTH",36)
	CALL _ADVPL_set_property(m_refer.raz_social,"VARIABLE",mr_tela,"raz_social")
	CALL _ADVPL_set_property(m_refer.raz_social,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.raz_social,"POSITION",290,30)


	#zoom
	LET m_refer.funil_repres = _ADVPL_create_component(NULL, "LIMAGEBUTTON", l_panel1)
	CALL _ADVPL_set_property(m_refer.funil_repres,"IMAGE","pesquisar_button")
	CALL _ADVPL_set_property(m_refer.funil_repres,"SIZE",24,20)
	CALL _ADVPL_set_property(m_refer.funil_repres,"TOOLTIP","Zoom Representante")
	CALL _ADVPL_set_property(m_refer.funil_repres,"CLICK_EVENT","geo1027_tela_funil_repres")
	CALL _ADVPL_set_property(m_refer.funil_repres,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.funil_repres,"POSITION",600,30)





	LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
	CALL _ADVPL_set_property(l_label,"TEXT","Cliente:")
	CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	CALL _ADVPL_set_property(l_label,"POSITION",20,60)


	#cod_cliente
	LET m_refer.cod_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.cod_cliente,"LENGTH",15)
	CALL _ADVPL_set_property(m_refer.cod_cliente,"VARIABLE",mr_tela,"cod_cliente")
	CALL _ADVPL_set_property(m_refer.cod_cliente,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cod_cliente,"VALID","geo1027_valid_cod_cliente1")
	CALL _ADVPL_set_property(m_refer.cod_cliente,"POSITION",130,60)

	#zoom
	LET m_refer.zoom_cliente = _ADVPL_create_component(NULL, "LIMAGEBUTTON", l_panel1)
	CALL _ADVPL_set_property(m_refer.zoom_cliente,"IMAGE","BTPESQ")
	CALL _ADVPL_set_property(m_refer.zoom_cliente,"SIZE",24,20)
	CALL _ADVPL_set_property(m_refer.zoom_cliente,"TOOLTIP","Zoom Clientes")
	CALL _ADVPL_set_property(m_refer.zoom_cliente,"CLICK_EVENT","geo1027_zoom_clientes")
	CALL _ADVPL_set_property(m_refer.zoom_cliente,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.zoom_cliente,"POSITION",260,60)

	#descricao
	LET m_refer.nom_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.nom_cliente,"LENGTH",36)
	CALL _ADVPL_set_property(m_refer.nom_cliente,"VARIABLE",mr_tela,"nom_cliente")
	CALL _ADVPL_set_property(m_refer.nom_cliente,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.nom_cliente,"POSITION",290,60)
	
	
		#zoom
	LET m_refer.funil_cliente = _ADVPL_create_component(NULL, "LIMAGEBUTTON", l_panel1)
	CALL _ADVPL_set_property(m_refer.funil_cliente,"IMAGE","pesquisar_button")
	CALL _ADVPL_set_property(m_refer.funil_cliente,"SIZE",24,20)
	CALL _ADVPL_set_property(m_refer.funil_cliente,"TOOLTIP","Zoom Cliente")
	CALL _ADVPL_set_property(m_refer.funil_cliente,"CLICK_EVENT","geo1027_tela_funil_cliente")
	CALL _ADVPL_set_property(m_refer.funil_cliente,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.funil_cliente,"POSITION",600,60)

	
	

	LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
	CALL _ADVPL_set_property(l_label,"TEXT","Item:")
	CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	CALL _ADVPL_set_property(l_label,"POSITION",20,90)

	#cod_item
	LET m_refer.cod_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.cod_item,"LENGTH",15)
	CALL _ADVPL_set_property(m_refer.cod_item,"VARIABLE",mr_tela,"cod_item")
	CALL _ADVPL_set_property(m_refer.cod_item,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cod_item,"VALID","geo1027_valid_cod_item1")
	CALL _ADVPL_set_property(m_refer.cod_item,"POSITION",130,90)

	#zoom
	LET m_refer.zoom_item = _ADVPL_create_component(NULL, "LIMAGEBUTTON", l_panel1)
	CALL _ADVPL_set_property(m_refer.zoom_item,"IMAGE","BTPESQ")
	CALL _ADVPL_set_property(m_refer.zoom_item,"SIZE",24,20)
	CALL _ADVPL_set_property(m_refer.zoom_item,"TOOLTIP","Zoom Item")
	CALL _ADVPL_set_property(m_refer.zoom_item,"CLICK_EVENT","geo1027_zoom_item")
	CALL _ADVPL_set_property(m_refer.zoom_item,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.zoom_item,"POSITION",260,90)

	#descricao
	LET m_refer.den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.den_item,"LENGTH",36)
	CALL _ADVPL_set_property(m_refer.den_item,"VARIABLE",mr_tela,"den_item")
	CALL _ADVPL_set_property(m_refer.den_item,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.den_item,"POSITION",290,90)
	
	
	#zoom
	LET m_refer.funil_item= _ADVPL_create_component(NULL, "LIMAGEBUTTON", l_panel1)
	CALL _ADVPL_set_property(m_refer.funil_item,"IMAGE","pesquisar_button")
	CALL _ADVPL_set_property(m_refer.funil_item,"SIZE",24,20)
	CALL _ADVPL_set_property(m_refer.funil_item,"TOOLTIP","Zoom Item")
	CALL _ADVPL_set_property(m_refer.funil_item,"CLICK_EVENT","geo1027_tela_funil_item")
	CALL _ADVPL_set_property(m_refer.funil_item,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.funil_item,"POSITION",600,90)
	
	
	
	##########3
	#
	#
	#
	##########3
	#cod cidade
	LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
	CALL _ADVPL_set_property(l_label,"TEXT","Cidade:")
	CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	CALL _ADVPL_set_property(l_label,"POSITION",20,120)

	#cod_item
	LET m_refer.cod_cidade = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.cod_cidade,"LENGTH",15)
	CALL _ADVPL_set_property(m_refer.cod_cidade,"VARIABLE",mr_tela,"cod_cidade")
	CALL _ADVPL_set_property(m_refer.cod_cidade,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cod_cidade,"VALID","geo1027_valid_cod_cidade")
	CALL _ADVPL_set_property(m_refer.cod_cidade,"POSITION",130,120)

	#zoom
	LET m_refer.zoom_cidade = _ADVPL_create_component(NULL, "LIMAGEBUTTON", l_panel1)
	CALL _ADVPL_set_property(m_refer.zoom_cidade,"IMAGE","BTPESQ")
	CALL _ADVPL_set_property(m_refer.zoom_cidade,"SIZE",24,20)
	CALL _ADVPL_set_property(m_refer.zoom_cidade,"TOOLTIP","Zoom Cidade")
	CALL _ADVPL_set_property(m_refer.zoom_cidade,"CLICK_EVENT","geo1027_zoom_cidade")
	CALL _ADVPL_set_property(m_refer.zoom_cidade,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.zoom_cidade,"POSITION",260,120)

	#descricao
	LET m_refer.den_cidade = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.den_cidade,"LENGTH",36)
	CALL _ADVPL_set_property(m_refer.den_cidade,"VARIABLE",mr_tela,"den_cidade")
	CALL _ADVPL_set_property(m_refer.den_cidade,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.den_cidade,"POSITION",290,120)
	
	
	#zoom
	LET m_refer.funil_cidade= _ADVPL_create_component(NULL, "LIMAGEBUTTON", l_panel1)
	CALL _ADVPL_set_property(m_refer.funil_cidade,"IMAGE","pesquisar_button")
	CALL _ADVPL_set_property(m_refer.funil_cidade,"SIZE",24,20)
	CALL _ADVPL_set_property(m_refer.funil_cidade,"TOOLTIP","Zoom Cidade")
	CALL _ADVPL_set_property(m_refer.funil_cidade,"CLICK_EVENT","geo1027_tela_funil_cidade")
	CALL _ADVPL_set_property(m_refer.funil_cidade,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.funil_cidade,"POSITION",600,120)
	
	
	
	###
	LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
	CALL _ADVPL_set_property(l_label,"TEXT","CEP De:")
	CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	CALL _ADVPL_set_property(l_label,"POSITION",700,120)

	#cod_item
	LET m_refer.cep_de = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.cep_de,"LENGTH",9)
	CALL _ADVPL_set_property(m_refer.cep_de,"PICTURE","@! XXXXX-XXX")
	CALL _ADVPL_set_property(m_refer.cep_de,"VARIABLE",mr_tela,"cep_de")
	CALL _ADVPL_set_property(m_refer.cep_de,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cep_de,"POSITION",830,120)

	LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
	CALL _ADVPL_set_property(l_label,"TEXT","Até:")
	CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	CALL _ADVPL_set_property(l_label,"POSITION",950,120)

	#descricao
	LET m_refer.cep_ate = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.cep_ate,"LENGTH",9)
	CALL _ADVPL_set_property(m_refer.cep_ate,"PICTURE","@! XXXXX-XXX")
	CALL _ADVPL_set_property(m_refer.cep_ate,"VARIABLE",mr_tela,"cep_ate")
	CALL _ADVPL_set_property(m_refer.cep_ate,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cep_ate,"POSITION",1000,120)
	
	############
	#
	#
	#
	#########


	LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
	CALL _ADVPL_set_property(l_label,"TEXT","Desconto Especial:")
	CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	CALL _ADVPL_set_property(l_label,"POSITION",20,150)

	#cod_item
	LET m_refer.desc_especial = _ADVPL_create_component(NULL,"LCOMBOBOX",l_panel1)
	CALL _ADVPL_set_property(m_refer.desc_especial,"VARIABLE",mr_tela,"desc_especial")
	CALL _ADVPL_set_property(m_refer.desc_especial,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.desc_especial,"POSITION",130,150)
	CALL _ADVPL_set_property(m_refer.desc_especial,"ADD_ITEM","T","TODOS")
	CALL _ADVPL_set_property(m_refer.desc_especial,"ADD_ITEM","S","SIM")
	CALL _ADVPL_set_property(m_refer.desc_especial,"ADD_ITEM","N","NÃO")




	LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
	CALL _ADVPL_set_property(l_label,"TEXT","Faixa % Desc De:")
	CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	CALL _ADVPL_set_property(l_label,"POSITION",700,30)

	#cod_item
	LET m_refer.pct_desc_de = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.pct_desc_de,"LENGTH",5,2)
	CALL _ADVPL_set_property(m_refer.pct_desc_de,"VARIABLE",mr_tela,"pct_desc_de")
	CALL _ADVPL_set_property(m_refer.pct_desc_de,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.pct_desc_de,"POSITION",830,30)
	CALL _ADVPL_set_property(m_refer.pct_desc_de,"PICTURE","@E 999.99")

	LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
	CALL _ADVPL_set_property(l_label,"TEXT","Até:")
	CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	CALL _ADVPL_set_property(l_label,"POSITION",950,30)

	#descricao
	LET m_refer.pct_desc_ate = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.pct_desc_ate,"LENGTH",5,2)
	CALL _ADVPL_set_property(m_refer.pct_desc_ate,"VARIABLE",mr_tela,"pct_desc_ate")
	CALL _ADVPL_set_property(m_refer.pct_desc_ate,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.pct_desc_ate,"POSITION",1000,30)
	CALL _ADVPL_set_property(m_refer.pct_desc_ate,"PICTURE","@E 999.99")


	LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
	CALL _ADVPL_set_property(l_label,"TEXT","Faixa % Desc Adic De:")
	CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	CALL _ADVPL_set_property(l_label,"POSITION",700,60)

	#cod_item
	LET m_refer.pct_desc_adic_de = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_de,"LENGTH",4,2)
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_de,"VARIABLE",mr_tela,"pct_desc_adic_de")
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_de,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_de,"POSITION",830,60)
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_de,"PICTURE","@E 999.99")

	LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
	CALL _ADVPL_set_property(l_label,"TEXT","Até:")
	CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	CALL _ADVPL_set_property(l_label,"POSITION",950,60)

	#descricao
	LET m_refer.pct_desc_adic_ate = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_ate,"LENGTH",4,2)
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_ate,"VARIABLE",mr_tela,"pct_desc_adic_ate")
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_ate,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_ate,"POSITION",1000,60)
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_ate,"PICTURE","@E 999.99")


	LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
	CALL _ADVPL_set_property(l_label,"TEXT","Data Final Desconto De:")
	CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	CALL _ADVPL_set_property(l_label,"POSITION",700,90)

	#cod_item
	LET m_refer.dat_final_desc_de = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.dat_final_desc_de,"VARIABLE",mr_tela,"dat_final_desc_de")
	CALL _ADVPL_set_property(m_refer.dat_final_desc_de,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.dat_final_desc_de,"POSITION",830,90)

	LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
	CALL _ADVPL_set_property(l_label,"TEXT","Até:")
	CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	CALL _ADVPL_set_property(l_label,"POSITION",950,90)

	#descricao
	LET m_refer.dat_final_desc_ate = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.dat_final_desc_ate,"VARIABLE",mr_tela,"dat_final_desc_ate")
	CALL _ADVPL_set_property(m_refer.dat_final_desc_ate,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.dat_final_desc_ate,"POSITION",1000,90)


	LET m_refer.aplica_listagem = _ADVPL_create_component(NULL, "LBUTTON", l_panel1)
	CALL _ADVPL_set_property(m_refer.aplica_listagem,"TEXT", "Aplicar na Listagem")
	CALL _ADVPL_set_property(m_refer.aplica_listagem,"CLICK_EVENT","geo1027_dialog")
	CALL _ADVPL_set_property(m_refer.aplica_listagem,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.aplica_listagem,"SIZE",130,25)
	CALL _ADVPL_set_property(m_refer.aplica_listagem,"POSITION",250,150)


	#cria campo  
	let m_refer.ies_ativo = _ADVPL_create_component(NULL,"LCHECKBOX",l_panel1)
	call _ADVPL_set_property(m_refer.ies_ativo,"VALUE_CHECKED","S")
	call _ADVPL_set_property(m_refer.ies_ativo,"VALUE_NCHECKED","N")
	call _ADVPL_set_property(m_refer.ies_ativo,"VARIABLE",mr_tela,"ies_ativo")
	call _ADVPL_set_property(m_refer.ies_ativo,"TEXT","Ativos")
	CALL _ADVPL_set_property(m_refer.ies_ativo,"POSITION",450,150)
	CALL _ADVPL_set_property(m_refer.ies_ativo,"ENABLE",true)

	#cria campo  
	let m_refer.ies_cancelado = _ADVPL_create_component(NULL,"LCHECKBOX",l_panel1)
	call _ADVPL_set_property(m_refer.ies_cancelado,"VALUE_CHECKED","S")
	call _ADVPL_set_property(m_refer.ies_cancelado,"VALUE_NCHECKED","N")
	call _ADVPL_set_property(m_refer.ies_cancelado,"VARIABLE",mr_tela,"ies_cancelado")
	call _ADVPL_set_property(m_refer.ies_cancelado,"TEXT","Cancelados")
	CALL _ADVPL_set_property(m_refer.ies_cancelado,"POSITION",550,150)
	CALL _ADVPL_set_property(m_refer.ies_cancelado,"ENABLE",true)

	#cria campo  
	let m_refer.ies_inativo = _ADVPL_create_component(NULL,"LCHECKBOX",l_panel1)
	call _ADVPL_set_property(m_refer.ies_inativo,"VALUE_CHECKED","S")
	call _ADVPL_set_property(m_refer.ies_inativo,"VALUE_NCHECKED","N")
	call _ADVPL_set_property(m_refer.ies_inativo,"VARIABLE",mr_tela,"ies_inativo")
	call _ADVPL_set_property(m_refer.ies_inativo,"TEXT","Inativos")
	CALL _ADVPL_set_property(m_refer.ies_inativo,"POSITION",650,150)
	CALL _ADVPL_set_property(m_refer.ies_inativo,"ENABLE",true)

	#cria campo  
	let m_refer.ies_novo = _ADVPL_create_component(NULL,"LCHECKBOX",l_panel1)
	call _ADVPL_set_property(m_refer.ies_novo,"VALUE_CHECKED","S")
	call _ADVPL_set_property(m_refer.ies_novo,"VALUE_NCHECKED","N")
	call _ADVPL_set_property(m_refer.ies_novo,"VARIABLE",mr_tela,"ies_novo")
	call _ADVPL_set_property(m_refer.ies_novo,"TEXT","Novos")
	CALL _ADVPL_set_property(m_refer.ies_novo,"POSITION",750,150)
	CALL _ADVPL_set_property(m_refer.ies_novo,"ENABLE",true)


	#cria campo  
	let m_refer.ies_suspenso = _ADVPL_create_component(NULL,"LCHECKBOX",l_panel1)
	call _ADVPL_set_property(m_refer.ies_suspenso,"VALUE_CHECKED","S")
	call _ADVPL_set_property(m_refer.ies_suspenso,"VALUE_NCHECKED","N")
	call _ADVPL_set_property(m_refer.ies_suspenso,"VARIABLE",mr_tela,"ies_suspenso")
	call _ADVPL_set_property(m_refer.ies_suspenso,"TEXT","Suspensos")
	CALL _ADVPL_set_property(m_refer.ies_suspenso,"POSITION",850,150)
	CALL _ADVPL_set_property(m_refer.ies_suspenso,"ENABLE",true)


#cria campo    
	LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
	CALL _ADVPL_set_property(l_label,"TEXT","Lista:")
	CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
	CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	CALL _ADVPL_set_property(l_label,"POSITION",950,150)

	#cod_repres
	LET m_refer.num_list_preco = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel1)
	CALL _ADVPL_set_property(m_refer.num_list_preco,"LENGTH",3)
	CALL _ADVPL_set_property(m_refer.num_list_preco,"VARIABLE",mr_tela,"num_list_preco")
	CALL _ADVPL_set_property(m_refer.num_list_preco,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.num_list_preco,"POSITION",1050,150)
 


	#cria panel  
	LET l_panel2 = _ADVPL_create_component(NULL,"LPANEL",m_layout.panel1)
	CALL _ADVPL_set_property(l_panel2,"HEIGHT",390)
	CALL _ADVPL_set_property(l_panel2,"ALIGN","BOTTOM")

	#cria panel  
	LET l_fieldset2 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel2)
	CALL _ADVPL_set_property(l_fieldset2,"HEIGHT",390)
	CALL _ADVPL_set_property(l_fieldset2,"ALIGN","TOP")
	CALL _ADVPL_set_property(l_fieldset2,"TITLE"," ")

	#cria array
	LET m_array.dados = _ADVPL_create_component(NULL,"LBROWSEEX",l_fieldset2)
	CALL _ADVPL_set_property(m_array.dados,"SIZE",650,390)
	CALL _ADVPL_set_property(m_array.dados,"CAN_ADD_ROW",FALSE)
	CALL _ADVPL_set_property(m_array.dados,"CAN_REMOVE_ROW",FALSE)
	CALL _ADVPL_set_property(m_array.dados,"ALIGN","CENTER")
	CALL _ADVPL_set_property(m_array.dados,"EDITABLE",TRUE)
	CALL _ADVPL_set_property(m_array.dados,"ENABLE",TRUE)
	CALL _ADVPL_set_property(m_array.dados,"BEFORE_ROW_EVENT","geo1027_before_row")
	#CALL _ADVPL_set_property(m_array.dados,"AFTER_ROW_EVENT","geo1027_after_row")
	CALL _ADVPL_set_property(m_array.dados,"POSITION",80,570)
	
    #cria campo do array: ies_selecionado
	LET m_array.ies_selecionado = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_array.dados)
	CALL _ADVPL_set_property(m_array.ies_selecionado,"IMAGE","{'S','CHECKED'}{'N','UNCHECKED'}")
	CALL _ADVPL_set_property(m_array.ies_selecionado,"EDITABLE", TRUE)
	CALL _ADVPL_set_property(m_array.ies_selecionado,"HEADER","Seleciona")
	CALL _ADVPL_set_property(m_array.ies_selecionado,"VARIABLE","ies_selecionado")
	CALL _ADVPL_set_property(m_array.ies_selecionado,"COLUMN_SIZE",10)
    	
 	#cria campo do array: cod_cliente
	LET m_array.cod_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_array.dados)
	CALL _ADVPL_set_property(m_array.cod_cliente,"VARIABLE","cod_cliente")
	CALL _ADVPL_set_property(m_array.cod_cliente,"HEADER","Cod.Cliente")
	CALL _ADVPL_set_property(m_array.cod_cliente,"COLUMN_SIZE", 50)
	CALL _ADVPL_set_property(m_array.cod_cliente,"ORDER",TRUE)
	CALL _ADVPL_set_property(m_array.cod_cliente,"EDIT_COMPONENT","LTEXTFIELD")
	CALL _ADVPL_set_property(m_array.cod_cliente,"EDIT_PROPERTY","LENGTH",15)
	CALL _ADVPL_set_property(m_array.cod_cliente,"EDIT_PROPERTY","VALID","geo1027_valid_cod_cliente2")
	CALL _ADVPL_set_property(m_array.cod_cliente,"EDITABLE", FALSE)

	#-- Zoom
	LET m_array.zoom_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_array.dados)
	CALL _ADVPL_set_property(m_array.zoom_cliente,"COLUMN_SIZE",10)
	CALL _ADVPL_set_property(m_array.zoom_cliente,"EDITABLE",FALSE)
	CALL _ADVPL_set_property(m_array.zoom_cliente,"NO_VARIABLE",TRUE)
	CALL _ADVPL_set_property(m_array.zoom_cliente,"IMAGE", "BTPESQ")
	CALL _ADVPL_set_property(m_array.zoom_cliente,"BEFORE_EDIT_EVENT","geo1027_zoom_clientes2")

	#cria campo do array: nom_cliente
	LET m_array.nom_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_array.dados)
	CALL _ADVPL_set_property(m_array.nom_cliente,"VARIABLE","nom_cliente")
	CALL _ADVPL_set_property(m_array.nom_cliente,"HEADER","Nom.Cliente")
	CALL _ADVPL_set_property(m_array.nom_cliente,"COLUMN_SIZE", 80)
	CALL _ADVPL_set_property(m_array.nom_cliente,"ORDER",TRUE)
	CALL _ADVPL_set_property(m_array.nom_cliente,"EDIT_COMPONENT","LTEXTFIELD")
	CALL _ADVPL_set_property(m_array.nom_cliente,"EDIT_PROPERTY","LENGTH",76)
	CALL _ADVPL_set_property(m_array.nom_cliente,"EDITABLE", FALSE)

	#cria campo do array: cod_item
	LET m_array.cod_item = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_array.dados)
	CALL _ADVPL_set_property(m_array.cod_item,"VARIABLE","cod_item")
	CALL _ADVPL_set_property(m_array.cod_item,"HEADER","Cod.Item")
	CALL _ADVPL_set_property(m_array.cod_item,"COLUMN_SIZE", 40)
	CALL _ADVPL_set_property(m_array.cod_item,"ORDER",TRUE)
	CALL _ADVPL_set_property(m_array.cod_item,"EDIT_COMPONENT","LTEXTFIELD")
	CALL _ADVPL_set_property(m_array.cod_item,"EDIT_PROPERTY","LENGTH",20)
	CALL _ADVPL_set_property(m_array.cod_item,"EDIT_PROPERTY","VALID","geo1027_valid_cod_item2")
	CALL _ADVPL_set_property(m_array.cod_item,"EDITABLE", FALSE)

	#-- Zoom
	LET m_array.zoom_item = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_array.dados)
	CALL _ADVPL_set_property(m_array.zoom_item,"COLUMN_SIZE",10)
	CALL _ADVPL_set_property(m_array.zoom_item,"EDITABLE",FALSE)
	CALL _ADVPL_set_property(m_array.zoom_item,"NO_VARIABLE",TRUE)
	CALL _ADVPL_set_property(m_array.zoom_item,"IMAGE", "BTPESQ")
	CALL _ADVPL_set_property(m_array.zoom_item,"BEFORE_EDIT_EVENT","geo1027_zoom_item2")

	#cria campo do array: den_item
	LET m_array.den_item = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_array.dados)
	CALL _ADVPL_set_property(m_array.den_item,"VARIABLE","den_item")
	CALL _ADVPL_set_property(m_array.den_item,"HEADER","Den.Item")
	CALL _ADVPL_set_property(m_array.den_item,"COLUMN_SIZE", 80)
	CALL _ADVPL_set_property(m_array.den_item,"ORDER",TRUE)
	CALL _ADVPL_set_property(m_array.den_item,"EDIT_COMPONENT","LTEXTFIELD")
	CALL _ADVPL_set_property(m_array.den_item,"EDIT_PROPERTY","LENGTH",76)
	CALL _ADVPL_set_property(m_array.den_item,"EDITABLE", FALSE)

	#cria campo do array: desc_especial
	LET m_array.desc_especial = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_array.dados)
	CALL _ADVPL_set_property(m_array.desc_especial,"VARIABLE","desc_especial")
	CALL _ADVPL_set_property(m_array.desc_especial,"HEADER","Desc.Especial")
	CALL _ADVPL_set_property(m_array.desc_especial,"COLUMN_SIZE", 20)
	CALL _ADVPL_set_property(m_array.desc_especial,"ORDER",TRUE)
	CALL _ADVPL_set_property(m_array.desc_especial,"EDITABLE", FALSE)
	CALL _ADVPL_set_property(m_array.desc_especial,"EDIT_COMPONENT","LCHECKBOX")
	CALL _ADVPL_set_property(m_array.desc_especial,"EDIT_PROPERTY","VALUE_CHECKED","S")
	CALL _ADVPL_set_property(m_array.desc_especial,"EDIT_PROPERTY","VALUE_NCHECKED","N")
	CALL _ADVPL_set_property(m_array.desc_especial,"IMAGE_HEADER","CHECKED")

	#cria campo do array: pct_desc
	LET m_array.pct_desc = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_array.dados)
	CALL _ADVPL_set_property(m_array.pct_desc,"VARIABLE","pct_desc")
	CALL _ADVPL_set_property(m_array.pct_desc,"HEADER","% Desc")
	CALL _ADVPL_set_property(m_array.pct_desc,"COLUMN_SIZE", 40)
	CALL _ADVPL_set_property(m_array.pct_desc,"ORDER",TRUE)
	CALL _ADVPL_set_property(m_array.pct_desc,"EDIT_COMPONENT","LNUMERICFIELD")
	CALL _ADVPL_set_property(m_array.pct_desc,"EDIT_PROPERTY","LENGTH",4,2)
	CALL _ADVPL_set_property(m_array.pct_desc,"EDITABLE", FALSE)
	CALL _ADVPL_set_property(m_array.pct_desc,"PICTURE","@E 999.99")
	CALL _ADVPL_set_property(m_array.pct_desc,"EDIT_PROPERTY","VALID","geo1027_valid_pct_desc")


    #cria campo do array: preco_tabela
	LET m_array.preco_tabela = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_array.dados)
	CALL _ADVPL_set_property(m_array.preco_tabela,"VARIABLE","preco_tabela")
	CALL _ADVPL_set_property(m_array.preco_tabela,"HEADER","Preço Tab.")
	CALL _ADVPL_set_property(m_array.preco_tabela,"COLUMN_SIZE", 50)
	CALL _ADVPL_set_property(m_array.preco_tabela,"ORDER",TRUE)
	CALL _ADVPL_set_property(m_array.preco_tabela,"EDIT_COMPONENT","LNUMERICFIELD")
	CALL _ADVPL_set_property(m_array.preco_tabela,"EDIT_PROPERTY","LENGTH",17,6)
	CALL _ADVPL_set_property(m_array.preco_tabela,"EDITABLE", FALSE)
	CALL _ADVPL_set_property(m_array.preco_tabela,"PICTURE","@E 999999999.999")
	
	#cria campo do array: preco_calculado
	LET m_array.preco_calculado = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_array.dados)
	CALL _ADVPL_set_property(m_array.preco_calculado,"VARIABLE","preco_calculado")
	CALL _ADVPL_set_property(m_array.preco_calculado,"HEADER","Preço Calc.")
	CALL _ADVPL_set_property(m_array.preco_calculado,"COLUMN_SIZE", 50)
	CALL _ADVPL_set_property(m_array.preco_calculado,"ORDER",TRUE)
	CALL _ADVPL_set_property(m_array.preco_calculado,"EDIT_COMPONENT","LNUMERICFIELD")
	CALL _ADVPL_set_property(m_array.preco_calculado,"EDIT_PROPERTY","LENGTH",17,6)
	CALL _ADVPL_set_property(m_array.preco_calculado,"EDITABLE", FALSE)
	CALL _ADVPL_set_property(m_array.preco_calculado,"PICTURE","@E 999999999.999")

	#cria campo do array: pct_desc_adic
	LET m_array.pct_desc_adic = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_array.dados)
	CALL _ADVPL_set_property(m_array.pct_desc_adic,"VARIABLE","pct_desc_adic")
	CALL _ADVPL_set_property(m_array.pct_desc_adic,"HEADER","% Desc Adic")
	CALL _ADVPL_set_property(m_array.pct_desc_adic,"COLUMN_SIZE", 40)
	CALL _ADVPL_set_property(m_array.pct_desc_adic,"ORDER",TRUE)
	CALL _ADVPL_set_property(m_array.pct_desc_adic,"EDIT_COMPONENT","LNUMERICFIELD")
	CALL _ADVPL_set_property(m_array.pct_desc_adic,"EDIT_PROPERTY","LENGTH",4,2)
	CALL _ADVPL_set_property(m_array.pct_desc_adic,"EDITABLE", FALSE)
	CALL _ADVPL_set_property(m_array.pct_desc_adic,"PICTURE","@E 999.99")

	CALL _ADVPL_set_property(m_array.pct_desc_adic,"EDIT_PROPERTY","VALID","geo1027_valid_pct_desc_adic")
	
	


	#cria campo do array: dat_final_desc
	LET m_array.dat_final_desc = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_array.dados)
	CALL _ADVPL_set_property(m_array.dat_final_desc,"VARIABLE","dat_final_desc")
	CALL _ADVPL_set_property(m_array.dat_final_desc,"HEADER","Data")
	CALL _ADVPL_set_property(m_array.dat_final_desc,"COLUMN_SIZE", 50)
	CALL _ADVPL_set_property(m_array.dat_final_desc,"ORDER",TRUE)
	CALL _ADVPL_set_property(m_array.dat_final_desc,"EDIT_COMPONENT","LDATEFIELD")
	CALL _ADVPL_set_property(m_array.dat_final_desc,"EDITABLE", FALSE)
	CALL _ADVPL_set_property(m_array.dat_final_desc,"EDIT_PROPERTY","VALID","geo1027_valid_dat_final_desc")
	
	
	#cria campo do array: preco_final
	LET m_array.preco_final = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_array.dados)
	CALL _ADVPL_set_property(m_array.preco_final,"VARIABLE","preco_final")
	CALL _ADVPL_set_property(m_array.preco_final,"HEADER","Preço Final")
	CALL _ADVPL_set_property(m_array.preco_final,"COLUMN_SIZE", 50)
	CALL _ADVPL_set_property(m_array.preco_final,"ORDER",TRUE)
	CALL _ADVPL_set_property(m_array.preco_final,"EDIT_COMPONENT","LNUMERICFIELD")
	CALL _ADVPL_set_property(m_array.preco_final,"EDIT_PROPERTY","LENGTH",17,6)
	CALL _ADVPL_set_property(m_array.preco_final,"EDITABLE", FALSE)
	CALL _ADVPL_set_property(m_array.preco_final,"PICTURE","@E 999999999.999")
	
	

	CALL _ADVPL_set_property(m_array.dados,"SET_ROWS",ma_tela,0)
	CALL _ADVPL_set_property(m_array.dados,"ITEM_COUNT",0)
	CALL _ADVPL_set_property(m_array.dados,"REFRESH")


	CALL _ADVPL_set_property(m_layout.form_principal,"ACTIVATE",TRUE)
END FUNCTION

#---------------------------#
function geo1027_valid_dat_final_desc()
#---------------------------#
	DEFINE l_arr_curr        SMALLINT

	LET l_arr_curr = _ADVPL_get_property(m_array.dados,"ITEM_SELECTED")
	
	call geo1027_calcula_preco_desconto(l_arr_curr)
	
end function

#---------------------------#
FUNCTION geo1027_valid_pct_desc_adic()
	#---------------------------#
	DEFINE l_arr_curr        SMALLINT

	LET l_arr_curr = _ADVPL_get_property(m_array.dados,"ITEM_SELECTED")


	if ma_tela[l_arr_curr].pct_desc_adic >= 100 then
		CALL _ADVPL_message_box("Deseconto informadod maior que 100%.")
		RETURN FALSE
	END IF

	call geo1027_calcula_preco_desconto(l_arr_curr)
        

	RETURN TRUE

END FUNCTION

#---------------------------#
function geo1027_calcula_preco_desconto(l_ind)
#---------------------------#
	define l_sql2 char(5000)
	define l_ind integer
	LET l_sql2 = '  select pre_unit ',
		'    from desc_preco_item ',
		'   where cod_empresa = "', p_cod_empresa, '" ',
		'     and num_list_preco = ', mr_tela.num_list_preco ,
		'     and cod_item = "', ma_tela[l_ind].cod_item, '" '
        
	PREPARE var_query2 FROM l_sql2
	DECLARE cq_pre_unit1 CURSOR WITH HOLD FOR var_query2
	OPEN cq_pre_unit1
	FETCH cq_pre_unit1 INTO ma_tela[l_ind].preco_tabela
        
	LET ma_tela[l_ind].preco_calculado = ma_tela[l_ind].preco_tabela - (ma_tela[l_ind].preco_tabela * ma_tela[l_ind].pct_desc / 100 )
        
	if ma_tela[l_ind].dat_final_desc >= today then
		LET ma_tela[l_ind].preco_final = ma_tela[l_ind].preco_calculado - (ma_tela[l_ind].preco_calculado * ma_tela[l_ind].pct_desc_adic / 100 )
	else
		LET ma_tela[l_ind].preco_final = ma_tela[l_ind].preco_calculado
	end if
		
		
end function

#---------------------------#
FUNCTION geo1027_valid_pct_desc()
	#---------------------------#
	DEFINE l_arr_curr        SMALLINT

	LET l_arr_curr = _ADVPL_get_property(m_array.dados,"ITEM_SELECTED")


	if ma_tela[l_arr_curr].pct_desc >= 100 then
		CALL _ADVPL_message_box("Deseconto informadod maior que 100%.")
		RETURN FALSE
	END IF
	
	call geo1027_calcula_preco_desconto(l_arr_curr)
    
	RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION geo1027_pesquisar()
	#---------------------------#
	DEFINE l_data    CHAR(10)
	INITIALIZE mr_tela.*, ma_tela to null
	
    initialize ma_funil_item to null
	initialize ma_funil_repres to null
	initialize ma_funil_cliente to null
	initialize ma_funil_cidade to null
	
	CALL _ADVPL_set_property(m_array.dados,"ITEM_COUNT",0)
	CALL _ADVPL_set_property(m_array.dados,"REFRESH")

	LET mr_tela.pct_desc_de = -99.99
	LET mr_tela.pct_desc_ate = 99.99
	LET mr_tela.pct_desc_adic_de = -99.99
	LET mr_tela.pct_desc_adic_ate = 99.99
	LET mr_tela.desc_especial = 'T'
	LET mr_tela.ies_suspenso = 'S'
	LET mr_tela.ies_novo = 'S'
	LET mr_tela.ies_inativo = 'S'
	LET mr_tela.ies_cancelado = 'S'
	LET mr_tela.ies_ativo = 'S'
	LET mr_tela.cep_de = ''
	LET mr_tela.cep_ate = ''
	LET mr_tela.num_list_preco = 1


	LET l_data = "01/01/2016" #,EXTEND(CURRENT, YEAR TO YEAR) ##ALTERADO EM 03/01/2017 CONFORME SOLICITADO PELA ROSE
	LET mr_tela.dat_final_desc_de = l_data

	LET l_data = "31/12/",EXTEND(CURRENT + 100 units year, YEAR TO YEAR)
	LET mr_tela.dat_final_desc_ate = l_data


	CALL geo1027_habilita_campos_manutencao(TRUE,'CONSULTAR')

END FUNCTION

#-----------------------------#
function geo1027_modificar()
	#-----------------------------#
	define l_msg char(80)

	INITIALIZE ma_telae TO NULL
	LET ma_telae = ma_tela
	call geo1027_habilita_campos_manutencao(TRUE,'MODIFICAR')
end function

#-----------------------------#
function geo1027_excluir()
	#-----------------------------#
	define l_msg char(80)

	let l_msg = 'Confirma a exclusão da rota do Vendedor: ', mr_tela.cod_repres, '?'
	IF LOG_pergunta(l_msg) THEN
	else
		return false
	end if

	delete
	from geo_rot_repres
	where cod_empresa = p_cod_empresa
	and cod_repres = mr_tela.cod_repres

	initialize mr_tela.* to null
	initialize ma_tela  to null
	CALL _ADVPL_set_property(m_array.dados,"ITEM_COUNT",0)
	CALL _ADVPL_set_property(m_array.dados,"REFRESH")

END FUNCTION

#---------------------------#
function geo1027_confirmar_pesquisar()
	#---------------------------#
	CALL geo1027_habilita_campos_manutencao(FALSE,'CONSULTAR')
	CALL LOG_progress_start("Processa","geo1027_carrega_dados","PROCESS")
end function

#---------------------------#
function geo1027_carrega_dados()
	#---------------------------#
	DEFINE l_ind         SMALLINT
	DEFINE l_sql         CHAR(999999)
	DEFINE l_sql2        CHAR(999999)
	DEFINE l_entrou      SMALLINT
	DEFINE l_tam         INTEGER

	INITIALIZE ma_tela TO NULL

	LET l_sql = " SELECT 'N', a.cod_cliente,   ",
		"        b.nom_cliente,   ",
		"        c.cod_item,      ",
		"        c.den_item,      ",
		"        a.desc_especial, ",
		"        a.pct_desc, 0,0,     ",
		"        a.pct_desc_adic,0, ",
		"        a.dat_final_desc ",
		"   FROM geo_desc_lista a, clientes b, item c ",
		"  WHERE a.cod_empresa = '",p_cod_empresa,"' ",
		"    AND a.cod_empresa = c.cod_empresa ",
		"    AND a.cod_cliente = b.cod_cliente ",
		"    AND a.cod_item    = c.cod_item ",
		"    AND a.dat_final_desc >= '",mr_tela.dat_final_desc_de,"'",
		"    AND a.dat_final_desc <= '",mr_tela.dat_final_desc_ate,"'",
		"    AND a.pct_desc >= ",log0800_replace(mr_tela.pct_desc_de,",","."),"",
		"    AND a.pct_desc <= ",log0800_replace(mr_tela.pct_desc_ate,",","."),"",
		"    AND a.pct_desc_adic >= ",log0800_replace(mr_tela.pct_desc_adic_de,",","."),"",
		"    AND a.pct_desc_adic <= ",log0800_replace(mr_tela.pct_desc_adic_ate,",","."),""


	IF mr_tela.ies_suspenso = 'S' OR
		mr_tela.ies_novo = 'S' OR
		mr_tela.ies_inativo = 'S' OR
		mr_tela.ies_cancelado = 'S' OR
		mr_tela.ies_ativo = 'S' THEN
		LET l_sql = l_sql CLIPPED, " AND b.cod_cliente IN ( SELECT x.cod_cliente FROM credcad_cli x WHERE x.ies_aprovacao IN ( "
	END if

	IF mr_tela.ies_suspenso = 'S' THEN
		LET l_sql = l_sql CLIPPED, '  "S" ,'
	END if

	IF mr_tela.ies_novo = 'S' THEN
		LET l_sql = l_sql CLIPPED, '  "N" ,'
	END if

	IF mr_tela.ies_inativo = 'S' THEN
		LET l_sql = l_sql CLIPPED, '  "I" ,'
	END if

	IF mr_tela.ies_cancelado = 'S' THEN
		LET l_sql = l_sql CLIPPED, '  "C" ,'
	END if

	IF mr_tela.ies_ativo = 'S' THEN
		LET l_sql = l_sql CLIPPED, '  "A" ,'
	END if


	IF mr_tela.ies_suspenso = 'S' OR
		mr_tela.ies_novo = 'S' OR
		mr_tela.ies_inativo = 'S' OR
		mr_tela.ies_cancelado = 'S' OR
		mr_tela.ies_ativo = 'S' THEN
		let l_tam = LENGTH(l_sql)

		let l_sql = l_sql[1,l_tam-1]
		let l_sql = l_sql clipped, ' ) ) '

	end if



	IF mr_tela.desc_especial <> 'T' THEN
		LET l_sql = l_sql CLIPPED, " AND a.desc_especial = '",mr_tela.desc_especial,"'"
	END IF


	IF mr_tela.cep_de IS NOT NULL AND mr_tela.cep_de <> " " THEN
		LET l_sql = l_sql CLIPPED," AND b.cod_cep >= '",mr_tela.cep_de,"'"
	END IF
	
	IF mr_tela.cep_ate IS NOT NULL AND mr_tela.cep_ate <> " " THEN
		LET l_sql = l_sql CLIPPED," AND b.cod_cep <= '",mr_tela.cep_ate,"'"
	END IF
	
	IF mr_tela.cod_cidade IS NOT NULL AND mr_tela.cod_cidade <> " " THEN
		LET l_sql = l_sql CLIPPED," AND b.cod_cidade = '",mr_tela.cod_cidade,"'"
	END IF
	
	if ma_funil_cidade[1].cod_cidade is not null and ma_funil_cidade[1].cod_cidade <> ' ' then
		LET l_sql = l_sql CLIPPED," AND b.cod_cidade in ( " 
	end if 
	
	for l_ind = 1 to 100
		if ma_funil_cidade[l_ind].cod_cidade is null or ma_funil_cidade[l_ind].cod_cidade = ' ' then
		   exit for 
		end if 
		
		if l_ind > 1 then
		   LET l_sql = l_sql CLIPPED,", '", ma_funil_cidade[l_ind].cod_cidade clipped, "' "
		else
		   LET l_sql = l_sql CLIPPED," '", ma_funil_cidade[l_ind].cod_cidade clipped, "' "		
		end if 
		
	end for 
	
	if ma_funil_cidade[1].cod_cidade is not null and ma_funil_cidade[1].cod_cidade <> ' ' then
		LET l_sql = l_sql CLIPPED, 	") "
	end if 
	
	IF mr_tela.cod_item IS NOT NULL AND mr_tela.cod_item <> " " THEN
		LET l_sql = l_sql CLIPPED," AND a.cod_item = '",mr_tela.cod_item,"'"
	END IF

if ma_funil_item[1].cod_item is not null and ma_funil_item[1].cod_item <> ' ' then
		LET l_sql = l_sql CLIPPED," AND a.cod_item in ( " 
	end if 
	
	for l_ind = 1 to 100
		if ma_funil_item[l_ind].cod_item is null or ma_funil_item[l_ind].cod_item = ' ' then
		   exit for 
		end if 
		
		if l_ind > 1 then
		   LET l_sql = l_sql CLIPPED,", '", ma_funil_item[l_ind].cod_item clipped, "' "
		else
		   LET l_sql = l_sql CLIPPED," '", ma_funil_item[l_ind].cod_item clipped, "' "		
		end if 
		
	end for 
	
	if ma_funil_item[1].cod_item is not null and ma_funil_item[1].cod_item <> ' ' then
		LET l_sql = l_sql CLIPPED, 	") "
	end if 
	
	IF mr_tela.cod_cliente IS NOT NULL AND mr_tela.cod_cliente <> " " THEN
		LET l_sql = l_sql CLIPPED," AND a.cod_cliente = '",mr_tela.cod_cliente,"'"
	END IF
	
	
	
	
	if ma_funil_cliente[1].cod_cliente is not null and ma_funil_cliente[1].cod_cliente <> ' ' then
		LET l_sql = l_sql CLIPPED," AND a.cod_cliente in ( " 
	end if 
	
	for l_ind = 1 to 100
		if ma_funil_cliente[l_ind].cod_cliente is null or ma_funil_cliente[l_ind].cod_cliente = ' ' then
		   exit for 
		end if 
		
		if l_ind > 1 then
		   LET l_sql = l_sql CLIPPED,", '", ma_funil_cliente[l_ind].cod_cliente clipped, "' "
		else
		   LET l_sql = l_sql CLIPPED," '", ma_funil_cliente[l_ind].cod_cliente clipped, "' "		
		end if 
		
	end for 
	
	if ma_funil_cliente[1].cod_cliente is not null and ma_funil_cliente[1].cod_cliente <> ' ' then
		LET l_sql = l_sql CLIPPED, 	") "
	end if 
	
	
	
	if ma_funil_repres[1].cod_repres is not null and ma_funil_repres[1].cod_repres <> ' ' then
		LET l_sql = l_sql CLIPPED," AND a.cod_cliente IN (SELECT z.cod_cliente ",
			"  FROM geo_roteiros z, geo_rot_repres y ",
			" WHERE z.cod_empresa = y.cod_empresa ",
			"   AND z.cod_roteiro = y.cod_roteiro ",
			"   AND y.cod_repres in ( "
	end if 
	
	for l_ind = 1 to 100
		if ma_funil_repres[l_ind].cod_repres is null or ma_funil_repres[l_ind].cod_repres = ' ' then
		   exit for 
		end if 
		
		if l_ind > 1 then
		   LET l_sql = l_sql CLIPPED,", ", ma_funil_repres[l_ind].cod_repres 
		else
		   LET l_sql = l_sql CLIPPED," ", ma_funil_repres[l_ind].cod_repres		
		end if 
		
	end for 
	
	if ma_funil_repres[1].cod_repres is not null and ma_funil_repres[1].cod_repres <> ' ' then
		LET l_sql = l_sql CLIPPED, 	")   AND z.cod_empresa = '",p_cod_empresa CLIPPED,"') "
	end if 
	
	IF mr_tela.cod_repres IS NOT NULL AND mr_tela.cod_repres <> " " AND mr_tela.cod_repres <> 0 THEN
		LET l_sql = l_sql CLIPPED," AND a.cod_cliente IN (SELECT z.cod_cliente ",
			"  FROM geo_roteiros z, geo_rot_repres y ",
			" WHERE z.cod_empresa = y.cod_empresa ",
			"   AND z.cod_roteiro = y.cod_roteiro ",
			"   AND y.cod_repres = ",mr_tela.cod_repres," ",
			"   AND z.cod_empresa = '",p_cod_empresa CLIPPED,"') "
	END IF


	PREPARE var_query1 FROM l_sql
	DECLARE cq_dados1 CURSOR WITH HOLD FOR var_query1
	LET l_entrou = FALSE
	LET l_ind = 1
	FOREACH cq_dados1 INTO ma_tela[l_ind].*
	    
	    
		call geo1027_calcula_preco_desconto(l_ind)
	    
		LET l_ind = l_ind + 1
		IF l_ind > 9999 THEN
			CALL _ADVPL_message_box("Limite de 9999 registros foi atingido. Filtre sua pesquisa")
			EXIT FOREACH
		END IF
		LET l_entrou = TRUE
	END FOREACH
	IF l_ind > 1 THEN
		CALL _ADVPL_set_property(m_array.dados,"SELECT_ITEM",1,1)
		LET l_ind = l_ind - 1
	END IF

	IF NOT l_entrou THEN
		CALL _ADVPL_message_box("Argumentos de pesquisa não encontrados")
	END IF



	CALL _ADVPL_set_property(m_array.dados,"ITEM_COUNT",l_ind)
	CALL _ADVPL_set_property(m_array.dados,"REFRESH")

	RETURN TRUE
END FUNCTION

#---------------------------#
function  geo1027_cancelar_inclusao()
	#---------------------------#
	call geo1027_habilita_campos_manutencao(FALSE,'INCLUIR')
end function

#---------------------------#
function geo1027_confirmar_modificacao()
	#---------------------------#
	CALL LOG_progress_start("Processa","geo1027_processa_modificacao","PROCESS")
END FUNCTION
#---------------------------#
function geo1027_processa_modificacao()
	#---------------------------# 
	#CALL geo1027_after_row()
	CALL geo1027_habilita_campos_manutencao(FALSE,'MODIFICAR')
	CALL geo1027_atualiza_dados('MODIFICACAO')
	RETURN TRUE
end function
#
#---------------------------#
function  geo1027_cancelar_modificacao()
	#---------------------------#
	CALL geo1027_habilita_campos_manutencao(FALSE,'MODIFICAR')
	INITIALIZE ma_tela TO NULL
	LET ma_tela = ma_telae
	CALL _ADVPL_set_property(m_array.dados,"REFRESH")
end function

#----------------------------------------------#
function geo1027_atualiza_dados(l_funcao)
	#----------------------------------------------#
	DEFINE l_funcao char(20)
	DEFINE l_ind    integer
	DEFINE l_data   date
	DEFINE l_hora   char(8)
	DEFINE l_roteiro    SMALLINT
	DEFINE lr_roteiros RECORD
		cod_empresa CHAR(2),
		cod_roteiro INTEGER,
		seq_visita  INTEGER,
		cod_cliente CHAR(15)
END RECORD

CALL log085_transacao('BEGIN')

FOR l_ind = 1 TO _ADVPL_get_property(m_array.dados,"ITEM_COUNT")
	IF ma_tela[l_ind].cod_cliente IS NULL OR ma_tela[l_ind].cod_cliente = " " THEN
		CONTINUE FOR
	END IF

	IF ma_tela[l_ind].cod_item IS NULL OR ma_tela[l_ind].cod_item = " " THEN
		CONTINUE FOR
	END IF

	DELETE
	FROM geo_desc_lista
	WHERE cod_empresa = p_cod_empresa
	AND cod_cliente = ma_tela[l_ind].cod_cliente
	AND cod_item = ma_tela[l_ind].cod_item
	IF sqlca.sqlcode <> 0 THEN
		CALL log085_transacao('ROLLBACK')
		CALL log003_err_sql("DELETE","geo_desc_lista")
		RETURN FALSE
	END IF

	INSERT INTO geo_desc_lista (cod_empresa,cod_cliente,cod_item,desc_especial,pct_desc,pct_desc_adic,dat_final_desc) VALUES (p_cod_empresa,
		ma_tela[l_ind].cod_cliente,
		ma_tela[l_ind].cod_item,
		ma_tela[l_ind].desc_especial,
		ma_tela[l_ind].pct_desc,
		ma_tela[l_ind].pct_desc_adic,
		ma_tela[l_ind].dat_final_desc)
	IF sqlca.sqlcode <> 0 THEN
		CALL log085_transacao('ROLLBACK')
		CALL log003_err_sql("INSERT","geo_desc_lista")
		RETURN FALSE
	END IF

END FOR

CALL log085_transacao('COMMIT')
RETURN TRUE

END FUNCTION

#----------------------------------------------#
function geo1027_habilita_campos_manutencao(l_status,l_funcao)
	#----------------------------------------------#

	DEFINE l_status smallint

	define l_funcao char(20)
CASE l_funcao
	WHEN 'CONSULTAR'
	CALL _ADVPL_set_property(m_refer.cod_repres,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.zoom_repres,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.funil_repres,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.funil_cidade,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.cod_cliente,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.zoom_cliente,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.funil_cliente,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.cod_item,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.zoom_item,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.funil_item,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.cod_cidade,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.zoom_cidade,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.pct_desc_de,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.pct_desc_ate,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_de,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_ate,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.desc_especial,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.ies_suspenso,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.num_list_preco,"ENABLE",l_status)
		
		
	CALL _ADVPL_set_property(m_refer.ies_novo,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.ies_inativo,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.ies_cancelado,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.ies_ativo,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_array.zoom_cliente,"EDITABLE",FALSE)
	CALL _ADVPL_set_property(m_array.zoom_item,"EDITABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.dat_final_desc_de,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.dat_final_desc_ate,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.cep_de,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_refer.cep_ate,"ENABLE",l_status)
		#CALL _ADVPL_set_property(m_array.dados,"EDITABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.aplica_listagem,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_array.dados,"CAN_ADD_ROW",FALSE)
	CALL _ADVPL_set_property(m_array.dados,"CAN_REMOVE_ROW",FALSE)
	WHEN 'MODIFICAR'
	CALL _ADVPL_set_property(m_refer.cod_repres,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.zoom_repres,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.funil_repres,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.funil_cidade,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cod_cliente,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.zoom_cliente,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.funil_cliente,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cod_item,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.zoom_item,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.funil_item,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cod_cidade,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.zoom_cidade,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.pct_desc_de,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.pct_desc_ate,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_de,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_ate,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.desc_especial,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.dat_final_desc_de,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.dat_final_desc_ate,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cep_de,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cep_ate,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.ies_suspenso,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.num_list_preco,"ENABLE",FALSE)
		
	CALL _ADVPL_set_property(m_refer.ies_novo,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.ies_inativo,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.ies_cancelado,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.ies_ativo,"ENABLE",FALSE)
		#CALL _ADVPL_set_property(m_array.dados,"EDITABLE",l_status)
		 
	CALL _ADVPL_set_property(m_array.cod_cliente,"EDITABLE",FALSE)
	CALL _ADVPL_set_property(m_array.cod_item,"EDITABLE",FALSE)
	CALL _ADVPL_set_property(m_array.zoom_cliente,"EDITABLE",l_status)
	CALL _ADVPL_set_property(m_array.zoom_item,"EDITABLE",l_status)
	CALL _ADVPL_set_property(m_array.desc_especial,"EDITABLE",l_status)
	CALL _ADVPL_set_property(m_array.pct_desc,"EDITABLE",l_status)
	CALL _ADVPL_set_property(m_array.pct_desc_adic,"EDITABLE",l_status)
	CALL _ADVPL_set_property(m_array.dat_final_desc,"EDITABLE",l_status)
	CALL _ADVPL_set_property(m_refer.aplica_listagem,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_array.dados,"CAN_ADD_ROW",FALSE)
	CALL _ADVPL_set_property(m_array.dados,"CAN_REMOVE_ROW",l_status)
	WHEN 'INCLUIR'
	CALL _ADVPL_set_property(m_refer.cod_repres,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.zoom_repres,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.funil_repres,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.funil_cidade,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cod_cliente,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.zoom_cliente,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.funil_cliente,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cod_item,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.zoom_item,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.funil_item,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cod_cidade,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.zoom_cidade,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.pct_desc_de,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.pct_desc_ate,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_de,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.pct_desc_adic_ate,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.desc_especial,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.dat_final_desc_de,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.dat_final_desc_ate,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cep_de,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.cep_ate,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.ies_suspenso,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.num_list_preco,"ENABLE",FALSE)
		
		
	CALL _ADVPL_set_property(m_refer.ies_novo,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.ies_inativo,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.ies_cancelado,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer.ies_ativo,"ENABLE",FALSE)
		#CALL _ADVPL_set_property(m_array.dados,"EDITABLE",l_status) 
		 
	CALL _ADVPL_set_property(m_array.cod_cliente,"EDITABLE",l_status)
	CALL _ADVPL_set_property(m_array.cod_item,"EDITABLE",l_status)
	CALL _ADVPL_set_property(m_array.desc_especial,"EDITABLE",l_status)
	CALL _ADVPL_set_property(m_array.pct_desc,"EDITABLE",l_status)
	CALL _ADVPL_set_property(m_array.zoom_cliente,"EDITABLE",l_status)
	CALL _ADVPL_set_property(m_array.zoom_item,"EDITABLE",l_status)
	CALL _ADVPL_set_property(m_array.pct_desc_adic,"EDITABLE",l_status)
	CALL _ADVPL_set_property(m_array.dat_final_desc,"EDITABLE",l_status)
	CALL _ADVPL_set_property(m_refer.aplica_listagem,"ENABLE",l_status)
	CALL _ADVPL_set_property(m_array.dados,"CAN_ADD_ROW",l_status)
	CALL _ADVPL_set_property(m_array.dados,"CAN_REMOVE_ROW",l_status)

END CASE

END FUNCTION

#--------------------------------------------------------------------#
function geo1027_cancela_pesquisar()
	#--------------------------------------------------------------------#
	CALL geo1027_habilita_campos_manutencao(FALSE,'CONSULTAR')
end function
#-------------------------------------#
FUNCTION geo1027_primeiro()
	#-------------------------------------#
	CALL geo1027_paginacao("PRIMEIRO")
end function

#-------------------------------------#
FUNCTION geo1027_anterior()
	#-------------------------------------#
	CALL geo1027_paginacao("ANTERIOR")
end function

#-------------------------------------#
FUNCTION geo1027_seguinte()
	#-------------------------------------#
	CALL geo1027_paginacao("SEGUINTE")
end function

#-------------------------------------#
FUNCTION geo1027_ultimo()
	#-------------------------------------#
	CALL geo1027_paginacao("ULTIMO")
end function

#
#-------------------------------------#
FUNCTION geo1027_paginacao(l_funcao)
	#-------------------------------------#

	DEFINE l_funcao    CHAR(10),
		l_status    SMALLINT

	LET l_funcao = l_funcao CLIPPED

	let mr_telar.* = mr_tela.*

	IF m_ies_consulta THEN


		{    WHILE TRUE
		CASE
		WHEN l_funcao = "SEGUINTE"

		FETCH NEXT cq_consulta INTO mr_tela.cod_empresa ,
		mr_tela.cod_repres    

		IF sqlca.sqlcode <> 0 THEN
		#CALL log003_err_sql ("NEXT","cq_orcamentos")
		#EXIT WHILE
		END IF

		WHEN l_funcao = "ANTERIOR"

		FETCH PREVIOUS cq_consulta INTO mr_tela.cod_empresa ,
		mr_tela.cod_repres  

		IF sqlca.sqlcode <> 0 THEN
		#CALL log003_err_sql ("PREVIOUS","cq_orcamentos")
		#EXIT WHILE
		END IF

		WHEN l_funcao = "PRIMEIRO"

		FETCH FIRST cq_consulta INTO mr_tela.cod_empresa ,
		mr_tela.cod_repres  

		IF sqlca.sqlcode <> 0 THEN
		#CALL log003_err_sql ("FIRST","cq_orcamentos")
		#EXIT WHILE
		END IF

		WHEN l_funcao = "ULTIMO"

		FETCH LAST cq_consulta INTO mr_tela.cod_empresa ,
		mr_tela.cod_repres  

		IF sqlca.sqlcode <> 0 THEN
		#CALL log003_err_sql ("LAST","cq_orcamentos")
		#EXIT WHILE
		END IF
		END CASE
		IF sqlca.sqlcode = NOTFOUND THEN
		CALL geo1027_exibe_mensagem_barra_status("Não existem mais itens nesta direcao.","ERRO")
		let mr_tela.* = mr_telar.*
		EXIT WHILE
		ELSE
		LET m_ies_consulta = TRUE
		END IF

		select cod_empresa, cod_repres 
		INTO mr_tela.cod_empresa ,
		mr_tela.cod_repres  
		from geo_rot_repres
		where cod_empresa  = p_cod_empresa
		and cod_repres    = mr_tela.cod_repres 
		group by cod_empresa, cod_repres  

		IF sqlca.sqlcode = 0 THEN

		EXIT WHILE

		END IF

		END WHILE}
	ELSE
		CALL geo1027_exibe_mensagem_barra_status("Efetue primeiramente a consulta.","ERRO")
	END IF


	CALL geo1027_exibe_dados()

END FUNCTION

#--------------------------------------------------------------------#
FUNCTION geo1027_exibe_mensagem_barra_status(l_mensagem,l_tipo_mensagem)
	#--------------------------------------------------------------------#

	DEFINE l_mensagem               CHAR(500),
		l_tipo_mensagem          CHAR(010),
		l_tipo_mensagem_original CHAR(015)

	LET l_tipo_mensagem_original = LOG_retorna_tipo_mensagem_original(UPSHIFT(l_tipo_mensagem),TRUE)
	CALL _ADVPL_set_property(m_layout.status_bar,l_tipo_mensagem_original CLIPPED," "||l_mensagem CLIPPED)

END FUNCTION


#--------------------------------------------------------------------#
function geo1027_exibe_dados()
	#--------------------------------------------------------------------#

	define l_seq_visita   integer
	define l_cod_roteiro  decimal(4,0)
	define l_den_roteiro  char(30)

	define l_ind          integer


	CALL _ADVPL_set_property(m_array.dados,"ITEM_COUNT",l_ind)
	CALL _ADVPL_set_property(m_array.dados,"REFRESH")

end function

#-----------------------------------#
FUNCTION geo1027_valid_cod_cliente1()
	#-----------------------------------#
	IF mr_tela.cod_cliente IS NOT NULL AND mr_tela.cod_cliente <> " " THEN
		SELECT nom_cliente
		INTO mr_tela.nom_cliente
		FROM clientes
		WHERE cod_cliente = mr_tela.cod_cliente
		IF sqlca.sqlcode = NOTFOUND THEN
			CALL _ADVPL_message_box("Cliente não encontrado")
			RETURN FALSE
		END IF
	END IF

	RETURN TRUE
END FUNCTION


#-----------------------------------#
FUNCTION geo1027_valid_cod_repres1()
	#-----------------------------------#
	IF mr_tela.cod_repres IS NOT NULL AND mr_tela.cod_repres <> " " AND mr_tela.cod_repres <> 0 THEN
		SELECT raz_social
		INTO mr_tela.raz_social
		FROM representante
		WHERE cod_repres = mr_tela.cod_repres
		IF sqlca.sqlcode = NOTFOUND THEN
			CALL _ADVPL_message_box("Representante não encontrado")
			RETURN FALSE
		END IF
	END IF

	RETURN TRUE
END FUNCTION



#-----------------------------------#
FUNCTION geo1027_valid_cod_item4()
	#-----------------------------------#
	DEFINE l_arr_curr        SMALLINT
    
	LET l_arr_curr = _ADVPL_get_property(m_refer_tabela_funil,"ITEM_SELECTED")

	IF ma_funil_item[l_arr_curr].cod_item IS NOT NULL AND ma_funil_item[l_arr_curr].cod_item <> " "  THEN
	
		SELECT den_item
		FROM item
		WHERE cod_item = ma_funil_item[l_arr_curr].cod_item
		AND cod_empresa = p_cod_empresa
		IF sqlca.sqlcode = NOTFOUND THEN
			CALL _ADVPL_message_box("Item não encontrado")
			RETURN FALSE
		END IF
	END IF

	RETURN TRUE
END FUNCTION



#-----------------------------------#
FUNCTION geo1027_valid_cod_cidade3()
	#-----------------------------------#
	DEFINE l_arr_curr        SMALLINT
    
	LET l_arr_curr = _ADVPL_get_property(m_refer_tabela_funil,"ITEM_SELECTED")



	IF ma_funil_cidade[l_arr_curr].cod_cidade IS NOT NULL AND ma_funil_cidade[l_arr_curr].cod_cidade <> " " THEN
		
		SELECT den_cidade 
		FROM cidades
		WHERE cod_cidade = ma_funil_cidade[l_arr_curr].cod_cidade
		IF sqlca.sqlcode = NOTFOUND THEN
			CALL _ADVPL_message_box("Cidade não encontrado")
			RETURN FALSE
		END IF
	END IF

	RETURN TRUE
END FUNCTION


#-----------------------------------#
FUNCTION geo1027_valid_cod_cliente4()
	#-----------------------------------#
	
	DEFINE l_arr_curr        SMALLINT
    
	LET l_arr_curr = _ADVPL_get_property(m_refer_tabela_funil,"ITEM_SELECTED")


	IF ma_funil_cliente[l_arr_curr].cod_cliente IS NOT NULL AND ma_funil_cliente[l_arr_curr].cod_cliente <> " "  THEN
		SELECT nom_cliente 
		FROM clientes
		WHERE cod_cliente = ma_funil_cliente[l_arr_curr].cod_cliente
		IF sqlca.sqlcode = NOTFOUND THEN
			CALL _ADVPL_message_box("Cliente não encontrado")
			RETURN FALSE
		END IF
	END IF

	RETURN TRUE
END FUNCTION


#-----------------------------------#
FUNCTION geo1027_valid_cod_repres3()
	#-----------------------------------#

DEFINE l_arr_curr        SMALLINT
    
	LET l_arr_curr = _ADVPL_get_property(m_refer_tabela_funil,"ITEM_SELECTED")

	IF ma_funil_repres[l_arr_curr].cod_repres IS NOT NULL AND ma_funil_repres[l_arr_curr].cod_repres <> " " AND ma_funil_repres[l_arr_curr].cod_repres <> 0 THEN
		SELECT raz_social 
		FROM representante
		WHERE cod_repres = ma_funil_repres[l_arr_curr].cod_repres
		IF sqlca.sqlcode = NOTFOUND THEN
			CALL _ADVPL_message_box("Representante não encontrado")
			RETURN FALSE
		END IF
	END IF

	RETURN TRUE
END FUNCTION

#-----------------------------------#
FUNCTION geo1027_valid_cod_cliente2()
	#-----------------------------------#
	DEFINE l_arr_curr        SMALLINT
    
	LET l_arr_curr = _ADVPL_get_property(m_array.dados,"ITEM_SELECTED")

	if ma_tela[l_arr_curr].cod_cliente is null or ma_tela[l_arr_curr].cod_cliente = '' then
		return true
	end if
    
	SELECT nom_cliente
	INTO ma_tela[l_arr_curr].nom_cliente
	FROM clientes
	WHERE cod_cliente = ma_tela[l_arr_curr].cod_cliente
	IF sqlca.sqlcode = NOTFOUND THEN
		CALL _ADVPL_message_box("Cliente não encontrado")
		RETURN FALSE
	END IF

	RETURN TRUE
END FUNCTION

#-----------------------------------#
FUNCTION geo1027_valid_cod_cidade()
	#-----------------------------------#
	IF mr_tela.cod_cidade IS NOT NULL AND mr_tela.cod_cidade <> " " THEN
		SELECT den_cidade
		INTO mr_tela.den_cidade
		FROM cidades
		WHERE cod_cidade = mr_tela.cod_cidade
		IF sqlca.sqlcode = NOTFOUND THEN
			CALL _ADVPL_message_box("Cidade não encontrado")
			RETURN FALSE
		END IF
	END IF

	RETURN TRUE
END FUNCTION

#-----------------------------------#
FUNCTION geo1027_valid_cod_item1()
	#-----------------------------------#
	IF mr_tela.cod_item IS NOT NULL AND mr_tela.cod_item <> " " THEN
		SELECT den_item
		INTO mr_tela.den_item
		FROM item
		WHERE cod_item = mr_tela.cod_item
		AND cod_empresa = p_cod_empresa
		IF sqlca.sqlcode = NOTFOUND THEN
			CALL _ADVPL_message_box("Item não encontrado")
			RETURN FALSE
		END IF
	END IF

	RETURN TRUE
END FUNCTION

#-----------------------------------#
FUNCTION geo1027_valid_cod_item2()
	#-----------------------------------#
	DEFINE l_arr_curr        SMALLINT

	LET l_arr_curr = _ADVPL_get_property(m_array.dados,"ITEM_SELECTED")

	SELECT den_item
	INTO ma_tela[l_arr_curr].den_item
	FROM item
	WHERE cod_item = ma_tela[l_arr_curr].cod_item
	AND cod_empresa = p_cod_empresa
	IF sqlca.sqlcode = NOTFOUND THEN
		CALL _ADVPL_message_box("Item não encontrado")
		RETURN FALSE
	END IF

	RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION geo1027_dialog()
	#-------------------------#
	DEFINE l_layout             RECORD
		panel1             VARCHAR(50),
		form_principal     VARCHAR(50),
		toolbar            VARCHAR(50),
		status_bar         VARCHAR(50)
END RECORD
DEFINE l_refer              RECORD
	aplica1         VARCHAR(50),
	aplica2         VARCHAR(50),
	aplica3         VARCHAR(50),
	aplica4         VARCHAR(50),
	aplica5         VARCHAR(50),
	aplica6         VARCHAR(50),
	desc_especial   VARCHAR(50),
	pct_desc        VARCHAR(50),
	pct_desc_adic   VARCHAR(50),
	pct_desc_ind    VARCHAR(50),
	pct_desc_adic_ind VARCHAR(50),
	dat_final_desc  VARCHAR(50)
END RECORD
DEFINE l_panel1               VARCHAR(50)
DEFINE l_panel2               VARCHAR(50)
DEFINE l_fieldset1            VARCHAR(50)
DEFINE l_fieldset2            VARCHAR(50)
DEFINE l_layout1              VARCHAR(50)
DEFINE l_layout2              VARCHAR(50)
DEFINE l_label                VARCHAR(50)

LET mr_dialog.desc_especial = "N"
LET mr_dialog.pct_desc = 0
LET mr_dialog.pct_desc_adic = 0
LET mr_dialog.dat_final_desc = TODAY

	#cria janela principal do tipo LDIALOG
LET l_layout.form_principal = _ADVPL_create_component(NULL,"LDIALOG")
CALL _ADVPL_set_property(l_layout.form_principal,"TITLE","LISTA DE DESCONTOS")
CALL _ADVPL_set_property(l_layout.form_principal,"ENABLE_ESC_CLOSE",FALSE)
CALL _ADVPL_set_property(l_layout.form_principal,"SIZE",600,250)#   1024,725)


	#cria panel para campos de filtro 
LET l_layout.panel1 = _ADVPL_create_component(NULL,"LPANEL",l_layout.form_principal)
CALL _ADVPL_set_property(l_layout.panel1,"ALIGN","TOP")
CALL _ADVPL_set_property(l_layout.panel1,"HEIGHT",400)

	#cria panel  
LET l_panel1 = _ADVPL_create_component(NULL,"LPANEL",l_layout.panel1)
CALL _ADVPL_set_property(l_panel1,"HEIGHT",200)
CALL _ADVPL_set_property(l_panel1,"ALIGN","TOP")

	#cria panel  
LET l_fieldset1 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel1)
CALL _ADVPL_set_property(l_fieldset1,"TITLE","APLICAR NA LISTAGEM")
CALL _ADVPL_set_property(l_fieldset1,"ALIGN","CENTER")

LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
CALL _ADVPL_set_property(l_label,"TEXT","Desconto Especial:")
CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
CALL _ADVPL_set_property(l_label,"POSITION",20,30)

	#cod_item
LET l_refer.desc_especial = _ADVPL_create_component(NULL,"LCHECKBOX",l_panel1)
CALL _ADVPL_set_property(l_refer.desc_especial,"VARIABLE",mr_dialog,"desc_especial")
CALL _ADVPL_set_property(l_refer.desc_especial,"ENABLE",TRUE)
CALL _ADVPL_set_property(l_refer.desc_especial,"POSITION",130,30)
CALL _ADVPL_set_property(l_refer.desc_especial,"VALUE_CHECKED","S")
CALL _ADVPL_set_property(l_refer.desc_especial,"VALUE_NCHECKED","N")

LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
CALL _ADVPL_set_property(l_label,"TEXT","Faixa % Desc:")
CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
CALL _ADVPL_set_property(l_label,"POSITION",20,60)

	#cod_item
LET l_refer.pct_desc = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel1)
CALL _ADVPL_set_property(l_refer.pct_desc,"LENGTH",4,2)
CALL _ADVPL_set_property(l_refer.pct_desc,"VARIABLE",mr_dialog,"pct_desc")
CALL _ADVPL_set_property(l_refer.pct_desc,"ENABLE",TRUE)
CALL _ADVPL_set_property(l_refer.pct_desc,"POSITION",130,60)

LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
CALL _ADVPL_set_property(l_label,"TEXT","Faixa % Desc Por Indice:")
CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
CALL _ADVPL_set_property(l_label,"POSITION",20,90)

	#cod_item
LET l_refer.pct_desc_ind = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel1)
CALL _ADVPL_set_property(l_refer.pct_desc_ind,"LENGTH",4,2)
CALL _ADVPL_set_property(l_refer.pct_desc_ind,"VARIABLE",mr_dialog,"pct_desc_ind")
CALL _ADVPL_set_property(l_refer.pct_desc_ind,"ENABLE",TRUE)
CALL _ADVPL_set_property(l_refer.pct_desc_ind,"POSITION",130,90)

LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
CALL _ADVPL_set_property(l_label,"TEXT","Faixa % Desc Adic:")
CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
CALL _ADVPL_set_property(l_label,"POSITION",20,120)

	#cod_item
LET l_refer.pct_desc_adic = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel1)
CALL _ADVPL_set_property(l_refer.pct_desc_adic,"LENGTH",4,2)
CALL _ADVPL_set_property(l_refer.pct_desc_adic,"VARIABLE",mr_dialog,"pct_desc_adic")
CALL _ADVPL_set_property(l_refer.pct_desc_adic,"ENABLE",TRUE)
CALL _ADVPL_set_property(l_refer.pct_desc_adic,"POSITION",130,120)

LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
CALL _ADVPL_set_property(l_label,"TEXT","Faixa % Desc Adic Por Indice:")
CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
CALL _ADVPL_set_property(l_label,"POSITION",20,150)

	#cod_item
LET l_refer.pct_desc_adic_ind = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel1)
CALL _ADVPL_set_property(l_refer.pct_desc_adic_ind,"LENGTH",4,2)
CALL _ADVPL_set_property(l_refer.pct_desc_adic_ind,"VARIABLE",mr_dialog,"pct_desc_adic_ind")
CALL _ADVPL_set_property(l_refer.pct_desc_adic_ind,"ENABLE",TRUE)
CALL _ADVPL_set_property(l_refer.pct_desc_adic_ind,"POSITION",130,150)

LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel1)
CALL _ADVPL_set_property(l_label,"TEXT","Data Final Desconto:")
CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
CALL _ADVPL_set_property(l_label,"POSITION",20,180)

	#cod_item
LET l_refer.dat_final_desc = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel1)
CALL _ADVPL_set_property(l_refer.dat_final_desc,"VARIABLE",mr_dialog,"dat_final_desc")
CALL _ADVPL_set_property(l_refer.dat_final_desc,"ENABLE",TRUE)
CALL _ADVPL_set_property(l_refer.dat_final_desc,"POSITION",130,180)

LET l_refer.aplica1 = _ADVPL_create_component(NULL, "LBUTTON", l_panel1)
CALL _ADVPL_set_property(l_refer.aplica1,"TEXT", "Aplicar")
CALL _ADVPL_set_property(l_refer.aplica1,"CLICK_EVENT","geo1027_aplica_desc_especial")
CALL _ADVPL_set_property(l_refer.aplica1,"ENABLE",TRUE)
CALL _ADVPL_set_property(l_refer.aplica1,"SIZE",130,25)
CALL _ADVPL_set_property(l_refer.aplica1,"POSITION",300,30)

LET l_refer.aplica2 = _ADVPL_create_component(NULL, "LBUTTON", l_panel1)
CALL _ADVPL_set_property(l_refer.aplica2,"TEXT", "Aplicar")
CALL _ADVPL_set_property(l_refer.aplica2,"CLICK_EVENT","geo1027_aplica_pct_desc")
CALL _ADVPL_set_property(l_refer.aplica2,"ENABLE",TRUE)
CALL _ADVPL_set_property(l_refer.aplica2,"SIZE",130,25)
CALL _ADVPL_set_property(l_refer.aplica2,"POSITION",300,60)

LET l_refer.aplica5 = _ADVPL_create_component(NULL, "LBUTTON", l_panel1)
CALL _ADVPL_set_property(l_refer.aplica5,"TEXT", "Aplicar")
CALL _ADVPL_set_property(l_refer.aplica5,"CLICK_EVENT","geo1027_aplica_pct_desc_ind")
CALL _ADVPL_set_property(l_refer.aplica5,"ENABLE",TRUE)
CALL _ADVPL_set_property(l_refer.aplica5,"SIZE",130,25)
CALL _ADVPL_set_property(l_refer.aplica5,"POSITION",300,90)

LET l_refer.aplica3 = _ADVPL_create_component(NULL, "LBUTTON", l_panel1)
CALL _ADVPL_set_property(l_refer.aplica3,"TEXT", "Aplicar")
CALL _ADVPL_set_property(l_refer.aplica3,"CLICK_EVENT","geo1027_aplica_pct_desc_adic")
CALL _ADVPL_set_property(l_refer.aplica3,"ENABLE",TRUE)
CALL _ADVPL_set_property(l_refer.aplica3,"SIZE",130,25)
CALL _ADVPL_set_property(l_refer.aplica3,"POSITION",300,120)

LET l_refer.aplica6 = _ADVPL_create_component(NULL, "LBUTTON", l_panel1)
CALL _ADVPL_set_property(l_refer.aplica6,"TEXT", "Aplicar")
CALL _ADVPL_set_property(l_refer.aplica6,"CLICK_EVENT","geo1027_aplica_pct_desc_adic_ind")
CALL _ADVPL_set_property(l_refer.aplica6,"ENABLE",TRUE)
CALL _ADVPL_set_property(l_refer.aplica6,"SIZE",130,25)
CALL _ADVPL_set_property(l_refer.aplica6,"POSITION",300,150)

LET l_refer.aplica4 = _ADVPL_create_component(NULL, "LBUTTON", l_panel1)
CALL _ADVPL_set_property(l_refer.aplica4,"TEXT", "Aplicar")
CALL _ADVPL_set_property(l_refer.aplica4,"CLICK_EVENT","geo1027_aplica_dat_final_desc")
CALL _ADVPL_set_property(l_refer.aplica4,"ENABLE",TRUE)
CALL _ADVPL_set_property(l_refer.aplica4,"SIZE",130,25)
CALL _ADVPL_set_property(l_refer.aplica4,"POSITION",300,180)

CALL _ADVPL_set_property(l_layout.form_principal,"ACTIVATE",TRUE)
END FUNCTION


#--------------------------------------#
FUNCTION geo1027_aplica_desc_especial()
	#--------------------------------------#
	DEFINE l_ind             SMALLINT

	FOR l_ind = 1 TO _ADVPL_get_property(m_array.dados,"ITEM_COUNT")
		LET ma_tela[l_ind].desc_especial = mr_dialog.desc_especial
	END FOR

	CALL _ADVPL_set_property(m_array.dados,"REFRESH")
END FUNCTION

#--------------------------------------#
FUNCTION geo1027_aplica_pct_desc()
	#--------------------------------------#
	DEFINE l_ind             SMALLINT

	FOR l_ind = 1 TO _ADVPL_get_property(m_array.dados,"ITEM_COUNT")
		LET ma_tela[l_ind].pct_desc = mr_dialog.pct_desc
	END FOR

	CALL _ADVPL_set_property(m_array.dados,"REFRESH")
END FUNCTION
#--------------------------------------#
FUNCTION geo1027_aplica_pct_desc_ind()
	#--------------------------------------#
	DEFINE l_ind             SMALLINT

	FOR l_ind = 1 TO _ADVPL_get_property(m_array.dados,"ITEM_COUNT")
		LET ma_tela[l_ind].pct_desc = ma_tela[l_ind].pct_desc * mr_dialog.pct_desc_ind
	END FOR

	CALL _ADVPL_set_property(m_array.dados,"REFRESH")
END FUNCTION

#--------------------------------------#
FUNCTION geo1027_aplica_pct_desc_adic()
	#--------------------------------------#
	DEFINE l_ind             SMALLINT

	FOR l_ind = 1 TO _ADVPL_get_property(m_array.dados,"ITEM_COUNT")
		LET ma_tela[l_ind].pct_desc_adic = mr_dialog.pct_desc_adic
	END FOR

	CALL _ADVPL_set_property(m_array.dados,"REFRESH")
END FUNCTION
#--------------------------------------#
FUNCTION geo1027_aplica_pct_desc_adic_ind()
	#--------------------------------------#
	DEFINE l_ind             SMALLINT

	FOR l_ind = 1 TO _ADVPL_get_property(m_array.dados,"ITEM_COUNT")
		LET ma_tela[l_ind].pct_desc_adic = ma_tela[l_ind].pct_desc_adic * mr_dialog.pct_desc_adic_ind
	END FOR

	CALL _ADVPL_set_property(m_array.dados,"REFRESH")
END FUNCTION

#--------------------------------------#
FUNCTION geo1027_aplica_dat_final_desc()
	#--------------------------------------#
	DEFINE l_ind             SMALLINT

	FOR l_ind = 1 TO _ADVPL_get_property(m_array.dados,"ITEM_COUNT")
		LET ma_tela[l_ind].dat_final_desc = mr_dialog.dat_final_desc
	END FOR

	CALL _ADVPL_set_property(m_array.dados,"REFRESH")
END FUNCTION

#--------------------------#
FUNCTION geo1027_incluir()
	#--------------------------#
	DEFINE l_ind SMALLINT
	INITIALIZE ma_tela TO NULL

	FOR l_ind = 1 TO 999
		LET ma_tela[l_ind].desc_especial = "N"
	END FOR

	CALL _ADVPL_set_property(m_array.dados,"ITEM_COUNT",1)
	CALL _ADVPL_set_property(m_array.dados,"REFRESH")

	CALL geo1027_habilita_campos_manutencao(TRUE, "INCLUIR")
END FUNCTION

#-----------------------------------#
FUNCTION geo1027_confirmar_incluir()
	#-----------------------------------#
	CALL geo1027_habilita_campos_manutencao(FALSE, "INCLUIR")
	CALL geo1027_atualiza_dados("INCLUIR")
END FUNCTION

#-----------------------------------#
FUNCTION geo1027_cancelar_incluir()
	#-----------------------------------#
	CALL geo1027_habilita_campos_manutencao(FALSE, "INCLUIR")
	INITIALIZE ma_tela TO NULL
	CALL _ADVPL_set_property(m_array.dados,"REFRESH")
END FUNCTION


#---------------------------------------#
function geo1027_zoom_repres()
	#---------------------------------------#
	DEFINE l_where_clause   CHAR(1000)
	DEFINE l_ind            SMALLINT
	define l_zoom_item varchar(10)
	define l_selecao integer
	define l_cod_cliente char(15)

	FOR l_ind = 1 TO 1000
		INITIALIZE ma_resp3[l_ind].* TO NULL
	END FOR

	LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
	CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
	CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_resp3)
		CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_representante")

	let mr_tela.cod_repres = ma_resp3[1].cod_repres
	let mr_tela.raz_social = ma_resp3[1].raz_social

end function


#---------------------------------------#
function geo1027_zoom_clientes4()
	#---------------------------------------#
	DEFINE l_where_clause   CHAR(1000)
	DEFINE l_ind            SMALLINT
	define l_zoom_item varchar(10)
	define l_selecao integer
	define l_cod_cliente char(15)
	DEFINE l_arr_curr    SMALLINT
 
    

	FOR l_ind = 1 TO 1000
		INITIALIZE ma_resp[l_ind].* TO NULL
	END FOR

	LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
	CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
	CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_resp)
	CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_clientes")
		
	for l_arr_curr = 1 to 999
		if ma_funil_cliente[l_arr_curr].cod_cliente is null or ma_funil_cliente[l_arr_curr].cod_cliente = '' then
		   exit for 
		end if
	end for 
	for l_ind = 1 to 999
		if ma_resp[l_ind].cod_cliente is null or ma_resp[l_ind].cod_cliente = '' then
		   exit for 
		end if
		let ma_funil_cliente[l_arr_curr].cod_cliente = ma_resp[l_ind].cod_cliente
		let l_arr_curr = l_arr_curr + 1
	end for
	let l_arr_curr = l_arr_curr - 1
	
	
	CALL _ADVPL_set_property(m_refer_tabela_funil,"ITEM_COUNT",l_arr_curr)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"REFRESH")
	 
end FUNCTION


#---------------------------------------#
function geo1027_zoom_item4()
	#---------------------------------------#
	DEFINE l_where_clause   CHAR(1000)
	DEFINE l_ind            SMALLINT
	define l_zoom_item varchar(10)
	define l_selecao integer
	define l_cod_cliente char(15)

	DEFINE l_arr_curr        SMALLINT
	
	FOR l_ind = 1 TO 1000
		INITIALIZE ma_resp2[l_ind].* TO NULL
	END FOR

	LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
	CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
	CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_resp2)
		CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_item")


    for l_arr_curr = 1 to 999
		if ma_funil_item[l_arr_curr].cod_item is null or ma_funil_item[l_arr_curr].cod_item = '' then
		   exit for 
		end if
	end for 
	for l_ind = 1 to 999
		if ma_resp2[l_ind].cod_item is null or ma_resp2[l_ind].cod_item = '' then
		   exit for 
		end if
		let ma_funil_item[l_arr_curr].cod_item = ma_resp2[l_ind].cod_item
		let l_arr_curr = l_arr_curr + 1
	end for
	let l_arr_curr = l_arr_curr - 1
	
	CALL _ADVPL_set_property(m_refer_tabela_funil,"ITEM_COUNT",l_arr_curr)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"REFRESH")
 
end function

#---------------------------------------#
function geo1027_zoom_cidade3()
	#---------------------------------------#
	DEFINE l_where_clause   CHAR(1000)
	DEFINE l_ind            SMALLINT
	define l_zoom_item varchar(10)
	define l_selecao integer
	define l_cod_cliente char(15)

	DEFINE l_arr_curr        SMALLINT
	
	FOR l_ind = 1 TO 1000
		INITIALIZE ma_zcidade[l_ind].* TO NULL
	END FOR

	LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
	CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
	CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_zcidade)
	CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_cidades")

    for l_arr_curr = 1 to 999
		if ma_funil_cidade[l_arr_curr].cod_cidade is null or ma_funil_cidade[l_arr_curr].cod_cidade = '' then
		   exit for 
		end if
	end for 
	for l_ind = 1 to 999
		if ma_zcidade[l_ind].cod_cidade is null or ma_zcidade[l_ind].cod_cidade = '' then
		   exit for 
		end if
		let ma_funil_cidade[l_arr_curr].cod_cidade = ma_zcidade[l_ind].cod_cidade
		let l_arr_curr = l_arr_curr + 1
	end for
	let l_arr_curr = l_arr_curr - 1
	
	CALL _ADVPL_set_property(m_refer_tabela_funil,"ITEM_COUNT",l_arr_curr)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"REFRESH")
	 
 
end function


#---------------------------------------#
function geo1027_zoom_repres3()
	#---------------------------------------#
	DEFINE l_where_clause   CHAR(1000)
	DEFINE l_ind            SMALLINT
	define l_zoom_item varchar(10)
	define l_selecao integer
	define l_cod_cliente char(15)
	
	
	DEFINE l_arr_curr        SMALLINT
    

	FOR l_ind = 1 TO 1000
		INITIALIZE ma_resp3[l_ind].* TO NULL
	END FOR

	LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
	CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
	CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_resp3)
		CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_representante")
	for l_arr_curr = 1 to 999
		if ma_funil_repres[l_arr_curr].cod_repres is null or ma_funil_repres[l_arr_curr].cod_repres = '' then
		   exit for 
		end if
	end for 
	for l_ind = 1 to 999
		if ma_resp3[l_ind].cod_repres is null or ma_resp3[l_ind].cod_repres = '' then
		   exit for 
		end if
		let ma_funil_repres[l_arr_curr].cod_repres = ma_resp3[l_ind].cod_repres
		let l_arr_curr = l_arr_curr + 1
	end for
	let l_arr_curr = l_arr_curr - 1
	
	CALL _ADVPL_set_property(m_refer_tabela_funil,"ITEM_COUNT",l_arr_curr)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"REFRESH")
	
end function

#---------------------------------------#
function geo1027_zoom_clientes()
	#---------------------------------------#
	DEFINE l_where_clause   CHAR(1000)
	DEFINE l_ind            SMALLINT
	define l_zoom_item varchar(10)
	define l_selecao integer
	define l_cod_cliente char(15)

	FOR l_ind = 1 TO 1000
		INITIALIZE ma_resp[l_ind].* TO NULL
	END FOR

	LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
	CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
	CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_resp)
		CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_clientes")

	let mr_tela.cod_cliente = ma_resp[1].cod_cliente
	let mr_tela.nom_cliente = ma_resp[1].nom_cliente
 
end function

#---------------------------------------#
function geo1027_zoom_item()
	#---------------------------------------#
	DEFINE l_where_clause   CHAR(1000)
	DEFINE l_ind            SMALLINT
	define l_zoom_item varchar(10)
	define l_selecao integer
	define l_cod_cliente char(15)

	FOR l_ind = 1 TO 1000
		INITIALIZE ma_resp2[l_ind].* TO NULL
	END FOR

	LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
	CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
	CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_resp2)
		CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_item")

	let mr_tela.cod_item = ma_resp2[1].cod_item
	let mr_tela.den_item = ma_resp2[1].den_item_reduz
 
end function

#---------------------------------------#
function geo1027_zoom_cidade()
	#---------------------------------------#
	DEFINE l_where_clause   CHAR(1000)
	DEFINE l_ind            SMALLINT
	define l_zoom_item varchar(10)
	define l_selecao integer
	define l_cod_cliente char(15)

	FOR l_ind = 1 TO 1000
		INITIALIZE ma_zcidade[l_ind].* TO NULL
	END FOR

	LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
	CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
	CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_zcidade)
		CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_cidades")

	let mr_tela.cod_cidade = ma_zcidade[1].cod_cidade
	let mr_tela.den_cidade = ma_zcidade[1].den_cidade
 
end function

#---------------------------------------#
function geo1027_zoom_clientes2()
	#---------------------------------------#
	DEFINE l_where_clause   CHAR(1000)
	DEFINE l_ind            SMALLINT
	define l_zoom_item varchar(10)
	define l_selecao integer
	define l_cod_cliente char(15)
	DEFINE l_arr_curr    SMALLINT

	LET l_arr_curr = _ADVPL_get_property(m_array.dados,"ITEM_SELECTED")

	FOR l_ind = 1 TO 1000
		INITIALIZE ma_resp[l_ind].* TO NULL
	END FOR

	LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
	CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
	CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_resp)
		CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_clientes")

	let ma_tela[l_arr_curr].cod_cliente = ma_resp[1].cod_cliente
	#let ma_tela[l_arr_curr].nom_cliente = ma_resp[1].nom_cliente

	#CALL _ADVPL_set_property(m_array.dados,"ITEM_COUNT",l_ind)
	CALL _ADVPL_set_property(m_array.dados,"REFRESH")

end function

#---------------------------------------#
function geo1027_zoom_item2()
	#---------------------------------------#
	DEFINE l_where_clause   CHAR(1000)
	DEFINE l_ind            SMALLINT
	define l_zoom_item varchar(10)
	define l_selecao integer
	define l_cod_cliente char(15)
	DEFINE l_arr_curr    SMALLINT

	LET l_arr_curr = _ADVPL_get_property(m_array.dados,"ITEM_SELECTED")

	FOR l_ind = 1 TO 1000
		INITIALIZE ma_resp2[l_ind].* TO NULL
	END FOR

	LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
	CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
	CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_resp2)
		CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_item")

	#CALL _ADVPL_message_box("tst "||ma_resp2[1].cod_item)
	#let ma_tela[l_arr_curr].cod_item = ma_resp2[1].cod_item
	#let ma_tela[l_arr_curr].den_item = ma_resp2[1].den_item_reduz
 
end function

#----------------------------#
FUNCTION geo1027_before_row()
	#----------------------------#
	DEFINE l_arr_curr   SMALLINT

	{LET l_arr_curr = _ADVPL_message_box(m_array.dados,"ITEM_SELECTED")
	IF l_arr_curr <= 0 THEN
	LET l_arr_curr = 1
	END IF 
	LET ma_tela[l_arr_curr].desc_especial = "N"}


END FUNCTION

#----------------------------#
FUNCTION geo1027_zerar()
	#----------------------------#
	DEFINE l_msg char(100)
	DEFINE l_funcao char(20)
	DEFINE l_ind    integer
	DEFINE l_data   date
	DEFINE l_hora   char(8)
	DEFINE l_roteiro    SMALLINT
	DEFINE lr_roteiros RECORD
		cod_empresa CHAR(2),
		cod_roteiro INTEGER,
		seq_visita  INTEGER,
		cod_cliente CHAR(15)
END RECORD

let l_msg = 'Zerar descontos adicioanais vencidos da pesquisa em tela?'
IF LOG_pergunta(l_msg) THEN
else
	return false
end if


CALL log085_transacao('BEGIN')

FOR l_ind = 1 TO _ADVPL_get_property(m_array.dados,"ITEM_COUNT")
	IF ma_tela[l_ind].cod_cliente IS NULL OR ma_tela[l_ind].cod_cliente = " " THEN
		CONTINUE FOR
	END IF

	IF ma_tela[l_ind].cod_item IS NULL OR ma_tela[l_ind].cod_item = " " THEN
		CONTINUE FOR
	END IF

	IF ma_tela[l_ind].dat_final_desc >= TODAY then
		CONTINUE FOR
	end IF
		
	IF ma_tela[l_ind].ies_selecionado <> "S" THEN
		CONTINUE FOR
	END IF


	LET ma_tela[l_ind].pct_desc_adic = 0


	DELETE
	FROM geo_desc_lista
	WHERE cod_empresa = p_cod_empresa
	AND cod_cliente = ma_tela[l_ind].cod_cliente
	AND cod_item = ma_tela[l_ind].cod_item
	IF sqlca.sqlcode <> 0 THEN
		CALL log085_transacao('ROLLBACK')
		CALL log003_err_sql("DELETE","geo_desc_lista")
		RETURN FALSE
	END IF

	INSERT INTO geo_desc_lista (cod_empresa,cod_cliente,cod_item,desc_especial,pct_desc,pct_desc_adic,dat_final_desc) VALUES (p_cod_empresa,
		ma_tela[l_ind].cod_cliente,
		ma_tela[l_ind].cod_item,
		ma_tela[l_ind].desc_especial,
		ma_tela[l_ind].pct_desc,
		ma_tela[l_ind].pct_desc_adic,
		ma_tela[l_ind].dat_final_desc)
	IF sqlca.sqlcode <> 0 THEN
		CALL log085_transacao('ROLLBACK')
		CALL log003_err_sql("INSERT","geo_desc_lista")
		RETURN FALSE
	END IF

END FOR

CALL _ADVPL_set_property(m_array.dados,"REFRESH")

CALL log085_transacao('COMMIT')
RETURN TRUE

END FUNCTION





#----------------------------------------------#
FUNCTION geo1027_alterar_desconto()
	#----------------------------------------------#

	DEFINE l_status   SMALLINT
	, l_ind      SMALLINT

	DEFINE l_toolbar_filtro varchar(50)
	DEFINE l_botao_find_filtro varchar(50)
	DEFINE l_panel_reference_filtro_1 varchar(50)
	DEFINE l_panel_reference_filtro_2 varchar(50)
	DEFINE l_layoutmanager_filtro_1 varchar(50)
	DEFINE l_splitter_filtro varchar(50)

	initialize mr_desconto.* to null

	#################  cria campos tela

	#cria janela principal do tipo LDIALOG
	LET m_form_desconto = _ADVPL_create_component(NULL,"LDIALOG")
	CALL _ADVPL_set_property(m_form_desconto,"TITLE","DESCONTOS EM MASSA")
	CALL _ADVPL_set_property(m_form_desconto,"ENABLE_ESC_CLOSE",FALSE)
	CALL _ADVPL_set_property(m_form_desconto,"SIZE",500,315)#   1024,725)

	#cria menu
	LET l_toolbar_filtro = _ADVPL_create_component(NULL,"LMENUBAR",m_form_desconto)

	#botao informar
	LET l_botao_find_filtro = _ADVPL_create_component(NULL,"LInformButton",l_toolbar_filtro)
	CALL _ADVPL_set_property(l_botao_find_filtro,"EVENT","geo1027_entrada_dadaos_filtro")
	CALL _ADVPL_set_property(l_botao_find_filtro,"CONFIRM_EVENT","geo1027_confirmar_filtro")
	CALL _ADVPL_set_property(l_botao_find_filtro,"CANCEL_EVENT","geo1027_cancela_filtro")

	#cria splitter
	LET l_splitter_filtro = _ADVPL_create_component(NULL,"LSPLITTER",m_form_desconto)
	CALL _ADVPL_set_property(l_splitter_filtro,"ALIGN","CENTER")
	CALL _ADVPL_set_property(l_splitter_filtro,"ORIENTATION","HORIZONTAL")

	#cria panel para campos de filtro
	LET l_panel_reference_filtro_1 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_splitter_filtro)
	CALL _ADVPL_set_property(l_panel_reference_filtro_1,"TITLE","INFORMAR FILTROS DA PESQUISA")

	LET l_panel_reference_filtro_2 = _ADVPL_create_component(NULL,"LPANEL",l_panel_reference_filtro_1)
	CALL _ADVPL_set_property(l_panel_reference_filtro_2,"ALIGN","CENTER")
	CALL _ADVPL_set_property(l_panel_reference_filtro_2,"HEIGHT",10)
	#
	#
	#    CABEÇALHO
	#
	LET l_layoutmanager_filtro_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference_filtro_2)
	CALL _ADVPL_set_property(l_layoutmanager_filtro_1,"MARGIN",TRUE)
	CALL _ADVPL_set_property(l_layoutmanager_filtro_1,"COLUMNS_COUNT",2)


	#cria campo aumentar_desconto
	CALL LOG_cria_rotulo(l_layoutmanager_filtro_1,"Alterar Desconto em %:")
	LET m_refer_desconto = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layoutmanager_filtro_1)
	CALL _ADVPL_set_property(m_refer_desconto,"LENGTH",5,2)
	CALL _ADVPL_set_property(m_refer_desconto,"PICTURE","@E 999.999")
	CALL _ADVPL_set_property(m_refer_desconto,"VARIABLE",mr_desconto,"pct_desc")
	CALL _ADVPL_set_property(m_refer_desconto,"ENABLE",FALSE)

   # 
	CALL LOG_cria_rotulo(l_layoutmanager_filtro_1,"Alterar Desconto Adicional em %:")
	LET m_refer_pct_desc_adic = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layoutmanager_filtro_1)
	CALL _ADVPL_set_property(m_refer_pct_desc_adic,"LENGTH",5,2)
	CALL _ADVPL_set_property(m_refer_pct_desc_adic,"PICTURE","@E 999.999")
	CALL _ADVPL_set_property(m_refer_pct_desc_adic,"VARIABLE",mr_desconto,"pct_desc_adic")
	CALL _ADVPL_set_property(m_refer_pct_desc_adic,"ENABLE",FALSE)
	
	# 
	CALL LOG_cria_rotulo(l_layoutmanager_filtro_1,"Alterar Data para:")
	LET m_refer_dat_final_desc = _ADVPL_create_component(NULL,"LDATEFIELD",l_layoutmanager_filtro_1)
	CALL _ADVPL_set_property(m_refer_dat_final_desc,"VARIABLE",mr_desconto,"dat_final_desc")
	CALL _ADVPL_set_property(m_refer_dat_final_desc,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer_dat_final_desc,"POSITION",830,90)
	 
	CALL _ADVPL_set_property(m_form_desconto,"ACTIVATE",TRUE)

END FUNCTION



#-------------------------------------------#
function geo1027_entrada_dadaos_filtro()
	#-------------------------------------------#

	CALL _ADVPL_set_property(m_refer_desconto,"ENABLE",TRUE)
	CALL _ADVPL_set_property(m_refer_pct_desc_adic,"ENABLE",TRUE)
	CALL _ADVPL_set_property(m_refer_dat_final_desc,"ENABLE",TRUE)
      



end function

#-------------------------------------------#
function geo1027_confirmar_filtro()
	#-------------------------------------------#
 
	DEFINE l_msg char(100)
	DEFINE l_funcao char(20)
	DEFINE l_ind    integer
	DEFINE l_data   date
	DEFINE l_hora   char(8)
	DEFINE l_roteiro    SMALLINT
	DEFINE lr_roteiros RECORD
		cod_empresa CHAR(2),
		cod_roteiro INTEGER,
		seq_visita  INTEGER,
		cod_cliente CHAR(15)
END RECORD

let l_msg = 'Alterar os descontos em: ',mr_desconto.pct_desc,' % ? somente para os intes marcados.'
IF LOG_pergunta(l_msg) THEN
else
	return false
end if


CALL log085_transacao('BEGIN')

FOR l_ind = 1 TO _ADVPL_get_property(m_array.dados,"ITEM_COUNT")
	IF ma_tela[l_ind].cod_cliente IS NULL OR ma_tela[l_ind].cod_cliente = " " THEN
		CONTINUE FOR
	END IF

	IF ma_tela[l_ind].cod_item IS NULL OR ma_tela[l_ind].cod_item = " " THEN
		CONTINUE FOR
	END IF
		
	IF ma_tela[l_ind].ies_selecionado <> "S" THEN
		CONTINUE FOR
	END IF
 

	DELETE
	FROM geo_desc_lista
	WHERE cod_empresa = p_cod_empresa
	AND cod_cliente = ma_tela[l_ind].cod_cliente
	AND cod_item = ma_tela[l_ind].cod_item
	IF sqlca.sqlcode <> 0 THEN
		CALL log085_transacao('ROLLBACK')
		CALL log003_err_sql("DELETE","geo_desc_lista")
		RETURN FALSE
	END IF

	IF ma_tela[l_ind].pct_desc + mr_desconto.pct_desc >= 100 then
		LET ma_tela[l_ind].pct_desc = 99.99
	else

		IF ma_tela[l_ind].pct_desc < 0 then
			LET ma_tela[l_ind].pct_desc = ma_tela[l_ind].pct_desc + mr_desconto.pct_desc
		else
			LET ma_tela[l_ind].pct_desc = ma_tela[l_ind].pct_desc + mr_desconto.pct_desc

			IF ma_tela[l_ind].pct_desc < 0 then
				LET ma_tela[l_ind].pct_desc = 0
			END IF
		END IF
	END IF
		
		
		
	LET ma_tela[l_ind].preco_calculado = ma_tela[l_ind].preco_tabela - (ma_tela[l_ind].preco_tabela * ma_tela[l_ind].pct_desc / 100 )
      
	if ma_tela[l_ind].dat_final_desc >= today then
		LET ma_tela[l_ind].preco_final = ma_tela[l_ind].preco_calculado - (ma_tela[l_ind].preco_calculado * ma_tela[l_ind].pct_desc_adic / 100 )
	else
		LET ma_tela[l_ind].preco_final = ma_tela[l_ind].preco_calculado
	end if
        
	IF ma_tela[l_ind].pct_desc_adic + mr_desconto.pct_desc_adic >= 100 then
		LET ma_tela[l_ind].pct_desc_adic = 99.99
	else

		IF ma_tela[l_ind].pct_desc_adic < 0 then
			LET ma_tela[l_ind].pct_desc_adic = ma_tela[l_ind].pct_desc_adic + mr_desconto.pct_desc_adic
		else
			LET ma_tela[l_ind].pct_desc_adic = ma_tela[l_ind].pct_desc_adic + mr_desconto.pct_desc_adic

			IF ma_tela[l_ind].pct_desc_adic < 0 then
				LET ma_tela[l_ind].pct_desc_adic = 0
			END IF
		END IF
	END IF
		
	LET ma_tela[l_ind].dat_final_desc = mr_desconto.dat_final_desc
		
	INSERT INTO geo_desc_lista (cod_empresa,cod_cliente,cod_item,desc_especial,pct_desc,pct_desc_adic,dat_final_desc) VALUES (p_cod_empresa,
		ma_tela[l_ind].cod_cliente,
		ma_tela[l_ind].cod_item,
		ma_tela[l_ind].desc_especial,
		ma_tela[l_ind].pct_desc,
		ma_tela[l_ind].pct_desc_adic,
		ma_tela[l_ind].dat_final_desc)
	IF sqlca.sqlcode <> 0 THEN
		CALL log085_transacao('ROLLBACK')
		CALL log003_err_sql("INSERT","geo_desc_lista")
		RETURN FALSE
	END IF

END FOR

CALL log085_transacao('COMMIT')

CALL _ADVPL_set_property(m_form_desconto,"ACTIVATE",FALSE)

CALL _ADVPL_set_property(m_array.dados,"REFRESH")
RETURN TRUE

end function

#-------------------------------------------#
function geo1027_cancela_filtro()
	#-------------------------------------------#

	CALL _ADVPL_set_property(m_form_desconto,"ACTIVATE",FALSE)



end function




#----------------------------------------------#
FUNCTION geo1027_copiar_desconto()
	#----------------------------------------------#

	DEFINE l_status   SMALLINT
	, l_ind      SMALLINT

	DEFINE l_toolbar_filtro varchar(50)
	DEFINE l_botao_find_filtro varchar(50)
	DEFINE l_panel_reference_filtro_1 varchar(50)
	DEFINE l_panel_reference_filtro_2 varchar(50)
	DEFINE l_layoutmanager_filtro_1 varchar(50)
	DEFINE l_splitter_filtro varchar(50)

	initialize mr_desconto.* to null

	#################  cria campos tela

	#cria janela principal do tipo LDIALOG
	LET m_form_desconto = _ADVPL_create_component(NULL,"LDIALOG")
	CALL _ADVPL_set_property(m_form_desconto,"TITLE","Copiar Descontos")
	CALL _ADVPL_set_property(m_form_desconto,"ENABLE_ESC_CLOSE",FALSE)
	CALL _ADVPL_set_property(m_form_desconto,"SIZE",500,315)#   1024,725)

	#cria menu
	LET l_toolbar_filtro = _ADVPL_create_component(NULL,"LMENUBAR",m_form_desconto)

	#botao informar
	LET l_botao_find_filtro = _ADVPL_create_component(NULL,"LInformButton",l_toolbar_filtro)
	CALL _ADVPL_set_property(l_botao_find_filtro,"EVENT","geo1027_entrada_dadaos_copia")
	CALL _ADVPL_set_property(l_botao_find_filtro,"CONFIRM_EVENT","geo1027_confirmar_copia")
	CALL _ADVPL_set_property(l_botao_find_filtro,"CANCEL_EVENT","geo1027_cancela_copia")

	#cria splitter
	LET l_splitter_filtro = _ADVPL_create_component(NULL,"LSPLITTER",m_form_desconto)
	CALL _ADVPL_set_property(l_splitter_filtro,"ALIGN","CENTER")
	CALL _ADVPL_set_property(l_splitter_filtro,"ORIENTATION","HORIZONTAL")

	#cria panel para campos de filtro
	LET l_panel_reference_filtro_1 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_splitter_filtro)
	CALL _ADVPL_set_property(l_panel_reference_filtro_1,"TITLE","INFORMAR FILTROS DA PESQUISA")

	LET l_panel_reference_filtro_2 = _ADVPL_create_component(NULL,"LPANEL",l_panel_reference_filtro_1)
	CALL _ADVPL_set_property(l_panel_reference_filtro_2,"ALIGN","CENTER")
	CALL _ADVPL_set_property(l_panel_reference_filtro_2,"HEIGHT",10)
	#
	#
	#    CABEÇALHO
	#
	LET l_layoutmanager_filtro_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference_filtro_2)
	CALL _ADVPL_set_property(l_layoutmanager_filtro_1,"MARGIN",TRUE)
	CALL _ADVPL_set_property(l_layoutmanager_filtro_1,"COLUMNS_COUNT",2)


	#cria campo aumentar_desconto

	CALL LOG_cria_rotulo(l_layoutmanager_filtro_1,"Item de:")

	LET m_refer_item_de = LOG_cria_textfield(l_layoutmanager_filtro_1,15)
	CALL _ADVPL_set_property(m_refer_item_de,"VARIABLE",mr_copia,"item_de")
	CALL _ADVPL_set_property(m_refer_item_de,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer_item_de,"POSITION",90,5)
	CALL _ADVPL_set_property(m_refer_item_de,"VALID","geo1027_valid_item_de")


	CALL LOG_cria_rotulo(l_layoutmanager_filtro_1,"Item para:")

	LET m_refer_item_para = LOG_cria_textfield(l_layoutmanager_filtro_1,15)
	CALL _ADVPL_set_property(m_refer_item_para,"VARIABLE",mr_copia,"item_para")
	CALL _ADVPL_set_property(m_refer_item_para,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer_item_para,"POSITION",90,5)
	CALL _ADVPL_set_property(m_refer_item_para,"VALID","geo1027_valid_item_para")




	CALL _ADVPL_set_property(m_form_desconto,"ACTIVATE",TRUE)

END FUNCTION

#-------------------------------------------#
FUNCTION geo1027_valid_item_para()
	#-------------------------------------------#


	SELECT distinct(cod_empresa)
	FROM item
	WHERE cod_empresa = p_cod_empresa
	AND cod_item = mr_copia.item_para
	IF sqlca.sqlcode = NOTFOUND THEN
		CALL _ADVPL_message_box("Item não encontrado")
		RETURN FALSE
	END IF




	RETURN TRUE

END FUNCTION
#-------------------------------------------#
FUNCTION geo1027_valid_item_de()
	#-------------------------------------------#

	SELECT distinct(cod_empresa)
	FROM item
	WHERE cod_empresa = p_cod_empresa
	AND cod_item = mr_copia.item_de
	IF sqlca.sqlcode = NOTFOUND THEN
		CALL _ADVPL_message_box("Item não encontrado")
		RETURN FALSE
	END IF


	RETURN TRUE
END FUNCTION


#-------------------------------------------#
function geo1027_entrada_dadaos_copia()
	#-------------------------------------------#

	LET mr_copia.item_de =''
	LET mr_copia.item_para =''
	CALL _ADVPL_set_property(m_refer_item_de,"ENABLE",TRUE)
	CALL _ADVPL_set_property(m_refer_item_para,"ENABLE",TRUE)




end function

#-------------------------------------------#
function geo1027_confirmar_copia()
	#-------------------------------------------#


	DEFINE l_msg char(100)
	DEFINE l_funcao char(20)
	DEFINE l_ind    integer
	DEFINE l_data   date
	DEFINE l_hora   char(8)
	DEFINE l_roteiro    SMALLINT
	DEFINE lr_roteiros RECORD
		cod_empresa CHAR(2),
		cod_roteiro INTEGER,
		seq_visita  INTEGER,
		cod_cliente CHAR(15)
END RECORD
DEFINE lr_geo_desc_lista record
	cod_empresa       char(2),
	cod_cliente       CHAR(15),
	nom_cliente       LIKE clientes.nom_cliente,
	cod_item          CHAR(15),
	den_item          CHAR(76),
	desc_especial     CHAR(1),
	pct_desc          DECIMAL(4,2),
	pct_desc_adic     DECIMAL(4,2),
	dat_final_desc    DATE
END RECORD
	
if mr_copia.item_de IS NULL OR mr_copia.item_para IS NULL OR mr_copia.item_de = '' OR mr_copia.item_para = '' then
	CALL _ADVPL_message_box("Informe corretamente os itens.")
	RETURN FALSE
END IF


let l_msg = 'Confirma copia do item de: ',mr_copia.item_de,' para o item: ', mr_copia.item_para, ' de todos os clientes ?'
IF LOG_pergunta(l_msg) THEN
else
	return false
end if
SELECT distinct(cod_empresa)
FROM geo_desc_lista
WHERE cod_empresa = p_cod_empresa
AND cod_item = mr_copia.item_para
IF sqlca.sqlcode = 0 THEN
	CALL _ADVPL_message_box("Já existe descontos cadastrados para este item.")

	let l_msg = 'Confirma substituição dos descontos do item ', mr_copia.item_para, ' ?'
	IF LOG_pergunta(l_msg) THEN
	else
		return false
	end if

END IF


CALL log085_transacao('BEGIN')

DECLARE cq_copia_item cursor for
SELECT cod_empresa, cod_cliente, cod_item, desc_especial, pct_desc, pct_desc_adic, dat_final_desc
FROM geo_desc_lista
WHERE cod_empresa = p_cod_empresa
AND cod_item = mr_copia.item_de
FOREACH cq_copia_item INTO lr_geo_desc_lista.cod_empresa,
		lr_geo_desc_lista.cod_cliente       ,
		lr_geo_desc_lista.cod_item          ,
		lr_geo_desc_lista.desc_especial     ,
		lr_geo_desc_lista.pct_desc          ,
		lr_geo_desc_lista.pct_desc_adic     ,
		lr_geo_desc_lista.dat_final_desc

	DELETE
	FROM geo_desc_lista
	WHERE cod_empresa = p_cod_empresa
	AND cod_cliente = lr_geo_desc_lista.cod_cliente
	AND cod_item = mr_copia.item_para


	INSERT INTO geo_desc_lista (cod_empresa,cod_cliente,cod_item,desc_especial,pct_desc,pct_desc_adic,dat_final_desc) VALUES (lr_geo_desc_lista.cod_empresa,
		lr_geo_desc_lista.cod_cliente,
		mr_copia.item_para,
		lr_geo_desc_lista.desc_especial,
		lr_geo_desc_lista.pct_desc,
		lr_geo_desc_lista.pct_desc_adic,
		lr_geo_desc_lista.dat_final_desc)
	IF sqlca.sqlcode <> 0 THEN
		CALL log085_transacao('ROLLBACK')
		CALL log003_err_sql("INSERT","geo_desc_lista")
		RETURN FALSE
	END IF

END foreach

CALL log085_transacao('COMMIT')

CALL _ADVPL_set_property(m_form_desconto,"ACTIVATE",FALSE)

RETURN TRUE

end function

#-------------------------------------------#
function geo1027_cancela_copia()
	#-------------------------------------------#

	CALL _ADVPL_set_property(m_form_desconto,"ACTIVATE",FALSE)



end function



 
#---------------------------------------------#
function geo1027_marcar_todos_painel()
#---------------------------------------------#
	CALL LOG_set_progress_text("Selecionando linhas...","PROCESS")
	CALL LOG_progress_start(" Pesquisando...","geo1027_marcar_todos2_painel","PROCESS")
	CALL LOG_progress_finish(TRUE)
   
end function
 
#---------------------------------------------#
function geo1027_marcar_todos2_painel()
#---------------------------------------------#
	define l_ind smallint

	for l_ind = 1 to 9999
		if ma_tela[l_ind].cod_cliente is null then
			exit for
		end if
		let ma_tela[l_ind].ies_selecionado = 'S'
	end for


#atualiza array
	CALL _ADVPL_set_property(m_array.dados,"REFRESH")

end function
 
 
 

#---------------------------------------------#
function geo1027_desmarcar_todos_painel()
#---------------------------------------------#
	CALL LOG_set_progress_text("Selecionando linhas...","PROCESS")
	CALL LOG_progress_start(" Pesquisando...","geo1027_desmarcar_todos2_painel","PROCESS")
	CALL LOG_progress_finish(TRUE)
   
end function

#---------------------------------------------#
function geo1027_desmarcar_todos2_painel()
#---------------------------------------------#
	define l_ind smallint

	for l_ind = 1 to 9999
		if ma_tela[l_ind].cod_cliente is null then
			exit for
		end if
		let ma_tela[l_ind].ies_selecionado = 'N'
	end for


#atualiza array
	CALL _ADVPL_set_property(m_array.dados,"REFRESH")

end function

#---------------------------------------------#
function geo1027_incluir_massa()
#---------------------------------------------#
 
 
	
	DEFINE l_status   SMALLINT
	, l_ind      SMALLINT

	DEFINE l_toolbar_filtro varchar(50)
	DEFINE l_botao_find_filtro varchar(50)
	DEFINE l_panel_reference_filtro_1 varchar(50)
	DEFINE l_panel_reference_filtro_2 varchar(50)
	DEFINE l_panel_reference_filtro_3 varchar(50)
	DEFINE l_panel_reference_filtro_4 varchar(50)
	DEFINE l_panel_reference_filtro_5 varchar(50)
	DEFINE l_panel_reference_filtro_6 varchar(50)
	DEFINE l_layoutmanager_filtro_1 varchar(50)
	DEFINE l_layoutmanager_filtro_2 varchar(50)
	DEFINE l_layoutmanager_filtro_3 varchar(50)
	DEFINE l_splitter_filtro varchar(50)
	
	
	DEFINE l_refer_cod_cliente varchar(50)
	DEFINE l_refer_zoom_cliente varchar(50)
	DEFINE l_refer_nom_cliente varchar(50)
	
	DEFINE l_refer_cod_item varchar(50)
	DEFINE l_refer_zoom_item varchar(50)
	DEFINE l_refer_den_item varchar(50)

	initialize mr_desconto.* to null
	INITIALIZE ma_itens TO null
	INITIALIZE ma_clientes TO null
    
	let mr_desconto.dat_final_desc = today
	#################  cria campos tela

	#cria janela principal do tipo LDIALOG
	LET m_form_desconto = _ADVPL_create_component(NULL,"LDIALOG")
	CALL _ADVPL_set_property(m_form_desconto,"TITLE","INCLUIR EM MASSA")
	CALL _ADVPL_set_property(m_form_desconto,"ENABLE_ESC_CLOSE",FALSE)
	CALL _ADVPL_set_property(m_form_desconto,"SIZE",800,600)#   1024,725)

	#cria menu
	LET l_toolbar_filtro = _ADVPL_create_component(NULL,"LMENUBAR",m_form_desconto)

	#botao informar
	LET l_botao_find_filtro = _ADVPL_create_component(NULL,"LInformButton",l_toolbar_filtro)
	CALL _ADVPL_set_property(l_botao_find_filtro,"EVENT","geo1027_entrada_dadaos_massa")
	CALL _ADVPL_set_property(l_botao_find_filtro,"CONFIRM_EVENT","geo1027_confirmar_massa")
	CALL _ADVPL_set_property(l_botao_find_filtro,"CANCEL_EVENT","geo1027_cancela_massa")

	#cria splitter
	LET l_splitter_filtro = _ADVPL_create_component(NULL,"LSPLITTER",m_form_desconto)
	CALL _ADVPL_set_property(l_splitter_filtro,"ALIGN","CENTER")
	CALL _ADVPL_set_property(l_splitter_filtro,"ORIENTATION","HORIZONTAL")

	#cria panel  
	LET l_panel_reference_filtro_1 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_splitter_filtro)
	CALL _ADVPL_set_property(l_panel_reference_filtro_1,"TITLE","INFORMAR")

	LET l_panel_reference_filtro_2 = _ADVPL_create_component(NULL,"LPANEL",l_panel_reference_filtro_1)
	CALL _ADVPL_set_property(l_panel_reference_filtro_2,"ALIGN","CENTER")
	CALL _ADVPL_set_property(l_panel_reference_filtro_2,"HEIGHT",10)
	
	
	#cria panel  
	LET l_panel_reference_filtro_3 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_splitter_filtro)
	CALL _ADVPL_set_property(l_panel_reference_filtro_3,"TITLE","CLIENTES")

	LET l_panel_reference_filtro_4 = _ADVPL_create_component(NULL,"LPANEL",l_panel_reference_filtro_3)
	CALL _ADVPL_set_property(l_panel_reference_filtro_4,"ALIGN","CENTER")
	CALL _ADVPL_set_property(l_panel_reference_filtro_4,"HEIGHT",10)
	
	
	
	
	#cria panel  
	LET l_panel_reference_filtro_5 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_splitter_filtro)
	CALL _ADVPL_set_property(l_panel_reference_filtro_5,"TITLE","INFORMAR")

	LET l_panel_reference_filtro_6 = _ADVPL_create_component(NULL,"LPANEL",l_panel_reference_filtro_5)
	CALL _ADVPL_set_property(l_panel_reference_filtro_6,"ALIGN","ITENS")
	CALL _ADVPL_set_property(l_panel_reference_filtro_6,"HEIGHT",10)
	
	 
	#
	LET l_layoutmanager_filtro_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference_filtro_2)
	CALL _ADVPL_set_property(l_layoutmanager_filtro_1,"MARGIN",TRUE)
	CALL _ADVPL_set_property(l_layoutmanager_filtro_1,"COLUMNS_COUNT",2)


	#cria campo aumentar_desconto
	CALL LOG_cria_rotulo(l_layoutmanager_filtro_1,"Desconto %:")
	LET m_refer_desconto = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layoutmanager_filtro_1)
	CALL _ADVPL_set_property(m_refer_desconto,"LENGTH",5,2)
	CALL _ADVPL_set_property(m_refer_desconto,"PICTURE","@E 999.999")
	CALL _ADVPL_set_property(m_refer_desconto,"VARIABLE",mr_desconto,"pct_desc")
	CALL _ADVPL_set_property(m_refer_desconto,"ENABLE",FALSE)

   # 
	CALL LOG_cria_rotulo(l_layoutmanager_filtro_1,"Desconto Adicional %:")
	LET m_refer_pct_desc_adic = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layoutmanager_filtro_1)
	CALL _ADVPL_set_property(m_refer_pct_desc_adic,"LENGTH",5,2)
	CALL _ADVPL_set_property(m_refer_pct_desc_adic,"PICTURE","@E 999.999")
	CALL _ADVPL_set_property(m_refer_pct_desc_adic,"VARIABLE",mr_desconto,"pct_desc_adic")
	CALL _ADVPL_set_property(m_refer_pct_desc_adic,"ENABLE",FALSE)
	
	# 
	CALL LOG_cria_rotulo(l_layoutmanager_filtro_1,"Data:")
	LET m_refer_dat_final_desc = _ADVPL_create_component(NULL,"LDATEFIELD",l_layoutmanager_filtro_1)
	CALL _ADVPL_set_property(m_refer_dat_final_desc,"VARIABLE",mr_desconto,"dat_final_desc")
	CALL _ADVPL_set_property(m_refer_dat_final_desc,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer_dat_final_desc,"POSITION",830,90)
	
	#
	LET l_layoutmanager_filtro_2 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference_filtro_4)
	CALL _ADVPL_set_property(l_layoutmanager_filtro_2,"MARGIN",TRUE)
	CALL _ADVPL_set_property(l_layoutmanager_filtro_2,"COLUMNS_COUNT",2)

 #cria array
	LET m_refer_tabela1 = _ADVPL_create_component(NULL,"LBROWSEEX",l_layoutmanager_filtro_2)
	CALL _ADVPL_set_property(m_refer_tabela1,"SIZE",750,300)
	CALL _ADVPL_set_property(m_refer_tabela1,"CAN_ADD_ROW",TRUE)
	CALL _ADVPL_set_property(m_refer_tabela1,"CAN_REMOVE_ROW",TRUE)
	CALL _ADVPL_set_property(m_refer_tabela1,"ALIGN","CENTER")
	CALL _ADVPL_set_property(m_refer_tabela1,"EDITABLE",TRUE)
	CALL _ADVPL_set_property(m_refer_tabela1,"ENABLE",TRUE)
	CALL _ADVPL_set_property(m_refer_tabela1,"POSITION",80,200)
	 
 	#cria campo do array: cod_cliente
	LET l_refer_cod_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_refer_tabela1)
	CALL _ADVPL_set_property(l_refer_cod_cliente,"VARIABLE","cod_cliente")
	CALL _ADVPL_set_property(l_refer_cod_cliente,"HEADER","Cod.Cliente")
	CALL _ADVPL_set_property(l_refer_cod_cliente,"COLUMN_SIZE", 50)
	CALL _ADVPL_set_property(l_refer_cod_cliente,"ORDER",TRUE)
	CALL _ADVPL_set_property(l_refer_cod_cliente,"EDIT_COMPONENT","LTEXTFIELD")
	CALL _ADVPL_set_property(l_refer_cod_cliente,"EDIT_PROPERTY","LENGTH",15)
	CALL _ADVPL_set_property(l_refer_cod_cliente,"EDIT_PROPERTY","VALID","geo1027_valid_cod_cliente3")
	CALL _ADVPL_set_property(l_refer_cod_cliente,"EDITABLE", TRUE)

	#-- Zoom
	LET l_refer_zoom_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_refer_tabela1)
	CALL _ADVPL_set_property(l_refer_zoom_cliente,"COLUMN_SIZE",10)
	CALL _ADVPL_set_property(l_refer_zoom_cliente,"EDITABLE",TRUE)
	CALL _ADVPL_set_property(l_refer_zoom_cliente,"NO_VARIABLE",TRUE)
	CALL _ADVPL_set_property(l_refer_zoom_cliente,"IMAGE", "BTPESQ")
	CALL _ADVPL_set_property(l_refer_zoom_cliente,"BEFORE_EDIT_EVENT","geo1027_zoom_clientes3")

	#cria campo do array: nom_cliente
	LET l_refer_nom_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_refer_tabela1)
	CALL _ADVPL_set_property(l_refer_nom_cliente,"VARIABLE","nom_cliente")
	CALL _ADVPL_set_property(l_refer_nom_cliente,"HEADER","Nom.Cliente")
	CALL _ADVPL_set_property(l_refer_nom_cliente,"COLUMN_SIZE", 100)
	CALL _ADVPL_set_property(l_refer_nom_cliente,"ORDER",TRUE)
	CALL _ADVPL_set_property(l_refer_nom_cliente,"EDIT_COMPONENT","LTEXTFIELD")
	CALL _ADVPL_set_property(l_refer_nom_cliente,"EDIT_PROPERTY","LENGTH",76)
	CALL _ADVPL_set_property(l_refer_nom_cliente,"EDITABLE", false)
 
	
    
	CALL _ADVPL_set_property(m_refer_tabela1,"SET_ROWS",ma_clientes,0)
	CALL _ADVPL_set_property(m_refer_tabela1,"ITEM_COUNT",0)
	CALL _ADVPL_set_property(m_refer_tabela1,"REFRESH")
	
	#
	LET l_layoutmanager_filtro_3 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference_filtro_6)
	CALL _ADVPL_set_property(l_layoutmanager_filtro_3,"MARGIN",TRUE)
	CALL _ADVPL_set_property(l_layoutmanager_filtro_3,"COLUMNS_COUNT",2)

  
	
	#cria array
	LET m_refer_tabela2 = _ADVPL_create_component(NULL,"LBROWSEEX",l_layoutmanager_filtro_3)
	CALL _ADVPL_set_property(m_refer_tabela2,"SIZE",750,300)
	CALL _ADVPL_set_property(m_refer_tabela2,"CAN_ADD_ROW",true)
	CALL _ADVPL_set_property(m_refer_tabela2,"CAN_REMOVE_ROW",true)
	CALL _ADVPL_set_property(m_refer_tabela2,"ALIGN","CENTER")
	CALL _ADVPL_set_property(m_refer_tabela2,"EDITABLE",TRUE)
	CALL _ADVPL_set_property(m_refer_tabela2,"ENABLE",TRUE)
	CALL _ADVPL_set_property(m_refer_tabela2,"POSITION",80,200)
	 
	#cria campo do array: cod_item
	LET l_refer_cod_item = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_refer_tabela2)
	CALL _ADVPL_set_property(l_refer_cod_item,"VARIABLE","cod_item")
	CALL _ADVPL_set_property(l_refer_cod_item,"HEADER","Cod.Item")
	CALL _ADVPL_set_property(l_refer_cod_item,"COLUMN_SIZE", 50)
	CALL _ADVPL_set_property(l_refer_cod_item,"ORDER",TRUE)
	CALL _ADVPL_set_property(l_refer_cod_item,"EDIT_COMPONENT","LTEXTFIELD")
	CALL _ADVPL_set_property(l_refer_cod_item,"EDIT_PROPERTY","LENGTH",20)
	CALL _ADVPL_set_property(l_refer_cod_item,"EDIT_PROPERTY","VALID","geo1027_valid_cod_item3")
	CALL _ADVPL_set_property(l_refer_cod_item,"EDITABLE", true)

	#-- Zoom
	LET l_refer_zoom_item = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_refer_tabela2)
	CALL _ADVPL_set_property(l_refer_zoom_item,"COLUMN_SIZE",10)
	CALL _ADVPL_set_property(l_refer_zoom_item,"EDITABLE",true)
	CALL _ADVPL_set_property(l_refer_zoom_item,"NO_VARIABLE",TRUE)
	CALL _ADVPL_set_property(l_refer_zoom_item,"IMAGE", "BTPESQ")
	CALL _ADVPL_set_property(l_refer_zoom_item,"BEFORE_EDIT_EVENT","geo1027_zoom_item3")

	#cria campo do array: den_item
	LET l_refer_den_item = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_refer_tabela2)
	CALL _ADVPL_set_property(l_refer_den_item,"VARIABLE","den_item")
	CALL _ADVPL_set_property(l_refer_den_item,"HEADER","Den.Item")
	CALL _ADVPL_set_property(l_refer_den_item,"COLUMN_SIZE", 100)
	CALL _ADVPL_set_property(l_refer_den_item,"ORDER",TRUE)
	CALL _ADVPL_set_property(l_refer_den_item,"EDIT_COMPONENT","LTEXTFIELD")
	CALL _ADVPL_set_property(l_refer_den_item,"EDIT_PROPERTY","LENGTH",76)
	CALL _ADVPL_set_property(l_refer_den_item,"EDITABLE", FALSE)
 

	CALL _ADVPL_set_property(m_refer_tabela2,"SET_ROWS",ma_itens,0)
	CALL _ADVPL_set_property(m_refer_tabela2,"ITEM_COUNT",0)
	CALL _ADVPL_set_property(m_refer_tabela2,"REFRESH")
	
	
	
	CALL _ADVPL_set_property(m_form_desconto,"ACTIVATE",TRUE)
	
	
END function
 
 
 

#-------------------------------------------#
function geo1027_entrada_dadaos_massa()
	#-------------------------------------------#

	CALL _ADVPL_set_property(m_refer_desconto,"ENABLE",TRUE)
	CALL _ADVPL_set_property(m_refer_pct_desc_adic,"ENABLE",TRUE)
	CALL _ADVPL_set_property(m_refer_dat_final_desc,"ENABLE",TRUE)
      



end function

#-------------------------------------------#
function geo1027_confirmar_massa()
	#-------------------------------------------#
	DEFINE l_ind1 integer
	DEFINE l_ind2 integer
	DEFINE l_msg  char(100)
   
	let l_msg = 'Confirma a inclusão em massa dos dados informados?'
	IF LOG_pergunta(l_msg) THEN
	else
		return false
	end if
	
    
	FOR l_ind1 = 1 TO _ADVPL_get_property(m_refer_tabela1,"ITEM_COUNT")
      
      
		IF ma_clientes[l_ind1].cod_cliente IS NULL OR ma_clientes[l_ind1].cod_cliente = '' then
			EXIT for
		END if
	
		FOR l_ind2 = 1 TO _ADVPL_get_property(m_refer_tabela2,"ITEM_COUNT")
			IF ma_itens[l_ind2].cod_item IS NULL OR ma_itens[l_ind2].cod_item = '' then
				EXIT for
			END if
         
         
			DELETE
			FROM geo_desc_lista
			WHERE cod_empresa = p_cod_empresa
			AND cod_cliente = ma_clientes[l_ind1].cod_cliente
			AND cod_item = ma_itens[l_ind2].cod_item
			IF sqlca.sqlcode <> 0 THEN
				CALL log085_transacao('ROLLBACK')
				CALL log003_err_sql("DELETE","geo_desc_lista")
				RETURN FALSE
			END IF
		 
			if mr_desconto.dat_final_desc is null or mr_desconto.dat_final_desc = '' then
				let mr_desconto.dat_final_desc = today
			end if
         
			INSERT INTO geo_desc_lista (cod_empresa,cod_cliente,cod_item,desc_especial,pct_desc,pct_desc_adic,dat_final_desc) VALUES (p_cod_empresa,
				ma_clientes[l_ind1].cod_cliente,
				ma_itens[l_ind2].cod_item,
				0,
				mr_desconto.pct_desc,
				mr_desconto.pct_desc_adic,
				mr_desconto.dat_final_desc)
			IF sqlca.sqlcode <> 0 THEN
				CALL log085_transacao('ROLLBACK')
				CALL log003_err_sql("INSERT","geo_desc_lista")
				RETURN FALSE
			END IF
	
		END FOR
	
	END for
   
	CALL LOG_mensagem(m_form_desconto,"Processamento efetuado com Sucesso.", "AVISO",FALSE)
	 
	RETURN TRUE

end function

#-------------------------------------------#
function geo1027_cancela_massa()
	#-------------------------------------------#

	CALL _ADVPL_set_property(m_form_desconto,"ACTIVATE",FALSE)



end FUNCTION


#-----------------------------------#
FUNCTION geo1027_valid_cod_cliente3()
	#-----------------------------------#
	DEFINE l_arr_curr        SMALLINT

	LET l_arr_curr = _ADVPL_get_property(m_refer_tabela1,"ITEM_SELECTED")
    
	IF ma_clientes[l_arr_curr].cod_cliente IS NULL OR ma_clientes[l_arr_curr].cod_cliente = '' then
		RETURN TRUE
	END if
    
	SELECT nom_cliente
	INTO ma_clientes[l_arr_curr].nom_cliente
	FROM clientes
	WHERE cod_cliente = ma_clientes[l_arr_curr].cod_cliente
	IF sqlca.sqlcode = NOTFOUND THEN
		CALL _ADVPL_message_box("Cliente não encontrado")
		RETURN FALSE
	END IF

	RETURN TRUE
END FUNCTION


#---------------------------------------#
function geo1027_zoom_clientes3()
	#---------------------------------------#
	DEFINE l_where_clause   CHAR(1000)
	DEFINE l_ind            SMALLINT
	define l_zoom_item varchar(10)
	define l_selecao integer
	define l_cod_cliente char(15)
	DEFINE l_arr_curr    SMALLINT

	LET l_arr_curr = _ADVPL_get_property(m_refer_tabela1,"ITEM_SELECTED")

	FOR l_ind = 1 TO 1000
		INITIALIZE ma_resp[l_ind].* TO NULL
	END FOR

	LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
	CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
	CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_resp)
		CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_clientes")

	let ma_clientes[l_arr_curr].cod_cliente = ma_resp[1].cod_cliente
	let ma_clientes[l_arr_curr].nom_cliente = ma_resp[1].nom_cliente

	#CALL _ADVPL_set_property(m_array.dados,"ITEM_COUNT",l_ind)
	CALL _ADVPL_set_property(m_refer_tabela1,"REFRESH")

end FUNCTION


#-----------------------------------#
FUNCTION geo1027_valid_cod_item3()
	#-----------------------------------#
	DEFINE l_arr_curr        SMALLINT
    
    
	LET l_arr_curr = _ADVPL_get_property(m_refer_tabela2,"ITEM_SELECTED")
    
	IF ma_itens[l_arr_curr].cod_item IS NULL OR ma_itens[l_arr_curr].cod_item = '' then
		RETURN true
	END if

	SELECT den_item
	INTO ma_itens[l_arr_curr].den_item
	FROM item
	WHERE cod_item = ma_itens[l_arr_curr].cod_item
	AND cod_empresa = p_cod_empresa
	IF sqlca.sqlcode = NOTFOUND THEN
		CALL _ADVPL_message_box("Item não encontrado")
		RETURN FALSE
	END IF

	RETURN TRUE

END FUNCTION

#---------------------------------------#
function geo1027_zoom_item3()
	#---------------------------------------#
	DEFINE l_where_clause   CHAR(1000)
	DEFINE l_ind            SMALLINT
	define l_zoom_item varchar(10)
	define l_selecao integer
	define l_cod_cliente char(15)
	DEFINE l_arr_curr    SMALLINT

	LET l_arr_curr = _ADVPL_get_property(m_refer_tabela2,"ITEM_SELECTED")

	FOR l_ind = 1 TO 1000
		INITIALIZE ma_resp2[l_ind].* TO NULL
	END FOR

	LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
	CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
	CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_resp2)
		CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_item")

	#CALL _ADVPL_message_box("tst "||ma_resp2[1].cod_item)
	let ma_itens[l_arr_curr].cod_item = ma_resp2[1].cod_item
	let ma_itens[l_arr_curr].den_item = ma_resp2[1].den_item_reduz
	
	 
	CALL _ADVPL_set_property(m_refer_tabela2,"REFRESH")
 
end function


#-------------------------------------------#
function geo1027_tela_funil_repres()
#-------------------------------------------#
	call geo1027_tela_funil_tela('repres')
end function

#-------------------------------------------#
function geo1027_tela_funil_cliente()
#-------------------------------------------#
	call geo1027_tela_funil_tela('cliente')
end function

#-------------------------------------------#
function geo1027_tela_funil_item()
#-------------------------------------------#
	call geo1027_tela_funil_tela('item')
end function

#-------------------------------------------#
function geo1027_tela_funil_cidade()
#-------------------------------------------#
	call geo1027_tela_funil_tela('cidade')
end function


#-------------------------------------------#
function geo1027_tela_funil_tela(l_tela)
#-------------------------------------------#
	define l_ind integer
	define l_tela char(10)
	DEFINE l_opcao char(20)
	DEFINE l_panel_filtro,
		l_toolbar            VARCHAR(10)

	DEFINE l_panel_reference,
		l_panel_reference_1,
		l_panel_reference_2,
		l_panel_reference_0        VARCHAR(10)

	DEFINE l_layoutmanager_refence_1,
		l_layoutmanager_refence_2 VARCHAR(10)

	define l_layoutmanager_filtro varchar(10)
	define l_layoutmanager_array varchar(10)
	define l_column_reference         varchar(10)

	DEFINE l_status SMALLINT

	DEFINE l_splitter_reference VARCHAR(10)
	define l_botao_find varchar(50)
	define l_refer_cliente varchar(50)
	define l_refer_zoom_cliente varchar(50)

	
   
    #cria janela principal do tipo LDIALOG
	LET m_form_funil = _ADVPL_create_component(NULL,"LDIALOG")
	CALL _ADVPL_set_property(m_form_funil,"TITLE","FILTROS")
	CALL _ADVPL_set_property(m_form_funil,"ENABLE_ESC_CLOSE",FALSE)
	CALL _ADVPL_set_property(m_form_funil,"SIZE",500,400)

    #cria menu
	LET l_toolbar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_funil)

    #botao informar
	LET l_botao_find = _ADVPL_create_component(NULL,"LInformButton",l_toolbar)
	CALL _ADVPL_set_property(l_botao_find,"EVENT","geo1027_entrada_dados_funil")
	CALL _ADVPL_set_property(l_botao_find,"CONFIRM_EVENT","geo1027_confirmar_funil")
	CALL _ADVPL_set_property(l_botao_find,"CANCEL_EVENT","geo1027_cancela_funil")
 
      #cria splitter
	LET l_splitter_reference = _ADVPL_create_component(NULL,"LSPLITTER",m_form_funil)
	CALL _ADVPL_set_property(l_splitter_reference,"ALIGN","CENTER")
	CALL _ADVPL_set_property(l_splitter_reference,"ORIENTATION","HORIZONTAL")

      #cria panel para campos de filtro
	LET l_panel_reference_0 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_splitter_reference)
	CALL _ADVPL_set_property(l_panel_reference_0,"TITLE","INFORMAR FILTROS DA PESQUISA")
 
	LET l_panel_reference_1 = _ADVPL_create_component(NULL,"LPANEL",l_panel_reference_0)
	CALL _ADVPL_set_property(l_panel_reference_1,"ALIGN","CENTER")
	CALL _ADVPL_set_property(l_panel_reference_1,"HEIGHT",10)
      
      
	LET l_layoutmanager_refence_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference_1)
	CALL _ADVPL_set_property(l_layoutmanager_refence_1,"MARGIN",TRUE)
	CALL _ADVPL_set_property(l_layoutmanager_refence_1,"COLUMNS_COUNT",4)
 


#cria array
	LET m_refer_tabela_funil = _ADVPL_create_component(NULL,"LBROWSEEX",l_layoutmanager_refence_1)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"SIZE",650,390)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"CAN_ADD_ROW",TRUE)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"CAN_REMOVE_ROW",TRUE)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"ALIGN","CENTER")
	CALL _ADVPL_set_property(m_refer_tabela_funil,"EDITABLE",TRUE)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"ENABLE",TRUE)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"POSITION",80,570)
	 
    case l_tela
      when 'repres'
      		#cria campo do array: cod_repres
			LET l_refer_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_refer_tabela_funil)
			CALL _ADVPL_set_property(l_refer_cliente,"VARIABLE","cod_repres")
			CALL _ADVPL_set_property(l_refer_cliente,"HEADER","Cod.Repres")
			CALL _ADVPL_set_property(l_refer_cliente,"COLUMN_SIZE", 50)
			CALL _ADVPL_set_property(l_refer_cliente,"ORDER",TRUE)
			CALL _ADVPL_set_property(l_refer_cliente,"EDIT_COMPONENT","LNUMERICFIELD")
			CALL _ADVPL_set_property(l_refer_cliente,"EDIT_PROPERTY","LENGTH",4,0)
			CALL _ADVPL_set_property(l_refer_cliente,"EDIT_PROPERTY","VALID","geo1027_valid_cod_repres3")
			CALL _ADVPL_set_property(l_refer_cliente,"EDITABLE", TRUE)
		  
			#-- Zoom
			LET l_refer_zoom_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_refer_tabela_funil)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"COLUMN_SIZE",10)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"EDITABLE",true)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"NO_VARIABLE",TRUE)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"IMAGE", "BTPESQ")
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"BEFORE_EDIT_EVENT","geo1027_zoom_repres3")
			
			let l_ind = 0 
			for l_ind = 1 to 999
			   if ma_funil_repres[l_ind].cod_repres is null or   ma_funil_repres[l_ind].cod_repres = ' ' then
			      exit for
			   end if
			end for
			let l_ind = l_ind - 1
			 
			CALL _ADVPL_set_property(m_refer_tabela_funil,"SET_ROWS",ma_funil_repres,0)
      when 'cliente'	
		 	#cria campo do array: cod_cliente
			LET l_refer_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_refer_tabela_funil)
			CALL _ADVPL_set_property(l_refer_cliente,"VARIABLE","cod_cliente")
			CALL _ADVPL_set_property(l_refer_cliente,"HEADER","Cod.Cliente")
			CALL _ADVPL_set_property(l_refer_cliente,"COLUMN_SIZE", 50)
			CALL _ADVPL_set_property(l_refer_cliente,"ORDER",TRUE)
			CALL _ADVPL_set_property(l_refer_cliente,"EDIT_COMPONENT","LTEXTFIELD")
			CALL _ADVPL_set_property(l_refer_cliente,"EDIT_PROPERTY","LENGTH",15)
			CALL _ADVPL_set_property(l_refer_cliente,"EDIT_PROPERTY","VALID","geo1027_valid_cod_cliente4")
			CALL _ADVPL_set_property(l_refer_cliente,"EDITABLE", TRUE)
		
			#-- Zoom
			LET l_refer_zoom_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_refer_tabela_funil)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"COLUMN_SIZE",10)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"EDITABLE",true)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"NO_VARIABLE",TRUE)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"IMAGE", "BTPESQ")
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"BEFORE_EDIT_EVENT","geo1027_zoom_clientes4")
			
			let l_ind = 0 
			for l_ind = 1 to 999
			   if ma_funil_cliente[l_ind].cod_cliente is null or   ma_funil_cliente[l_ind].cod_cliente = ' ' then
			      exit for
			   end if
			end for
			let l_ind = l_ind - 1
			  
			CALL _ADVPL_set_property(m_refer_tabela_funil,"SET_ROWS",ma_funil_cliente,0)
	  when 'item'
	  		#cria campo do array: cod_cliente
			LET l_refer_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_refer_tabela_funil)
			CALL _ADVPL_set_property(l_refer_cliente,"VARIABLE","cod_item")
			CALL _ADVPL_set_property(l_refer_cliente,"HEADER","Cod.Item")
			CALL _ADVPL_set_property(l_refer_cliente,"COLUMN_SIZE", 50)
			CALL _ADVPL_set_property(l_refer_cliente,"ORDER",TRUE)
			CALL _ADVPL_set_property(l_refer_cliente,"EDIT_COMPONENT","LTEXTFIELD")
			CALL _ADVPL_set_property(l_refer_cliente,"EDIT_PROPERTY","LENGTH",15)
			CALL _ADVPL_set_property(l_refer_cliente,"EDIT_PROPERTY","VALID","geo1027_valid_cod_item4")
			CALL _ADVPL_set_property(l_refer_cliente,"EDITABLE", TRUE)
		
			#-- Zoom
			LET l_refer_zoom_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_refer_tabela_funil)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"COLUMN_SIZE",10)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"EDITABLE",true)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"NO_VARIABLE",TRUE)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"IMAGE", "BTPESQ")
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"BEFORE_EDIT_EVENT","geo1027_zoom_item4")
			
			let l_ind = 0 
			for l_ind = 1 to 999
			   if ma_funil_item[l_ind].cod_item is null or   ma_funil_item[l_ind].cod_item = ' ' then
			      exit for
			   end if
			end for
			let l_ind = l_ind - 1
			  
			CALL _ADVPL_set_property(m_refer_tabela_funil,"SET_ROWS",ma_funil_item,0)
	  when 'cidade'
	  		#cria campo do array: cod_cliente
			LET l_refer_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_refer_tabela_funil)
			CALL _ADVPL_set_property(l_refer_cliente,"VARIABLE","cod_cidade")
			CALL _ADVPL_set_property(l_refer_cliente,"HEADER","Cod.Cidade")
			CALL _ADVPL_set_property(l_refer_cliente,"COLUMN_SIZE", 50)
			CALL _ADVPL_set_property(l_refer_cliente,"ORDER",TRUE)
			CALL _ADVPL_set_property(l_refer_cliente,"EDIT_COMPONENT","LTEXTFIELD")
			CALL _ADVPL_set_property(l_refer_cliente,"EDIT_PROPERTY","LENGTH",15)
			CALL _ADVPL_set_property(l_refer_cliente,"EDIT_PROPERTY","VALID","geo1027_valid_cod_cidade3")
			CALL _ADVPL_set_property(l_refer_cliente,"EDITABLE", TRUE)
		
			#-- Zoom
			LET l_refer_zoom_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_refer_tabela_funil)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"COLUMN_SIZE",10)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"EDITABLE",true)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"NO_VARIABLE",TRUE)
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"IMAGE", "BTPESQ")
			CALL _ADVPL_set_property(l_refer_zoom_cliente,"BEFORE_EDIT_EVENT","geo1027_zoom_cidade3")
			 
			let l_ind = 0 
			for l_ind = 1 to 999
			   if ma_funil_cidade[l_ind].cod_cidade is null or   ma_funil_cidade[l_ind].cod_cidade = ' ' then
			      exit for
			   end if
			end for
			let l_ind = l_ind - 1
			  
			CALL _ADVPL_set_property(m_refer_tabela_funil,"SET_ROWS",ma_funil_cidade,0)
	end case
			
	CALL _ADVPL_set_property(m_refer_tabela_funil,"ITEM_COUNT",l_ind)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"REFRESH")

   
      
	CALL _ADVPL_get_property(l_botao_find,"DO_CLICK")
	CALL _ADVPL_set_property(m_form_funil,"ACTIVATE",TRUE)

END FUNCTION


#--------------------------------------------------------------------#
function geo1027_entrada_dados_funil()
#--------------------------------------------------------------------#
   
    
end function
 
#--------------------------------------------------------------------#
function geo1027_confirmar_funil()
#--------------------------------------------------------------------#
	 CALL _ADVPL_set_property(m_form_funil,"ACTIVATE",FALSE)
end function

#--------------------------------------------------------------------#
function geo1027_cancela_funil()
#--------------------------------------------------------------------#
	 CALL _ADVPL_set_property(m_form_funil,"ACTIVATE",FALSE)
end function


 
 
