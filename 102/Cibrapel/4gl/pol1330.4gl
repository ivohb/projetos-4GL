{
insert into item_acerta_885
select cod_item from item where cod_empresa = '01'
and cod_familia  in ('200','201','202','205')
 and ies_tip_item <> 'C' and cod_item in
 (select distinct cod_item_pai from estrut_grade
 where cod_empresa = '01')
 AND substring(cod_item,1,1) < 'A'
 
 }
   
#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1330                                                 #
# OBJETIVO: Acerto do peso do ite a partir da ficha técnica         #
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
FUNCTION pol1330()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1330-12.00.08  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1330_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1330_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_proces      VARCHAR(10),
           l_inform      VARCHAR(10),
           l_titulo      CHAR(100)
    
    LET l_titulo = "AERTO DO PESO DO PRODUTO - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1330_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1330_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1330_cancelar")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1330_processar")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1330_cria_campos(l_panel)

   CALL pol1330_ativa_desativa(FALSE)

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1330_cria_campos(l_container)#
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
    CALL _ADVPL_set_property(m_item,"VALID","pol1330_checa_item")

    LET m_lupa_it = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_it,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_it,"POSITION",250,10)     
    CALL _ADVPL_set_property(m_lupa_it,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_it,"CLICK_EVENT","pol1330_zoom_item")

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
    CALL _ADVPL_set_property(m_familia,"VALID","pol1330_checa_familia")

    LET m_lupa_fam = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_fam,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_fam,"POSITION",250,40)     
    CALL _ADVPL_set_property(m_lupa_fam,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_fam,"CLICK_EVENT","pol1330_zoom_familia")

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
FUNCTION pol1330_checa_item()#
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
FUNCTION pol1330_checa_familia()#
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
FUNCTION pol1330_zoom_item()#
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
FUNCTION pol1330_zoom_familia()#
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
FUNCTION pol1330_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
    
   CALL _ADVPL_set_property(m_item,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_it,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_familia,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_fam,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_dat_corte,"EDITABLE",l_status)

END FUNCTION

#--------------------------#
FUNCTION pol1330_informar()#
#--------------------------#
   
   DEFINE l_data    DATE
   
   LET m_ies_info = FALSE
      
   CALL pol1330_ativa_desativa(TRUE)
   CALL pol1330_limpa_campos()
   CALL _ADVPL_set_property(m_item,"GET_FOCUS")
   
   RETURN TRUE 
    
END FUNCTION

#-----------------------------#
FUNCTION pol1330_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
    
END FUNCTION

#---------------------------#
FUNCTION pol1330_confirmar()#
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
   CALL pol1330_ativa_desativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1330_cancelar()#
#--------------------------#

    CALL pol1330_limpa_campos()
    CALL pol1330_ativa_desativa(FALSE)
    LET m_ies_info = FALSE
    RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1330_processar()#
#---------------------------#

   IF NOT m_ies_info THEN
      LET m_msg = 'Informe os parâmetros previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT LOG_question("Confirma a alteração de peso?") THEN
      CALL pol1330_cancelar()
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF
   

   IF NOT pol1330_acerta_peso() THEN
      LET m_msg = 'Operação cancelada.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
   ELSE
      LET m_msg = 'Operação efetuada com sucesso.'
      CALL log0030_mensagem(m_msg,'info')
   END IF
    
   LET m_ies_info = FALSE

   RETURN TRUE

END FUNCTION
     
