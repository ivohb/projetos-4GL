#-------------------------------------------------------------------------#
# PROGRAMA: pol0892                                                       #
# OBJETIVO: CARREGA PROGRAMACAO DE ENTREGA - EDIFACT - A PARTIR           #
#           DAS TABELAS QFPTRAN E PED_ITENS                               #
#-------------------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE p_nom_arquivo          CHAR(100),
         p_msg                  CHAR(500),
         g_ies_ambiente         CHAR(001),
         p_ies_impressao        CHAR(001),
         p_comando              CHAR(080),
         p_caminho              CHAR(080),
         p_nom_tela             CHAR(080),
         p_help                 CHAR(080),
         p_pedido               CHAR(012),
         p_cancel               INTEGER,
         p_cont                 INTEGER,
         p_contf                INTEGER,       
         p_houve_msg_erro       SMALLINT
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_den_empresa          LIKE empresa.den_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_status               SMALLINT,
         p_last_row             SMALLINT,
         p_count                SMALLINT,
         p_hoje                 DATE 
         
  DEFINE p_versao  CHAR(18)        
         
END GLOBALS        
      
  DEFINE p_qtd_item             LIKE nf_item.qtd_item,
         p_dat_emissao          LIKE fat_nf_mestre.dat_hor_emissao,
         p_time                 CHAR(08),
         p_prz_entrega          LIKE ped_itens_qfp.prz_entrega,
         p_observacao           CHAR(31),
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
         p_num_nff_fat          LIKE fat_nf_mestre.nota_fiscal,
         p_num_nff_rec          CHAR(36),
         p_num_nff_rec6         CHAR(06),
         p_num_nff_num          LIKE fat_nf_mestre.nota_fiscal,
         p_cod_item             CHAR(15),
         p_cod_it_form          CHAR(35),
         p_item_fornecedor      CHAR(30),     
         p_data_ant             DATE,
         p_seculo               CHAR(02),
         p_tot_registros        DECIMAL(03,0),
         p_zerados              DECIMAL(03,0),
         p_dia_semana           SMALLINT,
         p_ind                  SMALLINT,
         p_ind1                 SMALLINT,
         p_ind_it1              SMALLINT,
         p_ind_it2              SMALLINT,
         p_ies_cons             SMALLINT,
         p_existe               SMALLINT,
         p_houve_erro           SMALLINT,
         p_fator_conversao      DECIMAL(15,6)
  
  DEFINE p_ped_itens         RECORD LIKE ped_itens.*,
         p_ped_itens_qfp     RECORD LIKE ped_itens_qfp.*,
         p_ped_itens_fct_547 RECORD LIKE ped_itens_fct_547.*,
         p_audit_vdp         RECORD LIKE audit_vdp.*
  
  DEFINE p_qfptran,
         p_qfptran_aux       RECORD LIKE qfptran.*
  DEFINE p_peditem_ant       RECORD
         qtd_solic_nova      DECIMAL(10,3),
         qtd_solic_aceita    DECIMAL(10,3)
                             END RECORD 

  DEFINE p_tela   RECORD
         item_cli     CHAR(35),
         item         CHAR(15) 
              END RECORD 

  DEFINE qfptran_reg   RECORD
            versao             CHAR(01),
            cod_emissor        CHAR(35),
            cod_receptor       CHAR(35),
            dat_geracao        CHAR(08),
            num_trans          CHAR(14),
            cod_item_lin       CHAR(35),
            cod_item           CHAR(15),      
            num_ped_cli        CHAR(35),
            num_pedido         DECIMAL(06,0),      
            qtd_solic          CHAR(15),
            dat_entrega        CHAR(08),
            prog_entrega       CHAR(35)
                       END RECORD

  DEFINE  p_trans_cliente       RECORD LIKE trans_cliente.*,
          p_clientes            RECORD LIKE clientes.*,
          p_cli_info_adic       RECORD LIKE cli_info_adic.*,
          p_empresa             RECORD LIKE empresa.*

MAIN
  CALL log0180_conecta_usuario()
  LET p_versao = "POL0892-10.02.00" 
  WHENEVER ANY ERROR CONTINUE
  CALL log1400_isolation()
  WHENEVER ERROR STOP
  DEFER INTERRUPT

  CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
  LET p_help = p_caminho 
  OPTIONS
    HELP FILE p_help

  CALL log001_acessa_usuario("ESPEC999","")
    RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0 THEN 
    CALL pol0892_controle()
  END IF
