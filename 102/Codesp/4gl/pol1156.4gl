#-----------------------------------------------------------#
# SISTEMA.: RELATORIO DE RAZAO															#
#	PROGRAMA:	pol1156																					#
#	CLIENTE.:	CODESP																					#
#	OBJETIVO:	GERAR RELATORIO DE RAZAO												#
#	AUTOR...:	IVO             																#
#	DATA....:	11/07/2012																			#
#-----------------------------------------------------------#

DATABASE logix
GLOBALS
   DEFINE 
		   	p_cod_empresa   			LIKE empresa.cod_empresa,
		    p_user          			LIKE usuario.nom_usuario,
		    p_den_empresa					LIKE empresa.den_empresa,
			p_men       			CHAR(200),
		    p_num_cgc							LIKE empresa.num_cgc,	
				p_status        			SMALLINT,
				p_versao        			CHAR(18),
				comando         			CHAR(80),
				p_caminho							CHAR(30),
			  p_nom_arquivo					CHAR(100),
			  p_count               INTEGER,
				p_nom_tela 						CHAR(200),
				p_retorno							SMALLINT,
				p_ies_cons      			SMALLINT,
				p_nom_help      			CHAR(200),
				p_den_mes							CHAR(08),
				p_saldo								LIKE saldos.val_saldo_acum,
				p_den_conta						LIKE plano_contas.den_conta,
				p_cont								SMALLINT,
				p_num_conta_reduz			LIKE	plano_contas.num_conta_reduz,
				p_texto								CHAR(300),
				p_ies_impressao       CHAR(01),
				g_ies_ambiente        CHAR(01),
        P_Comprime           CHAR(01),
        p_descomprime        CHAR(01),
        p_6lpp               CHAR(100),
        p_8lpp               CHAR(100),
        p_last_row           SMALLINT,
        p_tex_hist           CHAR(50)
				
END GLOBALS

DEFINE p_data 	RECORD
				data		DATE,
				hora		DATETIME HOUR TO MINUTE 
END RECORD

DEFINE p_entrada RECORD 
				dat_movto_ini			DATE,				
				dat_movto_fim			DATE,				
				num_conta_ini			LIKE plano_contas.num_conta,
				num_conta_fim			LIKE plano_contas.num_conta,
				ies_hist          CHAR(01),
				ies_total         CHAR(01)
END RECORD 

DEFINE p_diario RECORD
				den_sistema_ger				LIKE	lancamentos.den_sistema_ger, 
				per_contabil					LIKE	lancamentos.per_contabil,	
				cod_seg_periodo				LIKE	lancamentos.cod_seg_periodo,
				num_lote							LIKE	lancamentos.num_lote,
				dat_movto							LIKE	lancamentos.dat_movto, 
				ies_tip_lanc					LIKE	lancamentos.ies_tip_lanc, 
				num_conta							LIKE	lancamentos.num_conta,
				num_lanc							LIKE	lancamentos.num_lanc, 
				num_relacionto				LIKE	lanctos_compl.num_relacionto,
				val_lanc							LIKE  ctb_lanc_ctbl_ctb.val_lancto
END RECORD 

DEFINE p_relat RECORD
		num_seq       INTEGER,
		dat_movto     DATE,
		sist_gerador  CHAR(07),
		num_relac     INTEGER,
		ano_movto     CHAR(04),
		mes_movto     CHAR(02),
		num_lote      INTEGER,
		tip_lanc      CHAR(01),
		num_conta     CHAR(23),
		num_conta_red CHAR(10),
		den_conta     CHAR(50),
		num_lanc      INTEGER,
		val_debito    DECIMAL(12,2),
		val_credito   DECIMAL(12,2)
END RECORD

MAIN
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
	  SET ISOLATION TO DIRTY READ
	  SET LOCK MODE TO WAIT 300 
	WHENEVER ANY ERROR STOP
	DEFER INTERRUPT
	LET p_versao = "pol1156-10.02.02"
	INITIALIZE p_nom_help TO NULL  
	CALL log140_procura_caminho("pol1156.iem") RETURNING p_nom_help
	LET  p_nom_help = p_nom_help CLIPPED
	OPTIONS HELP FILE p_nom_help,
	  NEXT KEY control-f,
	  INSERT KEY control-i,
	  DELETE KEY control-e,
	  PREVIOUS KEY control-b
	CALL log001_acessa_usuario("VDP","LIC_LIB")
	  RETURNING p_status, p_cod_empresa, p_user
	IF p_status = 0  THEN
	  CALL pol1156_controle()
	END IF
END MAIN 
#---------------------------#
FUNCTION  pol1156_controle()#
#---------------------------#
	CALL log006_exibe_teclas("01", p_versao)
	CALL log130_procura_caminho("pol1156") RETURNING comando
	OPEN WINDOW w_pol1156 AT 2,2 WITH FORM comando
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	
	LET p_retorno = FALSE 
	MENU "OPCAO"
		COMMAND "Informar"   "Informar parametros "
			HELP 0009
			MESSAGE ""
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				CALL pol1156_entrada_dados() RETURNING p_retorno
				NEXT OPTION "Listar"
			END IF
		
		COMMAND "Listar"  "Lista dados"
			HELP 1053
			IF p_retorno THEN
				IF log005_seguranca(p_user,"VDP","pol0903","MO") THEN
					IF log028_saida_relat(18,35) IS NOT NULL THEN
						MESSAGE " Processando a Extracao do Relatorio..." 
						ATTRIBUTE(REVERSE)
						IF p_ies_impressao = "S" THEN
							IF g_ies_ambiente = "U" THEN
								START REPORT pol1156_relat TO PIPE p_nom_arquivo
							ELSE
								CALL log150_procura_caminho ('LST') RETURNING p_caminho
								LET p_caminho = p_caminho CLIPPED, 'pol0903.tmp'
								START REPORT pol1156_relat  TO p_caminho
							END IF
						ELSE
							START REPORT pol1156_relat TO p_nom_arquivo
						END IF
						IF NOT  pol1156_listar() THEN
							LET p_retorno = FALSE 
							ERROR "Erro ao processar dados "
						END IF   
						FINISH REPORT pol1156_relat 
						LET p_retorno = FALSE   
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
				END IF     
			ELSE
				ERROR "Por favor informar parametros!"
				NEXT OPTION "Informar"
			END IF
			
		COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
			CALL pol1156_sobre() 
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
		COMMAND "Fim" "Retorna ao Menu Anterior"
			HELP 008
			EXIT MENU
	END MENU
	CLOSE WINDOW w_pol1156
END FUNCTION
#-----------------------#
FUNCTION pol1156_sobre()
#-----------------------#

   DEFINE p_dat DATETIME YEAR TO SECOND
   
   LET p_dat = CURRENT
   
   LET p_men = p_versao CLIPPED,"\n\n",
               " Alteração: ",p_dat,"\n\n",
               " LOGIX 10.02 \n\n",
               " Home page: www.aceex.com.br \n\n",
               " (0xx11) 4991-6667 \n\n"

   CALL log0030_mensagem(p_men,'excla')
                  
END FUNCTION
#--------------------------------#
FUNCTION  pol1156_entrada_dados()#
#--------------------------------#
	CALL log006_exibe_teclas("01 02 07", p_versao)
	CLEAR FORM 
 	CURRENT WINDOW IS w_pol0933	
 	DISPLAY p_cod_empresa TO cod_empresa
  LET INT_FLAG = FALSE
 	
 	INITIALIZE p_entrada TO NULL

 	LET p_entrada.ies_hist = 'N'
 	LET p_entrada.ies_total = 'N'
	LET p_entrada.dat_movto_ini = TODAY
 	LET p_entrada.dat_movto_fim = TODAY
   	 	
 	INPUT BY NAME p_entrada.* WITHOUT DEFAULTS
 	
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
 					IF NOT  pol1156_valida_data() THEN 
 						ERROR"Periodo de datas nao podem ser de meses diferentes"
 						NEXT FIELD dat_movto_fim
 					END IF 
 				END IF 
 			END IF 

 		AFTER FIELD num_conta_ini
 			IF p_entrada.num_conta_ini IS NOT NULL THEN 
 				IF NOT pol1156_verifica_conta(p_entrada.num_conta_ini) THEN
 					ERROR"Conta invalida digite o numero da conta novamente" 
 					NEXT FIELD num_conta_ini
 				END IF 
 			END IF

 		BEFORE  FIELD num_conta_fim
 			IF p_entrada.num_conta_ini IS NULL THEN
 			   let p_entrada.num_conta_fim = NULL
 				 NEXT FIELD ies_hist
 			END IF

 		AFTER FIELD num_conta_fim
 			IF p_entrada.num_conta_fim IS NULL THEN
 				ERROR"Campo de Preenchimento Obraigatório"
 				NEXT FIELD num_conta_fim
 			ELSE  
 				IF NOT pol1156_verifica_conta(p_entrada.num_conta_fim) THEN 
 					ERROR"Conta invalida digite o numero da conta novamente" 
 					NEXT FIELD num_conta_fim
 				END IF 
 			END IF
 			
 		ON KEY (control-z)
    	CALL pol1156_popup()  
    	
 	END INPUT
 	
 	IF int_flag THEN
		LET int_flag = 0
		CLEAR FORM
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
#--------------------------#
FUNCTION  pol1156_den_mes()#														#VERIFICANDO O MES E INSERINDO A DENOMINAÇAO
#--------------------------#														#PARA EXIBIR EM TELA DE POSTERIORMENTE NO RELATORIO
DEFINE 	l_mes			INTEGER
	LET l_mes = MONTH(p_diario.cod_seg_periodo)
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
#------------------------------#
FUNCTION  pol1156_valida_data()#
#------------------------------#
	DEFINE l_con SMALLINT
	
	SELECT COUNT(PER_CONTABIL)
	INTO l_con
	FROM PERIODOS
	WHERE COD_EMPRESA=p_cod_empresa
	AND DAT_INI_SEG_PER<=p_entrada.dat_movto_ini
	AND DAT_FIM_SEG_PER>=p_entrada.dat_movto_fim
	
	IF l_con > 0 THEN 
		RETURN TRUE
	ELSE
		RETURN FALSE 
	END IF 
END FUNCTION
#------------------------#
FUNCTION  pol1156_popup()#
#------------------------#
DEFINE p_codigo CHAR(25)
	IF  INFIELD(num_conta_ini) OR INFIELD(num_conta_fim) THEN 
		CALL log009_popup(8,10,"CONTAS","plano_contas",
		"num_conta","den_conta","","S","") 
		RETURNING p_codigo
		CALL log006_exibe_teclas("01 02 07", p_versao)
		CURRENT WINDOW IS w_pol1156
		IF p_codigo IS NOT NULL THEN
			IF  INFIELD(num_conta_ini) THEN 
				LET p_entrada.num_conta_ini = p_codigo CLIPPED
				DISPLAY p_codigo TO num_conta_ini
			ELSE
				LET p_entrada.num_conta_fim = p_codigo CLIPPED
				DISPLAY p_codigo TO num_conta_fim
			END IF 
		END IF
	END IF 
END FUNCTION
#-------------------------------------#
FUNCTION pol1156_verifica_conta(l_num)#
#-------------------------------------#
	DEFINE 	l_den  	LIKE PLANO_CONTAS.DEN_CONTA,
					l_num		LIKE PLANO_CONTAS.NUM_CONTA
	
	SELECT  DEN_CONTA
	INTO l_den
	FROM PLANO_CONTAS
	WHERE COD_EMPRESA = p_cod_empresa
	AND NUM_CONTA 		= l_num
	
	IF SQLCA.SQLCODE <> 0 THEN 
		RETURN FALSE
	ELSE
		IF  INFIELD(num_conta_ini) THEN 
			DISPLAY l_den TO den_conta_ini
		ELSE
			DISPLAY  l_den TO den_conta_fim
		END IF 
		RETURN TRUE 
	END IF 
