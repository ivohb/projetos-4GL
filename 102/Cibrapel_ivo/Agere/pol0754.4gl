#-------------------------------------------------------------------#
# SISTEMA.: COMERCIAL                                               #
# OBJETIVO: PROCESSAMENTO DE COMISSOES                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa         LIKE empresa.cod_empresa,
         p_user                LIKE usuario.nom_usuario,
         p_num_pedido          LIKE pedidos.num_pedido, 
         p_ano_ref             CHAR(4),                   
         p_mes_ref             CHAR(2),                   
         p_quinz_ref           CHAR(1),
         p_ies_exp             CHAR(1),                   
         p_nff_ch              CHAR(6),
         p_nff_nu              CHAR(6),                   
         p_comissao_par        RECORD LIKE comissao_par.*,
         p_nf_mestre           RECORD LIKE nf_mestre.*,
         p_nf_item             RECORD LIKE nf_item.*,
         p_docum               RECORD LIKE docum.*,     
         p_docum_pgto          RECORD LIKE docum_pgto.*,
         p_dev_mestre          RECORD LIKE dev_mestre.*,
         p_dev_item            RECORD LIKE dev_item.*,
         p_nf_sup              RECORD LIKE nf_sup.*,
         p_ies_emite_dupl      LIKE nat_operacao.ies_emite_dupl, 
         p_ies_estatistica     LIKE nat_operacao.ies_estatistica, 
         p_pct_max_cliche      LIKE par_vdp_885.pct_max_cliche,
         p_lanc_acerto_com_885 RECORD LIKE lanc_acerto_com_885.*,
         p_repres_885          RECORD LIKE repres_885.*,
         p_empresas_885        RECORD LIKE empresas_885.*,
         p_lanc_com_885        RECORD LIKE lanc_com_885.*,
         p_com_fut_885         RECORD LIKE com_fut_885.*, 
         p_status              SMALLINT,
         p_erro                SMALLINT,
         p_count               SMALLINT,
         comando               CHAR(80),
         p_nom_arquivo         CHAR(100),
         p_caminho             CHAR(080),
         p_nom_tela            CHAR(200),
         p_nom_help            CHAR(200),
         p_versao              CHAR(18),
         p_ind                 SMALLINT,
         p_pct_pagto           DECIMAL(8,5),
         p_saldo_cliche        DECIMAL(8,5),  
         p_val_base            DECIMAL(15,2),
         p_val_base_com        DECIMAL(15,2),
         p_val_base_dev        DECIMAL(15,2),
         p_val_com_dev         DECIMAL(15,2),
         p_val_pago            DECIMAL(15,2),
         l_val_com_ofi         DECIMAL(15,2),
         l_val_com_ger         DECIMAL(15,2),
         l_val_com_cli01       DECIMAL(15,2),
         l_val_com_clio1       DECIMAL(15,2),
         l_val_com_clig01      DECIMAL(15,2),
         l_val_com_cligo1      DECIMAL(15,2),
         l_val_com_tot         DECIMAL(15,2),
         l_val_cliche          DECIMAL(15,2),
         l_count               INTEGER,
         l_cod_item            CHAR(15),
         i                     SMALLINT,
         pa_curr, sc_curr      SMALLINT,
         p_ies_cons            SMALLINT,
         p_primeira_vez        SMALLINT,
         p_last_row            SMALLINT,
         p_cont                DECIMAL(2,0),
         p_i                   SMALLINT,
         p_msg                 CHAR(100) 

  DEFINE p_wcliche RECORD
         cod_empresa     CHAR(02),
         cod_item        CHAR(15),
         val_abat        DECIMAL(15,2)
                 END RECORD


  DEFINE p_tela     RECORD
               cod_empresa      LIKE empresa.cod_empresa,
               dat_inicio       DATE,                  
               dat_fim          DATE,                  
               dat_pagto        DATE,                  
               desc_proc        CHAR(20),              
               num_doc          CHAR(20)               
                    END RECORD

END GLOBALS

MAIN

  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
  SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao ="POL0754-10.02.02"
  INITIALIZE p_nom_help TO NULL
  CALL log140_procura_caminho("pol0754.iem") RETURNING p_nom_help
  LET p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help   ,
      NEXT KEY control-f,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
        RETURNING p_status, p_cod_empresa, p_user

  IF p_status = 0  THEN
     CALL pol0754_controle()
  END IF

END MAIN

#--------------------------#
 FUNCTION pol0754_controle()
#--------------------------#
 CALL log006_exibe_teclas("01",p_versao)
 INITIALIZE p_nom_tela TO NULL
 CALL log130_procura_caminho("pol0754") RETURNING p_nom_tela
 LET  p_nom_tela = p_nom_tela CLIPPED
 OPEN WINDOW w_pol0754 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

 MENU "OPCAO"

      COMMAND "Informar" "Informa parametros para processamento. " 
      HELP 000
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"VDP","pol0754","IN")  THEN
         CALL pol0754_entrada_dados()
         NEXT OPTION "Processar"
      END IF 

      COMMAND "Processar" "Processa informacoes."
      HELP 000
      MESSAGE ""
      LET int_flag = 0 
      CALL pol0754_cria_temp()
      LET p_tela.desc_proc = "NOTAS FISCAIS" 
      DISPLAY BY NAME p_tela.desc_proc  
      CALL pol0754_processa_notas()
      LET p_tela.desc_proc = "ACERTOS      " 
      DISPLAY BY NAME p_tela.desc_proc  
      CALL pol0754_processa_acertos()
      LET p_tela.desc_proc = "DESCONTOS   " 
      DISPLAY BY NAME p_tela.desc_proc
      CALL pol0754_processa_descontos()
      NEXT OPTION "Fim"
      ERROR "Fim de processamento"
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol0754_sobre()
      COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0

      COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 000
      MESSAGE ""
      EXIT MENU
 END MENU
 CLOSE WINDOW w_pol0754
 END FUNCTION

#--------------------------------#
 FUNCTION pol0754_entrada_dados()
#--------------------------------#
 INITIALIZE p_tela.*   TO NULL
 CALL log006_exibe_teclas("02 07",p_versao)
 CURRENT WINDOW IS w_pol0754
 CLEAR FORM
 LET p_tela.cod_empresa = p_cod_empresa
 DISPLAY BY NAME p_tela.cod_empresa
 INPUT BY NAME p_tela.* WITHOUT DEFAULTS

    BEFORE FIELD dat_inicio 
      SELECT * INTO p_empresas_885.* 
        FROM empresas_885 
       WHERE cod_emp_oficial = p_cod_empresa   

    AFTER FIELD dat_inicio 
       IF p_tela.dat_inicio IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD dat_inicio 
       END IF

    AFTER FIELD dat_fim     
       IF p_tela.dat_fim IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD dat_fim 
       ELSE
         IF p_tela.dat_inicio > p_tela.dat_fim THEN
            ERROR "Data inicio deve ser menor que data Final"
            NEXT FIELD dat_inicio
         END IF
       END IF

END INPUT
IF int_flag <> 0 THEN
   ERROR "Funcao Cancelada"
   INITIALIZE p_tela.* TO NULL
   RETURN
END IF
CURRENT WINDOW IS w_pol0754

END FUNCTION

#----------------------------#
 FUNCTION pol0754_cria_temp()
#----------------------------#
    WHENEVER ERROR CONTINUE

   DROP TABLE wcliche
   CREATE TEMP TABLE wcliche
     (cod_empresa     CHAR(02),
      cod_item        CHAR(15),
      val_abat        DECIMAL(15,2)
     );

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-WCLICHE")
   END IF

   DELETE FROM wcliche

   DROP TABLE wcli_pg
   CREATE TEMP TABLE wcli_pg
     (cod_empresa      CHAR(02),
      num_nff          DECIMAL(6,0),
      cod_item         CHAR(15),
      dat_pgto         DATE
     );

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-WCLICHE")
   END IF

   DELETE FROM wcliche


END FUNCTION

#---------------------------------#
 FUNCTION pol0754_processa_notas()
#---------------------------------#
  INITIALIZE p_lanc_com_885.* TO NULL

  SELECT pct_max_cliche
    INTO p_pct_max_cliche 
    FROM par_vdp_885
   WHERE cod_empresa = p_empresas_885.cod_emp_gerencial

  CALL pol0754_checa_cliches()

  DECLARE cq_rep CURSOR FOR 
    SELECT * 
      FROM repres_885
     ORDER BY cod_repres
  FOREACH cq_rep INTO p_repres_885.*
     IF p_repres_885.tip_perc = 'S' THEN
        LET p_tela.desc_proc = "NOTAS FISCAIS" 
        DISPLAY BY NAME p_tela.desc_proc  
        CALL pol0754_processa_fat_somatorio()
        LET p_tela.desc_proc = "DEVOLUCOES   " 
        DISPLAY BY NAME p_tela.desc_proc  
        CALL pol0754_processa_dev_som()
     ELSE
        LET p_tela.desc_proc = "NOTAS FISCAIS" 
        DISPLAY BY NAME p_tela.desc_proc  
        CALL pol0754_processa_fat_individual()
        LET p_tela.desc_proc = "DEVOLUCOES   " 
        DISPLAY BY NAME p_tela.desc_proc  
        CALL pol0754_processa_dev_ind()
     END IF 
  END FOREACH 

  LET p_tela.desc_proc = "CLICHES   " 
  DISPLAY BY NAME p_tela.desc_proc  
  CALL pol0754_libera_cliche()
  
END FUNCTION

#----------------------------------------#
 FUNCTION pol0754_processa_fat_somatorio()
#----------------------------------------#
 DEFINE l_val_merc         LIKE nf_mestre.val_tot_mercadoria,
        l_val_tot_nf       LIKE nf_mestre.val_tot_nff,
        l_val_merc_ger     LIKE nf_mestre.val_tot_mercadoria,
        l_pct_tot          LIKE repres_885.pct_rep_ofi,
        l_val_ipi          LIKE nf_mestre.val_tot_mercadoria,
        l_val_base_cli01   LIKE nf_mestre.val_tot_mercadoria,
        l_val_base_clio1   LIKE nf_mestre.val_tot_mercadoria,
        l_val_base_clitot  LIKE nf_mestre.val_tot_mercadoria,  
        l_val_com_clitot   LIKE nf_mestre.val_tot_mercadoria,
        l_val_com_tot      LIKE nf_mestre.val_tot_mercadoria,
        l_val_base_cli_tot LIKE nf_mestre.val_tot_mercadoria,
        l_count            INTEGER,
        l_ies_fut          CHAR(01)         

  DECLARE cq_nf_mes_som CURSOR FOR
    SELECT *
      FROM nf_mestre   
     WHERE cod_empresa = p_cod_empresa
       AND dat_emissao >= p_tela.dat_inicio 
       AND dat_emissao <= p_tela.dat_fim     
       AND ies_situacao = "N"
       AND cod_repres = p_repres_885.cod_repres               

   FOREACH cq_nf_mes_som INTO p_nf_mestre.*

        SELECT ies_emite_dupl,
               ies_estatistica
          INTO p_ies_emite_dupl,
               p_ies_estatistica    
          FROM nat_operacao
         WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper
         
        IF p_ies_emite_dupl = 'N' OR 
           (p_ies_estatistica<> 'T' AND 
            p_ies_estatistica<> 'V') THEN
           CONTINUE FOREACH
        END IF     
        
        LET p_count = 0
        
        SELECT count(*) 
          INTO p_count              
          FROM lanc_com_885 
         WHERE cod_empresa IN (p_cod_empresa, p_empresas_885.cod_emp_gerencial) 
           AND num_nff     = p_nf_mestre.num_nff
           AND ies_origem  = "F"
        
        IF p_count > 0 THEN 
           CONTINUE FOREACH
        END IF

        LET l_val_merc_ger = p_nf_mestre.val_tot_mercadoria
        
        SELECT SUM(val_liq_item)
          INTO l_val_ipi
          FROM nf_item 
         WHERE cod_empresa =  p_cod_empresa
           AND num_nff     =  p_nf_mestre.num_nff
           AND cod_item    IS NULL 
        IF l_val_ipi IS NULL THEN
           LET l_val_ipi = 0    
        END IF    
        
        LET l_val_merc_ger = l_val_merc_ger - l_val_ipi

        LET l_val_base_cli01 = 0 

        SELECT SUM(a.val_liq_item)
          INTO l_val_base_cli01
          FROM nf_item a, custo_cliche_885 b   
         WHERE a.cod_empresa  = p_cod_empresa 
           AND a.cod_item     = b.cod_item
           AND a.num_nff      = p_nf_mestre.num_nff
           AND b.saldo_cliche > 0 

        IF l_val_base_cli01 IS NULL THEN
           LET l_val_base_cli01 = 0 
        END IF     

        LET l_val_merc_ger = l_val_merc_ger - l_val_ipi - l_val_base_cli01
        
        SELECT val_tot_mercadoria, val_tot_nff 
          INTO l_val_merc,l_val_tot_nf
          FROM nf_mestre 
         WHERE cod_empresa = p_empresas_885.cod_emp_gerencial   
           AND num_nff     = p_nf_mestre.num_nff
        IF SQLCA.sqlcode <> 0 THEN 
           LET l_val_merc = 0 
        END IF    

        LET l_val_base_clio1 = 0 

        SELECT SUM(a.val_liq_item)
          INTO l_val_base_clio1
          FROM nf_item a, custo_cliche_885 b   
         WHERE a.cod_empresa  = p_empresas_885.cod_emp_gerencial   
           AND a.cod_item     = b.cod_item
           AND a.num_nff      = p_nf_mestre.num_nff
           AND b.saldo_cliche > 0 

        IF l_val_base_clio1 IS NULL THEN
           LET l_val_base_clio1 = 0 
        END IF     
        
        LET p_nf_mestre.val_tot_mercadoria = p_nf_mestre.val_tot_mercadoria + l_val_merc - l_val_ipi - l_val_base_clio1 - l_val_base_cli01
        
        LET p_nf_mestre.val_tot_nff = p_nf_mestre.val_tot_nff + l_val_tot_nf
        
        LET p_nff_ch = p_nf_mestre.num_nff
        LET p_tela.num_doc = p_nff_ch 
        DISPLAY BY NAME p_tela.num_doc    
        
        LET l_pct_tot = p_repres_885.pct_rep_ofi + p_repres_885.pct_rep_ger  
        LET l_val_com_ofi = (l_val_merc_ger * p_repres_885.pct_rep_ofi) / 100
        LET l_val_com_tot = (p_nf_mestre.val_tot_mercadoria * l_pct_tot) / 100 
        LET l_val_com_ger = l_val_com_tot - l_val_com_ofi
 
        LET p_lanc_com_885.num_docum    = p_nf_mestre.num_nff
        LET p_lanc_com_885.num_nff      = p_nf_mestre.num_nff
        LET p_lanc_com_885.val_base_com = l_val_merc_ger
        LET p_lanc_com_885.dat_proces   = TODAY
        LET p_lanc_com_885.ies_origem   = "F" 
        LET p_lanc_com_885.ies_tip_lanc = "C"  
        LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto
        LET p_lanc_com_885.dat_ini_per  = p_tela.dat_inicio
        LET p_lanc_com_885.dat_fim_per  = p_tela.dat_fim
        LET p_lanc_com_885.nom_usuario  = p_user

        IF l_val_com_ofi > 0 THEN 
           IF p_repres_885.ies_exp = 'N' THEN  
              LET p_lanc_com_885.cod_empresa  = p_cod_empresa 
           ELSE
              LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
           END IF    
        
           LET p_lanc_com_885.cod_empresa  = p_cod_empresa
           LET p_lanc_com_885.cod_repres   = p_nf_mestre.cod_repres
           LET p_lanc_com_885.pct_comis    = p_repres_885.pct_rep_ofi
           LET p_lanc_com_885.val_com_rep  = l_val_com_ofi
           INSERT into lanc_com_885 values (p_lanc_com_885.*)
           IF sqlca.sqlcode <> 0 THEN 
              CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")
              RETURN 
           END IF
        END IF    

        IF l_val_com_ger > 0 THEN 
           LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
           LET p_lanc_com_885.val_base_com = l_val_merc - l_val_base_clio1
           LET p_lanc_com_885.cod_repres   = p_nf_mestre.cod_repres
           LET p_lanc_com_885.pct_comis    = p_repres_885.pct_rep_ger         
           LET p_lanc_com_885.val_com_rep     = l_val_com_ger
           INSERT INTO lanc_com_885 VALUES (p_lanc_com_885.*)
           IF sqlca.sqlcode <> 0 THEN 
              CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")
              RETURN 
           END IF
        END IF

