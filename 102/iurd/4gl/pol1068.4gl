#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1068                                                 #
# OBJETIVO: BANCOS PARA EMPRÉSTIMOS CONSIGNADOS                     #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 23/11/10                                                #
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
         
  
   DEFINE p_banco_265          RECORD LIKE banco_265.*

   DEFINE p_cod_banco          LIKE banco_265.cod_banco,
          p_cod_banco_ant      LIKE banco_265.cod_banco,
          p_nom_banco          LIKE bancos.nom_banco
          
   DEFINE p_relat              RECORD LIKE banco_265.*      
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1068-10.02.04"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1068_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1068_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1068") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1068 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1068_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1068_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1068_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1068_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1068_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_cod_banco TO cod_banco
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1068_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1068_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1068_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1068

END FUNCTION

#--------------------------#
 FUNCTION pol1068_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_banco_265.* TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1068_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      LET p_banco_265.cod_tip_reg = ' '
      INSERT INTO banco_265 VALUES (p_banco_265.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","banco_265")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1068_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT p_banco_265.cod_banco,   
         p_banco_265.den_reduz,   
         p_banco_265.nom_contato,    
         p_banco_265.num_agencia,    
         p_banco_265.nom_agencia,    
         p_banco_265.num_conta,      
         p_banco_265.dat_termino    
      WITHOUT DEFAULTS
         FROM cod_banco,   
              den_reduz,   
              nom_contato, 
              num_agencia, 
              nom_agencia, 
              num_conta,   
              dat_termino  
                       
      BEFORE FIELD cod_banco
      IF p_funcao = "M" THEN
         NEXT FIELD den_reduz
      END IF
      
      AFTER FIELD cod_banco
      IF p_banco_265.cod_banco IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_banco   
      END IF
          
      SELECT nom_banco
        INTO p_nom_banco
        FROM bancos
       WHERE cod_banco = p_banco_265.cod_banco
         
      IF STATUS = 100 THEN 
         ERROR 'Banco não cadastrado na tabela bancos!!!'
         NEXT FIELD cod_banco
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','bancos')
            RETURN FALSE
         END IF 
      END IF  
     
      SELECT cod_banco
        FROM banco_265
       WHERE cod_banco = p_banco_265.cod_banco
      
      IF STATUS = 0 THEN
         ERROR "Código já cadastrado !!!"
         NEXT FIELD cod_banco
      ELSE 
         IF STATUS <> 100 THEN   
            CALL log003_err_sql('lendo','banco_265')
            RETURN FALSE
         END IF 
      END IF    
      
      DISPLAY p_nom_banco TO nom_banco

      AFTER INPUT
      IF NOT INT_FLAG THEN
         IF p_banco_265.den_reduz IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD den_reduz   
         END IF
         IF p_banco_265.num_agencia IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD num_agencia   
         END IF
         IF p_banco_265.num_conta IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD num_conta   
         END IF
         {IF p_banco_265.dat_termino < TODAY THEN
            ERROR "A data do término não pode ser menor que o dia de hoje !!!"
            NEXT FIELD dat_termino   
         END IF}
      END IF
      
      ON KEY (control-z)
         CALL pol1068_popup()
           
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1068_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_banco)
         CALL log009_popup(8,10,"BANCOS","bancos",
              "cod_banco","nom_banco","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_banco_265.cod_banco = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_banco
         END IF
   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1068_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_banco_ant = p_cod_banco
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      banco_265.cod_banco,
      banco_265.den_reduz,
      banco_265.num_agencia,
      banco_265.nom_agencia,
      banco_265.num_conta,
      banco_265.dat_termino
      
      ON KEY (control-z)
         CALL pol1068_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            LET p_cod_banco = p_cod_banco_ant
            CALL pol1068_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT cod_banco ",
                  "  FROM banco_265 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_banco"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_banco

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1068_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1068_exibe_dados()
#------------------------------#
   
   SELECT den_reduz,
          nom_contato, 
          num_agencia, 
          nom_agencia, 
          num_conta,
          dat_termino
     INTO p_banco_265.den_reduz,
          p_banco_265.nom_contato, 
          p_banco_265.num_agencia,
          p_banco_265.nom_agencia,
          p_banco_265.num_conta, 
          p_banco_265.dat_termino
     FROM banco_265
    WHERE cod_banco = p_cod_banco
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "banco_265")
      RETURN FALSE
   END IF
   
   SELECT nom_banco
     INTO p_nom_banco
     FROM bancos
    WHERE cod_banco = p_cod_banco
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','bancos')
      RETURN FALSE 
   END IF
   
   DISPLAY p_cod_banco             TO cod_banco
   DISPLAY p_nom_banco             TO nom_banco
   DISPLAY p_banco_265.den_reduz   TO den_reduz 
   DISPLAY p_banco_265.nom_contato TO nom_contato 
   DISPLAY p_banco_265.num_agencia TO num_agencia
   DISPLAY p_banco_265.nom_agencia TO nom_agencia
   DISPLAY p_banco_265.num_conta   TO num_conta
   DISPLAY p_banco_265.dat_termino TO dat_termino
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1068_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_banco_ant = p_cod_banco
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_banco
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_banco
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_banco
           FROM banco_265
          WHERE cod_banco = p_cod_banco
            
         IF STATUS = 0 THEN
            CALL pol1068_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_banco = p_cod_banco_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1068_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_banco 
      FROM banco_265  
     WHERE cod_banco = p_cod_banco
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","banco_265")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1068_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   LET p_banco_265.cod_banco = p_cod_banco 
   
   IF pol1068_prende_registro() THEN
      IF pol1068_edita_dados("M") THEN
         
         UPDATE banco_265
            SET den_reduz   = p_banco_265.den_reduz,
                nom_contato = p_banco_265.nom_contato,
                num_agencia = p_banco_265.num_agencia, 
                nom_agencia = p_banco_265.nom_agencia,
                num_conta   = p_banco_265.num_conta,
                dat_termino = p_banco_265.dat_termino
          WHERE cod_banco   = p_cod_banco
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Modificando", "banco_265")
         ELSE
            LET p_retorno = TRUE
         END IF
      
      ELSE
         CALL pol1068_exibe_dados() RETURNING p_status
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
 FUNCTION pol1068_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1068_prende_registro() THEN
      DELETE FROM banco_265
			WHERE cod_banco = p_cod_banco

      IF STATUS = 0 THEN               
         INITIALIZE p_banco_265 TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","banco_265")
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
 FUNCTION pol1068_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1068_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1068_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT cod_banco,
          nom_contato,
          num_agencia,
          nom_agencia,
          num_conta,
          cod_tip_reg,
          dat_termino
     FROM banco_265
 ORDER BY cod_banco                          
  
   FOREACH cq_impressao 
      INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      SELECT nom_banco
        INTO p_nom_banco
        FROM bancos
       WHERE cod_banco = p_relat.cod_banco
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'bancos')
         RETURN
      END IF 
   
   OUTPUT TO REPORT pol1068_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1068_relat   
   
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
 FUNCTION pol1068_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1068.tmp"
         START REPORT pol1068_relat TO p_caminho
      ELSE
         START REPORT pol1068_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1068_le_den_empresa()
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
 REPORT pol1068_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 135, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1068",
               COLUMN 042, "BANCOS PARA EMPRESTIMOS CONSIGNADOS",
               COLUMN 114, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "----------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, 'Banco          Descricao                       Contato              Agencia           Descricao                Conta       Identif   Termino'
         PRINT COLUMN 002, '----- ------------------------------ ------------------------------ ------- ------------------------------ --------------- -------- ----------'
                            
      ON EVERY ROW

         PRINT COLUMN 004, p_relat.cod_banco   USING "###",
               COLUMN 008, p_nom_banco,
               COLUMN 039, p_relat.nom_contato,
               COLUMN 070, p_relat.num_agencia,
               COLUMN 078, p_relat.nom_agencia,
               COLUMN 109, p_relat.num_conta,
               COLUMN 131, p_relat.cod_tip_reg USING "##",
               COLUMN 134, p_relat.dat_termino
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 055, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-----------------------#
 FUNCTION pol1068_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               "      LOGIX 10.02 \n\n",
               " Home page: www.aceex.com.br\n\n",
               "    (0xx11) 4991-6667  \n",
               "    (0xx11)9-4179-6633 \n"
               

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#-------------------------------- FIM DE PROGRAMA -----------------------------#
{
- 29/11/13: conversão para o oracle
