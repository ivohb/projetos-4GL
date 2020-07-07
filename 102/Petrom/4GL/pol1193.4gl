#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1193                                                 #
# OBJETIVO: PORCENTAGEM P/ APLICAÇÃO NO LUCRO                       #
# AUTOR...: IVO BL                                                  #
# DATA....: 30/04/2013                                              #
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

DEFINE pr_percent         ARRAY[100] OF RECORD
       valor_de           LIKE pct_lucro_455.valor_de,    
       valor_ate          LIKE pct_lucro_455.valor_ate,   
       pct_aplicado       LIKE pct_lucro_455.pct_aplicado
END RECORD

DEFINE sql_stmt            CHAR(500),
       where_clause        CHAR(500),  
       p_cod_indicador     CHAR(05)  

DEFINE p_tela              RECORD
       cod_indicador       LIKE indicadores_455.cod_indicador,
       descricao           LIKE indicadores_455.descricao
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1193-10.02.02"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0 THEN
      CALL pol1193_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1193_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1193") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1193 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1193_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            CALL pol1193_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1193_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR p_msg
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            ERROR "Só existe uma tabela de dados !!!"
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            ERROR "Só existe uma tabela de dados !!!"
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1193_modificacao() RETURNING p_status  
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
            CALL pol1193_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1193_listagem() 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1193_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1193

END FUNCTION

#----------------------------#
FUNCTION pol1193_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#-----------------------#
 FUNCTION pol1193_sobre()
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
 FUNCTION pol1193_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_cod_pergunta TO NULL
   LET p_opcao = 'I'

   IF NOT pol1193_le_itens() THEN
      RETURN FALSE
   END IF
   
   IF pol1193_edita_itens() THEN      
      IF pol1193_grava_dados() THEN    
         LET p_ies_cons = TRUE
         RETURN TRUE                                                                    
      END IF                                                                      
   END IF
   
   RETURN FALSE
   
END FUNCTION

#--------------------------#
FUNCTION pol1193_le_itens()#
#--------------------------#

   INITIALIZE pr_percent TO NULL
   LET p_index = 1
   
   DECLARE cq_itens CURSOR FOR
    SELECT valor_de,
           valor_ate,
           pct_aplicado
      FROM pct_lucro_455 
     ORDER BY valor_de
   
   FOREACH cq_itens INTO pr_percent[p_index].*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_itens')
         RETURN FALSE
      END IF

      LET p_index = p_index + 1
   
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_percent 
      WITHOUT DEFAULTS FROM sr_percent.*
         BEFORE INPUT
         EXIT INPUT
   END INPUT
   
   RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION pol1193_edita_itens()#
#------------------------------#     

   LET INT_FLAG = FALSE

   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS
   
      AFTER FIELD cod_indicador

         IF p_tela.cod_indicador IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_indicador   
         END IF
         
         SELECT descricao
           INTO p_tela.descricao
           FROM indicadores_455
          WHERE cod_indicador = p_tela.cod_indicador
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','indicadores_455')
            NEXT FIELD cod_indicador
         END IF
         
         DISPLAY p_tela.descricao TO descricao

      ON KEY (control-z)
         CALL pol1193_popup()
   
   END INPUT

   IF INT_FLAG THEN
      IF NOT p_ies_cons THEN
         CALL pol1193_limpa_tela()
      END IF
      RETURN FALSE
   END IF
   
   INPUT ARRAY pr_percent
      WITHOUT DEFAULTS FROM sr_percent.*
         ATTRIBUTES(INSERT ROW = TRUE, DELETE ROW = TRUE)

      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      BEFORE FIELD valor_de

         IF p_index = 1 THEN
            LET pr_percent[p_index].valor_de = 0
         ELSE
            LET pr_percent[p_index].valor_de = pr_percent[p_index-1].valor_ate + 1
         END IF
         DISPLAY pr_percent[p_index].valor_de TO sr_percent[s_index].valor_de
         NEXT FIELD valor_ate

      BEFORE FIELD valor_ate

         IF pr_percent[p_index].valor_de IS NULL THEN
            NEXT FIELD valor_de
         END IF

      AFTER FIELD valor_ate

         IF pr_percent[p_index].valor_ate IS NOT NULL THEN
            IF pr_percent[p_index].valor_ate < pr_percent[p_index].valor_de THEN
               ERROR 'Intevalo de valores inválido'
               NEXT FIELD valor_ate
            END IF
         ELSE
            IF  pr_percent[p_index].pct_aplicado IS NOT NULL THEN
               ERROR 'Campo com preenchimento obrigatório'
               NEXT FIELD valor_ate
            END IF
         END IF
         
         IF p_index < (ARR_COUNT() - 1) THEN
            LET pr_percent[p_index+1].valor_de = pr_percent[p_index].valor_ate + 1
         END IF
         DISPLAY pr_percent[p_index+1].valor_de TO sr_percent[s_index+1].valor_de

      BEFORE FIELD pct_aplicado

         IF pr_percent[p_index].valor_ate IS NULL THEN
            NEXT FIELD valor_ate
         END IF
         

      AFTER ROW
      
         IF FGL_LASTKEY() = 27   OR 
            FGL_LASTKEY() = 2000 OR 
            FGL_LASTKEY() = 4010 OR 
            FGL_LASTKEY() = 2016 OR 
            FGL_LASTKEY() = 2    OR INT_FLAG THEN
            IF pr_percent[p_index].valor_ate IS NULL THEN
               LET pr_percent[p_index].valor_de = NULL
               DISPLAY pr_percent[p_index].valor_de TO sr_percent[s_index].valor_de
            END IF
         ELSE
            IF pr_percent[p_index].valor_ate IS NULL  OR pr_percent[p_index].valor_ate < 0 THEN
               ERROR 'Campo com preenchimento obrigatório'
               NEXT FIELD valor_ate
            END IF

            IF pr_percent[p_index].pct_aplicado IS NULL  OR pr_percent[p_index].pct_aplicado < 0 THEN
               ERROR 'Campo com preenchimento obrigatório'
               NEXT FIELD pct_aplicado
            END IF
         END IF

         AFTER INPUT
            IF NOT INT_FLAG THEN
               FOR p_ind = 1 TO ARR_COUNT()
                   IF pr_percent[p_ind].valor_ate IS NOT NULL THEN
                      IF pr_percent[p_ind].pct_aplicado IS NULL THEN
                         ERROR 'Preencha o PCT de todas as linhas da grade'
                         NEXT FIELD pct_aplicado
                      END IF
                      IF pr_percent[p_ind].valor_ate < pr_percent[p_ind].valor_de THEN
                         ERROR 'Há linha com intervalo de valores inválido'
                         NEXT FIELD valor_ate
                      END IF
                   END IF
                END FOR
             END IF
         
   END INPUT 

   IF INT_FLAG THEN
      IF NOT p_ies_cons THEN
         CALL pol1193_limpa_tela()
      ELSE
        CALL pol1193_le_itens() RETURNING p_status
      END IF
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION

#-----------------------#
 FUNCTION pol1193_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_indicador)
         CALL log009_popup(8,25,"INDICADORES","indicadores_455",
                     "cod_indicador","descricao","pol1188","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)

         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_indicador = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_indicador
         END IF

   END CASE
   
END FUNCTION 

#-----------------------------#
 FUNCTION pol1193_grava_dados()
#-----------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DELETE FROM pct_lucro_455 
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando", "pct_lucro_455  ")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_percent[p_ind].valor_ate IS NOT NULL THEN
          
		       INSERT INTO pct_lucro_455  
		       VALUES (pr_percent[p_ind].valor_de,
		               pr_percent[p_ind].valor_ate,
		               pr_percent[p_ind].pct_aplicado,
		               p_tela.cod_indicador)
		
		       IF STATUS <> 0 THEN 
		          CALL log003_err_sql("Incluindo", "pct_lucro_455  ")
		          CALL log085_transacao("ROLLBACK")
		          RETURN FALSE
		       END IF
       END IF
   END FOR
         
   CALL log085_transacao("COMMIT")	      
   
   RETURN TRUE
      
END FUNCTION

#--------------------------#
FUNCTION pol1193_consulta()#
#--------------------------#
   
   LET p_ies_cons = FALSE
   
   IF NOT pol1193_le_itens() THEN
      LET p_msg = 'Operação cancelada'
      RETURN FALSE
   END IF
   
   IF p_index = 1 THEN
      LET p_msg = 'Não há dados cadastrados'
      RETURN FALSE
   END IF

   SELECT DISTINCT
          cod_indicador
     INTO p_tela.cod_indicador
     FROM pct_lucro_455
   
   SELECT descricao
     INTO p_tela.descricao
     FROM indicadores_455
    WHERE cod_indicador = p_tela.cod_indicador
    
   DISPLAY BY NAME p_tela.*
   
   LET p_ies_cons = TRUE
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
 FUNCTION pol1193_prende_tabela()
#--------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   LOCK TABLE pct_lucro_455 IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Bloqueando","pct_lucro_455  ")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol1193_modificacao()
#-----------------------------#

   LET p_retorno = FALSE
   LET p_opcao   = 'M'
   
   IF pol1193_prende_tabela() THEN
      IF pol1193_edita_itens() THEN
         IF pol1193_grava_dados() THEN
            LET p_retorno = TRUE
         END IF
      END IF
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
 FUNCTION pol1193_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1193_prende_tabela() THEN
      DELETE FROM pct_lucro_455  
         
      IF STATUS = 0 THEN               
         CALL pol1193_limpa_tela()
         LET p_ies_cons = FALSE
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","pct_lucro_455  ")
      END IF
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#--------------------------#
 FUNCTION pol1193_listagem()
#--------------------------#     

   IF NOT pol1193_le_itens() THEN
      RETURN
   END IF

   IF p_index = 1 THEN
      ERROR "Não existem dados há serem listados !!!"
      RETURN
   END IF

   IF NOT pol1193_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1193_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   OUTPUT TO REPORT pol1193_relat() 

   LET p_count = 1
      

   FINISH REPORT pol1193_relat   
   
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

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1193_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1193_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1193.tmp'
         START REPORT pol1193_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1193_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1193_le_den_empresa()
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

#----------------------#
 REPORT pol1193_relat()#
#----------------------#
             
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 072, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1193       PORCENTAGEM P/ APLICACAO NO LUCRO",
               COLUMN 061, TODAY USING "dd/mm/yyyy", " ", TIME

         PRINT COLUMN 001, "-------------------------------------------------------------------------------"

      PAGE HEADER
	  
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 072, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1193       PORCENTAGEM P/ APLICACAO NO LUCRO",
               COLUMN 061, TODAY USING "dd/mm/yyyy", " ", TIME

         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
               
      ON EVERY ROW

         PRINT
         PRINT COLUMN 001, '   VALOR DE       VALOR ATE    PCT'
         PRINT COLUMN 001, '-------------- -------------- -----'

         FOR p_ind = 1 TO ARR_COUNT()   
            
            PRINT COLUMN 001, pr_percent[p_ind].valor_de USING '###,###,##&.&&',
                  COLUMN 016, pr_percent[p_ind].valor_ate USING '###,###,##&.&&',
                  COLUMN 031, pr_percent[p_ind].pct_aplicado USING '#&.&&'
         END FOR

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