#### - COMISSAO DO GERENTE 
       
        LET l_val_com_ofi = (l_val_merc_ger * p_repres_885.pct_ger_ofi) / 100
         
        IF l_val_com_ofi > 0 THEN 
           SELECT ies_exp 
             INTO p_ies_exp 
             FROM ger_com_885
            WHERE cod_gerente =  p_repres_885.cod_gerente
           IF p_ies_exp = 'N' THEN  
              LET p_lanc_com_885.cod_empresa  = p_cod_empresa 
           ELSE
              LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
           END IF    
          
           LET p_lanc_com_885.cod_repres   = p_repres_885.cod_gerente
           LET p_lanc_com_885.val_base_com = l_val_merc_ger
           LET p_lanc_com_885.pct_comis    = p_repres_885.pct_ger_ofi     
           LET p_lanc_com_885.val_com_rep  = l_val_com_ofi
           INSERT into lanc_com_885 values (p_lanc_com_885.*)
           IF sqlca.sqlcode <> 0 THEN 
              CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")
              RETURN 
           END IF
        END IF    

        LET l_val_com_ger = (l_val_merc * p_repres_885.pct_ger_ger) / 100
        
        IF l_val_com_ger > 0 THEN 
           LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
           LET p_lanc_com_885.cod_repres   = p_repres_885.cod_gerente
           LET p_lanc_com_885.val_base_com = l_val_merc - l_val_base_clio1
           LET p_lanc_com_885.pct_comis    = p_repres_885.pct_ger_ger        
           LET p_lanc_com_885.val_com_rep  = l_val_com_ger
           INSERT INTO lanc_com_885 VALUES (p_lanc_com_885.*)
           IF sqlca.sqlcode <> 0 THEN 
              CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")
              RETURN 
           END IF
        END IF    

###  comissao futura representante e gerente
      LET l_ies_fut = 'N'
      LET l_count = 0 
      SELECT COUNT(*)
        INTO l_count 
        FROM com_fut_885 
       WHERE num_nff = p_nf_mestre.num_nff  
         AND cod_empresa IN (p_empresas_885.cod_emp_gerencial, p_cod_empresa)
      IF l_count = 0 THEN
         LET l_ies_fut = 'N'
      ELSE   
         LET l_ies_fut = 'S'
      END IF 
      
      IF l_ies_fut = 'N' THEN 
        INITIALIZE p_com_fut_885.dat_libera TO NULL

        IF l_val_base_cli01 > 0 THEN
        
           DECLARE cq_futrs1 CURSOR FOR 
              SELECT a.cod_item,SUM(a.val_liq_item)
                FROM nf_item a, custo_cliche_885 b   
               WHERE a.cod_empresa  = p_cod_empresa 
                 AND a.cod_item     = b.cod_item
                 AND a.num_nff      = p_nf_mestre.num_nff
                 AND b.saldo_cliche > 0 
               GROUP BY a.cod_item 
           FOREACH  cq_futrs1 INTO l_cod_item, l_val_base_cli01
           
## repres ofi    
 
              LET l_val_base_clio1 = 0
              
              SELECT SUM(val_liq_item)
                INTO l_val_base_clio1  
                FROM nf_item  
               WHERE cod_empresa  = p_empresas_885.cod_emp_gerencial
                 AND num_nff      = p_nf_mestre.num_nff
                 AND cod_item     = l_cod_item
              IF l_val_base_clio1 IS NULL THEN 
                 LET l_val_base_clio1 = 0
              END IF    


              LET l_val_base_cli_tot = l_val_base_cli01 + l_val_base_clio1
       
              LET l_val_com_cli01 = (l_val_base_cli01 * p_repres_885.pct_rep_ofi) / 100
              
              LET l_val_com_tot = (l_val_base_cli_tot * l_pct_tot) / 100
              
              LET l_val_com_clio1 = l_val_com_tot - l_val_com_cli01
              
              LET p_com_fut_885.num_nff      = p_nf_mestre.num_nff
              LET p_com_fut_885.val_base_com = l_val_base_cli01
              LET p_com_fut_885.cod_item     = l_cod_item
              LET p_com_fut_885.dat_pagto    = p_tela.dat_pagto
              LET p_com_fut_885.dat_proces   = TODAY
              LET p_com_fut_885.nom_usuario  = p_user
              IF l_val_com_cli01 > 0 THEN
                 IF p_repres_885.ies_exp = 'N' THEN 
                    LET p_com_fut_885.cod_empresa  = p_cod_empresa 
                 ELSE
                    LET p_com_fut_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
                 END IF
                     
                 LET p_com_fut_885.cod_repres   = p_nf_mestre.cod_repres
                 LET p_com_fut_885.pct_comis    = p_repres_885.pct_rep_ofi         
                 LET p_com_fut_885.val_comis    = l_val_com_cli01
                 INSERT INTO com_fut_885  VALUES (p_com_fut_885.*)
                 IF sqlca.sqlcode <> 0 THEN 
                    CALL log003_err_sql("INCLUSAO","COM FUT REP")
                    RETURN 
                 END IF
              END IF 
              
## repres ger 
 
              IF l_val_com_clio1 > 0 THEN 
                 LET p_com_fut_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
                 LET p_com_fut_885.val_base_com = l_val_base_clio1
                 LET p_com_fut_885.cod_repres   = p_nf_mestre.cod_repres
                 IF l_val_base_clio1 > 0 THEN 
                    LET p_com_fut_885.pct_comis = (l_val_com_clio1 / l_val_base_clio1) * 100          
                 ELSE
                    LET p_com_fut_885.pct_comis = p_repres_885.pct_rep_ger
                 END IF 
                 LET p_com_fut_885.val_comis    = l_val_com_clio1
                 INSERT INTO com_fut_885  VALUES (p_com_fut_885.*)
                 IF sqlca.sqlcode <> 0 THEN 
                    CALL log003_err_sql("INCLUSAO","COM FUT REP")
                    RETURN 
                 END IF
              END IF    

## gerente ofi

              LET l_val_com_clig01 = (l_val_base_cli01 * p_repres_885.pct_ger_ofi) / 100
              
              IF p_ies_exp = 'N' THEN  
                 LET p_com_fut_885.cod_empresa  = p_cod_empresa 
              ELSE
                 LET p_com_fut_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
              END IF    
              
              LET p_com_fut_885.val_base_com = l_val_base_cli01
              LET p_com_fut_885.cod_repres   = p_repres_885.cod_gerente
              LET p_com_fut_885.pct_comis    = p_repres_885.pct_ger_ofi         
              LET p_com_fut_885.val_comis    = l_val_com_clig01
              INSERT INTO com_fut_885 VALUES (p_com_fut_885.*)
              IF sqlca.sqlcode <> 0 THEN 
                 CALL log003_err_sql("INCLUSAO","COM FUT REP")
                 RETURN 
              END IF

