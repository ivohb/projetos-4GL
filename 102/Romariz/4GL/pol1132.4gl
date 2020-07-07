#-------------------------------------------------------------------#
# SISTEMA.: EMISSOR DE LAUDOS                                       #
# PROGRAMA: POL1132                                                 #
# OBJETIVO: RELATÓRIO DAS ANÁLISES PENDENTES                        #
# DATA....: 06/02/2012                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
          p_den_empresa   LIKE empresa.den_empresa,  
          p_user          LIKE usuario.nom_usuario,
          p_status        SMALLINT,
          p_houve_erro    SMALLINT,
          comando         CHAR(80),
          p_versao        CHAR(18),
          p_ies_impressao CHAR(001),
          g_ies_ambiente  CHAR(001),
          p_nom_arquivo   CHAR(100),
          p_arquivo       CHAR(025),
          p_caminho       CHAR(080),
          p_nom_tela      CHAR(200),
          p_nom_help      CHAR(200),
          sql_stmt        CHAR(500),
          p_r             CHAR(001),
          p_count         SMALLINT,
          p_ies_cons      SMALLINT,
          p_last_row      SMALLINT,
          p_sql           CHAR(950),
          p_grava         SMALLINT, 
          pa_curr         SMALLINT,
          pa_curr1        SMALLINT,
          sc_curr         SMALLINT,
          sc_curr1        SMALLINT,
          w_a             SMALLINT,
		  		p_msg           CHAR(100),
		  		p_operacao      CHAR(10),
		  		p_mensagem      CHAR(300),
		  		p_id_registro   INTEGER,
		  		p_cod_familia   char(05),
          p_dat_atual     date,
          p_txt_tip       char(10),
          p_txt_val       char(15),
          p_unidade       char(15),
          p_item          CHAR(15),
          p_num_pa        INTEGER,
          p_qtd_laudo     INTEGER,
          p_val_analise   char(15),
		  		L_TIPO_VALOR    CHAR(1),
          p_Comprime      CHAR(01),
          p_descomprime   CHAR(01),
          p_negrito       CHAR(02),
          p_normal        CHAR(02),
          p_ordem         CHAR(10),
          p_repetiu       SMALLINT,
          p_Data_char     CHAR(10),
          p_filtro        CHAR(120)
		  		
		 

END GLOBALS
   
   DEFINE w_i             SMALLINT

   DEFINE mr_tela RECORD 
      cod_item       LIKE analise_915.cod_item,
      den_item       LIKE item.den_item
   END RECORD 

   DEFINE p_lista RECORD
      cod_item                  LIKE ANALISE_915.cod_item,
      lote_tanque               LIKE ANALISE_915.lote_tanque,
      num_pa                    LIKE ANALISE_915.num_pa,
      tip_analise               LIKE ANALISE_915.tip_analise,
      den_analise_port          LIKE it_ANALISE_915.den_analise_port,
      dat_analise               LIKE ANALISE_915.dat_analise,
      usuario                   LIKE ANALISE_915.usuario
   END RECORD 



MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL1132-10.02.01"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("POL1132.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL POL1132_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION POL1132_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("POL1132") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_POL1132 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar"   "Informar parametros "
         HELP 0009
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","POL1132","IN") THEN
            IF pol1132_entrada_parametros() THEN
               NEXT OPTION "Listar"
            END IF
         END IF
      COMMAND "Listar" "Lista Relatório de Análises Pendentes"
         MESSAGE ""
            IF log0280_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT POL1132_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'POL1132.tmp'
                     START REPORT POL1132_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT POL1132_relat TO p_nom_arquivo
               END IF
               CALL POL1132_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
                  CONTINUE MENU
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT POL1132_relat   
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

      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL POL1132_sobre()
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
  
   CLOSE WINDOW w_pol1132

END FUNCTION

#-----------------------#
 FUNCTION POL1132_popup()
#-----------------------#
   DEFINE z_ind  SMALLINT

   DEFINE pr_lote ARRAY[150] OF RECORD
      val_caracter INTEGER,
      resultado    char(45)
   END RECORD
   

   CASE
      WHEN infield(cod_item)
         CALL log009_popup(9,13,"ITEM ANALISE","item_915","cod_item_analise",
                                "den_item_portugues","POL1132","S","")
            RETURNING mr_tela.cod_item

         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_POL1132
         IF mr_tela.cod_item IS NOT NULL THEN
            DISPLAY mr_tela.cod_item TO cod_item
            CALL POL1132_verifica_item() RETURNING p_status
         END IF
            
   END CASE
   
END FUNCTION



