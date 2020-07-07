DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_oper_ent_vrqtd LIKE estoque_trans.cod_operacao,                     
          p_cod_operac_estoq_c LIKE estoque_trans.cod_operacao,  
          p_prox_fec           LIKE par_estoque.dat_prx_fecha_est,
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_ies_tip_item       LIKE item.ies_tip_item,
          p_ies_situacao       LIKE item.ies_situacao,
          p_cod_grupo_item     LIKE item_vdp.cod_grupo_item, 
          p_qtd_movto_prd      LIKE estoque_trans.qtd_movto,      
          p_cus_tot_mv         LIKE estoque_trans.cus_tot_movto_p, 
          p_num_ordem_pai      DECIMAL(6,0),
          p_num_docum          CHAR(15),
          p_num_doc_pai        CHAR(15),
          p_cus_unit           DECIMAL(15,2),
          p_cus_tot_mp         DECIMAL(15,2), 
          p_pre_unit           DECIMAL(15,2), 
          p_num_doc            CHAR(15),
          p_num_transac        INTEGER,
          p_cod_item           CHAR(15),
          p_cod_emp            CHAR(02),
          p_dat_txt            CHAR(10),
          p_dia_txt            CHAR(02),
          p_ano_mes_ref        CHAR(06),
          p_ano_mes_fec        CHAR(06), 
          p_num_lote_dest      CHAR(15),
          p_dat_sup            DATE,
          p_dat_est            DATE,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_des_erro           CHAR(060),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(80)
          
   DEFINE p_tela               RECORD
          cod_empresa           CHAR(02),
          dat_ini               DATE,
          dat_fim               DATE
   END RECORD

    DEFINE p_tmp_custo     RECORD
      num_ordem       CHAR(15),
      cod_item        CHAR(15),
      cod_item_pai    CHAR(15),
      num_ordem_pai   CHAR(15),
      cus_unit        DECIMAL(15,2)   
   END RECORD

    DEFINE p_tmp_estoq     RECORD
      num_transac     INTEGER,
      cus_unit        DECIMAL(15,2),
      cus_tot         DECIMAL(15,2)
   END RECORD

   DEFINE    p_empresas_885        RECORD LIKE empresas_885.*,
             p_estoque_trans       RECORD LIKE estoque_trans.*,
             p_ordens              RECORD LIKE ordens.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0974-05.10.06"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0974.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0974_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0974_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0974") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0974 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa dados"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL  pol0974_cria_temp() 
         IF pol0974_informar() THEN
            NEXT OPTION 'Processar'
         END IF
      COMMAND "Processar" "Processa a valorizacao do estoque - IMPL"
         HELP 001
         MESSAGE ""
         LET int_flag = 0
         IF p_ies_cons THEN 
            IF log005_seguranca(p_user,"VDP","pol0974","IN") THEN
               IF log004_confirm(19,41) THEN
                  CALL log085_transacao("BEGIN")
                  IF pol0974_processa() THEN
                     MESSAGE "Foram Processado(s) ",p_count,' Item(ns).'
                        ATTRIBUTE(REVERSE)
                     CALL log085_transacao("COMMIT")
                  ELSE
                     MESSAGE "Erro no Processamento !!!" ATTRIBUTE(REVERSE)
                     CALL log085_transacao("ROLLBACK")
                  END IF
                  NEXT OPTION "Fim"
               ELSE
                  ERROR "Operação Cancelada !!!"
               END IF
            END IF
         ELSE
            ERROR "Informe os parâmetros previamente !!!"
            NEXT OPTION "Informar"
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Sai do programa"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0974

END FUNCTION

#--------------------------#
FUNCTION pol0974_cria_temp()
#--------------------------#
   WHENEVER ERROR CONTINUE

   DROP TABLE tmp_lote
   CREATE TEMP TABLE tmp_lote
     (
      num_lote     CHAR(15) 
     );

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-tmp_lote")
   END IF
   DELETE FROM tmp_lote

   DROP TABLE tmp_custo
   CREATE TEMP TABLE tmp_custo
     (
      num_ordem       CHAR(15),
      cod_item        CHAR(15),
      cod_item_pai    CHAR(15),
      num_ordem_pai   CHAR(15),
      cus_unit        DECIMAL(15,2) 
     );

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-tmp_ordem")
   END IF
   
   DELETE FROM tmp_custo

   DROP TABLE tmp_estoq
   CREATE TEMP TABLE tmp_estoq
     (
      num_transac     INTEGER,
      cus_unit        DECIMAL(15,2),
      cus_tot         DECIMAL(15,2)
     );

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-tmp_ordem")
   END IF
   
   DELETE FROM tmp_estoq

   WHENEVER ERROR STOP
 
END FUNCTION

#--------------------------#
FUNCTION pol0974_informar()
#--------------------------#
 DEFINE l_count   INTEGER
 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0974
   CLEAR FORM
   
   INITIALIZE p_tela TO NULL
   LET p_tela.cod_empresa = p_cod_empresa
   DISPLAY p_tela.cod_empresa TO cod_empresa
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD dat_ini
         IF p_tela.dat_ini IS NULL THEN
            ERROR 'Informe Periodo !!!'
            NEXT FIELD dat_ini
         END IF

      AFTER FIELD dat_fim
         IF p_tela.dat_fim IS NULL THEN
            ERROR 'Informe Periodo !!!'
            NEXT FIELD dat_fim
         END IF 
   END INPUT

   IF INT_FLAG = 0 THEN
      LET p_ies_cons = TRUE
   END IF

   RETURN(p_ies_cons)

END FUNCTION

#--------------------------#
FUNCTION pol0974_processa()
#--------------------------#
DEFINE l_count  INTEGER 
   MESSAGE "Aguarde. Processando ..." ATTRIBUTE(REVERSE)
    
      LET p_count = 0  

      DECLARE cq_estlt CURSOR FOR 
       SELECT DISTINCT num_lote_dest
         FROM estoque_trans
        WHERE cod_empresa  = p_cod_empresa
          AND cod_operacao = 'APON'
          AND dat_movto >= p_tela.dat_ini
          AND dat_movto <= p_tela.dat_fim
      FOREACH cq_estlt INTO p_num_lote_dest
                
          INSERT INTO tmp_lote VALUES (p_num_lote_dest)
          IF SQLCA.sqlcode <> 0 THEN 
             CALL log003_err_sql("INCLUSAO","tmp_lote")
             RETURN FALSE
          END IF 
        
      END FOREACH

      DECLARE cq_tmplt CURSOR FOR 
       SELECT *
         FROM tmp_lote
      FOREACH cq_tmplt INTO p_num_lote_dest
        DECLARE ct_ord CURSOR FOR 
          SELECT num_ordem,cod_item,cod_item_pai
            FROM ordens  
           WHERE cod_empresa  = p_cod_empresa
             AND num_lote     = p_num_lote_dest
          ORDER BY num_ordem DESC
           
         FOREACH ct_ord INTO p_ordens.num_ordem,p_ordens.cod_item,p_ordens.cod_item_pai
            LET p_num_ordem_pai = 0 
            IF p_ordens.cod_item_pai <> '0' THEN
               SELECT num_ordem
                 INTO p_num_ordem_pai
                 FROM ordens  
                WHERE cod_empresa  = p_cod_empresa
                  AND num_lote     = p_num_lote_dest
                  AND cod_item     = p_ordens.cod_item_pai
            END IF  

            LET p_num_doc = p_ordens.num_ordem    
            SELECT sum(qtd_movto)
              INTO p_qtd_movto_prd
              FROM estoque_trans
             WHERE cod_empresa    = p_cod_empresa
               AND num_docum      = p_num_doc
               AND ies_tip_movto  = 'N'
               AND cod_operacao   = 'APON'

            LET l_count = 0 
            SELECT count(*)
              INTO l_count 
              FROM tmp_custo
             WHERE num_ordem_pai = p_num_doc
                
            IF l_count > 0 THEN 
               CALL pol0974_calc_custo_prod()            
            ELSE
               SELECT sum(cus_tot_movto_p)
                 INTO p_cus_tot_mp
                 FROM estoque_trans
                WHERE cod_empresa    = p_cod_empresa
                  AND num_docum      = p_num_doc
                  AND ies_tip_movto  = 'N'
                  AND cod_operacao   IN ('BPRD','BXAM')
            END IF   
            LET  p_cus_unit =  p_cus_tot_mp / p_qtd_movto_prd

            LET p_num_doc_pai = p_num_ordem_pai  
            
            IF p_cus_unit IS NOT NULL THEN 
               INSERT INTO tmp_custo VALUES ( p_num_doc,p_ordens.cod_item,p_ordens.cod_item_pai,p_num_doc_pai,p_cus_unit)
             
               IF SQLCA.sqlcode <> 0 THEN 
                  CALL log003_err_sql("INCLUSAO","tmp_CUSTO")
                  RETURN FALSE
               END IF
            END IF    
         END FOREACH
      END FOREACH       

      IF pol0974_efetiva_atualiz() THEN 
         RETURN TRUE
      ELSE 
         RETURN FALSE
      END IF 
      
END FUNCTION

#--------------------------------#
FUNCTION pol0974_calc_custo_prod()
#--------------------------------#
DEFINE l_cus_tot  DECIMAL(15,2),
       l_qtd_tot  DECIMAL(12,3),
       l_cus_it   DECIMAL(15,2)

  LET l_cus_tot = 0 
   
  DECLARE cq_cus_prod CURSOR FOR 
   SELECT *
     FROM tmp_custo
    WHERE num_ordem_pai = p_num_doc  
  FOREACH cq_cus_prod INTO p_tmp_custo.*
       LET l_cus_it = 0 
       SELECT SUM(qtd_movto)
         INTO l_qtd_tot
         FROM estoque_trans 
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = p_tmp_custo.cod_item
          AND num_docum   = p_tmp_custo.num_ordem_pai 
          AND cod_operacao   IN ('BPRD','BXAM') 

       LET l_cus_it  =  l_qtd_tot * p_tmp_custo.cus_unit
       LET l_cus_tot =  l_cus_tot + l_cus_it
  END FOREACH 

  LET p_cus_tot_mp = l_cus_tot
END FUNCTION


#--------------------------------#
FUNCTION pol0974_efetiva_atualiz()
#--------------------------------#

   DECLARE cq_atual CURSOR FOR 
    SELECT *
      FROM tmp_custo
   FOREACH cq_atual INTO p_tmp_custo.*

     DECLARE cq_estt1 CURSOR FOR
       SELECT * 
         FROM estoque_trans
        WHERE cod_empresa = p_cod_empresa
          AND num_docum   = p_tmp_custo.num_ordem
          AND cod_item    = p_tmp_custo.cod_item
          AND cod_operacao = 'APON'
     FOREACH cq_estt1 INTO p_estoque_trans.*
       LET  p_tmp_estoq.num_transac   =    p_estoque_trans.num_transac
       LET  p_tmp_estoq.cus_unit      =    p_tmp_custo.cus_unit
       LET  p_tmp_estoq.cus_tot       =    p_estoque_trans.qtd_movto * p_tmp_custo.cus_unit
       INSERT INTO tmp_estoq VALUES (p_tmp_estoq.*)
     END FOREACH   

     IF p_tmp_custo.num_ordem_pai <> '0' THEN  
        DECLARE cq_estt2 CURSOR FOR
          SELECT * 
            FROM estoque_trans
           WHERE cod_empresa = p_cod_empresa
             AND num_docum   = p_tmp_custo.num_ordem_pai
             AND cod_item    = p_tmp_custo.cod_item
             AND cod_operacao IN ('BPRD','BXAM') 
        FOREACH cq_estt2 INTO p_estoque_trans.*
          LET  p_tmp_estoq.num_transac   =    p_estoque_trans.num_transac
          LET  p_tmp_estoq.cus_unit      =    p_tmp_custo.cus_unit
          LET  p_tmp_estoq.cus_tot       =    p_estoque_trans.qtd_movto * p_tmp_custo.cus_unit
          INSERT INTO tmp_estoq VALUES (p_tmp_estoq.*)
        END FOREACH
     END IF       
   END FOREACH       	

   DECLARE cq_efet CURSOR FOR 
    SELECT *
      FROM tmp_estoq
   FOREACH cq_efet INTO p_tmp_estoq.*
      UPDATE estoque_trans SET cus_unit_movto_p = p_tmp_estoq.cus_unit,
                               cus_tot_movto_p  = p_tmp_estoq.cus_tot
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_tmp_estoq.num_transac                         
      
      IF SQLCA.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","ESTOQUE_TRANS")
         RETURN FALSE
      END IF

      UPDATE estoque_trans_end SET cus_unit_movto_p = p_tmp_estoq.cus_unit,
                                   cus_tot_movto_p  = p_tmp_estoq.cus_tot
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_tmp_estoq.num_transac                         
      
      IF SQLCA.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","ESTOQUE_TRANS_END")
         RETURN FALSE
      END IF

      LET p_count = p_count + 1
   END FOREACH     
   RETURN TRUE 
   
END FUNCTION