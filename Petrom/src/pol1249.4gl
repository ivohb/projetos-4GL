#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1249                                                 #
# OBJETIVO: An�lise dos conhecimentos de frete                      #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 03/01/14                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_ver_prog           CHAR(09),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_num_conhec         INTEGER,
          p_tem_critica        SMALLINT,
          p_cod_tip_veiculo    CHAR(04), 
          p_tip_carga          CHAR(01),
          p_peso_minimo        DECIMAL(10,3),
          p_qtd_eixo           INTEGER,
          p_cod_cidade_dest    CHAR(05),
          p_cod_cidade_orig    CHAR(05),
          p_cid_empresa        CHAR(05)
         
         
         
END GLOBALS

DEFINE    m_cidade_orig        CHAR(05),
          m_cidade_dest        CHAR(05),
          m_placa              CHAR(07)

DEFINE p_num_processo       CHAR(07),
       p_dat_ini_process    DATE,
       p_hor_ini_process    CHAR(08),
       p_dat_corte          DATE,
       p_pct_tolerancia     DECIMAL(5,2),
       p_erro               CHAR(10),
       p_id_tabela          INTEGER,
       p_id_proces          INTEGER,
       p_cod_item           CHAR(15),
       p_qtd_item           DECIMAL(12,3),       
       p_ies_tip_item       CHAR(01),
       p_trans_nf           INTEGER,
       p_cod_cliente        CHAR(15),
       p_placa              CHAR(10),
       p_peso_nf            DECIMAL(10,3),
       p_peso_ant           DECIMAL(10,3),
       p_cod_transpor       CHAR(19),
       p_ser_conhec         CHAR(03),
       p_ssr_conhec         DECIMAL(2,0),
       p_val_frete          DECIMAL(12,2),
       p_dat_conhec         DATE,
       p_tip_frete          CHAR(01),
       p_val_tabela         DECIMAL(12,2),
       p_val_demais_viag    DECIMAL(12,2),
       p_val_pedagio        DECIMAL(12,2),
       p_val_adicional      DECIMAL(12,2),
       p_pct_seguro         DECIMAL(5,2),
       p_tip_cobranca       CHAR(01),
       p_val_calculado      DECIMAL(12,2),
       p_val_seguro         DECIMAL(12,2),
       p_pedagio_frete      DECIMAL(12,2),
       p_seguro_frete       DECIMAL(12,2),
       p_val_nota           DECIMAL(12,2),
       p_val_tolerancia     DECIMAL(12,2),
       p_val_dif            DECIMAL(12,2),
       p_cod_fornecedor     CHAR(15),
       p_num_aviso_rec      INTEGER,
       p_unidade            CHAR(03),
       p_ies_dif_preco      CHAR(01),
       p_cnd_pgto_frt       INTEGER,
       p_cod_cnd_pgto       INTEGER,
       p_divergencia        CHAR(78),
       p_erro_relac         SMALLINT,
       p_tip_valor          CHAR(01),
       p_chapa_veic         CHAR(07),
       p_sem_nfe            SMALLINT,
       p_transac            INTEGER,
       p_ctr_desp           INTEGER,
       p_fornecedor         CHAR(15)
       

DEFINE pr_men               ARRAY[1] OF RECORD    
       mensagem             CHAR(60)
END RECORD

DEFINE pr_erro       ARRAY[3000] OF RECORD  
  cod_empresa        CHAR(02),
  cod_transpor       CHAR(19),
  num_conhec         INTEGER,
  ser_conhec         CHAR(3),
  ssr_conhec         DECIMAL(2,0),
  den_erro           CHAR(500)
END RECORD

   DEFINE p_pct_ad_valorem DECIMAL(5,2), 
          p_pct_gris       DECIMAL(5,2), 
          p_val_despacho   DECIMAL(12,2),
          p_val_tas        DECIMAL(12,2),
          p_val_trt        DECIMAL(12,2),          
          p_val_gris       DECIMAL(12,2),          
          p_val_ad_valorem DECIMAL(12,2)          

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 60
   DEFER INTERRUPT
   
   LET p_versao = "pol1249-10.02.49  "
   CALL func002_versao_prg(p_versao)

   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '01'; LET p_user = 'admlog'; LET p_status = 0
   
   IF p_status = 0 THEN
      CALL pol1249_controle()
   END IF

END MAIN

#------------------------------#
FUNCTION pol1249_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_status          SMALLINT

   #CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   #CALL JOB_get_parametro_gatilho_tarefa(2,1) RETURNING l_status, l_param2_user
   #CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param2_user
   
   
   LET p_cod_empresa = '01' #l_param1_empresa
   LET p_user = 'pol1249'   #l_param2_user
   
   LET p_houve_erro = FALSE
   
   CALL pol1249_controle()
   
   IF p_houve_erro THEN
      RETURN 1
   ELSE
      RETURN 0
   END IF
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1249_controle()
#--------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1249") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1249 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   LET p_dat_ini_process = TODAY
   LET p_hor_ini_process = TIME
   LET p_ind = 0
   
   #BEGIN WORK
   #CALL log085_transacao("BEGIN")

   IF NOT pol1249_processa() THEN
      #ROLLBACK WORK
      #CALL log085_transacao("ROLLBACK")
      LET p_msg = 'PROCESSAMENTO COM ERRO. CONSULTE TABELA ERRO_CONHEC_455'
   ELSE
      #COMMIT WORK
      #CALL log085_transacao("COMMIT")
      LET p_msg = 'PROCESSAMENTO EFETUADO C/ SUCESSO'
   END IF

   #lds CALL LOG_refresh_display()

   CALL pol1249_grava_erro()
     
END FUNCTION


#-----------------------------#
FUNCTION pol1249_guarda_erro()#
#-----------------------------#

   LET p_ind = p_ind + 1
   LET pr_erro[p_ind].cod_empresa = p_cod_empresa
   LET pr_erro[p_ind].cod_transpor = p_cod_transpor
   LET pr_erro[p_ind].num_conhec = p_num_conhec
   LET pr_erro[p_ind].ser_conhec = p_ser_conhec
   LET pr_erro[p_ind].ssr_conhec = p_ssr_conhec
   LET pr_erro[p_ind].den_erro = p_msg
   LET p_tem_critica = TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1249_grava_erro()#
