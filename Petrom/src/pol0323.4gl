#-------------------------------------------------------------------#
# SISTEMA.: EMISSOR DE LAUDOS                                       #
# PROGRAMA: POL0323                                                 #
# MODULOS.: POL0323 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: PREPARA��O PARA IMPRESS�O DO LAUDO                      #
# AUTOR...: LOGOCENTER ABC - ANTONIO CEZAR VIEIRA JUNIOR            #
# DATA....: 14/02/2005          BI                                  #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
          p_den_empresa   LIKE empresa.den_empresa,  
          p_user          LIKE usuario.nom_usuario,
          p_status        SMALLINT,
          p_houve_erro    SMALLINT,
          comando         CHAR(80),
          # p_versao        CHAR(17),
          p_versao        CHAR(18),
          p_ies_impressao CHAR(001),
          g_ies_ambiente  CHAR(001),
          p_nom_arquivo   CHAR(100),
          p_arquivo       CHAR(025),
          p_caminho       CHAR(080),
          p_nom_tela      CHAR(200),
          p_nom_help      CHAR(200),
          sq_stmt         CHAR(300),
          p_r             CHAR(001),
          p_count         SMALLINT,
          p_ies_cons      SMALLINT,
          p_ast_row       SMALLINT,
          p_grava         SMALLINT, 
          pa_curr         SMALLINT,
          pa_curr1        SMALLINT,
          sc_curr         SMALLINT,
          sc_curr1        SMALLINT,
          w_a             SMALLINT,
          p_msg           CHAR(100),
          p_hoje          DATE,
          p_trans_nota_fiscal LIKE fat_nf_mestre.trans_nota_fiscal

END GLOBALS
   
   DEFINE w_i             SMALLINT,
          m_laudo_exx     SMALLINT,
          p_raz_social    CHAR(40),
          p_den_item      CHAR(60),
          p_dat_fabric    DATE,
          p_dat_valid     DATE,
          m_bloq_laudo    CHAR(01)

   DEFINE mr_tela RECORD 
      num_laudo      LIKE laudo_mest_petrom.num_laudo,
      num_nf         LIKE fat_nf_mestre.nota_fiscal,
      num_om         LIKE fat_nf_item.ord_montag, 
      cod_item       LIKE analise_petrom.cod_item,
      lote_tanque    LIKE analise_petrom.lote_tanque,
      qtd_laudo      LIKE laudo_mest_petrom.qtd_laudo,
      texto_1        LIKE laudo_mest_petrom.texto_1,
      texto_2        LIKE laudo_mest_petrom.texto_2,
      texto_3        LIKE laudo_mest_petrom.texto_3
   END RECORD 

   DEFINE mr_tela1  RECORD 
      num_laudo      LIKE laudo_mest_petrom.num_laudo,
      cod_cliente    LIKE clientes.cod_cliente,
      cod_item       LIKE analise_petrom.cod_item,
      lote_tanque    LIKE analise_petrom.lote_tanque,
      qtd_laudo      LIKE laudo_mest_petrom.qtd_laudo,
      texto_1        LIKE laudo_mest_petrom.texto_1,
      texto_2        LIKE laudo_mest_petrom.texto_2,
      texto_3        LIKE laudo_mest_petrom.texto_3
   END RECORD 

   DEFINE mr_nfe     RECORD 
      num_laudo      LIKE laudo_mest_petrom.num_laudo,
      num_nf         LIKE fat_nf_mestre.nota_fiscal,
      ser_nf         LIKE fat_nf_item.ord_montag, 
      cod_fornecedor LIKE fornecedor.cod_fornecedor,
      cod_item       LIKE analise_petrom.cod_item,
      lote_tanque    LIKE analise_petrom.lote_tanque,
      qtd_laudo      LIKE laudo_mest_petrom.qtd_laudo,
      texto_1        LIKE laudo_mest_petrom.texto_1,
      texto_2        LIKE laudo_mest_petrom.texto_2,
      texto_3        LIKE laudo_mest_petrom.texto_3
   END RECORD 

   DEFINE ma_tela ARRAY[50] OF RECORD 
      ies_calcula_media     CHAR(1),
      num_pa                LIKE analise_petrom.num_pa
   END RECORD 

   DEFINE ma_num_pa ARRAY[50] OF RECORD 
      num_pa                LIKE analise_petrom.num_pa
   END RECORD 

   DEFINE m_ind             SMALLINT,
          m_den_analise     LIKE it_analise_petrom.den_analise,
          m_ies_tanque      CHAR(1),
          m_item_petrom     LIKE item_petrom.cod_item_petrom

MAIN
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "POL0323-10.02.19"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0323.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   # CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0323_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol0323_controle()
#--------------------------#
   DEFINE l_informou_dados     SMALLINT

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0323") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0323 AT 2,1 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
 
   LET l_informou_dados = FAlSE

   MENU "OPCAO"
      COMMAND "peTrom" "Informa par�metros para criar Laudo Petrom."
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0323","IN") THEN
            IF pol0323_informa_dados() THEN
               IF pol0323_verifica_se_eh_tanque() = FALSE THEN
                  CALL pol0323_busca_num_pa(mr_tela.lote_tanque)
                  IF pol0323_informa_pas() THEN
                     LET l_informou_dados = TRUE
                     ERROR 'Opera��o efetuada com sucesso!'
                     NEXT OPTION "Processar"
                  END IF
               ELSE
                  ERROR 'Este item � tanque, pode processar.'
                  LET l_informou_dados = TRUE
                  NEXT OPTION "Processar"
               END IF
            ELSE
               LET l_informou_dados = FALSE
               ERROR 'Opera��o cancelada!'
            END IF
         END IF
      COMMAND "Exxonmobil" "Informa par�metros para criar Laudo Exxonmobil."
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0323","IN") THEN
            IF pol0323_informa_dados_exxon() THEN
               IF pol0323_verifica_se_eh_tanque() = FALSE THEN
                  CALL pol0323_busca_num_pa(mr_tela1.lote_tanque)
                  IF pol0323_informa_pas() THEN
                     LET l_informou_dados = TRUE
                     ERROR 'Opera��o efetuada com sucesso!'
                     NEXT OPTION "Processar"
                  END IF
               ELSE
                  ERROR 'Este item � tanque, pode processar.'
                  LET l_informou_dados = TRUE
                  NEXT OPTION "Processar"
               END IF 
            ELSE
               LET l_informou_dados = FALSE
               ERROR 'Opera��o cancelada!'
            END IF
         END IF

      COMMAND "NF de entrada" "Laudo de nota de entrada"
         CALL pol0323_laudo_de_nfe()
      COMMAND "Processar" "Processa a prepara��o do laudo."
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF l_informou_dados THEN
            IF log005_seguranca(p_user,"VDP","pol0323","MO") THEN
               CALL pol0323_processa()
               LET l_informou_dados = FALSE
            END IF
         ELSE
            ERROR "Informe os par�metros primeiramente."
            NEXT OPTION "Petrom"
         END IF  
      
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa !!!"
         CALL pol0323_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTece ENTER para continuar" FOR CHAR comando
         DATABASE ogix
         LET int_flag = 0
      
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0323

END FUNCTION
 
#-------------------------------#
 FUNCTION pol0323_informa_dados()
#-------------------------------#
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0323
   INITIALIZE mr_tela.* TO NULL
   INITIALIZE ma_tela TO NULL
   LET p_houve_erro = FALSE
   LET m_laudo_exx = FALSE

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG =  FALSE
   INPUT BY NAME mr_tela.*  WITHOUT DEFAULTS  

      BEFORE FIELD num_nf
         CALL pol0323_busca_num_laudo()

      AFTER FIELD num_nf
         IF mr_tela.num_nf IS NOT NULL THEN
            IF pol0323_verifica_nf() = FALSE THEN
               ERROR 'Nota Fisca n�o exise.'
               NEXT FIELD num_nf
            END IF
         END IF
    
      BEFORE FIELD num_om
         IF FGL_LASTKEY() = FGL_KEYVAL("UP") OR
            FGL_LASTKEY() = FGL_KEYVAL("LEFT") THEN
            IF mr_tela.num_nf IS NOT NULL THEN
               NEXT FIELD num_nf 
            END IF
         ELSE 
            IF mr_tela.num_nf IS NOT NULL THEN
               INITIALIZE mr_tela.num_om TO NULL
               DISPLAY BY NAME mr_tela.num_om 
               NEXT FIELD cod_item
            END IF
         END IF
        
      AFTER FIELD num_om 
         IF mr_tela.num_om IS NOT NULL THEN
            IF pol0323_verifica_om() = FALSE THEN
               ERROR "Ordem de Montagem n�o existe."
               NEXT FIELD num_om
            END IF       
         ELSE
            IF FGL_LASTKEY() = FGL_KEYVAL("UP") OR
               FGL_LASTKEY() = FGL_KEYVAL("LEFT") THEN
               NEXT FIELD num_nf 
            ELSE 
               IF mr_tela.num_nf IS NULL THEN
                  ERROR 'Tem que informar Nota Fiscal ou Ordem de Montagem.'
                  NEXT FIELD num_nf 
               END IF   
            END IF   
         END IF

      AFTER FIELD cod_item
         IF FGL_LASTKEY() = FGL_KEYVAL("UP") OR
            FGL_LASTKEY() = FGL_KEYVAL("LEFT") THEN
            IF mr_tela.num_om IS NOT NULL THEN
               NEXT FIELD num_om
            ELSE
               NEXT FIELD num_nf 
            END IF   
         ELSE
            IF mr_tela.cod_item IS NULL THEN
               ERROR "Campo de preenchimento obrigat�rio."
               NEXT FIELD cod_item
            ELSE
               IF pol0323_verifica_item() = FALSE THEN
                  ERROR 'Item n�o cadastrado.'
                  NEXT FIELD cod_item
               ELSE
                  IF pol0323_verifica_item_nf_om() = FALSE THEN
                     ERROR 'Item n�o pertence a OM/NF.'
                     NEXT FIELD cod_item
                  ELSE 
                     IF pol0323_busca_item_petrom('S', mr_tela.cod_item) = FALSE THEN
                        ERROR 'Item n�o cadastrado na tabela ITEM_REFER_PETROM.'
                        NEXT FIELD cod_item
                     END IF 
                  END IF 
               END IF
            END IF     
         END IF     

      AFTER FIELD lote_tanque
      
      IF mr_tela.lote_tanque IS NOT NULL AND 
         mr_tela.lote_tanque <> ' ' THEN
         IF pol0323_verifica_se_tem_resultado(mr_tela.lote_tanque) = FALSE THEN
            ERROR 'Item/Lote n�o cont�m resultados.'
            NEXT FIELD lote_tanque
         END IF 
      ELSE 
         ERROR "Campo de preenchimento obrigat�rio."
         NEXT FIELD lote_tanque 
      END IF

      AFTER FIELD qtd_laudo 
         IF mr_tela.qtd_laudo IS NULL OR
            mr_tela.qtd_laudo = ' ' THEN
            ERROR "Campo de preenchimento obrigat�rio."
            NEXT FIELD qtd_laudo 
         ELSE
            IF pol0323_verifica_qtd_laudo() = FALSE THEN
               NEXT FIELD qtd_laudo 
            END IF
         END IF

      ON KEY (control-z)
         CALL pol0323_popup()
 
    END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0323
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------------#
 FUNCTION pol0323_informa_dados_exxon()
#-------------------------------------#
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0323
   INITIALIZE mr_tela.* TO NULL
   INITIALIZE ma_tela TO NULL
   LET p_houve_erro = FALSE
   LET m_laudo_exx = TRUE
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG =  FALSE
   INPUT BY NAME mr_tela1.*  WITHOUT DEFAULTS

      BEFORE FIELD cod_cliente
         CALL pol0323_busca_num_laudo()

      AFTER FIELD cod_cliente
         IF mr_tela1.cod_cliente IS NOT NULL AND
            mr_tela1.cod_cliente <> ' ' THEN
            IF pol0323_verifica_cliente() = FALSE THEN
               ERROR 'Cliente n�o cadastrado.'
               NEXT FIELD cod_cliente
            END IF
         ELSE
            ERROR "Campo de preenchimento obrigat�rio."
            NEXT FIELD cod_item
         END IF

      AFTER FIELD cod_item
         IF mr_tela1.cod_item IS NULL OR 
            mr_tela1.cod_item = ' ' THEN
            ERROR "Campo de preenchimento obrigat�rio."
            NEXT FIELD cod_item
         ELSE
            IF pol0323_verifica_item_petrom() = FALSE THEN
               ERROR 'Item Petrom n�o cadastrado.'
               NEXT FIELD cod_item
            END IF
         END IF

      AFTER FIELD lote_tanque
      IF mr_tela1.lote_tanque IS NOT NULL AND
         mr_tela1.lote_tanque <> ' ' THEN
         IF pol0323_verifica_se_tem_resultado(mr_tela1.lote_tanque) = FALSE THEN
            ERROR 'Item/Lote n�o cont�m resultados.'
            NEXT FIELD lote_tanque
         END IF
      ELSE
         ERROR "Campo de preenchimento obrigat�rio."
         NEXT FIELD lote_tanque
      END IF
                  
      AFTER FIELD qtd_laudo
         IF mr_tela1.qtd_laudo IS NULL OR
            mr_tela1.qtd_laudo = ' ' THEN
            ERROR "Campo de preenchimento obrigat�rio."
            NEXT FIELD qtd_laudo
         END IF

      ON KEY (control-z)
         CALL pol0323_popup_1()

    END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0323
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE        
   END IF

   RETURN TRUE

