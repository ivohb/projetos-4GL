#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0482                                                 #
# MODULOS.: pol0482-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: INCLUSÃO DE FRETE POR ITEM                              #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 10/09/2006                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_num_pedido         LIKE frete_unit_kana.num_pedido,
          p_cod_cliente        LIKE clientes.cod_cliente,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_pre_unit           LIKE ped_itens.pre_unit,
          p_val_item           LIKE ped_itens.pre_unit,
          p_fator              DECIMAL(15,10),
          p_tot_item           DECIMAL(17,10),
          p_tot_calc           DECIMAL(12,2),
          p_dif                DECIMAL(10,4),
          p_consistido         SMALLINT,
          p_val_total          DECIMAL(12,2),
          p_qtd_solic          DECIMAL(10,2),
          p_opcao              CHAR(01),
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
          p_dat_txt            CHAR(10),
          p_dat_inv            CHAR(10),
          p_tot_ger            DECIMAL(13,4),
          p_retorno            SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          sql_stmt             CHAR(900),
          where_clause         CHAR(300),
          p_msg                CHAR(100)

   DEFINE p_frete_unit_kana    RECORD LIKE frete_unit_kana.*          
   
   DEFINE p_tela               RECORD
          num_pedido           LIKE pedidos.num_pedido,
          cod_cliente          LIKE clientes.cod_cliente,
          nom_cliente          LIKE clientes.nom_cliente,
          tot_info             DECIMAL(9,2)
   END RECORD

   DEFINE pr_itens     ARRAY[300] OF RECORD 
          num_seq      LIKE ped_itens.num_sequencia,
          cod_item     LIKE ped_itens.cod_item,
          den_item     LIKE item.den_item_reduz,
          qtd_solic    LIKE ped_itens.qtd_pecas_solic,
          val_frete    DECIMAL(10,2),
          val_total    DECIMAL(12,2)
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0482-10.02.04"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0482.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL pol0482_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0482_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0482") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0482 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         LET p_opcao = 'I'
         CALL pol0482_incluir() RETURNING p_status
         IF p_status THEN
            MESSAGE "Inclusão de Dados Efetuada c/ Sucesso !!!"
               ATTRIBUTE(REVERSE)
         ELSE
            MESSAGE "Operação Cancelada !!!"
               ATTRIBUTE(REVERSE)
         END IF      
         LET p_ies_cons = FALSE   
      COMMAND "Modificar" "Modifica/Inclui dados na Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         LET p_opcao = 'M'
         IF p_ies_cons THEN
            CALL pol0482_modificar() RETURNING p_status
            IF p_status THEN
               MESSAGE "Modificação de Dados Efetuada c/ Sucesso !!!"
                  ATTRIBUTE(REVERSE)
            ELSE
               MESSAGE "Operação Cancelada !!!"
                  ATTRIBUTE(REVERSE)
            END IF      
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND "Excluir" "Exclui Todos os dados da Tela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF p_tela.num_pedido IS NULL THEN
               ERROR "Não há dados na tela a serem excluídos !!!"
            ELSE
               CALL pol0482_excluir() RETURNING p_status
               IF p_status THEN
                  MESSAGE "Exclusão de Dados Efetuada c/ Sucesso !!!"
                     ATTRIBUTE(REVERSE)
               ELSE
                  MESSAGE "Operação Cancelada !!!"
                     ATTRIBUTE(REVERSE)
               END IF      
            END IF
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0482_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0482_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0482_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados do Cadastro"
         HELP 003
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0482","MO") THEN
            IF log0280_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0482_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0482.tmp'
                     START REPORT pol0482_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0482_relat TO p_nom_arquivo
               END IF
               CALL pol0482_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0482_relat   
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
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol0482_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0482

END FUNCTION

#-----------------------#
FUNCTION pol0482_incluir()
#-----------------------#

   IF pol0482_aceita_chave() THEN 
      IF pol0482_aceita_itens() THEN
         IF pol0482_grava_itens() THEN
            RETURN TRUE
         END IF
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#--------------------------#
FUNCTION pol0482_modificar()
#--------------------------#

   LET p_num_pedido = p_tela.num_pedido
   IF pol0482_aceita_itens() THEN
      IF pol0482_grava_itens() THEN
         CALL pol0482_exibe_dados()
         RETURN TRUE
      END IF
   END IF

   LET p_tela.num_pedido = p_num_pedido
   CALL pol0482_exibe_dados()

   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0482_aceita_chave()
