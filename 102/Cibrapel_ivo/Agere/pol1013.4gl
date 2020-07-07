#------------------------------------------------------------------------------#
# OBJETIVO: GRAVAÇÃO DA TABELA EST_TRANS_RELAC                                 #
# DATA....: 02/02/2010                                                         #
#------------------------------------------------------------------------------#

 DATABASE logix

 GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_criticou           SMALLINT,
          p_msg                CHAR(80),
          p_cod_status         CHAR(01),
          p_ies_bobina         SMALLINT,
          p_qtd_integer        INTEGER,
          p_dat_prod           DATE,
          p_ondu               CHAR(01),
          p_flag               CHAR(01),
          p_retorno            SMALLINT,
          p_count              INTEGER,
          p_status             SMALLINT,
          p_ind                SMALLINT,
          p_index              SMALLINT,
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_transf_refug       CHAR(01),
          sql_stmt             CHAR(900),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          p_caminho            CHAR(080),
          p_ies_apon           SMALLINT,
          p_ies_cons           SMALLINT,
          comando              CHAR(80),
          p_qtd_unit           DECIMAL(17,7),
          p_mes_ano            CHAR(07),
          p_tip_trim           CHAR(01),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_last_row           SMALLINT
          

   DEFINE p_dat_fecha_ult_man  LIKE par_estoque.dat_fecha_ult_man,
          p_dat_fecha_ult_sup  LIKE par_estoque.dat_fecha_ult_sup,
          p_dat_prx_fecha_est  LIKE par_estoque.dat_prx_fecha_est,
          p_num_lote           LIKE estoque_lote.num_lote,
          p_cod_prod           LIKE ordens.cod_item,
          p_num_docum          LIKE estoque_trans.num_docum,
          p_cod_item           LIKE estoque_trans.cod_item,
          p_num_transac_orig   LIKE estoque_trans.num_transac,
          p_cod_item_orig      LIKE estoque_trans.cod_item,
          p_num_transac_dest   LIKE estoque_trans.num_transac,
          p_cod_item_dest      LIKE estoque_trans.cod_item,
          p_num_transac        LIKE estoque_trans.num_transac,
          p_ies_tipo           LIKE estoque_trans.ies_tip_movto,
          p_cod_familia        LIKE item.cod_familia,
          p_num_nivel          LIKE est_trans_relac.num_nivel,
          p_dat_movto          LIKE estoque_trans.dat_movto,
          p_dat_consumo        LIKE estoque_trans.dat_movto,
          p_qtd_consumo        LIKE estoque_trans.qtd_movto,
          p_qtd_difer          LIKE estoque_trans.qtd_movto,
          p_qtd_apont          LIKE estoque_trans.qtd_movto,
          p_qtd_baixar         LIKE estoque_trans.qtd_movto,
          p_tot_baixa          LIKE estoque_trans.qtd_movto,
          p_cod_oper_sp        LIKE par_pcp.cod_estoque_sp,
          p_cod_oper_rp        LIKE par_pcp.cod_estoque_rp
          
          
          
   DEFINE pr_erros             ARRAY[1000] OF RECORD
          cod_empresa          CHAR(02),
          cod_item             CHAR(15),
          num_docum            CHAR(10),
          dat_consumo          DATE,
          qtd_consumo          DECIMAL(10,3),
          den_erro             CHAR(70)
   END RECORD
   

   DEFINE p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_transa     RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
          p_est_trans_relac    RECORD LIKE est_trans_relac.*

   DEFINE p_tela               RECORD
          dat_fecha_ult_sup    DATE,
          dat_prx_fecha_est    DATE,
          dat_ini              DATE,
          dat_fim              DATE
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1013-05.00.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1013_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1013_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1013") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1013 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   IF NOT pol1013_le_parametros() THEN
      RETURN
   END IF

   IF NOT pol1013_cria_tabs_tmp() THEN
      RETURN
   END IF
   
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informa período para processamento"
         CALL pol1013_informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Parâmetros informados com sucesso!!!'
            LET p_ies_cons = TRUE 
            LET p_ies_apon = TRUE 
            NEXT OPTION 'Processar'
         ELSE
            ERROR "Operação Cancelada!!!"
         END IF
      COMMAND "Processar" "Gera relação entre apontamento e consumo de materiais"
         IF p_ies_cons = TRUE THEN
            CALL pol1013_processar() RETURNING p_status
            CALL log0030_mensagem(p_msg,'excla')
         ELSE 
            ERROR "Informe previamente os parâmetros!!!"
            NEXT OPTION 'Informar'
         END IF     
      COMMAND "Críticas" "Consumos criticados durante o relacionamento"
         CALL pol1013_consultar() RETURNING p_status
         CLOSE WINDOW w_pol10131

         IF p_status THEN
            ERROR "Consulta efetuada com sucesso !!!"   
         ELSE
            ERROR 'Operação cancelada!!!'
         END IF
      COMMAND "Listar" "Listagem"
         CALL pol1013_listagem()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1013

