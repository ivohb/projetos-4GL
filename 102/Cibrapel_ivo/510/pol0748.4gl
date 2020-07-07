#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0748                                                 #
# MODULOS.: pol0748-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: DESCONTO DE TRANSPORTE - CIBRAPEL                       #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 22/04/2007                                              #
# CONVERSÃO 10.02: 17/07/2014 - IVO                                 #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_desc_transpor      LIKE desc_transp_885.cod_transpor,
          p_pct_desc           LIKE desc_transp_885.pct_desc,
          p_den_transpor       CHAR(50),
          p_user               LIKE usuario.nom_usuario,
          p_retorno            SMALLINT,
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
          p_msg                CHAR(100)



          
   DEFINE p_desc_transp_885  RECORD LIKE desc_transp_885.*,
          p_desc_transp_885a  RECORD LIKE desc_transp_885.* 
          

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0748-10.02.00  "
   CALL func002_versao_prg(p_versao)
   
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0748.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0748_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0748_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0748") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0748 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0748_inclusao() THEN
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
            IF pol0748_modificacao() THEN
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
            IF pol0748_exclusao() THEN
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
         CALL pol0748_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0748_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0748_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
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
   CLOSE WINDOW w_pol0748

END FUNCTION

#--------------------------#
 FUNCTION pol0748_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
  
   INITIALIZE p_desc_transp_885.* TO NULL
   LET p_desc_transp_885.cod_empresa = p_cod_empresa

   IF pol0748_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO desc_transp_885 VALUES (p_desc_transp_885.*)
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
 FUNCTION pol0748_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
  
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0748

   INPUT BY NAME p_desc_transp_885.* 
      WITHOUT DEFAULTS  

    BEFORE FIELD cod_transpor	
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD pct_desc
      END IF   
      
      AFTER FIELD cod_transpor
      IF p_desc_transp_885.cod_transpor IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_transpor
      ELSE
         SELECT nom_cliente
           INTO p_den_transpor
           FROM clientes
          WHERE cod_cliente = p_desc_transp_885.cod_transpor
           AND  cod_tip_cli IN ('99','98')
           
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo_tip_cli diferente de 98 ou 99 !!!" 
            NEXT FIELD cod_transpor
         END IF
         
         SELECT cod_transpor
         FROM desc_transp_885
         WHERE cod_transpor = p_desc_transp_885.cod_transpor
         AND   cod_empresa  = p_cod_empresa

         IF SQLCA.sqlcode = 0 THEN
            ERROR "Codigo ja Cadastrado na Tabela !!!" 
            NEXT FIELD cod_transpor
         END IF
         
         DISPLAY p_desc_transp_885.cod_transpor TO cod_transpor
         DISPLAY p_den_transpor TO den_transpor 
         NEXT FIELD pct_desc
         
           END IF
                 
            AFTER FIELD pct_desc
        IF p_desc_transp_885.pct_desc IS NULL THEN 
           ERROR "Campo com preenchimento obrigatório !!!"
           NEXT FIELD pct_desc
        END IF  
        
        
         ON KEY (control-z)
                CALL pol0748_popup()
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0748

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0748_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_desc_transp_885a.* = p_desc_transp_885.*

   CONSTRUCT BY NAME where_clause ON desc_transp_885.cod_transpor 
  
  ON KEY (control-z)
    CALL pol0748_popup()
   
      
   
 END CONSTRUCT      
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0748

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_desc_transp_885.* = p_desc_transp_885a.*
      CALL pol0748_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM desc_transp_885 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_transpor "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_desc_transp_885.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0748_exibe_dados()
   END IF

END FUNCTION


#------------------------------#
 FUNCTION pol0748_exibe_dados()
#------------------------------#

         SELECT nom_cliente
           INTO p_den_transpor
           FROM clientes
          WHERE cod_cliente = p_desc_transp_885.cod_transpor

   DISPLAY BY NAME p_desc_transp_885.*
   DISPLAY p_den_transpor TO den_transpor
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0748_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_desc_transp_885.*                                              
     FROM desc_transp_885
    WHERE cod_empresa = p_cod_empresa  
    AND   cod_transpor = p_desc_transp_885.cod_transpor
   FOR UPDATE     
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","desc_transp_885")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0748_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0748_cursor_for_update() THEN
      LET p_desc_transp_885a.* = p_desc_transp_885.*
      IF pol0748_entrada_dados("MODIFICACAO") THEN
      
         UPDATE desc_transp_885
            SET pct_desc = p_desc_transp_885.pct_desc
              WHERE cod_empresa  = p_cod_empresa
              AND  cod_transpor = p_desc_transp_885.cod_transpor
                           
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","desc_transp_885")
         END IF
      ELSE
         LET p_desc_transp_885.* = p_desc_transp_885a.*
         CALL pol0748_exibe_dados()
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
 FUNCTION pol0748_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0748_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
      
         DELETE FROM desc_transp_885
        WHERE cod_empresa = p_cod_empresa
        AND cod_transpor = p_desc_transp_885.cod_transpor
        
         IF STATUS = 0 THEN
            INITIALIZE p_desc_transp_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","desc_transp_885")
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

#-----------------------------------#
 FUNCTION pol0748_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_desc_transp_885a.* = p_desc_transp_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_desc_transp_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_desc_transp_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_desc_transp_885.* = p_desc_transp_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_desc_transp_885.*
           FROM desc_transp_885
          WHERE cod_empresa = p_cod_empresa 
          AND cod_transpor = p_desc_transp_885.cod_transpor
           
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0748_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0748_popup()
#-----------------------#
   DEFINE p_codigo  CHAR(15)
     
            
  # CASE
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_desc_transp_885.cod_transpor = p_codigo
            DISPLAY p_codigo TO cod_transpor
         END IF
         
  # END CASE
            
END FUNCTION 


#-------------------------------- FIM DE PROGRAMA -----------------------------#