END FUNCTION      

#---------------------------------#
 FUNCTION pol0323_busca_num_laudo()
#---------------------------------#
   DEFINE l_num_laudo          DECIMAL(6,0)

   SELECT MAX(num_laudo)
     INTO l_num_laudo
     FROM laudo_mest_petrom 
    WHERE cod_empresa = p_cod_empresa
   IF l_num_laudo IS NULL OR
      l_num_laudo = 0 THEN 
      LET l_num_laudo = 1 
   ELSE
      LET l_num_laudo = l_num_laudo + 1
   END IF

   IF m_laudo_exx THEN
      LET mr_tela1.num_laudo = l_num_laudo
      DISPLAY BY NAME mr_tela1.num_laudo
   ELSE
      LET mr_tela.num_laudo = l_num_laudo
      DISPLAY BY NAME mr_tela.num_laudo
   END IF

END FUNCTION

#----------------------------------# 
 FUNCTION pol0323_verifica_cliente()
#----------------------------------# 
   DEFINE l_nom_cliente         LIKE clientes.nom_cliente

   SELECT nom_cliente
     INTO l_nom_cliente
     FROM clientes
    WHERE cod_cliente = mr_tela1.cod_cliente

   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_nom_cliente TO nom_cliente
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF 

END FUNCTION

#--------------------------------------# 
 FUNCTION pol0323_verifica_item_petrom()
#--------------------------------------# 
   DEFINE l_den_item_petrom           LIKE item_petrom.den_item_petrom

   INITIALIZE m_item_petrom TO NULL

   SELECT den_item_petrom
     INTO l_den_item_petrom
     FROM item_petrom
    WHERE cod_empresa     = p_cod_empresa
      AND cod_item_petrom = mr_tela1.cod_item
 
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_item_petrom TO den_item
      LET m_item_petrom = mr_tela1.cod_item
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF 

END FUNCTION

#-------------------------------#
 FUNCTION pol0323_verifica_item()
#-------------------------------#
   DEFINE l_den_item         LIKE item.den_item

   SELECT den_item
     INTO l_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_tela.cod_item
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_item to den_item
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION           

#-------------------------------------#
 FUNCTION pol0323_verifica_item_nf_om()
#-------------------------------------#
   DEFINE l_cod_item              LIKE item.cod_item

   IF mr_tela.num_nf IS NOT NULL AND
      mr_tela.num_nf <> ' ' THEN
      DECLARE cq_item_nf CURSOR FOR 
       SELECT item
         FROM fat_nf_item
        WHERE empresa           = p_cod_empresa
          AND trans_nota_fiscal = p_trans_nota_fiscal
          AND item              = mr_tela.cod_item
     
      OPEN cq_item_nf
      FETCH cq_item_nf INTO l_cod_item
    
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE
      END IF 
   ELSE
      DECLARE cq_item_nf1 CURSOR FOR 
       SELECT cod_item 
         FROM ordem_montag_item
        WHERE cod_empresa = p_cod_empresa
          AND num_om      = mr_tela.num_om
          AND cod_item    = mr_tela.cod_item
      
      OPEN cq_item_nf1
      FETCH cq_item_nf1 INTO l_cod_item
      
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE
      END IF 
   END IF 
  
   RETURN TRUE 

END FUNCTION

#-------------------------------------------------#
 FUNCTION pol0323_busca_item_petrom(l_tip, l_item)
#-------------------------------------------------#

   DEFINE l_tip     CHAR(01),
          l_item    CHAR(15)
   
   INITIALIZE m_item_petrom TO NULL

     SELECT r.cod_item_petrom
       INTO m_item_petrom
       FROM item_refer_petrom r, item_petrom i
      WHERE r.cod_empresa = p_cod_empresa
        AND r.cod_item    = l_item  
        AND r.cod_empresa = i.cod_empresa
        AND r.cod_item_petrom = i.cod_item_petrom
        AND i.ies_tip_item =  l_tip
        
   IF sqlca.sqlcode <> 0 THEN 
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#--------------------------------------------------------#   
 FUNCTION pol0323_verifica_se_tem_resultado(l_lote_tanque)
#--------------------------------------------------------#   
   
   DEFINE l_lote_tanque           LIKE analise_petrom.lote_tanque,
          l_cont                  INTEGER

     SELECT COUNT(cod_empresa)
       INTO l_cont
       FROM analise_petrom
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = m_item_petrom
        AND lote_tanque = l_lote_tanque 
   
   IF l_cont > 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------------------------------#
FUNCTION pol0323_ve_formula_saida(l_cliente, l_data)#
#---------------------------------------------------#

   DEFINE l_cliente        LIKE clientes.cod_cliente,
          l_data           DATE          

   DEFINE l_teor_agua       LIKE analise_petrom.val_analise,   #8	
          l_pesados         LIKE analise_petrom.val_analise,   #71
          l_alcool_tot      LIKE analise_petrom.val_analise,   #33
          l_n_pentanol      LIKE analise_petrom.val_analise,   #69
          l_isobutanol      LIKE analise_petrom.val_analise,   #36
          l_n_butanol       LIKE analise_petrom.val_analise,   #37
          l_sec_butanol     LIKE analise_petrom.val_analise,   #68
          l_iso_pentanol    LIKE analise_petrom.val_analise,   #70
          l_somatoria_c4_c5 LIKE analise_petrom.val_analise,   #72
          l_val_analise     LIKE analise_petrom.val_analise,
          l_formula         LIKE analise_petrom.val_analise,
          l_msg             VARCHAR(1200)

   LET m_bloq_laudo = 'N'
   LET l_msg = NULL
    
   DECLARE cq_vanalise CURSOR FOR                                  
    SELECT val_analise                                           
      FROM analise_petrom                                        
     WHERE cod_empresa = p_cod_empresa                           
       AND cod_item    = m_item_petrom                           
       AND tip_analise = '8'                                 
       AND lote_tanque = mr_tela.lote_tanque                     
       AND dat_analise = l_data                              
     ORDER BY hor_analise DESC                                   
                                                                 
   FOREACH cq_vanalise INTO l_val_analise                              
                                                                 
      IF STATUS <> 0 THEN                                        
         CALL log003_err_sql('FOREACH','cq_vanalise')  
         RETURN FALSE                                 
      ELSE                                                       
         LET l_teor_agua = l_val_analise                             
      END IF                                                     
                                                                 
      EXIT FOREACH                                               
                                                                 
   END FOREACH                                                   
   
   FREE cq_vanalise

   IF l_teor_agua IS NULL THEN
      LET l_msg = l_msg CLIPPED, '- TEOR DE AGUA n�o encontrado na tabela analise_petrom\n'
   END IF
      
   DECLARE cq_vanalise CURSOR FOR                                  
    SELECT val_analise                                           
      FROM analise_petrom                                        
     WHERE cod_empresa = p_cod_empresa                           
       AND cod_item    = m_item_petrom                           
       AND tip_analise = '71'                                 
       AND lote_tanque = mr_tela.lote_tanque                     
       AND dat_analise = l_data                              
     ORDER BY hor_analise DESC                                   
                                                                 
   FOREACH cq_vanalise INTO l_val_analise                              
                                                                 
      IF STATUS <> 0 THEN                                        
         CALL log003_err_sql('FOREACH','cq_vanalise')  
         RETURN FALSE                                 
      ELSE                                                       
         LET l_pesados = l_val_analise                             
      END IF                                                     
                                                                 
      EXIT FOREACH                                               
                                                                 
   END FOREACH                                                   
   
   FREE cq_vanalise
   
   IF l_pesados IS NULL THEN
      LET l_msg = l_msg CLIPPED, '- PESADOS n�o encontrado na tabela analise_petrom\n'
   END IF

   DECLARE cq_vanalise CURSOR FOR                                  
    SELECT val_analise                                           
      FROM analise_petrom                                        
     WHERE cod_empresa = p_cod_empresa                           
       AND cod_item    = m_item_petrom                           
       AND tip_analise = '33'                                 
       AND lote_tanque = mr_tela.lote_tanque                     
       AND dat_analise = l_data                              
     ORDER BY hor_analise DESC                                   
                                                                 
   FOREACH cq_vanalise INTO l_val_analise                              
                                                                 
      IF STATUS <> 0 THEN                                        
         CALL log003_err_sql('FOREACH','cq_vanalise')  
         RETURN FALSE                                 
      ELSE                                                       
         LET l_alcool_tot = l_val_analise                             
      END IF                                                     
                                                                 
      EXIT FOREACH                                               
                                                                 
   END FOREACH                                                   
   
   FREE cq_vanalise
   
   IF l_alcool_tot IS NULL THEN
      LET l_msg = l_msg CLIPPED, '- ALCOOL TOTAL/PUREZA n�o encontrado na tabela analise_petrom\n'
   END IF

   DECLARE cq_vanalise CURSOR FOR                                  
    SELECT val_analise                                           
      FROM analise_petrom                                        
     WHERE cod_empresa = p_cod_empresa                           
       AND cod_item    = m_item_petrom                           
       AND tip_analise = '69'                                 
       AND lote_tanque = mr_tela.lote_tanque                     
       AND dat_analise = l_data                              
     ORDER BY hor_analise DESC                                   
                                                                 
   FOREACH cq_vanalise INTO l_val_analise                              
                                                                 
      IF STATUS <> 0 THEN                                        
         CALL log003_err_sql('FOREACH','cq_vanalise')  
         RETURN FALSE                                 
      ELSE                                                       
         LET l_n_pentanol = l_val_analise                             
      END IF                                                     
                                                                 
      EXIT FOREACH                                               
                                                                 
   END FOREACH                                                   
   
   FREE cq_vanalise
   
   IF l_n_pentanol IS NULL THEN
      LET l_msg = l_msg CLIPPED, '- N-PENTANOL n�o encontrado na tabela analise_petrom\n'
   END IF

   DECLARE cq_vanalise CURSOR FOR                                  
    SELECT val_analise                                           
      FROM analise_petrom                                        
     WHERE cod_empresa = p_cod_empresa                           
       AND cod_item    = m_item_petrom                           
       AND tip_analise = '36'                                 
       AND lote_tanque = mr_tela.lote_tanque                     
       AND dat_analise = l_data                              
     ORDER BY hor_analise DESC                                   
                                                                 
   FOREACH cq_vanalise INTO l_val_analise                              
                                                                 
      IF STATUS <> 0 THEN                                        
         CALL log003_err_sql('FOREACH','cq_vanalise')  
         RETURN FALSE                                 
      ELSE                                                       
         LET l_isobutanol = l_val_analise                             
      END IF                                                     
                                                                 
      EXIT FOREACH                                               
                                                                 
   END FOREACH                                                   
   
   FREE cq_vanalise
   
   IF l_isobutanol IS NULL THEN
      LET l_msg = l_msg CLIPPED, '- ISOBUTANOL n�o encontrado na tabela analise_petrom\n'
   END IF

   DECLARE cq_vanalise CURSOR FOR                                  
    SELECT val_analise                                           
      FROM analise_petrom                                        
     WHERE cod_empresa = p_cod_empresa                           
       AND cod_item    = m_item_petrom                           
       AND tip_analise = '37'                                 
       AND lote_tanque = mr_tela.lote_tanque                     
       AND dat_analise = l_data                              
     ORDER BY hor_analise DESC                                   
                                                                 
   FOREACH cq_vanalise INTO l_val_analise                              
                                                                 
      IF STATUS <> 0 THEN                                        
         CALL log003_err_sql('FOREACH','cq_vanalise')  
         RETURN FALSE                                 
      ELSE                                                       
         LET l_n_butanol = l_val_analise                             
      END IF                                                     
                                                                 
      EXIT FOREACH                                               
                                                                 
   END FOREACH                                                   
   
   FREE cq_vanalise
   
   IF l_n_butanol IS NULL THEN
      LET l_msg = l_msg CLIPPED, '- N-BUTANOL n�o encontrado na tabela analise_petrom\n'
   END IF

   DECLARE cq_vanalise CURSOR FOR                                  
    SELECT val_analise                                           
      FROM analise_petrom                                        
     WHERE cod_empresa = p_cod_empresa                           
       AND cod_item    = m_item_petrom                           
       AND tip_analise = '68'                                 
       AND lote_tanque = mr_tela.lote_tanque                     
       AND dat_analise = l_data                              
     ORDER BY hor_analise DESC                                   
                                                                 
   FOREACH cq_vanalise INTO l_val_analise                              
                                                                 
      IF STATUS <> 0 THEN                                        
         CALL log003_err_sql('FOREACH','cq_vanalise')  
         RETURN FALSE                                 
      ELSE                                                       
         LET l_sec_butanol = l_val_analise                             
      END IF                                                     
                                                                 
      EXIT FOREACH                                               
                                                                 
   END FOREACH                                                   
   
   FREE cq_vanalise
   
   IF l_sec_butanol IS NULL THEN
      LET l_msg = l_msg CLIPPED, '- SEC BUTANOL n�o encontrado na tabela analise_petrom\n'
   END IF

   DECLARE cq_vanalise CURSOR FOR                                  
    SELECT val_analise                                           
      FROM analise_petrom                                        
     WHERE cod_empresa = p_cod_empresa                           
       AND cod_item    = m_item_petrom                           
       AND tip_analise = '70'                                 
       AND lote_tanque = mr_tela.lote_tanque                     
       AND dat_analise = l_data                              
     ORDER BY hor_analise DESC                                   
                                                                 
   FOREACH cq_vanalise INTO l_val_analise                              
                                                                 
      IF STATUS <> 0 THEN                                        
         CALL log003_err_sql('FOREACH','cq_vanalise')  
         RETURN FALSE                                 
      ELSE                                                       
         LET l_iso_pentanol = l_val_analise                             
      END IF                                                     
                                                                 
      EXIT FOREACH                                               
                                                                 
   END FOREACH                                                   
   
   FREE cq_vanalise
   
   IF l_iso_pentanol IS NULL THEN
      LET l_msg = l_msg CLIPPED, '- ISO PENTANOL n�o encontrado na tabela analise_petrom\n'
   END IF

   DECLARE cq_vanalise CURSOR FOR                                  
    SELECT val_analise                                           
      FROM analise_petrom                                        
     WHERE cod_empresa = p_cod_empresa                           
       AND cod_item    = m_item_petrom                           
       AND tip_analise = '72'                                 
       AND lote_tanque = mr_tela.lote_tanque                     
       AND dat_analise = l_data                              
     ORDER BY hor_analise DESC                                   
                                                                 
   FOREACH cq_vanalise INTO l_val_analise                              
                                                                 
      IF STATUS <> 0 THEN                                        
         CALL log003_err_sql('FOREACH','cq_vanalise')  
         RETURN FALSE                                 
      ELSE                                                       
         LET l_somatoria_c4_c5 = l_val_analise                             
      END IF                                                     
                                                                 
      EXIT FOREACH                                               
                                                                 
   END FOREACH                                                   
   
   FREE cq_vanalise
   
   IF l_somatoria_c4_c5 IS NULL THEN
      LET l_msg = l_msg CLIPPED, '- SOMATORIA C4 + C5 n�o encontrado na tabela analise_petrom\n'
   END IF
   
   IF l_msg IS NOT NULL THEN
      CALL log0030_mensagem(l_msg,'info')
      LET m_bloq_laudo = 'S'
      RETURN TRUE
   END IF

   LET l_formula = 100 - l_teor_agua - l_pesados
   
   IF l_formula <> l_alcool_tot THEN
      LET m_bloq_laudo = 'S'
      LET mr_tela.texto_1 = '100 - TEOR DE AGUA + PESADOS DIFERENTE DE ALCOOL TOTAL/PUREZA'
   END IF

   LET l_formula = l_n_pentanol + l_isobutanol + l_n_butanol + l_sec_butanol + l_iso_pentanol

   IF l_formula <> l_somatoria_c4_c5 THEN
      LET m_bloq_laudo = 'S'
      LET mr_tela.texto_2 = 'N-PENTANOL + ISOBUTANOL + N-BUTANOL + SEC BUTANOL + ISO PENTANOL <> SOMATORIA C4 + C5'
   END IF
   
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol0323_ve_formula()#
#----------------------------#

   DEFINE l_teor_agua       LIKE analise_petrom.val_analise,   
          l_pesados         LIKE analise_petrom.val_analise,   
          l_alcool_tot      LIKE analise_petrom.val_analise,   
          l_n_pentanol      LIKE analise_petrom.val_analise,   
          l_isobutanol      LIKE analise_petrom.val_analise,   
          l_n_butanol       LIKE analise_petrom.val_analise,   
          l_sec_butanol     LIKE analise_petrom.val_analise,   
          l_iso_pentanol    LIKE analise_petrom.val_analise,   
          l_somatoria_c4_c5 LIKE analise_petrom.val_analise,   
          l_formula         LIKE analise_petrom.val_analise,
          l_val_analise     LIKE laudo_item_petrom.resultado,
          l_tip_analise     LIKE laudo_item_petrom.tip_analise,
          l_tipo            VARCHAR(02)

   LET m_bloq_laudo = 'N'

   DECLARE cq_formula CURSOR FOR
    SELECT tip_analise,
           resultado
      FROM laudo_item_petrom
     WHERE cod_empresa = p_cod_empresa
       AND num_laudo = mr_nfe.num_laudo
    FOREACH cq_formula INTO l_tip_analise, l_val_analise

      IF STATUS <> 0 THEN                                        
         CALL log003_err_sql('FOREACH','cq_formula')  
         RETURN FALSE                                 
      END IF 
      
      LET l_tipo = l_tip_analise USING '<<'
   
      CASE l_tipo
           WHEN '8'  LET l_teor_agua = l_val_analise       
           WHEN '71' LET l_pesados = l_val_analise         
           WHEN '33' LET l_alcool_tot = l_val_analise      
           WHEN '34' LET l_n_pentanol = l_val_analise      
           WHEN '36' LET l_isobutanol = l_val_analise      
           WHEN '37' LET l_n_butanol = l_val_analise       
           WHEN '68' LET l_sec_butanol = l_val_analise     
           WHEN '70' LET l_iso_pentanol = l_val_analise    
           WHEN '72' LET l_somatoria_c4_c5 = l_val_analise        
      END CASE
    
    END FOREACH

   LET l_formula = 100 - l_teor_agua - l_pesados
   
   IF l_formula <> l_alcool_tot THEN
      LET m_bloq_laudo = 'S'
      LET mr_tela.texto_1 = '100 - TEOR DE AGUA + PESADOS DIFERENTE DE ALCOOL TOTAL/PUREZA'
   END IF

   LET l_formula = l_n_pentanol + l_isobutanol + l_n_butanol + l_sec_butanol + l_iso_pentanol

   IF l_formula <> l_somatoria_c4_c5 THEN
      LET m_bloq_laudo = 'S'
      LET mr_tela.texto_2 = 'N-PENTANOL + ISOBUTANOL + N-BUTANOL + SEC BUTANOL + ISO PENTANOL <> SOMATORIA C4 + C5'
   END IF
   
   RETURN TRUE