END MAIN

#-----------------------------#
 FUNCTION pol0892_controle()
#-----------------------------#
  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("pol0892") RETURNING p_nom_tela 
  OPEN WINDOW w_pol0892 AT 7,11 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND "Processar" "Processa variacao programacao e emite relatorio"
      HELP 0116
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","pol0892","CO") THEN 
         CALL pol0892_lista_relat()
         IF p_imprimir = "SIM" THEN 	
            CALL pol0892_qfptran_carrega_ped_itens_fct()
            IF p_houve_erro = FALSE THEN 
               CALL log085_transacao("COMMIT")
               IF sqlca.sqlcode <> 0 THEN 
                  CALL log003_err_sql("INCLUSAO","PED_ITENS_FCT_547") 
                  CALL log085_transacao("ROLLBACK")
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
         CALL pol0892_sobre()
    
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0892
END FUNCTION

#----------------------------------------------#
FUNCTION pol0892_qfptran_carrega_ped_itens_fct()
#----------------------------------------------#
 DEFINE l_indi      INTEGER,
        l_indf      INTEGER

   INITIALIZE p_msg TO NULL

   CALL log085_transacao("BEGIN")

   LET p_houve_erro = FALSE

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   LET p_cod_cliente = '1'

   ERROR " Processando a atualizacao da tabela ... "
   
   DECLARE cp_qfptran CURSOR WITH HOLD FOR
    SELECT qfptran.*
      FROM qfptran

   FOREACH cp_qfptran INTO p_qfptran.*
   
      CASE p_qfptran.qfp_tran_txt[1,3]
      
         WHEN "UNB"
           LET qfptran_reg.versao      =  p_qfptran.qfp_tran_txt[10,10]
           LET qfptran_reg.cod_emissor   = "0"                  
           FOR p_ind = 12 TO 46
             IF p_qfptran.qfp_tran_txt[p_ind,p_ind] <> ':' AND 
                p_qfptran.qfp_tran_txt[p_ind,p_ind] <> '+' THEN  
                LET qfptran_reg.cod_emissor   = qfptran_reg.cod_emissor CLIPPED, p_qfptran.qfp_tran_txt[p_ind,p_ind]
             ELSE
                LET p_cont = p_ind
                EXIT FOR   
             END IF 
           END FOR  
           
           IF p_qfptran.qfp_tran_txt[p_cont,p_cont] = ':' THEN
              LET p_cont = p_cont + 1
              WHILE TRUE 
                IF p_qfptran.qfp_tran_txt[p_cont,p_cont] = '+' THEN
                   EXIT WHILE
                ELSE
                   LET p_cont = p_cont + 1   
                END IF 
              END WHILE     
           END IF 
           LET p_cont = p_cont + 1

           LET qfptran_reg.cod_receptor   = "0"
           LET p_contf = p_cont + 35                  
           FOR p_ind = p_cont TO p_contf
             IF p_qfptran.qfp_tran_txt[p_ind,p_ind] <> ':' AND 
                p_qfptran.qfp_tran_txt[p_ind,p_ind] <> '+' THEN  
                LET qfptran_reg.cod_receptor   = qfptran_reg.cod_receptor CLIPPED, p_qfptran.qfp_tran_txt[p_ind,p_ind]
             ELSE
                LET p_cont = p_ind
                EXIT FOR   
             END IF 
           END FOR  

           IF p_qfptran.qfp_tran_txt[p_cont,p_cont] = ':' THEN
              LET p_cont = p_cont + 1
              WHILE TRUE 
                IF p_qfptran.qfp_tran_txt[p_cont,p_cont] = '+' THEN
                   EXIT WHILE
                ELSE
                   LET p_cont = p_cont + 1   
                END IF 
              END WHILE     
           END IF 
           LET p_cont  = p_cont + 1
           IF p_qfptran.qfp_tran_txt[p_cont+6,p_cont+6] =':' OR 
              p_qfptran.qfp_tran_txt[p_cont+6,p_cont+6] ='+' THEN
              LET p_contf = p_cont + 5      
           ELSE
              LET p_contf = p_cont + 7      
           END IF 
            
           LET qfptran_reg.dat_geracao   = p_qfptran.qfp_tran_txt[p_cont,p_contf]
           
           LET p_cont = p_contf + 1
           LET p_contf = p_cont + 5

           FOR p_ind = p_cont TO p_contf
              IF p_qfptran.qfp_tran_txt[p_cont,p_cont] = ':' THEN
                 LET p_cont = p_cont + 1
                 WHILE TRUE 
                   IF p_qfptran.qfp_tran_txt[p_cont,p_cont] = '+' THEN
                      EXIT WHILE
                   ELSE
                      LET p_cont = p_cont + 1   
                   END IF 
                 END WHILE     
              END IF 
           END FOR   

           LET p_cont = p_cont + 1
           LET p_contf = p_cont + 14      
           
           INITIALIZE qfptran_reg.num_trans  TO NULL
           FOR p_ind = p_cont TO p_contf
             IF p_qfptran.qfp_tran_txt[p_ind,p_ind] <> ':' AND 
                p_qfptran.qfp_tran_txt[p_ind,p_ind] <> '+' THEN  
                LET qfptran_reg.num_trans   = qfptran_reg.num_trans CLIPPED, p_qfptran.qfp_tran_txt[p_ind,p_ind]
             ELSE
                LET p_cont = p_ind
                EXIT FOR   
             END IF 
           END FOR  
