#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0001                                                 #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 14/05/2012                                              #
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
          p_rowida             INTEGER,
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
         
   
   DEFINE p_nom_cliente      LIKE clientes.nom_cliente
   
   DEFINE p_cli_hayward      RECORD LIKE cli_hayward.*
         
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0001-10.02.02"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol0001_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol0001_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0001") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0001 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol0001_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol0001_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol0001_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol0001_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol0001_modificacao() RETURNING p_status  
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
            CALL pol0001_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol0001_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol0001_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0001

END FUNCTION

#-----------------------#
 FUNCTION pol0001_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
 FUNCTION pol0001_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_cli_hayward.* TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol0001_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO cli_hayward VALUES (p_cli_hayward.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","cli_hayward")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol0001_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_cli_hayward.*
      WITHOUT DEFAULTS
   
      BEFORE FIELD cod_cliente
      IF p_funcao = "M" THEN
         NEXT FIELD nom_contato
      END IF
      
      AFTER FIELD cod_cliente
      IF p_cli_hayward.cod_cliente IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_cliente   
      END IF

      SELECT nom_cliente
        INTO p_nom_cliente
        FROM clientes               
       WHERE cod_cliente  = p_cli_hayward.cod_cliente

      if status = 100 then
         ERROR 'Cliente não cadastrado!!!'
         NEXT FIELD cod_cliente
      else
         if status <> 0 then
            call log003_err_sql('Lendo','clientes')
            NEXT FIELD cod_cliente
         end if
      END if
      
      DISPLAY p_nom_cliente to nom_cliente

      AFTER FIELD nom_contato 

      IF p_cli_hayward.nom_contato IS NULL THEN
         ERROR "O campo NOME nao pode ser nulo."
         NEXT FIELD nom_contato     
      END IF 

     ON KEY (control-z)
        CALL pol0001_popup()
      
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol0001_popup()
#-----------------------#
  
  DEFINE p_cod_cliente        LIKE clientes.cod_cliente
  
  CASE
    WHEN infield(cod_cliente)
         LET  p_cod_cliente = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0001   
         IF   p_cod_cliente IS NOT NULL THEN 
              LET  p_cli_hayward.cod_cliente = p_cod_cliente
              DISPLAY p_cli_hayward.cod_cliente TO cod_cliente
         END IF
  END CASE
  
END FUNCTION

#--------------------------#
 FUNCTION pol0001_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   INITIALIZE p_cli_hayward.* TO NULL
   DISPLAY p_cod_empresa TO cod_empresa

   LET p_rowida = p_rowid

   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      cli_hayward.cod_cliente,
      cli_hayward.nom_contato,
      cli_hayward.set_contato,
      cli_hayward.tel_contato,
      cli_hayward.fax_contato,
      cli_hayward.obs_contato
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            LET p_rowid = p_rowida
            CALL pol0001_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT rowid, cod_cliente, nom_contato ",
                  "  FROM cli_hayward ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_cliente, nom_contato"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_rowid

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol0001_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol0001_exibe_dados()
#------------------------------#
   
   SELECT *
     into p_cli_hayward.*
     from cli_hayward
    where rowid = p_rowid
   
   IF STATUS <> 0 then
      call log003_err_sql('Lendo','cli_hayward')
      RETURN FALSE
   end if
   
   DISPLAY BY NAME p_cli_hayward.*             
         
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol0001_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_rowida = p_rowid
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_rowid
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_rowid
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_cliente
           FROM cli_hayward
          WHERE rowid = p_rowid
            
         IF STATUS = 0 THEN
            CALL pol0001_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_rowid = p_rowida
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION


#----------------------------------#
 FUNCTION pol0001_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_cliente 
      FROM cli_hayward  
     WHERE rowid = p_rowid
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","cli_hayward")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0001_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET p_opcao   = "M"
   
   IF pol0001_prende_registro() THEN
      IF pol0001_edita_dados("M") THEN
         
         UPDATE cli_hayward
            SET cli_hayward.* = p_cli_hayward.*
          WHERE rowid = p_rowid
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Modificando", "cli_hayward")
         ELSE
            LET p_retorno = TRUE
         END IF
      
      ELSE
         CALL pol0001_exibe_dados() RETURNING p_status
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
 FUNCTION pol0001_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol0001_prende_registro() THEN
      DELETE FROM cli_hayward
			 WHERE rowid  = p_rowid

      IF STATUS = 0 THEN               
         INITIALIZE p_cli_hayward TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","cli_hayward")
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

{
#--------------------------#
 FUNCTION pol0001_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol0001_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol0001_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT cod_parametro,
          den_parametro,
          par_tipo,     
          par_dec,      
          par_int,      
          par_dat,      
          par_txt      
     FROM cli_hayward
 ORDER BY cod_parametro                          
  
   FOREACH cq_impressao 
      INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
   OUTPUT TO REPORT pol0001_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol0001_relat   
   
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
 FUNCTION pol0001_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0001.tmp"
         START REPORT pol0001_relat TO p_caminho
      ELSE
         START REPORT pol0001_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol0001_le_den_empresa()
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
 REPORT pol0001_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 179, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol0001",
               COLUMN 071, "PARÂMETROS PARA INTEGRAÇÃO COM SISTEMA OMC",
               COLUMN 160, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, '             PARAMETRO                                               DESCRICAO                                  TIPO     V. DECIMAL     V. INTEIRO  V. DATA             V. TEXTO'
         PRINT COLUMN 002, '---------------------------------------- ---------------------------------------------------------------------- ---- ------------------ ---------- ---------- ------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 002, p_relat.cod_parametro,
               COLUMN 043, p_relat.den_parametro,
               COLUMN 114, p_relat.par_tipo,
               COLUMN 119, p_relat.par_dec USING "############.&&&&&",
               COLUMN 138, p_relat.par_int USING "##########",
               COLUMN 149, p_relat.par_dat,
               COLUMN 160, p_relat.par_txt
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 065, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT


#-------------------------------- FIM DE PROGRAMA -----------------------------#