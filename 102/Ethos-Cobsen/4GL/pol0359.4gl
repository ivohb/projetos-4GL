#-------------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                             #
# PROGRAMA: pol0359                                                       #
# MODULOS.: pol0359 - LOG0010 - LOG0030 - LOG0050 - LOG0060               #
#           LOG0280 - LOG1300 - LOG1400 - LOG1500                         #
# OBJETIVO: ATUALIZA A TABELA pedidos_qfp_547_vvE  ped_itens_qfp_547_vv   #
#           A PARTIR DAS TABELAS QFPTRAN E PED_ITENS                      #
# AUTOR...: ANDREI DAGOBERTO STREIT                                       #
# DATA....: 04/07/2002                                                    #
### EM CASO DE ALTERACAO DESTA VERSAO ATUALIZAR TAMBEM O VDP1147E         #
### VERSAO ESPECIFICA PARA "IM"                                           #
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
         p_pedido               CHAR(025),
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
         p_prz_entrega          LIKE ped_itens_qfp_547_vv.prz_entrega,
         p_observacao           CHAR(31),
         p_cod_local_estoq      CHAR(10),
         p_tp_prg1              CHAR(01),
         p_tp_prg2              CHAR(01),
         p_tp_prg3              CHAR(01),
         p_tp_prg4              CHAR(01),
         p_tp_prg5              CHAR(01),
         p_tp_prg6              CHAR(01),
         p_tp_prg7              CHAR(01),
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
         p_num_ped_ant          SMALLINT, 
         p_prz_ent_ant          DATE,
         p_ind_dp               SMALLINT, 
         p_ind_dpq              SMALLINT, 
         p_ind_atz              CHAR(01)
  
  DEFINE p_ped_itens         RECORD LIKE ped_itens.*
  
  DEFINE p_pedidos_qfp_547_vv       RECORD LIKE pedidos_qfp_547_vv.*
  
  DEFINE p_ped_itens_qfp_547_vv     RECORD LIKE ped_itens_qfp_547_vv.*
  
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

  DEFINE p_tpol0359           RECORD
                             data             DATE,
                             dia_semana       SMALLINT,
                             semana_mes       SMALLINT
                             END RECORD

  DEFINE  p_pedidos_edi_pe1_547_vv     RECORD LIKE pedidos_edi_pe1_547_vv.*,
          p_pedidos_edi_pe2_547_vv     RECORD LIKE pedidos_edi_pe2_547_vv.*,
          p_pedidos_edi_pe3_547_vv     RECORD LIKE pedidos_edi_pe3_547_vv.*,
          p_pedidos_edi_pe4_547_vv     RECORD LIKE pedidos_edi_pe4_547_vv.*,
          p_pedidos_edi_pe5_547_vv     RECORD LIKE pedidos_edi_pe5_547_vv.*,
          p_pedidos_edi_pe6_547_vv     RECORD LIKE pedidos_edi_pe6_547_vv.*,
          p_pedidos_edi_te1_547_vv     RECORD LIKE pedidos_edi_te1_547_vv.*

  DEFINE  p_trans_cliente       RECORD LIKE trans_cliente.*,
          p_clientes            RECORD LIKE clientes.*,
          p_cli_info_adic       RECORD LIKE cli_info_adic.*,
          p_empresa             RECORD LIKE empresa.*

  DEFINE  pa_edi_te1            ARRAY[500]
          OF RECORD
             den_texto          CHAR(120)
          END RECORD 

MAIN
  LET p_versao = "POL0359-10.02.22" 
  WHENEVER ANY ERROR CONTINUE
  CALL log0180_conecta_usuario()
  CALL log1400_isolation()
  
  DEFER INTERRUPT

  CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
  LET p_help = p_caminho 
  OPTIONS
    HELP FILE p_help

  CALL log001_acessa_usuario("ESPEC999","")
    RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0 THEN 
    CALL pol0359_controle()
  END IF
END MAIN

#----------------------------#
 FUNCTION pol0359_controle()
#----------------------------#
  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("pol0359") RETURNING p_nom_tela 
  OPEN WINDOW w_pol0359 AT 2,2 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND "Processar" "Processa variacao programacao e emite relatorio"
      HELP 0116
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","pol0359","CO") THEN 
         CALL pol0359_lista_relat()
         IF p_imprimir = "SIM" THEN 	
            CALL pol0359_qfptran_carrega_ped_itens_qfp_547_vv()
            IF p_houve_erro = FALSE THEN 
               CALL log085_transacao("COMMIT")
               IF sqlca.sqlcode <> 0 THEN 
                  CALL log003_err_sql("INCLUSAO","pedidos_qfp_547_vv, ped_itens_qfp_547_vv")
                  CALL log085_transacao("ROLLBACK")
               ELSE 
                  # osvaldo 
                  CALL pol0359_grava_ped_itens_qfp_pe5_547_vv()
                  CALL pol0359_corrige_ped_itens_qfp_547_vv()
                  # osvaldo
###                  CALL pol0359_ped_itens_qfp_547_vv_verifica_ped_itens()
###                  IF p_houve_erro = FALSE THEN 
###                     CALL log085_transacao("COMMIT")
###                     IF sqlca.sqlcode <> 0 THEN 
###                        CALL log003_err_sql("ATUALIZA-7","ped_itens_qfp_547_vv")
###                        CALL log085_transacao("ROLLBACK")
###                     ELSE
                  CALL pol0359_ped_itens_qfp_547_vv_verifica_nff() 
                  IF p_houve_erro = FALSE THEN 
                     CALL log085_transacao("COMMIT")
                     IF sqlca.sqlcode <> 0 THEN  
                        CALL log003_err_sql("ATUALIZA-7","ped_itens_qfp_547_vv")
                        CALL log085_transacao("ROLLBACK")
                     ELSE
                        CALL pol0359_deleta_qfptran()
                        NEXT OPTION "Fim"
                     END IF
                  ELSE 
                     CALL log003_err_sql("ATUALIZA-8","ped_itens_qfp_547_vv")
                     CALL log085_transacao("ROLLBACK")
                  END IF
###                     END IF
###                  ELSE 
###                     CALL log003_err_sql("ATUALIZA-8","ped_itens_qfp_547_vv")
###                     CALL log085_transacao("ROLLBACK")
###                  END IF
               END IF
            ELSE
               CALL log003_err_sql("INCLUSAO","pedidos_qfp_547_vv, ped_itens_qfp_547_vv")
               CALL log085_transacao("ROLLBACK")
            END IF
         ELSE 
            NEXT OPTION "Fim"
         END IF
      ELSE
         NEXT OPTION "Fim"
      END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0359_sobre() 
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0359
END FUNCTION

#-----------------------------------------------------#
FUNCTION pol0359_qfptran_carrega_ped_itens_qfp_547_vv()
#-----------------------------------------------------#
   DEFINE p_item                   CHAR(30)

   INITIALIZE p_msg TO NULL

   CALL pol0359_cria_tabelas_temp()
   CALL pol0359_limpa_tabelas()    
   CALL pol0359_insert_tpol0359()

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
     ORDER BY num_trans
     
   FOREACH cp_qfptran INTO p_qfptran.*
      CASE p_qfptran.qfp_tran_txt[1,3]
      
        WHEN "ITP"
         
        LET qfptran_1.num_cgc_montadora   = "0",
                                             p_qfptran.qfp_tran_txt[26,27],".",
                                             p_qfptran.qfp_tran_txt[28,30],".",
                                             p_qfptran.qfp_tran_txt[31,33],"/",
                                             p_qfptran.qfp_tran_txt[34,37],"-",
                                             p_qfptran.qfp_tran_txt[38,39]
     
        WHEN "PE1"
            
              IF p_houve_msg_erro THEN
                 OUTPUT TO REPORT pol0359_relat(3)
              END IF

              INITIALIZE p_pedidos_edi_pe1_547_vv.*, p_pedidos_edi_pe2_547_vv.*,
                         p_pedidos_edi_pe3_547_vv.*, p_pedidos_edi_pe4_547_vv.*,
                         p_pedidos_edi_pe5_547_vv.*, p_pedidos_edi_pe6_547_vv.*,
                         p_pedidos_edi_te1_547_vv.*, p_pedidos_qfp_547_vv.*,
                         p_ped_itens_qfp_547_vv.*,   pa_edi_te1    TO NULL 

              LET p_item = p_qfptran.qfp_tran_txt[67,96] 
              DISPLAY p_item TO item 
              IF p_qfptran_ant IS NULL THEN
              ELSE 
                 IF p_reg_lido      = "PE2"     OR    
                    p_tot_registros = p_zerados THEN 
                    LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = 0  
                    LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = 0

                    IF p_ped_itens_qfp_547_vv.cod_empresa IS NOT NULL THEN 
                       CALL pol0359_qfptran_grava_ped_itens_qfp_547_vv()
                    END IF
                 END IF
              END IF
              LET p_reg_lido       = "PE1"
              LET p_tot_registros  = 0
              LET p_zerados        = 0
              LET p_houve_msg_erro = FALSE

              INITIALIZE p_cod_local_estoq, qfptran_1.pedido, p_observacao,
                         p_tpol0359.semana_mes, p_dia_semana TO NULL
              LET p_qfptran_ant                 = p_qfptran.qfp_tran_txt[1,2]
              LET p_ped_itens_qfp_547_vv.num_sequencia = 0
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
              LET qfptran_1.pedido_cmp = p_qfptran.qfp_tran_txt[97,108]
        
              INITIALIZE qfptran_1.item_fornecedor, p_item_fornecedor TO NULL

              IF p_qfptran.qfp_tran_txt[67,96] = " "   OR 
                 p_qfptran.qfp_tran_txt[67,96] IS NULL THEN 
              ELSE
                 CALL pol0359_verifica_item_fornecedor()
              END IF

              LET qfptran_1.local_entrega = p_qfptran.qfp_tran_txt[109,113]

              IF pol0359_verifica_cod_cliente() = FALSE THEN 
                 INITIALIZE p_qfptran_ant TO NULL
                 CALL pol0359_gera_tabela_edi_pe1(1)
                 CONTINUE FOREACH
              END IF

              IF pol0359_verifica_item() = FALSE THEN 
                 CONTINUE FOREACH
              END IF

              CALL pol0359_insert_tpol0359_1()
              CALL pol0359_gera_tabela_edi_pe1(2)

         WHEN "PE2"
             LET p_reg_lido = "PE2"
             IF p_qfptran_ant IS NULL THEN 
                CALL pol0359_gera_tabela_edi_pe2(1)
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

        
             LET p_ped_itens_qfp_547_vv.cod_empresa  = p_cod_empresa              
             LET p_ped_itens_qfp_547_vv.num_pedido   = qfptran_1.pedido
             LET p_ped_itens_qfp_547_vv.cod_item     = p_cod_item #qfptran_1.item_fornecedor
             CALL pol0359_qfptran_grava_pedidos_qfp_547_vv()
             CALL pol0359_gera_tabela_edi_pe2(2)

         WHEN "PE3"
             LET p_qfptran_aux.* = p_qfptran.*
             IF p_qfptran_ant IS NULL THEN 
                CALL pol0359_gera_tabela_edi_pe3(1)
                CONTINUE FOREACH
             END IF
             LET p_reg_lido      = "PE3"
             CALL pol0359_gera_ped_itens_qfp_547_vv()
             CALL pol0359_gera_tabela_edi_pe3(2)

         WHEN "PE4"
             LET p_reg_lido = "PE4"
             IF p_qfptran_ant IS NULL THEN 
                CALL pol0359_gera_tabela_edi_pe4(1)
                CONTINUE FOREACH
             END IF
             CALL pol0359_gera_tabela_edi_pe4(2)

         WHEN "PE5"
             LET p_reg_lido = "PE5"
             IF p_qfptran_ant IS NULL THEN 
                CALL pol0359_gera_tabela_edi_pe5(1)
                CONTINUE FOREACH
             END IF
             CALL pol0359_gera_tabela_edi_pe5(2)

         WHEN "PE6"
             LET p_reg_lido = "PE6"
             IF p_qfptran_ant IS NULL THEN 
                CALL pol0359_gera_tabela_edi_pe6(1)
                CONTINUE FOREACH
             END IF
             CALL pol0359_gera_tabela_edi_pe6(2)

         WHEN "TE1"
             LET p_reg_lido = "TE1"
             IF p_qfptran_ant IS NULL THEN 
                CALL pol0359_gera_tabela_edi_te1(1)
                CONTINUE FOREACH
             END IF
             CALL pol0359_gera_tabela_edi_te1(2)

      END CASE
   END FOREACH

   FINISH REPORT pol0359_relat
   IF p_ies_impressao = "S" THEN
      MESSAGE "Relatorio Impresso com Sucesso" ATTRIBUTE(REVERSE)
   ELSE
      LET p_msg = "Relatorio Gravado no Arquivo ", p_nom_arquivo CLIPPED
      MESSAGE p_msg ATTRIBUTE(REVERSE)
   END IF
   ERROR "Fim de Processamento"

END FUNCTION

#------------------------------#
FUNCTION pol0359_limpa_tabelas()
#------------------------------#
  DELETE from ped_itens_qfp_pe5_547_vv
  DELETE from ped_it_qfp_pe5_cl_547_vv
  DELETE from ped_itens_qfp_547_vv
  DELETE from pedidos_qfp_547_vv
  DELETE from pedidos_edi_pe1_547_vv
  DELETE from pedidos_edi_pe2_547_vv
  DELETE from pedidos_edi_pe3_547_vv
  DELETE from pedidos_edi_pe4_547_vv
  DELETE from pedidos_edi_pe5_547_vv
  DELETE from pedidos_edi_pe6_547_vv
  DELETE from pedidos_edi_te1_547_vv
END FUNCTION
#----------------------------------#
FUNCTION pol0359_cria_tabelas_temp()
#----------------------------------#
   CREATE TEMP TABLE tpol0359
     (data          DATE,
      dia_semana    SMALLINT,
      semana_mes    SMALLINT)

   CREATE INDEX ix_tpol0359 ON tpol0359 (data)
 
   CREATE TEMP TABLE tpol0359_1
     (num_pedido    DECIMAL(6,0))

   CREATE INDEX ix_tpol0359_1 ON tpol0359_1 (num_pedido)

#  osvaldo
   CREATE TEMP TABLE tpol0359_2
      (num_pedido      DEC(6,0),
       num_sequencia   SMALLINT,
       dat_abertura    DATE,
       ies_programacao DEC(2,0),
       ident_prog      CHAR(9))

   CREATE INDEX ix_tpol0359_2 ON tpol0359_2 (num_pedido, num_sequencia)
#  osvaldo

END FUNCTION

#--------------------------------#
FUNCTION pol0359_insert_tpol0359()
#--------------------------------#
   LET p_tpol0359.data       = MDY(MONTH(today),01,YEAR(today))
   LET p_tpol0359.dia_semana = WEEKDAY(p_tpol0359.data)
   LET p_tpol0359.semana_mes = 1
   LET p_data_ant = p_tpol0359.data

   FOR p_ind = 1 TO 364
      LET p_tpol0359.data       = p_tpol0359.data + 1
      LET p_tpol0359.dia_semana = WEEKDAY(p_tpol0359.data)

      IF MONTH(p_tpol0359.data) <> MONTH(p_data_ant) THEN
         LET p_tpol0359.semana_mes = 1
         LET p_data_ant           = p_tpol0359.data
      ELSE 
         IF p_tpol0359.dia_semana = 0 THEN 
            LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
         ELSE
            LET p_tpol0359.semana_mes = p_tpol0359.semana_mes 
         END IF
      END IF

      INSERT INTO tpol0359 VALUES (p_tpol0359.*)
      IF sqlca.sqlcode <> 0 THEN 
         IF sqlca.sqlcode <> -239 THEN 
            CALL log003_err_sql("INCLUSAO","Tpol0359")
         END IF
      END IF
   END FOR
END FUNCTION

#-----------------------------------------#
FUNCTION pol0359_verifica_item_fornecedor()
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
FUNCTION pol0359_verifica_item()
#------------------------------#

   DEFINE p_num_ped    LIKE ped_itens.num_pedido,
          p_num_sequen LIKE ped_itens.num_sequencia

   INITIALIZE  p_pedido TO NULL 
   FOR p_ind = 1 TO 10
     IF qfptran_1.pedido_cmp[p_ind,p_ind] >= "0" AND
        qfptran_1.pedido_cmp[p_ind,p_ind] <= "9" THEN 
        LET p_pedido = p_pedido CLIPPED, qfptran_1.pedido_cmp[p_ind,p_ind]
     END IF
   END FOR

   LET p_pedidos_qfp_547_vv.cod_item_cliente  =  qfptran_1.item_cliente

   IF p_cod_cliente = '029307609000190' THEN 
      SELECT COUNT(*)
        INTO p_count 
        FROM cliente_item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item_cliente = qfptran_1.item_cliente      
         AND cod_cliente_matriz = p_cod_cliente
         AND cod_item[1,3] IN ('20-','21-','75-')
        
      IF p_count = 0 THEN
         LET p_observacao = "ITEM CLIENTE NAO CADASTRADO "
         OUTPUT TO REPORT pol0359_relat(1)
         INITIALIZE p_qfptran_ant TO NULL
         CALL pol0359_gera_tabela_edi_pe1(1)
         RETURN FALSE
      END IF
      
      IF p_count = 1 THEN
         SELECT cod_item 
           INTO p_cod_item
           FROM cliente_item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item_cliente = qfptran_1.item_cliente      
            AND cod_cliente_matriz = p_cod_cliente
            AND cod_item[1,3] IN ('20-','21-','75-')   
           
         SELECT num_pedido
           INTO p_num_ped   
           FROM pedidos
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido_cli = p_cod_item
            AND cod_cliente = p_cod_cliente
            AND ies_sit_pedido  IN ("N", "C", "F", "A")

         IF STATUS = -284 THEN
            LET p_observacao = "PEDIDO DUPLICADO P/ PEDIDO-CLI ", p_cod_item
            OUTPUT TO REPORT pol0359_relat(1)
            INITIALIZE p_qfptran_ant TO NULL
            CALL pol0359_gera_tabela_edi_pe1(1)
            RETURN FALSE
         END IF

         IF STATUS = 0 THEN
            LET qfptran_1.pedido = p_num_ped
            SELECT MAX(num_sequencia)
              INTO p_num_sequen
              FROM ped_itens    
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido = p_num_ped
         ELSE 
            LET p_observacao = "PEDIDO NAO CADASTRADO"
            LET qfptran_1.pedido = p_pedido
            OUTPUT TO REPORT pol0359_relat(1)
            INITIALIZE p_qfptran_ant TO NULL
            CALL pol0359_gera_tabela_edi_pe1(1)
            INITIALIZE qfptran_1.pedido TO NULL
            RETURN FALSE
         END IF
      ELSE
         LET p_observacao = "ITEM EM DUPLICIDADE "
         OUTPUT TO REPORT pol0359_relat(1)
         INITIALIZE p_qfptran_ant TO NULL
         CALL pol0359_gera_tabela_edi_pe1(1)
         RETURN FALSE
      END IF
   ELSE
      INITIALIZE  p_pedido TO NULL 
      FOR p_ind = 1 TO 10
         IF qfptran_1.pedido_cmp[p_ind,p_ind] >= "0" AND
            qfptran_1.pedido_cmp[p_ind,p_ind] <= "9" THEN 
            LET p_pedido = p_pedido CLIPPED, qfptran_1.pedido_cmp[p_ind,p_ind]
         END IF
      END FOR
   
      SELECT COUNT(*)
        INTO p_count 
        FROM cliente_item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item_cliente = qfptran_1.item_cliente      
         AND cod_cliente_matriz = p_cod_cliente
        
      IF p_count = 0 THEN
         LET p_observacao = "ITEM CLIENTE NAO CADASTRADO "
         OUTPUT TO REPORT pol0359_relat(1)
         INITIALIZE p_qfptran_ant TO NULL
         CALL pol0359_gera_tabela_edi_pe1(1)
         RETURN FALSE
      END IF
      
      IF p_count = 1 THEN
         SELECT cod_item 
           INTO p_cod_item
           FROM cliente_item
          WHERE cod_empresa = p_cod_empresa 
            AND cod_item_cliente = qfptran_1.item_cliente      
            AND cod_cliente_matriz = p_cod_cliente
           
         SELECT num_pedido
           INTO p_num_ped   
           FROM pedidos
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido_cli = p_cod_item
            AND cod_cliente = p_cod_cliente
            AND ies_sit_pedido  IN ("N", "C", "F", "A")
         IF SQLCA.SQLCODE = 0 THEN
            SELECT MAX(num_sequencia)
              INTO p_num_sequen
              FROM ped_itens    
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido = p_num_ped
         ELSE 
            LET qfptran_1.pedido = p_num_ped
            LET p_observacao = "PEDIDO NAO CADASTRADO"
            OUTPUT TO REPORT pol0359_relat(1)
            INITIALIZE p_qfptran_ant TO NULL
            CALL pol0359_gera_tabela_edi_pe1(1)
            RETURN FALSE
         END IF
      ELSE
         LET p_observacao = "ITEM EM DUPLICIDADE "
         OUTPUT TO REPORT pol0359_relat(1)
         INITIALIZE p_qfptran_ant TO NULL
         CALL pol0359_gera_tabela_edi_pe1(1)
         RETURN FALSE
      END IF
   END IF
      
   SELECT cod_local_estoq
     INTO p_cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF SQLCA.SQLCODE = 0 THEN 
      RETURN TRUE
   ELSE 
      LET p_observacao = "ITEM NAO CADASTRADO "
      OUTPUT TO REPORT pol0359_relat(1)
      INITIALIZE p_qfptran_ant TO NULL
      CALL pol0359_gera_tabela_edi_pe1(1)
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------------#
FUNCTION pol0359_verifica_cod_cliente()
#-------------------------------------#
   INITIALIZE p_cod_cliente TO NULL

   DECLARE cq_cliente CURSOR WITH HOLD FOR
    SELECT MAX(cod_cliente)
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
      OUTPUT TO REPORT pol0359_relat(1)
      RETURN FALSE
   END IF      
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol0359_verifica_num_pedido()
#------------------------------------#
   INITIALIZE qfptran_1.pedido, p_cod_cliente TO NULL
   
   LET p_existe = FALSE

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
         EXIT FOREACH
      END IF
   END FOREACH

   IF p_existe = TRUE THEN 
      RETURN TRUE 
   ELSE 
      LET qfptran_1.pedido = 0
      LET p_observacao = "PED. NAO CAD. P/ CGC OU ITEM NAO CAD. NO PED."
      RETURN FALSE
   END IF
END FUNCTION

#-----------------------------------#
FUNCTION pol0359_gera_ped_itens_qfp_547_vv()
#-----------------------------------#

   IF p_qfptran.qfp_tran_txt{[60,60]} = "1" OR 
      p_qfptran.qfp_tran_txt{[60,60]} = "2" THEN
      IF p_qfptran.qfp_tran_txt[12,20] IS NULL OR 
         p_qfptran.qfp_tran_txt[12,20] = " "   THEN
      ELSE 
         LET p_tot_registros = p_tot_registros + 1
         IF p_qfptran.qfp_tran_txt[12,20] > 0 THEN 
            LET p_ped_itens_qfp_547_vv.qtd_solic_nova   =  
                p_qfptran.qfp_tran_txt[12,20]
            LET p_ped_itens_qfp_547_vv.qtd_solic_aceita =
                p_qfptran.qfp_tran_txt[12,20]
            LET qfptran_2.cod_freq_fornec = "000"  
            CALL pol0359_qfptran_verifica_frequencia()
            CALL pol0359_qfptran_grava_ped_itens_qfp_547_vv()
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
            OUTPUT TO REPORT pol0359_relat(1)
         ELSE 
            LET p_tot_registros = p_tot_registros + 1
            IF p_qfptran.qfp_tran_txt[12,20] > 0 THEN 
               LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = 
                   p_qfptran.qfp_tran_txt[12,20]
               LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = 
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
               LET p_ped_itens_qfp_547_vv.prz_entrega = 
                                            MDY(p_qfptran.qfp_tran_txt[6,7],
                                           p_qfptran.qfp_tran_txt[8,9], p_ano)
               LET qfptran_2.cod_freq_fornec = "000"  
               CALL pol0359_qfptran_verifica_frequencia()
               CALL pol0359_qfptran_grava_ped_itens_qfp_547_vv()
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
            OUTPUT TO REPORT pol0359_relat(1)
         ELSE 
            LET p_tot_registros = p_tot_registros + 1
            IF p_qfptran.qfp_tran_txt[29,37] > 0 THEN 
               LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = 
                   p_qfptran.qfp_tran_txt[29,37]
               LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = 
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
               LET p_ped_itens_qfp_547_vv.prz_entrega =
                                      MDY(p_qfptran.qfp_tran_txt[23,24],
                                          p_qfptran.qfp_tran_txt[25,26], p_ano)
               LET qfptran_2.cod_freq_fornec = "000"  
               CALL pol0359_qfptran_verifica_frequencia()
               CALL pol0359_qfptran_grava_ped_itens_qfp_547_vv()
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
            OUTPUT TO REPORT pol0359_relat(1)
         ELSE 
            LET p_tot_registros = p_tot_registros + 1
            IF p_qfptran.qfp_tran_txt[46,54] > 0 THEN 
               LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = 
                   p_qfptran.qfp_tran_txt[46,54]
               LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = 
                   p_qfptran.qfp_tran_txt[46,54]

               IF p_qfptran.qfp_tran_txt[42,43] > 0 THEN 
               ELSE 
                  LET p_qfptran.qfp_tran_txt[42,43] = 01
               END IF

               IF p_qfptran.qfp_tran_txt[38,39] >= "00" AND 
                  p_qfptran.qfp_tran_txt[39,39] <= "50" THEN 
                  LET p_seculo = "20"
               ELSE 
                  LET p_seculo = "19"
               END IF  
               LET p_ano = p_seculo, p_qfptran.qfp_tran_txt[38,39]
               LET p_ped_itens_qfp_547_vv.prz_entrega =
                                     MDY(p_qfptran.qfp_tran_txt[40,41],
                                         p_qfptran.qfp_tran_txt[42,43], p_ano)
               LET qfptran_2.cod_freq_fornec = "000"  
               CALL pol0359_qfptran_verifica_frequencia()
               CALL pol0359_qfptran_grava_ped_itens_qfp_547_vv()
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
            OUTPUT TO REPORT pol0359_relat(1)
         ELSE 
            LET p_tot_registros = p_tot_registros + 1
            IF p_qfptran.qfp_tran_txt[63,71] > 0 THEN 
               LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = 
                   p_qfptran.qfp_tran_txt[63,71]
               LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = 
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
               LET p_ped_itens_qfp_547_vv.prz_entrega = 
                                   MDY(p_qfptran.qfp_tran_txt[57,58],
                                       p_qfptran.qfp_tran_txt[59,60], p_ano)
               LET qfptran_2.cod_freq_fornec = "000"  
	             CALL pol0359_qfptran_verifica_frequencia()
               CALL pol0359_qfptran_grava_ped_itens_qfp_547_vv()
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
            OUTPUT TO REPORT pol0359_relat(1)
         ELSE 
            LET p_tot_registros = p_tot_registros + 1
            IF p_qfptran.qfp_tran_txt[80,88] > 0 THEN 
               LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = 
                   p_qfptran.qfp_tran_txt[80,88]
               LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = 
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
               LET p_ped_itens_qfp_547_vv.prz_entrega = 
                                   MDY(p_qfptran.qfp_tran_txt[74,75],
                                       p_qfptran.qfp_tran_txt[76,77], p_ano)
               LET qfptran_2.cod_freq_fornec = "000"  
               CALL pol0359_qfptran_verifica_frequencia()
               CALL pol0359_qfptran_grava_ped_itens_qfp_547_vv()
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
           OUTPUT TO REPORT pol0359_relat(1)
        ELSE 
           LET p_tot_registros = p_tot_registros + 1
           IF p_qfptran.qfp_tran_txt[97,105] > 0 THEN 
              LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = 
                  p_qfptran.qfp_tran_txt[97,105]
              LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = 
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
              LET p_ped_itens_qfp_547_vv.prz_entrega = 
                                  MDY(p_qfptran.qfp_tran_txt[91,92],
                                      p_qfptran.qfp_tran_txt[93,94], p_ano)
              LET qfptran_2.cod_freq_fornec = "000"  
              CALL pol0359_qfptran_verifica_frequencia()
              CALL pol0359_qfptran_grava_ped_itens_qfp_547_vv()
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
           OUTPUT TO REPORT pol0359_relat(1)
        ELSE 
           LET p_tot_registros = p_tot_registros + 1
           IF p_qfptran.qfp_tran_txt[114,122] > 0 THEN 
              LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = 
                  p_qfptran.qfp_tran_txt[114,122]
              LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = 
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
              LET p_ped_itens_qfp_547_vv.prz_entrega = 
                                  MDY(p_qfptran.qfp_tran_txt[108,109],
                                      p_qfptran.qfp_tran_txt[110,111], p_ano)
              LET qfptran_2.cod_freq_fornec = "000"  
              CALL pol0359_qfptran_verifica_frequencia()
              CALL pol0359_qfptran_grava_ped_itens_qfp_547_vv()
           ELSE 
              LET p_zerados  = p_zerados + 1
           END IF
        END IF
     END IF
  END IF
