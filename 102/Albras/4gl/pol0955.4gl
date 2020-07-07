#-------------------------------------------------------------------------#
# SISTEMA.: MANUTENCAO	DO APONTAMENTOS DE PARADAS		            				#
#	PROGRAMA:	pol0934																												#
#	CLIENTE.:	CODESP																												#
#	OBJETIVO:	Corrigir apontamentos de paradas															#
#	AUTOR...:	THIAGO																												#
#	DATA....:	11/05/2009																										#
#-------------------------------------------------------------------------#

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
				p_nom_help      			CHAR(200),
				p_mudanca							SMALLINT
END GLOBALS 

DEFINE p_w_apont_prod RECORD 
			cod_item CHAR(15), 
				num_seq_registro INTEGER, 
				num_seq_operac DECIMAL(3,0),
				num_ordem INTEGER, 
				num_docum CHAR(10), 
				cod_roteiro CHAR(15), 
				num_altern DECIMAL(2,0), 
				cod_operacao CHAR(5), 
				cod_cent_trab CHAR(5), 
				cod_arranjo CHAR(5), 
				cod_equip CHAR(15), 
				cod_ferram CHAR(15), 
				num_operador CHAR(15), 
				num_lote CHAR(15), 
				hor_ini_periodo DATETIME HOUR TO MINUTE, 
				hor_fim_periodo DATETIME HOUR TO MINUTE, 
				cod_turno DECIMAL(3,0), 
				qtd_boas DECIMAL(10,3), 
				qtd_refug DECIMAL(10,3), 
				qtd_total_horas DECIMAL(10,2), 
				cod_local CHAR(10), 
				cod_local_est CHAR(10), 
				dat_producao DATE, 
				dat_ini_prod DATE, 
				dat_fim_prod DATE, 
				cod_tip_movto CHAR(1), 
				efetua_estorno_total CHAR(1), 
				ies_parada SMALLINT, 
				ies_defeito SMALLINT, 
				ies_sucata SMALLINT, 
				ies_equip_min CHAR(1), 
				ies_ferram_min CHAR(1), 
				ies_sit_qtd CHAR(1), 
				ies_apontamento CHAR(1), 
				tex_apont CHAR(255), 
				num_secao_requis CHAR(10), 
				num_conta_ent CHAR(23), 
				num_conta_saida CHAR(23), 
				num_programa CHAR(8), 
				nom_usuario CHAR(8), 
				observacao CHAR(200), 
				qtd_refug_ant DECIMAL(10,3), 
				qtd_boas_ant DECIMAL(10,3), 
				tip_servico CHAR(1), 
				seq_reg_integra INTEGER, 
				endereco INTEGER, 
				identif_estoque CHAR(30), 
				sku CHAR(25)
END RECORD 
DEFINE p_w_apont_prod1 RECORD 
				cod_item CHAR(15), 
				num_seq_registro INTEGER, 
				num_seq_operac DECIMAL(3,0),
				num_ordem INTEGER, 
				num_docum CHAR(10), 
				cod_roteiro CHAR(15), 
				num_altern DECIMAL(2,0), 
				cod_operacao CHAR(5), 
				cod_cent_trab CHAR(5), 
				cod_arranjo CHAR(5), 
				cod_equip CHAR(15), 
				cod_ferram CHAR(15), 
				num_operador CHAR(15), 
				num_lote CHAR(15), 
				hor_ini_periodo DATETIME HOUR TO MINUTE, 
				hor_fim_periodo DATETIME HOUR TO MINUTE, 
				cod_turno DECIMAL(3,0), 
				qtd_boas DECIMAL(10,3), 
				qtd_refug DECIMAL(10,3), 
				qtd_total_horas DECIMAL(10,2), 
				cod_local CHAR(10), 
				cod_local_est CHAR(10), 
				dat_producao DATE, 
				dat_ini_prod DATE, 
				dat_fim_prod DATE, 
				cod_tip_movto CHAR(1), 
				efetua_estorno_total CHAR(1), 
				ies_parada SMALLINT, 
				ies_defeito SMALLINT, 
				ies_sucata SMALLINT, 
				ies_equip_min CHAR(1), 
				ies_ferram_min CHAR(1), 
				ies_sit_qtd CHAR(1), 
				ies_apontamento CHAR(1), 
				tex_apont CHAR(255), 
				num_secao_requis CHAR(10), 
				num_conta_ent CHAR(23), 
				num_conta_saida CHAR(23), 
				num_programa CHAR(8), 
				nom_usuario CHAR(8), 
				
				observacao CHAR(200), 
				qtd_refug_ant DECIMAL(10,3), 
				qtd_boas_ant DECIMAL(10,3), 
				tip_servico CHAR(1), 
				seq_reg_integra INTEGER, 
				endereco INTEGER, 
				identif_estoque CHAR(30), 
				sku CHAR(25)
END RECORD 
DEFINE audit_prod ARRAY[5000] OF RECORD 
				num_seq_registro INTEGER,
				dat_alteracao DATE,
				hor_alteracao DATETIME HOUR TO SECOND,
				nom_usuario CHAR(8),
				cod_operac	CHAR(1)