## gerente ger

              LET l_val_com_cligo1 = (l_val_base_clio1 * p_repres_885.pct_ger_ger) / 100
              IF l_val_com_cligo1 > 0 THEN 
                 LET p_com_fut_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
                 LET p_com_fut_885.val_base_com = l_val_base_clio1
                 LET p_com_fut_885.cod_repres   = p_repres_885.cod_gerente
                 IF l_val_base_clio1 > 0 THEN 
                    LET p_com_fut_885.pct_comis = (l_val_com_cligo1 / l_val_base_clio1) * 100        
                 ELSE
                    LET p_com_fut_885.pct_comis = p_repres_885.pct_ger_ger
                 END IF    
                 LET p_com_fut_885.val_comis    = l_val_com_clig01
                 INSERT INTO com_fut_885  VALUES (p_com_fut_885.*)
                 IF sqlca.sqlcode <> 0 THEN 
                    CALL log003_err_sql("INCLUSAO","COM FUT REP")
                    RETURN 
                 END IF
              END IF 
           END FOREACH   
        END IF 
      END IF 
      INITIALIZE p_lanc_com_885.* TO NULL
   END FOREACH
    
   DECLARE cq_nf_mes_som2 CURSOR FOR
    SELECT *
      FROM nf_mestre   
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
       AND dat_emissao >= p_tela.dat_inicio 
       AND dat_emissao <= p_tela.dat_fim     
       AND ies_situacao = "N"
       AND cod_repres = p_repres_885.cod_repres   
       AND num_nff >= 100000            

   FOREACH cq_nf_mes_som2 INTO p_nf_mestre.*

       SELECT ies_emite_dupl,
              ies_estatistica
         INTO p_ies_emite_dupl,
              p_ies_estatistica    
         FROM nat_operacao
        WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper
        
       IF p_ies_emite_dupl = 'N' OR 
          (p_ies_estatistica<> 'T' AND 
           p_ies_estatistica<> 'V') THEN
          CONTINUE FOREACH
       END IF     

       LET p_count = 0

       SELECT count(*) 
         INTO p_count              
         FROM lanc_com_885 
        WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
          AND num_nff     = p_nf_mestre.num_nff
          AND ies_origem  = "F"

       IF p_count > 0 THEN 
          CONTINUE FOREACH
       END IF
 
       LET p_nff_ch = p_nf_mestre.num_nff
       LET p_tela.num_doc = p_nff_ch 
       DISPLAY BY NAME p_tela.num_doc    
        
        LET l_pct_tot = p_repres_885.pct_rep_ofi + p_repres_885.pct_rep_ger  
        LET l_val_com_tot = (p_nf_mestre.val_tot_mercadoria * l_pct_tot) / 100 

        LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial 
        LET p_lanc_com_885.num_docum    = p_nf_mestre.num_nff
        LET p_lanc_com_885.num_nff      = p_nf_mestre.num_nff
        LET p_lanc_com_885.val_base_com = p_nf_mestre.val_tot_mercadoria
        LET p_lanc_com_885.dat_proces   = TODAY
        LET p_lanc_com_885.ies_origem   = "F" 
        LET p_lanc_com_885.ies_tip_lanc = "C"  
        LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto
        LET p_lanc_com_885.dat_ini_per  = p_tela.dat_inicio
        LET p_lanc_com_885.dat_fim_per  = p_tela.dat_fim
        LET p_lanc_com_885.nom_usuario  = p_user
        LET p_lanc_com_885.cod_repres   = p_nf_mestre.cod_repres
        LET p_lanc_com_885.pct_comis    = p_repres_885.pct_rep_ger         
        LET p_lanc_com_885.val_com_rep  = l_val_com_tot
        INSERT INTO lanc_com_885 VALUES (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")
           RETURN 
        END IF
        
#### - COMISSAO DO GERENTE 
       
       LET l_val_com_ger = (p_nf_mestre.val_tot_mercadoria * p_repres_885.pct_ger_ger) / 100

       IF l_val_com_ger > 0 THEN 
          LET p_lanc_com_885.cod_repres   = p_repres_885.cod_gerente
          LET p_lanc_com_885.pct_comis    = p_repres_885.pct_ger_ger        
          LET p_lanc_com_885.val_com_rep  = l_val_com_ger
          INSERT INTO lanc_com_885 VALUES (p_lanc_com_885.*)
          IF sqlca.sqlcode <> 0 THEN 
             CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")
             RETURN 
          END IF
       END IF    
      INITIALIZE p_lanc_com_885.* TO NULL
   END FOREACH 
END FUNCTION

#-----------------------------------------#
 FUNCTION pol0754_processa_fat_individual()
#-----------------------------------------#
 DEFINE l_val_merc         LIKE nf_mestre.val_tot_mercadoria,
        l_val_tot_nf       LIKE nf_mestre.val_tot_nff,
        l_pct_tot          LIKE repres_885.pct_rep_ofi,
        l_val_ipi          LIKE nf_mestre.val_tot_mercadoria,
        l_val_base_cliche  LIKE nf_mestre.val_tot_mercadoria,
        l_val_com_cliche   LIKE nf_mestre.val_tot_mercadoria,
        l_count            INTEGER,
        l_ies_fut          CHAR(01)         

  DECLARE cq_nf_mes_ind CURSOR FOR
    SELECT *
      FROM nf_mestre   
     WHERE cod_empresa = p_cod_empresa
       AND dat_emissao >= p_tela.dat_inicio 
       AND dat_emissao <= p_tela.dat_fim     
       AND ies_situacao = "N"
       AND cod_repres = p_repres_885.cod_repres               

   FOREACH cq_nf_mes_ind INTO p_nf_mestre.*

       SELECT ies_emite_dupl,
              ies_estatistica
         INTO p_ies_emite_dupl,
              p_ies_estatistica    
         FROM nat_operacao
        WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper
         
       IF p_ies_emite_dupl   = 'N'  OR 
         (p_ies_estatistica <> 'T'  AND 
          p_ies_estatistica <> 'V') THEN
          CONTINUE FOREACH
       END IF     

       LET p_count = 0

       SELECT count(*) 
         INTO p_count              
         FROM lanc_com_885 
        WHERE cod_empresa IN (p_cod_empresa, p_empresas_885.cod_emp_gerencial) 
          AND num_nff     = p_nf_mestre.num_nff
          AND ies_origem  = "F"

       IF p_count > 0 THEN 
          CONTINUE FOREACH
       END IF

       LET p_nff_ch = p_nf_mestre.num_nff
       LET p_tela.num_doc = p_nff_ch 
       DISPLAY BY NAME p_tela.num_doc    

       SELECT SUM(val_liq_item)
         INTO l_val_ipi
         FROM nf_item 
        WHERE cod_empresa =  p_cod_empresa
          AND num_nff     =  p_nf_mestre.num_nff
          AND cod_item    IS NULL 
        IF l_val_ipi IS NULL THEN
           LET l_val_ipi = 0    
        END IF    

        LET l_val_base_cliche = 0 

        SELECT SUM(a.val_liq_item)
          INTO l_val_base_cliche 
          FROM nf_item a, custo_cliche_885 b   
         WHERE a.cod_empresa  = p_cod_empresa 
           AND a.cod_item     = b.cod_item
           AND a.num_nff      = p_nf_mestre.num_nff
           AND b.saldo_cliche > 0 

        IF l_val_base_cliche IS NULL THEN
           LET l_val_base_cliche = 0 
        END IF     
       
        LET p_nf_mestre.val_tot_mercadoria = p_nf_mestre.val_tot_mercadoria - l_val_ipi - l_val_base_cliche
       
        LET l_val_com_ofi = (p_nf_mestre.val_tot_mercadoria * p_repres_885.pct_rep_ofi) / 100

        LET p_lanc_com_885.num_docum    = p_nf_mestre.num_nff
        LET p_lanc_com_885.num_nff      = p_nf_mestre.num_nff
        LET p_lanc_com_885.val_base_com = p_nf_mestre.val_tot_mercadoria
        LET p_lanc_com_885.dat_proces   = TODAY
        LET p_lanc_com_885.ies_origem   = "F" 
        LET p_lanc_com_885.ies_tip_lanc = "C"  
        LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto
        LET p_lanc_com_885.dat_ini_per  = p_tela.dat_inicio
        LET p_lanc_com_885.dat_fim_per  = p_tela.dat_fim
        LET p_lanc_com_885.nom_usuario  = p_user
        
       IF l_val_com_ofi > 0 THEN 
          IF p_repres_885.ies_exp = 'N' THEN 
             LET p_lanc_com_885.cod_empresa  = p_cod_empresa 
          ELSE
             LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
          END IF    
          LET p_lanc_com_885.cod_repres   = p_nf_mestre.cod_repres
          LET p_lanc_com_885.pct_comis    = p_repres_885.pct_rep_ofi         
          LET p_lanc_com_885.val_com_rep  = l_val_com_ofi
          INSERT into lanc_com_885 values (p_lanc_com_885.*)
          IF sqlca.sqlcode <> 0 THEN 
             CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")
             RETURN 
          END IF
       END IF 

###  comissao futura repres
      LET l_ies_fut = 'N'
      LET l_count = 0 
      SELECT COUNT(*)
        INTO l_count 
        FROM com_fut_885 
       WHERE num_nff = p_nf_mestre.num_nff  
         AND cod_empresa IN (p_empresas_885.cod_emp_gerencial, p_cod_empresa)
      IF l_count = 0 THEN 
         LET l_ies_fut = 'N'
      ELSE
         LET l_ies_fut = 'S'  
      END IF 

      IF l_ies_fut = 'N' THEN 
       IF l_val_base_cliche > 0 THEN

          DECLARE cq_futr1 CURSOR FOR 
             SELECT a.cod_item,SUM(a.val_liq_item)
               FROM nf_item a, custo_cliche_885 b   
              WHERE a.cod_empresa  = p_cod_empresa 
                AND a.cod_item     = b.cod_item
                AND a.num_nff      = p_nf_mestre.num_nff
                AND b.saldo_cliche > 0 
              GROUP BY a.cod_item 
          FOREACH  cq_futr1 INTO l_cod_item, l_val_base_cliche 
          
             LET l_val_com_cliche = (l_val_base_cliche * p_repres_885.pct_rep_ofi) / 100
             
             INITIALIZE p_com_fut_885.dat_libera TO NULL 
             
             LET p_com_fut_885.num_nff      = p_nf_mestre.num_nff
             LET p_com_fut_885.val_base_com = l_val_base_cliche
             LET p_com_fut_885.cod_item     = l_cod_item
             LET p_com_fut_885.dat_pagto    = p_tela.dat_pagto
             LET p_com_fut_885.dat_proces   = TODAY
             LET p_com_fut_885.nom_usuario  = p_user
             
             IF p_repres_885.ies_exp = 'N' THEN 
                LET p_com_fut_885.cod_empresa  = p_cod_empresa 
             ELSE
                LET p_com_fut_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
             END IF
                 
             LET p_com_fut_885.cod_repres   = p_nf_mestre.cod_repres
             LET p_com_fut_885.pct_comis    = p_repres_885.pct_rep_ofi         
             LET p_com_fut_885.val_comis    = l_val_com_cliche
             INSERT INTO com_fut_885  VALUES (p_com_fut_885.*)
             IF sqlca.sqlcode <> 0 THEN 
                CALL log003_err_sql("INCLUSAO","COM FUT REP")
                RETURN 
             END IF
          END FOREACH   
       END IF   
      END IF 

#### - COMISSAO DO GERENTE 
       
       LET l_val_com_ofi = (p_nf_mestre.val_tot_mercadoria * p_repres_885.pct_ger_ofi) / 100
        
       IF l_val_com_ofi > 0 THEN 
          SELECT ies_exp 
            INTO p_ies_exp 
            FROM ger_com_885
           WHERE cod_gerente =  p_repres_885.cod_gerente
          IF p_ies_exp = 'N' THEN  
             LET p_lanc_com_885.cod_empresa  = p_cod_empresa 
          ELSE
             LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
          END IF    
          LET p_com_fut_885.val_base_com  = p_nf_mestre.val_tot_mercadoria
          LET p_lanc_com_885.cod_repres   = p_repres_885.cod_gerente
          LET p_lanc_com_885.pct_comis    = p_repres_885.pct_ger_ofi     
          LET p_lanc_com_885.val_com_rep     = l_val_com_ofi
          INSERT into lanc_com_885 values (p_lanc_com_885.*)
          IF sqlca.sqlcode <> 0 THEN 
             CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")
             RETURN 
          END IF
       END IF    

###  comissao futura gerente
      IF l_ies_fut = 'N' THEN  
       IF l_val_base_cliche > 0 THEN
          DECLARE cq_futg1 CURSOR FOR 
             SELECT a.cod_item,SUM(a.val_liq_item)
               FROM nf_item a, custo_cliche_885 b   
              WHERE a.cod_empresa  = p_cod_empresa 
                AND a.cod_item     = b.cod_item
                AND a.num_nff      = p_nf_mestre.num_nff
                AND b.saldo_cliche > 0 
              GROUP BY a.cod_item 
          FOREACH  cq_futg1 INTO l_cod_item, l_val_base_cliche 
       
             LET l_val_com_cliche = (l_val_base_cliche * p_repres_885.pct_ger_ofi) / 100

             SELECT ies_exp 
               INTO p_ies_exp 
               FROM ger_com_885
              WHERE cod_gerente =  p_repres_885.cod_gerente
             
             IF p_ies_exp = 'N' THEN 
                LET p_com_fut_885.cod_empresa  = p_cod_empresa 
             ELSE
                LET p_com_fut_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
             END IF  
             
             LET p_com_fut_885.val_base_com = l_val_base_cliche
             LET p_com_fut_885.cod_item     = l_cod_item 
             LET p_com_fut_885.cod_repres   = p_repres_885.cod_gerente
             LET p_com_fut_885.pct_comis    = p_repres_885.pct_ger_ofi           
             LET p_com_fut_885.val_comis    = l_val_com_cliche
             INSERT INTO com_fut_885 VALUES (p_com_fut_885.*)
             IF sqlca.sqlcode <> 0 THEN 
                CALL log003_err_sql("INCLUSAO","COM FUT GER")
                RETURN 
             END IF
          END FOREACH    
       END IF 
      END IF   
       INITIALIZE p_lanc_com_885.* TO NULL
          
   END FOREACH   

  DECLARE cq_nf_mes_ind2 CURSOR FOR
    SELECT *
      FROM nf_mestre   
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
       AND dat_emissao >= p_tela.dat_inicio 
       AND dat_emissao <= p_tela.dat_fim     
       AND ies_situacao = "N"
       AND cod_repres = p_repres_885.cod_repres               

   FOREACH cq_nf_mes_ind2 INTO p_nf_mestre.*

       SELECT ies_emite_dupl,
              ies_estatistica
         INTO p_ies_emite_dupl,
              p_ies_estatistica    
         FROM nat_operacao
        WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper
        
       IF p_ies_emite_dupl = 'N' OR 
          (p_ies_estatistica<> 'T' AND 
           p_ies_estatistica<> 'V') THEN
          CONTINUE FOREACH
       END IF     

       SELECT SUM(val_liq_item)
         INTO l_val_ipi
         FROM nf_item 
        WHERE cod_empresa =  p_empresas_885.cod_emp_gerencial
          AND num_nff     =  p_nf_mestre.num_nff
          AND cod_item    IS NULL 
        IF l_val_ipi IS NULL THEN
           LET l_val_ipi = 0    
        END IF    

       LET p_nff_ch = p_nf_mestre.num_nff
       LET p_tela.num_doc = p_nff_ch 
       DISPLAY BY NAME p_tela.num_doc    

       LET l_val_base_cliche = 0 

       SELECT SUM(a.val_liq_item)
         INTO l_val_base_cliche 
         FROM nf_item a, custo_cliche_885 b   
        WHERE a.cod_empresa  = p_empresas_885.cod_emp_gerencial
          AND a.cod_item     = b.cod_item
          AND a.num_nff      = p_nf_mestre.num_nff
          AND b.saldo_cliche > 0 

       IF l_val_base_cliche IS NULL THEN
          LET l_val_base_cliche = 0 
       END IF     

       LET p_nf_mestre.val_tot_mercadoria = p_nf_mestre.val_tot_mercadoria - l_val_ipi - l_val_base_cliche

       LET l_val_com_ger = (p_nf_mestre.val_tot_mercadoria * p_repres_885.pct_rep_ger) / 100
        
       LET p_lanc_com_885.num_docum    = p_nf_mestre.num_nff
       LET p_lanc_com_885.num_nff      = p_nf_mestre.num_nff
       LET p_lanc_com_885.val_base_com = p_nf_mestre.val_tot_mercadoria
       LET p_lanc_com_885.dat_proces   =  TODAY
       LET p_lanc_com_885.ies_origem    = "F" 
       LET p_lanc_com_885.ies_tip_lanc =  "C"  
       LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto
       LET p_lanc_com_885.dat_ini_per  = p_tela.dat_inicio
       LET p_lanc_com_885.dat_fim_per  = p_tela.dat_fim
       LET p_lanc_com_885.nom_usuario  = p_user
        
       IF l_val_com_ger > 0 THEN 
          LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
          LET p_lanc_com_885.cod_repres   = p_nf_mestre.cod_repres
          LET p_lanc_com_885.pct_comis    = p_repres_885.pct_rep_ger         
          LET p_lanc_com_885.val_com_rep  = l_val_com_ger
          INSERT into lanc_com_885 values (p_lanc_com_885.*)
          IF sqlca.sqlcode <> 0 THEN 
             CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")
             RETURN 
          END IF
       END IF 

###  comissao futura repres 2
      IF l_ies_fut = 'N' THEN  
       IF l_val_base_cliche > 0 THEN
          DECLARE cq_futr2 CURSOR FOR 
             SELECT a.cod_item,SUM(a.val_liq_item)
               FROM nf_item a, custo_cliche_885 b   
              WHERE a.cod_empresa  = p_empresas_885.cod_emp_gerencial
                AND a.cod_item     = b.cod_item
                AND a.num_nff      = p_nf_mestre.num_nff
                AND b.saldo_cliche > 0 
              GROUP BY a.cod_item 
          FOREACH  cq_futr2 INTO l_cod_item, l_val_base_cliche 
        
             LET l_val_com_cliche = (l_val_base_cliche * p_repres_885.pct_rep_ger) / 100
             
             LET p_com_fut_885.num_nff      = p_nf_mestre.num_nff
             LET p_com_fut_885.val_base_com = l_val_base_cliche
             LET p_com_fut_885.dat_pagto    = p_tela.dat_pagto
             LET p_com_fut_885.cod_item     = l_cod_item
             LET p_com_fut_885.dat_proces   = TODAY
             LET p_com_fut_885.nom_usuario  = p_user
             LET p_com_fut_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
             LET p_com_fut_885.cod_repres   = p_nf_mestre.cod_repres
             LET p_com_fut_885.pct_comis    = p_repres_885.pct_rep_ger         
             LET p_com_fut_885.val_comis  = l_val_com_cliche
             INSERT INTO com_fut_885 VALUES (p_com_fut_885.*)
             IF sqlca.sqlcode <> 0 THEN 
                CALL log003_err_sql("INCLUSAO","COM FUT REP2")
                RETURN 
             END IF
          END FOREACH    
       END IF 
      END IF 
#### - COMISSAO DO GERENTE 

       LET l_val_com_ger = (p_nf_mestre.val_tot_mercadoria * p_repres_885.pct_ger_ger) / 100

       IF l_val_com_ger > 0 THEN 
          LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
          LET p_lanc_com_885.cod_repres   = p_repres_885.cod_gerente
          LET p_lanc_com_885.pct_comis    = p_repres_885.pct_ger_ger        
          LET p_lanc_com_885.val_com_rep  = l_val_com_ger
          INSERT INTO lanc_com_885 VALUES (p_lanc_com_885.*)
          IF sqlca.sqlcode <> 0 THEN 
             CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")
             RETURN      
          END IF
       END IF    
       
###  comissao futura gerente 2
      IF l_ies_fut = 'N' THEN 
       IF l_val_base_cliche > 0 THEN
          DECLARE cq_futg2 CURSOR FOR 
             SELECT a.cod_item,SUM(a.val_liq_item)
               FROM nf_item a, custo_cliche_885 b   
              WHERE a.cod_empresa  = p_empresas_885.cod_emp_gerencial
                AND a.cod_item     = b.cod_item
                AND a.num_nff      = p_nf_mestre.num_nff
                AND b.saldo_cliche > 0 
              GROUP BY a.cod_item 
          FOREACH  cq_futg2 INTO l_cod_item, l_val_base_cliche 
       
             LET l_val_com_cliche = (l_val_base_cliche * p_repres_885.pct_ger_ger) / 100
             LET p_com_fut_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
              
             LET p_com_fut_885.cod_repres   = p_repres_885.cod_gerente
             LET p_com_fut_885.pct_comis    = p_repres_885.pct_ger_ger           
             LET p_com_fut_885.val_comis    = l_val_com_cliche 
             LET p_com_fut_885.cod_item     = l_cod_item
             INSERT INTO com_fut_885 VALUES (p_com_fut_885.*)
             IF sqlca.sqlcode <> 0 THEN 
                CALL log003_err_sql("INCLUSAO","COM FUT GER 2")
                RETURN 
             END IF   
          END FOREACH    
       END IF 
      END IF  
      INITIALIZE p_lanc_com_885.* TO NULL
   END FOREACH 
 END FUNCTION

#-----------------------------------#
 FUNCTION pol0754_processa_dev_som()
#-----------------------------------#
 DEFINE l_val_merc         LIKE nf_mestre.val_tot_mercadoria,
        l_val_tot_nf       LIKE nf_mestre.val_tot_nff,
        l_val_merc_ger     LIKE nf_mestre.val_tot_mercadoria,
        l_pct_tot          LIKE repres_885.pct_rep_ofi,
        l_val_bas_ger_ger  LIKE nf_mestre.val_tot_mercadoria,
        l_val_bas_ger_ofi  LIKE nf_mestre.val_tot_mercadoria,
        l_com_dev          LIKE nf_mestre.val_tot_mercadoria
  
  DECLARE cq_dev_mestre CURSOR  FOR
    SELECT *
      FROM dev_mestre 
     WHERE cod_empresa = p_cod_empresa
       AND dat_lancamento >= p_tela.dat_inicio 
       AND dat_lancamento <= p_tela.dat_fim
       AND cod_repres     =  p_repres_885.cod_repres 
     ORDER BY num_nff_origem

   FOREACH cq_dev_mestre INTO p_dev_mestre.*
   
     LET p_tela.num_doc = p_dev_mestre.num_nff  
     DISPLAY BY NAME p_tela.num_doc    

     SELECT *    
       INTO p_nf_mestre.* 
       FROM nf_mestre
      WHERE cod_empresa = p_dev_mestre.cod_empresa 
        AND num_nff     = p_dev_mestre.num_nff_origem

     IF sqlca.sqlcode <> 0 THEN
        CONTINUE FOREACH
        # Alterado em 04-06-2013 por solicitacao do Reinaldo,
        # pois estaria vinculando nf e repres errado quando nota de origem = 0
        #SELECT *
        #  INTO p_nf_sup.*
        #  FROM nf_sup
        # WHERE cod_empresa   = p_cod_empresa 
        #   AND num_aviso_rec = p_dev_mestre.num_nff
        #IF SQLCA.sqlcode <> 0 THEN           
        #   CONTINUE FOREACH
        #ELSE 
        #   LET p_nf_mestre.cod_nat_oper = 100
        #   LET p_nf_mestre.num_nff  =  p_nf_sup.num_aviso_rec
        #   LET p_nf_mestre.cod_repres = p_repres_885.cod_repres 
        #END IF    
     END IF

     SELECT ies_emite_dupl,
            ies_estatistica
       INTO p_ies_emite_dupl,
            p_ies_estatistica    
       FROM nat_operacao
      WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper
      
     IF p_ies_emite_dupl = 'N' OR 
        (p_ies_estatistica<> 'T' AND 
         p_ies_estatistica<> 'V') THEN
        CONTINUE FOREACH
     END IF     

     LET p_count = 0                                                                                                                
 
     IF p_dev_mestre.num_nff_origem > 0 THEN 
        SELECT count(*) 
          INTO p_count              
          FROM lanc_com_885 
         WHERE cod_empresa IN (p_cod_empresa, p_empresas_885.cod_emp_gerencial) 
           AND num_nff     = p_dev_mestre.num_nff_origem
           AND ies_origem  = "V"
        
        IF p_count > 0 THEN
           CONTINUE FOREACH
        END IF
     ELSE
        SELECT count(*) 
          INTO p_count              
          FROM lanc_com_885 
         WHERE cod_empresa IN (p_cod_empresa, p_empresas_885.cod_emp_gerencial) 
           AND num_nff     = p_dev_mestre.num_nff 
           AND ies_origem  = "V"

        IF p_count > 0 THEN
           CONTINUE FOREACH
        END IF

     END IF 

     LET p_val_com_dev = 0
     LET p_val_base_dev= 0
 
     IF p_dev_mestre.num_nff_origem > 0 THEN 
        DECLARE cq_dev_items CURSOR FOR
          
          SELECT *
            FROM dev_item    
           WHERE cod_empresa = p_dev_mestre.cod_empresa 
             AND num_nff     = p_dev_mestre.num_nff
           ORDER BY num_sequencia  
          
        FOREACH cq_dev_items  INTO p_dev_item.*   
          
          LET p_val_base    = 0 
           
          LET p_val_base = p_dev_item.qtd_item * p_dev_item.pre_unit
          
          LET l_count = 0 

          SELECT COUNT(*) 
            INTO l_count
            FROM com_fut_885
           WHERE cod_empresa  = p_cod_empresa 
             AND num_nff      = p_dev_mestre.num_nff_origem 
             AND cod_item     = p_dev_item.cod_item 
             AND dat_libera  IS NULL 
          
          IF l_count > 0 THEN 
             LET l_val_cliche = p_val_base * (p_pct_max_cliche/100)
             UPDATE custo_cliche_885
                SET saldo_cliche = saldo_cliche + l_val_cliche
              WHERE cod_empresa  =  p_empresas_885.cod_emp_gerencial 
                AND cod_item     =  p_dev_item.cod_item 
             DECLARE cq_ft_dv CURSOR WITH HOLD FOR 
                SELECT * 
                  FROM com_fut_885
                 WHERE cod_empresa  = p_cod_empresa 
                   AND num_nff      = p_dev_mestre.num_nff_origem 
                   AND cod_item     = p_dev_item.cod_item
                   AND dat_libera  IS NULL 
             FOREACH cq_ft_dv INTO p_com_fut_885.*
                LET l_com_dev =  p_val_base *  p_com_fut_885.pct_comis 
                UPDATE com_fut_885 SET val_base_com = val_base_com - p_val_base,
                                       val_comis = val_comis - l_com_dev
                 WHERE cod_empresa  = p_com_fut_885.cod_empresa 
                   AND num_nff      = p_dev_mestre.num_nff_origem 
                   AND cod_item     = p_dev_item.cod_item
                   AND cod_repres   = p_com_fut_885.cod_repres
             END FOREACH 
             
             DELETE FROM com_fut_885 
              WHERE val_comis  <= 0
          ELSE
             LET p_val_base_dev = p_val_base_dev + p_val_base
          END IF    
        END FOREACH 
     ELSE
        LET p_val_base_dev = p_nf_sup.val_tot_nf_c
     END IF 

     LET l_val_bas_ger_ofi = p_val_base_dev

     IF p_dev_mestre.num_nff_origem > 0 THEN 
        DECLARE cq_dev_items2 CURSOR FOR
          
          SELECT *
            FROM dev_item    
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
             AND num_nff     = p_dev_mestre.num_nff
           ORDER BY num_sequencia  
          
        FOREACH cq_dev_items2  INTO p_dev_item.*   
          
          LET p_val_base    = 0 
         
          LET p_val_base = p_dev_item.qtd_item * p_dev_item.pre_unit
          LET l_count = 0 
          
          SELECT COUNT(*) 
            INTO l_count
            FROM com_fut_885
           WHERE cod_empresa  = p_empresas_885.cod_emp_gerencial
             AND num_nff      = p_dev_mestre.num_nff_origem 
             AND cod_item     = p_dev_item.cod_item 
             
          IF l_count > 0 THEN 
             LET l_val_cliche = p_val_base * (p_pct_max_cliche/100)
             UPDATE custo_cliche_885
                SET saldo_cliche = saldo_cliche + l_val_cliche
              WHERE cod_empresa  =  p_empresas_885.cod_emp_gerencial 
                AND cod_item     =  p_dev_item.cod_item 
             DELETE 
               FROM com_fut_885
              WHERE cod_empresa  = p_empresas_885.cod_emp_gerencial
                AND num_nff      = p_dev_mestre.num_nff_origem 
                AND cod_item     = p_dev_item.cod_item 
          ELSE
             LET p_val_base_dev = p_val_base_dev + p_val_base
          END IF    
        END FOREACH 
     ELSE
        SELECT *
          INTO p_nf_sup.*
          FROM nf_sup
         WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial 
           AND num_aviso_rec = p_dev_mestre.num_nff
        IF SQLCA.sqlcode <> 0 THEN           
           LET p_val_base_dev = 0
        ELSE
           LET p_val_base_dev = p_nf_sup.val_tot_nf_c
        END IF      
     END IF 
     
     LET l_val_bas_ger_ger = p_val_base_dev - l_val_bas_ger_ofi

     LET l_pct_tot = p_repres_885.pct_rep_ofi + p_repres_885.pct_rep_ger  
     LET l_val_com_ofi = (l_val_bas_ger_ofi * p_repres_885.pct_rep_ofi) / 100
     LET l_val_com_tot = (p_val_base_dev * l_pct_tot) / 100 
     LET l_val_com_ger =  l_val_com_tot - l_val_com_ofi

     LET p_lanc_com_885.num_docum    = p_nf_mestre.num_nff
     LET p_lanc_com_885.num_nff      = p_nf_mestre.num_nff
     LET p_lanc_com_885.val_base_com = l_val_bas_ger_ofi
     LET p_lanc_com_885.dat_proces   = TODAY
     LET p_lanc_com_885.ies_origem   = "V" 
     LET p_lanc_com_885.ies_tip_lanc = "D"  
     LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto
     LET p_lanc_com_885.dat_ini_per  = p_tela.dat_inicio
     LET p_lanc_com_885.dat_fim_per  = p_tela.dat_fim
     LET p_lanc_com_885.nom_usuario  = p_user
       
     IF l_val_com_ofi > 0 THEN 
        LET p_lanc_com_885.pct_comis    = p_repres_885.pct_rep_ofi
        LET p_lanc_com_885.cod_empresa  =  p_cod_empresa 
        LET p_lanc_com_885.cod_repres   =  p_nf_mestre.cod_repres 
        LET p_lanc_com_885.val_com_rep  =  l_val_com_ofi 
        INSERT into lanc_com_885 values (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTOS DEV")
           RETURN
        END IF
     END IF    
       
     IF l_val_com_ger > 0 THEN 
        LET p_lanc_com_885.cod_empresa  =  p_empresas_885.cod_emp_gerencial 
        IF l_val_bas_ger_ger = 0 THEN
           LET p_lanc_com_885.val_base_com =  l_val_bas_ger_ofi
        ELSE
           LET p_lanc_com_885.val_base_com =  l_val_bas_ger_ger
        END IF    
        LET p_lanc_com_885.cod_repres   =  p_nf_mestre.cod_repres 
        LET p_lanc_com_885.pct_comis    =  p_repres_885.pct_rep_ger
        LET p_lanc_com_885.val_com_rep  =  l_val_com_ger 
        INSERT into lanc_com_885 values (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTOS DEV")
           RETURN
        END IF
     END IF 
     
####  COMISSAO DO GERENTE 
        
     LET l_val_com_ofi = (l_val_bas_ger_ofi * p_repres_885.pct_ger_ofi) / 100
      
     IF l_val_com_ofi > 0 THEN 
        SELECT ies_exp 
          INTO p_ies_exp 
          FROM ger_com_885
         WHERE cod_gerente =  p_repres_885.cod_gerente
        IF p_ies_exp = 'N' THEN 
           LET p_lanc_com_885.cod_empresa  = p_cod_empresa 
        ELSE
           LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
        END IF    
        LET p_lanc_com_885.cod_repres   = p_repres_885.cod_gerente
        LET p_lanc_com_885.pct_comis    = p_repres_885.pct_ger_ofi     
        LET p_lanc_com_885.val_com_rep  = l_val_com_ofi
        INSERT into lanc_com_885 values (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")        
           RETURN
        END IF
     END IF    

     LET l_val_com_ger = (l_val_bas_ger_ger * p_repres_885.pct_ger_ger) / 100

     IF l_val_com_ger > 0 THEN 
        LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
        LET p_lanc_com_885.cod_repres   = p_repres_885.cod_gerente
        LET p_lanc_com_885.pct_comis    = p_repres_885.pct_ger_ger        
        LET p_lanc_com_885.val_com_rep  = l_val_com_ger
        INSERT INTO lanc_com_885 VALUES (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")        
           RETURN
        END IF
     END IF    
     INITIALIZE p_lanc_com_885.* TO NULL
        
   END FOREACH 
   
  DECLARE cq_dev_mes2 CURSOR  FOR
    SELECT *
      FROM dev_mestre 
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
       AND dat_lancamento >= p_tela.dat_inicio 
       AND dat_lancamento <= p_tela.dat_fim
       AND cod_repres     =  p_repres_885.cod_repres 
       AND num_nff_origem >= 100000
     ORDER BY num_nff_origem

   FOREACH cq_dev_mes2 INTO p_dev_mestre.*
   
     LET p_tela.num_doc = p_dev_mestre.num_nff  
     DISPLAY BY NAME p_tela.num_doc    

     SELECT *    
       INTO p_nf_mestre.* 
       FROM nf_mestre
      WHERE cod_empresa = p_dev_mestre.cod_empresa 
        AND num_nff     = p_dev_mestre.num_nff_origem

     IF sqlca.sqlcode <> 0 THEN
        SELECT *
          INTO p_nf_sup.*
          FROM nf_sup
         WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial
           AND num_aviso_rec = p_dev_mestre.num_nff
        IF SQLCA.sqlcode <> 0 THEN           
           CONTINUE FOREACH
        ELSE 
           LET p_nf_mestre.cod_nat_oper = 100
           LET p_nf_mestre.num_nff  =  p_nf_sup.num_aviso_rec
           LET p_nf_mestre.cod_repres = p_repres_885.cod_repres 
        END IF    
     END IF

     SELECT ies_emite_dupl,
            ies_estatistica
       INTO p_ies_emite_dupl,
            p_ies_estatistica    
       FROM nat_operacao
      WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper
        
     IF p_ies_emite_dupl = 'N' OR 
        (p_ies_estatistica<> 'T' AND 
         p_ies_estatistica<> 'V') THEN
        CONTINUE FOREACH
     END IF     

     LET p_count = 0                                                                                                                
 
     IF p_dev_mestre.num_nff_origem > 0 THEN 
        SELECT count(*) 
          INTO p_count              
          FROM lanc_com_885 
         WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
           AND num_nff     = p_dev_mestre.num_nff_origem
           AND ies_origem  = "V"
        
        IF p_count > 0 THEN
           CONTINUE FOREACH
        END IF
     ELSE
        SELECT count(*) 
          INTO p_count              
          FROM lanc_com_885 
         WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
           AND num_nff     = p_dev_mestre.num_nff 
           AND ies_origem  = "V"

        IF p_count > 0 THEN
           CONTINUE FOREACH
        END IF

     END IF 

     LET p_val_com_dev = 0
     LET p_val_base_dev= 0

     IF p_dev_mestre.num_nff_origem > 0 THEN 
        DECLARE cq_dev_items3 CURSOR FOR
         
          SELECT *
            FROM dev_item    
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
             AND num_nff     = p_dev_mestre.num_nff
           ORDER BY num_sequencia  
          
        FOREACH cq_dev_items3  INTO p_dev_item.*   
        
          LET p_val_base    = 0 
        
          LET p_val_base = p_dev_item.qtd_item * p_dev_item.pre_unit
          LET p_val_base_dev = p_val_base_dev + p_val_base
        END FOREACH 
     ELSE
        LET p_val_base_dev = p_nf_sup.val_tot_nf_c
     END IF 

     LET l_pct_tot = p_repres_885.pct_rep_ofi + p_repres_885.pct_rep_ger  
     LET l_val_com_ger = (p_val_base_dev * l_pct_tot) / 100 

     LET p_lanc_com_885.num_docum    = p_nf_mestre.num_nff
     LET p_lanc_com_885.num_nff      = p_nf_mestre.num_nff
     LET p_lanc_com_885.val_base_com = p_val_base_dev
     LET p_lanc_com_885.dat_proces   = TODAY
     LET p_lanc_com_885.ies_origem   = "V" 
     LET p_lanc_com_885.ies_tip_lanc = "D"  
     LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto
     LET p_lanc_com_885.dat_ini_per  = p_tela.dat_inicio
     LET p_lanc_com_885.dat_fim_per  = p_tela.dat_fim
     LET p_lanc_com_885.nom_usuario  = p_user
      
     IF l_val_com_ger > 0 THEN 
        LET p_lanc_com_885.cod_empresa  =  p_empresas_885.cod_emp_gerencial
        LET p_lanc_com_885.cod_repres   =  p_nf_mestre.cod_repres 
        LET p_lanc_com_885.pct_comis    =  p_repres_885.pct_rep_ger
        LET p_lanc_com_885.val_base_com =  p_val_base_dev
        LET p_lanc_com_885.val_com_rep  =  l_val_com_ger 
        INSERT into lanc_com_885 values (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTOS DEV")
           RETURN
        END IF
     END IF 
     
#### COMISSAO DO GERENTE 

     LET l_val_com_ger = (l_val_bas_ger_ger * p_repres_885.pct_ger_ger) / 100

     IF l_val_com_ger > 0 THEN 
        LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
        LET p_lanc_com_885.cod_repres   = p_repres_885.cod_gerente
        LET p_lanc_com_885.pct_comis    = p_repres_885.pct_ger_ger        
        LET p_lanc_com_885.val_com_rep  = l_val_com_ger
        INSERT INTO lanc_com_885 VALUES (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")        
           RETURN
        END IF
     END IF    
     INITIALIZE p_lanc_com_885.* TO NULL   
   END FOREACH 
   
END FUNCTION 

#-------------------------------------#
 FUNCTION pol0754_processa_dev_ind()
#-------------------------------------#
 DEFINE l_val_merc         LIKE nf_mestre.val_tot_mercadoria,
        l_val_tot_nf       LIKE nf_mestre.val_tot_nff,
        l_val_merc_ger     LIKE nf_mestre.val_tot_mercadoria,
        l_pct_tot          LIKE repres_885.pct_rep_ofi,
        l_val_bas_ger_ger  LIKE nf_mestre.val_tot_mercadoria,
        l_val_bas_ger_ofi  LIKE nf_mestre.val_tot_mercadoria,
        l_count            INTEGER
  
  DECLARE cq_dev_mesin CURSOR  FOR
    SELECT *
      FROM dev_mestre 
     WHERE cod_empresa = p_cod_empresa
       AND dat_lancamento >= p_tela.dat_inicio 
       AND dat_lancamento <= p_tela.dat_fim
       AND cod_repres     =  p_repres_885.cod_repres 
     ORDER BY num_nff_origem

   FOREACH cq_dev_mesin INTO p_dev_mestre.*
   
     LET p_tela.num_doc = p_dev_mestre.num_nff  
     DISPLAY BY NAME p_tela.num_doc    

     SELECT *    
       INTO p_nf_mestre.* 
       FROM nf_mestre
      WHERE cod_empresa = p_dev_mestre.cod_empresa 
        AND num_nff     = p_dev_mestre.num_nff_origem

     IF sqlca.sqlcode <> 0 THEN
        SELECT *
          INTO p_nf_sup.*
          FROM nf_sup
         WHERE cod_empresa   = p_cod_empresa 
           AND num_aviso_rec = p_dev_mestre.num_nff
        IF SQLCA.sqlcode <> 0 THEN           
           CONTINUE FOREACH
        ELSE 
           LET p_nf_mestre.cod_nat_oper = 100
           LET p_nf_mestre.num_nff  =  p_nf_sup.num_aviso_rec
           LET p_nf_mestre.cod_repres = p_repres_885.cod_repres 
        END IF    
     END IF

     SELECT ies_emite_dupl,
            ies_estatistica
       INTO p_ies_emite_dupl,
            p_ies_estatistica    
       FROM nat_operacao
      WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper
        
     IF p_ies_emite_dupl = 'N' OR 
        (p_ies_estatistica<> 'T' AND 
         p_ies_estatistica<> 'V') THEN
        CONTINUE FOREACH
     END IF     

     LET p_count = 0                                                                                                                

     IF p_dev_mestre.num_nff_origem > 0 THEN 
        SELECT count(*) 
          INTO p_count              
          FROM lanc_com_885 
         WHERE cod_empresa IN (p_cod_empresa, p_empresas_885.cod_emp_gerencial) 
           AND num_nff     = p_dev_mestre.num_nff_origem
           AND ies_origem  = "V"
        
        IF p_count > 0 THEN
           CONTINUE FOREACH
        END IF
     ELSE
        SELECT count(*) 
          INTO p_count              
          FROM lanc_com_885 
         WHERE cod_empresa IN (p_cod_empresa, p_empresas_885.cod_emp_gerencial) 
           AND num_nff     = p_dev_mestre.num_nff 
           AND ies_origem  = "V"

        IF p_count > 0 THEN
           CONTINUE FOREACH
        END IF

     END IF 

     LET p_val_com_dev = 0
     LET p_val_base_dev= 0

     IF p_dev_mestre.num_nff_origem > 0 THEN 
        DECLARE cq_dev_itin CURSOR FOR
          
          SELECT *
            FROM dev_item    
           WHERE cod_empresa = p_dev_mestre.cod_empresa 
             AND num_nff     = p_dev_mestre.num_nff
           ORDER BY num_sequencia  
          
        FOREACH cq_dev_itin  INTO p_dev_item.*   
          
          LET p_val_base    = 0 
           
          LET p_val_base = p_dev_item.qtd_item * p_dev_item.pre_unit
          
          LET l_count = 0 
          
          SELECT COUNT(*) 
            INTO l_count
            FROM com_fut_885
           WHERE cod_empresa  = p_cod_empresa 
             AND num_nff      = p_dev_mestre.num_nff_origem 
             AND cod_item     = p_dev_item.cod_item 
             
          IF l_count > 0 THEN 
             LET l_val_cliche = p_val_base * (p_pct_max_cliche/100)
             UPDATE custo_cliche_885
                SET saldo_cliche = saldo_cliche + l_val_cliche
              WHERE cod_empresa  =  p_empresas_885.cod_emp_gerencial 
                AND cod_item     =  p_dev_item.cod_item 
             DELETE 
               FROM com_fut_885
              WHERE cod_empresa  = p_cod_empresa 
                AND num_nff      = p_dev_mestre.num_nff_origem 
                AND cod_item     = p_dev_item.cod_item 
          ELSE
             LET p_val_base_dev = p_val_base_dev + p_val_base
          END IF    
        END FOREACH 
     ELSE
        LET p_val_base_dev = p_nf_sup.val_tot_nf_c
     END IF 
     
     LET l_val_com_ofi = (p_val_base_dev * p_repres_885.pct_rep_ofi) / 100

     LET p_lanc_com_885.num_docum    = p_nf_mestre.num_nff
     LET p_lanc_com_885.num_nff      = p_nf_mestre.num_nff
     LET p_lanc_com_885.val_base_com = p_val_base_dev
     LET p_lanc_com_885.dat_proces   = TODAY
     LET p_lanc_com_885.ies_origem   = "V" 
     LET p_lanc_com_885.ies_tip_lanc = "D"  
     LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto
     LET p_lanc_com_885.dat_ini_per  = p_tela.dat_inicio
     LET p_lanc_com_885.dat_fim_per  = p_tela.dat_fim
     LET p_lanc_com_885.nom_usuario  = p_user
       
     IF l_val_com_ofi > 0 THEN 
        IF p_repres_885.ies_exp = 'N' THEN  
           LET p_lanc_com_885.cod_empresa  = p_cod_empresa 
        ELSE
           LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
        END IF    

        LET p_lanc_com_885.pct_comis    =  p_repres_885.pct_rep_ofi
        LET p_lanc_com_885.cod_repres   =  p_nf_mestre.cod_repres 
        LET p_lanc_com_885.val_base_com =  p_val_base_dev
        LET p_lanc_com_885.val_com_rep  =  l_val_com_ofi 
        INSERT into lanc_com_885 values (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTOS DEV")
           RETURN
        END IF
     END IF    

####  COMISSAO DO GERENTE 
        
     LET l_val_com_ofi = (p_val_base_dev * p_repres_885.pct_ger_ofi) / 100
      
     IF l_val_com_ofi > 0 THEN 
        SELECT ies_exp 
          INTO p_ies_exp 
          FROM ger_com_885
         WHERE cod_gerente =  p_repres_885.cod_gerente
        IF p_ies_exp = 'N' THEN  
           LET p_lanc_com_885.cod_empresa  = p_cod_empresa 
        ELSE
           LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
        END IF    
        LET p_lanc_com_885.cod_repres   = p_repres_885.cod_gerente
        LET p_lanc_com_885.pct_comis    = p_repres_885.pct_ger_ofi     
        LET p_lanc_com_885.val_com_rep  = l_val_com_ofi
        INSERT into lanc_com_885 values (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")        
           RETURN
        END IF
     END IF    

     INITIALIZE p_lanc_com_885.* TO NULL
   END FOREACH        

  DECLARE cq_dev_mesin2 CURSOR  FOR
    SELECT *
      FROM dev_mestre 
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
       AND dat_lancamento >= p_tela.dat_inicio 
       AND dat_lancamento <= p_tela.dat_fim
       AND cod_repres     =  p_repres_885.cod_repres 
     ORDER BY num_nff_origem

   FOREACH cq_dev_mesin2 INTO p_dev_mestre.*
   
     LET p_tela.num_doc = p_dev_mestre.num_nff  
     DISPLAY BY NAME p_tela.num_doc    

     SELECT *    
       INTO p_nf_mestre.*
       FROM nf_mestre
      WHERE cod_empresa = p_dev_mestre.cod_empresa 
        AND num_nff     = p_dev_mestre.num_nff_origem

     IF sqlca.sqlcode <> 0 then
        SELECT *
          INTO p_nf_sup.*
          FROM nf_sup
         WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial
           AND num_aviso_rec = p_dev_mestre.num_nff
        IF SQLCA.sqlcode <> 0 THEN           
           CONTINUE FOREACH
        ELSE 
           LET p_nf_mestre.cod_nat_oper = 100
           LET p_nf_mestre.num_nff  =  p_nf_sup.num_aviso_rec
           LET p_nf_mestre.cod_repres = p_repres_885.cod_repres 
        END IF    
     END IF

     SELECT ies_emite_dupl,
            ies_estatistica
       INTO p_ies_emite_dupl,
            p_ies_estatistica    
       FROM nat_operacao
      WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper
        
     IF p_ies_emite_dupl = 'N' OR 
        (p_ies_estatistica<> 'T' AND 
         p_ies_estatistica<> 'V') THEN
        CONTINUE FOREACH
     END IF     

     LET p_count = 0                                                                                                                

     IF p_dev_mestre.num_nff_origem > 0 THEN 
        SELECT count(*) 
          INTO p_count              
          FROM lanc_com_885 
         WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
           AND num_nff     = p_dev_mestre.num_nff_origem
           AND ies_origem  = "V"
        
        IF p_count > 0 THEN
           CONTINUE FOREACH
        END IF
     ELSE
        SELECT count(*) 
          INTO p_count              
          FROM lanc_com_885 
         WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
           AND num_nff     = p_dev_mestre.num_nff 
           AND ies_origem  = "V"

        IF p_count > 0 THEN
           CONTINUE FOREACH
        END IF

     END IF 

     LET p_val_com_dev = 0
     LET p_val_base_dev= 0


     IF p_dev_mestre.num_nff_origem > 0 THEN 
        DECLARE cq_dev_itin2 CURSOR FOR
          
          SELECT *
            FROM dev_item    
           WHERE cod_empresa = p_dev_mestre.cod_empresa 
             AND num_nff     = p_dev_mestre.num_nff
           ORDER BY num_sequencia  
          
        FOREACH cq_dev_itin  INTO p_dev_item.*   
          
          LET p_val_base    = 0 
           
          LET p_val_base = p_dev_item.qtd_item * p_dev_item.pre_unit
          
          LET l_count = 0 
          
          SELECT COUNT(*) 
            INTO l_count
            FROM com_fut_885
           WHERE cod_empresa  = p_empresas_885.cod_emp_gerencial
             AND num_nff      = p_dev_mestre.num_nff_origem 
             AND cod_item     = p_dev_item.cod_item 
             
          IF l_count > 0 THEN 
             LET l_val_cliche = p_val_base * (p_pct_max_cliche/100)
             UPDATE custo_cliche_885
                SET saldo_cliche = saldo_cliche + l_val_cliche
              WHERE cod_empresa  =  p_empresas_885.cod_emp_gerencial 
                AND cod_item     =  p_dev_item.cod_item 
             DELETE 
               FROM com_fut_885
              WHERE cod_empresa  = p_empresas_885.cod_emp_gerencial
                AND num_nff      = p_dev_mestre.num_nff_origem 
                AND cod_item     = p_dev_item.cod_item 
          ELSE
             LET p_val_base_dev = p_val_base_dev + p_val_base
          END IF    
        END FOREACH 
     ELSE
        LET p_val_base_dev = p_nf_sup.val_tot_nf_c
     END IF 
        
     LET l_val_com_ger = (p_val_base_dev * p_repres_885.pct_rep_ger) / 100

     LET p_lanc_com_885.num_docum    = p_nf_mestre.num_nff
     LET p_lanc_com_885.num_nff      = p_nf_mestre.num_nff
     LET p_lanc_com_885.val_base_com = p_val_base_dev
     LET p_lanc_com_885.dat_proces   = TODAY
     LET p_lanc_com_885.ies_origem   = "V" 
     LET p_lanc_com_885.ies_tip_lanc = "D"  
     LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto
     LET p_lanc_com_885.dat_ini_per  = p_tela.dat_inicio
     LET p_lanc_com_885.dat_fim_per  = p_tela.dat_fim
     LET p_lanc_com_885.nom_usuario  = p_user

     IF l_val_com_ger > 0 THEN 
        LET p_lanc_com_885.cod_empresa  =  p_empresas_885.cod_emp_gerencial 
        LET p_lanc_com_885.cod_repres   =  p_nf_mestre.cod_repres 
        LET p_lanc_com_885.pct_comis    =  p_repres_885.pct_rep_ger
        LET p_lanc_com_885.val_base_com =  p_val_base_dev
        LET p_lanc_com_885.val_com_rep  =  l_val_com_ger 
        INSERT into lanc_com_885 values (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTOS DEV")
           RETURN
        END IF
     END IF    
     
#####  COMISSAO DO GERENTE
     
     LET l_val_com_ger = (l_val_bas_ger_ger * p_repres_885.pct_ger_ger) / 100

     IF l_val_com_ger > 0 THEN 
        LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
        LET p_lanc_com_885.cod_repres   = p_repres_885.cod_gerente
        LET p_lanc_com_885.pct_comis    = p_repres_885.pct_ger_ger        
        LET p_lanc_com_885.val_com_rep  = l_val_com_ger
        INSERT INTO lanc_com_885 VALUES (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")        
           RETURN
        END IF
     END IF    

     INITIALIZE p_lanc_com_885.* TO NULL
   END FOREACH 
   
END FUNCTION 
        
#----------------------------------#
 FUNCTION pol0754_processa_acertos()
#----------------------------------#
  DEFINE  p_mes_ref    CHAR(2),
          p_ano_ref    CHAR(4)
 
  LET p_mes_ref = month(p_tela.dat_inicio) USING '&&'
  LET p_ano_ref = year(p_tela.dat_inicio)  

  DISPLAY p_mes_ref at 5,8
  display p_ano_ref at 6,8

  LET p_tela.num_doc = 0

  DISPLAY BY NAME p_tela.num_doc    

  DECLARE cq_acertos CURSOR FOR
    SELECT *
      FROM lanc_acerto_com_885
     WHERE cod_empresa = p_cod_empresa
       AND mes_cred  = p_mes_ref          
       AND ano_cred  = p_ano_ref          

   FOREACH cq_acertos INTO p_lanc_acerto_com_885.*
   
     LET p_tela.num_doc = p_lanc_acerto_com_885.cod_repres
     DISPLAY BY NAME p_tela.num_doc    

     LET p_count = 0

     SELECT count(*) 
       INTO p_count              
       FROM lanc_com_885 
      WHERE cod_empresa = p_cod_empresa 
        AND num_nff = p_lanc_acerto_com_885.num_docum
        AND ies_origem  IN ("X","Y")

       IF p_count > 0 THEN
          CONTINUE FOREACH
       END IF

     IF p_lanc_acerto_com_885.ies_tip_lanc = "C" THEN
        LET p_lanc_com_885.ies_origem   =  "X"      
     ELSE
        LET p_lanc_com_885.ies_origem   =  "Y"      
     END IF

     LET p_lanc_com_885.cod_empresa  =  p_cod_empresa 
     LET p_lanc_com_885.num_docum    = p_lanc_acerto_com_885.num_docum
     LET p_lanc_com_885.num_nff      =  p_lanc_acerto_com_885.num_docum
     LET p_lanc_com_885.val_base_com = 0
     LET p_lanc_com_885.dat_proces   = TODAY
     LET p_lanc_com_885.ies_tip_lanc = p_lanc_acerto_com_885.ies_tip_lanc
     LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto
     LET p_lanc_com_885.dat_ini_per  = p_tela.dat_inicio
     LET p_lanc_com_885.dat_fim_per  = p_tela.dat_fim
     LET p_lanc_com_885.nom_usuario  = p_user
     LET p_lanc_com_885.cod_repres   =  p_lanc_acerto_com_885.cod_repres 
     LET p_lanc_com_885.pct_comis    =  0                
     LET p_lanc_com_885.val_com_rep  =  p_lanc_acerto_com_885.val_lanc  
     INSERT INTO lanc_com_885 values (p_lanc_com_885.*)
     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("INCLUSAO","LANCAMENTOS ACE")
     END IF
  END FOREACH 
  
  DECLARE cq_acertos2 CURSOR FOR
    SELECT *
      FROM lanc_acerto_com_885
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
       AND mes_cred  = p_mes_ref          
       AND ano_cred  = p_ano_ref          

   FOREACH cq_acertos2 INTO p_lanc_acerto_com_885.*
   
     LET p_tela.num_doc = p_lanc_acerto_com_885.cod_repres
     DISPLAY BY NAME p_tela.num_doc    

     LET p_count = 0

     SELECT count(*) 
       INTO p_count              
       FROM lanc_com_885 
      WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
        AND num_nff = p_lanc_acerto_com_885.num_docum
        AND ies_origem  IN ("X","Y")

       IF p_count > 0 THEN
          CONTINUE FOREACH
       END IF

     IF p_lanc_acerto_com_885.ies_tip_lanc = "C" THEN
        LET p_lanc_com_885.ies_origem   =  "X"      
     ELSE
        LET p_lanc_com_885.ies_origem   =  "Y"      
     END IF

     LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
     LET p_lanc_com_885.num_docum    = p_lanc_acerto_com_885.num_docum
     LET p_lanc_com_885.num_nff      = p_lanc_acerto_com_885.num_docum
     LET p_lanc_com_885.val_base_com = 0
     LET p_lanc_com_885.dat_proces   = TODAY
     LET p_lanc_com_885.ies_tip_lanc = p_lanc_acerto_com_885.ies_tip_lanc
     LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto
     LET p_lanc_com_885.dat_ini_per  = p_tela.dat_inicio
     LET p_lanc_com_885.dat_fim_per  = p_tela.dat_fim
     LET p_lanc_com_885.nom_usuario  = p_user
     LET p_lanc_com_885.cod_repres   = p_lanc_acerto_com_885.cod_repres 
     LET p_lanc_com_885.pct_comis    = 0                
     LET p_lanc_com_885.val_com_rep  = p_lanc_acerto_com_885.val_lanc  

     INSERT INTO lanc_com_885 values (p_lanc_com_885.*)
     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("INCLUSAO","LANCAMENTOS ACE")
     END IF
  END FOREACH 
 
END FUNCTION 

#-------------------------------------#
 FUNCTION pol0754_processa_descontos()
#-------------------------------------#
 DEFINE l_val_merc         LIKE nf_mestre.val_tot_mercadoria,
        l_val_tot_nf       LIKE nf_mestre.val_tot_nff,
        l_val_merc_ger     LIKE nf_mestre.val_tot_mercadoria,
        l_pct_tot          LIKE repres_885.pct_rep_ofi,
        l_val_bas_ger_ger  LIKE nf_mestre.val_tot_mercadoria,
        l_val_bas_ger_ofi  LIKE nf_mestre.val_tot_mercadoria,
        l_num_doc          CHAR(06),
        l_num_nff          DECIMAL(6,0),
        l_count            INTEGER
  
  DECLARE cq_desc CURSOR  FOR
    SELECT *
      FROM docum_pgto
     WHERE cod_empresa = p_cod_empresa
       AND dat_pgto   >= p_tela.dat_inicio 
       AND dat_pgto   <= p_tela.dat_fim
       AND ies_forma_pgto = 'AB'

  FOREACH cq_desc INTO p_docum_pgto.*

     IF p_docum_pgto.val_abat = 0 THEN 
        CONTINUE FOREACH
     END IF    
   
     LET l_count = 0 
     SELECT COUNT(*)
       INTO l_count
       FROM docum
      WHERE cod_empresa      = p_cod_empresa
        AND num_docum_origem = p_docum_pgto.num_docum
        AND ies_tip_docum    = 'NC' 
     IF SQLCA.sqlcode > 0 THEN 
        CONTINUE FOREACH
     END IF

     LET p_tela.num_doc = p_docum_pgto.num_docum 
     DISPLAY BY NAME p_tela.num_doc    

     LET l_num_doc = p_docum_pgto.num_docum[3,8]
     LET l_num_nff = l_num_doc 

     SELECT *    
       INTO p_nf_mestre.* 
       FROM nf_mestre
      WHERE cod_empresa = p_cod_empresa
        AND num_nff     = l_num_nff

     SELECT ies_emite_dupl,
            ies_estatistica
       INTO p_ies_emite_dupl,
            p_ies_estatistica    
       FROM nat_operacao
      WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper
      
     IF p_ies_emite_dupl = 'N' OR 
        (p_ies_estatistica <> 'T' AND 
         p_ies_estatistica <> 'V') THEN
        CONTINUE FOREACH
     END IF     

     LET p_count = 0                                                                                                                
 
     SELECT count(*) 
       INTO p_count              
       FROM lanc_com_885 
      WHERE cod_empresa IN (p_cod_empresa, p_empresas_885.cod_emp_gerencial) 
        AND num_nff     = l_num_nff
        AND ies_origem  = "T"
     
     IF p_count > 0 THEN
        CONTINUE FOREACH
     END IF

     SELECT * 
       INTO p_repres_885.*
       FROM repres_885
      WHERE cod_repres = p_nf_mestre.cod_repres
  
     IF p_repres_885.tip_perc = 'S' THEN
        CALL pol0754_processa_desc_som() 
     ELSE
        CALL pol0754_processa_desc_ind() 
     END IF    
  END FOREACH 


#######  DESCONTOS CONCEDIDOS NA EMPRESA O

  DECLARE cq_desc2 CURSOR  FOR
    SELECT *
      FROM docum_pgto
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
       AND dat_pgto   >= p_tela.dat_inicio 
       AND dat_pgto   <= p_tela.dat_fim
       AND ies_forma_pgto IN ('AB', 'DV')

   FOREACH cq_desc2 INTO p_docum_pgto.*

     IF p_docum_pgto.val_abat = 0 THEN 
        CONTINUE FOREACH
     END IF    
   
     LET l_count = 0 
     SELECT COUNT(*)
       INTO l_count
       FROM docum
      WHERE cod_empresa      = p_empresas_885.cod_emp_gerencial
        AND num_docum_origem = p_docum_pgto.num_docum
        AND ies_tip_docum    = 'NC' 
     IF SQLCA.sqlcode > 0 THEN 
        CONTINUE FOREACH
     END IF

     LET p_tela.num_doc = p_docum_pgto.num_docum 
     DISPLAY BY NAME p_tela.num_doc    

     LET l_num_doc = p_docum_pgto.num_docum[3,8]
     LET l_num_nff = l_num_doc 

     SELECT *    
       INTO p_nf_mestre.* 
       FROM nf_mestre
      WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
        AND num_nff     = l_num_nff

     SELECT ies_emite_dupl,
            ies_estatistica
       INTO p_ies_emite_dupl,
            p_ies_estatistica    
       FROM nat_operacao
      WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper
      
     IF p_ies_emite_dupl = 'N' OR 
        (p_ies_estatistica <> 'T' AND 
         p_ies_estatistica <> 'V') THEN
        CONTINUE FOREACH
     END IF     

     LET p_count = 0                                                                                                                
 
     SELECT count(*) 
       INTO p_count              
       FROM lanc_com_885 
      WHERE cod_empresa = p_empresas_885.cod_emp_gerencial  
        AND num_nff     = l_num_nff
        AND ies_origem  = "T"
     
     IF p_count > 0 THEN
        CONTINUE FOREACH
     END IF

     SELECT * 
       INTO p_repres_885.*
       FROM repres_885
      WHERE cod_repres = p_nf_mestre.cod_repres

     LET p_val_com_dev = 0
     LET p_val_base_dev= 0

     LET p_val_base_dev = p_docum_pgto.val_abat

     LET l_pct_tot = p_repres_885.pct_rep_ofi + p_repres_885.pct_rep_ger  
     LET l_val_com_ger = (p_val_base_dev * l_pct_tot) / 100 

     LET p_lanc_com_885.num_docum    = p_nf_mestre.num_nff
     LET p_lanc_com_885.num_nff      = p_nf_mestre.num_nff
     LET p_lanc_com_885.val_base_com = p_val_base_dev
     LET p_lanc_com_885.dat_proces   = TODAY
     LET p_lanc_com_885.ies_origem   = "T" 
     LET p_lanc_com_885.ies_tip_lanc = "D"  
     LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto
     LET p_lanc_com_885.dat_ini_per  = p_tela.dat_inicio
     LET p_lanc_com_885.dat_fim_per  = p_tela.dat_fim
     LET p_lanc_com_885.nom_usuario  = p_user
      
     IF l_val_com_ger > 0 THEN 
        LET p_lanc_com_885.cod_empresa  =  p_empresas_885.cod_emp_gerencial
        LET p_lanc_com_885.cod_repres   =  p_nf_mestre.cod_repres 
        LET p_lanc_com_885.pct_comis    =  p_repres_885.pct_rep_ger
        LET p_lanc_com_885.val_base_com =  p_val_base_dev
        LET p_lanc_com_885.val_com_rep  =  l_val_com_ger 
        INSERT into lanc_com_885 values (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTOS DEV")
           RETURN
        END IF
     END IF 
     
#### COMISSAO DO GERENTE 

     LET l_val_com_ger = (p_val_base_dev * p_repres_885.pct_ger_ger) / 100

     IF l_val_com_ger > 0 THEN 
        LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
        LET p_lanc_com_885.cod_repres   = p_repres_885.cod_gerente
        LET p_lanc_com_885.pct_comis    = p_repres_885.pct_ger_ger        
        LET p_lanc_com_885.val_com_rep  = l_val_com_ger
        INSERT INTO lanc_com_885 VALUES (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")        
           RETURN
        END IF
     END IF    
     INITIALIZE p_lanc_com_885.* TO NULL   
   END FOREACH 
   
END FUNCTION 

#-----------------------------------#
 FUNCTION pol0754_processa_desc_som()
#-----------------------------------#
 DEFINE l_val_merc         LIKE nf_mestre.val_tot_mercadoria,
        l_val_tot_nf       LIKE nf_mestre.val_tot_nff,
        l_val_merc_ger     LIKE nf_mestre.val_tot_mercadoria,
        l_pct_tot          LIKE repres_885.pct_rep_ofi,
        l_val_bas_ger_ger  LIKE nf_mestre.val_tot_mercadoria,
        l_val_bas_ger_ofi  LIKE nf_mestre.val_tot_mercadoria,
        l_num_doc          CHAR(06),
        l_num_nff          DECIMAL(6,0),
        l_count            INTEGER
  
     LET p_val_com_dev = 0
     LET p_val_base_dev= 0
 
     LET p_val_base_dev = p_docum_pgto.val_abat

     LET l_val_bas_ger_ofi = p_val_base_dev
     
     LET l_pct_tot = p_repres_885.pct_rep_ofi + p_repres_885.pct_rep_ger  
     LET l_val_com_ofi = (l_val_bas_ger_ofi * p_repres_885.pct_rep_ofi) / 100
     LET l_val_com_tot = (p_val_base_dev * l_pct_tot) / 100 
     LET l_val_com_ger =  l_val_com_tot - l_val_com_ofi

     LET p_lanc_com_885.num_docum    = p_nf_mestre.num_nff
     LET p_lanc_com_885.num_nff      = p_nf_mestre.num_nff
     LET p_lanc_com_885.val_base_com = l_val_bas_ger_ofi
     LET p_lanc_com_885.dat_proces   = TODAY
     LET p_lanc_com_885.ies_origem   = "T" 
     LET p_lanc_com_885.ies_tip_lanc = "D"  
     LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto
     LET p_lanc_com_885.dat_ini_per  = p_tela.dat_inicio
     LET p_lanc_com_885.dat_fim_per  = p_tela.dat_fim
     LET p_lanc_com_885.nom_usuario  = p_user
       
     IF l_val_com_ofi > 0 THEN 
        LET p_lanc_com_885.pct_comis    =  p_repres_885.pct_rep_ofi
        LET p_lanc_com_885.cod_empresa  =  p_cod_empresa 
        LET p_lanc_com_885.cod_repres   =  p_nf_mestre.cod_repres 
        LET p_lanc_com_885.val_com_rep  =  l_val_com_ofi 
        INSERT into lanc_com_885 values (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTOS DEV")
           RETURN
        END IF
     END IF    
       
     IF l_val_com_ger > 0 THEN 
        LET p_lanc_com_885.cod_empresa  =  p_empresas_885.cod_emp_gerencial 
        IF l_val_bas_ger_ger = 0 THEN
           LET p_lanc_com_885.val_base_com =  l_val_bas_ger_ofi
        ELSE
           LET p_lanc_com_885.val_base_com =  l_val_bas_ger_ofi
        END IF    
        LET p_lanc_com_885.cod_repres   =  p_nf_mestre.cod_repres 
        LET p_lanc_com_885.pct_comis    =  p_repres_885.pct_rep_ger
        LET p_lanc_com_885.val_com_rep  =  l_val_com_ger 
        INSERT into lanc_com_885 values (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTOS DEV")
           RETURN
        END IF
     END IF 
     
####  COMISSAO DO GERENTE 
     LET l_pct_tot = p_repres_885.pct_ger_ofi + p_repres_885.pct_ger_ger  
     LET l_val_com_ofi = (l_val_bas_ger_ofi * p_repres_885.pct_ger_ofi) / 100
     LET l_val_com_tot = (p_val_base_dev * l_pct_tot) / 100 
     LET l_val_com_ger =  l_val_com_tot - l_val_com_ofi
      
     IF l_val_com_ofi > 0 THEN 
        SELECT ies_exp 
          INTO p_ies_exp 
          FROM ger_com_885
         WHERE cod_gerente =  p_repres_885.cod_gerente
        IF p_ies_exp = 'N' THEN 
           LET p_lanc_com_885.cod_empresa  = p_cod_empresa 
        ELSE
           LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
        END IF    
        LET p_lanc_com_885.cod_repres   = p_repres_885.cod_gerente
        LET p_lanc_com_885.pct_comis    = p_repres_885.pct_ger_ofi     
        LET p_lanc_com_885.val_com_rep  = l_val_com_ofi
        INSERT into lanc_com_885 values (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")        
           RETURN
        END IF
     END IF    

     IF l_val_com_ger > 0 THEN 
        LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
        LET p_lanc_com_885.cod_repres   = p_repres_885.cod_gerente
        LET p_lanc_com_885.pct_comis    = p_repres_885.pct_ger_ger        
        LET p_lanc_com_885.val_com_rep  = l_val_com_ger
        INSERT INTO lanc_com_885 VALUES (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")        
           RETURN
        END IF
     END IF    
     INITIALIZE p_lanc_com_885.* TO NULL
  
END FUNCTION 

#-------------------------------------#
 FUNCTION pol0754_processa_desc_ind()
#-------------------------------------#
 DEFINE l_val_merc         LIKE nf_mestre.val_tot_mercadoria,
        l_val_tot_nf       LIKE nf_mestre.val_tot_nff,
        l_val_merc_ger     LIKE nf_mestre.val_tot_mercadoria,
        l_pct_tot          LIKE repres_885.pct_rep_ofi,
        l_val_bas_ger_ger  LIKE nf_mestre.val_tot_mercadoria,
        l_val_bas_ger_ofi  LIKE nf_mestre.val_tot_mercadoria
  

     LET p_val_com_dev = 0
     LET p_val_base_dev= 0
 
     LET p_val_base_dev = p_docum_pgto.val_abat
     
     LET l_val_com_ofi = (p_val_base_dev * p_repres_885.pct_rep_ofi) / 100

     LET p_lanc_com_885.num_docum    = p_nf_mestre.num_nff
     LET p_lanc_com_885.num_nff      = p_nf_mestre.num_nff
     LET p_lanc_com_885.val_base_com = p_val_base_dev
     LET p_lanc_com_885.dat_proces   = TODAY
     LET p_lanc_com_885.ies_origem   = "T" 
     LET p_lanc_com_885.ies_tip_lanc = "D"  
     LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto
     LET p_lanc_com_885.dat_ini_per  = p_tela.dat_inicio
     LET p_lanc_com_885.dat_fim_per  = p_tela.dat_fim
     LET p_lanc_com_885.nom_usuario  = p_user
       
     IF l_val_com_ofi > 0 THEN 
        IF p_repres_885.ies_exp = 'N' THEN  
           LET p_lanc_com_885.cod_empresa  = p_cod_empresa 
        ELSE
           LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
        END IF    

        LET p_lanc_com_885.pct_comis    =  p_repres_885.pct_rep_ofi
        LET p_lanc_com_885.cod_repres   =  p_nf_mestre.cod_repres 
        LET p_lanc_com_885.val_base_com =  p_val_base_dev
        LET p_lanc_com_885.val_com_rep  =  l_val_com_ofi 
        INSERT into lanc_com_885 values (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTOS DEV")
           RETURN
        END IF
     END IF    

####  COMISSAO DO GERENTE 
        
     LET l_val_com_ofi = (p_val_base_dev * p_repres_885.pct_ger_ofi) / 100
      
     IF l_val_com_ofi > 0 THEN 
        SELECT ies_exp 
          INTO p_ies_exp 
          FROM ger_com_885
         WHERE cod_gerente =  p_repres_885.cod_gerente
        IF p_ies_exp = 'N' THEN  
           LET p_lanc_com_885.cod_empresa  = p_cod_empresa 
        ELSE
           LET p_lanc_com_885.cod_empresa  = p_empresas_885.cod_emp_gerencial
        END IF    
        LET p_lanc_com_885.cod_repres   = p_repres_885.cod_gerente
        LET p_lanc_com_885.pct_comis    = p_repres_885.pct_ger_ofi     
        LET p_lanc_com_885.val_com_rep  = l_val_com_ofi
        INSERT into lanc_com_885 values (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTO NF")        
           RETURN
        END IF
     END IF    

     INITIALIZE p_lanc_com_885.* TO NULL

END FUNCTION 

### -- atualiza saldo de cliches antes de calcular comissoes
#----------------------------------#
 FUNCTION pol0754_checa_cliches()
#----------------------------------#
  DEFINE l_val_cliche_it      DECIMAL(15,2),
         l_count              INTEGER
  
  DECLARE cq_clic CURSOR WITH HOLD FOR
    SELECT cod_item 
      FROM custo_cliche_885 
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
    FOREACH cq_clic INTO p_nf_item.cod_item 
       DECLARE cq_itf CURSOR FOR 
          SELECT a.cod_empresa,a.num_nff,a.cod_nat_oper,b.num_sequencia,b.val_liq_item
            FROM nf_mestre a, nf_item b 
           WHERE a.cod_empresa  IN (p_cod_empresa, p_empresas_885.cod_emp_gerencial)
             AND a.dat_emissao >= p_tela.dat_inicio 
             AND a.dat_emissao <= p_tela.dat_fim     
             AND a.ies_situacao = 'N' 
             AND a.cod_empresa = b.cod_empresa 
             AND a.num_nff     = b.num_nff
             AND b.cod_item    = p_nf_item.cod_item
       FOREACH cq_itf INTO p_nf_item.cod_empresa,
                           p_nf_item.num_nff,
                           p_nf_mestre.cod_nat_oper,
                           p_nf_item.num_sequencia,
                           p_nf_item.val_liq_item     
           SELECT COUNT(*)
             INTO l_count
             FROM lanc_cliche_885
            WHERE num_nff    = p_nf_item.num_nff
              AND cod_item   = p_nf_item.cod_item
              AND cod_empresa= p_nf_item.cod_empresa  
           IF l_count > 0 THEN    
              CONTINUE FOREACH
           END IF 

           SELECT ies_emite_dupl,
                  ies_estatistica
             INTO p_ies_emite_dupl,
                  p_ies_estatistica    
             FROM nat_operacao
            WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper
             
           IF p_ies_emite_dupl   = 'N'  OR 
             (p_ies_estatistica <> 'T'  AND 
              p_ies_estatistica <> 'V') THEN
              CONTINUE FOREACH
           END IF     
              
           LET l_val_cliche_it =  p_nf_item.val_liq_item * (p_pct_max_cliche/100)
           
           UPDATE custo_cliche_885 
              SET saldo_cliche = saldo_cliche - l_val_cliche_it
            WHERE cod_empresa  = p_empresas_885.cod_emp_gerencial
              AND cod_item     = p_nf_item.cod_item 
           
           IF sqlca.sqlcode <> 0 THEN 
              CALL log003_err_sql("ATUALIZACAO","CUSTO_CLICHE_885")        
              EXIT FOREACH
           END IF
           
           INSERT INTO lanc_cliche_885 VALUES 
             ( p_nf_item.cod_empresa, 
               p_nf_item.num_nff, 
               p_nf_item.num_sequencia, 
               p_nf_item.cod_item, 
               l_val_cliche_it) 

           IF sqlca.sqlcode <> 0 THEN 
              CALL log003_err_sql("INCLUSAO","LANC_CLICHE_885")        
              EXIT FOREACH
           END IF
                      
        END FOREACH    
    END FOREACH

END FUNCTION 

### -- libera comissao futura qdo saldo de cliche = 0
#-------------------------------#
 FUNCTION pol0754_libera_cliche()
#-------------------------------#
  DEFINE l_val_cliche_it      DECIMAL(15,2),
         l_count              INTEGER
  
  DECLARE cq_lib_cl CURSOR FOR
    SELECT a.*
      FROM com_fut_885 a, custo_cliche_885 b
     WHERE a.cod_empresa  IN ('01','O1')
       AND a.cod_item     = b.cod_item
       AND b.saldo_cliche <= 0
       AND dat_libera IS NULL        
    FOREACH cq_lib_cl INTO p_com_fut_885.*
        
        LET l_count = 0 
        SELECT COUNT(*) 
          INTO l_count
          FROM lanc_com_885 
         WHERE cod_empresa =  p_com_fut_885.cod_empresa
           AND num_nff     =  p_com_fut_885.num_nff
           AND ies_origem   = "R"
           AND ies_tip_lanc = "C"  
        IF l_count > 0 THEN 
           CONTINUE FOREACH 
        END IF 
           
        LET p_lanc_com_885.num_docum    = p_com_fut_885.num_nff
        LET p_lanc_com_885.num_nff      = p_com_fut_885.num_nff
        LET p_lanc_com_885.val_base_com = p_com_fut_885.val_base_com
        LET p_lanc_com_885.dat_proces   = TODAY
        LET p_lanc_com_885.ies_origem   = "R" 
        LET p_lanc_com_885.ies_tip_lanc = "C"  
        LET p_lanc_com_885.dat_pagto    = p_tela.dat_pagto
        LET p_lanc_com_885.dat_ini_per  = p_tela.dat_inicio
        LET p_lanc_com_885.dat_fim_per  = p_tela.dat_fim
        LET p_lanc_com_885.nom_usuario  = p_user
        LET p_lanc_com_885.cod_empresa  = p_com_fut_885.cod_empresa 
        LET p_lanc_com_885.cod_repres   = p_com_fut_885.cod_repres
        LET p_lanc_com_885.pct_comis    = p_com_fut_885.pct_comis         
        LET p_lanc_com_885.val_com_rep  = p_com_fut_885.val_comis
 
        INSERT INTO lanc_com_885 VALUES (p_lanc_com_885.*)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","LANCAMENTO FUT")
           RETURN 
        END IF

        INSERT INTO wcli_pg VALUES (p_com_fut_885.cod_empresa,
                                    p_com_fut_885.num_nff,
                                    p_com_fut_885.cod_item,
                                    p_com_fut_885.dat_pagto)
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","wcli_pg")
           RETURN 
        END IF
    END FOREACH

  DECLARE cq_dl_cl CURSOR FOR
    SELECT *
      FROM wcli_pg 
    FOREACH cq_dl_cl INTO p_com_fut_885.*
       UPDATE com_fut_885
          SET dat_libera = p_com_fut_885.dat_pagto
         WHERE cod_empresa = p_com_fut_885.cod_empresa
           AND cod_item    = p_com_fut_885.cod_item
           AND num_nff     = p_com_fut_885.num_nff
           AND dat_pagto   = p_com_fut_885.dat_pagto
    END FOREACH

END FUNCTION 


### ROTINA A SER FEITA
{#----------------------------------#
 FUNCTION pol0754_processa_baixas()
#----------------------------------#

  DECLARE cq_docum_pgto CURSOR FOR
    SELECT *
      FROM docum_pgto  
     WHERE cod_empresa = p_cod_empresa
       AND dat_pgto >= p_tela.dat_inicio-30
       AND dat_pgto <= p_tela.dat_fim   
       AND ies_tip_docum <> "ND"  

   FOREACH cq_docum_pgto INTO p_docum_pgto.*

      SELECT * 
         INTO p_tip_pag_com.*
      FROM tip_pag_com_helios
      WHERE cod_empresa   = p_cod_empresa                 
        AND ies_forma_pag = p_docum_pgto.ies_forma_pgto

      IF sqlca.sqlcode <> 0 THEN
         CONTINUE FOREACH
      END IF

      LET p_tela.num_doc = p_docum_pgto.num_docum
      DISPLAY BY NAME p_tela.num_doc    

      LET p_count = 0                                
      SELECT count(*)
         INTO p_count 
      FROM lanc_com_885
      WHERE cod_empresa = p_docum_pgto.cod_empresa 
        AND num_docum   = p_docum_pgto.num_docum   
        AND ies_tip_docum=p_docum_pgto.ies_tip_docum 
        AND num_seq_docum=p_docum_pgto.num_seq_docum
      IF p_count > 0 THEN
         CONTINUE FOREACH
      END IF

      SELECT *
         INTO p_docum.*
      FROM docum 
      WHERE cod_empresa = p_cod_empresa 
        AND num_docum = p_docum_pgto.num_docum
        AND ies_tip_docum = p_docum_pgto.ies_tip_docum 
      IF sqlca.sqlcode <> 0 THEN
         CONTINUE FOREACH
      END IF
      LET p_nff_nu = " "

      FOR p_i = 1 TO 6 
         IF p_docum.num_docum_origem[p_i] IS NULL OR
            p_docum.num_docum_origem[p_i] = " " THEN
            CONTINUE FOR
         ELSE
            LET p_nff_nu = p_nff_nu CLIPPED, p_docum.num_docum_origem[p_i]
         END IF
      END FOR  

      IF p_nff_nu IS NULL OR
         p_nff_nu = " " THEN
         LET p_nff_nu = "000000" 
      ELSE
         LET p_nff_nu = p_nff_nu CLIPPED
      END IF

   #  LET p_nff_nu = p_docum.num_docum_origem[1,6]
      LET p_count = 0                                

      SELECT count(*)
         INTO p_count 
      FROM lanc_com_885
      WHERE cod_empresa = p_docum_pgto.cod_empresa 
        AND num_nff     = p_nff_nu                
        AND ies_origem = "F"                          
      IF p_count > 0 THEN
         CONTINUE FOREACH
      END IF

      LET p_num_pedido = 0

      DECLARE cq_nf_itemb  CURSOR FOR
      SELECT num_pedido
      FROM nf_item     
      WHERE cod_empresa = p_cod_empresa
        AND num_nff     = p_nff_nu              

      FOREACH cq_nf_itemb INTO p_num_pedido  
         EXIT FOREACH
      END FOREACH

      LET p_val_pago = p_docum_pgto.val_pago - p_docum_pgto.val_juro_pago

      LET p_pct_pagto = p_val_pago / p_docum.val_bruto  
      IF p_pct_pagto > 1 THEN 
         LET p_pct_pagto = 1
      END IF

      LET p_val_base_com = p_docum.val_liquido * p_pct_pagto 

      LET p_lanc_com_885.val_com_rep = (p_val_base_com * p_docum.pct_comis_1) / 100

      LET p_lanc_com_885.cod_empresa   = p_cod_empresa 
      LET p_lanc_com_885.cod_repres    = p_docum.cod_repres_1
      LET p_lanc_com_885.cod_cliente   = p_docum.cod_cliente 
      LET p_lanc_com_885.num_pedido    = p_num_pedido            
      LET p_lanc_com_885.num_docum     = p_docum_pgto.num_docum  
      LET p_lanc_com_885.num_nff       = p_nff_nu                 
      LET p_lanc_com_885.ies_tip_docum = p_docum_pgto.ies_tip_docum
      LET p_lanc_com_885.num_seq_docum = p_docum_pgto.num_seq_docum
      LET p_lanc_com_885.ies_tip_lanc  = p_tip_pag_com.ies_tip_lanc
      LET p_lanc_com_885.ies_origem    = "B"      
      LET p_lanc_com_885.dat_vencto    = p_docum.dat_vencto_s_desc
      LET p_lanc_com_885.dat_pag_doc   = p_docum_pgto.dat_pgto         
      LET p_lanc_com_885.val_pago      = p_docum_pgto.val_pago         
      LET p_lanc_com_885.val_base_com   = p_val_base_com                
      LET p_lanc_com_885.pct_comis     = p_docum.pct_comis_1           
      LET p_lanc_com_885.dat_criacao   = TODAY    
      LET p_lanc_com_885.dat_pagto     = p_tela.dat_pagto
      LET p_lanc_com_885.nom_usuario   = p_user             
      INSERT into lanc_com_885 values (p_lanc_com_885.*)
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","LANCAMENTOS BAIXAS")        
      ELSE
         INITIALIZE p_lanc_com_885.* TO NULL
      END IF

   END FOREACH 

END FUNCTION}

#-----------------------#
 FUNCTION pol0754_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION