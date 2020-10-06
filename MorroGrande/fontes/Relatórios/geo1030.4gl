#-----------------------------------------------------------------#
# MODULO..: GEO                                                   #
# SISTEMA.: RELATORIO DE COMISSAO                                 #
# PROGRAMA: geo1030                                               #
# AUTOR...: EVANDRO SIMENES                                       #
# DATA....: 05/08/2016                                            #
#-----------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_versao            CHAR(18)
   DEFINE p_cod_empresa       LIKE empresa.cod_empresa
   DEFINE p_user              LIKE usuarios.cod_usuario
   
END GLOBALS

	DEFINE ma_resp           ARRAY[5000] OF RECORD
             cod_repres            DECIMAL(4,0)
           , nom_repres            CHAR(76)
           , raz_social char(76)
                                 END RECORD
   
   DEFINE m_ind                     INTEGER
   DEFINE m_form_principal          VARCHAR(10)
   DEFINE m_toolbar                 VARCHAR(10)
   DEFINE m_botao_informar          VARCHAR(10)
   DEFINE m_botao_processar         VARCHAR(10)
   DEFINE m_botao_quit              VARCHAR(10)
   DEFINE m_status_bar              VARCHAR(10)
   DEFINE m_panel_1                 VARCHAR(10)
   DEFINE m_panel_reference1        VARCHAR(10)
   DEFINE m_layoutmanager_refence_1 VARCHAR(10)
   DEFINE m_refer_cod_manifesto     VARCHAR(10)
   DEFINE m_refer_tipo_relat        VARCHAR(10)
   DEFINE m_refer_data_de           VARCHAR(10)
   DEFINE m_refer_data_ate          VARCHAR(10)
   DEFINE m_refer_cod_resp          VARCHAR(10)
   #DEFINE m_zoom_item               VARCHAR(10)
   DEFINE m_refer_campos            VARCHAR(10)
   DEFINE m_ind_carga               INTEGER
   DEFINE m_consulta_ativa          INTEGER
   DEFINE m_page_length             INTEGER
   DEFINE m_cod_repres              DECIMAL(4,0)
   DEFINE m_zoom_resp               VARCHAR(10)
   DEFINE m_tipo_relat_cargas       CHAR(1)
   DEFINE lr_total_linha          RECORD
            qtd_item 		DECIMAL(15,2),
            val_tot_item 	DECIMAL(15,2),
            val_fixa 		DECIMAL(15,2),
            val_var 		DECIMAL(15,2),
            val_comissao 	DECIMAL(15,2),
            qtd_item2 		DECIMAL(15,2),
            val_tot_item2 	DECIMAL(15,2),
            val_var2 		DECIMAL(15,2),
            val_comissao2 	DECIMAL(15,2),
            qtd_item3 		DECIMAL(15,2),
            val_tot_item3 	DECIMAL(15,2),
            val_comissao3 	DECIMAL(15,2)
         END RECORD
         
  
      DEFINE lr_total_vendedor          RECORD
            qtd_item 		DECIMAL(15,2),
            val_tot_item 	DECIMAL(15,2),
            val_fixa 		DECIMAL(15,2),
            val_var 		DECIMAL(15,2),
            val_comissao 	DECIMAL(15,2),
            qtd_item2 		DECIMAL(15,2),
            val_tot_item2 	DECIMAL(15,2),
            val_var2 		DECIMAL(15,2),
            val_comissao2 	DECIMAL(15,2),
            qtd_item3 		DECIMAL(15,2),
            val_tot_item3 	DECIMAL(15,2),
            val_comissao3 	DECIMAL(15,2)
         END RECORD
         
  
      DEFINE lr_total_geral          RECORD
            qtd_item 		DECIMAL(15,2),
            val_tot_item 	DECIMAL(15,2),
            val_fixa 		DECIMAL(15,2),
            val_var 		DECIMAL(15,2),
            val_comissao 	DECIMAL(15,2),
            qtd_item2 		DECIMAL(15,2),
            val_tot_item2 	DECIMAL(15,2),
            val_var2 		DECIMAL(15,2),
            val_comissao2 	DECIMAL(15,2),
            qtd_item3 		DECIMAL(15,2),
            val_tot_item3 	DECIMAL(15,2),
            val_comissao3 	DECIMAL(15,2)
         END RECORD
   DEFINE mr_total_geral          RECORD
            val_vista       DECIMAL(15,2),
            val_prazo       DECIMAL(15,2),
            tot_vendas      DECIMAL(15,2),
            val_cheques     DECIMAL(15,2),
            val_dinheiro    DECIMAL(15,2),
            val_despesas    DECIMAL(15,2),
            val_cobranca    DECIMAL(15,2),
            val_outros      DECIMAL(15,2),
            val_diferenca   DECIMAL(15,2)
         END RECORD
   
   DEFINE mr_tela RECORD
   			 cod_empresa   CHAR(2),
             tipo_relat    CHAR(1),
             cod_manifesto INTEGER,
             data_de       DATE,
             data_ate      DATE,
             cod_resp      DECIMAL(4,0),
             den_resp      CHAR(76)
         END RECORD
   
   DEFINE ma_carga ARRAY[9999] OF RECORD
              num_remessa   LIKE fat_nf_mestre.nota_fiscal,
              ser_remessa   LIKE fat_nf_mestre.serie_nota_fiscal,
              cod_item      CHAR(15),
              den_item      CHAR(76),
              unid_med      CHAR(3),
              qtd_remessa   DECIMAL(17,6),
              qtd_vendido   DECIMAL(17,6),
              qtd_retornado DECIMAL(17,6),
              qtd_diferenca DECIMAL(17,6)
           END RECORD
   
#-------------------#
 FUNCTION geo1030()
#-------------------#

   DEFINE l_label                      VARCHAR(50)
        , l_status                     SMALLINT

   CALL fgl_setenv("ADVPL","1")
   CALL LOG_connectDatabase("DEFAULT")

   CALL log1400_isolation()
   CALL log0180_conecta_usuario()


   CALL LOG_initApp('VDPLOG') RETURNING l_status


   LET m_ind = 0
 
#let p_user = 'admlog'
#let p_cod_empresa = '01'
   IF NOT l_status THEN
      CALL geo1030_tela()
   END IF

END FUNCTION

#-------------------------------------#
FUNCTION geo1030_args(l_tipo_relat, l_cod_manifesto)
#-------------------------------------#
   DEFINE l_cod_manifesto       INTEGER
   DEFINE l_tipo_relat          CHAR(1)
   
   LET mr_tela.cod_manifesto = l_cod_manifesto
   LET mr_tela.tipo_relat    = l_tipo_relat
   
   CALL geo1030_valid_cod_manifesto()
   
   LET m_consulta_ativa = TRUE
   CALL geo1030_tela()
   
END FUNCTION 

#-------------------#
 FUNCTION geo1030_tela()
