#----------------------------------------------------------------------#
# SISTEMA...: VENDAS E DISTRIBUICAO DE PRODUTOS                        #
# PROGRAMA..: VDP4923                                                  #
# MODULOS...:                                                          #
# OBJETIVOS.: IMPORTACAO DE PEDIDOS SEPARADOS PELO COLETOR DE DADOS    #
# AUTOR.....: PATRICIA CYBELI DE CASTRO                                #
# DATA......: 05/05/2004                                               #
#----------------------------------------------------------------------#
DATABASE logix
GLOBALS
   DEFINE
      p_cod_empresa     LIKE  empresa.cod_empresa,
      p_user            LIKE  usuario.nom_usuario,
      p_num_controle    DECIMAL(07,0),
      p_status          SMALLINT,
      p_ies_grava       CHAR(1),
      g_ies_grafico     SMALLINT,
      g_erro_qualidade  SMALLINT,
      p_msg             CHAR(300)

   DEFINE p_versao CHAR(18)
END GLOBALS

#MODULARES
   DEFINE m_comando       CHAR(080),
          m_caminho       CHAR(080),
          m_caminho_help  CHAR(080),
          m_informou      SMALLINT,
          p_den_tip_carteira CHAR(30)

   DEFINE mr_tela
      RECORD
         todas_empresas CHAR(1),
         pedido_de  LIKE   pedidos.num_pedido,
         pedido_ate LIKE   pedidos.num_pedido,
         cod_tip_carteira like  pedidos.cod_tip_carteira
      END RECORD

   DEFINE mr_om_pedido_itens   RECORD
                                 prz_entrega_clas         DATE,
                                 num_prioridade           SMALLINT,
                                 cod_empresa              CHAR(02),
                                 cod_cliente              CHAR(15),
                                 cod_nat_oper             INTEGER,
                                 cod_cnd_pgto             DECIMAL(03,0),
                                 cod_repres               DECIMAL(4,0),
                                 cod_repres_adic          DECIMAL(4,0),
                                 pct_comissao             DECIMAL(04,2),
                                 cod_transport            CHAR(15),
                                 cod_consig               CHAR(15),
                                 ies_finalidade           DECIMAL(1,0),
                                 ies_frete                DECIMAL(1,0),
                                 pct_desc_financ          DECIMAL(04,2),
                                 num_solicit              DECIMAL(05,0),
                                 num_controle             DECIMAL(07,0),
                                 num_pedido               DECIMAL(06,0),
                                 num_sequencia            DECIMAL(05,0),
                                 cod_item                 CHAR(15),
                                 pct_desc_adic            DECIMAL(04,2),
                                 pre_unit                 DECIMAL(17,6),
                                 qtd_pecas_reserv         DECIMAL(10,3),
                                 prz_entrega              DATE,
                                 val_minimo_om            DECIMAL(15,2),
                                 vol_maximo_carga         DECIMAL(05,0),
                                 ies_tipo_entrega         CHAR(01),
                                 ies_end_entr_ped         SMALLINT,
                                 ies_embal_padrao         CHAR(01),
                                 cod_rota                 DECIMAL(5,0),
                                 cod_moeda                DECIMAL(03,0),
                                 pct_desc_adic_mest       DECIMAL(04,2),
                                 ies_bonificacao          CHAR(01),
                                 cod_local_estoq          CHAR(10)
                              END RECORD
                              
   DEFINE  m_num_pedido       LIKE pedidos.num_pedido,
           m_empresa          LIKE pedidos.cod_empresa,
           m_houve_erro       SMALLINT,
           mr_om_erro         RECORD LIKE om_erro.*,
           mr_pedido          RECORD LIKE pedidos.*,
           mr_linha           RECORD
                                 linha_arquivo CHAR(200)
                              END RECORD
#END MODULARES

MAIN

   CALL log0180_conecta_usuario()

   LET p_versao = "VDP4923-10.02.04"
   DEFER INTERRUPT
   WHENEVER ERROR CONTINUE
   CALL log1400_isolation()
   WHENEVER ERROR STOP

   CALL log140_procura_caminho("vdp4923.iem")
        RETURNING m_caminho_help
        OPTIONS HELP FILE m_caminho_help

   CALL log001_acessa_usuario("VDP","LOGERP") RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL vdp4923_controle()
   END IF

END MAIN

#---------------------------#
 FUNCTION vdp4923_controle()
#---------------------------#
   CALL log006_exibe_teclas("01", p_versao)
   CALL log130_procura_caminho("vdp4923") RETURNING m_caminho
   OPEN WINDOW w_vdp4923 AT 2,2 WITH FORM m_caminho
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL vdpr102_cria_tabelas_temp_reserva()

   CALL log0010_close_window_screen()
   MENU "OPCAO"
      COMMAND "Informar" "Informar parametros para solicita��o de Ordem de Montagem."
         HELP 0100
         MESSAGE ""
         IF log005_seguranca(p_user, "VDP", "vdp4923", "CO") THEN
            CALL vdp4923_informar_parametros()
                 RETURNING m_informou
            IF m_informou THEN
               NEXT OPTION "Processar"
            END IF
         ELSE
            ERROR " Usu�rio n�o autorizado para a fun��o. "
         END IF

      COMMAND "Processar" "Processa solicita��o de Ordem de Montagem."
         HELP 0101
         MESSAGE ""
         IF log005_seguranca(p_user, "VDP", "vdp4921", "CO") THEN
            IF m_informou THEN
               IF log004_confirm(12,25) = TRUE THEN
                  IF vdp4923_gera_solicitacao() THEN
                     NEXT OPTION "Fim"
                  ELSE
                     CALL vdp4923_limpa_campos()
                  END IF
                  LET m_informou = FALSE
               ELSE
                  ERROR "Op��o cancelada pelo usu�rio."
                  CALL vdp4923_limpa_campos()
                  NEXT OPTION "Informar"
               END IF
            ELSE
               ERROR " Informe os par�metros previamente."
               NEXT OPTION "Informar"
            END IF
         ELSE
            ERROR " Usu�rio n�o autorizado para a fun��o "
         END IF
     COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL vdp4923_sobre()
      COMMAND KEY("!")
         PROMPT "Digite o comando : " FOR m_comando
         RUN m_comando
         PROMPT "\nTecle algo para continuar" FOR CHAR m_comando

      COMMAND "Fim" "Retorna ao menu anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU

   CLOSE WINDOW w_vdp4923
END FUNCTION

#-----------------------#
 FUNCTION vdp4923_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------------#
