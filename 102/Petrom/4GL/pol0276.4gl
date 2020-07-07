#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL0276                                                 #
# MODULOS.: POL0276 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA ORDEM_MONTAG_TRAN                  #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 08/07/2004                                              #
#-------------------------------------------------------------------#
DATABASE logix
GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_num_pedido         LIKE ordem_montag_item.num_pedido,
          p_cod_cliente        LIKE pedidos.cod_cliente,                
          p_qtd_saldo          LIKE ordem_montag_tran.qtd_devolvida,
          p_qtd_neces          LIKE ordem_montag_tran.qtd_devolvida,
          p_qtd_om             LIKE ordem_montag_tran.qtd_devolvida,
          p_num_sequencia      LIKE ordem_montag_item.num_sequencia,
          p_cod_item           LIKE ordem_montag_item.cod_item,
          p_ies_sit_om         LIKE ordem_montag_mest.ies_sit_om,
          p_status             SMALLINT,
          p_houve_erro         SMALLINT,
          p_grava              SMALLINT,
          p_num_trans          INTEGER, 
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          p_caminho            CHAR(80),
          g_ies_ambiente       CHAR(001),
          p_count              SMALLINT,
          p_qtd_reg            SMALLINT,
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
      #   p_nom_tela           CHAR(200),
          p_nom_tela           CHAR(080),
          p_nom_help           CHAR(200),
          p_msg                CHAR(100),
          p_ies_cons           SMALLINT,
          p_last_row           SMALLINT,
          pa_curr              SMALLINT,
          sc_curr              SMALLINT,
          p_i                  SMALLINT,
          p_hoje               DATE

   DEFINE p_ordem_montag_tran  RECORD LIKE ordem_montag_tran.*,
          p_ordem_montag_trann RECORD LIKE ordem_montag_tran.*,
          p_estrut_item_indus  RECORD LIKE estrut_item_indus.*,
          p_nat_operacao       RECORD LIKE nat_operacao.*,
          p_item_de_terc       RECORD LIKE item_de_terc.*

   DEFINE p_item RECORD
      cod_item_prd  LIKE estrut_item_indus.cod_item_prd,
      den_item_prd  LIKE item.den_item_reduz,
      qtd_reservada LIKE ordem_montag_item.qtd_reservada
   END RECORD

   DEFINE p_tela RECORD
      num_om        LIKE ordem_montag_tran.num_om,
      cod_item_prd  LIKE estrut_item_indus.cod_item_prd,
      dat_inclusao  LIKE estrut_item_indus.dat_inclusao,
      cod_nat_oper  LIKE nat_operacao.cod_nat_oper
   END RECORD

   DEFINE t_montag_item ARRAY[100] OF RECORD
      num_pedido    LIKE ordem_montag_item.num_pedido,
      num_sequencia LIKE ordem_montag_item.num_sequencia,
      cod_item      LIKE ordem_montag_item.cod_item,
      den_item      LIKE item.den_item_reduz,
      cod_unid_med  LIKE item.cod_unid_med,
      qtd_reservada LIKE ordem_montag_item.qtd_reservada
   END RECORD

   DEFINE t_estrut_item ARRAY[100] OF RECORD
      dat_inclusao  LIKE estrut_item_indus.dat_inclusao,
      seq_estrut    LIKE estrut_item_indus.seq_estrut,
      cod_item_ret  LIKE estrut_item_indus.cod_item_ret,  
      den_item_ret  LIKE item.den_item_reduz,
      cod_unid_med  LIKE item.cod_unid_med,
      qtd_item_ret  LIKE estrut_item_indus.qtd_item_ret
   END RECORD

   DEFINE t_ordem_montag ARRAY[100] OF RECORD
      cod_item      LIKE ordem_montag_tran.cod_item,    
      den_item_ret  LIKE item.den_item_reduz,
      cod_unid_med  LIKE item.cod_unid_med,
      qtd_devolvida LIKE ordem_montag_tran.qtd_devolvida,
      pre_unit      LIKE ordem_montag_tran.pre_unit,
      num_nf        LIKE ordem_montag_tran.num_nf       
   END RECORD

   DEFINE p_relat RECORD
      num_om        LIKE ordem_montag_tran.num_om,
      cod_item_prd  LIKE estrut_item_indus.cod_item_prd,
      den_item_prd  LIKE item.den_item_reduz,
      cod_item_ret  LIKE estrut_item_indus.cod_item_ret,
      den_item_ret  LIKE item.den_item_reduz,
      cod_unid_med  LIKE item.cod_unid_med, 
      qtd_devolvida LIKE ordem_montag_tran.qtd_devolvida,
      pre_unit      LIKE ordem_montag_tran.pre_unit,
      num_nf        LIKE ordem_montag_tran.num_nf
   END RECORD
