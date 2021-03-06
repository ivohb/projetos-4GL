#------------------------------------------------------------------------------#
# SISTEMA.: INTEGRA��O DO LOGIX x PW1         	                               #
# PROGRAMA: pol1131                                                            #
# OBJETIVO: EXPORTA��O DO LOGIX x PW1                                          #
# AUTOR...: MANUEL PIER SOBRIDO com base no pol1126                            #
# DATA....: 15/01/2012                                                         #
#------------------------------------------------------------------------------#
 DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_cod_item             LIKE item.cod_item,
          p_num_ordem            LIKE ordens.num_ordem,
          m_num_ordem            LIKE ordens.num_ordem,
          p_dat_abert            LIKE ordens.dat_abert,
          p_status               SMALLINT,
          p_qtd_pc_geme          SMALLINT,
          p_pc_por_oper          INTEGER,
          p_pc_hora              INTEGER,
          p_tmp_ciclo            decimal(11,7),
          l_ies_situacao         CHAR(01),
          p_msg                  CHAR(500),
		  p_compl                CHAR(30),
		  p_data_arquivo         DATE,
          p_hora_arquivo         DATETIME HOUR TO SECOND,
		  p_data_arq             CHAR(10),
          p_hora_arq             CHAR(19),
		  p_data_rem             CHAR(08),
          p_hora_rem             CHAR(06)

   DEFINE l_relat                SMALLINT,
          l_cont                 INTEGER,
          l_cod_arranjo          LIKE rec_arranjo.cod_arranjo,
          p_dat_ini              DATETIME YEAR TO SECOND,
          p_qtd_planej             LIKE ordens.qtd_planej,
          p_hor_ini              DATETIME HOUR TO SECOND,
          p_dat_aux              CHAR(10),
          p_hor_aux              CHAR(08),
          p_dat_oper             CHAR(08),
          p_hor_oper             CHAR(06),
          p_index                SMALLINT,
          s_index                SMALLINT
          

   DEFINE p_ies_impressao        CHAR(001),
          g_ies_ambiente         CHAR(001),
          p_nom_arquivo          CHAR(100),
          p_nom_arquivo_back     CHAR(100),
          g_usa_visualizador     SMALLINT

   DEFINE g_ies_grafico          SMALLINT

    DEFINE p_versao               CHAR(18)


   DEFINE pr_op      ARRAY[900] OF RECORD
          num_ordem  LIKE ordens.num_ordem,
          ies_situa  LIKE ordens.ies_situa,
          cod_item   LIKE ordens.cod_item,
          qtd_saldo  LIKE ordens.qtd_planej
   END RECORD

     DEFINE m_den_empresa          LIKE empresa.den_empresa,
            m_consulta_ativa       SMALLINT,
            m_esclusao_ativa       SMALLINT,
            sql_stmt               CHAR(5000),
            where_clause           CHAR(5000),
            comando                CHAR(080),
            m_comando              CHAR(080),
            p_caminho              CHAR(60),
            w_caminho              CHAR(50),
            p_men                  CHAR(100),
            m_caminho              CHAR(150),
            p_last_row             SMALLINT,
            m_processa             SMALLINT,
            m_primeira_vez         SMALLINT, 
            m_arquivo_nf           CHAR(150),
            m_arquivo_ud           CHAR(150),
            m_msg                  CHAR(100),
            p_den_empresa          LIKE empresa.den_empresa, 
			p_ponto_virgula 	   CHAR(01),
			p_cabecalho            INTEGER
    
   DEFINE lr_dados_ordem         RECORD 
          num_ordem           DECIMAL(9,0),
			 cod_operac          CHAR(5),
			 num_seq_operac      DECIMAL(2,0),
             cod_item            CHAR(50),    
			 den_item   		 CHAR(50),
			 den_cliente 		 CHAR(50),
       cod_recur           CHAR(20),
			 gru_maquina   		 CHAR(50),
			 ciclo_padrao  		 DECIMAL(9,0),
	         qtd_cavidades 		 DECIMAL(9,0),
			 pontos_peca   		 DECIMAL(3,0),
			 dat_ini       		 DATETIME YEAR TO SECOND,
			 dat_entrega         DATETIME YEAR TO SECOND,
			 qtd_pecas_planejada DECIMAL(10,3),
			 qtd_pecas_planej_ponto  CHAR(10),      # este campo � o mesmo campo da quantidade s� que editado para ter ponto no lugar da virgula
			 qtd_op        		 DECIMAL(2,0),
			 cod_roteiro         LIKE ordens.cod_roteiro,
             num_altern_roteiro  LIKE ordens.num_altern_roteiro,
			 pes_unit		     LIKE item.pes_unit,
			 op1                 DECIMAL(9,0),
			 op2                 DECIMAL(9,0),
			 op3                 DECIMAL(9,0),
			 op4                 DECIMAL(9,0),
			 op5                 DECIMAL(9,0),
			 op6                 DECIMAL(9,0),
			 op7                 DECIMAL(9,0),
			 op8                 DECIMAL(9,0),
			 op9                 DECIMAL(9,0),
			 op10                DECIMAL(9,0)
   END RECORD
		  
