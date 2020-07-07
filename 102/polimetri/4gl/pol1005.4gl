#-------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO DO LOGIX x EGA - ITAESBRA                    #
# PROGRAMA: pol1005                                                 #
# OBJETIVO: PARÂMETROS PARA AJUSTE DO CUSTO DO ITEM                 #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 07/01/2010                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_conta          LIKE plano_contas.den_conta,
          p_den_operac         LIKE estoque_operac.den_operacao,
          p_ies_tipo           LIKE estoque_operac.ies_tipo,
          p_ies_com_quantidade LIKE estoque_operac.ies_com_quantidade,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_msg                CHAR(500)
          

   DEFINE p_par_ajust_454   RECORD LIKE par_ajust_454.*,
          p_par_ajust_454a  RECORD LIKE par_ajust_454.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol1005-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1005.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol1005_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1005_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1005") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1005 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol1005_inclusao() RETURNING p_status
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol1005_modificacao()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol1005_exclusao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol1005_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol1005_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol1005_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1005_sobre()
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
   CLOSE WINDOW w_pol1005

END FUNCTION

#--------------------------#
 FUNCTION pol1005_inclusao()
#--------------------------#

   SELECT cod_empresa
     FROM par_ajust_454
    WHERE cod_empresa = p_cod_empresa
   IF STATUS = 0 THEN
      ERROR 'Empresa ',p_cod_empresa,' Já Cadastrada !!!'
      RETURN FALSE
   END IF

   LET p_houve_erro = FALSE
   IF pol1005_entrada_dados("INCLUSAO") THEN
      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      INSERT INTO par_ajust_454 VALUES (p_par_ajust_454.*)
      IF SQLCA.SQLCODE <> 0 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","par_ajust_454")       
      ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
      WHENEVER ERROR STOP
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      INITIALIZE p_par_ajust_454.* TO NULL
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol1005_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol1005
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_par_ajust_454.* TO NULL
      LET p_par_ajust_454.cod_empresa = p_cod_empresa
      CALL pol1005_exibe_dados()
   END IF

   INPUT BY NAME p_par_ajust_454.* 
      WITHOUT DEFAULTS  
         
       AFTER FIELD cod_oper_ent
          IF p_par_ajust_454.cod_oper_ent IS NULL THEN
             ERROR 'Campo c/ Preenchimento Obrigatório !!!'
             NEXT FIELD cod_oper_ent
          END IF
          
          SELECT den_operacao,
                 ies_tipo,
                 ies_com_quantidade
            INTO p_den_operac, 
                 p_ies_tipo,
                 p_ies_com_quantidade
              FROM estoque_operac
           WHERE cod_empresa = p_cod_empresa
             AND cod_operacao = p_par_ajust_454.cod_oper_ent
          
          DISPLAY p_den_operac TO den_oper_ent
          
          IF SQLCA.sqlcode = NOTFOUND THEN
             ERROR 'Código Inexistente !!!'
             NEXT FIELD cod_operac
          END IF
             
          IF p_ies_tipo <> 'E' THEN
             ERROR 'Este código não é uma operação de entrada !!!'
             NEXT FIELD cod_oper_ent
          END IF

          IF p_ies_com_quantidade = 'S' THEN
             ERROR 'Esta operação é de entrada más inclui quantidade !!!'
             NEXT FIELD cod_oper_ent
          END IF

       AFTER FIELD cod_oper_sai
          IF p_par_ajust_454.cod_oper_sai IS NULL THEN
             ERROR 'Campo c/ Preenchimento Obrigatório !!!'
             NEXT FIELD cod_oper_sai
          END IF
          
          SELECT den_operacao,
                 ies_tipo,
                 ies_com_quantidade
            INTO p_den_operac, 
                 p_ies_tipo,
                 p_ies_com_quantidade
              FROM estoque_operac
           WHERE cod_empresa = p_cod_empresa
             AND cod_operacao = p_par_ajust_454.cod_oper_sai
          
          DISPLAY p_den_operac TO den_oper_sai
          
          IF SQLCA.sqlcode = NOTFOUND THEN
             ERROR 'Código Inexistente !!!'
             NEXT FIELD cod_oper_sai
          END IF
             
          IF p_ies_tipo <> 'S' THEN
             ERROR 'Este código não é uma operação de saida !!!'
             NEXT FIELD cod_oper_sai
          END IF

          IF p_ies_com_quantidade = 'S' THEN
             ERROR 'Esta operação é de saida más inclui quantidade !!!'
             NEXT FIELD cod_oper_sai
          END IF
                  
      ON KEY (control-z)
         CALL pol1005_popup()
          
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol1005

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1005_consulta()
#--------------------------#

   DEFINE sql_stmt CHAR(300)
   
   LET sql_stmt = "SELECT * FROM par_ajust_454 ",
                  " WHERE cod_empresa = '",p_cod_empresa,"' "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_par_ajust_454.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol1005_exibe_dados()
   END IF

