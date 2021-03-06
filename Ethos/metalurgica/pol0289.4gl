#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL0289                                                 #
# MODULOS.: POL0289 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: RELATORIO DE PEDIDO DE VENDAS                           #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 07/12/2004                                              #
# OBSERV. : FOI AUMENTADO O CAMPO PEDIDO DO CLIENTE                 #
#-------------------------------------------------------------------#
DATABASE logix
GLOBALS
   DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
          p_den_empresa   LIKE empresa.den_empresa,
          p_user          LIKE usuario.nom_usuario,
          p_status        SMALLINT,
          p_comprime      CHAR(01),
          p_descomprime   CHAR(01),
          p_cod_item_ini  CHAR(15),
          p_cod_item_fim  CHAR(15),
          comando         CHAR(80),
          p_nom_arquivo   CHAR(100),
          p_nom_tela      CHAR(200),
          p_count         SMALLINT,
          p_nom_help      CHAR(200),
          p_ies_lista     SMALLINT,
          p_ies_impressao CHAR(01),
          p_versao        CHAR(18),
          p_ies_cons      SMALLINT,
          g_ies_ambiente  CHAR(01),
          p_caminho       CHAR(080),
          p_msg           CHAR(100),
          p_ship_date     DATE

   DEFINE p_ped_itens_texto RECORD LIKE ped_itens_texto.* 


   DEFINE p_tela RECORD
      cod_cliente         LIKE pedidos.cod_cliente,          
      nom_cliente         LIKE clientes.nom_cliente,
      cod_cli1            LIKE pedidos.cod_cliente,          
      nom_cli1            LIKE clientes.nom_cliente,
      cod_cli2            LIKE pedidos.cod_cliente,          
      nom_cli2            LIKE clientes.nom_cliente,
      cod_cli3            LIKE pedidos.cod_cliente,          
      nom_cli3            LIKE clientes.nom_cliente,
      dat_ini             LIKE pedidos.dat_pedido,
      dat_fim             LIKE pedidos.dat_pedido,
      cod_item            CHAR(15),
      ies_txt             CHAR(01),
      tipo_item           CHAR(01),
      ordenar_por         CHAR(01)
   END RECORD 

   DEFINE p_relat RECORD 
      cod_cliente         LIKE pedidos.cod_cliente,          
      cod_cli1            LIKE pedidos.cod_cliente,          
      cod_cli2            LIKE pedidos.cod_cliente,          
      cod_cli3            LIKE pedidos.cod_cliente,          
      num_pedido          LIKE pedidos.num_pedido,
      nom_cliente         LIKE clientes.nom_cliente,
      nom_cli1            LIKE clientes.nom_cliente,
      nom_cli2            LIKE clientes.nom_cliente,
      nom_cli3            LIKE clientes.nom_cliente,
      num_pedido_cli      LIKE pedidos.num_pedido_cli,
      cod_item_cliente    LIKE cliente_item.cod_item_cliente,
      den_texto_1         LIKE ped_itens_texto.den_texto_1,
      den_texto_2         LIKE ped_itens_texto.den_texto_1,
      den_texto_3         LIKE ped_itens_texto.den_texto_1,
      den_texto_4         LIKE ped_itens_texto.den_texto_1,
      den_texto_5         LIKE ped_itens_texto.den_texto_1,
      num_sequencia       LIKE ped_itens.num_sequencia,          
      cod_item            LIKE ped_itens.cod_item,
      den_item_reduz      LIKE item.den_item_reduz,
      prz_entrega         LIKE ped_itens.prz_entrega,
      qtd_item            LIKE ped_itens.qtd_pecas_solic,
      pre_unit            LIKE ped_itens.pre_unit,
      pre_total           LIKE ped_itens.val_frete_unit,
      num_ordem           CHAR(31)   
   END RECORD 
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT 
   LET p_versao = "POL0289-10.02.16"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0289.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   
   #LET p_cod_empresa = '21'
   #LET p_status = 0
   #LET p_user = 'admlog'
   
   IF p_status = 0  THEN
      CALL pol0289_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0289_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0289") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0289 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Informa Parametros para Impressao"
         HELP 001 
         LET p_ies_cons = FALSE
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","POL0289","IN")  THEN
            IF pol0289_entrada_dados() THEN
               NEXT OPTION "Listar"
            ELSE
               ERROR "Funcao Cancelada"
               NEXT OPTION "Fim"
            END IF 
         END IF 
      COMMAND "Listar" "Lista Relatorio de Pedidos"
         HELP 002
         LET p_count = 0    
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","POL0289","MO") THEN
            IF p_ies_cons THEN 
               IF log0280_saida_relat(13,29) IS NOT NULL THEN
                  MESSAGE " Processando a Extracao do Relatorio..." 
                     ATTRIBUTE(REVERSE)
                  IF p_ies_impressao = "S" THEN
                     IF g_ies_ambiente = "U" THEN
                        START REPORT pol0289_relat TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol0289.tmp'
                        START REPORT pol0289_relat TO p_caminho
                     END IF
                  ELSE
                     START REPORT pol0289_relat TO p_nom_arquivo
                  END IF
                  CALL pol0289_emite_relatorio()   
                  IF p_count = 0 THEN
                     ERROR "Nao Existem Dados para serem Listados" 
                  ELSE
                     ERROR "Relatorio Processado com Sucesso" 
                  END IF
                  FINISH REPORT pol0289_relat   
               ELSE
                  CONTINUE MENU
               END IF                                                     
               IF p_ies_impressao = "S" THEN
                  MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                     ATTRIBUTE(REVERSE)
                  IF g_ies_ambiente = "W" THEN
                     LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                   p_nom_arquivo
                     RUN comando
                  END IF
               ELSE
                  MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                  " " ATTRIBUTE(REVERSE)
               END IF                              
               NEXT OPTION "Fim"
            ELSE
               ERROR "Informar Previamente Parametros para Impressao"
               NEXT OPTION "Informar"
            END IF 
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol0289_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 000
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0289