#----------------------------#

   FOR p_index = 1 to p_ind

         DELETE FROM erro_conhec_455
          WHERE cod_empresa  = pr_erro[p_index].cod_empresa
            AND cod_transpor = pr_erro[p_index].cod_transpor 
            AND num_conhec   = pr_erro[p_index].num_conhec  
            AND ser_conhec   = pr_erro[p_index].ser_conhec   
            AND ssr_conhec   = pr_erro[p_index].ssr_conhec   

   END FOR

   FOR p_index = 1 to p_ind
     
     IF pr_erro[p_index].cod_empresa IS NOT NULL THEN
        LET p_houve_erro = TRUE
        INSERT INTO erro_conhec_455
         VALUES(pr_erro[p_index].cod_empresa,
                pr_erro[p_index].cod_transpor,
                pr_erro[p_index].num_conhec,
                pr_erro[p_index].ser_conhec,
                pr_erro[p_index].ssr_conhec,
                pr_erro[p_index].den_erro,
                p_dat_ini_process,
                p_hor_ini_process)

        IF STATUS <> 0 THEN
           EXIT FOR
        END IF
     END IF
     
   END FOR
   
END FUNCTION

#---------------------------#
FUNCTION pol1249_limpa_var()#
#---------------------------#

   LET p_val_tabela = 0     
   LET p_val_pedagio = 0    
   LET p_tip_cobranca = '' 
   LET p_peso_minimo = 0    
   LET p_peso_ant  = 0     
   LET p_qtd_eixo  = 0   
   LET p_val_ad_valorem = 0 
   LET p_val_gris = 0
   LET p_val_despacho = 0   
   LET p_val_tas = 0        
   LET p_val_trt = 0       
   LET p_placa = ''          
   LET p_val_calculado  = 0  
   LET p_cod_cidade_orig = ''
   LET p_cod_cidade_dest =''

END FUNCTION
      
#-------------------------------#
FUNCTION pol1249_ins_cf_proces()#
#-------------------------------#

   MESSAGE 'LENDO CONHECIMENTOS PROCESSADOS'
   #lds CALL LOG_refresh_display()

   SELECT MAX(id_registro)
     INTO p_id_proces
     FROM conhec_proces_455

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO ULTIMO REGISTRO DA TABELA CONHEC_PROCES_455'
      LET p_num_conhec = 0
      CALL pol1249_guarda_erro()
      RETURN FALSE
   END IF
   
   IF p_id_proces IS NULL THEN
      LET p_id_proces = 0
   END IF
   
   LET p_id_proces = p_id_proces + 1
   
   INSERT INTO conhec_proces_455(
      id_registro, 
      cod_empresa, 
      cod_transpor,
      num_conhec,  
      ser_conhec,  
      ssr_conhec,
      placa_veiculo,
      dat_conhec,
      val_frete,
      val_calculado,
      cidade_orig,
      cidade_dest,
      divergencia,
      tip_frete,
      val_tolerancia)
     VALUES(p_id_proces, 
          p_cod_empresa, 
          p_cod_transpor,
          p_num_conhec,  
          p_ser_conhec,  
          p_ssr_conhec,
          p_placa,
          p_dat_conhec,
          p_val_frete,
          p_val_calculado,
          p_cod_cidade_orig,
          p_cod_cidade_dest,
          p_divergencia,
          p_tip_frete,
          p_val_tolerancia)
          
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' INSERINDO DADOS NA TABELA CONHEC_PROCES_455'
      CALL pol1249_guarda_erro()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1249_ins_auditoria()#
#-------------------------------#

   DELETE FROM audit_conhec_455
    WHERE cod_empresa = p_cod_empresa
      AND id_cf_proces = p_id_proces

   INSERT INTO audit_conhec_455 (
      cod_empresa,	
      id_tabela,	  
      id_cf_proces,
      dat_confer,	
      hor_confer,	
      erro_confer)
    VALUES(p_cod_empresa, p_id_tabela, p_id_proces,
           p_dat_ini_process, p_hor_ini_process, 
           p_divergencia)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' INSERINDO DADOS NA TABELA AUDIT_CONHEC_455'
      CALL pol1249_guarda_erro()
      RETURN FALSE
   END IF
  

   DELETE FROM calculo_conhec_455
    WHERE cod_empresa = p_cod_empresa
      AND id_cf_proces = p_id_proces

   INSERT INTO calculo_conhec_455 (
      cod_empresa,   
      id_cf_proces,  
      id_tabela,     
      val_tabela,    
      val_pedagio,   
      tip_cobranca,  
      peso_minimo,   
      peso_nf,       
      qtd_eixo,      
      val_ad_valorem,
      val_gris,      
      val_despacho,  
      val_tas,       
      val_trt)       
    VALUES(
      p_cod_empresa, 
      p_id_proces,
      p_id_tabela, 
      p_val_tabela,    
      p_val_pedagio,   
      p_tip_cobranca,  
      p_peso_minimo,   
      p_peso_ant,       
      p_qtd_eixo,      
      p_val_ad_valorem,
      p_val_gris,      
      p_val_despacho,  
      p_val_tas,       
      p_val_trt)       

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' INSERINDO DADOS NA TABELA CALCULO_CONHEC_455'
      CALL pol1249_guarda_erro()
      RETURN FALSE
   END IF
  
   RETURN TRUE

END FUNCTION   
                  
