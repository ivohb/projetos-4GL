   
#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1335                                                 #
# OBJETIVO: Baixa da estrutura componentes inativos                 #
# AUTOR...: IVO                                                     #
# DATA....: 19/12/17                                                #
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
FUNCTION pol1335()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1335-12.00.08  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1335_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1335_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_proces      VARCHAR(10),
           l_inform      VARCHAR(10),
           l_titulo      CHAR(100)
    
    LET l_titulo = "BAIXA DA ESTRUTURA OS COMPONENTES INATRIVOS - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1335_processar")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION


#---------------------------#
FUNCTION pol1335_processar()#
#---------------------------#

   CALL LOG_progresspopup_start(
      "Processando...","pol1335_acerta_peso","PROCESS")   



END FUNCTION
     
#-----------------------------#
FUNCTION pol1335_acerta_peso()#
#-----------------------------#

   DEFINE l_progres   SMALLINT

   SELECT COUNT(DISTINCT cod_item_pai)
     INTO m_count
     FROM estrut_grade a, item b
     WHERE b.cod_empresa = p_cod_empresa
       AND b.ies_situacao = 'I'
       AND b.cod_item = a.cod_item_compon
       AND b.cod_empresa = a.cod_empresa       
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
        OR  (dat_validade_ini IS NULL AND dat_validade_fim >= getdate())
        OR  (dat_validade_fim IS NULL AND dat_validade_ini <= getdate())
        OR  (dat_validade_ini <= getdate() AND dat_validade_fim IS NULL)
        OR  (getdate() BETWEEN dat_validade_ini AND dat_validade_fim))
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estrut_grade:count')
      RETURN
   END IF
   
   IF m_count = 0 THEN
      CALL log0030_mensagem('Não há estruras a acertar','info')
      RETURN
   END IF
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DECLARE cq_baixa CURSOR WITH HOLD FOR 
    SELECT DISTINCT cod_item_pai
      FROM estrut_grade a, item b
     WHERE b.cod_empresa = p_cod_empresa
       AND b.ies_situacao = 'I'
       AND b.cod_item = a.cod_item_compon
       AND b.cod_empresa = a.cod_empresa       
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
        OR  (dat_validade_ini IS NULL AND dat_validade_fim >= getdate())
        OR  (dat_validade_fim IS NULL AND dat_validade_ini <= getdate())
        OR  (dat_validade_ini <= getdate() AND dat_validade_fim IS NULL)
        OR  (getdate() BETWEEN dat_validade_ini AND dat_validade_fim))
       
   FOREACH cq_baixa INTO m_cod_pai
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','FOREACH:cq_baixa')
         RETURN
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")

      BEGIN WORK
      
      IF NOT pol1335_le_etrutura() THEN
         ROLLBACK WORK
         RETURN
      END IF
            
      COMMIT WORK
      
   END FOREACH

END FUNCTION

#-----------------------------#
FUNCTION pol1335_le_etrutura()#
#-----------------------------#
   
   DEFINE l_ies_situacao    CHAR(01)
   
   DECLARE cq_compon CURSOR FOR
    SELECT cod_item_compon
      FROM estrut_grade
     WHERE cod_empresa = p_cod_empresa
       AND cod_item_pai = m_cod_pai
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
        OR  (dat_validade_ini IS NULL AND dat_validade_fim >= getdate())
        OR  (dat_validade_fim IS NULL AND dat_validade_ini <= getdate())
        OR  (dat_validade_ini <= getdate() AND dat_validade_fim IS NULL)
        OR  (getdate() BETWEEN dat_validade_ini AND dat_validade_fim))
   
   FOREACH cq_compon INTO m_cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT', 'FOREACH:cq_compon')
         RETURN FALSE
      END IF
      
      SELECT ies_situacao
        INTO l_ies_situacao
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = m_cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT', 'item:cq_compon')
         RETURN FALSE
      END IF
      
      IF l_ies_situacao = 'A' THEN
      ELSE
         UPDATE estrut_grade
            SET dat_validade_fim = getdate()
          WHERE cod_empresa = p_cod_empresa
            AND cod_item_pai = m_cod_pai
            AND cod_item_compon = m_cod_item

         IF STATUS <> 0 THEN
            CALL log003_err_sql('UPDATE', 'estrut_grade')
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH
   
   RETURN TRUE 

END FUNCTION

      