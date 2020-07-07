#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL1111                                                 #
# OBJETIVO: TIPOS DE ANÁLISES                                       #
# DATA....: 03/11/2011                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa  LIKE empresa.cod_empresa,
          p_den_empresa  LIKE empresa.den_empresa,  
          p_user         LIKE usuario.nom_usuario,
          p_status       SMALLINT,
          p_houve_erro   SMALLINT,
          comando        CHAR(80),
          p_versao       CHAR(18),
          p_nom_tela     CHAR(080),
          p_nom_help     CHAR(200),
          p_ies_cons     SMALLINT,
          p_last_row     SMALLINT,
          p_msg          CHAR(100)

END GLOBALS

    DEFINE mr_it_analise  RECORD LIKE it_analise_915.*,
           mr_it_analiser RECORD LIKE it_analise_915.*

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL1111-10.02.05"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("POL1111.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")  RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '11'; LET p_user = 'admlog'; LET p_status = 0

   IF p_status = 0  THEN
      CALL POL1111_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION POL1111_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL1111") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_POL1111 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","POL1111","IN") THEN
            CALL POL1111_inclusao() RETURNING p_status
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_it_analise.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","POL1111","MO") THEN
               CALL POL1111_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificação"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela "
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_it_analise.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","POL1111","EX") THEN
               CALL POL1111_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusão"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","POL1111","CO") THEN
            CALL POL1111_consulta()
            IF p_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Próximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL POL1111_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL POL1111_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL POL1111_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_POL1111

END FUNCTION

#--------------------------#
 FUNCTION POL1111_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   CLEAR FORM
   IF POL1111_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
   #  BEGIN WORK
      LET mr_it_analise.cod_empresa = p_cod_empresa
      WHENEVER ERROR CONTINUE
      INSERT INTO it_analise_915 VALUES (mr_it_analise.*)
      WHENEVER ERROR STOP 
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","IT_ANALISE_915")       
      ELSE
         CALL log085_transacao("COMMIT")
      #  COMMIT WORK 
         MESSAGE "Inclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
      END IF
   ELSE
      CLEAR FORM
      ERROR "Inclusão Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION POL1111_entrada_dados(p_funcao)
#---------------------------------------#
   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1111
   DISPLAY p_cod_empresa TO cod_empresa
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE mr_it_analise.* TO NULL
      IF not POL1111_verifica_tip_analise() then
         RETURN false
      end if
      let mr_it_analise.ies_validade = 'N'
   END IF

   INPUT BY NAME mr_it_analise.tip_analise,
                 mr_it_analise.ies_validade,
                 mr_it_analise.den_analise_port,
                 mr_it_analise.den_analise_ing,
                 mr_it_analise.den_analise_esp,
                 mr_it_analise.ies_texto,
				 mr_it_analise.ies_obrigatoria
            WITHOUT DEFAULTS  

      AFTER FIELD ies_validade
         IF mr_it_analise.ies_validade IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD ies_validade
         END IF
         
         IF mr_it_analise.ies_validade MATCHES '[SN]' then
         else
            ERROR "Valor inválido! - informe S/N"
            NEXT FIELD ies_validade
         END IF

      AFTER FIELD den_analise_port    
         IF mr_it_analise.den_analise_port IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD den_analise_port
         END IF

      AFTER FIELD ies_texto
         IF mr_it_analise.ies_texto IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD ies_texto
         END IF
         
         IF mr_it_analise.ies_texto MATCHES '[SN]' then
         else
            ERROR "Valor inválido! - informe S/N"
            NEXT FIELD ies_texto
         END IF
		 
	  AFTER FIELD ies_obrigatoria
         IF mr_it_analise.ies_obrigatoria IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD ies_obrigatoria
         END IF
         
         IF mr_it_analise.ies_obrigatoria MATCHES '[SN]' then
			IF (mr_it_analise.ies_obrigatoria = 'S') AND
			   (mr_it_analise.ies_validade    = 'S') THEN 
				ERROR "Se o tipo de analise é do TIPO VALIDADE não pode ser obrigatório!"
				NEXT FIELD ies_obrigatoria
			END IF 
         else
            ERROR "Valor inválido! - informe S/N"
            NEXT FIELD ies_obrigatoria
         END IF

      END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1111
   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------------------#
 FUNCTION POL1111_verifica_tip_analise()
