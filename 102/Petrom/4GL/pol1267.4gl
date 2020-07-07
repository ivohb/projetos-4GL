#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1267                                                 #
# OBJETIVO: ROTA P/ CONTROLE DE FRETE                               #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 16/08/2014                                              #
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


DEFINE p_rota_frete   RECORD LIKE rota_frete_455.*,
       p_rota_fretea  RECORD LIKE rota_frete_455.*

DEFINE p_den_cidade   LIKE cidades.den_cidade

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1267-10.02.01  "
   CALL func002_versao_prg(p_versao)
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21';  LET p_user = 'admlog';    LET p_status = 0

   IF p_status = 0 THEN
      CALL pol1267_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1267_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1267") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1267 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1267_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1267_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1267_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1267_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1267_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1267_exclusao() RETURNING p_status
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
   
   CLOSE WINDOW w_pol1267

END FUNCTION

#---------------------------#
FUNCTION pol1267_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1267_inclusao()
#--------------------------#

   CALL pol1267_limpa_tela()
   
   INITIALIZE p_rota_frete TO NULL

   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE
   
   IF pol1267_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1267_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1267_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1267_insere()
#------------------------#

   SELECT MAX(cod_rota)
     INTO p_rota_frete.cod_rota
     FROM rota_frete_455

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','rota_frete_455')
      RETURN FALSE
   END IF
   
   IF p_rota_frete.cod_rota IS NULL THEN
      LET p_rota_frete.cod_rota = 1
   ELSE
      LET p_rota_frete.cod_rota = p_rota_frete.cod_rota + 1
   END IF        
     
   INSERT INTO rota_frete_455 VALUES (p_rota_frete.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","rota_frete_455")       
      RETURN FALSE
   END IF
   
   DISPLAY p_rota_frete.cod_rota TO cod_rota
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1267_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_rota_frete.*
      WITHOUT DEFAULTS
                    
      AFTER FIELD cod_cidade

         IF p_rota_frete.cod_cidade IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_cidade   
         END IF
         
         CALL pol1267_le_cidade(p_rota_frete.cod_cidade)                  

         IF p_den_cidade IS NULL THEN
            ERROR 'Cidade inexistetne no logix.'
            NEXT FIELD cod_cidade   
         END IF
                   
         DISPLAY p_den_cidade TO den_cidade
                  
      ON KEY (control-z)
         CALL pol1267_popup()

   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1267_le_cidade(p_cod)#
#--------------------------------#
   
   DEFINE p_cod CHAR(15)
   
   SELECT den_cidade
     INTO p_den_cidade
     FROM cidades
    WHERE cod_cidade = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_den_cidade = NULL
   END IF  

END FUNCTION

#-----------------------#
 FUNCTION pol1267_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_cidade)
         LET p_codigo = pol1247_sel_cidade()
         CLOSE WINDOW w_pol1247a
         CURRENT WINDOW IS w_pol1267
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_rota_frete.cod_cidade = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_cidade
         END IF

   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1267_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1267_limpa_tela()
   LET p_rota_fretea.* = p_rota_frete.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      rota_frete_455.des_rota,
      rota_frete_455.cod_cidade

      ON KEY (control-z)
         CALL pol1267_popup()

   END CONSTRUCT
         
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1267_limpa_tela()
         ELSE
            LET p_rota_frete.* = p_rota_fretea.*
            CALL pol1267_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM rota_frete_455 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY des_rota"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_rota_frete.*

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1267_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1267_exibe_dados()
#------------------------------#

   DEFINE p_rota LIKE rota_frete_455.cod_rota
   
   LET p_rota = p_rota_frete.cod_rota
   
   SELECT * 
     INTO p_rota_frete.*
     FROM rota_frete_455
    WHERE cod_rota = p_rota
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','rota_frete_455')
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_rota_frete.*
   
   CALL pol1267_le_cidade(p_rota_frete.cod_cidade)
   DISPLAY p_den_cidade TO den_cidade
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1267_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01)

   LET p_rota_fretea.* = p_rota_frete.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_rota_frete.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_rota_frete.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_rota
           FROM rota_frete_455
          WHERE cod_rota = p_rota_frete.cod_rota
            
         IF STATUS = 0 THEN
            IF pol1267_exibe_dados() THEN
               LET p_excluiu = FALSE
               EXIT WHILE
            END IF
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_rota_frete.* = p_rota_fretea.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1267_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_rota 
      FROM rota_frete_455  
     WHERE cod_rota = p_rota_frete.cod_rota
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","rota_frete_455")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1267_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   LET p_rota_fretea.* = p_rota_frete.*
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF

   LET p_opcao   = "M"
   
   IF pol1267_prende_registro() THEN
      IF pol1267_edita_dados("M") THEN
         IF pol1267_atualiza() THEN
            LET p_retorno = TRUE
         END IF
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
      LET p_rota_frete.* = p_rota_fretea.*
      CALL pol1267_exibe_dados() RETURNING p_status
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
FUNCTION pol1267_atualiza()
#--------------------------#

   UPDATE rota_frete_455
      SET rota_frete_455.* = p_rota_frete.*
     WHERE cod_rota = p_rota_frete.cod_rota

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE", "rota_frete_455")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1267_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1267_prende_registro() THEN
      IF pol1267_deleta() THEN
         INITIALIZE p_rota_frete TO NULL
         CALL pol1267_limpa_tela()
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
FUNCTION pol1267_deleta()
#------------------------#

   DELETE FROM rota_frete_455
    WHERE cod_rota = p_rota_frete.cod_rota

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","rota_frete_455")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   


#-------------------------------- FIM DE PROGRAMA BL-----------------------------#
