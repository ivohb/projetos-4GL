#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1382                                                 #
# OBJETIVO: Acerto do peso do ite a partir da ficha t�cnica         #
# AUTOR...: IVO                                                     #
# DATA....: 23/05/17                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003)
           
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_item            VARCHAR(10),
       m_lupa_it         VARCHAR(10),
       m_zoom_it         VARCHAR(10),
       m_familia         VARCHAR(10),
       m_lupa_fam        VARCHAR(10),
       m_zoom_fam        VARCHAR(10),
       m_dat_corte       VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_cod_item        CHAR(15),
       m_cod_item_pai    CHAR(15),
       m_cod_item_old    CHAR(15),
       m_cod_item_new    CHAR(15),
       m_cod_familia     CHAR(15),
       m_cod_pai         CHAR(15),
       m_situa           CHAR(01),
       m_peso_aces       DECIMAL(10,3)

DEFINE mr_cabec          RECORD
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item,
       cod_familia       LIKE familia.cod_familia,
       den_familia       LIKE familia.den_familia,
       dat_corte         DATE
END RECORD

   DEFINE lr_estrut       RECORD LIKE estrut_grade.*
   DEFINE mr_estrut       RECORD LIKE estrutura.*


#-----------------#
FUNCTION pol1382()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1382-12.00.04  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1382_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1382_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_proces      VARCHAR(10),
           l_inform      VARCHAR(10),
           l_titulo      CHAR(100),
           l_peso        VARCHAR(10)
    
    LET l_titulo = "AERTO DO PESO DO PRODUTO - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1382_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1382_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1382_cancelar")

    LET l_peso = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_peso,"IMAGE","PESO_INTE")     
    CALL _ADVPL_set_property(l_peso,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_peso,"TOOLTIP","Importar peso do Trim")
    CALL _ADVPL_set_property(l_peso,"EVENT","pol1370_import_peso")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Alterar etrutura")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1382_processar")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1382_cria_campos(l_panel)

   CALL pol1382_ativa_desativa(FALSE)

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1382_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_cod_item        VARCHAR(10),
           l_den_item        VARCHAR(10),
           l_den_fam         VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",180)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",50,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","item:")    

    LET m_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_item,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_item,"POSITION",90,10)     
    CALL _ADVPL_set_property(m_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_item,"LENGTH",15) 
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_cabec,"cod_item")
    CALL _ADVPL_set_property(m_item,"VALID","pol1382_checa_item")

    LET m_lupa_it = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_it,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_it,"POSITION",250,10)     
    CALL _ADVPL_set_property(m_lupa_it,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_it,"CLICK_EVENT","pol1382_zoom_item")

    LET l_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_item,"POSITION",310,10)     
    CALL _ADVPL_set_property(l_den_item,"LENGTH",50) 
    CALL _ADVPL_set_property(l_den_item,"VARIABLE",mr_cabec,"den_item")
    CALL _ADVPL_set_property(l_den_item,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",40,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Familia:")    

    LET m_familia = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_familia,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_familia,"POSITION",90,40)     
    CALL _ADVPL_set_property(m_familia,"PICTURE","@!")
    CALL _ADVPL_set_property(m_familia,"LENGTH",15) 
    CALL _ADVPL_set_property(m_familia,"VARIABLE",mr_cabec,"cod_familia")
    CALL _ADVPL_set_property(m_familia,"VALID","pol1382_checa_familia")

    LET m_lupa_fam = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_fam,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_fam,"POSITION",250,40)     
    CALL _ADVPL_set_property(m_lupa_fam,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_fam,"CLICK_EVENT","pol1382_zoom_familia")

    LET l_den_fam = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_den_fam,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_fam,"POSITION",310,40)     
    CALL _ADVPL_set_property(l_den_fam,"LENGTH",50) 
    CALL _ADVPL_set_property(l_den_fam,"VARIABLE",mr_cabec,"den_familia")
    CALL _ADVPL_set_property(l_den_fam,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,70)     
    CALL _ADVPL_set_property(l_label,"TEXT","Dat corte:")    

    LET m_dat_corte = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel)
    CALL _ADVPL_set_property(m_dat_corte,"POSITION",90,70)     
    CALL _ADVPL_set_property(m_dat_corte,"VARIABLE",mr_cabec,"dat_corte")

END FUNCTION


