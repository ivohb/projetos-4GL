#-----------------------------------------------------------------#
# MODULO..: GEO                                                   #
# SISTEMA.: RELATORIOS                                            #
# PROGRAMA: geo1023                                               #
# AUTOR...: EVANDRO SIMENES                                       #
# DATA....: 30/03/2016                                            #
#-----------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_versao            CHAR(18)
   DEFINE p_cod_empresa       LIKE empresa.cod_empresa
   DEFINE p_user              LIKE usuarios.cod_usuario
   
END GLOBALS
   
   DEFINE m_ind                     INTEGER
   define m_form_funil              varchar(10)
   define m_refer_funil varchar(10)
     
   define m_refer_tabela_funil varchar(50)
    
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
   DEFINE m_zoom_item               VARCHAR(10)
   DEFINE m_refer_campos            VARCHAR(10)
   DEFINE m_ind_carga               INTEGER
   DEFINE m_consulta_ativa          INTEGER
   DEFINE m_page_length             INTEGER
   DEFINE m_cod_repres              DECIMAL(4,0)
   DEFINE m_zoom_resp               VARCHAR(10)
   DEFINE m_tipo_relat_cargas       CHAR(1)
   
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
             tipo_relat    CHAR(1),
             cod_manifesto INTEGER,
             data_de       DATE,
             data_ate      DATE,
             cod_resp      CHAR(15),
             den_resp      CHAR(76)
         END RECORD
   
   define ma_funil array[9999] of record
        codigo  integer
                               end record
                               
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
 FUNCTION geo1023()
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
      CALL geo1023_tela()
   END IF

END FUNCTION

#-------------------------------------#
FUNCTION geo1023_args(l_tipo_relat, l_cod_manifesto)
#-------------------------------------#
   DEFINE l_cod_manifesto       INTEGER
   DEFINE l_tipo_relat          CHAR(1)
   
   LET mr_tela.cod_manifesto = l_cod_manifesto
   LET mr_tela.tipo_relat    = l_tipo_relat
   
   CALL geo1023_valid_cod_manifesto()
   
   LET m_consulta_ativa = TRUE
   CALL geo1023_tela()
   
END FUNCTION 

#-------------------#
 FUNCTION geo1023_tela()
#-------------------#

   DEFINE l_label        VARCHAR(50)
        , l_splitter     VARCHAR(50)
        , l_status       SMALLINT
        , l_panel_center VARCHAR(10)
        , l_tst CHAR(99)
     
     
   #cria janela principal do tipo LDIALOG
   LET m_form_principal = _ADVPL_create_component(NULL,"LDIALOG")
   CALL _ADVPL_set_property(m_form_principal,"TITLE","RELATORIOS")
   CALL _ADVPL_set_property(m_form_principal,"ENABLE_ESC_CLOSE",FALSE)
   CALL _ADVPL_set_property(m_form_principal,"SIZE",500,300)#   1024,725)

   LET m_toolbar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_principal)

   LET m_botao_informar = _ADVPL_create_component(NULL,"LINFORMBUTTON",m_toolbar)
   CALL _ADVPL_set_property(m_botao_informar,"EVENT","geo1023_informar")
   CALL _ADVPL_set_property(m_botao_informar,"CONFIRM_EVENT","geo1023_confirma_informar")
   CALL _ADVPL_set_property(m_botao_informar,"CANCEL_EVENT","geo1023_cancela_informar")

   LET m_botao_processar = _ADVPL_create_component(NULL,"LPROCESSBUTTON",m_toolbar)
   CALL _ADVPL_set_property(m_botao_processar,"EVENT","geo1023_processar")
     
   LET m_botao_quit = _ADVPL_create_component(NULL,"LQUITBUTTON",m_toolbar)
   LET m_status_bar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_principal)

   LET m_panel_1 = _ADVPL_create_component(NULL,"LPANEL",m_form_principal)
   CALL _ADVPL_set_property(m_panel_1,"ALIGN","TOP")
   CALL _ADVPL_set_property(m_panel_1,"HEIGHT",190)
      
   #cria panel  
   LET m_panel_reference1 = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel_1)
   CALL _ADVPL_set_property(m_panel_reference1,"TITLE","RELATORIOS")
   CALL _ADVPL_set_property(m_panel_reference1,"ALIGN","CENTER")
   #CALL _ADVPL_set_property(m_panel_reference2,"HEIGHT",900)
     
   LET m_layoutmanager_refence_1 = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_reference1)
   CALL _ADVPL_set_property(m_layoutmanager_refence_1,"MARGIN",TRUE)
   CALL _ADVPL_set_property(m_layoutmanager_refence_1,"COLUMNS_COUNT",2)
   
   
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
   CALL _ADVPL_set_property(l_label,"TEXT","Tipo de Relatório:")
   CALL _ADVPL_set_property(l_label,"SIZE",100,15)
   CALL _ADVPL_set_property(l_label,"POSITION",10,30)
   CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
   
   LET m_refer_tipo_relat = _ADVPL_create_component(NULL,"LCOMBOBOX",m_panel_reference1)
   CALL _ADVPL_set_property(m_refer_tipo_relat,"VARIABLE",mr_tela,"tipo_relat")
   CALL _ADVPL_set_property(m_refer_tipo_relat,"VALID","geo1023_valid_tipo_relat")
   CALL _ADVPL_set_property(m_refer_tipo_relat,"ADD_ITEM","A","Financeiro")
   CALL _ADVPL_set_property(m_refer_tipo_relat,"ADD_ITEM","B","Resumo de Vendas")
   CALL _ADVPL_set_property(m_refer_tipo_relat,"ADD_ITEM","C","Cargas Não Encerradas")
   CALL _ADVPL_set_property(m_refer_tipo_relat,"ADD_ITEM","D","Cargas Encerradas")
   CALL _ADVPL_set_property(m_refer_tipo_relat,"ADD_ITEM","E","Resumo dos Acertos Encerrados")
   CALL _ADVPL_set_property(m_refer_tipo_relat,"ADD_ITEM","F","Acertos Encerrados por data")
   CALL _ADVPL_set_property(m_refer_tipo_relat,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_tipo_relat,"POSITION",120,29)
   
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
   CALL _ADVPL_set_property(l_label,"TEXT","Manifesto:")
   CALL _ADVPL_set_property(l_label,"SIZE",100,15)
   CALL _ADVPL_set_property(l_label,"POSITION",10,60)
   CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
   LET m_refer_cod_manifesto = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel_reference1)
   CALL _ADVPL_set_property(m_refer_cod_manifesto,"VARIABLE",mr_tela,"cod_manifesto")
   CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_cod_manifesto,"LENGTH",15)
   CALL _ADVPL_set_property(m_refer_cod_manifesto,"VALID","geo1023_valid_cod_manifesto")
   CALL _ADVPL_set_property(m_refer_cod_manifesto,"POSITION",120,59)
     
   LET m_zoom_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_reference1)
   CALL _ADVPL_set_property(m_zoom_item,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_zoom_item,"POSITION",251,59)
   CALL _ADVPL_set_property(m_zoom_item,"IMAGE", "BTPESQ")
   CALL _ADVPL_set_property(m_zoom_item,"CLICK_EVENT","geo1023_zoom_manifesto")
   CALL _ADVPL_set_property(m_zoom_item,"SIZE",24,20)
   CALL _ADVPL_set_property(m_zoom_item,"TOOLTIP","Zoom Manifesto")
   
   #zoom
	LET m_refer_funil = _ADVPL_create_component(NULL, "LIMAGEBUTTON", m_panel_reference1)
	CALL _ADVPL_set_property(m_refer_funil,"IMAGE","pesquisar_button")
	CALL _ADVPL_set_property(m_refer_funil,"SIZE",24,20)
	CALL _ADVPL_set_property(m_refer_funil,"TOOLTIP","Zoom Funil")
	CALL _ADVPL_set_property(m_refer_funil,"CLICK_EVENT","geo1023_tela_funil_tela")
	CALL _ADVPL_set_property(m_refer_funil,"ENABLE",FALSE)
	CALL _ADVPL_set_property(m_refer_funil,"POSITION",300,59)


   
   

   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
   CALL _ADVPL_set_property(l_label,"TEXT","Período De:")
   CALL _ADVPL_set_property(l_label,"SIZE",100,15)
   CALL _ADVPL_set_property(l_label,"POSITION",10,90)
   CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
   LET m_refer_data_de = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel_reference1)
   CALL _ADVPL_set_property(m_refer_data_de,"VARIABLE",mr_tela,"data_de")
   CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_data_de,"POSITION",120,89)
    
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
   CALL _ADVPL_set_property(l_label,"TEXT","Até:")
   CALL _ADVPL_set_property(l_label,"SIZE",100,15)
   CALL _ADVPL_set_property(l_label,"POSITION",300,90)
   CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
   LET m_refer_data_ate = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel_reference1)
   CALL _ADVPL_set_property(m_refer_data_ate,"VARIABLE",mr_tela,"data_ate")
   CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_data_ate,"POSITION",349,89)
    
   LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel_reference1)
   CALL _ADVPL_set_property(l_label,"TEXT","Responsável:")
   CALL _ADVPL_set_property(l_label,"SIZE",100,15)
   CALL _ADVPL_set_property(l_label,"POSITION",10,120)
   CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",52,100,171)
   CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,NULL)
	
   LET m_refer_cod_resp = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
   CALL _ADVPL_set_property(m_refer_cod_resp,"VARIABLE",mr_tela,"cod_resp")
   CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_cod_resp,"LENGTH",10)
   CALL _ADVPL_set_property(m_refer_cod_resp,"POSITION",120,119)
   
   LET m_zoom_resp = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel_reference1)
   CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_zoom_resp,"POSITION",211,119)
   CALL _ADVPL_set_property(m_zoom_resp,"IMAGE", "BTPESQ")
   CALL _ADVPL_set_property(m_zoom_resp,"CLICK_EVENT","geo1023_zoom_resp")
   CALL _ADVPL_set_property(m_zoom_resp,"SIZE",24,20)
   CALL _ADVPL_set_property(m_zoom_resp,"TOOLTIP","Zoom Responsável")
   
   LET m_refer_campos = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel_reference1)
   CALL _ADVPL_set_property(m_refer_campos,"VARIABLE",mr_tela,"den_resp")
   CALL _ADVPL_set_property(m_refer_campos,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_campos,"LENGTH",25)
   CALL _ADVPL_set_property(m_refer_campos,"POSITION",241,119)
  
   CALL _ADVPL_set_property(m_form_principal,"ACTIVATE",TRUE)

 END FUNCTION

#--------------------------#
FUNCTION geo1023_informar()
#--------------------------#
   
   INITIALIZE mr_tela.* to null
   LET mr_tela.tipo_relat = "A"
   CALL geo1023_valid_tipo_relat()
   CALL geo1023_habilita_campos_manutencao(TRUE,'INCLUIR')

END FUNCTION

#------------------------------------#
function geo1023_confirma_informar()
#------------------------------------#

   IF NOT geo1023_valid_cod_manifesto() THEN
      RETURN FALSE
   END IF 
   CALL geo1023_habilita_campos_manutencao(FALSE,'INCLUIR')
   LET m_consulta_ativa = TRUE
   
   CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_zoom_item,"ENABLE",FALSE)
   RETURN TRUE
end function

#-----------------------------------#
function geo1023_cancela_informar()
#-----------------------------------#
   call geo1023_habilita_campos_manutencao(FALSE,'INCLUIR')
   LET m_consulta_ativa = FALSE
   
   CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_zoom_item,"ENABLE",FALSE)
   RETURN TRUE
end function

#-------------------------------------------------------------#
function geo1023_habilita_campos_manutencao(l_status,l_funcao)
#-------------------------------------------------------------#
   DEFINE l_status smallint
   define l_funcao char(20)
   
   CALL _ADVPL_set_property(m_refer_tipo_relat,"ENABLE",l_status)
   
   {
   CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_zoom_item,"ENABLE",l_status) 
   }
   
END FUNCTION

#--------------------------------------------------------------------#
FUNCTION geo1023_exibe_mensagem_barra_status(l_mensagem,l_tipo_mensagem)
#--------------------------------------------------------------------#

   DEFINE l_mensagem               CHAR(500),
          l_tipo_mensagem          CHAR(010),
          l_tipo_mensagem_original CHAR(015)

   LET l_tipo_mensagem_original = LOG_retorna_tipo_mensagem_original(UPSHIFT(l_tipo_mensagem),TRUE)
   CALL _ADVPL_set_property(m_status_bar,l_tipo_mensagem_original CLIPPED," "||l_mensagem CLIPPED)

 END FUNCTION

#---------------------------------------#
 function geo1023_zoom_manifesto()
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
function geo1023_zoom_resp()
#---------------------------------------#
   DEFINE l_where_clause   CHAR(1000)
   DEFINE l_ind            SMALLINT
   define l_zoom_item varchar(10)
   define l_selecao integer 
   define l_cod_cliente char(15)
   
   INITIALIZE ma_manifesto TO NULL
   call ip_zoom_zoom_cadastro_3_colunas('geo_manifesto a, clientes b',
                                'DISTINCT a.cod_resp',
                                '2',
                                'b.nom_cliente',
                                '20',
                                'b.num_cgc_cpf',
                                '10',
                                'Codigo: ',
                                'Nome: ',
                                'CPF/CNPJ: ',
                                NULL,
                                ' AND a.cod_resp = b.cod_cliente ORDER BY b.nom_cliente ')
    
   LET mr_tela.cod_resp = ip_zoom_3_get_valor()
   LET mr_tela.den_resp = ip_zoom_3_get_valorb()
   
 end function
 
 #---------------------------------#
 FUNCTION geo1023_carrega_cargas()
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
 