###---------------------------------------------

         WHEN "BGM"
           FOR p_ind = 5 TO 44
             IF p_qfptran.qfp_tran_txt[p_ind,p_ind] = '+' THEN  
                LET p_cont = p_ind
                EXIT FOR   
             END IF 
           END FOR  
           
           LET p_cont = p_cont + 1

           LET p_contf = p_cont + 35  
           INITIALIZE qfptran_reg.prog_entrega TO NULL               
           FOR p_ind = p_cont TO p_contf
             IF p_qfptran.qfp_tran_txt[p_ind,p_ind] <> ':' AND 
                p_qfptran.qfp_tran_txt[p_ind,p_ind] <> '+' THEN  
                LET qfptran_reg.prog_entrega = qfptran_reg.prog_entrega CLIPPED, p_qfptran.qfp_tran_txt[p_ind,p_ind]
             ELSE
                LET p_cont = p_ind
                EXIT FOR   
             END IF 
           END FOR  
       
          CALL pol0892_limpa_tabelas()    
###------------------------------------------

         WHEN "LIN"
           INITIALIZE qfptran_reg.cod_item_lin,  
                      qfptran_reg.cod_item,      
                      qfptran_reg.num_ped_cli,   
                      qfptran_reg.num_pedido,    
                      qfptran_reg.qtd_solic,     
                      qfptran_reg.dat_entrega  TO NULL
                      
           FOR p_ind = 5 TO 10
             IF p_qfptran.qfp_tran_txt[p_ind,p_ind] <> ':' AND 
                p_qfptran.qfp_tran_txt[p_ind,p_ind] <> '+' THEN  
             ELSE
                LET p_cont = p_ind
                EXIT FOR   
             END IF 
           END FOR  
           
           IF p_qfptran.qfp_tran_txt[p_cont,p_cont] = ':' THEN
              LET p_cont = p_cont + 1
              WHILE TRUE 
                IF p_qfptran.qfp_tran_txt[p_cont,p_cont] = '+' THEN
                   EXIT WHILE
                ELSE
                   LET p_cont = p_cont + 1   
                END IF 
              END WHILE     
           END IF 
           LET p_cont = p_cont + 1
           LET p_contf = p_cont + 2
                             
           FOR p_ind = p_cont TO p_contf
             IF p_qfptran.qfp_tran_txt[p_ind,p_ind] <> ':' AND 
                p_qfptran.qfp_tran_txt[p_ind,p_ind] <> '+' THEN  
             ELSE
                LET p_cont = p_ind
                EXIT FOR   
             END IF 
           END FOR  

           IF p_qfptran.qfp_tran_txt[p_cont,p_cont] = ':' THEN
              LET p_cont = p_cont + 1
              WHILE TRUE 
                IF p_qfptran.qfp_tran_txt[p_cont,p_cont] = '+' THEN
                   EXIT WHILE
                ELSE
                   LET p_cont = p_cont + 1   
                END IF 
              END WHILE     
           END IF 
           LET p_cont  = p_cont + 1
           LET p_contf = p_cont + 34      
           INITIALIZE qfptran_reg.cod_item_lin TO NULL
           FOR p_ind = p_cont TO p_contf
             IF p_qfptran.qfp_tran_txt[p_ind,p_ind] <> ':' AND 
                p_qfptran.qfp_tran_txt[p_ind,p_ind] <> '+' THEN  
                LET qfptran_reg.cod_item_lin  = qfptran_reg.cod_item_lin CLIPPED, p_qfptran.qfp_tran_txt[p_ind,p_ind]
             ELSE
                LET p_cont = p_ind
                EXIT FOR   
             END IF 
           END FOR  

           LET p_ind_it1 = 1
           LET p_ind_it2 = 1  
           
           WHILE p_ind_it1 <= 35
             IF qfptran_reg.cod_item_lin[p_ind_it1] <> '-' THEN 
                LET p_cod_it_form[p_ind_it2] = qfptran_reg.cod_item_lin[p_ind_it1]
                LET p_ind_it2 = p_ind_it2 + 1  
             END IF 

             LET p_ind_it1 = p_ind_it1 + 1
               
           END WHILE 

           LET qfptran_reg.cod_item_lin = p_cod_it_form

           LET p_tela.item_cli = qfptran_reg.cod_item_lin 
           DISPLAY BY NAME p_tela.item_cli  
           
           LET p_hoje = TODAY 
           
           SELECT cod_item
             INTO qfptran_reg.cod_item
             FROM item_kanban_547
            WHERE cod_empresa = p_cod_empresa 
              AND cod_item_cliente = qfptran_reg.cod_item_lin 
              AND dat_inicio <= p_hoje
              AND dat_termino >= p_hoje 

           IF SQLCA.sqlcode <> 0 THEN 
              LET p_observacao  = "ERRO ITEM_KANBAN ERRO ",SQLCA.sqlcode
              OUTPUT TO REPORT pol0892_relat(1)
           END IF               
