#-------------------------------------------------------------------#
# SISTEMA.: ENVIO DE PROGRAMAÇÃO E RECEBIMENTO DE MATERIAIS VIA EDI #
# PROGRAMA: pol1051                                                 #
# MODULOS.: pol1051 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: ENVIO DE PROGRAMAÇÃO DA KF PARA volksvagen              #
# AUTOR...: tOTVS-GSP - MANUEL PIER SOBRIDO                         #
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
          p_y_saldo    		      DECIMAL(15,3),
		      P_y_qtd_estoq_seg     DECIMAL(10,3),
		      p_pct_refugo          LIKE item_prog_kf_1099.pct_refugo,
		      p_num_ped_wv          LIKE item_prog_kf_1099.num_ped_wv,
		      p_cod_item_wv         LIKE item_prog_kf_1099.cod_item_wv,
		      p_contato             LIKE item_prog_kf_1099.contato,
          x_saldo               LIKE estoque_lote.qtd_saldo,
          x_cod_item            LIKE estoque_lote.cod_item,
          l_pedido              LIKE pedidos.num_pedido,
		      l_num_sequencia       LIKE ped_itens.num_sequencia,
		      l_cod_item            LIKE ped_itens.cod_item,		  
		      l_cod_cliente         LIKE pedidos.cod_cliente,
		      l_saldo               LIKE ped_itens.qtd_pecas_solic, 
		      l_prz_entrega         LIKE ped_itens.prz_entrega,
		      x_qtd_estoq_seg       LIKE item_man.qtd_estoq_seg,
		      y_saldo    		        LIKE estoque_lote.qtd_saldo,
          y_cod_item     	      LIKE estoque_lote.cod_item,
		      p_msg                 CHAR(300),
	     	  p_cabeca_imp			    SMALLINT

   #Ivo 02/08/2011
   DEFINE p_qtd_saldo           DECIMAL(10,3),
          p_qtd_descontar       DECIMAL(10,3)
   #---Até aqui---------#
		  
   DEFINE p_cod_item           LIKE item.cod_item,
          p_dat_entrega        DATE,
		      p_num_pedido         LIKE pedidos.num_pedido, 
		      p_num_sequencia      LIKE ped_itens.num_sequencia, 
		      p_cod_cliente        LIKE pedidos.cod_cliente,
          p_cod_compon         LIKE item.cod_item,
          p_cod_item_pai       LIKE item.cod_item,
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_den_item           LIKE item.den_item,
          p_den_item_pai       LIKE item.den_item,
          p_ies_tip_item       LIKE item.ies_tip_item,
          p_cod_unid_med       LIKE item.cod_unid_med,
          p_parametros         LIKE estrutura.parametros,
          p_cod_nivel          DECIMAL(2,0),
          p_qtd_necessaria     DECIMAL(14,7),
          p_qtd_acumulada      DECIMAL(14,7),
          p_qtd_acumu_aux      DECIMAL(14,7),
          p_explodiu           CHAR(01),
		      p_num_seq            SMALLINT,
		      p_num_processo       INTEGER

    DEFINE p_dat_niv            RECORD
          dat_refer            DATE,
          des_item             CHAR(01),
          cod_nivel            DECIMAL(2,0)
    END RECORD
		  

	DEFINE p_compon RECORD 
	      num_pedido     DECIMAL(6,0),
		  num_sequencia  DECIMAL(5,0),
		  cod_cliente    CHAR(15), 
          cod_nivel      CHAR(06),
          cod_item       CHAR(15),
		  prz_entrega    DATE,
          cod_compon     CHAR(15),
          qtd_necessaria DECIMAL(14,7),
          qtd_acumulada  DECIMAL(14,7),
          explodiu       CHAR(01),
		  seq_imp        INTEGER
	END RECORD	 

	DEFINE p_resumo RECORD 
	      num_pedido     DECIMAL(6,0),
		  cod_cliente    CHAR(15),
		  cod_item       CHAR(15),
		  qtd_saldo      DECIMAL(14,7),
		  prz_entrega    DATE
	END RECORD	
	
    DEFINE p_edi_volksvagen RECORD 
       cod_empresa              CHAR(2),
       pedido                   DECIMAL(6,0),
       cod_item                 CHAR(15),
       cod_cliente              CHAR(15),
       saldo                    DECIMAL(18,7),
       num_ped_wv               CHAR(12), 
       cod_item_wv              CHAR(30),
       contato                  CHAR(11),
       prz_entrega              DATE  
   END RECORD
END GLOBALS
   
   DEFINE m_count             SMALLINT,
          m_tip_relat         CHAR(1) 

   DEFINE mr_tela  RECORD 
      dat_inicio          DATE,
      dat_final           DATE
   END RECORD 

   DEFINE ma_tela  ARRAY[10] OF RECORD 
      cod_cliente             LIKE clientes.cod_cliente,
      nom_cliente             LIKE clientes.nom_cliente
   END RECORD 
   

   DEFINE ma_tela3 ARRAY[100] OF RECORD 
      cod_item                LIKE item.cod_item,
      den_item                LIKE item.den_item_reduz,
      prz_entrega             DATE,
      saldo                   DECIMAL(9,0) 
   END RECORD 


MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "pol1051-10.02.19"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1051.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL pol1051_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1051_controle()
#--------------------------#
   DEFINE l_informou_dados     SMALLINT,
          l_imprime            SMALLINT

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1051") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1051 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
 
   LET l_informou_dados   = FALSE
   LET l_imprime          = FALSE
   LET g_usa_visualizador = TRUE
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa Parâmetros para Gerar Programação."
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol1051","IN") THEN
            IF pol1051_informa_dados() THEN
               IF pol1051_mostra_clientes() THEN
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
            IF log005_seguranca(p_user,"VDP","pol1051","MO") THEN
               MESSAGE "Processando..." ATTRIBUTE(REVERSE)
               IF pol1051_processa()  THEN 
                  LET l_informou_dados = FALSE
                  LET l_imprime        = TRUE
                  MESSAGE "Fim do Processamento." ATTRIBUTE(REVERSE)
                  NEXT OPTION "Gerar EDI" 
				ELSE  
				  ERROR "Processamento Cancelado, verificar erro"
                  NEXT OPTION "Informar"
				END IF
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
            IF log005_seguranca(p_user,"VDP","pol1051","MO") THEN
               IF pol1051_gera_arquivo() THEN
                  NEXT OPTION "Listar"
			   ELSE   
				  ERROR "Processamento Cancelado, verificar erro"
                  NEXT OPTION "Gerar EDI"
			   END IF
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
            IF log005_seguranca(p_user,"VDP","pol1051","MO") THEN
               IF pol1051_listar() THEN
                  CALL pol1051_imprime_relat()
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
         CALL pol1051_sobre()
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

   CLOSE WINDOW w_pol1051

END FUNCTION
 
#-------------------------------#
 FUNCTION pol1051_informa_dados()
#-------------------------------#
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol1051
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
         END IF

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol1051
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Envio de Programação Cancelada."
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION pol1051_mostra_clientes() 
#----------------------------------#
   DEFINE l_ind              SMALLINT,
          x_cod_cliente      CHAR(15)  

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol1051

   LET INT_FLAG =  FALSE
   LET l_ind    = 0 
   INITIALIZE x_cod_cliente   TO NULL 
 
   DECLARE cq_cliedi SCROLL CURSOR WITH HOLD FOR
    SELECT cod_cliente
      FROM cli_edi_1099 
   
   FOREACH cq_cliedi  INTO x_cod_cliente 
                          
     LET l_ind = l_ind + 1 
     IF  l_ind > 10 THEN
	     EXIT FOREACH 
     END IF  		 
    
    LET ma_tela[l_ind].cod_cliente = x_cod_cliente 
	
     SELECT nom_cliente 
           INTO ma_tela[l_ind].nom_cliente 
     FROM clientes
     WHERE cod_cliente = x_cod_cliente
  
     IF sqlca.sqlcode = 0 THEN
        DISPLAY ma_tela[l_ind].cod_cliente TO s_clientes[l_ind].cod_cliente
		DISPLAY ma_tela[l_ind].nom_cliente TO s_clientes[l_ind].nom_cliente 
     ELSE
        RETURN FALSE
     END IF

   END FOREACH 
     RETURN TRUE 
END FUNCTION

#--------------------------#
 FUNCTION pol1051_processa()
#--------------------------#

   INITIALIZE p_dat_niv TO NULL
   LET p_dat_niv.des_item = 'C'
   LET p_dat_niv.dat_refer = TODAY	  

   IF NOT pol1051_cria_temporaria() THEN 
      RETURN FALSE
   END IF 
   
   IF NOT pol1051_carrega_pedidos_carteira() THEN 
      RETURN FALSE
   END IF
 
   IF NOT pol1051_identifica_componentes() THEN 
      RETURN FALSE
   END IF 
 
   IF NOT pol1051_separa_componentes() THEN 
      RETURN FALSE
   END IF 
 
   RETURN TRUE  
       
END FUNCTION

#------------------------------------------# 
 FUNCTION pol1051_carrega_pedidos_carteira()
