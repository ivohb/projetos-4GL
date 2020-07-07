#-------------------------------------------------------------------#
# SISTEMA.: Cadastro de Parametros para carga NF Saida - Fame			  #
# PROGRAMA: pol0988                                                 #
# OBJETIVO: PARAMETROS DE NOTA FISCAIS 															#
# AUTOR...: POLO INFORMATICA - THIAGO                               #
# DATA....: 16/03/2009                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_msg                CHAR(100),
          p_ies_impressao      CHAR(01),  
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080)

END GLOBALS
DEFINE 	p_par_nf_912 RECORD LIKE par_nf_912.* , 
				p_par_nf_91201 RECORD LIKE par_nf_912.*

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0988-10.02.03"
   INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0988.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0988_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0988_controle()
#--------------------------#

  
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0988") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0988 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0988_inclusao() RETURNING p_status
      COMMAND "Modificar" "Inclui Dados das Cotas"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0988_modificacao()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados das Cotas"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0988_exclusao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados das Cotas"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0988_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0988_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0988_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0988","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0988_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0988.tmp'
                     START REPORT pol0988_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0988_relat TO p_nom_arquivo
               END IF
               CALL pol0988_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0988_relat   
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
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol0988_sobre() 
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
   CLOSE WINDOW w_pol0988
   
END FUNCTION