END FUNCTION


#------------------------------#
 FUNCTION pol1005_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_par_ajust_454.*

   INITIALIZE p_den_operac TO NULL
   
   SELECT den_operacao
     INTO p_den_operac 
     FROM estoque_operac
    WHERE cod_empresa = p_cod_empresa
      AND cod_operacao = p_par_ajust_454.cod_oper_ent

   DISPLAY p_den_operac TO den_oper_ent

   INITIALIZE p_den_operac TO NULL
   
   SELECT den_operacao
     INTO p_den_operac 
     FROM estoque_operac
    WHERE cod_empresa = p_cod_empresa
      AND cod_operacao = p_par_ajust_454.cod_oper_sai

   DISPLAY p_den_operac TO den_oper_sai
   
END FUNCTION


#-----------------------------------#
 FUNCTION pol1005_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT * INTO p_par_ajust_454.*                                              
     FROM par_ajust_454  
    WHERE cod_empresa = p_par_ajust_454.cod_empresa
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
      OTHERWISE CALL log003_err_sql("LEITURA","par_ajust_454")
   END CASE
   CALL log085_transacao("ROLLBACK")
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol1005_modificacao()
#-----------------------------#

   IF pol1005_cursor_for_update() THEN
      LET p_par_ajust_454a.* = p_par_ajust_454.*
      IF pol1005_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE par_ajust_454 
            SET cod_oper_ent = p_par_ajust_454.cod_oper_ent,
                cod_oper_sai = p_par_ajust_454.cod_oper_sai
                WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("MODIFICACAO","par_ajust_454")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_par_ajust_454.* = p_par_ajust_454a.*
         ERROR "Modificacao Cancelada"
         CALL pol1005_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1005_exclusao()
#--------------------------#

   IF pol1005_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM par_ajust_454
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_par_ajust_454.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("EXCLUSAO","par_ajust_454")
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------------------#
 FUNCTION pol1005_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_par_ajust_454a.* = p_par_ajust_454.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_par_ajust_454.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_par_ajust_454.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_par_ajust_454.* = p_par_ajust_454a.* 
            EXIT WHILE
         END IF

         SELECT * INTO p_par_ajust_454.* 
         FROM par_ajust_454
            WHERE cod_empresa = p_par_ajust_454.cod_empresa
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol1005_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol1005_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_oper_ent)
         CALL log009_popup(8,25,"OPERAÇÃO","estoque_operac",
                     "cod_operacao","den_operacao","","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol1005
         IF p_codigo IS NOT NULL THEN
            LET p_par_ajust_454.cod_oper_ent = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_oper_ent
         END IF
      WHEN INFIELD(cod_oper_sai)
         CALL log009_popup(8,25,"OPERAÇÃO","estoque_operac",
                     "cod_operacao","den_operacao","","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol1005
         IF p_codigo IS NOT NULL THEN
            LET p_par_ajust_454.cod_oper_sai = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_oper_sai
         END IF
      END CASE

END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#

# PARA COMPILAR NO 4JS, INSIRA UMA CHAVE ({) NA LINHA A SEGUIR
{
#----------------------------------#
FUNCTION log085_transacao(p_transac)
#----------------------------------#

   DEFINE p_transac CHAR(08)

   CASE p_transac
      WHEN "BEGIN"    BEGIN WORK
      WHEN "COMMIT"   COMMIT WORK
      WHEN "ROLLBACK" ROLLBACK WORK
   END CASE
         
END FUNCTION 

#----------------------------------#
FUNCTION log0180_conecta_usuario()
#----------------------------------#

END FUNCTION
}

#-----------------------#
 FUNCTION pol1005_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
