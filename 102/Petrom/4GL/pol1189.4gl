#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1189                                                 #
# OBJETIVO: VIGÊNCIA DOS INDICADORES                                #
# AUTOR...: IVO BL                                                  #
# DATA....: 22/04/2013                                              #
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
          p_excluiu            SMALLINT
                   
END GLOBALS

DEFINE pr_indicador         ARRAY[1000] OF RECORD
       cod_indicador        LIKE indicadores_455.cod_indicador,
       descricao            LIKE indicadores_455.descricao,
       valor                LIKE validade_indicador_455.valor
END RECORD

DEFINE p_tela               RECORD
       cod_cliente          LIKE validade_indicador_455.cod_cliente,
       nom_cliente          LIKE clientes.nom_cliente,
       dat_ini_vigencia     LIKE validade_indicador_455.dat_ini_vigencia,
       dat_fim_vigencia     LIKE validade_indicador_455.dat_fim_vigencia
END RECORD

DEFINE p_telaa              RECORD
       cod_cliente          LIKE validade_indicador_455.cod_cliente,
       nom_cliente          LIKE clientes.nom_cliente,
       dat_ini_vigencia     LIKE validade_indicador_455.dat_ini_vigencia,
       dat_fim_vigencia     LIKE validade_indicador_455.dat_fim_vigencia
END RECORD

DEFINE p_dat_fim_vigencia     DATE,
       sql_stmt, where_clause CHAR(500)  

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1189-10.02.05"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0 THEN
      CALL pol1189_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1189_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1189") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1189 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1189_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            CALL pol1189_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1189_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1189_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1189_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1189_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_cod_cliente TO cod_cliente
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1189_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1189_listagem() RETURNING p_status
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1189_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1189

END FUNCTION

#----------------------------#
FUNCTION pol1189_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#-----------------------#
 FUNCTION pol1189_sobre()
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

#--------------------------#
 FUNCTION pol1189_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela TO NULL
   LET p_opcao = 'I'
   
   IF pol1189_edita_dados() THEN      
      IF pol1189_edita_indicador() THEN      
         IF pol1189_grava_dados() THEN                                                     
            RETURN TRUE                                                                    
         END IF                                                                      
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1189_edita_dados()
#-----------------------------#
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
            
      AFTER FIELD cod_cliente
         IF p_tela.cod_cliente IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_cliente   
         END IF
                            
         SELECT nom_cliente
           INTO p_tela.nom_cliente
           FROM clientes
          WHERE cod_cliente = p_tela.cod_cliente
       
         IF STATUS = 100 THEN
            ERROR "Cliente inixistente."
            NEXT FIELD cod_cliente
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('lendo','clientes')
               RETURN FALSE
            END IF 
         END IF

         DISPLAY p_tela.nom_cliente TO nom_cliente
         
         SELECT MAX(dat_fim_vigencia)
           INTO p_dat_fim_vigencia
           FROM validade_indicador_455
          WHERE cod_cliente = p_tela.cod_cliente

         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','validade_indicador_455')
            RETURN FALSE
         END IF 
         
      AFTER FIELD dat_ini_vigencia
      
         IF p_dat_fim_vigencia IS NOT NULL THEN
            IF p_dat_fim_vigencia >= p_tela.dat_ini_vigencia THEN
               LET p_msg = 'A data inicial da vigência deve ser\n',
                           'maior que ', p_dat_fim_vigencia, ' ou seja\n',
                           'maior que a última vigência cadastrada.'
               CALL log0030_mensagem(p_msg,'excla')
               NEXT FIELD dat_ini_vigencia
            END IF
         END IF

      ON KEY (control-v)
         CALL pol1189_vigen_anterior()

      ON KEY (control-z)
         CALL pol1189_popup()
      
      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF p_tela.dat_fim_vigencia < p_tela.dat_ini_vigencia THEN
               ERROR 'Período de vigência inválido.'
               NEXT FIELD dat_fim_vigencia
            END IF
         END IF
                   
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1189_le_indicadores() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1189_le_indicadores()#
#--------------------------------#

   INITIALIZE pr_indicador TO NULL
   LET p_index = 1
   
   DECLARE cq_indic CURSOR FOR
      SELECT cod_indicador,
             descricao
        FROM indicadores_455

   FOREACH cq_indic INTO 
      pr_indicador[p_index].cod_indicador,
      pr_indicador[p_index].descricao
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_indic')
         RETURN FALSE
      END IF
   
    SELECT valor
      INTO pr_indicador[p_index].valor
      FROM validade_indicador_455 
     WHERE cod_cliente = p_tela.cod_cliente
       AND cod_indicador = pr_indicador[p_index].cod_indicador
       AND dat_ini_vigencia = p_tela.dat_ini_vigencia
       AND dat_fim_vigencia = p_tela.dat_fim_vigencia
         
      IF STATUS <> 0 THEN
         LET pr_indicador[p_index].valor = 0
      END IF
       
      IF pr_indicador[p_index].valor IS NULL THEN
         LET pr_indicador[p_index].valor = 0
      END IF
      
      LET p_index = p_index + 1
   
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_indicador 
      WITHOUT DEFAULTS FROM sr_indicador.*
         BEFORE INPUT
         EXIT INPUT
   END INPUT
   
   RETURN TRUE

