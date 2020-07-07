#-----------------------------------------------------------#
# SISTEMA.: RESUMO DO FATURAMENTO MENSAL										#
#	PROGRAMA:	pol1105																					#
#	CLIENTE.:	CODESP																					#
#	OBJETIVO:	GERAR RESUMO DO FATURAMENTO											#
#	AUTOR...:	PAULO CESAR																			#
#	DATA....:	08/07/2011																			#
#-----------------------------------------------------------#

DATABASE logix
GLOBALS
   DEFINE 
		   	p_cod_empresa   			LIKE empresa.cod_empresa,
		    p_user          			LIKE usuario.nom_usuario,
		    p_den_empresa					LIKE empresa.den_empresa,
				p_status        			SMALLINT,
				p_versao        			CHAR(18),
				comando         			CHAR(80),
				p_caminho							CHAR(30),
			  p_nom_arquivo					CHAR(100),
        p_ies_impressao       CHAR(01),
        g_ies_ambiente        CHAR(01),
        p_sql                 CHAR(800),
        p_count               SMALLINT,
				p_nom_tela 						CHAR(200),
				p_retorno							SMALLINT,
				p_ies_cons      			SMALLINT,
				p_cont								SMALLINT,
				p_nom_help      			CHAR(200),
				p_den_mes							CHAR(08),
				p_saldo								LIKE saldos.val_saldo_acum,
				p_saldo_ant						LIKE saldos.val_saldo_acum,
				p_den_conta						LIKE plano_contas.den_conta,
        p_Comprime            CHAR(01),
        p_descomprime         CHAR(01),
        p_negrito             CHAR(02),
        p_normal              CHAR(02),
        p_msg                 CHAR(600),
        p_filtro              CHAR(120),	
	      p_dat_movto_fim_aux		DATE

	 DEFINE p_entrada RECORD 
				 dat_movto_ini			DATE,				
				 dat_movto_fim			DATE
	 END RECORD 

   DEFINE p_lista RECORD
      usu_incl_nf               CHAR(8),
      tip_nota_fiscal           CHAR(8),
      val_nota_fiscal           DECIMAL(32,2),
      val_mercadoria            DECIMAL(32,2),
      dat_ini_seg_per           DATE,
      dat_fim_seg_per           DATE
   END RECORD 
END GLOBALS 


MAIN
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
	  SET ISOLATION TO DIRTY READ
	  SET LOCK MODE TO WAIT 300 
	WHENEVER ANY ERROR STOP
	DEFER INTERRUPT
	LET p_versao = "pol1105-10.02.02"
	INITIALIZE p_nom_help TO NULL  
	CALL log140_procura_caminho("pol1105.iem") RETURNING p_nom_help
	LET  p_nom_help = p_nom_help CLIPPED
	OPTIONS HELP FILE p_nom_help,
	  NEXT KEY control-f,
	  INSERT KEY control-i,
	  DELETE KEY control-e,
	  PREVIOUS KEY control-b
   CALL log001_acessa_usuario("ESPEC999","")
	  RETURNING p_status, p_cod_empresa, p_user
	IF p_status = 0  THEN
	  CALL pol1105_controle()
	END IF
END MAIN 
#---------------------------#
FUNCTION  pol1105_controle()#
#---------------------------#
	CALL log006_exibe_teclas("01", p_versao)
	CALL log130_procura_caminho("pol1105") RETURNING comando
	OPEN WINDOW w_pol1105 AT 5,3 WITH FORM comando
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	
	LET p_retorno = FALSE 
	MENU "OPCAO"
		COMMAND "Informar"   "Informar parametros "
         HELP 001 
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol1105","IN")  THEN
         		LET p_count = 0
            IF pol1105_entrada_dados() THEN
            	MESSAGE "Parâmetros informados com sucesso !!!" ATTRIBUTE(REVERSE)
              LET p_ies_cons = TRUE
              NEXT OPTION "Listar"
            ELSE
              ERROR "Operação Cancelada !!!"
              NEXT OPTION "Fim"
            END IF
         END IF 
		COMMAND "Listar"  "Lista dados"
         HELP 002
         LET p_count = 0
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol1075","MO") THEN
           IF p_ies_cons THEN 
               IF log0280_saida_relat(13,29) IS NOT NULL THEN
                  MESSAGE " Processando a Extracao do Relatorio..." 
                     ATTRIBUTE(REVERSE)
                     
                  IF p_ies_impressao = "S" THEN
                     IF g_ies_ambiente = "U" THEN
                        START REPORT pol1105_relat TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol1075.tmp'
                        START REPORT pol1105_relat  TO p_caminho
                     END IF
                  ELSE
                     START REPORT pol1105_relat TO p_nom_arquivo
                  END IF
                  CALL pol1105_listar()   
                  IF p_count = 0 THEN
                     ERROR "Nao Existem Dados para serem Listados" 
                  ELSE
                     ERROR "Relatorio Processado com Sucesso" 
                  END IF
                  FINISH REPORT pol1105_relat   

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
                  IF p_count > 0 THEN 
                     MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                     " " ATTRIBUTE(REVERSE)
                  ELSE
                     MESSAGE ""
                  END IF
               END IF                              

               NEXT OPTION "Fim"
           ELSE
               ERROR "Informar Previamente Parametros para Impressao"
               NEXT OPTION "Informar"
           END IF 
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	 			CALL pol1105_sobre()
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
		COMMAND "Fim" "Retorna ao Menu Anterior"
			HELP 008
			EXIT MENU
	END MENU
	CLOSE WINDOW w_pol1105
