#------------------------------------------------------------------------------#
# OBJETIVO: ESTORNO DE CONSUMO                                                 #
# DATA....: 08/08/2008                                                         #
#------------------------------------------------------------------------------#

 DATABASE logix

 GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_query              CHAR(600),
          p_men                CHAR(300),
          p_msg                CHAR(80),
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
          p_ies_cons           SMALLINT,
          comando              CHAR(80)
          

   DEFINE p_dat_fecha_ult_man  LIKE par_estoque.dat_fecha_ult_man,
          p_dat_fecha_ult_sup  LIKE par_estoque.dat_fecha_ult_sup,
          p_num_lote           LIKE estoque_lote.num_lote,
          p_cod_prod           LIKE ordens.cod_item,
          p_num_docum          LIKE ordens.num_docum,
          p_num_transac_rev    LIKE estoque_trans.num_transac,
          p_num_transac        LIKE estoque_lote.num_transac,
          p_num_transac_o      LIKE estoque_lote.num_transac,
          p_num_transac_0      LIKE estoque_lote.num_transac,
          p_qtd_baixar_ant     LIKE estoque_trans.qtd_movto,
          p_cod_operacao       LIKE estoque_trans.cod_operacao,
          p_cod_item_ord       LIKE item.cod_item
          
          
          

   DEFINE p_man                RECORD LIKE man_apont_912.*,
          p_consu              RECORD LIKE consu_mat_885.*,
          p_estoque_lote       RECORD LIKE estoque_lote.*,
          p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
          p_audit_logix        RECORD LIKE audit_logix.*,
          p_chf_compon         RECORD LIKE chf_componente.*,
          p_est_trans_relac    RECORD LIKE est_trans_relac.*

   DEFINE p_tela               RECORD
          dat_consumo          DATE
   END RECORD
   
   DEFINE p_tela_baixar        RECORD
          dat_inicial          DATE,
          dat_final            DATE
   END RECORD
   
   DEFINE p_datconsumo         LIKE cons_papel_885.datconsumo,
          p_cod_familia        LIKE item.cod_familia,
          p_cod_bob            LIKE item.cod_item,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_ctr_lote           LIKE item.ies_ctr_lote,
          p_sobre_baixa        LIKE item_man.ies_sofre_baixa,
          p_cod_maquina        LIKE consu_mat_885.cod_maquina,
          p_qtd_baixar         LIKE estoque_trans.qtd_movto,
          p_dat_movto          LIKE estoque_trans.dat_movto,
          p_cod_local_orig     LIKE item.cod_local_estoq,
          p_cod_local_dest     LIKE item.cod_local_estoq,
          p_cod_local          LIKE item.cod_local_estoq,
          p_cod_lin_prod       LIKE item.cod_lin_prod,
          p_pct_desc_valor     LIKE desc_nat_oper_885.pct_desc_valor,
          p_pct_desc_qtd       LIKE desc_nat_oper_885.pct_desc_qtd,
          p_num_pedido         LIKE ped_itens.num_pedido,
          p_num_seq_pedido     LIKE ped_itens.num_sequencia,
          p_qtd_reservada      LIKE estoque_loc_reser.qtd_reservada,
          p_num_conta          LIKE estoque_trans.num_conta,
          p_cod_item           LIKE ordens.cod_item,
          p_qtd_saldo          LIKE estoque_lote.qtd_saldo,
          p_num_lote_orig      LIKE estoque_trans.num_lote_orig,
          p_num_lote_dest      LIKE estoque_trans.num_lote_dest,
          p_ies_situa_orig     LIKE estoque_trans.ies_sit_est_orig,
          p_ies_situa_dest     LIKE estoque_trans.ies_sit_est_dest,
          p_qtd_movto          LIKE estoque_trans.qtd_movto,
          p_cod_chapa          LIKE ordens.cod_item

          
          


   DEFINE p_criticou           SMALLINT,
          p_cod_status         CHAR(01),
          p_ies_bobina         SMALLINT,
          p_qtd_integer        INTEGER,
          p_dat_prod           DATE,
          p_ondu               CHAR(01),
          p_flag               CHAR(01),
          p_dat_consumo        DATE,
          p_tem_critica        SMALLINT,
          p_cod_oper           CHAR(01),
          p_cod_tip_movto      CHAR(01),
          p_ies_refugo         CHAR(01),
          p_num_seq_trim       INTEGER,
          p_ctr_estoque        CHAR(01),
          p_ies_tip_item       CHAR(01),
          p_sem_estoque        SMALLINT,
          p_ies_situa          CHAR(01),
          p_ies_com_detalhe    CHAR(01),
          p_qtd_baixa_consu    DECIMAL(6,0),
          p_dat_hor            DATETIME YEAR TO SECOND,
          p_ies_chapa          SMALLINT,
          p_qtd_erro           INTEGER,
          p_cod_oper_insp      CHAR(04)
          
   DEFINE p_incons           ARRAY[2000] OF RECORD
          datconsumo         DATETIME YEAR TO DAY,
          coditem            CHAR(15),
          numlote            CHAR(15),
          qtdconsumo         DECIMAL(10,3),
          qtdestoque         DECIMAL(10,3),
          mensagem           CHAR(70)
   END RECORD
          

   DEFINE pr_erro            ARRAY[200] OF RECORD
          codempresa         CHAR(02),
          numsequencia       INTEGER,
          datconsumo         DATETIME YEAR TO DAY,
          mensagem           CHAR(70),
          dat_hor            DATETIME YEAR TO SECOND       
   END RECORD


END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0930-05.00.13"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0930_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0930_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0930") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0930 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   IF NOT pol0930_le_empresa() THEN
      RETURN
   END IF
   
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Baixar" "Processa a baixa do consumo"
            LET p_qtd_erro = 0
            CALL pol0930_baixar() RETURNING p_status
            IF p_status THEN
               IF p_qtd_erro = 0 THEN
                  CALL log0030_mensagem('Baixa efetuada com sucesso!','excla')
               ELSE
                  LET p_msg = 'Numero de inconsistências encontradas: ',p_qtd_erro
                  CALL log0030_mensagem(p_msg,'excla')
                  NEXT OPTION 'Consultar'
               END IF               
            ELSE
               ERROR 'Operação cancelada!'
            END IF
      COMMAND "Inconsistências" "Exibe os erros encontrados durante a baixa"
            CALL pol0930_erros() RETURNING p_status
            IF p_status THEN
               ERROR 'Consulta efetuada com sucesso!'
            ELSE
               ERROR 'Operação cancelada!'
            END IF
      COMMAND "Estornar" "Processa estorno de consumo"
         CALL pol0930_estornar() RETURNING p_status
         IF p_status THEN
            CALL log0030_mensagem('Estorno de consumo efetuado com sucesso!','info')
         ELSE
            ERROR 'Operação cancelada!'
         END IF
         MESSAGE ''
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol0930

END FUNCTION

#----------------------------#
FUNCTION pol0930_le_empresa()
#----------------------------#

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
          dat_fecha_ult_sup
     INTO p_dat_fecha_ult_man,
          p_dat_fecha_ult_sup
     FROM par_estoque
    WHERE cod_empresa = p_cod_emp_ofic
           
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("lendo", "par_estoque")
      RETURN FALSE
   END IF 

   SELECT cod_operac_estoq_l
     INTO p_cod_oper_insp
     FROM par_sup
    WHERE cod_empresa = p_cod_empresa
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","PAR_SUP")       
      RETURN FALSE
   END IF

   RETURN TRUE 

END FUNCTION

#--------------------------#
FUNCTION pol0930_estornar()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol09301") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol09301 AT 5,5 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   IF NOT pol0930_info_estornar() THEN
      RETURN FALSE
   END IF
 
    IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")
   
   IF NOT pol0930_estorna_consumo() THEN
      CALL log085_transacao("ROLLBACK")
      CLOSE WINDOW w_pol09301
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   
   CLOSE WINDOW w_pol09301   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol0930_info_baixar()