#---------------------------------------#
 function geo1023_valid_cod_manifesto()
#---------------------------------------#
   DEFINE l_cnpj LIKE clientes.num_cgc_cpf
   
   
   IF mr_tela.tipo_relat = "A" THEN
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
   END IF 
   RETURN TRUE
 
 end function 
 

 
#-------------------------------------#
FUNCTION geo1023_processar()
#-------------------------------------#
   IF NOT m_consulta_ativa THEN
      CALL _ADVPL_message_box("Informe um manifesto antes de tirar relatório")
 	  RETURN FALSE
   END IF 
   
   CASE mr_tela.tipo_relat
      WHEN "A"
         CALL LOG_progress_start("Geração de relatório","geo1023_relatorio_financeiro","PROCESS")
      WHEN "B"
         CALL LOG_progress_start("Geração de relatório","geo1023_relatorio_vendas","PROCESS")
      WHEN "C"
         CALL LOG_progress_start("Geração de relatório","geo1023_relat_carga_n_enc","PROCESS")
      WHEN "D"
         CALL LOG_progress_start("Geração de relatório","geo1023_relat_carga_enc","PROCESS")
      WHEN "E"
         CALL LOG_progress_start("Geração de relatório","geo1023_relat_resumo_acerto","PROCESS")
      WHEN "F"
         CALL LOG_progress_start("Geração de relatório","geo1023_relat_acerto_encerrados","PROCESS")
   END CASE
   
   RETURN TRUE
END FUNCTION


#-------------------------------------#
 FUNCTION geo1023_relat_acerto_encerrados()
#-------------------------------------#
   DEFINE l_options         SMALLINT
   CALL StartReport("geo1023_relat_encacerto","geo1023","Resumo dos Acertos de Pronta Entrega Encerrados",132,TRUE,TRUE)
   RETURN TRUE
END FUNCTION

#-------------------------------------#
FUNCTION geo1023_relat_encacerto(reportfile)
#-------------------------------------#
   ### PRESTACAO DE CONTAS - RESUMO DE VENDAS
   define l_sql_stmt  char(5000)
   define l_ind integer
   DEFINE reportfile          CHAR(250)
   DEFINE l_sql               CHAR(999)
   DEFINE l_tip_manifesto     CHAR(1)
   DEFINE lr_dados          RECORD
            cod_manifesto   INTEGER,
            dat_fechamento  DATE,
            cod_resp        CHAR(15),
            den_resp        CHAR(36),
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
   
   SELECT tip_manifesto
     INTO l_tip_manifesto
     FROM geo_manifesto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   
   LET m_page_length = ReportPageLength("geo1023")
   START REPORT geo1023_relat_encacer TO reportfile
   
   
   whenever error continue
   delete from temp_funil
   drop table temp_funil
   create temp table temp_funil
   (
   codigo integer
   )
   whenever error stop 
  
   for l_ind = 1 to 999
   	  if ma_funil[l_ind].codigo is null or   ma_funil[l_ind].codigo = ' ' or   ma_funil[l_ind].codigo = 0 then
	     exit for
	  end if
	  insert into temp_funil values(ma_funil[l_ind].codigo)
   end for
			
			
   
   let l_sql_stmt  = " SELECT a.cod_manifesto, (CASE WHEN c.data_movto IS NULL THEN a.dat_manifesto ELSE c.data_movto END), ",
 "           a.cod_resp, ",
 "           b.nom_cliente, ",
 "           NVL(SUM(c.val_bruto),0) VENDAS_A_VISTA, ",
 "           (SELECT NVL(SUM(b.val_duplicata_item),0) ",
 "              FROM fat_nf_mestre a2, fat_nf_item b, cond_pgto d ",
 " 			WHERE a2.empresa = b.empresa ",
 " 			  AND a2.trans_nota_fiscal = b.trans_nota_fiscal ",
 " 			  AND d.cod_cnd_pgto = a2.cond_pagto ",
 " 			  AND d.cod_cnd_pgto <> '999' ",
 " 			  AND d.ies_tipo <> 'V' ",
 " 			  AND a2.sit_nota_fiscal = 'N' ",
 " 			  AND a2.trans_nota_fiscal  IN (SELECT DISTINCT (CASE WHEN a.tip_manifesto = 'R' THEN c.trans_nota_fiscal ELSE c.trans_remessa END) ",
 " 			                                 FROM  geo_remessa_movto c ",
 " 			                                WHERE c.cod_empresa = a2.empresa ", 
 " 			                                AND c.tipo_movto = (CASE WHEN a.tip_manifesto = 'R' THEN 'S' ELSE 'E' END) ",
 " 			                                AND c.cod_manifesto = a.cod_manifesto ",
 " 			                                AND b.item = c.cod_item ",
 " 			                                AND a.cod_empresa = c.cod_empresa) ",
 "               ) VENDAS_A_PRAZO, ",
 "           NVL(NVL(SUM(c.val_bruto),0) + (  SELECT NVL(SUM(b.val_duplicata_item),0) ",
 " 								             FROM fat_nf_mestre a2, fat_nf_item b, cond_pgto d ",
 " 											WHERE a2.empresa = b.empresa ",
 " 											  AND a2.trans_nota_fiscal = b.trans_nota_fiscal ",
 " 											  AND d.cod_cnd_pgto = a2.cond_pagto ",
 " 											  AND d.cod_cnd_pgto <> '999' ",
 " 											  AND d.ies_tipo <> 'V' ",
 " 											  AND a2.sit_nota_fiscal = 'N' ",
 " 											  AND a2.trans_nota_fiscal  IN (SELECT DISTINCT (CASE WHEN a.tip_manifesto = 'R' THEN c.trans_nota_fiscal ELSE c.trans_remessa END) ",
 " 											                                 FROM  geo_remessa_movto c ",
 " 											                                WHERE c.cod_empresa = a2.empresa ", 
 " 											                                AND c.tipo_movto = (CASE WHEN a.tip_manifesto = 'R' THEN 'S' ELSE 'E' END) ",
 " 											                                AND c.cod_manifesto = a.cod_manifesto ",
 " 											                                AND b.item = c.cod_item ",
 " 											                                AND a.cod_empresa = c.cod_empresa) ",
 "               ),0) TOTAL_VENDAS, ",
 "           NVL(SUM(c.val_cheque),0) VALOR_CHEQUES, ",
 "           (SELECT NVL(SUM(e.val_dinheiro),0) ",
 "              FROM geo_acerto_dhr e ",
 "             WHERE e.cod_empresa = a.cod_empresa ",
 "               AND e.cod_manifesto = a.cod_manifesto ",
 "               ) VALOR_DINHEIRO, ",
 "           (SELECT NVL(SUM(d.val_despesa),0) ",
 "              FROM geo_acerto_despesas d ",
 "             WHERE d.cod_empresa = a.cod_empresa ",
 "               AND d.cod_manifesto = a.cod_manifesto ",
 "               ) VALOR_DESPESAS, ",
 "           (SELECT NVL(SUM(d.val_bruto + d.val_juros),0) ",
 "              FROM geo_acerto_cobranca d ",
 "             WHERE d.cod_empresa = a.cod_empresa ",
 "               AND d.cod_manifesto = a.cod_manifesto ",
 "               ) VALOR_COBRANCA, ",
 "           NVL(SUM(0),0) VALOR_OUTROS, ", 
 "           (NVL((SUM(c.val_bruto) + (SELECT NVL(SUM(d.val_bruto + d.val_juros),0) ",
 " 						             FROM geo_acerto_cobranca d ",
 " 						            WHERE d.cod_empresa = a.cod_empresa ",
 " 						              AND d.cod_manifesto = a.cod_manifesto ",
 " 						              )),0) - (SUM(NVL(c.val_cheque,0)) + ((SELECT NVL(SUM(e.val_dinheiro),0) ",
 " 																             FROM geo_acerto_dhr e ",
 " 																            WHERE e.cod_empresa = a.cod_empresa ",
 " 																              AND e.cod_manifesto = a.cod_manifesto ",
 " 																              )) +  ",
 " 																           (SELECT NVL(SUM(d.val_despesa),0) ",
 " 			                                                                  FROM geo_acerto_despesas d ",
 " 			                                                                 WHERE d.cod_empresa = a.cod_empresa ",
 " 			                                                                   AND d.cod_manifesto = a.cod_manifesto ",
 " 			                                                                   ))) VALOR_DIFERENCA ",
 "      FROM clientes b, ",
 "           geo_manifesto a, ",
 "           OUTER  geo_acerto c  ",    
 "     WHERE a.cod_resp = b.cod_cliente ",
 "       AND a.sit_manifesto = 'E' ",
 "       AND a.cod_empresa = c.cod_empresa ",
 " 	  AND a.cod_manifesto = c.cod_manifesto ",
 " 	  AND a.dat_fechamento >= '", mr_tela.data_de,"' ",
 " 	  AND a.dat_fechamento <= '", mr_tela.data_ate,"' ",
 "       AND a.cod_empresa = '", p_cod_empresa,"' ",
 "       and a.cod_manifesto in ( select codigo from temp_funil ) ",
 "     GROUP BY a.cod_manifesto, c.data_movto, a.cod_resp, b.nom_cliente, a.cod_empresa, a.cod_manifesto, a.tip_manifesto, a.dat_manifesto "
 	
	PREPARE var_query FROM l_sql_stmt
	DECLARE cq_cargas_relat SCROLL CURSOR FOR var_query
 
	 
       
   LET mr_total_geral.val_vista = 0
   LET mr_total_geral.val_prazo = 0
   LET mr_total_geral.tot_vendas = 0
   LET mr_total_geral.val_cheques = 0
   LET mr_total_geral.val_dinheiro = 0
   LET mr_total_geral.val_despesas = 0
   LET mr_total_geral.val_cobranca = 0
   LET mr_total_geral.val_diferenca = 0
   
   
   FOREACH cq_cargas_relat INTO lr_dados.*
      OUTPUT TO REPORT geo1023_relat_encacer(lr_dados.*)
   END FOREACH
   
   FINISH REPORT geo1023_relat_encacer
   
   CALL FinishReport("geo1023")
   
END FUNCTION


#------------------------------#
 REPORT geo1023_relat_encacer(lr_relat)