#----------------------------#
FUNCTION pol1382_checa_item()#
#----------------------------#

   DEFINE l_cod_familia  CHAR(15)

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   INITIALIZE mr_cabec.den_item TO NULL
   
   IF mr_cabec.cod_item IS NULL THEN
      RETURN TRUE
   END IF
      
   SELECT den_item
     INTO mr_cabec.den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_cabec.cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      CALL _ADVPL_set_property(m_item,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1382_checa_familia()#
#-------------------------------#

   DEFINE l_cod_familia  CHAR(15)

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   INITIALIZE mr_cabec.den_familia TO NULL
   
   IF mr_cabec.cod_familia IS NULL THEN
      RETURN TRUE
   END IF
      
   SELECT den_familia
     INTO mr_cabec.den_familia
     FROM familia
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = mr_cabec.cod_familia
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','familia')
      CALL _ADVPL_set_property(m_familia,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1382_zoom_item()#
#---------------------------#

    DEFINE l_cod_item       LIKE item.cod_item,
           l_den_item       LIKE item.den_item
    
    IF  m_zoom_it IS NULL THEN
        LET m_zoom_it = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_it,"ZOOM","zoom_item")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_it,"ACTIVATE")
    
    LET l_cod_item = _ADVPL_get_property(m_zoom_it,"RETURN_BY_TABLE_COLUMN","item","cod_item")
    LET l_den_item = _ADVPL_get_property(m_zoom_it,"RETURN_BY_TABLE_COLUMN","item","den_item")

    IF  l_cod_item IS NOT NULL THEN
        LET mr_cabec.cod_item = l_cod_item
        LET mr_cabec.den_item = l_den_item
    END IF
    
    CALL _ADVPL_set_property(m_item,"GET_FOCUS")

END FUNCTION

#------------------------------#
FUNCTION pol1382_zoom_familia()#
#------------------------------#

    DEFINE l_cod       LIKE familia.cod_familia,
           l_den       LIKE familia.den_familia
    
    IF  m_zoom_fam IS NULL THEN
        LET m_zoom_fam = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_fam,"ZOOM","zoom_familia")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_fam,"ACTIVATE")
    
    LET l_cod = _ADVPL_get_property(m_zoom_fam,"RETURN_BY_TABLE_COLUMN","familia","cod_familia")
    LET l_den = _ADVPL_get_property(m_zoom_fam,"RETURN_BY_TABLE_COLUMN","familia","den_familia")

    IF  l_cod IS NOT NULL THEN
        LET mr_cabec.cod_familia = l_cod
        LET mr_cabec.den_familia = l_den
    END IF
    
    CALL _ADVPL_set_property(m_familia,"GET_FOCUS")

END FUNCTION

#----------------------------------------#
FUNCTION pol1382_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
    
   CALL _ADVPL_set_property(m_item,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_it,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_familia,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_fam,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_dat_corte,"EDITABLE",l_status)

END FUNCTION

#--------------------------#
FUNCTION pol1382_informar()#
#--------------------------#
   
   DEFINE l_msg      CHAR(800)
   
   LET l_msg = 'Bot�o desativado. Use o bot�o Peso, para \n',
               'importar os pesos da tabela FT_ITEM_885, \n',
               'ou o bot�o Processar, p/ alterar a estrutura\n',
               'dos itens, cusjo de-para esteja na tabela\n ',
               'PAPELAO_885'
   
   CALL log0030_mensagem(l_msg CLIPPED,'info')
   
   RETURN FALSE               
   
   {DEFINE l_data    DATE
   
   LET m_ies_info = FALSE
      
   CALL pol1382_ativa_desativa(TRUE)
   CALL pol1382_limpa_campos()
   CALL _ADVPL_set_property(m_item,"GET_FOCUS")
   
   RETURN TRUE }
    
END FUNCTION

#-----------------------------#
FUNCTION pol1382_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
    
END FUNCTION

#---------------------------#
FUNCTION pol1382_confirmar()#
#---------------------------#

   IF mr_cabec.cod_item IS NOT NULL THEN
      IF mr_cabec.cod_familia IS NOT NULL THEN
         SELECT 1
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = mr_cabec.cod_item
            AND cod_familia = mr_cabec.cod_familia
         IF STATUS = 100 THEN
            LET m_msg = 'Familia/item inesistente no Logix'
            CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
            RETURN FALSE
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','item')
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF
   
   IF mr_cabec.dat_corte IS NULL THEN
      LET m_msg = 'Informe a data de corte.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_dat_corte,"GET_FOCUS")
      RETURN FALSE
   END IF   
   
   LET m_ies_info = TRUE
   CALL pol1382_ativa_desativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1382_cancelar()#
#--------------------------#

    CALL pol1382_limpa_campos()
    CALL pol1382_ativa_desativa(FALSE)
    LET m_ies_info = FALSE
    RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1382_processar()#
#---------------------------#

   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1382_acerta_estrut","PROCESS")  


   IF p_status THEN
      LET m_msg = "Processamento efetuado com sucesso."
   ELSE
      LET m_msg = "Opera��o cancelada."
   END IF
   
   LET m_ies_info = FALSE

   RETURN p_status

END FUNCTION
     