END FUNCTION

#-------------------------------#
 FUNCTION pol0289_entrada_dados()
#-------------------------------#

   INITIALIZE p_tela.* TO NULL
   LET p_tela.tipo_item = 'T'
   LET p_tela.ordenar_por = 'P'
   DISPLAY p_cod_empresa TO cod_empresa

   INPUT BY NAME p_tela.* 
      WITHOUT DEFAULTS

      AFTER FIELD cod_cliente   
      IF p_tela.cod_cliente IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD cod_cliente
      ELSE
         SELECT nom_cliente
            INTO p_tela.nom_cliente
         FROM clientes        
         WHERE cod_cliente = p_tela.cod_cliente
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cliente nao Cadastrado"
            NEXT FIELD cod_cliente
         END IF
         DISPLAY BY NAME p_tela.nom_cliente
         LET p_relat.nom_cliente = p_tela.nom_cliente
      END IF

      AFTER FIELD cod_cli1   
      IF p_tela.cod_cli1 IS NOT NULL THEN
         SELECT nom_cliente
            INTO p_tela.nom_cli1
         FROM clientes        
         WHERE cod_cliente = p_tela.cod_cli1
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cliente nao Cadastrado"
            NEXT FIELD cod_cli1
         END IF
         DISPLAY BY NAME p_tela.nom_cli1
         LET p_relat.nom_cli1 = p_tela.nom_cli1
      END IF

      AFTER FIELD cod_cli2   
      IF p_tela.cod_cli2 IS NOT NULL THEN
         SELECT nom_cliente
            INTO p_tela.nom_cli2
         FROM clientes        
         WHERE cod_cliente = p_tela.cod_cli2
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cliente nao Cadastrado"
            NEXT FIELD cod_cli2
         END IF
         DISPLAY BY NAME p_tela.nom_cli2
         LET p_relat.nom_cli2 = p_tela.nom_cli2
      END IF

      AFTER FIELD cod_cli3   
      IF p_tela.cod_cli3 IS NOT NULL THEN
         SELECT nom_cliente
            INTO p_tela.nom_cli3
         FROM clientes        
         WHERE cod_cliente = p_tela.cod_cli3
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cliente nao Cadastrado"
            NEXT FIELD cod_cli3
         END IF
         DISPLAY BY NAME p_tela.nom_cli3
         LET p_relat.nom_cli2 = p_tela.nom_cli3
      END IF


      AFTER FIELD dat_ini    
      IF p_tela.dat_ini IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD dat_ini       
      END IF 

      AFTER FIELD dat_fim   
      IF p_tela.dat_fim IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD dat_fim
      ELSE
         IF p_tela.dat_ini > p_tela.dat_fim THEN
            ERROR "Data Inicial nao pode ser maior que data Final"
            NEXT FIELD dat_ini
         END IF 
         IF p_tela.dat_fim - p_tela.dat_ini > 720 THEN 
            ERROR "Periodo nao pode ser maior que 720 Dias"
            NEXT FIELD dat_ini
         END IF 
      END IF 

      AFTER FIELD cod_item   
         IF p_tela.cod_item IS NULL THEN
            LET p_cod_item_ini = '000000000000000'
            LET p_cod_item_fim = 'ZZZZZZZZZZZZZZZ'
         ELSE
            SELECT cod_item
              INTO p_cod_item_ini
              FROM item     
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = p_tela.cod_item 
            IF SQLCA.sqlcode <> 0 THEN 
               ERROR 'ITEM NAO CADASTRADO ', SQLCA.sqlcode
               NEXT FIELD cod_item
            ELSE
               LET p_cod_item_fim = p_cod_item_ini
            END IF                
         END IF             

      AFTER FIELD ies_txt   
         IF p_tela.ies_txt <> 'S'  AND
            p_tela.ies_txt <> 'N'  THEN
            ERROR 'INFORMR (S) OU (N)'
            NEXT FIELD ies_txt
         END IF 

      BEFORE FIELD tipo_item
        IF p_tela.tipo_item IS NULL THEN
           LET p_tela.tipo_item = 'T'
        END IF 

      ON KEY (control-z)
         CALL pol0289_popup()
         
   END INPUT

   IF INT_FLAG = 0 THEN
      LET p_ies_cons = TRUE
      RETURN TRUE 
   ELSE
      LET p_ies_cons = FALSE
      RETURN FALSE 
   END IF

