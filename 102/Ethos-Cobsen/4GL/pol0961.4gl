#-------------------------------------------------------------------#
# SISTEMA.: ENVIO DE PROGRAMAÇÃO E RECEBIMENTO DE MATERIAIS VIA EDI #
# PROGRAMA: POL0935                                                 #
# OBJETIVO: ENVIO DE PROGRAMAÇÃO PARA DEMANDA MRP                   #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa         LIKE empresa.cod_empresa,
          p_den_empresa         LIKE empresa.den_empresa,  
          p_user                LIKE usuario.nom_usuario,
          p_status              SMALLINT,
          p_houve_erro          SMALLINT,
          comando               CHAR(80),
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
          p_msg                 CHAR(500)

END GLOBALS
   
   DEFINE m_prz_entrega       DATE,
          m_count             SMALLINT,
          m_tip_relat         CHAR(1),
          m_houve_alter       SMALLINT  

   DEFINE mr_tela  RECORD 
      prz_entrega_ini     DATE,
      prz_entrega_fim     DATE,
      ies_firme           CHAR(1),
      ies_requis          CHAR(1),
      ies_planej          CHAR(1),
      ies_car_po          CHAR(1),
      ies_car_pm          CHAR(1) 
   END RECORD 

   DEFINE p_ped_itens_qfp_pe512 RECORD LIKE ped_itens_qfp_pe512.*

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0961-12.00.00  "
   CALL func002_versao_prg(p_versao)
   
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0961.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL pol0961_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0961_controle()
#--------------------------#
   DEFINE l_informou_dados     SMALLINT,
          l_imprime            SMALLINT

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0961") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0961 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
 
   LET l_informou_dados   = FALSE
   LET l_imprime          = FALSE
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa Parâmetros para Gerar Demanda."
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0961_informa_dados() THEN
            LET l_informou_dados = TRUE
            NEXT OPTION "Processar"
         END IF
     
      COMMAND "Processar" "Efetua Processamento para Gerar Demanda."
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF l_informou_dados THEN
            MESSAGE "Processando..." ATTRIBUTE(REVERSE)
            CALL pol0961_processa()
            LET l_informou_dados = FALSE
            LET l_imprime        = TRUE
            LET m_houve_alter    = FALSE
            MESSAGE "Fim do Processamento." ATTRIBUTE(REVERSE)
            NEXT OPTION "Fim"
         ELSE
            ERROR "Informe os parâmetros primeiramente."
            NEXT OPTION "Informar"
         END IF  

{      COMMAND "Listar" "Imprime Relatório da Programação."
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF l_imprime THEN
            IF pol0961_listar() THEN
               CALL pol0961_imprime_relat()
            ELSE
               ERROR "Impressão de Relatório Cancelada." 
               NEXT OPTION "Fim"
            END IF
         ELSE
            ERROR "Informe os Parâmetros e Efetue o Processamento."
            NEXT OPTION "Informar"
         END IF   }
      
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0961_sobre()
      
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

   CLOSE WINDOW w_pol0961

END FUNCTION
 
#-------------------------------#
 FUNCTION pol0961_informa_dados()
#-------------------------------#
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0961
   INITIALIZE mr_tela.* TO NULL
   LET p_houve_erro = FALSE
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG =  FALSE
   INPUT BY NAME mr_tela.*  WITHOUT DEFAULTS  

      AFTER FIELD prz_entrega_ini
         IF mr_tela.prz_entrega_ini IS NULL OR
            mr_tela.prz_entrega_ini = ' ' THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD prz_entrega_ini 
         END IF

      AFTER FIELD prz_entrega_fim
         IF mr_tela.prz_entrega_fim IS NULL OR
            mr_tela.prz_entrega_fim = ' ' THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD prz_entrega_fim
         ELSE
            IF mr_tela.prz_entrega_fim < mr_tela.prz_entrega_ini THEN 
               ERROR 'Data final nao pode ser menor que inicial.'
               NEXT FIELD prz_entrega_ini
            END IF  
         END IF

      BEFORE FIELD ies_firme
          LET mr_tela.ies_firme  = 'S'
          LET mr_tela.ies_requis = 'S'
          LET mr_tela.ies_planej = 'S'
          LET mr_tela.ies_car_po = 'S'
          LET mr_tela.ies_car_pm = 'N'

      AFTER FIELD ies_car_pm
         IF mr_tela.ies_car_po = 'S' AND 
            mr_tela.ies_car_pm = 'S' THEN
            ERROR 'Informe apenas Operacional OU Mensal.'
            NEXT FIELD ies_car_po
         ELSE
           IF mr_tela.ies_car_po = 'N' AND 
               mr_tela.ies_car_pm = 'N' THEN
               ERROR 'Informe Operacional OU Mensal.'
               NEXT FIELD ies_car_po
            END IF 
         END IF
                
      AFTER INPUT
         IF INT_FLAG = 0 THEN
            IF mr_tela.prz_entrega_ini IS NULL OR
               mr_tela.prz_entrega_ini = ' ' THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD prz_entrega_ini 
            END IF
            IF mr_tela.prz_entrega_fim IS NULL OR
               mr_tela.prz_entrega_fim = ' ' THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD prz_entrega_fim 
            END IF
            IF mr_tela.prz_entrega_fim < mr_tela.prz_entrega_ini THEN 
               ERROR 'Data final nao pode ser menor que inicial.'
               NEXT FIELD prz_entrega_ini
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
   CURRENT WINDOW IS w_pol0961
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Envio de Programação Cancelada."
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION pol0961_processa()
#--------------------------#
   DEFINE sql_stmt                CHAR(2000),
          l_condicao              CHAR(350),
          l_cod_item              LIKE item.cod_item,
          l_pct_refugo            LIKE item_prog_ethos.pct_refugo,
          l_num_ped_cater         LIKE item_prog_ethos.num_ped_cater,
          l_envia_arquivo         LIKE item_prog_ethos.envia_arquivo,
          l_saldo                 DECIMAL(18,7), 
          l_pedido                LIKE pedidos.num_pedido,
          l_cod_item_cat          CHAR(30),
          l_contato               CHAR(11),
          l_mes                   DECIMAL(2),
          l_ano                   DECIMAL(4)

   CALL pol0961_cria_temporaria()
   CALL pol0961_carrega_pedidos_planejados()
   IF mr_tela.ies_car_po = 'S' THEN       
      DECLARE cq_pedidos SCROLL CURSOR WITH HOLD FOR
       SELECT *
         FROM w_temp_ethos 
      
      FOREACH cq_pedidos INTO l_pedido, 
                              l_cod_item, 
                              l_saldo, 
                              m_prz_entrega
      
      
         INSERT INTO mrp_dem VALUES (p_cod_empresa,
                                     l_pedido,
                                     l_cod_item,
                                     m_prz_entrega,
                                     l_saldo) 
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("INCLUSAO","PED_DEM")
         END IF
      END FOREACH 
  ELSE
      CALL pol0961_limpa_pl_me()      
      DECLARE cq_ped_me SCROLL CURSOR WITH HOLD FOR
       SELECT cod_item,
              month(prz_entrega),
              year(prz_entrega),
              sum(saldo)
         FROM w_temp_ethos 
        GROUP BY 1,2,3 
 
      FOREACH cq_ped_me INTO l_cod_item,
                             l_mes,
                             l_ano, 
                             l_saldo

            INSERT INTO pl_it_me VALUES (p_cod_empresa,
                                         l_cod_item,
                                         l_mes,
                                         l_ano,
                                         l_saldo) 
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("INCLUSAO","PL_IT_ME")
            END IF
      END FOREACH       
  END IF   
 