END GLOBALS
MAIN
#  CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0276-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0276.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0276_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0276_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL0276") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0276 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0276","IN") THEN
            CALL pol0276_inclusao() RETURNING p_status
         END IF
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0276","CO") THEN
            CALL pol0276_consulta()
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				 CALL pol0276_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 003
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0276

END FUNCTION

#--------------------------#
 FUNCTION pol0276_inclusao()
#--------------------------#

   LET p_grava = FALSE
   LET p_houve_erro = FALSE
   LET p_qtd_saldo = 0
   LET p_qtd_neces = 0
   IF pol0276_entrada_dados() THEN
   #  CALL log085_transacao("BEGIN") 
      BEGIN WORK
      SELECT COUNT(*)
         INTO p_qtd_reg
      FROM estrut_item_indus
      WHERE cod_empresa  = p_cod_empresa
        AND cod_item_prd = p_tela.cod_item_prd
        AND dat_inclusao = p_tela.dat_inclusao
        AND cod_cliente  = p_cod_cliente          
      DECLARE cq_estrut_item CURSOR WITH HOLD FOR
      SELECT *
      FROM estrut_item_indus
      WHERE cod_empresa  = p_cod_empresa
        AND cod_item_prd = p_tela.cod_item_prd
        AND dat_inclusao = p_tela.dat_inclusao
        AND cod_cliente  = p_cod_cliente          

      FOREACH cq_estrut_item INTO p_estrut_item_indus.*

         LET p_qtd_neces = p_item.qtd_reservada*p_estrut_item_indus.qtd_item_ret

         DECLARE cq_item_terc CURSOR WITH HOLD FOR
         SELECT *
         FROM item_de_terc
         WHERE cod_empresa = p_cod_empresa
           AND cod_fornecedor = p_estrut_item_indus.cod_cliente
           AND cod_item = p_estrut_item_indus.cod_item_ret
           AND qtd_tot_recebida - qtd_tot_devolvida > 0
         ORDER BY dat_emis_nf

         FOREACH cq_item_terc INTO p_item_de_terc.*

            LET p_qtd_saldo = p_item_de_terc.qtd_tot_recebida - 
                              p_item_de_terc.qtd_tot_devolvida

            SELECT sum(qtd_devolvida)
               INTO p_qtd_om
            FROM ordem_montag_tran a,
                 ordem_montag_mest b
            WHERE a.cod_empresa = b.cod_empresa
              AND a.num_om      = b.num_om 
              AND a.num_nf      = p_item_de_terc.num_nf
              AND a.ser_nf      = p_item_de_terc.ser_nf
              AND a.ssr_nf      = p_item_de_terc.ssr_nf
              AND a.cod_item    = p_item_de_terc.cod_item
              AND a.cod_empresa = p_cod_empresa           
              AND b.ies_sit_om <> "F"                     
            IF p_qtd_om IS NULL THEN
               LET p_qtd_om = 0
            END IF
          
            LET p_qtd_saldo = p_qtd_saldo - p_qtd_om 
 
            IF p_qtd_saldo <= 0 THEN
               CONTINUE FOREACH
            END IF

            IF p_qtd_saldo < p_qtd_neces THEN
               LET p_ordem_montag_tran.cod_empresa = p_cod_empresa
               LET p_ordem_montag_tran.num_om = p_tela.num_om
               LET p_ordem_montag_tran.num_pedido = p_num_pedido
               LET p_ordem_montag_tran.num_seq_item = p_num_sequencia
               LET p_ordem_montag_tran.cod_item = 
                   p_estrut_item_indus.cod_item_ret
               LET p_ordem_montag_tran.num_nf = p_item_de_terc.num_nf
               LET p_ordem_montag_tran.ser_nf = p_item_de_terc.ser_nf
               LET p_ordem_montag_tran.ssr_nf = p_item_de_terc.ssr_nf
               LET p_ordem_montag_tran.ies_especie_nf =
                   p_item_de_terc.ies_especie_nf
               LET p_ordem_montag_tran.num_seq_nf = p_item_de_terc.num_sequencia
               LET p_ordem_montag_tran.qtd_devolvida = p_qtd_saldo
               LET p_ordem_montag_tran.pre_unit = p_item_de_terc.val_remessa / 
                   p_item_de_terc.qtd_tot_recebida
               LET p_ordem_montag_tran.cod_nat_oper = p_tela.cod_nat_oper
               LET p_ordem_montag_tran.num_transacao = 0
               INSERT INTO ordem_montag_tran VALUES (p_ordem_montag_tran.*)
               IF SQLCA.SQLCODE <> 0 THEN 
      	          LET p_houve_erro = TRUE
	                CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_TRAN")
                  EXIT FOREACH
               END IF
               LET p_num_trans = SQLCA.SQLERRD[2]
               INSERT INTO ldi_om_trfor_inf_c VALUES (p_ordem_montag_tran.cod_empresa,p_num_trans,p_cod_cliente)
               LET p_qtd_neces = p_qtd_neces - p_qtd_saldo
            ELSE
               LET p_grava = TRUE 
               LET p_ordem_montag_tran.cod_empresa = p_cod_empresa
               LET p_ordem_montag_tran.num_om = p_tela.num_om
               LET p_ordem_montag_tran.num_pedido = p_num_pedido
               LET p_ordem_montag_tran.num_seq_item = p_num_sequencia
               LET p_ordem_montag_tran.cod_item = 
                   p_estrut_item_indus.cod_item_ret
               LET p_ordem_montag_tran.num_nf = p_item_de_terc.num_nf
               LET p_ordem_montag_tran.ser_nf = p_item_de_terc.ser_nf
               LET p_ordem_montag_tran.ssr_nf = p_item_de_terc.ssr_nf
               LET p_ordem_montag_tran.ies_especie_nf =
                   p_item_de_terc.ies_especie_nf
               LET p_ordem_montag_tran.num_seq_nf = p_item_de_terc.num_sequencia
               LET p_ordem_montag_tran.qtd_devolvida = p_qtd_neces
               LET p_ordem_montag_tran.pre_unit = p_item_de_terc.val_remessa / 
                   p_item_de_terc.qtd_tot_recebida
               LET p_ordem_montag_tran.cod_nat_oper = p_tela.cod_nat_oper
               LET p_ordem_montag_tran.num_transacao = 0
               INSERT INTO ordem_montag_tran VALUES (p_ordem_montag_tran.*)
               IF SQLCA.SQLCODE <> 0 THEN 
      	          LET p_houve_erro = TRUE
	                CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_TRAN")
                  EXIT FOREACH
               END IF
               LET p_num_trans = SQLCA.SQLERRD[2]
               INSERT INTO ldi_om_trfor_inf_c VALUES (p_ordem_montag_tran.cod_empresa,p_num_trans,p_cod_cliente)
               LET p_qtd_reg = p_qtd_reg - 1
               EXIT FOREACH
            END IF

         END FOREACH

         IF p_houve_erro = TRUE OR
            p_grava = FALSE THEN
            LET p_cod_item = p_estrut_item_indus.cod_item_ret
            EXIT FOREACH
         END IF

         LET p_cod_item = p_estrut_item_indus.cod_item_ret

      END FOREACH

      IF p_qtd_reg = 0 THEN 
         LET p_grava = TRUE 
      END IF 

      IF p_grava = FALSE OR
         p_qtd_reg > 0 THEN 
      #  CALL log085_transacao("ROLLBACK")
         ROLLBACK WORK
         LET p_msg = "Nao Existe Saldo de Terceiro para o Item --> ", 
                     p_cod_item CLIPPED
         ERROR p_msg
         RETURN FALSE
      END IF

      IF p_houve_erro = TRUE THEN
      #  CALL log085_transacao("ROLLBACK")
         ROLLBACK WORK
         RETURN FALSE
      ELSE
      #  CALL log085_transacao("COMMIT") 
         COMMIT WORK 
         MESSAGE "Inclusao Efetuada com Sucesso...!!!" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
   ELSE
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF    

   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol0276_entrada_dados()
