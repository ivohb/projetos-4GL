#-------------------------------------------------------------------#
# PROGRAMA: pol1345                                                 #
# OBJETIVO: IMPORTAÇÃO DE OC DO DRUMMER                             #
# CLIENTE.: LINTER                                                  #
# DATA....: 10/05/2018                                              #
# POR.....: IVO H BARBOSA                                           #
# ALTERADO:                                                         #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

  DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
       	 p_den_empresa        LIKE empresa.den_empresa,
       	 p_user               LIKE usuario.nom_usuario,
         p_index              SMALLINT,
         s_index              SMALLINT,
         p_ind                SMALLINT,
         s_ind                SMALLINT,
         p_msg                CHAR(150),
       	 p_nom_arquivo        CHAR(100),
       	 p_count              SMALLINT,
         p_rowid              SMALLINT,
       	 p_houve_erro         SMALLINT,
         p_ies_impressao      CHAR(01),
         g_ies_ambiente       CHAR(01),
       	 p_retorno            SMALLINT,
         p_nom_tela           CHAR(200),
       	 p_status             SMALLINT,
       	 p_caminho            CHAR(100),
       	 comando              CHAR(80),
         p_versao             CHAR(18),
         sql_stmt             CHAR(500),
         where_clause         CHAR(500),
         p_ies_cons           SMALLINT,
         p_neces              SMALLINT

END GLOBALS

DEFINE p_item_man          RECORD LIKE item_man.*,
       p_ordem_sup         RECORD LIKE ordem_sup.*

DEFINE p_dat_proces        DATE,
       p_hor_proces        CHAR(08),
       p_num_oc            INTEGER,
       p_erro              CHAR(10),
       p_num_processo      CHAR(19),
       m_gerar             CHAR(01)

DEFINE m_cod_item          CHAR(30),
       m_dat_entrega       DATE,
	     m_dat_abertura_oc   DATE,
       m_qtd_planej        DECIMAL(10,3),
       m_oc_drummer        CHAR(30),
       m_num_oc            INTEGER,
       m_oc_nova           SMALLINT,
       m_dat_emissao       DATE
       
DEFINE mr_erro             ARRAY[2000] OF RECORD
       msg                 CHAR(150)
END RECORD

DEFINE m_gru_ctr_desp       LIKE item_sup.gru_ctr_desp,
       m_num_conta          LIKE item_sup.num_conta,
       m_cod_tip_despesa    LIKE item_sup.cod_tip_despesa,
       m_ies_tip_item       LIKE item.ies_tip_item,
       m_cod_progr          LIKE item_sup.cod_progr,
       m_cod_comprador      LIKE item_sup.cod_comprador,
       m_ies_tip_incid_ipi  LIKE item_sup.ies_tip_incid_ipi,
       m_cod_fiscal         LIKE item_sup.cod_fiscal,
       m_prx_num_oc         LIKE par_sup.prx_num_oc,
       m_pct_ipi            LIKE item.pct_ipi,
       m_ies_tip_incid_icms LIKE item_sup.ies_tip_incid_icms,
       m_cod_unid_med       LIKE item.cod_unid_med,
       m_qtd_lote_minimo    LIKE item_sup.qtd_lote_minimo,
       m_qtd_estoq_seg      LIKE item_sup.qtd_estoq_seg,
       p_qtd_dias           LIKE horizonte.qtd_dias_horizon,
       p_cod_horizon        LIKE item_man.cod_horizon,
       p_num_docum          LIKE ordem_sup.num_docum, 
       p_cod_fiscal_compl   LIKE item_sup_compl.cod_fiscal_compl,
       m_cod_local_estoq    LIKE item.cod_local_estoq,
       m_pct_refug          LIKE estrut_grade.pct_refug

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 60
   DEFER INTERRUPT
   
   LET p_versao = "pol1345-12.02.04  "
   CALL func002_versao_prg(p_versao)

   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
   
   LET p_msg = 'Iniciando processo manual.'
   CALL pol1345_controle() RETURNING p_status
   CALL log0030_mensagem(p_msg,'info')


END MAIN

