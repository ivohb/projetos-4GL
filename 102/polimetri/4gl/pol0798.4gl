#-------------------------------------------------------------------#
# PROGRAMA: pol0798                                                 #
# MODULOS.: pol0798-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: PARAMETROS P/ BAIXA DE REJEITADOS - POLIMETRI           #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 28/04/2008                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE 
          p_den_local          LIKE local.den_local,
          p_den_operacao       LIKE estoque_operac.den_operacao,
          p_den_conta          LIKE plano_contas.den_conta,
          p_user               LIKE usuario.nom_usuario,
          p_cod_local_rejei    LIKE par_rejei_454.cod_local_rejei,
          p_cod_oper_baixa     LIKE par_rejei_454.cod_oper_baixa,
          p_num_conta          LIKE par_rejei_454.num_conta,
          p_retorno            SMALLINT,
          p_cod_empresa        LIKE empresa.cod_empresa,
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
          p_cod_formulario     CHAR(03),
          p_ies_tipo           CHAR(01),
          p_msg                CHAR(500)

          
   DEFINE p_par_rejei_454   RECORD LIKE par_rejei_454.*,
          p_par_rejei_454a  RECORD LIKE par_rejei_454.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0798-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0798.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0798_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0798_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0798") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0798 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0798_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
       COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0798_modificacao() THEN
               MESSAGE 'Modificação efetuada com sucesso !!!'
               
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF 
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0798_exclusao() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0798_consulta()
         IF p_ies_cons THEN
          END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0798_sobre()
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0798

END FUNCTION

