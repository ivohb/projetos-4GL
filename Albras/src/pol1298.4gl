#-------------------------------------------------------------------#
# PROGRAMA: pol1298                                                 #
# OBJETIVO: IMPORTA��O DE OC DO DRUMMER                             #
# CLIENTE.: ALBRAS                                                  #
# DATA....: 03/09/2015                                              #
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
       p_erro              CHAR(10)

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
   
   LET p_versao = "pol1298-10.02.27  "
   CALL func002_versao_prg(p_versao)

   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'; LET p_user = 'admlog'; LET p_status = 0
   
   IF p_status = 0 THEN
      CALL pol1298_menu()
   END IF

END MAIN

#-----------------------#
 FUNCTION pol1298_menu()#
#-----------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1298") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1298 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
   COMMAND "Processar" "Gera ordens enviadas pelo drummer"
	    LET p_msg = 'As ordens planejadas ser�o eliminadas\n',
	                'e novas ordens enviadas pelo Drummer\n',
	                'ser�o criadas. Deseja continuar ?' 
	    IF log0040_confirm(20,25,p_msg) THEN
         CALL pol1298_controle() RETURNING p_status
         IF NOT p_status THEN
            ERROR 'Opera��o cancelada'
         ELSE
            ERROR 'Opera��o efetuada com sucesso'
         END IF
         NEXT OPTION 'Fim'
      ELSE
         ERROR 'Opra��o cancelada.'
      END IF
	  
	COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol1298_sobre() 
    COMMAND KEY ("!")
       PROMPT "Digite o comando : " FOR comando
       RUN comando
       PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
       DATABASE logix
       LET INT_FLAG = 0
    COMMAND "Fim"       "Retorna ao Menu Anterior"
       EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1298

END FUNCTION

#--------------------------#
 FUNCTION pol1298_controle()
#--------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1298a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1298a AT 10,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   WHENEVER ANY ERROR CONTINUE

   LET p_dat_proces = TODAY
   LET p_hor_proces = TIME
   LET p_index = 0

   CALL log085_transacao("BEGIN") 

   LOCK TABLE par_sup IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, 'bloqueando tabela PAR_SUP.\n',
                  'N�o foi possivel abrir essa tabela\n em modo exclusivo.'
      CALL log085_transacao("ROLLBACK")                  
      CALL log0030_mensagem(p_msg,'info')
      CLOSE WINDOW w_pol1298a
      RETURN FALSE
   END IF
   
   IF pol1298_del_oc_planej() THEN
      CALL pol1298_processa() RETURNING p_status
   ELSE
      LET p_status = FALSE
   END IF
   
   IF NOT p_status THEN
      CALL log085_transacao("ROLLBACK")  
      CALL log0030_mensagem(p_msg,'info')
   ELSE
      CALL log085_transacao("COMMIT")
   END IF      
   
   CLOSE WINDOW w_pol1298a
   
   RETURN p_status
   
END FUNCTION

#-----------------------#
FUNCTION pol1298_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------#
FUNCTION pol1298_del_oc_planej()#
#-------------------------------#
   
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
          #AND num_versao = p_num_versao

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
          #AND num_versao = p_num_versao
          
       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'ERRO ', p_erro CLIPPED,' DELETANDO TABELA PROG_ORDEM_SUP'
          RETURN FALSE
       END IF

   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1298_processa()#
#--------------------------#
   
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
       AND (status_import IS NULL OR status_import = ' ')
       
   FOREACH cq_ins INTO m_cod_item, m_dat_entrega,m_dat_abertura_oc,
       m_qtd_planej, m_oc_drummer, m_num_oc,  m_dat_emissao
    
       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO TABELA ORDEM_COMPRA_DRUMMER'
          RETURN FALSE
       END IF
              
       IF m_num_oc IS NULL OR m_num_oc = 0 THEN          
       ELSE
          SELECT COUNT(dat_emis)
            INTO p_count
            FROM ordem_sup 
           WHERE cod_empresa = p_cod_empresa
             AND num_oc = m_num_oc
             AND ies_versao_atual = 'S'
          IF STATUS <> 0 THEN
             LET p_erro = STATUS
             LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO TABELA ORDEM_SUP'
             RETURN FALSE
          END IF
          IF p_count > 0 THEN
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

       IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = '	ITEM:',m_cod_item CLIPPED, 
                      ' ERRO ', p_erro CLIPPED,' LENDO TABELA ITEM'
          RETURN FALSE
       END IF
       
       IF l_ctr_estoq = 'N' THEN
          CONTINUE FOREACH
       END IF
                             
       IF m_qtd_planej <= 0 OR m_qtd_planej IS NULL OR m_qtd_planej = ' ' THEN
          CONTINUE FOREACH
       END IF
              
       LET p_erro = m_oc_drummer
       
       SELECT cod_item
         FROM item
        WHERE cod_empresa = p_cod_empresa
          AND cod_item = m_cod_item

       IF STATUS = 100 THEN
          LET p_msg = 'OC ', p_erro CLIPPED, 
               '. ITEM ', m_cod_item CLIPPED, ' ENVIADO PELO DRUMMER N�O EXISTE'
          RETURN FALSE
       ELSE
          IF STATUS <> 0 THEN
             LET p_erro = STATUS
             LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO TABELA ITEM'
             RETURN FALSE
          END IF
       END IF

       IF m_dat_emissao IS NULL THEN
          LET m_dat_emissao = TODAY
       END IF
                        
       IF NOT pol1298_grava_oc() THEN
          RETURN FALSE
       END IF
              
   END FOREACH
    
   RETURN TRUE
 
END FUNCTION

#--------------------------#
FUNCTION pol1298_grava_oc()#
#--------------------------#

   IF NOT pol1298_le_item_sup() THEN
      RETURN FALSE
   END IF

   IF NOT pol0923_le_par_compl() THEN
      RETURN FALSE
   END IF 
   
   IF m_num_oc IS NULL OR m_num_oc <= 0 THEN
      IF NOT pol0923_prx_num_oc() THEN
         RETURN FALSE
      END IF
      LET m_dat_emissao = TODAY
   ELSE
      LET m_prx_num_oc = m_num_oc
   END IF
   
   IF NOT pol0923_insere_estrut_oc() THEN
      RETURN FALSE
   END IF

   IF m_pct_refug IS NULL THEN
      LET m_pct_refug = 0
   END IF
   
   LET m_qtd_planej = m_qtd_planej + m_pct_refug
   
   IF NOT pol0923_insere_oc() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0923_insere_prog_oc() THEN
      RETURN FALSE
   END IF

   IF NOT pol0923_insere_dest_oc() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0923_ins_ordem_sup_compl() THEN
      RETURN FALSE
   END IF

   IF NOT pol0923_ins_orden_sup_audit() THEN
      RETURN FALSE
   END IF

   IF NOT pol0923_ins_sup_oc_grade() THEN
      RETURN FALSE
   END IF

   IF NOT pol0923_upd_drummer() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol1298_le_item_sup()
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
FUNCTION pol0923_le_par_compl()
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
 FUNCTION pol0923_prx_num_oc()
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
 FUNCTION pol0923_insere_oc()
#---------------------------#
   
   DEFINE l_cod_progr   LIKE programador.cod_progr
   
   {SELECT cod_progr INTO l_cod_progr   #m�rcio pediu para tirar.
     FROM programador
    WHERE cod_empresa = p_cod_empresa
      AND login       = p_user
   
   IF STATUS = 0 THEN
      LET m_cod_progr = l_cod_progr
   END IF   }

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

#--------------------------------#
 FUNCTION pol0923_insere_estrut_oc()
#--------------------------------#


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
         CALL log003_err_sql('Lendo','cq_temp')
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
 FUNCTION pol0923_insere_prog_oc()
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
 FUNCTION pol0923_insere_dest_oc()
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
FUNCTION pol0923_ins_ordem_sup_compl()#
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
 FUNCTION pol0923_ins_orden_sup_audit()#
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
 FUNCTION pol0923_ins_sup_oc_grade()#
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
FUNCTION pol0923_upd_drummer()#
#-----------------------------#

   UPDATE ordem_compra_drummer
      SET num_oc_logix = p_ordem_sup.num_oc,
          dat_emissao = m_dat_emissao,
          status_import = 'X'
    WHERE empresa = p_cod_empresa
      AND num_oc_drummer = m_oc_drummer

   IF sqlca.sqlcode <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' ATUALIZANDO A TABELA ORDEM_COMPRA_DRUMMER'
      RETURN FALSE 
   END IF

   RETURN  TRUE

END FUNCTION