#-------------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0276
   CLEAR FORM
   INITIALIZE p_tela.*, p_ordem_montag_tran.* TO NULL
   DISPLAY BY NAME p_tela.*
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG = FALSE
   INPUT BY NAME p_tela.* 
      WITHOUT DEFAULTS  

      AFTER FIELD num_om        
      IF p_tela.num_om IS NOT NULL THEN
         SELECT UNIQUE num_om
         FROM ordem_montag_tran
         WHERE cod_empresa = p_cod_empresa
           AND num_om = p_tela.num_om        
         IF SQLCA.SQLCODE = 0 THEN
            ERROR "Ordem de Montagem Já Cadastrada"
            NEXT FIELD num_om
         END IF
         SELECT ies_sit_om
            INTO p_ies_sit_om
         FROM ordem_montag_mest
         WHERE cod_empresa = p_cod_empresa
           AND num_om = p_tela.num_om        
         IF p_ies_sit_om = "F" THEN
            ERROR "Ordem de Montagem Já Faturada !!!"
            NEXT FIELD num_om
         END IF
         SELECT UNIQUE num_pedido
            INTO p_num_pedido
         FROM ordem_montag_item
         WHERE cod_empresa = p_cod_empresa
           AND num_om = p_tela.num_om        
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Ordem de Montagem nao Cadastrada"
            NEXT FIELD num_om
         END IF
         SELECT cod_cliente
            INTO p_cod_cliente
         FROM pedidos 
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_num_pedido
      ELSE
         ERROR "O Campo Numero da O.M. nao pode ser Nulo"
         NEXT FIELD num_om
      END IF

      AFTER FIELD cod_item_prd
      IF p_tela.cod_item_prd IS NOT NULL THEN
         SELECT qtd_reservada,
                num_sequencia
            INTO p_item.qtd_reservada,
                 p_num_sequencia
         FROM ordem_montag_item
         WHERE cod_empresa = p_cod_empresa
           AND num_om = p_tela.num_om        
           AND cod_item = p_tela.cod_item_prd
         IF p_item.qtd_reservada IS NULL THEN
            ERROR "Item nao Cadastrado para esta O.M."
            NEXT FIELD cod_item_prd
         ELSE
            SELECT UNIQUE cod_item_prd
            FROM estrut_item_indus
            WHERE cod_empresa = p_cod_empresa
              AND cod_item_prd = p_tela.cod_item_prd 
            IF SQLCA.SQLCODE <> 0 THEN
               ERROR "Item Inexistente na Tabela Produtos Industrializados"
               NEXT FIELD cod_item_prd
            END IF
            SELECT den_item_reduz
               INTO p_item.den_item_prd
            FROM item
            WHERE cod_empresa = p_cod_empresa
              AND cod_item = p_tela.cod_item_prd
            DISPLAY BY NAME p_item.den_item_prd,
                            p_item.qtd_reservada
         END IF
      ELSE
         ERROR "O Campo Item Produzido nao pode ser Nulo"
         NEXT FIELD cod_item_prd
      END IF
      
      LET p_hoje = TODAY
      
      BEFORE FIELD dat_inclusao
         SELECT MAX(dat_inclusao)
            INTO p_tela.dat_inclusao
         FROM estrut_item_indus
         WHERE cod_empresa = p_cod_empresa
           AND cod_item_prd = p_tela.cod_item_prd 
           AND dat_inclusao < p_hoje
         
      AFTER FIELD dat_inclusao
      IF p_tela.dat_inclusao IS NOT NULL THEN
         SELECT UNIQUE dat_inclusao
         FROM estrut_item_indus
         WHERE cod_empresa = p_cod_empresa
           AND cod_item_prd = p_tela.cod_item_prd 
           AND dat_inclusao = p_tela.dat_inclusao
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Data da Formula nao Cadastrada p/ este Produto"
            NEXT FIELD dat_inclusao
         END IF
      ELSE
         ERROR "O Campo Data da Formula nao pode ser Nulo"
         NEXT FIELD dat_inclusao
      END IF

      BEFORE FIELD cod_nat_oper
         LET p_tela.cod_nat_oper = 1104

      AFTER FIELD cod_nat_oper
      IF p_tela.cod_nat_oper IS NOT NULL THEN
         SELECT den_nat_oper,   
                ies_tip_controle
            INTO p_nat_operacao.den_nat_oper,
                 p_nat_operacao.ies_tip_controle
         FROM nat_operacao 
         WHERE cod_nat_oper = p_tela.cod_nat_oper
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Operacao de Retorno nao Cadastrada"
            NEXT FIELD cod_nat_oper
         ELSE
            DISPLAY BY NAME p_nat_operacao.den_nat_oper
            IF p_nat_operacao.ies_tip_controle <> "3" THEN
               ERROR "Operacao nao é de Retorno"
               NEXT FIELD cod_nat_oper
            END IF
         END IF
      ELSE
         ERROR "O Campo Operacao Retorno nao pode ser Nulo"
         NEXT FIELD cod_nat_oper
      END IF
      
      ON KEY (control-z)
         CALL pol0276_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0276
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
 FUNCTION pol0276_consulta()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL02762") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol02762 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0276","CO") THEN
            CALL pol0276_consulta_ordem()
            IF p_ies_cons = TRUE THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0276_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0276_paginacao("ANTERIOR") 
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 007
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0276","EX") THEN
            IF p_ies_cons THEN
               CALL pol0276_exclusao()
            ELSE
               ERROR "Consulte Previamente para fazer a Exclusao"
            END IF
         END IF 
      COMMAND "Listar" "Lista Parametros de Entrada"
         HELP 008
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","POL0276","CO") THEN
            IF p_ies_cons THEN
               CALL pol0276_listar() 
            ELSE
               ERROR "Informar Previamente Parametros de Entrada"
            END IF
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 009
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol02762