#-----------------------------#
FUNCTION pol1330_acerta_peso()#
#-----------------------------#

   DEFINE l_peso      INTEGER,
          l_pes_unit  DECIMAL(10,3),
          l_cod_item  CHAR(15),
          l_men       CHAR(100),
          l_query     CHAR(800)

   LET l_query = 
       "SELECT a.peso, a.cod_item FROM ft_item_885 a, item b ",
       " WHERE a.cod_empresa = '",p_cod_empresa,"' ",
       "   AND b.cod_empresa = a.cod_empresa ",
       "   AND b.cod_item = a.cod_item "

   IF mr_cabec.cod_familia IS NOT NULL THEN
      LET l_query = l_query CLIPPED, " AND b.cod_familia = '",mr_cabec.cod_familia,"' "
   END IF

   IF mr_cabec.cod_item IS NOT NULL THEN
      LET l_query = l_query CLIPPED, " AND b.cod_item = '",mr_cabec.cod_item,"' "
   END IF

   PREPARE var_query FROM l_query   
   
   DECLARE cq_peso CURSOR WITH HOLD FOR var_query
       
   FOREACH cq_peso INTO l_peso, l_cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cq_peso')
         RETURN
      END IF

      LET l_men = 'ACERTANDO PESO DO PRODUTO: ', l_cod_item
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", l_men)
         #lds CALL LOG_refresh_display()
      
      IF l_peso IS NULL THEN
         LET l_peso = 0
      END IF
      
      IF NOT pol1330_le_etrutura(l_cod_item) THEN
         RETURN
      END IF

      IF m_peso_aces IS NULL THEN
         LET m_peso_aces = 0
      END IF
      
      LET l_peso = l_peso + m_peso_aces
      LET l_pes_unit = l_peso / 1000
      
      BEGIN WORK
      
      UPDATE Item SET pes_unit = l_pes_unit
       WHERE cod_empresa = '01' and cod_item = l_cod_item
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','Item')
         ROLLBACK WORK
         RETURN
      END IF
      
      IF NOT pol1330_atu_cha(l_cod_item, l_pes_unit) THEN
         ROLLBACK WORK
         RETURN
      END IF      
      
      COMMIT WORK
      
   END FOREACH

END FUNCTION

#---------------------------------------#
FUNCTION pol1330_le_etrutura(l_cod_item)#
#---------------------------------------#
   
   DEFINE l_cod_item     LIKE item.cod_item,
          l_cod_compon   LIKE item.cod_item,
          l_peso_aces    LIKE item.pes_unit,
          l_qtd_neces    LIKE estrut_grade.qtd_necessaria
   
   LET m_peso_aces = 0 
   
   DECLARE cq_pai CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria
      FROM estrut_grade
     WHERE cod_empresa = p_cod_empresa
       AND cod_item_pai = l_cod_item
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
        OR  (dat_validade_ini IS NULL AND dat_validade_fim >= getdate())
        OR  (dat_validade_fim IS NULL AND dat_validade_ini <= getdate())
        OR  (dat_validade_ini <= getdate() AND dat_validade_fim IS NULL)
        OR  (getdate() BETWEEN dat_validade_ini AND dat_validade_fim))
   
   FOREACH cq_pai INTO l_cod_compon, l_qtd_neces
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_pai')
         RETURN FALSE
      END IF
      
      IF l_cod_compon[1] MATCHES "[0123456789]" THEN
         SELECT pes_unit FROM Item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = l_cod_compon
            AND cod_familia = '202'
         IF STATUS = 0 THEN
            SELECT peso INTO l_peso_aces FROM ft_item_885
             WHERE cod_empresa = p_cod_empresa
               AND cod_item = l_cod_compon
            IF STATUS <> 0 OR l_peso_aces IS NULL THEN
               LET l_peso_aces = 0
            END IF
            LET m_peso_aces = m_peso_aces + (l_peso_aces * l_qtd_neces)
         ELSE
            IF STATUS <> 100 THEN
               CALL log003_err_sql('SELECT','item')
               RETURN FALSE
            END IF
         END IF
      END IF
      
   END FOREACH
   
   RETURN TRUE 

END FUNCTION

#-----------------------------------------------#
FUNCTION pol1330_atu_cha(l_cod_item, l_pes_unit)#
#-----------------------------------------------#

   DEFINE l_cod_item       LIKE item.cod_item,
          l_num_pedido     LIKE ped_itens.num_pedido,
          l_num_seq        LIKE ped_itens.num_sequencia,
          l_pes_unit       LIKE item.pes_unit
   
   DECLARE cq_item_cha CURSOR WITH HOLD FOR
    SELECT b.num_pedido, b.num_sequencia
      FROM item_caixa_885 a, ped_itens b 
     WHERE a.cod_empresa = p_cod_empresa
       AND b.cod_empresa = a.cod_empresa 
       AND b.num_sequencia = a.num_sequencia
       AND b.num_pedido = a.num_pedido
       AND b.cod_item = l_cod_item
       AND b.prz_entrega >= mr_cabec.dat_corte
      
   FOREACH cq_item_cha INTO l_num_pedido, l_num_seq
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ped_itens:cq_item_cha')
         RETURN FALSE
      END IF
      
      UPDATE item_caixa_885
         SET pes_unit = l_pes_unit
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = l_num_pedido
         AND num_sequencia = l_num_seq

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','item_caixa_885:')
         RETURN FALSE
      END IF
         
   END FOREACH
   
   RETURN TRUE

END FUNCTION
   
      