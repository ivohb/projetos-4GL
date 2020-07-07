#-------------------------------------------------------------------#
# SISTEMA.: CONTROLE DE ANÁLISES                                    #
# PROGRAMA: pol0491                                                 #
# MODULOS.: pol0491 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: ESPECIFICAÇÃO DAS ANÁLISES                              #
# AUTOR...: LOGOCENTER ABC - IVO                                    #
# DATA....: 01/11/2006                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_cliente        LIKE clientes.cod_cliente,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_den_empresa        CHAR(25), 
          p_retorno            SMALLINT,
          P_Comprime           CHAR(01),
          p_msg                CHAR(200),
          p_descomprime        CHAR(01),
          p_ind                SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          sql_stmt             CHAR(300),
          where_clause         CHAR(300)

    DEFINE mr_especific_comil RECORD 
           cod_empresa        LIKE especific_comil.cod_empresa,
           cod_item           LIKE especific_comil.cod_item,
           tip_analise        LIKE especific_comil.tip_analise,
           metodo             LIKE especific_comil.metodo,
           unidade            LIKE especific_comil.unidade,
           val_especif_de     LIKE especific_comil.val_especif_de,
           val_especif_ate    LIKE especific_comil.val_especif_ate,
           variacao           LIKE especific_comil.variacao,
           tipo_valor         LIKE especific_comil.tipo_valor,
           qtd_casas_dec      LIKE especific_comil.qtd_casas_dec
    END RECORD 

    DEFINE mr_especific_comilr RECORD
           cod_empresa        LIKE especific_comil.cod_empresa,
           cod_item           LIKE especific_comil.cod_item,
           tip_analise        LIKE especific_comil.tip_analise,
           metodo             LIKE especific_comil.metodo,
           unidade            LIKE especific_comil.unidade,
           val_especif_de     LIKE especific_comil.val_especif_de,
           val_especif_ate    LIKE especific_comil.val_especif_ate,
           variacao           LIKE especific_comil.variacao,
           tipo_valor         LIKE especific_comil.tipo_valor,
           qtd_casas_dec      LIKE especific_comil.qtd_casas_dec
    END RECORD 

   DEFINE pr_reult ARRAY[200] OF RECORD 
          cod_result  LIKE result_analise741.cod_result,
          den_result  LIKE result_analise741.den_result
   END RECORD

END GLOBALS


MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0491-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0491.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

#  CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0491_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0491_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0491") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0491 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0491","IN") THEN
            CALL pol0491_inclusao() RETURNING p_status
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_especific_comil.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","pol0491","MO") THEN
               CALL pol0491_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_especific_comil.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","pol0491","EX") THEN
               CALL pol0491_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0491","CO") THEN
            CALL pol0491_consulta()
            IF p_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0491_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0491_paginacao("ANTERIOR") 
      COMMAND "Listar" "Lista os Dados do Cadastro"
         HELP 003
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0491","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0491_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0491.tmp'
                     START REPORT pol0491_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0491_relat TO p_nom_arquivo
               END IF
               CALL pol0491_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0491_relat   
            ELSE
               CONTINUE MENU
            END IF                                                     
            IF p_ies_impressao = "S" THEN
               MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
               IF g_ies_ambiente = "W" THEN
                  LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                p_nom_arquivo
                  RUN comando
               END IF
            ELSE
               MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                  " " ATTRIBUTE(REVERSE)
            END IF                              
            NEXT OPTION "Fim"
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0491_sobre() 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	 			CALL pol0491_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0491

END FUNCTION

#-----------------------#
FUNCTION pol0491_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX Totvs 05.10 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
 FUNCTION pol0491_inclusao()
