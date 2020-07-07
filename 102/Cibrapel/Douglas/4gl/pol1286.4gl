#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1286                                                 #
# OBJETIVO: FORNECEDORES/TRANSPORTADORES POR TARA MINIMA            #
# AUTOR...: DOUGLAS GREGORIO                                        #
# DATA....: 15/07/15                                                #
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
          p_ies_ambiente       char(01)


   DEFINE pr_transpor          ARRAY[1000] OF RECORD
          cod_transpor         LIKE clientes.cod_cliente,
          nom_transpor         LIKE clientes.nom_cliente
   END RECORD

   DEFINE p_cod_fornecedor     LIKE fornecedor.cod_fornecedor,
          p_cod_fornec_dest    LIKE fornecedor.cod_fornecedor,
          p_cod_fornec_ant     LIKE fornecedor.cod_fornecedor,
          p_raz_social         LIKE fornecedor.raz_social,
          p_cod_transpor       LIKE clientes.cod_cliente,
          p_nom_transpor       LIKE clientes.nom_cliente

END GLOBALS

DEFINE p_dat_atu CHAR(10)

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1286-10.02.01"
   OPTIONS
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1286_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1286_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1286") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1286 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   LET p_dat_atu = EXTEND(CURRENT, YEAR TO DAY)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1286_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1286_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte"
         ELSE
            ERROR 'consulta cancela !!!'
         END IF
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1286_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1286_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1286_modificacao() RETURNING p_status
            IF p_status THEN
               DISPLAY p_cod_fornecedor TO cod_fornecedor
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1286_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1286_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1286_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1286

END FUNCTION

#--------------------------#
 FUNCTION pol1286_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa       TO cod_empresa
   INITIALIZE pr_transpor      TO NULL
   INITIALIZE p_cod_fornecedor TO NULL
   LET p_opcao = 'I'

   IF pol1286_edita_dados() THEN
      IF pol1286_edita_transpor('I') THEN
         IF pol1286_grava_dados() THEN
            RETURN TRUE
         END IF
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol1286_edita_dados()
#-----------------------------#

   LET INT_FLAG = FALSE

   INPUT p_cod_fornecedor WITHOUT DEFAULTS
    FROM cod_fornecedor

      AFTER FIELD cod_fornecedor
      SELECT raz_social
        INTO p_raz_social
        FROM fornecedor
       WHERE cod_fornecedor = p_cod_fornecedor

      IF STATUS = 100 THEN
         ERROR "Fornecedor não localizado !!!"
         NEXT FIELD cod_fornecedor
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','fornecedor')
            RETURN FALSE
         END IF
      END IF

      DISPLAY p_raz_social TO raz_social

      LET p_count = 0

      SELECT COUNT(cod_fornecedor)
        INTO p_count
        FROM fornec_tara_minima_885
       WHERE cod_fornecedor = p_cod_fornecedor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','fornec_tara_minima_885')
         RETURN FALSE
      END IF

      IF p_count > 0 THEN
         ERROR "Já existem transportadores para este fornecedor!!! - Use a opção modificar"
         NEXT FIELD cod_fornecedor
      END IF

      ON KEY (control-z)
         CALL pol1286_popup()

   END INPUT

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------------#
 FUNCTION pol1286_edita_transpor(p_funcao)
#----------------------------------------#     

   DEFINE p_funcao CHAR(01)
   
   INPUT ARRAY pr_transpor
      WITHOUT DEFAULTS FROM sr_transpor.*
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
      
     
      
      AFTER FIELD cod_transpor
         
         FOR p_ind = 1 TO ARR_COUNT()                                                                        
            IF p_ind <> p_index THEN                                                                            
               IF pr_transpor[p_ind].cod_transpor = pr_transpor[p_index].cod_transpor THEN    
                     ERROR "Transportadora já informado para esse fornecedor !!!"                                               
                     NEXT FIELD cod_transpor   
               END IF                                                                                           
            END IF                                                                                              
         END FOR                                                                                                
                                                                                                                
         LET p_count = 0                                                                                        
                                                                                                                
         DECLARE cq_transpor CURSOR FOR                                                                           
                                                                                                                
          SELECT DISTINCT nom_cliente                                                                            
            FROM clientes                                                                                         
           WHERE cod_cliente = pr_transpor[p_index].cod_transpor                                                    
                                                                                                                
         FOREACH cq_transpor                                                                                      
            INTO pr_transpor[p_index].nom_transpor                                                                 
                                                                                                                
            IF STATUS <> 0 THEN                                                                                 
               CALL log003_err_sql('lendo',' cq_transpor')                                                            
               RETURN FALSE                                                                                     
            END IF                                                                                              
                                                                                                                
            LET p_count = 1                                                                                     
                                                                                                                
            EXIT FOREACH                                                                                        
                                                                                                                
         END FOREACH                                                                                            
                                                                                                                
         IF p_count = 0 AND pr_transpor[p_index].cod_transpor <>'' THEN                                                                                    
            ERROR "Transportador não cadastrado no Logix !!!"                                                          
            NEXT FIELD cod_transpor
         ELSE
            IF pr_transpor[p_index].cod_transpor <>'' THEN                                                                                    
              NEXT FIELD cod_transpor
            END IF
         END IF                                                                                                 
                                                                                                                                                                                                                                
         DISPLAY pr_transpor[p_index].nom_transpor TO sr_transpor[s_index].nom_transpor 
         
         AFTER ROW
            IF NOT INT_FLAG THEN                                    
               IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN                       
               ELSE                     
                  IF pr_transpor[p_index].cod_transpor IS NULL THEN   
                     NEXT FIELD cod_transpor                             
                      
                  END IF                                           
               END IF                                              
            END IF                                                 
         
         ON KEY (control-z)
            CALL pol1286_popup()
                 
   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      IF p_funcao = 'I' THEN
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
      ELSE
        CALL pol1286_carrega_transpor() RETURNING p_status
      END IF
      RETURN FALSE
   END IF
         
END FUNCTION

#---------------------------------#
 FUNCTION pol1286_carrega_transpor()
#---------------------------------#

   INITIALIZE pr_transpor TO NULL

   LET p_index = 1

   DECLARE cq_array CURSOR FOR

    SELECT cod_transpor
      FROM fornec_tara_minima_885
     WHERE cod_fornecedor = p_cod_fornecedor
     ORDER BY cod_fornecedor, cod_transpor

   FOREACH cq_array
      INTO pr_transpor[p_index].cod_transpor

      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo", "cursor: cq_array")
         RETURN FALSE
      END IF

      DECLARE cq_le_nom_transpor CURSOR FOR

       SELECT DISTINCT nom_cliente
         FROM clientes
        WHERE cod_cliente  = pr_transpor[p_index].cod_transpor

      FOREACH cq_le_nom_transpor
         INTO pr_transpor[p_index].nom_transpor

         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo", "cursor: cq_le_nom_transpor")
            RETURN FALSE
         END IF

         EXIT FOREACH

      END FOREACH

     LET p_index = p_index + 1

      IF p_index > 1000 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF

   END FOREACH

   CALL SET_COUNT(p_index - 1)

   DISPLAY p_cod_fornecedor TO cod_fornecedor
   DISPLAY p_raz_social     TO raz_social

   IF p_index > 9 THEN
      DISPLAY ARRAY pr_transpor TO sr_transpor.*
   ELSE
      INPUT ARRAY pr_transpor WITHOUT DEFAULTS FROM sr_transpor.*
         BEFORE INPUT
         EXIT INPUT
      END INPUT
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol1286_grava_dados()
#-----------------------------#

   DEFINE p_incluiu SMALLINT

   CALL log085_transacao("BEGIN")

   LET p_incluiu = FALSE

   DELETE FROM fornec_tara_minima_885
    WHERE cod_fornecedor = p_cod_fornecedor

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando", "fornec_tara_minima_885")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_transpor[p_ind].cod_transpor IS NOT NULL THEN

		       INSERT INTO fornec_tara_minima_885
		       VALUES (p_cod_fornecedor,
		               pr_transpor[p_ind].cod_transpor)

		       IF STATUS <> 0 THEN
		          CALL log003_err_sql("Incluindo", "fornec_tara_minima_885")
		          CALL log085_transacao("ROLLBACK")
		          RETURN FALSE
		       END IF
		       LET p_incluiu = TRUE
       END IF
   END FOR

   CALL log085_transacao("COMMIT")

   IF p_opcao = "I" THEN
      IF NOT p_incluiu THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1286_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0508
         IF p_codigo IS NOT NULL THEN
            LET p_cod_fornecedor = p_codigo
            DISPLAY p_codigo TO cod_fornecedor
         END IF

      WHEN INFIELD(cod_transpor)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0368
         IF p_codigo IS NOT NULL THEN
            LET pr_transpor[p_index].cod_transpor = p_codigo CLIPPED
            DISPLAY p_codigo TO sr_transpor[s_index].cod_transpor
         END IF

   END CASE

END FUNCTION

#--------------------------#
 FUNCTION pol1286_consulta()
#--------------------------#

   DEFINE sql_stmt,
          where_clause CHAR(500)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_fornec_ant = p_cod_fornecedor
   LET INT_FLAG = FALSE

   CONSTRUCT BY NAME where_clause ON
      fornec_tara_minima_885.cod_fornecedor

      ON KEY (control-z)
         CALL pol1286_popup()

   END CONSTRUCT

   IF INT_FLAG THEN
      IF p_ies_cons THEN
         LET p_cod_fornecedor = p_cod_fornec_ant
         CALL pol1286_exibe_dados() RETURNING p_status
      END IF
      RETURN FALSE
   END IF

   LET sql_stmt = "SELECT DISTINCT cod_fornecedor ",
                  "  FROM fornec_tara_minima_885 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_fornecedor "

   PREPARE var_query FROM sql_stmt
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_fornecedor

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE
      IF pol1286_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1286_exibe_dados()
