#------------------------------------------------------------------------------#
# OBJETIVO: GRAVAÇÃO DA TABELA EST_TRANS_RELAC                                 #
# DATA....: 08/08/2008                                                         #
#------------------------------------------------------------------------------#

 DATABASE logix

 GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_transac_ant        INTEGER,
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
          p_mes_ano            CHAR(05)
          

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
          dat_consumo          DATE,
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
   LET p_versao = "pol0943-05.00.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0943_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0943_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0943") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0943 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   IF NOT pol0943_le_parametros() THEN
      RETURN
   END IF

   IF NOT pol0943_cria_tabs_tmp() THEN
      RETURN
   END IF
   
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informa período para processamento"
         CALL pol0943_informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Parâmetros informados com sucesso!!!'
            LET p_ies_cons = TRUE 
            LET p_ies_apon = TRUE 
            NEXT OPTION 'Processar'
         ELSE
            ERROR "Operação Cancelada!!!"
         END IF
      COMMAND "Apontamento" "Gera relação entre apontamento e baixa de componente"
         IF p_ies_apon = TRUE THEN
            CALL pol0943_proces_apon() RETURNING p_status
            IF p_status THEN
               ERROR 'Procesamento efetuado com sucesso!'
               CALL log0030_mensagem('Procesamento efetuado com sucesso!','info')
            ELSE
               ERROR 'Operação cancelada!'
            END IF
            LET p_ies_apon = FALSE
            NEXT OPTION 'Informar'
         ELSE 
            ERROR "Informe previamente os parâmetros!!!"
            NEXT OPTION 'Informar'
         END IF     
      {COMMAND "Consumo" "Gera relação entre apontamento e consumo de bobina"
         IF p_ies_cons = TRUE THEN
            CALL pol0943_proces_bob() RETURNING p_status
            IF p_status THEN
               IF p_count > 0 THEN
                  LET p_msg = 'Procesamento efetuado com sucesso!'
               ELSE
                  LET p_msg = 'Não há dados para o período informado!'
               END IF
               CALL log0030_mensagem(p_msg,'info')
            ELSE
               ERROR 'Operação cancelada!'
            END IF
            LET p_ies_cons = FALSE
            NEXT OPTION 'Informar'
         ELSE 
            ERROR "Informe previamente os parâmetros!!!"
            NEXT OPTION 'Informar'
         END IF     
      COMMAND "Críticas" "Consumos criticados durante o relacionamento"
         CALL pol0943_consultar() RETURNING p_status
         CLOSE WINDOW w_pol09431
         IF p_status THEN
            ERROR "Consulta efetuada com sucesso !!!"   
         ELSE
            ERROR 'Operação canceada!!!'
         END IF}
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0943

END FUNCTION

#------------------------------#
FUNCTION pol0943_le_parametros()
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
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_pcp')
      RETURN FALSE
   END IF
         
   RETURN TRUE 

END FUNCTION

#------------------------------#
FUNCTION pol0943_cria_tabs_tmp()
#------------------------------#

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

   CREATE TEMP TABLE revertido_tmp_885(
      num_transac INTEGER
     ) ;

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("Criando","revertido_tmp_885")
      RETURN FALSE
   END IF
     
   CREATE TEMP TABLE trans_tmp_885(
      num_transac      INTEGER,
      cod_item         CHAR(15),
      dat_movto        DATE
     );

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("Criando","trans_tmp_885")
      RETURN FALSE
   END IF   
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
 FUNCTION pol0943_informar()
#--------------------------#                  
   
   DEFINE p_dat_txt CHAR(10)

   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   {LET p_tela.dat_ini = p_dat_fecha_ult_sup + 1
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
   END IF}
   
   SELECT dat_fim_proces
     INTO p_tela.dat_ini
     FROM relac_ok_885
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','dat_fim_proces')
      RETURN FALSE
   END IF
   
   LET p_tela.dat_ini = p_tela.dat_ini + 1
   
   
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD dat_ini    
         
         IF p_tela.dat_ini IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!'
            NEXT FIELD dat_ini
         END IF

         {IF p_tela.dat_ini <= p_dat_fecha_ult_man THEN
            ERROR 'Data inicial com manufatura já fechada!'
            NEXT FIELD dat_ini
         END IF
                     
         IF p_tela.dat_ini <= p_dat_fecha_ult_sup THEN
            ERROR 'Data inicial com suprimento já fechado!'
            NEXT FIELD dat_ini
         END IF}

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

#----------------------------#
FUNCTION pol0943_proces_apon()
#----------------------------#

   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")
   
   LET p_cod_empresa = p_cod_emp_ger
   
   IF NOT pol0943_efetua_gravacao() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   LET p_cod_empresa = p_cod_emp_ofic
   
   IF NOT pol0943_efetua_gravacao() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   UPDATE relac_ok_885
      SET dat_fim_proces = p_tela.dat_fim

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update', 'relac_ok_885')
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol0943_efetua_gravacao()
#---------------------------------#

   DEFINE p_dat_apont DATE
   
   MESSAGE 'Gravando relação com chapas/assessórios:'

   DECLARE cq_docum CURSOR FOR 
    SELECT DISTINCT 
           num_docum
      FROM estoque_trans
     WHERE cod_empresa  = p_cod_empresa
       AND num_docum    > 0
       AND cod_operacao = p_cod_oper_rp
          AND num_prog  = 'pol0627'
       AND dat_movto   >= p_tela.dat_ini
       AND dat_movto   <= p_tela.dat_fim
     ORDER BY num_docum

   FOREACH cq_docum INTO p_num_docum
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'cursor cq_docum')
         RETURN FALSE
      END IF
      
      DELETE FROM trans_tmp_885
      
      DECLARE cq_apon CURSOR FOR
       SELECT num_transac,
              cod_item,
              dat_movto
         FROM estoque_trans
        WHERE cod_empresa  = p_cod_empresa
          AND num_docum    = p_num_docum
          AND num_prog     = 'pol0627'
          AND cod_operacao = p_cod_oper_rp
          AND dat_movto   >= p_tela.dat_ini
          AND dat_movto   <= p_tela.dat_fim
          AND ies_tip_movto = 'N'
          AND num_transac NOT IN 
             (SELECT num_transac_normal 
                FROM estoque_trans_rev
               WHERE estoque_trans_rev.cod_empresa = estoque_trans.cod_empresa)
        
      FOREACH cq_apon INTO 
              p_num_transac_orig, p_cod_item_orig, p_dat_apont
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo', 'cursor cq_apon')
            RETURN FALSE
         END IF
         
         INSERT INTO trans_tmp_885
          VALUES(p_num_transac_orig,
                 p_cod_item_orig, 
                 p_dat_apont)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo', 'trans_tmp_885')
            RETURN FALSE
         END IF
                 
      END FOREACH
      
      LET p_transac_ant = 1
      
      DECLARE cq_temp CURSOR FOR
       SELECT num_transac,
              cod_item,
              dat_movto
         FROM trans_tmp_885
        ORDER BY num_transac
      
      FOREACH cq_temp INTO p_num_transac_orig, p_cod_item_orig, p_dat_apont
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo', 'cq_temp')
            RETURN FALSE
         END IF
      
         DECLARE cq_baixa CURSOR FOR
          SELECT num_transac,
                 cod_item,
                 dat_movto,
                 num_lote_orig
            FROM estoque_trans
           WHERE cod_empresa   = p_cod_empresa
             AND num_docum     = p_num_docum
             AND num_prog      = 'pol0627'
             AND cod_operacao  = p_cod_oper_sp
             AND ies_tip_movto = 'N'
             AND num_transac   < p_num_transac_orig
             AND num_transac   > p_transac_ant
             AND dat_movto     = p_dat_apont
             AND num_transac NOT IN 
                (SELECT num_transac_normal 
                   FROM estoque_trans_rev
                  WHERE estoque_trans_rev.cod_empresa = estoque_trans.cod_empresa)

         FOREACH cq_baixa INTO 
                 p_num_transac_dest, p_cod_item_dest, p_dat_movto, p_num_lote
          
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo', 'cursor cq_baixa')
               RETURN FALSE
            END IF
            
            IF NOT pol0943_chk_bobina() THEN
               RETURN FALSE
            END IF
            
            IF p_ies_bobina THEN
               CONTINUE FOREACH
            END IF
            
            DISPLAY p_dat_movto AT 21,45
            
            {SELECT COUNT(num_transac_orig)
              INTO p_count
              FROM est_trans_relac
             WHERE cod_empresa      = p_cod_empresa
               AND num_transac_dest = p_num_transac_dest
                     
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo', 'est_trans_relac')
               RETURN FALSE
            END IF

            IF p_count > 0 THEN
               CONTINUE FOREACH
            END IF}

            IF NOT pol0943_ins_relac() THEN
               RETURN FALSE
            END IF
            
            DISPLAY p_num_transac_orig AT 21,58
         
         END FOREACH
         
         LET p_transac_ant = p_num_transac_orig
         
      END FOREACH
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0943_chk_bobina()
#----------------------------#

   SELECT cod_familia
     INTO p_cod_familia
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_dest

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