END FUNCTION

#------------------------------#
FUNCTION pol1013_le_parametros()
#------------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
      LET p_cod_empresa  = p_cod_emp_ger
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
      END IF
   END IF

   SELECT dat_fecha_ult_man,
          dat_fecha_ult_sup,
          dat_prx_fecha_est
     INTO p_dat_fecha_ult_man,
          p_dat_fecha_ult_sup,
          p_dat_prx_fecha_est
     FROM par_estoque
    WHERE cod_empresa = p_cod_emp_ofic
           
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("lendo", "par_estoque")
      RETURN FALSE
   END IF 

   SELECT cod_estoque_sp,
          cod_estoque_rp    
     INTO p_cod_oper_sp,
          p_cod_oper_rp
     FROM par_pcp
    WHERE cod_empresa = p_cod_emp_ofic

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_pcp')
      RETURN FALSE
   END IF
        
   SELECT tip_trim
     INTO p_tip_trim
     FROM empresas_885
    WHERE cod_emp_gerencial = p_cod_emp_ger
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresas_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE 

END FUNCTION

#------------------------------#
FUNCTION pol1013_cria_tabs_tmp()
#------------------------------#

   DROP TABLE apont_tmp_885
   
   CREATE TEMP TABLE apont_tmp_885(
      num_transac_orig INTEGER,
      cod_item_orig    CHAR(15),
      qtd_movto        DECIMAL(10,3),
      dat_movto        DATE,
      qtd_baixar       DECIMAL(10,3)
     ) ;

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("Criando","apont_tmp_885")
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION

#--------------------------#
 FUNCTION pol1013_informar()
#--------------------------#                  
   
   DEFINE p_dat_txt CHAR(10)
   
   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   LET p_tela.dat_ini = p_dat_fecha_ult_sup + 1
   LET p_tela.dat_fim = p_dat_prx_fecha_est
   LET p_tela.dat_fecha_ult_sup = p_dat_fecha_ult_sup
   LET p_tela.dat_prx_fecha_est = p_dat_prx_fecha_est
   
   LET p_dat_txt = p_tela.dat_ini
   LET p_mes_ano = p_dat_txt[4,10]
   
   SELECT cod_empresa
     FROM relac_proces_885
    WHERE cod_empresa = p_cod_emp_ger
      AND mes_ano     = p_mes_ano
   
   IF STATUS = 0 THEN
      DISPLAY p_dat_fecha_ult_sup TO dat_fecha_ult_sup
      DISPLAY p_dat_prx_fecha_est TO dat_prx_fecha_est
      LET p_msg = 'Já foi efetuado o relacionamento\n',
                  'para o período de fechamento atual!\n'
      CALL log0030_mensagem(p_msg, 'excla')
      RETURN FALSE
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('Lendo','relac_proces_885')
         RETURN FALSE
      END IF
   END IF
   
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD dat_ini    
         
         IF p_tela.dat_ini IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!'
            NEXT FIELD dat_ini
         END IF

         IF p_tela.dat_ini <= p_dat_fecha_ult_man THEN
            ERROR 'Data inicial com manufatura já fechada!'
            NEXT FIELD dat_ini
         END IF
                     
         IF p_tela.dat_ini <= p_dat_fecha_ult_sup THEN
            ERROR 'Data inicial com suprimento já fechado!'
            NEXT FIELD dat_ini
         END IF

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
         
            IF p_tela.dat_fim IS NULL THEN
               ERROR 'Campo com preenchimento obrigatório!'
               NEXT FIELD dat_fim
            END IF

            IF p_tela.dat_ini > p_tela.dat_fim THEN
               ERROR 'Período de processamento inválido!!!'
               NEXT FIELD dat_ini
            END IF
            
         END IF
            
   END INPUT

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO codempresa
      LET p_ies_cons = FALSE
      LET p_ies_apon = FALSE
   ELSE
      LET p_ies_cons = TRUE  
      LET p_ies_apon = TRUE
   END IF

   RETURN(p_ies_cons)
   