END FUNCTION   


    
#----------------------------------------------#   
 FUNCTION pol0323_ve_validade(l_cliente,l_item)#
#----------------------------------------------#   
   
   DEFINE l_cliente        LIKE clientes.cod_cliente,
          l_item           LIKE item.cod_item,
          l_retorno        CHAR(01),
          l_qtd_dias       INTEGER,
          l_ies_indeterminada CHAR(01)
          
   LET l_retorno = 'N'
   LET l_qtd_dias = NULL
   
   SELECT qtd_dias
     INTO l_qtd_dias
     FROM cliente_item_455 
    WHERE cod_cliente = l_cliente
      AND cod_item = l_item
   
   IF STATUS = 100 THEN      
      SELECT qtd_dias
        INTO l_qtd_dias
        FROM cliente_item_455 
       WHERE cod_cliente = l_cliente
         AND cod_item IS NULL
      
      IF STATUS = 100 THEN
         LET l_qtd_dias = NULL
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','cliente_item_455')
            RETURN l_retorno
         END IF
      END IF
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cliente_item_455')
         RETURN l_retorno
      END IF
   END IF
   
   IF l_qtd_dias IS NULL THEN
      SELECT qtd_dia_validade, ies_indeterminada
        INTO l_qtd_dias, l_ies_indeterminada
        FROM item_petrom
       WHERE cod_empresa = p_cod_empresa
         AND cod_item_petrom = m_item_petrom

      IF STATUS <> 0 AND STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','item_petrom')
      END IF
   END IF
   
   IF l_ies_indeterminada = 'S' OR l_qtd_dias IS NULL THEN  
      RETURN l_retorno
   END IF
             
   SELECT dat_fabricacao
     INTO p_dat_fabric
     FROM validade_lote_455
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = m_item_petrom
      AND num_lote    = mr_tela.lote_tanque
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','validade_lote_455')
      RETURN l_retorno
   END IF
   
   IF p_dat_fabric IS NOT NULL THEN
      LET p_dat_valid = p_dat_fabric + l_qtd_dias
      IF p_dat_valid < TODAY THEN
         LET l_retorno = 'S'
      END IF
   END IF
   
   RETURN l_retorno
   
END FUNCTION

#-----------------------------#
 FUNCTION pol0323_verifica_nf()
#-----------------------------#
   DEFINE l_nom_cliente        LIKE clientes.nom_cliente
   
   LET p_count = 0
   
   DECLARE cq_verifica_nf CURSOR FOR
          
   SELECT a.cliente, a.trans_nota_fiscal, b.nom_cliente
     FROM fat_nf_mestre a, clientes b
    WHERE a.empresa     = p_cod_empresa
      AND a.nota_fiscal = mr_tela.num_nf
      AND a.tip_nota_fiscal = 'FATPRDSV'
      AND a.cliente     = b.cod_cliente
   
   FOREACH cq_verifica_nf
      INTO mr_tela1.cod_cliente,
           p_trans_nota_fiscal,
           l_nom_cliente
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo", "Cursor: cq_verifica_nf")
         RETURN FALSE
      END IF
      
      LET p_count = 1
      
      EXIT FOREACH
      
   END FOREACH
   
   IF p_count = 0 THEN
      RETURN FALSE
   END IF
   
   DISPLAY mr_tela1.cod_cliente TO cod_cliente
   DISPLAY l_nom_cliente TO nom_cliente
   
   RETURN TRUE
   
END FUNCTION       

#-----------------------------#
 FUNCTION pol0323_verifica_om()
#-----------------------------#
   DEFINE l_nom_cliente        LIKE clientes.nom_cliente
   
     SELECT UNIQUE p.cod_cliente, c.nom_cliente
       INTO mr_tela1.cod_cliente, l_nom_cliente
       FROM ordem_montag_item o, pedidos p, clientes c
      WHERE o.cod_empresa = p.cod_empresa
        AND o.num_pedido  = p.num_pedido
        AND o.num_om      = mr_tela.num_om
        AND o.cod_empresa = p_cod_empresa
        AND p.cod_cliente = c.cod_cliente
   IF sqlca.sqlcode = 0 THEN
      DISPLAY mr_tela1.cod_cliente TO cod_cliente
      DISPLAY l_nom_cliente TO nom_cliente
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION  

#------------------------------------# 
 FUNCTION pol0323_verifica_qtd_laudo()
#------------------------------------# 
   DEFINE l_qtd_item         DECIMAL(15,3),
          l_qtd_laudo        LIKE laudo_mest_petrom.qtd_laudo

   IF mr_tela.num_nf IS NOT NULL AND
      mr_tela.num_nf <> ' ' THEN
      SELECT SUM(qtd_item)
        INTO l_qtd_item
        FROM fat_nf_item
       WHERE empresa           = p_cod_empresa
         AND trans_nota_fiscal = p_trans_nota_fiscal
         AND item              = mr_tela.cod_item
      IF l_qtd_item IS NULL OR
         l_qtd_item = 0 THEN
         ERROR "Item sem quantidade na Nota Fiscal." 
         RETURN FALSE
      END IF 
      
      SELECT SUM(qtd_laudo)
        INTO l_qtd_laudo
        FROM laudo_mest_petrom
       WHERE cod_empresa = p_cod_empresa
         AND num_nff     = mr_tela.num_nf
         AND cod_item    = mr_tela.cod_item
      IF l_qtd_laudo IS NULL THEN
         LET l_qtd_laudo = 0
      END IF 
   ELSE
      SELECT SUM(qtd_reservada)
        INTO l_qtd_item
        FROM ordem_montag_item
       WHERE cod_empresa = p_cod_empresa
         AND num_om      = mr_tela.num_om 
         AND cod_item    = mr_tela.cod_item
      IF l_qtd_item IS NULL OR
         l_qtd_item = 0 THEN
         ERROR "Item sem quantidade na Ordem de Montagem." 
         RETURN FALSE
      END IF 
      
      SELECT SUM(qtd_laudo)
        INTO l_qtd_laudo
        FROM laudo_mest_petrom
       WHERE cod_empresa = p_cod_empresa
         AND num_om      = mr_tela.num_om
         AND cod_item    = mr_tela.cod_item
      IF l_qtd_laudo IS NULL THEN
         LET l_qtd_laudo = 0
      END IF 
   END IF       

   IF l_qtd_item < mr_tela.qtd_laudo THEN
      ERROR "Quantidade do Laudo maior que a Quantidade da OM/NF."
      # ERROR "Quantidade do Laudo ",l_qtd_laudo, " QTDE NF/OM ",l_qtd_item
      RETURN FALSE
   END IF 

   IF l_qtd_item >= (mr_tela.qtd_laudo + l_qtd_laudo) THEN
      RETURN TRUE
   ELSE
      ERROR "Quantidade do Laudo maior que o Saldo Restante da OM/NF."
      # ERROR "Quantidade saldo ",l_qtd_laudo, " QTDE NF/OM ",l_qtd_item
      RETURN FALSE
   END IF 

END FUNCTION

#---------------------------------------#
 FUNCTION pol0323_verifica_se_eh_tanque()
#---------------------------------------#
   INITIALIZE m_ies_tanque TO NULL

   DECLARE cq_tanque CURSOR FOR  
    SELECT UNIQUE ies_tanque
      FROM especific_petrom
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = m_item_petrom
      
      OPEN cq_tanque
     FETCH cq_tanque INTO m_ies_tanque

     CLOSE cq_tanque 
     
     IF m_ies_tanque = 'S' THEN
        RETURN TRUE
     ELSE
        RETURN FALSE
     END IF

END FUNCTION

#------------------------------------#
 FUNCTION pol0323_busca_num_pa(l_lote)
#------------------------------------#
   
   DEFINE l_lote         CHAR(15)
   DEFINE l_ind          SMALLINT
   
   LET l_ind = 1

   DECLARE cq_num_pa CURSOR FOR 
    SELECT DISTINCT num_pa
      FROM analise_petrom
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = m_item_petrom
       AND lote_tanque = l_lote
   
   FOREACH cq_num_pa INTO ma_tela[l_ind].num_pa
      LET l_ind = l_ind + 1
   END FOREACH

   IF l_ind > 1 THEN
      LET l_ind = l_ind - 1
   END IF

   CALL SET_COUNT(l_ind)

   IF l_ind > 10 THEN
      DISPLAY ARRAY ma_tela TO s_itens.*
   ELSE
      INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF                

END FUNCTION

#-----------------------------#
 FUNCTION pol0323_informa_pas() 
#-----------------------------#
   DEFINE p_funcao           CHAR(11),
          l_ind              SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0323

   INITIALIZE ma_num_pa TO NULL

   LET m_ind = 0
   LET INT_FLAG =  FALSE
 
   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*

      BEFORE FIELD ies_calcula_media 
         LET pa_curr   = ARR_CURR()
         LET sc_curr   = SCR_LINE()

      AFTER FIELD ies_calcula_media
         IF ma_tela[pa_curr].ies_calcula_media IS NOT NULL AND
            ma_tela[pa_curr].ies_calcula_media <> ' ' THEN
            IF ma_tela[pa_curr].ies_calcula_media <> 'S' AND
               ma_tela[pa_curr].ies_calcula_media <> 'N' THEN
               ERROR 'Valor inv�lido.'
               NEXT FIELD ies_calcula_media
            ELSE
               IF ma_tela[pa_curr].ies_calcula_media = 'S' THEN
                  IF pol0323_verifica_especificacao_pa() = FALSE THEN
                     ERROR 'PA est� fora da especifica��o no Tipo de An�lise ',
                            m_den_analise
                     LET ma_tela[pa_curr].ies_calcula_media = 'N'
                     NEXT FIELD ies_calcula_media
                  END IF
               END IF
            END IF
         END IF

    {  ON KEY (Control-z)
         CALL pol0323_popup_pa() }

      AFTER INPUT
         FOR l_ind = 1 TO 50 
            IF ma_tela[l_ind].ies_calcula_media = 'S' THEN
               LET m_ind = m_ind + 1 
               LET ma_num_pa[m_ind].num_pa = ma_tela[l_ind].num_pa  
            END IF 
         END FOR
 
   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0323
   
   IF INT_FLAG THEN
      CLEAR FORM
      RETURN FALSE
   ELSE
      RETURN TRUE 
   END IF

END FUNCTION

#-------------------------------------------#
 FUNCTION pol0323_verifica_especificacao_pa()
#-------------------------------------------#
   DEFINE l_cod_cliente       LIKE clientes.cod_cliente,
          l_bloqueia_laudo    LIKE par_laudo_petrom.bloqueia_laudo,
          l_tip_analise       LIKE it_analise_petrom.tip_analise,
          l_tip_analise_2     LIKE it_analise_petrom.tip_analise,
          l_media_final       DECIMAL(10,4),
          l_ind               SMALLINT,
          l_val_especif_de    LIKE especific_petrom.val_especif_de,
          l_val_especif_ate   LIKE especific_petrom.val_especif_ate,
          l_val_analise       LIKE analise_petrom.val_analise,
          l_variacao          LIKE especific_petrom.variacao,
          l_metodo            LIKE especific_petrom.metodo,
          l_val_especif_de_2  LIKE especific_petrom.val_especif_de,
          l_val_especif_ate_2 LIKE especific_petrom.val_especif_ate,
          l_variacao_2        LIKE especific_petrom.variacao,
          l_tipo_valor_2      CHAR(2),
          l_metodo_2          LIKE especific_petrom.metodo,
          l_pa_fora_especific LIKE par_laudo_petrom.pa_fora_especif,
          l_tipo_valor        CHAR(2),
          l_tem_cli           SMALLINT,
          sql_stmt            CHAR(500),
          l_cod_empresa       LIKE empresa.cod_empresa  
  
   IF m_laudo_exx = FALSE THEN 
      IF mr_tela.num_nf IS NOT NULL THEN
         
         DECLARE cq_fat_nf_mestre CURSOR FOR
         
          SELECT cliente
            FROM fat_nf_mestre
           WHERE empresa     = p_cod_empresa
             AND nota_fiscal = mr_tela.num_nf
          
         FOREACH cq_fat_nf_mestre
            INTO l_cod_cliente
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql("Lendo", "Cursor: cq_fat_nf_mestre")
               RETURN FALSE
            END IF
            
            EXIT FOREACH
            
         END FOREACH
            
      ELSE
           SELECT UNIQUE p.cod_cliente
             INTO l_cod_cliente
             FROM ordem_montag_item o, pedidos p
            WHERE o.cod_empresa = p.cod_empresa
              AND o.num_pedido  = p.num_pedido
              AND o.num_om      = mr_tela.num_om
              AND o.cod_empresa = p_cod_empresa
      END IF
   ELSE
      LET l_cod_cliente = mr_tela1.cod_cliente
      LET mr_tela.lote_tanque = mr_tela1.lote_tanque
   END IF

   DECLARE cq_especif_pa CURSOR FOR
    SELECT pa_fora_especif
      FROM par_laudo_petrom
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = m_item_petrom
       AND cod_cliente = l_cod_cliente   
 
      OPEN cq_especif_pa
     FETCH cq_especif_pa INTO l_pa_fora_especific
    
   IF sqlca.sqlcode <> 0 THEN
      DECLARE cq_especif_pa1 CURSOR FOR
       SELECT pa_fora_especif
         FROM par_laudo_petrom
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = m_item_petrom
          AND cod_cliente IS NULL 

         OPEN cq_especif_pa1
        FETCH cq_especif_pa1 INTO l_pa_fora_especific
        CLOSE cq_especif_pa1
   END IF                   

   CLOSE cq_especif_pa
   INITIALIZE m_den_analise TO NULL  
 
   IF l_pa_fora_especific = 'S' THEN 
      RETURN TRUE
   ELSE
   
      DECLARE cq_param_2 CURSOR FOR
       SELECT cod_empresa 
         FROM par_laudo_petrom
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = m_item_petrom
          AND cod_cliente = l_cod_cliente

         OPEN cq_param_2
        FETCH cq_param_2 INTO l_cod_empresa

      IF SQLCA.sqlcode = 0 THEN
         LET l_tem_cli = TRUE
      ELSE
         LET l_tem_cli = FALSE
      END IF

      LET sql_stmt =      
         " SELECT UNIQUE a.tip_analise ",
         "   FROM par_laudo_petrom a "
      
      LET sql_stmt = sql_stmt CLIPPED, 
         "  WHERE a.cod_empresa = '",p_cod_empresa,"'",
         "    AND a.cod_item    = '",m_item_petrom,"'"
         
      IF l_tem_cli THEN   
         LET sql_stmt = sql_stmt CLIPPED, "    AND a.cod_cliente = '",l_cod_cliente,"'"                      
      ELSE
         LET sql_stmt = sql_stmt CLIPPED, "    AND a.cod_cliente IS NULL "    
      END IF   

      LET sql_stmt = sql_stmt CLIPPED, "   ORDER BY a.tip_analise "
         
      PREPARE var_query_2 FROM sql_stmt   
      DECLARE cq_tip_ana_1 SCROLL CURSOR WITH HOLD FOR var_query_2
    
      FOREACH cq_tip_ana_1 INTO l_tip_analise_2
      
         DECLARE cq_verifica_pa CURSOR FOR
          SELECT a.tip_analise, a.val_especif_de, a.val_especif_ate,
                 a.tipo_valor, a.variacao, a.metodo, b.den_analise
            FROM especific_petrom a, it_analise_petrom b
           WHERE a.cod_empresa = p_cod_empresa
             AND a.cod_item    = m_item_petrom
             AND a.cod_cliente IS NULL 
             AND a.cod_empresa = b.cod_empresa
             AND a.tip_analise = b.tip_analise
             AND a.tip_analise = l_tip_analise_2
   
         FOREACH cq_verifica_pa INTO l_tip_analise,
                                     l_val_especif_de,
                                     l_val_especif_ate,
                                     l_tipo_valor,
                                     l_variacao,
                                     l_metodo,
                                     m_den_analise
   
            SELECT a.val_especif_de, a.val_especif_ate,
                   a.tipo_valor, a.variacao, a.metodo
              INTO l_val_especif_de_2,
                   l_val_especif_ate_2,
                   l_tipo_valor_2,
                   l_variacao_2,
                   l_metodo_2
              FROM especific_petrom a
             WHERE a.cod_empresa = p_cod_empresa
               AND a.cod_item    = m_item_petrom
               AND a.cod_cliente = l_cod_cliente
               AND a.tip_analise = l_tip_analise
            IF sqlca.sqlcode = 0 THEN
               LET l_val_especif_de  = l_val_especif_de_2
               LET l_val_especif_ate = l_val_especif_ate_2
               LET l_tipo_valor      = l_tipo_valor_2
               LET l_variacao        = l_variacao_2
               LET l_metodo          = l_metodo_2
            END IF
       
            SELECT val_analise
              INTO l_media_final
              FROM analise_petrom
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = m_item_petrom
               AND tip_analise = l_tip_analise
               AND lote_tanque = mr_tela.lote_tanque
               AND num_pa      = ma_tela[pa_curr].num_pa
            IF sqlca.sqlcode <> 0 THEN
               CONTINUE FOREACH
            END IF
   
            IF l_val_especif_de = l_val_especif_ate THEN
               IF l_variacao IS NOT NULL AND           
                  l_variacao <> '0' THEN
                  LET l_val_especif_de  = l_val_especif_de - l_variacao
                  LET l_val_especif_ate = l_val_especif_ate + l_variacao
                  IF l_media_final >= l_val_especif_de AND
                     l_media_final <= l_val_especif_ate THEN
                  ELSE
                     RETURN FALSE
                  END IF
               ELSE
                  IF l_tipo_valor = '>' THEN
                     IF l_media_final <= l_val_especif_de THEN
                        RETURN FALSE
                     END IF
                  ELSE
                     IF l_tipo_valor = '>=' THEN
                        IF l_media_final < l_val_especif_de THEN
                           RETURN FALSE
                        END IF
                     ELSE
                        IF l_tipo_valor = '<=' THEN
                           IF l_media_final > l_val_especif_de THEN
                              RETURN FALSE
                           END IF
                        ELSE
                           IF l_tipo_valor = '<' THEN
                              IF l_media_final >= l_val_especif_de THEN
                                 RETURN FALSE
                              END IF
                           ELSE
                              IF l_tipo_valor = '<>' THEN
                                 IF l_media_final = l_val_especif_de THEN
                                    RETURN FALSE
                                 END IF
                              END IF     
                           END IF
                        END IF
                     END IF
                  END IF
               END IF
            ELSE
               IF l_media_final < l_val_especif_de OR
                  l_media_final > l_val_especif_ate THEN
                  RETURN FALSE
               END IF
            END IF                    
         END FOREACH  
      END FOREACH     
   END IF

   RETURN TRUE

