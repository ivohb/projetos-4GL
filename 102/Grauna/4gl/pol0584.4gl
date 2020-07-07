#---------------------------------------------------------------------------------#
# SISTEMA.: VENDAS DISTRIBUICAO DE PRODUTOS                                       #
# PROGRAMA: pol0584                                                               #
# OBJETIVO: ROMANEIO DA GRAUNA
# AUTOR...: LOGOCENTER ABC  - IVO                                                 # 
# DATA....: 26/01/2007                                                            #
#05/01/10(Ivo) em função da colocação do cod_empresa na tab nat_oper_bene_1040    #
#15/01/10(Ivo) madunça do nome da tabela nat_oper_bene_1040 p/ operacao_bene_1040 #
#---------------------------------------------------------------------------------#

DATABASE logix

GLOBALS

  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_den_empresa       LIKE empresa.den_empresa,
         p_user              LIKE usuario.nom_usuario,
         l_num_lote          LIKE ordem_montag_mest.num_lote_om,
         l_num_om            LIKE ordem_montag_mest.num_om,
         p_qtd_acumulada     LIKE estrutura.qtd_necessaria,
         p_seq_tabulacao     LIKE sup_item_terc_end.seq_tabulacao,
         p_ies_sit_pedido    LIKE pedidos.ies_sit_pedido,
         p_cod_prod          LIKE item.cod_item,
         p_cod_item_compon   LIKE item.cod_item,
         p_cod_item_altern   LIKE item.cod_item,
         p_qtd_necessaria    LIKE estrutura.qtd_necessaria,
         p_tot_necessaria    LIKE estrutura.qtd_necessaria,
         p_tex_observ        LIKE fit_terc_ret.tex_observ,
         p_cod_pai_imediato    LIKE item.cod_item,
         p_pre_unit          LIKE ped_itens.pre_unit,
         p_cod_cnd_pgto      LIKE cond_pgto.cod_cnd_pgto,
         p_qtd_mat_prima     LIKE estrutura.qtd_necessaria,
         p_cod_cliente       LIKE clientes.cod_cliente,
         p_num_pedido        LIKE pedidos.num_pedido,
         p_den_item_reduz    LIKE item.den_item_reduz,
         p_cod_local_estoq   LIKE item.cod_local_estoq,
         p_prz_entrega       LIKE ped_itens.prz_entrega,
         p_qtd_reservada     LIKE ordem_montag_item.qtd_reservada,
         p_num_lote_om       LIKE ordem_montag_lote.num_lote_om,
         p_qtd_reser_lot     LIKE estoque_lote.qtd_saldo,
         p_qtd_estoque       LIKE estoque_lote.qtd_saldo,
         p_qtd_saldo         LIKE estoque_lote.qtd_saldo,
         p_qtd_reservar      LIKE estoque_lote.qtd_saldo,
         p_qtd_estoq_reser   LIKE estoque_lote.qtd_saldo,
         p_tot_reser         LIKE estoque_lote.qtd_saldo,
         p_qtd_devolvida     LIKE ordem_montag_tran.qtd_devolvida,
         p_den_embal         LIKE embalagem.den_embal,
         p_den_item          LIKE item.den_item,
         p_ctr_estoque       LIKE item.ies_ctr_estoque,
         p_ctr_lote          LIKE item.ies_ctr_lote,
         p_qtd_sel_item      LIKE estoque.qtd_reservada,
         p_cod_item_pai      LIKE item.cod_item,
         p_qtd_asel_lot      LIKE estoque.qtd_reservada,
         p_qtd_gravar        LIKE item_de_terc.qtd_tot_recebida,
         p_val_remessa       LIKE item_de_terc.val_remessa,
         p_qtd_tot_recebida  LIKE item_de_terc.qtd_tot_recebida,
         p_ies_especie_nf    LIKE item_de_terc.ies_especie_nf,
         p_cod_nat_oper      LIKE ordem_montag_tran.cod_nat_oper,
         p_qtd_tot_devolvida LIKE item_de_terc.qtd_tot_devolvida,
         p_endereco          LIKE estoque_lote_ender.endereco,
         p_comprimento       LIKE estoque_lote_ender.comprimento,
         p_largura           LIKE estoque_lote_ender.largura,
         p_altura            LIKE estoque_lote_ender.altura,
         p_diametro          LIKE estoque_lote_ender.diametro,
         p_num_transac       LIKE estoque_lote_ender.num_transac,
         p_dat_hor_producao  LIKE estoque_lote_ender.dat_hor_producao,
         m_cod_unid_med        LIKE item.cod_unid_med,
         m_cod_uni_feder       LIKE cidades.cod_uni_feder,     
         m_tex_hist_1_1        LIKE fiscal_hist.tex_hist_1,     
         m_tex_hist_2_1        LIKE fiscal_hist.tex_hist_1,     
         m_tex_hist_3_1        LIKE fiscal_hist.tex_hist_1,     
         m_tex_hist_4_1        LIKE fiscal_hist.tex_hist_1,     
         m_tex_hist_1_2        LIKE fiscal_hist.tex_hist_1,     
         m_tex_hist_2_2        LIKE fiscal_hist.tex_hist_1,     
         m_tex_hist_3_2        LIKE fiscal_hist.tex_hist_1,     
         m_tex_hist_4_2        LIKE fiscal_hist.tex_hist_1,
         m_cod_hist_1          LIKE fiscal_hist.cod_hist,     
         m_cod_hist_2          LIKE fiscal_hist.cod_hist,
         p_cod_hist_1          LIKE fiscal_hist.cod_hist,     
         p_cod_hist_2          LIKE fiscal_hist.cod_hist,
         m_pes_unit            LIKE item.pes_unit,
         m_cod_nat_oper        LIKE nat_operacao.cod_nat_oper,
         m_cod_cla_fisc        LIKE item.cod_cla_fisc,
         m_den_item            LIKE item.den_item,     
         m_val_liq_item        LIKE nf_item.val_liq_item,
         p_val_mat             LIKE nf_item.val_liq_item,
         p_val_tot_mat         LIKE nf_item.val_liq_item,
         m_val_base_item       LIKE nf_item.val_liq_item,
         p_val_gravado         LIKE nf_item.val_liq_item,
         m_val_tot_nff         LIKE nf_item.val_liq_item,
         m_val_base            LIKE nf_item.val_liq_item,
         p_val_base_icm        LIKE nf_item.val_liq_item,
         m_val_tot_liq         LIKE nf_item.val_liq_item,
         m_val_tot_base        LIKE nf_item.val_liq_item,
         m_val_tot_icm         LIKE nf_item_fiscal.val_icm,
         m_val_icm             LIKE nf_item_fiscal.val_icm,
         m_pct_icm             LIKE aviso_rec.pct_icms_item_d,
         m_val_tot_ipi         LIKE nf_item_fiscal.val_ipi,
         m_val_ipi             LIKE nf_item_fiscal.val_ipi,
         m_ies_tip_incid_ipi   LIKE item_sup.ies_tip_incid_ipi,
         m_ies_tip_incid_icms  LIKE item_sup.ies_tip_incid_icms,
         m_pct_ipi             LIKE item.pct_ipi,
         m_qtd_item            LIKE wfat_item.qtd_item,
         p_sdo_pedido          LIKE ped_itens.qtd_pecas_solic,
         p_sdo_mat_pri         LIKE item_de_terc.qtd_tot_recebida,
         p_num_item          SMALLINT,
         p_processo          CHAR(01),
         p_ies_tributa_ipi   CHAR(01), 
         p_tip_peca          CHAR(01), 
         l_num_reserva       INTEGER,
         p_num_trans         INTEGER, 
         p_gravou            SMALLINT,
         p_tem_altern        SMALLINT,
         p_om                SMALLINT,
         p_sl                SMALLINT,
         l_ind               SMALLINT,
         p_index             SMALLINT,
         s_index             SMALLINT,
         p_lote              CHAR(15),
         p_serie             CHAR(15),
         m_num_solicit       INTEGER,
         p_exibiu_tela       SMALLINT,
         p_cancelou          SMALLINT,
         p_men               CHAR(80),
         p_ies_bene          SMALLINT,
         p_ies_oclinha       SMALLINT,
         p_dig_ped           SMALLINT,
         p_dig_ocl           SMALLINT,
         p_dig_lote          SMALLINT,
         sql_stmt            CHAR(900),
         p_status            SMALLINT,
         p_ies_impressao     CHAR(001),
         comando             CHAR(080),
         p_comando           CHAR(080),
         p_nom_arquivo       CHAR(100),
         p_versao            CHAR(018),
         p_nom_tela          CHAR(080),
         p_nom_help          CHAR(200),
         g_ies_ambiente      CHAR(001),
         p_caminho           CHAR(080),
         p_comprime          CHAR(001),
         p_descomprime       CHAR(001),
         p_ind               SMALLINT,
         p_ind2              SMALLINT,
         p_count             SMALLINT,
         p_qtd_romaneio      DECIMAL(10,3),
         p_qtd_linha         SMALLINT,
         p_itens_array       SMALLINT,
         p_qtd_itens         SMALLINT,
         p_erro              SMALLINT,
         p_tela_exibida      SMALLINT,
         p_grava             CHAR(001),
         p_num_lote          CHAR(015),
         p_r                 CHAR(001),
         p_ies_lista         SMALLINT,
         p_count             SMALLINT,
         pa_curr             SMALLINT,
         sc_curr             SMALLINT,
         la_curr             SMALLINT,
         lc_curr             SMALLINT,
         p_i                 SMALLINT,
         m_informou          SMALLINT,
         p_difer             DECIMAL(17,7),
         p_qtd_sobra         DECIMAL(17,7),
         p_msg               CHAR(600)
                   
   DEFINE mr_tela            RECORD
         cod_empresa         LIKE empresa.cod_empresa,
         num_pedido          LIKE pedidos.num_pedido,
         oc_linha            CHAR(15),
         num_lote            LIKE ordem_montag_lote.num_lote_om,
         cod_transpor        LIKE ordem_montag_lote.cod_transpor,
         nom_transpor        LIKE clientes.nom_cliente,
         num_placa           LIKE ordem_montag_lote.num_placa,
         entrega_ate         LIKE ped_itens.prz_entrega
   END RECORD

   DEFINE p_item_de_terc        RECORD 
          num_nf                LIKE item_de_terc.num_nf,
          ser_nf                LIKE item_de_terc.ser_nf,
          ssr_nf                LIKE item_de_terc.ssr_nf,
          num_sequencia         LIKE item_de_terc.num_sequencia,
          dat_emis_nf           LIKE item_de_terc.dat_emis_nf,
          qtd_tot_recebida      LIKE item_de_terc.qtd_tot_recebida,
          qtd_tot_devolvida     LIKE item_de_terc.qtd_tot_devolvida
   END RECORD

   DEFINE ma_tela    ARRAY[1000] OF RECORD
         num_sequencia          LIKE ped_itens.num_sequencia,
         cod_item               LIKE item.cod_item,
         qtd_saldo              LIKE ped_itens.qtd_pecas_solic,
         qtd_reservada          LIKE ped_itens.qtd_pecas_solic,
         qtd_estoque            LIKE ped_itens.qtd_pecas_solic,
         reser_rej              LIKE ped_itens.qtd_pecas_solic,
         estoq_rej              LIKE ped_itens.qtd_pecas_solic
   END RECORD

   DEFINE ma_estoq   ARRAY[1000] OF RECORD
          qtd_estoque           LIKE ped_itens.qtd_pecas_solic
   END RECORD
   
   DEFINE ma_item   ARRAY[1000] OF RECORD
          ctr_estoque           LIKE item.ies_ctr_estoque,
          ctr_lote              LIKE item.ies_ctr_lote,
          gru_ctr_estoq         LIKE item.gru_ctr_estoq,
          cod_lin_prod          LIKE item.cod_lin_prod
   END RECORD

   DEFINE pr_pedidos     ARRAY[200] OF RECORD
          num_pedido     LIKE pedidos.num_pedido,
          ies_sit_pedido LIKE pedidos.ies_sit_pedido,
          cod_cliente    LIKE pedidos.cod_cliente,
          cod_item       LIKE item.cod_item,
          den_item_reduz LIKE item.den_item_reduz,
          qtd_saldo      LIKE ped_itens.qtd_pecas_solic
   END RECORD
          
   DEFINE ma_tela2   ARRAY[1000] OF RECORD
      num_transac               LIKE estoque_lote_ender.num_transac,
      endereco                  LIKE estoque_lote_ender.endereco,
      num_lote                  LIKE estoque_lote_ender.num_lote,
      qtd_reservada             LIKE estoque.qtd_reservada,
      qtd_saldo                 LIKE estoque_lote_ender.qtd_saldo
   END RECORD

      
   DEFINE mr_ordem_montag_mest  RECORD LIKE ordem_montag_mest.*,
          mr_ordem_montag_item  RECORD LIKE ordem_montag_item.*,
          mr_ordem_montag_grade RECORD LIKE ordem_montag_grade.*,
          mr_estoque_loc_reser  RECORD LIKE estoque_loc_reser.*,
          mr_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          mr_estoque_lote       RECORD LIKE estoque_lote.*,
          mr_pedidos            RECORD LIKE pedidos.*,
          p_parametros_1040     RECORD LIKE parametros_1040.*,
          p_ordem_montag_tran   RECORD LIKE ordem_montag_tran.*,
          mr_fiscal_par         RECORD LIKE fiscal_par.*,
          p_fit_terc_ret        RECORD LIKE fit_terc_ret.*
          
                   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT
   LET p_versao = "pol0584-05.10.48"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0584.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
        NEXT KEY control-f,
        PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol0584_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol0584_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0584") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0584 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
  
   SELECT *
     INTO p_parametros_1040.*
     FROM parametros_1040
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","P_PARAMETROS_1040")    
      RETURN
   END IF
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros necessários"
         HELP 001
         MESSAGE ""
         IF pol0584_informa_par() THEN
            ERROR 'Parâmetros informados com sucesso !!!'
            NEXT OPTION 'Processar'
         ELSE
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND "Processar" "Processa a geração da OM/SL"
         HELP 002
         MESSAGE ""
         IF m_informou THEN
            CALL pol0584_processar() RETURNING p_status
            CALL log0030_mensagem(p_men,"information")
         ELSE
            ERROR 'Informe os parâmetros previamente !!!'
            NEXT OPTION 'Informar'
         END IF
      COMMAND "Sobre" "Exibe a versão do programa"
         CALL pol0584_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 003
         MESSAGE ""
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol0584
   
END FUNCTION

#-----------------------#
FUNCTION pol0584_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 05.10 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#----------------------------#
FUNCTION pol0584_informa_par()
#----------------------------#

   IF NOT pol0584_cria_tabela_temporaria() THEN
      RETURN FALSE
   END IF
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE mr_tela.*, ma_tela TO NULL

   LET p_dig_ped = FALSE   
   LET p_dig_ocl = FALSE
   LET mr_tela.cod_empresa = p_cod_empresa

   INPUT BY NAME mr_tela.* WITHOUT DEFAULTS

      BEFORE FIELD num_pedido     
         IF p_dig_ocl THEN
            NEXT FIELD oc_linha
         END IF
         
      AFTER FIELD num_pedido     
         IF mr_tela.num_pedido IS NOT NULL THEN
            IF NOT pol0584_verifica_pedido() THEN
               NEXT FIELD num_pedido
            ELSE
               LET p_dig_ped = TRUE
            END IF
         ELSE
            LET p_dig_ped = FALSE
         END IF

      BEFORE FIELD oc_linha
         IF p_dig_ped THEN
            IF FGL_LASTKEY() = FGL_KEYVAL("UP") OR
               FGL_LASTKEY() = FGL_KEYVAL("LEFT")THEN
               NEXT FIELD num_pedido
            ELSE
               NEXT FIELD num_lote
            END IF
         END IF
      
      AFTER FIELD oc_linha
         IF mr_tela.oc_linha IS NULL THEN
            ERROR "Campo c/ preenchimento obrigatório !!!"
            NEXT FIELD oc_linha
         END IF
  
         LET p_index = 1
         LET p_count = 0
         
         DECLARE cq_ped CURSOR FOR
          SELECT a.num_pedido,
                 a.ies_sit_pedido,
                 a.cod_cliente,
                 b.cod_item,
                 c.den_item_reduz,
                 b.qtd_pecas_solic  - 
                 b.qtd_pecas_atend  - 
                 b.qtd_pecas_cancel - 
                 b.qtd_pecas_reserv - 
                 b.qtd_pecas_romaneio
            FROM pedidos a, 
                 ped_itens b,
                 item c
           WHERE a.cod_empresa    = p_cod_empresa
             AND a.num_pedido_cli = mr_tela.oc_linha
             AND b.cod_empresa    = a.cod_empresa
             AND b.num_pedido     = a.num_pedido
             AND c.cod_empresa    = a.cod_empresa
             AND c.cod_item       = b.cod_item
  
         FOREACH cq_ped INTO pr_pedidos[p_index].*
            LET p_index = p_index + 1
            LET p_count = p_count + 1
         END FOREACH
         
         IF p_count = 0 THEN
            ERROR 'Não há pedidos c/ essa oc-linha'
            NEXT FIELD oc_linha
         END IF

         IF p_count > 1 THEN
            IF NOT pol0584_escolhe_pedido() THEN
               ERROR 'OC-LINHA Descartada!'
               NEXT FIELD oc_linha
            END IF
         ELSE
            LET p_index = 1
         END IF
         
         LET mr_tela.num_pedido = pr_pedidos[p_index].num_pedido
         LET p_cod_cliente      = pr_pedidos[p_index].cod_cliente
         DISPLAY mr_tela.num_pedido TO num_pedido
         
{         SELECT cod_cliente
           FROM cli_c_oclinha_1040
          WHERE cod_cliente = p_cod_cliente
          
         IF STATUS <> 0 THEN
            ERROR "Cliente do pedido não utiliza oc-linha !!!"
            NEXT FIELD oc_linha
         END IF
}         
         IF pr_pedidos[p_index].qtd_saldo <= 0 THEN
            ERROR "Pedido sem saldo a faturar !!!"
            NEXT FIELD oc_linha
         END IF
         
         IF NOT pol0584_verifica_pedido() THEN
            NEXT FIELD oc_linha
         END IF
         
         LET p_dig_ocl = TRUE

      AFTER FIELD num_lote
      
         IF LENGTH(mr_tela.num_lote) = 0 THEN
            LET p_dig_lote = FALSE
            CALL pol0584_le_lote()
         ELSE
            LET p_dig_lote = TRUE
            SELECT cod_empresa
              FROM ordem_montag_lote
             WHERE cod_empresa = p_cod_empresa
               AND num_lote_om = mr_tela.num_lote

            IF SQLCA.SQLCODE <> 0 THEN
               ERROR "Lote Inexistente"
               NEXT FIELD num_lote
            END IF
         END IF

      AFTER FIELD cod_transpor 
         IF mr_tela.cod_transpor IS NOT NULL THEN
            CALL pol0584_busca_transportador() RETURNING p_status
            IF NOT p_status THEN
               ERROR "Transportadora nao Cadastrada"
               NEXT FIELD cod_transpor
            END IF
            DISPLAY BY NAME mr_tela.nom_transpor
         END IF

      AFTER FIELD entrega_ate    
         IF mr_tela.entrega_ate IS NULL THEN
            LET mr_tela.entrega_ate = p_prz_entrega
            DISPLAY mr_tela.entrega_ate TO entrega_ate
         ELSE
            IF NOT pol0584_checa_prz_entrega() THEN
               ERROR "Não há itens c/ prazo de entrega <= ", mr_tela.entrega_ate
               LET mr_tela.entrega_ate = p_prz_entrega
               NEXT FIELD entrega_ate 
            END IF
         END IF

      ON KEY (control-z)
         CALL pol0584_popup()

      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF mr_tela.num_pedido IS NULL AND mr_tela.oc_linha IS NULL THEN
               NEXT FIELD num_pedido
            END IF
            IF mr_tela.num_lote IS NULL THEN
               NEXT FIELD num_lote
            END IF
            IF mr_tela.entrega_ate IS NULL THEN
               NEXT FIELD entrega_ate
            END IF
         END IF
         
   END INPUT

   LET m_informou = FALSE
   
   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0
      RETURN FALSE 
   END IF

   IF NOT pol0584_bloqueia_pedido() THEN
      RETURN FALSE
   END if

   IF NOT p_dig_lote THEN
      LET mr_tela.num_lote = p_num_lote_om
   END IF

   IF mr_tela.oc_linha IS NULL THEN
      LET mr_tela.oc_linha = mr_pedidos.num_pedido_cli
   END IF
   
   DISPLAY mr_tela.num_lote TO num_lote
   DISPLAY mr_tela.oc_linha TO oc_linha

   IF NOT pol0584_busca_itens_pedido() THEN
      RETURN FALSE
   END IF

   CALL pol0584_informa_quantidades() RETURNING p_status

   CURRENT WINDOW IS w_pol0484
         
   LET m_informou = p_status

   RETURN p_status

END FUNCTION

#--------------------------------#
FUNCTION pol0584_escolhe_pedido()
#--------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol05841") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol05841 AT 6,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL SET_COUNT(p_index - 1)
   LET INT_FLAG = FALSE

   DISPLAY ARRAY pr_pedidos TO  sr_pedidos.*
      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE()
   
   CLOSE WINDOW w_pol05841
   CURRENT WINDOW IS w_pol0584
   
   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION

#--------------------------------#
FUNCTION pol0584_bloqueia_pedido()
#--------------------------------#

   CALL log085_transacao("BEGIN")

   WHENEVER ERROR CONTINUE

   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT num_pedido
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = mr_tela.num_pedido
      FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = -243 THEN
         CALL log0030_mensagem("Pedido sendo romaneado por outro usuário","exclamation")
      ELSE
         CALL log003_err_sql("BLOQUEANDO","PEDIDOS")
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#---------------------------#
FUNCTION pol0584_le_lote()
#---------------------------#

   SELECT MAX(num_lote_om)
     INTO p_num_lote_om
     FROM ordem_montag_lote
    WHERE cod_empresa = p_cod_empresa
         
   IF p_num_lote_om IS NULL THEN 
      LET p_num_lote_om = 1
   ELSE    
      LET p_num_lote_om = p_num_lote_om + 1
   END IF    

   LET mr_tela.num_lote = p_num_lote_om
   DISPLAY p_num_lote_om TO num_lote
   
END FUNCTION

#----------------------------------#
FUNCTION pol0584_busca_dat_entrega()
#----------------------------------#
   
   INITIALIZE p_prz_entrega TO NULL

   SELECT MAX(prz_entrega)
     INTO p_prz_entrega
     FROM ped_itens
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = mr_tela.num_pedido
   
   RETURN p_prz_entrega
   
END FUNCTION

#----------------------------------#
FUNCTION pol0584_checa_prz_entrega()
#----------------------------------#
   
   SELECT COUNT(prz_entrega)
     INTO p_count
     FROM ped_itens
    WHERE cod_empresa  = p_cod_empresa
      AND num_pedido   = mr_tela.num_pedido
      AND prz_entrega <= mr_tela.entrega_ate
   
   IF p_count = 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION

#-------------------------------------#
FUNCTION pol0584_busca_transportador()
#-------------------------------------#

   SELECT nom_cliente
     INTO mr_tela.nom_transpor
     FROM clientes
    WHERE cod_cliente = mr_tela.cod_transpor
  
   IF SQLCA.SQLCODE <> 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#---------------------------------#
 FUNCTION pol0584_verifica_pedido() 
#---------------------------------#

   DEFINE l_nom_cliente LIKE clientes.nom_cliente

   SELECT *
     INTO mr_pedidos.*
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = mr_tela.num_pedido

   IF sqlca.sqlcode <> 0 THEN
      ERROR "Pedido não Cadastrado !!!"
      RETURN FALSE
   END IF
   
   LET p_cod_cliente = mr_pedidos.cod_cliente
   
   IF mr_pedidos.ies_sit_pedido = '9' THEN
      ERROR 'Pedido Cancelado.'
      RETURN FALSE
   END IF
      
   IF mr_pedidos.ies_sit_pedido = 'B' THEN
      ERROR 'Pedido Bloqueado.'
      RETURN FALSE
   END IF

   IF mr_pedidos.ies_sit_pedido = 'S' THEN
      ERROR 'Pedido Suspenso.'
      RETURN FALSE
   END IF

   SELECT nom_cliente
     INTO l_nom_cliente
     FROM clientes
    WHERE cod_cliente = mr_pedidos.cod_cliente

   DISPLAY mr_pedidos.cod_cliente TO cod_cliente
   DISPLAY l_nom_cliente TO nom_cliente
   DISPLAY mr_pedidos.num_pedido_cli TO oc_linha

   IF mr_pedidos.ies_sit_pedido <> 'F' AND 
      mr_pedidos.ies_sit_pedido <> 'A' THEN
      IF pol0584_verifica_credito() = FALSE THEN
         RETURN FALSE
      END IF
   END IF
      
   IF pol0584_verifica_saldo_pedido() = FALSE THEN
      ERROR "Pedido sem saldo para Processar OM."
      RETURN FALSE
   END IF

   LET mr_tela.entrega_ate  = pol0584_busca_dat_entrega()
   LET mr_tela.cod_transpor = mr_pedidos.cod_transpor 
   CALL pol0584_busca_transportador() RETURNING p_status
   DISPLAY BY NAME mr_tela.cod_transpor, mr_tela.nom_transpor

   SELECT cod_nat_oper
     FROM operacao_bene_1040
    WHERE cod_nat_oper = mr_pedidos.cod_nat_oper
    
   IF STATUS = 0 THEN
      LET p_ies_bene = TRUE
   ELSE
      LET p_ies_bene = FALSE
   END IF

   SELECT cod_cliente
     FROM cli_c_oclinha_1040
    WHERE cod_cliente = mr_pedidos.cod_cliente
          
   IF STATUS = 0 THEN
      LET p_ies_oclinha = TRUE
   ELSE
      LET p_ies_oclinha = FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION pol0584_verifica_credito()
#----------------------------------#
   DEFINE lr_par_vdp           RECORD LIKE par_vdp.*,
          lr_cli_credito       RECORD LIKE cli_credito.*,
          l_valor_cli          DECIMAL(15,2),
          l_parametro          CHAR(1)
          
   SELECT *
     INTO lr_cli_credito.*
     FROM cli_credito
    WHERE cod_cliente = mr_pedidos.cod_cliente
      
   IF sqlca.sqlcode <> 0 THEN
      ERROR 'Cliente sem dados de crédito.'
      RETURN FALSE
   END IF

   SELECT *
     INTO lr_par_vdp.*
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF lr_par_vdp.par_vdp_txt[367] = 'S' THEN
      IF lr_cli_credito.qtd_dias_atr_dupl > lr_par_vdp.qtd_dias_atr_dupl THEN
         ERROR 'Cliente com duplicatas em atraso excedido.'
         RETURN FALSE
      END IF
      IF lr_cli_credito.qtd_dias_atr_med > lr_par_vdp.qtd_dias_atr_med THEN
         ERROR 'Cliente com atraso médio excedido.'
         RETURN FALSE
      END IF
   END IF

   SELECT par_ies
     INTO l_parametro
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'ies_limite_credito'
    
   IF l_parametro = 'S' THEN         
      LET l_valor_cli = lr_cli_credito.val_ped_carteira + 
                        lr_cli_credito.val_dup_aberto
      IF l_valor_cli > lr_cli_credito.val_limite_cred THEN
         ERROR 'Limite de crédito excedido.'
         RETURN FALSE
      END IF
   END IF

   IF lr_cli_credito.dat_val_lmt_cr IS NOT NULL THEN
      IF lr_cli_credito.dat_val_lmt_cr < TODAY THEN
         ERROR 'Data crédito expirada.'
         RETURN FALSE
      END IF
   END IF    
   
   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0584_verifica_saldo_pedido() 
#---------------------------------------#

    SELECT COUNT(cod_empresa)
      INTO p_count
      FROM ped_itens
     WHERE cod_empresa = p_cod_empresa 
       AND num_pedido  = mr_tela.num_pedido
       AND qtd_pecas_solic  - 
           qtd_pecas_atend  - 
           qtd_pecas_cancel - 
           qtd_pecas_reserv - 
           qtd_pecas_romaneio > 0 

   IF p_count > 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF  

END FUNCTION

#------------------------------------#
 FUNCTION pol0584_busca_itens_pedido()
#------------------------------------#

   INITIALIZE ma_tela TO NULL
   
   LET pa_curr = 1
   LET p_qtd_estoque = 0

   DECLARE cq_itens_ped CURSOR FOR
    SELECT num_sequencia, 
           cod_item,
           qtd_pecas_solic  - 
           qtd_pecas_atend  - 
           qtd_pecas_cancel -
           qtd_pecas_reserv -
           qtd_pecas_romaneio
      FROM ped_itens
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = mr_tela.num_pedido
       AND prz_entrega <= mr_tela.entrega_ate
       AND (qtd_pecas_solic  -   
            qtd_pecas_atend  -
            qtd_pecas_cancel -
            qtd_pecas_reserv -
            qtd_pecas_romaneio) > 0
   ORDER BY cod_item, 
            num_sequencia    
 
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","PED_ITENS")          
      RETURN FALSE
   END IF

   FOREACH cq_itens_ped INTO 
           ma_tela[pa_curr].num_sequencia,
           ma_tela[pa_curr].cod_item,
           ma_tela[pa_curr].qtd_saldo

      LET  p_sdo_pedido = ma_tela[pa_curr].qtd_saldo

      SELECT ies_ctr_estoque,
             ies_ctr_lote,
             cod_local_estoq,
             gru_ctr_estoq,
             cod_lin_prod
        INTO ma_item[pa_curr].ctr_estoque,
             ma_item[pa_curr].ctr_lote,
             p_cod_local_estoq,
             ma_item[pa_curr].gru_ctr_estoq,
             ma_item[pa_curr].cod_lin_prod
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = ma_tela[pa_curr].cod_item
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","ITEM")          
         RETURN FALSE
      END IF
 
      IF ma_item[pa_curr].ctr_estoque = 'N' THEN
        LET ma_estoq[pa_curr].qtd_estoque = NULL
        LET ma_tela[pa_curr].qtd_reservada = ma_tela[pa_curr].qtd_saldo
      ELSE                                  
         CALL pol0584_pega_estoq_boas()
         
         IF p_ies_bene THEN
            CALL pol0584_pega_estoq_rej()
         END IF
 
         INSERT INTO estoq_disp_temp
            VALUES(ma_tela[pa_curr].num_sequencia,
                   ma_tela[pa_curr].cod_item,
                   ma_tela[pa_curr].qtd_reservada)
      END IF
      
      IF p_ies_bene THEN
         IF NOT pol0584_grava_mat_pri() THEN
            RETURN FALSE
         END IF
      END IF
      
      LET pa_curr = pa_curr + 1

   END FOREACH    
   
   IF pa_curr = 1 THEN
      RETURN FALSE
   ELSE 
      RETURN TRUE
   END IF

END FUNCTION

#---------------------------------#
FUNCTION pol0584_pega_estoq_boas()
#---------------------------------#

IF NOT p_ies_oclinha THEN
 SELECT SUM(qtd_saldo)
   INTO p_qtd_estoque
   FROM estoque_lote
  WHERE cod_empresa = p_cod_empresa
    AND cod_item    = ma_tela[pa_curr].cod_item
    AND cod_local   = p_cod_local_estoq
    AND ies_situa_qtd IN ('L','E')
ELSE
 SELECT SUM(qtd_saldo)
   INTO p_qtd_estoque
   FROM estoque_lote
  WHERE cod_empresa = p_cod_empresa
    AND cod_item    = ma_tela[pa_curr].cod_item
    AND cod_local   = p_cod_local_estoq
    AND ies_situa_qtd IN ('L','E')
    AND num_lote    = mr_tela.oc_linha
END IF
  
   IF p_qtd_estoque IS NULL OR p_qtd_estoque < 0 THEN
    LET p_qtd_estoque = 0
 END IF

IF NOT p_ies_oclinha THEN
 SELECT SUM(qtd_reservada - qtd_atendida)
   INTO p_qtd_estoq_reser
   FROM estoque_loc_reser
  WHERE cod_empresa = p_cod_empresa
    AND cod_item    = ma_tela[pa_curr].cod_item
    AND cod_local   = p_cod_local_estoq
ELSE
 SELECT SUM(qtd_reservada - qtd_atendida)
   INTO p_qtd_estoq_reser
   FROM estoque_loc_reser
  WHERE cod_empresa = p_cod_empresa
    AND cod_item    = ma_tela[pa_curr].cod_item
    AND cod_local   = p_cod_local_estoq
    AND num_lote    = mr_tela.oc_linha
END IF

 IF p_qtd_estoq_reser IS NULL OR p_qtd_estoq_reser < 0 THEN
    LET p_qtd_estoq_reser = 0 
 END IF         

 LET p_qtd_estoque = p_qtd_estoque - p_qtd_estoq_reser
 
 IF p_qtd_estoque < 0 THEN
    LET p_qtd_estoque = 0
 END IF
 
 LET ma_estoq[pa_curr].qtd_estoque = p_qtd_estoque
 
 SELECT SUM(qtd_reservada)
   INTO p_qtd_romaneio
   FROM estoq_disp_temp
  WHERE cod_item = ma_tela[pa_curr].cod_item

 IF p_qtd_romaneio IS NULL THEN 
    LET p_qtd_romaneio = 0
 END IF

 LET ma_tela[pa_curr].qtd_estoque = p_qtd_estoque - p_qtd_romaneio

 IF ma_tela[pa_curr].qtd_estoque < ma_tela[pa_curr].qtd_saldo THEN
    LET ma_tela[pa_curr].qtd_reservada = ma_tela[pa_curr].qtd_estoque
 ELSE
    LET ma_tela[pa_curr].qtd_reservada = ma_tela[pa_curr].qtd_saldo
 END IF   

END FUNCTION

#---------------------------------#
FUNCTION pol0584_pega_estoq_rej()
#---------------------------------#

IF NOT p_ies_oclinha THEN
 SELECT SUM(qtd_saldo)
   INTO p_qtd_estoque
   FROM estoque_lote
  WHERE cod_empresa = p_cod_empresa
    AND cod_item    = ma_tela[pa_curr].cod_item
    AND cod_local   = p_parametros_1040.local_est_pc_rej
    AND ies_situa_qtd IN ('L','E')
ELSE
 SELECT SUM(qtd_saldo)
   INTO p_qtd_estoque
   FROM estoque_lote
  WHERE cod_empresa = p_cod_empresa
    AND cod_item    = ma_tela[pa_curr].cod_item
    AND cod_local   = p_parametros_1040.local_est_pc_rej
    AND ies_situa_qtd IN ('L','E')
    AND num_lote    = mr_tela.oc_linha
END IF
  
  IF p_qtd_estoque IS NULL OR p_qtd_estoque < 0 THEN
    LET p_qtd_estoque = 0
 END IF

IF NOT p_ies_oclinha THEN
 SELECT SUM(qtd_reservada - qtd_atendida)
   INTO p_qtd_estoq_reser
   FROM estoque_loc_reser
  WHERE cod_empresa = p_cod_empresa
    AND cod_item    = ma_tela[pa_curr].cod_item
    AND cod_local   = p_parametros_1040.local_est_pc_rej
ELSE
 SELECT SUM(qtd_reservada - qtd_atendida)
   INTO p_qtd_estoq_reser
   FROM estoque_loc_reser
  WHERE cod_empresa = p_cod_empresa
    AND cod_item    = ma_tela[pa_curr].cod_item
    AND cod_local   = p_parametros_1040.local_est_pc_rej
    AND num_lote    = mr_tela.oc_linha
END IF

 IF p_qtd_estoq_reser IS NULL OR p_qtd_estoq_reser < 0 THEN
    LET p_qtd_estoq_reser = 0 
 END IF         

 LET p_qtd_estoque = p_qtd_estoque - p_qtd_estoq_reser
 
 IF p_qtd_estoque < 0 THEN
    LET p_qtd_estoque = 0
 END IF
 
 LET ma_tela[pa_curr].estoq_rej = p_qtd_estoque

 IF ma_tela[pa_curr].estoq_rej < ma_tela[pa_curr].qtd_saldo THEN
    LET ma_tela[pa_curr].reser_rej = ma_tela[pa_curr].estoq_rej
 ELSE
    LET ma_tela[pa_curr].reser_rej = ma_tela[pa_curr].qtd_saldo
 END IF   

END FUNCTION


#-------------------------------------#
 FUNCTION pol0584_informa_quantidades() 
#-------------------------------------#

   CALL SET_COUNT(pa_curr - 1)
   
   LET p_erro = FALSE

   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM sr_tela.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)

      BEFORE FIELD qtd_reservada 
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

         IF p_erro = FALSE THEN         
            INITIALIZE p_den_item, p_ctr_estoque, p_ctr_lote TO NULL
            SELECT den_item,
                   ies_ctr_estoque,
                   ies_ctr_lote
              INTO p_den_item,
                   p_ctr_estoque,
                   p_ctr_lote
              FROM item
             WHERE cod_empresa = p_cod_empresa
               AND cod_item = ma_tela[pa_curr].cod_item
          
             DISPLAY p_den_item    TO den_item
             DISPLAY p_ctr_estoque TO ctr_estoque
             DISPLAY p_ctr_lote    TO ctr_lote
             
             SELECT SUM(qtd_reservada)
               INTO p_qtd_romaneio
               FROM estoq_disp_temp
              WHERE cod_item = ma_tela[pa_curr].cod_item
       
             IF p_qtd_romaneio > 0 THEN
                LET p_qtd_romaneio = p_qtd_romaneio - ma_tela[pa_curr].qtd_reservada
             END IF

             LET ma_tela[pa_curr].qtd_estoque = ma_estoq[pa_curr].qtd_estoque - p_qtd_romaneio
             DISPLAY ma_tela[pa_curr].qtd_estoque TO sr_tela[sc_curr].qtd_estoque
          END IF
          
          LET p_erro = FALSE
          
      AFTER FIELD qtd_reservada 
         IF ma_tela[pa_curr].qtd_reservada > ma_tela[pa_curr].qtd_saldo THEN
            ERROR "Quantidade reservada maior que saldo do item do pedido"
            LET p_erro = TRUE
            NEXT FIELD qtd_reservada
         END IF

         IF ma_item[pa_curr].ctr_estoque = 'S' THEN
            IF ma_tela[pa_curr].qtd_reservada > ma_tela[pa_curr].qtd_estoque THEN
               ERROR "Quantidade reservada maior que saldo em estoque"
               LET p_erro = TRUE
               NEXT FIELD qtd_reservada
            END IF
         END IF

         IF ma_tela[pa_curr].qtd_reservada > 0 AND p_ies_bene THEN
            
            LET p_tot_reser = ma_tela[pa_curr].qtd_reservada 
            
            IF ma_tela[pa_curr].reser_rej IS NULL OR ma_tela[pa_curr].reser_rej = ' ' THEN
            ELSE
               IF ma_tela[pa_curr].reser_rej > 0 THEN 
                  LET p_tot_reser = p_tot_reser + ma_tela[pa_curr].reser_rej
               END IF
            END IF
            
            IF NOT pol0584_tem_material() THEN
               IF p_erro THEN 
                  LET INT_FLAG = 1
                  EXIT INPUT
               ELSE
                  ERROR 'Não há mat prima suficiente p/ faturar a quantidade informada'
                  NEXT FIELD qtd_reservada
               END IF
            END IF
         END IF

         IF pol0584_verifica_qtd_embal() = FALSE THEN
            CALL log0030_mensagem("Pedido padrao embal. qtd. pecas nao padrao embal.","info")
            LET p_erro = TRUE
            NEXT FIELD qtd_reservada
         END IF

         UPDATE estoq_disp_temp
            SET qtd_reservada = ma_tela[pa_curr].qtd_reservada
          WHERE num_seq  = ma_tela[pa_curr].num_sequencia
            AND cod_item = ma_tela[pa_curr].cod_item

      BEFORE FIELD reser_rej
         IF NOT p_ies_bene THEN
            NEXT FIELD estoq_rej
         END IF

      AFTER FIELD reser_rej
         IF ma_tela[pa_curr].reser_rej > ma_tela[pa_curr].qtd_saldo THEN
            ERROR "Quantidade rejeitada maior que saldo do item do pedido"
            NEXT FIELD reser_rej
         END IF

         IF ma_item[pa_curr].ctr_estoque = 'S' THEN
            IF ma_tela[pa_curr].reser_rej > ma_tela[pa_curr].estoq_rej THEN
               ERROR "Quantidade rejeitada maior que saldo das rejeitadas"
               NEXT FIELD reser_rej
            END IF
         END IF
         
         LET p_tot_reser = ma_tela[pa_curr].reser_rej
         
         IF ma_tela[pa_curr].qtd_reservada IS NULL OR 
            ma_tela[pa_curr].qtd_reservada = ' ' THEN
         ELSE
            LET p_tot_reser = p_tot_reser + ma_tela[pa_curr].qtd_reservada
         END IF
         
         IF p_tot_reser > ma_tela[pa_curr].qtd_saldo THEN
            ERROR "Quantidade reservada + rejeitada > saldo do item do pedido"
            NEXT FIELD reser_rej
         END IF

         IF ma_tela[pa_curr].reser_rej > 0 THEN
            IF NOT pol0584_tem_material() THEN
               IF p_erro THEN 
                  LET INT_FLAG = 1
                  EXIT INPUT
               ELSE
                  ERROR 'Não há mat prima suficiente p/ faturar boas + rejeitadas desse item'
                  NEXT FIELD qtd_reservada
               END IF
            END IF
         END IF
         
   END INPUT        

   LET p_qtd_itens = ARR_COUNT()
   LET p_om = FALSE
   LET p_sl = FALSE
   
   FOR p_ind = 1 TO p_qtd_itens
      IF ma_tela[p_ind].qtd_reservada > 0 THEN
         LET p_om = TRUE
      END IF
      IF ma_tela[p_ind].reser_rej IS NOT NULL THEN
         IF ma_tela[p_ind].reser_rej > 0 THEN
            LET p_sl = TRUE
         END IF
      END IF
   END FOR
   
   IF INT_FLAG OR (p_om = FALSE AND p_sl = FALSE) THEN
      LET INT_FLAG = FALSE
      CLEAR FORM 
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   LET p_exibiu_tela = FALSE
   LET p_cancelou = FALSE
   LET p_tela_exibida = FALSE
   LET p_status = FALSE
   LET p_itens_array = ARR_COUNT()
   LET p_tip_peca = 'B'

   IF pol0584_checa_lote() THEN
      LET p_tip_peca = 'R'
      IF pol0584_checa_lote() THEN
         LET p_status = TRUE
      END IF
   END IF

   IF p_exibiu_tela THEN
      CLOSE WINDOW w_pol05842
      CURRENT WINDOW IS w_pol0584
   END IF

   RETURN p_status
   
END FUNCTION

#------------------------------------#
 FUNCTION pol0584_verifica_qtd_embal()
#------------------------------------#

   DEFINE l_qtd_padr_embal LIKE item_embalagem.qtd_padr_embal,
          l_qtd_embal      LIKE item_embalagem.qtd_padr_embal


   LET l_qtd_padr_embal = 1
   WHENEVER ERROR CONTINUE
   SELECT a.qtd_padr_embal
     INTO l_qtd_padr_embal
     FROM item_embalagem a
    WHERE a.cod_empresa   = p_cod_empresa
      AND a.cod_item      = ma_tela[pa_curr].cod_item
      AND a.ies_tip_embal IN ('I','N')

   WHENEVER ERROR STOP   
   
   LET l_qtd_embal = ma_tela[pa_curr].qtd_reservada MOD l_qtd_padr_embal
   
   IF (l_qtd_embal > 0 )
   AND (mr_pedidos.ies_embal_padrao <> '3' )  THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#---------------------------------------#
FUNCTION pol0584_cria_tabela_temporaria()
#---------------------------------------#

   WHENEVER ERROR CONTINUE

   CREATE TEMP TABLE w_lote
     (
      cod_empresa    CHAR(2),  
      cod_item       CHAR(015),
      num_seq        SMALLINT,
      cod_local      CHAR(010),
      num_lote       CHAR(015),
      tip_peca       CHAR(01),
      qtd_reservada  DECIMAL(15,3),
      qtd_saldo      DECIMAL(15,3),
      num_transac    INTEGER
     );

   IF SQLCA.SQLCODE = -958 THEN 
      DELETE FROM w_lote
   END IF

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-W_LOTE")
      RETURN FALSE
   END IF

   CREATE TEMP TABLE estoq_disp_temp
     (
      num_seq       DECIMAL(5,0),
      cod_item      CHAR(15),
      qtd_reservada DECIMAL(10,3)
     );

   IF SQLCA.SQLCODE = -958 THEN 
      DELETE FROM estoq_disp_temp
   END IF

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","ESTOQ_DISP_TEMP")
      RETURN FALSE
   END IF

   CREATE TEMP TABLE estrutura_tmp
     (
      oc_linha        CHAR(15),
      cod_item_pai    CHAR(15),
      cod_pai_imediato CHAR(15),
      cod_item_compon CHAR(15),
      qtd_necessaria  DECIMAL(14,7),
      qtd_em_estoque  DECIMAL(14,7),
      qtd_sobra       DECIMAL(14,7)
     );

   IF SQLCA.SQLCODE = -958 THEN 
      DELETE FROM estrutura_tmp
   END IF
   
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","ESTRUTURA_TMP")
      RETURN FALSE
   END IF

   CREATE TEMP TABLE nf_tmp_1040
     (
        num_nf   INTEGER,
        ser_nf   CHAR(01),
        ssr_nf   SMALLINT,
        esp_nf   CHAR(03),
        num_seq  SMALLINT,
        qtd_item DECIMAL(15,3),
        pre_unit DECIMAL(17,6),
        serie    CHAR(15)
     );

   IF SQLCA.SQLCODE = -958 THEN 
      DELETE FROM nf_tmp_1040
   END IF

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","NF_TMP_1040")
      RETURN FALSE
   END IF

   WHENEVER ERROR STOP
 
   RETURN TRUE

END FUNCTION
 

#------------------------------#
 FUNCTION pol0584_checa_lote()
#------------------------------#
   
   WHENEVER ERROR CONTINUE

   FOR p_ind = 1 TO p_itens_array
       IF p_tip_peca = 'B' THEN
          LET p_qtd_sel_item = ma_tela[p_ind].qtd_reservada
       ELSE
          LET p_qtd_sel_item = ma_tela[p_ind].reser_rej
       END IF
       IF p_qtd_sel_item > 0 THEN
          IF ma_item[p_ind].ctr_estoque = 'S' THEN
             IF ma_item[p_ind].ctr_lote = "S" AND p_ies_oclinha = FALSE THEN       
                LET p_exibiu_tela = TRUE
                IF NOT pol0584_escolhe_lote() THEN
                   LET p_cancelou = TRUE
                   EXIT FOR
                END IF
             ELSE
                IF NOT pol0584_pega_lote_automatic() THEN
                   LET p_cancelou = TRUE
                   EXIT FOR
                END IF
             END IF
          END IF
       END IF
   END FOR

   WHENEVER ERROR STOP

   IF p_cancelou THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION

#------------------------------------#
FUNCTION pol0584_pega_lote_automatic()
#------------------------------------#

   LET p_qtd_reservar = p_qtd_sel_item

   SELECT cod_local_estoq
     INTO p_cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = ma_tela[p_ind].cod_item

   IF p_tip_peca = 'R' THEN
      LET p_cod_local_estoq = p_parametros_1040.local_est_pc_rej
   END IF

   DECLARE cq_lote_end CURSOR FOR
   SELECT num_lote,
          qtd_saldo,  
          dat_hor_producao,
          num_transac,
          endereco,
          comprimento,
          largura,
          altura,
          diametro
    FROM estoque_lote_ender
   WHERE cod_empresa = p_cod_empresa
     AND cod_item = ma_tela[p_ind].cod_item
     AND cod_local = p_cod_local_estoq
     AND qtd_saldo > 0
     AND ies_situa_qtd IN ("L","E")
   ORDER BY dat_hor_producao, 
            num_lote

   FOREACH cq_lote_end INTO 
           p_num_lote,
           p_qtd_saldo,
           p_dat_hor_producao,
           p_num_transac,
           p_endereco,      
           p_comprimento,   
           p_largura,       
           p_altura,        
           p_diametro       

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'estoque_lote_ender:1')
         RETURN FALSE
      END IF           
                      
      IF p_ies_oclinha THEN
         IF p_num_lote <> mr_tela.oc_linha THEN
            CONTINUE FOREACH
         END IF
      END IF
           
      IF p_num_lote IS NULL THEN
         SELECT SUM(qtd_reservada - qtd_atendida)        
           INTO p_qtd_reservada                             
           FROM estoque_loc_reser a,                        
                est_loc_reser_end b                         
          WHERE a.cod_empresa = p_cod_empresa               
            AND a.cod_item    = ma_tela[p_ind].cod_item     
            AND a.cod_local   = p_cod_local_estoq           
            AND a.num_lote      IS NULL                    
            AND b.cod_empresa = a.cod_empresa              
            AND b.num_reserva = a.num_reserva              
            AND b.endereco    = p_endereco                 
            AND b.comprimento = p_comprimento              
            AND b.largura     = p_largura                  
            AND b.altura      = p_altura                   
            AND b.diametro    = p_diametro                 
      ELSE
         SELECT SUM(qtd_reservada - qtd_atendida)        
           INTO p_qtd_reservada                             
           FROM estoque_loc_reser a,                        
                est_loc_reser_end b                         
          WHERE a.cod_empresa = p_cod_empresa               
            AND a.cod_item    = ma_tela[p_ind].cod_item     
            AND a.cod_local   = p_cod_local_estoq           
            AND a.num_lote    = p_num_lote                 
            AND b.cod_empresa = a.cod_empresa              
            AND b.num_reserva = a.num_reserva              
            AND b.endereco    = p_endereco                 
            AND b.comprimento = p_comprimento              
            AND b.largura     = p_largura                  
            AND b.altura      = p_altura                   
            AND b.diametro    = p_diametro                 
      END IF

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','reservas:1')
         RETURN FALSE
      END IF
      
      IF p_qtd_reservada IS NULL THEN
         LET p_qtd_reservada = 0
      END IF
        
      IF p_qtd_saldo > p_qtd_reservada THEN
         LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
      ELSE
         CONTINUE FOREACH
      END IF
      
      IF p_qtd_saldo > p_qtd_reservar THEN
         LET p_qtd_saldo = p_qtd_reservar
      END IF
      
      LET p_qtd_reservar = p_qtd_reservar - p_qtd_saldo
      
      INSERT INTO w_lote
         VALUES(p_cod_empresa,
                ma_tela[p_ind].cod_item,
                ma_tela[p_ind].num_sequencia,
                p_cod_local_estoq,
                p_num_lote,
                p_tip_peca,
                p_qtd_saldo,
                p_qtd_reservar,
                p_num_transac)
                
      IF STATUS <> 0 THEN
         CALL log003_err_sql("INCLUSAO","W_LOTE") 
         RETURN FALSE
      END IF
      
      IF p_qtd_reservar = 0 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH

   IF p_qtd_reservar > 0 THEN
      LET p_men = 'Item: ', ma_tela[p_ind].cod_item
      LET p_men = p_men CLIPPED, ' sem lote para p/ reserva do produto !!!'
      CALL log0030_mensagem(p_men,"exclamation")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION pol0584_escolhe_lote()
#------------------------------#

   IF NOT p_tela_exibida THEN
      LET p_tela_exibida = TRUE
      CALL log006_exibe_teclas("01",p_versao)
      INITIALIZE p_nom_tela TO NULL
      CALL log130_procura_caminho("pol05842") RETURNING p_nom_tela
      LET p_nom_tela = p_nom_tela CLIPPED 
      OPEN WINDOW w_pol05842 AT 05,2 WITH FORM p_nom_tela 
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   END IF
   
   INITIALIZE ma_tela2 TO NULL
   LET p_i = 1
   LET p_qtd_asel_lot = p_qtd_sel_item

   SELECT den_item_reduz
     INTO p_den_item_reduz
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = ma_tela[p_ind].cod_item
   
   DISPLAY ma_tela[p_ind].num_sequencia TO num_seq
   DISPLAY ma_tela[p_ind].cod_item      TO cod_item
   DISPLAY p_den_item_reduz             TO den_item_reduz
   DISPLAY p_qtd_sel_item               TO qtd_sel_item
   DISPLAY p_qtd_asel_lot               TO qtd_asel_lot
   DISPLAY 0                            TO qtd_sel_lot

   SELECT cod_local_estoq
     INTO p_cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = ma_tela[p_ind].cod_item

   IF p_tip_peca = 'R' THEN
      LET p_cod_local_estoq = p_parametros_1040.local_est_pc_rej
   END IF

   DECLARE cq_estoque_lote CURSOR FOR
   SELECT num_lote,
          qtd_saldo,  
          dat_hor_producao,
          num_transac,
          endereco,
          comprimento,
          largura,
          altura,
          diametro
    FROM estoque_lote_ender
   WHERE cod_empresa = p_cod_empresa
     AND cod_item    = ma_tela[p_ind].cod_item
     AND cod_local   = p_cod_local_estoq
     AND ies_situa_qtd IN ("L","E")
     AND num_lote IS NOT NULL
   ORDER BY dat_hor_producao, 
            num_lote,
            endereco

   FOREACH cq_estoque_lote INTO 
           mr_estoque_lote_ender.num_lote,
           mr_estoque_lote_ender.qtd_saldo,
           p_dat_hor_producao,
           p_num_transac,
           p_endereco,      
           p_comprimento,   
           p_largura,       
           p_altura,        
           p_diametro       

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_lote_ender:2')
         RETURN FALSE
      END IF

      SELECT SUM(qtd_reservada - qtd_atendida)          
        INTO p_qtd_reservada                                
        FROM estoque_loc_reser a,                           
             est_loc_reser_end b                            
       WHERE a.cod_empresa = p_cod_empresa                  
         AND a.cod_item    = ma_tela[p_ind].cod_item        
         AND a.num_lote    = mr_estoque_lote_ender.num_lote                    
         AND a.cod_local   = p_cod_local_estoq              
         AND b.cod_empresa = a.cod_empresa                 
         AND b.num_reserva = a.num_reserva                 
         AND b.endereco    = p_endereco                    
         AND b.comprimento = p_comprimento                 
         AND b.largura     = p_largura                     
         AND b.altura      = p_altura                      
         AND b.diametro    = p_diametro                    

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','reservas:2')
         RETURN FALSE
      END IF

      IF p_qtd_reservada IS NULL THEN
         LET p_qtd_reservada = 0 
      END IF

      LET ma_tela2[p_i].num_transac = p_num_transac
      LET ma_tela2[p_i].endereco  = p_endereco
      LET ma_tela2[p_i].num_lote  = mr_estoque_lote_ender.num_lote
      LET ma_tela2[p_i].qtd_saldo = mr_estoque_lote_ender.qtd_saldo - p_qtd_reservada

      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada
        FROM w_lote 
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = ma_tela[p_ind].cod_item
         AND num_lote    = ma_tela2[p_i].num_lote
         AND tip_peca    = p_tip_peca
         AND num_transac = p_num_transac

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','w_lote:1')
         RETURN FALSE
      END IF

      IF p_qtd_reservada IS NULL THEN
         LET p_qtd_reservada = 0
      END IF 

      LET ma_tela2[p_i].qtd_saldo = ma_tela2[p_i].qtd_saldo - p_qtd_reservada
   
      IF ma_tela2[p_i].qtd_saldo <= 0 THEN
         CONTINUE FOREACH
      END IF

      LET ma_tela2[p_i].qtd_reservada = 0 

      LET p_i = p_i + 1

   END FOREACH
   
   IF p_i = 1 THEN
      LET p_men = 'Item: ', ma_tela[p_ind].cod_item
      LET p_men = p_men CLIPPED, ' sem lote para p/ reserva do produto !!!'
      CALL log0030_mensagem(p_men,"exclamation")
      RETURN FALSE
   END IF
   
   LET p_qtd_linha = p_i - 1

   CALL SET_COUNT(p_i - 1)

   INPUT ARRAY ma_tela2 WITHOUT DEFAULTS FROM s_ordem.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)

      BEFORE ROW
         LET la_curr = ARR_CURR()
         LET lc_curr = SCR_LINE()

      AFTER FIELD qtd_reservada 

         IF ma_tela2[la_curr].qtd_reservada IS NULL AND
            ma_tela2[la_curr].qtd_saldo IS NOT NULL THEN
            ERROR 'Campo c/ preenchimento obrigatório !!!'
            NEXT FIELD qtd_reservada
         END IF 
            
         IF ma_tela2[la_curr].qtd_reservada IS NOT NULL AND
            ma_tela2[la_curr].qtd_saldo IS NULL THEN
            ERROR 'Valor ilegar p/ lote inexistente !!!'
            LET ma_tela2[la_curr].qtd_reservada = NULL
            NEXT FIELD qtd_reservada
         END IF 

      IF ma_tela2[la_curr].qtd_reservada IS NOT NULL THEN
         IF ma_tela2[la_curr].qtd_reservada > ma_tela2[la_curr].qtd_saldo THEN
            ERROR "Quantidade Reservada Maior que Saldo do Lote"
            NEXT FIELD qtd_reservada
         END IF 

         LET p_qtd_reser_lot = 0
 
         FOR p_ind2 = 1 TO p_qtd_linha
             LET p_qtd_reser_lot = p_qtd_reser_lot + ma_tela2[p_ind2].qtd_reservada
         END FOR

         IF p_qtd_reser_lot > p_qtd_sel_item THEN
            ERROR "Soma da Qtd Reservada > Qtd Selec p/ Item"
            NEXT FIELD qtd_reservada
         END IF 

         LET p_qtd_asel_lot = p_qtd_sel_item - p_qtd_reser_lot
         
         DISPLAY p_qtd_reser_lot TO qtd_sel_lot
         DISPLAY p_qtd_asel_lot  TO qtd_asel_lot

         DELETE FROM w_lote 
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = ma_tela[p_ind].cod_item
            AND num_seq     = ma_tela[p_ind].num_sequencia
            AND num_lote    = ma_tela2[la_curr].num_lote
            AND tip_peca    = p_tip_peca
            AND num_transac = ma_tela2[la_curr].num_transac
         
         IF ma_tela2[la_curr].qtd_reservada > 0 THEN
            INSERT INTO w_lote
               VALUES(p_cod_empresa,
                      ma_tela[p_ind].cod_item,
                      ma_tela[p_ind].num_sequencia,
                      p_cod_local_estoq,
                      ma_tela2[la_curr].num_lote,
                      p_tip_peca,
                      ma_tela2[la_curr].qtd_reservada,
                      ma_tela2[la_curr].qtd_saldo,
                      ma_tela2[la_curr].num_transac)
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("INCLUSAO","W_LOTE")
               RETURN FALSE
            END IF
         END IF
      ELSE
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RIGHT") THEN
            IF ma_tela2[la_curr].qtd_saldo IS NULL THEN
               ERROR 'Não existem mais itens nessa direção !!!'
               NEXT FIELD qtd_reservada
            END IF
         END IF
      END IF

      AFTER INPUT 
         IF NOT INT_FLAG THEN
            IF p_qtd_reser_lot < p_qtd_sel_item THEN
               ERROR "Qtd Selec dos Lotes < Qtd Selec p/ Item"
               NEXT FIELD qtd_reservada
            END IF
         END IF

   END INPUT        

   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0584_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_transpor)
         LET mr_tela.cod_transpor = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0584
         IF mr_tela.cod_transpor IS NOT NULL THEN 
            CALL pol0584_busca_transportador() RETURNING p_status
         ELSE
            INITIALIZE mr_tela.nom_transpor TO NULL
         END IF
         DISPLAY BY NAME mr_tela.cod_transpor, mr_tela.nom_transpor

   END CASE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0584_grava_mat_pri()
#-------------------------------#

   IF NOT pol0584_monta_estrutura() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0584_monta_estrutura()
#---------------------------------#

   LET p_qtd_acumulada = 1
   LET p_cod_pai_imediato = ma_tela[pa_curr].cod_item
   
   DECLARE cq_estru_nevel_1 CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = ma_tela[pa_curr].cod_item
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
            (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
            (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
            (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))

   FOREACH cq_estru_nevel_1 INTO
           p_cod_item_compon,
           p_qtd_necessaria

      LET p_qtd_acumulada = p_qtd_acumulada * p_qtd_necessaria

      IF NOT pol0584_tem_estrutura() THEN
         IF NOT pol0584_insere_item() THEN
            RETURN FALSE
         ELSE
            CONTINUE FOREACH
         END IF
      END IF
      
      LET p_cod_pai_imediato = p_cod_item_compon
      
      DECLARE cq_estru_nevel_2 CURSOR FOR
        SELECT cod_item_compon,
               qtd_necessaria
          FROM estrutura
         WHERE cod_empresa  = p_cod_empresa
           AND cod_item_pai = p_cod_pai_imediato
           AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
                (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
                (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
                (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))
           
      FOREACH cq_estru_nevel_2 INTO
              p_cod_item_compon,
              p_qtd_necessaria

         LET p_qtd_acumulada = p_qtd_acumulada * p_qtd_necessaria
         
         IF NOT pol0584_tem_estrutura() THEN
            IF NOT pol0584_insere_item() THEN
               RETURN FALSE
            ELSE
               CONTINUE FOREACH
            END IF
         END IF
         
         LET p_cod_pai_imediato = p_cod_item_compon
         
         DECLARE cq_estru_nevel_3 CURSOR FOR
           SELECT cod_item_compon,
                  qtd_necessaria
             FROM estrutura
            WHERE cod_empresa  = p_cod_empresa
              AND cod_item_pai = p_cod_pai_imediato
              AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
                   (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
                   (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
                   (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))
           
         FOREACH cq_estru_nevel_3 INTO
                 p_cod_item_compon,
                 p_qtd_necessaria

            LET p_qtd_acumulada = p_qtd_acumulada * p_qtd_necessaria
            
            IF NOT pol0584_tem_estrutura() THEN
               IF NOT pol0584_insere_item() THEN
                  RETURN FALSE
               ELSE
                  CONTINUE FOREACH
               END IF
            END IF
            
            LET p_cod_pai_imediato = p_cod_item_compon
            DECLARE cq_estru_nevel_4 CURSOR FOR
              SELECT cod_item_compon,
                     qtd_necessaria
                FROM estrutura
               WHERE cod_empresa  = p_cod_empresa
                 AND cod_item_pai = p_cod_pai_imediato
                 AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
                      (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
                      (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
                      (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))
           
            FOREACH cq_estru_nevel_4 INTO
                    p_cod_item_compon,
                    p_qtd_necessaria
      
               LET p_qtd_acumulada = p_qtd_acumulada * p_qtd_necessaria
               
               IF NOT pol0584_tem_estrutura() THEN
                  IF NOT pol0584_insere_item() THEN
                     RETURN FALSE
                  ELSE
                     CONTINUE FOREACH
                  END IF
               END IF
               
               LET p_cod_pai_imediato = p_cod_item_compon
               
               DECLARE cq_estru_nevel_5 CURSOR FOR
                 SELECT cod_item_compon,
                        qtd_necessaria
                   FROM estrutura
                  WHERE cod_empresa  = p_cod_empresa
                    AND cod_item_pai = p_cod_pai_imediato
                    AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
                         (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
                         (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
                         (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))
           
               FOREACH cq_estru_nevel_5 INTO
                       p_cod_item_compon,
                       p_qtd_necessaria

                  LET p_qtd_acumulada = p_qtd_acumulada * p_qtd_necessaria
                  
                  IF NOT pol0584_tem_estrutura() THEN
                     IF NOT pol0584_insere_item() THEN
                        RETURN FALSE
                     ELSE
                        CONTINUE FOREACH
                     END IF
                  END IF
                  
                  LET p_cod_pai_imediato = p_cod_item_compon
                  
                  DECLARE cq_estru_nevel_6 CURSOR FOR
                    SELECT cod_item_compon,
                           qtd_necessaria
                      FROM estrutura
                     WHERE cod_empresa  = p_cod_empresa
                       AND cod_item_pai = p_cod_pai_imediato
                       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
                            (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
                            (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
                            (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))
           
                  FOREACH cq_estru_nevel_6 INTO
                          p_cod_item_compon,
                          p_qtd_necessaria
                          
                     LET p_qtd_acumulada = p_qtd_acumulada * p_qtd_necessaria
                     
                     IF NOT pol0584_insere_item() THEN
                        RETURN FALSE
                     END IF
      
                  END FOREACH

               END FOREACH
               
            END FOREACH
      
         END FOREACH

      END FOREACH

   END FOREACH

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0584_tem_estrutura()
#-------------------------------#

   SELECT COUNT(cod_item_compon)
     INTO p_count
     FROM estrutura
    WHERE cod_empresa  = p_cod_empresa
      AND cod_item_pai = p_cod_item_compon
      AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
           (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
           (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
           (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))

   IF p_count = 0 THEN 
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION

#-----------------------------#
FUNCTION pol0584_insere_item()
#-----------------------------#

   SELECT ies_tip_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_compon
      AND ies_tip_item IN ('B','C')
      
   IF STATUS <> 0 THEN
      LET p_qtd_acumulada = 1
      RETURN TRUE
   END IF

   SELECT qtd_necessaria
     FROM estrutura_tmp
    WHERE oc_linha        = mr_tela.oc_linha
      AND cod_item_pai    = ma_tela[pa_curr].cod_item
      AND cod_item_compon = p_cod_item_compon
   
   IF STATUS = 0 THEN
      UPDATE estrutura_tmp
         SET qtd_necessaria = qtd_necessaria + p_qtd_acumulada
       WHERE oc_linha        = mr_tela.oc_linha
         AND cod_item_pai    = ma_tela[pa_curr].cod_item
         AND cod_item_compon = p_cod_item_compon

      IF STATUS <> 0 THEN
         CALL log003_err_sql("UPDADTE","ESTRUTURA_TMP") 
         RETURN FALSE
      END IF
   ELSE    
      LET p_processo = 'R'
      IF p_ies_oclinha THEN
         CALL pol0584_pega_estq_c_ocl()
         IF p_sdo_mat_pri > 0 THEN
            LET p_qtd_acumulada = p_sdo_mat_pri / p_sdo_pedido
         END IF
      ELSE
         CALL pol0584_pega_estq_s_ocl() 
      END IF

      IF p_qtd_mat_prima <= 0 THEN
         LET p_cod_item_altern = p_cod_item_compon
         CALL pol0584_le_item_altern()
         IF NOT p_tem_altern THEN
            LET p_cod_item_compon = p_cod_item_altern
            LET p_qtd_mat_prima = 0
         END IF
      END IF

      INSERT INTO estrutura_tmp
       VALUES(mr_tela.oc_linha,
              ma_tela[pa_curr].cod_item,
              p_cod_pai_imediato,
              p_cod_item_compon,
              p_qtd_acumulada,
              p_qtd_mat_prima,0)

      IF STATUS <> 0 THEN
         CALL log003_err_sql("INCLUSAO","estrutura_tmp") 
         RETURN FALSE
      END IF
   END IF
   
   LET p_qtd_acumulada = 1
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol0584_pega_estq_c_ocl()
#---------------------------------#

   LET p_qtd_mat_prima = 0
   LET p_sdo_mat_pri  = 0
   
   DECLARE cq_itterc CURSOR FOR
    SELECT UNIQUE
           a.num_nf,
           a.ser_nf,
           a.ssr_nf,
           a.num_sequencia,
           a.dat_emis_nf,
           b.qtd_receb,
           b.qtd_consumida,
           a.ies_especie_nf
      FROM item_de_terc a,
           sup_item_terc_end b 
     WHERE b.empresa          = p_cod_empresa
       AND b.lote             = mr_tela.oc_linha
       AND a.num_nf           = b.nota_fiscal
       AND a.ser_nf           = b.serie_nota_fiscal
       AND a.ssr_nf           = b.subserie_nf
       AND a.ies_especie_nf   = b.espc_nota_fiscal
       AND a.num_sequencia    = b.seq_aviso_recebto
       AND a.cod_fornecedor   = b.fornecedor
       AND a.cod_empresa      = b.empresa
       AND a.cod_fornecedor   = p_cod_cliente
       AND a.cod_item         = p_cod_item_compon
       AND b.item             = a.cod_item
     ORDER BY a.dat_emis_nf
 
    FOREACH cq_itterc INTO p_item_de_terc.*, p_ies_especie_nf
    
       LET p_qtd_saldo = p_item_de_terc.qtd_tot_recebida - 
                         p_item_de_terc.qtd_tot_devolvida
      
       CALL pol0584_calcula_ja_devolvida()
     
       LET p_qtd_saldo = p_qtd_saldo - p_qtd_devolvida 
 
       IF p_qtd_saldo > 0 THEN
          LET p_qtd_mat_prima = p_qtd_mat_prima + p_qtd_saldo
       END IF
 
    END FOREACH
    
    LET p_sdo_mat_pri = p_qtd_mat_prima
 
END FUNCTION

#---------------------------------#
FUNCTION pol0584_pega_estq_s_ocl()
#---------------------------------#

   LET p_qtd_mat_prima = 0
   LET p_sdo_mat_pri  = 0
   
   DECLARE cq_it_terc CURSOR FOR
    SELECT num_nf,
           ser_nf,
           ssr_nf,
           num_sequencia,
           dat_emis_nf,
           qtd_tot_recebida,
           qtd_tot_devolvida,
           ies_especie_nf
      FROM item_de_terc 
     WHERE cod_empresa      = p_cod_empresa
       AND cod_fornecedor   = p_cod_cliente
       AND cod_item         = p_cod_item_compon
     ORDER BY dat_emis_nf
 
    FOREACH cq_it_terc INTO p_item_de_terc.*, p_ies_especie_nf
    
       LET p_qtd_saldo = p_item_de_terc.qtd_tot_recebida - 
                         p_item_de_terc.qtd_tot_devolvida

 
       CALL pol0584_calcula_ja_devolvida()
     
       LET p_qtd_saldo = p_qtd_saldo - p_qtd_devolvida 
 
       IF p_qtd_saldo > 0 THEN
          LET p_qtd_mat_prima = p_qtd_mat_prima + p_qtd_saldo
       END IF
 
    END FOREACH

    LET p_sdo_mat_pri = p_qtd_mat_prima
 
END FUNCTION

#--------------------------------#
FUNCTION pol0584_le_item_altern()
#--------------------------------#
   
   DEFINE p_qtd_neces LIKE item_altern.qtd_necessaria
   
   LET p_tem_altern = FALSE
   
   DECLARE cq_altern CURSOR FOR
    SELECT cod_item_altern,
           qtd_necessaria
      FROM item_altern
     WHERE cod_empresa     = p_cod_empresa
       AND cod_item_pai    = p_cod_pai_imediato
       AND cod_item_compon = p_cod_item_altern
       
   FOREACH cq_altern INTO
           p_cod_item_compon,
           p_qtd_neces

      IF p_ies_oclinha THEN
         CALL pol0584_pega_estq_c_ocl()
         IF p_sdo_mat_pri > 0 THEN
            LET p_qtd_acumulada = p_sdo_mat_pri / p_sdo_pedido
         END IF
      ELSE
         CALL pol0584_pega_estq_s_ocl() 
      END IF

      IF p_sdo_mat_pri > 0 THEN
         LET p_tem_altern = TRUE
         EXIT FOREACH
      END IF
      
   END FOREACH

END FUNCTION

#-------------------------------------#
FUNCTION pol0584_calcula_ja_devolvida()
#-------------------------------------#

   DEFINE p_qtd_dev_om LIKE ordem_montag_tran.qtd_devolvida,
          p_qtd_dev_sl LIKE fit_terc_ret.qtd_devolvida
          
   SELECT SUM(qtd_devolvida)
     INTO p_qtd_dev_sl
     FROM fat_retn_terc_grd
    WHERE empresa            = p_cod_empresa           
      AND nf_entrada         = p_item_de_terc.num_nf
      AND serie_nf_entrada   = p_item_de_terc.ser_nf
      AND subserie_nfe       = p_item_de_terc.ssr_nf
      AND especie_nf_entrada = p_ies_especie_nf
      AND seq_aviso_recebto  = p_item_de_terc.num_sequencia
      AND fornecedor         = p_cod_cliente
      AND nota_fiscal        = 0

   IF p_qtd_dev_sl IS NULL THEN
      LET p_qtd_dev_sl = 0
   END IF

   SELECT SUM(qtd_devolvida)
     INTO p_qtd_dev_om
     FROM ldi_retn_terc_grd a,
          ordem_montag_mest b
    WHERE a.empresa            = p_cod_empresa           
      AND a.nf_entrada         = p_item_de_terc.num_nf
      AND a.serie_nf_entrada   = p_item_de_terc.ser_nf
      AND a.subserie_nfe       = p_item_de_terc.ssr_nf
      AND a.especie_nf_entrada = p_ies_especie_nf
      AND a.seq_aviso_recebto  = p_item_de_terc.num_sequencia
      AND a.fornecedor         = p_cod_cliente
      AND b.cod_empresa        = a.empresa
      AND b.num_om             = a.ord_montag 
      AND b.ies_sit_om        <> "F"  
   
   IF p_qtd_dev_om IS NULL THEN
      LET p_qtd_dev_om = 0
   END IF

   LET p_qtd_devolvida = p_qtd_dev_om + p_qtd_dev_sl
   
END FUNCTION

#------------------------------#
FUNCTION pol0584_tem_material()
#------------------------------#

   DEFINE p_qtd_necessaria LIKE estrutura.qtd_necessaria,
          p_qtd_em_estoque LIKE estrutura.qtd_necessaria
          
   LET p_erro = FALSE
   
   DECLARE cq_estru CURSOR FOR
   SELECT cod_item_compon,
          qtd_necessaria,
          qtd_em_estoque
     FROM estrutura_tmp
    WHERE oc_linha     =  mr_tela.oc_linha
      AND cod_item_pai = ma_tela[pa_curr].cod_item
      AND cod_item_compon NOT IN
          (SELECT cod_item FROM ite_s_oclinha_1040
            WHERE cod_empresa = p_cod_empresa)

   FOREACH cq_estru INTO
           p_cod_item_compon,
           p_qtd_necessaria,
           p_qtd_em_estoque

      IF p_ies_oclinha THEN
         SELECT cod_item 
           FROM item_emprest_1040
          WHERE cod_empresa   = p_cod_empresa
            AND oc_linha_orig = mr_tela.oc_linha
            AND cod_item      = p_cod_item_compon
         IF STATUS = 0 THEN
            CONTINUE FOREACH
         END IF
         
      END IF
   
      IF p_qtd_em_estoque <= 0 THEN
         RETURN FALSE
      END IF
      
      LET p_tot_necessaria = p_qtd_necessaria * p_tot_reser
      
      IF p_qtd_em_estoque  < p_tot_necessaria THEN
         
         IF NOT p_ies_oclinha THEN
            RETURN FALSE
         END IF
         
         LET p_difer = p_tot_necessaria - p_qtd_em_estoque
         
         IF p_difer >= p_qtd_necessaria THEN
            RETURN FALSE
         END IF
      END IF
      
      LET p_difer = 0
      
      IF p_qtd_em_estoque  > p_tot_necessaria THEN
         LET p_difer = p_qtd_em_estoque - p_tot_necessaria
         IF p_difer < p_qtd_necessaria THEN
            UPDATE estrutura_tmp
               SET qtd_sobra = p_difer
             WHERE oc_linha        = mr_tela.oc_linha
               AND cod_item_pai    = ma_tela[pa_curr].cod_item
               AND cod_item_compon = p_cod_item_compon
         END IF
      END IF
      
   END FOREACH
           
   RETURN TRUE      
 
END FUNCTION

#---------------------------------#
FUNCTION pol0584_gera_retorno_mp()
#---------------------------------#
   
   DEFINE p_ies_ctr_lote  LIKE item.ies_ctr_lote,
          p_qtd_receb     LIKE sup_item_terc_end.qtd_receb,
          p_qtd_consumida LIKE sup_item_terc_end.qtd_consumida
   
   LET p_val_tot_mat = 0

   DECLARE cq_estrutura CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           qtd_sobra
      FROM estrutura_tmp
     WHERE oc_linha     = mr_tela.oc_linha
       AND cod_item_pai = p_cod_item_pai
       AND cod_item_compon NOT IN
          (SELECT cod_item FROM ite_s_oclinha_1040
            WHERE cod_empresa = p_cod_empresa)

   FOREACH cq_estrutura INTO
           p_cod_item_compon,
           p_qtd_necessaria,
           p_qtd_sobra

      IF p_ies_oclinha THEN
         SELECT cod_item 
           FROM item_emprest_1040
          WHERE cod_empresa   = p_cod_empresa
            AND oc_linha_orig = mr_tela.oc_linha
            AND cod_item      = p_cod_item_compon
         IF STATUS = 0 THEN
            CONTINUE FOREACH
         END IF
      END IF
           
      LET p_tot_necessaria = (p_qtd_necessaria * p_qtd_sel_item) + p_qtd_sobra
      LET p_gravou = FALSE
      
      IF p_ies_oclinha THEN
         LET sql_stmt = 
		          "SELECT",
		          " nota_fiscal,",
		          " serie_nota_fiscal,",
		          " subserie_nf,",
		          " seq_aviso_recebto,",
		          " seq_tabulacao,",
		          " espc_nota_fiscal,",
		          " lote, ",
		          " serie, ",
		          " qtd_receb,",
		          " qtd_consumida",
		          "  FROM sup_item_terc_end  ", 
		          " WHERE empresa        ='",p_cod_empresa,"'",
		          "   AND lote           ='",mr_tela.oc_linha,"'",
		          "   AND fornecedor     ='",p_cod_cliente,"'",
		          "   AND item           ='",p_cod_item_compon,"'",
		          " ORDER BY aviso_recebto, seq_tabulacao"

      ELSE
         LET sql_stmt = 
		          "SELECT",
		          " nota_fiscal,",
		          " serie_nota_fiscal,",
		          " subserie_nf,",
		          " seq_aviso_recebto,",
		          " seq_tabulacao,",
		          " espc_nota_fiscal,",
		          " lote, ",
		          " serie, ",
		          " qtd_receb,",
		          " qtd_consumida",
		          "  FROM sup_item_terc_end  ", 
		          " WHERE empresa        ='",p_cod_empresa,"'",
		          "   AND fornecedor     ='",p_cod_cliente,"'",
		          "   AND item           ='",p_cod_item_compon,"'",
		          " ORDER BY aviso_recebto, seq_tabulacao"
      END IF

      PREPARE var_query FROM sql_stmt
      
      DECLARE cq_sup_terc CURSOR FOR var_query

      FOREACH cq_sup_terc INTO 
               p_item_de_terc.num_nf,
               p_item_de_terc.ser_nf,
               p_item_de_terc.ssr_nf,
               p_item_de_terc.num_sequencia,
               p_seq_tabulacao,
               p_ies_especie_nf,
               p_lote,
               p_serie,
               p_qtd_receb,               
               p_qtd_consumida
    
          LET p_qtd_saldo = p_qtd_receb - p_qtd_consumida

          IF p_qtd_saldo <= 0 THEN 
             CONTINUE FOREACH
          END IF
          
          CALL pol0584_ve_devolucao()
     
          LET p_qtd_saldo = p_qtd_saldo - p_qtd_devolvida 
 
          IF p_qtd_saldo <= 0 THEN
             CONTINUE FOREACH
          END IF

          SELECT val_remessa,
                 qtd_tot_recebida
            INTO p_val_remessa,
                 p_qtd_tot_recebida
            FROM item_de_terc
           WHERE cod_empresa    = p_cod_empresa
						 AND num_nf         = p_item_de_terc.num_nf
						 AND ser_nf         = p_item_de_terc.ser_nf
						 AND ssr_nf         = p_item_de_terc.ssr_nf
						 AND ies_especie_nf = p_ies_especie_nf
						 AND cod_fornecedor = p_cod_cliente
						 AND num_sequencia  = p_item_de_terc.num_sequencia
          
          IF STATUS <> 0 THEN
             CALL log003_err_sql("LEITURA","ITEM_DE_TERC")
             RETURN FALSE
          END IF

          IF p_qtd_tot_recebida > 0 THEN
             LET p_pre_unit = p_val_remessa / p_qtd_tot_recebida
          ELSE
             LET p_pre_unit = 0
          END IF

          IF p_qtd_saldo <= p_tot_necessaria THEN
             LET p_qtd_gravar = p_qtd_saldo
             LET p_tot_necessaria = p_tot_necessaria - p_qtd_gravar
          ELSE
             LET p_qtd_gravar = p_tot_necessaria
             LET p_tot_necessaria = 0
          END IF

          IF p_processo = 'R' THEN
             IF NOT pol0584_insere_ldi_terc() THEN
                RETURN FALSE
             END IF
          ELSE
             IF NOT insere_fat_terc() THEN
                RETURN FALSE
             END IF
          END IF
          
          LET p_gravou = TRUE
          
          IF p_tot_necessaria = 0 THEN
             EXIT FOREACH
          END IF
                    
      END FOREACH
      
      IF p_tot_necessaria > p_qtd_necessaria THEN
         CALL log0030_mensagem('Não há material suficiente p/ devolver', 'excla')
         RETURN FALSE
      END IF
          
      IF p_gravou THEN
         IF p_processo = 'R' THEN
            IF NOT insere_montag_tran() THEN
               RETURN FALSE
            END IF
         ELSE
            IF NOT insere_fit_terc_ret() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0584_ve_devolucao()
#------------------------------#

   DEFINE p_qtd_dev_om LIKE ordem_montag_tran.qtd_devolvida,
          p_qtd_dev_sl LIKE fit_terc_ret.qtd_devolvida

   SELECT SUM(qtd_devolvida)
     INTO p_qtd_dev_sl
     FROM fat_retn_terc_grd
    WHERE empresa            = p_cod_empresa           
      AND nf_entrada         = p_item_de_terc.num_nf
      AND serie_nf_entrada   = p_item_de_terc.ser_nf
      AND subserie_nfe       = p_item_de_terc.ssr_nf
      AND especie_nf_entrada = p_ies_especie_nf
      AND seq_aviso_recebto  = p_item_de_terc.num_sequencia
      AND seq_tabulacao      = p_seq_tabulacao
      AND fornecedor         = p_cod_cliente
      AND nota_fiscal        = 0

   IF p_qtd_dev_sl IS NULL THEN
      LET p_qtd_dev_sl = 0
   END IF

   SELECT SUM(qtd_devolvida)
     INTO p_qtd_dev_om
     FROM ldi_retn_terc_grd a,
          ordem_montag_mest b
    WHERE a.empresa            = p_cod_empresa           
      AND a.nf_entrada         = p_item_de_terc.num_nf
      AND a.serie_nf_entrada   = p_item_de_terc.ser_nf
      AND a.subserie_nfe       = p_item_de_terc.ssr_nf
      AND a.especie_nf_entrada = p_ies_especie_nf
      AND a.seq_aviso_recebto  = p_item_de_terc.num_sequencia
      AND a.seq_tabulacao      = p_seq_tabulacao
      AND a.fornecedor         = p_cod_cliente
      AND b.cod_empresa        = a.empresa
      AND b.num_om             = a.ord_montag 
      AND b.ies_sit_om        <> "F"  
   
   IF p_qtd_dev_om IS NULL THEN
      LET p_qtd_dev_om = 0
   END IF

   LET p_qtd_devolvida = p_qtd_dev_om + p_qtd_dev_sl
   
END FUNCTION

#---------------------------------#
FUNCTION pol0584_insere_ldi_terc()
#---------------------------------#

   INSERT INTO ldi_retn_terc_grd 
     VALUES(p_cod_empresa,
            mr_ordem_montag_item.num_om,
            mr_ordem_montag_item.num_pedido,
            mr_ordem_montag_item.num_sequencia,
            0,0,0,0,0,
	          p_item_de_terc.num_nf,
	          p_item_de_terc.ser_nf,
	          p_item_de_terc.ssr_nf,
	          p_ies_especie_nf,
	          p_cod_cliente,
	          p_item_de_terc.num_sequencia,
	          p_seq_tabulacao,
	          p_qtd_gravar,
	          p_pre_unit,
	          p_cod_nat_oper,
	          0)
	          
	 IF SQLCA.SQLCODE <> 0 THEN 
	    CALL log003_err_sql("INCLUSAO","LDI_RETN_TERC_GRD")
	    RETURN FALSE
	 END IF

   INSERT INTO nf_tmp_1040
   VALUES(p_item_de_terc.num_nf,
          p_item_de_terc.ser_nf,
          p_item_de_terc.ssr_nf,
          p_ies_especie_nf,
          p_item_de_terc.num_sequencia,
          p_qtd_gravar,
          p_pre_unit,
          p_serie)

	 IF SQLCA.SQLCODE <> 0 THEN 
	    CALL log003_err_sql("INCLUSAO","NF_TMP_1040")
	    RETURN FALSE
	 END IF

   RETURN TRUE
  
END FUNCTION

#----------------------------#
FUNCTION insere_montag_tran()
#----------------------------#

  LET p_ordem_montag_tran.cod_empresa    = p_cod_empresa
  LET p_ordem_montag_tran.num_om         = mr_ordem_montag_item.num_om
  LET p_ordem_montag_tran.num_pedido     = mr_ordem_montag_item.num_pedido
  LET p_ordem_montag_tran.num_seq_item   = mr_ordem_montag_item.num_sequencia
  LET p_ordem_montag_tran.cod_item       = p_cod_item_compon
  LET p_ordem_montag_tran.cod_nat_oper   = p_cod_nat_oper

  DECLARE cq_tran CURSOR FOR
   SELECT num_nf,
          ser_nf,
          ssr_nf,
          esp_nf,
          num_seq,
          pre_unit,
      SUM (qtd_item)
     FROM nf_tmp_1040
    GROUP BY num_nf,
		         ser_nf,
		         ssr_nf,
		         esp_nf,
		         num_seq,
		         pre_unit

  FOREACH cq_tran INTO 
          p_ordem_montag_tran.num_nf,
          p_ordem_montag_tran.ser_nf,
          p_ordem_montag_tran.ssr_nf,    
          p_ordem_montag_tran.ies_especie_nf,
          p_ordem_montag_tran.num_seq_nf,
          p_ordem_montag_tran.pre_unit,
          p_ordem_montag_tran.qtd_devolvida

     LET p_ordem_montag_tran.num_transacao  = 0
  
     INSERT INTO ordem_montag_tran 
       VALUES (p_ordem_montag_tran.*)
  
     IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_TRAN")
        RETURN FALSE
     END IF

     LET p_num_trans = SQLCA.SQLERRD[2]

     INSERT INTO ldi_om_trfor_inf_c 
       VALUES (p_ordem_montag_tran.cod_empresa,
               p_num_trans,
               p_cod_cliente)

     IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("INCLUSAO","LDI_OM_TRFOR_INF_C")
        RETURN FALSE
     END IF

  END FOREACH
  
  DELETE FROM nf_tmp_1040
  
  IF SQLCA.SQLCODE <> 0 THEN 
     CALL log003_err_sql("DELEÇÃO","NF_TMP_1040")
     RETURN FALSE
  END IF
   
  RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION insere_fat_terc()
#-------------------------#

   INSERT INTO fat_retn_terc_grd 
    VALUES(p_cod_empresa,
          m_num_solicit,
          0,                         #nota_fiscal
          0,                         #serie_nota_fiscal
          0,                         #pedido
          1,                         #seq_item_pedido
          0,                         #ord_montag
          0,0,0,0,0,                 #grade_1 ate 3
          p_item_de_terc.num_nf,
          p_item_de_terc.ser_nf,
          p_item_de_terc.ssr_nf,
          p_ies_especie_nf,
          p_cod_cliente,
          p_item_de_terc.num_sequencia,
          p_seq_tabulacao,
          p_qtd_gravar,
          NULL,               
          p_user,
          0)
          
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","LDI_RETN_TERC_GRD")
      RETURN FALSE
   END IF

   INSERT INTO nf_tmp_1040
   VALUES(p_item_de_terc.num_nf,
          p_item_de_terc.ser_nf,
          p_item_de_terc.ssr_nf,
          p_ies_especie_nf,
          p_item_de_terc.num_sequencia,
          p_qtd_gravar,
          p_pre_unit,
          p_serie)

	 IF SQLCA.SQLCODE <> 0 THEN 
	    CALL log003_err_sql("INCLUSAO","NF_TMP_1040")
	    RETURN FALSE
	 END IF

  RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION insere_fit_terc_ret()
#-----------------------------#

   LET p_tex_observ = mr_tela.num_pedido
   LET p_tex_observ = p_tex_observ CLIPPED, '/', p_cod_item_compon

   LET p_fit_terc_ret.cod_empresa = p_cod_empresa
   LET p_fit_terc_ret.num_solicit = m_num_solicit
   LET p_fit_terc_ret.tex_observ = p_tex_observ
   LET p_fit_terc_ret.nom_usuario = p_user
   
   DECLARE cq_fat_terc CURSOR FOR
   SELECT num_nf,
          ser_nf,
          ssr_nf,
          esp_nf,
          num_seq,
          pre_unit,
      SUM (qtd_item)
     FROM nf_tmp_1040
    GROUP BY num_nf,
		         ser_nf,
		         ssr_nf,
		         esp_nf,
		         num_seq,
		         pre_unit
               
   FOREACH cq_fat_terc INTO 
           p_fit_terc_ret.num_nf,
           p_fit_terc_ret.ser_nf,
           p_fit_terc_ret.ssr_nf,
           p_fit_terc_ret.ies_especie_nf,
           p_fit_terc_ret.num_sequencia,
           p_pre_unit,
           p_qtd_gravar

      LET p_num_item = p_num_item + 1
      LET p_fit_terc_ret.num_item = p_num_item
   
{      INSERT INTO fit_terc_ret
        VALUES(p_fit_terc_ret.*)
            
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","FIT_TERC_RET")
         RETURN FALSE
      END IF
}  
      LET p_cod_prod = p_cod_item_compon
   
      CALL pol0584_le_item()

      LET m_pct_ipi = 0
      LET p_ies_tributa_ipi = 'N'
      LET m_val_ipi = 0
      LET m_val_icm = 0

      LET p_val_mat = p_qtd_gravar * p_pre_unit
      LET p_val_tot_mat = p_val_tot_mat + p_val_mat

      INSERT INTO fit_itemes
      VALUES (p_cod_empresa, 
           m_num_solicit, 
           p_num_item,
           p_cod_item_compon,
           m_den_item, 
           m_cod_unid_med, 
           m_pes_unit, 
           m_cod_cla_fisc, 
           m_pct_ipi, 
           p_ies_tributa_ipi,
           1, 
           p_qtd_gravar, 
           p_pre_unit, 
           p_val_mat, 
           m_val_ipi, 
           p_user,
           0)
  
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","FIT_ITEMES")
         RETURN FALSE
      END IF

      LET p_cod_nat_oper = p_parametros_1040.nat_oper_mat_rej
   
      IF NOT pol0584_le_fiscal() THEN
         RETURN FALSE
      END IF
   
      INSERT INTO fit_itemes_fiscal
      VALUES (p_cod_empresa, 
           m_num_solicit, 
           p_num_item,
           p_cod_nat_oper, 
           mr_fiscal_par.ies_incid_ipi,
           mr_fiscal_par.ies_incid_icm,
           mr_fiscal_par.pct_icm_contrib,
           mr_fiscal_par.pct_desc_b_icm_c,
           mr_fiscal_par.cod_fiscal,
           mr_fiscal_par.cod_origem,
           mr_fiscal_par.cod_tributacao,
           mr_fiscal_par.pct_desc_base_ipi,
           mr_fiscal_par.pct_cred_icm,
           mr_fiscal_par.tax_red_pct_icm,
           mr_fiscal_par.pct_desc_ipi, 0, 0 , 0, 0,
           p_val_mat, m_val_ipi, p_val_mat,
           m_val_icm, 0, 0, 0, 0, 0, 0, p_user) 

      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","FIT_ITEMES_FISCAL")
         RETURN FALSE
      END IF

   END FOREACH

  DELETE FROM nf_tmp_1040
  
  IF SQLCA.SQLCODE <> 0 THEN 
     CALL log003_err_sql("DELEÇÃO","NF_TMP_1040")
     RETURN FALSE
  END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION pol0584_processar()
#---------------------------#

   CALL log085_transacao("COMMIT") #fecha a transação aberta no bloqueio do pedido
   
   LET p_men = NULL
   
   IF p_om THEN
      CALL log085_transacao("BEGIN") 
      IF NOT pol0584_processa_om() THEN
         CALL log085_transacao("ROLLBACK") 
         LET p_men = 'Operação Cancelada'
         RETURN FALSE
      END IF
      DISPLAY l_num_om TO num_om
      CALL log085_transacao("COMMIT") 
      LET p_men = 'Romaneio Gerado c/ Sucesso'
   END IF

   IF p_sl THEN
      CALL log085_transacao("BEGIN") 
      IF NOT pol0584_processa_sl() THEN
         CALL log085_transacao("ROLLBACK") 
         LET p_men = p_men CLIPPED, ' - Solicitação de Faturamento Cancelada'
         RETURN FALSE
      END IF
      CALL log085_transacao("COMMIT") 
      IF p_men IS NOT NULL THEN
         LET p_men = 'Romaneio e Solicitação de Faturamento Gerados c/ Sucesso'
      ELSE
         LET p_men = 'Solicitação de Faturamento Gerada c/ Sucesso'
      END IF
      DISPLAY m_num_solicit TO num_sl
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol0584_processa_om()
#-----------------------------#

   DEFINE l_peso_unit         LIKE item.pes_unit,
          l_qtd_padr_embal    LIKE item_embalagem.qtd_padr_embal,
          l_cod_tip_carteira  LIKE pedidos.cod_tip_carteira,
          l_cont              SMALLINT,
          l_qtd_volume        LIKE ordem_montag_mest.qtd_volume_om,
          l_cod_embal_matriz  LIKE embalagem.cod_embal_matriz,
          l_cod_embal_int     LIKE item_embalagem.cod_embal,
          l_qtd_vol           CHAR(10)

   MESSAGE "Processando a Criação da OM..." ATTRIBUTE(REVERSE)
   
   LET l_num_lote = mr_tela.num_lote
   
   LET l_cont     = 0

   WHENEVER ERROR CONTINUE   

   SELECT num_ult_om
     INTO l_num_om
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF l_num_om IS NULL THEN
      LET l_num_om = 1
   ELSE
      LET l_num_om = l_num_om + 1
   END IF

   LET l_qtd_volume = 0
   
   FOR l_ind = 1 TO p_qtd_itens
      IF ma_tela[l_ind].qtd_reservada <= 0 THEN
         CONTINUE FOR
      END IF

      LET l_cont = l_cont + 1       
      
      INITIALIZE l_cod_embal_matriz to NULL

      SELECT a.qtd_padr_embal, 
             a.cod_embal, 
             b.cod_embal_matriz
        INTO l_qtd_padr_embal, 
             l_cod_embal_int, 
             l_cod_embal_matriz
        FROM item_embalagem a, 
             embalagem b
       WHERE a.cod_empresa   = p_cod_empresa
         AND a.cod_cliente   = mr_pedidos.cod_cliente
         AND a.cod_item      = ma_tela[l_ind].cod_item
         AND a.cod_embal     = b.cod_embal
         AND a.ies_tip_embal IN ('I','N')

      IF SQLCA.SQLCODE <> 0 THEN   
         LET l_qtd_padr_embal = 0
         LET l_cod_embal_int  = 0
      ELSE
         IF l_cod_embal_matriz IS NOT NULL THEN
            LET l_cod_embal_int = l_cod_embal_matriz
         END IF 	     
      END IF
      
      SELECT pes_unit
        INTO l_peso_unit 
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_tela[l_ind].cod_item

      IF l_qtd_padr_embal > 0 THEN
         LET l_qtd_vol = ma_tela[l_ind].qtd_reservada / 
                         l_qtd_padr_embal USING '&&&&&&&.&&'

         LET mr_ordem_montag_item.qtd_volume_item = l_qtd_vol[1,7]
      
         IF l_qtd_vol[9,10] > 0 THEN
            LET mr_ordem_montag_item.qtd_volume_item = 
                mr_ordem_montag_item.qtd_volume_item + 1
         END IF
      ELSE
         LET mr_ordem_montag_item.qtd_volume_item = 0
      END IF
      
      LET mr_ordem_montag_item.cod_empresa     = p_cod_empresa
      LET mr_ordem_montag_item.num_om          = l_num_om
      LET mr_ordem_montag_item.num_pedido      = mr_tela.num_pedido
      LET mr_ordem_montag_item.num_sequencia   = ma_tela[l_ind].num_sequencia 
      LET mr_ordem_montag_item.cod_item        = ma_tela[l_ind].cod_item
      LET mr_ordem_montag_item.qtd_reservada   = ma_tela[l_ind].qtd_reservada
      LET mr_ordem_montag_item.ies_bonificacao = 'N'
      LET mr_ordem_montag_item.pes_total_item  = ma_tela[l_ind].qtd_reservada * l_peso_unit

      INSERT INTO ordem_montag_item VALUES (mr_ordem_montag_item.*)

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_ITEM") 
         RETURN FALSE
      END IF

      UPDATE ped_itens 
         SET qtd_pecas_romaneio = qtd_pecas_romaneio + mr_ordem_montag_item.qtd_reservada
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = mr_ordem_montag_item.num_pedido
         AND num_sequencia = mr_ordem_montag_item.num_sequencia
        
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("ALTERACAO","PED_ITENS") 
         RETURN FALSE
      END IF
      
      LET l_qtd_volume = l_qtd_volume + mr_ordem_montag_item.qtd_volume_item
      
      INSERT INTO ordem_montag_embal 
         VALUES(p_cod_empresa,
                mr_ordem_montag_item.num_om,
	        1,	
                mr_ordem_montag_item.cod_item,
                l_cod_embal_int,
                mr_ordem_montag_item.qtd_volume_item,
                0,
                0,
                'T',
                1,
                1,
                mr_ordem_montag_item.qtd_reservada)

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_EMBAL") 
         RETURN FALSE
      END IF

      IF p_ies_bene THEN
         LET p_cod_nat_oper = p_parametros_1040.nat_oper_mat_boa
         LET p_qtd_sel_item = ma_tela[l_ind].qtd_reservada
         LET p_cod_item_pai = ma_tela[l_ind].cod_item
         LET p_processo = 'R'
         IF NOT pol0584_gera_retorno_mp() THEN
            RETURN FALSE
         END IF
      END IF

      IF ma_item[l_ind].ctr_estoque <> 'S' THEN
         CONTINUE FOR
      END IF

      UPDATE estoque
         SET qtd_reservada = 
             qtd_reservada +  mr_ordem_montag_item.qtd_reservada
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_ordem_montag_item.cod_item
 
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("ALTERACAO","ESTOQUE") 
         RETURN FALSE
      END IF
            
      DECLARE cq_lote CURSOR FOR
      SELECT cod_item,
             cod_local,
             num_lote,
             num_transac,
             SUM(qtd_reservada)
      FROM w_lote
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = ma_tela[l_ind].cod_item 
        AND num_seq  = ma_tela[l_ind].num_sequencia
        AND tip_peca = 'B'
      GROUP BY 1,2,3,4

      FOREACH cq_lote INTO 
              mr_estoque_lote.cod_item,
              mr_estoque_lote.cod_local,
              mr_estoque_lote.num_lote,
              p_num_transac,
              mr_estoque_loc_reser.qtd_reservada
                    
         LET mr_estoque_loc_reser.num_reserva = 0
      
         INSERT INTO estoque_loc_reser 
           VALUES(p_cod_empresa,
                  mr_estoque_loc_reser.num_reserva,
                  mr_estoque_lote.cod_item,
                  mr_estoque_lote.cod_local,
                  mr_estoque_loc_reser.qtd_reservada,
                  mr_estoque_lote.num_lote,
                  "P",
                  NULL,
                  NULL,
                  "N",
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  TODAY,
                  NULL,
                  NULL,
                  0,
                  NULL)
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO","ESTOQUE_LOC_RESER:1")
            RETURN FALSE
         END IF

         LET l_num_reserva = SQLCA.SQLERRD[2]

         IF NOT pol0584_ins_reser_end() THEN
            RETURN FALSE
         END IF

         INSERT INTO ordem_montag_grade
            VALUES(p_cod_empresa,
                   l_num_om,
                   mr_tela.num_pedido,
                   ma_tela[l_ind].num_sequencia,
                   mr_estoque_lote.cod_item,
                   mr_estoque_loc_reser.qtd_reservada,
                   l_num_reserva,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL)
          
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_GRADE")
            RETURN FALSE
         END IF


      END FOREACH

   END FOR

   IF l_cont > 0 THEN
      SELECT cod_tip_carteira
        INTO l_cod_tip_carteira
        FROM pedidos
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = mr_ordem_montag_item.num_pedido
      
      LET mr_ordem_montag_mest.cod_empresa   = p_cod_empresa
      LET mr_ordem_montag_mest.num_om        = l_num_om
      LET mr_ordem_montag_mest.num_lote_om   = l_num_lote
      LET mr_ordem_montag_mest.ies_sit_om    = 'N'
      LET mr_ordem_montag_mest.cod_transpor  = mr_tela.cod_transpor
      LET mr_ordem_montag_mest.qtd_volume_om = l_qtd_volume
      LET mr_ordem_montag_mest.dat_emis      = TODAY 

      INSERT INTO ordem_montag_mest VALUES (mr_ordem_montag_mest.*)

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_MEST") 
         RETURN FALSE
      END IF
      
      INSERT INTO om_list 
         VALUES (p_cod_empresa,
                 mr_ordem_montag_mest.num_om,
                 mr_ordem_montag_item.num_pedido,
                 TODAY,
                 p_user)

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("INCLUSAO","OM_LIST") 
         RETURN FALSE
      END IF

      IF mr_tela.cod_transpor IS NULL THEN
         LET mr_tela.cod_transpor = '0' 
      END IF   

      IF NOT p_dig_lote THEN
         INSERT INTO ordem_montag_lote 
         VALUES(p_cod_empresa,
                l_num_lote,
                'N',
                 mr_tela.cod_transpor,
                 TODAY,
                 0,
                 l_cod_tip_carteira,
                 mr_tela.num_placa,
                 0,
                 0,
                 0)

         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_LOTE") 
             RETURN FALSE
         END IF
      END IF
      
      UPDATE par_vdp
         SET num_ult_om = l_num_om
       WHERE cod_empresa = p_cod_empresa 
 
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("ALTERACAO","PAR_VDP") 
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0584_processa_sl()
#-----------------------------#

   MESSAGE 'Processando a Solicitação de Faturamento'

   LET p_cod_nat_oper = p_parametros_1040.nat_oper_fat_rej
   LET p_cod_cnd_pgto = p_parametros_1040.cnd_pgto_fat_rej
   
   SELECT cod_uni_feder  
     INTO m_cod_uni_feder
     FROM clientes a,cidades b
    WHERE a.cod_cliente = p_cod_cliente
      AND a.cod_cidade  = b.cod_cidade
   
   IF NOT pol0584_gera_solic_fat() THEN
      RETURN FALSE
   END IF

   LET m_val_tot_liq = 0
   LET m_val_tot_base = 0
   LET m_val_tot_ipi = 0
   LET m_val_tot_icm = 0
   LET p_num_item    = 0
   
   FOR p_ind = 1 TO p_qtd_itens

       IF ma_tela[p_ind].reser_rej <= 0 THEN
          CONTINUE FOR
       END IF

      LET p_cod_nat_oper = p_parametros_1040.nat_oper_fat_rej

      IF NOT pol0584_grava_itemes() THEN
         RETURN FALSE
      END IF
      
      UPDATE ped_itens
         SET qtd_pecas_atend = qtd_pecas_atend + ma_tela[p_ind].reser_rej
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = mr_tela.num_pedido
         AND num_sequencia = ma_tela[p_ind].num_sequencia

      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("UPDATE","PED_ITENS")
         RETURN FALSE
      END IF
      
      SELECT cod_empresa
        FROM fat_pc_rejei_1040
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = mr_tela.num_pedido
         AND num_sequencia = ma_tela[p_ind].num_sequencia
      
      IF STATUS = 100 THEN
         INSERT INTO fat_pc_rejei_1040
          VALUES(p_cod_empresa, 
                 mr_tela.num_pedido,
                 ma_tela[p_ind].num_sequencia,
                 ma_tela[p_ind].cod_item,
                 ma_tela[p_ind].reser_rej)
      ELSE
         IF STATUS = 0 THEN
            UPDATE fat_pc_rejei_1040
               SET qtd_faturada = qtd_faturada + ma_tela[p_ind].reser_rej
             WHERE cod_empresa   = p_cod_empresa
               AND num_pedido    = mr_tela.num_pedido
               AND num_sequencia = ma_tela[p_ind].num_sequencia
         ELSE
            CALL log003_err_sql("LEITURA","FAT_PC_REJEI_1040")
            RETURN FALSE
         END IF               
      END IF

      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("ATUALIZANDO","FAT_PC_REJEI_1040")
         RETURN FALSE
      END IF

      IF ma_item[p_ind].ctr_estoque <> 'S' THEN
         CONTINUE FOR
      END IF

      IF NOT pol0584_insere_reserva() THEN
         RETURN FALSE
      END IF
      
      UPDATE estoque
         SET qtd_reservada = qtd_reservada + ma_tela[p_ind].reser_rej
       WHERE cod_empresa  = p_cod_empresa
         AND cod_item     = ma_tela[p_ind].cod_item

      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("UPDATE","ESTOQUE")
         RETURN FALSE
      END IF

      
   END FOR

   LET p_cod_nat_oper = p_parametros_1040.nat_oper_mat_rej

   FOR p_ind = 1 TO p_qtd_itens

      LET p_qtd_sel_item = ma_tela[p_ind].reser_rej
      LET p_cod_item_pai = ma_tela[p_ind].cod_item
      LET p_processo = 'S'

      IF NOT pol0584_gera_retorno_mp() THEN
         RETURN FALSE
      END IF

   END FOR

   IF NOT pol0584_grava_total() THEN
      RETURN FALSE
   END IF

   IF NOT pol0584_grava_dupl_pecas() THEN
      RETURN FALSE
   END IF
               
{   IF NOT pol0584_insere_local_ent() THEN
      RETURN FALSE
   END IF
}
      
   RETURN TRUE

END FUNCTION


#-------------------------------------#
 FUNCTION pol0584_gera_solic_fat()
#-------------------------------------#

   SELECT MAX(num_solicit)
     INTO m_num_solicit 
     FROM fit_mestre
    WHERE cod_empresa = p_cod_empresa

   IF m_num_solicit IS NOT NULL THEN
      LET m_num_solicit = m_num_solicit + 1
   ELSE
      LET m_num_solicit = 1
   END IF

   IF NOT pol0584_le_fiscal() THEN
      RETURN FALSE
   END IF

   INSERT INTO fit_mestre
   
    VALUES (p_cod_empresa, 
            m_num_solicit,
            TODAY,
            "M", 
            p_cod_cliente,
            p_cod_nat_oper,
            p_cod_cnd_pgto,
            mr_pedidos.ies_frete, 
            mr_pedidos.ies_finalidade,
            mr_tela.cod_transpor, 
            mr_tela.num_placa,
            mr_pedidos.cod_consig,
            mr_pedidos.cod_repres,
            mr_pedidos.pct_comissao,
            NULL,NULL,NULL,999,
            p_user,
            p_parametros_1040.cod_via_transporte,
            1, 
            mr_pedidos.cod_moeda,
            0,    
            p_parametros_1040.cod_local_embarque,
            p_parametros_1040.cod_entrega,
            mr_pedidos.cod_tip_carteira,
            "L",  
            NULL) 
            
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","FIT_MESTRE")
      RETURN FALSE
   END IF

   INITIALIZE m_cod_hist_1,
              m_tex_hist_1_1,
              m_tex_hist_2_1,
              m_tex_hist_3_1,
              m_tex_hist_4_1 TO NULL
              
   SELECT cod_hist,
        tex_hist_1,
        tex_hist_2,
        tex_hist_3,
        tex_hist_4
   INTO m_cod_hist_1,   
        m_tex_hist_1_1,
        m_tex_hist_2_1,
        m_tex_hist_3_1,
        m_tex_hist_4_1
   FROM fiscal_hist
   WHERE cod_hist = mr_fiscal_par.cod_hist_1

   INITIALIZE m_cod_hist_2,
              m_tex_hist_1_2,
              m_tex_hist_2_2,
              m_tex_hist_3_2,
              m_tex_hist_4_2 TO NULL
              
   SELECT cod_hist,
        tex_hist_1,
        tex_hist_2,
        tex_hist_3,
        tex_hist_4
   INTO m_cod_hist_2,   
        m_tex_hist_1_2,
        m_tex_hist_2_2,
        m_tex_hist_3_2,
        m_tex_hist_4_2
   FROM fiscal_hist
   WHERE cod_hist = mr_fiscal_par.cod_hist_2

   INSERT INTO fit_hist  
      VALUES (p_cod_empresa, 
              m_num_solicit, 
              m_cod_hist_1, 
              m_tex_hist_1_1,
              m_tex_hist_2_1, 
              m_tex_hist_3_1, 
              m_tex_hist_4_1, 
              m_cod_hist_2, 
              m_tex_hist_1_2, 
              m_tex_hist_2_2, 
              m_tex_hist_3_2, 
              m_tex_hist_4_2, 
              p_user)

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","FIT_HIST")
      RETURN FALSE
   END IF

   INSERT INTO fit_embal 
   VALUES (p_cod_empresa, 
           m_num_solicit, 
           NULL, 
           NULL, 
           0,
           NULL, 
           0, 
           NULL, 
           0, 
           NULL, 
           0, 
           NULL, 
           0, 
           p_user, 
           0, 
           0) 

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","FIT_EMBAL")
      RETURN FALSE
   END IF

   RETURN TRUE
      
END FUNCTION

#---------------------------#
FUNCTION pol0584_le_fiscal()
#---------------------------#

   SELECT * 
     INTO mr_fiscal_par.*
     FROM fiscal_par   
    WHERE cod_empresa   = p_cod_empresa
      AND cod_nat_oper  = p_cod_nat_oper
      AND cod_uni_feder = m_cod_uni_feder 

   IF sqlca.sqlcode <> 0 THEN
      SELECT * 
        INTO mr_fiscal_par.*
        FROM fiscal_par   
       WHERE cod_empresa  = p_cod_empresa
         AND cod_nat_oper = p_cod_nat_oper
         AND cod_uni_feder IS NULL 

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("LEITURA","FISCAL_PAR")
         RETURN FALSE
      END IF

   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol0584_le_item()
#-------------------------#

   SELECT cod_unid_med,
        pes_unit,
        cod_cla_fisc,
        pct_ipi,
        den_item
     INTO m_cod_unid_med,
        m_pes_unit,
        m_cod_cla_fisc,
        m_pct_ipi, 
        m_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_prod

   IF m_pes_unit = 0 THEN
      LET m_pes_unit = 1
   END IF

END FUNCTION
#-----------------------------#
FUNCTION pol0584_grava_itemes()
#-----------------------------#

   LET p_cod_prod = ma_tela[p_ind].cod_item
   
   CALL pol0584_le_item()

   SELECT cod_nat_oper_ref 
     INTO m_cod_nat_oper
     FROM nat_oper_refer
    WHERE cod_empresa  = p_cod_empresa
      AND cod_item     = ma_tela[p_ind].cod_item
      AND cod_nat_oper = p_cod_nat_oper
   
   IF STATUS = 0 THEN
      LET p_cod_nat_oper = m_cod_nat_oper
   END IF

   IF NOT pol0584_le_fiscal() THEN
      RETURN FALSE
   END IF

   SELECT pre_unit
     INTO p_pre_unit
     FROM ped_itens
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = mr_tela.num_pedido
      AND num_sequencia = ma_tela[p_ind].num_sequencia

   LET m_val_liq_item   = ma_tela[p_ind].reser_rej * p_pre_unit
   LET m_val_base_item  = m_val_liq_item

   IF mr_fiscal_par.ies_incid_ipi <> 1 THEN
      LET m_val_ipi = 0
      LET p_ies_tributa_ipi = 'N'
      LET m_pct_ipi = 0
   ELSE
      LET m_val_ipi = m_val_base_item * (m_pct_ipi / 100)
      LET p_ies_tributa_ipi = 'S'
   END IF

   IF mr_fiscal_par.ies_incid_icm <> 1 THEN 
      LET m_val_icm = 0 
      LET mr_fiscal_par.pct_icm_contrib = 0
   ELSE
      LET m_val_icm = m_val_base_item * (mr_fiscal_par.pct_icm_contrib / 100)
   END IF

   LET p_num_item = p_num_item + 1
   
   INSERT INTO fit_itemes
   VALUES (p_cod_empresa, 
           m_num_solicit, 
           p_num_item, 
           ma_tela[p_ind].cod_item, 
           m_den_item, 
           m_cod_unid_med, 
           m_pes_unit, 
           m_cod_cla_fisc, 
           m_pct_ipi, 
           p_ies_tributa_ipi,
           1, 
           ma_tela[p_ind].reser_rej, 
           p_pre_unit, 
           m_val_liq_item, 
           m_val_ipi, 
           p_user,
           0)
           
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","FIT_ITEMES")
      RETURN FALSE
   END IF
   
   INSERT INTO fit_itemes_fiscal
   VALUES (p_cod_empresa, 
           m_num_solicit, 
           p_num_item, 
           p_cod_nat_oper, 
           mr_fiscal_par.ies_incid_ipi,
           mr_fiscal_par.ies_incid_icm,
           mr_fiscal_par.pct_icm_contrib,
           mr_fiscal_par.pct_desc_b_icm_c,
           mr_fiscal_par.cod_fiscal,
           mr_fiscal_par.cod_origem,
           mr_fiscal_par.cod_tributacao,
           mr_fiscal_par.pct_desc_base_ipi,
           mr_fiscal_par.pct_cred_icm,
           mr_fiscal_par.tax_red_pct_icm,
           mr_fiscal_par.pct_desc_ipi, 0, 0 , 0, 0,
           m_val_base_item, m_val_ipi, m_val_base_item,
           m_val_icm, 0, 0, 0, 0, 0, 0, p_user) 
           
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","FIT_ITEMES_FISCAL")
      RETURN FALSE
   END IF
           
   LET m_val_tot_base = m_val_tot_base + m_val_base_item            
   LET m_val_tot_liq  = m_val_tot_liq + m_val_liq_item            
   LET m_val_tot_ipi  = m_val_tot_ipi + m_val_ipi
   LET m_val_tot_icm  = m_val_tot_icm + m_val_icm

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0584_insere_reserva()
#--------------------------------#

      DECLARE cq_lot CURSOR FOR
      SELECT cod_item,
             cod_local,
             num_lote,
             num_transac,
             SUM(qtd_reservada)
      FROM w_lote
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = ma_tela[p_ind].cod_item 
        AND num_seq  = ma_tela[p_ind].num_sequencia
        AND tip_peca = 'R'
      GROUP BY 1,2,3,4

      FOREACH cq_lot INTO 
              mr_estoque_lote.cod_item,
              mr_estoque_lote.cod_local,
              mr_estoque_lote.num_lote,
              p_num_transac,
              mr_estoque_loc_reser.qtd_reservada
      
         LET mr_estoque_loc_reser.num_reserva = 0
      
         INSERT INTO estoque_loc_reser 
           VALUES(p_cod_empresa,
                  mr_estoque_loc_reser.num_reserva,
                  mr_estoque_lote.cod_item,
                  mr_estoque_lote.cod_local,
                  mr_estoque_loc_reser.qtd_reservada,
                  mr_estoque_lote.num_lote,
                  "P",
                  NULL,
                  NULL,
                  "N",
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  TODAY,
                  NULL,
                  NULL,
                  0,
                  NULL)
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO","ESTOQUE_LOC_RESER:2")
            RETURN FALSE
         END IF

         LET l_num_reserva = SQLCA.SQLERRD[2]

         IF NOT pol0584_ins_reser_end() THEN
            RETURN FALSE
         END IF
         
         INSERT INTO fat_resv_est_itesp
          VALUES(p_cod_empresa,
                 m_num_solicit,
                 ma_tela[p_ind].num_sequencia,
                 l_num_reserva,
                 mr_estoque_loc_reser.qtd_reservada,
                 0,
                 0,
                 p_user)
                 
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO","FAT_RESV_EST_ITESP")
            RETURN FALSE
         END IF
          
      
      END FOREACH

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0584_ins_reser_end()
#-------------------------------#

         SELECT * 
           INTO mr_estoque_lote_ender.*
           FROM estoque_lote_ender
          WHERE cod_empresa = p_cod_empresa
            AND num_transac = p_num_transac
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','estoque_lote_ender:3')
            RETURN FALSE
         END IF
         
         INSERT INTO est_loc_reser_end
            VALUES(p_cod_empresa,
                   l_num_reserva,
                   mr_estoque_lote_ender.endereco,
                   mr_estoque_lote_ender.num_volume, 
                   mr_estoque_lote_ender.cod_grade_1,
                   mr_estoque_lote_ender.cod_grade_2,
                   mr_estoque_lote_ender.cod_grade_3,
                   mr_estoque_lote_ender.cod_grade_4,
                   mr_estoque_lote_ender.cod_grade_5,
                   mr_estoque_lote_ender.dat_hor_producao,
                   mr_estoque_lote_ender.num_ped_ven,
                   mr_estoque_lote_ender.num_seq_ped_ven,
                   mr_estoque_lote_ender.dat_hor_validade,
                   mr_estoque_lote_ender.num_peca,
                   mr_estoque_lote_ender.num_serie,
                   mr_estoque_lote_ender.comprimento,
                   mr_estoque_lote_ender.largura,  
                   mr_estoque_lote_ender.altura,   
                   mr_estoque_lote_ender.diametro, 
                   mr_estoque_lote_ender.dat_hor_reserv_1,
                   mr_estoque_lote_ender.dat_hor_reserv_2,
                   mr_estoque_lote_ender.dat_hor_reserv_3,
                   mr_estoque_lote_ender.qtd_reserv_1,    
                   mr_estoque_lote_ender.qtd_reserv_2,    
                   mr_estoque_lote_ender.qtd_reserv_3,    
                   mr_estoque_lote_ender.num_reserv_1,    
                   mr_estoque_lote_ender.num_reserv_2,    
                   mr_estoque_lote_ender.num_reserv_3,    
                   mr_estoque_lote_ender.tex_reservado)   

         IF STATUS <> 0 THEN
            CALL log003_err_sql("INCLUSAO","EST_LOC_RESER_END:2")
            RETURN FALSE
         END IF

         RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0584_grava_total()
#----------------------------#

   LET m_val_tot_nff = m_val_tot_liq + m_val_tot_ipi
   LET m_val_tot_nff = m_val_tot_nff + p_val_tot_mat

   INSERT INTO fit_totais
   VALUES (p_cod_empresa, 
           m_num_solicit, 0, 0, 0, 0, 
           m_val_tot_base, 
           m_val_tot_ipi, 
           m_val_tot_base, 
           m_val_tot_icm, 
           m_val_tot_liq, 
           m_val_tot_nff, 
           p_user, 0, 0, 0, 0, 0) 

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","FIT_TOTAIS")
      RETURN FALSE
   END IF   

   RETURN TRUE
   
END FUNCTION 

#---------------------------------#
FUNCTION pol0584_grava_dupl_pecas()
#---------------------------------#

   DEFINE p_qtd_reg        SMALLINT,
          p_val_gravado    LIKE fit_vencto_dupl.val_duplicata,
          p_val_duplic     LIKE fit_vencto_dupl.val_duplicata,
          p_cond_pgto_item RECORD LIKE cond_pgto_item.*,
          p_ies_emite_dupl CHAR(01),
          p_dat_vencto     DATE

   SELECT ies_emite_dupl 
     INTO p_ies_emite_dupl
     FROM cond_pgto
    WHERE cod_cnd_pgto = p_cod_cnd_pgto

   IF p_ies_emite_dupl <> "S" THEN    
      RETURN TRUE
   END IF

   SELECT COUNT(cod_cnd_pgto)
     INTO p_qtd_reg
     FROM cond_pgto_item
    WHERE cod_cnd_pgto = p_cod_cnd_pgto

   IF p_qtd_reg = 0 THEN
      RETURN TRUE
   END IF
  
   DECLARE cq_cnd_pagto CURSOR FOR
    SELECT * 
      FROM cond_pgto_item
     WHERE cod_cnd_pgto = p_cod_cnd_pgto
       
   LET p_ind = 1
   LET p_val_gravado = 0
   
   FOREACH cq_cnd_pagto INTO p_cond_pgto_item.*

      IF p_ind = p_qtd_reg THEN
         LET p_val_duplic = m_val_tot_nff - p_val_gravado
      ELSE
         LET p_val_duplic  = 
             m_val_tot_nff * p_cond_pgto_item.pct_valor_liquido / 100
      END IF
      
      LET p_val_gravado = p_val_gravado + p_val_duplic    
      LET p_dat_vencto  = TODAY + p_cond_pgto_item.qtd_dias_sd
      
      INSERT INTO fit_vencto_dupl
         VALUES (p_cod_empresa, 
                 m_num_solicit,
                 p_ind, 
                 p_val_duplic, 
                 p_dat_vencto, 
                 NULL, 
                 p_cond_pgto_item.pct_desc_financ, 
                 p_user)
                 
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","fit_vencto_dupl")
         RETURN FALSE
      END IF
            
      LET p_ind = p_ind + 1
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION 

#---------------------------------#
FUNCTION pol0584_insere_local_ent()
#---------------------------------#


   INSERT INTO fit_end
      VALUES (p_cod_empresa, 
              m_num_solicit, 
              NULL, 
              NULL,
              NULL,
              NULL,
              NULL,
              NULL, 
              p_user)
   
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","FIT_END")
      RETURN FALSE
   END IF   
 
   RETURN TRUE
   
END FUNCTION