#------------------------------#
FUNCTION pol1345_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_param3_user     CHAR(08),
          l_status          SMALLINT

   CALL pol1341_exibe_tela()

   CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,0) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param3_user

   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
   LET p_msg = 'Iniciando processo pela JOB0003.'
           
   CALL pol1345_controle() RETURNING p_status
      
   RETURN TRUE
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1345_controle()
#--------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1345") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1345a AT 10,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   WHENEVER ANY ERROR CONTINUE

   IF p_cod_empresa IS NULL THEN
      LET p_cod_empresa = '01'
   END IF
         
   IF p_user IS NULL THEN
      LET p_user = 'admlog'
   END IF
   
   LET p_num_processo = EXTEND(CURRENT, YEAR TO SECOND)
   IF NOT pol1345_ins_erro() THEN
      RETURN FALSE
   END IF

   LET p_msg = NULL   
   LET p_dat_proces = TODAY
   LET p_hor_proces = TIME
   LET p_index = 0

   CALL log085_transacao("BEGIN") 

   LOCK TABLE par_sup IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, 'bloqueando tabela PAR_SUP.',
                  'Não foi possivel abrir essa tabela em modo exclusivo.'
      CALL log085_transacao("ROLLBACK")      
      CALL pol1345_ins_erro() RETURNING p_status           
      CLOSE WINDOW w_pol1345a
      RETURN FALSE
   END IF
   
   IF pol1345_del_oc_planej() THEN
      CALL pol1345_processa() RETURNING p_status
   ELSE
      LET p_status = FALSE
   END IF
   
   IF NOT p_status THEN
      CALL log085_transacao("ROLLBACK")  
   ELSE
      CALL log085_transacao("COMMIT")
   END IF      
   
   CLOSE WINDOW w_pol1345a
   
   IF p_msg IS NULL THEN
      LET p_msg = 'Processamento efetuado com sucesso.'
   END IF
   
   CALL pol1345_ins_erro() RETURNING p_status
   
   RETURN p_status
   
END FUNCTION

#--------------------------#
FUNCTION pol1345_ins_erro()#
#--------------------------#
            
   INSERT INTO erro_critico_1345
    VALUES(p_cod_empresa,p_num_processo,p_msg)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','erro_critico_1345')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-----------------------#
FUNCTION pol1345_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------#
FUNCTION pol1345_del_oc_planej()#
#-------------------------------#

   DECLARE cq_del_empresa CURSOR FOR
    SELECT DISTINCT empresa
      FROM ordem_compra_drummer
     WHERE item IS NOT NULL
       AND qtd_planejada IS NOT NULL
       AND qtd_planejada > 0
       AND status_import = 'N'
      
    FOREACH cq_del_empresa INTO p_cod_empresa
    
       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO TABELA ordem_compra_drummer:cq_del_empresa'
          RETURN FALSE
       END IF
       
       IF NOT pol1345_exc_ordens() THEN
          RETURN FALSE
       END IF
       
   END FOREACH
   
   RETURN TRUE

END FUNCTION   
   
#----------------------------#
FUNCTION pol1345_exc_ordens()#
#----------------------------#
   
   DEFINE p_num_versao INTEGER
   
   DECLARE cq_del CURSOR FOR
    SELECT num_oc, num_versao
      FROM ordem_sup 
     WHERE cod_empresa = p_cod_empresa
       AND ies_situa_oc = 'P'
       AND ies_origem_oc = 'C'
       AND ies_versao_atual = 'S'
       AND num_docum = 'DRUMMER'
       
    FOREACH cq_del INTO p_num_oc, p_num_versao
    
       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO TABELA ORDEM_SUP:CQ_DEL'
          RETURN FALSE
       END IF
         
       DELETE FROM ordem_sup
        WHERE cod_empresa = p_cod_empresa
          AND num_oc = p_num_oc

       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'ERRO ', p_erro CLIPPED,' DELETANDO TABELA ORDEM_SUP'
          RETURN FALSE
       END IF

       DELETE FROM dest_ordem_sup
        WHERE cod_empresa = p_cod_empresa
          AND num_oc = p_num_oc
          
       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'ERRO ', p_erro CLIPPED,' DELETANDO TABELA DEST_ORDEM_SUP'
          RETURN FALSE
       END IF

       DELETE FROM sup_oc_grade
        WHERE empresa = p_cod_empresa
          AND ordem_compra = p_num_oc
          
       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'ERRO ', p_erro CLIPPED,' DELETANDO TABELA SUP_OC_GRADE'
          RETURN FALSE
       END IF

       DELETE FROM estrut_ordem_sup
        WHERE cod_empresa = p_cod_empresa
          AND num_oc = p_num_oc
          
       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'ERRO ', p_erro CLIPPED,' DELETANDO TABELA ESTRUT_ORDEM_SUP'
          RETURN FALSE
       END IF

       DELETE FROM ordem_sup_compl
        WHERE cod_empresa = p_cod_empresa
          AND num_oc = p_num_oc
          
       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'ERRO ', p_erro CLIPPED,' DELETANDO TABELA ORDEM_SUP_COMPL'
          RETURN FALSE
       END IF

       DELETE FROM ordem_sup_audit
        WHERE cod_empresa = p_cod_empresa
          AND num_oc = p_num_oc
          
       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'ERRO ', p_erro CLIPPED,' DELETANDO TABELA ORDEM_SUP_AUDIT'
          RETURN FALSE
       END IF

       DELETE FROM prog_ordem_sup
        WHERE cod_empresa = p_cod_empresa
          AND num_oc = p_num_oc
          
       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'ERRO ', p_erro CLIPPED,' DELETANDO TABELA PROG_ORDEM_SUP'
          RETURN FALSE
       END IF

   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1345_processa()#
