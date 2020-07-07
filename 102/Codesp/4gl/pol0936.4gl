#-----------------------------------------------------------#
# SISTEMA.: EXPORTAÇÃO DE DADOS DA FATURA 									#
#	PROGRAMA:	POL000																					#
#	CLIENTE.:	CODESP																					#
#	OBJETIVO:	EXPORTAR DADOS DAS FATURAS IMPORTADAS PREVIAMANT#
#																														#
#	AUTOR...:	THIAGO																					#
#	DATA....:	18/05/2009																			#
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
				p_nom_help      			CHAR(200),
				p_data_fim						DATE,
				p_data_ini						DATE,
				p_cont								SMALLINT
END GLOBALS 
DEFINE p_exporta	 RECORD 	
				cod_empresa			CHAR(02) ,
				num_docum				DECIMAL(6,0),
				especie					CHAR(02),
				data_emissao_fa	DATE ,
				data_emissao_nf	DATE,
				num_nff					DECIMAL(6,0),
				num_transac 		INTEGER
END RECORD
DEFINE p_arquivo RECORD
			cod_empresa	CHAR(02),
			num_docum	INTEGER ,
			especie	CHAR(02) ,
			data_emissao_fa	DATE ,
			data_emissao_nf	DATE ,
			num_nff	INTEGER
END RECORD 

DEFINE 	p_cod_parametro  	LIKE 	par_solc_fat_codesp.cod_parametro,
				p_cam_export			LIKE  par_solc_fat_codesp.cam_export
			 	
#----#
MAIN #
#----#
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
		SET ISOLATION TO DIRTY READ
		SET LOCK MODE TO WAIT 300 
	WHENEVER ANY ERROR STOP
	DEFER INTERRUPT
	LET p_versao = "pol0934-10.02.00"
	INITIALIZE p_nom_help TO NULL  
	CALL log140_procura_caminho("pol0933.iem") RETURNING p_nom_help
	LET p_nom_help = p_nom_help CLIPPED
	OPTIONS HELP FILE p_nom_help,
		NEXT KEY control-f,
		INSERT KEY control-i,
		DELETE KEY control-e,
		PREVIOUS KEY control-b
	CALL log001_acessa_usuario("VDP","LIC_LIB")
	RETURNING p_status, p_cod_empresa, p_user
	IF p_status = 0  THEN
		CALL pol0936_controle()
	END IF
END MAIN
#---------------------------#
FUNCTION  pol0936_controle()#
#---------------------------#
DEFINE p_processa SMALLINT 
	CALL log006_exibe_teclas("01", p_versao)
	CALL log130_procura_caminho("pol0936") RETURNING comando
	OPEN WINDOW w_pol0936 AT 5,3 WITH FORM comando
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	LET p_processa = FALSE 
	MENU "OPCAO"
		COMMAND "Informar"   "Informar parametros "
			HELP 0009
			MESSAGE ""
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				IF pol0936_entrada_dados() THEN
					LET p_processa = TRUE 
					NEXT OPTION "Processar"
				END IF
			END IF
		COMMAND "Processar"  "Processar importação de faturas"
			HELP 1053
			IF p_processa THEN 
				IF pol0936_processar() THEN #INSERIR FUNÇÃO AQUI AINDA
					MESSAGE"Exportação de dados concluido com sucesso"
					LET p_processa = FALSE			
				ELSE
					ERROR"Erro ao exportar os dados"
					LET p_processa = TRUE
				END IF
			ELSE
				ERROR"Informar parametros previamente"
			END IF 
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
		COMMAND "Fim" "Retorna ao Menu Anterior"
			HELP 008
			EXIT MENU
	END MENU
	CLOSE WINDOW w_pol0936
