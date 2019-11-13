#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1331                                                 #
# OBJETIVO: TROCA COMPONENTE DA ESTRUTURA                           #
# AUTOR...: IVO                                                     #
# DATA....: 06/09/17                                                #
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
       m_zoom_it         VARCHAR(10)

DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_cod_item        CHAR(15),
       m_cod_novo        CHAR(15),
       m_cod_pai         CHAR(15),
       m_situa           CHAR(01)

DEFINE mr_cabec          RECORD
       cod_item          CHAR(15),
       den_item          CHAR(70),
       cod_novo          CHAR(15),
       den_novo          CHAR(70)
END RECORD

   DEFINE lr_estrut       RECORD LIKE estrut_grade.*
   DEFINE mr_estrut       RECORD LIKE estrutura.*


#-----------------#
FUNCTION pol1331()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1331-12.00.07  "
   CALL func002_versao_prg(p_versao)
   
   IF pol1323_cria_tab() THEN
      CALL pol1331_menu()
   END IF
    
END FUNCTION

#----------------------#
FUNCTION pol1331_menu()#
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

    {
    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1331_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1331_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1331_cancelar")
    }
    
    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1331_processar")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1331_cria_campos(l_panel)

   CALL pol1331_ativa_desativa(FALSE)

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1331_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_cod_item        VARCHAR(10),
           l_den_item        VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",80)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",50,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","item:")    

    LET m_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_item,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_item,"POSITION",90,10)     
    CALL _ADVPL_set_property(m_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_item,"LENGTH",15) 
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_cabec,"cod_item")
    CALL _ADVPL_set_property(m_item,"VALID","pol1331_checa_item")

    LET m_lupa_it = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_it,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_it,"POSITION",250,10)     
    CALL _ADVPL_set_property(m_lupa_it,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_it,"CLICK_EVENT","pol1331_zoom_item")

    LET l_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_item,"POSITION",310,10)     
    CALL _ADVPL_set_property(l_den_item,"LENGTH",50) 
    CALL _ADVPL_set_property(l_den_item,"VARIABLE",mr_cabec,"den_item")

    LET m_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_item,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_item,"POSITION",90,40)     
    CALL _ADVPL_set_property(m_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_item,"LENGTH",15) 
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_cabec,"cod_novo")
    CALL _ADVPL_set_property(m_item,"VALID","pol1331_checa_novo")

    LET m_lupa_it = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_it,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_it,"POSITION",250,40)     
    CALL _ADVPL_set_property(m_lupa_it,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_it,"CLICK_EVENT","pol1331_zoom_novo")

    LET l_den_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(l_den_item,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_den_item,"POSITION",310,40)     
    CALL _ADVPL_set_property(l_den_item,"LENGTH",50) 
    CALL _ADVPL_set_property(l_den_item,"VARIABLE",mr_cabec,"den_novo")


END FUNCTION


#----------------------------#
FUNCTION pol1331_checa_item()#
#----------------------------#

   DEFINE l_cod_familia  CHAR(15)

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   INITIALIZE mr_cabec.den_item TO NULL
   
   IF mr_cabec.cod_item IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe o produto.")
      RETURN FALSE
   END IF
      
   SELECT den_item
     INTO mr_cabec.den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_cabec.cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1331_checa_novo()#
#----------------------------#

   DEFINE l_cod_familia  CHAR(15)

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   INITIALIZE mr_cabec.den_novo TO NULL
   
   IF mr_cabec.cod_novo IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe o código novo")
      RETURN FALSE
   END IF
      
   SELECT den_item
     INTO mr_cabec.den_novo
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_cabec.cod_novo
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1331_zoom_item()#
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

#----------------------------------------#
FUNCTION pol1331_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
    
   CALL _ADVPL_set_property(m_item,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_it,"EDITABLE",l_status)

END FUNCTION

#--------------------------#
FUNCTION pol1331_informar()#
#--------------------------#
   
   DEFINE l_data    DATE
   
   LET m_ies_info = FALSE
      
   CALL pol1331_ativa_desativa(TRUE)
   CALL pol1331_limpa_campos()
      
   RETURN TRUE 
    
