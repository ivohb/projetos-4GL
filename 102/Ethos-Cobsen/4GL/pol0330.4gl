#-------------------------------------------------------------------#
# SISTEMA.: ENVIO DE PROGRAMAÇÃO E RECEBIMENTO DE MATERIAIS VIA EDI #
# PROGRAMA: POL0330                                                 #
# MODULOS.: POL0330 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: ENVIO DE PROGRAMAÇÃO PARA CATERPILLAR                   #
# AUTOR...: LOGOCENTER ABC - ANTONIO CEZAR VIEIRA JUNIOR            #
# DATA....: 25/02/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa         LIKE empresa.cod_empresa,
          p_den_empresa         LIKE empresa.den_empresa,  
          p_user                LIKE usuario.nom_usuario,
          p_status              SMALLINT,
          p_houve_erro          SMALLINT,
          comando               CHAR(80),
          p_comprime            CHAR(01),
          p_descomprime         CHAR(01),
          # p_versao              CHAR(17),
          p_versao              CHAR(18),
          p_ies_impressao       CHAR(001),
          g_ies_ambiente        CHAR(001),
          p_nom_arquivo         CHAR(100),
          p_arquivo             CHAR(025),
          p_last_row            SMALLINT,
          p_caminho             CHAR(080),
          p_nom_tela            CHAR(200),
          p_nom_help            CHAR(200),
          p_r                   CHAR(001),
          p_count               SMALLINT,
          pa_curr               SMALLINT,
          sc_curr               SMALLINT,
          g_usa_visualizador    SMALLINT,
          p_msg                 CHAR(500) 

END GLOBALS
   
   DEFINE m_prz_entrega       DATE,
          m_count             SMALLINT,
          m_tip_relat         CHAR(1),
          m_houve_alter       SMALLINT  

   DEFINE mr_tela  RECORD 
      dat_inicio          DATE,
      dat_final           DATE,
      prz_entrega         DATE,
      ies_firme           CHAR(1),
      ies_requis          CHAR(1),
      ies_planej          CHAR(1) 
   END RECORD 

   DEFINE ma_tela  ARRAY[50] OF RECORD 
      cod_cliente             LIKE clientes.cod_cliente,
      nom_cliente             LIKE clientes.nom_cliente
   END RECORD 
   
   DEFINE ma_edi   ARRAY[20] OF RECORD 
      prz_entrega             DATE,
      saldo                   DECIMAL(18,7) 
   END RECORD 

   DEFINE ma_tela3 ARRAY[100] OF RECORD 
      cod_item                LIKE item.cod_item,
      den_item                LIKE item.den_item_reduz,
      prz_entrega             DATE,
      saldo                   DECIMAL(9,0) 
   END RECORD 

   DEFINE p_ped_itens_qfp_pe512 RECORD LIKE ped_itens_qfp_pe512.*

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0330-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0330.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL pol0330_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0330_controle()
#--------------------------#
   DEFINE l_informou_dados     SMALLINT,
          l_imprime            SMALLINT

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0330") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0330 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
 
   LET l_informou_dados   = FALSE
   LET l_imprime          = FALSE
   LET g_usa_visualizador = TRUE
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa Parâmetros para Gerar Programação."
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0330","IN") THEN
            IF pol0330_informa_dados() THEN
               IF pol0330_informa_clientes() THEN
                  LET l_informou_dados = TRUE
                  NEXT OPTION "Processar"
               END IF 
            END IF
         END IF
     
      COMMAND "Processar" "Efetua Processamento para Gerar a Programação."
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF l_informou_dados THEN
            IF log005_seguranca(p_user,"VDP","pol0330","MO") THEN
               MESSAGE "Processando..." ATTRIBUTE(REVERSE)
               CALL pol0330_processa()
               LET l_informou_dados = FALSE
               LET l_imprime        = TRUE
               LET m_houve_alter    = FALSE
               MESSAGE "Fim do Processamento." ATTRIBUTE(REVERSE)
               NEXT OPTION "Modificar EDI"
            END IF
         ELSE
            ERROR "Informe os parâmetros primeiramente."
            NEXT OPTION "Informar"
         END IF  

      COMMAND KEY ('M') "Modificar EDI" "Gera arquivo EDI da programação de materiais."
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF l_imprime THEN
            IF log005_seguranca(p_user,"VDP","pol0330","MO") THEN
               IF pol0330_modifica_arquivo() THEN
                  LET m_houve_alter = TRUE
                  MESSAGE 'Modificação Efetuada com Sucesso !!!' ATTRIBUTE(REVERSE)
               ELSE
                  LET m_houve_alter = FALSE
               END IF
               NEXT OPTION "Gerar EDI"
            END IF
         ELSE
            ERROR "Informe os parâmetros primeiramente."
            NEXT OPTION "Informar"
         END IF   

      COMMAND KEY ('G') "Gerar EDI" "Gera Arquivo EDI da programação de materiais."
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF l_imprime THEN
            IF log005_seguranca(p_user,"VDP","pol0330","MO") THEN
               CALL pol0330_gera_arquivo()
               NEXT OPTION "Listar"
            END IF
         ELSE
            ERROR "Informe os parâmetros primeiramente."
            NEXT OPTION "Informar"
         END IF   

      COMMAND "Listar" "Imprime Relatório da Programação."
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF l_imprime THEN
            IF log005_seguranca(p_user,"VDP","pol0330","MO") THEN
               IF pol0330_listar() THEN
                  CALL pol0330_imprime_relat()
               ELSE
                  ERROR "Impressão de Relatório Cancelada." 
                  NEXT OPTION "Fim"
               END IF
            END IF
         ELSE
            ERROR "Informe os Parâmetros e Efetue o Processamento."
            NEXT OPTION "Informar"
         END IF   
      
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0330_sobre()
      
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTece ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0330

END FUNCTION
 
#-------------------------------#
 FUNCTION pol0330_informa_dados()
#-------------------------------#
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0330
   INITIALIZE mr_tela.* TO NULL
   INITIALIZE ma_tela TO NULL
   LET p_houve_erro = FALSE
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG =  FALSE
   INPUT BY NAME mr_tela.*  WITHOUT DEFAULTS  

      AFTER FIELD dat_inicio 
         IF mr_tela.dat_inicio IS NULL OR
            mr_tela.dat_inicio = ' ' THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD dat_inicio 
         END IF
    
      AFTER FIELD dat_final 
         IF mr_tela.dat_final IS NULL OR
            mr_tela.dat_final = ' ' THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD dat_final 
         END IF
      
      AFTER FIELD prz_entrega
         IF mr_tela.prz_entrega IS NULL OR
            mr_tela.prz_entrega = ' ' THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD prz_entrega 
         END IF

      BEFORE FIELD ies_firme
          LET mr_tela.ies_firme  = 'S'
          LET mr_tela.ies_requis = 'S'
          LET mr_tela.ies_planej = 'S'
                
      AFTER INPUT
         IF INT_FLAG = 0 THEN
            IF mr_tela.dat_inicio IS NULL OR
               mr_tela.dat_inicio = ' ' THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD dat_inicio
            END IF
            IF mr_tela.dat_final IS NULL OR
               mr_tela.dat_final = ' ' THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD dat_final
            END IF
            IF mr_tela.prz_entrega IS NULL OR
               mr_tela.prz_entrega = ' ' THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD prz_entrega 
            END IF
            IF mr_tela.ies_firme IS NULL OR
               mr_tela.ies_firme = ' ' THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD ies_firme 
            END IF
            IF mr_tela.ies_requis IS NULL OR
               mr_tela.ies_requis = ' ' THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD ies_requis
            END IF
            IF mr_tela.ies_planej IS NULL OR
               mr_tela.ies_planej = ' ' THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD ies_planej
            END IF
         END IF

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0330
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Envio de Programação Cancelada."
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION pol0330_verifica_cliente()
#----------------------------------#

   SELECT nom_cliente 
     INTO ma_tela[pa_curr].nom_cliente 
     FROM clientes
    WHERE cod_cliente = ma_tela[pa_curr].cod_cliente 
   IF sqlca.sqlcode = 0 THEN
      DISPLAY ma_tela[pa_curr].nom_cliente TO s_clientes[sc_curr].nom_cliente
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION           

#----------------------------------#
 FUNCTION pol0330_informa_clientes() 
#----------------------------------#
   DEFINE l_ind              SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0330

   LET INT_FLAG =  FALSE
 
   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_clientes.*

      BEFORE FIELD cod_cliente 
         LET pa_curr   = ARR_CURR()
         LET sc_curr   = SCR_LINE()

      AFTER FIELD cod_cliente 
         IF ma_tela[pa_curr].cod_cliente IS NOT NULL AND
            ma_tela[pa_curr].cod_cliente <> ' ' THEN
            IF pol0330_verifica_cliente() = FALSE THEN
               ERROR 'Cliente não Cadastrado.'
               NEXT FIELD cod_cliente 
            END IF
         END IF

      ON KEY (Control-z)
         CALL pol0330_popup()
 
   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0330
   
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Envio de Programação Cancelada."
      RETURN FALSE
   ELSE
      RETURN TRUE 
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0330_processa()
#--------------------------#
   DEFINE sql_stmt                CHAR(2000),
          l_condicao              CHAR(350),
          l_cod_item              LIKE item.cod_item,
          l_pct_refugo            LIKE item_prog_ethos.pct_refugo,
          l_num_ped_cater         LIKE item_prog_ethos.num_ped_cater,
          l_envia_arquivo         LIKE item_prog_ethos.envia_arquivo,
          l_cod_cliente           LIKE clientes.cod_cliente,
          l_saldo                 DECIMAL(18,7), 
          l_pedido                LIKE pedidos.num_pedido,
          l_cod_item_cat          CHAR(30),
          l_contato               CHAR(11)

   CALL pol0330_cria_temporaria()
   CALL pol0330_carrega_pedidos_carteira()
   CALL pol0330_carrega_pedidos_planejados()
 
   DECLARE cq_pedidos SCROLL CURSOR WITH HOLD FOR
    SELECT *
      FROM w_temp_ethos 
   
   FOREACH cq_pedidos INTO l_pedido, 
                           l_cod_item, 
                           l_cod_cliente, 
                           l_saldo, 
                           m_prz_entrega
      
      IF pol0330_verifica_tip_item(l_cod_item) THEN  
         CALL pol0330_busca_nivel_2(l_pedido, 
                                    l_cod_item, 
                                    l_saldo, 
                                    l_cod_cliente)
      ELSE
         CALL pol0330_busca_dados_item(l_cod_item) 
                     RETURNING l_pct_refugo,
                               l_num_ped_cater,
                               l_envia_arquivo,
                               l_cod_item_cat,
                               l_contato       

         IF l_pct_refugo IS NULL THEN
            LET l_pct_refugo = 0
         END IF

         LET l_saldo = l_saldo + ((l_saldo * l_pct_refugo)/100)
            
         CALL pol0330_insere_tabela_auxiliar(l_pedido,
                                             l_cod_item, 
                                             l_cod_cliente,
                                             l_saldo,
                                             l_num_ped_cater,
                                             l_envia_arquivo,
                                             l_cod_item_cat,
                                             l_contato)
      END IF 
  
   END FOREACH 
 
END FUNCTION

#------------------------------------------# 
 FUNCTION pol0330_carrega_pedidos_carteira()
