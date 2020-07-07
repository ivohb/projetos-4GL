#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1268                                                 #
# OBJETIVO: ROTA POR CLIENTE/FORNECEDOR                             #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 18/09/14                                                #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#
 
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro               CHAR(06),
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

DEFINE p_descricao             CHAR(36),
       p_des_rota              CHAR(20),
       p_cod_cidade            CHAR(05),
       p_cidade_rota           CHAR(05)

DEFINE p_cli_fornec        RECORD LIKE cli_fornec_455.*,
       p_cli_forneca       RECORD LIKE cli_fornec_455.*

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1268-10.02.05  "
   CALL func002_versao_prg(p_versao)
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'; LET p_user = 'admlog'; LET p_status = 0

   IF p_status = 0 THEN
      CALL pol1268_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1268_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1268") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1268 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1268_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1268_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1268_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1268_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1268_modificacao() RETURNING p_status  
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
            CALL pol1268_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1268_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1268

END FUNCTION

#---------------------------#
FUNCTION pol1268_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1268_inclusao()
#--------------------------#

   CALL pol1268_limpa_tela()
   
   INITIALIZE p_cli_fornec TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1268_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1268_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1268_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1268_insere()
#------------------------#

   INSERT INTO cli_fornec_455 VALUES (p_cli_fornec.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","cli_fornec_455")       
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1268_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_cli_fornec.*
      WITHOUT DEFAULTS

      BEFORE FIELD ies_cli_fornec

         IF p_funcao = "M" THEN
            NEXT FIELD cod_rota
         END IF

      AFTER FIELD ies_cli_fornec

         IF p_cli_fornec.ies_cli_fornec IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD ies_cli_fornec
         END IF
              
      BEFORE FIELD cod_cli_fornec

         IF p_funcao = "M" THEN
            NEXT FIELD cod_rota
         END IF
      
      AFTER FIELD cod_cli_fornec

         IF p_cli_fornec.cod_cli_fornec IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_cli_fornec   
         END IF

         CALL pol1268_le_descricao(p_cli_fornec.cod_cli_fornec)
          
         IF p_descricao IS NULL THEN 
            ERROR p_msg, ' não cadastrado.'
            NEXT FIELD cod_cli_fornec
         END IF  
         
         DISPLAY p_descricao TO descricao

         SELECT cod_cli_fornec
           FROM cli_fornec_455
          WHERE ies_cli_fornec = p_cli_fornec.ies_cli_fornec
            AND cod_cli_fornec = p_cli_fornec.cod_cli_fornec
         
         IF STATUS = 0 THEN
            ERROR 'Cliente ou fornecedor já cadastrado no pol1268.'
            NEXT FIELD cod_cli_fornec   
         END IF

      AFTER FIELD cod_rota

         IF p_cli_fornec.cod_rota IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_rota   
         END IF

         CALL pol1268_le_des_rota(p_cli_fornec.cod_rota)
          
         IF p_des_rota IS NULL THEN 
            ERROR 'Rota não cadastrada no POL1267.'
            NEXT FIELD cod_rota
         END IF  
         
         DISPLAY p_des_rota TO des_rota
         
         IF p_cidade_rota <> p_cod_cidade THEN
            ERROR 'A cidade dessa rota difere da cidade do ',p_msg
            NEXT FIELD cod_rota
         END IF                       
          
      ON KEY (control-z)
         CALL pol1268_popup()
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1268_le_descricao(p_cod)#
#-----------------------------------#
   
   DEFINE p_cod CHAR(15)
   
   IF p_cli_fornec.ies_cli_fornec = 'F' THEN
      LET p_msg = 'Fornecedor'
      SELECT raz_social,
             cod_cidade
        INTO p_descricao,
             p_cod_cidade
        FROM fornecedor
       WHERE cod_fornecedor = p_cod
   ELSE
      LET p_msg = 'Cliente'
      SELECT nom_cliente,
             cod_cidade
        INTO p_descricao,
             p_cod_cidade
        FROM clientes
       WHERE cod_cliente = p_cod
   END IF            
   
   IF STATUS <> 0 THEN 
      LET p_descricao = NULL
   END IF  

END FUNCTION

#----------------------------------#
FUNCTION pol1268_le_des_rota(p_cod)#
#----------------------------------#
   
   DEFINE p_cod CHAR(15)
   
   SELECT des_rota,
          cod_cidade
     INTO p_des_rota,
          p_cidade_rota
     FROM rota_frete_455
    WHERE cod_rota = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_des_rota = NULL
   END IF  

END FUNCTION

#-----------------------#
 FUNCTION pol1268_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_cli_fornec)
         IF p_cli_fornec.ies_cli_fornec = 'F' THEN
            LET p_codigo = sup162_popup_fornecedor()
         ELSE
            LET p_codigo = vdp372_popup_cliente()
         END IF
         
         CURRENT WINDOW IS w_pol1268
                            
         IF p_codigo IS NOT NULL THEN
            LET p_cli_fornec.cod_cli_fornec = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_cli_fornec
         END IF

      WHEN INFIELD(cod_rota)
         LET p_codigo = pol1268_sel_rota()
         CLOSE WINDOW w_pol1268a
         CURRENT WINDOW IS w_pol1268
                   
         IF p_codigo IS NOT NULL THEN
            LET p_cli_fornec.cod_rota = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_rota
         END IF

   END CASE 