END FUNCTION

#-----------------------------#
FUNCTION pol1331_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
    
END FUNCTION

#---------------------------#
FUNCTION pol1331_confirmar()#
#---------------------------#
   
   IF mr_cabec.cod_item IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Informe o item")
      CALL _ADVPL_set_property(m_item,"GET_FOCUS")
      RETURN FALSE      
   END IF
   
   IF NOT pol1331_checa_item() THEN
      RETURN FALSE
   END IF
   
   LET m_ies_info = TRUE
   CALL pol1331_ativa_desativa(FALSE)
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1331_cancelar()#
#--------------------------#

    CALL pol1331_limpa_campos()
    CALL pol1331_ativa_desativa(FALSE)
    LET m_ies_info = FALSE
    RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1331_processar()#
#---------------------------#

   IF NOT LOG_question("Confirma a alteração da estrutura?") THEN
      CALL pol1331_cancelar()
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF
       
   IF NOT pol1331_alt_estrut() THEN
      LET m_msg = 'Operação cancelada.'
   ELSE
      LET m_msg = 'Operação efetuada com sucesso.'
   END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)

   LET m_ies_info = FALSE

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1331_ins_erro()#
#--------------------------#

   INSERT INTO erro_item_885
    VALUES(m_msg)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','erro_item_885')
      RETURN FALSE
   END IF
   
   LET m_situa = 'C'
   
   IF NOT pol1331_atu_tab() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1331_alt_estrut()#
#----------------------------#
   define l_men    char(80)
      
   LET m_cod_item = mr_cabec.cod_item
   
   DELETE FROM erro_item_885
   
   DECLARE cq_item CURSOR WITH HOLD FOR
    SELECT cod_novo, cod_item 
      FROM de_para_chapa_885
     WHERE situacao = 'N'

   FOREACH cq_item INTO m_cod_novo, m_cod_item
        
     IF STATUS <> 0 THEN
        CALL log003_err_sql('FOREACH''cq_item')
        RETURN FALSE
     END IF
     
     SELECT cod_item FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = m_cod_item

     IF STATUS = 100 THEN
        LET m_msg = 'Item velho ', m_cod_item CLIPPED, ' Inexistente no Logix'
        IF NOT pol1331_ins_erro() THEN
           RETURN FALSE
        END IF
        CONTINUE FOREACH
     ELSE
        IF STATUS <> 0 THEN
           CALL log003_err_sql('FOREACH''cq_item')
           RETURN FALSE
        END IF
     END IF

     SELECT cod_item FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = m_cod_novo

     IF STATUS = 100 THEN
        LET m_msg = 'Item novo ', m_cod_novo CLIPPED, ' Inexistente no Logix'
        IF NOT pol1331_ins_erro() THEN
           RETURN FALSE
        END IF
        CONTINUE FOREACH
     ELSE
        IF STATUS <> 0 THEN
           CALL log003_err_sql('FOREACH''cq_item')
           RETURN FALSE
        END IF
     END IF
     
     BEGIN WORK
     
     IF NOT pol1331_le_estrut() THEN
        ROLLBACK WORK
        RETURN FALSE
     END IF
     
     COMMIT WORK
     
  END FOREACH

END FUNCTION

#-------------------------#
FUNCTION pol1331_atu_tab()#
#-------------------------#

   UPDATE de_para_chapa_885
     SET situacao = m_situa
   WHERE cod_item = m_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE''de_para_chapa_885')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   
     