END FUNCTION
   
#-----------------------#
 FUNCTION pol1189_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CURRENT WINDOW IS w_pol1189
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_cliente = p_codigo
            DISPLAY p_codigo TO cod_cliente
         END IF
   END CASE
   
END FUNCTION 

#--------------------------------#
FUNCTION pol1189_vigen_anterior()#
#--------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1189a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1189a AT 8,30 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1189_exib_vigencias()
   
   CLOSE WINDOW w_pol1189a

END FUNCTION

#--------------------------------#
FUNCTION pol1189_exib_vigencias()#
#--------------------------------#

   DEFINE pr_vigencia  ARRAY[200] OF RECORD
          dat_ini_vigencia  LIKE validade_indicador_455.dat_ini_vigencia,
          dat_fim_vigencia  LIKE validade_indicador_455.dat_fim_vigencia
   END RECORD

   LET p_ind = 1
    
   DECLARE cq_datas CURSOR FOR
    SELECT DISTINCT
           dat_ini_vigencia,
           dat_fim_vigencia
      FROM validade_indicador_455
     WHERE cod_cliente = p_tela.cod_cliente
     ORDER BY dat_ini_vigencia

   FOREACH cq_datas
      INTO pr_vigencia[p_ind].dat_ini_vigencia,
           pr_vigencia[p_ind].dat_fim_vigencia

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_datas')
         EXIT FOREACH
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 200 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(p_ind - 1)
   
   IF p_ind = 1 THEN
      LET p_msg = 'Não há vigências anteriores'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN
   END IF
   
   DISPLAY ARRAY pr_vigencia TO sr_vigencia.*
      
END FUNCTION

#----------------------------------#
 FUNCTION pol1189_edita_indicador()#
#----------------------------------#     

   INPUT ARRAY pr_indicador
      WITHOUT DEFAULTS FROM sr_indicador.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)

      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
      
      AFTER FIELD valor
      
         IF pr_indicador[p_index].valor IS NULL THEN
            LET pr_indicador[p_index].valor = 0
            DISPLAY pr_indicador[p_index].valor TO sr_indicador[s_index].valor
         END IF
         
         IF pr_indicador[p_index+1].cod_indicador IS NULL THEN
            IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
                 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
            ELSE
               NEXT FIELD valor
            END IF
         END IF
         
         ON KEY (control-z)
            CALL pol1189_popup()
                 
   END INPUT 

   IF INT_FLAG THEN
      IF p_opcao = 'I' THEN
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
      ELSE
        CALL pol1189_le_indicadores() RETURNING p_status
      END IF
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION

#-----------------------------#
 FUNCTION pol1189_grava_dados()