#------------------------------#
  DEFINE lr_relat          RECORD
            cod_manifesto   INTEGER,
            dat_fechamento  DATE,
            cod_resp        CHAR(15),
            den_resp        CHAR(36),
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
         
  DEFINE lr_total_dia          RECORD
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
  
  
  
  DEFINE l_last_row          SMALLINT
  DEFINE l_den_empresa       LIKE empresa.den_empresa
  DEFINE l_condicao_ant      CHAR(50)
  DEFINE l_primeiro          SMALLINT
  DEFINE l_quantidade        DECIMAL(20,2)
  DEFINE l_total             DECIMAL(20,2)
  DEFINE l_geral             DECIMAL(20,2)
  DEFINE l_cod_repres        DECIMAL(4,0)
  
  
  OUTPUT
    RIGHT  MARGIN 0
    LEFT   MARGIN 0
    TOP    MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH m_page_length
    ORDER EXTERNAL BY lr_relat.cod_resp, lr_relat.cod_manifesto
  
  
  
  FORMAT
    
       
    PAGE HEADER
       SELECT den_empresa
         INTO l_den_empresa
         FROM empresa
        WHERE cod_empresa = p_cod_empresa
       
       CALL ReportPageHeader("geo1023")
      
       PRINT COLUMN 001,p_cod_empresa," - ",l_den_empresa CLIPPED,
             COLUMN 095, "Período De: ",mr_tela.data_de," Até ",mr_tela.data_ate
       LET l_last_row = FALSE
         
       CALL ReportThinLine("geo1023")
       SKIP 01 LINE
     
       PRINT COLUMN 045,"        VENDAS DO PERÍODO      ",
             COLUMN 079,"           CRÉDITOS      ",
             COLUMN 113,"DÉBITOS",
             COLUMN 123,"DIFERENÇA"
            
       PRINT COLUMN 045,"-------------------------------",
             COLUMN 079,"-------------------------------",
             COLUMN 113,"---------",
             COLUMN 123,"---------"
            
       PRINT COLUMN 001,"",
             COLUMN 045,"A Vista",
             COLUMN 056,"A Prazo",
             COLUMN 067,"Total",
             COLUMN 079,"Cheques",
             COLUMN 090,"Dinheiro",
             COLUMN 101,"Despesas",
             COLUMN 113,"Cobrança"
     
       PRINT COLUMN 001,"",
             COLUMN 045,"---------",
             COLUMN 056,"---------",
             COLUMN 067,"---------",
             COLUMN 079,"---------",
             COLUMN 090,"---------",
             COLUMN 101,"---------",
             COLUMN 113,"---------",
             COLUMN 123,"---------"  
     
    BEFORE GROUP OF lr_relat.dat_fechamento
       LET lr_total_dia.val_vista = 0
       LET lr_total_dia.val_prazo = 0
       LET lr_total_dia.tot_vendas = 0
       LET lr_total_dia.val_cheques = 0
       LET lr_total_dia.val_dinheiro = 0
       LET lr_total_dia.val_despesas = 0
       LET lr_total_dia.val_cobranca = 0
       LET lr_total_dia.val_diferenca = 0
       
       PRINT COLUMN 001,"Data de Encerramento: ",lr_relat.dat_fechamento
       
    ON EVERY ROW
       LET lr_relat.val_diferenca = lr_relat.val_diferenca * (-1)
       
       LET lr_total_dia.val_vista = lr_total_dia.val_vista  + lr_relat.val_vista 
       LET lr_total_dia.val_prazo = lr_total_dia.val_prazo + lr_relat.val_prazo
       LET lr_total_dia.tot_vendas = lr_total_dia.tot_vendas + lr_relat.tot_vendas
       LET lr_total_dia.val_cheques = lr_total_dia.val_cheques + lr_relat.val_cheques
       LET lr_total_dia.val_dinheiro = lr_total_dia.val_dinheiro + lr_relat.val_dinheiro
       LET lr_total_dia.val_despesas = lr_total_dia.val_despesas + lr_relat.val_despesas
       LET lr_total_dia.val_cobranca = lr_total_dia.val_cobranca + lr_relat.val_cobranca
       LET lr_total_dia.val_diferenca = lr_total_dia.val_diferenca + lr_relat.val_diferenca
       
       LET mr_total_geral.val_vista = mr_total_geral.val_vista  + lr_relat.val_vista 
       LET mr_total_geral.val_prazo = mr_total_geral.val_prazo + lr_relat.val_prazo
       LET mr_total_geral.tot_vendas = mr_total_geral.tot_vendas + lr_relat.tot_vendas
       LET mr_total_geral.val_cheques = mr_total_geral.val_cheques + lr_relat.val_cheques
       LET mr_total_geral.val_dinheiro = mr_total_geral.val_dinheiro + lr_relat.val_dinheiro
       LET mr_total_geral.val_despesas = mr_total_geral.val_despesas + lr_relat.val_despesas
       LET mr_total_geral.val_cobranca = mr_total_geral.val_cobranca + lr_relat.val_cobranca
       LET mr_total_geral.val_diferenca = mr_total_geral.val_diferenca + lr_relat.val_diferenca
       
       SELECT cod_repres
         INTO l_cod_repres
         FROM geo_repres_paramet
        WHERE cod_cliente = lr_relat.cod_resp
       IF sqlca.sqlcode <> 0 THEN
          #CALL _ADVPL_message_box("Parametros do representante não encontrados na tabela geo_repres_paramet")
       END IF
       
       PRINT COLUMN 001,l_cod_repres USING "----"," - ",lr_relat.den_resp[1,28] CLIPPED,
             COLUMN 037, lr_relat.cod_manifesto using "-----",
             COLUMN 045, lr_relat.val_vista USING "#####&.&&",
             COLUMN 054, lr_relat.val_prazo USING "#######&.&&",
             COLUMN 065, lr_relat.tot_vendas USING "#######&.&&",
             COLUMN 079, lr_relat.val_cheques USING "#####&.&&",
             COLUMN 090, lr_relat.val_dinheiro USING "#####&.&&",
             COLUMN 101, lr_relat.val_despesas USING "#####&.&&",
             COLUMN 113, lr_relat.val_cobranca USING "#####&.&&",
             COLUMN 123, lr_relat.val_diferenca  USING "-----&.&&" 
        

    AFTER GROUP OF lr_relat.dat_fechamento
       CALL ReportThinLine("geo1023")
       PRINT COLUMN 030,"Total do Dia: ",
             COLUMN 045, lr_total_dia.val_vista USING "#####&.&&",
             COLUMN 054, lr_total_dia.val_prazo USING "#######&.&&",
             COLUMN 065, lr_total_dia.tot_vendas USING "#######&.&&",
             COLUMN 079, lr_total_dia.val_cheques USING "#####&.&&",
             COLUMN 090, lr_total_dia.val_dinheiro USING "#####&.&&",
             COLUMN 101, lr_total_dia.val_despesas USING "#####&.&&",
             COLUMN 113, lr_total_dia.val_cobranca USING "#####&.&&",
             COLUMN 123, lr_total_dia.val_diferenca  USING "-----&.&&"
       SKIP 01 LINE
         CALL ReportThinLine("geo1023")
         #SKIP 01 LINE
         
         
    ON LAST ROW
       SKIP 03 LINE
       LET l_last_row = TRUE
       CALL ReportThinLine("geo1023")
       {PRINT COLUMN 031,"Total Geral: ",
             COLUMN 044, mr_total_geral.val_vista USING "######&.&&",
             COLUMN 055, mr_total_geral.val_prazo USING "######&.&&",
             COLUMN 066, mr_total_geral.tot_vendas USING "######&.&&",
             COLUMN 079, mr_total_geral.val_cheques USING "#####&.&&",
             COLUMN 090, mr_total_geral.val_dinheiro USING "#####&.&&",
             COLUMN 101, mr_total_geral.val_despesas USING "#####&.&&",
             COLUMN 113, mr_total_geral.val_cobranca USING "#####&.&&",
             COLUMN 123, mr_total_geral.val_diferenca  USING "-----&.&&"}
       PRINT COLUMN 044,"                   Total Geral "
       PRINT COLUMN 044,"------------------------------------------------"
       PRINT COLUMN 044, "      Total vendas à vista: ",mr_total_geral.val_vista USING "#########&.&&"
       PRINT COLUMN 044, "      Total vendas à prazo: ",mr_total_geral.val_prazo USING "#########&.&&"
       PRINT COLUMN 044, "           Total de vendas: ",mr_total_geral.tot_vendas USING "#########&.&&"
       PRINT COLUMN 044, "   Total crédito em cheque: ",mr_total_geral.val_cheques USING "#########&.&&"
       PRINT COLUMN 044, " Total crédito em dinheiro: ",mr_total_geral.val_dinheiro USING "#########&.&&"
       PRINT COLUMN 044, "            Total despesas: ",mr_total_geral.val_despesas USING "#########&.&&"
       PRINT COLUMN 044, "Total débitos de Cobranças: ",mr_total_geral.val_cobranca USING "#########&.&&"
       PRINT COLUMN 044, "          Total diferenças: ",mr_total_geral.val_diferenca  USING "---------&.&&"
       
    PAGE TRAILER
       
               
       IF l_last_row = TRUE THEN
         #PRINT "* * *  ULTIMA FOLHA  * * *", log5211_termino_impressao() CLIPPED
         PRINT " "
       ELSE
         PRINT " "
       END IF

END REPORT

#-------------------------------------#
 FUNCTION geo1023_relat_resumo_acerto()
#-------------------------------------#
   DEFINE l_options         SMALLINT
   CALL StartReport("geo1023_relat_resacerto","geo1023","Resumo dos Acertos de Pronta Entrega Encerrados",132,TRUE,TRUE)
   RETURN TRUE
END FUNCTION

#-------------------------------------#
FUNCTION geo1023_relat_resacerto(reportfile)
#-------------------------------------#
   ### PRESTACAO DE CONTAS - RESUMO DE VENDAS
   DEFINE reportfile          CHAR(250)
   DEFINE l_sql               CHAR(999)
   DEFINE l_tip_manifesto     CHAR(1)
   DEFINE lr_dados          RECORD
            cod_manifesto   INTEGER,
            dat_fechamento  DATE,
            cod_resp        CHAR(15),
            den_resp        CHAR(36),
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
   
   SELECT tip_manifesto
     INTO l_tip_manifesto
     FROM geo_manifesto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   
   LET m_page_length = ReportPageLength("geo1023")
   START REPORT geo1023_relat_resacer TO reportfile
   
  
    DECLARE cq_cargas_relat CURSOR FOR
   SELECT a.cod_manifesto, (CASE WHEN c.data_movto IS NULL THEN a.dat_manifesto ELSE c.data_movto END),
          a.cod_resp,
          b.nom_cliente,
          NVL(SUM(c.val_bruto),0) VENDAS_A_VISTA,
          (SELECT NVL(SUM(b.val_duplicata_item),0)
             FROM fat_nf_mestre a2, fat_nf_item b, cond_pgto d
			WHERE a2.empresa = b.empresa
			  AND a2.trans_nota_fiscal = b.trans_nota_fiscal
			  AND d.cod_cnd_pgto = a2.cond_pagto
			  AND d.cod_cnd_pgto <> '999'
			  AND d.ies_tipo <> 'V'
			  AND a2.sit_nota_fiscal = 'N'
			  AND a2.trans_nota_fiscal  IN (SELECT DISTINCT (CASE WHEN a.tip_manifesto = 'R' THEN c.trans_nota_fiscal ELSE c.trans_remessa END)
			                                 FROM  geo_remessa_movto c
			                                WHERE c.cod_empresa = a2.empresa 
			                                AND c.tipo_movto = (CASE WHEN a.tip_manifesto = 'R' THEN 'S' ELSE 'E' END)
			                                AND c.cod_manifesto = a.cod_manifesto
			                                AND b.item = c.cod_item
			                                AND a.cod_empresa = c.cod_empresa)
              ) VENDAS_A_PRAZO,
          NVL(NVL(SUM(c.val_bruto),0) + (  SELECT NVL(SUM(b.val_duplicata_item),0)
								             FROM fat_nf_mestre a2, fat_nf_item b, cond_pgto d
											WHERE a2.empresa = b.empresa
											  AND a2.trans_nota_fiscal = b.trans_nota_fiscal
											  AND d.cod_cnd_pgto = a2.cond_pagto
											  AND d.cod_cnd_pgto <> '999'
											  AND d.ies_tipo <> 'V'
											  AND a2.sit_nota_fiscal = 'N'
											  AND a2.trans_nota_fiscal  IN (SELECT DISTINCT (CASE WHEN a.tip_manifesto = 'R' THEN c.trans_nota_fiscal ELSE c.trans_remessa END)
											                                 FROM  geo_remessa_movto c
											                                WHERE c.cod_empresa = a2.empresa 
											                                AND c.tipo_movto = (CASE WHEN a.tip_manifesto = 'R' THEN 'S' ELSE 'E' END)
											                                AND c.cod_manifesto = a.cod_manifesto
											                                AND b.item = c.cod_item
											                                AND a.cod_empresa = c.cod_empresa)
              ),0) TOTAL_VENDAS,
          NVL(SUM(c.val_cheque),0) VALOR_CHEQUES,
          (SELECT NVL(SUM(e.val_dinheiro),0)
             FROM geo_acerto_dhr e
            WHERE e.cod_empresa = a.cod_empresa
              AND e.cod_manifesto = a.cod_manifesto
              ) VALOR_DINHEIRO,
          (SELECT NVL(SUM(d.val_despesa),0)
             FROM geo_acerto_despesas d
            WHERE d.cod_empresa = a.cod_empresa
              AND d.cod_manifesto = a.cod_manifesto
              ) VALOR_DESPESAS,
          (SELECT NVL(SUM(d.val_bruto + d.val_juros),0)
             FROM geo_acerto_cobranca d
            WHERE d.cod_empresa = a.cod_empresa
              AND d.cod_manifesto = a.cod_manifesto
              ) VALOR_COBRANCA,
          NVL(SUM(0),0) VALOR_OUTROS, 
          (NVL((SUM(c.val_bruto) + (SELECT NVL(SUM(d.val_bruto + d.val_juros),0)
						             FROM geo_acerto_cobranca d
						            WHERE d.cod_empresa = a.cod_empresa
						              AND d.cod_manifesto = a.cod_manifesto
						              )),0) - (SUM(NVL(c.val_cheque,0)) + ((SELECT NVL(SUM(e.val_dinheiro),0)
																             FROM geo_acerto_dhr e
																            WHERE e.cod_empresa = a.cod_empresa
																              AND e.cod_manifesto = a.cod_manifesto
																              )) + 
																           (SELECT NVL(SUM(d.val_despesa),0)
			                                                                  FROM geo_acerto_despesas d
			                                                                 WHERE d.cod_empresa = a.cod_empresa
			                                                                   AND d.cod_manifesto = a.cod_manifesto
			                                                                   ))) VALOR_DIFERENCA
     FROM clientes b,
          geo_manifesto a,
          OUTER  geo_acerto c 
      
    WHERE a.cod_resp = b.cod_cliente
      AND a.sit_manifesto = 'E'
      AND a.cod_empresa = c.cod_empresa
	  AND a.cod_manifesto = c.cod_manifesto
	  AND c.data_movto >= mr_tela.data_de
	  AND c.data_movto <= mr_tela.data_ate
	  AND a.dat_manifesto >= mr_tela.data_de
	  AND a.dat_manifesto <= mr_tela.data_ate
      AND a.cod_empresa = p_cod_empresa
    GROUP BY a.cod_manifesto, c.data_movto, a.cod_resp, b.nom_cliente, a.cod_empresa, a.cod_manifesto, a.tip_manifesto, a.dat_manifesto
	
	
       
   LET mr_total_geral.val_vista = 0
   LET mr_total_geral.val_prazo = 0
   LET mr_total_geral.tot_vendas = 0
   LET mr_total_geral.val_cheques = 0
   LET mr_total_geral.val_dinheiro = 0
   LET mr_total_geral.val_despesas = 0
   LET mr_total_geral.val_cobranca = 0
   LET mr_total_geral.val_diferenca = 0
   
   
   FOREACH cq_cargas_relat INTO lr_dados.*
      OUTPUT TO REPORT geo1023_relat_resacer(lr_dados.*)
   END FOREACH
   
   FINISH REPORT geo1023_relat_resacer
   
   CALL FinishReport("geo1023")
   
END FUNCTION


#-------------------------------------#
 FUNCTION geo1023_relat_carga_n_enc()
#-------------------------------------#
   DEFINE l_options         SMALLINT
   LET m_tipo_relat_cargas = "N"
   CALL StartReport("geo1023_relat_cargas","geo1023","Relação de TODAS as Cargas Não Encerradas",132,TRUE,TRUE)
   RETURN TRUE
END FUNCTION
#-------------------------------------#
 FUNCTION geo1023_relat_carga_enc()