#-----------------------------#
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0482

   INITIALIZE p_tela TO NULL

   INPUT BY NAME p_tela.* 
      WITHOUT DEFAULTS  

      AFTER FIELD num_pedido
         IF p_tela.num_pedido IS NOT NULL THEN 
            SELECT cod_cliente
              INTO p_tela.cod_cliente
              FROM pedidos
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido  = p_tela.num_pedido
            IF SQLCA.sqlcode = NOTFOUND THEN
               SELECT cod_cliente
                 INTO p_tela.cod_cliente
                 FROM pedido_dig_mest
                WHERE cod_empresa = p_cod_empresa
                  AND num_pedido  = p_tela.num_pedido
               IF SQLCA.sqlcode = NOTFOUND THEN
                  ERROR 'Pedido Inexistente !!!'
                  NEXT FIELD num_pedido
               ELSE
                  LET p_consistido = FALSE
               END IF
            ELSE
               LET p_consistido = TRUE
            END IF
        
            INITIALIZE p_tela.nom_cliente TO NULL
            SELECT nom_reduzido
              INTO p_tela.nom_cliente
              FROM clientes
             WHERE cod_cliente = p_tela.cod_cliente
             DISPLAY p_tela.cod_cliente TO cod_cliente
             DISPLAY p_tela.nom_cliente TO nom_cliente
         ELSE
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD num_pedido
         END IF
         
         SELECT COUNT(num_pedido)
           INTO p_count
           FROM frete_unit_kana
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = p_tela.num_pedido
         
         IF p_count > 0 THEN
            ERROR 'Pedido com frete unitário já lançado !!!'
            NEXT FIELD num_pedido
         END IF
         
      BEFORE FIELD tot_info
         LET p_tela.tot_info = 0
         DISPLAY 0 TO tot_info
         
   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION 

#-----------------------------#
FUNCTION pol0482_aceita_itens()
#-----------------------------#

   IF p_opcao = 'I' THEN
      CALL pol0482_carrega_ped_itens()
   END IF
     
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_itens
      WITHOUT DEFAULTS FROM sr_itens.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
      
      AFTER FIELD val_frete
 
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_itens[p_index+1].cod_item IS NULL THEN
               CALL pol0482_atualiza_total()
               NEXT FIELD val_frete
            END IF
         END IF
         
         IF pr_itens[p_index].val_frete IS NULL  AND 
            pr_itens[p_index].num_seq   IS NOT NULL THEN
            ERROR 'Valor do frete não pode ser nulo !!!'
            NEXT FIELD val_frete
         END IF   

         CALL pol0482_atualiza_total()

         {IF p_tot_ger > p_tela.tot_info THEN
            ERROR 'Soma do frete dos itens ultrapassou total do frete !!!'
            NEXT FIELD val_frete
         END IF}

                   
   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF   
   
END FUNCTION

#--------------------------------#
FUNCTION pol0482_atualiza_total()
#--------------------------------#
         
   LET pr_itens[p_index].val_total = 
       pr_itens[p_index].qtd_solic * pr_itens[p_index].val_frete
   DISPLAY pr_itens[p_index].val_total TO sr_itens[s_index].val_total
   CALL pol0482_calcula_tot_ger()
   DISPLAY p_tot_ger TO tot_ger

END FUNCTION

