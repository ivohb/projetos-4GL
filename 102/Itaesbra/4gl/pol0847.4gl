#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0847                                                 #
# OBJETIVO: CADASTRO DE PEÇAS POR CICLO E CICLO POR PEÇAS           #
# AUTOR...: IVO HONÓRIO BARBOSA                                     #
# DATA....: 23/09/2008                                              #
# ALTERADO: 23/06/2009 -thiago- Foi adicionado dois novos campos na	#
#						tabela ciclo_peca_970, os campos  num_seq,num_sub_seq		#
#						foi modificado AS telas AS query e adicionada novas 		#
#						variaveis aos arranjos																	#
#						14/10/2009 - adicinado campo peça horas custo		-Thiago	#
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_exportar           CHAR(01),
          p_erro_critico       SMALLINT,
          p_last_row           SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_6lpp               CHAR(02),
          p_8lpp               CHAR(02),
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
          p_msg                CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080)
          
   DEFINE p_ciclo_peca_970     RECORD LIKE ciclo_peca_970.*,
          p_ciclo_peca_970a    RECORD LIKE ciclo_peca_970.* 

   DEFINE p_den_item           LIKE item.den_item,
          p_cod_item           LIKE item.cod_item,
          p_cod_itema          LIKE item.cod_item

   DEFINE pr_item              ARRAY[10000] OF RECORD          
          cod_item             LIKE item.cod_item,
          den_item             LIKE item.den_item_reduz,
          qtd_ciclo_peca       LIKE ciclo_peca_970.qtd_ciclo_peca,
          qtd_peca_ciclo       LIKE ciclo_peca_970.qtd_peca_ciclo,
          num_seq							 LIKE ciclo_peca_970.num_seq,
          num_sub_seq					 LIKE ciclo_peca_970.num_sub_seq,
          qtd_peca_emb				 LIKE ciclo_peca_970.qtd_peca_emb,
          qtd_peca_hor				 LIKE ciclo_peca_970.qtd_peca_hor,
          fator_mo             LIKE ciclo_peca_970.fator_mo
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0847-10.02.04"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0847.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0847_carrega_da_consumo()
      CALL pol0847_controle()
   END IF
END MAIN

#-----------------------------------#
FUNCTION pol0847_carrega_da_consumo()
#-----------------------------------#

   MESSAGE 'Aguarde !!!... carregando itens.'

   INITIALIZE pr_item TO NULL
   LET p_index = 1
   
   DECLARE cq_con CURSOR FOR 
    SELECT UNIQUE cod_item
      FROM consumo
     WHERE cod_empresa = p_cod_empresa
       AND cod_item NOT IN
           (SELECT cod_item 
              FROM ciclo_peca_970 
             WHERE cod_empresa = p_cod_empresa)
     ORDER BY cod_item
     
   FOREACH cq_con INTO
           pr_item[p_index].cod_item
           
      LET pr_item[p_index].qtd_ciclo_peca = 1
      
      LET pr_item[p_index].qtd_peca_ciclo = 1
   		LET pr_item[p_index].num_seq        = 1
   		LET pr_item[p_index].num_sub_seq    = 1
   		LET pr_item[p_index].qtd_peca_emb   = 1
   		LET pr_item[p_index].qtd_peca_hor   = 1
   		LET pr_item[p_index].fator_mo       = 0
   		
      SELECT den_item_reduz
        INTO pr_item[p_index].den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = pr_item[p_index].cod_item
         
      IF STATUS <> 0 THEN
         LET pr_item[p_index].den_item = 'Item Inexistente'
      END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 10000 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassado','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF p_index = 1 THEN
      RETURN
   END IF
   
   MESSAGE ''
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol08471") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol08471 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DISPLAY p_cod_empresa TO cod_empresa   
   
   LET INT_FLAG = FALSE
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_item WITHOUT DEFAULTS FROM sr_item.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
           
      AFTER FIELD qtd_ciclo_peca
         IF pr_item[p_index].qtd_ciclo_peca IS NULL THEN
            ERROR 'campo com preenchimento obrigatório'
            NEXT FIELD qtd_ciclo_peca
         END IF

      AFTER FIELD qtd_peca_ciclo
         IF pr_item[p_index].qtd_peca_ciclo IS NULL THEN
            ERROR 'campo com preenchimento obrigatório'
            NEXT FIELD qtd_peca_ciclo
         END IF
         
      AFTER FIELD num_seq
         IF pr_item[p_index].num_seq IS NULL THEN
            ERROR 'campo com preenchimento obrigatório'
            NEXT FIELD num_seq
         END IF
         
      AFTER FIELD num_sub_seq
         IF pr_item[p_index].num_sub_seq IS NULL THEN
            ERROR 'campo com preenchimento obrigatório'
            NEXT FIELD num_sub_seq
         END IF
         
      AFTER FIELD fator_mo
         IF pr_item[p_index].fator_mo IS NULL THEN
            ERROR 'campo com preenchimento obrigatório'
            NEXT FIELD fator_mo
         END IF
         
         IF pr_item[p_index].fator_mo < 0 THEN
            ERROR 'Valor ilegal para o campo em questão !!!'
            NEXT FIELD fator_mo
         END IF 
         
   END INPUT

   IF INT_FLAG THEN
      CALL log0030_mensagem('Operação cancelada','Excla')
   ELSE
      CALL log085_transacao("BEGIN")
      IF NOT pol0778_grava_itens() THEN
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         CALL log0030_mensagem('Operação efetuada com sucesso','Excla')
      END IF
   END IF
   
   CLOSE WINDOW w_pol08471
   
