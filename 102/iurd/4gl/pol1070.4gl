#-------------------------------------------------------------------#
# SISTEMA.: MANUFATURA                                              #
# PROGRAMA: pol1070                                                 #
# OBJETIVO: LAY-OUT DOS ARQUIVOS DOS BANCOS                         #
# AUTOR...: WILLIANS                                                #
# DATA....: 25/08/2010                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa         LIKE empresa.cod_empresa,
          p_den_empresa         LIKE empresa.den_empresa,
          p_user                LIKE usuario.nom_usuario,
          p_status              SMALLINT,
          p_count               SMALLINT,
          p_houve_erro          SMALLINT,
          comando               CHAR(80),
          p_ies_impressao       CHAR(01),
          g_ies_ambiente        CHAR(01),
          p_versao              CHAR(18),
          p_nom_arquivo         CHAR(100),
          p_nom_tela            CHAR(200),
          p_nom_help            CHAR(200),
          p_ies_cons            SMALLINT,
          p_caminho             CHAR(080),
          p_retorno             SMALLINT,
          p_index               SMALLINT,
          s_index               SMALLINT,
          p_ind                 SMALLINT,
          s_ind                 SMALLINT,
          sql_stmt              CHAR(500),          
          where_clause          CHAR(500),          
          p_6lpp                CHAR(100),
          p_8lpp                CHAR(100),
          p_msg                 CHAR(600),
          p_last_row            SMALLINT,
          p_Comprime            CHAR(01),
          p_descomprime         CHAR(01),
          p_repetiu             SMALLINT,
          p_opcao               CHAR(01)
               
   DEFINE p_tela                RECORD 
          cod_banco             DECIMAL(3,0),
          nom_banco             CHAR(30),
          identificador         CHAR(02),
          posi_header           INTEGER,
          posi_bco_header       INTEGER
   END RECORD        
           
   DEFINE pr_campos             ARRAY[12] OF RECORD
          posicao               INTEGER,
          tamanho               INTEGER
   END RECORD
   
   DEFINE p_cod_banco           LIKE bancos.cod_banco,
          p_cod_banco_ant       LIKE bancos.cod_banco,
          p_nom_banco           LIKE bancos.nom_banco,
          p_campo               CHAR(20),
          p_posicao             INTEGER,
          p_tamanho             INTEGER   
         
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 15 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol1070-10.02.01"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1070.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL pol1070_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1070_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1070") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1070 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
         
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1070_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1070_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1070_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1070_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF  
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1070_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_tela.cod_banco TO cod_banco
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificação !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1070_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
     # COMMAND "Listar" "Listagem dos registros cadastrados."
      #   CALL pol1070_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1070_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1070

END FUNCTION