#-------------------#

   DEFINE l_label        VARCHAR(50)
        , l_splitter     VARCHAR(50)
        , l_status       SMALLINT
        , l_panel_center VARCHAR(10)
        , l_tst CHAR(99)
     
     
   #cria janela principal do tipo LDIALOG
   LET m_form_principal = _ADVPL_create_component(NULL,"LDIALOG")
   CALL _ADVPL_set_property(m_form_principal,"TITLE","RELATORIO DE COMISSAO")
   CALL _ADVPL_set_property(m_form_principal,"ENABLE_ESC_CLOSE",FALSE)
   CALL _ADVPL_set_property(m_form_principal,"SIZE",500,310)#   1024,725)

   LET m_toolbar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_principal)

   LET m_botao_informar = _ADVPL_create_component(NULL,"LINFORMBUTTON",m_toolbar)
   CALL _ADVPL_set_property(m_botao_informar,"EVENT","geo1030_informar")
   CALL _ADVPL_set_property(m_botao_informar,"CONFIRM_EVENT","geo1030_confirma_informar")
   CALL _ADVPL_set_property(m_botao_informar,"CANCEL_EVENT","geo1030_cancela_informar")

   LET m_botao_processar = _ADVPL_create_component(NULL,"LPROCESSBUTTON",m_toolbar)
   CALL _ADVPL_set_property(m_botao_processar,"EVENT","geo1030_processar")
     
   LET m_botao_quit = _ADVPL_create_component(NULL,"LQUITBUTTON",m_toolbar)
   LET m_status_bar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_principal)

   LET m_panel_1 = _ADVPL_create_component(NULL,"LPANEL",m_form_principal)
   CALL _ADVPL_set_property(m_panel_1,"ALIGN","TOP")
   CALL _ADVPL_set_property(m_panel_1,"HEIGHT",200)
      
   #cria panel  
   LET m_panel_reference1 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel_1)
   CALL _ADVPL_set_property(m_panel_reference1,"TITLE","RELATORIO DE COMISSAO")
   CALL _ADVPL_set_property(m_panel_reference1,"ALIGN","CENTER")
   #CALL _ADVPL_set_property(m_panel_reference2,"HEIGHT",900)
     
   LET m_layoutmanager_refence_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_reference1)
   CALL _ADVPL_set_property(m_layoutmanager_refence_1,"MARGIN",TRUE)
   CALL _ADVPL_set_property(m_layoutmanager_refence_1,"COLUMNS_COUNT",2)
   
   
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
   CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")
   CALL _ADVPL_set_property(l_label,"SIZE",100,15)
   CALL _ADVPL_set_property(l_label,"POSITION",10,30)
   CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
   LET m_refer_cod_manifesto = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
   CALL _ADVPL_set_property(m_refer_cod_manifesto,"VARIABLE",mr_tela,"cod_empresa")
   CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_cod_manifesto,"POSITION",120,29)
    
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
   CALL _ADVPL_set_property(l_label,"TEXT","Período De:")
   CALL _ADVPL_set_property(l_label,"SIZE",100,15)
   CALL _ADVPL_set_property(l_label,"POSITION",10,60)
   CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
   LET m_refer_data_de = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel_reference1)
   CALL _ADVPL_set_property(m_refer_data_de,"VARIABLE",mr_tela,"data_de")
   CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_data_de,"POSITION",120,59)
    
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
   CALL _ADVPL_set_property(l_label,"TEXT","Até:")
   CALL _ADVPL_set_property(l_label,"SIZE",100,15)
   CALL _ADVPL_set_property(l_label,"POSITION",300,60)
   CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
   LET m_refer_data_ate = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel_reference1)
   CALL _ADVPL_set_property(m_refer_data_ate,"VARIABLE",mr_tela,"data_ate")
   CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_data_ate,"POSITION",349,59)
    
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
   CALL _ADVPL_set_property(l_label,"TEXT","Vendedor:")
   CALL _ADVPL_set_property(l_label,"SIZE",100,15)
   CALL _ADVPL_set_property(l_label,"POSITION",10,92)
   CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
   LET m_refer_cod_resp = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
   CALL _ADVPL_set_property(m_refer_cod_resp,"VARIABLE",mr_tela,"cod_resp")
   CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_cod_resp,"LENGTH",4)
   CALL _ADVPL_set_property(m_refer_cod_resp,"POSITION",120,89)
   
   LET m_zoom_resp = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_reference1)
   CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_zoom_resp,"POSITION",211,89)
   CALL _ADVPL_set_property(m_zoom_resp,"IMAGE", "BTPESQ")
   CALL _ADVPL_set_property(m_zoom_resp,"CLICK_EVENT","geo1030_zoom_resp")
   CALL _ADVPL_set_property(m_zoom_resp,"SIZE",24,20)
   CALL _ADVPL_set_property(m_zoom_resp,"TOOLTIP","Zoom Responsável")
   
   LET m_refer_campos = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
   CALL _ADVPL_set_property(m_refer_campos,"VARIABLE",mr_tela,"den_resp")
   CALL _ADVPL_set_property(m_refer_campos,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_campos,"LENGTH",25)
   CALL _ADVPL_set_property(m_refer_campos,"POSITION",241,89)
   
   LET m_refer_tipo_relat = _ADVPL_create_component(NULL,"LRADIOGROUP",m_panel_reference1)
   CALL _ADVPL_set_property(m_refer_tipo_relat,"VARIABLE", mr_tela, "tipo_relat")
   CALL _ADVPL_set_property(m_refer_tipo_relat,"POSITION",120,120)
   CALL _ADVPL_set_property(m_refer_tipo_relat,"ENABLE", FALSE)
   CALL _ADVPL_set_property(m_refer_tipo_relat,"ADD_RADIO_BUTTON","S","Sintético")
   CALL _ADVPL_set_property(m_refer_tipo_relat,"ADD_RADIO_BUTTON","A","Analítico")
   
   CALL _ADVPL_set_property(m_form_principal,"ACTIVATE",TRUE)

 END FUNCTION

#--------------------------#
FUNCTION geo1030_informar()
#--------------------------#
   DEFINE l_data    CHAR(10)
   INITIALIZE mr_tela.* to null
   LET mr_tela.tipo_relat = "S"
   #CALL geo1030_valid_tipo_relat()
   LET mr_tela.cod_empresa = p_cod_empresa
   
   LET l_data = "01/",EXTEND(TODAY,MONTH TO MONTH),"/",EXTEND(TODAY,YEAR TO YEAR)
   LET mr_tela.data_de = l_data
   LET mr_tela.data_ate = TODAY
   
   CALL geo1030_habilita_campos_manutencao(TRUE,'INCLUIR')

END FUNCTION

#------------------------------------#
function geo1030_confirma_informar()
#------------------------------------#

   IF NOT geo1030_valid_cod_manifesto() THEN
      RETURN FALSE
   END IF 
   CALL geo1030_habilita_campos_manutencao(FALSE,'INCLUIR')
   LET m_consulta_ativa = TRUE
   
   CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",FALSE)
   #CALL _ADVPL_set_property(m_zoom_item,"ENABLE",FALSE)
   RETURN TRUE
end function

#-----------------------------------#
function geo1030_cancela_informar()
#-----------------------------------#
   call geo1030_habilita_campos_manutencao(FALSE,'INCLUIR')
   LET m_consulta_ativa = FALSE
   
   CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",FALSE)
   #CALL _ADVPL_set_property(m_zoom_item,"ENABLE",FALSE)
   RETURN TRUE
end function

#-------------------------------------------------------------#
function geo1030_habilita_campos_manutencao(l_status,l_funcao)
#-------------------------------------------------------------#
   DEFINE l_status smallint
   define l_funcao char(20)
   
   #CALL _ADVPL_set_property(m_refer_tipo_relat,"ENABLE",l_status)
   
   #CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_tipo_relat,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",l_status)
   #CALL _ADVPL_set_property(m_zoom_item,"ENABLE",l_status) 
   
   
END FUNCTION

#--------------------------------------------------------------------#
FUNCTION geo1030_exibe_mensagem_barra_status(l_mensagem,l_tipo_mensagem)
#--------------------------------------------------------------------#

   DEFINE l_mensagem               CHAR(500),
          l_tipo_mensagem          CHAR(010),
          l_tipo_mensagem_original CHAR(015)

   LET l_tipo_mensagem_original = LOG_retorna_tipo_mensagem_original(UPSHIFT(l_tipo_mensagem),TRUE)
   CALL _ADVPL_set_property(m_status_bar,l_tipo_mensagem_original CLIPPED," "||l_mensagem CLIPPED)

 END FUNCTION

#---------------------------------------#
 function geo1030_zoom_manifesto()
#---------------------------------------#
   DEFINE l_where_clause   CHAR(1000)
   DEFINE l_ind            SMALLINT
   define l_zoom_item varchar(10)
   define l_selecao integer 
   define l_cod_cliente char(15)
   
   INITIALIZE ma_manifesto TO NULL
   call ip_zoom_zoom_cadastro_3_colunas('geo_manifesto',
                                'cod_manifesto',
                                '2',
                                'cod_resp',
                                '20',
                                'dat_fechamento',
                                '10',
                                'Manifesto: ',
                                'Responsável: ',
                                'Fechamento: ',
                                'cod_empresa',
                                ' AND sit_manifesto = "E" ORDER BY dat_fechamento DESC ')
    
   LET mr_tela.cod_manifesto = ip_zoom_3_get_valor()
   
 end function
 
#---------------------------------------#
function geo1030_zoom_resp()
#---------------------------------------#
   DEFINE l_where_clause   CHAR(1000)
   DEFINE l_ind            SMALLINT
   define l_zoom_item varchar(10)
   define l_selecao integer 
   define l_cod_cliente char(15)
   
   INITIALIZE ma_resp TO NULL
   
   LET l_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
   CALL _ADVPL_set_property(l_zoom_item,"ZOOM_TYPE",1)
   CALL _ADVPL_set_property(l_zoom_item,"ARRAY_RECORD_RETURN",ma_resp)
   CALL _ADVPL_get_property(l_zoom_item,"INIT_ZOOM","zoom_representante")
   
   let mr_tela.cod_resp = ma_resp[1].cod_repres
   let mr_tela.den_resp = ma_resp[1].nom_repres
   
 end function
 
 #---------------------------------#
 FUNCTION geo1030_carrega_cargas()
 #---------------------------------#
    DEFINE l_tip_manifesto     CHAR(1)
    
    SELECT tip_manifesto
      INTO l_tip_manifesto
      FROM geo_manifesto
     WHERE cod_empresa = p_cod_empresa
       AND cod_manifesto = mr_tela.cod_manifesto
    
    
    DECLARE cq_cargas1 CURSOR FOR
    SELECT d.num_remessa,
           d.ser_remessa,
           a.cod_item,
           a.den_item,
           a.cod_unid_med,
           d.qtd_movto #QUANTIDADE REMESSA
      FROM item a, fat_nf_item b, fat_nf_mestre c, geo_remessa_movto d
     WHERE a.cod_empresa = b.empresa
       AND b.empresa = c.empresa
       AND c.empresa = d.cod_empresa
       AND a.cod_item = b.item
       AND b.trans_nota_fiscal = c.trans_nota_fiscal
       AND c.trans_nota_fiscal = d.trans_remessa
       AND d.tipo_movto = 'E'
       AND a.cod_item = d.cod_item
       AND d.cod_manifesto = mr_tela.cod_manifesto
       AND d.cod_empresa = p_cod_empresa
       AND c.sit_nota_fiscal = 'N'
    
    LET m_ind_carga = 1
    FOREACH cq_cargas1 INTO ma_carga[m_ind_carga].*
       IF l_tip_manifesto = "R" THEN
	       SELECT SUM(a.qtd_movto)
	         INTO ma_carga[m_ind_carga].qtd_vendido
	         FROM geo_remessa_movto a, fat_nf_mestre b
	        WHERE a.cod_empresa = p_cod_empresa
	          AND a.cod_manifesto = mr_tela.cod_manifesto
	          AND a.tipo_movto = 'S'
	          AND a.cod_item = ma_carga[m_ind_carga].cod_item
	          AND a.num_remessa = ma_carga[m_ind_carga].num_remessa
	          AND a.ser_remessa = ma_carga[m_ind_carga].ser_remessa
	          AND a.cod_empresa = b.empresa
	          AND a.trans_nota_fiscal = b.trans_nota_fiscal
	          AND b.sit_nota_fiscal = 'N'
	   ELSE
	      SELECT SUM(a.qtd_movto)
	         INTO ma_carga[m_ind_carga].qtd_vendido
	         FROM geo_remessa_movto a, fat_nf_mestre b
	        WHERE a.cod_empresa = p_cod_empresa
	          AND a.cod_manifesto = mr_tela.cod_manifesto
	          AND a.tipo_movto = 'E'
	          AND a.cod_item = ma_carga[m_ind_carga].cod_item
	          AND a.num_remessa = ma_carga[m_ind_carga].num_remessa
	          AND a.ser_remessa = ma_carga[m_ind_carga].ser_remessa
	          AND a.cod_empresa = b.empresa
	          AND a.trans_remessa = b.trans_nota_fiscal
	          AND b.sit_nota_fiscal = 'N'
	   END IF 
          
       IF ma_carga[m_ind_carga].qtd_vendido IS NULL OR ma_carga[m_ind_carga].qtd_vendido = "" THEN
          LET ma_carga[m_ind_carga].qtd_vendido = 0
       END IF 
       SELECT SUM(qtd_movto)
         INTO ma_carga[m_ind_carga].qtd_retornado
         FROM geo_remessa_movto
        WHERE cod_empresa = p_cod_empresa
          AND cod_manifesto = mr_tela.cod_manifesto
          AND tipo_movto = 'R'
          AND cod_item = ma_carga[m_ind_carga].cod_item
          AND num_remessa = ma_carga[m_ind_carga].num_remessa
          AND ser_remessa = ma_carga[m_ind_carga].ser_remessa
       IF ma_carga[m_ind_carga].qtd_retornado IS NULL OR ma_carga[m_ind_carga].qtd_retornado = "" THEN
          LET ma_carga[m_ind_carga].qtd_retornado = 0
       END IF 
       
       LET ma_carga[m_ind_carga].qtd_diferenca = ma_carga[m_ind_carga].qtd_remessa - (ma_carga[m_ind_carga].qtd_vendido + ma_carga[m_ind_carga].qtd_retornado)
       
       LET m_ind_carga = m_ind_carga + 1
    END FOREACH
    IF m_ind_carga > 1 THEN
       LET m_ind_carga = m_ind_carga - 1
    END IF 
 END FUNCTION
 #----------------------------------#