#-------------------------------------#
   DEFINE l_options         SMALLINT
   LET m_tipo_relat_cargas = "E"
   CALL StartReport("geo1023_relat_cargas","geo1023","Relação de Cargas Encerradas no Período",132,TRUE,TRUE)
   RETURN TRUE
END FUNCTION
#-------------------------------------#
 FUNCTION geo1023_relatorio_vendas()
#-------------------------------------#
   DEFINE l_options         SMALLINT
   CALL StartReport("geo1023_rel_resven","geo1023","Prestação de Contas - Resumo de Vendas",132,TRUE,TRUE)
   RETURN TRUE
END FUNCTION
#-------------------------------------#
 FUNCTION geo1023_relatorio_financeiro()
#-------------------------------------#
   DEFINE l_options         SMALLINT
   CALL StartReport("geo1023_rel_fin","geo1023","Prestação de Contas - Financeiro",132,TRUE,TRUE)
   RETURN TRUE
END FUNCTION
#-------------------------------------#
FUNCTION geo1023_relat_cargas(reportfile)
#-------------------------------------#
   ### PRESTACAO DE CONTAS - RESUMO DE VENDAS
   define l_protoc_env_normal char(15)
   DEFINE reportfile          CHAR(250)
   DEFINE l_sql               CHAR(999)
   define l_num_ar integer
   define l_num_nf integer
   define l_obs char(50)
   define l_num_remessa integer
   DEFINE lr_cargas          RECORD
            cod_resp        DECIMAL(4,0),
            den_resp        CHAR(36),
            cod_manifesto   INTEGER,
            data_saida      DATE,
            data_chegada    DATE,
            data_encerrado  DATE,
            num_nf          INTEGER,
            ser_nf          CHAR(3)
         END RECORD
   
   LET m_page_length = ReportPageLength("geo1023")
   START REPORT geo1023_relat_carga TO reportfile
   
   IF m_tipo_relat_cargas = "E" THEN
      LET l_sql = " SELECT DISTINCT d.cod_repres, ",
                         " c.nom_cliente, ",
                         " a.cod_manifesto,  ",
                         " a.dat_manifesto,  ",
                         " b.dat_movto,  ",
                         " a.dat_fechamento, ", 
                         " b.num_remessa,  ",
                         " b.ser_remessa ",
                    " FROM geo_manifesto a, geo_remessa_movto b, clientes c, geo_repres_paramet d ",
                   " WHERE a.cod_empresa = b.cod_empresa ",
                     " AND a.cod_manifesto = b.cod_manifesto ",
                     " AND b.tipo_movto = 'R' ",
                     " AND a.sit_manifesto = 'E' ",
                     " AND c.cod_cliente = a.cod_resp ",
                     " AND d.cod_cliente = c.cod_cliente ",
                     " AND a.dat_manifesto >= '",mr_tela.data_de,"'",
                     " AND a.dat_manifesto <= '",mr_tela.data_ate,"'",
                     " AND b.num_remessa IS NOT NULL "
   ELSE
      LET l_sql = " SELECT DISTINCT d.cod_repres, ",
                         " c.nom_cliente, ",
                         " a.cod_manifesto,  ",
                         " a.dat_manifesto,  ",
                         " b.dat_movto,  ",
                         " a.dat_fechamento, ", 
                         " b.num_remessa,  ",
                         " b.ser_remessa ",
                    " FROM geo_manifesto a, geo_remessa_movto b, clientes c, geo_repres_paramet d ",
                   " WHERE a.cod_empresa = b.cod_empresa ",
                     " AND a.cod_manifesto = b.cod_manifesto ",
                     " AND b.tipo_movto = 'R' ",
                     " AND a.sit_manifesto <> 'E' ",
                     " AND c.cod_cliente = a.cod_resp ",
                     " AND d.cod_cliente = c.cod_cliente ",
                     " AND a.dat_manifesto >= '",mr_tela.data_de,"'",
                     " AND a.dat_manifesto <= '",mr_tela.data_ate,"'",
                     " AND b.num_remessa IS NOT NULL "
   END IF 
   
   PREPARE var_carga FROM l_sql
   DECLARE cq_cargas_relat CURSOR FOR var_carga
   FOREACH cq_cargas_relat INTO lr_cargas.*
      initialize l_num_ar to null 
      declare cq_ar cursor for
      select num_aviso_rec
        from geo_manifesto_ar
       where cod_empresa = p_cod_empresa
         and cod_manifesto = lr_cargas.cod_manifesto
      open cq_ar 
      fetch cq_ar into l_num_ar
      
      if sqlca.sqlcode = 0 then
	     select num_nf
	       into l_num_nf
	       from nf_sup
          where nf_sup.cod_empresa = p_cod_empresa
            and nf_sup.num_aviso_rec = l_num_ar 
	     if l_num_nf = l_num_remessa then
	        let l_obs = 'Pendente'
	     else
	     let l_protoc_env_normal = ''
	
	     select protoc_env_normal 
	       into l_protoc_env_normal
	       from obf_nf_eletr
	      where empresa = p_cod_empresa
	     	and aviso_recebto = l_num_ar
	        	
	         let l_obs = l_num_nf using '<<<<<<<', ' - ', l_protoc_env_normal
	     end if 
      end if
      
      OUTPUT TO REPORT geo1023_relat_carga(lr_cargas.*,l_num_ar,l_num_remessa,l_obs)
   END FOREACH
   
   FINISH REPORT geo1023_relat_carga
   
   CALL FinishReport("geo1023")
   
END FUNCTION

#-------------------------------------#
FUNCTION geo1023_rel_resven(reportfile)
#-------------------------------------#
   ### PRESTACAO DE CONTAS - RESUMO DE VENDAS
   DEFINE reportfile          CHAR(250)
   DEFINE lr_familia            RECORD LIKE familia.*
   DEFINE l_data1,l_data2   CHAR(19)
   DEFINE l_data3,l_data4   DATETIME YEAR TO SECOND
   DEFINE lr_notas              RECORD
            cod_familia     LIKE familia.cod_familia,
            den_familia     LIKE familia.den_familia,
            cod_item        LIKE item.cod_item,
            den_item        LIKE item.den_item,
            qtd_vendido     LIKE fat_nf_item.qtd_item,
            valor_vendido   LIKE fat_nf_item.val_liquido_item,
            qtd_retornado   LIKE aviso_rec.qtd_declarad_nf,
            valor_retornado LIKE aviso_rec.val_liquido_item,
            qtd_total       DECIMAL(20,2),
            val_total       DECIMAL(20,2)
         END RECORD
   
   LET m_page_length = ReportPageLength("geo1023")
   START REPORT geo1023_relat_vendas TO reportfile
   
   DECLARE cq_familias CURSOR FOR
   SELECT *
     FROM familia
    WHERE cod_empresa = p_cod_empresa
   
   LET l_data1 = EXTEND(mr_tela.data_de, YEAR TO DAY)," 00:00:00"
   LET l_data2 = EXTEND(mr_tela.data_ate, YEAR TO DAY)," 23:59:59"
   LET l_data3 = l_data1
   LET l_data4 = l_data2
   FOREACH cq_familias INTO lr_familia.*
      DECLARE cq_nf_vendas CURSOR FOR
      SELECT     "",
                 "",
                 a.cod_item,
                 a.den_item,
                 SUM(b.qtd_item) qtd_vendido,
                 SUM(b.val_liquido_item) valor_vendido
            FROM item a, fat_nf_item b, fat_nf_mestre c
           WHERE a.cod_empresa = b.empresa
             AND b.empresa = c.empresa
             AND a.cod_item = b.item
             AND b.trans_nota_fiscal = c.trans_nota_fiscal
             AND a.cod_empresa = p_cod_empresa
             AND c.dat_hor_emissao >= l_data3
             AND c.dat_hor_emissao <= l_data4
             AND a.cod_familia = lr_familia.cod_familia
             AND c.sit_nota_fiscal = 'N'
             AND c.natureza_operacao IN ('1','11')
           GROUP BY a.cod_item, a.den_item
      
      
      
      FOREACH cq_nf_vendas INTO lr_notas.*
         SELECT SUM(b.qtd_declarad_nf), SUM(b.val_liquido_item)
           INTO lr_notas.qtd_retornado, lr_notas.valor_retornado
           FROM nf_sup a, aviso_rec b
          WHERE a.cod_empresa = b.cod_empresa
            AND a.num_aviso_rec = b.num_aviso_rec
            AND a.cod_empresa = p_cod_empresa
            AND b.cod_item = lr_notas.cod_item
            AND a.dat_emis_nf >= mr_tela.data_de
            AND a.dat_emis_nf <= mr_tela.data_ate
            AND a.ies_especie_nf = 'NFR'
            
         IF lr_notas.qtd_retornado IS NULL OR lr_notas.qtd_retornado = " " THEN
            LET lr_notas.qtd_retornado = 0
         END IF 
         
         IF lr_notas.valor_retornado IS NULL OR lr_notas.valor_retornado = " " THEN
            LET lr_notas.valor_retornado = 0
         END IF 
         
         LET lr_notas.qtd_total = lr_notas.qtd_vendido + lr_notas.qtd_retornado
         LET lr_notas.val_total = lr_notas.valor_vendido + lr_notas.valor_retornado
         
         LET lr_notas.cod_familia = lr_familia.cod_familia
         LET lr_notas.den_familia = lr_familia.den_familia
         
         OUTPUT TO REPORT geo1023_relat_vendas(lr_notas.*)
         
      END FOREACH
      
   END FOREACH
   
   FINISH REPORT geo1023_relat_vendas
   
   CALL FinishReport("geo1023")
   
END FUNCTION


#------------------------------#
 REPORT geo1023_relat_vendas(lr_relat)
#------------------------------#
  DEFINE lr_relat          RECORD
            cod_familia     LIKE familia.cod_familia,
            den_familia     LIKE familia.den_familia,
            cod_item        LIKE item.cod_item,
            den_item        LIKE item.den_item,
            qtd_vendido     LIKE fat_nf_item.qtd_item,
            valor_vendido   LIKE fat_nf_item.val_liquido_item,
            qtd_retornado   LIKE aviso_rec.qtd_declarad_nf,
            valor_retornado LIKE aviso_rec.val_liquido_item,
            qtd_total       DECIMAL(20,2),
            val_total       DECIMAL(20,2)
         END RECORD
         
         
  DEFINE lr_totais     RECORD
            qtd_vendido     LIKE fat_nf_item.qtd_item,
            valor_vendido   LIKE fat_nf_item.val_liquido_item,
            qtd_retornado   LIKE aviso_rec.qtd_declarad_nf,
            valor_retornado LIKE aviso_rec.val_liquido_item,
            qtd_total       DECIMAL(20,2),
            val_total       DECIMAL(20,2)
         END RECORD
  
  DEFINE lr_totais2     RECORD
            qtd_vendido     LIKE fat_nf_item.qtd_item,
            valor_vendido   LIKE fat_nf_item.val_liquido_item,
            qtd_retornado   LIKE aviso_rec.qtd_declarad_nf,
            valor_retornado LIKE aviso_rec.val_liquido_item,
            qtd_total       DECIMAL(20,2),
            val_total       DECIMAL(20,2)
         END RECORD
  DEFINE lr_totais3      RECORD
            condicao    CHAR(50),
            familia     CHAR(50),
            quantidade  DECIMAL(20,2),
            total       DECIMAL(20,2),
            geral       DECIMAL(20,2)
        END RECORD
  DEFINE l_last_row          SMALLINT
  DEFINE l_den_empresa       LIKE empresa.den_empresa
  DEFINE l_condicao_ant      CHAR(50)
  DEFINE l_primeiro          SMALLINT
  DEFINE l_quantidade        DECIMAL(20,2)
  DEFINE l_total             DECIMAL(20,2)
  DEFINE l_geral             DECIMAL(20,2)
  
  
  OUTPUT
    RIGHT  MARGIN 0
    LEFT   MARGIN 0
    TOP    MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH m_page_length
    ORDER EXTERNAL BY lr_relat.cod_familia
  
  
  
  FORMAT

    PAGE HEADER
      LET lr_totais2.qtd_vendido     = 0
      LET lr_totais2.valor_vendido   = 0
      LET lr_totais2.qtd_retornado   = 0
      LET lr_totais2.valor_retornado = 0
      LET lr_totais2.qtd_total       = 0
      LET lr_totais2.val_total       = 0
       
      SELECT den_empresa
        INTO l_den_empresa
        FROM empresa
       WHERE cod_empresa = p_cod_empresa
       
      CALL ReportPageHeader("geo1023")
      
      PRINT COLUMN 001,p_cod_empresa," - ",l_den_empresa CLIPPED
      
      PRINT COLUMN 1, "Acumulado Total do Período",
            COLUMN 095, "Período De: ",mr_tela.data_de," Até ",mr_tela.data_ate
      LET l_last_row = FALSE

         
         CALL ReportThinLine("geo1023")
         SKIP 01 LINE
     
     BEFORE GROUP OF lr_relat.cod_familia
     
         LET lr_totais.qtd_vendido     = 0
         LET lr_totais.valor_vendido   = 0
         LET lr_totais.qtd_retornado   = 0
         LET lr_totais.valor_retornado = 0
         LET lr_totais.qtd_total       = 0
         LET lr_totais.val_total       = 0
     
         PRINT COLUMN 001,lr_relat.den_familia CLIPPED,
               COLUMN 060,"       VENDAS         ",
               COLUMN 085,"       RETORNO        ",
               COLUMN 110,"        TOTAL         "
         
         PRINT COLUMN 058,"----------------------",
               COLUMN 085,"----------------------",
               COLUMN 110,"----------------------"
         
         PRINT COLUMN 001,"Item",
               COLUMN 015,"Descrição",
               COLUMN 058,"Quantidade",
               COLUMN 075,"Valor",
               COLUMN 085,"Quantidade",
               COLUMN 102,"Valor",
               COLUMN 110,"Quantidade",
               COLUMN 127,"Valor"
         CALL ReportThinLine("geo1023")
         
      ON EVERY ROW
         
         LET lr_totais.qtd_vendido     = lr_totais.qtd_vendido + lr_relat.qtd_vendido
         LET lr_totais.valor_vendido   = lr_totais.valor_vendido + lr_relat.valor_vendido
         LET lr_totais.qtd_retornado   = lr_totais.qtd_retornado + lr_relat.qtd_retornado
         LET lr_totais.valor_retornado = lr_totais.valor_retornado + lr_relat.valor_retornado
         LET lr_totais.qtd_total       = lr_totais.qtd_total + lr_relat.qtd_total
         LET lr_totais.val_total       = lr_totais.val_total + lr_relat.val_total
         
         PRINT COLUMN 001,lr_relat.cod_item CLIPPED,
               COLUMN 015,lr_relat.den_item[1,41] CLIPPED,
               COLUMN 058,lr_relat.qtd_vendido USING "######&.&&",
               COLUMN 070,lr_relat.valor_vendido USING "######&.&&",
               COLUMN 085,lr_relat.qtd_retornado USING "######&.&&",
               COLUMN 097,lr_relat.valor_retornado USING "######&.&&",
               COLUMN 110,lr_relat.qtd_total USING "######&.&&",
               COLUMN 122,lr_relat.val_total USING "######&.&&"

    AFTER GROUP OF lr_relat.cod_familia
         CALL ReportThinLine("geo1023")
         
         LET lr_totais2.qtd_vendido     = lr_totais2.qtd_vendido + lr_totais.qtd_vendido
         LET lr_totais2.valor_vendido   = lr_totais2.valor_vendido + lr_totais.valor_vendido
         LET lr_totais2.qtd_retornado   = lr_totais2.qtd_retornado + lr_totais.qtd_retornado
         LET lr_totais2.valor_retornado = lr_totais2.valor_retornado + lr_totais.valor_retornado
         LET lr_totais2.qtd_total       = lr_totais2.qtd_total + lr_totais.qtd_total
         LET lr_totais2.val_total       = lr_totais2.val_total + lr_totais.val_total
         
         
         PRINT COLUMN 001,"TOTAL ",
               COLUMN 015,"",
               COLUMN 058,lr_totais.qtd_vendido USING "######&.&&",
               COLUMN 070,lr_totais.valor_vendido USING "######&.&&",
               COLUMN 085,lr_totais.qtd_retornado USING "######&.&&",
               COLUMN 097,lr_totais.valor_retornado USING "######&.&&",
               COLUMN 110,lr_totais.qtd_total USING "######&.&&",
               COLUMN 122,lr_totais.val_total USING "######&.&&"
         SKIP 01 LINE
         
    ON LAST ROW
       SKIP 01 LINE
       LET l_last_row = TRUE
       CALL ReportThinLine("geo1023")
       
               
        SKIP 01 LINE
        SKIP 01 LINE
        SKIP 01 LINE
        SKIP 01 LINE
        
        DECLARE cq_totais_prazo_vista CURSOR FOR 
        SELECT (CASE WHEN c.ies_tipo <> 'V' and c.cod_cnd_pgto <> '999' THEN
                   'A PRAZO'
                ELSE
                   'A VISTA'
                END ) condicao,
                d.den_familia, 
                SUM(b.qtd_item), 
                SUM(b.val_liquido_item), 
                SUM(b.val_liquido_item), 
                1
           FROM fat_nf_mestre a, fat_nf_item b, cond_pgto c, familia d, item e
          WHERE a.empresa = b.empresa
            AND a.empresa = d.cod_empresa
            AND a.trans_nota_fiscal = b.trans_nota_fiscal
            AND a.cond_pagto = c.cod_cnd_pgto 
            AND e.cod_empresa = a.empresa
            AND b.item = e.cod_item
            AND d.cod_familia = e.cod_familia
            AND a.empresa = p_cod_empresa
            AND a.dat_hor_emissao >= mr_tela.data_de
            AND a.dat_hor_emissao <= mr_tela.data_ate
            AND a.sit_nota_fiscal = 'N'
          GROUP BY (CASE WHEN c.ies_tipo <> 'V' and c.cod_cnd_pgto <> '999' THEN
                       'A PRAZO'
                    ELSE
                       'A VISTA'
                    END ), 
                    d.den_familia
       UNION ALL
          SELECT 'RETORNO',
                 d.den_familia, 
                 SUM(b.qtd_declarad_nf), 
                 SUM(b.val_liquido_item), 
                 SUM(b.val_liquido_item), 
                 2
            FROM nf_sup a, aviso_rec b, familia d, item e
           WHERE a.cod_empresa = b.cod_empresa
             AND a.cod_empresa = d.cod_empresa
             AND a.num_aviso_rec = b.num_aviso_rec
             AND e.cod_empresa = a.cod_empresa
             AND b.cod_item = e.cod_item
             AND d.cod_familia = e.cod_familia
             AND a.cod_empresa = p_cod_empresa
             AND a.dat_emis_nf >= mr_tela.data_de
             AND a.dat_emis_nf <= mr_tela.data_ate
             AND a.ies_especie_nf = 'NFR'
           GROUP BY  d.den_familia
           ORDER BY 6, (CASE WHEN c.ies_tipo <> 'V' and c.cod_cnd_pgto <> '999' THEN
                           'A PRAZO'
                        ELSE
                           'A VISTA'
                        END ) DESC
        
        LET l_condicao_ant = "INICIO"
        LET l_primeiro = TRUE
        
        FOREACH cq_totais_prazo_vista INTO lr_totais3.*
           IF l_condicao_ant <> lr_totais3.condicao THEN
              IF NOT l_primeiro THEN
                 PRINT COLUMN 001,"---------------------------------------------------------------------"
                 PRINT COLUMN 001,"TOTAL" CLIPPED,
                       COLUMN 030,l_quantidade USING "######&.&&",
                       COLUMN 045,l_total USING "######&.&&",
                       COLUMN 060,l_geral USING "######&.&&"
                 SKIP 01 LINE
              END IF 
              PRINT COLUMN 001,lr_totais3.condicao CLIPPED,
                    COLUMN 030,"Quantidade",
                    COLUMN 050,"Total",
                    COLUMN 065,"Geral"
              PRINT COLUMN 001,"---------------------------------------------------------------------"
              
              LET l_condicao_ant = lr_totais3.condicao
              LET l_quantidade = 0
              LET l_total = 0
              LET l_geral = 0
           END IF 
              LET l_quantidade = l_quantidade + lr_totais3.quantidade
              LET l_total = l_total + lr_totais3.total
              LET l_geral = l_geral + lr_totais3.geral
              PRINT COLUMN 001,lr_totais3.familia CLIPPED,
                    COLUMN 030,lr_totais3.quantidade USING "######&.&&",
                    COLUMN 045,lr_totais3.total USING "######&.&&",
                    COLUMN 060,lr_totais3.geral USING "######&.&&"
           
           LET l_primeiro = FALSE
        END FOREACH
        
        PRINT COLUMN 001,"---------------------------------------------------------------------"
        PRINT COLUMN 001,"TOTAL" CLIPPED,
              COLUMN 030,l_quantidade USING "######&.&&",
              COLUMN 045,l_total USING "######&.&&",
              COLUMN 060,l_geral USING "######&.&&"
              
    PAGE TRAILER
       IF l_last_row = TRUE THEN
         #PRINT "* * *  ULTIMA FOLHA  * * *", log5211_termino_impressao() CLIPPED
         PRINT " "
       ELSE
         PRINT " "
       END IF

END REPORT



#-------------------------------------#
FUNCTION geo1023_rel_fin(reportfile)
#-------------------------------------#
   ### PRESTACAO DE CONTAS - FINANCEIRO
   DEFINE l_ind               SMALLINT
   DEFINE reportfile          CHAR(250)
   DEFINE l_val_item          LIKE fat_nf_item.preco_unit_liquido
   DEFINE l_tip_manifesto     CHAR(1)
   DEFINE lr_relat            RECORD
            cod_item       LIKE item.cod_item,
            den_item       LIKE item.den_item,
            qtd_carga      LIKE fat_nf_item.qtd_item,
            qtd_retorno    LIKE fat_nf_item.qtd_item,
            qtd_vendas     LIKE fat_nf_item.qtd_item,
            qtd_bonif      LIKE fat_nf_item.qtd_item,
            qtd_troca      LIKE fat_nf_item.qtd_item,
            qtd_vbt        LIKE fat_nf_item.qtd_item,
            val_fatur      DECIMAL(12,2)
                             END RECORD
                             
   CALL geo1023_carrega_cargas()
   LET m_page_length = ReportPageLength("geo1023")
   START REPORT geo1023_relat_fin TO reportfile
   
   SELECT tip_manifesto
     INTO l_tip_manifesto
     FROM geo_manifesto
    WHERE cod_empresa = p_cod_empresa
      AND cod_manifesto = mr_tela.cod_manifesto
   
   FOR l_ind = 1 TO m_ind_carga
      LET lr_relat.cod_item       = ma_carga[l_ind].cod_item
      LET lr_relat.den_item       = ma_carga[l_ind].den_item
      LET lr_relat.qtd_carga      = ma_carga[l_ind].qtd_remessa
      LET lr_relat.qtd_retorno    = ma_carga[l_ind].qtd_retornado
      LET lr_relat.qtd_vendas     = ma_carga[l_ind].qtd_vendido
      LET lr_relat.qtd_bonif      = 0
      LET lr_relat.qtd_troca      = 0
      LET lr_relat.qtd_vbt        = lr_relat.qtd_vendas + lr_relat.qtd_bonif + lr_relat.qtd_troca
      
      IF l_tip_manifesto = "R" THEN
	      SELECT SUM(a.val_duplicata_item)
	        INTO lr_relat.val_fatur
	        FROM fat_nf_item a, fat_nf_mestre b
	       WHERE a.empresa = p_cod_empresa
	         AND a.empresa = b.empresa
	         AND b.trans_nota_fiscal = a.trans_nota_fiscal
	         AND b.sit_nota_fiscal = 'N'
	         AND a.item = ma_carga[l_ind].cod_item
	         AND a.trans_nota_fiscal IN (SELECT DISTINCT trans_nota_fiscal
	                                       FROM geo_remessa_movto
	                                      WHERE cod_empresa = p_cod_empresa
	                                        AND cod_manifesto = mr_tela.cod_manifesto
	                                        AND cod_item = ma_carga[l_ind].cod_item
	                                        AND tipo_movto = 'S') 
	  ELSE
	      SELECT SUM(a.val_duplicata_item)
	        INTO lr_relat.val_fatur
	        FROM fat_nf_item a, fat_nf_mestre b
	       WHERE a.empresa = p_cod_empresa
	         AND a.empresa = b.empresa
	         AND b.trans_nota_fiscal = a.trans_nota_fiscal
	         AND b.sit_nota_fiscal = 'N'
	         AND a.item = ma_carga[l_ind].cod_item
	         AND a.trans_nota_fiscal IN (SELECT DISTINCT trans_remessa
	                                       FROM geo_remessa_movto
	                                      WHERE cod_empresa = p_cod_empresa
	                                        AND cod_manifesto = mr_tela.cod_manifesto
	                                        AND cod_item = ma_carga[l_ind].cod_item
	                                        AND tipo_movto = 'E') 
	  END IF
      IF l_val_item IS NULL OR l_val_item = " " THEN
         LET l_val_item = 0
      END IF 
      
      IF lr_relat.val_fatur IS NULL OR lr_relat.val_fatur = " " THEN
         LET lr_relat.val_fatur  = 0
      END IF 
      
      OUTPUT TO REPORT geo1023_relat_fin(lr_relat.*)
   END FOR
   
   FINISH REPORT geo1023_relat_fin
   
   CALL FinishReport("geo1023")
   
END FUNCTION


#------------------------------#
 REPORT geo1023_relat_fin(lr_relat)