#--------------------------#

   DECLARE cq_proc_empresa CURSOR FOR
    SELECT DISTINCT empresa
      FROM ordem_compra_drummer
     WHERE item IS NOT NULL
       AND qtd_planejada IS NOT NULL
       AND qtd_planejada > 0
       AND status_import = 'N'
      
    FOREACH cq_proc_empresa INTO p_cod_empresa
    
       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO TABELA ordem_compra_drummer:cq_proc_empresa'
          RETURN FALSE
       END IF
       
       IF NOT pol1345_le_ordens() THEN
          RETURN FALSE
       END IF
       
   END FOREACH
   
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1345_le_ordens()#
#---------------------------#
   
   DEFINE l_par17        CHAR(01),
          l_ctr_estoq    CHAR(01)
          
   DECLARE cq_ins CURSOR WITH HOLD FOR
    SELECT item, dat_entrega_prev, dat_abertura_oc,
           qtd_planejada, num_oc_drummer, num_oc_logix,
           dat_emissao
      FROM ordem_compra_drummer
     WHERE empresa = p_cod_empresa
       AND item IS NOT NULL
       AND qtd_planejada IS NOT NULL
       AND qtd_planejada > 0
       AND status_import = 'N'
       
   FOREACH cq_ins INTO m_cod_item, m_dat_entrega, m_dat_abertura_oc,
       m_qtd_planej, m_oc_drummer, m_num_oc,  m_dat_emissao 
    
       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO TABELA ORDEM_COMPRA_DRUMMER'
          RETURN FALSE
       END IF
              
       IF m_num_oc IS NULL OR m_num_oc = 0 THEN          
       ELSE
          IF NOT pol1345_atu_oc() THEN
             RETURN FALSE
          END IF
          IF NOT m_gerar THEN
             CONTINUE FOREACH
          END IF
       END IF
       
       SELECT parametros[17] 
         INTO l_par17
         FROM item_parametro          
        WHERE cod_empresa = p_cod_empresa 
          AND cod_item = m_cod_item

       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = '	ITEM:',m_cod_item CLIPPED, 
                      ' ERRO ', p_erro CLIPPED,' LENDO TABELA ITEM_PARAMETRO'
          RETURN FALSE
       END IF
       
       IF l_par17 = 'S' THEN
          CONTINUE FOREACH
       END IF

       SELECT ies_ctr_estoque
         INTO l_ctr_estoq
         FROM item          
        WHERE cod_empresa = p_cod_empresa 
          AND cod_item = m_cod_item
          AND ies_situacao =  'A'

       IF STATUS = 100 THEN
          LET p_msg = 'Produto inativo ou inexistente no Logix.'
          IF NOT pol1345_gra_mensagem() THEN
             RETURN FALSE
          END IF
          CONTINUE FOREACH
       END IF

       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = '	ITEM:',m_cod_item CLIPPED, 
                      ' ERRO ', p_erro CLIPPED,' LENDO TABELA ITEM'
          RETURN FALSE
       END IF
       
       IF l_ctr_estoq = 'N' THEN
          LET p_msg = 'Produto não é um item de estoque.'
          IF NOT pol1345_gra_mensagem() THEN
             RETURN FALSE
          END IF
          CONTINUE FOREACH
       END IF
                                           
       LET p_erro = m_oc_drummer
       LET m_dat_emissao = TODAY
                        
       IF NOT pol1345_grava_oc() THEN
          RETURN FALSE
       END IF
              
   END FOREACH
    
   RETURN TRUE
 
