#-----------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO LOGIX E TRIM PAPEL                               #
# PROGRAMA: pol0654                                                     #
# OBJETIVO: ALTERAR STATUS DA OP DE 3 P/ 4                              #
# AUTOR...: POLO INFORMATICA - IVO                                      #
# DATA....: 31/07/2007                                                  #
#-----------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_ies_cons           SMALLINT,
          p_rowid              INTEGER,
          p_count              SMALLINT,
          p_status             SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          p_caminho            CHAR(080),
          p_men                CHAR(80)


   DEFINE p_cod_item           LIKE item.cod_item,
          p_cod_compon         LIKE item.cod_item,
          p_op_chapa           LIKE ordens.num_ordem,
          p_ies_baixa_comp     LIKE ordens.ies_baixa_comp,
          p_num_docum          LIKE ordens.num_docum,
          p_ies_ctr_estoque    LIKE item.ies_ctr_estoque,
          p_ies_sofre_baixa    LIKE item_man.ies_sofre_baixa,
          p_num_ordem          LIKE ordens.num_ordem,
          p_qtd_planej         LIKE ordens.qtd_planej,
          p_tot_neces          LIKE estoque_lote.qtd_saldo,
          p_num_lote           LIKE estoque_lote.num_lote,
          p_qtd_saldo          LIKE estoque_lote.qtd_saldo,
          p_qtd_saldo_ant      LIKE estoque_lote.qtd_saldo,
          p_qtd_saldo_dep      LIKE estoque_lote.qtd_saldo,
          p_cod_local_estoq    LIKE item.cod_local_estoq,
          p_cod_local_prod     LIKE ordens.cod_local_prod,
          p_qtd_reser          LIKE man_prior_consumo.qtd_reservada,
          p_num_lote_prod      LIKE estoque_lote.num_lote,
          p_qtd_necessaria     LIKE necessidades.qtd_necessaria,
          p_novo_saldo         LIKE estoque_lote.qtd_saldo,
          p_num_conta          LIKE item_sup.num_conta,
          p_cod_estoque_ac     LIKE par_pcp.cod_estoque_ac,
          p_num_neces          LIKE necessidades.num_neces,
          p_qtd_transferir     LIKE man_prior_consumo.qtd_reservada,
          m_num_transac_orig   LIKE estoque_trans_end.num_transac,
          p_numsequencia       INTEGER, #LIKE ord_liberada_885.numsequencia,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa
          

   DEFINE mr_estoque_trans     RECORD LIKE estoque_trans.*,
          mr_estoque_trans_end RECORD LIKE estoque_trans_end.*,
          p_audit_logix        RECORD LIKE audit_logix.*,
          p_trans_pendentes    RECORD LIKE trans_pendentes.*,
          p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*
      
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT 
   LET p_versao = "pol0654-05.10.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0654.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
        NEXT KEY control-f,
        PREVIOUS KEY control-b,
        DELETE KEY control-e
   
    CALL log001_acessa_usuario("VDP","LIC_LIB")     
       RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol0654_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0654_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0654") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0654 AT 6,20 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol0655_le_empresas() THEN
      RETURN
   END IF

   CALL pol0654_libera_ordens()

   CLOSE WINDOW w_pol0654

END FUNCTION

#-----------------------------#
FUNCTION pol0655_le_empresas()
#-----------------------------#

   SELECT cod_emp_oficial
     INTO p_cod_emp_ofic
     FROM empresas_885
    WHERE cod_emp_gerencial = p_cod_empresa

   IF STATUS = 0 THEN
      LET p_cod_emp_ger = p_cod_empresa
   ELSE   
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_gerencial
           INTO p_cod_emp_ger
           FROM empresas_885
          WHERE cod_emp_oficial = p_cod_empresa
         IF STATUS = 0 THEN
            LET p_cod_emp_ofic = p_cod_empresa
         ELSE
            IF STATUS <> 100 THEN
               CALL log003_err_sql("LENDO","EMPRESA_885")       
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION


#-----------------------------#
FUNCTION pol0654_libera_ordens()
#-----------------------------#

   DECLARE cq_prod CURSOR WITH HOLD FOR
    SELECT a.NumSequencia,
           a.NumOrdem,
           b.cod_item,
           b.qtd_planej,
           b.cod_local_prod,
           b.ies_baixa_comp,
           b.num_docum
      FROM ord_liberada_885 a,
           ordens b
     WHERE a.CodEmpresa     = p_cod_empresa
       AND a.Statusregistro = '0'
       AND b.cod_empresa    = a.CodEmpresa
       AND b.num_ordem      = a.NumOrdem
       AND b.ies_situa      = '3'

    IF STATUS <> 0 THEN
       CALL log003_err_sql("LEITURA","ordens/ord_liberada_885")
       RETURN 
    END IF

   FOREACH cq_prod INTO 
           p_numsequencia,
           p_num_ordem,
           p_cod_item,
           p_qtd_planej,
           p_cod_local_prod,
           p_ies_baixa_comp,
           p_num_docum

      DISPLAY p_num_ordem TO num_ordem
      
      CALL log085_transacao("BEGIN")
 
          
      IF p_ies_baixa_comp = '1' THEN       
         IF NOT pol0654_transf_mp() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN
         END IF 
      END IF

      IF NOT pol0654_atualiza_tabs() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN
      END IF
      
      CALL log085_transacao("COMMIT")
   
   END FOREACH

END FUNCTION

#-------------------------------#
FUNCTION pol0654_atualiza_tabs()
#-------------------------------#

   UPDATE ordens
      SET ies_situa = '4'
    WHERE cod_empresa IN (p_cod_emp_ger,p_cod_emp_ofic)
      AND num_ordem   = p_num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE","ORDENS")
      RETURN FALSE
   END IF

   UPDATE necessidades
      SET ies_situa = '4'
    WHERE cod_empresa IN (p_cod_emp_ger,p_cod_emp_ofic)
      AND num_ordem   = p_num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE","NECESSIDADES")
      RETURN FALSE
   END IF

   UPDATE ord_liberada_885
      SET statusregistro = '1'
    WHERE CodEmpresa   = p_cod_empresa
      AND numsequencia = p_numsequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE","ORD_LIBERADA_885")
      RETURN FALSE
   END IF
    
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0654_transf_mp()
#---------------------------#

   DECLARE cq_neces CURSOR WITH HOLD FOR
    SELECT cod_item,
           num_neces,
           qtd_necessaria
      FROM necessidades
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_num_ordem

    IF STATUS <> 0 THEN
       CALL log003_err_sql("LEITURA","necessidades")
       RETURN FALSE
    END IF

   FOREACH cq_neces INTO 
           p_cod_compon,
           p_num_neces,
           p_qtd_necessaria
   
      SELECT cod_local_estoq,
             ies_ctr_estoque,
             ies_sofre_baixa
        INTO p_cod_local_estoq,
             p_ies_ctr_estoque,
             p_ies_sofre_baixa
        FROM item a,
             item_man b
       WHERE a.cod_empresa = p_cod_empresa
         AND a.cod_item    = p_cod_compon
         AND b.cod_empresa = a.cod_empresa
         AND b.cod_item    = a.cod_item
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","item/item_man")
         RETURN FALSE
      END IF
      
      IF p_ies_ctr_estoque = 'N' OR p_ies_sofre_baixa = 'N' THEN
         CONTINUE FOREACH
      END IF

      LET p_tot_neces = p_qtd_necessaria * p_qtd_planej

      SELECT SUM(qtd_saldo)
	      INTO p_qtd_saldo_ant
	      FROM estoque_lote
	     WHERE cod_empresa   = p_cod_empresa
	       AND cod_item      = p_cod_compon
	       AND ies_situa_qtd = 'L'

       IF STATUS <> 0 THEN
          CALL log003_err_sql("LEITURA","estoque_lote")
          RETURN FALSE
       END IF

   	  IF p_qtd_saldo_ant IS NULL THEN
	       LET p_qtd_saldo_ant = 0
	    END IF

      IF NOT pol0654_movimenta_estoque() THEN
         RETURN FALSE
      END IF
      
      SELECT SUM(qtd_saldo)
	      INTO p_qtd_saldo_dep
	      FROM estoque_lote
	     WHERE cod_empresa   = p_cod_empresa
	       AND cod_item      = p_cod_compon
	       AND ies_situa_qtd = "L"

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","estoque_lote")
         RETURN FALSE
      END IF

	    IF p_qtd_saldo_dep IS NULL THEN
	       LET p_qtd_saldo_dep = 0
	    END IF 
	 
      IF p_qtd_saldo_dep <> p_qtd_saldo_ant THEN
         DISPLAY p_cod_compon AT 9,20
         DISPLAY p_qtd_saldo_ant AT 10,20
         DISPLAY p_qtd_saldo_dep AT 11,20
         CALL log0030_mensagem("ERRO NA MOVIMENTAÇÃO DE ESTOQUE","exclamation")
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION  