#------------------------------------------# 
   DEFINE sql_stmt                CHAR(2000),
          l_condicao              CHAR(350),
          l_pedido                LIKE pedidos.num_pedido,
		  l_num_sequencia         LIKE ped_itens.num_sequencia, 
		  l_saldo                 LIKE ped_itens.qtd_pecas_solic, 
		  l_cod_cliente           LIKE pedidos.cod_cliente,
		  l_prz_entrega           LIKE ped_itens.prz_entrega, 
		  l_cod_item              LIKE ped_itens.cod_item



   INITIALIZE    l_pedido, l_num_sequencia, l_cod_item,  l_cod_cliente, l_saldo,  l_prz_entrega  TO NULL
							 
   LET sql_stmt = " SELECT pedidos.num_pedido, ",
                  "        ped_itens.num_sequencia, ",
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
                  "    AND ped_itens.prz_entrega  <= '",mr_tela.dat_final,"' ",
				          "    AND pedidos.cod_cliente IN (SELECT cod_cliente FROM cli_edi_1099)"
				  
                              
   PREPARE var_query FROM sql_stmt
   DECLARE cq_pedidos_1 SCROLL CURSOR FOR var_query
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","CQ_PEDIDOS")
	  RETURN FALSE
   END IF

   FOREACH cq_pedidos_1 INTO l_pedido,
                             l_num_sequencia,  
                             l_cod_item,
                             l_cod_cliente,
                             l_saldo,
                             l_prz_entrega
       IF sqlca.sqlcode <> 0 THEN
          CALL log003_err_sql("FOREACH","CQ_PEDIDOS_1")
	      RETURN FALSE
       END IF
	   

#      LET 	l_prz_entrega = l_prz_entrega -  10
      			
	   
      INSERT INTO w_temp_kf VALUES    (l_pedido,
	                                   l_num_sequencia, 
                                       l_cod_item,
                                       l_cod_cliente,
                                       l_saldo,
                                       l_prz_entrega)
   
   END FOREACH  

   RETURN TRUE  

END FUNCTION

#------------------------------------#
FUNCTION pol1051_le_item(l_cod_item)
#------------------------------------#
   DEFINE   l_cod_item                  LIKE item.cod_item
	
   SELECT ies_tip_item,
          den_item,
          den_item_reduz,
          cod_unid_med
     INTO p_ies_tip_item,
          p_den_item,
          p_den_item_reduz,
          p_cod_unid_med
     FROM item 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = l_cod_item 
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1051_insere_item()
#-----------------------------#

   INSERT INTO estrut_item_1099
    VALUES(p_num_pedido,
	       p_num_sequencia,
	       p_cod_cliente,
	       p_cod_nivel,
           p_cod_item,
		   p_dat_entrega,
		   p_cod_compon,
           p_qtd_necessaria,
           p_qtd_acumulada,
           p_explodiu,
		   p_num_seq)
		   
		   

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','estrut_item_1099')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION
#--------------------------------#
FUNCTION pol1051_explode_estrut()
#--------------------------------#
		  
   LET p_num_seq = 0

   WHILE TRUE
    
      SELECT COUNT(cod_compon)
        INTO p_count
        FROM estrut_item_1099
       WHERE explodiu = 'N'
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estrut_item_1099')
         RETURN FALSE
      END IF
    
      IF p_count = 0 THEN
         EXIT WHILE
      END IF

      LET p_cod_nivel = p_cod_nivel + 1
    
   
      DECLARE cq_exp CURSOR FOR
       SELECT cod_compon,
              qtd_acumulada
         FROM estrut_item_1099
        WHERE explodiu = 'N'
      
    
        FOREACH cq_exp INTO p_cod_item, p_qtd_acumu_aux
    
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_exp')
            RETURN FALSE
         END IF
       
         UPDATE estrut_item_1099
            SET explodiu = 'S'
         WHERE cod_compon = p_cod_item

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Atualizando','estrut_item_1099')
            RETURN FALSE
         END IF
        
          DECLARE cq_est CURSOR FOR
            SELECT cod_item_compon,
                 qtd_necessaria,
                 parametros
            FROM estrutura
             WHERE cod_empresa  = p_cod_empresa
             AND cod_item_pai = p_cod_item       
             AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
                  (dat_validade_ini IS NULL AND dat_validade_fim >= p_dat_niv.dat_refer) OR
                  (dat_validade_fim IS NULL AND dat_validade_ini <= p_dat_niv.dat_refer )OR
                  (p_dat_niv.dat_refer BETWEEN dat_validade_ini AND dat_validade_fim)    OR
		    		      (dat_validade_fim >= p_dat_entrega))
             ORDER BY parametros
             
          FOREACH cq_est INTO p_cod_compon, p_qtd_necessaria, p_parametros

            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','estrutura')
               RETURN FALSE
            END IF
          
            LET p_num_seq = p_num_seq + 1
               
            LET p_qtd_acumulada  = p_qtd_acumu_aux * p_qtd_necessaria

            #Ivo 02/08/2011 - abater estoque
            #Ivo 10/04/2013 - Victor mandou tirar o abatimento do estoque
            {SELECT qtd_saldo
              INTO p_qtd_saldo
              FROM item_estoq_1099
             WHERE cod_compon = p_cod_compon
             
            IF STATUS <> 0 THEN
			         SELECT SUM(qtd_saldo) 
			           INTO p_qtd_saldo
			           FROM estoque_lote 
			          WHERE cod_empresa   = '01'
                  AND ies_situa_qtd = 'L'
                  AND cod_item      = p_cod_compon	

               IF STATUS <> 0 THEN
			            RETURN FALSE
			         END IF

		           IF p_qtd_saldo IS NULL  THEN 
                 LET p_qtd_saldo = 0 
               END IF
         
               INSERT INTO item_estoq_1099
                VALUES(p_cod_compon, p_qtd_saldo)
            END IF
                        
            IF p_qtd_acumulada > p_qtd_saldo THEN
               LET p_qtd_acumulada = p_qtd_acumulada - p_qtd_saldo
               LET p_qtd_saldo = 0
            ELSE
               LET p_qtd_saldo = p_qtd_saldo - p_qtd_acumulada
               LET p_qtd_acumulada = 0
            END IF
                        
            UPDATE item_estoq_1099
               SET qtd_saldo = p_qtd_saldo
             WHERE cod_compon = p_cod_compon}
            #----Até aqui----#
       
            IF NOT pol1051_le_item(p_cod_compon) THEN
               RETURN FALSE
            END IF
          
            IF p_ies_tip_item MATCHES '[C]' THEN
               LET p_explodiu = 'S'
            ELSE
               LET p_explodiu = 'N'
            END IF
		  
            IF NOT pol1051_insere_item() THEN
               RETURN FALSE
            END IF
         
          END FOREACH
   
        END FOREACH
	
    END WHILE
   
   RETURN TRUE
   
END FUNCTION
#-----------------------------------------#
 FUNCTION pol1051_identifica_componentes()
#-----------------------------------------#

   DEFINE p_nome_caminho CHAR(40)
   
   SELECT nom_caminho
     INTO p_nome_caminho
     FROM caminho_1099
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','caminho_1099')
      RETURN FALSE
   END IF
   
   CALL log150_procura_caminho ('LST') RETURNING p_nom_arquivo
   LET p_nom_arquivo = p_nome_caminho
   LET p_nom_arquivo = p_nome_caminho CLIPPED, p_user CLIPPED, '_pol1051.lst'
   START REPORT pol1051_detalha  TO p_nom_arquivo
	  
#   INITIALIZE x_item TO NULL 
   LET        x_saldo = 0 

   DECLARE cq_pedidos_2 SCROLL CURSOR WITH HOLD FOR
    SELECT *
      FROM w_temp_kf 
     WHERE saldo > 0
	ORDER BY cod_item, prz_entrega, pedido, num_sequencia
	     
   FOREACH cq_pedidos_2 INTO l_pedido,
                           l_num_sequencia,    
                           l_cod_item, 
                           l_cod_cliente, 
                           l_saldo, 
                           l_prz_entrega
	
  	   IF sqlca.sqlcode <> 0 THEN
    	   CALL log003_err_sql("FOREACH","CQ_PEDIDOS_2")
	 	     RETURN FALSE
       END IF	
						   
       #Ivo 10/04/2013 - Victor pediu para não descontar salafo
       {IF x_cod_item  = l_cod_item  THEN 
		      IF  x_saldo >= l_saldo  THEN 			
               #	@parte1-imprimir relatório informando que pedido tem saldo no estoque e que foi descartado.	
    		     OUTPUT TO REPORT pol1051_detalha(1) 
				       LET x_saldo = x_saldo - l_saldo
				      CONTINUE FOREACH
			    ELSE 

			       IF x_saldo > 0  THEN 
                LET l_saldo = l_saldo - x_saldo
				        LET x_saldo = 0 
#					      @parte1- imprimir relatório informando que pedido foi considerado e imprimir o campo l_saldo.	
					      OUTPUT TO REPORT pol1051_detalha(1) 
				     END IF 
			    END IF 
		   ELSE
		   LET x_qtd_estoq_seg = 0 }

         # Em 29/07/2011 o Rafael pediu para não considerar o Estoque de segurança no cálculo por esse motivo está comentado 
	       {SELECT qtd_estoq_seg 
 			     INTO x_qtd_estoq_seg
			     FROM item_man 
			    WHERE cod_empresa   ='01'
            AND cod_item      = 	l_cod_item	
         IF sqlca.sqlcode <> 0 THEN
   	        LET x_qtd_estoq_seg = 0  
			   END IF} 	

         #Ivo 10/04/2013 continua
  		   {LET x_cod_item  = l_cod_item 
			   LET x_saldo     = 0    
			   SELECT SUM(qtd_saldo) 
			     INTO x_saldo
			     FROM estoque_lote 
			    WHERE cod_empresa='01'
            AND ies_situa_qtd = 'L'
            AND cod_item      = 	l_cod_item	
          IF sqlca.sqlcode <> 0 THEN
    	       LET x_saldo = 0 
				     CONTINUE FOREACH 
			    ELSE 
			       LET x_saldo = x_saldo - x_qtd_estoq_seg
             IF  x_saldo >= l_saldo  THEN 		
    			       OUTPUT TO REPORT pol1051_detalha(1) 
                 #					@parte1-imprimir relatório informando que pedido tem saldo no estoque e que foi descartado.				
		             LET x_saldo = x_saldo - l_saldo
				         CONTINUE FOREACH
			       ELSE 
					      IF x_saldo IS NULL  THEN 
                   LET x_saldo = 0 
				        ELSE 
                   LET l_saldo = l_saldo - x_saldo
						       LET x_saldo = 0 
					      END IF
					      OUTPUT TO REPORT pol1051_detalha(1)  
                #	@parte1- imprimir relatório informando que pedido foi considerado  e imprimir o campo l_saldo.	
				     END IF 	
			    END IF 			      			   
		   END IF} 
		   #---até aqui - Ivo 10/04/2013------- 
	  
		   IF NOT pol1051_le_item(l_cod_item) THEN
           EXIT FOREACH
       END IF
      
       LET p_den_item_pai    = p_den_item
       LET p_cod_item        = l_cod_item
		   LET p_cod_compon      = l_cod_item
       LET p_qtd_necessaria  = 1
       LET p_qtd_acumulada   = l_saldo
       LET p_explodiu        = 'N'
		   LET p_dat_entrega     = l_prz_entrega
		   LET p_num_pedido      = l_pedido
		   LET p_num_sequencia   = l_num_sequencia
		   LET p_cod_cliente     = l_cod_cliente
		   LET p_num_seq         = 0 
		   LET p_cod_nivel       = 0 

       IF NOT pol1051_insere_item() THEN
           RETURN FALSE
       END IF
	  
	     IF NOT pol1051_explode_estrut() THEN
           RETURN FALSE
       END IF 
	  
	     #DELETE FROM estrut_item_1099
       #  WHERE seq_imp = 0
	  
	END FOREACH


  RETURN TRUE
   
END FUNCTION

#-------------------------------------#
 FUNCTION pol1051_separa_componentes()
#-------------------------------------#

 DEFINE y_cod_item 	    LIKE estoque_lote.cod_item,
		    y_qtd_estoq_seg LIKE item_man.qtd_estoq_seg

 INITIALIZE p_resumo.*, p_edi_volksvagen.*    TO NULL  

 LET y_saldo = 0 

 DECLARE cq_compon SCROLL CURSOR WITH HOLD FOR
 
    SELECT num_pedido,   
				   cod_cliente,
	         cod_compon, 
				   sum(qtd_acumulada),
				   prz_entrega
    FROM estrut_item_1099
	 WHERE cod_compon IN
	       (SELECT cod_item 
					  FROM item_prog_kf_1099
           WHERE  cod_empresa = p_cod_empresa)
	GROUP BY num_pedido, cod_cliente, cod_compon,  prz_entrega
	ORDER BY cod_compon, num_pedido
						   
	     
   FOREACH cq_compon  INTO p_resumo.*
	
  	  IF sqlca.sqlcode <> 0 THEN
    	   CALL log003_err_sql("FOREACH","CQ_COMPON")
	 	     RETURN FALSE
      END IF	
      
      IF p_resumo.qtd_saldo <= 0 THEN
         #Imprimir mensagem de que o componente foi descartado pois 
         #tinha saldo em estoque, imprimir qtde necessária e saldo 
         #em estoque restante
         OUTPUT TO REPORT pol1051_detalha(2) 
         CONTINUE FOREACH
      END IF
		
	    IF NOT pol1051_busca_dados_item(p_resumo.cod_item) THEN
       	 RETURN FALSE
      END IF
	  
      INSERT INTO w_edi_volksvagen 
        VALUES  (p_cod_empresa,
                 p_resumo.num_pedido, 
                 p_resumo.cod_item,                               
                 p_resumo.cod_cliente,                            
                 p_resumo.qtd_saldo,                              
                 p_num_ped_wv,                                    
                 p_cod_item_wv,                                   
                 p_contato,                                       
                 p_resumo.prz_entrega)                            
										   
       IF sqlca.sqlcode <> 0 THEN
          CALL log003_err_sql("INCLUSAO","EDI_volksvagen")
		      RETURN FALSE
       END IF
	   
       # @parte3 - Imprime no relatório a quantidade do produto 
       # por pedido mais o percentual de refugo e imprime total por produto. 
       
       OUTPUT TO REPORT pol1051_detalha(3) 
	   
   END FOREACH

   FINISH REPORT pol1051_detalha   

   RETURN TRUE
   
END FUNCTION

#---------------------------------------------#
 FUNCTION pol1051_busca_dados_item(l_cod_item)
#---------------------------------------------#
   DEFINE l_cod_item              LIKE item.cod_item
   
    INITIALIZE          p_pct_refugo ,           
                        p_num_ped_wv   ,           
                        p_cod_item_wv   ,        
                        p_contato              TO NULL

   SELECT pct_refugo, 
          num_ped_wv, 
          cod_item_wv,   
          contato
     INTO p_pct_refugo, 
          p_num_ped_wv,  
          p_cod_item_wv, 
          p_contato
     FROM item_prog_kf_1099
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = l_cod_item
	  						   
    IF sqlca.sqlcode <> 0 THEN
	   CALL log003_err_sql('Lendo','item_prog_kf_1099')
       RETURN FALSE
    ELSE
       RETURN TRUE
    END IF

END FUNCTION

#---------------------------------#
 FUNCTION pol1051_cria_temporaria()
#---------------------------------#

       DROP TABLE estrut_item_1099;
       DROP TABLE w_edi_volksvagen;
       DROP TABLE w_temp_kf;
 
      CREATE   TABLE estrut_item_1099
	  (
	      num_pedido     DECIMAL(6,0),
		  num_sequencia  DECIMAL(5,0),
		  cod_cliente    CHAR(15), 
          cod_nivel      DECIMAL(2,0),
          cod_item       CHAR(15),
		  prz_entrega    DATE,
          cod_compon     CHAR(15),
          qtd_necessaria DECIMAL(14,7),
          qtd_acumulada  DECIMAL(14,7),
          explodiu       CHAR(01),
		  seq_imp        INTEGER
      )

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Criando','estrut_item_1099')
	  RETURN FALSE
   END IF
   
   CREATE TABLE w_edi_volksvagen 
      (
       cod_empresa              CHAR(2),
       pedido                   DECIMAL(6,0),
       cod_item                 CHAR(15),
       cod_cliente              CHAR(15),
       saldo                    DECIMAL(18,7),
       num_ped_wv               CHAR(12), 
       cod_item_wv              CHAR(30),
       contato                  CHAR(11),
       prz_entrega              DATE  
      )

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","W_EDI_volksvagen")
	  RETURN FALSE
   END IF


   CREATE TABLE w_temp_kf
      (
       pedido                   DECIMAL(6,0),
	   num_sequencia            DECIMAL(5,0),
       cod_item                 CHAR(15),
       cod_cliente              CHAR(15),
       saldo                    DECIMAL(18,7),
       prz_entrega              DATE
      )                     

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","W_TEMP_kf")
	  RETURN FALSE
   END IF

   #Ivo 02/08/2011
   DROP TABLE item_estoq_1099;

   CREATE TABLE item_estoq_1099
      (
        cod_compon CHAR(15),
        qtd_saldo  DECIMAL(10,3)
      )                     

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","item_estoq_1099")
	  RETURN FALSE
   END IF
   #---Até aqui-----#
   
   RETURN TRUE
   
END FUNCTION              

#------------------------#
 FUNCTION pol1051_listar()
#------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10511") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol10511 AT 2,2 WITH FORM p_nom_tela 
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
            IF m_tip_relat <> 'G' THEN
               ERROR 'Valor Inválido'
               NEXT FIELD tip_relat 
            END IF   
         END IF

    END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   
   IF INT_FLAG THEN
      CURRENT WINDOW IS w_pol1051
      CLOSE WINDOW w_pol10511
      RETURN FALSE
   END IF

   CURRENT WINDOW IS w_pol1051
   CLOSE WINDOW w_pol10511
   RETURN TRUE

END FUNCTION

#-------------------------------#  
 FUNCTION pol1051_imprime_relat()
#-------------------------------#  

   IF NOT pol1051_escolhe_saida() THEN
   		RETURN 
   END IF
   

    START REPORT pol1051_relat TO p_nom_arquivo


      CALL pol1051_emite_relatorio()
 
    IF p_count = 0 THEN
         MESSAGE "Não Existem Dados para serem Listados" ATTRIBUTE(REVERSE)
         RETURN FALSE
    ELSE
         ERROR "Relatório Processado com Sucesso"
    END IF
      FINISH REPORT pol1051_relat

  
END FUNCTION                               
#------------------------------#
FUNCTION pol1051_escolhe_saida()
#------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1054.tmp"
         START REPORT pol1051_relat TO p_caminho
      ELSE
         START REPORT pol1051_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   
#---------------------------------#
 FUNCTION pol1051_emite_relatorio()
#---------------------------------#

   DEFINE lr_relat          RECORD  
       cod_cliente              CHAR(15),   
       cod_item                 CHAR(15),
       den_item                 CHAR(40),
       prz_entrega              DATE,
       cod_unid_med             CHAR(3),
       saldo                    DECIMAL(18,7),
       pct_refugo               DECIMAL(5,2),
       tip_item                 CHAR(1)    
                            END RECORD

   DEFINE l_qtd_item            DECIMAL(18,7),
          l_qtd                 CHAR(19),
          l_inteiro             INTEGER,
          l_decimal             INTEGER

          
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

	DECLARE cq_relat_2 SCROLL CURSOR  FOR
 
    SELECT  cod_cliente, 
	        cod_item,
			prz_entrega,
            SUM(saldo)
    FROM w_edi_volksvagen
    GROUP BY cod_cliente, cod_item, prz_entrega
    ORDER BY cod_cliente, cod_item, prz_entrega 
						   	     
     FOREACH cq_relat_2 INTO lr_relat.cod_cliente,
                             lr_relat.cod_item,
							 lr_relat.prz_entrega,
							 lr_relat.saldo
      
         SELECT den_item[1,60], cod_unid_med, ies_tip_item 
           INTO lr_relat.den_item, lr_relat.cod_unid_med, lr_relat.tip_item
           FROM item 
          WHERE cod_empresa = p_cod_empresa 
            AND cod_item    = lr_relat.cod_item 
      
         SELECT pct_refugo
           INTO lr_relat.pct_refugo
           FROM item_prog_kf_1099
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = lr_relat.cod_item
      
         LET l_qtd_item = lr_relat.saldo *(1 + (lr_relat.pct_refugo / 100))
         LET l_qtd      = l_qtd_item USING '&&&&&&&&&&&.&&&&&&&'
            
         LET l_inteiro = l_qtd[1,11]
         LET l_decimal = l_qtd[13,19]
          
         IF l_decimal > 0 THEN
            LET l_qtd_item = l_inteiro + 1
         ELSE
            LET l_qtd_item = l_inteiro + 0
         END IF
         
		 LET lr_relat.saldo = l_qtd_item
		 
         OUTPUT TO REPORT pol1051_relat(lr_relat.*)
      
         INITIALIZE lr_relat.* TO NULL 
         LET p_count = p_count + 1
      
      END FOREACH


END FUNCTION      

#-----------------------------#
 REPORT pol1051_relat(lr_relat)
#-----------------------------#
  DEFINE l_saldo_total   DECIMAL(18,7)   
  DEFINE lr_relat          RECORD  
       cod_cliente              CHAR(15),   
       cod_item                 CHAR(15),
       den_item                 CHAR(40),
       prz_entrega              DATE,
       cod_unid_med             CHAR(3),
       saldo                    DECIMAL(18,7),
       pct_refugo               DECIMAL(5,2),
       tip_item                 CHAR(1)    
   END RECORD

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3 
 
   ORDER EXTERNAL BY lr_relat.cod_cliente,
                     lr_relat.cod_item,
                     lr_relat.prz_entrega

   FORMAT
      PAGE HEADER
         LET l_saldo_total  = 0 
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 066, "RELATORIO DE ENVIO DE PROGRAMACAO",
               COLUMN 132, "PAG.: ", PAGENO USING "####"
         PRINT COLUMN 001, "pol1051",
               COLUMN 050, "PERIODO : ", mr_tela.dat_inicio,
                           " ATE ",mr_tela.dat_final,
               COLUMN 128, "DATA: ", TODAY USING "DD/MM/YY"
         PRINT COLUMN 001, "--------------------------------------------",
                           "--------------------------------------------",
                           "-----------------------------------------------------"
         PRINT COLUMN 001, "CLIENTE",              
               COLUMN 017, "ITEM",
			   COLUMN 030, "DESCRICAO",
               COLUMN 095, "DATA ENTR.",
               COLUMN 106, "UNI",
               COLUMN 111, "QTDADE",
               COLUMN 121, "REFUGO",
               COLUMN 131, "TIPO" 
         PRINT COLUMN 001, "--------------- -------------------------------",
                           "---------------------------------------------- ",
                           "---------- ---  --------- --------- ------ ----"
      ON EVERY ROW
         PRINT COLUMN 001, lr_relat.cod_cliente,
		       COLUMN 017, lr_relat.cod_item,
               COLUMN 030, lr_relat.den_item,
               COLUMN 095, lr_relat.prz_entrega,
               COLUMN 106, lr_relat.cod_unid_med,
               COLUMN 111, lr_relat.saldo USING '<<<<<<<<<',
               COLUMN 121, lr_relat.pct_refugo USING '##&.&&',
               COLUMN 131, lr_relat.tip_item         
         
         LET l_saldo_total  = l_saldo_total + lr_relat.saldo USING '<<<<<<<<&'
         SKIP 1 LINE

      AFTER GROUP OF lr_relat.cod_item
         SKIP 1 LINE
         PRINT COLUMN 001, 'TOTAL DO ITEM ',
               COLUMN 016, '..............................................',
               COLUMN 057, '..............................................',
               COLUMN 111, l_saldo_total USING '<<<<<<<<<'
         LET l_saldo_total = 0 
         SKIP 2 LINES
         PRINT COLUMN 001, "--------------------------------------------",
                           "--------------------------------------------",
                           "-----------------------------------------------------"
						        
      ON LAST ROW
         PRINT COLUMN 001, p_descomprime

END REPORT

#------------------------------#
 FUNCTION pol1051_gera_arquivo()
#------------------------------#
	DEFINE z_cod_cliente        LIKE pedidos.cod_cliente

		   
    INITIALIZE z_cod_cliente             TO NULL

    DECLARE cq_cliente SCROLL CURSOR  FOR
 
    SELECT cod_cliente
    FROM   cli_edi_1099
	ORDER BY  cod_cliente
						   	     
    FOREACH cq_cliente  INTO z_cod_cliente
	
  	  IF sqlca.sqlcode <> 0 THEN
    	     CALL log003_err_sql("FOREACH","CQ_CLIENTE")
	 	    RETURN FALSE
      END IF	
						       	  
	  IF NOT pol1051_grava_arquivo(z_cod_cliente) THEN
       		RETURN FALSE
      END IF
	  
	  LET m_count = m_count + 1
	  
   END FOREACH

   IF m_count = 0 THEN
      MESSAGE "Não Existem Dados para gerar arquivo." ATTRIBUTE(REVERSE)
      RETURN FALSE
   ELSE
      ERROR "Arquivo Processado com Sucesso."
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------------------#
 FUNCTION pol1051_grava_arquivo(z_cod_cliente)
#---------------------------------------------#
   DEFINE l_num_cnpj            CHAR(19),
          l_cnpj_kf             CHAR(19),
          l_dat_hora            CHAR(19),
		  z_cod_cliente        LIKE pedidos.cod_cliente

   DEFINE p_nome_caminho CHAR(40)
   
   SELECT nom_caminho
     INTO p_nome_caminho
     FROM caminho_1099
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','caminho_1099')
      RETURN FALSE
   END IF

   MESSAGE " Processando a Extração do Arquivo..." ATTRIBUTE(REVERSE)
    

   SELECT num_cgc_cpf
     INTO l_num_cnpj
     FROM clientes
    WHERE cod_cliente = z_cod_cliente

   IF sqlca.sqlcode <> 0 THEN
      LET l_num_cnpj = ' '
   END IF

   SELECT num_cgc
     INTO l_cnpj_kf
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
 
   IF sqlca.sqlcode <> 0 THEN
      LET l_cnpj_kf = ' '
   END IF

   LET l_cnpj_kf = l_cnpj_kf[2,3],
                      l_cnpj_kf[5,7],
                      l_cnpj_kf[9,11],
                      l_cnpj_kf[13,16],
                      l_cnpj_kf[18,19]
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
   LET p_nom_arquivo = p_nome_caminho
   
   LET p_nom_arquivo = p_nom_arquivo CLIPPED,l_num_cnpj CLIPPED,'_RND00107_',
                       l_cnpj_kf CLIPPED,'_',l_dat_hora CLIPPED,'.txt'
     
   START REPORT pol1051_relat_arq  TO p_nom_arquivo

   IF  NOT pol1051_emite_arquivo_edi(z_cod_cliente) THEN 
       RETURN FALSE 
   END IF  	   

   FINISH REPORT pol1051_relat_arq     
      
   MESSAGE "Gravado em ",p_nom_arquivo
       ATTRIBUTE(REVERSE)   
	   

   RETURN TRUE 	   
	   
END FUNCTION

#--------------------------------------------------#
 FUNCTION pol1051_emite_arquivo_edi(z_cod_cliente)
#--------------------------------------------------#
   DEFINE lr_arq_edi       RECORD
      ident_itp                CHAR(3), # 1-3     Ident. tipo registro 			- ITP
      ident_proc               CHAR(3), # 4-6     Ident. do processo 			- 001
      num_ver_transac          CHAR(2), # 7-8     Numero da Versao Transacao 	- 09
      num_ctr_transm           CHAR(5), # 9-13    Numero controle transmissao 	- 00000
      ident_ger_mov            CHAR(12),# 14-25   Ident. Geracao do movimento   - AAMMDDHHMMSS
      ident_tms_comun          CHAR(14),# 26-39   Ident. Transmissor na Comun.
      ident_rcp_comun          CHAR(14),# 40-53   Ident. Receptor na Comun. 
      cod_int_tms              CHAR(8), # 54-61   Código Interno do Transmissor
      cod_int_rcp              CHAR(8), # 62-69   Código Interno do Receptor 
      nom_tms                  CHAR(25),# 70-94   Nome do Transmissor 
      nom_rcp                  CHAR(25),# 95-119  Nome do Receptor 
      espaco_itp               CHAR(9), # 120-128 Espaço  
      ident_pe1                CHAR(3), # 1-3     Ident. Tipo Registro 			- PE1
      cod_fab_dest             CHAR(3), # 4-6     Código da Fábrica destino		- 011
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
	  ident_pe2                CHAR(3), # 1-3     Ident. Tipo Registro 			- PE2
      dat_rec_item             CHAR(6), # 4-9     Data de Última Entrega
      ult_nf                   CHAR(6), # 10-15   Número da Última Nota Fiscal (NF de venda da WV da MP)
	  ser_ult_nf               CHAR(4), # 16-19   Série da Última Nota Fiscal
	  data_ult_nf              CHAR(6), # 20-25   Data de Última Nota Fiscal
	  qtd_ult_nf               CHAR(12),# 26-37   Quantidade da Última Entrega
	  qtd_acum                 CHAR(14),# 38-51   Quantidade Entrega Acumulada
	  qtd_nec_acum             CHAR(14),# 52-65   Quantidade Necessária Acumulada
	  qtd_lote_min             CHAR(12),# 66-77   Quantido do Lote Mínimo
	  cod_freq_for             CHAR(3), # 78-80   Código de Frequencia do Fornecimento
	  dat_lib_prod             CHAR(4), # 81-84   Data de Liberação para Produção
	  dat_lib_mp               CHAR(4), # 85-88   Data de Liberação da Materia Prima
	  cod_local                CHAR(7), # 89-95   Código do Local de Descarga
	  per_entrega              CHAR(4), # 96-99   Período de Entrega
	  sit_item                 CHAR(2), # 100-101 Código da Situação do Item
	  ident_tp                 CHAR(1), # 102-102 Identificação do Tipo de Programa
	  pedido_rev               CHAR(13),# 103-115 Pedido de Revenda
	  qualif_prog              CHAR(1), # 106-116 Qualificação da Programação
	  tipo_pr                  CHAR(2), # 117-118 Tipo do Pedido de Revenda
	  via_transp               CHAR(2), # 119-121 Código da Via de Transporte
	  espaco_pe2               CHAR(7), # 122-128 Espaço 
      ident_pe3                CHAR(3), # 1-3     Ident. Tipo Registro - PE3   
      dat_ent_item_1           CHAR(6), # 4-9     Data de Entrega do item
      hor_ent_item_1           CHAR(2), # 10-11   Hora para entrega do item
      qtd_ent_item_1           CHAR(9), # 12-20   Qtde entrega do item
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
          l_cnpj_kf         CHAR(19),
          l_cod_item           LIKE item.cod_item, 
          l_cod_cliente        LIKE clientes.cod_cliente, 
          l_cod_item_wv        LIKE item_prog_kf_1099.cod_item_wv, 
          l_num_ped_wv         LIKE item_prog_kf_1099.num_ped_wv,
          l_contato            LIKE item_prog_kf_1099.contato,
          l_dat_atual          CHAR(6),
          l_hor_atual          CHAR(8),
          l_capa               SMALLINT,  
          l_qtd_item_1         DECIMAL(18,7), 
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
          l_inteiro_1          INTEGER, 
          l_decimal_1          INTEGER,
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
		  l_cod_uni_med        LIKE item_prog_kf_1099.cod_uni_med,
		  l_num_nf             LIKE nf_sup.num_nf,
		  l_ssr_nf             LIKE nf_sup.ssr_nf,
		  l_num_aviso_rec      LIKE nf_sup.num_aviso_rec,
		  l_dat_entrada_nf     LIKE nf_sup.dat_entrada_nf,
		  l_dat_emis_nf        LIKE nf_sup.dat_emis_nf,
		  l_qtd_recebida       LIKE aviso_rec.qtd_recebida,
		  x_ind                SMALLINT,
		  l_ind                SMALLINT,
          sql_stmt_2           CHAR(300),
		  z_cod_cliente        LIKE pedidos.cod_cliente,
		  z_cod_item           LIKE item.cod_item
		  
	DEFINE ma_edi   ARRAY[200] OF RECORD 
      prz_entrega             DATE,
      saldo                   DECIMAL(18,7) 
    END RECORD 
 
     DEFINE l_item_prog_kf_1099  RECORD LIKE item_prog_kf_1099.*

 
   LET l_capa  = TRUE
   LET m_count = 0
   LET l_num_reg = 0
   INITIALIZE z_cod_item   TO NULL
   INITIALIZE l_item_prog_kf_1099.* TO NULL
   INITIALIZE lr_arq_edi.*          TO NULL
    
                    
   LET sql_stmt_2 = " SELECT UNIQUE cod_item ",
                    "   FROM w_edi_volksvagen ",
					" WHERE cod_cliente      = '",z_cod_cliente,"'",
                    " ORDER BY cod_item "
					
   PREPARE var_query_2 FROM sql_stmt_2
   DECLARE cq_edi SCROLL CURSOR WITH HOLD FOR var_query_2   
   FOREACH cq_edi INTO z_cod_item


      SELECT nom_cliente, num_cgc_cpf
        INTO lr_arq_edi.nom_rcp, l_num_cnpj
        FROM clientes
       WHERE cod_cliente = z_cod_cliente
 
      IF sqlca.sqlcode <> 0 THEN
         LET l_num_cnpj = ' '
         LET lr_arq_edi.nom_rcp = ' '       
      END IF
 
      SELECT den_empresa, num_cgc
        INTO lr_arq_edi.nom_tms, l_cnpj_kf
        FROM empresa
       WHERE cod_empresa = p_cod_empresa
      
      IF sqlca.sqlcode <> 0 THEN
         LET l_cnpj_kf = ' '
         LET lr_arq_edi.nom_tms = ' '       
      END IF

      LET lr_arq_edi.ident_itp        = 'ITP'
      LET lr_arq_edi.ident_proc       = '001'
      LET lr_arq_edi.num_ver_transac  = '09'
      LET lr_arq_edi.num_ctr_transm   = '00000'
      LET l_dat_atual = TODAY USING 'yymmdd' 
      LET l_hor_atual = CURRENT HOUR TO SECOND  
      LET lr_arq_edi.ident_ger_mov    = l_dat_atual, 
                                        l_hor_atual[1,2],
                                        l_hor_atual[4,5],
                                        l_hor_atual[7,8]              
      LET lr_arq_edi.ident_tms_comun  = l_cnpj_kf[2,3], 
                                        l_cnpj_kf[5,7],
                                        l_cnpj_kf[9,11],
                                        l_cnpj_kf[13,16],
                                        l_cnpj_kf[18,19]
      LET lr_arq_edi.ident_rcp_comun  = l_num_cnpj[2,3],
                                        l_num_cnpj[5,7],
                                        l_num_cnpj[9,11],
                                        l_num_cnpj[13,16],
                                        l_num_cnpj[18,19]
      LET lr_arq_edi.cod_int_tms      = '        '
      LET lr_arq_edi.cod_int_rcp      = '        '
      LET lr_arq_edi.espaco_itp       = ' ' 

      IF l_capa THEN 
         LET l_num_reg = l_num_reg + 1
         OUTPUT TO REPORT pol1051_relat_arq(0,lr_arq_edi.*)
         LET l_capa = FALSE
      END IF
   
  
	  INITIALIZE p_num_processo   TO NULL
	  
	  SELECT num_processo 
		INTO p_num_processo  
	    FROM processo_edi_1099
		WHERE cod_empresa = p_cod_empresa
	  	
	  IF sqlca.sqlcode <> 0 THEN
         LET p_num_processo = 0      
      END IF
	  
	  LET p_num_processo =  p_num_processo + 1
	  
	  UPDATE processo_edi_1099  SET num_processo =  p_num_processo WHERE cod_empresa = p_cod_empresa
	  	
	  IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE     
      END IF
	  
	  SELECT *
	    INTO  l_item_prog_kf_1099.*
	    FROM  item_prog_kf_1099
       WHERE  cod_empresa      = p_cod_empresa
         AND     cod_item      = z_cod_item
			 
  	  IF sqlca.sqlcode <> 0 THEN
    	 CALL log003_err_sql("SELECT","ITEM_PROG_KF_1099")
	 	 RETURN FALSE
      END IF	
	  
	  LET lr_arq_edi.ident_pe1        = 'PE1' 
      LET lr_arq_edi.cod_fab_dest     = '011'
      LET lr_arq_edi.ident_prog_atual = p_num_processo USING '&&&&&&&&&'
      LET lr_arq_edi.dat_prog_atual   = TODAY USING 'yymmdd'
      LET lr_arq_edi.ident_prog_ant   = ' '
      LET lr_arq_edi.dat_prog_ant     = '000000' #ivo - arquivo da vw esta branco
      LET lr_arq_edi.cod_item_cli     = l_item_prog_kf_1099.cod_item_wv
      LET lr_arq_edi.cod_item_forn    = z_cod_item 
      LET lr_arq_edi.num_ped_comp     = l_item_prog_kf_1099.num_ped_wv #ivo - vw enviou OP200015
      LET lr_arq_edi.cod_loc_dest     = '011'  
      LET lr_arq_edi.ident_para_cont  = l_item_prog_kf_1099.contato 
      LET lr_arq_edi.cod_unid_med     = l_item_prog_kf_1099.cod_uni_med
      LET lr_arq_edi.qtd_casas_dec    = '0' 
      LET lr_arq_edi.cod_tip_fornto   = 'P' 
	  
	  LET l_num_reg = l_num_reg + 1
      OUTPUT TO REPORT pol1051_relat_arq(1,lr_arq_edi.*)
	  
	  INITIALIZE l_dat_entrada_nf , l_dat_emis_nf  TO NULL	  
      LET l_ssr_nf         = ' '  
	  LET l_num_nf         = 0 
	  LET l_num_aviso_rec  = 0 
	  LET l_qtd_recebida   = 0 
	 
	  DECLARE cq_ultnf SCROLL CURSOR FOR

	    SELECT a.num_nf, a.ssr_nf, a.num_aviso_rec, a.dat_entrada_nf, a.dat_emis_nf, sum(b.qtd_recebida)
	    FROM  nf_sup a, aviso_rec b
		WHERE a.cod_empresa=b.cod_empresa
		AND   a.num_aviso_rec=b.num_aviso_rec
                AND   b.cod_item=z_cod_item
                AND   a.cod_empresa=p_cod_empresa
				AND   a.cod_fornecedor = z_cod_cliente
                AND   a.dat_entrada_nf  IN(SELECT  max(dat_entrada_nf)
                                             FROM  nf_sup c, aviso_rec d
                                            WHERE c.cod_empresa=d.cod_empresa
                                               AND   c.num_aviso_rec=d.num_aviso_rec
                                               AND   c.cnd_pgto_nf in (SELECT   cnd_pgto
                                              FROM   cond_pgto_cap
                                             WHERE   ies_pagamento='2')
                                               AND   d.cod_item=z_cod_item
                                               AND   c.cod_empresa=p_cod_empresa)
		GROUP BY  a.num_nf, a.ssr_nf, a.num_aviso_rec, a.dat_entrada_nf, a.dat_emis_nf
		ORDER BY  a.num_aviso_rec DESC

		FOREACH cq_ultnf  INTO  l_num_nf, l_ssr_nf, l_num_aviso_rec, l_dat_entrada_nf, l_dat_emis_nf, l_qtd_recebida 
		
	        IF sqlca.sqlcode <> 0 THEN
               LET l_ssr_nf         = ' '  
	           LET l_num_nf         = 0 
	           LET l_num_aviso_rec  = 0 
	           LET l_qtd_recebida   = 0   
               EXIT FOREACH 	
            ELSE
               EXIT FOREACH			
            END IF
	    END FOREACH
	   IF sqlca.sqlcode <> 0 THEN
           LET l_ssr_nf         = ' '  
	       LET l_num_nf         = 0 
	       LET l_num_aviso_rec  = 0 
	       LET l_qtd_recebida   = 0   
       END IF
	   
	  LET lr_arq_edi.ident_pe2        = 'PE2'
	  
	  IF (l_dat_entrada_nf = '31/12/1899') OR
         (l_dat_entrada_nf IS NULL)        THEN
         LET lr_arq_edi.dat_rec_item = '000000'
      ELSE 
         LET lr_arq_edi.dat_rec_item = l_dat_entrada_nf USING 'yymmdd' 
      END IF
	  
	  IF (l_dat_emis_nf = '31/12/1899') OR
         (l_dat_emis_nf IS NULL)        THEN
         LET lr_arq_edi.data_ult_nf = '000000'
      ELSE 
         LET lr_arq_edi.data_ult_nf = l_dat_emis_nf USING 'yymmdd' 
      END IF
	  
	  LET lr_arq_edi.ult_nf           = l_num_nf  USING '&&&&&&'
	  LET lr_arq_edi.ser_ult_nf       = l_ssr_nf  USING '####'
	  LET l_qtd_recebida              = l_qtd_recebida * 1000
	  LET lr_arq_edi.qtd_ult_nf       = l_qtd_recebida USING '&&&&&&&&&&&&'
	  LET lr_arq_edi.qtd_acum         = '00000000000000'
	  LET lr_arq_edi.qtd_nec_acum     = '00000000000000'
	  LET lr_arq_edi.qtd_lote_min     = '000000000000'
	  LET lr_arq_edi.cod_freq_for     = ' '
      LET lr_arq_edi.dat_lib_prod     = '0000'
	  LET lr_arq_edi.dat_lib_mp       = '0000'
	  LET lr_arq_edi.cod_local        = ' '
	  LET lr_arq_edi.per_entrega      = ' '
	  LET lr_arq_edi.sit_item         = ' '
	  LET lr_arq_edi.ident_tp         = '1'
	  LET lr_arq_edi.pedido_rev       = ' '
	  LET lr_arq_edi.qualif_prog      = ' '
	  LET lr_arq_edi.tipo_pr          = ' '
	  LET lr_arq_edi.via_transp       = ' ' 
	  LET lr_arq_edi.espaco_pe2       = ' '
	  
	  
	  LET l_num_reg = l_num_reg + 1
      OUTPUT TO REPORT pol1051_relat_arq(2,lr_arq_edi.*)
	    
		
    LET l_ind = 1   
    INITIALIZE ma_edi  TO NULL 	

    DECLARE cq_prz_entrega CURSOR FOR
      SELECT SUM(saldo), prz_entrega 
      FROM w_edi_volksvagen 
      WHERE cod_item      = z_cod_item
	  AND cod_cliente     = z_cod_cliente
      GROUP BY prz_entrega 
      ORDER BY prz_entrega 

    FOREACH cq_prz_entrega INTO ma_edi[l_ind].saldo,
                                ma_edi[l_ind].prz_entrega
         
         LET l_ind = l_ind + 1
         IF l_ind  > 198 THEN 
			CALL log003_err_sql('ESTOUROU INDICE 1','L_IND')
			RETURN  FALSE
	     END IF 		
    END FOREACH	
	
	  
	LET x_ind = 0
	  
	  WHILE TRUE
               			
            LET  lr_arq_edi.dat_ent_item_1           = '000000'
            LET  lr_arq_edi.hor_ent_item_1           = '00'
            LET  lr_arq_edi.qtd_ent_item_1           = '000000000'
            LET  lr_arq_edi.dat_ent_item_2           = '000000'
            LET  lr_arq_edi.hor_ent_item_2           = '00'
            LET  lr_arq_edi.qtd_ent_item_2           = '000000000'
            LET  lr_arq_edi.dat_ent_item_3           = '000000'
            LET  lr_arq_edi.hor_ent_item_3           = '00'
            LET  lr_arq_edi.qtd_ent_item_3           = '000000000'
            LET  lr_arq_edi.dat_ent_item_4           = '000000'
            LET  lr_arq_edi.hor_ent_item_4           = '00'
            LET  lr_arq_edi.qtd_ent_item_4           = '000000000'
            LET  lr_arq_edi.dat_ent_item_5           = '000000'
            LET  lr_arq_edi.hor_ent_item_5           = '00'
            LET  lr_arq_edi.qtd_ent_item_5           = '000000000'
            LET  lr_arq_edi.dat_ent_item_6           = '000000'
            LET  lr_arq_edi.hor_ent_item_6           = '00'
            LET  lr_arq_edi.qtd_ent_item_6           = '000000000'
            LET  lr_arq_edi.dat_ent_item_7           = '000000'
            LET  lr_arq_edi.hor_ent_item_7           = '00'
            LET  lr_arq_edi.qtd_ent_item_7           = '000000000'
	
			
            LET lr_arq_edi.ident_pe3        = 'PE3'
			LET lr_arq_edi.espaco_pe3       = ' '    
			LET x_ind = x_ind + 1 
							
			IF (ma_edi[x_ind].saldo  IS NULL) OR
               (ma_edi[x_ind].saldo  <=0 )		THEN
				EXIT WHILE  
			END IF 			  
			
		    IF x_ind  >  199   THEN 
			   CALL log003_err_sql('ESTOUROU INDICE 2', x_ind)
			   RETURN  FALSE
            END IF  	
				  
            LET lr_arq_edi.dat_ent_item_1     = ma_edi[x_ind].prz_entrega USING 'yymmdd'   
            LET lr_arq_edi.hor_ent_item_1     = '00'    
  
            LET l_qtd_item_1 = ma_edi[x_ind].saldo * (1 + (l_item_prog_kf_1099.pct_refugo / 100))
            LET l_qtd_1 = l_qtd_item_1 USING '&&&&&&&&&&&.&&&&&&&'   
            LET l_inteiro_1 = l_qtd_1[1,11]
            LET l_decimal_1 = l_qtd_1[13,19]  
            IF l_decimal_1 > 0 THEN
               LET l_qtd_item_1 = l_inteiro_1 + 1
            ELSE
               LET l_qtd_item_1 = l_inteiro_1 + 0
            END IF        
            LET lr_arq_edi.qtd_ent_item_1    = l_qtd_item_1 USING '&&&&&&&&&'

			LET x_ind = x_ind + 1 
			
			IF (ma_edi[x_ind].prz_entrega  IS NULL)  THEN
			   	  LET l_num_reg = l_num_reg + 1
                  OUTPUT TO REPORT pol1051_relat_arq(3,lr_arq_edi.*)
				  EXIT WHILE    
			END IF 	
                			   
			LET lr_arq_edi.dat_ent_item_2     = ma_edi[x_ind].prz_entrega USING 'yymmdd'   
            LET lr_arq_edi.hor_ent_item_2     = '00'    
  
            LET l_qtd_item_2 = ma_edi[x_ind].saldo *(1 + (l_item_prog_kf_1099.pct_refugo / 100))
            LET l_qtd_2 = l_qtd_item_2 USING '&&&&&&&&&&&.&&&&&&&'   
            LET l_inteiro_2 = l_qtd_2[1,11]
            LET l_decimal_2 = l_qtd_2[13,19]  
            IF l_decimal_2 > 0 THEN
               LET l_qtd_item_2 = l_inteiro_2 + 1
            ELSE
               LET l_qtd_item_2 = l_inteiro_2 + 0
            END IF        
            LET lr_arq_edi.qtd_ent_item_2    = l_qtd_item_2 USING '&&&&&&&&&'

			LET x_ind = x_ind + 1 
			
		    IF (ma_edi[x_ind].prz_entrega  IS NULL)  THEN
			   	  LET l_num_reg = l_num_reg + 1
                  OUTPUT TO REPORT pol1051_relat_arq(3,lr_arq_edi.*)
				  EXIT WHILE    
			END IF 	
                			   
			LET lr_arq_edi.dat_ent_item_3     = ma_edi[x_ind].prz_entrega USING 'yymmdd'   
            LET lr_arq_edi.hor_ent_item_3     = '00'    
  
            LET l_qtd_item_3 = ma_edi[x_ind].saldo *(1 + (l_item_prog_kf_1099.pct_refugo / 100))
            LET l_qtd_3 = l_qtd_item_3 USING '&&&&&&&&&&&.&&&&&&&'   
            LET l_inteiro_3 = l_qtd_3[1,11]
            LET l_decimal_3 = l_qtd_3[13,19]  
            IF l_decimal_3 > 0 THEN
               LET l_qtd_item_3 = l_inteiro_3 + 1
            ELSE
               LET l_qtd_item_3 = l_inteiro_3 + 0
            END IF        
            LET lr_arq_edi.qtd_ent_item_3    = l_qtd_item_3 USING '&&&&&&&&&'
			
			
		    LET x_ind = x_ind + 1 
			
		    IF (ma_edi[x_ind].prz_entrega  IS NULL)  THEN
			   	  LET l_num_reg = l_num_reg + 1
                  OUTPUT TO REPORT pol1051_relat_arq(3,lr_arq_edi.*)
				  EXIT WHILE    
			END IF 	
                			   
			LET lr_arq_edi.dat_ent_item_4    = ma_edi[x_ind].prz_entrega USING 'yymmdd'   
            LET lr_arq_edi.hor_ent_item_4     = '00'    
  
            LET l_qtd_item_4 = ma_edi[x_ind].saldo *(1 + (l_item_prog_kf_1099.pct_refugo / 100))
            LET l_qtd_4 = l_qtd_item_4 USING '&&&&&&&&&&&.&&&&&&&'   
            LET l_inteiro_4 = l_qtd_4[1,11]
            LET l_decimal_4 = l_qtd_4[13,19]  
            IF l_decimal_4 > 0 THEN
               LET l_qtd_item_4 = l_inteiro_4 + 1
            ELSE
               LET l_qtd_item_4 = l_inteiro_4 + 0
            END IF        
            LET lr_arq_edi.qtd_ent_item_4    = l_qtd_item_4 USING '&&&&&&&&&'	
			
			
	        LET x_ind = x_ind + 1 
			
		    IF (ma_edi[x_ind].prz_entrega  IS NULL)  THEN
			   	  LET l_num_reg = l_num_reg + 1
                  OUTPUT TO REPORT pol1051_relat_arq(3,lr_arq_edi.*)
				  EXIT WHILE    
			END IF 	
                			   
			LET lr_arq_edi.dat_ent_item_5    = ma_edi[x_ind].prz_entrega USING 'yymmdd'   
            LET lr_arq_edi.hor_ent_item_5     = '00'    
  
            LET l_qtd_item_5 = ma_edi[x_ind].saldo *(1 + (l_item_prog_kf_1099.pct_refugo / 100))
            LET l_qtd_5 = l_qtd_item_5 USING '&&&&&&&&&&&.&&&&&&&'   
            LET l_inteiro_5 = l_qtd_5[1,11]
            LET l_decimal_5 = l_qtd_5[13,19]  
            IF l_decimal_5 > 0 THEN
               LET l_qtd_item_5 = l_inteiro_5 + 1
            ELSE
               LET l_qtd_item_5 = l_inteiro_5 + 0
            END IF        
            LET lr_arq_edi.qtd_ent_item_5    = l_qtd_item_5 USING '&&&&&&&&&'	
			
		    LET x_ind = x_ind + 1 
			
		    IF (ma_edi[x_ind].prz_entrega  IS NULL)  THEN
			   	  LET l_num_reg = l_num_reg + 1
                  OUTPUT TO REPORT pol1051_relat_arq(3,lr_arq_edi.*)
				  EXIT WHILE    
			END IF 	
                			   
			LET lr_arq_edi.dat_ent_item_6    = ma_edi[x_ind].prz_entrega USING 'yymmdd'   
            LET lr_arq_edi.hor_ent_item_6     = '00'    
  
            LET l_qtd_item_6 = ma_edi[x_ind].saldo *(1 + (l_item_prog_kf_1099.pct_refugo / 100))
            LET l_qtd_6 = l_qtd_item_6 USING '&&&&&&&&&&&.&&&&&&&'   
            LET l_inteiro_6 = l_qtd_6[1,11]
            LET l_decimal_6 = l_qtd_6[13,19]  
            IF l_decimal_6 > 0 THEN
               LET l_qtd_item_6 = l_inteiro_6 + 1
            ELSE
               LET l_qtd_item_6 = l_inteiro_6 + 0
            END IF        
            LET lr_arq_edi.qtd_ent_item_6    = l_qtd_item_6 USING '&&&&&&&&&'	
			
			
			
			LET x_ind = x_ind + 1 
			
		    IF (ma_edi[x_ind].prz_entrega  IS NULL)  THEN
			   	  LET l_num_reg = l_num_reg + 1
                  OUTPUT TO REPORT pol1051_relat_arq(3,lr_arq_edi.*)
				  EXIT WHILE    
			END IF 	
                			   
			LET lr_arq_edi.dat_ent_item_7    = ma_edi[x_ind].prz_entrega USING 'yymmdd'   
            LET lr_arq_edi.hor_ent_item_7     = '00'    
  
            LET l_qtd_item_7 = ma_edi[x_ind].saldo *(1 + (l_item_prog_kf_1099.pct_refugo / 100))
            LET l_qtd_7 = l_qtd_item_7 USING '&&&&&&&&&&&.&&&&&&&'   
            LET l_inteiro_7 = l_qtd_7[1,11]
            LET l_decimal_7 = l_qtd_7[13,19]  
            IF l_decimal_7 > 0 THEN
               LET l_qtd_item_7 = l_inteiro_7 + 1
            ELSE
               LET l_qtd_item_7 = l_inteiro_7 + 0
            END IF        
            LET lr_arq_edi.qtd_ent_item_7    = l_qtd_item_7 USING '&&&&&&&&&'	
			
			LET l_num_reg = l_num_reg + 1
			OUTPUT TO REPORT pol1051_relat_arq(3,lr_arq_edi.*)
			
	   END WHILE

	   
   END FOREACH

   
   IF l_num_reg > 0   THEN 
      LET lr_arq_edi.ident_ftp        = 'FTP'  
      LET lr_arq_edi.num_ctr_tms_ftp  = '00000' 
      LET lr_arq_edi.qtd_reg_transac  = l_num_reg + 1 USING '&&&&&&&&&'
      LET lr_arq_edi.num_tot_val      = '00000000000000000'  
      LET lr_arq_edi.categ_operac     = ' '  
      LET lr_arq_edi.espaco_ftp       = ' '  
     
      OUTPUT TO REPORT pol1051_relat_arq(4,lr_arq_edi.*)
   END IF	  
   
   RETURN TRUE
   