END FUNCTION

#------------------------#
FUNCTION pol1345_atu_oc()#
#------------------------#

   DEFINE l_ies_situa_oc   CHAR(01),
          l_num_pedido     INTEGER,
          l_num_versao     INTEGER
   
   LET m_gerar = FALSE
   
   SELECT ies_situa_oc,
          num_pedido,
          num_versao
     INTO l_ies_situa_oc,
          l_num_pedido,
          l_num_versao
     FROM ordem_sup 
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = m_num_oc
      AND ies_origem_oc = 'C'
      AND ies_versao_atual = 'S'
      AND num_docum = 'DRUMMER'

   IF STATUS = 100 THEN
      LET m_gerar = TRUE
      RETURN TRUE
   END IF
      
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO TABELA ORDEM_SUP'
      RETURN FALSE
   END IF

   IF l_num_pedido > 0 THEN
      LET p_msg = 'OC já está agregada a um pedido. Portando, não pode ser alterada.'
      IF NOT pol1345_gra_mensagem() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
   
   UPDATE ordem_sup 
      SET qtd_solic = m_qtd_planej,
          dat_entrega_prev = m_dat_entrega
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = m_num_oc
      AND ies_origem_oc = 'C'
      AND ies_versao_atual = 'S'
      AND num_docum = 'DRUMMER'
      
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' ATUALIZANDO TABELA ORDEM_SUP'
      RETURN FALSE
   END IF
      
   UPDATE prog_ordem_sup 
      SET qtd_solic = m_qtd_planej,
          dat_entrega_prev = m_dat_entrega
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = m_num_oc
      AND num_versao = l_num_versao
      
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' ATUALIZANDO TABELA PROG_ORDEM_SUP'
      RETURN FALSE
   END IF

   LET p_msg = 'Ordem de compra ALTERADA com sucesso.'
   
   IF NOT pol1345_upd_drummer() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1345_grava_oc()#
#--------------------------#

   IF NOT pol1345_le_item_sup() THEN
      RETURN FALSE
   END IF

   IF NOT pol1345_le_par_compl() THEN
      RETURN FALSE
   END IF 
   
   IF NOT pol1345_prx_num_oc() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1345_insere_estrut_oc() THEN
      RETURN FALSE
   END IF

   IF m_pct_refug IS NULL THEN
      LET m_pct_refug = 0
   END IF
   
   LET m_qtd_planej = m_qtd_planej + m_pct_refug
   
   IF NOT pol1345_insere_oc() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1345_insere_prog_oc() THEN
      RETURN FALSE
   END IF

   IF NOT pol1345_insere_dest_oc() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1345_ins_ordem_sup_compl() THEN
      RETURN FALSE
   END IF

   IF NOT pol1345_ins_orden_sup_audit() THEN
      RETURN FALSE
   END IF

   #IF NOT pol1345_ins_sup_oc_grade() THEN
   #  RETURN FALSE
   #END IF
   
   LET m_num_oc = p_ordem_sup.num_oc 
   LET p_msg = 'Ordem de compra INCLUIDA com sucesso.'
   
   IF NOT pol1345_upd_drummer() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol1345_le_item_sup()