#------------------------------------------# 
   DEFINE sql_stmt                CHAR(2000),
          l_condicao              CHAR(350),
          l_cod_item              LIKE item.cod_item,
          l_cod_cliente           LIKE clientes.cod_cliente,
          l_saldo                 DECIMAL(18,7),
          l_pedido                LIKE pedidos.num_pedido,
          l_prz_entrega           LIKE ped_itens.prz_entrega

   CALL pol0330_monta_selecao_clientes() RETURNING l_condicao
 
   LET sql_stmt = " SELECT pedidos.num_pedido, ",
                  "        ped_itens.cod_item, ",
                  "        pedidos.cod_cliente, ",
                  "       (ped_itens.qtd_pecas_solic - ",
                  "       (ped_itens.qtd_pecas_atend + ",
                  "        ped_itens.qtd_pecas_cancel + ",
                  "        ped_itens.qtd_pecas_reserv)), ",
                  "        ped_itens.prz_entrega ",
                  "   FROM pedidos, ped_itens ",
                  "  WHERE pedidos.cod_empresa    = '",p_cod_empresa,"'",
                  "    AND pedidos.cod_empresa    = ped_itens.cod_empresa ",
                  "    AND pedidos.num_pedido     = ped_itens.num_pedido ",
                  "    AND pedidos.ies_sit_pedido <> '9' ",
                  "    AND (qtd_pecas_solic - (qtd_pecas_atend + ",
                                             " qtd_pecas_cancel + ",
                                             " qtd_pecas_reserv)) > 0 ",
                  "    AND ped_itens.prz_entrega  >= '",mr_tela.dat_inicio,"'",
                  "    AND ped_itens.prz_entrega  <= '",mr_tela.dat_final,"'"
                              
   IF l_condicao IS NOT NULL AND
      l_condicao <> ' ' THEN
      LET sql_stmt = sql_stmt CLIPPED,
                     " AND pedidos.cod_cliente IN (",l_condicao CLIPPED,")"
   END IF

   PREPARE var_query FROM sql_stmt
   DECLARE cq_pedidos_1 SCROLL CURSOR WITH HOLD FOR var_query

   FOREACH cq_pedidos_1 INTO l_pedido,
                             l_cod_item,
                             l_cod_cliente,
                             l_saldo,
                             l_prz_entrega

      INSERT INTO w_temp_ethos VALUES (l_pedido,
                                       l_cod_item,
                                       l_cod_cliente,
                                       l_saldo,
                                       l_prz_entrega)
   
   END FOREACH              

END FUNCTION

#--------------------------------------------#
 FUNCTION pol0330_carrega_pedidos_planejados()
#--------------------------------------------#
   DEFINE sql_stmt1               CHAR(2000),
          l_condicao              CHAR(350),
          l_cod_item              LIKE item.cod_item,
          l_num_sequencia         LIKE ped_itens.num_sequencia,
          l_cod_cliente           LIKE clientes.cod_cliente,
          l_saldo                 DECIMAL(18,7),
          l_pedido                LIKE pedidos.num_pedido,
          l_prz_entrega           LIKE ped_itens.prz_entrega,
          l_ok                    CHAR(01)

   CALL pol0330_monta_selecao_clientes() RETURNING l_condicao
 
   LET sql_stmt1 = 
      " SELECT pedidos.num_pedido, ",
      "        ped_itens_qfp_512.cod_item, ",
      "        ped_itens_qfp_512.num_sequencia, ",
      "        pedidos.cod_cliente, ",
      "        ped_itens_qfp_512.qtd_solic, ",
      "        ped_itens_qfp_512.prz_entrega ",
      "   FROM pedidos, ped_itens_qfp_512 ",
      "  WHERE pedidos.cod_empresa    = '",p_cod_empresa,"'",
      "    AND pedidos.cod_empresa    = ped_itens_qfp_512.cod_empresa ",
      "    AND pedidos.num_pedido     = ped_itens_qfp_512.num_pedido ",
      "    AND pedidos.ies_sit_pedido <> '9' ",
      "    AND ped_itens_qfp_512.prz_entrega >= '",mr_tela.dat_inicio,"'",
      "    AND ped_itens_qfp_512.prz_entrega <= '",mr_tela.dat_final,"'",
      "    AND NOT EXISTS ",
              " (SELECT * ",
              "    FROM ped_itens ", 
              "   WHERE ped_itens.cod_empresa = ped_itens_qfp_512.cod_empresa ",
              "     AND ped_itens.num_pedido  = ped_itens_qfp_512.num_pedido ",
              "     AND ped_itens.cod_item    = ped_itens_qfp_512.cod_item ",
              "     AND ped_itens.prz_entrega = ped_itens_qfp_512.prz_entrega )"   
 
   IF l_condicao IS NOT NULL AND
      l_condicao <> ' ' THEN
      LET sql_stmt1 = sql_stmt1 CLIPPED,
                     " AND pedidos.cod_cliente IN (",l_condicao CLIPPED,")"
   END IF

   PREPARE var_query1 FROM sql_stmt1
   DECLARE cq_pedidos_2 SCROLL CURSOR WITH HOLD FOR var_query1

   FOREACH cq_pedidos_2 INTO l_pedido,
                             l_cod_item,
                             l_num_sequencia,
                             l_cod_cliente,
                             l_saldo,
                             l_prz_entrega

     SELECT * 
        INTO p_ped_itens_qfp_pe512.*
        FROM ped_itens_qfp_pe512
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = l_pedido 
         AND num_sequencia = l_num_sequencia
         AND cod_item = l_cod_item       

      IF p_ped_itens_qfp_pe512.ies_programacao = "8" THEN
         CONTINUE FOREACH      
      END IF

      LET l_ok ="N"     
      IF mr_tela.ies_firme  = "S"  AND 
         mr_tela.ies_requis = "S"  AND 
         mr_tela.ies_planej = "S"  THEN 
         LET l_ok ="S"     
      ELSE 
         IF p_ped_itens_qfp_pe512.ies_programacao = "1" AND 
            mr_tela.ies_firme = "S" THEN
            LET l_ok ="S"     
         ELSE 
            IF p_ped_itens_qfp_pe512.ies_programacao = "3" AND 
               mr_tela.ies_requis= "S" THEN
               LET l_ok ="S"     
            ELSE 
               IF p_ped_itens_qfp_pe512.ies_programacao = "4" AND 
                  mr_tela.ies_planej= "S" THEN
                  LET l_ok ="S"     
               END IF
            END IF
         END IF
      END IF

      IF l_ok = "N" THEN
         CONTINUE FOREACH
      END IF 

      INSERT INTO w_temp_ethos VALUES (l_pedido,
                                       l_cod_item,
                                       l_cod_cliente,
                                       l_saldo,
                                       l_prz_entrega)

   END FOREACH              

END FUNCTION

#---------------------------------------------------------------------------#
 FUNCTION pol0330_busca_nivel_2(l_pedido, l_cod_item, l_saldo, l_cod_cliente)
#---------------------------------------------------------------------------#
   DEFINE l_cod_item           LIKE item.cod_item,
          l_qtd_necessaria     LIKE estrutura.qtd_necessaria,
          l_saldo              DECIMAL(18,7), 
          l_saldo_1            DECIMAL(18,7), 
          l_cod_cliente        LIKE clientes.cod_cliente,
          l_cod_item_comp      LIKE item.cod_item,
          l_pct_refugo         LIKE item_prog_ethos.pct_refugo,
          l_num_ped_cater      LIKE item_prog_ethos.num_ped_cater,
          l_envia_arquivo      LIKE item_prog_ethos.envia_arquivo,
          l_pedido             LIKE pedidos.num_pedido,
          l_cod_item_cat       CHAR(30),
          l_contato            CHAR(11)
         
   DECLARE cq_est2 CURSOR WITH HOLD FOR
    SELECT UNIQUE cod_item_compon, qtd_necessaria
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = l_cod_item
       AND (dat_validade_fim >= m_prz_entrega
        OR  dat_validade_fim IS NULL)

   FOREACH cq_est2 INTO l_cod_item_comp, l_qtd_necessaria

      IF pol0330_verifica_tip_item(l_cod_item_comp) THEN
        
         LET l_saldo_1 = 0 
         LET l_saldo_1 = l_saldo * l_qtd_necessaria
 
         CALL pol0330_busca_nivel_3(l_pedido, 
                                    l_cod_item_comp, 
                                    l_saldo_1, 
                                    l_cod_cliente)
      ELSE
         CALL pol0330_busca_dados_item(l_cod_item_comp) 
                 RETURNING l_pct_refugo,
                           l_num_ped_cater,
                           l_envia_arquivo,
                           l_cod_item_cat,
                           l_contato       
         
         IF l_pct_refugo IS NULL THEN
            LET l_pct_refugo = 0
         END IF

         LET l_saldo_1 = l_saldo * l_qtd_necessaria

         LET l_saldo_1 = l_saldo_1 + ((l_saldo_1 * l_pct_refugo)/100) 

         CALL pol0330_insere_tabela_auxiliar(l_pedido,
                                             l_cod_item_comp,
                                             l_cod_cliente,
                                             l_saldo_1,
                                             l_num_ped_cater,
                                             l_envia_arquivo,
                                             l_cod_item_cat,
                                             l_contato)
      END IF           
   END FOREACH

END FUNCTION

#---------------------------------------------------------------------------#
 FUNCTION pol0330_busca_nivel_3(l_pedido, l_cod_item, l_saldo, l_cod_cliente)
#---------------------------------------------------------------------------#
   DEFINE l_cod_item           LIKE item.cod_item,
          l_qtd_necessaria     LIKE estrutura.qtd_necessaria,
          l_saldo              DECIMAL(18,7), 
          l_saldo_1            DECIMAL(18,7), 
          l_cod_cliente        LIKE clientes.cod_cliente,
          l_cod_item_comp      LIKE item.cod_item,
          l_pct_refugo         LIKE item_prog_ethos.pct_refugo,
          l_num_ped_cater      LIKE item_prog_ethos.num_ped_cater,
          l_envia_arquivo      LIKE item_prog_ethos.envia_arquivo,
          l_pedido             LIKE pedidos.num_pedido,
          l_cod_item_cat       CHAR(30),
          l_contato            CHAR(11)
         
   DECLARE cq_est3 CURSOR WITH HOLD FOR
    SELECT UNIQUE cod_item_compon, qtd_necessaria
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = l_cod_item
       AND (dat_validade_fim >= m_prz_entrega
        OR  dat_validade_fim IS NULL)
   FOREACH cq_est3 INTO l_cod_item_comp, l_qtd_necessaria

      IF pol0330_verifica_tip_item(l_cod_item_comp) THEN
         
         LET l_saldo_1 = 0
         LET l_saldo_1 = l_saldo * l_qtd_necessaria
         
         CALL pol0330_busca_nivel_4(l_pedido, 
                                    l_cod_item_comp, 
                                    l_saldo_1, 
                                    l_cod_cliente)
      ELSE
         CALL pol0330_busca_dados_item(l_cod_item_comp)
                    RETURNING l_pct_refugo,
                              l_num_ped_cater,
                              l_envia_arquivo,
                              l_cod_item_cat,
                              l_contato       

         IF l_pct_refugo IS NULL THEN
            LET l_pct_refugo = 0
         END IF
         
         LET l_saldo_1 = l_saldo * l_qtd_necessaria

         LET l_saldo_1 = l_saldo_1 + ((l_saldo_1 * l_pct_refugo)/100) 

         CALL pol0330_insere_tabela_auxiliar(l_pedido,
                                             l_cod_item_comp,
                                             l_cod_cliente,
                                             l_saldo_1,
                                             l_num_ped_cater,
                                             l_envia_arquivo,
                                             l_cod_item_cat,
                                             l_contato)   
      END IF                                 

   END FOREACH

END FUNCTION

#---------------------------------------------------------------------------#
 FUNCTION pol0330_busca_nivel_4(l_pedido, l_cod_item, l_saldo, l_cod_cliente)