END FUNCTION
{
#--------------------------#
 FUNCTION pol0323_popup_pa()
#--------------------------#
   DEFINE la_tela ARRAY[50] OF RECORD 
      den_analise              LIKE it_analise_petrom.den_analise,
      val_especif_de           LIKE especific_petrom.val_especif_de,
      val_especif_ate          LIKE especific_petrom.val_especif_ate,
      val_analise              LIKE analise_petrom.val_analise,
      pa_fora                  CHAR(1)
                  END RECORD        

   DEFINE l_cod_cliente        LIKE clientes.cod_cliente,
          l_ind                SMALLINT,
          l_tip_analise        LIKE it_analise_petrom.tip_analise,
          l_variacao           LIKE especific_petrom.variacao,
          l_tipo_valor         LIKE especific_petrom.tipo_valor 

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol03231") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol03231 AT 6,6 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)      

   LET l_ind = 1

   IF m_laudo_exx = FALSE THEN
      IF mr_tela.num_nf IS NOT NULL THEN
         SELECT cliente
           INTO l_cod_cliente
           FROM fat_nf_mestre
          WHERE empresa     = p_cod_empresa
            AND nota_fiscal = mr_tela.num_nf
      ELSE
           SELECT UNIQUE p.cod_cliente
             INTO l_cod_cliente
             FROM ordem_montag_item o, pedidos p
            WHERE o.cod_empresa = p.cod_empresa
              AND o.num_pedido  = p.num_pedido
              AND o.num_om      = mr_tela.num_om
              AND o.cod_empresa = p_cod_empresa
      END IF                                 
   ELSE
      LET l_cod_cliente = mr_tela1.cod_cliente
      LET mr_tela.lote_tanque = mr_tela1.lote_tanque
   END IF 

   DECLARE cq_popup CURSOR FOR
    SELECT tip_analise, val_analise
      FROM analise_petrom
     WHERE cod_empresa = p_cod_empresa
       AND num_pa      = ma_tela[pa_curr].num_pa
       AND cod_item    = m_item_petrom
       AND lote_tanque = mr_tela.lote_tanque
       AND val_analise > 0
   
   FOREACH cq_popup INTO l_tip_analise,
                         la_tela[l_ind].val_analise
                         
      SELECT den_analise
        INTO la_tela[l_ind].den_analise
        FROM it_analise_petrom
       WHERE cod_empresa = p_cod_empresa
         AND tip_analise = l_tip_analise
 
      SELECT val_especif_de, val_especif_ate, tipo_valor, variacao
        INTO la_tela[l_ind].val_especif_de,
             la_tela[l_ind].val_especif_ate,
             l_tipo_valor,
             l_variacao
        FROM especific_petrom
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = m_item_petrom
         AND cod_cliente = l_cod_cliente
         AND tip_analise = l_tip_analise 
      IF sqlca.sqlcode <> 0 THEN
         SELECT val_especif_de, val_especif_ate, tipo_valor, variacao
           INTO la_tela[l_ind].val_especif_de,
                la_tela[l_ind].val_especif_ate,
                l_tipo_valor,
                l_variacao
           FROM especific_petrom
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = m_item_petrom
            AND cod_cliente IS NULL 
            AND tip_analise = l_tip_analise 
      END IF 

      IF la_tela[l_ind].val_especif_de = la_tela[l_ind].val_especif_ate THEN
         IF l_variacao IS NOT NULL AND
            l_variacao <> '0' THEN
            LET la_tela[l_ind].val_especif_de = la_tela[l_ind].val_especif_de - 
                                                l_variacao
            LET la_tela[l_ind].val_especif_ate = la_tela[l_ind].val_especif_ate 
                                                 + l_variacao
            IF la_tela[l_ind].val_analise >= la_tela[l_ind].val_especif_de AND
               la_tela[l_ind].val_analise <= la_tela[l_ind].val_especif_ate THEN
            ELSE
               LET la_tela[l_ind].pa_fora = '*' 
            END IF
         ELSE
            IF l_tipo_valor = '>' THEN
               IF la_tela[l_ind].val_analise <= 
                  la_tela[l_ind].val_especif_de THEN
                  LET la_tela[l_ind].pa_fora = '*' 
               END IF
            ELSE
               IF l_tipo_valor = '>=' THEN
                  IF la_tela[l_ind].val_analise < 
                     la_tela[l_ind].val_especif_de THEN
                     LET la_tela[l_ind].pa_fora = '*' 
                  END IF
               ELSE
                  IF l_tipo_valor = '<=' THEN
                     IF la_tela[l_ind].val_analise > 
                        la_tela[l_ind].val_especif_de THEN
                        LET la_tela[l_ind].pa_fora = '*' 
                     END IF
                  ELSE
                     IF l_tipo_valor = '<' THEN
                        IF la_tela[l_ind].val_analise >= 
                           la_tela[l_ind].val_especif_de THEN
                           LET la_tela[l_ind].pa_fora = '*' 
                        END IF
                     ELSE
                        IF l_tipo_valor = '<>' THEN
                           IF la_tela[l_ind].val_analise = 
                              la_tela[l_ind].val_especif_de THEN
                              LET la_tela[l_ind].pa_fora = '*' 
                           END IF
                        END IF
                     END IF
                  END IF
               END IF
            END IF
         END IF
      ELSE
         IF la_tela[l_ind].val_analise < la_tela[l_ind].val_especif_de OR 
            la_tela[l_ind].val_analise > la_tela[l_ind].val_especif_ate THEN
            LET la_tela[l_ind].pa_fora = '*' 
         END IF                       
      END IF

      LET l_ind = l_ind + 1

   END FOREACH

   IF l_ind > 1 THEN 
      LET l_ind = l_ind - 1
   END IF
   
   CALL SET_COUNT(l_ind)
   
   DISPLAY ARRAY la_tela TO s_pa.*
   END DISPLAY

   CLOSE WINDOW w_pol03231
   CURRENT WINDOW IS w_pol0323
      
END FUNCTION
}
#--------------------------#
 FUNCTION pol0323_processa()