#----------------------------------#
FUNCTION pol0654_movimenta_estoque()
#----------------------------------#
    
   DECLARE cq_lot CURSOR WITH HOLD FOR
    SELECT *
      FROM estoque_lote_ender
     WHERE cod_empresa   = p_cod_empresa
       AND cod_item      = p_cod_compon
       AND cod_local     = p_cod_local_estoq
       AND ies_situa_qtd = 'L'
       AND qtd_saldo     > 0
     ORDER BY dat_hor_producao, 
              num_lote

    IF STATUS <> 0 THEN
       CALL log003_err_sql("LEITURA","estoque_lote_ender")
       RETURN FALSE
    END IF

   FOREACH cq_lot INTO p_estoque_lote_ender.*

      LET p_num_lote   = p_estoque_lote_ender.num_lote
      LET p_qtd_saldo  = p_estoque_lote_ender.qtd_saldo
      LET p_novo_saldo = p_qtd_saldo
      
      IF p_num_lote IS NOT NULL THEN
         SELECT SUM(qtd_reservada - qtd_atendida)
           INTO p_qtd_reser
           FROM estoque_loc_reser
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_compon
            AND cod_local   = p_cod_local_estoq
            AND num_lote    = p_num_lote
      ELSE
         SELECT SUM(qtd_reservada - qtd_atendida)
           INTO p_qtd_reser
           FROM estoque_loc_reser
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_compon
            AND cod_local   = p_cod_local_estoq
            AND num_lote IS NULL
      END IF      

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","estoque_loc_reser")
         RETURN FALSE
      END IF
      
      IF p_qtd_reser IS NULL OR p_qtd_reser < 0 THEN
         LET p_qtd_reser = 0
      END IF
       
      IF p_qtd_saldo > p_qtd_reser THEN
         LET p_qtd_saldo = p_qtd_saldo - p_qtd_reser
      ELSE
         CONTINUE FOREACH
      END IF

      IF p_qtd_saldo <= p_tot_neces THEN
         LET p_qtd_transferir = p_qtd_saldo
         LET p_tot_neces  = p_tot_neces - p_qtd_saldo
      ELSE
         LET p_qtd_transferir = p_tot_neces
         LET p_tot_neces  = 0
      END IF
      
      LET p_novo_saldo = p_novo_saldo - p_qtd_transferir
      
      IF p_novo_saldo = 0 THEN
         IF NOT pol0654_deleta_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol0654_atualiza_lote() THEN
            RETURN FALSE
         END IF
      END IF
        
      IF NOT pol0654_atualiza_local_prod() THEN
         RETURN FALSE
      END IF
      
      IF p_tot_neces = 0 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   IF p_tot_neces > 0 THEN
      IF NOT pol0654_grava_trans_penden() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------------#      