#-----------------------------#
      
   INITIALIZE p_tela_baixar TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela_baixar.*
      WITHOUT DEFAULTS

      AFTER FIELD dat_inicial    
         IF p_tela_baixar.dat_inicial IS NOT NULL THEN
            IF p_tela_baixar.dat_inicial <= p_dat_fecha_ult_man THEN
               ERROR 'Data com manufatura já fechada !!!'
               NEXT FIELD dat_inicial
            END IF
            IF p_tela_baixar.dat_inicial <= p_dat_fecha_ult_sup THEN
               ERROR 'Data com suprimento já fechado !!!'
               NEXT FIELD dat_inicial
            END IF
         END IF
      
      AFTER FIELD dat_final      
         IF p_tela_baixar.dat_final IS NOT NULL THEN
            IF p_tela_baixar.dat_final <= p_dat_fecha_ult_man THEN
               ERROR 'Data com manufatura já fechada !!!'
               NEXT FIELD dat_final
            END IF
            IF p_tela_baixar.dat_final <= p_dat_fecha_ult_sup THEN
               ERROR 'Data com suprimento já fechado !!!'
               NEXT FIELD dat_final
            END IF
         END IF
      
      AFTER INPUT
         IF p_tela_baixar.dat_inicial IS NOT NULL AND                
            p_tela_baixar.dat_final   IS NOT NULL THEN
            IF p_tela_baixar.dat_final < p_tela_baixar.dat_inicial THEN
               ERROR "A data inicial do período não pode ser maior que a data final !!!"
               NEXT FIELD dat_inicial
            END IF
         END IF
         
   END INPUT

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET p_ies_cons = FALSE
      LET INT_FLAG = FALSE
      RETURN FALSE
   ELSE
      LET p_ies_cons = TRUE
      RETURN TRUE  
   END IF
   
END FUNCTION

#-------------------------------#
 FUNCTION pol0930_info_estornar()
#-------------------------------#
   
   DEFINE p_op CHAR(01)
   
   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD dat_consumo    
                  
         IF p_tela.dat_consumo IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!'
            NEXT FIELD dat_consumo
         END IF

         SELECT DISTINCT cod_status
           INTO p_cod_status
           FROM consu_mat_885 
          WHERE cod_empresa  = p_cod_empresa
            AND dat_consumo  = p_tela.dat_consumo
            
         IF STATUS = 100 THEN 
            ERROR "Não há consumo baixado para a data informada!"
            NEXT FIELD dat_consumo 
         ELSE 
            IF STATUS <> 0 THEN 
               CALL log003_err_sql("lendo", "consu_mat_885")
               NEXT FIELD dat_consumo
            END IF 
         END IF 
         
         IF p_cod_status = 'E' THEN
            ERROR 'O consumo da data informada já foi estornado!'
            NEXT FIELD dat_consumo
         END IF
                  
         IF p_tela.dat_consumo <= p_dat_fecha_ult_man THEN
            ERROR 'Data com manufatura já fechada!'
            NEXT FIELD dat_consumo
         END IF
                     
         IF p_tela.dat_consumo <= p_dat_fecha_ult_sup THEN
            ERROR 'Data com suprimento já fechado!'
            NEXT FIELD dat_consumo
         END IF
         
   END INPUT

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE
      LET p_ies_cons = TRUE
      RETURN TRUE  
   END IF
   
END FUNCTION

#---------------------------------#
FUNCTION pol0930_estorna_consumo()
#---------------------------------#

   MESSAGE 'Aguarde!... processando:'

   UPDATE consu_mat_885
      SET cod_status = 'E'
    WHERE cod_empresa = p_cod_empresa
      AND dat_consumo = p_tela.dat_consumo
      AND cod_status  = 'B'

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Atualizando','consu_mat_885')
     RETURN FALSE
   END IF


   DECLARE cq_consu CURSOR FOR
    SELECT num_ordem,
           cod_item,
           num_lote
      FROM consu_mat_885
     WHERE cod_empresa = p_cod_empresa
       AND dat_consumo = p_tela.dat_consumo
       AND cod_status  = 'E'
     ORDER BY num_ordem, cod_item
     
   FOREACH cq_consu INTO
           p_num_docum,
           p_cod_prod,
           p_num_lote

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'consu_mat_885')
         RETURN FALSE
      END IF
      
      DECLARE cq_trans CURSOR FOR
       SELECT *
         FROM estoque_trans
        WHERE cod_empresa IN (p_cod_emp_ger, p_cod_emp_ofic)
          AND num_docum     = p_num_docum
          AND cod_item      = p_cod_prod
          AND num_lote_orig = p_num_lote
          AND (num_prog     = 'pol0930' OR num_prog = 'pol0627')
          AND ies_tip_movto = 'N'

      FOREACH cq_trans INTO p_estoque_trans.*
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo', 'estoque_trans')
            RETURN FALSE
         END IF
      
         DISPLAY p_estoque_trans.num_transac AT 16,30
         
         SELECT num_transac_rev
           FROM estoque_trans_rev
          WHERE cod_empresa        = p_estoque_trans.cod_empresa
            AND num_transac_normal = p_estoque_trans.num_transac
         
         IF STATUS = 0 THEN
            CONTINUE FOREACH
         ELSE
            IF STATUS <> 100 THEN
               CALL log003_err_sql('Lendo','estoque_trans_rev')
               RETURN FALSE
            END IF
         END IF

         LET p_estoque_trans.ies_tip_movto = 'R'
         
         IF NOT pol0930_ins_trans() THEN
            RETURN FALSE
         END IF
         
         IF NOT pol0930_ins_estoq_audit() THEN
            RETURN FALSE
         END IF

         IF NOT pol0930_ins_trans_rev() THEN
            RETURN FALSE
         END IF

         IF NOT pol0930_ins_trans_end() THEN
            RETURN FALSE
         END IF

         IF NOT pol0930_movta_estoque() THEN
            RETURN FALSE
         END IF
         
      END FOREACH
      
   END FOREACH
   
   IF NOT pol0930_grava_cons() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
                   
#---------------------------#
FUNCTION pol0930_ins_trans()
#---------------------------#

   LET p_estoque_trans.nom_usuario   = p_user
   LET p_estoque_trans.dat_proces    = TODAY
   LET p_estoque_trans.hor_operac    = TIME
   LET p_estoque_trans.num_prog      = "POL0930"
   
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
     CALL log003_err_sql('Inserindo', 'estoque_trans')
     RETURN FALSE
   END IF

   LET p_num_transac_rev = SQLCA.SQLERRD[2]

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0930_ins_trans_rev()
#-------------------------------#

   INSERT INTO estoque_trans_rev
       VALUES(p_estoque_trans.cod_empresa,
              p_estoque_trans.num_transac,
              p_num_transac_rev)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo', 'estoque_trans_rev')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0930_ins_estoq_audit()
#---------------------------------#

  INSERT INTO estoque_auditoria 
     VALUES(p_estoque_trans.cod_empresa,
            p_num_transac_rev, 
            p_user, 
            getdate(),
            p_estoque_trans.num_prog)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo', 'estoque_auditoria')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0930_ins_trans_end()
#-------------------------------#

   SELECT * 
     INTO p_estoque_trans_end.*
     FROM estoque_trans_end
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND num_transac = p_estoque_trans.num_transac
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'estoque_trans_end')
      RETURN FALSE
   END IF

   LET p_estoque_trans_end.num_transac      = p_num_transac_rev
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog

   INSERT INTO estoque_trans_end 
      VALUES (p_estoque_trans_end.*)
      
      
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo', 'estoque_trans_end')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0930_movta_estoque()
#-------------------------------#

   IF p_estoque_trans.num_lote_orig IS NOT NULL THEN
		   SELECT num_transac
		     INTO p_num_transac
		     FROM estoque_lote_ender
		    WHERE cod_empresa   = p_estoque_trans.cod_empresa
		      AND cod_item      = p_estoque_trans.cod_item
		      AND cod_local     = p_estoque_trans.cod_local_est_orig
		      AND num_lote      = p_estoque_trans.num_lote_orig
		      AND ies_situa_qtd = p_estoque_trans.ies_sit_est_orig
   ELSE
		   SELECT num_transac
		     INTO p_num_transac
		     FROM estoque_lote_ender
		    WHERE cod_empresa   = p_estoque_trans.cod_empresa
		      AND cod_item      = p_estoque_trans.cod_item
		      AND cod_local     = p_estoque_trans.cod_local_est_orig
		      AND ies_situa_qtd = p_estoque_trans.ies_sit_est_orig
		      AND num_lote      IS NULL
   END IF   
   
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','estoque_lote_ender')
      RETURN FALSE
   END IF  

   IF STATUS = 0 THEN
      IF NOT pol0828_atu_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0828_ins_lote() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol0828_atu_estoque() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol0930_le_lote()
