#-------------------------------------------------------------------#
# PROGRAMA: pol1223                                                 #
# OBJETIVO: ENVIO DE PROGRAMAÇÃO DE COMPRA DA POLIMETRI PARA FORD   #
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
          p_tem_nota            SMALLINT,
          sc_curr               SMALLINT,
          g_usa_visualizador    SMALLINT,
          p_den_item40          CHAR(40),
          p_y_saldo    		      DECIMAL(15,3),
		      P_y_qtd_estoq_seg     DECIMAL(10,3),
		      p_pct_refugo          LIKE item_edi_454.pct_refugo,
		      p_num_ped_cli         CHAR(12),
		      p_cod_item_cli         LIKE item_edi_454.cod_item_cli,
		      p_contato             LIKE item_edi_454.contato,
          x_saldo               LIKE estoque_lote.qtd_saldo,
          x_cod_item            LIKE estoque_lote.cod_item,
          l_pedido              INTEGER,
		      l_num_sequencia       LIKE ped_itens.num_sequencia,
		      l_cod_item            LIKE ped_itens.cod_item,		  
		      l_cod_fornecedor      LIKE fornecedor.cod_fornecedor,
		      l_saldo               LIKE ped_itens.qtd_pecas_solic, 
		      l_prz_entrega         LIKE ped_itens.prz_entrega,
		      x_qtd_estoq_seg       LIKE item_man.qtd_estoq_seg,
		      y_saldo    		        LIKE estoque_lote.qtd_saldo,
          y_cod_item     	      LIKE estoque_lote.cod_item,
		      p_msg                 CHAR(300),
	     	  p_cabeca_imp			    SMALLINT,
	     	  p_index               SMALLINT

   #Ivo 02/08/2011
   DEFINE p_qtd_saldo           DECIMAL(10,3),
          p_qtd_descontar       DECIMAL(10,3)
   #---Até aqui---------#
		  
   DEFINE p_cod_item           LIKE item.cod_item,
          p_dat_entrega        DATE,
		      p_num_pedido         LIKE pedidos.num_pedido, 
		      p_num_sequencia      LIKE ped_itens.num_sequencia, 
		      p_cod_fornecedor     LIKE fornecedor.cod_fornecedor,
          p_cod_compon         LIKE item.cod_item,
          p_cod_item_pai       LIKE item.cod_item,
          p_den_item_reduz     LIKE item.den_item_reduz,
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
		      p_num_processo       INTEGER,
		      p_num_pc             INTEGER

    DEFINE p_dat_niv           RECORD
          dat_refer            DATE,
          des_item             CHAR(01),
          cod_nivel            DECIMAL(2,0)
    END RECORD
		  

	DEFINE p_compon RECORD 
	      num_pedido     DECIMAL(6,0),
		  num_sequencia  DECIMAL(5,0),
		  cod_fornecedor    CHAR(15), 
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
		  cod_fornecedor    CHAR(15),
		  cod_item       CHAR(15),
		  qtd_saldo      DECIMAL(14,7),
		  prz_entrega    DATE
	END RECORD	
	
END GLOBALS
   
   DEFINE m_count             SMALLINT,
          m_tip_relat         CHAR(1) 

   DEFINE p_tela          RECORD 
      dat_inicio          DATE,
      dat_final           DATE
   END RECORD 

   DEFINE pr_fornec       ARRAY[100] OF RECORD 
      cod_fornecedor      LIKE fornecedor.cod_fornecedor,
      raz_social          LIKE fornecedor.raz_social,
      ies_enviar          CHAR(01)
   END RECORD 
   

   DEFINE pr_fornec3 ARRAY[100] OF RECORD 
      cod_item                LIKE item.cod_item,
      den_item                LIKE item.den_item_reduz,
      prz_entrega             DATE,
      saldo                   DECIMAL(9,0) 
   END RECORD 

   DEFINE p_prog RECORD 
       pedido                 INTEGER,
       cod_fornecedor         CHAR(15),
       cod_item               CHAR(15),
	     num_sequencia          DECIMAL(5,0),
       prz_entrega            DATE,
       saldo                  DECIMAL(18,7),
       cod_item_cli            CHAR(30),
       num_ped_cli             CHAR(12)
   END RECORD   

   DEFINE p_nome_caminho CHAR(90)

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "pol1223-10.02.14"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1223.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL pol1223_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1223_controle()
#--------------------------#
   DEFINE l_informou_dados     SMALLINT,
          l_imprime            SMALLINT

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1223") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1223 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
 
   LET l_informou_dados   = FALSE
   LET l_imprime          = FALSE
   LET g_usa_visualizador = TRUE
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa Parâmetros para Gerar Programação."
         MESSAGE ""
         IF pol1223_informa_dados() THEN
            IF pol1223_mostra_fornecedor() THEN
               ERROR 'Operação efetuada com sucesso.'
               LET l_informou_dados = TRUE
               NEXT OPTION "Processar"
            ELSE
               ERROR 'Operação cancelada.'
            END IF 
         ELSE
            ERROR 'Operação cancelada.'
         END IF
      COMMAND "Processar" "Efetua Processamento para Gerar a Programação."
         MESSAGE ""
         IF l_informou_dados THEN
            LET l_informou_dados = FALSE
            IF pol1223_processa()  THEN 
               LET l_imprime = TRUE
               MESSAGE ''
               ERROR 'Processamento efetuado com sucesso.'
               NEXT OPTION "Gerar EDI" 
				    ELSE  
				       ERROR "Processamento Cancelado, verificar erro"
               NEXT OPTION "Informar"
				    END IF
         ELSE
            ERROR "Informe os parâmetros primeiramente."
            NEXT OPTION "Informar"
         END IF  
      COMMAND KEY ('G') "Gerar EDI" "Gera Arquivo EDI da programação de materiais."
         IF l_imprime THEN
            IF pol1223_gera_arquivo() THEN
               NEXT OPTION "Listar"
			      ELSE   
				       ERROR "Processamento Cancelado, verificar erro"
               NEXT OPTION "Gerar EDI"
			      END IF
         ELSE
            ERROR "Informe os parâmetros primeiramente."
            NEXT OPTION "Informar"
         END IF   
      COMMAND "Listar" "Imprime Relatório da Programação."
         IF l_imprime THEN
            CALL pol1223_imprime_relat()
         ELSE
            ERROR "Informe os Parâmetros e Efetue o Processamento."
            NEXT OPTION "Informar"
         END IF   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1223_sobre()
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

   CLOSE WINDOW w_pol1223

END FUNCTION

#-----------------------#
 FUNCTION pol1223_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               "ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     GrupoAceex\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

  CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
 
#-------------------------------#
 FUNCTION pol1223_informa_dados()