#-----------------------------#
   
   SELECT cod_comprador,
          cod_progr,
          gru_ctr_desp,
          num_conta,
          cod_tip_despesa,
          ies_tip_incid_icms,
          ies_tip_incid_ipi,
          cod_fiscal,
          qtd_lote_minimo,
          qtd_estoq_seg
     INTO m_cod_comprador,
          m_cod_progr,
          m_gru_ctr_desp,
          m_num_conta,
          m_cod_tip_despesa,
          m_ies_tip_incid_icms,
          m_ies_tip_incid_ipi,
          m_cod_fiscal,
          m_qtd_lote_minimo,
          m_qtd_estoq_seg
     FROM item_sup
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = m_cod_item

   IF STATUS = 100 THEN
      LET p_msg = 'ITEM ',m_cod_item, ' NAO CADASTRADO NA TABELA ITEM_SUP.'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO DADOS DA TABELA ITEM_SUP'
         RETURN FALSE
      END IF
   END IF

   IF m_num_conta IS NULL THEN
      LET m_num_conta = 0
   END IF

   IF m_gru_ctr_desp IS NULL THEN 
      LET m_gru_ctr_desp = 0
   END IF

   SELECT cod_fiscal_compl
     INTO p_cod_fiscal_compl
     FROM item_sup_compl
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = m_cod_item

   IF STATUS <> 0 THEN
      LET p_cod_fiscal_compl = NULL
   END IF

   SELECT cod_local_estoq
     INTO m_cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = m_cod_item

   IF STATUS <> 0 THEN
      LET m_cod_local_estoq = NULL
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1345_le_par_compl()
#------------------------------#

   SELECT pct_ipi, 
          cod_unid_med
     INTO m_pct_ipi, 
          m_cod_unid_med
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = m_cod_item

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO DADOS DA TABELA ITEM'
      RETURN FALSE
   END IF

{
   SELECT cod_horizon
     INTO p_cod_horizon
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = m_cod_item

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO DADOS DA TABELA ITEM_MAN'
      RETURN FALSE
   END IF
   
   SELECT qtd_dias_horizon
     INTO p_qtd_dias
     FROM horizonte
    WHERE cod_empresa = p_cod_empresa
      AND cod_horizon = p_cod_horizon

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO DADOS DA TABELA HORIZONTE'
      RETURN FALSE
   END IF
}
   RETURN TRUE
   
END FUNCTION

#----------------------------#
 FUNCTION pol1345_prx_num_oc()