#--------------------------#
   DEFINE l_cont                SMALLINT,
          l_cod_cliente         LIKE clientes.cod_cliente,
          l_tipo_laudo          LIKE par_laudo_petrom.tip_laudo,
          l_bloqueia_laudo      LIKE par_laudo_petrom.bloqueia_laudo,
          l_tip_analise         LIKE it_analise_petrom.tip_analise,
          l_tipo_valor          CHAR(2),
          l_media_tot           DECIMAL(10,4),      
          l_media_final         DECIMAL(10,4),
          l_valor               DECIMAL(10,4),
          l_ind                 SMALLINT,
          l_bloq_laudo          CHAR(1),
          l_val_especif_de      LIKE especific_petrom.val_especif_de,
          l_val_especif_ate     LIKE especific_petrom.val_especif_ate,
          l_val_analise         LIKE analise_petrom.val_analise,
          l_variacao            LIKE especific_petrom.variacao,
          l_houve_erro          SMALLINT,
          l_metodo              LIKE especific_petrom.metodo,
          l_dat_analise         LIKE analise_petrom.dat_analise,
          l_hor_analise         CHAR(20),
          l_val_especif_de_2    LIKE especific_petrom.val_especif_de,
          l_val_especif_ate_2   LIKE especific_petrom.val_especif_ate,
          l_metodo_2            LIKE especific_petrom.metodo,
          l_variacao_2          LIKE especific_petrom.variacao,
          l_tipo_valor_2        CHAR(2),
          l_tem_cli             SMALLINT,
          sql_stmt              CHAR(500),
          l_cod_empresa         LIKE empresa.cod_empresa,
          l_bloq_item           CHAR(1)

   LET l_bloq_laudo = 'N'
   LET l_houve_erro = FALSE
   INITIALIZE sql_stmt TO NULL 

   IF m_laudo_exx = FALSE THEN 
      IF mr_tela.num_nf IS NOT NULL THEN
         
         DECLARE cq_fat_nf_mestre_2 CURSOR FOR
         
          SELECT cliente
            FROM fat_nf_mestre
           WHERE empresa     = p_cod_empresa
             AND nota_fiscal = mr_tela.num_nf
             AND trans_nota_fiscal = p_trans_nota_fiscal
          
         FOREACH cq_fat_nf_mestre_2
            INTO l_cod_cliente
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql("Lendo", "Cursor: cq_fat_nf_mestre_2")
               RETURN FALSE
            END IF
            
            EXIT FOREACH
                     
         END FOREACH
     
      ELSE
           SELECT UNIQUE p.cod_cliente
             INTO l_cod_cliente
             FROM ordem_montag_item o, pedidos p
            WHERE o.cod_empresa = p.cod_empresa
              AND o.num_pedido  = p.num_pedido
              AND o.num_om      = mr_tela.num_om 
              AND o.cod_empresa = p_cod_empresa
      END IF
   ELSE
      LET l_cod_cliente       = mr_tela1.cod_cliente
      LET mr_tela.num_laudo   = mr_tela1.num_laudo
      LET mr_tela.lote_tanque = mr_tela1.lote_tanque
      LET mr_tela.qtd_laudo   = mr_tela1.qtd_laudo
      LET mr_tela.texto_1     = mr_tela1.texto_1
      LET mr_tela.texto_2     = mr_tela1.texto_2
      LET mr_tela.texto_3     = mr_tela1.texto_3
   END IF

   DECLARE cq_parametro CURSOR FOR
    SELECT tip_laudo, bloqueia_laudo
      FROM par_laudo_petrom
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = m_item_petrom
       AND cod_cliente = l_cod_cliente
   
      OPEN cq_parametro
     FETCH cq_parametro INTO l_tipo_laudo, l_bloqueia_laudo

   IF sqlca.sqlcode <> 0 THEN
      DECLARE cq_parametro1 CURSOR FOR
       SELECT tip_laudo, bloqueia_laudo
         FROM par_laudo_petrom
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = m_item_petrom
          AND cod_cliente IS NULL 
     
         OPEN cq_parametro1
        FETCH cq_parametro1 INTO l_tipo_laudo, l_bloqueia_laudo
        CLOSE cq_parametro1
   END IF 
    
   CLOSE cq_parametro

   BEGIN WORK

   IF m_ies_tanque = 'S' THEN
      DECLARE cq_param2 CURSOR FOR
       SELECT cod_empresa 
         FROM par_laudo_petrom
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = m_item_petrom
          AND cod_cliente = l_cod_cliente

         OPEN cq_param2
        FETCH cq_param2 INTO l_cod_empresa

      IF SQLCA.sqlcode = 0 THEN
         LET l_tem_cli = TRUE
      ELSE
         LET l_tem_cli = FALSE
      END IF
           
      LET sql_stmt =      
         " SELECT UNIQUE a.tip_analise ",
         "   FROM par_laudo_petrom a "
      
      LET sql_stmt = sql_stmt CLIPPED, 
         "  WHERE a.cod_empresa = '",p_cod_empresa,"'",
         "    AND a.cod_item    = '",m_item_petrom,"'"
         
      IF l_tem_cli THEN   
         LET sql_stmt = sql_stmt CLIPPED, "    AND a.cod_cliente = '",l_cod_cliente,"'"
      ELSE
         LET sql_stmt = sql_stmt CLIPPED, "    AND a.cod_cliente IS NULL "    
      END IF   

      LET sql_stmt = sql_stmt CLIPPED, "   ORDER BY a.tip_analise "
         
      PREPARE var_query2 FROM sql_stmt   
      DECLARE cq_tip_analise2 SCROLL CURSOR WITH HOLD FOR var_query2
    
      FOREACH cq_tip_analise2 INTO l_tip_analise

           SELECT val_especif_de, val_especif_ate,
                  tipo_valor, variacao, metodo
             INTO l_val_especif_de_2, l_val_especif_ate_2,
                  l_tipo_valor_2, l_variacao_2, l_metodo_2
             FROM especific_petrom
            WHERE cod_empresa = p_cod_empresa
              AND cod_item    = m_item_petrom
              AND cod_cliente = l_cod_cliente
              AND tip_analise = l_tip_analise 
          
         IF sqlca.sqlcode = 0 THEN
            LET l_val_especif_de  = l_val_especif_de_2
            LET l_val_especif_ate = l_val_especif_ate_2
            LET l_tipo_valor      = l_tipo_valor_2
            LET l_variacao        = l_variacao_2
            LET l_metodo          = l_metodo_2
         ELSE
            SELECT tip_analise, val_especif_de, val_especif_ate,      
                   tipo_valor, variacao, metodo                         
              INTO l_tip_analise, l_val_especif_de, l_val_especif_ate,  
                   l_tipo_valor, l_variacao, l_metodo                   
              FROM especific_petrom                                     
             WHERE cod_empresa = p_cod_empresa                          
               AND cod_item    = m_item_petrom                          
               AND cod_cliente IS NULL                                  
               AND tip_analise = l_tip_analise                          
         END IF 
      
         SELECT MAX(dat_analise)                   
           INTO l_dat_analise                        
           FROM analise_petrom                       
          WHERE cod_empresa = p_cod_empresa          
            AND cod_item    = m_item_petrom          
            AND tip_analise = l_tip_analise          
            AND lote_tanque = mr_tela.lote_tanque    
                                  
         SELECT MAX(hor_analise)                     
           INTO l_hor_analise                        
           FROM analise_petrom                       
          WHERE cod_empresa = p_cod_empresa          
            AND cod_item    = m_item_petrom          
            AND tip_analise = l_tip_analise          
            AND lote_tanque = mr_tela.lote_tanque    
            AND dat_analise = l_dat_analise          
           
         LET l_media_final = NULL
           
         DECLARE cq_vanalise CURSOR FOR                        
          SELECT val_analise                                     
            FROM analise_petrom                                  
           WHERE cod_empresa = p_cod_empresa                     
             AND cod_item    = m_item_petrom                     
             AND tip_analise = l_tip_analise                     
             AND lote_tanque = mr_tela.lote_tanque               
             AND dat_analise = l_dat_analise                     
           ORDER BY hor_analise DESC                             
                                                                 
         FOREACH cq_vanalise INTO l_valor                        
                                                                 
            IF STATUS <> 0 THEN                                  
               CALL log003_err_sql('FOREACH','cq_vanalise')      
            ELSE                                                 
               LET l_media_final = l_valor                       
            END IF                                               
                                                                 
            EXIT FOREACH                                         
                                                                 
         END FOREACH                                             
                      
         LET l_bloq_item  = 'N'
         
         IF l_val_especif_de = l_val_especif_ate THEN
            IF l_variacao IS NOT NULL AND l_variacao <> '0' THEN
               LET l_val_especif_de  = l_val_especif_de - l_variacao
               LET l_val_especif_ate = l_val_especif_ate + l_variacao
               IF l_media_final >= l_val_especif_de AND l_media_final <= l_val_especif_ate THEN
               ELSE
                  IF l_bloqueia_laudo = 'S' THEN
                     LET l_bloq_laudo = 'S'
                     LET l_bloq_item  = 'S'
                  END IF
               END IF
            ELSE
               IF l_tipo_valor = '>' THEN
                  IF l_media_final <= l_val_especif_de THEN
                     IF l_bloqueia_laudo = 'S' THEN
                        LET l_bloq_laudo = 'S'
                        LET l_bloq_item  = 'S'
                     END IF
                  END IF
               ELSE
                  IF l_tipo_valor = '>=' THEN
                     IF l_media_final < l_val_especif_de THEN
                        IF l_bloqueia_laudo = 'S' THEN    
                           LET l_bloq_laudo = 'S'
                           LET l_bloq_item  = 'S'
                        END IF
                     END IF
                  ELSE
                     IF l_tipo_valor = '<=' THEN
                        IF l_media_final > l_val_especif_de THEN
                           IF l_bloqueia_laudo = 'S' THEN
                              LET l_bloq_laudo = 'S'
                              LET l_bloq_item  = 'S'
                           END IF
                        END IF
                     ELSE
                        IF l_tipo_valor = '<' THEN
                           IF l_media_final >= l_val_especif_de THEN
                              IF l_bloqueia_laudo = 'S' THEN
                                 LET l_bloq_laudo = 'S'
                                 LET l_bloq_item  = 'S'
                              END IF
                           END IF
                        ELSE
                           IF l_tipo_valor = '<>' THEN
                              IF l_media_final = l_val_especif_de THEN
                                 IF l_bloqueia_laudo = 'S' THEN
                                    LET l_bloq_laudo = 'S'        
                                    LET l_bloq_item  = 'S'
                                 END IF
                              END IF
                           END IF
                        END IF
                     END IF
                  END IF
               END IF
            END IF
         ELSE
            IF l_media_final < l_val_especif_de OR l_media_final > l_val_especif_ate THEN
               IF l_bloqueia_laudo = 'S' THEN
                  LET l_bloq_laudo = 'S'
                  LET l_bloq_item  = 'S'
               END IF
            END IF
         END IF

         INSERT INTO laudo_item_petrom VALUES (p_cod_empresa,
                                               mr_tela.num_laudo,
                                               l_tip_analise,
                                               l_metodo,
                                               l_val_especif_de,    
                                               l_val_especif_ate,
                                               l_media_final,
                                               l_tipo_valor,
                                               l_bloq_item)     
         IF sqlca.sqlcode <> 0 THEN
            LET l_houve_erro = TRUE
            CALL log003_err_sql("INCLUSAO","LAUDO_ITEM_PETROM")
         END IF
         
         
      END FOREACH
   ELSE
      DECLARE cq_param CURSOR FOR
       SELECT cod_empresa 
         FROM par_laudo_petrom
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = m_item_petrom
          AND cod_cliente = l_cod_cliente

         OPEN cq_param
        FETCH cq_param INTO l_cod_empresa

      IF SQLCA.sqlcode = 0 THEN
         LET l_tem_cli = TRUE
      ELSE
         LET l_tem_cli = FALSE
      END IF
           
      LET sql_stmt =      
         " SELECT UNIQUE a.tip_analise ",
         "   FROM par_laudo_petrom a "
      
      LET sql_stmt = sql_stmt CLIPPED, 
         "  WHERE a.cod_empresa = '",p_cod_empresa,"'",
         "    AND a.cod_item    = '",m_item_petrom,"'"
         
      IF l_tem_cli THEN   
         LET sql_stmt = sql_stmt CLIPPED, "    AND a.cod_cliente = '",l_cod_cliente,"'"
      ELSE
         LET sql_stmt = sql_stmt CLIPPED, "    AND a.cod_cliente IS NULL "    
      END IF   

      LET sql_stmt = sql_stmt CLIPPED, "   ORDER BY a.tip_analise "
         
      PREPARE var_query FROM sql_stmt   
      DECLARE cq_tip_analise SCROLL CURSOR WITH HOLD FOR var_query
    
      FOREACH cq_tip_analise INTO l_tip_analise
         
           SELECT val_especif_de, val_especif_ate,
                  tipo_valor, variacao, metodo
             INTO l_val_especif_de_2, l_val_especif_ate_2,
                  l_tipo_valor_2, l_variacao_2, l_metodo_2
             FROM especific_petrom
            WHERE cod_empresa = p_cod_empresa
              AND cod_item    = m_item_petrom
              AND cod_cliente = l_cod_cliente
              AND tip_analise = l_tip_analise 
          
         IF sqlca.sqlcode = 0 THEN
            LET l_val_especif_de  = l_val_especif_de_2
            LET l_val_especif_ate = l_val_especif_ate_2
            LET l_tipo_valor      = l_tipo_valor_2
            LET l_variacao        = l_variacao_2
            LET l_metodo          = l_metodo_2
         ELSE
              SELECT val_especif_de, val_especif_ate,
                     tipo_valor, variacao, metodo
                INTO l_val_especif_de, l_val_especif_ate,
                     l_tipo_valor, l_variacao, l_metodo
                FROM especific_petrom
               WHERE cod_empresa = p_cod_empresa
                 AND cod_item    = m_item_petrom
                 AND cod_cliente IS NULL
                 AND tip_analise = l_tip_analise 
         END IF 
          
         LET l_media_tot = 0
         LET l_cont = 0

         FOR l_ind = 1 TO 50     
            IF ma_num_pa[l_ind].num_pa IS NOT NULL THEN
                 SELECT val_analise  
                   INTO l_val_analise
                   FROM analise_petrom
                  WHERE cod_empresa = p_cod_empresa
                    AND cod_item    = m_item_petrom
                    AND tip_analise = l_tip_analise
                    AND lote_tanque = mr_tela.lote_tanque
                    AND num_pa      = ma_num_pa[l_ind].num_pa         
               IF sqlca.sqlcode = 0 THEN 
                  LET l_media_tot = l_media_tot + l_val_analise 
                  LET l_cont      = l_cont + 1
               END IF
            END IF
         END FOR

         LET l_media_final = l_media_tot / l_cont 
 
         LET l_bloq_item  = 'N'
         
         IF l_val_especif_de = l_val_especif_ate THEN
            IF l_variacao IS NOT NULL AND
               l_variacao <> '0' THEN
               LET l_val_especif_de  = l_val_especif_de - l_variacao
               LET l_val_especif_ate = l_val_especif_ate + l_variacao 
               IF l_media_final >= l_val_especif_de AND
                  l_media_final <= l_val_especif_ate THEN
               ELSE
                  IF l_bloqueia_laudo = 'S' THEN
                     LET l_bloq_laudo = 'S'
                     LET l_bloq_item  = 'S'
                  END IF
               END IF
            ELSE
               IF l_tipo_valor = '>' THEN
                  IF l_media_final <= l_val_especif_de THEN
                     IF l_bloqueia_laudo = 'S' THEN
                        LET l_bloq_laudo = 'S'
                        LET l_bloq_item  = 'S'
                     END IF
                  END IF
               ELSE
                  IF l_tipo_valor = '>=' THEN
                     IF l_media_final < l_val_especif_de THEN
                        IF l_bloqueia_laudo = 'S' THEN
                           LET l_bloq_laudo = 'S'
                           LET l_bloq_item  = 'S'
                        END IF
                     END IF
                  ELSE
                     IF l_tipo_valor = '<=' THEN
                        IF l_media_final > l_val_especif_de THEN
                           IF l_bloqueia_laudo = 'S' THEN
                              LET l_bloq_laudo = 'S'
                              LET l_bloq_item  = 'S'
                           END IF
                        END IF
                     ELSE  
                        IF l_tipo_valor = '<' THEN
                           IF l_media_final >= l_val_especif_de THEN
                              IF l_bloqueia_laudo = 'S' THEN
                                 LET l_bloq_laudo = 'S'
                                 LET l_bloq_item  = 'S'
                              END IF
                           END IF
                        ELSE
                           IF l_tipo_valor = '<>' THEN
                              IF l_media_final = l_val_especif_de THEN
                                 IF l_bloqueia_laudo = 'S' THEN
                                    LET l_bloq_laudo = 'S'
                                    LET l_bloq_item  = 'S'
                                 END IF
                              END IF
                           END IF
                        END IF
                     END IF      
                  END IF
               END IF 
            END IF
         ELSE
            IF l_media_final < l_val_especif_de OR
               l_media_final > l_val_especif_ate THEN
               IF l_bloqueia_laudo = 'S' THEN
                  LET l_bloq_laudo = 'S'
                  LET l_bloq_item  = 'S'
               END IF
            END IF
         END IF
  
         INSERT INTO laudo_item_petrom VALUES (p_cod_empresa,
                                               mr_tela.num_laudo,
                                               l_tip_analise,
                                               l_metodo,
                                               l_val_especif_de,
                                               l_val_especif_ate,
                                               l_media_final, 
                                               l_tipo_valor,
                                               l_bloq_item)
         IF sqlca.sqlcode <> 0 THEN
            LET l_houve_erro = TRUE
            CALL log003_err_sql("INCLUSAO","LAUDO_ITEM_PETROM")
         END IF
        
      END FOREACH
   END IF
   
   LET p_hoje = TODAY

   IF l_bloq_laudo <> 'S' THEN
      LET l_bloq_laudo = pol0323_ve_validade(l_cod_cliente, mr_tela.cod_item)
   END IF
   
   IF l_houve_erro = FALSE THEN
      INSERT INTO laudo_mest_petrom VALUES (p_cod_empresa,
                                            mr_tela.num_laudo,
                                            mr_tela.num_om,
                                            mr_tela.num_nf,
                                            mr_tela.cod_item,
                                            m_item_petrom,
                                            p_hoje,
                                            l_cod_cliente,
                                            mr_tela.lote_tanque,
                                            mr_tela.qtd_laudo,
                                            l_tipo_laudo,
                                            'N',
                                            l_bloq_laudo,
                                            mr_tela.texto_1,
                                            mr_tela.texto_2,
                                            mr_tela.texto_3,
                                            NULL,
                                            NULL,
                                            NULL,0,'S')
      IF sqlca.sqlcode <> 0 THEN
         LET l_houve_erro = TRUE
         CALL log003_err_sql("INCLUSAO","LAUDO_MEST_PETROM")
      END IF  
      
      IF m_ies_tanque = 'N' THEN
         FOR l_ind = 1 TO 50     
            IF ma_num_pa[l_ind].num_pa IS NOT NULL THEN
                 INSERT INTO pa_laudo_petrom VALUES(p_cod_empresa,
                                                    mr_tela.num_laudo,
                                                    ma_num_pa[l_ind].num_pa)
               IF sqlca.sqlcode <> 0 THEN 
                  LET l_houve_erro = TRUE
                  CALL log003_err_sql("INCLUSAO","PA_LAUDO_PETROM")                                               
               END IF
            END IF
         END FOR
      END IF
   END IF
 
   IF l_houve_erro = FALSE THEN
      MESSAGE "Processamento Efetuado com Sucesso." ATTRIBUTE(REVERSE)
      COMMIT WORK
   ELSE
      MESSAGE "Ocorreu problemas no Processamento." ATTRIBUTE(REVERSE)
      ROLLBACK WORK
      CLEAR FORM
   END IF     
             
END FUNCTION

#-----------------------#
 FUNCTION pol0323_popup()
#-----------------------#
   CASE
      WHEN INFIELD(cod_item)
         CALL pol0323_popup_item() RETURNING mr_tela.cod_item        
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0323
         IF mr_tela.cod_item IS NOT NULL AND
            mr_tela.cod_item <> ' ' THEN
            DISPLAY BY NAME mr_tela.cod_item
            CALL pol0323_verifica_item() RETURNING p_status
         END IF

         
   END CASE

END FUNCTION

#-------------------------#
 FUNCTION pol0323_popup_1()
#-------------------------#
   CASE
      WHEN INFIELD(cod_cliente)
         CALL vdp372_popup_cliente() RETURNING mr_tela1.cod_cliente
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0323
         DISPLAY mr_tela1.cod_cliente TO cod_cliente
         CALL pol0323_verifica_cliente() RETURNING p_status

      WHEN INFIELD(cod_item)
         CALL log009_popup(9,13,"ITEM PETROM","item_petrom","cod_item_petrom",
                                "den_item_petrom","POL0337","S","")
            RETURNING mr_tela1.cod_item

         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0323
         DISPLAY mr_tela1.cod_item TO cod_item
         CALL pol0323_verifica_item_petrom() RETURNING p_status

   END CASE

END FUNCTION

#----------------------------#
 FUNCTION pol0323_popup_item()