#--------------------------#

   INITIALIZE mr_especific_comil.* TO NULL
   LET p_houve_erro = FALSE
   CLEAR FORM
   IF pol0491_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      LET mr_especific_comil.cod_empresa = p_cod_empresa
      WHENEVER ERROR CONTINUE
      INSERT INTO especific_comil VALUES (mr_especific_comil.cod_empresa,
                                           mr_especific_comil.cod_item,
                                           mr_especific_comil.tip_analise,
                                           mr_especific_comil.metodo,
                                           mr_especific_comil.unidade,
                                           mr_especific_comil.val_especif_de,
                                           mr_especific_comil.val_especif_ate,
                                           mr_especific_comil.variacao,
                                           mr_especific_comil.tipo_valor,
                                           mr_especific_comil.qtd_casas_dec)
      WHENEVER ERROR STOP 
      IF SQLCA.SQLCODE <> 0 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","ESPECIFIC_comil")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
   ELSE
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0491_entrada_dados(p_funcao)
#---------------------------------------#
   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0491
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE mr_especific_comil.* TO NULL
   END IF

   LET mr_especific_comil.cod_empresa = p_cod_empresa
   DISPLAY BY NAME mr_especific_comil.cod_empresa
   
   INPUT BY NAME mr_especific_comil.*
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_item
         IF p_funcao = "MODIFICACAO" THEN
            NEXT FIELD metodo
         END IF  
      
      AFTER FIELD cod_item
         IF mr_especific_comil.cod_item IS NOT NULL AND
            mr_especific_comil.cod_item <> ' ' THEN
            IF pol0491_verifica_item() = FALSE THEN
               ERROR 'Item não cadastrado.'
               NEXT FIELD cod_item
            END IF 
         ELSE
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD cod_item
            END IF
         END IF  

      BEFORE FIELD tip_analise
         IF p_funcao = "MODIFICACAO" THEN 
            NEXT FIELD metodo
         END IF

      AFTER FIELD tip_analise  
         IF mr_especific_comil.tip_analise IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD tip_analise  
         ELSE
            IF pol0491_verifica_tip_analise() = FALSE THEN
               ERROR "Tipo de análise não Cadastrada."
               NEXT FIELD tip_analise
            ELSE
               IF pol0491_verifica_duplicidade() THEN
                  ERROR 'Registro já cadastrado.'
                  NEXT FIELD cod_item
               END IF  
            END IF
         END IF
      
      AFTER FIELD val_especif_de 
         IF mr_especific_comil.val_especif_de IS NULL OR      
            mr_especific_comil.val_especif_de = ' ' THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD val_especif_de
         END IF

      BEFORE FIELD val_especif_ate
         IF mr_especific_comil.val_especif_ate IS NULL OR      
            mr_especific_comil.val_especif_ate = ' ' THEN
            LET mr_especific_comil.val_especif_ate = 
                mr_especific_comil.val_especif_de 
            DISPLAY BY NAME mr_especific_comil.val_especif_ate
         END IF

      AFTER FIELD val_especif_ate 
         IF mr_especific_comil.val_especif_ate IS NULL OR      
            mr_especific_comil.val_especif_ate = ' ' THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD val_especif_ate
         ELSE
            IF mr_especific_comil.val_especif_de >
               mr_especific_comil.val_especif_ate THEN
               ERROR 'Valor final não pode ser Menor que o valor inicial.'
               NEXT FIELD val_especif_de
            END IF
         END IF

      BEFORE FIELD variacao
         IF mr_especific_comil.val_especif_de <> 
            mr_especific_comil.val_especif_ate THEN
            LET mr_especific_comil.variacao = 0 
            DISPLAY BY NAME mr_especific_comil.variacao
            IF FGL_LASTKEY() = FGL_KEYVAL("UP") THEN
               NEXT FIELD val_especif_ate
            ELSE
               NEXT FIELD tipo_valor
            END IF
         END IF

      AFTER FIELD variacao
         IF mr_especific_comil.variacao IS NULL THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD variacao
         END IF 
     
      BEFORE FIELD tipo_valor
         IF mr_especific_comil.val_especif_de <>
            mr_especific_comil.val_especif_ate THEN
            IF FGL_LASTKEY() = FGL_KEYVAL("UP") THEN
               NEXT FIELD variacao
            ELSE
               NEXT FIELD qtd_casas_dec
            END IF
         END IF
         IF mr_especific_comil.variacao IS NOT NULL AND
            mr_especific_comil.variacao <> '0' THEN
            LET mr_especific_comil.tipo_valor = ' ' 
            DISPLAY BY NAME mr_especific_comil.tipo_valor
            IF FGL_LASTKEY() = FGL_KEYVAL("UP") THEN
               NEXT FIELD variacao
            ELSE
               NEXT FIELD qtd_casas_dec
            END IF
         END IF   

      AFTER FIELD tipo_valor
         IF mr_especific_comil.tipo_valor IS NOT NULL AND
            mr_especific_comil.tipo_valor <> ' ' THEN
            IF mr_especific_comil.tipo_valor <> '<' AND
               mr_especific_comil.tipo_valor <> '>' AND
               mr_especific_comil.tipo_valor <> '<=' AND
               mr_especific_comil.tipo_valor <> '>=' AND
               mr_especific_comil.tipo_valor <> '<>' THEN
               ERROR 'Valor inválido.'
               NEXT FIELD tipo_valor
            END IF 
         END IF 
 
      AFTER FIELD qtd_casas_dec 
         IF mr_especific_comil.qtd_casas_dec IS NULL OR
            mr_especific_comil.qtd_casas_dec = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD qtd_casas_dec 
            END IF
         END IF
      
      ON KEY(control-z)
         CALL pol0491_popup()
 
      AFTER INPUT
         IF INT_FLAG = 0 THEN
            IF mr_especific_comil.cod_item IS NULL THEN
               ERROR "Campo de preenchimento obrigatório."
               NEXT FIELD cod_item
            END IF 
            IF mr_especific_comil.tip_analise IS NULL THEN
               ERROR "Campo de preenchimento obrigatório."
               NEXT FIELD tip_analise
            END IF 
         END IF 
 
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0491
   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION pol0491_verifica_item()