#-----------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DELETE FROM validade_indicador_455
    WHERE cod_cliente = p_tela.cod_cliente
      AND dat_ini_vigencia = p_tela.dat_ini_vigencia
      AND dat_fim_vigencia = p_tela.dat_fim_vigencia
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando", "validade_indicador_455")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_indicador[p_ind].cod_indicador IS NOT NULL THEN
          
		       INSERT INTO validade_indicador_455
		       VALUES (p_tela.cod_cliente,
		               pr_indicador[p_ind].cod_indicador,
		               pr_indicador[p_ind].valor,
		               p_tela.dat_ini_vigencia,
		               p_tela.dat_fim_vigencia)
		
		       IF STATUS <> 0 THEN 
		          CALL log003_err_sql("Incluindo", "validade_indicador_455")
		          CALL log085_transacao("ROLLBACK")
		          RETURN FALSE
		       END IF
       END IF
   END FOR
         
   CALL log085_transacao("COMMIT")	      
   
   RETURN TRUE
      
END FUNCTION

#--------------------------#
 FUNCTION pol1189_consulta()
#--------------------------#

   CALL pol1189_limpa_tela()
   LET p_telaa.* = p_tela.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      validade_indicador_455.cod_cliente,
      validade_indicador_455.dat_ini_vigencia,
      validade_indicador_455.dat_fim_vigencia
      
      ON KEY (control-z)
         CALL pol1189_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      CALL pol1189_limpa_tela()
      IF p_ies_cons THEN 
         IF p_excluiu THEN
         ELSE
            LET p_tela.* = p_telaa.*
            CALL pol1189_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET sql_stmt = "SELECT DISTINCT cod_cliente, ",
                  " dat_ini_vigencia, dat_fim_vigencia ",
                  "  FROM validade_indicador_455 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_cliente, dat_ini_vigencia"

   IF p_opcao = 'L' THEN
      RETURN TRUE
   END IF

   LET p_excluiu = FALSE

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO 
      p_tela.cod_cliente,
      p_tela.dat_ini_vigencia,
      p_tela.dat_fim_vigencia

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1189_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1189_exibe_dados()
#------------------------------#

   LET p_excluiu = FALSE

   SELECT nom_cliente
     INTO p_tela.nom_cliente
     FROM clientes
    WHERE cod_cliente = p_tela.cod_cliente
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','clientes')
      RETURN FALSE 
   END IF

   DISPLAY BY NAME p_tela.*
           
   IF NOT pol1189_le_indicadores() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION pol1189_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_telaa.* = p_tela.*

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO 
              p_tela.cod_cliente, p_tela.dat_ini_vigencia, p_tela.dat_fim_vigencia
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO 
              p_tela.cod_cliente, p_tela.dat_ini_vigencia, p_tela.dat_fim_vigencia
         
      END CASE

      IF STATUS = 0 THEN
         
         LET p_count = 0
         
         SELECT COUNT(cod_cliente)
           INTO p_count
           FROM validade_indicador_455
          WHERE cod_cliente  = p_tela.cod_cliente
            AND dat_ini_vigencia = p_tela.dat_ini_vigencia
            AND dat_fim_vigencia = p_tela.dat_fim_vigencia
                        
         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo", "validade_indicador_455")
         END IF
         
         IF p_count > 0 THEN   
            CALL pol1189_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_tela.* = p_telaa.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION


#----------------------------------#
 FUNCTION pol1189_prende_registro()
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT cod_cliente 
      FROM validade_indicador_455  
     WHERE cod_cliente  = p_tela.cod_cliente
       AND dat_ini_vigencia = p_tela.dat_ini_vigencia
       AND dat_fim_vigencia = p_tela.dat_fim_vigencia
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","validade_indicador_455")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1189_modificacao()
#-----------------------------#

   IF p_excluiu THEN
      CALL log0030_mensagem("Selecione o registro a modificar !!!", "exclamation")
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE
   LET INT_FLAG  = FALSE
   LET p_opcao   = 'M'
   
   IF pol1189_prende_registro() THEN
      IF pol1189_edita_indicador() THEN
         IF pol1189_grava_dados() THEN
            LET p_retorno = TRUE
         END IF
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
 FUNCTION pol1189_exclusao()
#--------------------------#

   IF p_excluiu THEN
      CALL log0030_mensagem("Selecione o registro a excluír !!!", "exclamation")
      RETURN FALSE
   END IF

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1189_prende_registro() THEN
      DELETE FROM validade_indicador_455
       WHERE cod_cliente  = p_tela.cod_cliente
         AND dat_ini_vigencia = p_tela.dat_ini_vigencia
         AND dat_fim_vigencia = p_tela.dat_fim_vigencia
         
      IF STATUS = 0 THEN               
         CALL pol1189_limpa_tela()
         LET p_excluiu = TRUE
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","validade_indicador_455")
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
 FUNCTION pol1189_listagem()