#---------------------------#
FUNCTION pol0943_ins_relac()
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

#----------------------------#
FUNCTION pol0943_proces_bob()
#----------------------------#

   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   MESSAGE 'Gravando relação com consumo de bobinas - data:'

   LET p_cod_empresa = p_cod_emp_ger
   LET p_count = 0

   DECLARE cq_dat CURSOR WITH HOLD FOR
    SELECT DISTINCT 
           dat_consumo 
      FROM consu_mat_885 
     WHERE cod_empresa = p_cod_emp_ger
       AND dat_consumo 
           BETWEEN p_tela.dat_ini 
               AND p_tela.dat_fim
     ORDER BY dat_consumo
     
   FOREACH cq_dat INTO p_dat_consumo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_dat')
         RETURN FALSE
      END IF
      
      SELECT dat_geracao
        FROM consu_relac_885
       WHERE dat_consumo = p_dat_consumo
      
      IF STATUS = 0 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 100 THEN
            CALL log003_err_sql('Lendo','consu_relac_885')
            RETURN FALSE
         END IF
      END IF
            
      LET p_count = p_count + 1
      
      DISPLAY p_dat_consumo AT 21,52
      
      LET p_criticou = FALSE

      DELETE FROM relac_erro_885
       WHERE dat_consumo = p_dat_consumo
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Deletando','relac_erro_885')
         RETURN FALSE
      END IF
      
      LET p_index = 0
      INITIALIZE pr_erros TO NULL
      
      CALL log085_transacao("BEGIN")
      
      IF NOT pol0943_grava_reg_bob() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF

      IF p_criticou THEN
         CALL log085_transacao("ROLLBACK")
         CALL log085_transacao("BEGIN")
         IF NOT pol0943_salva_erros() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
         CALL log085_transacao("COMMIT")
      ELSE
         IF NOT pol0943_salva_dat_ok() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
         CALL log085_transacao("COMMIT")
      END IF      
  
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0943_salva_erros()
#----------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO p_index
     
      SELECT dat_consumo
        FROM relac_erro_885
       WHERE dat_consumo = pr_erros[p_ind].dat_consumo
         AND den_erro    = pr_erros[p_ind].den_erro
      
      IF STATUS = 100 THEN
         INSERT INTO relac_erro_885
          VALUES(pr_erros[p_ind].dat_consumo,
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
FUNCTION pol0943_salva_dat_ok()
#-------------------------------#

   INSERT INTO consu_relac_885
    VALUES(p_dat_consumo, getdate(), p_user)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo', 'consu_relac_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION
    
    
#-------------------------------#
FUNCTION pol0943_grava_reg_bob()
#-------------------------------#
          
      DECLARE cq_bobs CURSOR FOR
       SELECT num_ordem, 
              cod_item, 
              num_lote,  
              qtd_consumo 
         FROM consu_mat_885
        WHERE cod_empresa = p_cod_emp_ger 
          AND dat_consumo = p_dat_consumo 
        ORDER BY num_ordem, cod_item
   
      FOREACH cq_bobs INTO p_num_docum, p_cod_item, p_num_lote, p_qtd_consumo
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_bobs')
            RETURN FALSE
         END IF
         
         DECLARE cq_estorna CURSOR FOR
          SELECT cod_empresa, 
             MAX(num_transac) 
            FROM estoque_trans
           WHERE cod_item      = p_cod_item
             AND num_docum     = p_num_docum
             AND num_lote_orig = p_num_lote
             AND ies_tip_movto = 'N' 
             AND cod_empresa IN (p_cod_emp_ger, p_cod_emp_ofic) 
           GROUP BY cod_empresa              
         
         FOREACH cq_estorna INTO p_cod_empresa, p_num_transac

            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','cq_estorna')
               RETURN FALSE
            END IF

            DISPLAY p_num_transac AT 21,65
            
            SELECT qtd_boas+qtd_refug+qtd_sucata
              INTO p_qtd_apont
              FROM ordens
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = p_num_docum

            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','ordens')
               RETURN FALSE
            END IF
            
            IF p_qtd_apont IS NULL OR
               p_qtd_apont = 0 THEN
               LET p_criticou = TRUE
               LET p_msg = 'CONSUMO DE BOBINA P/ OP SEM APONTAMENTOS - OP:',p_num_docum
               LET p_index = p_index + 1
               LET pr_erros[p_index].dat_consumo = p_dat_consumo
               LET pr_erros[p_index].den_erro = p_msg
            END IF

            IF p_criticou THEN
               EXIT FOREACH
            END IF

            IF NOT pol0943_estorna_consumo() THEN
               RETURN FALSE
            END IF
            
            LET p_qtd_unit = p_qtd_consumo / p_qtd_apont
            
            DELETE FROM apont_tmp_885
            DELETE FROM revertido_tmp_885
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
                AND cod_operacao  = 'APON' 
                AND ies_tip_movto = 'N'

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
               
               LET p_num_transac = NULL
               
               SELECT MAX(num_transac)
                 INTO p_num_transac
                 FROM estoque_trans
                WHERE cod_empresa        = p_cod_empresa 
                  AND num_transac        > p_estoque_trans.num_transac
                  AND cod_item           = p_estoque_trans.cod_item
                  AND dat_movto          = p_estoque_trans.dat_movto
                  AND qtd_movto          = p_estoque_trans.qtd_movto
                  AND cod_local_est_dest = p_estoque_trans.cod_local_est_dest
                  AND num_lote_dest      = p_estoque_trans.num_lote_dest
                  AND ies_sit_est_dest   = p_estoque_trans.ies_sit_est_dest
                  AND num_docum          = p_num_docum
                  AND cod_operacao       = 'APON' 
                  AND ies_tip_movto      = 'R'
                  AND num_transac NOT IN (SELECT num_transac FROM revertido_tmp_885)
                 
               IF STATUS <> 0 THEN
                  CALL log003_err_sql('Lendo','estoque_trans')
                  RETURN FALSE
               END IF
               
               IF p_num_transac IS NOT NULL THEN
                  INSERT INTO revertido_tmp_885 VALUES(p_num_transac)
                  IF STATUS <> 0 THEN
                     CALL log003_err_sql('Inserindo','revertido_tmp_885')
                     RETURN FALSE
                  END IF
                  CONTINUE FOREACH
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
            
            IF NOT pol0943_bx_consumo() THEN
               RETURN FALSE
            END IF
            
         END FOREACH
   
      END FOREACH      
   
      RETURN TRUE
   
END FUNCTION   

#---------------------------------#
FUNCTION pol0943_estorna_consumo()
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

   IF NOT pol0943_ins_est_trans() THEN
      RETURN FALSE
   END IF

   IF NOT pol0943_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT pol0943_ins_est_auditoria() THEN
      RETURN FALSE
   END IF

   IF NOT pol0943_ins_trans_rev() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0943_ins_est_trans()
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
 FUNCTION pol0943_ins_est_trans_end()
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
FUNCTION pol0943_ins_est_auditoria()
#-----------------------------------#

  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, 
            p_num_transac_orig, 
            p_user, 
            getdate(),
            "POL0943")

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_auditoria')
     RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0943_ins_trans_rev()
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
FUNCTION pol0943_bx_consumo()
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
      LET p_estoque_trans.daT_movto = p_dat_movto
      LET p_estoque_trans_end.qtd_movto = p_qtd_baixar
      
      IF NOT pol0943_ins_est_trans() THEN
         RETURN FALSE
      END IF

      IF NOT pol0943_ins_est_trans_end() THEN
         RETURN FALSE
      END IF

      IF NOT pol0943_ins_est_auditoria() THEN
         RETURN FALSE
      END IF
      
      LET p_num_transac_dest = p_num_transac_orig
      LET p_cod_item_dest    = p_estoque_trans.cod_item
      LET p_num_transac_orig = p_num_transac_apon
      
      IF NOT pol0943_ins_relac() THEN
         RETURN FALSE
      END IF
            
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
 FUNCTION pol0943_consultar()
#---------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol09431") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol09431 AT 5,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   INITIALIZE pr_erros TO NULL
   
   LET p_index = 1

   DECLARE cq_erros CURSOR FOR 
  
   SELECT dat_consumo,
          den_erro
     FROM relac_erro_885
    ORDER BY dat_consumo                              
      
   FOREACH cq_erros INTO 
           pr_erros[p_index].dat_consumo,
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

#-----------------------END OF PROGRAM--------------------#