END FUNCTION

#--------------------------------#
 FUNCTION pol0276_consulta_ordem()
#--------------------------------#

   DEFINE sql_stmt, where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON ordem_montag_tran.num_om

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol02762
   IF INT_FLAG THEN
      LET p_ordem_montag_tran.* = p_ordem_montag_trann.*
      CLEAR FORM
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT UNIQUE cod_empresa, ",
                  "              num_om, ",
                  "              num_seq_item ",
                  "FROM ordem_montag_tran ",
                  "WHERE ", where_clause CLIPPED,
                  "ORDER BY num_om "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_ordem_montag_tran.cod_empresa,
                        p_ordem_montag_tran.num_om,
                        p_ordem_montag_tran.num_seq_item

      IF SQLCA.SQLCODE = NOTFOUND THEN
         ERROR "Argumentos de Pesquisa nao Encontrados"
         LET p_ies_cons = FALSE
      ELSE 
         LET p_ies_cons = TRUE
         CALL pol0276_exibe_dados()
      END IF

END FUNCTION  

#-----------------------------#
 FUNCTION pol0276_exibe_dados()
#-----------------------------#
 
   SELECT cod_item
      INTO p_item.cod_item_prd
   FROM ordem_montag_item
   WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
     AND num_om = p_ordem_montag_tran.num_om
     AND num_sequencia = p_ordem_montag_tran.num_seq_item

   SELECT den_item_reduz
      INTO p_item.den_item_prd
   FROM item
   WHERE cod_empresa = p_cod_empresa
     AND cod_item = p_item.cod_item_prd

   DISPLAY BY NAME p_ordem_montag_tran.num_om,
                   p_item.cod_item_prd,
                   p_item.den_item_prd

   INITIALIZE t_ordem_montag TO NULL
   DECLARE cq_ordem CURSOR WITH HOLD FOR
   SELECT cod_item,
          num_nf,     
          qtd_devolvida,
          pre_unit
   FROM ordem_montag_tran 
   WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
     AND num_om = p_ordem_montag_tran.num_om        
     AND num_seq_item = p_ordem_montag_tran.num_seq_item
   ORDER BY 1

   LET p_i = 1
   FOREACH cq_ordem INTO t_ordem_montag[p_i].cod_item,
                         t_ordem_montag[p_i].num_nf,       
                         t_ordem_montag[p_i].qtd_devolvida,
                         t_ordem_montag[p_i].pre_unit

      SELECT den_item_reduz,
             cod_unid_med
         INTO t_ordem_montag[p_i].den_item_ret,
              t_ordem_montag[p_i].cod_unid_med
      FROM item
      WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
        AND cod_item = t_ordem_montag[p_i].cod_item
      LET p_i = p_i + 1

   END FOREACH

   LET p_i = p_i - 1
   CALL SET_COUNT(p_i)
   DISPLAY ARRAY t_ordem_montag TO s_ordem_montag.*
   END DISPLAY