#-------------------------------#

   INITIALIZE p_tela.* TO NULL
   LET p_houve_erro = FALSE

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG =  FALSE

   INPUT BY NAME p_tela.*  WITHOUT DEFAULTS  

      AFTER FIELD dat_inicio 

         IF p_tela.dat_inicio IS NULL OR
            p_tela.dat_inicio = ' ' THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD dat_inicio 
         END IF
    
      AFTER FIELD dat_final 
         IF p_tela.dat_final IS NULL OR
            p_tela.dat_final = ' ' THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD dat_final 
         END IF
      
               
      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF p_tela.dat_inicio IS NULL OR
               p_tela.dat_inicio = ' ' THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD dat_inicio
            END IF
            IF p_tela.dat_final IS NULL OR
               p_tela.dat_final = ' ' THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD dat_final
            END IF
            IF p_tela.dat_final < p_tela.dat_inicio THEN
               ERROR 'Período inválido!'
               NEXT FIELD dat_final
            END IF
         END IF

   END INPUT

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      ERROR "Envio de Programação Cancelada."
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION pol1223_mostra_fornecedor() 
#----------------------------------#

   DEFINE l_ind                 SMALLINT,
          s_ind                 SMALLINT,
          x_cod_fornecedor      CHAR(15),
          p_qtd_linha           INTEGER 

   LET INT_FLAG =  FALSE
   LET l_ind    = 1
   INITIALIZE pr_fornec TO NULL 
 
   DECLARE cq_fornec SCROLL CURSOR WITH HOLD FOR
    SELECT cod_fornecedor
      FROM fornec_edi_454 
   
   FOREACH cq_fornec  INTO x_cod_fornecedor 
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_fornec')
         RETURN FALSE
      END IF
                                
    LET pr_fornec[l_ind].cod_fornecedor = x_cod_fornecedor 
	
     SELECT raz_social 
       INTO pr_fornec[l_ind].raz_social 
       FROM fornecedor
      WHERE cod_fornecedor = x_cod_fornecedor
  
     IF STATUS <> 0 THEN
  		  LET pr_fornec[l_ind].raz_social = ''
     END IF
     
     LET pr_fornec[l_ind].ies_enviar = 'N'
     
     LET l_ind = l_ind + 1 

     IF  l_ind > 100 THEN
	     EXIT FOREACH 
     END IF  		 

   END FOREACH 
   
   LET p_qtd_linha = l_ind - 1
   
   CALL SET_COUNT(l_ind - 1)
   LET INT_FLAG = FALSE
   
   INPUT ARRAY pr_fornec 
      WITHOUT DEFAULTS FROM Sr_fornec.*

      BEFORE ROW
         LET l_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  

      AFTER FIELD ies_enviar
         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
              OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
         ELSE
            IF l_ind >= p_qtd_linha THEN
               NEXT FIELD ies_enviar
            END IF
         END IF

      AFTER INPUT
         IF NOT INT_FLAG THEN
            LET p_count = 0
            FOR p_index = 1 TO ARR_COUNT()
                IF pr_fornec[p_index].ies_enviar = 'S' THEN
                   LET p_count = p_count + 1
                END IF
            END FOR
            IF p_count = 0 THEN
               LET p_msg = 'Selecione ao menos um fornecedor\n para envio de dados.'
               CALL log0030_mensagem(p_msg,'info')
               NEXT FIELD ies_enviar
            END IF
         END IF
         
   END INPUT
   
   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE 

END FUNCTION

#--------------------------#
 FUNCTION pol1223_processa()
#--------------------------#

   MESSAGE "Aguarde! - Processando..." ATTRIBUTE(REVERSE)

   INITIALIZE p_dat_niv TO NULL
   LET p_dat_niv.des_item = 'C'
   LET p_dat_niv.dat_refer = TODAY	  

   IF NOT pol1223_cria_temporaria() THEN 
      RETURN FALSE
   END IF 
   
   IF NOT pol1223_carrega_pedidos() THEN 
      RETURN FALSE
   END IF
 
   IF NOT pol1223_separa_componentes() THEN 
      RETURN FALSE
   END IF 
 
   RETURN TRUE  
       
END FUNCTION

#---------------------------------#
 FUNCTION pol1223_cria_temporaria()
#---------------------------------#

   DROP TABLE w_edi_tmp_454
   CREATE TABLE w_edi_tmp_454 (
       cod_empresa              CHAR(2),
       pedido                   INTEGER,
       cod_item                 CHAR(15),
       cod_fornecedor           CHAR(15),
       saldo                    DECIMAL(18,7),
       num_ped_cli               CHAR(12), 
       cod_item_cli              CHAR(30),
       contato                  CHAR(11),
       prz_entrega              DATE  
      )

   IF STATUS <> 0 THEN
      CALL log003_err_sql("CREATE", "w_edi_tmp_454")
	    RETURN FALSE
   END IF

   DROP TABLE prog_entrega_tmp_454
   CREATE TABLE prog_entrega_tmp_454 (
       pedido                 INTEGER,
       cod_fornecedor         CHAR(15),
       cod_item               CHAR(15),
	     num_sequencia          DECIMAL(5,0),
       prz_entrega            DATE,
       saldo                  DECIMAL(18,7),
       cod_item_cli            CHAR(30),
       num_ped_cli             CHAR(12)
      )                     

   IF STATUS <> 0 THEN
      CALL log003_err_sql("CREATE","prog_entrega_tmp_454")
      RETURN FALSE
   END IF

   DROP TABLE fornec_tmp_454
   CREATE TABLE fornec_tmp_454 (
      cod_fornecedor char(15)
   )

   IF STATUS <> 0 THEN
      CALL log003_err_sql("CREATE","fornec_tmp_454")
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION              

#---------------------------------# 
 FUNCTION pol1223_carrega_pedidos()
#---------------------------------# 

   DEFINE sql_stmt                CHAR(2000),
          l_condicao              CHAR(350),
          l_pedido                INTEGER,
          l_versao                INTEGER,
		      l_num_sequencia         INTEGER,
		      l_saldo                 DECIMAL(10,3),
		      l_cod_fornecedor        CHAR(15),
		      l_prz_entrega           DATE,
		      l_cod_item              CHAR(15),
		      l_cod_item_cli           CHAR(30),
		      l_num_ped_cli            CHAR(12)

   
   FOR p_index = 1 TO ARR_COUNT()
       IF pr_fornec[p_index].ies_enviar = 'S' THEN
          IF pr_fornec[p_index].cod_fornecedor IS NOT NULL THEN
             INSERT INTO fornec_tmp_454
               VALUES(pr_fornec[p_index].cod_fornecedor)
             IF STATUS <> 0 THEN
                CALL log003_err_sql('INSERT','fornec_tmp_454')
                RETURN FALSE
             END IF
          END IF
        END IF
   END FOR
   
   DECLARE cq_ocs CURSOR FOR 
    SELECT o.num_oc,
           o.num_versao,
           o.cod_item,
           o.cod_fornecedor,
           i.cod_item_cli,
           p.num_prog_entrega,         
           p.dat_entrega_prev,     
           o.num_pedido,    
           (p.qtd_solic - p.qtd_recebida)
      FROM ordem_sup o,
           prog_ordem_sup p,
           fornec_tmp_454 f,
           item_edi_454 i
     WHERE o.cod_empresa = p_cod_empresa
       AND o.ies_situa_oc = 'R'
       AND o.ies_versao_atual = 'S'
       AND o.cod_empresa = p.cod_empresa
       AND o.num_oc = p.num_oc
       AND o.num_versao = p.num_versao
       AND p.dat_entrega_prev >= p_tela.dat_inicio
       AND p.dat_entrega_prev <= p_tela.dat_final
       AND p.ies_situa_prog <> 'L'
       AND o.cod_fornecedor = f.cod_fornecedor
       AND o.cod_item = i.cod_item
       AND i.cod_empresa = o.cod_empresa
     ORDER BY o.num_oc, p.dat_entrega_prev

   FOREACH cq_ocs INTO 
      l_pedido, l_versao, l_cod_item, 
      l_cod_fornecedor, l_cod_item_cli, 
      l_num_sequencia, l_prz_entrega, l_num_ped_cli, l_saldo
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("FOREACH","CQ_OCS")
	       RETURN FALSE
      END IF
               
      IF l_saldo > 0 THEN
         INSERT INTO prog_entrega_tmp_454 
         VALUES(l_pedido, 
                l_cod_fornecedor, 
                l_cod_item, 
                l_num_sequencia, 
                l_prz_entrega, 
                l_saldo,
                l_cod_item_cli, 
                l_num_ped_cli)

         IF STATUS <> 0 THEN
            CALL log003_err_sql("INSERT","prog_entrega_tmp_454")
           RETURN FALSE
         END IF
      END IF
      
   END FOREACH  

   RETURN TRUE  

END FUNCTION

#-------------------------------------#
 FUNCTION pol1223_separa_componentes()
#-------------------------------------#
   
   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1223.tmp"
         START REPORT pol1223_detalha TO p_caminho
      ELSE
         START REPORT pol1223_detalha TO p_nom_arquivo
      END IF
   END IF
   
   DECLARE cq_compon CURSOR FOR
    SELECT *
    FROM prog_entrega_tmp_454
   ORDER BY cod_fornecedor, cod_item, prz_entrega
	     
   FOREACH cq_compon  INTO p_prog.*
	
  	  IF STATUS <> 0 THEN
    	   CALL log003_err_sql("FOREACH","CQ_COMPON")
	 	     RETURN FALSE
      END IF	
      
      MESSAGE "Pedido:", p_prog.pedido
		
	    IF NOT pol1223_busca_dados_item(p_prog.cod_item) THEN
       	 RETURN FALSE
      END IF
	  
      INSERT INTO w_edi_tmp_454 
        VALUES  (p_cod_empresa,
                 p_prog.pedido, #ordem de compra
                 p_prog.cod_item,                               
                 p_prog.cod_fornecedor,                            
                 p_prog.saldo,                              
                 p_prog.num_ped_cli,                                    
                 p_prog.cod_item_cli,                                   
                 p_contato,                                       
                 p_prog.prz_entrega)                            

       IF STATUS <> 0 THEN
          CALL log003_err_sql("INCLUSAO","EDI_volksvagen")
		      RETURN FALSE
       END IF
       
       SELECT DISTINCT num_pedido
         INTO p_num_pc  #pedido de compra
         FROM ordem_sup
        WHERE cod_empresa = p_cod_empresa
          AND num_oc = p_prog.pedido
          AND ies_versao_atual = 'S'

       IF STATUS <> 0 THEN
          LET p_num_pc = ''
       END IF
       
       SELECT den_item
         INTO p_den_item40
         FROM item
        WHERE cod_empresa = p_cod_empresa
          AND cod_item = p_prog.cod_item
       
       IF STATUS <> 0 THEN
          LET p_den_item40 = ''
       END IF
        
       OUTPUT TO REPORT pol1223_detalha() 
	   
   END FOREACH

   FINISH REPORT pol1223_detalha

   IF p_ies_impressao = "S" THEN
      LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
      CALL log0030_mensagem(p_msg, 'excla')
      IF g_ies_ambiente = "W" THEN
         LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
         RUN comando
      END IF
   ELSE
      LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
      CALL log0030_mensagem(p_msg, 'exclamation')
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------------------#
 FUNCTION pol1223_busca_dados_item(l_cod_item)
#---------------------------------------------#

   DEFINE l_cod_item     LIKE item.cod_item
   
   SELECT pct_refugo, 
          contato
     INTO p_pct_refugo, 
          p_contato
     FROM item_edi_454
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = l_cod_item
	  						   
    IF STATUS <> 0 THEN
	   CALL log003_err_sql('Lendo','item_edi_454')
       RETURN FALSE
    ELSE
       RETURN TRUE
    END IF

END FUNCTION

#------------------------#
 REPORT pol1223_detalha()                              
#------------------------# 

	DEFINE 	p_ordem_imp				SMALLINT
   
	OUTPUT LEFT   MARGIN 0
	TOP    				MARGIN 0
	BOTTOM 				MARGIN 3
  
	FORMAT
	
	PAGE HEADER
	
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
                           
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 119, "PAG: ", PAGENO USING "###&"
               
         PRINT COLUMN 001, "pol1223",
               COLUMN 041, "DETALHAMENTO DO ARQUIVO PARA EDI",
               COLUMN 101, "DATA: ", TODAY USING "DD/MM/YYYY", " - ", TIME
               
     		 PRINT COLUMN 001, "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT COLUMN 001, "PEDIDO|NUM OC |   COD. ITEM   |  COD. FORNEC   |  SALDO   | PEDIDO CLI|       COD. ITEM CLI          |  CONTATO  | PRZ. ENTREGA" 
         PRINT COLUMN 001, "------|-------|---------------|----------------|----------|-----------|------------------------------|-----------|--------------|----------------------------------------"

	ON EVERY ROW

         PRINT COLUMN 001, p_num_pc USING '&&&&&&', #pedido de compra
               COLUMN 007,'|',
               COLUMN 008, p_prog.pedido USING '&&&&&&&', #ordem de compra
               COLUMN 014,'|',
               COLUMN 015, p_prog.cod_item, 
               COLUMN 030,'|',
               COLUMN 031, p_prog.cod_fornecedor, 
               COLUMN 048,'|',
               COLUMN 049, p_prog.saldo USING '#####&.&&&', 
               COLUMN 059,'|',
             	 COLUMN 060, p_prog.num_ped_cli[1,11], 
               COLUMN 071,'|',
             	 COLUMN 072, p_prog.cod_item_cli, 
               COLUMN 102,'|',
             	 COLUMN 103, p_contato,
               COLUMN 114,'|',
             	 COLUMN 115, p_prog.prz_entrega,
               COLUMN 129,'|',
               COLUMN 130, p_den_item40

             	 
         	PRINT COLUMN 001, "------|-------|---------------|----------------|----------|-----------|------------------------------|-----------|--------------|----------------------------------------"

  
  ON LAST ROW 
  
     LET p_last_row = TRUE

  PAGE TRAILER

       IF p_last_row = TRUE THEN 
          PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
       ELSE 
          PRINT " "
       END IF