#--------------------------#     

   LET p_telaa.* = p_tela.*
   
   LET p_opcao = 'L'
   
   IF NOT pol1189_consulta() THEN
      ERROR 'Operação cancelada.'
      RETURN FALSE
   END IF
   
   IF NOT pol1189_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1189_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   PREPARE query FROM sql_stmt   
   DECLARE cq_impressao CURSOR  FOR query

   FOREACH cq_impressao INTO
      p_tela.cod_cliente,
      p_tela.dat_ini_vigencia,
      p_tela.dat_fim_vigencia
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_impressao')
         EXIT FOREACH
      END IF 
   
      SELECT nom_cliente
        INTO p_tela.nom_cliente
        FROM clientes
       WHERE cod_cliente = p_tela.cod_cliente
      
      IF STATUS <> 0 THEN
         LET p_tela.nom_cliente = ''
      END IF                                                             
     
      OUTPUT TO REPORT pol1189_relat(p_tela.cod_cliente) 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1189_relat   
   
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
         CALL log0030_mensagem(p_msg, 'exclamation')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

   IF p_ies_cons THEN
      LET p_tela.* = p_telaa.*
      CALL pol1189_exibe_dados()
   END IF

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1189_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1189_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1189.tmp'
         START REPORT pol1189_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1189_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1189_le_den_empresa()
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

#-----------------------------------#
 REPORT pol1189_relat(p_cod_cliente)#
#-----------------------------------#
    
   DEFINE p_cod_cliente   LIKE clientes.cod_cliente,
          p_cod_indicador LIKE indicadores_455.cod_indicador,
          p_valor         LIKE validade_indicador_455.valor,
          p_descricao     LIKE indicadores_455.descricao
          
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 072, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "POL1189   VALIDADE DOS INDICADORES P/ ANALISE DE CREDITO",
               COLUMN 061, TODAY USING "dd/mm/yyyy", " ", TIME

         PRINT COLUMN 001, "-------------------------------------------------------------------------------"

      PAGE HEADER
	  
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 072, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "POL1189   VALIDADE DOS INDICADORES P/ ANALISE DE CREDITO",
               COLUMN 061, TODAY USING "dd/mm/yyyy", " ", TIME

         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
               
      BEFORE GROUP OF p_cod_cliente

         SKIP TO TOP OF PAGE
                            
      ON EVERY ROW

         PRINT
         PRINT COLUMN 005, 'Cliente:  ', p_tela.cod_cliente CLIPPED, ' - ', p_tela.nom_cliente CLIPPED
         PRINT COLUMN 005, 'Vigencia: ', p_tela.dat_ini_vigencia, ' - ', p_tela.dat_fim_vigencia
         PRINT
         PRINT COLUMN 001, 'INDCADOR         DESCRICAO                     VALOR'
         PRINT COLUMN 001, '--------  ------------------------------  ----------------'

         DECLARE cq_imp CURSOR FOR
          SELECT cod_indicador,
                 descricao
            FROM indicadores_455
           ORDER BY descricao

         FOREACH cq_indic INTO 
            p_cod_indicador, p_descricao      
      
            IF STATUS <> 0 THEN
               CALL log003_err_sql('FOREACH','cq_indic')
               RETURN 
            END IF

            SELECT valor
              INTO p_valor
              FROM validade_indicador_455 
             WHERE cod_cliente = p_tela.cod_cliente
               AND cod_indicador = p_cod_indicador
               AND dat_ini_vigencia = p_tela.dat_ini_vigencia
               AND dat_fim_vigencia = p_tela.dat_fim_vigencia

            IF STATUS <> 0 THEN
               LET p_valor = 0
            END IF
            
            PRINT COLUMN 001, p_cod_indicador,
                  COLUMN 011, p_descricao,
                  COLUMN 043, p_valor USING '#,###,###,##&.&&'
   
         END FOREACH

         PRINT
         
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT


#-------------------------------- FIM DE PROGRAMA -----------------------------#