#-----------------------#
FUNCTION pol0988_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#--------------------------#
 FUNCTION pol0988_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   IF pol0988_entrada_dados("INCLUSAO") THEN
      
      WHENEVER ERROR CONTINUE
      
      CALL log085_transacao("BEGIN")
      INSERT INTO par_nf_912 VALUES (p_par_nf_912.*)
      IF SQLCA.SQLCODE <> 0 THEN 
				 LET p_houve_erro = TRUE
				 CALL log003_err_sql("INCLUSAO","par_nf_912")       
			ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
      WHENEVER ERROR STOP
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      INITIALIZE p_par_nf_912 TO NULL
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0988_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0988
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_par_nf_912 TO NULL
      CALL pol0988_exibe_dados()
   END IF
		LET p_par_nf_912.cod_empresa = p_cod_empresa
		
    INPUT  	p_par_nf_912.cod_param,
						p_par_nf_912.den_param,
						p_par_nf_912.ser_nff,
						p_par_nf_912.cod_nat_oper,
						p_par_nf_912.cod_cnd_pgto,
						p_par_nf_912.cod_tip_carteira,
						p_par_nf_912.cod_cliente,
						p_par_nf_912.cod_transportador,
						p_par_nf_912.ies_finalidade,
						p_par_nf_912.cod_texto,
						p_par_nf_912.cod_moeda,
						p_par_nf_912.cod_local,
						p_par_nf_912.cod_local1
		WITHOUT DEFAULTS	FROM 	cod_param,
														den_param,
														ser_nff,
														cod_nat_oper,
														cod_cnd_pgto,
														cod_tip_carteira,
														cod_cliente,
														cod_transportador,
														ies_finalidade,
														cod_texto,
														cod_moeda,
														cod_local,
														cod_local1
          
	    BEFORE FIELD cod_param	
	    	IF p_funcao <> "INCLUSAO" THEN
	    		NEXT FIELD den_param
	    	END IF
			AFTER FIELD cod_param	
				IF p_par_nf_912.cod_param IS NULL THEN 
					ERROR"Campo de preenchimento obrigat�rio!!!"
					NEXT FIELD cod_param
				ELSE
					IF pol0988_verifica_duplicidade() THEN 
						ERROR"Codigo j� cadastrado!!!"
						NEXT FIELD cod_param
					ELSE
						NEXT FIELD den_param
					END IF
				END IF 
			AFTER FIELD den_param	
				IF p_par_nf_912.den_param IS NULL THEN 
					ERROR"Campo de preenchimento obrigat�rio!!!"
					NEXT FIELD den_param
				ELSE
					NEXT FIELD ser_nff
				END IF 
			
			AFTER FIELD ser_nff
				IF p_par_nf_912.ser_nff IS NULL THEN
					ERROR"Campo de preenchimento obrigat�rio!!!" 
					NEXT FIELD ser_nff
				ELSE
					IF NOT pol0988_valida_ser_nff() THEN 
						ERROR"Codigo invalido!!!"
						NEXT FIELD ser_nff
					ELSE
						NEXT FIELD cod_nat_oper
					END IF
				END IF 
			AFTER FIELD cod_nat_oper
				IF p_par_nf_912.cod_nat_oper IS NULL  THEN 
					ERROR"Campo de preenchimento obrigat�rio!!!"
					NEXT FIELD cod_nat_oper
				ELSE
					IF NOT pol0988_valida_cod_nat_oper() THEN 
						ERROR"Codigo invalido!!!"
						NEXT FIELD cod_nat_oper
					ELSE
						NEXT FIELD cod_cnd_pgto	
					END IF
				END IF 
			AFTER FIELD cod_cnd_pgto	
				IF p_par_nf_912.cod_cnd_pgto IS NULL  THEN 
					ERROR"Campo de preenchimento obrigat�rio!!!"
					NEXT FIELD cod_cnd_pgto	
				ELSE
					IF NOT pol0988_valida_cod_cnd_pgto() THEN 
						ERROR"Codigo invalido!!!"
						NEXT FIELD cod_cnd_pgto
					ELSE
						NEXT FIELD cod_tip_carteira
					END IF
				END IF 
			AFTER FIELD cod_tip_carteira
				IF p_par_nf_912.cod_tip_carteira IS NULL THEN 
					ERROR"Codigo invalido!!!"
					ERROR"Campo de preenchimento obrigat�rio!!!"
					NEXT FIELD cod_tip_carteira
				ELSE
					IF NOT pol0988_valida_cod_tip_carteira() THEN 
						ERROR"Codigo invalido!!!"
					NEXT FIELD cod_tip_carteira
					ELSE
						NEXT FIELD cod_cliente
					END IF
				END IF 
			AFTER FIELD cod_cliente	
				IF p_par_nf_912.cod_cliente IS NULL THEN
					ERROR"Campo de preenchimento obrigat�rio!!!"
					NEXT FIELD cod_cliente
				ELSE
					IF NOT pol0988_valida_cod_cliente() THEN 
						ERROR"Codigo invalido!!!"
						NEXT FIELD cod_cliente
					ELSE
						NEXT FIELD cod_transportador
					END IF
				END IF 
			AFTER FIELD cod_transportador
				IF p_par_nf_912.cod_transportador IS NULL THEN 
					ERROR"Campo de preenchimento obrigat�rio!!!"
					NEXT FIELD cod_transportador
				ELSE
					IF NOT pol0988_valida_cod_transportador() THEN 
						ERROR"Codigo invalido!!!"
						NEXT FIELD cod_transportador
					ELSE
						NEXT FIELD ies_finalidade
					END IF
				END IF 
			AFTER FIELD ies_finalidade
				IF p_par_nf_912.ies_finalidade IS NULL THEN 
					ERROR"Campo de preenchimento obrigat�rio!!!"
					NEXT FIELD ies_finalidade 
				ELSE
					IF p_par_nf_912.ies_finalidade<>'1' AND p_par_nf_912.ies_finalidade<>'2' AND p_par_nf_912.ies_finalidade<>'3' THEN 
						ERROR"Codigo invalido!!!"
						NEXT FIELD ies_finalidade
					ELSE
						NEXT FIELD cod_texto
					END IF
				END IF 
			AFTER FIELD cod_texto	
				IF p_par_nf_912.cod_texto IS NOT  NULL  THEN 
					IF NOT pol0988_valida_cod_texto() THEN 
						NEXT FIELD cod_texto
					ELSE
						NEXT FIELD cod_moeda
					END IF
				END IF 
				AFTER FIELD cod_moeda
				IF p_par_nf_912.cod_moeda IS NULL THEN
					ERROR"Campo de preenchimento obrigat�rio!!!"
					NEXT FIELD cod_moeda
				ELSE
					IF NOT pol0988_valida_cod_cod_moeda() THEN 
						ERROR"Codigo invalido!!!"
						NEXT FIELD cod_moeda
					END IF
				END IF
			AFTER FIELD cod_local
				IF p_par_nf_912.cod_local IS NULL THEN
					ERROR"Campo de preenchimento obrigat�rio!!!"
					NEXT FIELD cod_local
				ELSE
					NEXT FIELD cod_local1
				END IF 
			AFTER FIELD cod_local1
				IF p_par_nf_912.cod_local1 IS NULL THEN
					ERROR"Campo de preenchimento obrigat�rio!!!"
					NEXT FIELD cod_local1
				END IF   
			ON KEY (control-z)
			CALL pol0988_popup()                   
    END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0988

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION
#--------------------------------------#
FUNCTION pol0988_valida_cod_cod_moeda()#
#--------------------------------------#
DEFINE 	l_den 					CHAR(35)
	SELECT den_moeda 
	INTO l_den
	FROM moeda
	WHERE cod_moeda =p_par_nf_912.cod_moeda
	
	IF SQLCA.SQLCODE <>0 THEN 
		RETURN FALSE 
	ELSE
		DISPLAY l_den TO den_moeda
		RETURN TRUE 
	END IF 