END RECORD 
DEFINE p_audit RECORD
				dat_alter_ini DATE,
				dat_alter_fim DATE,
				seq_registro INTEGER,
				usuario CHAR(08),
				operac CHAR(1)
END RECORD 
MAIN
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
		SET ISOLATION TO DIRTY READ
		SET LOCK MODE TO WAIT 11
	WHENEVER ANY ERROR STOP 
	DEFER INTERRUPT 
	LET p_versao = "pol0955-10.02.01"
	INITIALIZE p_nom_help TO NULL  
	CALL log140_procura_caminho("pol0955.iem") RETURNING p_nom_help
	LET  p_nom_help = p_nom_help CLIPPED
	OPTIONS HELP FILE p_nom_help,
	    NEXT KEY control-f,
	    INSERT KEY control-i,
	    PREVIOUS KEY control-b,
	    DELETE KEY control-e
   
    CALL log001_acessa_usuario("VDP","LOGERP")     
       RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0955_controle()
   END IF
END MAIN


#---------------------------#
 FUNCTION pol0955_controle()#
#---------------------------#
	CALL log006_exibe_teclas("01",p_versao)
	INITIALIZE p_nom_tela TO NULL 
	CALL log130_procura_caminho("pol0955") RETURNING p_nom_tela
	LET p_nom_tela = p_nom_tela CLIPPED 
	OPEN WINDOW w_pol0955 AT 1,1 WITH FORM p_nom_tela
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	DISPLAY p_cod_empresa TO cod_empresa
	
	MENU "OPCAO"
		COMMAND "Modificar" "Inclui Dados das Cotas"
			HELP 002
			MESSAGE ""
			LET INT_FLAG = 0
			IF p_ies_cons THEN
				CALL pol0955_alterar()
				ELSE
			ERROR "Consulte Previamente para fazer a Modificacao"
			END IF
		COMMAND "Excluir" "Exclui Dados das Cotas"
			HELP 003
			MESSAGE ""
			LET INT_FLAG = 0
			IF p_ies_cons THEN
				CALL pol0955_excluir()
				ELSE
				ERROR "Consulte Previamente para fazer a Exclusao"
			END IF 
		COMMAND "Consultar" "Consulta Dados das Cotas"
			HELP 004
			MESSAGE "" 
			LET INT_FLAG = 0
			CALL pol0955_consultar()
			IF p_ies_cons THEN
				NEXT OPTION "Seguinte" 
			END IF
		COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
			HELP 005
			MESSAGE ""
			LET INT_FLAG = 0
			CALL pol0955_paginacao("SEGUINTE")
		COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
			HELP 006
			MESSAGE ""
			LET INT_FLAG = 0
			CALL pol0955_paginacao("ANTERIOR")
		COMMAND "Auditoria" "Mostra as mudanças realizadas nos registros"
			HELP 007
			MESSAGE ""
			CALL pol0955_controle_audit()
		COMMAND "Apontar" "Mostra as mudanças realizadas nos registros"
			HELP 007
			MESSAGE ""
			CALL pol0955_processa()
		COMMAND KEY ("!")
		PROMPT "Digite o comando : " FOR comando
		RUN comando
		PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
		DATABASE logix
		LET INT_FLAG = 0
		COMMAND "Fim"       "Retorna ao Menu Anterior"
		HELP 008
		MESSAGE ""
		EXIT MENU
	END MENU
	CLOSE WINDOW w_pol0955
END FUNCTION

#--------------------------------------#
FUNCTION  pol0955_entrada_dados(p_oper)#
#--------------------------------------#
DEFINE p_oper			CHAR(1) # verifica se esta inserindo ou alterando
	CALL log006_exibe_teclas("01 02 07", p_versao)
	CLEAR FORM 
 	CURRENT WINDOW IS w_pol0955	
 	DISPLAY p_cod_empresa TO cod_empresa
 	LET p_mudanca = FALSE 
	INPUT BY NAME p_w_apont_prod.*
								WITHOUT DEFAULTS 
		BEFORE FIELD cod_item 
			NEXT FIELD 
		
		BEFORE FIELD num_seq_registro
			NEXT FIELD 
			
		BEFORE  FIELD num_seq_operac
			NEXT FIELD
			
		AFTER FIELD num_ordem
			IF p_w_apont_prod.num_ordem IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD num_ordem
			END IF 
			
		AFTER FIELD cod_roteiro
			IF p_w_apont_prod.cod_roteiro IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD cod_roteiro
			END IF 	
		
		AFTER FIELD num_altern
			IF p_w_apont_prod.num_altern IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD num_altern
			END IF 
			
		AFTER FIELD cod_operacao
			IF p_w_apont_prod.cod_operacao IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD cod_operacao
			END IF 
		
		AFTER FIELD cod_cent_trab
			IF p_w_apont_prod.cod_cent_trab IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD cod_cent_trab
			END IF 
			
		AFTER FIELD cod_arranjo
			IF p_w_apont_prod.cod_arranjo IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD cod_arranjo
			END IF 
			
		AFTER FIELD cod_equip
			IF p_w_apont_prod.cod_equip IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD cod_equip
			END IF 
			
		AFTER FIELD cod_ferram
			IF p_w_apont_prod.cod_ferram IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD cod_ferram
			END IF 
			
		AFTER FIELD num_operador
			IF p_w_apont_prod.num_operador IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD num_operador
			END IF 
		
		
		AFTER FIELD hor_ini_periodo
			IF p_w_apont_prod.hor_ini_periodo IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD num_lote
			END IF 
		
		AFTER FIELD hor_fim_periodo
			IF p_w_apont_prod.hor_fim_periodo IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD hor_fim_periodo
			END IF 
			
		AFTER FIELD cod_turno
			IF p_w_apont_prod.cod_turno IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD cod_turno
			END IF 
			
		AFTER FIELD qtd_boas
			IF p_w_apont_prod.qtd_boas IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD qtd_boas
			END IF 
			
		AFTER FIELD qtd_refug
			IF p_w_apont_prod.qtd_refug IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD qtd_refug
			END IF 
			
		AFTER FIELD qtd_total_horas
			IF p_w_apont_prod.qtd_total_horas IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD qtd_total_horas
			END IF 
			
		AFTER FIELD cod_local
			IF p_w_apont_prod.cod_local IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD cod_local
			END IF 
			
		AFTER FIELD cod_local_est
			IF p_w_apont_prod.cod_local_est IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD cod_local_est
			END IF 
			
		AFTER FIELD dat_producao
			IF p_w_apont_prod.dat_producao IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD dat_producao
			END IF 
			
		AFTER FIELD dat_ini_prod
			IF p_w_apont_prod.dat_ini_prod IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD dat_ini_prod
			END IF 
			
		AFTER FIELD dat_fim_prod
			IF p_w_apont_prod.dat_fim_prod IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD dat_fim_prod
			END IF 
			
			
		AFTER FIELD cod_tip_movto
			IF p_w_apont_prod.cod_tip_movto IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD cod_tip_movto
			END IF 
			
		AFTER FIELD efetua_estorno_total
			IF p_w_apont_prod.efetua_estorno_total IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD efetua_estorno_total
			ELSE
				IF p_w_apont_prod.efetua_estorno_total <> 'S' AND  p_w_apont_prod.efetua_estorno_total <> 'N' THEN
					ERROR"Valor invalido!"
					NEXT FIELD efetua_estorno_total
				END IF 
			END IF
			 
		AFTER FIELD ies_parada 
			IF p_w_apont_prod.ies_parada IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD ies_parada
			ELSE
				IF p_w_apont_prod.ies_parada <> 0 AND p_w_apont_prod.ies_parada <> 1 THEN
					ERROR"Valor invalido!"
					NEXT FIELD ies_parada
				END IF 
			END IF 
			
		AFTER FIELD ies_defeito
			IF p_w_apont_prod.ies_defeito IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD ies_defeito
			ELSE
				IF p_w_apont_prod.ies_defeito <> 0 AND p_w_apont_prod.ies_defeito <> 1 THEN
					ERROR"Valor invalido!"
					NEXT FIELD ies_defeito
				END IF 
			END IF 
			
		AFTER FIELD ies_sucata
			IF p_w_apont_prod.ies_sucata IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD ies_sucata
			ELSE
				IF p_w_apont_prod.ies_sucata <> 0 AND  p_w_apont_prod.ies_sucata <> 1 THEN
					ERROR"Valor invalido!"
					NEXT FIELD ies_sucata
				END IF 
			END IF 
			
		AFTER FIELD ies_equip_min
			IF p_w_apont_prod.ies_equip_min IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD ies_equip_min
			ELSE
				IF p_w_apont_prod.ies_equip_min <>'S' AND p_w_apont_prod.ies_equip_min <>'N'THEN
					ERROR"Valor invalido!"
					NEXT FIELD ies_equip_min
				END IF 
			END IF 
			
		AFTER FIELD ies_ferram_min
			IF p_w_apont_prod.ies_ferram_min IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD ies_ferram_min
			ELSE
				IF p_w_apont_prod.ies_ferram_min <>'S' AND p_w_apont_prod.ies_ferram_min <> 'N' THEN
					ERROR"Valor invalido!"
					NEXT FIELD
				END IF 
			END IF 
			
		AFTER FIELD ies_sit_qtd
			IF p_w_apont_prod.ies_sit_qtd IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD ies_sit_qtd
			ELSE
				IF p_w_apont_prod.ies_sit_qtd <>'L' AND p_w_apont_prod.ies_sit_qtd <> 'R' THEN
					ERROR"Valor invalido!"
					NEXT FIELD
				END IF 
			END IF
			 
		AFTER FIELD ies_apontamento
			IF p_w_apont_prod.ies_apontamento IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD ies_apontamento
			ELSE
				IF p_w_apont_prod.ies_apontamento <> 0 AND p_w_apont_prod.ies_apontamento <> 1 THEN
					ERROR"Valor invalido!"
					NEXT FIELD
				END IF 
			END IF 
		
		AFTER FIELD num_secao_requis
			IF p_w_apont_prod.num_secao_requis IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD num_secao_requis
			
			END IF
		
		AFTER FIELD num_programa
			IF p_w_apont_prod.num_programa IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD num_programa
			END IF			
		
		
		BEFORE FIELD nom_usuario
			NEXT FIELD 

		
		AFTER FIELD observacao
			IF p_w_apont_prod.observacao IS NULL THEN 
				ERROR"Campo de preencimento Obrigadotório"
				NEXT FIELD observacao
			END IF
	
	AFTER INPUT 
		CASE 
			WHEN FIELD_TOUCHED(cod_item) = TRUE AND p_mudanca = FALSE 			#treco verifica se houve alguma mudança em algum 
				LET p_mudanca = TRUE																					#dos campos para poder gravar na auditoria
			WHEN FIELD_TOUCHED(num_seq_registro) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(num_seq_operac) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(num_ordem) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(num_docum) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(cod_roteiro) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(num_altern) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(cod_operacao) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(cod_cent_trab) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(cod_arranjo) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(cod_equip) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(cod_ferram) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(num_operador) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(num_lote) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(hor_ini_periodo) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(hor_fim_periodo) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(cod_turno) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(qtd_boas) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(qtd_refug) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(qtd_total_horas) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(cod_local) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(cod_local_est) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(dat_producao) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(dat_ini_prod) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(dat_fim_prod) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(cod_tip_movto) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(efetua_estorno_total) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(ies_parada) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(ies_defeito) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(ies_sucata) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(ies_equip_min) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(ies_ferram_min) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(ies_sit_qtd) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(ies_apontamento) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(tex_apont) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(num_secao_requis) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(num_conta_ent) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(num_conta_saida) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(num_programa) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(nom_usuario) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(observacao) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(qtd_refug_ant) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(qtd_boas_ant) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(tip_servico) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(seq_reg_integra) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(endereco) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(identif_estoque) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
			WHEN FIELD_TOUCHED(sku) = TRUE AND p_mudanca = FALSE 
				LET p_mudanca = TRUE 
		END CASE 
	END INPUT
	IF int_flag = 1 THEN
		LET int_flag = 0
		LET p_mudanca = FALSE 
		CLEAR FORM
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION

#-------------------------#
FUNCTION pol0955_incluir()#
#-------------------------#
	INITIALIZE p_w_apont_prod TO NULL 
	IF pol0955_entrada_dados('I') THEN
		CALL log085_transacao("BEGIN")
		INSERT INTO apont_prog912 VALUES (p_w_apont_prod.*)
			IF SQLCA.SQLCODE<>0 THEN
				CALL log003_err_sql('Incluir','apont_prog912')
				CLEAR FORM 
				INITIALIZE p_w_apont_prod.* TO NULL 
				ERROR"Inclusão cancelada!"
				RETURN FALSE 
			ELSE
				CALL log085_transacao("COMMIT")
				MESSAGE"Dados incuidos com sucesso!!"
				RETURN TRUE
			END IF 
	ELSE
		CLEAR FORM 
		INITIALIZE p_w_apont_prod TO NULL 
		ERROR"Inclusão cancelada!"
		RETURN FALSE 
	END IF 
END FUNCTION 
#-------------------------#
FUNCTION pol0955_excluir()#
#-------------------------#
	IF pol0955_cursor_para_alterar() THEN
		IF log004_confirm(18,35) THEN
			WHENEVER ERROR CONTINUE
			
			INSERT INTO audit_apont_prog912(cod_empresa, num_seq_registro, dat_alteracao,hor_alteracao,nom_usuario,cod_operac)
						VALUES(p_cod_empresa,p_w_apont_prod.num_seq_registro, CURRENT ,CURRENT, p_user,'E' )
			IF SQLCA.SQLCODE <> 0 THEN 
				CALL log085_transacao("ROLLBACK")											#se excluirem o registro grava na auditoria
				CALL log003_err_sql("INCLUIR","audit_apont_prog912")
			END IF 
			
			UPDATE apont_prog912
				SET ies_processado ='E'
			WHERE CURRENT OF cm_padrao
			IF SQLCA.SQLCODE = 0 THEN
				CALL log085_transacao("COMMIT")
				MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
				INITIALIZE p_w_apont_prod.* TO NULL
				CLEAR FORM
				DISPLAY p_cod_empresa TO cod_empresa
			ELSE
				CALL log085_transacao("ROLLBACK")
				CALL log003_err_sql("EXCLUSAO","apont_prog912")
			END IF
			WHENEVER ERROR STOP
		ELSE
			CALL log085_transacao("ROLLBACK")
		END IF
	#	CLOSE cm_padrao
	END IF
END FUNCTION 
#--------------------------------------#
 FUNCTION pol0955_cursor_para_alterar()#
#--------------------------------------#
WHENEVER ERROR CONTINUE
DECLARE cm_padrao CURSOR WITH HOLD FOR	SELECT  COD_ITEM,NUM_SEQ_REGISTRO,NUM_SEQ_OPERAC,NUM_ORDEM,NUM_DOCUM,COD_ROTEIRO,
																								NUM_ALTERN,COD_OPERACAO,COD_CENT_TRAB,
																								COD_ARRANJO,COD_EQUIP,COD_FERRAM,NUM_OPERADOR,NUM_LOTE,
																								HOR_INI_PERIODO,HOR_FIM_PERIODO,COD_TURNO,QTD_BOAS,QTD_REFUG,
																								QTD_TOTAL_HORAS,COD_LOCAL,COD_LOCAL_EST,DAT_PRODUCAO,DAT_INI_PROD,
																								DAT_FIM_PROD,COD_TIP_MOVTO,EFETUA_ESTORNO_TOTAL,IES_PARADA ,
																								IES_DEFEITO,IES_SUCATA,IES_EQUIP_MIN,IES_FERRAM_MIN,IES_SIT_QTD,
																								IES_APONTAMENTO,TEX_APONT,NUM_SECAO_REQUIS,NUM_CONTA_ENT,NUM_CONTA_SAIDA,
																								NUM_PROGRAMA,NOM_USUARIO,OBSERVACAO,
																								QTD_REFUG_ANT,QTD_BOAS_ANT,TIP_SERVICO,SEQ_REG_INTEGRA,
																								ENDERECO,IDENTIF_ESTOQUE,SKU 
																					INTO p_w_apont_prod.*                                              
																					FROM apont_prog912
																					WHERE COD_EMPRESA = p_cod_empresa
																					#AND IES_PROCESSADO = 'P'
																					AND NUM_SEQ_REGISTRO= p_w_apont_prod.num_seq_registro
																					FOR UPDATE 
	CALL log085_transacao("BEGIN")   
	OPEN cm_padrao
	FETCH cm_padrao
		CASE SQLCA.SQLCODE
			WHEN    0 RETURN TRUE 
			WHEN -250 ERROR " Registro sendo atualizado por outro usua",
			    "rio. Aguarde e tente novamente."
			WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
			    "ute a CONSULTA novamente."
			OTHERWISE CALL log003_err_sql("LEITURA","apont_prog912")
		END CASE
	CALL log085_transacao("ROLLBACK")
WHENEVER ERROR STOP
RETURN FALSE
END FUNCTION
#-------------------------#
FUNCTION pol0955_alterar()#
#-------------------------#
DEFINE 	l_hor_ini_periodo			CHAR(20),
				l_hor_fim_periodo			CHAR(20)

	IF pol0955_cursor_para_alterar() THEN
		LET p_w_apont_prod1.* = p_w_apont_prod.*
		IF pol0955_entrada_dados('A') THEN
			LET l_hor_ini_periodo	=	p_w_apont_prod.hor_ini_periodo
			LET l_hor_fim_periodo	=	p_w_apont_prod.hor_fim_periodo
			WHENEVER ERROR CONTINUE
				IF p_mudanca THEN 
					INSERT INTO audit_apont_prog912(cod_empresa, num_seq_registro, dat_alteracao,hor_alteracao,nom_usuario,cod_operac)
						VALUES(p_cod_empresa,p_w_apont_prod.num_seq_registro, CURRENT ,CURRENT, p_user,'A' )
					IF SQLCA.SQLCODE <> 0 THEN									# se haver mudança no registro ele vai gravar na tabela de 
						CALL log085_transacao("ROLLBACK")					#auditoria 
						CALL log003_err_sql("MODIFICACAO","audit_apont_prog912")
					END IF
				END IF 
			
				UPDATE apont_prog912
				SET num_ordem 						= p_w_apont_prod.num_ordem,
						num_docum							= p_w_apont_prod.num_docum,
						cod_roteiro						= p_w_apont_prod.cod_roteiro,
						num_altern						= p_w_apont_prod.num_altern,
						cod_operacao					= p_w_apont_prod.cod_operacao,
						num_seq_operac				= p_w_apont_prod.num_seq_operac,
						cod_cent_trab					= p_w_apont_prod.cod_cent_trab,
						cod_arranjo						= p_w_apont_prod.cod_arranjo,
						cod_equip							= p_w_apont_prod.cod_equip,
						cod_ferram						= p_w_apont_prod.cod_ferram,
						num_operador					= p_w_apont_prod.num_operador,
						num_lote							= p_w_apont_prod.num_lote,
						hor_ini_periodo				= l_hor_ini_periodo,
						hor_fim_periodo				= l_hor_fim_periodo,
						cod_turno							= p_w_apont_prod.cod_turno,
						qtd_boas							= p_w_apont_prod.qtd_boas,
						qtd_refug							= p_w_apont_prod.qtd_refug,
						qtd_total_horas				= p_w_apont_prod.qtd_total_horas,
						cod_local							= p_w_apont_prod.cod_local,
						cod_local_est					= p_w_apont_prod.cod_local_est,
						dat_producao					= p_w_apont_prod.dat_producao,
						dat_ini_prod					= p_w_apont_prod.dat_ini_prod,
						dat_fim_prod					= p_w_apont_prod.dat_fim_prod,
						cod_tip_movto					= p_w_apont_prod.cod_tip_movto,
						efetua_estorno_total	= p_w_apont_prod.efetua_estorno_total,
						ies_parada 						= p_w_apont_prod.ies_parada,
						ies_defeito						= p_w_apont_prod.ies_defeito,
						ies_sucata						= p_w_apont_prod.ies_sucata,
						ies_equip_min					= p_w_apont_prod.ies_equip_min,
						ies_ferram_min				= p_w_apont_prod.ies_ferram_min,
						ies_sit_qtd						= p_w_apont_prod.ies_sit_qtd,
						ies_apontamento				= p_w_apont_prod.ies_apontamento,
						tex_apont							= p_w_apont_prod.tex_apont,
						num_secao_requis			= p_w_apont_prod.num_secao_requis,
						num_conta_ent					= p_w_apont_prod.num_conta_ent,
						num_conta_saida				= p_w_apont_prod.num_conta_saida,
						num_programa					= p_w_apont_prod.num_programa,
						nom_usuario						= p_w_apont_prod.nom_usuario,
						observacao						= p_w_apont_prod.observacao,
						qtd_refug_ant					= p_w_apont_prod.qtd_refug_ant,
						qtd_boas_ant					= p_w_apont_prod.qtd_boas_ant,
						tip_servico						= p_w_apont_prod.tip_servico,
						seq_reg_integra				= p_w_apont_prod.seq_reg_integra,
						endereco							= p_w_apont_prod.endereco,
						identif_estoque				= p_w_apont_prod.identif_estoque,
						sku 									= p_w_apont_prod.sku
				WHERE CURRENT OF cm_padrao
		
				IF SQLCA.SQLCODE = 0 THEN
					CALL log085_transacao("COMMIT")
					MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
				ELSE
					CALL log085_transacao("ROLLBACK")
					CALL log003_err_sql("MODIFICACAO","apont_prog912")
				END IF
		ELSE
			CALL log085_transacao("ROLLBACK")
			LET p_w_apont_prod.* = p_w_apont_prod1.*
			ERROR "Modificacao Cancelada"
			CALL pol0955_exibe_dados()
		END IF
			CLOSE cm_padrao
	END IF
