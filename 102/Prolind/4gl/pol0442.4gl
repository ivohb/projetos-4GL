#-------------------------------------------------------------------#
# PROGRAMA: pol0442                                                 #
# MODULOS.: pol0442-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: ESTOQUE DOS COMPONENTES DA ORDEM DE PRODUÇÃO            #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 01/08/2006                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_item           LIKE item.den_item,
          p_den_item_redux     LIKE item.den_item_reduz,
          p_qtd_planej         LIKE ordens.qtd_planej,
          p_cod_local_estoq    LIKE ordens.cod_local_estoq,
          p_cod_local_prod     LIKE ordens.cod_local_prod,
          p_prioridade         LIKE man_prior_consumo.prioridade,
          p_msg                CHAR(300),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(80)

   DEFINE p_tela              RECORD
          num_ordem           LIKE ordens.num_ordem,
          dat_entrega         LIKE ordens.dat_entrega,
          num_docum           LIKE ordens.num_docum,
          dat_liberac         LIKE ordens.dat_liberac,
          ies_situa           LIKE ordens.ies_situa,
          cod_item            LIKE ordens.cod_item
   END RECORD

   DEFINE p_telaa             RECORD
          num_ordem           LIKE ordens.num_ordem,
          dat_entrega         LIKE ordens.dat_entrega,
          num_docum           LIKE ordens.num_docum,
          dat_liberac         LIKE ordens.dat_liberac,
          ies_situa           LIKE ordens.ies_situa,
          cod_item            LIKE ordens.cod_item
   END RECORD
   
   DEFINE pr_compon           ARRAY[100] OF RECORD
          cod_item            LIKE item.cod_item,
          den_item_reduz      LIKE item.den_item_reduz,
          qtd_necessaria      DECIMAL(9,3),
          qtd_dispon          DECIMAL(9,3),
          qtd_estoque         DECIMAL(9,3),
          qtd_fila            DECIMAL(9,3)
   END RECORD

   DEFINE p_local             RECORD
          loc_estoque         DECIMAL(1,0)
   END RECORD

   DEFINE p_locala            RECORD
          loc_estoque         DECIMAL(1,0)
   END RECORD
   
   DEFINE pr_local            ARRAY[4] OF RECORD
          cod_local           CHAR(01),
          den_local           CHAR(45)
   END RECORD


END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0442-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0442.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0442_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0442_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0442") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0442 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   LET pr_local[1].cod_local = 1
   LET pr_local[2].cod_local = 2
   LET pr_local[3].cod_local = 3
   LET pr_local[4].cod_local = 4
   LET pr_local[1].den_local = 'Local de estoque' 
   LET pr_local[2].den_local = 'Todos os locais menos do local de produção' 
   LET pr_local[3].den_local = 'Local de pordução' 
   LET pr_local[4].den_local = 'Todos os locais' 
   
   MENU "OPCAO"
      COMMAND "Consulta" "Consulta a OP e seus componentes"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         LET p_ies_cons = FALSE
         CALL pol0442_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0442_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0442_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0442_sobre() 
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
   CLOSE WINDOW w_pol0442

END FUNCTION

#-----------------------#
FUNCTION pol0442_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
 FUNCTION pol0442_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_telaa.* = p_tela.*
   LET p_locala.* = p_local.*
   
 CONSTRUCT BY NAME where_clause ON 
    ordens.num_ordem, ordens.dat_entrega,
    ordens.num_docum, ordens.dat_liberac,
    ordens.ies_situa, ordens.cod_item

#    ON KEY (f4,control-z)
#       CALL pol0442_popup()
 
# END CONSTRUCT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0442

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   IF NOT pol0442_aceita_local() THEN
      ERROR "Consulta Cancelada"
      RETURN
   END IF   

   LET sql_stmt = "SELECT num_ordem, dat_entrega, num_docum, ",
                  " dat_liberac, ies_situa, cod_item, qtd_planej, cod_local_prod ",
                  " FROM ordens ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY num_ordem "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO
         p_tela.*, p_qtd_planej, p_cod_local_prod
         
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0442_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0442_aceita_local()
#-----------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0442
   INITIALIZE p_local.loc_estoque TO NULL
   
   INPUT BY NAME p_local.* WITHOUT DEFAULTS

      AFTER FIELD loc_estoque
         IF p_local.loc_estoque IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD loc_estoque
         END IF
             
         IF p_local.loc_estoque < 1 OR p_local.loc_estoque > 4 THEN
            ERROR 'Opção Inválida !!!'
            NEXT FIELD loc_estoque
         END IF

      ON KEY (control-z)
         CALL pol0442_popup()

   END INPUT

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF
         

END FUNCTION

#------------------------------#
 FUNCTION pol0442_exibe_dados()
#------------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   DISPLAY BY NAME p_tela.*
   DISPLAY p_qtd_planej TO qtd_planej
   CASE p_tela.ies_situa
      WHEN '1' DISPLAY 'Planejada' TO den_situa
      WHEN '2' DISPLAY 'Firme    ' TO den_situa
      WHEN '3' DISPLAY 'Aberta   ' TO den_situa
      WHEN '4' DISPLAY 'Liberada ' TO den_situa
      WHEN '5' DISPLAY 'Fechada  ' TO den_situa
      WHEN '9' DISPLAY 'Cancelada' TO den_situa
   END CASE
   DISPLAY p_local.loc_estoque TO loc_estoque
   DISPLAY pr_local[p_local.loc_estoque].den_local TO den_loc_estoque
   
   INITIALIZE p_den_item TO NULL
   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_tela.cod_item
      
   DISPLAY p_den_item TO den_item
   
   CALL pol0442_exibe_compon()