END FUNCTION 

#-----------------------#
FUNCTION pol0289_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0289
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_cliente = p_codigo
            DISPLAY p_codigo TO cod_cliente
         END IF

      WHEN INFIELD(cod_cli1)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0289
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_cli1 = p_codigo
            DISPLAY p_codigo TO cod_cli1
         END IF

      WHEN INFIELD(cod_cli2)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0289
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_cli2 = p_codigo
            DISPLAY p_codigo TO cod_cli2
         END IF

      WHEN INFIELD(cod_cli3)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0289
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_cli3 = p_codigo
            DISPLAY p_codigo TO cod_cli3
         END IF

   END CASE
   

END FUNCTION

#---------------------------------#
 FUNCTION pol0289_emite_relatorio()
#---------------------------------#
   
   DEFINE p_num_ordem CHAR(10),
          p_ies_kanabn CHAR(01),
          p_cod_item   CHAR(15),
          p_query      CHAR(3000)
   
   DROP TABLE cliente_tmp
   
   CREATE TEMP TABLE cliente_tmp(
     cod_cliente     CHAR(15)
   );
      
	 IF STATUS <> 0 THEN 
	    DELETE FROM cliente_tmp
	    SELECT COUNT(*) INTO p_count FROM cliente_tmp
	    IF p_count > 0 THEN
	       LET p_msg = 'Na� foi possivel limpar\n a tabela tempor�ria cliente_tmp'
			   CALL log0030_mensagem(p_msg,'info')
			   LET p_count = 0
			   RETURN 
			END IF
	 END IF

   INSERT INTO cliente_tmp VALUES(p_tela.cod_cliente)
   INSERT INTO cliente_tmp VALUES(p_tela.cod_cli1)
   INSERT INTO cliente_tmp VALUES(p_tela.cod_cli2)
   INSERT INTO cliente_tmp VALUES(p_tela.cod_cli3)
      
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_count = 0

   SELECT den_empresa   
      INTO p_den_empresa
   FROM empresa 
   WHERE cod_empresa = p_cod_empresa
   
   LET p_query = 