###------------------------------------------ 
           
         WHEN "PIA"
           LET l_indi = 5
           LET l_indf = 6
           WHILE TRUE 
             IF p_qfptran.qfp_tran_txt[l_indi,l_indf] = 'PO' THEN
                LET l_indf = l_indf - 3
                LET l_indi = l_indf  
                EXIT WHILE 
             ELSE
               LET  l_indi = l_indi + 1
               LET  l_indf = l_indf + 1
             END IF 
             IF p_qfptran.qfp_tran_txt[l_indi,l_indf] = '  '  OR 
                p_qfptran.qfp_tran_txt[l_indi,l_indf] IS NULL THEN
                LET p_observacao  = "ITEM SEM NUM. DE PEDIDO ",SQLCA.sqlcode
                OUTPUT TO REPORT pol0892_relat(1)
                EXIT WHILE 
             END IF    
           END WHILE   
           
           IF p_qfptran.qfp_tran_txt[l_indi,l_indf] = '  '  OR 
              p_qfptran.qfp_tran_txt[l_indi,l_indf] IS NULL THEN
           ELSE   
              WHILE TRUE
                 IF p_qfptran.qfp_tran_txt[l_indi] = ':' OR 
                    p_qfptran.qfp_tran_txt[l_indi] = '+' THEN
                    LET l_indi = l_indi + 1
                    EXIT WHILE
                 ELSE
                    LET l_indi = l_indi - 1
                 END IF    
              END WHILE
           
              INITIALIZE qfptran_reg.num_ped_cli TO NULL
              
              LET qfptran_reg.num_ped_cli = p_qfptran.qfp_tran_txt[l_indi,l_indf]
              
              SELECT num_pedido 
                INTO qfptran_reg.num_pedido
                FROM pedidos  
               WHERE cod_empresa = p_cod_empresa
                 AND cod_cliente = p_cod_cliente
                 AND ies_sit_pedido <> '9'
                 AND num_pedido_cli = qfptran_reg.num_ped_cli
              
                 IF SQLCA.sqlcode <> 0 THEN 
                    LET p_observacao  = "ERRO AO LER PEDIDO 1, ",SQLCA.sqlcode
                    OUTPUT TO REPORT pol0892_relat(1)
                 END IF               
              
              IF qfptran_reg.num_pedido IS NULL THEN 
                 SELECT MAX(a.num_pedido)
                   INTO qfptran_reg.num_pedido
                   FROM ped_itens a,
                        pedidos b 
                  WHERE a.cod_empresa = b.cod_empresa
                    AND a.num_pedido  = b.num_pedido 
                    AND a.cod_empresa = p_cod_empresa
                    AND a.cod_item    = qfptran_reg.cod_item
                    AND b.cod_cliente = p_cod_cliente
                    AND b.ies_sit_pedido <> '9'
                    AND b.num_pedido_cli IS NOT NULL 
                 
                 IF SQLCA.sqlcode <> 0 THEN 
                    LET p_observacao  = "ERRO AO LER PEDIDO 2, ",SQLCA.sqlcode
                    OUTPUT TO REPORT pol0892_relat(1)
                 END IF               
              END IF  
           END IF 