END FUNCTION

#------------------------------#
FUNCTION pol0442_exibe_compon()
#------------------------------#

   DECLARE cq_compon CURSOR FOR
    SELECT a.cod_item, a.qtd_necessaria - a.qtd_saida,
           b.den_item_reduz
      FROM necessidades a, item b
     WHERE a.cod_empresa = p_cod_empresa
       AND a.num_ordem   = p_tela.num_ordem
       AND b.cod_empresa = a.cod_empresa
       AND b.cod_item    = a.cod_item
   
   LET p_index = 1
   
   FOREACH cq_compon INTO 
      pr_compon[p_index].cod_item,
      pr_compon[p_index].qtd_necessaria,
      pr_compon[p_index].den_item_reduz
      
      CALL pol0442_calc_estoques()      
      LET p_index = p_index + 1
   
   END FOREACH

   IF p_index = 1 THEN
      ERROR 'ORDEM SEM COMPONENTES'
      RETURN
   END IF
   
   CALL SET_COUNT(p_index - 1)

   IF p_index > 7 THEN
      DISPLAY ARRAY pr_compon TO  sr_compon.*
   ELSE
      INPUT ARRAY pr_compon WITHOUT DEFAULTS FROM sr_compon.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF
   
END FUNCTION

#--------------------------------#
 FUNCTION pol0442_calc_estoques()
#--------------------------------#

   SELECT cod_local_estoq
     INTO p_cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = pr_compon[p_index].cod_item
      
   SELECT prioridade
     INTO p_prioridade
     FROM man_prior_consumo
    WHERE empresa  = p_cod_empresa
      AND item      = pr_compon[p_index].cod_item
      AND docum     = p_tela.num_ordem
      AND tip_docum = "OP"
      AND prior_atendida IN ('N','P')

   IF sqlca.sqlcode = NOTFOUND THEN
      SELECT SUM(qtd_reservada)
        INTO pr_compon[p_index].qtd_fila
        FROM man_prior_consumo
       WHERE empresa = p_cod_empresa
         AND item    = pr_compon[p_index].cod_item
         AND prior_atendida IN ('N','P')
   ELSE
      SELECT SUM(qtd_reservada)
        INTO pr_compon[p_index].qtd_fila
        FROM man_prior_consumo
       WHERE empresa    = p_cod_empresa
         AND item       = pr_compon[p_index].cod_item
         AND prioridade < p_prioridade
         AND prior_atendida IN ('N','P')
   END IF

   IF pr_compon[p_index].qtd_fila IS NULL THEN
      LET pr_compon[p_index].qtd_fila = 0
   END IF

   CASE p_local.loc_estoque
      WHEN 1
         SELECT SUM(qtd_saldo)
           INTO pr_compon[p_index].qtd_estoque
           FROM estoque_lote
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = pr_compon[p_index].cod_item
            AND cod_local   = p_cod_local_estoq
            AND ies_situa_qtd in( "L", "E")
      WHEN 2
         SELECT SUM(qtd_saldo)
           INTO pr_compon[p_index].qtd_estoque
           FROM estoque_lote
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = pr_compon[p_index].cod_item
            AND cod_local  <> p_cod_local_prod
            AND ies_situa_qtd in( "L", "E")
      WHEN 3
         SELECT SUM(qtd_saldo)
           INTO pr_compon[p_index].qtd_estoque
           FROM estoque_lote
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = pr_compon[p_index].cod_item
            AND cod_local   = p_cod_local_prod
            AND ies_situa_qtd in( "L", "E")
      WHEN 4
         SELECT SUM(qtd_saldo)
           INTO pr_compon[p_index].qtd_estoque
           FROM estoque_lote
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = pr_compon[p_index].cod_item
            AND ies_situa_qtd in( "L", "E")
   END CASE     
   
   IF pr_compon[p_index].qtd_estoque IS NULL THEN
      LET pr_compon[p_index].qtd_estoque = 0
   END IF
   
   LET pr_compon[p_index].qtd_dispon = 
       pr_compon[p_index].qtd_estoque - pr_compon[p_index].qtd_fila

END FUNCTION 

#-----------------------------------#
 FUNCTION pol0442_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_telaa.* = p_tela.*
      CASE
         WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_tela.*, p_qtd_planej
         WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_tela.*, p_qtd_planej
      END CASE

      IF SQLCA.SQLCODE = NOTFOUND THEN
         ERROR "Nao Existem Mais Itens Nesta Direção"
         LET p_tela.* = p_telaa.* 
      ELSE
         CALL pol0442_exibe_dados()
      END IF
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#----------------------#
FUNCTION pol0442_popup()
#----------------------#

   DEFINE pr_index, sr_index SMALLINT
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04421") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol04421 AT 10,15 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DISPLAY '  LOCAL P/ PESQUISA DO ESTOQUE  ' TO den_titulo
   
   LET pr_index = 4
   CALL SET_COUNT(pr_index)
   
   DISPLAY ARRAY pr_local TO sr_local.*

      LET pr_index = ARR_CURR()
      LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol04421
   
   IF INT_FLAG = 0 THEN
      LET p_local.loc_estoque = pr_local[pr_index].cod_local
      DISPLAY p_local.loc_estoque TO loc_estoque
   ELSE
      LET INT_FLAG = 0
   END IF 

END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#

