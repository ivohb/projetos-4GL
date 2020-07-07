DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_dat_inicio         CHAR(10),
          p_dat_fim            CHAR(10),
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
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(80)
          
   DEFINE p_tela               RECORD
          cod_item              CHAR(15),
          val_item              DECIMAL(15,6),
          den_item              CHAR(65)
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
   LET p_versao = "pol0837-05.10.05"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0837.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0837_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0837_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0837") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0837 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa dados"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL  pol0837_cria_temp() 
         IF pol0837_informar() THEN
            NEXT OPTION 'Processar'
         END IF
      COMMAND "Processar" "Processa a valorizacao do estoque - IMPL"
         HELP 001
         MESSAGE ""
         LET int_flag = 0
         IF p_ies_cons THEN 
            IF log005_seguranca(p_user,"VDP","pol0837","IN") THEN
               IF log004_confirm(19,41) THEN
                  CALL log085_transacao("BEGIN")
                  IF pol0837_processa() THEN
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

   CLOSE WINDOW w_pol0837

END FUNCTION

#--------------------------#
FUNCTION pol0837_cria_temp()
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
FUNCTION pol0837_informar()
#--------------------------#

 SELECT *
     INTO p_empresas_885.*
     FROM empresas_885
    WHERE cod_emp_gerencial = p_cod_empresa
       OR cod_emp_oficial  = p_cod_empresa
            
   IF SQLCA.sqlcode = NOTFOUND THEN
      ERROR 'Registro nao encontrada na tabela empresas_885'
      RETURN FALSE
   ELSE
      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na leitura Empresas_885- Erro nº ', STATUS
         CALL log003_err_sql("LEITURA","EMPRESAS_885")
         RETURN FALSE
      END IF
   END IF
   
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0837
   CLEAR FORM
   
   INITIALIZE p_tela TO NULL
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

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
      
   END INPUT

   IF INT_FLAG = 0 THEN
      LET p_ies_cons = TRUE
   ELSE
      LET p_ies_cons = FALSE
      DISPLAY '' TO cod_item
      DISPLAY '' TO val_item
   END IF

   RETURN(p_ies_cons)

END FUNCTION

#--------------------------#
FUNCTION pol0837_processa()
#--------------------------#
   MESSAGE "Aguarde. Processando ..." ATTRIBUTE(REVERSE)
    
      LET p_count = 0  

      DECLARE cq_estt CURSOR FOR 
       SELECT *
         FROM estoque_trans  
        WHERE cod_empresa  IN (p_empresas_885.cod_emp_gerencial, p_empresas_885.cod_emp_oficial)
          AND cod_operacao  IN ('IMPL','ETRC','STRC')
          AND dat_movto     IN ('30/11/2008','31/12/2008')
          AND cod_item      = p_tela.cod_item

      FOREACH cq_estt INTO p_estoque_trans.*

        IF p_estoque_trans.cod_empresa <> '01' AND
           p_estoque_trans.cod_empresa <> 'O1' AND
           p_estoque_trans.cod_empresa <> '02' AND
           p_estoque_trans.cod_empresa <> 'O2' THEN
           CONTINUE FOREACH
        END IF 
        
        IF p_estoque_trans.cod_empresa = '01' OR
           p_estoque_trans.cod_empresa = 'O1' THEN 
           IF p_estoque_trans.dat_movto <> '30/11/2008' THEN
              CONTINUE FOREACH
           END IF 
        END IF       

        IF p_estoque_trans.cod_empresa = '02' OR
           p_estoque_trans.cod_empresa = 'O2' THEN 
           IF p_estoque_trans.dat_movto <> '31/12/2008' THEN
              CONTINUE FOREACH
           END IF 
        END IF       

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
        LET p_count = p_count + 1
      END FOREACH     
 
   RETURN TRUE
   
END FUNCTION