#------------------------------#
  DEFINE lr_relat            RECORD
            cod_item       LIKE item.cod_item,
            den_item       LIKE item.den_item,
            qtd_carga      LIKE fat_nf_item.qtd_item,
            qtd_retorno    LIKE fat_nf_item.qtd_item,
            qtd_vendas     LIKE fat_nf_item.qtd_item,
            qtd_bonif      LIKE fat_nf_item.qtd_item,
            qtd_troca      LIKE fat_nf_item.qtd_item,
            qtd_vbt        LIKE fat_nf_item.qtd_item,
            val_fatur      DECIMAL(12,2)
                             END RECORD
  DEFINE la_nfs            ARRAY[9999] OF RECORD
              num_remessa    INTEGER,
              ser_remessa    CHAR(3)
                           END RECORD                           
  DEFINE l_last_row          SMALLINT,
         l_ind               SMALLINT,
         l_material          CHAR(15),
         l_cor               CHAR(15),
         l_qtd_necessaria    DECIMAL(14,7),
         l_den_empresa       LIKE empresa.den_empresa,
         l_repres            LIKE representante.raz_social,
         l_data_ini          DATE,
         l_data_fim          DATE,
         l_tot_carga         LIKE fat_nf_item.qtd_item,
         l_tot_retorno       LIKE fat_nf_item.qtd_item,
         l_tot_vendas        LIKE fat_nf_item.qtd_item,
         l_tot_bonif         LIKE fat_nf_item.qtd_item,
         l_tot_troca         LIKE fat_nf_item.qtd_item,
         l_tot_vbt           LIKE fat_nf_item.qtd_item,
         l_tot_fatur         DECIMAL(12,2),
         l_data_enc          CHAR(10),
         l_hora_enc          CHAR(10),
         l_saldo             DECIMAL(12,2),
         l_saldo_ant         DECIMAL(12,2),
         l_saldo_atual       DECIMAL(12,2),
         l_outros_rec        DECIMAL(12,2),
         l_tot_cobrancas     DECIMAL(12,2),
         l_diferenca         DECIMAL(12,2),
         l_tot_cdd           DECIMAL(12,2),
         l_tot_vco           DECIMAL(12,2),
         l_tot_despesas      DECIMAL(12,2),
         l_val_cheque        DECIMAL(12,2),
         l_val_dinheiro      DECIMAL(12,2),
         l_val_total         DECIMAL(12,2),
         l_val_vista         DECIMAL(12,2),
         l_val_prazo         DECIMAL(12,2),
         l_op1               CHAR(1),
         l_op2               CHAR(2),
         l_tip_manifesto     CHAR(1)
         
         
         
  OUTPUT
    RIGHT  MARGIN 0
    LEFT   MARGIN 0
    TOP    MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH m_page_length
    
  
  
  
  FORMAT

    PAGE HEADER
       LET l_tot_carga   = 0
       LET l_tot_retorno = 0
       LET l_tot_vendas  = 0
       LET l_tot_bonif   = 0
       LET l_tot_troca   = 0
       LET l_tot_vbt     = 0
       LET l_tot_fatur   = 0
       
      SELECT den_empresa
        INTO l_den_empresa
        FROM empresa
       WHERE cod_empresa = p_cod_empresa
       
      CALL ReportPageHeader("geo1023")
      SELECT dat_fechamento
        INTO l_data_enc
        FROM geo_manifesto
       WHERE cod_empresa = p_cod_empresa
         AND cod_manifesto = mr_tela.cod_manifesto
      PRINT COLUMN 001,p_cod_empresa," - ",l_den_empresa CLIPPED,
            COLUMN 094, "Encerramento: ",l_data_enc
      
      
      DECLARE cq_nfs_remessa CURSOR FOR
      SELECT DISTINCT num_remessa, ser_remessa
        FROM geo_remessa_movto
       WHERE cod_empresa = p_cod_empresa
         AND cod_manifesto = mr_tela.cod_manifesto
         AND tipo_movto = 'E'
      
      LET l_ind = 1
      INITIALIZE la_nfs TO NULL
      FOREACH cq_nfs_remessa INTO la_nfs[l_ind].*
         LET l_ind = l_ind + 1
      END FOREACH
      
      FOR l_ind = 1 TO 9999
         IF la_nfs[l_ind].num_remessa = "0" OR la_nfs[l_ind].num_remessa IS NULL OR la_nfs[l_ind].num_remessa = " " THEN
            INITIALIZE la_nfs[l_ind].* TO NULL
         END IF  
      END FOR 
      
      SELECT cod_repres
        INTO m_cod_repres
        FROM geo_repres_paramet
       WHERE cod_cliente = mr_tela.cod_resp
      
      IF m_cod_repres = "9999" THEN
         LET l_repres = "TORREFACOES NOIVACOLINENSES LTDA"
      ELSE
         SELECT raz_social
           INTO l_repres
           FROM representante
          WHERE cod_repres = m_cod_repres
      END IF
      
      SELECT DISTINCT cod_empresa
        FROM geo_manifesto
       WHERE cod_empresa = p_cod_empresa
         AND cod_manifesto = mr_tela.cod_manifesto
         AND tip_manifesto = 'B'
      IF sqlca.sqlcode = 0 THEN
          SELECT DATE(MIN(dat_hor_emissao))
            INTO l_data_ini
            FROM fat_nf_mestre
           WHERE empresa = p_cod_empresa
             AND sit_nota_fiscal = 'N'
             AND trans_nota_fiscal IN (SELECT trans_remessa
                                         FROM geo_remessa_movto
                                        WHERE cod_empresa = p_cod_empresa
                                          AND tipo_movto = 'E'
                                          AND cod_manifesto = mr_tela.cod_manifesto)
         
         SELECT DATE(MAX(dat_hor_emissao))
            INTO l_data_fim
            FROM fat_nf_mestre
           WHERE empresa = p_cod_empresa
             AND sit_nota_fiscal = 'N'
             AND trans_nota_fiscal IN (SELECT trans_remessa
                                         FROM geo_remessa_movto
                                        WHERE cod_empresa = p_cod_empresa
                                          AND tipo_movto = 'R'
                                          AND cod_manifesto = mr_tela.cod_manifesto)
      ELSE
	      SELECT MIN(dat_movto)
	        INTO l_data_ini
	        FROM geo_remessa_movto
	       WHERE cod_empresa = p_cod_empresa
	         AND cod_manifesto = mr_tela.cod_manifesto
	         AND tipo_movto = 'E'
	      
	      SELECT MAX(dat_movto)
	        INTO l_data_fim
	        FROM geo_remessa_movto
	       WHERE cod_empresa = p_cod_empresa
	         AND cod_manifesto = mr_tela.cod_manifesto
	         AND tipo_movto = 'R'
      END IF
            
      PRINT COLUMN 1, m_cod_repres USING "####"," - ",l_repres CLIPPED,"          Manifesto: ",mr_tela.cod_manifesto,
            COLUMN 095, "Período De: ",l_data_ini," Até ",l_data_fim
      LET l_last_row = FALSE

         
         CALL ReportThinLine("geo1023")
         SKIP 01 LINE
         PRINT COLUMN 001,"Item",
               COLUMN 015,"Descrição",
               COLUMN 050,"Carrega",
               COLUMN 060,"Retorno",
               COLUMN 070,"Vendas",
               COLUMN 080,"Bonif.",
               COLUMN 090,"Troca",
               COLUMN 100,"V+B+T",
               COLUMN 120,"Vlr Faturado"
         CALL ReportThinLine("geo1023")
         
      ON EVERY ROW
      
         LET l_tot_carga   = l_tot_carga + lr_relat.qtd_carga
         LET l_tot_retorno = l_tot_retorno + lr_relat.qtd_retorno
         LET l_tot_vendas  = l_tot_vendas + lr_relat.qtd_vendas
         LET l_tot_bonif   = l_tot_bonif + lr_relat.qtd_bonif
         LET l_tot_troca   = l_tot_troca + lr_relat.qtd_troca
         LET l_tot_vbt     = l_tot_vbt + lr_relat.qtd_vbt
         LET l_tot_fatur   = l_tot_fatur + lr_relat.val_fatur
         
         PRINT COLUMN 001,lr_relat.cod_item CLIPPED,
               COLUMN 015,lr_relat.den_item[1,32] CLIPPED,
               COLUMN 049,lr_relat.qtd_carga USING "####&.&&",
               COLUMN 059,lr_relat.qtd_retorno USING "####&.&&",
               COLUMN 068,lr_relat.qtd_vendas USING "####&.&&",
               COLUMN 078,lr_relat.qtd_bonif USING "####&.&&",
               COLUMN 087,lr_relat.qtd_troca USING "####&.&&",
               COLUMN 097,lr_relat.qtd_vbt USING "####&.&&",
               COLUMN 122,lr_relat.val_fatur USING "######&.&&"


    ON LAST ROW
       SKIP 01 LINE
       LET l_last_row = TRUE
       CALL ReportThinLine("geo1023")
       PRINT COLUMN 001,"Total" ,
               COLUMN 049,l_tot_carga USING "####&.&&",
               COLUMN 059,l_tot_retorno USING "####&.&&",
               COLUMN 068,l_tot_vendas USING "####&.&&",
               COLUMN 078,l_tot_bonif USING "####&.&&",
               COLUMN 087,l_tot_troca USING "####&.&&",
               COLUMN 097,l_tot_vbt USING "####&.&&",
               COLUMN 122,l_tot_fatur USING "######&.&&"
               
        SKIP 01 LINE
        SKIP 01 LINE
        SKIP 01 LINE
        SKIP 01 LINE
        
        SELECT tip_manifesto
          INTO l_tip_manifesto
          FROM geo_manifesto
         WHERE cod_empresa = p_cod_empresa
           AND cod_manifesto = mr_tela.cod_manifesto
        
        IF l_tip_manifesto = "R" THEN
	        SELECT SUM(b.val_duplicata_item)
	          INTO l_val_prazo
	          FROM fat_nf_mestre a, fat_nf_item b, geo_remessa_movto c, cond_pgto d
	         WHERE a.empresa = b.empresa
	           AND a.trans_nota_fiscal = b.trans_nota_fiscal
	           AND c.cod_empresa = a.empresa
	           AND c.trans_nota_fiscal = a.trans_nota_fiscal
	           AND c.tipo_movto = 'S'
	           AND c.cod_manifesto = mr_tela.cod_manifesto
	           AND d.cod_cnd_pgto = a.cond_pagto
	           AND d.cod_cnd_pgto <> '999'
	           AND d.ies_tipo <> 'V'
	           AND b.item = c.cod_item
	           AND a.sit_nota_fiscal = 'N'
	           AND a.empresa = p_cod_empresa
	        
	        SELECT SUM(b.val_duplicata_item)
	          INTO l_val_vista
	          FROM fat_nf_mestre a, fat_nf_item b, geo_remessa_movto c, cond_pgto d, fat_nf_duplicata e
	         WHERE a.empresa = b.empresa
	           AND a.trans_nota_fiscal = b.trans_nota_fiscal
	           AND c.cod_empresa = a.empresa
	           AND c.trans_nota_fiscal = a.trans_nota_fiscal
	           AND c.tipo_movto = 'S'
	           AND c.cod_manifesto = mr_tela.cod_manifesto
	           AND d.cod_cnd_pgto = a.cond_pagto
	           AND d.cod_cnd_pgto <> '999'
	           AND d.ies_tipo = 'V'
	           AND b.item = c.cod_item
	           AND a.sit_nota_fiscal = 'N'
	           AND a.empresa = p_cod_empresa
	           AND e.empresa = a.empresa
	           AND e.trans_nota_fiscal = a.trans_nota_fiscal
	           AND e.docum_cre IN (SELECT cod_titulo 
	                                 FROM geo_acerto 
	                                WHERE cod_empresa = a.empresa
	                                  AND cod_manifesto = c.cod_manifesto)
	    ELSE
	    	SELECT SUM(b.val_duplicata_item)
	          INTO l_val_prazo
	          FROM fat_nf_mestre a, fat_nf_item b, geo_remessa_movto c, cond_pgto d
	         WHERE a.empresa = b.empresa
	           AND a.trans_nota_fiscal = b.trans_nota_fiscal
	           AND c.cod_empresa = a.empresa
	           AND c.trans_remessa = a.trans_nota_fiscal
	           AND c.tipo_movto = 'E'
	           AND c.cod_manifesto = mr_tela.cod_manifesto
	           AND d.cod_cnd_pgto = a.cond_pagto
	           AND d.cod_cnd_pgto <> '999'
	           AND d.ies_tipo <> 'V'
	           AND b.item = c.cod_item
	           AND a.sit_nota_fiscal = 'N'
	           AND a.empresa = p_cod_empresa
	        {SELECT SUM(c.val_duplicata)
	        INTO l_val_prazo
			FROM fat_nf_mestre a,  
			fat_nf_repr b,  
			fat_nf_duplicata c,  
			docum e,  
			cond_pgto g,
			geo_repres_paramet j 
			WHERE a.empresa           = c.empresa 
			AND e.cod_empresa       = a.empresa 
			AND a.trans_nota_fiscal = c.trans_nota_fiscal 
			AND c.docum_cre         = e.num_docum 
			AND a.cond_pagto        = g.cod_cnd_pgto 
			AND a.sit_nota_fiscal   = 'N' 
			AND j.cod_repres        = b.representante 
			AND b.empresa           = a.empresa 
			AND b.trans_nota_fiscal = a.trans_nota_fiscal 
			AND g.ies_tipo <> 'V'
			AND g.cod_cnd_pgto <> '999'
			AND a.trans_nota_fiscal IN (
			SELECT DISTINCT trans_remessa
			  FROM geo_remessa_movto
			 WHERE cod_empresa = p_cod_empresa
			   AND cod_manifesto = mr_tela.cod_manifesto
			   AND tipo_movto = 'E')}
			
	        
	        SELECT SUM(b.val_duplicata_item)
	          INTO l_val_vista
	          FROM fat_nf_mestre a, fat_nf_item b, geo_remessa_movto c, cond_pgto d, fat_nf_duplicata e
	         WHERE a.empresa = b.empresa
	           AND a.trans_nota_fiscal = b.trans_nota_fiscal
	           AND c.cod_empresa = a.empresa
	           AND c.trans_remessa = a.trans_nota_fiscal
	           AND c.tipo_movto = 'E'
	           AND c.cod_manifesto = mr_tela.cod_manifesto
	           AND d.cod_cnd_pgto = a.cond_pagto
	           AND d.cod_cnd_pgto <> '999'
	           AND d.ies_tipo = 'V'
	           AND b.item = c.cod_item
	           AND a.sit_nota_fiscal = 'N'
	           AND a.empresa = p_cod_empresa
	           AND e.empresa = a.empresa
	           AND e.trans_nota_fiscal = a.trans_nota_fiscal
	           AND e.docum_cre IN (SELECT cod_titulo 
	                                 FROM geo_acerto 
	                                WHERE cod_empresa = a.empresa
	                                  AND cod_manifesto = c.cod_manifesto)
	    END IF 
        IF l_val_vista IS NULL OR l_val_vista = " " THEN
           LET l_val_vista = 0
        END IF 
        IF l_val_prazo IS NULL OR l_val_prazo = " " THEN
           LET l_val_prazo = 0
        END IF 
        
        LET l_val_total = l_val_vista + l_val_prazo
        PRINT COLUMN 054,"    VENDAS DO PERÍODO",
              COLUMN 110," NF's DO MANIFESTO ",mr_tela.cod_manifesto 
        PRINT COLUMN 054,"-------------------------",
              COLUMN 110,"-------------------"
        PRINT COLUMN 054, "A Vista:       ",l_val_vista USING "######&.&&",
              COLUMN 110," ",la_nfs[1].num_remessa USING "&&&&&&","         ",la_nfs[1].ser_remessa CLIPPED," "
        PRINT COLUMN 054, "A Prazo:       ",l_val_prazo USING "######&.&&",
              COLUMN 110," ",la_nfs[2].num_remessa USING "&&&&&&","         ",la_nfs[2].ser_remessa CLIPPED," "
        PRINT COLUMN 054,"-------------------------",
              COLUMN 110," ",la_nfs[3].num_remessa USING "&&&&&&","         ",la_nfs[3].ser_remessa CLIPPED," "
        PRINT COLUMN 054, "  Total:       ",l_val_total USING "######&.&&",
              COLUMN 110," ",la_nfs[4].num_remessa USING "&&&&&&","         ",la_nfs[4].ser_remessa CLIPPED," "
        
        
        PRINT COLUMN 110," ",la_nfs[5].num_remessa USING "&&&&&&","         ",la_nfs[5].ser_remessa CLIPPED," "
        PRINT COLUMN 110," ",la_nfs[6].num_remessa USING "&&&&&&","         ",la_nfs[6].ser_remessa CLIPPED," "
        
        INITIALIZE l_val_dinheiro TO NULL
        
        SELECT val_dinheiro
          INTO l_val_dinheiro
          FROM geo_acerto_dhr
         WHERE cod_empresa = p_cod_empresa
           AND cod_manifesto = mr_tela.cod_manifesto
        IF l_val_dinheiro IS NULL OR l_val_dinheiro = " " THEN
           LET l_val_dinheiro = 0
        END IF 
        
        INITIALIZE l_val_cheque TO NULL
        
        SELECT SUM(val_cheque)
          INTO l_val_cheque
          FROM geo_acerto_chq
         WHERE cod_empresa = p_cod_empresa
           AND cod_manifesto = mr_tela.cod_manifesto
        IF l_val_cheque IS NULL OR l_val_cheque = " " THEN
           LET l_val_cheque = 0
        END IF 
        
		INITIALIZE l_tot_despesas TO NULL
        
        SELECT SUM(val_despesa)
          INTO l_tot_despesas
          FROM geo_acerto_despesas
         WHERE cod_empresa = p_cod_empresa
           AND cod_manifesto = mr_tela.cod_manifesto
        IF l_tot_despesas IS NULL OR l_tot_despesas = " " THEN
           LET l_tot_despesas = 0
        END IF 
        
        INITIALIZE l_tot_cobrancas TO NULL
        
        SELECT SUM(val_cheque + val_dinheiro + val_juros)
          INTO l_tot_cobrancas
          FROM geo_acerto_cobranca
         WHERE cod_empresa = p_cod_empresa
           AND cod_manifesto = mr_tela.cod_manifesto
        IF l_tot_cobrancas IS NULL OR l_tot_cobrancas = " " THEN
           LET l_tot_cobrancas = 0
        END IF 
        
        
        
        LET l_outros_rec = 0
        
        LET l_tot_cdd   = (l_val_cheque + l_val_dinheiro + l_tot_despesas)
        LET l_tot_vco  = (l_val_vista + l_tot_cobrancas + l_outros_rec)
        LET l_diferenca = l_tot_vco - l_tot_cdd
        LET l_diferenca = l_diferenca * (-1)
        
        
        PRINT COLUMN 058,"ACERTO FINANCEIRO" ,
              COLUMN 110," ",la_nfs[7].num_remessa USING "&&&&&&","         ",la_nfs[7].ser_remessa CLIPPED," "
        PRINT COLUMN 030,"----------------------------------------------------------------------------",
              COLUMN 110," ",la_nfs[8].num_remessa USING "&&&&&&","         ",la_nfs[8].ser_remessa CLIPPED," "
        PRINT COLUMN 030, "Cheques:        ",l_val_cheque USING "######&.&&","  +",
              COLUMN 070, "Vendas A Vista:        ",l_val_vista USING "######&.&&","  -",
              COLUMN 110," ",la_nfs[9].num_remessa USING "&&&&&&","         ",la_nfs[9].ser_remessa CLIPPED," "
        PRINT COLUMN 030, "Dinheiro:       ",l_val_dinheiro USING "######&.&&","  +",
              COLUMN 070, "     Cobranças:        ",l_tot_cobrancas USING "######&.&&","  -",
              COLUMN 110," ",la_nfs[10].num_remessa USING "&&&&&&","         ",la_nfs[10].ser_remessa CLIPPED," "
        PRINT COLUMN 030, "Despesas:       ",l_tot_despesas USING "######&.&&","  +",
              COLUMN 070, "   Outros Rec.:        ",l_outros_rec USING "######&.&&","  -",
              COLUMN 110," ",la_nfs[11].num_remessa USING "&&&&&&","         ",la_nfs[11].ser_remessa CLIPPED," "
        PRINT COLUMN 030,"----------------------------------------------------------------------------",
              COLUMN 110," ",la_nfs[12].num_remessa USING "&&&&&&","         ",la_nfs[12].ser_remessa CLIPPED," "
        PRINT COLUMN 030, "                ",l_tot_cdd USING "######&.&&",
              COLUMN 070, "                       ",l_tot_vco USING "######&.&&",
              COLUMN 110," ",la_nfs[13].num_remessa USING "&&&&&&","         ",la_nfs[13].ser_remessa CLIPPED," "
        PRINT COLUMN 030,"----------------------------------------------------------------------------",
              COLUMN 110," ",la_nfs[14].num_remessa USING "&&&&&&","         ",la_nfs[14].ser_remessa CLIPPED," "
        PRINT COLUMN 057, "DIFERENÇA: ",l_diferenca USING "------&.&&",
              COLUMN 110," ",la_nfs[15].num_remessa USING "&&&&&&","         ",la_nfs[15].ser_remessa CLIPPED," "
        
        PRINT COLUMN 110," ",la_nfs[16].num_remessa USING "&&&&&&","         ",la_nfs[16].ser_remessa CLIPPED," "
        PRINT COLUMN 110," ",la_nfs[17].num_remessa USING "&&&&&&","         ",la_nfs[17].ser_remessa CLIPPED," "
        
        SELECT saldo_atual, saldo_anterior
          INTO l_saldo_atual, l_saldo #, l_saldo_ant
          FROM geo_acerto_cc
         WHERE cod_empresa = p_cod_empresa
           AND cod_manifesto = mr_tela.cod_manifesto
           
        #LET l_saldo_atual = l_diferenca + l_saldo
        
        PRINT COLUMN 045,"         CONTA CORRENTE DO VENDEDOR         ",
              COLUMN 110," ",la_nfs[18].num_remessa USING "&&&&&&","         ",la_nfs[18].ser_remessa CLIPPED," "
        PRINT COLUMN 045,"--------------------------------------------",
              COLUMN 110," ",la_nfs[19].num_remessa USING "&&&&&&","         ",la_nfs[19].ser_remessa CLIPPED," "
        PRINT COLUMN 045,"    Saldo Anterior:     ",l_saldo USING "------&.&&",
              COLUMN 110," ",la_nfs[20].num_remessa USING "&&&&&&","         ",la_nfs[20].ser_remessa CLIPPED," "
        PRINT COLUMN 045,"    Saldo Atual:        ",l_saldo_atual USING "------&.&&",
              COLUMN 110," ",la_nfs[21].num_remessa USING "&&&&&&","         ",la_nfs[21].ser_remessa CLIPPED," "
        
    PAGE TRAILER
       IF l_last_row = TRUE THEN
         #PRINT "* * *  ULTIMA FOLHA  * * *", log5211_termino_impressao() CLIPPED
         PRINT " "
       ELSE
         PRINT " "
       END IF

END REPORT

#----------------------------------#
FUNCTION geo1023_valid_tipo_relat()
#----------------------------------#
    DEFINE l_status     SMALLINT
    DEFINE l_tipo_ant   CHAR(1)
    DEFINE l_data       CHAR(10)
    
    LET l_status = TRUE
    
    LET l_tipo_ant = mr_tela.tipo_relat
    
    INITIALIZE mr_tela.* TO NULL
    
    LET mr_tela.tipo_relat = l_tipo_ant
    
    CASE mr_tela.tipo_relat
       WHEN "A"
          CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",FALSE)
          CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",FALSE)
          CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",FALSE)
          CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",FALSE)
          CALL _ADVPL_set_property(m_zoom_item,"ENABLE",l_status) 
          CALL _ADVPL_set_property(m_refer_funil,"ENABLE",FALSE)
          
       WHEN "B"
          LET l_data = "01/",EXTEND(CURRENT,MONTH TO MONTH),"/",EXTEND(CURRENT,YEAR TO YEAR)
          LET mr_tela.data_de = l_data
          LET mr_tela.data_ate = TODAY
          CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",FALSE)
          CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",FALSE)
          CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",FALSE)
          CALL _ADVPL_set_property(m_zoom_item,"ENABLE",FALSE) 
          CALL _ADVPL_set_property(m_refer_funil,"ENABLE",FALSE)
          
       WHEN "C"
          LET l_data = "01/",EXTEND(CURRENT,MONTH TO MONTH),"/",EXTEND(CURRENT,YEAR TO YEAR)
          LET mr_tela.data_de = l_data
          LET mr_tela.data_ate = TODAY
          CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",FALSE)
          CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_zoom_item,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_refer_funil,"ENABLE",FALSE)
          
       WHEN "D"
          LET l_data = "01/",EXTEND(CURRENT,MONTH TO MONTH),"/",EXTEND(CURRENT,YEAR TO YEAR)
          LET mr_tela.data_de = l_data
          LET mr_tela.data_ate = TODAY
          CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",FALSE)
          CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_zoom_item,"ENABLE",l_status) 
          CALL _ADVPL_set_property(m_refer_funil,"ENABLE",FALSE)
       WHEN "E"
          LET l_data = "01/",EXTEND(CURRENT,MONTH TO MONTH),"/",EXTEND(CURRENT,YEAR TO YEAR)
          LET mr_tela.data_de = l_data
          LET mr_tela.data_ate = TODAY
          CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",FALSE)
          CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_zoom_item,"ENABLE",l_status) 
          CALL _ADVPL_set_property(m_refer_funil,"ENABLE",FALSE)
       
       WHEN "F"
          LET l_data = "01/",EXTEND(CURRENT,MONTH TO MONTH),"/",EXTEND(CURRENT,YEAR TO YEAR)
          LET mr_tela.data_de = l_data
          LET mr_tela.data_ate = TODAY
          CALL _ADVPL_set_property(m_refer_cod_manifesto,"ENABLE",FALSE)
          CALL _ADVPL_set_property(m_refer_data_de,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_refer_data_ate,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_refer_cod_resp,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_zoom_resp,"ENABLE",l_status)
          CALL _ADVPL_set_property(m_zoom_item,"ENABLE",l_status) 
          CALL _ADVPL_set_property(m_refer_funil,"ENABLE",TRUE)
          
    END CASE
   
END FUNCTION



#------------------------------#
 REPORT geo1023_relat_carga(lr_relat,l_num_ar,l_num_remessa,l_obs)
#------------------------------#
  DEFINE lr_relat          RECORD
            cod_resp        DECIMAL(4,0),
            den_resp        CHAR(36),
            cod_manifesto   INTEGER,
            data_saida      DATE,
            data_chegada    DATE,
            data_encerrado  DATE,
            num_nf          INTEGER,
            ser_nf          CHAR(3)
         END RECORD
         
  define l_num_ar integer
  	   , l_num_remessa integer 
       , l_obs    char(50)
       
  DEFINE l_last_row          SMALLINT
  DEFINE l_den_empresa       LIKE empresa.den_empresa
  DEFINE l_condicao_ant      CHAR(50)
  DEFINE l_primeiro          SMALLINT
  DEFINE l_quantidade        DECIMAL(20,2)
  DEFINE l_total             DECIMAL(20,2)
  DEFINE l_geral             DECIMAL(20,2)
  
  
  OUTPUT
    RIGHT  MARGIN 0
    LEFT   MARGIN 0
    TOP    MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH m_page_length
    ORDER EXTERNAL BY lr_relat.cod_resp
  
  
  
  FORMAT

    PAGE HEADER
      SELECT den_empresa
        INTO l_den_empresa
        FROM empresa
       WHERE cod_empresa = p_cod_empresa
       
      CALL ReportPageHeader("geo1023")
      
      PRINT COLUMN 001,p_cod_empresa," - ",l_den_empresa CLIPPED,
            COLUMN 095, "Período De: ",mr_tela.data_de," Até ",mr_tela.data_ate
      LET l_last_row = FALSE

         
      CALL ReportThinLine("geo1023")
      SKIP 01 LINE
     
     BEFORE GROUP OF lr_relat.cod_resp
     
         PRINT COLUMN 001,lr_relat.cod_resp CLIPPED," - ", lr_relat.den_resp CLIPPED
         
         PRINT COLUMN 010,"Manifesto   Saída       Chegada     Encerrado    NF         Série   AR          Retorno"
         PRINT COLUMN 010,"----------  ----------  ----------  ----------  ----------  ------  ----------  ----------------------"
         
         
      ON EVERY ROW
         
         PRINT COLUMN 010,lr_relat.cod_manifesto USING "&&&&&&",
               COLUMN 022,lr_relat.data_saida ,
               COLUMN 034,lr_relat.data_chegada ,
               COLUMN 046,lr_relat.data_encerrado ,
               COLUMN 058,lr_relat.num_nf USING "&&&&&&",
               COLUMN 070,lr_relat.ser_nf,
               COLUMN 078, l_num_ar USING "<<<<<<<<<&",
               COLUMN 090, l_obs


    AFTER GROUP OF lr_relat.cod_resp
         SKIP 01 LINE
         CALL ReportThinLine("geo1023")
         SKIP 01 LINE
         
    ON LAST ROW
       #SKIP 01 LINE
       LET l_last_row = TRUE
       #CALL ReportThinLine("geo1023")
       
    PAGE TRAILER
       IF l_last_row = TRUE THEN
         #PRINT "* * *  ULTIMA FOLHA  * * *", log5211_termino_impressao() CLIPPED
         PRINT " "
       ELSE
         PRINT " "
       END IF

END REPORT




#------------------------------#
 REPORT geo1023_relat_resacer(lr_relat)
#------------------------------#
  DEFINE lr_relat          RECORD
            cod_manifesto   INTEGER,
            dat_fechamento  DATE,
            cod_resp        CHAR(15),
            den_resp        CHAR(36),
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
         
  DEFINE lr_total_dia          RECORD
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
  
  
  
  DEFINE l_last_row          SMALLINT
  DEFINE l_den_empresa       LIKE empresa.den_empresa
  DEFINE l_condicao_ant      CHAR(50)
  DEFINE l_primeiro          SMALLINT
  DEFINE l_quantidade        DECIMAL(20,2)
  DEFINE l_total             DECIMAL(20,2)
  DEFINE l_geral             DECIMAL(20,2)
  DEFINE l_cod_repres        DECIMAL(4,0)
  
  
  OUTPUT
    RIGHT  MARGIN 0
    LEFT   MARGIN 0
    TOP    MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH m_page_length
    ORDER EXTERNAL BY lr_relat.cod_resp, lr_relat.cod_manifesto
  
  
  
  FORMAT
    
       
    PAGE HEADER
       SELECT den_empresa
         INTO l_den_empresa
         FROM empresa
        WHERE cod_empresa = p_cod_empresa
       
       CALL ReportPageHeader("geo1023")
      
       PRINT COLUMN 001,p_cod_empresa," - ",l_den_empresa CLIPPED,
             COLUMN 095, "Período De: ",mr_tela.data_de," Até ",mr_tela.data_ate
       LET l_last_row = FALSE
         
       CALL ReportThinLine("geo1023")
       SKIP 01 LINE
     
       PRINT COLUMN 045,"        VENDAS DO PERÍODO      ",
             COLUMN 079,"           CRÉDITOS      ",
             COLUMN 113,"DÉBITOS",
             COLUMN 123,"DIFERENÇA"
            
       PRINT COLUMN 045,"-------------------------------",
             COLUMN 079,"-------------------------------",
             COLUMN 113,"---------",
             COLUMN 123,"---------"
            
       PRINT COLUMN 001,"",
             COLUMN 045,"A Vista",
             COLUMN 056,"A Prazo",
             COLUMN 067,"Total",
             COLUMN 079,"Cheques",
             COLUMN 090,"Dinheiro",
             COLUMN 101,"Despesas",
             COLUMN 113,"Cobrança"
     
       PRINT COLUMN 001,"",
             COLUMN 045,"---------",
             COLUMN 056,"---------",
             COLUMN 067,"---------",
             COLUMN 079,"---------",
             COLUMN 090,"---------",
             COLUMN 101,"---------",
             COLUMN 113,"---------",
             COLUMN 123,"---------"  
     
    BEFORE GROUP OF lr_relat.dat_fechamento
       LET lr_total_dia.val_vista = 0
       LET lr_total_dia.val_prazo = 0
       LET lr_total_dia.tot_vendas = 0
       LET lr_total_dia.val_cheques = 0
       LET lr_total_dia.val_dinheiro = 0
       LET lr_total_dia.val_despesas = 0
       LET lr_total_dia.val_cobranca = 0
       LET lr_total_dia.val_diferenca = 0
       
       PRINT COLUMN 001,"Data de Encerramento: ",lr_relat.dat_fechamento
       
    ON EVERY ROW
       LET lr_relat.val_diferenca = lr_relat.val_diferenca * (-1)
       
       LET lr_total_dia.val_vista = lr_total_dia.val_vista  + lr_relat.val_vista 
       LET lr_total_dia.val_prazo = lr_total_dia.val_prazo + lr_relat.val_prazo
       LET lr_total_dia.tot_vendas = lr_total_dia.tot_vendas + lr_relat.tot_vendas
       LET lr_total_dia.val_cheques = lr_total_dia.val_cheques + lr_relat.val_cheques
       LET lr_total_dia.val_dinheiro = lr_total_dia.val_dinheiro + lr_relat.val_dinheiro
       LET lr_total_dia.val_despesas = lr_total_dia.val_despesas + lr_relat.val_despesas
       LET lr_total_dia.val_cobranca = lr_total_dia.val_cobranca + lr_relat.val_cobranca
       LET lr_total_dia.val_diferenca = lr_total_dia.val_diferenca + lr_relat.val_diferenca
       
       LET mr_total_geral.val_vista = mr_total_geral.val_vista  + lr_relat.val_vista 
       LET mr_total_geral.val_prazo = mr_total_geral.val_prazo + lr_relat.val_prazo
       LET mr_total_geral.tot_vendas = mr_total_geral.tot_vendas + lr_relat.tot_vendas
       LET mr_total_geral.val_cheques = mr_total_geral.val_cheques + lr_relat.val_cheques
       LET mr_total_geral.val_dinheiro = mr_total_geral.val_dinheiro + lr_relat.val_dinheiro
       LET mr_total_geral.val_despesas = mr_total_geral.val_despesas + lr_relat.val_despesas
       LET mr_total_geral.val_cobranca = mr_total_geral.val_cobranca + lr_relat.val_cobranca
       LET mr_total_geral.val_diferenca = mr_total_geral.val_diferenca + lr_relat.val_diferenca
       
       SELECT cod_repres
         INTO l_cod_repres
         FROM geo_repres_paramet
        WHERE cod_cliente = lr_relat.cod_resp
       IF sqlca.sqlcode <> 0 THEN
          #CALL _ADVPL_message_box("Parametros do representante não encontrados na tabela geo_repres_paramet")
       END IF
       
       PRINT COLUMN 001,l_cod_repres USING "----"," - ",lr_relat.den_resp[1,28] CLIPPED,
             COLUMN 037, lr_relat.cod_manifesto using "-----",
             COLUMN 045, lr_relat.val_vista USING "#####&.&&",
             COLUMN 054, lr_relat.val_prazo USING "#######&.&&",
             COLUMN 065, lr_relat.tot_vendas USING "#######&.&&",
             COLUMN 079, lr_relat.val_cheques USING "#####&.&&",
             COLUMN 090, lr_relat.val_dinheiro USING "#####&.&&",
             COLUMN 101, lr_relat.val_despesas USING "#####&.&&",
             COLUMN 113, lr_relat.val_cobranca USING "#####&.&&",
             COLUMN 123, lr_relat.val_diferenca  USING "-----&.&&" 
        

    AFTER GROUP OF lr_relat.dat_fechamento
       CALL ReportThinLine("geo1023")
       PRINT COLUMN 030,"Total do Dia: ",
             COLUMN 045, lr_total_dia.val_vista USING "#####&.&&",
             COLUMN 054, lr_total_dia.val_prazo USING "#######&.&&",
             COLUMN 065, lr_total_dia.tot_vendas USING "#######&.&&",
             COLUMN 079, lr_total_dia.val_cheques USING "#####&.&&",
             COLUMN 090, lr_total_dia.val_dinheiro USING "#####&.&&",
             COLUMN 101, lr_total_dia.val_despesas USING "#####&.&&",
             COLUMN 113, lr_total_dia.val_cobranca USING "#####&.&&",
             COLUMN 123, lr_total_dia.val_diferenca  USING "-----&.&&"
       SKIP 01 LINE
         CALL ReportThinLine("geo1023")
         #SKIP 01 LINE
         
         
    ON LAST ROW
       SKIP 03 LINE
       LET l_last_row = TRUE
       CALL ReportThinLine("geo1023")
       {PRINT COLUMN 031,"Total Geral: ",
             COLUMN 044, mr_total_geral.val_vista USING "######&.&&",
             COLUMN 055, mr_total_geral.val_prazo USING "######&.&&",
             COLUMN 066, mr_total_geral.tot_vendas USING "######&.&&",
             COLUMN 079, mr_total_geral.val_cheques USING "#####&.&&",
             COLUMN 090, mr_total_geral.val_dinheiro USING "#####&.&&",
             COLUMN 101, mr_total_geral.val_despesas USING "#####&.&&",
             COLUMN 113, mr_total_geral.val_cobranca USING "#####&.&&",
             COLUMN 123, mr_total_geral.val_diferenca  USING "-----&.&&"}
       PRINT COLUMN 044,"                   Total Geral "
       PRINT COLUMN 044,"------------------------------------------------"
       PRINT COLUMN 044, "      Total vendas à vista: ",mr_total_geral.val_vista USING "#########&.&&"
       PRINT COLUMN 044, "      Total vendas à prazo: ",mr_total_geral.val_prazo USING "#########&.&&"
       PRINT COLUMN 044, "           Total de vendas: ",mr_total_geral.tot_vendas USING "#########&.&&"
       PRINT COLUMN 044, "   Total crédito em cheque: ",mr_total_geral.val_cheques USING "#########&.&&"
       PRINT COLUMN 044, " Total crédito em dinheiro: ",mr_total_geral.val_dinheiro USING "#########&.&&"
       PRINT COLUMN 044, "            Total despesas: ",mr_total_geral.val_despesas USING "#########&.&&"
       PRINT COLUMN 044, "Total débitos de Cobranças: ",mr_total_geral.val_cobranca USING "#########&.&&"
       PRINT COLUMN 044, "          Total diferenças: ",mr_total_geral.val_diferenca  USING "---------&.&&"
       
    PAGE TRAILER
       
               
       IF l_last_row = TRUE THEN
         #PRINT "* * *  ULTIMA FOLHA  * * *", log5211_termino_impressao() CLIPPED
         PRINT " "
       ELSE
         PRINT " "
       END IF

END REPORT



#-------------------------------------------#
function geo1023_tela_funil_tela()
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
	CALL _ADVPL_set_property(l_botao_find,"EVENT","geo1023_entrada_dados_funil")
	CALL _ADVPL_set_property(l_botao_find,"CONFIRM_EVENT","geo1023_confirmar_funil")
	CALL _ADVPL_set_property(l_botao_find,"CANCEL_EVENT","geo1023_cancela_funil")
 
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
	CALL _ADVPL_set_property(m_refer_tabela_funil,"SIZE",350,190)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"CAN_ADD_ROW",TRUE)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"CAN_REMOVE_ROW",TRUE)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"ALIGN","CENTER")
	CALL _ADVPL_set_property(m_refer_tabela_funil,"EDITABLE",TRUE)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"ENABLE",TRUE)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"POSITION",80,570)
	 
     
      		#cria campo do array: cod_repres
			LET l_refer_cliente = _ADVPL_create_component(NULL,"LTABLECOLUMNEX", m_refer_tabela_funil)
			CALL _ADVPL_set_property(l_refer_cliente,"VARIABLE","codigo")
			CALL _ADVPL_set_property(l_refer_cliente,"HEADER","Cod.")
			CALL _ADVPL_set_property(l_refer_cliente,"COLUMN_SIZE", 10)
			CALL _ADVPL_set_property(l_refer_cliente,"ORDER",TRUE)
			CALL _ADVPL_set_property(l_refer_cliente,"EDIT_COMPONENT","LNUMERICFIELD")
			CALL _ADVPL_set_property(l_refer_cliente,"EDIT_PROPERTY","LENGTH",10,0) 
			CALL _ADVPL_set_property(l_refer_cliente,"EDITABLE", TRUE)
	 
			
			let l_ind = 0 
			for l_ind = 1 to 999
			   if ma_funil[l_ind].codigo is null or   ma_funil[l_ind].codigo = ' ' or   ma_funil[l_ind].codigo = 0 then
			      exit for
			   end if
			end for
			let l_ind = l_ind - 1
			 
			CALL _ADVPL_set_property(m_refer_tabela_funil,"SET_ROWS",ma_funil,0)
     
	CALL _ADVPL_set_property(m_refer_tabela_funil,"ITEM_COUNT",l_ind)
	CALL _ADVPL_set_property(m_refer_tabela_funil,"REFRESH")

   
      
	CALL _ADVPL_get_property(l_botao_find,"DO_CLICK")
	CALL _ADVPL_set_property(m_form_funil,"ACTIVATE",TRUE)

END FUNCTION

#--------------------------------------------------------------------#
function geo1023_entrada_dados_funil()
#--------------------------------------------------------------------#
   
    
end function
 
#--------------------------------------------------------------------#
function geo1023_confirmar_funil()
#--------------------------------------------------------------------#
	 CALL _ADVPL_set_property(m_form_funil,"ACTIVATE",FALSE)
end function

#--------------------------------------------------------------------#
function geo1023_cancela_funil()
#--------------------------------------------------------------------#
	 CALL _ADVPL_set_property(m_form_funil,"ACTIVATE",FALSE)
end function