#--------------------------#
 FUNCTION pol1070_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE pr_campos TO NULL
   INITIALIZE p_tela.* TO NULL
   LET p_opcao = 'I'
   
   IF pol1070_edita_dados('I') THEN      
      IF pol1070_edita_layout() THEN      
         IF pol1070_grava_dados() THEN                                                     
            RETURN TRUE                                                                    
         END IF                                                                      
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1070_edita_dados(p_op)
#----------------------------------#
   
   DEFINE p_op CHAR(01)
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      BEFORE FIELD cod_banco
         IF p_op = 'M' THEN
            NEXT FIELD identificador
         END IF
            
      AFTER FIELD cod_banco
      IF p_tela.cod_banco IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_banco   
      END IF
                
      SELECT nom_banco
        INTO p_tela.nom_banco
        FROM bancos
       WHERE cod_banco = p_tela.cod_banco
         
      IF STATUS = 100 THEN 
         ERROR 'Banco não cadastrado no Logix !!!'
         NEXT FIELD cod_banco
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','bancos')
            RETURN FALSE
         END IF 
      END IF  
      
      DISPLAY p_tela.nom_banco TO nom_banco
      
      SELECT cod_tip_reg,
             posi_header,
             posi_bco_header
        INTO p_tela.identificador,
             p_tela.posi_header,
             p_tela.posi_bco_header
        FROM banco_265
       WHERE cod_banco = p_tela.cod_banco
       
      IF STATUS = 100 THEN
         ERROR "Banco não cadastrado para empréstimo consignado !!!"
         NEXT FIELD cod_banco
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','banco_265')
            RETURN FALSE
         END IF 
      END IF
      
      DISPLAY p_tela.identificador TO identificador
      DISPLAY p_tela.posi_header TO posi_header
      DISPLAY p_tela.posi_bco_header TO posi_header
      
      LET p_count = 0
      
      SELECT COUNT(cod_banco)
        INTO p_count
        FROM layout_265
       WHERE cod_banco = p_tela.cod_banco
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','layout_265')
         RETURN FALSE
      END IF 
  
      IF p_count > 0 THEN
         ERROR "Layout já cadastrado para esse banco !!!"
         NEXT FIELD cod_banco
      END IF
      
      AFTER FIELD identificador
         IF p_tela.identificador IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD identificador
         END IF

      AFTER FIELD posi_header
         IF p_tela.posi_header IS NULL OR
            p_tela.posi_header = 0 THEN
            ERROR 'Valor inválido para o campo !!!'
            NEXT FIELD posi_header
         END IF

      AFTER FIELD posi_bco_header
         IF p_tela.posi_bco_header IS NULL OR
            p_tela.posi_bco_header = 0 THEN
            ERROR 'Valor inválido para o campo !!!'
            NEXT FIELD posi_bco_header
         END IF
      
      ON KEY (control-z)
         CALL pol1070_popup()
           
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION pol1070_edita_layout()
#------------------------------#     
   
   INPUT ARRAY pr_campos
      WITHOUT DEFAULTS FROM sr_campos.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
      
      BEFORE FIELD posicao
         IF pr_campos[p_index].posicao IS NULL THEN
            IF p_index > 1 THEN
               LET pr_campos[p_index].posicao = pr_campos[p_index - 1].posicao + pr_campos[p_index - 1].tamanho
               IF pr_campos[p_index].posicao > 999 THEN
                  LET pr_campos[p_index].posicao = 999
               END IF
            ELSE
               LET pr_campos[p_index].posicao = 1
            END IF
            DISPLAY pr_campos[p_index].posicao TO sr_campos[s_index].posicao
         END IF
      
      AFTER FIELD posicao
         IF pr_campos[p_index].posicao IS NULL THEN
            ERROR "Campo com prenchimento obrigatório !!!"
            NEXT FIELD posicao
         END IF                                                                    
      
         IF p_index = 1 THEN                                                                                    
            IF pr_campos[p_index].posicao <= 0 THEN                                                             
               ERROR "Valor ilegal para o campo em questão !!!"                                                 
               NEXT FIELD posicao                                                                               
            END IF                                                                                              
         ELSE                                                                                                   
            IF pr_campos[p_index].posicao < pr_campos[p_index - 1].posicao + pr_campos[p_index - 1].tamanho THEN
               ERROR "Valor ilegal para o campo em questão !!!"                                                 
               NEXT FIELD posicao                                                                               
            END IF                                                                                              
         END IF                                                                                                 
                                                                                       
      AFTER FIELD tamanho         
         IF pr_campos[p_index].tamanho IS NULL THEN
            ERROR "Campo com prenchimento obrigatório !!!"
            NEXT FIELD tamanho
         END IF
         
         IF pr_campos[p_index].tamanho <= 0 THEN
            ERROR "Valor ilegal para o campo em questão !!!"
            NEXT FIELD tamanho
         END IF
   
      AFTER INPUT
         IF NOT INT_FLAG THEN
            FOR p_ind = 1 TO 12
               IF pr_campos[p_ind].posicao IS NULL OR
                  pr_campos[p_ind].tamanho IS NULL THEN
                  CALL log0030_mensagem("Prencha corretamente todos os campos !!!", "exclamation")
                  NEXT FIELD posicao
               END IF
            END FOR
                  
            FOR p_ind = 1 TO ARR_COUNT()
               IF p_ind <> 1 THEN
                  IF pr_campos[p_ind].posicao < pr_campos[p_ind - 1].posicao + pr_campos[p_ind - 1].tamanho THEN 
                     CALL log0030_mensagem("Layout com divergência nas posições dos campos !!!", "exclamation")
                     NEXT FIELD posicao
                  END IF
               END IF
            END FOR
         END IF
         
   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      CLEAR FORM 
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF   
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1070_grava_dados()
#-----------------------------#
    
   CALL log085_transacao("BEGIN")

   UPDATE banco_265 
      SET cod_tip_reg = p_tela.identificador,
          posi_header = p_tela.posi_header,
          posi_bco_header = p_tela.posi_bco_header
    WHERE cod_banco = p_tela.cod_banco

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Atualizando", "banco_265")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
    
   DELETE FROM layout_265
    WHERE cod_banco = p_tela.cod_banco
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando", "layout_265")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   FOR p_ind = 1 TO ARR_COUNT()
       
      CASE p_ind
          
         WHEN 1
            LET p_campo = "BANCO"
         WHEN 2
            LET p_campo = "CONTADOR"
         WHEN 3
            LET p_campo = "IDENTIFICADOR"
         WHEN 4
            LET p_campo = "FUNCIONARIO"
         WHEN 5
            LET p_campo = "CPF"
         WHEN 6
            LET p_campo = "DATA"
         WHEN 7
            LET p_campo = "PARCELA"
         WHEN 8
            LET p_campo = "PRAZO"
         WHEN 9
            LET p_campo = "SOLICITACAO"
         WHEN 10
            LET p_campo = "EMPRESTIMO"
         WHEN 11
            LET p_campo = "PRESTACAO"
         WHEN 12
            LET p_campo = "CONTRATO"
             
      END CASE
         
      INSERT INTO layout_265
         VALUES (p_tela.cod_banco,
                 p_campo,
 		             pr_campos[p_ind].posicao,
		             pr_campos[p_ind].tamanho)
		
		  IF STATUS <> 0 THEN 
		     CALL log003_err_sql("Incluindo", "layout_265")
		     CALL log085_transacao("ROLLBACK")
		     RETURN FALSE
		  END IF

   END FOR
         
   CALL log085_transacao("COMMIT")	      
   
   RETURN TRUE
      