#----------------------------#
   DEFINE l_ind             SMALLINT

   DEFINE la_tela ARRAY[50] OF RECORD
      cod_item              LIKE item.cod_item,
      den_item              LIKE item.den_item
                  END RECORD

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol03232") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol03232 AT 5,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET l_ind = 1                     

   IF mr_tela.num_nf IS NOT NULL AND
      mr_tela.num_nf <> ' ' THEN
      DECLARE cq_popup_1 CURSOR FOR
       SELECT UNIQUE a.item, b.den_item
         FROM fat_nf_item a, item b
        WHERE a.empresa           = b.cod_empresa
          AND a.item              = b.cod_item
          AND a.empresa           = p_cod_empresa
          AND a.trans_nota_fiscal = p_trans_nota_fiscal

      FOREACH cq_popup_1 INTO la_tela[l_ind].cod_item,
                              la_tela[l_ind].den_item

         LET l_ind = l_ind + 1

      END FOREACH
   ELSE
      DECLARE cq_popup_2 CURSOR FOR
       SELECT UNIQUE a.cod_item, b.den_item
         FROM ordem_montag_item a, item b
        WHERE a.cod_empresa = b.cod_empresa
          AND a.cod_item    = b.cod_item
          AND a.cod_empresa = p_cod_empresa
          AND a.num_om      = mr_tela.num_om

      FOREACH cq_popup_2 INTO la_tela[l_ind].cod_item,
                              la_tela[l_ind].den_item

         LET l_ind = l_ind + 1

      END FOREACH
   END IF
 
   LET l_ind = l_ind - 1

   CALL SET_COUNT(l_ind)
   DISPLAY ARRAY la_tela TO s_item.*

   LET l_ind = ARR_CURR()

   IF INT_FLAG = 0 THEN           
      CLOSE WINDOW w_pol03232
      CURRENT WINDOW IS w_pol0323
      RETURN la_tela[l_ind].cod_item
   ELSE
      CLOSE WINDOW w_pol03232
      CURRENT WINDOW IS w_pol0323
      RETURN " "
   END IF

END FUNCTION     
                               
#-----------------------#
 FUNCTION pol0323_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


# Altera��es efetuadas por Ivo em 12/06/15
# Objetivo: gerar laudo p/ nota de entrda


#------------------------------#
 FUNCTION pol0323_laudo_de_nfe()
#------------------------------#
   
   DEFINE l_informou_dados   SMALLINT
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0323a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol0323a AT 02,02 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa to cod_empresa
   
   LET l_informou_dados = FALSE
     
   MENU "OPCAO1"
      COMMAND "Informar" "Informa par�metros para criar Laudo de entrada"
      MESSAGE ""
      IF pol1213_info_nf() THEN
         CALL pol0323_busca_num_pa(mr_nfe.lote_tanque)
         IF pol0323_info_pas_nfe() THEN
            LET l_informou_dados = TRUE
            ERROR 'Opera��o efetuada com sucesso!'
            NEXT OPTION "Processar"
         END IF
      ELSE
         LET l_informou_dados = FALSE
         ERROR 'Opera��o cancelada!'
      END IF
      COMMAND "Processar" "Processa a gera��o do laudo."
         MESSAGE ""
         IF l_informou_dados THEN
            CALL pol0323_gera_laudo()
            LET l_informou_dados = FALSE
         ELSE
            ERROR "Informe os par�metros primeiramente."
            NEXT OPTION "Informar"
         END IF        
      COMMAND "Fim" "Retorna ao Menu Anterior"
         MESSAGE ""
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0323a

END FUNCTION

#--------------------------#
 FUNCTION pol1213_info_nf()
#--------------------------#

   DISPLAY p_cod_empresa TO cod_empresa
   
   INITIALIZE mr_nfe to NULL
   
   SELECT MAX(num_laudo)
     INTO mr_nfe.num_laudo
     FROM laudo_mest_petrom 
    WHERE cod_empresa = p_cod_empresa
   
   IF mr_nfe.num_laudo IS NULL OR
      mr_nfe.num_laudo = 0 THEN 
      LET mr_nfe.num_laudo = 1 
   ELSE
      LET mr_nfe.num_laudo = mr_nfe.num_laudo + 1
   END IF

   LET INT_FLAG =  FALSE
   INPUT BY NAME mr_nfe.*  WITHOUT DEFAULTS  

      AFTER FIELD num_nf
         IF mr_nfe.num_nf IS NULL THEN
            ERROR 'Campo com preenchimento obrigat�rio'
            NEXT FIELD num_nf
         END IF

      AFTER FIELD ser_nf
         IF mr_nfe.ser_nf IS NULL THEN
            ERROR 'Campo com preenchimento obrigat�rio'
            NEXT FIELD ser_nf
         END IF
            
      AFTER FIELD cod_fornecedor 
         
         IF mr_nfe.cod_fornecedor IS NULL THEN
            ERROR 'Campo com preenchimento obrigat�rio'
            NEXT FIELD cod_fornecedor
         END IF
         
         SELECT raz_social
           INTO p_raz_social
           FROM fornecedor
          WHERE cod_fornecedor = mr_nfe.cod_fornecedor
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','fornecedor')
            NEXT FIELD cod_fornecedor
         END IF         
         
         DISPLAY p_raz_social to raz_social

      AFTER FIELD cod_item

         IF mr_nfe.cod_item IS NULL THEN
            ERROR "Campo de preenchimento obrigat�rio."
            NEXT FIELD cod_item
         END IF

         IF pol0323_busca_item_petrom('E', mr_nfe.cod_item) = FALSE THEN
            ERROR 'Item n�o cadastrado no POL0337'
            NEXT FIELD cod_item
         END IF 

         SELECT den_item
           INTO p_den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = mr_nfe.cod_item
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','item')
            NEXT FIELD cod_item
         END IF         
         
         DISPLAY p_den_item to den_item

      AFTER FIELD lote_tanque
      
      IF mr_nfe.lote_tanque IS NULL THEN 
         ERROR "Campo com preenchimento obrigat�rio."
         NEXT FIELD lote_tanque 
      END IF
            
      IF pol0323_verifica_se_tem_resultado(mr_nfe.lote_tanque) = FALSE THEN
         ERROR 'Item/Lote n�o cont�m resultados.'
         NEXT FIELD lote_tanque
      END IF 

      AFTER FIELD qtd_laudo 
        
         IF mr_nfe.qtd_laudo IS NULL THEN
            ERROR "Campo de preenchimento obrigat�rio."
            NEXT FIELD qtd_laudo 
         END IF

      ON KEY (control-z)
         CALL pol0323_popnfe()
 
      AFTER INPUT
         
         IF INT_FLAG THEN
            RETURN FALSE
         END IF
         
         IF mr_nfe.num_nf IS NULL THEN
            ERROR 'Campo com preenchimento obrigat�rio'
            NEXT FIELD num_nf
         END IF

         IF mr_nfe.ser_nf IS NULL THEN
            ERROR 'Campo com preenchimento obrigat�rio'
            NEXT FIELD ser_nf
         END IF
            
         IF mr_nfe.cod_fornecedor IS NULL THEN
            ERROR 'Campo com preenchimento obrigat�rio'
            NEXT FIELD cod_fornecedor
         END IF

         IF mr_nfe.cod_item IS NULL THEN
            ERROR "Campo de preenchimento obrigat�rio."
            NEXT FIELD cod_item
         END IF

         IF mr_nfe.lote_tanque IS NULL THEN 
            ERROR "Campo com preenchimento obrigat�rio."
            NEXT FIELD lote_tanque 
         END IF
            
         IF mr_nfe.qtd_laudo IS NULL THEN
            ERROR "Campo de preenchimento obrigat�rio."
            NEXT FIELD qtd_laudo 
         END IF
                  
         SELECT COUNT (*) 
           INTO p_count
           FROM laudo_mest_petrom
          WHERE cod_empresa = p_cod_empresa
            AND num_nff = mr_nfe.num_nf 
            AND ser_nff = mr_nfe.ser_nf 
            AND cod_cliente = mr_nfe.cod_fornecedor 
            AND lote_tanque = mr_nfe.lote_tanque
            AND ies_es = 'E'
         
         IF p_count > 0 THEN
            CALL log0030_mensagem('J� existe laudo, p/ os\n par�metros informados','info')
            NEXT FIELD num_nf 
         END IF
         
    END INPUT 

   RETURN TRUE

END FUNCTION


#-------------------------#
 FUNCTION pol0323_popnfe()
#-------------------------#
   
   DEFINE p_codigo    CHAR(15)
   
   CASE
      WHEN INFIELD(cod_item)
         LET p_codigo = pol0323_le_itens()
         IF p_codigo IS NOT NULL THEN
           LET mr_nfe.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

      WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         
         CURRENT WINDOW IS w_pol0323a
         
         IF p_codigo IS NOT NULL THEN
            LET mr_nfe.cod_fornecedor = p_codigo
            DISPLAY p_codigo TO cod_fornecedor
         END IF
         
   END CASE

END FUNCTION

#---------------------------#
 FUNCTION pol0323_le_itens()
#---------------------------#
   
   DEFINE p_ind, s_ind INTEGER
   
   DEFINE pr_itens  ARRAY[2000] OF RECORD
          cod_item  LIKE item.cod_item,
          den_item  LIKE item.den_item
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0323b") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol0323b AT 5,14 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
    
   DECLARE cq_itens CURSOR FOR

     SELECT r.cod_item, i.den_item
       FROM item_refer_petrom r, item_petrom p, item i
      WHERE r.cod_empresa = p_cod_empresa
        AND r.cod_empresa = p.cod_empresa
        AND r.cod_item_petrom = p.cod_item_petrom
        AND p.ies_tip_item =  'E'
        AND r.cod_empresa = i.cod_empresa
        AND r.cod_item = i.cod_item
   
   FOREACH cq_itens
      INTO pr_itens[p_ind].cod_item,   
           pr_itens[p_ind].den_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cursor: cq_itens')
         EXIT FOREACH
      END IF
             
      LET p_ind = p_ind + 1
      
      IF p_ind > 2000 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
    
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_itens TO sr_itens.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol0323b
   
   IF NOT INT_FLAG THEN
      RETURN pr_itens[p_ind].cod_item
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#------------------------------#
 FUNCTION pol0323_info_pas_nfe() 
#------------------------------#

   DEFINE p_funcao           CHAR(11),
          l_ind              SMALLINT
   
   INITIALIZE ma_num_pa TO NULL

   LET INT_FLAG =  FALSE
 
   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*

      BEFORE FIELD ies_calcula_media 
         LET pa_curr   = ARR_CURR()
         LET sc_curr   = SCR_LINE()

      AFTER FIELD ies_calcula_media
                  
         IF ma_tela[pa_curr].ies_calcula_media IS NOT NULL AND
            ma_tela[pa_curr].ies_calcula_media <> ' ' THEN
            IF ma_tela[pa_curr].ies_calcula_media <> 'S' AND
               ma_tela[pa_curr].ies_calcula_media <> 'N' THEN
               ERROR 'Valor inv�lido.'
               NEXT FIELD ies_calcula_media
            ELSE
               IF ma_tela[pa_curr].ies_calcula_media = 'S' THEN
                  IF pol0323_ver_especif_pa() = FALSE THEN
                     ERROR 'PA est� fora da especifica��o no Tipo de An�lise ',
                            m_den_analise
                     LET ma_tela[pa_curr].ies_calcula_media = 'N'
                     NEXT FIELD ies_calcula_media
                  END IF
               END IF
            END IF
         END IF
      
      AFTER INPUT
         
         IF INT_FLAG THEN
            RETURN FALSE
         END IF

         LET m_ind = 0
   
         FOR l_ind = 1 TO 50 
             IF ma_tela[l_ind].ies_calcula_media = 'S' THEN
                LET m_ind = m_ind + 1
                LET ma_num_pa[m_ind].num_pa = ma_tela[l_ind].num_pa  
             END IF 
         END FOR
         
         IF m_ind = 0 THEN
            CALL log0030_mensagem('Marque pelo menos uma PA com S','info')
            NEXT FIELD ies_calcula_media
         END IF
         
   END INPUT
   
   

   RETURN TRUE 

END FUNCTION


#---------------------------------#
 FUNCTION pol0323_ver_especif_pa()