FUNCTION vdp4923_informar_parametros()
#------------------------------------#

   CALL vdp4923_limpa_campos()

   DISPLAY p_cod_empresa TO cod_empresa
   LET mr_tela.todas_empresas = 'N'
   LET mr_tela.cod_tip_carteira = '01'
   
   INPUT BY NAME mr_tela.* WITHOUT DEFAULTS

   BEFORE INPUT
      LET mr_tela.pedido_de  = 0
      LET mr_tela.pedido_ate = 999999

      DISPLAY mr_tela.pedido_de, mr_tela.pedido_ate
           TO pedido_de, pedido_ate

   AFTER FIELD todas_empresas
      IF mr_tela.todas_empresas = 'S' THEN
         LET mr_tela.pedido_de  = NULL
         LET mr_tela.pedido_ate = NULL

         DISPLAY mr_tela.pedido_de, mr_tela.pedido_ate
              TO pedido_de, pedido_ate
         EXIT INPUT
      END IF

   AFTER FIELD cod_tip_carteira

      IF mr_tela.cod_tip_carteira IS NOT NULL THEN
         SELECT den_tip_carteira
           INTO p_den_tip_carteira
           FROM tipo_carteira
          WHERE cod_tip_carteira = mr_tela.cod_tip_carteira
         
         IF STATUS = 100 THEN
            ERROR 'Carteira inixistente!'
            NEXT FIELD cod_tip_carteira
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo', 'tipo_carteira')
               NEXT FIELD cod_tip_carteira
            END IF
         END IF

         DISPLAY p_den_tip_carteira TO den_tip_carteira
      END IF

   AFTER INPUT
       IF INT_FLAG = 0 THEN
          
          IF mr_tela.todas_empresas = 'N' THEN
             IF mr_tela.pedido_de IS NULL THEN
                ERROR "Campo com preenchimeto obrigat�rio!"
                NEXT FIELD pedido_de
             END IF
             
             IF mr_tela.pedido_ate IS NULL THEN
                ERROR "Campo com preenchimeto obrigat�rio!"
                NEXT FIELD pedido_ate
             END IF
          END IF

          IF mr_tela.todas_empresas = 'S' THEN
             LET mr_tela.pedido_de  = NULL
             LET mr_tela.pedido_ate = NULL
             LET mr_tela.cod_tip_carteira = NULL
             DISPLAY mr_tela.pedido_de, mr_tela.pedido_ate, mr_tela.cod_tip_carteira
                  TO pedido_de, pedido_ate, cod_tip_carteira
          END IF

       END IF

   ON KEY (control-w, f1)
       CALL vdp4923_help()

   ON KEY (control-z)
      CALL vdp4923_popup()

   END INPUT

   RETURN INT_FLAG = 0
END FUNCTION


#-----------------------#
FUNCTION vdp4923_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_tip_carteira)
         CALL log009_popup(8,25,"CARTEIRAS","tipo_carteira",
                     "cod_tip_carteira","den_tip_carteira","","","1=1 order by den_tip_carteira") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4923
         IF p_codigo IS NOT NULL THEN
            LET mr_tela.cod_tip_carteira = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_tip_carteira
         END IF

   END CASE   

END FUNCTION

#-----------------------#
 FUNCTION vdp4923_help()
#-----------------------#
    OPTIONS HELP FILE m_caminho_help
    CASE
        WHEN INFIELD (todas_empresas) CALL showhelp(106)
        WHEN INFIELD (pedido_de)  CALL showhelp(103)
        WHEN INFIELD (pedido_ate) CALL showhelp(104)
    END CASE
    CURRENT WINDOW IS w_vdp4923
END FUNCTION

#--------------------------------#
FUNCTION vdp4923_gera_solicitacao()
#--------------------------------#
   DEFINE  l_caminho     CHAR(080)

   CALL vdp4923_cria_tabelas_temporarias()

   CALL vdp4923_gera_ordens_montagem()

   IF NOT m_houve_erro THEN
      MESSAGE "Solicita��o finalizada com sucesso." ATTRIBUTE (REVERSE)
   ELSE
      MESSAGE "Ocorreram erros na gera��o da OM. Processo Abortado." ATTRIBUTE (REVERSE)
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION vdp4923_limpa_campos()
#-----------------------------#
   INITIALIZE mr_tela.* TO NULL
   CLEAR FORM
END FUNCTION

#-----------------------------------------#
FUNCTION vdp4923_cria_tabelas_temporarias()
#-----------------------------------------#
  WHENEVER ERROR CONTINUE
    DROP TABLE w_vdp8020
    CREATE TEMP TABLE w_vdp8020
          (cod_empresa              CHAR(02),
           num_sequencia            DECIMAL(05,0),
           cod_item                 CHAR(15),
           cod_grade_1              CHAR(15),
           cod_grade_2              CHAR(15),
           cod_grade_3              CHAR(15),
           cod_grade_4              CHAR(15),
           cod_grade_5              CHAR(15),
           qtd_pecas_reserv         DECIMAL(10,3),
           ies_lote                 CHAR(01),
           num_lote                 CHAR(15),
           endereco                 CHAR(15),
           num_volume               INTEGER,
           trans_estoque            INTEGER
         ) WITH NO LOG;
    CREATE INDEX ix_w_vdp8020  ON w_vdp8020
         (cod_empresa,
          num_sequencia,
          cod_item,
          cod_grade_1,
          cod_grade_2,
          cod_grade_3,
          cod_grade_4,
          cod_grade_5
         );
  WHENEVER ERROR STOP

   WHENEVER ERROR CONTINUE
      DELETE FROM om_pedido_itens
      CREATE TEMP TABLE om_pedido_itens
           (prz_entrega_clas         DATE,
                 {prazo de entrega do item}
            num_prioridade           SMALLINT,
                 {controle para dar a prioridade da selecao dos pedidos}
                 {conforme a digitacao da solicitacao}
            cod_empresa              CHAR(02),
                 {codigo da empresa}
            cod_cliente              CHAR(15),
                 {codigo do cliente}
            cod_nat_oper             INTEGER,
                 {codigo de operacao do pedido}
            cod_cnd_pgto             DECIMAL(03,0),
                 {codigo da condicao de pagamento}
            cod_repres               DECIMAL(4,0),
                 {codigo do representante }
            cod_repres_adic          DECIMAL(4,0),
                 {codigo do representante adicional }
            pct_comissao             DECIMAL(04,2),
                 {percentual de comissao do representante neste pedido}
            cod_transport            CHAR(15),
                 {codigo da transportadora}
            cod_consig               CHAR(15),
                 {codigo do consignatario}
            ies_finalidade           DECIMAL(1,0),
                 {indicador especial da finalidade dos produtos}
                 { 1 = industrializar e/ou comercializar}
                 { 2 = consumo de nao contribuinte}
                 { 3 = consumo de contribuinte}
            ies_frete                DECIMAL(1,0),
                 { indicador especial do tipo de frete}
                 { 1 = CIF }
                 { 2 = FOB }
                 { 3 = Capitais}
                 { 4 = CIF com percentual}
            pct_desc_financ          DECIMAL(04,2),
                 {percentual de desconto financeiro}
            num_solicit              DECIMAL(05,0),
                 {numero da solicitacao de ordem de montagem}
            num_controle             DECIMAL(07,0),
                 {numero de controle para separacao de pedidos de um mesmo cliente}
            num_pedido               DECIMAL(06,0),
                 {numero do pedido  }
            num_sequencia            DECIMAL(05,0),
                 {numero sequencial do item no pedido}
            cod_item                 CHAR(15),
                 {codigo do item    }
            pct_desc_adic            DECIMAL(04,2),
                 {percentual de desconto adicional para o item}
            pre_unit                 DECIMAL(17,6),
                 {preco unitario do produto}
            qtd_pecas_reserv         DECIMAL(10,3),
                 {quantidade de pecas a reservar na O.M.}
            prz_entrega              DATE,
                 {prazo de entrega do item}
            val_minimo_om            DECIMAL(15,2),
                 {valor minimo para emissao de ordem de montagem}
            vol_maximo_carga         DECIMAL(05,0),
                 {volume maximo para da carga para um ordem de montagem}
            ies_tipo_entrega         CHAR(01),
                 {indicador especial do tipo da entrega do pedido}
                 {"1" = Total/Total}
                 {"2" = Parcial/Total}
                 {"3" = Parcial/Parcial}
            ies_end_entr_ped         SMALLINT,
                 {indicador especial de endereco de entrega do pedido}
            ies_embal_padrao         CHAR(01),
                 {indicador especial para pedido com embalagem padrao}
                 {"S" = Sim }
                 {"N" = Nao }
            cod_rota                 DECIMAL(5,0),
                 {codigo da rota}
            cod_moeda                DECIMAL(03,0),
                 {codigo da moeda do pedido}
            pct_desc_adic_mest       DECIMAL(04,2),
                 {percentual de desconto adicional mestre do pedido}
            ies_bonificacao          CHAR(01)      NOT NULL,
                 {indicador especial para identificar os itens de bonificacao}
                 {S = Sim}
                 {N = Nao}
            cod_local_estoq          CHAR(10)
                 {codigo do local de estoque para reserva}
           ) WITH NO LOG;
      CREATE INDEX ix_om_ped_item_1  ON om_pedido_itens
           (cod_empresa,
            num_pedido,
            num_sequencia
           );
   WHENEVER ERROR STOP