#--------------------------------------#
    
    DEFINE p_tip_analise integer
    
    SELECT max(tip_analise)
      into p_tip_analise
      FROM it_analise_915
     WHERE cod_empresa = p_cod_empresa  

    IF status <> 0 THEN
       call log003_err_sql('Lendo','it_analise_915')
       RETURN FALSE
    END IF
    
    IF p_tip_analise IS NULL THEN
       let p_tip_analise = 1
    else
       let p_tip_analise = p_tip_analise + 1
    end if
    
    LET mr_it_analise.tip_analise = p_tip_analise
    
    RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION POL1111_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON it_analise_915.tip_analise,
                                     it_analise_915.den_analise_port,
                                     it_analise_915.den_analise_ing, 
                                     it_analise_915.den_analise_esp

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1111

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET mr_it_analise.* = mr_it_analiser.*
      CALL POL1111_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM it_analise_915 ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'",
                  "   AND ", where_clause CLIPPED,                 
                  " ORDER BY tip_analise "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_it_analise.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa não Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL POL1111_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION POL1111_exibe_dados()
#-----------------------------#

   DISPLAY BY NAME mr_it_analise.*

END FUNCTION

#-----------------------------------#
 FUNCTION POL1111_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET mr_it_analiser.* = mr_it_analise.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            mr_it_analise.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            mr_it_analise.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não Existem mais Registros nesta Direção"
            LET mr_it_analise.* = mr_it_analiser.* 
            EXIT WHILE
         END IF
        
         SELECT * 
           INTO mr_it_analise.* 
           FROM it_analise_915  
          WHERE cod_empresa = mr_it_analise.cod_empresa
            AND tip_analise = mr_it_analise.tip_analise
         IF SQLCA.SQLCODE = 0 THEN 
            CALL POL1111_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Não Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION POL1111_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR FOR
   SELECT *                            
      INTO mr_it_analise.*                                              
   FROM it_analise_915
   WHERE cod_empresa = mr_it_analise.cod_empresa
     AND tip_analise = mr_it_analise.tip_analise
   FOR UPDATE 
   CALL log085_transacao("BEGIN")
#  BEGIN WORK
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usuá",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro não mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","IT_ANALISE_915")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION POL1111_modificacao()
#-----------------------------#

   IF POL1111_cursor_for_update() THEN
      LET mr_it_analiser.* = mr_it_analise.*
      IF POL1111_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE it_analise_915
            SET den_analise_port = mr_it_analise.den_analise_port,
                den_analise_ing  = mr_it_analise.den_analise_ing,
                den_analise_esp  = mr_it_analise.den_analise_esp,
                ies_validade     = mr_it_analise.ies_validade,
				ies_texto        = mr_it_analise.ies_texto,
				ies_obrigatoria  = mr_it_analise.ies_obrigatoria
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","IT_ANALISE_915")
            ELSE
               MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","IT_ANALISE_95")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
      ELSE
         LET mr_it_analise.* = mr_it_analiser.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         DISPLAY BY NAME mr_it_analise.tip_analise
         DISPLAY BY NAME mr_it_analise.den_analise_port
         DISPLAY BY NAME mr_it_analise.den_analise_ing
         DISPLAY BY NAME mr_it_analise.den_analise_esp
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION POL1111_exclusao()
#--------------------------#

   IF POL1111_cursor_for_update() THEN
      IF log004_confirm(13,42) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM it_analise_915 
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-EXC","IT_ANALISE_915")
            ELSE
               MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE mr_it_analise.* TO NULL
               CLEAR FORM
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","IT_ANALISE_915")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------#
 FUNCTION POL1111_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------- FIM DE PROGRAMA --------------------------------#