#------------------------------#

   SELECT raz_social
     INTO p_raz_social
     FROM fornecedor
    WHERE cod_fornecedor = p_cod_fornecedor

   IF STATUS <> 0 THEN
      CALL log003_err_sql('lendo','bancos')
      RETURN FALSE
   END IF

   IF NOT pol1286_carrega_transpor() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION pol1286_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_fornec_ant = p_cod_fornecedor

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_fornecedor

         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_fornecedor

      END CASE

      IF STATUS = 0 THEN

         LET p_count = 0

         SELECT COUNT(cod_fornecedor)
           INTO p_count
           FROM fornec_tara_minima_885
          WHERE cod_fornecedor  = p_cod_fornecedor

         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo", "fornec_tara_minima_885")
         END IF

         IF p_count > 0 THEN
            CALL pol1286_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_fornecedor = p_cod_fornec_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1286_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_fornecedor
      FROM fornec_tara_minima_885
     WHERE cod_fornecedor = p_cod_fornecedor
       FOR UPDATE

    OPEN cq_prende
   FETCH cq_prende

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","fornec_tara_minima_885")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1286_modificacao()
#-----------------------------#

   LET p_retorno = FALSE
   LET INT_FLAG  = FALSE
   LET p_opcao   = 'M'

   IF pol1286_prende_registro() THEN
      IF pol1286_edita_transpor('M') THEN
         IF pol1286_grava_dados() THEN
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
 FUNCTION pol1286_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN
      RETURN FALSE
   END IF

   LET p_retorno = FALSE

   IF pol1286_prende_registro() THEN
      DELETE FROM fornec_tara_minima_885
			 WHERE cod_fornecedor = p_cod_fornecedor

      IF STATUS = 0 THEN
         INITIALIZE p_cod_fornecedor TO NULL
         INITIALIZE pr_transpor      TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
      ELSE
         CALL log003_err_sql("Excluindo","fornec_tara_minima_885")
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
 FUNCTION pol1286_listagem()
#--------------------------#

   IF NOT pol1286_escolhe_saida() THEN
   		RETURN
   END IF

   IF NOT pol1286_le_den_empresa() THEN
      RETURN
   END IF

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2"
   LET p_8lpp        = ascii 27, "0"

   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR

   SELECT cod_fornecedor,
          cod_transpor
     FROM fornec_tara_minima_885
 ORDER BY cod_fornecedor, cod_transpor

   FOREACH cq_impressao
      INTO p_cod_fornecedor,
           p_cod_transpor
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF

      SELECT raz_social
        INTO p_raz_social
        FROM fornecedor
       WHERE cod_fornecedor = p_cod_fornecedor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'fornecedor')
         RETURN
      END IF

      DECLARE cq_listar_transpor CURSOR FOR

       SELECT nom_cliente
         FROM clientes
        WHERE cod_cliente = p_cod_transpor

      FOREACH cq_listar_transpor
         INTO p_nom_transpor

         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','transportadoras')
            RETURN FALSE
         END IF

         EXIT FOREACH

      END FOREACH

   OUTPUT TO REPORT pol1286_relat(p_cod_fornecedor)

      LET p_count = 1

   END FOREACH

   FINISH REPORT pol1286_relat

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

   RETURN

END FUNCTION

#-------------------------------#
 FUNCTION pol1286_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF

   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1286.tmp"
         START REPORT pol1286_relat TO p_caminho
      ELSE
         START REPORT pol1286_relat TO p_nom_arquivo
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1286_le_den_empresa()
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
 REPORT pol1286_relat(p_cod_fornecedor)
#--------------------------------#

   DEFINE p_cod_fornecedor LIKE fornecedor.cod_fornecedor

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63

   FORMAT

      PAGE HEADER

         PRINT COLUMN 002,  p_den_empresa,
               COLUMN 073, "PAG. ", PAGENO USING "####&"

         PRINT COLUMN 002, "pol1286",
               COLUMN 013, "FORNECEDORES/TRANSPORTADORAS",
               COLUMN 053, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 002, "---------------------------------------------------------------------------------"
         PRINT

      BEFORE GROUP OF p_cod_banco

         PRINT
         PRINT COLUMN 003, "Banco: ", p_cod_fornecedor, " - ", p_raz_social
         PRINT
         PRINT COLUMN 002, 'Codigo    Nome'
         PRINT COLUMN 002, '--------- -----------------------------------------------------'

      ON EVERY ROW

         PRINT COLUMN 004, p_cod_transpor USING "#########",
               COLUMN 010, p_nom_transpor
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE
           PRINT " "
        END IF

END REPORT

#-----------------------#
 FUNCTION pol1286_sobre()
#-----------------------#

   {SELECT nom_caminho,
          ies_ambiente
     INTO p_caminho,
          p_ies_ambiente
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa
     AND cod_sistema = "UNL"

   LET p_nom_arquivo = p_caminho clipped,'funcionario.unl'

   LOAD from p_nom_arquivo INSERT INTO funcionario

   if STATUS <> 0 then
   end if}

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')

END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#