END REPORT

#------------------------------#
 FUNCTION pol1223_gera_arquivo()
#------------------------------#
	
   CALL log150_procura_caminho("TXT") RETURNING p_caminho

    DECLARE cq_fornec CURSOR  FOR
 
    SELECT DISTINCT cod_fornecedor
      FROM w_edi_tmp_454
	ORDER BY cod_fornecedor
						   	     
    FOREACH cq_fornec  INTO p_cod_fornecedor
	
  	  IF STATUS <> 0 THEN
    	     CALL log003_err_sql("FOREACH","cq_fornec")
	 	    RETURN FALSE
      END IF	
						       	  
	  IF NOT pol1223_grava_arquivo() THEN
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

#--------------------------------#
 FUNCTION pol1223_grava_arquivo()
#--------------------------------#

   DEFINE l_num_cnpj            CHAR(19),
          l_cnpj_cli             CHAR(19),
          l_dat_hora            CHAR(19)


   MESSAGE " Processando a Extração do Arquivo..." ATTRIBUTE(REVERSE)

   SELECT num_cgc_cpf
     INTO l_num_cnpj
     FROM fornecedor
    WHERE cod_fornecedor = p_cod_fornecedor

   IF STATUS <> 0 THEN
      LET l_num_cnpj = ' '
   END IF

   SELECT num_cgc
     INTO l_cnpj_cli
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
 
   IF STATUS <> 0 THEN
      LET l_cnpj_cli = ' '
   END IF

   LET l_cnpj_cli =   l_cnpj_cli[2,3],
                      l_cnpj_cli[5,7],
                      l_cnpj_cli[9,11],
                      l_cnpj_cli[13,16],
                      l_cnpj_cli[18,19]
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
    
   LET p_nom_arquivo = p_caminho CLIPPED, 'EDI', l_num_cnpj CLIPPED,'_RND00107_',
                       l_cnpj_cli CLIPPED,'_',l_dat_hora CLIPPED,'.TXT'
     
   START REPORT pol1223_relat_arq  TO p_nom_arquivo

   IF  NOT pol1223_emite_arquivo_edi() THEN 
       RETURN FALSE 
   END IF  	   

   FINISH REPORT pol1223_relat_arq     
      
   MESSAGE "Arquivos Gerados no caminho ",p_caminho
       ATTRIBUTE(REVERSE)   
	   

   RETURN TRUE 	   
	   
END FUNCTION

#-------------------------------------#
 FUNCTION pol1223_emite_arquivo_edi()