END FUNCTION

#----------------------------------#
FUNCTION pol0988_valida_cod_texto()#
#----------------------------------#
DEFINE 	l_den 					CHAR(35)
	
	IF (p_par_nf_912.cod_texto IS null)
	OR (p_par_nf_912.cod_texto = ' ')  THEN 
	    RETURN TRUE 
	END IF    
	
	
	SELECT DES_TEXTO 
	INTO l_den
	FROM TEXTO_NF
	WHERE COD_TEXTO =p_par_nf_912.cod_texto
	
	IF SQLCA.SQLCODE <>0 THEN 
		RETURN FALSE 
	ELSE
		DISPLAY l_den TO des_texto
		RETURN TRUE 
	END IF 
END FUNCTION

#------------------------------------------#
FUNCTION pol0988_valida_cod_transportador()#
#------------------------------------------#
DEFINE 	l_den 					CHAR(35)
	SELECT NOM_CLIENTE
	INTO l_den 
	FROM CLIENTES
	WHERE COD_CLIENTE =p_par_nf_912.cod_transportador
	
	IF SQLCA.SQLCODE <>0 THEN 
		RETURN FALSE 
	ELSE
		DISPLAY l_den TO nom_transp
		RETURN TRUE 
	END IF 
END FUNCTION

#------------------------------------#
FUNCTION pol0988_valida_cod_cliente()#
#------------------------------------#
DEFINE 	l_den 					CHAR(35)

	SELECT NOM_CLIENTE 
	INTO l_den
	FROM CLIENTES
	WHERE COD_CLIENTE =p_par_nf_912.cod_cliente
	
	IF SQLCA.SQLCODE <>0 THEN 
		RETURN FALSE 
	ELSE
		DISPLAY l_den TO nom_cliente
		RETURN TRUE 
	END IF 
END FUNCTION

#-----------------------------------------#
FUNCTION pol0988_valida_cod_tip_carteira()#
#-----------------------------------------#
DEFINE l_den CHAR(35)

	SELECT DEN_TIP_CARTEIRA 
	INTO l_den
	FROM TIPO_CARTEIRA
	WHERE COD_TIP_CARTEIRA = p_par_nf_912.cod_tip_carteira
	
	IF SQLCA.SQLCODE <>0 THEN 
		RETURN FALSE
	ELSE
		DISPLAY l_den TO den_tip_carteira
		RETURN TRUE 
	END IF 
END FUNCTION
#--------------------------------------#
FUNCTION pol0988_valida_cod_cnd_pgto()#
#--------------------------------------#
DEFINE l_den CHAR(35)

	SELECT DEN_CND_PGTO 
	INTO l_den
	FROM COND_PGTO
	WHERE COD_CND_PGTO =p_par_nf_912.cod_cnd_pgto
	
	IF SQLCA.SQLCODE <>0 THEN 
		RETURN FALSE
	ELSE
		DISPLAY l_den TO den_cnd_pgto
		RETURN TRUE 
	END IF 
	
END FUNCTION

#-------------------------------------#
FUNCTION pol0988_valida_cod_nat_oper()#
#-------------------------------------#
DEFINE l_den CHAR(35)

	SELECT DEN_NAT_OPER
	INTO l_den
	FROM NAT_OPERACAO
	WHERE COD_NAT_OPER =p_par_nf_912.cod_nat_oper

	IF SQLCA.SQLCODE <>0 THEN 
		RETURN FALSE
	ELSE
		DISPLAY l_den TO den_nat_oper 
		RETURN TRUE 
	END IF 
END FUNCTION

#--------------------------------#
FUNCTION pol0988_valida_ser_nff()#
#--------------------------------#

   SELECT serie_docum 
     FROM vdp_num_docum
    WHERE empresa = p_cod_empresa
      AND tip_docum = 'FATECF'
      AND serie_docum = p_par_nf_912.ser_nff 

	{SELECT ser_nff 
	FROM FAT_NUMERO_SER
	WHERE cod_empresa =p_cod_empresa
	AND ser_nff =p_par_nf_912.ser_nff}
	
	IF SQLCA.SQLCODE <> 0 THEN 
		RETURN FALSE
	ELSE
		RETURN TRUE 
	END IF 

END FUNCTION