END FUNCTION 

#--------------------------#
FUNCTION pol1268_sel_rota()#
#--------------------------#
   
   DEFINE pr_rota      ARRAY[1000] OF RECORD
          cod_rota     INTEGER,
          des_rota     CHAR(76)
   END RECORD
   
   DEFINE p_where, p_query CHAR(150)

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1268a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1268a AT 5,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
   
   DECLARE cq_rota CURSOR FOR 
    SELECT cod_rota, des_rota
      FROM rota_frete_455
     WHERE cod_cidade = p_cod_cidade
     ORDER BY des_rota
     
   FOREACH cq_rota INTO
      pr_rota[p_ind].cod_rota,
      pr_rota[p_ind].des_rota

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_rota')
         RETURN ""
      END IF
       
      LET p_ind = p_ind + 1
      
      IF p_ind > 1000 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassado!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
           
   END FOREACH
   
   IF p_ind = 1 THEN
      LET p_msg = 'Nenhuma rota foi cadastrada\n',
                  'no POL1267, para a cidade ', p_cod_cidade CLIPPED,
                  'do ',p_msg CLIPPED, ' ', p_cli_fornec.cod_cli_fornec
      CALL log0030_mensagem(p_msg,'excla')
      RETURN ""
   END IF
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_rota TO sr_rota.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   IF NOT INT_FLAG THEN
      RETURN pr_rota[p_ind].cod_rota
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#--------------------------#
 FUNCTION pol1268_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1268_limpa_tela()
   LET p_cli_forneca.* = p_cli_fornec.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      cli_fornec_455.ies_cli_fornec,
      cli_fornec_455.cod_cli_fornec,
      cli_fornec_455.cod_rota      

      ON KEY (control-z)
         CALL pol1268_popup()

   END CONSTRUCT
   
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1268_limpa_tela()
         ELSE
            LET p_cli_fornec.* = p_cli_forneca.*
            CALL pol1268_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM cli_fornec_455 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY ies_cli_fornec, cod_cli_fornec"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cli_fornec.*

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1268_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1268_exibe_dados()
#------------------------------#

   DEFINE p_codigo   CHAR(15),
          p_ies_cli  CHAR(01)
   
   LET p_codigo = p_cli_fornec.cod_cli_fornec
   LET p_ies_cli = p_cli_fornec.ies_cli_fornec
   
   SELECT *
     INTO p_cli_fornec.*
     FROM cli_fornec_455
    WHERE cod_cli_fornec = p_codigo
      AND ies_cli_fornec = p_ies_cli
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'cli_fornec_455')
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_cli_fornec.*
   
   CALL pol1268_le_descricao(p_codigo)
   DISPLAY p_descricao to escricao

   CALL pol1268_le_des_rota(p_cli_fornec.cod_rota)
   DISPLAY p_des_rota to des_rota
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1268_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01)

   LET p_cli_forneca.* = p_cli_fornec.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cli_fornec.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cli_fornec.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_cli_fornec
           FROM cli_fornec_455
          WHERE cod_cli_fornec = p_cli_fornec.cod_cli_fornec
            AND ies_cli_fornec = p_cli_fornec.ies_cli_fornec
            
         IF STATUS = 0 THEN
            IF pol1268_exibe_dados() THEN
               LET p_excluiu = FALSE
               EXIT WHILE
            END IF
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cli_fornec.* = p_cli_forneca.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1268_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_cli_fornec 
      FROM cli_fornec_455  
     WHERE cod_cli_fornec = p_cli_fornec.cod_cli_fornec
       AND ies_cli_fornec = p_cli_fornec.ies_cli_fornec
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","cli_fornec_455")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1268_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   LET p_cli_forneca.* = p_cli_fornec.*
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF

   LET p_opcao   = "M"
   
   IF pol1268_prende_registro() THEN
      IF pol1268_edita_dados("M") THEN
         IF pol11163_atualiza() THEN
            LET p_retorno = TRUE
         END IF
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
      LET p_cli_fornec.* = p_cli_forneca.*
      CALL pol1268_exibe_dados() RETURNING p_status
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
FUNCTION pol11163_atualiza()
#--------------------------#

   UPDATE cli_fornec_455
      SET cli_fornec_455.cod_rota = p_cli_fornec.cod_rota
    WHERE cod_cli_fornec = p_cli_fornec.cod_cli_fornec
      AND ies_cli_fornec = p_cli_fornec.ies_cli_fornec

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE", "cli_fornec_455")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1268_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1268_prende_registro() THEN
      IF pol1268_deleta() THEN
         INITIALIZE p_cli_fornec TO NULL
         CALL pol1268_limpa_tela()
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
FUNCTION pol1268_deleta()
#------------------------#

   DELETE FROM cli_fornec_455
    WHERE cod_cli_fornec = p_cli_fornec.cod_cli_fornec
      AND ies_cli_fornec = p_cli_fornec.ies_cli_fornec

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","cli_fornec_455")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1268_listagem()
#--------------------------#     

   IF NOT pol1268_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1268_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT *
      FROM cli_fornec_455 
     ORDER BY ies_cli_fornec, cod_cli_fornec
  
   FOREACH cq_impressao INTO p_cli_fornec.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
      
      CALL pol1268_le_descricao(p_cli_fornec.cod_cli_fornec)
      CALL pol1268_le_des_rota(p_cli_fornec.cod_rota)
      
      OUTPUT TO REPORT pol1268_relat() 
      
      LET p_count = 1
      
   END FOREACH

   CALL pol1268_finaliza_relat()

   RETURN
     
END FUNCTION 
      
#-------------------------------#
 FUNCTION pol1268_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1268_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1268.tmp'
         START REPORT pol1268_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1268_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1268_le_den_empresa()
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
FUNCTION pol1268_finaliza_relat()#
#--------------------------------#

   FINISH REPORT pol1268_relat   

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
 REPORT pol1268_relat()
#----------------------#
   
   DEFINE p_tipo CHAR(10)
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 116, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol1268",
               COLUMN 010, "cli_fornecS P/ CONTROLE DE FRETE",
               COLUMN 096, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, '-----------------------------------------------------------------------------------------------------------------------------'
         PRINT
         PRINT COLUMN 001, 'TIPO       CODIGO          RAZAO SOCIAL                    ROTA  DESCRICAO '
         PRINT COLUMN 001, '---------- --------------- ------------------------------ ------ ------------------------------------------------------------'

      PAGE HEADER
	  
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 116, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, '-----------------------------------------------------------------------------------------------------------------------------'
         PRINT
         PRINT COLUMN 001, 'TIPO       CODIGO          RAZAO SOCIAL                    ROTA  DESCRICAO '
         PRINT COLUMN 001, '---------- --------------- ------------------------------ ------ ------------------------------------------------------------'

      ON EVERY ROW
         
         IF p_cli_fornec.ies_cli_fornec = 'C' THEN
            LET p_tipo = 'CLIENTE'
         ELSE
            LET p_tipo = 'FORNECEDOR'
         END IF
         
         PRINT COLUMN 001, p_tipo,
               COLUMN 012, p_cli_fornec.cod_cli_fornec,
               COLUMN 028, p_descricao[1,30],
               COLUMN 059, p_cli_fornec.cod_rota USING '#####&',
               COLUMN 066, p_des_rota[1,60]
                              
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