END FUNCTION 

#-----------------------------#
FUNCTION pol0778_grava_itens()
#-----------------------------#

   MESSAGE 'Aguarde !!!... gravando itens.'

   FOR p_index = 1 TO ARR_COUNT()
       IF pr_item[p_index].cod_item IS NOT NULL THEN
          INSERT INTO ciclo_peca_970
           VALUES(p_cod_empresa,
                  pr_item[p_index].cod_item,
                  pr_item[p_index].qtd_ciclo_peca,
                  pr_item[p_index].qtd_peca_ciclo,
                  pr_item[p_index].num_seq,
                  pr_item[p_index].num_sub_seq,
                  pr_item[p_index].qtd_peca_emb,
                  pr_item[p_index].qtd_peca_hor,
                  pr_item[p_index].fator_mo,'','')
          IF STATUS <> 0 THEN
             CALL log003_err_sql('inserindo','ciclo_peca_970')
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
 FUNCTION pol0847_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0847") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0847 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         CALL pol0847_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         IF p_ies_cons THEN
            CALL pol0847_modificacao() RETURNING p_status
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         IF p_ies_cons THEN
            CALL pol0847_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         CALL pol0847_consulta()
         IF p_ies_cons THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         IF p_ies_cons THEN
            CALL pol0847_paginacao("S")
         ELSE
            ERROR "Nao Existe Nenhuma Consulta Ativa"
         END IF
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         IF p_ies_cons THEN
            CALL pol0847_paginacao("A")
         ELSE
            ERROR "Nao Existe Nenhuma Consulta Ativa"
         END IF
      COMMAND "Listar" "Listagem dos parâmetros"
         CALL pol0847_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol0847_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         PROMPT "Exportar peças ega? : " FOR p_exportar
         IF p_exportar = 'S' OR p_exportar = 's' THEN
            CALL log120_procura_caminho("pol0857") RETURNING comando
            LET comando = comando 
            RUN comando RETURNING p_status   
         END IF
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0847

END FUNCTION


#--------------------------#
 FUNCTION pol0847_inclusao()
#--------------------------#

   INITIALIZE p_ciclo_peca_970.* TO NULL
   LET p_ciclo_peca_970.cod_empresa = p_cod_empresa

   IF pol0847_entrada_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO ciclo_peca_970 VALUES (p_ciclo_peca_970.*)
      IF SQLCA.SQLCODE <> 0 THEN 
      	 CALL log003_err_sql("INCLUSAO","p_ciclo_peca_970")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF

   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0847_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE

   INPUT BY NAME p_ciclo_peca_970.* WITHOUT DEFAULTS
   
      BEFORE FIELD cod_item
      IF p_funcao = 'M' THEN
         NEXT FIELD qtd_ciclo_peca
      END IF
      
      AFTER FIELD cod_item
         IF p_ciclo_peca_970.cod_item IS NULL THEN
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_item   
         END IF
         
         LET p_cod_item = p_ciclo_peca_970.cod_item
         
         CALL pol0847_le_item() RETURNING p_msg
         
         IF p_msg IS NOT NULL THEN
            CALL log0030_mensagem(p_msg,'exclamation')
            NEXT FIELD cod_item
         END IF
         
         DISPLAY p_den_item TO den_item
         
         CALL pol0847_le_ciclo_peca()

         IF STATUS <> 100 THEN
            IF STATUS = 0 THEN
               DISPLAY BY NAME p_ciclo_peca_970.*
               LET p_msg = 'Ciclo/peça já cadastrado para esse item'
            ELSE
               LET p_msg = 'Erro (',STATUS,') Lendo tabela ciclo_peca_970'
            END IF
            CALL log0030_mensagem(p_msg,'exclamation')
            NEXT FIELD cod_item
         END IF

      AFTER FIELD qtd_ciclo_peca
         IF p_ciclo_peca_970.qtd_ciclo_peca IS NULL THEN
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD qtd_ciclo_peca   
         END IF
      
      AFTER FIELD qtd_peca_ciclo
         IF p_ciclo_peca_970.qtd_peca_ciclo IS NULL THEN
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD qtd_peca_ciclo   
         END IF
      AFTER FIELD num_seq
         IF p_ciclo_peca_970.num_seq IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório'
            NEXT FIELD num_seq
         END IF
         
      AFTER FIELD num_sub_seq
         IF p_ciclo_peca_970.num_sub_seq IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório'
            NEXT FIELD num_sub_seq
         END IF
     AFTER FIELD qtd_peca_emb
         IF p_ciclo_peca_970.qtd_peca_emb IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório'
            NEXT FIELD qtd_peca_emb
         END IF
      AFTER FIELD qtd_peca_hor
         IF p_ciclo_peca_970.qtd_peca_hor IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório'
            NEXT FIELD qtd_peca_hor
         END IF
      
      AFTER FIELD fator_mo
         IF p_ciclo_peca_970.fator_mo IS NULL THEN
            ERROR 'campo com preenchimento obrigatório'
            NEXT FIELD fator_mo
         END IF
         
         IF p_ciclo_peca_970.fator_mo < 0 THEN
            ERROR 'Valor ilegal para o campo em questão !!!'
            NEXT FIELD fator_mo
         END IF
      
      ON KEY (control-z)
         CALL pol0847_popup()

   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#-------------------------#
FUNCTION pol0847_le_item()
#-------------------------#

   DEFINE p_erro CHAR(70)

   INITIALIZE p_den_item, p_erro TO NULL
   
   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_ciclo_peca_970.cod_item

   IF STATUS = 100 THEN
      LET p_erro = 'Item não cadastrado'
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = 'Erro (',STATUS,') Lendo tabela item'
      END IF
   END IF

   RETURN(p_erro)
   
END FUNCTION

#------------------------------#
FUNCTION pol0847_le_ciclo_peca()
#------------------------------#

   SELECT qtd_ciclo_peca,
          qtd_peca_ciclo,
          num_seq,
          num_sub_seq,
          qtd_peca_emb,
          qtd_peca_hor,
          fator_mo,
          cod_item_cliente,
          passo
     INTO p_ciclo_peca_970.qtd_ciclo_peca,
          p_ciclo_peca_970.qtd_peca_ciclo,
          p_ciclo_peca_970.num_seq,
          p_ciclo_peca_970.num_sub_seq,
          p_ciclo_peca_970.qtd_peca_emb,
          p_ciclo_peca_970.qtd_peca_hor,
          p_ciclo_peca_970.fator_mo,
          p_ciclo_peca_970.cod_item_cliente,
          p_ciclo_peca_970.passo
     FROM ciclo_peca_970
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

END FUNCTION


#-----------------------#
FUNCTION pol0847_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0847
         IF p_codigo IS NOT NULL THEN
           LET p_ciclo_peca_970.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF
     
   END CASE

END FUNCTION 


#--------------------------#
 FUNCTION pol0847_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_itema = p_cod_item
   
   CONSTRUCT BY NAME where_clause ON 
      ciclo_peca_970.cod_item,
      ciclo_peca_970.qtd_ciclo_peca,
      ciclo_peca_970.qtd_peca_ciclo,
      ciclo_peca_970.num_seq,
      ciclo_peca_970.num_sub_seq,
      ciclo_peca_970.qtd_peca_emb,
      ciclo_peca_970.qtd_peca_hor,
      ciclo_peca_970.fator_mo,
      ciclo_peca_970.cod_item_cliente

   IF INT_FLAG THEN
      IF p_ies_cons THEN
         LET p_cod_item = p_cod_itema
         CALL pol0847_exibe_dados()
      END IF
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT cod_item ",
                  "  FROM ciclo_peca_970 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_item"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_item

   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0847_exibe_dados()
   END IF
   
   RETURN

END FUNCTION

#------------------------------#
 FUNCTION pol0847_exibe_dados()
#------------------------------#

   CALL pol0847_le_ciclo_peca()
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','tab:ciclo_peca_970')
   END IF

   LET p_ciclo_peca_970.cod_item = p_cod_item
   
   CALL pol0847_le_item() RETURNING p_msg
   
   IF p_msg IS NOT NULL THEN
      LET p_den_item = p_msg
   END IF
   
   DISPLAY BY NAME p_ciclo_peca_970.*
   
   DISPLAY p_den_item TO den_item

END FUNCTION

#-----------------------------------#
 FUNCTION pol0847_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_itema = p_cod_item

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_item
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_item
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_item
           FROM ciclo_peca_970
          WHERE cod_item = p_cod_item
            AND cod_empresa = p_cod_empresa
            
         IF STATUS = 0 THEN
            CALL pol0847_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_item = p_cod_itema
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION


#----------------------------------#
 FUNCTION pol0847_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")
   DECLARE cq_prende CURSOR FOR
   SELECT cod_empresa 
     FROM ciclo_peca_970  
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
      FOR UPDATE 
   
   OPEN cq_prende
   FETCH cq_prende
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","ciclo_peca_970")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0847_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0847_prende_registro() THEN
      IF pol0847_entrada_dados("M") THEN
         UPDATE ciclo_peca_970 
            SET qtd_ciclo_peca = p_ciclo_peca_970.qtd_ciclo_peca,
                qtd_peca_ciclo = p_ciclo_peca_970.qtd_peca_ciclo,
                num_seq        = p_ciclo_peca_970.num_seq,
          			num_sub_seq    = p_ciclo_peca_970.num_sub_seq,
          			qtd_peca_emb	 = p_ciclo_peca_970.qtd_peca_emb,
          			qtd_peca_hor	 = p_ciclo_peca_970.qtd_peca_hor,
          			fator_mo       = p_ciclo_peca_970.fator_mo,
          			cod_item_cliente = p_ciclo_peca_970.cod_item_cliente,
          			passo            = p_ciclo_peca_970.passo
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_item

         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificando","ciclo_peca_970")
         END IF
      ELSE
         CALL pol0847_exibe_dados()
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
 FUNCTION pol0847_exclusao()
#--------------------------#

   LET p_retorno = FALSE

   IF pol0847_prende_registro() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM ciclo_peca_970
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_item

         IF STATUS = 0 THEN
            INITIALIZE p_ciclo_peca_970 TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Excluindo","ciclo_peca_970")
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
FUNCTION pol0847_listagem()
#--------------------------#

   CALL pol0847_escolhe_saida()

   IF NOT pol0847_le_empresa() THEN
      RETURN FALSE
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_imp CURSOR FOR
    SELECT cod_item,
           qtd_ciclo_peca,
           qtd_peca_ciclo,
           num_seq,
           num_sub_seq,
           qtd_peca_emb,
           qtd_peca_hor,
           fator_mo
      FROM ciclo_peca_970
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_item
   
   FOREACH cq_imp INTO 
           p_ciclo_peca_970.cod_item,
           p_ciclo_peca_970.qtd_ciclo_peca,
           p_ciclo_peca_970.qtd_peca_ciclo,
           p_ciclo_peca_970.num_seq,
           p_ciclo_peca_970.num_sub_seq,
           p_ciclo_peca_970.qtd_peca_emb,
           p_ciclo_peca_970.qtd_peca_hor,
           p_ciclo_peca_970.fator_mo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ciclo_peca_970:cq_imp')
         EXIT FOREACH
      END IF

      CALL pol0847_le_item() RETURNING p_msg
      
      IF p_msg IS NOT NULL THEN
         LET p_den_item = p_msg
      END IF
      
      OUTPUT TO REPORT pol0847_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol0847_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados para serem listados. "
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
      ERROR 'Relatório gerado com sucesso!!!'
   END IF
  
END FUNCTION 

#-------------------------------#
FUNCTION pol0847_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0847.tmp"
         START REPORT pol0847_relat TO p_caminho
      ELSE
         START REPORT pol0847_relat TO p_nom_arquivo
      END IF
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol0847_le_empresa()
#----------------------------#

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
 REPORT pol0847_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_comprime, p_den_empresa,  
               COLUMN 087, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol0847",
               COLUMN 024, "CICLOS POR PECA / PECA POR CICLO",
               COLUMN 068, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "-------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '   COD ITEM              DESCRICAO              CICLO/PC PC/CICLO SEQ SUB/SEQ PC/EMB PC/HR FAT/MO'
         PRINT COLUMN 001, '--------------- ------------------------------- -------- -------- --- ------- ------ ----- ------'
      
      ON EVERY ROW

         PRINT COLUMN 001, p_ciclo_peca_970.cod_item,
               COLUMN 017, p_den_item[1,31],
               COLUMN 051, p_ciclo_peca_970.qtd_ciclo_peca USING '######&',
               COLUMN 060, p_ciclo_peca_970.qtd_peca_ciclo USING '######&',
               COLUMN 067, p_ciclo_peca_970.num_seq        USING '##&',
         			 COLUMN 073, p_ciclo_peca_970.num_sub_seq    USING '##&',
         			 COLUMN 077, p_ciclo_peca_970.qtd_peca_emb   USING '######&',
         			 COLUMN 081, p_ciclo_peca_970.qtd_peca_hor   USING '######&',
         			 COLUMN 093, p_ciclo_peca_970.fator_mo       USING '#&.&&'         


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
 FUNCTION pol0847_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#