#---------------------------------#

   DEFINE l_cod_cliente       LIKE clientes.cod_cliente,
          l_bloqueia_laudo    LIKE par_laudo_petrom.bloqueia_laudo,
          l_tip_analise       LIKE it_analise_petrom.tip_analise,
          l_tip_analise_2     LIKE it_analise_petrom.tip_analise,
          l_media_final       DECIMAL(10,4),
          l_ind               SMALLINT,
          l_val_especif_de    LIKE especific_petrom.val_especif_de,
          l_val_especif_ate   LIKE especific_petrom.val_especif_ate,
          l_val_analise       LIKE analise_petrom.val_analise,
          l_variacao          LIKE especific_petrom.variacao,
          l_metodo            LIKE especific_petrom.metodo,
          l_val_especif_de_2  LIKE especific_petrom.val_especif_de,
          l_val_especif_ate_2 LIKE especific_petrom.val_especif_ate,
          l_variacao_2        LIKE especific_petrom.variacao,
          l_tipo_valor_2      CHAR(2),
          l_metodo_2          LIKE especific_petrom.metodo,
          l_pa_fora_especific LIKE par_laudo_petrom.pa_fora_especif,
          l_tipo_valor        CHAR(2),
          l_tem_cli           SMALLINT,
          sql_stmt            CHAR(500),
          l_cod_empresa       LIKE empresa.cod_empresa  
  
     INITIALIZE m_den_analise TO NULL  

    SELECT DISTINCT pa_fora_especif
      INTO l_pa_fora_especific
      FROM par_laudo_petrom
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = m_item_petrom
       AND cod_cliente IS NULL 
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','par_laudo_petrom')
      RETURN FALSE
   END IF
    
   IF l_pa_fora_especific = 'S' THEN 
      RETURN TRUE
   END IF
   
   DECLARE cq_tp_ana CURSOR FOR
    SELECT DISTINCT tip_analise 
      FROM par_laudo_petrom 
     WHERE cod_empresa = p_cod_empresa
       AND cod_item  = m_item_petrom
       AND cod_cliente IS NULL
     ORDER BY tip_analise
     
   FOREACH cq_tp_ana INTO l_tip_analise_2

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_tp_ana')
         RETURN FALSE
      END IF
      
      DECLARE cq_espec_pa CURSOR FOR
       SELECT a.tip_analise, 
              a.val_especif_de, 
              a.val_especif_ate,
              a.tipo_valor, 
              a.variacao, 
              a.metodo, 
              b.den_analise
         FROM especific_petrom a, it_analise_petrom b
        WHERE a.cod_empresa = p_cod_empresa
          AND a.cod_item    = m_item_petrom
          AND a.cod_cliente IS NULL 
          AND a.cod_empresa = b.cod_empresa
          AND a.tip_analise = b.tip_analise
          AND a.tip_analise = l_tip_analise_2
   
      FOREACH cq_espec_pa INTO 
              l_tip_analise,
              l_val_especif_de,
              l_val_especif_ate,
              l_tipo_valor,
              l_variacao,
              l_metodo,
              m_den_analise

         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_espec_pa')
            RETURN FALSE
         END IF
          
         SELECT val_analise
           INTO l_media_final
           FROM analise_petrom
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = m_item_petrom
            AND tip_analise = l_tip_analise
            AND lote_tanque = mr_nfe.lote_tanque
            AND num_pa      = ma_tela[pa_curr].num_pa

         IF STATUS = 100 THEN
            CONTINUE FOREACH
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','analise_petrom')
               RETURN FALSE
            END IF
         END IF
   
         IF l_val_especif_de = l_val_especif_ate THEN
            IF l_variacao IS NOT NULL AND l_variacao <> '0' THEN
               LET l_val_especif_de  = l_val_especif_de - l_variacao
               LET l_val_especif_ate = l_val_especif_ate + l_variacao
               
               IF l_media_final >= l_val_especif_de AND l_media_final <= l_val_especif_ate THEN
               ELSE
                  RETURN FALSE
               END IF
            ELSE
               IF l_tipo_valor = '>' THEN
                  IF l_media_final <= l_val_especif_de THEN
                     RETURN FALSE
                  END IF
               ELSE
                  IF l_tipo_valor = '>=' THEN
                     IF l_media_final < l_val_especif_de THEN
                        RETURN FALSE
                     END IF
                  ELSE
                     IF l_tipo_valor = '<=' THEN
                        IF l_media_final > l_val_especif_de THEN
                           RETURN FALSE
                        END IF
                     ELSE
                        IF l_tipo_valor = '<' THEN
                           IF l_media_final >= l_val_especif_de THEN
                              RETURN FALSE
                           END IF
                        ELSE
                           IF l_tipo_valor = '<>' THEN
                              IF l_media_final = l_val_especif_de THEN
                                 RETURN FALSE
                              END IF
                           END IF     
                        END IF
                     END IF
                  END IF
               END IF
            END IF
         ELSE
            IF l_media_final < l_val_especif_de OR l_media_final > l_val_especif_ate THEN
               RETURN FALSE
            END IF
         END IF                    
      
      END FOREACH  

   END FOREACH     
   
   RETURN TRUE

END FUNCTION


#-----------------------------#
 FUNCTION pol0323_gera_laudo()
#----------------------------#

   DEFINE l_cont                SMALLINT,
          l_cod_cliente         LIKE clientes.cod_cliente,
          l_tipo_laudo          LIKE par_laudo_petrom.tip_laudo,
          l_bloqueia_laudo      LIKE par_laudo_petrom.bloqueia_laudo,
          l_tip_analise         LIKE it_analise_petrom.tip_analise,
          l_tipo_valor          CHAR(2),
          l_media_tot           DECIMAL(10,4),      
          l_media_final         DECIMAL(10,4),
          l_ind                 SMALLINT,
          l_bloq_laudo          CHAR(1),
          l_val_especif_de      LIKE especific_petrom.val_especif_de,
          l_val_especif_ate     LIKE especific_petrom.val_especif_ate,
          l_val_analise         LIKE analise_petrom.val_analise,
          l_variacao            LIKE especific_petrom.variacao,
          l_houve_erro          SMALLINT,
          l_metodo              LIKE especific_petrom.metodo,
          l_dat_analise         LIKE analise_petrom.dat_analise,
          l_hor_analise         CHAR(20),
          l_val_especif_de_2    LIKE especific_petrom.val_especif_de,
          l_val_especif_ate_2   LIKE especific_petrom.val_especif_ate,
          l_metodo_2            LIKE especific_petrom.metodo,
          l_variacao_2          LIKE especific_petrom.variacao,
          l_tipo_valor_2        CHAR(2),
          l_tem_cli             SMALLINT,
          sql_stmt              CHAR(500),
          l_cod_empresa         LIKE empresa.cod_empresa,
          l_bloq_item           CHAR(1)

   LET l_bloq_laudo = 'N'
   LET l_houve_erro = FALSE

   SELECT DISTINCT tip_laudo, bloqueia_laudo
     INTO l_tipo_laudo, l_bloqueia_laudo
     FROM par_laudo_petrom
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = m_item_petrom
      AND cod_cliente IS NULL 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','par_laudo_petrom')
      RETURN
   END IF
       
   BEGIN WORK

   DECLARE cq_gera CURSOR FOR
    SELECT DISTINCT tip_analise 
      FROM par_laudo_petrom 
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = m_item_petrom
       AND cod_cliente IS NULL
     ORDER BY tip_analise
         
   FOREACH cq_gera INTO l_tip_analise

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_gera')
         RETURN
      END IF

      SELECT val_especif_de, val_especif_ate,
             tipo_valor, variacao, metodo
        INTO l_val_especif_de, l_val_especif_ate,
             l_tipo_valor, l_variacao, l_metodo
        FROM especific_petrom
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = m_item_petrom
         AND cod_cliente IS NULL
         AND tip_analise = l_tip_analise 
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','especific_petrom')
         RETURN
      END IF
              
      LET l_media_tot = 0
      LET l_cont = 0

      FOR l_ind = 1 TO 50     
          IF ma_num_pa[l_ind].num_pa IS NOT NULL THEN
             SELECT val_analise  
               INTO l_val_analise
               FROM analise_petrom
              WHERE cod_empresa = p_cod_empresa
                AND cod_item    = m_item_petrom
                AND tip_analise = l_tip_analise
                AND lote_tanque = mr_nfe.lote_tanque
                AND num_pa      = ma_num_pa[l_ind].num_pa         
  
             IF STATUS = 0 THEN 
                LET l_media_tot = l_media_tot + l_val_analise 
                LET l_cont      = l_cont + 1
             END IF
          END IF  
      
      END FOR

      LET l_media_final = l_media_tot / l_cont 
 
      LET l_bloq_item  = 'N'
         
      IF l_val_especif_de = l_val_especif_ate THEN
         IF l_variacao IS NOT NULL AND
            l_variacao <> '0' THEN
            LET l_val_especif_de  = l_val_especif_de - l_variacao
            LET l_val_especif_ate = l_val_especif_ate + l_variacao 
            IF l_media_final >= l_val_especif_de AND
               l_media_final <= l_val_especif_ate THEN
            ELSE
               IF l_bloqueia_laudo = 'S' THEN
                  LET l_bloq_laudo = 'S'
                  LET l_bloq_item  = 'S'
               END IF
            END IF
         ELSE
            IF l_tipo_valor = '>' THEN
               IF l_media_final <= l_val_especif_de THEN
                  IF l_bloqueia_laudo = 'S' THEN
                     LET l_bloq_laudo = 'S'
                     LET l_bloq_item  = 'S'
                  END IF
               END IF
            ELSE
               IF l_tipo_valor = '>=' THEN
                  IF l_media_final < l_val_especif_de THEN
                     IF l_bloqueia_laudo = 'S' THEN
                        LET l_bloq_laudo = 'S'
                        LET l_bloq_item  = 'S'
                     END IF
                  END IF
               ELSE
                  IF l_tipo_valor = '<=' THEN
                     IF l_media_final > l_val_especif_de THEN
                        IF l_bloqueia_laudo = 'S' THEN
                           LET l_bloq_laudo = 'S'
                           LET l_bloq_item  = 'S'
                        END IF
                     END IF
                  ELSE  
                     IF l_tipo_valor = '<' THEN
                        IF l_media_final >= l_val_especif_de THEN
                           IF l_bloqueia_laudo = 'S' THEN
                              LET l_bloq_laudo = 'S'
                              LET l_bloq_item  = 'S'
                           END IF
                        END IF
                     ELSE
                        IF l_tipo_valor = '<>' THEN
                           IF l_media_final = l_val_especif_de THEN
                              IF l_bloqueia_laudo = 'S' THEN
                                 LET l_bloq_laudo = 'S'
                                 LET l_bloq_item  = 'S'
                              END IF
                           END IF
                        END IF
                     END IF
                  END IF      
               END IF
            END IF 
         END IF
      ELSE
         IF l_media_final < l_val_especif_de OR
            l_media_final > l_val_especif_ate THEN
            IF l_bloqueia_laudo = 'S' THEN
               LET l_bloq_laudo = 'S'
               LET l_bloq_item  = 'S'
            END IF
         END IF
      END IF
  
      INSERT INTO laudo_item_petrom VALUES (p_cod_empresa,
                                            mr_nfe.num_laudo,
                                            l_tip_analise,
                                            l_metodo,
                                            l_val_especif_de,
                                            l_val_especif_ate,
                                            l_media_final, 
                                            l_tipo_valor,
                                            l_bloq_item)
      IF STATUS <> 0 THEN
         CALL log003_err_sql("INCLUSAO","LAUDO_ITEM_PETROM")
         LET l_houve_erro = TRUE
         EXIT FOREACH
      END IF
        
   END FOREACH
  
   LET p_hoje = TODAY
      
   IF l_houve_erro = FALSE THEN

      IF l_bloq_laudo <> 'S' AND m_item_petrom = '36' THEN
         IF NOT pol0323_ve_formula() THEN
            LET l_houve_erro = TRUE
         ELSE 
           LET l_bloq_laudo = m_bloq_laudo
        END IF
      END IF
   END IF
   
   IF l_houve_erro = FALSE THEN
      INSERT INTO laudo_mest_petrom VALUES (
        p_cod_empresa,        
        mr_nfe.num_laudo,     
        NULL,                 
        mr_nfe.num_nf,        
        mr_nfe.cod_item,      
        m_item_petrom,        
        p_hoje,               
        mr_nfe.cod_fornecedor,      
        mr_nfe.lote_tanque,   
        mr_nfe.qtd_laudo,     
        l_tipo_laudo,         
        'N',                  
        l_bloq_laudo,         
        mr_nfe.texto_1,       
        mr_nfe.texto_2,       
        mr_nfe.texto_3,       
        NULL,                 
        NULL,                 
        NULL,                  
        mr_nfe.ser_nf,        
        'E')                  
                              
      IF STATUS <> 0 THEN
         CALL log003_err_sql("INCLUSAO","LAUDO_MEST_PETROM")
         LET l_houve_erro = TRUE
      
      ELSE
         FOR l_ind = 1 TO 50     
            IF ma_num_pa[l_ind].num_pa IS NOT NULL THEN
                 INSERT INTO pa_laudo_petrom VALUES(p_cod_empresa,
                                                    mr_nfe.num_laudo,
                                                    ma_num_pa[l_ind].num_pa)
               IF STATUS <> 0 THEN 
                  CALL log003_err_sql("INCLUSAO","PA_LAUDO_PETROM")                                               
                  LET l_houve_erro = TRUE
               END IF
            END IF
         END FOR
      END IF
      
   END IF
 
 
   IF l_houve_erro = FALSE THEN
      MESSAGE "Processamento Efetuado com Sucesso." ATTRIBUTE(REVERSE)
      COMMIT WORK
   ELSE
      MESSAGE "Ocorreu problemas no Processamento." ATTRIBUTE(REVERSE)
      ROLLBACK WORK
      CLEAR FORM
   END IF     
             
END FUNCTION

{
Item 36 OLEO FUSEL - tabelas item_petrom e item_refer_petrom

especific_petrom contem os tipos de analise do item petrom e parameros e interva�los e varia�oes
it_analise_petrom contem a descri��o do tipo de analise

tipo
analise descri��o
8				TEOR DE AGUA
71			PESADOS  
33			ALCOOL TOTAL/PUREZA

69			N-PENTANOL
36			ISOBUTANOL
37			N-BUTANOL
68			SEC BUTANOL
70			ISO PENTANOL
72			SOMATORIA C4 + C5

 
1.  100 -  TEOR DE AGUA + PESADOS  = ALCOOL TOTAL/PUREZA
2.  N-PENTANOL + ISOBUTANOL + N-BUTANOL + SEC BUTANOL + ISO PENTANOL = SOMATORIA C4 + C5