END FUNCTION

#---------------------------#
FUNCTION pol1013_ins_relac()
#---------------------------#
                 
   SELECT num_nivel
     INTO p_num_nivel
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_dest
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'item_man')
      RETURN FALSE
   END IF
   
   INSERT INTO est_trans_relac(
      cod_empresa,
      num_nivel,
      num_transac_orig,
      cod_item_orig,
      num_transac_dest,
      cod_item_dest,
      dat_movto) 
   VALUES(p_cod_empresa,
          p_num_nivel,
          p_num_transac_orig,
          p_cod_item_orig,
          p_num_transac_dest,
          p_cod_item_dest,
          p_dat_movto)
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','est_trans_relac')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1013_processar()
#---------------------------#

   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   MESSAGE 'Gravando relação com consumo de bobinas - data:'

   LET p_cod_empresa = p_cod_emp_ger
   LET p_count = 0

   DELETE FROM relac_erro_885
    WHERE cod_empresa = p_cod_empresa
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','relac_erro_885')
      RETURN FALSE
   END IF

   INITIALIZE pr_erros TO NULL
   LET p_criticou = FALSE
   LET p_index = 0
      
   CALL log085_transacao("BEGIN")

   IF NOT pol1013_relaciona() THEN
      LET p_msg = 'Operação cancelada!'
      RETURN FALSE
   END IF
   
   IF p_criticou THEN
      CALL log085_transacao("ROLLBACK")
      CALL log085_transacao("BEGIN")
      IF NOT pol1013_salva_erros() THEN
         CALL log085_transacao("ROLLBACK")
      END IF
      CALL log085_transacao("COMMIT")
      LET p_msg = 'Erros foram detectados!\n',
                  'Execute a operação Criticas.\n'
   ELSE
      IF NOT pol1013_salva_relac_ok() THEN
         CALL log085_transacao("ROLLBACK")
      END IF
      CALL log085_transacao("COMMIT")
      LET p_msg = 'Processamento efetuado\n',
                  'com sucesso!\n'
   END IF      

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1013_relaciona()
#--------------------------#
   
   DECLARE cq_relac CURSOR WITH HOLD FOR
    SELECT DISTINCT 
           dat_movto 
      FROM estoque_trans 
     WHERE cod_operacao = p_cod_oper_sp
       AND dat_movto BETWEEN p_tela.dat_ini AND p_tela.dat_fim
       AND cod_empresa IN (p_cod_emp_ger, p_cod_emp_ofic)
     ORDER BY dat_movto
     
   FOREACH cq_relac INTO p_dat_consumo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_relac')
         RETURN FALSE
      END IF
      
      LET p_count = p_count + 1
      
      DISPLAY p_dat_consumo AT 21,52
                  
      DECLARE cq_consu CURSOR FOR
       SELECT cod_empresa,
              num_docum, 
              cod_item, 
              num_lote_orig,  
              qtd_movto,
              num_transac
         FROM estoque_trans
        WHERE dat_movto     = p_dat_consumo
          AND cod_operacao  = p_cod_oper_sp
          AND ies_tip_movto = 'N'
          AND cod_empresa IN (p_cod_emp_ger, p_cod_emp_ofic)
          AND num_transac NOT IN 
             (SELECT num_transac_normal 
                FROM estoque_trans_rev
               WHERE estoque_trans_rev.cod_empresa = estoque_trans.cod_empresa)
        ORDER BY num_docum, cod_item
   
      FOREACH cq_consu INTO 
              p_cod_empresa,
              p_num_docum, 
              p_cod_item, 
              p_num_lote, 
              p_qtd_consumo,
              p_num_transac
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_consu')
            RETURN FALSE
         END IF
         
         IF p_tip_trim = 'B' THEN
            IF NOT pol1013_checa_bobina() THEN
               RETURN FALSE
            END IF
            IF NOT p_ies_bobina THEN
               CONTINUE FOREACH
            END IF
         END IF
         
         DISPLAY p_num_transac AT 21,65
            
         SELECT SUM(qtd_movto)
           INTO p_qtd_apont
           FROM estoque_trans
          WHERE cod_empresa   = p_cod_empresa
            AND num_docum     = p_num_docum
            AND cod_operacao  = p_cod_oper_rp
            AND ies_tip_movto = 'N'
            AND dat_movto BETWEEN p_tela.dat_ini AND p_tela.dat_fim
            AND num_transac NOT IN 
               (SELECT num_transac_normal 
                  FROM estoque_trans_rev
                 WHERE estoque_trans_rev.cod_empresa = estoque_trans.cod_empresa)
                  
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','ordens')
            RETURN FALSE
         END IF
            
         IF p_qtd_apont IS NULL OR p_qtd_apont = 0 THEN
            LET p_criticou = TRUE
            LET p_msg = 'CONSUMO DE MATERIAL P/ OP SEM APONTAMENTOS'
            LET p_index = p_index + 1
            LET pr_erros[p_index].cod_empresa = p_cod_empresa
            LET pr_erros[p_index].cod_item    = p_cod_item
            LET pr_erros[p_index].num_docum   = p_num_docum
            LET pr_erros[p_index].dat_consumo = p_dat_consumo
            LET pr_erros[p_index].qtd_consumo = p_qtd_consumo
            LET pr_erros[p_index].den_erro    = p_msg
         END IF

         IF p_criticou THEN
            CONTINUE FOREACH
         END IF

         IF NOT pol1013_estorna_consumo() THEN
            RETURN FALSE
         END IF
            
         LET p_qtd_unit = p_qtd_consumo / p_qtd_apont
            
         DELETE FROM apont_tmp_885
         LET p_tot_baixa = 0
            
         DECLARE cq_aptos CURSOR FOR
          SELECT num_transac,
                 cod_item,
                 dat_movto,
                 qtd_movto,
                 cod_local_est_dest,
                 num_lote_dest,
                 ies_sit_est_dest
            FROM estoque_trans 
           WHERE cod_empresa   = p_cod_empresa 
             AND num_docum     = p_num_docum
             AND cod_operacao  = p_cod_oper_rp 
             AND ies_tip_movto = 'N'
             AND dat_movto BETWEEN p_tela.dat_ini AND p_tela.dat_fim
             AND num_transac NOT IN 
                (SELECT num_transac_normal 
                   FROM estoque_trans_rev
                  WHERE estoque_trans_rev.cod_empresa = estoque_trans.cod_empresa)

         FOREACH cq_aptos INTO 
                 p_estoque_trans.num_transac,
                 p_estoque_trans.cod_item,
                 p_estoque_trans.dat_movto,
                 p_estoque_trans.qtd_movto,
                 p_estoque_trans.cod_local_est_dest,
                 p_estoque_trans.num_lote_dest,
                 p_estoque_trans.ies_sit_est_dest
                    
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','cq_aptos')
               RETURN FALSE
            END IF
                              
            LET p_qtd_baixar = p_estoque_trans.qtd_movto * p_qtd_unit
             
            INSERT INTO apont_tmp_885
             VALUES(p_estoque_trans.num_transac,
                    p_estoque_trans.cod_item,
                    p_estoque_trans.qtd_movto,
                    p_estoque_trans.dat_movto,
                    p_qtd_baixar)

            IF STATUS <> 0 THEN
               CALL log003_err_sql('Inserindo','apont_tmp_885')
               RETURN FALSE
            END IF
               
            LET p_tot_baixa = p_tot_baixa + p_qtd_baixar
               
         END FOREACH
            
         LET p_qtd_difer = p_qtd_consumo - p_tot_baixa
            
         IF p_qtd_difer <> 0 THEN
            SELECT MAX(num_transac_orig)
              INTO p_num_transac
              FROM apont_tmp_885
              
            IF p_num_transac IS NULL THEN
               CALL log003_err_sql('Lendo', 'apont_tmp_885')
               RETURN FALSE
            END IF
               
            UPDATE apont_tmp_885
               SET qtd_baixar = qtd_baixar + p_qtd_difer
             WHERE num_transac_orig = p_num_transac
               
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Atualizando','apont_tmp_885')
               RETURN FALSE
            END IF

         END IF
         
         IF NOT pol1013_bx_consumo() THEN
            RETURN FALSE
         END IF
            
      END FOREACH      
   
   END FOREACH

   RETURN TRUE
   