#--------------------------#
FUNCTION pol1249_processa()#
#--------------------------#
      
   MESSAGE 'LENDO PARAMETROS DA EMPRESA'
   #lds CALL LOG_refresh_display()

   DELETE FROM erro_conhec_455
    WHERE num_conhec = 0  
   
   DECLARE cq_emps CURSOR WITH HOLD FOR
    SELECT cod_empresa,
           dat_corte,
           pct_tolerancia
      FROM par_frete_455
   
   FOREACH cq_emps INTO p_cod_empresa, p_dat_corte, p_pct_tolerancia                
      
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CURSOR CQ_EMPS'
         LET p_num_conhec = 0
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF

      MESSAGE 'LENDO CONHECIMENTOS N�O PROCESSADOS'
      #lds CALL LOG_refresh_display()
      
      DECLARE cq_conhecs CURSOR WITH HOLD FOR
       SELECT f.cod_transpor,
              f.num_conhec,
              f.ser_conhec,
              f.ssr_conhec,
              f.val_frete,
              f.tip_frete,
              f.dat_entrada_conhec,
              f.cnd_pgto_frt,
              f.gru_ctr_desp_frete
         FROM frete_sup f
        WHERE f.cod_empresa = p_cod_empresa
          AND f.ies_incl_cap in ('N','X')
          AND f.dat_entrada_conhec >= p_dat_corte  
          AND f.cod_tip_despesa IN 
              (SELECT t.cod_tip_despesa FROM tip_despesa_455 t
                WHERE t.cod_empresa = f.cod_empresa)
          AND f.num_conhec NOT IN
              (SELECT c.num_conhec FROM conhec_proces_455 c
                WHERE c.cod_empresa = f.cod_empresa
                  AND c.cod_transpor = f.cod_transpor
                  AND c.num_conhec = f.num_conhec
                  AND c.ser_conhec = f.ser_conhec
                  AND c.ssr_conhec = f.ssr_conhec)      
          AND f.cod_transpor IN
              (SELECT cod_transpor FROM transportador_455)
              
      FOREACH cq_conhecs INTO 
              p_cod_transpor,
              p_num_conhec,  
              p_ser_conhec,  
              p_ssr_conhec,  
              p_val_frete,    
              p_tip_frete,
              p_dat_conhec,
              p_cnd_pgto_frt,
              p_ctr_desp 

         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CURSOR CQ_CONHECS'
            LET p_num_conhec = 0
            CALL pol1249_guarda_erro()
            RETURN FALSE
         END IF
         
         CALL pol1249_limpa_var()
         
         BEGIN WORK
         
         IF pol1249_analisa_conhec() THEN
            COMMIT WORK
         ELSE
            ROLLBACK WORK
         END IF
         
      END FOREACH         

   END FOREACH

   RETURN TRUE
   
END FUNCTION
         