#-----------------------------------#
FUNCTION pol1132_entrada_parametros()
#-----------------------------------#

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol1132

   INITIALIZE mr_tela.* TO NULL

   LET INT_FLAG =  FALSE
   INPUT BY NAME mr_tela.*  WITHOUT DEFAULTS  

      AFTER FIELD cod_item 
         IF mr_tela.cod_item IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD cod_item       
         ELSE
            IF POL1132_verifica_item() = FALSE THEN
               ERROR 'Item não cadastrado.'
               NEXT FIELD cod_item
            END IF   
         END IF
         
      ON KEY (control-z)
         CALL POL1132_popup()
 
    END INPUT 

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol1132

   IF INT_FLAG THEN
      LET INT_FLAG = 0
      CLEAR FORM
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION POL1132_verifica_item()
#-------------------------------#
   DEFINE l_den_item         LIKE item.den_item

   SELECT den_item_portugues
     INTO l_den_item
     FROM item_915
    WHERE cod_empresa     = p_cod_empresa
      AND cod_item_analise = mr_tela.cod_item
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_item to den_item
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION           




#--------------------------------#
 FUNCTION pol1132_emite_relatorio()
#--------------------------------#

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_negrito     = ascii 27, "E"
   LET p_normal      = ascii 27, "F"
   LET p_count = 0 
   
	SELECT den_empresa
	INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	

#----------------------------- IMPRIMINDO LISTA --------------------------#
   LET p_sql = 
      "SELECT a.cod_item,a.lote_tanque,a.num_pa,a.tip_analise,it.den_analise_port, ",
      " a.dat_analise, a.usuario ",
      " FROM analise_915 a, it_analise_915 it  "

   LET p_sql = p_sql CLIPPED, ' '," WHERE a.cod_empresa =  ",p_cod_empresa
   LET p_sql = p_sql CLIPPED, ' '," AND a.em_analise =  '",'S',"'"
   LET p_sql = p_sql CLIPPED, ' '," AND it.cod_empresa = a.cod_empresa"
   LET p_sql = p_sql CLIPPED, ' '," AND it.tip_analise = a.tip_analise "

	 IF   mr_tela.cod_item <> '' THEN
   		LET p_sql = p_sql CLIPPED, ' '," AND a.cod_item =  '",mr_tela.cod_item,"'"
   END IF
      

   LET p_sql = p_sql CLIPPED, ' ', " order by a.cod_item "

   PREPARE var_query FROM p_sql   
   DECLARE cq_padrao CURSOR FOR var_query


   FOREACH cq_padrao INTO 
      p_lista.cod_item, p_lista.lote_tanque,
      p_lista.num_pa, p_lista.tip_analise, 
      p_lista.den_analise_port,
      p_lista.dat_analise, p_lista.usuario 

      
      
			IF   mr_tela.cod_item <> '' THEN
      	LET p_filtro = p_filtro CLIPPED, " ITEM: ",mr_tela.cod_item
    	END IF

      
   OUTPUT TO REPORT pol1132_relat(p_lista.cod_item) 
      
   LET p_count = p_count + 1
   INITIALIZE p_lista TO NULL
                 
   END FOREACH


END FUNCTION





#--------------------------------#
 REPORT pol1132_relat(p_ordem_imp)                              
#--------------------------------# 

	DEFINE 	p_ordem_imp				CHAR(15)
   
	OUTPUT LEFT   MARGIN 0
	TOP    				MARGIN 0
	BOTTOM 				MARGIN 3

	FORMAT
	
	PAGE HEADER  								#----------CABEÇALHO DO RELATORIO-------------
	
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
                           
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 124, "PAG: ", PAGENO USING "###&"
               
         PRINT COLUMN 001, p_versao,
               COLUMN 041, "RELATÓRIO DE ANÁLISES PENDENTES",
               COLUMN 91, "DATA: ", TODAY USING "DD/MM/YYYY", " - ", TIME," USUARIO: ",p_user
         PRINT COLUMN 001, p_filtro  
               
         PRINT COLUMN 001, '--------------------------------------------------------------------------------------------'
         PRINT COLUMN 001, '     ITEM      |LOTE TANQUE|   PA   |TIPO AN.|        DESCRIÇÃO             | USUARIO    '
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, '---------------|-----------|--------|--------|------------------------------|---------------'
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
         PRINT COLUMN 001, p_lista.cod_item, 
               COLUMN 016,'|',
               COLUMN 017, p_lista.lote_tanque, 
               COLUMN 028,'|',
               COLUMN 030, p_lista.num_pa USING '###,###', 
               COLUMN 037,'|',
               COLUMN 038, p_lista.tip_analise USING '###,###',
               COLUMN 046,'|',
               COLUMN 047, p_lista.den_analise_port, 
               COLUMN 077,'|',
               COLUMN 080, p_lista.usuario 
         PRINT COLUMN 001, '---------------|-----------|--------|--------|------------------------------|---------------'
      ON LAST ROW 
         PRINT COLUMN 001, '--------------------------------------------------------------------------------------------'
         PRINT
         PRINT COLUMN 001, 'ULTIMA FOLHA'
					

END REPORT

  
#-----------------------#
 FUNCTION POL1132_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
   
END FUNCTION   
                  