END FUNCTION
     
#-------------------------------------------#
 REPORT pol1051_relat_arq(l_tipo, lr_arq_edi)
#-------------------------------------------#
   DEFINE lr_arq_edi       RECORD
      ident_itp                CHAR(3), # 1-3     Ident. tipo registro 			- ITP
      ident_proc               CHAR(3), # 4-6     Ident. do processo 			- 001
      num_ver_transac          CHAR(2), # 7-8     Numero da Versao Transacao 	- 09
      num_ctr_transm           CHAR(5), # 9-13    Numero controle transmissao 	- 00000
      ident_ger_mov            CHAR(12),# 14-25   Ident. Geracao do movimento   - AAMMDDHHMMSS
      ident_tms_comun          CHAR(14),# 26-39   Ident. Transmissor na Comun.
      ident_rcp_comun          CHAR(14),# 40-53   Ident. Receptor na Comun. 
      cod_int_tms              CHAR(8), # 54-61   Código Interno do Transmissor
      cod_int_rcp              CHAR(8), # 62-69   Código Interno do Receptor 
      nom_tms                  CHAR(25),# 70-94   Nome do Transmissor 
      nom_rcp                  CHAR(25),# 95-119  Nome do Receptor 
      espaco_itp               CHAR(9), # 120-128 Espaço  
      ident_pe1                CHAR(3), # 1-3     Ident. Tipo Registro 			- PE1
      cod_fab_dest             CHAR(3), # 4-6     Código da Fábrica destino		- 011
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
	  ident_pe2                CHAR(3), # 1-3     Ident. Tipo Registro - PE2
      dat_rec_item             CHAR(6), # 4-9     Data de Última Entrega
      ult_nf                   CHAR(6), # 10-15   Número da Última Nota Fiscal (NF de venda da WV da MP)
	  ser_ult_nf               CHAR(4), # 16-19   Série da Última Nota Fiscal
	  data_ult_nf              CHAR(6), # 20-25   Data de Última Nota Fiscal
	  qtd_ult_nf               CHAR(12),# 26-37   Quantidade da Última Entrega
	  qtd_acum                 CHAR(14),# 38-51   Quantidade Entrega Acumulada
	  qtd_nec_acum             CHAR(14),# 52-65   Quantidade Necessária Acumulada
	  qtd_lote_min             CHAR(12),# 66-77   Quantido do Lote Mínimo
	  cod_freq_for             CHAR(3), # 78-80   Código de Frequencia do Fornecimento
	  dat_lib_prod             CHAR(4), # 81-84   Data de Liberação para Produção
	  dat_lib_mp               CHAR(4), # 85-88   Data de Liberação da Materia Prima
	  cod_local                CHAR(7), # 89-95   Código do Local de Descarga
	  per_entrega              CHAR(4), # 96-99   Período de Entrega
	  sit_item                 CHAR(2), # 100-101 Código da Situação do Item
	  ident_tp                 CHAR(1), # 102-102 Identificação do Tipo de Programa
	  pedido_rev               CHAR(13),# 103-115 Pedido de Revenda
	  qualif_prog              CHAR(1), # 106-116 Qualificação da Programação
	  tipo_pr                  CHAR(2), # 117-118 Tipo do Pedido de Revenda
	  via_transp               CHAR(2), # 119-121 Código da Via de Transporte
	  espaco_pe2               CHAR(7), # 122-128 Espaço 
      ident_pe3                CHAR(3), # 1-3     Ident. Tipo Registro - PE3   
      dat_ent_item_1           CHAR(6), # 4-9     Data de Entrega do item
      hor_ent_item_1           CHAR(2), # 10-11   Hora para entrega do item
      qtd_ent_item_1           CHAR(9), # 12-20   Qtde entrega do item
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
            WHEN l_tipo = 0
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
               PRINT COLUMN 120, lr_arq_edi.espaco_itp, '\n' 
         
            WHEN l_tipo = 1
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
               PRINT COLUMN 128, lr_arq_edi.cod_tip_fornto , '\n' 
			   
            WHEN l_tipo = 2
               PRINT COLUMN 001, lr_arq_edi.ident_pe2;  
               PRINT COLUMN 004, lr_arq_edi.dat_rec_item;
			   PRINT COLUMN 010, lr_arq_edi.ult_nf; 
			   PRINT COLUMN 016, lr_arq_edi.ser_ult_nf; 
			   PRINT COLUMN 020, lr_arq_edi.data_ult_nf;
			   PRINT COLUMN 026, lr_arq_edi.qtd_ult_nf;
			   PRINT COLUMN 038, lr_arq_edi.qtd_acum;
			   PRINT COLUMN 052, lr_arq_edi.qtd_nec_acum;
			   PRINT COLUMN 066, lr_arq_edi.qtd_lote_min;
			   PRINT COLUMN 078, lr_arq_edi.cod_freq_for;
			   PRINT COLUMN 081, lr_arq_edi.dat_lib_prod;
			   PRINT COLUMN 085, lr_arq_edi.dat_lib_mp;
			   PRINT COLUMN 089, lr_arq_edi.cod_local;
			   PRINT COLUMN 096, lr_arq_edi.per_entrega;
			   PRINT COLUMN 100, lr_arq_edi.sit_item;
			   PRINT COLUMN 102, lr_arq_edi.ident_tp;
			   PRINT COLUMN 103, lr_arq_edi.pedido_rev;
			   PRINT COLUMN 107, lr_arq_edi.qualif_prog;
			   PRINT COLUMN 117, lr_arq_edi.tipo_pr;
			   PRINT COLUMN 119, lr_arq_edi.via_transp;  
               PRINT COLUMN 123, lr_arq_edi.espaco_pe2, '\n'    

            WHEN l_tipo = 3			   
               PRINT COLUMN 001, lr_arq_edi.ident_pe3;       
               PRINT COLUMN 004, lr_arq_edi.dat_ent_item_1;    
               PRINT COLUMN 010, lr_arq_edi.hor_ent_item_1;    
               PRINT COLUMN 012, lr_arq_edi.qtd_ent_item_1 USING '&&&&&&&&&';    
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
               PRINT COLUMN 123, lr_arq_edi.espaco_pe3, '\n'    			   

            WHEN l_tipo = 4   
               PRINT COLUMN 001, lr_arq_edi.ident_ftp;           
               PRINT COLUMN 004, lr_arq_edi.num_ctr_tms_ftp;     
               PRINT COLUMN 009, lr_arq_edi.qtd_reg_transac;     
               PRINT COLUMN 018, lr_arq_edi.num_tot_val;         
               PRINT COLUMN 035, lr_arq_edi.categ_operac;        
               PRINT COLUMN 036, lr_arq_edi.espaco_ftp, '\n' 
        END CASE