END FUNCTION

#--------------------------------------------#
 FUNCTION pol0961_carrega_pedidos_planejados()
#--------------------------------------------#
   DEFINE sql_stmt1               CHAR(2000),
          l_condicao              CHAR(350),
          l_cod_item              LIKE item.cod_item,
          l_num_sequencia         LIKE ped_itens.num_sequencia,
          l_saldo                 DECIMAL(18,7),
          l_pedido                LIKE pedidos.num_pedido,
          l_prz_entrega           LIKE ped_itens.prz_entrega,
          l_ok                    CHAR(01)

   LET sql_stmt1 = 
      " SELECT pedidos.num_pedido, ",
      "        ped_itens_qfp_512.cod_item, ",
      "        ped_itens_qfp_512.num_sequencia, ",
      "        ped_itens_qfp_512.qtd_solic, ",
      "        ped_itens_qfp_512.prz_entrega ",
      "   FROM pedidos, ped_itens_qfp_512 ",
      "  WHERE pedidos.cod_empresa    = '",p_cod_empresa,"'",
      "    AND pedidos.cod_empresa    = ped_itens_qfp_512.cod_empresa ",
      "    AND pedidos.num_pedido     = ped_itens_qfp_512.num_pedido ",
      "    AND pedidos.ies_sit_pedido <> '9' ",
      "    AND ped_itens_qfp_512.prz_entrega >= '",mr_tela.prz_entrega_ini,"'",
      "    AND ped_itens_qfp_512.prz_entrega <= '",mr_tela.prz_entrega_fim,"'"
{      "    AND NOT EXISTS ",
              " (SELECT * ",
              "    FROM ped_itens ", 
              "   WHERE ped_itens.cod_empresa = ped_itens_qfp_512.cod_empresa ",
              "     AND ped_itens.num_pedido  = ped_itens_qfp_512.num_pedido ",
              "     AND ped_itens.cod_item    = ped_itens_qfp_512.cod_item ",
              "     AND ped_itens.prz_entrega = ped_itens_qfp_512.prz_entrega )"   
 }
   PREPARE var_query1 FROM sql_stmt1
   DECLARE cq_pedidos_2 SCROLL CURSOR WITH HOLD FOR var_query1

   FOREACH cq_pedidos_2 INTO l_pedido,
                             l_cod_item,
                             l_num_sequencia,
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
                                       l_saldo,
                                       l_prz_entrega)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INCLUSAO","W_TEMP_ETHOS")
   END IF


   END FOREACH              

END FUNCTION

#---------------------------------#
 FUNCTION pol0961_cria_temporaria()
#---------------------------------#

   WHENEVER ERROR CONTINUE
       DROP TABLE w_temp_ethos;
   WHENEVER ERROR STOP

   CREATE TABLE w_temp_ethos
      (
       pedido                   DECIMAL(6,0),
       cod_item                 CHAR(15),
       saldo                    DECIMAL(18,7),
       prz_entrega              DATE
      )                     

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","W_TEMP_ETHOS")
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0961_limpa_pl_me()
#------------------------------#
DEFINE l_mes                   DECIMAL(2),
       l_ano                   DECIMAL(4)

DECLARE cq_del_me SCROLL CURSOR WITH HOLD FOR
 SELECT DISTINCT month(prz_entrega),
                year(prz_entrega)
   FROM w_temp_ethos 
FOREACH cq_del_me INTO l_mes,l_ano

  DELETE FROM pl_it_me 
   WHERE cod_empresa = p_cod_empresa
     AND mes_ref     = l_mes
     AND ano_ref     = l_ano

END FOREACH    



END FUNCTION

#-----------------------#
 FUNCTION pol0961_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION