#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1265                                                 #
# OBJETIVO: TIPO DE DESPESA P/ CONTROLE DE FRETE                    #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 0209/08/2014                                            #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro               CHAR(06),
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT
         
END GLOBALS


DEFINE p_tip_despesa   RECORD LIKE tip_despesa_455.*,
       p_tip_despesaa  RECORD LIKE tip_despesa_455.*

DEFINE p_nom_tip_despesa      LIKE tipo_despesa.nom_tip_despesa

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1265-10.02.01  "
   CALL func002_versao_prg(p_versao)
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'; LET p_user = 'admlog'; LET p_status = 0

   IF p_status = 0 THEN
      CALL pol1265_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1265_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1265") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1265 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1265_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1265_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1265_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1265_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1265_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1265

END FUNCTION

#---------------------------#
FUNCTION pol1265_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1265_inclusao()
#--------------------------#

   CALL pol1265_limpa_tela()
   
   INITIALIZE p_tip_despesa TO NULL
   LET p_tip_despesa.cod_empresa = p_cod_empresa

   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE
   
   IF pol1265_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1265_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1265_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1265_insere()
#------------------------#

   INSERT INTO tip_despesa_455 VALUES (p_tip_despesa.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","tip_despesa_455")       
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1265_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tip_despesa.*
      WITHOUT DEFAULTS
                    
      AFTER FIELD cod_tip_despesa

         IF p_tip_despesa.cod_tip_despesa IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_tip_despesa   
         END IF
         
         SELECT cod_tip_despesa
           FROM tip_despesa_455
          WHERE cod_empresa = p_cod_empresa
            AND cod_tip_despesa = p_tip_despesa.cod_tip_despesa
         
         IF STATUS = 0 THEN
            ERROR 'Tipo de despesa já cadastrada no pol1265.'
            NEXT FIELD cod_tip_despesa   
         END IF
          
         CALL pol1265_le_nom_despesa(p_tip_despesa.cod_tip_despesa)
          
         IF p_nom_tip_despesa IS NULL THEN 
            ERROR 'Tipo de despesa inexistente no Logix.'
            NEXT FIELD cod_tip_despesa
         END IF  
         
         DISPLAY p_nom_tip_despesa TO nom_tip_despesa

      ON KEY (control-z)
         CALL pol1265_popup()

   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol1265_le_nom_despesa(p_cod)#
#--------------------------------------#
   
   DEFINE p_cod CHAR(15)
   
   SELECT nom_tip_despesa
     INTO p_nom_tip_despesa
     FROM tipo_despesa
    WHERE cod_empresa = p_cod_empresa
      AND cod_tip_despesa = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_nom_tip_despesa = NULL
   END IF  

END FUNCTION

#-----------------------#
 FUNCTION pol1265_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_tip_despesa)
         CALL log009_popup(8,10,"TIPO DE DESPESA","tipo_despesa",
              "cod_tip_despesa","nom_tip_despesa","","S"," 1=1 order by nom_tip_despesa") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_tip_despesa.cod_tip_despesa = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_tip_despesa
         END IF

   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1265_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1265_limpa_tela()
   LET p_tip_despesaa.* = p_tip_despesa.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      tip_despesa_455.cod_tip_despesa     

      ON KEY (control-z)
         CALL pol1265_popup()

   END CONSTRUCT
         
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1265_limpa_tela()
         ELSE
            LET p_tip_despesa.* = p_tip_despesaa.*
            CALL pol1265_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM tip_despesa_455 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_tip_despesa"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_tip_despesa.*

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1265_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1265_exibe_dados()
#------------------------------#

   DEFINE p_cod_desp LIKE tip_despesa_455.cod_tip_despesa
   
   LET p_cod_desp = p_tip_despesa.cod_tip_despesa
   
   SELECT * 
     INTO p_tip_despesa.*
     FROM tip_despesa_455
    WHERE cod_tip_despesa = p_cod_desp
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','tip_despesa_455')
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_tip_despesa.*
   
   CALL pol1265_le_nom_despesa(p_cod_desp)
   DISPLAY p_nom_tip_despesa TO nom_tip_despesa
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1265_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01)

   LET p_tip_despesaa.* = p_tip_despesa.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_tip_despesa.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_tip_despesa.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_tip_despesa
           FROM tip_despesa_455
          WHERE cod_empresa = p_cod_empresa
            AND cod_tip_despesa = p_tip_despesa.cod_tip_despesa
            
         IF STATUS = 0 THEN
            IF pol1265_exibe_dados() THEN
               LET p_excluiu = FALSE
               EXIT WHILE
            END IF
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_tip_despesa.* = p_tip_despesaa.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1265_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_tip_despesa 
      FROM tip_despesa_455  
     WHERE cod_empresa = p_cod_empresa
       AND cod_tip_despesa = p_tip_despesa.cod_tip_despesa
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","tip_despesa_455")
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1265_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1265_prende_registro() THEN
      IF pol1265_deleta() THEN
         INITIALIZE p_tip_despesa TO NULL
         CALL pol1265_limpa_tela()
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#------------------------#
FUNCTION pol1265_deleta()
#------------------------#

   DELETE FROM tip_despesa_455
    WHERE cod_empresa = p_cod_empresa
      AND cod_tip_despesa = p_tip_despesa.cod_tip_despesa

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","tip_despesa_455")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   


#-------------------------------- FIM DE PROGRAMA BL-----------------------------#