"SELECT a.cod_cliente, a.num_pedido, a.num_pedido_cli, b.num_sequencia, b.cod_item, b.prz_entrega, ",
   "(b.qtd_pecas_solic - b.qtd_pecas_atend - b.qtd_pecas_cancel - b.qtd_pecas_reserv), b.pre_unit,",
   "((b.qtd_pecas_solic - b.qtd_pecas_atend - b.qtd_pecas_cancel - b.qtd_pecas_reserv) * b.pre_unit)",
   " FROM pedidos a, ped_itens b ",
   " WHERE a.cod_empresa = b.cod_empresa ",
   "   AND a.num_pedido = b.num_pedido ",
   "   AND a.cod_empresa = '",p_cod_empresa,"' ",
   "   AND a.ies_sit_pedido <> '9' ",
   "   AND a.cod_cliente IN (SELECT cod_cliente FROM cliente_tmp) ",
   "   AND (b.qtd_pecas_solic - b.qtd_pecas_atend - b.qtd_pecas_cancel - b.qtd_pecas_reserv) > 0 ",
   "   AND b.prz_entrega >= '",p_tela.dat_ini,"' ",
   "   AND b.prz_entrega <= '",p_tela.dat_fim,"' ",
   "   AND b.cod_item >= '",p_cod_item_ini,"' ",
   "   AND b.cod_item <= '",p_cod_item_fim,"' "
   

   IF p_tela.ordenar_por = 'P' THEN
      LET p_query = p_query CLIPPED, " ORDER BY a.num_pedido "
   END IF

   IF p_tela.ordenar_por = 'I' THEN
      LET p_query = p_query CLIPPED, " ORDER BY b.cod_item "
   END IF

   IF p_tela.ordenar_por = 'D' THEN
      LET p_query = p_query CLIPPED, " ORDER BY b.prz_entrega "
   END IF
   
   PREPARE var_query FROM p_query
   
   IF STATUS <> 0 THEN
      LET p_query = STATUS
      LET p_msg = 'Erro ', p_query CLIPPED, ' preparando a\n',
                  'query do relat�rio.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN
   END IF
      
   DECLARE cq_pedidos CURSOR FOR var_query
      
   FOREACH cq_pedidos INTO p_relat.cod_cliente,
                           p_relat.num_pedido,
                           p_relat.num_pedido_cli,
                           p_relat.num_sequencia,
                           p_relat.cod_item,
                           p_relat.prz_entrega,
                           p_relat.qtd_item,
                           p_relat.pre_unit,
                           p_relat.pre_total

      INITIALIZE p_relat.den_texto_1,
                 p_relat.den_texto_2,
                 p_relat.den_texto_3,
                 p_relat.den_texto_4,
                 p_relat.den_texto_5  TO NULL


      IF p_tela.tipo_item = 'T' THEN
      ELSE
         SELECT cod_item
           FROM item_kanban_547
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_relat.cod_item
      
         IF STATUS = 100 THEN
            LET p_ies_kanabn = 'N'
         ELSE
            IF STATUS = 0 THEN
               LET p_ies_kanabn = 'S'
            ELSE
               CALL log003_err_sql('lendo','item_kanban_547')
            END IF
         END IF
         
         IF p_tela.tipo_item = 'K' THEN
            IF p_ies_kanabn = 'N' THEN
               CONTINUE FOREACH
            END IF
         ELSE
            IF p_ies_kanabn = 'S' THEN
               CONTINUE FOREACH
            END IF
         END IF
      END IF
      
      SELECT den_texto_1[1,10]
         INTO p_relat.den_texto_1
      FROM ped_itens_texto
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido = p_relat.num_pedido
        AND num_sequencia = 0
      IF SQLCA.SQLCODE <> 0 THEN
         LET p_relat.den_texto_1 = NULL
      END IF

      IF p_tela.ies_txt = 'S'  THEN
         SELECT *
            INTO p_ped_itens_texto.*
         FROM ped_itens_texto
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido = p_relat.num_pedido
           AND num_sequencia = p_relat.num_sequencia
         IF SQLCA.SQLCODE <> 0 THEN
            LET p_relat.den_texto_2 = NULL
            LET p_relat.den_texto_3 = NULL
            LET p_relat.den_texto_4 = NULL
            LET p_relat.den_texto_5 = NULL
         ELSE
            LET p_relat.den_texto_2 = p_ped_itens_texto.den_texto_2
            LET p_relat.den_texto_3 = p_ped_itens_texto.den_texto_3
            LET p_relat.den_texto_4 = p_ped_itens_texto.den_texto_4
            LET p_relat.den_texto_5 = p_ped_itens_texto.den_texto_5
         END IF
      END IF 
      
      IF p_relat.cod_cliente <> "1" AND
         p_relat.cod_cliente <> "849" AND 
         p_relat.cod_cliente <> "1106" AND 
         p_relat.cod_cliente <> "1463" AND 
         p_relat.cod_cliente <> "061064911001734" THEN 
         SELECT den_texto_1
            INTO p_relat.num_pedido_cli
         FROM ped_itens_texto
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido = p_relat.num_pedido
           AND num_sequencia = p_relat.num_sequencia
         IF SQLCA.SQLCODE <> 0 THEN
            LET p_relat.num_pedido_cli = NULL
         END IF
      END IF

      SELECT cod_item_cliente
         INTO p_relat.cod_item_cliente
      FROM cliente_item
      WHERE cod_empresa = p_cod_empresa
        AND cod_cliente_matriz = p_relat.cod_cliente
        AND cod_item = p_relat.cod_item
      IF SQLCA.SQLCODE <> 0 THEN
         LET p_relat.cod_item_cliente = NULL
      END IF

      SELECT den_item_reduz
         INTO p_relat.den_item_reduz
      FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = p_relat.cod_item 
      IF SQLCA.SQLCODE <> 0 THEN
         LET p_relat.den_item_reduz = NULL
      END IF
      
      LET p_relat.num_ordem = ''
      
      DECLARE cq_ordens CURSOR FOR
       SELECT num_ordem 
         FROM ord_ped_item_547 
        WHERE cod_empresa = p_cod_empresa 
          AND num_pedido    = p_relat.num_pedido 
          AND num_sequencia = p_relat.num_sequencia

      FOREACH cq_ordens INTO p_num_ordem
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_ordens')
            CONTINUE FOREACH
         END IF

         SELECT cod_item 
           INTO p_cod_item
           FROM ordens
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem = p_num_ordem
            AND ies_situa IN ('3','4')
            
         IF STATUS = 100 THEN
            CONTINUE FOREACH
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','ordens')
               CONTINUE FOREACH
            END IF
         END IF

         SELECT ies_tip_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_cod_item
            AND ies_tip_item = 'F'

         IF STATUS = 100 THEN
            CONTINUE FOREACH
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','cq_ordens')
               CONTINUE FOREACH
            END IF
         END IF
            
           
         IF p_relat.num_ordem = '' THEN
            LET p_relat.num_ordem = p_num_ordem
         ELSE
            LET p_relat.num_ordem = p_relat.num_ordem CLIPPED, ' / ', p_num_ordem
         END IF
         
      END FOREACH

      SELECT ship_date
        INTO p_ship_date
        FROM ped_itens_ethos
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = p_relat.num_pedido
         AND num_sequencia = p_relat.num_sequencia
      
      IF STATUS <> 0 THEN
         LET p_ship_date = NULL
      END IF
      
      OUTPUT TO REPORT pol0289_relat() 
      LET p_count = p_count + 1

   END FOREACH