END FUNCTION 


#----------------------------------------------------#
FUNCTION pol0359_verifica_ped_itens_reserva_romaneio()
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
FUNCTION pol0359_insert_tpol0359_1()
#----------------------------------#

   LET p_num_ped_temp = qfptran_1.pedido

   IF pol0359_verifica_tpol0359_1() = FALSE THEN 
      INSERT INTO tpol0359_1 VALUES (qfptran_1.pedido)
      IF sqlca.sqlcode <> 0 THEN 
         IF sqlca.sqlcode <> -239 THEN 
            CALL log003_err_sql("INCLUSAO","Tpol0359_1")
         END IF
      END IF
   END IF
END FUNCTION

#------------------------------------#
FUNCTION pol0359_verifica_frequencia()
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
FUNCTION pol0359_qfptran_verifica_frequencia()
#--------------------------------------------#
   IF WEEKDAY(p_ped_itens_qfp_547_vv.prz_entrega) = 6 THEN 
      LET p_ped_itens_qfp_547_vv.prz_entrega = p_ped_itens_qfp_547_vv.prz_entrega + 2
   END IF
   IF WEEKDAY(p_ped_itens_qfp_547_vv.prz_entrega) = 0 THEN 
      LET p_ped_itens_qfp_547_vv.prz_entrega = p_ped_itens_qfp_547_vv.prz_entrega + 1
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
   END IF

   IF qfptran_2.cod_freq_fornec = "20" OR
      qfptran_2.cod_freq_fornec = "21" THEN 
      LET p_dia_semana = 1
      CALL pol0359_frequencia_20_a_25()
   END IF
   IF qfptran_2.cod_freq_fornec = "22" THEN 
      LET p_dia_semana = 2
      CALL pol0359_frequencia_20_a_25()
   END IF
   IF qfptran_2.cod_freq_fornec = "23" THEN 
      LET p_dia_semana = 3
      CALL pol0359_frequencia_20_a_25()
   END IF
   IF qfptran_2.cod_freq_fornec = "24" THEN 
      LET p_dia_semana = 4
      CALL pol0359_frequencia_20_a_25()
   END IF
   IF qfptran_2.cod_freq_fornec = "25" THEN 
      LET p_dia_semana = 5
      CALL pol0359_frequencia_20_a_25()
   END IF

   LET p_saldo          = 0
   LET p_qtd_solic_nova = p_ped_itens_qfp_547_vv.qtd_solic_nova
   LET p_prz_entrega    = p_ped_itens_qfp_547_vv.prz_entrega

   IF qfptran_2.cod_freq_fornec = "11" THEN 
      LET p_qtd_solic_int = p_ped_itens_qfp_547_vv.qtd_solic_nova / 5
      LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = p_qtd_solic_int
      LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = p_qtd_solic_int
      LET p_dia_semana = 1
      CALL pol0359_frequencia_11()
      LET p_saldo      = p_saldo + p_ped_itens_qfp_547_vv.qtd_solic_nova 
      LET p_dia_semana = 2
      CALL pol0359_frequencia_11()
      LET p_saldo      = p_saldo + p_ped_itens_qfp_547_vv.qtd_solic_nova 
      LET p_dia_semana = 3
      CALL pol0359_frequencia_11()
      LET p_saldo      = p_saldo + p_ped_itens_qfp_547_vv.qtd_solic_nova 
      LET p_dia_semana = 4
      CALL pol0359_frequencia_11()
      LET p_saldo      = p_saldo + p_ped_itens_qfp_547_vv.qtd_solic_nova 
      LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = p_qtd_solic_nova - p_saldo
      LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = p_qtd_solic_nova - p_saldo
      LET p_dia_semana = 5
   END IF

   IF qfptran_2.cod_freq_fornec = "26" THEN 
      LET p_qtd_solic_int = p_ped_itens_qfp_547_vv.qtd_solic_nova / 3
      LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = p_qtd_solic_int
      LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = p_qtd_solic_int
      LET p_dia_semana = 1
      CALL pol0359_frequencia_26_a_29()
      LET p_saldo      = p_saldo + p_ped_itens_qfp_547_vv.qtd_solic_nova 
      LET p_dia_semana = 3
      CALL pol0359_frequencia_26_a_29()
      LET p_saldo      = p_saldo + p_ped_itens_qfp_547_vv.qtd_solic_nova 
      LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = p_qtd_solic_nova - p_saldo
      LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = p_qtd_solic_nova - p_saldo
      LET p_dia_semana = 5
   END IF
   IF qfptran_2.cod_freq_fornec = "27" THEN 
      LET p_qtd_solic_int = p_ped_itens_qfp_547_vv.qtd_solic_nova / 2
      LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = p_qtd_solic_int
      LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = p_qtd_solic_int
      LET p_dia_semana = 1
      CALL pol0359_frequencia_26_a_29()
      LET p_saldo      = p_saldo + p_ped_itens_qfp_547_vv.qtd_solic_nova 
      LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = p_qtd_solic_nova - p_saldo
      LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = p_qtd_solic_nova - p_saldo
      LET p_dia_semana = 3
   END IF
   IF qfptran_2.cod_freq_fornec = "28" THEN 
      LET p_qtd_solic_int = p_ped_itens_qfp_547_vv.qtd_solic_nova / 2
      LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = p_qtd_solic_int
      LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = p_qtd_solic_int
      LET p_dia_semana = 2
      CALL pol0359_frequencia_26_a_29()
      LET p_saldo      = p_saldo + p_ped_itens_qfp_547_vv.qtd_solic_nova 
      LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = p_qtd_solic_nova - p_saldo
      LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = p_qtd_solic_nova - p_saldo
      LET p_dia_semana = 4
   END IF
   IF qfptran_2.cod_freq_fornec = "29" THEN 
      LET p_qtd_solic_int = p_ped_itens_qfp_547_vv.qtd_solic_nova / 2
      LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = p_qtd_solic_int
      LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = p_qtd_solic_int
      LET p_dia_semana = 3
      CALL pol0359_frequencia_26_a_29()
      LET p_saldo      = p_saldo + p_ped_itens_qfp_547_vv.qtd_solic_nova 
      LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = p_qtd_solic_nova - p_saldo
      LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = p_qtd_solic_nova - p_saldo
      LET p_dia_semana = 5
   END IF

   IF qfptran_2.cod_freq_fornec = "11" OR 
      qfptran_2.cod_freq_fornec = "26" OR 
      qfptran_2.cod_freq_fornec = "27" OR 
      qfptran_2.cod_freq_fornec = "28" OR 
      qfptran_2.cod_freq_fornec = "29" THEN 

      SELECT semana_mes
        INTO p_tpol0359.semana_mes
        FROM tpol0359
       WHERE data = p_prz_entrega
   ELSE 
      
      SELECT semana_mes
        INTO p_tpol0359.semana_mes
        FROM tpol0359
       WHERE data = p_ped_itens_qfp_547_vv.prz_entrega
   END IF

   IF qfptran_2.cod_freq_fornec = "40" THEN 
      LET p_tpol0359.semana_mes = 1
      LET p_dia_semana         = 5
   END IF
   IF qfptran_2.cod_freq_fornec = "41" THEN 
      LET p_tpol0359.semana_mes = 1
      LET p_dia_semana         = 5
   END IF
   IF qfptran_2.cod_freq_fornec = "42" THEN 
      LET p_tpol0359.semana_mes = 2
      LET p_dia_semana         = 5
   END IF
   IF qfptran_2.cod_freq_fornec = "43" THEN 
      LET p_tpol0359.semana_mes = 3
      LET p_dia_semana         = 5
   END IF
   IF qfptran_2.cod_freq_fornec = "44" THEN 
      LET p_tpol0359.semana_mes = 4
      LET p_dia_semana         = 3
   END IF

   IF pol0359_pesquisa_tpol0359() THEN 
   ELSE 
      IF qfptran_2.cod_freq_fornec = "26" OR 
         qfptran_2.cod_freq_fornec = "27" OR 
         qfptran_2.cod_freq_fornec = "28" OR 
         qfptran_2.cod_freq_fornec = "29" THEN 
         IF p_tpol0359.semana_mes = 1 THEN 
            CALL pol0359_seleciona_26_a_29_maior()
         ELSE 
            IF p_tpol0359.semana_mes > 4 THEN 
               CALL pol0359_seleciona_26_a_29_menor()
            END IF
         END IF
      ELSE 
         IF qfptran_2.cod_freq_fornec = "11" THEN 
            IF p_tpol0359.semana_mes = 1 THEN 
               CALL pol0359_seleciona_11_maior()
            ELSE 
               IF p_tpol0359.semana_mes > 4 THEN 
                  CALL pol0359_seleciona_11_menor()
               END IF
            END IF
         ELSE 
            IF p_tpol0359.semana_mes = 1 THEN 
               LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
            ELSE 
               IF p_tpol0359.semana_mes > 4 THEN 
                  LET p_tpol0359.semana_mes = p_tpol0359.semana_mes - 1
               END IF
            END IF
         END IF
      END IF
      IF pol0359_pesquisa_tpol0359() THEN 
      ELSE 
      END IF
   END IF
END FUNCTION


#---------------------------------------------------------------------#
 FUNCTION pol0359_frequencia_11()
#---------------------------------------------------------------------#
  SELECT semana_mes
    INTO p_tpol0359.semana_mes
    FROM tpol0359
   WHERE data = p_prz_entrega

  IF   pol0359_pesquisa_tpol0359()
  THEN 
  ELSE IF   p_tpol0359.semana_mes = 1
       THEN CALL pol0359_seleciona_11_maior()
       ELSE IF   p_tpol0359.semana_mes > 4
            THEN CALL pol0359_seleciona_11_menor()
            END IF
       END IF
       IF   pol0359_pesquisa_tpol0359()
       THEN 
       ELSE 
       END IF
  END IF

  CALL pol0359_qfptran_grava_ped_itens_qfp_547_vv()
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0359_seleciona_11_maior()
#---------------------------------------------------------------------#
  IF   p_dia_semana = 1
  THEN LET p_dia_semana = 2
       IF   pol0359_pesquisa_tpol0359()
       THEN 
       ELSE LET p_dia_semana = 3
            IF   pol0359_pesquisa_tpol0359()
            THEN 
            ELSE LET p_dia_semana = 4
                 IF   pol0359_pesquisa_tpol0359()
                 THEN 
                 ELSE LET p_dia_semana = 5
                      IF   pol0359_pesquisa_tpol0359()
                      THEN 
                      ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
                           LET p_dia_semana         = 1
                      END IF
                 END IF
            END IF
       END IF
  ELSE
       IF   p_dia_semana = 2
       THEN LET p_dia_semana = 3
            IF   pol0359_pesquisa_tpol0359()
            THEN 
            ELSE LET p_dia_semana = 4
                 IF   pol0359_pesquisa_tpol0359()
                 THEN 
                 ELSE LET p_dia_semana = 5
                      IF   pol0359_pesquisa_tpol0359()
                      THEN 
                      ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
                           LET p_dia_semana         = 1
                      END IF
                 END IF
            END IF
       ELSE
            IF   p_dia_semana = 3
            THEN LET p_dia_semana = 4
                 IF   pol0359_pesquisa_tpol0359()
                 THEN 
                 ELSE LET p_dia_semana = 5
                      IF   pol0359_pesquisa_tpol0359()
                      THEN 
                      ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
                           LET p_dia_semana         = 1
                      END IF
                 END IF
            ELSE
                 IF   p_dia_semana = 4
                 THEN LET p_dia_semana = 5
                      IF   pol0359_pesquisa_tpol0359()
                      THEN 
                      ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
                           LET p_dia_semana         = 1
                      END IF
                 ELSE
                      LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
                      LET p_dia_semana         = 1
                 END IF
            END IF
       END IF
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0359_seleciona_11_menor()
#---------------------------------------------------------------------#
  IF   p_dia_semana = 5
  THEN LET p_dia_semana = 4
       IF   pol0359_pesquisa_tpol0359()
       THEN 
       ELSE LET p_dia_semana = 3
            IF   pol0359_pesquisa_tpol0359()
            THEN 
            ELSE LET p_dia_semana = 2
                 IF   pol0359_pesquisa_tpol0359()
                 THEN 
                 ELSE LET p_dia_semana = 1
                      IF   pol0359_pesquisa_tpol0359()
                      THEN 
                      ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes - 1
                           LET p_dia_semana         = 5
                      END IF
                 END IF
            END IF
       END IF
  ELSE
       IF   p_dia_semana = 4
       THEN LET p_dia_semana = 3
            IF   pol0359_pesquisa_tpol0359()
            THEN 
            ELSE LET p_dia_semana = 2
                 IF   pol0359_pesquisa_tpol0359()
                 THEN 
                 ELSE LET p_dia_semana = 1
                      IF   pol0359_pesquisa_tpol0359()
                      THEN 
                      ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes - 1
                           LET p_dia_semana         = 5
                      END IF
                 END IF
            END IF
       ELSE
            IF   p_dia_semana = 3
            THEN LET p_dia_semana = 2
                 IF   pol0359_pesquisa_tpol0359()
                 THEN 
                 ELSE LET p_dia_semana = 1
                      IF   pol0359_pesquisa_tpol0359()
                      THEN 
                      ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes - 1
                           LET p_dia_semana         = 5
                      END IF
                 END IF
            ELSE
                 IF   p_dia_semana = 2
                 THEN LET p_dia_semana = 1
                      IF   pol0359_pesquisa_tpol0359()
                      THEN 
                      ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes - 1
                           LET p_dia_semana         = 5
                      END IF
                 ELSE
                      LET p_tpol0359.semana_mes = p_tpol0359.semana_mes - 1
                      LET p_dia_semana         = 5
                 END IF
            END IF
       END IF
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0359_frequencia_20_a_25()
#---------------------------------------------------------------------#
  SELECT semana_mes
    INTO p_tpol0359.semana_mes
    FROM tpol0359
   WHERE data = p_ped_itens_qfp_547_vv.prz_entrega

  SELECT dia_semana
    INTO p_tpol0359.dia_semana
    FROM tpol0359
   WHERE data = p_ped_itens_qfp_547_vv.prz_entrega

  IF   p_tpol0359.dia_semana = 0
    OR p_tpol0359.dia_semana = 6
  THEN RETURN
  END IF

  IF   p_tpol0359.dia_semana > p_dia_semana
  THEN RETURN
  END IF

  IF   pol0359_pesquisa_tpol0359()
  THEN 
  ELSE LET p_data_ant = p_ped_itens_qfp_547_vv.prz_entrega
       FOR p_ind = 1 TO 5
           IF   MONTH(p_ped_itens_qfp_547_vv.prz_entrega + 1) <> MONTH(p_data_ant)
           THEN EXIT FOR
           ELSE LET p_ped_itens_qfp_547_vv.prz_entrega =
                    p_ped_itens_qfp_547_vv.prz_entrega + 1
           END IF
       END FOR
       SELECT dia_semana
         INTO p_dia_semana
         FROM tpol0359
        WHERE data = p_ped_itens_qfp_547_vv.prz_entrega
       IF   pol0359_pesquisa_tpol0359()
       THEN 
       ELSE #LET p_ped_itens_qfp_547_vv.prz_entrega = TODAY
       END IF
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0359_frequencia_26_a_29()
#---------------------------------------------------------------------#
  SELECT semana_mes
    INTO p_tpol0359.semana_mes
    FROM tpol0359
   WHERE data = p_prz_entrega

  IF   pol0359_pesquisa_tpol0359()
  THEN
  ELSE IF   p_tpol0359.semana_mes = 1
       THEN CALL pol0359_seleciona_26_a_29_maior()
       ELSE IF   p_tpol0359.semana_mes > 4
            THEN CALL pol0359_seleciona_26_a_29_menor()
            END IF
       END IF
       IF   pol0359_pesquisa_tpol0359()
       THEN 
       ELSE # LET p_ped_itens_qfp_547_vv.prz_entrega = TODAY
       END IF
  END IF

  CALL pol0359_qfptran_grava_ped_itens_qfp_547_vv()
END FUNCTION


#----------------------------------------#
FUNCTION pol0359_seleciona_26_a_29_maior()
#----------------------------------------#
  
   IF qfptran_2.cod_freq_fornec = "26" THEN 
      IF p_dia_semana = 1 THEN 
         LET p_dia_semana = 3
         IF pol0359_pesquisa_tpol0359() THEN 
         ELSE 
            LET p_dia_semana = 5
            IF pol0359_pesquisa_tpol0359() THEN 
            ELSE 
               LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
               LET p_dia_semana         = 1
            END IF
         END IF
      ELSE 
         IF p_dia_semana = 3 THEN 
            LET p_dia_semana = 5
            IF pol0359_pesquisa_tpol0359() THEN 
            ELSE 
               LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
               LET p_dia_semana         = 1
            END IF
         ELSE 
            LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
            LET p_dia_semana         = 1
         END IF
      END IF
   END IF
   IF qfptran_2.cod_freq_fornec = "27" THEN 
      IF p_dia_semana = 1 THEN 
         LET p_dia_semana = 3
         IF pol0359_pesquisa_tpol0359() THEN 
         ELSE 
            LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
            LET p_dia_semana         = 1
         END IF
      ELSE
         LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
         LET p_dia_semana         = 1
      END IF
   END IF
   IF qfptran_2.cod_freq_fornec = "28" THEN 
      IF p_dia_semana = 2 THEN 
         LET p_dia_semana = 4
         IF pol0359_pesquisa_tpol0359() THEN 
         ELSE 
            LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
            LET p_dia_semana         = 2
         END IF
      ELSE
         LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
         LET p_dia_semana         = 2
      END IF
   END IF
   IF qfptran_2.cod_freq_fornec = "29" THEN 
      IF p_dia_semana = 3 THEN 
         LET p_dia_semana = 5
         IF pol0359_pesquisa_tpol0359() THEN 
         ELSE 
            LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
            LET p_dia_semana         = 3
         END IF
      ELSE 
         LET p_tpol0359.semana_mes = p_tpol0359.semana_mes + 1
         LET p_dia_semana         = 3
      END IF
   END IF
END FUNCTION


#----------------------------------------#
FUNCTION pol0359_seleciona_26_a_29_menor()
#----------------------------------------#
  IF   qfptran_2.cod_freq_fornec = "26"
  THEN IF   p_dia_semana = 5
       THEN LET p_dia_semana = 3
            IF   pol0359_pesquisa_tpol0359()
            THEN 
            ELSE LET p_dia_semana = 1
                 IF   pol0359_pesquisa_tpol0359()
                 THEN 
                 ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes - 1
                      LET p_dia_semana         = 5
                 END IF
            END IF
       ELSE IF   p_dia_semana = 3
            THEN LET p_dia_semana = 1
                 IF   pol0359_pesquisa_tpol0359()
                 THEN 
                 ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes - 1
                      LET p_dia_semana         = 5
                 END IF
            ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes - 1
                 LET p_dia_semana         = 5
            END IF
       END IF
  END IF
  IF   qfptran_2.cod_freq_fornec = "27"
  THEN IF   p_dia_semana = 3
       THEN LET p_dia_semana = 1
            IF   pol0359_pesquisa_tpol0359()
            THEN 
            ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes - 1
                 LET p_dia_semana         = 3
            END IF
       ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes - 1
            LET p_dia_semana         = 3
       END IF
  END IF
  IF   qfptran_2.cod_freq_fornec = "28"
  THEN IF   p_dia_semana = 4
       THEN LET p_dia_semana = 2
            IF   pol0359_pesquisa_tpol0359()
            THEN 
            ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes - 1
                 LET p_dia_semana         = 4
            END IF
       ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes - 1
            LET p_dia_semana         = 4
       END IF
  END IF
  IF   qfptran_2.cod_freq_fornec = "29"
  THEN IF   p_dia_semana = 5
       THEN LET p_dia_semana = 3
            IF   pol0359_pesquisa_tpol0359()
            THEN 
            ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes - 1
                 LET p_dia_semana         = 5
            END IF
       ELSE LET p_tpol0359.semana_mes = p_tpol0359.semana_mes - 1
            LET p_dia_semana         = 5
       END IF
  END IF
END FUNCTION

#----------------------------------#
FUNCTION pol0359_pesquisa_tpol0359()
#----------------------------------#
   SELECT data
     INTO p_ped_itens_qfp_547_vv.prz_entrega
     FROM tpol0359
    WHERE MONTH(data) = MONTH(p_ped_itens_qfp_547_vv.prz_entrega)
      AND semana_mes  = p_tpol0359.semana_mes
      AND dia_semana  = p_dia_semana

   IF sqlca.sqlcode = 0 THEN 
      RETURN TRUE
   ELSE 
      RETURN FALSE
   END IF
END FUNCTION


#---------------------------------------------------#
FUNCTION pol0359_qfptran_grava_ped_itens_qfp_547_vv()
#---------------------------------------------------#
      LET p_ped_itens_qfp_547_vv.qtd_solic = 0
      LET p_ped_itens_qfp_547_vv.qtd_atend = 0
      CALL pol0359_gravar_ped_itens_qfp_547_vv()

   IF p_houve_erro = FALSE THEN 
      CALL log085_transacao("COMMIT")
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO-2","ped_itens_qfp_547_vv")
         CALL log085_transacao("ROLLBACK")
      ELSE 
         CALL log085_transacao("BEGIN")
      END IF
   ELSE 
      CALL log003_err_sql("INCLUSAO-3","ped_itens_qfp_547_vv")
      CALL log085_transacao("ROLLBACK")
   END IF
END FUNCTION


#-------------------------------------------------#
FUNCTION pol0359_qfptran_grava_pedidos_qfp_547_vv()
#-------------------------------------------------#
   DEFINE p_contador       SMALLINT

   LET p_contador = 0

   SELECT count(*)
     INTO p_contador
     FROM pedidos_qfp_547_vv
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido

   IF p_contador = 0 THEN 
      CALL pol0359_gravar_pedidos_qfp_547_vv()
   ELSE 
      DELETE 
        FROM pedidos_qfp_547_vv
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
      IF sqlca.sqlcode <> 0 THEN 
         LET p_houve_erro = TRUE
         CALL log003_err_sql("DELECAO-1 ","pedidos_qfp_547_vv")
         CALL log085_transacao("ROLLBACK")
      ELSE 
         CALL log085_transacao("COMMIT")
         IF sqlca.sqlcode <> 0 THEN 
            LET p_houve_erro = TRUE
            CALL log003_err_sql("DELECAO-2","pedidos_qfp_547_vv")
            CALL log085_transacao("ROLLBACK")
         ELSE 
            CALL log085_transacao("BEGIN")

            SELECT COUNT(*)
              INTO p_contador
              FROM ped_itens_qfp_547_vv
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
            IF p_contador > 0 THEN 
               DELETE 
                 FROM ped_itens_qfp_547_vv
                WHERE cod_empresa = p_cod_empresa
                  AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
               IF sqlca.sqlcode = 0 THEN 
                  CALL log085_transacao("COMMIT")
                  IF sqlca.sqlcode <> 0 THEN 
                     LET p_houve_erro = TRUE
                     CALL log003_err_sql("DELECAO-1","ped_itens_qfp_547_vv")
                     CALL log085_transacao("ROLLBACK")
                  ELSE 
                     CALL log085_transacao("BEGIN")
                  END IF
               ELSE 
                  LET p_houve_erro = TRUE
                  CALL log003_err_sql("DELECAO-2 ","ped_itens_qfp_547_vv")
                  CALL log085_transacao("ROLLBACK")
               END IF
            END IF 
       
            LET p_contador = 0 
            SELECT COUNT(*)
              INTO p_contador
              FROM ped_itens_qfp_pe5_547_vv
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
            IF p_contador > 0 THEN 
               DELETE 
                 FROM ped_itens_qfp_pe5_547_vv
                WHERE cod_empresa = p_cod_empresa
                  AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
               IF sqlca.sqlcode = 0 THEN 
                  CALL log085_transacao("COMMIT")
                  IF sqlca.sqlcode <> 0 THEN 
                     LET p_houve_erro = TRUE
                     CALL log003_err_sql("DELECAO-1","ped_itens_qfp_pe5_547_vv")
                     CALL log085_transacao("ROLLBACK")
                  ELSE 
                     CALL log085_transacao("BEGIN")
                  END IF
               ELSE 
                  LET p_houve_erro = TRUE
                  CALL log003_err_sql("DELECAO-2 ","ped_itens_qfp_pe5_547_vv")
                  CALL log085_transacao("ROLLBACK")
               END IF
            END IF
            CALL pol0359_gravar_pedidos_qfp_547_vv()
         END IF
      END IF
   END IF

   IF p_houve_erro = FALSE THEN 
      CALL log085_transacao("COMMIT")
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INCLUSAO-2","pedidos_qfp_547_vv")
         CALL log085_transacao("ROLLBACK")
      ELSE 
         CALL log085_transacao("BEGIN")
      END IF
   ELSE 
      CALL log003_err_sql("INCLUSAO-3","pedidos_qfp_547_vv")
      CALL log085_transacao("ROLLBACK")
   END IF
END FUNCTION


#------------------------------------------#
FUNCTION pol0359_gravar_pedidos_qfp_547_vv()
#------------------------------------------#
   LET p_pedidos_qfp_547_vv.cod_empresa       = p_cod_empresa
   LET p_pedidos_qfp_547_vv.num_pedido        = p_ped_itens_qfp_547_vv.num_pedido
   LET p_pedidos_qfp_547_vv.num_prog_atual    = qfptran_1.prg_atual
   LET p_pedidos_qfp_547_vv.dat_prog_atual    = qfptran_1.dat_prg_atual
   LET p_pedidos_qfp_547_vv.num_prog_ant      = qfptran_1.prg_anterior

   IF qfptran_1.dat_prg_anterior > 0 THEN 
      LET p_pedidos_qfp_547_vv.dat_prog_ant = qfptran_1.dat_prg_anterior
   ELSE 
      LET p_pedidos_qfp_547_vv.dat_prog_ant = NULL
   END IF

   LET p_pedidos_qfp_547_vv.cod_frequencia    = qfptran_2.cod_freq_fornec
   LET p_pedidos_qfp_547_vv.num_nff_ult       = qfptran_2.num_ult_nf

   INSERT INTO pedidos_qfp_547_vv VALUES (p_pedidos_qfp_547_vv.*)
   IF sqlca.sqlcode <> 0 THEN 
      LET p_houve_erro = TRUE
      CALL log003_err_sql("INCLUSAO-1","pedidos_qfp_547_vv")
   END IF
END FUNCTION


#--------------------------------------------------------#
FUNCTION pol0359_ped_itens_qfp_547_vv_verifica_ped_itens()
#--------------------------------------------------------#
   CALL log085_transacao("BEGIN")
  
   LET p_houve_erro = FALSE

   INITIALIZE p_pedidos_qfp_547_vv.*, 
              p_ped_itens_qfp_547_vv.*, 
              p_ped_itens.*,
              p_cod_cliente         TO NULL

   DECLARE cp_ped_itens_qfp_547_vv CURSOR WITH HOLD FOR 
    SELECT *
      INTO p_ped_itens_qfp_547_vv.*
      FROM ped_itens_qfp_547_vv
     WHERE cod_empresa = p_cod_empresa
     ORDER BY num_pedido,
              num_sequencia,
              cod_item,
              prz_entrega

   FOREACH cp_ped_itens_qfp_547_vv
      CALL pol0359_ped_itens_atualiza_ped_itens_qfp_547_vv()
   END FOREACH
END FUNCTION


#--------------------------------------------------------#
FUNCTION pol0359_ped_itens_atualiza_ped_itens_qfp_547_vv()
#--------------------------------------------------------#
   DEFINE p_ies_qfp            CHAR(01)

   SELECT cod_cliente
     INTO p_cod_cliente
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido

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
       AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido 
       AND cod_item    = p_ped_itens_qfp_547_vv.cod_item
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

      SELECT ped_itens_qfp_547_vv.*
        INTO p_ped_itens_qfp_547_vv.*
        FROM ped_itens_qfp_547_vv
       WHERE cod_empresa   = p_cod_empresa   
         AND num_pedido    = p_ped_itens.num_pedido 
         AND cod_item      = p_ped_itens.cod_item
         AND prz_entrega   = p_ped_itens.prz_entrega
         AND num_seq_ped   = p_ped_itens.num_sequencia

      IF SQLCA.sqlcode = 0 THEN 
         LET p_ped_itens_qfp_547_vv.qtd_solic = p_ped_itens.qtd_pecas_solic - 
                                                p_ped_itens.qtd_pecas_atend - 
                                                p_ped_itens.qtd_pecas_cancel
 
         UPDATE ped_itens_qfp_547_vv
            SET qtd_solic = p_ped_itens_qfp_547_vv.qtd_solic
          WHERE cod_empresa   = p_cod_empresa   
            AND num_pedido    = p_ped_itens.num_pedido 
            AND cod_item      = p_ped_itens.cod_item
            AND prz_entrega   = p_ped_itens.prz_entrega
            AND num_seq_ped   = p_ped_itens.num_sequencia
         IF sqlca.sqlcode <> 0 THEN 
            LET p_houve_erro = TRUE
            CALL log003_err_sql("ATUALIZA-2","ped_itens_qfp_547_vv")
         END IF
      ELSE        
         LET p_ped_itens_qfp_547_vv.cod_empresa      = p_cod_empresa
         LET p_ped_itens_qfp_547_vv.num_pedido       = p_ped_itens.num_pedido
         LET p_ped_itens_qfp_547_vv.cod_item         = p_ped_itens.cod_item
         LET p_ped_itens_qfp_547_vv.prz_entrega      = p_ped_itens.prz_entrega
         LET p_ped_itens_qfp_547_vv.qtd_solic        = p_ped_itens.qtd_pecas_solic
                                                     - p_ped_itens.qtd_pecas_atend
                                                     - p_ped_itens.qtd_pecas_cancel  
         
         IF p_ies_qfp = "P"  THEN     {# PARCIAL - HONDA #} 
            LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = p_ped_itens_qfp_547_vv.qtd_solic
            LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = p_ped_itens_qfp_547_vv.qtd_solic
         ELSE 
            LET p_ped_itens_qfp_547_vv.qtd_solic_nova   = 0
            LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = 0
         END IF
         
         CALL pol0359_ped_itens_qfp_547_vv_num_sequencia()
         CALL pol0359_gravar_ped_itens_qfp_547_vv()
      END IF

      IF p_houve_erro = FALSE THEN 
         CALL log085_transacao("COMMIT")
         IF sqlca.sqlcode <> 0 THEN 
            CALL log003_err_sql("ATUALIZA-3","ped_itens_qfp_547_vv")
            CALL log085_transacao("ROLLBACK")
         ELSE 
            CALL log085_transacao("BEGIN")
         END IF                                              
      ELSE 
         CALL log085_transacao("ROLLBACK")
      END IF                                                   
   END FOREACH 
END FUNCTION

#---------------------------------------------------#
FUNCTION pol0359_ped_itens_qfp_547_vv_num_sequencia()
#---------------------------------------------------#
   SELECT MAX(num_sequencia)
     INTO p_ped_itens_qfp_547_vv.num_sequencia
     FROM ped_itens_qfp_547_vv
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
   IF p_ped_itens_qfp_547_vv.num_sequencia IS NULL THEN 
      LET p_ped_itens_qfp_547_vv.num_sequencia = 0
   END IF    

END FUNCTION

#--------------------------------------------#
FUNCTION pol0359_gravar_ped_itens_qfp_547_vv()
#--------------------------------------------#
   DEFINE l_cont_sq      SMALLINT,
          l_cont_sqf     SMALLINT,
          l_num_seq      SMALLINT,
          l_num_seq_p    SMALLINT,
          l_num_seq_pq   SMALLINT  
   
   LET l_cont_sq  =  0
   
   SELECT COUNT(*)
     INTO l_cont_sq
     FROM ped_itens 
    WHERE cod_empresa =  p_cod_empresa
      AND num_pedido  =  p_ped_itens_qfp_547_vv.num_pedido
      AND prz_entrega =  p_ped_itens_qfp_547_vv.prz_entrega  
   IF l_cont_sq  =  0 THEN                                   
      SELECT MAX(num_seq_ped)
        INTO l_num_seq_pq
        FROM ped_itens_qfp_547_vv 
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido

      SELECT MAX(num_sequencia)
        INTO l_num_seq_p
        FROM ped_itens 
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido

      IF l_num_seq_p IS NULL THEN 
         LET   l_num_seq_p = 0
      END IF 

      IF l_num_seq_pq IS NULL THEN 
         LET   l_num_seq_pq = 0
      END IF 
      IF l_num_seq_p > l_num_seq_pq THEN     
         LET  p_ped_itens_qfp_547_vv.num_seq_ped = l_num_seq_p + 1
      ELSE
         LET  p_ped_itens_qfp_547_vv.num_seq_ped = l_num_seq_pq + 1
      END IF    
   ELSE
      IF l_cont_sq  =  1 THEN
         LET  l_cont_sqf  = 0 
         SELECT COUNT(*)
           INTO l_cont_sqf
           FROM ped_itens_qfp_547_vv 
          WHERE cod_empresa =  p_cod_empresa
            AND num_pedido  =  p_ped_itens_qfp_547_vv.num_pedido
            AND prz_entrega =  p_ped_itens_qfp_547_vv.prz_entrega  
         IF l_cont_sqf  =  0 THEN      
            SELECT num_sequencia 
              INTO p_ped_itens_qfp_547_vv.num_seq_ped
              FROM ped_itens 
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
               AND prz_entrega = p_ped_itens_qfp_547_vv.prz_entrega  
         ELSE
            SELECT MAX(num_seq_ped)
              INTO l_num_seq_pq
              FROM ped_itens_qfp_547_vv 
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
            
            SELECT MAX(num_sequencia)
              INTO l_num_seq_p
              FROM ped_itens 
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
            
            IF l_num_seq_p IS NULL THEN 
               LET   l_num_seq_p = 0
            END IF 
            
            IF l_num_seq_pq IS NULL THEN 
               LET   l_num_seq_pq = 0
            END IF 
            IF l_num_seq_p > l_num_seq_pq THEN     
               LET  p_ped_itens_qfp_547_vv.num_seq_ped = l_num_seq_p + 1
            ELSE
               LET  p_ped_itens_qfp_547_vv.num_seq_ped = l_num_seq_pq + 1
            END IF    
         END IF      
      ELSE
         LET p_ped_itens_qfp_547_vv.num_seq_ped = 0
         SELECT MAX(num_seq_ped)
           INTO p_ped_itens_qfp_547_vv.num_seq_ped
           FROM ped_itens_qfp_547_vv 
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
            AND prz_entrega = p_ped_itens_qfp_547_vv.prz_entrega
         IF p_ped_itens_qfp_547_vv.num_seq_ped IS NULL OR 
            p_ped_itens_qfp_547_vv.num_seq_ped = 0 THEN
            LET p_ped_itens_qfp_547_vv.num_seq_ped = 0 
         END IF    
         
         LET l_num_seq = 0 
         DECLARE cq_pd_it_sq1 CURSOR FOR 
           SELECT num_sequencia 
             FROM ped_itens 
            WHERE cod_empresa = p_cod_empresa
              AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido
              AND prz_entrega = p_ped_itens_qfp_547_vv.prz_entrega
              AND num_sequencia > p_ped_itens_qfp_547_vv.num_seq_ped
            ORDER BY num_sequencia  
         FOREACH cq_pd_it_sq1 INTO l_num_seq
              LET p_ped_itens_qfp_547_vv.num_seq_ped = l_num_seq  
              EXIT FOREACH 
         END FOREACH
         IF l_num_seq = 0 OR 
            l_num_seq IS NULL  THEN  
            SELECT MAX(num_sequencia)
              INTO l_num_seq_p
              FROM ped_itens 
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido

            SELECT MAX(num_seq_ped)
              INTO l_num_seq_pq
              FROM ped_itens_qfp_547_vv 
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido

            IF l_num_seq_p > l_num_seq_pq THEN     
               LET  p_ped_itens_qfp_547_vv.num_seq_ped = l_num_seq_p + 1
            ELSE
               LET  p_ped_itens_qfp_547_vv.num_seq_ped = l_num_seq_pq + 1
            END IF    
         END IF 
      END IF
   END IF       
   
   LET p_ped_itens_qfp_547_vv.num_sequencia = p_ped_itens_qfp_547_vv.num_sequencia + 1

   INSERT INTO ped_itens_qfp_547_vv VALUES (p_ped_itens_qfp_547_vv.*)

   IF sqlca.sqlcode <> 0 THEN 
      LET p_houve_erro = TRUE
      CALL log003_err_sql("INCLUSAO-1","ped_itens_qfp_547_vv")
   END IF
END FUNCTION

#--------------------------------------------------#
FUNCTION pol0359_ped_itens_qfp_547_vv_verifica_nff()
#--------------------------------------------------#
   CALL log085_transacao("BEGIN")
  
   LET p_houve_erro = FALSE
   LET p_saldo          = 0
   LET p_num_pedido_ant = 0
   
   INITIALIZE p_pedidos_qfp_547_vv.*, p_ped_itens_qfp_547_vv.*, p_ped_itens.*,
              p_cod_cliente TO NULL

   DECLARE cp_peditem_saldo CURSOR WITH HOLD FOR 
    SELECT *
      FROM ped_itens_qfp_547_vv
     WHERE cod_empresa      = p_cod_empresa
       AND qtd_solic_nova   > 0
       AND qtd_solic_aceita > 0
     ORDER BY num_pedido,
              num_sequencia,
              cod_item,
              prz_entrega

   FOREACH cp_peditem_saldo INTO p_ped_itens_qfp_547_vv.*
      LET p_num_ped_temp = p_ped_itens_qfp_547_vv.num_pedido
      IF pol0359_verifica_tpol0359_1() THEN
      ELSE 
         CONTINUE FOREACH
      END IF

      IF p_ped_itens_qfp_547_vv.num_pedido <> p_num_pedido_ant THEN 
         CALL pol0359_ped_itens_qfp_547_vv_verifica_pedidos_qfp_547_vv()
         CALL pol0359_verifica_nf()
         LET p_num_pedido_ant = p_ped_itens_qfp_547_vv.num_pedido
      END IF

      LET p_saldo = p_saldo
                  + p_ped_itens_qfp_547_vv.qtd_solic_nova
                # + p_ped_itens_qfp_547_vv.qtd_solic_aceita
                # + p_ped_itens_qfp_547_vv.qtd_atend
                
      IF p_saldo > 0 THEN 
         LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = p_saldo
         LET p_saldo                          = 0
      ELSE 
         LET p_ped_itens_qfp_547_vv.qtd_solic_aceita = 0
      END IF

      UPDATE ped_itens_qfp_547_vv
         SET qtd_solic_aceita = p_ped_itens_qfp_547_vv.qtd_solic_aceita
       WHERE ped_itens_qfp_547_vv.cod_empresa   = p_cod_empresa
         AND ped_itens_qfp_547_vv.num_pedido    = p_ped_itens_qfp_547_vv.num_pedido
         AND ped_itens_qfp_547_vv.cod_item      = p_ped_itens_qfp_547_vv.cod_item
         AND ped_itens_qfp_547_vv.prz_entrega   = p_ped_itens_qfp_547_vv.prz_entrega

      IF sqlca.sqlcode <> 0 THEN 
         LET p_houve_erro = TRUE
         CALL log003_err_sql("ATUALIZA-6","ped_itens_qfp_547_vv")
      END IF
   END FOREACH
END FUNCTION

#------------------------------------#
FUNCTION pol0359_verifica_tpol0359_1()
#------------------------------------#
   SELECT *
     FROM tpol0359_1
    WHERE num_pedido = p_num_ped_temp

   IF sqlca.sqlcode = 0 THEN 
      RETURN TRUE
   ELSE 
      RETURN FALSE
   END IF
END FUNCTION

#-----------------------------------------------------------------#
FUNCTION pol0359_ped_itens_qfp_547_vv_verifica_pedidos_qfp_547_vv()
#-----------------------------------------------------------------#
   LET p_dat_emissao = 0

   SELECT num_nff_ult
     INTO p_pedidos_qfp_547_vv.num_nff_ult
     FROM pedidos_qfp_547_vv
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido

   IF SQLCA.SQLCODE <> 0 OR 
      p_pedidos_qfp_547_vv.num_nff_ult IS NULL THEN 
      SELECT MAX(NUM_NFF) 
        INTO p_pedidos_qfp_547_vv.num_nff_ult
        FROM nf_item 
       WHERE cod_empresa =  p_cod_empresa
         AND cod_item = p_ped_itens_qfp_547_vv.cod_item
      IF SQLCA.sqlcode <> 0 THEN 
         LET p_pedidos_qfp_547_vv.num_nff_ult = 0 
      END IF 
   END IF          

   SELECT cod_cliente
     INTO p_cod_cliente
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_itens_qfp_547_vv.num_pedido

   SELECT dat_emissao
     INTO p_dat_emissao
     FROM nf_mestre
    WHERE cod_empresa = p_cod_empresa
      AND num_nff     = p_pedidos_qfp_547_vv.num_nff_ult
END FUNCTION

#----------------------------#
FUNCTION pol0359_verifica_nf()
#----------------------------#
  DEFINE p_cod_tip_carteira   LIKE item_vdp.cod_tip_carteira

  LET p_qtd_item = 0

  IF p_pedidos_qfp_547_vv.num_nff_ult IS NULL THEN 
     LET p_qtd_item = 0 
  ELSE      
     SELECT cod_tip_carteira
       INTO p_cod_tip_carteira
       FROM item_vdp
      WHERE item_vdp.cod_empresa = p_cod_empresa
        AND item_vdp.cod_item    = p_ped_itens_qfp_547_vv.cod_item
     
     
     
     SELECT SUM(nf_item.qtd_item)
       INTO p_qtd_item
       FROM nf_mestre, nf_item, nat_operacao
      WHERE nf_mestre.cod_empresa         = p_cod_empresa
        AND nf_mestre.cod_cliente         = p_cod_cliente
        AND nf_mestre.ies_situacao        = "N"
        AND nf_mestre.cod_tip_carteira    = p_cod_tip_carteira
        AND nf_mestre.num_nff             >  p_pedidos_qfp_547_vv.num_nff_ult
        AND nf_mestre.dat_emissao         >= p_dat_emissao
        AND nf_mestre.cod_nat_oper        = nat_operacao.cod_nat_oper
        AND (nat_operacao.ies_estatistica = "T"
         OR  nat_operacao.ies_estatistica = "Q")
        AND nf_mestre.cod_empresa         = nf_item.cod_empresa
        AND nf_mestre.num_nff             = nf_item.num_nff
        AND nf_item.num_pedido            = p_ped_itens_qfp_547_vv.num_pedido
        AND nf_item.cod_item              = p_ped_itens_qfp_547_vv.cod_item
     
     IF STATUS <> 0 THEN
        LET p_qtd_item = 0
     END IF
     
     
     
  END IF 
  
  IF   p_qtd_item IS NULL
  THEN LET p_qtd_item = 0
  END IF

  LET p_saldo = p_qtd_item * (- 1)
  
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0359_deleta_qfptran()
#---------------------------------------------------------------------#
     
     CALL log085_transacao("BEGIN")

     DELETE FROM qfptran 

     IF   sqlca.sqlcode = 0 THEN
          CALL log085_transacao("COMMIT")
          IF   sqlca.sqlcode <> 0
          THEN CALL log003_err_sql("DELECAO-1","QFPTRAN")
               CALL log085_transacao("ROLLBACK")
          END IF
     ELSE CALL log003_err_sql("DELECAO-2","QFPTRAN")
          CALL log085_transacao("ROLLBACK")
     END IF
     
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION pol0359_lista_relat()
#---------------------------------------------------------------------#
  LET p_imprimir = "NAO"
  
  IF   log028_saida_relat(16,37) IS NOT NULL
  THEN LET p_imprimir = "SIM"
       IF g_ies_ambiente = "W"
       THEN IF p_ies_impressao = "S"
            THEN START REPORT pol0359_relat TO PRINTER
            ELSE START REPORT pol0359_relat TO p_nom_arquivo
            END IF
       ELSE 
            IF p_ies_impressao = "S"
            THEN START REPORT pol0359_relat TO PIPE p_nom_arquivo
            ELSE START REPORT pol0359_relat TO p_nom_arquivo
            END IF
       END IF
  ELSE LET p_imprimir = "NAO"
  END IF
END FUNCTION

#--------------------------#
REPORT pol0359_relat(l_tipo)
#--------------------------#
   DEFINE l_tipo           CHAR(01),
          l_for            SMALLINT 

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1

  FORMAT
    PAGE HEADER
      PRINT COLUMN   1, p_den_empresa
      PRINT COLUMN   1, "pol0359",
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

      OTHERWISE
         PRINT COLUMN 1, "IDENT. PROGRAMA => ",
                             p_tp_prg1,",",p_tp_prg2,",",p_tp_prg3,",",p_tp_prg4,",",p_tp_prg5,",",p_tp_prg6,",",p_tp_prg7
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
FUNCTION pol0359_gera_tabela_edi_pe1(l_status)
#--------------------------------------------#
   DEFINE l_status    SMALLINT 

   INITIALIZE p_pedidos_edi_pe1_547_vv.*  TO NULL 

   LET p_pedidos_edi_pe1_547_vv.cod_empresa        = p_cod_empresa
   LET p_pedidos_edi_pe1_547_vv.num_pedido         = qfptran_1.pedido
   LET p_pedidos_edi_pe1_547_vv.cod_fabr_dest      = p_qfptran.qfp_tran_txt[4,6]
   LET p_pedidos_edi_pe1_547_vv.identif_prog_atual = p_qfptran.qfp_tran_txt[7,15]
   LET p_pedidos_edi_pe1_547_vv.dat_prog_atual     = qfptran_1.dat_prg_atual #[16,21]
   LET p_pedidos_edi_pe1_547_vv.identif_prog_ant   = p_qfptran.qfp_tran_txt[22,30]
   LET p_pedidos_edi_pe1_547_vv.dat_prog_anterior  = qfptran_1.dat_prg_anterior #[31,36] 
   LET p_pedidos_edi_pe1_547_vv.cod_item_cliente   = p_qfptran.qfp_tran_txt[37,66]
   LET p_pedidos_edi_pe1_547_vv.cod_item           = qfptran_1.item_fornecedor #[67,96]
   LET p_pedidos_edi_pe1_547_vv.num_pedido_compra  = p_qfptran.qfp_tran_txt[97,106]
   LET p_pedidos_edi_pe1_547_vv.cod_local_destino  = p_qfptran.qfp_tran_txt[109,113]
   LET p_pedidos_edi_pe1_547_vv.nom_contato        = p_qfptran.qfp_tran_txt[114,124]
   LET p_pedidos_edi_pe1_547_vv.cod_unid_med       = p_qfptran.qfp_tran_txt[125,126]
   LET p_pedidos_edi_pe1_547_vv.qtd_casas_decimais = p_qfptran.qfp_tran_txt[127,127]
   LET p_pedidos_edi_pe1_547_vv.cod_tip_fornec     = p_qfptran.qfp_tran_txt[128,128]

   IF l_status = 1 THEN
      RETURN
   END IF 

   DELETE
     FROM pedidos_edi_pe1_547_vv
    WHERE cod_empresa    = p_cod_empresa
      AND num_pedido     = qfptran_1.pedido
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","pedidos_edi_pe1_547_vv")
      RETURN 
   END IF 

   INSERT INTO pedidos_edi_pe1_547_vv VALUES (p_pedidos_edi_pe1_547_vv.*)
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","pedidos_edi_pe1_547_vv")
   END IF
END FUNCTION


#--------------------------------------------#
FUNCTION pol0359_gera_tabela_edi_pe2(l_status)
#--------------------------------------------#
   DEFINE l_status    SMALLINT   

   INITIALIZE p_pedidos_edi_pe2_547_vv.*  TO NULL

   LET p_pedidos_edi_pe2_547_vv.cod_empresa        = p_cod_empresa
   LET p_pedidos_edi_pe2_547_vv.num_pedido         = qfptran_1.pedido

   IF p_qfptran.qfp_tran_txt[4,5] >= "00" AND
      p_qfptran.qfp_tran_txt[4,5] <= "50" THEN
      LET p_seculo = "20"
   ELSE
      LET p_seculo = "19"
   END IF
   LET p_ano = p_seculo, p_qfptran.qfp_tran_txt[4,5]  
   LET p_pedidos_edi_pe2_547_vv.dat_ult_embar  = MDY(p_qfptran.qfp_tran_txt[6,7],
                                          p_qfptran.qfp_tran_txt[8,9],p_ano)

   LET p_pedidos_edi_pe2_547_vv.num_ult_nff    = p_qfptran.qfp_tran_txt[10,15]
   LET p_pedidos_edi_pe2_547_vv.ser_ult_nff    = p_qfptran.qfp_tran_txt[16,19]

   IF p_qfptran.qfp_tran_txt[20,21] >= "00" AND
      p_qfptran.qfp_tran_txt[20,21] <= "50" THEN
      LET p_seculo = "20"
   ELSE
      LET p_seculo = "19"
   END IF
   LET p_ano = p_seculo, p_qfptran.qfp_tran_txt[20,21]  
   LET p_pedidos_edi_pe2_547_vv.dat_rec_ult_nff  = MDY(p_qfptran.qfp_tran_txt[22,23],
                                            p_qfptran.qfp_tran_txt[24,25],p_ano)
   LET p_pedidos_edi_pe2_547_vv.qtd_recebido       = p_qfptran.qfp_tran_txt[26,37]
   LET p_pedidos_edi_pe2_547_vv.qtd_receb_acum     = p_qfptran.qfp_tran_txt[38,51]
   LET p_pedidos_edi_pe2_547_vv.qtd_lote_minimo    = p_qfptran.qfp_tran_txt[66,77]
   LET p_pedidos_edi_pe2_547_vv.cod_freq_fornec    = p_qfptran.qfp_tran_txt[78,80]
   LET p_pedidos_edi_pe2_547_vv.dat_lib_producao   = p_qfptran.qfp_tran_txt[81,84]
   LET p_pedidos_edi_pe2_547_vv.dat_lib_mat_prima  = p_qfptran.qfp_tran_txt[85,88]
   LET p_pedidos_edi_pe2_547_vv.cod_local_descarga = p_qfptran.qfp_tran_txt[89,95]
   LET p_pedidos_edi_pe2_547_vv.periodo_entrega    = p_qfptran.qfp_tran_txt[96,99]
   LET p_pedidos_edi_pe2_547_vv.cod_sit_item       = p_qfptran.qfp_tran_txt[100,101]
   LET p_pedidos_edi_pe2_547_vv.identif_tip_prog   = p_qfptran.qfp_tran_txt[102,102]
   LET p_pedidos_edi_pe2_547_vv.pedido_revenda     = p_qfptran.qfp_tran_txt[103,115]
   LET p_pedidos_edi_pe2_547_vv.qualif_progr       = p_qfptran.qfp_tran_txt[116,116]

   IF l_status = 1 THEN
      RETURN
   END IF 

   DELETE
     FROM pedidos_edi_pe2_547_vv
    WHERE cod_empresa    = p_cod_empresa
      AND num_pedido     = qfptran_1.pedido
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","pedidos_edi_pe2_547_vv")
      RETURN 
   END IF 

   INSERT INTO pedidos_edi_pe2_547_vv VALUES (p_pedidos_edi_pe2_547_vv.*)
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","pedidos_edi_pe2_547_vv")
   END IF
END FUNCTION


#--------------------------------------------#
FUNCTION pol0359_gera_tabela_edi_pe3(l_status)
#--------------------------------------------#
   DEFINE l_status    SMALLINT   

   INITIALIZE p_pedidos_edi_pe3_547_vv.*  TO NULL

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

   LET p_pedidos_edi_pe3_547_vv.cod_empresa    = p_cod_empresa
   LET p_pedidos_edi_pe3_547_vv.num_pedido     = qfptran_1.pedido
   LET p_pedidos_edi_pe3_547_vv.num_sequencia  = p_ped_itens_qfp_547_vv.num_sequencia
   LET p_pedidos_edi_pe3_547_vv.dat_entrega_1  = MDY(p_qfptran.qfp_tran_txt[6,7], 
                                          p_qfptran.qfp_tran_txt[8,9], p_ano)
   LET p_pedidos_edi_pe3_547_vv.hor_entrega_1  = p_qfptran.qfp_tran_txt[10,11]
   LET p_pedidos_edi_pe3_547_vv.qtd_entrega_1  = p_qfptran.qfp_tran_txt[12,20]

   IF p_qfptran.qfp_tran_txt[21,22] >= "00" AND
      p_qfptran.qfp_tran_txt[21,22] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[21,22]

   LET p_pedidos_edi_pe3_547_vv.dat_entrega_2  = MDY(p_qfptran.qfp_tran_txt[23,24], 
                                          p_qfptran.qfp_tran_txt[25,26], p_ano)
   LET p_pedidos_edi_pe3_547_vv.hor_entrega_2  = p_qfptran.qfp_tran_txt[27,28]
   LET p_pedidos_edi_pe3_547_vv.qtd_entrega_2  = p_qfptran.qfp_tran_txt[29,37]

   IF p_qfptran.qfp_tran_txt[38,39] >= "00" AND
      p_qfptran.qfp_tran_txt[38,39] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[38,39]

   LET p_pedidos_edi_pe3_547_vv.dat_entrega_3  = MDY(p_qfptran.qfp_tran_txt[40,41], 
                                          p_qfptran.qfp_tran_txt[42,43],p_ano)
   LET p_pedidos_edi_pe3_547_vv.hor_entrega_3  = p_qfptran.qfp_tran_txt[44,45]
   LET p_pedidos_edi_pe3_547_vv.qtd_entrega_3  = p_qfptran.qfp_tran_txt[46,54]

   IF p_qfptran.qfp_tran_txt[55,56] >= "00" AND
      p_qfptran.qfp_tran_txt[55,56] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[55,56]

   LET p_pedidos_edi_pe3_547_vv.dat_entrega_4  = MDY(p_qfptran.qfp_tran_txt[57,58], 
                                          p_qfptran.qfp_tran_txt[59,60],p_ano)
   LET p_pedidos_edi_pe3_547_vv.hor_entrega_4  = p_qfptran.qfp_tran_txt[61,62]
   LET p_pedidos_edi_pe3_547_vv.qtd_entrega_4  = p_qfptran.qfp_tran_txt[63,71]

   IF p_qfptran.qfp_tran_txt[72,73] >= "00" AND
      p_qfptran.qfp_tran_txt[72,73] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[72,73]

   LET p_pedidos_edi_pe3_547_vv.dat_entrega_5  = MDY(p_qfptran.qfp_tran_txt[74,75], 
                                          p_qfptran.qfp_tran_txt[76,77],p_ano)
   LET p_pedidos_edi_pe3_547_vv.hor_entrega_5  = p_qfptran.qfp_tran_txt[78,79]
   LET p_pedidos_edi_pe3_547_vv.qtd_entrega_5  = p_qfptran.qfp_tran_txt[80,88]

   IF p_qfptran.qfp_tran_txt[89,90] >= "00" AND
      p_qfptran.qfp_tran_txt[89,90] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[89,90]

   LET p_pedidos_edi_pe3_547_vv.dat_entrega_6  = MDY(p_qfptran.qfp_tran_txt[91,92], 
                                          p_qfptran.qfp_tran_txt[93,94],p_ano)
   LET p_pedidos_edi_pe3_547_vv.hor_entrega_6  = p_qfptran.qfp_tran_txt[95,96]
   LET p_pedidos_edi_pe3_547_vv.qtd_entrega_6  = p_qfptran.qfp_tran_txt[97,105]

   IF p_qfptran.qfp_tran_txt[106,107] >= "00" AND
      p_qfptran.qfp_tran_txt[106,107] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[106,107]

   LET p_pedidos_edi_pe3_547_vv.dat_entrega_7  = MDY(p_qfptran.qfp_tran_txt[108,109], 
                                          p_qfptran.qfp_tran_txt[110,111],p_ano)
   LET p_pedidos_edi_pe3_547_vv.hor_entrega_7  = p_qfptran.qfp_tran_txt[112,113]
   LET p_pedidos_edi_pe3_547_vv.qtd_entrega_7  = p_qfptran.qfp_tran_txt[114,122]

   IF l_status = 1 THEN
      RETURN
   END IF 

   DELETE
     FROM pedidos_edi_pe3_547_vv
    WHERE cod_empresa    = p_cod_empresa
      AND num_pedido     = qfptran_1.pedido
      AND num_sequencia  = p_ped_itens_qfp_547_vv.num_sequencia
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","pedidos_edi_pe3_547_vv")
      RETURN 
   END IF 

   INSERT INTO pedidos_edi_pe3_547_vv VALUES (p_pedidos_edi_pe3_547_vv.*)
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","pedidos_edi_pe3_547_vv")
   END IF
END FUNCTION


#--------------------------------------------#
FUNCTION pol0359_gera_tabela_edi_pe4(l_status)
#--------------------------------------------#
   DEFINE l_status    SMALLINT   

   INITIALIZE p_pedidos_edi_pe4_547_vv.*  TO NULL

   LET p_pedidos_edi_pe4_547_vv.cod_empresa       = p_cod_empresa
   LET p_pedidos_edi_pe4_547_vv.num_pedido        = qfptran_1.pedido
   LET p_pedidos_edi_pe4_547_vv.tip_emb_cli_seg   = p_qfptran.qfp_tran_txt[4,33]
   LET p_pedidos_edi_pe4_547_vv.tip_emb_forn_seg  = p_qfptran.qfp_tran_txt[34,63]
   LET p_pedidos_edi_pe4_547_vv.capac_emb_seg     = p_qfptran.qfp_tran_txt[64,75]
   LET p_pedidos_edi_pe4_547_vv.tip_emb_forn_pri  = p_qfptran.qfp_tran_txt[76,105]
   LET p_pedidos_edi_pe4_547_vv.capac_emb_pri     = p_qfptran.qfp_tran_txt[106,117]
   LET p_pedidos_edi_pe4_547_vv.cod_resp_emb      = p_qfptran.qfp_tran_txt[118,118]

   IF l_status = 1 THEN
      RETURN
   END IF 

   DELETE
     FROM pedidos_edi_pe4_547_vv
    WHERE cod_empresa    = p_cod_empresa
      AND num_pedido     = qfptran_1.pedido
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","pedidos_edi_pe4_547_vv")
      RETURN TRUE
   END IF 

   INSERT INTO pedidos_edi_pe4_547_vv VALUES (p_pedidos_edi_pe4_547_vv.*)
   IF sqlca.sqlcode <> 0 AND  
      sqlca.sqlcode <> -1226 THEN 
      CALL log003_err_sql("INCLUSAO","pedidos_edi_pe4_547_vv")
   END IF
END FUNCTION


#--------------------------------------------#
FUNCTION pol0359_gera_tabela_edi_pe5(l_status)
#--------------------------------------------#
   DEFINE l_status    SMALLINT   

   INITIALIZE p_pedidos_edi_pe5_547_vv.*  TO NULL

   INITIALIZE p_tp_prg1,
              p_tp_prg2,
              p_tp_prg3,
              p_tp_prg4,
              p_tp_prg5,
              p_tp_prg6,
              p_tp_prg7 TO NULL 

   LET p_pedidos_edi_pe5_547_vv.cod_empresa         = p_cod_empresa
   LET p_pedidos_edi_pe5_547_vv.num_pedido          = qfptran_1.pedido
   LET p_pedidos_edi_pe5_547_vv.num_sequencia       = p_ped_itens_qfp_547_vv.num_sequencia

   IF p_qfptran.qfp_tran_txt[4,5] >= "00" AND
      p_qfptran.qfp_tran_txt[4,5] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[4,5]

   LET p_pedidos_edi_pe5_547_vv.dat_entrega_1  = MDY(p_qfptran.qfp_tran_txt[6,7], 
                                          p_qfptran.qfp_tran_txt[8,9],p_ano)

   LET p_pedidos_edi_pe5_547_vv.identif_programa_1  = p_qfptran.qfp_tran_txt[10,10]
   LET p_tp_prg1 = p_qfptran.qfp_tran_txt[10,10]
   LET p_pedidos_edi_pe5_547_vv.ident_prog_atual_1  = p_qfptran.qfp_tran_txt[11,19]

   IF p_qfptran.qfp_tran_txt[20,21] >= "00" AND
      p_qfptran.qfp_tran_txt[20,21] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[20,21]

   LET p_pedidos_edi_pe5_547_vv.dat_entrega_2  = MDY(p_qfptran.qfp_tran_txt[22,23], 
                                          p_qfptran.qfp_tran_txt[24,25],p_ano)

   LET p_pedidos_edi_pe5_547_vv.identif_programa_2  = p_qfptran.qfp_tran_txt[26,26]
   LET p_tp_prg2 = p_qfptran.qfp_tran_txt[26,26]
   LET p_pedidos_edi_pe5_547_vv.ident_prog_atual_2  = p_qfptran.qfp_tran_txt[27,35]

   IF p_qfptran.qfp_tran_txt[36,37] >= "00" AND
      p_qfptran.qfp_tran_txt[36,37] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[36,37]

   LET p_pedidos_edi_pe5_547_vv.dat_entrega_3  = MDY(p_qfptran.qfp_tran_txt[38,39], 
                                          p_qfptran.qfp_tran_txt[40,41],p_ano)

   LET p_pedidos_edi_pe5_547_vv.identif_programa_3  = p_qfptran.qfp_tran_txt[42,42]
   LET p_tp_prg3 = p_qfptran.qfp_tran_txt[42,42]
   LET p_pedidos_edi_pe5_547_vv.ident_prog_atual_3  = p_qfptran.qfp_tran_txt[43,51]

   IF p_qfptran.qfp_tran_txt[52,53] >= "00" AND
      p_qfptran.qfp_tran_txt[52,53] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[52,53]

   LET p_pedidos_edi_pe5_547_vv.dat_entrega_4  = MDY(p_qfptran.qfp_tran_txt[54,55], 
                                          p_qfptran.qfp_tran_txt[56,57],p_ano)

   LET p_pedidos_edi_pe5_547_vv.identif_programa_4  = p_qfptran.qfp_tran_txt[58,58]
   LET p_tp_prg4 = p_qfptran.qfp_tran_txt[58,58]
   LET p_pedidos_edi_pe5_547_vv.ident_prog_atual_4  = p_qfptran.qfp_tran_txt[59,67]

   IF p_qfptran.qfp_tran_txt[68,69] >= "00" AND
      p_qfptran.qfp_tran_txt[68,69] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[68,69]

   LET p_pedidos_edi_pe5_547_vv.dat_entrega_5  = MDY(p_qfptran.qfp_tran_txt[70,71], 
                                          p_qfptran.qfp_tran_txt[72,73],p_ano)

   LET p_pedidos_edi_pe5_547_vv.identif_programa_5  = p_qfptran.qfp_tran_txt[74,74]
   LET p_tp_prg5 = p_qfptran.qfp_tran_txt[74,74]
   LET p_pedidos_edi_pe5_547_vv.ident_prog_atual_5  = p_qfptran.qfp_tran_txt[75,83]

   IF p_qfptran.qfp_tran_txt[84,85] >= "00" AND
      p_qfptran.qfp_tran_txt[84,85] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[84,85]

   LET p_pedidos_edi_pe5_547_vv.dat_entrega_6  = MDY(p_qfptran.qfp_tran_txt[86,87], 
                                          p_qfptran.qfp_tran_txt[88,89],p_ano)

   LET p_pedidos_edi_pe5_547_vv.identif_programa_6  = p_qfptran.qfp_tran_txt[90,90]
   LET p_pedidos_edi_pe5_547_vv.ident_prog_atual_6  = p_qfptran.qfp_tran_txt[91,99]

   IF p_qfptran.qfp_tran_txt[100,101] >= "00" AND
      p_qfptran.qfp_tran_txt[100,101] <= "50" THEN 
      LET p_seculo = "20"
   ELSE 
      LET p_seculo = "19"
   END IF  
   LET p_ano  = p_seculo, p_qfptran.qfp_tran_txt[100,101]

   LET p_pedidos_edi_pe5_547_vv.dat_entrega_7  = MDY(p_qfptran.qfp_tran_txt[102,103], 
                                          p_qfptran.qfp_tran_txt[104,105],p_ano)

   LET p_pedidos_edi_pe5_547_vv.identif_programa_7  = p_qfptran.qfp_tran_txt[106,106]
   LET p_tp_prg5 = p_qfptran.qfp_tran_txt[106,106]
   LET p_pedidos_edi_pe5_547_vv.ident_prog_atual_7  = p_qfptran.qfp_tran_txt[107,115]

   IF l_status = 1 THEN
      RETURN
   END IF 

   DELETE
     FROM pedidos_edi_pe5_547_vv
    WHERE cod_empresa    = p_cod_empresa
      AND num_pedido     = qfptran_1.pedido
      AND num_sequencia  = p_ped_itens_qfp_547_vv.num_sequencia
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","pedidos_edi_pe5_547_vv")
      RETURN TRUE
   END IF 

   INSERT INTO pedidos_edi_pe5_547_vv VALUES (p_pedidos_edi_pe5_547_vv.*)
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","pedidos_edi_pe5_547_vv")
   END IF
END FUNCTION


#--------------------------------------------#
FUNCTION pol0359_gera_tabela_edi_pe6(l_status)
#--------------------------------------------#
   DEFINE l_status    SMALLINT   

   INITIALIZE p_pedidos_edi_pe6_547_vv.*  TO NULL

   LET p_pedidos_edi_pe6_547_vv.cod_empresa       = p_cod_empresa
   LET p_pedidos_edi_pe6_547_vv.num_pedido        = qfptran_1.pedido
   LET p_fator_conversao                   = p_qfptran.qfp_tran_txt[4,13]
   LET p_pedidos_edi_pe6_547_vv.fator_conversao   = p_fator_conversao / 100000
   LET p_pedidos_edi_pe6_547_vv.alter_tecnica     = p_qfptran.qfp_tran_txt[14,17]
   LET p_pedidos_edi_pe6_547_vv.cod_material      = p_qfptran.qfp_tran_txt[18,27]

   IF l_status = 1 THEN
      RETURN 
   END IF 

   DELETE
     FROM pedidos_edi_pe6_547_vv
    WHERE cod_empresa    = p_cod_empresa
      AND num_pedido     = qfptran_1.pedido
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","pedidos_edi_pe6_547_vv")
      RETURN TRUE
   END IF 

   INSERT INTO pedidos_edi_pe6_547_vv VALUES (p_pedidos_edi_pe6_547_vv.*)
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","pedidos_edi_pe6_547_vv")
   END IF
   
END FUNCTION

#--------------------------------------------#
FUNCTION pol0359_gera_tabela_edi_te1(l_status)
#--------------------------------------------#
   DEFINE l_status    SMALLINT,
          l_for       SMALLINT 

   INITIALIZE p_pedidos_edi_te1_547_vv.*   TO NULL

   LET p_pedidos_edi_te1_547_vv.cod_empresa       = p_cod_empresa
   LET p_pedidos_edi_te1_547_vv.num_pedido        = qfptran_1.pedido
   LET p_pedidos_edi_te1_547_vv.num_sequencia     = 0 #p_qfptran.qfp_tran_txt[61,62]
   LET p_pedidos_edi_te1_547_vv.texto_1           = p_qfptran.qfp_tran_txt[4,43]
   LET p_pedidos_edi_te1_547_vv.texto_2           = p_qfptran.qfp_tran_txt[44,83]
   LET p_pedidos_edi_te1_547_vv.texto_3           = p_qfptran.qfp_tran_txt[84,123]

   LET l_for = 1 # p_qfptran.qfp_tran_txt[61,62]
   IF l_status = 1 THEN 
      LET pa_edi_te1[l_for].den_texto = p_pedidos_edi_te1_547_vv.texto_1,
                                        p_pedidos_edi_te1_547_vv.texto_2,
                                        p_pedidos_edi_te1_547_vv.texto_3
      RETURN
   END IF 

      DELETE
        FROM pedidos_edi_te1_547_vv
       WHERE cod_empresa    = p_cod_empresa
         AND num_pedido     = qfptran_1.pedido
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("DELETE","pedidos_edi_te1_547_vv")
         RETURN TRUE
      END IF 

   INSERT INTO pedidos_edi_te1_547_vv VALUES (p_pedidos_edi_te1_547_vv.*)
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","pedidos_edi_te1_547_vv")
   END IF
END FUNCTION

#------------------------------------------#
FUNCTION pol0359_busca_informacoes_edi_pe5()
#------------------------------------------#
   DEFINE l_qfptran           RECORD LIKE qfptran.*,
          l_chave             CHAR(58),
          p_exit_foreach      SMALLINT 


   LET p_exit_foreach = FALSE 
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
         ELSE
            FETCH NEXT cq_edi_pe5 INTO l_qfptran.*
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
      LET p_tp_prg1 = l_qfptran.qfp_tran_txt[10,10]
   END IF 

   IF l_qfptran.qfp_tran_txt[20,25] IS NOT NULL AND
      l_qfptran.qfp_tran_txt[20,25] <> " "      THEN
      LET p_qfptran.qfp_tran_txt[21,26]  = l_qfptran.qfp_tran_txt[20,25] 
      LET p_tp_prg2 = l_qfptran.qfp_tran_txt[26,26]
   END IF 

   IF l_qfptran.qfp_tran_txt[36,41] IS NOT NULL AND
      l_qfptran.qfp_tran_txt[36,41] <> " "      THEN
      LET p_qfptran.qfp_tran_txt[38,43]  = l_qfptran.qfp_tran_txt[36,41]
      LET p_tp_prg3 = l_qfptran.qfp_tran_txt[42,42]
   END IF 

   IF l_qfptran.qfp_tran_txt[52,57] IS NOT NULL AND
      l_qfptran.qfp_tran_txt[52,57] <> " "      THEN
      LET p_qfptran.qfp_tran_txt[55,60]  = l_qfptran.qfp_tran_txt[52,57] 
      LET p_tp_prg4 = l_qfptran.qfp_tran_txt[58,58]
   END IF 

   IF l_qfptran.qfp_tran_txt[68,73] IS NOT NULL AND
      l_qfptran.qfp_tran_txt[68,73] <> " "      THEN
      LET p_qfptran.qfp_tran_txt[72,77]  = l_qfptran.qfp_tran_txt[68,73] 
      LET p_tp_prg5 = l_qfptran.qfp_tran_txt[74,74]
   END IF 

   IF l_qfptran.qfp_tran_txt[84,89] IS NOT NULL AND
      l_qfptran.qfp_tran_txt[84,89] <> " "      THEN
      LET p_qfptran.qfp_tran_txt[89,94]  = l_qfptran.qfp_tran_txt[84,89] 
      LET p_tp_prg6 = l_qfptran.qfp_tran_txt[90,90]
   END IF 

   IF l_qfptran.qfp_tran_txt[100,105] IS NOT NULL AND
      l_qfptran.qfp_tran_txt[100,105] <> " "      THEN
      LET p_qfptran.qfp_tran_txt[106,111]  = l_qfptran.qfp_tran_txt[100,105] 
      LET p_tp_prg7 = l_qfptran.qfp_tran_txt[106,106]
   END IF 

END FUNCTION

# osvaldo
#--------------------------------------------------------#
FUNCTION pol0359_grava_ped_itens_qfp_pe5_547_vv()
#--------------------------------------------------------#

   DEFINE pa_ped_edi_pe5 ARRAY[7] OF RECORD 
      num_pedido       LIKE pedidos_edi_pe5_547_vv.num_pedido,
      num_sequencia    LIKE pedidos_edi_pe5_547_vv.num_sequencia,
      dat_entrega      LIKE pedidos_edi_pe5_547_vv.dat_entrega_1,
      identif_programa LIKE pedidos_edi_pe5_547_vv.identif_programa_1,
      ident_prog       LIKE pedidos_edi_pe5_547_vv.ident_prog_atual_1
   END RECORD 

   DEFINE p_ped_itens_qfp_547_vv1 RECORD
      num_pedido    LIKE ped_itens_qfp_547_vv.num_pedido,   
      num_sequencia LIKE ped_itens_qfp_547_vv.num_sequencia,
      cod_item      LIKE ped_itens_qfp_547_vv.cod_item            
   END RECORD 

   DEFINE p_temp RECORD
      num_pedido      DEC(6,0), 
      num_sequencia   SMALLINT, 
      dat_abertura    DATE,  
      ies_programacao DEC(2,0),
      ident_prog      CHAR(9) 
   END RECORD 

   DEFINE p_num_pedido LIKE pedidos_qfp_547_vv.num_pedido,
          p_num_seq    SMALLINT,
          l_num_seq    SMALLINT,
          p_i          SMALLINT

   INITIALIZE pa_ped_edi_pe5 TO NULL
   LET p_num_pedido = 0

   DECLARE cp_pedidos_qfp_547_vv CURSOR WITH HOLD FOR 
   SELECT unique num_pedido
     FROM pedidos_qfp_547_vv
    WHERE cod_empresa = p_cod_empresa   

   FOREACH cp_pedidos_qfp_547_vv INTO p_num_pedido             

      DECLARE cp_pedidos_edi_pe5_547_vv CURSOR WITH HOLD FOR 
      SELECT num_pedido,
             num_sequencia,
             dat_entrega_1,
             identif_programa_1,
             ident_prog_atual_1,
             dat_entrega_2,
             identif_programa_2,
             ident_prog_atual_2,
             dat_entrega_3,
             identif_programa_3,
             ident_prog_atual_3,
             dat_entrega_4,
             identif_programa_4,
             ident_prog_atual_4,
             dat_entrega_5,
             identif_programa_5,
             ident_prog_atual_5,
             dat_entrega_6,
             identif_programa_6,
             ident_prog_atual_6,
             dat_entrega_7,
             identif_programa_7,
             ident_prog_atual_7
      FROM pedidos_edi_pe5_547_vv
      WHERE cod_empresa = p_cod_empresa   
        AND num_pedido  = p_num_pedido 
      ORDER BY num_sequencia

      LET p_num_seq = 1
      FOREACH cp_pedidos_edi_pe5_547_vv INTO pa_ped_edi_pe5[1].num_pedido,
                                      pa_ped_edi_pe5[1].num_sequencia,
                                      pa_ped_edi_pe5[1].dat_entrega,
                                      pa_ped_edi_pe5[1].identif_programa,
                                      pa_ped_edi_pe5[1].ident_prog,
                                      pa_ped_edi_pe5[2].dat_entrega,
                                      pa_ped_edi_pe5[2].identif_programa,
                                      pa_ped_edi_pe5[2].ident_prog,
                                      pa_ped_edi_pe5[3].dat_entrega,
                                      pa_ped_edi_pe5[3].identif_programa,
                                      pa_ped_edi_pe5[3].ident_prog,
                                      pa_ped_edi_pe5[4].dat_entrega,
                                      pa_ped_edi_pe5[4].identif_programa,
                                      pa_ped_edi_pe5[4].ident_prog,
                                      pa_ped_edi_pe5[5].dat_entrega,
                                      pa_ped_edi_pe5[5].identif_programa,
                                      pa_ped_edi_pe5[5].ident_prog,
                                      pa_ped_edi_pe5[6].dat_entrega,
                                      pa_ped_edi_pe5[6].identif_programa,
                                      pa_ped_edi_pe5[6].ident_prog,
                                      pa_ped_edi_pe5[7].dat_entrega,
                                      pa_ped_edi_pe5[7].identif_programa,
                                      pa_ped_edi_pe5[7].ident_prog 

         FOR p_i = 1 TO 7

            IF pa_ped_edi_pe5[p_i].dat_entrega IS NULL THEN
               EXIT FOR
            ELSE
               INSERT INTO tpol0359_2 
                  VALUES (pa_ped_edi_pe5[1].num_pedido,
                          pa_ped_edi_pe5[1].num_sequencia, #p_num_seq,  ivo 28/01/2013
                          pa_ped_edi_pe5[p_i].dat_entrega,
                          pa_ped_edi_pe5[p_i].identif_programa,
                          pa_ped_edi_pe5[p_i].ident_prog)
               IF sqlca.sqlcode <> 0 THEN 
                  IF sqlca.sqlcode <> -239 THEN 
                     CALL log003_err_sql("INCLUSAO","Tpol0359_2")
                  END IF
               END IF
               EXIT FOR #ivo 28/01/2013
            END IF

            LET p_num_seq = p_num_seq + 1

         END FOR 
               
      END FOREACH 

      INITIALIZE pa_ped_edi_pe5 TO NULL

      LET l_num_seq = 0 

      DECLARE cp_ped_itens_qfp_547_vv1 CURSOR WITH HOLD FOR 
      SELECT num_pedido,
             num_sequencia,
             cod_item
      FROM ped_itens_qfp_547_vv
      WHERE cod_empresa = p_cod_empresa   
        AND num_pedido  = p_num_pedido 
      ORDER BY num_sequencia

      FOREACH cp_ped_itens_qfp_547_vv1 INTO p_ped_itens_qfp_547_vv1.*
          SELECT *
            INTO p_temp.*
            FROM tpol0359_2
           WHERE num_pedido    = p_ped_itens_qfp_547_vv1.num_pedido
             AND num_sequencia = p_ped_itens_qfp_547_vv1.num_sequencia

					#ivo 28/01/2013
          IF STATUS <> 0 OR p_temp.dat_abertura IS NULL OR p_temp.ies_programacao IS NULL THEN
             CONTINUE FOREACH
          END IF #até aqui

            INSERT INTO ped_itens_qfp_pe5_547_vv
               VALUES (p_cod_empresa,                
                       p_temp.num_pedido, 
                       p_ped_itens_qfp_547_vv1.cod_item,
                       p_ped_itens_qfp_547_vv1.num_sequencia, 
                       p_temp.dat_abertura,  
                       p_temp.ies_programacao)
            IF sqlca.sqlcode <> 0 THEN 
               IF sqlca.sqlcode <> -239 THEN 
                  CALL log003_err_sql("INCLUSAO","ped_itens_qfp_pe5_547_vv")
               END IF
            END IF
         
            INSERT INTO ped_it_qfp_pe5_cl_547_vv
               VALUES (p_cod_empresa,                
                       p_temp.num_pedido, 
                       p_ped_itens_qfp_547_vv1.cod_item,
                       p_ped_itens_qfp_547_vv1.num_sequencia,
                       p_temp.ident_prog) 

      END FOREACH     

   END FOREACH 

END FUNCTION
#---------------------------------------------#
FUNCTION pol0359_corrige_ped_itens_qfp_547_vv()
#---------------------------------------------#
  
    DELETE FROM ped_itens_qfp_547_vv 
     WHERE NOT EXISTS 
   (SELECT * FROM ped_itens_qfp_pe5_547_vv 
     WHERE ped_itens_qfp_547_vv.cod_empresa= ped_itens_qfp_pe5_547_vv.cod_empresa 
       AND  ped_itens_qfp_547_vv.num_pedido= ped_itens_qfp_pe5_547_vv.num_pedido
       AND  ped_itens_qfp_547_vv.num_sequencia= ped_itens_qfp_pe5_547_vv.num_sequencia)
       
END FUNCTION

#-----------------------#
FUNCTION pol0359_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------------- FIM DE PROGRAMA BI----------------------------#