END GLOBALS

DEFINE m_cod_operac        CHAR(05),
       m_cod_maquina       CHAR(15),
       m_ies_apontamento   CHAR(01)

DEFINE m_cod_roteiro         LIKE item_man.cod_roteiro,
       m_num_altern_roteiro	 LIKE item_man.num_altern_roteiro,
       m_dat_liberac         LIKE ordens.dat_liberac



MAIN
     CALL log0180_conecta_usuario()
     LET p_versao = 'pol1131-10.02.35'
     WHENEVER ANY ERROR CONTINUE

#     CALL log1400_isolation()
     SET ISOLATION TO DIRTY READ
     SET LOCK MODE TO WAIT 120

     WHENEVER ANY ERROR STOP

     DEFER INTERRUPT

     CALL log140_procura_caminho("pol.iem") RETURNING m_caminho



     OPTIONS
         PREVIOUS KEY control-b,
         NEXT     KEY control-f,
         INSERT   KEY control-i,
         DELETE   KEY control-e,
         HELP    FILE m_caminho


     CALL log001_acessa_usuario("ESPEC999","")
          RETURNING p_status, p_cod_empresa, p_user
     
     IF  p_status = 0 THEN
         CALL pol1131_controle()
     END IF
 END MAIN

#--------------------------#
 FUNCTION pol1131_controle()
#--------------------------#

   CALL log006_exibe_teclas('01', p_versao)
   CALL log130_procura_caminho("pol1131") RETURNING m_caminho

   OPEN WINDOW w_pol1131 AT 2,2  WITH FORM  m_caminho 
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)




   
   CURRENT WINDOW IS w_pol1131
   DISPLAY p_cod_empresa TO cod_empresa           
            
   MENU 'OPCAO'
       COMMAND 'Exportar' 'Exporta as Ordens e Produtos p/ Sistema pw1.'
           HELP 001
           MESSAGE ''
           IF log005_seguranca(p_user, 'VDP', 'pol1131', 'IN') THEN
              CALL pol1131_exportar()
           END IF
       COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol1131_sobre()       
       COMMAND KEY ("!")
           PROMPT "Digite o comando : " FOR m_comando
           RUN m_comando

       COMMAND 'Fim'       'Retorna ao menu anterior.'
           HELP 008
           EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1131

END FUNCTION

#--------------------------#
 FUNCTION pol1131_exportar()
#--------------------------# 
   DEFINE l_ver_sincr1           CHAR(100),
          l_ver_sincr2           SMALLINT  
      
   INITIALIZE p_caminho TO NULL
   
   SELECT nom_caminho,
          cod_operac,
          cod_maquina
		  INTO w_caminho,
		       m_cod_operac,
		       m_cod_maquina
     FROM pct_ajust_man912
    WHERE cod_empresa = p_cod_empresa
   
   IF m_cod_operac IS NULL THEN
      LET m_cod_operac =  ' '
   END IF

   IF m_cod_maquina IS NULL THEN
      LET m_cod_maquina =  ' '
   END IF
   
   CALL log085_transacao("BEGIN")

   IF NOT pol1131_cria_temps() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN
   END IF

   IF pol1131_le_ordens() THEN
      CALL log085_transacao("COMMIT")
      IF pol1131_exporta_ordens() THEN
      END IF
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF
   
END FUNCTION 

#----------------------------#
FUNCTION pol1131_cria_temps()
#----------------------------#

   WHENEVER ERROR CONTINUE
   
   DROP TABLE ord_oper_temp;

   CREATE TEMP TABLE ord_oper_temp
   (
      num_ordem  			INTEGER,
	  cod_operac 			CHAR(20),      # cod. opera��o do pw1
	  num_seq_operac        DECIMAL(3,0),
      cod_item   			CHAR(15),
	  den_item   			CHAR(50),
	  den_cliente 			CHAR(50),
	  cod_recur  			CHAR(20),
	  gru_maquina   		CHAR(50), 
	  ciclo_padrao  		DECIMAL(9,0),
	  qtd_cavidades 		DECIMAL(9,0),
	  pontos_peca   		DECIMAL(3,0),
	  dat_ini       		DATETIME YEAR TO SECOND,
	  dat_entrega     		DATETIME YEAR TO SECOND,
      qtd_pecas_planejada  	DECIMAL(10,3),
	  qtd_op        		DECIMAL(2,0),
	  op1  	        		INTEGER,
	  op2  	        		INTEGER,
	  op3  	        		INTEGER,
	  op4  	        		INTEGER,
	  op5  	        		INTEGER,
	  op6  	        		INTEGER,
	  op7  	        		INTEGER,
	  op8  	        		INTEGER,
	  op9  	        		INTEGER,
	  op10 	        		INTEGER
   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","ord_oper_temp")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
 FUNCTION pol1131_le_ordens()
#--------------------------------#
   
   DEFINE     l_qtd_planej   LIKE ord_oper.qtd_planejada,
			        l_qtd_boas     LIKE ord_oper.qtd_boas,
              l_qtd_refugo   LIKE ord_oper.qtd_refugo,
              l_qtd_sucata   LIKE ord_oper.qtd_sucata,
              l_qtd_apont    LIKE ord_oper.qtd_planejada,
              l_num_ordem    CHAR(09),
			  l_oper_final   LIKE ord_oper.ies_oper_final,
			  p_dat_entrega  DATE,
			  p_dat_hoje     CHAR(10),
			  l_pecas_conjugadas INTEGER,
			  l_cod_peca_princ LIKE peca_geme_man912.cod_peca_princ,
			  l_pecas_hora	LIKE consumo.qtd_pecas_ciclo,
			  l_ind   		 SMALLINT,
			  l_ind2   		 SMALLINT,
			  l_count        INTEGER,
			  l_id_registro  INTEGER,
			  l_op_conjugada INTEGER
		 

   MESSAGE "Aguarde!...    Lendo Ordens. " ATTRIBUTE(REVERSE)  
 
   LET p_dat_hoje = TODAY
   LET p_dat_hoje[1] = '0'
   LET p_dat_hoje[2] = '1'
   LET p_dat_entrega = p_dat_hoje
   
       INITIALIZE lr_dados_ordem.*   TO NULL

   DECLARE cq_dados_op CURSOR FOR 
    SELECT a.num_ordem, 
        a.cod_item,
        a.cod_roteiro,
        a.num_altern_roteiro,
 		    a.dat_liberac,
		    a.dat_entrega,
		    a.qtd_planej
   FROM ordens a
  WHERE (a.cod_empresa = p_cod_empresa
    AND  a.ies_situa   in( '3', '4') 
    #AND  a.dat_entrega >= p_dat_entrega   #Ivo 01/06/11
    AND (a.qtd_planej - a.qtd_boas - a.qtd_refug - a.qtd_sucata) > 0) #Ivo 07/06/11
    ORDER BY num_ordem

   FOREACH cq_dados_op INTO 
          lr_dados_ordem.num_ordem,
          lr_dados_ordem.cod_item,
          lr_dados_ordem.cod_roteiro,
          lr_dados_ordem.num_altern_roteiro,
				  lr_dados_ordem.dat_ini,
					lr_dados_ordem.dat_entrega,
					lr_dados_ordem.qtd_pecas_planejada

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("LEITURA","ordens")
         RETURN FALSE
      END IF
      
      LET m_dat_liberac = lr_dados_ordem.dat_ini
      
      SELECT den_item[1,50], 
		      pes_unit,
		      ies_apontamento
	   INTO lr_dados_ordem.den_item,    
          lr_dados_ordem.pes_unit,
          m_ies_apontamento
     FROM item, item_man 
    WHERE item.cod_item     	= lr_dados_ordem.cod_item
      AND item.cod_empresa  	= p_cod_empresa
      AND item_man.cod_empresa  	= item.cod_empresa
      AND item_man.cod_item  	= item.cod_item

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("LEITURA","item")
      RETURN FALSE
	 END IF
    	
	 FOR l_ind = 1 TO 50	
		   IF (lr_dados_ordem.den_item[l_ind]  = "'")  OR 
	   	    (lr_dados_ordem.den_item[l_ind]  = '"') THEN 
			    LET lr_dados_ordem.den_item[l_ind]  = ' '
		   END IF 
	 END FOR	
	
		LET lr_dados_ordem.den_cliente = 'CLIENTE NAO IDENTIFICADO' 	 
		
		DECLARE cq_cli_item CURSOR FOR
				SELECT 	b.nom_cliente 
				FROM  	cliente_item a, clientes b
				WHERE  a.cod_cliente_matriz = b.cod_cliente 
				AND    a.cod_item= lr_dados_ordem.cod_item
		  
   
		FOREACH cq_cli_item INTO lr_dados_ordem.den_cliente
	
			FOR l_ind2 = 1 TO 50	
				IF 	(lr_dados_ordem.den_cliente[l_ind2]  = "'")  OR 
					(lr_dados_ordem.den_cliente[l_ind2]  = '"') THEN 
					LET lr_dados_ordem.den_cliente[l_ind2]  = ' '
				END IF 
			END FOR	
		
			EXIT FOREACH
			
		END FOREACH 
		
		IF SQLCA.SQLCODE <> 0 THEN 
		    LET lr_dados_ordem.den_cliente = 'CLIENTE NAO IDENTIFICADO'
			  CONTINUE FOREACH
		END IF

				
	 #-------Ivo 20/03/2018------#
	 
	 IF m_ies_apontamento = '2' THEN
	 
	    LET lr_dados_ordem.cod_recur = m_cod_maquina
      LET lr_dados_ordem.qtd_op = 1
      LET lr_dados_ordem.cod_operac = m_cod_operac
      LET lr_dados_ordem.num_seq_operac = ' '
      LET lr_dados_ordem.ciclo_padrao = 10000 
           
      IF NOT pol1331_ins_op_temp() THEN
         RETURN FALSE
      END IF				
	    
	    CONTINUE FOREACH
	    
	 END IF
	 
   #--------------------------#
   
   LET l_num_ordem = lr_dados_ordem.num_ordem USING '&&&&&&&&&'
	 INITIALIZE ies_oper_final  TO NULL
   
      DECLARE cq_operacoes CURSOR FOR                  
       SELECT trim(cod_operac), 
              num_seq_operac, 
              cod_arranjo,
              qtd_planejada,
              qtd_boas,
              qtd_refugo,
              qtd_sucata,
			        ies_oper_final
         FROM ord_oper
        WHERE cod_empresa      = p_cod_empresa
          AND num_ordem        = lr_dados_ordem.num_ordem
          AND ies_apontamento <> 'F'
        ORDER BY num_seq_operac
      
      FOREACH cq_operacoes INTO 
              lr_dados_ordem.cod_operac,
              lr_dados_ordem.num_seq_operac,
              l_cod_arranjo,
              l_qtd_planej,
              l_qtd_boas,
              l_qtd_refugo,
              l_qtd_sucata,
			        l_oper_final
  
         IF STATUS <> 0 THEN
    		     CALL log003_err_sql("FOREACH","cq_operacoes")
    		     RETURN FALSE
    		  END IF
		 
         LET l_qtd_apont = l_qtd_boas + l_qtd_refugo + l_qtd_sucata
         LET lr_dados_ordem.qtd_pecas_planejada = l_qtd_planej  
         
         IF lr_dados_ordem.qtd_pecas_planejada <= 0 THEN
            CONTINUE FOREACH
         END IF
    
         IF NOT pol1131_le_recurso() THEN
            RETURN FALSE
         END IF
    
	
	LET l_id_registro = 0 
	
	SELECT    id_registro,
			  qtd_ciclos_peca,                         
	          qtd_pecas_ciclo                          
	  INTO    l_id_registro,
			  lr_dados_ordem.pontos_peca,  
       		  lr_dados_ordem.qtd_cavidades                          
	      FROM conjuga_ops_912                        
	     WHERE cod_empresa 	  = p_cod_empresa          
	       AND num_ordem  	  = lr_dados_ordem.num_ordem   
	       AND num_seq_operac = lr_dados_ordem.num_seq_operac     
	 	  
	IF STATUS <> 0 THEN
		LET lr_dados_ordem.qtd_cavidades = 1
		LET lr_dados_ordem.pontos_peca   = 0
	END IF 
    
       ##- RELACIONA PECAS CONJUGADAS S� PODEM CONJUGAR 10 OPS, O PROGRAMA POL1129 QUE � ONDE SE FAZ A CONJUFA��O N�O PERMITE MAIS DO QUE 10 oPS 
    
    LET l_pecas_conjugadas = 0
	LET l_op_conjugada = 0 
	INITIALIZE l_cod_peca_princ,
                lr_dados_ordem.op1,
                lr_dados_ordem.op2,
                lr_dados_ordem.op3,
                lr_dados_ordem.op4,
                lr_dados_ordem.op5,
                lr_dados_ordem.op6,
                lr_dados_ordem.op7,
                lr_dados_ordem.op8,
                lr_dados_ordem.op9,
                lr_dados_ordem.op10
				TO NULL 
	
			DECLARE cq_ops_conjug CURSOR FOR     
			SELECT a.num_ordem	       
			FROM conjuga_ops_912 a, ord_oper b                    
			WHERE a.cod_empresa 	  = p_cod_empresa          
			  AND a.id_registro 	  = l_id_registro  
			  AND a.num_ordem       <>  lr_dados_ordem.num_ordem    
			  AND a.cod_empresa   	  = b.cod_empresa
			  AND a.num_ordem		  = b.num_ordem
			  AND a.num_seq_operac    = b.num_seq_operac
              AND ((b.qtd_planejada - b.qtd_boas - b.qtd_refugo - b.qtd_sucata) > 0)
		      AND a.num_ordem in(SELECT num_ordem
									FROM ordens
									WHERE cod_empresa = p_cod_empresa 
									AND  ies_situa   in( '3', '4'))	  
			   
			FOREACH cq_ops_conjug INTO l_op_conjugada
		 
		        LET l_pecas_conjugadas = l_pecas_conjugadas  + 1
		 
				    IF l_pecas_conjugadas = 1 THEN
					   LET  lr_dados_ordem.op1 =  l_op_conjugada
					   CONTINUE FOREACH
				    END IF 
					
					IF l_pecas_conjugadas = 2 THEN
					   LET  lr_dados_ordem.op2 =  l_op_conjugada
					   CONTINUE FOREACH
				    END IF 
					
					IF l_pecas_conjugadas = 3 THEN
					   LET  lr_dados_ordem.op3 =  l_op_conjugada
					   CONTINUE FOREACH
				    END IF 
					
					IF l_pecas_conjugadas = 4 THEN
					   LET  lr_dados_ordem.op4 =  l_op_conjugada
					   CONTINUE FOREACH
				    END IF 
					
					IF l_pecas_conjugadas = 5 THEN
					   LET  lr_dados_ordem.op5 =  l_op_conjugada
					   CONTINUE FOREACH
				    END IF 
					
					IF l_pecas_conjugadas = 6 THEN
					   LET  lr_dados_ordem.op6 =  l_op_conjugada
					   CONTINUE FOREACH
				    END IF 
					
					IF l_pecas_conjugadas = 7 THEN
					   LET  lr_dados_ordem.op7 =  l_op_conjugada
					   CONTINUE FOREACH
				    END IF 
					
					IF l_pecas_conjugadas = 8 THEN
					   LET  lr_dados_ordem.op8 =  l_op_conjugada
					   CONTINUE FOREACH
				    END IF 
					
					IF l_pecas_conjugadas = 9 THEN
					   LET  lr_dados_ordem.op9 =  l_op_conjugada
					   CONTINUE FOREACH
				    END IF 
					
					IF l_pecas_conjugadas = 10 THEN
					   LET  lr_dados_ordem.op10 =  l_op_conjugada
					   CONTINUE FOREACH
				    END IF 
					
					IF l_pecas_conjugadas > 10 THEN
					   LET  l_pecas_conjugadas =  10
					   EXIT FOREACH 
				    END IF 				  					
			
			END FOREACH 		
    
	    LET lr_dados_ordem.qtd_op   = l_pecas_conjugadas + 1
         
         SELECT dat_ini_planejada
           INTO p_dat_ini
           FROM man_oper_compl
          WHERE empresa            = p_cod_empresa
            AND ordem_producao     = lr_dados_ordem.num_ordem
            AND operacao           = lr_dados_ordem.cod_operac
            AND sequencia_operacao = lr_dados_ordem.num_seq_operac
            
         IF STATUS <> 0 THEN
	     ELSE		
			LET lr_dados_ordem.dat_ini = p_dat_ini
         END IF
         
         LET p_tmp_ciclo  = 0
		 LET l_pecas_hora = 0
		 
         SELECT qtd_horas,
				qtd_pecas_ciclo
           INTO p_tmp_ciclo,
		        l_pecas_hora
           FROM consumo
          WHERE cod_empresa        = p_cod_empresa
            AND cod_item           = lr_dados_ordem.cod_item
            AND cod_roteiro        = lr_dados_ordem.cod_roteiro
            AND num_altern_roteiro = lr_dados_ordem.num_altern_roteiro
            AND num_seq_operac     = lr_dados_ordem.num_seq_operac
       
         IF STATUS <> 0 THEN
            LET p_tmp_ciclo = 0
			      LET l_pecas_hora = 1
         END IF
		 
		 IF l_pecas_hora <= 0 THEN 
			  LET lr_dados_ordem.ciclo_padrao = 10000 
	   ELSE
			  LET lr_dados_ordem.ciclo_padrao = (3600000 / l_pecas_hora) 
     END IF

     IF NOT pol1331_ins_op_temp() THEN
        RETURN FALSE
     END IF				

                                
      END FOREACH
      

   END FOREACH 
            ERROR '                          ' 
   RETURN TRUE

END FUNCTION 

#-----------------------------#
FUNCTION pol1331_ins_op_temp()#
#-----------------------------#


         INSERT INTO ord_oper_temp
            VALUES(lr_dados_ordem.num_ordem,
			       lr_dados_ordem.cod_operac,
				   lr_dados_ordem.num_seq_operac,
                   lr_dados_ordem.cod_item,
				   lr_dados_ordem.den_item,
				   lr_dados_ordem.den_cliente,
				   lr_dados_ordem.cod_recur,
				   lr_dados_ordem.gru_maquina,
                   lr_dados_ordem.ciclo_padrao,
				   lr_dados_ordem.qtd_cavidades,
				   lr_dados_ordem.pontos_peca,
				   lr_dados_ordem.dat_ini,
				   lr_dados_ordem.dat_entrega,
				   lr_dados_ordem.qtd_pecas_planejada,
				   lr_dados_ordem.qtd_op,
				   lr_dados_ordem.op1,
				   lr_dados_ordem.op2,
				   lr_dados_ordem.op3,
				   lr_dados_ordem.op4,
				   lr_dados_ordem.op5,
				   lr_dados_ordem.op6,
				   lr_dados_ordem.op7,
				   lr_dados_ordem.op8,
				   lr_dados_ordem.op9,
				   lr_dados_ordem.op10)

         IF STATUS <> 0 THEN
            CALL log003_err_sql("INCLUS�O","ord_oper_temp")
            RETURN FALSE
         END IF
         

         ERROR 'Ordem: ', lr_dados_ordem.num_ordem

   RETURN TRUE
END FUNCTION


#--------------------------------#
FUNCTION pol1131_exporta_ordens()
#--------------------------------#

   SELECT COUNT(num_ordem)
     INTO l_cont
     FROM ord_oper_temp
     
   IF l_cont = 0 THEN
      ERROR 'N�o h� Ordens p/ Exportar... Opera��o Cancelada!!!'
      RETURN FALSE
   END IF
   
   LET p_data_arquivo = TODAY
   LET p_hora_arquivo = TIME
   LET p_data_arq = p_data_arquivo
   LET p_hora_arq = p_hora_arquivo  
   
   LET p_data_rem = p_data_arq[1,2],  p_data_arq[4,5], p_data_arq[7,10]
   LET p_hora_rem = p_hora_arq[1,2],  p_hora_arq[4,5], p_hora_arq[7,8]
   
   LET p_compl = 'PW1OP',p_data_rem,p_hora_rem,'.csv'
   INITIALIZE p_caminho TO NULL
   LET p_caminho = w_caminho CLIPPED
   LET p_caminho = p_caminho CLIPPED, p_compl
    
   INITIALIZE lr_dados_ordem.* TO NULL
   LET p_ponto_virgula =";"
   LET p_cabecalho = 0

   START REPORT pol1131_relat_ordem TO p_caminho 

    LET l_cont = FALSE
   
   DECLARE cq_imp_ord CURSOR FOR
    SELECT   
       num_ordem,
			 cod_operac,
			 num_seq_operac,
       cod_item,
			 den_item,
			 den_cliente,
       cod_recur,
			 gru_maquina,
			 ciclo_padrao,
	         qtd_cavidades,
			 pontos_peca,
			 dat_ini,
			 dat_entrega,
			 qtd_pecas_planejada,
			 qtd_op,
			 op1,
			 op2,
			 op3,
			 op4,
			 op5,
			 op6,
			 op7,
			 op8,
			 op9,
			 op10
      FROM ord_oper_temp
     ORDER BY cod_recur, num_ordem, dat_ini     
              
   FOREACH cq_imp_ord INTO
			 lr_dados_ordem.num_ordem,
			 lr_dados_ordem.cod_operac,
			 lr_dados_ordem.num_seq_operac,
             lr_dados_ordem.cod_item,
			 lr_dados_ordem.den_item,
			 lr_dados_ordem.den_cliente,
             lr_dados_ordem.cod_recur,
			 lr_dados_ordem.gru_maquina,
			 lr_dados_ordem.ciclo_padrao,
	         lr_dados_ordem.qtd_cavidades,
			 lr_dados_ordem.pontos_peca,
			 lr_dados_ordem.dat_ini,
			 lr_dados_ordem.dat_entrega,
			 lr_dados_ordem.qtd_pecas_planejada,
			 lr_dados_ordem.qtd_op,
			 lr_dados_ordem.op1,
			 lr_dados_ordem.op2,
			 lr_dados_ordem.op3,
			 lr_dados_ordem.op4,
			 lr_dados_ordem.op5,
			 lr_dados_ordem.op6,
			 lr_dados_ordem.op7,
			 lr_dados_ordem.op8,
			 lr_dados_ordem.op9,
			 lr_dados_ordem.op10
      
	  LET lr_dados_ordem.qtd_pecas_planej_ponto = lr_dados_ordem.qtd_pecas_planejada
    LET lr_dados_ordem.qtd_pecas_planej_ponto[LENGTH(lr_dados_ordem.qtd_pecas_planej_ponto)-3] = '.'
	  
      ERROR 'Ordem: ', lr_dados_ordem.num_ordem
      
      LET p_pc_por_oper = 0
      LET p_pc_hora = 0

      OUTPUT TO REPORT pol1131_relat_ordem(lr_dados_ordem.cod_recur)
      LET l_cont = TRUE
      
   END FOREACH
   
   FINISH REPORT pol1131_relat_ordem
   LET p_men = 'Arquivo exportado com sucesso: ',p_caminho CLIPPED
   MESSAGE "                                    " ATTRIBUTE(REVERSE)  
   CALL log0030_mensagem(p_men,"orientation")
   ERROR 'Processamento efetuado com sucesso!!!'
   MESSAGE "                          " ATTRIBUTE(REVERSE)  
   

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 REPORT pol1131_relat_ordem(p_cod_recur)
#---------------------------------------#

   DEFINE p_cod_recur CHAR(20)
        
                                 
   OUTPUT LEFT   MARGIN 0  
          TOP    MARGIN 0  
          BOTTOM MARGIN 0  
          PAGE   LENGTH 1

      ORDER EXTERNAL BY p_cod_recur
      
   FORMAT 
   
      BEFORE GROUP OF p_cod_recur
      
      ON EVERY ROW 
       IF p_cabecalho = 0 THEN   
         PRINT COLUMN 001, "ordem_producao;operacao;codigo_produto;desc_produto;nome_cliente;codigo_maquina;grupo_maquina;ciclo_padrao;qtd_cavidades;pontos_peca;data_hora_inicio;data_hora_entrega;qtd_pecas_planejada;qtd_op;op01;op02;op03;op04;op05;op06;op07;op08;op09;op10;"         
         PRINT COLUMN 001, lr_dados_ordem.num_ordem CLIPPED, ";", 
		      lr_dados_ordem.num_seq_operac CLIPPED, ";",  
			    lr_dados_ordem.cod_item CLIPPED, ";", 
			    lr_dados_ordem.den_item CLIPPED, ";", 
			    lr_dados_ordem.den_cliente CLIPPED,";", 
				  lr_dados_ordem.cod_recur CLIPPED,";", 
			    " ;", 
			    lr_dados_ordem.ciclo_padrao CLIPPED, ";", 	
			    lr_dados_ordem.qtd_cavidades CLIPPED, ";", 
			    lr_dados_ordem.pontos_peca CLIPPED, ";", 
			    lr_dados_ordem.dat_ini CLIPPED, ";", 
				  lr_dados_ordem.dat_entrega CLIPPED, ";", 
			    lr_dados_ordem.qtd_pecas_planej_ponto CLIPPED, ";",    
			    lr_dados_ordem.qtd_op CLIPPED, ";",
				lr_dados_ordem.op1  CLIPPED, ";",
				lr_dados_ordem.op2  CLIPPED, ";",
				lr_dados_ordem.op3  CLIPPED, ";",
				lr_dados_ordem.op4  CLIPPED, ";",
				lr_dados_ordem.op5  CLIPPED, ";",
				lr_dados_ordem.op6  CLIPPED, ";",
				lr_dados_ordem.op7  CLIPPED, ";",
				lr_dados_ordem.op8  CLIPPED, ";",
				lr_dados_ordem.op9  CLIPPED, ";",
				lr_dados_ordem.op10 CLIPPED, ";"
		ELSE
		    PRINT COLUMN 001, lr_dados_ordem.num_ordem CLIPPED, ";", 
		        lr_dados_ordem.num_seq_operac  CLIPPED, ";",  
			    lr_dados_ordem.cod_item CLIPPED, ";", 
			    lr_dados_ordem.den_item CLIPPED, ";", 
			    lr_dados_ordem.den_cliente CLIPPED,";", 
				lr_dados_ordem.cod_recur CLIPPED,";", 
			    " ;", 	
			    lr_dados_ordem.ciclo_padrao CLIPPED, ";", 	
			    lr_dados_ordem.qtd_cavidades CLIPPED, ";", 
			    lr_dados_ordem.pontos_peca CLIPPED, ";", 
			    lr_dados_ordem.dat_ini CLIPPED, ";", 
				lr_dados_ordem.dat_entrega CLIPPED, ";", 
			    lr_dados_ordem.qtd_pecas_planej_ponto CLIPPED, ";",     
			    lr_dados_ordem.qtd_op CLIPPED, ";",
				lr_dados_ordem.op1  CLIPPED, ";",
				lr_dados_ordem.op2  CLIPPED, ";",
				lr_dados_ordem.op3  CLIPPED, ";",
				lr_dados_ordem.op4  CLIPPED, ";",
				lr_dados_ordem.op5  CLIPPED, ";",
				lr_dados_ordem.op6  CLIPPED, ";",
				lr_dados_ordem.op7  CLIPPED, ";",
				lr_dados_ordem.op8  CLIPPED, ";",
				lr_dados_ordem.op9  CLIPPED, ";",
				lr_dados_ordem.op10 CLIPPED, ";"
		END IF 
		LET p_cabecalho = 1   
END REPORT                  

#-----------------------#
 FUNCTION pol1131_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1131_le_recurso()#
#----------------------------#

   DEFINE l_cod_recur     LIKE recurso.cod_recur,
			    l_ies_tip_recur LIKE recurso.ies_tip_recur

	 INITIALIZE lr_dados_ordem.cod_recur  TO NULL 
	  
   DECLARE cq_recurso CURSOR FOR  	
    SELECT a.cod_recur
      FROM rec_arranjo a
     WHERE a.cod_empresa = p_cod_empresa
       AND a.cod_arranjo = l_cod_arranjo
       AND a.cod_recur IN
           (SELECT b.cod_recur FROM recurso b
             WHERE b.cod_empresa   = a.cod_empresa
               AND b.cod_recur     = a.cod_recur
               AND b.ies_tip_recur in ('1','2') )
     	 
   FOREACH cq_recurso INTO l_cod_recur
          
      IF STATUS <> 0 THEN
         CALL log003_err_sql("FOREACH","cq_recurso")
    	   RETURN FALSE
      END IF	           	           
	        
	    LET lr_dados_ordem.cod_recur = l_cod_recur
	           
	    SELECT ies_tip_recur INTO l_ies_tip_recur
	      FROM recurso
	     WHERE cod_empresa = p_cod_empresa
	       AND cod_recur = l_cod_recur
             
      IF l_ies_tip_recur = '2' THEN	              
	       EXIT FOREACH
	    END IF
	           
	 END FOREACH 	
	       
	 IF lr_dados_ordem.cod_recur IS NULL THEN
	    LET lr_dados_ordem.cod_recur = ' '
	 END IF

   RETURN TRUE

END FUNCTION

   