#-------------------------#

   IF p_estoque_trans.num_lote_orig IS NOT NULL THEN
		   SELECT num_transac
		     INTO p_num_transac
		     FROM estoque_lote
		    WHERE cod_empresa   = p_estoque_trans.cod_empresa
		      AND cod_item      = p_estoque_trans.cod_item
		      AND cod_local     = p_estoque_trans.cod_local_est_orig
		      AND num_lote      = p_estoque_trans.num_lote_orig
		      AND ies_situa_qtd = p_estoque_trans.ies_sit_est_orig
   ELSE
		   SELECT num_transac
		     INTO p_num_transac
		     FROM estoque_lote_ender
		    WHERE cod_empresa   = p_estoque_trans.cod_empresa
		      AND cod_item      = p_estoque_trans.cod_item
		      AND cod_local     = p_estoque_trans.cod_local_est_orig
		      AND ies_situa_qtd = p_estoque_trans.ies_sit_est_orig
		      AND num_lote      IS NULL
   END IF   
   
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','estoque_lote')
      RETURN FALSE
   END IF  
   
   IF STATUS = 100 THEN
      INITIALIZE p_num_transac TO NULL
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0828_atu_lote()
#--------------------------#

   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo + p_estoque_trans.qtd_movto
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando', 'estoque_lote_ender')
      RETURN FALSE
   END IF  

   IF NOT pol0930_le_lote() THEN
      RETURN FALSE
   END IF
   
   IF p_num_transac IS NULL THEN
      LET p_men = 'Tabelas estoque_lote e estoque_lote_ender\n',
                  'incompativeis para os parâmetros:\n',
                  'Empresa :', p_estoque_trans.cod_empresa,'\n',
                  'Item    :', p_estoque_trans.cod_item,'\n',
                  'Lote    :', p_estoque_trans.num_lote_orig,'\n',
                  'Local   :', p_estoque_trans.cod_local_est_orig,'\n',
                  'Situação:', p_estoque_trans.ies_sit_est_orig,'\n'
      
      CALL log0030_mensagem(p_men,'excla')
      RETURN FALSE
   END IF

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + p_estoque_trans.qtd_movto
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','estoque_lote')
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0828_ins_lote()
#--------------------------#
 
   INSERT INTO estoque_lote_ender(
          cod_empresa,
          cod_item,
          cod_local,
          num_lote,
          endereco,
          num_volume,
          cod_grade_1,
          cod_grade_2,
          cod_grade_3,
          cod_grade_4,
          cod_grade_5,
          dat_hor_producao,
          num_ped_ven,
          num_seq_ped_ven,
          ies_situa_qtd,
          qtd_saldo,
          ies_origem_entrada,
          dat_hor_validade,
          num_peca,
          num_serie,
          comprimento,
          largura,
          altura,
          diametro,
          dat_hor_reserv_1,
          dat_hor_reserv_2,
          dat_hor_reserv_3,
          qtd_reserv_1,
          qtd_reserv_2,
          qtd_reserv_3,
          num_reserv_1,
          num_reserv_2,
          num_reserv_3,
          tex_reservado) 
          VALUES(p_estoque_trans.cod_empresa,
                 p_estoque_trans.cod_item,
                 p_estoque_trans.cod_local_est_orig,
                 p_estoque_trans.num_lote_orig,
                 p_estoque_trans_end.endereco,
                 p_estoque_trans_end.num_volume,
                 p_estoque_trans_end.cod_grade_1,
                 p_estoque_trans_end.cod_grade_2,
                 p_estoque_trans_end.cod_grade_3,
                 p_estoque_trans_end.cod_grade_4,
                 p_estoque_trans_end.cod_grade_5,
                 p_estoque_trans_end.dat_hor_producao,
                 p_estoque_trans_end.num_ped_ven,
                 p_estoque_trans_end.num_seq_ped_ven,
                 p_estoque_trans.ies_sit_est_orig,
                 p_estoque_trans_end.qtd_movto,
                 ' ',
                 p_estoque_trans_end.dat_hor_validade,
                 p_estoque_trans_end.num_peca,
                 p_estoque_trans_end.num_serie,
                 p_estoque_trans_end.comprimento,
                 p_estoque_trans_end.largura,
                 p_estoque_trans_end.altura,
                 p_estoque_trans_end.diametro,
                 p_estoque_trans_end.dat_hor_reserv_1,
                 p_estoque_trans_end.dat_hor_reserv_2,
                 p_estoque_trans_end.dat_hor_reserv_3,
                 p_estoque_trans_end.qtd_reserv_1,
                 p_estoque_trans_end.qtd_reserv_2,
                 p_estoque_trans_end.qtd_reserv_3,
                 p_estoque_trans_end.num_reserv_1,
                 p_estoque_trans_end.num_reserv_2,
                 p_estoque_trans_end.num_reserv_3,
                 p_estoque_trans_end.tex_reservado)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_lote_ender')
     RETURN FALSE
   END IF

   INSERT INTO estoque_lote(
          cod_empresa, 
          cod_item, 
          cod_local, 
          num_lote, 
          ies_situa_qtd, 
          qtd_saldo)  
          VALUES(p_estoque_trans.cod_empresa,
                 p_estoque_trans.cod_item,
                 p_estoque_trans.cod_local_est_orig,
                 p_estoque_trans.num_lote_orig,
                 p_estoque_trans.ies_sit_est_orig,
                 p_estoque_trans.qtd_movto)

   IF STATUS <> 0 THEN
     MESSAGE "Item/lote:", p_estoque_trans.cod_item, '/', p_estoque_trans.num_lote_orig
     CALL log003_err_sql('Inserindo','estoque_lote')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0828_atu_estoque()
#-----------------------------#

   IF p_estoque_trans.ies_sit_est_orig = 'L' THEN
      UPDATE estoque
         SET qtd_liberada    = qtd_liberada + p_estoque_trans.qtd_movto,
             dat_ult_entrada = getdate()
       WHERE cod_empresa = p_estoque_trans.cod_empresa
         AND cod_item    = p_estoque_trans.cod_item
   ELSE
      UPDATE estoque
         SET qtd_lib_excep   = qtd_lib_excep + p_estoque_trans.qtd_movto,
             dat_ult_entrada = getdate()
       WHERE cod_empresa = p_estoque_trans.cod_empresa
         AND cod_item    = p_estoque_trans.cod_item
   END IF
   
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0930_grava_cons()
#----------------------------#

   DELETE FROM cons_papel_885
    WHERE codempresa     = p_cod_empresa
      AND datconsumo     = p_tela.dat_consumo

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Atualizando','cons_papel_885')
     RETURN FALSE
   END IF

   DELETE FROM cons_erro_885
    WHERE codempresa = p_cod_empresa
      AND datconsumo = p_tela.dat_consumo

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Deletando','cons_erro_885')
     RETURN FALSE
   END IF

   DELETE FROM consu_mat_885
    WHERE cod_empresa = p_cod_empresa
      AND dat_consumo = p_tela.dat_consumo
      AND cod_status  = 'E'

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Deletando','consu_mat_885')
     RETURN FALSE
   END IF

   DELETE FROM dat_consumo_885
    WHERE cod_empresa = p_cod_empresa
      AND dat_consumo = p_tela.dat_consumo

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Deletando','dat_consumo_885')
     RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------#
FUNCTION pol0930_baixar()
#------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol09303") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol09303 AT 5,5 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   IF NOT pol0930_info_baixar() THEN
      RETURN FALSE
   END IF

   CLOSE WINDOW w_pol09303
   
   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")
   
   LET p_man.num_seq_apont = 0
   
   DELETE FROM cons_erro_885
    WHERE codempresa = p_cod_empresa
      AND (numsequencia IS NULL OR numsequencia NOT IN
          (SELECT numsequencia FROM cons_papel_885
            WHERE codempresa = p_cod_empresa))

   SELECT COUNT(*)
     INTO p_count
     FROM cons_papel_885
    WHERE (codempresa IS NULL OR codempresa <> p_cod_empresa)
      AND StatusRegistro IN ('0','2')

   IF p_count > 0 THEN
      LET p_consu.num_seq_trim = 0
      LET p_msg = 'EXISTEM: ', p_count, ' CONSUMOS COM CODIGO DA EMPRESA INVALIDO'
      IF NOT pol0930_grava_erro() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
   END IF

   INITIALIZE p_consu, p_msg TO NULL

   UPDATE cons_papel_885
      SET StatusRegistro = '2'
    WHERE codempresa     = p_cod_empresa
      AND StatusRegistro = '0'
      AND datconsumo IN
          (SELECT dat_consumo 
             FROM dat_consumo_885
            WHERE cod_empresa = p_cod_empresa
              AND cod_status  = 'S')

   IF STATUS <> 0 THEN
	    CALL log085_transacao("ROLLBACK")
      LET p_msg = 'ERRO:(',STATUS, ') BLOQUEANDO CONSUMOS'
	    LET p_consu.num_seq_trim = 0
	    CALL pol0930_grava_erro() RETURNING p_status
	    RETURN FALSE
	 END IF

   CALL log085_transacao("COMMIT")

   LET p_query =
       "SELECT datconsumo FROM cons_papel_885 ",
       " WHERE codempresa ='",p_cod_empresa,"' ",
       "   AND StatusRegistro = '2' "

   IF p_tela_baixar.dat_inicial IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND datconsumo >= '",p_tela_baixar.dat_inicial,"' "
   END IF
   
   IF p_tela_baixar.dat_final IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND datconsumo <= '",p_tela_baixar.dat_final,"' "
   END IF
   
   LET p_query = p_query CLIPPED, " GROUP BY datconsumo ORDER BY datconsumo "  

   PREPARE var_query FROM p_query   
   DECLARE cq_dat CURSOR WITH HOLD FOR var_query

   FOREACH cq_dat INTO p_datconsumo

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO DATA DO CONSUMO:CQ_DAT'
         LET p_consu.num_seq_trim = 0
	       CALL pol0930_grava_erro() RETURNING p_status
	       RETURN FALSE
	    END IF
             
 	    LET p_criticou = FALSE
   
      CALL log085_transacao("BEGIN")
      
 	    IF NOT pol0930_apaga_erros() THEN
	       RETURN FALSE
	    END IF

      IF pol0930_proces_datconsumo() THEN
         
         UPDATE cons_papel_885
            SET StatusRegistro = '1'
          WHERE codempresa     = p_cod_empresa
            AND datconsumo     = p_datconsumo
            AND statusregistro = '2'

         IF STATUS <> 0 THEN
            CALL log085_transacao("ROLLBACK")
            LET p_msg = 'ERRO:(',STATUS, ') EFETIVANDO CONSUMO:', p_datconsumo
      	    LET p_consu.num_seq_trim = 0
	          CALL pol0930_grava_erro() RETURNING p_status
	          RETURN FALSE
	   	   END IF
         
         UPDATE dat_consumo_885
            SET cod_status = 'P'
          WHERE cod_empresa = p_cod_empresa
            AND dat_consumo = p_datconsumo
            
         IF STATUS <> 0 THEN
            CALL log085_transacao("ROLLBACK")
            LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO DAT_CONSUMO_885:'
      	    LET p_consu.num_seq_trim = 0
	          CALL pol0930_grava_erro() RETURNING p_status
	          RETURN FALSE
	   	   END IF
         
         CALL log085_transacao("COMMIT")
         
         LET p_msg = 'Baixa de consumo efetuado com sucesso!'
 
 	    ELSE
 	       IF p_msg IS NOT NULL THEN
 	          CALL pol0930_grava_erro() RETURNING p_status
 	       END IF
 	       
         CALL pol0930_carrega_erros()
         
         CALL log085_transacao("ROLLBACK")
         
         IF p_tem_critica THEN     
          
            CALL log085_transacao("BEGIN")   
            
            UPDATE cons_papel_885
               SET StatusRegistro = '3'
             WHERE codempresa     = p_cod_empresa
               AND datconsumo     = p_datconsumo
               AND statusregistro = '2'

            IF STATUS <> 0 THEN
	             CALL log085_transacao("ROLLBACK")
               LET p_msg = 'ERRO:(',STATUS, ') EFETIVANDO CONSUMO ', p_datconsumo
         	     LET p_consu.num_seq_trim = 0
	             CALL pol0930_grava_erro() RETURNING p_status
	             RETURN FALSE
            END IF

            DELETE FROM dat_consumo_885
             WHERE cod_empresa = p_cod_empresa
               AND dat_consumo = p_datconsumo
            
            IF STATUS <> 0 THEN
               CALL log085_transacao("ROLLBACK")
               LET p_msg = 'ERRO:(',STATUS, ') DELETANDO DAT_CONSUMO_885 ', p_datconsumo
         	     LET p_consu.num_seq_trim = 0
	             CALL pol0930_grava_erro() RETURNING p_status
	             RETURN FALSE
	   	      END IF
	   	      
	   	      CALL log085_transacao("COMMIT")
	   	      
	   	      LET p_msg = 
	   	          'Foi detectada a presença de inconsistências. Execute a Consulta.'
	   	      
         END IF
         
         CALL pol0930_recupera_erros()
          
	    END IF

   END FOREACH

   SELECT COUNT(numsequencia)
     INTO p_qtd_erro
     FROM cons_erro_885
    WHERE codempresa = p_cod_empresa
    
   RETURN TRUE
   
END FUNCTION 

#----------------------------#
FUNCTION pol0930_apaga_erros()
#----------------------------#

   DELETE FROM cons_erro_885
    WHERE codempresa = p_cod_empresa
      AND datconsumo = p_datconsumo

   IF STATUS <> 0 THEN 
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO CONS_ERRO_885'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0930_proces_datconsumo()
#-----------------------------------#

   MESSAGE 'Processando data: ',p_datconsumo
   
   LET p_tem_critica = FALSE

   SELECT COUNT(dat_consumo)
     INTO p_count
     FROM consu_mat_885
    WHERE cod_empresa = p_cod_empresa
      AND dat_consumo = p_datconsumo

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO consu_mat_885:ppd'
      LET p_consu.num_seq_trim = 0
	    RETURN FALSE
	 END IF

   IF p_count > 0 THEN
      LET p_msg = 'DATA DE CONSUMO JA APONTADA'
      LET p_consu.num_seq_trim = 0
      LET p_tem_critica = TRUE
      RETURN FALSE
   END IF

   DELETE FROM cons_papel_885
	   WHERE codempresa     = p_cod_empresa
	     AND datconsumo     = p_datconsumo
	     AND statusregistro = '3'

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO CONSUMOS COM STATUS 3'
      LET p_consu.num_seq_trim = 0
	    RETURN FALSE
	 END IF
              
   DECLARE cq_cons CURSOR FOR
	  SELECT codempresa,
	         numsequencia,
	         numordem,
	         coditem,
	         numlote,
	         qtdconsumo,
	         codmaquina,
	         iesrefugo,
	         datconsumo,
	         datregistro
	    FROM cons_papel_885
	   WHERE codempresa     = p_cod_empresa
	     AND datconsumo     = p_datconsumo
	     AND statusregistro = '2'
	     ORDER BY numsequencia
	
   FOREACH cq_cons INTO 
	          p_consu.cod_empresa,
	          p_consu.num_seq_trim,
	          p_consu.num_ordem,
	          p_consu.cod_item,
	          p_consu.num_lote,
	          p_consu.qtd_consumo,
	          p_consu.cod_maquina,
	          p_consu.ies_refugo,
	          p_consu.dat_consumo,
	          p_consu.dat_registro
	
      IF STATUS <> 0 THEN
	       LET p_msg = 'ERRO:(',STATUS, ') LENDO CONS_PAPEL_885:cq_cons'
         LET p_consu.num_seq_trim = 0
	       RETURN FALSE
	    END IF
	      
	    LET p_msg = NULL
	    LET p_criticou = FALSE
	      
	    DISPLAY 'Seq:', p_consu.num_seq_trim AT 21,35
	
	    IF p_consu.ies_refugo IS NULL THEN
	       LET p_consu.ies_refugo = 'N'	
	    END IF
	    
	    IF NOT pol0930_consiste_consu() THEN
         RETURN FALSE
	    END IF
	
	    IF p_criticou THEN
	       LET p_tem_critica = TRUE
	       CONTINUE FOREACH
	    END IF
	    
	    IF NOT p_tem_critica THEN
         IF NOT pol0930_baixa_papel() THEN
            RETURN FALSE
         END IF
         IF p_criticou THEN
            LET p_tem_critica = TRUE
            IF NOT pol0930_grava_erro() THEN
               RETURN FALSE
            END IF
         ELSE
            CALL pol0930_insere_consu() RETURNING p_status
         END IF
      END IF
	      
   END FOREACH
   
   IF p_tem_critica THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol0930_baixa_papel()