END FUNCTION 
#---------------------------#
FUNCTION pol0955_consultar()#
#---------------------------#
DEFINE  where_clause, sql_stmt		CHAR(900)				

	CLEAR FORM
	DISPLAY p_cod_empresa TO cod_empresa
	LET p_w_apont_prod1.* = p_w_apont_prod.*
	
	CONSTRUCT BY NAME where_clause ON COD_ITEM,
																		NUM_SEQ_REGISTRO,
																		NUM_ORDEM,
																		NUM_DOCUM,
																		COD_ROTEIRO,
																		NUM_ALTERN,
																		COD_OPERACAO,
																		NUM_SEQ_OPERAC,
																		COD_CENT_TRAB,
																		COD_ARRANJO,
																		COD_EQUIP,
																		COD_FERRAM,
																		NUM_OPERADOR,
																		NUM_LOTE,
																		HOR_INI_PERIODO,
																		HOR_FIM_PERIODO,
																		COD_TURNO,
																		QTD_BOAS,
																		QTD_REFUG,
																		QTD_TOTAL_HORAS,
																		COD_LOCAL,
																		COD_LOCAL_EST,
																		DAT_PRODUCAO,
																		DAT_INI_PROD,
																		DAT_FIM_PROD,
																		COD_TIP_MOVTO,
																		EFETUA_ESTORNO_TOTAL,
																		IES_PARADA ,
																		IES_DEFEITO,
																		IES_SUCATA,
																		IES_EQUIP_MIN,
																		IES_FERRAM_MIN,
																		IES_SIT_QTD,
																		IES_APONTAMENTO,
																		TEX_APONT,
																		NUM_SECAO_REQUIS,
																		NUM_CONTA_ENT,
																		NUM_CONTA_SAIDA,
																		NUM_PROGRAMA,
																		NOM_USUARIO,
																		OBSERVACAO,
																		QTD_REFUG_ANT,
																		QTD_BOAS_ANT,
																		TIP_SERVICO,
																		SEQ_REG_INTEGRA,
																		ENDERECO,
																		IDENTIF_ESTOQUE,
																		SKU 
		ON KEY(control-z)
							
	END CONSTRUCT
	CALL log006_exibe_teclas("01",p_versao)
	CURRENT WINDOW IS w_pol0955
	IF INT_FLAG THEN
		LET INT_FLAG = 0 
		LET p_w_apont_prod.* = p_w_apont_prod1.*
		#CALL pol0955_exibe_dados()
		ERROR "Consulta Cancelada"
	RETURN
	END IF
	LET sql_stmt = 	"SELECT  COD_ITEM,NUM_SEQ_REGISTRO,NUM_SEQ_OPERAC,NUM_ORDEM,NUM_DOCUM,COD_ROTEIRO,",
									"	NUM_ALTERN,COD_OPERACAO,COD_CENT_TRAB,",
									"	COD_ARRANJO,COD_EQUIP,COD_FERRAM,NUM_OPERADOR,NUM_LOTE,",
									"	HOR_INI_PERIODO,HOR_FIM_PERIODO,COD_TURNO,QTD_BOAS,QTD_REFUG,",
									"	QTD_TOTAL_HORAS,COD_LOCAL,COD_LOCAL_EST,DAT_PRODUCAO,DAT_INI_PROD,",
									"	DAT_FIM_PROD,COD_TIP_MOVTO,EFETUA_ESTORNO_TOTAL,IES_PARADA ,",
									"	IES_DEFEITO,IES_SUCATA,IES_EQUIP_MIN,IES_FERRAM_MIN,IES_SIT_QTD,",
									"	IES_APONTAMENTO,TEX_APONT,NUM_SECAO_REQUIS,NUM_CONTA_ENT,NUM_CONTA_SAIDA,",
									"	NUM_PROGRAMA,NOM_USUARIO,OBSERVACAO,",
									"	QTD_REFUG_ANT,QTD_BOAS_ANT,TIP_SERVICO,SEQ_REG_INTEGRA,",
									"	ENDERECO,IDENTIF_ESTOQUE,SKU",
									"	FROM apont_prog912 ",
									" WHERE " ,where_clause CLIPPED,  
						   		" AND cod_empresa = '",p_cod_empresa,"' ",
						   		" AND IES_PROCESSADO = 'P' ",
						    	" ORDER BY num_seq_registro "
	
	PREPARE var_query FROM sql_stmt   
	DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
	OPEN cq_padrao
	FETCH cq_padrao INTO p_w_apont_prod.*
	IF SQLCA.SQLCODE = NOTFOUND THEN
		ERROR "Argumentos de Pesquisa nao Encontrados"
		LET p_ies_cons = FALSE
	ELSE 
		LET p_ies_cons = TRUE
		CALL pol0955_exibe_dados()
	END IF
END FUNCTION 
#-----------------------------------#
FUNCTION pol0955_paginacao(p_funcao)#
#-----------------------------------#
DEFINE p_funcao CHAR(20)
	IF p_ies_cons THEN
		LET p_w_apont_prod1.* = p_w_apont_prod.*
		WHILE TRUE
			CASE
				WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO  p_w_apont_prod.*
				WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO  p_w_apont_prod.*
			END CASE
			IF SQLCA.SQLCODE = NOTFOUND THEN
				ERROR "Nao Existem Mais Itens Nesta Direção"
				LET p_w_apont_prod.* = p_w_apont_prod1.* 
				EXIT WHILE
			END IF
			SELECT  COD_ITEM,NUM_SEQ_REGISTRO,NUM_SEQ_OPERAC,NUM_ORDEM,NUM_DOCUM,COD_ROTEIRO,
							NUM_ALTERN,COD_OPERACAO,COD_CENT_TRAB,
							COD_ARRANJO,COD_EQUIP,COD_FERRAM,NUM_OPERADOR,NUM_LOTE,
							HOR_INI_PERIODO,HOR_FIM_PERIODO,COD_TURNO,QTD_BOAS,QTD_REFUG,
							QTD_TOTAL_HORAS,COD_LOCAL,COD_LOCAL_EST,DAT_PRODUCAO,DAT_INI_PROD,
							DAT_FIM_PROD,COD_TIP_MOVTO,EFETUA_ESTORNO_TOTAL,IES_PARADA ,
							IES_DEFEITO,IES_SUCATA,IES_EQUIP_MIN,IES_FERRAM_MIN,IES_SIT_QTD,
							IES_APONTAMENTO,TEX_APONT,NUM_SECAO_REQUIS,NUM_CONTA_ENT,NUM_CONTA_SAIDA,
							NUM_PROGRAMA,NOM_USUARIO,OBSERVACAO,COD_ITEM_GRADE1,
							COD_ITEM_GRADE2,COD_ITEM_GRADE3,COD_ITEM_GRADE4,COD_ITEM_GRADE5,
							QTD_REFUG_ANT,QTD_BOAS_ANT,TIP_SERVICO,SEQ_REG_INTEGRA,
							ENDERECO,IDENTIF_ESTOQUE,SKU
			INTO p_w_apont_prod.* 
			FROM apont_prog912
			WHERE cod_empresa    = p_cod_empresa
			AND NUM_SEQ_REGISTRO= p_w_apont_prod.num_seq_registro
			IF SQLCA.SQLCODE = 0 THEN  
				CALL pol0955_exibe_dados()
				EXIT WHILE
			END IF
		END WHILE
	ELSE
		ERROR "Nao Existe Nenhuma Consulta Ativa"
	END IF
END FUNCTION 


#--------------------------#
FUNCTION pol0955_processa()#
#--------------------------#
	#WHENEVER ERROR CONTINUE
	#	INSERT INTO apont_prog912
	#	SELECT * FROM apont_prog912
	#	WHERE ies_processado = 'N'
	#	AND cod_empresa = p_cod_empresa
	#	ORDER BY num_ordem,num_seq_operac
	#WHENEVER ERROR STOP 
	
	#IF SQLCA.SQLCODE =  0 THEN
		CALL log120_procura_caminho("pol0941") RETURNING comando
		LET comando = comando CLIPPED , " ","pol0972"
		RUN comando RETURNING p_status   
	#ELSE
	#	CALL log003_err_sql("Insert","apont_apont912")
	#END IF 
	