#---------------------------------------------------------------------------#
   DEFINE l_cod_item           LIKE item.cod_item,
          l_qtd_necessaria     LIKE estrutura.qtd_necessaria,
          l_saldo              DECIMAL(18,7), 
          l_saldo_1            DECIMAL(18,7), 
          l_cod_cliente        LIKE clientes.cod_cliente,
          l_cod_item_comp      LIKE item.cod_item,
          l_pct_refugo         LIKE item_prog_ethos.pct_refugo,
          l_num_ped_cater      LIKE item_prog_ethos.num_ped_cater,
          l_envia_arquivo      LIKE item_prog_ethos.envia_arquivo,
          l_pedido             LIKE pedidos.num_pedido,
          l_cod_item_cat       CHAR(30),
          l_contato            CHAR(11)
         
   DECLARE cq_est4 CURSOR WITH HOLD FOR
    SELECT UNIQUE cod_item_compon, qtd_necessaria
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = l_cod_item
       AND (dat_validade_fim >= m_prz_entrega
        OR  dat_validade_fim IS NULL)
   FOREACH cq_est4 INTO l_cod_item_comp, l_qtd_necessaria

      IF pol0330_verifica_tip_item(l_cod_item_comp) THEN
         
         LET l_saldo_1 = 0 
         LET l_saldo_1 = l_saldo * l_qtd_necessaria
         
         CALL pol0330_busca_nivel_5(l_pedido,
                                    l_cod_item_comp, 
                                    l_saldo_1, 
                                    l_cod_cliente)
      ELSE
         CALL pol0330_busca_dados_item(l_cod_item_comp) 
                 RETURNING l_pct_refugo,
                           l_num_ped_cater,
                           l_envia_arquivo,
                           l_cod_item_cat,
                           l_contato       

         IF l_pct_refugo IS NULL THEN
            LET l_pct_refugo = 0
         END IF
         
         LET l_saldo_1 = l_saldo * l_qtd_necessaria

         LET l_saldo_1 = l_saldo_1 + ((l_saldo_1 * l_pct_refugo)/100) 

         CALL pol0330_insere_tabela_auxiliar(l_pedido,
                                             l_cod_item_comp,
                                             l_cod_cliente,
                                             l_saldo_1,
                                             l_num_ped_cater,
                                             l_envia_arquivo,
                                             l_cod_item_cat,
                                             l_contato)  
      END IF

   END FOREACH

END FUNCTION

#---------------------------------------------------------------------------#
 FUNCTION pol0330_busca_nivel_5(l_pedido, l_cod_item, l_saldo, l_cod_cliente)
#---------------------------------------------------------------------------#
   DEFINE l_cod_item           LIKE item.cod_item,
          l_qtd_necessaria     LIKE estrutura.qtd_necessaria,
          l_saldo              DECIMAL(18,7), 
          l_saldo_1            DECIMAL(18,7), 
          l_cod_cliente        LIKE clientes.cod_cliente,
          l_cod_item_comp      LIKE item.cod_item,
          l_pct_refugo         LIKE item_prog_ethos.pct_refugo,
          l_num_ped_cater      LIKE item_prog_ethos.num_ped_cater,
          l_envia_arquivo      LIKE item_prog_ethos.envia_arquivo,
          l_pedido             LIKE pedidos.num_pedido,
          l_cod_item_cat       CHAR(30),
          l_contato            CHAR(11)
         
   DECLARE cq_est5 CURSOR WITH HOLD FOR
    SELECT UNIQUE cod_item_compon, qtd_necessaria
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = l_cod_item
       AND (dat_validade_fim >= m_prz_entrega
        OR  dat_validade_fim IS NULL)
   FOREACH cq_est5 INTO l_cod_item_comp, l_qtd_necessaria
     
      IF pol0330_verifica_tip_item(l_cod_item_comp) THEN
        
         LET l_saldo_1 = 0
         LET l_saldo_1 = l_saldo * l_qtd_necessaria
        
         CALL pol0330_busca_nivel_6(l_pedido,
                                    l_cod_item_comp, 
                                    l_saldo_1, 
                                    l_cod_cliente)
      ELSE
         CALL pol0330_busca_dados_item(l_cod_item_comp) 
                 RETURNING l_pct_refugo,
                           l_num_ped_cater,
                           l_envia_arquivo,
                           l_cod_item_cat,
                           l_contato       

         IF l_pct_refugo IS NULL THEN
            LET l_pct_refugo = 0
         END IF
         
         LET l_saldo_1 = l_saldo * l_qtd_necessaria

         LET l_saldo_1 = l_saldo_1 + ((l_saldo_1 * l_pct_refugo)/100) 

         CALL pol0330_insere_tabela_auxiliar(l_pedido,
                                             l_cod_item_comp,
                                             l_cod_cliente,
                                             l_saldo_1,
                                             l_num_ped_cater,
                                             l_envia_arquivo,
                                             l_cod_item_cat,
                                             l_contato)
      END IF          

   END FOREACH

END FUNCTION

#---------------------------------------------------------------------------#
 FUNCTION pol0330_busca_nivel_6(l_pedido, l_cod_item, l_saldo, l_cod_cliente)
#---------------------------------------------------------------------------#
   DEFINE l_cod_item           LIKE item.cod_item,
          l_qtd_necessaria     LIKE estrutura.qtd_necessaria,
          l_saldo              DECIMAL(18,7), 
          l_saldo_1            DECIMAL(18,7), 
          l_cod_cliente        LIKE clientes.cod_cliente,
          l_cod_item_comp      LIKE item.cod_item,
          l_pct_refugo         LIKE item_prog_ethos.pct_refugo,
          l_num_ped_cater      LIKE item_prog_ethos.num_ped_cater,
          l_envia_arquivo      LIKE item_prog_ethos.envia_arquivo,
          l_pedido             LIKE pedidos.num_pedido,
          l_cod_item_cat       CHAR(30),
          l_contato            CHAR(11)
         
   DECLARE cq_est6 CURSOR WITH HOLD FOR
    SELECT UNIQUE cod_item_compon, qtd_necessaria
      FROM estrutura                               
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = l_cod_item
       AND (dat_validade_fim >= m_prz_entrega
        OR  dat_validade_fim IS NULL)
   FOREACH cq_est6 INTO l_cod_item_comp, l_qtd_necessaria
 
      IF pol0330_verifica_tip_item(l_cod_item_comp) THEN
         
         LET l_saldo_1 = 0
         LET l_saldo_1 = l_saldo * l_qtd_necessaria
         
         CALL pol0330_busca_nivel_7(l_pedido,
                                    l_cod_item_comp, 
                                    l_saldo_1, 
                                    l_cod_cliente)
      ELSE
         CALL pol0330_busca_dados_item(l_cod_item_comp) 
                RETURNING l_pct_refugo,
                          l_num_ped_cater,
                          l_envia_arquivo,
                          l_cod_item_cat,
                          l_contato       

         IF l_pct_refugo IS NULL THEN
            LET l_pct_refugo = 0
         END IF
         
         LET l_saldo_1 = l_saldo * l_qtd_necessaria

         LET l_saldo_1 = l_saldo_1 + ((l_saldo_1 * l_pct_refugo)/100)

         CALL pol0330_insere_tabela_auxiliar(l_pedido,
                                             l_cod_item_comp,
                                             l_cod_cliente,
                                             l_saldo_1,
                                             l_num_ped_cater,
                                             l_envia_arquivo,
                                             l_cod_item_cat,
                                             l_contato)
      END IF          

   END FOREACH                   

END FUNCTION

#---------------------------------------------------------------------------#
 FUNCTION pol0330_busca_nivel_7(l_pedido, l_cod_item, l_saldo, l_cod_cliente)
#---------------------------------------------------------------------------#
   DEFINE l_cod_item           LIKE item.cod_item,
          l_qtd_necessaria     LIKE estrutura.qtd_necessaria,
          l_saldo              DECIMAL(18,7), 
          l_saldo_1            DECIMAL(18,7), 
          l_cod_cliente        LIKE clientes.cod_cliente,
          l_cod_item_comp      LIKE item.cod_item,
          l_pct_refugo         LIKE item_prog_ethos.pct_refugo,
          l_num_ped_cater      LIKE item_prog_ethos.num_ped_cater,
          l_envia_arquivo      LIKE item_prog_ethos.envia_arquivo,
          l_pedido             LIKE pedidos.num_pedido,
          l_cod_item_cat       CHAR(30),
          l_contato            CHAR(11)
         
   DECLARE cq_est7 CURSOR WITH HOLD FOR
    SELECT UNIQUE cod_item_compon, qtd_necessaria
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = l_cod_item
       AND (dat_validade_fim >= m_prz_entrega
        OR  dat_validade_fim IS NULL)
   FOREACH cq_est7 INTO l_cod_item_comp, l_qtd_necessaria
    
      IF pol0330_verifica_tip_item(l_cod_item_comp) THEN
         
         LET l_saldo_1 = 0
         LET l_saldo_1 = l_saldo * l_qtd_necessaria

         CALL pol0330_busca_nivel_8(l_pedido,
                                    l_cod_item_comp, 
                                    l_saldo_1, 
                                    l_cod_cliente)
      ELSE
         CALL pol0330_busca_dados_item(l_cod_item_comp)
                RETURNING l_pct_refugo,
                          l_num_ped_cater,
                          l_envia_arquivo,
                          l_cod_item_cat,
                          l_contato       

         IF l_pct_refugo IS NULL THEN
            LET l_pct_refugo = 0
         END IF
         
         LET l_saldo_1 = l_saldo * l_qtd_necessaria

         LET l_saldo_1 = l_saldo_1 + ((l_saldo_1 * l_pct_refugo)/100) 

         CALL pol0330_insere_tabela_auxiliar(l_pedido,
                                             l_cod_item_comp,
                                             l_cod_cliente,
                                             l_saldo_1,
                                             l_num_ped_cater,
                                             l_envia_arquivo,
                                             l_cod_item_cat,
                                             l_contato)
      END IF          
 
   END FOREACH

END FUNCTION

#---------------------------------------------------------------------------#
 FUNCTION pol0330_busca_nivel_8(l_pedido, l_cod_item, l_saldo, l_cod_cliente)
#---------------------------------------------------------------------------#
   DEFINE l_cod_item           LIKE item.cod_item,
          l_qtd_necessaria     LIKE estrutura.qtd_necessaria,
          l_saldo              DECIMAL(18,7), 
          l_saldo_1            DECIMAL(18,7), 
          l_cod_cliente        LIKE clientes.cod_cliente,
          l_cod_item_comp      LIKE item.cod_item,
          l_pct_refugo         LIKE item_prog_ethos.pct_refugo,
          l_num_ped_cater      LIKE item_prog_ethos.num_ped_cater,
          l_envia_arquivo      LIKE item_prog_ethos.envia_arquivo,
          l_pedido             LIKE pedidos.num_pedido,
          l_cod_item_cat       CHAR(30),
          l_contato            CHAR(11)
         
   DECLARE cq_est8 CURSOR WITH HOLD FOR
    SELECT UNIQUE cod_item_compon, qtd_necessaria
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = l_cod_item
       AND (dat_validade_fim >= m_prz_entrega
        OR  dat_validade_fim IS NULL)
   FOREACH cq_est8 INTO l_cod_item_comp, l_qtd_necessaria

      IF pol0330_verifica_tip_item(l_cod_item_comp) THEN
         CALL pol0330_busca_dados_item(l_cod_item_comp) 
                RETURNING l_pct_refugo,
                          l_num_ped_cater,
                          l_envia_arquivo,
                          l_cod_item_cat,
                          l_contato       

         IF l_pct_refugo IS NULL THEN
            LET l_pct_refugo = 0
         END IF
         
         LET l_saldo_1 = 0
         LET l_saldo_1 = l_saldo * l_qtd_necessaria

         LET l_saldo_1 = l_saldo_1 + ((l_saldo_1 * l_pct_refugo)/100) 

         CALL pol0330_insere_tabela_auxiliar(l_pedido,
                                             l_cod_item_comp,
                                             l_cod_cliente,
                                             l_saldo_1,
                                             l_num_ped_cater,
                                             l_envia_arquivo,
                                             l_cod_item_cat,
                                             l_contato)
      END IF          
  
   END FOREACH

END FUNCTION

#---------------------------------------------#         
 FUNCTION pol0330_verifica_tip_item(l_cod_item)
#---------------------------------------------#         
   DEFINE l_cod_item              LIKE item.cod_item,
          l_tipo_item             LIKE item.ies_tip_item

   SELECT ies_tip_item
     INTO l_tipo_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = l_cod_item   
   
   IF l_tipo_item <> 'P' AND  
      l_tipo_item <> 'B' AND 
      l_tipo_item <> 'F' AND
      l_tipo_item <> 'T' THEN
      RETURN FALSE 
   ELSE
      RETURN TRUE 
   END IF 
   
END FUNCTION

#--------------------------------------------#
 FUNCTION pol0330_busca_dados_item(l_cod_item)
#--------------------------------------------#
   DEFINE l_cod_item              LIKE item.cod_item,
          l_pct_refugo            LIKE item_prog_ethos.pct_refugo,
          l_num_ped_cater         LIKE item_prog_ethos.num_ped_cater,
          l_envia_arquivo         LIKE item_prog_ethos.envia_arquivo,
          l_cod_item_cat          CHAR(30),
          l_contato               CHAR(11) 

   SELECT pct_refugo, 
          num_ped_cater, 
          envia_arquivo, 
          cod_item_cat,   
          contato
     INTO l_pct_refugo, 
          l_num_ped_cater, 
          l_envia_arquivo, 
          l_cod_item_cat, 
          l_contato
     FROM item_prog_ethos
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = l_cod_item

   RETURN l_pct_refugo,
          l_num_ped_cater, 
          l_envia_arquivo, 
          l_cod_item_cat, 
          l_contato

END FUNCTION

#-------------------------------------------------------#
 FUNCTION pol0330_insere_tabela_auxiliar(l_pedido,
                                         l_cod_item,
                                         l_cliente,
                                         l_saldo,
                                         l_num_ped_cater,
                                         l_envia_arquivo,
                                         l_cod_item_cat,
                                         l_contato)
#-------------------------------------------------------#
   DEFINE l_cod_item                   LIKE item.cod_item,
          l_cliente                    LIKE clientes.cod_cliente,
          l_saldo                      DECIMAL(18,7), 
          l_num_ped_cater              LIKE item_prog_ethos.num_ped_cater,
          l_envia_arquivo              LIKE item_prog_ethos.envia_arquivo,
          l_pedido                     LIKE pedidos.num_pedido,
          l_cod_item_cat               CHAR(30),
          l_contato                    CHAR(11)

   CALL log085_transacao("BEGIN")
   # BEGIN WORK

   WHENEVER ERROR CONTINUE
     INSERT INTO w_edi_caterpillar VALUES (p_cod_empresa,
                                           l_pedido,
                                           l_cod_item,
                                           l_cliente,
                                           l_saldo,
                                           l_num_ped_cater,
                                           l_envia_arquivo,
                                           l_cod_item_cat,
                                           l_contato,
                                           mr_tela.prz_entrega)
   WHENEVER ERROR STOP 
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INCLUSAO","EDI_CATERPILLAR")
      CALL log085_transacao("ROLLBACK")
      # ROLLBACK WORK
   ELSE
      CALL log085_transacao("COMMIT")
      # COMMIT WORK
   END IF
 
END FUNCTION

#----------------------------------------#
 FUNCTION pol0330_monta_selecao_clientes()
#----------------------------------------#
   DEFINE l_condicao             CHAR(350),
          l_ind                  SMALLINT 

   LET l_condicao = ' '

   FOR l_ind = 1 TO 20
      IF ma_tela[l_ind].cod_cliente IS NOT NULL AND
         ma_tela[l_ind].cod_cliente <> ' ' THEN
         LET l_condicao = l_condicao CLIPPED,
             ',"',ma_tela[l_ind].cod_cliente, '"' 
      END IF
   END FOR

   LET l_condicao = l_condicao[2,350]

   RETURN l_condicao

END FUNCTION

#---------------------------------#
 FUNCTION pol0330_cria_temporaria()
#---------------------------------#

   WHENEVER ERROR CONTINUE
       DROP TABLE w_edi_caterpillar;
       DROP TABLE t_edi_caterpillar;
       DROP TABLE w_temp_ethos;
   WHENEVER ERROR STOP

   CREATE TABLE w_edi_caterpillar 
      (
       cod_empresa              CHAR(2),
       pedido                   DECIMAL(6,0),
       cod_item                 CHAR(15),
       cod_cliente              CHAR(15),
       saldo                    DECIMAL(18,7),
       num_ped_cater            CHAR(12), 
       envia_arquivo            CHAR(1),
       cod_item_cat             CHAR(30),
       contato                  CHAR(11),
       prz_entrega              DATE  
      )

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","W_EDI_CATERPILLAR")
   END IF

   CREATE TABLE t_edi_caterpillar 
      (
       cod_item                 CHAR(15),
       prz_entrega              DATE,  
       saldo                    DECIMAL(18,7)
      )

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","T_EDI_CATERPILLAR")
   END IF

   CREATE TABLE w_temp_ethos
      (
       pedido                   DECIMAL(6,0),
       cod_item                 CHAR(15),
       cod_cliente              CHAR(15),
       saldo                    DECIMAL(18,7),
       prz_entrega              DATE
      )                     

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","W_TEMP_ETHOS")
   END IF

END FUNCTION              

#-----------------------#
 FUNCTION pol0330_popup()
#-----------------------#
   CASE
      WHEN INFIELD(cod_cliente)
         CALL vdp372_popup_cliente() RETURNING ma_tela[pa_curr].cod_cliente
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0330
         DISPLAY ma_tela[pa_curr].cod_cliente TO s_clientes[sc_curr].cod_cliente
         CALL pol0330_verifica_cliente() RETURNING p_status
      
      WHEN INFIELD(cod_item)
         CALL min071_popup_item(p_cod_empresa) RETURNING ma_tela3[pa_curr].cod_item
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0330
         DISPLAY ma_tela3[pa_curr].cod_item TO s_edi[sc_curr].cod_item
         CALL pol0330_verifica_item() RETURNING p_status       
   END CASE

END FUNCTION
 
#------------------------#
 FUNCTION pol0330_listar()
#------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log1300_procura_caminho("pol03301","pol03302") RETURNING p_nom_tela
   # CALL log130_procura_caminho("pol03301") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol03301 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG =  FALSE
   
   INPUT m_tip_relat WITHOUT DEFAULTS
    FROM tip_relat 

      AFTER FIELD tip_relat 
         IF m_tip_relat IS NULL OR
            m_tip_relat = ' ' THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD tip_relat 
         ELSE
            IF m_tip_relat <> 'C' AND
               m_tip_relat <> 'G' THEN
               ERROR 'Valor Inválido'
               NEXT FIELD tip_relat 
            END IF   
         END IF

    END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   
   IF INT_FLAG THEN
      CURRENT WINDOW IS w_pol0330
      CLOSE WINDOW w_pol03301
      RETURN FALSE
   END IF

   CURRENT WINDOW IS w_pol0330
   CLOSE WINDOW w_pol03301
   RETURN TRUE

END FUNCTION

#-------------------------------#  
 FUNCTION pol0330_imprime_relat()
#-------------------------------#  
   IF log028_saida_relat(13,29) IS NOT NULL THEN
      MESSAGE " Processando a Extração do Relatório..." ATTRIBUTE(REVERSE)
      IF p_ies_impressao = "S" THEN
         IF g_ies_ambiente = "U" THEN
            START REPORT pol0330_relat TO PIPE p_nom_arquivo
         ELSE
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'pol0330.tmp'
            START REPORT pol0330_relat  TO p_caminho
         END IF
      ELSE
         START REPORT pol0330_relat TO p_nom_arquivo
      END IF

      CALL pol0330_emite_relatorio()
 
      IF p_count = 0 THEN
         MESSAGE "Não Existem Dados para serem Listados" ATTRIBUTE(REVERSE)
         RETURN
      ELSE
         ERROR "Relatório Processado com Sucesso"
      END IF
      FINISH REPORT pol0330_relat
   ELSE                       
      ERROR "Listagem Cancelada."
      RETURN
   END IF
   IF p_ies_impressao = "S" THEN
      MESSAGE "Relatório Impresso na Impressora ", p_nom_arquivo
          ATTRIBUTE(REVERSE)
      IF g_ies_ambiente = "W" THEN
         LET comando = "lpdos.bat ", p_caminho CLIPPED, " ",p_nom_arquivo
         RUN comando
      END IF
   ELSE
      MESSAGE "Relatório Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
   END IF

   IF p_ies_impressao = "V" THEN
      CALL log028_visualiza_arquivo(p_nom_arquivo)
   END IF
   
END FUNCTION                               

#---------------------------------#
 FUNCTION pol0330_emite_relatorio()
#---------------------------------#
   DEFINE sql_stmt_1            CHAR(600)
 
   DEFINE lr_relat          RECORD   
       cod_item                 CHAR(15),
       den_item                 CHAR(76),
       prz_entrega              DATE,
       cod_unid_med             CHAR(3),
       saldo                    DECIMAL(18,7),
       chapas                   DECIMAL(9,0),
       pct_refugo               DECIMAL(5,2),
       tip_item                 CHAR(1)    
                            END RECORD

   DEFINE l_qtd_item            DECIMAL(18,7),
          l_qtd                 CHAR(19),
          l_inteiro             INTEGER,
          l_decimal             INTEGER,
          l_peso_item           LIKE item_prog_ethos.peso_item
          
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   IF m_houve_alter THEN
      LET sql_stmt_1 = " SELECT a.cod_item, ",
                       "        a.prz_entrega, ",
                       "        SUM(a.saldo) ",
                       "   FROM t_edi_caterpillar a ",
                       "  GROUP BY 1, 2 "
      
      IF m_tip_relat <> 'C' THEN
         LET sql_stmt_1 = sql_stmt_1 CLIPPED,
                       "  UNION ALL ",
                       " SELECT b.cod_item, ",
                       "        b.prz_entrega, ",
                       "    SUM(b.saldo/ (SELECT c.peso_item ",
                                          " FROM item_prog_ethos c ",
                                         " WHERE c.cod_empresa = b.cod_empresa ",
                                         "   AND c.cod_item    = b.cod_item )) ",
                       "   FROM w_edi_caterpillar b ",
                       "  WHERE (b.envia_arquivo <> 'S' OR ",
                       "         b.envia_arquivo IS NULL) ",
                       "  GROUP BY 1, 2 "
      END IF  
      
      LET sql_stmt_1 = sql_stmt_1 CLIPPED, "  ORDER BY 1, 2 "
                                           
      PREPARE var_query_1 FROM sql_stmt_1
      DECLARE cq_relat SCROLL CURSOR WITH HOLD FOR var_query_1
      
      FOREACH cq_relat INTO lr_relat.cod_item,
                            lr_relat.prz_entrega,
                            lr_relat.saldo
      
         SELECT den_item, cod_unid_med, ies_tip_item 
           INTO lr_relat.den_item, lr_relat.cod_unid_med, lr_relat.tip_item
           FROM item 
          WHERE cod_empresa = p_cod_empresa 
            AND cod_item    = lr_relat.cod_item 
      
         SELECT pct_refugo
           INTO lr_relat.pct_refugo
           FROM item_prog_ethos
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = lr_relat.cod_item

         LET l_qtd     = lr_relat.saldo USING '&&&&&&&&&&&.&&&&&&&'
         LET l_inteiro = l_qtd[1,11]
         LET l_decimal = l_qtd[13,19]
          
         IF l_decimal > 0 THEN
            LET l_qtd_item = l_inteiro + 1
         ELSE
            LET l_qtd_item = l_inteiro + 0
         END IF
            
         LET lr_relat.chapas = l_qtd_item USING '&&&&&&&&&'
         
         IF lr_relat.saldo IS NULL THEN
            SELECT SUM(saldo)
              INTO lr_relat.saldo
              FROM w_edi_caterpillar
             WHERE (envia_arquivo <> 'S' OR
                    envia_arquivo IS NULL)
               AND cod_item      = lr_relat.cod_item
               AND prz_entrega   = lr_relat.prz_entrega
         ELSE   
            SELECT SUM(saldo)
              INTO lr_relat.saldo
              FROM w_edi_caterpillar
             WHERE envia_arquivo = 'S'
               AND cod_item      = lr_relat.cod_item
               AND prz_entrega   = lr_relat.prz_entrega
         END IF
         
         OUTPUT TO REPORT pol0330_relat(lr_relat.*)
      
         INITIALIZE lr_relat.* TO NULL 
         LET p_count = p_count + 1
      
      END FOREACH
   ELSE
      LET sql_stmt_1 = " SELECT cod_item, ",
                       "    SUM(saldo) ",
                       "   FROM w_edi_caterpillar " 

      IF m_tip_relat = 'C' THEN
         LET sql_stmt_1 = sql_stmt_1 CLIPPED,
                          " WHERE envia_arquivo = 'S' "
      END IF
   
      LET sql_stmt_1 = sql_stmt_1 CLIPPED,
                       "  GROUP BY cod_item ",
                       "  ORDER BY cod_item "
   
      PREPARE var_query_4 FROM sql_stmt_1
      DECLARE cq_relat_2 SCROLL CURSOR WITH HOLD FOR var_query_4
      
      FOREACH cq_relat_2 INTO lr_relat.cod_item,
                              lr_relat.saldo
      
         SELECT den_item, cod_unid_med, ies_tip_item 
           INTO lr_relat.den_item, lr_relat.cod_unid_med, lr_relat.tip_item
           FROM item 
          WHERE cod_empresa = p_cod_empresa 
            AND cod_item    = lr_relat.cod_item 
      
         LET l_peso_item = 0
         
         SELECT pct_refugo, peso_item
           INTO lr_relat.pct_refugo, l_peso_item
           FROM item_prog_ethos
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = lr_relat.cod_item
      
         LET l_qtd_item = lr_relat.saldo / l_peso_item
         LET l_qtd      = l_qtd_item USING '&&&&&&&&&&&.&&&&&&&'
            
         LET l_inteiro = l_qtd[1,11]
         LET l_decimal = l_qtd[13,19]
          
         IF l_decimal > 0 THEN
            LET l_qtd_item = l_inteiro + 1
         ELSE
            LET l_qtd_item = l_inteiro + 0
         END IF
            
         LET lr_relat.chapas      = l_qtd_item USING '&&&&&&&&&'
         LET lr_relat.prz_entrega = mr_tela.prz_entrega
         
         OUTPUT TO REPORT pol0330_relat(lr_relat.*)
      
         INITIALIZE lr_relat.* TO NULL 
         LET p_count = p_count + 1
      
      END FOREACH
   END IF