END FUNCTION   

#---------------------------------#
FUNCTION pol1013_estorna_consumo()
#---------------------------------#

   SELECT * 
     INTO p_estoque_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'estoque_trans')
      RETURN FALSE
   END IF
   
   LET p_estoque_transa.* = p_estoque_trans.*
   
   SELECT * 
     INTO p_estoque_trans_end.*
     FROM estoque_trans_end
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'estoque_trans_end')
      RETURN FALSE
   END IF

   LET p_estoque_trans.ies_tip_movto = 'R'

   IF NOT pol1013_ins_est_trans() THEN
      RETURN FALSE
   END IF

   IF NOT pol1013_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT pol1013_ins_est_auditoria() THEN
      RETURN FALSE
   END IF

   IF NOT pol1013_ins_trans_rev() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1013_ins_est_trans()
#-------------------------------#

   LET p_estoque_trans.num_transac   = 0

    INSERT INTO estoque_trans(
          cod_empresa,
          cod_item,
          dat_movto,
          dat_ref_moeda_fort,
          cod_operacao,
          num_docum,
          num_seq,
          ies_tip_movto,
          qtd_movto,
          cus_unit_movto_p,
          cus_tot_movto_p,
          cus_unit_movto_f,
          cus_tot_movto_f,
          num_conta,
          num_secao_requis,
          cod_local_est_orig,
          cod_local_est_dest,
          num_lote_orig,
          num_lote_dest,
          ies_sit_est_orig,
          ies_sit_est_dest,
          cod_turno,
          nom_usuario,
          dat_proces,
          hor_operac,
          num_prog)   
          VALUES (p_estoque_trans.cod_empresa,
                  p_estoque_trans.cod_item,
                  p_estoque_trans.dat_movto,
                  p_estoque_trans.dat_ref_moeda_fort,
                  p_estoque_trans.cod_operacao,
                  p_estoque_trans.num_docum,
                  p_estoque_trans.num_seq,
                  p_estoque_trans.ies_tip_movto,
                  p_estoque_trans.qtd_movto,
                  p_estoque_trans.cus_unit_movto_p,
                  p_estoque_trans.cus_tot_movto_p,
                  p_estoque_trans.cus_unit_movto_f,
                  p_estoque_trans.cus_tot_movto_f,
                  p_estoque_trans.num_conta,
                  p_estoque_trans.num_secao_requis,
                  p_estoque_trans.cod_local_est_orig,
                  p_estoque_trans.cod_local_est_dest,
                  p_estoque_trans.num_lote_orig,
                  p_estoque_trans.num_lote_dest,
                  p_estoque_trans.ies_sit_est_orig,
                  p_estoque_trans.ies_sit_est_dest,
                  p_estoque_trans.cod_turno,
                  p_estoque_trans.nom_usuario,
                  p_estoque_trans.dat_proces,
                  p_estoque_trans.hor_operac,
                  p_estoque_trans.num_prog)   


   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans')   
     RETURN FALSE
   END IF

   LET p_num_transac_orig = SQLCA.SQLERRD[2]

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION pol1013_ins_est_trans_end()
#------------------------------------#

   LET p_estoque_trans_end.num_transac   = p_num_transac_orig
   LET p_estoque_trans_end.ies_tip_movto = p_estoque_trans.ies_tip_movto

   INSERT INTO estoque_trans_end 
      VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans_end')  
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1013_ins_est_auditoria()
#-----------------------------------#

  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, 
            p_num_transac_orig, 
            p_user, 
            getdate(),
            "pol1013")

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_auditoria')
     RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1013_ins_trans_rev()