END FUNCTION   

#-----------------------------------#
 FUNCTION pol0276_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_ordem_montag_trann.* = p_ordem_montag_tran.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_ordem_montag_tran.cod_empresa,
                            p_ordem_montag_tran.num_om,       
                            p_ordem_montag_tran.num_seq_item 
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_ordem_montag_tran.cod_empresa,
                            p_ordem_montag_tran.num_om,       
                            p_ordem_montag_tran.num_seq_item  
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem mais Itens nesta Direcao"
            LET p_ordem_montag_tran.* = p_ordem_montag_trann.*
            EXIT WHILE
         END IF
        
         SELECT UNIQUE cod_empresa,
                       num_om,
                       num_seq_item
            INTO p_ordem_montag_tran.cod_empresa,
                 p_ordem_montag_tran.num_om,     
                 p_ordem_montag_tran.num_seq_item 
         FROM ordem_montag_tran
         WHERE cod_empresa  = p_ordem_montag_tran.cod_empresa
           AND num_om = p_ordem_montag_tran.num_om
           AND num_seq_item = p_ordem_montag_tran.num_seq_item
  
         IF SQLCA.SQLCODE = 0 THEN 
            LET p_ies_cons = TRUE
            CALL pol0276_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION   
 
#--------------------------#
 FUNCTION pol0276_exclusao()