END FUNCTION 
#---------------------------------#
FUNCTION pol0936_entrada_dados() #									
#---------------------------------#
	CALL log006_exibe_teclas("01 02 07", p_versao)
	INITIALIZE p_cod_parametro TO NULL 
	CLEAR FORM 
	DISPLAY p_cod_empresa TO cod_empresa
	INPUT  p_cod_parametro,p_data_ini,p_data_fim WITHOUT DEFAULTS FROM cod_parametro,data_ini,data_fim
	BEFORE INPUT 
		LET p_data_ini = TODAY
		LET p_data_fim = TODAY
	AFTER FIELD cod_parametro
			IF p_cod_parametro IS NULL THEN
				ERROR"Campo de preenchimento obrigatório"
				NEXT FIELD cod_parametro
			ELSE 
				IF NOT  pol0936_valida_par() THEN
					ERROR"Parametro nao cadastrado"
					NEXT FIELD cod_parametro
				END IF 
			END IF 
	#BEFORE  FIELD data_ini	
	#	LET p_data_ini = TODAY
	AFTER FIELD data_ini
		IF p_data_ini IS NULL THEN
			ERROR"Campo de preenchimento obrigatório"
			NEXT FIELD data_ini
		END IF
	#BEFORE  FIELD data_fim
	#	LET p_data_fim = TODAY
	AFTER FIELD data_fim
		IF p_data_fim IS NULL THEN
			ERROR"Campo de preenchimento obrigatório"
			NEXT FIELD data_fim
		ELSE
			IF p_data_fim < p_data_ini THEN
				ERROR"Data final tem que ser maior que a data inicial"
				NEXT FIELD data_fim
			ELSE 
				IF p_data_fim > TODAY  THEN
					ERROR"Data final tem que ser menor ou igual a data atual"
					NEXT FIELD data_fim
				END IF 
			END IF 
		END IF
		ON KEY (control-z)
		CALL pol0936_popup()
	END INPUT
	IF int_flag THEN
		LET int_flag = 0
		CLEAR FORM
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
#---------------------------------#
FUNCTION pol0936_cria_temp_table()#									#criaçao da tabela temporaria da qual
#---------------------------------#									#vai ajudar na geração do aruivo
	WHENEVER ERROR CONTINUE
		DROP TABLE t_exp_fat_nfs
		CREATE TEMP TABLE t_exp_fat_nfs(
			cod_empresa	CHAR(02) NOT NULL ,
			num_docum	INTEGER NOT NULL ,
			especie	CHAR(02) NOT NULL ,
			data_emissao_fa	DATE NOT NULL ,
			data_emissao_nf	DATE NOT NULL ,
			num_nff	INTEGER
		)
		IF SQLCA.SQLCODE<> 0 THEN
			CALL log003_err_sql("CRIAR","t_exp_fat_nfs")
			RETURN FALSE 
		ELSE 
			RETURN TRUE 
		END IF 
	WHENEVER ERROR STOP 
END FUNCTION 
#------------------------------#
FUNCTION pol0936_processar()#
#------------------------------#
DEFINE 	p_data_char		CHAR(10),
				p_hora_char		CHAR(5),
				p_data				DATE,
				p_hora 				DATETIME HOUR TO MINUTE,
				l_msg					CHAR(200)
	DISPLAY p_cod_empresa TO cod_empresa
	LET  p_cont = 0
	IF pol0936_cria_temp_table() THEN
		CALL log085_transacao('BEGIN') 	# Aqui estou procurando as notas que ja foram faturadas 
																		#	e vendo na tablela qua nao foram exportadas ainda
		DECLARE cq_export CURSOR WITH HOLD FOR	SELECT cod_empresa,num_docum,especie,
																						data_emissao_fa,data_emissao_nf, nota_fiscal, num_transac
																						FROM rel_fat_nfs_codesp REL, FAT_NF_MESTRE FAT
																						WHERE  empresa = cod_empresa
																						AND FAT.TRANS_NOTA_FISCAL = REL.num_transac
																						AND fat.nota_fiscal <> rel.num_docum
																						#AND rel.num_nff is NULL
																						AND DATA_EMISSAO_FA BETWEEN p_data_ini AND p_data_fim
																						AND cod_empresa = p_cod_empresa
																						ORDER BY nota_fiscal	
																					
		IF SQLCA.SQLCODE = 100 THEN
			CALL log0030_mensagem("Nenhum dado encontrado","")
		END IF																							
		FOREACH cq_export INTO p_exporta.*
			INSERT INTO t_exp_fat_nfs VALUES( p_exporta.cod_empresa,
																				p_exporta.num_docum,
																				p_exporta.especie,
																				p_exporta.data_emissao_fa,
																				p_exporta.data_emissao_nf	,
																				p_exporta.num_nff)

			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERIR","t_exp_fat_nfs")
				CALL log085_transacao('ROLLBACK') 
				RETURN FALSE 
			END IF
			UPDATE rel_fat_nfs_codesp														#atualizo a tabela rel_fat_nfs_codesp 	
				SET num_nff = p_exporta.num_nff										#adicionando o numero da nota ja faturado
			WHERE num_transac = p_exporta.num_transac
			AND num_nff IS NULL 
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("ATUALIZAR","rel_fat_nfs_codesp")
				CALL log085_transacao('ROLLBACK') 
				RETURN FALSE 
			END IF
			MESSAGE"Processando",p_exporta.num_nff
			LET p_cont = p_cont+1	
		END FOREACH
		IF	p_cont = 0 THEN 
			CALL log0030_mensagem("Nenhum registro foi encontrado!",'info')
			RETURN FALSE
		END IF 
	ELSE 
		ERROR"Erro ao processar dados!!!"
		RETURN FALSE 
	END IF 
	WHENEVER ERROR CONTINUE
		LET p_data = CURRENT 								#convertendo a data e a hora para que possa			
		LET p_hora = CURRENT								#nomear o arquivo de texto
		LET p_data_char = p_data 
		LET p_hora_char = p_hora
		
		LET p_nom_arquivo = p_cam_export CLIPPED,"NFS_",p_data_char[1,2],p_data_char[4,5],p_data_char[7,10],p_hora_char[1,2],p_hora_char[4,5], '.txt'
		
		START REPORT pol0936_relat TO  p_nom_arquivo
		DECLARE cq_exp  CURSOR WITH HOLD FOR		#fazendo o Unload ta tabela para 		
					SELECT * FROM t_exp_fat_nfs				#gerar o arquvo de texto desejado
		
		FOREACH cq_exp INTO p_arquivo.*
			OUTPUT TO REPORT  pol0936_relat()
		
		END FOREACH
		
		FINISH REPORT  pol0936_relat
		LET l_msg = "Foram exportados ",p_cont," no caminho ", p_nom_arquivo
		CALL log0030_mensagem(l_msg,'info') 
		MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
		 							
			CALL log085_transacao('COMMIT') 
 		RETURN TRUE 
	WHENEVER ERROR STOP 
END FUNCTION 
#-------------------------------#
FUNCTION pol0936_valida_par()#
#-------------------------------#
DEFINE l_den_parametro LIKE par_solc_fat_codesp.den_parametro

	SELECT den_parametro, cam_export
	INTO 	l_den_parametro,
				p_cam_export
	FROM par_solc_fat_codesp
	WHERE cod_parametro = p_cod_parametro
	IF SQLCA.SQLCODE<> 0 THEN
		RETURN FALSE
	ELSE
		DISPLAY l_den_parametro TO den_parametro
		RETURN TRUE 
	END IF 
END FUNCTION
#-----------------------#
FUNCTION pol0936_popup()#
#-----------------------#
DEFINE p_codigo  			CHAR(15)
      
	CASE
		WHEN INFIELD(cod_parametro)
			CALL log009_popup(8,10,"CODIGO DO PARAMETRO","par_solc_fat_codesp",
						"cod_parametro","den_parametro","","S","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0936
			IF p_codigo IS NOT NULL THEN
				LET p_cod_parametro = p_codigo CLIPPED
				DISPLAY p_codigo TO cod_parametro
			END IF
	END CASE 

END FUNCTION

#---------------------#
 REPORT pol0936_relat()#
#----------------------#
DEFINE g_num_docum,g_num_nff CHAR(06)
   
   OUTPUT LEFT   MARGIN 0  
           TOP    MARGIN 0  
           BOTTOM MARGIN 0
           PAGE   LENGTH 1
    
    FORMAT 
       ON EVERY ROW 
       			LET g_num_docum =p_arquivo.num_docum 
       			LET g_num_nff =p_arquivo.num_nff
            PRINT p_arquivo.cod_empresa	 CLIPPED,"|" ,
									g_num_docum CLIPPED,"|" , 
									p_arquivo.especie CLIPPED,"|" , 
									p_arquivo.data_emissao_fa CLIPPED,"|" , 
									p_arquivo.data_emissao_nf CLIPPED,"|" , 
									g_num_nff CLIPPED,"|" 
   					
         
END REPORT