END FUNCTION

#-------------------------------------#
FUNCTION vdp4923_gera_ordens_montagem()
#-------------------------------------#
   DEFINE sql_stmt CHAR(500)
   DEFINE l_num_om        LIKE ordem_montag_mest.num_om,
          l_cod_cliente   LIKE clientes.cod_cliente,
          l_cod_empresa   LIKE ordem_montag_mest.cod_empresa,
          l_num_pedido    LIKE ordem_montag_item.num_pedido  #OS 454126

   LET p_num_controle  = 0

   LET sql_stmt = "SELECT pedido, empresa ",
                  "  FROM vdp_pedido_575 ",
                  " WHERE sit_pedido = 'R' "

   IF mr_tela.todas_empresas = 'N' THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND empresa = '",p_cod_empresa,"' "
   END IF

   IF mr_tela.pedido_de IS NOT NULL AND mr_tela.pedido_de >= 0 THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND pedido >= ", mr_tela.pedido_de
   END IF

   IF mr_tela.pedido_ate IS NOT NULL AND mr_tela.pedido_ate > 0 THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND pedido <= ", mr_tela.pedido_ate
   END IF

   PREPARE var_pedidos FROM sql_stmt
   DECLARE cm_pedido CURSOR FOR var_pedidos
   OPEN cm_pedido
   FETCH cm_pedido INTO m_num_pedido, m_empresa

   IF sqlca.sqlcode = NOTFOUND THEN
      MESSAGE "Argumentos de pesquisa n�o encontrados."
      LET m_houve_erro = TRUE
      SLEEP 5
      RETURN
   END IF

   CALL log085_transacao("BEGIN")

   FOREACH cm_pedido INTO m_num_pedido, m_empresa
   
      IF mr_tela.cod_tip_carteira IS NOT NULL THEN
         SELECT cod_empresa
           FROM pedidos
          WHERE cod_empresa = m_empresa
            AND num_pedido  = m_num_pedido
            AND cod_tip_carteira = mr_tela.cod_tip_carteira
         
         IF STATUS = 100 THEN
            CONTINUE FOREACH
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','pedidos:cm_pedido')
               LET m_houve_erro = TRUE
               RETURN
            END IF
         END IF  
      END IF
      
      DELETE FROM om_erro 
       WHERE cod_empresa = m_empresa 
         AND num_pedido  = m_num_pedido
   
      IF vdp4923_checa_qtd_coletada() THEN
         CALL vdp4923_grava_om_pedido_itens()
      ELSE
         CONTINUE FOREACH    
      END IF 
      
#OS 454126
      {DELETE FROM w_vdp8020 WHERE 1=1
      WHENEVER ERROR CONTINUE
      DELETE FROM om_pedido_itens WHERE 1=1
      WHENEVER ERROR STOP
      IF sqlca.sqlcode = 0 THEN
      END IF}
#Fim OS 454126
   END FOREACH

#OS 454126
   IF  NOT m_houve_erro THEN
      CALL vdp102_create_temp()
      CALL vdp102_controle()

       # Verifica se ocorreu erro na inspecao da qualidade (se o modulo QEA estiver instalado)
       WHENEVER ERROR CONTINUE
          SELECT par_ies
          FROM par_vdp_pad
          WHERE cod_empresa       = p_cod_empresa #OS 454126 mr_om_pedido_itens.cod_empresa
                AND cod_parametro = 'ies_qea_instal'
                AND par_ies       = 'S'
       WHENEVER ERROR STOP

       IF sqlca.sqlcode = 0 THEN
          IF g_erro_qualidade = TRUE THEN
             CALL log0030_mensagem("Problema na inspecao da qualidade.","exclamation")
             LET m_houve_erro = TRUE
          END IF
       END IF
       #-----

       SELECT par_ies
         FROM par_vdp_pad
        WHERE cod_empresa   = p_cod_empresa #OS 454126 mr_om_pedido_itens.cod_empresa
          AND cod_parametro = 'ies_limite_credito'
          AND par_ies       = 'S'

       IF sqlca.sqlcode = 0 THEN
          CALL vdp4923_credito_cliente()
       END IF
#------------------ OS 468382 -------------------------------------#
       WHENEVER ERROR CONTINUE
       DECLARE cq_credito CURSOR FOR
       SELECT UNIQUE num_om,
                     cod_cliente,
                     cod_empresa
         FROM w_vdp636
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          CALL log003_err_sql("DECLARE","CQ_CREDITO")
       END IF

       WHENEVER ERROR CONTINUE
       FOREACH cq_credito INTO l_num_om,
                               l_cod_cliente,
                               l_cod_empresa #OS 454126
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql('FOREACH','CQ_CREDITO')
             LET m_houve_erro = TRUE
             RETURN
          END IF

          WHENEVER ERROR CONTINUE
           SELECT MIN(num_pedido)
             INTO l_num_pedido
             FROM ordem_montag_item
            WHERE cod_empresa = l_cod_empresa
              AND num_om      = l_num_om
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql('SELECT','ORDEM_MONTAG_ITEM')
          END IF

          WHENEVER ERROR CONTINUE
           SELECT *
             INTO mr_pedido.*
             FROM pedidos
            WHERE cod_empresa = l_cod_empresa
              AND num_pedido  = l_num_pedido
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql('SELECT','PEDIDOS')
           END IF

          WHENEVER ERROR CONTINUE
          UPDATE vdp_pedido_575
             SET sit_pedido = 'P'
           WHERE empresa = mr_pedido.cod_empresa
             AND pedido  = mr_pedido.num_pedido
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("ATUALIZACAO","VDP_PEDIDO_575")
             LET m_houve_erro = TRUE
          END IF
      END FOREACH
   END IF
