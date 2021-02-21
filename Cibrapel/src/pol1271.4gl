#------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO LOGIX X TRIM                                #
# OBJETIVO: IMPORTAÇÃO DE ROMANEIO DO TRIM                         #
# DATA....: 24/07/2007                                             #
# CONVERSÃO 10.02: 10/12/2014 - IVO                                #
# FUNÇÕES: FUNC002                                                 #
# data      Motivo  Versão 18                                      #
# 25/07/16  fazer rateio dos pesos do romaneio pelos itens         #
#           do romaneio                                            #
# 22/01/21  Gravar no campo ped_itens_texto.den_texto_1 a % de FSC #
#           Paraibuna: FSC Misto 70%     p/ cod composição[1]=B    #
#           Smurft Kappa: FSC Misto 80%                            #
#           Cibrapel: FSC reciclado 100% p/ cod composição[1]=K    #
#------------------------------------------------------------------#

#OBF40060 - modalidade

#PARA POR EM PRODUÇÃO:
{
- ALTER TABLE ROMANEIO_885 ADD industrializacao CHAR(01)

}

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_seq_sf             SMALLINT,
          p_ped_char           CHAR(06),
          p_seq_char           CHAR(03),
          p_count              INTEGER,
          p_status             SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ies_cons           SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_last_row           SMALLINT,
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          p_caminho            CHAR(080),
          p_msg                CHAR(150),
          p_dat_movto          DATE,
          p_dat_proces         DATE,
          p_hor_operac         CHAR(08),
          p_transac_consumo    INTEGER,
          p_transac_apont      INTEGER,
          p_num_trans_atual    INTEGER,
          p_tip_movto          CHAR(01),
          p_qtd_movto          DECIMAL(10,3),
          p_ies_chapa          SMALLINT,
          p_ies_sucata         SMALLINT,
          p_info               CHAR(01),
          p_qtd_transf         DECIMAL(10,3),
          p_eh_conjunto        SMALLINT


DEFINE p_man                RECORD LIKE man_apont_885.*,
       p_parametros_885     RECORD LIKE parametros_885.*,
       p_est_trans_relac    RECORD LIKE est_trans_relac.*,
       p_cod_oper_sp        LIKE par_pcp.cod_estoque_sp,
       p_cod_unid_med       LIKE item.cod_unid_med,
       p_ies_tip_item       LIKE item.ies_tip_item
          
END GLOBALS


DEFINE m_ies_situa             CHAR(01),
       m_ies_tip_movto         CHAR(01),
       m_tip_operacao          CHAR(01),
       m_qtd_movto             DECIMAL(10,3),
       m_cod_operac            CHAR(05),
       m_cod_item              CHAR(15),
       m_num_lote              CHAR(10),
       m_dat_movto             DATE,
       m_num_controle          INTEGER,
       m_ordem_antiga          INTEGER,
       m_ies_chapa             CHAR(01),
       m_ies_modalidade        CHAR(01),
       m_ies_indus             SMALLINT,
       m_ies_fat               SMALLINT,
       m_roma_ltda             CHAR(01),
       m_cli_benef             CHAR(15),
       m_fornec                CHAR(15),
       m_ies_texto             SMALLINT,
       m_num_seq               INTEGER,
       m_num_docum             VARCHAR(15)

   
   DEFINE p_statusRegistro     LIKE romaneio_885.statusRegistro,
          p_ies_largura        LIKE item_ctr_grade.ies_largura,
          p_num_lote_om        LIKE ordem_montag_mest.num_lote_om,
          p_ies_altura         LIKE item_ctr_grade.ies_altura,
          p_ies_diametro       LIKE item_ctr_grade.ies_diametro,
          p_ies_comprimento    LIKE item_ctr_grade.ies_comprimento,
          p_ies_serie          LIKE item_ctr_grade.reservado_2,
          p_ctr_lote           LIKE item.ies_ctr_lote,
          p_cod_status         LIKE romaneio_885.statusRegistro,
          p_cod_cid_dest       LIKE roma_item_885.codciddest,
          p_cod_compon         LIKE item.cod_item,
          p_qtd_necessaria     LIKE ord_compon.qtd_necessaria,
          p_cod_local_baixa    LIKE ord_compon.cod_local_baixa,
          p_cod_tip_carteira   LIKE pedidos.cod_tip_carteira,
          p_num_seq_item       LIKE roma_item_885.numseqitem,
          p_codcarteira        LIKE pedidos.cod_tip_carteira,
          p_numsequencia       LIKE roma_item_885.numsequencia,
          p_num_pedido         LIKE ped_itens.num_pedido, 
          p_qtd_reservada      LIKE estoque_loc_reser.qtd_reservada,
          l_num_lote_om        LIKE ordem_montag_lote.num_lote_om,
          p_den_erro           LIKE roma_erro_885.den_erro,
          p_tipooperacao       LIKE roma_item_885.tipooperacao,
          p_tip_trim           LIKE empresas_885.tip_trim,
          p_numromaneio        LIKE roma_item_885.numromaneio,
          p_numroma_ant        LIKE roma_item_885.numromaneio,
          l_num_om             LIKE ordem_montag_mest.num_om,
          p_numpedido          LIKE roma_item_885.numpedido,
          l_num_lote           LIKE ordem_montag_mest.num_lote_om,
          p_cod_emp_ant        LIKE empresa.cod_empresa,
          p_pct_desc_valor     LIKE desc_nat_oper_885.pct_desc_valor,
          p_pct_desc_qtd       LIKE desc_nat_oper_885.pct_desc_qtd,
          p_pct_cancelar       LIKE desc_nat_oper_885.pct_desc_qtd,
          p_cod_cnd_pgto       LIKE pedidos.cod_cnd_pgto,
          p_numseqitem         LIKE roma_item_885.numseqitem,
          #p_coditem            LIKE roma_item_885.coditem,
          p_qtdpecas           LIKE roma_item_885.qtdpecas,
          p_cod_cliente        LIKE pedidos.cod_cliente,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_cli_ant            LIKE pedidos.cod_cliente,
          p_num_sequencia      LIKE romaneio_885.numsequencia,
          p_cod_emp_log        LIKE empresa.cod_empresa,
          p_qtd_saldo          LIKE ped_itens.qtd_pecas_solic,
          p_qtd_estoq          LIKE estoque_lote.qtd_saldo,
          p_qtd_estoq_reser    LIKE estoque_lote.qtd_saldo,
          p_cod_local_estoq    LIKE item.cod_local_estoq,
          m_cod_local_estoq    LIKE item.cod_local_estoq,
          p_ies_ctr_estoque    LIKE item.ies_ctr_estoque,
          p_cod_item           LIKE item.cod_item,
          p_coditem            LIKE item.cod_item,
          p_num_docum          LIKE ordens.num_docum,
          p_ies_sit_om         LIKE ordem_montag_mest.ies_sit_om,
          p_ies_sit_pedido     LIKE pedidos.ies_sit_pedido,
          l_cod_tip_carteira   LIKE pedidos.cod_tip_carteira,
          p_num_om             LIKE roma_papel_885.numromaneio,
          p_peso_carga         LIKE ordem_montag_item.pes_total_item,
          p_numlote            LIKE roma_item_885.numlote,
          p_largura            LIKE roma_item_885.largura,
          p_diametro           LIKE roma_item_885.diametro,
          p_tubete             LIKE roma_item_885.tubete,
          p_comprimento        LIKE roma_item_885.comprimento,
          p_serie              LIKE est_loc_reser_end.num_serie,
          p_pre_unit           LIKE ped_itens.pre_unit,
          p_pecas_solic        LIKE ped_itens.qtd_pecas_solic,
          p_val_pedido         LIKE frete_peso_885.val_tonelada,
          p_val_tot            LIKE frete_peso_885.val_tonelada,
          p_val_tonelada       LIKE frete_peso_885.val_tonelada,
          p_val_frete          LIKE frete_peso_885.val_tonelada,
          p_val_ger            LIKE frete_peso_885.val_tonelada,
          p_val_fret_ofic      LIKE frete_peso_885.val_tonelada,
          p_val_fret_ger       LIKE frete_peso_885.val_tonelada,
          p_cod_cid_orig       LIKE clientes.cod_cidade,
          p_num_cgc            LIKE empresa.num_cgc,
          p_num_versao         LIKE frete_rota_885.num_versao,
          p_ies_tip_controle   LIKE nat_operacao.ies_tip_controle,
          p_cod_nat_oper       LIKE pedidos.cod_nat_oper,
          p_ies_situa_qtd      LIKE estoque_lote.ies_situa_qtd,
          p_num_trans_origem   LIKE estoque_trans.num_transac,
          p_num_trans_destino  LIKE estoque_trans.num_transac,
          p_num_transac        LIKE estoque_trans.num_transac,
          p_cod_operacao       LIKE estoque_trans.cod_operacao,
          p_texto_ped          LIKE ped_itens_texto.den_texto_1,
          p_num_lacre          LIKE ped_itens_texto.den_texto_2,
          p_qtd_pacote         LIKE roma_item_885.qtdpacote,
          p_txt_pacote         LIKE ped_itens_texto.den_texto_3,
          p_cod_grupo_item     LIKE grupo_item.cod_grupo_item,
          l_cod_embal_int      LIKE item_embalagem.cod_embal,
          p_cod_familia        LIKE item.cod_familia,
          p_qtd_baixar         LIKE estoque_lote.qtd_saldo,
          m_num_nff            LIKE fat_nf_mestre.nota_fiscal,
          m_den_texto_1        LIKE ped_itens_texto.den_texto_1

           
          
   DEFINE p_tolmais            DECIMAL(10,3),
          p_pct_desc           DECIMAL(5,2),
          p_selecionou         SMALLFLOAT,
          p_tolentmais         DECIMAL(5,2),
          p_faturar            CHAR(01),
          p_coefic             DECIMAL(17,7),
          p_saldo_txt          CHAR(22),
          p_pecas_txt          CHAR(22),
          p_peso_romaneio      DECIMAL(10,3),
          p_peso_romaneiob     DECIMAL(10,3),
          p_peso_ger           DECIMAL(10,3),
          p_peso_ofic          DECIMAL(10,3),
          p_pes_brut_it        DECIMAL(10,3),
          p_pes_brut_tot       DECIMAL(10,3),
          p_pes_liq_tot        DECIMAL(10,3),
          p_pesoliqcarregado   DECIMAL(10,3),
          p_pesocarregado      DECIMAL(10,3),
          p_qtd_pecas_solic    INTEGER,
          p_qtd_romanear       DECIMAL(10,0),
          p_qtd_cancelar       DECIMAL(10,0),
          p_dat_hor            DATETIME YEAR TO SECOND,
          p_qtd_roma_aux       CHAR(12),
          p_ies_itens_nff      CHAR(01),
          p_gerou_solicit      SMALLINT,
          p_pct_romanear       DECIMAL(5,2),
          p_pct_emp_ger        DECIMAL(5,2),
          p_pct_emp_ofic       DECIMAL(5,2),
          p_pct_reservar       DECIMAL(5,2),
          p_qtd_itens          SMALLINT,
          p_criticou           SMALLINT,
          p_hor_atual          CHAR(08),
          p_cod_transp         CHAR(02),
          p_cod_transp_auto    CHAR(02),
          p_num_sf             INTEGER,
          p_num_solicit        INTEGER,
          p_criticou_item      SMALLINT,
          p_qtd_item           SMALLINT,
          p_oper_e_trnsf       CHAR(04),
          p_oper_s_trnsf       CHAR(04),
          p_cod_pacote_bob     CHAR(03),
          p_ies_pacote         CHAR(01),
          l_qtd_volume         DECIMAL(6,0),
          p_ies_frete          CHAR(01),
          m_ies_frete          INTEGER,
          p_num_nff            INTEGER,
          p_qtd_linha          INTEGER,
          p_tipo_processo      INTEGER,
          m_ies_top            SMALLINT
             
   DEFINE mr_ordem_montag_mest  RECORD LIKE ordem_montag_mest.*,
          mr_ordem_montag_item  RECORD LIKE ordem_montag_item.*,
          mr_ordem_montag_grade RECORD LIKE ordem_montag_grade.*,
          p_fat_solic_ser_comp  RECORD LIKE fat_solic_ser_comp.*,
          p_estoque_lote_ender  RECORD LIKE estoque_lote_ender.*,
          p_ped_item_nat        RECORD LIKE ped_item_nat.*

   DEFINE p_nf_solicit          RECORD
          cod_empresa          char(2),
          num_solicit          INTEGER,
          dat_refer            DATE,
          cod_via_transporte   decimal(2,0),
          cod_entrega          decimal(4,0),
          cod_mercado          char(2),
          cod_local_embarque   decimal(3,0),
          ies_mod_embarque     decimal(2,0),
          ies_tip_solicit      char(1),
          ies_lotes_geral      char(1),
          cod_tip_carteira     char(2),
          num_lote_om          decimal(6,0),
          num_om               decimal(6,0),
          num_controle         decimal(3,0),
          num_texto_1          decimal(3,0),
          num_texto_2          decimal(3,0),
          num_texto_3          decimal(3,0),
          val_frete            decimal(15,2),
          val_seguro           decimal(15,2),
          val_frete_ex         decimal(15,2),
          val_seguro_ex        decimal(15,2),
          pes_tot_bruto        decimal(13,4),
          ies_situacao         char(1),
          num_sequencia        SMALLINT,
          nom_usuario          char(8),
          cod_transpor         char(15),
          num_placa            char(7),
          num_volume           decimal(6,0),
          cod_embal_1          char(3),
          qtd_embal_1          decimal(6,0),
          cod_embal_2          char(3),
          qtd_embal_2          decimal(4,0),
          cod_embal_3          char(3),
          qtd_embal_3          decimal(4,0),
          cod_embal_4          char(3),
          qtd_embal_4          decimal(4,0),
          cod_embal_5          char(3),
          qtd_embal_5          decimal(4,0),
          cod_cnd_pgto         decimal(3,0),
          pes_tot_liquido      decimal(13,4),
          qtd_dias_acr_dupl    decimal(3,0)
   END RECORD
          

   DEFINE p_roma               RECORD
          NumSequencia         LIKE romaneio_885.NumSequencia,
          CodEmpresa           LIKE romaneio_885.CodEmpresa,
          TipoOperacao         LIKE romaneio_885.TipoOperacao,
          numromaneio          LIKE romaneio_885.numromaneio,
          coderptranspor       LIKE romaneio_885.coderptranspor,
          placaveiculo         LIKE romaneio_885.placaveiculo,
          pesobalanca          LIKE romaneio_885.pesobalanca,
          pesocarregado        LIKE romaneio_885.pesocarregado,
          codtipfrete          LIKE romaneio_885.codtipfrete,
          valfrete             LIKE romaneio_885.valfrete,
          codpercurso          LIKE romaneio_885.codpercurso,
          codveiculo           LIKE romaneio_885.codveiculo,
          codtipcarga          LIKE romaneio_885.codtipcarga,
          codciddest           LIKE romaneio_885.codciddest,
          ufveiculo            CHAR(02),
          pesoliquido          DECIMAL(10,3),
          industrializacao     CHAR(01)          
   END RECORD

   DEFINE p_sol                RECORD
          num_om               LIKE ordem_montag_mest.num_om,
          num_pedido           LIKE pedidos.num_pedido,
          cod_acao             CHAR(01)
   END RECORD

   DEFINE p_item_roma          RECORD
          num_sequencia        DECIMAL(6,0),
          cod_item             CHAR(15),
          numlote              CHAR(15),
          largura              INTEGER,
          diametro             INTEGER,
          altura               INTEGER,
          comprimento          INTEGER,
          pes_item             DECIMAL(12,2),
          pes_itemb            DECIMAL(12,2),
          qtd_reservada        DECIMAL(10,3),
          qtd_volumes          INTEGER
   END RECORD

   DEFINE p_romaneios         ARRAY[200] OF RECORD
          num_sequencia       LIKE roma_erro_885.num_sequencia,
          den_erro            LIKE roma_erro_885.den_erro,
          dat_hor             DATE
   END RECORD

   DEFINE pr_om               ARRAY[200] OF RECORD
          num_om              LIKE solicit_fat_885.num_om,
          num_pedido          LIKE solicit_fat_885.num_pedido,
          cod_cliente         LIKE clientes.cod_cliente,
          nom_cliente         LIKE clientes.nom_cliente,
          cod_status          LIKE solicit_fat_885.cod_status,
          cod_acao            CHAR(01)
   END RECORD

  DEFINE lr_fat_solic_mestre	RECORD LIKE fat_solic_mestre.*
  DEFINE lr_fat_solic_fatura	RECORD LIKE fat_solic_fatura.*
  DEFINE lr_fat_solic_embal		RECORD LIKE fat_solic_embal.*


   DEFINE pr_pedido           ARRAY[30] OF RECORD
          num_om              INTEGER,
          num_pedido          INTEGER,
          cod_cliente         CHAR(15),
          nom_cliente         CHAR(18),
          cod_nat_oper        LIKE pedidos.cod_nat_oper,
          cod_tip_carteira    LIKE pedidos.cod_tip_carteira,
          controle            DECIMAL(2,0)
   END RECORD
   
   DEFINE m_controle          INTEGER,
          m_txt_placa_veic    LIKE fat_solic_fatura.texto_1,
          m_txt_uf_veic       LIKE fat_solic_fatura.texto_2
          
   DEFINE m_copia_roma        SMALLINT,
          m_opcao             CHAR(01),
          m_cod_emp_op        CHAR(02),
          m_cod_emp_pv        CHAR(02)

   DEFINE m_num_transac   INTEGER,
          m_cod_cliente   CHAR(15),
          m_nom_reduzido  CHAR(15)
   
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1271-12.02.71  "
   CALL func002_versao_prg(p_versao)
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1271.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL pol1271_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol1271_controle()
#--------------------------#
   
   DEFINE l_help_nf_ret   CHAR(30)
   
   LET l_help_nf_ret = "Inclui NF de retorno na emp ", p_cod_empresa
   
   CALL log006_exibe_teclas("01",p_versao)
   
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1271") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1271 AT 02,02 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF NOT log0150_verifica_se_tabela_existe("cli_alt_desc_885") THEN 
      IF NOT pol1271_cria_cli_alt() THEN
         RETURN 
      END IF
   END IF

   IF NOT pol1271_le_parametros() THEN
      RETURN
   END IF

   DISPLAY p_cod_empresa TO cod_empresa

   LET p_num_sequencia = 0

   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      
      BEFORE MENU

        #IF p_cod_empresa <> m_cod_emp_op THEN
           HIDE OPTION "Nf de Retorno"
        #END IF
      
      COMMAND "Informar" "Informa parametros p/ o processamento "
         LET p_info = 'I'
         IF NOT pol1271_informar() THEN
            LET p_ies_cons = FALSE
            CALL pol1271_limpa_tela()
            ERROR 'OPERAÇÃO CANCELADA !!!'
         ELSE
            ERROR 'PARAMETROS INFORMADOS COM SUCESSO !!!'
         END IF
      
      COMMAND "Desconsolidar" "Prepara romaneio p/ ser desconsolidade pelo Trim "
         IF p_ies_cons THEN
            IF p_cod_status = '1' THEN
               CALL log0030_mensagem('Romaneio já processado','exclamation')
            ELSE
               CALL log085_transacao("BEGIN")
               IF pol1271_muda_status('3') THEN
                  CALL log085_transacao("COMMIT")
                  ERROR 'OPERAÇÃO EFETUADA COM SUCESSO !!!'
               ELSE 
                  CALL log085_transacao("ROLLBACK")
                  ERROR 'OPERAÇÃO CANCELADA !!!'
               END IF
            END IF
         ELSE
            ERROR 'INFORME PREVIAMENTE OS PARÂMETROS'
         END IF
      
      COMMAND "Cancelar" "Cancela o romaneio enviado pelo Trim "
         IF p_ies_cons THEN
            IF p_cod_status = '1' THEN
               CALL log0030_mensagem('Romaneio já processado','exclamation')
            ELSE
               CALL log085_transacao("BEGIN")
               IF pol1271_muda_status('4') THEN
                  CALL pol1271_limpa_tela()
                  CALL log085_transacao("COMMIT")
                  ERROR 'OPERAÇÃO EFETUADA COM SUCESSO !!!'
               ELSE 
                  CALL log085_transacao("ROLLBACK")
                  ERROR 'OPERAÇÃO CANCELADA !!!'
               END IF
            END IF
         ELSE
            ERROR 'INFORME PREVIAMENTE OS PARÂMETROS'
         END IF
      
      COMMAND "Reprocessar" "Reprocessa a solicitação de faturamento "
         IF p_ies_cons THEN
            IF p_cod_status = '1' THEN
               CALL log0030_mensagem('Romaneio já processado','exclamation')
            ELSE
               LET m_opcao = 'R'
               CALL pol1271_processar() RETURNING p_status
               IF p_status THEN
                  ERROR 'PROCESSAMENTO EFETUADO COM SUCESSO!'
               ELSE
                  ERROR 'OPERAÇÃO CANCELADA!'
               END IF
            END IF
         ELSE
            ERROR 'INFORME PREVIAMENTE OS PARÂMETROS'
         END IF
     
      COMMAND "OM logix" "Odens de montagem geradas no logix "
         CALL pol1271_om_logix()      
      
      COMMAND "Faturar"  "Faturar a solicitação"
			   CALL log120_procura_caminho("VDP0745") RETURNING comando
		     LET comando = comando CLIPPED
		     RUN comando RETURNING p_status      
      
      COMMAND "Modificar" "Modificar descrição do item "
         IF pol1271_modificar() THEN
            ERROR 'OPERAÇÃO EFETUADA COM SUCESSO !!!'
         ELSE
            ERROR 'OPERAÇÃO CANCELADA !!!'
         END IF

      COMMAND "Nf de Retorno" l_help_nf_ret 
         IF p_ies_cons THEN
            IF pol1271_inc_nf_terc() THEN
               ERROR 'PROCESSAMENTO EFETUADO COM SUCESSO!'
            ELSE
               ERROR 'OPERAÇÃO CANCELADA!'
            END IF         
         ELSE
            ERROR 'INFORME PREVIAMENTE OS PARÂMETROS'
         END IF
      
      COMMAND "Sobre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      
      COMMAND "Fim" "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU
 
   CLOSE WINDOW w_pol1271


END FUNCTION

#------------------------------#
FUNCTION pol1271_cria_cli_alt()#
#------------------------------#

   CREATE TABLE cli_alt_desc_885 (
     cod_empresa      char(02),
     cod_cliente      char(15),
     ies_ativo        char(01)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE', 'cli_alt_desc_885')
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX ix_cli_alt_desc_885
    ON cli_alt_desc_885(cod_empresa, cod_cliente);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE', 'ix_cli_alt_desc_885')
      RETURN FALSE
   END IF
   
   INSERT INTO cli_alt_desc_885
    VALUES(p_cod_empresa, '050748748000145', 'S')

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT', 'cli_alt_desc_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION
   
#----------------------------#
FUNCTION pol1271_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#-------------------------------#
FUNCTION pol1271_le_parametros()
#-------------------------------#

   DROP TABLE roma_tmp_885
   
   CREATE TEMP TABLE roma_tmp_885 (
      cod_item      CHAR(15),
      qtd_tot_roma  DECIMAL(10,3)
   );
   
   CREATE INDEX ix_roma_tmp_885 ON roma_tmp_885(cod_item)

   SELECT cod_pacote_bob
     INTO p_cod_pacote_bob
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','parametros_885')
      RETURN FALSE
   END IF

   SELECT num_cgc
     INTO p_num_cgc
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   SELECT cod_cidade
     INTO p_cod_cid_orig
     FROM clientes
    WHERE num_cgc_cpf = p_num_cgc

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','clientes')
      RETURN FALSE
   END IF
 
   IF p_num_cgc = '035.503.800/0001-00' THEN
      LET p_tip_trim = 'T'
   ELSE
      IF p_cod_empresa = '01' OR p_cod_empresa = '11' THEN
         LET p_tip_trim = 'B'
      ELSE
         LET p_tip_trim = 'P'
      END IF

      SELECT cod_fornecedor
        INTO m_fornec
        FROM fornecedor
       WHERE num_cgc_cpf = p_num_cgc

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fornecedor')
         RETURN FALSE
      END IF
        
   END IF
   
   SELECT substring(par_vdp_txt,215,2)
     INTO p_cod_transp
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      ERROR 'Não foi possivel ler parâmetro do transportador'
      CALL log003_err_sql('Lendo','par_vdp')
      RETURN FALSE
   END IF

   SELECT par_txt
     INTO p_cod_transp_auto
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'cod_tip_transp_aut'
   
   IF STATUS <> 0 THEN
      ERROR 'Não foi possivel ler código de transportador autônomo'
      CALL log003_err_sql('Lendo','par_vdp_pad')
      RETURN FALSE
   END IF

   SELECT par_txt 
     INTO p_oper_s_trnsf
     FROM par_sup_pad 
    WHERE cod_empresa   = p_cod_empresa 
      AND cod_parametro = 'oper_sai_trf_grade'

   IF STATUS <> 0 THEN
      ERROR 'Não foi possivel ler oeração de saída transf grade'
      CALL log003_err_sql('Lendo','par_vdp_pad')
      RETURN FALSE
   END IF

   SELECT par_txt 
     INTO p_oper_e_trnsf
     FROM par_sup_pad 
    WHERE cod_empresa   = p_cod_empresa 
      AND cod_parametro = 'oper_ent_trf_grade'

   IF STATUS <> 0 THEN
      ERROR 'Não foi possivel ler operação de entrada transf grade'
      CALL log003_err_sql('Lendo','par_vdp_pad')
      RETURN FALSE
   END IF 

   IF p_tip_trim = 'T' THEN
      LET m_cod_emp_op = p_cod_empresa
   ELSE   
      SELECT cod_emp_ordem
        INTO m_cod_emp_op
        FROM de_para_empresa_885
       WHERE cod_emp_pedido = p_cod_empresa

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','de_para_empresa_885.1')
         RETURN FALSE
      END IF
   
      IF m_cod_emp_op IS NULL THEN
         LET p_msg = 'Empresa produtora não cadastrada para empresa ',p_cod_empresa
         CALL log0030_mensagem(p_msg,'info')
         RETURN FALSE
      END IF      
   END IF
   
   IF p_tip_trim = 'T' THEN
      LET m_cod_emp_pv = p_cod_empresa
   ELSE
      SELECT MAX(cod_emp_pedido) 
        INTO m_cod_emp_pv
        FROM de_para_empresa_885
       WHERE cod_emp_ordem = m_cod_emp_op

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','de_para_empresa_885.2')
         RETURN FALSE
      END IF
   END IF

    SELECT num_cgc
     INTO p_num_cgc
     FROM empresa
    WHERE cod_empresa = m_cod_emp_pv
    
   IF STATUS = 0 THEN

      SELECT cod_cliente
       INTO m_cli_benef
        FROM clientes
       WHERE num_cgc_cpf = p_num_cgc

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','clientes:2')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1271_informar()
#--------------------------#

   INITIALIZE p_num_solicit, p_texto_ped TO NULL
   LET INT_FLAG = FALSE
   CALL pol1271_limpa_tela()
 
   INPUT p_num_solicit WITHOUT DEFAULTS FROM num_roma

      AFTER FIELD num_roma
         IF p_num_solicit IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD num_roma
         END IF
         
         SELECT MAX(numsequencia)
           INTO p_num_sequencia
           FROM romaneio_885
          WHERE codempresa  = p_cod_empresa
            AND numromaneio = p_num_solicit
            AND statusregistro IN ('0','1','2','3')
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','romaneio_885')
            NEXT FIELD num_roma
         END IF
         
         IF p_num_sequencia IS NULL THEN
            CALL log0030_mensagem('Romaneio Inexistente.','exclamation')
            NEXT FIELD num_roma
         END IF

         SELECT statusregistro,
                numlacre
           INTO p_cod_status,
                p_num_lacre
           FROM romaneio_885
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_num_sequencia
            
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','romaneio_885')
            NEXT FIELD num_roma
         END IF
        
         LET p_num_lacre = UPSHIFT(p_num_lacre)
         
         #IF p_num_lacre IS NOT NULL THEN
         #  LET p_num_lacre = 'LACRE: ', p_num_lacre CLIPPED
         #END IF
        
         DISPLAY  p_cod_status TO cod_status
         
         IF p_cod_status MATCHES '[012]' THEN
         ELSE
            IF p_cod_status = '1' THEN
               CALL log0030_mensagem('Romaneio já processado','excla')
            ELSE
               IF p_cod_status = '3' THEN
                  CALL log0030_mensagem('Romaneio aguardando desconsolidação do Trim','excla')
               ELSE
                  CALL log0030_mensagem('Romaneio Inexistente.','exclamation')
               END IF
            END IF
            NEXT FIELD num_roma
         END IF

      ON KEY (control-z)
         CALL pol1271_popup('T')

   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   IF p_cod_status = '1' THEN
      DISPLAY 'Nf de retorno' TO den_oper
      LET p_ies_cons = TRUE
      RETURN TRUE
   END IF
   
   IF p_cod_status = '2' THEN
      IF NOT pol1271_carrega_criticas() THEN
         RETURN FALSE
      END IF
      CALL pol1271_exibe_criticas()
      DISPLAY 'Reprocessar/Desconsolidar/Cancelar' TO den_oper
      LET p_ies_cons = TRUE
      RETURN TRUE
   END IF

   IF log004_confirm(18,35) THEN
      LET m_opcao = 'I'
      CALL pol1271_processar() RETURNING p_status
   ELSE
      LET p_status = FALSE
   END IF

   RETURN(p_status)
   
END FUNCTION

#--------------------------#
FUNCTION pol1271_popup(p_ch)
#--------------------------#

   DEFINE p_codigo CHAR(15),
          p_ch     CHAR(01)

   CASE
   
      WHEN INFIELD(num_roma)
         LET p_codigo = pol1271_escolhe_roma(p_ch)
         CLOSE WINDOW w_pol12713
         IF p_codigo IS NOT NULL THEN
            LET p_num_solicit = p_codigo
            DISPLAY p_num_solicit TO num_roma
         END IF
   
   END CASE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1271_escolhe_roma(p_ch)
#---------------------------------#

   DEFINE pr_pop_roma ARRAY[3000] OF RECORD
          num_roma INTEGER
   END RECORD
   
   DEFINE p_ch     CHAR(01),
          sql_stmt CHAR(600)

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol12713") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   IF p_ch = 'T' THEN
      OPEN WINDOW w_pol12713 AT 08,14 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   ELSE
      OPEN WINDOW w_pol12713 AT 09,63 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   END IF
   
   LET INT_FLAG = FALSE
   LET p_ind = 1
   
   IF p_ch = 'T' THEN
      LET sql_stmt = "SELECT DISTINCT numromaneio FROM romaneio_885 ",
                     " WHERE statusregistro IN ('0','2') ",
                     "   AND codempresa ='",p_cod_empresa,"' ",
                     " ORDER BY numromaneio desc"
   ELSE
      IF p_info = 'A' THEN
         LET sql_stmt = "SELECT DISTINCT a.num_solicit FROM solicit_fat_885 a, ",
                        "  fat_solic_mestre b ",
                        " WHERE a.cod_empresa ='",p_cod_empresa,"' ",
                        "   AND b.empresa = a.cod_empresa ",
                        "   AND b.solicitacao_fatura = a.num_solicit ",                        
                        " ORDER BY num_solicit desc"
      ELSE
         LET sql_stmt = "SELECT DISTINCT num_solicit FROM solicit_fat_885 ",
                        " WHERE cod_empresa ='",p_cod_empresa,"' ",
                        " ORDER BY num_solicit desc"
      END IF      
   END IF

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_pop CURSOR FOR var_query
      
   FOREACH cq_pop INTO pr_pop_roma[p_ind].num_roma
   
      LET p_ind = p_ind + 1
      
      IF p_ind > 3000 THEN
         LET p_msg = 'Limite de romaneios previstos ultrapasou.\n',
                     'Alguns numeros não serão exibidos'
         CALL log0030_mensagem(p_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   IF p_ind = 1 THEN
      CALL log0030_mensagem('Naõ há romaneio p/ exiber.','excla')
      RETURN ""
   END IF
   
   CALL SET_COUNT(p_ind -1)
   
   DISPLAY ARRAY pr_pop_roma TO sr_pop_roma.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE()

   
   IF INT_FLAG THEN
      RETURN ""
   ELSE
      RETURN(pr_pop_roma[p_ind].num_roma)
   END IF
   
END FUNCTION

#--------------------------------#
FUNCTION pol1271_carrega_criticas()
#--------------------------------#

   INITIALIZE p_romaneios TO NULL
   
   LET p_index = 1

   INITIALIZE p_romaneios TO NULL
   
   DECLARE cq_erros CURSOR FOR
    SELECT num_sequencia,
           den_erro,
           dat_hor
      FROM roma_erro_885
     WHERE cod_empresa  = p_cod_empresa
       AND num_romaneio = p_num_solicit
    
   FOREACH cq_erros INTO 
           p_romaneios[p_index].num_sequencia,
           p_romaneios[p_index].den_erro,
           p_dat_hor
           
      LET p_romaneios[p_index].dat_hor = EXTEND(p_dat_hor, YEAR TO DAY)

      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo","roma_erro_885")    
         RETURN FALSE
      END IF

      LET p_index = p_index + 1

      IF p_index > 2000 THEN
         ERROR 'Limite de Linhas Ultrapassado!'
         EXIT FOREACH
      END IF

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1271_exibe_criticas()
#--------------------------------#

   CALL SET_COUNT(p_index - 1)

   IF ARR_COUNT() > 11 THEN
      DISPLAY ARRAY p_romaneios TO s_romaneios.*
   ELSE
      INPUT ARRAY p_romaneios WITHOUT DEFAULTS FROM s_romaneios.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF

END FUNCTION

#----------------------------------------#
FUNCTION pol1271_muda_status(p_cod_status)
#----------------------------------------#

   DEFINE p_cod_status CHAR(01),
          p_stat_reg   INTEGER
   
   IF NOT log004_confirm(18,35) THEN
      RETURN FALSE
   END IF
   
   UPDATE romaneio_885
      SET statusregistro = p_cod_status,
          usuario        = p_user
    WHERE (codempresa   = p_cod_empresa OR codempresa = m_cod_emp_pv)
      AND numromaneio  = p_num_solicit
      AND numsequencia = p_num_sequencia
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Excluindo','romaneio_885')
      RETURN FALSE
   END IF

   UPDATE roma_item_885
      SET statusregistro = p_cod_status
    WHERE (codempresa   = p_cod_empresa OR codempresa = m_cod_emp_pv)
      AND numromaneio  = p_num_solicit
      AND numseqpai    = p_num_sequencia
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Excluindo','roma_item_885')
      RETURN FALSE
   END IF
   
   DELETE FROM roma_erro_885
    WHERE (cod_empresa   = p_cod_empresa OR cod_empresa = m_cod_emp_pv)
      AND num_romaneio  = p_num_solicit
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Excluindo','roma_erro_885')
      RETURN FALSE
   END IF
   
   CALL pol1271_limpa_tela()
   LET p_ies_cons = FALSE
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1271_processar()
#---------------------------#

   SELECT COUNT(dat_refer)
     INTO p_count
     FROM fat_solic_mestre
    WHERE empresa = p_cod_empresa
      AND dat_refer < TODAY

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','fat_solic_mestre')
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      LET p_msg = 'Existem solicitações não faturadas\n',
                  'com datas anteriores a atual.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")
   
   IF p_tip_trim = 'T' THEN
   ELSE
      IF m_opcao = 'I' AND m_cod_emp_op = p_cod_empresa THEN
         IF NOT pol1271_copia_roma_885() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
      END IF
   END IF
    
   IF NOT pol1271_importa_romaneio() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   CALL pol1271_limpa_tela()
   DISPLAY p_num_solicit TO num_roma

   IF p_statusRegistro = 1 THEN
      DISPLAY 'OM logix' TO den_oper
      LET p_msg = 'Procesamento efetuado com sucesso.\n',
                  'Deseja agrupar os pedisos agora ?'
      IF log0040_confirm(20,25,p_msg) THEN
         CALL pol1271_agrupar()
      END IF
   ELSE
      IF NOT pol1271_carrega_criticas() THEN
         RETURN FALSE
      END IF
      CALL pol1271_exibe_criticas()
      DISPLAY 'Reprocessar/Desconsolidar/Cancelar' TO den_oper
      LET p_ies_cons = TRUE
   END IF
   
   DISPLAY p_statusRegistro TO cod_status
   
   RETURN TRUE

END FUNCTION
  
#----------------------------------#
FUNCTION pol1271_importa_romaneio()
#----------------------------------#

   UPDATE romaneio_885
      SET statusregistro = 'I'
    WHERE codempresa  = p_cod_empresa
      AND numromaneio = p_num_solicit
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','romaneio_885')
      RETURN FALSE
   END IF

   SELECT MAX(numsequencia)
     INTO p_num_sequencia
     FROM romaneio_885
    WHERE codempresa  = p_cod_empresa
      AND numromaneio = p_num_solicit
         
   IF STATUS <> 0 OR p_num_sequencia IS NULL THEN
      CALL log003_err_sql('Lendo','romaneio_885:numsequencia')
      RETURN FALSE
   END IF

   IF NOT pol1271_le_romaneio_885() THEN
      RETURN FALSE
   END IF

   IF NOT pol1271_deleta_erros() THEN
      RETURN FALSE
   END IF

   LET p_criticou = FALSE
   LET p_numsequencia = 0
   LET p_statusRegistro = 1
   LET p_faturar = 'T'

   CALL pol1271_gera_num_sf()
      
   IF NOT pol1271_consiste_roma() THEN
      RETURN FALSE
   END IF
   
   IF NOT p_criticou THEN
      IF NOT pol1271_insere_solicit() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1271_grava_roma() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1271_le_romaneio_885()
#---------------------------------#

   SELECT NumSequencia,
          CodEmpresa,
          TipoOperacao,
          numromaneio,
          coderptranspor,
          placaveiculo,
          pesobalanca,
          pesocarregado,
          codtipfrete,
          valfrete,
          codpercurso,
          codveiculo,
          codtipcarga,
          codciddest,
          ufveiculo,
          pesoliquido,
          industrializacao
     INTO p_roma.*
     FROM romaneio_885
    WHERE codempresa = p_cod_empresa
      AND numromaneio  = p_num_solicit
      AND NumSequencia = p_num_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','romaneio_885')
      RETURN FALSE
   END IF
   
   LET m_ies_indus = FALSE
   
   IF p_roma.industrializacao IS NOT NULL THEN
      IF p_roma.industrializacao = 'S' THEN
         LET m_ies_indus = TRUE
      END IF
   ELSE
      LET p_roma.industrializacao = 'N'
   END IF
        
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1271_deleta_erros()
#------------------------------#
   
   DELETE FROM roma_erro_885
    WHERE cod_empresa  = p_cod_empresa
      AND num_romaneio = p_num_solicit

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','roma_erro_885')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1271_gera_num_sf()
#-----------------------------#
   
   DEFINE p_ind SMALLINT,
          p_txt CHAR(06),
          p_sol CHAR(12),
          p_ctr SMALLINT
      
   INITIALIZE p_txt, p_sol TO NULL
   LET p_ctr = 0
   LET p_sol = p_num_solicit
   
   FOR p_ind = LENGTH(p_sol CLIPPED) TO 1 step -1
       LET p_txt = p_sol[p_ind], p_txt
       LET p_ctr = p_ctr + 1
       IF p_ctr >= 6 THEN
          EXIT FOR
       END IF
   END FOR
   
   LET p_num_sf = p_txt
   LET p_seq_sf = 0

END FUNCTION

#------------------------------#
FUNCTION pol1271_consiste_roma()
#------------------------------#

   IF p_roma.tipooperacao <> '0'  THEN
      LET p_den_erro = 'TIPO DE OPERACAO INVALIDA'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_roma.pesobalanca IS NULL OR p_roma.pesobalanca <= 0 THEN
      LET p_den_erro = 'PESO BALANCA INVALIDO'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_roma.pesoliquido IS NULL OR p_roma.pesoliquido <= 0  THEN
      LET p_den_erro = 'PESO LIQUIDO INVALIDO'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_roma.pesoliquido > p_roma.pesobalanca  THEN
      LET p_den_erro = 'O PESO LIQUIDO ESTA MAIOR QUE O PESO BALANCA'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_roma.placaveiculo IS NOT NULL THEN
      IF p_roma.ufveiculo IS NULL OR p_roma.ufveiculo = ' ' THEN
         LET p_den_erro = 'UF DO VEICULO NA FOI INFORMADA'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF p_roma.codtipfrete MATCHES '[PRF9]' THEN
      IF p_roma.codtipfrete MATCHES '[F9]' THEN 
         IF NOT pol1271_checa_cli_transp() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol1271_checa_transportes() THEN
            RETURN FALSE
         END IF
      END IF
   ELSE
      LET p_den_erro = 'TIPO DE FRETE INVALIDO'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_roma.industrializacao = 'S' THEN
   
      LET p_roma.codtipfrete = 'F'
      
      UPDATE romaneio_885
         SET codtipfrete = 'F'
       WHERE codempresa = p_cod_empresa
         AND numromaneio  = p_num_solicit
         AND NumSequencia = p_num_sequencia

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','romaneio_885.cop_roma')
         RETURN FALSE
      END IF
      
   END IF   
   
   IF p_roma.codtipfrete = 'F' THEN 
      LET m_ies_frete = 3
      LET m_ies_modalidade = '1'
   ELSE
      IF p_roma.codtipfrete = '9' THEN
         LET m_ies_frete = 3
         LET m_ies_modalidade = '9' #ou 0
      ELSE
         LET m_ies_frete = 1
         LET m_ies_modalidade = '0'
      END IF      
   END IF         

   IF NOT pol1271_conta_item() THEN
      RETURN FALSE
   END IF
   
   IF p_qtd_item = 0 THEN
      LET p_den_erro = 'ROMANEIO SEM OS ITENS CORRESPONDENTES'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   ELSE   
      IF NOT pol1271_consiste_itens() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1271_conta_item()
#----------------------------#

   SELECT COUNT(numseqpai)
     INTO p_qtd_item
     FROM roma_item_885
    WHERE codempresa  = p_roma.codempresa
      AND numseqpai   = p_roma.numsequencia
      AND numromaneio  = p_num_solicit #28/07/17
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','roma_item_885')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1271_checa_cli_transp()
#---------------------------------#

   IF p_roma.coderptranspor IS NULL OR p_roma.coderptranspor = ' ' THEN
   ELSE
      SELECT cod_cliente
        FROM clientes
       WHERE cod_cliente = p_roma.coderptranspor
   
      IF STATUS = 100 THEN
         LET p_den_erro = 'TRANSPORTADORA NAO CADASTRADA NO LOGIX:CLIENTES'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
  END IF
  
  RETURN TRUE

END FUNCTION  

#------------------------------------#
FUNCTION pol1271_checa_transportes()
#------------------------------------#

   IF p_roma.coderptranspor IS NULL THEN
      LET p_den_erro = 'CODIGO DO TRNSPORTADOR ESTA NULO'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      SELECT cod_cliente
        FROM clientes
       WHERE cod_cliente = p_roma.coderptranspor
         AND (cod_tip_cli = p_cod_transp OR cod_tip_cli = p_cod_transp_auto)
   
      IF STATUS = 100 THEN
         LET p_den_erro = 'TRANSPORTADORA NAO CADASTRADA NO LOGIX'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','clientes')
            RETURN FALSE
         END IF
      END IF
   END IF
   
   IF p_roma.codveiculo IS NULL THEN
      LET p_den_erro = 'CODIGO DO VEICULO ESTA NULO'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_roma.codtipcarga IS NULL THEN
      LET p_den_erro = 'TIPO DE CARGA ESTA NULO'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_roma.codciddest IS NULL THEN
      LET p_den_erro = 'CIDADE DESTINO ESTA NULO'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      SELECT cod_cidade
        FROM cidades
       WHERE cod_cidade = p_roma.codciddest
   
      IF STATUS = 100 THEN
         LET p_den_erro = 'CIDADE DESTINO NAO CADASTRADA NO LOGIX'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cidades')
            RETURN FALSE
         END IF
      END IF
   
   END IF

   IF p_roma.valfrete IS NULL OR p_roma.valfrete <= 0 THEN
      LET p_den_erro = 'VALOR DO FRETE ENVIADO INVALIDO'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

{   IF NOT p_criticou THEN
      IF p_roma.codtipfrete = 'R' THEN
         SELECT val_frete
           FROM frete_rota_885
          WHERE cod_empresa      = p_roma.codempresa
            AND cod_transpor     = p_roma.coderptranspor
            AND cod_veiculo      = p_roma.codveiculo
            AND cod_tip_carga    = p_roma.codtipcarga
            AND cod_cid_orig     = p_cod_cid_orig
            AND cod_cid_dest     = p_roma.codciddest
            AND ies_versao_atual = 'S'
         IF STATUS = 100 THEN 
            LET p_den_erro = 'DADOS DO TRANSPORTE NAO CADASTRADOS NO POL0746'
            IF NOT pol1271_insere_erro() THEN
               RETURN FALSE
            END IF
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','frete_rota_885')
               RETURN FALSE
            END IF
         END IF
      ELSE
         SELECT val_tonelada
           FROM frete_peso_885
          WHERE cod_empresa      = p_cod_empresa
            AND cod_percurso     = p_roma.codpercurso
            AND ies_versao_atual = 'S'
         IF STATUS = 100 THEN 
            LET p_den_erro = 'DADOS DO TRANSPORTE NAO CADASTRADOS NO POL0747'
            IF NOT pol1271_insere_erro() THEN
               RETURN FALSE
            END IF
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','frete_peso_885')
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF   }

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1271_troca_item()#
#----------------------------#

   DEFINE p_num_docum       LIKE ordens.num_docum,
          p_seq_txt         CHAR(10),
          item_novo         CHAR(15)
   
   #LET p_num_docum = p_numpedido
   #LET p_seq_txt = p_numseqitem USING '<<<'
   #LET p_num_docum = p_num_docum CLIPPED, '/', p_seq_txt
   
   SELECT cod_item_pai
     INTO item_novo
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_docum = p_num_docum
      AND cod_item = p_coditem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ordens')
      RETURN FALSE
   END IF  
   
   UPDATE roma_item_885
      SET coditem = item_novo,
          itemorigem = p_coditem
    WHERE codempresa = p_cod_empresa
      AND numsequencia = p_numsequencia
      AND numromaneio  = p_num_solicit #28/07/17
      
   LET p_coditem = item_novo
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1271_rateia_peso()
#-----------------------------#
   
   DEFINE p_coefic_liq     DECIMAL(17,9),
          p_coefic_bru     DECIMAL(17,9),
          l_peso_liq       DECIMAL(10,3),
          l_peso_bru       DECIMAL(10,3)
   
   LET l_peso_liq =  p_roma.pesoliquido
   LET l_peso_bru =  p_roma.pesobalanca
   #LET p_num_solicit = 1001
   #LET p_num_sequencia = 1
   
   SELECT SUM(pesoliqcarregado),
          SUM(pesocarregado)
     INTO p_pesoliqcarregado, p_pesocarregado
     FROM roma_item_885
    WHERE codempresa  = p_cod_empresa
      AND numromaneio = p_num_solicit
      AND numseqpai   = p_num_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','roma_item_885:sum')
      RETURN FALSE
   END IF
   
   IF p_pesoliqcarregado IS NULL THEN
      LET p_pesoliqcarregado = 0
   END IF

   IF p_pesocarregado IS NULL THEN
      LET p_pesocarregado = 0
   END IF
   
   IF p_pesoliqcarregado <= 0 THEN
      LET p_den_erro = 'PESO TEORICO LIQUIDO CARREGADO DO ITEM NAO INFORMADO'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_pesocarregado <= 0 THEN
      LET p_den_erro = 'PESO TEORICO BRUTO CARREGADO DO ITEM NAO INFORMADO'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_pesocarregado < p_pesoliqcarregado THEN
      LET p_den_erro = 'PESO TEORICO BRUTO DO ITEM  MENOR QUE PESO TEORICO LIQUIDO'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_criticou_item THEN
      RETURN TRUE
   END IF
   
   LET p_coefic_liq = l_peso_liq / p_pesoliqcarregado
   LET p_coefic_bru = l_peso_bru / p_pesocarregado

   UPDATE roma_item_885
      SET pesoitem = pesoliqcarregado * p_coefic_liq, 
          pesobrutoitem = pesocarregado * p_coefic_bru
    WHERE codempresa  = p_cod_empresa
      AND numromaneio = p_num_solicit
      AND numseqpai   = p_num_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','roma_item_885:pesos')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1271_consiste_itens()
#-------------------------------#
   
   DEFINE p_itemorigem CHAR(15)

   LET p_criticou_item = FALSE
   
   IF p_faturar = 'T' THEN
      IF NOT pol1271_rateia_peso() THEN
         RETURN FALSE
      END IF
   
      IF p_criticou_item THEN
         RETURN TRUE
      END IF
   END IF

   DELETE FROM roma_tmp_885   
       
   DECLARE cq_ci CURSOR FOR
    SELECT numsequencia,
           tipooperacao,
           numromaneio,
           numpedido,
           numseqitem,
           coditem,
           numlote,
           largura,
           diametro,
           tubete,
           comprimento,
           qtdpecas,
           codcarteira,
           numsequencia,
           pesoitem,
           pesobrutoitem,
           itemorigem
      FROM roma_item_885
     WHERE codempresa  = p_cod_empresa
       AND numromaneio = p_num_solicit
       AND numseqpai   = p_num_sequencia
     ORDER BY numpedido, numseqitem
   
   FOREACH cq_ci INTO 
           p_numsequencia,
           p_tipooperacao,
           p_numromaneio,
           p_numpedido,
           p_numseqitem,
           p_coditem,
           p_numlote,
           p_largura,
           p_diametro,
           p_tubete,
           p_comprimento,
           p_qtdpecas,
           p_codcarteira,
           p_numsequencia,
           p_peso_romaneio,
           p_peso_romaneiob,
           p_itemorigem

      IF STATUS <> 0 THEN
        CALL log003_err_sql('Lendo','roma_item_885:cq_ci')
        RETURN FALSE
      END IF
      
      LET p_num_docum = p_numlote
      
      LET p_ies_chapa = FALSE
   
      IF p_tip_trim = 'B' THEN
         SELECT DISTINCT cod_empresa
           FROM item_chapa_885        
          WHERE cod_empresa   = p_cod_empresa
            AND num_pedido    = p_numpedido
            AND num_sequencia = p_numseqitem
   
         IF STATUS = 0 THEN #É um peido de chapa
            LET p_ies_chapa = TRUE
            IF p_itemorigem IS NULL OR p_itemorigem = ' ' THEN
               IF NOT pol1271_troca_item() THEN
                  RETURN FALSE
               END IF            
            END IF
         END IF
      END IF
            
      LET p_criticou_item = FALSE
      
      IF p_numpedido IS NULL OR p_numpedido = 0 THEN
         LET p_den_erro = 'NUM PEDIDO DA SEQ.',p_numsequencia,' INVALIDO'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol1271_consiste_pedidos() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_tipooperacao IS NULL OR p_tipooperacao <> p_roma.tipooperacao THEN
         LET p_den_erro = 'TIP OPERACAO DA SEQ.',p_numsequencia,' DO ROMANEIO INVALIDA'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
       
      IF p_numromaneio IS NULL OR p_numromaneio = 0 OR 
         p_numromaneio <> p_num_solicit THEN 
         LET p_den_erro = 'NUM ROMANEIO DA SEQ.',p_numsequencia,' DA INVALIDO'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_numseqitem IS NULL OR p_numseqitem = 0 THEN
         LET p_den_erro = 'NUMERO DE SEQUENCIA DO PEDIDO INVALIDO'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_coditem IS NULL OR p_coditem = 0 THEN
         LET p_den_erro = 'CODIGO DO ITEM INVALIDO'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
      
      CALL pol1271_le_item(p_coditem)
      
      IF STATUS = 100 THEN
         LET p_den_erro = 'ITEM ENVIADO NAO CADASTRADO'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
      
      IF p_numlote = ' ' THEN
         LET p_numlote = NULL
      END IF
      
      IF p_ctr_lote = 'S' THEN
         IF p_numlote IS NULL THEN
            LET p_den_erro = 'NUMERO DO LOTE NAO ENVIADO'
            IF NOT pol1271_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      ELSE
         LET p_numlote = NULL
      END IF

      IF NOT pol1271_le_item_ctr_grade(p_coditem) THEN
         RETURN FALSE
      END IF

      IF p_ies_largura = 'S' THEN 
         IF p_largura IS NULL THEN
            LET p_den_erro = 'DIMENSIONAL LARGURA INVALIDO'
            IF NOT pol1271_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      ELSE
         LET p_largura = 0
      END IF

      IF p_ies_altura = 'S' THEN
         IF p_tubete IS NULL THEN
            LET p_den_erro = 'DIMENSIONAL ALTURA INVALIDO'
            IF NOT pol1271_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      ELSE
         LET p_tubete = 0
      END IF

      IF p_ies_diametro = 'S' THEN
         IF p_diametro IS NULL THEN
            LET p_den_erro = 'DIMENSIONAL DIAMETRO INVALIDO'
            IF NOT pol1271_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      ELSE
         LET p_diametro = 0
      END IF

      IF p_ies_comprimento = 'S' THEN
         IF p_comprimento IS NULL THEN
            LET p_den_erro = 'DIMENSIONAL COMPRIMENTO INVALIDO'
            IF NOT pol1271_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      ELSE
         LET p_comprimento = 0
      END IF

      IF p_qtdpecas IS NULL OR p_qtdpecas = 0 THEN
         LET p_den_erro = 'QUANTIDADE DE PECAS INVALIDA'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_peso_romaneio IS NULL THEN
         LET p_den_erro = 'PESO LIQUIDO DO ITEM ESTA NULO'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_peso_romaneiob IS NULL THEN
         LET p_den_erro = 'PESO BRUTO DO ITEM ESTA NULO'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
           
      IF NOT p_criticou_item THEN
         IF NOT pol1271_checa_saldo() THEN
            RETURN FALSE
         END IF              
      END IF

      IF p_criticou_item THEN
         UPDATE roma_item_885
            SET statusregistro = '2'
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_numsequencia
            AND numromaneio  = p_num_solicit #28/07/17
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Atualizando','roma_item_885')
            RETURN FALSE
         END IF
      END IF

   END FOREACH

   RETURN TRUE
            
END FUNCTION

#-----------------------------#
FUNCTION pol1271_checa_saldo()
#-----------------------------#
      
   SELECT pct_desc_valor,
          pct_desc_qtd
     INTO p_pct_desc_valor,
          p_pct_desc_qtd
     FROM desc_nat_oper_885
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_numpedido
	
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','desc_nat_oper_885:cs')
      RETURN FALSE
   END IF
      
   IF p_pct_desc_qtd > 0 THEN
      LET p_pct_reservar = 100 - p_pct_desc_qtd
   ELSE
      LET p_pct_reservar = 100
   END IF
   
   LET p_qtd_romanear = p_qtdpecas # * p_pct_reservar / 100
   
   IF p_qtd_romanear > 0 THEN             
      IF NOT pol1271_tem_saldo() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1271_tem_saldo()
#---------------------------#
  
  DEFINE p_local          LIKE item.cod_local_estoq,
         l_qtd_tot_roma   DECIMAL(10,3),
         l_lote           CHAR(15) 
       
  SELECT cod_local_estoq,
         ies_ctr_lote,
         cod_unid_med,
         ies_tip_item
    INTO p_local,
         p_ctr_lote,
         p_cod_unid_med,
         p_ies_tip_item
    FROM item
   WHERE cod_empresa = p_cod_empresa
     AND cod_item    = p_coditem
 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item:local')
      RETURN FALSE
   END IF  

   IF m_ies_indus THEN
      LET p_local = m_cod_local_estoq
   END IF
      
  IF p_ctr_lote = 'N' THEN
     LET l_lote = 'NULL'
      SELECT SUM(qtd_saldo)
        INTO p_qtd_saldo
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_coditem
         AND cod_local     = p_local
         AND largura       = p_largura
         AND altura        = p_tubete
         AND diametro      = p_diametro
         AND comprimento   = p_comprimento
         AND ies_situa_qtd IN ('L','E')
         AND num_lote      IS NULL
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_lote_ender:1')
         RETURN FALSE
      END IF  

      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada
        FROM estoque_loc_reser a,
             est_loc_reser_end b
       WHERE a.cod_empresa = p_cod_empresa
         AND a.cod_item    = p_coditem
         AND a.cod_local   = p_local
         AND a.num_reserva = b.num_reserva
         AND b.largura     = p_largura
         AND b.altura      = p_tubete
         AND b.diametro    = p_diametro
         AND b.comprimento = p_comprimento
         AND a.num_lote    IS NULL
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_loc_reser:ts')
         RETURN FALSE
      END IF  
         
   ELSE
      LET l_lote = p_numlote
      SELECT SUM(qtd_saldo)
        INTO p_qtd_saldo
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_coditem
         AND cod_local     = p_local
         AND num_lote      = p_numlote
         AND largura       = p_largura
         AND altura        = p_tubete
         AND diametro      = p_diametro
         AND comprimento   = p_comprimento
         AND ies_situa_qtd IN ('L','E')

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_lote_ender:1')
         RETURN FALSE
      END IF  

      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada
        FROM estoque_loc_reser a,
             est_loc_reser_end b
       WHERE a.cod_empresa = p_cod_empresa
         AND a.cod_item    = p_coditem
         AND a.cod_local   = p_local
         AND a.num_lote    = p_numlote
         AND a.num_reserva = b.num_reserva
         AND b.largura     = p_largura
         AND b.altura      = p_tubete
         AND b.diametro    = p_diametro
         AND b.comprimento = p_comprimento
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_loc_reser:ts')
         RETURN FALSE
      END IF  

   END IF   

   IF p_qtd_saldo IS NULL THEN 
      LET p_qtd_saldo = 0 
   END IF

   IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
      LET p_qtd_reservada = 0
   END IF
       
   IF p_qtd_saldo > p_qtd_reservada THEN
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
   ELSE
      LET p_qtd_saldo = 0
   END IF

   SELECT SUM(qtd_tot_roma)
     INTO l_qtd_tot_roma
     FROM roma_tmp_885
    WHERE cod_item = p_coditem
    GROUP BY cod_item

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','roma_tmp_885:ts')
      RETURN FALSE
   END IF  
   
   IF l_qtd_tot_roma IS NULL THEN
      LET l_qtd_tot_roma = 0
   END IF
   
   INSERT INTO roma_tmp_885 VALUES(p_coditem, p_qtd_romanear)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','roma_tmp_885:ts')
      RETURN FALSE
   END IF  
   
   IF p_cod_empresa = '01' AND p_tip_trim = 'B' THEN
      LET p_qtd_saldo = p_qtd_saldo - l_qtd_tot_roma
   END IF
      
   IF p_qtd_saldo IS NULL OR p_qtd_saldo < 0 THEN
      LET p_qtd_saldo = 0
   END IF
   
   IF p_qtd_saldo < p_qtd_romanear THEN
      
      LET p_eh_conjunto = FALSE
      LET m_ies_chapa = 'N'

      IF p_ies_chapa AND p_tipo_processo <> 4 THEN
         LET m_ies_chapa = 'S'
      ELSE
         IF p_cod_empresa = '01' AND p_tip_trim = 'B' THEN
            IF NOT pol1271_ve_se_eh_conjunto() THEN   
               RETURN FALSE
            END IF
         ELSE
            LET m_ies_chapa = 'N'
         END IF         
      END IF
      
      IF p_eh_conjunto {OR m_ies_chapa = 'S'} THEN
         LET p_qtd_romanear = p_qtd_romanear - p_qtd_saldo
         IF NOT pol1271_aponta_item() THEN  #se o item for um conjunto, apontar
            RETURN FALSE                    
         END IF                    
      ELSE         
         {LET p_saldo_txt = p_qtd_saldo USING '<<<<<<<<<<'
         LET p_pecas_txt = p_qtd_romanear USING '<<<<<<<<<<'
         LET p_saldo_txt = p_saldo_txt CLIPPED, ' X ', p_pecas_txt CLIPPED
         LET p_den_erro = 'PED ',p_numpedido USING '<<<<<<'
         LET p_den_erro = p_den_erro CLIPPED, '/', p_numseqitem USING '<<<'         
         LET p_den_erro = p_den_erro CLIPPED, ' IT ',p_coditem CLIPPED,
             ' S/ SALDO ', p_saldo_txt}
         LET p_den_erro = ' IT ',p_coditem CLIPPED, ' LOTE ', l_lote CLIPPED, ' S/ SALDO SUFICIENTE'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF      

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1271_consiste_pedidos()
#----------------------------------#
   
   DEFINE p_item_pedido CHAR(15),
          p_txt         CHAR(10)
   
   SELECT tipo_processo
     INTO p_tipo_processo
     FROM tipo_pedido_885
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_numpedido         
      
   IF STATUS <> 0 THEN                                                               
      CALL log003_err_sql('Lendo','tipo_pedido_885')                                         
      RETURN FALSE                                                                   
   END IF                                                                         

   SELECT ies_sit_pedido,                                                               
          cod_cliente,                                                                  
          cod_nat_oper,                                                                 
          cod_tip_carteira,
          ies_frete,
          cod_local_estoq                                                             
     INTO p_ies_sit_pedido,                                                             
          p_cod_cliente,                                                                
          p_cod_nat_oper,                                                               
          p_cod_tip_carteira,
          p_ies_frete,
          m_cod_local_estoq                                                          
     FROM pedidos                                                                       
    WHERE cod_empresa = p_cod_empresa                                                   
      AND num_pedido  = p_numpedido                                                     
                                                                                     
   IF STATUS = 100 THEN                                                                 
      LET p_den_erro = 'PEDIDO ',p_numpedido,' NAO EXITE'                          
      IF NOT pol1271_insere_erro() THEN                                                 
         RETURN FALSE                                                                   
      END IF                                                                            
   ELSE                                                                                 
      IF STATUS <> 0 THEN                                                               
         CALL log003_err_sql('Lendo','pedidos')                                         
         RETURN FALSE                                                                   
      END IF                                                                            
   END IF                                                                               
                                                                                     
   IF p_codcarteira IS NULL  OR p_codcarteira = ' ' THEN                                
                                                                                        
       UPDATE roma_item_885                                                             
          SET codcarteira  = p_cod_tip_carteira                                         
        WHERE numsequencia = p_numsequencia             
          AND numromaneio  = p_num_solicit #28/07/17     
          AND codempresa   = p_cod_empresa                           
                                                                                     
       IF STATUS <> 0 THEN                                                              
          CALL log003_err_sql('Atualizando','roma_item_885')                            
          RETURN FALSE                                                                  
       END IF                                                                           
   END IF                                                                               
                                                                                        
   IF p_ies_sit_pedido = '9' THEN                                                       
      LET p_den_erro = 'PEDIDO ',p_numpedido,' ESTA CANCELADO'                          
      IF NOT pol1271_insere_erro() THEN                                                 
         RETURN FALSE                                                                   
      END IF                                                                            
   END IF                                                                               

   IF p_ies_sit_pedido = 'Z' THEN                                                       
      LET p_den_erro = 'PEDIDO ',p_numpedido,' ESTA FINALIZADO'                          
      IF NOT pol1271_insere_erro() THEN                                                 
         RETURN FALSE                                                                   
      END IF                                                                            
   END IF                                                                               
                                                                                     
   IF p_ies_sit_pedido = 'B' THEN                                                       
      LET p_den_erro = 'PEDIDO ',p_numpedido,' ESTA BLOQUEADO'                          
      IF NOT pol1271_insere_erro() THEN                                                 
         RETURN FALSE                                                                   
      END IF                                                                            
   END IF                                                                               
                                                                                        
   IF p_ies_sit_pedido = 'S' THEN                                                       
      LET p_den_erro = 'PEDIDO ',p_numpedido,' ESTA SUSPENSO'                           
      IF NOT pol1271_insere_erro() THEN                                                 
         RETURN FALSE                                                                   
      END IF                                                                            
   END IF                                                                               
                                                                                     
   IF p_ies_sit_pedido = 'O' THEN                                                       
      LET p_den_erro = 'PEDIDO ',p_numpedido,' STATUS:O - FATURAMENTO NAO PERMITIDO'    
      IF NOT pol1271_insere_erro() THEN                                                 
         RETURN FALSE                                                                   
      END IF                                                                            
   END IF                                                                               
                                                                                        
   IF p_ies_sit_pedido <> 'F' AND p_ies_sit_pedido <> 'A' THEN                          
      #IF NOT pol1271_verifica_credito() THEN                                           
      #   RETURN FALSE                                                                  
      #END IF                                                                           
   END IF                                                                               

   SELECT COUNT(cod_empresa)
     INTO p_count
     FROM pedido_finalizado_885
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_numpedido
      AND num_sequencia = p_numseqitem

   IF STATUS <> 0 THEN                                                              
      CALL log003_err_sql('SELECT','pedido_finalizado_885')                            
      RETURN FALSE                                                                  
   END IF                                                                           
   
   IF p_count > 0 THEN                                                       
      LET p_den_erro = 'PEDIDO ',p_numpedido USING '<<<<<<'
      LET p_den_erro = p_den_erro CLIPPED, ' SEQUENCIA ', p_numseqitem USING '<<<'
      LET p_den_erro = p_den_erro CLIPPED, ' JA FINALIZADO'
      IF NOT pol1271_insere_erro() THEN                                                 
         RETURN FALSE                                                                   
      END IF                                                                            
   END IF                                                                               


   IF p_cod_nat_oper IS NULL OR p_cod_nat_oper = ' ' THEN    
   ELSE                                                                                 
      SELECT ies_tip_controle                                                              
        INTO p_ies_tip_controle                                                            
        FROM nat_operacao                                                                  
       WHERE cod_nat_oper = p_cod_nat_oper                                                 
      
      IF STATUS = 100 THEN   
         LET p_msg = 'NATUREZA DE OPRACAO ',p_cod_nat_oper, '\n',
                     'NAO CADASTRADA.'
         IF NOT pol1271_insere_erro() THEN                                                 
            RETURN FALSE                                                                   
         END IF               
      ELSE                                                             
         IF STATUS <> 0 THEN                                                                  
            CALL log003_err_sql('Lendo','nat_operacao')                                       
            RETURN FALSE                                                                      
         ELSE
            IF p_ies_tip_controle = '8' THEN                                                     
               LET p_den_erro = 'PEDIDO ',p_numpedido,'C/ NAT.OPER. VENDA FURURA'                
               IF NOT pol1271_insere_erro() THEN                                                 
                  RETURN FALSE                                                                   
               END IF                                                                            
            END IF
         END IF                                                                               
      END IF                                                                               
   END IF
             
   SELECT cod_item
     INTO p_item_pedido
     FROM ped_itens
    WHERE cod_empresa = p_cod_empresa                                                   
      AND num_pedido  = p_numpedido     
      AND num_sequencia = p_numseqitem                                              
    
   IF STATUS <> 0 THEN                                                                  
      CALL log003_err_sql('Lendo','ped_itens')                                       
      RETURN FALSE                                                                      
   END IF
   
   IF p_item_pedido <> p_coditem THEN
      LET p_txt = p_numpedido
      LET p_den_erro = 'PEDIDO: ',p_txt CLIPPED,' ', 'SEQ.: ', p_numseqitem USING '<<<',
                       ': O ITEM ENVIADO E <> DO ITEM DO PEDIDO'  
      IF NOT pol1271_insere_erro() THEN                                                 
         RETURN FALSE                                                                   
      END IF                                                                            
   END IF                                                                               
                                                                                      
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1271_verifica_credito()
#----------------------------------#

   DEFINE lr_par_vdp           RECORD LIKE par_vdp.*,
          lr_cli_credito       RECORD LIKE cli_credito.*,
          l_valor_cli          DECIMAL(15,2),
          l_parametro          CHAR(1)
          
   SELECT *
     INTO lr_cli_credito.*
     FROM cli_credito
    WHERE cod_cliente = p_cod_cliente
      
   IF sqlca.sqlcode <> 0 THEN
      LET p_den_erro = 'CLIENTE SEM DADOS DE CREDITO'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   SELECT *
     INTO lr_par_vdp.*
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF lr_par_vdp.par_vdp_txt[367] = 'S' THEN
      IF lr_cli_credito.qtd_dias_atr_dupl > lr_par_vdp.qtd_dias_atr_dupl THEN
         LET p_den_erro = 'CLIENTE COM DUPLICATAS EM ATRASO EXCEDIDO'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
      IF lr_cli_credito.qtd_dias_atr_med > lr_par_vdp.qtd_dias_atr_med THEN
         LET p_den_erro = 'CLIENTE COM ATRASO MEDIO EXCEDIDO'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
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
         LET p_den_erro = 'LIMITE DE CREDITO EXCEDIDO'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF lr_cli_credito.dat_val_lmt_cr IS NOT NULL THEN
      IF lr_cli_credito.dat_val_lmt_cr < TODAY THEN
         LET p_den_erro = 'DATA CREDITO EXPIRADA'
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF    
   
   RETURN TRUE

END FUNCTION


#-----------------------------#
FUNCTION pol1271_insere_erro()
#-----------------------------#

   LET p_statusRegistro = '2'
   LET p_criticou      = TRUE
   LET p_criticou_item = TRUE
   LET p_dat_hor = CURRENT YEAR TO SECOND
   
   INSERT INTO roma_erro_885
    VALUES(p_cod_empresa,
           p_numsequencia,
           p_num_solicit,
           p_den_erro,
           p_dat_hor)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','roma_erro_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1271_grava_roma()
#-----------------------------#

   UPDATE romaneio_885
      SET StatusRegistro = p_statusRegistro
    WHERE codempresa   = p_cod_empresa
      AND NumSequencia = p_num_sequencia
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','romaneio_885')
      RETURN FALSE
   END IF
   
   IF p_statusRegistro = 1 THEN
      UPDATE roma_item_885
         SET StatusRegistro = '1'
       WHERE codempresa  = p_cod_empresa
         AND numseqpai   = p_num_sequencia
         AND numromaneio = p_num_solicit

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Atualizando','romaneio_885')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION


#------------------------------#
FUNCTION pol1271_pega_lote_om()
#------------------------------#

      SELECT MAX(num_lote_om)
        INTO l_num_lote_om
        FROM ordem_montag_lote
       WHERE cod_empresa = p_cod_empresa
      
      IF l_num_lote_om IS NULL THEN
         LET l_num_lote_om = 0
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','ordem_montag_lote')
            RETURN FALSE
         END IF
      END IF

      LET l_num_lote_om = l_num_lote_om + 1
        
      SELECT num_ult_om
        INTO l_num_om
        FROM par_vdp
       WHERE cod_empresa = p_cod_empresa

      IF l_num_om IS NULL THEN
         LET l_num_om = 0
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','par_vdp')
            RETURN FALSE
         END IF
      END IF

      LET l_num_om = l_num_om + 1
 
      UPDATE par_vdp
         SET num_ult_om = l_num_om
       WHERE cod_empresa = p_cod_empresa

      IF STATUS <> 0 THEN
         CALL log003_err_sql('atualizando','par_vdp')
	       RETURN FALSE
    	END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1271_le_desconto()#
#-----------------------------#

      SELECT pct_desc_valor,
             pct_desc_qtd
        INTO p_pct_desc_valor,
             p_pct_desc_qtd
        FROM desc_nat_oper_885
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_num_pedido
	
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','desc_nat_oper_885')
         RETURN FALSE
      END IF
      
      IF p_pct_desc_qtd > 0 THEN
         LET p_pct_romanear = 100 - p_pct_desc_qtd
         LET p_pct_cancelar = p_pct_desc_qtd / 100
      ELSE
         LET p_pct_romanear = 100
         LET p_pct_cancelar = 0
      END IF
      
      RETURN TRUE

END FUNCTION
      
#--------------------------------#
FUNCTION pol1271_insere_solicit()
#--------------------------------#

   IF NOT pol1271_cria_om_tmp() THEN
      RETURN FALSE
   END IF
   
   SELECT SUM(pesobrutoitem)
     INTO p_peso_carga
     FROM roma_item_885
    WHERE codempresa  = p_roma.codempresa
      AND numseqpai   = p_roma.numsequencia
      AND numromaneio  = p_num_solicit #28/07/17

   IF STATUS <> 0 THEN
      CALL log003_err_sql('lendo','roma_item_885')
      RETURN FALSE
   END IF
               
   LET p_gerou_solicit = FALSE
   
   DECLARE cq_pedido CURSOR FOR
    SELECT DISTINCT numpedido
      FROM roma_item_885
     WHERE codempresa  = p_roma.codempresa
       AND numseqpai   = p_roma.numsequencia
       AND numromaneio  = p_num_solicit #28/07/17
    ORDER BY numpedido
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('lendo','roma_item_885:cq_pedido')
      RETURN FALSE
   END IF

   FOREACH cq_pedido INTO p_num_pedido

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_pedido')
         RETURN FALSE
      END IF

      IF NOT pol1271_le_desconto() THEN
         RETURN FALSE
      END IF

      IF NOT pol1271_cria_item_roma_tmp() THEN
         RETURN FALSE
      END IF
      
	    DECLARE cq_roma_it CURSOR FOR
	    SELECT numseqitem,
	           coditem,
	           numlote,
	           largura,
	           diametro,
	           tubete,
	           comprimento,
	           pesoitem,
	           pesobrutoitem,
	           qtdpecas,
	           qtdvolumes,
	           tolmais,
	           codcarteira
	      FROM roma_item_885
	     WHERE codempresa  = p_roma.codempresa
	       AND numseqpai   = p_roma.numsequencia
	       AND numpedido   = p_num_pedido
	       AND numromaneio  = p_num_solicit #28/07/17
	     ORDER BY numseqitem
	     
	    FOREACH cq_roma_it INTO    
          p_item_roma.num_sequencia,
          p_item_roma.cod_item,
          p_item_roma.numlote,
          p_item_roma.largura,
          p_item_roma.diametro,
          p_item_roma.altura,
          p_item_roma.comprimento,
          p_item_roma.pes_item,
          p_item_roma.pes_itemb,
          p_item_roma.qtd_reservada,
          p_item_roma.qtd_volumes,
          p_tolmais,
          p_cod_tip_carteira

         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','roma_item_885:cq_roma_it')
            RETURN FALSE
         END IF
         
         IF NOT pol1271_le_item_ctr_grade(p_item_roma.cod_item) THEN
            RETURN FALSE
         END IF

         IF p_ies_largura = 'S' THEN 
         ELSE
            LET p_item_roma.largura = 0
         END IF

         IF p_ies_altura = 'S' THEN 
         ELSE
            LET p_item_roma.altura = 0
         END IF

         IF p_ies_comprimento = 'S' THEN 
         ELSE
            LET p_item_roma.comprimento = 0
         END IF

         IF p_ies_diametro = 'S' THEN 
         ELSE
            LET p_item_roma.diametro = 0
         END IF
                 
         INSERT INTO item_roma_tmp
           VALUES(p_item_roma.*)
           
   	     IF STATUS <> 0 THEN
            CALL log003_err_sql('inserindo','item_roma_tmp')
	          RETURN FALSE
	       END IF
	       
	       IF NOT pol1271_trata_tolerancia() THEN
	          RETURN FALSE
	       END IF

         SELECT ies_itens_nff
           INTO p_ies_itens_nff
           FROM tipo_carteira
          WHERE cod_tip_carteira = p_cod_tip_carteira

         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','tipo_carteira')
            RETURN FALSE
         END IF
         
         IF p_ies_itens_nff = 'S' THEN
            IF NOT pol1271_gerar() THEN
               RETURN FALSE
            END IF
            
            DELETE FROM item_roma_tmp
            IF STATUS <> 0 THEN
               CALL log003_err_sql('deletando','item_roma_tmp')
               RETURN FALSE
            END IF
            
         END IF         
        
      END FOREACH

      SELECT COUNT(cod_item)
        INTO p_qtd_itens
        FROM item_roma_tmp
        
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','item_roma_tmp:cod_item')
	       RETURN FALSE
	    END IF
        
      IF p_qtd_itens > 0 THEN
         IF NOT pol1271_gerar() THEN
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH
  
   IF p_roma.codtipfrete <> 'F' THEN
      SELECT COUNT(num_om)
        INTO p_count
        FROM om_tmp_885
     
      IF p_count > 0 THEN 
         IF p_faturar = 'T' THEN
            IF NOT pol1271_grava_frete_885() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF
   
   RETURN TRUE
  
END FUNCTION

#-----------------------# 
FUNCTION pol1271_gerar()
#-----------------------# 
         
   IF p_faturar = 'T' THEN
      IF NOT pol1271_pega_lote_om() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_pct_romanear > 0 THEN
      IF NOT pol1271_gera_roma() THEN
         RETURN FALSE
      END IF
   END IF
          
   RETURN TRUE
   
END FUNCTION
#----------------------------------#
FUNCTION pol1271_trata_tolerancia()
#----------------------------------#

   SELECT parametro_val                                                        
     FROM ped_info_compl                                                     
    WHERE empresa = p_cod_empresa                                            
      AND pedido  = p_numpedido                                              
      AND campo   = 'pct_tolerancia_maximo'                                  
                                                                             
   IF STATUS = 100 THEN                                                   
      INSERT INTO ped_info_compl                                             
         VALUES(p_cod_empresa,                                               
                p_numpedido,                                                 
                'pct_tolerancia_maximo',                                     
                NULL,                                                        
                NULL,                                                        
                p_tolmais,                                                   
                NULL,                                                        
                NULL)                                                        
                                                                             
      IF STATUS <> 0 THEN                                                 
	       CALL log003_err_sql('inserindo','ped_info_compl')     
         RETURN FALSE                                                        
	    END IF                                                                 
	 ELSE                                                                      
      UPDATE ped_info_compl                                                  
         SET parametro_val = p_tolmais                                       
       WHERE empresa = p_cod_empresa                                         
         AND pedido  = p_numpedido                                           
         AND campo   = 'pct_tolerancia_maximo'                               
                                                                             
      IF STATUS <> 0 THEN                                                 
	       CALL log003_err_sql('atualizando','ped_info_compl')      
         RETURN FALSE                                                        
	    END IF                                                                 
	                                                                           
   END IF                                                                             

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1271_gera_roma()
#---------------------------#

   DEFINE l_peso_unit         LIKE item.pes_unit,
          l_qtd_padr_embal    LIKE item_embalagem.qtd_padr_embal,
          l_cod_embal_matriz  LIKE embalagem.cod_embal_matriz,
          p_num_lote          LIKE estoque_lote.num_lote,
          p_qtd_saldo         LIKE estoque_lote.qtd_saldo,
          p_qtd_reser         LIKE estoque_lote.qtd_saldo,
          p_qtd_a_reser       LIKE estoque_lote.qtd_saldo,
          p_qtd_ja_reser      LIKE estoque_lote.qtd_saldo,
          p_num_seq           LIKE ped_itens.num_sequencia,
          l_num_reserva       INTEGER,
          l_ind               SMALLINT,
          l_qtd_vol           CHAR(10),
          p_qtd_empenhada     DECIMAL(10,2),
          l_lote              CHAR(15)

   LET p_peso_romaneio  = 0     
   LET p_peso_romaneiob = 0     
   
   IF m_ies_indus THEN
      LET p_roma.coderptranspor = '0'
      LET p_roma.placaveiculo = ''
      LET p_roma.ufveiculo = ''
   END IF
   
   SELECT cod_cliente,
          cod_tip_carteira,
          cod_cnd_pgto,
          ies_frete
     INTO p_cod_cliente,
          l_cod_tip_carteira,
          p_cod_cnd_pgto,
          p_ies_frete
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_num_pedido

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('lendo','pedidos')   
      RETURN FALSE
   END IF

   IF p_faturar = 'P' THEN
      SELECT num_om,
             num_lote_om,
             val_frete,
             val_ger
        INTO l_num_om,
             l_num_lote_om,
             p_val_fret_ofic,
             p_val_fret_ger
        FROM solicit_fat_885
       WHERE cod_empresa = p_cod_empresa
         AND num_solicit = p_num_solicit
         AND num_pedido  = p_num_pedido
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','solicit_fat_885')
         RETURN
      END IF

      UPDATE solicit_fat_885
         SET cod_status = 'N'
       WHERE cod_empresa = p_cod_empresa
         AND num_solicit = p_num_solicit
         AND num_pedido  = p_num_pedido

      IF SQLCA.SQLCODE <> 0 THEN
          CALL log003_err_sql('Atualizando','solicit_fat_885')
          RETURN FALSE
      END IF

   END IF
   
   INSERT INTO ordem_montag_lote 
	  VALUES(p_cod_empresa,
	         l_num_lote_om,
	         'N',
	          0,
	          getdate(),
	          0,
	          l_cod_tip_carteira,
	          NULL,
	          0,
	          0,
	          0)
	
	  IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('inserindo','ordem_montag_lote')   
       RETURN FALSE
	  END IF

   DECLARE cq_tmp CURSOR FOR
    SELECT *
      FROM item_roma_tmp
   
   FOREACH cq_tmp INTO p_item_roma.*

      CALL pol1271_le_item(p_item_roma.cod_item) 
      
      IF m_ies_indus THEN
         LET p_cod_local_estoq = m_cod_local_estoq
      END IF
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','item')
         RETURN FALSE
      END IF

      IF p_ctr_lote = 'S' THEN
         LET p_num_lote = p_item_roma.numlote
      ELSE
         LET p_num_lote = NULL
      END IF

      LET p_qtd_romanear = p_item_roma.qtd_reservada * p_pct_romanear / 100

      IF p_num_lote IS NOT NULL THEN
         LET l_lote = p_num_lote
         SELECT *
           INTO p_estoque_lote_ender.*
           FROM estoque_lote_ender
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_item_roma.cod_item
            AND cod_local   = p_cod_local_estoq
            AND num_lote    = p_num_lote
            AND largura     = p_item_roma.largura
            AND altura      = p_item_roma.altura
            AND diametro    = p_item_roma.diametro
            AND comprimento = p_item_roma.comprimento
            AND ies_situa_qtd IN ('L','E')
            AND qtd_saldo   >= p_qtd_romanear
      ELSE
         LET l_lote = 'NULL'
         SELECT *
           INTO p_estoque_lote_ender.*
           FROM estoque_lote_ender
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_item_roma.cod_item
            AND cod_local   = p_cod_local_estoq
            AND num_lote      IS NULL
            AND largura     = p_item_roma.largura
            AND altura      = p_item_roma.altura
            AND diametro    = p_item_roma.diametro
            AND comprimento = p_item_roma.comprimento
            AND ies_situa_qtd IN ('L','E')
            AND qtd_saldo   >= p_qtd_romanear
      END IF

     IF STATUS <> 0 THEN
         ERROR p_item_roma.cod_item
         CALL log003_err_sql('Lendo','estoque_lote_ender:2')
         RETURN FALSE
      END IF
      
      IF p_num_lote IS NOT NULL THEN
         SELECT SUM(qtd_reservada)
           INTO p_qtd_empenhada
           FROM estoque_loc_reser a,
                est_loc_reser_end b
          WHERE a.cod_empresa = p_cod_empresa
            AND a.cod_item    = p_item_roma.cod_item
            AND a.cod_local   = p_cod_local_estoq
            AND a.num_lote    = p_num_lote
            AND a.num_reserva = b.num_reserva
            AND b.largura     = p_item_roma.largura     
            AND b.altura      = p_item_roma.altura      
            AND b.diametro    = p_item_roma.diametro    
            AND b.comprimento = p_item_roma.comprimento 
      ELSE      
         SELECT SUM(qtd_reservada)
           INTO p_qtd_empenhada
           FROM estoque_loc_reser a,
                est_loc_reser_end b
          WHERE a.cod_empresa = p_cod_empresa
            AND a.cod_item    = p_item_roma.cod_item
            AND a.cod_local   = p_cod_local_estoq
            AND a.num_lote      IS NULL
            AND a.num_reserva = b.num_reserva
            AND b.largura     = p_item_roma.largura     
            AND b.altura      = p_item_roma.altura      
            AND b.diametro    = p_item_roma.diametro    
            AND b.comprimento = p_item_roma.comprimento 
      END IF

     IF STATUS <> 0 THEN
         ERROR p_item_roma.cod_item
         CALL log003_err_sql('Lendo','estoque_loc_reser:2')
         RETURN FALSE
      END IF

      IF p_qtd_empenhada IS NULL OR p_qtd_empenhada < 0 THEN
         LET p_qtd_empenhada = 0
      END IF
      
      LET p_estoque_lote_ender.qtd_saldo = p_estoque_lote_ender.qtd_saldo - p_qtd_empenhada

      IF p_estoque_lote_ender.qtd_saldo < p_item_roma.qtd_reservada THEN # p_qtd_romanear THEN
         LET p_msg = ' IT ',p_item_roma.cod_item CLIPPED, ' LOTE ', l_lote CLIPPED, ' S/ SALDO SUFICIENTE'
         CALL log0030_mensagem(p_msg,'info')
         RETURN FALSE
      END IF

      IF p_estoque_lote_ender.ies_situa_qtd = 'E' THEN
         IF NOT pol1271_transf_situa() THEN
            RETURN FALSE
         END IF
      END IF
            
      INSERT INTO estoque_loc_reser(
             cod_empresa,
             cod_item,
             cod_local,
             qtd_reservada,
             num_lote,
             ies_origem,
             num_docum,
             num_referencia,
             ies_situacao,
             dat_prev_baixa,
             num_conta_deb,
             cod_uni_funcio,
             nom_solicitante,
             dat_solicitacao,
             nom_aprovante,
             dat_aprovacao,
             qtd_atendida,
             dat_ult_atualiz)
           VALUES(p_cod_empresa,
                  p_item_roma.cod_item,
                  p_cod_local_estoq,
                  p_qtd_romanear,
                  p_num_lote,
                  'V',
                  p_num_pedido,
                  NULL,
                  'N',
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  getdate(),
                  NULL,
                  NULL,
                  0,
                  NULL)
   
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('inserindo','estoque_loc_reser')  
         RETURN FALSE
      END IF

      LET l_num_reserva = SQLCA.SQLERRD[2]
      
      INSERT INTO est_loc_reser_end (
						cod_empresa,
						num_reserva,
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
            VALUES(p_cod_empresa,
                   l_num_reserva,
                   p_estoque_lote_ender.endereco,
                   p_estoque_lote_ender.num_volume,
                   p_estoque_lote_ender.cod_grade_1,
                   p_estoque_lote_ender.cod_grade_2,
                   p_estoque_lote_ender.cod_grade_3,
                   p_estoque_lote_ender.cod_grade_4,
                   p_estoque_lote_ender.cod_grade_5,
                   p_estoque_lote_ender.dat_hor_producao,
                   p_estoque_lote_ender.num_ped_ven,
                   p_estoque_lote_ender.num_seq_ped_ven,
                   p_estoque_lote_ender.dat_hor_validade,
                   p_estoque_lote_ender.num_peca,
                   p_estoque_lote_ender.num_serie,
                   p_estoque_lote_ender.comprimento,
                   p_estoque_lote_ender.largura,
                   p_estoque_lote_ender.altura,
                   p_estoque_lote_ender.diametro,
                   p_estoque_lote_ender.dat_hor_reserv_1,
                   p_estoque_lote_ender.dat_hor_reserv_2,
                   p_estoque_lote_ender.dat_hor_reserv_3,
                   p_estoque_lote_ender.qtd_reserv_1,
                   p_estoque_lote_ender.qtd_reserv_2,
                   p_estoque_lote_ender.qtd_reserv_3,
                   p_estoque_lote_ender.num_reserv_1,
                   p_estoque_lote_ender.num_reserv_2,
                   p_estoque_lote_ender.num_reserv_3,
                   p_estoque_lote_ender.tex_reservado)
                   
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('inserindo','est_loc_reser_end')  
         RETURN FALSE
      END IF

      INSERT INTO ordem_montag_grade
            VALUES(p_cod_empresa,
                   l_num_om,
                   p_num_pedido,
                   p_item_roma.num_sequencia,
                   p_item_roma.cod_item,
                   p_qtd_romanear,
                   l_num_reserva,
                   p_estoque_lote_ender.cod_grade_1,
                   p_estoque_lote_ender.cod_grade_2,
                   p_estoque_lote_ender.cod_grade_3,
                   p_estoque_lote_ender.cod_grade_4,
                   p_estoque_lote_ender.cod_grade_5,
                   NULL)
          
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('inserindo','ordem_montag_grade')  
         RETURN FALSE
      END IF

   END FOREACH

   LET l_qtd_volume = 0
   LET p_val_pedido = 0
   LET p_pes_brut_tot = 0
   LET p_pes_liq_tot = 0
   
   DECLARE cq_montag_item CURSOR FOR
    SELECT num_sequencia,
           cod_item,
           SUM(qtd_reservada),
           SUM(qtd_volumes),
           SUM(pes_item),
           SUM(pes_itemb)
      FROM item_roma_tmp
     GROUP BY num_sequencia, cod_item
      
   FOREACH cq_montag_item INTO
           p_item_roma.num_sequencia,
           p_item_roma.cod_item,
           p_item_roma.qtd_reservada,
           p_item_roma.qtd_volumes,
           p_item_roma.pes_item,
           p_item_roma.pes_itemb

      IF STATUS <> 0 THEN     
         CALL log003_err_sql('lendo','item_roma_tmp:cq_montag_item')  
         RETURN FALSE
      END IF
           
      SELECT DISTINCT iespacote
        INTO p_ies_pacote
        FROM roma_item_885
       WHERE codempresa = p_cod_empresa
      	 AND numseqpai  = p_roma.numsequencia
	       AND numpedido  = p_num_pedido
	       AND numseqitem = p_item_roma.num_sequencia
	       AND coditem    = p_item_roma.cod_item
	       AND numromaneio  = p_num_solicit #28/07/17
	       
      IF STATUS <> 0 THEN 
         LET p_ies_pacote = NULL
      END IF

      IF p_ies_pacote IS NULL THEN
         LET p_ies_pacote = 'N'
      END IF
      
      IF p_ies_pacote = 'S' THEN
         LET l_cod_embal_int = p_cod_pacote_bob
      ELSE
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
            AND a.cod_item      = p_item_roma.cod_item
            AND a.cod_embal     = b.cod_embal
            AND a.ies_tip_embal IN ('I','N')

         IF STATUS = 100 THEN   
            LET l_qtd_padr_embal = 0
            LET l_cod_embal_int  = NULL
         ELSE
            IF STATUS = 0 THEN   
               IF l_cod_embal_matriz IS NOT NULL THEN
                  LET l_cod_embal_int = l_cod_embal_matriz
               END IF 	     
            ELSE
               CALL log003_err_sql('lendo','item_embalagem/embalagem') 
               RETURN FALSE
            END IF
         END IF
      END IF
      
      LET p_qtd_romanear = p_item_roma.qtd_reservada * p_pct_romanear / 100
      LET p_qtd_transf = p_item_roma.qtd_reservada - p_qtd_romanear # qtd a transferir p/ sucata
      
      #grava peso cheio na nota, mesmo tendo divisão de quantidade
      
      LET mr_ordem_montag_item.pes_total_item = p_item_roma.pes_item
      LET p_pes_liq_tot = p_pes_liq_tot + mr_ordem_montag_item.pes_total_item
      LET p_pes_brut_tot = p_pes_brut_tot + p_item_roma.pes_itemb
      
      LET mr_ordem_montag_item.cod_empresa     = p_cod_empresa
      LET mr_ordem_montag_item.num_om          = l_num_om
      LET mr_ordem_montag_item.num_pedido      = p_num_pedido
      LET mr_ordem_montag_item.num_sequencia   = p_item_roma.num_sequencia 
      LET mr_ordem_montag_item.cod_item        = p_item_roma.cod_item
      LET mr_ordem_montag_item.qtd_reservada   = p_qtd_romanear
      LET mr_ordem_montag_item.ies_bonificacao = 'N'

      INITIALIZE p_cod_grupo_item TO NULL
      
      SELECT grupo_item.cod_grupo_item
        INTO p_cod_grupo_item
        FROM item_vdp
        LEFT OUTER join grupo_item ON
             item_vdp.cod_grupo_item =  grupo_item.cod_grupo_item
       WHERE item_vdp.cod_empresa    = p_cod_empresa
         AND item_vdp.cod_item       = mr_ordem_montag_item.cod_item 

      IF STATUS = 100 THEN
         CALL log003_err_sql('lendo','item_vdp') 
         RETURN FALSE
      END IF

      IF p_cod_grupo_item IS NULL THEN
         LET p_den_erro = 'GRUPO DO ITEM NÃO LOCALIZADO NAS TABELAS ITEM_VDP/GRUPO_ITEM'
         CALL log0030_mensagem(p_den_erro,'EXCLA')
         RETURN FALSE
      END IF
            
      IF p_cod_grupo_item = '04' THEN
         LET mr_ordem_montag_item.qtd_volume_item = p_item_roma.qtd_volumes
      ELSE
         IF p_qtd_romanear < 100000 THEN
            LET mr_ordem_montag_item.qtd_volume_item = p_qtd_romanear
         ELSE
            LET mr_ordem_montag_item.qtd_volume_item = 0
         END IF
      END IF

      INSERT INTO ordem_montag_item VALUES (mr_ordem_montag_item.*)

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('inserindo','ordem_montag_item') 
         RETURN FALSE
      END IF

      
      SELECT SUM(qtdpacote)
        INTO p_qtd_pacote
        FROM roma_item_885
       WHERE codempresa  = p_roma.codempresa
         AND numseqpai   = p_roma.numsequencia
         AND numpedido   = p_num_pedido
         AND numseqitem  = mr_ordem_montag_item.num_sequencia
         AND numromaneio  = p_num_solicit #28/07/17
      
      LET p_txt_pacote = NULL
   
      IF p_qtd_pacote IS NOT NULL THEN
         IF p_qtd_pacote > 0 THEN
            LET p_txt_pacote = p_qtd_pacote
            LET p_txt_pacote = 'PACOTES: ', p_txt_pacote CLIPPED
         END IF
      END IF   
      
      SELECT den_texto_1
        INTO m_den_texto_1
        FROM ped_itens_texto
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_num_pedido
         AND num_sequencia = mr_ordem_montag_item.num_sequencia
      
      IF STATUS = 0 THEN
         LET m_ies_texto = TRUE
      ELSE
         IF STATUS = 100 THEN
            LET m_ies_texto = FALSE
            LET m_den_texto_1 = NULL
         ELSE
            CALL log003_err_sql('SELECT','ped_itens_texto')
            RETURN FALSE
         END IF
      END IF

      #LET m_num_seq = mr_ordem_montag_item.num_sequencia
      #LET m_num_docum = p_num_pedido USING '<<<<<<','/', m_num_seq USING '<<<'
     
      IF p_tip_trim = 'B' THEN
        SELECT DISTINCT numlote
           INTO m_num_docum
           FROM roma_item_885
          WHERE codempresa = p_cod_empresa
          	 AND numseqpai  = p_roma.numsequencia
	           AND numpedido  = p_num_pedido
	           AND numseqitem = p_item_roma.num_sequencia
	           AND coditem    = p_item_roma.cod_item
	          AND numromaneio  = p_num_solicit 

        IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','roma_item_885:lote')
            RETURN FALSE
         END IF

         IF NOT pol1271_ve_papel(mr_ordem_montag_item.cod_item) THEN
            RETURN FALSE
         END IF      
      END IF
      
      IF m_ies_texto THEN
         UPDATE ped_itens_texto
            SET den_texto_1 = m_den_texto_1,
                den_texto_3 = p_txt_pacote
          WHERE cod_empresa   = p_cod_empresa
            AND num_pedido    = p_num_pedido
            AND num_sequencia = mr_ordem_montag_item.num_sequencia
      ELSE
         INSERT INTO ped_itens_texto(
            cod_empresa,
            num_pedido,
            num_sequencia,
            den_texto_1,
            den_texto_3)
          VALUES(p_cod_empresa,
                 p_num_pedido,
                 mr_ordem_montag_item.num_sequencia,
                 m_den_texto_1,
                 p_txt_pacote)
      END IF
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Gravando','ped_itens_texto')
         RETURN FALSE
      END IF
            
      LET l_qtd_volume = l_qtd_volume + mr_ordem_montag_item.qtd_volume_item
      LET p_qtd_cancelar = p_item_roma.qtd_reservada * p_pct_cancelar

      UPDATE ped_itens 
         SET qtd_pecas_romaneio = qtd_pecas_romaneio + mr_ordem_montag_item.qtd_reservada #,
             #qtd_pecas_cancel = qtd_pecas_cancel + p_qtd_cancelar
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = mr_ordem_montag_item.num_pedido
         AND num_sequencia = mr_ordem_montag_item.num_sequencia
        
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('atualizando','ped_itens') 
         RETURN FALSE
      END IF

      SELECT pre_unit
        INTO p_pre_unit
        FROM ped_itens
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = mr_ordem_montag_item.num_pedido
         AND num_sequencia = mr_ordem_montag_item.num_sequencia

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('Lendo','ped_itens')
         RETURN FALSE
      END IF
      
      LET p_val_pedido = p_val_pedido +
          mr_ordem_montag_item.qtd_reservada * p_pre_unit
      
      IF l_cod_embal_int = 0 OR l_cod_embal_int IS NULL THEN
         LET l_cod_embal_int = 99
      END IF
      
      INSERT INTO ordem_montag_embal 
         VALUES(p_cod_empresa,
                mr_ordem_montag_item.num_om,
                mr_ordem_montag_item.num_sequencia,	
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
         CALL log003_err_sql('Inserindo','ordem_montag_embal')
         RETURN FALSE
      END IF
      
      UPDATE estoque
         SET qtd_reservada = 
             qtd_reservada +  mr_ordem_montag_item.qtd_reservada
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_ordem_montag_item.cod_item
 
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('Atualizando','estoque')
         RETURN FALSE
      END IF
      
      IF p_qtd_transf > 0 THEN
         IF NOT pol1271_transf_sucata() THEN #descomentar
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH
   
	 LET mr_ordem_montag_mest.cod_empresa   = p_cod_empresa
	 LET mr_ordem_montag_mest.num_om        = l_num_om
	 LET mr_ordem_montag_mest.num_lote_om   = l_num_lote_om
	 LET mr_ordem_montag_mest.cod_transpor  = p_roma.coderptranspor
	 LET mr_ordem_montag_mest.qtd_volume_om = l_qtd_volume
	 LET mr_ordem_montag_mest.dat_emis      = TODAY 
   LET mr_ordem_montag_mest.ies_sit_om    = 'N'
	
	 INSERT INTO ordem_montag_mest VALUES (mr_ordem_montag_mest.*)
	
	 IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Inserindo','ordem_montag_mest')
	    RETURN FALSE
	 END IF
	  
	 INSERT INTO om_list 
	     VALUES (p_cod_empresa,
	             mr_ordem_montag_mest.num_om,
	             mr_ordem_montag_item.num_pedido,
	             getdate(),
	             p_user)
	
	 IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Inserindo','om_list')
	    RETURN FALSE
	 END IF
	 
	 LET p_num_pedido = mr_ordem_montag_item.num_pedido

   INSERT INTO om_tmp_885
    VALUES(p_cod_empresa,mr_ordem_montag_mest.num_om, p_val_pedido)

	 IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Inserindo','om_tmp_885')
	    RETURN FALSE
	 END IF

   #IF p_texto_ped IS NULL THEN
      IF NOT pol1271_grava_texto() THEN
         RETURN FALSE
      END IF
   #END IF
   
   IF p_faturar = 'T' THEN
      SELECT COUNT(num_om)
        INTO p_count 
        FROM solicit_fat_885
       WHERE cod_empresa = p_cod_empresa
         AND num_solicit = p_num_solicit
         AND num_om      = l_num_om

     	IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('Lendo','solicit_fat_885')
	       RETURN FALSE
	    END IF
      
      IF p_count = 0 THEN
         DECLARE cq_cid CURSOR FOR
          SELECT codciddest
            FROM roma_item_885
           WHERE codempresa  = p_cod_empresa
             AND numseqpai   = p_num_sequencia
             AND numromaneio = p_num_solicit
             AND numpedido   = p_num_pedido
       
         FOREACH cq_cid INTO p_cod_cid_dest
        	   IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql('Lendo','codciddest')
	             RETURN FALSE
	          END IF
            EXIT FOREACH
         END FOREACH
      
         INSERT INTO solicit_fat_885
          VALUES(p_cod_empresa, 
                 p_num_solicit, 
                 l_num_om, 
                 getdate(), 
                 'N',
                 p_num_pedido,
                 0,
                 l_num_lote_om,
                 p_cod_cid_dest,
                 0)

      	 IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql('Inserindo','solicit_fat_885')
            RETURN FALSE
      	 END IF
   	  END IF
   END IF
   
   LET p_gerou_solicit = TRUE

   IF NOT pol1271_gera_solicit() THEN
      RETURN FALSE
   END IF
	
	 IF p_faturar = 'P' THEN
	    LET p_num_om = l_num_om
   	  IF NOT pol1271_insere_frete_roma() THEN
	       RETURN FALSE
	    END IF
	 END IF
	
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1271_ve_papel(l_cod_item)#
#------------------------------------#
   
   DEFINE l_cod_item    LIKE ordens.cod_item,
          l_cod_comp    LIKE ordens.cod_item,
          l_num_ordem   LIKE ordens.num_ordem,
          l_txt_fsc     VARCHAR(50),
          l_ies_fsc     VARCHAR(01),
          l_msg         VARCHAR(120)
   
   SELECT num_ordem
     INTO l_num_ordem
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_docum = m_num_docum
      AND cod_item = l_cod_item
      AND cod_item_pai = '0'
   
   IF STATUS <> 0 THEN
      RETURN TRUE
      CALL log003_err_sql('Lendo','ordens')
      RETURN FALSE
   END IF  
   
   LET l_ies_fsc = NULL
   
   DECLARE cq_composi CURSOR for
    SELECT cod_item_compon
      FROM ord_compon
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = l_num_ordem
      AND ies_tip_item <> 'C'
   
   FOREACH cq_composi INTO l_cod_comp
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_composi')
         RETURN FALSE
      END IF  
      
      IF l_cod_comp[1] MATCHES '[BK]' THEN
         LET l_ies_fsc = l_cod_comp[1]
         EXIT FOREACH
      END IF
            
   END FOREACH
   
   IF l_ies_fsc MATCHES '[BK]'  THEN
   ELSE
      RETURN TRUE
   END IF
   
   SELECT texto_fsc INTO l_txt_fsc
     FROM papelao_fsc_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_tip_papel = l_ies_fsc
   
   IF STATUS <> 0 THEN                                
      CALL log003_err_sql('Lendo','papelao_fsc_885:texto fsc da nota')   
      RETURN FALSE                                    
   END IF                                             
   
   LET m_den_texto_1 = m_den_texto_1 CLIPPED, ' - ', l_txt_fsc CLIPPED
   
   RETURN TRUE

END FUNCTION  

#-----------------------------#
FUNCTION pol1271_grava_texto()
#-----------------------------#

   DEFINE l_pct_desc_valor DECIMAL(6,2),
          l_texto_3        CHAR(30)
   
   SELECT pct_desc_valor
     INTO l_pct_desc_valor
     FROM desc_nat_oper_885
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_numpedido
	
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','desc_nat_oper_885:gt')
      RETURN FALSE
   END IF
   
   IF l_pct_desc_valor > 0 THEN
      LET l_texto_3 = 'PRODUTO DESCLASSIFICADO'
   ELSE
      LET l_texto_3 = ''
   END IF   

   LET p_texto_ped = p_num_solicit
   LET p_texto_ped = 'LAUDO: ', p_texto_ped CLIPPED
   
   #LET p_texto_ped = p_texto_ped CLIPPED, 
   # ' - PLACA DO VEICULO: ', p_roma.placaveiculo CLIPPED, ' - UF: ', p_roma.ufveiculo
      
   SELECT cod_empresa
     FROM ped_itens_texto
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_num_pedido
      AND num_sequencia = 0
         
   IF STATUS = 0 THEN
      UPDATE ped_itens_texto
         SET den_texto_1 = p_texto_ped,
             den_texto_2 = p_num_lacre,
             den_texto_3 = l_texto_3
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_num_pedido
         AND num_sequencia = 0
   ELSE
      INSERT INTO ped_itens_texto(
         cod_empresa,
         num_pedido,
         num_sequencia,
         den_texto_1,
         den_texto_2,
         den_texto_3)
       VALUES(p_cod_empresa,
              p_num_pedido,
              0,
              p_texto_ped,
              p_num_lacre,
              l_texto_3)
   END IF
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Gravando','ped_itens_texto')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------------------#
FUNCTION pol1271_le_item_ctr_grade(p_cod_item)
#--------------------------------------------#

   DEFINE p_cod_item   LIKE item.cod_item,
          p_achou      SMALLINT

   LET p_achou = FALSE
   
   DECLARE cq_ctr CURSOR FOR
    SELECT ies_largura,
           ies_altura,
           ies_diametro,
           ies_comprimento,
           reservado_2
      FROM item_ctr_grade
     WHERE cod_empresa   = p_cod_empresa
       AND cod_item      = p_cod_item

   FOREACH cq_ctr INTO
           p_ies_largura,
           p_ies_altura,
           p_ies_diametro,
           p_ies_comprimento,
           p_ies_serie
   
      IF STATUS <> 0 THEN
        CALL log003_err_sql('Lendo','item_ctr_grade')
        RETURN FALSE
      END IF

      LET p_achou = TRUE
      EXIT FOREACH

   END FOREACH
   
   IF NOT p_achou THEN
      LET p_ies_largura     = 'N'
      LET p_ies_altura      = 'N'
      LET p_ies_diametro    = 'N'
      LET p_ies_comprimento = 'N'
      LET p_ies_serie       = 'N'
   ELSE
      IF STATUS <> 0 THEN
        CALL log003_err_sql('Lendo','item_ctr_grade')
        RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1271_le_item(p_cod_item)
#----------------------------------#

   DEFINE p_cod_item LIKE item.cod_item

   SELECT ies_ctr_lote,
          ies_ctr_estoque,
          cod_local_estoq,
          cod_familia
     INTO p_ctr_lote,
          p_ies_ctr_estoque,
          p_cod_local_estoq,
          p_cod_familia
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
     
END FUNCTION

#------------------------------#
FUNCTION pol1271_gera_solicit()
#------------------------------#

  INITIALIZE p_nf_solicit TO NULL
  
  LET p_seq_sf = p_seq_sf + 1
  LET p_nf_solicit.cod_empresa        = p_cod_empresa
  LET p_nf_solicit.num_solicit        = p_num_sf
  LET p_nf_solicit.dat_refer          = TODAY
  LET p_nf_solicit.cod_via_transporte = 1
  LET p_nf_solicit.cod_entrega        = 1
  LET p_nf_solicit.ies_tip_solicit    = 'R'
  LET p_nf_solicit.ies_lotes_geral    = 'N'
  LET p_nf_solicit.cod_tip_carteira   = l_cod_tip_carteira
  LET p_nf_solicit.num_lote_om        = l_num_lote_om
  LET p_nf_solicit.num_om             = l_num_om
  LET p_nf_solicit.val_frete          = 0
  LET p_nf_solicit.val_seguro         = 0
  LET p_nf_solicit.val_frete_ex       = 0
  LET p_nf_solicit.val_seguro_ex      = 0
  LET p_nf_solicit.pes_tot_bruto      = p_pes_brut_tot #p_roma.pesobalanca
  LET p_nf_solicit.ies_situacao       = 'C'
  LET p_nf_solicit.num_sequencia      = p_seq_sf
  LET p_nf_solicit.nom_usuario        = p_user
  LET p_nf_solicit.cod_transpor       = p_roma.coderptranspor
  LET p_nf_solicit.num_placa          = p_roma.placaveiculo
  LET p_nf_solicit.num_volume         = NULL
  LET p_nf_solicit.cod_cnd_pgto       = p_cod_cnd_pgto
  LET p_nf_solicit.pes_tot_liquido    = p_pes_liq_tot #p_roma.pesoliquido 
  LET p_nf_solicit.cod_embal_1        = l_cod_embal_int
  LET p_nf_solicit.qtd_embal_1        = l_qtd_volume
  
  INSERT INTO nf_solicit_885
   VALUES(p_nf_solicit.cod_empresa,
          p_num_solicit,
          p_nf_solicit.num_solicit,
          p_nf_solicit.dat_refer,
          p_nf_solicit.cod_via_transporte,
          p_nf_solicit.cod_entrega,
          p_nf_solicit.ies_tip_solicit,
          p_nf_solicit.ies_lotes_geral,
          p_nf_solicit.cod_tip_carteira,
          p_nf_solicit.num_lote_om,
          p_nf_solicit.num_om,
          p_nf_solicit.val_frete,
          p_nf_solicit.val_seguro,
          p_nf_solicit.val_frete_ex,
          p_nf_solicit.val_seguro_ex,
          p_nf_solicit.pes_tot_bruto,
          p_nf_solicit.ies_situacao,
          p_nf_solicit.num_sequencia,
          p_nf_solicit.nom_usuario,
          p_nf_solicit.cod_transpor,
          p_nf_solicit.num_placa,
          p_nf_solicit.num_volume,
          p_nf_solicit.cod_cnd_pgto,
          p_nf_solicit.pes_tot_liquido,
          p_nf_solicit.cod_embal_1,
          p_nf_solicit.qtd_embal_1)

	IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('Inserindo','nf_solicit_885')
     RETURN FALSE
	END IF
  
  IF NOT pol1271_grava_nf_solicit() THEN
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1271_grava_nf_solicit()
#---------------------------------#
  
  DEFINE l_num_pedido      INTEGER
  
  IF m_txt_placa_veic IS NULL OR m_txt_placa_veic = 0 THEN

     SELECT cod_texto INTO m_txt_placa_veic
       FROM texto_nf WHERE des_texto = 'Veiculo: <NUM_PLACA>'
     
     IF STATUS <> 0 THEN
        CALL log003_err_sql('SELECT','texto_nf:Veiculo: <NUM_PLACA>')
        RETURN FALSE
     END IF
     
     SELECT cod_texto INTO m_txt_uf_veic
       FROM texto_nf WHERE des_texto = 'Veiculo <UF_PLACA>'
     
     IF STATUS <> 0 THEN
        CALL log003_err_sql('SELECT','texto_nf:Veiculo: <UF_PLACA>')
        RETURN FALSE
     END IF
  
  END IF
      
  LET p_nf_solicit.num_controle = p_nf_solicit.num_sequencia

  IF p_nf_solicit.qtd_embal_1 IS NULL THEN
     SELECT SUM(qtd_volume_item)
       INTO p_nf_solicit.qtd_embal_1
       FROM ordem_montag_item
      WHERE cod_empresa = p_cod_empresa
        AND num_om = p_nf_solicit.num_om
     IF p_nf_solicit.qtd_embal_1 IS NULL THEN    
        LET p_nf_solicit.qtd_embal_1 = 0
     END IF    
  END IF
  	
	SELECT *
  	INTO lr_fat_solic_mestre.*
	  FROM FAT_SOLIC_MESTRE
	 WHERE empresa = p_nf_solicit.cod_empresa
	   AND solicitacao_fatura = p_nf_solicit.num_solicit
	
	IF STATUS <> 0 THEN
		INITIALIZE lr_fat_solic_mestre.* TO NULL
		LET lr_fat_solic_mestre.trans_solic_fatura 	= 0
		LET lr_fat_solic_mestre.empresa 			= p_nf_solicit.cod_empresa
		LET lr_fat_solic_mestre.tip_docum 			= 'SOLPRDSV'
		LET lr_fat_solic_mestre.serie_fatura		= '1'
		LET lr_fat_solic_mestre.subserie_fatura		= '0'
		LET lr_fat_solic_mestre.especie_fatura		= 'NFF'
		LET lr_fat_solic_mestre.solicitacao_fatura	= p_nf_solicit.num_solicit
		LET lr_fat_solic_mestre.usuario				= p_nf_solicit.nom_usuario
		LET lr_fat_solic_mestre.inscricao_estadual	= NULL
		LET lr_fat_solic_mestre.dat_refer			= p_nf_solicit.dat_refer
		LET lr_fat_solic_mestre.tip_solicitacao		= 'O'
		LET lr_fat_solic_mestre.lote_geral			= 'N' 
		LET lr_fat_solic_mestre.tip_carteira		= NULL
		LET lr_fat_solic_mestre.sit_solic_fatura	= 'C'
		
		INSERT INTO fat_solic_mestre (		
		                  empresa, 
											tip_docum, 
											serie_fatura, 
											subserie_fatura, 
											especie_fatura, 
											solicitacao_fatura, 
											usuario, 
											inscricao_estadual, 
											dat_refer, 
											tip_solicitacao, 
											lote_geral, 
											tip_carteira, 
											sit_solic_fatura)
									VALUES (lr_fat_solic_mestre.empresa,
											lr_fat_solic_mestre.tip_docum,
											lr_fat_solic_mestre.serie_fatura, 
											lr_fat_solic_mestre.subserie_fatura, 
											lr_fat_solic_mestre.especie_fatura, 
											lr_fat_solic_mestre.solicitacao_fatura, 
											lr_fat_solic_mestre.usuario, 
											lr_fat_solic_mestre.inscricao_estadual, 
											lr_fat_solic_mestre.dat_refer, 
											lr_fat_solic_mestre.tip_solicitacao, 
											lr_fat_solic_mestre.lote_geral, 
											lr_fat_solic_mestre.tip_carteira, 
											lr_fat_solic_mestre.sit_solic_fatura)

	   IF STATUS <> 0 THEN
        CALL log003_err_sql('Inserindo','fat_solic_mestre')
        RETURN FALSE
	   END IF
											
	    LET lr_fat_solic_mestre.trans_solic_fatura = SQLCA.SQLERRD[2]
	    
	END IF
	
	# FAT_SOLIC_FATURA
	
	INITIALIZE lr_fat_solic_fatura.* TO NULL
	
	LET lr_fat_solic_fatura.trans_solic_fatura	= lr_fat_solic_mestre.trans_solic_fatura
	LET lr_fat_solic_fatura.ord_montag			    = p_nf_solicit.num_om
	LET lr_fat_solic_fatura.lote_ord_montag		  = 0
	LET lr_fat_solic_fatura.seq_solic_fatura	  = p_nf_solicit.num_sequencia
	LET lr_fat_solic_fatura.controle			      = NULL
	LET lr_fat_solic_fatura.cond_pagto			    = p_nf_solicit.cod_cnd_pgto
	LET lr_fat_solic_fatura.qtd_dia_acre_dupl	  = NULL
	LET lr_fat_solic_fatura.texto_1				      = m_txt_placa_veic
	LET lr_fat_solic_fatura.texto_2				      = m_txt_uf_veic
	LET lr_fat_solic_fatura.texto_3				      = NULL
	LET lr_fat_solic_fatura.via_transporte		  = p_nf_solicit.cod_via_transporte
	LET lr_fat_solic_fatura.cidade_dest_frete	  = NULL
	LET lr_fat_solic_fatura.tabela_frete		    = NULL
	LET lr_fat_solic_fatura.seq_tabela_frete	  = NULL
	LET lr_fat_solic_fatura.sequencia_faixa		  = NULL
	LET lr_fat_solic_fatura.transportadora		  = p_nf_solicit.cod_transpor
	LET lr_fat_solic_fatura.placa_veiculo		    = p_nf_solicit.num_placa
	LET lr_fat_solic_fatura.placa_carreta_1		  = NULL
	LET lr_fat_solic_fatura.placa_carreta_2		  = NULL
	LET lr_fat_solic_fatura.estado_placa_veic	  = p_roma.ufveiculo
	LET lr_fat_solic_fatura.estado_plac_carr_1	= NULL
	LET lr_fat_solic_fatura.estado_plac_carr_2	= NULL
	LET lr_fat_solic_fatura.val_frete           = 0
	  
	LET lr_fat_solic_fatura.val_seguro			    = p_nf_solicit.val_seguro
	LET lr_fat_solic_fatura.peso_liquido		    = p_nf_solicit.pes_tot_liquido
	LET lr_fat_solic_fatura.peso_bruto			    = p_nf_solicit.pes_tot_bruto
	LET lr_fat_solic_fatura.primeiro_volume		  = 1
	
	IF p_nf_solicit.num_volume IS NULL THEN
		LET lr_fat_solic_fatura.volume_cubico = 0
	ELSE
		LET lr_fat_solic_fatura.volume_cubico = p_nf_solicit.num_volume
	END IF
	
	LET lr_fat_solic_fatura.mercado				    = NULL
	LET lr_fat_solic_fatura.local_embarque		= NULL
	LET lr_fat_solic_fatura.modo_embarque	 	  = NULL
	LET lr_fat_solic_fatura.dat_hor_embarque	= NULL
	LET lr_fat_solic_fatura.cidade_embarque		= NULL
	LET lr_fat_solic_fatura.sit_solic_fatura	= 'C'
	 
	INSERT INTO fat_solic_fatura
                	(
                	trans_solic_fatura,
                	ord_montag,
                	lote_ord_montag,
                	seq_solic_fatura,
                	controle,
                	cond_pagto,
                	qtd_dia_acre_dupl,
                	texto_1,
                	texto_2,
                	texto_3,
                	via_transporte,
                	cidade_dest_frete,
                	tabela_frete,
                	seq_tabela_frete,
                	sequencia_faixa,
                	transportadora,
                	placa_veiculo,
                	placa_carreta_1,
                	placa_carreta_2,
                	estado_placa_veic,
                	estado_plac_carr_1,
                	estado_plac_carr_2,
                	val_frete,
                	val_seguro,
                	peso_liquido,
                	peso_bruto,
                	primeiro_volume,
                	volume_cubico,
                	mercado,
                	local_embarque,
                	modo_embarque,
                	dat_hor_embarque,
                	cidade_embarque,
                	sit_solic_fatura
                	)
                values 
                	(
                	lr_fat_solic_fatura.trans_solic_fatura,
                	lr_fat_solic_fatura.ord_montag,
                	lr_fat_solic_fatura.lote_ord_montag,
                	lr_fat_solic_fatura.seq_solic_fatura,
                	lr_fat_solic_fatura.controle,
                	lr_fat_solic_fatura.cond_pagto,
                	lr_fat_solic_fatura.qtd_dia_acre_dupl,
                	lr_fat_solic_fatura.texto_1,
                	lr_fat_solic_fatura.texto_2,
                	lr_fat_solic_fatura.texto_3,
                	lr_fat_solic_fatura.via_transporte,
                	lr_fat_solic_fatura.cidade_dest_frete,
                	lr_fat_solic_fatura.tabela_frete,
                	lr_fat_solic_fatura.seq_tabela_frete,
                	lr_fat_solic_fatura.sequencia_faixa,
                	lr_fat_solic_fatura.transportadora,
                	lr_fat_solic_fatura.placa_veiculo,
                	lr_fat_solic_fatura.placa_carreta_1,
                	lr_fat_solic_fatura.placa_carreta_2,
                	lr_fat_solic_fatura.estado_placa_veic,
                	lr_fat_solic_fatura.estado_plac_carr_1,
                	lr_fat_solic_fatura.estado_plac_carr_2,
                	lr_fat_solic_fatura.val_frete,
                	lr_fat_solic_fatura.val_seguro,
                	lr_fat_solic_fatura.peso_liquido,
                	lr_fat_solic_fatura.peso_bruto,
                	lr_fat_solic_fatura.primeiro_volume,
                	lr_fat_solic_fatura.volume_cubico,
                	lr_fat_solic_fatura.mercado,
                	lr_fat_solic_fatura.local_embarque,
                	lr_fat_solic_fatura.modo_embarque,
                	lr_fat_solic_fatura.dat_hor_embarque,
                	lr_fat_solic_fatura.cidade_embarque,
                	lr_fat_solic_fatura.sit_solic_fatura)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','fat_solic_fatura')
      RETURN FALSE
	 END IF
		
   INSERT INTO fat_s_nf_eletr(
    trans_solic_fatura, 
    ord_montag, 
    lote_ord_montag, 
    modalidade_frete_nfe) 
  VALUES(lr_fat_solic_fatura.trans_solic_fatura,
         lr_fat_solic_fatura.ord_montag,        
         lr_fat_solic_fatura.lote_ord_montag, 
         m_ies_modalidade)  
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','fat_s_nf_eletr')
      RETURN FALSE
	 END IF

   {SELECT DISTINCT num_pedido INTO l_num_pedido
       FROM ordem_montag_item
      WHERE cod_empresa = p_cod_empresa
        AND num_om = p_nf_solicit.num_om
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordem_montag_item')
   ELSE
      UPDATE pedidos SET ies_frete = m_ies_frete
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido = l_num_pedido
      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','pedidos:ies_frete')
      END IF
   END IF}
      
   IF p_nf_solicit.qtd_embal_1 IS NULL THEN    
      LET p_nf_solicit.qtd_embal_1 = 0
   END IF    
   
	# FAT_SOLIC_EMBAL
	
	IF p_nf_solicit.qtd_embal_1 > 0 THEN

	   IF p_nf_solicit.cod_embal_1 IS NULL OR p_nf_solicit.cod_embal_1 = 0 THEN
	      LET p_nf_solicit.cod_embal_1 = 99
	   END IF
	
	   INITIALIZE lr_fat_solic_embal.* TO NULL
	
	   LET lr_fat_solic_embal.trans_solic_fatura	= lr_fat_solic_mestre.trans_solic_fatura
	   LET lr_fat_solic_embal.ord_montag			  = p_nf_solicit.num_om
	   LET lr_fat_solic_embal.lote_ord_montag		= p_nf_solicit.num_lote_om
	   LET lr_fat_solic_embal.embalagem			    = p_nf_solicit.cod_embal_1
	   LET lr_fat_solic_embal.qtd_embalagem		  = p_nf_solicit.qtd_embal_1
		
		INSERT INTO fat_solic_embal VALUES (lr_fat_solic_embal.*)

    IF STATUS <> 0 THEN
       CALL log003_err_sql('Inserindo','fat_solic_embal')
       RETURN FALSE
	  END IF
		
	END IF	

  RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol1271_cria_item_roma_tmp()
#------------------------------------#

   DROP TABLE item_roma_tmp

   CREATE TEMP TABLE item_roma_tmp(
          num_sequencia  DECIMAL(6,0),
          cod_item       CHAR(15),
          numlote        CHAR(15),
          largura        INTEGER,
          diametro       INTEGER,
          tubete         INTEGER,
          comprimento    INTEGER,
          pes_item       DECIMAL(12,2),
          pes_itemb      DECIMAL(12,2),
          qtd_reservada  DECIMAL(10,3),
          qtd_volumes    INTEGER
   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql('Criando','item_roma_tmp')
       RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1271_cria_om_tmp()
#-----------------------------#

   DROP TABLE om_tmp_885
 
   CREATE TEMP TABLE om_tmp_885(
        cod_empresa CHAR(02),
        num_om      INTEGER,
        val_pedido  DECIMAL(12,2)
   );


	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIANDO","OM_TMP_885")
			RETURN FALSE
	 END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1271_grava_frete_885()
#--------------------------------#

   SELECT val_frete,
          num_versao
     INTO p_val_frete,
          p_num_versao
     FROM frete_rota_885
    WHERE cod_empresa      = p_cod_empresa
      AND cod_transpor     = p_roma.coderptranspor
      AND cod_veiculo      = p_roma.codveiculo
      AND cod_tip_carga    = p_roma.codtipcarga
      AND cod_tip_frete    = p_roma.codtipfrete
      AND cod_percurso     = p_roma.codpercurso
      AND cod_cid_orig     = p_cod_cid_orig
      AND cod_cid_dest     = p_roma.codciddest
      AND ies_versao_atual = 'S'
         
   IF STATUS = 100 THEN 
      LET p_val_frete  = 0
      LET p_num_versao = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','frete_rota_885')
         RETURN FALSE
      END IF
   END IF
      
   IF p_roma.codtipfrete = 'P' THEN
      LET p_val_frete = p_roma.pesobalanca * p_val_frete / 1000
   END IF
   
   SELECT pct_desc
     INTO p_pct_desc
     FROM desc_transp_885
    WHERE cod_empresa  = p_cod_empresa
      AND cod_transpor = p_roma.coderptranspor
      
   IF STATUS = 100 THEN
      LET p_pct_desc = 0
   ELSE
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('Lendo','desc_transp_885')
         RETURN FALSE
      END IF
   END IF
   
   LET p_val_fret_ger  = p_roma.valfrete  * p_pct_desc / 100
   LET p_val_fret_ofic = p_roma.valfrete  - p_val_fret_ger
   
   INSERT INTO frete_solicit_885
    VALUES(p_cod_empresa,
           p_num_solicit,
           p_roma.coderptranspor,
           p_roma.placaveiculo,
           p_cod_cid_orig,
           p_roma.codciddest,
           p_roma.codveiculo,
           p_roma.codtipcarga,
           p_roma.codtipfrete,
           p_roma.codpercurso,
           NULL,
           NULL,
           p_roma.valfrete,
           p_val_frete,
           p_val_fret_ofic,
           p_val_fret_ger,
           p_num_versao,
           getdate(),
           'N',
           p_num_sequencia,
           'S',
           p_peso_carga)
           
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Inserindo','frete_solicit_885')
      RETURN FALSE
   END IF
           
   IF p_val_fret_ofic > 0 THEN
      IF NOT pol1271_rateia_frete() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1271_rateia_frete()
#-----------------------------#
   
   SELECT SUM(val_pedido)
     INTO p_val_tot
     FROM om_tmp_885

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Lendo','om_tmp_885:1')
      RETURN FALSE
   END IF

   IF p_val_tot IS NULL THEN
      RETURN TRUE
   END IF
     
   LET p_coefic = p_roma.valfrete / p_val_tot
   LET p_val_ger = 0
   
   DECLARE cq_oms CURSOR FOR
    SELECT num_om,
       SUM (val_pedido)
      FROM om_tmp_885 
     GROUP BY num_om
     ORDER BY num_om
   
   FOREACH cq_oms INTO p_num_om, p_val_pedido
   
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('Lendo','om_tmp_885:2')
         RETURN FALSE
      END IF
      
      LET p_val_frete = p_val_pedido * p_coefic
      LET p_val_fret_ofic = p_val_frete * ((100 - p_pct_desc ) / 100)
      LET p_val_fret_ger  = p_val_frete * (p_pct_desc / 100)
      
      IF NOT pol1271_insere_frete_roma() THEN
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1271_insere_frete_roma()
#-----------------------------------#

   DEFINE p_op CHAR(01)
   
   INSERT INTO frete_roma_885
    VALUES(p_cod_empresa,
           p_num_solicit,
           p_num_om,
           p_val_fret_ofic,
           p_val_fret_ger,
           1,'S')
                   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Inserindo','frete_roma_885')
      RETURN FALSE
   END IF

   IF p_faturar = 'T' THEN
      UPDATE solicit_fat_885
         SET val_frete = p_val_fret_ofic,
               val_ger = p_val_fret_ger
       WHERE cod_empresa = p_cod_empresa
         AND num_solicit = p_num_solicit
         AND num_om      = p_num_om

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('Atualizando','solicit_fat_885')
         RETURN FALSE
      END IF
   END IF
      
   {UPDATE nf_solicit
      SET val_frete = p_val_fret_ofic
    WHERE cod_empresa = p_cod_empresa
      AND num_solicit = p_num_sf
      AND num_om      = p_num_om

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Atualizando','nf_solicit')
      RETURN FALSE
   END IF}
   
   IF p_ies_frete = '2' THEN   
      UPDATE fat_solic_fatura
         SET val_frete = p_val_fret_ofic
       WHERE ord_montag = p_num_om		    
 
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('Atualizando','fat_solic_fatura')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION


#--------------------------#
FUNCTION pol1271_om_logix()
#--------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol12711") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol12711 AT 03,02 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa
   
   LET p_selecionou = FALSE
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa parametros p/ o processamento "
         LET p_selecionou = FALSE
         LET m_roma_ltda = '0'
         LET p_info = 'I'
         IF NOT pol1271_par_info('1') THEN
            CALL pol1271_limpa_tela()
            ERROR 'OPERAÇÃO CANCELADA !!!'
         ELSE
            IF p_selecionou THEN
               ERROR 'ROMANEIO INFORMADO COM SUCESSO !!!'
               NEXT OPTION 'Cancelar'
            ELSE
               ERROR 'OPERAÇÃO CANCELADA !!!'
            END IF
         END IF
      COMMAND "Cancelar" "Cacelar OM's e Soloct Faturamento "
         IF p_selecionou THEN
           IF m_ies_fat THEN
              ERROR "EXISTE(M) OM(S) JÁ FATURADA(S)"
           ELSE
             IF m_roma_ltda = '1' THEN
                ERROR "ROMANEIO JÁ PROCESSADO NA EMPRESA LTDA."
             ELSE
                IF log004_confirm(18,35) THEN                   
                  CALL log085_transacao("BEGIN")                
                  CALL pol1271_opc_proces() RETURNING p_status  
                  IF p_status THEN                              
                     CALL log085_transacao("COMMIT")            
                  ELSE                                          
                    CALL log085_transacao("ROLLBACK")           
                  END IF                                        
                  CALL log0030_mensagem(p_den_erro,'info')      
                  LET p_selecionou = FALSE                      
                  NEXT OPTION 'Informar'                        
                END IF                                          
             END IF
           END IF
         ELSE
            ERROR 'INFORME PREVIAMENTE O ROMANEIO.'
         END IF
      COMMAND "Restaurar" "Restaura solicitação excluida pelo concelamento da NF"
         LET p_info = 'R'
         #IF pol1271_par_info('2') THEN
         IF p_selecionou THEN
          IF m_roma_ltda = '1' THEN
             ERROR "ROMANEIO JÁ PROCESSADO NA EMPRESA LTDA."
          ELSE
            CALL log085_transacao("BEGIN")
            IF NOT pol1271_restaurar() THEN
               CALL log085_transacao("ROLLBACK")
               ERROR 'OPERAÇÃO CANCELADA !!!'
            ELSE
               CALL log085_transacao("COMMIT")
               CALL log0030_mensagem('RESTAURAÇÃO PROCESSADA COM SUCESSO' ,'excla')
            END IF
          END IF
         ELSE
            ERROR 'INFORME PREVIAMENTE O ROMANEIO.'
         END IF
      COMMAND "Agrupar" "Agrupar OMs/Pedidos na mesma Nota "
         LET p_info = 'A'
         IF pol1271_par_info('2') THEN
            IF pol1271_agrupar() THEN
               ERROR 'OPERAÇÃO EFETUADA COM SUCESSO.'
            ELSE
               ERROR 'OPERAÇÃO CANCELADA !!!'
            END IF
         ELSE
            ERROR 'OPERAÇÃO CANCELADA !!!'
         END IF
      COMMAND "Listar" "Impressão do romaneio "
         LET p_info = 'L'
         IF pol1271_par_info('2') THEN
            CALL pol1271_listar()
         ELSE
            ERROR 'OPERAÇÃO CANCELADA !!!'
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU
 
   CLOSE WINDOW w_pol12711


END FUNCTION

#-----------------------------#
FUNCTION pol1271_par_info(p_op)
#-----------------------------#

   DEFINE p_op CHAR(01)
             
   INITIALIZE p_num_solicit, pr_om TO NULL
   LET INT_FLAG = FALSE
   
   CALL pol1271_limpa_tela()
   
   INPUT p_num_solicit WITHOUT DEFAULTS FROM num_roma

      AFTER FIELD num_roma
         IF p_num_solicit IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD num_roma
         END IF
         
         SELECT COUNT(num_om)
           INTO p_count
           FROM solicit_fat_885
          WHERE cod_empresa = p_cod_empresa
            AND num_solicit = p_num_solicit
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','solicit_fat_885')
            NEXT FIELD num_roma
         END IF
         
         IF p_count = 0 THEN
            CALL log0030_mensagem('Romaneio não está processado.','excla')
            NEXT FIELD num_roma
         END IF

      ON KEY (control-z)
         CALL pol1271_popup('L')

   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   IF p_op = '2' THEN
      RETURN TRUE
   END IF

   SELECT MAX(numsequencia)
     INTO p_num_sequencia
     FROM romaneio_885
    WHERE codempresa     = p_cod_empresa
      AND numromaneio    = p_num_solicit
      AND statusregistro = '1'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','romaneio_885')
      RETURN FALSE
   END IF

   CALL pol1271_gera_num_sf()

   LET p_selecionou = FALSE
   
   IF m_ies_indus THEN
      SELECT statusregistro                                      
        INTO m_roma_ltda                                         
        FROM romaneio_885                                        
       WHERE codempresa   = m_cod_emp_pv                         
         AND numromaneio  = p_num_solicit                        
         AND numsequencia = p_num_sequencia                      
                                                                 
      IF STATUS = 100 THEN                                       
         LET m_roma_ltda = '0'                                   
      ELSE                                                       
         IF STATUS <> 0 THEN                                     
            CALL log003_err_sql('Lendo','romaneio_885:emp_ltda') 
            RETURN FALSE                                         
         END IF                                                  
      END IF                                                     
   END IF
   
   CALL pol1271_exibe_oms() RETURNING p_status

   RETURN(p_status)

END FUNCTION

#---------------------------#
FUNCTION pol1271_exibe_oms()
#---------------------------#

   LET p_index = 1
   LET m_ies_fat = FALSE
   
   INITIALIZE pr_om TO NULL
   
   DECLARE cq_ord_m CURSOR FOR
    SELECT DISTINCT
           num_om,
           num_pedido,
           cod_status
      FROM solicit_fat_885
     WHERE cod_empresa = p_cod_empresa
       AND num_solicit = p_num_solicit
       
   FOREACH cq_ord_m INTO
           pr_om[p_index].num_om,
           pr_om[p_index].num_pedido,
           pr_om[p_index].cod_status

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_ord_m')
         RETURN FALSE
      END IF

      LET p_selecionou = TRUE                            

      SELECT ies_sit_om                               
        INTO pr_om[p_index].cod_status                   
        FROM ordem_montag_mest                           
       WHERE cod_empresa = p_cod_empresa                 
         AND num_om      = pr_om[p_index].num_om         
                                                                                                                  
      IF STATUS = 0 THEN                                 
         IF pr_om[p_index].cod_status = 'F' THEN         
            #LET m_ies_fat = TRUE                         
            LET pr_om[p_index].cod_acao = 'N'            
         ELSE                                            
            LET pr_om[p_index].cod_acao = 'C'            
         END IF                                          
      ELSE                                               
         IF STATUS <> 100 THEN                           
            CALL log003_err_sql('Lendo','pedidos')       
            RETURN FALSE                                 
         END IF                                          
      END IF                                             

      SELECT cod_cliente
        INTO pr_om[p_index].cod_cliente
        FROM pedidos
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = pr_om[p_index].num_pedido
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','pedidos')
         RETURN FALSE
      END IF
        
      SELECT nom_cliente
        INTO pr_om[p_index].nom_cliente
        FROM clientes
       WHERE cod_cliente = pr_om[p_index].cod_cliente

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','clientes')
         RETURN FALSE
      END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 200 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassado','excla')
         RETURN FALSE
      END IF
      
   END FOREACH
   
   LET p_status = TRUE
   
   CALL pol1271_selec_acao() RETURNING p_status
   
   RETURN(p_status)
      
END FUNCTION

#----------------------------#
FUNCTION pol1271_selec_acao()
#----------------------------#

   CALL SET_COUNT(p_index -1)

   INPUT ARRAY pr_om
      WITHOUT DEFAULTS FROM sr_om.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
   
   RETURN TRUE
      
   INPUT ARRAY pr_om
      WITHOUT DEFAULTS FROM sr_om.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()

      AFTER FIELD cod_acao
         IF pr_om[p_index].cod_acao IS NOT NULL THEN
            IF pr_om[p_index].cod_acao MATCHES '[CG]' THEN
            ELSE
               ERROR 'Acão inválida !!!'
               NEXT FIELD cod_acao
            END IF
            IF pr_om[p_index].cod_acao = 'C' THEN
               IF pr_om[p_index].cod_status <> 'N' THEN
                  ERROR 'ORDEM DE MONTAGEM ESTÁ CANCELADA OU FATURADA'
                  NEXT FIELD cod_acao
               END IF
            ELSE
               IF pr_om[p_index].cod_acao = 'G' THEN
                  IF pr_om[p_index].cod_status <> 'C' THEN
                     ERROR 'Ordem de montagem já existe'
                     NEXT FIELD cod_acao
                  END IF
               END IF
            END IF
         END IF               
         
   END INPUT

   IF NOT INT_FLAG THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------------#
FUNCTION pol1271_checa_possib_canc()
#-----------------------------------#

   INITIALIZE p_den_erro, p_ies_sit_om TO NULL
      
   SELECT ies_sit_om
     INTO p_ies_sit_om
     FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_sol.num_om
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Lendo','ordem_montag_mest')
      RETURN FALSE
   END IF

   IF p_ies_sit_om = 'F' THEN
      LET p_den_erro = 'ORDEM DE MONTAGEM JÁ FATURADA'
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1271_opc_proces()
#----------------------------#

   LET p_den_erro = 'Operacao cancelada.'
   
   IF NOT pol1271_cria_solicit_tmp() THEN
      RETURN FALSE
   END IF

   FOR p_index = 1 TO ARR_COUNT()
       IF pr_om[p_index].cod_acao IS NULL THEN
       ELSE
          INSERT INTO solicit_tmp_885
           VALUES(pr_om[p_index].num_om,
                  pr_om[p_index].num_pedido,
                  pr_om[p_index].cod_acao)
          IF STATUS <> 0 THEN
             CALL log003_err_sql('Inserindo','solicit_tmp_885')
             RETURN FALSE
          END IF
       END IF
   END FOR

   LET p_criticou = FALSE

   IF NOT pol1271_deleta_erros() THEN
      RETURN FALSE
   END IF

   CALL pol1271_gera_num_sf()
   
   DECLARE cq_tmp_c CURSOR FOR
    SELECT num_om,
           num_pedido,
           cod_acao
      FROM solicit_tmp_885
     WHERE cod_acao = 'C'

   FOREACH cq_tmp_c INTO p_sol.*
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','solicit_tmp_885')
         RETURN FALSE
      END IF

      IF NOT pol1271_cancela_om() THEN
         RETURN FALSE
      END IF
      
   END FOREACH

   IF NOT pol1271_deleta_solicit() THEN
      RETURN FALSE
   END IF
   
   LET p_den_erro = 'Processamento efetuado com sucesso.'

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1271_cancela_om()
#----------------------------#

   #IF NOT pol1271_checa_possib_canc() THEN
    #  RETURN FALSE
   #END IF

   #IF p_den_erro IS NOT NULL THEN
    #  IF NOT pol1271_insere_erro() THEN
    #     RETURN FALSE
    #  END IF
     # RETURN TRUE
   #END IF
   
   SELECT num_om
     INTO p_num_om
     FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om = p_sol.num_om

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ordem_montag_mest')
      RETURN FALSE
   END IF
      
   IF NOT pol1271_cancela_roma() THEN
      RETURN FALSE
   END IF

   UPDATE solicit_fat_885
      SET cod_status = 'C'
    WHERE cod_empresa = p_cod_empresa
      AND num_solicit = p_num_solicit
      AND num_om      = p_num_om

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Atualizando','solicit_fat_885')
      RETURN FALSE
   END IF
         
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1271_cancela_roma()
#------------------------------#

   DEFINE l_pct_por_dentro       DECIMAL(5,2),
          l_qtd_tot_por_dentro   INTEGER,
          l_pct_fat              DECIMAL(5,2),
          l_qtd_cancelada        INTEGER,
          l_qtd_pecas_solic      INTEGER
   
   DEFINE l_trans_solic_fatura 	INTEGER
   DEFINE l_solicitacao_fatura	INTEGER

   DEFINE l_num_reserva   LIKE ordem_montag_grade.num_reserva,
          p_num_sequencia LIKE ped_itens.num_sequencia,
          p_qtd_reservada LIKE ordem_montag_item.qtd_reservada,
          p_cod_item      LIKE ordem_montag_item.cod_item,
          p_texto         CHAR(40)


   DECLARE cq_ped CURSOR FOR 
    SELECT num_pedido,
           num_sequencia,
           cod_item,
           qtd_reservada
      FROM ordem_montag_item
     WHERE cod_empresa = p_cod_empresa
       AND num_om      = p_num_om

   FOREACH cq_ped INTO 
           p_num_pedido, 
           p_num_sequencia, 
           p_cod_item,
           p_qtd_reservada
   
      IF NOT pol1271_le_desconto() THEN
         RETURN FALSE
      END IF
      
      SELECT qtd_pecas_solic INTO l_qtd_pecas_solic FROM ped_itens
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_num_pedido
         AND num_sequencia = p_num_sequencia

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('SELECIONADA','ped_itens')
         RETURN FALSE
      END IF

      IF p_pct_cancelar > 0 THEN
         LET l_pct_por_dentro = 100 - p_pct_cancelar
         LET l_qtd_tot_por_dentro = l_qtd_pecas_solic * l_pct_por_dentro / 100
         LET l_pct_fat = p_qtd_reservada * 100 / l_qtd_tot_por_dentro
         LET l_qtd_cancelada = l_qtd_pecas_solic * p_pct_cancelar / 100 * l_pct_fat / 100
      ELSE
         LET l_qtd_cancelada = 0
      END IF
      
      UPDATE ped_itens
         SET qtd_pecas_romaneio = qtd_pecas_romaneio - p_qtd_reservada #,
             #qtd_pecas_cancel = qtd_pecas_cancel - l_qtd_cancelada
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_num_pedido
         AND num_sequencia = p_num_sequencia

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('Atualizando','ped_itens')
         RETURN FALSE
      END IF
      
      DELETE FROM pedido_finalizado_885
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_num_pedido
         AND num_sequencia = p_num_sequencia

      IF STATUS <> 0 THEN                                                              
         CALL log003_err_sql('DELETE','pedido_finalizado_885')                            
         RETURN FALSE                                                                  
      END IF                                                                           
      
      UPDATE estoque
         SET qtd_reservada = qtd_reservada - p_qtd_reservada
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('Atualizando','estoque')
         RETURN FALSE
      END IF
         
   END FOREACH

   DELETE FROM ordem_montag_item
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_item')
      RETURN FALSE
   END IF

   DELETE FROM ordem_montag_embal
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_embal')
      RETURN FALSE
   END IF

   DECLARE cq_reser CURSOR FOR
    SELECT num_reserva
      FROM ordem_montag_grade
     WHERE cod_empresa = p_cod_empresa
       AND num_om      = p_num_om
      
   FOREACH cq_reser INTO l_num_reserva
  
      DELETE estoque_loc_reser
       WHERE cod_empresa = p_cod_empresa
         AND num_reserva = l_num_reserva
      
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('DELETE','estoque_loc_reser')
         RETURN FALSE
      END IF

      DELETE est_loc_reser_end
       WHERE cod_empresa = p_cod_empresa
         AND num_reserva = l_num_reserva
      
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('DELETE','est_loc_reser_end')
         RETURN FALSE
      END IF
  
   END FOREACH
  
   DELETE FROM ordem_montag_grade
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_grade')
      RETURN FALSE
   END IF

   SELECT num_lote_om
     INTO l_num_lote_om
     FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Lendo','ordem_montag_mest')
      RETURN FALSE
   END IF
     
   DELETE FROM ordem_montag_lote
    WHERE cod_empresa = p_cod_empresa
      AND num_lote_om = l_num_lote_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_lote')
      RETURN FALSE
   END IF

   DELETE FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_mest')
      RETURN FALSE
   END IF

   DELETE FROM om_list
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','om_list')
      RETURN FALSE
   END IF

   DELETE FROM frete_roma_885
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','frete_roma_885')
      RETURN FALSE
   END IF

   DELETE FROM nf_solicit_885
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','nf_solicit_885')
      RETURN FALSE
   END IF

   DELETE FROM fat_solic_fatura 
		WHERE ord_montag = p_num_om

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','fat_solic_fatura')
      RETURN FALSE
   END IF
	
	 DELETE FROM fat_solic_embal	 
		WHERE ord_montag = p_num_om

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','fat_solic_embal')
      RETURN FALSE
   END IF
    
   {DELETE FROM nf_solicit
     WHERE cod_empresa = p_cod_empresa
       AND num_solicit = p_num_sf
       AND num_om      = p_num_om

   IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('Deletando','nf_solicit')
       RETURN FALSE
   END IF

   DELETE FROM fat_solic_ser_comp
     WHERE empresa            = p_cod_empresa
       AND solicitacao_fatura = p_num_sf
       AND ord_montag         = p_num_om

   IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('Deletando','fat_solic_ser_comp')
       RETURN FALSE
   END IF}

   LET p_hor_atual = CURRENT HOUR TO SECOND
   
   LET p_texto = "CANCELAMENTO DA OM Nr.", p_num_om USING '&&&&&&&&&&'
   
   INSERT INTO audit_vdp (
      cod_empresa,
      num_pedido,
      tipo_informacao,
      tipo_movto,
      texto,
      num_programa,
      data,
      hora,
      usuario)
    VALUES(p_cod_empresa,
           0,
           'C',
           'C', 
           p_texto,
           'POL1271',
           getdate(),
           p_hor_atual,
           p_user)
           
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','audit_vdp')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1271_deleta_solicit()
#--------------------------------#

   SELECT num_sequencia
     INTO p_num_sequencia
     FROM frete_solicit_885
    WHERE cod_empresa = p_cod_empresa
      AND num_solicit = p_num_solicit

   IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 THEN
       CALL log003_err_sql('Lendo','frete_solicit_885')
       RETURN FALSE
   END IF
   
   IF STATUS = 100 THEN
      SELECT MAX(numsequencia)
        INTO p_num_sequencia
        FROM romaneio_885
       WHERE codempresa  = p_cod_empresa
         AND numromaneio = p_num_solicit

      IF p_num_sequencia IS NULL THEN
         CALL log003_err_sql('Lendo','romaneio_885:sequencia')
         RETURN FALSE
      END IF
   END IF

   UPDATE romaneio_885
      SET StatusRegistro = '2'
    WHERE codempresa   = p_cod_empresa
      AND numromaneio  = p_num_solicit
      AND numsequencia = p_num_sequencia
      
   IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('Atualizando','romaneio_885')
       RETURN FALSE
   END IF

   UPDATE roma_item_885
      SET StatusRegistro = '2'
    WHERE codempresa  = p_cod_empresa
      AND numromaneio = p_num_solicit
      AND numseqpai   = p_num_sequencia
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','roma_item_885')
      RETURN FALSE
   END IF
      
   DELETE FROM frete_solicit_885
    WHERE cod_empresa = p_cod_empresa
      AND num_solicit = p_num_solicit
   
   IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('Deletando','frete_solicit_885')
       RETURN FALSE
   END IF

   DELETE FROM solicit_fat_885
    WHERE cod_empresa = p_cod_empresa
      AND num_solicit = p_num_solicit

   IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('Deletando','solicit_fat_885')
       RETURN FALSE
   END IF

	 DELETE FROM fat_solic_mestre 
	  WHERE empresa  = p_cod_empresa 
	    AND solicitacao_fatura = p_num_sf

   IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('Deletando','fat_solic_mestre')
       RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1271_cheka_fat()
#---------------------------#

   DEFINE p_qtd_om_fat SMALLINT
   
   DECLARE cq_fat CURSOR FOR 
    SELECT num_om
      FROM solicit_fat_885
     WHERE num_solicit = p_num_solicit
      
   FOREACH cq_fat INTO p_num_om

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','solicit_fat_885')
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      SELECT COUNT(num_om)
        INTO p_qtd_om_fat
        FROM ordem_montag_mest
       WHERE num_om     = p_num_om
         AND ies_sit_om = 'F'
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordem_montag_mest')
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
      
      IF p_qtd_om_fat > 0 THEN
         CALL log003_err_sql('Lendo','ordem_montag_mest')
         IF NOT pol1271_insere_erro() THEN
            RETURN FALSE
         END IF
         EXIT FOREACH
      END IF

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1271_criticas_exibe()
#--------------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol12712") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol12712 AT 07,04 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL SET_COUNT(p_index - 1)

   DISPLAY ARRAY p_romaneios TO s_romaneios.*
  
   CLOSE WINDOW w_pol12712
   
END FUNCTION

#----------------------------------#
FUNCTION pol1271_cria_solicit_tmp()
#----------------------------------#

   DROP TABLE solicit_tmp_885

   CREATE TEMP TABLE solicit_tmp_885(
      num_om     INTEGER,
      num_pedido DECIMAL(6,0),
      cod_acao   CHAR(01)
    );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","SOLICIT_TMP_885")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1271_restaurar()
#---------------------------#

   CALL pol1271_gera_num_sf()
   
   SELECT COUNT(solicitacao_fatura)
     INTO p_count
     FROM fat_solic_mestre
    WHERE empresa = p_cod_empresa
      AND solicitacao_fatura = p_num_sf
    
   IF p_count > 0 THEN
      CALL log0030_mensagem('Solicitação sem necessidade de restauração','excla')
      RETURN FALSE
   END IF
   
   INITIALIZE p_nf_solicit TO NULL
   
   DECLARE cq_nfs CURSOR FOR
    SELECT cod_empresa,
           num_solicit,
           dat_refer,
           cod_via_transporte,
           cod_entrega,
           ies_tip_solicit,
           ies_lotes_geral,
           cod_tip_carteira,
           num_lote_om,
           num_om,
           val_frete,
           val_seguro,
           val_frete_ex,
           val_seguro_ex,
           pes_tot_bruto,
           ies_situacao,
           num_sequencia,
           nom_usuario,
           cod_transpor,
           num_placa,
           num_volume,
           cod_cnd_pgto,
           pes_tot_liquido,
           cod_embal_1,
           qtd_embal_1
      FROM nf_solicit_885
     WHERE cod_empresa  = p_cod_empresa
       AND num_romaneio = p_num_solicit 

   
   FOREACH cq_nfs INTO 
           p_nf_solicit.cod_empresa,
           p_nf_solicit.num_solicit,
           p_nf_solicit.dat_refer,
           p_nf_solicit.cod_via_transporte,
           p_nf_solicit.cod_entrega,
           p_nf_solicit.ies_tip_solicit,
           p_nf_solicit.ies_lotes_geral,
           p_nf_solicit.cod_tip_carteira,
           p_nf_solicit.num_lote_om,
           p_nf_solicit.num_om,
           p_nf_solicit.val_frete,
           p_nf_solicit.val_seguro,
           p_nf_solicit.val_frete_ex,
           p_nf_solicit.val_seguro_ex,
           p_nf_solicit.pes_tot_bruto,
           p_nf_solicit.ies_situacao,
           p_nf_solicit.num_sequencia,
           p_nf_solicit.nom_usuario,
           p_nf_solicit.cod_transpor,
           p_nf_solicit.num_placa,
           p_nf_solicit.num_volume,
           p_nf_solicit.cod_cnd_pgto,
           p_nf_solicit.pes_tot_liquido,
           p_nf_solicit.cod_embal_1,
           p_nf_solicit.qtd_embal_1    

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("LENDO","nf_solicit_885")
         RETURN FALSE
      END IF

      SELECT num_nff
        INTO p_num_nff
        FROM ordem_montag_mest
       WHERE cod_empresa = p_cod_empresa
         AND num_om = p_nf_solicit.num_om
      
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("LENDO","ordem_montag_mest")
         RETURN FALSE
      END IF
      
      IF p_num_nff IS NULL OR p_num_nff = ' ' OR p_num_nff = 0 THEN
      ELSE
         CONTINUE FOREACH
      END IF
      
      LET p_roma.ufveiculo = NULL
      
      DECLARE cq_uf CURSOR FOR
       SELECT ufveiculo
         FROM romaneio_885
        WHERE codempresa = p_nf_solicit.cod_empresa
          AND numromaneio = p_nf_solicit.num_solicit
          AND statusregistro = '1'
          AND (ufveiculo IS NOT NULL AND ufveiculo <> ' ')
      
      FOREACH cq_uf INTO p_roma.ufveiculo
         EXIT FOREACH
      END FOREACH
      
      IF p_roma.ufveiculo IS NULL THEN
         LET p_roma.ufveiculo = p_nf_solicit.num_placa[1,2]
      END IF
   
      IF NOT pol1271_grava_nf_solicit() THEN
         RETURN FALSE
      END IF
   
   END FOREACH

   RETURN TRUE
      
END FUNCTION

#------------------------------#
FUNCTION pol1271_transf_situa()
#------------------------------#

   LET p_cod_operacao = p_oper_s_trnsf
   LET p_estoque_lote_ender.ies_situa_qtd = 'E'
   
   IF NOT pol1271_ins_transf() THEN
      RETURN FALSE
   END IF
   
   LET p_num_trans_origem = p_num_transac

   LET p_cod_operacao = p_oper_e_trnsf
   LET p_estoque_lote_ender.ies_situa_qtd = 'L'	
   
   IF NOT pol1271_ins_transf() THEN
      RETURN FALSE
   END IF
   
   LET p_num_trans_destino = p_num_transac
   
   INSERT INTO sup_mov_orig_dest
      VALUES(p_cod_empresa,
             p_num_trans_origem,
             p_num_trans_destino,'2')

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','sup_mov_orig_dest')
      RETURN FALSE
   END IF

   IF NOT pol1271_atuali_estoq() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION            

#----------------------------#
FUNCTION pol1271_ins_transf()
#----------------------------#

   DEFINE p_estoque_trans     RECORD LIKE estoque_trans.*,
          p_estoque_trans_end RECORD LIKE estoque_trans_end.*
   
   DEFINE p_ies_com_detalhe   LIKE estoque_operac.ies_com_detalhe,
          p_num_conta         LIKE estoque_operac_ct.num_conta_debito

   INITIALIZE p_estoque_trans,
              p_estoque_trans_end TO NULL
              
   SELECT ies_com_detalhe
     INTO p_ies_com_detalhe
     FROM estoque_operac
    WHERE cod_empresa  = p_cod_empresa
      AND cod_operacao = p_cod_operacao

   IF STATUS = 100 THEN
     LET p_ies_com_detalhe = 'N'
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_operac')
         RETURN FALSE
      END IF
   END IF

   IF p_ies_com_detalhe = 'S' THEN 
      IF p_cod_operacao = p_oper_s_trnsf THEN
         SELECT num_conta_debito 
           INTO p_num_conta
           FROM estoque_operac_ct
          WHERE cod_empresa  = p_cod_empresa
            AND cod_operacao = p_cod_operacao
      ELSE
         SELECT num_conta_credito 
           INTO p_num_conta
           FROM estoque_operac_ct
          WHERE cod_empresa  = p_cod_empresa
            AND cod_operacao = p_cod_operacao
      END IF
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_operac_ct')
         RETURN FALSE
      END IF
   ELSE
      LET p_num_conta = NULL
   END IF
      
   LET p_estoque_trans.cod_empresa        = p_cod_empresa
   LET p_estoque_trans.num_transac        = 0
   LET p_estoque_trans.cod_item           = p_estoque_lote_ender.cod_item
   LET p_estoque_trans.dat_movto          = TODAY
   LET p_estoque_trans.dat_ref_moeda_fort = TODAY
   LET p_estoque_trans.dat_proces         = TODAY
   LET p_estoque_trans.hor_operac         = TIME
   LET p_estoque_trans.ies_tip_movto      = 'N'
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_prog           = "pol1271"
   LET p_estoque_trans.num_docum          = p_num_solicit
   LET p_estoque_trans.num_seq            = NULL
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = NULL
   LET p_estoque_trans.nom_usuario        = p_user
   LET p_estoque_trans.qtd_movto          = p_estoque_lote_ender.qtd_saldo

   IF p_cod_operacao = p_oper_s_trnsf THEN 
      LET p_estoque_trans.ies_sit_est_orig   = p_estoque_lote_ender.ies_situa_qtd
      LET p_estoque_trans.cod_local_est_orig = p_estoque_lote_ender.cod_local
      LET p_estoque_trans.num_lote_orig      = p_estoque_lote_ender.num_lote
   ELSE
      LET p_estoque_trans.ies_sit_est_dest   = p_estoque_lote_ender.ies_situa_qtd
      LET p_estoque_trans.cod_local_est_dest = p_estoque_lote_ender.cod_local
      LET p_estoque_trans.num_lote_dest      = p_estoque_lote_ender.num_lote
   END IF
   
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

   LET p_num_transac = SQLCA.SQLERRD[2]

   LET p_estoque_trans_end.num_transac      = p_num_transac
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
     CALL log003_err_sql('Inserindo','estoque_trans_end')  
     RETURN FALSE
   END IF

  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, p_num_transac, p_user, getdate(),'pol1271')

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_auditoria')   
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1271_atuali_estoq()
#------------------------------#

   UPDATE estoque
      SET qtd_lib_excep = qtd_lib_excep - p_estoque_lote_ender.qtd_saldo,
          qtd_liberada  = qtd_liberada  + p_estoque_lote_ender.qtd_saldo
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_estoque_lote_ender.cod_item
      
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Atualizando','estoque')   
     RETURN FALSE
   END IF

   IF p_estoque_lote_ender.num_lote IS NOT NULL THEN
      UPDATE estoque_lote
         SET ies_situa_qtd = 'L'
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_estoque_lote_ender.cod_item
         AND cod_local   = p_estoque_lote_ender.cod_local
         AND num_lote    = p_estoque_lote_ender.num_lote
         AND ies_situa_qtd = 'E'
      IF STATUS = 0 THEN
         UPDATE estoque_lote_ender
            SET ies_situa_qtd = 'L'
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_estoque_lote_ender.cod_item
            AND cod_local   = p_estoque_lote_ender.cod_local
            AND num_lote    = p_estoque_lote_ender.num_lote
            AND largura     = p_estoque_lote_ender.largura
            AND altura      = p_estoque_lote_ender.altura
            AND diametro    = p_estoque_lote_ender.diametro
            AND comprimento = p_estoque_lote_ender.comprimento
            AND ies_situa_qtd = 'E'
      ELSE
         CALL log003_err_sql('Atualizando','estoque_lote')
         RETURN FALSE
      END IF
   ELSE
      UPDATE estoque_lote
         SET ies_situa_qtd = 'L'
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_estoque_lote_ender.cod_item
         AND cod_local   = p_estoque_lote_ender.cod_local
         AND ies_situa_qtd = 'E'         
         AND num_lote IS NULL
      IF STATUS = 0 THEN
         UPDATE estoque_lote_ender
            SET ies_situa_qtd = 'L'
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_estoque_lote_ender.cod_item
            AND cod_local   = p_estoque_lote_ender.cod_local
            AND largura     = p_estoque_lote_ender.largura
            AND altura      = p_estoque_lote_ender.altura
            AND diametro    = p_estoque_lote_ender.diametro
            AND comprimento = p_estoque_lote_ender.comprimento
            AND ies_situa_qtd = 'E'
            AND num_lote IS NULL
      ELSE
         CALL log003_err_sql('Atualizando','estoque_lote')
         RETURN FALSE
      END IF
   END IF
      
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Atualizando','estoque_lote_ender')   
     RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------FIM DO ROMANEIO--------------------------#

#-----------------------------------#
FUNCTION pol1271_ve_se_eh_conjunto()#
#-----------------------------------#

   DEFINE p_num_ordem           LIKE ordens.num_ordem,
          p_seq_txt             CHAR(03)
   
   #LET p_num_docum = p_numpedido USING '<<<<<<'
   #LET p_seq_txt = p_numseqitem USING '<<<'
   #LET p_num_docum = p_num_docum CLIPPED, '/', p_seq_txt

   SELECT num_ordem
     INTO p_num_ordem
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_docum = p_num_docum
      AND cod_item = p_coditem
      AND cod_item_pai = 0
   
   IF STATUS = 100 THEN
      LET p_msg = 'Não foi possivel localizar a\n',
                  'OP do item ',p_coditem CLIPPED,' a par-\n',
                  'tir do documento ', p_num_docum 
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordens')
         RETURN FALSE
      END IF
   END IF  

  SELECT parametro_numerico 
    INTO m_ordem_antiga
    FROM min_par_modulo 
   WHERE empresa = m_cod_emp_op
     AND parametro = 'MAIOR_OP_ANTIGA'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','min_par_modulo')
      ERROR 'Não foi possivel ler MAIOR_OP_ANTIGA'
      RETURN FALSE
   END IF 

   SELECT count(a.cod_item_compon)                   
     INTO p_count                                            
     FROM ord_compon a, item b                               
    WHERE a.cod_empresa = p_cod_empresa                                       
      AND a.num_ordem = p_num_ordem        
      AND a.num_ordem > m_ordem_antiga                                
      AND a.ies_tip_item <> 'C'                                       
      AND b.cod_empresa = a.cod_empresa                               
      AND b.cod_item = a.cod_item_compon                              
      AND b.cod_familia  in ('200','201','202','205')                 
      AND substring(a.cod_item_compon,1,1) < 'A'                      

   IF STATUS <> 0 THEN
 	    CALL log003_err_sql('Lendo','ord_compon:1')
      RETURN FALSE
	 END IF

   IF p_count > 0 THEN
      LET p_eh_conjunto = TRUE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------INICIO DO APONTAMENTO DA CHAPA OU CONJUNTO-------#

#-----------------------------#
FUNCTION pol1271_aponta_item()#
#-----------------------------#

   DEFINE p_num_ordem           LIKE ordens.num_ordem,
          p_cod_operac          LIKE consumo.cod_operac,
          p_seq_operac          LIKE consumo.num_seq_operac,
          p_cod_roteiro         LIKE ordens.cod_roteiro, 
          p_num_altern_roteiro  LIKE ordens.num_altern_roteiro,
          p_seq_txt             CHAR(03)
   
   INITIALIZE p_man TO NULL

   #LET p_num_docum = p_numpedido USING '<<<<<<'
   #LET p_seq_txt = p_numseqitem USING '<<<'
   #LET p_num_docum = p_num_docum CLIPPED, '/', p_seq_txt
   
   SELECT num_ordem,
          cod_roteiro, 
          num_altern_roteiro
     INTO p_num_ordem,
          p_cod_roteiro,
          p_num_altern_roteiro
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_docum = p_num_docum
      AND cod_item = p_coditem
      AND cod_item_pai = 0
   
   IF STATUS = 100 THEN
      LET p_msg = 'Não foi possivel localizar a\n',
                  'OP do item ',p_coditem CLIPPED, ' a par-\n',
                  'tir do documento ', p_num_docum 
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordens')
         RETURN FALSE
      END IF
   END IF  

   LET p_man.num_seq_apont = 0
   LET p_man.empresa = p_cod_empresa
   LET p_man.item = p_coditem
   LET p_man.ordem_producao = p_num_ordem
   LET p_man.num_seq_pedido = p_numseqitem
   LET p_man.num_pedido = p_numpedido
   LET p_man.dat_ini_producao = CURRENT
   LET p_man.dat_fim_producao = CURRENT
   LET p_man.hor_inicial = '00:00:00'
   LET p_man.hor_fim = '00:00:00'
   LET p_man.qtd_movto = p_qtd_romanear
   LET p_man.tip_movto = 'L'
   LET p_man.largura = p_largura      
   LET p_man.diametro = 0             
   LET p_man.altura = 0               
   LET p_man.comprimento = p_comprimento
   LET p_man.ies_devolucao = 'N'
   LET p_dat_movto  = TODAY
   LET p_dat_proces = TODAY
   LET p_hor_operac = TIME
   LET p_man.turno = 1
   

   SELECT operacao, 
          seq_operacao,
          centro_trabalho,
          centro_custo,
          arranjo
     INTO p_cod_operac,
          p_seq_operac,
          p_man.centro_trabalho,
          p_man.centro_custo,
          p_man.arranjo            
     FROM man_processo_item
    WHERE empresa             = p_cod_empresa
      AND item                = p_coditem
      AND roteiro             = p_cod_roteiro
      AND roteiro_alternativo = p_num_altern_roteiro
      AND operacao_final = 'S'
                    
   IF STATUS = 100 THEN
      LET p_den_erro = 'ITEM ',p_coditem CLIPPED, ' SEM ROTEIRO NA TABELA MAN_PROCESSO_ITEM'
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      ELSE
         RETURN TRUE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','consumo/consumo_compl')
         RETURN FALSE
      END IF
   END IF  

   LET p_man.cod_recur = p_cod_operac
   LET p_man.operacao = p_cod_operac  
   LET p_man.sequencia_operacao = p_seq_operac
   LET p_man.seq_leitura = 1
   LET p_man.ies_chapa = m_ies_chapa
      
   LET p_man.dat_atualiz = CURRENT YEAR TO SECOND
   LET p_man.nom_prog = 'POL1269'
   LET p_man.nom_usuario = p_user
   LET p_man.num_versao = 1
   LET p_man.versao_atual = 'S'
   LET p_man.cod_status = '0'
   LET p_man.qtd_hor = 0         #não apontar tempo
   LET p_man.unid_produtiva = ' '
      
   IF p_ctr_lote = 'S' THEN
      LET p_man.lote = p_numlote
   ELSE
      LET p_man.lote = NULL
   END IF
   
   LET p_msg = NULL
   
   IF NOT pol1269_le_operacoes() THEN
      LET p_den_erro = p_msg CLIPPED, ' - ', p_numlote
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      ELSE
         RETURN TRUE
      END IF
   END IF

   IF NOT pol1269_ck_material() THEN   
      LET p_den_erro = p_msg CLIPPED
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      ELSE
         RETURN TRUE
      END IF
   END IF
   
   IF p_msg IS NOT NULL THEN
      LET p_den_erro = p_msg CLIPPED
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      ELSE
         RETURN TRUE
      END IF
   END IF
      
   IF NOT pol1269b_aponta_producao() THEN #aponta a produção como liberada
      LET p_den_erro = p_msg CLIPPED, ' - ', p_numlote
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      ELSE
         RETURN TRUE
      END IF
   END IF

   IF NOT pol1271_baixa_material() THEN  #consome a matéria prima
      LET p_den_erro = p_msg CLIPPED, ' - ', p_numlote
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF   

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1271_baixa_material()#
#---------------------------------#
   
  DECLARE cq_structure CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           cod_local_baixa
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_man.ordem_producao

   FOREACH cq_structure INTO 
           p_cod_compon, 
           p_qtd_necessaria,
           p_cod_local_baixa

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ord_compon')
         RETURN FALSE
      END IF  
      
      LET p_qtd_baixar = p_qtd_necessaria * p_man.qtd_movto
               
      IF NOT pol1271_bx_pelo_fifo() THEN
         RETURN FALSE
      END IF
   
   END FOREACH
         
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1271_bx_pelo_fifo()#
#------------------------------#   
   
   DEFINE p_qtd_reservada   DECIMAL(10,3), 
          p_qtd_saldo       DECIMAL(10,3),
          p_baixa_do_lote   DECIMAL(10,3)

   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01),
         num_conta     CHAR(20),
         cus_unit      DECIMAL(12,2),
         cus_tot       DECIMAL(12,2)
   END RECORD

   LET p_item.cus_unit      = 0
   LET p_item.cus_tot       = 0
         
   DECLARE cq_fifo CURSOR FOR
    SELECT *
      FROM estoque_lote_ender
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = p_cod_compon
       AND cod_local = p_cod_local_baixa
       AND ies_situa_qtd = 'L'
       AND qtd_saldo > 0
       AND num_lote IS NULL
     ORDER BY num_transac    
   
   FOREACH cq_fifo INTO p_estoque_lote_ender.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_lote_ender/cq_fifo')
         RETURN FALSE
      END IF  
      
      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada 
        FROM estoque_loc_reser
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_estoque_lote_ender.cod_item
         AND cod_local   = p_estoque_lote_ender.cod_local
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_loc_reser/cq_fifo')
         RETURN FALSE
      END IF  

      IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
         LET p_qtd_reservada = 0
      END IF
      
      LET p_qtd_saldo = p_estoque_lote_ender.qtd_saldo - p_qtd_reservada
      
      IF p_qtd_saldo < p_qtd_baixar THEN
         LET p_baixa_do_lote = p_qtd_saldo
         LET p_qtd_baixar = p_qtd_baixar - p_baixa_do_lote
      ELSE
         LET p_baixa_do_lote = p_qtd_baixar
         LET p_qtd_baixar = 0
      END IF
      
      #Carrega record p_item, para chamada da func005, a qual
      #irá fazer a saída do material
      
      LET p_item.cod_empresa   = p_estoque_lote_ender.cod_empresa
      LET p_item.cod_item      = p_estoque_lote_ender.cod_item
      LET p_item.cod_local     = p_estoque_lote_ender.cod_local
      LET p_item.num_lote      = p_estoque_lote_ender.num_lote
      LET p_item.comprimento   = p_estoque_lote_ender.comprimento
      LET p_item.largura       = p_estoque_lote_ender.largura    
      LET p_item.altura        = p_estoque_lote_ender.altura     
      LET p_item.diametro      = p_estoque_lote_ender.diametro   
      LET p_item.cod_operacao  = p_cod_oper_sp
      LET p_item.ies_situa     = p_estoque_lote_ender.ies_situa_qtd
      LET p_item.qtd_movto     = p_baixa_do_lote
      LET p_item.dat_movto     = p_dat_movto
      LET p_item.ies_tip_movto = 'N'
      LET p_item.dat_proces    = p_dat_proces
      LET p_item.hor_operac    = p_hor_operac
      LET p_item.num_prog      = p_man.nom_prog
      LET p_item.num_docum     = p_man.ordem_producao
      LET p_item.num_seq       = 0
      LET p_item.tip_operacao  = 'S' #Saída
      LET p_item.usuario       = p_man.nom_usuario
      LET p_item.cod_turno     = p_man.turno
      LET p_item.trans_origem  = 0
      
      IF p_estoque_lote_ender.num_lote IS NULL OR
          p_estoque_lote_ender.num_lote = ' ' THEN
         LET p_item.ies_ctr_lote  = 'N'
      ELSE
         LET p_item.ies_ctr_lote  = 'S'
      END IF
   
      IF NOT func005_insere_movto(p_item) THEN
         RETURN FALSE
      END IF
      
      LET p_tip_movto = 'S'
      LET p_qtd_movto = p_baixa_do_lote
      LET p_transac_consumo = p_num_trans_atual
      
      IF NOT pol1269b_insere_chf_componente() THEN            
         RETURN FALSE                                        
      END IF                                                 

      IF NOT pol1269b_insere_man_consumo() THEN            
         RETURN FALSE                                        
      END IF                                                 
      
      IF p_qtd_baixar <= 0 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH

   IF p_qtd_baixar > 0 THEN
      LET p_den_erro = 'S/SALDO DO ',p_cod_compon CLIPPED,' P/PRODUZIR O ', p_man.item
      IF NOT pol1271_insere_erro() THEN
         RETURN FALSE
      END IF
      CALL log0030_mensagem(p_den_erro,'info')
   END IF
   
   RETURN TRUE

END FUNCTION

#ROTINA DE LISTAGEM DAS OM's X PEDIDOS

#------------------------#
FUNCTION pol1271_listar()#
#------------------------#

   CALL pol1071_inicializa_relat()

   DECLARE cq_ord_l CURSOR FOR
    SELECT DISTINCT
           num_om,
           num_pedido
      FROM solicit_fat_885
     WHERE cod_empresa = p_cod_empresa
       AND num_solicit = p_num_solicit
       
   FOREACH cq_ord_l INTO
           p_num_om,
           p_num_pedido

      SELECT cod_cliente
        INTO p_cod_cliente
        FROM pedidos
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_num_pedido
      
      IF STATUS = 0 THEN
         SELECT nom_cliente
           INTO p_nom_cliente
           FROM clientes
          WHERE cod_cliente = p_cod_cliente

         IF STATUS <> 0 THEN
            LET p_nom_cliente = NULL
         END IF
      END IF
            
      LET p_count = p_count + 1
      
      OUTPUT TO REPORT pol1071_relat() 
      
   END FOREACH
   
   CALL pol1071_finaliza_relat()
   
END FUNCTION

#----------------------------------#
FUNCTION pol1071_inicializa_relat()
#----------------------------------#
      
   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN 
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1071_relat TO PIPE p_nom_arquivo
      ELSE 
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1071.tmp' 
         START REPORT pol1071_relat TO p_caminho 
      END IF 
   ELSE
      START REPORT pol1071_relat TO p_nom_arquivo
   END IF
          
   LET p_count = 0

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'Empresa')
      RETURN FALSE
   END IF 

END FUNCTION

#--------------------------------#
FUNCTION pol1071_finaliza_relat()
#--------------------------------#

   FINISH REPORT pol1071_relat

   FINISH REPORT pol0778_relat   
   
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

#----------------------#
 REPORT pol1071_relat()#
#----------------------#
  
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 2
          BOTTOM MARGIN 2
          PAGE   LENGTH 66
          
   FORMAT
      
      FIRST PAGE HEADER  
      
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 073, "PAG. ", PAGENO USING "##&"
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT COLUMN 020, "ORDENS DE MONTAGEM DO ROMANEIO",
               COLUMN 051, p_num_solicit USING '##########'
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '     ORDEM     PEDIDO       CLIENTE                 DESCRICAO'
         PRINT COLUMN 001, '  ---------- ---------- --------------- ---------------------------------------'
                                           
      ON EVERY ROW
         
         PRINT COLUMN 003, p_num_om USING '##########',
               COLUMN 014, p_num_pedido USING '##########',
               COLUMN 025, p_cod_cliente,
               COLUMN 041, p_nom_cliente  

     PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 066, "* * * ULTIMA FOLHA * * *"
           LET p_last_row = FALSE
        ELSE 
           PRINT " "
        END IF
                                 
END REPORT

#-------------------------#
FUNCTION pol1271_agrupar()#
#-------------------------#
   
   DEFINE p_controle   INTEGER,
          p_agrupa     CHAR(01)

   #LET p_num_solicit = 171024017
   
   #CALL pol1271_gera_num_sf()
   
   LET INT_FLAG = FALSE
   
   LET p_index = 1
   
   DECLARE cq_pedido CURSOR FOR
   SELECT a.trans_solic_fatura,
          b.controle,
          c.num_om,
          c.num_pedido,
          d.cod_cliente,    
          d.cod_nat_oper,
          d.cod_tip_carteira          
     FROM fat_solic_mestre a, 
          fat_solic_fatura b,
          solicit_fat_885 c,
          pedidos d
    WHERE a.empresa = p_cod_empresa
      AND c.cod_empresa = a.empresa
      AND c.num_solicit = p_num_solicit
      AND b.trans_solic_fatura = a.trans_solic_fatura
      AND b.ord_montag = c.num_om
      AND d.cod_empresa = a.empresa
      AND d.num_pedido  = c.num_pedido
    ORDER BY b.controle

   FOREACH cq_pedido INTO
           p_num_transac,
           p_controle,
           p_num_om,
           p_num_pedido,
           p_cod_cliente,
           p_cod_nat_oper,
           p_cod_tip_carteira

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_pedido')
         RETURN FALSE
      END IF

      SELECT num_nff
        INTO p_num_nff
        FROM ordem_montag_mest
       WHERE cod_empresa = p_cod_empresa
         AND num_om = p_num_om
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordem_montag_mest')
         RETURN FALSE
      END IF
      
      IF p_num_nff IS NULL OR p_num_nff = ' ' THEN
      ELSE
         CONTINUE FOREACH
      END IF
      
      SELECT nom_cliente
        INTO p_nom_cliente
        FROM clientes
       WHERE cod_cliente = p_cod_cliente

      IF STATUS <> 0 THEN
         LET p_nom_cliente = NULL
      END IF
            
      LET pr_pedido[p_index].num_om = p_num_om 
      LET pr_pedido[p_index].num_pedido = p_num_pedido
      LET pr_pedido[p_index].cod_cliente = p_cod_cliente
      LET pr_pedido[p_index].nom_cliente = p_nom_cliente
      LET pr_pedido[p_index].controle = p_index
      LET pr_pedido[p_index].cod_nat_oper = p_cod_nat_oper
      LET pr_pedido[p_index].cod_tip_carteira = p_cod_tip_carteira
      
      LET p_index = p_index + 1
      
      IF p_index > 30 THEN
         LET p_msg = 'Limite de linhas da\n',
                     'grade superou a pre-\n',
                     'visão de 30 linhas.' 
         CALL log0030_mensagem(p_msg, 'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
      
   LET p_index = p_index - 1
   LET p_qtd_linha = p_index
      
   IF p_qtd_linha = 0 THEN
      LET p_msg = 'O romaneio informado não contém\n',
                  'ordem de montagem para agrupar'
      CALL log0030_mensagem(p_msg, 'info')
      RETURN FALSE
   END IF
   
   IF NOT pol1271_edita_controle() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1271_edita_controle()#
#--------------------------------#
   
   DEFINE l_ind          INTEGER,
          l_controle     INTEGER,
          l_juntou       SMALLINT
   
   INITIALIZE p_nom_tela TO NULL 
   
   CALL log130_procura_caminho("pol12715") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol12715 AT 04,02 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
      
   LET INT_FLAG = FALSE
   
   CALL SET_COUNT(p_index)
   
   INPUT ARRAY pr_pedido 
      WITHOUT DEFAULTS FROM sr_pedido.*   

      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()
      
      AFTER FIELD controle
      
         IF pr_pedido[p_index].controle IS NULL THEN
            IF p_index <= p_qtd_linha THEN
               ERROR 'Campo com preenchimento obrigatório'
               NEXT FIELD controle
            END IF
         END IF

         LET l_juntou = FALSE
         LET l_controle = pr_pedido[p_index].controle

         FOR l_ind = 1 TO p_qtd_linha
             IF l_ind = p_index THEN
             ELSE
                IF l_controle = pr_pedido[l_ind].controle THEN
                   LET p_msg = NULL
                   IF NOT pol1271_ve_se_juntou(l_ind, p_index) THEN
                      RETURN FALSE
                   END IF
                   IF p_msg IS NOT NULL THEN
                      LET p_msg = p_msg CLIPPED, 
                            'Você não pode juntar pedidos\n',
                            'com pedidos de clienets ca-\n',
                            'dastrados no POL1327.'
                      CALL log0030_mensagem(p_msg,'info')
                      NEXT FIELD controle
                   END IF
                END IF
             END IF                
         END FOR
         
         IF p_index >= p_qtd_linha THEN
            IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
                 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
            ELSE
               NEXT FIELD controle
            END IF
         END IF
         
         IF pol1271_controle_invalido() THEN
            LET p_msg = 'Não é permitido jantar pedidos\n',
                        'com clientes, operações ou\n',
                        'carteiras diferentes'
            CALL log0030_mensagem(p_msg,'info')
            NEXT FIELD controle
         END IF
   
   END INPUT
   
   CLOSE WINDOW w_pol12715

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1271_agrupa_controle() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#--------------------------------------------#
FUNCTION pol1271_ve_se_juntou(l_ind, l_index)#
#--------------------------------------------#

   DEFINE l_ind, l_index      INTEGER
   
   SELECT 1 FROM nao_agrupar_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = pr_pedido[l_index].cod_cliente
            
   IF STATUS = 0 THEN
      LET p_msg = 'Cliente: ',pr_pedido[l_index].cod_cliente CLIPPED,'\n',
                  ' não permite juntar pedidos.\n'
      RETURN TRUE
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','nao_agrupar_885:ref.01')
         RETURN FALSE
      END IF   
   END IF
         
   SELECT 1 FROM nao_agrupar_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = pr_pedido[l_ind].cod_cliente
            
   IF STATUS = 0 THEN
      LET p_msg = 'Cliente: ',pr_pedido[l_ind].cod_cliente CLIPPED,'\n',
                  ' não permite juntar pedidos.\n'
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','nao_agrupar_885:ref.02')
         RETURN FALSE
      END IF   
   END IF

   RETURN TRUE

END FUNCTION
   
#-----------------------------------#
FUNCTION pol1271_controle_invalido()#
#-----------------------------------#
   
   DEFINE m_ind        INTEGER,
          m_invalido   SMALLINT
   
   LET m_invalido = FALSE
   
   FOR m_ind = 1 to p_qtd_linha
       IF m_ind <> p_index THEN
          IF pr_pedido[m_ind].controle = pr_pedido[p_index].controle THEN
             IF pr_pedido[m_ind].cod_cliente <> pr_pedido[p_index].cod_cliente THEN
                LET m_invalido = TRUE
             END IF
             IF pr_pedido[m_ind].cod_nat_oper <> pr_pedido[p_index].cod_nat_oper THEN
                LET m_invalido = TRUE
             END IF
             IF pr_pedido[m_ind].cod_tip_carteira <> pr_pedido[p_index].cod_tip_carteira THEN
                LET m_invalido = TRUE
             END IF
          END IF
       END IF
   END FOR

   RETURN m_invalido

END FUNCTION   

#--------------------------------#
FUNCTION pol1271_agrupa_controle()#
#--------------------------------#
   
   FOR p_index = 1 to p_qtd_linha
       IF pr_pedido[p_index].controle IS NOT NULL THEN

          UPDATE fat_solic_fatura 
             SET controle = pr_pedido[p_index].controle
           WHERE trans_solic_fatura = p_num_transac
             AND ord_montag = pr_pedido[p_index].num_om
         
          IF STATUS <> 0 THEN
             CALL log003_err_sql('UPDATE','fat_solic_fatura:ac')
             RETURN FALSE
          END IF
          
       END IF
   END FOR
   
   RETURN TRUE

END FUNCTION
   

#--------------------------------#
FUNCTION pol1271_transf_sucata() #
#--------------------------------#

	  DEFINE m_pes_unit        LIKE item.pes_unit,
	         m_unid_item       LIKE item.cod_unid_med,
	         m_unid_sucata     LIKE item.cod_unid_med,
           m_fat_conver      DECIMAL(12,5),
           m_qtd_conver      DECIMAL(15,3),
           m_ies_lote        CHAR(01)

   SELECT *
     INTO p_parametros_885.*
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('select','parametros_885')
      RETURN FALSE
   END IF

    #faz a saída do item origem                                                        
                                                                                                              
    LET m_ies_situa = 'L'                                                                                     
    LET m_ies_tip_movto = 'N'                                                                                 
    LET m_tip_operacao = 'S'                                                                                  
    LET m_qtd_movto = p_qtd_transf                                                                
    LET m_cod_operac = p_parametros_885.oper_sai_tp_refugo                                                  
    LET m_cod_item = mr_ordem_montag_item.cod_item
    LET m_num_lote = NULL
    LET m_dat_movto = TODAY
                                                                                                                     
    IF NOT pol1271_movto_estoque() THEN                                                                       
       RETURN FALSE                                                                                           
    END IF                                                                                                    
                                                                                                              
    LET p_est_trans_relac.num_transac_orig = p_num_trans_atual                                                
    LET p_est_trans_relac.cod_item_orig = m_cod_item                                                          
                                                                                                              
    #faz a entrada no item de sucata    
                                                                      
    LET m_ies_situa = 'L'                                                                                     
    LET m_ies_tip_movto = 'N'                                                                                 
    LET m_tip_operacao = 'E'      
    
    #faz a conversão entre unidades
    
   SELECT pes_unit,
          cod_unid_med
     INTO m_pes_unit, m_unid_item
     FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = m_cod_item
	        
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item:de')
      RETURN FALSE
   END IF    

   SELECT cod_unid_med
     INTO m_unid_sucata
     FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = p_parametros_885.cod_item_sucata
	        
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item:para')
      RETURN FALSE
   END IF    
    
    IF m_unid_item = m_unid_sucata THEN
       LET m_fat_conver = 1
       LET m_qtd_movto = p_qtd_transf  
    ELSE
       LET m_fat_conver = m_pes_unit
       LET m_qtd_movto = p_qtd_transf * m_fat_conver
    END IF
                                                                                
    LET m_cod_item = p_parametros_885.cod_item_sucata                                                                                                                      
    LET m_cod_operac = p_parametros_885.oper_ent_tp_refugo                                                  
  
   SELECT ies_ctr_lote
     INTO m_ies_lote
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item:ctr_lote')
      RETURN FALSE
   END IF
   
    IF m_ies_lote = 'S' THEN
       LET m_num_lote = p_parametros_885.num_lote_sucata
    ELSE
       LET m_num_lote = NULL
    END IF
                                                                                                            
    IF NOT pol1271_movto_estoque() THEN                                                                       
       RETURN FALSE                                                                                           
    END IF                                                                                                    
                                                                                                      
    LET p_est_trans_relac.num_transac_dest = p_num_trans_atual                                                
    LET p_est_trans_relac.cod_item_dest = p_parametros_885.cod_item_sucata                                    
                                                                                                       
    IF NOT pol1271_insere_relac() THEN                                                                        
       RETURN FALSE                                                                                           
    END IF                                                                                                    

    IF NOT pol1271_insere_transac() THEN                                                                        
       RETURN FALSE                                                                                           
    END IF                                                                                                    
    
    RETURN TRUE

END FUNCTION    
   

#-------------------------------#
FUNCTION pol1271_movto_estoque()#
#-------------------------------#   
   
   DEFINE l_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01),
         num_conta     CHAR(20),
         cus_unit      DECIMAL(12,2),
         cus_tot       DECIMAL(12,2)
   END RECORD

   DEFINE l_ies_ctr_lote CHAR(01)
                        
   LET l_item.cus_unit      = 0
   LET l_item.cus_tot       = 0
   
   SELECT cod_local_estoq,
          ies_ctr_lote
     INTO l_item.cod_local,
          l_ies_ctr_lote
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
      
   LET l_item.cod_empresa   = p_cod_empresa
   LET l_item.cod_item      = m_cod_item
   
   IF l_ies_ctr_lote = 'N' THEN
      LET l_item.num_lote = NULL
   ELSE
      LET l_item.num_lote = m_num_lote
   END IF
      
   LET l_item.comprimento   = 0
   LET l_item.largura       = 0  
   LET l_item.altura        = 0    
   LET l_item.diametro      = 0       
   LET l_item.cod_operacao  = m_cod_operac  
   LET l_item.ies_situa     = m_ies_situa
   LET l_item.qtd_movto     = m_qtd_movto   
   LET l_item.dat_movto     = m_dat_movto   
   LET l_item.ies_tip_movto = m_ies_tip_movto
   LET l_item.dat_proces    = TODAY
   LET l_item.hor_operac    = TIME
   LET l_item.num_docum     = mr_ordem_montag_item.num_pedido
   LET l_item.num_seq       = 0   
   LET l_item.tip_operacao  = m_tip_operacao   
   LET l_item.trans_origem  = 0
   LET l_item.ies_ctr_lote  = l_ies_ctr_lote
   LET l_item.usuario       = p_user
   LET l_item.cod_turno     = 3
   LET l_item.num_prog      = 'POL1271'
   
   IF NOT func005_insere_movto(l_item) THEN
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1271_insere_relac()#
#------------------------------#
   
   LET p_est_trans_relac.cod_empresa = p_cod_empresa
   LET p_est_trans_relac.num_nivel = 0
   LET p_est_trans_relac.dat_movto = m_dat_movto
      
   INSERT INTO est_trans_relac(
      cod_empresa,
      num_nivel,
      num_transac_orig,
      cod_item_orig,
      num_transac_dest,
      cod_item_dest,
      dat_movto)
   VALUES(p_est_trans_relac.*)

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('INSERT','est_trans_relac')
      RETURN FALSE
   END IF 

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1271_insere_transac()#
#--------------------------------# 

   INSERT INTO trans_relac_om_885
    VALUES(p_cod_empresa,
           mr_ordem_montag_item.num_om,
           mr_ordem_montag_item.num_pedido,
           mr_ordem_montag_item.num_sequencia,
           p_est_trans_relac.num_transac_orig,
           p_est_trans_relac.num_transac_dest)
           
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('INSERT','trans_relac_om_885')
      RETURN FALSE
   END IF 

   RETURN TRUE
   
END FUNCTION
           

#--------------------------------#
FUNCTION pol1271_copia_roma_885()
#--------------------------------#
   
   DEFINE lr_roma        RECORD LIKE romaneio_885.*,
          lr_r_item      RECORD LIKE roma_item_885.*
          
   DEFINE l_pedido       DECIMAL(6,0),
          l_num_seq      DECIMAL(3,0)
                
   SELECT MAX(numpedido) 
     INTO l_pedido
     FROM roma_item_885
    WHERE codempresa  = p_cod_empresa
      AND numromaneio = p_num_solicit
      AND numseqpai   = p_num_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','roma_item_885.1')
      RETURN FALSE
   END IF

   IF l_pedido IS NULL THEN
      LET p_msg = 'Erro validando pedido na tabela roma_item_885.1'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   IF l_pedido < 500000 THEN
      RETURN TRUE
   END IF

   SELECT MIN(numpedido) 
     INTO l_pedido
     FROM roma_item_885
    WHERE codempresa  = p_cod_empresa
      AND numromaneio = p_num_solicit
      AND numseqpai   = p_num_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','roma_item_885.2')
      RETURN FALSE
   END IF

   IF l_pedido IS NULL THEN
      LET p_msg = 'Erro validando pedido na tabela roma_item_885.2'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF

   IF l_pedido < 50000 THEN
      LET p_msg = 'Pedidos de empresas diferentes\n não são permitidos\n no mesmo romaneio.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
      
   DELETE FROM romaneio_885
    WHERE codempresa = m_cod_emp_pv
      AND numromaneio  = p_num_solicit
      AND numsequencia = p_num_sequencia
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','romaneio_885')
      RETURN FALSE
   END IF

   DELETE FROM roma_item_885
    WHERE codempresa = m_cod_emp_pv
      AND numromaneio  = p_num_solicit
      AND numseqpai   = p_num_sequencia
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','roma_item_885')
      RETURN FALSE
   END IF
   
   SELECT *
     INTO lr_roma.*
     FROM romaneio_885
    WHERE codempresa = p_cod_empresa
      AND numromaneio  = p_num_solicit
      AND NumSequencia = p_num_sequencia
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','romaneio_885')
      RETURN FALSE
   END IF
   
   LET lr_roma.codempresa = m_cod_emp_pv
   
   INSERT INTO romaneio_885 VALUES(lr_roma.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','romaneio_885')
      RETURN FALSE
   END IF

   DECLARE cq_ins_it CURSOR FOR
    SELECT * FROM roma_item_885
     WHERE codempresa  = p_cod_empresa
       AND numromaneio = p_num_solicit
       AND numseqpai   = p_num_sequencia
   
   FOREACH cq_ins_it INTO lr_r_item.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','roma_item_885.cq_ins_it')
         RETURN FALSE
      END IF
      
      LET lr_r_item.codempresa = m_cod_emp_pv
   
      INSERT INTO roma_item_885 VALUES(lr_r_item.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','roma_item_885.cq_ins_it')
         RETURN FALSE
      END IF
            
   END FOREACH
   
   UPDATE romaneio_885
      SET industrializacao = 'S'
    WHERE codempresa = m_cod_emp_op
      AND numromaneio  = p_num_solicit
      AND NumSequencia = p_num_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','romaneio_885.cop_roma')
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION
   
#--------------------------#
FUNCTION pol1271_modificar()
#--------------------------#
   
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol12714") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol12714 AT 03,03 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   LET p_status = pol1271_info_nf()
   
   CLOSE WINDOW w_pol12714
   
   RETURN p_status

END FUNCTION

#-------------------------#
FUNCTION pol1271_info_nf()#
#-------------------------#
      
   LET INT_FLAG = FALSE
   LET m_num_nff = NULL

  SELECT MAX(trans_nota_fiscal)
     INTO m_num_transac
     FROM fat_nf_mestre
    WHERE empresa = p_cod_empresa
      AND cliente in (
          SELECT cod_cliente FROM cli_alt_desc_885
           WHERE cod_empresa = p_cod_empresa
             AND ies_ativo = 'S')
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','fat_nf_mestre')
      RETURN FALSE
   END IF       
   
   IF m_num_transac IS NULL THEN
      LET m_num_transac = 0
   END IF
   
   IF m_num_transac > 0 THEN
      SELECT nota_fiscal,
             cliente
        INTO m_num_nff,
             m_cod_cliente
        FROM fat_nf_mestre
       WHERE empresa = p_cod_empresa
         AND trans_nota_fiscal = m_num_transac

      IF STATUS = 100 THEN
         LET m_num_nff = NULL
      ELSE
         IF STATUS = 0 THEN
            SELECT nom_reduzido INTO m_nom_reduzido
              FROM clientes WHERE cod_cliente = m_cod_cliente
            IF STATUS <> 0 THEN
               LET m_nom_reduzido = NULL
            END IF
         ELSE
            CALL log003_err_sql('SELECT','fat_nf_mestre')
            RETURN FALSE
         END IF
      END IF    
   END IF   
   
   DISPLAY m_cod_cliente TO cod_cliente
   DISPLAY m_nom_reduzido TO nom_reduzido
   
   INPUT m_num_nff WITHOUT DEFAULTS FROM num_nff

      AFTER FIELD num_nff
         
         IF m_num_nff IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD num_nff
         END IF

        SELECT trans_nota_fiscal,
               cliente
          INTO m_num_transac,
               m_cod_cliente
          FROM fat_nf_mestre
         WHERE empresa = p_cod_empresa
           AND nota_fiscal = m_num_nff
           AND cliente IN (
               SELECT cod_cliente FROM cli_alt_desc_885
                WHERE cod_empresa = p_cod_empresa AND ies_ativo = 'S')
        
        IF STATUS = 100 THEN
           LET p_msg = 'NF não existe ou não é de um cliente\n',
                       'que exige alteração da descrição. '
           CALL log0030_mensagem(p_msg,'info')
           NEXT FIELD num_nff
        ELSE
           IF STATUS <> 0 THEN
              CALL log003_err_sql('SELECT','fat_nf_mestre')
              RETURN FALSE
           END IF
        END IF                    
        
   END INPUT
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1271_le_itens() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1271_le_itens()#
#--------------------------#

   DEFINE l_ind         INTEGER,
          s_ind         INTEGER,
          l_pedido      INTEGER, 
          l_sequen      INTEGER,
          l_largura     INTEGER,
          l_ped_cli     CHAR(30)
   
   DEFINE l_den_item    LIKE fat_nf_item.des_item

   DEFINE lr_item       ARRAY[50] OF RECORD
          cod_item      CHAR(15),             
          den_item      CHAR(60)           
   END RECORD

   DEFINE lr_pedido     ARRAY[50] OF RECORD
          pedido        INTEGER,             
          sequenc       INTEGER,
          seq_it_nf     INTEGER          
   END RECORD
   
   LET l_ind = 1
   
   DECLARE cq_nf_item CURSOR FOR
    SELECT item, pedido, seq_item_pedido, seq_item_nf
      FROM fat_nf_item
     WHERE empresa = p_cod_empresa
       AND trans_nota_fiscal = m_num_transac
   
   FOREACH cq_nf_item INTO 
      lr_item[l_ind].cod_item, 
      lr_pedido[l_ind].pedido, 
      lr_pedido[l_ind].sequenc,
      lr_pedido[l_ind].seq_it_nf
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_nf_item')
         RETURN FALSE
      END IF
      
      SELECT tex_complementar
        INTO l_den_item
        FROM cliente_item
       WHERE cod_empresa = p_cod_empresa
         AND cod_cliente_matriz = m_cod_cliente
         AND cod_item_cliente = lr_item[l_ind].cod_item
      
      IF STATUS = 100 THEN
         LET l_den_item = NULL
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','cliente_item:cq_nf_item')
            RETURN FALSE
         END IF
      END IF
      
      IF l_den_item IS NULL THEN
         SELECT den_item INTO l_den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = lr_item[l_ind].cod_item
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','item:cq_nf_item')
            RETURN FALSE
         END IF
      END IF
      
      SELECT largura, num_pedido_cli
        INTO l_largura, l_ped_cli
        FROM item_bobina_885 
       WHERE cod_empresa = p_cod_empresa 
         AND num_pedido = lr_pedido[l_ind].pedido 
         AND num_sequencia = lr_pedido[l_ind].sequenc               

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item_bobina_885:cq_nf_item')
         RETURN FALSE
      END IF
      
      LET l_den_item = l_den_item CLIPPED, ' LARG.',l_largura USING '<<<<<<'
      LET l_den_item = l_den_item CLIPPED, ' OC ', l_ped_cli CLIPPED
      LET lr_item[l_ind].den_item = l_den_item CLIPPED
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 50 THEN
         LET p_msg = 'Limite de itens da nota ultrapassou o previsto'
         CALL log0030_mensagem(p_msg,'info')
         RETURN FALSE
      END IF
      
   END FOREACH
   
   LET p_qtd_linha =  l_ind - 1
     
   IF l_ind = 1 THEN
      LET p_msg = 'Nenhum item foi encontrado na NF ',m_num_nff
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   LET INT_FLAG = FALSE
   
   CALL SET_COUNT(l_ind - 1)
   
   INPUT ARRAY lr_item 
      WITHOUT DEFAULTS FROM sr_item.*   

      BEFORE ROW
         LET l_ind = ARR_CURR()
         LET s_ind = SCR_LINE()
      
      BEFORE FIELD den_item
         LET lr_item[l_ind].den_item = lr_item[l_ind].den_item CLIPPED
         
      AFTER FIELD den_item
      
         IF lr_item[l_ind].den_item IS NULL THEN
            IF l_ind <= p_qtd_linha THEN
               ERROR 'Campo com preenchimento obrigatório'
               NEXT FIELD den_item
            END IF
         END IF
        
   END INPUT
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   FOR l_ind = 1 TO p_qtd_linha
       UPDATE fat_nf_item
          SET des_item = lr_item[l_ind].den_item
        WHERE empresa = p_cod_empresa
          AND trans_nota_fiscal = m_num_transac
          AND pedido = lr_pedido[l_ind].pedido 
          AND seq_item_pedido = lr_pedido[l_ind].sequenc 

       IF STATUS <> 0 THEN
          CALL log003_err_sql('UPDATE','fat_nf_item:cq_nf_item')
          CALL log085_transacao("ROLLBACK")
          RETURN FALSE
       END IF       
       
       SELECT 1 FROM fat_nf_cliente_item
        WHERE empresa = p_cod_empresa
          AND trans_nota_fiscal = m_num_transac 
          AND seq_item_nf = lr_pedido[l_ind].seq_it_nf

       IF STATUS = 100 THEN
          INSERT INTO fat_nf_cliente_item
           VALUES(p_cod_empresa, 
                  m_num_transac,
                  lr_pedido[l_ind].seq_it_nf, 
                  lr_item[l_ind].cod_item,
                  lr_item[l_ind].den_item)
       ELSE
          IF STATUS = 0 THEN
             UPDATE fat_nf_cliente_item
                SET des_item_cliente = lr_item[l_ind].den_item
              WHERE empresa = p_cod_empresa
                AND trans_nota_fiscal = m_num_transac 
                AND seq_item_nf = lr_pedido[l_ind].seq_it_nf
          ELSE
             CALL log003_err_sql('SELECT','fat_nf_cliente_item:LENDO')
             CALL log085_transacao("ROLLBACK")
             RETURN FALSE
          END IF
       END IF       
          
       IF STATUS <> 0 THEN
          CALL log003_err_sql('UPDATE','fat_nf_cliente_item:gravando')
          CALL log085_transacao("ROLLBACK")
          RETURN FALSE
       END IF       
              
   END FOR
      
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#-----------------------------# 
FUNCTION pol1271_inc_nf_terc()#
#-----------------------------#
   
   DEFINE l_tem_nf      SMALLINT,
          l_num_transac INTEGER,
          l_ser_nf      LIKE nf_sup.ser_nf,
          l_ssr_nf      LIKE nf_sup.ssr_nf,
          l_especie     LIKE nf_sup.ies_especie_nf

   DEFINE lr_nota             RECORD
         cod_emp_benf         LIKE empresa.cod_empresa,
         cod_emp_vend         LIKE empresa.cod_empresa,
         trans_nota_fiscal    LIKE fat_nf_mestre.trans_nota_fiscal,
         cod_fornecedor       LIKE nf_sup.cod_fornecedor,
         num_romaneio         INTEGER,
         num_seq_pai          INTEGER,
         num_prog             CHAR(08),
         nf_com_erro          CHAR(01),
         den_erro             CHAR(30),
         ies_contag           CHAR(01),
         ies_insp             CHAR(01),
         ies_indus            CHAR(01)
   END RECORD
    
   IF p_cod_status <> '1' THEN
      LET p_msg = 'Opçao disponível somente\n para romaneio processado'
      CALL log0030_mensagem(p_msg,'exclamation')
      RETURN FALSE
   END IF
      
   LET l_tem_nf = FALSE
   
    SELECT DISTINCT num_nff
      INTO m_num_nff
      FROM ordem_montag_mest o,
           solicit_fat_885 f
     WHERE f.cod_empresa = p_cod_empresa
       AND f.num_solicit = p_num_solicit
       AND o.cod_empresa = f.cod_empresa
       AND o.num_om = f.num_om
       AND o.ies_sit_om = 'F'

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordem_montag_mest:num_nff')
         RETURN FALSE
      END IF       
            
     SELECT trans_nota_fiscal,
            serie_nota_fiscal,
            subserie_nf,
            espc_nota_fiscal 
       INTO l_num_transac,
            l_ser_nf,
            l_ssr_nf,
            l_especie
       FROM fat_nf_mestre 
      WHERE empresa = p_cod_empresa 
        AND nota_fiscal = m_num_nff
        AND cliente = m_cli_benef

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','fat_nf_mestre')
         RETURN FALSE
      END IF       
      
      SELECT COUNT(num_nf)
        INTO p_count
        FROM nf_sup
       WHERE cod_empresa = m_cod_emp_pv
         AND cod_fornecedor = m_fornec
         AND num_nf = m_num_nff
         AND ser_nf = l_ser_nf
         AND ssr_nf = l_ssr_nf
         AND ies_especie_nf = l_especie
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','nf_sup:cq_nff')
         RETURN FALSE
      END IF       
      
      IF p_count > 0 THEN
         LET p_msg = 'Já existe nota com essas \n características no SUP3760'
         CALL log0030_mensagem(p_msg, 'info')
         RETURN FALSE
      END IF
      
      LET lr_nota.cod_emp_benf = m_cod_emp_op
      LET lr_nota.cod_emp_vend = m_cod_emp_pv
      LET lr_nota.trans_nota_fiscal = l_num_transac
      LET lr_nota.cod_fornecedor = m_fornec
      LET lr_nota.num_romaneio = p_num_solicit
      LET lr_nota.num_seq_pai = p_num_sequencia
      LET lr_nota.num_prog = 'POL1271'
      LET lr_nota.nf_com_erro = 'N'
      LET lr_nota.ies_contag = 'N'
      LET lr_nota.ies_insp = 'N'
      LET lr_nota.ies_indus = 'S'
      
      CALL log085_transacao("BEGIN")

      LET p_msg = func022_gera_nota(lr_nota) 
  
      IF p_msg = 'OK' THEN
         CALL log085_transacao("COMMIT")
         LET p_msg = 'Inclusão de NF com sucesso.'
         CALL log0030_mensagem(p_msg, 'info')
         RETURN TRUE
      ELSE
        CALL log085_transacao("ROLLBACK")
        CALL log0030_mensagem(p_msg, 'info')
        RETURN FALSE
      END IF                  
   
END FUNCTION
   
      