#-------------------------------#

   DEFINE l_den_item  LIKE item_comil.den_item_comil

   SELECT den_item
     INTO l_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_especific_comil.cod_item

   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_item to den_item
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF  

END FUNCTION

#--------------------------------------#
 FUNCTION pol0491_verifica_tip_analise()
#--------------------------------------#

    DEFINE l_den_analise        LIKE it_analise_comil.den_analise

    SELECT den_analise
      INTO l_den_analise 
      FROM it_analise_comil
     WHERE cod_empresa = p_cod_empresa  
       AND tip_analise = mr_especific_comil.tip_analise

    IF sqlca.sqlcode = 0 THEN
       DISPLAY l_den_analise to den_analise
       RETURN TRUE
    ELSE
       RETURN FALSE
    END IF

END FUNCTION

#--------------------------------------#
 FUNCTION pol0491_verifica_duplicidade()
#--------------------------------------#

   SELECT cod_empresa
     FROM especific_comil
    WHERE cod_empresa  = p_cod_empresa
      AND cod_item     = mr_especific_comil.cod_item
      AND tip_analise  = mr_especific_comil.tip_analise

   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF  

END FUNCTION

#-----------------------#
 FUNCTION pol0491_popup()
#-----------------------#
   CASE

      WHEN infield(cod_item)
         LET mr_especific_comil.cod_item = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0491
         DISPLAY mr_especific_comil.cod_item  TO cod_item

      WHEN INFIELD(tip_analise)
         CALL log009_popup(9,13,"TIPO ANÁLISE","it_analise_comil",
                                "tip_analise","den_analise","POL0312","S","")
            RETURNING mr_especific_comil.tip_analise 
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0491
         DISPLAY mr_especific_comil.tip_analise TO tip_analise

      WHEN INFIELD(val_especif_de)
         IF NOT pol0491_tem_txt() THEN
            RETURN
         END IF
         LET mr_especific_comil.val_especif_de = pol0491_result_anal()
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol0491
         DISPLAY mr_especific_comil.val_especif_de TO val_especif_de
         
         
      WHEN INFIELD(val_especif_ate)
         IF NOT pol0491_tem_txt() THEN
            RETURN
         END IF
         LET mr_especific_comil.val_especif_ate = pol0491_result_anal()
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol0491
         DISPLAY mr_especific_comil.val_especif_ate TO val_especif_ate

   END CASE

END FUNCTION

#-------------------------#
FUNCTION pol0491_tem_txt()
#-------------------------#

   SELECT COUNT(tip_analise)
     INTO p_count
     FROM result_analise741
    WHERE cod_empresa = p_cod_empresa
      AND tip_analise = mr_especific_comil.tip_analise
         
   IF p_count > 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0491_result_anal()
#-----------------------------#

   DEFINE p_den_analise LIKE it_analise_comil.den_analise

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04911") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol04911 AT 6,20 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   SELECT den_analise
     INTO p_den_analise
     FROM it_analise_comil
    WHERE cod_empresa = p_cod_empresa
      AND tip_analise = mr_especific_comil.tip_analise
      
   DISPLAY p_den_analise TO den_analise

   LET p_index = 1
   
   DECLARE cq_result CURSOR FOR
    SELECT cod_result,
           den_result
      FROM result_analise741
     WHERE cod_empresa = p_cod_empresa
       AND tip_analise = mr_especific_comil.tip_analise
     ORDER BY cod_result
     
   FOREACH cq_result INTO pr_reult[p_index].*
      LET p_index = p_index + 1
   END FOREACH

   CALL SET_COUNT(p_index - 1)
   
   DISPLAY ARRAY pr_reult TO sr_reult.*

      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE()

   CLOSE WINDOW w_pol04911
   
   RETURN pr_reult[p_index].cod_result

END FUNCTION


#--------------------------#
 FUNCTION pol0491_consulta()
#--------------------------#
   DEFINE sql_stmt           CHAR(500), 
          where_clause       CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON especific_comil.cod_item,
                                     especific_comil.tip_analise,
                                     especific_comil.metodo,   
                                     especific_comil.qtd_casas_dec,   
                                     especific_comil.unidade,  
                                     especific_comil.val_especif_de,
                                     especific_comil.val_especif_ate,
                                     especific_comil.variacao,       
                                     especific_comil.tipo_valor     

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0491

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET mr_especific_comil.* = mr_especific_comilr.*
      CALL pol0491_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM especific_comil ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'", 
                  " AND ",where_clause CLIPPED,                 
                  " ORDER BY cod_item, tip_analise "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_especific_comil.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0491_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0491_exibe_dados()
#-----------------------------#

   DISPLAY BY NAME mr_especific_comil.*
   CALL pol0491_verifica_item() RETURNING p_status
   CALL pol0491_verifica_tip_analise() RETURNING p_status 

END FUNCTION

#-----------------------------------#
 FUNCTION pol0491_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET mr_especific_comilr.* = mr_especific_comil.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            mr_especific_comil.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            mr_especific_comil.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem mais Registros nesta Direcao"
            LET mr_especific_comil.* = mr_especific_comilr.* 
            EXIT WHILE
         END IF
       
         SELECT *
           INTO mr_especific_comil.* 
           FROM especific_comil   
          WHERE cod_empresa = mr_especific_comil.cod_empresa
            AND cod_item    = mr_especific_comil.cod_item
            AND tip_analise = mr_especific_comil.tip_analise

         IF SQLCA.SQLCODE = 0 THEN 
            CALL pol0491_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION pol0491_cursor_for_update()
#-----------------------------------#
   WHENEVER ERROR CONTINUE
    DECLARE cm_padrao CURSOR FOR 
     SELECT *                            
       FROM especific_comil  
      WHERE cod_empresa  = mr_especific_comil.cod_empresa
        AND cod_item     = mr_especific_comil.cod_item  
        AND tip_analise  = mr_especific_comil.tip_analise
        FOR UPDATE 

   CALL log085_transacao("BEGIN")
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","ESPECIFIC_comil")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0491_modificacao()
#-----------------------------#

   IF pol0491_cursor_for_update() THEN
      LET mr_especific_comilr.* = mr_especific_comil.*
      IF pol0491_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE especific_comil
            SET tip_analise     = mr_especific_comil.tip_analise,
                metodo          = mr_especific_comil.metodo,
                unidade         = mr_especific_comil.unidade,
                val_especif_de  = mr_especific_comil.val_especif_de,
                val_especif_ate = mr_especific_comil.val_especif_ate,
                variacao        = mr_especific_comil.variacao,
                tipo_valor      = mr_especific_comil.tipo_valor,
                qtd_casas_dec   = mr_especific_comil.qtd_casas_dec
         WHERE CURRENT OF cm_padrao

         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         ELSE
            CALL log003_err_sql("EFET-COMMIT-ALT","ESPECIFIC_comil")
            CALL log085_transacao("ROLLBACK")
         END IF
      ELSE
         LET mr_especific_comil.* = mr_especific_comilr.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK")
         DISPLAY BY NAME mr_especific_comil.tip_analise
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0491_exclusao()
#--------------------------#
   IF pol0491_cursor_for_update() THEN
      IF log004_confirm(13,42) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM especific_comil 
          WHERE cod_empresa  = mr_especific_comil.cod_empresa
            AND cod_item     = mr_especific_comil.cod_item  
            AND tip_analise  = mr_especific_comil.tip_analise

         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE mr_especific_comil.* TO NULL
            CLEAR FORM
         ELSE
            CALL log003_err_sql("EXCLUSAO","ESPECIFIC_comil")
            CALL log085_transacao("ROLLBACK")
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0491_emite_relatorio()
#-----------------------------------#

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18

   SELECT den_empresa INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_listar CURSOR FOR
     SELECT *
       FROM especific_comil
      WHERE cod_empresa = p_cod_empresa
      ORDER BY cod_item
     
   FOREACH cq_listar INTO mr_especific_comil.*

      OUTPUT TO REPORT pol0491_relat() 
 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#----------------------#
 REPORT pol0491_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_comprime, p_den_empresa,
               COLUMN 100, "PAG.: ", PAGENO USING "##&"
         PRINT COLUMN 001, "POL0491",
               COLUMN 037, "ESPECIFICACOES DAS ANALISES",
               COLUMN 082, "DATA: ", TODAY USING "DD/MM/YYYY", ' - ', TIME
         PRINT COLUMN 001, '------------------------------------------------------------------------------------------------------------'
                           
                           

         PRINT

         PRINT COLUMN 001, 'ITEM            ANALISE       METODO            UNIDADE      ESPECIF DE ESPEC ATE   VARIACAO  TP CASAS DEC'
         PRINT COLUMN 001, '--------------- ------- -------------------- --------------- ---------- ---------- ---------- -- -----------'
         PRINT
                           
      ON EVERY ROW
         
         PRINT COLUMN 001, mr_especific_comil.cod_item,
               COLUMN 017, mr_especific_comil.tip_analise USING '######',
               COLUMN 025, mr_especific_comil.metodo,
               COLUMN 046, mr_especific_comil.unidade,
               COLUMN 062, mr_especific_comil.val_especif_de USING '####&.&&&&',
               COLUMN 073, mr_especific_comil.val_especif_ate USING '####&.&&&&',
               COLUMN 084, mr_especific_comil.variacao USING '####&.&&&&',
               COLUMN 095, mr_especific_comil.tipo_valor,
               COLUMN 098, mr_especific_comil.qtd_casas_dec

      ON LAST ROW

         PRINT COLUMN 001, p_descomprime
            
END REPORT


#-----------------------#
 FUNCTION pol0491_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------- FIM DE PROGRAMA --------------------------------#
