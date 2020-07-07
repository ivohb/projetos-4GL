#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1187                                                 #
# OBJETIVO: USUÁRIOS P/ ANALISES DE CRÉDITO                         #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 17/04/2013                                              #
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
         
  
   DEFINE p_usuario_funcao_455  RECORD LIKE usuario_funcao_455.*
          
   DEFINE p_cod_usuario      LIKE usuarios.cod_usuario,
          p_cod_usuarioa     LIKE usuarios.cod_usuario,
          p_nom_funcionario  LIKE usuarios.nom_funcionario,
          p_den_funcao       CHAR(10),
          p_funcao           CHAR(01)
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1187-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
 
   IF p_status = 0 THEN
      CALL pol1187_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1187_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1187") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1187 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1187_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1187_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1187_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1187_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1187_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_cod_usuario TO cod_usuario
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1187_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1187_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1187_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1187

END FUNCTION

#-----------------------#
 FUNCTION pol1187_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               "ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     GrupoAceex\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
FUNCTION pol1187_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION


#--------------------------#
 FUNCTION pol1187_inclusao()
#--------------------------#

   CALL pol1187_limpa_tela()
   INITIALIZE p_usuario_funcao_455 TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1187_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1187_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1187_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1187_insere()
#------------------------#

   INSERT INTO usuario_funcao_455 VALUES (p_usuario_funcao_455.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","usuario_funcao_455")       
      RETURN FALSE
   END IF
     
   RETURN TRUE

END FUNCTION
   
#---------------------------------#
 FUNCTION pol1187_edita_dados(p_op)
#---------------------------------#

   DEFINE p_op CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_usuario_funcao_455.*
      WITHOUT DEFAULTS
                       
      BEFORE FIELD cod_usuario

         IF p_op = "M" THEN
            NEXT FIELD funcao
         END IF
      
      AFTER FIELD cod_usuario

         IF p_usuario_funcao_455.cod_usuario IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_usuario   
         END IF
          
         SELECT nom_funcionario
           INTO p_nom_funcionario
           FROM usuarios
          WHERE cod_usuario = p_usuario_funcao_455.cod_usuario
         
         IF STATUS = 100 THEN 
            ERROR 'Usuário inexistente no Logix.'
            NEXT FIELD cod_usuario
         ELSE
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo','usuarios')
               RETURN FALSE
            END IF 
         END IF  
         
         DISPLAY p_nom_funcionario to nom_funcionario
                  
      ON KEY (control-z)
         CALL pol1187_popup()
      
      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF pol1187_registro_existe() THEN
               ERROR 'Usuário/função já existente.'
               NEXT FIELD cod_usuario
            END IF
         END IF
      
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1187_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_usuario)
         CALL log009_popup(8,10,"USUÁRIOS","usuarios",
              "cod_usuario","nom_funcionario","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_usuario_funcao_455.cod_usuario = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_usuario
         END IF
   END CASE 

END FUNCTION 

#---------------------------------#
FUNCTION pol1187_registro_existe()#
#---------------------------------#

   SELECT funcao
     FROM usuario_funcao_455
    WHERE cod_usuario = p_usuario_funcao_455.cod_usuario
      AND funcao = p_usuario_funcao_455.funcao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1187_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1187_limpa_tela()
   LET p_cod_usuarioa = p_cod_usuario
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      usuario_funcao_455.cod_usuario,
      usuario_funcao_455.funcao
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1187_limpa_tela()
         ELSE
            LET p_cod_usuario = p_cod_usuarioa
            CALL pol1187_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT cod_usuario, funcao ",
                  "  FROM usuario_funcao_455 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_usuario"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_usuario, p_funcao

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1187_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1187_exibe_dados()
#------------------------------#

   SELECT *
     INTO p_usuario_funcao_455.*
     FROM usuario_funcao_455
    WHERE cod_usuario = p_cod_usuario
      AND funcao = p_funcao
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "usuario_funcao_455")
      RETURN FALSE
   END IF
   
   SELECT nom_funcionario
     INTO p_nom_funcionario
     FROM usuarios
    WHERE cod_usuario = p_cod_usuario
   
   IF STATUS <> 0 THEN 
      LET p_nom_funcionario = ''
   END IF
   
   DISPLAY BY NAME p_usuario_funcao_455.*

   DISPLAY p_nom_funcionario TO nom_funcionario
      
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
 FUNCTION pol1187_paginacao(p_op)
