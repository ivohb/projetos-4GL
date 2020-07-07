#-------------------------------------------------------------------#
# SISTEMA.: RECURSOS HUMANOS                                        #
# PROGRAMA: pol0657                                                 #
# OBJETIVO: MANUTENCAO DA TABELA cc_n_trans                   #
# DATA....: 01/08/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix
GLOBALS
   DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
          p_user              LIKE usuario.nom_usuario,
          p_status            SMALLINT,
          p_houve_erro        SMALLINT,
          comando             CHAR(80),
          p_versao            CHAR(18),
          p_nom_arquivo       CHAR(100),
          p_nom_tela          CHAR(080),
          p_nom_help          CHAR(200),
          p_ies_cons          SMALLINT,
          p_msg               CHAR(100)

   DEFINE p_cc_n_trans  RECORD LIKE cc_n_trans.*,
          p_cc_n_transr RECORD LIKE cc_n_trans.*

   DEFINE p_tela RECORD 
      den_empresa_orig        LIKE empresa.den_empresa,
      den_empresa_dest        LIKE empresa.den_empresa,
      den_cent_cust           LIKE centro_custo.den_cent_cust
   END RECORD
END GLOBALS
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "POL0657-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0657.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0657_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0657_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0657") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0657 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0657","IN") THEN
            CALL pol0657_inclusao() RETURNING p_status
         END IF
      COMMAND "Excluir" "Exclui dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0657","EX") THEN
               CALL pol0657_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0657","CO") THEN
            CALL pol0657_consulta()
            IF p_ies_cons = TRUE THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0657_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0657_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0657_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 007
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0657

END FUNCTION

#--------------------------#
 FUNCTION pol0657_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   IF pol0657_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN") 
      INSERT INTO cc_n_trans VALUES (p_cc_n_trans.*)
      IF SQLCA.SQLCODE <> 0 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","cc_n_trans")       
      ELSE
         CALL log085_transacao("COMMIT") 
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
   ELSE
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0657_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao        CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0657
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_cc_n_trans.* TO NULL
      DISPLAY BY NAME p_cc_n_trans.cod_empresa_orig,
                      p_cc_n_trans.cod_empresa_dest,
                      p_cc_n_trans.cod_cent_cust

      CLEAR FORM
   END IF
   DISPLAY p_cod_empresa TO cod_empresa

   INPUT BY NAME p_cc_n_trans.cod_empresa_orig,
                 p_cc_n_trans.cod_empresa_dest,
                 p_cc_n_trans.cod_cent_cust
      WITHOUT DEFAULTS  

      AFTER FIELD cod_empresa_orig
      IF p_cc_n_trans.cod_empresa_orig IS NOT NULL THEN
         SELECT den_empresa
            INTO p_tela.den_empresa_orig 
         FROM empresa           
         WHERE cod_empresa = p_cc_n_trans.cod_empresa_orig
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Empresa nao Cadastrada" 
            NEXT FIELD cod_empresa_orig
         ELSE 
            DISPLAY BY NAME p_tela.den_empresa_orig
         END IF
      ELSE
         ERROR "O Campo Empresa Origem nao pode ser Nulo"
         NEXT FIELD cod_empresa_orig
      END IF

      AFTER FIELD cod_empresa_dest
      IF p_cc_n_trans.cod_empresa_dest IS NOT NULL THEN
         SELECT den_empresa
            INTO p_tela.den_empresa_dest 
         FROM empresa           
         WHERE cod_empresa = p_cc_n_trans.cod_empresa_dest
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Empresa nao Cadastrada" 
            NEXT FIELD cod_empresa_dest
         ELSE 
            DISPLAY BY NAME p_tela.den_empresa_dest
         END IF
      ELSE
         ERROR "O Campo Empresa Destino nao pode ser Nulo"
         NEXT FIELD cod_empresa_dest
      END IF

      AFTER FIELD cod_cent_cust
      IF p_cc_n_trans.cod_cent_cust IS NOT NULL THEN

         SELECT nom_cent_cust
           INTO p_tela.den_cent_cust
           FROM cad_cc            
          WHERE cod_empresa = p_cod_empresa
            AND cod_cent_cust = p_cc_n_trans.cod_cent_cust
             
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cad_cc')
         END IF
         
         IF p_tela.den_cent_cust IS NULL THEN
            ERROR "Centro de custo nao Cadastrado" 
            NEXT FIELD cod_cent_cust
         END IF
         IF pol0657_verifica_duplicidade() THEN
            ERROR "Evento Já Cadastrado" 
            NEXT FIELD cod_empresa_orig
         END IF
         DISPLAY BY NAME p_tela.den_cent_cust
      ELSE
         ERROR "O Campo Evento nao pode ser Nulo"
         NEXT FIELD cod_cent_cust
      END IF

       ON KEY (control-z)
         CALL pol0657_popup()

   END INPUT 
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0657
   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0657_consulta()