#----------------------------#

   LET p_cod_oper = 'B'
   LET p_cod_tip_movto = 'N'
   LET p_num_seq_trim       = p_consu.num_seq_trim
   LET p_cod_prod           = p_consu.cod_item
   LET p_num_lote           = p_consu.num_lote
   LET p_cod_maquina        = p_consu.cod_maquina
   LET p_qtd_baixar         = p_consu.qtd_consumo
   LET p_ies_refugo         = p_consu.ies_refugo
   LET p_dat_movto          = p_consu.dat_consumo
       
   DISPLAY p_man.ordem_producao TO num_ordem
            
   SELECT num_conta
     INTO p_num_conta
     FROM de_para_maq_885
	  WHERE cod_empresa  = p_cod_empresa
		  AND cod_maq_trim = p_cod_maquina

   IF STATUS = 100 THEN
      LET p_num_conta = NULL
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB DE_PARA_MAQ_885:NUM_CONTA'  
         RETURN FALSE
      END IF
   END IF

   IF NOT pol0930_le_item_man() THEN
      RETURN FALSE
   END IF

   IF p_ies_refugo = 'N' THEN
      SELECT num_docum
        INTO p_num_docum
        FROM ordens 
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem   = p_consu.num_ordem
         
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORDENS:CQ_CONS_PAPEL'  
         RETURN FALSE
      END IF

      CALL pol0930_pega_pedido()
      
      IF NOT pol0930_le_desc_nat_oper_885() THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_pct_desc_valor = 0
      LET p_pct_desc_qtd   = 0
   END IF
      
   IF p_ctr_estoque = 'N' OR p_sobre_baixa = 'N' THEN
      LET p_msg = p_cod_prod CLIPPED,' - ESSE MATERIAL NAO SOFRE BAIXA'
      LET p_criticou = TRUE
   ELSE
      IF NOT pol0930_checa_estoque() THEN
         RETURN FALSE
      END IF
      IF p_sem_estoque THEN
         LET p_msg = 'SEM SALDO SUFICIENTE P/ BAIXAR'
         LET p_criticou = TRUE
      ELSE
         LET p_num_docum = p_consu.num_ordem
         LET p_qtd_baixar_ant = p_qtd_baixar
         LET p_num_transac = p_num_transac_o
         IF NOT pol627_baixa_consumo() THEN
            RETURN FALSE
         ELSE
            LET p_cod_empresa  = p_cod_emp_ofic
            LET p_num_transac = p_num_transac_0
            LET p_qtd_baixar = p_qtd_baixar_ant
            IF NOT pol627_baixa_consumo() THEN
               LET p_cod_empresa = p_cod_emp_ger
               RETURN FALSE
            END IF
            LET p_cod_empresa  = p_cod_emp_ger
            LET p_msg = p_cod_prod CLIPPED,' - BAIXA EFETUADA COM SUCESSO'
         END IF
      END IF
   END IF
     
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0930_le_item_man()
#-----------------------------#

   SELECT a.cod_local_estoq,
          a.ies_ctr_estoque,
          a.ies_ctr_lote,
          a.cod_familia,
          b.ies_sofre_baixa,
          ies_tip_item,
          cod_lin_prod
     INTO p_cod_local_orig,
          p_ctr_estoque,
          p_ctr_lote,
          p_cod_familia,
          p_sobre_baixa,
          p_ies_tip_item,
          p_cod_lin_prod
     FROM item a,
          item_man b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.cod_item    = p_cod_prod
      AND b.cod_empresa = a.cod_empresa
      AND b.cod_item    = a.cod_item

   IF STATUS = 100 THEN
      LET p_cod_local_orig = 'N'
      LET p_ctr_estoque    = 'N'
      LET p_ctr_lote       = 'N'
      LET p_sobre_baixa    = 'N'
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ITEM/ITEM_MAN'  
         RETURN FALSE
      END IF
   END IF  

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0930_insere_consu()
#------------------------------#

   LET p_consu.mensagem = 'BAIXA EFETUADA COM SUCESSO'
   LET p_consu.nom_prog = 'pol0930'
   LET p_consu.nom_usuario = p_user
   LET p_consu.num_versao = 1
   LET p_consu.foi_baixado = 'S'
   LET p_consu.cod_status = 'B'

   INSERT INTO consu_mat_885
    VALUES(p_consu.*)
    
   IF STATUS <> 0 THEN 
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA CONSU_MAT_885'
      RETURN FALSE
   END IF

   LET p_qtd_baixa_consu = p_qtd_baixa_consu + 1
   DISPLAY p_qtd_baixa_consu TO qtd_baixa_consu

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0930_consiste_consu()
#--------------------------------#

   IF p_consu.num_seq_trim IS NULL OR p_consu.num_seq_trim = 0 THEN
      LET p_consu.num_seq_trim = 0
      LET p_msg = 'CODIGO DE SEQUENCIA INVALIDO ',p_consu.num_seq_trim
      IF NOT pol0930_grava_erro() THEN
         RETURN FALSE
      ELSE
         RETURN TRUE
      END IF
   END IF
   
   SELECT num_seq_trim
     FROM consu_mat_885
    WHERE cod_empresa = p_cod_empresa
      AND num_seq_trim = p_consu.num_seq_trim

   IF STATUS = 100 THEN
   ELSE
      IF STATUS = 0 THEN
         LET p_msg = 'SEQUENCIA DE CONSUMO JA ENVIADA ',p_consu.num_seq_trim
         IF NOT pol0930_grava_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_msg = 'ERRO:(',STATUS, ') LENDO CONSU_MAT_885:VALIDANDO SEQUENCIA'
         RETURN FALSE
      END IF
   END IF

   IF p_consu.ies_refugo = 'N' THEN 
      IF p_consu.num_ordem IS NULL OR p_consu.num_ordem = 0 THEN
         LET p_msg = 'OREM DE PRODUÇÃO INVALIDA ',p_consu.num_ordem
         IF NOT pol0930_grava_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_cod_item = NULL
         SELECT cod_item
           INTO p_cod_item
           FROM ordens
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem   = p_consu.num_ordem

         IF STATUS = 100 THEN
            LET p_msg = 'ORDEM DE PRODUCAO INIXISTENTE ',p_consu.num_ordem
            IF NOT pol0930_grava_erro() THEN
               RETURN FALSE
            END IF
         ELSE
            IF STATUS <> 0 THEN
               LET p_msg = 'ERRO:(',STATUS, ') LENDO, P/ VALIDAR, TAB ORDENS'
               RETURN FALSE
            END IF
         END IF
         LET p_cod_item_ord = p_cod_item
      END IF
   END IF
   
   IF p_consu.cod_item IS NULL OR p_consu.cod_item = 0 THEN
      LET p_msg = 'CODIGO DO ITEM INVALIDO'
      IF NOT pol0930_grava_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      SELECT ies_ctr_lote,
             cod_familia
        INTO p_ctr_lote,
             p_cod_familia
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_consu.cod_item

      IF STATUS = 100 THEN
         LET p_msg = 'CODIGO DO ITEM ENVIADO INIXISTENTE'
         IF NOT pol0930_grava_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO, P/ VALIDAR, TAB ITEM'
            RETURN FALSE
         END IF
      END IF
   END IF

   IF p_consu.num_lote IS NULL THEN
      LET p_msg = 'NUMERO DO LOTE ESTA NULO'
      IF NOT pol0930_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_consu.qtd_consumo IS NULL OR p_consu.qtd_consumo = 0 THEN
      LET p_msg = 'QUANTIDADE CONSUMIDA INVALIDA ',p_consu.qtd_consumo
      IF NOT pol0930_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_consu.dat_consumo IS NULL THEN
      LET p_msg = 'DATA DO CONSUMO ESTA NULA'
      IF NOT pol0930_grava_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      IF p_dat_fecha_ult_man IS NOT NULL THEN
         IF p_consu.dat_consumo  <= p_dat_fecha_ult_man THEN
            LET p_msg = 'CONSUMO APOS FECHAMENTO DA MANUFATURA - VER C/ SETOR FISCAL'
            IF NOT pol0930_grava_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
      IF p_dat_fecha_ult_sup IS NOT NULL THEN
         IF p_consu.dat_consumo  <= p_dat_fecha_ult_sup THEN
            LET p_msg = 'CONSUMO APOS FECHAMENTO DO ESTOQUE - VER C/ SETOR FISCAL'
            IF NOT pol0930_grava_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF      
      
   IF p_criticou THEN 
      RETURN TRUE
   END IF
   
   IF NOT pol0930_troca_op() THEN
      RETURN FALSE
   END IF

   IF p_consu.num_lote IS NOT NULL THEN
      SELECT COUNT(num_lote)
        INTO p_count
        FROM estoque_lote
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_consu.cod_item
         AND num_lote    = p_consu.num_lote
      IF p_count = 0 THEN
         LET p_msg = 'LOTE(',p_consu.num_lote
         LET p_msg = p_msg CLIPPED,')INEXISTENTE'
         SELECT DISTINCT
                cod_item 
           INTO p_cod_bob
           FROM estoque_lote
          WHERE cod_empresa = p_cod_empresa
            AND num_lote    = p_consu.num_lote
         IF STATUS = 0 THEN
            LET p_msg = p_msg CLIPPED, '-IT LOGIX:',p_cod_bob
         END IF
         IF NOT pol0930_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF NOT p_criticou THEN   
      
      SELECT MAX(num_transac)
        INTO p_num_transac
        FROM estoque_trans
       WHERE cod_empresa   = p_cod_emp_ofic
         AND cod_item      = p_consu.cod_item
         AND num_lote_dest = p_consu.num_lote
         AND ies_tip_movto = 'N'
         AND (cod_operacao  = p_cod_oper_insp OR cod_operacao = 'IMPL')
      
      IF p_num_transac IS NULL THEN
         LET p_msg = 'ITEM/LOTE SEM MOVIMENTO DE ENTRADA NO LOGIX'
         IF NOT pol0930_grava_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         SELECT dat_movto
           INTO p_dat_prod
           FROM estoque_trans
          WHERE cod_empresa = p_cod_emp_ofic
            AND num_transac = p_num_transac
        
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO DATA DE ENTRADA DA BOBINA'  
            RETURN FALSE
         ELSE
            IF p_dat_prod > p_consu.dat_consumo THEN
               LET p_msg = 'DATA DO CONSUMO < DATA DE ENTRADA NO LOGIX'
               IF NOT pol0930_grava_erro() THEN
                  RETURN FALSE
               END IF
            END IF
         END IF
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol0930_grava_erro()
#-----------------------------#

   LET p_criticou = TRUE
   LET p_dat_hor = CURRENT YEAR TO SECOND

   INSERT INTO cons_erro_885
      VALUES (p_cod_empresa,
              p_consu.num_seq_trim,
              p_datconsumo,
              p_msg,
              p_dat_hor)

   IF sqlca.sqlcode <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA CONS_ERRO_885'
      RETURN FALSE
   END IF                                           
   
   LET p_qtd_erro = p_qtd_erro + 1
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------------#
FUNCTION pol0930_le_desc_nat_oper_885()
#--------------------------------------#

   SELECT pct_desc_valor,
          pct_desc_qtd
     INTO p_pct_desc_valor,
          p_pct_desc_qtd
    FROM desc_nat_oper_885
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = p_num_pedido
            
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB desc_nat_oper_885:2'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0930_pega_pedido()
#-------------------------------#

   DEFINE p_carac CHAR(01),
          p_numpedido CHAR(6),
          p_numseq    CHAR(3),
          p_ind       SMALLINT

   INITIALIZE p_numpedido, p_numseq TO NULL

   FOR p_ind = 1 TO LENGTH(p_num_docum)
       LET p_carac = p_num_docum[p_ind]
       IF p_carac = '/' THEN
          EXIT FOR
       END IF
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numpedido = p_numpedido CLIPPED, p_carac
       END IF
   END FOR
   
   FOR p_ind = p_ind + 1 TO LENGTH(p_num_docum)
       LET p_carac = p_num_docum[p_ind]
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numseq = p_numseq CLIPPED, p_carac
       END IF
   END FOR
   
   LET p_num_pedido     = p_numpedido
   LET p_num_seq_pedido = p_numseq