#----------------------------#

   SELECT prx_num_oc
     INTO m_prx_num_oc
     FROM par_sup
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO DADOS NA TABELA PAR_SUP'
      RETURN FALSE
   END IF

   IF m_prx_num_oc IS NULL THEN
      LET m_prx_num_oc = 0
   END IF
   
   UPDATE par_sup
      SET prx_num_oc = prx_num_oc + 1
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' ATUALIZANDO DADOS NA TABELA PAR_SUP'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION pol1345_insere_oc()
#---------------------------#
   
   DEFINE l_cod_progr   LIKE programador.cod_progr
   
   LET p_ordem_sup.cod_empresa        = p_cod_empresa
   LET p_ordem_sup.num_oc             = m_prx_num_oc
   LET p_ordem_sup.num_versao         = 1
   LET p_ordem_sup.dat_ref_cotacao    = NULL
   LET p_ordem_sup.num_versao_pedido  = 0
   LET p_ordem_sup.ies_versao_atual   = 'S'
   LET p_ordem_sup.cod_item           = m_cod_item
   LET p_ordem_sup.num_pedido         = 0
   LET p_ordem_sup.ies_situa_oc       = 'P'
   LET p_ordem_sup.ies_origem_oc      = 'C'
   LET p_ordem_sup.ies_item_estoq     = 'S' 
   LET p_ordem_sup.ies_imobilizado    = 'N'
   LET p_ordem_sup.cod_unid_med       = m_cod_unid_med
   LET p_ordem_sup.dat_emis           = m_dat_emissao
   LET p_ordem_sup.qtd_solic          = m_qtd_planej
   LET p_ordem_sup.dat_entrega_prev   = m_dat_entrega
   LET p_ordem_sup.fat_conver_unid    = 1
   LET p_ordem_sup.qtd_recebida       = 0
   LET p_ordem_sup.pre_unit_oc        = 0
   LET p_ordem_sup.pct_ipi            = m_pct_ipi
   LET p_ordem_sup.cod_moeda          = 0
   LET p_ordem_sup.cod_fornecedor     = ' '
   LET p_ordem_sup.cnd_pgto           = 0
   LET p_ordem_sup.cod_mod_embar      = 0
   LET p_ordem_sup.num_docum          = 'DRUMMER'
   LET p_ordem_sup.gru_ctr_desp       = m_gru_ctr_desp
   LET p_ordem_sup.cod_secao_receb    = m_cod_local_estoq
   LET p_ordem_sup.cod_progr          = m_cod_progr
   LET p_ordem_sup.cod_comprador      = m_cod_comprador
   LET p_ordem_sup.pct_aceite_dif     = 0
   LET p_ordem_sup.ies_tip_entrega    = 'D'
   LET p_ordem_sup.ies_liquida_oc     = '2'
   LET p_ordem_sup.dat_abertura_oc    = m_dat_abertura_oc
   LET p_ordem_sup.num_oc_origem      = m_prx_num_oc
   LET p_ordem_sup.qtd_origem         = m_qtd_planej
   LET p_ordem_sup.ies_tip_incid_ipi  = m_ies_tip_incid_ipi
   LET p_ordem_sup.ies_tip_incid_icms = m_ies_tip_incid_icms
   LET p_ordem_sup.cod_fiscal         = m_cod_fiscal
   LET p_ordem_sup.cod_tip_despesa    = m_cod_tip_despesa
   LET p_ordem_sup.ies_insp_recebto   = '4'
   LET p_ordem_sup.dat_origem         = p_ordem_sup.dat_entrega_prev

   INSERT INTO ordem_sup VALUES (p_ordem_sup.*)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO DADOS NA TABELA ORDEM_SUP'
      RETURN FALSE 
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION pol1345_insere_estrut_oc()
#-----------------------------------#


   DEFINE l_pct_refug          LIKE estrut_grade.pct_refug,
          p_cod_item_compon    LIKE estrutura.cod_item_compon,
          p_qtd_necessaria     LIKE estrutura.qtd_necessaria,
		      p_estrut_ordem_sup   RECORD LIKE estrut_ordem_sup.*

   
   LET m_pct_refug = null
   
   DELETE FROM t_estrut_912
   
   DECLARE cq_temp CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           pct_refug
      FROM estrut_grade
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = m_cod_item
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
            (dat_validade_ini IS NULL AND dat_validade_fim >= today) OR
            (dat_validade_fim IS NULL AND dat_validade_ini <= today )OR
            (today BETWEEN dat_validade_ini AND dat_validade_fim))
     ORDER BY parametros
       
   FOREACH cq_temp INTO 
           p_cod_item_compon,
           p_qtd_necessaria,
           l_pct_refug

	   IF STATUS <> 0 THEN
		  LET p_erro = STATUS
		  LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO DADOS NA TABELA ESTRUT_GRADE'
		  RETURN FALSE 
	   END IF
     
     IF m_pct_refug IS NULL THEN
        LET m_pct_refug = l_pct_refug
     END IF
     
	   LET p_estrut_ordem_sup.cod_empresa      = p_cod_empresa
	   LET p_estrut_ordem_sup.num_oc           = m_prx_num_oc
	   LET p_estrut_ordem_sup.cod_item_comp    = p_cod_item_compon
	   LET p_estrut_ordem_sup.qtd_necessaria   = p_qtd_necessaria + l_pct_refug
	   LET p_estrut_ordem_sup.cus_unit_compon  = NULL
	   
	   INSERT INTO estrut_ordem_sup VALUES (p_estrut_ordem_sup.*)

	   IF STATUS <> 0 THEN
		  LET p_erro = STATUS
		  LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO DADOS NA TABELA ESTRUT_ORDEM_SUP'
		  RETURN FALSE 
	   END IF
           
   END FOREACH
      
   RETURN TRUE

END FUNCTION
#--------------------------------#
 FUNCTION pol1345_insere_prog_oc()
#--------------------------------#

   DEFINE p_prog_ordem_sup    RECORD LIKE prog_ordem_sup.*

   LET p_prog_ordem_sup.cod_empresa      = p_ordem_sup.cod_empresa
   LET p_prog_ordem_sup.num_oc           = p_ordem_sup.num_oc
   LET p_prog_ordem_sup.num_versao       = p_ordem_sup.num_versao
   LET p_prog_ordem_sup.num_prog_entrega = 1
   LET p_prog_ordem_sup.ies_situa_prog   = 'P'
   LET p_prog_ordem_sup.dat_entrega_prev = p_ordem_sup.dat_entrega_prev
   LET p_prog_ordem_sup.qtd_solic        = p_ordem_sup.qtd_solic
   LET p_prog_ordem_sup.qtd_recebida     = p_ordem_sup.qtd_recebida
   LET p_prog_ordem_sup.dat_origem       = p_ordem_sup.dat_entrega_prev
   LET p_prog_ordem_sup.dat_palpite      = NULL

   INSERT INTO prog_ordem_sup VALUES (p_prog_ordem_sup.*)

   IF sqlca.sqlcode <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO DADOS NA TABELA PROG_ORDEM_SUP'
      RETURN FALSE 
   END IF

   RETURN  TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1345_insere_dest_oc()