#--------------------------#

   DEFINE sql_stmt, where_clause CHAR(300)  
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON cc_n_trans.cod_empresa_orig,
                                     cc_n_trans.cod_empresa_dest,
                                     cc_n_trans.cod_cent_cust

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0657
   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_cc_n_trans.* = p_cc_n_transr.*
      CALL pol0657_exibe_dados()
      ERROR " Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM cc_n_trans ",
                  " WHERE ", where_clause CLIPPED,                 
                  " ORDER BY cod_empresa_orig "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_cc_n_trans.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0657_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0657_exibe_dados()
#-----------------------------#

   SELECT den_empresa
      INTO p_tela.den_empresa_orig 
   FROM empresa           
   WHERE cod_empresa = p_cc_n_trans.cod_empresa_orig

   SELECT den_empresa
      INTO p_tela.den_empresa_dest
   FROM empresa           
   WHERE cod_empresa = p_cc_n_trans.cod_empresa_dest

   SELECT non_cent_cust
      INTO p_tela.den_cent_cust
   FROM cad_cc            
   WHERE cod_empresa = p_cod_empresa
     AND cod_cent_cust = p_cc_n_trans.cod_cent_cust


   DISPLAY BY NAME p_cc_n_trans.cod_empresa_orig,
                   p_cc_n_trans.cod_empresa_dest,
                   p_cc_n_trans.cod_cent_cust,
                   p_tela.*

END FUNCTION

#-----------------------------------#
 FUNCTION pol0657_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_cc_n_transr.* = p_cc_n_trans.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_cc_n_trans.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_cc_n_trans.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem mais Itens nesta Direcao"
            LET p_cc_n_trans.* = p_cc_n_transr.* 
            EXIT WHILE
         END IF
         
         SELECT * INTO p_cc_n_trans.* FROM cc_n_trans    
         WHERE cod_empresa_orig = p_cc_n_trans.cod_empresa_orig
           AND cod_empresa_dest = p_cc_n_trans.cod_empresa_dest
           AND cod_cent_cust = p_cc_n_trans.cod_cent_cust
  
         IF SQLCA.SQLCODE = 0 THEN 
            CALL pol0657_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION pol0657_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *                            
     INTO p_cc_n_trans.*                                              
     FROM cc_n_trans      
    WHERE cod_empresa_orig = p_cc_n_trans.cod_empresa_orig
      AND cod_empresa_dest = p_cc_n_trans.cod_empresa_dest
      AND cod_cent_cust    = p_cc_n_trans.cod_cent_cust

   CALL log085_transacao("BEGIN") 
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","cc_n_trans")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#--------------------------#
 FUNCTION pol0657_exclusao()
#--------------------------#

   IF pol0657_cursor_for_update() THEN
      IF log004_confirm(18,34) THEN

         WHENEVER ERROR CONTINUE
         DELETE FROM cc_n_trans    
          WHERE cod_empresa_orig = p_cc_n_trans.cod_empresa_orig
            AND cod_empresa_dest = p_cc_n_trans.cod_empresa_dest
            AND cod_cent_cust    = p_cc_n_trans.cod_cent_cust

         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT") 
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-EXC","cc_n_trans")
            ELSE
               MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE p_cc_n_trans.* TO NULL
               CLEAR FORM
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","cc_n_trans")
            CALL log085_transacao("ROLLBACK") 
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK") 
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#--------------------------------------#
 FUNCTION pol0657_verifica_duplicidade()
#--------------------------------------#

   SELECT * 
   FROM cc_n_trans
   WHERE cod_empresa_orig = p_cc_n_trans.cod_empresa_orig
     AND cod_empresa_dest = p_cc_n_trans.cod_empresa_dest
     AND cod_cent_cust = p_cc_n_trans.cod_cent_cust
   IF SQLCA.SQLCODE = 0 THEN 
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION   

#-----------------------#
 FUNCTION pol0657_popup()
#-----------------------#

   CASE
      WHEN INFIELD(cod_empresa_orig)
         CALL log009_popup(6,25,"EMPRESA","empresa",
                          "cod_empresa","den_empresa",
                          "","N","") 
            RETURNING p_cc_n_trans.cod_empresa_orig
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0657 
         IF p_cc_n_trans.cod_empresa_orig IS NOT NULL THEN
            DISPLAY BY NAME p_cc_n_trans.cod_empresa_orig
         END IF
      WHEN INFIELD(cod_empresa_dest)
         CALL log009_popup(6,25,"EMPRESA","empresa",
                          "cod_empresa","den_empresa",
                          "","N","") 
            RETURNING p_cc_n_trans.cod_empresa_dest
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0657 
         IF p_cc_n_trans.cod_empresa_dest IS NOT NULL THEN
            DISPLAY BY NAME p_cc_n_trans.cod_empresa_dest
         END IF
      WHEN INFIELD(cod_cent_cust)
         CALL log009_popup(6,25,"CENTRO CUSTO","cad_cc",
                          "cod_cent_cust","nom_cent_cust",
                          "con0480","N","") 
            RETURNING p_cc_n_trans.cod_cent_cust
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0657   
         IF p_cc_n_trans.cod_cent_cust IS NOT NULL THEN
            DISPLAY BY NAME p_cc_n_trans.cod_cent_cust
         END IF
   END CASE

END FUNCTION

#-----------------------#
 FUNCTION pol0657_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------ FIM DE PROGRAMA -------------------------------#