END FUNCTION

#----------------------#
 REPORT pol0289_relat()                              
#----------------------# 

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3

   ORDER EXTERNAL BY p_relat.prz_entrega, p_relat.cod_item 
 
   FORMAT

      FIRST PAGE HEADER  
      
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 053, "RELATORIO PEDIDO DE VENDAS - FIRMES ",
               COLUMN 119, "PAG.:  ", PAGENO USING "######&"
         PRINT COLUMN 001, "POL0289",
               COLUMN 049, "PERIODO : ", p_tela.dat_ini," ATE ",p_tela.dat_fim,
               COLUMN 119, "DATA: ", TODAY USING "DD/MM/YY"
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
         
         PRINT COLUMN 001, "Cliente    : ", p_relat.cod_cliente, " ",
                           p_relat.nom_cliente
         PRINT COLUMN 001, "Cliente    : ", p_relat.cod_cli1, " ",
                           p_relat.nom_cli1
         PRINT COLUMN 001, "Cliente    : ", p_relat.cod_cli2, " ",
                           p_relat.nom_cli2
         PRINT COLUMN 001, "Cliente    : ", p_relat.cod_cli3, " ",
                           p_relat.nom_cli3

         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

         PRINT COLUMN 001, " PEDIDO CLIENTE  PEDIDO SEQ     ITEM            DESCRICAO       ENTREGA   COD PRODUTO      IND AMOS    QTDE   PRE UNIT  PRE TOTAL        ORDENS DE PRODUCAO        SHIP DATE "
         PRINT COLUMN 001, "---------------- ------ --- --------------- ------------------ ---------- ---------------- ---------- ------- --------- --------- ------------------------------- ----------"
         

      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 053, "RELATORIO PEDIDO DE VENDAS",
               COLUMN 119, "PAG.:  ", PAGENO USING "######&"
         PRINT COLUMN 001, "POL0289",
               COLUMN 049, "PERIODO : ", p_tela.dat_ini," ATE ",p_tela.dat_fim,
               COLUMN 119, "DATA: ", TODAY USING "DD/MM/YY"
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
         
         PRINT COLUMN 001, "Cliente    : ", p_relat.cod_cliente, " ",
                           p_relat.nom_cliente
         PRINT COLUMN 001, "Cliente    : ", p_relat.cod_cli1, " ",
                           p_relat.nom_cli1
         PRINT COLUMN 001, "Cliente    : ", p_relat.cod_cli2, " ",
                           p_relat.nom_cli2
         PRINT COLUMN 001, "Cliente    : ", p_relat.cod_cli3, " ",
                           p_relat.nom_cli3

         PRINT COLUMN 001, "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

         PRINT COLUMN 001, " PEDIDO CLIENTE  PEDIDO SEQ     ITEM            DESCRICAO       ENTREGA   COD PRODUTO      IND AMOS    QTDE   PRE UNIT  PRE TOTAL        ORDENS DE PRODUCAO        SHIP DATE "
         PRINT COLUMN 001, "---------------- ------ --- --------------- ------------------ ---------- ---------------- ---------- ------- --------- --------- ------------------------------- ----------"

 
      ON EVERY ROW

         PRINT COLUMN 001, p_relat.num_pedido_cli[1,16], 
               COLUMN 018, p_relat.num_pedido USING "&&&&&&", 
               COLUMN 025, p_relat.num_sequencia USING "##&", 
               COLUMN 029, p_relat.cod_item, 
               COLUMN 045, p_relat.den_item_reduz, 
               COLUMN 064, p_relat.prz_entrega, 
               COLUMN 075, p_relat.cod_item_cliente[1,16], 
               COLUMN 092, p_relat.den_texto_1[1,10], 
               COLUMN 103, p_relat.qtd_item USING "###.##&", 
               COLUMN 111, p_relat.pre_unit USING "##,##&.&&", 
               COLUMN 121, p_relat.pre_total USING "##,##&.&&",
               COLUMN 131, p_relat.num_ordem,
               COLUMN 164, p_ship_date
               
#         PRINT
         IF p_relat.den_texto_2 IS NOT NULL THEN 
            IF p_relat.den_texto_5 IS NOT NULL THEN 
               PRINT COLUMN 001, p_relat.den_texto_2 CLIPPED,"    ",p_relat.den_texto_5  
            ELSE
               PRINT COLUMN 001, p_relat.den_texto_2 
            END IF 
         ELSE
            IF p_relat.den_texto_5 IS NOT NULL THEN 
               PRINT COLUMN 001, p_relat.den_texto_5  
            END IF 
         END IF 

         IF p_relat.den_texto_3 IS NOT NULL THEN 
            PRINT COLUMN 001, p_relat.den_texto_3," ",p_relat.den_texto_4
         ELSE
            IF p_relat.den_texto_4 IS NOT NULL THEN 
               PRINT COLUMN 001, p_relat.den_texto_4 
            END IF       
         END IF       

         PRINT COLUMN 001, "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

END REPORT

#-----------------------#
 FUNCTION pol0289_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------ FIM DE PROGRAMA BI-------------------------------#