#-------------------------------#

   INSERT INTO estoque_trans_rev
    VALUES(p_estoque_trans.cod_empresa,
           p_num_transac,
           p_num_transac_orig)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','estoque_trans_rev')  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1013_bx_consumo()
#----------------------------#

   DEFINE p_num_transac_apon LIKE estoque_trans.num_transac
   
   LET p_estoque_trans.* = p_estoque_transa.*
   LET p_estoque_trans.ies_tip_movto = 'N'

   DECLARE cq_bx CURSOR FOR
    SELECT num_transac_orig,
           cod_item_orig,
           dat_movto,
           qtd_baixar
      FROM apont_tmp_885
            
   FOREACH cq_bx INTO 
           p_num_transac_apon, 
           p_cod_item_orig, 
           p_dat_movto,
           p_qtd_baixar
            
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'cq_bx')
         RETURN FALSE
      END IF

      LET p_estoque_trans.qtd_movto = p_qtd_baixar
      LET p_estoque_trans.dat_movto = p_dat_movto
      LET p_estoque_trans_end.qtd_movto = p_qtd_baixar
      
      IF NOT pol1013_ins_est_trans() THEN
         RETURN FALSE
      END IF

      IF NOT pol1013_ins_est_trans_end() THEN
         RETURN FALSE
      END IF

      IF NOT pol1013_ins_est_auditoria() THEN
         RETURN FALSE
      END IF
      
      LET p_num_transac_dest = p_num_transac_orig
      LET p_cod_item_dest    = p_estoque_trans.cod_item
      LET p_num_transac_orig = p_num_transac_apon
      
      IF NOT pol1013_ins_relac() THEN
         RETURN FALSE
      END IF
            
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
 FUNCTION pol1013_consultar()