END REPORT                                         
#-----------------------#
 FUNCTION pol1051_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------------#
 REPORT pol1051_detalha(p_ordem_imp)                              
#--------------------------------# 


	DEFINE 	p_ordem_imp				SMALLINT
   
	OUTPUT LEFT   MARGIN 0
	TOP    				MARGIN 0
	BOTTOM 				MARGIN 3
  
	FORMAT
	
	PAGE HEADER  								#----------CABEÇALHO DO RELATORIO-------------
  			LET   p_cabeca_imp = 0
	
         PRINT COLUMN 001, p_comprime,"----------------------------------------------------------------------------------"
                           
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 70, "PAG: ", PAGENO USING "###&"
               
         PRINT COLUMN 001, "pol1051",
               COLUMN 013, "DETALHAMENTO DO ARQUIVO PARA VW",
               COLUMN 056, "DATA: ", TODAY USING "DD/MM/YYYY", " - ", TIME
               
				IF p_ordem_imp = 1 THEN        
        	PRINT COLUMN 001, "----------------------------------------------------------------------------------"
         	PRINT COLUMN 001, "PEDIDO| SEQ |  COD. ITEM    | COD. CLIENTE  |  SALDO   | PRZ. ENTREGA |SALDO EST. "
         	PRINT COLUMN 001, "------|-----|---------------|---------------|----------|--------------|-----------"
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
				ELSE
					IF p_ordem_imp = 2 THEN        
         		PRINT COLUMN 001, "-----------------------------------------------------------------------------"
         		PRINT COLUMN 001, "PEDIDO| COD. CLIENTE  |  COMPONENTE    |  SALDO   | PRZ. ENTREGA |SALDO EST. " 
         		PRINT COLUMN 001, "------|---------------|----------------|----------|--------------|-----------"
                           	  #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           	  #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
					ELSE
         		PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------"
         		PRINT COLUMN 001, "PEDIDO|   COD. ITEM   |  COD. CLIENTE  |  SALDO   | PEDIDO VW |       COD. ITEM VW           |  CONTATO  | PRZ. ENTREGA" 
         		PRINT COLUMN 001, "------|---------------|----------------|----------|-----------|------------------------------|-----------|--------------"
                           	  #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           	  #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
        	END IF
  			  LET   p_cabeca_imp = 1
				END IF
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
  CASE p_ordem_imp
  	WHEN 1
         PRINT COLUMN 001, l_pedido USING '&&&&&&', 
               COLUMN 007,'|',
               COLUMN 008, l_num_sequencia USING '&&&&&', 
               COLUMN 013,'|',
               COLUMN 014, l_cod_item, 
               COLUMN 029,'|',
               COLUMN 030, l_cod_cliente, 
               COLUMN 045,'|',
               COLUMN 046, l_saldo USING '#####&.&&&', 
               COLUMN 056,'|',
             	 COLUMN 058, l_prz_entrega, 
               COLUMN 071,'|',
             	 COLUMN 072, x_saldo USING '#####&.&&&'
             	 
		     #IF  x_saldo >= l_saldo  THEN 			
				 	
         ##		PRINT COLUMN 010, '< Pedido descartado pois tem estoque >'
				 #ELSE
         		PRINT COLUMN 010, '< Pedido considerado >'
         #END IF     		
         PRINT COLUMN 001, "------|-----|---------------|---------------|----------|--------------|-----------"

  	WHEN 2
         IF p_cabeca_imp = 0 THEN

         	PRINT COLUMN 001, "----------------------------------------------------------------------------------"

     {33} SKIP 3 LINES