###------------------------------------------
           
         WHEN "RFF"
{           IF qfptran_reg.num_pedido IS NULL THEN 
              INITIALIZE qfptran_reg.cod_item_lin,  
                         qfptran_reg.cod_item,      
                         qfptran_reg.num_ped_cli,   
                         qfptran_reg.num_pedido,    
                         qfptran_reg.qtd_solic,     
                         qfptran_reg.dat_entrega  TO NULL

              IF p_qfptran.qfp_tran_txt[5,6] = 'ON' THEN
                 INITIALIZE qfptran_reg.num_ped_cli TO NULL
                 FOR p_ind = 8 TO 43
                   IF p_qfptran.qfp_tran_txt[p_ind,p_ind] <> ':' AND 
                      p_qfptran.qfp_tran_txt[p_ind,p_ind] <> '+' THEN  
                      LET qfptran_reg.num_ped_cli  = qfptran_reg.num_ped_cli CLIPPED, p_qfptran.qfp_tran_txt[p_ind,p_ind]
                   ELSE
                      LET p_cont = p_ind
                      EXIT FOR   
                   END IF 
                 END FOR  

                 SELECT num_pedido 
                   INTO qfptran_reg.num_pedido
                   FROM pedidos  
                  WHERE cod_empresa = p_cod_empresa
                    AND cod_cliente = p_cod_cliente
                    AND ies_sit_pedido <> '9'
                    AND num_pedido_cli = qfptran_reg.num_ped_cli

                 IF SQLCA.sqlcode <> 0 THEN 
                    LET p_observacao  = "ERRO AO LER PEDIDO, ",SQLCA.sqlcode
                    OUTPUT TO REPORT pol0892_relat(1)
                 END IF               

                 SELECT MAX(cod_item) 
                   INTO qfptran_reg.cod_item
                   FROM ped_itens 
                  WHERE cod_empresa = p_cod_empresa
                    AND num_pedido  = qfptran_reg.num_pedidoido_cli

                 LET p_tela.item = qfptran_reg.cod_item 
                 DISPLAY BY NAME p_tela.item  

                 IF SQLCA.sqlcode <> 0 THEN 
                    LET p_observacao  = "ERRO AO LER PED_ITEM, ", SQLCA.sqlcode
                    OUTPUT TO REPORT pol0892_relat(1)
                 END IF               
              END IF    
           END IF}

           IF p_num_nff_rec  IS NULL THEN 
              INITIALIZE p_num_nff_rec  TO NULL
              IF p_qfptran.qfp_tran_txt[5,6] = 'OI' THEN
                 FOR p_ind = 8 TO 43
                   IF p_qfptran.qfp_tran_txt[p_ind,p_ind] <> ':' AND 
                      p_qfptran.qfp_tran_txt[p_ind,p_ind] <> '+' THEN  
                      LET p_num_nff_rec  = p_num_nff_rec CLIPPED, p_qfptran.qfp_tran_txt[p_ind,p_ind]
                   ELSE
                      LET p_cont = p_ind
                      EXIT FOR   
                   END IF 
                 END FOR
              END IF      
              LET p_num_nff_rec6 = p_num_nff_rec[1,6]
              LET p_num_nff_num  = p_num_nff_rec6 
           END IF
###------------------------------------------

         WHEN "QTY"
           IF qfptran_reg.num_pedido IS NOT NULL THEN 
              INITIALIZE qfptran_reg.qtd_solic  TO NULL
              IF p_qfptran.qfp_tran_txt[5,5] = '1' THEN
                 FOR p_ind = 7 TO 21
                   IF p_qfptran.qfp_tran_txt[p_ind,p_ind] <> ':' AND 
                      p_qfptran.qfp_tran_txt[p_ind,p_ind] <> '+' THEN  
                      LET qfptran_reg.qtd_solic  = qfptran_reg.qtd_solic CLIPPED, p_qfptran.qfp_tran_txt[p_ind,p_ind]
                   ELSE
                      LET p_cont = p_ind
                      EXIT FOR   
                   END IF 
                 END FOR  
              END IF                 
           END IF                 
###------------------------------------------

         WHEN "DTM"
           IF qfptran_reg.num_pedido IS NOT NULL THEN 
              IF p_qfptran.qfp_tran_txt[5,6] = '10' THEN
                 LET qfptran_reg.dat_entrega = p_qfptran.qfp_tran_txt[8,15]
                 IF pol0892_grava_ped_itens_fct() THEN
                 END IF 
              END IF                 
           END IF                 

      END CASE
   END FOREACH

   FINISH REPORT pol0892_relat
   IF p_ies_impressao = "S" THEN
      MESSAGE "Relatorio Impresso com Sucesso" ATTRIBUTE(REVERSE)
   ELSE
      LET p_msg = "Relatorio Gravado no Arquivo ", p_nom_arquivo CLIPPED
      MESSAGE p_msg ATTRIBUTE(REVERSE)
   END IF
   ERROR "Fim de Processamento"

END FUNCTION

#------------------------------#
FUNCTION pol0892_limpa_tabelas()
#------------------------------#
  DELETE from ped_itens_fct_547
   WHERE qtd_romaneio = 0 
     AND prog_entrega = qfptran_reg.prog_entrega
  
END FUNCTION

#-----------------------------------#
FUNCTION pol0892_grava_ped_itens_fct()
#-----------------------------------#
   DEFINE l_ano        CHAR(04),
          l_mes        CHAR(02),
          l_dia        CHAR(02),
          l_dat_ch     CHAR(08), 
          l_dat_ent    CHAR(10),
          l_qtd        DECIMAL(15,0),
          l_qtd_solic  DECIMAL(10,3)

  LET l_qtd = qfptran_reg.qtd_solic

  LET l_ano = qfptran_reg.dat_entrega[1,4]
  LET l_mes = qfptran_reg.dat_entrega[5,6]
  LET l_dia = qfptran_reg.dat_entrega[7,8]
  LET l_dat_ent = l_dia,'/',l_mes,'/',l_ano 
         
  LET l_qtd_solic = 0 
  
  SELECT qtd_solic
    INTO l_qtd_solic
    FROM ped_itens_fct_547
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = qfptran_reg.num_pedido
     AND prz_entrega = l_dat_ent 
  
  IF STATUS = 100 THEN
     LET p_ped_itens_fct_547.cod_empresa  = p_cod_empresa
     LET p_ped_itens_fct_547.num_pedido   = qfptran_reg.num_pedido       
     LET p_ped_itens_fct_547.prog_entrega = qfptran_reg.prog_entrega
     LET p_ped_itens_fct_547.cod_item     = qfptran_reg.cod_item
     LET p_ped_itens_fct_547.prz_entrega  = l_dat_ent
     LET p_ped_itens_fct_547.qtd_solic    = l_qtd
     LET p_ped_itens_fct_547.qtd_romaneio = 0
     
     INITIALIZE p_ped_itens_fct_547.dat_alteracao,  
                p_ped_itens_fct_547.dat_romaneio  TO NULL  
                            
     INSERT INTO ped_itens_fct_547 VALUES (p_ped_itens_fct_547.*)
     
     LET p_audit_vdp.cod_empresa = p_cod_empresa
     LET p_audit_vdp.num_pedido = qfptran_reg.num_pedido
     LET p_audit_vdp.tipo_informacao = 'I' 
     LET p_audit_vdp.tipo_movto = 'A'
     LET p_audit_vdp.texto = 'INCLUSAO EDIFACT ENTREGA ',l_dat_ent,' QUANTIDADE ',l_qtd
     LET p_audit_vdp.num_programa = 'POL0892'
     LET p_audit_vdp.data =  TODAY
     LET p_audit_vdp.hora =  TIME 
     LET p_audit_vdp.usuario = p_user
     LET p_audit_vdp.num_transacao = 0  
     INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
     
  ELSE
#     IF l_qtd_solic <> l_qtd THEN  solicitado pelo Felipe / Marcos, alegaram que nao ocorrera duplicidade
        
        LET p_hoje = TODAY 
        
        UPDATE ped_itens_fct_547
           SET qtd_solic = (qtd_solic + l_qtd), 
               dat_alteracao = p_hoje 
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = qfptran_reg.num_pedido
           AND prz_entrega = l_dat_ent 
           
         LET p_audit_vdp.cod_empresa = p_cod_empresa
         LET p_audit_vdp.num_pedido = qfptran_reg.num_pedido
         LET p_audit_vdp.tipo_informacao = 'A' 
         LET p_audit_vdp.tipo_movto = 'A'
         LET p_audit_vdp.texto = 'ALTERACAO EDIFACT ENTREGA DE ',l_dat_ent,' ALTERADA PARA DE ',l_qtd_solic,
                                 ' PARA ',l_qtd
         LET p_audit_vdp.num_programa = 'POL0892'
         LET p_audit_vdp.data =  TODAY
         LET p_audit_vdp.hora =  TIME 
         LET p_audit_vdp.usuario = p_user
         LET p_audit_vdp.num_transacao = 0  
         INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
#     END IF       
  END IF
  
  RETURN TRUE 
    
END FUNCTION 

#---------------------------------#
 FUNCTION pol0892_deleta_qfptran()
#---------------------------------#

   WHENEVER ERROR CONTINUE
   CALL log085_transacao("BEGIN")
   DELETE FROM qfptran 
   IF sqlca.sqlcode = 0 THEN 
      CALL log085_transacao("COMMIT")
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("DELECAO-1","QFPTRAN")
         CALL log085_transacao("ROLLBACK")
      END IF
   ELSE 
      CALL log003_err_sql("DELECAO-2","QFPTRAN")
      CALL log085_transacao("ROLLBACK")
   END IF
   WHENEVER ERROR STOP

END FUNCTION

#------------------------------#
 FUNCTION pol0892_lista_relat()
#------------------------------#
  LET p_imprimir = "NAO"
  
  IF log028_saida_relat(16,37) IS NOT NULL THEN 
     LET p_imprimir = "SIM"
     IF g_ies_ambiente = "W"  THEN 
        IF p_ies_impressao = "S" THEN 
           START REPORT pol0892_relat TO PRINTER
        ELSE 
           START REPORT pol0892_relat TO p_nom_arquivo
        END IF
     ELSE 
        IF p_ies_impressao = "S" THEN 
           START REPORT pol0892_relat TO PIPE p_nom_arquivo
        ELSE 
           START REPORT pol0892_relat TO p_nom_arquivo
        END IF
     END IF
  ELSE 
     LET p_imprimir = "NAO"
  END IF
END FUNCTION

#--------------------------#
REPORT pol0892_relat(l_tipo)
#--------------------------#
   DEFINE l_tipo           CHAR(01),
          l_for            SMALLINT 

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1

  FORMAT
    PAGE HEADER
      PRINT COLUMN   1, p_den_empresa
      PRINT COLUMN   1, "POL0892",
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
          PRINT COLUMN   1, qfptran_reg.cod_item_lin[1,30],
                COLUMN  32, qfptran_reg.cod_item,
                COLUMN  64, qfptran_reg.num_ped_cli[1,30], 
                COLUMN  76, qfptran_reg.num_pedido,
                COLUMN 102, p_observacao
    
       WHEN l_tipo = 2 
         PRINT 

    END CASE 

    ON LAST ROW
      LET p_last_row = true
    PAGE TRAILER
      IF   p_last_row = true
      THEN PRINT "* * * ULTIMA FOLHA * * *"
      ELSE PRINT " "
      END IF
END REPORT

#-----------------------#
 FUNCTION pol0892_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------------- FIM DE PROGRAMA ----------------------------#