#-------------------------------#
FUNCTION pol1382_acerta_estrut()#
#-------------------------------#

   DEFINE l_progres   SMALLINT

   CALL LOG_progresspopup_set_total("PROCESS",9)
      
   DECLARE cq_old CURSOR WITH HOLD FOR
    SELECT cod_item_old,
           cod_item_new
      FROM papelao_885     
           
   FOREACH cq_old INTO m_cod_item_old, m_cod_item_new
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','papelao_885:cq_old')
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")

    SELECT COUNT(cod_item_pai) INTO m_count
      FROM estrut_grade
     WHERE cod_empresa = p_cod_empresa
       AND cod_item_compon = m_cod_item_old
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
        OR  (dat_validade_ini IS NULL AND dat_validade_fim >= getdate())
        OR  (dat_validade_fim IS NULL AND dat_validade_ini <= getdate())
        OR  (dat_validade_ini <= getdate() AND dat_validade_fim IS NULL)
        OR  (getdate() BETWEEN dat_validade_ini AND dat_validade_fim))

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estrut_grade:cq_old')
         RETURN FALSE
      END IF
      
      IF m_count = 0 THEN
         CONTINUE FOREACH
      END IF
      
      CALL LOG_transaction_begin()
      
      IF NOT pol1382_atualiza() THEN
         CALL LOG_transaction_rollback()
         RETURN FALSE
      END IF
      
      CALL LOG_transaction_commit()
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1382_atualiza()#
#--------------------------#
   
   DEFINE l_peso         INTEGER,
          l_pes_unit     DECIMAL(10,3)
   
   DECLARE cq_pai CURSOR FOR
    SELECT DISTINCT cod_item_pai           
      FROM estrut_grade
     WHERE cod_empresa = p_cod_empresa
       AND cod_item_compon = m_cod_item_old
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
        OR  (dat_validade_ini IS NULL AND dat_validade_fim >= getdate())
        OR  (dat_validade_fim IS NULL AND dat_validade_ini <= getdate())
        OR  (dat_validade_ini <= getdate() AND dat_validade_fim IS NULL)
        OR  (getdate() BETWEEN dat_validade_ini AND dat_validade_fim))
   
   FOREACH cq_pai INTO m_cod_item_pai
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'estrut_grade:cq_pai')
         RETURN FALSE
      END IF
      
      SELECT 1
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = m_cod_item_pai
         AND cod_familia = '201'
      
      IF STATUS = 0 THEN
         CONTINUE FOREACH
      END IF
      
      UPDATE estrut_grade
         SET cod_item_compon = m_cod_item_new
       WHERE cod_empresa = p_cod_empresa
         AND cod_item_pai = m_cod_item_pai
         AND cod_item_compon = m_cod_item_old
            
      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE', 'estrut_grade:update')
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE 

END FUNCTION

#-----------------------------#
FUNCTION pol1370_import_peso()#
#-----------------------------#

   LET m_msg = 'Deseja mesmo importar pesos da tabela FT_ITEM_885 ?'
   
   IF NOT LOG_question(m_msg) THEN
      RETURN FALSE
   END IF

   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1382_importar","PROCESS")  


   IF p_status THEN
      LET m_msg = "Processamento efetuado com sucesso."
   ELSE
      LET m_msg = "Opera��o cancelada."
   END IF
   
   LET m_ies_info = FALSE

   RETURN p_status

END FUNCTION

#--------------------------#
FUNCTION pol1382_importar()#
#--------------------------#

   DEFINE l_progres       SMALLINT,
          l_peso          LIKE item.pes_unit,
          l_familia       LIKE item.cod_familia,
          l_item          CHAR(15)
   
   SELECT COUNT(*) INTO m_count
    FROM ft_item_885
   WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ft_item_885')
      RETURN FALSE
   END IF   
    
   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   DECLARE cq_peso CURSOR  WITH HOLD FOR
    SELECT peso, cod_item 
      FROM ft_item_885
     WHERE cod_empresa = p_cod_empresa
     AND peso IS NOT NULL
     AND cod_item IS NOT NULL

   FOREACH cq_peso INTO l_peso, l_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ft_item_885:cq_peso')
         RETURN FALSE
      END IF   
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")

      LET l_familia = NULL
      
      SELECT cod_familia
        INTO l_familia
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = l_item
      
      IF STATUS = 100 OR l_familia = '201' THEN
         CONTINUE FOREACH
      END IF
      
      LET l_peso = l_peso / 1000
      
      LET l_peso = log2260_troca_virgula_por_ponto(l_peso)
      
      CALL LOG_transaction_begin()
      
      UPDATE item SET pes_unit = l_peso
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = l_item  

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','item-cq_peso')
         CALL LOG_transaction_rollback()
         RETURN FALSE
      END IF   
      
      CALL LOG_transaction_commit()
         
   END FOREACH   
   
   RETURN TRUE

END FUNCTION
   
   