#      SKIP TO TOP OF PAGE

         PRINT COLUMN 001, "-----------------------------------------------------------------------------"
         PRINT COLUMN 001, "PEDIDO| COD. CLIENTE  |  COMPONENTE    |  SALDO   | PRZ. ENTREGA |SALDO EST. " 
         PRINT COLUMN 001, "------|---------------|----------------|----------|--------------|-----------"
  			 LET   p_cabeca_imp = 1
         ELSE
         END IF

{        IF y_cod_item  = p_resumo.cod_item  THEN 
         PRINT COLUMN 001, 'Saldo em Estoque: ',p_y_saldo USING '#,##&.&&&',' - Est. Seg.: ',p_y_qtd_estoq_seg USING '#,##&.&&&',' = ',p_y_saldo-p_y_qtd_estoq_seg USING '#,##&.&&&' 
        ELSE
        END IF}
         PRINT COLUMN 001, p_resumo.num_pedido USING '&&&&&&', 
               COLUMN 007,'|',
               COLUMN 008, p_resumo.cod_cliente, 
               COLUMN 023,'|',
               COLUMN 024, p_resumo.cod_item, 
               COLUMN 040,'|',
               COLUMN 042, p_resumo.qtd_saldo USING '#####&.&&&', 
               COLUMN 051,'|',
             	 COLUMN 053, p_resumo.prz_entrega, 
               COLUMN 066,'|',
             	 COLUMN 067, y_saldo USING '#####&.&&&' 
             	 
		    #IF  y_saldo >= p_resumo.qtd_saldo  THEN 			
        # 		PRINT COLUMN 010, '< Componente descartado pois tem saldo em estoque >'
				# ELSE
         		PRINT COLUMN 010, '< Componente considerado  >'
         #END IF     		
         PRINT COLUMN 001, "------|---------------|----------------|----------|--------------|-----------"

  	WHEN 3
         IF p_cabeca_imp = 0 THEN

         	PRINT COLUMN 001, "-----------------------------------------------------------------------------"

    	{33} SKIP 3 LINES

#      SKIP TO TOP OF PAGE

	         	PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------"
	         	PRINT COLUMN 001, "PEDIDO|   COD. ITEM   |  COD. CLIENTE  |  SALDO   | PEDIDO VW |       COD. ITEM VW           |  CONTATO  | PRZ. ENTREGA" 
	         	PRINT COLUMN 001, "------|---------------|----------------|----------|-----------|------------------------------|-----------|--------------"
	                           	#         1         2         3         4         5         6         7         8         9        10        11        12        13            
	                           	#1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	  			 	LET   p_cabeca_imp = 1
	         ELSE
         END IF

         PRINT COLUMN 001, p_resumo.num_pedido USING '&&&&&&', 
               COLUMN 007,'|',
               COLUMN 008, p_resumo.cod_item, 
               COLUMN 023,'|',
               COLUMN 024, p_resumo.cod_cliente, 
               COLUMN 040,'|',
               COLUMN 042, p_resumo.qtd_saldo USING '#####&.&&&', 
               COLUMN 051,'|',
             	 COLUMN 052, p_num_ped_wv USING '&&&&&&&&&&&', 
               COLUMN 063,'|',
             	 COLUMN 064, p_cod_item_wv, 
               COLUMN 094,'|',
             	 COLUMN 095, p_contato,
               COLUMN 106,'|',
             	 COLUMN 108, p_resumo.prz_entrega
             	 
         	PRINT COLUMN 001, "------|---------------|----------------|----------|-----------|------------------------------|-----------|--------------"

	END CASE					
  
  ON LAST ROW 
  CASE p_ordem_imp
  	WHEN 1
         PRINT COLUMN 001, "----------------------------------------------------------------------------------"
         PRINT COLUMN 001, p_descomprime
         PRINT
  			 LET   p_cabeca_imp = 0
  	WHEN 2
         PRINT COLUMN 001, "-----------------------------------------------------------------------------"
         PRINT COLUMN 001, p_descomprime
         PRINT
  			 LET   p_cabeca_imp = 0
  	WHEN 3
         	PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------"
         PRINT COLUMN 001, p_descomprime
         PRINT
	END CASE  				

END REPORT



 