#--------------------------------#         
FUNCTION pol1249_analisa_conhec()#
#--------------------------------#
   
   LET p_erro_relac = FALSE
   
   IF NOT pol1249_bloqueia() THEN
      RETURN FALSE
   END IF

   DELETE FROM erro_conhec_455
    WHERE cod_empresa  = p_cod_empresa
      AND cod_transpor = p_cod_transpor 
      AND num_conhec   = p_num_conhec  
      AND ser_conhec   = p_ser_conhec   
      AND ssr_conhec   = p_ssr_conhec   

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' DELETANDO TABELA ERRO_CONHEC_455'
      CALL pol1249_guarda_erro()
      RETURN FALSE
   END IF

   LET p_tem_critica = FALSE
   LET p_divergencia = ''
         
   SELECT cod_cnd_pgto,                                                                                       
          pct_ad_valorem,                                                                                           
          pct_gris,                                                                                                 
          val_despacho,                                                                                             
          val_tas,                                                                                                  
          val_trt                                                                                                   
     INTO p_cod_cnd_pgto,                                                                                           
          p_pct_ad_valorem,                                                                                         
          p_pct_gris,                                                                                               
          p_val_despacho,                                                                                           
          p_val_tas,                                                                                                
          p_val_trt                                                                                                 
     FROM transportador_455                                                                                         
    WHERE cod_transpor = p_cod_transpor                                                                             
                                                                                                              
   IF STATUS <> 0 THEN                                                                                           
      LET p_erro = STATUS                                                                                        
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TRANSPORTADOR_455'                                            
      CALL pol1249_guarda_erro()                                                                                 
      RETURN FALSE                                                                                               
   END IF                                                                                                           
                                                                                                              
   IF p_cod_cnd_pgto <> p_cnd_pgto_frt THEN                                                                         
      LET p_msg = 'CONDICAO DE PAGAMENTO DO FRETE DIFERENTE ',                                                      
                  'DA COND. PGTO CADASTRADA P/ O TRANSPORTADOR.'                                                    
      CALL pol1249_guarda_erro()                                                                                    
      RETURN TRUE                                                                                                   
   END IF                                                                                                           

   INITIALIZE p_cod_cidade_orig,
              p_cod_cidade_dest, 
              p_placa, m_cidade_dest,
              m_cidade_orig, m_placa TO NULL
   
   IF p_ctr_desp = 83 THEN
   ELSE                                                                                                                    
      IF NOT POL1249_le_orig_dest() THEN                                                                               
         RETURN FALSE                                                                                                  
      END IF                                                                                                           
   END IF
                                                                                                           
   IF p_tem_critica THEN                                                                                            
      RETURN TRUE                                                                                                   
   END IF                                                                                                           
                                                                                                                    
   MESSAGE 'LENDO NOTAS DO CONHEC ', p_num_conhec                                                                   
   #lds CALL LOG_refresh_display()                                                                                  
                                                                                                                    
   IF p_tip_frete = 'V' THEN                                                                                        
      IF NOT pol1249_le_nf_saida() THEN                                                                             
         RETURN FALSE                                                                                               
      END IF                                                                                                        
   ELSE                                                                                                             
      IF NOT pol1249_le_nf_entrada() THEN                                                                           
         RETURN FALSE                                                                                               
      END IF                                                                                                        
   END IF                                                                                                           
                                                                                                              
   IF p_tem_critica THEN                                                                                            
      RETURN TRUE                                                                                                   
   END IF                                                                                                           

   IF p_erro_relac THEN
      IF NOT pol1249_ins_cf_proces() THEN
         RETURN FALSE
      END IF

      IF NOT pol1249_ins_auditoria() THEN
         RETURN FALSE
      END IF
      
      RETURN TRUE      
   END IF

      SELECT placa_veic,
             cidade_orig,
             cidade_dest                                                                                            
        INTO m_placa, m_cidade_orig, m_cidade_dest                                                                                     
        FROM placa_veic_455                                                                                         
       WHERE cod_empresa  = p_cod_empresa                                                                           
         AND cod_transpor = p_cod_transpor                                                                          
         AND num_conhec   = p_num_conhec                                                                            
         AND ser_conhec   = p_ser_conhec                                                                            
         AND ssr_conhec   = p_ssr_conhec                                                                            
                                                                                                                    
      IF STATUS = 100 THEN                                                                                          
         LET m_placa = NULL              #  Manuel em 29-12-2016 estava como p_placa                                                                           
      ELSE                                                                                                          
         IF STATUS <> 0 THEN                                                                                        
            LET p_erro = STATUS                                                                                     
            LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO PLACA_VEIC_455'                                            
            CALL pol1249_guarda_erro()                                                                              
            RETURN FALSE                                                                                            
         END IF                                                                                                     
      END IF                                                                                                        
   
   IF p_placa IS NULL THEN                                                                                       
      LET p_placa = p_chapa_veic                                                                                 
   END IF                                                                                                        
                                                                                                                    
   IF p_placa IS NULL THEN                                                                                          
      LET p_placa = m_placa                                                                                                          
      IF p_placa IS NULL THEN                                                                                       
         LET p_msg = 'NAO FOI POSSIVEL LER A PLACA DO VEICULO. ',
                     'VC PODE USAR O POL1250 PARA INCLUI-LA.'                                                    
         CALL pol1249_guarda_erro()                                                                                 
         RETURN TRUE                                                                                                
      END IF                                                                                                        
   END IF                                                                                                           

   IF p_ctr_desp = 83 THEN
      IF NOT pol1249_le_cidades() THEN
         RETURN FALSE
      END IF
   ELSE
      IF p_cod_cidade_orig IS NULL OR p_cod_cidade_dest IS NULL THEN  
         LET p_cod_cidade_orig = m_cidade_orig
         LET p_cod_cidade_dest = m_cidade_dest
         IF p_cod_cidade_orig IS NULL OR p_cod_cidade_dest IS NULL THEN                                                                                         
            LET p_msg = 'NAO FOI POSSIVEL ENCONTRAR AS CIDADES ORIGEM E ',
                        'DESTINO. VC PODE USAR O POL1250 PARA INCLUI-LAS.'                                                    
            CALL pol1249_guarda_erro()                                                                                 
            RETURN TRUE
         END IF                                                                                             
      END IF                                                                                                        
   END IF                                                                                    

   IF p_tem_critica THEN                                                                                            
      RETURN TRUE                                                                                                   
   END IF                                                                                                           
                                                                                                                    
   IF NOT pol1249_calc_frete() THEN          #calcula o frete com base na tabela                                    
      RETURN FALSE                           #do pol1247                                                            
   END IF                                                                                                           
                                                                                                              
   IF p_tem_critica THEN                                                                                            
      RETURN TRUE                                                                                                   
   END IF                                                                                                           
                                                                                                              
   #acrescenta os adicionais sobre o valor calculado                                                                
                                                                                                              
   IF p_pct_ad_valorem > 0 THEN                                                                                     
      LET p_val_ad_valorem = p_val_nota * p_pct_ad_valorem / 100                                                    
   ELSE                                                                                                             
      LET p_val_ad_valorem = 0                                                                                      
   END IF                                                                                                           
                                                                                                              
   IF p_pct_gris > 0 THEN                                                                                           
      LET p_val_gris = p_val_nota * p_pct_gris / 100                                                                
   ELSE                                                                                                             
      LET p_val_gris = 0                                                                                            
   END IF                                                                                                           
                                                                                                                    
   LET p_val_calculado = p_val_calculado +                                                                          
        p_val_ad_valorem + p_val_gris + p_val_despacho +                                                            
        p_val_tas + p_val_trt                                                                                       
                                                                                                              
   #agrega ped�gio e seguro ao                                                                                   
   #valaor do conhecimento de frete                                                                              
                                                                                                                    
   #IF NOT pol1247_add_pedagio_seguro() THEN  --j� est� incluido no valor do frete                                  
   #   RETURN FALSE                                                                                                 
   #END IF                                                                                                          
                                                                                                              
   #IF p_tem_critica THEN                                                                                           
   #   CONTINUE FOREACH                                                                                             
   #END IF                                                                                                          
                                                                                                              
   LET p_msg = ''                                                                                                   
                                                                                                                    
   IF p_val_calculado < p_val_frete THEN                                                                            
      LET p_val_tolerancia = p_val_calculado * p_pct_tolerancia / 100                                               
      LET p_val_dif = p_val_frete - p_val_calculado                                                                 
      IF p_val_dif > p_val_tolerancia THEN                                                                          
         LET p_msg = ' * VALOR FRETE MAIOR QUE VALOR CALCULADO * '                                                  
      END IF                                                                                                        
   ELSE                                                                                                             
      IF p_val_calculado > p_val_frete THEN                                                                         
         LET p_val_tolerancia = p_val_frete * p_pct_tolerancia / 100                                                
         LET p_val_dif = p_val_calculado - p_val_frete                                                              
         IF p_val_dif > p_val_tolerancia THEN                                                                       
            LET p_msg = ' * VALOR CALCULADO MAIOR QUE VALOR FRETE * '                                               
         END IF                                                                                                     
      END IF                                                                                                        
   END IF                                                                                                           
                                                                                                                    
   LET p_divergencia = p_divergencia CLIPPED, p_msg CLIPPED                                                         
                                                                                                                    
   IF p_divergencia IS NULL OR p_divergencia = '' 
          OR p_divergencia = ' ' OR LENGTH(p_divergencia) = 0 THEN                                                              
      IF NOT pol1249_desbloqueia() THEN                                                                             
         RETURN FALSE                                                                                               
      END IF                                                                                                        
   END IF                                                                                                           

   IF NOT pol1249_ins_cf_proces() THEN
      RETURN FALSE
   END IF

   IF NOT pol1249_ins_auditoria() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
         