#---------------------------#

   CURRENT WINDOW IS w_pol1013
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10131") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10131 AT 4,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   INITIALIZE pr_erros TO NULL
   
   LET INT_FLAG = FALSE
   
   LET p_index = 1
   DECLARE cq_erros CURSOR FOR 
  
   SELECT cod_empresa,
          cod_item,
          num_docum,
          dat_consumo,
          qtd_consumo,
          den_erro
     FROM relac_erro_885
    ORDER BY dat_consumo                              
      
   FOREACH cq_erros INTO 
           pr_erros[p_index].cod_empresa,
           pr_erros[p_index].cod_item,
           pr_erros[p_index].num_docum,
           pr_erros[p_index].dat_consumo,
           pr_erros[p_index].qtd_consumo,
           pr_erros[p_index].den_erro
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','relac_erro_885')
         RETURN FALSE
      END IF 
      
      LET p_index = p_index + 1
      
      IF p_index > 1000 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassado','excla')
         EXIT FOREACH
      END IF
            
   END FOREACH
   
   IF p_index = 1 THEN
      CALL log0030_mensagem("Não há consumos baixados com erros !!!","exclamation")
      RETURN FALSE 
   END IF 
   
   CALL SET_COUNT(p_index-1)
   
   DISPLAY ARRAY pr_erros TO sr_erros.*
         
   RETURN TRUE 