#------------------ FIM: OS 468382 --------------------------------#

   WHENEVER ERROR CONTINUE
   DELETE FROM w_vdp8020
   DELETE FROM om_pedido_itens
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
   END IF
#Fim OS 454126

   IF NOT m_houve_erro THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   FREE cq_credito

END FUNCTION

#---------------------------------------#
 FUNCTION vdp4923_checa_qtd_coletada()
#---------------------------------------#
##  Rotina incluida em 13/03 consiste se a quantidade coletada na separa��o possui
##  estoque cadastrado no local de estoque do item, caso o coletado for maior que o 
##  estoque no sistema, nao devera gerar OM para este pedido. Toni

DEFINE l_qtd_pecas_reserv  DECIMAL(13,3),
       l_qtd_est           DECIMAL(13,3),
       l_qtd_omp           DECIMAL(13,3),
       l_qtd_res           DECIMAL(13,3),
       l_cod_item          CHAR(15),
       l_erro              CHAR(1),
       l_ordem             CHAR(2)

WHENEVER ERROR CONTINUE

   INITIALIZE mr_om_pedido_itens.* TO NULL
   LET l_erro = 'N'
   
   SELECT *
     INTO mr_pedido.*
     FROM pedidos
    WHERE pedidos.num_pedido  = m_num_pedido
      AND pedidos.cod_empresa = m_empresa

   WHENEVER ERROR CONTINUE

   DECLARE cm_cons_qtd CURSOR FOR
   SELECT item,
          sequencial_pedido, 
          qtd_kg_separado 
     FROM vdp_ped_item_575
    WHERE empresa = mr_pedido.cod_empresa
      AND pedido  = mr_pedido.num_pedido
    ORDER BY item 

   FOREACH cm_cons_qtd INTO l_cod_item,
                            l_ordem,
                            l_qtd_pecas_reserv

      IF mr_pedido.cod_local_estoq IS NULL OR
         mr_pedido.cod_local_estoq = " " THEN

         SELECT cod_local_estoq
           INTO mr_om_pedido_itens.cod_local_estoq
           FROM item
          WHERE cod_empresa  = mr_om_pedido_itens.cod_empresa
            AND cod_item     = mr_om_pedido_itens.cod_item

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("LEITURA","ITEM")
            LET m_houve_erro = TRUE
         END IF
      ELSE
         LET mr_om_pedido_itens.cod_local_estoq = mr_pedido.cod_local_estoq
      END IF
   
      SELECT SUM(qtd_reservada)
        INTO l_qtd_res
        FROM estoque_loc_reser 
       WHERE cod_empresa =  mr_pedido.cod_empresa
         AND cod_item    =  l_cod_item
         AND cod_local   =  mr_om_pedido_itens.cod_local_estoq

      IF l_qtd_res IS NULL THEN
         LET l_qtd_res = 0
      END IF    

      SELECT SUM(qtd_saldo)
        INTO l_qtd_est
        FROM estoque_lote
       WHERE cod_empresa =  mr_pedido.cod_empresa
         AND cod_item    =  l_cod_item
         AND cod_local   =  mr_om_pedido_itens.cod_local_estoq
         AND ies_situa_qtd = 'L'
         
      IF l_qtd_est IS NULL THEN
         LET l_qtd_est = 0
      ELSE
         LET l_qtd_est = l_qtd_est - l_qtd_res
      END IF    

      SELECT SUM(qtd_pecas_reserv)
        INTO l_qtd_omp 
        FROM om_pedido_itens
       WHERE cod_empresa =  mr_pedido.cod_empresa
         AND cod_item    =  l_cod_item
         
      IF l_qtd_omp IS NULL THEN
         LET l_qtd_omp = 0
      END IF    

      LET l_qtd_est = l_qtd_est - l_qtd_omp

      IF l_qtd_est < l_qtd_pecas_reserv THEN
         LET mr_om_erro.cod_empresa       = mr_pedido.cod_empresa
         LET mr_om_erro.num_pedido        = mr_pedido.num_pedido
         LET mr_om_erro.sequencia         = l_ordem
         LET mr_om_erro.cod_cliente       = mr_pedido.cod_cliente
         LET mr_om_erro.cod_item          = l_cod_item         
         LET mr_om_erro.qtd_dias_atr_dupl = NULL
         LET mr_om_erro.qtd_dias_atr_med  = NULL
         LET mr_om_erro.nom_usuario       = p_user
         LET mr_om_erro.mensagem          = 'ITEM DO PEDIDO COM PROBLEMA DE ESTOQUE '
         INSERT INTO om_erro VALUES (mr_om_erro.*)
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("INCLUSAO","OM_ERRO")
            RETURN FALSE
         END IF
         LET l_erro = 'S' 
      END IF   
   END FOREACH       

   IF l_erro = 'N' THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF       

END FUNCTION


#---------------------------------------#
 FUNCTION vdp4923_grava_om_pedido_itens()