FUNCTION pol0654_grava_trans_penden()
#------------------------------------#      
      
   LET p_trans_pendentes.cod_empresa = p_cod_empresa
   LET p_trans_pendentes.cod_item  = p_cod_compon
   LET p_trans_pendentes.num_ordem = p_num_ordem
   LET p_trans_pendentes.num_neces = p_num_neces
   LET p_trans_pendentes.dat_movto = TODAY
   LET p_trans_pendentes.qtd_movto = p_tot_neces
   
   INSERT INTO trans_pendentes 
      VALUES (p_trans_pendentes.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERÇÃO","TRANS_PENDENTES")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
 FUNCTION pol0654_deleta_lote()
#------------------------------#
  
   IF p_num_lote IS NULL THEN
      DELETE FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_compon
         AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = 'L'
         AND num_lote IS NULL
   ELSE
      DELETE FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_compon
         AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = 'L'
         AND num_lote      = p_num_lote
   END IF
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELEÇÃO","ESTOQUE_LOTE")
      RETURN FALSE
   END IF
   
   IF p_num_lote IS NULL THEN
      DELETE FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_compon
         AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = 'L'
         AND num_lote IS NULL
   ELSE
      DELETE FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_compon
         AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = 'L'
         AND num_lote      = p_num_lote
   END IF
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELEÇÃO","ESTOQUE_LOTE_ENDER")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION        

#------------------------------#
 FUNCTION pol0654_atualiza_lote()
#------------------------------#
   
   IF p_num_lote IS NULL THEN
      UPDATE estoque_lote
         SET qtd_saldo = p_novo_saldo
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_compon
         AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = 'L'
         AND num_lote IS NULL
   ELSE
      UPDATE estoque_lote
         SET qtd_saldo = p_novo_saldo
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_compon
         AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = 'L'
         AND num_lote      = p_num_lote
   END IF

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELEÇÃO","ESTOQUE_LOTE")
      RETURN FALSE
   END IF
   
   IF p_num_lote IS NULL THEN
      UPDATE estoque_lote_ender
         SET qtd_saldo = p_novo_saldo
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_compon
         AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = 'L'
         AND num_lote IS NULL
   ELSE
      UPDATE estoque_lote_ender
         SET qtd_saldo = p_novo_saldo
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_compon
         AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = 'L'
         AND num_lote      = p_num_lote
   END IF

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELEÇÃO","ESTOQUE_LOTE_ENDER")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION        

#--------------------------------------#
FUNCTION  pol0654_atualiza_local_prod()
#--------------------------------------#

   IF p_num_lote IS NOT NULL THEN
      SELECT rowid
        INTO p_rowid
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_compon
         AND cod_local     = p_cod_local_prod
         AND ies_situa_qtd = 'L'
         AND num_lote      = p_num_lote
   ELSE
      SELECT rowid
        INTO p_rowid
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_compon
         AND cod_local     = p_cod_local_prod
         AND ies_situa_qtd = 'L'
         AND num_lote IS NULL
   END IF   
   
   IF STATUS = 100 THEN
      IF NOT pol0654_insere_local_prod() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 0 THEN
         IF NOT pol0654_altera_local_prod() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql("LEITURA","ESTOQUE_LOTE_ENDER")
         RETURN FALSE
      END IF
   END IF
   
   IF NOT pol0654_insere_est_trans() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION  pol0654_insere_local_prod()
#-----------------------------------#

      LET p_estoque_lote_ender.cod_local   = p_cod_local_prod
      LET p_estoque_lote_ender.qtd_saldo   = p_qtd_transferir
      LET p_estoque_lote_ender.num_transac = 0
      
      INSERT INTO estoque_lote_ender
      VALUES (p_estoque_lote_ender.*)

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","ESTOQUE_LOTE_ENDER")
         RETURN FALSE
      END IF
            
      INSERT INTO estoque_lote
          VALUES (p_cod_empresa,
                  p_cod_compon,
                  p_cod_local_prod,
                  p_num_lote,
                  'L',
                  p_qtd_transferir,
                  0)
                  
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","ESTOQUE_LOTE")
         RETURN FALSE
      END IF
      
      RETURN TRUE
      
END FUNCTION

#-----------------------------------#
FUNCTION  pol0654_altera_local_prod()
#-----------------------------------#

   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo + p_qtd_transferir
    WHERE rowid = p_rowid
    
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("ALTERAÇÃO","ESTOQUE_LOTE_ENDER")
      RETURN FALSE
   END IF
   
   LET p_rowid = 0
   
   IF p_num_lote IS NULL THEN
      SELECT rowid
        INTO p_rowid
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_compon
         AND cod_local     = p_cod_local_prod
         AND ies_situa_qtd = 'L'
         AND num_lote IS NULL
   ELSE
      SELECT rowid
        INTO p_rowid
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_compon
         AND cod_local     = p_cod_local_prod
         AND ies_situa_qtd = 'L'
         AND num_lote      = p_num_lote
   END IF   

   IF STATUS = 100 THEN
      LET p_men = 'ITEM: ',p_cod_compon
      LET p_men = p_men CLIPPED, " - ESTOQUE_LOTE_ENDER E ESTOQUE_LOTE INCOMPATÍVEIS"
      CALL log0030_mensagem(p_men,"exclamation")
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","ESTOQUE_LOTE")
         RETURN FALSE
      END IF
   END IF

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + p_qtd_transferir
    WHERE rowid = p_rowid
    
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("ALTERAÇÃO","ESTOQUE_LOTE")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol0654_insere_est_trans()
#----------------------------------#
   
   INITIALIZE mr_estoque_trans.*, p_cod_estoque_ac TO NULL
      
   SELECT cod_estoque_ac
     INTO p_cod_estoque_ac
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      LET p_cod_estoque_ac = 0
   END IF

   SELECT num_conta
     INTO p_num_conta
     FROM item_sup                          
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_compon
      
   IF sqlca.sqlcode <> 0 THEN
      LET p_num_conta = 0
   END IF

   LET mr_estoque_trans.cod_empresa        = p_cod_empresa
   LET mr_estoque_trans.num_transac        = 0
   LET mr_estoque_trans.cod_item           = p_cod_compon
   LET mr_estoque_trans.dat_movto          = TODAY
   LET mr_estoque_trans.dat_ref_moeda_fort = TODAY
   LET mr_estoque_trans.dat_proces         = TODAY
   LET mr_estoque_trans.hor_operac         = TIME
   LET mr_estoque_trans.ies_tip_movto      = "N"
   LET mr_estoque_trans.cod_operacao       = p_cod_estoque_ac
   LET mr_estoque_trans.num_prog           = "pol0654"
   LET mr_estoque_trans.num_docum          = p_num_ordem
   LET mr_estoque_trans.num_seq            = NULL
   LET mr_estoque_trans.cus_unit_movto_p   = 0
   LET mr_estoque_trans.cus_tot_movto_p    = 0
   LET mr_estoque_trans.cus_unit_movto_f   = 0
   LET mr_estoque_trans.cus_tot_movto_f    = 0
   LET mr_estoque_trans.num_conta          = p_num_conta
   LET mr_estoque_trans.num_secao_requis   = NULL
   LET mr_estoque_trans.nom_usuario        = p_user
   LET mr_estoque_trans.qtd_movto          = p_qtd_transferir
   LET mr_estoque_trans.ies_sit_est_orig   = "L"
   LET mr_estoque_trans.ies_sit_est_dest   = "L"
   LET mr_estoque_trans.cod_local_est_orig = p_cod_local_estoq
   LET mr_estoque_trans.cod_local_est_dest = p_cod_local_prod
   LET mr_estoque_trans.num_lote_orig      = p_num_lote
   LET mr_estoque_trans.num_lote_dest      = p_num_lote

   INSERT INTO estoque_trans VALUES (mr_estoque_trans.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","ESTOQUE_TRANS")
      RETURN FALSE
   END IF

   LET m_num_transac_orig = SQLCA.SQLERRD[2]

   IF NOT pol0654_ins_est_trans_end() THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#------------------------------------#
 FUNCTION pol0654_ins_est_trans_end()
#------------------------------------#

   INITIALIZE mr_estoque_trans_end.*   TO NULL

   LET mr_estoque_trans_end.cod_empresa      = mr_estoque_trans.cod_empresa
   LET mr_estoque_trans_end.num_transac      = m_num_transac_orig
   LET mr_estoque_trans_end.endereco         =  " "
   LET mr_estoque_trans_end.num_volume       = 0
   LET mr_estoque_trans_end.qtd_movto        = mr_estoque_trans.qtd_movto
   LET mr_estoque_trans_end.cod_grade_1      = " "
   LET mr_estoque_trans_end.cod_grade_2      = " "
   LET mr_estoque_trans_end.cod_grade_3      = " "
   LET mr_estoque_trans_end.cod_grade_4      = " "
   LET mr_estoque_trans_end.cod_grade_5      = " "
   LET mr_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.vlr_temperatura  = 0
   LET mr_estoque_trans_end.endereco_origem  = " "
   LET mr_estoque_trans_end.num_ped_ven      = 0
   LET mr_estoque_trans_end.num_seq_ped_ven  = 0
   LET mr_estoque_trans_end.dat_hor_producao = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.dat_hor_validade = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.num_peca         = " "
   LET mr_estoque_trans_end.num_serie        = " "
   LET mr_estoque_trans_end.comprimento      = 0
   LET mr_estoque_trans_end.largura          = 0
   LET mr_estoque_trans_end.altura           = 0
   LET mr_estoque_trans_end.diametro         = 0
   LET mr_estoque_trans_end.dat_hor_reserv_1 = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.dat_hor_reserv_2 = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.dat_hor_reserv_3 = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.qtd_reserv_1     = 0
   LET mr_estoque_trans_end.qtd_reserv_2     = 0
   LET mr_estoque_trans_end.qtd_reserv_3     = 0
   LET mr_estoque_trans_end.num_reserv_1     = 0
   LET mr_estoque_trans_end.num_reserv_2     = 0
   LET mr_estoque_trans_end.num_reserv_3     = 0
   LET mr_estoque_trans_end.tex_reservado    = " "
   LET mr_estoque_trans_end.cus_unit_movto_p = 0
   LET mr_estoque_trans_end.cus_unit_movto_f = 0
   LET mr_estoque_trans_end.cus_tot_movto_p  = 0
   LET mr_estoque_trans_end.cus_tot_movto_f  = 0
   LET mr_estoque_trans_end.cod_item         = mr_estoque_trans.cod_item
   LET mr_estoque_trans_end.dat_movto        = mr_estoque_trans.dat_movto
   LET mr_estoque_trans_end.cod_operacao     = mr_estoque_trans.cod_operacao
   LET mr_estoque_trans_end.dat_movto        = mr_estoque_trans.dat_movto
   LET mr_estoque_trans_end.cod_operacao     = mr_estoque_trans.cod_operacao
   LET mr_estoque_trans_end.ies_tip_movto    = mr_estoque_trans.ies_tip_movto
   LET mr_estoque_trans_end.num_prog         = "pol0654"

   INSERT INTO estoque_trans_end VALUES (mr_estoque_trans_end.*)

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("INCLUSAO","ESTOQUE_TRANS_END")
      RETURN FALSE
   END IF

  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, m_num_transac_orig, p_user, CURRENT,'pol0654')

  IF SQLCA.SQLCODE <> 0 THEN 
     CALL log003_err_sql("INSERÇÃO","estoque_auditoria")
     RETURN FALSE
  END IF

  RETURN TRUE
   
END FUNCTION



#------------------------FIM DO PROGRAMA----------------------------#