#--------------------------------#

   DEFINE p_dest_ordem_sup    RECORD LIKE dest_ordem_sup.*

   LET p_dest_ordem_sup.cod_empresa        = p_ordem_sup.cod_empresa
   LET p_dest_ordem_sup.num_oc             = p_ordem_sup.num_oc
   LET p_dest_ordem_sup.cod_area_negocio   = 0
   LET p_dest_ordem_sup.cod_lin_negocio    = 0
   LET p_dest_ordem_sup.pct_particip_comp  = 100
   LET p_dest_ordem_sup.cod_secao_receb    = p_ordem_sup.cod_secao_receb
   LET p_dest_ordem_sup.num_conta_deb_desp = m_num_conta
   LET p_dest_ordem_sup.qtd_particip_comp  = p_ordem_sup.qtd_solic
   LET p_dest_ordem_sup.num_docum          = p_ordem_sup.num_docum
   LET p_dest_ordem_sup.num_transac        = 0

   INSERT INTO dest_ordem_sup VALUES (p_dest_ordem_sup.*)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO DADOS NA TABELA DEST_ORDEM_SUP'
      RETURN FALSE 
   END IF

   RETURN  TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1345_ins_ordem_sup_compl()#
#-------------------------------------#

   DEFINE p_ordem_sup_compl RECORD LIKE ordem_sup_compl.*
   
   LET p_ordem_sup_compl.cod_empresa        = p_ordem_sup.cod_empresa #   char(2)        
   LET p_ordem_sup_compl.num_oc             = p_ordem_sup.num_oc      #   decimal(9,0)   
   LET p_ordem_sup_compl.val_item_moeda     = 0                       #   decimal(17,6)  
   LET p_ordem_sup_compl.num_lista          = NULL                    #   decimal(9,0)   
   LET p_ordem_sup_compl.nom_fabricante     = NULL                    #   char(30)       
   LET p_ordem_sup_compl.cod_ref_item       = NULL                    #   char(25)       
   LET p_ordem_sup_compl.nom_apelido        = NULL                    #   char(20)       
   LET p_ordem_sup_compl.cod_subregiao      = NULL                    #   decimal(5,0)   
   LET p_ordem_sup_compl.ins_estadual       = NULL                    #   char(16)       
   LET p_ordem_sup_compl.ies_tip_contrat_mp = NULL                    #   char(1)        
   LET p_ordem_sup_compl.cod_praca          = NULL                    #   decimal(5,0)   
   LET p_ordem_sup_compl.cod_fiscal_compl   = 0                       #   integer        
   LET p_ordem_sup_compl.possui_remito      = NULL                    #   char(1)        
   LET p_ordem_sup_compl.tip_compra         = NULL                    #   char(1)        
   LET p_ordem_sup_compl.oc_contrato        = NULL                    #   decimal(9,0)   
   LET p_ordem_sup_compl.val_tot_contrato   = NULL                    #   decimal(17,20 

   IF p_cod_fiscal_compl IS NULL THEN
      LET p_ordem_sup_compl.cod_fiscal_compl = 0
   ELSE
      LET p_ordem_sup_compl.cod_fiscal_compl = p_cod_fiscal_compl
   END IF

   IF sup0290_sistema_argentino() THEN
      LET p_ordem_sup_compl.possui_remito = "S"
      LET p_ordem_sup_compl.tip_compra    = "S"
   END IF

   INSERT INTO ordem_sup_compl VALUES (p_ordem_sup_compl.*)
   
   IF sqlca.sqlcode <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO DADOS NA TABELA ORDEM_SUP_COMPL'
      RETURN FALSE 
   END IF

   RETURN  TRUE

END FUNCTION

#--------------------------------------#
 FUNCTION pol1345_ins_orden_sup_audit()#
#--------------------------------------#

   DEFINE p_ordem_sup_audit RECORD LIKE ordem_sup_audit.*
   
   LET p_ordem_sup_audit.cod_empresa    = p_ordem_sup.cod_empresa
   LET p_ordem_sup_audit.num_oc         = p_ordem_sup.num_oc
   LET p_ordem_sup_audit.ies_tipo_audit = 1
   LET p_ordem_sup_audit.nom_usuario    = p_user  
   LET p_ordem_sup_audit.dat_proces     = p_dat_proces
   LET p_ordem_sup_audit.hor_operac     = p_hor_proces

   INSERT INTO ordem_sup_audit VALUES (p_ordem_sup_audit.*)

   IF sqlca.sqlcode <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO DADOS NA TABELA ORDEM_SUP_AUDIT'
      RETURN FALSE 
   END IF

   RETURN  TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION pol1345_ins_sup_oc_grade()#
#-----------------------------------#

   DEFINE l_tem_grade    DEC(2,0)
   
   LET l_tem_grade = 0

    SELECT count(*)
	INTO  l_tem_grade 
	FROM  item_ctr_grade
	WHERE cod_empresa=p_cod_empresa
	AND   cod_item=m_cod_item
	AND     ((num_grade_1 IS NOT NULL) OR
 	(num_grade_2 IS NOT NULL) OR
 	(num_grade_3 IS NOT NULL) OR
 	(num_grade_4 IS NOT NULL) OR
 	(num_grade_5 IS NOT NULL) OR
      (ies_endereco <> 'N') OR
     (ies_volume   <> 'N') OR
      (ies_dat_producao <> 'N') OR
      (ies_dat_validade <> 'N') OR
      (ies_comprimento <> 'N') OR
      (ies_largura <> 'N') OR
      (ies_altura <> 'N') OR
      (ies_diametro <> 'N') OR
      (reservado_1 <> 'N') OR
      (reservado_2 <> 'N'))

   IF sqlca.sqlcode <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO DADOS NA TABELA ITEM_CTR_GRADE'
      RETURN FALSE 
   END IF
   
   IF  l_tem_grade >  0   THEN 
	   INSERT INTO sup_oc_grade (
		  empresa, ordem_compra, seq_tabulacao, 
		  qtd_solicitada, qtd_receb, pre_uni_oc, 
		  endereco, num_volume, grade_1, grade_2, 
		  grade_3, grade_4, grade_5, dat_hor_producao, 
		  dat_hor_valid, peca, serie_peca, comprimento, 
		  largura, altura, diametro, dat_hor_reserva_1, 
		  dat_hor_reserva_2, dat_hor_reserva_3, qtd_reservada_1, 
		  qtd_reservada_2, qtd_reservada_3, num_reserva_1, num_reserva_2, num_reserva_3, texto_reservado) 
		  
		  VALUES(p_cod_empresa,
				 p_ordem_sup.num_oc,1,
				 p_ordem_sup.qtd_solic,0,0,' ',0,' ',' ',' ',' ',' ',
				 '1900-01-01 00:00:00',
				 '1900-01-01 00:00:00',
				 ' ',' ',0,0,0,0,
				 '1900-01-01 00:00:00',
				 '1900-01-01 00:00:00',
				 '1900-01-01 00:00:00',
				 0,0,0,0,0,0,' ')
				 
	   IF sqlca.sqlcode <> 0 THEN
		  LET p_erro = STATUS
		  LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO DADOS NA TABELA SUP_OC_GRADE'
		  RETURN FALSE 
	   END IF
   END IF

   RETURN  TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1345_upd_drummer()#
#-----------------------------#

   UPDATE ordem_compra_drummer
      SET num_oc_logix = m_num_oc,
          dat_emissao = m_dat_emissao,
          status_import = 'S',
          erro_import = p_msg
    WHERE empresa = p_cod_empresa
      AND num_oc_drummer = m_oc_drummer

   IF sqlca.sqlcode <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' ATUALIZANDO A TABELA ORDEM_COMPRA_DRUMMER'
      RETURN FALSE 
   END IF

   RETURN  TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1345_gra_mensagem()#
#------------------------------#

   UPDATE ordem_compra_drummer
      SET erro_import = p_msg,
          status_import = 'E'
    WHERE empresa = p_cod_empresa
      AND num_oc_drummer = m_oc_drummer

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' ATUALIZANDO A TABELA ORDEM_COMPRA_DRUMMER'
      RETURN FALSE 
   END IF

   RETURN  TRUE

END FUNCTION
