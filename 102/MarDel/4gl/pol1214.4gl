#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1214                                                 #
# OBJETIVO: DE PRA ESPÉCIE DE NOTAS                                 #
# AUTOR...: ACEEX - BL                                              #
# DATA....: 19/07/2013                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
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
          p_erro               CHAR(10)

END GLOBALS

DEFINE p_tela                  RECORD
       tipo_logix              CHAR(03),
       tipo_fiat               CHAR(02),
       entrada_saida           CHAR(01)
END RECORD

DEFINE p_id_registro           INTEGER,
       p_id_registroa          INTEGER,
       p_excluiu               SMALLINT

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1214-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol1214_menu()
   END IF
   
END MAIN

#-----------------------#
 FUNCTION pol1214_menu()#
#-----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1214") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1214 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1214_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1214_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1214_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1214_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1214_modificacao() RETURNING p_status  
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
            CALL pol1214_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1214_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1214   

END FUNCTION

#------------------------#
 FUNCTION pol1214_sobre()#
#------------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1214_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION


#--------------------------#
 FUNCTION pol1214_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1214_edita_dados("I") THEN
      
      CALL log085_transacao("BEGIN")
      
      INSERT INTO tipo_nf_5054 (
        tipo_logix,   
        tipo_fiat,    
        entrada_saida)
       VALUES (
         p_tela.tipo_logix, 
         p_tela.tipo_fiat, 
         p_tela.entrada_saida)
      
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","tipo_nf_5054")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1214_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
      
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      BEFORE FIELD tipo_logix
         IF p_funcao = 'M' THEN
            NEXT FIELD entrada_saida
         END IF
      
      AFTER FIELD tipo_logix
      
         IF p_tela.tipo_logix IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD tipo_logix   
         END IF
          
                            
      AFTER FIELD tipo_fiat
      
         IF p_tela.tipo_fiat IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD tipo_fiat   
         END IF
                                    
      AFTER FIELD entrada_saida

         IF p_tela.entrada_saida IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD entrada_saida   
         END IF

         IF p_tela.entrada_saida MATCHES '[ES]' THEN 
         ELSE
            ERROR "Informe E ou S, para esse campo "
            NEXT FIELD entrada_saida   
         END IF

         IF p_funcao = 'I' THEN   
            SELECT id_registro
              FROM tipo_nf_5054
             WHERE tipo_logix = p_tela.tipo_logix
               AND tipo_fiat = p_tela.tipo_fiat
               AND entrada_saida = p_tela.entrada_saida
         ELSE
            SELECT id_registro
              FROM tipo_nf_5054
             WHERE tipo_logix = p_tela.tipo_logix
               AND tipo_fiat = p_tela.tipo_fiat
               AND entrada_saida = p_tela.entrada_saida
               AND id_registro <> p_id_registro
         END IF

         IF STATUS = 0 THEN
            ERROR "Depara já cadastrado"
            NEXT FIELD tipo_fiat
         ELSE 
            IF STATUS <> 100 THEN   
               CALL log003_err_sql('lendo','tipo_nf_5054')
               RETURN FALSE
            END IF 
         END IF    
                    
   END INPUT 

   IF INT_FLAG THEN
      CALL pol1214_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION pol1214_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1214_limpa_tela()
   LET p_id_registroa = p_id_registro
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      tipo_nf_5054.tipo_logix,
      tipo_nf_5054.tipo_fiat,
      tipo_nf_5054.entrada_saida
               
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1214_limpa_tela()
         ELSE
            LET p_id_registro = p_id_registroa
            CALL pol1214_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT id_registro, entrada_saida ",
                  "  FROM tipo_nf_5054 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY entrada_saida"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_id_registro

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1214_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1214_exibe_dados()
#------------------------------#
   
   SELECT tipo_logix,
          tipo_fiat,
          entrada_saida
     INTO p_tela.tipo_logix,
          p_tela.tipo_fiat,
          p_tela.entrada_saida
     FROM tipo_nf_5054
    WHERE id_registro = p_id_registro
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "tipo_nf_5054")
      RETURN FALSE
   END IF

   
   DISPLAY BY NAME p_tela.*
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1214_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_id_registroa = p_id_registro
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao 
           INTO p_id_registro
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao 
           INTO p_id_registro
      
      END CASE

      IF STATUS = 0 THEN
         SELECT id_registro
           FROM tipo_nf_5054
          WHERE id_registro = p_id_registro
            
         IF STATUS = 0 THEN
            CALL pol1214_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_id_registro = p_id_registroa
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1214_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT id_registro 
      FROM tipo_nf_5054  
     WHERE id_registro = p_id_registro
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","tipo_nf_5054")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1214_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   
   IF pol1214_prende_registro() THEN
      IF pol1214_edita_dados("M") THEN
         
         UPDATE tipo_nf_5054
            SET entrada_saida = p_tela.entrada_saida
          WHERE id_registro = p_id_registro
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Modificando", "tipo_nf_5054")
         ELSE
            LET p_retorno = TRUE
         END IF
      
      ELSE
         CALL pol1214_exibe_dados() RETURNING p_status
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

#--------------------------#
 FUNCTION pol1214_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1214_prende_registro() THEN
      DELETE FROM tipo_nf_5054
			 WHERE id_registro = p_id_registro

      IF STATUS = 0 THEN               
         INITIALIZE p_id_registro TO NULL
         CALL pol1214_limpa_tela()
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","tipo_nf_5054")
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