END FUNCTION

#--------------------------------#
FUNCTION  pol1105_entrada_dados()#
#--------------------------------#
	CALL log006_exibe_teclas("01 02 07", p_versao)
	CLEAR FORM 
 	CURRENT WINDOW IS w_pol1105	
 	DISPLAY p_cod_empresa TO cod_empresa
 	INPUT BY NAME p_entrada.*
 		BEFORE  INPUT
		 	LET p_entrada.dat_movto_ini = CURRENT
		 	LET p_entrada.dat_movto_fim = CURRENT
		 	DISPLAY p_entrada.dat_movto_ini  TO dat_movto_ini
		 	DISPLAY p_entrada.dat_movto_fim  TO dat_movto_fim 
 	
 		AFTER FIELD dat_movto_ini
 			IF p_entrada.dat_movto_ini IS NULL THEN
 				ERROR"Campo de Prenchimento Obrigatório!"
 				NEXT FIELD dat_movto_ini
 			END IF 
 		AFTER FIELD dat_movto_fim
			IF p_entrada.dat_movto_fim IS NULL THEN
 				ERROR"Campo de Prenchimento Obrigatório!"
 				NEXT FIELD dat_movto_fim
 			ELSE 
 				IF p_entrada.dat_movto_fim < p_entrada.dat_movto_ini THEN
 					ERROR"Data Final não pode ser menor que a data inicial"
 					NEXT FIELD dat_movto_fim
 				ELSE
 					IF NOT  pol1105_valida_data() THEN 
 						ERROR"Periodo de datas nao podem ser de meses diferentes"
 						NEXT FIELD dat_movto_fim
 					END IF 
 				END IF 
 			END IF
 	END INPUT
 	IF int_flag THEN
		LET int_flag = 0
		CLEAR FORM
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
#------------------------------#
FUNCTION  pol1105_valida_data()#
#------------------------------#
	DEFINE l_con SMALLINT
	
	SELECT COUNT(PER_CONTABIL),dat_ini_seg_per, dat_fim_seg_per
	INTO l_con, p_lista.dat_ini_seg_per, p_lista.dat_fim_seg_per
	FROM PERIODOS
	WHERE COD_EMPRESA=p_cod_empresa
	AND DAT_INI_SEG_PER<=p_entrada.dat_movto_ini
	AND DAT_FIM_SEG_PER>=p_entrada.dat_movto_fim
	GROUP BY DAT_INI_SEG_PER, dat_fim_seg_per

	IF l_con > 0 THEN 
	  LET p_entrada.dat_movto_ini = p_lista.dat_ini_seg_per
	  LET p_entrada.dat_movto_fim = p_lista.dat_fim_seg_per 
	  LET  p_dat_movto_fim_aux    = p_lista.dat_fim_seg_per + 1
		RETURN TRUE
	ELSE
		RETURN FALSE 
	END IF 
END FUNCTION
 