#--------------------------#

   IF log004_confirm(20,45) THEN
      SELECT ies_sit_om
         INTO p_ies_sit_om
      FROM ordem_montag_mest
      WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
        AND num_om = p_ordem_montag_tran.num_om
      IF p_ies_sit_om = "F" THEN
         MESSAGE "Exclusao nao Permitida - Ordem de Montagem Faturada !!!"
            ATTRIBUTE(REVERSE)
         RETURN
      END IF
   #  CALL log085_transacao("BEGIN") 
      BEGIN WORK
      WHENEVER ERROR CONTINUE
      DELETE FROM ordem_montag_tran
      WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
        AND num_om = p_ordem_montag_tran.num_om
        AND num_seq_item = p_ordem_montag_tran.num_seq_item
      IF SQLCA.SQLCODE = 0 THEN
      #  CALL log085_transacao("COMMIT") 
         COMMIT WORK
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("EFET-COMMIT-EXC","ORDEM_MONTAG_TRAN")
         ELSE
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_ordem_montag_tran.* TO NULL
            CLEAR FORM
         END IF
      ELSE
         CALL log003_err_sql("EXCLUSAO","ORDEM_MONTAG_TRAN")
      #  CALL log085_transacao("ROLLBACK")
         ROLLBACK WORK
      END IF
      WHENEVER ERROR STOP
   END IF

END FUNCTION   

#-----------------------#
 FUNCTION pol0276_popup()
#-----------------------#

   DEFINE p_cod_nat_oper LIKE nat_operacao.cod_nat_oper
  
   CASE
      WHEN INFIELD(cod_item_prd)
         CALL pol0276_busca_item()
            RETURNING t_montag_item[pa_curr].*
            CURRENT WINDOW IS w_pol0276
            LET p_tela.cod_item_prd = t_montag_item[pa_curr].cod_item
            DISPLAY BY NAME p_tela.cod_item_prd
      WHEN INFIELD(cod_nat_oper)
         CALL log009_popup(6,25,"NAT. OPERACAO","nat_operacao","cod_nat_oper",
                           "den_nat_oper","","N","ies_tip_controle = '3'") 
            RETURNING p_cod_nat_oper
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0276 
         IF p_cod_nat_oper IS NOT NULL THEN 
            LET p_tela.cod_nat_oper = p_cod_nat_oper
            DISPLAY BY NAME p_tela.cod_nat_oper
         END IF
      WHEN INFIELD(dat_inclusao)
         CALL pol0276_busca_data()
            RETURNING t_estrut_item[pa_curr].*
            CURRENT WINDOW IS w_pol0276
            LET p_tela.dat_inclusao = t_estrut_item[pa_curr].dat_inclusao
            DISPLAY BY NAME p_tela.dat_inclusao
   END CASE

END FUNCTION  

#----------------------------#
 FUNCTION pol0276_busca_item()
#----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol02763") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol02763 AT 3,5 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   INITIALIZE t_montag_item TO NULL
   CLEAR FORM

   DECLARE cq_item_prd CURSOR WITH HOLD FOR
   SELECT num_pedido,
          num_sequencia,
          cod_item,
          qtd_reservada
   FROM ordem_montag_item
   WHERE cod_empresa  = p_cod_empresa
     AND num_om = p_tela.num_om      

   LET p_i = 1
   FOREACH cq_item_prd INTO t_montag_item[p_i].num_pedido,  
                            t_montag_item[p_i].num_sequencia,
                            t_montag_item[p_i].cod_item,     
                            t_montag_item[p_i].qtd_reservada

      SELECT den_item_reduz,
             cod_unid_med
         INTO t_montag_item[p_i].den_item,
              t_montag_item[p_i].cod_unid_med
      FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = t_montag_item[p_i].cod_item
      LET p_i = p_i + 1

   END FOREACH 

   LET p_i = p_i - 1
   CALL SET_COUNT(p_i)

   LET INT_FLAG = FALSE
   INPUT ARRAY t_montag_item WITHOUT DEFAULTS FROM s_montag_item.*

      BEFORE FIELD num_pedido  
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD num_pedido  
         IF t_montag_item[pa_curr].num_pedido IS NULL THEN
            EXIT INPUT
         END IF

   END INPUT 

   IF INT_FLAG THEN
      INITIALIZE t_montag_item TO NULL
      CLOSE WINDOW w_pol02763
      RETURN t_montag_item[1].*
   ELSE
      CLOSE WINDOW w_pol02763
      RETURN t_montag_item[pa_curr].*
   END IF
 
END FUNCTION  

#----------------------------#
 FUNCTION pol0276_busca_data()
#----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol02761") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol02761 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   INITIALIZE t_estrut_item TO NULL
   CLEAR FORM

   DISPLAY BY NAME p_tela.cod_item_prd,
                   p_item.den_item_prd

   DECLARE cq_item_ret CURSOR WITH HOLD FOR
   SELECT dat_inclusao,
          seq_estrut,
          cod_item_ret,
          qtd_item_ret
   FROM estrut_item_indus
   WHERE cod_empresa  = p_cod_empresa
     AND cod_item_prd = p_tela.cod_item_prd
     AND cod_cliente  = p_cod_cliente   

   LET p_i = 1
   FOREACH cq_item_ret INTO t_estrut_item[p_i].dat_inclusao,
                            t_estrut_item[p_i].seq_estrut,  
                            t_estrut_item[p_i].cod_item_ret,     
                            t_estrut_item[p_i].qtd_item_ret

      SELECT den_item_reduz,
             cod_unid_med
         INTO t_estrut_item[p_i].den_item_ret,
              t_estrut_item[p_i].cod_unid_med
      FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = t_estrut_item[p_i].cod_item_ret
      LET p_i = p_i + 1

   END FOREACH 

   LET p_i = p_i - 1
   CALL SET_COUNT(p_i)

   LET INT_FLAG = FALSE
   INPUT ARRAY t_estrut_item WITHOUT DEFAULTS FROM s_estrut_item.*

      BEFORE FIELD dat_inclusao
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD dat_inclusao
         IF t_estrut_item[pa_curr].dat_inclusao IS NULL THEN
            EXIT INPUT
         END IF

   END INPUT 

   IF INT_FLAG THEN
      INITIALIZE t_estrut_item TO NULL
      CLOSE WINDOW w_pol02761
      RETURN t_estrut_item[1].*
   ELSE
      CLOSE WINDOW w_pol02761
      RETURN t_estrut_item[pa_curr].*
   END IF
 
END FUNCTION  

#------------------------#
 FUNCTION pol0276_listar()
#------------------------#

   DEFINE sql_stmt1, where_clause1 CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause1 ON ordem_montag_tran.num_om        

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol02762
   IF INT_FLAG THEN
      LET p_ordem_montag_tran.* = p_ordem_montag_trann.*
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt1 = "SELECT UNIQUE cod_empresa, ",
                   "              num_om, ",
                   "              num_seq_item ",
                   " FROM ordem_montag_tran ",
                   " WHERE ", where_clause1 CLIPPED
               #   " ORDER BY num_om "

   PREPARE var_query1 FROM sql_stmt1  
   DECLARE cq_relat CURSOR WITH HOLD FOR var_query1

   OPEN cq_relat
   FETCH cq_relat INTO p_ordem_montag_tran.cod_empresa,
                       p_ordem_montag_tran.num_om,
                       p_ordem_montag_tran.num_seq_item

      IF SQLCA.SQLCODE = NOTFOUND THEN
         ERROR "Argumentos de Pesquisa nao Encontrados"
         LET p_ies_cons = FALSE
         RETURN
      ELSE 
         SELECT cod_item
            INTO p_item.cod_item_prd
         FROM ordem_montag_item
         WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
           AND num_om = p_ordem_montag_tran.num_om
           AND num_sequencia = p_ordem_montag_tran.num_seq_item
         SELECT den_item_reduz
            INTO p_item.den_item_prd
         FROM item
         WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
           AND cod_item = p_item.cod_item_prd
         DISPLAY BY NAME p_ordem_montag_tran.cod_empresa,
                         p_ordem_montag_tran.num_om,
                         p_item.cod_item_prd,
                         p_item.den_item_prd
      END IF

   IF log028_saida_relat(20,42) IS NOT NULL THEN 
      MESSAGE " Processando a Extracao do Relatorio..." 
         ATTRIBUTE(REVERSE)
      IF p_ies_impressao = "S" THEN 
         IF g_ies_ambiente = "U" THEN
            START REPORT pol0276_relat TO PIPE p_nom_arquivo
         ELSE 
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'pol0276.tmp' 
            START REPORT pol0276_relat TO p_caminho 
         END IF 
      ELSE
         START REPORT pol0276_relat TO p_nom_arquivo
      END IF
   ELSE
      RETURN 
   END IF

   SELECT den_empresa
      INTO p_den_empresa
   FROM empresa
   WHERE cod_empresa = p_cod_empresa

   FOREACH cq_relat INTO p_ordem_montag_tran.cod_empresa,
                         p_ordem_montag_tran.num_om,
                         p_ordem_montag_tran.num_seq_item

      LET p_relat.num_om = p_ordem_montag_tran.num_om       
      SELECT cod_item
         INTO p_relat.cod_item_prd
      FROM ordem_montag_item
      WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
        AND num_om = p_ordem_montag_tran.num_om
        AND num_sequencia = p_ordem_montag_tran.num_seq_item
      SELECT den_item_reduz
         INTO p_relat.den_item_prd
      FROM item
      WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
        AND cod_item = p_relat.cod_item_prd

      DECLARE cq_relat_item CURSOR WITH HOLD FOR
      SELECT cod_item,
             num_nf,      
             qtd_devolvida, 
             pre_unit     
      FROM ordem_montag_tran
      WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
        AND num_om = p_ordem_montag_tran.num_om       
        AND num_seq_item = p_ordem_montag_tran.num_seq_item
      ORDER BY 1

      LET p_count = 0
      FOREACH cq_relat_item INTO p_relat.cod_item_ret,
                                 p_relat.num_nf,      
                                 p_relat.qtd_devolvida,
                                 p_relat.pre_unit

         SELECT den_item_reduz,
                cod_unid_med
            INTO p_relat.den_item_ret,
                 p_relat.cod_unid_med
         FROM item
         WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
           AND cod_item = p_relat.cod_item_ret

         OUTPUT TO REPORT pol0276_relat(p_relat.*)
      #  INITIALIZE p_relat.* TO NULL
         LET p_count = p_count + 1

      END FOREACH

   END FOREACH

   FINISH REPORT pol0276_relat

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
 REPORT pol0276_relat(p_relat)
#----------------------------# 

   DEFINE p_relat RECORD
      num_om        LIKE ordem_montag_tran.num_om,
      cod_item_prd  LIKE estrut_item_indus.cod_item_prd,
      den_item_prd  LIKE item.den_item_reduz,
      cod_item_ret  LIKE estrut_item_indus.cod_item_ret,
      den_item_ret  LIKE item.den_item_reduz,
      cod_unid_med  LIKE item.cod_unid_med, 
      qtd_devolvida LIKE ordem_montag_tran.qtd_devolvida,
      pre_unit      LIKE ordem_montag_tran.pre_unit,
      num_nf        LIKE ordem_montag_tran.num_nf      
   END RECORD

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3

   ORDER EXTERNAL BY p_relat.num_om,
                     p_relat.cod_item_prd

   FORMAT

      PAGE HEADER

         PRINT COLUMN 001, p_den_empresa[1,21],
               COLUMN 024, "LISTAGEM DE RETORNO DE MERCADORIAS",
               COLUMN 072, "FL. ", PAGENO USING "####&"
         PRINT COLUMN 001, "POL0276",
               COLUMN 042, "EXTRAIDO EM ", TODAY USING "dd/mm/yyyy",
               COLUMN 064, " AS ", TIME,
               COLUMN 077, "HRS."
         PRINT COLUMN 001, "*---------------------------------------",
                           "---------------------------------------*"

      BEFORE GROUP OF p_relat.num_om

         SKIP 1 LINE
         PRINT COLUMN 001, "O.M. : ", p_relat.num_om USING "#####&"

      BEFORE GROUP OF p_relat.cod_item_prd

         SKIP 1 LINE
         PRINT COLUMN 001, "Item Produzido : ", p_relat.cod_item_prd CLIPPED,
                           1 SPACE, p_relat.den_item_prd
         SKIP 1 LINE

         PRINT COLUMN 001, "Item Retorno", 
               COLUMN 018, "Descricao",
               COLUMN 038, "U.M.",
               COLUMN 047, "Qtde Devolvida",
               COLUMN 064, "Preco Unit",
               COLUMN 077, "N.F." 
         SKIP 1 LINE

      ON EVERY ROW

         PRINT COLUMN 001, p_relat.cod_item_ret,
               COLUMN 018, p_relat.den_item_ret,
               COLUMN 040, p_relat.cod_unid_med,
               COLUMN 047, p_relat.qtd_devolvida USING "##,###,##&.&&&",
               COLUMN 062, p_relat.pre_unit USING "#,###,##&.&&",
               COLUMN 075, p_relat.num_nf USING "#####&"

END REPORT    

#-----------------------#
 FUNCTION pol0276_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION   

#------------------------------ FIM DE PROGRAMA -------------------------------#