END FUNCTION 

#----------------------------#
FUNCTION pol1013_salva_erros()
#----------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO p_index
       
       IF pr_erros[p_ind].cod_empresa IS NOT NULL THEN
        
          INSERT INTO relac_erro_885
           VALUES(pr_erros[p_ind].cod_empresa,
                  pr_erros[p_ind].cod_item,
                  pr_erros[p_ind].num_docum,
                  pr_erros[p_ind].dat_consumo,
                  pr_erros[p_ind].qtd_consumo,
                  pr_erros[p_ind].den_erro)
        
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo', 'relac_erro_885')
            RETURN FALSE
         END IF
      END IF
              
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1013_salva_relac_ok()
#-------------------------------#

   INSERT INTO relac_proces_885
    VALUES(p_cod_emp_ger, p_mes_ano)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo', 'relac_proces_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION
    
#-----------------------------#
FUNCTION pol1013_checa_bobina()
#-----------------------------#

   SELECT cod_familia
     INTO p_cod_familia
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item')
      RETURN FALSE
   END IF
     
   SELECT cod_familia
     FROM familia_insumo_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = p_cod_familia
      AND ies_bobina  = 'S'
      
   IF STATUS = 100 THEN
      LET p_ies_bobina = FALSE
   ELSE
      IF STATUS = 0 THEN
         LET p_ies_bobina = TRUE
      ELSE
         CALL log003_err_sql('Lendo','familia_insumo_885')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol1013_listagem()
#-------------------------#     

   IF NOT pol1013_escolhe_saida() THEN
   		RETURN 
   END IF
   
   IF NOT pol1013_le_empresa() THEN
      RETURN
   END IF 
      
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT cod_empresa,
          cod_item,
          num_docum,
          dat_consumo,
          qtd_consumo,
          den_erro
     FROM relac_erro_885
    ORDER BY dat_consumo                              
      
   FOREACH cq_impressao INTO 
           pr_erros[p_index].cod_empresa,
           pr_erros[p_index].cod_item,
           pr_erros[p_index].num_docum,
           pr_erros[p_index].dat_consumo,
           pr_erros[p_index].qtd_consumo,
           pr_erros[p_index].den_erro

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','relac_erro_885:cq_impressao')
         EXIT FOREACH
      END IF      
      
      OUTPUT TO REPORT pol1013_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1013_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF
  
END FUNCTION 

#------------------------------#
FUNCTION pol1013_escolhe_saida()
#------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1013.tmp"
         START REPORT pol1013_relat TO p_caminho
      ELSE
         START REPORT pol1013_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1013_le_empresa()
#---------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------#
 REPORT pol1013_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_comprime, p_den_empresa,
               COLUMN 123, "PAG.: ", PAGENO USING "####&" 
               
         PRINT COLUMN 001, "pol1013",
               COLUMN 042, "CONSUMOS BAIXADOS C/ ERROS",
               COLUMN 103, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'Empresa      Item        Docum/Op  Dat. consumo Qtd. consumo                         Descricao do erro '
         PRINT COLUMN 001, '------- --------------- ---------- ------------ ------------ -----------------------------------------------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 001, pr_erros[p_index].cod_empresa,
               COLUMN 009, pr_erros[p_index].cod_item, 
               COLUMN 025, pr_erros[p_index].num_docum,
               COLUMN 036, pr_erros[p_index].dat_consumo,
               COLUMN 050, pr_erros[p_index].qtd_consumo  USING '######&.&&&',
               COLUMN 062, pr_erros[p_index].den_erro
         

      ON LAST ROW

        LET p_last_row = TRUE

     PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#