END FUNCTION

#-----------------------------#
FUNCTION pol0955_exibe_dados()#
#-----------------------------#
	DISPLAY p_cod_empresa TO cod_empresa
	DISPLAY BY NAME p_w_apont_prod.*
END FUNCTION

#-------------------------------#
FUNCTION pol0955_entrada_audit()#
#-------------------------------#

	LET p_audit.dat_alter_fim = CURRENT 
	LET p_audit.dat_alter_ini = '01/01/1900'
	LET p_audit.seq_registro = NULL 

	INPUT BY NAME p_audit.* WITHOUT DEFAULTS
		
		AFTER FIELD dat_alter_ini
			IF p_audit.dat_alter_ini IS NULL THEN 
				ERROR"Campo de preenchimento obrigatório"
				NEXT FIELD dat_alter_ini
			END IF 
			
		AFTER FIELD dat_alter_fim
			 
			IF p_audit.dat_alter_fim IS NOT NULL THEN 
				IF p_audit.dat_alter_fim < p_audit.dat_alter_ini THEN 
					ERROR"Data final nao pode ser maior que data final"
					NEXT FIELD dat_alter_fim
				END IF  
			ELSE 
				ERROR"Campo de preenchimento obrigatório"
				NEXT FIELD dat_alter_fim
			END IF 
	END INPUT
	IF int_flag = 1 THEN
		LET int_flag = 0
		CLEAR FORM
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION

#--------------------------------#
FUNCTION pol0955_consulta_audit()#
#--------------------------------#
	DEFINE  where_clause, sql_stmt		CHAR(900),
					l_cont 										SMALLINT

	DISPLAY p_cod_empresa TO cod_empresa
	
	IF NOT  pol0955_entrada_audit() THEN
		RETURN 
	END IF 
	IF 	p_audit.seq_registro IS NOT NULL THEN
		LET where_clause = "AND num_seq_registro =' ",p_audit.seq_registro,"' "
	END IF 
	
	IF 	p_audit.usuario IS NOT NULL THEN
		LET where_clause = where_clause CLIPPED," ","AND nom_usuario = '",p_audit.usuario,"' "
	END IF
	
	IF p_audit.operac IS NOT NULL THEN
		LET where_clause = where_clause CLIPPED," "," AND cod_operac = '",p_audit.operac, "'"
	END IF
	
	LET l_cont = 1
	
	LET sql_stmt = 	"SELECT num_seq_registro, dat_alteracao, ",
									" hor_alteracao,nom_usuario,cod_operac ",
									" FROM audit_apont_prog912 ",
									" WHERE cod_empresa = '",p_cod_empresa,"' ",
									" AND dat_alteracao BETWEEN  '",p_audit.dat_alter_ini ,"' AND '" ,p_audit.dat_alter_fim,"' ",
									where_clause,
						    	" ORDER BY dat_alteracao, num_seq_registro "
	
	PREPARE var_queri FROM sql_stmt   
	DECLARE cq_audit SCROLL CURSOR WITH HOLD FOR var_queri
	FOREACH cq_audit INTO audit_prod[l_cont].*
		LET l_cont = l_cont + 1
	  #	IF audit_prod[l_cont].nom_usuario IS NULL  THEN 
	   #		EXIT FOREACH
	  #	ELSE 
			IF l_cont>5000 THEN 
				EXIT FOREACH
			END IF 
	 #	END IF 
	END FOREACH
	IF SQLCA.SQLCODE = NOTFOUND THEN
		ERROR "Argumentos de Pesquisa nao Encontrados"
	ELSE 
		CALL SET_COUNT(l_cont - 1)
		INPUT ARRAY audit_prod WITHOUT DEFAULTS FROM s_audit.*
      BEFORE INPUT
         EXIT INPUT
   	END INPUT
	END IF
END FUNCTION

#---------------------------------#
 FUNCTION pol0955_controle_audit()#
#---------------------------------#
	CALL log006_exibe_teclas("01",p_versao)
	INITIALIZE p_nom_tela TO NULL 
	LET p_nom_tela = p_nom_tela CLIPPED
	CALL log130_procura_caminho("pol09551") RETURNING p_nom_tela
	OPEN WINDOW w_pol09551 AT 1,1 WITH FORM p_nom_tela
		ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
		DISPLAY p_cod_empresa TO cod_empresa
	{
	LET p_nom_tela = p_nom_tela CLIPPED #,'1'
		OPEN WINDOW w_pol09551 AT 1,1 WITH FORM p_nom_tela
		ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
		DISPLAY p_cod_empresa TO cod_empresa}
	MENU "OPCAO"
		COMMAND "Consultar" "Consulta Dados"
			HELP 008
			MESSAGE "" 
			LET INT_FLAG = 0
			CALL pol0955_consulta_audit()
		
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
			DATABASE logix
			LET INT_FLAG = 0
		COMMAND "Fim"       "Retorna ao Menu Anterior"
			HELP 0010
			MESSAGE ""
			EXIT MENU
	END MENU
	CLOSE WINDOW w_pol09551
END FUNCTION