#------------------------------#
FUNCTION POL1249_le_orig_dest()#
#------------------------------#
   
   DEFINE p_par_txt     LIKE sup_par_frete.parametro_texto,
          p_id_xml      CHAR(300),
          p_trans_xml   DECIMAL(9,0),
          p_mun_orig    CHAR(07),
          p_mun_dest    CHAR(07)
   
   SELECT parametro_texto 
     INTO p_par_txt
     FROM sup_par_frete
    WHERE empresa = p_cod_empresa
      AND num_conhec = p_num_conhec 
      AND serie_conhec = p_ser_conhec
      AND subserie_conhec = p_ssr_conhec
      AND transportadora = p_cod_transpor
      AND parametro = 'chave_acesso_cte' 

   IF STATUS = 100 THEN
      #LET p_msg = 'DURANTE A CARGA DO XML A TABELA SUP_PAR_FRETE NAO FOI ALIMENTADA'
      #CALL pol1249_guarda_erro()
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA SUP_PAR_FRETE.'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF
   END IF

   LET p_id_xml = 'CTe',p_par_txt
   
   SELECT cMunIni,
          cMunFim, 
          transxml
     INTO p_mun_orig,
          p_mun_dest,
          p_trans_xml
     FROM cte_ide_912
    WHERE id = p_id_xml 
    
   IF STATUS = 100 THEN
      #LET p_msg = 'DURANTE A CARGA DO XML A TABELA CTE_IDE_912 NAO FOI ALIMENTADA'
      #CALL pol1249_guarda_erro()
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA INFCTE_912.'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF
   END IF

   SELECT cidade_logix
     INTO p_cod_cidade_orig
     FROM obf_cidade_ibge
    WHERE cidade_ibge = p_mun_orig
    
   IF STATUS = 100 THEN
      LET p_msg = 'CIDADE IBGE ', p_mun_orig CLIPPED,
            'NAO CADASTRADA NA TAB OBF_CIDADE_IBGE'
      CALL pol1249_guarda_erro()
      RETURN TRUE
   END IF

   IF STATUS = -284 THEN
      LET p_msg = 'CIDADE IBGE ', p_mun_orig CLIPPED,
            'DUPLICADA NA TAB OBF_CIDADE_IBGE'
      CALL pol1249_guarda_erro()
      RETURN TRUE
   END IF
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, 
                  ' LENDO TABELA OBF_CIDADE_IBGE, P/ MUNIC. ', p_mun_orig
      CALL pol1249_guarda_erro()
      RETURN FALSE
   END IF

   SELECT cidade_logix
     INTO p_cod_cidade_dest
     FROM obf_cidade_ibge
    WHERE cidade_ibge = p_mun_dest
    
   IF STATUS = 100 THEN
      LET p_msg = 'CIDADE IBGE ', p_mun_dest CLIPPED,
            'NAO CADASTRADA NA TAB OBF_CIDADE_IBGE'
      CALL pol1249_guarda_erro()
      RETURN TRUE
   END IF

   IF STATUS = -284 THEN
      LET p_msg = 'CIDADE IBGE ', p_mun_dest CLIPPED,
            'DUPLICADA NA TAB OBF_CIDADE_IBGE'
      CALL pol1249_guarda_erro()
      RETURN TRUE
   END IF
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, 
                  ' LENDO TABELA OBF_CIDADE_IBGE, P/ MUNIC. ', p_mun_dest
      CALL pol1249_guarda_erro()
      RETURN FALSE
   END IF
   
   LET p_placa = NULL
   
   DECLARE cq_placa1 CURSOR FOR
    SELECT placa
      FROM cte_veic_912
     WHERE transxml = p_trans_xml
       AND tpveic = 1
   FOREACH cq_placa1 INTO p_placa
      EXIT FOREACH
   END FOREACH
   
   IF p_placa IS NULL THEN
      DECLARE cq_placa0 CURSOR FOR
       SELECT placa
         INTO p_placa
         FROM cte_veic_912
        WHERE transxml = p_trans_xml
          AND tpveic = 0
      FOREACH cq_placa0 INTO p_placa
         EXIT FOREACH
      END FOREACH
   END IF

   IF p_placa IS NULL THEN
      DECLARE cq_placa2 CURSOR FOR
       SELECT placa
         INTO p_placa
         FROM cte_veic_912
        WHERE transxml = p_trans_xml
          AND tpveic = 2
      FOREACH cq_placa2 INTO p_placa
         EXIT FOREACH
      END FOREACH
   END IF
            
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1249_le_cidades()
#---------------------------#         

   IF p_tip_frete = 'V' THEN  #cidade origem = mogi e desino = cidade do cliente

      SELECT cidade 
        INTO p_cod_cidade_orig
        FROM log_empresa_compl 
       WHERE empresa = p_cod_empresa

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CIDADE ORIGEM DA TABELA LOG_EMPRESA_COMPL'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF

      IF p_cod_cidade_orig IS NULL THEN
         LET p_msg = 'COD CIDADE DA EMPRESA ', p_cod_empresa CLIPPED, ' ESTA NULO'
         CALL pol1249_guarda_erro()
         RETURN TRUE
      END IF

      SELECT cod_cidade
        INTO p_cod_cidade_dest
        FROM clientes
       WHERE cod_cliente = p_cod_cliente 
      
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CIDADE DESTINO DA TABELA CLIENTES'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF

      IF p_cod_cidade_dest IS NULL THEN
         LET p_msg = 'COD CIDADE DO CLIENTE ', p_cod_cliente CLIPPED, ' ESTA NULO'
         CALL pol1249_guarda_erro()
         RETURN TRUE
      END IF
         
   ELSE                       #cidade origem = cidade do fornecedor e cidade destino = mogi                                 

      SELECT cod_cidade
        INTO p_cod_cidade_orig
        FROM fornecedor
       WHERE cod_fornecedor = p_fornecedor
      
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CIDADE ORIGEM DA TABELA FORNECEDOR'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF

      IF p_cod_cidade_orig IS NULL THEN
         LET p_msg = 'COD CIDADE DO FORNECEDOR ', p_fornecedor CLIPPED, ' ESTA NULO'
         CALL pol1249_guarda_erro()
         RETURN TRUE
      END IF
      
      SELECT cidade 
        INTO p_cod_cidade_dest
        FROM log_empresa_compl 
       WHERE empresa = p_cod_empresa

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CIDADE DESTINO DA TABELA LOG_EMPRESA_COMPL'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF

      IF p_cod_cidade_dest IS NULL THEN
         LET p_msg = 'COD CIDADE DA EMPRESA ', p_cod_empresa CLIPPED, ' ESTA NULO'
         CALL pol1249_guarda_erro()
         RETURN TRUE
      END IF
         
   END IF
   
   RETURN TRUE
   
