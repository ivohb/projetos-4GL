#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1043                                                 #
# OBJETIVO: CADASTRO DE FAMÍLIAS (NOVOS PRODUTOS)                   #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 21/06/10                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_den_familia        LIKE familia.den_familia,
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
          p_msg                CHAR(100),
          p_last_row           SMALLINT
         
  
   DEFINE p_kana_novos_produtos_familias RECORD
          cod_familia                    CHAR(03),          
          idinpf                         INTEGER,
          data_inicio                    DATE,             
          data_termino                   DATE
   END RECORD 

   DEFINE p_cod_familia        LIKE kana_novos_produtos_familias.cod_familia,
          p_cod_familia_ant    LIKE kana_novos_produtos_familias.cod_familia
          
END GLOBALS

MAIN
   #CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1043-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1043_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1043_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1043") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1043 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   CALL pol1043_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         CALL pol1043_inclusao() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = FALSE
            ERROR 'Inclusão efetuada com sucesso !!!'
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
          IF pol1043_consulta() THEN
            LET p_ies_cons = TRUE
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1043_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1043_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol1043_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_cod_familia TO cod_familia
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol1043_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
	  COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
              CALL pol1043_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1043

END FUNCTION

#----------------------------#
 FUNCTION pol1043_limpa_tela()
#----------------------------#
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 
   
#--------------------------#
 FUNCTION pol1043_inclusao()
#--------------------------#
   
   IF pol1043_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO kana_novos_produtos_familias VALUES (p_kana_novos_produtos_familias.idinpf,
                                                       p_kana_novos_produtos_familias.cod_familia,
                                                       p_kana_novos_produtos_familias.data_inicio,
                                                       p_kana_novos_produtos_familias.data_termino)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","kana_novos_produtos_familias")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1043_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   
   LET INT_FLAG = FALSE 
   
   IF p_funcao = "I" THEN 
      CALL pol1043_limpa_tela()
      INITIALIZE p_kana_novos_produtos_familias.* TO NULL
      IF NOT pol1043_busca_identificador() THEN
         RETURN FALSE
      END IF 
   END IF 
   
   INPUT BY NAME p_kana_novos_produtos_familias.* WITHOUT DEFAULTS
      
      BEFORE FIELD cod_familia
      IF p_funcao = "M" THEN 
         DISPLAY p_cod_familia TO cod_familia
         NEXT FIELD data_inicio
      END IF 
      
      AFTER FIELD cod_familia
      IF p_kana_novos_produtos_familias.cod_familia IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_familia   
      END IF
          
      SELECT den_familia
        INTO p_den_familia
        FROM familia
       WHERE cod_empresa = p_cod_empresa
         AND cod_familia = p_kana_novos_produtos_familias.cod_familia
          
      IF STATUS = 100 THEN 
         ERROR 'Família não cadastrada na tabela familia !!!'
         NEXT FIELD cod_familia
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','familia')
            RETURN FALSE
         END IF 
      END IF  
      
      DISPLAY p_den_familia TO den_familia
      
      SELECT cod_familia
        FROM kana_novos_produtos_familias
       WHERE cod_familia = p_kana_novos_produtos_familias.cod_familia
          
      IF STATUS = 0 THEN 
         ERROR 'Família já cadastrada na tabela kana_novos_produtos_familias !!!'
         NEXT FIELD cod_familia
      ELSE
         IF STATUS <> 100 THEN 
            CALL log003_err_sql('lendo','kana_novos_produtos_familias')
            RETURN FALSE
         END IF 
      END IF
      
      AFTER FIELD data_inicio
      IF p_kana_novos_produtos_familias.data_inicio IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD data_inicio   
      END IF
      
      AFTER FIELD data_termino
      IF p_kana_novos_produtos_familias.data_termino IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD data_termino   
      END IF
      
      IF p_kana_novos_produtos_familias.data_termino < TODAY THEN 
         ERROR "A data final não pode ser inferior a data atual !!!"
         NEXT FIELD data_termino
      ELSE
         IF p_kana_novos_produtos_familias.data_inicio > p_kana_novos_produtos_familias.data_termino THEN 
            ERROR "A data inicial não pode ser superior a data final !!!"
            NEXT FIELD data_inicio
         END IF  
      END IF
      
      ON KEY (control-z)
         CALL pol1043_popup()
      
   END INPUT 

   IF INT_FLAG  THEN
      CALL pol1043_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1043_busca_identificador()