#--------------------------#
 FUNCTION pol0798_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_par_rejei_454.* TO NULL
   LET p_par_rejei_454.cod_empresa = p_cod_empresa

   IF pol0798_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO par_rejei_454 VALUES (p_par_rejei_454.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF 
   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0798_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
   
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0798

   INPUT BY NAME p_par_rejei_454.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_local_rejei
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD cod_oper_baixa
      END IF   
      
      AFTER FIELD cod_local_rejei
      IF p_par_rejei_454.cod_local_rejei IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_local_rejei
      ELSE
          SELECT den_local
          INTO p_den_local
          FROM local
          WHERE cod_empresa = p_cod_empresa 
          AND cod_local = p_par_rejei_454.cod_local_rejei
   
                            
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Grupo nao Cadastrado na Tabela local !!!" 
            NEXT FIELD cod_local_rejei
        END IF  
                
           SELECT cod_empresa
           FROM   par_rejei_454
           WHERE  cod_empresa = p_cod_empresa
            
          IF STATUS = 0 THEN  
           ERROR "Empresa Ja Contem Um Cadastro!!!"
            NEXT FIELD cod_local_rejei 
          END IF        
     
     IF p_funcao <> "MODIFICACAO" THEN                 
         SELECT cod_local_rejei
           FROM par_rejei_454
          WHERE cod_empresa = p_cod_empresa 
            AND cod_local_rejei = p_par_rejei_454.cod_local_rejei   
        
         IF STATUS = 0 THEN
            ERROR "Código do Arranjo já Cadastrado na Tabela par_rejei_454 !!!"
            NEXT FIELD cod_local_rejei
         END IF
     END IF 
                              
         DISPLAY p_par_rejei_454.cod_local_rejei TO cod_local_rejei
         DISPLAY p_den_local TO den_local
         
      NEXT FIELD cod_oper_baixa
        END IF
   

      AFTER FIELD cod_oper_baixa
      IF p_par_rejei_454.cod_oper_baixa IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_oper_baixa
      ELSE
          SELECT den_operacao
          INTO p_den_operacao
          FROM estoque_operac
          WHERE cod_empresa = p_cod_empresa 
          AND cod_operacao = p_par_rejei_454.cod_oper_baixa
          
                            
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Grupo nao Cadastrado na Tabela estoque_operac !!!" 
            NEXT FIELD cod_oper_baixa
        END IF  
                      
          SELECT ies_tipo
          INTO p_ies_tipo
          FROM estoque_operac
          WHERE cod_empresa = p_cod_empresa 
          AND cod_operacao = p_par_rejei_454.cod_oper_baixa
          
          IF p_ies_tipo <> 'S' THEN
          ERROR 'Tipo não é de saida'
          NEXT FIELD cod_oper_baixa
          END IF             
       
       IF p_funcao <> "MODIFICACAO" THEN
                      
         SELECT cod_oper_baixa
           FROM par_rejei_454
          WHERE cod_empresa = p_cod_empresa 
            AND cod_oper_baixa = p_par_rejei_454.cod_oper_baixa  
        
         IF STATUS = 0 THEN
            ERROR "Código do Arranjo já Cadastrado na Tabela par_rejei_454 !!!"
            NEXT FIELD cod_oper_baixa
         END IF
    END IF 
                                      
         DISPLAY p_par_rejei_454.cod_oper_baixa TO cod_oper_baixa
         DISPLAY p_den_operacao TO den_operacao
         
      NEXT FIELD num_conta
        END IF
          

      AFTER FIELD num_conta
      IF p_par_rejei_454.num_conta IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD num_conta
      ELSE
          SELECT den_conta
          INTO p_den_conta
          FROM plano_contas
          WHERE cod_empresa = p_cod_empresa 
          AND num_conta = p_par_rejei_454.num_conta
   
                            
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Grupo nao Cadastrado na Tabela plano_contas !!!" 
            NEXT FIELD num_conta
        END IF  
      
      IF p_funcao <> "MODIFICACAO" THEN
                      
         SELECT num_conta
           FROM par_rejei_454
          WHERE cod_empresa = p_cod_empresa 
            AND num_conta = p_par_rejei_454.num_conta  
        
         IF STATUS = 0 THEN
            ERROR "Código do Arranjo já Cadastrado na Tabela par_rejei_454 !!!"
            NEXT FIELD num_conta
         END IF
    END IF 
                                      
         DISPLAY p_par_rejei_454.num_conta TO num_conta
         DISPLAY p_den_conta TO den_conta
      
        END IF
        
               
    ON KEY (control-z)
      CALL pol0798_popup()
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0798

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF  

END FUNCTION

#--------------------------#
 FUNCTION pol0798_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_par_rejei_454a.* = p_par_rejei_454.*

   CONSTRUCT BY NAME where_clause ON par_rejei_454.cod_local_rejei,
                                     par_rejei_454.cod_oper_baixa,
                                     par_rejei_454.num_conta 
  
      ON KEY (control-z)
        CALL pol0798_popup()

        
   END CONSTRUCT      
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0798

         IF SQLCA.sqlcode <> 0 THEN
            CLEAR FORM
         END IF

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_par_rejei_454.* = p_par_rejei_454a.*
      CALL pol0798_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM par_rejei_454 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_local_rejei"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_par_rejei_454.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      CLEAR FORM 
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0798_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0798_exibe_dados()
#------------------------------#
   SELECT den_local
   INTO p_den_local
   FROM local
   WHERE cod_empresa = p_cod_empresa 
   AND cod_local = p_par_rejei_454.cod_local_rejei

   SELECT den_operacao
   INTO p_den_operacao
   FROM estoque_operac
   WHERE cod_empresa = p_cod_empresa 
   AND cod_operacao = p_par_rejei_454.cod_oper_baixa
 
   SELECT den_conta
   INTO p_den_conta
   FROM plano_contas
   WHERE cod_empresa = p_cod_empresa 
   AND num_conta = p_par_rejei_454.num_conta

   DISPLAY BY NAME p_par_rejei_454.*
   DISPLAY p_den_local TO den_local
   DISPLAY p_den_operacao TO den_operacao
   DISPLAY p_den_conta TO den_conta
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0798_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_par_rejei_454.*                                              
     FROM par_rejei_454
     WHERE cod_empresa = p_cod_empresa 

   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","par_rejei_454")   
      RETURN FALSE
   END IF

END FUNCTION


#-----------------------------#
 FUNCTION pol0798_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0798_cursor_for_update() THEN
      LET p_par_rejei_454a.* = p_par_rejei_454.*
      IF pol0798_entrada_dados("MODIFICACAO") THEN
         UPDATE par_rejei_454
            SET cod_oper_baixa =  p_par_rejei_454.cod_oper_baixa,
                num_conta = p_par_rejei_454.num_conta
              WHERE cod_empresa = p_cod_empresa

         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","par_rejei_454")
         END IF
      ELSE
         LET p_par_rejei_454.* = p_par_rejei_454a.*
         CALL pol0798_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION 


#--------------------------#
 FUNCTION pol0798_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0798_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
      
         DELETE FROM par_rejei_454
         WHERE cod_empresa = p_cod_empresa
         
         IF STATUS = 0 THEN
            INITIALIZE p_par_rejei_454.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","par_rejei_454")
         END IF
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#-----------------------#
FUNCTION pol0798_popup()
#-----------------------#
   DEFINE p_codigo  CHAR(05),
          p_codigo2 CHAR(23)

   CASE
      WHEN INFIELD(cod_local_rejei)
         CALL log009_popup(8,10,"LOCAL","local",
              "cod_local","den_local","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0798
          
         IF p_codigo IS NOT NULL THEN
           LET p_par_rejei_454.cod_local_rejei = p_codigo CLIPPED
           DISPLAY p_codigo TO cod_local_rejei
         END IF          
   END CASE
   
   CASE
      WHEN INFIELD(cod_oper_baixa)
         CALL log009_popup(8,10,"OPERACAO","estoque_operac",
              "cod_operacao","den_operacao","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0798
          
         IF p_codigo IS NOT NULL THEN
           LET p_par_rejei_454.cod_oper_baixa = p_codigo CLIPPED
           DISPLAY p_codigo TO cod_oper_baixa
         END IF          
   END CASE
   
   CASE
      WHEN INFIELD(num_conta)
         CALL log009_popup(8,10,"CONTA","plano_contas",
              "num_conta","den_conta","","S","") 
              RETURNING p_codigo2
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0798
          
         IF p_codigo2 IS NOT NULL THEN
           LET p_par_rejei_454.num_conta = p_codigo2 CLIPPED
           DISPLAY p_codigo2 TO num_conta
         END IF          
   END CASE   
   
   
   
END FUNCTION 

#-----------------------#
 FUNCTION pol0798_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION



#-------------------------------- FIM DE PROGRAMA -----------------------------#