END FUNCTION
   
#-----------------------------#   
FUNCTION pol1249_le_nf_saida()#
#-----------------------------#
   
   DEFINE l_peso_unit    LIKE fat_nf_item.peso_unit,
          l_qtd_item     LIKE fat_nf_item.qtd_item,
          l_unid_medida  LIKE fat_nf_item.unid_medida,
          l_peso_nf      LIKE fat_nf_item.peso_unit
   
   LET l_peso_nf = 0
   LET p_peso_nf = 0
   
   LET p_chapa_veic = NULL
   
   SELECT DISTINCT cliente
     INTO p_cod_cliente
     FROM fat_nf_mestre
    WHERE empresa = p_cod_empresa
      AND sit_nota_fiscal = 'N'
      AND transportadora = p_cod_transpor
      AND trans_nota_fiscal IN
          (SELECT trans_nota_fiscal_fatura
             FROM frete_sup_x_nff 
            WHERE cod_empresa = p_cod_empresa
              AND num_conhec = p_num_conhec
              AND ser_conhec = p_ser_conhec
              AND ssr_conhec = p_ssr_conhec)

   IF STATUS = -284 THEN
      LET p_msg = 'CONHECIMENTO C/ NOTAS DE CLIENTES DIFERENTES - TRATAMENTO MANUAL'
      CALL pol1249_guarda_erro()
      RETURN TRUE
   END IF

   IF STATUS = 100 THEN
      LET p_divergencia = 'NAO HA RELACIONAMENTO ENTRE CONHECIMENTO E NOTA DE SAIDA'
      #CALL pol1249_guarda_erro()
      LET p_erro_relac = TRUE                      
      RETURN TRUE
   END IF

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA FAT_NF_MESTRE - CLIENTE'
      CALL pol1249_guarda_erro()
      RETURN FALSE
   END IF

   LET p_divergencia = ''
   
   DECLARE cq_nf_saida CURSOR FOR
    SELECT trans_nota_fiscal
      FROM fat_nf_mestre
     WHERE empresa = p_cod_empresa            
       AND sit_nota_fiscal = 'N'
       AND transportadora = p_cod_transpor
       AND trans_nota_fiscal IN
          (SELECT trans_nota_fiscal_fatura
             FROM frete_sup_x_nff 
            WHERE cod_empresa = p_cod_empresa
              AND num_conhec = p_num_conhec
              AND ser_conhec = p_ser_conhec
              AND ssr_conhec = p_ssr_conhec)
   
   FOREACH cq_nf_saida INTO p_transac
   
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO NOTAS DE SAIDA DO CONHECIMENTO'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF
      
      SELECT COUNT(num_conhec)
        INTO p_count
        FROM frete_sup_x_nff
       WHERE cod_empresa = p_cod_empresa
         AND trans_nota_fiscal_fatura = p_transac
         AND num_conhec <> p_num_conhec

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO REGISTROS DA TABELA FRETE_SUP_X_NFF'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF

      IF p_count > 0 THEN
         LET p_divergencia = 'ESSE CONHECIMENTO ESTA RELACIONADO C/ NFS DE OUTRO CF-S'  
         LET p_erro_relac = TRUE                      
      END IF
      
      IF p_chapa_veic IS NULL THEN
         SELECT placa_veiculo
           INTO p_chapa_veic
           FROM fat_nf_mestre
          WHERE empresa = p_cod_empresa
            AND trans_nota_fiscal = p_transac
            
         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO PLACA_VEICULO DA TAB FAT_NF_MESTRE'
            CALL pol1249_guarda_erro()
            RETURN FALSE
         END IF
      END IF
      
      DECLARE cq_peso CURSOR FOR
       SELECT peso_unit, qtd_item, unid_medida
         FROM fat_nf_item
        WHERE empresa = p_cod_empresa
          AND trans_nota_fiscal = p_transac

      FOREACH cq_peso INTO
         l_peso_unit, l_qtd_item, l_unid_medida

         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO PESOS DA TAB FAT_NF_ITEM'
            CALL pol1249_guarda_erro()
            RETURN FALSE
         END IF
         
         LET l_peso_nf = l_qtd_item 
         
         IF l_unid_medida = 'KG' THEN
            LET l_peso_nf = l_peso_nf / 1000
         END IF
         
         LET p_peso_nf = p_peso_nf + l_peso_nf

      END FOREACH
      
   END FOREACH
      
   SELECT SUM(val_mercadoria)
     INTO p_val_nota
     FROM fat_nf_mestre
    WHERE empresa = p_cod_empresa
      AND sit_nota_fiscal = 'N'
      AND transportadora = p_cod_transpor
      AND trans_nota_fiscal IN
          (SELECT trans_nota_fiscal_fatura
             FROM frete_sup_x_nff 
            WHERE cod_empresa = p_cod_empresa
              AND num_conhec = p_num_conhec
              AND ser_conhec = p_ser_conhec
              AND ssr_conhec = p_ssr_conhec)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA FAT_NF_MESTRE - PESO'
      CALL pol1249_guarda_erro()
      RETURN FALSE
   END IF
      
   IF p_val_nota IS NULL THEN
      LET p_divergencia = 'NAO HA RELACIONAMENTO ENTRE CONHECIMENTO E NOTA DE SAIDA'
      LET p_erro_relac = TRUE      
      #CALL pol1249_guarda_erro()                
      RETURN TRUE
   END IF
         
   RETURN TRUE

END FUNCTION
         
#-------------------------------#   
FUNCTION pol1249_le_nf_entrada()#
#-------------------------------#
      
   LET p_sem_nfe = TRUE
   LET p_peso_nf = 0
   LET p_chapa_veic = NULL
   LET p_val_nota = 0
   LET p_fornecedor = NULL
   
   DECLARE cq_nfe CURSOR FOR
    SELECT cod_fornecedor,
           num_aviso_rec
     FROM nf_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_conhec = p_num_conhec
      AND ser_conhec = p_ser_conhec
      AND ssr_conhec = p_ssr_conhec
      AND cod_transpor = p_cod_transpor

   FOREACH cq_nfe INTO p_cod_fornecedor, p_num_aviso_rec

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA NF_SUP'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF

      IF p_chapa_veic IS NULL THEN
         SELECT DISTINCT num_placa_veic
           INTO p_chapa_veic
           FROM aviso_rec_compl
          WHERE cod_empresa = p_cod_empresa
            AND num_aviso_rec = p_num_aviso_rec
      END IF
      
      IF p_fornecedor IS NULL THEN
         LET p_fornecedor = p_cod_fornecedor
      END IF
                     
      LET p_sem_nfe = FALSE

      DECLARE cq_ar CURSOR FOR
       SELECT qtd_declarad_nf,
              cod_unid_med_nf
         FROM aviso_rec
        WHERE cod_empresa = p_cod_empresa
          AND num_aviso_rec = p_num_aviso_rec
      
      FOREACH cq_ar INTO p_qtd_item, p_unidade
      
         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA AVISO_REC'
            CALL pol1249_guarda_erro()
            RETURN FALSE
         END IF
         
         IF p_unidade = 'KG' THEN
            LET p_qtd_item = p_qtd_item / 1000
         END IF
         
         LET p_peso_nf = p_peso_nf + p_qtd_item
      
      END FOREACH         
         
   END FOREACH

   IF NOT p_sem_nfe THEN
      SELECT SUM(val_tot_nf_c)
        INTO p_val_nota
        FROM nf_sup
       WHERE cod_empresa = p_cod_empresa
         AND num_conhec = p_num_conhec
         AND ser_conhec = p_ser_conhec
         AND ssr_conhec = p_ssr_conhec
         AND cod_transpor = p_cod_transpor

      IF p_val_nota IS NULL THEN
         LET p_val_nota = 0
      END IF
      
      RETURN TRUE   
   END IF

   IF NOT pol1249_le_sup_frete() THEN
      RETURN FALSE
   END IF
         
   IF p_sem_nfe THEN
      LET p_erro = STATUS
      LET p_msg = 'NAO HA RELACIONAMENTO ENTRE CONHECIMENTO E NOTA DE ENTRADA'
      CALL pol1249_guarda_erro()
   END IF
      
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1249_le_sup_frete()#
#------------------------------#
   
   DEFINE p_conhec      INTEGER,
          p_valor       DECIMAL(12,2)
   
   INITIALIZE p_cod_fornecedor TO NULL
   LET p_divergencia = ''
   
   DECLARE cq_snfe CURSOR FOR
    SELECT aviso_recebto
     FROM sup_frete_x_nf_entrada
    WHERE empresa = p_cod_empresa
      AND conhec = p_num_conhec
      AND serie_conhec = p_ser_conhec
      AND subserie_conhec = p_ssr_conhec
      AND transportador = p_cod_transpor

   FOREACH cq_snfe INTO p_num_aviso_rec

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA SUP_FRETE_X_NF_ENTRADA'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF

      IF p_chapa_veic IS NULL THEN
         SELECT DISTINCT num_placa_veic
           INTO p_chapa_veic
           FROM aviso_rec_compl
          WHERE cod_empresa = p_cod_empresa
            AND num_aviso_rec = p_num_aviso_rec
      END IF
                     
      LET p_sem_nfe = FALSE
      
      SELECT cod_fornecedor,
             num_conhec,
             val_tot_nf_c
        INTO p_cod_fornecedor,
             p_conhec,
             p_valor
        FROM nf_sup
       WHERE cod_empresa = p_cod_empresa
         AND num_aviso_rec = p_num_aviso_rec

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA NF_SUP'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF

      IF p_fornecedor IS NULL THEN
         LET p_fornecedor = p_cod_fornecedor
      END IF

      IF p_conhec > 0 THEN
         IF p_conhec <> p_num_conhec THEN
            LET p_divergencia = 'ESSE CONHECIMENTO ESTA RELACIONADO C/ NFE DE OUTRO CF-E'  
            LET p_erro_relac = TRUE       
         END IF
      END IF
      
      LET p_val_nota = p_val_nota + p_valor
      
      DECLARE cq_ar CURSOR FOR
       SELECT qtd_declarad_nf,
              cod_unid_med_nf
         FROM aviso_rec
        WHERE cod_empresa = p_cod_empresa
          AND num_aviso_rec = p_num_aviso_rec
      
      FOREACH cq_ar INTO p_qtd_item, p_unidade
      
         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA AVISO_REC'
            CALL pol1249_guarda_erro()
            RETURN FALSE
         END IF
         
         IF p_unidade = 'KG' THEN
            LET p_qtd_item = p_qtd_item / 1000
         END IF
         
         LET p_peso_nf = p_peso_nf + p_qtd_item
      
      END FOREACH         
         
   END FOREACH

   RETURN TRUE   

END FUNCTION

#---calcula o frete com base na tabela do pol1247---#