#-------------------------------#

   DEFINE p_op CHAR(01)

   LET p_cod_usuarioa = p_cod_usuario
   
   WHILE TRUE
      CASE
         WHEN p_op = "S" FETCH NEXT cq_padrao INTO p_cod_usuario, p_funcao
                                                       
         WHEN p_op = "A" FETCH PREVIOUS cq_padrao INTO p_cod_usuario, p_funcao
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_usuario
           FROM usuario_funcao_455
          WHERE cod_usuario = p_cod_usuario
            AND funcao = p_funcao
            
         IF STATUS = 0 THEN
            CALL pol1187_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_usuario = p_cod_usuarioA
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1187_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_usuario 
      FROM usuario_funcao_455  
     WHERE cod_usuario = p_cod_usuario
       AND funcao = p_funcao
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","usuario_funcao_455")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1187_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   
   IF pol1187_prende_registro() THEN
      IF pol1187_edita_dados("M") THEN
         IF pol11163_atualiza() THEN
            LET p_retorno = TRUE
         END IF
      ELSE
         CALL pol1187_exibe_dados() RETURNING p_status
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
FUNCTION pol11163_atualiza()
#--------------------------#

   UPDATE usuario_funcao_455
      SET usuario_funcao_455.* = p_usuario_funcao_455.*
    WHERE cod_usuario = p_cod_usuario
      AND funcao = p_funcao
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Modificando", "usuario_funcao_455")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1187_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1187_prende_registro() THEN
      IF pol1187_deleta() THEN
         INITIALIZE p_usuario_funcao_455 TO NULL
         CALL pol1187_limpa_tela()
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
FUNCTION pol1187_deleta()
#------------------------#

   DELETE FROM usuario_funcao_455
    WHERE cod_usuario = p_cod_usuario
      AND funcao = p_funcao

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","usuario_funcao_455")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1187_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1187_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1187_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT *
     FROM usuario_funcao_455
 ORDER BY cod_usuario                          
  
   FOREACH cq_impressao 
      INTO p_usuario_funcao_455.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      SELECT nom_funcionario
        INTO p_nom_funcionario
        FROM usuarios
       WHERE cod_usuario = p_usuario_funcao_455.cod_usuario
      
      IF STATUS <> 0 THEN
         LET p_nom_funcionario = NULL
      END IF 
      
      CASE p_usuario_funcao_455.funcao
         WHEN 'A' LET p_den_funcao = 'ANALISTA'
         WHEN 'G' LET p_den_funcao = 'GERENTE'
         WHEN 'P' LET p_den_funcao = 'APROVADOR'
         WHEN 'V' LET p_den_funcao = 'VENDEDOR'
      END CASE
      
      OUTPUT TO REPORT pol1187_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1187_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1187_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1187_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1187.tmp'
         START REPORT pol1187_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1187_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1187_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------#
 REPORT pol1187_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 072, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 000, "POL1187",
               COLUMN 019, "USUARIOS PARA ANALISE DE CREDITO",
               COLUMN 061, TODAY USING "dd/mm/yyyy", " ", TIME

         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 010, 'USUARIO                 NOME                        FUNCAO'
         PRINT COLUMN 010, '-------- ---------------------------------------- ----------'
          
      PAGE HEADER  
         
         PRINT COLUMN 072, "PAG. ", PAGENO USING "##&"
         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 010, 'USUARIO                 NOME                        FUNCAO'
         PRINT COLUMN 010, '-------- ---------------------------------------- ----------'

      ON EVERY ROW

         PRINT COLUMN 010, p_usuario_funcao_455.cod_usuario,
               COLUMN 019, p_nom_funcionario,
               COLUMN 060, p_den_funcao
         
      ON LAST ROW
        
        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 055, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT


#-------------------------------- FIM DE PROGRAMA -----------------------------#