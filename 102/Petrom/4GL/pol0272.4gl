#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL0272                                                 #
# MODULOS.: POL0272 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA ESTRUT_ITEM_INDUS                  #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 01/07/2004                                              #
#-------------------------------------------------------------------#
DATABASE logix
GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          p_caminho            CHAR(80),
          g_ies_ambiente       CHAR(001),
          p_count              SMALLINT,
      #   p_versao             CHAR(17),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
      #   p_nom_tela           CHAR(200),
          p_nom_tela           CHAR(080),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_last_row           SMALLINT,
          pa_curr              SMALLINT,
          sc_curr              SMALLINT,
          p_i                  SMALLINT,
          p_msg                CHAR(100)

   DEFINE p_estrut_item_indus  RECORD LIKE estrut_item_indus.*,
          p_estrut_item_induss RECORD LIKE estrut_item_indus.*

   DEFINE p_item RECORD
      den_item_prod LIKE item.den_item_reduz,
      nom_cliente   LIKE clientes.nom_cliente   
   END RECORD

   DEFINE p_tela RECORD
      cod_item_prd LIKE estrut_item_indus.cod_item_prd,
      dat_inclusao LIKE estrut_item_indus.dat_inclusao,
      cod_cliente  LIKE estrut_item_indus.cod_cliente 
   END RECORD

   DEFINE t_estrut_item ARRAY[100] OF RECORD
      seq_estrut   LIKE estrut_item_indus.seq_estrut,
      cod_item_ret LIKE estrut_item_indus.cod_item_ret,
      den_item_ret LIKE item.den_item_reduz,
      cod_unid_med LIKE item.cod_unid_med,
      qtd_item_ret LIKE estrut_item_indus.qtd_item_ret
   END RECORD

   DEFINE p_relat RECORD
      cod_item_prd  LIKE estrut_item_indus.cod_item_prd,
      den_item_prod LIKE item.den_item_reduz,
      dat_inclusao  LIKE estrut_item_indus.dat_inclusao,
      cod_cliente   LIKE estrut_item_indus.cod_cliente,
      nom_cliente   LIKE clientes.nom_cliente,         
      seq_estrut    LIKE estrut_item_indus.seq_estrut,
      cod_item_ret  LIKE estrut_item_indus.cod_item_ret,
      den_item_ret  LIKE item.den_item_reduz,
      cod_unid_med  LIKE item.cod_unid_med,
      qtd_item_ret  LIKE estrut_item_indus.qtd_item_ret
   END RECORD
END GLOBALS
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0272-10.02.01"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0272.iem") RETURNING p_nom_help
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
      CALL pol0272_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0272_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL0272") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0272 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
            CALL pol0272_inclusao() RETURNING p_status
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_estrut_item_indus.cod_empresa IS NOT NULL THEN
            CALL pol0272_modificacao()
            LET p_ies_cons = TRUE
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_estrut_item_indus.cod_empresa IS NOT NULL THEN
               CALL pol0272_exclusao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
            CALL pol0272_consulta()
            IF p_ies_cons = TRUE THEN
               NEXT OPTION "Seguinte"
            END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0272_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0272_paginacao("ANTERIOR") 
      COMMAND "Listar" "Lista Parametros de Entrada"
         HELP 007
         MESSAGE ""
         LET INT_FLAG = 0
            CALL pol0272_listar() 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol0272_sobre()
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
   CLOSE WINDOW w_pol0272

END FUNCTION

#--------------------------#
 FUNCTION pol0272_inclusao()