#----------------------------#
FUNCTION pol1249_calc_frete()#
#----------------------------#
   
   DEFINE p_rota_orig LIKE cli_fornec_455.cod_rota,
          p_rota_dest LIKE cli_fornec_455.cod_rota
   
   IF p_tip_frete = 'V' THEN
      LET p_rota_orig = 0
      SELECT cod_rota
        INTO p_rota_dest
        FROM cli_fornec_455
       WHERE ies_cli_fornec = 'C'
         AND cod_cli_fornec = p_cod_cliente
   ELSE
      LET p_rota_dest = 0
      SELECT cod_rota
        INTO p_rota_orig
        FROM cli_fornec_455
       WHERE ies_cli_fornec = 'F'
         AND cod_cli_fornec = p_cod_fornecedor
   END IF
   
   IF STATUS = 100 THEN
      LET p_rota_dest = 0
      LET p_rota_orig = 0
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA CLI_FORNEC_455'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF
   END IF
   
   SELECT cod_tip_veiculo,
          tip_carga,  
          peso_minimo,
          qtd_eixo,
          ies_dif_preco
     INTO p_cod_tip_veiculo,
          p_tip_carga,  
          p_peso_minimo,
          p_qtd_eixo,
          p_ies_dif_preco
     FROM carreta_455
    WHERE cod_transpor = p_cod_transpor
      AND chapa = p_placa

   IF STATUS = 100 THEN
      LET p_erro = p_trans_nf
      LET p_msg = 'TRANSPORTADOR ', p_cod_transpor CLIPPED, 
                  ' - PLACA ', p_placa CLIPPED, ' NAO CADASTRADA.'
      CALL pol1249_guarda_erro()
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA CARRETA_455'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF
   END IF
   
   LET p_count = 0

   DECLARE cq_tab_frete CURSOR FOR               
    SELECT val_pri_viagem, 
           val_demais_viag,
           val_pedagio,    
           val_adicional,  
           tip_cobranca,
           tip_valor,
           id_registro
      FROM preco_frete_455
     WHERE cod_transpor = p_cod_transpor
       AND cod_tip_veiculo = p_cod_tip_veiculo
       AND tip_carga = p_tip_carga
       AND cod_cidade_orig = p_cod_cidade_orig
       AND cod_rota_orig = p_rota_orig
       AND cod_cidade_dest = p_cod_cidade_dest
       AND cod_rota_dest = p_rota_dest
       AND dat_ini_vigencia <= p_dat_conhec
       AND dat_fim_vigencia >= p_dat_conhec
     ORDER BY id_registro DESC

   FOREACH cq_tab_frete INTO 
          p_val_tabela,
          p_val_demais_viag,
          p_val_pedagio,    
          p_val_adicional,  
          p_tip_cobranca,
          p_tip_valor,
          p_id_tabela  

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA PRECO_FRETE_455:CQ_TAB_FRETE'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF   
   
      LET p_count = 1
   
      EXIT FOREACH
   
   END FOREACH
   
   IF p_count = 0 THEN
      LET p_msg = 'NAO HA TABELA PARA:',
                  ' TRANSP: ',p_cod_transpor CLIPPED,
                  ' CARRETA: ',p_cod_tip_veiculo CLIPPED,
                  ' CARGA: ',p_tip_carga CLIPPED,
                  ' CID ORIG: ',p_cod_cidade_orig CLIPPED,
                  ' CID DEST: ',p_cod_cidade_dest CLIPPED,
                  ' VIGENCIA: ',p_dat_conhec
      CALL pol1249_guarda_erro()
      RETURN TRUE
   END IF
   
   IF p_ies_dif_preco = 'S' THEN #se cobra outro valor p/ demais viagens do dia
      SELECT COUNT(num_conhec)
        INTO p_count
        FROM conhec_proces_455
       WHERE placa_veiculo = p_placa
         AND dat_conhec = p_dat_conhec

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA CONHEC_PROCES_455'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF
   
      IF p_count > 0 THEN
         IF p_val_demais_viag = 0 THEN
            LET p_erro = p_id_tabela
            LET p_msg = ' TABELA ', p_erro CLIPPED, ' SEM VALOR P/ DEMAIS VIAGENS.'
            CALL pol1249_guarda_erro()
            RETURN TRUE
         ELSE
            LET p_val_tabela = p_val_demais_viag
         END IF
      END IF
   END IF

   LET p_peso_ant = p_peso_nf
   
   IF p_tip_cobranca = 'C' THEN
      IF p_peso_nf < p_peso_minimo THEN
         LET p_peso_nf = p_peso_minimo
      END IF
   END IF  
   
   IF p_tip_valor = 'T' THEN
      LET p_val_calculado = p_peso_nf * p_val_tabela
   ELSE
      LET p_val_calculado = p_val_tabela
   END IF
   
   LET p_val_pedagio = p_val_pedagio * p_qtd_eixo
   LET p_val_calculado = p_val_calculado + p_val_pedagio 
   
   IF p_val_adicional > 0 THEN
      LET p_val_calculado = p_val_calculado + p_val_adicional
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1247_add_pedagio_seguro()#
#------------------------------------#   
   
   #---agrega ao valor do conecimento de frete o ped�gio e seguro----#
   
   SELECT val_pedagio
     INTO p_pedagio_frete
     FROM pedagio_frete
    WHERE cod_empresa = p_cod_empresa
      AND num_nf_conhec = p_num_conhec 
      AND ser_nf_conhec = p_ser_conhec
      AND ssr_nf_conhec = p_ssr_conhec
      AND cod_fornecedor = p_cod_transpor 
      AND ies_especie_nf = 'FR'

   IF STATUS = 100 THEN
      LET p_pedagio_frete = 0
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA PEDAGIO_FRETE'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF
   END IF
   
   SELECT parametro_val
     INTO p_seguro_frete
     FROM sup_par_frete
    WHERE empresa = p_cod_empresa        
      AND num_conhec = p_num_conhec
      AND serie_conhec = p_ser_conhec
      AND subserie_conhec = p_ssr_conhec
      AND transportadora = p_cod_transpor
      AND parametro = 'val_seguro_frt'     
     
   IF STATUS = 100 THEN
      LET p_seguro_frete = 0
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA SUP_PAR_FRETE'
         CALL pol1249_guarda_erro()
         RETURN FALSE
      END IF
   END IF

   LET p_val_frete = p_val_frete + (p_val_frete * p_seguro_frete/100)
   LET p_val_frete = p_val_frete + p_pedagio_frete

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1249_bloqueia()#
#--------------------------#

   UPDATE frete_sup
      SET ies_incl_cap = 'X'
    WHERE cod_empresa = p_cod_empresa
      AND cod_transpor = p_cod_transpor
      AND num_conhec = p_num_conhec
      AND ser_conhec = p_ser_conhec 
      AND ssr_conhec = p_ssr_conhec
      
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' BLOQUEANDO FRETE TAB FRETE_SUP'
      CALL pol1249_guarda_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1249_desbloqueia()#
#-----------------------------#

   UPDATE frete_sup
      SET ies_incl_cap = 'N',
          ies_liberacao_frt = 'N'     
    WHERE cod_empresa = p_cod_empresa
      AND cod_transpor = p_cod_transpor
      AND num_conhec = p_num_conhec
      AND ser_conhec = p_ser_conhec 
      AND ssr_conhec = p_ssr_conhec
      
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' ATUALIZANDO TABELA FRETE_SUP'
      CALL pol1249_guarda_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

   
#---------FIM DO PROGRAMA-----------#

