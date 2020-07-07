#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1188                                                 #
# OBJETIVO: INDICADORES PARA ANALISE DE CRÉDITO                     #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 18/04/2013                                              #
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
          p_excluiu            SMALLINT
         
  
   DEFINE p_indicadores_455  RECORD LIKE indicadores_455.*
          
   DEFINE p_cod_indicador      LIKE indicadores_455.cod_indicador,
          p_cod_indicadora     LIKE indicadores_455.cod_indicador
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1188-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      CALL pol1188_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1188_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1188") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1188 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1188_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1188_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1188_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1188_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1188_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_cod_indicador TO cod_indicador
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1188_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1188_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1188_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1188

END FUNCTION

#-----------------------#
 FUNCTION pol1188_sobre()
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
FUNCTION pol1188_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1188_inclusao()
#--------------------------#

   CALL pol1188_limpa_tela()
   INITIALIZE p_indicadores_455 TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1188_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1188_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1188_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1188_insere()
#------------------------#

   INSERT INTO indicadores_455 VALUES (p_indicadores_455.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","indicadores_455")       
      RETURN FALSE
   END IF
     
   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1188_edita_dados(p_opcao)
#-------------------------------------#

   DEFINE p_opcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_indicadores_455.*
      WITHOUT DEFAULTS
                       
      BEFORE FIELD cod_indicador

         IF p_opcao = "M" THEN
            NEXT FIELD descricao
         END IF
      
      AFTER FIELD cod_indicador

         IF p_indicadores_455.cod_indicador IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_indicador   
         END IF

         IF pol1188_registro_existe() THEN
            ERROR 'Indicador já existente.'
            NEXT FIELD cod_indicador
         END IF
          
      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF p_indicadores_455.descricao IS NULL THEN 
               ERROR "Campo com preenchimento obrigatório !!!"
               NEXT FIELD descricao   
            END IF
         END IF
      
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1188_registro_existe()#
#---------------------------------#

   SELECT descricao
     FROM indicadores_455
    WHERE cod_indicador = p_indicadores_455.cod_indicador
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1188_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1188_limpa_tela()
   LET p_cod_indicadora = p_cod_indicador
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      indicadores_455.cod_indicador,
      indicadores_455.descricao
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1188_limpa_tela()
         ELSE
            LET p_cod_indicador = p_cod_indicadora
            CALL pol1188_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT cod_indicador ",
                  "  FROM indicadores_455 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_indicador"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_indicador

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1188_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1188_exibe_dados()
#------------------------------#

   SELECT *
     INTO p_indicadores_455.*
     FROM indicadores_455
    WHERE cod_indicador = p_cod_indicador
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "indicadores_455")
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_indicadores_455.*

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1188_paginacao(p_opcao)
#-----------------------------------#

   DEFINE p_opcao CHAR(01)

   LET p_cod_indicadora = p_cod_indicador
   
   WHILE TRUE
      CASE
         WHEN p_opcao = "S" FETCH NEXT cq_padrao INTO p_cod_indicador
                                                       
         WHEN p_opcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_indicador
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_indicador
           FROM indicadores_455
          WHERE cod_indicador = p_cod_indicador
            
         IF STATUS = 0 THEN
            CALL pol1188_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_indicador = p_cod_indicadorA
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1188_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_indicador 
      FROM indicadores_455  
     WHERE cod_indicador = p_cod_indicador
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","indicadores_455")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1188_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET INT_FLAG  = FALSE
   
   IF pol1188_prende_registro() THEN
      IF pol1188_edita_dados("M") THEN
         IF pol11163_atualiza() THEN
            LET p_retorno = TRUE
         END IF
      ELSE
         CALL pol1188_exibe_dados() RETURNING p_status
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

   UPDATE indicadores_455
      SET indicadores_455.* = p_indicadores_455.*
    WHERE cod_indicador = p_cod_indicador
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Modificando", "indicadores_455")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1188_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   SELECT COUNT(cod_indicador)
     INTO p_count
     FROM validade_indicador_455
    WHERE cod_indicador = p_cod_indicador

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','validade_indicador_455')
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      LET p_msg = 'Indicador já possui vigência\n',
                  'cadastrada. Consulte o pol1189.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   SELECT COUNT(cod_pergunta)
     INTO p_count
     FROM formulas_455
    WHERE operando = p_cod_indicador

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','formulas_455')
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      LET p_msg = 'Indicador já está sendo usado nas\n',
                  'formulas. Consulte o pol1191.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
          
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1188_prende_registro() THEN
      IF pol1188_deleta() THEN
         INITIALIZE p_indicadores_455 TO NULL
         CALL pol1188_limpa_tela()
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
FUNCTION pol1188_deleta()
#------------------------#

   DELETE FROM indicadores_455
    WHERE cod_indicador = p_cod_indicador

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","indicadores_455")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1188_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1188_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1188_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT *
     FROM indicadores_455
 ORDER BY cod_indicador                          
  
   FOREACH cq_impressao 
      INTO p_indicadores_455.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      OUTPUT TO REPORT pol1188_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1188_relat   
   
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
 FUNCTION pol1188_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1188_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1188.tmp'
         START REPORT pol1188_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1188_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1188_le_den_empresa()
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
 REPORT pol1188_relat()
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
               
         PRINT COLUMN 000, "pol1188",
               COLUMN 019, "INDICADORES PARA ANALISE DE CREDITO",
               COLUMN 061, TODAY USING "dd/mm/yyyy", " ", TIME

         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 020, 'INDICADOR          DESCRICAO'
         PRINT COLUMN 020, '--------- -----------------------------'
          
      PAGE HEADER  
         
         PRINT COLUMN 072, "PAG. ", PAGENO USING "##&"
         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 020, 'INDICADOR          DESCRICAO'
         PRINT COLUMN 020, '--------- -----------------------------'

      ON EVERY ROW

         PRINT COLUMN 020, p_indicadores_455.cod_indicador,
               COLUMN 030, p_indicadores_455.descricao
         
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