#-------------------------------------#
  
   DEFINE lr_arq_edi       RECORD
    #---ITPv0  M  1 00  Segmento Inicial Mensagem     
      ident_itp                CHAR(3), # 1-3     Ident. tipo registro 	  - ITP
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
   #---PE1v0  M 1 ITPv0 01 DADOS DO ITEM                 
      ident_pe1                CHAR(3), # 1-3     Ident. Tipo Registro 			  - PE1
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
   #---PE2v2 M 1 PE1v0 02 INFORMACOES DE ENTREGAS       
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
	    qualif_prog              CHAR(1), # 116-116 Qualificação da Programação
	    tipo_pr                  CHAR(2), # 117-118 Tipo do Pedido de Revenda
	    via_transp               CHAR(2), # 119-120 Código da Via de Transporte
	    espaco_pe2               CHAR(8), # 121-128 Espaço 
  #---PE3v0 M G PE1v0 02 CRONOGRAMA DE ENTREGA         
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

     #---PE5v0 O 1  PE3v0     03    COMPLEMENTO PROGRAMA ENTREGA  
      ident_pe5                CHAR(3), # 1-3    Ident. Tipo Registro - PE5
      dat_ent_emb_1            CHAR(6), # 4-9    Data de Entrega/embarque do item
      prog_firme_1             CHAR(1), # 10-10  tipo de programação: 1=firme
      prog_atual_1             CHAR(9), # 11-19  programação atual: mandar zeros
      dat_ent_emb_2            CHAR(6), 
      prog_firme_2             CHAR(1), 
      prog_atual_2             CHAR(9), 
      dat_ent_emb_3            CHAR(6), 
      prog_firme_3             CHAR(1), 
      prog_atual_3             CHAR(9), 
      dat_ent_emb_4            CHAR(6), 
      prog_firme_4             CHAR(1), 
      prog_atual_4             CHAR(9), 
      dat_ent_emb_5            CHAR(6), 
      prog_firme_5             CHAR(1), 
      prog_atual_5             CHAR(9), 
      dat_ent_emb_6            CHAR(6), 
      prog_firme_6             CHAR(1), 
      prog_atual_6             CHAR(9), 
      dat_ent_emb_7            CHAR(6), 
      prog_firme_7             CHAR(1), 
      prog_atual_7             CHAR(9), 
      espaco_pe5               CHAR(13),
     
     #---PE4v0 O 1  PE1v0     02    DADOS DA EMBALAGEM            
     #---TE1v0 O N  PE1v0     02    TEXTO LIVRE                   
     #---FTPv0 M 1  ITPv0     01    Segmento Final Mensagem       
      
      ident_ftp                CHAR(3), # 1-3     Ident. Tipo Registro - FTP
      num_ctr_tms_ftp          CHAR(5), # 4-8     Numero Contr. Transmissao
      qtd_reg_transac          CHAR(9), # 9-17    Quantidade Registro Transacao
      num_tot_val              CHAR(17),# 18-34   Numero total de valores
      categ_operac             CHAR(1), # 35-35   Categoria da Operacao
      espaco_ftp               CHAR(93) # 36-128  Espaço       
   END RECORD
   
   DEFINE l_num_reg            INTEGER,
          l_num_cnpj           CHAR(19),
          l_cnpj_cli            CHAR(19),
          l_cod_item           LIKE item.cod_item, 
          l_cod_fornecedor     LIKE fornecedor.cod_fornecedor, 
          l_cod_item_cli        LIKE item_edi_454.cod_item_cli, 
          l_num_ped_cli         CHAR(12),
          l_contato            LIKE item_edi_454.contato,
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
  		    l_cod_uni_med        LIKE item_edi_454.cod_uni_med,
		      l_num_nf             LIKE nf_sup.num_nf,
		      l_ser_nf             LIKE nf_sup.ser_nf,
		      l_num_aviso_rec      LIKE nf_sup.num_aviso_rec,
		      l_dat_entrada_nf     LIKE nf_sup.dat_entrada_nf,
		      l_dat_emis_nf        LIKE nf_sup.dat_emis_nf,
		      l_qtd_recebida       LIKE aviso_rec.qtd_recebida,
		      x_ind                SMALLINT,
		      l_ind                SMALLINT,
          sql_stmt_2           CHAR(300),
		      z_cod_item           LIKE item.cod_item,
		      z_num_ped_fornec     CHAR(12)
		  
	DEFINE ma_edi   ARRAY[200] OF RECORD 
      prz_entrega             DATE,
      saldo                   DECIMAL(18,7),
      num_ped_cli             CHAR(12) 
  END RECORD 
  
  DEFINE p_qtd_saldo      DECIMAL(10,3), 
         p_prz_entrega    DATE,
         p_query          CHAR(800)
   
  DEFINE l_item_edi_454  RECORD LIKE item_edi_454.*
 
   LET l_capa  = TRUE
   LET m_count = 0
   LET l_num_reg = 0
   INITIALIZE z_cod_item   TO NULL
   INITIALIZE l_item_edi_454.* TO NULL
   INITIALIZE lr_arq_edi.*          TO NULL
				
   DECLARE cq_edi CURSOR FOR
    SELECT DISTINCT cod_item
      FROM w_edi_tmp_454
		 WHERE cod_fornecedor = p_cod_fornecedor
     ORDER BY cod_item 

   FOREACH cq_edi INTO z_cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_edi')
         RETURN FALSE
      END IF
      
      SELECT raz_social, num_cgc_cpf
        INTO lr_arq_edi.nom_rcp, l_num_cnpj
        FROM fornecedor
       WHERE cod_fornecedor = p_cod_fornecedor
 
      IF STATUS <> 0 THEN
         LET l_num_cnpj = ' '
         LET lr_arq_edi.nom_rcp = ' '       
      END IF
 
      SELECT den_empresa, num_cgc
        INTO lr_arq_edi.nom_tms, l_cnpj_cli
        FROM empresa
       WHERE cod_empresa = p_cod_empresa
      
      IF STATUS <> 0 THEN
         LET l_cnpj_cli = ' '
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
      LET lr_arq_edi.ident_tms_comun  = l_cnpj_cli[2,3], 
                                        l_cnpj_cli[5,7],
                                        l_cnpj_cli[9,11],
                                        l_cnpj_cli[13,16],
                                        l_cnpj_cli[18,19]
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
         OUTPUT TO REPORT pol1223_relat_arq(0,lr_arq_edi.*)
         LET l_capa = FALSE
      END IF
   
   #--- a seguir, preparação e envio dos dados do item
   
	    INITIALIZE p_num_processo TO NULL
	  
	    SELECT num_processo 
		    INTO p_num_processo  
	      FROM processo_edi_454
		   WHERE cod_empresa = p_cod_empresa
	  	
	    IF STATUS <> 0 THEN
         LET p_num_processo = 0      
      END IF
	  
	    LET p_num_processo =  p_num_processo + 1
	  
	    UPDATE processo_edi_454  
	       SET num_processo =  p_num_processo 
	     WHERE cod_empresa = p_cod_empresa
	  	
	    IF STATUS <> 0 THEN
         RETURN FALSE     
      END IF
	  
	    SELECT *
	      INTO l_item_edi_454.*
	      FROM item_edi_454
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = z_cod_item
			 
  	  IF STATUS <> 0 THEN
    	   CALL log003_err_sql("SELECT","item_edi_454")
	 	     RETURN FALSE
      END IF	
	  
	    LET lr_arq_edi.ident_pe1        = 'PE1' 
      LET lr_arq_edi.cod_fab_dest     = '011'
      LET lr_arq_edi.ident_prog_atual = p_num_processo USING '&&&&&&&&&'
      LET lr_arq_edi.dat_prog_atual   = TODAY USING 'yymmdd'
      LET lr_arq_edi.ident_prog_ant   = ' '
      LET lr_arq_edi.dat_prog_ant     = '000000' 
      LET lr_arq_edi.cod_item_cli     = l_item_edi_454.cod_item_cli
      LET lr_arq_edi.cod_item_forn    = z_cod_item 
      LET lr_arq_edi.num_ped_comp     = '            '
      LET lr_arq_edi.cod_loc_dest     = '011'  
      LET lr_arq_edi.ident_para_cont  = l_item_edi_454.contato 
      LET lr_arq_edi.cod_unid_med     = l_item_edi_454.cod_uni_med
      LET lr_arq_edi.qtd_casas_dec    = '0' 
      LET lr_arq_edi.cod_tip_fornto   = 'P' 
	  
	    LET l_num_reg = l_num_reg + 1
      OUTPUT TO REPORT pol1223_relat_arq(1,lr_arq_edi.*)

   #--- a seguir, preparação e envio dos dados da última entrega
	 
	    INITIALIZE l_dat_entrada_nf , l_dat_emis_nf  TO NULL	  
	    LET p_tem_nota = FALSE
	    
	    DECLARE cq_ultnf SCROLL CURSOR FOR

	    SELECT a.num_nf, 
	           a.ser_nf,
	           a.num_aviso_rec, 
	           a.dat_entrada_nf, 
	           a.dat_emis_nf, 
	           sum(b.qtd_recebida)
	      FROM nf_sup a, aviso_rec b
		   WHERE a.cod_empresa = b.cod_empresa
		     AND a.num_aviso_rec = b.num_aviso_rec
         AND b.cod_item = z_cod_item
         AND a.cod_empresa = p_cod_empresa
				 AND a.cod_fornecedor = p_cod_fornecedor
         AND a.dat_entrada_nf IN 
             (SELECT max(dat_entrada_nf)
                FROM nf_sup c, aviso_rec d
               WHERE c.cod_empresa=d.cod_empresa
                 AND c.num_aviso_rec=d.num_aviso_rec
                 AND c.cnd_pgto_nf IN 
                     (SELECT cnd_pgto
                        FROM cond_pgto_cap
                       WHERE ies_pagamento = '2')
                 AND d.cod_item = z_cod_item
                 AND c.cod_empresa = p_cod_empresa)
		   GROUP BY  a.num_nf, a.ser_nf, a.num_aviso_rec, a.dat_entrada_nf, a.dat_emis_nf
		   ORDER BY  a.num_aviso_rec DESC

		  FOREACH cq_ultnf INTO  
		     l_num_nf, l_ser_nf, l_num_aviso_rec, l_dat_entrada_nf, l_dat_emis_nf, l_qtd_recebida 
		
         LET p_tem_nota = TRUE
         EXIT FOREACH			

	    END FOREACH

	    IF NOT p_tem_nota THEN
         LET l_ser_nf         = ' '  
	       LET l_num_nf         = 0 
	       LET l_num_aviso_rec  = 0 
	       LET l_qtd_recebida   = 0   
      END IF
	   
	    LET lr_arq_edi.ident_pe2 = 'PE2'
	  
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
	    LET lr_arq_edi.ser_ult_nf       = l_ser_nf  USING '####'
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
      OUTPUT TO REPORT pol1223_relat_arq(2,lr_arq_edi.*)
	    
		#--- a seguir, preparação e envio do cronograma de entrega
		
      LET l_ind = 1   
      INITIALIZE ma_edi  TO NULL 	

      DECLARE cq_prz_entrega CURSOR FOR
       SELECT SUM(saldo), prz_entrega, num_ped_cli 
         FROM w_edi_tmp_454 
        WHERE cod_item       = z_cod_item
	        AND cod_fornecedor = p_cod_fornecedor
        GROUP BY prz_entrega, num_ped_cli 
        ORDER BY prz_entrega, num_ped_cli

      FOREACH cq_prz_entrega INTO ma_edi[l_ind].saldo, ma_edi[l_ind].prz_entrega, ma_edi[l_ind].num_ped_cli
      
         IF ma_edi[l_ind].saldo <= 0 OR ma_edi[l_ind].prz_entrega IS NULL THEN
            CONTINUE FOREACH
         END IF
         
         LET l_ind = l_ind + 1
         
         IF l_ind  > 200 THEN 
			      CALL log003_err_sql('ESTOUROU INDICE 1','L_IND')
			      RETURN  FALSE
	       END IF 		
	       
      END FOREACH	
	  
	    LET x_ind = 0
	  
	    WHILE x_ind < l_ind

         LET lr_arq_edi.ident_pe3                 = 'PE3'
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
         LET  lr_arq_edi.espaco_pe3               = '      '    

         LET lr_arq_edi.ident_pe5                 = 'PE5'
         LET  lr_arq_edi.dat_ent_emb_1            = '000000'
         LET  lr_arq_edi.prog_firme_1             = '0'
         LET  lr_arq_edi.prog_atual_1             = '         '

         LET  lr_arq_edi.dat_ent_emb_2            = '000000'
         LET  lr_arq_edi.prog_firme_2             = '0'
         LET  lr_arq_edi.prog_atual_2             = '         '

         LET  lr_arq_edi.dat_ent_emb_3            = '000000'
         LET  lr_arq_edi.prog_firme_3             = '0'
         LET  lr_arq_edi.prog_atual_3             = '         '

         LET  lr_arq_edi.dat_ent_emb_4            = '000000'
         LET  lr_arq_edi.prog_firme_4             = '0'
         LET  lr_arq_edi.prog_atual_4             = '         '

         LET  lr_arq_edi.dat_ent_emb_5            = '000000'
         LET  lr_arq_edi.prog_firme_5             = '0'
         LET  lr_arq_edi.prog_atual_5             = '         '

         LET  lr_arq_edi.dat_ent_emb_6            = '000000'
         LET  lr_arq_edi.prog_firme_6             = '0'
         LET  lr_arq_edi.prog_atual_6             = '         '

         LET  lr_arq_edi.dat_ent_emb_7            = '000000'
         LET  lr_arq_edi.prog_firme_7             = '0'
         LET  lr_arq_edi.prog_atual_7             = '         '

         LET  lr_arq_edi.espaco_pe5               = '             '    

			   LET x_ind = x_ind + 1 
			   
			   IF x_ind < l_ind THEN
	          IF ma_edi[x_ind].saldo > 0 THEN
               LET lr_arq_edi.dat_ent_item_1     = ma_edi[x_ind].prz_entrega USING 'yymmdd'   
               LET lr_arq_edi.hor_ent_item_1     = '00'    
               LET l_qtd_item_1 = ma_edi[x_ind].saldo * (1 + (l_item_edi_454.pct_refugo / 100))
               LET l_qtd_1 = l_qtd_item_1 USING '&&&&&&&&&&&.&&&&&&&'   
               LET l_inteiro_1 = l_qtd_1[1,11]
               LET l_decimal_1 = l_qtd_1[13,19]  
               IF l_decimal_1 > 0 THEN
                  LET l_qtd_item_1 = l_inteiro_1 + 1
               ELSE
                  LET l_qtd_item_1 = l_inteiro_1 + 0
               END IF        
               LET lr_arq_edi.qtd_ent_item_1    = l_qtd_item_1 USING '&&&&&&&&&'
               LET lr_arq_edi.dat_ent_emb_1 = lr_arq_edi.dat_ent_item_1
               LET lr_arq_edi.prog_firme_1 = '1'
               LET  lr_arq_edi.prog_atual_1 = ma_edi[x_ind].num_ped_cli
            END IF
         END IF

  			 LET x_ind = x_ind + 1 
			   IF x_ind < l_ind THEN
   	        IF ma_edi[x_ind].saldo > 0 THEN			
    		       LET lr_arq_edi.dat_ent_item_2     = ma_edi[x_ind].prz_entrega USING 'yymmdd'   
               LET lr_arq_edi.hor_ent_item_2     = '00'    
               LET l_qtd_item_2 = ma_edi[x_ind].saldo *(1 + (l_item_edi_454.pct_refugo / 100))
               LET l_qtd_2 = l_qtd_item_2 USING '&&&&&&&&&&&.&&&&&&&'   
               LET l_inteiro_2 = l_qtd_2[1,11]
               LET l_decimal_2 = l_qtd_2[13,19]  
               IF l_decimal_2 > 0 THEN
                  LET l_qtd_item_2 = l_inteiro_2 + 1
               ELSE
                  LET l_qtd_item_2 = l_inteiro_2 + 0
               END IF        
               LET lr_arq_edi.qtd_ent_item_2    = l_qtd_item_2 USING '&&&&&&&&&'
               LET lr_arq_edi.dat_ent_emb_2 = lr_arq_edi.dat_ent_item_2
               LET lr_arq_edi.prog_firme_2 = '1'
               LET  lr_arq_edi.prog_atual_2 = ma_edi[x_ind].num_ped_cli
            END IF
         END IF
         
	       LET x_ind = x_ind + 1 
			   IF x_ind < l_ind THEN
   	        IF ma_edi[x_ind].saldo > 0 THEN			
			         LET lr_arq_edi.dat_ent_item_3     = ma_edi[x_ind].prz_entrega USING 'yymmdd'   
               LET lr_arq_edi.hor_ent_item_3     = '00'    
               LET l_qtd_item_3 = ma_edi[x_ind].saldo *(1 + (l_item_edi_454.pct_refugo / 100))
               LET l_qtd_3 = l_qtd_item_3 USING '&&&&&&&&&&&.&&&&&&&'   
               LET l_inteiro_3 = l_qtd_3[1,11]
               LET l_decimal_3 = l_qtd_3[13,19]  
               IF l_decimal_3 > 0 THEN
                  LET l_qtd_item_3 = l_inteiro_3 + 1
               ELSE
                  LET l_qtd_item_3 = l_inteiro_3 + 0
               END IF        
               LET lr_arq_edi.qtd_ent_item_3    = l_qtd_item_3 USING '&&&&&&&&&'
               LET lr_arq_edi.dat_ent_emb_3 = lr_arq_edi.dat_ent_item_3
               LET lr_arq_edi.prog_firme_3 = '1'
               LET  lr_arq_edi.prog_atual_3 = ma_edi[x_ind].num_ped_cli
            END IF
         END IF
         
	       LET x_ind = x_ind + 1 
			   IF x_ind < l_ind THEN
   	        IF ma_edi[x_ind].saldo > 0 THEN			
			         LET lr_arq_edi.dat_ent_item_4    = ma_edi[x_ind].prz_entrega USING 'yymmdd'   
               LET lr_arq_edi.hor_ent_item_4     = '00'    
               LET l_qtd_item_4 = ma_edi[x_ind].saldo *(1 + (l_item_edi_454.pct_refugo / 100))
               LET l_qtd_4 = l_qtd_item_4 USING '&&&&&&&&&&&.&&&&&&&'   
               LET l_inteiro_4 = l_qtd_4[1,11]
               LET l_decimal_4 = l_qtd_4[13,19]  
               IF l_decimal_4 > 0 THEN
                  LET l_qtd_item_4 = l_inteiro_4 + 1
               ELSE
                  LET l_qtd_item_4 = l_inteiro_4 + 0
               END IF        
               LET lr_arq_edi.qtd_ent_item_4    = l_qtd_item_4 USING '&&&&&&&&&'	
               LET lr_arq_edi.dat_ent_emb_4 = lr_arq_edi.dat_ent_item_4
               LET lr_arq_edi.prog_firme_4 = '1'
               LET  lr_arq_edi.prog_atual_4 = ma_edi[x_ind].num_ped_cli
            END IF
         END IF
			
	       LET x_ind = x_ind + 1 
			   IF x_ind < l_ind THEN
   	        IF ma_edi[x_ind].saldo > 0 THEN			
			         LET lr_arq_edi.dat_ent_item_5    = ma_edi[x_ind].prz_entrega USING 'yymmdd'   
               LET lr_arq_edi.hor_ent_item_5     = '00'    
               LET l_qtd_item_5 = ma_edi[x_ind].saldo *(1 + (l_item_edi_454.pct_refugo / 100))
               LET l_qtd_5 = l_qtd_item_5 USING '&&&&&&&&&&&.&&&&&&&'   
               LET l_inteiro_5 = l_qtd_5[1,11]
               LET l_decimal_5 = l_qtd_5[13,19]  
               IF l_decimal_5 > 0 THEN
                  LET l_qtd_item_5 = l_inteiro_5 + 1
               ELSE
                  LET l_qtd_item_5 = l_inteiro_5 + 0
               END IF        
               LET lr_arq_edi.qtd_ent_item_5    = l_qtd_item_5 USING '&&&&&&&&&'	
               LET lr_arq_edi.dat_ent_emb_5 = lr_arq_edi.dat_ent_item_5
               LET lr_arq_edi.prog_firme_5 = '1'
               LET  lr_arq_edi.prog_atual_5 = ma_edi[x_ind].num_ped_cli
            END IF
         END IF

	       LET x_ind = x_ind + 1 
			   IF x_ind < l_ind THEN
   	        IF ma_edi[x_ind].saldo > 0 THEN			
			         LET lr_arq_edi.dat_ent_item_6    = ma_edi[x_ind].prz_entrega USING 'yymmdd'   
               LET lr_arq_edi.hor_ent_item_6     = '00'    
               LET l_qtd_item_6 = ma_edi[x_ind].saldo *(1 + (l_item_edi_454.pct_refugo / 100))
               LET l_qtd_6 = l_qtd_item_6 USING '&&&&&&&&&&&.&&&&&&&'   
               LET l_inteiro_6 = l_qtd_6[1,11]
               LET l_decimal_6 = l_qtd_6[13,19]  
               IF l_decimal_6 > 0 THEN
                  LET l_qtd_item_6 = l_inteiro_6 + 1
               ELSE
                  LET l_qtd_item_6 = l_inteiro_6 + 0
               END IF        
               LET lr_arq_edi.qtd_ent_item_6    = l_qtd_item_6 USING '&&&&&&&&&'	
               LET lr_arq_edi.dat_ent_emb_6 = lr_arq_edi.dat_ent_item_6
               LET lr_arq_edi.prog_firme_6 = '1'
               LET  lr_arq_edi.prog_atual_6 = ma_edi[x_ind].num_ped_cli
            END IF
         END IF
			
	       LET x_ind = x_ind + 1 
			   IF x_ind < l_ind THEN
   	        IF ma_edi[x_ind].saldo > 0 THEN			
			         LET lr_arq_edi.dat_ent_item_7    = ma_edi[x_ind].prz_entrega USING 'yymmdd'   
               LET lr_arq_edi.hor_ent_item_7     = '00'    
               LET l_qtd_item_7 = ma_edi[x_ind].saldo *(1 + (l_item_edi_454.pct_refugo / 100))
               LET l_qtd_7 = l_qtd_item_7 USING '&&&&&&&&&&&.&&&&&&&'   
               LET l_inteiro_7 = l_qtd_7[1,11]
               LET l_decimal_7 = l_qtd_7[13,19]  
               IF l_decimal_7 > 0 THEN
                  LET l_qtd_item_7 = l_inteiro_7 + 1
               ELSE
                  LET l_qtd_item_7 = l_inteiro_7 + 0
               END IF        
               LET lr_arq_edi.qtd_ent_item_7    = l_qtd_item_7 USING '&&&&&&&&&'	
               LET lr_arq_edi.dat_ent_emb_7 = lr_arq_edi.dat_ent_item_7
               LET lr_arq_edi.prog_firme_7 = '1'
               LET  lr_arq_edi.prog_atual_7 = ma_edi[x_ind].num_ped_cli
            END IF
         END IF
 	       
 	       LET l_num_reg = l_num_reg + 2
			   OUTPUT TO REPORT pol1223_relat_arq(3,lr_arq_edi.*)
			   OUTPUT TO REPORT pol1223_relat_arq(5,lr_arq_edi.*)
			
	    END WHILE
	   
   END FOREACH
   
   IF l_num_reg > 0   THEN 
      LET l_num_reg = l_num_reg + 1
      LET lr_arq_edi.ident_ftp        = 'FTP'  
      LET lr_arq_edi.num_ctr_tms_ftp  = '00000' 
      LET lr_arq_edi.qtd_reg_transac  = l_num_reg  USING '&&&&&&&&&'
      LET lr_arq_edi.num_tot_val      = '00000000000000000'  
      LET lr_arq_edi.categ_operac     = ' '  
      LET lr_arq_edi.espaco_ftp       = ' '  
     
      OUTPUT TO REPORT pol1223_relat_arq(4,lr_arq_edi.*)
   END IF	  
   
   RETURN TRUE
   