#---------------------------------------#
   DEFINE l_gera_om_inc       CHAR(01),
          l_nom_cliente       LIKE clientes.nom_cliente,
          l_cod_cidade        LIKE clientes.cod_cidade,
          l_cod_rota          LIKE clientes.cod_rota,
          l_ies_situacao      LIKE clientes.ies_situacao,
          l_den_cidade        LIKE cidades.den_cidade,
          l_cod_uni_feder     LIKE cidades.cod_uni_feder,
          l_ordem             CHAR(2),
          l_qtd_pecas_reserv  DECIMAL(13,3),
          l_qtd_est           DECIMAL(13,3),
          l_qtd_omp           DECIMAL(13,3),
          l_qtd_res           DECIMAL(13,3),
          l_qtd_cancel        DECIMAL(13,3),
          l_qtd_pecas_solic   DECIMAL(10),
          l_cont              INTEGER,
          l_parcial           CHAR(1),
          l_liberado          CHAR(1),
          l_cod_item          CHAR(15),
          l_qtd_padr_embal    LIKE item_embalagem.qtd_padr_embal,
          l_ver               SMALLINT,
          l_status            SMALLINT

   DEFINE l_par_vdp_val_min   LIKE par_vdp.val_min_om

   SELECT par_vdp_pad.par_ies
     INTO l_gera_om_inc
     FROM par_vdp_pad
   WHERE par_vdp_pad.cod_empresa   = m_empresa
     AND par_vdp_pad.cod_parametro = "ies_gera_om_inc"

   IF sqlca.sqlcode <> 0 THEN
      LET l_gera_om_inc = 'N'
   END IF

   SELECT par_ies
     FROM par_vdp_pad
    WHERE cod_empresa = mr_pedido.cod_empresa
      AND cod_parametro = 'ies_qea_instal'
      AND par_ies = 'S'

      WHENEVER ERROR STOP

      IF sqlca.sqlcode = 0 THEN
         CALL qea1020_cria_temp()
              RETURNING l_status
      END IF

      SELECT val_min_om
        INTO l_par_vdp_val_min
        FROM par_vdp
       WHERE par_vdp.cod_empresa = mr_pedido.cod_empresa

      IF sqlca.sqlcode <> 0 THEN
         LET l_par_vdp_val_min = 0
      END IF

      SELECT clientes.nom_cliente, clientes.cod_cidade,
             clientes.cod_rota, clientes.ies_situacao
        INTO l_nom_cliente, l_cod_cidade, l_cod_rota, l_ies_situacao
        FROM clientes, pedidos
       WHERE pedidos.num_pedido   = mr_pedido.num_pedido
         AND pedidos.cod_empresa  = mr_pedido.cod_empresa
         AND clientes.cod_cliente = mr_pedido.cod_cliente

      SELECT den_cidade, cod_uni_feder
        INTO l_den_cidade, l_cod_uni_feder
        FROM cidades
       WHERE cidades.cod_cidade = l_cod_cidade

      IF sqlca.sqlcode <> 0 THEN
         LET l_den_cidade = " "
         LET l_cod_uni_feder = " "
      END IF

      LET p_num_controle     = p_num_controle + 1

      LET mr_om_pedido_itens.cod_empresa      = mr_pedido.cod_empresa
      LET mr_om_pedido_itens.num_solicit      = 1
      LET mr_om_pedido_itens.num_controle     = p_num_controle 
      LET mr_om_pedido_itens.num_pedido       = mr_pedido.num_pedido
      LET mr_om_pedido_itens.val_minimo_om    = l_par_vdp_val_min
      LET mr_om_pedido_itens.vol_maximo_carga = 99999
      LET mr_om_pedido_itens.cod_cliente      = mr_pedido.cod_cliente
      LET mr_om_pedido_itens.cod_nat_oper     = mr_pedido.cod_nat_oper
      LET mr_om_pedido_itens.cod_cnd_pgto     = mr_pedido.cod_cnd_pgto
      LET mr_om_pedido_itens.ies_embal_padrao = mr_pedido.ies_embal_padrao
      LET mr_om_pedido_itens.cod_repres       = mr_pedido.cod_repres
      LET mr_om_pedido_itens.cod_repres_adic  = mr_pedido.cod_repres_adic
      LET mr_om_pedido_itens.cod_local_estoq  = mr_pedido.cod_local_estoq

      IF mr_om_pedido_itens.cod_local_estoq IS NULL THEN
         LET mr_om_pedido_itens.cod_local_estoq = 0
      END IF

      IF mr_om_pedido_itens.cod_repres_adic IS NULL THEN
         LET mr_om_pedido_itens.cod_repres_adic = 0
      END IF

      LET mr_om_pedido_itens.pct_comissao     = mr_pedido.pct_comissao
      LET mr_om_pedido_itens.cod_transport    = mr_pedido.cod_transpor

      IF mr_om_pedido_itens.cod_transport IS NULL THEN
         LET mr_om_pedido_itens.cod_transport = 0
      END IF

      LET mr_om_pedido_itens.cod_consig       = mr_pedido.cod_consig

      IF mr_om_pedido_itens.cod_consig IS NULL THEN
         LET mr_om_pedido_itens.cod_consig = 0
      END IF

      LET mr_om_pedido_itens.ies_finalidade     = mr_pedido.ies_finalidade
      LET mr_om_pedido_itens.ies_frete          = mr_pedido.ies_frete
      LET mr_om_pedido_itens.pct_desc_financ    = mr_pedido.pct_desc_financ
      LET mr_om_pedido_itens.cod_rota           = l_cod_rota
      LET mr_om_pedido_itens.cod_moeda          = mr_pedido.cod_moeda
      LET mr_om_pedido_itens.pct_desc_adic_mest = mr_pedido.pct_desc_adic
      LET mr_om_pedido_itens.ies_end_entr_ped   = 0
      LET mr_om_pedido_itens.ies_tipo_entrega   = mr_pedido.ies_tip_entrega

      IF vdp4923_verifica_gravacao() = FALSE THEN
         RETURN
      END IF

      DECLARE cm_ped_itens_575 CURSOR FOR
      SELECT item,
             sequencial_pedido,
             qtd_kg_separado,
             qtd_solicitada,
             entrega_parcial,
             item_liberado
        FROM vdp_ped_item_575
       WHERE empresa = mr_pedido.cod_empresa
         AND pedido  = mr_pedido.num_pedido
       ORDER BY sequencial_pedido

      OPEN cm_ped_itens_575
      FETCH cm_ped_itens_575 INTO l_cod_item, l_ordem,
                                  l_qtd_pecas_reserv, l_qtd_pecas_solic,
                                  l_parcial, l_liberado

      IF sqlca.sqlcode <> 0 THEN
         RETURN
      END IF

      FOREACH cm_ped_itens_575 INTO l_cod_item, l_ordem,
                                    l_qtd_pecas_reserv, l_qtd_pecas_solic,
                                    l_parcial, l_liberado

         IF l_qtd_pecas_reserv < 0 THEN
            CONTINUE FOREACH
         END IF
          
         LET l_qtd_padr_embal = 1

         IF mr_pedido.ies_embal_padrao = "1" THEN
            SELECT qtd_padr_embal
              INTO l_qtd_padr_embal
             FROM item_embalagem 
             WHERE item_embalagem.cod_empresa   = mr_pedido.cod_empresa
               AND item_embalagem.cod_item      = l_cod_item
               AND item_embalagem.ies_tip_embal IN ("N","I")

            IF sqlca.sqlcode <> 0 THEN
               LET l_qtd_padr_embal = 1
            END IF
         END IF

         IF mr_pedido.ies_embal_padrao = "2" THEN

            SELECT qtd_padr_embal
              INTO l_qtd_padr_embal
              FROM item_embalagem
             WHERE item_embalagem.cod_empresa = mr_pedido.cod_empresa
               AND item_embalagem.cod_item    = l_cod_item
               AND item_embalagem.ies_tip_embal IN ("E","C")

            IF sqlca.sqlcode <> 0 THEN
               LET l_qtd_padr_embal = 1
            END IF

         END IF

         {retorna como embalagens ent�o tenho que voltar para n�mero total de pe�as solicitadas}
         {o processo est� em coment�rio, pois o programa j� recebe a quantidade
         solicitada em KILO}
