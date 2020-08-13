#-------------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                             #
# PROGRAMA: pol0211                                                       #
# MODULOS.: pol0211 - LOG0010 - LOG0030 - LOG0050 - LOG0060               #
#           LOG0280 - LOG1300 - LOG1400 - LOG1500                         #
# OBJETIVO: ATUALIZA A TABELA PEDIDOS_QFP E PED_ITENS_QFP A PARTIR        #
#           DAS TABELAS QFPTRAN E PED_ITENS                               #
# AUTOR...: ANDREI DAGOBERTO STREIT                                       #
# DATA....: 04/07/2002                                                    #
# ## EM CASO DE ALTERACAO DESTA VERSAO ATUALIZAR TAMBEM O VDP1147E        #
# ## VERSAO ESPECIFICA PARA "IM"                                          #
#-------------------------------------------------------------------------#
# VERSAO COM A VERIFICACAO NA TABELA PAR_VDP_PADRAO - IES_QFP, E NA TABE- #
# LA QFP_CGC - NUM_CGC_DESTINO - Ramiro                                   #
#-------------------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE p_nom_arquivo          CHAR(100),
         p_msg                  CHAR(100),
         g_ies_ambiente         CHAR(01),
         p_ies_impressao        CHAR(001),
         p_comando              CHAR(080),
         p_caminho              CHAR(080),
         p_nom_tela             CHAR(080),
         p_help                 CHAR(080),
         p_pedido               CHAR(012),
         p_cancel               INTEGER,
         p_houve_msg_erro       SMALLINT
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_den_empresa          LIKE empresa.den_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_status               SMALLINT,
         p_last_row             SMALLINT,
         p_count                SMALLINT

 DEFINE p_versao  CHAR(18)        
         
END GLOBALS        
      
  DEFINE p_qtd_item             LIKE nf_item.qtd_item,
         p_dat_emissao          LIKE nf_mestre.dat_emissao,
         p_time                 CHAR(008),
         p_prz_entrega          LIKE ped_itens_qfp.prz_entrega,
         p_observacao           CHAR(31),
         p_des_obs              CHAR(30),
         p_cod_local_estoq      CHAR(10),
         p_ano                  CHAR(04),
         p_cod_cliente          CHAR(15),
         p_num_sequencia        DECIMAL(05,0),
         p_saldo                DECIMAL(15,3),
         p_qtd_solic_int        DECIMAL(12,0),
         p_qtd_solic_nova       DECIMAL(15,3),
         p_num_pedido           DECIMAL(06,0),
         p_num_ped_temp         DECIMAL(06,0),
         p_imprimir             CHAR(03),
         p_reg_lido             CHAR(03),
         p_qfptran_ant          CHAR(56),
         p_num_pedido_ant       DECIMAL(06,0),
         p_cod_item             CHAR(15),
         p_item_fornecedor      CHAR(30),     
         p_data_ant             DATE,
         p_seculo               CHAR(02),
         p_tot_registros        DECIMAL(03,0),
         p_zerados              DECIMAL(03,0),
         p_dia_semana           SMALLINT,
         p_ind                  SMALLINT,
         p_ind1                 SMALLINT,
         p_ies_cons             SMALLINT,
         p_existe               SMALLINT,
         p_houve_erro           SMALLINT,
         p_fator_conversao      DECIMAL(15,6),
         p_ies_firme            CHAR(01),
         m_itenf_cli            CHAR(07)
  
  DEFINE p_ped_itens         RECORD LIKE ped_itens.*
  
  DEFINE p_pedidos_qfp       RECORD LIKE pedidos_qfp.*
  
  DEFINE p_ped_itens_qfp     RECORD LIKE ped_itens_qfp.*
  
  DEFINE p_qfptran,
         p_qfptran_aux       RECORD LIKE qfptran.*
  DEFINE p_peditem_ant       RECORD
         qtd_solic_nova      DECIMAL(10,3),
         qtd_solic_aceita    DECIMAL(10,3)
                             END RECORD 
                                                  
  DEFINE qfptran_1           RECORD                           
                             num_cgc_montadora  CHAR(19),     
                             item_cliente       CHAR(30),     
                             prg_atual          CHAR(09),     
                             dat_prg_atual      DATE,         
                             prg_anterior       CHAR(09),     
                             dat_prg_anterior   DATE,         
                             item_fornecedor    CHAR(30),     
                             pedido_cmp         CHAR(12),     
                             local_entrega      CHAR(05),     
                             pedido             DECIMAL(06,0) 
                             END RECORD                       
                                                              
  DEFINE qfptran_2           RECORD                           
                             dat_ult_entrega    DATE,         
                             num_ult_nf         DECIMAL(06,0),
                             ser_ult_nf         CHAR(03),     
                             dat_ult_nf         DATE,         
                             qtd_ult_entrega    DECIMAL(12,3),
                             cod_freq_fornec    CHAR(03)      
                             END RECORD

  DEFINE p_tpol0211           RECORD
                             data             DATE,
                             dia_semana       SMALLINT,
                             semana_mes       SMALLINT
                             END RECORD

DEFINE  p_pedidos_edi_pe1     RECORD

cod_empresa          char(2),
num_pedido           decimal(6,0),
cod_fabr_dest        char(3),
identif_prog_atual   char(9),
dat_prog_atual       DATE,
identif_prog_ant     char(9),
dat_prog_anterior    DATE,
cod_item_cliente     char(30),
cod_item             char(30),
num_pedido_compra    char(12),
cod_local_destino    char(5),
nom_contato          char(11),
cod_unid_med         char(2),
qtd_casas_decimais   INTEGER,     
cod_tip_fornec       char(1)                  
END RECORD

  DEFINE  
          p_pedidos_edi_pe2     RECORD LIKE pedidos_edi_pe2.*,
          p_pedidos_edi_pe3     RECORD LIKE pedidos_edi_pe3.*,
          p_pedidos_edi_pe4     RECORD LIKE pedidos_edi_pe4.*,
          p_pedidos_edi_pe5     RECORD LIKE pedidos_edi_pe5.*,
          p_pedidos_edi_pe6     RECORD LIKE pedidos_edi_pe6.*,
          p_pedidos_edi_te1     RECORD LIKE pedidos_edi_te1.*

  DEFINE  p_trans_cliente         RECORD LIKE trans_cliente.*,
          p_clientes              RECORD LIKE clientes.*,
          p_cli_info_adic         RECORD LIKE cli_info_adic.*,
          p_empresa               RECORD LIKE empresa.*

  DEFINE  pa_edi_te1            ARRAY[500]
          OF RECORD
             den_texto          CHAR(120)
          END RECORD 

MAIN
  CALL log0180_conecta_usuario()
  LET p_versao = "POL0211-10.02.19" 
  WHENEVER ANY ERROR CONTINUE
  CALL log1400_isolation()
  
  DEFER INTERRUPT

  CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
  LET p_help = p_caminho 
  OPTIONS
    HELP FILE p_help

  CALL log001_acessa_usuario("ESPEC999","")
    RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0 THEN 
    CALL pol0211_controle()
  END IF
END MAIN

#---------------------------------------------------------------------#
 FUNCTION pol0211_controle()
#---------------------------------------------------------------------#
  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("pol0211") RETURNING p_nom_tela 
  OPEN WINDOW w_pol0211 AT 7,11 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND "Processar" "Processa variacao programacao e emite relatorio"
      HELP 0116
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","pol0211","CO") THEN 
         CALL pol0211_lista_relat()
         IF p_imprimir = "SIM" THEN 	
            CALL pol0211_qfptran_carrega_ped_itens_qfp()
            IF p_houve_erro = FALSE THEN 
               CALL log085_transacao("COMMIT")
               IF sqlca.sqlcode <> 0 THEN 
                  CALL log003_err_sql("INCLUSAO","PEDIDOS_QFP, PED_ITENS_QFP") 
                  CALL log085_transacao("ROLLBACK")
               ELSE 
                  # osvaldo 
                  CALL pol0211_grava_ped_itens_qfp_pe5()
                  CALL pol0211_corrige_ped_itens_qfp()
                  # osvaldo
                  CALL pol0211_ped_itens_qfp_verifica_ped_itens()
                  IF p_houve_erro = FALSE THEN 
                     CALL log085_transacao("COMMIT")
                     IF sqlca.sqlcode <> 0 THEN 
                        CALL log003_err_sql("ATUALIZA-7","PED_ITENS_QFP") 
                        CALL log085_transacao("ROLLBACK")
                     ELSE
                        CALL pol0211_ped_itens_qfp_verifica_nff() 
                        IF p_houve_erro = FALSE THEN 
                           CALL log085_transacao("COMMIT")
                           IF sqlca.sqlcode <> 0 THEN  
                              CALL log003_err_sql("ATUALIZA-7","PED_ITENS_QFP")
                              CALL log085_transacao("ROLLBACK")
                           ELSE
                              CALL pol0211_deleta_qfptran()
                              NEXT OPTION "Fim"
                           END IF
                        ELSE 
                           CALL log003_err_sql("ATUALIZA-8","PED_ITENS_QFP")
                           CALL log085_transacao("ROLLBACK")
                        END IF
                     END IF
                  ELSE 
                     CALL log003_err_sql("ATUALIZA-8","PED_ITENS_QFP")
                     CALL log085_transacao("ROLLBACK")
                  END IF
               END IF
            ELSE
               CALL log003_err_sql("INCLUSAO","PEDIDOS_QFP, PED_ITENS_QFP")
               CALL log085_transacao("ROLLBACK")
            END IF
         ELSE 
            NEXT OPTION "Fim"
         END IF
      ELSE
         NEXT OPTION "Fim"
      END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0211_sobre() 
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0211
END FUNCTION

#----------------------------------------------#
FUNCTION pol0211_qfptran_carrega_ped_itens_qfp()
#----------------------------------------------#
   DEFINE p_item                   CHAR(30)
   
   INITIALIZE p_msg TO NULL

   CALL pol0211_cria_tabelas_temp()
   CALL pol0211_limpa_tabelas()    
   CALL pol0211_insert_tpol0211()

   CALL log085_transacao("BEGIN")

   LET p_houve_erro = FALSE
   LET p_tot_registros = 0
   LET p_zerados       = 0

   INITIALIZE p_qfptran_ant, p_reg_lido TO NULL

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   ERROR " Processando a atualizacao da tabela ... "
   
   DECLARE cp_qfptran CURSOR WITH HOLD FOR
    SELECT qfptran.*
      FROM qfptran
    # ORDER BY qfp_tran_txt[1,62]

   FOREACH cp_qfptran INTO p_qfptran.*
      CASE p_qfptran.qfp_tran_txt[1,3]
      
         WHEN "ITP"
         
        LET qfptran_1.num_cgc_montadora   = "0",
                                               p_qfptran.qfp_tran_txt[26,27],".",
                                               p_qfptran.qfp_tran_txt[28,30],".",
                                               p_qfptran.qfp_tran_txt[31,33],"/",
                                               p_qfptran.qfp_tran_txt[34,37],"-",
                                               p_qfptran.qfp_tran_txt[38,39]
           
           LET m_itenf_cli = p_qfptran.qfp_tran_txt[54,60]
           
         WHEN "PE1"
            
              IF p_houve_msg_erro THEN
                 OUTPUT TO REPORT pol0211_relat(3)
              END IF

              INITIALIZE p_pedidos_edi_pe1.*, p_pedidos_edi_pe2.*,
                         p_pedidos_edi_pe3.*, p_pedidos_edi_pe4.*,
                         p_pedidos_edi_pe5.*, p_pedidos_edi_pe6.*,
                         p_pedidos_edi_te1.*, pa_edi_te1            TO NULL 

              LET p_item = p_qfptran.qfp_tran_txt[67,96] 
              DISPLAY p_item TO item 
              IF p_qfptran_ant IS NULL THEN
              ELSE 
                 IF p_reg_lido      = "PE2"     OR    
                    p_tot_registros = p_zerados THEN 
                    # LET p_ped_itens_qfp.prz_entrega    = TODAY	
                    LET p_ped_itens_qfp.qtd_solic_nova   = 0  
                    LET p_ped_itens_qfp.qtd_solic_aceita = 0

                    # GRAVA PED_ITENS_QFP PARA PEDIDOS SEM REG=PE3 #
                    #                  (CANCELAMENTO)              #
                    IF p_ped_itens_qfp.cod_empresa IS NOT NULL THEN 
                       CALL pol0211_qfptran_grava_ped_itens_qfp()
                    END IF
                 END IF
              END IF
              LET p_reg_lido       = "PE1"
              LET p_tot_registros  = 0
              LET p_zerados        = 0
              LET p_houve_msg_erro = FALSE

              INITIALIZE p_cod_local_estoq, qfptran_1.pedido, p_observacao,
                         p_tpol0211.semana_mes, p_dia_semana TO NULL
              #falta alterar
              LET p_qfptran_ant                 = p_qfptran.qfp_tran_txt[1,2]
              LET p_ped_itens_qfp.num_sequencia = 0
              LET qfptran_1.item_cliente      = p_qfptran.qfp_tran_txt[37,66]
              LET qfptran_1.prg_atual         = p_qfptran.qfp_tran_txt[7,15]
              IF p_qfptran.qfp_tran_txt[16,21] > 0 THEN 
                 IF p_qfptran.qfp_tran_txt[16,17] >= "00" AND 
                    p_qfptran.qfp_tran_txt[16,17] <= "50" THEN 
                    LET p_seculo = "20"
                 ELSE 
                    LET p_seculo = "19"
                 END IF  
                 LET p_ano                   = p_seculo,
                                               p_qfptran.qfp_tran_txt[16,17]
                 LET qfptran_1.dat_prg_atual = 
                     MDY(p_qfptran.qfp_tran_txt[18,19], 
                     p_qfptran.qfp_tran_txt[20,21], p_ano)
              ELSE 
                 LET qfptran_1.dat_prg_atual = 0
              END IF
              LET qfptran_1.prg_anterior      = p_qfptran.qfp_tran_txt[22,30]
              IF p_qfptran.qfp_tran_txt[31,36] > 0 THEN 
                 IF p_qfptran.qfp_tran_txt[31,32] >= "00" AND
                    p_qfptran.qfp_tran_txt[31,32] <= "50" THEN 
                    LET p_seculo = "20"
                 ELSE 
                    LET p_seculo = "19"
                 END IF  
                 LET p_ano                      = p_seculo, 
                                                  p_qfptran.qfp_tran_txt[31,32]
                 LET qfptran_1.dat_prg_anterior = 
                     MDY(p_qfptran.qfp_tran_txt[33,34], 
                     p_qfptran.qfp_tran_txt[35,36], p_ano)
              ELSE
                 LET qfptran_1.dat_prg_anterior = 0
              END IF
              LET qfptran_1.pedido_cmp = p_qfptran.qfp_tran_txt[97,106]
              
              LET p_ies_firme = 'N'
              
              INITIALIZE qfptran_1.item_fornecedor, p_item_fornecedor TO NULL

              IF p_qfptran.qfp_tran_txt[67,96] = " "   OR 
                 p_qfptran.qfp_tran_txt[67,96] IS NULL THEN 
              ELSE
                 CALL pol0211_verifica_item_fornecedor()
              END IF

              LET qfptran_1.local_entrega = p_qfptran.qfp_tran_txt[109,113]

              IF pol0211_verifica_cod_cliente() = FALSE THEN 
                 INITIALIZE p_qfptran_ant TO NULL
                 CALL pol0211_gera_tabela_edi_pe1(1)
                 CONTINUE FOREACH
              END IF

              IF pol0211_verifica_item() = FALSE THEN 
                 LET p_observacao = p_des_obs          #### aquioooooo
                 OUTPUT TO REPORT pol0211_relat(1)
                 INITIALIZE p_qfptran_ant TO NULL
                 CALL pol0211_gera_tabela_edi_pe1(1)
                 INITIALIZE p_observacao TO NULL
                 CONTINUE FOREACH
              END IF

              IF pol0211_verifica_num_pedido() = FALSE THEN 
                 OUTPUT TO REPORT pol0211_relat(1)
                 INITIALIZE p_qfptran_ant TO NULL
                 CALL pol0211_gera_tabela_edi_pe1(1)
                 CONTINUE FOREACH
              END IF

              IF pol0211_verifica_ped_itens_reserva_romaneio() = TRUE THEN 
                 LET p_observacao  = "PED.COM RESERVA/ROMANEIO ******"
                 OUTPUT TO REPORT pol0211_relat(1)
                 INITIALIZE p_observacao TO NULL
                 # solicitacao do Geraldo - Tupy - 17/08/95
                 # INITIALIZE p_qfptran_ant TO NULL
                 # CONTINUE FOREACH
              END IF

              CALL pol0211_insert_tpol0211_1()
              CALL pol0211_gera_tabela_edi_pe1(2)

         WHEN "PE2"
             LET p_reg_lido = "PE2"
             IF p_qfptran_ant IS NULL THEN 
                CALL pol0211_gera_tabela_edi_pe2(1)
                CONTINUE FOREACH
             END IF
          
             IF p_qfptran.qfp_tran_txt[4,9] > 0 THEN
                IF p_qfptran.qfp_tran_txt[4,5] >= "00" AND 
                   p_qfptran.qfp_tran_txt[4,5] <= "50" THEN
                   LET p_seculo = "20"
                ELSE 
                   LET p_seculo = "19"
                END IF  
                LET p_ano                     = p_seculo,
                                                p_qfptran.qfp_tran_txt[4,5]
                LET qfptran_2.dat_ult_entrega =
                    MDY(p_qfptran.qfp_tran_txt[6,7], 
                    p_qfptran.qfp_tran_txt[8,9], p_ano)
             ELSE 
                LET qfptran_2.dat_ult_entrega = TODAY
             END IF
             LET qfptran_2.num_ult_nf      = p_qfptran.qfp_tran_txt[10,15]
             LET qfptran_2.ser_ult_nf      = p_qfptran.qfp_tran_txt[16,19]
             IF p_qfptran.qfp_tran_txt[20,25] > 0 THEN 
                IF p_qfptran.qfp_tran_txt[20,21] >= "00" AND 
                   p_qfptran.qfp_tran_txt[20,21] <= "50" THEN 
                   LET p_seculo = "20"
                ELSE
                   LET p_seculo = "19"
                END IF  
                LET p_ano                = p_seculo, 
                                           p_qfptran.qfp_tran_txt[20,21]
                LET qfptran_2.dat_ult_nf = MDY(p_qfptran.qfp_tran_txt[22,23], 
                                           p_qfptran.qfp_tran_txt[24,25], p_ano)
             ELSE 
                LET qfptran_2.dat_ult_nf = TODAY
             END IF
             LET qfptran_2.qtd_ult_entrega = p_qfptran.qfp_tran_txt[26,37]/ 1000
             LET qfptran_2.cod_freq_fornec = p_qfptran.qfp_tran_txt[78,80]

             IF pol0211_verifica_frequencia() = FALSE THEN 
                LET p_observacao  = "FREQUENCIA INVALIDA "
                OUTPUT TO REPORT pol0211_relat(1)
                INITIALIZE p_qfptran_ant TO NULL
                CALL pol0211_gera_tabela_edi_pe2(1)
                CONTINUE FOREACH
             END IF
             
             #### GRAVA PEDIDOS_QFP
         
             LET p_ped_itens_qfp.cod_empresa  = p_cod_empresa              
             LET p_ped_itens_qfp.num_pedido   = qfptran_1.pedido
             LET p_ped_itens_qfp.cod_item     = p_cod_item #qfptran_1.item_fornecedor
             CALL pol0211_qfptran_grava_pedidos_qfp()
             CALL pol0211_gera_tabela_edi_pe2(2)

         WHEN "PE3"
             LET p_qfptran_aux.* = p_qfptran.*
             CALL pol0211_busca_informacoes_edi_pe5()
             IF p_qfptran_ant IS NULL THEN 
                CALL pol0211_gera_tabela_edi_pe3(1)
                OUTPUT TO REPORT pol0211_relat(2)
                CONTINUE FOREACH
             END IF
             LET p_reg_lido      = "PE3"
             CALL pol0211_gera_ped_itens_qfp()
             CALL pol0211_gera_tabela_edi_pe3(2)

         WHEN "PE4"
             LET p_reg_lido = "PE4"
             IF p_qfptran_ant IS NULL THEN 
                CALL pol0211_gera_tabela_edi_pe4(1)
                CONTINUE FOREACH
             END IF
             CALL pol0211_gera_tabela_edi_pe4(2)

         WHEN "PE5"
             LET p_reg_lido = "PE4"
             IF p_qfptran_ant IS NULL THEN 
                CALL pol0211_gera_tabela_edi_pe5(1)
                CONTINUE FOREACH
             END IF
             CALL pol0211_gera_tabela_edi_pe5(2)

         WHEN "PE6"
             LET p_reg_lido = "PE6"
             IF p_qfptran_ant IS NULL THEN 
                CALL pol0211_gera_tabela_edi_pe6(1)
                CONTINUE FOREACH
             END IF
             CALL pol0211_gera_tabela_edi_pe6(2)

         WHEN "TE1"
             LET p_reg_lido = "TE1"
             IF p_qfptran_ant IS NULL THEN 
                CALL pol0211_gera_tabela_edi_te1(1)
                CONTINUE FOREACH
             END IF
             CALL pol0211_gera_tabela_edi_te1(2)

      END CASE
   END FOREACH

   IF p_houve_msg_erro THEN
      OUTPUT TO REPORT pol0211_relat(3)
   END IF

   FINISH REPORT pol0211_relat
   IF p_ies_impressao = "S" THEN
   #  CALL log0030_mensagem("Relatorio impresso com sucesso. ","info")
      MESSAGE "Relatorio Impresso com Sucesso" ATTRIBUTE(REVERSE)
   ELSE
      LET p_msg = "Relatorio Gravado no Arquivo ", p_nom_arquivo CLIPPED
   #  CALL log0030_mensagem(p_msg,"info")
      MESSAGE p_msg ATTRIBUTE(REVERSE)
   END IF
   ERROR "Fim de Processamento"

END FUNCTION

#------------------------------#
FUNCTION pol0211_limpa_tabelas()
#------------------------------#
  DELETE from ped_itens_qfp_pe5
  DELETE from ped_itens_qfp_pe512
  DELETE from ped_itens_qfp
  DELETE from ped_itens_qfp_512
  DELETE from pedidos_qfp
  DELETE from pedidos_edi_pe1
  DELETE from pedidos_edi_pe2
  DELETE from pedidos_edi_pe3
  DELETE from pedidos_edi_pe4
  DELETE from pedidos_edi_pe5
  DELETE from pedidos_edi_pe6
  DELETE from pedidos_edi_te1
END FUNCTION
#----------------------------------#
FUNCTION pol0211_cria_tabelas_temp()
#----------------------------------#
   CREATE TEMP TABLE tpol0211
     (data          DATE,
      dia_semana    SMALLINT,
      semana_mes    SMALLINT)

   CREATE INDEX ix_tpol0211 ON tpol0211 (data)
 
   CREATE TEMP TABLE tpol0211_1
     (num_pedido    DECIMAL(6,0))

   CREATE INDEX ix_tpol0211_1 ON tpol0211_1 (num_pedido)

#  osvaldo
   CREATE TEMP TABLE tpol0211_2
      (num_pedido      DEC(6,0),
       num_sequencia   SMALLINT,
       dat_abertura    DATE,
       ies_programacao DEC(2,0))

   CREATE INDEX ix_tpol0211_2 ON tpol0211_2 (num_pedido, num_sequencia)
#  osvaldo

END FUNCTION

#--------------------------------#
FUNCTION pol0211_insert_tpol0211()
#--------------------------------#
   LET p_tpol0211.data       = MDY(MONTH(today),01,YEAR(today))
   LET p_tpol0211.dia_semana = WEEKDAY(p_tpol0211.data)
   LET p_tpol0211.semana_mes = 1
   LET p_data_ant = p_tpol0211.data

   FOR p_ind = 1 TO 364
      LET p_tpol0211.data       = p_tpol0211.data + 1
      LET p_tpol0211.dia_semana = WEEKDAY(p_tpol0211.data)

      IF MONTH(p_tpol0211.data) <> MONTH(p_data_ant) THEN
         LET p_tpol0211.semana_mes = 1
         LET p_data_ant           = p_tpol0211.data
      ELSE 
         IF p_tpol0211.dia_semana = 0 THEN 
            LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
         ELSE
            LET p_tpol0211.semana_mes = p_tpol0211.semana_mes 
         END IF
      END IF

      INSERT INTO tpol0211 VALUES (p_tpol0211.*)
      IF sqlca.sqlcode <> 0 THEN 
         IF sqlca.sqlcode <> -239 THEN 
            CALL log003_err_sql("INCLUSAO","Tpol0211")
         END IF
      END IF
   END FOR
END FUNCTION

#-----------------------------------------#
FUNCTION pol0211_verifica_item_fornecedor()
#-----------------------------------------#
   LET p_item_fornecedor = p_qfptran.qfp_tran_txt[67,96]
   LET p_ind1 = 0

   FOR p_ind1 = 1 TO 30
      IF p_item_fornecedor[p_ind1,p_ind1] <> " " THEN 
         IF p_item_fornecedor[p_ind1,p_ind1] = "." THEN
         ELSE 
            LET qfptran_1.item_fornecedor = qfptran_1.item_fornecedor CLIPPED, 
                                            p_item_fornecedor[p_ind1,p_ind1]
         END IF
      END IF
   END FOR
END FUNCTION

#------------------------------#
FUNCTION pol0211_verifica_item()
#------------------------------#

   DEFINE p_num_ped    LIKE ped_itens.num_pedido,
          p_num_sequen LIKE ped_itens.num_sequencia

#  aqui
   LET p_pedido = " "
   FOR p_ind = 1 TO 10
      IF qfptran_1.pedido_cmp[p_ind,p_ind] >= "0" AND
         qfptran_1.pedido_cmp[p_ind,p_ind] <= "9" THEN 
         LET p_pedido = p_pedido CLIPPED, qfptran_1.pedido_cmp[p_ind,p_ind]
      END IF
   END FOR

   SELECT COUNT(*)
      INTO p_count 
   FROM cliente_item
   WHERE cod_item_cliente = qfptran_1.item_cliente      
     AND cod_cliente_matriz = p_cod_cliente
   IF p_count = 0 THEN
      LET p_des_obs = 'ITEM NAO CADASTRADO'
      RETURN FALSE
   END IF

   IF p_count = 1 THEN
      SELECT cod_item 
         INTO p_cod_item
      FROM cliente_item
      WHERE cod_item_cliente = qfptran_1.item_cliente      
        AND cod_cliente_matriz = p_cod_cliente
      IF SQLCA.SQLCODE <> 0 THEN
         LET p_des_obs = 'ITEM NAO CADASTRADO'
         RETURN FALSE
      END IF
   ELSE
      LET p_pedido = " "
      FOR p_ind = 1 TO 10
         IF qfptran_1.pedido_cmp[p_ind,p_ind] <> " " THEN 
            LET p_pedido = p_pedido CLIPPED, qfptran_1.pedido_cmp[p_ind,p_ind]
         END IF
      END FOR

      SELECT num_pedido
         INTO p_num_ped   
      FROM pedidos
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido_cli[1,10]  = p_pedido
        AND cod_cliente = p_cod_cliente
        AND ies_sit_pedido <> '9'
        
      IF SQLCA.SQLCODE = 0 THEN
         SELECT MAX(num_sequencia)
            INTO p_num_sequen
         FROM ped_itens    
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido = p_num_ped
         IF SQLCA.SQLCODE = 0 THEN
            SELECT cod_item           
               INTO p_cod_item       
            FROM ped_itens    
            WHERE cod_empresa = p_cod_empresa
              AND num_pedido = p_num_ped
              AND num_sequencia = p_num_sequen
            IF SQLCA.SQLCODE <> 0 THEN
               RETURN FALSE
            ELSE
              LET p_count = 0
              SELECT COUNT(*)
                INTO p_count 
                FROM ped_itens 
               WHERE cod_empresa = p_cod_empresa
                 AND num_pedido = p_num_ped
                 AND cod_item = p_cod_item
              IF p_count = 0 THEN 
                 LET p_des_obs = 'ITEM DIVERGE DO CADASTRADO NO PEDIDO'
                 RETURN FALSE
              END IF    
            END IF
         ELSE 
            RETURN FALSE
         END IF
      ELSE 
         LET p_des_obs = 'NAO EXISTE PEDIDO PARA O ITEM'
         RETURN FALSE
      END IF
   END IF
#  aqui
     
   SELECT cod_local_estoq
      INTO p_cod_local_estoq
   FROM item
   WHERE cod_empresa = p_cod_empresa
     AND cod_item = p_cod_item

   IF SQLCA.SQLCODE = 0 THEN 
      RETURN TRUE
   ELSE 
      LET p_des_obs = 'LOC DE EST. DO ITEM NAO CAD'
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------------#
FUNCTION pol0211_verifica_cod_cliente()
#-------------------------------------#
{  SELECT cgc_entrega
     INTO qfptran_1.num_cgc_montadora
     FROM qfp_cgc
    WHERE cod_empresa    = p_cod_empresa
      AND cgc_matriz     = qfptran_1.num_cgc_montadora
      AND cod_local_entr = qfptran_1.local_entrega

   IF sqlca.sqlcode = 0 THEN 
      LET p_observacao = "CGC SUBST. "
      LET p_observacao = p_observacao CLIPPED, qfptran_1.num_cgc_montadora
        OUTPUT TO REPORT pol0211_relat(1)
   END IF

   INITIALIZE p_cod_cliente TO NULL

   DECLARE cq_cliente CURSOR WITH HOLD FOR
    SELECT UNIQUE cod_cliente
      INTO p_cod_cliente
      FROM clientes
     WHERE num_cgc_cpf = qfptran_1.num_cgc_montadora

   OPEN cq_cliente
   FETCH cq_cliente
   IF sqlca.sqlcode = 0 THEN 
      CLOSE cq_cliente
      RETURN TRUE
   ELSE 
      CLOSE cq_cliente
      LET p_observacao             = "PEDIDO COM CLIENTE NAO CADASTRADO "
      OUTPUT TO REPORT pol0211_relat(1)
      RETURN FALSE
   END IF   }  

   {   
   IF qfptran_1.pedido_cmp[1,4] = 'QEST' THEN
      LET p_cod_cliente = "849" 
   ELSE
      IF qfptran_1.pedido_cmp[1,4] = 'QAPD' OR 
         qfptran_1.pedido_cmp[1,4] = 'QHPD' THEN
         LET p_cod_cliente = "061064911001734" 
      ELSE     
         IF qfptran_1.pedido_cmp[1,2] = 'PA' OR 
            qfptran_1.pedido_cmp[1,2] = 'PH' THEN
            LET p_cod_cliente = "1463" 
         ELSE
            LET p_cod_cliente = "1"
         END IF
      END IF    
   END IF    
   }

   IF m_itenf_cli = 'Q7586S0' THEN
      LET p_cod_cliente = "1"
   ELSE
      IF m_itenf_cli = 'Q7586S1' THEN
         LET p_cod_cliente = "1463"
      ELSE
         IF m_itenf_cli = 'Q7586S6' THEN
            LET p_cod_cliente = "061064911001734"
         ELSE
         
         END IF
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION


#------------------------------------#
FUNCTION pol0211_verifica_num_pedido()
#------------------------------------#
   INITIALIZE qfptran_1.pedido TO NULL
   
   LET p_existe = FALSE

   LET p_pedido = " "
   FOR p_ind = 1 TO 10
      IF qfptran_1.pedido_cmp[p_ind,p_ind] <> " " THEN 
         LET p_pedido = p_pedido CLIPPED, qfptran_1.pedido_cmp[p_ind,p_ind]
      END IF
   END FOR

      DECLARE cp_pedidos CURSOR WITH HOLD FOR
       SELECT num_pedido
         FROM pedidos
        WHERE cod_empresa           = p_cod_empresa
          AND cod_cliente           = p_cod_cliente
          AND ies_sit_pedido       IN ("N", "C", "F", "A")
          AND num_pedido_cli[1,10]  = p_pedido
        ORDER BY num_pedido
        
      FOREACH cp_pedidos INTO qfptran_1.pedido
         SELECT UNIQUE(cod_item)
          FROM ped_itens            
         WHERE cod_empresa = p_cod_empresa   
           AND num_pedido  = qfptran_1.pedido
           AND cod_item    = p_cod_item
        
         IF sqlca.sqlcode = 0 THEN 
            LET p_existe = TRUE
            LET p_observacao = "ITEM NAO CADASTRADO PARA O PEDIDO"
            EXIT FOREACH
          END IF
      END FOREACH

   IF p_existe = TRUE THEN 
      RETURN TRUE 
   ELSE 
      LET qfptran_1.pedido = 0
      LET p_observacao = "PEDIDO NAO CADASTR. P/ ESTE CGC"
      RETURN FALSE
   END IF
END FUNCTION

#-----------------------------------#
FUNCTION pol0211_gera_ped_itens_qfp()
#-----------------------------------#
   DEFINE l_ano  CHAR(02),
          l_mes  CHAR(02),
          l_dia  CHAR(02)

   # falta alterar  
   IF p_qfptran.qfp_tran_txt{[60,60]} = "1" OR 
      p_qfptran.qfp_tran_txt{[60,60]} = "2" THEN
  # falta alterar     
      IF p_qfptran.qfp_tran_txt[12,20] IS NULL OR 
         p_qfptran.qfp_tran_txt[12,20] = " "   THEN
      ELSE 
         LET p_tot_registros = p_tot_registros + 1
         IF p_qfptran.qfp_tran_txt[12,20] > 0 THEN 
            #LET p_ped_itens_qfp.prz_entrega      = TODAY
            LET p_ped_itens_qfp.qtd_solic_nova   =  
                p_qfptran.qfp_tran_txt[12,20]
            LET p_ped_itens_qfp.qtd_solic_aceita =
                p_qfptran.qfp_tran_txt[12,20]
            CALL pol0211_qfptran_verifica_frequencia()
            CALL pol0211_qfptran_grava_ped_itens_qfp()
         ELSE 
            LET p_zerados  = p_zerados + 1
         END IF
      END IF
   ELSE 
      IF p_qfptran.qfp_tran_txt[12,20] IS NULL OR 
         p_qfptran.qfp_tran_txt[12,20] = " "   THEN
      ELSE 
         IF p_qfptran.qfp_tran_txt[4,9] = 999999 OR 
            p_qfptran.qfp_tran_txt[6,7] = 99     OR 
            p_qfptran.qfp_tran_txt[8,9] = 99     THEN 
            LET p_observacao = "DATA INVALIDA *****************"
            OUTPUT TO REPORT pol0211_relat(1)
         ELSE 
            LET p_tot_registros = p_tot_registros + 1
            IF p_qfptran.qfp_tran_txt[12,20] > 0 THEN 
               LET p_ped_itens_qfp.qtd_solic_nova   = 
                   p_qfptran.qfp_tran_txt[12,20]
               LET p_ped_itens_qfp.qtd_solic_aceita = 
                   p_qfptran.qfp_tran_txt[12,20]
               IF p_qfptran.qfp_tran_txt[8,9] > 0 THEN 
               ELSE 
                  LET p_qfptran.qfp_tran_txt[8,9] = 01
               END IF
               IF p_qfptran.qfp_tran_txt[4,5] >= "00" AND 
                  p_qfptran.qfp_tran_txt[4,5] <= "50" THEN 
                  LET p_seculo = "20"
               ELSE 
                  LET p_seculo = "19"
               END IF  
               LET p_ano = p_seculo, p_qfptran.qfp_tran_txt[4,5]
               LET p_ped_itens_qfp.prz_entrega = 
                                            MDY(p_qfptran.qfp_tran_txt[6,7],
                                           p_qfptran.qfp_tran_txt[8,9], p_ano)
               CALL pol0211_qfptran_verifica_frequencia()
               CALL pol0211_qfptran_grava_ped_itens_qfp()
            ELSE 
               LET p_zerados  = p_zerados + 1
            END IF
         END IF
      END IF
      IF p_qfptran.qfp_tran_txt[29,37] IS NULL OR 
         p_qfptran.qfp_tran_txt[29,37] = " "   THEN
      ELSE 
         IF p_qfptran.qfp_tran_txt[21,26] = 999999 OR 
            p_qfptran.qfp_tran_txt[23,24] = 99     OR 
            p_qfptran.qfp_tran_txt[25,26] = 99     THEN 
            LET p_observacao = "DATA INVALIDA *****************"
            OUTPUT TO REPORT pol0211_relat(1)
         ELSE 
            LET p_tot_registros = p_tot_registros + 1
            IF p_qfptran.qfp_tran_txt[29,37] > 0 THEN 
               LET p_ped_itens_qfp.qtd_solic_nova   = 
                   p_qfptran.qfp_tran_txt[29,37]
               LET p_ped_itens_qfp.qtd_solic_aceita = 
                   p_qfptran.qfp_tran_txt[29,37]
               IF p_qfptran.qfp_tran_txt[25,26] > 0 THEN 
               ELSE 
                  LET p_qfptran.qfp_tran_txt[25,26] = 01
               END IF
               IF p_qfptran.qfp_tran_txt[21,22] >= "00" AND 
                  p_qfptran.qfp_tran_txt[21,22] <= "50" THEN
                  LET p_seculo = "20"
               ELSE 
                  LET p_seculo = "19"
               END IF  
               LET p_ano = p_seculo, p_qfptran.qfp_tran_txt[21,22]
               LET p_ped_itens_qfp.prz_entrega =
                                      MDY(p_qfptran.qfp_tran_txt[23,24],
                                          p_qfptran.qfp_tran_txt[25,26], p_ano)
               CALL pol0211_qfptran_verifica_frequencia()
               CALL pol0211_qfptran_grava_ped_itens_qfp()
            ELSE 
               LET p_zerados  = p_zerados + 1
            END IF
         END IF
      END IF
      IF p_qfptran.qfp_tran_txt[46,54] IS NULL OR 
         p_qfptran.qfp_tran_txt[46,54] = " "   THEN
      ELSE 
         IF p_qfptran.qfp_tran_txt[38,43]  = 999999 OR 
            p_qfptran.qfp_tran_txt[40,41]  = 99     OR 
            p_qfptran.qfp_tran_txt[42,43] = 99     THEN 
            LET p_observacao = "DATA INVALIDA *****************"
            OUTPUT TO REPORT pol0211_relat(1)
         ELSE 
            LET p_tot_registros = p_tot_registros + 1
            IF p_qfptran.qfp_tran_txt[46,54] > 0 THEN 
               LET p_ped_itens_qfp.qtd_solic_nova   = 
                   p_qfptran.qfp_tran_txt[46,54]
               LET p_ped_itens_qfp.qtd_solic_aceita = 
                   p_qfptran.qfp_tran_txt[46,54]

               IF p_qfptran.qfp_tran_txt[42,43] > 0 THEN 
               ELSE 
                  LET p_qfptran.qfp_tran_txt[42,43] = 01
               END IF

##               IF p_qfptran.qfp_tran_txt[38,39] >= "00" AND 
##                  p_qfptran.qfp_tran_txt[39,39] <= "50" THEN 
               LET p_seculo = "20"
##               ELSE 
##                  LET p_seculo = "19"
##               END IF  
               LET l_ano = p_qfptran.qfp_tran_txt[38,39]
               LET p_ano = p_seculo, l_ano
               LET l_dia = p_qfptran.qfp_tran_txt[42,43]
               LET l_mes = p_qfptran.qfp_tran_txt[40,41]
               LET p_ped_itens_qfp.prz_entrega =
                                     MDY(p_qfptran.qfp_tran_txt[40,41],
                                         p_qfptran.qfp_tran_txt[42,43], p_ano)
               CALL pol0211_qfptran_verifica_frequencia()
               CALL pol0211_qfptran_grava_ped_itens_qfp()
            ELSE 
               LET p_zerados  = p_zerados + 1
            END IF
         END IF
      END IF
      IF p_qfptran.qfp_tran_txt[63,71] IS NULL OR 
         p_qfptran.qfp_tran_txt[63,71] = " "   THEN
      ELSE
         IF p_qfptran.qfp_tran_txt[55,60] = 999999 OR 
            p_qfptran.qfp_tran_txt[57,58] = 99     OR 
            p_qfptran.qfp_tran_txt[59,60] = 99     THEN 
            LET p_observacao = "DATA INVALIDA *****************"
            OUTPUT TO REPORT pol0211_relat(1)
         ELSE 
            LET p_tot_registros = p_tot_registros + 1
            IF p_qfptran.qfp_tran_txt[63,71] > 0 THEN 
               LET p_ped_itens_qfp.qtd_solic_nova   = 
                   p_qfptran.qfp_tran_txt[63,71]
               LET p_ped_itens_qfp.qtd_solic_aceita = 
                   p_qfptran.qfp_tran_txt[63,71]
               IF p_qfptran.qfp_tran_txt[59,60] > 0 THEN 
               ELSE 
                  LET p_qfptran.qfp_tran_txt[59,60] = 01
               END IF
               IF p_qfptran.qfp_tran_txt[55,56] >= "00" AND 
                  p_qfptran.qfp_tran_txt[55,56] <= "50" THEN 
                  LET p_seculo = "20"
               ELSE 
                  LET p_seculo = "19"
               END IF  
               LET p_ano = p_seculo, p_qfptran.qfp_tran_txt[55,56]
               LET p_ped_itens_qfp.prz_entrega = 
                                   MDY(p_qfptran.qfp_tran_txt[57,58],
                                       p_qfptran.qfp_tran_txt[59,60], p_ano)
	       CALL pol0211_qfptran_verifica_frequencia()
               CALL pol0211_qfptran_grava_ped_itens_qfp()
            ELSE 
               LET p_zerados  = p_zerados + 1
            END IF
         END IF
      END IF
      IF p_qfptran.qfp_tran_txt[80,88] IS NULL OR 
         p_qfptran.qfp_tran_txt[80,88] = " "   THEN
      ELSE 
         IF p_qfptran.qfp_tran_txt[72,77] = 999999 OR 
            p_qfptran.qfp_tran_txt[74,75] = 99     OR 
            p_qfptran.qfp_tran_txt[76,77] = 99     THEN 
            LET p_observacao = "DATA INVALIDA *****************"
            OUTPUT TO REPORT pol0211_relat(1)
         ELSE 
            LET p_tot_registros = p_tot_registros + 1
            IF p_qfptran.qfp_tran_txt[80,88] > 0 THEN 
               LET p_ped_itens_qfp.qtd_solic_nova   = 
                   p_qfptran.qfp_tran_txt[80,88]
               LET p_ped_itens_qfp.qtd_solic_aceita = 
                   p_qfptran.qfp_tran_txt[80,88]
               IF p_qfptran.qfp_tran_txt[76,77] > 0 THEN 
               ELSE 
                  LET p_qfptran.qfp_tran_txt[76,77] = 01
               END IF
               IF p_qfptran.qfp_tran_txt[72,73] >= "00" AND 
                  p_qfptran.qfp_tran_txt[72,73] <= "50" THEN 
                  LET p_seculo = "20"
               ELSE 
                  LET p_seculo = "19"
               END IF  
               LET p_ano = p_seculo, p_qfptran.qfp_tran_txt[72,73]
               LET p_ped_itens_qfp.prz_entrega = 
                                   MDY(p_qfptran.qfp_tran_txt[74,75],
                                       p_qfptran.qfp_tran_txt[76,77], p_ano)
               CALL pol0211_qfptran_verifica_frequencia()
               CALL pol0211_qfptran_grava_ped_itens_qfp()
            ELSE 
               LET p_zerados  = p_zerados + 1
            END IF
         END IF
     END IF
     IF p_qfptran.qfp_tran_txt[97,105] IS NULL OR 
        p_qfptran.qfp_tran_txt[97,105] = " "   THEN
     ELSE 
        IF p_qfptran.qfp_tran_txt[89,94] = 999999 OR 
           p_qfptran.qfp_tran_txt[91,92] = 99     OR 
           p_qfptran.qfp_tran_txt[93,94] = 99     THEN 
           LET p_observacao = "DATA INVALIDA *****************"
           OUTPUT TO REPORT pol0211_relat(1)
        ELSE 
           LET p_tot_registros = p_tot_registros + 1
           IF p_qfptran.qfp_tran_txt[97,105] > 0 THEN 
              LET p_ped_itens_qfp.qtd_solic_nova   = 
                  p_qfptran.qfp_tran_txt[97,105]
              LET p_ped_itens_qfp.qtd_solic_aceita = 
                  p_qfptran.qfp_tran_txt[97,105]
              IF p_qfptran.qfp_tran_txt[93,94] > 0 THEN 
              ELSE 
                 LET p_qfptran.qfp_tran_txt[93,94] = 01
              END IF
              IF p_qfptran.qfp_tran_txt[89,90] >= "00" AND 
                 p_qfptran.qfp_tran_txt[89,90] <= "50" THEN
                 LET p_seculo = "20"
              ELSE 
                 LET p_seculo = "19"
              END IF  
              LET p_ano = p_seculo, p_qfptran.qfp_tran_txt[89,90]
              LET p_ped_itens_qfp.prz_entrega = 
                                  MDY(p_qfptran.qfp_tran_txt[91,92],
                                      p_qfptran.qfp_tran_txt[93,94], p_ano)
              CALL pol0211_qfptran_verifica_frequencia()
              CALL pol0211_qfptran_grava_ped_itens_qfp()
           ELSE 
              LET p_zerados  = p_zerados + 1
           END IF
        END IF
     END IF
     IF p_qfptran.qfp_tran_txt[114,122] IS NULL OR 
        p_qfptran.qfp_tran_txt[114,122] = " "   THEN
     ELSE 
        IF p_qfptran.qfp_tran_txt[106,111] = 999999 OR
           p_qfptran.qfp_tran_txt[108,109] = 99     OR 
           p_qfptran.qfp_tran_txt[110,111] = 99     THEN
           LET p_observacao = "DATA INVALIDA *****************"
           OUTPUT TO REPORT pol0211_relat(1)
        ELSE 
           LET p_tot_registros = p_tot_registros + 1
           IF p_qfptran.qfp_tran_txt[114,122] > 0 THEN 
              LET p_ped_itens_qfp.qtd_solic_nova   = 
                  p_qfptran.qfp_tran_txt[114,122]
              LET p_ped_itens_qfp.qtd_solic_aceita = 
                  p_qfptran.qfp_tran_txt[114,122]
              IF p_qfptran.qfp_tran_txt[110,111] > 0 THEN 
              ELSE 
                 LET p_qfptran.qfp_tran_txt[110,111] = 01
              END IF
              IF p_qfptran.qfp_tran_txt[106,107] >= "00" AND 
                 p_qfptran.qfp_tran_txt[106,107] <= "50" THEN
                 LET p_seculo = "20"
              ELSE 
                 LET p_seculo = "19"
              END IF  
              LET p_ano = p_seculo, p_qfptran.qfp_tran_txt[106,107]
              LET p_ped_itens_qfp.prz_entrega = 
                                  MDY(p_qfptran.qfp_tran_txt[108,109],
                                      p_qfptran.qfp_tran_txt[110,111], p_ano)
              CALL pol0211_qfptran_verifica_frequencia()
              CALL pol0211_qfptran_grava_ped_itens_qfp()
           ELSE 
              LET p_zerados  = p_zerados + 1
           END IF
        END IF
     END IF
  END IF
END FUNCTION 


#----------------------------------------------------#
FUNCTION pol0211_verifica_ped_itens_reserva_romaneio()
#----------------------------------------------------#
   DEFINE p_contador       SMALLINT

   SELECT COUNT(*)
     INTO p_contador
     FROM ped_itens
    WHERE ped_itens.cod_empresa = p_cod_empresa
      AND ped_itens.num_pedido  = qfptran_1.pedido
      AND (ped_itens.qtd_pecas_reserv  > 0
       OR ped_itens.qtd_pecas_romaneio > 0)
   IF p_contador = 0 THEN 
      RETURN FALSE
   ELSE 
      RETURN TRUE
   END IF
END FUNCTION


#----------------------------------#
FUNCTION pol0211_insert_tpol0211_1()
#----------------------------------#
# insert temp - pedidos com programacao, para desconto das NFF em transito.

   LET p_num_ped_temp = qfptran_1.pedido

   IF pol0211_verifica_tpol0211_1() = FALSE THEN 
      INSERT INTO tpol0211_1 VALUES (qfptran_1.pedido)
      IF sqlca.sqlcode <> 0 THEN 
         IF sqlca.sqlcode <> -239 THEN 
            CALL log003_err_sql("INCLUSAO","Tpol0211_1")
         END IF
      END IF
   END IF
END FUNCTION

#------------------------------------#
FUNCTION pol0211_verifica_frequencia()
#------------------------------------#
  IF   qfptran_2.cod_freq_fornec = "000"
    OR qfptran_2.cod_freq_fornec = " "
    OR qfptran_2.cod_freq_fornec = "10"
    OR qfptran_2.cod_freq_fornec = "11"
    OR qfptran_2.cod_freq_fornec = "20"
    OR qfptran_2.cod_freq_fornec = "21"
    OR qfptran_2.cod_freq_fornec = "22"
    OR qfptran_2.cod_freq_fornec = "23"
    OR qfptran_2.cod_freq_fornec = "24"
    OR qfptran_2.cod_freq_fornec = "25"
    OR qfptran_2.cod_freq_fornec = "26"
    OR qfptran_2.cod_freq_fornec = "27"
    OR qfptran_2.cod_freq_fornec = "28"
    OR qfptran_2.cod_freq_fornec = "29"
    OR qfptran_2.cod_freq_fornec = "31"
    OR qfptran_2.cod_freq_fornec = "32"
    OR qfptran_2.cod_freq_fornec = "40"
    OR qfptran_2.cod_freq_fornec = "41"
    OR qfptran_2.cod_freq_fornec = "42"
    OR qfptran_2.cod_freq_fornec = "43"
    OR qfptran_2.cod_freq_fornec = "44"
    OR qfptran_2.cod_freq_fornec = "50"
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION


#--------------------------------------------#
FUNCTION pol0211_qfptran_verifica_frequencia()
#--------------------------------------------#
   IF WEEKDAY(p_ped_itens_qfp.prz_entrega) = 6 THEN 
      LET p_ped_itens_qfp.prz_entrega = p_ped_itens_qfp.prz_entrega + 2
   END IF
   IF WEEKDAY(p_ped_itens_qfp.prz_entrega) = 0 THEN 
      LET p_ped_itens_qfp.prz_entrega = p_ped_itens_qfp.prz_entrega + 1
   END IF

   IF qfptran_2.cod_freq_fornec = "000" OR 
      qfptran_2.cod_freq_fornec = " "   OR 
      qfptran_2.cod_freq_fornec = "31"  OR 
      qfptran_2.cod_freq_fornec = "32"  THEN 
      RETURN
   END IF
   IF qfptran_2.cod_freq_fornec = "10" OR 
      qfptran_2.cod_freq_fornec = "50" THEN 
      RETURN
      #  LET p_dia_semana = 0
      #  Considerar o prz_entrega a data do qfptran.
   END IF

   IF qfptran_2.cod_freq_fornec = "20" OR
      qfptran_2.cod_freq_fornec = "21" THEN 
      LET p_dia_semana = 1
      CALL pol0211_frequencia_20_a_25()
   END IF
   IF qfptran_2.cod_freq_fornec = "22" THEN 
      LET p_dia_semana = 2
      CALL pol0211_frequencia_20_a_25()
   END IF
   IF qfptran_2.cod_freq_fornec = "23" THEN 
      LET p_dia_semana = 3
      CALL pol0211_frequencia_20_a_25()
   END IF
   IF qfptran_2.cod_freq_fornec = "24" THEN 
      LET p_dia_semana = 4
      CALL pol0211_frequencia_20_a_25()
   END IF
   IF qfptran_2.cod_freq_fornec = "25" THEN 
      LET p_dia_semana = 5
      CALL pol0211_frequencia_20_a_25()
   END IF

   LET p_saldo          = 0
   LET p_qtd_solic_nova = p_ped_itens_qfp.qtd_solic_nova
   LET p_prz_entrega    = p_ped_itens_qfp.prz_entrega

   IF qfptran_2.cod_freq_fornec = "11" THEN 
      LET p_qtd_solic_int = p_ped_itens_qfp.qtd_solic_nova / 5
      LET p_ped_itens_qfp.qtd_solic_nova   = p_qtd_solic_int
      LET p_ped_itens_qfp.qtd_solic_aceita = p_qtd_solic_int
      LET p_dia_semana = 1
      CALL pol0211_frequencia_11()
      LET p_saldo      = p_saldo + p_ped_itens_qfp.qtd_solic_nova 
      LET p_dia_semana = 2
      CALL pol0211_frequencia_11()
      LET p_saldo      = p_saldo + p_ped_itens_qfp.qtd_solic_nova 
      LET p_dia_semana = 3
      CALL pol0211_frequencia_11()
      LET p_saldo      = p_saldo + p_ped_itens_qfp.qtd_solic_nova 
      LET p_dia_semana = 4
      CALL pol0211_frequencia_11()
      LET p_saldo      = p_saldo + p_ped_itens_qfp.qtd_solic_nova 
      LET p_ped_itens_qfp.qtd_solic_nova   = p_qtd_solic_nova - p_saldo
      LET p_ped_itens_qfp.qtd_solic_aceita = p_qtd_solic_nova - p_saldo
      LET p_dia_semana = 5
   END IF

   IF qfptran_2.cod_freq_fornec = "26" THEN 
      LET p_qtd_solic_int = p_ped_itens_qfp.qtd_solic_nova / 3
      LET p_ped_itens_qfp.qtd_solic_nova   = p_qtd_solic_int
      LET p_ped_itens_qfp.qtd_solic_aceita = p_qtd_solic_int
      LET p_dia_semana = 1
      CALL pol0211_frequencia_26_a_29()
      LET p_saldo      = p_saldo + p_ped_itens_qfp.qtd_solic_nova 
      LET p_dia_semana = 3
      CALL pol0211_frequencia_26_a_29()
      LET p_saldo      = p_saldo + p_ped_itens_qfp.qtd_solic_nova 
      LET p_ped_itens_qfp.qtd_solic_nova   = p_qtd_solic_nova - p_saldo
      LET p_ped_itens_qfp.qtd_solic_aceita = p_qtd_solic_nova - p_saldo
      LET p_dia_semana = 5
   END IF
   IF qfptran_2.cod_freq_fornec = "27" THEN 
      LET p_qtd_solic_int = p_ped_itens_qfp.qtd_solic_nova / 2
      LET p_ped_itens_qfp.qtd_solic_nova   = p_qtd_solic_int
      LET p_ped_itens_qfp.qtd_solic_aceita = p_qtd_solic_int
      LET p_dia_semana = 1
      CALL pol0211_frequencia_26_a_29()
      LET p_saldo      = p_saldo + p_ped_itens_qfp.qtd_solic_nova 
      LET p_ped_itens_qfp.qtd_solic_nova   = p_qtd_solic_nova - p_saldo
      LET p_ped_itens_qfp.qtd_solic_aceita = p_qtd_solic_nova - p_saldo
      LET p_dia_semana = 3
   END IF
   IF qfptran_2.cod_freq_fornec = "28" THEN 
      LET p_qtd_solic_int = p_ped_itens_qfp.qtd_solic_nova / 2
      LET p_ped_itens_qfp.qtd_solic_nova   = p_qtd_solic_int
      LET p_ped_itens_qfp.qtd_solic_aceita = p_qtd_solic_int
      LET p_dia_semana = 2
      CALL pol0211_frequencia_26_a_29()
      LET p_saldo      = p_saldo + p_ped_itens_qfp.qtd_solic_nova 
      LET p_ped_itens_qfp.qtd_solic_nova   = p_qtd_solic_nova - p_saldo
      LET p_ped_itens_qfp.qtd_solic_aceita = p_qtd_solic_nova - p_saldo
      LET p_dia_semana = 4
   END IF
   IF qfptran_2.cod_freq_fornec = "29" THEN 
      LET p_qtd_solic_int = p_ped_itens_qfp.qtd_solic_nova / 2
      LET p_ped_itens_qfp.qtd_solic_nova   = p_qtd_solic_int
      LET p_ped_itens_qfp.qtd_solic_aceita = p_qtd_solic_int
      LET p_dia_semana = 3
      CALL pol0211_frequencia_26_a_29()
      LET p_saldo      = p_saldo + p_ped_itens_qfp.qtd_solic_nova 
      LET p_ped_itens_qfp.qtd_solic_nova   = p_qtd_solic_nova - p_saldo
      LET p_ped_itens_qfp.qtd_solic_aceita = p_qtd_solic_nova - p_saldo
      LET p_dia_semana = 5
   END IF

   IF qfptran_2.cod_freq_fornec = "11" OR 
      qfptran_2.cod_freq_fornec = "26" OR 
      qfptran_2.cod_freq_fornec = "27" OR 
      qfptran_2.cod_freq_fornec = "28" OR 
      qfptran_2.cod_freq_fornec = "29" THEN 

      SELECT semana_mes
        INTO p_tpol0211.semana_mes
        FROM tpol0211
       WHERE data = p_prz_entrega
   ELSE 
      
      SELECT semana_mes
        INTO p_tpol0211.semana_mes
        FROM tpol0211
       WHERE data = p_ped_itens_qfp.prz_entrega
   END IF

   IF qfptran_2.cod_freq_fornec = "40" THEN 
      LET p_tpol0211.semana_mes = 1
      LET p_dia_semana         = 5
   END IF
   IF qfptran_2.cod_freq_fornec = "41" THEN 
      LET p_tpol0211.semana_mes = 1
      LET p_dia_semana         = 5
   END IF
   IF qfptran_2.cod_freq_fornec = "42" THEN 
      LET p_tpol0211.semana_mes = 2
      LET p_dia_semana         = 5
   END IF
   IF qfptran_2.cod_freq_fornec = "43" THEN 
      LET p_tpol0211.semana_mes = 3
      LET p_dia_semana         = 5
   END IF
   IF qfptran_2.cod_freq_fornec = "44" THEN 
      LET p_tpol0211.semana_mes = 4
      LET p_dia_semana         = 3
   END IF

   IF pol0211_pesquisa_tpol0211() THEN 
     {
     IF p_ped_itens_qfp.prz_entrega < TODAY
       THEN LET p_ped_itens_qfp.prz_entrega = TODAY
     END IF
     }
   ELSE 
      IF qfptran_2.cod_freq_fornec = "26" OR 
         qfptran_2.cod_freq_fornec = "27" OR 
         qfptran_2.cod_freq_fornec = "28" OR 
         qfptran_2.cod_freq_fornec = "29" THEN 
         IF p_tpol0211.semana_mes = 1 THEN 
            CALL pol0211_seleciona_26_a_29_maior()
         ELSE 
            IF p_tpol0211.semana_mes > 4 THEN 
               CALL pol0211_seleciona_26_a_29_menor()
            END IF
         END IF
      ELSE 
         IF qfptran_2.cod_freq_fornec = "11" THEN 
            IF p_tpol0211.semana_mes = 1 THEN 
               CALL pol0211_seleciona_11_maior()
            ELSE 
               IF p_tpol0211.semana_mes > 4 THEN 
                  CALL pol0211_seleciona_11_menor()
               END IF
            END IF
         ELSE 
            IF p_tpol0211.semana_mes = 1 THEN 
               LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
            ELSE 
               IF p_tpol0211.semana_mes > 4 THEN 
                  LET p_tpol0211.semana_mes = p_tpol0211.semana_mes - 1
               END IF
            END IF
         END IF
      END IF
      IF pol0211_pesquisa_tpol0211() THEN 
      ELSE 
         #LET p_ped_itens_qfp.prz_entrega = TODAY
      END IF
   END IF
END FUNCTION


#---------------------------------------------------------------------#
 FUNCTION pol0211_frequencia_11()
#---------------------------------------------------------------------#
  SELECT semana_mes
    INTO p_tpol0211.semana_mes
    FROM tpol0211
   WHERE data = p_prz_entrega
#p_ped_itens_qfp.prz_entrega

  IF   pol0211_pesquisa_tpol0211()
  THEN 
  ELSE IF   p_tpol0211.semana_mes = 1
       THEN CALL pol0211_seleciona_11_maior()
       ELSE IF   p_tpol0211.semana_mes > 4
            THEN CALL pol0211_seleciona_11_menor()
            END IF
       END IF
       IF   pol0211_pesquisa_tpol0211()
       THEN 
       ELSE # LET p_ped_itens_qfp.prz_entrega = TODAY
       END IF
  END IF

  CALL pol0211_qfptran_grava_ped_itens_qfp()
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0211_seleciona_11_maior()
#---------------------------------------------------------------------#
  IF   p_dia_semana = 1
  THEN LET p_dia_semana = 2
       IF   pol0211_pesquisa_tpol0211()
       THEN 
       ELSE LET p_dia_semana = 3
            IF   pol0211_pesquisa_tpol0211()
            THEN 
            ELSE LET p_dia_semana = 4
                 IF   pol0211_pesquisa_tpol0211()
                 THEN 
                 ELSE LET p_dia_semana = 5
                      IF   pol0211_pesquisa_tpol0211()
                      THEN 
                      ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
                           LET p_dia_semana         = 1
                      END IF
                 END IF
            END IF
       END IF
  ELSE
       IF   p_dia_semana = 2
       THEN LET p_dia_semana = 3
            IF   pol0211_pesquisa_tpol0211()
            THEN 
            ELSE LET p_dia_semana = 4
                 IF   pol0211_pesquisa_tpol0211()
                 THEN 
                 ELSE LET p_dia_semana = 5
                      IF   pol0211_pesquisa_tpol0211()
                      THEN 
                      ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
                           LET p_dia_semana         = 1
                      END IF
                 END IF
            END IF
       ELSE
            IF   p_dia_semana = 3
            THEN LET p_dia_semana = 4
                 IF   pol0211_pesquisa_tpol0211()
                 THEN 
                 ELSE LET p_dia_semana = 5
                      IF   pol0211_pesquisa_tpol0211()
                      THEN 
                      ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
                           LET p_dia_semana         = 1
                      END IF
                 END IF
            ELSE
                 IF   p_dia_semana = 4
                 THEN LET p_dia_semana = 5
                      IF   pol0211_pesquisa_tpol0211()
                      THEN 
                      ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
                           LET p_dia_semana         = 1
                      END IF
                 ELSE
                      LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
                      LET p_dia_semana         = 1
                 END IF
            END IF
       END IF
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0211_seleciona_11_menor()
#---------------------------------------------------------------------#
  IF   p_dia_semana = 5
  THEN LET p_dia_semana = 4
       IF   pol0211_pesquisa_tpol0211()
       THEN 
       ELSE LET p_dia_semana = 3
            IF   pol0211_pesquisa_tpol0211()
            THEN 
            ELSE LET p_dia_semana = 2
                 IF   pol0211_pesquisa_tpol0211()
                 THEN 
                 ELSE LET p_dia_semana = 1
                      IF   pol0211_pesquisa_tpol0211()
                      THEN 
                      ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes - 1
                           LET p_dia_semana         = 5
                      END IF
                 END IF
            END IF
       END IF
  ELSE
       IF   p_dia_semana = 4
       THEN LET p_dia_semana = 3
            IF   pol0211_pesquisa_tpol0211()
            THEN 
            ELSE LET p_dia_semana = 2
                 IF   pol0211_pesquisa_tpol0211()
                 THEN 
                 ELSE LET p_dia_semana = 1
                      IF   pol0211_pesquisa_tpol0211()
                      THEN 
                      ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes - 1
                           LET p_dia_semana         = 5
                      END IF
                 END IF
            END IF
       ELSE
            IF   p_dia_semana = 3
            THEN LET p_dia_semana = 2
                 IF   pol0211_pesquisa_tpol0211()
                 THEN 
                 ELSE LET p_dia_semana = 1
                      IF   pol0211_pesquisa_tpol0211()
                      THEN 
                      ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes - 1
                           LET p_dia_semana         = 5
                      END IF
                 END IF
            ELSE
                 IF   p_dia_semana = 2
                 THEN LET p_dia_semana = 1
                      IF   pol0211_pesquisa_tpol0211()
                      THEN 
                      ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes - 1
                           LET p_dia_semana         = 5
                      END IF
                 ELSE
                      LET p_tpol0211.semana_mes = p_tpol0211.semana_mes - 1
                      LET p_dia_semana         = 5
                 END IF
            END IF
       END IF
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0211_frequencia_20_a_25()
#---------------------------------------------------------------------#
  SELECT semana_mes
    INTO p_tpol0211.semana_mes
    FROM tpol0211
   WHERE data = p_ped_itens_qfp.prz_entrega

  SELECT dia_semana
    INTO p_tpol0211.dia_semana
    FROM tpol0211
   WHERE data = p_ped_itens_qfp.prz_entrega

  IF   p_tpol0211.dia_semana = 0
    OR p_tpol0211.dia_semana = 6
  THEN RETURN
  END IF

  IF   p_tpol0211.dia_semana > p_dia_semana
  THEN RETURN
  END IF

  IF   pol0211_pesquisa_tpol0211()
  THEN 
       {
       IF   p_ped_itens_qfp.prz_entrega < TODAY
       THEN LET p_ped_itens_qfp.prz_entrega = TODAY
       END IF
       }
  ELSE LET p_data_ant = p_ped_itens_qfp.prz_entrega
       FOR p_ind = 1 TO 5
           IF   MONTH(p_ped_itens_qfp.prz_entrega + 1) <> MONTH(p_data_ant)
           THEN EXIT FOR
           ELSE LET p_ped_itens_qfp.prz_entrega =
                    p_ped_itens_qfp.prz_entrega + 1
           END IF
       END FOR
       SELECT dia_semana
         INTO p_dia_semana
         FROM tpol0211
        WHERE data = p_ped_itens_qfp.prz_entrega
       IF   pol0211_pesquisa_tpol0211()
       THEN 
       ELSE #LET p_ped_itens_qfp.prz_entrega = TODAY
       END IF
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0211_frequencia_26_a_29()
#---------------------------------------------------------------------#
  SELECT semana_mes
    INTO p_tpol0211.semana_mes
    FROM tpol0211
   WHERE data = p_prz_entrega
## p_ped_itens_qfp.prz_entrega

  IF   pol0211_pesquisa_tpol0211()
  THEN
       {
       IF   p_ped_itens_qfp.prz_entrega < TODAY
       THEN LET p_ped_itens_qfp.prz_entrega = TODAY
       END IF
       }
  ELSE IF   p_tpol0211.semana_mes = 1
       THEN CALL pol0211_seleciona_26_a_29_maior()
       ELSE IF   p_tpol0211.semana_mes > 4
            THEN CALL pol0211_seleciona_26_a_29_menor()
            END IF
       END IF
       IF   pol0211_pesquisa_tpol0211()
       THEN 
       ELSE # LET p_ped_itens_qfp.prz_entrega = TODAY
       END IF
  END IF

  CALL pol0211_qfptran_grava_ped_itens_qfp()
END FUNCTION


#----------------------------------------#
FUNCTION pol0211_seleciona_26_a_29_maior()
#----------------------------------------#
  
   IF qfptran_2.cod_freq_fornec = "26" THEN 
      IF p_dia_semana = 1 THEN 
         LET p_dia_semana = 3
         IF pol0211_pesquisa_tpol0211() THEN 
         ELSE 
            LET p_dia_semana = 5
            IF pol0211_pesquisa_tpol0211() THEN 
            ELSE 
               LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
               LET p_dia_semana         = 1
            END IF
         END IF
      ELSE 
         IF p_dia_semana = 3 THEN 
            LET p_dia_semana = 5
            IF pol0211_pesquisa_tpol0211() THEN 
            ELSE 
               LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
               LET p_dia_semana         = 1
            END IF
         ELSE 
            LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
            LET p_dia_semana         = 1
         END IF
      END IF
   END IF
   IF qfptran_2.cod_freq_fornec = "27" THEN 
      IF p_dia_semana = 1 THEN 
         LET p_dia_semana = 3
         IF pol0211_pesquisa_tpol0211() THEN 
         ELSE 
            LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
            LET p_dia_semana         = 1
         END IF
      ELSE
         LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
         LET p_dia_semana         = 1
      END IF
   END IF
   IF qfptran_2.cod_freq_fornec = "28" THEN 
      IF p_dia_semana = 2 THEN 
         LET p_dia_semana = 4
         IF pol0211_pesquisa_tpol0211() THEN 
         ELSE 
            LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
            LET p_dia_semana         = 2
         END IF
      ELSE
         LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
         LET p_dia_semana         = 2
      END IF
   END IF
   IF qfptran_2.cod_freq_fornec = "29" THEN 
      IF p_dia_semana = 3 THEN 
         LET p_dia_semana = 5
         IF pol0211_pesquisa_tpol0211() THEN 
         ELSE 
            LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
            LET p_dia_semana         = 3
         END IF
      ELSE 
         LET p_tpol0211.semana_mes = p_tpol0211.semana_mes + 1
         LET p_dia_semana         = 3
      END IF
   END IF
END FUNCTION


#----------------------------------------#
FUNCTION pol0211_seleciona_26_a_29_menor()
#----------------------------------------#
  IF   qfptran_2.cod_freq_fornec = "26"
  THEN IF   p_dia_semana = 5
       THEN LET p_dia_semana = 3
            IF   pol0211_pesquisa_tpol0211()
            THEN 
            ELSE LET p_dia_semana = 1
                 IF   pol0211_pesquisa_tpol0211()
                 THEN 
                 ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes - 1
                      LET p_dia_semana         = 5
                 END IF
            END IF
       ELSE IF   p_dia_semana = 3
            THEN LET p_dia_semana = 1
                 IF   pol0211_pesquisa_tpol0211()
                 THEN 
                 ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes - 1
                      LET p_dia_semana         = 5
                 END IF
            ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes - 1
                 LET p_dia_semana         = 5
            END IF
       END IF
  END IF
  IF   qfptran_2.cod_freq_fornec = "27"
  THEN IF   p_dia_semana = 3
       THEN LET p_dia_semana = 1
            IF   pol0211_pesquisa_tpol0211()
            THEN 
            ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes - 1
                 LET p_dia_semana         = 3
            END IF
       ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes - 1
            LET p_dia_semana         = 3
       END IF
  END IF
  IF   qfptran_2.cod_freq_fornec = "28"
  THEN IF   p_dia_semana = 4
       THEN LET p_dia_semana = 2
            IF   pol0211_pesquisa_tpol0211()
            THEN 
            ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes - 1
                 LET p_dia_semana         = 4
            END IF
       ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes - 1
            LET p_dia_semana         = 4
       END IF
  END IF
  IF   qfptran_2.cod_freq_fornec = "29"
  THEN IF   p_dia_semana = 5
       THEN LET p_dia_semana = 3
            IF   pol0211_pesquisa_tpol0211()
            THEN 
            ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes - 1
                 LET p_dia_semana         = 5
            END IF
       ELSE LET p_tpol0211.semana_mes = p_tpol0211.semana_mes - 1
            LET p_dia_semana         = 5
       END IF
  END IF
END FUNCTION

#----------------------------------#
FUNCTION pol0211_pesquisa_tpol0211()
#----------------------------------#
   SELECT data
     INTO p_ped_itens_qfp.prz_entrega
     FROM tpol0211
    WHERE MONTH(data) = MONTH(p_ped_itens_qfp.prz_entrega)
      AND semana_mes  = p_tpol0211.semana_mes
      AND dia_semana  = p_dia_semana

   IF sqlca.sqlcode = 0 THEN 
      RETURN TRUE
   ELSE 
      RETURN FALSE
   END IF
END FUNCTION


#--------------------------------------------#
FUNCTION pol0211_qfptran_grava_ped_itens_qfp()
#--------------------------------------------#
   SELECT qtd_solic_nova,
          qtd_solic_aceita
     INTO p_peditem_ant.qtd_solic_nova,
          p_peditem_ant.qtd_solic_aceita
     FROM ped_itens_qfp
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_itens_qfp.num_pedido
      AND cod_item    = p_ped_itens_qfp.cod_item
      AND prz_entrega = p_ped_itens_qfp.prz_entrega

   IF p_peditem_ant.qtd_solic_nova IS NULL THEN 
      LET p_peditem_ant.qtd_solic_nova = 0
   END IF
   IF p_peditem_ant.qtd_solic_aceita IS NULL THEN 
      LET p_peditem_ant.qtd_solic_aceita = 0
   END IF

   IF sqlca.sqlcode = 0 THEN 

      UPDATE ped_itens_qfp
         SET qtd_solic_nova   = p_ped_itens_qfp.qtd_solic_nova + 
                                p_peditem_ant.qtd_solic_nova,
             qtd_solic_aceita = p_ped_itens_qfp.qtd_solic_aceita + 
                                p_peditem_ant.qtd_solic_aceita
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_ped_itens_qfp.num_pedido
         AND cod_item    = p_ped_itens_qfp.cod_item
         AND prz_entrega = p_ped_itens_qfp.prz_entrega
      IF sqlca.sqlcode <> 0 THEN 
         LET p_houve_erro = TRUE
         CALL log003_err_sql("ATUALIZACAO-1","PED_ITENS_QFP")
      END IF
   ELSE 
      LET p_ped_itens_qfp.qtd_solic = 0
      LET p_ped_itens_qfp.qtd_atend = 0
      CALL pol0211_gravar_ped_itens_qfp()
   END IF

   IF p_houve_erro = FALSE THEN 
      CALL log085_transacao("COMMIT")
   #  COMMIT WORK
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO-2","PED_ITENS_QFP")
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
      ELSE 
         CALL log085_transacao("BEGIN")
      #  BEGIN WORK
      END IF
   ELSE 
      CALL log003_err_sql("INCLUSAO-3","PED_ITENS_QFP")
      CALL log085_transacao("ROLLBACK")
   #  ROLLBACK WORK
   END IF
END FUNCTION


#------------------------------------------#
FUNCTION pol0211_qfptran_grava_pedidos_qfp()
#------------------------------------------#
   DEFINE p_contador       SMALLINT

   LET p_contador = 0

   SELECT count(*)
     INTO p_contador
     FROM pedidos_qfp
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_itens_qfp.num_pedido

   ## alteracao em acordo com Geraldo - Tupy - 15/09/95 - deleta o existente
   IF p_contador = 0 THEN 
      CALL pol0211_gravar_pedidos_qfp()
   ELSE 
      DELETE 
        FROM pedidos_qfp
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_ped_itens_qfp.num_pedido
      IF sqlca.sqlcode <> 0 THEN 
         LET p_houve_erro = TRUE
         CALL log003_err_sql("DELECAO-1 ","PEDIDOS_QFP")
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
      ELSE  
         CALL log085_transacao("COMMIT")
      #  COMMIT WORK
         IF sqlca.sqlcode <> 0 THEN 
            LET p_houve_erro = TRUE
            CALL log003_err_sql("DELECAO-2","PEDIDOS_QFP")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         ELSE 
            CALL log085_transacao("BEGIN")
         #  BEGIN WORK

            SELECT COUNT(*)
              INTO p_contador
              FROM ped_itens_qfp
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido  = p_ped_itens_qfp.num_pedido
            IF p_contador > 0 THEN 
               DELETE 
                 FROM ped_itens_qfp
                WHERE cod_empresa = p_cod_empresa
                  AND num_pedido  = p_ped_itens_qfp.num_pedido
               IF sqlca.sqlcode = 0 THEN 
                  CALL log085_transacao("COMMIT")
               #  COMMIT WORK
                  IF sqlca.sqlcode <> 0 THEN 
                     LET p_houve_erro = TRUE
                     CALL log003_err_sql("DELECAO-1","PED_ITENS_QFP")
                     CALL log085_transacao("ROLLBACK")
                  #  ROLLBACK WORK
                  ELSE 
                     CALL log085_transacao("BEGIN")
                  #  BEGIN WORK
                  END IF
               ELSE 
                  LET p_houve_erro = TRUE
                  CALL log003_err_sql("DELECAO-2 ","PED_ITENS_QFP")
                  CALL log085_transacao("ROLLBACK")
               #  ROLLBACK WORK
               END IF
            END IF 
       
            LET p_contador = 0 
            SELECT COUNT(*)
              INTO p_contador
              FROM ped_itens_qfp_pe5
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido  = p_ped_itens_qfp.num_pedido
            IF p_contador > 0 THEN 
               DELETE 
                 FROM ped_itens_qfp_pe5
                WHERE cod_empresa = p_cod_empresa
                  AND num_pedido  = p_ped_itens_qfp.num_pedido
               IF sqlca.sqlcode = 0 THEN 
                  CALL log085_transacao("COMMIT")
               #  COMMIT WORK
                  IF sqlca.sqlcode <> 0 THEN 
                     LET p_houve_erro = TRUE
                     CALL log003_err_sql("DELECAO-1","PED_ITENS_QFP_PE5")
                     CALL log085_transacao("ROLLBACK")
                  #  ROLLBACK WORK
                  ELSE 
                     CALL log085_transacao("BEGIN")
                  #  BEGIN WORK
                  END IF
               ELSE 
                  LET p_houve_erro = TRUE
                  CALL log003_err_sql("DELECAO-2 ","PED_ITENS_QFP_PE5")
                  CALL log085_transacao("ROLLBACK")
               #  ROLLBACK WORK
               END IF
            END IF
            CALL pol0211_gravar_pedidos_qfp()
         END IF
      END IF
   END IF

   IF p_houve_erro = FALSE THEN 
      CALL log085_transacao("COMMIT")
   #  COMMIT WORK
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INCLUSAO-2","PEDIDOS_QFP")
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
      ELSE 
         CALL log085_transacao("BEGIN")
      #  BEGIN WORK
      END IF
   ELSE 
      CALL log003_err_sql("INCLUSAO-3","PEDIDOS_QFP")
      CALL log085_transacao("ROLLBACK")
   #  ROLLBACK WORK
   END IF
END FUNCTION


#-----------------------------------#
FUNCTION pol0211_gravar_pedidos_qfp()
#-----------------------------------#
   LET p_pedidos_qfp.cod_empresa       = p_cod_empresa
   LET p_pedidos_qfp.num_pedido        = p_ped_itens_qfp.num_pedido
   LET p_pedidos_qfp.num_prog_atual    = qfptran_1.prg_atual
   LET p_pedidos_qfp.dat_prog_atual    = qfptran_1.dat_prg_atual
   LET p_pedidos_qfp.num_prog_ant      = qfptran_1.prg_anterior

   IF qfptran_1.dat_prg_anterior > 0 THEN 
      LET p_pedidos_qfp.dat_prog_ant = qfptran_1.dat_prg_anterior
   ELSE 
      LET p_pedidos_qfp.dat_prog_ant = NULL
   END IF

   LET p_pedidos_qfp.cod_frequencia    = qfptran_2.cod_freq_fornec
   LET p_pedidos_qfp.num_nff_ult       = qfptran_2.num_ult_nf
   LET p_pedidos_qfp.cod_item_cliente  = " "
   FOR p_ind = 1 TO 30
      IF qfptran_1.item_cliente[p_ind,p_ind] <> " " THEN 
         LET p_pedidos_qfp.cod_item_cliente = 
             p_pedidos_qfp.cod_item_cliente CLIPPED, 
             qfptran_1.item_cliente[p_ind,p_ind]
      END IF
   END FOR

   INSERT INTO pedidos_qfp VALUES (p_pedidos_qfp.*)
   IF sqlca.sqlcode <> 0 THEN 
      LET p_houve_erro = TRUE
      CALL log003_err_sql("INCLUSAO-1","PEDIDOS_QFP")
   END IF
END FUNCTION


#-------------------------------------------------#
FUNCTION pol0211_ped_itens_qfp_verifica_ped_itens()
#-------------------------------------------------#
   CALL log085_transacao("BEGIN")
#  BEGIN WORK
  
   LET p_houve_erro = FALSE

   INITIALIZE p_pedidos_qfp.*, 
              p_ped_itens_qfp.*, 
              p_ped_itens.*        TO NULL

   DECLARE cp_ped_itens_qfp CURSOR WITH HOLD FOR 
    SELECT *
      INTO p_ped_itens_qfp.*
      FROM ped_itens_qfp
     WHERE cod_empresa = p_cod_empresa
     ORDER BY num_pedido,
              num_sequencia,
              cod_item,
              prz_entrega

   FOREACH cp_ped_itens_qfp
      CALL pol0211_ped_itens_atualiza_ped_itens_qfp()
   END FOREACH
END FUNCTION


#-------------------------------------------------#
FUNCTION pol0211_ped_itens_atualiza_ped_itens_qfp()
#-------------------------------------------------#
   DEFINE p_ies_qfp            CHAR(01)

   SELECT cod_cliente
     INTO p_cod_cliente
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_itens_qfp.num_pedido
      AND ies_sit_pedido <> '9'
   SELECT val_param
     INTO p_ies_qfp
     FROM par_vdp_padrao
    WHERE cod_empresa = p_cod_empresa   
      AND cod_acesso  = p_cod_cliente 
      AND cod_param   = "ies_qfp" 
   IF sqlca.sqlcode <> 0 THEN 
      LET p_ies_qfp = "C"
   END IF

   DECLARE cp_ped_itens CURSOR WITH HOLD FOR
    SELECT *
      FROM ped_itens            
     WHERE cod_empresa = p_cod_empresa   
       AND num_pedido  = p_ped_itens_qfp.num_pedido 
       AND cod_item    = p_ped_itens_qfp.cod_item
     ORDER BY num_sequencia,
              prz_entrega

   FOREACH cp_ped_itens INTO p_ped_itens.*
      # Verifica saldo do ped_itens zerado - ignora
      LET p_saldo = 0
      LET p_saldo = p_ped_itens.qtd_pecas_solic - 
                    p_ped_itens.qtd_pecas_atend - 
                    p_ped_itens.qtd_pecas_cancel

      IF p_saldo > 0 THEN
      ELSE 
         CONTINUE FOREACH
      END IF

      SELECT ped_itens_qfp.*
        INTO p_ped_itens_qfp.*
        FROM ped_itens_qfp
       WHERE cod_empresa = p_cod_empresa   
         AND num_pedido  = p_ped_itens.num_pedido 
         AND cod_item    = p_ped_itens.cod_item
         AND prz_entrega = p_ped_itens.prz_entrega
      IF sqlca.sqlcode = 0 THEN 
         LET p_ped_itens_qfp.qtd_solic = p_ped_itens.qtd_pecas_solic - 
                                         p_ped_itens.qtd_pecas_atend - 
                                         p_ped_itens.qtd_pecas_cancel  
         CALL pol0211_atualiza_ped_itens_qfp()
      ELSE 
         LET p_ped_itens_qfp.cod_empresa      = p_cod_empresa
         LET p_ped_itens_qfp.num_pedido       = p_ped_itens.num_pedido
         LET p_ped_itens_qfp.cod_item         = p_ped_itens.cod_item
         LET p_ped_itens_qfp.prz_entrega      = p_ped_itens.prz_entrega
         LET p_ped_itens_qfp.qtd_solic        = p_ped_itens.qtd_pecas_solic
                                              - p_ped_itens.qtd_pecas_atend
                                              - p_ped_itens.qtd_pecas_cancel  

         IF p_ies_qfp = "P"  THEN     {# PARCIAL - HONDA #} 
            LET p_ped_itens_qfp.qtd_solic_nova   = p_ped_itens_qfp.qtd_solic
            LET p_ped_itens_qfp.qtd_solic_aceita = p_ped_itens_qfp.qtd_solic
         ELSE 
            LET p_ped_itens_qfp.qtd_solic_nova   = 0
            LET p_ped_itens_qfp.qtd_solic_aceita = 0
         END IF

         CALL pol0211_ped_itens_qfp_num_sequencia()
         CALL pol0211_gravar_ped_itens_qfp()
      END IF

      IF p_houve_erro = FALSE THEN 
         CALL log085_transacao("COMMIT")
      #  COMMIT WORK   
         IF sqlca.sqlcode <> 0 THEN 
            CALL log003_err_sql("ATUALIZA-3","PED_ITENS_QFP")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK                                  
         ELSE 
            CALL log085_transacao("BEGIN")
         #  BEGIN WORK                                     
         END IF                                              
      ELSE 
         CALL log003_err_sql("ATUALIZA-4","PED_ITENS_QFP")     
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK                                       
      END IF                                                   
   END FOREACH 
END FUNCTION


#---------------------------------------#
FUNCTION pol0211_atualiza_ped_itens_qfp()
#---------------------------------------#
   UPDATE ped_itens_qfp
      SET qtd_solic        = p_ped_itens_qfp.qtd_solic
          # qtd_atend        = p_ped_itens_qfp.qtd_atend,
          # qtd_solic_aceita = p_ped_itens_qfp.qtd_solic_aceita
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_itens.num_pedido
      AND cod_item    = p_ped_itens.cod_item
      AND prz_entrega = p_ped_itens.prz_entrega

   IF sqlca.sqlcode <> 0 THEN 
      LET p_houve_erro = TRUE
      CALL log003_err_sql("ATUALIZA-2","PED_ITENS_QFP")
   END IF
END FUNCTION


#--------------------------------------------#
FUNCTION pol0211_ped_itens_qfp_num_sequencia()
#--------------------------------------------#
   SELECT MAX(num_sequencia)
     INTO p_ped_itens_qfp.num_sequencia
     FROM ped_itens_qfp
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_itens_qfp.num_pedido
 #    AND cod_item    = p_ped_itens_qfp.cod_item
END FUNCTION


#-------------------------------------#
FUNCTION pol0211_gravar_ped_itens_qfp()
#-------------------------------------#
   LET p_ped_itens_qfp.num_sequencia = p_ped_itens_qfp.num_sequencia + 1

   INSERT INTO ped_itens_qfp VALUES (p_ped_itens_qfp.*)

   IF sqlca.sqlcode <> 0 THEN 
      LET p_houve_erro = TRUE
      CALL log003_err_sql("INCLUSAO-1","PED_ITENS_QFP")
   END IF
   
   INSERT INTO ped_itens_qfp_512 VALUES (p_ped_itens_qfp.cod_empresa, 
                                         p_ped_itens_qfp.num_pedido, 
                                         p_ped_itens_qfp.num_sequencia,
                                         p_ped_itens_qfp.cod_item,
                                         p_ped_itens_qfp.prz_entrega,
                                         p_ped_itens_qfp.qtd_solic_aceita)

   IF sqlca.sqlcode <> 0 THEN 
      LET p_houve_erro = TRUE
      CALL log003_err_sql("INCLUSAO-1","PED_ITENS_QFP_512")
   END IF
   
END FUNCTION


#-------------------------------------------#
FUNCTION pol0211_ped_itens_qfp_verifica_nff()
#-------------------------------------------#
   CALL log085_transacao("BEGIN")
#  BEGIN WORK
  
   LET p_houve_erro = FALSE
   LET p_saldo          = 0
   LET p_num_pedido_ant = 0
   
   INITIALIZE p_pedidos_qfp.*, p_ped_itens_qfp.*, p_ped_itens.*,
              p_cod_cliente TO NULL

   DECLARE cp_peditem_saldo CURSOR WITH HOLD FOR 
    SELECT *
      FROM ped_itens_qfp
     WHERE cod_empresa      = p_cod_empresa
       AND qtd_solic_nova   > 0
       AND qtd_solic_aceita > 0
     ORDER BY num_pedido,
              num_sequencia,
              cod_item,
              prz_entrega

   FOREACH cp_peditem_saldo INTO p_ped_itens_qfp.*
      LET p_num_ped_temp = p_ped_itens_qfp.num_pedido
      IF pol0211_verifica_tpol0211_1() THEN
      ELSE 
         CONTINUE FOREACH
      END IF

      IF p_ped_itens_qfp.num_pedido <> p_num_pedido_ant THEN 
         CALL pol0211_ped_itens_qfp_verifica_pedidos_qfp()
         CALL pol0211_verifica_nf()
         LET p_num_pedido_ant = p_ped_itens_qfp.num_pedido
      END IF

      LET p_saldo = p_saldo
                  + p_ped_itens_qfp.qtd_solic_nova
                # + p_ped_itens_qfp.qtd_solic_aceita
                # + p_ped_itens_qfp.qtd_atend
                
      IF p_saldo > 0 THEN 
         LET p_ped_itens_qfp.qtd_solic_aceita = p_saldo
         LET p_saldo                          = 0
      ELSE 
         LET p_ped_itens_qfp.qtd_solic_aceita = 0
      END IF

      UPDATE ped_itens_qfp
         SET qtd_solic_aceita = p_ped_itens_qfp.qtd_solic_aceita
       WHERE ped_itens_qfp.cod_empresa   = p_cod_empresa
         AND ped_itens_qfp.num_pedido    = p_ped_itens_qfp.num_pedido
         AND ped_itens_qfp.cod_item      = p_ped_itens_qfp.cod_item
         AND ped_itens_qfp.prz_entrega   = p_ped_itens_qfp.prz_entrega

      IF sqlca.sqlcode <> 0 THEN 
         LET p_houve_erro = TRUE
         CALL log003_err_sql("ATUALIZA-6","PED_ITENS_QFP")
      END IF
   END FOREACH
END FUNCTION


#------------------------------------#
FUNCTION pol0211_verifica_tpol0211_1()
#------------------------------------#
   SELECT *
     FROM tpol0211_1
    WHERE num_pedido = p_num_ped_temp

   IF sqlca.sqlcode = 0 THEN 
      RETURN TRUE
   ELSE 
      RETURN FALSE
   END IF
END FUNCTION


#---------------------------------------------------#
FUNCTION pol0211_ped_itens_qfp_verifica_pedidos_qfp()
#---------------------------------------------------#
   LET p_dat_emissao = 0

   SELECT num_nff_ult
     INTO p_pedidos_qfp.num_nff_ult
     FROM pedidos_qfp
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_itens_qfp.num_pedido

   SELECT cod_cliente
     INTO p_cod_cliente
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_itens_qfp.num_pedido
      AND ies_sit_pedido <> '9'

   SELECT dat_emissao
     INTO p_dat_emissao
     FROM nf_mestre
    WHERE cod_empresa = p_cod_empresa
      AND num_nff     = p_pedidos_qfp.num_nff_ult
END FUNCTION


#----------------------------#
FUNCTION pol0211_verifica_nf()
#----------------------------#
  DEFINE p_cod_tip_carteira   LIKE item_vdp.cod_tip_carteira

  LET p_qtd_item = 0

  SELECT cod_tip_carteira
    INTO p_cod_tip_carteira
    FROM item_vdp
   WHERE item_vdp.cod_empresa = p_cod_empresa
     AND item_vdp.cod_item    = p_ped_itens_qfp.cod_item

# selecao natureza de operacao, solicitado pelo Geraldo - Tupy - 20/09/95
#
  SELECT SUM(nf_item.qtd_item)
    INTO p_qtd_item
    FROM nf_mestre, nf_item, nat_operacao
   WHERE nf_mestre.cod_empresa         = p_cod_empresa
     AND nf_mestre.cod_cliente         = p_cod_cliente
     AND nf_mestre.ies_situacao        = "N"
     AND nf_mestre.cod_tip_carteira    = p_cod_tip_carteira
     AND nf_mestre.num_nff             >  p_pedidos_qfp.num_nff_ult
     AND nf_mestre.dat_emissao         >= p_dat_emissao
     AND nf_mestre.cod_nat_oper        = nat_operacao.cod_nat_oper
     AND (nat_operacao.ies_estatistica = "T"
      OR  nat_operacao.ies_estatistica = "Q")
     AND nf_mestre.cod_empresa         = nf_item.cod_empresa
     AND nf_mestre.num_nff             = nf_item.num_nff
     AND nf_item.num_pedido            = p_ped_itens_qfp.num_pedido
     AND nf_item.cod_item              = p_ped_itens_qfp.cod_item
 
  IF   p_qtd_item IS NULL
  THEN LET p_qtd_item = 0
  END IF

  LET p_saldo = p_qtd_item * (- 1)
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0211_deleta_qfptran()
#---------------------------------------------------------------------#

   
   CALL log085_transacao("BEGIN")
#  BEGIN WORK
   DELETE FROM qfptran 
   IF sqlca.sqlcode = 0 THEN 
      CALL log085_transacao("COMMIT")
   #  COMMIT WORK
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("DELECAO-1","QFPTRAN")
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
      END IF
   ELSE 
      CALL log003_err_sql("DELECAO-2","QFPTRAN")
      CALL log085_transacao("ROLLBACK")
   #  ROLLBACK WORK
   END IF
   

END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0211_lista_relat()
#---------------------------------------------------------------------#
  LET p_imprimir = "NAO"
  
  IF   log028_saida_relat(16,37) IS NOT NULL
  THEN LET p_imprimir = "SIM"
       IF g_ies_ambiente = "W"
       THEN IF p_ies_impressao = "S"
            THEN START REPORT pol0211_relat TO PRINTER
            ELSE START REPORT pol0211_relat TO p_nom_arquivo
            END IF
       ELSE 
            IF p_ies_impressao = "S"
            THEN START REPORT pol0211_relat TO PIPE p_nom_arquivo
            ELSE START REPORT pol0211_relat TO p_nom_arquivo
            END IF
       END IF
  ELSE LET p_imprimir = "NAO"
  END IF
END FUNCTION

#--------------------------#
REPORT pol0211_relat(l_tipo)
#--------------------------#
   DEFINE l_tipo           CHAR(01),
          l_for            SMALLINT 

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1

  FORMAT
    PAGE HEADER
      PRINT COLUMN   1, p_den_empresa
      PRINT COLUMN   1, "pol0211",
            COLUMN  25, "PECAS ESPECIAIS - PROGRAMACAO DE CLIENTES SEM POSSIBILIDADE DE AUTOMATIZAR",
            COLUMN 125, "FL. ", PAGENO USING "####"
      PRINT COLUMN  94, "EXTRAIDO EM ", TODAY USING "DD/MM/YYYY",
            COLUMN 117, "AS ", TIME,
            COLUMN 129, "HRS."
      SKIP 1 LINE
      PRINT COLUMN  13, "C O D I G O  D O  P R O D U T O",
            COLUMN  79, "NUMERO DO PEDIDO"
      PRINT COLUMN   4, p_den_empresa,
            COLUMN  38, "(CLIENTE)",
            COLUMN  67, "LOCAL",
            COLUMN  76, p_den_empresa,
            COLUMN  90, "(CLIENTE)",
            COLUMN 102, "OBSERVACAO"
      SKIP 1 LINE

    ON EVERY ROW
    CASE 
       WHEN l_tipo = 1 
          LET p_houve_msg_erro = TRUE 
          PRINT COLUMN   1, qfptran_1.item_fornecedor,
                COLUMN  32, qfptran_1.item_cliente,
                COLUMN  64, qfptran_1.local_entrega, #p_cod_local_estoq,
                COLUMN  76, qfptran_1.pedido,
                COLUMN  88, qfptran_1.pedido_cmp,
                COLUMN 102, p_observacao
       WHEN l_tipo = 2 
         PRINT COLUMN 1, "PE3 ", 
                         p_pedidos_edi_pe3.dat_entrega_1 USING "dd/mm/yy", " ",
                         p_pedidos_edi_pe3.qtd_entrega_1 USING "#########";

         IF p_pedidos_edi_pe3.dat_entrega_2 IS NOT NULL AND
            p_pedidos_edi_pe3.dat_entrega_2 <> " "      THEN
            PRINT COLUMN 30, 
                         p_pedidos_edi_pe3.dat_entrega_2 USING "dd/mm/yy", " ",
                         p_pedidos_edi_pe3.qtd_entrega_2 USING "#########";
         END IF 
                         
         IF p_pedidos_edi_pe3.dat_entrega_3 IS NOT NULL AND
            p_pedidos_edi_pe3.dat_entrega_3 <> " "      THEN
            PRINT COLUMN 60, 
                         p_pedidos_edi_pe3.dat_entrega_3 USING "dd/mm/yy", " ",
                         p_pedidos_edi_pe3.qtd_entrega_3 USING "#########";
         END IF 
                         
         IF p_pedidos_edi_pe3.dat_entrega_4 IS NOT NULL AND
            p_pedidos_edi_pe3.dat_entrega_4 <> " "      THEN
            PRINT COLUMN 90, 
                         p_pedidos_edi_pe3.dat_entrega_4 USING "dd/mm/yy", " ",
                         p_pedidos_edi_pe3.qtd_entrega_4 USING "#########"
         ELSE
            PRINT COLUMN 01, " " 
         END IF 
                         
         IF p_pedidos_edi_pe3.dat_entrega_5 IS NOT NULL AND
            p_pedidos_edi_pe3.dat_entrega_5 <> " "      THEN
            PRINT COLUMN 5, 
                         p_pedidos_edi_pe3.dat_entrega_5 USING "dd/mm/yy", " ",
                         p_pedidos_edi_pe3.qtd_entrega_5 USING "#########";
         END IF 
                         
         IF p_pedidos_edi_pe3.dat_entrega_6 IS NOT NULL AND
            p_pedidos_edi_pe3.dat_entrega_6 <> " "      THEN
            PRINT COLUMN 30, 
                         p_pedidos_edi_pe3.dat_entrega_6 USING "dd/mm/yy", " ",
                         p_pedidos_edi_pe3.qtd_entrega_6 USING "#########";
         END IF 
                         
         IF p_pedidos_edi_pe3.dat_entrega_7 IS NOT NULL AND
            p_pedidos_edi_pe3.dat_entrega_7 <> " "      THEN
            PRINT COLUMN 60,
                         p_pedidos_edi_pe3.dat_entrega_7 USING "dd/mm/yy", " ",
                         p_pedidos_edi_pe3.qtd_entrega_7 USING "#########"
         ELSE 
            PRINT COLUMN 1, " " 
         END IF 

      OTHERWISE
         PRINT COLUMN 1, " "
         PRINT COLUMN 1, "UNIDADE MEDIDA: ", 
                          p_pedidos_edi_pe1.cod_unid_med, " - ",
                         "LOCAL DESTINO: ", 
                          p_pedidos_edi_pe1.cod_local_destino, " - ",
                         "FABRICA DESTINO: ", 
                          p_pedidos_edi_pe1.cod_fabr_dest
         PRINT COLUMN 1, " "
         PRINT COLUMN 1, "ALTERACAO TECNICA => ", 
                          p_pedidos_edi_pe6.alter_tecnica

         PRINT COLUMN 1, " "
         PRINT COLUMN 1, "ULTIMA ENTREGA => ", 
                         " NFF: ",p_pedidos_edi_pe2.num_ult_nff USING "######",
                        " QTD: ",p_pedidos_edi_pe2.qtd_recebido USING "#######",
                        " DATA: ",p_pedidos_edi_pe2.dat_rec_ult_nff 
                                                            USING "dd/mm/yy",
                       " QTD. ACUMULADO: ", p_pedidos_edi_pe2.qtd_receb_acum
                                                            USING "#########"
         PRINT COLUMN 1, " "
         
         PRINT COLUMN 1, "TIPO FORNECIMENTO => ", p_pedidos_edi_pe1.cod_tip_fornec;
         IF p_ies_firme = 'S' THEN               
           PRINT COLUMN 25, "IDENT. PROGRAMA => ", " 1 - ITEM FIRMADO " 
         ELSE
           PRINT COLUMN 25, "IDENT. PROGRAMA => ", p_pedidos_edi_pe5.identif_programa_1 
         END IF
                                 
         PRINT COLUMN 1, " "
         PRINT COLUMN 1, "TEXTOS => "
         FOR l_for = 1 TO 100
             IF pa_edi_te1[l_for].den_texto IS NOT NULL AND
                pa_edi_te1[l_for].den_texto <> " "      THEN
                PRINT COLUMN 1, pa_edi_te1[l_for].den_texto
             END IF 
         END FOR
         PRINT COLUMN 1, " "
         PRINT COLUMN 1, " "
         LET p_houve_msg_erro = FALSE
    END CASE 

    ON LAST ROW
      LET p_last_row = true
    PAGE TRAILER
      IF   p_last_row = true
      THEN PRINT "* * * ULTIMA FOLHA * * *"
      ELSE PRINT " "
      END IF
END REPORT

#--------------------------------------------#
FUNCTION pol0211_gera_tabela_edi_pe1(l_status)
#--------------------------------------------#
   DEFINE l_status    SMALLINT,
          x_hoje      date 

   INITIALIZE p_pedidos_edi_pe1.*  TO NULL 
   
  

   LET p_pedidos_edi_pe1.cod_empresa        = p_cod_empresa
   LET p_pedidos_edi_pe1.num_pedido         = qfptran_1.pedido
   LET p_pedidos_edi_pe1.cod_fabr_dest      = p_qfptran.qfp_tran_txt[4,6]
   LET p_pedidos_edi_pe1.identif_prog_atual = p_qfptran.qfp_tran_txt[7,15]
   LET p_pedidos_edi_pe1.dat_prog_atual     = qfptran_1.dat_prg_atual #[16,21]
   LET p_pedidos_edi_pe1.identif_prog_ant   = p_qfptran.qfp_tran_txt[22,30]
   
   IF LENGTH(qfptran_1.dat_prg_anterior) > 0 THEN
      LET p_pedidos_edi_pe1.dat_prog_anterior  = qfptran_1.dat_prg_anterior #[31,36]
   ELSE   
      LET p_pedidos_edi_pe1.dat_prog_anterior  = '01/01/1900'
   END IF    
    
   LET p_pedidos_edi_pe1.cod_item_cliente   = p_qfptran.qfp_tran_txt[37,66]
   LET p_pedidos_edi_pe1.cod_item           = qfptran_1.item_fornecedor #[67,96]
   LET p_pedidos_edi_pe1.num_pedido_compra  = p_qfptran.qfp_tran_txt[97,106]
   LET p_pedidos_edi_pe1.cod_local_destino  = p_qfptran.qfp_tran_txt[109,113]
   LET p_pedidos_edi_pe1.nom_contato        = p_qfptran.qfp_tran_txt[114,124]
   LET p_pedidos_edi_pe1.cod_unid_med       = p_qfptran.qfp_tran_txt[125,126]
   LET p_pedidos_edi_pe1.qtd_casas_decimais = p_qfptran.qfp_tran_txt[127,127]
   LET p_pedidos_edi_pe1.cod_tip_fornec     = p_qfptran.qfp_tran_txt[128,128]

   IF l_status = 1 THEN
      RETURN
   END IF 

   DELETE
     FROM pedidos_edi_pe1
    WHERE cod_empresa    = p_cod_empresa
      AND num_pedido     = qfptran_1.pedido
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","PEDIDOS_EDI_PE1")
      RETURN 
   END IF 

   INSERT INTO pedidos_edi_pe1(
      cod_empresa,             
      num_pedido,           
      cod_fabr_dest,        
      identif_prog_atual,   
      dat_prog_atual,       
      identif_prog_ant,     
      dat_prog_anterior,    
      cod_item_cliente,     
      cod_item,             
      num_pedido_compra,    
      cod_local_destino,    
      nom_contato,          
      cod_unid_med,         
      qtd_casas_decimais,   
      cod_tip_fornec) 
   VALUES(p_pedidos_edi_pe1.cod_empresa,          
          p_pedidos_edi_pe1.num_pedido,           
          p_pedidos_edi_pe1.cod_fabr_dest,        
          p_pedidos_edi_pe1.identif_prog_atual,   
          p_pedidos_edi_pe1.dat_prog_atual,       
          p_pedidos_edi_pe1.identif_prog_ant,     
          p_pedidos_edi_pe1.dat_prog_anterior,    
          p_pedidos_edi_pe1.cod_item_cliente,     
          p_pedidos_edi_pe1.cod_item,             
          p_pedidos_edi_pe1.num_pedido_compra,    
          p_pedidos_edi_pe1.cod_local_destino,    
          p_pedidos_edi_pe1.nom_contato,          
          p_pedidos_edi_pe1.cod_unid_med,         
          p_pedidos_edi_pe1.qtd_casas_decimais,   
          p_pedidos_edi_pe1.cod_tip_fornec)       

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","PEDIDOS_EDI_PE1")
   END IF

END FUNCTION


#--------------------------------------------#
FUNCTION pol0211_gera_tabela_edi_pe2(l_status)
#--------------------------------------------#
   DEFINE l_status    SMALLINT   

   INITIALIZE p_pedidos_edi_pe2.*  TO NULL

   LET p_pedidos_edi_pe2.cod_empresa        = p_cod_empresa
   LET p_pedidos_edi_pe2.num_pedido         = qfptran_1.pedido

   IF p_qfptran.qfp_tran_txt[4,5] >= "00" AND
      p_qfptran.qfp_tran_txt[4,5] <= "50" THEN
      LET p_seculo = "20"
   ELSE
      LET p_seculo = "19"
   END IF
   LET p_ano = p_seculo, p_qfptran.qfp_tran_txt[4,5]  
   LET p_pedidos_edi_pe2.dat_ult_embar  = MDY(p_qfptran.qfp_tran_txt[6,7],
                                          p_qfptran.qfp_tran_txt[8,9],p_ano)

   LET p_pedidos_edi_pe2.num_ult_nff    = p_qfptran.qfp_tran_txt[10,15]
   LET p_pedidos_edi_pe2.ser_ult_nff    = p_qfptran.qfp_tran_txt[16,19]

   IF p_qfptran.qfp_tran_txt[20,21] >= "00" AND
      p_qfptran.qfp_tran_txt[20,21] <= "50" THEN
      LET p_seculo = "20"
   ELSE
      LET p_seculo = "19"
   END IF
   LET p_ano = p_seculo, p_qfptran.qfp_tran_txt[20,21]  
   LET p_pedidos_edi_pe2.dat_rec_ult_nff  = MDY(p_qfptran.qfp_tran_txt[22,23],
                                            p_qfptran.qfp_tran_txt[24,25],p_ano)
   LET p_pedidos_edi_pe2.qtd_recebido       = p_qfptran.qfp_tran_txt[26,37]
   LET p_pedidos_edi_pe2.qtd_receb_acum     = p_qfptran.qfp_tran_txt[38,51]
   LET p_pedidos_edi_pe2.qtd_lote_minimo    = p_qfptran.qfp_tran_txt[66,77]
   LET p_pedidos_edi_pe2.cod_freq_fornec    = p_qfptran.qfp_tran_txt[78,80]
   LET p_pedidos_edi_pe2.dat_lib_producao   = p_qfptran.qfp_tran_txt[81,84]
   LET p_pedidos_edi_pe2.dat_lib_mat_prima  = p_qfptran.qfp_tran_txt[85,88]
   LET p_pedidos_edi_pe2.cod_local_descarga = p_qfptran.qfp_tran_txt[89,95]
   LET p_pedidos_edi_pe2.periodo_entrega    = p_qfptran.qfp_tran_txt[96,99]
   LET p_pedidos_edi_pe2.cod_sit_item       = p_qfptran.qfp_tran_txt[100,101]
   LET p_pedidos_edi_pe2.identif_tip_prog   = p_qfptran.qfp_tran_txt[102,102]
   LET p_pedidos_edi_pe2.pedido_revenda     = p_qfptran.qfp_tran_txt[103,115]
   LET p_pedidos_edi_pe2.qualif_progr       = p_qfptran.qfp_tran_txt[116,116]

   IF l_status = 1 THEN
      RETURN
   END IF 

   DELETE
     FROM pedidos_edi_pe2
    WHERE cod_empresa    = p_cod_empresa
      AND num_pedido     = qfptran_1.pedido
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","PEDIDOS_EDI_PE2")
      RETURN 
   END IF 

   INSERT INTO pedidos_edi_pe2 VALUES (p_pedidos_edi_pe2.*)
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","PEDIDOS_EDI_PE2")
   END IF
END FUNCTION


#--------------------------------------------#
FUNCTION pol0211_gera_tabela_edi_pe3(l_status)
#--------------------------------------------#
   DEFINE l_status    SMALLINT   

   INITIALIZE p_pedidos_edi_pe3.*  TO NULL

   IF l_status = 2 THEN
      LET p_qfptran.* = p_qfptran_aux.* 
   END IF 

   IF p_qfptran.qfp_tran_txt[4,5] >= "00" AND
      p_qfptran.qfp_tran_txt[4,5] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[4,5]

   LET p_pedidos_edi_pe3.cod_empresa    = p_cod_empresa
   LET p_pedidos_edi_pe3.num_pedido     = qfptran_1.pedido
   LET p_pedidos_edi_pe3.num_sequencia  = p_ped_itens_qfp.num_sequencia
   LET p_pedidos_edi_pe3.dat_entrega_1  = MDY(p_qfptran.qfp_tran_txt[6,7], 
                                          p_qfptran.qfp_tran_txt[8,9], p_ano)
   LET p_pedidos_edi_pe3.hor_entrega_1  = p_qfptran.qfp_tran_txt[10,11]
   LET p_pedidos_edi_pe3.qtd_entrega_1  = p_qfptran.qfp_tran_txt[12,20]

   IF p_qfptran.qfp_tran_txt[21,22] >= "00" AND
      p_qfptran.qfp_tran_txt[21,22] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[21,22]

   LET p_pedidos_edi_pe3.dat_entrega_2  = MDY(p_qfptran.qfp_tran_txt[23,24], 
                                          p_qfptran.qfp_tran_txt[25,26], p_ano)
   LET p_pedidos_edi_pe3.hor_entrega_2  = p_qfptran.qfp_tran_txt[27,28]
   LET p_pedidos_edi_pe3.qtd_entrega_2  = p_qfptran.qfp_tran_txt[29,37]

   IF p_qfptran.qfp_tran_txt[38,39] >= "00" AND
      p_qfptran.qfp_tran_txt[38,39] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[38,39]

   LET p_pedidos_edi_pe3.dat_entrega_3  = MDY(p_qfptran.qfp_tran_txt[40,41], 
                                          p_qfptran.qfp_tran_txt[42,43],p_ano)
   LET p_pedidos_edi_pe3.hor_entrega_3  = p_qfptran.qfp_tran_txt[44,45]
   LET p_pedidos_edi_pe3.qtd_entrega_3  = p_qfptran.qfp_tran_txt[46,54]

   IF p_qfptran.qfp_tran_txt[55,56] >= "00" AND
      p_qfptran.qfp_tran_txt[55,56] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[55,56]

   LET p_pedidos_edi_pe3.dat_entrega_4  = MDY(p_qfptran.qfp_tran_txt[57,58], 
                                          p_qfptran.qfp_tran_txt[59,60],p_ano)
   LET p_pedidos_edi_pe3.hor_entrega_4  = p_qfptran.qfp_tran_txt[61,62]
   LET p_pedidos_edi_pe3.qtd_entrega_4  = p_qfptran.qfp_tran_txt[63,71]

   IF p_qfptran.qfp_tran_txt[72,73] >= "00" AND
      p_qfptran.qfp_tran_txt[72,73] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[72,73]

   LET p_pedidos_edi_pe3.dat_entrega_5  = MDY(p_qfptran.qfp_tran_txt[74,75], 
                                          p_qfptran.qfp_tran_txt[76,77],p_ano)
   LET p_pedidos_edi_pe3.hor_entrega_5  = p_qfptran.qfp_tran_txt[78,79]
   LET p_pedidos_edi_pe3.qtd_entrega_5  = p_qfptran.qfp_tran_txt[80,88]

   IF p_qfptran.qfp_tran_txt[89,90] >= "00" AND
      p_qfptran.qfp_tran_txt[89,90] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[89,90]

   LET p_pedidos_edi_pe3.dat_entrega_6  = MDY(p_qfptran.qfp_tran_txt[91,92], 
                                          p_qfptran.qfp_tran_txt[93,94],p_ano)
   LET p_pedidos_edi_pe3.hor_entrega_6  = p_qfptran.qfp_tran_txt[95,96]
   LET p_pedidos_edi_pe3.qtd_entrega_6  = p_qfptran.qfp_tran_txt[97,105]

   IF p_qfptran.qfp_tran_txt[106,107] >= "00" AND
      p_qfptran.qfp_tran_txt[106,107] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[106,107]

   LET p_pedidos_edi_pe3.dat_entrega_7  = MDY(p_qfptran.qfp_tran_txt[108,109], 
                                          p_qfptran.qfp_tran_txt[110,111],p_ano)
   LET p_pedidos_edi_pe3.hor_entrega_7  = p_qfptran.qfp_tran_txt[112,113]
   LET p_pedidos_edi_pe3.qtd_entrega_7  = p_qfptran.qfp_tran_txt[114,122]

   IF l_status = 1 THEN
      RETURN
   END IF 

   DELETE
     FROM pedidos_edi_pe3
    WHERE cod_empresa    = p_cod_empresa
      AND num_pedido     = qfptran_1.pedido
      AND num_sequencia  = p_ped_itens_qfp.num_sequencia
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","PEDIDOS_EDI_PE3")
      RETURN 
   END IF 

   INSERT INTO pedidos_edi_pe3 VALUES (p_pedidos_edi_pe3.*)
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","PEDIDOS_EDI_PE3")
   END IF
END FUNCTION


#--------------------------------------------#
FUNCTION pol0211_gera_tabela_edi_pe4(l_status)
#--------------------------------------------#
   DEFINE l_status    SMALLINT,
          w_valor     DEC(17,3)  

   INITIALIZE p_pedidos_edi_pe4.*  TO NULL
   LET w_valor   = 0 

   LET p_pedidos_edi_pe4.cod_empresa       = p_cod_empresa
   LET p_pedidos_edi_pe4.num_pedido        = qfptran_1.pedido
   LET p_pedidos_edi_pe4.tip_emb_cli_seg   = p_qfptran.qfp_tran_txt[4,33]
   LET p_pedidos_edi_pe4.tip_emb_forn_seg  = p_qfptran.qfp_tran_txt[34,63]
   LET w_valor                             = p_qfptran.qfp_tran_txt[64,75] 
   LET p_pedidos_edi_pe4.capac_emb_seg     = w_valor / 1000
   LET p_pedidos_edi_pe4.tip_emb_forn_pri  = p_qfptran.qfp_tran_txt[76,105]
   LET p_pedidos_edi_pe4.capac_emb_pri     = p_qfptran.qfp_tran_txt[106,117]
   LET p_pedidos_edi_pe4.cod_resp_emb      = p_qfptran.qfp_tran_txt[118,118]

   IF l_status = 1 THEN
      RETURN
   END IF 

   DELETE
     FROM pedidos_edi_pe4
    WHERE cod_empresa    = p_cod_empresa
      AND num_pedido     = qfptran_1.pedido
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","PEDIDOS_EDI_PE4")
      RETURN TRUE
   END IF 

   INSERT INTO pedidos_edi_pe4 VALUES (p_pedidos_edi_pe4.*)
   IF sqlca.sqlcode <> 0 AND  
      sqlca.sqlcode <> -1226 THEN 
      CALL log003_err_sql("INCLUSAO","PEDIDOS_EDI_PE4")
   END IF
END FUNCTION


#--------------------------------------------#
FUNCTION pol0211_gera_tabela_edi_pe5(l_status)
#--------------------------------------------#
   DEFINE l_status    SMALLINT   

   INITIALIZE p_pedidos_edi_pe5.*  TO NULL

   LET p_pedidos_edi_pe5.cod_empresa         = p_cod_empresa
   LET p_pedidos_edi_pe5.num_pedido          = qfptran_1.pedido
   LET p_pedidos_edi_pe5.num_sequencia       = p_ped_itens_qfp.num_sequencia

   IF p_qfptran.qfp_tran_txt[4,5] >= "00" AND
      p_qfptran.qfp_tran_txt[4,5] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[4,5]

   LET p_pedidos_edi_pe5.dat_entrega_1  = MDY(p_qfptran.qfp_tran_txt[6,7], 
                                          p_qfptran.qfp_tran_txt[8,9],p_ano)

   LET p_pedidos_edi_pe5.identif_programa_1  = p_qfptran.qfp_tran_txt[10,10]
   LET p_pedidos_edi_pe5.ident_prog_atual_1  = p_qfptran.qfp_tran_txt[11,19]

   IF p_pedidos_edi_pe5.identif_programa_1 = '1' THEN 
      LET p_ies_firme = 'S'
   END IF    

   IF p_qfptran.qfp_tran_txt[20,21] >= "00" AND
      p_qfptran.qfp_tran_txt[20,21] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[20,21]

   LET p_pedidos_edi_pe5.dat_entrega_2  = MDY(p_qfptran.qfp_tran_txt[22,23], 
                                          p_qfptran.qfp_tran_txt[24,25],p_ano)

   LET p_pedidos_edi_pe5.identif_programa_2  = p_qfptran.qfp_tran_txt[26,26]
   LET p_pedidos_edi_pe5.ident_prog_atual_2  = p_qfptran.qfp_tran_txt[27,35]

   IF p_qfptran.qfp_tran_txt[36,37] >= "00" AND
      p_qfptran.qfp_tran_txt[36,37] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[36,37]

   LET p_pedidos_edi_pe5.dat_entrega_3  = MDY(p_qfptran.qfp_tran_txt[38,39], 
                                          p_qfptran.qfp_tran_txt[40,41],p_ano)

   LET p_pedidos_edi_pe5.identif_programa_3  = p_qfptran.qfp_tran_txt[42,42]
   LET p_pedidos_edi_pe5.ident_prog_atual_3  = p_qfptran.qfp_tran_txt[43,51]

   IF p_qfptran.qfp_tran_txt[52,53] >= "00" AND
      p_qfptran.qfp_tran_txt[52,53] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[52,53]

   LET p_pedidos_edi_pe5.dat_entrega_4  = MDY(p_qfptran.qfp_tran_txt[54,55], 
                                          p_qfptran.qfp_tran_txt[56,57],p_ano)

   LET p_pedidos_edi_pe5.identif_programa_4  = p_qfptran.qfp_tran_txt[58,58]
   LET p_pedidos_edi_pe5.ident_prog_atual_4  = p_qfptran.qfp_tran_txt[59,67]

   IF p_qfptran.qfp_tran_txt[68,69] >= "00" AND
      p_qfptran.qfp_tran_txt[68,69] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[68,69]

   LET p_pedidos_edi_pe5.dat_entrega_5  = MDY(p_qfptran.qfp_tran_txt[70,71], 
                                          p_qfptran.qfp_tran_txt[72,73],p_ano)

   LET p_pedidos_edi_pe5.identif_programa_5  = p_qfptran.qfp_tran_txt[74,74]
   LET p_pedidos_edi_pe5.ident_prog_atual_5  = p_qfptran.qfp_tran_txt[75,83]

   IF p_qfptran.qfp_tran_txt[84,85] >= "00" AND
      p_qfptran.qfp_tran_txt[84,85] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[84,85]

   LET p_pedidos_edi_pe5.dat_entrega_6  = MDY(p_qfptran.qfp_tran_txt[86,87], 
                                          p_qfptran.qfp_tran_txt[88,89],p_ano)

   LET p_pedidos_edi_pe5.identif_programa_6  = p_qfptran.qfp_tran_txt[90,90]
   LET p_pedidos_edi_pe5.ident_prog_atual_6  = p_qfptran.qfp_tran_txt[91,99]

   IF p_qfptran.qfp_tran_txt[100,101] >= "00" AND
      p_qfptran.qfp_tran_txt[100,101] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[100,101]

   LET p_pedidos_edi_pe5.dat_entrega_7  = MDY(p_qfptran.qfp_tran_txt[102,103], 
                                          p_qfptran.qfp_tran_txt[104,105],p_ano)

   LET p_pedidos_edi_pe5.identif_programa_7  = p_qfptran.qfp_tran_txt[106,106]
   LET p_pedidos_edi_pe5.ident_prog_atual_7  = p_qfptran.qfp_tran_txt[107,115]

   IF l_status = 1 THEN
      RETURN
   END IF 

   DELETE
     FROM pedidos_edi_pe5
    WHERE cod_empresa    = p_cod_empresa
      AND num_pedido     = qfptran_1.pedido
      AND num_sequencia  = p_ped_itens_qfp.num_sequencia
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","PEDIDOS_EDI_PE5")
      RETURN TRUE
   END IF 

   INSERT INTO pedidos_edi_pe5 VALUES (p_pedidos_edi_pe5.*)
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","PEDIDOS_EDI_PE5")
   END IF
END FUNCTION


#--------------------------------------------#
FUNCTION pol0211_gera_tabela_edi_pe6(l_status)
#--------------------------------------------#
   DEFINE l_status    SMALLINT   

   INITIALIZE p_pedidos_edi_pe6.*  TO NULL

   LET p_pedidos_edi_pe6.cod_empresa       = p_cod_empresa
   LET p_pedidos_edi_pe6.num_pedido        = qfptran_1.pedido
   LET p_fator_conversao                   = p_qfptran.qfp_tran_txt[4,13]
   LET p_pedidos_edi_pe6.fator_conversao   = p_fator_conversao / 100000
   LET p_pedidos_edi_pe6.alter_tecnica     = p_qfptran.qfp_tran_txt[14,17]
   LET p_pedidos_edi_pe6.cod_material      = p_qfptran.qfp_tran_txt[18,27]

   IF l_status = 1 THEN
      RETURN 
   END IF 

   DELETE
     FROM pedidos_edi_pe6
    WHERE cod_empresa    = p_cod_empresa
      AND num_pedido     = qfptran_1.pedido
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","PEDIDOS_EDI_PE6")
      RETURN TRUE
   END IF 

   INSERT INTO pedidos_edi_pe6 VALUES (p_pedidos_edi_pe6.*)
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","PEDIDOS_EDI_PE6")
   END IF
   
END FUNCTION

#--------------------------------------------#
FUNCTION pol0211_gera_tabela_edi_te1(l_status)
#--------------------------------------------#
   DEFINE l_status    SMALLINT,
          l_for       SMALLINT 

   INITIALIZE p_pedidos_edi_te1.*   TO NULL

   LET p_pedidos_edi_te1.cod_empresa       = p_cod_empresa
   LET p_pedidos_edi_te1.num_pedido        = qfptran_1.pedido
   LET p_pedidos_edi_te1.num_sequencia     = 0 #p_qfptran.qfp_tran_txt[61,62]
   LET p_pedidos_edi_te1.texto_1           = p_qfptran.qfp_tran_txt[4,43]
   LET p_pedidos_edi_te1.texto_2           = p_qfptran.qfp_tran_txt[44,83]
   LET p_pedidos_edi_te1.texto_3           = p_qfptran.qfp_tran_txt[84,123]

   LET l_for = 1 # p_qfptran.qfp_tran_txt[61,62]
   IF l_status = 1 THEN 
      LET pa_edi_te1[l_for].den_texto = p_pedidos_edi_te1.texto_1,
                                        p_pedidos_edi_te1.texto_2,
                                        p_pedidos_edi_te1.texto_3
      RETURN
   END IF 

   #IF p_pedidos_edi_te1.num_sequencia = 1 THEN
      DELETE
        FROM pedidos_edi_te1
       WHERE cod_empresa    = p_cod_empresa
         AND num_pedido     = qfptran_1.pedido
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("DELETE","PEDIDOS_EDI_TE1")
         RETURN TRUE
      END IF 
   #END IF 

   INSERT INTO pedidos_edi_te1 VALUES (p_pedidos_edi_te1.*)
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","PEDIDOS_EDI_TE1")
   END IF
END FUNCTION

#------------------------------------------#
FUNCTION pol0211_busca_informacoes_edi_pe5()
#------------------------------------------#
   DEFINE l_qfptran           RECORD LIKE qfptran.*,
          l_chave             CHAR(58),
          p_exit_foreach      SMALLINT 

   let p_exit_foreach = FALSE 
   LET l_chave        = p_qfptran.qfp_tran_txt[1,58]

   DECLARE cq_edi_pe5 CURSOR FOR
    SELECT *
      FROM qfptran
     WHERE qfp_tran_txt[1,58] = l_chave

   FOREACH cq_edi_pe5 INTO l_qfptran.*
      IF l_qfptran.qfp_tran_txt[59,62] =
         p_qfptran.qfp_tran_txt[59,62]   THEN

         IF l_qfptran.qfp_tran_txt[1,3] = "PE5" AND
            p_exit_foreach                        THEN
            EXIT FOREACH
         END IF

         FETCH NEXT cq_edi_pe5 INTO l_qfptran.*

         IF l_qfptran.qfp_tran_txt[1,3] = "PE5" THEN 
            LET p_exit_foreach = TRUE 
            EXIT FOREACH
         END IF 
      END IF 
   END FOREACH
   FREE cq_edi_pe5
  
   IF p_exit_foreach = FALSE THEN
      RETURN
   END IF 

   IF l_qfptran.qfp_tran_txt[4,9] IS NOT NULL AND
      l_qfptran.qfp_tran_txt[4,9] <> " "      THEN
      LET p_qfptran.qfp_tran_txt[4,9]  = l_qfptran.qfp_tran_txt[4,9] 
   END IF 

   IF l_qfptran.qfp_tran_txt[20,25] IS NOT NULL AND
      l_qfptran.qfp_tran_txt[20,25] <> " "      THEN
      LET p_qfptran.qfp_tran_txt[21,26]  = l_qfptran.qfp_tran_txt[20,25] 
   END IF 

   IF l_qfptran.qfp_tran_txt[36,41] IS NOT NULL AND
      l_qfptran.qfp_tran_txt[36,41] <> " "      THEN
      LET p_qfptran.qfp_tran_txt[38,43]  = l_qfptran.qfp_tran_txt[36,41]
   END IF 

   IF l_qfptran.qfp_tran_txt[52,57] IS NOT NULL AND
      l_qfptran.qfp_tran_txt[52,57] <> " "      THEN
      LET p_qfptran.qfp_tran_txt[55,60]  = l_qfptran.qfp_tran_txt[52,57] 
   END IF 

   IF l_qfptran.qfp_tran_txt[68,73] IS NOT NULL AND
      l_qfptran.qfp_tran_txt[68,73] <> " "      THEN
      LET p_qfptran.qfp_tran_txt[72,77]  = l_qfptran.qfp_tran_txt[68,73] 
   END IF 

   IF l_qfptran.qfp_tran_txt[84,89] IS NOT NULL AND
      l_qfptran.qfp_tran_txt[84,89] <> " "      THEN
      LET p_qfptran.qfp_tran_txt[89,94]  = l_qfptran.qfp_tran_txt[84,89] 
   END IF 

   IF l_qfptran.qfp_tran_txt[100,105] IS NOT NULL AND
      l_qfptran.qfp_tran_txt[100,105] <> " "      THEN
      LET p_qfptran.qfp_tran_txt[106,111]  = l_qfptran.qfp_tran_txt[100,105] 
   END IF 

END FUNCTION

# osvaldo
#----------------------------------------#
FUNCTION pol0211_grava_ped_itens_qfp_pe5()
#----------------------------------------#

   DEFINE pa_ped_edi_pe5 ARRAY[7] OF RECORD 
      num_pedido       LIKE pedidos_edi_pe5.num_pedido,
      num_sequencia    LIKE pedidos_edi_pe5.num_sequencia,
      dat_entrega      LIKE pedidos_edi_pe5.dat_entrega_1,
      identif_programa LIKE pedidos_edi_pe5.identif_programa_1 
   END RECORD 

   DEFINE p_ped_itens_qfp1 RECORD
      num_pedido    LIKE ped_itens_qfp.num_pedido,   
      num_sequencia LIKE ped_itens_qfp.num_sequencia,
      cod_item      LIKE ped_itens_qfp.cod_item            
   END RECORD 

   DEFINE p_temp RECORD
      num_pedido      DEC(6,0), 
      num_sequencia   SMALLINT, 
      dat_abertura    DATE,  
      ies_programacao DEC(2,0) 
   END RECORD 

   DEFINE p_num_pedido LIKE pedidos_qfp.num_pedido,
          p_num_seq    SMALLINT,
          p_i          SMALLINT

   INITIALIZE pa_ped_edi_pe5 TO NULL
   LET p_num_pedido = 0

   DECLARE cp_pedidos_qfp CURSOR WITH HOLD FOR 
   SELECT unique num_pedido
   FROM pedidos_qfp
   WHERE cod_empresa = p_cod_empresa   

   FOREACH cp_pedidos_qfp INTO p_num_pedido             

      DECLARE cp_pedidos_edi_pe5 CURSOR WITH HOLD FOR 
      SELECT num_pedido,
             num_sequencia,
             dat_entrega_1,
             identif_programa_1,
             dat_entrega_2,
             identif_programa_2,
             dat_entrega_3,
             identif_programa_3,
             dat_entrega_4,
             identif_programa_4,
             dat_entrega_5,
             identif_programa_5,
             dat_entrega_6,
             identif_programa_6,
             dat_entrega_7,
             identif_programa_7
      FROM pedidos_edi_pe5
      WHERE cod_empresa = p_cod_empresa   
        AND num_pedido  = p_num_pedido 
      ORDER BY num_sequencia

      LET p_num_seq = 1
      FOREACH cp_pedidos_edi_pe5 INTO pa_ped_edi_pe5[1].num_pedido,
                                      pa_ped_edi_pe5[1].num_sequencia,
                                      pa_ped_edi_pe5[1].dat_entrega,
                                      pa_ped_edi_pe5[1].identif_programa,
                                      pa_ped_edi_pe5[2].dat_entrega,
                                      pa_ped_edi_pe5[2].identif_programa,
                                      pa_ped_edi_pe5[3].dat_entrega,
                                      pa_ped_edi_pe5[3].identif_programa,
                                      pa_ped_edi_pe5[4].dat_entrega,
                                      pa_ped_edi_pe5[4].identif_programa,
                                      pa_ped_edi_pe5[5].dat_entrega,
                                      pa_ped_edi_pe5[5].identif_programa,
                                      pa_ped_edi_pe5[6].dat_entrega,
                                      pa_ped_edi_pe5[6].identif_programa,
                                      pa_ped_edi_pe5[7].dat_entrega,
                                      pa_ped_edi_pe5[7].identif_programa 

         FOR p_i = 1 TO 7

            IF pa_ped_edi_pe5[p_i].dat_entrega IS NULL THEN
               EXIT FOR
            ELSE
               INSERT INTO tpol0211_2 
                  VALUES (pa_ped_edi_pe5[1].num_pedido,
                          p_num_seq,
                          pa_ped_edi_pe5[p_i].dat_entrega,
                          pa_ped_edi_pe5[p_i].identif_programa)
               IF sqlca.sqlcode <> 0 THEN 
                  IF sqlca.sqlcode <> -239 THEN 
                     CALL log003_err_sql("INCLUSAO","Tpol0211_2")
                  END IF
               END IF
            END IF

            LET p_num_seq = p_num_seq + 1

         END FOR 
               
      END FOREACH 

      INITIALIZE pa_ped_edi_pe5 TO NULL

      DECLARE cp_ped_itens_qfp1 CURSOR WITH HOLD FOR 
      SELECT num_pedido,
             num_sequencia,
             cod_item
      FROM ped_itens_qfp
      WHERE cod_empresa = p_cod_empresa   
        AND num_pedido  = p_num_pedido 
      ORDER BY num_sequencia

      FOREACH cp_ped_itens_qfp1 INTO p_ped_itens_qfp1.*

         SELECT * 
            INTO p_temp.*    
         FROM tpol0211_2
         WHERE num_pedido    = p_ped_itens_qfp1.num_pedido
           AND num_sequencia = p_ped_itens_qfp1.num_sequencia

					#ivo 28/01/2013
          IF STATUS <> 0 OR p_temp.dat_abertura IS NULL OR p_temp.ies_programacao IS NULL THEN
             CONTINUE FOREACH
          END IF #até aqui

         INSERT INTO ped_itens_qfp_pe5
            VALUES (p_cod_empresa,                
                    p_temp.num_pedido, 
                    p_ped_itens_qfp1.cod_item,
                    p_temp.num_sequencia, 
                    p_temp.dat_abertura,  
                    p_temp.ies_programacao)
         IF sqlca.sqlcode <> 0 THEN 
            IF sqlca.sqlcode <> -239 THEN 
               CALL log003_err_sql("INCLUSAO","PED_ITENS_QFP_PE5")
            END IF
         END IF

         INSERT INTO ped_itens_qfp_pe512
            VALUES (p_cod_empresa,                
                    p_temp.num_pedido, 
                    p_ped_itens_qfp1.cod_item,
                    p_temp.num_sequencia, 
                    p_temp.dat_abertura,  
                    p_temp.ies_programacao)
         IF sqlca.sqlcode <> 0 THEN 
            IF sqlca.sqlcode <> -239 THEN 
               CALL log003_err_sql("INCLUSAO","PED_ITENS_QFP_PE512")
            END IF
         END IF         
      END FOREACH     

   END FOREACH 

END FUNCTION
#--------------------------------------#
FUNCTION pol0211_corrige_ped_itens_qfp()
#--------------------------------------#
{DEFINE p_num_ped_cor  LIKE ped_itens_qfp.num_pedido,
        p_num_seq_cor  LIKE ped_itens_qfp.num_sequencia,
        p_count_cor    DECIMAL(2,0)

  DECLARE cp_correc  CURSOR WITH HOLD FOR 
      SELECT num_pedido,
             num_sequencia
      FROM ped_itens_qfp
      WHERE cod_empresa = p_cod_empresa   

      FOREACH cp_correc INTO p_num_ped_cor,p_num_seq_cor
         LET p_count_cor = 0
         SELECT count(*)
           INTO p_count_cor 
           FROM ped_itens_qfp_pe5
          WHERE cod_empresa = p_cod_empresa 
            AND num_pedido = p_num_ped_cor
            AND num_sequencia = p_num_seq_cor 
          IF p_count_cor > 0 THEN
          ELSE
             DELETE 
               from ped_itens_qfp
              WHERE cod_empresa = p_cod_empresa 
                AND num_pedido = p_num_ped_cor
                AND num_sequencia = p_num_seq_cor
          END IF 

    END FOREACH 
}
  
    DELETE FROM ped_itens_qfp 
     WHERE NOT EXISTS 
   (SELECT * FROM ped_itens_qfp_pe5 
     WHERE ped_itens_qfp.cod_empresa= ped_itens_qfp_pe5.cod_empresa 
       AND  ped_itens_qfp.num_pedido= ped_itens_qfp_pe5.num_pedido
       AND  ped_itens_qfp.num_sequencia= ped_itens_qfp_pe5.num_sequencia)
       
END FUNCTION

#-----------------------#
FUNCTION pol0211_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------------- FIM DE PROGRAMA ----------------------------#
