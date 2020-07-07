#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1259                                                 #
# OBJETIVO: TIPO DE NOTA POR OPERAÇÃO                               #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 30/06/14                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_caminho            CHAR(080),
          p_status             SMALLINT
          
END GLOBALS


DEFINE p_last_row           SMALLINT,
       p_opcao              CHAR(01),  
       p_excluiu            SMALLINT,      
       p_6lpp               CHAR(100),    
       p_8lpp               CHAR(100),    
       p_msg                CHAR(500),    
       p_nom_tela           CHAR(200),    
       p_ies_cons           SMALLINT,     
       p_salto              SMALLINT,     
       p_erro_critico       SMALLINT,     
       p_existencia         SMALLINT,     
       p_num_seq            SMALLINT,     
       P_Comprime           CHAR(01),     
       p_descomprime        CHAR(01),     
       p_rowid              INTEGER,      
       p_retorno            SMALLINT,     
       p_index              SMALLINT,     
       s_index              SMALLINT,     
       p_count              SMALLINT,     
       p_houve_erro         SMALLINT,
       p_den_status         CHAR(60)

DEFINE p_den_operacao       LIKE cod_fiscal_sup.den_cod_fiscal,
       p_cod_operacao       LIKE cod_fiscal_sup.cod_fiscal
             
DEFINE p_status_nf          RECORD
       cod_empresa          char(02),
       cod_operacao         char(07),
       cod_status           char(01)
END RECORD

DEFINE p_status_nfa         RECORD
       cod_empresa          char(02),
       cod_operacao         char(07),
       cod_status           char(01)
END RECORD
             
DEFINE p_relat RECORD
       cod_operacao         char(07),
       den_operacao         char(30),
       cod_status           char(01)       
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1259-10.02.04"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
   
   #LET p_cod_empresa = '21'; LET p_status = 0; LET p_user = 'admlog'
   
   IF p_status = 0 THEN
      CALL pol1259_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1259_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1259") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1259 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO empresa
   
   CALL pol1259_gera_status()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1259_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1259_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1259_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1259_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1259_modificacao() RETURNING p_status  
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
            CALL pol1259_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1259_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1259_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1259

END FUNCTION

#-----------------------#
 FUNCTION pol1259_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               "       Autor: Ivo H Barbosa\n    ",
               " ibarbosa@totvspartners.com.br.com\n ",
               "       ivohb.me@gmail.com\n\n    ",
               "           LOGIX 10.02\n          ",
               "       www.grupoaceex.com.br\n   ",
               "       (0xx11) 4991-6667 Com.\n  ",
               "      (0xx11)94179-6633 Vivo    "

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
FUNCTION pol1259_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1259_inclusao()
#--------------------------#

   CALL pol1259_limpa_tela()
   
   INITIALIZE p_status_nf TO NULL
   LET p_status_nf.cod_empresa = p_cod_empresa

   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1259_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1259_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1259_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1259_insere()
#------------------------#

   INSERT INTO status_nf_ronc VALUES (p_status_nf.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","status_nf_ronc")       
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1259_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_status_nf.*
      WITHOUT DEFAULTS
              
      BEFORE FIELD cod_operacao

         IF p_funcao = "M" THEN
            NEXT FIELD cod_status
         END IF
      
      AFTER FIELD cod_operacao

         IF p_status_nf.cod_operacao IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório."
            NEXT FIELD cod_operacao   
         END IF
         
         IF p_status_nf.cod_operacao[1] < '5' THEN
            ERROR "Código inválido."
            NEXT FIELD cod_operacao   
         END IF
                   
         SELECT cod_operacao
           FROM status_nf_ronc
          WHERE cod_operacao = p_status_nf.cod_operacao
         
         IF STATUS = 0 THEN
            LET p_msg = ' Operação já cadastrada no POL1259.'
            ERROR p_msg
            NEXT FIELD cod_operacao   
         END IF
         
         CALL pol1259_le_operacao(p_status_nf.cod_operacao)
            RETURNING p_status
         
         IF NOT p_status THEN
            NEXT FIELD cod_operacao   
         END IF
                  
         DISPLAY p_den_operacao TO den_operacao

      AFTER FIELD cod_status

         IF p_status_nf.cod_status IS NOT NULL THEN 
            CALL pol1259_le_status(p_status_nf.cod_status)
            IF p_den_status IS NULL THEN
               ERROR 'Status inválido.'
               NEXT FIELD cod_status   
            END IF
            DISPLAY p_den_status TO den_status
         END IF
      
      
      ON KEY (control-z)
         CALL pol1259_popup()

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            
            IF p_status_nf.cod_status IS NULL THEN 
               ERROR "Campo com preenchimento obrigatório."
               NEXT FIELD cod_status   
            END IF

         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1259_le_operacao(p_cod)#
#----------------------------------#

   DEFINE p_cod LIKE cod_fiscal_sup.cod_fiscal
   
   SELECT den_cod_fiscal
     INTO p_den_operacao
     FROM cod_fiscal_sup
    WHERE cod_fiscal = p_cod

   IF STATUS <> 0 THEN
      LET p_den_operacao = NULL
      CALL log003_err_sql('SELECT', 'cod_fiscal_sup')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1259_le_status(p_cod)#
#--------------------------------#

   DEFINE p_cod CHAR(01)
   
   SELECT den_status
     INTO p_den_status
     FROM status_nota
    WHERE cod_status = p_cod

   IF STATUS <> 0 THEN
      LET p_den_status = NULL
   END IF
   
END FUNCTION
     
#-----------------------#
 FUNCTION pol1259_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)          

   CASE
      WHEN INFIELD(cod_operacao)
         CALL log009_popup(8,10,"CFOP","cod_fiscal_sup",
              "cod_fiscal","den_cod_fiscal","","N"," cod_fiscal[1] >= '5' order by cod_fiscal") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_status_nf.cod_operacao = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_operacao
         END IF

      WHEN INFIELD(cod_status)         
         LET p_codigo = pol1259_sel_status()

         IF p_codigo IS NULL OR p_codigo = ' ' THEN
         ELSE
            LET p_status_nf.cod_status = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_status
         END IF

   END CASE 

END FUNCTION 

#----------------------------#
FUNCTION pol1259_sel_status()#
#----------------------------#

   DEFINE pr_status    ARRAY[20] OF RECORD
       cod_status           char(01),
       den_status           char(60)
   END RECORD

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1259a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1259a AT 5,5 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   INITIALIZE pr_status TO NULL
   LET INT_FLAG = FALSE
   LET p_index = 1
   
   DECLARE cq_status CURSOR FOR
    SELECT cod_status,
           den_status
      FROM status_nota
     ORDER BY cod_status
  
  FOREACH cq_status INTO 
          pr_status[p_index].cod_status,
          pr_status[p_index].den_status
   
     IF STATUS <> 0 THEN
        CALL log003_err_sql('FOREACH', 'cq_status')
        EXIT FOREACH
     END IF
   
     LET p_index = p_index + 1
   
     IF p_index > 2000 THEN
        LET p_msg = 'Limite de grade ultrapassado !!!'
        CALL log0030_mensagem(p_msg,'exclamation')
        EXIT FOREACH
     END IF

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)

   DISPLAY ARRAY pr_status TO sr_status.*

      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol1259a
   
   IF NOT INT_FLAG THEN
      RETURN pr_status[p_index].cod_status
   ELSE
      RETURN ""
   END IF

END FUNCTION   

#-----------------------------#
FUNCTION pol1259_gera_status()#
#-----------------------------#

   IF NOT log0150_verifica_se_tabela_existe('status_nota') THEN
      
      CREATE TABLE status_nota(
       cod_status           char(01),
       den_status           char(60)
      );
      
      IF STATUS = 0 THEN
         CALL pol1259_ins_status()
      ELSE
         CALL log003_err_sql('CREATE','status_nota')
      END IF
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol1259_ins_status()#
#----------------------------#
   
   INSERT INTO status_nota VALUES('1','Nota Fiscal Normal')
   INSERT INTO status_nota VALUES('2','Aguarda relacionamento com Nota fiscal de entrada')
   INSERT INTO status_nota VALUES('3','Relacionamento de NFE realizado')
   INSERT INTO status_nota VALUES('4','Nota fiscal de remessa para consignação')
   INSERT INTO status_nota VALUES('5','Nota fiscal de faturamento de consignação')
   INSERT INTO status_nota VALUES('6','Nota fiscal de Entrada. Emitida pelo Suprimentos')
   INSERT INTO status_nota VALUES('7','Nota fiscal de material em trânsito')
   INSERT INTO status_nota VALUES('8','Nota fiscal de transferência de beneficiamento')
   INSERT INTO status_nota VALUES('9','itens Da NF terão as quantidades convertidas pela qtd padrão')
   INSERT INTO status_nota VALUES('A','Nota Fiscal de origem fornecedor')
   INSERT INTO status_nota VALUES('B','Nota Fiscal com origem depositante')
   INSERT INTO status_nota VALUES('C','NF complementar ou NF de reenvio de material devolvido')
   INSERT INTO status_nota VALUES('D','NF com Espécie = NFR e CFOP = x.99')
   INSERT INTO status_nota VALUES('T','controle automático de itens de terceiros para a NF')
   INSERT INTO status_nota VALUES('X','NF de devolução de mercadoria em consignação')
   INSERT INTO status_nota VALUES('P','Nota fiscal de permuta entre empresas')
   
