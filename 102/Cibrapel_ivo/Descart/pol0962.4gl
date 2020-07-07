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
          p_dat_txt            CHAR(10),
          p_dia_txt            CHAR(02),
          p_ano_mes_ref        CHAR(06),
          p_ano_mes_fec        CHAR(06),
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
          dat_ini               DATE,
          dat_fim               DATE,
          cod_item              CHAR(15),
          val_item              DECIMAL(15,6),
          den_item              CHAR(65),
          cod_op1               CHAR(04),
          cod_op2               CHAR(04),
          cod_op3               CHAR(04),
          cod_op4               CHAR(04),
          cod_op5               CHAR(04),
          cod_op6               CHAR(04),
          cod_op7               CHAR(04),
          cod_op8               CHAR(04),
          cod_op9               CHAR(04),
          cod_op10              CHAR(04)
   END RECORD

   DEFINE p_tmp_transac     RECORD
      cod_empresa  CHAR(02),
      num_transac    INTEGER,
      val_unitario DECIMAL(15,6),
      val_total    DECIMAL(15,2)
   END RECORD

   DEFINE    p_empresas_885        RECORD LIKE empresas_885.*,
             p_estoque_trans       RECORD LIKE estoque_trans.*


END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0962-05.10.05"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0962.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0962_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0962_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0962") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0962 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa dados"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL  pol0962_cria_temp() 
         IF pol0962_informar() THEN
            NEXT OPTION 'Processar'
         END IF
      COMMAND "Processar" "Processa a valorizacao do estoque - IMPL"
         HELP 001
         MESSAGE ""
         LET int_flag = 0
         IF p_ies_cons THEN 
            IF log005_seguranca(p_user,"VDP","pol0962","IN") THEN
               IF log004_confirm(19,41) THEN
                  CALL log085_transacao("BEGIN")
                  IF pol0962_processa() THEN
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

   CLOSE WINDOW w_pol0962

END FUNCTION

#--------------------------#
FUNCTION pol0962_cria_temp()
#--------------------------#
   WHENEVER ERROR CONTINUE

   DROP TABLE tmp_transac
   CREATE TEMP TABLE tmp_transac
     (
      cod_empresa  CHAR(02),
      num_transac    INTEGER,
      val_unitario DECIMAL(15,6),
      val_total    DECIMAL(15,2)
     );

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-tmp_transac")
   END IF
   DELETE FROM tmp_transac

   WHENEVER ERROR STOP
 
END FUNCTION

#--------------------------#
FUNCTION pol0962_informar()
#--------------------------#
 DEFINE l_count   INTEGER
 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0962
   CLEAR FORM
   
   INITIALIZE p_tela TO NULL
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD dat_ini
         IF p_tela.dat_ini IS NULL THEN
            ERROR 'Informe Periodo !!!'
            NEXT FIELD dat_ini
         ELSE
            SELECT dat_fecha_ult_sup
              INTO p_dat_sup
              FROM par_estoque
             WHERE cod_empresa = p_cod_empresa
            IF SQLCA.sqlcode <> 0 THEN 
               LET p_dat_sup = ' 01/01/1899'
            END IF 
            IF p_tela.dat_ini <=  p_dat_sup THEN
               ERROR 'Estoque / Suprimento ja fechado para o periodo informado'  
               NEXT FIELD dat_ini
            END IF    
         END IF 

      AFTER FIELD dat_fim
         IF p_tela.dat_fim IS NULL THEN
            ERROR 'Informe Periodo !!!'
            NEXT FIELD dat_fim
         ELSE
            IF p_tela.dat_fim < p_tela.dat_ini THEN 
               ERROR 'Informe Periodo !!!'
               NEXT FIELD dat_fim
            END IF    
         END IF 

      AFTER FIELD cod_item
         IF p_tela.cod_item IS NULL THEN
            ERROR 'Informe o item !!!'
            NEXT FIELD cod_item
         ELSE
            SELECT den_item[1,65]
              INTO p_tela.den_item
              FROM item
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = p_tela.cod_item
            IF SQLCA.sqlcode <> 0 THEN 
               ERROR 'Item nao cadastrado!!!'
               NEXT FIELD cod_item
            ELSE
               DISPLAY p_tela.den_item TO den_item    
            END IF        
         END IF
         
      AFTER FIELD val_item
         IF p_tela.val_item IS NULL THEN
            ERROR 'Informe o valor unitario do item !!!'
            NEXT FIELD val_item
         END IF

      AFTER FIELD cod_op1
         IF p_tela.cod_op1 IS NULL THEN
            ERROR 'Informe ao menos uma operacao !!!'
            NEXT FIELD cod_op1
         ELSE
           LET l_count = 0  
           SELECT COUNT(*)
             INTO l_count
             FROM estoque_operac
            WHERE cod_empresa  = p_cod_empresa 
              AND cod_operacao = p_tela.cod_op1
            IF l_count = 0 THEN 
               ERROR 'Operacao Invalida !!!'
               NEXT FIELD cod_op1
            END IF      
         END IF 
          
      AFTER FIELD cod_op2
         IF p_tela.cod_op2 IS NOT NULL THEN 
           LET l_count = 0  
           SELECT COUNT(*)
             INTO l_count
             FROM estoque_operac
            WHERE cod_empresa  = p_cod_empresa 
              AND cod_operacao = p_tela.cod_op2
            IF l_count = 0 THEN 
               ERROR 'Operacao Invalida !!!'
               NEXT FIELD cod_op2
            END IF      
         END IF    

      AFTER FIELD cod_op3
         IF p_tela.cod_op3 IS NOT NULL THEN 
            LET l_count = 0  
           SELECT COUNT(*)
             INTO l_count
             FROM estoque_operac
            WHERE cod_empresa  = p_cod_empresa 
              AND cod_operacao = p_tela.cod_op3
            IF l_count = 0 THEN 
               ERROR 'Operacao Invalida !!!'
               NEXT FIELD cod_op3
            END IF      
         END IF    

      AFTER FIELD cod_op4
         IF p_tela.cod_op4 IS NOT NULL THEN 
           LET l_count = 0  
           SELECT COUNT(*)
             INTO l_count
             FROM estoque_operac
            WHERE cod_empresa  = p_cod_empresa 
              AND cod_operacao = p_tela.cod_op4
            IF l_count = 0 THEN 
               ERROR 'Operacao Invalida !!!'
               NEXT FIELD cod_op4
            END IF      
         END IF    

      AFTER FIELD cod_op5
         IF p_tela.cod_op5 IS NOT NULL THEN 
           LET l_count = 0  
           SELECT COUNT(*)
             INTO l_count
             FROM estoque_operac
            WHERE cod_empresa  = p_cod_empresa 
              AND cod_operacao = p_tela.cod_op5
            IF l_count = 0 THEN 
               ERROR 'Operacao Invalida !!!'
               NEXT FIELD cod_op5
            END IF      
         END IF    

      AFTER FIELD cod_op6
         IF p_tela.cod_op6 IS NOT NULL THEN 
           LET l_count = 0  
           SELECT COUNT(*)
             INTO l_count
             FROM estoque_operac
            WHERE cod_empresa  = p_cod_empresa 
              AND cod_operacao = p_tela.cod_op6
            IF l_count = 0 THEN 
               ERROR 'Operacao Invalida !!!'
               NEXT FIELD cod_op6
            END IF      
         END IF    

      AFTER FIELD cod_op7
         IF p_tela.cod_op7 IS NOT NULL THEN 
           LET l_count = 0  
           SELECT COUNT(*)
             INTO l_count
             FROM estoque_operac
            WHERE cod_empresa  = p_cod_empresa 
              AND cod_operacao = p_tela.cod_op7
            IF l_count = 0 THEN 
               ERROR 'Operacao Invalida !!!'
               NEXT FIELD cod_op7
            END IF      
         END IF    

      AFTER FIELD cod_op8
         IF p_tela.cod_op8 IS NOT NULL THEN 
           LET l_count = 0  
           SELECT COUNT(*)
             INTO l_count
             FROM estoque_operac
            WHERE cod_empresa  = p_cod_empresa 
              AND cod_operacao = p_tela.cod_op8
            IF l_count = 0 THEN 
               ERROR 'Operacao Invalida !!!'
               NEXT FIELD cod_op8
            END IF      
         END IF    

      AFTER FIELD cod_op9
         IF p_tela.cod_op9 IS NOT NULL THEN 
           LET l_count = 0  
           SELECT COUNT(*)
             INTO l_count
             FROM estoque_operac
            WHERE cod_empresa  = p_cod_empresa 
              AND cod_operacao = p_tela.cod_op9
            IF l_count = 0 THEN 
               ERROR 'Operacao Invalida !!!'
               NEXT FIELD cod_op9
            END IF      
         END IF    

      AFTER FIELD cod_op10
         IF p_tela.cod_op10 IS NOT NULL THEN 
           LET l_count = 0  
           SELECT COUNT(*)
             INTO l_count
             FROM estoque_operac
            WHERE cod_empresa  = p_cod_empresa 
              AND cod_operacao = p_tela.cod_op10
            IF l_count = 0 THEN 
               ERROR 'Operacao Invalida !!!'
               NEXT FIELD cod_op10
            END IF      
         END IF    
      
   END INPUT

   IF INT_FLAG = 0 THEN
      LET p_ies_cons = TRUE
   ELSE
      LET p_ies_cons = FALSE
      DISPLAY '' TO dat_ini
      DISPLAY '' TO dat_fim
      DISPLAY '' TO cod_item
      DISPLAY '' TO val_item
      DISPLAY '' TO cod_op1
      DISPLAY '' TO cod_op2
      DISPLAY '' TO cod_op3
      DISPLAY '' TO cod_op4
      DISPLAY '' TO cod_op5
      DISPLAY '' TO cod_op6
      DISPLAY '' TO cod_op7
      DISPLAY '' TO cod_op8
      DISPLAY '' TO cod_op9
      DISPLAY '' TO cod_op10
   END IF

   RETURN(p_ies_cons)