#         LET l_qtd_pecas_reserv = l_qtd_pecas_reserv * l_qtd_padr_embal

         LET mr_om_pedido_itens.num_sequencia    = l_ordem
         LET mr_om_pedido_itens.cod_item         = l_cod_item
         LET mr_om_pedido_itens.qtd_pecas_reserv = l_qtd_pecas_reserv
         LET mr_om_pedido_itens.prz_entrega_clas = DATE("31/12/9999")

         SELECT pct_desc_adic, pre_unit, prz_entrega
           INTO mr_om_pedido_itens.pct_desc_adic,
                mr_om_pedido_itens.pre_unit,
                mr_om_pedido_itens.prz_entrega
           FROM ped_itens
          WHERE cod_empresa   = mr_pedido.cod_empresa
            AND num_pedido    = mr_pedido.num_pedido
            AND num_sequencia = l_ordem

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("LEITURA","PED_ITENS")
            LET m_houve_erro = TRUE
         END IF

         LET mr_om_pedido_itens.ies_bonificacao = "N"

         # inclusao do incentivo fiscal do item no campo prioridade
         # para separar as OM por incentivo.

         IF l_gera_om_inc = "S" THEN
            CALL vdp4923_busca_prioridade(mr_pedido.cod_empresa)
         ELSE
            LET mr_om_pedido_itens.num_prioridade = 0
         END IF

         IF mr_om_pedido_itens.qtd_pecas_reserv > 0  THEN
         
            INSERT INTO om_pedido_itens VALUES (mr_om_pedido_itens.*)
         
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("INCLUSAO","OM_PEDIDO_ITENS")
               LET m_houve_erro = TRUE
            END IF
         
            {Caso a quantidade de pe�as reservadas seja menor que a solicitada
             o restante � cancelado}
            IF l_qtd_pecas_solic  > l_qtd_pecas_reserv THEN
         
               UPDATE ped_itens
                  SET qtd_pecas_cancel = (l_qtd_pecas_solic - l_qtd_pecas_reserv)
                WHERE cod_empresa   = mr_pedido.cod_empresa
                  AND num_pedido    = mr_pedido.num_pedido
                  AND num_sequencia = l_ordem
         
               IF sqlca.sqlcode <> 0 THEN
                  CALL log003_err_sql("MANUTENCAO","PED_ITENS")
                  LET m_houve_erro = TRUE
               END IF
         
               LET l_qtd_cancel = l_qtd_pecas_solic - l_qtd_pecas_reserv
         
               INSERT INTO ped_itens_cancel VALUES (mr_pedido.cod_empresa,
                                                    mr_pedido.num_pedido,
                                                    l_ordem,
                                                    mr_om_pedido_itens.cod_item,
                                                    TODAY,
                                                    0,
                                                    l_qtd_cancel,
                                                    0)
         
               IF sqlca.sqlcode <> 0 THEN
                  CALL log003_err_sql("INCLUSAO","PED_ITENS_CANCEL")
                  LET m_houve_erro = TRUE
               END IF
            END IF
         ELSE
            UPDATE ped_itens
               SET qtd_pecas_cancel = l_qtd_pecas_solic 
             WHERE cod_empresa   = mr_pedido.cod_empresa
               AND num_pedido    = mr_pedido.num_pedido
               AND num_sequencia = l_ordem
         
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("MANUTENCAO","PED_ITENS")
               LET m_houve_erro = TRUE
            END IF
         
            LET l_qtd_cancel = l_qtd_pecas_solic
         
            INSERT INTO ped_itens_cancel VALUES (mr_pedido.cod_empresa,
                                                 mr_pedido.num_pedido,
                                                 l_ordem,
                                                 mr_om_pedido_itens.cod_item,
                                                 TODAY,
                                                 0,
                                                 l_qtd_cancel,
                                                 0)
         
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("INCLUSAO","PED_ITENS_CANCEL")
               LET m_houve_erro = TRUE
            END IF
         END IF
      END FOREACH
      
   WHENEVER ERROR STOP

{#OS 454126
   IF  NOT m_houve_erro THEN
      CALL vdp102_create_temp()
      CALL vdp102_controle()

       # Verifica se ocorreu erro na inspecao da qualidade (se o modulo QEA estiver instalado)
       WHENEVER ERROR CONTINUE
          SELECT par_ies
          FROM par_vdp_pad
          WHERE cod_empresa       = mr_om_pedido_itens.cod_empresa
                AND cod_parametro = 'ies_qea_instal'
                AND par_ies       = 'S'
       WHENEVER ERROR STOP

       IF sqlca.sqlcode = 0 THEN
          IF g_erro_qualidade = TRUE THEN
             CALL log0030_mensagem("Problema na inspecao da qualidade.","exclamation")
             LET m_houve_erro = TRUE
          END IF
       END IF
       #-----


       SELECT par_ies
         FROM par_vdp_pad
        WHERE cod_empresa   = mr_om_pedido_itens.cod_empresa
          AND cod_parametro = 'ies_limite_credito'
          AND par_ies       = 'S'

       IF sqlca.sqlcode = 0 THEN
          CALL vdp4923_credito_cliente()
       END IF

   END IF
#Fim OS 454126}

END FUNCTION

#---------------------------------#
 FUNCTION vdp4923_credito_cliente()
#---------------------------------#
   DEFINE l_num_om        LIKE ordem_montag_mest.num_om,
          l_cod_cliente   LIKE clientes.cod_cliente,
          l_cod_empresa   LIKE ordem_montag_mest.cod_empresa #OS 454126

   DECLARE cq_cred_om CURSOR FOR
      SELECT UNIQUE num_om, cod_cliente, cod_empresa
        FROM w_vdp636

   FOREACH cq_cred_om INTO l_num_om,
                           l_cod_cliente,
                           l_cod_empresa #OS 454126

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_CRED_OM')
         LET m_houve_erro = TRUE
         RETURN
      END IF

      IF vdp4923_verifica_limite_credito(l_cod_cliente,l_num_om, l_cod_empresa) = FALSE THEN

        UPDATE ordem_montag_mest
           SET ies_sit_om = 'B'
         WHERE cod_empresa = l_cod_empresa #OS 454126 mr_om_pedido_itens.cod_empresa
           AND num_om      = l_num_om

        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('ATUALIZACAO','ORDEM_MONTAG_MEST')
           LET m_houve_erro = TRUE
           RETURN
        END IF
      END IF
   END FOREACH

   FREE cq_cred_om

END FUNCTION

#------------------------------------------------------------------------------#
 FUNCTION vdp4923_verifica_limite_credito(l_cod_cliente, l_num_om,l_cod_empresa)
#------------------------------------------------------------------------------#
   DEFINE l_cod_cliente       LIKE clientes.cod_cliente,
          l_num_om            LIKE ordem_montag_mest.num_om,
          l_cod_empresa       LIKE ordem_montag_mest.cod_empresa

   DEFINE l_erro              CHAR(70),
          l_dat_validade      LIKE cli_credito.dat_val_lmt_cr,
          l_qtd_dias_atr_med  LIKE cli_credito.qtd_dias_atr_med,
          l_qtd_dias_atr_dup  LIKE cli_credito.qtd_dias_atr_dupl,
          l_val_dup_aberto    LIKE cli_credito.val_dup_aberto,
          l_val_limite_cred   LIKE cli_credito.val_limite_cred,
          l_val_fatur         DECIMAL(13,2),
          l_val_ordem         DECIMAL(13,2),
          l_num_pedido        LIKE ordem_montag_item.num_pedido

   MESSAGE " Verificando limite do credito do cliente. "

   CALL vdp3792_verifica_credito(l_cod_cliente, l_num_om)
      RETURNING p_status,
                l_erro,
                l_dat_validade,
                l_qtd_dias_atr_med,
                l_qtd_dias_atr_dup,
                l_val_dup_aberto,
                l_val_limite_cred,
                l_val_fatur,
                l_val_ordem
   MESSAGE " "

 #------------------ OS 468382 -------------------------------------#
    WHENEVER ERROR CONTINUE
     SELECT MIN(num_pedido)
       INTO l_num_pedido
       FROM ordem_montag_item
      WHERE cod_empresa = l_cod_empresa
        AND num_om      = l_num_om
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('SELECT','ORDEM_MONTAG_ITEM')
    END IF

    WHENEVER ERROR CONTINUE
     SELECT *
       INTO mr_pedido.*
       FROM pedidos
      WHERE cod_empresa = l_cod_empresa
        AND num_pedido  = l_num_pedido
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('SELECT','PEDIDOS')
     END IF

#------------------FIM: OS 468382 ------------------------------#


   CALL vdp4923_verifica_lista(l_qtd_dias_atr_med, l_qtd_dias_atr_dup)

   IF   m_houve_erro THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF


   IF  p_status = FALSE THEN
      INITIALIZE mr_om_erro.* TO NULL
      ###   A posicao 40 da mensagem de erro esta setada como "F" para identificar
      ###   que este erro e' um problema de credito do cliente e tambem para que
      ###   esta nao seja eliminada em outras solicitacoes de O.M.
      LET l_erro[40] = "F"
      LET mr_om_erro.mensagem = l_erro
      ###   O numero da O.M. seta sendo armazenada no codigo do item para quando a
      ###   O.M. FOR liberada no VDP1652, seja excluido apenas as mensagens de con-
      ###   sistencias dessa O.M., pois � possivel que exista outra O.M. bloqueada
      ###   o mesmo numero de pedido.
      LET mr_om_erro.cod_item = l_num_om

      CALL vdp4923_grava_om_erro(l_qtd_dias_atr_med, l_qtd_dias_atr_dup)
      IF l_dat_validade IS NOT NULL THEN
         INITIALIZE mr_om_erro.* TO NULL
         LET mr_om_erro.mensagem = "DATA DE VALIDADE CREDITO: ",
                                   l_dat_validade
         LET mr_om_erro.mensagem[40] = "F"
         LET mr_om_erro.cod_item = l_num_om
         CALL vdp4923_grava_om_erro(l_qtd_dias_atr_med, l_qtd_dias_atr_dup)
      END IF
      IF l_val_dup_aberto IS NOT NULL AND
         l_val_dup_aberto > 0   THEN
         INITIALIZE mr_om_erro.* TO NULL
         LET mr_om_erro.mensagem = "VALOR DE DUPL. EM ABERTO: ",
                                   l_val_dup_aberto USING "#####,##&.&&"
         LET mr_om_erro.mensagem[40] = "F"
         LET mr_om_erro.cod_item = l_num_om
         CALL vdp4923_grava_om_erro(l_qtd_dias_atr_med, l_qtd_dias_atr_dup)
      END IF
      IF l_val_limite_cred IS NOT NULL
         AND l_val_limite_cred > 0  THEN
         INITIALIZE mr_om_erro.* TO NULL
         LET mr_om_erro.mensagem = "VALOR LIMITE DE CREDITO: ",
                                   l_val_limite_cred USING "######,##&.&&"
         LET mr_om_erro.mensagem[40] = "F"
         LET mr_om_erro.cod_item = l_num_om
         CALL vdp4923_grava_om_erro(l_qtd_dias_atr_med, l_qtd_dias_atr_dup)
      END IF
      IF l_val_fatur IS NOT NULL AND
         l_val_fatur > 0   THEN
         INITIALIZE mr_om_erro.* TO NULL
         LET mr_om_erro.mensagem = "VALOR DO FATURAMENTO:    ",
                                   l_val_fatur USING "######,##&.&&"
         LET mr_om_erro.mensagem[40] = "F"
         LET mr_om_erro.cod_item = l_num_om
         CALL vdp4923_grava_om_erro(l_qtd_dias_atr_med, l_qtd_dias_atr_dup)
      END IF
      IF l_val_ordem IS NOT NULL AND
         l_val_ordem > 0  THEN
         INITIALIZE mr_om_erro.* TO NULL
         LET mr_om_erro.mensagem = "VALOR ORDEM DE MONTAGEM: ",
                                   l_val_ordem USING "######,##&.&&"
         LET mr_om_erro.mensagem[40] = "F"
         LET mr_om_erro.cod_item = l_num_om
         CALL vdp4923_grava_om_erro(l_qtd_dias_atr_med, l_qtd_dias_atr_dup)
      END IF
      ERROR "FOI GERADA OM BLOQUEADA - PROBLEMA NO CREDITO DO CLIENTE."
      SLEEP 2
      RETURN FALSE
   END IF
   RETURN TRUE

END FUNCTION

#-----------------------------------------------#
 FUNCTION vdp4923_busca_prioridade(l_cod_empresa)
#-----------------------------------------------#
   DEFINE l_cod_empresa LIKE pedidos.cod_empresa

   SELECT MIN(tip_incentiv) INTO mr_om_pedido_itens.num_prioridade
   FROM obf_incentiv_item
   WHERE empresa   = l_cod_empresa
         AND item  = mr_om_pedido_itens.cod_item

   IF sqlca.sqlcode <> 0 THEN
      SELECT MIN(tip_incentiv) INTO mr_om_pedido_itens.num_prioridade
      FROM obf_incentiv_item, item
      WHERE empresa                = l_cod_empresa
            AND linha_produto      = item.cod_lin_prod
            AND linha_receita      = item.cod_lin_recei
            AND segmto_mercado     = item.cod_seg_merc
            AND classe_uso         = item.cod_cla_uso
            AND item.cod_empresa   = l_cod_empresa
            AND item.cod_item      = mr_om_pedido_itens.cod_item

      IF sqlca.sqlcode <> 0 THEN
         SELECT MIN(tip_incentiv) INTO mr_om_pedido_itens.num_prioridade
         FROM obf_incentiv_item,item
         WHERE obf_incentiv_item.empresa = l_cod_empresa
               AND item.cod_empresa      = obf_incentiv_item.empresa
               AND item.cod_cla_fisc     = obf_incentiv_item.classif_fiscal
               AND item.cod_item         = mr_om_pedido_itens.cod_item

         IF sqlca.sqlcode <> 0 THEN
            LET mr_om_pedido_itens.num_prioridade = 0
         END IF
      END IF
   END IF

 END FUNCTION

#------------------------------------------------------------#
FUNCTION vdp4923_grava_om_erro(l_val_atr_med, l_val_atr_dup)
#------------------------------------------------------------#
   DEFINE l_val_atr_med         LIKE cli_credito.qtd_dias_atr_med,
          l_val_atr_dup         LIKE cli_credito.qtd_dias_atr_dupl

   IF l_val_atr_med = 0  THEN
      LET l_val_atr_med = NULL
   END IF

   IF l_val_atr_dup = 0 THEN
      LET l_val_atr_dup = NULL
   END IF

   LET mr_om_erro.cod_empresa       = mr_pedido.cod_empresa
   LET mr_om_erro.num_pedido        = mr_pedido.num_pedido
   LET mr_om_erro.sequencia         = 0
   LET mr_om_erro.cod_cliente       = mr_pedido.cod_cliente
   LET mr_om_erro.qtd_dias_atr_dupl = l_val_atr_dup
   LET mr_om_erro.qtd_dias_atr_med  = l_val_atr_med
   LET mr_om_erro.nom_usuario       = p_user

   INSERT INTO om_erro VALUES (mr_om_erro.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INCLUSAO","OM_ERRO")
   END IF
END FUNCTION

#------------------------------------------------------------#
 FUNCTION vdp4923_verifica_lista(l_val_atr_med, l_val_atr_dup)
#------------------------------------------------------------#
  DEFINE l_val_atr_med       LIKE cli_credito.qtd_dias_atr_med,
         l_val_atr_dup       LIKE cli_credito.qtd_dias_atr_dupl,
         lr_desc_preco_mest  RECORD LIKE desc_preco_mest.*

  IF   mr_pedido.num_list_preco > 0 AND
      (mr_pedido.num_list_preco IS NOT NULL OR
       mr_pedido.num_list_preco <> "    ") THEN
    SELECT desc_preco_mest.* INTO lr_desc_preco_mest.*
    FROM desc_preco_mest
    WHERE desc_preco_mest.cod_empresa    = mr_pedido.cod_empresa
          AND desc_preco_mest.num_list_preco = mr_pedido.num_list_preco
    IF SQLCA.sqlcode = 0 THEN
       IF   lr_desc_preco_mest.ies_bloq_fatur = "S"  THEN
          LET mr_om_erro.mensagem = "LISTA PRECO BLOQ. P/ FATURAMENTO"
          LET m_houve_erro = TRUE
       END IF
    ELSE
       LET mr_om_erro.mensagem = "LISTA DE PRECO NAO CADASTRADO"
       LET m_houve_erro = TRUE
    END IF

    LET mr_om_erro.cod_empresa       = mr_pedido.cod_empresa
    LET mr_om_erro.num_pedido        = mr_pedido.num_pedido
    LET mr_om_erro.sequencia         = 0
    LET mr_om_erro.cod_cliente       = mr_pedido.cod_cliente
    LET mr_om_erro.nom_usuario       = p_user

    INSERT INTO om_erro VALUES (mr_om_erro.*)

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("INCLUSAO","OM_ERRO")
    END IF

  END IF

END FUNCTION

#-----------------------------------#
 FUNCTION vdp4923_verifica_gravacao()
#-----------------------------------#
 DEFINE l_aux                SMALLINT,
        l_qtd_pecas_reserv   LIKE ordem_montag_item.qtd_reservada,
        l_qtd_reservada      LIKE ordem_montag_item.qtd_reservada,
        l_quantidade         LIKE ordem_montag_item.qtd_reservada,
        l_qtd_item           LIKE nf_item.qtd_item,
        l_valor              LIKE nf_item.qtd_item,
        l_cota_diaria        LIKE cli_guia_trafego.qtd_cota_diaria,
        l_data_validade      LIKE cli_guia_trafego.dat_validade,
        l_qtd_padr_embal     LIKE item_embalagem.qtd_padr_embal,
        l_item               LIKE item.cod_item

 LET l_qtd_pecas_reserv = 0
 LET l_qtd_reservada    = 0
 LET l_qtd_item         = 0
 LET l_valor            = 0
 LET l_cota_diaria      = 0

 DECLARE cm_itens_575 CURSOR FOR
    SELECT qtd_kg_separado, item
      FROM vdp_ped_item_575
     WHERE pedido  = m_num_pedido
       AND empresa = m_empresa

 FOREACH cm_itens_575 INTO l_quantidade, l_item

{
    A quantidade de KILOS j� � a Quantidade solicitada, por isso n�o � realizado
    o processo abaixo.

    SELECT qtd_padr_embal INTO l_qtd_padr_embal
     FROM item_embalagem
    WHERE item_embalagem.cod_empresa   = mr_om_pedido_itens.cod_empresa
      AND item_embalagem.cod_item      = l_item
      AND item_embalagem.ies_tip_embal = mr_om_pedido_itens.ies_embal_padrao

    LET l_quantidade = l_quantidade * l_qtd_padr_embal}

    LET l_qtd_pecas_reserv = l_qtd_pecas_reserv + l_quantidade

 END FOREACH

 SELECT dat_validade, qtd_cota_diaria INTO l_data_validade, l_cota_diaria
 FROM cli_guia_trafego
 WHERE cod_cliente  = mr_om_pedido_itens.cod_cliente

 IF sqlca.sqlcode = NOTFOUND THEN
    RETURN TRUE
 END IF

 SELECT SUM(b.qtd_reservada) INTO l_qtd_reservada
   FROM ordem_montag_mest a, ordem_montag_item b, pedidos c
  WHERE a.cod_empresa = mr_om_pedido_itens.cod_empresa
    AND a.ies_sit_om  <> "F"
    AND a.dat_emis    = TODAY
    AND b.cod_empresa = mr_om_pedido_itens.cod_empresa
    AND b.num_om      = a.num_om
    AND b.num_pedido  = mr_om_pedido_itens.num_pedido
    AND c.cod_empresa = mr_om_pedido_itens.cod_empresa
    AND c.num_pedido  = b.num_pedido
    AND c.cod_cliente = mr_om_pedido_itens.cod_cliente

 IF l_qtd_reservada IS NULL THEN
    LET l_qtd_reservada = 0
 END IF

 SELECT SUM(b.qtd_item) INTO l_qtd_item
 FROM nf_mestre a, nf_item b
 WHERE a.cod_empresa  = mr_om_pedido_itens.cod_empresa
       AND a.dat_emissao  = TODAY
       AND a.ies_situacao = "N"
       AND a.cod_cliente  = mr_om_pedido_itens.cod_cliente
       AND b.cod_empresa  = mr_om_pedido_itens.cod_empresa
       AND b.num_nff      = a.num_nff

 IF l_qtd_item IS NULL THEN
    LET l_qtd_item = 0
 END IF

 LET l_valor = l_qtd_pecas_reserv + l_qtd_reservada + l_qtd_item

 IF l_cota_diaria IS NULL THEN
    LET l_cota_diaria = 0
 END IF

 IF l_valor > l_cota_diaria THEN
    INITIALIZE mr_om_erro.* TO NULL
    LET mr_om_erro.mensagem = "ESTOUROU A COTA DIARIA ", l_valor
    CALL vdp4923_grava_om_erro2()
    ERROR "NAO GERAOU OM - ESTOUROU A COTA DIARIA DO CLIENTE   "
    SLEEP 2
    RETURN FALSE
 END IF

 IF l_data_validade < TODAY THEN
    INITIALIZE mr_om_erro.* TO NULL
    LET mr_om_erro.mensagem = "DATA GERACAO OM > DATA VALIDADE CLIENTE"
    CALL vdp4923_grava_om_erro2()
    ERROR "NAO GEROU O.M - DATA EXPIRADA PARA FATURAMENTO DO CLIENTE "
    SLEEP 2
    RETURN FALSE
 END IF
 RETURN TRUE
END FUNCTION

#--------------------------------#
 FUNCTION vdp4923_grava_om_erro2()
#--------------------------------#
 LET mr_om_erro.cod_empresa       = mr_om_pedido_itens.cod_empresa
 LET mr_om_erro.num_pedido        = mr_om_pedido_itens.num_pedido
 LET mr_om_erro.sequencia         = 0
 LET mr_om_erro.cod_cliente       = mr_om_pedido_itens.cod_cliente
 LET mr_om_erro.cod_item          = NULL
 LET mr_om_erro.qtd_dias_atr_dupl = NULL
 LET mr_om_erro.qtd_dias_atr_med  = NULL
 LET mr_om_erro.nom_usuario       = p_user

 INSERT INTO om_erro VALUES (mr_om_erro.*)
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("INCLUSAO","OM_ERRO")
    RETURN
 END IF
END FUNCTION