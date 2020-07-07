#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1312                                                 #
# OBJETIVO: GERAÇÃO DE DADOS DE CRÉDITO NO LAY-OUT CREDINFAR        #
# AUTOR...: IVO                                                     #
# DATA....: 24/10/16                                                #
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
       m_associada       VARCHAR(10),
       m_cliente         VARCHAR(10),
       m_lupa_cliente    VARCHAR(10),
       m_zoom_cliente    VARCHAR(10),
       m_data_cm         VARCHAR(10),
       m_data_fc         VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_caminho         CHAR(100),
       m_comando         CHAR(200),
       m_ies_ambiente    CHAR(001),
       m_relat           CHAR(120),
       m_mes_ano         CHAR(06),
       m_mes             INTEGER,
       m_ano             INTEGER,
       m_1_10_dias       INTEGER,
       m_11_30_dias      INTEGER,
       m_31_90_dias      INTEGER,
       m_91_180_dias     INTEGER,
       m_181_360_dias    INTEGER,
       m_mais_360_dias   INTEGER,
       m_mais_30_dias    INTEGER,
       m_erro            SMALLINT,
       m_deb_atual       INTEGER,
       m_dat_base        DATE


DEFINE mr_parametro      RECORD
       cod_associada     DECIMAL(3,0),
       cod_cliente       CHAR(15),
       nom_cliente       CHAR(40),
       data_cm           CHAR(07),
       dat_fec_cre       DATE
END RECORD

DEFINE mr_dados                RECORD    
       cod_associada           CHAR(03), 
       seguimento              CHAR(02), 
       tip_cliente             CHAR(01), 
       num_cliente             CHAR(08), 
       compl_cliente           CHAR(04), 
       dig_cliente             CHAR(02), 
       nom_cliente             CHAR(40), 
       endereco                CHAR(30), 
       cidade                  CHAR(20), 
       cep                     CHAR(08), 
       uf                      CHAR(02), 
       mes_ano_cad             CHAR(06), 
       data_uc                 CHAR(06), 
       valor_uc                CHAR(09), 
       data_nf                 CHAR(06), 
       valor_nf                CHAR(09), 
       data_ma                 CHAR(06), 
       valor_ma                CHAR(09),        
       limite_credito          CHAR(09), 
       dias_atraso             CHAR(03), 
       debito_atual            CHAR(09), 
       debito_vencidos         CHAR(09), 
       data_cm                 CHAR(06), 
       valor_cm                CHAR(09), 
       vencidos_01_10_dias     CHAR(09),
       vencidos_11_30_dias     CHAR(09),
       vencidos_31_90_dias     CHAR(09),
       vencidos_91_180_dias    CHAR(09),
       vencidos_181_360_dias   CHAR(09),
       vencidos_mais_360_dias  CHAR(09)
END RECORD       

DEFINE mr_clientes       RECORD LIKE clientes.*,
       mr_credito        RECORD LIKE credcad_cli.*
                    
#-----------------#
FUNCTION pol1312()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1312-12.00.20  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1312_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1312_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_print       VARCHAR(10)
    
    INITIALIZE mr_parametro.* TO NULL
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE","GERAÇÃO DE DADOS DE CRÉDITO")

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1312_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1312_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1312_cancelar")

    LET l_print = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_print,"EVENT","pol1312_processar")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1312_cria_campos(l_panel)

    CALL pol1312_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1312_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_nom_cliente     VARCHAR(10),
           l_panel_campos    VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",5)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cód do cliente:")    

    LET m_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cliente,"VARIABLE",mr_parametro,"cod_cliente")
    CALL _ADVPL_set_property(m_cliente,"LENGTH",15)
    CALL _ADVPL_set_property(m_cliente,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cliente,"VALID","pol1312_checa_cliente")

    LET m_lupa_cliente = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_cliente,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cliente,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cliente,"CLICK_EVENT","pol1312_zoom_cliente")

    LET l_nom_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_nom_cliente,"LENGTH",40) 
    CALL _ADVPL_set_property(l_nom_cliente,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_nom_cliente,"VARIABLE",mr_parametro,"nom_cliente")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Cód da associada:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_associada = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_associada,"VARIABLE",mr_parametro,"cod_associada")
    CALL _ADVPL_set_property(m_associada,"LENGTH",3)
    CALL _ADVPL_set_property(m_associada,"PICTURE","@E ###")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Dat Compra Mês:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_data_cm = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_data_cm,"VARIABLE",mr_parametro,"data_cm")
    CALL _ADVPL_set_property(m_data_cm,"LENGTH",7)
    CALL _ADVPL_set_property(m_data_cm,"PICTURE","##/####")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Dat fec cred:")
    
    LET m_data_fc = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_data_fc,"VARIABLE",mr_parametro,"dat_fec_cre")