END FUNCTION

#--------------------------#
FUNCTION pol0962_processa()
#--------------------------#
   MESSAGE "Aguarde. Processando ..." ATTRIBUTE(REVERSE)
    
      LET p_count = 0  

      DECLARE cq_estt CURSOR FOR 
       SELECT *
         FROM estoque_trans  
        WHERE cod_empresa  = p_cod_empresa
          AND cod_operacao  IN (p_tela.cod_op1,p_tela.cod_op2,p_tela.cod_op3,p_tela.cod_op4,p_tela.cod_op5,p_tela.cod_op6,
                                p_tela.cod_op7,p_tela.cod_op8,p_tela.cod_op9,p_tela.cod_op10)
          AND dat_movto >= p_tela.dat_ini 
          AND dat_movto <= p_tela.dat_fim 
          AND cod_item      = p_tela.cod_item

      FOREACH cq_estt INTO p_estoque_trans.*

        LET p_tmp_transac.cod_empresa   =  p_estoque_trans.cod_empresa
        LET p_tmp_transac.num_transac   =  p_estoque_trans.num_transac
        LET p_tmp_transac.val_unitario  =  p_tela.val_item
        LET p_tmp_transac.val_total     =  p_tela.val_item * p_estoque_trans.qtd_movto
        INSERT INTO tmp_transac VALUES (p_tmp_transac.*)
        IF SQLCA.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","tmp_transac")
           RETURN FALSE
        END IF 
        
      END FOREACH

      DECLARE cq_tmp CURSOR FOR 
       SELECT *
         FROM tmp_transac
      FOREACH cq_tmp INTO p_tmp_transac.*
        UPDATE estoque_trans SET cus_unit_movto_p = p_tmp_transac.val_unitario,
                                 cus_tot_movto_p = p_tmp_transac.val_total
         WHERE cod_empresa = p_tmp_transac.cod_empresa
           AND num_transac = p_tmp_transac.num_transac
        IF SQLCA.sqlcode <> 0 THEN 
           CALL log003_err_sql("ATUALIZACAO","estoque_trans")
           RETURN FALSE
        END IF
         
        UPDATE estoque_trans_end  SET cus_unit_movto_p = p_tmp_transac.val_unitario,
                                      cus_tot_movto_p = p_tmp_transac.val_total
         WHERE cod_empresa = p_tmp_transac.cod_empresa
           AND num_transac = p_tmp_transac.num_transac
        IF SQLCA.sqlcode <> 0 THEN 
           CALL log003_err_sql("ATUALIZACAO","estoque_trans")
           RETURN FALSE
        END IF 

        LET p_count = p_count + 1
      END FOREACH     
 
   RETURN TRUE
   
END FUNCTION