END FUNCTION

#-------------------------------#
FUNCTION pol0930_checa_estoque()
#-------------------------------#

   IF NOT pol0930_ve_estoque() THEN
      RETURN FALSE
   END IF
   
   IF p_sem_estoque THEN 
      RETURN TRUE
   END IF

   LET p_num_transac_o = p_num_transac
   LET p_cod_empresa   = p_cod_emp_ofic
   
   IF NOT pol0930_ve_estoque() THEN
      LET p_cod_empresa = p_cod_emp_ger
      RETURN FALSE
   END IF

   LET p_num_transac_0 = p_num_transac
   LET p_cod_empresa = p_cod_emp_ger

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0930_ve_estoque()
#-------------------------------#

   LET p_sem_estoque = FALSE
   LET p_cod_local   = p_cod_local_orig
   LET p_ies_situa   = 'L'
   
   SELECT qtd_saldo,
          num_transac
     INTO p_qtd_saldo,
          p_num_transac
     FROM estoque_lote
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = p_cod_prod
      AND cod_local     = p_cod_local
      AND num_lote      = p_num_lote
      AND ies_situa_qtd = p_ies_situa

   IF STATUS <> 0 THEN
      LET p_ies_situa   = 'E'
   
      SELECT qtd_saldo,
             num_transac
        INTO p_qtd_saldo,
             p_num_transac
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_prod
         AND cod_local     = p_cod_local
         AND num_lote      = p_num_lote
         AND ies_situa_qtd = p_ies_situa


      IF STATUS <> 0 THEN
         LET p_qtd_saldo = 0
      END IF
   END IF  

   SELECT SUM(qtd_reservada - qtd_atendida)
     INTO p_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_prod
      AND cod_local   = p_cod_local
      AND num_lote    = p_num_lote

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') CHECANDO MP NA ESTOQUE_LOC_RESER'  
      RETURN FALSE
   END IF  

   IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
      LET p_qtd_reservada = 0
   END IF
       
   IF p_qtd_saldo > p_qtd_reservada THEN
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
   ELSE
      LET p_qtd_saldo = 0
   END IF

   IF p_qtd_saldo < p_qtd_baixar THEN
      LET p_sem_estoque = TRUE
      RETURN TRUE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol627_baixa_consumo()
#------------------------------#

   LET p_num_lote_dest = NULL
   LET p_ies_situa_orig = p_ies_situa
   LET p_ies_situa_dest = NULL
   LET p_num_lote_orig = p_num_lote
   
	 IF p_ies_refugo = 'S' THEN
      SELECT substring(parametros,133,4)
        INTO p_cod_operacao
        FROM par_pcp
       WHERE cod_empresa = p_cod_empresa
   END IF
         
   LET p_qtd_movto = p_qtd_baixar 

   IF NOT pol0930_atualiza_lote() THEN
      RETURN FALSE
   END IF

   IF NOT pol0930_deleta_lote() THEN
      RETURN FALSE
   END IF

   IF NOT pol0930_update_estoque() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0930_atualiza_lote()
#-------------------------------#

   DEFINE p_achou SMALLINT

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo - p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN      
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TAB ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF   

   LET p_achou = FALSE
   
   IF p_num_lote IS NOT NULL THEN
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_prod
         AND num_lote      = p_num_lote
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
   ELSE
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_prod
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND num_lote      IS NULL
   END IF
   
   IF STATUS = 100 THEN
      LET p_msg = 'ESTOQUE_LOTE/ESTOQUE_LOTE_ENDER INCOMPATIVEIS - OP',p_man.ordem_producao  
      RETURN FALSE
   END IF
   
   IF STATUS <> 0 THEN
      IF STATUS = -284 THEN
         LET p_msg = "LOTE:",p_num_lote
         LET p_msg = p_msg CLIPPED," REPETIDO NA ESTOQUE_LOTE_ENDER"
      ELSE
         LET p_msg = 'ERRO:(',STATUS, ')LENDO TAB ESTOQUE_LOTE_ENDER - LOTE:', p_num_lote
      END IF
      RETURN FALSE
   END IF
   
   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo - p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_estoque_lote_ender.num_transac

   IF STATUS <> 0 THEN      
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TAB ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF   
  
   IF NOT pol0930_grava_trans() THEN
      RETURN FALSE
   END IF

   IF NOT pol0930_ins_estoq_audit() THEN
      RETURN FALSE
   END IF

   IF NOT pol0930_grava_trans_end() THEN
      RETURN FALSE
   END IF
            
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0930_grava_trans()
#-----------------------------#

   INITIALIZE p_estoque_trans.* TO NULL

   IF p_cod_operacao IS NULL THEN
      IF NOT pol0930_le_operacao() THEN
         RETURN FALSE
      END IF
   END IF
   
   SELECT ies_com_detalhe
     INTO p_ies_com_detalhe
     FROM estoque_operac
    WHERE cod_empresa  = p_cod_empresa
      AND cod_operacao = p_cod_operacao

   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_OPERAC:', p_cod_operacao
     RETURN FALSE
   END IF

   IF p_ies_com_detalhe = 'S' THEN 
      IF p_num_conta IS NULL THEN
         SELECT num_conta_debito 
           INTO p_num_conta
           FROM estoque_operac_ct
          WHERE cod_empresa  = p_cod_empresa
            AND cod_operacao = p_cod_operacao

         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_OPERAC_CT:', p_cod_operacao
            RETURN FALSE
         END IF
      END IF
   END IF
   
   LET p_estoque_trans.cod_empresa        = p_cod_empresa
   LET p_estoque_trans.num_transac        = 0
   LET p_estoque_trans.cod_item           = p_cod_prod
   LET p_estoque_trans.dat_movto          = p_dat_movto
   LET p_estoque_trans.dat_ref_moeda_fort = TODAY
   LET p_estoque_trans.dat_proces         = TODAY
   LET p_estoque_trans.hor_operac         = TIME
   LET p_estoque_trans.ies_tip_movto      = p_cod_tip_movto
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_prog           = "POL0930"
   LET p_estoque_trans.num_docum          = p_num_docum
   LET p_estoque_trans.num_seq            = NULL
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = NULL
   LET p_estoque_trans.nom_usuario        = p_user
   LET p_estoque_trans.qtd_movto          = p_qtd_movto
   LET p_estoque_trans.ies_sit_est_orig   = p_ies_situa_orig
   LET p_estoque_trans.ies_sit_est_dest   = p_ies_situa_dest
   LET p_estoque_trans.cod_local_est_orig = p_cod_local_orig
   LET p_estoque_trans.cod_local_est_dest = p_cod_local_dest
   LET p_estoque_trans.num_lote_orig      = p_num_lote_orig
   LET p_estoque_trans.num_lote_dest      = p_num_lote_dest

   IF NOT pol0930_ins_trans() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol0930_le_operacao()
#-----------------------------#

     
   SELECT cod_estoque_sp    
     INTO p_cod_operacao
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB PAR_PCP.COD_ESTOQUE_SP/RP'  
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0930_grava_trans_end()
#--------------------------------#

   INITIALIZE p_estoque_trans_end.* TO NULL

   LET p_estoque_trans_end.num_transac      = p_num_transac_rev
   LET p_estoque_trans_end.endereco         = p_estoque_lote_ender.endereco
   LET p_estoque_trans_end.cod_grade_1      = p_estoque_lote_ender.cod_grade_1
   LET p_estoque_trans_end.cod_grade_2      = p_estoque_lote_ender.cod_grade_2
   LET p_estoque_trans_end.cod_grade_3      = p_estoque_lote_ender.cod_grade_3
   LET p_estoque_trans_end.cod_grade_4      = p_estoque_lote_ender.cod_grade_4
   LET p_estoque_trans_end.cod_grade_5      = p_estoque_lote_ender.cod_grade_5
   LET p_estoque_trans_end.num_ped_ven      = p_estoque_lote_ender.num_ped_ven
   LET p_estoque_trans_end.num_seq_ped_ven  = p_estoque_lote_ender.num_seq_ped_ven
   LET p_estoque_trans_end.dat_hor_producao = p_estoque_lote_ender.dat_hor_producao
   LET p_estoque_trans_end.dat_hor_validade = p_estoque_lote_ender.dat_hor_validade
   LET p_estoque_trans_end.num_peca         = p_estoque_lote_ender.num_peca
   LET p_estoque_trans_end.num_serie        = p_estoque_lote_ender.num_serie
   LET p_estoque_trans_end.comprimento      = p_estoque_lote_ender.comprimento
   LET p_estoque_trans_end.largura          = p_estoque_lote_ender.largura
   LET p_estoque_trans_end.altura           = p_estoque_lote_ender.altura
   LET p_estoque_trans_end.diametro         = p_estoque_lote_ender.diametro
   LET p_estoque_trans_end.dat_hor_reserv_1 = p_estoque_lote_ender.dat_hor_reserv_1
   LET p_estoque_trans_end.dat_hor_reserv_2 = p_estoque_lote_ender.dat_hor_reserv_2
   LET p_estoque_trans_end.dat_hor_reserv_3 = p_estoque_lote_ender.dat_hor_reserv_3
   LET p_estoque_trans_end.qtd_reserv_1     = p_estoque_lote_ender.qtd_reserv_1
   LET p_estoque_trans_end.qtd_reserv_2     = p_estoque_lote_ender.qtd_reserv_2
   LET p_estoque_trans_end.qtd_reserv_3     = p_estoque_lote_ender.qtd_reserv_3
   LET p_estoque_trans_end.num_reserv_1     = p_estoque_lote_ender.num_reserv_1
   LET p_estoque_trans_end.num_reserv_2     = p_estoque_lote_ender.num_reserv_2
   LET p_estoque_trans_end.num_reserv_3     = p_estoque_lote_ender.num_reserv_3
   LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa
   LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item
   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog
   LET p_estoque_trans_end.cus_unit_movto_p = 0
   LET p_estoque_trans_end.cus_unit_movto_f = 0
   LET p_estoque_trans_end.cus_tot_movto_p  = 0
   LET p_estoque_trans_end.cus_tot_movto_f  = 0
   LET p_estoque_trans_end.num_volume       = 0
   LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.vlr_temperatura  = 0
   LET p_estoque_trans_end.endereco_origem  = ' '
   LET p_estoque_trans_end.tex_reservado    = " "

   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TAB ESTOQUE_TRANS_END'  
     RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0930_carrega_erros()
#-------------------------------#

   LET p_index = 1
   INITIALIZE pr_erro TO NULL
   
   DECLARE cq_erro CURSOR FOR
    SELECT *
      FROM cons_erro_885
     WHERE codempresa = p_cod_empresa
       AND datconsumo = p_datconsumo
       
   FOREACH cq_erro INTO pr_erro[p_index].*

      IF STATUS <> 0 THEN
	       EXIT FOREACH
	    END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 200 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   LET p_ind = p_index - 1
   
END FUNCTION

#-------------------------------#
FUNCTION pol0930_recupera_erros()
#-------------------------------#

 	 IF pol0930_apaga_erros() THEN
	    
	    CALL log085_transacao("BEGIN")
      FOR p_index = 1 TO p_ind

          INSERT INTO cons_erro_885
           VALUES(pr_erro[p_index].codempresa,
                  pr_erro[p_index].numsequencia,
                  pr_erro[p_index].datconsumo,
                  pr_erro[p_index].mensagem,
                  pr_erro[p_index].dat_hor)
      END FOR
      CALL log085_transacao("COMMIT")
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol0930_troca_op()
#--------------------------#

   DEFINE p_num_op LIKE ordens.num_ordem

   LET p_cod_item = p_cod_item_ord
   
   IF NOT pol0930_le_item_vdp() THEN
      RETURN FALSE
   END IF
   
   IF p_ies_chapa THEN 
      RETURN TRUE
   END IF
 
   SELECT num_docum
     INTO p_num_docum
	   FROM ordens 
	  WHERE cod_empresa = p_cod_empresa
	    AND num_ordem   = p_consu.num_ordem

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO ORDENS:NUM.DOCUM'
      RETURN FALSE
   END IF
	 
	 LET p_ies_chapa = FALSE
	 
   DECLARE cq_op_chapa CURSOR FOR
    SELECT num_ordem,
           cod_item
      FROM ordens
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_cod_item_ord
       AND num_docum    = p_num_docum
       AND ies_situa    IN ('4','5')


   FOREACH cq_op_chapa INTO p_num_op, p_cod_item
   
       IF STATUS <> 0 THEN
          LET p_msg = 'ERRO:(',STATUS, ') LENDO ORDENS:OP DA CHAPA'
          RETURN FALSE
      END IF
       
      IF NOT pol0930_le_item_vdp() THEN
         RETURN FALSE
      END IF
   
      IF p_ies_chapa THEN 
         EXIT FOREACH
      END IF
      
   END FOREACH

   IF p_ies_chapa THEN
      LET p_consu.num_ordem = p_num_op
   ELSE
      LET p_msg = 'NAO EXISTE OF DA CHAPA P/ A ORDEM:',p_consu.num_ordem
      IF NOT pol0930_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF   

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0930_le_item_vdp()
#-----------------------------#

   DEFINE p_cod_grupo_item LIKE item_vdp.cod_grupo_item

   LET p_ies_chapa = FALSE

	  SELECT cod_grupo_item
	    INTO p_cod_grupo_item
	    FROM item_vdp
	   WHERE cod_empresa = p_cod_empresa
	     AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO ITEM_VDP ', p_cod_item
      RETURN FALSE
   END IF

   SELECT cod_empresa
     FROM grupo_produto_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_grupo   = p_cod_grupo_item
      AND cod_tipo    = '2'
	  
	 IF STATUS = 0 THEN
	    LET p_ies_chapa = TRUE
   ELSE	 
      IF STATUS <> 100 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO GRUPO_PRODUTO_885'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION


#-----------------------------#
FUNCTION pol0930_deleta_lote()
#-----------------------------#

   DELETE FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
      AND qtd_saldo   <= 0

   IF STATUS <> 0 THEN      
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO TAB ESTOQUE_LOTE'  
      RETURN FALSE
   END IF   

   DELETE FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_estoque_lote_ender.num_transac
      AND qtd_saldo   <= 0

   IF STATUS <> 0 THEN      
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO TAB ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0930_update_estoque()
#--------------------------------#

   IF p_ies_situa = 'L' THEN
      UPDATE estoque
         SET qtd_liberada = qtd_liberada - p_qtd_movto,
             dat_ult_saida = getdate()
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_prod
   ELSE
      UPDATE estoque
         SET qtd_lib_excep = qtd_lib_excep - p_qtd_movto,
             dat_ult_saida = getdate()
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_prod
   END IF
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TAB ESTOQUE'  
      RETURN FALSE
   END IF   

   RETURN TRUE
   
END FUNCTION

#-----------------------#
FUNCTION pol0930_erros()
#-----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol09302") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol09302 AT 5,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   INITIALIZE p_dat_consumo TO NULL
   LET INT_FLAG = FALSE
   
   INPUT p_dat_consumo WITHOUT DEFAULTS FROM dat_consumo

      AFTER FIELD dat_consumo
         IF NOT pol0930_le_cosu_criticados() THEN
            IF p_dat_consumo IS NOT NULL THEN
               LET p_msg = 'data de consumo sem inconsistências!'
               CALL log0030_mensagem(p_msg,'exclamation') 
            ELSE
               LET p_msg = 'Não há inconsistências no consumo!'
               CALL log0030_mensagem(p_msg,'exclamation') 
            END IF
            NEXT FIELD dat_consumo
         END IF
   
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   CALL pol0930_exibe_erros()

   CLOSE WINDOW w_pol09302
   
   RETURN  TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0930_le_cosu_criticados()
#-----------------------------------#

   LET p_index = 1
   LET p_count = 0
   INITIALIZE p_incons TO NULL
   
   IF p_dat_consumo IS NOT NULL THEN

      DECLARE cq_erros1 CURSOR FOR
       SELECT DISTINCT
              a.datconsumo,
              b.coditem,
              b.numlote,
              a.mensagem
         FROM cons_erro_885 a,
              cons_papel_885 b
        WHERE a.codempresa   = p_cod_empresa
          AND a.datconsumo   = p_dat_consumo
          AND b.codempresa   = a.codempresa
          AND b.numsequencia = a.numsequencia
        UNION SELECT datconsumo, ' ', ' ',
                      mensagem
                 FROM cons_erro_885 
                WHERE codempresa   = p_cod_empresa
                  AND numsequencia = 0
         ORDER BY a.datconsumo, a.mensagem
               
      FOREACH cq_erros1 INTO 
              p_incons[p_index].datconsumo,
              p_incons[p_index].coditem,
              p_incons[p_index].numlote,
              p_incons[p_index].mensagem

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_erros1')
            RETURN FALSE
         END IF
         
         IF NOT pol0930_le_qtds() THEN
            RETURN FALSE
         END IF
         
         LET p_index = p_index + 1
         LET p_count = p_count + 1

         IF p_index > 2000 THEN
            ERROR 'Limite de Linhas Ultrapassado!'
            EXIT FOREACH
         END IF

      END FOREACH
      
   ELSE

      DECLARE cq_erros2 CURSOR FOR
       SELECT DISTINCT
              a.datconsumo,
              b.coditem,
              b.numlote,
              a.mensagem
         FROM cons_erro_885 a,
              cons_papel_885 b
        WHERE a.codempresa   = p_cod_empresa
          AND b.codempresa   = a.codempresa
          AND b.numsequencia = a.numsequencia
        UNION SELECT datconsumo, ' ', ' ', 
                      mensagem
                 FROM cons_erro_885 
                WHERE codempresa   = p_cod_empresa
                  AND numsequencia = 0
         ORDER BY a.datconsumo, a.mensagem
               
      FOREACH cq_erros2 INTO 
              p_incons[p_index].datconsumo,
              p_incons[p_index].coditem,
              p_incons[p_index].numlote,
              p_incons[p_index].mensagem

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_erros2')
            RETURN FALSE
         END IF
         
         IF NOT pol0930_le_qtds() THEN
            RETURN FALSE
         END IF

         LET p_index = p_index + 1
         LET p_count = p_count + 1
         
         IF p_index > 2000 THEN
            ERROR 'Limite de Linhas Ultrapassado!'
            EXIT FOREACH
         END IF
         
      END FOREACH
      
   END IF

   IF p_count = 0 THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol0930_le_qtds()
#-------------------------#

   SELECT SUM(qtdconsumo)
     INTO p_incons[p_index].qtdconsumo
     FROM cons_papel_885
    WHERE codempresa = p_cod_empresa
      AND coditem    = p_incons[p_index].coditem
      AND numlote    = p_incons[p_index].numlote
      AND datconsumo = p_incons[p_index].datconsumo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','Quantidade consumida')
      RETURN FALSE
   END IF
        
   SELECT SUM(qtd_saldo)
     INTO p_incons[p_index].qtdestoque
     FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_incons[p_index].coditem
      AND num_lote    = p_incons[p_index].numlote
      AND ies_situa_qtd IN ('L','E')

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','Quantidade estocada')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol0930_exibe_erros()
#-----------------------------#
  
   CALL SET_COUNT(p_index - 1)

   DISPLAY ARRAY p_incons TO s_incons.*

END FUNCTION


#------FIM DO PROGRAMA--------#