#-----------------------------------#
FUNCTION pol0482_carrega_ped_itens()
#-----------------------------------#

   IF p_consistido THEN
      LET sql_stmt = 
          " SELECT a.num_sequencia,a.cod_item,b.den_item_reduz,(a.qtd_pecas_solic - a.qtd_pecas_cancel), ",
          " a.pre_unit FROM ped_itens a, item b ",
          " WHERE a.cod_empresa = '",p_cod_empresa,"' ",
          " AND a.num_pedido    = '",p_tela.num_pedido,"' ",
          " AND b.cod_empresa   = a.cod_empresa ",
          " AND b.cod_item      = a.cod_item "
   ELSE
      LET sql_stmt = 
          " SELECT a.num_sequencia,a.cod_item,b.den_item_reduz,a.qtd_pecas_solic, ",
          " a.pre_unit FROM pedido_dig_item a, item b ",
          " WHERE a.cod_empresa = '",p_cod_empresa,"' ",
          " AND a.num_pedido    = '",p_tela.num_pedido,"' ",
          " AND b.cod_empresa   = a.cod_empresa ",
          " AND b.cod_item      = a.cod_item "
   END IF   
   
   PREPARE var_query FROM sql_stmt   
   
   LET p_tot_item = 0
   LET p_index = 1
   LET p_count = 0
   
   DECLARE cq_soma_itens CURSOR FOR var_query
   FOREACH cq_soma_itens 
      INTO pr_itens[p_index].num_seq,
           pr_itens[p_index].cod_item,
           pr_itens[p_index].den_item,
           pr_itens[p_index].qtd_solic,
           p_pre_unit

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_soma_itens')
         RETURN FALSE
      END IF
      
      LET p_val_item = pr_itens[p_index].qtd_solic * p_pre_unit
      LET p_tot_item = p_tot_item + p_val_item
      LET p_count = p_count + 1
      
      IF p_index > 300 THEN
         EXIT FOREACH
      END IF

   END FOREACH

   LET p_fator    = p_tela.tot_info / p_tot_item
   LET p_tot_calc = 0
   LET p_index    = 1
   LET p_tot_ger  = 0
      
   DECLARE cq_ped_itens CURSOR FOR var_query
   FOREACH cq_ped_itens 
      INTO pr_itens[p_index].num_seq,
           pr_itens[p_index].cod_item,
           pr_itens[p_index].den_item,
           pr_itens[p_index].qtd_solic,
           p_pre_unit
 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_ped_itens')
         RETURN FALSE
      END IF

      LET pr_itens[p_index].val_frete = p_pre_unit * p_fator
      LET pr_itens[p_index].val_total = 
          pr_itens[p_index].qtd_solic * pr_itens[p_index].val_frete
      LET p_tot_calc = p_tot_calc + pr_itens[p_index].val_total

      {IF p_index = p_count THEN
         IF p_tot_calc <> p_tela.tot_info THEN
            LET p_dif = (p_tela.tot_info - p_tot_calc) / pr_itens[p_index].qtd_solic
            LET pr_itens[p_index].val_frete = pr_itens[p_index].val_frete + p_dif
            LET pr_itens[p_index].val_total = 
                pr_itens[p_index].qtd_solic * pr_itens[p_index].val_frete
         END IF
      END IF}
         
      LET p_tot_ger = p_tot_ger + pr_itens[p_index].val_total
      LET p_index = p_index + 1

      IF p_index > 300 THEN
         EXIT FOREACH
      END IF

   END FOREACH
   
   DISPLAY p_tot_ger TO tot_ger

END FUNCTION
#---------------------------------#
FUNCTION pol0482_calcula_tot_ger()
#---------------------------------#

   DEFINE p_ind SMALLINT

   LET p_tot_ger = 0
   
   FOR p_ind = 1 TO ARR_COUNT()
       LET p_tot_ger = p_tot_ger + pr_itens[p_ind].val_total
   END FOR
   
END FUNCTION  

#-----------------------------#
FUNCTION pol0482_grava_itens()
#-----------------------------#
   
   DEFINE p_ind SMALLINT 
   CALL log085_transacao("BEGIN")

   WHENEVER ERROR CONTINUE
   IF p_opcao = 'M' THEN
      IF NOT pol0482_deleta() THEN
         RETURN FALSE
      END IF
   END IF
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_itens[p_ind].num_seq IS NOT NULL THEN
          
		       INSERT INTO frete_unit_kana
		       VALUES (p_cod_empresa,
		               p_tela.num_pedido,
		               pr_itens[p_ind].num_seq,
		               pr_itens[p_ind].cod_item,
		               pr_itens[p_ind].val_frete)
		
		       IF sqlca.sqlcode <> 0 THEN 
		          MESSAGE "Erro na inclusão" ATTRIBUTE(REVERSE)
		          CALL log003_err_sql("GRAVAÇÃO","frete_unit_kana")
		          CALL log085_transacao("ROLLBACK")
		          RETURN FALSE
		       END IF
       END IF
   END FOR
         
   CALL log085_transacao("COMMIT")	      
   RETURN TRUE
      
END FUNCTION

#------------------------#
FUNCTION pol0482_deleta()
#------------------------#

   DELETE FROM frete_unit_kana
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_tela.num_pedido

   IF sqlca.sqlcode <> 0 THEN 
      MESSAGE "Erro na deleção" ATTRIBUTE(REVERSE)
      CALL log003_err_sql("DELEÇÃO","frete_unit_kana")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION

#--------------------------#
 FUNCTION pol0482_consulta()