END FUNCTION

#--------------------------#
 FUNCTION pol1259_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1259_limpa_tela()
   LET p_status_nfa.* = p_status_nf.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      status_nf_ronc.cod_operacao,     
      status_nf_ronc.cod_status
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1259_limpa_tela()
         ELSE
            LET p_status_nf.* = p_status_nfa.*
            CALL pol1259_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT cod_operacao ",
                  "  FROM status_nf_ronc ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_empresa"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_operacao

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1259_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1259_exibe_dados()
#------------------------------#

   DEFINE p_empresa CHAR(02)
   
   SELECT *
     INTO p_status_nf.*
     FROM status_nf_ronc
    WHERE cod_operacao = p_cod_operacao
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'p_status_nf')
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_status_nf.*
   
   CALL pol1259_le_operacao(p_status_nf.cod_operacao)
   DISPLAY p_den_operacao to den_operacao

   CALL pol1259_le_status(p_status_nf.cod_status)
   DISPLAY p_den_status TO den_status
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1259_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01)

   LET p_status_nfa.* = p_status_nf.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_operacao
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_operacao
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_empresa
           FROM status_nf_ronc
          WHERE cod_operacao = p_cod_operacao
            
         IF STATUS = 0 THEN
            IF pol1259_exibe_dados() THEN
               LET p_excluiu = FALSE
               EXIT WHILE
            END IF
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_status_nf.* = p_status_nfa.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1259_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_empresa 
      FROM status_nf_ronc  
     WHERE cod_operacao = p_cod_operacao
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","status_nf_ronc")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1259_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   LET p_status_nfa.* = p_status_nf.*
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF

   LET p_opcao   = "M"
   
   IF pol1259_prende_registro() THEN
      IF pol1259_edita_dados("M") THEN
         IF pol11163_atualiza() THEN
            LET p_retorno = TRUE
         END IF
      ELSE
         LET p_status_nf.* = p_status_nfa.*
         CALL pol1259_exibe_dados() RETURNING p_status
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

   UPDATE status_nf_ronc
      SET status_nf_ronc.* = p_status_nf.*
     WHERE cod_operacao = p_cod_operacao

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE", "status_nf_ronc")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1259_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1259_prende_registro() THEN
      IF pol1259_deleta() THEN
         INITIALIZE p_status_nf TO NULL
         CALL pol1259_limpa_tela()
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
FUNCTION pol1259_deleta()
#------------------------#

   DELETE FROM status_nf_ronc
    WHERE cod_operacao = p_cod_operacao

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","status_nf_ronc")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1259_listagem()
#--------------------------#     

   IF NOT pol1259_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1259_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT a.cod_operacao, 
           b.den_cod_fiscal,
           a.cod_status
      FROM status_nf_ronc a, cod_fiscal_sup b
     WHERE a.cod_operacao = b.cod_fiscal
     ORDER BY a.cod_operacao
  
   FOREACH cq_impressao 
      INTO p_relat.cod_operacao,
           p_relat.den_operacao,
           p_relat.cod_status
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'CURSOR: cq_impressao')
         RETURN
      END IF 
      
      OUTPUT TO REPORT pol1259_relat() 

      LET p_count = 1
      
   END FOREACH

   CALL pol1259_finaliza_relat()

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1259_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1259_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1259.tmp'
         START REPORT pol1259_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1259_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1259_le_den_empresa()
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

#--------------------------------#
FUNCTION pol1259_finaliza_relat()#
#--------------------------------#

   FINISH REPORT pol1259_relat   

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

END FUNCTION

#----------------------#
 REPORT pol1259_relat()
#----------------------#
    
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 071, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol1259",
               COLUMN 010, "STATUS DE NOTA FISCAL POR OPERAÇÃO",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 010, 'OPERACAO          DESCRICAO             ESTATUS'                                
         PRINT COLUMN 010, '-------- ------------------------------ -------'

      PAGE HEADER
	  
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 076, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 010, 'OPERACAO          DESCRICAO             ESTATUS'                                
         PRINT COLUMN 010, '-------- ------------------------------ -------'

      ON EVERY ROW

         PRINT COLUMN 010, p_relat.cod_operacao,
               COLUMN 019, p_relat.den_operacao,
               COLUMN 053, p_relat.cod_status
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT
                  

#-------------------------------- FIM DE PROGRAMA BL-----------------------------#