END FUNCTION


#-------------------------------------------#
 REPORT pol1223_relat_arq(l_tipo, lr_arq_edi)
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
	    via_transp               CHAR(2), # 119-120 Código da Via de Transporte
	    espaco_pe2               CHAR(8), # 121-128 Espaço 
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

      ident_pe5                CHAR(3), # 1-3    Ident. Tipo Registro - PE5
      dat_ent_emb_1            CHAR(6), # 4-9    Data de Entrega/embarque do item
      prog_firme_1             CHAR(1), # 10-10  tipo de programação: 1=firme
      prog_atual_1             CHAR(9), # 11-19  programação atual: mandar zeros
      dat_ent_emb_2            CHAR(6), 
      prog_firme_2             CHAR(1), 
      prog_atual_2             CHAR(9), 
      dat_ent_emb_3            CHAR(6), 
      prog_firme_3             CHAR(1), 
      prog_atual_3             CHAR(9), 
      dat_ent_emb_4            CHAR(6), 
      prog_firme_4             CHAR(1), 
      prog_atual_4             CHAR(9), 
      dat_ent_emb_5            CHAR(6), 
      prog_firme_5             CHAR(1), 
      prog_atual_5             CHAR(9), 
      dat_ent_emb_6            CHAR(6), 
      prog_firme_6             CHAR(1), 
      prog_atual_6             CHAR(9), 
      dat_ent_emb_7            CHAR(6), 
      prog_firme_7             CHAR(1), 
      prog_atual_7             CHAR(9), 
      espaco_pe5               CHAR(13),

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
               PRINT COLUMN 120, lr_arq_edi.espaco_itp
         
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
               PRINT COLUMN 128, lr_arq_edi.cod_tip_fornto
			   
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
               PRINT COLUMN 121, lr_arq_edi.espaco_pe2

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
               PRINT COLUMN 123, lr_arq_edi.espaco_pe3

            WHEN l_tipo = 4   
               PRINT COLUMN 001, lr_arq_edi.ident_ftp;           
               PRINT COLUMN 004, lr_arq_edi.num_ctr_tms_ftp;     
               PRINT COLUMN 009, lr_arq_edi.qtd_reg_transac;     
               PRINT COLUMN 018, lr_arq_edi.num_tot_val;         
               PRINT COLUMN 035, lr_arq_edi.categ_operac;        
               PRINT COLUMN 036, lr_arq_edi.espaco_ftp

            WHEN l_tipo = 5   
               PRINT COLUMN 001, lr_arq_edi.ident_pe5;       

               PRINT COLUMN 004, lr_arq_edi.dat_ent_emb_1;    
               PRINT COLUMN 010, lr_arq_edi.prog_firme_1;    
               PRINT COLUMN 011, lr_arq_edi.prog_atual_1;

               PRINT COLUMN 020, lr_arq_edi.dat_ent_emb_2;    
               PRINT COLUMN 026, lr_arq_edi.prog_firme_2;    
               PRINT COLUMN 027, lr_arq_edi.prog_atual_2;

               PRINT COLUMN 036, lr_arq_edi.dat_ent_emb_3;    
               PRINT COLUMN 042, lr_arq_edi.prog_firme_3;    
               PRINT COLUMN 043, lr_arq_edi.prog_atual_3;

               PRINT COLUMN 052, lr_arq_edi.dat_ent_emb_4;    
               PRINT COLUMN 058, lr_arq_edi.prog_firme_4;    
               PRINT COLUMN 059, lr_arq_edi.prog_atual_4;

               PRINT COLUMN 068, lr_arq_edi.dat_ent_emb_5;    
               PRINT COLUMN 074, lr_arq_edi.prog_firme_5;    
               PRINT COLUMN 075, lr_arq_edi.prog_atual_5;

               PRINT COLUMN 084, lr_arq_edi.dat_ent_emb_6;    
               PRINT COLUMN 090, lr_arq_edi.prog_firme_6;    
               PRINT COLUMN 091, lr_arq_edi.prog_atual_6;

               PRINT COLUMN 100, lr_arq_edi.dat_ent_emb_7;    
               PRINT COLUMN 106, lr_arq_edi.prog_firme_7;    
               PRINT COLUMN 107, lr_arq_edi.prog_atual_7;
               PRINT COLUMN 116, lr_arq_edi.espaco_pe5


        END CASE