#--------------------------#

   LET p_num_pedido = p_tela.num_pedido
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
      
   CONSTRUCT BY NAME where_clause ON 
      frete_unit_kana.num_pedido

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0482

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_tela.num_pedido = p_num_pedido
      CALL pol0482_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT num_pedido FROM frete_unit_kana ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY num_pedido"

   PREPARE var_queri FROM sql_stmt   
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_queri
   OPEN cq_consulta
   FETCH cq_consulta INTO p_tela.num_pedido
   
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0482_exibe_dados()
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0482_exibe_dados()
#-----------------------------------#
   
   INITIALIZE pr_itens TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CALL pol0482_carrega_itens()

   SELECT cod_cliente
     INTO p_tela.cod_cliente
     FROM pedidos
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = p_tela.num_pedido

   SELECT nom_cliente
     INTO p_tela.nom_cliente
     FROM clientes
    WHERE cod_cliente = p_tela.cod_cliente

   DISPLAY BY NAME p_tela.*
   DISPLAY p_tot_ger TO tot_ger
   
   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY pr_itens WITHOUT DEFAULTS FROM sr_itens.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT

 END FUNCTION

#-----------------------------#
FUNCTION pol0482_carrega_itens()
#-----------------------------#

   SELECT num_pedido
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_tela.num_pedido
 
   IF STATUS = 0 THEN
      
      LET sql_stmt =
          " SELECT a.num_pedido, ",
              " a.num_sequencia, ",
              " a.cod_item, ",
              " b.den_item_reduz, ",
              " (c.qtd_pecas_solic - c.qtd_pecas_cancel), ",
              " a.val_frete_unit, ",
              " ((c.qtd_pecas_solic - c.qtd_pecas_cancel) * a.val_frete_unit) ",
              " FROM frete_unit_kana a, ",
              " item b, ",
              " ped_itens c ",
        " WHERE a.cod_empresa   = '",p_cod_empresa,"' ",
        "   AND a.num_pedido    = '",p_tela.num_pedido,"' ",
        "   AND b.cod_empresa   = a.cod_empresa ",
        "   AND b.cod_item      = a.cod_item ",
        "   AND c.cod_empresa   = a.cod_empresa ",
        "   AND c.num_pedido    = a.num_pedido ",
        "   AND c.num_sequencia = a.num_sequencia ",
        " ORDER BY a.num_sequencia "
   ELSE
      LET sql_stmt =
          " SELECT a.num_pedido, ",
              " a.num_sequencia, ",
              " a.cod_item, ",
              " b.den_item_reduz, ",
              " c.qtd_pecas_solic, ",
              " a.val_frete_unit, ",
              " (c.qtd_pecas_solic * a.val_frete_unit) ",
              " FROM frete_unit_kana a, ",
              " item b, ",
              " pedido_dig_item c ",
        " WHERE a.cod_empresa   = '",p_cod_empresa,"' ",
        "   AND a.num_pedido    = '",p_tela.num_pedido,"' ",
        "   AND b.cod_empresa   = a.cod_empresa ",
        "   AND b.cod_item      = a.cod_item ",
        "   AND c.cod_empresa   = a.cod_empresa ",
        "   AND c.num_pedido    = a.num_pedido ",
        "   AND c.num_sequencia = a.num_sequencia ",
        " ORDER BY a.num_sequencia "
   END IF
   
   LET p_index = 1
   LET p_tot_ger = 0

   PREPARE var_query2 FROM sql_stmt   
   DECLARE cq_itens CURSOR FOR var_query2

   FOREACH cq_itens 
      INTO p_tela.num_pedido,
           pr_itens[p_index].*
   
      LET p_tot_ger = p_tot_ger + pr_itens[p_index].val_total

      LET p_index = p_index + 1

      IF p_index > 300 THEN
         EXIT FOREACH
      END IF

   END FOREACH

END FUNCTION

#-----------------------------------#
 FUNCTION pol0482_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_num_pedido = p_tela.num_pedido
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_consulta INTO 
                            p_tela.num_pedido
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_consulta INTO 
                            p_tela.num_pedido
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_tela.num_pedido = p_num_pedido 
            EXIT WHILE
         END IF

         IF p_tela.num_pedido = p_num_pedido THEN
            CONTINUE WHILE
         END IF 
         
         SELECT COUNT(num_pedido)
           INTO p_count
           FROM frete_unit_kana
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = p_tela.num_pedido
         
         IF p_count > 0 THEN
            CALL pol0482_exibe_dados()
            EXIT WHILE
         END IF
     
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#------------------------#
FUNCTION pol0482_excluir()
#------------------------#

  IF log004_confirm(18,35) THEN
      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      IF pol0482_deleta() THEN
         CALL log085_transacao("COMMIT")
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
         INITIALIZE p_tela.num_pedido TO NULL
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE
      
END FUNCTION

#-----------------------------------#
 FUNCTION pol0482_emite_relatorio()
#-----------------------------------#

   LET p_count = 0
       
   SELECT den_empresa INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   DECLARE cq_imprime CURSOR FOR
    SELECT a.*,
           b.den_item_reduz,
           c.qtd_pecas_solic,
          (c.qtd_pecas_solic * a.val_frete_unit)
      FROM frete_unit_kana a,
           item b,
           ped_itens c
     WHERE a.cod_empresa   = p_cod_empresa
       AND b.cod_empresa   = a.cod_empresa
       AND b.cod_item      = a.cod_item
       AND c.cod_empresa   = a.cod_empresa
       AND c.num_pedido    = a.num_pedido
       AND c.num_sequencia = a.num_sequencia
     ORDER BY a.num_pedido, a.num_sequencia

   FOREACH cq_imprime INTO 
           p_frete_unit_kana.*,
           p_den_item_reduz,
           p_qtd_solic,
           p_val_total
  
      OUTPUT TO REPORT pol0482_relat(p_frete_unit_kana.num_pedido)
     
      LET p_count = p_count + 1
      
   END FOREACH
   
END FUNCTION 

#----------------------------------#
 REPORT pol0482_relat(p_relat)
#----------------------------------#

   DEFINE p_relat RECORD
          num_pedido LIKE frete_unit_kana.num_pedido
   END RECORD
          
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   ORDER EXTERNAL BY p_relat.num_pedido
   
   FORMAT
      
      FIRST PAGE HEADER  
      
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 072, "PAG.: ", PAGENO USING "##&"
         PRINT COLUMN 001, "pol0482",
               COLUMN 023, "FRETE UNITARIO POR ITEM DO PEDIDO",
               COLUMN 065, "DATA: ", DATE USING "dd/mm/yyyy"
                
         PRINT COLUMN 001, "*---------------------------------------",
                           "---------------------------------------*"
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 072, "PAG.: ", PAGENO USING "##&"
         PRINT COLUMN 001, "pol0482",
               COLUMN 023, "FRETE UNITARIO POR ITEM DO PEDIDO",
               COLUMN 065, "DATA: ", DATE USING "dd/mm/yyyy"
                
         PRINT COLUMN 001, "*---------------------------------------",
                           "---------------------------------------*"
                           

      BEFORE GROUP OF p_relat.num_pedido

         SELECT cod_cliente
           INTO p_cod_cliente
           FROM pedidos
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = p_relat.num_pedido
            
         INITIALIZE p_tela.nom_cliente TO NULL

         SELECT nom_cliente
           INTO p_nom_cliente
           FROM clientes
          WHERE cod_cliente = p_cod_cliente
                              
         PRINT
         PRINT COLUMN 001, 'Pedido: ', p_relat.num_pedido CLIPPED, 
                           '  Cliente: ', p_cod_cliente CLIPPED, ' ', p_nom_cliente
         PRINT
         PRINT COLUMN 001, 'SEQ.       ITEM            DESCRICAO     QTD SOLIC   VALOR FRETE    VALOR TOTAL'
         PRINT COLUMN 001, '----- --------------- ------------------ ---------- ------------- --------------'
         PRINT
                           
      ON EVERY ROW

         PRINT COLUMN 001, p_frete_unit_kana.num_sequencia USING '####&',
               COLUMN 007, p_frete_unit_kana.cod_item,
               COLUMN 023, p_den_item_reduz,
               COLUMN 042, p_qtd_solic USING '######&.&&',
               COLUMN 053, p_frete_unit_kana.val_frete_unit USING '##,###,##&.&&',
               COLUMN 067, p_val_total USING '###,###,##&.&&'

      AFTER GROUP OF p_relat.num_pedido

        SKIP 1 LINES
         PRINT COLUMN 045, "TOTAL DO PEDIDO: R$ ",
                     GROUP SUM (p_val_total) USING "#,###,###,##&.&&"
                           
         PRINT
         
      ON LAST ROW

         SKIP 3 LINES
         PRINT COLUMN 049, "TOTAL GERAL: R$ ",
                           SUM (p_val_total) USING "##,###,###,##&.&&"
                           
END REPORT

#-----------------------#
 FUNCTION pol0482_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#