#--------------------------#

   LET p_houve_erro = TRUE
   
   BEGIN WORK
   
   IF pol0272_entrada_dados() THEN
      IF pol0272_entrada_itens("INCLUSAO") THEN
         LET p_estrut_item_indus.cod_empresa  = p_cod_empresa
         LET p_estrut_item_indus.cod_item_prd = p_tela.cod_item_prd
         LET p_estrut_item_indus.dat_inclusao = p_tela.dat_inclusao
         LET p_estrut_item_indus.cod_cliente  = p_tela.cod_cliente 
         FOR p_i = 1 TO ARR_COUNT()
            IF t_estrut_item[p_i].cod_item_ret IS NULL THEN                 
               EXIT FOR
            ELSE
               LET p_estrut_item_indus.seq_estrut = 
                   t_estrut_item[p_i].seq_estrut
               LET p_estrut_item_indus.cod_item_ret =
                   t_estrut_item[p_i].cod_item_ret
               LET p_estrut_item_indus.qtd_item_ret = 
                   t_estrut_item[p_i].qtd_item_ret
               
               INSERT INTO estrut_item_indus VALUES (p_estrut_item_indus.*)
               IF STATUS <> 0 THEN 
	                CALL log003_err_sql("INCLUSAO","ESTRUT_ITEM_INDUS")
                  EXIT FOR
               END IF
            
            END IF
         END FOR
	       IF p_i > 1 THEN
	          LET p_houve_erro = FALSE
	       END IF
	    END IF
	 END IF
	 
	 IF p_houve_erro THEN
      ROLLBACK WORK
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF
   
   COMMIT WORK 
   MESSAGE "Inclusao Efetuada com Sucesso...!!!" ATTRIBUTE(REVERSE)
   LET p_ies_cons = FALSE
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol0272_entrada_dados()
#-------------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0272
   CLEAR FORM
   INITIALIZE p_tela.*, p_estrut_item_indus.* TO NULL
   DISPLAY BY NAME p_tela.*
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG = FALSE
   INPUT BY NAME p_tela.* 
      WITHOUT DEFAULTS  

      AFTER FIELD cod_item_prd
      IF p_tela.cod_item_prd IS NOT NULL THEN
         SELECT den_item_reduz
            INTO p_item.den_item_prod
         FROM item    
         WHERE cod_empresa = p_cod_empresa
           AND cod_item = p_tela.cod_item_prd
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Item Produzido nao Cadastrado" 
            NEXT FIELD cod_item_prd
         ELSE 
            DISPLAY BY NAME p_item.den_item_prod
         END IF
      ELSE 
         ERROR "O Campo Cod Item Produzido nao pode ser Nulo"
         NEXT FIELD cod_item_prd
      END IF

      AFTER FIELD dat_inclusao
      IF p_tela.dat_inclusao IS NULL THEN
         ERROR "O Campo Data de Inclusao nao pode ser Nulo"
         NEXT FIELD dat_inclusao 
      END IF

      AFTER FIELD cod_cliente  
      IF p_tela.cod_cliente IS NOT NULL THEN
         SELECT UNIQUE cod_empresa,
                       cod_item_prd,
                       dat_inclusao,
                       cod_cliente
         FROM estrut_item_indus
         WHERE cod_empresa  = p_cod_empresa
           AND cod_item_prd = p_tela.cod_item_prd
           AND dat_inclusao = p_tela.dat_inclusao
           AND cod_cliente  = p_tela.cod_cliente 
         IF SQLCA.SQLCODE = 0 THEN
            ERROR "Item Produzido já Cadastrado"
            NEXT FIELD cod_item_prd
         END IF
         SELECT nom_cliente   
            INTO p_item.nom_cliente   
         FROM clientes 
         WHERE cod_cliente = p_tela.cod_cliente  
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cliente nao Cadastrado" 
            NEXT FIELD cod_cliente 
         ELSE 
            DISPLAY BY NAME p_item.nom_cliente   
         END IF
      ELSE 
         ERROR "O Campo Cod Cliente nao pode ser Nulo"
         NEXT FIELD cod_cliente  
      END IF
      
      ON KEY (control-z)
         CALL pol0272_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0272
   IF INT_FLAG = 0 THEN
      LET p_ies_cons = FALSE
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------------------#
 FUNCTION pol0272_entrada_itens(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(20)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0272
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE t_estrut_item TO NULL
   END IF

   LET INT_FLAG = FALSE
   INPUT ARRAY t_estrut_item WITHOUT DEFAULTS FROM s_estrut_item.*
            
      BEFORE ROW
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()
      {   IF t_estrut_item[pa_curr].seq_estrut IS NULL THEN
            LET t_estrut_item[pa_curr].seq_estrut = pa_curr
            DISPLAY t_estrut_item[pa_curr].seq_estrut TO 
                    s_estrut_item[sc_curr].seq_estrut
         END IF}

      AFTER FIELD cod_item_ret
         IF t_estrut_item[pa_curr].cod_item_ret IS NOT NULL THEN

            SELECT den_item_reduz,
                   cod_unid_med
              INTO t_estrut_item[pa_curr].den_item_ret,
                   t_estrut_item[pa_curr].cod_unid_med
              FROM item
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = t_estrut_item[pa_curr].cod_item_ret
            
            IF STATUS = 100 THEN
               ERROR "Item Retorno não cadastrado !!!"
               NEXT FIELD cod_item_ret
            ELSE
               IF STATUS <> 0 THEN
                  CALL log003_err_sql("Lendo", "item")
                  RETURN FALSE
               END IF
            END IF
            
            LET t_estrut_item[pa_curr].seq_estrut = pa_curr
            DISPLAY t_estrut_item[pa_curr].seq_estrut TO 
                    s_estrut_item[sc_curr].seq_estrut
            DISPLAY t_estrut_item[pa_curr].den_item_ret TO 
                    s_estrut_item[sc_curr].den_item_ret
            DISPLAY t_estrut_item[pa_curr].cod_unid_med TO 
                    s_estrut_item[sc_curr].cod_unid_med
         ELSE
            IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
            ELSE
               ERROR "Campo com prenchimento obrigatório !!!"
               NEXT FIELD cod_item_ret
            END IF
         END IF

      BEFORE FIELD qtd_item_ret
         IF t_estrut_item[pa_curr].cod_item_ret IS NULL THEN
            NEXT FIELD cod_item_ret
         END IF
         
      AFTER FIELD qtd_item_ret
         IF t_estrut_item[pa_curr].qtd_item_ret IS NULL THEN
            ERROR "Campo com prenchimento obrigatório !!!"
            NEXT FIELD qtd_item_ret
         END IF
      
      AFTER ROW
         {IF pa_curr = 1 THEN
            IF t_estrut_item[pa_curr].cod_item_ret IS NULL AND
               t_estrut_item[pa_curr].qtd_item_ret IS NULL THEN
               ERROR "Campo com prenchimento obrigatório !!!"
               NEXT FIELD cod_item_ret
            END IF
         END IF}
         IF NOT INT_FLAG THEN      
            IF t_estrut_item[pa_curr].cod_item_ret IS NOT NULL AND
               t_estrut_item[pa_curr].qtd_item_ret IS NULL     THEN
               ERROR "Campo com prenchimento obrigatório !!!"
               NEXT FIELD qtd_item_ret
            ELSE
               IF t_estrut_item[pa_curr].cod_item_ret IS NULL     AND
                  t_estrut_item[pa_curr].qtd_item_ret IS NOT NULL THEN
                  ERROR "Campo com prenchimento obrigatório !!!"
                  NEXT FIELD cod_item_ret
               END IF
            END IF
         END IF
                        
      ON KEY (control-z)
         CALL pol0272_popup()

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0272

   IF INT_FLAG = 0 THEN
      LET p_ies_cons = FALSE
      RETURN TRUE 
   ELSE
      LET INT_FLAG = 0
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0272_consulta()
#--------------------------#

   DEFINE sql_stmt, where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON estrut_item_indus.cod_item_prd,
                                     estrut_item_indus.dat_inclusao,
                                     estrut_item_indus.cod_cliente     
      
      ON KEY (control-z)
         CALL pol0272_popup()
         
   END CONSTRUCT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0272
   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_estrut_item_indus.* = p_estrut_item_induss.*
      CALL pol0272_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT UNIQUE cod_empresa, ",
                  "              cod_item_prd, ",
                  "              dat_inclusao, ",
                  "              cod_cliente ",
                  " FROM estrut_item_indus ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_item_prd "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao

   FETCH cq_padrao INTO p_estrut_item_indus.cod_empresa,
                        p_estrut_item_indus.cod_item_prd,
                        p_estrut_item_indus.dat_inclusao,
                        p_estrut_item_indus.cod_cliente 

      IF SQLCA.SQLCODE = NOTFOUND THEN
         ERROR "Argumentos de Pesquisa nao Encontrados"
         LET p_ies_cons = FALSE
      ELSE 
         LET p_ies_cons = TRUE
         CALL pol0272_exibe_dados()
      END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0272_exibe_dados()
#-----------------------------#
 
   SELECT den_item_reduz
      INTO p_item.den_item_prod
   FROM item
   WHERE cod_empresa = p_cod_empresa
     AND cod_item = p_estrut_item_indus.cod_item_prd

   SELECT nom_cliente   
      INTO p_item.nom_cliente   
   FROM clientes 
   WHERE cod_cliente = p_estrut_item_indus.cod_cliente  

   DISPLAY BY NAME p_estrut_item_indus.cod_item_prd,
                   p_estrut_item_indus.dat_inclusao,
                   p_estrut_item_indus.cod_cliente,
                   p_item.*

   INITIALIZE t_estrut_item TO NULL
   DECLARE cq_item CURSOR WITH HOLD FOR
   SELECT seq_estrut,
          cod_item_ret,
          qtd_item_ret
   FROM estrut_item_indus
   WHERE cod_empresa  = p_estrut_item_indus.cod_empresa
     AND cod_item_prd = p_estrut_item_indus.cod_item_prd
     AND dat_inclusao = p_estrut_item_indus.dat_inclusao
     AND cod_cliente  = p_estrut_item_indus.cod_cliente 
   ORDER BY 1

   LET p_i = 1
   FOREACH cq_item INTO t_estrut_item[p_i].seq_estrut,
                        t_estrut_item[p_i].cod_item_ret,
                        t_estrut_item[p_i].qtd_item_ret

      SELECT den_item_reduz,
             cod_unid_med
         INTO t_estrut_item[p_i].den_item_ret,
              t_estrut_item[p_i].cod_unid_med
      FROM item
      WHERE cod_empresa = p_estrut_item_indus.cod_empresa
        AND cod_item = t_estrut_item[p_i].cod_item_ret
      LET p_i = p_i + 1

   END FOREACH

   LET p_i = p_i - 1
   CALL SET_COUNT(p_i)

   IF p_i > 8 THEN 
      DISPLAY ARRAY t_estrut_item TO s_estrut_item.*
   ELSE
      INPUT ARRAY t_estrut_item WITHOUT DEFAULTS FROM s_estrut_item.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol0272_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_estrut_item_induss.* = p_estrut_item_indus.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_estrut_item_indus.cod_empresa,
                            p_estrut_item_indus.cod_item_prd,
                            p_estrut_item_indus.dat_inclusao,
                            p_estrut_item_indus.cod_cliente  
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_estrut_item_indus.cod_empresa,
                            p_estrut_item_indus.cod_item_prd,
                            p_estrut_item_indus.dat_inclusao,
                            p_estrut_item_indus.cod_cliente
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem mais Itens nesta Direcao"
            LET p_estrut_item_indus.* = p_estrut_item_induss.* 
            EXIT WHILE
         END IF
        
         SELECT UNIQUE cod_empresa,
                       cod_item_prd,
                       dat_inclusao,
                       cod_cliente
            INTO p_estrut_item_indus.cod_empresa,
                 p_estrut_item_indus.cod_item_prd,
                 p_estrut_item_indus.dat_inclusao,
                 p_estrut_item_indus.cod_cliente  
         FROM estrut_item_indus
         WHERE cod_empresa  = p_estrut_item_indus.cod_empresa
           AND cod_item_prd = p_estrut_item_indus.cod_item_prd
           AND dat_inclusao = p_estrut_item_indus.dat_inclusao
           AND cod_cliente  = p_estrut_item_indus.cod_cliente 
  
         IF SQLCA.SQLCODE = 0 THEN 
            LET p_ies_cons = TRUE
            CALL pol0272_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
#FUNCTION pol0272_cursor_for_update()
#-----------------------------------#

{
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT cod_empresa,
          cod_item_prd,
          dat_inclusao,
          cod_cliente
      INTO p_estrut_item_indus.cod_empresa,
           p_estrut_item_indus.cod_item_prd,
           p_estrut_item_indus.dat_inclusao,
           p_estrut_item_indus.cod_cliente  
   FROM estrut_item_indus      
   WHERE cod_empresa = p_cod_empresa
     AND cod_item_prd = p_estrut_item_indus.cod_item_prd
     AND dat_inclusao = p_estrut_item_indus.dat_inclusao
     AND cod_cliente  = p_estrut_item_indus.cod_cliente 
   FOR UPDATE 
   BEGIN WORK
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","ESTRUT_ITEM_INDUS")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION   } 

#-----------------------------#
 FUNCTION pol0272_modificacao()
#-----------------------------#

   LET p_houve_erro = FALSE
#  IF pol0272_cursor_for_update() THEN
      LET p_estrut_item_induss.* = p_estrut_item_indus.*
      IF pol0272_entrada_itens("MODIFICACAO") THEN
         DELETE FROM estrut_item_indus
         WHERE cod_empresa  = p_estrut_item_indus.cod_empresa
           AND cod_item_prd = p_estrut_item_indus.cod_item_prd
           AND dat_inclusao = p_estrut_item_indus.dat_inclusao
           AND cod_cliente  = p_estrut_item_indus.cod_cliente 
         IF SQLCA.SQLCODE <> 0 THEN 
	          CALL log003_err_sql("EXCLUSAO","ESTRUT_ITEM_INDUS")
         #  ROLLBACK WORK
         END IF
         FOR p_i = 1 TO 100
            IF t_estrut_item[p_i].seq_estrut IS NOT NULL AND
               t_estrut_item[p_i].cod_item_ret IS NOT NULL THEN
               LET p_estrut_item_indus.seq_estrut = 
                   t_estrut_item[p_i].seq_estrut
               LET p_estrut_item_indus.cod_item_ret =
                   t_estrut_item[p_i].cod_item_ret
               LET p_estrut_item_indus.qtd_item_ret = 
                   t_estrut_item[p_i].qtd_item_ret
               INSERT INTO estrut_item_indus VALUES (p_estrut_item_indus.*)
               IF SQLCA.SQLCODE <> 0 THEN 
	                LET p_houve_erro = TRUE
                  EXIT FOR
               END IF
            END IF
         END FOR
         IF p_houve_erro = FALSE THEN
         #  COMMIT WORK
            MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         ELSE
	          CALL log003_err_sql("INCLUSAO","ESTRUT_ITEM_INDUS")
         #  ROLLBACK WORK
         END IF
      ELSE
         LET p_estrut_item_indus.* = p_estrut_item_induss.*
         ERROR "Modificacao Cancelada"
      #  ROLLBACK WORK
      #   DISPLAY BY NAME p_tela.*
      #   DISPLAY BY NAME p_item.*
         CALL pol0272_exibe_dados()
      END IF
   #  CLOSE cm_padrao
#  END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0272_exclusao()
#--------------------------#

#  IF pol0272_cursor_for_update() THEN
      IF log004_confirm(21,45) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM estrut_item_indus    
         WHERE cod_empresa  = p_estrut_item_indus.cod_empresa
           AND cod_item_prd = p_estrut_item_indus.cod_item_prd
           AND dat_inclusao = p_estrut_item_indus.dat_inclusao
           AND cod_cliente  = p_estrut_item_indus.cod_cliente 
         IF SQLCA.SQLCODE = 0 THEN
         #  COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-EXC","ESTRUT_ITEM_INDUS")
            ELSE
               MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE p_estrut_item_indus.* TO NULL
               CLEAR FORM
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","ESTRUT_ITEM_INDUS")
         #  ROLLBACK WORK
         END IF
         WHENEVER ERROR STOP
      END IF
   #  CLOSE cm_padrao
#  END IF

END FUNCTION   

#-----------------------#
 FUNCTION pol0272_popup()
#-----------------------#

   DEFINE p_cod_item_prd LIKE item.cod_item,
          p_cod_cliente  LIKE clientes.cod_cliente,
          p_cod_item_ret LIKE item.cod_item      
  
   CASE
      WHEN infield(cod_item_prd)
         LET p_cod_item_prd = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0272 
         IF p_cod_item_prd IS NOT NULL THEN
            LET p_tela.cod_item_prd = p_cod_item_prd
            DISPLAY BY NAME p_tela.cod_item_prd
         END IF
      WHEN infield(cod_cliente)
         LET p_cod_cliente = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0272 
         IF p_cod_cliente IS NOT NULL THEN 
            LET p_tela.cod_cliente = p_cod_cliente
            DISPLAY BY NAME p_tela.cod_cliente  
         END IF
      WHEN infield(cod_item_ret)
         LET pa_curr = ARR_CURR() 
         LET sc_curr = SCR_LINE()
         LET p_cod_item_ret = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0272 
         IF p_cod_item_ret IS NOT NULL THEN 
            LET t_estrut_item[pa_curr].cod_item_ret = p_cod_item_ret
            DISPLAY t_estrut_item[pa_curr].cod_item_ret TO 
                    s_estrut_item[sc_curr].cod_item_ret
         END IF
   END CASE

END FUNCTION  

#------------------------#
 FUNCTION pol0272_listar()
#------------------------#

   DEFINE sql_stmt1, where_clause1 CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause1 ON estrut_item_indus.cod_item_prd,
                                      estrut_item_indus.dat_inclusao,
                                      estrut_item_indus.cod_cliente
   
      ON KEY (control-z)
         CALL pol0272_popup()
         
   END CONSTRUCT
   
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0272
   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_estrut_item_indus.* = p_estrut_item_induss.*
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt1 = "SELECT UNIQUE cod_empresa, ",
                   "              cod_item_prd, ",
                   "              dat_inclusao, ",
                   "              cod_cliente ",
                   " FROM estrut_item_indus ",
                   " WHERE ", where_clause1 CLIPPED,
                   " ORDER BY dat_inclusao "

   PREPARE var_query1 FROM sql_stmt1  
   DECLARE cq_relat CURSOR WITH HOLD FOR var_query1

   OPEN cq_relat
   FETCH cq_relat INTO p_estrut_item_indus.cod_empresa,
                       p_estrut_item_indus.cod_item_prd,
                       p_estrut_item_indus.dat_inclusao,
                       p_estrut_item_indus.cod_cliente  

      IF SQLCA.SQLCODE = NOTFOUND THEN
         ERROR "Argumentos de Pesquisa não Encontrados"
         LET p_ies_cons = FALSE
         RETURN
      ELSE 
         DISPLAY BY NAME p_estrut_item_indus.cod_empresa,
                         p_estrut_item_indus.cod_item_prd,
                         p_estrut_item_indus.dat_inclusao,
                         p_estrut_item_indus.cod_cliente  
      END IF

   IF log028_saida_relat(21,42) IS NOT NULL THEN 
      MESSAGE " Processando a Extracao do Relatorio..." 
         ATTRIBUTE(REVERSE)
      IF p_ies_impressao = "S" THEN 
         IF g_ies_ambiente = "U" THEN
            START REPORT pol0272_relat TO PIPE p_nom_arquivo
         ELSE 
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'pol0272.tmp' 
            START REPORT pol0272_relat TO p_caminho 
         END IF 
      ELSE
         START REPORT pol0272_relat TO p_nom_arquivo
      END IF
   ELSE
      RETURN 
   END IF

   SELECT den_empresa
      INTO p_den_empresa
   FROM empresa
   WHERE cod_empresa = p_cod_empresa

   FOREACH cq_relat INTO p_estrut_item_indus.cod_empresa,
                         p_estrut_item_indus.cod_item_prd,
                         p_estrut_item_indus.dat_inclusao,
                         p_estrut_item_indus.cod_cliente

      LET p_relat.cod_item_prd = p_estrut_item_indus.cod_item_prd
      SELECT den_item_reduz
         INTO p_relat.den_item_prod
      FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = p_estrut_item_indus.cod_item_prd
      LET p_relat.dat_inclusao = p_estrut_item_indus.dat_inclusao
      LET p_relat.cod_cliente  = p_estrut_item_indus.cod_cliente
      SELECT nom_cliente   
         INTO p_relat.nom_cliente   
      FROM clientes
      WHERE cod_cliente = p_estrut_item_indus.cod_cliente

      DECLARE cq_relat_item CURSOR WITH HOLD FOR
      SELECT seq_estrut,
             cod_item_ret,
             qtd_item_ret
      FROM estrut_item_indus
      WHERE cod_empresa  = p_estrut_item_indus.cod_empresa
        AND cod_item_prd = p_estrut_item_indus.cod_item_prd
        AND dat_inclusao = p_estrut_item_indus.dat_inclusao
        AND cod_cliente  = p_estrut_item_indus.cod_cliente
      ORDER BY 1

      FOREACH cq_relat_item INTO p_relat.seq_estrut,
                                 p_relat.cod_item_ret,
                                 p_relat.qtd_item_ret

         SELECT den_item_reduz,
                cod_unid_med
            INTO p_relat.den_item_ret,
                 p_relat.cod_unid_med
         FROM item
         WHERE cod_empresa = p_estrut_item_indus.cod_empresa
           AND cod_item = p_relat.cod_item_ret

         OUTPUT TO REPORT pol0272_relat(p_relat.*)
      #  INITIALIZE p_relat.* TO NULL
         LET p_count = p_count + 1

      END FOREACH

   END FOREACH

   FINISH REPORT pol0272_relat

   IF p_count > 0 THEN
      IF p_ies_impressao = "S" THEN
         MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
            ATTRIBUTE(REVERSE)
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando 
         END IF
      ELSE 
         MESSAGE "Relatorio Gravado no Arquivo ", p_nom_arquivo, " " 
            ATTRIBUTE(REVERSE)
      END IF
   ELSE 
      MESSAGE "Nao Existem Dados para serem Listados"
         ATTRIBUTE(REVERSE)
   END IF

END FUNCTION

#----------------------------#
 REPORT pol0272_relat(p_relat)
#----------------------------# 

   DEFINE p_relat RECORD
      cod_item_prd  LIKE estrut_item_indus.cod_item_prd,
      den_item_prod LIKE item.den_item_reduz,
      dat_inclusao  LIKE estrut_item_indus.dat_inclusao,
      cod_cliente   LIKE estrut_item_indus.cod_cliente,
      nom_cliente   LIKE clientes.nom_cliente,         
      seq_estrut    LIKE estrut_item_indus.seq_estrut,
      cod_item_ret  LIKE estrut_item_indus.cod_item_ret,
      den_item_ret  LIKE item.den_item_reduz,
      cod_unid_med  LIKE item.cod_unid_med,
      qtd_item_ret  LIKE estrut_item_indus.qtd_item_ret
   END RECORD

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3

   FORMAT

      PAGE HEADER

         PRINT COLUMN 001, p_den_empresa[1,22],
               COLUMN 025, "LISTAGEM DOS PRODUTOS PRODUZIDOS",
               COLUMN 072, "FL. ", PAGENO USING "####&"
         PRINT COLUMN 001, "POL0272",
               COLUMN 042, "EXTRAIDO EM ", TODAY USING "dd/mm/yyyy",
               COLUMN 064, " AS ", TIME,
               COLUMN 077, "HRS."
         PRINT COLUMN 001, "*---------------------------------------",
                           "---------------------------------------*"

      BEFORE GROUP OF p_relat.cod_item_prd

         SKIP 1 LINE
         PRINT COLUMN 001, "Item Produzido : ", p_relat.cod_item_prd CLIPPED,
                           1 SPACE, p_relat.den_item_prod, 
               COLUMN 050, "Data Inclusao : ", p_relat.dat_inclusao
         PRINT COLUMN 001, "Cliente        : ", p_relat.cod_cliente, 1 SPACE, 
                           p_relat.nom_cliente
         SKIP 1 LINE

         PRINT COLUMN 003, "Seq", 
               COLUMN 010, "Item Retorno",
               COLUMN 027, "Descricao",
               COLUMN 047, "Unid Med",
               COLUMN 058, "Qte Item Retorno"
         SKIP 1 LINE

      ON EVERY ROW

         PRINT COLUMN 001, p_relat.seq_estrut USING "####&",
               COLUMN 010, p_relat.cod_item_ret,
               COLUMN 027, p_relat.den_item_ret,
               COLUMN 049, p_relat.cod_unid_med,
               COLUMN 059, p_relat.qtd_item_ret USING "###,###,##&.&&&"

END REPORT

#-----------------------#
 FUNCTION pol0272_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------ FIM DE PROGRAMA -------------------------------#