#--------------------------#
FUNCTION  pol1105_den_mes()#														#VERIFICANDO O MES E INSERINDO A DENOMINAÇAO
#--------------------------#														#PARA EXIBIR EM TELA DE POSTERIORMENTE NO RELATORIO
DEFINE 	l_mes			INTEGER
	LET l_mes = MONTH(p_entrada.dat_movto_ini)
	CASE
		WHEN l_mes =  1
			LET p_den_mes = 'JANEIRO'
		WHEN l_mes = 2
			LET p_den_mes = 'FEVEREIRO'
		WHEN l_mes = 3
			LET p_den_mes = 'MARCO'
		WHEN l_mes = 4
			LET p_den_mes = 'ABRIL'
		WHEN l_mes = 5
			LET p_den_mes = 'MAIO'
		WHEN l_mes = 6
			LET p_den_mes = 'JUNHO'
		WHEN l_mes = 7
			LET p_den_mes = 'JULHO'
		WHEN l_mes = 8
			LET p_den_mes = 'AGOSTO'
		WHEN l_mes = 9
			LET p_den_mes = 'SETEMBRO'
		WHEN l_mes = 10
			LET p_den_mes = 'OUTUBRO'
		WHEN l_mes = 11
			LET p_den_mes = 'NOVEMBRO'
		WHEN l_mes = 12
			LET p_den_mes = 'DEZEMBRO'
	END CASE
	
END FUNCTION


#--------------------------------#
FUNCTION pol1105_listar()
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
      "select usu_incl_nf, tip_nota_fiscal, ",
      " sum(val_nota_fiscal), sum(val_mercadoria) ",
      " from fat_nf_mestre "


   LET p_sql = p_sql CLIPPED, ' '," WHERE empresa =  ",p_cod_empresa," "
   LET p_sql = p_sql CLIPPED, ' ',"AND ((TIP_NOTA_FISCAL='FATPRDSV' AND  sit_nota_fiscal='N') OR" 
   LET p_sql = p_sql CLIPPED, ' '," (TIP_NOTA_FISCAL='FATSERV')) " 
   LET p_sql = p_sql CLIPPED, ' ', " and CAST(dat_hor_emissao AS DATE) >= '",p_entrada.dat_movto_ini,"' AND CAST(dat_hor_emissao AS DATE) < '",p_dat_movto_fim_aux,"'" 
   LET p_sql = p_sql CLIPPED, ' ', " group by usu_incl_nf, tip_nota_fiscal"

   

   LET p_filtro =  " Período de ",p_entrada.dat_movto_ini," até ",p_entrada.dat_movto_fim

   PREPARE var_query FROM p_sql   
   DECLARE cq_padrao CURSOR FOR var_query


   FOREACH cq_padrao INTO 
      p_lista.usu_incl_nf, p_lista.tip_nota_fiscal,
      p_lista.val_nota_fiscal, p_lista.val_mercadoria
      
   	OUTPUT TO REPORT pol1105_relat(p_lista.usu_incl_nf) 
      
   	LET p_count = p_count + 1
   	INITIALIZE p_lista TO NULL
                 
   END FOREACH

END FUNCTION

#-----------------------------#
 REPORT pol1105_relat(p_ordem_imp)#
#-----------------------------#
	
	DEFINE 	p_ordem_imp				CHAR(7)
   
	OUTPUT LEFT   MARGIN 0
	TOP    				MARGIN 0
	BOTTOM 				MARGIN 3

	FORMAT
	
	PAGE HEADER  								#----------CABEÇALHO DO RELATORIO-------------
	
         PRINT COLUMN 001, p_descomprime,
                           "------------------------------------------------------------------------------"                     
				 PRINT COLUMN 001, "POL1105",
				 			 COLUMN 030, "RESUMO DE FATURAMENTO",
		           COLUMN 070, "PAG: ", PAGENO USING "###&"
         PRINT
         PRINT COLUMN 020,p_cod_empresa,' - ',p_den_empresa
         PRINT
         PRINT COLUMN 001, p_filtro                
         PRINT COLUMN 001, "------------------------------------------------------------------------------"
         PRINT COLUMN 001, ' USUARIO |TIPO NF. |      VALOR NOTA FISCAL      |       VALOR MERCADORIA     '
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
         PRINT COLUMN 001, '---------|---------|-----------------------------|----------------------------'
         PRINT COLUMN 002, p_lista.usu_incl_nf, 
               COLUMN 010,'|',
               COLUMN 011, p_lista.tip_nota_fiscal, 
               COLUMN 020,'|',
               COLUMN 027, p_lista.val_nota_fiscal USING '###,###,##&.&&', 
               COLUMN 050,'|',
               COLUMN 057, p_lista.val_mercadoria USING '###,###,##&.&&' 
               
      ON LAST ROW 
         PRINT COLUMN 001, "------------------------------------------------------------------------------"
END REPORT

#-----------------------#
 FUNCTION pol1105_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION



