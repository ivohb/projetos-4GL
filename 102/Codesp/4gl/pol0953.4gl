#-----------------------------------------------------------#
# SISTEMA.: IMPORTAÇAO DE SOLICITAÇÃO DE TEXTOS FISCAIS			#
#	PROGRAMA:	pol0953																					#
#	CLIENTE.:	CODESP																					#
#	OBJETIVO:	SUBSTITUIR TEXTOS FISCAIS  PARA GERAR SPEED			#
#	AUTOR...:	THIAGO																					#
#	DATA....:	11/05/2009																			#
#-----------------------------------------------------------#

DATABASE logix
GLOBALS
   DEFINE 
		   	p_cod_empresa   			LIKE empresa.cod_empresa,
		    p_user          			LIKE usuario.nom_usuario,
				p_status        			SMALLINT,
				p_versao        			CHAR(18),
				p_resposta						SMALLINT,
				comando         			CHAR(80),
				p_caminho							CHAR(30),
			  p_nom_arquivo					CHAR(100),
				p_nom_tela 						CHAR(200),
				p_retorno							SMALLINT,
				p_ies_cons      			SMALLINT,
				p_cont								SMALLINT,
				p_nom_help      			CHAR(200)
END GLOBALS 
DEFINE  p_entrada RECORD 
				cod_periodo			DATETIME YEAR TO YEAR,
				seg_periodo DATETIME MONTH TO MONTH
END RECORD 
MAIN
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
	  SET ISOLATION TO DIRTY READ
	  SET LOCK MODE TO WAIT 300 
	WHENEVER ANY ERROR STOP
	DEFER INTERRUPT
	LET p_versao = "pol0953-10.02.03"
	INITIALIZE p_nom_help TO NULL  
	CALL log140_procura_caminho("pol0953.iem") RETURNING p_nom_help
	LET  p_nom_help = p_nom_help CLIPPED
	OPTIONS HELP FILE p_nom_help,
	  NEXT KEY control-f,
	  INSERT KEY control-i,
	  DELETE KEY control-e,
	  PREVIOUS KEY control-b
	CALL log001_acessa_usuario("VDP","LIC_LIB")
	  RETURNING p_status, p_cod_empresa, p_user
	IF p_status = 0  THEN
	  CALL pol0953_controle()
	END IF
END MAIN 

#---------------------------#
FUNCTION  pol0953_controle()#
#---------------------------#
	CALL log006_exibe_teclas("01", p_versao)
	CALL log130_procura_caminho("pol0953") RETURNING comando
	OPEN WINDOW w_pol0953 AT 5,3 WITH FORM comando
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	
	LET p_retorno = FALSE 
	MENU "OPCAO"
		COMMAND "Informar"   "Informar parametros "
			HELP 0009
			MESSAGE ""
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				CALL pol0953_entrada_parametro() RETURNING p_retorno
				NEXT OPTION "Processar"
			END IF
		
		COMMAND "Processar"  "Processar dados"
			HELP 1053
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				IF retorno THEN
						MESSAGE "ProcessANDo..."
						CALL log085_transacao('BEGIN') 
					 	IF pol0953_processar() THEN
					 	 	MESSAGE "Foram processados ",p_cont," registros"
					 	 	CALL log085_transacao('COMMIT') 
					 	 	LET p_resposta = FALSE
					 		 NEXT OPTION "Fim"
					 	ELSE
					 		ERROR "Erro ao Processar Dados"
					 		CALL log085_transacao('ROLLBACK') 
					 		LET p_resposta = FALSE 
					 		NEXT OPTION "Informar" 
					 	END IF 
				 ELSE
				 	ERROR "Informar parametros!"
				 	NEXT OPTION "Informar"
				 END IF
			END IF
		
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
		COMMAND "Fim" "Retorna ao Menu Anterior"
			HELP 008
			EXIT MENU
	END MENU
	CLOSE WINDOW w_pol0953
END FUNCTION 

#----------------------------------#
FUNCTION pol0953_entrada_parametro()#
#----------------------------------#
	CALL log006_exibe_teclas("01 02 07",p_versao)
	CURRENT WINDOW IS w_pol0953
	DISPLAY p_cod_empresa TO cod_empresa
	INITIALIZE p_entrada.* TO NULL 
	INPUT  p_entrada.* WITHOUT DEFAULTS FROM cod_periodo,seg_periodo 
		AFTER FIELD cod_periodo
			IF p_entrada.cod_periodo IS NULL THEN 
				ERROR 'Campo de preencimento obrigatório!!!'
				NEXT FIELD cod_periodo
			END IF 
		AFTER FIELD seg_periodo
			IF p_entrada.seg_periodo IS NULL THEN 
				ERROR 'Campo de preencimento obrigatório!!!'
				NEXT FIELD seg_periodo
			END IF 
	END INPUT
	
	IF INT_FLAG = 0 THEN
		LET p_retorno = TRUE
	ELSE
		CLEAR FORM
		DISPLAY p_cod_empresa TO cod_empresa
		LET INT_FLAG = 0
		LET p_retorno =FALSE
	END IF
	RETURN p_retorno
END FUNCTION
#----------------------------#
 FUNCTION pol0953_processar()#
#----------------------------#
DEFINE l_int_periodo SMALLINT,
			 l_int_seg_per SMALLINT

DEFINE p_hist_compl RECORD 
				empresa							LIKE hist_compl.cod_empresa,
				sistema_gerador			LIKE hist_compl.den_sistema_ger,
				periodo_contab			LIKE hist_compl.per_contabil,
				segmto_periodo			LIKE hist_compl.cod_seg_periodo,
				lote_controle				LIKE hist_compl.num_lote,
				num_lancto					LIKE hist_compl.num_lanc,
				seq_reg_hist_compl	LIKE hist_compl.num_seq_linha,
				texto_hist_compl		LIKE ctb_compl_hist.texto_hist_compl
END RECORD 			 
	
	
	 
	LET l_int_periodo = YEAR(p_entrada.cod_periodo)
	LET l_int_seg_per = MONTH(p_entrada.seg_periodo)
	LET p_cont = 0
			 
	DELETE  FROM  HIST_COMPL 
	WHERE COD_EMPRESA=p_cod_empresa
	AND   DEN_SISTEMA_GER='CON'
	AND   PER_CONTABIL= l_int_periodo
	AND   COD_SEG_PERIODO= l_int_seg_per
	
	IF SQLCA.SQLCODE <> 0 THEN
		CALL log003_err_sql('DELETAR','HIST_COMPL')
		RETURN FALSE
	END IF 
	
	DECLARE cq_insert CURSOR FOR 	SELECT DISTINCT  A.EMPRESA,
													       				A.SISTEMA_GERADOR,
																       A.PERIODO_CONTAB,
																       A.SEGMTO_PERIODO,
																       A.LOTE_CONTROLE,
																       B.NUM_LANCTO,
																       A.SEQ_REG_HIST_COMPL,
																       A.TEXTO_HIST_COMPL
																	FROM CTB_COMPL_HIST A, CTB_LANC_CTBL_CTB B
																	WHERE A.EMPRESA=B.EMPRESA
																	AND   A.SISTEMA_GERADOR=B.SISTEMA_GERADOR
																	AND   A.PERIODO_CONTAB=B.PERIODO_CONTAB
																	AND   A.SEGMTO_PERIODO=B.SEGMTO_PERIODO
																	AND   A.SEQ_LOTE_CONTROLE=B.SEQ_LOTE_CONTROLE
																	AND   A.PERIODO_CONTAB=l_int_periodo
																	AND   A.SEGMTO_PERIODO=l_int_seg_per
																	AND   A.SISTEMA_GERADOR = 'CON'
																	AND 	A.EMPRESA = p_cod_empresa
													
	IF SQLCA.SQLCODE <> 0 THEN
		CALL log003_err_sql('PROCURAR','CTB_COMPL_HIST/CTB_LANC_CTBL_CTB')
		RETURN FALSE
	END IF 
	FOREACH cq_insert INTO p_hist_compl.*
		
		INSERT INTO HIST_COMPL VALUES (p_hist_compl.*)
		
		IF SQLCA.SQLCODE <> 0 THEN
			CALL log003_err_sql('INSERIR','HIST_COMPL')
			RETURN FALSE
		END IF 
		LET p_cont = p_cont + 1
	END FOREACH
	
	UPDATE LANCAMENTOS   SET IES_COMPL_HIST='S'
	WHERE PER_CONTABIL=l_int_periodo
	AND COD_SEG_PERIODO= l_int_seg_per
	AND COD_EMPRESA= p_cod_empresa
	AND   DEN_SISTEMA_GER= 'CON'
	
	IF SQLCA.SQLCODE <> 0 THEN
		CALL log003_err_sql('LANCAMENTOS','HIST_COMPL')
		RETURN FALSE
	END IF 
	RETURN TRUE 
END FUNCTION