FUNCTION geo1030_valid_tipo_relat()
#----------------------------------#
    DEFINE l_status     SMALLINT
    DEFINE l_tipo_ant   CHAR(1)
    DEFINE l_data       CHAR(10)
    
    LET l_status = TRUE
    
    LET l_tipo_ant = mr_tela.tipo_relat
    
    INITIALIZE mr_tela.* TO NULL
    
    LET mr_tela.tipo_relat = l_tipo_ant
    
    
          CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",FALSE)
          CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",FALSE)
          CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",FALSE)
          CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",FALSE)
  
   
END FUNCTION
 
#---------------------------------------#
 function geo1030_valid_cod_manifesto()
#---------------------------------------#
   DEFINE l_cnpj LIKE clientes.num_cgc_cpf
   
   
   {IF mr_tela.tipo_relat = "A" THEN
	   SELECT a.cod_resp, b.nom_cliente
	     INTO mr_tela.cod_resp, mr_tela.den_resp
	     FROM geo_manifesto a, clientes b
	    WHERE a.cod_empresa = p_cod_empresa
	      AND a.cod_manifesto = mr_tela.cod_manifesto
	      AND b.cod_cliente = a.cod_resp
	
	   IF sqlca.sqlcode = 100 THEN
	      CALL _ADVPL_message_box("Manifesto não encontrado.")
	      RETURN FALSE
	   END IF
   END IF }
   RETURN TRUE
 
 end function 
 

 
#-------------------------------------#
FUNCTION geo1030_processar()
#-------------------------------------#
         CALL LOG_progress_start("Geração de relatório de comissão","geo1030_relat_comis","PROCESS")
   RETURN TRUE
END FUNCTION
#-------------------------------------#
 FUNCTION geo1030_relat_comis()
#-------------------------------------#
   DEFINE l_options         SMALLINT
   CALL StartReport("geo1030_relatorio_comissao","geo1030","Relatório de Comissão",220,TRUE,TRUE)
   RETURN TRUE
END FUNCTION

#-------------------------------------#
FUNCTION geo1030_relatorio_comissao(reportfile)
#-------------------------------------#
   ### PRESTACAO DE CONTAS - RESUMO DE VENDAS
   DEFINE reportfile          CHAR(250)
   DEFINE l_sql,l_sql2,l_sql3               CHAR(999)
   DEFINE l_tip_manifesto     CHAR(1)
   DEFINE l_tipo         CHAR(10)
   DEFINE lr_dados          RECORD
            cod_vendedor  	DECIMAL(4,0),
            nom_vendedor  	CHAR(36),
            linha		  	CHAR(36),
            cod_item 		CHAR(15),
            den_item 		CHAR(76),
            qtd_item 		DECIMAL(15,2),
            val_tot_item 	DECIMAL(15,2),
            val_fixa 		DECIMAL(15,2),
            val_var 		DECIMAL(15,2),
            val_comissao 	DECIMAL(15,2),
            qtd_item2 		DECIMAL(15,2),
            val_tot_item2 	DECIMAL(15,2),
            val_var2 		DECIMAL(15,2),
            val_comissao2 	DECIMAL(15,2),
            qtd_item3 		DECIMAL(15,2),
            val_tot_item3 	DECIMAL(15,2),
            val_comissao3 	DECIMAL(15,2)
        END RECORD
    DEFINE lr_dados2          RECORD
            nota_fiscal  	INTEGER,
            serie		  	CHAR(3),
            cod_vendedor  	DECIMAL(4,0),
            nom_vendedor  	CHAR(36),
            linha		  	CHAR(36),
            cod_item 		CHAR(15),
            den_item 		CHAR(76),
            qtd_item 		DECIMAL(15,2),
            val_tot_item 	DECIMAL(15,2),
            val_fixa 		DECIMAL(15,2),
            val_var 		DECIMAL(15,2),
            val_comissao 	DECIMAL(15,2),
            qtd_item2 		DECIMAL(15,2),
            val_tot_item2 	DECIMAL(15,2),
            val_var2 		DECIMAL(15,2),
            val_comissao2 	DECIMAL(15,2),
            qtd_item3 		DECIMAL(15,2),
            val_tot_item3 	DECIMAL(15,2),
            val_comissao3 	DECIMAL(15,2)
        END RECORD
   
    LET lr_total_linha.qtd_item 	 = 0
    LET lr_total_linha.val_tot_item  = 0
    LET lr_total_linha.val_fixa 	 = 0
    LET lr_total_linha.val_var 		 = 0
    LET lr_total_linha.val_comissao  = 0
	LET lr_total_linha.qtd_item2 	 = 0
    LET lr_total_linha.val_tot_item2 = 0
    LET lr_total_linha.val_var2 	 = 0
    LET lr_total_linha.val_comissao2 = 0
    LET lr_total_linha.qtd_item3 	 = 0
    LET lr_total_linha.val_tot_item3 = 0
    LET lr_total_linha.val_comissao3 = 0
    
    LET lr_total_vendedor.qtd_item 	 = 0
    LET lr_total_vendedor.val_tot_item  = 0
    LET lr_total_vendedor.val_fixa 	 = 0
    LET lr_total_vendedor.val_var 		 = 0
    LET lr_total_vendedor.val_comissao  = 0
	LET lr_total_vendedor.qtd_item2 	 = 0
    LET lr_total_vendedor.val_tot_item2 = 0
    LET lr_total_vendedor.val_var2 	 = 0
    LET lr_total_vendedor.val_comissao2 = 0
    LET lr_total_vendedor.qtd_item3 	 = 0
    LET lr_total_vendedor.val_tot_item3 = 0
    LET lr_total_vendedor.val_comissao3 = 0
    
    LET lr_total_geral.qtd_item 	 = 0
    LET lr_total_geral.val_tot_item  = 0
    LET lr_total_geral.val_fixa 	 = 0
    LET lr_total_geral.val_var 		 = 0
    LET lr_total_geral.val_comissao  = 0
	LET lr_total_geral.qtd_item2 	 = 0
    LET lr_total_geral.val_tot_item2 = 0
    LET lr_total_geral.val_var2 	 = 0
    LET lr_total_geral.val_comissao2 = 0
    LET lr_total_geral.qtd_item3 	 = 0
    LET lr_total_geral.val_tot_item3 = 0
    LET lr_total_geral.val_comissao3 = 0
    
    
   IF mr_tela.tipo_relat = "S" THEN
   		LET m_page_length = ReportPageLength("geo1030")
   		START REPORT geo1030_report_sintetico TO reportfile
   		
   		LET l_sql = " SELECT vendedor, ",
					       " nom_vend, ",
					       " linha, ",
					       " item,  ",
					       " des_item ", 
					       #" SUM(qtd_item), ", 
					       #" SUM(val_liquido_item), ", 
					       #" '0',  ",
					       #" SUM(val_comis), ", 
					       #" SUM(val_comis) ",
					  " FROM lhp_comissao ",
					 " WHERE emissao >= '",mr_tela.data_de,"' ",
					   " AND emissao <= '",mr_tela.data_ate,"' ",
					   " AND empresa = '",mr_tela.cod_empresa,"' "
					   #" AND tipo = 'SMART' "
					 
		IF mr_tela.cod_resp IS NOT NULL AND mr_tela.cod_resp <> " " AND mr_tela.cod_resp <> 0 THEN
			LET l_sql = l_sql CLIPPED," AND vendedor = '",mr_tela.cod_resp,"'"
		END IF 
		
		LET l_sql = l_sql CLIPPED,
					 " GROUP BY vendedor, nom_vend, linha, item, des_item ",
					 " ORDER BY nom_vend, linha, item"  
   		
   		
   		PREPARE var_sintetico FROM l_sql
   		DECLARE cq_sintetico CURSOR FOR var_sintetico
	   	
	    FOREACH cq_sintetico INTO   lr_dados.cod_vendedor,
						            lr_dados.nom_vendedor,
						            lr_dados.linha,
						            lr_dados.cod_item,
						            lr_dados.den_item
				
				
	    		LET lr_dados.val_fixa = 0
	    		LET l_sql2 = " SELECT SUM(qtd_item), ", 
							       " SUM(val_liquido_item), ", 
							       " SUM(val_comis), ", 
							       " SUM(val_comis) ",
							  " FROM lhp_comissao ",
							 " WHERE emissao >= '",mr_tela.data_de,"' ",
							   " AND emissao <= '",mr_tela.data_ate,"' ",
							   " AND empresa = '",mr_tela.cod_empresa,"' ",
							   " AND tipo = 'BALCAO' ",
							   " AND vendedor = '",lr_dados.cod_vendedor,"' ",
							   " AND item = '",lr_dados.cod_item,"'"
				 			 
		    	PREPARE var_sintetico2 FROM l_sql2
		    	DECLARE cq_sintetico2 CURSOR FOR var_sintetico2
		    	OPEN cq_sintetico2
		    	FETCH cq_sintetico2 INTO  lr_dados.qtd_item2,
								            lr_dados.val_tot_item2,
								            lr_dados.val_var2,
								            lr_dados.val_comissao2
				IF lr_dados.qtd_item2 IS NULL OR lr_dados.qtd_item2 = " " THEN
					LET lr_dados.qtd_item2 = 0
				END IF      
				IF lr_dados.val_tot_item2 IS NULL OR lr_dados.val_tot_item2 = " " THEN
					LET lr_dados.val_tot_item2 = 0
				END IF      
				IF lr_dados.val_var2 IS NULL OR lr_dados.val_var2 = " " THEN
					LET lr_dados.val_var2 = 0
				END IF
				IF lr_dados.val_comissao2 IS NULL OR lr_dados.val_comissao2 = " " THEN
					LET lr_dados.val_comissao2 = 0
				END IF    
				
				CLOSE cq_sintetico2
		       	FREE cq_sintetico2
		    	
		    	
				LET l_sql3 = " SELECT SUM(qtd_item), ", 
							       " SUM(val_liquido_item), ", 
							       " SUM(val_comis), ", 
							       " SUM(val_comis) ",
							  " FROM lhp_comissao ",
							 " WHERE emissao >= '",mr_tela.data_de,"' ",
							   " AND emissao <= '",mr_tela.data_ate,"' ",
							   " AND empresa = '",mr_tela.cod_empresa,"' ",
							   " AND tipo = 'SMART' ",
							   " AND vendedor = '",lr_dados.cod_vendedor,"' ",
							   " AND item = '",lr_dados.cod_item,"'"
				 			 
		    	PREPARE var_sintetico3 FROM l_sql3
		    	DECLARE cq_sintetico3 CURSOR FOR var_sintetico3
		    	OPEN cq_sintetico3
		    	FETCH cq_sintetico3 INTO  lr_dados.qtd_item,
								            lr_dados.val_tot_item,
								            lr_dados.val_var,
								            lr_dados.val_comissao
				IF lr_dados.qtd_item IS NULL OR lr_dados.qtd_item = " " THEN
					LET lr_dados.qtd_item = 0
				END IF      
				IF lr_dados.val_tot_item IS NULL OR lr_dados.val_tot_item = " " THEN
					LET lr_dados.val_tot_item = 0
				END IF      
				IF lr_dados.val_var IS NULL OR lr_dados.val_var = " " THEN
					LET lr_dados.val_var = 0
				END IF      
				IF lr_dados.val_comissao IS NULL OR lr_dados.val_comissao = " " THEN
					LET lr_dados.val_comissao = 0
				END IF    
				
	       		CLOSE cq_sintetico3
		       	FREE cq_sintetico3
	       		
	       		#CALL _ADVPL_message_box("ITEM "||lr_dados.cod_item||" QTD1 "||lr_dados.qtd_item||" QTD2 "||lr_dados.qtd_item2)
	       		
	       		LET lr_dados.qtd_item3 = lr_dados.qtd_item2 + lr_dados.qtd_item
	        	LET lr_dados.val_tot_item3 = lr_dados.val_tot_item2 + lr_dados.val_tot_item 
	        	LET lr_dados.val_comissao3 = lr_dados.val_comissao2 + lr_dados.val_comissao
	       		OUTPUT TO REPORT geo1030_report_sintetico(lr_dados.*)
		       	
	    END FOREACH
	   
	    FINISH REPORT geo1030_report_sintetico
	   
	    CALL FinishReport("geo1030")
   ELSE
   		LET m_page_length = ReportPageLength("geo1030")
   		START REPORT geo1030_report_analitico TO reportfile
   		
   		LET l_sql = " SELECT nf, serie, vendedor, ",
					       " nom_vend, ",
					       " linha, ",
					       " item,  ",
					       " des_item ", 
					       #" SUM(qtd_item), ", 
					       #" SUM(val_liquido_item), ", 
					       #" '0',  ",
					       #" SUM(val_comis), ", 
					       #" SUM(val_comis) ",
					  " FROM lhp_comissao ",
					 " WHERE emissao >= '",mr_tela.data_de,"' ",
					   " AND emissao <= '",mr_tela.data_ate,"' ",
					   " AND empresa = '",mr_tela.cod_empresa,"' "
					   #" AND tipo = 'SMART' "
		
		IF mr_tela.cod_resp IS NOT NULL AND mr_tela.cod_resp <> " " AND mr_tela.cod_resp <> 0 THEN
			LET l_sql = l_sql CLIPPED," AND vendedor = '",mr_tela.cod_resp,"'"
		END IF 
		
		LET l_sql = l_sql CLIPPED,
					 " GROUP BY vendedor, nom_vend, linha, item, des_item, nf, serie ",
					 " ORDER BY nom_vend, linha, nf "  
   		
   		
   		PREPARE var_analitico FROM l_sql
   		DECLARE cq_analitico CURSOR FOR var_analitico
	   	
	    FOREACH cq_analitico INTO   lr_dados2.nota_fiscal,
						            lr_dados2.serie,
						            lr_dados2.cod_vendedor,
						            lr_dados2.nom_vendedor,
						            lr_dados2.linha,
						            lr_dados2.cod_item,
						            lr_dados2.den_item
	    	
	    	LET l_sql = " SELECT SUM(qtd_item), ", 
						       " SUM(val_liquido_item), ", 
						       " SUM(val_comis), ", 
						       " SUM(val_comis) ",
						  " FROM lhp_comissao ",
						 " WHERE emissao >= '",mr_tela.data_de,"' ",
						   " AND emissao <= '",mr_tela.data_ate,"' ",
						   " AND empresa = '",mr_tela.cod_empresa,"' ",
						   " AND tipo = 'BALCAO' ",
						   " AND vendedor = '",lr_dados2.cod_vendedor,"' ",
						   " AND item = '",lr_dados2.cod_item,"'",
						   " AND nf = '",lr_dados2.nota_fiscal,"'",
						   " AND serie = '",lr_dados2.serie,"'"
			 			 
	    	PREPARE var_analitico2 FROM l_sql
	    	DECLARE cq_analitico2 CURSOR FOR var_analitico2
	    	OPEN cq_analitico2
	    	FETCH cq_analitico2 INTO  lr_dados2.qtd_item2,
							            lr_dados2.val_tot_item2,
							            lr_dados2.val_var2,
							            lr_dados2.val_comissao2
			IF lr_dados2.qtd_item2 IS NULL OR lr_dados2.qtd_item2 = " " THEN
				LET lr_dados2.qtd_item2 = 0
			END IF      
			IF lr_dados2.val_tot_item2 IS NULL OR lr_dados2.val_tot_item2 = " " THEN
				LET lr_dados2.val_tot_item2 = 0
			END IF      
			IF lr_dados2.val_var2 IS NULL OR lr_dados2.val_var2 = " " THEN
				LET lr_dados2.val_var2 = 0
			END IF      
			IF lr_dados2.val_comissao2 IS NULL OR lr_dados2.val_comissao2 = " " THEN
				LET lr_dados2.val_comissao2 = 0
			END IF    
			
	       	CLOSE cq_analitico2
	       	FREE cq_analitico2
	       	
	       	
	       	LET l_sql = " SELECT SUM(qtd_item), ", 
						       " SUM(val_liquido_item), ", 
						       " SUM(val_comis), ", 
						       " SUM(val_comis) ",
						  " FROM lhp_comissao ",
						 " WHERE emissao >= '",mr_tela.data_de,"' ",
						   " AND emissao <= '",mr_tela.data_ate,"' ",
						   " AND empresa = '",mr_tela.cod_empresa,"' ",
						   " AND tipo = 'SMART' ",
						   " AND vendedor = '",lr_dados2.cod_vendedor,"' ",
						   " AND item = '",lr_dados2.cod_item,"'",
						   " AND nf = '",lr_dados2.nota_fiscal,"'",
						   " AND serie = '",lr_dados2.serie,"'"
			 			 
	    	PREPARE var_analitico3 FROM l_sql
	    	DECLARE cq_analitico3 CURSOR FOR var_analitico3
	    	OPEN cq_analitico3
	    	FETCH cq_analitico3 INTO  lr_dados2.qtd_item,
							            lr_dados2.val_tot_item,
							            lr_dados2.val_var,
							            lr_dados2.val_comissao
			IF lr_dados2.qtd_item IS NULL OR lr_dados2.qtd_item = " " THEN
				LET lr_dados2.qtd_item = 0
			END IF      
			IF lr_dados2.val_tot_item IS NULL OR lr_dados2.val_tot_item = " " THEN
				LET lr_dados2.val_tot_item = 0
			END IF      
			IF lr_dados2.val_var IS NULL OR lr_dados2.val_var = " " THEN
				LET lr_dados2.val_var = 0
			END IF      
			IF lr_dados2.val_comissao IS NULL OR lr_dados2.val_comissao = " " THEN
				LET lr_dados2.val_comissao = 0
			END IF    
			
	       	CLOSE cq_analitico3
	       	FREE cq_analitico3
	       	
	       	
	       	LET lr_dados2.qtd_item3 = lr_dados2.qtd_item2 + lr_dados2.qtd_item
        	LET lr_dados2.val_tot_item3 = lr_dados2.val_tot_item2 + lr_dados2.val_tot_item 
        	LET lr_dados2.val_comissao3 = lr_dados2.val_comissao2 + lr_dados2.val_comissao
        	
       		OUTPUT TO REPORT geo1030_report_analitico(lr_dados2.*)
	       	
	    END FOREACH
	   
	    FINISH REPORT geo1030_report_analitico
	   
	    CALL FinishReport("geo1030")
   END IF
    
   