END FUNCTION
#----------------------------#
FUNCTION pol1156_pega_texto()#
#----------------------------#

	DECLARE cq_texto  CURSOR FOR 	
	  SELECT UNIQUE TEX_HIST, NUM_SEQ_LINHA
		  FROM hist_compl, ctb_lanc_ctbl_ctb
		 WHERE HIST_COMPL.COD_EMPRESA		  =	p_cod_empresa
			AND HIST_COMPL.DEN_SISTEMA_GER	=	p_diario.den_sistema_ger
			AND HIST_COMPL.PER_CONTABIL			=	p_diario.per_contabil
			AND HIST_COMPL.COD_SEG_PERIODO	=	p_diario.cod_seg_periodo
			AND HIST_COMPL.NUM_LOTE					=	p_diario.num_lote
			AND NUM_RELACIONTO 							= p_diario.num_relacionto
			AND NUM_LANC                    = p_diario.num_lanc
			AND EMPRESA =HIST_COMPL.COD_EMPRESA
	  	AND SISTEMA_GERADOR = HIST_COMPL.DEN_SISTEMA_GER
			AND PERIODO_CONTAB =HIST_COMPL.PER_CONTABIL
			AND SEGMTO_PERIODO =HIST_COMPL.COD_SEG_PERIODO
			AND LOTE_CONTAB =HIST_COMPL.NUM_LOTE
			AND NUM_LANCTO=HIST_COMPL.NUM_LANC
		ORDER BY HIST_COMPL.NUM_SEQ_LINHA
																
	FOREACH cq_texto INTO p_tex_hist
 
       LET p_count = p_count + 1
       
       INSERT INTO lanc_temp(num_seq, dat_movto, num_relac, den_conta) 
         VALUES(p_count, p_diario.dat_movto, p_diario.num_relacionto, p_tex_hist)
  
       IF STATUS <> 0 THEN 
		      CALL log003_err_sql('INSERINDO','LANC_TEMP:TEXTO')
		      RETURN FALSE
	     END IF																				
	
	END FOREACH
	
  RETURN TRUE
  	
END FUNCTION

#-------------------------#
FUNCTION  pol1156_listar()#
#-------------------------#

   DEFINE 	l_per_contabil				INTEGER,
				l_cod_seg_periodo			INTEGER,
				l_num_rel							INTEGER,
				l_cod_empresa_plano		CHAR(02),
				l_sql									CHAR(100),
				sql_stmt        			CHAR(999),
   		  p_val_debito          DECIMAL(12,2),
		    p_val_credito         DECIMAL(12,2)
				

   DROP TABLE lanc_temp
   
   CREATE  TABLE lanc_temp(
		num_seq       INTEGER,
		dat_movto     DATE,
		sist_gerador  CHAR(07),
		num_relac     INTEGER,
		ano_movto     CHAR(04),
		mes_movto     CHAR(02),
		num_lote      INTEGER,
		tip_lanc      CHAR(01),
		num_conta     CHAR(23),
		num_conta_red CHAR(10),
		den_conta     CHAR(50),
		num_lanc      INTEGER,
		val_debito    DECIMAL(12,2),
		val_credito   DECIMAL(12,2)
   );
		
	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIACAO","LANC_TEMP")
			RETURN 
	 END IF

  LET p_count = 0

	SELECT DEN_EMPRESA, NUM_CGC 											#BUSCA NOME E CGC DA EMPRESA CORRENTE
	INTO p_den_empresa,
			 p_num_cgc
	FROM EMPRESA 
	WHERE COD_EMPRESA = p_cod_empresa
	
	LET l_sql = ' '
	IF p_entrada.num_conta_ini THEN 
		LET l_sql=" AND A.NUM_CONTA 	BETWEEN '" ,p_entrada.num_conta_ini,"' AND '",p_entrada.num_conta_fim,"' "
	END IF 
	
	LET sql_stmt = 	"SELECT UNIQUE A.DEN_SISTEMA_GER, A.PER_CONTABIL,	A.COD_SEG_PERIODO,A.NUM_LOTE, ",
									"A.DAT_MOVTO, A.IES_TIP_LANC, A.NUM_CONTA,A.NUM_LANC, A.VAL_LANC, B.NUM_RELACIONTO ",
									"FROM lancamentos A, ctb_lanc_ctbl_ctb B ",
									"WHERE A.COD_EMPRESA = '",p_cod_empresa,"' ",
									"AND A.DAT_MOVTO BETWEEN '",p_entrada.dat_movto_ini,"' AND '",p_entrada.dat_movto_fim,"' ",
									l_sql CLIPPED,															
									" AND EMPRESA = A.COD_EMPRESA ",						
									"AND SISTEMA_GERADOR = DEN_SISTEMA_GER ",		
									"AND PERIODO_CONTAB  = PER_CONTABIL ",
									"AND SEGMTO_PERIODO  = COD_SEG_PERIODO ",
									"AND LOTE_CONTAB = NUM_LOTE ",
									"AND NUM_LANCTO = NUM_LANC ",
									"ORDER BY DAT_MOVTO, NUM_RELACIONTO , A.NUM_LANC "
									
	PREPARE var_queri FROM sql_stmt  
	DECLARE cq_conta SCROLL CURSOR WITH HOLD FOR var_queri
																								
	FOREACH cq_conta INTO p_diario.den_sistema_ger, 
												p_diario.per_contabil,	
												p_diario.cod_seg_periodo,
												p_diario.num_lote,							
												p_diario.dat_movto, 
												p_diario.ies_tip_lanc, 
												p_diario.num_conta,
												p_diario.num_lanc,
												p_diario.val_lanc, 
												p_diario.num_relacionto

     IF STATUS <> 0 THEN 
		    CALL log003_err_sql('LENDO','CQ_CONTA')
		    RETURN FALSE
	   END IF																				

		SELECT cod_empresa_plano										
		  INTO l_cod_empresa_plano 										
		  FROM par_con																
 		 WHERE cod_empresa = p_cod_empresa						
 		
 		IF l_cod_empresa_plano IS NOT NULL THEN 		
 		
 			SELECT DEN_CONTA, num_conta_reduz  
			  INTO p_den_conta, p_num_conta_reduz
			  FROM PLANO_CONTAS
			 WHERE COD_EMPRESA  =	l_cod_empresa_plano
			   AND NUM_CONTA 		=	p_diario.num_conta
 		ELSE
			SELECT DEN_CONTA, num_conta_reduz
			  INTO p_den_conta, p_num_conta_reduz
			  FROM PLANO_CONTAS
			 WHERE COD_EMPRESA  =	p_cod_empresa
			   AND NUM_CONTA 		=	p_diario.num_conta
 		END IF 
 		
 		IF STATUS <> 0 THEN 	
 			 INITIALIZE p_den_conta, p_num_conta_reduz TO NULL
 		END IF 

     LET p_count = p_count + 1

     INITIALIZE p_val_debito, p_val_credito TO NULL
     
     IF p_diario.ies_tip_lanc = 'D' THEN
        LET p_val_debito = p_diario.val_lanc
     ELSE
        LET p_val_credito = p_diario.val_lanc
     END IF
     												 
     INSERT INTO lanc_temp
       VALUES(p_count, 
              p_diario.dat_movto,
              p_diario.den_sistema_ger, 
              p_diario.num_relacionto, 
              p_diario.per_contabil,
              p_diario.cod_seg_periodo,
              p_diario.num_lote,
              p_diario.ies_tip_lanc,
              p_diario.num_conta,
              p_num_conta_reduz,
              p_den_conta,
              p_diario.num_lanc,
              p_val_debito,
              p_val_credito)
 		
     IF STATUS <> 0 THEN 
		    CALL log003_err_sql('INSERINDO','LANC_TEMP:DADOS')
		    RETURN FALSE
	   END IF																				
    
    IF p_entrada.ies_hist = 'S' THEN
       IF NOT pol1156_pega_texto() THEN
          RETURN FALSE
       END IF
    END IF
    
	END FOREACH
	
	IF p_count = 0 THEN 
		CALL log0030_mensagem('Não há lançamentos, p/ os parâmetros informados','info')
		RETURN FALSE
	END IF

  IF NOT pol1156_listagem() THEN
     RETURN FALSE
  END IF
   
	RETURN TRUE 

END FUNCTION

#--------------------------#
FUNCTION pol1156_listagem()#
#--------------------------#

   IF NOT pol1156_le_den_empresa() THEN
      RETURN FALSE
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT * 
     FROM lanc_temp 
    ORDER BY num_seq
  
   FOREACH cq_impressao INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN FALSE
      END IF 
      
      OUTPUT TO REPORT pol1156_relat(p_relat.dat_movto, p_relat.num_relac) 

      LET p_count = 1
      
   END FOREACH

   RETURN TRUE
     
END FUNCTION 

#--------------------------------#
 FUNCTION pol1156_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------------------#
 REPORT pol1156_relat(p_dat_movto, p_num_relac)#
#----------------------------------------------#
    
   DEFINE p_dat_movto DATE,
          p_num_relac INTEGER,
          p_dat_imp   DATE,
          p_dat_dia   DATE
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3

          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_comprime, p_cod_empresa, ' - ', p_den_empresa, 
               COLUMN 058, "LANCAMENTOS CONTABEIS - DIARIO GERAL",
               COLUMN 124, "PAG: ", PAGENO USING "###&"
               
         PRINT COLUMN 001, p_versao,
               COLUMN 058, "PERIODO: ", p_entrada.dat_movto_ini, ' - ', p_entrada.dat_movto_fim,
               COLUMN 103, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------------------"
         PRINT COLUMN 001, "DATA     GERADOR RELAC LANCTO   CONTA CONTABIL          REDUZIDA   DESCRICAO                                   DEBITO        CREDITO"
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------------------"

      BEFORE GROUP OF p_dat_movto
         LET p_dat_imp = p_dat_movto
         LET p_dat_dia = p_dat_movto

      ON EVERY ROW

       IF p_relat.sist_gerador IS NOT NULL THEN
          PRINT COLUMN 001, p_dat_imp USING 'dd/mm/yy',
                COLUMN 010, p_relat.sist_gerador, 
                COLUMN 018, p_relat.num_relac USING '#####',
                COLUMN 024, p_relat.num_lanc USING '########',
                COLUMN 033, p_relat.num_conta,
                COLUMN 057, p_relat.num_conta_red,
                COLUMN 068, p_relat.den_conta[1,35],
                COLUMN 104, p_relat.val_debito  USING '###,###,##&.&&',
                COLUMN 119, p_relat.val_credito USING '###,###,##&.&&'
       ELSE
          PRINT COLUMN 052, p_relat.den_conta
       END IF
         
         LET p_dat_imp = NULL

      AFTER GROUP OF p_num_relac
         
         IF p_entrada.ies_total = 'S' THEN
            PRINT COLUMN 088, 'TOTAL DO RELAC:',
                  COLUMN 104, GROUP SUM(p_relat.val_debito)  USING '###,###,##&.&&',
                  COLUMN 119, GROUP SUM(p_relat.val_credito) USING '###,###,##&.&&'
            PRINT
         END IF
         
      AFTER GROUP OF p_dat_movto
      
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------------------"
         PRINT COLUMN 082, 'TOTAL DO DIA:', p_dat_dia USING 'dd/mm/yy', 
               COLUMN 104, GROUP SUM(p_relat.val_debito)  USING '###,###,##&.&&',
               COLUMN 119, GROUP SUM(p_relat.val_credito) USING '###,###,##&.&&'
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------------------"
                              
      ON LAST ROW 

         PRINT
         PRINT COLUMN 084, 'TOTAL DO PERIODO:', 
               COLUMN 104, SUM(p_relat.val_debito)  USING '###,###,##&.&&',
               COLUMN 119, SUM(p_relat.val_credito) USING '###,###,##&.&&'

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT


#-------------------------------- FIM DE PROGRAMA BL-----------------------------#