END FUNCTION

#----------------------------------------#
FUNCTION pol1312_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
    
   CALL _ADVPL_set_property(m_cliente,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_cliente,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_associada,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_data_cm,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_data_fc,"EDITABLE",FALSE)

END FUNCTION

#--------------------------#
FUNCTION pol1312_informar()#
#--------------------------#
   
   DEFINE l_mes        DECIMAL(2,0),
          l_ano        DECIMAL(4,0),
          l_data       CHAR(10),
          l_dia        CHAR(02),
          l_dat_fec    CHAR(10),
          l_resto      DECIMAL(10,2)
   
   CALL pol1312_ativa_desativa(TRUE)
   CALL pol1312_limpa_campos()
   
   LET l_mes = MONTH(TODAY)
   LET l_ano = YEAR(TODAY)
   
   IF l_mes > 1 THEN
      LET l_mes = l_mes - 1
   ELSE
      LET l_mes = 12
      LET l_ano = l_ano - 1
   END IF
         
   LET mr_parametro.data_cm = func002_strzero(l_mes,2),'/',func002_strzero(l_ano,4)
   
   IF l_mes = 4 OR l_mes = 6 OR l_mes = 9 OR l_mes = 11 THEN
      LET l_dia = '30'
   ELSE
      IF l_mes = 2 THEN
         LET l_resto = l_ano MOD 4
         IF l_resto = 0 THEN 
            LET l_dia = '29'
         ELSE
            LET l_dia = '28'
         END IF
      ELSE
         LET l_dia = '31'
      END IF      
   END IF
   
   LET l_data = l_dia,'/',mr_parametro.data_cm 
   LET m_dat_base = l_data
   
   LET m_ies_info = FALSE
   
   SELECT dat_proces_doc
     INTO mr_parametro.dat_fec_cre
     FROM par_cre
   
   LET l_data = EXTEND(m_dat_base, YEAR TO DAY)
   LET l_dat_fec = EXTEND(mr_parametro.dat_fec_cre, YEAR TO DAY)
   
   #IF l_dat_fec <> l_data THEN
   #   LET m_msg = 'A data do fechamento do\n crédito está divergente.'
   #   CALL log0030_mensagem(m_msg,'info')
   #   CALL pol1312_ativa_desativa(FALSE)
   #   RETURN FALSE
   #END IF
      
   RETURN TRUE 
    
END FUNCTION

#-----------------------------#
FUNCTION pol1312_limpa_campos()
#-----------------------------#

   INITIALIZE mr_parametro.* TO NULL
    
END FUNCTION

#---------------------------#
FUNCTION pol1312_confirmar()#
#---------------------------#
      
   IF mr_parametro.cod_associada IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe a Associada")
      CALL _ADVPL_set_property(m_associada,"GET_FOCUS")
      RETURN FALSE      
   END IF

   LET m_msg = ''
   
   LET m_mes = mr_parametro.data_cm[1,2]   
   
   IF STATUS <> 0 THEN 
      LET m_msg = 'Mês inválido.; '
   ELSE
      IF m_mes < 1 OR m_mes > 12 OR m_mes IS NULL THEN
         LET m_msg = 'Mês inválido; '
      END IF
   END IF
    
   LET m_ano = mr_parametro.data_cm[4,7]
   
   IF STATUS <> 0 THEN 
      LET m_msg = m_msg CLIPPED, ' Ano inválido.; '
   ELSE
      IF m_ano <= 1900 OR m_ano IS NULL THEN
         LET m_msg = m_msg CLIPPED, ' Ano inválido.; '
      END IF
   END IF

   IF m_msg IS NOT NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_data_cm,"GET_FOCUS")
      RETURN FALSE      
   END IF
   
   LET m_mes_ano = func002_strzero(m_mes, 2), m_ano   
   LET mr_parametro.data_cm = m_mes_ano[1,2],'/',m_mes_ano[3,6]
   
   LET m_ies_info = TRUE
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1312_cancelar()#
#--------------------------#

    CALL pol1312_limpa_campos()
    CALL pol1312_ativa_desativa(FALSE)
    RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1312_checa_cliente()#
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
FUNCTION pol1312_zoom_cliente()#
#------------------------------#

    DEFINE l_cod_cliente       LIKE clientes.cod_cliente,
           l_nom_cliente       LIKE clientes.nom_cliente
    
    IF  m_zoom_cliente IS NULL THEN
        LET m_zoom_cliente = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_cliente,"ZOOM","zoom_clientes")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_cliente,"ACTIVATE")
    
    LET l_cod_cliente = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_nom_cliente = _ADVPL_get_property(m_zoom_cliente,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")

    IF  l_cod_cliente IS NOT NULL THEN
        LET mr_parametro.cod_cliente = l_cod_cliente
        LET mr_parametro.nom_cliente = l_nom_cliente
    END IF

END FUNCTION

#---------------------------#
FUNCTION pol1312_processar()#
#---------------------------#

   IF NOT m_ies_info THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe os parâmetros previamente")
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a geração dos dados de crédito") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   CALL LOG_progresspopup_start("Procesando...","pol1312_executa","PROCESS")
  
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
FUNCTION pol1312_executa()#
#-------------------------#
   
   SELECT nom_caminho,
          ies_ambiente           
     INTO m_caminho, 
          m_ies_ambiente
     FROM path_logix_v2
    WHERE cod_empresa = p_cod_empresa 
      AND (cod_sistema = 'txt' OR cod_sistema = 'TXT')
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','path_logix_v2')
      RETURN FALSE
   END IF

   LET p_status = pol1312_gera_dados()
   
   RETURN p_status

END FUNCTION

#----------------------------#
FUNCTION pol1312_gera_dados()#
#----------------------------#
   
   DEFINE l_dat_cadatro   CHAR(10),
          l_tot_deb       INTEGER,
          l_tem_dados     SMALLINT,
          l_progres       SMALLINT
      
   LET l_tem_dados = FALSE
   
   SELECT COUNT(*) INTO m_count FROM clientes
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   IF mr_parametro.cod_cliente IS NULL THEN
      DECLARE cq_clientes CURSOR FOR
       SELECT * FROM clientes
   ELSE
      DECLARE cq_clientes CURSOR FOR
       SELECT * FROM clientes
        WHERE cod_cliente = mr_parametro.cod_cliente
   END IF
   
   FOREACH cq_clientes INTO mr_clientes.*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_clientes')
         EXIT FOREACH
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET m_erro = FALSE
      
      IF NOT l_tem_dados THEN
         LET l_tem_dados = TRUE
         CALL pol1312_start_arquivo()
      END IF
            
      LET mr_clientes.num_cgc_cpf = func002_retira_especiais(mr_clientes.num_cgc_cpf)
      
      IF mr_clientes.num_cgc_cpf = '98927850700' THEN
         LET mr_clientes.num_cgc_cpf = '989278507000000'
      END IF
      
      IF mr_clientes.num_cgc_cpf = '' OR mr_clientes.num_cgc_cpf IS NULL THEN
         LET mr_clientes.num_cgc_cpf = '000000000000000'
      END IF
      
      IF mr_clientes.cod_tip_cli IS NULL OR
         mr_clientes.cod_tip_cli = ' ' THEN
         CONTINUE FOREACH
      END IF      

      MESSAGE 'Exportando Cliente: ', mr_clientes.cod_cliente
      #lds CALL LOG_refresh_display()
      
      LET mr_dados.cod_associada = func002_strzero(mr_parametro.cod_associada, 3)
      LET mr_dados.seguimento = '00'      
      LET mr_dados.compl_cliente = mr_clientes.num_cgc_cpf[10,13]
            
      IF mr_dados.compl_cliente = '0000' THEN
         LET mr_dados.tip_cliente = mr_clientes.num_cgc_cpf[1]
      ELSE
         LET mr_dados.tip_cliente = 'G'
      END IF
      
      LET mr_dados.num_cliente = mr_clientes.num_cgc_cpf[02,09]
      LET mr_dados.dig_cliente = mr_clientes.num_cgc_cpf[14,15]
      
      LET mr_dados.nom_cliente = mr_clientes.nom_cliente
      LET mr_dados.endereco = mr_clientes.end_cliente            

      IF NOT pol1312_le_cidade() THEN
         EXIT FOREACH
      END IF
      
      LET mr_dados.cep = mr_clientes.cod_cep
      
      IF mr_clientes.dat_cadastro IS NULL THEN
         LET mr_dados.mes_ano_cad = func002_strzero(0,6)
      ELSE
         LET l_dat_cadatro = mr_clientes.dat_cadastro
         LET l_dat_cadatro = l_dat_cadatro[4,5],l_dat_cadatro[7,10]   
         LET mr_dados.mes_ano_cad = l_dat_cadatro CLIPPED   
      END IF            
      
      LET mr_dados.mes_ano_cad = pol1312_data(mr_clientes.dat_cadastro)
            
      INITIALIZE mr_credito.* TO NULL
      
      SELECT *
        INTO mr_credito.*
        FROM credcad_cli
       WHERE cod_cliente = mr_clientes.cod_cliente

      IF STATUS = 100 THEN
         LET mr_credito.val_ult_fat = 0
         LET mr_credito.val_maior_fat = 0
         LET mr_credito.val_maior_acumulo = 0
         LET mr_credito.val_credito_conced = 0
         LET mr_credito.qtd_dias_atras_med = 0
         LET mr_credito.val_debito_a_venc = 0
         LET mr_credito.val_debito_vencido = 0
         LET mr_credito.val_faturado_mes = 0
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','credcad_cli')
            EXIT FOREACH
         END IF
      END IF
      
      
      #LET mr_dados.data_uc  = pol1312_data(mr_credito.dat_ult_fat)
      #LET mr_dados.valor_uc = func002_strzero(mr_credito.val_ult_fat,9) 
      LET mr_dados.data_nf  = pol1312_data(mr_credito.dat_maior_fat)
      LET mr_dados.valor_nf = func002_strzero(mr_credito.val_maior_fat,9) 
      LET mr_dados.data_ma  = pol1312_data(mr_credito.dat_maior_acumulo)
      LET mr_dados.valor_ma = func002_strzero(mr_credito.val_maior_acumulo,9)
      LET mr_dados.limite_credito = func002_strzero(mr_credito.val_credito_conced,9)
      LET mr_dados.dias_atraso = func002_strzero(mr_credito.qtd_dias_atras_med,3)      
      LET mr_dados.data_cm  = m_mes_ano            
      #LET mr_dados.valor_cm = func002_strzero(mr_credito.val_faturado_mes,9)           
            
                  
      IF NOT pol1312_le_nfs() THEN
         EXIT FOREACH
      END IF

      IF m_erro  THEN
         CONTINUE FOREACH
      END IF

      IF NOT pol1312_le_titulos() THEN
         EXIT FOREACH
      END IF

      IF m_erro  THEN
         CONTINUE FOREACH
      END IF

      LET mr_dados.vencidos_01_10_dias = func002_strzero(m_1_10_dias,9)
      LET mr_dados.vencidos_11_30_dias = func002_strzero(m_11_30_dias,9)
      
      LET mr_dados.vencidos_31_90_dias = func002_strzero(m_31_90_dias,9)
      LET mr_dados.vencidos_91_180_dias = func002_strzero(m_91_180_dias,9)
      LET mr_dados.vencidos_181_360_dias = func002_strzero(m_181_360_dias,9)
      
      LET mr_dados.vencidos_mais_360_dias = func002_strzero(m_mais_360_dias,9)
            
      LET l_tot_deb = 
          m_1_10_dias + m_11_30_dias + m_31_90_dias + m_91_180_dias + m_181_360_dias + m_mais_360_dias 
      
      LET mr_dados.debito_vencidos = func002_strzero(l_tot_deb,9)
      LET mr_dados.debito_atual = func002_strzero(m_deb_atual,9)      
      
      OUTPUT TO REPORT pol1312_relat() 
   
   END FOREACH

   IF NOT l_tem_dados THEN
      RETURN FALSE
   END IF

   CALL pol1312_finish_arquivo()

   RETURN TRUE
         
END FUNCTION      

#---------------------------#
FUNCTION pol1312_le_cidade()#
#---------------------------#

   SELECT den_cidade, cod_uni_feder
     INTO mr_dados.cidade, mr_dados.uf
     FROM cidades
    WHERE cod_cidade = mr_clientes.cod_cidade

   IF STATUS = 100 THEN
      INITIALIZE mr_dados.cidade, mr_dados.uf TO NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cidade')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1312_data(l_data)#
#----------------------------#
   
   DEFINE l_data       CHAR(19)
   
   IF l_data IS NULL THEN
      LET l_data = func002_strzero(0,6)
   ELSE
      LET l_data = l_data[4,5],l_data[7,10]   
   END IF            

   RETURN l_data CLIPPED

END FUNCTION

#------------------------#
FUNCTION pol1312_le_nfs()#
#------------------------#
   
   DEFINE l_valor        INTEGER,
          l_trans        INTEGER,
          l_dat          CHAR(19)
   
   LET mr_dados.valor_nf = NULL
   
   DECLARE cq_maior_nf CURSOR FOR
    SELECT dat_hor_emissao, 
           val_nota_fiscal   
      FROM fat_nf_mestre 
     WHERE empresa = p_cod_empresa 
       AND cliente = mr_clientes.cod_cliente
       AND sit_nota_fiscal = 'N'
     ORDER BY val_nota_fiscal DESC

   FOREACH cq_maior_nf INTO l_dat, l_valor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_maior_nf')
         RETURN FALSE
      END IF
      LET mr_dados.valor_nf = func002_strzero(l_valor,9)
      LET mr_dados.data_nf = l_dat[6,7],l_dat[1,4]
      EXIT FOREACH
   END FOREACH
   
   IF mr_dados.valor_nf IS NULL THEN
      LET m_erro = TRUE
   END IF
   
   LET mr_dados.valor_uc = NULL
   
   DECLARE cq_nf CURSOR FOR
   SELECT dat_hor_emissao, val_nota_fiscal, trans_nota_fiscal
    FROM fat_nf_mestre
   WHERE empresa = p_cod_empresa
     AND cliente = mr_clientes.cod_cliente
     AND sit_nota_fiscal = 'N'
     ORDER BY trans_nota_fiscal DESC     

   FOREACH cq_nf INTO l_dat, l_valor,  l_trans
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','fat_nf_mestre')
         RETURN FALSE
      END IF
      LET mr_dados.valor_uc = func002_strzero(l_valor,9)
      LET mr_dados.data_uc = l_dat[6,7],l_dat[1,4]
      EXIT FOREACH
   END FOREACH
       
   IF mr_dados.valor_uc IS NULL THEN
      LET m_erro = TRUE
   END IF

   SELECT SUM(val_nota_fiscal)
    INTO l_valor
    FROM fat_nf_mestre 
   WHERE empresa = p_cod_empresa 
     AND cliente = mr_clientes.cod_cliente
     AND sit_nota_fiscal = 'N'
     AND MONTH(dat_hor_emissao) = m_mes
     AND YEAR(dat_hor_emissao) = m_ano
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','fat_nf_mestre')
      RETURN FALSE
   END IF
      
   IF l_valor IS NULL THEN
      LET l_valor = 0
   END IF

   IF l_valor = 0 THEN
      #LET m_erro = TRUE
   END IF
   
   LET mr_dados.valor_cm = func002_strzero(l_valor,9)

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1312_le_titulos()#
#----------------------------#
   
   DEFINE l_dat_ini       DATE,
          l_dat_fim       DATE,
          l_val_1         INTEGER,
          l_val_2         INTEGER
   
   LET m_dat_base = TODAY
   
   LET l_dat_ini = m_dat_base - 1  
   LET l_dat_fim = m_dat_base - 10 

   SELECT SUM(val_saldo)
     INTO l_val_1
     FROM docum
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_clientes.cod_cliente
      AND ies_situa_docum = 'N'
      AND val_saldo > 0
      AND dat_vencto_s_desc <= l_dat_ini
      AND dat_vencto_s_desc >= l_dat_fim
      AND dat_prorrogada IS NULL
      AND ies_tip_docum = 'DP'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','docum:1_10')
      RETURN FALSE
   END IF
   
   IF l_val_1 IS NULL THEN
      LET l_val_1 = 0
   END IF

  SELECT SUM(val_saldo)
     INTO l_val_2
     FROM docum
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_clientes.cod_cliente
      AND ies_situa_docum = 'N'
      AND val_saldo > 0
      AND dat_prorrogada IS NOT NULL
      AND dat_prorrogada <= l_dat_ini
      AND dat_prorrogada >= l_dat_ini
      AND ies_tip_docum = 'DP'
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','docum:1_10')
      RETURN FALSE
   END IF
   
   IF l_val_2 IS NULL THEN
      LET l_val_2 = 0
   END IF

   LET m_1_10_dias = l_val_1 + l_val_2
   
   LET l_dat_ini = m_dat_base - 11 
   LET l_dat_fim = m_dat_base - 30 
   
   SELECT SUM(val_saldo)
     INTO l_val_1
     FROM docum
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_clientes.cod_cliente
      AND ies_situa_docum = 'N'
      AND val_saldo > 0
      AND dat_vencto_s_desc <= l_dat_ini
      AND dat_vencto_s_desc >= l_dat_fim
      AND dat_prorrogada IS NULL
      AND ies_tip_docum = 'DP'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','docum:11_30')
      RETURN FALSE
   END IF
   
   IF l_val_1 IS NULL THEN
      LET l_val_1 = 0
   END IF

  SELECT SUM(val_saldo)
     INTO l_val_2
     FROM docum
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_clientes.cod_cliente
      AND ies_situa_docum = 'N'
      AND val_saldo > 0
      AND dat_prorrogada IS NOT NULL
      AND dat_prorrogada <= l_dat_ini
      AND dat_prorrogada >= l_dat_ini
      AND ies_tip_docum = 'DP'
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','docum:11_30')
      RETURN FALSE
   END IF
   
   IF l_val_2 IS NULL THEN
      LET l_val_2 = 0
   END IF
   
   LET m_11_30_dias = l_val_1 + l_val_2

   #-- 31 a 90 dias ----#

   LET l_dat_ini = m_dat_base - 31 
   LET l_dat_fim = m_dat_base - 90 
   
   SELECT SUM(val_saldo)
     INTO l_val_1
     FROM docum
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_clientes.cod_cliente
      AND ies_situa_docum = 'N'
      AND val_saldo > 0
      AND dat_vencto_s_desc <= l_dat_ini
      AND dat_vencto_s_desc >= l_dat_fim
      AND dat_prorrogada IS NULL
      AND ies_tip_docum = 'DP'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','docum:11_30')
      RETURN FALSE
   END IF
   
   IF l_val_1 IS NULL THEN
      LET l_val_1 = 0
   END IF

  SELECT SUM(val_saldo)
     INTO l_val_2
     FROM docum
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_clientes.cod_cliente
      AND ies_situa_docum = 'N'
      AND val_saldo > 0
      AND dat_prorrogada IS NOT NULL
      AND dat_prorrogada <= l_dat_ini
      AND dat_prorrogada >= l_dat_ini
      AND ies_tip_docum = 'DP'
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','docum:11_30')
      RETURN FALSE
   END IF
   
   IF l_val_2 IS NULL THEN
      LET l_val_2 = 0
   END IF
   
   LET m_31_90_dias = l_val_1 + l_val_2
   
   #---91 a 180 dias ---#
   
      LET l_dat_ini = m_dat_base - 91 
   LET l_dat_fim = m_dat_base - 180 
   
   SELECT SUM(val_saldo)
     INTO l_val_1
     FROM docum
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_clientes.cod_cliente
      AND ies_situa_docum = 'N'
      AND val_saldo > 0
      AND dat_vencto_s_desc <= l_dat_ini
      AND dat_vencto_s_desc >= l_dat_fim
      AND dat_prorrogada IS NULL
      AND ies_tip_docum = 'DP'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','docum:11_30')
      RETURN FALSE
   END IF
   
   IF l_val_1 IS NULL THEN
      LET l_val_1 = 0
   END IF

  SELECT SUM(val_saldo)
     INTO l_val_2
     FROM docum
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_clientes.cod_cliente
      AND ies_situa_docum = 'N'
      AND val_saldo > 0
      AND dat_prorrogada IS NOT NULL
      AND dat_prorrogada <= l_dat_ini
      AND dat_prorrogada >= l_dat_ini
      AND ies_tip_docum = 'DP'
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','docum:11_30')
      RETURN FALSE
   END IF
   
   IF l_val_2 IS NULL THEN
      LET l_val_2 = 0
   END IF
   
   LET m_91_180_dias = l_val_1 + l_val_2

   #---181 a 360 dias ---#

   LET l_dat_ini = m_dat_base - 181 
   LET l_dat_fim = m_dat_base - 360 
   
   SELECT SUM(val_saldo)
     INTO l_val_1
     FROM docum
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_clientes.cod_cliente
      AND ies_situa_docum = 'N'
      AND val_saldo > 0
      AND dat_vencto_s_desc <= l_dat_ini
      AND dat_vencto_s_desc >= l_dat_fim
      AND dat_prorrogada IS NULL
      AND ies_tip_docum = 'DP'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','docum:11_30')
      RETURN FALSE
   END IF
   
   IF l_val_1 IS NULL THEN
      LET l_val_1 = 0
   END IF

  SELECT SUM(val_saldo)
     INTO l_val_2
     FROM docum
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_clientes.cod_cliente
      AND ies_situa_docum = 'N'
      AND val_saldo > 0
      AND dat_prorrogada IS NOT NULL
      AND dat_prorrogada <= l_dat_ini
      AND dat_prorrogada >= l_dat_ini
      AND ies_tip_docum = 'DP'
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','docum:11_30')
      RETURN FALSE
   END IF
   
   IF l_val_2 IS NULL THEN
      LET l_val_2 = 0
   END IF
   
   LET m_181_360_dias = l_val_1 + l_val_2

   #---mais de 360 dias ---#
      
   LET l_dat_ini = m_dat_base - 361
   
   SELECT SUM(val_saldo)
     INTO l_val_1
     FROM docum
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_clientes.cod_cliente
      AND ies_situa_docum = 'N'
      AND val_saldo > 0
      AND dat_vencto_s_desc <= l_dat_ini
      AND dat_prorrogada IS NULL
      AND ies_tip_docum = 'DP'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','docum:mais_de_30')
      RETURN FALSE
   END IF
   
   IF l_val_1 IS NULL THEN
      LET l_val_1 = 0
   END IF

  SELECT SUM(val_saldo)
     INTO l_val_2
     FROM docum
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_clientes.cod_cliente
      AND ies_situa_docum = 'N'
      AND val_saldo > 0
      AND dat_prorrogada IS NOT NULL
      AND dat_prorrogada <= l_dat_ini
      AND ies_tip_docum = 'DP'
        
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','docum:mais_de_30')
      RETURN FALSE
   END IF
   
   IF l_val_2 IS NULL THEN
      LET l_val_2 = 0
   END IF

   LET m_mais_360_dias = l_val_1 + l_val_2

   SELECT SUM(val_saldo)
     INTO m_deb_atual
     FROM docum 
    WHERE cod_empresa = p_cod_empresa 
      AND cod_cliente = mr_clientes.cod_cliente
      AND ies_situa_docum = 'N'
      AND val_saldo > 0
      AND ies_tip_docum = 'DP'
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','docum:debito_atual')
      RETURN FALSE
   END IF

   #LET m_deb_atual = m_mais_30_dias + m_11_30_dias + m_1_10_dias
   
   IF m_deb_atual IS NULL THEN
      LET m_deb_atual = 0
   END IF

   IF m_deb_atual <= 0 THEN
      LET m_erro = TRUE
   END IF
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1312_start_arquivo()#
#-------------------------------#

   LET m_relat = m_caminho CLIPPED, 'NFASSOC.SIC'
   START REPORT pol1312_relat TO m_relat 

END FUNCTION


#--------------------------------#
FUNCTION pol1312_finish_arquivo()#
#--------------------------------#

   FINISH REPORT pol1312_relat
   
   LET m_msg = 'Arquivo salvo em: \n\n', m_relat
   CALL log0030_mensagem(m_msg, 'info')

END FUNCTION

#---------------------#
REPORT pol1312_relat()#
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1
          
   FORMAT

     ON EVERY ROW

      PRINT mr_dados.cod_associada,         
            mr_dados.seguimento,            
            mr_dados.tip_cliente,           
            mr_dados.num_cliente,           
            mr_dados.compl_cliente,         
            mr_dados.dig_cliente,           
            mr_dados.nom_cliente,           
            mr_dados.endereco,              
            mr_dados.cidade,                
            mr_dados.cep,                   
            mr_dados.uf,                    
            mr_dados.mes_ano_cad,           
            mr_dados.data_uc,               
            mr_dados.valor_uc,              
            mr_dados.data_nf,               
            mr_dados.valor_nf,              
            mr_dados.data_ma,               
            mr_dados.valor_ma,              
            mr_dados.limite_credito,        
            mr_dados.dias_atraso,           
            mr_dados.debito_atual,          
            mr_dados.debito_vencidos,       
            mr_dados.data_cm,               
            mr_dados.valor_cm,              
            mr_dados.vencidos_01_10_dias,   
            mr_dados.vencidos_11_30_dias,   
            mr_dados.vencidos_31_90_dias,   
            mr_dados.vencidos_91_180_dias,   
            mr_dados.vencidos_181_360_dias,   
            mr_dados.vencidos_mais_360_dias         
END REPORT