END FUNCTION

#-----------------------#
 FUNCTION pol1070_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_banco)
         LET p_codigo = pol1070_le_bancos()
         IF p_codigo IS NOT NULL THEN
           LET p_tela.cod_banco = p_codigo
           DISPLAY p_codigo TO cod_banco
         END IF
   END CASE 

END FUNCTION 

#---------------------------#
 FUNCTION pol1070_le_bancos()
#---------------------------#

   DEFINE pr_bancos  ARRAY[2000] OF RECORD
          cod_banco  LIKE banco_265.cod_banco,
          nom_banco  LIKE bancos.nom_banco
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10701") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10701 AT 5,16 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
    
   DECLARE cq_bancos CURSOR FOR
   
    SELECT cod_banco
      FROM banco_265
     ORDER BY cod_banco

   FOREACH cq_bancos
      INTO pr_bancos[p_ind].cod_banco   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cursor: cq_bancos')
         EXIT FOREACH
      END IF
      
      SELECT nom_banco
        INTO pr_bancos[p_ind].nom_banco
        FROM bancos
       WHERE cod_banco = pr_bancos[p_ind].cod_banco
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','bancos')
         EXIT FOREACH
      END IF
       
      LET p_ind = p_ind + 1
      
      IF p_ind > 2000 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_bancos TO sr_bancos.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol10701
   
   IF NOT INT_FLAG THEN
      RETURN pr_bancos[p_ind].cod_banco
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#--------------------------#
 FUNCTION pol1070_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_banco_ant = p_cod_banco
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      layout_265.cod_banco
      
      ON KEY (control-z)
         CALL pol1070_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_cod_banco = p_cod_banco_ant
         CALL pol1070_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT DISTINCT cod_banco ",
                  "  FROM layout_265 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_banco"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_banco

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1070_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1070_exibe_dados()
#------------------------------#

   SELECT nom_banco
     INTO p_nom_banco
     FROM bancos
    WHERE cod_banco = p_cod_banco
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','bancos')
      RETURN FALSE 
   END IF
   
   SELECT cod_tip_reg,
          posi_header,
          posi_bco_header
     INTO p_tela.identificador,
          p_tela.posi_header,
          p_tela.posi_bco_header
     FROM banco_265
    WHERE cod_banco = p_cod_banco
    
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','banco_265')
      RETURN FALSE 
   END IF
    
   IF NOT pol1070_carrega_layout() THEN
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_index - 1)
      
   DISPLAY p_cod_banco TO cod_banco
   DISPLAY p_nom_banco TO nom_banco
   DISPLAY p_tela.identificador TO identificador
   DISPLAY p_tela.posi_header TO posi_header
   DISPLAY p_tela.posi_bco_header TO posi_bco_header
   
   INPUT ARRAY pr_campos WITHOUT DEFAULTS FROM sr_campos.*
      BEFORE INPUT
      EXIT INPUT
   END INPUT
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1070_carrega_layout()
#--------------------------------#
   
   INITIALIZE pr_campos TO NULL
   
   LET p_index = 1
      
   DECLARE cq_array CURSOR FOR
   
    SELECT campo,
           posicao,
           tamanho
      FROM layout_265
     WHERE cod_banco = p_cod_banco
     
   FOREACH cq_array
      INTO p_campo,
           p_posicao,
           p_tamanho
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo", "cursor: cq_array")
         RETURN FALSE
      END IF
        
      CASE p_campo
      
         WHEN "BANCO"
            LET pr_campos[1].posicao = p_posicao
            LET pr_campos[1].tamanho = p_tamanho
         WHEN "CONTADOR"
            LET pr_campos[2].posicao = p_posicao
            LET pr_campos[2].tamanho = p_tamanho
         WHEN "IDENTIFICADOR"
            LET pr_campos[3].posicao = p_posicao
            LET pr_campos[3].tamanho = p_tamanho
         WHEN "FUNCIONARIO"
            LET pr_campos[4].posicao = p_posicao
            LET pr_campos[4].tamanho = p_tamanho
         WHEN "CPF"
            LET pr_campos[5].posicao = p_posicao
            LET pr_campos[5].tamanho = p_tamanho
         WHEN "DATA"
            LET pr_campos[6].posicao = p_posicao
            LET pr_campos[6].tamanho = p_tamanho
         WHEN "PARCELA"
            LET pr_campos[7].posicao = p_posicao
            LET pr_campos[7].tamanho = p_tamanho
         WHEN "PRAZO"
            LET pr_campos[8].posicao = p_posicao
            LET pr_campos[8].tamanho = p_tamanho
         WHEN "SOLICITACAO"
            LET pr_campos[9].posicao = p_posicao
            LET pr_campos[9].tamanho = p_tamanho
         WHEN "EMPRESTIMO"
            LET pr_campos[10].posicao = p_posicao
            LET pr_campos[10].tamanho = p_tamanho
         WHEN "PRESTACAO"
            LET pr_campos[11].posicao = p_posicao
            LET pr_campos[11].tamanho = p_tamanho
         WHEN "CONTRATO"
            LET pr_campos[12].posicao = p_posicao
            LET pr_campos[12].tamanho = p_tamanho
      END CASE
   
      LET p_index = p_index + 1
                  
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1070_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_banco_ant = p_cod_banco

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_banco
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_banco
         
      END CASE

      IF STATUS = 0 THEN
         
         LET p_count = 0
         
         SELECT COUNT(cod_banco)
           INTO p_count
           FROM layout_265
          WHERE cod_banco  = p_cod_banco
                        
         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo", "layout_265")
         END IF
         
         IF p_count > 0 THEN   
            CALL pol1070_exibe_dados() RETURNING p_status
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
 FUNCTION pol1070_prende_registro()
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT cod_banco 
      FROM layout_265  
     WHERE cod_banco  = p_cod_banco
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","layout_265")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1070_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   LET INT_FLAG  = FALSE
   LET p_opcao   = 'M'
   LET p_tela.cod_banco = p_cod_banco
   
   IF pol1070_prende_registro() THEN
     IF pol1070_edita_dados('M') THEN    
      IF pol1070_edita_layout() THEN
         LET p_tela.cod_banco = p_cod_banco
         IF pol1070_grava_dados() THEN
            LET p_retorno = TRUE
         END IF
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
 FUNCTION pol1070_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1070_prende_registro() THEN
      DELETE FROM layout_265
			 WHERE cod_banco = p_cod_banco
         
      IF STATUS = 0 THEN               
         INITIALIZE p_cod_banco TO NULL
         INITIALIZE pr_campos TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","layout_265")
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