#---------------------------#
FUNCTION pol1331_le_estrut()#
#---------------------------#

   DEFINE l_cod_compon    LIKE item.cod_item,
          l_qtd_neces     LIKE estrut_grade.qtd_necessaria,
          l_parametros    LIKE estrut_grade.parametros,
          l_dat_fim       DATE,
          l_dat_ini       DATE,
          l_param         LIKE estrut_grade.parametros,
          l_posi          INTEGER,
          l_posi_ant      INTEGER,
          l_seq           INTEGER,
          l_num_param     INTEGER,
          m_cod_ant       CHAR(15),
          l_men           CHAR(80)
   
   LET m_cod_ant =  m_cod_item
               
   DECLARE cq_pai CURSOR FOR
    SELECT cod_item_pai
      FROM estrut_grade
     WHERE cod_empresa = p_cod_empresa
       AND cod_item_compon = m_cod_item
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
        OR  (dat_validade_ini IS NULL AND dat_validade_fim >= getdate())
        OR  (dat_validade_fim IS NULL AND dat_validade_ini <= getdate())
        OR  (dat_validade_ini <= getdate() AND dat_validade_fim IS NULL)
        OR  (getdate() BETWEEN dat_validade_ini AND dat_validade_fim))
   
   FOREACH cq_pai INTO m_cod_pai
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_pai')
         RETURN FALSE
      END IF
      
      DECLARE cq_grade CURSOR FOR
      SELECT *        
        FROM estrut_grade
       WHERE cod_empresa = p_cod_empresa
         AND cod_item_compon = m_cod_item
         AND cod_item_pai = m_cod_pai
         AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
          OR  (dat_validade_ini IS NULL AND dat_validade_fim >= getdate())
          OR  (dat_validade_fim IS NULL AND dat_validade_ini <= getdate())
          OR  (dat_validade_ini <= getdate() AND dat_validade_fim IS NULL)
          OR  (getdate() BETWEEN dat_validade_ini AND dat_validade_fim))
   
      FOREACH cq_grade INTO lr_estrut.*
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH', 'cq_grade')
            RETURN FALSE
         END IF
         EXIT FOREACH
      END FOREACH
         
         {LET l_posi_ant = lr_estrut.cod_posicao
         
         SELECT max(cod_posicao)
           INTO l_posi
           FROM estrut_grade
          WHERE cod_empresa = p_cod_empresa
            AND cod_item_pai = lr_estrut.cod_item_pai      

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT', 'estrut_grade:posição')
            RETURN FALSE
         END IF
   
         IF l_posi IS NULL THEN
            LET l_posi = 0
         END IF
   
         SELECT max(num_sequencia)
           INTO l_seq
           FROM estrut_grade
          WHERE cod_empresa = p_cod_empresa

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT', 'estrut_grade:num_sequencia')
            RETURN FALSE
         END IF

         IF l_seq IS NULL THEN
            LET l_seq = 0
         END IF

         LET lr_estrut.cod_item_compon = m_cod_novo
         LET l_posi = l_posi + 1
         LET l_seq = l_seq + 1
         LET lr_estrut.cod_posicao = l_posi
         LET lr_estrut.num_sequencia = l_seq
         LET l_num_param = l_posi
         LET lr_estrut.parametros = func002_strzero(l_num_param,10)

         LET l_dat_fim = TODAY
         LET l_dat_ini = l_dat_fim + 1
         
         LET lr_estrut.dat_validade_ini = l_dat_ini

         IF NOT pol1331_grava_estrut() THEN
            RETURN FALSE
         END IF
      
         UPDATE estrut_grade SET dat_validade_fim = l_dat_fim
          WHERE cod_empresa = p_cod_empresa
            AND cod_item_pai = m_cod_pai
            AND cod_item_compon = m_cod_ant
            AND cod_posicao = l_posi_ant

         IF STATUS <> 0 THEN
            CALL log003_err_sql('UPDATE','estrut_grade')
            RETURN FALSE
         END IF}

      DELETE FROM estrut_grade
       WHERE cod_empresa = p_cod_empresa
         AND cod_item_pai = lr_estrut.cod_item_pai
         AND cod_item_compon = lr_estrut.cod_item_compon
         AND cod_posicao = lr_estrut.cod_posicao
         AND num_sequencia = lr_estrut.num_sequencia

      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','estrut_grade')
         RETURN FALSE
      END IF

      LET lr_estrut.cod_item_compon = m_cod_novo
         
      IF NOT pol1331_grava_estrut() THEN
         RETURN FALSE
      END IF

      SELECT *
        INTO mr_estrut.*
        FROM estrutura
       WHERE cod_empresa = p_cod_empresa
         AND cod_item_compon = m_cod_item
         AND cod_item_pai = m_cod_pai
         AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
          OR  (dat_validade_ini IS NULL AND dat_validade_fim >= getdate())
          OR  (dat_validade_fim IS NULL AND dat_validade_ini <= getdate())
          OR  (dat_validade_ini <= getdate() AND dat_validade_fim IS NULL)
          OR  (getdate() BETWEEN dat_validade_ini AND dat_validade_fim))
   
      
      IF STATUS <> 0 THEN
         #CALL log003_err_sql('SELECT', 'estrutura')
         CONTINUE FOREACH
      END IF

      DELETE FROM estrutura
       WHERE cod_empresa = p_cod_empresa
         AND cod_item_pai = mr_estrut.cod_item_pai
         AND cod_item_compon = mr_estrut.cod_item_compon
         AND parametros = mr_estrut.parametros

      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','estrutura')
         RETURN FALSE
      END IF

      LET mr_estrut.cod_item_compon = m_cod_novo
         
      INSERT INTO estrutura VALUES(mr_estrut.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','estrutura')
         RETURN FALSE
      END IF
        
      LET l_men = 'TROCANDO COMPONENTE DO ITEM: ', m_cod_pai
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", l_men)
         #lds CALL LOG_refresh_display()
         
   END FOREACH

   LET m_situa = 'I'
   
   IF NOT pol1331_atu_tab() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
     
#------------------------------#
FUNCTION pol1331_grava_estrut()#
#------------------------------#

      INSERT INTO estrut_grade(
        cod_empresa,               
        cod_item_pai,               
        cod_grade_1,                
        cod_grade_2,                
        cod_grade_3,                
        cod_grade_4,                
        cod_grade_5,                
        cod_item_compon,            
        cod_grade_comp_1,           
        cod_grade_comp_2,           
        cod_grade_comp_3,           
        cod_grade_comp_4,           
        cod_grade_comp_5,           
        qtd_necessaria,             
        pct_refug,                  
        dat_validade_ini,
        dat_validade_fim,           
        tmp_ressup_sobr,            
        cod_cent_cust,              
        cod_comp_custo,             
        num_sequencia,              
        parametros,                 
        cod_posicao,                
        texto)                            
       VALUES(lr_estrut.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT', 'estrut_grade')
         RETURN FALSE
      END IF

      RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1331_acerta_peso()#
#-----------------------------#

   DEFINE l_peso      INTEGER,
          l_pes_unit  DECIMAL(10,3),
          l_cod_item  CHAR(15),
          l_men       CHAR(100)
   
   DECLARE cq_peso CURSOR WITH HOLD FOR
    SELECT a.peso, a.cod_item
      FROM ft_item_885 a, item b
     WHERE a.cod_empresa = '01'
       AND b.cod_empresa = a.cod_empresa
       AND b.cod_item = a.cod_item
       
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
      
      LET l_pes_unit = l_peso / 1000
      
      BEGIN WORK
      
      UPDATE Item SET pes_unit = l_pes_unit
       WHERE cod_empresa = '01' and cod_item = l_cod_item
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','Item')
         ROLLBACK WORK
         RETURN
      END IF
      
      COMMIT WORK
   
   END FOREACH

END FUNCTION

#--------------------------#
FUNCTION pol1323_cria_tab()#
#--------------------------#
   
   DEFINE l_tab     CHAR(30)
   
   LET l_tab = 'troca_compon_885'
   
   IF NOT log0150_verifica_se_tabela_existe(l_tab) THEN
      CREATE TABLE troca_compon_885 (
       cod_empresa       CHAR(02),
       dat_troca         CHAR(19),
       item_sai          CHAR(15),
       item_entra        CHAR(15),
       usuario           CHAR(08)
      );

      IF STATUS <> 0 THEN
         CALL log003_err_sql('CREATE','troca_compon_885')
         RETURN FALSE
      END IF
      
      create index ix_troca_compon_885 ON 
       troca_compon_885(cod_empresa);

      IF STATUS <> 0 THEN
         CALL log003_err_sql('CREATE','troca_compon_885.INDEX')
         RETURN FALSE
      END IF
       
   END IF
   
   RETURN TRUE

END FUNCTION
   