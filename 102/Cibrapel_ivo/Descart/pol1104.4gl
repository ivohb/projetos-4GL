#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1104                                                 #
# OBJETIVO: fornecedores PARA EMPRÉSTIMOS CONSIGNADOS                     #
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
          p_msg                CHAR(100),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT
         
  
   DEFINE p_cod_fornecedor     CHAR(15),
          p_cod_for            CHAR(15),
          p_nom_fornecedor     CHAR(40)
          
   DEFINE p_relat              RECORD
          cod_fornecedor       CHAR(15),
          nom_fornecedor       CHAR(40)
   END RECORD
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1104-05.10.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1104_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1104_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1104") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1104 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1104_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1104_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1104_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1104_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1104_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1104_listagem()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1104

END FUNCTION

#--------------------------#
 FUNCTION pol1104_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_cod_fornecedor TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1104_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO fornecedor_885 VALUES (p_cod_fornecedor)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","fornecedor_265")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1104_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT p_cod_fornecedor
      WITHOUT DEFAULTS
         FROM cod_fornecedor
                       
      AFTER FIELD cod_fornecedor
      IF p_cod_fornecedor IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_fornecedor   
      END IF
          
      SELECT raz_social
        INTO p_nom_fornecedor
        FROM fornecedor
       WHERE cod_fornecedor = p_cod_fornecedor
         
      IF STATUS = 100 THEN 
         ERROR 'fornecedor não cadastrado n Logix!!!'
         NEXT FIELD cod_fornecedor
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','fornecedor')
            RETURN FALSE
         END IF 
      END IF  
     
      SELECT cod_fornecedor
        FROM fornecedor_885
       WHERE cod_fornecedor = p_cod_fornecedor
      
      IF STATUS = 0 THEN
         ERROR "Código já cadastrado como fornecedor de aparas!!!"
         NEXT FIELD cod_fornecedor
      ELSE 
         IF STATUS <> 100 THEN   
            CALL log003_err_sql('lendo','fornecedor_265')
            RETURN FALSE
         END IF 
      END IF    
      
      DISPLAY p_nom_fornecedor TO nom_fornecedor

      ON KEY (control-z)
         CALL pol1104_popup()
           
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1104_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1104
         IF p_codigo IS NOT NULL THEN
            LET p_cod_fornecedor = p_codigo
            DISPLAY p_codigo TO cod_fornecedor
         END IF

   END CASE

END FUNCTION 

#--------------------------#
 FUNCTION pol1104_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_for = p_cod_fornecedor
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      fornecedor_885.cod_fornecedor
           
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            LET p_cod_fornecedor = p_cod_for
            CALL pol1104_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT cod_fornecedor ",
                  "  FROM fornecedor_885 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_fornecedor"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_fornecedor

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1104_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1104_exibe_dados()
#------------------------------#
     
   SELECT raz_social
     INTO p_nom_fornecedor
     FROM fornecedor
    WHERE cod_fornecedor = p_cod_fornecedor
   
   IF STATUS <> 0 THEN 
      LET p_nom_fornecedor = ''
   END IF
   
   DISPLAY p_cod_fornecedor             TO cod_fornecedor
   DISPLAY p_nom_fornecedor             TO nom_fornecedor
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1104_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_for = p_cod_fornecedor
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_fornecedor
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_fornecedor
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_fornecedor
           FROM fornecedor_885
          WHERE cod_fornecedor = p_cod_fornecedor
            
         IF STATUS = 0 THEN
            CALL pol1104_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_fornecedor = p_cod_for
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1104_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_fornecedor 
      FROM fornecedor_885  
     WHERE cod_fornecedor = p_cod_fornecedor
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","fornecedor_265")
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1104_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1104_prende_registro() THEN
      DELETE FROM fornecedor_885
			WHERE cod_fornecedor = p_cod_fornecedor

      IF STATUS = 0 THEN               
         INITIALIZE p_cod_fornecedor TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","fornecedor_265")
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
 FUNCTION pol1104_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1104_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1104_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT cod_fornecedor
     FROM fornecedor_885
 ORDER BY cod_fornecedor                          
  
   FOREACH cq_impressao 
      INTO p_relat.cod_fornecedor
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      SELECT raz_social
        INTO p_relat.nom_fornecedor
        FROM fornecedor
       WHERE cod_fornecedor = p_relat.cod_fornecedor
      
      IF STATUS <> 0 THEN
         LET p_relat.cod_fornecedor = ''
      END IF 
   
      OUTPUT TO REPORT pol1104_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1104_relat   
   
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
 FUNCTION pol1104_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1104.tmp"
         START REPORT pol1104_relat TO p_caminho
      ELSE
         START REPORT pol1104_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1104_le_den_empresa()
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
 REPORT pol1104_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_comprime, p_den_empresa, 
               COLUMN 70, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol1104",
               COLUMN 025, "FORNECEDORES DE APARAS",
               COLUMN 050, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 005, 'Fornecedor                        Descricao'
         PRINT COLUMN 005, '--------------- --------------------------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 005, p_relat.cod_fornecedor,
               COLUMN 021, p_relat.nom_fornecedor
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