#-------------------------------------#

   SELECT MAX (idinpf)
     INTO p_kana_novos_produtos_familias.idinpf
     FROM kana_novos_produtos_familias
    
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo", "kana_novos_produtos_familias")
      RETURN FALSE
   END IF 
   
   IF p_kana_novos_produtos_familias.idinpf IS NULL THEN 
      LET p_kana_novos_produtos_familias.idinpf = 1
   ELSE
      LET p_kana_novos_produtos_familias.idinpf = p_kana_novos_produtos_familias.idinpf + 1
   END IF 
   
   RETURN TRUE
   
END FUNCTION 

#-----------------------#
 FUNCTION pol1043_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
     WHEN INFIELD(cod_familia)
         CALL log009_popup(8,10,"FAMÌLIAS","familia",
                     "cod_familia","den_familia","","N","")
              RETURNING p_codigo
         CALL log006_exibe_teclas("01",p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_kana_novos_produtos_familias.cod_familia = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_familia
         END IF
   END CASE 
   
END FUNCTION 
  
#--------------------------#
 FUNCTION pol1043_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1043_limpa_tela()
      
   LET p_cod_familia_ant = p_cod_familia
   LET INT_FLAG          = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      kana_novos_produtos_familias.cod_familia,
      kana_novos_produtos_familias.idinpf,
      kana_novos_produtos_familias.data_inicio,
      kana_novos_produtos_familias.data_termino
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_cod_familia = p_cod_familia_ant
         CALL pol1043_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT cod_familia",
                  "  FROM kana_novos_produtos_familias ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_familia"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_familia

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1043_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1043_exibe_dados()
#------------------------------#

   SELECT idinpf,
          data_inicio,
          data_termino
     INTO p_kana_novos_produtos_familias.idinpf,
          p_kana_novos_produtos_familias.data_inicio,
          p_kana_novos_produtos_familias.data_termino
     FROM kana_novos_produtos_familias
    WHERE cod_familia = p_cod_familia 
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo', 'kana_novos_produtos_familias')
      RETURN FALSE 
   END IF
   
   SELECT den_familia
     INTO p_den_familia
     FROM familia
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = p_cod_familia
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo', 'familia')
      RETURN FALSE 
   END IF
   
   LET p_kana_novos_produtos_familias.cod_familia = p_cod_familia
   
   DISPLAY BY NAME p_kana_novos_produtos_familias.*
   DISPLAY p_den_familia TO den_familia
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1043_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_familia_ant = p_cod_familia

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_familia
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_familia
         
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_familia
           FROM kana_novos_produtos_familias
          WHERE cod_familia = p_cod_familia
             
         IF STATUS = 0 THEN
            CALL pol1043_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_familia = p_cod_familia_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1043_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_familia 
      FROM kana_novos_produtos_familias  
     WHERE cod_familia = p_cod_familia
           FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","kana_novos_produtos_familias")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1043_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE

   IF pol1043_prende_registro() THEN
      IF pol1043_edita_dados("M") THEN
         
         UPDATE kana_novos_produtos_familias
            SET idinpf       = p_kana_novos_produtos_familias.idinpf,
                data_inicio  = p_kana_novos_produtos_familias.data_inicio,
                data_termino = p_kana_novos_produtos_familias.data_termino
          WHERE cod_familia  = p_cod_familia
             
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificando","kana_novos_produtos_familias")
         END IF
      ELSE
         CALL pol1043_exibe_dados() RETURNING p_status
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
 FUNCTION pol1043_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1043_prende_registro() THEN
      
      DELETE FROM kana_novos_produtos_familias
			 WHERE cod_familia = p_cod_familia
    		
      IF STATUS = 0 THEN               
         INITIALIZE p_kana_novos_produtos_familias TO NULL
         CALL pol1043_limpa_tela()
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","kana_novos_produtos_familias")
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
#-----------------------#
 FUNCTION pol1043_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
#-------------------------------- FIM DE PROGRAMA -----------------------------#