END REPORT                                         

#-------------------------------#  
 FUNCTION pol1223_imprime_relat()
#-------------------------------#  

   IF NOT pol1223_escolhe_saida() THEN
   		RETURN 
   END IF
   

    START REPORT pol1223_relat TO p_nom_arquivo


    CALL pol1223_emite_relatorio()
 
    FINISH REPORT pol1223_relat

   IF p_ies_impressao = "S" THEN
      LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
      CALL log0030_mensagem(p_msg, 'excla')
      IF g_ies_ambiente = "W" THEN
         LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
         RUN comando
      END IF
   ELSE
      LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
      CALL log0030_mensagem(p_msg, 'exclamation')
   END IF

   ERROR 'Relatório gerado com sucesso !!!'
        
END FUNCTION           
                    
#------------------------------#
FUNCTION pol1223_escolhe_saida()
#------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1223.tmp"
         START REPORT pol1223_relat TO p_caminho
      ELSE
         START REPORT pol1223_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------------#
 FUNCTION pol1223_emite_relatorio()
#---------------------------------#

   DEFINE lr_relat          RECORD  
       cod_fornecedor              CHAR(15),   
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
 
    SELECT  cod_fornecedor, 
	          cod_item,
			      prz_entrega,
            SUM(saldo)
    FROM w_edi_tmp_454
    GROUP BY cod_fornecedor, cod_item, prz_entrega
    ORDER BY cod_fornecedor, cod_item, prz_entrega 
						   	     
     FOREACH cq_relat_2 INTO 
             lr_relat.cod_fornecedor,
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
           FROM item_edi_454
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
		 
         OUTPUT TO REPORT pol1223_relat(lr_relat.*)
      
         INITIALIZE lr_relat.* TO NULL 
         LET p_count = p_count + 1
      
      END FOREACH


END FUNCTION      

#-----------------------------#
 REPORT pol1223_relat(lr_relat)
#-----------------------------#
  DEFINE l_saldo_total   DECIMAL(18,7)   
  DEFINE lr_relat          RECORD  
       cod_fornecedor              CHAR(15),   
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
 
   ORDER EXTERNAL BY lr_relat.cod_fornecedor,
                     lr_relat.cod_item,
                     lr_relat.prz_entrega

   FORMAT
      PAGE HEADER
         LET l_saldo_total  = 0 
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 066, "RELATORIO DE ENVIO DE PROGRAMACAO",
               COLUMN 132, "PAG.: ", PAGENO USING "####"
         PRINT COLUMN 001, "pol1223",
               COLUMN 050, "PERIODO : ", p_tela.dat_inicio,
                           " ATE ",p_tela.dat_final,
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
         PRINT COLUMN 001, lr_relat.cod_fornecedor,
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

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF

END REPORT




#------------FIM DO PROGRAMA-----------------#








     



 