#-----------------------#
FUNCTION pol0988_popup() #
#-----------------------#
   DEFINE p_codigo  CHAR(15)

	CASE 
		WHEN INFIELD(cod_moeda)
			CALL log009_popup(8,10,"Moeda","moeda",
				"cod_moeda","den_moeda","pat0140","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0988
			IF p_codigo IS NOT NULL THEN
				LET p_par_nf_912.cod_moeda = p_codigo CLIPPED
				DISPLAY p_codigo TO cod_moeda
			END IF 
		WHEN INFIELD(ser_nff)
			CALL log009_popup(8,10,"Serie Nota Fiscal","vdp_num_docum",
				"serie_docum","dat_emis_ult_docum","","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0988
			IF p_codigo IS NOT NULL THEN
				LET p_par_nf_912.ser_nff = p_codigo CLIPPED
				DISPLAY p_codigo TO ser_nff
			END IF 
		WHEN INFIELD(cod_nat_oper)
			CALL log009_popup(8,10,"Natureza De Opera��o","NAT_OPERACAO",
				"COD_NAT_OPER","DEN_NAT_OPER","vdp0050","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0988
			IF p_codigo IS NOT NULL THEN
				LET p_par_nf_912.cod_nat_oper= p_codigo CLIPPED
				DISPLAY p_codigo TO cod_nat_oper
			END IF 
			
		WHEN INFIELD(cod_cnd_pgto)	
			CALL log009_popup(8,10,"CONDI��O DE PAGAMENTO","COND_PGTO",
				"cod_cnd_pgto","DEN_CND_PGTO","vdp0140","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0988
			IF p_codigo IS NOT NULL THEN
				LET p_par_nf_912.cod_cnd_pgto = p_codigo CLIPPED
				DISPLAY p_codigo TO cod_cnd_pgto 
			END IF 
		WHEN INFIELD(cod_tip_carteira)
			CALL log009_popup(8,10,"Tipo De Carteira","TIPO_CARTEIRA",
				"COD_TIP_CARTEIRA","den_tip_carteira","vdp6310","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0988
			IF p_codigo IS NOT NULL THEN
				LET p_par_nf_912.cod_tip_carteira = p_codigo CLIPPED
				DISPLAY p_codigo TO cod_tip_carteira 
			END IF 
		WHEN INFIELD(cod_cliente)	
			LET p_codigo = vdp372_popup_cliente()
      CALL log006_exibe_teclas("01 02 03 07", p_versao)
      CURRENT WINDOW IS w_pol0988
			IF p_codigo IS NOT NULL THEN
				LET p_par_nf_912.cod_cliente = p_codigo CLIPPED
				DISPLAY p_codigo TO cod_cliente
			END IF 
      
		WHEN INFIELD(cod_transportador)
			LET p_codigo = vdp372_popup_cliente()
      CALL log006_exibe_teclas("01 02 03 07", p_versao)
      CURRENT WINDOW IS w_pol0988
			IF p_codigo IS NOT NULL THEN
				LET p_par_nf_912.cod_transportador = p_codigo CLIPPED
				DISPLAY p_codigo TO cod_transportador 
			END IF 
			
		WHEN INFIELD(cod_texto)
			CALL log009_popup(8,10,"Texto Nota Fiscal","TEXTO_NF",
				"COD_TEXTO","DES_TEXTO","vdp0390","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0988
			IF p_codigo IS NOT NULL THEN
				LET p_par_nf_912.cod_texto = p_codigo CLIPPED
				DISPLAY p_codigo TO cod_texto
		END IF 	
	END CASE
END FUNCTION 

#--------------------------------------#
 FUNCTION pol0988_verifica_duplicidade()
#--------------------------------------#
   SELECT den_param
     FROM par_nf_912
    WHERE cod_empresa = p_cod_empresa
      AND cod_param = p_par_nf_912.cod_param
   
   IF SQLCA.SQLCODE = 0 THEN
      RETURN TRUE
   ELSE 
      RETURN FALSE
   END IF 
      
END FUNCTION 

#--------------------------#
 FUNCTION pol0988_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_par_nf_91201.*= p_par_nf_912.*

	CONSTRUCT BY NAME where_clause ON cod_param	,
																		den_param,
																		ser_nff,
																		cod_nat_oper,
																		cod_cnd_pgto,
																		cod_tip_carteira,
																		cod_cliente,
																		cod_transportador,
																		ies_finalidade,
																		cod_texto,
																		cod_moeda,
																		cod_local,
																		cod_local1

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0988

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
    	LET p_par_nf_912.* = p_par_nf_91201.*
      CALL pol0988_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT par_nf_912.* FROM par_nf_912 ",
                  " WHERE ",where_clause CLIPPED,             
                  " and cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY cod_param "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_par_nf_912.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0988_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0988_exibe_dados()
#------------------------------#
DEFINE l_booleana				SMALLINT
	 CLEAR FORM

   DISPLAY p_cod_empresa TO cod_empresa
   DISPLAY BY NAME p_par_nf_912.*
   CALL pol0988_valida_cod_cliente() RETURNING l_booleana
   CALL pol0988_valida_cod_nat_oper() RETURNING l_booleana
   CALL pol0988_valida_cod_texto() RETURNING l_booleana
   CALL pol0988_valida_cod_tip_carteira() RETURNING l_booleana
   CALL pol0988_valida_cod_transportador() RETURNING l_booleana
	 CALL pol0988_valida_cod_cnd_pgto() RETURNING l_booleana
	 CALL pol0988_valida_ser_nff() RETURNING l_booleana
	 CALL pol0988_valida_cod_cod_moeda() RETURNING l_booleana
   
END FUNCTION
   
   
#-----------------------------------#
 FUNCTION pol0988_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT * INTO p_par_nf_912.*                                              
      FROM par_nf_912
         WHERE cod_empresa	= p_cod_empresa
           AND cod_param		= p_par_nf_912.cod_param
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
      OTHERWISE CALL log003_err_sql("LEITURA","par_nf_912")
   END CASE
   CALL log085_transacao("ROLLBACK")
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0988_modificacao()
#-----------------------------#

   IF pol0988_cursor_for_update() THEN
      LET p_par_nf_91201.* = p_par_nf_912.*
      IF pol0988_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         
         			UPDATE par_nf_912
            		SET den_param					= p_par_nf_912.den_param ,
										ser_nff						= p_par_nf_912.ser_nff,
										cod_nat_oper			= p_par_nf_912.cod_nat_oper,
										cod_cnd_pgto			= p_par_nf_912.cod_cnd_pgto,
										cod_tip_carteira	= p_par_nf_912.cod_tip_carteira,
										cod_cliente				= p_par_nf_912.cod_cliente,
										cod_transportador	= p_par_nf_912.cod_transportador,
										ies_finalidade		= p_par_nf_912.ies_finalidade,
										cod_texto					= p_par_nf_912.cod_texto,
										cod_local					= p_par_nf_912.cod_local,
										cod_local1				= p_par_nf_912.cod_local1
									
                WHERE CURRENT OF cm_padrao
          	
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("MODIFICACAO","par_nf_912")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_par_nf_912.* = p_par_nf_91201.*
         ERROR "Modificacao Cancelada"
         CALL pol0988_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0988_exclusao()
#--------------------------#

   IF pol0988_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM par_nf_912
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_par_nf_912 TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
          
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("EXCLUSAO","par_nf_912")
            
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
         
      END IF
      CLOSE cm_padrao
   END IF
 
END FUNCTION  


#-----------------------------------#
 FUNCTION pol0988_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_par_nf_91201.* = p_par_nf_912.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_par_nf_912.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_par_nf_912.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Dire��o"
            LET p_par_nf_912.* = p_par_nf_91201.* 
            EXIT WHILE
         END IF

         SELECT par_nf_912.* INTO p_par_nf_912.*
         FROM par_nf_912
            WHERE cod_empresa    = p_cod_empresa
              AND cod_param =p_par_nf_912.cod_param
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0988_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0988_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
      FROM empresa
         WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_oper CURSOR FOR
      SELECT * FROM par_nf_912
       WHERE cod_empresa = p_cod_empresa
       ORDER BY cod_param
   
   FOREACH cq_oper INTO p_par_nf_912.*
      
       OUTPUT TO REPORT pol0988_relat(p_par_nf_912.cod_param) 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#------------------------------#
 REPORT pol0988_relat(p_relat)
#------------------------------#

   DEFINE p_relat    LIKE par_nf_912.cod_param
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 072, "PAG.: ", PAGENO USING "##&"
         PRINT COLUMN 001, "pol0988",
               COLUMN 030, "PARAMETROS PARA CARGA NF SAIDA",
               COLUMN 065, "DATA: ", DATE USING "dd/mm/yyyy"
                
         PRINT COLUMN 001, "*--------------------------------------------------",
                           "---------------------------------------------------*"
         PRINT
         PRINT COLUMN 001, "  CODIGO           DESCRI�AO         S.  OP.  PGTO C.  Cliente         TRANSPORTADOR  F.	TEX	 "                     
         PRINT COLUMN 001, "--------------- -------------------- -- ------ --- -- --------------- --------------- -- ---  "
      	 
      ON EVERY ROW
					
         PRINT COLUMN 001, p_relat,
      	 			 COLUMN 017,p_par_nf_912.den_param CLIPPED,
							 COLUMN 038,p_par_nf_912.ser_nff CLIPPED,
							 COLUMN 041,p_par_nf_912.cod_nat_oper  USING "####&",
							 COLUMN 048,p_par_nf_912.cod_cnd_pgto USING "##&",
							 COLUMN 052,p_par_nf_912.cod_tip_carteira CLIPPED,
							 COLUMN 055,p_par_nf_912.cod_cliente CLIPPED,
							 COLUMN 071,p_par_nf_912.cod_transportador CLIPPED,
							 COLUMN 090,p_par_nf_912.ies_finalidade CLIPPED,
							 COLUMN 093,p_par_nf_912.cod_texto USING "##&"

   
END REPORT