END FUNCTION



#------------------------------#
 REPORT geo1030_report_sintetico(lr_relat)
#------------------------------#
  DEFINE lr_relat          RECORD
            cod_vendedor  	DECIMAL(4,0),
            nom_vendedor  	CHAR(36),
            linha		  	CHAR(36),
            cod_item 		CHAR(15),
            den_item 		CHAR(76),
            qtd_item 		DECIMAL(15,2),
            val_tot_item 	DECIMAL(15,2),
            val_fixa 		DECIMAL(15,2),
            val_var 		DECIMAL(15,2),
            val_comissao 	DECIMAL(15,2),
            qtd_item2 		DECIMAL(15,2),
            val_tot_item2 	DECIMAL(15,2),
            val_var2 		DECIMAL(15,2),
            val_comissao2 	DECIMAL(15,2),
            qtd_item3 		DECIMAL(15,2),
            val_tot_item3 	DECIMAL(15,2),
            val_comissao3 	DECIMAL(15,2)
         END RECORD
         
  
         
  
         
  DEFINE l_last_row          SMALLINT
  DEFINE l_den_empresa       LIKE empresa.den_empresa
  DEFINE l_condicao_ant      CHAR(50)
  DEFINE l_primeiro          SMALLINT
  DEFINE l_quantidade        DECIMAL(20,2)
  DEFINE l_total             DECIMAL(20,2)
  DEFINE l_geral             DECIMAL(20,2)
  DEFINE l_cod_repres        DECIMAL(4,0)
  DEFINE l_den_item          CHAR(40)
  
  
  OUTPUT
    RIGHT  MARGIN 0
    LEFT   MARGIN 0
    TOP    MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH m_page_length
    #ORDER EXTERNAL BY lr_relat.cod_resp
  
  
  
  FORMAT
    
       
    PAGE HEADER
       SELECT den_empresa
         INTO l_den_empresa
         FROM empresa
        WHERE cod_empresa = mr_tela.cod_empresa
       
       CALL ReportPageHeader("geo1030")
      
       PRINT COLUMN 001,p_cod_empresa," - ",l_den_empresa CLIPPED,
             COLUMN 095, "Período De: ",mr_tela.data_de," Até ",mr_tela.data_ate
       LET l_last_row = FALSE
         
       CALL ReportThinLine("geo1030")
       #SKIP 01 LINE
     
       PRINT COLUMN 002,lr_relat.nom_vendedor CLIPPED,
             COLUMN 072,"------------- PRONTA ENTREGA ------------ ",
             COLUMN 123,"--------------- PRE VENDA ---------------",
             COLUMN 174,"----------------- TOTAL -----------------"
            
       PRINT COLUMN 002,lr_relat.cod_vendedor,
             COLUMN 072,"QTDE",
             COLUMN 089,"VALOR",
             #COLUMN 086,"FIXA",
             #COLUMN 098,"VAR (N)",
             COLUMN 106,"TOT.COM",
             COLUMN 123,"QTDE",
             COLUMN 140,"VALOR",
             #COLUMN 154,"VAR (N)",
             COLUMN 157,"TOT.COM",
             COLUMN 174,"QTDE",
             COLUMN 191,"VALOR",
             COLUMN 208,"TOT.COM"
            CALL ReportThinLine("geo1030")
       
     
    BEFORE GROUP OF lr_relat.cod_vendedor
       SKIP TO TOP OF PAGE
       
    ON EVERY ROW
        LET lr_total_linha.qtd_item 	 = lr_total_linha.qtd_item 		+ lr_relat.qtd_item
        LET lr_total_linha.val_tot_item  = lr_total_linha.val_tot_item 	+ lr_relat.val_tot_item
        LET lr_total_linha.val_fixa 	 = lr_total_linha.val_fixa 		+ lr_relat.val_fixa
        LET lr_total_linha.val_var 		 = lr_total_linha.val_var 		+ lr_relat.val_var
        LET lr_total_linha.val_comissao  = lr_total_linha.val_comissao 	+ lr_relat.val_comissao
    	LET lr_total_linha.qtd_item2 	 = lr_total_linha.qtd_item2 	+ lr_relat.qtd_item2
        LET lr_total_linha.val_tot_item2 = lr_total_linha.val_tot_item2 + lr_relat.val_tot_item2
        LET lr_total_linha.val_var2 	 = lr_total_linha.val_var2 		+ lr_relat.val_var2
        LET lr_total_linha.val_comissao2 = lr_total_linha.val_comissao2 + lr_relat.val_comissao2
        LET lr_total_linha.qtd_item3 	 = lr_total_linha.qtd_item3 	+ lr_relat.qtd_item3
        LET lr_total_linha.val_tot_item3 = lr_total_linha.val_tot_item3 + lr_relat.val_tot_item3
        LET lr_total_linha.val_comissao3 = lr_total_linha.val_comissao3 + lr_relat.val_comissao3
    
    	LET lr_total_vendedor.qtd_item 	 = lr_total_vendedor.qtd_item 		+ lr_relat.qtd_item
        LET lr_total_vendedor.val_tot_item  = lr_total_vendedor.val_tot_item 	+ lr_relat.val_tot_item
        LET lr_total_vendedor.val_fixa 	 = lr_total_vendedor.val_fixa 		+ lr_relat.val_fixa
        LET lr_total_vendedor.val_var 		 = lr_total_vendedor.val_var 		+ lr_relat.val_var
        LET lr_total_vendedor.val_comissao  = lr_total_vendedor.val_comissao 	+ lr_relat.val_comissao
    	LET lr_total_vendedor.qtd_item2 	 = lr_total_vendedor.qtd_item2 	+ lr_relat.qtd_item2
        LET lr_total_vendedor.val_tot_item2 = lr_total_vendedor.val_tot_item2 + lr_relat.val_tot_item2
        LET lr_total_vendedor.val_var2 	 = lr_total_vendedor.val_var2 		+ lr_relat.val_var2
        LET lr_total_vendedor.val_comissao2 = lr_total_vendedor.val_comissao2 + lr_relat.val_comissao2
        LET lr_total_vendedor.qtd_item3 	 = lr_total_vendedor.qtd_item3 	+ lr_relat.qtd_item3
        LET lr_total_vendedor.val_tot_item3 = lr_total_vendedor.val_tot_item3 + lr_relat.val_tot_item3
        LET lr_total_vendedor.val_comissao3 = lr_total_vendedor.val_comissao3 + lr_relat.val_comissao3
    
    	LET lr_total_geral.qtd_item 	 = lr_total_geral.qtd_item 		+ lr_relat.qtd_item
        LET lr_total_geral.val_tot_item  = lr_total_geral.val_tot_item 	+ lr_relat.val_tot_item
        LET lr_total_geral.val_fixa 	 = lr_total_geral.val_fixa 		+ lr_relat.val_fixa
        LET lr_total_geral.val_var 		 = lr_total_geral.val_var 		+ lr_relat.val_var
        LET lr_total_geral.val_comissao  = lr_total_geral.val_comissao 	+ lr_relat.val_comissao
    	LET lr_total_geral.qtd_item2 	 = lr_total_geral.qtd_item2 	+ lr_relat.qtd_item2
        LET lr_total_geral.val_tot_item2 = lr_total_geral.val_tot_item2 + lr_relat.val_tot_item2
        LET lr_total_geral.val_var2 	 = lr_total_geral.val_var2 		+ lr_relat.val_var2
        LET lr_total_geral.val_comissao2 = lr_total_geral.val_comissao2 + lr_relat.val_comissao2
        LET lr_total_geral.qtd_item3 	 = lr_total_geral.qtd_item3 	+ lr_relat.qtd_item3
        LET lr_total_geral.val_tot_item3 = lr_total_geral.val_tot_item3 + lr_relat.val_tot_item3
        LET lr_total_geral.val_comissao3 = lr_total_geral.val_comissao3 + lr_relat.val_comissao3
    
       IF LENGTH(lr_relat.den_item) > 42 THEN
          LET l_den_item = lr_relat.den_item[1,42],"..."
       ELSE
          LET l_den_item = lr_relat.den_item
       END IF 
       PRINT COLUMN 002, lr_relat.cod_item CLIPPED,
             COLUMN 011, l_den_item CLIPPED,
             COLUMN 065, lr_relat.qtd_item USING "-------&.&&",
             COLUMN 083, lr_relat.val_tot_item USING "-------&.&&",
             #COLUMN 077, lr_relat.val_fixa USING "-------&.&&",
             #COLUMN 092, lr_relat.val_var USING "-------&.&&",
             COLUMN 102, lr_relat.val_comissao USING "-------&.&&",
             COLUMN 116, lr_relat.qtd_item2 USING "-------&.&&",
             COLUMN 134, lr_relat.val_tot_item2 USING "-------&.&&",
             #COLUMN 149, lr_relat.val_var2 USING "-------&.&&",
             COLUMN 153, lr_relat.val_comissao2 USING "-------&.&&",
             COLUMN 167, lr_relat.qtd_item3 USING "-------&.&&",
             COLUMN 185, lr_relat.val_tot_item3 USING "-------&.&&",
             COLUMN 204, lr_relat.val_comissao3 USING "-------&.&&"
        
	
    AFTER GROUP OF lr_relat.cod_vendedor
       PRINT COLUMN 045,"Total Vendedor: ",
    	      COLUMN 065, lr_total_vendedor.qtd_item USING "-------&.&&",
              COLUMN 083, lr_total_vendedor.val_tot_item USING "-------&.&&",
              #COLUMN 077, lr_total_vendedor.val_fixa USING "-------&.&&",
              #COLUMN 092, lr_total_vendedor.val_var USING "-------&.&&",
              COLUMN 102, lr_total_vendedor.val_comissao USING "-------&.&&",
              COLUMN 116, lr_total_vendedor.qtd_item2 USING "-------&.&&",
              COLUMN 134, lr_total_vendedor.val_tot_item2 USING "-------&.&&",
              #COLUMN 149, lr_total_vendedor.val_var2 USING "-------&.&&",
              COLUMN 153, lr_total_vendedor.val_comissao2 USING "-------&.&&",
              COLUMN 167, lr_total_vendedor.qtd_item3 USING "-------&.&&",
              COLUMN 185, lr_total_vendedor.val_tot_item3 USING "-------&.&&",
              COLUMN 204, lr_total_vendedor.val_comissao3 USING "-------&.&&"
    	
    	LET lr_total_vendedor.qtd_item 	 = 0
        LET lr_total_vendedor.val_tot_item  = 0
        LET lr_total_vendedor.val_fixa 	 = 0
        LET lr_total_vendedor.val_var 		 = 0
        LET lr_total_vendedor.val_comissao  = 0
    	LET lr_total_vendedor.qtd_item2 	 = 0
        LET lr_total_vendedor.val_tot_item2 = 0
        LET lr_total_vendedor.val_var2 	 = 0
        LET lr_total_vendedor.val_comissao2 = 0
        LET lr_total_vendedor.qtd_item3 	 = 0
        LET lr_total_vendedor.val_tot_item3 = 0
        LET lr_total_vendedor.val_comissao3 = 0
    
       SKIP 01 LINE
    
    AFTER GROUP OF lr_relat.linha
    	PRINT COLUMN 045,lr_relat.linha CLIPPED,
    	      COLUMN 065, lr_total_linha.qtd_item USING "-------&.&&",
              COLUMN 083, lr_total_linha.val_tot_item USING "-------&.&&",
              #COLUMN 077, lr_total_linha.val_fixa USING "-------&.&&",
              #COLUMN 092, lr_total_linha.val_var USING "-------&.&&",
              COLUMN 102, lr_total_linha.val_comissao USING "-------&.&&",
              COLUMN 116, lr_total_linha.qtd_item2 USING "-------&.&&",
              COLUMN 134, lr_total_linha.val_tot_item2 USING "-------&.&&",
              #COLUMN 149, lr_total_linha.val_var2 USING "-------&.&&",
              COLUMN 153, lr_total_linha.val_comissao2 USING "-------&.&&",
              COLUMN 167, lr_total_linha.qtd_item3 USING "-------&.&&",
              COLUMN 185, lr_total_linha.val_tot_item3 USING "-------&.&&",
              COLUMN 204, lr_total_linha.val_comissao3 USING "-------&.&&"
    	CALL ReportThinLine("geo1030")
    	LET lr_total_linha.qtd_item 	 = 0
        LET lr_total_linha.val_tot_item  = 0
        LET lr_total_linha.val_fixa 	 = 0
        LET lr_total_linha.val_var 		 = 0
        LET lr_total_linha.val_comissao  = 0
    	LET lr_total_linha.qtd_item2 	 = 0
        LET lr_total_linha.val_tot_item2 = 0
        LET lr_total_linha.val_var2 	 = 0
        LET lr_total_linha.val_comissao2 = 0
        LET lr_total_linha.qtd_item3 	 = 0
        LET lr_total_linha.val_tot_item3 = 0
        LET lr_total_linha.val_comissao3 = 0
    
    ON LAST ROW
       LET l_last_row = TRUE
       CALL ReportThinLine("geo1030")
       CALL ReportThinLine("geo1030")
       PRINT COLUMN 045,"Total Geral: ",
    	      COLUMN 065, lr_total_geral.qtd_item USING "-------&.&&",
              COLUMN 083, lr_total_geral.val_tot_item USING "-------&.&&",
              #COLUMN 077, lr_total_geral.val_fixa USING "-------&.&&",
              #COLUMN 092, lr_total_geral.val_var USING "-------&.&&",
              COLUMN 102, lr_total_geral.val_comissao USING "-------&.&&",
              COLUMN 116, lr_total_geral.qtd_item2 USING "-------&.&&",
              COLUMN 134, lr_total_geral.val_tot_item2 USING "-------&.&&",
              #COLUMN 149, lr_total_geral.val_var2 USING "-------&.&&",
              COLUMN 153, lr_total_geral.val_comissao2 USING "-------&.&&",
              COLUMN 167, lr_total_geral.qtd_item3 USING "-------&.&&",
              COLUMN 185, lr_total_geral.val_tot_item3 USING "-------&.&&",
              COLUMN 204, lr_total_geral.val_comissao3 USING "-------&.&&"
    	
    	LET lr_total_geral.qtd_item 	 = 0
        LET lr_total_geral.val_tot_item  = 0
        LET lr_total_geral.val_fixa 	 = 0
        LET lr_total_geral.val_var 		 = 0
        LET lr_total_geral.val_comissao  = 0
    	LET lr_total_geral.qtd_item2 	 = 0
        LET lr_total_geral.val_tot_item2 = 0
        LET lr_total_geral.val_var2 	 = 0
        LET lr_total_geral.val_comissao2 = 0
        LET lr_total_geral.qtd_item3 	 = 0
        LET lr_total_geral.val_tot_item3 = 0
        LET lr_total_geral.val_comissao3 = 0
       
    PAGE TRAILER
             
       IF l_last_row = TRUE THEN
         #PRINT "* * *  ULTIMA FOLHA  * * *", log5211_termino_impressao() CLIPPED
         PRINT " "
       ELSE
         PRINT " "
       END IF

END REPORT


#------------------------------#
 REPORT geo1030_report_analitico(lr_relat)
#------------------------------#
  DEFINE lr_relat          RECORD
            nota_fiscal     INTEGER,
            serie           CHAR(3),
            cod_vendedor  	DECIMAL(4,0),
            nom_vendedor  	CHAR(36),
            linha		  	CHAR(36),
            cod_item 		CHAR(15),
            den_item 		CHAR(76),
            qtd_item 		DECIMAL(15,2),
            val_tot_item 	DECIMAL(15,2),
            val_fixa 		DECIMAL(15,2),
            val_var 		DECIMAL(15,2),
            val_comissao 	DECIMAL(15,2),
            qtd_item2 		DECIMAL(15,2),
            val_tot_item2 	DECIMAL(15,2),
            val_var2 		DECIMAL(15,2),
            val_comissao2 	DECIMAL(15,2),
            qtd_item3 		DECIMAL(15,2),
            val_tot_item3 	DECIMAL(15,2),
            val_comissao3 	DECIMAL(15,2)
         END RECORD
         
  DEFINE l_last_row          SMALLINT
  DEFINE l_den_empresa       LIKE empresa.den_empresa
  DEFINE l_condicao_ant      CHAR(50)
  DEFINE l_primeiro          SMALLINT
  DEFINE l_quantidade        DECIMAL(20,2)
  DEFINE l_total             DECIMAL(20,2)
  DEFINE l_geral             DECIMAL(20,2)
  DEFINE l_cod_repres        DECIMAL(4,0)
  DEFINE l_den_item          CHAR(40)
  DEFINE l_nf_ant            INTEGER
  
  OUTPUT
    RIGHT  MARGIN 0
    LEFT   MARGIN 0
    TOP    MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH m_page_length
    #ORDER EXTERNAL BY lr_relat.cod_resp
  
  FORMAT
    
    PAGE HEADER
       SELECT den_empresa
         INTO l_den_empresa
         FROM empresa
        WHERE cod_empresa = mr_tela.cod_empresa
       
       CALL ReportPageHeader("geo1030")
      
       PRINT COLUMN 001,p_cod_empresa," - ",l_den_empresa CLIPPED,
             COLUMN 095, "Período De: ",mr_tela.data_de," Até ",mr_tela.data_ate
       LET l_last_row = FALSE
         
       CALL ReportThinLine("geo1030")
       #SKIP 01 LINE
     
       PRINT COLUMN 002,lr_relat.nom_vendedor CLIPPED,
             COLUMN 072,"------------- PRONTA ENTREGA ------------ ",
             COLUMN 123,"--------------- PRE VENDA ---------------",
             COLUMN 174,"----------------- TOTAL -----------------"
            
       PRINT COLUMN 002,lr_relat.cod_vendedor,
             COLUMN 072,"QTDE",
             COLUMN 089,"VALOR",
             #COLUMN 086,"FIXA",
             #COLUMN 098,"VAR (N)",
             COLUMN 106,"TOT.COM",
             COLUMN 123,"QTDE",
             COLUMN 140,"VALOR",
             #COLUMN 154,"VAR (N)",
             COLUMN 157,"TOT.COM",
             COLUMN 174,"QTDE",
             COLUMN 191,"VALOR",
             COLUMN 208,"TOT.COM"
            CALL ReportThinLine("geo1030")
       
     
    BEFORE GROUP OF lr_relat.cod_vendedor
       SKIP TO TOP OF PAGE
       
    ON EVERY ROW
        LET lr_total_linha.qtd_item 	 = lr_total_linha.qtd_item 		+ lr_relat.qtd_item
        LET lr_total_linha.val_tot_item  = lr_total_linha.val_tot_item 	+ lr_relat.val_tot_item
        LET lr_total_linha.val_fixa 	 = lr_total_linha.val_fixa 		+ lr_relat.val_fixa
        LET lr_total_linha.val_var 		 = lr_total_linha.val_var 		+ lr_relat.val_var
        LET lr_total_linha.val_comissao  = lr_total_linha.val_comissao 	+ lr_relat.val_comissao
    	LET lr_total_linha.qtd_item2 	 = lr_total_linha.qtd_item2 	+ lr_relat.qtd_item2
        LET lr_total_linha.val_tot_item2 = lr_total_linha.val_tot_item2 + lr_relat.val_tot_item2
        LET lr_total_linha.val_var2 	 = lr_total_linha.val_var2 		+ lr_relat.val_var2
        LET lr_total_linha.val_comissao2 = lr_total_linha.val_comissao2 + lr_relat.val_comissao2
        LET lr_total_linha.qtd_item3 	 = lr_total_linha.qtd_item3 	+ lr_relat.qtd_item3
        LET lr_total_linha.val_tot_item3 = lr_total_linha.val_tot_item3 + lr_relat.val_tot_item3
        LET lr_total_linha.val_comissao3 = lr_total_linha.val_comissao3 + lr_relat.val_comissao3
    
    	LET lr_total_vendedor.qtd_item 	 = lr_total_vendedor.qtd_item 		+ lr_relat.qtd_item
        LET lr_total_vendedor.val_tot_item  = lr_total_vendedor.val_tot_item 	+ lr_relat.val_tot_item
        LET lr_total_vendedor.val_fixa 	 = lr_total_vendedor.val_fixa 		+ lr_relat.val_fixa
        LET lr_total_vendedor.val_var 		 = lr_total_vendedor.val_var 		+ lr_relat.val_var
        LET lr_total_vendedor.val_comissao  = lr_total_vendedor.val_comissao 	+ lr_relat.val_comissao
    	LET lr_total_vendedor.qtd_item2 	 = lr_total_vendedor.qtd_item2 	+ lr_relat.qtd_item2
        LET lr_total_vendedor.val_tot_item2 = lr_total_vendedor.val_tot_item2 + lr_relat.val_tot_item2
        LET lr_total_vendedor.val_var2 	 = lr_total_vendedor.val_var2 		+ lr_relat.val_var2
        LET lr_total_vendedor.val_comissao2 = lr_total_vendedor.val_comissao2 + lr_relat.val_comissao2
        LET lr_total_vendedor.qtd_item3 	 = lr_total_vendedor.qtd_item3 	+ lr_relat.qtd_item3
        LET lr_total_vendedor.val_tot_item3 = lr_total_vendedor.val_tot_item3 + lr_relat.val_tot_item3
        LET lr_total_vendedor.val_comissao3 = lr_total_vendedor.val_comissao3 + lr_relat.val_comissao3
    
    	LET lr_total_geral.qtd_item 	 = lr_total_geral.qtd_item 		+ lr_relat.qtd_item
        LET lr_total_geral.val_tot_item  = lr_total_geral.val_tot_item 	+ lr_relat.val_tot_item
        LET lr_total_geral.val_fixa 	 = lr_total_geral.val_fixa 		+ lr_relat.val_fixa
        LET lr_total_geral.val_var 		 = lr_total_geral.val_var 		+ lr_relat.val_var
        LET lr_total_geral.val_comissao  = lr_total_geral.val_comissao 	+ lr_relat.val_comissao
    	LET lr_total_geral.qtd_item2 	 = lr_total_geral.qtd_item2 	+ lr_relat.qtd_item2
        LET lr_total_geral.val_tot_item2 = lr_total_geral.val_tot_item2 + lr_relat.val_tot_item2
        LET lr_total_geral.val_var2 	 = lr_total_geral.val_var2 		+ lr_relat.val_var2
        LET lr_total_geral.val_comissao2 = lr_total_geral.val_comissao2 + lr_relat.val_comissao2
        LET lr_total_geral.qtd_item3 	 = lr_total_geral.qtd_item3 	+ lr_relat.qtd_item3
        LET lr_total_geral.val_tot_item3 = lr_total_geral.val_tot_item3 + lr_relat.val_tot_item3
        LET lr_total_geral.val_comissao3 = lr_total_geral.val_comissao3 + lr_relat.val_comissao3
    
       IF LENGTH(lr_relat.den_item) > 42 THEN
          LET l_den_item = lr_relat.den_item[1,42],"..."
       ELSE
          LET l_den_item = lr_relat.den_item
       END IF 
       
       IF l_nf_ant <> lr_relat.nota_fiscal THEN
          LET l_nf_ant = lr_relat.nota_fiscal
       
	       PRINT COLUMN 002, lr_relat.serie CLIPPED," ",lr_relat.nota_fiscal USING "&&&&&&"," ",
	             COLUMN 012, l_den_item CLIPPED,
	             COLUMN 065, lr_relat.qtd_item USING "-------&.&&",
	             COLUMN 083, lr_relat.val_tot_item USING "-------&.&&",
	             #COLUMN 077, lr_relat.val_fixa USING "-------&.&&",
	             #COLUMN 092, lr_relat.val_var USING "-------&.&&",
	             COLUMN 102, lr_relat.val_comissao USING "-------&.&&",
	             COLUMN 116, lr_relat.qtd_item2 USING "-------&.&&",
	             COLUMN 134, lr_relat.val_tot_item2 USING "-------&.&&",
	             #COLUMN 149, lr_relat.val_var2 USING "-------&.&&",
	             COLUMN 153, lr_relat.val_comissao2 USING "-------&.&&",
	             COLUMN 167, lr_relat.qtd_item3 USING "-------&.&&",
	             COLUMN 185, lr_relat.val_tot_item3 USING "-------&.&&",
	             COLUMN 204, lr_relat.val_comissao3 USING "-------&.&&"
	    ELSE
	    	PRINT COLUMN 002, " ",
	             COLUMN 012, l_den_item CLIPPED,
	             COLUMN 065, lr_relat.qtd_item USING "-------&.&&",
	             COLUMN 083, lr_relat.val_tot_item USING "-------&.&&",
	             #COLUMN 077, lr_relat.val_fixa USING "-------&.&&",
	             #COLUMN 092, lr_relat.val_var USING "-------&.&&",
	             COLUMN 102, lr_relat.val_comissao USING "-------&.&&",
	             COLUMN 116, lr_relat.qtd_item2 USING "-------&.&&",
	             COLUMN 134, lr_relat.val_tot_item2 USING "-------&.&&",
	             #COLUMN 149, lr_relat.val_var2 USING "-------&.&&",
	             COLUMN 153, lr_relat.val_comissao2 USING "-------&.&&",
	             COLUMN 167, lr_relat.qtd_item3 USING "-------&.&&",
	             COLUMN 185, lr_relat.val_tot_item3 USING "-------&.&&",
	             COLUMN 204, lr_relat.val_comissao3 USING "-------&.&&"
	    END IF 
        
    AFTER GROUP OF lr_relat.cod_vendedor
       PRINT COLUMN 045,"Total Vendedor: ",
    	      COLUMN 065, lr_total_vendedor.qtd_item USING "-------&.&&",
              COLUMN 086, lr_total_vendedor.val_tot_item USING "-------&.&&",
              #COLUMN 077, lr_total_vendedor.val_fixa USING "-------&.&&",
              #COLUMN 092, lr_total_vendedor.val_var USING "-------&.&&",
              COLUMN 102, lr_total_vendedor.val_comissao USING "-------&.&&",
              COLUMN 116, lr_total_vendedor.qtd_item2 USING "-------&.&&",
              COLUMN 134, lr_total_vendedor.val_tot_item2 USING "-------&.&&",
              #COLUMN 149, lr_total_vendedor.val_var2 USING "-------&.&&",
              COLUMN 153, lr_total_vendedor.val_comissao2 USING "-------&.&&",
              COLUMN 167, lr_total_vendedor.qtd_item3 USING "-------&.&&",
              COLUMN 185, lr_total_vendedor.val_tot_item3 USING "-------&.&&",
              COLUMN 204, lr_total_vendedor.val_comissao3 USING "-------&.&&"
    	
    	LET lr_total_vendedor.qtd_item 	 = 0
        LET lr_total_vendedor.val_tot_item  = 0
        LET lr_total_vendedor.val_fixa 	 = 0
        LET lr_total_vendedor.val_var 		 = 0
        LET lr_total_vendedor.val_comissao  = 0
    	LET lr_total_vendedor.qtd_item2 	 = 0
        LET lr_total_vendedor.val_tot_item2 = 0
        LET lr_total_vendedor.val_var2 	 = 0
        LET lr_total_vendedor.val_comissao2 = 0
        LET lr_total_vendedor.qtd_item3 	 = 0
        LET lr_total_vendedor.val_tot_item3 = 0
        LET lr_total_vendedor.val_comissao3 = 0
    
       SKIP 01 LINE
    
    AFTER GROUP OF lr_relat.linha
    	PRINT COLUMN 045,lr_relat.linha CLIPPED,
    	      COLUMN 065, lr_total_linha.qtd_item USING "-------&.&&",
              COLUMN 083, lr_total_linha.val_tot_item USING "-------&.&&",
              #COLUMN 077, lr_total_linha.val_fixa USING "-------&.&&",
              #COLUMN 092, lr_total_linha.val_var USING "-------&.&&",
              COLUMN 102, lr_total_linha.val_comissao USING "-------&.&&",
              COLUMN 116, lr_total_linha.qtd_item2 USING "-------&.&&",
              COLUMN 134, lr_total_linha.val_tot_item2 USING "-------&.&&",
              #COLUMN 149, lr_total_linha.val_var2 USING "-------&.&&",
              COLUMN 153, lr_total_linha.val_comissao2 USING "-------&.&&",
              COLUMN 167, lr_total_linha.qtd_item3 USING "-------&.&&",
              COLUMN 185, lr_total_linha.val_tot_item3 USING "-------&.&&",
              COLUMN 204, lr_total_linha.val_comissao3 USING "-------&.&&"
    	CALL ReportThinLine("geo1030")
    	LET lr_total_linha.qtd_item 	 = 0
        LET lr_total_linha.val_tot_item  = 0
        LET lr_total_linha.val_fixa 	 = 0
        LET lr_total_linha.val_var 		 = 0
        LET lr_total_linha.val_comissao  = 0
    	LET lr_total_linha.qtd_item2 	 = 0
        LET lr_total_linha.val_tot_item2 = 0
        LET lr_total_linha.val_var2 	 = 0
        LET lr_total_linha.val_comissao2 = 0
        LET lr_total_linha.qtd_item3 	 = 0
        LET lr_total_linha.val_tot_item3 = 0
        LET lr_total_linha.val_comissao3 = 0
    
    ON LAST ROW
       LET l_last_row = TRUE
       CALL ReportThinLine("geo1030")
       CALL ReportThinLine("geo1030")
       PRINT COLUMN 045,"Total Geral: ",
    	      COLUMN 065, lr_total_geral.qtd_item USING "-------&.&&",
              COLUMN 083, lr_total_geral.val_tot_item USING "-------&.&&",
              #COLUMN 077, lr_total_geral.val_fixa USING "-------&.&&",
              #COLUMN 092, lr_total_geral.val_var USING "-------&.&&",
              COLUMN 102, lr_total_geral.val_comissao USING "-------&.&&",
              COLUMN 116, lr_total_geral.qtd_item2 USING "-------&.&&",
              COLUMN 134, lr_total_geral.val_tot_item2 USING "-------&.&&",
              #COLUMN 149, lr_total_geral.val_var2 USING "-------&.&&",
              COLUMN 153, lr_total_geral.val_comissao2 USING "-------&.&&",
              COLUMN 167, lr_total_geral.qtd_item3 USING "-------&.&&",
              COLUMN 185, lr_total_geral.val_tot_item3 USING "-------&.&&",
              COLUMN 204, lr_total_geral.val_comissao3 USING "-------&.&&"
    	
    	LET lr_total_geral.qtd_item 	 = 0
        LET lr_total_geral.val_tot_item  = 0
        LET lr_total_geral.val_fixa 	 = 0
        LET lr_total_geral.val_var 		 = 0
        LET lr_total_geral.val_comissao  = 0
    	LET lr_total_geral.qtd_item2 	 = 0
        LET lr_total_geral.val_tot_item2 = 0
        LET lr_total_geral.val_var2 	 = 0
        LET lr_total_geral.val_comissao2 = 0
        LET lr_total_geral.qtd_item3 	 = 0
        LET lr_total_geral.val_tot_item3 = 0
        LET lr_total_geral.val_comissao3 = 0
       
    PAGE TRAILER
             
       IF l_last_row = TRUE THEN
         #PRINT "* * *  ULTIMA FOLHA  * * *", log5211_termino_impressao() CLIPPED
         PRINT " "
       ELSE
         PRINT " "
       END IF

END REPORT

######### VIEW UTILIZADA PELO PROGRAMA PARA GERACAO DOS RELATORIOS ############


{
	
create view dbo.lhp_comissao WITH SCHEMABINDING as 

select distinct	a.empresa, 'SMART' tipo,
		c.representante vendedor,
		rp.nom_guerra nom_vend,
		c.seq_representante seq_vend,
		a.nota_fiscal nf,
		a.serie_nota_fiscal serie,
		cast(a.dat_hor_emissao as date) emissao,
		a.cliente,
		cl.nom_cliente,
		case when it.cod_lin_prod = '1' then 'CAFE'
			 when it.cod_lin_prod = '2' then 'REVENDA'
			 when it.cod_lin_prod = '4' then 'MAQUINAS'
			 else 'OUTROS' end as linha,
		b.item,
		b.des_item,
		b.qtd_item,
		b.preco_unit_liquido pre_liq,
		b.val_liquido_item,

		case when co2.cod_cliente is null then co.pct_comissao
		else co2.pct_comissao end as pct_comissao,
		cast(b.val_liquido_item*(case when co2.cod_cliente is null then co.pct_comissao
		else co2.pct_comissao end/100) as decimal(15,2))  val_comis
		
from dbo.fat_nf_mestre a -- vdp40005

inner join dbo.fat_nf_item b
		on a.empresa		= b.empresa
		and a.trans_nota_fiscal = b.trans_nota_fiscal
		
inner join dbo.item it	-- man10021
		on b.empresa		= it.cod_empresa
		and b.item				= it.cod_item
		
inner join dbo.fat_nf_repr c
		on c.empresa			= a.empresa
		and c.trans_nota_fiscal = a.trans_nota_fiscal
		and c.seq_representante	= '1'
		
inner join dbo.representante rp -- vdp10027
		on rp.cod_repres 		= c.representante
-- 		and cod_repres			= '203'
		
left outer join dbo.comissao_par co -- vdp10015
		on co.cod_repres 		= c.representante
		and co.cod_cliente		is null
		and co.cod_tip_cli		is null
		and co.cod_cnd_pgto		is null
		and co.cod_item			is null
		and co.cod_lin_prod		= it.cod_lin_prod
		
left outer join dbo.comissao_par co2 -- vdp10015
		on co2.cod_repres 		= c.representante
		and co2.cod_cliente		= a.cliente
		and co2.cod_tip_cli		is null
		and co2.cod_cnd_pgto	is null
		and co2.cod_item		is null
		and co2.cod_lin_prod	= it.cod_lin_prod

		
inner join dbo.nat_operacao n
		on a.natureza_operacao	= n.cod_nat_oper
		and n.ies_estatistica	<> 'N'
		
inner join dbo.clientes cl
		on a.cliente			= cl.cod_cliente
	
where a.sit_nota_fiscal 		= 'N'
and a.cond_pagto 				<> '999'
and a.serie_nota_fiscal			<> 'LC'
-- and a.dat_hor_emissao 			>= '25/06/2016'
-- and a.dat_hor_emissao 			<= '22/07/2016'
and a.natureza_operacao in ('11')

UNION ALL
-- ####################################################
select distinct	a.empresa, 'BALCAO' tipo,
		c.representante vendedor,
		rp.nom_guerra nom_vend,
		c.seq_representante seq_vend,
		a.nota_fiscal nf,
		a.serie_nota_fiscal serie,
		cast(a.dat_hor_emissao as date) emissao,
		a.cliente,
		cl.nom_cliente,
		case when it.cod_lin_prod = '1' then 'CAFE'
			 when it.cod_lin_prod = '2' then 'REVENDA'
			 when it.cod_lin_prod = '4' then 'MAQUINAS'
			 else 'OUTROS' end as linha,
		b.item,
		b.des_item,
		b.qtd_item,
		b.preco_unit_liquido pre_liq,
		b.val_liquido_item,

		case when co2.cod_cliente is null then co.pct_comissao
		else co2.pct_comissao end as pct_comissao,
		cast(b.val_liquido_item*(case when co2.cod_cliente is null then co.pct_comissao
		else co2.pct_comissao end/100) as decimal(15,2))  val_comis
		
from dbo.fat_nf_mestre a -- vdp40005

inner join dbo.fat_nf_item b
		on a.empresa		= b.empresa
		and a.trans_nota_fiscal = b.trans_nota_fiscal
		
inner join dbo.item it	-- man10021
		on b.empresa		= it.cod_empresa
		and b.item				= it.cod_item
		
inner join dbo.fat_nf_repr c
		on c.empresa			= a.empresa
		and c.trans_nota_fiscal = a.trans_nota_fiscal
		and c.seq_representante	IN ('1','2')
		
inner join dbo.representante rp -- vdp10027
		on rp.cod_repres 		= c.representante
-- 		and cod_repres			= '203'
		
left outer join dbo.comissao_par co -- vdp10015
		on co.cod_repres 		= c.representante
		and co.cod_cliente		is null
		and co.cod_tip_cli		is null
		and co.cod_cnd_pgto		is null
		and co.cod_item			is null
		and co.cod_lin_prod		= it.cod_lin_prod
		
left outer join dbo.comissao_par co2 -- vdp10015
		on co2.cod_repres 		= c.representante
		and co2.cod_cliente		= a.cliente
		and co2.cod_tip_cli		is null
		and co2.cod_cnd_pgto	is null
		and co2.cod_item		is null
		and co2.cod_lin_prod	= it.cod_lin_prod

inner join dbo.nat_operacao n
		on a.natureza_operacao	= n.cod_nat_oper
		and n.ies_estatistica	<> 'N'
		
inner join dbo.clientes cl
		on a.cliente			= cl.cod_cliente
	
where a.sit_nota_fiscal 		= 'N'
and a.cond_pagto 				<> '999'
and a.serie_nota_fiscal			<> 'LC'
-- and a.dat_hor_emissao 			>= '25/06/2016'
-- and a.dat_hor_emissao 			<= '22/07/2016'
and a.natureza_operacao in ('1','13');	
}