#-----------------------#
 FUNCTION pol1070_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


{
#--------------------------#
 FUNCTION pol1070_listagem()
#--------------------------#     

   IF NOT pol1070_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1070_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT posicao,
          tamanho
     FROM layout_265
    WHERE cod_campo = p_cod_campo
 ORDER BY cod_banco                         
  
   FOREACH cq_impressao 
      INTO p_posicao,
           p_tamanho
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      SELECT nom_banco
        INTO p_nom_banco
        FROM bancos
       WHERE cod_banco = p_cod_banco
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'bancos')
         RETURN
      END IF                                                             
                                                                                       
      DECLARE cq_listar_evento CURSOR FOR                                               
                                                                                       
       SELECT den_evento                                                         
         FROM evento                                                             
        WHERE cod_evento = p_cod_evento                        
                                                                                       
      FOREACH cq_listar_evento                                                          
         INTO p_den_evento                                     
                                                                                       
         IF STATUS <> 0 THEN                                                     
            CALL log003_err_sql('lendo','evento')                                
            RETURN FALSE                                                         
         END IF                                                                                                                           
                                                                                       
         EXIT FOREACH                                                            
                                                                                       
      END FOREACH
      
      IF p_tip_evento = '1'THEN
         LET p_den_tipo = "Desconto da parcela de empréstimo"
      ELSE
         IF p_tip_evento = '2' THEN
            LET p_den_tipo = "Desconto de rescisão"
         ELSE
            IF p_tip_evento = '3' THEN
               LET p_den_tipo = "Desconto de afastamento pelo INSS"
            ELSE
               LET p_den_tipo = "Reembolso"
            END IF
         END IF
      END IF
      
   OUTPUT TO REPORT pol1070_relat(p_cod_banco) 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1070_relat   
   
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
 FUNCTION pol1070_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1070.tmp"
         START REPORT pol1070_relat TO p_caminho
      ELSE
         START REPORT pol1070_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1070_le_den_empresa()
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
 REPORT pol1070_relat(p_cod_banco)
#--------------------------------#
    
   DEFINE p_cod_banco LIKE bancos.cod_banco
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_den_empresa, 
               COLUMN 073, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1070",
               COLUMN 013, "EVENTOS PARA EMPRESTIMOS CONSIGNADOS",
               COLUMN 053, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "---------------------------------------------------------------------------------"
         PRINT
               
      BEFORE GROUP OF p_cod_banco
         
         PRINT
         PRINT COLUMN 003, "Banco: ", p_cod_banco, " - ", p_nom_banco
         PRINT
         PRINT COLUMN 002, '       Evento      Descricao       Tipo           Descricao'
         PRINT COLUMN 002, '       ------ -------------------- ---- ---------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 010, p_cod_evento   USING "#####",
               COLUMN 016, p_den_evento,
               COLUMN 040, p_tip_evento   USING "#",
               COLUMN 042, p_den_tipo
                              
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