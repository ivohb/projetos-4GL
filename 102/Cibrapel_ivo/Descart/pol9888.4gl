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
          p_pre_unit           LIKE ped_itens.pre_unit,
          p_num_transac        INTEGER,
          p_cod_item           CHAR(15),
          p_cod_emp            CHAR(02),
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
          dat_fim               DATE
   END RECORD

   DEFINE p_tmp_item   RECORD
      cod_empresa  CHAR(02),
      cod_item     CHAR(15),
      pre_unit     DECIMAL(15,6)
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
   LET p_versao = "POL9888-05.10.02"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol9888.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol9888_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol9888_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol9888") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol9888 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa dados"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL  pol9888_cria_temp() 
         IF pol9888_informar() THEN
            NEXT OPTION 'Processar'
         END IF
      COMMAND "Processar" "Processa a valorizacao do estoque - IMPL"
         HELP 001
         MESSAGE ""
         LET int_flag = 0
         IF p_ies_cons THEN 
            IF log005_seguranca(p_user,"VDP","pol9888","IN") THEN
               IF log004_confirm(19,41) THEN
                  CALL log085_transacao("BEGIN")
                  IF pol9888_processa() THEN
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

   CLOSE WINDOW w_pol9888

END FUNCTION

#--------------------------#
FUNCTION pol9888_cria_temp()
#--------------------------#
   WHENEVER ERROR CONTINUE

   DROP TABLE tmp_item
   CREATE TEMP TABLE tmp_item
     (
      cod_empresa  CHAR(02),
      cod_item     CHAR(15),
      pre_unit     DECIMAL(15,6) 
     );

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-tmp_item")
   END IF
   DELETE FROM tmp_item

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
FUNCTION pol9888_informar()
#--------------------------#
 DEFINE l_count   INTEGER
 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol9888
   CLEAR FORM
   
   INITIALIZE p_tela TO NULL
   
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
FUNCTION pol9888_processa()
#--------------------------#
DEFINE l_count  INTEGER 
   MESSAGE "Aguarde. Processando ..." ATTRIBUTE(REVERSE)
    
      LET p_count = 0  

      DECLARE cq_estit CURSOR FOR 
       SELECT *
         FROM at_custo
      FOREACH cq_estit INTO p_cod_emp,p_cod_item
    
          SELECT cod_grupo_item
            INTO p_cod_grupo_item
            FROM item_vdp
           WHERE cod_empresa = p_cod_empresa
             AND cod_item    = p_cod_item 

          IF p_cod_grupo_item <> '01'  THEN 
             CONTINUE FOREACH 
          END IF 

          LET l_count = 0 
          
          SELECT COUNT(*) 
            INTO l_count
            FROM tmp_item
           WHERE cod_empresa = p_cod_empresa
             AND cod_item    = p_estoque_trans.cod_item
          IF l_count > 0 THEN 
             CONTINUE FOREACH 
          END IF     
          
          LET p_tmp_item.cod_empresa   =  p_cod_empresa
          LET p_tmp_item.cod_item      =  p_cod_item
          
          INITIALIZE p_tmp_item.pre_unit TO NULL
            
          SELECT MAX(pre_unit)
            INTO p_tmp_item.pre_unit 
            FROM ped_itens 
           WHERE cod_empresa = p_cod_empresa 
             AND cod_item    = p_tmp_item.cod_item 
             AND prz_entrega >= '01/05/2008' 
             AND prz_entrega <= '30/05/2009'  

          IF p_tmp_item.pre_unit  IS NULL THEN 
             CONTINUE FOREACH
          END IF    
          
          LET p_tmp_item.pre_unit = p_tmp_item.pre_unit * 0.8
          
          INSERT INTO tmp_item VALUES (p_tmp_item.*)
          IF SQLCA.sqlcode <> 0 THEN 
             CALL log003_err_sql("INCLUSAO","tmp_item")
             RETURN FALSE
          END IF 
        
      END FOREACH

      DECLARE cq_tmp CURSOR FOR 
       SELECT *
         FROM tmp_item
      FOREACH cq_tmp INTO p_tmp_item.*
        
        DECLARE ct_ett1 CURSOR FOR 
          SELECT cod_empresa,num_transac
            FROM at_transac  
           WHERE cod_empresa  = p_cod_empresa
             AND cod_item     = p_tmp_item.cod_item
         FOREACH ct_ett1 INTO p_estoque_trans.cod_empresa,p_num_transac 
            
            LET p_tmp_transac.cod_empresa   =  p_cod_empresa
            LET p_tmp_transac.num_transac   =  p_estoque_trans.num_transac
            LET p_tmp_transac.val_unitario  =  p_tmp_item.pre_unit
            LET p_tmp_transac.val_total     =  p_tmp_item.pre_unit * p_estoque_trans.qtd_movto
            INSERT INTO tmp_transac VALUES (p_tmp_transac.*)
            IF SQLCA.sqlcode <> 0 THEN 
               CALL log003_err_sql("INCLUSAO","tmp_transac")
               RETURN FALSE
            END IF 
         END FOREACH
      END FOREACH       

      DECLARE cq_estt2 CURSOR FOR 
       SELECT *
         FROM tmp_transac
      FOREACH cq_estt2 INTO p_tmp_transac.*
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