END FUNCTION      

#-----------------------------#
 REPORT pol0330_relat(lr_relat)
#-----------------------------#
    DEFINE lr_relat          RECORD   
       cod_item                 CHAR(15),
       den_item                 CHAR(76),
       prz_entrega              DATE,
       cod_unid_med             CHAR(3),
       saldo                    DECIMAL(18,7),
       chapas                   DECIMAL(9,0),
       pct_refugo               DECIMAL(5,2),    
       tip_item                 CHAR(1)    
                             END RECORD

   DEFINE l_saldo            DECIMAL(12,3),
          l_chapas           DECIMAL(12,3)  

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3 
 
   ORDER EXTERNAL BY lr_relat.cod_item,
                     lr_relat.prz_entrega

   FORMAT
      PAGE HEADER
         LET l_saldo  = 0 
         LET l_chapas = 0 
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 066, "RELATORIO DE ENVIO DE PROGRAMACAO",
               COLUMN 132, "PAG.: ", PAGENO USING "####"
         PRINT COLUMN 001, "POL0330",
               COLUMN 050, "PERIODO : ", mr_tela.dat_inicio,
                           " ATE ",mr_tela.dat_final,
               COLUMN 128, "DATA: ", TODAY USING "DD/MM/YY"
         PRINT COLUMN 001, "--------------------------------------------",
                           "--------------------------------------------",
                           "-----------------------------------------------------"
         PRINT COLUMN 001, "ITEM",              
               COLUMN 017, "DESCRICAO",
               COLUMN 095, "DATA ENTR.",
               COLUMN 106, "UNI",
               COLUMN 111, "QTDADE",
               COLUMN 121, "CHAPAS",
               COLUMN 131, "REFUGO",
               COLUMN 138, "TIPO" 
         PRINT COLUMN 001, "--------------- -------------------------------",
                           "---------------------------------------------- ",
                           "---------- ---  --------- --------- ------ ----"
      ON EVERY ROW
         PRINT COLUMN 001, lr_relat.cod_item,
               COLUMN 017, lr_relat.den_item,
               COLUMN 095, lr_relat.prz_entrega,
               COLUMN 106, lr_relat.cod_unid_med,
               COLUMN 111, lr_relat.saldo USING '<<<<<<<<<',
               COLUMN 121, lr_relat.chapas USING '<<<<<<<<<',
               COLUMN 131, lr_relat.pct_refugo USING '##&.&&',
               COLUMN 138, lr_relat.tip_item         
         
         LET l_saldo  = l_saldo + lr_relat.saldo USING '<<<<<<<<&'
         LET l_chapas = l_chapas + lr_relat.chapas USING '<<<<<<<<&'
         SKIP 1 LINE

      AFTER GROUP OF lr_relat.cod_item
         SKIP 1 LINE
         PRINT COLUMN 001, 'TOTAL DO ITEM ',
               COLUMN 016, '..............................................',
               COLUMN 057, '..............................................',
               COLUMN 111, l_saldo USING '<<<<<<<<<',
               COLUMN 121, l_chapas USING '<<<<<<<<<'
         LET l_saldo = 0 
         SKIP 2 LINES
         PRINT COLUMN 001, "--------------------------------------------",
                           "--------------------------------------------",
                           "-----------------------------------------------------"
      
      ON LAST ROW
         PRINT COLUMN 001, p_descomprime

END REPORT

#------------------------------#
 FUNCTION pol0330_gera_arquivo()
#------------------------------#
   DEFINE l_num_cnpj            CHAR(19),
          l_cnpj_ethos          CHAR(19),
          l_dat_hora            CHAR(19)

   MESSAGE " Processando a Extração do Arquivo..." ATTRIBUTE(REVERSE)
     
   SELECT num_cgc_cpf
     INTO l_num_cnpj
     FROM clientes
    WHERE cod_cliente = ma_tela[1].cod_cliente

   IF sqlca.sqlcode <> 0 THEN
      LET l_num_cnpj = ' '
   END IF

   SELECT num_cgc
     INTO l_cnpj_ethos
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
 
   IF sqlca.sqlcode <> 0 THEN
      LET l_cnpj_ethos = ' '
   END IF

   LET l_cnpj_ethos = l_cnpj_ethos[2,3],
                      l_cnpj_ethos[5,7],
                      l_cnpj_ethos[9,11],
                      l_cnpj_ethos[13,16],
                      l_cnpj_ethos[18,19]
   LET l_num_cnpj   = l_num_cnpj[2,3],
                      l_num_cnpj[5,7],
                      l_num_cnpj[9,11],
                      l_num_cnpj[13,16],
                      l_num_cnpj[18,19]  

   LET l_dat_hora = CURRENT YEAR TO SECOND 

   LET l_dat_hora = l_dat_hora[1,4],
                    l_dat_hora[6,7],
                    l_dat_hora[9,10],
                    l_dat_hora[12,13],
                    l_dat_hora[15,16],
                    l_dat_hora[18,19]
  
   CALL log150_procura_caminho ('LST') RETURNING p_nom_arquivo
   LET p_nom_arquivo = p_nom_arquivo CLIPPED,l_num_cnpj CLIPPED,'_RND00107_',
                       l_cnpj_ethos CLIPPED,'_',l_dat_hora CLIPPED,'.txt'
     
   START REPORT pol0330_relat_arq  TO p_nom_arquivo

   CALL pol0330_emite_arquivo_edi()

   IF m_count = 0 THEN
      MESSAGE "Não Existem Dados para gerar arquivo." ATTRIBUTE(REVERSE)
      RETURN
   ELSE
      ERROR "Arquivo Processado com Sucesso."
   END IF

   FINISH REPORT pol0330_relat_arq     
      
   MESSAGE "Gravado em ",p_nom_arquivo
       ATTRIBUTE(REVERSE)

END FUNCTION

#-----------------------------------#
 FUNCTION pol0330_emite_arquivo_edi()
#-----------------------------------#
   DEFINE lr_arq_edi       RECORD
      ident_itp                CHAR(3), # 1-3     Ident. tipo registro - ITP
      ident_proc               CHAR(3), # 4-6     Ident. do processo
      num_ver_transac          CHAR(2), # 7-8     Numero da Versao Transacao 
      num_ctr_transm           CHAR(5), # 9-13    Numero controle transmissao
      ident_ger_mov            CHAR(12),# 14-25   Ident. Geracao do movimento
      ident_tms_comun          CHAR(14),# 26-39   Ident. Transmissor na Comun.
      ident_rcp_comun          CHAR(14),# 40-53   Ident. Receptor na Comun. 
      cod_int_tms              CHAR(8), # 54-61   Código Interno do Transmissor
      cod_int_rcp              CHAR(8), # 62-69   Código Interno do Receptor 
      nom_tms                  CHAR(25),# 70-94   Nome do Transmissor 
      nom_rcp                  CHAR(25),# 95-119  Nome do Receptor 
      espaco_itp               CHAR(9), # 120-128 Espaço  
      ident_pe1                CHAR(3), # 1-3     Ident. Tipo Registro - PE1
      cod_fab_dest             CHAR(3), # 4-6     Código da Fábrica destino
      ident_prog_atual         CHAR(9), # 7-15    Ident. Programa atual
      dat_prog_atual           CHAR(6), # 16-21   Data do Programa atual
      ident_prog_ant           CHAR(9), # 22-30   Ident. Programa anterior
      dat_prog_ant             CHAR(6), # 31-36   Data do Programa anterior
      cod_item_cli             CHAR(30),# 37-66   Código do item do cliente 
      cod_item_forn            CHAR(30),# 67-96   Código do item do Fornecedor
      num_ped_comp             CHAR(12),# 97-108  Número do pedido de compra
      cod_loc_dest             CHAR(5), # 109-113 Código do local de destino
      ident_para_cont          CHAR(11),# 114-124 Ident. para contato
      cod_unid_med             CHAR(2), # 125-126 Código Unidade Medida
      qtd_casas_dec            CHAR(1), # 127-127 Qtde Casas decimais
      cod_tip_fornto           CHAR(1), # 128-128 Código Tipo de Fornecimento 
      ident_pe3                CHAR(3), # 1-3     Ident. Tipo Registro - PE3   
      dat_ent_item             CHAR(6), # 4-9     Data de Entrega do item
      hor_ent_item             CHAR(2), # 10-11   Hora para entrega do item
      qtd_ent_item             CHAR(9), # 12-20   Qtde entrega do item
      dat_ent_item_2           CHAR(6), # 21-26   Data de Entrega do item
      hor_ent_item_2           CHAR(2), # 27-28   Hora para entrega do item
      qtd_ent_item_2           CHAR(9), # 29-37   Qtde entrega do item
      dat_ent_item_3           CHAR(6), # 38-43   Data de Entrega do item
      hor_ent_item_3           CHAR(2), # 44-45   Hora para entrega do item
      qtd_ent_item_3           CHAR(9), # 46-54   Qtde entrega do item
      dat_ent_item_4           CHAR(6), # 55-60   Data de Entrega do item
      hor_ent_item_4           CHAR(2), # 61-62   Hora para entrega do item
      qtd_ent_item_4           CHAR(9), # 63-71   Qtde entrega do item
      dat_ent_item_5           CHAR(6), # 72-77   Data de Entrega do item
      hor_ent_item_5           CHAR(2), # 78-79   Hora para entrega do item
      qtd_ent_item_5           CHAR(9), # 80-88   Qtde entrega do item
      dat_ent_item_6           CHAR(6), # 89-94   Data de Entrega do item
      hor_ent_item_6           CHAR(2), # 95-96   Hora para entrega do item
      qtd_ent_item_6           CHAR(9), # 97-105  Qtde entrega do item
      dat_ent_item_7           CHAR(6), # 106-111 Data de Entrega do item
      hor_ent_item_7           CHAR(2), # 112-113 Hora para entrega do item
      qtd_ent_item_7           CHAR(9), # 114-122 Qtde entrega do item
      espaco_pe3               CHAR(6), # 123-128 Espaço
      ident_ftp                CHAR(3), # 1-3     Ident. Tipo Registro - FTP
      num_ctr_tms_ftp          CHAR(5), # 4-8     Numero Contr. Transmissao
      qtd_reg_transac          CHAR(9), # 9-17    Quantidade Registro Transacao
      num_tot_val              CHAR(17),# 18-34   Numero total de valores
      categ_operac             CHAR(1), # 35-35   Categoria da Operacao
      espaco_ftp               CHAR(93) # 36-128  Espaço       
                           END RECORD
   
   DEFINE l_num_reg            INTEGER,
          l_num_cnpj           CHAR(19),
          l_cnpj_ethos         CHAR(19),
          l_cod_item           LIKE item.cod_item, 
          l_cod_cliente        LIKE clientes.cod_cliente, 
          l_cod_item_cat       LIKE item_prog_ethos.cod_item_cat, 
          l_num_ped_cater      LIKE item_prog_ethos.num_ped_cater,
          l_contato            LIKE item_prog_ethos.contato,
          l_dat_atual          CHAR(6),
          l_hor_atual          CHAR(8),
          l_capa               SMALLINT,  
          l_qtd_item           DECIMAL(18,7), 
          l_qtd_1              CHAR(19), 
          l_qtd_item_2         DECIMAL(18,7), 
          l_qtd_2              CHAR(19), 
          l_qtd_item_3         DECIMAL(18,7), 
          l_qtd_3              CHAR(19), 
          l_qtd_item_4         DECIMAL(18,7), 
          l_qtd_4              CHAR(19), 
          l_qtd_item_5         DECIMAL(18,7), 
          l_qtd_5              CHAR(19), 
          l_qtd_item_6         DECIMAL(18,7), 
          l_qtd_6              CHAR(19), 
          l_qtd_item_7         DECIMAL(18,7), 
          l_qtd_7              CHAR(19),
          l_inteiro            INTEGER, 
          l_decimal            INTEGER,
          l_inteiro_2          INTEGER, 
          l_decimal_2          INTEGER,
          l_inteiro_3          INTEGER, 
          l_decimal_3          INTEGER,
          l_inteiro_4          INTEGER, 
          l_decimal_4          INTEGER,
          l_inteiro_5          INTEGER, 
          l_decimal_5          INTEGER,
          l_inteiro_6          INTEGER, 
          l_decimal_6          INTEGER,
          l_inteiro_7          INTEGER, 
          l_decimal_7          INTEGER,
          l_peso_item          LIKE item_prog_ethos.peso_item,
          sql_stmt_2           CHAR(300)
 
   LET l_capa  = TRUE
   LET m_count = 0
   LET l_num_reg = 0
    
   IF m_houve_alter THEN
      LET sql_stmt_2 = " SELECT UNIQUE cod_item ",
                       "   FROM t_edi_caterpillar "
   ELSE                      
      LET sql_stmt_2 = " SELECT UNIQUE cod_item ",
                       "   FROM w_edi_caterpillar ",
                       "  WHERE envia_arquivo = 'S' "
   END IF 

   PREPARE var_query_2 FROM sql_stmt_2
   DECLARE cq_edi SCROLL CURSOR WITH HOLD FOR var_query_2   
   FOREACH cq_edi INTO l_cod_item

      SELECT cod_item_cat, 
             num_ped_cater,
             contato,
             peso_item
        INTO l_cod_item_cat, 
             l_num_ped_cater,
             l_contato,
             l_peso_item 
        FROM item_prog_ethos
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = l_cod_item

      CALL pol0330_busca_prz_entrega(l_cod_item)
      
      LET l_cod_cliente = ma_tela[1].cod_cliente
 
      SELECT nom_cliente, num_cgc_cpf
        INTO lr_arq_edi.nom_rcp, l_num_cnpj
        FROM clientes
       WHERE cod_cliente = l_cod_cliente
 
      IF sqlca.sqlcode <> 0 THEN
         LET l_num_cnpj = ' '
         LET lr_arq_edi.nom_rcp = ' '       
      END IF
 
      SELECT den_empresa, num_cgc
        INTO lr_arq_edi.nom_tms, l_cnpj_ethos
        FROM empresa
       WHERE cod_empresa = p_cod_empresa
      
      IF sqlca.sqlcode <> 0 THEN
         LET l_cnpj_ethos = ' '
         LET lr_arq_edi.nom_tms = ' '       
      END IF

      LET lr_arq_edi.ident_itp        = 'ITP'
      LET lr_arq_edi.ident_proc       = '001'
      LET lr_arq_edi.num_ver_transac  = '07'
      LET lr_arq_edi.num_ctr_transm   = '00000'
      LET l_dat_atual = TODAY USING 'yymmdd' 
      LET l_hor_atual = CURRENT HOUR TO SECOND  
      LET lr_arq_edi.ident_ger_mov    = l_dat_atual, 
                                        l_hor_atual[1,2],
                                        l_hor_atual[4,5],
                                        l_hor_atual[7,8]              
      LET lr_arq_edi.ident_tms_comun  = l_cnpj_ethos[2,3], 
                                        l_cnpj_ethos[5,7],
                                        l_cnpj_ethos[9,11],
                                        l_cnpj_ethos[13,16],
                                        l_cnpj_ethos[18,19]
      LET lr_arq_edi.ident_rcp_comun  = l_num_cnpj[2,3],
                                        l_num_cnpj[5,7],
                                        l_num_cnpj[9,11],
                                        l_num_cnpj[13,16],
                                        l_num_cnpj[18,19]
      LET lr_arq_edi.cod_int_tms      = 'Q7586S0 '
      LET lr_arq_edi.cod_int_rcp      = '        '
      LET lr_arq_edi.espaco_itp       = ' ' 

      IF l_capa THEN 
         LET l_num_reg = l_num_reg + 1
         OUTPUT TO REPORT pol0330_relat_arq(1,lr_arq_edi.*)
         LET l_capa = FALSE
      END IF
   
      LET lr_arq_edi.ident_pe1        = 'PE1' 
      LET lr_arq_edi.cod_fab_dest     = '028'
      LET lr_arq_edi.ident_prog_atual = ' '
      LET lr_arq_edi.dat_prog_atual   = TODAY USING 'yymmdd'
      LET lr_arq_edi.ident_prog_ant   = ' '
      LET lr_arq_edi.dat_prog_ant     = '000000'
      LET lr_arq_edi.cod_item_cli     = l_cod_item_cat
      LET lr_arq_edi.cod_item_forn    = l_cod_item 
      LET lr_arq_edi.num_ped_comp     = l_num_ped_cater 
      LET lr_arq_edi.cod_loc_dest     = 'CAT00'  
      LET lr_arq_edi.ident_para_cont  = l_contato 
      LET lr_arq_edi.cod_unid_med     = 'EA'
      LET lr_arq_edi.qtd_casas_dec    = '0' 
      LET lr_arq_edi.cod_tip_fornto   = 'C' 
      LET lr_arq_edi.ident_pe3        = 'PE3'
      LET lr_arq_edi.dat_ent_item     = ma_edi[1].prz_entrega USING 'yymmdd'   
      LET lr_arq_edi.hor_ent_item     = '00'    
 
      IF m_houve_alter THEN
         LET lr_arq_edi.qtd_ent_item     = ma_edi[1].saldo
      ELSE
         LET l_qtd_item = ma_edi[1].saldo / l_peso_item    
         LET l_qtd_1 = l_qtd_item USING '&&&&&&&&&&&.&&&&&&&' 
         
         LET l_inteiro = l_qtd_1[1,11]
         LET l_decimal = l_qtd_1[13,19]
         
         IF l_decimal > 0 THEN
            LET l_qtd_item = l_inteiro + 1
         ELSE
            LET l_qtd_item = l_inteiro + 0 
         END IF       
         
         LET lr_arq_edi.qtd_ent_item     =  l_qtd_item   USING '&&&&&&&&&'
      END IF    

      IF lr_arq_edi.qtd_ent_item IS NULL THEN
         LET lr_arq_edi.qtd_ent_item  = 0
      END IF

      IF ma_edi[2].prz_entrega = '31/12/1899' THEN
         LET lr_arq_edi.dat_ent_item_2 = '000000'
      ELSE 
         LET lr_arq_edi.dat_ent_item_2 = ma_edi[2].prz_entrega USING 'yymmdd' 
      END IF
 
      LET lr_arq_edi.hor_ent_item_2    = '00'

      IF m_houve_alter THEN
         LET lr_arq_edi.qtd_ent_item_2     = ma_edi[2].saldo
      ELSE
         LET l_qtd_item_2 = ma_edi[2].saldo / l_peso_item
         LET l_qtd_2 = l_qtd_item_2 USING '&&&&&&&&&&&.&&&&&&&'
   
         LET l_inteiro_2 = l_qtd_2[1,11]
         LET l_decimal_2 = l_qtd_2[13,19]
   
         IF l_decimal_2 > 0 THEN
            LET l_qtd_item_2 = l_inteiro_2 + 1
         ELSE
            LET l_qtd_item_2 = l_inteiro_2 + 0
         END IF
         
         LET lr_arq_edi.qtd_ent_item_2    = l_qtd_item_2 USING '&&&&&&&&&'
      END IF    
      
      IF lr_arq_edi.qtd_ent_item_2 IS NULL THEN
         LET lr_arq_edi.qtd_ent_item_2 = 0
      END IF
 
      IF ma_edi[3].prz_entrega = '31/12/1899' THEN
         LET lr_arq_edi.dat_ent_item_3 = '000000'
      ELSE 
         LET lr_arq_edi.dat_ent_item_3 = ma_edi[3].prz_entrega USING 'yymmdd' 
      END IF
 
      LET lr_arq_edi.hor_ent_item_3    = '00'

      IF m_houve_alter THEN
         LET lr_arq_edi.qtd_ent_item_3     = ma_edi[3].saldo
      ELSE
         LET l_qtd_item_3 = ma_edi[3].saldo / l_peso_item
         LET l_qtd_3 = l_qtd_item_3 USING '&&&&&&&&&&&.&&&&&&&'
   
         LET l_inteiro_3 = l_qtd_3[1,11]
         LET l_decimal_3 = l_qtd_3[13,19]
   
         IF l_decimal_3 > 0 THEN
            LET l_qtd_item_3 = l_inteiro_3 + 1
         ELSE
            LET l_qtd_item_3 = l_inteiro_3 + 0
         END IF
   
         LET lr_arq_edi.qtd_ent_item_3    = l_qtd_item_3 USING '&&&&&&&&&'
      END IF   
      
      IF lr_arq_edi.qtd_ent_item_3 IS NULL THEN
         LET lr_arq_edi.qtd_ent_item_3 = 0
      END IF

      IF ma_edi[4].prz_entrega = '31/12/1899' THEN
         LET lr_arq_edi.dat_ent_item_4 = '000000'
      ELSE 
         LET lr_arq_edi.dat_ent_item_4 = ma_edi[4].prz_entrega USING 'yymmdd' 
      END IF
  
      LET lr_arq_edi.hor_ent_item_4   = '00'

      IF m_houve_alter THEN
         LET lr_arq_edi.qtd_ent_item_4     = ma_edi[4].saldo
      ELSE
         LET l_qtd_item_4 = ma_edi[4].saldo / l_peso_item
         LET l_qtd_4 = l_qtd_item_4 USING '&&&&&&&&&&&.&&&&&&&'
   
         LET l_inteiro_4 = l_qtd_4[1,11]
         LET l_decimal_4 = l_qtd_4[13,19]
   
         IF l_decimal_4 > 0 THEN
            LET l_qtd_item_4 = l_inteiro_4 + 1
         ELSE
            LET l_qtd_item_4 = l_inteiro_4 + 0
         END IF
   
         LET lr_arq_edi.qtd_ent_item_4    = l_qtd_item_4 USING '&&&&&&&&&'
      END IF
   
      IF lr_arq_edi.qtd_ent_item_4 IS NULL THEN
         LET lr_arq_edi.qtd_ent_item_4 = 0
      END IF

      IF ma_edi[5].prz_entrega = '31/12/1899' THEN
         LET lr_arq_edi.dat_ent_item_5 = '000000'
      ELSE 
         LET lr_arq_edi.dat_ent_item_5 = ma_edi[5].prz_entrega USING 'yymmdd' 
      END IF
  
      LET lr_arq_edi.hor_ent_item_5   = '00'
 
      IF m_houve_alter THEN
         LET lr_arq_edi.qtd_ent_item_5     = ma_edi[5].saldo
      ELSE
         LET l_qtd_item_5 = ma_edi[5].saldo / l_peso_item
         LET l_qtd_5 = l_qtd_item_5 USING '&&&&&&&&&&&.&&&&&&&'
   
         LET l_inteiro_5 = l_qtd_5[1,11]
         LET l_decimal_5 = l_qtd_5[13,19]
   
         IF l_decimal_5 > 0 THEN
            LET l_qtd_item_5 = l_inteiro_5 + 1
         ELSE
            LET l_qtd_item_5 = l_inteiro_5 + 0
         END IF
   
         LET lr_arq_edi.qtd_ent_item_5    = l_qtd_item_5 USING '&&&&&&&&&'
      END IF 
    
      IF lr_arq_edi.qtd_ent_item_5 IS NULL THEN
         LET lr_arq_edi.qtd_ent_item_5 = 0
      END IF

      IF ma_edi[6].prz_entrega = '31/12/1899' THEN
         LET lr_arq_edi.dat_ent_item_6 = '000000'
      ELSE 
         LET lr_arq_edi.dat_ent_item_6 = ma_edi[6].prz_entrega USING 'yymmdd' 
      END IF
  
      LET lr_arq_edi.hor_ent_item_6   = '00'
 
      IF m_houve_alter THEN
         LET lr_arq_edi.qtd_ent_item_6     = ma_edi[6].saldo
      ELSE
         LET l_qtd_item_6 = ma_edi[6].saldo / l_peso_item
         LET l_qtd_6 = l_qtd_item_6 USING '&&&&&&&&&&&.&&&&&&&'
   
         LET l_inteiro_6 = l_qtd_6[1,11]
         LET l_decimal_6 = l_qtd_6[13,19]
   
         IF l_decimal_6 > 0 THEN
            LET l_qtd_item_6 = l_inteiro_6 + 1
         ELSE
            LET l_qtd_item_6 = l_inteiro_6 + 0
         END IF
   
         LET lr_arq_edi.qtd_ent_item_6    = l_qtd_item_6 USING '&&&&&&&&&'
      END IF 
         
      IF lr_arq_edi.qtd_ent_item_6 IS NULL THEN
         LET lr_arq_edi.qtd_ent_item_6 = 0
      END IF

      IF ma_edi[7].prz_entrega = '31/12/1899' THEN
         LET lr_arq_edi.dat_ent_item_7 = '000000'
      ELSE 
         LET lr_arq_edi.dat_ent_item_7 = ma_edi[7].prz_entrega USING 'yymmdd' 
      END IF
  
      LET lr_arq_edi.hor_ent_item_7   = '00'
     
      IF m_houve_alter THEN
         LET lr_arq_edi.qtd_ent_item_7     = ma_edi[7].saldo
      ELSE
         LET l_qtd_item_7 = ma_edi[7].saldo / l_peso_item
         LET l_qtd_7 = l_qtd_item_7 USING '&&&&&&&&&&&.&&&&&&&'
   
         LET l_inteiro_7 = l_qtd_7[1,11]
         LET l_decimal_7 = l_qtd_7[13,19]
   
         IF l_decimal_7 > 0 THEN
            LET l_qtd_item_7 = l_inteiro_7 + 1
         ELSE
            LET l_qtd_item_7 = l_inteiro_7 + 0
         END IF
   
         LET lr_arq_edi.qtd_ent_item_7    = l_qtd_item_7 USING '&&&&&&&&&'
      END IF
      
      IF lr_arq_edi.qtd_ent_item_7 IS NULL THEN
         LET lr_arq_edi.qtd_ent_item_7 = 0
      END IF

      LET lr_arq_edi.espaco_pe3       = ' '    
     
      LET l_num_reg = l_num_reg + 2 

      OUTPUT TO REPORT pol0330_relat_arq(2,lr_arq_edi.*)
      
      INITIALIZE lr_arq_edi.* TO NULL
      LET m_count = m_count + 1

   END FOREACH

   LET lr_arq_edi.ident_ftp        = 'FTP'  
   LET lr_arq_edi.num_ctr_tms_ftp  = '00000'  
   LET lr_arq_edi.qtd_reg_transac  = l_num_reg + 1 USING '&&&&&&&&&'
   LET lr_arq_edi.num_tot_val      = '00000000000000000'  
   LET lr_arq_edi.categ_operac     = ' '  
   LET lr_arq_edi.espaco_ftp       = ' '  
     
   OUTPUT TO REPORT pol0330_relat_arq(3,lr_arq_edi.*)

END FUNCTION

#---------------------------------------------# 
 FUNCTION pol0330_busca_prz_entrega(l_cod_item)
#---------------------------------------------# 
   DEFINE l_ind                    SMALLINT,
          l_cod_item               LIKE item.cod_item,
          sql_stmt_3               CHAR(300)

   LET l_ind = 1 

   IF m_houve_alter THEN
      LET sql_stmt_3 = " SELECT SUM(saldo), prz_entrega ",
                       "   FROM t_edi_caterpillar ",
                       "  WHERE cod_item      = '",l_cod_item,"'",
                       "  GROUP BY prz_entrega ",
                       "  ORDER BY prz_entrega "
      
      PREPARE var_query_3 FROM sql_stmt_3
      DECLARE cq_prz_entrega SCROLL CURSOR WITH HOLD FOR var_query_3
      
      FOREACH cq_prz_entrega INTO ma_edi[l_ind].saldo,
                                  ma_edi[l_ind].prz_entrega
         
         LET l_ind = l_ind + 1
         
      END FOREACH
   ELSE
      SELECT SUM(saldo)
        INTO ma_edi[l_ind].saldo
        FROM w_edi_caterpillar
       WHERE cod_item      = l_cod_item
         AND envia_arquivo = 'S'
                     
      LET ma_edi[l_ind].prz_entrega = mr_tela.prz_entrega
   END IF                    
      
END FUNCTION
      
#-------------------------------------------#
 REPORT pol0330_relat_arq(l_tipo, lr_arq_edi)
#-------------------------------------------#
   DEFINE lr_arq_edi        RECORD
      ident_itp                CHAR(3), # 1-3     Ident. tipo registro - ITP
      ident_proc               CHAR(3), # 4-6     Ident. do processo
      num_ver_transac          CHAR(2), # 7-8     Numero da Versao Transacao
      num_ctr_transm           CHAR(5), # 9-13    Numero controle transmissao
      ident_ger_mov            CHAR(12),# 14-25   Ident. Geracao do movimento
      ident_tms_comun          CHAR(14),# 26-39   Ident. Transmissor na Comun.
      ident_rcp_comun          CHAR(14),# 40-53   Ident. Receptor na Comun.
      cod_int_tms              CHAR(8), # 54-61   Código Interno do Transmissor
      cod_int_rcp              CHAR(8), # 62-69   Código Interno do Receptor
      nom_tms                  CHAR(25),# 70-94   Nome do Transmissor
      nom_rcp                  CHAR(25),# 95-119  Nome do Receptor
      espaco_itp               CHAR(9), # 120-128 Espaço
      ident_pe1                CHAR(3), # 1-3     Ident. Tipo Registro - PE1
      cod_fab_dest             CHAR(3), # 4-6     Código da Fábrica destino
      ident_prog_atual         CHAR(9), # 7-15    Ident. Programa atual
      dat_prog_atual           CHAR(6), # 16-21   Data do Programa atual
      ident_prog_ant           CHAR(9), # 22-30   Ident. Programa anterior
      dat_prog_ant             CHAR(6), # 31-36   Data do Programa anterior
      cod_item_cli             CHAR(30),# 37-66   Código do item do cliente
      cod_item_forn            CHAR(30),# 67-96   Código do item do Fornecedor
      num_ped_comp             CHAR(12),# 97-108  Número do pedido de compra
      cod_loc_dest             CHAR(5), # 109-113 Código do local de destino  
      ident_para_cont          CHAR(11),# 114-124 Ident. para contato
      cod_unid_med             CHAR(2), # 125-126 Código Unidade Medida
      qtd_casas_dec            CHAR(1), # 127-127 Qtde Casas decimais
      cod_tip_fornto           CHAR(1), # 128-128 Código Tipo de Fornecimento
      ident_pe3                CHAR(3), # 1-3     Ident. Tipo Registro - PE3
      dat_ent_item             CHAR(6), # 4-9     Data de Entrega do item
      hor_ent_item             CHAR(2), # 10-11   Hora para entrega do item
      qtd_ent_item             CHAR(9), # 12-20   Qtde entrega do item
      dat_ent_item_2           CHAR(6), # 21-26   Data de Entrega do item
      hor_ent_item_2           CHAR(2), # 27-28   Hora para entrega do item
      qtd_ent_item_2           CHAR(9), # 29-37   Qtde entrega do item
      dat_ent_item_3           CHAR(6), # 38-43   Data de Entrega do item
      hor_ent_item_3           CHAR(2), # 44-45   Hora para entrega do item
      qtd_ent_item_3           CHAR(9), # 46-54   Qtde entrega do item
      dat_ent_item_4           CHAR(6), # 55-60   Data de Entrega do item
      hor_ent_item_4           CHAR(2), # 61-62   Hora para entrega do item
      qtd_ent_item_4           CHAR(9), # 63-71   Qtde entrega do item
      dat_ent_item_5           CHAR(6), # 72-77   Data de Entrega do item
      hor_ent_item_5           CHAR(2), # 78-79   Hora para entrega do item
      qtd_ent_item_5           CHAR(9), # 80-88   Qtde entrega do item
      dat_ent_item_6           CHAR(6), # 89-94   Data de Entrega do item
      hor_ent_item_6           CHAR(2), # 95-96   Hora para entrega do item
      qtd_ent_item_6           CHAR(9), # 97-105  Qtde entrega do item
      dat_ent_item_7           CHAR(6), # 106-111 Data de Entrega do item
      hor_ent_item_7           CHAR(2), # 112-113 Hora para entrega do item
      qtd_ent_item_7           CHAR(9), # 114-122 Qtde entrega do item
      espaco_pe3               CHAR(6), # 123-128 Espaço
      ident_ftp                CHAR(3), # 1-3     Ident. Tipo Registro - FTP
      num_ctr_tms_ftp          CHAR(5), # 4-8     Numero Contr. Transmissao
      qtd_reg_transac          CHAR(9), # 9-17    Quantidade Registro Transacao
      num_tot_val              CHAR(17),# 18-34   Numero total de valores
      categ_operac             CHAR(1), # 35-35   Categoria da Operacao
      espaco_ftp               CHAR(93) # 36-128  Espaço
                            END RECORD         

   DEFINE l_tipo               SMALLINT
 
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1

   FORMAT
     
      ON EVERY ROW 
         CASE
            WHEN l_tipo = 1
               PRINT COLUMN 001, lr_arq_edi.ident_itp;
               PRINT COLUMN 004, lr_arq_edi.ident_proc;
               PRINT COLUMN 007, lr_arq_edi.num_ver_transac;
               PRINT COLUMN 009, lr_arq_edi.num_ctr_transm;
               PRINT COLUMN 014, lr_arq_edi.ident_ger_mov;
               PRINT COLUMN 026, lr_arq_edi.ident_tms_comun;
               PRINT COLUMN 040, lr_arq_edi.ident_rcp_comun;
               PRINT COLUMN 054, lr_arq_edi.cod_int_tms;
               PRINT COLUMN 062, lr_arq_edi.cod_int_rcp;
               PRINT COLUMN 070, lr_arq_edi.nom_tms;    
               PRINT COLUMN 095, lr_arq_edi.nom_rcp;    
               PRINT COLUMN 120, lr_arq_edi.espaco_itp 
         
            WHEN l_tipo = 2
               PRINT COLUMN 001, lr_arq_edi.ident_pe1;  
               PRINT COLUMN 004, lr_arq_edi.cod_fab_dest;
               PRINT COLUMN 007, lr_arq_edi.ident_prog_atual;
               PRINT COLUMN 016, lr_arq_edi.dat_prog_atual;  
               PRINT COLUMN 022, lr_arq_edi.ident_prog_ant;  
               PRINT COLUMN 031, lr_arq_edi.dat_prog_ant;    
               PRINT COLUMN 037, lr_arq_edi.cod_item_cli;    
               PRINT COLUMN 067, lr_arq_edi.cod_item_forn;   
               PRINT COLUMN 097, lr_arq_edi.num_ped_comp;    
               PRINT COLUMN 109, lr_arq_edi.cod_loc_dest;    
               PRINT COLUMN 114, lr_arq_edi.ident_para_cont; 
               PRINT COLUMN 125, lr_arq_edi.cod_unid_med;    
               PRINT COLUMN 127, lr_arq_edi.qtd_casas_dec;   
               PRINT COLUMN 128, lr_arq_edi.cod_tip_fornto  
               PRINT COLUMN 001, lr_arq_edi.ident_pe3;       
               PRINT COLUMN 004, lr_arq_edi.dat_ent_item;    
               PRINT COLUMN 010, lr_arq_edi.hor_ent_item;    
               PRINT COLUMN 012, lr_arq_edi.qtd_ent_item USING '&&&&&&&&&';    
               PRINT COLUMN 021, lr_arq_edi.dat_ent_item_2;    
               PRINT COLUMN 027, lr_arq_edi.hor_ent_item_2;    
               PRINT COLUMN 029, lr_arq_edi.qtd_ent_item_2 USING '&&&&&&&&&'; 
               PRINT COLUMN 038, lr_arq_edi.dat_ent_item_3;    
               PRINT COLUMN 044, lr_arq_edi.hor_ent_item_3;    
               PRINT COLUMN 046, lr_arq_edi.qtd_ent_item_3 USING '&&&&&&&&&'; 
               PRINT COLUMN 055, lr_arq_edi.dat_ent_item_4;    
               PRINT COLUMN 061, lr_arq_edi.hor_ent_item_4;    
               PRINT COLUMN 063, lr_arq_edi.qtd_ent_item_4 USING '&&&&&&&&&';  
               PRINT COLUMN 072, lr_arq_edi.dat_ent_item_5;    
               PRINT COLUMN 078, lr_arq_edi.hor_ent_item_5;    
               PRINT COLUMN 080, lr_arq_edi.qtd_ent_item_5 USING '&&&&&&&&&';  
               PRINT COLUMN 089, lr_arq_edi.dat_ent_item_6;    
               PRINT COLUMN 095, lr_arq_edi.hor_ent_item_6;    
               PRINT COLUMN 097, lr_arq_edi.qtd_ent_item_6 USING '&&&&&&&&&';  
               PRINT COLUMN 106, lr_arq_edi.dat_ent_item_7;    
               PRINT COLUMN 112, lr_arq_edi.hor_ent_item_7;    
               PRINT COLUMN 114, lr_arq_edi.qtd_ent_item_7 USING '&&&&&&&&&';   
               PRINT COLUMN 123, lr_arq_edi.espaco_pe3      
           
            WHEN l_tipo = 3  
               PRINT COLUMN 001, lr_arq_edi.ident_ftp;           
               PRINT COLUMN 004, lr_arq_edi.num_ctr_tms_ftp;     
               PRINT COLUMN 009, lr_arq_edi.qtd_reg_transac;     
               PRINT COLUMN 018, lr_arq_edi.num_tot_val;         
               PRINT COLUMN 035, lr_arq_edi.categ_operac;        
               PRINT COLUMN 036, lr_arq_edi.espaco_ftp;
        END CASE

END REPORT                                         
                                                                                
#----------------------------------#
 FUNCTION pol0330_modifica_arquivo()
#----------------------------------#
   DEFINE l_ind                    SMALLINT,
          l_cod_item               LIKE item.cod_item,
          l_peso_item              LIKE item_prog_ethos.peso_item,
          l_saldo                  DECIMAL(18,7),
          l_qtd_item               DECIMAL(18,7), 
          l_qtd_1                  CHAR(19), 
          l_inteiro                INTEGER, 
          l_decimal                INTEGER

   LET l_ind = 1 

   IF m_houve_alter THEN
      DECLARE cq_modifica1 CURSOR FOR
       SELECT cod_item, prz_entrega, SUM(saldo)
         FROM t_edi_caterpillar
        GROUP BY 1,2
        ORDER BY 1,2
      
      FOREACH cq_modifica1 INTO ma_tela3[l_ind].cod_item,
                                ma_tela3[l_ind].prz_entrega,
                                ma_tela3[l_ind].saldo
      
         SELECT den_item_reduz
           INTO ma_tela3[l_ind].den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = ma_tela3[l_ind].cod_item
            
         WHENEVER ERROR CONTINUE
           INSERT INTO t_edi_caterpillar VALUES (ma_tela3[l_ind].cod_item,
                                                 ma_tela3[l_ind].prz_entrega,
                                                 ma_tela3[l_ind].saldo)                             
         WHENEVER ERROR STOP                                                  
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("INCLUSAO","EDI_CATERPILLAR")
            RETURN FALSE
         END IF 
         
         LET l_ind = l_ind + 1
      END FOREACH
   ELSE
      WHENEVER ERROR CONTINUE
        DELETE FROM t_edi_caterpillar;
      WHENEVER ERROR STOP 

      DECLARE cq_modifica CURSOR FOR
       SELECT UNIQUE cod_item
         FROM w_edi_caterpillar
        WHERE envia_arquivo = 'S'
      
      FOREACH cq_modifica INTO l_cod_item
      
         SELECT peso_item
           INTO l_peso_item 
           FROM item_prog_ethos
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = l_cod_item
      
         DECLARE cq_przent CURSOR FOR
          SELECT SUM(saldo) 
            FROM w_edi_caterpillar
           WHERE cod_item    = l_cod_item
      
         FOREACH cq_przent INTO l_saldo 
      
            LET l_qtd_item = l_saldo / l_peso_item    
            LET l_qtd_1 = l_qtd_item USING '&&&&&&&&&&&.&&&&&&&' 
      
            LET l_inteiro = l_qtd_1[1,11]
            LET l_decimal = l_qtd_1[13,19]
      
            IF l_decimal > 0 THEN
               LET l_qtd_item = l_inteiro + 1
            ELSE
               LET l_qtd_item = l_inteiro + 0 
            END IF       
      
            LET ma_tela3[l_ind].saldo       = l_qtd_item USING '&&&&&&&&&'
            LET ma_tela3[l_ind].cod_item    = l_cod_item
            LET ma_tela3[l_ind].prz_entrega = mr_tela.prz_entrega
      
            SELECT den_item_reduz
              INTO ma_tela3[l_ind].den_item
              FROM item
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = ma_tela3[l_ind].cod_item
               
            WHENEVER ERROR CONTINUE
              INSERT INTO t_edi_caterpillar VALUES (ma_tela3[l_ind].cod_item,
                                                    ma_tela3[l_ind].prz_entrega,
                                                    ma_tela3[l_ind].saldo)                             
            WHENEVER ERROR STOP                                                  
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("INCLUSAO","EDI_CATERPILLAR")
               RETURN FALSE
            END IF 
            
            LET l_ind = l_ind + 1
         END FOREACH
      END FOREACH
   END IF
   
   IF l_ind > 1 THEN
      LET l_ind = l_ind - 1
   END IF
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol03303") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol03303 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa
    
   CALL SET_COUNT(l_ind)
   
   INPUT ARRAY ma_tela3 WITHOUT DEFAULTS FROM s_edi.*

      BEFORE FIELD cod_item
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()
      
      AFTER FIELD cod_item
         IF ma_tela3[pa_curr].cod_item IS NOT NULL AND
            ma_tela3[pa_curr].cod_item <> ' ' THEN
            IF pol0330_verifica_item() = FALSE THEN
               ERROR 'Item não cadastrado.'
               NEXT FIELD cod_item
            END IF   
         END IF   
 
      ON KEY (Control-z)
         CALL pol0330_popup()
    
   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol03303
   
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Alteração da Programação Cancelada."
      CLOSE WINDOW w_pol03303
      CURRENT WINDOW IS w_pol0330
      RETURN FALSE
   ELSE
      IF log004_confirm(13,42) THEN
         IF pol0330_insere_arquivo_edi() THEN
            CLOSE WINDOW w_pol03303
            CURRENT WINDOW IS w_pol0330
            RETURN TRUE 
         ELSE
            ERROR "Alteração não Efetuada, Ocorreu Erros."
            CLOSE WINDOW w_pol03303
            CURRENT WINDOW IS w_pol0330
            RETURN FALSE
         END IF     
      ELSE
         ERROR "Alteração da Programação Cancelada."
         CLOSE WINDOW w_pol03303
         CURRENT WINDOW IS w_pol0330
         RETURN FALSE
      END IF
   END IF

END FUNCTION  

#-------------------------------#
 FUNCTION pol0330_verifica_item()
#-------------------------------#
   SELECT den_item_reduz
     INTO ma_tela3[pa_curr].den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = ma_tela3[pa_curr].cod_item
   
   IF sqlca.sqlcode = 0 THEN
      DISPLAY ma_tela3[pa_curr].den_item TO s_edi[sc_curr].den_item_reduz
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#------------------------------------#
 FUNCTION pol0330_insere_arquivo_edi()
#------------------------------------#
   DEFINE l_cont               SMALLINT 
   
   CALL log085_transacao("BEGIN")
   
   WHENEVER ERROR CONTINUE
     DELETE FROM t_edi_caterpillar;
   WHENEVER ERROR STOP 
    
   FOR l_cont = 1 TO 100
      IF ma_tela3[l_cont].cod_item IS NOT NULL AND
         ma_tela3[l_cont].cod_item <> ' ' THEN
         WHENEVER ERROR CONTINUE
           INSERT INTO t_edi_caterpillar VALUES (ma_tela3[l_cont].cod_item,
                                                 ma_tela3[l_cont].prz_entrega,
                                                 ma_tela3[l_cont].saldo)                             
         WHENEVER ERROR STOP                                                  
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("INCLUSAO","EDI_CATERPILLAR")
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE 
         END IF 
      END IF
   END FOR 
      
   CALL log085_transacao("COMMIT")   
   RETURN TRUE

END FUNCTION  

#-----------------------#
 FUNCTION pol0330_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION